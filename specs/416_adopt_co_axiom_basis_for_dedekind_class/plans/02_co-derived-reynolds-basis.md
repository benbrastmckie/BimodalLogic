# Implementation Plan: CO as a Derived Theorem over the Retained Reynolds Basis

- **Task**: 416 - adopt_co_axiom_basis_for_dedekind_class
- **Status**: [IMPLEMENTING]
- **Effort**: 10 hours
- **Dependencies**: None (runs in parallel with tasks 408 and 165; no shared edit targets — see Risks)
- **Research Inputs**: `specs/416_adopt_co_axiom_basis_for_dedekind_class/reports/01_co-axiom-basis-adoption.md`
- **Artifacts**: plans/02_co-derived-reynolds-basis.md (this file)
- **Standards**: plan-format.md; status-markers.md; artifact-management.md; tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

The task's original framing (swap the Dedekind-class axiom basis to the paper's CO axiom and
re-derive the Reynolds gap principles as internal theorems) was **inverted** after research and
user-ratified. Research produced a concrete independence-model sketch (a ℚ-flow with isolated
`¬p` points accumulating at an irrational from above — the classical Stavi US-vs-FO phenomenon)
under which every CO instance holds while `prior_U_gap` is refuted, so CO very likely does NOT
Hilbert-derive the Reynolds triple; the converse derivation sketch (Reynolds ⊢ CO) does work.

This plan therefore **keeps `Axiom.prior_U_gap` / `Axiom.prior_S_gap` / `Axiom.sep` as the
official Dedekind-class basis** — no constructor is added, removed, or renamed — and adds CO as
a *derived* object: a named formula abbreviation `Formula.co`, a semantic validity lemma
`co_valid : ValidDedekindDense (Formula.co φ)`, and a proof-theoretic derivation
`co_derived : DerivationTree fc [] (Formula.co φ)` for `.Dedekind ≤ fc`. It also lands the
cheap Hölder classification lemmas that Mathlib does not provide, and aligns the
`FrameClass` / `Validity` docstrings with the paper's TM_c vs TM⁺_dc distinction.

Because the direction is inverted, the downstream rebase surface is **empty**: the six real
`DerivationTree.axiom` consumption sites (three Chronicle limit-witness files, three in
`ChronicleMonadicBridge` feeding the Doets embedding) are untouched, as are all mechanical
constructor case arms and the tableau rule set.

**Definition of done**: `lake build` is green, no new `sorry`, `Formula.co` / `co_valid` /
`co_derived` exist and are referenced from the aligned docstrings, the three cheap Hölder
lemmas are proved, and the paper-side amendment is recorded as an out-of-scope follow-up.

### Research Integration

Findings consumed from `reports/01_co-axiom-basis-adoption.md`:

- **Finding 1/2** — CO verbatim and its operator resolution: `△(Hφ → F(Hφ)) → (Hφ → Gφ)` with
  `△φ := Hφ ∧ φ ∧ Gφ` (the **temporal** triangle, not `□`). Source:
  `/home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex:3250`. All four
  operators already exist in `FormalSystem/Syntax/Formula.lean` (`allPast` 161, `allFuture` 151,
  `someFuture` 131, `always` 460). Drives Phase 1.
- **Finding 3(c)** — the Reynolds ⊢ CO derivation sketch (via Prior-U at χ, plus the
  △-antecedent's G-component to kill both consequent disjuncts). Drives Phases 3-4.
- **Finding 4 option 1** — the inverted resolution adopted here; rebase surface empty.
- **Finding 6/7/8** — verified-present Mathlib API
  (`LinearOrderedAddCommGroup.discrete_or_denselyOrdered`,
  `discrete_iff_not_denselyOrdered`, `Archimedean.exists_orderAddMonoidHom_real_injective`),
  verified-absent "complete ordered group ⇒ Archimedean" (cheap hand lemma) and packaged
  "dense+complete ≃+o ℝ" (not cheap → docs). Drives Phases 5-6.
- **Finding 9** — the required FrameClass/Validity doc corrections. Drives Phase 6.
- **Finding 10** — `co_valid` proof shape mirrors `prior_U_gap_valid`
  (`FormalSystem/Metalogic/Soundness.lean:1482`), a direct `IsLUB` argument. Drives Phase 2.
  `co_swap_valid` is explicitly NOT needed here: it is only required when `co` is a
  *constructor* (for the `temporal_duality` soundness case), which this plan does not do.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

`specs/ROADMAP.md` was supplied as read-only context; no roadmap items are marked or amended by
this plan (`roadmap_flag` is false). This work advances the paper-alignment (fix.md C4) strand
by settling the CO/Reynolds basis relationship on the repo side.

## Goals & Non-Goals

**Goals**:

- Add `Formula.co` as a named abbreviation for the paper's CO formula, faithful to the JPL
  source, with a docstring citing it.
- Prove `co_valid : ValidDedekindDense (Formula.co φ)` semantically, as an independent check.
- Prove `co_derived : DerivationTree fc [] (Formula.co φ)` for `.Dedekind ≤ fc` from the
  retained Reynolds basis, establishing the paper's CO as a *theorem* of this repo's Dedekind
  class.
- Land the cheap Hölder classification lemmas Mathlib lacks: complete ⇒ Archimedean, the
  discrete-or-dense dichotomy for complete duration groups, and complete+discrete ≅ ℤ.
- Align the `FrameClass` and `Validity` docstrings with the paper's TM_c / TM⁺_dc distinction
  and with the CO/Reynolds relationship established here.

**Non-Goals**:

- **The paper-side amendment is OUT OF SCOPE for this repo.** The paper's `def:TMplus-c`
  defines BX_c as base + CO and `cor:tm-completeness` defers its completeness to this
  repository with no independent citation; under Finding 3(b) that definition is deductively
  too weak. The correction — switching the paper's BX_c basis to the Reynolds axioms, per
  fix.md C4 option 2 — lives in `/home/benjamin/Philosophy/Papers/PossibleWorlds/` and must be
  routed through the fix.md C4 process as separate work. This plan records the finding in repo
  docstrings; it does not edit any file under `Philosophy/Papers/`.
- No basis swap: `Axiom.prior_U_gap` / `prior_S_gap` / `sep` are not removed, renamed, or
  demoted, and no `Axiom.co` constructor is added.
- No two-basis bridge, no `FrameClass` reshaping, no new frame class.
- No rebase of the six `DerivationTree.axiom` consumption sites, no touch to the mechanical
  constructor case arms in `Soundness.lean` / `FrameClassVariants.lean` / `DenseValidity.lean` /
  `FormulaEnumerator.lean` / `MachineAppendixExport.lean`, and no tableau rule changes.
- No `co_swap_valid` (only needed under a constructor adoption; see Finding 10).
- No packaged "nontrivial dense Dedekind-complete ordered abelian group ≃+o ℝ" theorem.
  Research verified this is a ~100-200 line order-topology development with no Mathlib
  equivalent; per the task's "lemmas where cheap, else docs" instruction it is recorded as
  documentation (Phase 6) citing the composition path, not proved.
- No attempt to prove or refute CO ⊢ Reynolds (the independence sketch is left as a
  pen-and-paper result recorded in docs; no EF/composition formalization).

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| The Hilbert derivation `co_derived` resists formalization within budget (Finding 3(c) is a sketch, not a checked proof; the point-shifting steps are the hard part) | H | M | Phases 3/4 split scaffolding from the main derivation so the reusable helpers land green regardless. Phase 4 carries a hard budget: on exhaustion, mark Phase 4 `[BLOCKED]` with the exact stuck goal recorded, keep Phases 1/2/3/5/6 green, and **do not introduce `sorry` or an axiom** (zero-debt policy). Phase 6 doc text is written conditionally on Phase 4's outcome. |
| `Formula.co` name collides with an existing declaration in the `Formula` namespace | L | L | Phase 1 opens with `grep`/`lean_local_search` for `Formula.co`; on collision use `Formula.dedekindCO` and thread the name through Phases 2/4/6. |
| `Syntax/Formula.lean` and `ProofSystem/Axioms.lean` are core, widely-imported files; concurrent tasks 408 and 165 are `[IMPLEMENTING]` in the same tree | M | M | Both edits here are strictly additive (Phase 1: one new `def`) or docstring-only (Phase 6). Neither task declares a `file_scope`, but 408's territory is `WeakCanonical/RealModel/*`, `StrongCompleteness.lean`, `CompletenessDedekind.lean` and 165's is the tableau/decidability tree — **no overlap with any file this plan writes**. Expect rebuild churn, not edit collisions. If Phase 6's `Axioms.lean` docstring edit finds concurrent modifications in that file, stop and coordinate rather than resolving blind. |
| `co_valid`'s `IsLUB` argument needs the △-antecedent at the supremum point `s`, requiring a `s = t` vs `t < s` case split | M | M | The `△` conjuncts supply exactly this: the middle conjunct covers `s = t` and the `G` conjunct covers `t < s`. Mirror the `prior_U_gap_valid` skeleton (`Soundness.lean:1482`), which already sets up `A`, `BddAbove`, `h_lub`, and the `hs.exists_between` guard step. |
| `archimedean_of_lub` hand proof is subtler than the ~20-line estimate (needs `Nontrivial`/positivity handling) | L | M | Report supplies the argument (if ¬Archimedean, `{n • a}` is bounded above; its LUB `s` gives `s - a < s`, so some `n` with `s - a < n • a`, hence `s < (n+1) • a ≤ s`). If it overruns, it is still self-contained in a new file and blocks only Phase 5's other two lemmas, which are one-liners given it. |
| New files not registered in the aggregators, so `lake build` silently ignores them | M | L | Each file-creating phase registers the module in its aggregator (`FormalSystem/Semantics.lean`, `FormalSystem/Theorems.lean`, `FormalSystem/Metalogic/SoundnessLemmas.lean`) as part of the same phase, and verifies via a full `lake build`. |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 3, 5 | -- |
| 2 | 2, 4 | 1 (for 2); 1, 3 (for 4) |
| 3 | 6 | 2, 4, 5 |

Phases within the same wave can execute in parallel. Phases 3 and 4 both write
`FormalSystem/Theorems/DedekindDerived.lean` but sit in different waves, so they never run
concurrently.

---

### Phase 1: Add `Formula.co` abbreviation [COMPLETED]

- **Goal:** A named, source-cited abbreviation for the paper's CO formula exists in the syntax
  layer, usable from both `Metalogic` (Phase 2) and `Theorems` (Phase 4).
- **Tasks:**
  - [x] `grep`/`lean_local_search` for an existing `Formula.co` to rule out a name collision;
        fall back to `Formula.dedekindCO` if one exists.
  - [ ] Add to `FormalSystem/Syntax/Formula.lean`, immediately after `Formula.always` (line
        ~460), the definition
        `def Formula.co (φ : Formula) : Formula := (Formula.always (φ.allPast.imp φ.allPast.someFuture)).imp (φ.allPast.imp φ.allFuture)`.
  - [ ] Docstring: state `△(Hφ → F(Hφ)) → (Hφ → Gφ)`; cite
        `/home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex:3250`
        (`def:TMplus-c`); state explicitly that `△` here is the **temporal** triangle
        `Formula.always` (`Hφ ∧ φ ∧ Gφ`), NOT `Formula.box`; and note that this is an
        abbreviation, not an `Axiom` constructor — CO is a derived theorem of the retained
        Reynolds basis (forward-reference `co_derived`).
  - [ ] Confirm the definition elaborates and its unfolding matches the intended formula (e.g.
        `#reduce`/`lean_hover_info` sanity check on `Formula.co (Formula.atomS "p")`).
- **Timing:** 0.5 hours
- **Depends on:** none
- **Verification Tier:** interface
- **Scope Hypothesis:** Hypothesis — this phase touches exactly one file
  (`FormalSystem/Syntax/Formula.lean`) and adds exactly one declaration, with no aggregator
  edit needed because `Formula.lean` is already imported by `FormalSystem/Syntax.lean`. Confirm
  at implementation time by checking `FormalSystem/Syntax.lean` for the existing
  `import FormalSystem.Syntax.Formula` line and by `git diff --stat` showing one file changed.
- **Files to modify:**
  - `FormalSystem/Syntax/Formula.lean` — add `Formula.co` + docstring.
- **Verification:**
  - Build `FormalSystem.Syntax.Formula` plus its enumerated direct dependents
    (`FormalSystem/Syntax.lean`, `FormalSystem/ProofSystem/Axioms.lean`,
    `FormalSystem/Semantics/Truth.lean`) green.
  - No new diagnostics in `Formula.lean`.

---

### Phase 2: Prove `co_valid` [NOT STARTED]

- **Goal:** CO is proved semantically valid on dense Dedekind-complete flows, independently of
  the proof-theoretic route, as a check on Phase 4 and on the formalization of Phase 1.
- **Tasks:**
  - [ ] Create `FormalSystem/Metalogic/SoundnessLemmas/CoValidity.lean` (module header +
        copyright block matching the sibling files in that directory).
  - [ ] State `theorem co_valid (φ : Formula) : ValidDedekindDense (Formula.co φ)`.
  - [ ] Prove it by the `IsLUB` argument, mirroring the `prior_U_gap_valid` skeleton at
        `FormalSystem/Metalogic/Soundness.lean:1482`: assume `△(Hφ → F Hφ)` and `Hφ` at `t`, and
        for contradiction `¬Gφ` witnessed by `v > t` with `¬φ` at `v`; set
        `A := {u | t ≤ u ∧ Hφ at u}`; `A` is nonempty (`t ∈ A`) and bounded above by `v`;
        let `s` be its LUB; show `Hφ` at `s` via the `exists_between` guard step; apply the
        △-antecedent at `s` (middle conjunct when `s = t`, `G` conjunct when `t < s`) to get
        `s' > s` with `Hφ` at `s'`, so `s' ∈ A` and `s' ≤ s` — contradiction.
  - [ ] Document in the theorem docstring which hypotheses the proof actually consumes (LUB +
        linear order only, matching the note at `Soundness.lean:1476-1481`), and that the
        `DenselyOrdered` binder is carried for chain consistency rather than mathematical need.
  - [ ] Register the module in `FormalSystem/Metalogic/SoundnessLemmas.lean`.
  - [ ] Add a one-line pointer from `FormalSystem/Metalogic/SoundnessLemmas/README.md` (file
        inventory) if that README enumerates modules.
- **Timing:** 2 hours
- **Depends on:** 1
- **Verification Tier:** local
- **Scope Hypothesis:** Hypothesis — `co_valid` is provable from the `ValidDedekindDense` binder
  set with no additional hypotheses and no new imports beyond what `SoundnessLemmas/*.lean`
  siblings already carry. Confirm at implementation time by closing the proof with no
  `sorry` and no added axiom; if an extra hypothesis proves necessary, record it in the
  docstring and flag it rather than weakening the statement.
- **Files to modify:**
  - `FormalSystem/Metalogic/SoundnessLemmas/CoValidity.lean` (new) — `co_valid`.
  - `FormalSystem/Metalogic/SoundnessLemmas.lean` — register the module.
  - `FormalSystem/Metalogic/SoundnessLemmas/README.md` — inventory line (if applicable).
- **Verification:**
  - `lake build FormalSystem.Metalogic.SoundnessLemmas.CoValidity` green.
  - `lean_verify FormalSystem.Metalogic.SoundnessLemmas.co_valid` (fully qualified) reports no
    `sorryAx` and no new axioms.

---

### Phase 3: Derivation scaffolding for the CO derivation [NOT STARTED]

- **Goal:** The reusable Hilbert-side helper derivations the CO proof needs exist and are green,
  independently of whether the full CO derivation lands.
- **Tasks:**
  - [ ] Create `FormalSystem/Theorems/DedekindDerived.lean` with the standard header, importing
        `FormalSystem.ProofSystem.Derivation`, `FormalSystem.Theorems.TemporalDerived`,
        `FormalSystem.Theorems.ContextualProofs`, and
        `FormalSystem.Theorems.Propositional.Connectives`.
  - [ ] Prove the `△`-elimination helpers at an arbitrary frame class `fc`:
        `alwaysElimPast : ⊢[fc] (Formula.always χ).imp χ.allPast`,
        `alwaysElimHere : ⊢[fc] (Formula.always χ).imp χ`,
        `alwaysElimFuture : ⊢[fc] (Formula.always χ).imp χ.allFuture`
        (pure conjunction elimination over `Formula.always χ = Hχ ∧ (χ ∧ Gχ)`,
        `Formula.lean:460`).
  - [ ] Prove the point-shifting helper(s) the Finding 3(c) sketch needs — at minimum
        "`Hχ` at `t` plus `χ` throughout `(t,s)` gives `Hχ` at `s`" in its U/S-internal form,
        expressed with `Formula.untl` and the existing guard-monotonicity lemmas
        (`untilMonoGuard`, `untilMonoEvent`, `TemporalDerived.lean:457-484`) plus
        `Metalogic.Core.deductionTheorem` for the context-discharge steps.
  - [ ] Register the module in `FormalSystem/Theorems.lean` and add it to the theorem inventory
        in `FormalSystem/Theorems/README.md`.
- **Timing:** 2 hours
- **Depends on:** none
- **Verification Tier:** local
- **Scope Hypothesis:** Hypothesis — the sketch needs the three `△`-eliminators plus one
  `Hχ`-propagation helper, and all of them are reachable from existing `TemporalDerived` /
  `ContextualProofs` lemmas plus `deductionTheorem` without new axiom instances. Confirm at
  implementation time by closing each helper sorry-free; if the propagation helper turns out to
  need an axiom instance not admissible at `.Base`, restate it at `.Dedekind` and record why.
- **Files to modify:**
  - `FormalSystem/Theorems/DedekindDerived.lean` (new) — helper derivations.
  - `FormalSystem/Theorems.lean` — register the module.
  - `FormalSystem/Theorems/README.md` — inventory entry.
- **Verification:**
  - `lake build FormalSystem.Theorems.DedekindDerived` green.
  - Every helper is sorry-free (`lean_verify` on each fully qualified name).

---

### Phase 4: Prove `co_derived` from the Reynolds basis [NOT STARTED]

- **Goal:** The paper's CO axiom is a *theorem* of this repo's Dedekind class:
  `co_derived (φ) : DerivationTree fc [] (Formula.co φ)` for `.Dedekind ≤ fc`, derived from
  `Axiom.prior_U_gap` and the base/dense axioms. This is the phase that makes the inversion
  substantive rather than merely documentary.
- **Tasks:**
  - [ ] State `theorem co_derived {fc : FrameClass} (h_fc : FrameClass.Dedekind ≤ fc)
        (φ : Formula) : DerivationTree fc [] (Formula.co φ)` in
        `FormalSystem/Theorems/DedekindDerived.lean`.
  - [ ] Formalize the Finding 3(c) derivation, working in context and discharging with
        `Metalogic.Core.deductionTheorem`: from `△(Hφ → F Hφ)` and `Hφ`, assume `F¬φ` for
        contradiction; use the △-antecedent at the point to get `s > t` with `Hφ` at `s`, hence
        `U(⊤,φ)`; feed `U(⊤,φ) ∧ F¬φ` into `Axiom.prior_U_gap` at `φ` (via
        `DerivationTree.axiom` with `h_fc`) to obtain `U(¬φ ∨ K⁺¬φ, φ)`; then use the
        △-antecedent's `G`-component together with the Phase 3 propagation helper to refute both
        disjuncts at the witness point; conclude `Gφ`.
  - [ ] Docstring: quote the paper formula and its JPL source line, state that CO is derived
        (not primitive), and state the direction result explicitly — the Reynolds basis derives
        CO, while the converse is *not* claimed and is believed false (cite the independence
        sketch by its content, not by task number).
  - [ ] Record the derivation's axiom footprint: which `Axiom` constructors and which inference
        rules it consumes.
- **Timing:** 2 hours (hard budget; see contingency below)
- **Depends on:** 1, 3
- **Verification Tier:** local
- **Commit Mode:** per-substep
- **Scope Hypothesis:** Hypothesis — `co_derived` consumes `Axiom.prior_U_gap` only (plus base
  and dense axioms and the standard rules), not `prior_S_gap` and not `sep`. Confirm at
  implementation time by reading the finished derivation's constructor uses and by
  `lean_verify` on the completed theorem; if `prior_S_gap` or `sep` turns out to be needed,
  update the docstring's footprint claim and the Phase 6 doc text accordingly rather than
  leaving the hypothesis asserted.
- **Contingency (explicit):** if the derivation is not closed within the 2-hour budget, mark
  this phase `[BLOCKED]`, record the exact remaining goal state and the last successful step in
  the phase notes, and stop. **Do not** introduce `sorry`, do not add an `Axiom.co` constructor,
  and do not weaken the statement to an assumed hypothesis. Phases 1, 2, 3, 5 and a
  Phase-4-aware variant of Phase 6 all remain deliverable in that case.
- **Files to modify:**
  - `FormalSystem/Theorems/DedekindDerived.lean` — `co_derived`.
- **Verification:**
  - `lake build FormalSystem.Theorems.DedekindDerived` green.
  - `lean_verify` on the fully qualified `co_derived` shows no `sorryAx`.
  - Cross-check against Phase 2: soundness applied to `co_derived` must yield exactly the
    statement `co_valid` proves independently (agreement of the two routes is the intended
    consistency check; a mismatch means the Phase 1 formalization is wrong).

---

### Phase 5: Cheap Hölder classification lemmas [NOT STARTED]

- **Goal:** The Hölder facts that are cheap in the pinned Mathlib are proved as lemmas against
  the repo's own LUB-hypothesis form, so the docstrings of Phase 6 can cite repo theorems rather
  than prose.
- **Tasks:**
  - [ ] Create `FormalSystem/Semantics/DurationClassification.lean`, importing
        `Mathlib.GroupTheory.ArchimedeanDensely` and the repo's `Semantics.TaskFrame` for the
        duration binder conventions (`TaskFrame.lean:99`).
  - [ ] Prove `archimedean_of_lub {D} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
        (h_lub : ∀ s : Set D, s.Nonempty → BddAbove s → ∃ x, IsLUB s x) : Archimedean D`.
        Argument: if `¬Archimedean`, `{n • a}` is bounded above for some `0 < a`; its LUB `s`
        satisfies `s - a < s`, so some `n` has `s - a < n • a`, giving `s < (n+1) • a ≤ s`.
        Mathlib provides no group-level version — only the field version
        `ConditionallyCompleteLinearOrderedField.to_archimedean` — so this is a genuine new
        lemma, not a re-export.
  - [ ] Prove `complete_duration_discrete_or_dense` (same binders + `h_lub`):
        `Nonempty (D ≃+o ℤ) ∨ DenselyOrdered D`, by supplying `archimedean_of_lub` to
        `LinearOrderedAddCommGroup.discrete_or_denselyOrdered` (verified present in the pinned
        Mathlib at `Mathlib/GroupTheory/ArchimedeanDensely.lean`, with a typeclass set matching
        the repo's duration binders exactly).
  - [ ] Prove `complete_not_dense_iso_int` (same binders + `h_lub` + `¬DenselyOrdered D`):
        `Nonempty (D ≃+o ℤ)`, via `LinearOrderedAddCommGroup.discrete_iff_not_denselyOrdered`.
  - [ ] Module docstring: state the classification, cite the Mathlib names used, and name the
        one absence deliberately not proved here (packaged "nontrivial dense complete ordered
        abelian group ≃+o ℝ") with its composition path — complete ⇒ Archimedean (this file) →
        `Archimedean.exists_orderAddMonoidHom_real_injective`
        (`Mathlib/Data/Real/Embedding.lean:232`) → image dense via
        `AddSubgroup.dense_or_cyclic` → surjectivity from completeness — and why it is out of
        scope (~100-200 lines of order-topology plumbing; see Non-Goals).
  - [ ] Register the module in `FormalSystem/Semantics.lean`.
- **Timing:** 2 hours
- **Depends on:** none
- **Verification Tier:** local
- **Scope Hypothesis:** Hypothesis — exactly three lemmas, in one new file, with
  `archimedean_of_lub` the only one requiring real proof work (the other two are one-liners
  given it and the two verified Mathlib names). Confirm at implementation time by the finished
  file's declaration count and by checking that the two Mathlib lemmas apply without an adapter
  (research verified an exact typeclass match; if an adapter proves necessary, record it in the
  module docstring).
- **Files to modify:**
  - `FormalSystem/Semantics/DurationClassification.lean` (new) — three lemmas + module docs.
  - `FormalSystem/Semantics.lean` — register the module.
- **Verification:**
  - `lake build FormalSystem.Semantics.DurationClassification` green.
  - All three lemmas sorry-free under `lean_verify`.
  - The two cited Mathlib names resolve in the pinned Mathlib (hover/`lean_local_search`
    confirmation, not a search-index absence).

---

### Phase 6: FrameClass / Validity documentation alignment [NOT STARTED]

- **Goal:** The repo's docstrings state the sharp Hölder picture and the paper's TM_c / TM⁺_dc
  distinction correctly, and stop implying that the CO basis and the Reynolds basis are
  interchangeable.
- **Tasks:**
  - [ ] `FormalSystem/ProofSystem/Axioms.lean` (`FrameClass` docstring, ~404-447): replace
        "valid on dense Dedekind-complete frames (paradigmatically ℝ)" with the Hölder-sharp
        statement — by `complete_duration_discrete_or_dense` (Phase 5) a nontrivial dense
        Dedekind-complete duration group is order-and-group isomorphic to ℝ, so
        `FrameClass.Dedekind` is the paper's **TM⁺_dc** (real flow), not TM⁺_c.
  - [ ] Same file: state that the paper's **TM⁺_c** (complete simpliciter; class `{ℤ, ℝ}` up to
        iso; theory `Th(ℤ) ∩ Th(ℝ)`) has **no repo frame class** — the complete-but-discrete
        case is exactly ℤ (cite `complete_not_dense_iso_int`) and is covered by
        `FrameClass.Discrete` / `ValidDiscrete`, while `ValidDedekind` exists as a predicate but
        is not a soundness target (its own docstring already explains why).
  - [ ] Same file, the Layer 9 Reynolds axiom block (~356-401): record the basis relationship —
        the Reynolds triple is the official basis, the paper's CO is derivable from it
        (reference `co_derived`, or, if Phase 4 is `[BLOCKED]`, reference `co_valid` and state
        the derivation as sketched-but-not-yet-formalized), and the converse (CO ⊢ the gap
        axioms) is **not** claimed: an independence model over a ℚ-flow with `¬φ` points
        accumulating at a gap validates every CO instance while refuting Prior-U, the classical
        Stavi US-vs-FO phenomenon. Note this is a pen-and-paper result, not machine-checked.
  - [ ] `FormalSystem/Semantics/Validity.lean` (`ValidDedekindDense` docstring, ~240-254):
        replace "ℝ is the paradigm model" with "up to order-and-group isomorphism ℝ is the
        *only* nontrivial model", citing the Phase 5 lemmas; note that the density binder is
        exactly what excludes the ℤ branch of the dichotomy.
  - [ ] Same file (`ValidDedekind` docstring): cross-reference the classification so the "ℤ
        satisfies every binder" observation is tied to the discrete branch of Hölder rather than
        left as an isolated remark.
  - [ ] Record, in the `FrameClass`/Layer-9 prose, that the paper's `def:TMplus-c` and its
        deferred completeness claim are implicated and require a paper-side amendment routed
        through the fix.md C4 process — as an explicitly out-of-scope note, with **no** edit to
        any file under `/home/benjamin/Philosophy/Papers/`.
  - [ ] Correct the paper footnote's claim where it is repeated anywhere in repo prose: no
        non-Archimedean order is complete, so the "complete extension is substantive for
        non-Archimedean orders" reading is false.
- **Timing:** 1.5 hours
- **Depends on:** 2, 4, 5
- **Verification Tier:** prose
- **Scope Hypothesis:** Hypothesis — this phase is docstring-only across exactly two files
  (`Axioms.lean`, `Validity.lean`) and changes no code. Confirm at implementation time by
  reading the diff and checking every changed hunk lies inside a `/-- ... -/` or `/-! ... -/`
  block; if any repo prose outside these two files repeats the "paradigmatically ℝ" or
  non-Archimedean claim, add those files to the phase and re-state the scope rather than
  leaving them stale.
- **Files to modify:**
  - `FormalSystem/ProofSystem/Axioms.lean` — `FrameClass` docstring, Layer 9 axiom block prose.
  - `FormalSystem/Semantics/Validity.lean` — `ValidDedekind` / `ValidDedekindDense` docstrings.
- **Verification:**
  - Diff read-through confirms every changed hunk is inside a doc comment.
  - Full `lake build` green (docstring edits still trigger elaboration of these core modules).
  - Every repo symbol named in the new prose (`co_derived`, `co_valid`,
    `complete_duration_discrete_or_dense`, `complete_not_dense_iso_int`) actually exists at the
    time the prose is written; no forward reference to a `[BLOCKED]` Phase 4 result is stated as
    a completed fact.

---

## Testing & Validation

- [ ] `lake build` green over the whole library with no new warnings in the touched modules.
- [ ] No new `sorry` anywhere: `grep -rn "sorry" FormalSystem/Theorems/DedekindDerived.lean
      FormalSystem/Metalogic/SoundnessLemmas/CoValidity.lean
      FormalSystem/Semantics/DurationClassification.lean` returns nothing.
- [ ] `lean_verify` on each new theorem (`co_valid`, `co_derived`, `archimedean_of_lub`,
      `complete_duration_discrete_or_dense`, `complete_not_dense_iso_int`) reports no `sorryAx`
      and introduces no new axioms.
- [ ] Basis-invariance check: `git diff` shows **no** change to the `Axiom` inductive's
      constructor list, and no change to any of the six `DerivationTree.axiom` consumption sites
      (three Chronicle limit-witness files, three in `ChronicleMonadicBridge`).
- [ ] Tableau untouched: `git diff --stat` shows no change under
      `FormalSystem/Metalogic/Decidability/`.
- [ ] Two-route agreement: the statement `soundness_dedekind` applied to `co_derived` yields
      matches `co_valid`'s statement modulo unfolding `Formula.co` (Phase 4 verification).
- [ ] Existing test suite (`lake test` / `BimodalTest`) green.
- [ ] No file under `/home/benjamin/Philosophy/Papers/` modified.

## Artifacts & Outputs

- `specs/416_adopt_co_axiom_basis_for_dedekind_class/plans/02_co-derived-reynolds-basis.md`
  (this file)
- `specs/416_adopt_co_axiom_basis_for_dedekind_class/summaries/02_{short-slug}-summary.md`
  (written at implementation completion; not pre-created)
- `FormalSystem/Syntax/Formula.lean` — `Formula.co` (modified)
- `FormalSystem/Metalogic/SoundnessLemmas/CoValidity.lean` — `co_valid` (new)
- `FormalSystem/Metalogic/SoundnessLemmas.lean` — module registration (modified)
- `FormalSystem/Theorems/DedekindDerived.lean` — `△`-eliminators, propagation helper,
  `co_derived` (new)
- `FormalSystem/Theorems.lean`, `FormalSystem/Theorems/README.md` — registration + inventory
  (modified)
- `FormalSystem/Semantics/DurationClassification.lean` — three Hölder lemmas (new)
- `FormalSystem/Semantics.lean` — module registration (modified)
- `FormalSystem/ProofSystem/Axioms.lean`, `FormalSystem/Semantics/Validity.lean` — docstring
  alignment (modified)

**Follow-up recorded, not delivered here**: the paper-side amendment to `def:TMplus-c` /
`cor:tm-completeness` in `/home/benjamin/Philosophy/Papers/PossibleWorlds/`, routed through the
fix.md C4 process (option 2: switch the paper's BX_c basis to the Reynolds axioms). See
Non-Goals.

## Rollback/Contingency

- Every phase is additive. Three of the four code phases create **new** files, so rollback is
  file deletion plus reverting the corresponding one-line aggregator registration.
- Phase 1 (`Formula.co`) and Phase 6 (docstrings) are the only edits to pre-existing files;
  both are strictly additive or comment-only and revert cleanly with
  `git revert` of the phase commit.
- No `Axiom` constructor, `FrameClass` element, or existing theorem statement is changed, so no
  downstream consumer can break: a full rollback returns the library to its exact current
  behavior.
- If Phase 4 blocks (see its contingency), the task lands as `[PARTIAL]` with Phases 1, 2, 3, 5
  and a Phase-4-aware Phase 6 complete; `co_valid` and the Hölder lemmas stand on their own and
  the docstrings state the derivation as sketched rather than proved. No `sorry` and no axiom is
  introduced under any outcome.
