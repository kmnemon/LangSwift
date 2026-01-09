//
//  LLMProtocol.swift
//  LangSwift
//
//  Created by ke Liu on 1/8/26.
//
import Foundation

protocol  LLMProtocol {
    func invoke(userContent: String) async throws -> String
}

extension LLMProtocol {

}
