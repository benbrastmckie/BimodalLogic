# Specs

Task artifacts for the ProofChecker project.

## Structure

Each task has a directory: `specs/{N}_{SLUG}/`

Within each task directory:
- `reports/` - Research reports (research-001.md, etc.)
- `plans/` - Implementation plans (implementation-001.md, etc.)
- `summaries/` - Implementation summaries (implementation-summary-{DATE}.md)

## Key Files

| File | Description |
|------|-------------|
| TODO.md | Task list and status tracking |
| ROAD_MAP.md | Project roadmap and architecture |
| state.json | Machine-readable task state |
| errors.json | Error tracking |

## Artifact Naming

- Research: `research-{NNN}.md` (e.g., research-001.md)
- Plans: `implementation-{NNN}.md` (e.g., implementation-001.md)
- Summaries: `implementation-summary-{DATE}.md` (e.g., implementation-summary-20260316.md)

## Status Markers

Tasks use status markers: `[NOT STARTED]`, `[RESEARCHING]`, `[RESEARCHED]`,
`[PLANNING]`, `[PLANNED]`, `[IMPLEMENTING]`, `[COMPLETED]`, `[BLOCKED]`,
`[ABANDONED]`, `[PARTIAL]`, `[EXPANDED]`

---

*Last Updated: 2026-03-16*
