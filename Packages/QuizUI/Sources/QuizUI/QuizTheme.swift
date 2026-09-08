import SwiftUI

public enum QuizColor {
    public static let screenBackground = Color(.systemBackground)
    public static let cardBackground = Color(.secondarySystemBackground)
    public static let chipIdle = Color(.tertiarySystemBackground)
    public static let chipSelected = Color(.systemGray)
    public static let primaryText = Color.primary
    public static let secondaryText = Color.secondary
    public static let inverseText = Color(.systemBackground)
    public static let onSelectedChip = Color.white
    public static let posterBackground = Color.black
    public static let splashBackground = Color.black
    public static let splashIcon = Color.white
    public static let posterBorder = Color.white
    public static let success = Color(.systemGreen)
    public static let danger = Color(.systemRed)
    public static let warning = Color(.systemYellow)
}

public enum QuizFont {
    public static let heroIcon = Font.system(size: 88, weight: .bold)
    public static let splashIcon = Font.system(size: 125, weight: .bold)
    public static let screenTitle = Font.system(size: 20, weight: .semibold)
    public static let cardTitle = Font.system(size: 20, weight: .semibold)
    public static let question = Font.system(size: 20, weight: .bold)
    public static let header = Font.system(size: 22, weight: .bold)
    public static let answer = Font.system(size: 20, weight: .bold)
    public static let recordTitle = Font.system(size: 17, weight: .semibold)
    public static let bestScore = Font.system(size: 16, weight: .medium)
    public static let body = Font.system(size: 15, weight: .regular)
    public static let bodySemibold = Font.system(size: 15, weight: .semibold)
    public static let caption = Font.system(size: 14, weight: .regular)
    public static let symbol = Font.system(size: 20, weight: .regular)
    public static let backSymbol = Font.system(size: 20, weight: .semibold)
}

public enum QuizRadius {
    public static let card: CGFloat = 16
    public static let row: CGFloat = 12
    public static let chip: CGFloat = 10
    public static let poster: CGFloat = 20
    public static let answer: CGFloat = 20
}

public enum QuizSpacing {
    public static let screen: CGFloat = 20
    public static let stack: CGFloat = 16
    public static let section: CGFloat = 12
    public static let compact: CGFloat = 8
    public static let tight: CGFloat = 4
}

public enum SFSymbol {
    public static let popcorn = "popcorn.fill"
    public static let film = "film"
    public static let atom = "atom"
    public static let mountain = "mountain.2"
    public static let smiling = "face.smiling"
    public static let people = "person.2"
    public static let gear = "gearshape"
    public static let back = "chevron.left"
}
