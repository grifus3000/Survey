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
    var currentId: Int? { get set }
    var totalQuestionsCount: Int { get }
    var submittedQuestionsCount: Int { get }
    var currentQuestion: QuestionModel? { get }
    
    var isNextButtonDisabled: Bool { get }
    var isPreviousButtonDisabled: Bool { get }
    var isSubmitButtonDisabled: Bool { get }
    var isAnswerFieldDisabled: Bool { get }
    
    var retryButtonHandler: () -> Void { get set }
    
    var submitButtonTitle: String { get }
    
    var answer: String { get }
    var bannerIsShowing: Bool { get set }
    var bannerModel: BannerModel { get set }
    
    func getNextQuestion()
    func getPreviousQuestion()
    func submitAnswer()
    func bannerWasAppeared()
    
    func viewOnAppear()
    func viewOnDisappear()
}

final class SurveyViewModel: SurveyViewModeling {
    // MARK: - Public Properties
    
    var isNextButtonDisabled: Bool {
        isNextIdNotAvailable
    }
    
    var isPreviousButtonDisabled: Bool {
        isPreviousIdNotAvailable
    }
    
    var isSubmitButtonDisabled: Bool {
        guard let isAnswerSubmitted = currentQuestion?.isAnswerSubmitted,
              !answer.isEmpty else {
            return true
        }

        return isAnswerSubmitted
    }
    
    var isAnswerFieldDisabled: Bool {
        guard let isAnswerSubmitted = currentQuestion?.isAnswerSubmitted else {
            return true
        }

        return isAnswerSubmitted
    }
    
    var totalQuestionsCount: Int {
        questions.count
    }
    
    var submittedQuestionsCount: Int {
        let submittedQuestions = questions.filter { question in
            question.isAnswerSubmitted
        }
        return submittedQuestions.count
    }
    
    var retryButtonHandler: () -> Void = {}
    
    var currentQuestion: QuestionModel? {
        questions.first { questionModel in
            questionModel.id == currentId
        }
    }
    
    var submitButtonTitle: String {
        if currentQuestion?.isAnswerSubmitted ?? false {
            return "Already submitted"
        } else {
            return "Submit"
        }
    }
    
    @Published var bannerIsShowing: Bool = false
    @ObservedObject var bannerModel = BannerModel(bannerText: "some", backgroundColor: .black, isRetryButtonVisible: false)
    
    @Published var answer: String = ""
    @Published var currentId: Int? {
        didSet {
            answer = currentQuestion?.answer ?? ""
        }
    }
    
    // MARK: - Private Properties
    
    @Published private var questions: [QuestionModel] = []
    
    private let getUrl = "https://xm-assignment.web.app/questions"
    private let postUrl = "https://xm-assignment.web.app/question/submit"
    
    private var disposables = Set<AnyCancellable>()
    private var timer: Timer?
    
    private let networkService: NetworkServiceProtocol
    private let dataCoderService: DataCoderServiceProtocol
    
    private var isNextIdNotAvailable: Bool {
        return currentId == questions.last?.id
    }
    private var isPreviousIdNotAvailable: Bool {
        return currentId == questions.first?.id
    }
    
    // MARK: - Lifecycle
    
    init(networkService: NetworkServiceProtocol, dataCoderService: DataCoderServiceProtocol) {
        self.networkService = networkService
        self.dataCoderService = dataCoderService
    }
    
    // MARK: - Public Methods
    
    func getNextQuestion() {
        if !isNextIdNotAvailable {
            currentId? += 1
        }
    }
    
    func getPreviousQuestion() {
        if !isPreviousIdNotAvailable {
            currentId? -= 1
        }
    }
    
    func bannerWasAppeared() {
        timer = Timer.scheduledTimer(timeInterval: 1,
                                     target: self,
                                     selector: #selector(didEndTimer),
                                     userInfo: nil,
                                     repeats: false)
    }
    
    func viewOnAppear() {
        getModel()
        retryButtonHandler = { [weak self] in
            self?.retrySendAnswer()
        }
    }
    
    func viewOnDisappear() {
        for index in questions.indices {
            questions[index].answer = nil
        }
        currentId = questions.first?.id ?? 0
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
    
    // MARK: - Private Methods
    
    @objc private func didEndTimer() {
        bannerIsShowing.toggle()
    }
    
    private func retrySendAnswer() {
        timer?.fire()
        submitAnswer()
    }
    
    private var postStatus: PostStatus = .notInProgress
    
    private enum PostStatus {
        case inProgress
        case notInProgress
    }
    
    private func post(answer: AnswerPostData) {
        guard let url = URL(string: postUrl),
              let data = dataCoderService.encode(element: answer) else {
            return
        }
        
        switch postStatus {
        case .notInProgress:
            break
        case .inProgress:
            return
        }
        
        postStatus = .inProgress
        networkService.postDataPublisher(by: url, with: data)
            .receive(on: DispatchQueue.main)
            .sink { error in
                print(error)
            } receiveValue: { [weak self] response in
                guard let response = response as? HTTPURLResponse else { return }
                
                self?.handle(response: response)
                self?.clearDisposables()
            }
            .store(in: &disposables)
    }
    
    private func clearDisposables() {
        disposables = Set()
    }
    
    private func handle(response: HTTPURLResponse) {
        postStatus = .notInProgress

        if 200...299 ~= response.statusCode  {
            postWasSuccessful()
        } else if 400...499 ~= response.statusCode {
            postWasNotSuccessful()
        }
    }
    
    private func postWasSuccessful() {
        if let index = questions.firstIndex(where: { $0.id == currentId }) {
            questions[index].answer = answer
            setupAndShowBanner(title: "Success", color: .green)
            bannerModel.isRetryButtonVisible = false
        }
    }
    
    private func postWasNotSuccessful() {
        setupAndShowBanner(title: "Failure", color: .red)
        bannerModel.isRetryButtonVisible = true
    }
    
    private func setupAndShowBanner(title: String, color: Color) {
        bannerModel.bannerText = title
        bannerModel.backgroundColor = color
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
                
                self.questions = self.dataCoderService.decode(data: data)
                self.currentId = self.questions.first?.id ?? 0
            }
            .store(in: &disposables)
    }
}
