//
//  StartView.swift
//  Survey
//
//  Created by Фирсов Алексей on 28.10.2022.
//

import SwiftUI

struct StartView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Welcome!")
                Spacer()
                NavigationLink("Start survey") {
                    let viewModel = SurveyViewModel(networkService: NetworkService(),
                                                    dataCoderService: DataCoderService())
                    SurveyView(viewModel: viewModel)
                }
                Spacer()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        StartView()
    }
}
