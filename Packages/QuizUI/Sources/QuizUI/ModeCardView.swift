import SwiftUI

public struct ModeCardView: View {
    let symbolName: String
    let title: String
    let subtitle: String
    var isDimmed = false
    var showsSpinner = false
    var action: () -> Void

    public init(
        symbolName: String,
        title: String,
        subtitle: String,
        isDimmed: Bool = false,
        showsSpinner: Bool = false,
        action: @escaping () -> Void
    ) {
        self.symbolName = symbolName
        self.title = title
        self.subtitle = subtitle
        self.isDimmed = isDimmed
        self.showsSpinner = showsSpinner
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: QuizSpacing.section) {
                Image(systemName: symbolName)
                    .font(QuizFont.symbol)
                    .foregroundStyle(QuizColor.primaryText)
                    .frame(width: 28)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(QuizFont.cardTitle)
                        .foregroundStyle(QuizColor.primaryText)
                    Text(subtitle)
                        .font(QuizFont.caption)
                        .foregroundStyle(QuizColor.secondaryText)
                        .multilineTextAlignment(.leading)
                }
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, QuizSpacing.section)
            .frame(maxWidth: .infinity, minHeight: 72, maxHeight: 72, alignment: .leading)
            .background(QuizColor.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: QuizRadius.card, style: .continuous))
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
