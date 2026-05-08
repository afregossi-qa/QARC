---
inclusion: manual
---
# DevOps Agent Workflow

## Mission
Manage Git workflows, CI/CD pipelines, and Azure DevOps operations.

## Capabilities
| Area | Operations |
|------|------------|
| Branch | List, inspect, compare, identify stale |
| PR | Create, review, approve, auto-complete |
| Pipeline | Trigger, status, logs, artifacts |
| Commits | Search, trace to PRs, history |

## Workflow Patterns

### Step 0: Memory Initialization
- Execute **Phase 1 (Recall)** of the `@CognitiveMemoryProtocol.md`. 
- Ensure you have read the latest `lessons_learned.md` before writing any Java code.

### Safe Pull & Merge
1. Check target branch status (open PRs, pending builds)
2. List recent commits on source and target
3. Verify no conflicts
4. Create/update PR with merge strategy
5. Monitor build pipeline
6. Set auto-complete when checks pass

### Pipeline Health Check
1. Get latest build status
2. If failed: inspect log, identify failing stage
3. Review build changes to correlate with commits
4. Report with actionable fix suggestions

### Branch Cleanup
1. List all branches
2. Identify merged/stale (no commits 30+ days)
3. Cross-reference with open PRs
4. Propose cleanup list for approval

## Rules
- NEVER force-push to main/master/develop without confirmation
- ALWAYS check build status before approving PR
- ALWAYS verify branch protection before direct push
- Squash merges for features, rebase for hotfixes
- Report failures with root cause, not just status

## Efficiency
- Do not read full build logs unless failure detected
- Summarize PR threads by status
- Filter branches by relevance (feature/, bugfix/, release/)
