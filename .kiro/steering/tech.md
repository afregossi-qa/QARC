---
inclusion: manual
---

# Technical Stack

> Load manually via `#tech` in chat. Customize this file to match your project's architecture.

## Architecture

<!-- Document your system's key components. Example: -->
<!-- - **Backend Services**: User API, Config API -->
<!-- - **Application**: Desktop/Mobile/Web client -->
<!-- - **Database**: SQL/NoSQL/Collections-based storage -->

- **Backend Services**: TODO
- **Application**: TODO
- **Database**: TODO

## Key Technologies

<!-- List the technologies and patterns your project uses. Example: -->
<!-- - REST APIs with delta-time filtering support -->
<!-- - Repository pattern for data persistence -->
<!-- - Generic `SyncResult<T>` pattern for standardized sync operations -->

- TODO: Technology/pattern 1
- TODO: Technology/pattern 2

## API Patterns

### Delta-Time Sync Endpoints

<!-- Document your API patterns. Example: -->
<!-- All configuration endpoints support optional `modifiedFrom` query parameter: -->
<!-- - Without parameter: Returns full dataset (initial sync) -->
<!-- - With parameter: Returns only entities modified since timestamp (incremental sync) -->

TODO: Document your API patterns here.

## Testing Approach

### Test Types
- **Functional Testing**: API response validation, data integrity
- **Integration Testing**: Multi-entity sync, parallel testing
- **Performance Testing**: Full vs incremental sync comparison
- **Regression Testing**: Ensure existing functionality unchanged
- **Security Testing**: Permission cache consistency

### Test Priorities
- **P0 (Critical)**: Must pass before production
- **P1 (High)**: Should pass, non-blocking
- **P2 (Medium)**: Nice to have

### Automation
Target 80%+ automation coverage for regression and functional tests.

## Common Testing Commands

<!-- Add your project's test commands as you discover them. Example: -->
<!-- - `npm test` — Run unit tests -->
<!-- - `npm run e2e` — Run end-to-end tests -->

_Note: Add your project's specific commands here._

## Development Workflow

<!-- Document your team's workflow. Example: -->
<!-- - Feature branches merged to `develop` -->
<!-- - Pull requests require QA validation -->
<!-- - Parallel testing required for related features -->

- TODO: Document your workflow
