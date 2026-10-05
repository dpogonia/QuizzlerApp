//
//  Strings+Generated.swift
//  Quizzler
//
//  Created by Dmitrii Pogonia on 18.09.2026.
//

// Файл собирает SwiftGen из Quizzler/Resources/en.lproj/Localizable.strings (настройка в swiftgen.yml).

// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum L10n {
  internal enum Error {
    /// Couldn't find the character image.
    internal static var southParkImage: String { return L10n.tr("Localizable", "error.south_park_image", fallback: "Couldn't find the character image.") }
  }
  internal enum Game {
    /// Back to modes
    internal static var backToMenu: String { return L10n.tr("Localizable", "game.back_to_menu", fallback: "Back to modes") }
    /// Is this character’s name %@?
    internal static func characterNameQuestion(_ p1: Any) -> String {
      return L10n.tr("Localizable", "game.character_name_question", String(describing: p1), fallback: "Is this character’s name %@?")
    }
    /// Couldn't load data: %@
    internal static func loadError(_ p1: Any) -> String {
      return L10n.tr("Localizable", "game.load_error", String(describing: p1), fallback: "Couldn't load data: %@")
    }
    /// Loading question…
    internal static var loadingQuestion: String { return L10n.tr("Localizable", "game.loading_question", fallback: "Loading question…") }
    /// NO
    internal static var no: String { return L10n.tr("Localizable", "game.no", fallback: "NO") }
    /// Play again
    internal static var playAgain: String { return L10n.tr("Localizable", "game.play_again", fallback: "Play again") }
    /// This round is over!
    internal static var roundOver: String { return L10n.tr("Localizable", "game.round_over", fallback: "This round is over!") }
    /// Syncing with the server…
    internal static var syncing: String { return L10n.tr("Localizable", "game.syncing", fallback: "Syncing with the server…") }
    /// YES
    internal static var yes: String { return L10n.tr("Localizable", "game.yes", fallback: "YES") }
    /// Your score: %@
    internal static func yourResult(_ p1: Any) -> String {
      return L10n.tr("Localizable", "game.your_result", String(describing: p1), fallback: "Your score: %@")
    }
  }
  internal enum Mode {
    internal enum BigMouth {
      /// Hormones and monsters
      internal static var subtitle: String { return L10n.tr("Localizable", "mode.bigMouth.subtitle", fallback: "Hormones and monsters") }
      /// Big Mouth
      internal static var title: String { return L10n.tr("Localizable", "mode.bigMouth.title", fallback: "Big Mouth") }
    }
    internal enum HumanResources {
      /// Monster office
      internal static var subtitle: String { return L10n.tr("Localizable", "mode.humanResources.subtitle", fallback: "Monster office") }
      /// Human Resources
      internal static var title: String { return L10n.tr("Localizable", "mode.humanResources.title", fallback: "Human Resources") }
    }
    internal enum RickAndMorty {
      /// Wubba Lubba Dub-Dub
      internal static var subtitle: String { return L10n.tr("Localizable", "mode.rickAndMorty.subtitle", fallback: "Wubba Lubba Dub-Dub") }
      /// Rick and Morty
      internal static var title: String { return L10n.tr("Localizable", "mode.rickAndMorty.title", fallback: "Rick and Morty") }
    }
    internal enum SouthPark {
      /// Oh my God, they killed Kenny
      internal static var subtitle: String { return L10n.tr("Localizable", "mode.southPark.subtitle", fallback: "Oh my God, they killed Kenny") }
      /// South Park
      internal static var title: String { return L10n.tr("Localizable", "mode.southPark.title", fallback: "South Park") }
    }
  }
  internal enum Settings {
    /// Best score (%@): %@
    internal static func bestScore(_ p1: Any, _ p2: Any) -> String {
      return L10n.tr("Localizable", "settings.best_score", String(describing: p1), String(describing: p2), fallback: "Best score (%@): %@")
    }
    /// %ds
    internal static func durationChip(_ p1: Int) -> String {
      return L10n.tr("Localizable", "settings.duration_chip", p1, fallback: "%ds")
    }
    /// Vibrations
    internal static var haptics: String { return L10n.tr("Localizable", "settings.haptics", fallback: "Vibrations") }
    /// Feel the taps — and the last three seconds
    internal static var hapticsHint: String { return L10n.tr("Localizable", "settings.haptics_hint", fallback: "Feel the taps — and the last three seconds") }
    /// Language
    internal static var language: String { return L10n.tr("Localizable", "settings.language", fallback: "Language") }
    /// What language do you prefer?
    internal static var languageHint: String { return L10n.tr("Localizable", "settings.language_hint", fallback: "What language do you prefer?") }
    /// Plural format key: "No records for %#@seconds@"
    internal static func noRecords(_ p1: Int) -> String {
      return L10n.tr("Localizable", "settings.no_records", p1, fallback: "Plural format key: \"No records for %#@seconds@\"")
    }
    /// Records
    internal static var records: String { return L10n.tr("Localizable", "settings.records", fallback: "Records") }
    /// Sounds
    internal static var sounds: String { return L10n.tr("Localizable", "settings.sounds", fallback: "Sounds") }
    /// Clicks on taps and a loop during the round
    internal static var soundsHint: String { return L10n.tr("Localizable", "settings.sounds_hint", fallback: "Clicks on taps and a loop during the round") }
    /// Theme
    internal static var theme: String { return L10n.tr("Localizable", "settings.theme", fallback: "Theme") }
    /// Which side are you on?
    internal static var themeHint: String { return L10n.tr("Localizable", "settings.theme_hint", fallback: "Which side are you on?") }
    /// Difficulty
    internal static var timer: String { return L10n.tr("Localizable", "settings.timer", fallback: "Difficulty") }
    /// Choose how fast you're gonna lose
    internal static var timerHint: String { return L10n.tr("Localizable", "settings.timer_hint", fallback: "Choose how fast you're gonna lose") }
    /// Settings
    internal static var title: String { return L10n.tr("Localizable", "settings.title", fallback: "Settings") }
    internal enum Haptics {
      /// Off
      internal static var off: String { return L10n.tr("Localizable", "settings.haptics.off", fallback: "Off") }
      /// On
      internal static var on: String { return L10n.tr("Localizable", "settings.haptics.on", fallback: "On") }
    }
    internal enum Language {
      /// English
      internal static var english: String { return L10n.tr("Localizable", "settings.language.english", fallback: "English") }
      /// Russian
      internal static var russian: String { return L10n.tr("Localizable", "settings.language.russian", fallback: "Russian") }
    }
    internal enum Sounds {
      /// Off
      internal static var off: String { return L10n.tr("Localizable", "settings.sounds.off", fallback: "Off") }
      /// On
      internal static var on: String { return L10n.tr("Localizable", "settings.sounds.on", fallback: "On") }
    }
    internal enum Theme {
      /// Dark
      internal static var dark: String { return L10n.tr("Localizable", "settings.theme.dark", fallback: "Dark") }
      /// Light
      internal static var light: String { return L10n.tr("Localizable", "settings.theme.light", fallback: "Light") }
      /// System
      internal static var system: String { return L10n.tr("Localizable", "settings.theme.system", fallback: "System") }
    }
  }
  internal enum Splash {
    /// Continue
    internal static var `continue`: String { return L10n.tr("Localizable", "splash.continue", fallback: "Continue") }
    /// Couldn't preload quiz data:
    /// %@
    internal static func preloadError(_ p1: Any) -> String {
      return L10n.tr("Localizable", "splash.preload_error", String(describing: p1), fallback: "Couldn't preload quiz data:\n%@")
    }
    /// Retry
    internal static var retry: String { return L10n.tr("Localizable", "splash.retry", fallback: "Retry") }
  }
  internal enum Start {
    /// Cancel
    internal static var cancel: String { return L10n.tr("Localizable", "start.cancel", fallback: "Cancel") }
    /// Continue
    internal static var continueGame: String { return L10n.tr("Localizable", "start.continue_game", fallback: "Continue") }
    /// %@ · %@
    internal static func continueSubtitle(_ p1: Any, _ p2: Any) -> String {
      return L10n.tr("Localizable", "start.continue_subtitle", String(describing: p1), String(describing: p2), fallback: "%@ · %@")
    }
    /// Error
    internal static var errorTitle: String { return L10n.tr("Localizable", "start.error_title", fallback: "Error") }
    /// Couldn't load the data. Please try again.
    /// %@
    internal static func loadFailed(_ p1: Any) -> String {
      return L10n.tr("Localizable", "start.load_failed", String(describing: p1), fallback: "Couldn't load the data. Please try again.\n%@")
    }
    /// Loading...
    internal static var loading: String { return L10n.tr("Localizable", "start.loading", fallback: "Loading...") }
    /// OK
    internal static var ok: String { return L10n.tr("Localizable", "start.ok", fallback: "OK") }
    /// Continue
    internal static var resumeContinue: String { return L10n.tr("Localizable", "start.resume_continue", fallback: "Continue") }
    /// You already have an unfinished quiz in this mode. Continue it or start a new one?
    internal static var resumeMessage: String { return L10n.tr("Localizable", "start.resume_message", fallback: "You already have an unfinished quiz in this mode. Continue it or start a new one?") }
    /// Start new
    internal static var resumeNew: String { return L10n.tr("Localizable", "start.resume_new", fallback: "Start new") }
    /// Unfinished quiz
    internal static var resumeTitle: String { return L10n.tr("Localizable", "start.resume_title", fallback: "Unfinished quiz") }
    /// Settings
    internal static var settings: String { return L10n.tr("Localizable", "start.settings", fallback: "Settings") }
    /// Records, difficulty, theme, sounds, vibrations, language
    internal static var settingsSubtitle: String { return L10n.tr("Localizable", "start.settings_subtitle", fallback: "Records, difficulty, theme, sounds, vibrations, language") }
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg..., fallback value: String) -> String {
    let format = AppLocalization.string(forKey:table:fallback:)(key, table, value)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}
