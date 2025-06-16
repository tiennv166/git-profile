//
//  MockSessionTask.swift
//  GitProfile
//
//  Created by Tien Nguyen on 14/6/25.
//

import APIKit
import Foundation

final class MockSessionTask: SessionTask {

    private let handler: (Data?, URLResponse?, Error?) -> Void
    private var cancelled = false
    private let data: Data?
    private let urlResponse: URLResponse?
    private let error: Error?

    init(data: Data?, urlResponse: URLResponse?, error: Error?, handler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        self.data = data
        self.urlResponse = urlResponse
        self.error = error
        self.handler = handler
    }

    func resume() {
        if cancelled {
            handler(nil, nil, MockAPIKitAdapter.Error.cancelled)
        } else {
            handler(data, urlResponse, error)
        }
    }

    func cancel() {
        cancelled = true
    }
}
