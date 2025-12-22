# Implementation Plan: Refine ModelBuilder architecture using Frame deltas and Frame insights

**Project**: #122 — refine_modelbuilder_architecture_using_frame_deltas_and_frame_insights  
**Version**: 001  
**Date**: 2025-12-22  
**Complexity**: Moderate  
**Effort Estimate**: 3–4 hours  
**Status**: Planning (doc-only; no code changes)

## Overview
Refine the ModelBuilder architecture using Frame-derived patterns (capability manifests, validation/safety gates, deterministic scoring/pruning, layered caches, provenance-first contracts). Produce updated architecture deltas with task mappings (91–104) and compatibility notes for all pipeline phases without creating new project directories beyond this plan.

## Research Inputs
- **Research Inputs: none linked** (Task 118 research available but not explicitly linked in TODO entry; reuse `docs/research/frame-architecture-insights.md` and `architecture/architecture-delta-from-frame.md` as sources.)

## Goals / Scope
- Confirm and document ≥5 Frame-aligned architecture deltas with citations in `architecture/architecture-delta-from-frame.md`.
- Map each delta to TODO tasks 91–104 and to pipeline phases FLF, SRS, SMS, SCP, SRI.
- Add refinement summary and compatibility notes to `docs/research/frame-architecture-insights.md` tying recommendations to ModelBuilder phases.
- Capture backlog mapping for FLF→SRI covering: capability manifests, pre-flight validation/safety gates, deterministic scoring/pruning, layered caches, provenance-first data contracts.
- Enumerate cross-cutting quality gates across FLF→SRS→SMS→SCP→SRI.
- Keep task plan/research-ready (no code changes; no new project dirs beyond this plan).

## Out of Scope / Non-goals
- Implementing code changes, APIs, or runtime caches.
- Creating new Frame research artifacts.
- Altering task statuses in TODO beyond plan link attachment.

## Assumptions / Constraints
- Task 118 Frame research is complete and available for citations.
- Task 105 confirmation of Frame artifacts is pending; current mappings marked “assumed” must be revisited post-105.
- Task 103 scope is undefined; leave explicit placeholder.
- Lazy directory creation must be preserved (no new directories except this plan path and state file).
- All updates remain documentation/planning only.

## Risks & Mitigations
- **Citation gaps or unconfirmed deltas (Task 105 pending):** Mark “needs confirmation” and cite existing Frame sources; add TODO for post-105 refresh.
- **Mapping incompleteness (Task 103 missing scope):** Add placeholder row and note dependency on future scope definition.
- **Acceptance criteria miss (insufficient deltas or mappings):** Use verification checklist (see Testing/Verification) before completion.
- **Overhead / scope creep:** Timebox per phase; keep owners as "TBD" to avoid blocking.

## Dependencies
- **Upstream research:** Task 118 (Frame review) — use as primary evidence.  
- **Pending confirmation:** Task 105 (Frame analysis) — needed to remove “assumed” markers and finalize citations.  
- **Task scopes:** TODO 91–104 for mapping alignment.  
- **Docs for context:** `architecture/architecture-delta-from-frame.md`, `docs/research/frame-architecture-insights.md`, `docs/guides/pipeline_overview.md`.

## Technology / Artifacts
- Markdown documents only; no code or external libraries.  
- Targets: `architecture/architecture-delta-from-frame.md`, `docs/research/frame-architecture-insights.md`, `docs/guides/pipeline_overview.md` (cross-references only if needed).

## Backlog Mapping (FLF → SRS → SMS → SCP → SRI)
Focus areas: Capability manifests (CM), Validation/Safety gates (VS), Deterministic scoring/pruning (DS), Layered caches (LC), Provenance-first contracts (PV).

| Phase | CM | VS | DS | LC | PV |
| --- | --- | --- | --- | --- | --- |
| FLF | Operator selector manifests; capabilities + inputs | Pre-flight schema checks for inputs; safety caps | Deterministic operator scoring/pruning with audited tie-breaks | N/A (note: avoid cache pre-creation) | Provenance tags on extracted fragments |
| SRS | Template/instantiator manifests | FLF→SRS validation, relevance thresholds | Deterministic template relevance scoring | Template catalog cache (lazy creation) | ID round-trip + provenance retention |
| SMS | Transition engine manifests | SRS→SMS schema/compatibility checks | Deterministic conflict resolution + pruning | Optional transition memoization (lazy) | Transitions carry SRS IDs/provenance |
| SCP | Scenario generator manifests | SMS compatibility + constraint checks | Deterministic scenario pruning (rule-based) | Layered fragment/context caches (lazy) | Scenario provenance back to SMS/SRS |
| SRI | Inference backend manifests | Pre-flight validation, resource/time caps | Deterministic backend selection + tie-breaks | Backend result cache (opt-in, lazy) | Inference traces tied to upstream IDs |

## Mapping Deltas to Tasks 91–104 (planned updates)
- Ensure ≥5 confirmed deltas; cite Frame sources; mark “assumed pending Task 105” where needed.

| Task | Delta Alignment | Notes / Citations |
| --- | --- | --- |
| 91 (Data models/validation) | FLF/SRS schemas with provenance & confidence bands; enforce ID round-trip | Cite Frame validation gates; mark assumed if Task 105 pending |
| 92 (Dev env/CI) | Add validation/safety gates + provenance checks to CI; logging taxonomy | Cite Frame validation gates; ensure no new dirs |
| 93 (FLF pipeline) | Operator manifests, deterministic scoring/pruning, structured logging | Cite dual-model scoring/pruning; provenance tags |
| 94 (Security framework) | Safety gates + redaction rules for logs/manifests | Cite Frame context protection; note PII guardrails |
| 95 (Testing infra) | Regression suites for validation gates, pruning determinism, provenance | Cite QA/validation practices |
| 96 (Performance) | Measure overhead of gates/caches; cache hit-rate telemetry | Cite cache recommendations; lazy creation |
| 97 (SRS generation) | Template manifests, relevance gates, deterministic scoring | Cite layered templates + scoring |
| 98 (API) | Expose capability manifests + validation results in API responses | Cite capability manifest pattern |
| 99 (Error/logging) | Structured logging taxonomy + audit trails for gates/pruning | Cite logging/traceability patterns |
| 100 (Documentation) | Document manifests, gates, provenance-first contracts | Cite Frame documentation alignment |
| 101 (SMS construction) | Typed transitions, deterministic conflict resolution, provenance | Cite determinism + audit trails |
| 102 (Phases 4–5 strategy) | Context layering + backend manifests planning | Cite context layering |
| 103 (TBD) | Placeholder pending scope definition | Mark TBD |
| 104 (State cleanup) | Reflect manifest/provenance fields; ensure lazy directory creation | Cite lazy creation + data contract hygiene |

## Cross-Cutting Quality Gates (to enumerate/update)
- Validation Gate: FLF→SRS and SRS→SMS schema/provenance checks with fail-fast errors.  
- Safety/Resource Gate: Timeouts, size caps, solver circuit breakers.  
- Capability Manifests: Declarative requirements for selectors, templates, transition engines, scenario generators, inference backends.  
- Deterministic Scoring/Pruning: Dual-model scoring + audited tie-breaks; seed control.  
- Provenance & Traceability: IDs propagated FLF→SRS→SMS→SCP→SRI; inference traces preserved.  
- Structured Logging/Telemetry: Standard fields + redaction; correlation IDs.  
- Layered Caches: Versioned, lazy-created caches with hit/miss telemetry.  
- Lazy Directory Creation: No directories created until writing artifacts; preserve guardrails.

## Phases & Tasks (1–2h each, owners TBD)
1) **Recon & Extraction (0.75–1h)**  
   - Re-read architecture delta draft and Frame insights; list current deltas and citations.  
   - Identify assumed vs confirmed mappings; note Task 105 dependencies.

2) **Backlog Mapping & Quality Gates (1–1.25h)**  
   - Expand per-phase backlog mapping (FLF→SRI) across CM/VS/DS/LC/PV.  
   - Fill task 91–104 mapping table; add placeholder for 103.  
   - Draft cross-cutting gates with references to lazy creation and provenance.

3) **Document Updates (1–1.25h)**  
   - Update `architecture/architecture-delta-from-frame.md` with ≥5 confirmed deltas, citations, resolved assumptions, and explicit mappings to tasks 91–104.  
   - Add backlog mapping and quality gates list; include checkpoints for citations.  
   - Update `docs/research/frame-architecture-insights.md` with concise refinement summary + compatibility notes tied to phases and delta doc.

4) **Verification & Wrap (0.5h)**  
   - Run acceptance checklist (see Testing/Verification).  
   - Ensure links left for future /plan or /research artifacts; no new dirs created beyond this plan.  
   - Record assumptions requiring Task 105 follow-up.

## Deliverables
- Updated `architecture/architecture-delta-from-frame.md` with ≥5 Frame-aligned deltas, citations, mappings to tasks 91–104, backlog mapping, and quality gates.  
- Updated `docs/research/frame-architecture-insights.md` with refinement summary and compatibility notes tied to phases.  
- Cross-references to `docs/guides/pipeline_overview.md` only if needed (no structural changes planned).

## Testing / Verification (for documentation updates)
- Checklist before completion:  
  - ≥5 deltas present, each with Frame citation.  
  - Task mapping table covers 91–104; Task 103 marked TBD.  
  - Backlog mapping covers CM/VS/DS/LC/PV across all phases.  
  - Cross-cutting gates enumerated and include lazy directory creation.  
  - Compatibility notes added to Frame insights; links to delta doc.  
  - No new directories beyond plan/state; lazy creation guardrails preserved.  
- Self-review for clarity and alignment with acceptance criteria.

## Timeline / Estimates
- Total: 3–4 hours.  
- Phase 1: 0.75–1h; Phase 2: 1–1.25h; Phase 3: 1–1.25h; Phase 4: 0.5h.

## Success Criteria
- Acceptance criteria satisfied (≥5 deltas with citations; mappings to tasks 91–104; backlog mapping and quality gates documented; compatibility notes added).  
- Plan remains research-ready with no unintended directory creation.  
- Clear TODOs for Task 105 confirmations and Task 103 scope.

## Notes
- Keep owners as TBD to avoid blocking; link future /plan or /research artifacts when created.  
- Maintain lazy directory creation across any future updates.
