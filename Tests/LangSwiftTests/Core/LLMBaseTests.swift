//
//  LLMBaseTests.swift
//  LangSwift
//
//  Created by ke Liu on 4/6/26.
//

import Foundation
import Testing
@testable import LangSwift

@Test func testGetSetEnv() async throws {
    LLMKey.setValue("123", for: LLMKey.deepSeek)
    let key = LLMKey.value(for: LLMKey.deepSeek)
    
  
    #expect(key! == "123")
}

@Test func testClearEnv() async throws {
    LLMKey.setValue("123", for: LLMKey.deepSeek)
    LLMKey.clearValue(for: LLMKey.deepSeek)
    
    let key = LLMKey.value(for: LLMKey.deepSeek)
    
    #expect(key == nil)
}

@Test func baseModelConfigurationStoresTemperature() {
    let configuration = BaseModel.Configuration(token: "token", temperature: 0.3)

    #expect(configuration.temperature == 0.3)
}

@Test func chatQueryEncodesTemperatureWhenSet() throws {
    let query = ChatQuery(
        messages: [.user("Hello")],
        model: .gpt4_o_mini,
        temperature: 0.3
    )

    let json = try encodedJSONObject(query)

    #expect(json["temperature"] as? Double == 0.3)
}

@Test func responsesQueryEncodesTemperatureWhenSet() throws {
    let query = CreateModelResponseQuery(
        input: .textInput("Hello"),
        model: .gpt4_o_mini,
        temperature: 0.3
    )

    let json = try encodedJSONObject(query)

    #expect(json["temperature"] as? Double == 0.3)
}

private func encodedJSONObject<Value: Encodable>(_ value: Value) throws -> [String: Any] {
    let data = try JSONEncoder().encode(value)
    return try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])
}
