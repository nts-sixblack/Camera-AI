//
//  ShutterSpeedDialView.swift
//  Camera
//
//  Shutter speed dial control with vertical swipe gesture for adjusting exposure duration.
//  Implements 1/3-stop shutter speed values with haptic feedback on value changes.
//

import Combine
import CoreMedia
import SwiftUI
import UIKit

/// Standard 1/3-stop shutter speed values used in photography
/// Represented as CMTime durations (seconds)
enum ShutterStops {
  /// Full shutter speed sequence at 1/3-stop intervals as (numerator, denominator) for CMTime
  /// Ordered from fastest (shortest duration) to slowest (longest duration)
  static let values: [(Int64, Int32)] = [
    // Ultra fast
    (1, 8000), (1, 6400), (1, 5000), (1, 4000), (1, 3200), (1, 2500),
    (1, 2000), (1, 1600), (1, 1250), (1, 1000),
    // Fast
    (1, 800), (1, 640), (1, 500), (1, 400), (1, 320), (1, 250),
    (1, 200), (1, 160), (1, 125), (1, 100),
    // Medium
    (1, 80), (1, 60), (1, 50), (1, 40), (1, 30), (1, 25),
    (1, 20), (1, 15), (1, 13), (1, 10),
    // Slow
    (1, 8), (1, 6), (1, 5), (1, 4),
    // Very slow (using higher timescale for precision)
    (3, 10), (4, 10), (5, 10), (6, 10), (8, 10), (1, 1),
  ]

  /// Converts tuple to CMTime
  private static func toTime(_ tuple: (Int64, Int32)) -> CMTime {
    return CMTime(value: tuple.0, timescale: tuple.1)
  }

  /// Get all values as CMTime array
  static var allTimes: [CMTime] {
    return values.map { toTime($0) }
  }

  /// Finds the nearest standard shutter speed to a given duration
  /// - Parameters:
  ///   - duration: The duration to match
  ///   - minDuration: Minimum allowed duration (fastest shutter, device limit)
  ///   - maxDuration: Maximum allowed duration (slowest shutter, device limit)
  /// - Returns: The nearest standard shutter speed within bounds
  static func nearest(to duration: CMTime, minDuration: CMTime, maxDuration: CMTime) -> CMTime {
    let targetSeconds = duration.seconds
    let minSeconds = minDuration.seconds
    let maxSeconds = maxDuration.seconds

    let validTimes = allTimes.filter { $0.seconds >= minSeconds && $0.seconds <= maxSeconds }
    guard !validTimes.isEmpty else {
      // Clamp to bounds if no valid stops
      return CMTime(
        seconds: max(minSeconds, min(targetSeconds, maxSeconds)), preferredTimescale: 1000)
    }

    return validTimes.min(by: { abs($0.seconds - targetSeconds) < abs($1.seconds - targetSeconds) })
      ?? duration
  }

  /// Gets the next faster shutter speed (shorter duration, swiping up)
  /// - Parameters:
  ///   - current: Current shutter speed
  ///   - minDuration: Minimum allowed duration (fastest shutter)
  /// - Returns: Next faster shutter speed or nil if at fastest
  static func faster(than current: CMTime, minDuration: CMTime) -> CMTime? {
    let currentSeconds = current.seconds
    let minSeconds = minDuration.seconds

    // Filter for valid stops and find the first one faster than current
    let validTimes = allTimes.filter { $0.seconds >= minSeconds }
    // Sort by duration descending to find the next smaller duration
    let sorted = validTimes.sorted { $0.seconds > $1.seconds }
    return sorted.first(where: { $0.seconds < currentSeconds })
  }

  /// Gets the next slower shutter speed (longer duration, swiping down)
  /// - Parameters:
  ///   - current: Current shutter speed
  ///   - maxDuration: Maximum allowed duration (slowest shutter)
  /// - Returns: Next slower shutter speed or nil if at slowest
  static func slower(than current: CMTime, maxDuration: CMTime) -> CMTime? {
    let currentSeconds = current.seconds
    let maxSeconds = maxDuration.seconds

    // Filter for valid stops and find the first one slower than current
    let validTimes = allTimes.filter { $0.seconds <= maxSeconds }
    // Sort by duration ascending to find the next larger duration
    let sorted = validTimes.sorted { $0.seconds < $1.seconds }
    return sorted.first(where: { $0.seconds > currentSeconds })
  }

  /// Gets the index of a shutter speed in the valid range
  /// - Parameters:
  ///   - duration: The duration to find
  ///   - minDuration: Minimum allowed duration
  ///   - maxDuration: Maximum allowed duration
  /// - Returns: Index in the filtered array, or nil if not found
  static func index(of duration: CMTime, minDuration: CMTime, maxDuration: CMTime) -> Int? {
    let targetSeconds = duration.seconds
    let minSeconds = minDuration.seconds
    let maxSeconds = maxDuration.seconds

    let validTimes = allTimes.filter { $0.seconds >= minSeconds && $0.seconds <= maxSeconds }
    return validTimes.firstIndex(where: { abs($0.seconds - targetSeconds) < 0.0001 })
  }
}

/// ViewModel for Shutter Speed Dial control
class ShutterSpeedDialViewModel: ObservableObject {
  @Published var currentDuration: CMTime
  let minDuration: CMTime
  let maxDuration: CMTime

  /// Callback when shutter speed changes
  var onShutterSpeedChanged: ((CMTime) -> Void)?

  /// Haptic feedback generators
  private let selectionFeedback = UISelectionFeedbackGenerator()
  private let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)

  /// Gesture state tracking
  private var lastDuration: CMTime
  private var accumulatedDelta: CGFloat = 0
  /// Pixels of vertical drag required to change one shutter stop.
  /// Matches ISODialView threshold for consistent gesture feel across all dials.
  private let deltaThreshold: CGFloat = 40

  init(currentDuration: CMTime, minDuration: CMTime, maxDuration: CMTime) {
    self.currentDuration = currentDuration
    self.minDuration = minDuration
    self.maxDuration = maxDuration
    self.lastDuration = currentDuration

    // Prepare haptic generators
    selectionFeedback.prepare()
    impactFeedback.prepare()
  }

  /// Called when drag gesture starts
  func onDragStart() {
    lastDuration = currentDuration
    accumulatedDelta = 0
    selectionFeedback.prepare()
  }

  /// Process drag gesture change
  /// - Parameter translation: Vertical translation from gesture (negative = up = faster shutter)
  func onDragChange(translation: CGFloat) {
    // Invert: swiping up (negative translation) should decrease duration (faster shutter)
    let delta = -translation - accumulatedDelta

    if abs(delta) >= deltaThreshold {
      let stepsToChange = Int(delta / deltaThreshold)
      accumulatedDelta += CGFloat(stepsToChange) * deltaThreshold

      var newDuration = currentDuration

      for _ in 0..<abs(stepsToChange) {
        if stepsToChange > 0 {
          // Trying to go faster (shorter duration)
          if let faster = ShutterStops.faster(than: newDuration, minDuration: minDuration) {
            newDuration = faster
            triggerStepFeedback()
          } else {
            // At fastest bound
            triggerBoundFeedback()
            break
          }
        } else {
          // Trying to go slower (longer duration)
          if let slower = ShutterStops.slower(than: newDuration, maxDuration: maxDuration) {
            newDuration = slower
            triggerStepFeedback()
          } else {
            // At slowest bound
            triggerBoundFeedback()
            break
          }
        }
      }

      if newDuration != currentDuration {
        currentDuration = newDuration
        onShutterSpeedChanged?(newDuration)
      }
    }
  }

  /// Called when drag gesture ends
  func onDragEnd() {
    // Ensure we're at a valid stop
    let snappedDuration = ShutterStops.nearest(
      to: currentDuration, minDuration: minDuration, maxDuration: maxDuration)
    if snappedDuration != currentDuration {
      currentDuration = snappedDuration
      onShutterSpeedChanged?(snappedDuration)
    }
  }

  /// Updates the shutter speed from external source (e.g., camera)
  func updateDuration(_ duration: CMTime) {
    let snapped = ShutterStops.nearest(
      to: duration, minDuration: minDuration, maxDuration: maxDuration)
    if snapped != currentDuration {
      currentDuration = snapped
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

/// Shutter Speed Dial View with vertical swipe gesture
struct ShutterSpeedDialView: View {
  @ObservedObject var viewModel: ShutterSpeedDialViewModel

  // State to track if drag has started this gesture
  @State private var isDragging = false

  var body: some View {
    VStack(spacing: 8) {
      // Shutter Speed Value Display
      Text(formattedShutterSpeed)
        .font(.system(size: 48, weight: .bold, design: .monospaced))
        .foregroundStyle(.white)

      Text("SHUTTER")
        .font(.caption)
        .foregroundStyle(.white.opacity(0.6))

      // Visual dial indicator
      ShutterDialIndicator(
        currentDuration: viewModel.currentDuration,
        minDuration: viewModel.minDuration,
        maxDuration: viewModel.maxDuration
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

  /// Formats shutter speed for display
  /// Fast speeds: "1/250", slow speeds: "0.5s"
  private var formattedShutterSpeed: String {
    let seconds = viewModel.currentDuration.seconds

    if seconds >= 1.0 {
      // Format as seconds with "s"
      if seconds == floor(seconds) {
        return String(format: "%.0fs", seconds)
      } else {
        return String(format: "%.1fs", seconds)
      }
    } else if seconds >= 0.1 {
      // Format as decimal seconds
      return String(format: "%.1fs", seconds)
    } else {
      // Format as fraction 1/X
      let denominator = Int(round(1.0 / seconds))
      return "1/\(denominator)"
    }
  }
}

/// Visual indicator showing position in shutter speed range
struct ShutterDialIndicator: View {
  let currentDuration: CMTime
  let minDuration: CMTime
  let maxDuration: CMTime

  private var progress: Double {
    guard maxDuration.seconds > minDuration.seconds else { return 0 }
    // Use logarithmic scale for better visual distribution
    let logMin = log(max(minDuration.seconds, 0.00001))
    let logMax = log(maxDuration.seconds)
    let logCurrent = log(currentDuration.seconds)
    // Invert because faster (shorter) should be on the left
    return 1.0 - (logCurrent - logMin) / (logMax - logMin)
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

    ShutterSpeedDialView(
      viewModel: ShutterSpeedDialViewModel(
        currentDuration: CMTime(value: 1, timescale: 125),
        minDuration: CMTime(value: 1, timescale: 8000),
        maxDuration: CMTime(value: 1, timescale: 4)
      )
    )
    .padding()
  }
}
