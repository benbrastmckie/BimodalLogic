# Implementation Plan: Frame-Class Uniformity

- **Task**: 450 - frame_class_parameterization_restricted_mcs
- **Status**: [IMPLEMENTING]
- **Effort**: 18 hours
- **Dependencies**: None
- **Research Inputs**: `specs/450_frame_class_parameterization_restricted_mcs/reports/01_frame-class-parameterization-research.md`
- **Artifacts**: plans/01_frame-class-uniformity-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Remove the ad hoc `FrameClass.Base` pins from the restricted-MCS layer and the derived-theorem
libraries beneath it, so that every declaration is stated at the weakest frame class at which it
is derivable and is `{fc : FrameClass}`-polymorphic wherever it is class-independent. The gate
result — deliverable (c), a Discrete-system consistency lemma — lands first, because a
Discrete-instantiated MCS layer is vacuous without it. Definition of done: all six deliverables
(a)-(f) landed, `lake build` exit 0 at every commit, and `scripts/check-module-invariants.sh`
reporting all ten check groups PASS with exactly one live sorry.

### Research Integration

Three findings from the research report reshape the plan versus the task description:

1. **The description's spelling of deliverable (a) does not compile.**
   `{fc : FrameClass := FrameClass.Base}` is a Lean 4 syntax error — `optParam` is not permitted
   on implicit binders. The verified working design is a **trailing explicit**
   `(fc : FrameClass := FrameClass.Base)` on definitions, plus **leading implicit
   `{fc : FrameClass}`** on theorems (inferred from the hypothesis). Leading-explicit optParam and
   `variable`-level optParam were both tested and fail. This spelling is fixed in Phase 2 and used
   verbatim thereafter.

2. **Deliverable (a) is a pure mechanical transform with zero proof repair, already spiked green.**
   The full generalisation of `Core/RestrictedMCS/Basic.lean` (662 lines, 23 Base occurrences)
   compiled with zero errors, and `lake build FormalSystem.Metalogic.Decidability.FMP.FMP`
   rebuilt the entire downstream FMP layer with zero source changes. Default-to-Base is a
   confirmed regression firewall, and deliverable (b) is satisfied by construction: the three
   preserved FMP theorems keep their explicit `¬Derivable FrameClass.Base [] phi` statements and
   are never edited.

3. **The real deliverable-(e) surface is ~4x the description's grep census, and grep cannot see
   it.** `⊢ φ` is itself a Base pin (`notation:50 "⊢ " φ => DerivationTree FrameClass.Base [] φ`,
   `ProofSystem/Derivation.lean:330`), as is `Γ ⊢ φ` (:325) and both `|-!` forms
   (`Derivable.lean:87,92`). A declaration written with bare `⊢` is Base-pinned and produces no
   `FrameClass.Base` grep hit. Counting declarations instead of tokens, `FormalSystem/Theorems/`
   holds **244 declarations, 202 of them Base-pinned** — against the 32 grep hits the description
   cites for the same files. The polymorphic sibling `⊢[fc] φ` already exists
   (`Derivation.lean:320`), so the transform is mechanical but wide. Phases 6-10 are sized against
   the declaration count, not the grep count.

Two corrections the research established that the plan honours:

- **Nothing in section 5 of the task description is red.** The full harness reports all ten check
  groups PASS. C6, C9, and `lake build BimodalTest` were fixed by earlier work today. Moreover
  the description's C6 claim was misattributed in the first place: C6 is the
  unreachable-module-manifest check and never reported the `CoValidity.lean:104 simp` failure it
  is credited with; there is no live `simp` failure in `CoValidity.lean`. **No phase schedules
  work to fix any of these, and their being green is the expected baseline.**
- **The 417 evidence file has moved.** It is at
  `specs/archive/417_semantic_fmp_finite_worldstate_over_z/evidence/spike-untl-unfolding-and-fwd-obstruction.lean`;
  the description's un-archived path no longer resolves. It was recompiled during research and
  all 9 declarations audit clean (`propext`, `Classical.choice`, `Quot.sound`; no `sorryAx`).

### Prior Plan Reference

No prior plan. This is plan version 1 for this task.

### Roadmap Alignment

`roadmap_path` was not supplied in the delegation context, so no roadmap consultation was
performed as a plan input. `specs/ROADMAP.md` does exist and its FMP track (`fmp_completeness`,
FMP truth preservation) and its entry for the semantic-FMP work are the downstream consumers this
task unblocks; the plan does not modify ROADMAP.md.

## Goals & Non-Goals

**Goals**:

- (c) Land `not_derivable_nil_bot_discrete` in `Soundness.lean` — the first lemma, without which
  everything else is vacuous.
- (a) Parameterise `RestrictedConsistent` / `RestrictedMCS` / `RestrictedConsistentSupersets` /
  `closure_mcs_deductively_closed` and the downstream FMP layer by `fc`, defaulting to Base so
  every existing call site elaborates unchanged.
- (b) Preserve `mcs_finite_model_property`, `fmp_contrapositive`, `fmp_size_bound` verbatim as
  theorems about the Base system. Hard-coding Discrete is rejected.
- (d) Promote the spike's Discrete unfolding schema and its polymorphic plumbing into the library,
  consolidating the currently-triplicated combinators.
- (e) Make `FormalSystem/Theorems/` uniformly `{fc}`-polymorphic, with a docstring line on every
  declaration whose class is genuinely essential saying why.
- (f) Produce the repo-wide audit table classifying every remaining `FrameClass.Base` occurrence
  as legitimately-Base / generalised / deliberately-deferred, as a deliverable artifact.
- Zero new sorry; live-sorry count stays at exactly 1 (`countermodel_discrete`), verified via
  `scripts/check-module-invariants.sh`, never naive grep.

**Non-Goals**:

- Does NOT implement the filtered step relation, `filteredStep_fwd`/`bwd`, `FilteredStepFrame`,
  the bi-lasso layer, or the semantic FMP.
- No edits under `/home/benjamin/Philosophy/Papers/` (read-only ground truth).
- Does NOT reconcile Discrete with Dense/Dedekind — they are incomparable in `FrameClass`'s order
  (`Axioms.lean` ~:505-517). No joint class is added.
- Does NOT schedule any repair of C6, C9, or `BimodalTest` — all three are green (see Research
  Integration).
- Does NOT generalise `Metalogic/Bundle/`, `Metalogic/BXCanonical/`, or
  `Metalogic/Algebraic + WeakCanonical/` (364 occurrences, ~313 gratuitous). These are far larger
  than the named deliverables and touch the canonical-model construction, which the FMP work does
  not depend on. They are **deliberately deferred with a reason recorded in the deliverable-(f)
  audit table** (category iii) — the description explicitly permits this — rather than silently
  omitted or half-attempted.
- Does NOT fix the `Automation/Tactics/Helpers.lean:1010,1062` hardcoded
  `` mkConst ``FrameClass.Base `` in `tryModalK` / `tryTemporalK`. This is a real capability gap
  (those tactics cannot fire at non-Base classes), not a naming issue, and fixing it is
  metaprogramming work orthogonal to the rest. Deferred with a reason in the audit table.
- Does NOT change the `⊢` / `Γ ⊢` / `|-!` notations themselves. They stay as Base-pinned
  conveniences; declarations move to `⊢[fc]` instead.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Generalising a statement from `⊢ φ` to `⊢[fc] φ` breaks a downstream call site where `fc` cannot be inferred (`have h := em A` leaves `?fc` unresolved) | H | H | Phases 6-10 carry verification tier `full`. Each is one file group, committed only when `lake build` exits 0. If a call site cannot infer, annotate it `(fc := FrameClass.Base)` at the call site rather than reverting the generalisation |
| The optParam spelling is re-derived incorrectly at a later phase, silently reintroducing the syntax error or the positional-misassignment failure | M | M | The verified spelling is fixed in Phase 2 and restated as the single reference recipe; Phases 3+ copy it verbatim rather than re-deriving |
| A preserved deliverable-(b) statement drifts | H | L | The three theorems are never edited. Phase 3 verifies their statements byte-identically via `git diff` on the enclosing hunks before committing |
| `import Mathlib.Data.Int.SuccPred` in `Soundness.lean` brings `ℤ` instances into scope repo-wide and changes `simp`/elaboration behaviour somewhere downstream | M | L | Phase 1 tier `full`; the import is already present in five other live modules, so the instances are not new to the build |
| A promoted combinator collides with an existing name | M | L | Verified at plan time: `orIntroL`, `orIntroR`, `orElim`, `guardMono`, `eventMono`, `necG`, `wk`, `topNegImpBot`, `untlBotFalse`, `succIndicator`, `nextConj` exist nowhere in the live tree; `topThm`, `andIntro`, `orElimBot`, `thmIn`, `baseThm` exist only as `private` in `DedekindDerived` |
| New `Theorems/DiscreteUnfolding.lean` becomes an unreachable live module and trips C6 | M | M | Phase 5 wires it into the `FormalSystem/Theorems.lean` aggregator (verified: the aggregator imports 9 modules and does not currently import `TemporalDerived` or `ContextualProofs`, so aggregator membership is not automatic) and runs `check-module-invariants.sh` |
| Argument-order regression when promoting the spike schema | H | M | `Formula.untl` is guard-first / event-second per `specs/decisions/untl-snce-argument-order.md` (DECIDED 2026-08-17); the pretty-printer renders event-first `U(e,g)`. Phase 5 preserves constructor order, not rendering |
| Phases 8-10 (158 declarations) overrun the budget | M | M | They are the last code phases and are independently commitable per file. If budget binds, the deliverable-(f) audit table classifies the untouched remainder as category (iii) with a reason — which is the description's own permitted outcome |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 4 | 1 |
| 3 | 3, 5, 6 | 2, 4 |
| 4 | 7, 8, 9, 10 | 6 |
| 5 | 11 | 3, 5, 7, 8, 9, 10 |
| 6 | 12 | 11 |

Phases within the same wave can execute in parallel. Note that parallel Lean phases share one
build graph: run them in parallel only with disjoint file ownership, and serialise the `lake build`
gate.

---

### Phase 1: Discrete-System Consistency Lemma [COMPLETED]

**Goal**: Land deliverable (c). Everything downstream is vacuous without it.

**Tasks**:
- [ ] Add `import Mathlib.Data.Int.SuccPred` to `FormalSystem/Metalogic/Soundness.lean`. This
      import is load-bearing: without it `ValidDiscrete`'s binder list fails to synthesize
      `SuccOrder ℤ` and `PredOrder ℤ`. `Semantics/Validity.lean` imports the *classes*
      (`Mathlib.Order.SuccPred.Basic`, `.Archimedean`) but not the *ℤ instances*.
- [ ] Add `not_derivable_nil_bot_discrete` beside the existing `not_derivable_nil_bot`
      (`Soundness.lean:1968`), using `soundness_discrete_valid` (:1334) at `D = ℤ` on
      `TaskFrame.trivialFrame`:
      ```lean
      theorem not_derivable_nil_bot_discrete :
          ¬ Derivable FrameClass.Discrete [] Formula.bot := by
        rintro ⟨d⟩
        obtain ⟨τ⟩ := TaskFrame.hF_nonempty_of_frameAxioms (D := ℤ) TaskFrame.trivialFrame
        exact Truth.bot_false
          (FormalSystem.Metalogic.soundness_discrete_valid d ℤ TaskFrame.trivialFrame
            TaskModel.allFalse τ.val τ.property 0)
      ```
- [ ] Docstring it, mirroring `not_derivable_nil_bot`'s explanation of the `¬ Derivable …` rather
      than `Consistent []` phrasing (import-graph reason).
- [ ] `#print axioms FormalSystem.Metalogic.not_derivable_nil_bot_discrete` — must report exactly
      `[propext, Classical.choice, Quot.sound]`, no `sorryAx`.
- [ ] `lake build` exit 0; commit.

**Timing**: 0.5 hours

**Depends on**: none

**Verification Tier**: full

**Scope Hypothesis**: The proof above is asserted to compile as written (it was compiled during
research via `lake env lean` against the current tree) and to require exactly one added import.
Confirm by pasting it in, building, and checking that no other module's build output changes
character. If the added import perturbs any downstream `simp` set, that is in scope for this phase
to repair — it is caused by this work, not inherited.

**Files to modify**:
- `FormalSystem/Metalogic/Soundness.lean` - one import; one theorem beside `not_derivable_nil_bot`

**Verification**:
- `lake build` exits 0
- `#print axioms` reports no `sorryAx`
- `bash scripts/check-module-invariants.sh` still reports exactly 1 live sorry

---

### Phase 2: Parameterise the Restricted-MCS Core [COMPLETED]

**Goal**: Deliverable (a) at its root — `Core/RestrictedMCS/Basic.lean` — and fix the reference
spelling that every later phase copies.

**Tasks**:
- [ ] Add `{fc : FrameClass}` to the file's `variable` line: `variable {phi : Formula}` becomes
      `variable {phi : Formula} {fc : FrameClass}`.
- [ ] Give `RestrictedConsistent` (:71), `RestrictedMCS` (:78) and
      `RestrictedConsistentSupersets` a **trailing explicit** `(fc : FrameClass := FrameClass.Base)`
      binder. The parameter must be trailing, not leading: a leading explicit optParam misassigns
      positional arguments (`argument phi … expected optParam FrameClass`), and a `variable`-level
      optParam fails the same way because `variable` inserts `fc` first. An implicit optParam
      (`{fc : FrameClass := FrameClass.Base}`) is a Lean 4 syntax error.
- [ ] Rewrite `SetConsistent (fc := FrameClass.Base)` to `SetConsistent (fc := fc)` throughout.
- [ ] Thread the new argument through applications (`RestrictedConsistent phi S fc`).
- [ ] Replace the remaining in-proof `FrameClass.Base` occurrences with `fc`, including all 9 in
      `restricted_mcs_negation_complete` and the `DerivationTree.axiom (fc := …)` in
      `restricted_mcs_from_formula`.
- [ ] Theorems take the leading implicit `{fc}` from the `variable` line, inferred from their
      hypothesis — e.g. `restricted_consistent_is_consistent {S} (h : RestrictedConsistent phi S fc)
      : SetConsistent (fc := fc) S := h.2`.
- [ ] Confirm the resulting signature is
      `@RestrictedMCS : Formula → Set Formula → optParam FrameClass FrameClass.Base → Prop`.
- [ ] **Regression firewall check, before touching anything downstream**:
      `lake build FormalSystem.Metalogic.Decidability.FMP.FMP` must exit 0 with **zero source
      changes** to the FMP layer. This is the whole point of default-to-Base; if it fails, stop and
      diagnose rather than editing downstream files to compensate.
- [ ] `lake build` exit 0; commit.

**Timing**: 1 hour

**Depends on**: 1 — this is the task description's explicit sequencing directive ("(c) is the
FIRST lemma of the task"), not a technical dependency; `Basic.lean` does not import
`Soundness.lean`.

**Verification Tier**: interface

**Commit Mode**: per-substep

**Scope Hypothesis**: 23 `FrameClass.Base` occurrences in `Basic.lean` (confirmed by
`grep -c` at plan time), of which 3 are definition sites, 14 are in proof bodies, and the
remainder are docstring/comment. The transform is asserted to require **zero proof repair** — the
research spike compiled the generalised 662-line file with zero errors and a single pre-existing
`Try this: intro L hL ⟨d⟩` warning (at :414 in the untouched original, shifted one line by the
added binder). Confirm by comparing the build output's warning set against the pre-edit build;
any *new* error means the mechanical assumption is wrong for that hunk and it needs a real proof
edit, which must be called out.

**Files to modify**:
- `FormalSystem/Metalogic/Core/RestrictedMCS/Basic.lean` - three defs gain the trailing optParam;
  `fc` threaded through proofs

**Verification**:
- `lake build FormalSystem.Metalogic.Decidability.FMP.FMP` exits 0 with no downstream edits
- `lake build` exits 0
- Legacy call forms still elaborate: `RestrictedConsistent phi S` defaults to Base;
  `restricted_consistent_is_consistent h` unifies `{fc}` to Base from `h`
- New forms elaborate: `RestrictedMCS phi S FrameClass.Discrete` and
  `RestrictedMCS phi S (fc := FrameClass.Discrete)`

---

### Phase 3: Parameterise the Decidability/FMP Layer [COMPLETED]

**Goal**: Deliverable (a) downstream, with deliverable (b) preserved by construction.

**Tasks**:
- [ ] Parameterise `closure_mcs_deductively_closed`
      (`Metalogic/Decidability/FMP/ClosureMCS.lean:171`) by `{fc}`, using the Phase 2 recipe
      verbatim.
- [ ] Sweep the remaining gratuitous pins in `FMP/ClosureMCS.lean` (15 occurrences),
      `FMP/TruthPreservation.lean` (8), `FMP/Filtration.lean` (1). `FMP/FiniteModel.lean` and
      `FMP/Periodicity.lean` have zero.
- [ ] `FMP/FMP.lean` (9 occurrences): **do not edit** `mcs_finite_model_property` (:230),
      `fmp_contrapositive` (:243), `fmp_size_bound` (:269). Their `¬Derivable FrameClass.Base []
      phi` statements are the deliverable-(b) preserved assets. Generalise only pins that are not
      part of these three statements or of `Decidability/Correctness.lean`'s `fmp_completeness` /
      `fmp_incompleteness_witness`, which are also legitimately Base.
- [ ] Every pin left in place in this layer gets a docstring line saying why its class is
      essential (deliverable (e)'s docstring rule, applied here as it is reached).
- [ ] Before committing: `git diff` the three preserved theorem hunks and confirm they are
      byte-identical to `HEAD`.
- [ ] `lake build` exit 0; commit.

**Timing**: 1.5 hours

**Depends on**: 2

**Verification Tier**: interface

**Commit Mode**: per-substep

**Scope Hypothesis**: 33 gratuitous pins across `Metalogic/Decidability/`, of a 51-occurrence
total with 6 legitimately Base and 5 structural (research §6). Per-file grep counts confirmed at
plan time: ClosureMCS 15, FMP 9, TruthPreservation 8, Filtration 1, FiniteModel 0, Periodicity 0.
Confirm by re-running the per-file count before and after and reconciling every delta against the
audit categories; a pin that resists generalisation is category (i) or (iii), not a silent skip.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/FMP/ClosureMCS.lean` - `closure_mcs_deductively_closed` + pins
- `FormalSystem/Metalogic/Decidability/FMP/TruthPreservation.lean` - pins
- `FormalSystem/Metalogic/Decidability/FMP/Filtration.lean` - one pin
- `FormalSystem/Metalogic/Decidability/FMP/FMP.lean` - pins outside the three preserved statements only

**Verification**:
- `lake build` exits 0
- `git diff HEAD -- FormalSystem/Metalogic/Decidability/FMP/FMP.lean` shows no change inside the
  three preserved theorem statements
- `bash scripts/check-module-invariants.sh` reports 1 live sorry

---

### Phase 4: Promote the Polymorphic Plumbing [COMPLETED]

**Goal**: Deliverable (d), first half. Consolidate the currently-triplicated combinators into the
library so downstream work reuses them instead of rebuilding them a fourth time.

**Tasks**:
- [ ] De-`private` `thmIn` (`DedekindDerived.lean:77`), `baseThm` (:82), `topThm` (:87),
      `andIntro` (:100), `orElimBot` (:116) and **move** them to `Theorems/Combinators.lean`
      (namespace `FormalSystem.Theorems.Combinators`), leaving `DedekindDerived` to import and use
      them. `Combinators` is the root of the `Theorems/` import graph (it imports only
      `ProofSystem.Derivation`, `Syntax.Formula`, `Automation.LemmaDB`), so this introduces no
      cycle.
- [ ] Any promoted helper that needs `lceImp` / `rceImp` (which live in
      `Theorems/Propositional/Core.lean`, not `Combinators`) goes to `Propositional/Core.lean`
      instead — notably the `andFst` / `andSnd` pair. Do not move `Propositional`-dependent
      helpers into `Combinators`; that would invert the import graph.
- [ ] Promote from the evidence file
      (`specs/archive/417_semantic_fmp_finite_worldstate_over_z/evidence/spike-untl-unfolding-and-fwd-obstruction.lean`,
      lines ~66-186) the `{fc}`-polymorphic plumbing absent from the live tree: `necG`, `wk`,
      `orIntroL`, `orIntroR`, `orElim`, `guardMono`, `eventMono`, `topNegImpBot`, `untlBotFalse`.
      Route each to `Combinators` or `Propositional/Core` by its dependency set, per the previous
      bullet.
- [ ] `baseThm` (`d.lift (FrameClass.base_le fc)`) is the canonical Base-to-any-`fc` lift and the
      reference recipe for Phases 6-10: at a `DerivationTree.axiom` site, the `le` proof becomes
      `(FrameClass.base_le fc)`.
- [ ] `lake build` exit 0; commit.

**Timing**: 1.5 hours

**Depends on**: 1 — sequencing only; this phase needs nothing from Phase 2 or 3 and owns a
disjoint file set, so it can run in parallel with Phase 2.

**Verification Tier**: interface

**Commit Mode**: per-substep

**Scope Hypothesis**: 14 promotion targets asserted absent from the live tree. Verified at plan
time: `orIntroL`, `orIntroR`, `orElim`, `guardMono`, `eventMono`, `necG`, `wk`, `topNegImpBot`,
`untlBotFalse` have **zero** live declarations; `topThm`, `andIntro`, `orElimBot`, `thmIn`,
`baseThm` exist **only** as `private` in `DedekindDerived`. Confirm the placement split
(`Combinators` vs `Propositional/Core`) at implementation time by checking each promoted
declaration's actual dependency set — the plan-time split above is a hypothesis derived from
where `lceImp`/`rceImp`/`pairing`/`identity` live, not from compiling each one.

**Files to modify**:
- `FormalSystem/Theorems/Combinators.lean` - receives the `Derivation`-only plumbing
- `FormalSystem/Theorems/Propositional/Core.lean` - receives plumbing needing `lceImp`/`rceImp`
- `FormalSystem/Theorems/DedekindDerived.lean` - private helpers removed; now imports them

**Verification**:
- `lake build` exits 0
- `DedekindDerived` builds unchanged in behaviour (its 15 declarations remain `{fc}`-polymorphic)
- No duplicate declaration names anywhere in the live tree

---

### Phase 5: Promote the Discrete Unfolding Schema [COMPLETED]

**Goal**: Deliverable (d), second half — the Discrete-specific schema, in a new library module.

**Tasks**:
- [ ] Create `FormalSystem/Theorems/DiscreteUnfolding.lean` (does not currently exist).
- [ ] Promote from the evidence file, preserving proofs: `succIndicator` (:191), `unfoldForward`
      (:212), `unfoldBackward` (:280), `nextConj` (:303), `unfoldTableForward` (:347),
      `unfoldTableBackward` (:369), `noBlockingTriple` (:398). All are stated at
      `⊢[FrameClass.Discrete]` except `nextConj`, which is `{fc}`-polymorphic and must stay so.
- [ ] Reuse the Phase 4 plumbing rather than re-deriving it. The evidence file's local copies of
      `topThm`/`andIntro`/`orElim`/`guardMono`/`eventMono` are the third copy of these
      combinators; promoting them again would make a fourth.
- [ ] **Argument order**: `Formula.untl` is guard-first / event-second per
      `specs/decisions/untl-snce-argument-order.md` (DECIDED 2026-08-17). The pretty-printer
      renders event-first `U(e,g)`. Preserve the constructor order from the evidence file; do not
      "fix" it to match the rendering.
- [ ] Add `import FormalSystem.Theorems.DiscreteUnfolding` to `FormalSystem/Theorems.lean`. This
      is required, not cosmetic: check C6 fails any live module that is neither import-reachable
      nor listed in the unreachable-module manifest.
- [ ] `#print axioms` each promoted declaration — all must report exactly
      `[propext, Classical.choice, Quot.sound]`.
- [ ] `lake build` exit 0; `bash scripts/check-module-invariants.sh`; commit.

**Timing**: 1.5 hours

**Depends on**: 4

**Verification Tier**: interface

**Scope Hypothesis**: 7 named declarations plus the `nxt` abbreviation (evidence :61), each
asserted to have zero live occurrences (verified by grep at plan time) and to recompile without
edit. Confirm by recompiling the evidence file first
(`lake env lean specs/archive/417_semantic_fmp_finite_worldstate_over_z/evidence/spike-untl-unfolding-and-fwd-obstruction.lean`)
so any drift between the evidence file and the current tree surfaces before, not during, the port.

**Files to modify**:
- `FormalSystem/Theorems/DiscreteUnfolding.lean` - new file
- `FormalSystem/Theorems.lean` - aggregator import + submodule docstring entry

**Verification**:
- `lake build` exits 0
- `bash scripts/check-module-invariants.sh` — all ten groups PASS, 1 live sorry, C6 clean
- Every promoted declaration audits sorry-free via `#print axioms`

---

### Phase 6: Generalise Theorems/Propositional [COMPLETED]

**Goal**: Deliverable (e) at the base of the `Theorems/` import graph. This is the largest
behavioural win — it is the layer whose Base pin forced the spike to rebuild combinators from
scratch, and every later `Theorems/` phase depends on it.

**Tasks**:
- [ ] `Propositional/Core.lean`: generalise the 10 Base-pinned declarations — `em` (:55),
      `botOfAndNeg` (:205), `impNegImp` (:257), `impOfNeg` (:326), `negImp` (:342), `orInl` (:354),
      `orInr` (:406), `impOfNegImpNeg` (:438), `andLeft` (:513), `andRight` (:582). The 5 already
      `{fc}`-polymorphic (`efqAxiom` :77, `peirceAxiom` :88, `doubleNegation` :135, `lceImp` :650,
      `rceImp` :668) are the in-file model.
- [ ] `Propositional/Connectives.lean`: generalise all 14 (0/14 currently polymorphic) —
      `classicalMerge`, `iffIntro`, `iffElimLeft`, `iffElimRight`, `contraposeImp`,
      `contraposition`, `contraposeIff`, `iffNegIntro`, the four De Morgan forward/backward pairs,
      `demorganConjNeg`, `demorganDisjNeg`.
- [ ] `Propositional/Reasoning.lean`: generalise all 4. (It has zero `FrameClass.Base` grep hits —
      all 4 pins are grep-invisible bare `⊢`, which is exactly the finding this phase is sized
      against.)
- [ ] Mechanical recipe: `⊢ φ` → `⊢[fc] φ`; `Γ ⊢ φ` → `Γ ⊢[fc] φ`; add `{fc : FrameClass}` (via
      the file `variable` line where one exists); at each `DerivationTree.axiom` site the `le`
      argument becomes `(FrameClass.base_le fc)`; whole-derivation lifts use
      `d.lift (FrameClass.base_le fc)`. `DedekindDerived.lean` (15/15 polymorphic) is the
      reference implementation for all of this.
- [ ] Repair downstream call sites where `fc` can no longer be inferred by annotating the call
      site `(fc := FrameClass.Base)` — never by reverting the generalisation.
- [ ] Any declaration that genuinely cannot be generalised gets a docstring line saying why its
      class is essential.
- [ ] `lake build` exit 0; commit per file.

**Timing**: 2 hours

**Depends on**: 2, 4 — technically only 4 (the promoted plumbing lands in `Combinators` and
`Propositional/Core`, and this phase edits `Propositional/Core`); 2 is listed for build-graph
serialisation, so two agents do not hold the build graph at once.

**Verification Tier**: full

**Scope Hypothesis**: 28 Base-pinned declarations across the three files (Core 10 of 15,
Connectives 14 of 14, Reasoning 4 of 4), per the research report's declaration-level census.
Grep-visible `FrameClass.Base` tokens are a *different and much smaller* number — 12, 5, and 0
respectively, confirmed at plan time — because bare `⊢` is an invisible pin. Confirm the
declaration count by enumerating `def`/`theorem`/`lemma` headers per file and checking each for a
`{fc}` binder; do **not** use the grep count as the completion criterion, or the phase will report
done at roughly half the surface.

**Files to modify**:
- `FormalSystem/Theorems/Propositional/Core.lean` - 10 declarations
- `FormalSystem/Theorems/Propositional/Connectives.lean` - 14 declarations
- `FormalSystem/Theorems/Propositional/Reasoning.lean` - 4 declarations
- Downstream call sites as needed for `fc` inference

**Verification**:
- `lake build` exits 0
- Every declaration in the three files carries `{fc}` or a docstring justifying its pin
- No statement weakened; each generalised statement is the old one with `Base` replaced by `fc`

---

### Phase 7: Generalise ModalS5 and ModalS4 [COMPLETED]

**Goal**: Deliverable (e) for the modal layer.

**Tasks**:
- [ ] `ModalS5.lean`: generalise the 12 Base-pinned declarations (9 grep-visible pins).
- [ ] `ModalS4.lean`: generalise the 4 Base-pinned declarations (2 grep-visible pins).
- [ ] Apply the Phase 6 recipe verbatim.
- [ ] Docstring any declaration that must stay pinned with the reason.
- [ ] `lake build` exit 0; commit per file.

**Timing**: 1.5 hours

**Depends on**: 6

**Verification Tier**: full

**Scope Hypothesis**: 16 declarations (ModalS5 12, ModalS4 4). Same grep-vs-declaration gap as
Phase 6: 9 and 2 grep-visible tokens respectively, confirmed at plan time. Enumerate declaration
headers, not grep hits, to determine completion.

**Files to modify**:
- `FormalSystem/Theorems/ModalS5.lean` - 12 declarations
- `FormalSystem/Theorems/ModalS4.lean` - 4 declarations

**Verification**:
- `lake build` exits 0
- `ModalS4` (which imports `ModalS5`) builds against the generalised `ModalS5`

---

### Phase 8: Generalise TemporalDerived [COMPLETED]

**Goal**: Deliverable (e) for the temporal layer — the single widest-consumed module in
`Theorems/` (imported by 11 live modules across `Metalogic/`, `Automation/`, and
`DedekindDerived`).

**Tasks**:
- [ ] Generalise all 45 declarations (0 currently polymorphic) using the Phase 6 recipe.
- [ ] Because this module has the widest live consumer set, repair `fc`-inference breakage at each
      consumer with an explicit `(fc := FrameClass.Base)` annotation.
- [ ] Docstring any declaration that must stay pinned with the reason.
- [ ] `lake build` exit 0; commit in coherent sub-groups.

**Timing**: 2 hours

**Depends on**: 6

**Verification Tier**: full

**Scope Hypothesis**: 45 declarations, 0 currently `{fc}`, and 11 live importing modules
(`Metalogic/Core/MCSProperties`, `Metalogic/BXCanonical/Chronicle/{RRelation,PointInsertion}`,
`Metalogic/Bundle/{UntilSinceCoherence,WitnessSeed}`, `Metalogic/Decidability/FMP/TruthPreservation`,
`Theorems/DedekindDerived`, `Automation/{AesopRules,ProofStepExport,Tactics/Helpers}`) — importer
list confirmed by grep at plan time. Confirm the declaration count by header enumeration; confirm
the consumer set by re-running the import grep before starting, since Phases 3 and 5 may have
added importers.

**Files to modify**:
- `FormalSystem/Theorems/TemporalDerived.lean` - 45 declarations
- Consumer call sites as needed for `fc` inference

**Verification**:
- `lake build` exits 0
- All 11 importing modules build without statement changes of their own

---

### Phase 9: Generalise ContextualProofs [COMPLETED]

**Goal**: Deliverable (e) for the contextual-derivation layer.

**Tasks**:
- [ ] Generalise the 71 Base-pinned declarations (1 of 72 is already `{fc}`).
- [ ] `ContextualProofs.lean` imports only `ProofSystem.Derivation` and `Theorems.Combinators`, so
      it does not depend on Phase 6's output — but it does depend on Phase 4's promoted plumbing.
- [ ] Docstring any declaration that must stay pinned with the reason.
- [ ] `lake build` exit 0; commit in coherent sub-groups.

**Timing**: 2 hours

**Depends on**: 6 — declared for build-graph serialisation. The only *technical* dependency is
Phase 4 (`Combinators`); if run in parallel with Phases 7/8/10, file ownership is disjoint and the
`lake build` gate must be serialised.

**Verification Tier**: full

**Scope Hypothesis**: 72 declarations, 1 already `{fc}`, leaving 71. This is the largest
single-file declaration count in the phase set despite the file being only 468 lines — the
declarations are short. Confirm by header enumeration before starting; if the real count exceeds
~80, split the phase in two along the file's section boundaries rather than overrunning.

**Files to modify**:
- `FormalSystem/Theorems/ContextualProofs.lean` - 71 declarations

**Verification**:
- `lake build` exits 0
- `Automation/ProofStepExport.lean` (the one live importer) builds unchanged

---

### Phase 10: Generalise Perpetuity [COMPLETED]

**Goal**: Deliverable (e) for the perpetuity principles — the last code phase.

**Tasks**:
- [ ] `Perpetuity/Principles.lean`: generalise 20 declarations.
- [ ] `Perpetuity/MonotonicityDuality.lean`: generalise 19 declarations.
- [ ] `Perpetuity/Helpers.lean`: generalise the 3 remaining Base-pinned declarations (3 of 6 are
      already `{fc}`).
- [x] `Perpetuity.lean` is a pure aggregator (0 declarations, confirmed at plan time) — no
      generalisation needed there, but update its submodule docstring if it describes the
      submodules as Base-only. *(deviation: altered — the aggregator docstring contains no
      `Base`/`FrameClass` mention at all, so no docstring edit was needed and none was made.)*
- [ ] Order within the phase: `Helpers` first (`Principles` and `MonotonicityDuality` both import
      it), then `Principles`, then `MonotonicityDuality` (which imports `Principles`).
- [ ] Docstring any declaration that must stay pinned with the reason.
- [ ] `lake build` exit 0; commit per file.

**Timing**: 2 hours

**Depends on**: 6

**Verification Tier**: full

**Scope Hypothesis**: 42 Base-pinned declarations across three files (Principles 20,
MonotonicityDuality 19, Helpers 3 of 6). Confirm by header enumeration. `ModalS4` and `ModalS5`
both import `Theorems.Perpetuity`, so if Phase 7 ran first, some inference repair may already be
in place — re-check rather than assuming.

**Files to modify**:
- `FormalSystem/Theorems/Perpetuity/Helpers.lean` - 3 declarations
- `FormalSystem/Theorems/Perpetuity/Principles.lean` - 20 declarations
- `FormalSystem/Theorems/Perpetuity/MonotonicityDuality.lean` - 19 declarations
- `FormalSystem/Theorems/Perpetuity.lean` - docstring only, if stale

**Verification**:
- `lake build` exits 0
- `bash scripts/check-module-invariants.sh` — all ten groups PASS, 1 live sorry

---

### Phase 11: Docstring Sweep [COMPLETED]

**Goal**: Eliminate the actively-misleading Base prose on already-generic declarations, and ensure
every surviving pin carries its "why this class is essential" line.

**Tasks**:
- [ ] `Metalogic/Core/MaximalConsistent.lean` (6 occurrences) and `Metalogic/Core/MCSProperties.lean`
      (6 occurrences): these are **100% stale prose** — docstrings saying "Base" on declarations
      that are already fully `{fc}`-generic (`Consistent`, `SetConsistent`, `SetMaximalConsistent`,
      `set_lindenbaum`, `consistent_chain_union`, `closed_under_derivation`, `implication_property`,
      `negation_complete`, …). Zero code change; high documentation value.
- [ ] Sweep the remaining category-(iv) doc/comment occurrences (61 repo-wide per research §6)
      wherever they describe generic code as Base-only.
- [ ] Verify every declaration left pinned by Phases 1-10 carries a docstring line stating why its
      class is essential — the deliverable-(e) rule. Category (i) sites in scope for this check:
      `Soundness.lean` (`soundness`, `not_derivable_nil_bot`, `axiom_valid`),
      `SoundnessLemmas/FrameClassVariants.lean` (6 × `minFrameClass ≤ Base` admissibility splits),
      `FrameConditions/Soundness.lean`, `FrameConditions/Compatibility.lean`,
      `Axioms.lean:600` `FrameClass.base_le`, `BXCanonical/Completeness.lean` `completeness`,
      `Decidability/ProofExtraction.lean` (4 `minFrameClass ≤ Base` guards),
      `Decidability/Correctness.lean` (`fmp_completeness`, `fmp_incompleteness_witness`),
      and the three preserved FMP theorems.
- [ ] `lake build` exit 0; commit.

**Timing**: 1 hour

**Depends on**: 3, 5, 7, 8, 9, 10

**Verification Tier**: prose

**Scope Hypothesis**: 12 stale-prose occurrences in `Core/{MaximalConsistent,MCSProperties}.lean`
(6 each, confirmed by `grep -c` at plan time) and 61 category-(iv) occurrences repo-wide. Confirm
each is genuinely comment-only before editing: the tier's blind spot is an edit that crosses out
of the comment region, so read each changed hunk and confirm it lies inside a `/--`, `/-!`, or
`--` region. Run `lake build` anyway at phase close — the prose tier governs in-phase granularity
only, not the closing gate.

**Files to modify**:
- `FormalSystem/Metalogic/Core/MaximalConsistent.lean` - 6 docstrings
- `FormalSystem/Metalogic/Core/MCSProperties.lean` - 6 docstrings
- Category-(i) sites listed above - one "why essential" line each where missing

**Verification**:
- `lake build` exits 0 (no code was touched, so this should be a no-op relink)
- No remaining docstring describes an `{fc}`-generic declaration as Base-only

---

### Phase 12: Repo-Wide Audit Table [NOT STARTED]

**Goal**: Deliverable (f) — the audit table as a deliverable artifact, not scratch work.

**Tasks**:
- [ ] Enumerate every remaining `FrameClass.Base` occurrence in the live tree (non-Boneyard),
      broken out FormalSystem vs Tests.
- [ ] Classify each as: (i) legitimately Base-specific, (ii) generalised by this task,
      (iii) deliberately deferred with a reason. Include the grep-invisible bare-`⊢` pins as a
      separate accounting line — a token census alone understates the surface roughly 4x and the
      table must not repeat that error.
- [ ] Record the deliberate deferrals with their reasons:
      - `Metalogic/Bundle/` (92), `Metalogic/BXCanonical/` (138),
        `Metalogic/Algebraic + WeakCanonical/` (134) — 364 occurrences, ~313 gratuitous. Deferred:
        far larger than the named deliverables, and they touch the canonical-model construction,
        on which the FMP work does not depend. Note the concrete payoff a future task inherits:
        `BXCanonical/CanonicalModel.lean:426` documents that the existing chain machinery
        (`FwdSucc`, `BwdPred`, `IntChain`) is hardcoded to Base, and :544-572 define parallel
        `fwdChainFc` / `bwdChainFc` / `IntChainFc` / `FwdSuccFc` / `BwdPredFc` twins with `fc`
        free — generalising the originals lets the twins be **deleted**.
      - `Automation/Tactics/Helpers.lean:1010,1062` — hardcoded
        `` mkConst ``FrameClass.Base ``, so `tryModalK` / `tryTemporalK` cannot fire at non-Base
        classes. A real capability gap; fixing it is metaprogramming work orthogonal to this task.
      - The `⊢` / `Γ ⊢` / `|-!` notations themselves (`Derivation.lean:325,330`;
        `Derivable.lean:87,92`) — retained as Base-pinned conveniences by design.
      - `Tests/` (148 occurrences) — unaffected, because default-to-Base means every existing test
        call site elaborates unchanged. Record as category (iii) with that reason, not as an
        oversight.
      - Any `Theorems/` declaration Phases 6-10 could not reach.
- [ ] Write the table to
      `specs/450_frame_class_parameterization_restricted_mcs/reports/02_frame-class-base-audit.md`.
- [ ] Final gate: `bash scripts/check-module-invariants.sh` — all ten groups PASS, exactly 1 live
      sorry (`countermodel_discrete`, `WeakCanonical/Transfer.lean`), verified by the script and
      never by naive grep. `lake build` and `lake build BimodalTest` both exit 0.
- [ ] Commit.

**Timing**: 1.5 hours

**Depends on**: 11

**Verification Tier**: prose

**Scope Hypothesis**: The plan-time baseline is 670 live `FrameClass.Base` occurrences (522
FormalSystem + 148 Tests), confirmed by grep at plan time, against 2,086 bare-`⊢` and 313 `⊢[`
lines under `FormalSystem/`. The post-implementation counts will differ; the audit's completion
criterion is that **every** remaining occurrence is classified, not that any particular count is
reached. Confirm by re-running the census at audit time and reconciling the category totals
against it — an unreconciled remainder is a defect in the audit, not a rounding error.

**Files to modify**:
- `specs/450_frame_class_parameterization_restricted_mcs/reports/02_frame-class-base-audit.md` - new artifact

**Verification**:
- Every remaining live `FrameClass.Base` occurrence appears in exactly one category
- Category totals sum to the re-run census count
- `bash scripts/check-module-invariants.sh` — ALL CHECKS PASSED, 1 live sorry
- `lake build` and `lake build BimodalTest` exit 0

---

## Testing & Validation

- [ ] `lake build` exits 0 at **every** commit — the task's verification contract, not a
      phase-close convenience.
- [ ] `lake build BimodalTest` exits 0 at task close.
- [ ] `bash scripts/check-module-invariants.sh` reports ALL CHECKS PASSED, with exactly 1 live
      sorry (`countermodel_discrete`). Never verify the sorry count by naive grep.
- [ ] `lake build FormalSystem.Metalogic.Decidability.FMP.FMP` exits 0 after Phase 2 with **zero**
      downstream source changes — the default-to-Base regression firewall.
- [ ] `#print axioms` on `not_derivable_nil_bot_discrete` and on every declaration promoted in
      Phase 5 reports exactly `[propext, Classical.choice, Quot.sound]`.
- [ ] `git diff` on `FMP.lean` shows the three deliverable-(b) theorem statements byte-identical
      to their pre-task form.
- [ ] Zero new sorry, zero new axiom, zero vacuous definition, no statement restated in a
      trivially-true form. Any statement change is called out explicitly in the summary.
- [ ] Legacy elaboration is unchanged: `RestrictedConsistent phi S` and
      `restricted_consistent_is_consistent h` both still resolve `fc` to Base with no call-site
      edit.

## Artifacts & Outputs

- `specs/450_frame_class_parameterization_restricted_mcs/plans/01_frame-class-uniformity-plan.md` — this plan
- `specs/450_frame_class_parameterization_restricted_mcs/reports/02_frame-class-base-audit.md` — deliverable (f) audit table
- `specs/450_frame_class_parameterization_restricted_mcs/summaries/01_frame-class-uniformity-summary.md` — implementation summary
- `FormalSystem/Theorems/DiscreteUnfolding.lean` — new library module (deliverable (d))
- Modified: `Metalogic/Soundness.lean`, `Metalogic/Core/RestrictedMCS/Basic.lean`,
  `Metalogic/Core/{MaximalConsistent,MCSProperties}.lean`,
  `Metalogic/Decidability/FMP/{ClosureMCS,TruthPreservation,Filtration,FMP}.lean`,
  `Theorems.lean`, `Theorems/{Combinators,DedekindDerived,TemporalDerived,ContextualProofs,ModalS4,ModalS5}.lean`,
  `Theorems/Propositional/{Core,Connectives,Reasoning}.lean`,
  `Theorems/Perpetuity/{Helpers,Principles,MonotonicityDuality}.lean`

## Rollback/Contingency

Every phase ends at a green `lake build` and its own commit, so rollback is `git revert` of the
offending phase commit. The phases are ordered so that the two load-bearing results land first and
independently: Phase 1 (deliverable (c)) is a single self-contained theorem plus one import, and
Phase 2 (deliverable (a)) is confined to one file whose downstream layer is protected by the
default-to-Base firewall. Reverting Phases 6-12 leaves Phases 1-5 intact and still unblocks the
downstream filtered-step work; reverting Phase 2 requires also reverting Phase 3.

If a generalisation in Phases 6-10 proves genuinely non-mechanical for a declaration — the proof
needs a Base-specific fact rather than a `FrameClass.base_le` lift — leave it pinned, add the
"why this class is essential" docstring line, and record it in the Phase 12 audit as category (i)
or (iii). That is the described outcome, not a failure. Do **not** introduce a `sorry` to force a
generalisation through: the live-sorry count is contractually fixed at 1.
