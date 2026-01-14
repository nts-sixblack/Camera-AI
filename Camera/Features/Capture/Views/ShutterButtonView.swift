//
//  ShutterButtonView.swift
//  Camera
//
//  A circular shutter button with haptic feedback.
//

import SwiftUI

struct ShutterButtonView: View {
  var action: () -> Void

  var body: some View {
    Button(action: {
      let generator = UIImpactFeedbackGenerator(style: .medium)
      generator.impactOccurred()
      action()
    }) {
      ZStack {
        Circle()
          .stroke(Color.white, lineWidth: 4)
          .frame(width: 72, height: 72)

        Circle()
          .fill(Color.white)
          .frame(width: 60, height: 60)
      }
    }
    .buttonStyle(PlainButtonStyle())  // Avoid default opacity effect if undesired, or custom style
  }
}

#Preview {
  ZStack {
    Color.black.edgesIgnoringSafeArea(.all)
    ShutterButtonView(action: {})
  }
}
