//
//  GenericPermissionDeniedView.swift
//  Camera
//
//  Reusable view for permission denied states (Camera, Photo Library, etc.)
//

import SwiftUI

struct GenericPermissionDeniedView: View {
  let iconName: String
  let title: String
  let description: String
  let showSettingsButton: Bool
  let onOpenSettings: () -> Void

  var body: some View {
    ZStack {
      AppColors.background
        .ignoresSafeArea()

      VStack(spacing: 32) {
        Spacer()

        Image(systemName: iconName)
          .font(.system(size: 64))
          .foregroundStyle(AppColors.primaryText)
          .accessibilityHidden(true)

        VStack(spacing: 16) {
          Text(title)
            .font(.title2)
            .fontWeight(.semibold)
            .foregroundStyle(AppColors.primaryText)
            .multilineTextAlignment(.center)

          Text(description)
            .font(.body)
            .foregroundStyle(AppColors.secondaryText)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 32)
        }

        Spacer()

        if showSettingsButton {
          Button(action: onOpenSettings) {
            Text("Open Settings")
              .font(.headline)
              .foregroundStyle(AppColors.buttonText)
              .frame(maxWidth: .infinity)
              .frame(height: AppColors.buttonHeight)
              .background(AppColors.signalOrange)
              .clipShape(RoundedRectangle(cornerRadius: 12))
          }
          .padding(.horizontal, 24)
          .frame(minWidth: AppColors.minTouchTarget, minHeight: AppColors.minTouchTarget)
          .accessibilityLabel("Open Settings")
        }

        Spacer()
          .frame(height: 48)
      }
    }
  }
}
