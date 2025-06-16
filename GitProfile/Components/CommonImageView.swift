//
//  CommonImageView.swift
//  GitProfile
//
//  Created by Tien Nguyen on 15/6/25.
//

import Kingfisher
import SkeletonUI
import SwiftUI

struct CommonImageView: View {
    
    private let url: URL?
    
    init(_ url: URL?) {
        self.url = url
    }
    
    init(_ urlString: String?) {
        self.url = urlString.flatMap { URL(string: $0) }
    }
    
    var body: some View {
        GeometryReader { proxy in
            KFImage(url)
                .placeholder {
                    Color.secondary
                        .skeleton(with: true, size: proxy.size, shape: .rectangle)
                        .frame(width: proxy.size.width, height: proxy.size.height)
                }
                .cancelOnDisappear(true)
                .startLoadingBeforeViewAppear(true)
                .loadDiskFileSynchronously()
                .fade(duration: 0.25)
                .resizable()
                .scaledToFill()
                .frame(width: proxy.size.width, height: proxy.size.height)
        }
    }
}
