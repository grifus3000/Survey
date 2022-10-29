//
//  ArrayExtension.swift
//  Survey
//
//  Created by Фирсов Алексей on 29.10.2022.
//

import Foundation

extension Array {
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
