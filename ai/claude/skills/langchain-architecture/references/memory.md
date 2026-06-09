# Memory Management

Memory options:

- **ConversationBufferMemory**: Stores all messages (short conversations)
- **ConversationSummaryMemory**: Summarizes older messages (long conversations)
- **ConversationTokenBufferMemory**: Token-based windowing
- **VectorStoreRetrieverMemory**: Semantic similarity retrieval
- **LangGraph Checkpointers**: Persistent state across sessions

## Token-Based Memory with LangGraph

```python
from langgraph.checkpoint.memory import MemorySaver
from langgraph.prebuilt import create_react_agent

# In-memory checkpointer (development)
checkpointer = MemorySaver()

# Create agent with persistent memory
agent = create_react_agent(llm, tools, checkpointer=checkpointer)

# Each thread_id maintains separate conversation
config = {"configurable": {"thread_id": "session-abc123"}}

# Messages persist across invocations with same thread_id
result1 = await agent.ainvoke({"messages": [("user", "My name is Alice")]}, config)
result2 = await agent.ainvoke({"messages": [("user", "What's my name?")]}, config)
# Agent remembers: "Your name is Alice"
```

## Production Memory with PostgreSQL

```python
import os
from langgraph.checkpoint.postgres import PostgresSaver

# Production checkpointer. Never hardcode DSNs; load from env.
checkpointer = PostgresSaver.from_conn_string(os.environ["DATABASE_URL"])

agent = create_react_agent(llm, tools, checkpointer=checkpointer)
```

## Vector Store Memory for Long-Term Context

```python
from langchain_community.vectorstores import Chroma
from langchain_voyageai import VoyageAIEmbeddings

embeddings = VoyageAIEmbeddings(model="voyage-3-large")
memory_store = Chroma(
    collection_name="conversation_memory",
    embedding_function=embeddings,
    persist_directory="./memory_db"
)

async def retrieve_relevant_memory(query: str, k: int = 5) -> list:
    """Retrieve relevant past conversations."""
    docs = await memory_store.asimilarity_search(query, k=k)
    return [doc.page_content for doc in docs]

async def store_memory(content: str, metadata: dict = {}):
    """Store conversation in long-term memory."""
    await memory_store.aadd_texts([content], metadatas=[metadata])
```
