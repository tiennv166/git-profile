//
//  CommonErrorView.swift
//  GitProfile
//
//  Created by Tien Nguyen on 15/6/25.
//

import SwiftUI

struct CommonErrorView: View {
    
    @EnvironmentObject private var languageClient: LanguageClient
    
    let onRetry: (() -> Void)
    
    var body: some View {
        VStack(spacing: 12) {
            Spacer()
            
            Text(languageClient.localize("common.error.title"))
                .font(
                    .system(size: 16)
                    .weight(.semibold)
                )
                .padding(.top, 24)
            
            Text(languageClient.localize("common.error.description"))
                .font(
                    .system(size: 15)
                    .weight(.regular)
                )
                .foregroundColor(.secondary)
            
            Button {
                onRetry()
            } label: {
                Text(languageClient.localize("retry"))
                    .font(
                        .system(size: 16)
                        .weight(.semibold)
                    )
                    .frame(minWidth: 168)
                    .padding()
            }
            .tint(.primary)
            .frame(height: 44)
            .overlay(RoundedRectangle(cornerRadius: 22).stroke(.secondary, lineWidth: 2))
            .cornerRadius(22)
            .padding(.top)
            
            Spacer()
        }
        .padding(.horizontal, 16)
    }
}
