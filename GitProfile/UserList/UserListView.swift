//
//  UserListView.swift
//  GitProfile
//
//  Created by Tien Nguyen on 14/6/25.
//

import SwiftUI
import GitProfileServices

struct UserListView: View {
    
    @EnvironmentObject private var navManager: NavigationManager
    @EnvironmentObject private var languageClient: LanguageClient
    
    @StateObject private var viewModel = UserListViewModel()
    
    var body: some View {
        NavigationStack(path: $navManager.navPath) {
            Group {
                switch viewModel.users {
                case .nothing:
                    UserListLoadingView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                case let .loading(users):
                    if let users, !users.isEmpty {
                        userListView(users)
                    } else {
                        UserListLoadingView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    
                case .error:
                    CommonErrorView {
                        Task { await viewModel.refresh(forced: true) }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                case let .success(users):
                    userListView(users)
                }
            }
            .navigationTitle(languageClient.localize("user.list.view.title"))
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: NavDestination.self) { $0.content }
        }
        .onAppear {
            Task { await viewModel.refresh(forced: false) }
        }
    }
    
    @ViewBuilder
    private func userListView(_ users: [User]) -> some View {
        if users.isEmpty {
            CommonEmptyView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(users) { user in
                        userRow(user)
                            .onAppear {
                                viewModel.loadMoreIfNeeded(currentUser: user)
                            }
                    }
                    
                    if viewModel.isLoadingMore {
                        ProgressView()
                            .padding()
                    }
                }
                .padding(.top, 8)
            }
            .refreshable {
                await viewModel.refresh(forced: true)
            }
        }
    }
    
    private func userRow(_ user: User) -> some View {
        Button {
            navManager.push(destination: .userDetails(user.login))
        } label: {
            UserCardView(user: user, shouldShowHtmlUrl: true)
                .padding(.horizontal)
                .padding(.vertical, 4)
        }
    }
}
