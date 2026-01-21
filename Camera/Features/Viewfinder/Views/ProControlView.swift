//
//  ProControlView.swift
//  Camera
//
//  Container view for Pro mode manual controls (ISO, Shutter, Focus).
//  Designed to occupy the bottom "Thumb Zone" (~180pt).
//

import Combine
import CoreMedia
import SwiftUI

class ProControlViewModel: ObservableObject {
  @Published var selectedControl = 0
  @Published var opacity: Double = 1.0

  private var lastInteractionTime = Date()
  private let inactivityThreshold: TimeInterval = 3.0
  private var timer: AnyCancellable?

  // Camera Engine reference for manual controls
  let cameraEngine: CameraEngine

  // ISO Dial ViewModel - created lazily and connected to camera engine
  lazy var isoDialViewModel: ISODialViewModel = {
    let vm = ISODialViewModel(
      currentISO: cameraEngine.currentISO,
      minISO: cameraEngine.minISO,
      maxISO: cameraEngine.maxISO
    )
    vm.onISOChanged = { [weak self] iso in
      self?.cameraEngine.setISO(iso)
    }
    return vm
  }()

  // Shutter Speed Dial ViewModel - created lazily and connected to camera engine
  lazy var shutterSpeedDialViewModel: ShutterSpeedDialViewModel = {
    let vm = ShutterSpeedDialViewModel(
      currentDuration: cameraEngine.currentExposureDuration,
      minDuration: cameraEngine.minExposureDuration,
      maxDuration: cameraEngine.maxExposureDuration
    )
    vm.onShutterSpeedChanged = { [weak self] duration in
      self?.cameraEngine.setShutterSpeed(duration)
    }
    return vm
  }()

  // Focus Dial ViewModel - created lazily and connected to camera engine
  lazy var focusDialViewModel: FocusDialViewModel = {
    let vm = FocusDialViewModel(
      currentLensPosition: cameraEngine.currentLensPosition
    )
    vm.onLensPositionChanged = { [weak self] lensPosition in
      self?.cameraEngine.setFocusLensPosition(lensPosition)
    }
    return vm
  }()

  // White Balance Dial ViewModel - created lazily and connected to camera engine
  lazy var whiteBalanceDialViewModel: WhiteBalanceDialViewModel = {
    let vm = WhiteBalanceDialViewModel(
      currentKelvin: cameraEngine.currentTemperatureKelvin,
      selectedPreset: .auto
    )
    vm.onKelvinChanged = { [weak self] kelvin in
      self?.cameraEngine.setWhiteBalanceTemperature(kelvin)
    }
    vm.onPresetSelected = { [weak self] preset in
      if preset == .auto {
        self?.cameraEngine.setAutoWhiteBalance()
      }
    }
    return vm
  }()

  private var cancellables = Set<AnyCancellable>()

  init(cameraEngine: CameraEngine) {
    self.cameraEngine = cameraEngine
    startTimer()

    // Subscribe to camera engine ISO updates
    cameraEngine.$currentISO
      .receive(on: DispatchQueue.main)
      .sink { [weak self] iso in
        self?.isoDialViewModel.updateISO(iso)
      }
      .store(in: &cancellables)

    // Subscribe to camera engine exposure duration updates
    cameraEngine.$currentExposureDuration
      .receive(on: DispatchQueue.main)
      .sink { [weak self] duration in
        self?.shutterSpeedDialViewModel.updateDuration(duration)
      }
      .store(in: &cancellables)

    // Subscribe to camera engine lens position updates
    cameraEngine.$currentLensPosition
      .receive(on: DispatchQueue.main)
      .sink { [weak self] lensPosition in
        self?.focusDialViewModel.updateLensPosition(lensPosition)
      }
      .store(in: &cancellables)

    // Subscribe to camera engine white balance temperature updates
    cameraEngine.$currentTemperatureKelvin
      .receive(on: DispatchQueue.main)
      .sink { [weak self] kelvin in
        self?.whiteBalanceDialViewModel.updateKelvin(kelvin)
      }
      .store(in: &cancellables)

    // TODO: [Story 2-3 Review] Implement dynamic bounds updates when device format changes
    // Currently, ISO and shutter speed dials use initial bounds from CameraEngine.
    // If format changes mid-session, bounds would be stale.
  }

  func startTimer() {
    timer = Timer.publish(every: 0.5, on: .main, in: .common)
      .autoconnect()
      .sink { [weak self] currentTime in
        self?.checkInactivity(currentTime: currentTime)
      }
  }

  func checkInactivity(currentTime: Date) {
    let timeSinceInteraction = currentTime.timeIntervalSince(lastInteractionTime)
    if timeSinceInteraction > inactivityThreshold {
      if opacity != 0.3 {
        withAnimation(.easeInOut(duration: 0.5)) {
          opacity = 0.3
        }
      }
    }
  }

  func handleInteraction() {
    lastInteractionTime = Date()
    if opacity != 1.0 {
      withAnimation(.easeOut(duration: 0.2)) {
        opacity = 1.0
      }
    }
  }

  func selectControl(_ index: Int) {
    selectedControl = index
    handleInteraction()
  }
}

struct ProControlView: View {

  @ObservedObject var viewModel: ProControlViewModel

  init(cameraEngine: CameraEngine) {
    self.viewModel = ProControlViewModel(cameraEngine: cameraEngine)
  }

  var body: some View {
    VStack(spacing: 0) {
      // Control Selector (Tabs)
      HStack(spacing: 20) {
        controlButton(title: "ISO", index: 0)
        controlButton(title: "S", index: 1)  // Shutter
        controlButton(title: "WB", index: 2)  // White Balance
        controlButton(title: "Focus", index: 3)
      }
      .padding(.top, 10)
      .padding(.bottom, 8)

      // Control Area - shows selected dial
      Group {
        switch viewModel.selectedControl {
        case 0:
          // ISO Dial
          ISODialView(viewModel: viewModel.isoDialViewModel)
        case 1:
          // Shutter Speed Dial
          ShutterSpeedDialView(viewModel: viewModel.shutterSpeedDialViewModel)
        case 2:
          // White Balance Dial
          WhiteBalanceDialView(viewModel: viewModel.whiteBalanceDialViewModel)
        case 3:
          // Manual Focus Dial
          FocusDialView(viewModel: viewModel.focusDialViewModel)
        default:
          placeholderControl(title: "Control")
        }
      }
      .frame(height: 110)
      .padding(.horizontal)

      Spacer()
    }
    .frame(height: 180)
    .background(Color.black.opacity(0.5))
    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    .opacity(viewModel.opacity)
    // Detect interactions to reset timer
    .simultaneousGesture(
      DragGesture(minimumDistance: 0)
        .onChanged { _ in
          viewModel.handleInteraction()
        }
        .onEnded { _ in
          viewModel.handleInteraction()
        }
    )
  }

  private func controlButton(title: String, index: Int) -> some View {
    Button(action: {
      viewModel.selectControl(index)
    }) {
      Text(title)
        .font(.system(size: 14, weight: .bold))
        .foregroundStyle(viewModel.selectedControl == index ? Color.yellow : Color.white)
        .frame(minWidth: 44, minHeight: 44)
    }
  }

  private func placeholderControl(title: String) -> some View {
    ZStack {
      Color.black.opacity(0.3)

      VStack(spacing: 8) {
        Text(title)
          .font(.headline)
          .foregroundStyle(.white.opacity(0.6))

        Text("Coming Soon")
          .font(.caption)
          .foregroundStyle(.white.opacity(0.4))
      }
    }
    .clipShape(RoundedRectangle(cornerRadius: 12))
  }
}

#Preview {
  ZStack {
    Color.gray
    VStack {
      Spacer()
      ProControlView(cameraEngine: .shared)
    }
  }
}
