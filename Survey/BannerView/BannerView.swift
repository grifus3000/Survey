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
    
    init(bannerText: String, backgroundColor: Color) {
        self.bannerText = bannerText
        self.backgroundColor = backgroundColor
    }
    
    var body: some View {
        VStack {
            Text(bannerText)
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: 100)
                .background(backgroundColor)
            Spacer()
        }
    }
}

struct BannerView_Previews: PreviewProvider {
    static var previews: some View {
        BannerView(bannerText: "Success", backgroundColor: .green)
    }
}
