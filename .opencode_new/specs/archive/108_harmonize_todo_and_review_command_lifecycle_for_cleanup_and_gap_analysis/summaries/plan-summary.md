# Plan Summary: Harmonize /todo and /review command lifecycle for cleanup and gap analysis

**Version**: 001  
**Complexity**: complex  
**Estimated Effort**: 3–6 hours

## Key Steps

1. Codify lifecycle rules and guardrails (cleanup vs gap-analysis, numbering/lazy creation)
2. Build shared detection/normalization helpers and wire /todo cleanup + archival flow
3. Extend /review gap-analysis to propose tasks via /add, add validation/reporting, and update status docs

## Dependencies

- state-schema.md, tasks.md, status-markers.md, artifact-management.md
- .opencode/command/{todo,review}.md and lifecycle helper utilities
- TODO/state/archive/state files plus Feature Registry and Implementation Status docs

## Success Criteria

- /todo cleans, archives, and syncs TODO/state/archive/status docs without creating new directories or changing numbering
- /review generates tasks via /add with numbering intact and no cleanup side effects

## Full Plan

See: ../plans/implementation-001.md
