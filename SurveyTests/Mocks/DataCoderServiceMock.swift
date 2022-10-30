//
//  DataCoderServiceMock.swift
//  SurveyTests
//
//  Created by Фирсов Алексей on 30.10.2022.
//

import Foundation
@testable import Survey

class DataCoderServiceMock: DataCoderServiceProtocol {
    var questionModel: [QuestionModel]
    
    init(questionModel: [QuestionModel]) {
        self.questionModel = questionModel
    }
    
    func decode(data: Data) -> [Survey.QuestionModel] {
        return questionModel
    }
    
    func encode(element: Codable) -> Data? {
        Data()
    }
}
