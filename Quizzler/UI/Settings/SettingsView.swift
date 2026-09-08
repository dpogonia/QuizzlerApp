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
                                    title: QuizFormatters.duration(value),
                                    isSelected: viewModel.timer.selectedDuration == value
                                ) {
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
                                    themeController.select(theme)
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
