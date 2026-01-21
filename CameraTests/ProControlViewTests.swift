//
//  ProControlViewTests.swift
//  CameraTests
//
//  Created by BMad on 2026-01-14.
//

import SwiftUI
import XCTest

@testable import Camera

final class ProControlViewTests: XCTestCase {

  func testProControlViewInitialization() {
    let view = ProControlView(cameraEngine: .shared)
    XCTAssertNotNil(view)
  }

  func testExposureHUDViewInitialization() {
    let view = ExposureHUDView(iso: 100, shutter: "1/100", aperture: "f2.8")
    XCTAssertNotNil(view)
  }

  @MainActor
  func testProControlViewModelInactivityLogic() {
    let viewModel = ProControlViewModel(cameraEngine: .shared)

    // Initial state
    XCTAssertEqual(viewModel.opacity, 1.0)

    // Simulate inactivity
    // We can't easily advance the real system timer in XCTest without dependency injection of a Scheduler,
    // but we can test the checkInactivity method directly.

    let now = Date()
    let future = now.addingTimeInterval(4.0)  // > 3.0 threshold

    viewModel.checkInactivity(currentTime: future)

    // Opacity should drop to 0.3
    // Note: within withAnimation block, values change immediately in tests usually,
    // effectively verifying the logic branch was hit.
    XCTAssertEqual(viewModel.opacity, 0.3)

    // Simulate Interaction
    viewModel.handleInteraction()
    XCTAssertEqual(viewModel.opacity, 1.0)
  }

  @MainActor
  func testControlSelection() {
    let viewModel = ProControlViewModel(cameraEngine: .shared)
    XCTAssertEqual(viewModel.selectedControl, 0)

    viewModel.selectControl(2)
    XCTAssertEqual(viewModel.selectedControl, 2)
    XCTAssertEqual(viewModel.opacity, 1.0)  // Should verify interaction reset too
  }

  // MARK: - ISO Dial Tests (Story 2.2)

  @MainActor
  func testISODialViewModelInitialization() {
    let viewModel = ProControlViewModel(cameraEngine: .shared)
    let isoDialVM = viewModel.isoDialViewModel

    XCTAssertNotNil(isoDialVM)
    XCTAssertGreaterThanOrEqual(isoDialVM.minISO, 0)
    XCTAssertGreaterThan(isoDialVM.maxISO, isoDialVM.minISO)
  }

  func testISOStopsNearestValue() {
    // Test that nearest function finds correct ISO stops
    let nearest100 = ISOStops.nearest(to: 100, minISO: 32, maxISO: 12800)
    XCTAssertEqual(nearest100, 100)

    let nearest110 = ISOStops.nearest(to: 110, minISO: 32, maxISO: 12800)
    XCTAssertEqual(nearest110, 100)  // 100 is closer than 125

    let nearest120 = ISOStops.nearest(to: 120, minISO: 32, maxISO: 12800)
    XCTAssertEqual(nearest120, 125)  // 125 is closer than 100
  }

  func testISOStopsHigherValue() {
    let higher = ISOStops.higher(than: 100, maxISO: 12800)
    XCTAssertEqual(higher, 125)

    let higherAtMax = ISOStops.higher(than: 51200, maxISO: 51200)
    XCTAssertNil(higherAtMax)
  }

  func testISOStopsLowerValue() {
    let lower = ISOStops.lower(than: 125, minISO: 32)
    XCTAssertEqual(lower, 100)

    let lowerAtMin = ISOStops.lower(than: 32, minISO: 32)
    XCTAssertNil(lowerAtMin)
  }
}
