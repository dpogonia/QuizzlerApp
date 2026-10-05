//
//  RootView.swift
//  Quizzler
//
//  Created by Dmitrii Pogonia on 07.02.2026.
//

import SwiftUI

// RootView — вход. Сначала сплэш, потом меню в NavigationStack. Не содержит логики квиза.
struct RootView: View {
    @State private var showSplash = true

    var body: some View {
        Group {
            if showSplash {
                SplashView {
                    withAnimation(.easeInOut(duration: 0.35)) {
                        showSplash = false
                    }
                }
            } else {
                NavigationStack {
                    StartView()
                }
            }
        }
    }
}
