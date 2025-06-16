//
//  RootView.swift
//  GitProfile
//
//  Created by Tien Nguyen on 14/6/25.
//

import SwiftUI

struct RootView: View {
    
    @StateObject private var languageClient = LanguageClient()
    @StateObject private var navManager = NavigationManager()
    
    var body: some View {
        navManager.currentRoot.content
            .preferredColorScheme(.light)
            .accentColor(.primary)
            .environmentObject(navManager)
            .environmentObject(languageClient)
    }
}
