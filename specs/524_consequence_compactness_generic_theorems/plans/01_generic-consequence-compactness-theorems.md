# Implementation Plan: Generic Consequence / Compactness / Strong-Completeness Theorems

- **Task**: 524 - Finish the FrameClass collapse at the THEOREM layer of the consequence/compactness/strong-completeness stack
- **Status**: [IMPLEMENTING]
- **Effort**: 15 hours
- **Dependencies**: None (WAVE 3 theorem layer; task 523's definition-layer collapse already landed at `b7da18269`)
- **Research Inputs**: `specs/524_consequence_compactness_generic_theorems/reports/01_consequence-compactness-generic-theorems.md`
- **Artifacts**: plans/01_generic-consequence-compactness-theorems.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

The definitions in `FormalSystem/Metalogic/` are already generic in `FrameClass`, but almost every
theorem is still four per-class copies, because three textbook facts were never named:
`WeakCompleteness fc`, the `StrongCompleteness ↔ Compact ↔ ModelExistence` triangle, and a shared
refutation skeleton. This plan states those three, then rewrites the per-class layer as one-line
instantiations, adds the two structural upgrades (`modelExistence_of_satPreserved`,
`PointedModel`), and closes with a dead-code / naming / manifest sweep plus the
`Metalogic/Conservativity/` directory reorganization. Done means: the two named iffs exist, zero
per-class copies of the four skeletons remain, `lake build` is green, and
`scripts/check-module-invariants.sh` reports ALL PASS with the C2/C14 axiom baselines extended to
cover every declaration this task touches.

### Research Integration

The research report elaborated every proposed declaration against the built library with
`lake env lean` across seven scratch probes. All of items 1-6 are **known-constructible**, not
speculative, and every new terminus measured the expected axiom profile
`[propext, Classical.choice, Quot.sound]`. The plan therefore treats the report's Lean snippets as
transcription targets rather than sketches. Five report findings are load-bearing on phase design
and are carried into the phases below:

1. **Items 2 and 3 interleave** and cannot be sequential phases. The real edges are
   `WeakCompleteness → strongCompleteness_iff_compact`, `not_compact_of_witness →
   modelExistence_of_compact`, and `compact_of_strongCompleteness → not_strongCompleteness_of_witness`.
   Phases 4 and 5 are cut along those edges, not along the item numbering.
2. **`modelExistence_of_satPreserved`'s reviewed hypothesis does not typecheck** — `ofModel F M`
   has carrier `F.HF`, so `(ofModel F M).frame` is a genuinely different frame. The fix is the
   one-line bridge `sat_ofModel_frame … := by cases fc <;> exact h`, and `T` must be an
   **explicit** binder in `hpres` or the Dense discharge fails.
3. **`exists_strictMono_qPoints` must also expose `t < ch 0`** — `dedWitness_core`'s `htz` step
   consumes exactly that fact and the caller cannot recover it.
4. **The `PointedModel` migration is source-compatible.** `rcases`/`obtain` auto-flattens through
   `Nonempty` plus a single-constructor structure, so all six existing destructuring sites compile
   unchanged. Item 5 is a definition swap, not a call-site campaign.
5. **The "C2 manifest" is not `scripts/module-invariants-manifest.txt`** (that is C6's
   known-unreachable list). It is four order-sensitive heredocs inside
   `scripts/check-module-invariants.sh` — `AXIOM_BASELINE`/`AX_SRC` for C2 and
   `C14_BASELINE`/`C14LEAN` for C14 — compared by exact string equality.

Four corrections to the task's premises that the plan does **not** re-import:

- **B-08 already landed.** All five BL-vs-TM files are in the build graph
  (`Metalogic.lean:17,18,20,21` plus `Z1Countermodel.lean:8`). Phase 8 rests on the B-19
  convention alone, not on "which is how they fell out of the build".
- **The dead-declaration count is 13, not 15**, and the list changed (task 523 already deleted the
  six per-class `.of_forall`/`.apply` adapters). Phase 9 carries the re-measured list.
- **`semantic_deduction_base` is not byte-identical to its three siblings** — it routes through the
  frame-condition-free Base adapters. It still collapses to the same one-liner, but the diff will
  not look like the other three.
- **There is one `SatisfiableSet.of_forall`, not four.** Item 5's "the four `*_of_forall`
  constructors" reads as "the one `SatisfiableSet.of_forall`".

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No `roadmap_path` was supplied in the delegation context; `specs/ROADMAP.md` was not consulted.

## Goals & Non-Goals

**Goals**:
- Name `WeakCompleteness fc`, `semantic_deduction_in`, `soundness_consequence`, and retype the
  three longhand engine hypotheses to use the new name.
- Prove `strongCompleteness_iff_compact` and `compact_iff_modelExistence`, and draw
  `¬ ModelExistenceDedekind`.
- Collapse the four refutations onto one shared `not_compact_of_witness` /
  `not_strongCompleteness_of_witness` skeleton.
- Generalize model existence to `modelExistence_of_satPreserved` with an ultraproduct-closure
  hypothesis, with `modelExistenceBase` / `modelExistenceDense` as instantiations.
- Introduce `structure PointedModel fc Γ`, restate `SatisfiableSet` over it, add
  `FinitelySatisfiableSet` and the two bridge iffs.
- Generalize `TMComplete` / `Forward` in `fc`, with the four existing names as instantiations.
- Delete the 13 dead `SetConsequence` declarations and the `Core.MaximalConsistent` import; adopt
  one naming scheme; migrate in-file `#print axioms` into the C2/C14 heredocs, keeping only the
  five termini in-file.
- Create `Metalogic/Conservativity/` with a sibling aggregator and fix the wrong-carrier /
  denied-result passages at `Conservativity.lean:345-357`.

**Non-Goals**:
- Any change under `FormalSystem/Semantics/Correspondence/` or its neighbours — that is task 525's
  territory. In particular `sat_ofModel_frame` is homed in `Compactness.lean`, not in
  `Semantics/ShiftSet.lean` or `Semantics/FrameClassValidity.lean`.
- Proving strong completeness for `.Discrete` or `.Dedekind` (both are refuted; that is the point).
- Introducing any `sorry`. Every declaration in this plan has been elaborated to completion during
  research; a `sorry` here is a defect, not a deferral.
- Adding deprecated aliases for the renamed refutation theorems — research verified they are cited
  only in prose, never at a `.lean` call site outside their defining files.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| C2/C14 heredoc pairs drift out of order and the exact-string-equality compare reports a false axiom regression ("HARD STOP, not a new baseline") | H | M | Phase 11 edits all four heredocs in one pass, appending in identical order to both members of each pair, and runs `check-module-invariants.sh` before committing. Every earlier phase that adds or renames a covered declaration updates the heredocs in that same phase's commit. |
| `SatisfiableSet` becoming `Nonempty (PointedModel …)` changes axiom profiles downstream via `Nonempty.elim` | H | L | Phase 7 re-runs C2/C14 **after** the swap. Research probed `PointedModel` against the *current* definition only, so this is the one place where a probe does not transfer. |
| The ~60-citation path sweep in Phase 8 lands out of step with the file moves, tripping C5/C12/C13 | H | M | Phase 8 declares `Commit Mode: atomic-batch`: the moves and the sweep are one objective with expected-red intermediate states, committed only once `check-module-invariants.sh` is green. |
| A phase touches a declaration named in the C2/C14 baselines or in `Metalogic/README.md` prose and misses the co-edit | M | M | Every phase's Verification step names `bash scripts/check-module-invariants.sh` explicitly; C5/C12/C14 are the failing checks and their names are recorded per phase. |
| The refutation rename (Phase 10) breaks a call site research did not find | M | L | Re-run the grep at implementation time (Phase 10 Scope Hypothesis) rather than trusting the plan's count; `lake build` catches any missed `.lean` site regardless. |
| Territory collision with task 525 in `FormalSystem/Semantics/` | M | L | No phase writes under `FormalSystem/Semantics/`. If a phase finds it needs to, stop and report rather than editing. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2, 3 | -- |
| 2 | 4, 6 | 1 |
| 3 | 5, 8 | 2, 4 (P5); 6 (P8) |
| 4 | 7 | 3, 5 |
| 5 | 9 | 7 |
| 6 | 10 | 5, 8, 9 |
| 7 | 11 | 1-10 |

Phases within the same wave can execute in parallel. The wave-1 trio is genuinely disjoint by
file: Phase 1 owns `StrongCompleteness.lean` + `SetConsequence.lean`, Phase 2 owns
`DiscreteNonCompactness.lean` + `DedekindNonCompactness.lean`, Phase 3 owns `Compactness.lean`.

---

### Phase 1: Generic deduction, soundness guard, and `WeakCompleteness` [COMPLETED]

**Goal**: Name the three missing generic facts of item 1 and retype the engine layer onto
`WeakCompleteness`, so every downstream phase has a single hypothesis to quote.

**Tasks**:
- [x] Add `def WeakCompleteness (fc : FrameClass) : Prop := ∀ ψ : Formula, ValidIn fc ψ → Derivable fc [] ψ`
      to `SetConsequence.lean`, beside `StrongCompleteness` (its two ingredients are already
      imported at `:8,10`).
- [x] Add `semantic_deduction_in {fc} (Γ φ) : SemanticConsequenceIn fc Γ φ ↔ ValidIn fc (Γ.foldr Formula.imp φ)`
      to `StrongCompleteness.lean` (must live there — it needs `truthAt_foldr_imp`; stating it in
      `SetConsequence.lean` is an import cycle, as the docstrings at `:322-325`/`:398-401` record).
- [x] Add `soundness_consequence {fc} (Γ φ) (h : Derivable fc Γ φ) : SemanticConsequenceIn fc Γ φ`
      to `StrongCompleteness.lean`, adjacent to `soundness_setConsequence` (`:949`) so the finite
      and `Set Formula` halves of B-02 read as one pair.
- [x] Collapse `semantic_deduction_{dedekind,base,dense,discrete}` (`:238`, `:615`, `:728`, `:851`)
      to one-line instantiations. Expect the Base row's diff to differ from the other three: it
      currently routes through `Valid.of_forall_total` / `SemanticConsequence.of_forall` / `.apply`.
- [x] Collapse `soundness_{dedekind,base,dense,discrete}_consequence` (`:508`, `:658`, `:772`,
      `:893`) to one-line instantiations.
- [x] Add `consequence_completeness_of_engine` and retype the three longhand engine hypotheses
      (`strongCompleteness_of_compact` at `:358`, `consequence_completeness_dedekind_of_engine` at
      `:487`, `completeness_dedekind_of_engine` at `:526`) to take `WeakCompleteness fc`.
- [x] State the four `BXCanonical` corollaries as `WeakCompleteness .X` witnesses:
      `completeness_base`, `completeness_dense`, `completeness_discrete`, `completeness_dedekind`
      inhabit them on the nose — no transport, no `rfl` lemma.

**Timing**: 1.5 hours

**Depends on**: none

**Verification Tier**: full

**Files to modify**:
- `FormalSystem/Metalogic/SetConsequence.lean` — add `WeakCompleteness`
- `FormalSystem/Metalogic/StrongCompleteness.lean` — add the two generics, collapse eight per-class
  theorems, retype three engine hypotheses

**Verification**:
- `lake build` green.
- `bash scripts/check-module-invariants.sh` ALL PASS (C1, C2, C14 in particular — the engine
  retype touches `completeness_dedekind`, `strongCompletenessBase`, `strongCompletenessDense`,
  all three of which are C14 baseline entries).
- `#print axioms` on each retyped engine corollary still reads
  `[propext, Classical.choice, Quot.sound]`.

---

### Phase 2: `dedWitness_core` split and the `@[simp]` membership lemmas [NOT STARTED]

**Goal**: Land B-20 and B-21 — extract the two chain lemmas out of `dedWitness_core` and add the
two membership simp lemmas — independently of the compactness work, so Phase 5's refutation
collapse lands on already-tidied witness modules.

**Tasks**:
- [ ] Extract `qAlpha_step (q M τ a) (ha : ∀ n, TruthAt M τ a (qAlpha q n)) : ∃ s, a < s ∧ TruthAt M τ s (Formula.atom q) ∧ ∀ n, TruthAt M τ s (qAlpha q n)`
      from `DedekindNonCompactness.lean:205-257`.
- [ ] Extract `exists_strictMono_qPoints (q M τ t) (ht : ∀ n, TruthAt M τ t (qAlpha q n)) : ∃ ch : ℕ → F.Duration, StrictMono ch ∧ t < ch 0 ∧ ∀ n, TruthAt M τ (ch n) (Formula.atom q)`.
      **The `t < ch 0` conjunct is mandatory** — `dedWitness_core`'s `htz` step at `:250` is
      `lt_of_lt_of_le (hc 0).1 (hz.1 ⟨0, rfl⟩)` and consumes exactly it. The review's proposed
      signature omits it and is wrong.
- [ ] Rebuild `dedWitness_core` on top of the two lemmas (research measured 51 lines → 15).
- [ ] Add `@[simp] mem_archWitness_iff` to `DiscreteNonCompactness.lean` and
      `@[simp] mem_dedWitness_iff` to `DedekindNonCompactness.lean`.
- [ ] Replace the three witness-extraction sites inside `dedWitness_core` with `h _ (by simp)`, and
      reduce the `simp only [<witness>, Set.mem_union, Set.mem_singleton_iff, Set.mem_setOf_eq]`
      incantations at `DiscreteNonCompactness.lean:203` and `DedekindNonCompactness.lean:393-394`
      to plain `simp`.

**Timing**: 1.5 hours

**Depends on**: none

**Verification Tier**: full

**Scope Hypothesis**: `dedWitness_core` is asserted to fall from 51 lines to ~15, and exactly three
witness-extraction sites plus two `simp only` incantations are asserted to simplify. Confirm at
implementation time by `wc -l` on the rebuilt declaration and by grepping for remaining
`simp [dedWitness]` / `simp only [archWitness` occurrences in the two files; record the actual
counts in the phase commit message.

**Files to modify**:
- `FormalSystem/Metalogic/DedekindNonCompactness.lean` — two extracted lemmas, rebuilt
  `dedWitness_core`, `mem_dedWitness_iff`
- `FormalSystem/Metalogic/DiscreteNonCompactness.lean` — `mem_archWitness_iff`, simp-site cleanup

**Verification**:
- `lake build` green. A new `@[simp]` lemma is globally scoped, so the full build is the gate, not
  a per-module build.
- `bash scripts/check-module-invariants.sh` ALL PASS.
- `#print axioms` on `dedWitness_not_satisfiable` and `archWitness_not_satisfiable` unchanged.

---

### Phase 3: `modelExistence_of_satPreserved` and the `sat_ofModel_frame` bridge [NOT STARTED]

**Goal**: Land item 4 — one generic model-existence proof parameterized by an ultraproduct-closure
hypothesis on `fc.Sat`, with the two existing near-identical proofs as instantiations.

**Tasks**:
- [ ] Add `sat_ofModel_frame {fc} {F} (M : TaskModel F) (h : fc.Sat F) : fc.Sat (ShiftSet.ofModel F M).frame := by cases fc <;> exact h`
      to `Compactness.lean`. **Home it here, not in `Semantics/`** — its only consumer lives here,
      and `Semantics/ShiftSet.lean` / `Semantics/FrameClassValidity.lean` are adjacent to task 525's
      territory. Do not state the converse `sat_frame_of_sat_ofModel` unless a consumer appears.
- [ ] Add `modelExistence_of_satPreserved {fc} (hpres : ∀ {I : Type} (u : Ultrafilter I) (T : I → TemporalOrder) (S : ∀ i, ShiftSet (T i)), (∀ i, fc.Sat (S i).frame) → fc.Sat (uShiftSet u S).frame) : ModelExistence fc`,
      reusing `modelExistenceBase`'s existing body verbatim after the `refine`.
      **`T` must be an explicit binder.** With `{T}` implicit, the `S i` projection in the Dense
      discharge elaborates `S : I → TemporalOrder` and fails with `Invalid field 'frame'`. `I` may
      stay implicit.
- [ ] Rewrite `modelExistenceBase` (`:84`) as `modelExistence_of_satPreserved (fun _ _ _ _ => trivial)`.
- [ ] Rewrite `modelExistenceDense` (`:122`) as the `DenselyOrdered` discharge shown in the report.
- [ ] Write the docstring the generalization unlocks: `hpres` is **false** at `.Discrete` and
      `.Dedekind` (ultraproducts of Archimedean orders need not be Archimedean; of
      Dedekind-complete orders need not be complete), and `discrete_consequence_not_compact` /
      `dedekind_consequence_not_compact` are the machine-checked proof that no route around it
      exists. This docstring replaces the four-module status prose.
- [ ] Delete the now-stale type-ascription explanation at `Compactness.lean:110-121`, which
      describes `TaskFrame.IsDense` as "a plain `def`" — it is an `abbrev` since
      `FrameProperty.lean:97`.

**Timing**: 1.5 hours

**Depends on**: none

**Verification Tier**: interface

**Files to modify**:
- `FormalSystem/Metalogic/Compactness.lean` — bridge lemma, generic model existence, two
  instantiations, docstrings

**Verification**:
- `lake build` green.
- `bash scripts/check-module-invariants.sh` ALL PASS. C14 covers `strongCompletenessBase` and
  `strongCompletenessDense` (`Compactness.lean:157,164`), both downstream of the rewritten proofs,
  so a profile change surfaces here.

---

### Phase 4: The shared refutation skeleton and `strongCompleteness_iff_compact` [NOT STARTED]

**Goal**: Land the interleaved half of items 2 and 3 — the three generic lemmas that the four
refutations and the two iffs both depend on. This is the phase boundary the dependency edges force:
`compact_of_strongCompleteness` (item 2) feeds `not_strongCompleteness_of_witness` (item 3), so
they must share a phase.

**Tasks**:
- [ ] Add `setConsequence_of_not_satisfiable {fc} {Γ} {φ} (h : ¬ SatisfiableSet fc Γ) : SetSemanticConsequenceOn fc Γ φ`.
- [ ] Add `compact_of_strongCompleteness {fc} (h : StrongCompleteness fc) : Compact fc`. **Use
      `soundness_validIn`** (`Soundness.lean:1319`, the empty-context form uniform in `fc`), not the
      review's `soundness_in [] _ d … (by simp)` — it removes the `ValidIn.of_forall_total` wrapper
      and the vacuous-context `simp` entirely.
- [ ] Add `strongCompleteness_iff_compact {fc} (engine : WeakCompleteness fc) : StrongCompleteness fc ↔ Compact fc`,
      as `⟨compact_of_strongCompleteness, fun hc => strongCompleteness_of_compact hc engine⟩`.
- [ ] Add `not_compact_of_witness {fc} {W} (hfin) (hunsat) : ¬ Compact fc`.
- [ ] Add `not_strongCompleteness_of_witness`, routing through `compact_of_strongCompleteness`.
- [ ] Note in the skeleton's docstring that this routing means the `*_refuted` theorems will no
      longer mention `soundness_discrete` / `soundness_dedekind` at all — B-21's case (c)
      disappears outright rather than being helped. (The `haveI` lines it retires are deleted in
      Phase 5, where the refutation bodies are rewritten.)

**Timing**: 1.5 hours

**Depends on**: 1

**Verification Tier**: interface

**Files to modify**:
- `FormalSystem/Metalogic/StrongCompleteness.lean` — five new generic declarations

**Verification**:
- `lake build` green.
- `bash scripts/check-module-invariants.sh` ALL PASS.
- `#print axioms` on each of the five new declarations reads `[propext, Classical.choice, Quot.sound]`.

---

### Phase 5: The compactness triangle and the four one-line refutations [NOT STARTED]

**Goal**: Close item 2 (`modelExistence_of_compact`, `compact_iff_modelExistence`,
`¬ ModelExistenceDedekind`) and item 3's payoff (the four refutations become one-liners).

**Tasks**:
- [ ] Add `modelExistence_of_compact {fc} (hc : Compact fc) : ModelExistence fc` — literally the
      contrapositive of Phase 4's `not_compact_of_witness`, via `by_contra`.
- [ ] Add `compact_iff_modelExistence {fc} : Compact fc ↔ ModelExistence fc :=
      ⟨modelExistence_of_compact, compact_of_modelExistence⟩`.
- [ ] Draw `modelExistenceDedekind_refuted : ¬ ModelExistenceDedekind :=
      fun h => dedekind_consequence_not_compact (compact_of_modelExistence h)`, and delete the
      `SetConsequence.lean:565-570` docstring claim that it is "simply not drawn here".
- [ ] Rewrite `discrete_consequence_not_compact` (`DiscreteNonCompactness.lean:250`) and
      `strongCompletenessDiscrete_refuted` (`:279`) as `not_compact_of_witness` /
      `not_strongCompleteness_of_witness` applications at `archWitness ⟨"p", none⟩`.
- [ ] Rewrite `dedekind_consequence_not_compact` (`DedekindNonCompactness.lean:423`) and
      `strongCompletenessDedekind_refuted` (`:451`) likewise at `dedWitness ⟨"q", none⟩`.
- [ ] Delete the two now-dead `haveI : DenselyOrdered F.Duration := hd` lines
      (`DedekindNonCompactness.lean:441`, `:462`) and their explanatory prose at `:415-421`,
      `:447-449`; delete the bare-instance-binder `rintro ⟨F, ⟨_,_,_,_⟩, M, τ, hτ, t, hsat⟩`
      discipline at `DiscreteNonCompactness.lean:288`.

**Timing**: 1 hour

**Depends on**: 2, 4

**Verification Tier**: full

**Files to modify**:
- `FormalSystem/Metalogic/StrongCompleteness.lean` — two new generic theorems
- `FormalSystem/Metalogic/SetConsequence.lean` — `modelExistenceDedekind_refuted` + docstring fix
- `FormalSystem/Metalogic/DiscreteNonCompactness.lean` — two refutations collapsed
- `FormalSystem/Metalogic/DedekindNonCompactness.lean` — two refutations collapsed, `haveI`
  cleanup

**Verification**:
- `lake build` green.
- `bash scripts/check-module-invariants.sh` ALL PASS.
- `grep -c 'soundness_discrete\|soundness_dedekind'` in the two NonCompactness files returns 0
  outside docstrings.
- `#print axioms` on all four refutations plus `modelExistenceDedekind_refuted` reads
  `[propext, Classical.choice, Quot.sound]`.

---

### Phase 6: `TMComplete` / `Forward` generic in `fc` [NOT STARTED]

**Goal**: Land item 6. The bridge B-22 asks for already exists as a theorem, so the only hypothesis
needed is `WeakCompleteness fc`.

**Tasks**:
- [ ] Add `def TMComplete (fc : FrameClass) : Prop` and `def Forward (fc : FrameClass) : Prop` to
      `TMCompletenessReduction.lean`. Both stay `def`s.
- [ ] Add `tmComplete_iff_forward {fc} (engine : WeakCompleteness fc) : TMComplete fc ↔ Forward fc`,
      using `blValidIn_iff_validIn_tr` (`BaseLanguageSoundness.lean:177`) and `soundness_validIn`.
      The conclusion is an `Iff`, not either side, so the module's "unasserted `def`, never a
      theorem conclusion" prohibition discipline (`:28-33`) is preserved — say so in the docstring.
- [ ] Restate `TMCompleteBase`/`ForwardBase`/`TMCompleteDiscrete`/`ForwardDiscrete` as
      instantiations, and rewrite `tmCompleteBase_iff_forwardBase` /
      `tmCompleteDiscrete_iff_forwardDiscrete` as `tmComplete_iff_forward completeness_base` /
      `… completeness_discrete`.
- [ ] Add the two free rows the generalization yields: `tmComplete_iff_forward completeness_dense`
      and `… completeness_dedekind`.
- [ ] Confirm `open FormalSystem.BaseLanguage` and `open FormalSystem.Metalogic.Conservativity` are
      in scope (already present at `:71,73`).

**Timing**: 1 hour

**Depends on**: 1

**Verification Tier**: interface

**Files to modify**:
- `FormalSystem/Metalogic/TMCompletenessReduction.lean` — two generic `def`s, one generic iff, four
  instantiations, two new rows

**Verification**:
- `lake build` green.
- `bash scripts/check-module-invariants.sh` ALL PASS.
- `#print axioms tmComplete_iff_forward` and the four instantiations read
  `[propext, Classical.choice, Quot.sound]`.

---

### Phase 7: `PointedModel` and the satisfiability bridges [NOT STARTED]

**Goal**: Land item 5 — restate `SatisfiableSet` over a named structure and add the two bridge
iffs, so compactness reads as "satisfiable iff finitely satisfiable".

**Tasks**:
- [ ] Add `structure PointedModel (fc : FrameClass) (Γ : Set Formula)` with the seven named fields
      (`Frame`, `inClass`, `Model`, `hist`, `htotal`, `time`, `models`).
- [ ] Redefine `SatisfiableSet fc Γ := Nonempty (PointedModel fc Γ)`.
- [ ] Add `def PointedModel.mono` — a **`def`, not a `theorem`**; `PointedModel` lives in `Type`,
      and stating it as a theorem fails with "type of theorem … is not a proposition".
- [ ] Add `SatisfiableSet.mono`, `def FinitelySatisfiableSet`, and
      `SatisfiableSet.finitelySatisfiable`.
- [ ] Retype the single `SatisfiableSet.of_forall` (`:260`) as `PointedModel.of` returning
      `PointedModel fc Γ`; keep a `SatisfiableSet.of_forall` wrapper if any call site wants the
      `Nonempty` form directly.
- [ ] Add `modelExistence_iff_finitelySatisfiable` and
      `satisfiableSet_iff_finitelySatisfiable (hme : ModelExistence fc)`, routing the task's "given
      `Compact fc`" phrasing through Phase 5's `compact_iff_modelExistence`. Watch the coercion
      trap: `(by simpa using hL)` alone fails at `{a | a ∈ L} ⊆ Γ` versus `∀ ψ ∈ L, ψ ∈ Γ`; write
      `intro ψ hψ; exact hL ψ (by simpa using hψ)`.
- [ ] Add `setConsequence_iff_not_satisfiable {fc} {Γ} {φ} : SetSemanticConsequenceOn fc Γ φ ↔ ¬ SatisfiableSet fc (Γ ∪ {φ.neg})`,
      and re-derive Phase 4's `setConsequence_of_not_satisfiable` from it as the `mpr` at
      `Γ ∪ {φ.neg} := Γ`. Keep both.
- [ ] Delete the ten-line anonymous-binder warning in the `SatisfiableDiscreteSet` docstring
      (`SetConsequence.lean:544-553`) — the structure's field names make it obsolete.
- [ ] Confirm the six existing destructuring sites still compile unchanged
      (`compact_of_modelExistence`, `archWitness_not_satisfiable`, `dedWitness_not_satisfiable`,
      the four refutations, `modelExistence{Base,Dense}`'s `refine`). Research verified `rcases`
      auto-flattens through `Nonempty` + a single-constructor structure; treat a failure here as a
      surprise worth reporting, not as expected churn.

**Timing**: 2 hours

**Depends on**: 3, 5

**Verification Tier**: full

**Scope Hypothesis**: six existing destructuring sites are asserted to compile unchanged. Confirm
by building with **no** call-site edits first; only if that fails, enumerate the actual failures and
record them. Do not pre-emptively rewrite call sites.

**Files to modify**:
- `FormalSystem/Metalogic/SetConsequence.lean` — structure, redefinition, three new defs/theorems,
  two bridge iffs, docstring deletion

**Verification**:
- `lake build` green with zero call-site edits (or an explicit record of which sites needed one).
- `bash scripts/check-module-invariants.sh` ALL PASS — **run C2 and C14 after the swap, not before**.
  `SatisfiableSet` becoming `Nonempty (PointedModel …)` is definitionally different from the bare
  `∃`, and every terminus downstream of it now passes through `Nonempty.elim`. This is the one
  place in the task where the research probes do not transfer, because item 5 was probed against
  the current definition.

---

### Phase 8: `Metalogic/Conservativity/` directory and the ~60-citation sweep [NOT STARTED]

**Goal**: Land item 8 — the five BL-vs-TM modules move under a `Conservativity/` subdirectory with
a sibling aggregator, every path citation is swept in the same commit, and the wrong-carrier /
denied-result passages are corrected.

**Tasks**:
- [ ] Create the target layout: `Metalogic/Conservativity.lean` (aggregator, carrying today's 231
      lines of narrative) plus `Conservativity/{Backward,BaseLanguageSoundness,TMCompletenessReduction,SpWitness,Z1Countermodel}.lean`.
      C8 (`check-module-invariants.sh:418-448`) requires exactly this shape: a sibling `X.lean` for
      every Lean-bearing subdirectory of `FormalSystem` and `FormalSystem/Metalogic`, and no
      self-named `X/X.lean`.
- [ ] **Import discipline**: the children must import
      `FormalSystem.Metalogic.Conservativity.Backward`, **never** the aggregator
      `FormalSystem.Metalogic.Conservativity`, or the build cycles. Preserve today's chain
      (`Conservativity ← BaseLanguageSoundness ← TMCompletenessReduction ← Z1Countermodel`, and
      `SpWitness ← BaseLanguageSoundness`) rewritten against `Backward`.
- [ ] Collapse `Metalogic.lean:17,18,20,21` to a single import of the aggregator.
- [ ] Sweep the path citations. Namespaces need no change — today's body is already
      `namespace FormalSystem.Metalogic.Conservativity`, so declarations keep their fully-qualified
      names when the file becomes `Backward.lean`.
- [ ] Fix B-17: rewrite `Conservativity.lean:345-349` ("says nothing about `TM_f ⊢ Z1`") and
      `:354-357` ("over `ℤ ×_lex ℤ` — an argument this repository cannot yet formalize"). Both are
      contradicted by the same file at `:70-79` (the carrier is `ℚ ×_lex ℤ`) and `:159-166` ("Both
      are now landed"). Point the corrected passages at `Z1Countermodel.not_bl_derivable_z1`
      (`Z1Countermodel.lean:175`) and `tmCompleteDiscrete_refuted` (`:199`).

**Timing**: 2 hours

**Depends on**: 6

**Verification Tier**: full

**Commit Mode**: atomic-batch

**Scope Hypothesis**: ~60 path citations are asserted to need sweeping —
`Metalogic/Conservativity.lean` 20, `BaseLanguageSoundness.lean` 23, `SpWitness.lean` 7,
`Z1Countermodel.lean` 5, `TMCompletenessReduction.lean` 5, plus the dotted module form
(`FormalSystem.Metalogic.Conservativity` 14, `…BaseLanguageSoundness` 6, three others 1 each).
Re-measure with `grep -rn` over the whole repo before the move and again after, and record both
counts in the commit message. The pre-move count is the hypothesis; the post-move count of
**zero** stale citations is the confirmation.

**Files to modify**:
- `FormalSystem/Metalogic/Conservativity.lean` → aggregator (rewritten) + `Conservativity/Backward.lean`
- `FormalSystem/Metalogic/{BaseLanguageSoundness,TMCompletenessReduction,SpWitness,Z1Countermodel}.lean`
  → moved under `Conservativity/`
- `FormalSystem/Metalogic.lean` — four imports collapse to one
- Every file carrying a citation of the five old paths (see Scope Hypothesis)

**Verification**:
- `lake build` green (import-cycle failures surface here first).
- `bash scripts/check-module-invariants.sh` ALL PASS — C8 (directory structure), C5 (dotted module
  names), C12/C13 (markdown path and link resolution) are the checks this phase can break.
- `grep -rn` for each of the five old module paths returns zero hits outside archive/boneyard.

---

### Phase 9: Dead-declaration deletion and the `Core.MaximalConsistent` import drop [NOT STARTED]

**Goal**: Land item 7's deletion half — remove the 13 unconsumed `SetConsequence` declarations and
the import that only they kept alive.

**Tasks**:
- [ ] Delete these 13 (all in `SetConsequence.lean`): `SetSemanticConsequenceBase` (`:112`),
      `SetSemanticConsequenceDense` (`:116`), `setDerivable_mono` (`:269`),
      `setSemanticConsequenceOn_mono_fc` (`:285`), `setSemanticConsequence{Base,Dense,Discrete,Dedekind}_mono`
      (`:291`, `:296`, `:301`, `:307`), `setDerivable_of_derivable` (`:321`),
      `derivable_of_setDerivable_contextToSet` (`:331`), `setDerivable_of_mem` (`:339`),
      `not_setConsistent_of_setDerivable_bot` (`:349`).
- [ ] **Keep** `SetSemanticConsequenceOn.apply_total` (`:237`) — it has no consumer today, but
      Phase 4's `not_compact_of_witness` makes it live.
- [ ] **Keep** `SetSemanticConsequence{Discrete,Dedekind}` (consumed by the two refutation
      modules), `setConsequenceOnFrames_mono` (`:277`), `setDerivable_iff_exists_finite` (`:316`)
      (both consumed by `soundness_setConsequence`), and `soundness_setConsequence` itself
      (`StrongCompleteness.lean:949`) — B-02 makes it the `Set Formula` half of the
      `soundness_consequence` pair.
- [ ] Drop the `Core.MaximalConsistent` import at `SetConsequence.lean:11`. Its only two live uses
      (`Core.contextToSet` at `:322`/`:332`, `Core.SetConsistent` at `:350`) sit inside three of
      the deleted declarations. Reword the prose reference at `:46`; do not delete it.

**Timing**: 1 hour

**Depends on**: 7

**Verification Tier**: full

**Scope Hypothesis**: exactly 13 declarations are asserted dead (research re-measured this down
from the task description's 15 — task 523 already deleted the six per-class adapters). Before
deleting, re-run the repo-wide grep excluding `Boneyard/` and the defining file for each name; a
declaration with a live consumer is kept and the discrepancy recorded rather than forced.

**Files to modify**:
- `FormalSystem/Metalogic/SetConsequence.lean` — 13 deletions, one import drop, one prose reword

**Verification**:
- `lake build` green (a wrongly-classified deletion fails here).
- `bash scripts/check-module-invariants.sh` ALL PASS.
- `grep -n 'Core\.' FormalSystem/Metalogic/SetConsequence.lean` returns only prose hits.

---

### Phase 10: Naming scheme and the stale-prose sweep [NOT STARTED]

**Goal**: Land item 7's naming half (B-18) and retire the documentation this task's work has made
untrue.

**Tasks**:
- [ ] Adopt `not<PropName>`: rename `discrete_consequence_not_compact` → `notCompactDiscrete`,
      `dedekind_consequence_not_compact` → `notCompactDedekind`,
      `strongCompletenessDiscrete_refuted` → `notStrongCompletenessDiscrete`,
      `strongCompletenessDedekind_refuted` → `notStrongCompletenessDedekind`. This mirrors the
      positive form already in use (`compactBase : CompactBase`) and keeps the `Prop` name first.
      No deprecated aliases.
- [ ] Sweep the rename through `scripts/check-module-invariants.sh` (the two old names appear in
      its C2 baseline candidates), `FormalSystem/Metalogic/README.md`, and `Metalogic.lean` prose
      — **in this same commit**, or C5/C12/C14 trip.
- [ ] Fix the stale prose the task does not list but this work invalidates:
      `StrongCompleteness.lean:48-58` still calls Base/Dense strong completeness "the intended
      eventual terminus" and "an open research question", though `strongCompletenessBase` /
      `strongCompletenessDense` are proved at `Compactness.lean:157,164`.
- [ ] Confirm the two prose items already handled upstream stayed handled: the
      `TaskFrame.IsDense` "plain `def`" explanation (`Compactness.lean:110-121`, deleted in Phase 3)
      and the `haveI` notes (`DedekindNonCompactness.lean:415-421,447-449`, deleted in Phase 5).

**Timing**: 1.5 hours

**Depends on**: 5, 8, 9

**Verification Tier**: interface

**Scope Hypothesis**: the four old names are asserted to be cited only in docstring prose, with no
`.lean` call site outside their defining files. Re-run `grep -rn` for each of the four across
`FormalSystem/`, `scripts/`, `docs/`, and `README.md` before renaming; `lake build` is the backstop
for any missed `.lean` site.

**Files to modify**:
- `FormalSystem/Metalogic/DiscreteNonCompactness.lean`, `DedekindNonCompactness.lean` — renames
- `FormalSystem/Metalogic/StrongCompleteness.lean` — stale-terminus prose
- `FormalSystem/Metalogic/README.md`, `FormalSystem/Metalogic.lean` — prose citations
- `scripts/check-module-invariants.sh` — baseline candidate names

**Verification**:
- `lake build` green.
- `bash scripts/check-module-invariants.sh` ALL PASS (C5, C12, C14 in particular).
- `grep -rn` for each of the four old names across the repo returns zero hits outside
  `Boneyard/`/archive.

---

### Phase 11: `#print axioms` consolidation into the C2/C14 heredocs and final gate [NOT STARTED]

**Goal**: Land item 7's manifest half and take the acceptance measurement.

**Tasks**:
- [ ] Keep in-file `#print axioms` on exactly the five termini the task names:
      `strongCompletenessBase`, `strongCompletenessDense`, `notCompactDiscrete`,
      `notCompactDedekind`, `consequence_completeness_dedekind`.
- [ ] Append every remaining in-territory `#print axioms` declaration to the C2 pair
      (`AXIOM_BASELINE` at `check-module-invariants.sh:144-149` and the `AX_SRC` Lean scratch at
      `:155-161`) or the C14 pair (`C14_BASELINE` / `C14LEAN` at `:773-786`). **Both members of a
      pair are compared by exact string equality including order** — append to both in the same
      order, as C14's own comment already instructs ("Edit them together, appending to both").
- [ ] Extend the baselines to cover every declaration this task introduced:
      `semantic_deduction_in`, `soundness_consequence`, `strongCompleteness_iff_compact`,
      `compact_of_strongCompleteness`, `modelExistence_of_compact`, `compact_iff_modelExistence`,
      `not_compact_of_witness`, `not_strongCompleteness_of_witness`,
      `setConsequence_of_not_satisfiable`, `setConsequence_iff_not_satisfiable`,
      `modelExistence_of_satPreserved`, `sat_ofModel_frame`,
      `satisfiableSet_iff_finitelySatisfiable`, `modelExistence_iff_finitelySatisfiable`,
      `tmComplete_iff_forward`, `qAlpha_step`, `exists_strictMono_qPoints`,
      `modelExistenceDedekind_refuted`.
- [ ] Delete the two hand-transcribed `#print axioms` output blocks
      (`DiscreteNonCompactness.lean:300-313`, `DedekindNonCompactness.lean:472-487`) — the script's
      baseline is their proper home, and C14's stale-literal scan already covers
      `FormalSystem/**/*.lean` docstrings.
- [ ] Take the acceptance measurement: line count removed, per-class copies remaining (must be
      zero for the deduction theorem, soundness guard, model-existence proof, and refutation
      skeleton).

**Timing**: 1.5 hours

**Depends on**: 1, 2, 3, 4, 5, 6, 7, 8, 9, 10

**Verification Tier**: full

**Scope Hypothesis**: ~44 in-territory `#print axioms` directives are asserted (14 in
`StrongCompleteness`, 6 in `Compactness`, 12 in `DiscreteNonCompactness`, 12 in
`DedekindNonCompactness`), of 55 tree-wide. A raw `grep -c` at plan time returned 45 and 72
respectively, so the report's figures are net of docstring/comment occurrences. Re-measure with
`grep -rn '#print axioms' FormalSystem/` and reconcile the two numbers before deciding what to
migrate; migrate the real directives, not the grep count.

**Files to modify**:
- `scripts/check-module-invariants.sh` — four heredocs, extended in matching order
- `FormalSystem/Metalogic/StrongCompleteness.lean`, `Compactness.lean`,
  `DiscreteNonCompactness.lean`, `DedekindNonCompactness.lean` — `#print axioms` removals and the
  two transcribed output blocks

**Verification**:
- `lake build` green.
- `bash scripts/check-module-invariants.sh` ALL PASS, C2 and C14 explicitly reporting the extended
  baselines rather than a divergence.
- Every new declaration's recorded axiom profile is `[propext, Classical.choice, Quot.sound]`.

---

## Testing & Validation

- [ ] `lake build` green at the end of every phase, and at task completion.
- [ ] `bash scripts/check-module-invariants.sh` reports ALL PASS at task completion, with C2 and
      C14 extended to cover every declaration this task touches.
- [ ] Zero `sorry` introduced — `grep -rn 'sorry' FormalSystem/Metalogic/` shows no new hits
      relative to `b7da18269`.
- [ ] `strongCompleteness_iff_compact` and `compact_iff_modelExistence` exist and elaborate.
- [ ] Zero per-class copies remain of: the deduction theorem, the soundness guard, the
      model-existence proof, the refutation skeleton. Confirm by reading each per-class declaration
      and checking its body is a single application of the generic.
- [ ] Net removal of roughly 230 lines of per-class instantiation (research projects ~235, plus
      ~100 lines of now-false docstring). Report the actual `git diff --stat` figure rather than
      asserting the projection.
- [ ] Every new terminus reports axiom profile `[propext, Classical.choice, Quot.sound]`.
- [ ] No file under `FormalSystem/Semantics/` is modified (task 525 territory).

## Artifacts & Outputs

- `specs/524_consequence_compactness_generic_theorems/plans/01_generic-consequence-compactness-theorems.md` (this file)
- `specs/524_consequence_compactness_generic_theorems/summaries/01_generic-consequence-compactness-theorems-summary.md`
- Modified: `FormalSystem/Metalogic/{StrongCompleteness,SetConsequence,Compactness,DiscreteNonCompactness,DedekindNonCompactness}.lean`
- Modified: `FormalSystem/Metalogic.lean`, `FormalSystem/Metalogic/README.md`
- Modified: `scripts/check-module-invariants.sh`
- New: `FormalSystem/Metalogic/Conservativity/{Backward,BaseLanguageSoundness,TMCompletenessReduction,SpWitness,Z1Countermodel}.lean`
- Rewritten: `FormalSystem/Metalogic/Conservativity.lean` (aggregator)

## Rollback/Contingency

Every phase is a separate commit against a green `lake build` and a green
`check-module-invariants.sh`, so `git revert` of a single phase commit is the unit of rollback.
Two phases need extra care:

- **Phase 8** (`atomic-batch`) is one commit containing the file moves and the whole citation
  sweep. Reverting it restores the flat layout wholesale; do not attempt a partial revert, which
  would leave dangling imports and a cycling build.
- **Phase 7** changes a `def` that everything downstream elaborates through. If C2/C14 diverge
  after the swap and the divergence is not a transcription slip, revert Phase 7 alone and report —
  the rest of the stack (Phases 1-6, 8) stands without it, and items 1-4 and 6 satisfy most of the
  acceptance criteria on their own.

If a phase's `lake build` cannot be made green within its budget, mark the phase `[PARTIAL]`,
commit nothing, and report the failing elaboration verbatim. Do not introduce a `sorry` to make a
phase close: research elaborated every declaration in this plan to completion, so a stuck proof
means the transcription diverged from the verified source, not that the mathematics is open.
