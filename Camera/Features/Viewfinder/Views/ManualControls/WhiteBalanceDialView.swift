//
//  WhiteBalanceDialView.swift
//  Camera
//
//  White balance control with preset selection and Kelvin dial adjustment.
//  Implements both tap-to-select presets and vertical swipe for custom Kelvin.
//

import Combine
import SwiftUI
import UIKit

// MARK: - White Balance Preset Enum

/// Standard white balance presets with corresponding color temperatures
enum WhiteBalancePreset: String, CaseIterable, Identifiable {
  case auto = "Auto"
  case sunny = "Sunny"
  case cloudy = "Cloudy"
  case shade = "Shade"
  case tungsten = "Tungsten"
  case fluorescent = "Fluorescent"
  case custom = "Custom"

  var id: String { rawValue }

  /// Display name for the preset
  var displayName: String { rawValue }

  /// Approximate Kelvin value for the preset (nil for auto/custom)
  var kelvinValue: Float? {
    switch self {
    case .auto: return nil
    case .sunny: return 5500
    case .cloudy: return 6500
    case .shade: return 7500
    case .tungsten: return 3200
    case .fluorescent: return 4000
    case .custom: return nil
    }
  }

  /// Tint value for the preset (neutral for all presets in this implementation)
  var tintValue: Float { 0.0 }

  /// Short display symbol for compact UI
  var shortSymbol: String {
    switch self {
    case .auto: return "A"
    case .sunny: return "☀️"
    case .cloudy: return "☁️"
    case .shade: return "🏠"
    case .tungsten: return "💡"
    case .fluorescent: return "🔆"
    case .custom: return "K"
    }
  }
}

// MARK: - White Balance Dial ViewModel

/// ViewModel for White Balance Dial control
class WhiteBalanceDialViewModel: ObservableObject {
  // MARK: - Published Properties

  @Published var currentKelvin: Float
  @Published var selectedPreset: WhiteBalancePreset

  // MARK: - Constants

  let minKelvin: Float = 2000.0
  let maxKelvin: Float = 10000.0

  /// Threshold for Kelvin change before updating (in points)
  private let deltaThreshold: CGFloat = 30.0

  /// Kelvin change per step
  private let kelvinChangePerStep: Float = 100.0

  /// Haptic trigger interval in Kelvin
  private let hapticInterval: Float = 100.0

  // MARK: - Callbacks

  /// Callback when Kelvin value changes
  var onKelvinChanged: ((Float) -> Void)?

  /// Callback when preset is selected (for Auto mode)
  var onPresetSelected: ((WhiteBalancePreset) -> Void)?

  // MARK: - Haptic Generators

  private let selectionFeedback = UISelectionFeedbackGenerator()
  private let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)

  // MARK: - Gesture State

  private var accumulatedDelta: CGFloat = 0
  private var lastKelvin: Float = 5500
  private var lastHapticKelvin: Float = 5500

  // MARK: - Initialization

  init(currentKelvin: Float = 5500.0, selectedPreset: WhiteBalancePreset = .auto) {
    // Clamp input value to valid range
    self.currentKelvin = max(2000.0, min(currentKelvin, 10000.0))
    self.selectedPreset = selectedPreset
    self.lastHapticKelvin = self.currentKelvin
  }

  // MARK: - Preset Selection

  /// Selects a white balance preset
  /// - Parameter preset: The preset to select
  func selectPreset(_ preset: WhiteBalancePreset) {
    selectedPreset = preset

    if preset == .auto {
      // Call auto mode callback
      onPresetSelected?(preset)
    } else if let kelvin = preset.kelvinValue {
      // Apply preset's Kelvin value
      currentKelvin = kelvin
      lastHapticKelvin = kelvin
      onKelvinChanged?(kelvin)
    }
    // Custom preset is handled via dial interaction

    triggerStepFeedback()
  }

  // MARK: - Gesture Handlers

  /// Called when drag gesture starts
  func onDragStart() {
    lastKelvin = currentKelvin
    lastHapticKelvin = currentKelvin
    accumulatedDelta = 0
    selectionFeedback.prepare()
  }

  /// Process drag gesture change
  /// - Parameter translation: Vertical translation from gesture (negative = up = higher Kelvin)
  func onDragChange(translation: CGFloat) {
    // Invert: swiping up (negative translation) should increase Kelvin (cooler)
    let delta = -translation - accumulatedDelta

    if abs(delta) >= deltaThreshold {
      let stepsToChange = Int(delta / deltaThreshold)
      let kelvinDelta = Float(stepsToChange) * kelvinChangePerStep

      var newKelvin = currentKelvin + kelvinDelta

      // Check bounds and provide resistance feedback
      if newKelvin < minKelvin {
        newKelvin = minKelvin
        if currentKelvin > minKelvin {
          triggerBoundFeedback()
        }
      } else if newKelvin > maxKelvin {
        newKelvin = maxKelvin
        if currentKelvin < maxKelvin {
          triggerBoundFeedback()
        }
      } else {
        // Trigger haptic for significant Kelvin changes
        let kelvinDiff = abs(newKelvin - lastHapticKelvin)
        if kelvinDiff >= hapticInterval {
          triggerStepFeedback()
          lastHapticKelvin = newKelvin
        }
      }

      if newKelvin != currentKelvin {
        currentKelvin = newKelvin
        selectedPreset = .custom  // Switch to custom when manually adjusting
        onKelvinChanged?(newKelvin)
      }

      accumulatedDelta += CGFloat(stepsToChange) * deltaThreshold
    }
  }

  /// Called when drag gesture ends
  func onDragEnd() {
    // Snap to nearest 100K for cleaner values
    let snappedKelvin = round(currentKelvin / 100.0) * 100.0
    if snappedKelvin != currentKelvin {
      currentKelvin = max(minKelvin, min(snappedKelvin, maxKelvin))
      onKelvinChanged?(currentKelvin)
    }
  }

  /// Updates the Kelvin value from external source (e.g., camera)
  func updateKelvin(_ kelvin: Float) {
    let clamped = max(minKelvin, min(kelvin, maxKelvin))
    if clamped != currentKelvin {
      currentKelvin = clamped
      lastHapticKelvin = clamped
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

// MARK: - White Balance Dial View

/// White Balance Dial View with preset buttons and Kelvin swipe adjustment
struct WhiteBalanceDialView: View {
  @ObservedObject var viewModel: WhiteBalanceDialViewModel

  // State to track if drag has started this gesture
  @State private var isDragging = false

  var body: some View {
    VStack(spacing: 6) {
      // Preset Selection Row
      ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: 8) {
          ForEach(WhiteBalancePreset.allCases.filter { $0 != .custom }) { preset in
            presetButton(preset)
          }
        }
        .padding(.horizontal, 8)
      }
      .frame(height: 32)

      // Temperature Display and Dial Area
      HStack(spacing: 12) {
        // Kelvin Value Display
        VStack(alignment: .leading, spacing: 2) {
          Text(displayText)
            .font(.system(size: 20, weight: .bold, design: .rounded))
            .foregroundStyle(.white)
            .minimumScaleFactor(0.7)

          Text("Swipe ↑↓ for Kelvin")
            .font(.caption2)
            .foregroundStyle(.white.opacity(0.5))
        }
        .frame(width: 100, alignment: .leading)

        // Temperature Gradient Indicator
        WhiteBalanceDialIndicator(
          currentKelvin: viewModel.currentKelvin,
          minKelvin: viewModel.minKelvin,
          maxKelvin: viewModel.maxKelvin
        )
      }
      .padding(.horizontal, 12)
      .frame(maxWidth: .infinity)
    }
    .contentShape(Rectangle())
    .gesture(
      DragGesture()
        .onChanged { value in
          if !isDragging {
            viewModel.onDragStart()
            isDragging = true
          }
          viewModel.onDragChange(translation: value.translation.height)
        }
        .onEnded { _ in
          viewModel.onDragEnd()
          isDragging = false
        }
    )
  }

  // MARK: - Display Text

  private var displayText: String {
    if viewModel.selectedPreset == .auto {
      return "Auto"
    } else if let kelvin = viewModel.selectedPreset.kelvinValue,
      viewModel.selectedPreset != .custom
    {
      return "\(viewModel.selectedPreset.displayName) (\(Int(kelvin))K)"
    } else {
      return "\(Int(viewModel.currentKelvin))K"
    }
  }

  // MARK: - Preset Button

  private func presetButton(_ preset: WhiteBalancePreset) -> some View {
    Button(action: {
      viewModel.selectPreset(preset)
    }) {
      Text(preset.shortSymbol)
        .font(.system(size: 14))
        .frame(width: 32, height: 28)
        .background(
          RoundedRectangle(cornerRadius: 6)
            .fill(
              viewModel.selectedPreset == preset
                ? Color.orange.opacity(0.8)
                : Color.white.opacity(0.15)
            )
        )
        .foregroundStyle(viewModel.selectedPreset == preset ? .white : .white.opacity(0.8))
    }
    .buttonStyle(.plain)
  }
}

// MARK: - White Balance Dial Indicator

/// Visual indicator showing position in temperature range with color gradient
struct WhiteBalanceDialIndicator: View {
  let currentKelvin: Float
  let minKelvin: Float
  let maxKelvin: Float

  private var progress: Double {
    guard maxKelvin > minKelvin else { return 0.5 }
    return Double((currentKelvin - minKelvin) / (maxKelvin - minKelvin))
  }

  var body: some View {
    GeometryReader { geometry in
      ZStack(alignment: .leading) {
        // Temperature gradient background
        LinearGradient(
          colors: [
            Color.orange,  // 2000K - warm
            Color.orange.opacity(0.8),
            Color.white,  // ~6500K - neutral
            Color.blue.opacity(0.7),
            Color.blue,  // 10000K - cool
          ],
          startPoint: .leading,
          endPoint: .trailing
        )
        .clipShape(RoundedRectangle(cornerRadius: 4))

        // Position indicator
        Circle()
          .fill(Color.white)
          .frame(width: 12, height: 12)
          .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
          .offset(
            x: max(
              6, min(CGFloat(progress) * geometry.size.width - 6, geometry.size.width - 12)))
      }
    }
    .frame(height: 16)
  }
}

// MARK: - Preview

#Preview {
  ZStack {
    Color.black.ignoresSafeArea()

    VStack {
      WhiteBalanceDialView(
        viewModel: WhiteBalanceDialViewModel(
          currentKelvin: 5500,
          selectedPreset: .sunny
        )
      )
      .padding()
    }
  }
}
