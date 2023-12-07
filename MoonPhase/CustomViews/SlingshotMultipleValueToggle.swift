//
//  SlingshotSelector.swift
//  MoonPhase
//
//  Created by Lorand Ignat on 06.12.2023.
//

import SwiftUI

struct SlingshotMultipleValueToggle: View {
  
  @Binding var selectedValue: UInt
  
  var backgroundColor: Color = Color(red: 0.8, green: 0.8, blue: 0.9).opacity(0.3)
  var backgrondShadowRadius: CGFloat = 10
  
  var icons: [Image] = [Image(systemName: "1.circle"), Image(systemName: "2.circle"), Image(systemName: "3.circle")]
  var iconSelectedColor: Color = .black.opacity(0.5)
  var iconDefaultColor: Color = .black.opacity(0.3)
  
  var selectionFillColor: Color = .white.opacity(0.5)
  
  @State private var dragDistance: CGFloat = 0.0
  @State private var animationStart: Date = Date()
  @State private var animatedValue: UInt = 0
  private let iconSizeDifference = 4.0
  
  var body: some View {
    GeometryReader { geometry in
      GeometryReader { geometry in
        Capsule(style: .continuous)
          .fill(backgroundColor)
          .shadow(radius: backgrondShadowRadius)
        selectionCircle(for: geometry)
          .clipShape(Capsule(style: .continuous))
        icons(for: geometry)
      }
      .onChange(of: selectedValue) {
        withAnimation(.easeInOut(duration: 0.2)) {
          animatedValue = selectedValue
        }
      }
      .frame(minWidth: geometry.size.height * CGFloat((icons.count * 3 / 2)), minHeight: 30)
      .position(x: geometry.size.width / 2,
                y: geometry.size.height / 2)
    }
  }
  
  @ViewBuilder
  func selectionCircle(for geometry: GeometryProxy) -> some View {
    if icons.count <= 1 {
      EmptyView()
    } else {
      GeometryReader { geometry in
        
        let fullWidth = geometry.size.width * (1 + 1 / (CGFloat(icons.count) - 1))
        let iconWidth = fullWidth / CGFloat(icons.count)
        let iconPlacementOffset = iconWidth * CGFloat(animatedValue)
        
        SlingshotSliderCircle(slingshotDistance: dragDistance)
          .fill(selectionFillColor)
          .frame(width: iconWidth, height: geometry.size.height)
          .position(x: iconPlacementOffset, y: geometry.size.height / 2)
          .blur(radius: 1.0)
          .gesture(
            DragGesture()
              .onEnded { (value) in
                withAnimation {
                  dragDistance = 0.0
                }
              }
              .onChanged { (value) in
                var dragDistanceCalculation = (value.location.x - iconPlacementOffset) / iconWidth * 2
                
                if selectedValue == 0 && dragDistanceCalculation < 0 {
                  dragDistanceCalculation = 0
                }
                if selectedValue == icons.count - 1 && dragDistanceCalculation > 0 {
                  dragDistanceCalculation = 0
                }
                
                withAnimation {
                  dragDistance = dragDistanceCalculation
                }
                
                if dragDistanceCalculation > 1 {
                  selectedValue += 1
                } else if dragDistanceCalculation < -1 {
                  selectedValue -= 1
                }
              }
          )
      }
      .frame(width: geometry.size.width - geometry.size.height, height: geometry.size.height)
      .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
    }
  }
  
  @ViewBuilder
  private func icons(for geometry: GeometryProxy) -> some View {
    if icons.count <= 1 {
      EmptyView()
    } else {
      GeometryReader { geometry in
        ForEach((0..<icons.count), id: \.self) {
          let iconIndex = $0
          let fullWidth = geometry.size.width * (1 + 1 / (CGFloat(icons.count) - 1))
          let iconWidth = fullWidth / CGFloat(icons.count)
          let iconPlacementOffset = iconWidth * CGFloat(iconIndex)
          icons[iconIndex]
            .resizable()
            .frame(width: geometry.size.height - iconSizeDifference * 2, height: geometry.size.height - iconSizeDifference * 2)
            .position(x: iconPlacementOffset, y: geometry.size.height / 2)
            .foregroundStyle(animatedValue == iconIndex ? iconSelectedColor : iconDefaultColor)
            .allowsHitTesting(animatedValue != iconIndex)
            .onTapGesture {
              selectedValue = UInt(iconIndex)
            }
        }
      }
      .frame(width: geometry.size.width - geometry.size.height, height: geometry.size.height)
      .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
    }
  }
}

private struct SlingshotSliderCircle: Shape {
  
  private let circleSizeDifference = 2.0
  
  var slingshotDistance = 0.0
  var animatableData: Double {
    get {
      slingshotDistance
    }
    set {
      slingshotDistance = newValue
    }
  }
  
  func path(in rect: CGRect) -> Path {
    
    let width = rect.size.width
    let height = rect.size.height
    
    let point1 = CGPoint(x: width / 2, y: circleSizeDifference)
    
    let point2 = CGPoint(x: (width - height) / 2 + circleSizeDifference + (slingshotDistance < 0 ? (slingshotDistance > -1 ? slingshotDistance * height : -height) : 0), y: height / 2)
    let pointControl1 = CGPoint(x: (width - height) / 2 + circleSizeDifference, y: circleSizeDifference)
    
    let point3 = CGPoint(x: width / 2, y: height - circleSizeDifference)
    let pointControl2 = CGPoint(x: (width - height) / 2 + circleSizeDifference, y: height - circleSizeDifference)
    
    let point4 = CGPoint(x: (width + height) / 2 - circleSizeDifference +  (slingshotDistance > 0 ? (slingshotDistance < 1 ? slingshotDistance * height : height) : 0), y: height / 2)
    let pointControl3 = CGPoint(x: (width + height) / 2 - circleSizeDifference, y: height - circleSizeDifference)
    
    let pointControl4 = CGPoint(x: (width + height) / 2 - circleSizeDifference, y: circleSizeDifference)
    
    return Path { path in
      path.move(to: point1)
      path.addQuadCurve(to: point2, control: pointControl1)
      path.addQuadCurve(to: point3, control: pointControl2)
      path.addQuadCurve(to: point4, control: pointControl3)
      path.addQuadCurve(to: point1, control: pointControl4)
      path.closeSubpath()
    }
  }
}

struct SlingshotMultipleValueTogglePreview: View {
  @State private var value: UInt = 0
  var body: some View {
    SlingshotMultipleValueToggle(selectedValue: $value)
  }
}

#Preview {
  VStack {
    SlingshotMultipleValueTogglePreview()
      .frame(width: 300, height: 40)
  }
}
