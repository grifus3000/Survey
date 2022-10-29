//
//  NetworkService.swift
//  Survey
//
//  Created by Фирсов Алексей on 28.10.2022.
//

import Foundation
import Combine

protocol NetworkServiceProtocol {
    func getDataPublisher(by url: URL) -> AnyPublisher<Data, URLError>
    func postDataPublisher(by url: URL, with data: Data) -> AnyPublisher<URLResponse, URLError>
}

class NetworkService: NetworkServiceProtocol {
    func getDataPublisher(by url: URL) -> AnyPublisher<Data, URLError> {
        return URLSession.shared.dataTaskPublisher(for: url)
            .map({ (data, _) -> Data in
                return data
            })
            .eraseToAnyPublisher()
    }
    
    func postDataPublisher(by url: URL, with data: Data) -> AnyPublisher<URLResponse, URLError> {
        var request = URLRequest(url: url)
        request.httpBody = data
        request.httpMethod = "POST"
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map({ data, response -> URLResponse in
                return response
            })
            .eraseToAnyPublisher()
    }
}
