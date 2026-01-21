//
//  ExposureHUDView.swift
//  Camera
//
//  Heads-Up Display for exposure values (ISO, Shutter, Aperture).
//

import SwiftUI

struct ExposureHUDView: View {

  let iso: Int
  let shutter: String
  let aperture: String

  var body: some View {
    HStack(spacing: 16) {
      hudItem(label: "ISO", value: "\(iso)")
      hudItem(label: "S", value: shutter)
      hudItem(label: "ƒ", value: aperture)
    }
    .padding(8)
    .background(Color.black.opacity(0.4))
    .cornerRadius(8)
  }

  private func hudItem(label: String, value: String) -> some View {
    HStack(spacing: 4) {
      Text(label)
        .font(.caption2)
        .fontWeight(.bold)
        .foregroundStyle(.white.opacity(0.7))

      Text(value)
        .font(.system(.caption, design: .monospaced))
        .foregroundStyle(.white)
    }
  }
}

#Preview {
  ZStack {
    Color.gray
    ExposureHUDView(iso: 400, shutter: "1/250", aperture: "f/1.6")
  }
}
