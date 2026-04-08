# Execution Summary: Task #85 — Until/Since Chain Coherence

- **Task**: 85 - Until/Since chain coherence approaches
- **Status**: [COMPLETED]
- **Plan**: plans/02_implementation-plan.md
- **Session**: sess_1775685437_4b0a71

## Results

### Phase 1: Rename X/Y Theorems and Remove Pure X/Y Code [COMPLETED]
- Renamed 8 theorems from X/Y notation to bot-Until/bot-Since notation
- Removed 7 purely X/Y theorems with no active non-Boneyard callers
- Updated 3 call-site files (WitnessSeed, SuccRelation, TemporalContent)

### Phase 2: Remove x_content/y_content Section and Archive Discreteness [COMPLETED]
- Removed x_content, y_content definitions and all dependent infrastructure from TemporalContent.lean (4 sorry sites eliminated)
- Removed G_implies_X, H_implies_Y, and X/Y abbreviations from TemporalDerived.lean
- Archived Discreteness.lean to Boneyard/DiscreteXY/ (1 sorry site eliminated)
- Removed unused TemporalDerived import from TemporalContent.lean

### Phase 3: Fix FMP TruthPreservation Sorry [COMPLETED]
- Replaced sorry at line 263 with `DerivationTree.axiom [] _ (Axiom.temp_4 psi)` (1 sorry eliminated)
- The temp_4 (G-transitivity) axiom was available but marked as removed

### Phase 4: Investigate BX7 Linearity for bx_le Totality [COMPLETED - INVESTIGATION]
- **Finding**: BX7 (linearity of Until) cannot directly prove bx_le totality
- **Root cause**: bx_le is defined via g_content (universal future), while BX7 provides linearity of Until witnesses -- a semantic mismatch
- **Viable paths**: Redefine bx_le using Until-based witness ordering, or adopt quasimodel approach
- 4 sorry sites in Frame.lean remain; comments updated with investigation findings
- No code changes beyond documentation

### Phase 5: Clean Up X/Y Comments Across Codebase [COMPLETED]
- Updated comments in 9 files to replace x_content/y_content with bot-Until/bot-Since terminology
- Updated DeterministicFMCS/DeterministicChain references to note Boneyard archival
- Updated DovetailedChain deprecation notice to point to BXCanonical path

### Phase 6: Truth Lemma Refactoring and Sorry Summary Update [COMPLETED]
- Defined `BFMCS.restricted_forward_until_since_coherent` in TemporalCoherence.lean
- Scopes forward coherence to `subformulaClosure(root)` for truth lemma precision
- Added `forward_implies_restricted_forward` showing full implies restricted

## Sorry Impact

| Phase | Action | Sorry Delta |
|-------|--------|-------------|
| Phase 1 | Rename X/Y theorems | 0 |
| Phase 2 | Remove x/y_content + archive Discreteness | -5 |
| Phase 3 | Fix FMP temp_4 sorry | -1 |
| Phase 4 | BX7 investigation (no proof changes) | 0 |
| Phase 5 | Comment cleanup | 0 |
| Phase 6 | Restricted coherence definition | 0 |
| **Total** | | **-6** |

## Final Metrics

- **Sorry count (active, non-Boneyard)**: ~242 (estimated, grep-based)
- **New axiom declarations**: 0
- **Build status**: passing (944 jobs)
- **Files modified**: 15 Lean files, 1 Markdown file
- **Files archived**: 1 (Discreteness.lean -> Boneyard/DiscreteXY/)

## Artifacts

- `specs/085_until_since_chain_coherence/plans/02_implementation-plan.md` (all phases [COMPLETED])
- `specs/085_until_since_chain_coherence/summaries/02_execution-summary.md` (this file)
- `Theories/Bimodal/Boneyard/DiscreteXY/Discreteness.lean` (archived)
