//
//  UserListLoadingView.swift
//  GitProfile
//
//  Created by Tien Nguyen on 16/6/25.
//

import SkeletonUI
import SwiftUI

struct UserListLoadingView: View {
    
    @State private var isLoading = true
    
    var body: some View {
        VStack(spacing: 8) {
            ForEach((1...4), id: \.self) { _ in
                Color.secondary
                    .skeleton(with: isLoading, shape: .rectangle)
                    .frame(height: 110)
                    .frame(maxWidth: .infinity)
                    .cornerRadius(16)
                    .padding(.vertical, 4)
            }
            
            Spacer()
        }
        .padding(.top, 8)
        .padding(.horizontal)
        .onAppear {
            isLoading = true
        }
        .onDisappear {
            isLoading = false
        }
    }
}
