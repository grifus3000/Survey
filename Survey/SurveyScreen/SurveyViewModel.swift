//
//  SurveyViewModel.swift
//  Survey
//
//  Created by Фирсов Алексей on 28.10.2022.
//

import Foundation
import Combine
import SwiftUI

protocol SurveyViewModeling: ObservableObject {
    var questions: [QuestionModel] { get set }
    var currentIndex: Int { get set }
    var totalQuestionsCount: Int { get }
    var isNextButtonDisabled: Bool { get }
    var isPreviousButtonDisabled: Bool { get }
    var isSubmitActionDisabled: Bool { get }
    var submittedQuestionsCount: Int { get }
    var question: String { get }
    var submitButtonTitle: String { get }
    var answer: String { get }
    var bannerIsShowing: Bool { get set }
    var bannerText: String { get set }
    var bannerColor: Color { get set }
    
    func getNextQuestion()
    func getPreviousQuestion()
    func submitAnswer()
    func bannerWasAppeared()
    func viewOnDisappear()
}

class SurveyViewModel: SurveyViewModeling {
    private var currentQuestion: QuestionModel? {
        questions.first { questionModel in
            questionModel.id == currentIndex
        }
    }
    
    var totalQuestionsCount: Int {
        questions.count
    }
    
    var isNextButtonDisabled: Bool {
        return currentIndex == totalQuestionsCount
    }
    
    var isPreviousButtonDisabled: Bool {
        return currentIndex == 1
    }
    
    var question: String {
        return currentQuestion?.question ?? ""
    }
    
    var submittedQuestionsCount: Int {
        let submittedQuestions = questions.filter { question in
            question.isAnswerSubmitted
        }
        return submittedQuestions.count
    }
    
    var isSubmitActionDisabled: Bool {
        guard let isAnswerSubmitted =  currentQuestion?.isAnswerSubmitted else {
            return false
        }

        return isAnswerSubmitted
    }
    
    var submitButtonTitle: String {
        if isSubmitActionDisabled {
            return "Already submitted"
        } else {
            return "Submit"
        }
    }
    
    @Published var bannerText: String = ""
    @Published var bannerColor: Color = .clear
    @Published var bannerIsShowing: Bool = false
    @Published var answer: String = ""
    @Published var questions: [QuestionModel] = []
    @Published var currentIndex = 0 {
        didSet {
            answer = currentQuestion?.answer ?? ""
        }
    }
    
    private let getUrl = "https://xm-assignment.web.app/questions"
    private let postUrl = "https://xm-assignment.web.app/question/submit"
    
    private var disposables = Set<AnyCancellable>()
    private var timer: Timer?
    
    private let networkService: NetworkServiceProtocol
    private let dataCoder: DataCoderProtocol
    
    init(networkService: NetworkServiceProtocol, dataCoder: DataCoderProtocol) {
        self.networkService = networkService
        self.dataCoder = dataCoder
        
        getModel()
    }
    
    func getNextQuestion() {
        currentIndex += 1
    }
    
    func getPreviousQuestion() {
        currentIndex -= 1
    }
    
    func bannerWasAppeared() {
        timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(didEndTimer), userInfo: nil, repeats: false)
    }
    
    func viewOnDisappear() {
        for index in questions.indices {
            questions[index].answer = nil
        }
        currentIndex = questions.first?.id ?? 0
        timer?.fire()
    }
    
    func submitAnswer() {
        guard let id = currentQuestion?.id,
              !bannerIsShowing,
              !answer.isEmpty else {
            return
        }

        let answerModel = AnswerPostData(id: id, answer: answer)
        post(answer: answerModel)
    }
    
    @objc private func didEndTimer() {
        bannerIsShowing.toggle()
    }
    
    private func post(answer: AnswerPostData) {
        guard let url = URL(string: postUrl),
              let data = dataCoder.encode(element: answer) else {
            return
        }
        
        networkService.postDataPublisher(by: url, with: data)
            .receive(on: DispatchQueue.main)
            .sink { error in
                print(error)
            } receiveValue: { [weak self] response in
                guard let response = response as? HTTPURLResponse else { return }
                
                self?.handle(response: response)
            }
            .store(in: &disposables)
    }
    
    private func handle(response: HTTPURLResponse) {
        if 200...299 ~= response.statusCode  {
            postWasSuccessful()
        } else if 400...499 ~= response.statusCode {
            postWasNotSuccessful()
        }
    }
    
    private func postWasSuccessful() {
        questions[currentIndex - 1].answer = answer
        setupAndShowBanner(title: "Success", color: .green)
    }
    
    
    private func postWasNotSuccessful() {
        setupAndShowBanner(title: "Failure", color: .red)
    }
    
    private func setupAndShowBanner(title: String, color: Color) {
        bannerText = title
        bannerColor = color
        bannerIsShowing.toggle()
    }
    
    private func getModel() {
        guard let url = URL(string: getUrl) else { return }
        
        networkService.getDataPublisher(by: url)
            .receive(on: DispatchQueue.main)
            .sink { error in
                print(error)
            } receiveValue: { [weak self] data in
                guard let self = self else { return }
                
                self.questions = self.dataCoder.decode(data: data)
                self.currentIndex = self.questions.first?.id ?? 0
            }
            .store(in: &disposables)
    }
}
