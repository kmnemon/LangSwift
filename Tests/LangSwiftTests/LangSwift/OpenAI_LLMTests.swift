//
//  OpenAI_LLMTests.swift
//  LangSwift
//
//  Created by ke Liu on 4/7/26.
//
import Testing
@testable import LangSwift

@Test func testOpenAISendMessage() async throws {
    InitKey.initKeys()
    
    let openai = ChatCompletions()
    let resp = try! await openai.invoke(userContent: "give me some icecream")
    
    print(resp)
    #expect(resp != "")
}
