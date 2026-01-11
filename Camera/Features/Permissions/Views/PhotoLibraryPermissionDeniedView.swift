//
//  PhotoLibraryPermissionDeniedView.swift
//  Camera
//
//  Displays when Photo Library permission has been denied, with Settings redirect
//

import SwiftUI

/// View displayed when Photo Library permission is denied or restricted
struct PhotoLibraryPermissionDeniedView: View {
  /// Whether the restriction is due to parental controls (vs user denial)
  let isRestricted: Bool
  /// Action to open Settings app
  let onOpenSettings: () -> Void

  var body: some View {
    ZStack {
      AppColors.background
        .ignoresSafeArea()

      VStack(spacing: 32) {
        Spacer()

        Image(systemName: isRestricted ? "lock.fill" : "photo.on.rectangle.angled")
          .font(.system(size: 64))
          .foregroundStyle(AppColors.primaryText)
          .accessibilityHidden(true)

        VStack(spacing: 16) {
          Text(titleText)
            .font(.title2)
            .fontWeight(.semibold)
            .foregroundStyle(AppColors.primaryText)
            .multilineTextAlignment(.center)

          Text(descriptionText)
            .font(.body)
            .foregroundStyle(AppColors.secondaryText)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 32)
        }

        Spacer()

        if !isRestricted {
          Button(action: onOpenSettings) {
            Text("Open Settings")
              .font(.headline)
              .foregroundStyle(AppColors.buttonText)
              .frame(maxWidth: .infinity)
              .frame(height: 50)
              .background(AppColors.signalOrange)
              .clipShape(RoundedRectangle(cornerRadius: 12))
          }
          .padding(.horizontal, 24)
          .frame(minWidth: 44, minHeight: 44)
          .accessibilityLabel("Open Settings to enable photo library access")
        }

        Spacer()
          .frame(height: 48)
      }
    }
    .accessibilityElement(children: .contain)
    .accessibilityLabel(isRestricted ? "Photo library access restricted" : "Photo library access denied")
  }

  private var titleText: String {
    isRestricted ? "Photo Library Access Restricted" : "Photo Library Access Required"
  }

  private var descriptionText: String {
    if isRestricted {
      return "Photo Library access is restricted by parental controls or device policy. Contact your administrator to enable access."
    } else {
      return "To save your captured photos, please enable Photo Library access in Settings."
    }
  }
}

#Preview("Denied") {
  PhotoLibraryPermissionDeniedView(isRestricted: false, onOpenSettings: {})
}

#Preview("Restricted") {
  PhotoLibraryPermissionDeniedView(isRestricted: true, onOpenSettings: {})
}
