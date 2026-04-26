//
//  ResponsesModels.swift
//  LangSwift
//
//  Created by ke Liu on 4/26/26.
//

import Foundation

struct CreateModelResponseQuery: Encodable {
    let input: ResponseInput
    let model: Model
}

enum ResponseInput: Encodable {
    case textInput(String)

    func encode(to encoder: Encoder) throws {
        switch self {
        case .textInput(let text):
            var container = encoder.singleValueContainer()
            try container.encode(text)
        }
    }
}

struct ResponseObject: Decodable {
    let output: [ResponseOutput]
}

enum ResponseOutput: Decodable {
    case outputMessage(OutputMessage)
    case other

    private enum CodingKeys: String, CodingKey {
        case type
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decodeIfPresent(String.self, forKey: .type)

        switch type {
        case "message", "output_message":
            self = .outputMessage(try OutputMessage(from: decoder))
        default:
            self = .other
        }
    }
}

struct OutputMessage: Decodable {
    let content: [ResponseContent]
}

enum ResponseContent: Decodable {
    case OutputTextContent(OutputTextContentObject)
    case RefusalContent(RefusalContentObject)
    case other

    private enum CodingKeys: String, CodingKey {
        case type
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decodeIfPresent(String.self, forKey: .type)

        switch type {
        case "output_text":
            self = .OutputTextContent(try OutputTextContentObject(from: decoder))
        case "refusal":
            self = .RefusalContent(try RefusalContentObject(from: decoder))
        default:
            self = .other
        }
    }
}

struct OutputTextContentObject: Decodable {
    let text: String
}

struct RefusalContentObject: Decodable {
    let refusal: String
}

final class ResponsesModel: BaseModel {
    func createResponse(query: CreateModelResponseQuery) async throws -> ResponseObject {
        let request = try makeRequest(path: "/v1/responses", body: query)
        let (data, response) = try await URLSession.shared.data(for: request)
        try validate(response: response, data: data)
        return try decode(ResponseObject.self, from: data)
    }
}

