//
//  CommonEmptyView.swift
//  GitProfile
//
//  Created by Tien Nguyen on 15/6/25.
//

import SwiftUI

struct CommonEmptyView: View {
    
    @EnvironmentObject private var languageClient: LanguageClient
    
    var body: some View {
        VStack {
            Spacer()
            
            Text(languageClient.localize("common.empty.title"))
                .font(
                    .system(size: 16)
                    .weight(.semibold)
                )
                .foregroundColor(.secondary)
                .padding(.top)
            
            Spacer()
        }
        .padding(.horizontal, 16)
    }
}
