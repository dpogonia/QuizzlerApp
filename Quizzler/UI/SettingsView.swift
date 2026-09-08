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
            VStack(alignment: .leading, spacing: 12) {
                Text("Рекорды")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(Color.primary)

                ForEach(GameMode.allCases, id: \.self) { mode in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(mode.title)
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(Color.primary)
                        Text(viewModel.records.recordText(for: mode))
                            .font(.system(size: 15, weight: .regular))
                            .foregroundStyle(Color.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }

                SectionCard(title: "Таймер") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("За сколько секунд ты готов проиграть")
                            .font(.system(size: 15, weight: .regular))
                            .foregroundStyle(Color.secondary)

                        HStack(spacing: 8) {
                            ForEach(viewModel.timer.availableDurations, id: \.self) { value in
                                ChipButton(
                                    title: "\(value)",
                                    isSelected: viewModel.timer.selectedDuration == value
                                ) {
                                    viewModel.timer.selectDuration(value)
                                }
                            }
                        }
                    }
                }

                SectionCard(title: "Тема") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("На чьей стороне ты")
                            .font(.system(size: 15, weight: .regular))
                            .foregroundStyle(Color.secondary)

                        HStack(spacing: 8) {
                            ForEach(Array(AppTheme.allCases), id: \.self) { theme in
                                ChipButton(
                                    title: theme.title,
                                    isSelected: themeController.current == theme
                                ) {
                                    themeController.select(theme)
                                }
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 24)
        }
        .background(Color(.systemBackground))
        .navigationTitle("Настройки")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.visible, for: .navigationBar)
    }
}
