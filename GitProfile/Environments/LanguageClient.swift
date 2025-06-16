//
//  LanguageClient.swift
//  GitProfile
//
//  Created by Tien Nguyen on 15/6/25.
//

import Foundation
import LanguageManager_iOS

@MainActor
final class LanguageClient: ObservableObject {
    
    @Published private(set) var language: Languages = LanguageManager.shared.currentLanguage
    
    func localize(_ key: String) -> String {
        key.localiz()
    }
}
