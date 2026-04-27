# LangSwift

## LCEL-style chains

Compose prompts, LLMs, parsers, and adapters with `|`:

```swift
let promptExtract = ChatPromptTemplate.fromTemplate("""
Extract the technical specifications from the following text:

{text_input}
""")

let promptTransform = ChatPromptTemplate.fromTemplate("""
Transform the following specifications into a JSON object with "cpu", "memory",
and "storage" as keys:

{specifications}
""")

let llm = ChatCompletions()

let extractionChain = promptExtract | llm | StrOutputParser()
let specifications = try await extractionChain.invoke([
    "text_input": "The laptop has an M4 CPU, 24GB memory, and 1TB storage."
])

let fullChain = promptExtract
    | llm
    | StrOutputParser()
    | AssignInput("specifications")
    | promptTransform
    | llm
    | StrOutputParser()

let json = try await fullChain.invoke([
    "text_input": "The laptop has an M4 CPU, 24GB memory, and 1TB storage."
])
```
