//
//  SectionCard.swift
//  QuizUI
//
//  Created by Dmitrii Pogonia on 30.04.2026.
//

import SwiftUI

public struct SectionCard<Content: View>: View {
    let title: String?
    @ViewBuilder let content: Content

    public init(title: String? = nil, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: QuizSpacing.section) {
            if let title {
                QuizSectionTitle(title)
            }
            content
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.vertical, QuizSpacing.section)
                .background(QuizColor.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: QuizRadius.row, style: .continuous))
        }
    }
}
