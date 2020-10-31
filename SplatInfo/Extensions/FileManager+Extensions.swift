//
//  FileManager+Extensions.swift
//  SplatInfo
//
//  Created by Görkem Güclü on 29.10.20.
//

import Foundation

extension FileManager {
    
    var appGroupContainerURL : URL? {
        let sharedContainerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Constants.appGroupName)
        return sharedContainerURL
    }
}
