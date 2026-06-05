# QARC Setup Guide

How to configure this framework for your project.

---

## 1. Prerequisites

| Tool | Version | Purpose |
|------|---------|---------|
| [Kiro IDE](https://kiro.dev) | Latest | Runtime environment for agents and hooks |
| [uv](https://docs.astral.sh/uv/getting-started/installation/) | Latest | Python package runner — runs Atlassian MCP via `uvx` |
| [Node.js](https://nodejs.org/) | 18+ | Runs AIO Tests, Azure DevOps, and Image Extractor MCPs via `npx` |

---

## 2. Configure MCP Servers

```bash
cp .kiro/settings/mcp.example.json .kiro/settings/mcp.json
```

Edit `.kiro/settings/mcp.json` and fill in your credentials:

### Required Servers

| Server | Command | Credential | Where to get it |
|--------|---------|-----------|-----------------|
| **Atlassian** | `uvx mcp-atlassian` | Jira/Confluence API Token | [Atlassian API Tokens](https://id.atlassian.com/manage-profile/security/api-tokens) |
| **Image Extractor** | `npx mcp-image-extractor` | None (no auth needed) | Auto-installed via npx |

### Optional Servers

| Server | Command | Credential | Where to get it |
|--------|---------|-----------|-----------------|
| **Azure DevOps** | `npx @azure-devops/mcp {ORG}` | Personal Access Token (Code Read scope) | Azure DevOps → User Settings → PATs |
| **AIO Tests** | `node .kiro/mcp-servers/aio-tests/index.js` | AIO API Token | AIO Tests → Settings → API |

**Disable servers you don't use** by setting `"disabled": true` in the config.

### Auto-Approve (Recommended)

For smoother pipeline execution, add frequently-used tools to `autoApprove` arrays:

```json
"atlassian": {
  "autoApprove": [
    "jira_get_issue", "jira_search", "jira_download_attachments",
    "jira_get_issue_images", "confluence_search", "confluence_get_page"
  ]
},
"image-extractor": {
  "autoApprove": ["extract_image_from_file"]
}
```

---

## 3. Initialize Memory (Shared Brain)

The Shared Brain uses a structured memory layout. Copy templates to create your working memory:

```bash
# Create the memory folder structure
mkdir -p .kiro/memory/universal
mkdir -p .kiro/memory/products/your-product

# Copy templates
cp .kiro/memory-templates/universal/*.md .kiro/memory/universal/
cp .kiro/memory-templates/products/pos/*.md .kiro/memory/products/your-product/
```

| File | What it does |
|------|-------------|
| `products/{name}/project_context.md` | Your module map, service relationships, architecture |
| `products/{name}/lessons_learned.md` | Grows automatically as agents discover patterns |
| `products/{name}/pattern_registry.md` | Error signatures and diagnostic paths |
| `universal/` | Cross-product knowledge shared across all projects |
| `cognitive-memory-protocol.md` | The RECALL-RELATE-LEARN protocol (don't edit) |

These files start mostly empty. They fill up as you use the pipeline — the `learn-on-findings` hook auto-appends after every ticket closure.

---

## 4. Customize Product Context

Edit `.kiro/memory/products/{your-product}/project_context.md` with:

- Module relationships and dependencies
- Key services and their responsibilities
- API endpoints and sync behavior
- Database collections and their content
- Environment architecture (prod vs dev vs QA)

This is the most impactful file — it teaches agents how your product actually works.

---

## 5. Verify Installation

Run this checklist after setup:

| Check | How |
|-------|-----|
| Atlassian MCP connects | Ask Kiro: "fetch issue PROJ-123" |
| Image Extractor works | Drop a screenshot in a folder, ask Kiro to describe it |
| Azure DevOps connects | Ask Kiro: "show recent PRs in {repo}" |
| AIO Tests connects | Ask Kiro: "list test cases for PROJ" |
| Hooks are visible | Open Kiro hooks panel — should see "Trigger Expert", "Trigger Reviewer", etc. |

---

## 6. Customization Tips

| Want to... | Do this |
|-----------|---------|
| Skip AIO Tests | Set `"disabled": true` on aio-tests server |
| Skip Azure DevOps | Set `"disabled": true` on azure-devops server |
| Add domain knowledge | Edit `products/{name}/project_context.md` |
| Change hook behavior | Edit files in `.kiro/hooks/` |
| Add a custom agent | Create a new `.json` in `.kiro/agents/` |
| Change test case format | Edit `.kiro/steering/TestCasesDesign.md` |

---

## 7. Troubleshooting

| Problem | Solution |
|---------|----------|
| `uvx` not found | Install uv: `pip install uv` or `brew install uv` |
| `npx` not found | Install Node.js from https://nodejs.org |
| MCP server won't connect | Run the command manually in terminal to see errors |
| Agent doesn't trigger | Check hook patterns in `.kiro/hooks/` match your file structure |
| Agent hallucinates | Add more context to `project_context.md` |
| Images not analyzed | Verify `image-extractor` server is enabled and not disabled |
