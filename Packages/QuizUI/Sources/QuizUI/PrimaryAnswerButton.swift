import SwiftUI

public struct PrimaryAnswerButton: View {
    let title: String
    let isEnabled: Bool
    let action: () -> Void

    public init(title: String, isEnabled: Bool, action: @escaping () -> Void) {
        self.title = title
        self.isEnabled = isEnabled
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Text(title)
                .font(QuizFont.answer)
                .foregroundStyle(QuizColor.inverseText)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(QuizColor.primaryText)
                .clipShape(RoundedRectangle(cornerRadius: QuizRadius.answer, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: QuizRadius.answer, style: .continuous)
                        .stroke(QuizColor.primaryText, lineWidth: 1)
                }
        }
        .buttonStyle(.plain)
        .opacity(isEnabled ? 1 : 0.5)
        .disabled(!isEnabled)
    }
}
