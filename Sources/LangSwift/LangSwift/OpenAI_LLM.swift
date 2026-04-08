//
//  OpenAI.swift
//  LangSwift
//
//  Created by ke Liu on 1/3/26.
//
import OpenAI

class OpenAI_LLM: LLMProtocol {
    private var openAI: OpenAI
    //    private var mode: String
    
    init(mode: String = .gpt4_o_mini, baseURL: String = "api.chatanywhere.tech") {
        let configuration = OpenAI.Configuration(token: LLMKey.value(for: LLMKey.openAI), host: baseURL, timeoutInterval: 60.0)
        self.openAI = OpenAI(configuration: configuration)
        //        self.mode = mode
        
    }
    
    func invoke(userContent: String) async throws -> String {
        let query = CreateModelResponseQuery(
            input: .textInput(userContent),
            model: .gpt4_o_mini
        )
        
        let response: ResponseObject = try await openAI.responses.createResponse(query: query)
        for output in response.output {
            switch output {
                case .outputMessage(let outputMessage):
                    for content in outputMessage.content {
                        switch content {
                            case .OutputTextContent(let textContent):
                                return textContent.text
                            case .RefusalContent(let refusalContent):
                                return refusalContent.refusal
                        }
                    }
                default:
                    return "some error happens"
            }
        }
        
        return "waht"
    }
    
    func invoke1(userContent: String) async throws -> String {
        let query = ChatQuery(
            messages: [
                .user(.init(content: .string(userContent)))
            ],
            model: .gpt4_o_mini
        )
        
        do {
            let result = try await openAI.chats(query: query)
            return result.choices.first?.message.content ?? "no respond"
        } catch {
            throw error
        }
    }
    
    func invoke(messages: [Message]) async -> String {
        return ""
    }
}

