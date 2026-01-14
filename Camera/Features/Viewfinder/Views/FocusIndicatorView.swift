//
//  FocusIndicatorView.swift
//  Camera
//
//  A visual indicator that appears when the user taps to focus.
//  Design: Square with Signal Orange (#FF9500) border.
//

import SwiftUI

struct FocusIndicatorView: View {

  // MARK: - Properties

  /// The position of the indicator in the parent view's coordinate space
  let position: CGPoint

  /// Callback when the animation completes and view should be removed
  var onAnimationComplete: () -> Void

  @State private var opacity: Double = 1.0
  @State private var scale: CGFloat = 1.2

  // MARK: - Constants

  private let indicatorSize: CGFloat = 70
  private let strokeWidth: CGFloat = 1.0
  // "Signal Orange"
  private let indicatorColor = Color(red: 1.0, green: 0.584, blue: 0.0)

  // MARK: - Body

  var body: some View {
    Rectangle()
      .strokeBorder(indicatorColor, lineWidth: strokeWidth)
      .frame(width: indicatorSize, height: indicatorSize)
      .position(position)
      .opacity(opacity)
      .scaleEffect(scale)
      .onAppear {
        animate()
      }
      .allowsHitTesting(false)  // Pass touches through
  }

  // MARK: - Animation

  private func animate() {
    // 1. Initial scale down effect (pulse)
    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
      scale = 1.0
    }

    // 2. Fade out after delay
    withAnimation(.easeOut(duration: 0.3).delay(1.0)) {
      opacity = 0.0
    }

    // 3. Notify completion
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
      onAnimationComplete()
    }
  }
}

#Preview {
  ZStack {
    Color.black.ignoresSafeArea()
    FocusIndicatorView(position: CGPoint(x: 200, y: 300)) {}
  }
}
