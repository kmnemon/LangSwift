//
//  LLMBaseTests.swift
//  LangSwift
//
//  Created by ke Liu on 4/6/26.
//

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
