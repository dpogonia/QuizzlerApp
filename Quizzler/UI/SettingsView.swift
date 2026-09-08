import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @EnvironmentObject private var themeController: ThemeController

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                sectionTitle("Рекорды")

                ForEach(GameMode.allCases, id: \.self) { mode in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(mode.title)
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(Color.primary)
                        Text(viewModel.recordText(for: mode))
                            .font(.system(size: 15, weight: .regular))
                            .foregroundStyle(Color.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }

                sectionTitle("Таймер")
                    .padding(.top, 8)

                VStack(alignment: .leading, spacing: 8) {
                    Text("За сколько секунд ты готов проиграть")
                        .font(.system(size: 15, weight: .regular))
                        .foregroundStyle(Color.secondary)

                    HStack(spacing: 8) {
                        ForEach(viewModel.availableDurations, id: \.self) { value in
                            chipButton(
                                title: "\(value)",
                                isSelected: viewModel.selectedDuration == value
                            ) {
                                viewModel.selectDuration(value)
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                sectionTitle("Тема")
                    .padding(.top, 8)

                VStack(alignment: .leading, spacing: 8) {
                    Text("На чьей стороне ты")
                        .font(.system(size: 15, weight: .regular))
                        .foregroundStyle(Color.secondary)

                    HStack(spacing: 8) {
                        ForEach(Array(AppTheme.allCases), id: \.self) { theme in
                            chipButton(
                                title: theme.title,
                                isSelected: themeController.current == theme
                            ) {
                                themeController.select(theme)
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 24)
        }
        .background(Color(.systemBackground))
        .navigationTitle("Настройки")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.visible, for: .navigationBar)
    }

    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 20, weight: .semibold))
            .foregroundStyle(Color.primary)
    }

    private func chipButton(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(isSelected ? Color.white : Color.primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(isSelected ? Color(.systemGray) : Color(.tertiarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}
