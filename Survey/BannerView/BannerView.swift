//
//  BannerView.swift
//  Survey
//
//  Created by Фирсов Алексей on 29.10.2022.
//

import SwiftUI

struct BannerView: View {
    @ObservedObject var model: BannerModel
    
    var buttonTapHandler: () -> Void
    
    var body: some View {
        VStack {
            HStack {
                Text(model.bannerText)
                if model.isRetryButtonVisible {
                    Button("Retry", action: buttonTapHandler)
                }
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: UIScreen.main.bounds.size.height / 10)
            .background(model.backgroundColor)
            
            Spacer()
        }
    }
}

struct BannerView_Previews: PreviewProvider {
    static var previews: some View {
        BannerView(model: BannerModel(bannerText: "Success", backgroundColor: .green, isRetryButtonVisible: false)) { }
    }
}
