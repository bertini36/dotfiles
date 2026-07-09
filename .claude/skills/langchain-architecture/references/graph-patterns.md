# Graph Patterns: RAG, Workflows, Multi-Agent

## Pattern 1: RAG with LangGraph

```python
from langgraph.graph import StateGraph, START, END
from langchain_anthropic import ChatAnthropic
from langchain_voyageai import VoyageAIEmbeddings
from langchain_pinecone import PineconeVectorStore
from langchain_core.documents import Document
from langchain_core.prompts import ChatPromptTemplate
from typing import TypedDict, Annotated

class RAGState(TypedDict):
    question: str
    context: Annotated[list[Document], "retrieved documents"]
    answer: str

# Initialize components
llm = ChatAnthropic(model="claude-sonnet-4-6")
embeddings = VoyageAIEmbeddings(model="voyage-3-large")
vectorstore = PineconeVectorStore(index_name="docs", embedding=embeddings)
retriever = vectorstore.as_retriever(search_kwargs={"k": 4})

# Define nodes
async def retrieve(state: RAGState) -> RAGState:
    """Retrieve relevant documents."""
    docs = await retriever.ainvoke(state["question"])
    return {"context": docs}

async def generate(state: RAGState) -> RAGState:
    """Generate answer from context."""
    prompt = ChatPromptTemplate.from_template(
        """Answer based on the context below. If you cannot answer, say so.

        Context: {context}

        Question: {question}

        Answer:"""
    )
    context_text = "\n\n".join(doc.page_content for doc in state["context"])
    response = await llm.ainvoke(
        prompt.format(context=context_text, question=state["question"])
    )
    return {"answer": response.content}

# Build graph
builder = StateGraph(RAGState)
builder.add_node("retrieve", retrieve)
builder.add_node("generate", generate)
builder.add_edge(START, "retrieve")
builder.add_edge("retrieve", "generate")
builder.add_edge("generate", END)

rag_chain = builder.compile()

# Use the chain
result = await rag_chain.ainvoke({"question": "What is the main topic?"})
```

## Pattern 2: Multi-Step Workflow with StateGraph

```python
from langgraph.graph import StateGraph, START, END
from typing import TypedDict, Literal

class WorkflowState(TypedDict):
    text: str
    entities: list
    analysis: str
    summary: str
    current_step: str

async def extract_entities(state: WorkflowState) -> WorkflowState:
    """Extract key entities from text."""
    prompt = f"Extract key entities from: {state['text']}\n\nReturn as JSON list."
    response = await llm.ainvoke(prompt)
    return {"entities": response.content, "current_step": "analyze"}

async def analyze_entities(state: WorkflowState) -> WorkflowState:
    """Analyze extracted entities."""
    prompt = f"Analyze these entities: {state['entities']}\n\nProvide insights."
    response = await llm.ainvoke(prompt)
    return {"analysis": response.content, "current_step": "summarize"}

async def generate_summary(state: WorkflowState) -> WorkflowState:
    """Generate final summary."""
    prompt = f"""Summarize:
    Entities: {state['entities']}
    Analysis: {state['analysis']}

    Provide a concise summary."""
    response = await llm.ainvoke(prompt)
    return {"summary": response.content, "current_step": "complete"}

def route_step(state: WorkflowState) -> Literal["analyze", "summarize", "end"]:
    """Route to next step based on current state."""
    step = state.get("current_step", "extract")
    if step == "analyze":
        return "analyze"
    elif step == "summarize":
        return "summarize"
    return "end"

# Build workflow
builder = StateGraph(WorkflowState)
builder.add_node("extract", extract_entities)
builder.add_node("analyze", analyze_entities)
builder.add_node("summarize", generate_summary)

builder.add_edge(START, "extract")
builder.add_conditional_edges("extract", route_step, {
    "analyze": "analyze",
    "summarize": "summarize",
    "end": END
})
builder.add_conditional_edges("analyze", route_step, {
    "summarize": "summarize",
    "end": END
})
builder.add_edge("summarize", END)

workflow = builder.compile()
```

## Pattern 3: Multi-Agent Orchestration

```python
from langgraph.graph import StateGraph, START, END
from langgraph.prebuilt import create_react_agent
from langchain_core.messages import HumanMessage
from typing import Literal

class MultiAgentState(TypedDict):
    messages: list
    next_agent: str

# Create specialized agents
researcher = create_react_agent(llm, research_tools)
writer = create_react_agent(llm, writing_tools)
reviewer = create_react_agent(llm, review_tools)

async def supervisor(state: MultiAgentState) -> MultiAgentState:
    """Route to appropriate agent based on task."""
    prompt = f"""Based on the conversation, which agent should handle this?

    Options:
    - researcher: For finding information
    - writer: For creating content
    - reviewer: For reviewing and editing
    - FINISH: Task is complete

    Messages: {state['messages']}

    Respond with just the agent name."""

    response = await llm.ainvoke(prompt)
    return {"next_agent": response.content.strip().lower()}

def route_to_agent(state: MultiAgentState) -> Literal["researcher", "writer", "reviewer", "end"]:
    """Route based on supervisor decision."""
    next_agent = state.get("next_agent", "").lower()
    if next_agent == "finish":
        return "end"
    return next_agent if next_agent in ["researcher", "writer", "reviewer"] else "end"

# Build multi-agent graph
builder = StateGraph(MultiAgentState)
builder.add_node("supervisor", supervisor)
builder.add_node("researcher", researcher)
builder.add_node("writer", writer)
builder.add_node("reviewer", reviewer)

builder.add_edge(START, "supervisor")
builder.add_conditional_edges("supervisor", route_to_agent, {
    "researcher": "researcher",
    "writer": "writer",
    "reviewer": "reviewer",
    "end": END
})

# Each agent returns to supervisor
for agent in ["researcher", "writer", "reviewer"]:
    builder.add_edge(agent, "supervisor")

multi_agent = builder.compile()
```
