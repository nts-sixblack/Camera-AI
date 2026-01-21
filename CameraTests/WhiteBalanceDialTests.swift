//
//  WhiteBalanceDialTests.swift
//  CameraTests
//
//  Tests for WhiteBalancePreset enum and WhiteBalanceDialViewModel
//

import XCTest

@testable import Camera

final class WhiteBalanceDialTests: XCTestCase {

  // MARK: - WhiteBalancePreset Tests

  func testPreset_Auto_HasNilKelvinValue() {
    XCTAssertNil(WhiteBalancePreset.auto.kelvinValue)
  }

  func testPreset_Sunny_HasCorrectKelvinValue() {
    XCTAssertEqual(WhiteBalancePreset.sunny.kelvinValue, 5500)
  }

  func testPreset_Cloudy_HasCorrectKelvinValue() {
    XCTAssertEqual(WhiteBalancePreset.cloudy.kelvinValue, 6500)
  }

  func testPreset_Shade_HasCorrectKelvinValue() {
    XCTAssertEqual(WhiteBalancePreset.shade.kelvinValue, 7500)
  }

  func testPreset_Tungsten_HasCorrectKelvinValue() {
    XCTAssertEqual(WhiteBalancePreset.tungsten.kelvinValue, 3200)
  }

  func testPreset_Fluorescent_HasCorrectKelvinValue() {
    XCTAssertEqual(WhiteBalancePreset.fluorescent.kelvinValue, 4000)
  }

  func testPreset_Custom_HasNilKelvinValue() {
    XCTAssertNil(WhiteBalancePreset.custom.kelvinValue)
  }

  func testPreset_AllHaveNeutralTint() {
    for preset in WhiteBalancePreset.allCases {
      XCTAssertEqual(preset.tintValue, 0.0, "Preset \(preset.displayName) should have neutral tint")
    }
  }

  func testPreset_DisplayNamesAreNotEmpty() {
    for preset in WhiteBalancePreset.allCases {
      XCTAssertFalse(preset.displayName.isEmpty, "Preset \(preset) should have display name")
    }
  }

  func testPreset_ShortSymbolsAreNotEmpty() {
    for preset in WhiteBalancePreset.allCases {
      XCTAssertFalse(preset.shortSymbol.isEmpty, "Preset \(preset) should have short symbol")
    }
  }

  // MARK: - WhiteBalanceDialViewModel Initialization Tests

  func testViewModel_InitWithDefaultValues() {
    let viewModel = WhiteBalanceDialViewModel()

    XCTAssertEqual(viewModel.currentKelvin, 5500.0)
    XCTAssertEqual(viewModel.selectedPreset, .auto)
    XCTAssertEqual(viewModel.minKelvin, 2000.0)
    XCTAssertEqual(viewModel.maxKelvin, 10000.0)
  }

  func testViewModel_InitClampsLowValue() {
    let viewModel = WhiteBalanceDialViewModel(currentKelvin: 1000.0)

    XCTAssertEqual(viewModel.currentKelvin, 2000.0, "Should clamp to minKelvin")
  }

  func testViewModel_InitClampsHighValue() {
    let viewModel = WhiteBalanceDialViewModel(currentKelvin: 15000.0)

    XCTAssertEqual(viewModel.currentKelvin, 10000.0, "Should clamp to maxKelvin")
  }

  func testViewModel_InitWithValidValue() {
    let viewModel = WhiteBalanceDialViewModel(currentKelvin: 6200.0)

    XCTAssertEqual(viewModel.currentKelvin, 6200.0)
  }

  // MARK: - WhiteBalanceDialViewModel Preset Selection Tests

  func testViewModel_SelectPreset_UpdatesPresetAndKelvin() {
    let viewModel = WhiteBalanceDialViewModel()
    var receivedKelvin: Float?
    viewModel.onKelvinChanged = { kelvin in
      receivedKelvin = kelvin
    }

    viewModel.selectPreset(.sunny)

    XCTAssertEqual(viewModel.selectedPreset, .sunny)
    XCTAssertEqual(viewModel.currentKelvin, 5500.0)
    XCTAssertEqual(receivedKelvin, 5500.0)
  }

  func testViewModel_SelectPreset_Tungsten() {
    let viewModel = WhiteBalanceDialViewModel()

    viewModel.selectPreset(.tungsten)

    XCTAssertEqual(viewModel.selectedPreset, .tungsten)
    XCTAssertEqual(viewModel.currentKelvin, 3200.0)
  }

  func testViewModel_SelectPreset_Auto_CallsPresetCallback() {
    let viewModel = WhiteBalanceDialViewModel(selectedPreset: .sunny)
    var receivedPreset: WhiteBalancePreset?
    viewModel.onPresetSelected = { preset in
      receivedPreset = preset
    }

    viewModel.selectPreset(.auto)

    XCTAssertEqual(viewModel.selectedPreset, .auto)
    XCTAssertEqual(receivedPreset, .auto)
  }

  // MARK: - WhiteBalanceDialViewModel Kelvin Adjustment Tests

  func testViewModel_UpdateKelvin_ClampsToMinimum() {
    let viewModel = WhiteBalanceDialViewModel(currentKelvin: 5000.0)

    viewModel.updateKelvin(1500.0)

    XCTAssertEqual(viewModel.currentKelvin, 2000.0)
  }

  func testViewModel_UpdateKelvin_ClampsToMaximum() {
    let viewModel = WhiteBalanceDialViewModel(currentKelvin: 5000.0)

    viewModel.updateKelvin(12000.0)

    XCTAssertEqual(viewModel.currentKelvin, 10000.0)
  }

  func testViewModel_UpdateKelvin_AcceptsValidValue() {
    let viewModel = WhiteBalanceDialViewModel(currentKelvin: 5000.0)

    viewModel.updateKelvin(7200.0)

    XCTAssertEqual(viewModel.currentKelvin, 7200.0)
  }

  // MARK: - WhiteBalanceDialViewModel Boundary Tests

  func testViewModel_BoundaryAt2000K() {
    let viewModel = WhiteBalanceDialViewModel(currentKelvin: 2000.0)

    XCTAssertEqual(viewModel.currentKelvin, 2000.0)
  }

  func testViewModel_BoundaryAt10000K() {
    let viewModel = WhiteBalanceDialViewModel(currentKelvin: 10000.0)

    XCTAssertEqual(viewModel.currentKelvin, 10000.0)
  }

  func testViewModel_UpdateKelvin_ExactBoundary2000() {
    let viewModel = WhiteBalanceDialViewModel()

    viewModel.updateKelvin(2000.0)

    XCTAssertEqual(viewModel.currentKelvin, 2000.0)
  }

  func testViewModel_UpdateKelvin_ExactBoundary10000() {
    let viewModel = WhiteBalanceDialViewModel()

    viewModel.updateKelvin(10000.0)

    XCTAssertEqual(viewModel.currentKelvin, 10000.0)
  }

  // MARK: - WhiteBalanceDialViewModel Gesture State Tests

  func testViewModel_OnDragStart_PreparesState() {
    let viewModel = WhiteBalanceDialViewModel(currentKelvin: 5500.0)

    viewModel.onDragStart()

    // No crash = success (internal state prepared)
    XCTAssertEqual(viewModel.currentKelvin, 5500.0)
  }

  func testViewModel_OnDragEnd_SnapsToNearest100K() {
    let viewModel = WhiteBalanceDialViewModel(currentKelvin: 5550.0)

    viewModel.onDragEnd()

    XCTAssertEqual(viewModel.currentKelvin, 5600.0)
  }

  func testViewModel_OnDragEnd_AtExactValue() {
    let viewModel = WhiteBalanceDialViewModel(currentKelvin: 5500.0)

    viewModel.onDragEnd()

    XCTAssertEqual(viewModel.currentKelvin, 5500.0)
  }
}
