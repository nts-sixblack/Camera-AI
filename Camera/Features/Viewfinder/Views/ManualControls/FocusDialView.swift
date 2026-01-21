//
//  FocusDialView.swift
//  Camera
//
//  Focus dial control with vertical swipe gesture for adjusting manual focus.
//  Uses continuous lens position (0.0-1.0) with haptic feedback at regular intervals.
//

import Combine
import SwiftUI
import UIKit

// MARK: - Focus Distance Display Helper

/// Maps lensPosition (0.0-1.0) to approximate distance display strings
enum FocusDistance {
  /// Converts lens position to approximate distance string
  /// - Parameter lensPosition: The lens position from 0.0 (near) to 1.0 (infinity)
  /// - Returns: Approximate distance string for display (e.g., "0.3m", "1m", "∞")
  static func displayString(from lensPosition: Float) -> String {
    switch lensPosition {
    case 0.0..<0.1: return "0.1m"
    case 0.1..<0.2: return "0.3m"
    case 0.2..<0.4: return "0.5m"
    case 0.4..<0.6: return "1m"
    case 0.6..<0.8: return "2m"
    case 0.8..<0.95: return "5m"
    default: return "∞"
    }
  }
}

// MARK: - FocusDialViewModel

/// ViewModel for Focus Dial control
class FocusDialViewModel: ObservableObject {
  @Published var currentLensPosition: Float = 0.5

  /// Callback when lens position changes
  var onLensPositionChanged: ((Float) -> Void)?

  /// Haptic feedback generators
  private let selectionFeedback = UISelectionFeedbackGenerator()
  private let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)

  /// Gesture state tracking
  private var lastLensPosition: Float = 0.5
  private var accumulatedDelta: CGFloat = 0

  /// Delta threshold in points for position change (smaller = smoother)
  private let deltaThreshold: CGFloat = 30

  /// Haptic interval - trigger haptic every 0.1 lens position change
  private let hapticInterval: Float = 0.1

  /// Position change per delta threshold crossing (L2 fix)
  private let positionChangePerStep: Float = 0.02

  init(currentLensPosition: Float) {
    // H2 fix: Clamp initial value to valid range
    self.currentLensPosition = max(0.0, min(currentLensPosition, 1.0))
    self.lastLensPosition = self.currentLensPosition

    // Prepare haptic generators
    selectionFeedback.prepare()
    impactFeedback.prepare()
  }

  /// Called when drag gesture starts
  func onDragStart() {
    lastLensPosition = currentLensPosition
    accumulatedDelta = 0
    selectionFeedback.prepare()
  }

  /// Process drag gesture change
  /// - Parameter translation: Vertical translation from gesture (negative = up = increase lens position)
  func onDragChange(translation: CGFloat) {
    // Invert: swiping up (negative translation) should increase lens position (toward infinity)
    let delta = -translation - accumulatedDelta

    if abs(delta) >= deltaThreshold {
      let steps = delta / deltaThreshold
      accumulatedDelta += steps * deltaThreshold

      // Calculate position change using named constant (L2 fix)
      let positionChange = Float(steps) * positionChangePerStep
      var newPosition = currentLensPosition + positionChange

      // Check bounds and trigger resistance haptic if at edges
      if newPosition <= 0.0 {
        if currentLensPosition > 0.0 {
          triggerBoundFeedback()
        }
        newPosition = 0.0
      } else if newPosition >= 1.0 {
        if currentLensPosition < 1.0 {
          triggerBoundFeedback()
        }
        newPosition = 1.0
      }

      // Update position and check for haptic interval
      if newPosition != currentLensPosition {
        let oldPosition = currentLensPosition
        currentLensPosition = newPosition
        onLensPositionChanged?(newPosition)

        // Trigger haptic if crossed haptic interval threshold
        let oldInterval = Int(oldPosition / hapticInterval)
        let newInterval = Int(newPosition / hapticInterval)
        if oldInterval != newInterval {
          triggerStepFeedback()
        }
      }
    }
  }

  /// Called when drag gesture ends
  func onDragEnd() {
    // No snapping needed for continuous focus - just ensure bounds
    let clampedPosition = max(0.0, min(currentLensPosition, 1.0))
    if clampedPosition != currentLensPosition {
      currentLensPosition = clampedPosition
      onLensPositionChanged?(clampedPosition)
    }
  }

  /// Updates the lens position from external source (e.g., camera)
  func updateLensPosition(_ lensPosition: Float) {
    let clamped = max(0.0, min(lensPosition, 1.0))
    if clamped != currentLensPosition {
      currentLensPosition = clamped
    }
  }

  // MARK: - Haptic Feedback

  private func triggerStepFeedback() {
    selectionFeedback.selectionChanged()
    selectionFeedback.prepare()
  }

  private func triggerBoundFeedback() {
    impactFeedback.impactOccurred()
    impactFeedback.prepare()
  }
}

// MARK: - FocusDialView

/// Focus Dial View with vertical swipe gesture
struct FocusDialView: View {
  @ObservedObject var viewModel: FocusDialViewModel

  // State to track if drag has started this gesture
  @State private var isDragging = false

  var body: some View {
    VStack(spacing: 8) {
      // Focus Distance Display
      Text(formattedDistance)
        .font(.system(size: 48, weight: .bold, design: .monospaced))
        .foregroundStyle(.white)

      Text("FOCUS")
        .font(.caption)
        .foregroundStyle(.white.opacity(0.6))

      // Visual dial indicator (linear for focus, unlike log-scale for ISO)
      FocusDialIndicator(
        currentValue: viewModel.currentLensPosition,
        minValue: 0.0,
        maxValue: 1.0
      )
      .frame(height: 30)
      .padding(.horizontal)

      // Hint text
      Text("Swipe ↑↓ to adjust")
        .font(.caption2)
        .foregroundStyle(.white.opacity(0.4))
    }
    .frame(maxWidth: .infinity)
    .padding(.vertical, 12)
    .gesture(
      DragGesture(minimumDistance: 1)
        .onChanged { value in
          if !isDragging {
            isDragging = true
            viewModel.onDragStart()
          }
          viewModel.onDragChange(translation: value.translation.height)
        }
        .onEnded { _ in
          viewModel.onDragEnd()
          isDragging = false
        }
    )
  }

  /// Formats lens position as distance display
  private var formattedDistance: String {
    FocusDistance.displayString(from: viewModel.currentLensPosition)
  }
}

// MARK: - FocusDialIndicator

/// Visual indicator showing position in focus range (linear, cyan colored)
struct FocusDialIndicator: View {
  let currentValue: Float
  let minValue: Float
  let maxValue: Float

  /// Linear progress (focus uses linear, not log scale like ISO/shutter)
  private var progress: Double {
    guard maxValue > minValue else { return 0 }
    return Double(currentValue - minValue) / Double(maxValue - minValue)
  }

  /// Cyan/teal color to differentiate from ISO (yellow) and shutter (also yellow)
  private let focusColor = Color(red: 0.3, green: 0.85, blue: 0.9)  // Cyan/teal

  var body: some View {
    GeometryReader { geometry in
      ZStack(alignment: .leading) {
        // Background track
        RoundedRectangle(cornerRadius: 4)
          .fill(Color.white.opacity(0.2))
          .frame(height: 4)

        // Filled portion
        RoundedRectangle(cornerRadius: 4)
          .fill(focusColor)
          .frame(width: geometry.size.width * CGFloat(progress), height: 4)

        // Position indicator
        Circle()
          .fill(focusColor)
          .frame(width: 12, height: 12)
          .offset(x: geometry.size.width * CGFloat(progress) - 6)
      }
      .frame(height: geometry.size.height)
    }
  }
}

// MARK: - Preview

#Preview {
  ZStack {
    Color.black.ignoresSafeArea()

    FocusDialView(
      viewModel: FocusDialViewModel(
        currentLensPosition: 0.5
      )
    )
    .padding()
  }
}
