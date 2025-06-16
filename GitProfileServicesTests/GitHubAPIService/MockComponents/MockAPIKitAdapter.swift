//
//  MockAPIKitAdapter.swift
//  GitProfileServicesTests
//
//  Created by Tien Nguyen on 14/6/25.
//

import APIKit
import Foundation

final class MockAPIKitAdapter: SessionAdapter {

    enum Error: Swift.Error {
        case cancelled
    }

    private let data: Data?
    private let urlResponse: URLResponse?
    private let error: Error?

    init(data: Data? = nil, urlResponse: URLResponse? = nil, error: Error? = nil) {
        self.data = data
        self.urlResponse = urlResponse
        self.error = error
    }

    func createTask(with request: URLRequest,
                    handler: @escaping (Data?, URLResponse?, Swift.Error?) -> Void) -> SessionTask {
        MockSessionTask(
            data: data,
            urlResponse: urlResponse,
            error: error,
            handler: handler
        )
    }

    func getTasks(with handler: @escaping ([SessionTask]) -> Void) {
        handler([])
    }
}
