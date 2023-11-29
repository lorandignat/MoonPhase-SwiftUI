//
//  ViewSelectorSlider.swift
//  MoonPhase
//
//  Created by Lorand Ignat on 28.11.2023.
//

import SwiftUI

enum AnimationPhase: CaseIterable {
  case start, middle, end
}
struct ViewSelectorSlider: View {
  
  @State private var valueSelected = 0
  @State private var dragging = false
  
  @State private var lastTap: Date?
  
  var onValueChanged: (_ valueSelected: Int) -> ()
  
  var body: some View {
    GeometryReader { geometry in
      background(for: geometry)
      selectionCircle(for: geometry)
      icons(for: geometry)
    }
  }
  
  func selectionCircle(for geometry: GeometryProxy) -> some View {
    
    let position =
    valueSelected == 0 ? (CGFloat(valueSelected) * geometry.size.width / 2 + 20) :
    valueSelected == 1 ? (CGFloat(valueSelected) * geometry.size.width / 2) :
    (geometry.size.width - 20)
    
    return Circle()
      .fill(.white.opacity(0.5))
      .frame(width: 36, height: 36)
      .padding(EdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2))
      .position(CGPoint(x: position, y: 20))
      .gesture(
        DragGesture()
          .onEnded { (value) in
            withAnimation(.easeInOut(duration: 1).delay(5)) {
              dragging = false
            }
          }
          .onChanged { (value) in
            withAnimation(.easeInOut(duration: 0.5)) {
              lastTap = Date()
              dragging = true
            }
            
            if value.location.x <= geometry.size.width / 3 - 20 {
              if valueSelected != 0 {
                withAnimation {
                  valueSelected = 0
                }
                self.onValueChanged(0)
              }
            } else if value.location.x <= geometry.size.width / 3 * 2 + 20 {
              if valueSelected != 1 {
                withAnimation {
                  valueSelected = 1
                }
                self.onValueChanged(1)
              }
            } else {
              if valueSelected != 2 {
                withAnimation {
                  valueSelected = 2
                }
                self.onValueChanged(2)
              }
            }
          }
      )
  }
  
  func background(for geometry: GeometryProxy) -> some View {
    return Capsule(style: .continuous)
      .fill(Color(red: 0.8, green: 0.8, blue: 0.9).opacity(dragging ? 0.3 : 0.03))
      .frame(height: 40)
      .shadow(radius: 10)
      .gesture(
        SpatialTapGesture()
          .onEnded { value in
            if let lastTap, lastTap.timeIntervalSinceNow > -5 {
              if value.location.x <= geometry.size.width / 3 - 20 {
                if valueSelected != 0 {
                  withAnimation {
                    valueSelected = 0
                  }
                  self.onValueChanged(0)
                }
              } else if value.location.x <= geometry.size.width / 3 * 2 + 20 {
                if valueSelected != 1 {
                  withAnimation {
                    valueSelected = 1
                  }
                  self.onValueChanged(1)
                }
              } else {
                if valueSelected != 2 {
                  withAnimation {
                    valueSelected = 2
                  }
                  self.onValueChanged(2)
                }
              }
            }
            withAnimation(.easeInOut(duration: 0.5)) {
              self.lastTap = Date()
              dragging = true
            }
            withAnimation(.easeInOut(duration: 1).delay(5)) {
              dragging = false
            }
          }
      )
  }
  
  func icons(for geometry: GeometryProxy) -> some View {
    return HStack {
      Image(systemName: "bubble.circle")
        .resizable()
        .frame(width: 32, height: 32)
        .padding(EdgeInsets(top: 4, leading: 4, bottom: 4, trailing: 4))
        .foregroundStyle(valueSelected == 0 ? .black : .gray)
        .opacity(valueSelected == 0 ? 0.5 : 0.2)
      Spacer()
      Image(systemName: "moon.circle")
        .resizable()
        .frame(width: 32, height: 32)
        .foregroundStyle(valueSelected == 1 ? .black : .gray)
        .opacity(valueSelected == 1 ? 0.5 : 0.2)
      Spacer()
      Image(systemName: "sun.horizon.circle")
        .resizable()
        .frame(width: 32, height: 32)
        .padding(EdgeInsets(top: 4, leading: 4, bottom: 4, trailing: 4))
        .foregroundStyle(valueSelected == 2 ? .black : .gray)
        .opacity(valueSelected == 2 ? 0.5 : 0.2)
    }
  }
}

#Preview {
  ViewSelectorSlider { _ in
  }
}
