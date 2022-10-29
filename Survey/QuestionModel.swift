//
//  QuestionModel.swift
//  Survey
//
//  Created by Фирсов Алексей on 28.10.2022.
//

import Foundation

struct QuestionModel: Codable {
    let id: Int
    let question: String
    var answer: String?
    
    var isAnswerSubmitted: Bool {
        guard let answer = answer,
              !answer.isEmpty else {
            return false
        }
        
        return true
    }
}
