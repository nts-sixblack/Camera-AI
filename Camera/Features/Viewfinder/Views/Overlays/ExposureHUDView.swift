//
//  ExposureHUDView.swift
//  Camera
//
//  HUD for displaying real-time exposure values (ISO, Shutter, Aperture)
//  Overlayed on the viewfinder in Pro Mode.
//

import SwiftUI

struct ExposureHUDView: View {
  @StateObject private var viewModel = ExposureHUDViewModel()

  var body: some View {
    HStack(spacing: 24) {
      Text(viewModel.formattedISO)
        .accessibilityLabel("ISO Value")
        .accessibilityValue(viewModel.formattedISO)

      Text(viewModel.formattedShutterSpeed)
        .accessibilityLabel("Shutter Speed")
        .accessibilityValue(viewModel.formattedShutterSpeed)

      Text(viewModel.formattedAperture)
        .accessibilityLabel("Aperture")
        .accessibilityValue(viewModel.formattedAperture)
    }
    .font(.system(size: 17, weight: .medium, design: .monospaced))  // SF Mono substitute
    .foregroundColor(.white)
    // Add subtle shadow for legibility against bright backgrounds (AC4)
    .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 1)
    .padding(.top, 100)  // Position near top (heuristic, will adjust in integration)
    .frame(maxWidth: .infinity, alignment: .top)
  }
}

#Preview {
  ZStack {
    Color.gray
    ExposureHUDView()
  }
}
