# Implementation Plan: Bypass-Based Enriched Formula Construction (v29)

- **Task**: 273 - chronicle_gap_contradiction_proof
- **Status**: [NOT STARTED]
- **Effort**: 6 hours
- **Dependencies**: Plans v17-v22 (phases 1-4 COMPLETED), plan v23 (Phase 0 COMPLETED), plan v24 (Phases 1-2 COMPLETED), plan v26 (Phases 1-2 COMPLETED, Phase 3 all options blocked), plan v28 (Phase 1 COMPLETED, Phase 2 BLOCKED). Rabinovich infrastructure (4 files, 1349+ lines, sorry-free core). NfToVecEA.lean (700+ lines, depth-0 sorry-free, bracketBuildLeft_correct sorry-free).
- **Research Inputs**:
  - specs/273_chronicle_gap_contradiction_proof/reports/27_wiring-strategy-research.md (round 27, bypass feasibility + arity-climbing insight)
  - specs/273_chronicle_gap_contradiction_proof/reports/26_literature-proof-walkthrough.md (round 26, Path B recommendation)
  - specs/273_chronicle_gap_contradiction_proof/reports/25_formula-construction-research.md (round 25, formula construction)
  - specs/273_chronicle_gap_contradiction_proof/reports/24_blocker-research.md (round 24, root blocker)
  - specs/273_chronicle_gap_contradiction_proof/reports/23_team-research.md (round 23, VecEADecomposition dead code)
  - specs/273_chronicle_gap_contradiction_proof/reports/13_team-research.md (round 13, nf_to_formula bridge)
  - specs/273_chronicle_gap_contradiction_proof/reports/11_divergence-audit.md (postmortem constraints)
  - specs/273_chronicle_gap_contradiction_proof/reports/10_literature-transcription.md (literature grounding)
  - specs/literature/Rabinovich_2014_Proof_of_Kamps_Theorem.md (Section 5 -- primary reference)
- **Artifacts**: plans/29_bypass-enriched-formula.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Plan v28 Phase 1 (bracketBuildLeft_correct) is COMPLETED. Phase 2 is BLOCKED because the NF-to-VecEA2 bridge at depth k+1 requires expressing 3-var existentials at depth k as temporal formulas, which itself requires arity-climbing composition -- the same fundamental blocker in a different form.

Report 27 discovered the critical structural insight: the sorry at `nf_2var_exist_formula_prior` (NfCharFormula.lean:610) requires only `exists A` (existential), NOT a specific formula. The current proof commits to `A = nf_exist_formula ...` at k+1 (line 643), but we can provide a DIFFERENT formula that encodes all quantifier conditions directly. This plan constructs such a formula by induction on k with n (arity) as a parameter, matching Rabinovich 2014 Section 5's P_n(k) generalization.

The key mathematical insight: at depth k+1 with 2 variables (x, t), the 3-var quantifier conditions involve depth-k 3-var existentials. These are themselves P_3(k) instances. By the induction hypothesis at depth k (for ALL arities), these have temporal formulas. At depth 0 for all arities, existPart_zero is sorry-free (RabinovichGeneralized.lean:183). The induction terminates because depth strictly decreases.

This plan does NOT modify `nf_exist_formula`, `nf_exist_formula_nested`, or any existing sorry-free infrastructure. It provides a new proof path via the `exists A` bypass.

### Research Integration

**Reports integrated in this plan version**:
- `27_wiring-strategy-research.md`: Bypass feasibility confirmed (exists A allows any formula). VecEADecomp handles depth-0 only. Arity-generalization P_n(k) identified as the correct approach matching Rabinovich Section 5. Import cycle analysis: VecEADecomp can be imported by NfCharFormula without cycles.
- `26_literature-proof-walkthrough.md`: Path B (Rabinovich VecEA pipeline) recommended. bracketBuildLeft_correct now sorry-free (Phase 1 completed in v28). neg_2var_vec_ea is sorry-free (Prop 4.2).
- `25_formula-construction-research.md`: All three bridge options (A/B/C) reduce to composition. generalized_composition proved FALSE with clean counterexample. Formula-level bypass is the remaining option.

### Prior Plan Reference

Plans v17-v22: Phases 1-4 COMPLETED (~2700 lines sorry-free vec-EA infrastructure). Plan v23: Phase 0 COMPLETED (quarantine). Plan v24: Phases 1-2 COMPLETED (Separation module, sorry-free). Plan v26: Phases 1-2 COMPLETED (existPart_zero all n, existPart_succ factored). Plan v27: Phases 1-2 COMPLETED (confirmed Prop 4.2 sorry-free, no new code needed). Plan v28: Phase 1 COMPLETED (bracketBuildLeft_correct Since-direction sorry-free); Phase 2 BLOCKED (bridge requires arity-climbing composition).

This plan replaces v28 phases 2-3 with a 4-phase strategy that directly constructs an enriched bypass formula via induction on k with arity n as parameter.

### Roadmap Alignment

- **Kamp chain**: Close `kamp_prior_expressive_completeness` via enriched bypass formula filling `nf_2var_exist_formula_prior` at k+1
- **Chronicle gap**: Fill `chronicle_gap_contradiction` once the Kamp chain is sorry-free
- **Critical path**: Closes two of the remaining sorry chains for `completeness_discrete`

## Goals & Non-Goals

**Goals**:
- Define `nf_nvar_exist_formula_prior` -- a generalized P_n(k) theorem stating that for ALL arities n >= 1 and ALL depths k, the (n+1)-var existential has a temporal characterization on Prior structures. This fills `ExistPart` at all depths.
- Fill `nf_2var_exist_formula_prior` (NfCharFormula.lean:610) at k+1 by instantiating P_2(k+1) from the generalized theorem.
- Fill `existPart_succ` (RabinovichGeneralized.lean:446, :474) by instantiating P_n(k+1) from the generalized theorem.
- Verify `kamp_prior_expressive_completeness` and `completeness_discrete` sorry chains improve.
- Fill `chronicle_gap_contradiction` if unblocked by the Kamp chain closure.

**Non-Goals**:
- Filling NegationClosure.lean:1716 (`nf_exist_formula_nested_backward`) -- the bypass makes this unnecessary.
- Filling NegationClosure.lean:1327 (zone compatibility `all_goals sorry`) -- not on critical path.
- Modifying `nf_exist_formula` or `nf_exist_formula_nested` -- these remain as-is.
- Modifying any existing sorry-free infrastructure (VecEATranslation, NegationClosureProp42, VecEAClosure, NfToVecEA, etc.).
- Proving the GHR94 separation property (Path A -- rejected as too expensive).

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Lean dependent type issues with variable-arity Fin-indexed environments | H | M | The arity parameter n appears in `Fin n -> M.carrier` environments. At each induction step on k, arity increases by 1. Lean's Fin arithmetic may need explicit `Fin.cons` / `Fin.castSucc` gymnastics. Mitigate by working with explicit environment manipulations via helper lemmas. |
| Enriched formula at depth k+1 requires encoding positive/negative quantifier conditions for ALL arity-(n+1) sub-NFs simultaneously | M | L | The conjunction is finite (over `NormalForm sig k (n+2) -> Bool`). Use `formula_conjList` over `Fintype.elems`. Negative conditions use `neg_2var_vec_ea` (Prop 4.2, sorry-free) for n=1 and classical existence for higher arities. |
| Backward direction of the enriched formula proof requires extracting quantifier profile from formula truth | H | M | This is the core difficulty. The enriched formula explicitly encodes each quantifier condition as a conjunct, so extraction is straightforward conjunction elimination -- unlike `nf_exist_formula` which does NOT encode quantifier conditions. The enriched formula is designed to make backward extraction trivial. |
| New file may create import cycle | L | L | Import analysis (report 27): VecEADecomp is strictly below NfCharFormula in the import graph. The new file (KampBypass.lean) imports NfToVecEA and VecEADecomp (both below NfCharFormula), and NfCharFormula imports KampBypass. No cycle. |
| Chronicle gap Case B (constant MCS) non-trivial | M | M | Orthogonal to Phases 1-3. If non-trivial, mark as sub-sorry with follow-up task. |

## Postmortem Constraints (from Report 11, Section 5)

These remain binding:
1. **DO NOT attempt NF-to-formula backward proofs by extracting NF data from formula truth** (Deflection 1) -- NOTE: The enriched formula bypass AVOIDS this by encoding quantifier data directly in the formula, making extraction trivial.
2. **DO NOT use depth-k characteristic formulas where depth-(k+1) is needed** (Deflection 2)
3. **DO NOT encode negative interval conditions as guards that block legitimate witnesses** (Deflection 3)
4. **DO NOT attempt to prove nf_3var_from_1var_nfs at fixed arity** (Deflection 4) -- NOTE: The generalized P_n(k) approach avoids fixed-arity by parameterizing over n.
5. **DO NOT cycle between formula-level and NF-level fixes** (Deflection 5)

## Sorry Inventory (Current State)

| File | Line | Statement | Status | This Plan |
|------|------|-----------|--------|-----------|
| NfToVecEA.lean | 472 | bracketBuildLeft_correct forward (Since, n>0) | FILLED (v28 Ph1) | Preserved |
| NfToVecEA.lean | 475 | bracketBuildLeft_correct backward (Since, n>0) | FILLED (v28 Ph1) | Preserved |
| NfCharFormula.lean | 540 | nf_exist_backward_prior (k+1 case) | SORRY | Phase 3 bypasses (fill via enriched formula at line 610) |
| NfCharFormula.lean | 610 | nf_2var_exist_formula_prior (k+1 case) | SORRY | Phase 3 fills via new bypass formula |
| RabinovichNegation.lean | 291 | nf_2var_exist_formula_prior_neg (k'+1 case) | SORRY | Phase 3 fills (same approach) |
| RabinovichGeneralized.lean | 446 | existPart_succ n=1 | SORRY | Phase 3 fills via generalized P_n(k) |
| RabinovichGeneralized.lean | 474 | existPart_succ n>=2 | SORRY | Phase 3 fills (follows from n=1) |
| NegationClosure.lean | 1716 | nf_exist_formula_nested_backward | SORRY | BYPASSED (not needed) |
| NegationClosure.lean | 1327 | zone compatibility all_goals sorry | SORRY | NOT on critical path (preserved) |
| ChronicleToCountermodel.lean | 224 | succ_reaches_dom_N boundary | SORRY | Dead code (NOT filled) |

### Existing Infrastructure (sorry-free, DO NOT TOUCH)

| File | Lines | Content |
|------|-------|---------|
| VecEAFormula.lean | -- | VecEA2 types |
| VecEATranslation.lean | 302 | Prop 3.5: ExistsForallSpec -> TL(U,S), bracketBuildRight_correct |
| NegationClosureProp42.lean | -- | Prop 4.2: neg_2var_vec_ea |
| PriorINF.lean | -- | Prior INF/SUP |
| VecEAClosure.lean | -- | VecEA closure |
| NfToVecEA.lean | 700+ | NF-to-VecEA depth 0 + bracketBuildLeft_correct (all n, sorry-free) |
| RabinovichGeneralized.lean | ~470 | ExistPart(0) all n, forward direction |
| NegationClosure.lean | -- | Forward direction all k |
| RabinovichTranslation.lean | 302 | Prop 3.5 translate_correct |
| RabinovichNegation.lean | 297 | Backward k=0 |
| NfComposition.lean | 267 | intra_structure_extend |
| SeparationBridge.lean | ~199 | neg_until_equiv_prior, neg_since_equiv_prior |
| VecEADecomp.lean | 898 | Depth-0 3-var zone decomposition |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |

Phases are fully sequential. Each phase builds on the prior.

---

### Phase 1: Define generalized enriched formula P_n(k) [COMPLETED]

**Goal**: Define the enriched temporal formula for (n+1)-var existentials at depth k, by induction on k with n as parameter. This is the core construction.

**Mathematical Content**:

The enriched formula for `exists x, nf_eval_nf M k (n+1) (Fin.cons x env) sub_nf` is constructed as:

- **Base case k=0**: At depth 0, NFs are purely atomic (no quantifier conditions). The existential reduces to zone analysis (order of x relative to env elements) plus predicate matching. Use `existPart_zero` (sorry-free) or the VecEA2 translation (for n=1, via `nf_2var_exist_depth0_tl`).

- **Step case k+1**: At depth k+1, `sub_nf : NormalForm sig (k+1) (n+1)` has:
  - `sub_nf.1 : AtomKind sig (n+1) -> Bool` (predicates + orders)
  - `sub_nf.2 : NormalForm sig k (n+2) -> Bool` (quantifier profile)

  The enriched formula A is `Until(enriched_point_type, top)` (for x > env(0)) or `Since(enriched_point_type, top)` (for x < env(0)), where:

  `enriched_point_type` at x = `char_{k+1}(nf_x)` /\ conjunction of quantifier encodings:
  - For each ssn with sub_nf.2(ssn) = true: `Phi_ssn` where `Phi_ssn` is the IH formula for `exists y, nf_eval_nf M k (n+2) (Fin.cons y (Fin.cons x env)) ssn`. This is P_{n+1}(k) -- the IH at depth k with arity n+1.
  - For each ssn with sub_nf.2(ssn) = false: `neg Phi_ssn` where `Phi_ssn` is the same IH formula. The negation is valid because `Phi_ssn <-> exists y ...` and we need `not (exists y ...)`.

  The disjunction over all atom-compatible nf_x profiles and over all zone cases (x > env(0), x < env(0), x = env(0)) gives the full formula.

**Key design decision**: The IH at depth k gives `exists (Phi : Formula), forall M ..., temporal_truth M atomMap t Phi <-> exists y, nf_eval_nf M k (n+2) ...`. We use `Classical.choose` to extract the formula `Phi_ssn` at each ssn. This is sound because the theorem is purely existential.

**Tasks**:
- [ ] **Task 1.1**: Create new file `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampBypass.lean`. Import NfToVecEA, VecEADecomp, NfCharFormula (for `nf_exist_formula_forward'`), RabinovichGeneralized (for `existPart_zero`). Define the statement of the generalized theorem:
  ```
  theorem nf_nvar_exist_formula_bypass : forall k n (hn : n >= 1),
    forall char_k char_k_correct parent_atoms (sub_nf : NormalForm sig k (n+1)),
    exists A, forall M h_UZ h_SZ (env : Fin n -> M.carrier),
      (atoms_match env parent_atoms) ->
      (temporal_truth M atomMap (env 0) A <->
       exists x, nf_eval_nf M k (n+1) (Fin.cons x env) sub_nf)
  ```
  (~30-50 lines for imports, statement, docstring)
- [ ] **Task 1.2**: Implement the base case k=0. Delegate to `existPart_zero` for the formula existence. This case is already sorry-free in RabinovichGeneralized.lean. (~20-40 lines)
- [ ] **Task 1.3**: Implement the step case k+1 -- formula construction. Define the enriched formula using `char_{k+1}` for the point type at x, `Classical.choose` on the IH at depth k for each quantifier condition ssn, conjunction of positive/negative conditions, disjunction over atom-compatible profiles, wrapping in Until/Since/identity for the three zone cases. (~80-120 lines)
- [ ] **Task 1.4**: Verify the construction compiles with sorries only in the correctness proof (Phase 2). Run `lake build` on the module.

**Timing**: 1.5 hours (~150-200 lines)

**Depends on**: none

**Files to create**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampBypass.lean`

**Verification**:
- `lake build Bimodal.Metalogic.WeakCanonical.Kamp.KampBypass` succeeds (with sorries in Phase 2 only)

---

### Phase 2: Prove correctness of the enriched formula (both directions) [BLOCKED]

**Goal**: Prove the biconditional `temporal_truth M atomMap (env 0) A <-> exists x, nf_eval_nf M k (n+1) (Fin.cons x env) sub_nf` for the enriched formula A from Phase 1. This is the core proof.

**Mathematical Content**:

**Forward direction** (exists x with NF -> formula truth):
Given x with `nf_eval_nf M k (n+1) (Fin.cons x env) sub_nf`:
1. x is in a specific zone relative to env(0) (from the atom part of sub_nf).
2. `char_{k+1}(nf_x)` holds at x (from `nf_eval_nf M k 1 (fun _ => x) nf_x` and `char_k_correct`).
3. For each positive ssn (sub_nf.2 ssn = true): `exists y, nf_eval_nf M k (n+2) (y, x, env) ssn` holds. By the IH correctness at depth k: `Phi_ssn` holds at env(0). Actually: `Phi_ssn` is evaluated at x (the newly quantified variable), since the enriched formula evaluates conjuncts at x's position, not at env(0). Correction: `Phi_ssn` is the IH formula for the existential with base environment `(Fin.cons x env)`. The IH says `temporal_truth M atomMap x Phi_ssn <-> exists y, ...`. So from the positive condition, `temporal_truth M atomMap x Phi_ssn` holds.
4. For each negative ssn: similarly, `not (exists y ...)` gives `not (temporal_truth ... Phi_ssn)`, giving `temporal_truth ... (neg Phi_ssn)`.
5. The enriched point type holds at x. Combined with the zone placement, the formula (Until/Since wrapping) holds at env(0).

This direction mirrors `nf_exist_formula_forward'` but with the enriched formula. It should be straightforward.

**Backward direction** (formula truth -> exists x with NF):
Given formula truth at env(0):
1. Extract x from Until/Since semantics (in the right zone).
2. From the disjunction in the enriched point type, extract which nf_x profile holds at x. From `char_{k+1}(nf_x)` holding at x and `char_k_correct`, get `nf_eval_nf M k 1 (fun _ => x) nf_x`.
3. From each positive conjunct `Phi_ssn` holding at x: by the IH correctness, `exists y, nf_eval_nf M k (n+2) (y, x, env) ssn` holds. So sub_nf.2 ssn = true is verified.
4. From each negative conjunct `neg Phi_ssn` holding at x: by the IH correctness, `not (exists y, ...)`. So sub_nf.2 ssn = false is verified.
5. Atom conditions follow from nf_x's atom profile compatibility with sub_nf.1, plus the zone giving the order.
6. Combining atoms + quantifiers: `nf_eval_nf M k (n+1) (Fin.cons x env) sub_nf` holds.

This is the KEY insight of the bypass: the enriched formula encodes ALL quantifier conditions as explicit conjuncts, so extracting them in the backward direction is conjunction elimination. No composition theorem is needed because the quantifier profile is directly encoded, not inferred from 1-var NF data.

**BLOCKER** (Phase 2):
- **What failed**: `depth0_3var_exist_formula` loses y-t order information. Two ssn values differing only in y-t order produce the SAME temporal formula. When `sub_nf.2 ssn_a = true` and `sub_nf.2 ssn_b = false` for such a pair, `quant_profile_conj_depth0` contains both phi and neg-phi, making the enriched formula False at x even when sub_nf IS the characteristic of (x,t).
- **What was tried**: (1) Using y-x zone decomposition only (loses y-t info). (2) Nested temporal formulas like `Since(parent_char AND Since(char_y, top), top)` to encode y < t from x (finds SOME z with parent_char, not necessarily t). (3) Using Prior-UZ/SZ to find FIRST/LAST occurrence of parent_char (multiple points may share the same characteristic, so z may not equal t).
- **Why stuck**: From position x, temporal formulas reference points relative to x, not relative to t. The y-t order is a ternary relationship that cannot be expressed as a temporal property at a single point. This is equivalent to the Feferman-Vaught composition property for Prior structures, which is the SAME blocker as `nf_exist_backward_prior` (NfCharFormula.lean:541). The enriched formula bypass does NOT avoid this composition requirement.
- **What is needed**: Either (a) prove the Prior composition property: on Prior structures, knowing x's depth-(k+1) 1-var NF + t's predicates + x-t order determines the 3-var quantifier profile at (y,x,t); or (b) find a fundamentally different encoding of the quantifier profile that avoids referencing t from x (perhaps using the Rabinovich "P_n(k) generalization" at a deeper level that avoids per-ssn encoding).
- **Prohibited**: Do NOT use sorry, def X := True, or vacuous placeholder.

**Tasks**:
- [ ] **Task 2.1**: Prove the forward direction of the k+1 case. Given x with `nf_eval_nf`, show the enriched formula holds at env(0). Factor through helper lemmas for the atom part (zone placement + char_k truth) and the quantifier part (IH application for each ssn). (~80-120 lines)
- [ ] **Task 2.2**: Prove the backward direction of the k+1 case. Given the enriched formula truth, extract x from Until/Since, extract the atom profile from the disjunction, extract each quantifier condition from the conjunction. Assemble `nf_eval_nf`. (~100-150 lines)
- [ ] **Task 2.3**: Handle the base environment compatibility. The IH at depth k gives formulas evaluated at `x` (the newly introduced variable), NOT at `env(0)`. Need to verify that the enriched point type conjuncts are evaluated at the Until/Since witness point x, which is where `Phi_ssn` should be evaluated. The IH formula for `exists y, nf_eval_nf M k (n+2) (Fin.cons y (Fin.cons x env)) ssn` takes base `(Fin.cons x env)` and evaluates at `(Fin.cons x env)(0) = x`. So `temporal_truth M atomMap x Phi_ssn` is the correct evaluation point. This matches the enriched point type being evaluated at x (inside the Until/Since). (~30-50 lines for environment manipulation helpers)
- [ ] **Task 2.4**: Verify `lean_verify nf_nvar_exist_formula_bypass` shows no sorryAx. Run `lake build` on the module.

**Timing**: 2 hours (~250-350 lines)

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampBypass.lean` (extend with proofs)

**Verification**:
- `lean_verify nf_nvar_exist_formula_bypass` shows no sorryAx
- `lake build Bimodal.Metalogic.WeakCanonical.Kamp.KampBypass` succeeds

---

### Phase 3: Wire bypass into NfCharFormula + RabinovichGeneralized [COMPLETED]

**Goal**: Use `nf_nvar_exist_formula_bypass` from Phases 1-2 to fill the sorry at `nf_2var_exist_formula_prior` (NfCharFormula.lean:610, k+1 case), `nf_2var_exist_formula_prior_neg` (RabinovichNegation.lean:291), and `existPart_succ` (RabinovichGeneralized.lean:446, :474). Verify the sorry chain closure.

**Mathematical Content**:

The bypass theorem provides: for any k, n >= 1, `exists A, forall M h_UZ h_SZ env, ... temporal_truth A <-> exists x, nf_eval_nf ...`.

**Wiring into NfCharFormula.lean:610**: Replace the k+1 case. Instead of `refine <nf_exist_formula ..., ...>`, use `nf_nvar_exist_formula_bypass` with n=1. The IH `char_k_correct` provides the depth-k characteristic formulas. The bypass theorem gives a different formula A and its correctness proof. The `nf_exist_backward_prior` sorry at line 540 becomes dead code (the k+1 branch no longer calls it).

**Wiring into RabinovichNegation.lean:291**: Similarly replace the k'+1 case with the bypass theorem at n=1.

**Wiring into RabinovichGeneralized.lean:446**: Replace the n=1 case with the bypass theorem at n=1, k=k+1. The n>=2 case at line 474 then either follows from the same bypass theorem at general n, or from the n=1 case via the existing constant-base projection argument.

**Tasks**:
- [ ] **Task 3.1**: Modify `nf_2var_exist_formula_prior` (NfCharFormula.lean:610) at the k+1 case. Import KampBypass. Replace the current `refine <nf_exist_formula, ...>` with a call to `nf_nvar_exist_formula_bypass` at n=1. The formula A comes from the bypass theorem. Adapt the char_k hypothesis format. (~30-50 lines changed)
- [ ] **Task 3.2**: Modify `nf_2var_exist_formula_prior_neg` (RabinovichNegation.lean:291) at the k'+1 case. Import KampBypass. Replace the sorry with the bypass theorem. (~20-30 lines changed)
- [ ] **Task 3.3**: Modify `existPart_succ` (RabinovichGeneralized.lean:446) at the n=1 case. The bypass theorem at general n fills this directly. For the n>=2 case at line 474, either use the bypass at n=n''+2 directly, or use the existing constant-base projection from the now-sorry-free n=1 case. (~30-50 lines changed)
- [ ] **Task 3.4**: Verify the Kamp chain: `nf_characterizable_temporal_prior`, `kamp_prior_expressive_completeness`, `US_expressively_complete_over_prior` all compile with no sorryAx.
- [ ] **Task 3.5**: Run `lake build` on the full project -- must succeed with 0 errors.

**Timing**: 1.5 hours (~100-150 lines changed + verification)

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfCharFormula.lean` -- replace k+1 case at line 610
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/RabinovichNegation.lean` -- fill sorry at line 291
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/RabinovichGeneralized.lean` -- fill sorries at lines 446, 474

**Verification**:
- `lean_verify nf_characterizable_temporal_prior` shows no sorryAx
- `lean_verify kamp_prior_expressive_completeness` shows no sorryAx
- `lean_verify kamp_mutual_induction` shows no sorryAx
- `lake build` succeeds (full project, clean)

---

### Phase 4: Chronicle gap + final verification [NOT STARTED]

**Goal**: Fill `chronicle_gap_contradiction` if unblocked by the Kamp chain closure. Run full verification of the completeness pipeline.

**Mathematical Content**:

Once `kamp_prior_expressive_completeness` is sorry-free, the sorry chain for `completeness_discrete` should trace only through the chronicle gap and Task 202 (succ_cofinal). The chronicle gap Case A (distinct limit functions) uses `contemp_equiv` and NF characterization. Case B (constant MCS) may be trivial or may need a separate argument.

**Tasks**:
- [ ] **Task 4.1**: Check `lean_verify completeness_discrete` to identify remaining sorryAx. Determine if `chronicle_gap_contradiction` is now the only blocker (besides Task 202 chain).
- [ ] **Task 4.2**: Fill `chronicle_gap_contradiction` (ChronicleToCountermodel.lean). Activate the OLD PROOF block. Case A: fix k=0 -> k>=1 issue, use k=1 for `contemp_equiv`. Case B: prove or mark as sub-sorry. (~50-80 lines)
- [ ] **Task 4.3**: Run full verification:
  - `lean_verify chronicle_gap_contradiction` -- no sorryAx (or reduced)
  - `lean_verify completeness_discrete` -- remaining sorryAx should trace ONLY through Task 202 chain (succ_cofinal)
  - `lake build` -- full project, 0 errors
- [ ] **Task 4.4**: Update README.md if sorry obligations improve.

**Timing**: 1 hour (~50-80 lines + verification)

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- fill chronicle_gap_contradiction
- `README.md` -- update sorry count if improved

**Verification**:
- `lean_verify chronicle_gap_contradiction` shows no sorryAx (or identifies remaining sub-sorry)
- `lean_verify completeness_discrete` -- remaining sorryAx traces only through Task 202 chain
- `lake build` succeeds (full project, clean)

---

## Testing & Validation

- [x] Phase 1-4 (v21/v22): Vec-EA infrastructure (~2700 lines sorry-free) (DONE)
- [x] Phase 0 (v23): VecEADecomposition quarantined (DONE)
- [x] Phases 1-2 (v24): Separation module sorry-free (DONE)
- [x] Rabinovich core: 4 files, 1349+ lines sorry-free (DONE)
- [x] Phase 1-2 (v26): existPart_zero all n + existPart_succ factored (DONE)
- [x] Phase 1-2 (v27): Lemma 5.3 + Prop 4.2 confirmed sorry-free (DONE, no new code)
- [x] Phase 1 (v28): bracketBuildLeft_correct Since-direction sorry-free (DONE)
- [ ] Phase 1 (v29): Enriched formula definition (nf_nvar_exist_formula_bypass)
- [ ] Phase 2 (v29): Enriched formula correctness (both directions, no sorry)
- [ ] Phase 3 (v29): Wiring into NfCharFormula + RabinovichGeneralized + RabinovichNegation
- [ ] Phase 4 (v29): Chronicle gap filled; completeness_discrete verified

## Artifacts & Outputs

**Existing (sorry-free, preserved)**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/VecEATranslation.lean` (302 lines)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/VecEAFormula.lean`
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NegationClosureProp42.lean`
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/VecEAClosure.lean`
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/PriorINF.lean`
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfToVecEA.lean` (700+ lines, all sorry-free)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/RabinovichTranslation.lean` (302 lines)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/RabinovichWiring.lean` (365 lines)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/RabinovichNegation.lean` (297 lines)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/RabinovichGeneralized.lean` (~470 lines)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfComposition.lean` (267 lines)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/SeparationBridge.lean` (~199 lines)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/VecEADecomp.lean` (898 lines)

**New (v29)**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampBypass.lean` -- enriched bypass formula + correctness (~400-550 lines)

**Modified (v29)**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfCharFormula.lean` -- replace k+1 case at line 610 (~30-50 lines changed)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/RabinovichNegation.lean` -- fill sorry at line 291 (~20-30 lines changed)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/RabinovichGeneralized.lean` -- fill sorries at lines 446, 474 (~30-50 lines changed)
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- fill chronicle_gap_contradiction (~50-80 lines)

**Estimated new Lean code**: ~500-700 lines across all files

## Rollback/Contingency

**If the enriched formula construction at k+1 has Lean type issues (Phase 1)**:
- The arity parameter n in `Fin n -> M.carrier` may cause unification difficulties. Try: (a) fixing n=1 first as a special case, then generalizing; (b) using `Vector M.carrier n` instead of `Fin n -> M.carrier`; (c) working with explicit environment manipulation functions.
- Fallback: define the enriched formula only for n=1 (which is sufficient for `nf_2var_exist_formula_prior` and `existPart_succ` n=1). Handle n>=2 via the existing constant-base projection from the now-sorry-free n=1 case.

**If the backward direction proof is harder than expected (Phase 2)**:
- The enriched formula is designed to make backward extraction trivial (conjunction elimination). If the Until/Since extraction is problematic, try the `nf_exist_formula_forward'` pattern which already handles this extraction for the non-enriched formula.
- Fallback: fill only the forward direction and mark backward as [PARTIAL]. This gives a weaker result but may still allow progress.

**If the IH application at depth k requires environment manipulation lemmas that do not exist (Phase 2)**:
- The IH at depth k for arity n+1 gives a formula evaluated at `(Fin.cons x env)(0) = x`. The enriched point type conjuncts are evaluated inside Until/Since, where the temporal evaluation point IS x. If the `temporal_truth M atomMap x Phi_ssn` does not match the IH's format, add explicit rewriting lemmas.
- Fallback: define intermediate lemmas that bridge the environment format gap.

**If wiring into NfCharFormula creates import issues (Phase 3)**:
- KampBypass.lean must import NfCharFormula's dependencies but NOT NfCharFormula itself (to avoid cycles). If NfCharFormula needs to import KampBypass, ensure KampBypass only depends on lower-level modules.
- Fallback: inline the bypass construction directly in NfCharFormula.lean instead of a separate file.

**If chronicle_gap_contradiction Case B is non-trivial (Phase 4)**:
- Mark Case B as a separate sorry with a TODO comment.
- Create a follow-up task for Case B.
- The Kamp chain closure (the primary goal of Phases 1-3) is independent of the chronicle gap.

**If the approach fails entirely**:
- All existing sorry-free code (~5000+ lines) remains valid.
- The NegationClosure.lean:1716 path remains as an alternative approach (requires the composition theorem).
- Consider the GHR94 separation approach (Path A) as a last resort (~2000-4000 lines).
