import SwiftUI

public struct ChipButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    public init(title: String, isSelected: Bool, action: @escaping () -> Void) {
        self.title = title
        self.isSelected = isSelected
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Text(title)
                .font(QuizFont.bodySemibold)
                .foregroundStyle(isSelected ? QuizColor.onSelectedChip : QuizColor.primaryText)
                .frame(maxWidth: .infinity)
                .padding(.vertical, QuizSpacing.compact)
                .background(isSelected ? QuizColor.chipSelected : QuizColor.chipIdle)
                .clipShape(RoundedRectangle(cornerRadius: QuizRadius.chip, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}
