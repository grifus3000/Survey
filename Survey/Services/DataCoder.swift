//
//  DataCoderService.swift
//  Survey
//
//  Created by Фирсов Алексей on 28.10.2022.
//

import Foundation

protocol DataCoderServiceProtocol {
    func decode(data: Data) -> [QuestionModel]
    func encode(element: Codable) -> Data?
}

class DataCoderService: DataCoderServiceProtocol {
    func decode(data: Data) -> [QuestionModel] {
        guard let questions = try? JSONDecoder().decode([QuestionModel].self, from: data) else {
            return []
        }
        
        return questions
    }
    
    func encode(element: Codable) -> Data? {
        guard let data = try? JSONEncoder().encode(element) else { return nil }
        return data
    }
}
