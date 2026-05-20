# Research Report: Task 155 -- Post-Task-157 Status Assessment

**Task**: 155 -- Reynolds Pipeline Activation
**Date**: 2026-05-20
**Session**: sess_1779261283_7c358c
**Focus**: Determine exact remaining work after task 157 completion

## Executive Summary

The discrete completeness pipeline has 5 distinct sorry sites across 2 files. Three are in Transfer.lean (the truth bridge), two are in IntegerModel.lean (the Reynolds Lemma 16 path). However, the critical discovery is that `chronicle_is_good` and `countermodel_discrete` both bypass the Reynolds Lemma 16 path entirely by using `orderIsoIntOfLinearSuccPredArch` directly. This means the 2 IntegerModel.lean sorries (`cofinal_decomposition_k_equiv`, `ordered_sum_of_good_bounded_is_good`) are NOT on the critical path.

The actual critical-path sorry chain for `bx_completeness` -> `countermodel_discrete` consists of:

1. `limitDomSubtype_isSuccArchimedean` (ChronicleToCountermodel.lean) -- inherited via `extract_chronicle_as_prior`
2. `Nonempty sig.preds` (Transfer.lean:332) -- trivial
3. Chronicle truth lemma (Transfer.lean:371) -- medium difficulty
4. `z_interval_countermodel` truth bridge (Transfer.lean:286) -- medium-high difficulty, has a bug

## What Task 157 Changed

Task 157 completed the oracle-free hierarchy for `is_separable`, making the expressive completeness of {S,U} over integer time fully sorry-free. The Separation module (`Separation/SeparationThm.lean`, `Separation/Hierarchy.lean`, etc.) now has ZERO axiom dependencies beyond `propext/Classical.choice/Quot.sound`.

**Impact on task 155**: Task 157's result means `table_correctness` and the separation infrastructure are available as sorry-free tools. However, the Reynolds pipeline activation does not directly use `is_separable` -- it uses `table_correctness` (sorry-free since task 148) and `doets_lemma_1_4` (sorry-free since task 154). Task 157's contribution is ensuring the broader ecosystem is clean, but it does not directly unblock any of the remaining sorry sites in Transfer.lean.

## Current Sorry Inventory

### Critical Path (blocking `bx_completeness`)

The completeness theorem at `Completeness.lean:163` calls `WeakCanonical.countermodel_discrete`, which has `sorryAx` in its axiom list. The sorry propagates through TWO independent channels:

**Channel A: `extract_chronicle_as_prior` (inherited sorry)**

```
countermodel_discrete (Transfer.lean:321)
  -> extract_chronicle_as_prior (ChronicleExtraction.lean:144)
    -> limitDomSubtype_isSuccArchimedean (ChronicleToCountermodel.lean:1900)
      -> succ_cofinal (ChronicleToCountermodel.lean:1563) [SORRY]
```

This is the `succ_cofinal` sorry from task 129. The chronicle extraction produces `IsSuccArchimedean` on the domain, which is then used at Transfer.lean:344 for `orderIsoIntOfLinearSuccPredArch`. This is the deepest sorry in the chain.

**Channel B: Transfer.lean explicit sorries**

| Line | Goal | Difficulty | Notes |
|------|------|------------|-------|
| 332 | `Nonempty sig.preds` | TRIVIAL | Need to handle empty-predicate edge case |
| 371 | `temporal_truth M_chron atomMap_fwd chron.root_point phi.neg` | MEDIUM | Chronicle truth lemma (inductive proof) |
| 286 | `not (truth_at TM Set.univ zIntervalHistory z phi)` | MEDIUM-HIGH | Truth bridge with a valuation bug |

### Non-Critical Path (IntegerModel.lean)

These are sorry'd lemmas in the Reynolds Lemma 16 proof path, which is NOT used by `countermodel_discrete`:

| Lemma | Line | Status | Notes |
|-------|------|--------|-------|
| `cofinal_decomposition_k_equiv` | 1079 | SORRY | Cofinal decomposition preserves k-equiv |
| `ordered_sum_of_good_bounded_is_good` | 1138 | SORRY | Shift-and-glue for bounded Z-intervals |

These are used by `very_good_implies_good` (Reynolds Lemma 16), which feeds into the abstract Reynolds pipeline. But `countermodel_discrete` and `chronicle_is_good` both bypass this by using `orderIsoIntOfLinearSuccPredArch` directly.

### Other sorry sites (not on critical path)

| File | Lemma | Status | Notes |
|------|-------|--------|-------|
| OrderedSum.lean:56 | `doets_lemma_1_5` | SORRY | Only needed for dense case (not discrete) |
| TruthLemma.lean (multiple) | Until/Since backward | SORRY | Non-critical, parametric truth lemma used instead |
| Completeness.lean:225 | `countermodel_discrete_enriched` | SORRY | Wrapper that inlines countermodel_discrete |
| Completeness.lean:254,279,288 | Frame-class completeness | SORRY | Future work, not blocking general completeness |

## Sorry-Free Theorems (Verified)

All of the following have been verified via `lean_verify` to have NO `sorryAx`:

| Theorem | File | Axioms |
|---------|------|--------|
| `chronicle_is_good` | IntegerModel.lean | propext, Classical.choice, Quot.sound |
| `finite_structures_good` | IntegerModel.lean | propext, Classical.choice, Quot.sound |
| `contemp_equiv_is_equiv` | IntegerModel.lean | propext, Classical.choice, Quot.sound |
| `one_class` | IntegerModel.lean | propext, Classical.choice, Quot.sound |
| `no_gaps_discrete` | IntegerModel.lean | propext, Classical.choice, Quot.sound |
| `no_boundary_at_successor` | IntegerModel.lean | propext, Classical.choice, Quot.sound |
| `k_equiv_preserves_sentence` | Transfer.lean | propext, Classical.choice, Quot.sound |
| `truth_transfer` | Transfer.lean | propext, Classical.choice, Quot.sound |
| `table_correctness` | Table.lean | propext, Classical.choice, Quot.sound |
| `table_depth_bound` | Table.lean | propext, Classical.choice, Quot.sound |
| `doets_lemma_1_1` | NormalForm.lean | propext, Classical.choice, Quot.sound |
| `doets_lemma_1_4` | OrderedSum.lean | propext, Classical.choice, Quot.sound |
| `k_equiv_of_iso` | IntegerModel.lean | propext, Classical.choice, Quot.sound |
| `countermodel_dense` | ChronicleToCountermodel.lean | no sorryAx |
| `dd_countermodel_chronicle_mixed_sorry` | ChronicleToCountermodel.lean | no sorryAx (vacuously true) |
| `separation_theorem_int` | SeparationThm.lean | no axioms at all |

## Architecture of `countermodel_discrete`

The current proof at Transfer.lean:312-381 follows this structure:

```
Step 1: extract_chronicle_as_prior -> ChronicleAsPriorModel [SORRY: succ_cofinal]
Step 2: mkSigFrom phi, mkAtomMap phi
Step 3: Nonempty sig.preds [SORRY: trivial]
Step 4: chronicleAsMonadicStructure
Step 5: orderIsoIntOfLinearSuccPredArch [requires IsSuccArchimedean from Step 1]
Step 6: Construct Z_wit (unbounded Z-interval), prove k_equiv [DONE]
Step 7: h_chronicle_truth: temporal_truth on chronicle [SORRY]
Step 8: truth_transfer (sorry-free, uses k_equiv + table_correctness)
Step 9: z_interval_countermodel [SORRY: truth bridge]
```

Key observation: Steps 6 and 8 are fully proved. The k-equivalence between the chronicle and the Z-interval is established by `k_equiv_of_iso`, and the truth transfer via existential closure is done. The remaining gap is on both ends: connecting MCS membership to temporal_truth (Step 7), and connecting temporal_truth to truth_at (Step 9).

## Bug in `z_interval_countermodel`

Transfer.lean:275-276 defines:
```lean
let TM : TaskModel zIntervalTaskFrame :=
  { valuation := fun _ a => Z.interp (atomMap_fwd (.atom a)) s.val }
```

The valuation uses `s.val` (the fixed witness point) rather than varying with the time parameter. This means `TM.valuation () a` returns the predicate value at a single fixed point for ALL time points. This is incorrect -- `truth_at TM Omega tau t (Formula.atom a)` should depend on `t`, not on the fixed witness `s`.

The correct definition should be:
```lean
let TM : TaskModel zIntervalTaskFrame :=
  { valuation := fun _ a => ??? }
```

But `TaskModel.valuation` has type `WorldState -> Atom -> Prop`, and `WorldState = Unit` for `zIntervalTaskFrame`. The valuation does not take a time parameter -- it takes a WorldState. Since WorldState = Unit, there is only one state, and the valuation cannot vary with time. This means the current `zIntervalTaskFrame` architecture is fundamentally incapable of encoding a Z-model where atom truth varies by position.

This is the same problem identified in Research Report 01 (Section 5): the single-state TaskFrame cannot capture time-varying atom truth. The fix requires either:

**(A) Make WorldState = Int**: The WorldState carries the time position. `task_rel` relates states at adjacent times. The valuation `fun (z : Int) (a : Atom) => Z.interp (atomMap_fwd (.atom a)) z` correctly varies with position. This requires building a proper TaskFrame Int with Int-valued WorldState and appropriate task_rel.

**(B) Use WorldHistory.states to encode position**: Keep WorldState = Unit but have the WorldHistory carry the time information. However, `truth_at` for atoms reads `TM.valuation (tau.states t h_dom) a`, so if `tau.states t _ = ()` always, the valuation cannot vary.

Approach (A) is the correct fix.

## Concrete Steps to Complete Task 155

### Step 1: Eliminate `succ_cofinal` dependency (HIGH priority, HARD)

The `extract_chronicle_as_prior` function uses `limitDomSubtype_isSuccArchimedean` which has a sorry. Two options:

**(Option 1) Refactor `ChronicleAsPriorModel` to drop `IsSuccArchimedean`**: Remove the `domain_succ_archimedean` field. Change `countermodel_discrete` to NOT use `orderIsoIntOfLinearSuccPredArch`. Instead, use `very_good_implies_good` (Reynolds Lemma 16) which only needs `Countable + NoMaxOrder + NoMinOrder`. But this requires closing the 2 IntegerModel.lean sorries first.

**(Option 2) Prove `succ_cofinal`**: This is task 129, which has 330+ lines of partial work and three failed approaches. Extremely hard.

**(Option 3) Use a different IsSuccArchimedean proof**: The chronicle domain IS succ-Archimedean (this is a mathematical fact for discrete countable linear orders without endpoints where succ/pred are well-defined). The current proof path through `succ_cofinal` is convoluted. An alternative proof might use the separation theorem or expressive completeness to derive IsSuccArchimedean directly.

**Recommendation**: Option 1 is cleanest. Remove `IsSuccArchimedean` from `ChronicleAsPriorModel`, then route through Reynolds Lemma 16 (requiring closure of `cofinal_decomposition_k_equiv` and `ordered_sum_of_good_bounded_is_good`).

### Step 2: Close `Nonempty sig.preds` (TRIVIAL)

Transfer.lean:332. Two approaches:
- Case-split on whether `phi.predFormulas` is empty. If empty, phi is purely propositional (only bot/imp), and a simpler countermodel suffices.
- Or prove that `phi.neg in A` implies phi has at least one predicate subformula (not true in general -- e.g., phi = bot).

The correct fix: handle the empty-predicate case separately with a propositional countermodel.

### Step 3: Chronicle truth lemma (MEDIUM)

Transfer.lean:371 (and the standalone `chronicle_temporal_truth` at line 178-186). Need to prove:
```
temporal_truth M_chron atomMap_fwd chron.root_point phi.neg
```

This requires an inductive proof that `temporal_truth` on the chronicle-as-monadic-structure agrees with MCS membership for all subformulas. The key ingredients are:
- Atom case: `atomMap_fwd` is a section of `atomMap_rev` on `predFormulas`
- Box case: `atomMap_fwd (.box psi)` maps to the box predicate, and MCS membership of `.box psi` tracks its truth
- Until/Since cases: Prior-UZ/SZ validity in the chronicle ensures temporal operator correctness
- The root_point's MCS contains `phi.neg` by hypothesis

### Step 4: Fix `z_interval_countermodel` (MEDIUM-HIGH)

Rewrite `zIntervalTaskFrame` with `WorldState = Int` (or a type isomorphic to the Z-interval carrier). Define:
```lean
noncomputable def zIntervalTaskFrame' : TaskFrame Int where
  WorldState := Int
  task_rel := fun w1 w2 delta => w2 = w1 + delta
  ...
```

Then define `TaskModel` with `valuation := fun z a => Z.interp (atomMap_fwd (.atom a)) z`.

Prove the inductive truth correspondence:
```
truth_at TM Omega tau t phi <-> temporal_truth Z.toOrdered atomMap_fwd (iso.symm t) phi
```

by structural induction on phi.

### Step 5: Close IntegerModel.lean sorries (if Option 1 for Step 1)

If taking Option 1 (removing IsSuccArchimedean), must close:
- `cofinal_decomposition_k_equiv` (line 1079): Prove that the cofinal decomposition preserves k-types. Standard but technical.
- `ordered_sum_of_good_bounded_is_good` (line 1138): The shift-and-glue construction. Need to show the concatenation of bounded Z-intervals indexed by Z is iso to Z.

### Step 6: Wire `countermodel_discrete_enriched` (EASY)

Completeness.lean:225 -- once `countermodel_discrete` is sorry-free, inline with explicit Int type.

### Step 7: Verify `#print axioms bx_completeness` (TRIVIAL)

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| `succ_cofinal` remains unsolved | HIGH if Option 2 | BLOCKING | Use Option 1 or Option 3 |
| `cofinal_decomposition_k_equiv` harder than expected | MEDIUM | BLOCKING if Option 1 | Can use EF-game argument |
| Truth bridge inductive proof complex | LOW-MEDIUM | DELAYS | Well-documented structure |
| TaskFrame refactor breaks downstream | LOW | MODERATE | `zIntervalTaskFrame` only used here |

## Effort Estimate

| Step | Effort | Notes |
|------|--------|-------|
| Step 1 (Option 1: refactor away IsSuccArchimedean) | 4-6h | Requires closing 2 IntegerModel sorries |
| Step 1 (Option 3: alternative IsSuccArchimedean proof) | 2-4h | May be simpler with separation theorem |
| Step 2 (Nonempty sig.preds) | 0.5h | Trivial case split |
| Step 3 (Chronicle truth lemma) | 3-5h | Inductive proof, well-structured |
| Step 4 (z_interval_countermodel fix + proof) | 4-6h | Architecture change + inductive proof |
| Step 5 (IntegerModel.lean sorries, if needed) | 3-5h | cofinal_decomposition + shift-and-glue |
| Step 6 (Wire enriched) | 0.5h | Straightforward |
| Step 7 (Verify) | 0.5h | Just run the check |

**Total estimate**: 13-23 hours (depending on approach to Step 1)

## Recommended Implementation Order

1. Step 2 (trivial, removes noise)
2. Step 1 Option 3 first attempt (try alternative IsSuccArchimedean proof using separation/expressive completeness); fall back to Option 1 if needed
3. Step 4 (fix z_interval_countermodel architecture + proof)
4. Step 3 (chronicle truth lemma)
5. Step 5 (only if Option 1 for Step 1)
6. Step 6 + Step 7 (wiring and verification)
