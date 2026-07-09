# Observability, Streaming, and Performance

## LangSmith Tracing

LangSmith is the standard for observability: request/response logging, token usage, latency, errors, trace visualization.

```python
import os
from langchain_anthropic import ChatAnthropic

# Enable LangSmith tracing. Export LANGCHAIN_API_KEY from .env or secret store,
# never inline the key in source.
os.environ["LANGCHAIN_TRACING_V2"] = "true"
os.environ["LANGCHAIN_PROJECT"] = "my-project"
assert os.environ.get("LANGCHAIN_API_KEY"), "LANGCHAIN_API_KEY must be set"

# All LangChain/LangGraph operations are automatically traced
llm = ChatAnthropic(model="claude-sonnet-4-6")
```

## Custom Callback Handler

```python
from langchain_core.callbacks import BaseCallbackHandler
from typing import Any, Dict, List

class CustomCallbackHandler(BaseCallbackHandler):
    def on_llm_start(
        self, serialized: Dict[str, Any], prompts: List[str], **kwargs
    ) -> None:
        print(f"LLM started with {len(prompts)} prompts")

    def on_llm_end(self, response, **kwargs) -> None:
        print(f"LLM completed: {len(response.generations)} generations")

    def on_llm_error(self, error: Exception, **kwargs) -> None:
        print(f"LLM error: {error}")

    def on_tool_start(
        self, serialized: Dict[str, Any], input_str: str, **kwargs
    ) -> None:
        print(f"Tool started: {serialized.get('name')}")

    def on_tool_end(self, output: str, **kwargs) -> None:
        print(f"Tool completed: {output[:100]}...")

# Use callbacks
result = await agent.ainvoke(
    {"messages": [("user", "query")]},
    config={"callbacks": [CustomCallbackHandler()]}
)
```

## Streaming Responses

```python
from langchain_anthropic import ChatAnthropic

llm = ChatAnthropic(model="claude-sonnet-4-6", streaming=True)

# Stream tokens
async for chunk in llm.astream("Tell me a story"):
    print(chunk.content, end="", flush=True)

# Stream agent events
async for event in agent.astream_events(
    {"messages": [("user", "Search and summarize")]},
    version="v2"
):
    if event["event"] == "on_chat_model_stream":
        print(event["data"]["chunk"].content, end="")
    elif event["event"] == "on_tool_start":
        print(f"\n[Using tool: {event['name']}]")
```

## Performance Optimization

### Caching with Redis

```python
from langchain_community.cache import RedisCache
from langchain_core.globals import set_llm_cache
import redis

redis_client = redis.Redis.from_url("redis://localhost:6379")
set_llm_cache(RedisCache(redis_client))
```

### Async Batch Processing

```python
import asyncio
from langchain_core.documents import Document

async def process_documents(documents: list[Document]) -> list:
    """Process documents in parallel."""
    tasks = [process_single(doc) for doc in documents]
    return await asyncio.gather(*tasks)

async def process_single(doc: Document) -> dict:
    """Process a single document."""
    chunks = text_splitter.split_documents([doc])
    embeddings = await embeddings_model.aembed_documents(
        [c.page_content for c in chunks]
    )
    return {"doc_id": doc.metadata.get("id"), "embeddings": embeddings}
```

### Connection Pooling

```python
from langchain_pinecone import PineconeVectorStore
from pinecone import Pinecone

# Reuse Pinecone client
pc = Pinecone(api_key=os.environ["PINECONE_API_KEY"])
index = pc.Index("my-index")

# Create vector store with existing index
vectorstore = PineconeVectorStore(index=index, embedding=embeddings)
```
