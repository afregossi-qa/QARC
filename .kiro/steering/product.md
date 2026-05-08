---
inclusion: manual
---

# Product Overview — How It Works

> This file is the **source of truth** for how your product works. It is updated by the Cognitive Memory Protocol's Refinement phase when lessons are promoted from `lessons_learned.md`. Load manually via `#product` in chat.

## Domain

<!-- Describe your product domain in 1-2 sentences. Example: -->
<!-- Point of Sale (POS) system for retail operations with multi-location employee management and configuration synchronization. -->

TODO: Describe your product domain here.

## Core Features

<!-- List the main features your product provides. Example: -->
<!-- - Employee and Job Title management across operational units -->
<!-- - Delta-based configuration synchronization -->
<!-- - Permission evaluation and caching -->

- TODO: Feature 1
- TODO: Feature 2
- TODO: Feature 3

## Key Business Concepts

<!-- Define domain terms that agents need to understand. Example: -->
<!-- - **Operational Units**: Individual store locations or business units -->
<!-- - **Delta Sync**: Incremental synchronization using modification timestamps -->

- **TODO Term 1**: Definition
- **TODO Term 2**: Definition

## Configuration Sync

<!-- Document your sync triggers and behavior. Example: -->

| Trigger | Type | When | Behavior |
|---------|------|------|----------|
| Startup Sync | Full | Every app launch | Downloads everything fresh |
| Background Sync | Incremental | Every ~30 min | Uses delta timestamps |
| TODO | TODO | TODO | TODO |

## Current Development Focus

<!-- List active feature tickets being tested. Example: -->
<!-- - Delta-based config downloads (PROJ-1234) -->
<!-- - New payment integration (PROJ-5678) -->

- TODO: Active ticket 1
- TODO: Active ticket 2
