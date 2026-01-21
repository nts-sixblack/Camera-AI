//
//  ISODialView.swift
//  Camera
//
//  ISO dial control with vertical swipe gesture for adjusting ISO sensitivity.
//  Implements 1/3-stop ISO values with haptic feedback on value changes.
//

import Combine
import SwiftUI
import UIKit

/// Standard 1/3-stop ISO values used in photography
/// These follow the ISO standard for camera sensitivity increments
enum ISOStops {
  /// Full ISO sequence at 1/3-stop intervals
  static let values: [Float] = [
    32, 40, 50, 64, 80, 100,
    125, 160, 200, 250, 320, 400,
    500, 640, 800, 1000, 1250, 1600,
    2000, 2500, 3200, 4000, 5000, 6400,
    8000, 10000, 12800, 16000, 20000, 25600,
    32000, 40000, 51200,
  ]

  /// Finds the nearest standard ISO value to a given value
  /// - Parameters:
  ///   - value: The ISO value to match
  ///   - minISO: Minimum allowed ISO (device limit)
  ///   - maxISO: Maximum allowed ISO (device limit)
  /// - Returns: The nearest standard ISO value within bounds
  static func nearest(to value: Float, minISO: Float, maxISO: Float) -> Float {
    let validValues = values.filter { $0 >= minISO && $0 <= maxISO }
    guard !validValues.isEmpty else { return max(minISO, min(value, maxISO)) }

    return validValues.min(by: { abs($0 - value) < abs($1 - value) }) ?? value
  }

  /// Gets the next higher ISO stop (swiping up)
  /// - Parameters:
  ///   - current: Current ISO value
  ///   - maxISO: Maximum allowed ISO
  /// - Returns: Next higher ISO stop or nil if at max
  static func higher(than current: Float, maxISO: Float) -> Float? {
    let validValues = values.filter { $0 <= maxISO }
    return validValues.first(where: { $0 > current })
  }

  /// Gets the next lower ISO stop (swiping down)
  /// - Parameters:
  ///   - current: Current ISO value
  ///   - minISO: Minimum allowed ISO
  /// - Returns: Next lower ISO stop or nil if at min
  static func lower(than current: Float, minISO: Float) -> Float? {
    let validValues = values.filter { $0 >= minISO }
    return validValues.last(where: { $0 < current })
  }

  /// Gets the index of an ISO value in the valid range
  /// - Parameters:
  ///   - value: The ISO value to find
  ///   - minISO: Minimum allowed ISO
  ///   - maxISO: Maximum allowed ISO
  /// - Returns: Index in the filtered array, or nil if not found
  static func index(of value: Float, minISO: Float, maxISO: Float) -> Int? {
    let validValues = values.filter { $0 >= minISO && $0 <= maxISO }
    return validValues.firstIndex(where: { abs($0 - value) < 1 })
  }
}

/// ViewModel for ISO Dial control
class ISODialViewModel: ObservableObject {
  @Published var currentISO: Float = 100.0
  let minISO: Float
  let maxISO: Float

  /// Callback when ISO value changes
  var onISOChanged: ((Float) -> Void)?

  /// Haptic feedback generators
  private let selectionFeedback = UISelectionFeedbackGenerator()
  private let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)

  /// Gesture state tracking
  private var lastISO: Float = 100.0
  private var accumulatedDelta: CGFloat = 0
  private let deltaThreshold: CGFloat = 40  // pixels needed to change one stop

  init(currentISO: Float, minISO: Float, maxISO: Float) {
    self.currentISO = currentISO
    self.minISO = minISO
    self.maxISO = maxISO
    self.lastISO = currentISO

    // Prepare haptic generators
    selectionFeedback.prepare()
    impactFeedback.prepare()
  }

  /// Called when drag gesture starts
  func onDragStart() {
    lastISO = currentISO
    accumulatedDelta = 0
    selectionFeedback.prepare()
  }

  /// Process drag gesture change
  /// - Parameter translation: Vertical translation from gesture (negative = up = higher ISO)
  func onDragChange(translation: CGFloat) {
    // Invert: swiping up (negative translation) should increase ISO
    let delta = -translation - accumulatedDelta

    if abs(delta) >= deltaThreshold {
      let stepsToChange = Int(delta / deltaThreshold)
      accumulatedDelta += CGFloat(stepsToChange) * deltaThreshold

      var newISO = currentISO

      for _ in 0..<abs(stepsToChange) {
        if stepsToChange > 0 {
          // Trying to increase ISO
          if let higher = ISOStops.higher(than: newISO, maxISO: maxISO) {
            newISO = higher
            triggerStepFeedback()
          } else {
            // At max bound
            triggerBoundFeedback()
            break
          }
        } else {
          // Trying to decrease ISO
          if let lower = ISOStops.lower(than: newISO, minISO: minISO) {
            newISO = lower
            triggerStepFeedback()
          } else {
            // At min bound
            triggerBoundFeedback()
            break
          }
        }
      }

      if newISO != currentISO {
        currentISO = newISO
        onISOChanged?(newISO)
      }
    }
  }

  /// Called when drag gesture ends
  func onDragEnd() {
    // Ensure we're at a valid stop
    let snappedISO = ISOStops.nearest(to: currentISO, minISO: minISO, maxISO: maxISO)
    if snappedISO != currentISO {
      currentISO = snappedISO
      onISOChanged?(snappedISO)
    }
  }

  /// Updates the ISO value from external source (e.g., camera)
  func updateISO(_ iso: Float) {
    let snapped = ISOStops.nearest(to: iso, minISO: minISO, maxISO: maxISO)
    if snapped != currentISO {
      currentISO = snapped
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

/// ISO Dial View with vertical swipe gesture
struct ISODialView: View {
  @ObservedObject var viewModel: ISODialViewModel

  // State to track if drag has started this gesture
  @State private var isDragging = false

  var body: some View {
    VStack(spacing: 8) {
      // ISO Value Display
      Text(formattedISO)
        .font(.system(size: 48, weight: .bold, design: .monospaced))
        .foregroundStyle(.white)

      Text("ISO")
        .font(.caption)
        .foregroundStyle(.white.opacity(0.6))

      // Visual dial indicator
      DialIndicator(
        currentValue: viewModel.currentISO,
        minValue: viewModel.minISO,
        maxValue: viewModel.maxISO
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

  /// Formats ISO value for display (removes decimal for clean values)
  private var formattedISO: String {
    let iso = viewModel.currentISO
    if iso >= 1000 {
      // Format large values without decimals
      return String(format: "%.0f", iso)
    } else {
      return String(format: "%.0f", iso)
    }
  }
}

/// Visual indicator showing position in ISO range
struct DialIndicator: View {
  let currentValue: Float
  let minValue: Float
  let maxValue: Float

  private var progress: Double {
    guard maxValue > minValue else { return 0 }
    let logMin = log(Double(max(minValue, 1)))
    let logMax = log(Double(maxValue))
    let logCurrent = log(Double(currentValue))
    return (logCurrent - logMin) / (logMax - logMin)
  }

  var body: some View {
    GeometryReader { geometry in
      ZStack(alignment: .leading) {
        // Background track
        RoundedRectangle(cornerRadius: 4)
          .fill(Color.white.opacity(0.2))
          .frame(height: 4)

        // Filled portion
        RoundedRectangle(cornerRadius: 4)
          .fill(Color.yellow)
          .frame(width: geometry.size.width * CGFloat(progress), height: 4)

        // Position indicator
        Circle()
          .fill(Color.yellow)
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

    ISODialView(
      viewModel: ISODialViewModel(
        currentISO: 400,
        minISO: 32,
        maxISO: 12800
      )
    )
    .padding()
  }
}
