//
//  Array+Extension.swift
//  GitProfile
//
//  Created by Tien Nguyen on 15/6/25.
//

import Foundation

extension Array {
    /// Safely accesses the element at the specified index.
    ///
    /// - Parameter index: The index of the element to retrieve.
    /// - Returns: The element at the given index if it exists, otherwise `nil`.
    ///
    /// This helps avoid index out-of-bounds crashes by returning `nil`
    /// when the index is outside the array’s bounds.
    func safe(_ index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

extension Sequence where Element: Identifiable {
    /// Returns an array with duplicates (based on `id`) removed, preserving the original order.
    func uniqued() -> [Element] {
        var seen = Set<Element.ID>()
        return self.filter { seen.insert($0.id).inserted }
    }
}
