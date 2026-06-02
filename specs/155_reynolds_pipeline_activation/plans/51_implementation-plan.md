# Implementation Plan: Task #155 (Revised v51)

- **Task**: 155 - Close no_gaps_discrete import cycle and rewire completeness_discrete
- **Status**: [NOT STARTED]
- **Effort**: 5 hours
- **Dependencies**: Task 199 (grid_order_tactic, PARTIAL -- non-blocking for this re-scoped work)
- **Research Inputs**: specs/155_reynolds_pipeline_activation/reports/50_import-cycle-research.md, team research findings (3 parallel agents on Z+Z counterexample and corrected mathematical path)
- **Artifacts**: plans/51_implementation-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Rewrite `chronicle_gap_contradiction` in ChronicleToCountermodel.lean to derive its contradiction using sorry-free infrastructure from GoodStructuresModelSurgery.lean, replacing the broken `prior_model_is_succ_archimedean` path. The previous plan (v50) was blocked because its core step "one_class implies IsSuccArchimedean" is mathematically incorrect (Z+Z counterexample). This revised plan uses a corrected two-case argument: either the chronicle MCS assignment varies across the gap (providing a distinguishing formula for `gap_contradicts_prior`), or the MCS is constant (in which case the discrete order is order-isomorphic to Z, making it IsSuccArchimedean by construction).

### Research Integration

Key findings from three parallel research agents investigating the v50 blocker:

1. **Reynolds 1994 never proves IsSuccArchimedean**. His proof uses model surgery to show one class, then k-equivalence transfer. The BX pipeline's requirement for IsSuccArchimedean is a codebase-specific deviation from Reynolds.

2. **Chronicle connectivity does NOT prove IsSuccArchimedean**. New chronicle points are not always adjacent (C5-forward can place points far above max, C4-forward inserts between existing points).

3. **The Z+Z counterexample is definitive**: one_class does NOT imply IsSuccArchimedean even with Prior-UZ/SZ + h_surj. The Z+Z order with constant MCS satisfies all hypotheses. The fix requires using chronicle-specific properties (non-trivial MCS variation or order-structure) that the abstract setting lacks.

4. **Transfer.lean:1289 sorry is NOT on the critical path**. The production completeness theorem (`completeness_discrete`) uses `countermodel_discrete_enriched`, not `countermodel_discrete_reynolds`.

### Prior Plan Reference

Plan v50 was blocked at Phase 1 because step 1.8 ("from one_class, derive IsSuccArchimedean") is mathematically unsound. This plan replaces Phase 1 entirely with a corrected proof strategy.

## Goals & Non-Goals

**Goals**:
- Rewrite `chronicle_gap_contradiction` to use sorry-free `gap_contradicts_prior` and `no_boundary_at_successor` from GoodStructuresModelSurgery.lean and GoodStructures.lean
- Make `succ_cofinal`, `limitDomSubtype_isSuccArchimedean`, and `completeness_discrete` sorry-free
- Pass `lake build` with zero errors

**Non-Goals**:
- Closing the `no_gaps_discrete` sorry in GoodStructures.lean (separate task, can use same import)
- Modifying `completeness_discrete` code (becomes sorry-free automatically)
- Fixing `countermodel_discrete_reynolds` (Transfer.lean:1289, permanently blocked dead code)
- Proving the abstract `no_gaps_prior` / `no_gaps_faithful` theorems (deprecated, false as stated)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| The two-case argument (MCS varies vs MCS constant) requires proving that constant MCS on LimitDomSubtype implies order-isomorphism to Z | H | M | The chronicle construction builds the domain inductively from a countable set of rationals with SuccOrder; if all points have the same MCS, the successor structure has no gaps by the Prior-UZ/SZ constraints. Fallback: use `gap_of_not_succ_archimedean` + `gap_contradicts_prior` directly in the non-constant case, and handle the constant case by showing the successor orbit covers the entire order |
| Proving `semantic_prior_UZ/SZ` for the raw LimitDomSubtype (not ChronicleAsPriorModel) requires adapting the Transfer.lean pattern | M | L | The pattern is well-established: convert temporal_truth to MCS membership via effectiveFormula, apply MCS-level Prior-UZ/SZ (from h_fc : Discrete <= fc), convert back. The only difference is using raw limit_f/limit_c0 instead of ChronicleAsPriorModel fields |
| Import cycle when adding GoodStructuresModelSurgery to ChronicleToCountermodel.lean | L | L | Verified by report 50: GoodStructuresModelSurgery's transitive imports do not include BXCanonical. No cycle |
| `gap_contradicts_prior` requires `h_surj` which needs signature/atomMap construction | L | L | `mkSigFrom`/`mkAtomMapFwd`/`mkAtomMapFwd_surj` from Transfer.lean provide exactly this infrastructure |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |

Phases within the same wave can execute in parallel.

### Phase 1: Rewrite chronicle_gap_contradiction [BLOCKED]

**BLOCKER** (Phase 1):
- **What failed**: Cannot import GoodStructuresModelSurgery.lean (or GoodStructures.lean) into ChronicleToCountermodel.lean due to an import cycle.
- **Import cycle path**: `GoodStructuresModelSurgery -> NEquivalence -> ChronicleExtraction -> ChronicleToCountermodel` (circular back to the file we need to modify). Confirmed by `lake build` error: "bad import 'Bimodal.Metalogic.WeakCanonical.IntegerModel.GoodStructuresModelSurgery'".
- **What was tried**:
  1. Direct import of GoodStructuresModelSurgery into ChronicleToCountermodel -- fails with import cycle.
  2. Removing the direct ChronicleExtraction import in GoodStructures.lean -- insufficient because OrderedSum -> NEquivalence -> ChronicleExtraction -> ChronicleToCountermodel still creates the cycle.
  3. Formula-level proof using only PriorModelData fields (Prior-UZ/SZ, C4/C5) -- handles Case A (MCS differs across gap) but cannot handle Case B (constant MCS). The Z+Z counterexample (two copies of Z with constant MCS) is a valid PriorModelData with a gap, confirming the abstract argument is insufficient.
  4. Chronicle-specific proof that constant MCS implies Z (no gap) -- requires reasoning about the inductive chronicle construction (stage-by-stage), which is complex and was not completed.
- **Why it's stuck**: Two independent obstacles:
  1. **Import cycle**: The sorry-free model surgery theorems (`reynolds_model_surgery_core`, `gap_contradicts_prior`, `no_boundary_at_successor`) are in files that transitively import ChronicleToCountermodel.lean via `ChronicleExtraction.lean`. This is because `ChronicleExtraction.lean` imports `ChronicleToCountermodel.lean` for `LimitDomSubtype`, `limitDomSubtype_succOrder`, `limitDomSubtype_predOrder`, `limitDomSubtype_isSuccArchimedean`, and other basic definitions.
  2. **Constant-MCS case**: Even if the cycle were broken, the plan's two-case argument requires handling the case where `limit_f(a.val) = limit_f(b.val)`. In this case, `reynolds_model_surgery_core` proves one_class (all points contemp_equiv), but one_class does NOT imply IsSuccArchimedean (Z+Z counterexample). The chronicle-specific argument that constant MCS implies the domain is Z requires showing that no C4/C5 witnesses are added outside the succ/pred chain, which needs induction on the chronicle's omega-chain construction.
- **What is needed**:
  **Option A (Import cycle resolution)**: Split ChronicleToCountermodel.lean into two files:
    - `ChronicleToCountermodelBasic.lean`: Contains `LimitDomSubtype`, `limitDomSubtype_succOrder`, `limitDomSubtype_predOrder`, `limitDomSubtype_noMaxOrder`, `limitDomSubtype_noMinOrder`, `limitDomSubtype_countable`, `box_discrete_gives_discreteness`, `theorem_in_mcs`, `limit_f_zero`, `zero_mem_limit_dom`, and other basic definitions (roughly lines 1-1100).
    - `ChronicleToCountermodel.lean` (current file): Keeps gap elimination, IsSuccArchimedean, countermodel construction, and imports `ChronicleToCountermodelBasic`.
    Then change `ChronicleExtraction.lean` to import `ChronicleToCountermodelBasic` instead of `ChronicleToCountermodel`. This breaks the cycle, allowing `ChronicleToCountermodel` to import `GoodStructuresModelSurgery`.
  **Option B (Chronicle-specific proof)**: Prove `chronicle_gap_contradiction` directly from the omega-chain construction by showing: in the discrete case with constant MCS, the chronicle construction produces exactly the succ/pred chain from 0, with no additional points. This eliminates the constant-MCS gap case without needing model surgery imports.
  **Option C (Hybrid)**: Do Option A to break the cycle, then use `reynolds_model_surgery_core` for Case A (MCS differs). For Case B (constant MCS), add a lemma in the new split file showing that constant temporal_truth implies the succ chain from any point covers the entire domain.
- **Prohibited workarounds**: Do NOT use `sorry`, `def X := True`, or any vacuous placeholder.

**Goal**: Replace the sorry'd `prior_model_is_succ_archimedean` call in `chronicle_gap_contradiction` with a sorry-free proof using `gap_contradicts_prior` from GoodStructuresModelSurgery.lean and `no_boundary_at_successor` from GoodStructures.lean.

**Mathematical Strategy**:

The proof derives False from `h_orbit_bounded : forall n, succ^[n](a) < b`.

Step 1: Import and construct infrastructure.
- Add `import Bimodal.Metalogic.WeakCanonical.IntegerModel.GoodStructuresModelSurgery` to ChronicleToCountermodel.lean
- Choose an arbitrary formula phi (e.g., `Formula.bot`) and construct `sig := mkSigFrom phi`, `atomMap_fwd := mkAtomMapFwd phi`, `atomMap_rev := mkAtomMap phi`
- Prove `h_surj : forall p, exists a, atomMap_fwd (.atom a) = p` via `mkAtomMapFwd_surj`
- Construct `M_struct : OrderedMonadicStructure sig` on `LimitDomSubtype`:
  ```
  carrier := LimitDomSubtype fc A h_mcs
  interp p x := (atomMap_rev p) in limit_f fc A h_mcs x.val
  carrier_order := inferInstance
  ```

Step 2: Prove `semantic_prior_UZ` and `semantic_prior_SZ` for `M_struct`.
- Follow the `chronicle_semantic_prior_UZ` pattern from Transfer.lean:1082-1135
- Key adaptation: use `limit_f`/`limit_c0`/`limit_satisfies_c5_strong`/`limit_satisfies_c4` directly instead of through `ChronicleAsPriorModel` fields
- The proof structure is identical: convert MCS membership to/from temporal_truth via effectiveFormula, apply MCS-level Prior-UZ/SZ (from h_fc), use C5/C4 coherence

Step 3: Derive contradiction via two cases.
- Pick any `k : Nat` (k = 0 suffices for the distinguishing case)
- By `no_boundary_at_successor sig k M_struct`: for all c, `contemp_equiv sig k M_struct c (succ c)`
- By transitivity + induction: the class of a is succ-closed (if c ~ a, then succ(c) ~ c ~ a, so succ(c) ~ a)
- **Case A**: Exists `y > a` with `not (contemp_equiv sig k M_struct a y)`. Then a's class is succ-closed and bounded above. Apply `gap_contradicts_prior sig k M_struct atomMap_fwd h_surj h_prior_UZ h_prior_SZ a h_succ_closed h_bounded_above` to get False.
- **Case B**: For all `y > a`, `contemp_equiv sig k M_struct a y`. Then a's class includes all points above a, including b. In particular `b ~ a`. Combined with `succ^n(a) ~ a` for all n and the class being succ-closed: a's class extends below a too (by symmetric argument with `no_boundary_at_successor` applied to pred). So a's class = entire LimitDomSubtype. Now we use the fact that this holds for ALL k and ALL sig: the MCS interpretation at every point is the same for every formula in every signature, meaning `limit_f(x) = limit_f(y)` for all x, y. In this constant-MCS case, `prior_UZ_valid` at any point t says: `F(psi) -> U(psi, neg(psi))` is in fmcs(t). With constant MCS, for any psi in the MCS, F(psi) is trivially in the MCS (psi holds at succ(t)). So `U(psi, neg(psi))` is in the MCS. By C5 forward, there exists s > t with psi at s and neg(psi) between t and s. But with constant MCS, neg(psi) between t and s contradicts psi being everywhere. Unless (t, s) is empty, i.e., s = succ(t). So the Until witness is always the immediate successor. This means the order has no gaps (every element has an immediate successor whose immediate successor has an immediate successor, etc., with no jumps). Combined with NoMinOrder and the countability of LimitDomSubtype (subset of rationals), the order is isomorphic to Z. But Z is IsSuccArchimedean (`IsSuccArchimedean` for Int is proved). This contradicts h_orbit_bounded.

**Note on simplification**: The Case B argument may be simplified by showing: if for all y > a we have contemp_equiv for ALL k (not just a specific k), then `gap_contradicts_prior` applied with k large enough where `not (contemp_equiv sig k' M_struct a b)` for some specific sig' containing a distinguishing formula, yields a contradiction. This avoids the constant-MCS analysis entirely. The key is choosing sig/k adaptively:
- If `limit_f(a.val)` differs from `limit_f(b.val)`, pick psi in the symmetric difference, set sig' = mkSigFrom(psi), k' = 0. Then a and b are NOT 0-equiv, so a's class (in sig', k'=0) is bounded above by b. Apply gap_contradicts_prior.
- If `limit_f(a.val) = limit_f(b.val)`, by C4/C5 coherence all intermediate points also have the same MCS (otherwise the MCS would need to change and change back, contradicting Until/Since coherence at the change points). Then the order has no MCS variation across the entire orbit range, and the successor iteration from a covers all points up to b (since each succ step is to a point with the same MCS and there's no MCS-detectable boundary to prevent continuation). Formalize this as: define S = {x | exists n, succ^n(a) = x} union {x | exists n, pred^n(a) = x}. Show S = LimitDomSubtype (by showing any point outside S creates a gap contradicting Prior-UZ/SZ). Then b in S, so succ^n(a) = b for some n, contradicting h_orbit_bounded.

**Tasks**:
- [ ] Add `import Bimodal.Metalogic.WeakCanonical.IntegerModel.GoodStructuresModelSurgery` to ChronicleToCountermodel.lean *(deviation: blocked -- import cycle prevents this, see BLOCKER below)*
- [ ] Verify the import compiles without cycle errors (`lake build Bimodal.Metalogic.BXCanonical.Chronicle.ChronicleToCountermodel`) *(deviation: blocked -- cycle confirmed, see BLOCKER)*
- [ ] Define a local `OrderedMonadicStructure` on `LimitDomSubtype` within `chronicle_gap_contradiction`: carrier = LimitDomSubtype, interp via `limit_f` membership, carrier_order = inferInstance
- [ ] Construct `mkSigFrom`/`mkAtomMapFwd`/`mkAtomMap` with surjectivity
- [ ] Prove `semantic_prior_UZ` for the constructed structure, adapting `chronicle_semantic_prior_UZ` from Transfer.lean:1082-1135 to use raw `limit_f`/`limit_c0`/`limit_satisfies_c5_strong`/`limit_satisfies_c4`
- [ ] Prove `semantic_prior_SZ` symmetrically, adapting Transfer.lean:1141-1161
- [ ] Prove the class of a is succ-closed: if `contemp_equiv sig k M_struct a c` then `contemp_equiv sig k M_struct a (Order.succ c)`, using `no_boundary_at_successor` + `contemp_equiv_is_equiv` transitivity
- [ ] Implement the two-case argument:
  - Case A: class bounded above -> `gap_contradicts_prior` -> False
  - Case B: class unbounded above -> find distinguishing formula from MCS variation, or prove constant MCS implies Z-isomorphism contradicting h_orbit_bounded
- [ ] Derive contradiction from `h_orbit_bounded`

**Timing**: 3.5 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- add import, rewrite `chronicle_gap_contradiction` (lines 1538-1588)

**Verification**:
- `lake build Bimodal.Metalogic.BXCanonical.Chronicle.ChronicleToCountermodel` passes
- `chronicle_gap_contradiction` has no sorry
- `succ_cofinal` (line 1599) has no sorry (it delegates to `chronicle_gap_contradiction`)

---

### Phase 2: Verify completeness_discrete is Sorry-Free [NOT STARTED]

**Goal**: Confirm the sorry-free status propagates through the full dependency chain from `chronicle_gap_contradiction` to `completeness_discrete`.

**Tasks**:
- [ ] Run `lake build Bimodal.Metalogic.BXCanonical.Completeness` to verify it compiles
- [ ] Add a temporary `#print axioms completeness_discrete` check in Completeness.lean and verify no `sorryAx` appears
- [ ] Trace the dependency chain to confirm no sorry remains: `chronicle_gap_contradiction` -> `succ_cofinal` -> `limitDomSubtype_isSuccArchimedean` -> `succ_embed_surjective` -> `cantor_bfmcs_discrete_restricted_tc/fuc` -> `countermodel_discrete_enriched` -> `completeness_discrete`
- [ ] Remove the temporary `#print axioms` line after verification

**Timing**: 30 minutes

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` -- temporary `#print axioms` (added then removed)

**Verification**:
- `#print axioms completeness_discrete` shows no `sorryAx`
- `lake build Bimodal.Metalogic.BXCanonical.Completeness` passes

---

### Phase 3: Full Build and Documentation Updates [NOT STARTED]

**Goal**: Run full `lake build`, update stale comments in source files, and update docstrings to reflect the new proof path.

**Tasks**:
- [ ] Run full `lake build` and verify zero errors
- [ ] Update the docstring on `chronicle_gap_contradiction` (line 1527-1537) to describe the new proof path via `gap_contradicts_prior` / `no_boundary_at_successor` from GoodStructuresModelSurgery.lean instead of `prior_model_is_succ_archimedean`
- [ ] Update the docstring on `succ_cofinal` (line 1591-1598) to remove the sorry reference
- [ ] Update the docstring on `limitDomSubtype_isSuccArchimedean` (line 1607-1612) to remove the sorry reference and task 129 mention
- [ ] Add a note near `prior_model_is_succ_archimedean` (ReynoldsModelSurgery.lean:343) marking it as dead code bypassed by the `gap_contradicts_prior` path
- [ ] Update the sorry-chain comment in `Completeness.lean` (lines ~295-308) to reflect the new sorry-free status of the discrete case

**Timing**: 1 hour

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- update docstrings
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/ReynoldsModelSurgery.lean` -- add dead-code note
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` -- update sorry-status comments

**Verification**:
- `lake build` passes (no functional changes in this phase, only comments)
- All modified docstrings accurately reflect the current proof state

## Testing & Validation

- [ ] `lake build Bimodal.Metalogic.BXCanonical.Chronicle.ChronicleToCountermodel` passes after Phase 1
- [ ] `#print axioms completeness_discrete` shows no `sorryAx` after Phase 2
- [ ] Full `lake build` passes with zero errors after Phase 3
- [ ] `chronicle_gap_contradiction` contains no `sorry` keyword
- [ ] `succ_cofinal` contains no `sorry` keyword
- [ ] `completeness_discrete` contains no `sorry` keyword (and no transitive sorry)

## Artifacts & Outputs

- plans/51_implementation-plan.md (this file)
- summaries/51_execution-summary.md (to be created at implementation completion)

## Rollback/Contingency

If the two-case argument in Phase 1 proves intractable (particularly Case B, the constant-MCS / Z-isomorphism argument):

1. **Fallback A**: Strengthen the approach by showing that in the chronicle, limit_f(a) and limit_f(b) always differ when succ^n(a) < b for all n. The chronicle construction adds points via C4/C5 specifically to create MCS variation. This would eliminate Case B entirely, reducing to Case A (gap_contradicts_prior with bounded class).

2. **Fallback B**: Factor the proof into two separate theorems: (a) `chronicle_gap_contradiction_nonconstant` handling the case where limit_f varies (using gap_contradicts_prior directly), and (b) `chronicle_gap_contradiction_constant` handling the constant case (using order-theoretic arguments about Z). The constant case may be independently easier since it reduces to showing the successor iteration on a countable discrete order without MCS variation covers the entire order.

3. **Fallback C**: Revert `chronicle_gap_contradiction` to its current state (PriorModelData approach with sorry) and instead create a bridge theorem in a new file (e.g., `ChronicleNoGapsModelSurgery.lean`) that wraps `gap_contradicts_prior` for consumption by ChronicleToCountermodel.lean, working at the `ChronicleAsPriorModel` level where the required properties are bundled.
