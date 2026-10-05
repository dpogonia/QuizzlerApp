//
//  SettingsView.swift
//  Quizzler
//
//  Created by Dmitrii Pogonia on 20.06.2026.
//

import QuizServices
import QuizUI
import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var environment: AppEnvironment
    @EnvironmentObject private var themeController: ThemeController

    var body: some View {
        SettingsScreen(
            viewModel: SettingsViewModel(
                scoreStore: environment.scoreStore,
                timerSettings: environment.timerSettings
            )
        )
    }
}

private struct SettingsScreen: View {
    @StateObject private var viewModel: SettingsViewModel
    @EnvironmentObject private var themeController: ThemeController
    @EnvironmentObject private var languageController: LanguageController
    @EnvironmentObject private var feedback: FeedbackController

    init(viewModel: SettingsViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: QuizSpacing.section) {
                QuizSectionTitle(L10n.Settings.records)

                ForEach(GameMode.allCases, id: \.self) { mode in
                    QuizInfoCard(
                        title: mode.localizedTitle,
                        subtitle: viewModel.records.recordText(for: mode)
                    )
                }

                SectionCard(title: L10n.Settings.timer) {
                    VStack(alignment: .leading, spacing: QuizSpacing.compact) {
                        QuizHintText(L10n.Settings.timerHint)

                        HStack(spacing: QuizSpacing.compact) {
                            ForEach(viewModel.timer.availableDurations, id: \.self) { value in
                                ChipButton(
                                    title: L10n.Settings.durationChip(value),
                                    isSelected: viewModel.timer.selectedDuration == value
                                ) {
                                    feedback.playSelection()
                                    viewModel.timer.selectDuration(value)
                                }
                            }
                        }
                    }
                }

                SectionCard(title: L10n.Settings.theme) {
                    VStack(alignment: .leading, spacing: QuizSpacing.compact) {
                        QuizHintText(L10n.Settings.themeHint)

                        HStack(spacing: QuizSpacing.compact) {
                            ForEach(Array(AppTheme.allCases), id: \.self) { theme in
                                ChipButton(
                                    title: theme.localizedTitle,
                                    isSelected: themeController.current == theme
                                ) {
                                    feedback.playSelection()
                                    themeController.select(theme)
                                }
                            }
                        }
                    }
                }

                SectionCard(title: L10n.Settings.sounds) {
                    VStack(alignment: .leading, spacing: QuizSpacing.compact) {
                        QuizHintText(L10n.Settings.soundsHint)

                        HStack(spacing: QuizSpacing.compact) {
                            ChipButton(
                                title: L10n.Settings.Sounds.on,
                                isSelected: feedback.sounds.isEnabled
                            ) {
                                feedback.haptics.playSelection()
                                feedback.sounds.select(true)
                            }
                            ChipButton(
                                title: L10n.Settings.Sounds.off,
                                isSelected: !feedback.sounds.isEnabled
                            ) {
                                feedback.haptics.playSelection()
                                feedback.sounds.select(false)
                            }
                        }
                    }
                }

                SectionCard(title: L10n.Settings.haptics) {
                    VStack(alignment: .leading, spacing: QuizSpacing.compact) {
                        QuizHintText(L10n.Settings.hapticsHint)

                        HStack(spacing: QuizSpacing.compact) {
                            ChipButton(
                                title: L10n.Settings.Haptics.on,
                                isSelected: feedback.haptics.isEnabled
                            ) {
                                feedback.sounds.playSelection()
                                feedback.haptics.select(true)
                            }
                            ChipButton(
                                title: L10n.Settings.Haptics.off,
                                isSelected: !feedback.haptics.isEnabled
                            ) {
                                feedback.sounds.playSelection()
                                feedback.haptics.select(false)
                            }
                        }
                    }
                }

                SectionCard(title: L10n.Settings.language) {
                    VStack(alignment: .leading, spacing: QuizSpacing.compact) {
                        QuizHintText(L10n.Settings.languageHint)

                        HStack(spacing: QuizSpacing.compact) {
                            ForEach(Array(AppLanguage.allCases), id: \.self) { language in
                                ChipButton(
                                    title: language.localizedTitle,
                                    isSelected: languageController.current == language
                                ) {
                                    feedback.playSelection()
                                    languageController.select(language)
                                }
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, QuizSpacing.screen)
            .padding(.vertical, 24)
        }
        .background(QuizColor.screenBackground)
        .navigationTitle(L10n.Settings.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.visible, for: .navigationBar)
    }
}
