//
//  SolarSystemPlanetScene.swift
//  MoonPhase
//
//  Created by Lorand Ignat on 29.11.2023.
//

import SceneKit

// Note: Extension for the camera movement to include planets.
class SolarSystemPlanetScene: SolarSystemCameraScene {
  
  private let solarSystem: SCNNode
  private let earthSystem: SCNNode
  private let sunNode: SCNNode
  private let earthNode: SCNNode
  private let moonNode: SCNNode
  
  override init() {
    
    sunNode = Self.createSun()
    earthNode = Self.createEarth()
    moonNode = Self.createMoon()
    
    earthSystem = SCNNode()
    earthSystem.position = SCNVector3(0, 0, -42)
    
    solarSystem = SCNNode()
    solarSystem.position = SCNVector3(0, 0, 0)

    earthSystem.addChildNode(earthNode)
    earthSystem.addChildNode(moonNode)
    
    solarSystem.addChildNode(sunNode)
    solarSystem.addChildNode(earthSystem)
    
    super.init()
    
    rootNode.addChildNode(solarSystem)
    movePlanetsInSolarSystem()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func backgroundImage() -> UIImage? {
    nil
  }
  
  func displayingDate() -> Date {
    date
  }
  
  func moonIllumination() -> Double {
    var moonAge = moonDetails.info.age / (29.53059 / 2)
    if moonAge > 1 {
      moonAge = 2 - moonAge
    }
    return moonAge * 100
  }
  
  func moonPhase() -> String {
    return moonDetails.info.phase.rawValue
  }

  override func movePlanetsInSolarSystem(addedTime: Double = 0.0, animated: Bool = false) {

    super.movePlanetsInSolarSystem(addedTime: addedTime, animated: animated)
    
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

    let earthRotationVector = SCNVector4(0, 1, 0, -0.22 + Double.pi + earthRotationAroundAxis)
    if animated {
      let animation = CABasicAnimation(keyPath: "rotation")
      animation.fromValue = earthNode.rotation
      animation.toValue = earthRotationVector
      animation.duration = 1
      animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
      earthNode.addAnimation(animation, forKey: nil)
    }
    earthNode.rotation = earthRotationVector
    
    let sunRotationVector = SCNVector4(0, 1, 0, sunRotationAroundAxis)
    if animated {
      let animation = CABasicAnimation(keyPath: "rotation")
      animation.fromValue = sunNode.rotation
      animation.toValue = sunRotationAroundAxis
      animation.duration = 1
      animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
      sunNode.addAnimation(animation, forKey: nil)
    }
    sunNode.rotation = sunRotationVector
  }
  
  override func moveCameraToMoonView(animated: Bool = false, centered: Bool = false) {
    
    super.moveCameraToMoonView(animated: animated, centered: centered)
    
    if animated {
      // Note: hide sun mid animation, while camera is pointing away
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
        self.sunNode.opacity = 0.0
      }
    } else {
      sunNode.opacity = 0.0
    }
  }
  
  override func moveCameraToFullView(animated: Bool = false) {
    
    super.moveCameraToFullView(animated: animated)
    
    if animated {
      // Note: show sun mid animation, while camera is pointing away
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
        self.sunNode.opacity = 1
      }
    } else {
      sunNode.opacity = 1
    }
  }
  
  private static func createSun() -> SCNNode {
    
    let planetGeometry = SCNSphere(radius: 24)
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
