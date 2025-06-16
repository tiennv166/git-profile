//
//  UserCardView.swift
//  GitProfile
//
//  Created by Tien Nguyen on 16/6/25.
//

import SwiftUI
import GitProfileServices

struct UserCardView: View {
    
    private let user: User
    private let shouldShowLocation: Bool
    private let shouldShowHtmlUrl: Bool
    
    init(user: User, shouldShowLocation: Bool = false, shouldShowHtmlUrl: Bool = false) {
        self.user = user
        self.shouldShowLocation = shouldShowLocation
        self.shouldShowHtmlUrl = shouldShowHtmlUrl
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.secondary.opacity(0.16))
                    .frame(width: 86, height: 86)
                
                CommonImageView(user.avatarUrl)
                    .frame(width: 75, height: 75)
                    .clipShape(Circle())
            }
            .frame(width: 86, height: 86)
            
            VStack(alignment: .leading, spacing: 10) {
                Text(user.login)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color.primary)
                
                Divider()
                
                if shouldShowLocation, let location = user.location {
                    Label(location, systemImage: "location.circle")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                if shouldShowHtmlUrl, let htmlUrl = user.htmlUrl {
                    Text(htmlUrl)
                        .font(.system(size: 13))
                        .foregroundColor(Color.blue)
                        .underline(true, color: .blue)
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .onTapGesture {
                            guard let link = URL(string: htmlUrl) else { return }
                            UIApplication.shared.open(link)
                        }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 8)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.secondary.opacity(0.24), radius: 6, x: 1, y: 2)
        )
    }
}
