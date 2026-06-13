# Implementation Plan: Generalized Composition Lemma with Budget Parameter (v25)

- **Task**: 273 - chronicle_gap_contradiction_proof
- **Status**: [NOT STARTED]
- **Effort**: 6 hours
- **Dependencies**: Plans v17-v22 (phases 1-4 COMPLETED), plan v23 (Phase 0 COMPLETED), plan v24 (Phases 1-2 COMPLETED, Phase 3 IN PROGRESS)
- **Research Inputs**:
  - specs/273_chronicle_gap_contradiction_proof/reports/24_blocker-research.md (round 24)
  - specs/273_chronicle_gap_contradiction_proof/reports/23_team-research.md (round 23)
  - specs/273_chronicle_gap_contradiction_proof/reports/13_team-research.md (round 13)
  - specs/273_chronicle_gap_contradiction_proof/reports/11_divergence-audit.md (postmortem constraints)
  - specs/273_chronicle_gap_contradiction_proof/reports/10_literature-transcription.md (literature grounding)
- **Artifacts**: plans/25_generalized-composition-lemma.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Plans v23-v24 failed because NfComposition.lean does induction on depth k at fixed arity 3, but the quantifier step at depth k+1 introduces a 4th variable (z), requiring arity-4 NF agreement at depth k. The IH only provides arity-3 agreement. The GHR94 syntactic separation approach (plan v24) was also blocked -- the Z-bridge cannot transfer `US_expressively_complete_over_Z` to arbitrary Prior structures due to atomMap/carrier type mismatch.

This plan fixes the root cause directly: **generalize to arbitrary arity n with a budget parameter b**, using strong induction on b. At (k+1, n) with budget b+1, the quantifier step yields (k, n+1) with budget b. The constraint k+n <= b+1 ensures the budget strictly decreases. This is the intra-structure version of the same technique already proved sorry-free in NEquivalence.lean's `build_bicompat`/`CompData` pattern for the inter-structure case.

The generalized composition lemma directly fills the 2 sorries at NfComposition.lean:113,115 by specializing to n=3, b=k+2. This cascades to fill NfCharFormula.lean:572 (`nf_2var_exist_formula_prior`) and NegationClosure.lean:1379 (`nf_exist_formula_nested_backward`), closing the Kamp chain and enabling the chronicle gap contradiction.

### Research Integration

**Reports integrated in this plan version**:
- `24_blocker-research.md`: Root cause identified -- NfComposition.lean arity-3 fixed induction fails because quantifier step needs arity-4 IH. Generalized arity-n approach with budget parameter b is the fix.
- `23_team-research.md`: VecEADecomposition.lean confirmed dead code; NF-specific Prop 4.3 bypass insufficient for k >= 1.
- `13_team-research.md`: nf_to_formula bridge exists; Lemma 3.2.2 + Prop 4.3 architecture designed.
- `11_divergence-audit.md`: Postmortem constraints remain binding (especially Deflection 4: DO NOT attempt nf_3var_from_1var_nfs directly).
- `10_literature-transcription.md`: Doets 1989 Lemma 1.4/1.5 foundation for composition.

### Prior Plan Reference

Plans v17-v22: Phases 1-4 COMPLETED (~2700 lines sorry-free vec-EA infrastructure). Plan v23: Phase 0 COMPLETED (quarantine). Plan v24: Phases 1-2 COMPLETED (Separation module, sorry-free). Phase 3 IN PROGRESS (Z-bridge blocked). Phases 4-6 NOT STARTED.

This plan supersedes v24 phases 3-6 with a direct approach. All completed phases from prior plans are preserved. The Separation module infrastructure remains available but is not required by this plan.

### Roadmap Alignment

- **Kamp chain**: Close `kamp_prior_expressive_completeness` sorry chain via generalized composition
- **Chronicle gap**: Fill `chronicle_gap_contradiction` via sorry-free model surgery pipeline
- **Critical path**: Closes two of the remaining sorry chains for `completeness_discrete`

## Goals & Non-Goals

**Goals**:
- Prove `generalized_composition`: arbitrary arity n, budget parameter b, strong induction on b
- Prove intra-structure zone matching helper for the quantifier step witness transfer
- Fill sorries at NfComposition.lean:113,115 via specialization of generalized_composition
- Cascade to fill NfCharFormula.lean:572 and NegationClosure.lean:1379
- Fill sorry at KampPrior.lean:149 (`nf_characterizable_temporal_prior` succ k case)
- Fill sorry at chronicle_gap_contradiction (ChronicleToCountermodel.lean:537)
- Pass `lake build` with zero new sorries on the critical path to `completeness_discrete`

**Non-Goals**:
- Proving the full inter-structure Feferman-Vaught composition (NEquivalence.lean already handles this)
- Modifying existing sorry-free infrastructure (phases 1-4 files, Separation module)
- Fixing VecEADecomposition.lean:285 sorry (quarantined dead code)
- Implementing the GHR94 Z-bridge (plan v24 phase 3 approach abandoned)
- Modifying StaviCompleteness.lean

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Zone matching on general linear orders is harder than on ordered sums | H | M | The zone argument only needs: "given env1 points with known order and NF types, and z fitting between them, find z' with same NF type fitting between env2 points." On a linear order, this is exactly the quantifier case of nf_agreement_monotone -- already proved sorry-free. |
| Fin n arithmetic creates universe/casting complexity | M | M | Follow the NEquivalence.lean pattern which already handles Fin-indexed environments with budget arithmetic. Reuse `Fin.cons` and `Fin.cast` patterns. |
| The 2 sorry sites at NfComposition.lean may not be the only consumers | L | L | grep confirms the dependency chain: NfComposition -> NfCharFormula -> NegationClosure -> KampPrior. No other consumers. |
| Chronicle gap Case B (constant MCS) may be non-trivial | M | M | Case B is orthogonal to Phase 1-2. If non-trivial, mark as sub-sorry with follow-up task. |

## Postmortem Constraints (from Report 11, Section 5)

These remain binding:

1. **DO NOT attempt NF-to-formula backward proofs by extracting NF data from formula truth** (Deflection 1). This plan works at the NF composition level, not formula level.
2. **DO NOT use depth-k characteristic formulas where depth-(k+1) is needed** (Deflection 2). The budget parameter ensures correct depth tracking.
3. **DO NOT encode negative interval conditions as guards that block legitimate witnesses** (Deflection 3).
4. **DO NOT attempt to prove nf_3var_from_1var_nfs at fixed arity** (Deflection 4). This plan generalizes to arbitrary arity, which is the fix.
5. **DO NOT cycle between formula-level and NF-level fixes** (Deflection 5). This plan commits to the NF-level (composition) approach exclusively.

## Lemma-to-Literature Mapping

| Phase | Lean Definition/Lemma | Literature Source | Notes |
|-------|----------------------|-------------------|-------|
| 1 | `zone_witness_transfer` | Doets 1989, Lemma 1.4 | Intra-structure: given z with known NF type in a zone between env1 points, find z' in corresponding zone between env2 points with same NF type |
| 1 | `generalized_composition` | Doets 1989, Lemma 1.5 / Composition method | Strong induction on budget b, arbitrary arity n |
| 2 | `nf_3var_from_1var_nfs` fill | Specialization of generalized_composition | n=3, b=k+2 |
| 2 | `nf_2var_exist_formula_prior` fill | Cascades from NfComposition fix | NfCharFormula.lean:572 |
| 2 | `nf_exist_formula_nested_backward` fill | Cascades from NfCharFormula fix | NegationClosure.lean:1379 |
| 2 | `nf_characterizable_temporal_prior` succ k | Cascades from NegationClosure fix | KampPrior.lean:149 |
| 3 | `chronicle_gap_contradiction` fill | Reynolds 1994, Lemmas 6-13 | Via sorry-free model surgery pipeline |

### Preserved Assets (from v21/v22/v23 phases 0-4, sorry-free)

| File | Lines | Status | Content |
|------|-------|--------|---------|
| VecEAFormula.lean | ~600 | SORRY-FREE | Vec-EA types + evaluation |
| VecEAClosure.lean | ~400 | SORRY-FREE | Closure properties |
| VecEATranslation.lean | ~350 | SORRY-FREE | V-EA to temporal translation |
| NegationClosure5.lean | ~800 | SORRY-FREE | Section 5 lemmas |
| NegationClosureProp42.lean | ~350 | SORRY-FREE | Prop 4.2 negation closure |
| FoToVecEA.lean | ~200 | SORRY-FREE | Bridge theorems |
| Translation.lean | ~337 | SORRY-FREE | Prop 3.5 temporal translation |
| PriorINF.lean | ~194 | SORRY-FREE | Prior first/last occurrence |
| GoodStructuresModelSurgery.lean | ~2000 | SORRY-FREE | Reynolds model surgery core |
| Separation/ (all files) | ~47K+ | SORRY-FREE | GHR94 separation theorem + bridge |

### Quarantined Assets

| File | Lines | Status | Reason |
|------|-------|--------|--------|
| VecEADecomposition.lean | ~310 | QUARANTINED | Dead code, not on critical path |

### Reusable Infrastructure (directly relevant to this plan)

| Definition | File | Line | Status | Role |
|-----------|------|------|--------|------|
| `pred_agree_of_1var_nf_eq` | NfComposition.lean | 27 | SORRY-FREE | Predicates agree if 1-var NFs agree |
| `nf_characteristic_satisfies` | NormalForm.lean | 224 | SORRY-FREE | Characteristic NF satisfies nf_eval |
| `nf_eval_unique` | NormalForm.lean | 245 | SORRY-FREE | NF satisfying evaluation is unique |
| `nf_exists_unique` | NormalForm.lean | 277 | SORRY-FREE | Unique NF exists for each (M, env) |
| `nf_agreement_monotone` | NormalForm.lean | 339 | SORRY-FREE | Depth monotonicity for NF agreement |
| `nf_agreement_from_shared_nf` | NormalForm.lean | 291 | SORRY-FREE | Shared NF implies full agreement |
| `component_extend_fwd` | NEquivalence.lean | 187 | SORRY-FREE | Witness extension for inter-structure case |
| `BiCompat`/`build_bicompat` | NEquivalence.lean | 160/475 | SORRY-FREE | Budget-based induction pattern (inter-structure) |
| `nf_3var_from_1var_nfs` k=0 case | NfComposition.lean | 66-83 | SORRY-FREE | Base case already proved |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |

Phases are fully sequential. Each phase builds on the prior.

---

### Phase 1: Generalized Composition Lemma [BLOCKED]

**BLOCKER** (Phase 1):
- **What failed**: The theorem `generalized_composition` as stated is **FALSE** for n >= 2 on general linear orders.
- **Counterexample**: M = (Z, <) with no predicates, env1 = (0, 2), env2 = (0, 1), k = 1. All integers have the same depth-k 1-var NF for all k (by translation symmetry). Orders match: 0 < 2 iff 0 < 1. But depth-1 2-var NFs differ: the zone "strictly between the two points" is nonempty for (0, 2) (contains 1) but empty for (0, 1) (no integer between 0 and 1). The depth-0 3-var NF type "env[0] < z < env[1]" is realized for (0, 2) but not for (0, 1).
- **What was tried**: (1) h_nf at depth k+1 (original statement). (2) h_nf at depth k+n (budget parameter). (3) h_nf at depth k+n+1. (4) h_nf at depth 2k+n. (5) Budget-based strong induction. (6) Double induction on k and n. (7) Inner induction on n. (8) Using component_extend_fwd with M=M. (9) Extracting z' from individual env points' NFs. ALL approaches fail because: (a) each witness extraction from an env point's NF costs 1 depth level, and (b) more fundamentally, no depth of 1-var NFs can encode the zone structure between env points in a single linear order.
- **Why the theorem is false**: On a general linear order, matching 1-var NFs + matching orders does NOT imply matching n-var NFs for n >= 2. The 2-var NF encodes whether the zone between two points is empty or non-empty, which is NOT captured by individual 1-var NFs or pairwise orders. Increasing the depth of h_nf does not help because all integers have identical 1-var NFs at every depth.
- **Resolution**: The false theorem was removed from NfComposition.lean. In its place, `intra_structure_extend` and `intra_structure_extend_bwd` were proved sorry-free. These are the intra-structure analogs of `component_extend_fwd/bwd` from NEquivalence.lean: given depth-(K+1) n-var NF agreement, for any z there exists z' with depth-K (n+1)-var NF agreement. These require FULL n-var NF agreement as hypothesis (not just 1-var NFs).
- **Next steps**: (a) The downstream sorry at NfCharFormula.lean:572 (`nf_2var_exist_formula_prior`) does NOT depend on `generalized_composition` -- it is about constructing a characteristic formula, which is a separate problem. (b) The intra-structure composition theorem (from 1-var NFs to n-var NFs) likely requires an EF-game-based proof or a formula-level argument via `doets_lemma_1_1`. (c) NfComposition.lean is not imported by any other file, so this change has no downstream impact.
- **Prohibited**: Do NOT use sorry, def X := True, or vacuous placeholder.

**Goal**: Prove the generalized composition theorem for arbitrary arity n with budget parameter b, using strong induction on b. This is the intra-structure analog of the `build_bicompat`/`CompData` pattern in NEquivalence.lean.

**Mathematical Argument**:

```
theorem generalized_composition (M : OrderedMonadicStructure sig) :
    forall (b k n : Nat) (h : k + n <= b + 1)
    (env1 env2 : Fin n -> M.carrier)
    (h_nf : forall i : Fin n, nf_characteristic M b 1 (fun _ => env1 i) =
                               nf_characteristic M b 1 (fun _ => env2 i))
    (h_ord : forall i j : Fin n, i != j ->
             (env1 i < env1 j <-> env2 i < env2 j)),
    nf_characteristic M k n env1 = nf_characteristic M k n env2
```

**Why the budget parameter works**: At (k+1, n) with budget b+1, the quantifier step introduces z giving (k, n+1). Check constraint: from k+1+n <= b+2, we get k+(n+1) = k+n+1 <= b+1. The budget b strictly decreases from b+1 to b. The strong induction hypothesis at budget b gives us the result at (k, n+1).

**Zone matching (intra-structure) for witness transfer**: Given z with known depth-b 1-var NF and order position relative to env1 points, the depth-(b+1) 1-var NF of each env1[i] encodes that NF type is realized in the relevant zone. Since env2[i] has the same depth-(b+1) 1-var NF, the same NF type is realized in the corresponding zone around env2[i]. On a linear order, zones relative to multiple reference points intersect correctly.

**Tasks**:
- [ ] **Task 1.1**: Define `zone_witness_transfer` helper: given z in M.carrier with env1 points having matching 1-var NFs and matching order to env2 points, produce z' in M.carrier with the same depth-b 1-var NF as z and the same order relations to env2 as z has to env1. Uses the quantifier case of `nf_characteristic` at depth b+1 for the 1-var NFs of env1[i]/env2[i], which encode existence of elements with specific depth-b 1-var NFs in each zone. (~80-120 lines)
- [ ] **Task 1.2**: Prove `generalized_composition` by strong induction on b. Base case (k=0): only atom part, use `pred_agree_of_1var_nf_eq` and order hypothesis (similar to existing k=0 case at NfComposition.lean:66-83 but for arbitrary n). Inductive step (k+1): atom part as in base case; quantifier part uses `zone_witness_transfer` to produce z' from z, then applies IH at budget b with (k, n+1). (~120-180 lines)
- [ ] **Task 1.3**: Verify `generalized_composition` compiles sorry-free. Run `lake build` on the module.

**Timing**: 3 hours (~200-300 lines)

**Depends on**: none

**Files to create/modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfComposition.lean` -- replace the sorry'd `nf_3var_from_1var_nfs` succ k case with generalized_composition and a specialization. Keep `pred_agree_of_1var_nf_eq` (sorry-free), remove `classical_decide_eq_of_iff` (only used by old approach), replace `nf_3var_from_1var_nfs` body with a call to the generalized version.

**Verification**:
- `lean_verify generalized_composition` shows no sorryAx
- `lean_verify nf_3var_from_1var_nfs` shows no sorryAx (now a corollary)
- `lake build Bimodal.Metalogic.WeakCanonical.Kamp.NfComposition` succeeds with 0 sorries

**Implementation Notes**:
- The atom part at each depth is straightforward: predicates via `pred_agree_of_1var_nf_eq` (extending to Fin n via the env hypothesis), order atoms via `h_ord` directly. The existing `classical_decide_eq_of_iff` helper may be retained or inlined.
- For the quantifier part, the key step is: given `exists z, nf_eval_nf M k (n+1) (Fin.cons z env1) sub_nf`, extract z, use `zone_witness_transfer` to find z', then apply the IH at budget b to show `nf_eval_nf M k (n+1) (Fin.cons z' env2) sub_nf`.
- The `zone_witness_transfer` argument uses: (1) z has a depth-b 1-var NF `nf_characteristic M b 1 (fun _ => z)`. (2) For each env1[i], the depth-(b+1) 1-var NF encodes which depth-b 1-var NF types are realized in each zone (above/below). (3) Since env2[i] has the same depth-(b+1) 1-var NF, the same type is realized in the corresponding zone. (4) z' is obtained from the existential in the quantifier part of env2[i]'s depth-(b+1) 1-var NF.
- The constraint `k + n <= b + 1` ensures `k + (n+1) <= b + 1` when we step from b+1 to b and from k+1 to k: from `(k+1) + n <= (b+1) + 1` we get `k + (n+1) <= b + 1 + 1`, which means we need IH at budget b with `k + (n+1) <= b + 1`. Check: `k + n + 1 <= b + 2` gives `k + n <= b + 1`, so `k + (n+1) = k + n + 1 <= b + 2` -- wait, we need `k + (n+1) <= b + 1`. From `(k+1) + n <= (b+1) + 1`, i.e., `k + n + 1 <= b + 2`, we get `k + n <= b + 1`, hence `k + (n+1) = k + n + 1 <= b + 2`. But IH requires `k + (n+1) <= b + 1`. This holds iff `k + n + 1 <= b + 1`, i.e., `k + n <= b`. From our assumption `(k+1) + n <= (b+1) + 1`, we get `k + n <= b + 1`. So we need one more: the IH at budget b requires `k + (n+1) <= b + 1`, which is `k + n + 1 <= b + 1`, i.e., `k + n <= b`. But we only have `k + n <= b + 1`. Resolution: use `k + n <= b` as the constraint instead, or use a different budget formulation. The precise constraint should be `k + n <= b` (not `b + 1`), ensuring the quantifier step `k + (n+1) <= b` holds from `(k+1) + n <= b`, which is strictly weaker than `(k+1) + n + 1 <= b + 1`. The implementation must validate the exact constraint during Task 1.2.

---

### Phase 2: Wire into Sorry Sites + Fill Kamp Chain [NOT STARTED]

**Goal**: Specialize `generalized_composition` to fill the sorry at NfComposition.lean:113,115 (n=3 case), and verify that this cascades to close `nf_2var_exist_formula_prior` (NfCharFormula.lean:572), `nf_exist_formula_nested_backward` (NegationClosure.lean:1379), and `nf_characterizable_temporal_prior` succ k (KampPrior.lean:149).

**Tasks**:
- [ ] **Task 2.1**: Replace the sorry'd body of `nf_3var_from_1var_nfs` succ k case (NfComposition.lean:108-115) with a call to `generalized_composition`. Specialization: set n=3, b=k+2 (so k+3 <= k+2+1 = k+3, satisfying the constraint). The 1-var NF hypotheses h_y, h_x, h_t map to h_nf for Fin 3, and h_ord maps directly. (~20-30 lines)
- [ ] **Task 2.2**: Fill `nf_2var_exist_formula_prior` (NfCharFormula.lean:572). With `nf_3var_from_1var_nfs` sorry-free, the downstream proof should type-check. Verify with `lean_verify nf_2var_exist_formula_prior`. If the sorry remains (because the dependency is not automatic), trace the dependency chain and provide the explicit fill. (~10-30 lines)
- [ ] **Task 2.3**: Fill `nf_exist_formula_nested_backward` (NegationClosure.lean:1379). This calls into `nf_2var_exist_formula_prior` or `nf_3var_from_1var_nfs`. Verify with `lean_verify nf_exist_formula_nested_backward`. (~0-20 lines)
- [ ] **Task 2.4**: Verify KampPrior.lean:149 (`nf_characterizable_temporal_prior` succ k) is now sorry-free. The chain: `nf_characterizable_temporal_prior` -> `nf_characterizable_temporal_prior_classical` -> `nf_2var_exist_formula_prior`. If all upstream sorries are filled, this should compile. Verify with `lean_verify nf_characterizable_temporal_prior`. (~0 lines if cascade works)
- [ ] **Task 2.5**: Verify the full Kamp chain: `lean_verify kamp_prior_expressive_completeness` and `lean_verify US_expressively_complete_over_prior` show no sorryAx.

**Timing**: 1.5 hours (~50-100 lines modification)

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfComposition.lean` -- fill succ k case of `nf_3var_from_1var_nfs`
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfCharFormula.lean` -- fill sorry at line 572 (if not automatic)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NegationClosure.lean` -- fill sorry at line 1379 (if not automatic)

**Verification**:
- `lean_verify nf_3var_from_1var_nfs` shows no sorryAx
- `lean_verify nf_2var_exist_formula_prior` shows no sorryAx
- `lean_verify nf_exist_formula_nested_backward` shows no sorryAx
- `lean_verify nf_characterizable_temporal_prior` shows no sorryAx
- `lean_verify kamp_prior_expressive_completeness` shows no sorryAx
- `lake build Bimodal.Metalogic.WeakCanonical.Kamp.KampPrior` succeeds with 0 sorries

---

### Phase 3: Chronicle Gap Contradiction + Full Verification [NOT STARTED]

**Goal**: Fill `chronicle_gap_contradiction` (ChronicleToCountermodel.lean:537) using the now-sorry-free model surgery pipeline, then verify end-to-end build.

**Literature**: Reynolds 1994, Section 7 (Lemmas 6-13), implemented in GoodStructuresModelSurgery.lean (sorry-free).

**Tasks**:
- [ ] **Task 3.1**: Activate and fix the OLD PROOF block (ChronicleToCountermodel.lean:539-813).
  - **Case A** (limit_f(a) != limit_f(b)): 95% complete. Fix the k=0 -> k >= 1 issue at line 792. Use k=1 for `contemp_equiv`. Prove `neg contemp_equiv sig 1 M a b` using a distinguishing formula psi at depth 1: the 1-var NF at a includes psi while at b it does not, giving depth-1 NF disagreement. Apply `gap_contradicts_prior` with semantic_prior_UZ/SZ (proved at lines 687-754). (~30 lines)
  - **Case B** (limit_f(a) = limit_f(b)): Symmetric case at line 812. Either prove Case B is vacuously impossible in Prior structures, or provide a direct chronicle-specific argument. If Case B requires a separate deep investigation, mark it as a sub-sorry with a comment and create a follow-up task. (~50 lines or ~5 lines if vacuously impossible)
- [ ] **Task 3.2**: Fix the stale header comment at ChronicleToCountermodel.lean:65-77 to reflect current status. (~10 lines)
- [ ] **Task 3.3**: Run `lake build` (full project) -- must succeed with 0 errors.
- [ ] **Task 3.4**: Verify axiom checks:
  - `lean_verify kamp_prior_expressive_completeness` -- no sorryAx
  - `lean_verify US_expressively_complete_over_prior` -- no sorryAx
  - `lean_verify chronicle_gap_contradiction` -- no sorryAx
  - `lean_verify completeness_discrete` -- remaining sorryAx should trace ONLY through Task 202 chain (succ_cofinal)
- [ ] **Task 3.5**: Mark bypass comments on dead code:
  - NfComposition.lean header: update to reflect sorry-free status
  - NegationClosure.lean:1371: update comment to reflect resolved status
  - VecEADecomposition.lean: retain quarantine status (not on critical path)
- [ ] **Task 3.6**: Update ROADMAP.md: mark Kamp chain complete, chronicle gap filled.

**Timing**: 1.5 hours (~80-100 lines modification + verification)

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- activate OLD PROOF, fill sorries, fix header
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfComposition.lean` -- update header comment
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NegationClosure.lean` -- update bypass comment at :1371

**Verification**:
- `lean_verify chronicle_gap_contradiction` shows no sorryAx
- `lake build` succeeds (full project, clean)
- `lean_verify completeness_discrete` -- remaining sorryAx traces only through Task 202 chain

**Implementation Notes**:
- `chronicle_gap_contradiction` calls `gap_contradicts_prior` which depends on `US_expressively_complete_over_prior` via the model surgery pipeline. Phase 2 must be complete first.
- The OLD PROOF's semantic_prior_UZ/SZ proofs (lines 621-754) are independent of Kamp and are sorry-free. They build the OrderedMonadicStructure on LimitDomSubtype and prove Prior-UZ/SZ using the chronicle's C4/C5 coherence.
- ChronicleToCountermodel.lean:218 and :374 (`succ_reaches_dom_N` boundary sorries) are dead code -- do NOT attempt to fill them.

---

## Testing & Validation

- [x] Phase 1 (v21): Vec-EA type definitions compile, universe-correct (DONE)
- [x] Phase 2 (v21): Closure lemmas sorry-free (DONE)
- [x] Phase 3 (v21): Translation correctness sorry-free (DONE)
- [x] Phase 4 (v22): All negation closure sub-phases sorry-free (DONE)
- [x] Phase 0 (v23): Preconditions verified, VecEADecomposition quarantined (DONE)
- [x] Phase 1 (v24): All 8 elimination cases + duals sorry-free (EXISTING: Separation/Eliminations.lean)
- [x] Phase 2 (v24): Separation theorem sorry-free (EXISTING: Separation/SeparationThm.lean)
- [ ] Phase 1 (v25): generalized_composition sorry-free, zone_witness_transfer sorry-free
- [ ] Phase 2 (v25): nf_3var_from_1var_nfs sorry-free, full Kamp chain closed (no sorryAx on kamp_prior_expressive_completeness)
- [ ] Phase 3 (v25): chronicle_gap_contradiction sorry-free, `lake build` clean, axiom checks pass

## Artifacts & Outputs

**Existing (phases 1-4 from v21/v22, sorry-free)**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/VecEAFormula.lean` (~600 lines)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/VecEAClosure.lean` (~400 lines)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/VecEATranslation.lean` (~350 lines)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NegationClosure5.lean` (~800 lines)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NegationClosureProp42.lean` (~350 lines)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/FoToVecEA.lean` (~200 lines)

**Modified (v25)**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfComposition.lean` -- generalized_composition + fill sorries (~200-300 lines new/modified)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfCharFormula.lean` -- fill sorry at :572 (~10-30 lines)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NegationClosure.lean` -- fill sorry at :1379 (~0-20 lines)
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- activate OLD PROOF, fill sorries (~80-100 lines)

**Estimated new Lean code**: ~300-450 lines across all files

## Rollback/Contingency

**If the budget parameter constraint arithmetic doesn't work out**:
- Try alternative formulation: `generalized_composition (b : Nat) (k n : Nat) (h : k + n <= b)` with induction on b, where the quantifier step goes from b to b-1 with k-1+(n+1) = k+n <= b-1+1 = b. This is equivalent but may have cleaner omega arithmetic.
- Fallback: use well-founded recursion on (b, k, n) triple with lexicographic ordering instead of simple Nat induction on b.

**If zone_witness_transfer is harder than expected**:
- The zone argument can be simplified by noting that on a single linear order, the quantifier case of depth-(b+1) 1-var NF already provides exactly the witness transfer we need: `nf_characteristic M (b+1) 1 (fun _ => env1[i])` encodes `exists z, nf_characteristic M b 1 (fun _ => z) = tau AND z < env1[i]` (or z > env1[i]). Since env2[i] has the same depth-(b+1) NF, the same existential holds.
- If multi-zone intersection is problematic, note that we only need z' to have (1) the same depth-b 1-var NF as z, and (2) the same order relations to env2 as z has to env1. Condition (2) is a conjunction of `<` or `>` conditions, and the depth-(b+1) NFs encode which NF types are realized in each single zone. The intersection of zones is non-empty by the order compatibility of env2 (matching order to env1).

**If the cascade from NfComposition to NfCharFormula/NegationClosure/KampPrior doesn't propagate automatically**:
- Trace the dependency chain manually. The likely issue is that `nf_2var_exist_formula_prior` (NfCharFormula.lean:572) has its own sorry independent of NfComposition. In that case, Phase 2 Task 2.2 provides the explicit fill using `nf_3var_from_1var_nfs` or `generalized_composition` directly.

**If Phase 3 Case B (constant MCS) is genuinely non-trivial**:
- Mark Case B as a separate sorry with a TODO comment
- Create a follow-up task for Case B investigation
- The rest of the chain (Case A + Kamp chain) still closes the critical path significantly

**If the approach fails entirely**:
- All existing sorry-free code (~2700+ lines) remains valid
- The generalized composition, even if partially implemented, provides infrastructure for future attempts
- Consider the Z-bridge approach from plan v24 Phase 3 as an alternative path (requires resolving the atomMap/carrier type mismatch)
