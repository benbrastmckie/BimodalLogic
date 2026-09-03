# Implementation Plan: Core MCS API Consolidation

- **Task**: 526 - Consolidate the maximal-consistent-set API in `FormalSystem/Metalogic/Core/` so the three completeness routes consume one set of lemmas; resolve the MCS-automation question
- **Status**: [IMPLEMENTING]
- **Effort**: 14 hours
- **Dependencies**: 524 (serialized `BaseLanguageSoundness.lean` access; landed)
- **Research Inputs**: `specs/526_core_mcs_api_consolidation/reports/01_core-mcs-api-consolidation.md`
- **Artifacts**: plans/01_core-mcs-api-consolidation.md (this file)
- **Standards**:
  - `.claude/context/formats/plan-format.md`
  - `.claude/context/standards/status-markers.md`
  - `.claude/rules/artifact-formats.md`
  - `.claude/rules/plan-format-enforcement.md`
  - `.claude/rules/state-management.md`
- **Type**: lean4
- **Lean Intent**: false

## Overview

Five duplicated or over-long constructions in the MCS layer are replaced by one lemma each, and
one newly discovered 174-site composite idiom is collapsed by a one-line helper. Every
replacement in this plan was compiled against the live tree by research (scratch modules E1-E9)
and is quoted by report section rather than re-derived here; the implementer transcribes the
validated code and sweeps the call sites. The MCS-automation experiment has already been run and
returned a negative result, so its deliverable is a recorded decision in `Core/README.md`, not a
tactic. Done means: one Zorn lemma, one `bot_not_mem`, zero inline `right_mono_until`-with-top
idioms in `Bundle/`, `Transfer.lean` no longer importing BXCanonical for a one-liner, the
`mcs_auto` decision recorded, `lake build` green, and the C2 axiom baseline unchanged.

### Research Integration

The research report is load-bearing and **overrides the task description wherever they
conflict** — the task's MEASURED STATE predates tasks 520, 524 and 525. Corrections carried into
this plan:

- **Item 5 (`CanonicalTask_backward`) is struck.** Task 520 phase 4 (`ab24de633`) already
  Boneyarded the entire family to `FormalSystem/Boneyard/BundleDeadHalf/CanonicalTaskRelation.lean`,
  taking F-10's own "cheapest variant is to Boneyard it" escape hatch. It is recorded here rather
  than silently omitted so a reader does not re-open it. See report §3.5.
- **Item 2 retires rather than refactors.** The four boundedness lemmas (157 lines) have zero
  references in `FormalSystem/`, `Tests/`, or `docs/`, and their advertised consumer
  `succ_chain_fam` is itself Boneyarded. Retirement is cheaper than the `Nat.find` rewrite. The
  rewrite was validated anyway (report §3.2) and is kept as this plan's documented fallback if
  Phase 3 turns up a live consumer.
- **`mcs_auto` is a negative result and is not shipped.** It closes synthetic forward chains in
  45 ms where plain `aesop` fails, but fails both real pure-MCS proofs with "made no progress".
  Two structural blockers plus one mechanical one (a rule set cannot be declared and used in the
  same module, so D-12's single `Core/MCSAesop.lean` is not implementable as written). Report
  §4.4 supplies the decision text.
- **A new first-class work item is added**: `SetMaximalConsistent.mp_of_theorem`, collapsing the
  `implication_property h_mcs (theorem_in_mcs h_mcs …) hφ` composite idiom. Report §5 counts 197
  sites across 20 files; an independent conservative re-scan during planning found 174 across the
  same 20 files with a matching per-file distribution. This is the single largest win in the task.
- **Drift respected**: `bot_not_in_mcs` has four copies, not three (the fourth at
  `Decidability/FMP/TruthPreservation.lean:94`), which is why the lemma belongs on `SetConsistent`
  rather than `SetMaximalConsistent`; the `right_mono_until` inline count is 13, not 16;
  `BaseLanguageSoundness.lean` now lives under `Metalogic/Conservativity/`; the `Soundness.lean`
  weakening scaffold is at `:1274-1281`; `someFuture_mono` must be a `def` and `somePast_mono` a
  `noncomputable def` (`theorem` is rejected outright because `⊢[fc]` is `Type`).

### Prior Plan Reference

No prior plan for this task.

### Roadmap Alignment

No `roadmap_path` was supplied in the delegation context and no roadmap flag is set.
`specs/ROADMAP.md` exists but is an architecture/status document rather than a checklist of
items this internal API consolidation advances. **ROADMAP.md is not read for phase sequencing and
is not modified by any phase of this plan.**

## Goals & Non-Goals

**Goals**:

- One generic Zorn lemma (`exists_maximal_of_chainClosed`) with `set_lindenbaum` and
  `restricted_lindenbaum` as instantiations; the four dead superset definitions deleted.
- One `bot_not_mem`, stated on `SetConsistent` in `Core/MCSProperties.lean`, replacing all four
  live copies; `WeakCanonical/Transfer.lean` re-pointed at `Core` so it no longer imports
  BXCanonical for a one-liner.
- `someFuture_mono` / `somePast_mono` in `Theorems/TemporalDerived.lean`, with all 13 inline
  `right_mono_until`-with-top blocks replaced — including all 8 in `Bundle/`.
- `DerivationTree.ofWeakeningNil` plus its height lemmas in `ProofSystem/Derivation.lean`, with a
  BaseLanguage twin, removing the duplicated `omega`-dependent termination scaffold from both
  soundness inductions.
- `SetMaximalConsistent.mp_of_theorem` in `Core/MCSProperties.lean`, swept through all 20
  consumer files.
- The four dead boundedness lemmas retired to the Boneyard.
- `Core/README.md` refreshed, carrying the `mcs_auto` rejection decision in enough detail that the
  question is not re-opened.

**Non-Goals**:

- **Not shipping `mcs_auto`.** No `Core/MCSAesop.lean`, no `declare_aesop_rule_sets`, no
  `macro "mcs_auto"`, no Aesop attributes anywhere. The acceptance criterion "`mcs_auto` decision
  recorded" is satisfied by Phase 11's written rejection, not by a tactic.
- **Not touching `FormalSystem/Boneyard/BundleDeadHalf/CanonicalTaskRelation.lean`** or any other
  already-archived module. (Phase 3 *adds* a new file under `Boneyard/`; that is a retirement, not
  a modification of existing archive content.)
- **Not attempting A-14's second half** — unifying `soundness_in`'s
  `induction … generalizing` with `derivable_valid_and_swap_validIn`'s `match`/`termination_by`.
  The two have genuinely different statements and the empty-context form is the one the
  necessitation cases consume (`Soundness.lean:1252-1272`). Phase 6 stops at `ofWeakeningNil`.
- **Not keeping the four boundedness lemmas live under a `Nat.find` rewrite** as the default
  route. The `Nat.find` rewrite is validated (report §3.2) and is Phase 3's documented fallback,
  used only if that phase's confirmation step finds a live consumer.
- **Not introducing any `sorry`** (structural or strategic) and not adding or changing any axiom.
  Every replacement in this plan compiles end to end; the tree's structural-`sorry` count is 0 and
  stays 0.
- **Not changing any flagship theorem statement.** Signatures of `set_lindenbaum`,
  `restricted_lindenbaum`, `restricted_mcs_*`, `soundness_in` and
  `derivable_valid_and_swap_validIn` are preserved.
- **Not editing `specs/ROADMAP.md`.**
- **Not creating pull requests and not pushing to any remote.**

**Scope note on Non-Goals**: this plan deliberately edits ~30 files across `Core/`,
`BXCanonical/`, `WeakCanonical/`, `Bundle/`, `Algebraic/`, `Decidability/`, `Theorems/`,
`ProofSystem/`, `BaseLanguage/`, and `Conservativity/`. No Non-Goal above restricts edits to
`Core/`; the call-site sweeps in Phases 4, 5, and 7-10 are in scope by design.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `Core/MCSProperties.lean` and `ProofSystem/Derivation.lean` are near the import-graph root; editing either invalidates most of the tree | H | H (certain) | Phase 1 makes all `MCSProperties.lean` additions in ONE edit so only one near-full rebuild is paid; Phase 6 is isolated and scheduled to run without competing builds. All builds detached and guarded per `context/project/lean4/operations/long-builds.md`. |
| The 174/197 site count is a hypothesis, not a fact; the sweep phases are partitioned on it | M | M | Every sweep phase carries a `**Scope Hypothesis**` line with the confirmation command. A per-file count differing from the plan is expected and is not a defect — the implementer re-partitions within the phase rather than skipping sites. |
| File collisions between work groups (A/B on `RestrictedMCS/Basic.lean`; C/F on `MCSProperties.lean`; D/F on `WitnessSeed.lean` and `RRelation.lean`) | M | H | Collisions are resolved structurally: all `MCSProperties.lean` additions are hoisted into Phase 1, and the `Depends on` fields serialize every remaining colliding pair (3 after 2; 8 and 9 after 5; 10 after 4). |
| Retiring 157 lines to the Boneyard breaks `check-module-invariants.sh` C11 (Boneyard imports must resolve) or C14 (documented counts must match the tree) | M | M | Phase 3 runs the full invariants gate, not just `lake build`; Phase 11 re-runs it after the README refresh, which is where documented counts live. |
| Group E (Phase 6) edits `soundness_in`'s sibling recursion, which is on the flagship path | H | L | Phase 6 is `full` tier and runs `check-module-invariants.sh` with C2 explicitly checked before the phase closes; C2 divergence is a hard stop, never a re-baselining. |
| `somePast_mono` must be `noncomputable def`; a `theorem` or plain `def` is rejected | L | M (if code is re-derived) | Phase 5 transcribes report §3.4 verbatim rather than re-deriving; `Automation/ProofStepExport.lean:60`'s computable list is checked as part of that phase's verification. |
| Long `lake build` cycles exhaust an agent's context mid-phase | M | M | Commit-per-green-substep is in force for every phase (all default to `per-substep`); a phase interrupted mid-sweep resumes from the last committed file. |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2, 5, 6 | -- |
| 2 | 3, 4, 7, 8, 9 | 1, 2, 5 |
| 3 | 10 | 1, 4 |
| 4 | 11 | 3, 4, 6, 7, 8, 9, 10 |

Phases within the same wave can execute in parallel. **Practical note**: the waves express
logical independence (disjoint file territory), not a recommendation to run concurrent `lake
build` invocations. Serial execution in wave order is acceptable and is the lower-risk default
given build contention on this tree.

---

### Phase 1: Core/MCSProperties.lean additions [COMPLETED]

**Goal**: Land every new `Core/MCSProperties.lean` declaration in a single edit, so the tree pays
one near-full rebuild for all of them, and so the later sweep phases never collide on this file.

**Tasks**:
- [ ] Add `SetConsistent.bot_not_mem` and `SetMaximalConsistent.bot_not_mem` verbatim from report
      §3.3, beside the existing `negation_complete` / `implication_property` / `neg_excludes` /
      `set_consistent_not_both`.
- [ ] Add `SetMaximalConsistent.mp_of_theorem` verbatim from report §5, beside
      `implication_property`, with its docstring.
- [ ] Confirm no name collision with `bot_not_mem_predFormulas` (`Transfer.lean:60`) or the
      `Ultrafilter.bot_not_mem` field (`Algebraic/UltrafilterMCS.lean:50`) — both are in different
      namespaces per report §3.3, but re-check after the edit.
- [ ] Do NOT delete or re-point any call site in this phase; additions only.

**Timing**: 0.75 hours

**Depends on**: none

**Verification Tier**: full

**Scope Hypothesis**: exactly three new declarations in exactly one file, with no deletions and no
call-site edits. Confirm with `git diff --stat` at the end of the phase: one file changed,
insertions only.

**Files to modify**:
- `FormalSystem/Metalogic/Core/MCSProperties.lean` - add three theorems (two `bot_not_mem`, one
  `mp_of_theorem`)

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- FormalSystem` green (detached,
  background)
- `bash scripts/check-module-invariants.sh` passes; C2 axiom baseline unchanged
- `grep -c sorry` over `FormalSystem/` excluding `Boneyard/` unchanged at 0 structural sorries
- The three new names resolve from a downstream module (e.g. via `lean_hover_info` at a
  `BXCanonical/` call site)

---

### Phase 2: One Zorn lemma and two instantiations [COMPLETED]

**Goal**: Replace the two hand-rolled Zorn arguments with one generic
`exists_maximal_of_chainClosed` plus two thin instantiations, and delete the four dead superset
definitions they were the only consumers of.

**Tasks**:
- [ ] Add `exists_maximal_of_chainClosed {P : Set Formula → Prop}` to
      `Core/MaximalConsistent.lean` verbatim from report §3.1. Note the `A : Set Formula`
      parameter from the review's sketch is deliberately dropped — the maximality conclusion is
      fully general and the closure restriction belongs in the instantiation.
- [ ] Rewrite `set_lindenbaum` (`MaximalConsistent.lean:303-353`) as the report §3.1
      instantiation, preserving its signature exactly.
- [ ] Rewrite `restricted_lindenbaum` (`RestrictedMCS/Basic.lean:316-375`) as the report §3.1
      instantiation, preserving its signature and keeping the four-line closure-preservation
      bridge that reconciles `¬RestrictedConsistent phi (insert psi S) fc` with `RestrictedMCS`'s
      `¬SetConsistent (insert psi S)` maximality field (`Basic.lean:78-80`).
- [ ] Delete `ConsistentSupersets` (`MaximalConsistent.lean:286`),
      `self_mem_consistent_supersets` (`:292`), `RestrictedConsistentSupersets`
      (`Basic.lean:274`), and `self_mem_restricted_consistent_supersets` (`:281`) after confirming
      zero remaining consumers.

**Timing**: 1.5 hours

**Depends on**: none

**Verification Tier**: full

**Scope Hypothesis**: 111 lines of proof collapse to 39, and exactly four definitions become
deletable. Confirm before deleting each with
`grep -rn "ConsistentSupersets\|self_mem_consistent_supersets\|RestrictedConsistentSupersets\|self_mem_restricted_consistent_supersets" FormalSystem Tests docs`
returning only the declaration sites; if any other consumer exists, keep that definition and
record the deviation in the phase notes.

**Files to modify**:
- `FormalSystem/Metalogic/Core/MaximalConsistent.lean` - add generic lemma, rewrite
  `set_lindenbaum`, delete 2 dead definitions
- `FormalSystem/Metalogic/Core/RestrictedMCS/Basic.lean` - rewrite `restricted_lindenbaum`,
  delete 2 dead definitions

**Verification**:
- Guarded `lake build` green
- `bash scripts/check-module-invariants.sh` passes; C2 unchanged
- `set_lindenbaum` and `restricted_lindenbaum` signatures byte-identical to pre-phase (diff the
  declaration lines)
- Zero new `sorry`, zero new axioms

---

### Phase 3: Retire the four boundedness lemmas [COMPLETED]

**Goal**: Remove 157 lines of unreferenced boundedness machinery from `Core/RestrictedMCS/`,
retiring it to the Boneyard rather than refactoring it.

**Tasks**:
- [ ] Re-confirm zero consumers of `restricted_mcs_F_bounded` (`Basic.lean:486-554`),
      `restricted_mcs_P_bounded` (`:591-660`), `restricted_mcs_iter_F_bound` (`:467`), and
      `restricted_mcs_iter_P_bound` (`:571`).
- [x] Move all four declarations, with their docstrings, into a new Boneyard module under
      `FormalSystem/Boneyard/` *(deviation: altered — C8 explicitly skips `Boneyard`, so the
      sibling-aggregator convention does not apply there. Followed the archive's own documented
      standard instead (`Boneyard/README.md`, "How to Archive Files"): a new subdirectory
      `RestrictedMCSBoundedness/` with a `README.md` and `Boundedness.lean`, plus a Directory
      Inventory row and refreshed archive counts.)*, with a header
      note recording why they were retired and that `succ_chain_fam` — their advertised consumer —
      lives at `FormalSystem/Boneyard/StrictSemanticsLegacy/Bundle/SuccChainFMCS.lean`.
- [ ] Delete the four declarations and the two now-orphaned source comments from
      `Core/RestrictedMCS/Basic.lean`; fix the one docstring cross-reference research found.
- [ ] Ensure every `import` inside the new Boneyard module resolves (invariant C11).

**Timing**: 0.75 hours

**Depends on**: 2

**Verification Tier**: full

**Scope Hypothesis**: exactly four declarations totalling 157 lines, with zero references outside
their own file. Confirm with
`grep -rn "restricted_mcs_F_bounded\|restricted_mcs_P_bounded\|restricted_mcs_iter_F_bound\|restricted_mcs_iter_P_bound" FormalSystem Tests docs`
before removing anything. **Fallback if a live consumer is found**: do NOT retire. Instead apply
the validated `Nat.find` rewrite from report §3.2 — `exists_boundary_of_one` plus two 14-line
instantiations, absorbing the two 9-line `iter_*_bound` lemmas into the `hesc` argument (139 proof
lines become 44). Note that rewrite needs `classical` (`Nat.find` needs `DecidablePred`; `_ ∈ M`
for `M : Set Formula` is not decidable) and no module-scope `open Classical`.

**Files to modify**:
- `FormalSystem/Metalogic/Core/RestrictedMCS/Basic.lean` - remove four declarations and stale
  comments
- `FormalSystem/Boneyard/…` (new module) - receive the retired declarations

**Verification**:
- Guarded `lake build` green
- `bash scripts/check-module-invariants.sh` passes — specifically B0 (still exactly one archive
  tree), C8 (aggregator convention), C11 (Boneyard imports resolve), C14 (documented counts match)
- C2 unchanged

---

### Phase 4: One bot_not_mem — delete the four copies and re-point Transfer.lean [COMPLETED]

**Goal**: Collapse all four live `bot_not_in_mcs` proofs onto the Phase 1 `Core` lemma, and remove
the accidental `WeakCanonical → BXCanonical` dependency this duplication created.

**Tasks**:
- [x] Delete `BXCanonical/TruthLemma.lean:69-77` and `WeakCanonical/TruthLemma.lean:57-64`,
      re-pointing their call sites at `Core`. *(deviation: altered — the `ReflCanDomain` copy at
      `WeakCanonical/TruthLemma.lean:57` has **zero** call sites anywhere in the tree, so no
      `SetMaximalConsistent.bot_not_mem x.property` re-pointing was needed; it was deleted
      outright and the file's "Status" docstring list updated. The `BXCanonical` copy's call
      sites are 9, not the 6 the plan enumerated — three further sites live in
      `WeakCanonical/IntegerModel/ReynoldsBridge.lean:172,285,329`, found by the implementer's
      own scan and re-pointed with the rest.)*
- [ ] Replace `Algebraic/FlowFrame.lean`'s inlined `| bot` branch (`:693-697`) with the call.
- [ ] Replace `Decidability/FMP/TruthPreservation.lean:94-105` with
      `SetConsistent.bot_not_mem (closure_mcs_consistent S.is_mcs)` — this is the copy stated for
      a `ClosureMCSBundle`, which is not a `SetMaximalConsistent` but reaches consistency through
      `closure_mcs_consistent` (`ClosureMCS.lean:153`).
- [x] Re-point `WeakCanonical/Transfer.lean:455,892,986,1036` at `Core`. *(deviation: altered —
      the BXCanonical import is **retained**: `Transfer.lean` still uses
      `BXCanonical.imp_iff_mcs` at 7 sites and `ChronicleAsPriorModel`. The acceptance criterion
      "no longer imports BXCanonical **for a one-liner**" is satisfied by the one-liner
      dependency being gone, not by deleting the import.)*

**Timing**: 1.25 hours

**Depends on**: 1

**Verification Tier**: interface

**Scope Hypothesis**: four proof copies plus four `Transfer.lean` cross-references. Confirm with
`grep -rn "bot_not_in_mcs" FormalSystem --include=*.lean | grep -v Boneyard` before and after; the
after-count must be 0. Do not confuse with `bot_not_mem_predFormulas` (`Transfer.lean:60`) or the
`Ultrafilter.bot_not_mem` field (`Algebraic/UltrafilterMCS.lean:50`), which are unrelated.

**Files to modify**:
- `FormalSystem/Metalogic/BXCanonical/TruthLemma.lean` - delete local copy
- `FormalSystem/Metalogic/WeakCanonical/TruthLemma.lean` - delete local copy
- `FormalSystem/Metalogic/WeakCanonical/Transfer.lean` - re-point 4 call sites, drop BXCanonical
  import if unused
- `FormalSystem/Metalogic/Algebraic/FlowFrame.lean` - replace inlined `| bot` branch
- `FormalSystem/Metalogic/Decidability/FMP/TruthPreservation.lean` - replace local copy

**Verification**:
- Guarded `lake build` green (build the five changed modules and their direct dependents; full gate
  before the phase closes)
- `bash scripts/check-module-invariants.sh` passes; C4 (imports resolve) specifically exercised by
  the `Transfer.lean` import removal
- `grep -rn "bot_not_in_mcs" FormalSystem --include=*.lean | grep -v Boneyard` returns nothing
- `Transfer.lean` no longer imports any `BXCanonical` module for a one-liner (inspect its import
  block)

---

### Phase 5: someFuture_mono / somePast_mono and the 13-site sweep [COMPLETED]

**Goal**: Introduce the two temporal monotonicity helpers and eliminate every inline
`right_mono_until`-with-top idiom, including all 8 in `Bundle/`.

**Tasks**:
- [ ] Add `someFuture_mono` (a `def`) and `somePast_mono` (a `noncomputable def`) to
      `Theorems/TemporalDerived.lean` directly below `fMono` (`:407`) and `pMono` (`:417`),
      verbatim from report §3.4. `theorem` is rejected outright — `⊢[fc] φ` is `DerivationTree`,
      which is `Type`, not `Prop`. `somePast_mono` must be `noncomputable` because
      `FormalSystem.Theorems.pastNecessitation` is.
- [x] Confirm `Automation/ProofStepExport.lean:60`'s "computable, suitable for ProofStepExport"
      list is still accurate: `someFuture_mono` qualifies, `somePast_mono` does not. Update the
      list only if it enumerates names. *(deviation: altered — the `:60` list documents the 334
      entries the file's own `mkEntry` table actually exports, not every computable theorem.
      No `mkEntry` for `someFuture_mono` was added, so the list stays accurate as written and
      needs no edit; adding one would have changed the documented entry counts and the
      2026-06-01 validation record, which is outside this phase.)*
- [ ] Replace all 13 live inline blocks: `Bundle/TemporalContent.lean:176,195,229,246`,
      `Bundle/WitnessSeed.lean:72,91,118,138`, `BXCanonical/Chronicle/RRelation.lean:1263,1286,1304,1346`,
      `WeakCanonical/ReflexiveCanonical.lean:212`.
- [ ] Use the report §3.4 rewritten `some_future_all_future_neg_absurd` (validated against
      `Bundle/WitnessSeed.lean:60-79`, 14-line body to 4) as the worked template. The
      `DerivationTree.lift (fc₁ := .Base) trivial` disappears at each site — `someFuture_mono` is
      already `{fc}`-generic via `fMono`'s `FrameClass.base_le fc`, which also removes the
      `lift`-vs-`base_le` inconsistency F-15 flagged.

**Timing**: 2 hours

**Depends on**: none

**Verification Tier**: full

**Scope Hypothesis**: 13 live sites in 4 files (not the 16 the task description claims — 6 of the
original 14 were in `Bundle/SuccRelation.lean`, Boneyarded by task 520), all using `Formula.top`
as the third axiom argument and therefore all in scope. Confirm with
`grep -rn "right_mono_until" FormalSystem --include=*.lean | grep -v Boneyard` before and after;
the after-count in `Bundle/` must be 0.

**Files to modify**:
- `FormalSystem/Theorems/TemporalDerived.lean` - add two defs
- `FormalSystem/Metalogic/Bundle/TemporalContent.lean` - 4 sites
- `FormalSystem/Metalogic/Bundle/WitnessSeed.lean` - 4 sites
- `FormalSystem/Metalogic/BXCanonical/Chronicle/RRelation.lean` - 4 sites
- `FormalSystem/Metalogic/WeakCanonical/ReflexiveCanonical.lean` - 1 site
- `FormalSystem/Automation/ProofStepExport.lean` - only if its computable list enumerates names

**Verification**:
- Guarded `lake build` green
- `bash scripts/check-module-invariants.sh` passes; C2 unchanged
- Zero inline `right_mono_until`-with-top idioms remain under `FormalSystem/Metalogic/Bundle/`
- `someFuture_mono` elaborates as computable; `somePast_mono` as noncomputable (confirm with
  `lean_hover_info` or `#print axioms`-adjacent inspection)

---

### Phase 6: DerivationTree.ofWeakeningNil and its BaseLanguage twin [COMPLETED]

**Goal**: Replace the duplicated, `omega`-dependent weakening/termination scaffold in the two
soundness inductions with a named helper plus height lemmas.

**Tasks**:
- [ ] Add `DerivationTree.ofWeakeningNil`, `DerivationTree.height_ofWeakeningNil` (`@[simp]`), and
      `DerivationTree.height_ofWeakeningNil_lt` to `ProofSystem/Derivation.lean` verbatim from
      report §3.6.
- [ ] Add the mirror trio beside the BaseLanguage derivation type in
      `FormalSystem/BaseLanguage/Derivation.lean`. This twin is **required, not optional**:
      `BaseLanguage.DerivationTree` is a different inductive type and one lemma cannot cover both.
- [ ] Rewrite the `Soundness.lean:1274-1281` `.weakening` arm per report §3.6. Keep `h_term` as a
      `have` — it is consumed implicitly by the `omega` in the `decreasing_by` block
      (`Soundness.lean:1283-1287`), which reads it out of the local context. Naming the height
      fact is exactly what makes the scaffold survive a change to `DerivationTree.height`.
- [ ] Rewrite the twin arm at `Metalogic/Conservativity/BaseLanguageSoundness.lean:410-418`.
- [ ] Stop there. Do not touch `soundness_in` (`:1289`, `induction d generalizing τ t` at `:1295`)
      or `derivable_valid_and_swap_validIn` (`:1217`) beyond the `.weakening` arm — see Non-Goals.

**Timing**: 1.5 hours

**Depends on**: none

**Verification Tier**: full

**Scope Hypothesis**: exactly four files, three new declarations per derivation type, and exactly
two rewritten `.weakening` arms. Confirm the two arm sites still match report §3.6's quoted shape
before editing (`grep -n "weakening" FormalSystem/Metalogic/Soundness.lean
FormalSystem/Metalogic/Conservativity/BaseLanguageSoundness.lean`); the line numbers `:1274-1281`
and `:410-418` are post-task-524 and will drift.

**Files to modify**:
- `FormalSystem/ProofSystem/Derivation.lean` - add 3 declarations
- `FormalSystem/BaseLanguage/Derivation.lean` - add BL twin trio
- `FormalSystem/Metalogic/Soundness.lean` - rewrite the `.weakening` arm at `:1274-1281`
- `FormalSystem/Metalogic/Conservativity/BaseLanguageSoundness.lean` - rewrite the twin arm at
  `:410-418`

**Verification**:
- Guarded `lake build` green — this phase forces a near-full rebuild; budget for it
- `bash scripts/check-module-invariants.sh` passes with **C2 explicitly confirmed**: this group
  edits `soundness_in`'s sibling recursion, which is on the flagship path. C2 divergence is a hard
  stop, never a new baseline.
- `soundness_in` and `derivable_valid_and_swap_validIn` signatures unchanged
- Zero new `sorry`, zero new axioms

---

### Phase 7: mp_of_theorem sweep A — Chronicle core [COMPLETED]

**Goal**: Collapse the composite MCS idiom in the two densest files.

**Tasks**:
- [ ] Replace each `implication_property h_mcs (theorem_in_mcs h_mcs <derivation>) hφ` occurrence
      (typically spread over 3-4 lines) with a single
      `SetMaximalConsistent.mp_of_theorem h_mcs <derivation> hφ` application, in
      `BXCanonical/Chronicle/PointInsertion.lean` and
      `BXCanonical/Chronicle/ChronicleToCountermodelBasic.lean`.
- [ ] Use `G_implies_F_mcs` (`PointInsertion.lean:376-406`, 31 lines, 14 API calls, six of its
      `have`s the idiom verbatim) as the showcase and the sanity check on the rewrite shape
      (report §5).
- [ ] Commit per green file, not per phase.

**Timing**: 1.5 hours

**Depends on**: 1

**Verification Tier**: local

**Scope Hypothesis**: ~50 sites — report §5 gives 34 + 25 = 59; a conservative planning re-scan
gives 32 + 18 = 50. **Confirmed at implementation: 57** (PointInsertion 32,
ChronicleToCountermodelBasic 25). The planning re-scan's regex undercounts because
`implication_property\s+\S+\s*\(\s*theorem_in_mcs` cannot match a *parenthesized* MCS argument
(e.g. `(h_mcs t)`) and cannot match the dot-notation surface form
`h_mcs.implication_property (theorem_in_mcs h_mcs d) x` at all. A paren-matching parser was used
instead, and its counts are the ones recorded here. Confirm per file at implementation time with a multi-line-aware scan, e.g.
`python3 -c "import re,sys;print(len(re.findall(r'implication_property\s+\S+\s*\(\s*theorem_in_mcs', open(sys.argv[1]).read(), re.S)))" <file>`,
and treat the confirmed count as authoritative over both numbers above. A count outside this range
is not a defect; re-partition within the phase rather than skipping sites.

**Files to modify**:
- `FormalSystem/Metalogic/BXCanonical/Chronicle/PointInsertion.lean`
- `FormalSystem/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodelBasic.lean`

**Verification**:
- Guarded `lake build` of the two changed modules green after each file; full gate before the phase
  closes
- The confirmed per-file idiom count drops to 0 in both files
- No proof term changes meaning: `mp_of_theorem` is definitionally the composite, so the diff must
  be a pure contraction with no new `have`s or `sorry`

---

### Phase 8: mp_of_theorem sweep B — RRelation, CanonicalModel, CounterexampleElimination [COMPLETED]

**Goal**: Same collapse across the next three densest files.

**Tasks**:
- [ ] Sweep `BXCanonical/Chronicle/RRelation.lean`, `BXCanonical/CanonicalModel.lean`, and
      `BXCanonical/Chronicle/CounterexampleElimination.lean`.
- [ ] `RRelation.lean` was already edited by Phase 5; start from its post-Phase-5 state and do not
      re-introduce any inline `right_mono_until` block.
- [ ] Commit per green file.

**Timing**: 1.5 hours

**Depends on**: 1, 5

**Verification Tier**: local

**Scope Hypothesis**: ~54 sites — report §5 gives 22 + 19 + 16 = 57; the planning re-scan gives
22 + 16 + 16 = 54. **Confirmed at implementation: 57**, matching report §5 exactly
(RRelation 22, CanonicalModel 19, CounterexampleElimination 16). Confirm per file with the same multi-line scan as Phase 7 and treat the
confirmed count as authoritative.

**Files to modify**:
- `FormalSystem/Metalogic/BXCanonical/Chronicle/RRelation.lean`
- `FormalSystem/Metalogic/BXCanonical/CanonicalModel.lean`
- `FormalSystem/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean`

**Verification**:
- Guarded `lake build` green per file; full gate before the phase closes
- Confirmed per-file idiom count drops to 0 in all three
- `right_mono_until` still absent from `RRelation.lean` (Phase 5 result preserved) *(deviation:
  altered — the criterion as written is stricter than Phase 5's actual target and than the tree.
  `RRelation.lean` retains 7 `right_mono_until` occurrences: 4 docstring mentions and 3 genuine
  axiom applications whose third argument is **not** `Formula.top` (`guard`, `β`,
  `β'.and (β.untl γ)`), which were never in scope. What Phase 5 removed — the 4 with-top inline
  blocks — is confirmed still gone, with 4 `someFuture_mono` uses in their place.)*

---

### Phase 9: mp_of_theorem sweep C — Bundle, Frame, ReflexiveCanonical [COMPLETED]

**Goal**: Same collapse across the files that Phase 5 also touched, plus `BXCanonical/Frame.lean`.

**Tasks**:
- [ ] Sweep `Bundle/WitnessSeed.lean`, `BXCanonical/Frame.lean`,
      `WeakCanonical/ReflexiveCanonical.lean`, and `Bundle/TemporalContent.lean`.
- [ ] `WitnessSeed.lean`, `ReflexiveCanonical.lean` and `TemporalContent.lean` were edited by
      Phase 5; start from their post-Phase-5 state. In particular, the rewritten
      `some_future_all_future_neg_absurd` (report §3.4) itself contains the idiom — collapse it
      too.
- [ ] Commit per green file.

**Timing**: 1.25 hours

**Depends on**: 1, 5

**Verification Tier**: local

**Scope Hypothesis**: ~35 sites — report §5 gives 14 + 9 + 11 = 34 for the first three; the
planning re-scan gives 14 + 9 + 8 + 4 (`TemporalContent.lean`) = 35. **Confirmed at
implementation: 38** (WitnessSeed 14, Frame 9, ReflexiveCanonical 11, TemporalContent 4) — the
report's 11 for `ReflexiveCanonical.lean` is right and the re-scan's 8 is the undercount, because
every one of that file's sites uses the dot-notation surface form
`h_mcs.implication_property (theorem_in_mcs h_mcs d) x`, which the re-scan's regex cannot see. Confirm per file with the
same multi-line scan as Phase 7.

**Files to modify**:
- `FormalSystem/Metalogic/Bundle/WitnessSeed.lean`
- `FormalSystem/Metalogic/BXCanonical/Frame.lean`
- `FormalSystem/Metalogic/WeakCanonical/ReflexiveCanonical.lean`
- `FormalSystem/Metalogic/Bundle/TemporalContent.lean`

**Verification**:
- Guarded `lake build` green per file; full gate before the phase closes
- Confirmed per-file idiom count drops to 0 in all four
- Zero inline `right_mono_until`-with-top idioms in `Bundle/` (Phase 5 acceptance preserved)

---

### Phase 10: mp_of_theorem sweep D — the remaining consumer files [COMPLETED]

**Goal**: Finish the sweep across the long tail so no live file retains the composite idiom.

**Tasks**:
- [ ] Re-run the multi-line scan across all of `FormalSystem/` excluding `Boneyard/` to enumerate
      every remaining file, rather than working from a plan-time list.
- [ ] Sweep each. The planning re-scan's tail was:
      `BXCanonical/Quasimodel/Construction.lean` (6), `BXCanonical/Filtration/DefectChain.lean` (5),
      `BXCanonical/Chronicle/ChronicleConstruction.lean` (5),
      `BXCanonical/OrderedSeedConsistency.lean` (4), `BXCanonical/CanonicalChain.lean` (4),
      `BXCanonical/TruthLemma.lean` (3), `BXCanonical/Chronicle/ChronicleTypes.lean` (3),
      `Bundle/TemporalCoherence.lean` (2), `BXCanonical/CompletenessDedekind.lean` (1),
      `BXCanonical/Completeness.lean` (1), `BXCanonical/Chronicle/MCSMixedCase.lean` (1).
- [ ] `BXCanonical/TruthLemma.lean` was edited by Phase 4; start from its post-Phase-4 state.
- [ ] Commit per green file.

**Timing**: 1.25 hours

**Depends on**: 1, 4

**Verification Tier**: local

**Scope Hypothesis**: ~35 sites across ~11 files (report §5's "12 further files / 47 sites"; the
planning re-scan gives 11 files / 35 sites). **Confirmed at implementation: 44 sites across 16
files** — the plan's 11-file tail plus five files neither the report nor the re-scan listed:
`Bundle/RealExtensionBundle.lean` (3), `Chronicle/ChronicleMonadicBridge.lean` (3),
`WeakCanonical/IntegerModel/ReynoldsBridge.lean` (1),
`WeakCanonical/GroupModel/CountermodelBase.lean` (1), and
`Chronicle/ChronicleToCountermodel.lean` (1).

**Repo-wide total across Phases 7-10: 196 genuine sites in 25 files** (57 + 57 + 38 + 44), which
lands on report §5's 197 rather than the planning re-scan's 174. The re-scan undercounted for two
reasons, both regex limitations rather than tree drift: a parenthesized MCS argument
(`(h_mcs t)`) defeats its `\S+`, and the dot-notation form
`h_mcs.implication_property (theorem_in_mcs h_mcs d) x` is invisible to it entirely.

**`Core/MCSProperties.lean` is deliberately excluded from the sweep.** Its two matches are
`mp_of_theorem`'s own docstring and its own body — the body *is* the composite, by definition.
Rewriting it would make the lemma refer to itself. The repo-wide scan therefore correctly settles
at 2 remaining occurrences, both in that one declaration, not at 0.

**Files to modify**:
- The 11 files enumerated above, plus any additional file the repo-wide scan finds

**Verification**:
- Guarded `lake build` green per file; full gate before the phase closes
- A repo-wide paren-matching scan over `FormalSystem/` excluding `Boneyard/` returns **2**
  occurrences of the composite idiom, both inside `SetMaximalConsistent.mp_of_theorem`'s own
  declaration in `Core/MCSProperties.lean` (its docstring and its defining body). Every *consumer*
  site is 0. *(deviation: altered — "returns 0" as written is unachievable without making the new
  lemma self-referential; the defining occurrence is the fixed point of the sweep, not a miss.)*
- `bash scripts/check-module-invariants.sh` passes; C2 unchanged

---

### Phase 11: Core/README.md refresh, mcs_auto decision record, and final gate [NOT STARTED]

**Goal**: Bring `Core/README.md` up to date with the post-consolidation directory and record the
`mcs_auto` rejection permanently, then run the full acceptance gate.

**Tasks**:
- [ ] Update `Core/README.md`, whose `:162` still reads *Last verified: 2026-05-29* against a
      directory that has moved on (`MCSProperties.lean` dated 2026-09-02, the README itself
      2026-09-01). Reflect the new `Core` surface: `exists_maximal_of_chainClosed`,
      `SetConsistent.bot_not_mem`, `SetMaximalConsistent.bot_not_mem`,
      `SetMaximalConsistent.mp_of_theorem`; the four deleted superset definitions; the four
      retired boundedness lemmas.
- [ ] Insert the `mcs_auto` decision record using the draft text at report §4.4 (evaluated and
      rejected 2026-09-03; the `negation_complete`-instantiation blocker; the inert
      `DerivationTree`-argument forward rules; the declare-in-a-separate-imported-module mechanic;
      the note that the productive consolidation at these sites is `mp_of_theorem`, not
      automation).
- [ ] Add a one-line note that `CanonicalTask_backward` was already retired by an earlier task and
      is intentionally out of scope here, so it is not re-opened. **Do not cite a task number** —
      `.claude/rules/no-task-references-in-deliverables.md` forbids task-number citations outside
      `specs/**`; cite the Boneyard path
      (`FormalSystem/Boneyard/BundleDeadHalf/CanonicalTaskRelation.lean`) instead.
- [ ] Verify every module-shaped path and relative link in the rewritten README resolves
      (invariants C5, C12, C13) and every documented axiom/sorry count matches the tree (C14).
- [ ] Run the full acceptance gate and record the results in the implementation summary.

**Timing**: 0.75 hours

**Depends on**: 3, 4, 6, 7, 8, 9, 10

**Verification Tier**: full

**Scope Hypothesis**: exactly one file edited, and `Core/README.md:162` is still the `Last
verified` line. Confirm with `grep -n "Last verified" FormalSystem/Metalogic/Core/README.md` — the
line number is from the research measurement and will have drifted if any earlier phase touched
the README.

**Files to modify**:
- `FormalSystem/Metalogic/Core/README.md` - refresh inventory, add `mcs_auto` decision record and
  the out-of-scope note

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- FormalSystem` green
- `bash scripts/check-module-invariants.sh` passes in full — B0, C1-C15, C9D — with C2 unchanged
  from baseline and C3 at zero structural sorries
- `grep -rn "task [0-9]" FormalSystem/Metalogic/Core/README.md` returns nothing (invariant C9)
- Every acceptance criterion in "Testing & Validation" below checked off with evidence

---

## Testing & Validation

Acceptance criteria, mapped to the phases that deliver them:

- [ ] **One Zorn lemma**: `exists_maximal_of_chainClosed` is the only Zorn argument in `Core/`;
      `set_lindenbaum` and `restricted_lindenbaum` are instantiations (Phase 2)
- [ ] **One boundedness story**: the four dead lemmas are retired, or (fallback) collapsed onto
      `exists_boundary_of_one` (Phase 3)
- [ ] **One `bot_not_mem` in the live tree**:
      `grep -rn "bot_not_in_mcs" FormalSystem --include=*.lean | grep -v Boneyard` returns nothing
      (Phase 4)
- [ ] **Zero inline `right_mono_until`-with-top idioms in `Bundle/`** (Phase 5)
- [ ] **`Transfer.lean` no longer imports BXCanonical for a one-liner** — inspect its import block
      (Phase 4)
- [ ] **Zero remaining composite `implication_property … theorem_in_mcs …` idioms** in live scope
      (Phases 7-10)
- [ ] **`mcs_auto` decision recorded** in `Core/README.md`, decision = reject, with the structural
      blockers named (Phase 11)
- [ ] **`lake build` green** — detached and guarded per
      `context/project/lean4/operations/long-builds.md` (every phase)
- [ ] **C2 axiom baseline unchanged** — `bash scripts/check-module-invariants.sh`; divergence is a
      hard stop, never a re-baselining (every phase; explicitly after Phase 6)
- [ ] **Zero structural `sorry`, zero new axioms** (every phase)
- [ ] **No `Core/MCSAesop.lean`, no Aesop rule set, no `mcs_auto` macro anywhere in the tree**
      (negative check, Phase 11)

## Artifacts & Outputs

- `specs/526_core_mcs_api_consolidation/plans/01_core-mcs-api-consolidation.md` (this file)
- `specs/526_core_mcs_api_consolidation/summaries/01_core-mcs-api-consolidation-summary.md`
  (produced at implementation)
- New declarations: `exists_maximal_of_chainClosed`, `SetConsistent.bot_not_mem`,
  `SetMaximalConsistent.bot_not_mem`, `SetMaximalConsistent.mp_of_theorem`, `someFuture_mono`,
  `somePast_mono`, `DerivationTree.ofWeakeningNil` (+ 2 height lemmas) and its BaseLanguage twin
- One new Boneyard module receiving the four retired boundedness lemmas
- Refreshed `FormalSystem/Metalogic/Core/README.md` carrying the `mcs_auto` rejection record
- Net line reduction estimate: ~111→39 (Phase 2), 157 retired (Phase 3), ~30 (Phase 4), ~115
  (Phase 5), ~10 (Phase 6), ~170-200 (Phases 7-10)

## Rollback/Contingency

- Every phase is independently revertible: phases commit per green sub-step, so
  `git revert` of a phase's commit range restores the prior state without disturbing other phases.
- Take `bash .claude/scripts/git-snapshot.sh 526` before any intentional rollback that would
  discard uncommitted work; never `git reset --hard` on a dirty tree.
- **Never discard uncommitted changes to reach a passing build** — fix forward per
  `.claude/context/contracts/recovery.md`.
- If Phase 3's confirmation finds a live consumer of the boundedness lemmas, switch to the
  `Nat.find` fallback (report §3.2) rather than retiring; record the deviation.
- If Phase 6's C2 check diverges, stop the phase, revert its commits, and report — the flagship
  axiom baseline is never re-recorded to accommodate a change.
- If a sweep phase (7-10) exhausts context mid-file, the last committed green file is the resume
  point; the remaining files are enumerated by re-running that phase's confirmation scan.
