//
//  DataCoderServiceTests.swift
//  SurveyTests
//
//  Created by Фирсов Алексей on 30.10.2022.
//

import XCTest
@testable import Survey

final class DataCoderServiceTests: XCTestCase {
    
    var sut: DataCoderService!
    let model = [QuestionModel(id: 1, question: "One"),
                 QuestionModel(id: 2, question: "Two")]

    override func setUpWithError() throws {
        try super.setUpWithError()
        
        sut = DataCoderService()
    }

    override func tearDownWithError() throws {
        sut = nil
        
        try super.tearDownWithError()
    }

    func testDecodeSuccess() throws {
        guard let data = try? JSONEncoder().encode(model) else {
            XCTFail()
            return
        }
        
        let result = sut.decode(data: data)
        
        XCTAssertEqual(result, model)
    }
    
    func testDecodeFailure() throws {
        let data = Data()
        
        let result = sut.decode(data: data)
        
        XCTAssertEqual(result, [])
    }
    
    func testEncodeSuccess() throws {
        guard let data = try? JSONEncoder().encode(model) else {
            XCTFail()
            return
        }
        
        let result = sut.encode(element: model)
        
        XCTAssertEqual(result, data)
    }
}
