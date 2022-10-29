//
//  BannerView.swift
//  Survey
//
//  Created by Фирсов Алексей on 29.10.2022.
//

import SwiftUI

struct BannerView: View {
    @State var bannerText: String
    @State var backgroundColor: Color
    @State var isRetryButtonVisible: Bool
    
    var buttonTapHandler: () -> Void
    
    var body: some View {
        VStack {
            HStack {
                Text(bannerText)
                if isRetryButtonVisible {
                    Button("Retry", action: buttonTapHandler)
                }
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: 100)
            .background(backgroundColor)
            
            Spacer()
        }
    }
}

struct BannerView_Previews: PreviewProvider {
    static var previews: some View {
        BannerView(bannerText: "Success", backgroundColor: .green, isRetryButtonVisible: false) {
            
        }
    }
}
