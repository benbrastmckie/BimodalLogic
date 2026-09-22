# Implementation Plan: Task #534

- **Task**: 534 - H/G-fragment finite axiomatizability (TMFrag per frame class)
- **Status**: [IMPLEMENTING]
- **Effort**: 8.5 hours
- **Dependencies**: None (builds on the landed `Metalogic/Conservativity/` tree)
- **Research Inputs**: specs/534_hg_fragment_finite_axiomatizability/reports/01_hg-fragment-axiomatizability.md
- **Artifacts**: plans/01_hg-fragment-axiomatizability.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

The research verdict is **positive at all four classes**: each `TMFrag fc` is finitely
axiomatizable over TM⁻ in the H/G language, with candidate schema sets Σ_Base = {(Sp)/(DD)},
Σ_ZTime = {Z1}, Σ_Dense = ∅, Σ_RTime = ∅, on the strength of Burgess 1984 §2.5–2.7, Venema 2001
Thm 3.3, and a universal-modality reduction (MF + TR + S5 make `□` universal on a task model).
This plan machine-checks the part that is honestly obtainable without a base-language canonical
model: a theorems-only extension calculus `MinusExt fc Ax` (TM⁻ at `fc` plus a schema set `Ax`,
closed under MP, MN, TN, TR); **soundness** `MinusExt fc Σ_fc ⊆ TMFrag fc` at all four classes;
**strictness** `TM⁻ ⊊ TM⁻ + Σ_fc` at `.Base` and `.ZTime` from the existing countermodels; a
**conditional completeness** theorem `MinusExt fc Ax = TMFrag fc` whose single explicit hypothesis
(`ChainComplete fc Ax`, completeness of the extension over chain bundles) is exactly what the
classical results supply on paper and is never asserted in Lean; and an L⁻ deduction layer with the
four `□`-globality derivations that Lemma U of the report rests on. Definition of done: the four
new/edited modules build sorry-free inside the `Conservativity` aggregator, the four-row status
docstrings and READMEs are updated with the machine-checked / literature-backed distinction kept
explicit, `scripts/check-module-invariants.sh` passes, and the per-class verdict plus reworded
paper footnote are recorded for hand-off.

### Research Integration

- **Verdict and Σ_fc** (report §Executive Summary, §Assembly per class): adopted verbatim as the
  content of `FragmentAxiomatization.lean`'s module docstring and its `sigmaBase` / `sigmaZTime`
  definitions. Dense and RTime carry the empty set.
- **Recommendation 1** (`TMMinusExt fc Σ` with soundness through `translate`): implemented as
  Phases 1–2. The report's `translate`-induction route is replaced by the cheaper closure route:
  `TMFrag` is closed under MP/MN/TN/TR because `tr_imp`, `tr_box`, `tr_allFuture` are `rfl` and
  `tr_reflectTime` is proved (`FormalSystem/MinusLanguage/Translation.lean`), so the induction is
  over `MinusExt`, not over TM⁻ derivations.
- **Recommendation 2** (conditional completeness, "cheaper phrased semantically via `chainSat`"):
  implemented as Phase 3 through `not_minusValidIn_of_not_chainSat`
  (`Conservativity/ChainBundleTruth.lean`). The report's Lemma U / Lemma I normal-form machinery
  is *not* formalized — it lives inside the `ChainComplete` hypothesis, which is where the
  classical literature does its work.
- **Recommendation 3** (small direct TM⁻ derivations): scoped down to the four `□`-globality
  derivations of Lemma U's first bullet (Phase 4), which need only S5 + MF + MT + TR and a
  deduction theorem. The `□DN^r → □DN` and `CO(Fp) → A7a` derivations are **not** planned: the
  report proves them semantically (via Burgess's L₂ completeness), not syntactically, so a direct
  Hilbert derivation has no literature route to follow and would be open-ended.
- **Recommendation 4** (docs: four-row table, Σ record): Phase 5.
- **Recommendation 5** (paper report-back): Phase 5, recorded in the module docstring and the
  implementation summary; the PossibleWorlds repository is not under `~/Projects` and is not
  edited by this task.
- **Path correction**: the report cites `Syntax/MinusLanguage/…` and `Semantics/MinusLanguage/…`;
  the actual modules are `FormalSystem/MinusLanguage/{Axioms,Derivation,Formula,Translation,
  MinusTruth,MinusValidity,MinusSchemaValidity,Soundness}.lean`. The report's
  `Metalogic/Core/DeductionTheorem.lean` is `FormalSystem/Theorems/DeductionTheorem.lean`.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No roadmap context provided in the dispatch; no ROADMAP.md consulted.

## Goals & Non-Goals

- **Goals**: `MinusExt`, `minusExt_of_derivable`, `minusExt_le_tmFrag`, `sigmaBase`,
  `sigmaZTime`, `minusExt_sigmaBase_le_tmFrag`, `minusExt_sigmaZTime_le_tmFrag`,
  `tmMinus_lt_minusExt_sigmaBase`, `tmMinus_lt_minusExt_sigmaZTime`, `ChainValidIn`,
  `ChainComplete`, `tmFrag_chainValidIn`, `minusExt_iff_tmFrag_of_chainComplete`,
  `minusDeductionTheorem`, `boxGlobalFuture`, `boxGlobalPast`, `notBoxGlobalFuture`,
  `notBoxGlobalPast`
- **Non-Goals**:
  - Any unconditional completeness theorem for `MinusExt fc Σ_fc` at any class, and any
    `theorem` whose conclusion is `ChainComplete fc Ax` for a concrete `fc`/`Ax`. These are
    literature-backed only (Burgess 1984, Venema 2001) and stay prose.
  - Formalizing pure H/G tense logic, Kripke validity over a bare linear order, Lemma U's
    normal form, Lemma I's global deduction theorem, or Lemma Q's model theory.
  - Direct TM⁻ derivations of `□DN^r → □DN` or `CO(Fp) → A7a` (see Research Integration).
  - Editing the PossibleWorlds paper. The reworded footnote is delivered as text only.
  - A separating H/G-validity for `TM⁻ + Σ_fc ⊊ TMFrag fc`: the verdict is positive, so none
    exists; the strictness results planned are `TM⁻ ⊊ TM⁻ + Σ_fc`, over the existing witnesses.
  - Any change to `TMFrag`, `Sp`, `Z1`, `translate`, or the `MinusLanguage/` calculus.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| A `theorem` about `TMFrag`/`MinusExt` completeness is stated and `sorry`-ed, violating the standing prohibition (`Metalogic/Conservativity.lean`) | H | L | Every completeness-shaped statement is either an `Iff`/implication with `ChainComplete` as an explicit hypothesis (Phase 3) or prose. Phase 5 grep-verifies zero `sorry` and that no declaration concludes `ChainComplete _ _`. |
| `□`-globality derivations (Phase 4) need more CPL glue over L⁻ than budgeted (no propositional layer exists on the L⁻ side) | M | M | Phase 4 mirrors `Theorems/DeductionTheorem.lean` mechanically and adds only the combinators the four target derivations consume (identity, contraposition, DNE). If a derivation does not close in budget, mark Phase 4 `[BLOCKED]` with the goal state per `rules/plan-compliance.md`; Phases 1–3 and 5 do not depend on it beyond aggregator wiring. |
| `ChainValidIn`'s quantification over `TemporalOrder` and `FamIdx : Type` inside a `Prop` triggers universe issues | L | L | Copy the binder shapes of `not_minusValidIn_of_not_chainSat` verbatim (`{D : TemporalOrder} {FamIdx : Type} [Nonempty FamIdx]`); the definition is `Prop`-valued so no universe lift is needed. |
| C14 status-claim tripwires or C23 naming gates reject new docstring wording or names | M | M | Phase 5 runs `bash scripts/check-module-invariants.sh` and repairs in place; new names use lowerCamel with no `Uppercase_x` shape; docstrings say "complete by classical theorem, not machine-checked" for the literature-backed rows. |
| `Sp`/`Z1` instance sets defined as `Set.range` over pairs make membership proofs awkward | L | M | Define `sigmaBase := {χ | ∃ φ ψ, χ = Sp φ ψ}` and `sigmaZTime := {χ | ∃ φ, χ = Z1 φ}`; membership is `⟨φ, ψ, rfl⟩`. |
| Wiring the new modules into the aggregator creates an import cycle | M | L | The new modules import only `Fragment`, `SpWitness`, `ChainBundleTruth`, and `MinusLanguage.*`; none imports `Metalogic/Conservativity.lean`. `scripts/check-metalogic-cycles.sh` runs in Phase 5. |
| Report's ℤ citation is survey-grade (Venema 2001 → Segerberg 1970 / Goldblatt) | L | — | Only affects prose; the docstring cites Venema 2001 Thm 3.3 as a survey citation and names the primary sources as unverified in the corpus. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 4 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 1, 2 |
| 4 | 5 | 1, 2, 3, 4 |

Phases within the same wave can execute in parallel.

### Phase 1: `MinusExt` — the theorems-only extension calculus and its soundness engine [COMPLETED]

**Goal**: Define `MinusExt fc Ax : MinusFormula → Prop`, the closure of TM⁻ at `fc` plus an
arbitrary schema-instance set `Ax` under MP, MN, TN, TR, and prove the one engine every
soundness row instantiates: `MinusExt fc Ax ⊆ TMFrag fc` whenever `Ax ⊆ TMFrag fc`.

**Tasks**:
- [x] Create `FormalSystem/Metalogic/Conservativity/MinusExt.lean` with the copyright header,
      `import FormalSystem.Metalogic.Conservativity.Fragment`, namespace
      `FormalSystem.Metalogic.Conservativity`, and a module docstring stating: what `MinusExt`
      is, that it is theorems-only (no context, matching TM⁻'s MN/TN/TR discipline), that it
      is `Prop`-valued (unlike `MinusLanguage.DerivationTree`, because nothing pattern-matches
      it into a `Type`), and that it neither states nor approaches forward conservativity.
- [x] Declare `inductive MinusExt (fc : FrameClass) (Ax : Set MinusFormula) : MinusFormula → Prop`
      with constructors `tm` (`MinusLanguage.Derivable fc [] φ → MinusExt fc Ax φ`),
      `ax` (`φ ∈ Ax → MinusExt fc Ax φ`), `mp`, `mn` (`□`), `tn` (`G`), `tr`
      (`MinusFormula.reflectTime`).
- [x] Prove `minusExt_of_derivable` (the `tm` constructor, exported as a theorem),
      `minusExt_mono` (`Ax₁ ⊆ Ax₂ → MinusExt fc Ax₁ φ → MinusExt fc Ax₂ φ`, induction), and
      `minusExt_empty_iff` (`MinusExt fc ∅ φ ↔ MinusLanguage.Derivable fc [] φ`; the backward
      direction is `tm`, the forward direction is induction using
      `MinusLanguage.DerivationTree.modus_ponens/necessitation/temporal_necessitation/time_reflection`
      on the `Nonempty` witnesses).
- [x] Prove the four `TMFrag` closure lemmas the engine needs, each a one-liner on the TM side:
      `tmFrag_mp` (`ProofSystem.DerivationTree.modus_ponens` under `tr_imp`),
      `tmFrag_mn` (`necessitation` under `tr_box`), `tmFrag_tn` (`temporal_necessitation` under
      `tr_allFuture`), `tmFrag_reflectTime` (`time_reflection` transported along
      `MinusLanguage.tr_reflectTime`, exactly as in `translate`'s `time_reflection` case in
      `Conservativity/Backward.lean`).
- [x] Prove `minusExt_le_tmFrag (hAx : ∀ ψ ∈ Ax, TMFrag fc ψ) : MinusExt fc Ax φ → TMFrag fc φ`
      by induction on `MinusExt`: `tm` is `tmMinus_le_tmFrag`, `ax` is `hAx`, the rules are the
      four closure lemmas.
- [x] Add an acceptance `example` that `MinusExt fc ∅ φ → TMFrag fc φ` typechecks from
      `minusExt_le_tmFrag` with the vacuous hypothesis.
- [x] Scoped build: `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Conservativity.MinusExt`
      (detached, `run_in_background: true`); `lean_verify` on `minusExt_le_tmFrag`.

**Timing**: 1.5 hours

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: One new module of roughly 120–180 lines with six theorems and one
inductive; confirm at implementation time that `tr_reflectTime` transport typechecks as a `▸`
rewrite on `ProofSystem.Derivable` (it may need `Nonempty.elim` then `⟨… ▸ …⟩`, as in
`Backward.lean`'s `translate`).

**Files to modify**:
- `FormalSystem/Metalogic/Conservativity/MinusExt.lean` - new module (created)

**Verification**:
- Scoped build exits 0 with zero `sorry`, zero warnings beyond `scripts/warning-budget.txt`.
- `lean_verify FormalSystem.Metalogic.Conservativity.minusExt_le_tmFrag` reports axioms exactly
  `[propext, Classical.choice, Quot.sound]` (or a subset).
- No declaration in the file mentions `Forward`, `TMMinusComplete`, or concludes
  `MinusLanguage.Derivable fc [] _` from `TMFrag fc _`.

---

### Phase 2: `FragmentAxiomatization.lean` part A — Σ_fc, the four soundness rows, and strictness over TM⁻ [NOT STARTED]

**Goal**: Pin the candidate axiom sets and machine-check the requested soundness half,
`TM⁻ + Σ_fc ⊆ TMFrag fc`, at all four classes, together with `TM⁻ ⊊ TM⁻ + Σ_fc` at `.Base` and
`.ZTime` from the landed countermodels.

**Tasks**:
- [ ] Create `FormalSystem/Metalogic/Conservativity/FragmentAxiomatization.lean` importing
      `FormalSystem.Metalogic.Conservativity.MinusExt`,
      `FormalSystem.Metalogic.Conservativity.SpWitness`, and
      `FormalSystem.Metalogic.Conservativity.ChainBundleTruth`; namespace
      `FormalSystem.Metalogic.Conservativity`.
- [ ] Write the module docstring as the **canonical verdict record**: a four-row table
      (`.Base`: TM⁻ + (Sp), `.Dense`: TM⁻_d, `.ZTime`: TM⁻_z + Z1, `.RTime`: TM⁻_r), each row
      naming what is machine-checked here (soundness; strictness at Base/ZTime; conditional
      completeness, Phase 3) versus what is literature-backed and **not machine-checked**
      (completeness: Burgess 1984 §2.5 for ℚ, §2.6 + the report's Lemma Q for the discrete side
      of `.Base`, §2.7 for ℝ; Venema 2001 Thm 3.3 for ℤ, a survey citation whose primary sources
      Segerberg 1970 / Goldblatt are not in the corpus). Name the universal-modality reduction
      (MF + TR + S5) as the bridge and state explicitly that `ChainComplete` is never asserted.
      Cite no task numbers.
- [ ] Define `sigmaBase : Set MinusFormula := {χ | ∃ φ ψ, χ = Sp φ ψ}` and
      `sigmaZTime : Set MinusFormula := {χ | ∃ φ, χ = Z1 φ}`; note in docstrings that
      `.Dense` and `.RTime` use `∅` and need no named set.
- [ ] Prove `sigmaBase_le_tmFrag : ∀ ψ ∈ sigmaBase, TMFrag FrameClass.Base ψ` from
      `sp_translate`, and `sigmaZTime_le_tmFrag : ∀ ψ ∈ sigmaZTime, TMFrag FrameClass.ZTime ψ`
      from `z1_translate` (`tmFrag_z1_ztime`).
- [ ] Prove the four soundness rows: `minusExt_sigmaBase_le_tmFrag`,
      `minusExt_sigmaZTime_le_tmFrag` (via `minusExt_le_tmFrag` and the two membership lemmas),
      and `minusExt_empty_le_tmFrag_dense`, `minusExt_empty_le_tmFrag_rtime` (via
      `minusExt_le_tmFrag` with the vacuous hypothesis, or `minusExt_empty_iff` + `tmMinus_le_tmFrag`).
- [ ] Prove strictness over TM⁻: `tmMinus_lt_minusExt_sigmaBase :
      ∃ φ, MinusExt .Base sigmaBase φ ∧ ¬ MinusLanguage.Derivable .Base [] φ` with witness
      `Sp (.atom a) (.atom a)` for `a := Atom.mkBase "p"` (membership by `MinusExt.ax`,
      non-derivability by `not_derivable_sp a`), and `tmMinus_lt_minusExt_sigmaZTime` with
      witness `Z1 (.atom (Atom.mkBase "p"))` and `not_minus_derivable_z1`.
- [ ] Add the two dense-side sanity examples: `Sp φ ψ ∈` the fragment at `.Dense` and `.RTime`
      is already a TM⁻ theorem there (`spDerivableDense`, `spDerivableRTime` from
      `DenseObstructionTransfer.lean`), so `MinusExt .Dense ∅ (Sp φ ψ)` holds via `tm` — one
      `example` each, documenting why Σ_Dense and Σ_RTime carry no (Sp).
- [ ] Scoped build of `FormalSystem.Metalogic.Conservativity.FragmentAxiomatization` (guarded,
      detached); `lean_verify` on the two Σ soundness rows and both strictness theorems.

**Timing**: 1.5 hours

**Depends on**: 1

**Verification Tier**: local

**Scope Hypothesis**: Eight theorems/defs plus two examples in one new module; confirm at
implementation time that `DenseObstructionTransfer.lean` is reachable from the chosen imports
(if not, import it directly rather than widening to the aggregator, which would create a cycle).

**Files to modify**:
- `FormalSystem/Metalogic/Conservativity/FragmentAxiomatization.lean` - new module (created;
  Phase 3 extends it)

**Verification**:
- Scoped build exits 0, zero `sorry`.
- `lean_verify` on `minusExt_sigmaBase_le_tmFrag`, `minusExt_sigmaZTime_le_tmFrag`,
  `tmMinus_lt_minusExt_sigmaBase`, `tmMinus_lt_minusExt_sigmaZTime`: axioms within
  `[propext, Classical.choice, Quot.sound]`.
- The docstring's four-row table reads "not machine-checked" on every completeness cell.

---

### Phase 3: `FragmentAxiomatization.lean` part B — conditional completeness via chain bundles [NOT STARTED]

**Goal**: State the completeness half with its hypothesis explicit and never discharged: if
`MinusExt fc Ax` is complete for the chain-bundle semantics of `ChainBundleTruth.lean`, then
`MinusExt fc Ax` coincides with `TMFrag fc`. This is the machine-checked form of the report's
"conditional completeness theorems, taking the classical linear-order completeness as a
hypothesis", with Lemma U folded into the hypothesis.

**Tasks**:
- [ ] Define `ChainValidIn (fc : FrameClass) (φ : MinusFormula) : Prop :=
      ∀ (D : TemporalOrder) (FamIdx : Type) [Nonempty FamIdx],
        fc.Sat (multiFamTaskFrameGen D FamIdx) → ∀ v q, chainSat (D := D) v q φ`,
      copying the binder shapes of `not_minusValidIn_of_not_chainSat` verbatim; docstring: "valid
      on every disjoint union of `D`-chains whose flow frame lies in `fc`, with `□` universal".
- [ ] Prove `tmFrag_chainValidIn : TMFrag fc φ → ChainValidIn fc φ`: `tmFrag_sound` gives
      `MinusValidIn fc φ`; for each `D`, `FamIdx`, `hSat`, `v`, `q`, argue by contradiction with
      `not_minusValidIn_of_not_chainSat hSat v q φ`.
- [ ] Define `ChainComplete (fc : FrameClass) (Ax : Set MinusFormula) : Prop :=
      ∀ φ, ChainValidIn fc φ → MinusExt fc Ax φ`, with a docstring that says in so many words:
      this is the proposition the classical theorems (Burgess 1984 §2.5–2.7, Venema 2001 Thm 3.3)
      plus the universal-modality reduction establish on paper for `(fc, Σ_fc)` at each class;
      **no declaration in this tree concludes it**, and none may be added with `sorry`.
- [ ] Prove `minusExt_iff_tmFrag_of_chainComplete (hcc : ChainComplete fc Ax)
      (hAx : ∀ ψ ∈ Ax, TMFrag fc ψ) (φ) : MinusExt fc Ax φ ↔ TMFrag fc φ` — forward is
      `minusExt_le_tmFrag hAx`, backward is `hcc φ ∘ tmFrag_chainValidIn`.
- [ ] Add the four per-class corollaries with the hypothesis still explicit:
      `minusExt_sigmaBase_iff_tmFrag_of_chainComplete (h : ChainComplete .Base sigmaBase)`,
      `minusExt_sigmaZTime_iff_tmFrag_of_chainComplete (h : ChainComplete .ZTime sigmaZTime)`,
      `minusExt_empty_iff_tmFrag_dense_of_chainComplete (h : ChainComplete .Dense ∅)`,
      `minusExt_empty_iff_tmFrag_rtime_of_chainComplete (h : ChainComplete .RTime ∅)`. The dense
      two, composed with `minusExt_empty_iff`, read "TM⁻_d (resp. TM⁻_r) is complete for
      `MinusValidIn` given chain-completeness" — state that reading in the docstring, and note it
      relates to `TMMinusComplete .Dense` / `.RTime` in `TMCompletenessReduction.lean` without
      asserting either.
- [ ] Add an acceptance `example` showing the contrapositive shape a future refutation probe
      would consume: `¬ MinusExt fc Ax φ → ChainComplete fc Ax → ¬ ChainValidIn fc φ`.
- [ ] Scoped build (guarded, detached); `lean_verify` on `tmFrag_chainValidIn` and
      `minusExt_iff_tmFrag_of_chainComplete`.

**Timing**: 1.5 hours

**Depends on**: 1, 2

**Verification Tier**: local

**Scope Hypothesis**: Two defs, two theorems, four corollaries, one example appended to the
Phase 2 module (roughly 100 lines); confirm at implementation time that `fc.Sat` accepts
`multiFamTaskFrameGen D FamIdx` directly (as in `ChainBundleTruth.lean`) rather than needing
`.toTaskFrame`.

**Files to modify**:
- `FormalSystem/Metalogic/Conservativity/FragmentAxiomatization.lean` - append the conditional
  completeness section

**Verification**:
- Scoped build exits 0, zero `sorry`.
- `grep -n "ChainComplete" FormalSystem/Metalogic/Conservativity/FragmentAxiomatization.lean`
  shows `ChainComplete` only in its `def`, in hypotheses `(h… : ChainComplete …)`, and in prose —
  never as the conclusion of a `theorem`/`example`.
- `lean_verify` axioms within `[propext, Classical.choice, Quot.sound]`.

---

### Phase 4: `MinusDeduction.lean` — L⁻ deduction theorem and the `□`-globality derivations [NOT STARTED]

**Goal**: Supply the L⁻-side propositional layer the report's Lemma U needs and machine-check
its first bullet as direct TM⁻ derivations: `□χ → G□χ`, `□χ → H□χ`, `¬□χ → G¬□χ`, `¬□χ → H¬□χ`
at every `fc`. These are the facts that make `□` globally constant, hence universal, on a task
model.

**Tasks**:
- [ ] Create `FormalSystem/Metalogic/Conservativity/MinusDeduction.lean` importing
      `FormalSystem.MinusLanguage` (the aggregator; it does not import `Semantics`), namespace
      `FormalSystem.Metalogic.Conservativity`, docstring stating this is the
      `MinusLanguage.DerivationTree` mirror of `FormalSystem/Theorems/DeductionTheorem.lean`
      restricted to what the `□`-globality derivations consume, and that nothing here is
      semantic.
- [ ] Mirror, constructor-for-constructor, `deductionAxiom`, `deductionAssumptionSame`
      (identity `Γ ⊢⁻ A → A` via `prop_k`/`prop_s`), `deductionAssumptionOther`, `deductionMp`,
      and `minusDeductionTheorem : (A :: Γ) ⊢⁻[fc] B → Γ ⊢⁻[fc] A.imp B` by structural recursion
      on the L⁻ derivation. The MN/TN/TR cases are empty-context and cannot occur with a
      non-empty `A :: Γ`; discharge them exactly as `DeductionTheorem.lean` does (by the context
      equation `A :: Γ = []` being impossible).
- [ ] Add `minusDeductionConverse` (`Γ ⊢⁻ A.imp B → (A :: Γ) ⊢⁻ B`, via `weakening` + MP) and
      the three propositional combinators the target derivations need, each as a `def`
      returning a derivation: `minusImpTrans`, `minusContrapos` (`⊢⁻ (A → B) → (¬B → ¬A)`), and
      `minusDne` (`⊢⁻ ¬¬A → A`, from `peirce` + `ex_falso`, mirroring
      `Theorems/Propositional/Core.lean`'s route).
- [ ] Derive `boxImpBoxBox : ⊢⁻[fc] χ.box.imp χ.box.box` (MT contraposed gives
      `□χ → ¬□¬□χ`, i.e. `□χ → ◇□χ`, then M5) and `notBoxImpBoxNotBox : ⊢⁻[fc] χ.box.neg.imp χ.box.neg.box`
      (M5 contraposed plus `minusDne`).
- [ ] Derive `boxGlobalFuture : ⊢⁻[fc] χ.box.imp χ.box.allFuture` (`boxImpBoxBox`, then MF
      `□□χ → □G□χ`, then MT `□G□χ → G□χ`, chained by `minusImpTrans`) and
      `notBoxGlobalFuture : ⊢⁻[fc] χ.box.neg.imp χ.box.neg.allFuture` (same route from
      `notBoxImpBoxNotBox`).
- [ ] Derive `boxGlobalPast` and `notBoxGlobalPast` by `time_reflection` on the `Future`
      derivations at `χ.reflectTime`, then rewriting with `reflectTime_involution` and the
      `@[simp]` `reflectTime_*` push-through lemmas so the statement lands at `χ` (the same
      involution-instantiation trick the report describes; if the rewrite is fragile, state the
      lemma at `χ.reflectTime.reflectTime` first and transport).
- [ ] Scoped build (guarded, detached); `lean_verify` on the four `*Global*` declarations.

**Timing**: 2 hours

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: Roughly 250–350 lines mirroring the L-side deduction module plus six
short derivations; the count of propositional combinators actually required (planned: three) is
a hypothesis to confirm while deriving `notBoxImpBoxNotBox`, which is the one derivation that
needs double-negation elimination. If a derivation does not close within budget, mark this
phase `[BLOCKED]` with the reached goal state per `rules/plan-compliance.md` rather than
substituting a semantic proof.

**Files to modify**:
- `FormalSystem/Metalogic/Conservativity/MinusDeduction.lean` - new module (created)

**Verification**:
- Scoped build exits 0, zero `sorry`.
- `lean_verify` on `boxGlobalFuture`, `boxGlobalPast`, `notBoxGlobalFuture`, `notBoxGlobalPast`
  reports no axioms beyond `[propext, Classical.choice, Quot.sound]` (expected: none, since the
  derivations are constructive `Type`-valued terms).
- No `import FormalSystem.Semantics*` and no `import FormalSystem.Metalogic.*` other than none
  (the module is syntax-only).

---

### Phase 5: Wiring, status docstrings, ledgers, gates, and the paper hand-off [NOT STARTED]

**Goal**: Land the three new modules in the build graph, update every prose location that
records the fragment's axiomatization status with the machine-checked / literature-backed
distinction kept explicit, pin the flagship declarations in the axiom ledger, pass the full
gate, and record the per-class verdict and reworded footnote for the paper.

**Tasks**:
- [ ] Add `import FormalSystem.Metalogic.Conservativity.MinusExt`,
      `…FragmentAxiomatization`, `…MinusDeduction` to `FormalSystem/Metalogic/Conservativity.lean`
      (aggregator) and to `FormalSystem.lean` in sorted position (C27 mk_all ordering); extend the
      aggregator's module docstring with a short paragraph pointing at
      `FragmentAxiomatization.lean` as the canonical verdict record.
- [ ] Update `FormalSystem/Metalogic/Conservativity/Fragment.lean`'s "Why the fragment, and not a
      finite axiomatization" section: the native finite axiomatization is no longer "open research
      not attempted"; it is pinned per class in `FragmentAxiomatization.lean`, with soundness and
      conditional completeness machine-checked and unconditional completeness literature-backed.
- [ ] Update `FormalSystem/Metalogic/Conservativity/TMCompletenessReduction.lean`'s four-row
      status table: the `.Dense` and `.RTime` rows keep their **machine-checked** status
      (open; nothing in Lean asserts `TMMinusComplete` there) and gain the sentence "expected
      complete by classical theorem (Burgess 1984 §2.5 / §2.7 + universal-modality reduction);
      not machine-checked — see `FragmentAxiomatization.lean`". The `.RTime` row's "obstruction
      named" paragraph gains one sentence recording that the named obstruction is specific to the
      Doets route and does not bear on Burgess's A7 route, which `CO` subsumes on paper. Record
      Σ_Base = (Sp) and Σ_ZTime = Z1 in the table's preamble.
- [ ] Update `FormalSystem/Metalogic/Conservativity/README.md`: run
      `bash scripts/check-module-invariants.sh --emit-inventory` to regenerate the inventory
      block, then fill the `<!-- TODO: add description -->` cells for the three new modules only;
      add three Key Results bullets (`MinusExt`/`minusExt_le_tmFrag`; the Σ_fc rows and
      strictness; `minusExt_iff_tmFrag_of_chainComplete` with its hypothesis named). Update
      `FormalSystem/README.md` and root `README.md` only where they state the fragment's
      axiomatization status (grep `finite axiomatization|finitely axiomatiz|TMFrag`); leave
      other text untouched.
- [ ] Update `FormalSystem/Metalogic.lean`'s SORRY-FREE paragraph on the fragment (the sentence
      naming `tmFrag_sound`) to mention the Σ_fc soundness rows, keeping the exact
      "axioms: exactly `propext`, `Classical.choice`, `Quot.sound`" phrasing C14 scans.
- [ ] Pin in `scripts/check-module-invariants.sh`'s C14 baseline pair (both the `#print axioms`
      list and the expected-output block, in the existing order convention):
      `minusExt_le_tmFrag`, `minusExt_sigmaBase_le_tmFrag`, `minusExt_sigmaZTime_le_tmFrag`,
      `tmMinus_lt_minusExt_sigmaBase`, `tmMinus_lt_minusExt_sigmaZTime`, `tmFrag_chainValidIn`,
      `minusExt_iff_tmFrag_of_chainComplete`, `boxGlobalFuture`, `boxGlobalPast`,
      `notBoxGlobalFuture`, `notBoxGlobalPast`; add matching rows to `docs/theorem-index.md`
      with `Paper: —` and the formalization-native reason, following the existing `TMFrag` rows.
- [ ] Run the full gate: `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build`
      (detached), then `bash scripts/check-module-invariants.sh` and
      `bash scripts/check-metalogic-cycles.sh`; repair any C5/C12/C13/C14/C15/C20/C23/C27
      finding in place. Never add a baseline key to silence a new failure.
- [ ] Record the paper hand-off in `FragmentAxiomatization.lean`'s module docstring under a
      "Paper note" heading (no task numbers): the negative footnote in `possible_worlds.tex`
      (`sub:Logic`, after "TM⁻ owes its strength to since and until") is **not supportable** and
      should be reworded to: TM⁻ is incomplete at `.Base` and `.ZTime`; TM⁻ + (DD) and
      TM⁻_z + Z1 are complete for all task frames and ℤ-time respectively, and TM⁻_d, TM⁻_r are
      already complete, by classical H/G completeness results and the universal-modality
      reduction. The implementation summary repeats this wording verbatim as the report-back.

**Timing**: 2 hours

**Depends on**: 1, 2, 3, 4

**Verification Tier**: full

**Scope Hypothesis**: Eleven declarations to pin in C14 and eleven ledger rows; the exact set of
README/docstring locations that state the fragment's axiomatization status is hypothesized to be
five files (the two Conservativity docstrings, the Conservativity README, `FormalSystem/Metalogic.lean`,
and possibly the root/FormalSystem READMEs) — confirm by the grep named above before editing.

**Files to modify**:
- `FormalSystem/Metalogic/Conservativity.lean` - three imports, docstring paragraph
- `FormalSystem.lean` - three imports (sorted)
- `FormalSystem/Metalogic/Conservativity/Fragment.lean` - docstring section update
- `FormalSystem/Metalogic/Conservativity/TMCompletenessReduction.lean` - four-row table prose
- `FormalSystem/Metalogic/Conservativity/README.md` - inventory regeneration, descriptions, Key Results
- `FormalSystem/Metalogic.lean` - SORRY-FREE paragraph sentence
- `FormalSystem/README.md`, `README.md` - only if the grep finds a status sentence to update
- `scripts/check-module-invariants.sh` - C14 baseline pair entries
- `docs/theorem-index.md` - new rows
- `FormalSystem/Metalogic/Conservativity/FragmentAxiomatization.lean` - "Paper note" docstring section

**Verification**:
- Full guarded build exits 0; `check-module-invariants.sh` and `check-metalogic-cycles.sh` exit 0.
- `grep -rn "sorry" FormalSystem/Metalogic/Conservativity/{MinusExt,FragmentAxiomatization,MinusDeduction}.lean`
  returns only docstring mentions (C3 asserts zero structural `sorry` by content).
- `grep -rn "task [0-9]" FormalSystem/Metalogic/Conservativity/{MinusExt,FragmentAxiomatization,MinusDeduction}.lean README.md docs/`
  returns nothing new (C9).
- Every completeness sentence added to a docstring or README carries either "machine-checked"
  with a declaration name or "not machine-checked" with a literature citation.

## Lean Challenge Statements

```lean
import FormalSystem.Metalogic.Conservativity.Fragment
import FormalSystem.Metalogic.Conservativity.SpWitness
import FormalSystem.Metalogic.Conservativity.ChainBundleTruth

namespace FormalSystem.Metalogic.Conservativity

open FormalSystem.Syntax
open FormalSystem.ProofSystem (FrameClass)
open FormalSystem.MinusLanguage
open FormalSystem.Metalogic
open FormalSystem.Metalogic.Algebraic

/-- Plan-time placeholder for the signature only: implemented in Phase 1 as
`inductive MinusExt (fc : FrameClass) (Ax : Set MinusFormula) : MinusFormula → Prop`. -/
def MinusExt (fc : FrameClass) (Ax : Set MinusFormula) : MinusFormula → Prop := sorry

theorem minusExt_of_derivable {fc : FrameClass} {Ax : Set MinusFormula} {φ : MinusFormula}
    (h : MinusLanguage.Derivable fc [] φ) : MinusExt fc Ax φ := sorry

theorem minusExt_le_tmFrag {fc : FrameClass} {Ax : Set MinusFormula}
    (hAx : ∀ ψ ∈ Ax, TMFrag fc ψ) {φ : MinusFormula} (h : MinusExt fc Ax φ) :
    TMFrag fc φ := sorry

/-- `{χ | ∃ φ ψ, χ = Sp φ ψ}` — the (Sp)/(DD) instances. -/
def sigmaBase : Set MinusFormula := sorry

/-- `{χ | ∃ φ, χ = Z1 φ}` — the Z1 instances. -/
def sigmaZTime : Set MinusFormula := sorry

theorem minusExt_sigmaBase_le_tmFrag {φ : MinusFormula}
    (h : MinusExt FrameClass.Base sigmaBase φ) : TMFrag FrameClass.Base φ := sorry

theorem minusExt_sigmaZTime_le_tmFrag {φ : MinusFormula}
    (h : MinusExt FrameClass.ZTime sigmaZTime φ) : TMFrag FrameClass.ZTime φ := sorry

theorem tmMinus_lt_minusExt_sigmaBase :
    ∃ φ : MinusFormula, MinusExt FrameClass.Base sigmaBase φ ∧
      ¬ MinusLanguage.Derivable FrameClass.Base [] φ := sorry

theorem tmMinus_lt_minusExt_sigmaZTime :
    ∃ φ : MinusFormula, MinusExt FrameClass.ZTime sigmaZTime φ ∧
      ¬ MinusLanguage.Derivable FrameClass.ZTime [] φ := sorry

/-- Valid on every disjoint union of `D`-chains whose flow frame lies in `fc`, `□` universal. -/
def ChainValidIn (fc : FrameClass) (φ : MinusFormula) : Prop := sorry

/-- `∀ φ, ChainValidIn fc φ → MinusExt fc Ax φ`. Never concluded by any theorem in the tree. -/
def ChainComplete (fc : FrameClass) (Ax : Set MinusFormula) : Prop := sorry

theorem tmFrag_chainValidIn {fc : FrameClass} {φ : MinusFormula} (h : TMFrag fc φ) :
    ChainValidIn fc φ := sorry

theorem minusExt_iff_tmFrag_of_chainComplete {fc : FrameClass} {Ax : Set MinusFormula}
    (hcc : ChainComplete fc Ax) (hAx : ∀ ψ ∈ Ax, TMFrag fc ψ) (φ : MinusFormula) :
    MinusExt fc Ax φ ↔ TMFrag fc φ := sorry

noncomputable def minusDeductionTheorem {fc : FrameClass} (Γ : MinusLanguage.Context)
    (A B : MinusFormula) (d : MinusLanguage.DerivationTree fc (A :: Γ) B) :
    MinusLanguage.DerivationTree fc Γ (A.imp B) := sorry

def boxGlobalFuture {fc : FrameClass} (χ : MinusFormula) :
    MinusLanguage.DerivationTree fc [] (χ.box.imp χ.box.allFuture) := sorry

def boxGlobalPast {fc : FrameClass} (χ : MinusFormula) :
    MinusLanguage.DerivationTree fc [] (χ.box.imp χ.box.allPast) := sorry

def notBoxGlobalFuture {fc : FrameClass} (χ : MinusFormula) :
    MinusLanguage.DerivationTree fc [] (χ.box.neg.imp χ.box.neg.allFuture) := sorry

def notBoxGlobalPast {fc : FrameClass} (χ : MinusFormula) :
    MinusLanguage.DerivationTree fc [] (χ.box.neg.imp χ.box.neg.allPast) := sorry

end FormalSystem.Metalogic.Conservativity
```

Notes on the block: `MinusExt`, `sigmaBase`, `sigmaZTime`, `ChainValidIn`, `ChainComplete` are
pinned by *signature* only — their real bodies are an `inductive` and four ordinary definitions,
so a `--check` drift finding on their kind (def vs inductive) is expected and advisory. The
identifier `Σ` is a reserved token in Lean 4; the schema-set binder is `Ax` throughout.

## Testing & Validation

- [ ] Each new module builds scoped, sorry-free, through
      `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build <Module>` (detached).
- [ ] `lean_verify` on every Goals identifier that is a theorem/def: axioms within
      `[propext, Classical.choice, Quot.sound]`.
- [ ] Full guarded build, `scripts/check-module-invariants.sh` (C1–C28 incl. C14 pins, C9 task
      refs, C27 import ordering, INV inventory), `scripts/check-metalogic-cycles.sh` all exit 0.
- [ ] Prohibition audit: no `theorem` concludes `ChainComplete _ _`, `TMMinusComplete _`,
      `Forward _`, or `TMFrag fc φ → MinusLanguage.Derivable fc [] φ`.
- [ ] Docstring audit: every completeness claim added is tagged machine-checked (with a
      declaration) or not machine-checked (with a citation).
- [ ] `bash .claude/scripts/lean-challenge-snapshot.sh --check` (advisory): drift only on the
      five signature-only placeholders named above.

## Artifacts & Outputs

- `FormalSystem/Metalogic/Conservativity/MinusExt.lean` (new)
- `FormalSystem/Metalogic/Conservativity/FragmentAxiomatization.lean` (new; canonical verdict
  record and paper note in its docstring)
- `FormalSystem/Metalogic/Conservativity/MinusDeduction.lean` (new)
- Edited: `FormalSystem/Metalogic/Conservativity.lean`, `FormalSystem.lean`,
  `FormalSystem/Metalogic/Conservativity/{Fragment,TMCompletenessReduction}.lean`,
  `FormalSystem/Metalogic/Conservativity/README.md`, `FormalSystem/Metalogic.lean`,
  `scripts/check-module-invariants.sh`, `docs/theorem-index.md`, and (conditionally)
  `FormalSystem/README.md`, `README.md`
- `specs/534_hg_fragment_finite_axiomatizability/summaries/01_hg-fragment-axiomatizability-summary.md`
  carrying the per-class verdict table and the reworded footnote text for the paper

## Rollback/Contingency

- Phases 1–4 create new modules not yet imported by anything; a failed phase is reverted by
  deleting the file(s) it created and nothing else, with no aggregator or ledger impact.
- Phase 5 is the only phase that touches shared files. If the full gate cannot be made green,
  revert only Phase 5's edits (aggregator imports, docstrings, README, C14 pins, ledger rows),
  leaving the three green modules in place and unwired; record the module names in
  `scripts/module-invariants-manifest.txt` only if C6 demands it, with the reason.
- A genuine whole-tree rollback of uncommitted work follows
  `context/contracts/recovery.md`'s rollback rung (snapshot first, with its out-of-scope
  override where the tree carries edits outside this task's `file_scope`), never a bare
  precautionary `git-snapshot.sh` call; a durable non-reverting checkpoint before Phase 5's
  multi-file edits uses `--no-revert`.
- Commit each green sub-step as it lands (`task 534 phase P.O: …`), so any rollback is to the
  last green commit, not to the start of the task.
