//
//  BannerModel.swift
//  Survey
//
//  Created by Фирсов Алексей on 01.11.2022.
//

import Foundation
import SwiftUI

class BannerModel: ObservableObject {
    @Published var bannerText: String
    @Published var backgroundColor: Color
    @Published var isRetryButtonVisible: Bool
    
    init(bannerText: String, backgroundColor: Color, isRetryButtonVisible: Bool) {
        self.bannerText = bannerText
        self.backgroundColor = backgroundColor
        self.isRetryButtonVisible = isRetryButtonVisible
    }
}
