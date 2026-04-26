//
//  OpenAI.swift
//  LangSwift
//
//  Created by ke Liu on 4/26/26.
//

import Foundation

final class OpenAI {
    typealias Configuration = LLM.Configuration

    let responses: Responses

    init(configuration: Configuration) {
        let llm = LLM(configuration: configuration)
        self.responses = Responses(llm: llm)
    }
}

final class Responses {
    private let llm: LLM

    init(llm: LLM) {
        self.llm = llm
    }

    func createResponse(query: CreateModelResponseQuery) async throws -> ResponseObject {
        let request = try llm.makeRequest(path: "/v1/responses", body: query)
        let (data, response) = try await URLSession.shared.data(for: request)
        try llm.validate(response: response, data: data)
        return try llm.decode(ResponseObject.self, from: data)
    }
}
