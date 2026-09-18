# Research Report: Task #603

**Task**: 603 - Investigate a ℚ-time frame predicate (`TaskFrame.IsQTime`)
**Started**: 2026-09-18T06:56:14Z
**Completed**: 2026-09-18T07:10:00Z
**Effort**: Small (implementation estimate: 1 phase, ~120 lines without the optional `≃+o ℚ` characterization; +120-200 lines with it)
**Dependencies**: None (sits beside the paper-alignment work in tasks 600/605/606/608; touches `FrameProperty.lean`, `Validity.lean`, `BXCanonical/Completeness.lean` only)
**Sources/Inputs**: - Codebase (`Semantics/FrameProperty.lean`, `Semantics/Validity.lean`, `Semantics/DurationClassification.lean`, `Semantics/IntTransfer.lean`, `Metalogic/BXCanonical/Completeness.lean`, `Metalogic/Compactness.lean`, `Metalogic/DedekindNonCompactness.lean`, `Metalogic/StrongCompleteness.lean`), Mathlib search tools (leansearch/loogle/leanfinder/local_search), lean-lsp MCP (`lean_run_code` end-to-end verification), paper `~/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex` and `metalogic.tex`
**Artifacts**: - specs/603_investigate_qtime_frame_predicate/reports/01_qtime-frame-predicate.md
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **Recommended definition (candidate (a), intrinsic "divisible + pairwise commensurable")**, placed in
  `FormalSystem/Semantics/FrameProperty.lean` next to `IsZTime`/`IsRTime`, with **no new imports**:
  ```lean
  def TaskFrame.IsQTime (F : TaskFrame) : Prop :=
    (∀ n : ℕ, n ≠ 0 → Function.Surjective (fun x : F.Duration => n • x)) ∧
    ∀ a b : F.Duration, a ≠ 0 → ∃ (m : ℤ) (n : ℕ), n ≠ 0 ∧ (n : ℤ) • b = m • a
  ```
  Together with `TemporalOrder`'s built-in nontriviality this picks out exactly the ordered groups `≃+o ℚ`
  (a torsion-free group of ℚ-rank one that is divisible). It excludes every near miss: `ℤ` and `ℤ[1/2]` fail
  divisibility; `ℚ + ℚ√2` and `ℚ ×ₗ ℚ` fail commensurability.
- **The whole application is already machine-checked in a scratch snippet, sorry-free**
  (`#print axioms` = `[propext, Classical.choice, Quot.sound]`): `isDense_of_isQTime` (12 lines),
  `isQTime` for every `FrameOver (TemporalOrder.of ℚ)` (10 lines), and
  `ValidQTime φ ↔ ValidDense φ` (22 lines, via `countermodel_dense_enriched` + `soundness_dense_valid` +
  `ValidOnFrames.mono`). The verified code is in the Appendix.
- Candidate (b) `Nonempty (F.Duration ≃+o ℚ)` is exact and cheap, but it would pull `ℚ` and `≃+o` into the
  lower semantic layer (`ClockFrame.lean` records that `Semantics/` avoids a tree-wide ℚ import), and it is an
  extrinsic "is isomorphic to" rather than an intrinsic condition like `IsZTime`/`IsRTime`. Candidate (c)
  (countable + dense) does **not** pick out ℚ as a group and cannot carry frames (only `≃o`). The "Archimedean +
  divisible + countable" variant of (d) admits `ℚ + ℚ√2`. No Mathlib predicate or `≃+o ℚ` classification exists.
- **Strong completeness over ℚ-time is NOT nearly free.** Finite-context consequence completeness is free
  (a 4-line P-generic copy of `semantic_deduction_in`), but set-based strong completeness is not: the ultraproduct
  route (`modelExistence_of_satPreserved`) fails its `hpres` obligation, because an ultrapower of ℚ is not
  Archimedean, so not commensurable. The ℚ-carrier chronicle is only coherent over a `Finset` closure. Recommend
  leaving it out of scope and recording it as open.

## Context & Scope

The goal is a semantic class strictly inside `IsDense`, the ℚ-time class. Its validity
`ValidQTime := ValidOnFrames TaskFrame.IsQTime` should be proved equal to `ValidDense`. It is **not** a new
`FrameClass` constructor. It mirrors `ValidComplete`, the other `ValidOnFrames` at a non-tag predicate. The
research compared four candidate definitions on these points:

- whether each pins down ℚ;
- how closely it follows the phrasing of `IsZTime`/`IsRTime`;
- reducibility and instance-cache concerns;
- what Mathlib already supports;
- proof cost;
- what the paper and in-tree usage favour.

## Findings

### Codebase Patterns

- **`IsZTime` is intrinsic and ℤ is recovered by a separate classification.** `IsZTime` =
  `∃ SuccOrder PredOrder, IsSuccArchimedean ∧ IsPredArchimedean` (existential only because `SuccOrder` is data).
  The isomorphism `intIso : D ≃+o ℤ` lives in `Semantics/DurationClassification.lean`, and carrier normalization
  `validZTime_iff_validInt` lives in `Semantics/IntTransfer.lean`. So the tree's pattern is an intrinsic `Prop` in
  `FrameProperty.lean`, an optional `≃+o` characterization in `DurationClassification.lean`, and an optional
  `Valid*`-over-one-carrier transfer. Candidate (a) reproduces that pattern exactly. Candidate (b) collapses the
  first two steps into the definition.
- **`IsRTime` is also intrinsic** (`IsDense ∧ IsComplete`). The tree deliberately does *not* prove `≃+o ℝ`
  (`DurationClassification.lean` module docstring: "What is deliberately *not* proved here"). So an intrinsic
  `IsQTime` with an optional, deferred `ratIso` has direct precedent.
- **Additive, not order-only, isomorphisms are what transport frames** (`IntTransfer.lean` module docstring:
  "Durations **add** … an order-only isomorphism cannot carry a frame across"). This rules out (c) as a ℚ-time
  predicate: `Order.iso_of_countable_dense` yields only `≃o`.
- **Reducibility.** `IsDense` is `abbrev` because `FrameClass.Sat .Dense` must reach the instance cache.
  `IsQTime` is never a `Sat` target: it is consumed by `obtain`/projection and by the named bridge
  `isDense_of_isQTime`. So a plain `def` is correct, like `IsZTime`/`IsComplete`/`IsRTime`. A `class`
  formulation is unnecessary. The definition carries no data (only `∀`/`∃` over elements and `nsmul`/`zsmul`), so
  the `Prop`-structure projection issue documented for `IsZTime` does not arise.
- **`countermodel_dense_enriched`** (`Metalogic/BXCanonical/Completeness.lean:139`) already returns a
  countermodel with `F : FrameOver (TemporalOrder.of Rat)`. `derivable_of_validDense` (line 264) applies
  `h_valid_dense` only at such ℚ-frames. So the dense completeness engine really proves completeness w.r.t.
  ℚ-frames: `ValidQTime → Derivable .Dense` is the same proof with `isQTime_rat F` in place of `inferInstance`.
- **Imports.** `FrameProperty.lean` imports only `TaskFrame` + `Order.SuccPred.*` and carries an
  `assert_not_exists` guard against the proof system. The recommended definition and `isDense_of_isQTime` were
  verified to compile against `import FormalSystem.Semantics.FrameProperty` alone (the proof avoids
  `norm_num`/`abel`/`linarith`, none of which are available or effective at that layer). The ℚ instance proof
  needs `field_simp`, so it must live downstream.

### External Resources (Mathlib, verified)

- `Order.iso_of_countable_dense` (`Mathlib/Order/CountableDenseLinearOrder.lean:245`): `Nonempty (α ≃o β)`,
  order-only. It is the in-tree Cantor step (`ChronicleToCountermodelBasic.lean:237`).
- `LinearOrderedAddCommGroup.discrete_or_denselyOrdered` (`Mathlib.GroupTheory.ArchimedeanDensely`): Archimedean ⇒
  `≃+o ℤ` ∨ dense. This is the ℤ side only. There is **no Mathlib `≃+o ℚ` classification** (leanfinder/leansearch
  both came up empty).
- `DivisibleBy` (`Mathlib/GroupTheory/Divisible.lean`) is a **data** class (`Type`-valued), so it is unsuitable
  as a `Prop` frame condition. The recommended surjectivity clause is its `Prop` shadow.
- `DivisibleHull M` (`Mathlib/GroupTheory/DivisibleHull.lean`): the ℚ-module hull with a linear order and
  `archimedeanClassOrderIso`. It could be used in the optional characterization, but is not needed for the definition.
- `Archimedean.embedReal` / `Archimedean.exists_orderAddMonoidHom_real_injective` (`Mathlib/Data/Real/Embedding.lean`):
  an alternative route for `ratIso` (embed into ℝ, normalize `u ↦ 1`, image = ℚ).
- `Rat.mul_den_eq_num`, `Rat.den_nz`: these discharge commensurability on ℚ (verified).

### Candidate comparison

| Candidate | Picks out ℚ up to `≃+o`? | Fidelity to `IsZTime`/`IsRTime` phrasing | Imports at `FrameProperty.lean` | Cost: ℚ satisfies | Cost: `→ Nonempty (≃+o ℚ)` |
|---|---|---|---|---|---|
| (a) divisible ∧ pairwise commensurable | **Yes** (with `TemporalOrder` nontriviality) | High: intrinsic `Prop` on the carrier, "generated by one element up to division", the analogue of ℤ's "generated by one step" | None new (verified) | 10 lines (verified) | ~120-200 lines, optional |
| (b) `Nonempty (F.Duration ≃+o ℚ)` | Yes, by definition | Low: extrinsic; neither sibling is phrased this way | Adds ℚ + `≃+o` to the lower semantic layer | 1 line (`⟨OrderAddMonoidIso.refl _⟩`) | Free |
| (c) `Countable ∧ DenselyOrdered` | **No**: admits `ℤ[1/2]`, `ℚ+ℚ√2`, `ℚ ×ₗ ℚ`; yields only `≃o ℚ` | Medium | `Countable` only | `inferInstance` | Impossible (false) |
| (d1) Archimedean ∧ divisible ∧ countable | **No**: admits `ℚ + ℚ√2 ⊂ ℝ` | Medium | small | small | Impossible (false) |
| (d2) fixed-unit form `∃ u ≠ 0, divisible ∧ ∀ x, ∃ m n, n•x = m•u` | Yes (equivalent to (a)) | High, but carries a witness | None | ~same as (a) | ~same as (a) |
| (d3) prime-subfield / `Module ℚ` / `finrank ℚ = 1` | Yes | Low: needs data instances on an abstract carrier; durations are not rings | Heavy | medium | medium |

All of (a)-(c) and (d1)-(d3) give `ValidOnFrames P = ValidDense` whenever `P` implies dense and holds of the ℚ
frames. For (c) and (d1) that holds by the sandwich `ValidDense ⊆ ValidP ⊆ ValidQ-frames = ValidDense`. So the
*validity* result does not discriminate between them. What discriminates is whether the predicate deserves the
name "ℚ-time", and only (a), (b), (d2) and (d3) do.

### Paper vocabulary

- `possible_worlds.tex` names only **ℤ-time** and **ℝ-time** as narrowed classes (l.1413-1419, footnote using
  Hölder). ℚ appears as a paradigm dense carrier ("identify T with ℤ, ℚ or ℝ", l.852). Kamp is noted not to
  extend to ℚ-time (l.1084). The paper defines no ℚ-time predicate, so there is no paper phrasing to match. The
  closest analogue is the paper's own route to ℤ-time, "discrete + Archimedean ⇒ ℤ" (intrinsic conditions,
  isomorphism as a consequence), which favours (a).
- `metalogic.tex` l.349-352 sketches "**strong** completeness of TM^d … canonical model uses T^c = ℚ". The
  mechanized tree does **not** realize that sketch for infinite sets: strong completeness over Dense uses
  ultraproducts, whose carriers are not ℚ. See Risks.

### Strong completeness over ℚ-time

- **Finite-context consequence: free.** `semantic_deduction_in`'s proof (`StrongCompleteness.lean:261`) is generic
  in the frame predicate (it only uses `truthAt_foldr_imp`). A P-indexed copy for `ConsequenceOnFrames IsQTime`
  plus `ValidQTime ↔ ValidDense` plus `consequence_completeness_dense` gives finite-Γ completeness over ℚ-time in
  under 15 lines.
- **Set-based strong completeness: not free, and not recommended here.**
  1. `SetConsequence.lean`'s `Compact`/`StrongCompleteness` are indexed by `FrameClass` tags. Since `IsQTime` is
     deliberately not a tag, stating the ℚ version needs a new P-indexed set-consequence layer.
  2. The ultraproduct engine `modelExistence_of_satPreserved` needs `hpres`, i.e. that the class survives
     ultraproducts. An ultrapower of ℚ is non-Archimedean, so it violates commensurability. `hpres` is false for
     `IsQTime`, exactly as for `.ZTime`/`.RTime`.
  3. The ℚ-carrier chronicle (`cantorBfmcsDense`) has a truth lemma only over `deferralClosure φ` (a `Finset`).
     `StrongCompleteness.lean` records that an arbitrary `Γ : Set Formula` has no single root.
  4. A downward Löwenheim-Skolem argument would give a *countable dense ordered group*. That is (c), not ℚ as a
     group, and making the history sort "full" in the substructure is nontrivial.
  The two known refutations do not port: `archWitness` needs `next`, which is vacuous on dense carriers, and
  `dedWitness` needs Dedekind completeness, which ℚ lacks. So compactness over ℚ-time is **open, plausibly
  true, and a separate project**.

### Recommendations

1. **Definition** (in `FrameProperty.lean`, after `IsRTime`): `TaskFrame.IsQTime`, as in the Executive Summary.
   Use a plain `def`, not `abbrev`. Its docstring should record:
   - **Why not `≃+o ℚ` directly:** it follows the `IsZTime` pattern (intrinsic condition, classification
     separate) and keeps ℚ out of the lower semantic layer.
   - **Why the density conjunct is omitted:** it is derivable, unlike in `IsRTime`.
   - **Why each clause is needed:** the four near-miss groups (`ℤ[1/2]`, `ℚ+ℚ√2`, `ℚ ×ₗ ℚ`, `ℤ`) each fail one.
   - **That it is not a `FrameClass` constructor:** point to `ValidComplete` as the precedent.
2. **Bridge** (same file): `TaskFrame.isDense_of_isQTime : F.IsQTime → F.IsDense` (verified proof, Appendix).
   Update the module docstring's "Main Definitions" and "Why five predicates" sections, which would become six
   frame predicates plus determinism.
3. **Validity** (`Semantics/Validity.lean`, beside `ValidComplete`):
   `def ValidQTime (φ : Formula) : Prop := ValidOnFrames TaskFrame.IsQTime φ`. Also state `ValidDense → ValidQTime`
   there, via `ValidOnFrames.mono` + `isDense_of_isQTime`.
4. **ℚ membership + completeness engine** (`Metalogic/BXCanonical/Completeness.lean`, beside
   `derivable_of_validDense`):
   - `isQTime_rat (F : FrameOver (TemporalOrder.of ℚ)) : F.toTaskFrame.IsQTime`.
   - `derivable_of_validQTime : ValidQTime φ → Derivable .Dense [] φ` (the current body of
     `derivable_of_validDense`, with `isQTime_rat F`).
   - Then `derivable_of_validDense` becomes a one-liner through `ValidOnFrames.mono`, which removes the duplication
     instead of creating it.
   - `validQTime_iff_validDense` (verified) closes the loop. It could also live in a small new
     `Metalogic/QTime.lean` if `Completeness.lean` should stay untouched.
5. **Optional, recommend deferring:** `ratIso : F.IsQTime → Nonempty (F.Duration ≃+o ℚ)` in
   `DurationClassification.lean` (analogue of `intIso`) and `ValidRat`/`validQTime_iff_validRat` (analogue of
   `IntTransfer.lean`). The latter is ~30 lines once `ratIso` exists, since `FrameOver.map`/`truthAt_map` are
   generic. Neither is needed for `ValidQTime = ValidDense`.
6. **Naming:** `TaskFrame.IsQTime`, `TaskFrame.isDense_of_isQTime`, `isQTime_rat`, `ValidQTime`,
   `derivable_of_validQTime`, `validQTime_iff_validDense`. These are consistent with the
   `IsZTime`/`ValidZTime`/`derivable_of_validZTime` family.
7. **A sorry-free path exists and is already verified.** No axioms and no sorry are required.

## Decisions

- Choose (a) over (b): intrinsic phrasing, no new imports in `Semantics/`, same pattern as `IsZTime` + `intIso`.
- Drop a redundant `IsDense` conjunct; supply `isDense_of_isQTime` instead (12 verified lines).
- Pairwise commensurability (no chosen unit) over the fixed-unit form (d2): it avoids an existential witness and
  is directly usable at any pair.
- `≃+o ℚ` characterization and strong (set-based) completeness over ℚ-time are out of scope. The former is
  optional polish. The latter is open research.

## Risks & Mitigations

- **Risk:** `IsQTime` could be mistaken for a proof-side class. **Mitigation:** its docstring points at the
  `ValidComplete` caveat pattern; there is no `FrameClass` constructor, and `Sat` is not touched.
- **Risk:** `metalogic.tex`'s strong-completeness sketch over `T^c = ℚ` suggests strong completeness over ℚ-time
  is established. **Mitigation:** record in the `ValidQTime` docstring that only weak and finite-context
  completeness transfer to ℚ-time; flag the sketch to the paper-sync work (task 607 chain) if it is still present.
- **Risk:** `n • x` with `n : ℕ` vs `(n : ℤ) • b` coercion friction. **Mitigation:** the exact statement in the
  Appendix elaborates and is consumed successfully at ℚ.
- **Risk:** Tactic availability at the `FrameProperty` layer (`norm_num`, `abel`, `linarith` unavailable or
  ineffective). **Mitigation:** the verified proof uses only `two_nsmul`, `add_nonpos`, `add_sub_cancel`,
  `lt_add_of_pos_right`.
- **Risk:** Concurrent edits. Task 588 is editing `Metalogic/` and task 605 is waiting on `Axioms.lean`.
  **Mitigation:** the recommended edits touch `FrameProperty.lean`, `Validity.lean` and `Completeness.lean` only.
  Check for in-flight edits to `Completeness.lean` before implementing.

## Tactic Survey Results

| Goal | Tactic | Result | Premises/Config |
|------|--------|--------|-----------------|
| `F.IsQTime → DenselyOrdered F.Duration` (at `FrameProperty` imports) | `linarith` | fail | no ring structure (known tree trap) |
| same | `norm_num` / `abel` | fail (unknown tactic at this import layer) | N/A |
| same | term proof | success | `two_nsmul`, `add_nonpos`, `add_sub_cancel`, `lt_add_of_pos_right` |
| ℚ divisibility `n • (y / n) = y` | `simp only [nsmul_eq_mul]; field_simp` | success | `(n:ℚ) ≠ 0` via `exact_mod_cast` |
| ℚ commensurability | `simp only [zsmul_eq_mul, Int.cast_natCast]; rw [← Rat.mul_den_eq_num]; field_simp` | success | `Rat.den_nz` |
| `ValidQTime φ → ValidDense φ` | copy of `derivable_of_validDense` + `soundness_dense_valid` | success | `countermodel_dense_enriched`, `set_lindenbaum`, `Axiom.dense_indicator` |
| `ValidDense φ → ValidQTime φ` | `ValidOnFrames.mono` | success | `isDense_of_isQTime` |
| axiom audit | `#print axioms` | `[propext, Classical.choice, Quot.sound]` | no sorryAx |

## Context Extension Recommendations

- **Topic**: ordered-group characterizations of ℤ/ℚ/ℝ time
- **Gap**: no context file records which intrinsic conditions pick out each carrier, or which near-miss groups
  (`ℤ[1/2]`, `ℚ+ℚ√2`, `ℚ ×ₗ ℚ`, `ℚ ×ₗ ℤ`) separate the candidate definitions
- **Recommendation**: add a short section to the lean4 project context (domain) listing the Z/Q/R-time predicates,
  their classification lemmas, and the non-compactness status per class

## Appendix

### Verified code (via `lean_run_code`, imports `FormalSystem.Metalogic.BXCanonical.Completeness` + `FormalSystem.Metalogic.Soundness`; the first two declarations also verified against `FormalSystem.Semantics.FrameProperty` alone)

```lean
def TaskFrame.IsQTime (F : TaskFrame) : Prop :=
  (∀ n : ℕ, n ≠ 0 → Function.Surjective (fun x : F.Duration => n • x)) ∧
  ∀ a b : F.Duration, a ≠ 0 → ∃ (m : ℤ) (n : ℕ), n ≠ 0 ∧ (n : ℤ) • b = m • a

theorem TaskFrame.isDense_of_isQTime {F : TaskFrame} (h : F.IsQTime) : F.IsDense := by
  refine ⟨fun x y hxy => ?_⟩
  obtain ⟨z, hz⟩ := h.1 2 two_ne_zero (y - x)
  simp only at hz
  rw [two_nsmul] at hz
  have hpos : 0 < z := by
    have : 0 < y - x := sub_pos.mpr hxy
    rw [← hz] at this
    by_contra hc
    exact absurd this (not_lt.mpr (add_nonpos (not_lt.mp hc) (not_lt.mp hc)))
  refine ⟨x + z, lt_add_of_pos_right x hpos, ?_⟩
  have : y = x + z + z := by rw [add_assoc, hz, add_sub_cancel]
  rw [this]; exact lt_add_of_pos_right _ hpos

theorem isQTime_rat (F : FrameOver (TemporalOrder.of ℚ)) : F.toTaskFrame.IsQTime := by
  refine ⟨fun n hn y => ⟨(y : ℚ) / n, ?_⟩, fun a b ha => ⟨((b : ℚ) / a).num, ((b : ℚ) / a).den,
    ((b : ℚ) / a).den_nz, ?_⟩⟩
  · have : (n : ℚ) ≠ 0 := by exact_mod_cast hn
    show n • ((y : ℚ) / n) = y
    simp only [nsmul_eq_mul]; field_simp
  · show (((b : ℚ) / a).den : ℤ) • (b : ℚ) = ((b : ℚ) / a).num • (a : ℚ)
    have ha' : (a : ℚ) ≠ 0 := ha
    have h := Rat.mul_den_eq_num ((b : ℚ) / a)
    simp only [zsmul_eq_mul, Int.cast_natCast]
    rw [← h]; field_simp

def ValidQTime (φ : Formula) : Prop := ValidOnFrames TaskFrame.IsQTime φ

theorem validQTime_iff_validDense (φ : Formula) : ValidQTime φ ↔ ValidDense φ := by
  constructor
  · intro h
    have hd : Derivable FrameClass.Dense [] φ := by
      by_contra h_not
      have h_cons := neg_consistent_of_not_derivable (fc := FrameClass.Dense) φ h_not
      obtain ⟨M, hM_sup, hM_mcs⟩ := set_lindenbaum {Formula.neg φ} h_cons
      have h_neg_in : Formula.neg φ ∈ M := hM_sup (Set.mem_singleton _)
      rcases SetMaximalConsistent.negation_complete hM_mcs
        (Formula.box Chronicle.nextTop.neg) with h_box_dense | h_not_box_dense
      · obtain ⟨F, _hdet, TM, τ, t, h_not_true⟩ :=
          countermodel_dense_enriched M hM_mcs φ h_neg_in h_box_dense
        exact h_not_true (h F.toTaskFrame (isQTime_rat F) TM τ t)
      · have h_ax : DerivationTree FrameClass.Dense [] Chronicle.nextTop.neg :=
          DerivationTree.axiom [] _ Axiom.dense_indicator (by trivial)
        have h_box : DerivationTree FrameClass.Dense [] Chronicle.nextTop.neg.box :=
          DerivationTree.necessitation _ h_ax
        exact set_consistent_not_both hM_mcs.1 _ (theorem_in_mcs hM_mcs h_box) h_not_box_dense
    obtain ⟨d⟩ := hd
    exact soundness_dense_valid d
  · intro h
    exact ValidOnFrames.mono (fun F hF => TaskFrame.isDense_of_isQTime hF) h
-- #print axioms: [propext, Classical.choice, Quot.sound]
```

(The scratch version used primed names and the `open` list `FormalSystem.Semantics FormalSystem.ProofSystem
FormalSystem.Metalogic.BXCanonical FormalSystem.Metalogic FormalSystem.Metalogic.Core FormalSystem.Syntax`.)

### Sketch for the optional `ratIso`

1. Fix `u > 0`, which exists by nontriviality.
2. Define `g x := m/n` from commensurability with `a := u`.
3. `g` is well defined, because ordered groups are torsion-free: `n'm•u = nm'•u ⇒ n'm = nm'`.
4. `g` is additive, and strictly monotone because `n•x` preserves sign.
5. `g` is surjective by the divisibility clause.
6. Package the result as `OrderAddMonoidIso`.

An alternative route is `Archimedean.exists_orderAddMonoidHom_real_injective`, rescaled so that `u ↦ 1`, with its
image identified as ℚ.

### Search queries used

- leansearch: "divisible torsion-free abelian group is a module over the rationals"; "ordered additive isomorphism
  to rationals, archimedean ordered field unique embedding of rationals"
- leanfinder: "a linearly ordered divisible abelian group in which any two nonzero elements are commensurable is
  order isomorphic to the rationals" (no ℚ classification; only the ℤ/dense dichotomy)
- loogle: `DivisibleBy ?A ℤ → Module ℚ ?A` (no results)
- local_search: `DivisibleBy`, `Order.iso_of_countable_dense`
