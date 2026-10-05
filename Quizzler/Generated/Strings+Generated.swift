//
//  Strings+Generated.swift
//  Quizzler
//
//  Created by Dmitrii Pogonia on 18.09.2026.
//

import Foundation

internal enum L10n {
  internal enum Error {

    internal static var southParkImage: String { return L10n.tr("Localizable", "error.south_park_image", fallback: "Couldn't find the character image.") }
  }
  internal enum Game {

    internal static var backToMenu: String { return L10n.tr("Localizable", "game.back_to_menu", fallback: "Back to modes") }

    internal static func characterNameQuestion(_ p1: Any) -> String {
      return L10n.tr("Localizable", "game.character_name_question", String(describing: p1), fallback: "Is this character’s name %@?")
    }

    internal static func loadError(_ p1: Any) -> String {
      return L10n.tr("Localizable", "game.load_error", String(describing: p1), fallback: "Couldn't load data: %@")
    }

    internal static var loadingQuestion: String { return L10n.tr("Localizable", "game.loading_question", fallback: "Loading question…") }

    internal static var no: String { return L10n.tr("Localizable", "game.no", fallback: "NO") }

    internal static var playAgain: String { return L10n.tr("Localizable", "game.play_again", fallback: "Play again") }

    internal static var roundOver: String { return L10n.tr("Localizable", "game.round_over", fallback: "This round is over!") }

    internal static var syncing: String { return L10n.tr("Localizable", "game.syncing", fallback: "Syncing with the server…") }

    internal static var yes: String { return L10n.tr("Localizable", "game.yes", fallback: "YES") }

    internal static func yourResult(_ p1: Any) -> String {
      return L10n.tr("Localizable", "game.your_result", String(describing: p1), fallback: "Your score: %@")
    }
  }
  internal enum Mode {
    internal enum BigMouth {

      internal static var subtitle: String { return L10n.tr("Localizable", "mode.bigMouth.subtitle", fallback: "Hormones and monsters") }

      internal static var title: String { return L10n.tr("Localizable", "mode.bigMouth.title", fallback: "Big Mouth") }
    }
    internal enum HumanResources {

      internal static var subtitle: String { return L10n.tr("Localizable", "mode.humanResources.subtitle", fallback: "Monster office") }

      internal static var title: String { return L10n.tr("Localizable", "mode.humanResources.title", fallback: "Human Resources") }
    }
    internal enum RickAndMorty {

      internal static var subtitle: String { return L10n.tr("Localizable", "mode.rickAndMorty.subtitle", fallback: "Wubba Lubba Dub-Dub") }

      internal static var title: String { return L10n.tr("Localizable", "mode.rickAndMorty.title", fallback: "Rick and Morty") }
    }
    internal enum SouthPark {

      internal static var subtitle: String { return L10n.tr("Localizable", "mode.southPark.subtitle", fallback: "Oh my God, they killed Kenny") }

      internal static var title: String { return L10n.tr("Localizable", "mode.southPark.title", fallback: "South Park") }
    }
  }
  internal enum Settings {

    internal static func bestScore(_ p1: Any, _ p2: Any) -> String {
      return L10n.tr("Localizable", "settings.best_score", String(describing: p1), String(describing: p2), fallback: "Best score (%@): %@")
    }

    internal static func durationChip(_ p1: Int) -> String {
      return L10n.tr("Localizable", "settings.duration_chip", p1, fallback: "%ds")
    }

    internal static var haptics: String { return L10n.tr("Localizable", "settings.haptics", fallback: "Vibrations") }

    internal static var hapticsHint: String { return L10n.tr("Localizable", "settings.haptics_hint", fallback: "Feel the taps — and the last three seconds") }

    internal static var language: String { return L10n.tr("Localizable", "settings.language", fallback: "Language") }

    internal static var languageHint: String { return L10n.tr("Localizable", "settings.language_hint", fallback: "What language do you prefer?") }

    internal static func noRecords(_ p1: Int) -> String {
      return L10n.tr("Localizable", "settings.no_records", p1, fallback: "Plural format key: \"No records for %#@seconds@\"")
    }

    internal static var records: String { return L10n.tr("Localizable", "settings.records", fallback: "Records") }

    internal static var sounds: String { return L10n.tr("Localizable", "settings.sounds", fallback: "Sounds") }

    internal static var soundsHint: String { return L10n.tr("Localizable", "settings.sounds_hint", fallback: "Clicks on taps and a loop during the round") }

    internal static var theme: String { return L10n.tr("Localizable", "settings.theme", fallback: "Theme") }

    internal static var themeHint: String { return L10n.tr("Localizable", "settings.theme_hint", fallback: "Which side are you on?") }

    internal static var timer: String { return L10n.tr("Localizable", "settings.timer", fallback: "Difficulty") }

    internal static var timerHint: String { return L10n.tr("Localizable", "settings.timer_hint", fallback: "Choose how fast you're gonna lose") }

    internal static var title: String { return L10n.tr("Localizable", "settings.title", fallback: "Settings") }
    internal enum Haptics {

      internal static var off: String { return L10n.tr("Localizable", "settings.haptics.off", fallback: "Off") }

      internal static var on: String { return L10n.tr("Localizable", "settings.haptics.on", fallback: "On") }
    }
    internal enum Language {

      internal static var english: String { return L10n.tr("Localizable", "settings.language.english", fallback: "English") }

      internal static var russian: String { return L10n.tr("Localizable", "settings.language.russian", fallback: "Russian") }
    }
    internal enum Sounds {

      internal static var off: String { return L10n.tr("Localizable", "settings.sounds.off", fallback: "Off") }

      internal static var on: String { return L10n.tr("Localizable", "settings.sounds.on", fallback: "On") }
    }
    internal enum Theme {

      internal static var dark: String { return L10n.tr("Localizable", "settings.theme.dark", fallback: "Dark") }

      internal static var light: String { return L10n.tr("Localizable", "settings.theme.light", fallback: "Light") }

      internal static var system: String { return L10n.tr("Localizable", "settings.theme.system", fallback: "System") }
    }
  }
  internal enum Splash {

    internal static var `continue`: String { return L10n.tr("Localizable", "splash.continue", fallback: "Continue") }


    internal static func preloadError(_ p1: Any) -> String {
      return L10n.tr("Localizable", "splash.preload_error", String(describing: p1), fallback: "Couldn't preload quiz data:\n%@")
    }

    internal static var retry: String { return L10n.tr("Localizable", "splash.retry", fallback: "Retry") }
  }
  internal enum Start {

    internal static var cancel: String { return L10n.tr("Localizable", "start.cancel", fallback: "Cancel") }

    internal static var continueGame: String { return L10n.tr("Localizable", "start.continue_game", fallback: "Continue") }

    internal static func continueSubtitle(_ p1: Any, _ p2: Any) -> String {
      return L10n.tr("Localizable", "start.continue_subtitle", String(describing: p1), String(describing: p2), fallback: "%@ · %@")
    }

    internal static var errorTitle: String { return L10n.tr("Localizable", "start.error_title", fallback: "Error") }


    internal static func loadFailed(_ p1: Any) -> String {
      return L10n.tr("Localizable", "start.load_failed", String(describing: p1), fallback: "Couldn't load the data. Please try again.\n%@")
    }

    internal static var loading: String { return L10n.tr("Localizable", "start.loading", fallback: "Loading...") }

    internal static var ok: String { return L10n.tr("Localizable", "start.ok", fallback: "OK") }

    internal static var resumeContinue: String { return L10n.tr("Localizable", "start.resume_continue", fallback: "Continue") }

    internal static var resumeMessage: String { return L10n.tr("Localizable", "start.resume_message", fallback: "You already have an unfinished quiz in this mode. Continue it or start a new one?") }

    internal static var resumeNew: String { return L10n.tr("Localizable", "start.resume_new", fallback: "Start new") }

    internal static var resumeTitle: String { return L10n.tr("Localizable", "start.resume_title", fallback: "Unfinished quiz") }

    internal static var settings: String { return L10n.tr("Localizable", "start.settings", fallback: "Settings") }

    internal static var settingsSubtitle: String { return L10n.tr("Localizable", "start.settings_subtitle", fallback: "Records, difficulty, theme, sounds, vibrations, language") }
  }
}

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg..., fallback value: String) -> String {
    let format = AppLocalization.string(forKey:table:fallback:)(key, table, value)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}
