import SwiftUI

struct ModeToggleView: View {
  let mode: CameraMode
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      HStack(spacing: 0) {
        modeText("Auto", isActive: mode == .auto)
        modeText("Pro", isActive: mode == .pro)
      }
      .background(Color.black.opacity(0.5))
      .clipShape(Capsule())
      .overlay(
        Capsule()
          .stroke(Color.white.opacity(0.2), lineWidth: 1)
      )
      .frame(minHeight: 44)  // AC2: Minimum touch target
    }
    .buttonStyle(PlainButtonStyle())
    .accessibilityLabel("Toggle Camera Mode")
    .accessibilityValue(mode == .auto ? "Auto" : "Pro")
  }

  private func modeText(_ text: String, isActive: Bool) -> some View {
    Text(text)
      .font(.system(size: 14, weight: .bold))
      .foregroundColor(isActive ? .white : .white.opacity(0.6))
      .padding(.vertical, 8)
      .padding(.horizontal, 16)
      .background(
        isActive ? AppColors.signalOrange : Color.clear
      )
      .clipShape(Capsule())
      .animation(.easeInOut(duration: 0.2), value: isActive)
      .contentShape(Rectangle())  // Ensure tap target checks the whole area if needed, though padding helps
  }
}

#Preview {
  VStack {
    ModeToggleView(mode: .auto, action: {})
    ModeToggleView(mode: .pro, action: {})
  }
  .padding()
  .background(Color.gray)
}
