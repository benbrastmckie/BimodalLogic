# Implementation Plan: Update README Metalogic Progress

- **Task**: 158 - Update README.md to reflect metalogic progress in BimodalLogic
- **Status**: [COMPLETED]
- **Effort**: 3 hours
- **Dependencies**: None
- **Research Inputs**: specs/158_update_readme_metalogic_progress/reports/01_team-research.md
- **Artifacts**: plans/01_readme-overhaul-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: markdown
- **Lean Intent**: false

## Overview

The README.md is significantly outdated: it reports 162 files / ~30K LOC (actual: 189 / ~43K), omits the Until (U) and Since (S) operators, never mentions Logos Laboratories, links to sorry-laden example files, and overclaims completeness across all frame classes. This plan rewrites the README following the research-recommended section ordering, removes or demotes stale pedagogical artifacts, and adds a labeled mermaid diagram of the frame hierarchy with per-class metalogical results. The definition of done is a README that is accurate, well-organized, concise, and honest about the 1 remaining sorry on the discrete completeness path.

### Research Integration

The team research report (4 teammates) provided: updated codebase statistics (189 files, 42,706 LOC, 28,421 comments); the complete operator inventory including U/S primitives and derived operators; the 3-tier frame hierarchy (Base/Dense/Discrete) as the natural mermaid diagram structure; per-frame metalogical results with sorry status; cleanup targets (6 example files with ~65 sorries, 4 pedagogical docs to remove); the "task semantics" terminology note; paper URL inconsistency; CI badge availability; and a recommended 13-section README ordering.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

- The README rewrite advances the Phase 5 "Publication quality" roadmap item by ensuring external documentation accurately reflects the formalization state.
- Honest sorry reporting (1 sorry on discrete completeness critical path) aligns with the roadmap's "Sorry summary" tracking.

## Goals & Non-Goals

**Goals**:
- Rewrite README.md with accurate statistics, complete operator table, Logos context, and frame-class-organized metalogical results
- Add a mermaid diagram showing the Base/Dense/Discrete frame hierarchy with soundness/completeness status
- Remove sorry-laden example files and stale pedagogical docs from the codebase
- Add CI badge, streamlined installation, curated documentation links, citation section with BibTeX, and related projects
- Reconcile the inconsistent paper URL to a single canonical link

**Non-Goals**:
- Fixing the remaining sorry in discrete completeness (that is task 140)
- Rewriting any Lean source code (only removing sorry-laden example files)
- Hosting BimodalReference.pdf externally
- Adding new documentation pages (only curating links to existing ones)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Removing example files breaks `lake build` due to import dependencies | H | M | Run `lake build` after removal; check imports in parent module files |
| Mermaid diagram renders poorly on GitHub mobile | L | M | Keep diagram to 3-4 nodes max; test rendering on GitHub |
| Paper URL chosen is incorrect or will change | M | L | Confirm with user which URL is canonical before committing |
| Removing USING_GIT.md / GETTING_STARTED.md upsets contributors | L | L | These are not linked from CONTRIBUTING.md; removal is safe |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |

Phases within the same wave can execute in parallel.

### Phase 1: Cleanup Stale Artifacts [COMPLETED]

**Goal**: Remove sorry-laden example files and irrelevant pedagogical docs so the README can link only to clean artifacts.

**Tasks**:
- [ ] Remove sorry-laden example Lean files (6 files):
  - `Theories/Bimodal/Examples/TemporalProofs.lean` (30 sorries)
  - `Theories/Bimodal/Examples/TemporalProofStrategies.lean` (19 sorries)
  - `Theories/Bimodal/Examples/ModalProofs.lean` (5 sorries)
  - `Theories/Bimodal/Examples/ModalProofStrategies.lean` (5 sorries)
  - `Theories/Bimodal/Examples/BimodalProofStrategies.lean` (2 sorries)
  - `Theories/Bimodal/Examples/Demo.lean` (4 sorries)
- [ ] Update `Theories/Bimodal/Examples.lean` (or equivalent module root) to remove imports of deleted files
- [ ] Remove irrelevant docs:
  - `docs/installation/USING_GIT.md`
  - `docs/installation/GETTING_STARTED.md`
  - `docs/installation/CLAUDE_CODE.md`
  - `docs/tts-stt-integration.md`
- [ ] Run `lake build` to verify no broken imports
- [ ] Run `lake test` to verify tests still pass

**Timing**: 45 minutes

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Examples/TemporalProofs.lean` - delete
- `Theories/Bimodal/Examples/TemporalProofStrategies.lean` - delete
- `Theories/Bimodal/Examples/ModalProofs.lean` - delete
- `Theories/Bimodal/Examples/ModalProofStrategies.lean` - delete
- `Theories/Bimodal/Examples/BimodalProofStrategies.lean` - delete
- `Theories/Bimodal/Examples/Demo.lean` - delete
- `Theories/Bimodal/Examples.lean` (or parent module) - remove deleted imports
- `docs/installation/USING_GIT.md` - delete
- `docs/installation/GETTING_STARTED.md` - delete
- `docs/installation/CLAUDE_CODE.md` - delete
- `docs/tts-stt-integration.md` - delete

**Verification**:
- `lake build` succeeds with no new errors
- `lake test` passes
- Only `BimodalProofs.lean` (0 sorries), `TemporalStructures.lean` (0 sorries), and `README.md` remain in Examples/

---

### Phase 2: Rewrite README.md [COMPLETED]

**Goal**: Replace the current README with a well-organized document following the research-recommended 13-section structure, with accurate statistics, complete operators, Logos context, mermaid diagram, and honest metalogic reporting.

**Tasks**:
- [ ] Write new README.md header: title + CI badge + one-sentence description
- [ ] Write Logos context paragraph: explain this is the intensional bimodal fragment of the Logos, link to https://logos-labs.ai/, briefly explain "intensional" (compositional possible-worlds semantics vs. extensional/truth-functional)
- [ ] Write paper/specification/demo links block: reconcile to single canonical paper URL, link to BimodalReference.pdf, point demo to `BimodalProofs.lean` (sorry-free replacement for Demo.lean)
- [ ] Write codebase size table with accurate numbers (189 files, ~43K LOC, ~28K comments) at end of intro area per user request
- [ ] Write complete operators table including Until (U), Since (S), perpetuity (always/sometimes), next (X), prev (Y)
- [ ] Write Task Frame Semantics section: brief paragraph explaining terminology, note it comes from companion paper, relate to non-deterministic dynamical systems
- [ ] Write Project Structure section: updated directory tree highlighting Metalogic/ subdirectories
- [ ] Write Installation section: streamlined (elan + lake build), remove references to deleted guides, keep link to BASIC_INSTALLATION.md
- [ ] Write Metalogical Results section:
  - Mermaid diagram with 3 labeled nodes (Base/Dense/Discrete) showing frame hierarchy
  - Results table per frame class (Base: soundness, completeness, decidability -- all sorry-free; Dense: soundness, completeness -- sorry-free; Discrete: soundness sorry-free, completeness has 1 sorry remaining)
  - Be transparent: "1 sorry remaining on the discrete completeness critical path"
- [ ] Write Documentation section: curated links only -- remove beginner guides, keep reference docs, tutorial, contributing
- [ ] Write Related Projects section: ModelChecker + Logos Labs
- [ ] Write Citation section: BibTeX for paper and software, key literature references (Burgess 1982, Xu 1988, Reynolds 1994, Venema 1993)
- [ ] Write License section
- [ ] Remove the old "Codebase Size" section from the bottom (moved to intro area)
- [ ] Remove the old "Contributing" section with redundant setup instructions (merged into Installation)
- [ ] Remove the old "Implementation Status" section (replaced by Metalogical Results)
- [ ] Remove the old "Theoretical Foundations" section (merged into overview and metalogic)

**Timing**: 1.5 hours

**Depends on**: 1

**Files to modify**:
- `README.md` - complete rewrite

**Verification**:
- README contains all 13 recommended sections in order
- No links to deleted files (Demo.lean, USING_GIT.md, GETTING_STARTED.md, CLAUDE_CODE.md)
- Codebase statistics match actual numbers
- Operators table includes U, S, next, prev, always, sometimes
- Mermaid diagram renders correctly (3 nodes, labeled)
- Sorry count is accurately reported (1 remaining on discrete path)
- Single canonical paper URL used throughout
- CI badge URL is correct

---

### Phase 3: Verification and Polish [COMPLETED]

**Goal**: Validate all links, mermaid rendering, and build integrity after the full rewrite.

**Tasks**:
- [ ] Check all internal file links in README (verify each linked file exists)
- [ ] Check all external URLs (paper, Logos Labs, GitHub Actions badge, ModelChecker repo)
- [ ] Verify mermaid diagram renders correctly by reviewing markdown syntax
- [ ] Run `lake build` one final time to confirm clean state
- [ ] Review README for conciseness: remove any verbose explanations, tighten wording
- [ ] Verify `docs/installation/README.md` does not link to deleted files; update if needed
- [ ] Verify `Theories/Bimodal/Examples/README.md` is still accurate after file removals; update if needed

**Timing**: 45 minutes

**Depends on**: 2

**Files to modify**:
- `README.md` - minor link fixes and wording polish
- `docs/installation/README.md` - update to remove references to deleted guides
- `Theories/Bimodal/Examples/README.md` - update to reflect remaining files only

**Verification**:
- All internal links resolve to existing files
- All external URLs are syntactically correct
- `lake build` passes
- README reads clearly for target audience (formal methods researchers)

## Testing & Validation

- [ ] `lake build` succeeds after example file removal (Phase 1)
- [ ] `lake test` passes after example file removal (Phase 1)
- [ ] No broken imports in any `.lean` file referencing deleted examples
- [ ] All internal README links resolve to existing files
- [ ] Mermaid diagram renders on GitHub (3-node frame hierarchy)
- [ ] Codebase statistics in README match `cloc` output
- [ ] Single canonical paper URL used throughout
- [ ] CI badge URL matches `.github/workflows/ci.yml` workflow name
- [ ] Sorry count accurately reflects current codebase state

## Artifacts & Outputs

- `plans/01_readme-overhaul-plan.md` (this file)
- `README.md` (rewritten)
- `docs/installation/README.md` (updated links)
- `Theories/Bimodal/Examples/README.md` (updated after removals)

## Rollback/Contingency

All changes are to tracked files. If the README rewrite is unsatisfactory or the build breaks after example removal:
1. `git checkout HEAD -- README.md` restores the previous README
2. `git checkout HEAD -- Theories/Bimodal/Examples/` restores deleted example files
3. `git checkout HEAD -- docs/` restores deleted documentation files
4. Re-run `lake build` to confirm restoration
