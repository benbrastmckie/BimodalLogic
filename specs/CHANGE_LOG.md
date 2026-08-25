# Change Log


## 2026-08-25: Archive 4 completed tasks

**Archived**:
- **487** (completed, meta): Fixed the 128KB Linux `MAX_ARG_STRLEN` argv ceiling that crashed `roadmap-integration.sh` unconditionally against the live repo and `state-write.sh` for any oversized `--argjson` payload -- transparent auto-spill to `jq --slurpfile` above a 100,000-byte threshold plus an additive `--argjson-file` flag; also made `--annotate` atomic (staged copy committed once, report -> commit -> print) so a mid-run failure leaves `ROADMAP.md` byte-identical, and tightened `explicit_task_ref` to collect every `(task N)` reference and reject the high-confidence verdict while any referenced task is still non-terminal; two new regression suites (7-case and 5-case) fail 5/7 and 3/5 respectively against the pre-fix scripts
- **486** (completed, lean4): Ten-phase `docs/` overhaul -- deleted `SORRY_REGISTRY.md` (196 lines) and `IMPLEMENTATION_STATUS.md` (331 lines) as confirmed fiction (both claimed 9 sorries in files that do not exist, globbing a nonexistent `Bimodal/` tree), drove the dead-link resolver from 74 to **0**, created the nine missing `FormalSystem/` READMEs so `readme-lint.sh` reports 0 missing / 0 broken, and added checks C12, C13 and C14 so this class of drift fails the build; zero `.lean` edits. Two plan hypotheses were measured wrong and recorded rather than reworked (28 `SORRY_REGISTRY` inbound refs, not 15; 138 task-number citations, not 152) because the gates were commands, not numbers
- **485** (completed, lean4): Ten-phase README correction across the top-level `README.md` and `FormalSystem/**` -- drove `readme-lint.sh` broken references from 5 to **0**, deleted the "Active sorry obligations" section naming files whose structural inventory is zero, replaced "axiom-free" with the house `sorryAx`-free phrasing, removed the "decidability fully proven" over-claim, swept 42 -> 45 constructors and "8 layers" -> nine throughout, added the three-way strong-completeness split and the fourth (Dedekind) variant, and deleted phantom file rows, Key Results, and declarations that do not exist
- **484** (completed, lean4): Corrected the two anchor documents (`specs/ROADMAP.md`, `FormalSystem/Metalogic/README.md`) against Lean source -- all nine asserted defects repaired, three (A3, B4, B5) at the larger true size research found. Rebuilt the axiom layer table from a fresh enumeration (three phantom rows removed, three layers added, 45 rows matching the 45 `inductive Axiom` constructors with every citation checked), replaced the false `sorryAx` axiom-set block with a drift-proof pointer to check C2, and replaced the false one-structural-sorry inventory with the verified zero per C3; prose only, no `.lean` changes

**Directories moved**: 4 (specs/ -> specs/archive/)
**Roadmap updates**: 0 annotations applied -- all 5 eligible matches were low-confidence keyword matches; `specs/ROADMAP.md` unchanged
**Repository health**: todo_count 5, fixme_count 0, build_errors 0, status `healthy`

## 2026-08-25: Archive 21 completed tasks

**Archived**:
- **480** (completed, lean4): Bridged `isValid` to semantic validity -- `sound_of_isValid` stated at the `DecisionResult` level (covering `decide`, `decideBlocking`, `decideAuto`, `decideAutoAdaptive` at once) plus ten corollaries in `Correctness.lean`, sorry-free on `[propext, Classical.choice, Quot.sound]`; narrowed the two module docstrings that had asserted no `isValid`-shaped statement existed
- **479** (completed, lean4): Proved `WeakCanonical.countermodel_discrete`, the tree's sole live structural sorry and the only `sorryAx` source reaching `BXCanonical.completeness`; relocated to a new `GroupModel/CountermodelBase.lean` under the same namespace to break an import cycle (consumer needed zero edits) and ported the v2 body to the non-Archimedean discrete carrier `Q x_lex Z` off `companionChronicle`
- **478** (completed, lean4): Proved the groupable companion lemma in full generality -- `companionGeneral` (every countable discrete unbounded monadic structure is `goodGroupable` at every depth k over `Q x_lex Z`) and `companionChronicle` (its Base-MCS instantiation), across four new sorry-free `GroupModel/` modules: block decomposition, monochromatic discrete completeness via a threshold EF invariant, infinite Ramsey for pairs with per-block inflation, and Q-condensation plus glue
- **477** (completed, lean4): Landed `GroupModel/GoodGroupable.lean` -- `QZStructure` over the full `Rat x_lex Int` carrier with `toMonadic`/`toOrdered`/`toOrdered_carrier`, the `goodGroupable` existential with `kEquiv`/`orderIso` transfer lemmas, `NoMaxOrder`/`NoMinOrder` instances, and two `*_of_goodGroupable` guardrail corollaries against a vacuous `veryGoodGroupable` analogue
- **475** (completed, lean4): Closed the successor-Archimedean gap -- `ValidDiscrete φ ↔ ValidInt φ`, so quantifying over every nontrivial successor-Archimedean ordered abelian group is the same as quantifying over `Z` alone; five new declarations in `Semantics/DurationClassification.lean` at the reduced binder bundle
- **474** (completed, lean4): Wired the BiLasso decision layer into the live tree across four phases/commits -- registered the `Decidability.BiLasso` re-export in `Decidability.lean`, retired 15 module-path lines from `module-invariants-manifest.txt`, and rewrote the stale block comments
- **473** (completed, lean4): Deleted the two quarantined, sorry-free but vacuous Kamp Prop 4.2 theorems and swept every prose site presenting them as landed Rabinovich deliverables; nothing proved, no sorry closed, no repair attempted -- the record of *why* they were vacuous was kept
- **472** (completed, lean4): Ten-phase documentation-correction pass over the nine verified false/stale claims (a)-(i) plus in-scope defects in the same blocks; prose and docstrings only -- no declaration, signature, import, or tactic changed
- **470** (completed, meta): Repaired all nine mechanical task-graph/metadata defects from the 2026-08-24 programme review -- corrected 421's acceptance criterion, pointed 433/434 at downstream owners, restored null descriptions on 257/282, fixed 177's `file_scope`, archived seven completed tasks, and reconciled `state.json`'s top-level counters against the post-archival tree
- **469** (completed, lean4): Captured the verdict that the rebuilt filtration lands in `IntPresentation` directly, so no bridge theorem needs proving; scoped and priced the bi-lasso route to decidability of `FrameClass.Discrete` and recorded the follow-ups
- **468** (completed, meta): Programme realignment from a verified proof-state audit -- re-verified the proof state fresh (zero live structural sorries, all four flagship theorems axiom-clean), adjudicated tasks 169/422/95 as REMOVE against the 477-479 closure, rewrote `specs/ROADMAP.md` around decidability with a PROVEN-vs-SORRY-FREE distinction, created tasks 480-482, applied nine description REVISEs, and repaired the dependency graph and `active_topics`
- **462** (completed, lean4): Added section D5 to `MintBound.lean` (674 insertions), discharging `MintPaysForTimeFixed fc U Tmax` at an arbitrary universe under the single visible `(Dense <= fc) -> False` hypothesis, and at `signedUniverse C L` for every stock C including `untl`/`snce` nodes; the missing piece was the picked rule's identity at the successor, threaded via `pick_stage_source_rule` and a `decide`-proved four-bucket census in `pickBranches_mintPays`
- **451** (completed, lean4): Consolidated the two Boneyard archives into one `FormalSystem/Boneyard/` tree with a coherent `Kamp/` region, produced entirely by `git mv`; every archived import either resolves or carries a recorded waiver, plus a new enforced check C11 to keep it that way
- **434** (completed, lean4): Section D3 of `MintBound.lean` proves `MintPaysForTime fc U Tmax` outright -- the predicate as originally stated, universal in the renaming sigma -- for every universe whose formulas carry no `untl` and no `snce` node, at every frame class and every `Tmax`, instantiated at a nonempty concrete `signedUniverse C L` with machine-checked non-vacuity
- **426** (completed, lean4): Settled the anchor row for `(G p) → □(G p)` -- the branch saturates at fuel ceiling 25 with a countermodel, so the task's `.fuelExhausted` premise described a state the repository had already left; the genuine non-saturation case is a *different* formula, `F(G p)`, stationary at 21 formulas from fuel 25 to 4096 with an unfulfilled eventuality
- **425** (completed, lean4): Machine-checked the Discrete non-compactness witness -- `archWitness p` is finitely satisfiable over `Z` and unsatisfiable over every Archimedean discrete carrier, refuting compactness and, through `soundness_discrete`, strong completeness; the former module-docstring argument is now a theorem
- **424** (completed, lean4): Compactness feasibility gate **PASSED** -- both directions of the shift-set representation theorem landed sorry-free with no `sorryAx` dependency and the module registered in the build; the GATING RULE's cancel condition was not met, and `sep` (the *Limit* axiom transcription) is first-order over the two-sorted signature
- **423** (completed, lean4): Landed `Metalogic/SetConsequence.lean` (19 declarations, zero sorries) -- the finitary `SetDerivable` relation from a possibly-infinite premise set, plus the four per-class `SetSemanticConsequence*` predicates
- **421** (completed, lean4): Two comment-and-probe-only deliverables on the Base weak terminus -- corrected the refuted-route guidance in `WeakCanonical/Transfer.lean` and probed the non-Archimedean discrete carrier; no proof obligation added, discharged, or relocated, and the `countermodel_discrete` sorry left byte-identical
- **413** (completed, lean4): Formalized the TM+/TM conservativity bridge, backward direction -- a self-contained `FormalSystem/BaseLanguage/` cluster for the tense-primitive base language BL plus `TM |- phi ==> TM+ |- tr phi` in `Metalogic/Conservativity.lean`, sorry-free across nine phases, with a documented refutation record for the forward direction
- **362** (completed, lean4): Landed unconditional finite-context CONSEQUENCE completeness for `FrameClass.Base`, `Dense` and `Discrete` in `StrongCompleteness.lean` (14 declarations, each with its semantic deduction theorem, soundness guard and weak corollary, plus a nine-entry `#print axioms` audit), and the Base set-layer mirror isolating `CompactBase` as the whole remaining obligation

**Directories moved**: 21 (specs/ -> specs/archive/)
**Roadmap updates**: 1 completed annotation (the Consequence-completeness capstone checkbox, task 362); 1 further high-confidence match (task 313) fell outside this batch
**Memory harvest**: none (no candidates recorded on any archived task)
**Note**: `roadmap-integration.sh` fails with `Argument list too long` when run against the full active task set -- its `roadmap_matches` payload reached 497KB, past the 128KB per-argument limit on the final `jq -n`. The annotation above was applied via the roadmap-eligible-only snapshot, which stays under the limit.

## 2026-08-24: Archive 7 completed tasks

**Archived**:
- **467** (completed, markdown): Corrected all 11 misalignments between `FormalSystem/Metalogic/Decidability/README.md` and the directory it documents -- removed the unproved decidability overclaim, rebuilt the Modules table, fixed the stale DecisionResult constructor set, redrew the dependency flowchart, added missing sibling README links, refreshed the footer date
- **460** (completed, general): OCR'd and ingested Gabbay 2003 "Many-Dimensional Modal Logics" (742 pages) into the literature corpus via resumable `ocrmypdf` batches, with hand-verified semantic accuracy pre- and post-ingest and a fully-audited scoped exception for 19 non-prose OCR fusion sites
- **459** (completed, general): Removed 8 stale, provenance-marked placeholder duplicate entries from the global literature index via a guarded, assertion-first deletion script; verified all surviving entries byte-identical and the per-repo sub-index untouched
- **458** (completed, general): Migrated 12 legacy `chunks_dir`-only literature entries to the v2 schema, grounded entirely in hand chunk reads; post-mutation gate independently confirmed all 12 token counts and a field-level diff limited to the 5-field allow-list
- **457** (completed, general): Repaired six literature-corpus data defect classes across 369 global index entries over seven sequential, backed-up, gated phases; deferred SCOPE 6 with recorded rationale and spawned four follow-up tasks (458-461)
- **436** (completed, lean4): Resumed the fourth termination-measure component (self-guard potential) after its spawned blocker task reoriented the identification arm's merge direction; Phase 1's original FALSE verdict did not survive the reorientation, and Phases 2-9 were unblocked and executed sorry-free, axiom-free
- **432** (completed, lean4): Discharged the `UniverseClosed` residual -- both conjuncts refuted as originally stated; clause 2 repaired via `UniverseClosedAt` (constraining the merge target to known times), clause 1's label coordinate reduced to a fully-analysed and refuted rectangle (`FreshLabelHeadroom`)

**Directories moved**: 7 (specs/ -> specs/archive/)
**Roadmap updates**: 0 (0 eligible matches against the 111-row status table; ROADMAP.md unchanged)
**Memory harvest**: none (no candidates recorded on any archived task)

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

