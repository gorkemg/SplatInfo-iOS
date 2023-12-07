//
//  SwiftUI+Extensions.swift
//  SplatInfo
//
//  Created by Görkem Güclü on 15.10.22.
//

import UIKit
import SwiftUI

extension Bool {
     static var isWatchOSExtension10: Bool {
         guard #available(watchOSApplicationExtension 10.0, *) else {
             return true
         }
         return false
     }
 }

extension View {
    func emptyWidgetBackground() -> some View {
        if #available(watchOS 10.0, iOSApplicationExtension 17.0, iOS 17.0, macOSApplicationExtension 14.0, *) {
            return containerBackground(for: .widget) {
            }
        } else {
            return Color.clear
        }
    }
    
    func widgetBackground(backgroundView: some View) -> some View {
        if #available(watchOS 10.0, iOSApplicationExtension 17.0, iOS 17.0, macOSApplicationExtension 14.0, *) {
            return containerBackground(for: .widget) {
                backgroundView
            }
        } else {
            return background(backgroundView)
        }
    }
}

extension WidgetConfiguration {

    func contentMarginsDisabledIfAvailable() -> some WidgetConfiguration {
        if #available(iOSApplicationExtension 17.0, *) {
            return self.contentMarginsDisabled()
        } else {
            return self
        }
    }
}
