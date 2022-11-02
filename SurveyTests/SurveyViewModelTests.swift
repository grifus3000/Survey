//
//  SurveyViewModelTests.swift
//  SurveyTests
//
//  Created by Фирсов Алексей on 30.10.2022.
//

import XCTest
@testable import Survey
import Combine
import SwiftUI

extension QuestionModel: Equatable {
    public static func == (lhs: QuestionModel, rhs: QuestionModel) -> Bool {
        lhs.id == rhs.id
    }
}

final class SurveyViewModelTests: XCTestCase {

    private var disposables = Set<AnyCancellable>()
    
    var networkServiceMock: NetworkServiceMock!
    var dataCoderServiceMock: DataCoderServiceMock!
    var sut: SurveyViewModel!
    
    let questionsModel = [QuestionModel(id: 1, question: "One"),
                         QuestionModel(id: 2, question: "Two"),
                         QuestionModel(id: 3, question: "Three")]
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        networkServiceMock = NetworkServiceMock()
        dataCoderServiceMock = DataCoderServiceMock(questionModel: questionsModel)
        sut = SurveyViewModel(networkService: networkServiceMock,
                              dataCoderService: dataCoderServiceMock)
        
    }

    override func tearDownWithError() throws {
        networkServiceMock = nil
        dataCoderServiceMock = nil
        sut = nil
        disposables = Set<AnyCancellable>()
        
        try super.tearDownWithError()
    }

    func testInitializing() throws {
        setupData()
        
        XCTAssertEqual(sut.answer, questionsModel.first?.answer ?? "")
        XCTAssertEqual(sut.currentId, questionsModel.first?.id)
        XCTAssertEqual(sut.totalQuestionsCount, questionsModel.count)
    }
    
    func testGetNextQuestion() throws {
        setupData()

        sut.getNextQuestion()
        sut.getNextQuestion()
        sut.getNextQuestion()
        
        XCTAssertEqual(sut.currentId, 3)
        XCTAssertEqual(sut.isNextButtonDisabled, true)
    }
    
    func testGetPreviousQuestion() throws {
        setupData()
        
        sut.currentId = questionsModel.last?.id
        
        sut.getPreviousQuestion()
        sut.getPreviousQuestion()
        sut.getPreviousQuestion()
        
        XCTAssertEqual(sut.currentId, 1)
        XCTAssertEqual(sut.isPreviousButtonDisabled, true)
    }
    
    func testSubmitQuestionsCount() throws {
        setupAnswers()
        setupData()
        
        XCTAssertEqual(sut.submittedQuestionsCount, 2)
    }
    
    func testSubmitQuestionsActionsSubmitted() throws {
        setupAnswers()
        setupData()
        
        XCTAssertEqual(sut.isSubmitButtonDisabled, true)
        XCTAssertEqual(sut.submitButtonTitle, "Already submitted")
        XCTAssertEqual(sut.isAnswerFieldDisabled, true)
    }
    
    func testSubmitQuestionsActionsNoAnswer() throws {
        setupAnswers()
        setupData()
        
        sut.currentId = 2
        
        XCTAssertEqual(sut.isSubmitButtonDisabled, true)
        XCTAssertEqual(sut.isAnswerFieldDisabled, false)
        XCTAssertEqual(sut.submitButtonTitle, "Submit")
    }
    
    func testSubmitQuestionsActionsWithAnswer() throws {
        setupAnswers()
        setupData()
        
        sut.currentId = 2
        sut.answer = "Answer"
        
        XCTAssertEqual(sut.isSubmitButtonDisabled, false)
        XCTAssertEqual(sut.isAnswerFieldDisabled, false)
        XCTAssertEqual(sut.submitButtonTitle, "Submit")
    }
    
    func testSubmitSuccess() throws {
        setupData()
        let answer = "Answer"
        let expectation = expectation(description: "submit")
        
        sut.answer = answer
        sut.submitAnswer()
        
        DispatchQueue.main.async {
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2)
        
        XCTAssertEqual(sut.currentQuestion?.answer, answer)
        XCTAssertEqual(sut.bannerModel.isRetryButtonVisible, false)
        XCTAssertEqual(sut.bannerModel.bannerText, "Success")
        XCTAssertEqual(sut.bannerModel.backgroundColor, Color.green)
        XCTAssertEqual(sut.bannerIsShowing, true)
    }
    
    func testSubmitFailure() throws {
        setupData()
        networkServiceMock.statusCode = 400
        let answer = "Answer"
        let expectation = expectation(description: "submit")
        
        sut.answer = answer
        sut.submitAnswer()
        
        DispatchQueue.main.async {
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2)
        
        XCTAssertNil(sut.currentQuestion?.answer)
        XCTAssertEqual(sut.bannerModel.isRetryButtonVisible, true)
        XCTAssertEqual(sut.bannerModel.bannerText, "Failure")
        XCTAssertEqual(sut.bannerModel.backgroundColor, Color.red)
        XCTAssertEqual(sut.bannerIsShowing, true)
    }
    
    func testViewOnDisappear() throws {
        setupData()
        setupAnswers()
        
        sut.viewOnDisappear()
        
        XCTAssertNil(sut.currentQuestion?.answer)
        XCTAssertEqual(sut.currentId, 1)
        XCTAssertEqual(sut.bannerIsShowing, false)
    }
    
    func setupData() {
        let expectation = expectation(description: "currentIndex")
        
        DispatchQueue.main.async {
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5)
    }
    
    func setupAnswers() {
        dataCoderServiceMock.questionModel[0].answer = "Answer1"
        dataCoderServiceMock.questionModel[2].answer = "Answer3"
    }
}
