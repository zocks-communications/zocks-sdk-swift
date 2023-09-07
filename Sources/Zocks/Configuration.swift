//
//  Configuration.swift
//  
//
//  Created by János Kranczler on 2023. 01. 17..
//

import Foundation

public let defaultAccountId = "db8mt16gxt8ueddw"
public let defaultMediaManagementUrl = "https://api.zocks.io"

public struct Configuration {
    let accountId: String
    let getToken: () -> String
    let mediaManagementUrl: String
    
    public init(accountId: String = defaultAccountId,
                getToken: @escaping () -> String,
                mediaManagementUrl: String = defaultMediaManagementUrl) {
        self.accountId = accountId
        self.getToken = getToken
        self.mediaManagementUrl = mediaManagementUrl
    }
}

struct Token {
    let string: String
    init(string: String) {
        self.string = string
    }
}
