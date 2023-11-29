//
//  PlanetSceneView.swift
//  MoonPhase
//
//  Created by Lorand Ignat on 27.11.2023.
//

import SwiftUI
import SceneKit

struct PlanetSceneView : UIViewRepresentable {
  
  weak var scene: SolarSystemCameraScene?
  
  func makeUIView(context: Context) -> SCNView {
    let scnView = SCNView()
    return scnView
  }
  
  func updateUIView(_ scnView: SCNView, context: Context) {
    scnView.scene = scene
    scnView.backgroundColor = UIColor.clear
  }
}

#Preview {
  let planetScene = SolarSystemPlanetScene()
  return PlanetSceneView(scene: planetScene)
}
