//
//  ExposureHUDViewModel.swift
//  Camera
//
//  ViewModel for the Exposure Values HUD overlay.
//  Formats raw values from CameraEngine into user-friendly strings.
//

import Combine
import CoreMedia
import Foundation

final class ExposureHUDViewModel: ObservableObject {

  // MARK: - Published Properties

  @Published var formattedISO: String = ""
  @Published var formattedShutterSpeed: String = ""
  @Published var formattedAperture: String = ""

  // MARK: - Dependencies

  private let cameraEngine: CameraEngine
  private var cancellables = Set<AnyCancellable>()

  // MARK: - Initialization

  init(cameraEngine: CameraEngine = .shared) {
    self.cameraEngine = cameraEngine
    setupBindings()
  }

  // MARK: - Bindings

  private func setupBindings() {
    // Bind ISO
    cameraEngine.$currentISO
      .receive(on: DispatchQueue.main)
      .sink { [weak self] iso in
        self?.formattedISO = self?.formatISO(iso) ?? ""
      }
      .store(in: &cancellables)

    // Bind Shutter Speed
    cameraEngine.$currentExposureDuration
      .receive(on: DispatchQueue.main)
      .sink { [weak self] duration in
        self?.formattedShutterSpeed = self?.formatShutterSpeed(duration) ?? ""
      }
      .store(in: &cancellables)

    // Bind Aperture
    cameraEngine.$currentAperture
      .receive(on: DispatchQueue.main)
      .sink { [weak self] aperture in
        self?.formattedAperture = self?.formatAperture(aperture) ?? ""
      }
      .store(in: &cancellables)
  }

  // MARK: - Formatting Logic

  func formatISO(_ iso: Float) -> String {
    return String(format: "ISO %.0f", iso)
  }

  func formatShutterSpeed(_ duration: CMTime) -> String {
    let seconds = duration.seconds

    // Guard against invalid/zero
    guard seconds > 0, seconds.isFinite else { return "--" }

    if seconds >= 1.0 {
      // Display as seconds with quote (e.g. 1", 2.5")
      // Use significant digits logic if needed, but standard is %.1f usually for non-integer
      let isInteger = floor(seconds) == seconds
      if isInteger {
        return String(format: "%.0f\"", seconds)
      } else {
        return String(format: "%.1f\"", seconds)
      }
    } else {
      // Display as fraction (e.g. 1/250)
      let denominator = round(1.0 / seconds)
      return String(format: "1/%.0f", denominator)
    }
  }

  func formatAperture(_ aperture: Float) -> String {
    return String(format: "f/%.1f", aperture)
  }
}
