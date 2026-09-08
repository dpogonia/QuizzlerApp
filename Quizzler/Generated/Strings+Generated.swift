// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name
internal enum L10n {
  internal enum Error {
    /// Couldn't find the character image.
    internal static let southParkImage = L10n.tr("Localizable", "error.south_park_image", fallback: "Couldn't find the character image.")
  }
  internal enum Game {
    /// Back to modes
    internal static let backToMenu = L10n.tr("Localizable", "game.back_to_menu", fallback: "Back to modes")
    /// Is this character’s name %@?
    internal static func characterNameQuestion(_ p1: Any) -> String {
      return L10n.tr("Localizable", "game.character_name_question", String(describing: p1), fallback: "Is this character’s name %@?")
    }
    /// Couldn't load data: %@
    internal static func loadError(_ p1: Any) -> String {
      return L10n.tr("Localizable", "game.load_error", String(describing: p1), fallback: "Couldn't load data: %@")
    }
    /// Loading question…
    internal static let loadingQuestion = L10n.tr("Localizable", "game.loading_question", fallback: "Loading question…")
    /// Is this movie rated higher than 6?
    internal static let movieRatingQuestion = L10n.tr("Localizable", "game.movie_rating_question", fallback: "Is this movie rated higher than 6?")
    /// NO
    internal static let no = L10n.tr("Localizable", "game.no", fallback: "NO")
    /// Play again
    internal static let playAgain = L10n.tr("Localizable", "game.play_again", fallback: "Play again")
    /// This round is over!
    internal static let roundOver = L10n.tr("Localizable", "game.round_over", fallback: "This round is over!")
    /// Syncing with the server…
    internal static let syncing = L10n.tr("Localizable", "game.syncing", fallback: "Syncing with the server…")
    /// YES
    internal static let yes = L10n.tr("Localizable", "game.yes", fallback: "YES")
    /// Your score: %@
    internal static func yourResult(_ p1: Any) -> String {
      return L10n.tr("Localizable", "game.your_result", String(describing: p1), fallback: "Your score: %@")
    }
  }
  internal enum Mode {
    internal enum BigMouth {
      /// Hormones and monsters
      internal static let subtitle = L10n.tr("Localizable", "mode.bigMouth.subtitle", fallback: "Hormones and monsters")
      /// Big Mouth
      internal static let title = L10n.tr("Localizable", "mode.bigMouth.title", fallback: "Big Mouth")
    }
    internal enum HumanResources {
      /// Monster office
      internal static let subtitle = L10n.tr("Localizable", "mode.humanResources.subtitle", fallback: "Monster office")
      /// Human Resources
      internal static let title = L10n.tr("Localizable", "mode.humanResources.title", fallback: "Human Resources")
    }
    internal enum Movies {
      /// Guess the movie rating
      internal static let subtitle = L10n.tr("Localizable", "mode.movies.subtitle", fallback: "Guess the movie rating")
      /// IMDb Ratings
      internal static let title = L10n.tr("Localizable", "mode.movies.title", fallback: "IMDb Ratings")
    }
    internal enum RickAndMorty {
      /// Wubba Lubba Dub-Dub
      internal static let subtitle = L10n.tr("Localizable", "mode.rickAndMorty.subtitle", fallback: "Wubba Lubba Dub-Dub")
      /// Rick and Morty
      internal static let title = L10n.tr("Localizable", "mode.rickAndMorty.title", fallback: "Rick and Morty")
    }
    internal enum SouthPark {
      /// Oh my God, they killed Kenny
      internal static let subtitle = L10n.tr("Localizable", "mode.southPark.subtitle", fallback: "Oh my God, they killed Kenny")
      /// South Park
      internal static let title = L10n.tr("Localizable", "mode.southPark.title", fallback: "South Park")
    }
  }
  internal enum Settings {
    /// Best score (%@): %@
    internal static func bestScore(_ p1: Any, _ p2: Any) -> String {
      return L10n.tr("Localizable", "settings.best_score", String(describing: p1), String(describing: p2), fallback: "Best score (%@): %@")
    }
    /// No records for %#@seconds@
    internal static func noRecords(_ p1: Int) -> String {
      return L10n.tr("Localizable", "settings.no_records", p1, fallback: "No records for %#@seconds@")
    }
    /// Records
    internal static let records = L10n.tr("Localizable", "settings.records", fallback: "Records")
    /// Theme
    internal static let theme = L10n.tr("Localizable", "settings.theme", fallback: "Theme")
    /// Which side are you on
    internal static let themeHint = L10n.tr("Localizable", "settings.theme_hint", fallback: "Which side are you on")
    /// Timer
    internal static let timer = L10n.tr("Localizable", "settings.timer", fallback: "Timer")
    /// How many seconds before you lose
    internal static let timerHint = L10n.tr("Localizable", "settings.timer_hint", fallback: "How many seconds before you lose")
    /// Settings
    internal static let title = L10n.tr("Localizable", "settings.title", fallback: "Settings")
    internal enum Theme {
      /// Dark
      internal static let dark = L10n.tr("Localizable", "settings.theme.dark", fallback: "Dark")
      /// Light
      internal static let light = L10n.tr("Localizable", "settings.theme.light", fallback: "Light")
      /// System
      internal static let system = L10n.tr("Localizable", "settings.theme.system", fallback: "System")
    }
  }
  internal enum Start {
    /// Best: %@ — %@
    internal static func bestScore(_ p1: Any, _ p2: Any) -> String {
      return L10n.tr("Localizable", "start.best_score", String(describing: p1), String(describing: p2), fallback: "Best: %@ — %@")
    }
    /// Error
    internal static let errorTitle = L10n.tr("Localizable", "start.error_title", fallback: "Error")
    /// Couldn't load the data. Please try again.\n%@
    internal static func loadFailed(_ p1: Any) -> String {
      return L10n.tr("Localizable", "start.load_failed", String(describing: p1), fallback: "Couldn't load the data. Please try again.\n%@")
    }
    /// Loading...
    internal static let loading = L10n.tr("Localizable", "start.loading", fallback: "Loading...")
    /// OK
    internal static let ok = L10n.tr("Localizable", "start.ok", fallback: "OK")
    /// Settings
    internal static let settings = L10n.tr("Localizable", "start.settings", fallback: "Settings")
    /// Records, timer, theme
    internal static let settingsSubtitle = L10n.tr("Localizable", "start.settings_subtitle", fallback: "Records, timer, theme")
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg..., fallback value: String) -> String {
    let format = BundleToken.bundle.localizedString(forKey: key, value: value, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
