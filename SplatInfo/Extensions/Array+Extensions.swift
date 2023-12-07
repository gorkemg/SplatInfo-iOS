//
//  Array+Extensions.swift
//  SplatInfo
//
//  Created by Görkem Güclü on 07.12.23.
//

import Foundation

extension Array where Element: Equatable{
    mutating func remove(element: Element) {
        if let i = self.firstIndex(of: element) {
            self.remove(at: i)
        }
    }
}
