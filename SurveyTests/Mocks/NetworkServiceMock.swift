//
//  NetworkServiceMock.swift
//  SurveyTests
//
//  Created by Фирсов Алексей on 30.10.2022.
//

import Foundation
import Combine
@testable import Survey

final class NetworkServiceMock: NetworkServiceProtocol {
    var statusCode = 200
    
    func getDataPublisher(by url: URL) -> AnyPublisher<Data, URLError> {
        Result.success(Data()).publisher
            .setFailureType(to: URLError.self)
            .eraseToAnyPublisher()
    }
    
    func postDataPublisher(by url: URL, with data: Data) -> AnyPublisher<URLResponse, URLError> {
        let response = HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
        return Result.success(response).publisher
            .setFailureType(to: URLError.self)
            .eraseToAnyPublisher()
    }
}
