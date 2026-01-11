//
//  AppColors.swift
//  Camera
//
//  Centralized color definitions following the UX Design Specification.
//  Dark Mode Only app with True Black background and Signal Orange accent.
//

import SwiftUI

/// App-wide color constants from UX Design Specification
enum AppColors {
  /// True Black background (#000000)
  static let background = Color.black

  /// Primary text color (#FFFFFF)
  static let primaryText = Color.white

  /// Secondary text color (white with reduced opacity)
  static let secondaryText = Color.white.opacity(0.8)

  /// Signal Orange accent color (#FF9500) - used for primary actions
  static let signalOrange = Color(red: 255/255, green: 149/255, blue: 0/255)

  /// Text color for buttons on Signal Orange background
  static let buttonText = Color.black
}
