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
    GenericPermissionDeniedView(
      iconName: isRestricted ? "lock.fill" : "photo.on.rectangle.angled",
      title: titleText,
      description: descriptionText,
      showSettingsButton: !isRestricted,
      onOpenSettings: onOpenSettings
    )
    .accessibilityElement(children: .contain)
    .accessibilityLabel(
      isRestricted ? "Photo library access restricted" : "Photo library access denied")
  }

  private var titleText: String {
    isRestricted ? "Photo Library Access Restricted" : "Photo Library Access Required"
  }

  private var descriptionText: String {
    if isRestricted {
      return
        "Photo Library access is restricted by parental controls or device policy. Contact your administrator to enable access."
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
