---
inclusion: auto
description: Token/context budgeting rules and anti-patterns for all agents
---

# Context & Token Efficiency Standards

## File Size Thresholds

| Size | Action |
|------|--------|
| <5KB | Read fully |
| 5-10KB | Read fully, summarize in response |
| >10KB | Use line ranges or `readCode` with selector |
| >50KB | NEVER read fully — extract specific sections only |

## Data Retrieval Rules
- **Lazy Loading**: Only read files strictly necessary for the current step
- **Selective Scoping**: For logs/JSON evidence, extract first 50 + last 50 lines unless error detected
- **Ignore Assets**: Never read binary files (images, PDFs) directly
- **One-Shot Reads**: Batch multiple file reads into single `readMultipleFiles` call

## Steering File Rules
- Heavy workflow docs (>2KB) MUST use `inclusion: manual`
- Hooks reference steering via `@filename.md` — never embed content
- Keep always-included steering files under 1KB each

## Hook Prompt Limits
- Hook prompts MUST be <500 tokens
- Reference `@steering-file.md` for detailed instructions
- Never embed full workflow steps in hook JSON

## Response Guidelines
- **No Chatter**: Pipeline agents output only structured data
- **Direct Output**: Every response → `fsWrite` or tool call
- **Markdown Compression**: Tables over bullet lists

## Folder Locking
- Agents stay locked to their `[Ticket_ID]/` directory
- Only Dashboard Agent may read across multiple tickets
- Never traverse parent directories unless explicitly required

## Anti-Patterns

| Bad | Good |
|-----|------|
| Reading entire 20KB log | Read first/last 50 lines |
| Embedding workflow in hook | Reference `@qa-workflows.md` |
| Multiple single-file reads | Batch with `readMultipleFiles` |
| Always-include 5KB steering | Use `inclusion: manual` |
