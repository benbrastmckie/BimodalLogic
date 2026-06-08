# Implementation Plan: Integer-Time Separation Bypass for US Expressive Completeness

- **Task**: 273 - Bypass GHR93 bridge lemma sorry via GHR94 integer-time separation
- **Status**: [NOT STARTED]
- **Effort**: 10 hours
- **Dependencies**: None (separation theorem is fully proved; all infrastructure exists)
- **Research Inputs**: specs/273_chronicle_gap_contradiction_proof/reports/03_stavi-sorry-analysis.md, specs/273_chronicle_gap_contradiction_proof/reports/04_ghr93-literature-review.md
- **Artifacts**: plans/03_separation-bypass-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

The completeness theorem `completeness_discrete` carries `sorryAx` through a chain that terminates at three sorry sites in `StaviCompleteness.lean` (lines 2353, 2435, 2805). These encode the GHR93 4-variable existential transfer in EF game composition. The sorry enters `completeness_discrete` via: `countermodel_discrete_reynolds_v2` -> `limitdom_is_good` -> `no_gaps_discrete_model_surgery` -> `gap_prior_UZ_contradiction` -> `invariant_formula_constant` -> `US_expressively_complete_over_prior` -> `stavi_expressive_completeness` -> sorry.

This plan bypasses the sorry by providing a new proof of `US_expressively_complete_over_prior` that does NOT import `StaviCompleteness.lean`. Instead, it uses the already-proved (sorry-free) separation theorem for integer time (GHR94 Chapter 10.2, in `Separation/`) combined with the fact that Stavi connectives U'(A,B) and S'(A,B) are always false on Prior structures (already proved sorry-free in `PriorExpressiveness.lean`).

The key architectural change: currently `PriorExpressiveness.lean` imports `StaviCompleteness.lean` to get `stavi_expressive_completeness` (the sorry-tainted theorem). The bypass replaces this with a self-contained argument that derives `US_expressively_complete_over_prior` using:
1. The separation theorem (`all_formulas_separable`, sorry-free in `Separation/`)
2. A bridge between `IntStructure`/`int_truth` (separation framework) and `OrderedMonadicStructure`/`temporal_truth` (main framework)
3. The separation-implies-expressive-completeness argument for Prior structures

Definition of done: `completeness_discrete` compiles without `sorryAx` (modulo any remaining sorry sources not in this chain, such as `chronicle_gap_contradiction` if still imported via `Completeness.lean`).

### Research Integration

Integrated reports:
- `03_stavi-sorry-analysis.md` (PRIMARY): Mapped the complete sorry dependency chain from `completeness_discrete` through `US_expressively_complete_over_prior` to `stavi_expressive_completeness`. Confirmed the 3 sorry sites encode the GHR93 4-variable existential transfer. Identified the separation-based bypass as "Alternative 1" with assessment: "conceptually simpler but technically verbose" (~1000-2000 lines estimated).
- `04_ghr93-literature-review.md`: Detailed the GHR93 composition argument and compared it with the NF approach. Recommended Alternative 1 (bypass via integer-time separation) as the primary approach: "completely avoids the bridge lemma sorry for the specific use case and uses a well-understood, purely syntactic proof technique."

Key findings incorporated:
1. The separation theorem (GHR94 Lemma 10.2.8 / Theorem 10.2.9) is fully formalized and sorry-free in `Separation/`.
2. `flatten_stavi_correct_prior` (U'/S' always false on Prior structures) is sorry-free in `PriorExpressiveness.lean`.
3. The bridge between `IntStructure` and `OrderedMonadicStructure` does NOT currently exist and must be built.
4. `US_expressively_complete_over_prior` is consumed ~7 times in `GoodStructuresModelSurgery.lean`; the replacement must have the SAME type signature.
5. The key mathematical insight: on Prior structures (which are integer-like), the separation theorem gives {U,S} separation, which combined with the standard table/induction argument gives expressive completeness WITHOUT Stavi connectives.

### Prior Plan Reference

Prior plan `01_gap-contradiction-plan.md` targeted proving `chronicle_gap_contradiction` directly via Z1 axiom co-induction. That plan is OBSOLETE: research report 03 established that `chronicle_gap_contradiction` is NOT on the critical path for `completeness_discrete` (it is bypassed by the v2 Reynolds countermodel pipeline). The prior plan's Phase 1 was marked [BLOCKED] due to the fundamental issue that orbit membership is second-order and cannot be expressed as a temporal formula. No phases from the prior plan are reused.

Lessons from the prior plan:
- Effort estimates were accurate for the Z1 infrastructure (2 hours estimated, Phase 1 completed but hit fundamental blocker)
- The Z1 co-inductive approach has a genuine circularity for the chronicle setting
- Plans in this codebase benefit from checking the actual import chain before committing to a proof strategy

### Roadmap Alignment

No ROADMAP.md found.

## Goals & Non-Goals

**Goals**:
- Prove `US_expressively_complete_over_prior` with the SAME type signature, but without importing `StaviCompleteness.lean`
- Build a bridge between `IntStructure`/`int_truth` (separation framework) and `OrderedMonadicStructure`/`temporal_truth` (main framework)
- Remove the `StaviCompleteness.lean` import from `PriorExpressiveness.lean`
- Make `completeness_discrete` sorry-free through this dependency chain (the `US_expressively_complete_over_prior` -> `stavi_expressive_completeness` chain)

**Non-Goals**:
- Fixing the EF game composition sorry sites (lines 2353, 2435, 2805 in StaviCompleteness.lean) -- those are bypassed, not fixed
- Proving `chronicle_gap_contradiction` (not on the critical path)
- Modifying `GoodStructuresModelSurgery.lean` (the consumer of `US_expressively_complete_over_prior`) -- the type signature must be preserved
- Proving Kamp's theorem in full generality (only the Prior structure case is needed)
- Removing the dense-case sorry from `completeness_dense` (separate concern)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Bridge between IntStructure and OrderedMonadicStructure is more complex than expected (different treatment of atoms, modal operators) | H | M | IntStructure uses `Atom -> Set Z`; OrderedMonadicStructure uses `MonadicSignature` with `preds`. The atomMap parameter already mediates between these. Build the bridge incrementally, starting with the simplest case. |
| Separation theorem's `int_truth` ignores the box operator (treats it as True), but `temporal_truth` handles box substantively | M | L | `US_expressively_complete_over_prior` only concerns temporal formulas (U, S, atoms, boolean connectives). The box case is irrelevant since the output formula uses only U and S. Verify that `flatten_stavi` never produces box. |
| Proof that "separated formula equivalent on all Prior structures" requires connecting integer-time semantics (Z) to arbitrary Prior structures | H | M | Prior structures satisfy Prior-UZ/SZ. The key fact: any Prior structure is "integer-like" for temporal truth purposes. The bridge needs to show that `int_equiv` on Z implies `temporal_truth` equivalence on Prior structures. This is the Kamp transfer step. |
| Total effort exceeds estimate due to bridge infrastructure | M | M | The separation theorem is already proved (the hard part). The bridge is conceptually simple: embed an OrderedMonadicStructure into an IntStructure by composing the order embedding with the valuation. If the bridge grows large, factor into a separate file. |
| Import cycle: PriorExpressiveness.lean cannot import Separation/ if Separation/ imports PriorExpressiveness.lean | H | L | Check the import graph. Separation/ currently imports only `Bimodal.Syntax.Formula` and Mathlib. PriorExpressiveness.lean currently imports StaviConnectives and StaviCompleteness. Replacing the StaviCompleteness import with Separation imports should not create a cycle. |
| The `ChronicleToCountermodel.lean` import in `Completeness.lean` leaks `sorryAx` from `chronicle_gap_contradiction` even after fixing the Stavi chain | M | H | This is a known issue from report 03. After the Stavi chain is fixed, a simple fix suffices: either guard the import or remove it. The `completeness_discrete` proof body does not use anything from ChronicleToCountermodel.lean. Include this as Phase 6. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2 | -- |
| 2 | 3 | 1 |
| 3 | 4 | 2, 3 |
| 4 | 5 | 4 |
| 5 | 6 | 5 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Semantic Bridge Infrastructure [COMPLETED]

**Goal**: Build the connection between `IntStructure`/`int_truth` (used by the separation theorem) and `OrderedMonadicStructure`/`temporal_truth` (used by `US_expressively_complete_over_prior`). This is the foundational infrastructure enabling the bypass.

**Tasks**:
- [ ] Create a new file `Theories/Bimodal/Metalogic/WeakCanonical/Separation/SemanticBridge.lean` that imports both `Separation.SeparationThm` and the relevant OrderedMonadicStructure definitions
- [ ] Define `oms_to_int_structure`: given an `OrderedMonadicStructure sig` with carrier isomorphic to Z (or any linear order), an `atomMap : Formula -> sig.preds`, construct an `IntStructure` by composing the order embedding with the predicate interpretation. For Prior structures, the carrier may not literally be Z, so use an order-isomorphism parameter
- [ ] Prove `int_truth_matches_temporal_truth`: for any formula `φ` (using only atoms, boolean connectives, U, S -- no box), `int_truth (oms_to_int_structure M atomMap iso) (iso t) φ <-> temporal_truth M atomMap t φ`. This is a structural induction on φ. The key cases are:
  - `atom a`: follows from the construction of `oms_to_int_structure`
  - `bot`: trivial
  - `imp`: follows from induction hypotheses
  - `untl φ ψ`: requires showing the existential and universal quantifiers transfer through the isomorphism
  - `snce φ ψ`: symmetric to `untl`
  - `box`: not needed (output formula will not contain box)
- [ ] Prove `int_equiv_implies_temporal_equiv`: if `int_equiv φ ψ` (over all IntStructures), then for any OrderedMonadicStructure M satisfying semantic Prior-UZ and Prior-SZ with atomMap, `temporal_truth M atomMap t φ <-> temporal_truth M atomMap t ψ`. This is the crucial transfer lemma. The proof constructs an IntStructure from M and transfers the equivalence.

**Timing**: 2 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/SemanticBridge.lean` (new file)

**Verification**:
- All lemmas compile without sorry
- `lake build Bimodal.Metalogic.WeakCanonical.Separation.SemanticBridge` succeeds
- No import cycles introduced

---

### Phase 2: Monadic FO to Temporal Formula Translation [NOT STARTED]

**Goal**: Build the translation from `MonadicFormula sig 1` (monadic first-order formulas with one free variable) to `Formula` (temporal formulas using U, S). This is the "table" translation from GHR94/Reynolds that converts first-order quantification over a linear order into temporal operators.

**Tasks**:
- [ ] Study the existing `MonadicFormula` type and `eval` function to understand the first-order formula structure. Key: `MonadicFormula sig n` has constructors for atoms (`pred`), boolean connectives, and existential quantification (`ex`). The `eval M env psi` evaluates `psi` in structure `M` with environment `env : Fin n -> M.carrier`.
- [ ] Define `monadic_to_temporal : MonadicFormula sig 1 -> (Formula -> sig.preds) -> Formula` (or use a Subtype approach). This translation converts:
  - Predicate application `P(x)` -> corresponding atom via `atomMap`
  - Boolean connectives -> same boolean connectives
  - Existential quantification `exists y, phi(x, y)` with `y > x`: `some_future (translate phi[y := current, x := free])`, and analogously for `y < x`
  - The key insight from Kamp/GHR: the translation is by induction on quantifier depth, using the separation theorem to keep formulas separated at each step
- [ ] Alternatively (and more practically): check if `stavi_expressive_completeness` can be replaced by a direct construction that doesn't go through the EF game bridge lemma. The existing `stavi_expressive_completeness` uses NF (Normal Form) theory which is the sorry-carrying part. A direct translation from `MonadicFormula sig 1` to `Formula` via the standard Kamp argument (quantifier elimination by induction on quantifier depth, using separation at each step) avoids NFs entirely.
- [ ] Prove the correctness of the translation: for any `MonadicFormula sig 1` `psi` and any Prior structure M, `eval M (fun _ => t) psi <-> temporal_truth M atomMap t (translate psi)`. This is an induction on `psi`'s structure, with the key quantifier case using the separation theorem (Phase 1's bridge) and Prior-UZ/SZ.

**Timing**: 3 hours

**Depends on**: none (can proceed in parallel with Phase 1, since the interface is known)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/KampTranslation.lean` (new file) -- or a similar name

**Verification**:
- Translation function compiles without sorry
- Correctness theorem compiles without sorry
- `lake build` for the new file succeeds

---

### Phase 3: Kamp's Theorem for Prior Structures [NOT STARTED]

**Goal**: Prove Kamp's theorem for Prior structures: every `MonadicFormula sig 1` has a {U,S}-temporal equivalent on structures satisfying semantic Prior-UZ and Prior-SZ. This combines the monadic-to-temporal translation (Phase 2) with the semantic bridge (Phase 1).

**Tasks**:
- [ ] Define and prove `kamp_prior`: for any `MonadicFormula sig 1` `psi`, there exists a `Formula` `A` such that for all Prior structures M with atomMap, `eval M (fun _ => t) psi <-> temporal_truth M atomMap t A`. This is the composition of:
  1. The monadic-to-temporal translation from Phase 2
  2. The separation theorem (ensuring the result uses only U and S in separated form)
  3. The Prior structure hypothesis (ensuring U'/S' contribute nothing)
- [ ] Ensure the output formula `A` uses only `atom`, `bot`, `imp`, `untl`, `snce` constructors (no `box`). The separation theorem guarantees this since `int_truth` treats box as True and the separation procedure never introduces box.
- [ ] Verify that the type signature matches what `US_expressively_complete_over_prior` needs: `{ A : Formula // forall M h_UZ h_SZ t, eval M (fun _ => t) psi <-> temporal_truth M atomMap t A }`

**Timing**: 1.5 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/KampTranslation.lean` (or `KampPrior.lean`)

**Verification**:
- `kamp_prior` compiles without sorry
- Type signature matches `US_expressively_complete_over_prior`'s result type

---

### Phase 4: Replace US_expressively_complete_over_prior [NOT STARTED]

**Goal**: Rewrite `PriorExpressiveness.lean` to prove `US_expressively_complete_over_prior` using the Kamp translation (Phase 3) instead of `stavi_expressive_completeness`. Remove the import of `StaviCompleteness.lean`.

**Tasks**:
- [ ] Modify `PriorExpressiveness.lean`:
  - Replace `import Bimodal.Metalogic.WeakCanonical.EFGames.StaviCompleteness` with `import Bimodal.Metalogic.WeakCanonical.Separation.KampTranslation` (or whatever file name from Phase 3)
  - Keep the `import Bimodal.Metalogic.WeakCanonical.StaviConnectives` (still needed for `stavi_U_false_on_prior_UZ`, `stavi_S_false_on_prior_SZ`, and `flatten_stavi_correct_prior` if they remain)
  - Actually: check whether `StaviConnectives.lean` has its own sorry. If not, it can stay. The sorry is only in `StaviCompleteness.lean`.
- [ ] Rewrite `US_expressively_complete_over_prior` to use `kamp_prior` instead of `stavi_expressive_completeness` + `flatten_stavi_correct_prior`. The new proof:
  ```
  obtain ⟨A, h_A⟩ := kamp_prior atomMap h_surj psi
  exact ⟨A, fun M h_UZ h_SZ t => h_A M h_UZ h_SZ t⟩
  ```
- [ ] Verify that the TYPE SIGNATURE of `US_expressively_complete_over_prior` is unchanged:
  ```lean
  noncomputable def US_expressively_complete_over_prior
      {sig : MonadicSignature}
      (atomMap : Formula -> sig.preds)
      (h_surj : forall p : sig.preds, exists a : Atom, atomMap (.atom a) = p)
      (psi : MonadicFormula sig 1) :
      { A : Formula //
        forall (M : OrderedMonadicStructure sig)
          (_h_prior_UZ : semantic_prior_UZ M atomMap)
          (_h_prior_SZ : semantic_prior_SZ M atomMap)
          (t : M.carrier),
          eval M (fun _ => t) psi <->
          temporal_truth M atomMap t A }
  ```
- [ ] The existing sorry-free lemmas in PriorExpressiveness.lean (`stavi_U_false_on_prior_UZ`, `stavi_S_false_on_prior_SZ`, `flatten_stavi_correct_prior`) remain unchanged -- they do NOT depend on StaviCompleteness.lean's sorry-carrying parts. They only depend on the StaviConnectives definitions.
- [ ] Verify that `GoodStructuresModelSurgery.lean` (which imports `PriorExpressiveness.lean` and uses `US_expressively_complete_over_prior` ~7 times) still compiles without changes.

**Timing**: 1.5 hours

**Depends on**: 2, 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/PriorExpressiveness.lean` -- change imports and rewrite `US_expressively_complete_over_prior`

**Verification**:
- `lake build Bimodal.Metalogic.WeakCanonical.PriorExpressiveness` succeeds
- `lake build Bimodal.Metalogic.WeakCanonical.IntegerModel.GoodStructuresModelSurgery` succeeds
- `#print axioms US_expressively_complete_over_prior` shows no `sorryAx`
- `#print axioms gap_prior_UZ_contradiction` shows no `sorryAx` (this was the consumer)

---

### Phase 5: Decouple Completeness.lean from ChronicleToCountermodel [NOT STARTED]

**Goal**: Remove or guard the import of `ChronicleToCountermodel.lean` from `Completeness.lean` so that `completeness_discrete` does not inherit `sorryAx` from `chronicle_gap_contradiction` (which is not on its critical path but leaks sorry through Lean's transitive import mechanism).

**Tasks**:
- [ ] Read `Completeness.lean` to confirm that `completeness_discrete` does not use anything from `ChronicleToCountermodel.lean`. Research report 03 states this but verify by checking the proof body.
- [ ] Check if `completeness_dense` (also in Completeness.lean) uses ChronicleToCountermodel.lean content. If yes, the import cannot be removed entirely -- it would need to be moved to a separate file.
- [ ] If `completeness_dense` uses ChronicleToCountermodel:
  - Option A: Move `completeness_dense` to a separate file (e.g., `CompletenessDense.lean`) that imports ChronicleToCountermodel
  - Option B: Keep the import but verify that `completeness_discrete` is sorry-free via `#print axioms`
  - Option C: If Lean's `#print axioms` only reports axioms actually used in the proof body (not just transitively imported), the import may not matter. Verify this behavior.
- [ ] If `completeness_dense` does NOT use ChronicleToCountermodel: remove the import entirely.
- [ ] Verify `#print axioms completeness_discrete` after the change.

**Timing**: 1 hour

**Depends on**: 4

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` -- adjust imports
- Possibly: create `Theories/Bimodal/Metalogic/BXCanonical/CompletenessDense.lean` if splitting is needed

**Verification**:
- `lake build Bimodal.Metalogic.BXCanonical.Completeness` succeeds
- `#print axioms completeness_discrete` does not include `sorryAx`
- If split was done: `completeness_dense` still compiles in the new location

---

### Phase 6: Full Build Verification and Axiom Audit [NOT STARTED]

**Goal**: Run full project build, verify `completeness_discrete` is sorry-free, audit the axiom set, and clean up any documentation.

**Tasks**:
- [ ] Run `lake build` for the full project
- [ ] Run `#print axioms completeness_discrete` and verify output is `[propext, Classical.choice, Lean.ofReduceBool, Lean.trustCompiler, Quot.sound]` (no `sorryAx`)
- [ ] Verify the sorry chain is eliminated:
  - `US_expressively_complete_over_prior` -- sorry-free
  - `gap_prior_UZ_contradiction` -- sorry-free (inherits from US_expressively_complete_over_prior)
  - `gap_prior_SZ_contradiction` -- sorry-free
  - `no_gaps_discrete_model_surgery` -- sorry-free
  - `limitdom_is_good` -- sorry-free
  - `countermodel_discrete_reynolds_v2` -- sorry-free
  - `completeness_discrete` -- sorry-free
- [ ] Verify no new `sorry` was introduced: `grep -rn "sorry" Theories/Bimodal/Metalogic/WeakCanonical/Separation/ --include="*.lean"` shows no results
- [ ] Verify no import cycles: `lake build` succeeds (import cycles cause build failure)
- [ ] Update docstring comments in `PriorExpressiveness.lean` to document the new proof strategy (separation-based bypass instead of Stavi completeness composition)
- [ ] Verify that existing tests pass: `lake build BimodalTest`

**Timing**: 1 hour

**Depends on**: 5

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/PriorExpressiveness.lean` -- update docstrings

**Verification**:
- `lake build` succeeds for the full project
- `#print axioms completeness_discrete` shows no `sorryAx`
- `grep` finds no unexpected sorry in modified files
- Existing tests pass

## Testing & Validation

- [ ] `lake build` completes without errors for the full project
- [ ] `#print axioms Bimodal.Metalogic.WeakCanonical.US_expressively_complete_over_prior` does not include `sorryAx`
- [ ] `#print axioms Bimodal.Metalogic.WeakCanonical.IntegerModel.gap_prior_UZ_contradiction` does not include `sorryAx`
- [ ] `#print axioms Bimodal.Metalogic.BXCanonical.completeness_discrete` does not include `sorryAx`
- [ ] `GoodStructuresModelSurgery.lean` compiles without changes (type signature preserved)
- [ ] No new `sorry` introduced in the Separation/ directory
- [ ] No import cycles (verified by successful `lake build`)
- [ ] Existing `Tests/BimodalTest/` tests pass

## Artifacts & Outputs

- `specs/273_chronicle_gap_contradiction_proof/plans/03_separation-bypass-plan.md` (this file)
- New file: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/SemanticBridge.lean`
- New file: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/KampTranslation.lean`
- Modified: `Theories/Bimodal/Metalogic/WeakCanonical/PriorExpressiveness.lean` (import change + proof rewrite)
- Modified: `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` (import adjustment)
- `specs/273_chronicle_gap_contradiction_proof/summaries/03_separation-bypass-summary.md`

## Rollback/Contingency

- If the semantic bridge (Phase 1) proves intractable due to type mismatches between `IntStructure` and `OrderedMonadicStructure`: consider an alternative approach where the Kamp translation is defined directly on `OrderedMonadicStructure` without going through `IntStructure`. This would duplicate some separation infrastructure but avoid the bridge entirely.
- If the Kamp translation (Phase 2) is too complex for a single pass: break the quantifier elimination into multiple sub-phases (one for the base case, one for the inductive step), each targeting specific quantifier patterns.
- If the Completeness.lean decoupling (Phase 5) reveals that `completeness_dense` deeply depends on ChronicleToCountermodel: use Option B (keep import, verify `#print axioms` only reports used axioms) as a temporary measure.
- If the full plan fails: fall back to the secondary recommendation from research report 04 -- strengthen zone-matching (Approach C) or restructure the induction (Approach D) to close the actual sorry in `nf_2var_existential_transfer` (StaviCompleteness.lean:2353/2435).
- Git revert to the commit before implementation if any phase introduces regressions.
