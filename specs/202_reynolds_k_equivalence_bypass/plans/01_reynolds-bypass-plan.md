# Implementation Plan: Reynolds k-Equivalence Bypass for Sorry-Free completeness_discrete

- **Task**: 202 - Reynolds k-equivalence bypass for sorry-free completeness_discrete
- **Status**: [NOT STARTED]
- **Effort**: 25-40 hours
- **Dependencies**: 155 (Reynolds pipeline activation -- EF game infrastructure)
- **Research Inputs**: specs/202_reynolds_k_equivalence_bypass/reports/01_reynolds-bypass-research.md
- **Artifacts**: plans/01_reynolds-bypass-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Rewire `countermodel_discrete` (Transfer.lean:790) to use the Reynolds k-equivalence pipeline instead of `dd_countermodel_chronicle_discrete`, eliminating `succ_cofinal` from `completeness_discrete`. The current path requires `IsSuccArchimedean` on the chronicle domain (blocked by the unprovable `succ_cofinal`). The Reynolds bypass proves the chronicle is `good` (k-equivalent to a Z-interval) without proving it is Z-isomorphic, by establishing that all points are in one contemporaneous equivalence class via `no_gaps_discrete` (Reynolds Theorem 14), then transferring truth via k-equivalence to a Z-model counterexample. The sole remaining sorry is `no_gaps_discrete` (GoodStructures.lean:842), which requires extending US expressive completeness from Z (already proved as `US_expressively_complete_over_Z`) to general Prior structures.

### Research Integration

Key findings from `01_reynolds-bypass-research.md`:
- Existing infrastructure is ~80% complete (~10,800+ lines in WeakCanonical)
- Sole critical sorry: `no_gaps_discrete` at GoodStructures.lean:842 (Reynolds Theorem 14)
- `ghr93_forward_to_backward_discrete` (Theorem 6) already proved sorry-free (Transfer.lean:662-769)
- `k_equiv_preserves_sentence`, `truth_transfer`, `chronicle_temporal_truth`, `z_interval_countermodel` all sorry-free
- `exists_cofinal_sequence` (ShiftAndGlue.lean:127) requires only Countable + NoMaxOrder + NoMinOrder + Nonempty -- NOT IsSuccArchimedean
- `very_good_implies_good` (ShiftAndGlue.lean:829) uses `exists_cofinal_sequence`, NOT `IsSuccArchimedean`
- `one_class` (GoodStructures.lean:883) is sorry-free modulo `no_gaps_discrete`
- `US_expressively_complete_over_Z` (Theorem.lean:357) already proved sorry-free but only over Z

### Prior Plan Reference

Task 155 has 44+ plan versions and extensive research (48+ artifacts). Key lessons: (1) `succ_cofinal` is unprovable -- 4 research agents confirmed the constant-MCS gap scenario is consistent. (2) EF-game infrastructure (ghr93_forward_to_backward_discrete) is solid and sorry-free. (3) The Reynolds pipeline architecture in Transfer.lean is correct but the `chronicle_is_good` proof path via `orderIsoIntOfLinearSuccPredArch` is blocked. (4) The bridge from EF games to k-equivalence for general Prior structures is the hard mathematical content.

### Roadmap Alignment

This task is on the CRITICAL PATH for sorry-free `completeness_discrete`:
- Advances: "Sorry-free `bx_completeness`" -- eliminates the sole remaining sorry
- Unblocks: task 95 (verification audit), task 176 (Chronicle relocation), all downstream refactoring

## Goals & Non-Goals

**Goals**:
- Eliminate the `succ_cofinal` sorry from `completeness_discrete`
- Prove `no_gaps_discrete` (Reynolds Theorem 14) via US expressive completeness over Prior structures
- Rewire `countermodel_discrete` to use the Reynolds pipeline (chronicle -> good -> truth_transfer -> Z-countermodel)
- Achieve `#print axioms completeness_discrete` with no `sorryAx`
- `lake build` passes with zero errors

**Non-Goals**:
- Proving `succ_cofinal` directly (confirmed unprovable)
- Proving `IsSuccArchimedean` for the chronicle domain
- Changing the chronicle construction itself
- Addressing the ~17 dead-code sorries in BXCanonical (those are in dead code)
- Optimizing proof term size or compilation time
- Refactoring naming conventions (deferred to task 175)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| US expressive completeness transfer from Z to Prior structures harder than estimated | H | M | Existing `US_expressively_complete_over_Z` provides the core; the extension to Prior structures requires showing that Prior-UZ/SZ enforce the same temporal expressiveness as the standard translation over Z. Can axiomatize the extension if a direct proof is too complex. |
| `h_truth_corr` hypothesis of `z_interval_countermodel` difficult to discharge | M | M | The hypothesis decomposes into box transparency (already proved as `zIntervalBox_transparent`) and atom agreement (follows from `chronicle_temporal_truth` + section property). Concrete proof strategy exists in Transfer.lean comments. |
| `no_gaps_discrete` proof requires Reynolds Lemmas 7-8, 12 (model surgery) not yet formalized | H | M | The model surgery approach requires showing that class boundaries contradict Prior-UZ/SZ via temporal formulas expressing the boundary. Can factor into separate lemmas and formalize incrementally. |
| New `chronicle_is_good_direct` theorem has unexpected type-checking issues | L | L | The existing `very_good_implies_good` is sorry-free and well-tested; the new path only changes the input (`very_good` via `one_class` instead of `orderIsoIntOfLinearSuccPredArch`). |
| Compilation time explosion from large proof terms | L | M | Use `set_option maxHeartbeats` locally; factor proofs into small lemmas; use `lake build Module.Name` for incremental checking. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |

Phases within the same wave can execute in parallel.

---

### Phase 1: US Expressive Completeness Over Prior Structures [BLOCKED]

**BLOCKER** (Phase 1):
- **What failed**: US expressive completeness over Prior structures requires extending `US_expressively_complete_over_Z` from Z-structures to general discrete linear orders satisfying Prior-UZ/SZ. This is Reynolds Theorem 5 (GHR94 Theorem 9.3.1 for Prior structures).
- **What was tried**: Analysis of `separation_implies_expressiveness` (Z-specific), `proper_separation_theorem_int` (Z-specific), and Stavi connective decomposition infrastructure. The existing proof pipeline is Z-specific throughout (`IntStructureFromSig`, `int_truth`, `to_int_struct`).
- **Why it's stuck**: The expressive completeness result is formalized only over Z. Extending to Prior structures requires: (1) showing U'(A,B) and S'(A,B) are equivalent to bot in any Prior structure (via Prior-UZ/SZ), (2) rewriting `separation_implies_expressiveness` to work with `temporal_truth` on general `OrderedMonadicStructure` instead of `int_truth` on `IntStructureFromSig`. This is 8-12 hours of mathematical formalization.
- **What is needed**: Formalize Reynolds Theorem 5: in any discrete countable linear order without endpoints satisfying Prior-UZ/SZ semantically, {U,S} is expressively complete for monadic FO. See Rollback/Contingency item 3 for a scope reduction option.
- **Prohibited workarounds**: Do NOT use `sorry`, `def X := True`, or any vacuous placeholder

**Goal**: Extend `US_expressively_complete_over_Z` to hold over general discrete Prior structures (structures satisfying Prior-UZ and Prior-SZ). This is the mathematical core: showing that every monadic FO sentence of bounded quantifier depth has an equivalent temporal formula (using U, S) that transfers truth correctly at every point of any Prior structure.

**Tasks**:
- [ ] Study `US_expressively_complete_over_Z` (Theorem.lean:357-363) and `separation_implies_expressiveness` to understand the Z-specific proof
- [ ] Identify which parts of the Z proof use integer-specific structure vs. general discrete-order properties
- [ ] Define `PriorStructure` predicate (or reuse `ChronicleAsPriorModel` fields): discrete countable linear order without endpoints, satisfying Prior-UZ and Prior-SZ semantically
- [ ] Prove `US_expressively_complete_over_prior` theorem: for any monadic FO sentence of quantifier depth <= k, there exists a temporal formula A such that for all points t in any Prior structure M, `temporal_truth M atomMap t A <-> eval M env phi`
- [ ] The proof strategy: (a) by `US_expressively_complete_over_Z`, get temporal formula A that works over Z; (b) show that Prior-UZ + Prior-SZ + discreteness + no-endpoints ensures the temporal semantics of A is determined solely by the k-type profile, which is the same information captured by k-equivalence; (c) use `ghr93_forward_to_backward_discrete` to transfer the EF-game characterization from Z to the Prior structure
- [ ] Alternative: if the transfer is too complex, prove directly via the Stavi connective decomposition (StaviConnectives.lean, sorry-free) + quantifier elimination (QuantifierElimination.lean, sorry-free) that the result holds for Prior structures

**Timing**: 8-12 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/ExpressiveCompleteness/Theorem.lean` - Add `US_expressively_complete_over_prior`
- Potentially new file `Theories/Bimodal/Metalogic/WeakCanonical/ExpressiveCompleteness/PriorExpressiveness.lean` if the addition is large

**Verification**:
- `US_expressively_complete_over_prior` compiles with no sorry
- `lean_verify` shows no `sorryAx`
- `lake build Bimodal.Metalogic.WeakCanonical.ExpressiveCompleteness.Theorem` passes

---

### Phase 2: Prove `no_gaps_discrete` (Reynolds Theorem 14) [BLOCKED]

**BLOCKER** (Phase 2):
- **What failed**: `no_gaps_discrete` requires Phase 1 (US expressive completeness over Prior structures) to provide a temporal formula that detects class boundaries.
- **What was tried**: Analysis of alternative approaches: (1) IVT on discrete orders -- requires finiteness of intervals which needs IsSuccArchimedean (circular), (2) Direct construction-level argument about chronicle domain -- equivalent difficulty to `succ_cofinal`, (3) Scope reduction to Z-specific expressive completeness -- circular since proving the chronicle is k-equivalent to Z IS the goal.
- **Why it's stuck**: Depends on Phase 1 which is blocked.
- **What is needed**: Completion of Phase 1, then proof follows Reynolds 1994 Section 8 as documented in the sorry.
- **Prohibited workarounds**: Do NOT use `sorry`, `def X := True`, or any vacuous placeholder

**Goal**: Close the sorry at GoodStructures.lean:842. Prove that in a discrete Prior structure without endpoints, if two points are not contemporaneously equivalent, there exists a class boundary at some successor pair.

**Tasks**:
- [ ] Study the `no_gaps_discrete` signature and its caller `one_class` (GoodStructures.lean:883-906) to understand exact requirements
- [ ] Implement the proof following Reynolds 1994 Section 8:
  1. Assume `a` and `b` are in different ~M classes (¬contemp_equiv)
  2. By US expressive completeness over Prior (Phase 1), get a temporal formula R that distinguishes the k-types at `a` and `b`
  3. R holds at `a` but not at `b` (or vice versa). Since ~M is an equivalence relation, there must be a boundary: some `c` where R changes truth value between `c` and `succ(c)`
  4. This `c` satisfies: `contemp_equiv a c` (R agrees at a and c) but `not contemp_equiv a (succ c)` (R disagrees at a and succ(c))
  5. The existence of such `c` is constructive via the IVT-like argument: R changes from True to False (or vice versa) between positions where `a` is, so there must be a last position where it agrees with `a`
- [ ] Key sub-lemma: if a temporal formula has depth <= k, its truth value determines contemp_equiv membership (since contemp_equiv is defined via very_good which checks k-type profiles of subintervals)
- [ ] Key sub-lemma: in a discrete order, if a property holds at `a` but not at `b > a`, there exists `c` in [a,b) such that the property holds at `c` but not at `succ(c)` (discrete IVT / last-boundary lemma)

**Timing**: 8-12 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/GoodStructures.lean` - Replace sorry at line 842 with proof

**Verification**:
- `no_gaps_discrete` compiles with no sorry
- `one_class` compiles with no sorry (was already correct modulo `no_gaps_discrete`)
- `lean_verify Bimodal.Metalogic.WeakCanonical.no_gaps_discrete` shows no `sorryAx`
- `lake build Bimodal.Metalogic.WeakCanonical.IntegerModel.GoodStructures` passes

---

### Phase 3: New `chronicle_is_good_direct` via `one_class` + `very_good_implies_good` [COMPLETED]

**Goal**: Create a new sorry-free proof of `chronicle_is_good` that does NOT use `IsSuccArchimedean` or `orderIsoIntOfLinearSuccPredArch`. Instead, use `one_class` -> `very_good` -> `very_good_implies_good` -> `good`.

**Tasks**:
- [ ] Add a helper lemma `one_class_implies_very_good`: if all points are contemp_equiv (output of `one_class`), then the structure is `very_good` (every subinterval [a,b] is good). This follows from the definition: `contemp_equiv a b` = `very_good sig k (M.subinterval sig (min a b) (max a b))`, so for `a <= b`, `contemp_equiv a b` directly gives `good sig k (M.subinterval sig a b)`.
- [ ] Add `chronicle_prior_UZ_semantic`: discharge the `h_prior_UZ` hypothesis of `one_class` using the chronicle's `prior_UZ_valid` field. This requires showing that the MCS-level Prior-UZ axiom translates to the semantic Prior-UZ property on `chronicleAsMonadicStructure`. Uses `chronicle_temporal_truth` for the translation.
- [ ] Add `chronicle_prior_SZ_semantic`: similarly for `h_prior_SZ`
- [ ] Create `chronicle_is_good_direct`:
  ```
  chronicle_is_good_direct (M : ChronicleAsPriorModel) (sig : MonadicSignature)
      (atomMap_rev : sig.preds → Formula) (atomMap_fwd : Formula → sig.preds)
      (h_section : ...) (k : Nat) :
      good sig k (chronicleAsMonadicStructure M sig atomMap_rev)
  ```
  Proof sketch:
  1. Apply `one_class` with `atomMap_fwd` and chronicle Prior-UZ/SZ semantic hypotheses
  2. Derive `very_good` from `one_class` via `one_class_implies_very_good`
  3. Apply `very_good_implies_good` (which uses `exists_cofinal_sequence` -- needs Countable, NoMaxOrder, NoMinOrder, Nonempty, PredOrder -- all available on the chronicle domain)
- [ ] Either replace the existing `chronicle_is_good` body (which uses `orderIsoIntOfLinearSuccPredArch`) or create a parallel theorem and update the call site

**Timing**: 3-5 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/ShiftAndGlue.lean` - Replace or supplement `chronicle_is_good` at line 880
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/GoodStructures.lean` - Add `one_class_implies_very_good` helper
- Possibly `Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean` - Add chronicle Prior-UZ/SZ semantic lemmas

**Verification**:
- `chronicle_is_good_direct` compiles with no sorry
- Does NOT use `IsSuccArchimedean` or `orderIsoIntOfLinearSuccPredArch`
- `lean_verify` shows no `sorryAx`
- `lake build Bimodal.Metalogic.WeakCanonical.IntegerModel.ShiftAndGlue` passes

---

### Phase 4: Rewire `countermodel_discrete` to Reynolds Pipeline [BLOCKED]

**BLOCKER** (Phase 4):
- **What failed**: The `h_truth_corr` discharge requires `truth_at TM ... t psi <-> temporal_truth ... s psi` for all subformulas. With `zIntervalTaskFrame` (WorldState = Unit), atom valuation is position-independent (`TM.valuation () a` is constant), but `temporal_truth ... s (atom a) = Z.interp (atomMap_fwd (atom a)) s.val` is position-dependent. These cannot be equated.
- **What was tried**: (1) Position-tracking TaskFrame with `WorldState = Z` - fails because `time_shift` changes states, making singleton Omega NOT shift-closed. (2) Position-tracking with all-shifts Omega - fails because box is no longer transparent. (3) Weakening `h_truth_corr` to single point - fails because `truth_at ... t phi` for Until/Since unfolds recursively to other points.
- **Why it's stuck**: Fundamental incompatibility between three requirements: (a) shift-closed Omega (needed for ShiftClosed), (b) transparent box (needed for box = identity), (c) position-dependent atom truth (needed for truth correspondence). Any two can be satisfied but not all three simultaneously with the current TaskFrame architecture.
- **What is needed**: Either (1) restructure the countermodel to use the parametric canonical model on Z directly (requires building a BFMCS on Z with restricted coherence, which avoids `succ_embed_surjective` because Z IS succ-Archimedean), or (2) prove a "weak countermodel" theorem that only requires `NOT truth_at ... t phi` without a full truth correspondence (requires showing the specific formula phi evaluates correctly under some fixed valuation), or (3) complete Phase 1 first, which makes `chronicle_is_good` sorry-free via `orderIsoIntOfLinearSuccPredArch` (because if `no_gaps_discrete` implies the domain IS succ-Archimedean after all, the original approach works).
- **Prohibited workarounds**: Do NOT use `sorry`, `def X := True`, or any vacuous placeholder

**Goal**: Replace the `dd_countermodel_chronicle_discrete` delegation in `countermodel_discrete` (Transfer.lean:790) with the full Reynolds pipeline: chronicle extraction -> chronicle_is_good_direct -> truth_transfer -> z_interval_countermodel.

**Tasks**:
- [ ] Discharge `h_truth_corr` hypothesis of `z_interval_countermodel` *(deviation: blocked -- WorldState=Unit incompatible with position-dependent predicates; see BLOCKER above)*
- [ ] Build the complete pipeline proof in `countermodel_discrete`:
  1. Extract chronicle: `extract_chronicle_as_prior` (ChronicleExtraction.lean)
  2. Convert to monadic structure: `chronicleAsMonadicStructure` (NEquivalence.lean)
  3. Build signature and atom maps: `mkSigFrom phi`, `mkAtomMap phi` (Transfer.lean)
  4. Prove chronicle is good: `chronicle_is_good_direct` (Phase 3)
  5. Get Z-interval witness from `good`: extract the `ZIntervalStructure` and `k_equiv` proof
  6. Transfer truth of `neg phi` from chronicle to Z-interval via `truth_transfer`
  7. Need: `neg phi` is temporally true at the root point of the chronicle (from `chronicle_temporal_truth` + `h_neg_in`)
  8. Need: k >= operator_depth(phi) + 1 (choose k accordingly in the signature construction)
  9. Build countermodel from Z-interval: `z_interval_countermodel` with the Z-interval from step 5
  10. Discharge `h_truth_corr` using the construction from the first task
- [ ] Handle the section property: `mkAtomMap` returns `sig.preds -> Formula` where `p.val` is the formula; `mkSigFrom` puts the formula's `predFormulas` into the signature. Verify that `mkAtomMap (mkSigFrom phi)` is a section of the natural embedding.
- [ ] Ensure the Z-interval from `good` is unbounded (`lo = none, hi = none`). The `chronicle_is_good_direct` proof via `very_good_implies_good` produces a Z-interval via the shift-and-glue construction on the whole unbounded domain, so `lo = none` and `hi = none` should follow from the construction.

**Timing**: 4-8 hours

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean` - Rewrite `countermodel_discrete` (lines 782-790), add `h_truth_corr` discharge lemma, add pipeline assembly helpers

**Verification**:
- `countermodel_discrete` compiles with no sorry
- Does NOT delegate to `dd_countermodel_chronicle_discrete`
- `lean_verify Bimodal.Metalogic.WeakCanonical.countermodel_discrete` shows no `sorryAx`
- `lake build Bimodal.Metalogic.WeakCanonical.Transfer` passes

---

### Phase 5: Full Build Verification and Axiom Audit [NOT STARTED]

**Goal**: Verify the entire build passes and `completeness_discrete` has no `sorryAx`.

**Tasks**:
- [ ] Run `lake build` (full project build)
- [ ] Run `lean_verify Bimodal.Metalogic.BXCanonical.completeness_discrete` to check for `sorryAx`
- [ ] Run `lean_verify Bimodal.Metalogic.BXCanonical.completeness_dense` to confirm still sorry-free
- [ ] Check `#print axioms completeness_discrete` output
- [ ] If any sorries remain in the chain, trace and fix them
- [ ] Remove or mark as dead code the `domain_succ_archimedean` field of `ChronicleAsPriorModel` and `limitDomSubtype_isSuccArchimedean` if no longer used on any live path
- [ ] Update the `#print axioms` comment at Completeness.lean:374 to reflect the sorry-free status
- [ ] Update ROADMAP.md sorry count and critical path status

**Timing**: 2-3 hours

**Depends on**: 4

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` - Update axiom audit comments
- `Theories/Bimodal/Metalogic/WeakCanonical/ChronicleExtraction.lean` - Potentially remove `domain_succ_archimedean` field or mark optional
- `specs/ROADMAP.md` - Update sorry count and critical path

**Verification**:
- `lake build` passes with zero errors
- `lean_verify Bimodal.Metalogic.BXCanonical.completeness_discrete` shows NO `sorryAx`
- `#print axioms completeness_discrete` matches expected output (standard Lean axioms only)
- ROADMAP.md accurately reflects sorry-free status

---

## Testing & Validation

- [ ] `no_gaps_discrete` compiles without sorry (GoodStructures.lean)
- [ ] `one_class` compiles without sorry (GoodStructures.lean)
- [ ] `chronicle_is_good_direct` compiles without sorry and does not use `IsSuccArchimedean`
- [ ] `countermodel_discrete` compiles without sorry and does not delegate to `dd_countermodel_chronicle_discrete`
- [ ] `lean_verify Bimodal.Metalogic.WeakCanonical.countermodel_discrete` shows no `sorryAx`
- [ ] `lean_verify Bimodal.Metalogic.BXCanonical.completeness_discrete` shows no `sorryAx`
- [ ] `lake build` passes with zero errors
- [ ] No new sorries introduced anywhere in the codebase

## Artifacts & Outputs

- `specs/202_reynolds_k_equivalence_bypass/plans/01_reynolds-bypass-plan.md` (this file)
- Modified: `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/GoodStructures.lean`
- Modified: `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/ShiftAndGlue.lean`
- Modified: `Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean`
- Modified or new: `Theories/Bimodal/Metalogic/WeakCanonical/ExpressiveCompleteness/PriorExpressiveness.lean`
- Modified: `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` (comments only)
- Modified: `specs/ROADMAP.md`

## Rollback/Contingency

If the Reynolds bypass proves infeasible within the estimated effort:

1. **Partial rollback**: Revert `countermodel_discrete` to the current `dd_countermodel_chronicle_discrete` delegation. All intermediate work (expressive completeness extension, `no_gaps_discrete` partial proof) is independently valuable and should be preserved.

2. **Alternative approach**: Axiomatize `no_gaps_discrete` as a standalone axiom (add to the system as a structural property of Prior structures) and document the mathematical justification. This would eliminate `succ_cofinal` at the cost of introducing one new axiom. This is a last resort -- the goal is a proof, not an axiom.

3. **Scope reduction**: If `US_expressively_complete_over_prior` is the sole blocker, consider proving `no_gaps_discrete` for Z specifically (using `US_expressively_complete_over_Z` which is already proved) and then showing the chronicle is k-equivalent to a Z-structure at the appropriate depth. This sidesteps the Prior-structure generalization.

4. **Git recovery**: All changes are on `main`. Use `git stash` or `git revert` to roll back if needed. No branch needed since the work modifies separate functions and can be reverted per-file.
