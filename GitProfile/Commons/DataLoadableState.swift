//
//  DataLoadableState.swift
//  GitProfile
//
//  Created by Tien Nguyen on 15/6/25.
//

import Foundation

/// Represents the state of a loadable data operation, such as fetching from API or cache.
enum DataLoadableState<T: Equatable & Sendable>: Equatable, Sendable {
    
    /// No data has been loaded yet.
    case nothing

    /// Data is currently loading.
    /// - Parameter data: Optional previous data (e.g. cached or partially loaded data).
    case loading(data: T?)

    /// Data was successfully loaded.
    /// - Parameter data: The final loaded data.
    case success(data: T)

    /// An error occurred while loading data.
    case error
}

extension DataLoadableState {
    
    /// Returns the associated data if available (from `.success` or `.loading`), otherwise nil.
    var data: T? {
        switch self {
        case let .success(data): return data
        case let .loading(data): return data
        default: return nil
        }
    }

    /// Returns `true` if the state is `.loading`, otherwise `false`.
    var isLoading: Bool {
        switch self {
        case .loading: return true
        default: return false
        }
    }
}
