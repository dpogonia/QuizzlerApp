import SwiftUI

public struct QuizSectionTitle: View {
    let text: String

    public init(_ text: String) {
        self.text = text
    }

    public var body: some View {
        Text(text)
            .font(QuizFont.screenTitle)
            .foregroundStyle(QuizColor.primaryText)
    }
}

public struct QuizInfoCard: View {
    let title: String
    let subtitle: String

    public init(title: String, subtitle: String) {
        self.title = title
        self.subtitle = subtitle
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: QuizSpacing.tight) {
            Text(title)
                .font(QuizFont.recordTitle)
                .foregroundStyle(QuizColor.primaryText)
            Text(subtitle)
                .font(QuizFont.body)
                .foregroundStyle(QuizColor.secondaryText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.vertical, QuizSpacing.section)
        .background(QuizColor.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: QuizRadius.row, style: .continuous))
    }
}

public struct QuizLoadingStatus: View {
    let text: String

    public init(text: String) {
        self.text = text
    }

    public var body: some View {
        VStack(spacing: QuizSpacing.compact) {
            ProgressView()
            Text(text)
                .font(QuizFont.caption)
                .foregroundStyle(QuizColor.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 56)
    }
}

public struct QuizHeroIcon: View {
    let systemName: String
    let size: CGFloat
    let color: Color

    public init(systemName: String, size: CGFloat, color: Color = QuizColor.primaryText) {
        self.systemName = systemName
        self.size = size
        self.color = color
    }

    public var body: some View {
        Image(systemName: systemName)
            .font(.system(size: size, weight: .bold))
            .foregroundStyle(color)
    }
}

public struct QuizHintText: View {
    let text: String

    public init(_ text: String) {
        self.text = text
    }

    public var body: some View {
        Text(text)
            .font(QuizFont.body)
            .foregroundStyle(QuizColor.secondaryText)
    }
}
