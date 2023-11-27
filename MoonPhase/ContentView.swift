//
//  ContentView.swift
//  TrialAnimation
//
//  Created by Lorand Ignat on 13.11.2023.
//

import SwiftUI
import SceneKit
import MoonKit

struct ContentView: View {
  
  private let scene = PlanetScene()
  @State private var expanded = false
  @State private var days = 0.0
  @State private var animateGradient = false
  
  var body: some View {
    ZStack {
      LinearGradient(colors: [.black, expanded ? .black : .red], startPoint: .top, endPoint: .bottom)
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.easeInOut(duration: 10.0).repeatForever(autoreverses: true)) {
                animateGradient.toggle()
            }
        }
      PlanetSceneView(scene: scene)
        .ignoresSafeArea()
        .onChange(of: expanded) { oldValue, _ in
          if oldValue {
            scene.moveCameraToMoonView(animated: true)
          } else {
            scene.moveCameraToFullView(animated: true)
          }
        }
        .onChange(of: days) { _, newValue in
          scene.movePlanetsInSolarSystem(addedTime: newValue, animated: false)
          if expanded {
            scene.moveCameraToFullView(animated: false)
          } else {
            scene.moveCameraToMoonView(animated: false)
          }
        }
      VStack {
        HStack {
          Spacer()
          VStack {
            Button {
              withAnimation {
                expanded.toggle()
              }
            } label: {
              Image(systemName: "arrow.up.arrow.down")
                .resizable()
                .frame(width: 30, height: 30)
            }
            .tint(.gray)
            .padding(EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20))
            Spacer()
          }
        }
        Spacer()
        Text(scene.displayingDate(), style: .date)
          .tint(.black)
        Text(scene.displayingDate(), style: .time)
          .tint(.black)
        Slider(value: $days, in: -29.53059...29.53059)
          .padding(EdgeInsets(top: 0, leading: 40, bottom: 40, trailing: 40))
          .tint(.gray)
      }
    }
  }
}

struct PlanetSceneView : UIViewRepresentable {
  
  weak var scene: PlanetScene?
  
  func makeUIView(context: Context) -> SCNView {
    let scnView = SCNView()
    return scnView
  }
  
  func updateUIView(_ scnView: SCNView, context: Context) {
    scnView.scene = scene
    scnView.backgroundColor = UIColor.clear
  }
}

class PlanetScene: SCNScene {
  
  private var earthRotationAroundSun = 0.0
  private var moonRotationAroundEarth = 0.0
  
  private let solarSystem: SCNNode
  private let earthSystem: SCNNode
  private let sunNode: SCNNode
  private let earthNode: SCNNode
  private let moonNode: SCNNode
  private let cameraNode: SCNNode
  
  private var date: Date
  private var moonDetails: Moon
  private var initialMoonAge: Double
  
  override init() {
    
    cameraNode = SCNNode()
    cameraNode.camera = SCNCamera()
    cameraNode.camera?.zFar = 300
    cameraNode.camera?.zNear = 0.1
    cameraNode.camera?.focalLength = 30
    cameraNode.position = SCNVector3(0, 0, 0)
    
    sunNode = Self.createSun()
    earthNode = Self.createEarth()
    moonNode = Self.createMoon()
    
    earthSystem = SCNNode()
    earthSystem.position = SCNVector3(0, 0, -36)
    
    solarSystem = SCNNode()
    solarSystem.position = SCNVector3(0, 0, 0)

    earthSystem.addChildNode(earthNode)
    earthSystem.addChildNode(moonNode)
    
    solarSystem.addChildNode(sunNode)
    solarSystem.addChildNode(earthSystem)
    
    date = Date()
    moonDetails = Moon(date)
    initialMoonAge = moonDetails.info.age
    
    super.init()
    
    rootNode.position = SCNVector3(0, 0, 0)
    rootNode.addChildNode(solarSystem)
    rootNode.addChildNode(cameraNode)
    
    movePlanetsInSolarSystem()
    moveCameraToMoonView()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func displayingDate() -> Date {
    date
  }
  
  func moonIllumination() -> Double {
    return moonDetails.info.age / 29.53059 * 100
  }
  
  func moonDistance() -> Double {
    return moonDetails.info.distance
  }
  
  func moonPhase() -> Moon.Phase {
    return moonDetails.info.phase
  }
}

extension PlanetScene {
  
  func movePlanetsInSolarSystem(addedTime: Double = 0.0, animated: Bool = false) {

    let extraDay = Int(addedTime)
    let extraHour = Int((addedTime - Double(extraDay)) * 24)

    let todayAddedDay = Calendar.current.date(byAdding: .day, value: extraDay, to: Date()) ?? Date()
    let todayAddedDayAndHour = Calendar.current.date(byAdding: .hour, value: extraHour, to: todayAddedDay) ?? Date()
    
    let day = Double(Calendar.current.ordinality(of: .day, in: .year, for: todayAddedDayAndHour) ?? 0)
    let hour = Double(Calendar.current.ordinality(of: .hour, in: .day, for: todayAddedDayAndHour) ?? 0)
    
    date = todayAddedDayAndHour
    moonDetails = Moon(date)

    earthRotationAroundSun = day / 365.25 * 2 * Double.pi
    moonRotationAroundEarth = (initialMoonAge + addedTime) / 29.53059 * 2 * Double.pi

    let earthRotation = -0.22 + Double.pi + hour / 24 * 2 * Double.pi - moonRotationAroundEarth
    
    let solarSystemRotation = SCNVector4(0, 1, 0, earthRotationAroundSun)
    if animated {
      let animation = CABasicAnimation(keyPath: "rotation")
      animation.fromValue = solarSystem.rotation
      animation.toValue = solarSystemRotation
      animation.duration = 1
      animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
      solarSystem.addAnimation(animation, forKey: nil)
    }
    solarSystem.rotation = solarSystemRotation
    
    let earthSystemRotation = SCNVector4(0, 1, 0, moonRotationAroundEarth)
    if animated {
      let animation = CABasicAnimation(keyPath: "rotation")
      animation.fromValue = earthSystem.rotation
      animation.toValue = earthSystemRotation
      animation.duration = 1
      animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
      earthSystem.addAnimation(animation, forKey: nil)
    }
    earthSystem.rotation = earthSystemRotation

    let earthRotationVector = SCNVector4(0, 1, 0, earthRotation)
    if animated {
      let animation = CABasicAnimation(keyPath: "rotation")
      animation.fromValue = earthNode.rotation
      animation.toValue = earthRotationVector
      animation.duration = 1
      animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
      earthNode.addAnimation(animation, forKey: nil)
    }
    earthNode.rotation = earthRotationVector
  }
  
  func moveCameraToMoonView(animated: Bool = false) {
    
    var transform = SCNMatrix4Mult( SCNMatrix4MakeRotation(Float(earthRotationAroundSun), 0, 1, 0), SCNMatrix4Identity)
    transform = SCNMatrix4Mult( SCNMatrix4MakeTranslation(0, 0, -36), transform)
    transform = SCNMatrix4Mult( SCNMatrix4MakeRotation(Float(moonRotationAroundEarth) + Float.pi, 0, 1, 0), transform)
    transform = SCNMatrix4Mult( SCNMatrix4MakeTranslation(0, -1, 0), transform)
    
    if animated {
      let animation = CABasicAnimation(keyPath: "transform")
      animation.fromValue = cameraNode.transform
      animation.toValue = transform
      animation.duration = 1
      animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
      cameraNode.addAnimation(animation, forKey: nil)
      
      // Note: hide sun mid animation, while camera is pointing away
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
        self.sunNode.opacity = 0.0
      }
    } else {
      sunNode.opacity = 0.0
    }
    background.contents = nil
    cameraNode.transform = transform
  }
  
  func moveCameraToFullView(animated: Bool = false) {
    
    var transform = SCNMatrix4Mult( SCNMatrix4MakeRotation(Float(earthRotationAroundSun), 0, 1, 0), SCNMatrix4Identity)
    transform = SCNMatrix4Mult( SCNMatrix4MakeTranslation(0, 70, -30), transform)
    transform = SCNMatrix4Mult( SCNMatrix4MakeRotation(-Float.pi / 2, 1, 0, 0), transform)
    
    if animated {
      let animation = CABasicAnimation(keyPath: "transform")
      animation.fromValue = cameraNode.transform
      animation.toValue = transform
      animation.duration = 1
      animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
      cameraNode.addAnimation(animation, forKey: nil)
      
      // Note: background.contents cannot be animated if it's a UIImage
      DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
        self.background.contents = UIImage(named: "8k_stars_milky_way")
      }
      
      // Note: show sun mid animation, while camera is pointing away
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
        self.sunNode.opacity = 1
      }
    } else {
      background.contents = UIImage(named: "8k_stars_milky_way")
      sunNode.opacity = 1
    }
    
    cameraNode.transform = transform
  }
}

extension PlanetScene {
  
  private static func createSun() -> SCNNode {
    
    let planetGeometry = SCNSphere(radius: 16)
    planetGeometry.segmentCount = 100
    
    let planetMaterial = SCNMaterial()
    planetMaterial.diffuse.contents = UIImage(named: "8k_sun")
    planetGeometry.materials = [planetMaterial]
    
    planetGeometry.firstMaterial?.lightingModel = SCNMaterial.LightingModel.constant
    planetGeometry.firstMaterial?.transparency = 1
    
    let sunNode = SCNNode(geometry: planetGeometry)
    sunNode.position = SCNVector3(0, 0, 0)
    
    let changeColor = SCNAction.customAction(duration: 1000) { (node, elapsedTime) -> () in
      let percentage = sin(elapsedTime / 10)
      node.geometry!.firstMaterial!.diffuse.contentsTransform = SCNMatrix4MakeScale(1, Float(percentage) / 5 + 1, 1)
      let color = UIColor(red: (CGFloat(percentage) + 1) / 2, green: 0, blue: 0, alpha: 1)
      node.geometry!.firstMaterial!.emission.contents = color
    }
    sunNode.runAction(SCNAction.repeatForever(changeColor))
    
    sunNode.light = SCNLight()
    sunNode.light?.type = SCNLight.LightType.omni
    sunNode.light?.color = UIColor(white: 1, alpha: 1)
    
    let planetLightNodeLeft = SCNNode()
    planetLightNodeLeft.position = SCNVector3(6, 0, 0)
    planetLightNodeLeft.light = SCNLight()
    planetLightNodeLeft.light?.type = SCNLight.LightType.omni
    planetLightNodeLeft.light?.color = UIColor(white: 1, alpha: 0.5)
    
    let planetLightNodeRight = SCNNode()
    planetLightNodeRight.position = SCNVector3(-6, 0, 0)
    planetLightNodeRight.light = SCNLight()
    planetLightNodeRight.light?.type = SCNLight.LightType.omni
    planetLightNodeRight.light?.color = UIColor(white: 1, alpha: 0.5)

    sunNode.addChildNode(planetLightNodeLeft)
    sunNode.addChildNode(planetLightNodeRight)
    
    return sunNode
  }
  
  private static func createMoon() -> SCNNode {
    
    let planetGeometry = SCNSphere(radius: 1)
    planetGeometry.segmentCount = 100
    
    let planetMaterial = SCNMaterial()
    planetMaterial.diffuse.contents = UIImage(named: "2k_moon")
    planetGeometry.materials = [planetMaterial]
    
    let moonNode = SCNNode(geometry: planetGeometry)
    moonNode.position = SCNVector3(0, 0, 8)
    moonNode.rotation = SCNVector4(0, 0.8, 0.1, Double.pi)
    
    return moonNode
  }
  
  private static func createEarth() -> SCNNode {
    
    let planetGeometry = SCNSphere(radius: 4)
    planetGeometry.segmentCount = 100
    
    let planetMaterial = SCNMaterial()
    planetMaterial.diffuse.contents = UIImage(named: "2k_earth_daymap")
    planetGeometry.materials = [planetMaterial]
    
    let earthNode = SCNNode(geometry: planetGeometry)
    earthNode.position = SCNVector3(0, 0, 0)
    
    return earthNode
  }
}

#Preview {
  ContentView()
}
