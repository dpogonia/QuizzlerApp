import SwiftUI
import UIKit

public struct PosterFrameView: View {
    let image: UIImage?
    let fillContent: Bool
    let borderColor: Color
    let isLoading: Bool

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
        ZStack {
            Color.black
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: fillContent ? .fill : .fit)
            }
            if isLoading {
                ProgressView()
                    .controlSize(.large)
                    .tint(Color.primary)
            }
        }
        .aspectRatio(2 / 3, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(borderColor, lineWidth: 16)
        }
    }
}
