//
//  JoinInfo.swift
//  
//
//  Created by János Kranczler on 2023. 01. 17..
//

import Foundation

struct JoinResponseWrapper: Decodable {
    let data: JoinResponse
}

struct JoinResponse: Decodable {
    let joinInfo: JoinInfo
}

struct JoinInfo: Decodable {
    let token: String
    let webSocketUrl: String
    let turnServers: Array<TurnServer>
    let forceEdge: Bool
    let transcription: Transcription
}

struct TurnServer: Decodable {
    let urls: Array<String>
    let username: String
    let password: String
}

struct Transcription: Decodable {
    let url: String
    let provider: String
}
