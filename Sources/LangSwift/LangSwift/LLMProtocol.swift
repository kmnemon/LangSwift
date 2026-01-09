//
//  LLMProtocol.swift
//  LangSwift
//
//  Created by ke Liu on 1/8/26.
//
import Foundation

protocol  LLMProtocol {
    func invoke(userContent: String) async -> String
    func invoke(messages: [Message]) async -> String
}

extension LLMProtocol {

}
