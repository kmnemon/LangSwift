//
//  OpenAI.swift
//  LangSwift
//
//  Created by ke Liu on 1/3/26.
//

public final class ResponsesAPI: LLMProtocol {
    private var llm: ResponsesModel
    private var mode: String
    
    public init(mode: String = .gpt4_o_mini, baseURL: String = "api.chatanywhere.tech") {
        let configuration = ResponsesModel.Configuration(token: LLMKey.value(for: LLMKey.openAI), host: baseURL, timeoutInterval: 60.0)
        self.llm = ResponsesModel(configuration: configuration)
        self.mode = mode
        
    }
    
    public func invoke(userContent: String) async throws -> String {
        let query = CreateModelResponseQuery(
            input: .textInput(userContent),
            model: self.mode
        )
        
        let response: ResponseObject = try await llm.createResponse(query: query)
        for output in response.output {
            switch output {
            case .outputMessage(let outputMessage):
                for content in outputMessage.content {
                    switch content {
                    case .OutputTextContent(let textContent):
                        return textContent.text
                    case .RefusalContent(let refusalContent):
                        return refusalContent.refusal
                    case .other:
                        continue
                    }
                }
            default:
                return "some error happens"
            }
        }
        
        return "waht"
    }
    
    public func invoke(messages: [Message]) async throws -> String {
        try await invoke(userContent: messages.map(\.content).joined(separator: "\n"))
    }
}
