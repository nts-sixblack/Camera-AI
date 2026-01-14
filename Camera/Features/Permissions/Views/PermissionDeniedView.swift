//
//  PermissionDeniedView.swift
//  Camera
//
//  Displays when camera permission has been denied, with Settings redirect
//

import SwiftUI

/// View displayed when camera permission is denied or restricted
struct PermissionDeniedView: View {
  /// Whether the restriction is due to parental controls (vs user denial)
  let isRestricted: Bool
  /// Action to open Settings app
  let onOpenSettings: () -> Void

  var body: some View {
    GenericPermissionDeniedView(
      iconName: isRestricted ? "lock.fill" : "camera.fill",
      title: titleText,
      description: descriptionText,
      showSettingsButton: !isRestricted,
      onOpenSettings: onOpenSettings
    )
    .accessibilityElement(children: .contain)
    .accessibilityLabel(isRestricted ? "Camera access restricted" : "Camera access denied")
  }

  private var titleText: String {
    isRestricted ? "Camera Access Restricted" : "Camera Access Required"
  }

  private var descriptionText: String {
    if isRestricted {
      return
        "Camera access is restricted by parental controls or device policy. Contact your administrator to enable camera access."
    } else {
      return "To capture photos and videos, please enable camera access in Settings."
    }
  }
}

#Preview("Denied") {
  PermissionDeniedView(isRestricted: false, onOpenSettings: {})
}

#Preview("Restricted") {
  PermissionDeniedView(isRestricted: true, onOpenSettings: {})
}
