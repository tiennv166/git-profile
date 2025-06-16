//
//  UserDetailsView.swift
//  GitProfile
//
//  Created by Tien Nguyen on 15/6/25.
//

import SwiftUI
import GitProfileServices

struct UserDetailsView: View {
    
    @EnvironmentObject private var languageClient: LanguageClient
    
    @StateObject private var viewModel: UserDetailsViewModel
    
    init(username: String) {
        _viewModel = StateObject(wrappedValue: UserDetailsViewModel(username: username))
    }
    
    var body: some View {
        Group {
            switch viewModel.userDetails {
            case .nothing:
                UserDetailsLoadingView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
            case let .loading(user):
                if let user {
                    userDetailsView(user)
                } else {
                    UserDetailsLoadingView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                
            case .error:
                CommonErrorView {
                    Task { await viewModel.refresh(forced: true) }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
            case let .success(user):
                userDetailsView(user)
            }
        }
        .navigationTitle(languageClient.localize("user.details.view.title"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbarRole(.editor)
        .onAppear {
            Task { await viewModel.refresh(forced: false ) }
        }
    }
    
    @ViewBuilder
    private func userDetailsView(_ user: User) -> some View {
        ScrollView {
            VStack(spacing: 16) {
                UserCardView(user: user, shouldShowLocation: true)
                    .padding(.vertical, 4)
                
                HStack(spacing: 40) {
                    statItem(
                        icon: "person.2.fill",
                        countText: (user.followers ?? 0).formatFollowerCount,
                        label: languageClient.localize("user.details.view.follower")
                    )
                    statItem(
                        icon: "person.crop.circle.badge.checkmark",
                        countText: (user.following ?? 0).formatFollowerCount,
                        label: languageClient.localize("user.details.view.following")
                    )
                }
                
                // Bio section
                if let bio = user.bio, !bio.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(languageClient.localize("user.details.view.bio"))
                            .font(.headline)
                        
                        Text(bio)
                            .font(.subheadline)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                // Blog section
                if let blog = user.blog, !blog.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(languageClient.localize("user.details.view.blog"))
                            .font(.headline)
                        
                        Group {
                            if let link = URL(string: blog) {
                                Link(blog, destination: link)
                            } else {
                                Text(blog)
                            }
                        }
                        .font(.subheadline)
                        .foregroundColor(Color.blue)
                        .underline(true, color: .blue)
                        .lineLimit(1)
                        .truncationMode(.tail)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(.horizontal)
        }
        .refreshable {
            await viewModel.refresh(forced: true)
        }
    }
    
    @ViewBuilder
    private func statItem(icon: String, countText: String, label: String) -> some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .fill(Color(UIColor.systemGray6))
                    .frame(width: 60, height: 60)
                
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(.primary)
            }
            
            Text(countText)
                .font(.subheadline)
                .fontWeight(.semibold)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

private extension Int {
    var formatFollowerCount: String {
        switch self {
        case 0..<10:
            return "\(self)"
        case 10..<50:
            return "10+"
        case 50..<100:
            return "50+"
        case 100..<500:
            return "100+"
        case 500..<1_000:
            return "500+"
        case 1_000..<1_000_000:
            let value = Double(self) / 1_000
            return String(format: value.truncatingRemainder(dividingBy: 1) == 0 ? "%.0fK" : "%.1fK", value)
        default:
            let value = Double(self) / 1_000_000
            return String(format: value.truncatingRemainder(dividingBy: 1) == 0 ? "%.0fM" : "%.1fM", value)
        }
    }
}
