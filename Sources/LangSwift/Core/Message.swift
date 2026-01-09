//
//  Message.swift
//  LangSwift
//
//  Created by ke on 1/9/26.
//

protocol BaseMessage: Codable {
    var role: Role { get set }
    var content: String { get set }
}

struct Message: BaseMessage, Codable {
    var role: Role
    var content: String
}


