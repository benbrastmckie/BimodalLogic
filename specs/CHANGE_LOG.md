# Change Log


## 2026-08-18: Archive 3 completed tasks

**Archived**:
- **441** (completed, lean4): Effective periodic extension over finite frames -- all ten phases sorry-free with no new axiom; Tier A `IntPresentation.extend_periodic` yields a decidable-coherence `PlacedBiLasso` certificate, Tier B `TaskFrame.extend_periodic` proves the literal existential over an arbitrary `TaskFrame Z` with `[Finite WorldState]` and extends to gapped finite domains; a hand-rolled choice-free pigeonhole on `Fin` removed finiteness from the `Classical.choice` sources
- **440** (completed, lean4): Finite-frame discharge of Spherical and Limit -- `wlem_of_spherical` derives weak excluded middle from Spherical at carrier `Bool` over `D = Int` from exactly `[propext, Quot.sound]`, proving the original "make `spherical_of_finite` choice-free" acceptance test unsatisfiable; four axiom profiles converted into build-breaking `#guard_msgs` guards and verified to gate, five stale `Extension.lean` docstring passages repaired
- **417** (completed, lean4): Semantic FMP over finite `WorldState` on Z -- closed Phase 12 of the bi-lasso decision layer with `check`, `check_correct` and the `Decidable` instance for `SatAtState` sorry-free and off the `Classical.dec` path, added the subdirectory re-export and six C6 manifest entries, and wired four evidence probes in as permanent regression guards via a new `check-evidence-probes.sh`

**Directories moved**: 3 (specs/ -> specs/archive/)
**Roadmap updates**: 0 (no eligible matches against the 111-row status table)
**Memory harvest**: none (no candidates recorded on any archived task)

## 2026-08-17: Archive 4 completed tasks

**Archived**:
- **449** (completed, formal): Revised the Bimodal Reference Manual to the Since/Until-primitive target state -- CONFIRM tag convention, infix guard-first notation, completeness restated as four target theorems with the non-compactness negative results in the body, paper-anchor citations removed from rendered content, definitions-of-record re-pinned (25 anchors)
- **448** (completed, lean4): Migrated `Formula.untl`/`Formula.snce` from event-first (Burgess) to guard-first (paper) argument order -- 3,711 occurrences across 152 files, executed as a rename-forced migration so unmigrated references became compiler errors; no proof changed shape, no `sorry` introduced, oracle regenerates byte-identically
- **419** (completed, lean4): Landed the tree's first machine-checked independence result -- `co_not_derives_prior_U_gap` and its schema-level form `co_not_derives_prior_U_gap_schema`, both sorry-free, over a new rational-clock countermodel frame
- **415** (completed, lean4): Restated and reproved weak completeness per frame class over total-history semantics outright -- countermodels are the frame's own `H_F`, no transfer or realization lemma in any final statement, Limit-violating parametric stack deleted

**Directories moved**: 4 (specs/ -> specs/archive/)
**Roadmap updates**: 0 (no eligible matches against the 111-row status table)
**Memory harvest**: 3 memories created (PATTERN, WORKFLOW, TECHNIQUE) from task 449

## 2026-08-17: Archive 8 tasks

**Archived**:
- **444** (completed, formal): Overhauled `typst/FormalFoundations.typ` into a five-section advanced-textbook presentation of TM's completeness construction
- **443** (completed, typst): Authored `typst/FormalFoundations.typ`, a standalone ~17-page research report on the formal foundations of bimodal logic
- **442** (completed, typst): Revised the BimodalReference book against the paper and the live Lean tree across all 16 plan phases
- **439** (completed, general): Re-verified the definitions-of-record file, drift lint, and definition audit deliverables
- **438** (completed, lean4): Re-issued the paper-refactor cluster against the JPL paper's four-axiom `def:frame` and totality-based logical consequence
- **420** (completed, lean4): Aligned the task frame with the positive-cone axioms
- **414** (completed, lean4): Completed the total-history-validity refactor, including frame-relative validity
- **427** (expanded, typst): Sync Typst book with refactored paper -- superseded by the reference-book and foundations work

**Directories moved**: 7 (specs/ -> specs/archive/); task 427 had no directory
**Roadmap updates**: 0 (1 match skipped: low confidence)
**Memory harvest**: 2 memories created (TECHNIQUE, WORKFLOW); 1 candidate redirected into a new follow-up task

## 2026-05-15: Archive 4 completed tasks

**Archived**:
- **139** (completed): FO satisfaction for monadic structures -- cleanup, dead code deletion, existsTask_transitive fix
- **140** (completed): Truth transfer and succ_cofinal elimination -- table correctness, Reynolds Section 6 standard translation
- **141** (completed): Canonical truth lemma Until/Since -- reflCanR_linear and canS5R_symm closed, 6 TruthLemma sorries reclassified non-critical
- **144** (completed): Fix existsTask_transitive -- verified sorry-free (fix applied in task 139 phase 2)

**Directories moved**: 4 (specs/ -> specs/archive/)
**Roadmap updates**: 0
**Memory harvest**: none

