import Foundation
import QuizServices

enum QuizFormatters {
    static func scorePair(correct: Int, total: Int) -> String {
        decimal.locale = AppLocalization.locale
        return "\(decimal.string(from: NSNumber(value: correct)) ?? "\(correct)")/\(decimal.string(from: NSNumber(value: total)) ?? "\(total)")"
    }

    static func duration(_ seconds: Int) -> String {
        let measurement = Measurement(value: Double(seconds), unit: UnitDuration.seconds)
        durationFormatter.locale = AppLocalization.locale
        durationFormatter.numberFormatter.locale = AppLocalization.locale
        return durationFormatter.string(from: measurement)
    }

    private static let decimal: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = .current
        return formatter
    }()

    private static let durationFormatter: MeasurementFormatter = {
        let formatter = MeasurementFormatter()
        formatter.unitStyle = .short
        formatter.unitOptions = .providedUnit
        formatter.locale = .current
        formatter.numberFormatter.maximumFractionDigits = 0
        return formatter
    }()
}

extension GameMode {
    var localizedTitle: String {
        switch self {
        case .movies: return L10n.Mode.Movies.title
        case .rickAndMorty: return L10n.Mode.RickAndMorty.title
        case .southPark: return L10n.Mode.SouthPark.title
        case .bigMouth: return L10n.Mode.BigMouth.title
        case .humanResources: return L10n.Mode.HumanResources.title
        }
    }

    var localizedSubtitle: String {
        switch self {
        case .movies: return L10n.Mode.Movies.subtitle
        case .rickAndMorty: return L10n.Mode.RickAndMorty.subtitle
        case .southPark: return L10n.Mode.SouthPark.subtitle
        case .bigMouth: return L10n.Mode.BigMouth.subtitle
        case .humanResources: return L10n.Mode.HumanResources.subtitle
        }
    }
}

extension AppTheme {
    var localizedTitle: String {
        switch self {
        case .light: return L10n.Settings.Theme.light
        case .dark: return L10n.Settings.Theme.dark
        case .system: return L10n.Settings.Theme.system
        }
    }
}

extension AppLanguage {
    var localizedTitle: String {
        switch self {
        case .russian: return L10n.Settings.Language.russian
        case .english: return L10n.Settings.Language.english
        }
    }
}
