//
//  OpenAI.swift
//  LangSwift
//
//  Created by ke Liu on 1/3/26.
//

class ResponsesAPI: LLMProtocol {
    private var llm: OpenAI
    private var mode: String
    
    init(mode: String = .gpt4_o_mini, baseURL: String = "api.chatanywhere.tech") {
        let configuration = OpenAI.Configuration(token: LLMKey.value(for: LLMKey.openAI), host: baseURL, timeoutInterval: 60.0)
        self.llm = OpenAI(configuration: configuration)
        self.mode = mode
        
    }
    
    func invoke(userContent: String) async throws -> String {
        let query = CreateModelResponseQuery(
            input: .textInput(userContent),
            model: self.mode
        )
        
        let response: ResponseObject = try await llm.responses.createResponse(query: query)
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
    
    func invoke(messages: [Message]) async -> String {
        return ""
    }
}
