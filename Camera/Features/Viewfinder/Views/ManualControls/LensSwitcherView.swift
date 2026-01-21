//
//  LensSwitcherView.swift
//  Camera
//
//  Created by Sixblack on 2026-01-21.
//

import Combine
import SwiftUI

class LensSwitcherViewModel: ObservableObject {
  @Published var availableLensFactors: [CGFloat] = [1.0]
  @Published var currentZoomFactor: CGFloat = 1.0
  @Published var opacity: Double = 1.0

  private let cameraEngine: CameraEngine
  private var cancellables = Set<AnyCancellable>()

  // Haptic feedback
  private let selectionFeedback = UISelectionFeedbackGenerator()

  init(cameraEngine: CameraEngine = .shared) {
    self.cameraEngine = cameraEngine

    setupSubscriptions()
    selectionFeedback.prepare()
  }

  private func setupSubscriptions() {
    cameraEngine.$availableLensFactors
      .receive(on: DispatchQueue.main)
      .assign(to: \.availableLensFactors, on: self)
      .store(in: &cancellables)

    cameraEngine.$currentZoomFactor
      .receive(on: DispatchQueue.main)
      .assign(to: \.currentZoomFactor, on: self)
      .store(in: &cancellables)
  }

  func selectLens(_ factor: CGFloat) {
    // Only trigger if changed
    guard factor != currentZoomFactor else { return }

    // Provide haptic feedback
    selectionFeedback.selectionChanged()
    selectionFeedback.prepare()  // Prepare for next

    cameraEngine.setZoomFactor(factor)
  }

  func lensLabel(for factor: CGFloat) -> String {
    // Format: "0.5x", "1x", "3x"
    // Use modulo to check if integer
    if factor.truncatingRemainder(dividingBy: 1) == 0 {
      return String(format: "%.0fx", factor)
    } else {
      return String(format: "%.1fx", factor)
    }
  }
}

struct LensSwitcherView: View {
  @StateObject var viewModel: LensSwitcherViewModel

  init(cameraEngine: CameraEngine = .shared) {
    _viewModel = StateObject(wrappedValue: LensSwitcherViewModel(cameraEngine: cameraEngine))
  }

  var body: some View {
    HStack(spacing: 8) {
      if viewModel.availableLensFactors.count > 1 {
        ForEach(viewModel.availableLensFactors, id: \.self) { factor in
          LensButton(
            label: viewModel.lensLabel(for: factor),
            isSelected: isSelected(factor: factor),
            action: {
              viewModel.selectLens(factor)
            }
          )
        }
      } else {
        // Fallback for single lens (AC3)
        // Show "1x" just to indicate standard, or hide?
        // AC3 says: "the lens switcher is hidden or shows only '1x'"
        // Let's hide it if only 1 lens to save space, or show simplified.
        // If we want to hide it, we return EmptyView logic in parent or here.
        // Let's show "1x" static for now as per "shows only '1x'" option.
        LensButton(
          label: "1x",
          isSelected: true,
          action: {}
        )
        .disabled(true)
        .opacity(0.5)
      }
    }
    .padding(6)
    .background(Color.black.opacity(0.4))
    .clipShape(Capsule())
  }

  private func isSelected(factor: CGFloat) -> Bool {
    // Floating point comparison with small epsilon, or just use close enough
    abs(viewModel.currentZoomFactor - factor) < 0.1
  }
}

private struct LensButton: View {
  let label: String
  let isSelected: Bool
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      ZStack {
        // Active indicator (filled circle)
        Circle()
          .fill(isSelected ? Color.yellow.opacity(0.8) : Color.clear)
          .frame(width: 36, height: 36)

        Text(label)
          .font(.system(size: 13, weight: .bold))
          .foregroundColor(isSelected ? .black : .white)
      }
      .frame(width: 44, height: 44)  // Touch target
      .contentShape(Circle())
    }
  }
}

#Preview {
  ZStack {
    Color.gray
    LensSwitcherView()
  }
}
