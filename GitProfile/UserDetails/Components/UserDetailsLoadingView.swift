//
//  UserDetailsLoadingView.swift
//  GitProfile
//
//  Created by Tien Nguyen on 17/6/25.
//

import SkeletonUI
import SwiftUI

struct UserDetailsLoadingView: View {
    
    @State private var isLoading = true
    
    var body: some View {
        VStack(spacing: 8) {
            Color.secondary
                .skeleton(with: isLoading, shape: .rectangle)
                .frame(height: 110)
                .frame(maxWidth: .infinity)
                .cornerRadius(16)
                .padding(.vertical, 4)
            
            HStack(spacing: 40) {
                ForEach((1...2), id: \.self) { _ in
                    VStack(spacing: 4) {
                        Color.secondary
                            .skeleton(with: isLoading, shape: .circle)
                            .frame(width: 60, height: 60)
                        
                        Color.secondary
                            .skeleton(with: isLoading, shape: .rectangle)
                            .frame(width: 60, height: 16)
                            .cornerRadius(4)
                            .padding(.top, 4)
                        
                        Color.secondary
                            .skeleton(with: isLoading, shape: .rectangle)
                            .frame(width: 60, height: 14)
                            .cornerRadius(4)
                            .padding(.top, 4)
                    }
                }
            }
            
            HStack {
                Color.secondary
                    .skeleton(with: isLoading, shape: .rectangle)
                    .frame(width: 100, height: 16)
                    .cornerRadius(4)
                    .padding(.top, 20)
                
                Spacer()
            }
            
            HStack {
                Color.secondary
                    .skeleton(with: isLoading, shape: .rectangle)
                    .frame(width: 300, height: 16)
                    .cornerRadius(4)
                    .padding(.top, 4)
                
                Spacer()
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
