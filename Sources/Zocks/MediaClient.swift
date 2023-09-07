//
//  MediaClient.swift
//  
//
//  Created by János Kranczler on 2023. 01. 17..
//

import Foundation

let encoder = JSONEncoder()
let decoder = JSONDecoder()
let mediaManagementApiVersion = "v1"

struct JoinRequest: Encodable {
    let id: String?
    let name: String?
    let autoCreate: Bool?
    let password: String?
}

struct MediaClient {
    let urlSession = URLSession.shared
    let configuration: Configuration
    
    init(configuration: Configuration) {
        self.configuration = configuration
    }
    
    func joinRoom(roomId: String? = nil, roomName: String? = nil, autoCreate: Bool = false, password: String? = nil) async throws -> JoinResponse {
        guard autoCreate == (roomId == nil && roomName == nil) else {
            throw MediaClientError.invalidJoinParameters
        }
        let joinRequest = JoinRequest(id: roomId, name: roomName, autoCreate: autoCreate, password: password)
        let jsonData = try encoder.encode(joinRequest)
        let request = try createRequest(with: "rooms/join", from: jsonData)
        let (data, response) = try await urlSession.data(for: request)
        let httpResponse = response as! HTTPURLResponse
        guard (200...201).contains(httpResponse.statusCode) else {
            throw MediaClientError.joinFailed
        }
        let wrapper = try decoder.decode(JoinResponseWrapper.self, from: data)
        return wrapper.data
    }
    
    private func createRequest(with path: String, from body: Data) throws -> URLRequest {
        var request = URLRequest(url: try buildUrl(with: path))
        request.httpMethod = "POST"
        request.httpBody = body
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(configuration.getToken())", forHTTPHeaderField: "Authorization")
        return request
    }

    private func buildUrl(with path: String) throws -> URL {
        let path = "/\(mediaManagementApiVersion)/accounts/\(configuration.accountId)/\(path)"
        guard let url = URL(string: configuration.mediaManagementUrl + path) else {
            throw MediaClientError.invalidJoinParameters
        }
        return url
    }
    

}

enum MediaClientError: Error {
    case invalidJoinParameters
    case joinFailed
}
