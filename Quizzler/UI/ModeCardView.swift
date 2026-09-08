import SwiftUI

struct ModeCardView: View {
    let symbolName: String
    let title: String
    let subtitle: String
    var isDimmed = false
    var showsSpinner = false
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: symbolName)
                    .font(.system(size: 20, weight: .regular))
                    .foregroundStyle(Color.primary)
                    .frame(width: 28)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(Color.primary)
                    Text(subtitle)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(Color.secondary)
                        .multilineTextAlignment(.leading)
                }
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, minHeight: 72, maxHeight: 72, alignment: .leading)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay {
                if showsSpinner {
                    ProgressView()
                        .controlSize(.regular)
                }
            }
            .opacity(isDimmed ? 0.6 : 1)
        }
        .buttonStyle(.plain)
        .disabled(isDimmed && !showsSpinner)
    }
}
