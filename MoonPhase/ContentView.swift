//
//  ContentView.swift
//  TrialAnimation
//
//  Created by Lorand Ignat on 13.11.2023.
//

import SwiftUI
import SceneKit
import SlingshotMultipleValueToggle

struct ContentView: View {
  
  private let scene = SolarSystemPlanetScene()
  private let backgroundScene = SolarSystemCameraScene()
  
  @State private var viewType: UInt = 0
  @State private var animateGradient = false
  @State private var animateViewChange = false
  
  @State private var days = 0.0
  
  var body: some View {
    
    ZStack {
      Color.black
        .ignoresSafeArea()
      
      PlanetSceneView(scene: backgroundScene)
        .opacity(animateViewChange ? 1 : 0.5)
        .ignoresSafeArea()
      
      VStack {
        if animateViewChange {
          Spacer()
        }
        LinearGradient(colors: [animateViewChange ? .clear : .clear, .gradient3, .gradient2, .gradient1],
                       startPoint: animateGradient ?  UnitPoint(x: 0.0, y: 0.1) : UnitPoint(x: 0.1, y: 0.1),
                       endPoint: animateGradient ? UnitPoint(x: 0, y: 0.3) : UnitPoint(x: 0, y: 0.7))
        .onAppear {
          withAnimation(.easeInOut(duration: 10.0).repeatForever(autoreverses: true)) {
            animateGradient.toggle()
          }
        }
        .frame(maxHeight: animateViewChange ? 200 : .infinity)
      }
      .ignoresSafeArea()
      
      PlanetSceneView(scene: scene)
        .ignoresSafeArea()
      
      GeometryReader { geometry in
        VStack {
          Spacer().frame(alignment: .bottom)
          ZStack {
            Color(.gradient1)
              .background(.ultraThinMaterial)
              .cornerRadius(15)
              .frame(maxHeight: animateViewChange ? 200 : geometry.size.height / 5 * 2, alignment: .bottom)
              .shadow(radius: 5)
              .opacity(animateViewChange ? 0.7 : 1)
            detailView
              .colorMultiply(.teal)
              .saturation(0.3)
              .frame(maxHeight: animateViewChange ? 200 : geometry.size.height / 5 * 2, alignment: .bottom)
          }
          .shadow(radius: 10)
        }
      }.ignoresSafeArea()
    }
    .onChange(of: days) { _, newValue in
      backgroundScene.movePlanetsInSolarSystem(addedTime: newValue, animated: false)
      scene.movePlanetsInSolarSystem(addedTime: newValue, animated: false)
      moveCamera(for: viewType, animated: false)
    }
    .onChange(of: viewType) { _, newValue in
      moveCamera(for: newValue, animated: true)
    }
  }
  
  var detailView: some View {
    VStack {
      Spacer().frame(alignment: .bottom)
      let layout = !animateViewChange ? AnyLayout(VStackLayout()) : AnyLayout(HStackLayout())
      layout {
        Text(scene.displayingDate(), style: .date)
          .font(animateViewChange ? .callout : .title2)
          .foregroundStyle(.white)
        Text(scene.displayingDate(), style: .time)
          .font(animateViewChange ? .callout : .title2)
          .foregroundStyle(.white)
      }
      
      if !animateViewChange {
        Spacer().frame(alignment: .bottom)
      }
      VStack {
        if !animateViewChange {
          HStack {
            Text("Moon phase:")
              .foregroundStyle(.white)
            Text("\(scene.moonPhase())")
              .animation(.none)
              .foregroundStyle(.white)
          }
          Spacer().frame(alignment: .bottom)
          HStack {
            Text("Illumination percentage:")
              .foregroundStyle(.white)
            Text("\(scene.moonIllumination(), specifier: "%.2f") %")
              .animation(.none)
              .foregroundStyle(.white)
          }
        }
      }
      if !animateViewChange {
        Spacer().frame(alignment: .bottom)
      }
      VStack {
        Slider(value: $days, in: -29.53059...29.53059)
          .padding(EdgeInsets(top: 10, leading: 70, bottom: 10, trailing: 70))
          .tint(.gray.opacity(0.4))
          .opacity(/*@START_MENU_TOKEN@*/0.8/*@END_MENU_TOKEN@*/)
        
        SlingshotMultipleValueToggle(selectedValue: $viewType,
                        icons: [
                          Image(systemName: "bubble.circle"),
                          Image(systemName: "moon.circle"),
                          Image(systemName: "sun.horizon.circle")])
        .frame(width: 270, height: 40)
        .onChange(of: viewType) {
          withAnimation {
            animateViewChange = viewType != 0
          }
        }
      }
      .padding(EdgeInsets(top: 0, leading: 0, bottom: 50, trailing: 0))
    }
  }
  
  func moveCamera(for viewType: UInt, animated: Bool) {
    if viewType == 0 {
      backgroundScene.moveCameraToMoonView(animated: animated, centered: false)
      scene.moveCameraToMoonView(animated: animated, centered: false)
    }
    if viewType == 1 {
      backgroundScene.moveCameraToMoonView(animated: animated, centered: true)
      scene.moveCameraToMoonView(animated: animated, centered: true)
    }
    if viewType == 2 {
      backgroundScene.moveCameraToFullView(animated: animated)
      scene.moveCameraToFullView(animated: animated)
    }
  }
}

#Preview {
  ContentView()
}
