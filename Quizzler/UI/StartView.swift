import SwiftUI

struct StartView: View {
    @StateObject private var viewModel = StartViewModel()
    @State private var showSettings = false

    var body: some View {
        VStack(spacing: 0) {
            Image(systemName: "popcorn.fill")
                .font(.system(size: 88, weight: .bold))
                .foregroundStyle(Color.primary)
                .frame(width: 104, height: 104)
                .padding(.top, 24)

            Text(viewModel.bestResultText)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(Color.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.top, 8)

            VStack(spacing: 16) {
                ForEach(viewModel.modes, id: \.self) { mode in
                    ModeCardView(
                        symbolName: mode.symbolName,
                        title: mode.title,
                        subtitle: mode.description,
                        isDimmed: viewModel.isLoading,
                        showsSpinner: viewModel.loadingMode == mode
                    ) {
                        viewModel.select(mode)
                    }
                }

                ModeCardView(
                    symbolName: "gearshape",
                    title: "Settings",
                    subtitle: "Рекорды, таймер, тема",
                    isDimmed: viewModel.isLoading
                ) {
                    showSettings = true
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 24)
            .allowsHitTesting(!viewModel.isLoading)

            if viewModel.isLoading {
                ProgressView()
                    .padding(.top, 24)
                Text("Loading...")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(Color.secondary)
                    .padding(.top, 8)
            }

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            viewModel.onAppear()
        }
        .navigationDestination(isPresented: $showSettings) {
            SettingsView()
        }
        .navigationDestination(isPresented: $viewModel.navigateToGame) {
            if let session = viewModel.session {
                GameView(viewModel: session)
            }
        }
        .alert("Ошибка", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }
}
