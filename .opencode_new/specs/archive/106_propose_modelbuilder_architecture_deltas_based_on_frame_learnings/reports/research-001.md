# Research Report: ModelBuilder architecture deltas from Frame learnings

**Project**: #106  
**Date**: 2025-12-22  
**Research Type**: Architecture delta synthesis

## Research Question
Propose ModelBuilder architecture deltas across FLF, SRS, SMS, SCP, and SRI based on Frame-derived patterns (Task 105), with effort/impact/risk and integration mapping to tasks 91–104.

## Sources Consulted
- Internal: `.opencode/specs/106/.../plans/implementation-001.md`, `Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md`, `FEATURE_REGISTRY.md`
- Standards: `patterns.md`, `artifact-management.md`, `state-schema.md`, `tasks.md`, `task-breakdown.md`
- Frame insights: **Not available** (Task 105 pending) — assumptions noted
- Web research: None

## Frame-to-ModelBuilder Deltas (by phase)
**FLF (fact-level extraction)**
- Enforce explicit data contracts for extracted facts (typed fields, provenance, confidence); add schema validation before SRS handoff.
- Introduce traceable operator selection rules (configurable strategy registry) mirroring Frame’s pluggable selector pattern.
- Add structured logging (per document/segment) with error taxonomy for extraction failures.
- Rationale: Frame emphasizes strong contracts and pluggable selectors to avoid downstream drift.

**SRS (sentence/requirements synthesis)**
- Separate “semantic template library” from instantiation engine; load templates by domain profile.
- Add relevance filter scoring with thresholds + override hooks to align with downstream SMS needs.
- Validate SRS outputs against FLF schema (round-trip ID consistency, required fields).
- Rationale: Frame patterns favor explicit template catalogs, gated relevance, and schema-checked outputs.

**SMS (state machine synthesis)**
- Normalize state representation: typed states, transitions with guards/effects, provenance linking back to SRS IDs.
- Add deterministic resolution for conflicting transitions (priority rules + audit trail).
- Introduce simulation stubs for early validation; emit compatibility metadata for SCP.
- Rationale: Frame uses audited transition rules and deterministic conflict handling.

**SCP (scenario construction/planning)**
- Standardize scenario parameter generator to accept SMS compatibility metadata; add constraints check before expansion.
- Layered context determiner: base context + domain overlays; log constraint violations.
- Cache reusable scenario fragments; version scenario templates.
- Rationale: Frame leans on context layering and fragment reuse to reduce combinatorial blowup.

**SRI (reasoning/inference)**
- Unify inference manager with pluggable proof/model-check backends; declare capabilities and required inputs.
- Add model checker bridge pre-flight validation (input schema, timeout, resource caps).
- Persist inference traces with links to originating SRS/SMS artifacts for explainability.
- Rationale: Frame patterns stress backend declarativity and auditable inference traces.

## Effort / Impact / Risk (estimates)
| Phase | Recommendation | Effort (h) | Impact | Risk | Mitigation |
| --- | --- | --- | --- | --- | --- |
| FLF | Schema validation + operator registry | 4 | High | Medium (retrofit cost) | Start as adapter layer; incrementally tighten schema |
| SRS | Template library separation + relevance gate | 4 | High | Medium (template migration) | Migrate per-domain; add fallback legacy path |
| SMS | Typed transitions + conflict resolution | 5 | High | Medium (state refactors) | Pilot on one domain; add audit logging |
| SCP | Context layering + fragment cache | 3 | Medium | Low | Begin with cache behind flag; monitor hit rate |
| SRI | Pluggable backends + pre-flight checks | 4 | High | Medium (integration complexity) | Define capability manifest; stage rollout per backend |
| Cross-cutting | Structured logging, validation gates, provenance links | 3 | High | Low | Apply via shared middleware/utilities |

## Integration Mapping to Tasks 91–104 (assumptive; confirm scopes)
- Tasks 91–94 (assumed FLF/SRS): Align FLF schema validation and SRS template separation; add relevance gate hooks.
- Tasks 95–97 (assumed SMS): Integrate typed transitions, conflict resolution, provenance links.
- Tasks 98–100 (assumed SCP): Apply context layering, constraints checks, fragment cache.
- Tasks 101–104 (assumed SRI / system cleanup): Wire pluggable inference backends, pre-flight validation, and logging; sync with Task 104 (state cleanup) to ensure manifests and provenance fields are reflected.
- Action: Replace assumptions with actual task scopes once available; add explicit linkage table in `architecture/architecture-delta-from-frame.md`.

## Open Questions / Gaps
- Task 105 outputs missing: need concrete Frame patterns, data contracts, and component interfaces.
- Tasks 91–104 scopes not provided: mapping above is provisional.
- Current ModelBuilder contracts per phase not enumerated; need baseline schemas to diff against Frame patterns.
- Performance/SLO targets absent; may affect design of validation/logging depth and caching strategy.

## Recommended Next Steps for `architecture/architecture-delta-from-frame.md`
1. Ingest Task 105 artifacts; replace assumptions with concrete Frame patterns and data contracts.
2. Document per-phase delta with: current state, proposed change, Frame rationale, effort/impact/risk, and dependencies.
3. Add explicit integration table to tasks 91–104 (confirmed scopes), including sequencing and interface impacts.
4. Define cross-cutting quality gates (validation, logging, security, provenance) as reusable middleware/utilities.
5. Update `docs/guides/pipeline_overview.md` with pointers to the delta doc and note phased changes.
6. Add verification checklist (per plan) and note any remaining gaps.

## Acceptance Coverage (checklist)
- Phase deltas with rationale ✅
- Effort/impact/risk per recommendation ✅
- Integration mapping to tasks 91–104 (assumptive; requires confirmation) ⚠️
- Open questions/gaps captured ✅
- Next steps for architecture-delta doc provided ✅

---

Summary for TODO: Drafted phased ModelBuilder architecture deltas (with effort/impact/risk, integration placeholders for tasks 91–104, and next steps) based on Frame patterns, pending confirmation of Task 105 insights and task scopes.
