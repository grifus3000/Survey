//
//  SurveyView.swift
//  Survey
//
//  Created by Фирсов Алексей on 28.10.2022.
//

import SwiftUI

struct SurveyView: View {
    @ObservedObject var viewModel = SurveyViewModel(networkService: NetworkService(), dataCoder: DataCoder())
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    HStack {
                        Text("Questions \(viewModel.currentIndex) / \(viewModel.totalQuestionsCount)")
                            .padding(10)
                        Spacer()
                        Button("Previous") {
                            viewModel.getPreviousQuestion()
                        }
                        .disabled(viewModel.isPreviousButtonDisabled)
                        Button("Next") {
                            viewModel.getNextQuestion()
                        }
                        .disabled(viewModel.isNextButtonDisabled)
                        .padding(10)
                    }
                    
                    Text("Submitted questions: \(viewModel.submittedQuestionsCount)")
                    Spacer()
                    
                    VStack {
                        Text(viewModel.question)
                        TextField("Answer", text: $viewModel.answer)
                            .multilineTextAlignment(.center)
                            .disabled(viewModel.isSubmitActionDisabled)
                        Button(viewModel.submitButtonTitle) {
                            viewModel.submitAnswer()
                        }
                        .disabled(viewModel.isSubmitActionDisabled)
                        .padding()
                    }
                    Spacer()
                }
                if viewModel.bannerIsShowing {
                    BannerView(bannerText: viewModel.bannerText, backgroundColor: viewModel.bannerColor)
                        .onAppear {
                            viewModel.bannerWasAppeared()
                        }
                }
            }
        }
        .onDisappear {
            viewModel.viewOnDisappear()
        }
    }
}

struct SurveyView_Previews: PreviewProvider {
    static var previews: some View {
        SurveyView()
    }
}
