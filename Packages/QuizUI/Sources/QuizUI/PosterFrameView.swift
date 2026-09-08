import SwiftUI
import UIKit

public struct PosterFrameView: View {
    let image: UIImage?
    let fillContent: Bool
    let borderColor: Color
    let isLoading: Bool

    private static let aspectRatio: CGFloat = 2 / 3

    public init(
        image: UIImage?,
        fillContent: Bool,
        borderColor: Color,
        isLoading: Bool
    ) {
        self.image = image
        self.fillContent = fillContent
        self.borderColor = borderColor
        self.isLoading = isLoading
    }

    public var body: some View {
        GeometryReader { geo in
            let posterSize = Self.fittedSize(in: geo.size)
            ZStack {
                QuizColor.posterBackground
                if let image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: fillContent ? .fill : .fit)
                        .frame(width: posterSize.width, height: posterSize.height)
                        .clipped()
                }
                if isLoading {
                    ProgressView()
                        .controlSize(.large)
                        .tint(QuizColor.primaryText)
                }
            }
            .frame(width: posterSize.width, height: posterSize.height)
            .clipShape(RoundedRectangle(cornerRadius: QuizRadius.poster, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: QuizRadius.poster, style: .continuous)
                    .strokeBorder(borderColor, lineWidth: 16)
            }
            .frame(width: geo.size.width, height: geo.size.height, alignment: .center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private static func fittedSize(in container: CGSize) -> CGSize {
        guard container.width > 0, container.height > 0 else { return .zero }
        if container.width / container.height > aspectRatio {
            return CGSize(width: container.height * aspectRatio, height: container.height)
        }
        return CGSize(width: container.width, height: container.width / aspectRatio)
    }
}
