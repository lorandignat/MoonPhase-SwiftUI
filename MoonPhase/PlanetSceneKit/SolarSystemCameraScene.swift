//
//  SolarSystemCameraScene.swift
//  MoonPhase
//
//  Created by Lorand Ignat on 29.11.2023.
//

import SceneKit

// Note: Barebone camera movement and rotations with physics in mind. No planets.
class SolarSystemCameraScene: SCNScene {
  
  var earthRotationAroundSun = 0.0
  var moonRotationAroundEarth = 0.0
  var earthRotationAroundAxis = 0.0
  var sunRotationAroundAxis = 0.0
  
  var date: Date
  var moonDetails: Moon
  var initialMoonAge: Double
  
  private let cameraNode: SCNNode
  
  override init() {
    
    cameraNode = SCNNode()
    cameraNode.camera = SCNCamera()
    cameraNode.camera?.zFar = 300
    cameraNode.camera?.zNear = 0.1
    cameraNode.camera?.focalLength = 30
    cameraNode.position = SCNVector3(0, 0, 0)
    
    date = Date()
    moonDetails = Moon(date)
    initialMoonAge = moonDetails.info.age
    
    super.init()
    
    rootNode.position = SCNVector3(0, 0, 0)
    rootNode.addChildNode(cameraNode)
    
    background.contents = backgroundImage()
    
    movePlanetsInSolarSystem()
    moveCameraToMoonView()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func backgroundImage() -> UIImage? {
    UIImage(named: "8k_stars_milky_way")
  }
  
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
    earthRotationAroundAxis = hour / 24 * 2 * Double.pi - moonRotationAroundEarth
    sunRotationAroundAxis = -earthRotationAroundSun
  }
  
  func moveCameraToMoonView(animated: Bool = false, centered: Bool = false) {
    
    var transform = SCNMatrix4Mult( SCNMatrix4MakeRotation(Float(earthRotationAroundSun), 0, 1, 0), SCNMatrix4Identity)
    transform = SCNMatrix4Mult( SCNMatrix4MakeTranslation(0, 0, -42), transform)
    transform = SCNMatrix4Mult( SCNMatrix4MakeRotation(Float(moonRotationAroundEarth) + Float.pi, 0, 1, 0), transform)
    transform = SCNMatrix4Mult( SCNMatrix4MakeTranslation(0, centered ? -0.5 : -1, 0), transform)
    
    if animated {
      let animation = CABasicAnimation(keyPath: "transform")
      animation.fromValue = cameraNode.transform
      animation.toValue = transform
      animation.duration = centered ? 1.0 : 0.5
      animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
      cameraNode.addAnimation(animation, forKey: nil)
    }
    
    cameraNode.transform = transform
  }
  
  func moveCameraToFullView(animated: Bool = false) {
    
    var transform = SCNMatrix4Mult( SCNMatrix4MakeRotation(Float(earthRotationAroundSun), 0, 1, 0), SCNMatrix4Identity)
    transform = SCNMatrix4Mult( SCNMatrix4MakeTranslation(0, 70, -34), transform)
    transform = SCNMatrix4Mult( SCNMatrix4MakeRotation(-Float.pi / 2, 1, 0, 0), transform)
    
    if animated {
      let animation = CABasicAnimation(keyPath: "transform")
      animation.fromValue = cameraNode.transform
      animation.toValue = transform
      animation.duration = 1
      animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
      cameraNode.addAnimation(animation, forKey: nil)
    }
    
    cameraNode.transform = transform
  }
}
