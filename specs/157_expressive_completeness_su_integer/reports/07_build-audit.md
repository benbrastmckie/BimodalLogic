# Task 157 Build Audit: Current State After Multiple Partial Agents

**Date**: 2026-05-17
**Auditor**: lean-research-agent
**Scope**: ExpressiveCompleteness.lean and its dependencies in WeakCanonical/

---

## 1. Build Status

`lake build` completes successfully: **1647 jobs, no errors**.

There are no compilation errors anywhere in the project. All warnings are either:
- `declaration uses 'sorry'` (expected, tracked below)
- Unused simp arguments in IntegerModel.lean (cosmetic, already flagged)
- Unused variables in FrameConditions (unrelated, pre-existing)

The `.ex`/`.all` build errors mentioned in prior handoffs no longer exist. They were resolved by a previous agent.

---

## 2. Sorries in ExpressiveCompleteness.lean

There are exactly **3 sorry instances** in the file (1298 total lines):

| Line | Location | What it defers |
|------|----------|----------------|
| 958 | `atom_elim_correct` theorem body | The core quantifier elimination correctness proof |
| 1139 | `.ex alpha` case of `expressiveness_inner`, atom containment branch | Atom containment for `quantElimFormula` in the existential case |
| 1217 | `.all alpha` case of `expressiveness_inner`, atom containment branch | Atom containment for `neg (quantElimFormula ...)` in the universal case |

All three sorries are inside `expressiveness_inner`. The two atom containment sorries (lines 1139 and 1217) are near-identical and small. The critical sorry is line 958 (`atom_elim_correct`), which is the main proof obligation.

---

## 3. Axioms in the Separation Subsystem

All axioms are in `Separation/SeparationThm.lean`. There are **9 axioms total**.

### Pre-existing axioms (8, introduced in earlier phases):

**Temporal closure for separability** (4 axioms):
- Line 90: `all_past_separable` — H of a separable formula is separable
- Line 94: `all_future_separable` — G of a separable formula is separable
- Line 98: `untl_separable` — U of separable formulas is separable
- Line 102: `snce_separable` — S of separable formulas is separable

**Temporal closure for proper separability** (4 axioms):
- Line 223: `all_past_properly_separable`
- Line 228: `all_future_properly_separable`
- Line 233: `untl_properly_separable`
- Line 239: `snce_properly_separable`

These 8 axioms encapsulate the GHR94 substitution bridge (Lemmas 10.2.4-10.2.8). They are known-sound by Kamp 1968 / Reynolds 1994 independent establishment.

### Newest axiom (1, added by most recent agent):

- Line 281: `proper_separation_preserves_atoms (φ : Formula)`

**Statement:**
```lean
axiom proper_separation_preserves_atoms (φ : Formula) :
    ∃ ψ : Formula, is_properly_separated ψ = true ∧ int_equiv φ ψ ∧
    formula_atoms ψ ⊆ formula_atoms φ
```

**Assessment of `proper_separation_preserves_atoms`:**

This axiom is mathematically true and provable in principle. The GHR94 separation procedure (Lemmas 10.2.3-10.2.8) operates by: (1) identifying syntactic subformulas of specific forms (e.g. `U(a ∧ S(A,B), q)`), (2) replacing them with equivalent temporal combinations built from the same subformulas, without introducing new atoms. No fresh atomic propositions are added at any step.

However, this axiom is **not currently derivable** from the existing infrastructure because:
1. The 8 temporal closure axioms above only guarantee existence of an equivalent properly separated formula; they do not track atom content.
2. The `DualEliminations.lean` file has 8 open sorries (the dual elimination cases 1-8, which are the S-side mirror of the proved elimination cases). These dual cases would need to be proved first.
3. The full atom-tracking version requires threading a `formula_atoms ψ ⊆ formula_atoms φ` invariant through the entire junction-depth induction, which is Phase 6 work.

**Recommendation**: The axiom is *sound* and its use does not introduce a logical inconsistency. However, it should eventually be proved (Phase 6). It should **not** be removed now since it is load-bearing for `expressiveness_inner` (used at lines 1091 and 1167). For the current task, the axiom is a legitimate placeholder with clear proof obligations.

No axioms exist outside of `Separation/SeparationThm.lean`.

---

## 4. Infrastructure Quality: What's Solid vs. What's Broken

### Solid (compiles, no sorries in the functions themselves)

| Component | File:Lines | Status |
|-----------|-----------|--------|
| `to_int_struct_mem_freshAM` | EC.lean:793-805 | Fully proved |
| `to_int_struct_mem_atomMap` | EC.lean:808-817 | Fully proved |
| `int_truth_foldl_and` | EC.lean:822-839 | Fully proved |
| `guardFormula_correct` | EC.lean:842-881 | Fully proved |
| `int_truth_depends_on_atoms` | EC.lean:894-939 | Fully proved |
| `applySubsts_past_correct` | EC.lean:742-761 | Fully proved |
| `applySubsts_future_correct` | EC.lean:764-783 | Fully proved |
| `subst_preserves_past_only` | EC.lean:695-716 | Fully proved |
| `subst_preserves_future_only` | EC.lean:718-740 | Fully proved |
| `mk_fresh_atomMap_inj` | EC.lean:971-975 | Fully proved |
| `mk_fresh_base_ne` | EC.lean:978-982 | Fully proved |
| `expressiveness_inner` (structural cases) | EC.lean:1013-1056 | `.atom`, `.lt`, `.not`, `.and` fully proved |
| `expressiveness_wf` (framework) | EC.lean:1221-1245 | Scaffolding correct, delegates to inner |
| `expressiveness_fixed_atomMap` | EC.lean:1249-1261 | Fully proved (wraps wf) |
| `separation_implies_expressiveness` | EC.lean:1263-1280 | Fully proved (wraps fixed_atomMap) |
| `US_expressively_complete_over_Z` | EC.lean:1290-1296 | Fully proved (calls separation_implies_expressiveness) |

Note: `int_truth_foldl_or` and `guardFormula_unique` were not found in the file. They either were renamed or are not needed in the current approach.

### Has Sorries (blocks the main goal)

| Component | File:Lines | What's missing |
|-----------|-----------|----------------|
| `atom_elim_correct` | EC.lean:949-958 | Full proof body (1 sorry) |
| `.ex alpha` atom containment | EC.lean:1135-1139 | Proof that `formula_atoms (quantElimFormula ...)` ⊆ range atomMap |
| `.all alpha` atom containment | EC.lean:1214-1217 | Same, for the negation case |

### Related WeakCanonical sorries (not in EC.lean)

These are upstream/parallel sorries that affect the broader task 157 pipeline but not directly ExpressiveCompleteness.lean:

| File | Lines (build warning) | Description |
|------|-----------------------|-------------|
| `IntegerModel.lean` | 1074, 1092 | `cofinal_decomposition_k_equiv`, `ordered_sum_of_good_bounded_is_good` (k≥2) — Reynolds Lemma 16 components |
| `Transfer.lean` | 178, 258, 312 | `chronicle_temporal_truth`, `z_interval_countermodel` bridge, `doets_countermodel_discrete` sorry chain |
| `OrderedSum.lean` | 50 | `doets_lemma_1_5` (dense case, not on discrete critical path) |
| `TruthLemma.lean` | 404, 446, 458, 495, 512 | Until/Since forward/backward in WeakCanonical truth lemma (non-critical for bx_completeness) |
| `Separation/DualEliminations.lean` | 8 sorries | elim_cases 1-8 dual (S-side mirror of the proved elimination cases) |

---

## 5. Detailed Sorry Analysis: What's Needed to Close Each

### Sorry 1: `atom_elim_correct` (line 958) — THE BIG ONE

**Goal state**: Prove that
```
Separation.int_truth (to_int_struct (extIntStruct M t) freshAM) t B_sep
↔ Separation.int_truth (to_int_struct M atomMap) t (quantElimFormula atomMap freshAM B_sep)
```

**Hypotheses available**:
- `B_sep` is properly separated (`hB_sep : is_properly_separated B_sep = true`)
- All atoms of `B_sep` are in `range freshAM` (`hB_atoms`)
- `atomMap` and `freshAM` have disjoint ranges (`h_disj`)
- `atomMap` and `freshAM` are injective

**What's needed**: Structural induction on `B_sep` with case analysis on the `quantElimFormula` disjunction. The key insight documented in the code is:

1. `quantElimFormula` is a big disjunction `∨_σ (guardFormula(σ) ∧ elimExtFromSep(σ, B_sep))` over all assignments σ.
2. Exactly one branch has `guardFormula(σ)` true in the original model (the one matching the current model's assignment at time `t`).
3. For that true branch, `elimExtFromSep` correctly substitutes freshAM atoms back using `applySubsts_{past,future}_correct`.

The proof requires:
- A lemma `int_truth_foldl_or` (mirror of the existing `int_truth_foldl_and`) — **not yet proved**
- `guardFormula_unique`: only one σ has `guardFormula(σ)` true in a given model — **not yet proved**
- A lemma connecting `elimExtFromSep` truth to `B_sep` truth via the substitutions — substantial, requires the separation structure and purity predicates

**Estimated LOC**: 100-200 lines for a complete proof of `atom_elim_correct`.

### Sorry 2: `.ex alpha` atom containment (line 1139)

**Goal**: `a ∈ Separation.formula_atoms (quantElimFormula atomMap freshAM B_sep)` implies `a ∈ Set.range atomMap`.

**What's needed**: A lemma `formula_atoms_quantElimFormula` showing that the atoms of `quantElimFormula` are exactly the union of:
- atoms of `guardFormula` = all `atomMap p` = range atomMap
- atoms of `elimExtFromSep` = after substitution, only `atomMap p` atoms remain (freshAM and lt/gt atoms are eliminated by substitution)

This requires a `formula_atoms_elimExtFromSep` lemma and `formula_atoms_applySubsts` lemma tracking how atom substitution changes `formula_atoms`. Medium complexity.

**Estimated LOC**: 50-80 lines.

### Sorry 3: `.all alpha` atom containment (line 1217)

Identical to Sorry 2 but for `Formula.neg (quantElimFormula ...)`. Since `formula_atoms (Formula.neg φ) = formula_atoms φ`, this reduces to the same `formula_atoms_quantElimFormula` lemma.

**Estimated LOC**: 5-10 lines (just applies the neg atoms lemma + Sorry 2's lemma).

---

## 6. Total Remaining Work Estimate for ExpressiveCompleteness.lean

| Work Item | Estimated LOC | Complexity |
|-----------|--------------|------------|
| `int_truth_foldl_or` | 20-30 | Low (mirrors int_truth_foldl_and) |
| `guardFormula_unique` | 30-50 | Medium (requires Finset.univ exhaustion + decidability) |
| `formula_atoms_applySubsts` | 30-40 | Medium (structural induction) |
| `formula_atoms_elimExtFromSep` | 40-60 | Medium (structural induction on formula type) |
| `formula_atoms_quantElimFormula` | 20-30 | Medium (assembles previous two) |
| Core `atom_elim_correct` proof | 120-180 | High (structural induction on B_sep + disjunction uniqueness) |
| Atom containment sorry 2 | 10-15 | Low (uses formula_atoms_quantElimFormula) |
| Atom containment sorry 3 | 5-10 | Low (uses sorry 2's lemma) |
| **Total** | **275-415 LOC** | |

---

## 7. Key Architectural Observations

1. **The main sorry chain is self-contained**: `atom_elim_correct` at line 958 is the single hardest piece. Everything else in `expressiveness_inner` is complete. Closing this sorry closes the core expressiveness theorem.

2. **`US_expressively_complete_over_Z` already compiles**: The final theorem at line 1290 compiles and type-checks. It depends on `atom_elim_correct` only transitively through `expressiveness_inner`. The axiom `proper_separation_preserves_atoms` is already in place and allows the outer structure to typecheck.

3. **`proper_separation_preserves_atoms` is load-bearing but sound**: It is used at lines 1091 and 1167. Without it, the entire `expressiveness_inner` existential/universal quantifier cases would fail. It correctly states what the GHR94 procedure does and introduces no inconsistency.

4. **No `int_truth_foldl_or` or `guardFormula_unique` exist yet**: These are needed for `atom_elim_correct` but have not been written. They are straightforward extensions of existing infrastructure.

5. **DualEliminations.lean has 8 open sorries**: These are NOT on the critical path for `ExpressiveCompleteness.lean`. They are needed for Phase 6 (eliminating the 8 temporal closure axioms), which is future work. The current axioms in `SeparationThm.lean` bypass the need for these dual cases.

6. **Build is clean**: No `.ex`/`.all` errors exist. Prior handoff descriptions of such errors are outdated.

---

## 8. Critical Path Summary

To get `ExpressiveCompleteness.lean` sorry-free (while keeping the 9 axioms in SeparationThm.lean):

1. Prove `int_truth_foldl_or`
2. Prove `guardFormula_unique`
3. Prove `formula_atoms_applySubsts`
4. Prove `formula_atoms_elimExtFromSep`
5. Prove `formula_atoms_quantElimFormula`
6. Use (1)-(5) to prove `atom_elim_correct`
7. Close the two atom containment sorries using `formula_atoms_quantElimFormula`

Steps 1-7 are all within `ExpressiveCompleteness.lean` or small helper lemmas. No upstream files need modification except possibly adding a `formula_atoms_subst_formula` lemma to `Separation/Defs.lean` or `Separation/FormulaOps.lean`.
