//
//  ExposureHUDViewModelTests.swift
//  CameraTests
//
//  Tests for formatting logic of exposure values in the HUD
//

import XCTest
import CoreMedia
@testable import Camera

final class ExposureHUDViewModelTests: XCTestCase {
    
    // MARK: - Shutter Speed Formatting
    
    func testFormattedShutterSpeed_Fractions() {
        let vm = ExposureHUDViewModel()
        
        // 1/250s
        let t1 = CMTime(value: 1, timescale: 250)
        XCTAssertEqual(vm.formatShutterSpeed(t1), "1/250")
        
        // 1/60s
        let t2 = CMTime(value: 1, timescale: 60)
        XCTAssertEqual(vm.formatShutterSpeed(t2), "1/60")
        
        // 1/1000s
        let t3 = CMTime(value: 1, timescale: 1000)
        XCTAssertEqual(vm.formatShutterSpeed(t3), "1/1000")
        
        // 1/48s (Standard cinematic)
        let t4 = CMTime(value: 1, timescale: 48)
        XCTAssertEqual(vm.formatShutterSpeed(t4), "1/48")
    }
    
    func testFormattedShutterSpeed_Seconds() {
        let vm = ExposureHUDViewModel()
        
        // 1.0s
        let t1 = CMTime(value: 1, timescale: 1)
        XCTAssertEqual(vm.formatShutterSpeed(t1), "1\"")
        
        // 2.5s (Long exposure) - rounding to nearest interesting value or decimal? AC say "0.5\""
        let t2 = CMTime(value: 5, timescale: 2) // 2.5s
        XCTAssertEqual(vm.formatShutterSpeed(t2), "2.5\"")
        
        // 0.5s (1/2s, but usually displayed as 0.5" or 1/2 in cameras? AC says ' "0.5"" if applicable')
        // Let's implement logic: if >= 1.0s, use seconds with ". Others use fractions.
        // Wait, standard convention: 0.5s is usually 1/2.
        // AC says: "Given shutter speed is 1 second or slower -> decimal seconds"
        // "Faster than 1 second -> fraction"
        // So 0.5s is faster than 1s (0.5 < 1). So it should be "1/2".
        
        let t3 = CMTime(value: 1, timescale: 2) // 0.5s
        XCTAssertEqual(vm.formatShutterSpeed(t3), "1/2")
    }
    
    // MARK: - Aperture Formatting
    
    func testFormattedAperture() {
        let vm = ExposureHUDViewModel()
        
        // f/1.8
        XCTAssertEqual(vm.formatAperture(1.8), "f/1.8")
        
        // f/2.4
        XCTAssertEqual(vm.formatAperture(2.4), "f/2.4")
        
        // f/11 (integer case) - Usually displayed as f/11, not f/11.0? 
        // Standard is often f/11. Let's assume standard formatting %.1f usually unless .0
        // AC example: "f/1.8".
        // Let's stick to %.1f for safety for now.
        XCTAssertEqual(vm.formatAperture(11.0), "f/11.0") 
    }
    
    // MARK: - ISO Formatting
    
    func testFormattedISO() {
        let vm = ExposureHUDViewModel()
        
        // ISO 100
        XCTAssertEqual(vm.formatISO(100.0), "ISO 100")
        
        // ISO 3200
        XCTAssertEqual(vm.formatISO(3200.0), "ISO 3200")
    }
}
