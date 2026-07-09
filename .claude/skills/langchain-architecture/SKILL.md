---
name: langchain-architecture
description: Design LLM applications using LangChain 1.x and LangGraph for agents, memory, and tool integration. Use when building LangChain applications, implementing AI agents, or creating complex LLM workflows.
---

# LangChain & LangGraph Architecture

Modern LangChain 1.x and LangGraph for LLM applications with agents, state management, memory, and tool integration.

## Core Rules

- LangGraph is the standard for agents: explicit `StateGraph` with TypedDict state, durable execution, checkpointing, human-in-the-loop
- Use `create_react_agent` for tool-calling agents; define tools with Pydantic schemas
- Memory via checkpointers: `MemorySaver` in development, `PostgresSaver` in production, vector store for long-term context; each `thread_id` is a separate conversation
- Multi-agent systems use a supervisor node routing between specialized agents via conditional edges
- Document pipelines: loaders, text splitters, vector stores, retrievers
- LangSmith for observability; keys always from env, never inline

## References

Read only the file relevant to the task:

| File | Read when working on |
|---|---|
| `references/agents-and-state.md` | Package structure, TypedDict state, ReAct agent quick start, structured tools with Pydantic |
| `references/graph-patterns.md` | RAG graphs, multi-step workflows with conditional routing, multi-agent supervisor orchestration |
| `references/memory.md` | Checkpointers (MemorySaver, PostgresSaver), thread IDs, vector store long-term memory |
| `references/observability-performance.md` | LangSmith tracing, custom callbacks, streaming, Redis LLM cache, async batching, connection pooling |
