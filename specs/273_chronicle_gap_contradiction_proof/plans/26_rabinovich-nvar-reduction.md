# Implementation Plan: Rabinovich Strategy with n-var to 2-var Reduction (v26)

- **Task**: 273 - chronicle_gap_contradiction_proof
- **Status**: [NOT STARTED]
- **Effort**: 8 hours
- **Dependencies**: Plans v17-v22 (phases 1-4 COMPLETED), plan v23 (Phase 0 COMPLETED), plan v24 (Phases 1-2 COMPLETED). Rabinovich infrastructure (4 files, 1349 lines, sorry-free core).
- **Research Inputs**:
  - specs/273_chronicle_gap_contradiction_proof/reports/25_formula-construction-research.md (round 25)
  - specs/273_chronicle_gap_contradiction_proof/reports/24_blocker-research.md (round 24)
  - specs/273_chronicle_gap_contradiction_proof/reports/23_team-research.md (round 23)
  - specs/273_chronicle_gap_contradiction_proof/reports/13_team-research.md (round 13)
  - specs/273_chronicle_gap_contradiction_proof/reports/11_divergence-audit.md (postmortem constraints)
  - specs/273_chronicle_gap_contradiction_proof/reports/10_literature-transcription.md (literature grounding)
- **Artifacts**: plans/26_rabinovich-nvar-reduction.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Plan v25 was based on a theorem (`generalized_composition`) proved FALSE. The theorem has been removed; NfComposition.lean is now sorry-free. In its place, Rabinovich infrastructure has been built: 4 files, 1349 lines, sorry-free core. The key insight from report 25 is that all n>=2 cases reduce to the n=1 case via a decidable consistency check and 2-var projection. The only genuine mathematical blocker is `existPart_succ` at n=1, which is equivalent to the original sorry at NfCharFormula.lean:572 (`nf_2var_exist_formula_prior`).

This plan supersedes v25 entirely. It follows the Rabinovich-based strategy with clear phases: close the mechanical n>=2 sorry at depth 0, factor the depth k+1 sorry into n=1 + n>=2 (where n>=2 reduces to n=1), resolve the base environment mismatch, fill the core n=1 case, and wire the result into the NfCharFormula sorry site.

### Research Integration

**Reports integrated in this plan version**:
- `25_formula-construction-research.md`: The two sorry sites (NfCharFormula:572 and NegationClosure:1712) are causally linked; NegationClosure is ROOT. Option (b) -- bypass NfCharFormula:572 by rewriting `nf_characterizable_temporal_prior_classical` to call `nf_2var_exist_formula_prior_fill` -- is structurally cleaner. The Stavi/GHR approach (`nf_exist_formula_nested`) is a dead end at k>=1.
- `24_blocker-research.md`: Root cause -- NfComposition arity-3 fixed induction fails; generalized arity-n approach needed.
- `23_team-research.md`: VecEADecomposition confirmed dead code; NF-specific Prop 4.3 bypass insufficient for k>=1.
- `13_team-research.md`: nf_to_formula bridge exists; Lemma 3.2.2 + Prop 4.3 architecture designed.
- `11_divergence-audit.md`: Postmortem constraints remain binding.
- `10_literature-transcription.md`: Doets 1989 Lemma 1.4/1.5 foundation; Rabinovich 2014 Section 5.

### Prior Plan Reference

Plans v17-v22: Phases 1-4 COMPLETED (~2700 lines sorry-free vec-EA infrastructure). Plan v23: Phase 0 COMPLETED (quarantine). Plan v24: Phases 1-2 COMPLETED (Separation module, sorry-free). Plan v25: ALL PHASES BLOCKED (generalized_composition proved FALSE and removed).

This plan replaces v25 with the Rabinovich-based strategy. All completed phases from prior plans are preserved.

### Roadmap Alignment

- **Kamp chain**: Close `kamp_prior_expressive_completeness` via ExistPart sorry closure
- **Chronicle gap**: Fill `chronicle_gap_contradiction` via sorry-free model surgery pipeline
- **Critical path**: Closes two of the remaining sorry chains for `completeness_discrete`

## Goals & Non-Goals

**Goals**:
- Fill `existPart_zero` sorry at RabinovichGeneralized.lean:268 (n>=2 case)
- Factor `existPart_succ` (RabinovichGeneralized.lean:333) into n>=2 reduction + n=1 core
- Resolve the base environment mismatch for quantifier conditions at depth k+1
- Fill `existPart_succ` at n=1 -- the core mathematical work
- Wire the result to close NfCharFormula.lean:572 (`nf_2var_exist_formula_prior`)
- Fill `chronicle_gap_contradiction` (ChronicleToCountermodel.lean)
- Pass `lake build` with zero new sorries on the critical path to `completeness_discrete`

**Non-Goals**:
- Proving the Stavi/GHR version at NegationClosure.lean:1712 (`nf_exist_formula_nested_backward`) -- preserved but not on critical path since `nf_2var_exist_formula_prior_filled` bypasses it
- Filling NegationClosure.lean:1327 (`all_goals sorry` in zone1_quant_check) -- not on critical path
- Modifying existing sorry-free infrastructure (phases 1-4 files, Separation module)
- Fixing VecEADecomposition.lean sorries (quarantined dead code)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| existPart_zero n>=2 Fin bookkeeping is more extensive than estimated | M | M | Template from `reconstruct_depth0` in RabinovichNegation.lean handles the 2-var case; extend to n-var. Worst case: double the estimate (~200 lines instead of 100). |
| Base environment mismatch at k+1 requires deep generalization of ExistPart | H | M | Three options evaluated in Phase 3. If Option A (generalize ExistPart) is too invasive, fall back to Option B (single ExistsForallSpec encoding) or Option C (Rabinovich Section 5 negation closure). |
| n=1 existPart_succ is genuinely harder than expected | H | M | This is the core mathematical blocker. The proof requires encoding quantifier conditions in temporal formulas using Prior-UZ/SZ. RabinovichWiring.lean already has the forward direction sorry-free and backward at k=0 sorry-free. Pattern extends to k+1. |
| Chronicle gap Case B (constant MCS) non-trivial | M | M | Orthogonal to Phases 1-4. If non-trivial, mark as sub-sorry with follow-up task. |

## Postmortem Constraints (from Report 11, Section 5)

These remain binding:
1. **DO NOT attempt NF-to-formula backward proofs by extracting NF data from formula truth** (Deflection 1)
2. **DO NOT use depth-k characteristic formulas where depth-(k+1) is needed** (Deflection 2)
3. **DO NOT encode negative interval conditions as guards that block legitimate witnesses** (Deflection 3)
4. **DO NOT attempt to prove nf_3var_from_1var_nfs at fixed arity** (Deflection 4)
5. **DO NOT cycle between formula-level and NF-level fixes** (Deflection 5)

## Sorry Inventory (Current State)

| File | Line | Statement | Status | This Plan |
|------|------|-----------|--------|-----------|
| RabinovichGeneralized.lean | 268 | existPart_zero n>=2 (satisfiable case) | SORRY | Phase 1 fills |
| RabinovichGeneralized.lean | 333 | existPart_succ all n | SORRY | Phase 2 factors, Phase 4 fills n=1 |
| RabinovichWiring.lean | 359 | backward k+1 | SORRY | Same blocker as existPart_succ n=1 |
| RabinovichNegation.lean | 291 | backward k+1 | SORRY | Same blocker as existPart_succ n=1 |
| NfCharFormula.lean | 572 | nf_2var_exist_formula_prior | SORRY | Phase 5 wires via nf_2var_exist_formula_prior_filled |
| NegationClosure.lean | 1712 | nf_exist_formula_nested_backward | SORRY | NOT on critical path (preserved) |
| NegationClosure.lean | 1327 | zone compatibility `all_goals sorry` | SORRY | NOT on critical path (preserved) |
| ChronicleToCountermodel.lean | 224 | succ_reaches_dom_N boundary | SORRY | Dead code (NOT filled) |

### Existing Infrastructure (sorry-free)

| File | Lines | Content |
|------|-------|---------|
| RabinovichTranslation.lean | 302 | Prop 3.5: ExistsForallSpec -> TL(U,S) |
| RabinovichWiring.lean | 365 | Forward ALL k, backward k=0 |
| RabinovichNegation.lean | 297 | Backward k=0, drop-in replacement |
| RabinovichGeneralized.lean | 385 | CharPart/ExistPart framework, kamp_mutual_induction |
| NfComposition.lean | 267 | intra_structure_extend (sorry-free) |
| SeparationBridge.lean | ~199 | GHR94 Lemma 10.2.2 negation equivalences |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |

Phases are fully sequential. Each phase builds on the prior.

---

### Phase 1: Close existPart_zero at n>=2 [NOT STARTED]

**Goal**: Fill the sorry at RabinovichGeneralized.lean:268 (the satisfiable case of existPart_zero for n>=2). The unsatisfiable case is already sorry-free.

**Mathematical Argument**: At depth 0, the (n+1)-var NF is purely atomic: predicates at each variable + order relations. When the base environment is `(fun _ => t)` (all base vars equal t), the n-var existential `exists x, nf_eval_nf M 0 (n+1) (Fin.cons x (fun _ => t)) sub_nf` is equivalent to the 2-var existential `exists x, nf_eval_nf M 0 2 (Fin.cons x (fun _ => t)) (project sub_nf)` because: (1) all base variables are identical, (2) predicates at base vars are captured by `parent_atoms`, (3) order relations among base vars are all `=`, (4) only the order between x and t matters. If the sub_nf has inconsistent constraints (e.g., asserting different predicates at different base vars, or strict order between base vars), the existential is vacuously false (unsatisfiable case, already handled).

**Tasks**:
- [ ] **Task 1.1**: Define decidable consistency check for sub_nf at depth 0: verify that sub_nf's atom function does not impose contradictory constraints on the base variables (all of which equal t). Extract these conditions from the satisfiability witness in h_sat. (~30 lines)
- [ ] **Task 1.2**: Construct the 2-var projection: given sub_nf satisfying consistency, build the 2-var NF that captures all relevant information (predicates at x and t, order between x and t). Show the n-var and 2-var existentials are equivalent. (~50 lines)
- [ ] **Task 1.3**: Wire to the existing `nf_2var_exist_formula_prior_neg` at k=0 to get the temporal formula. (~20 lines)
- [ ] **Task 1.4**: Verify `existPart_zero` compiles sorry-free. Run `lean_verify existPart_zero`.

**Timing**: 1.5 hours (~100 lines)

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/RabinovichGeneralized.lean` -- fill sorry at line 268

**Verification**:
- `lean_verify existPart_zero` shows no sorryAx
- `lake build Bimodal.Metalogic.WeakCanonical.Kamp.RabinovichGeneralized` succeeds

**Template**: `reconstruct_depth0` in RabinovichNegation.lean handles the 2-var depth-0 case. Extend the pattern to n-var with constant base environment.

---

### Phase 2: Factor existPart_succ into n=1 + n>=2 [NOT STARTED]

**Goal**: Replace the single sorry at RabinovichGeneralized.lean:333 with two branches: one for n>=2 (which reduces to n=1 via the same 2-var projection as Phase 1) and one for n=1 (left as sorry placeholder -- the mathematical blocker).

**Mathematical Argument**: At depth k+1 with n>=2, the same reduction applies as at depth 0. When all base variables equal t, the (n+1)-var existential `exists x, nf_eval_nf M (k+1) (n+1) (Fin.cons x (fun _ => t)) sub_nf` can be checked for consistency of base-variable constraints. If inconsistent, the existential is vacuously false. If consistent, it reduces to the 2-var existential because the additional base variables contribute no information beyond what `parent_atoms` captures. This gives `existPart_succ` for n>=2 in terms of `existPart_succ` for n=1 (via the recursive IH).

**Tasks**:
- [ ] **Task 2.1**: Add case split on n in `existPart_succ`: `rcases n with _ | n'` separating n=1 from n>=2. (~10 lines)
- [ ] **Task 2.2**: For n>=2 case: apply the decidable consistency check + 2-var projection (same argument as Phase 1 but at depth k+1). Use `ih_exist` at n=1 for the projected 2-var existential. (~50 lines)
- [ ] **Task 2.3**: For n=1 case: leave as sorry with documented comment explaining this is the core mathematical blocker. (~5 lines)
- [ ] **Task 2.4**: Verify `existPart_succ` compiles with exactly one sorry (the n=1 case). Run `lean_verify existPart_succ` -- should show sorryAx (from n=1 case only).

**Timing**: 1 hour (~80 lines)

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/RabinovichGeneralized.lean` -- restructure existPart_succ

**Verification**:
- `lean_verify existPart_succ` shows sorryAx (from n=1 placeholder only)
- The n>=2 branch produces no sorry
- `lake build Bimodal.Metalogic.WeakCanonical.Kamp.RabinovichGeneralized` succeeds

---

### Phase 3: Resolve the base environment mismatch [NOT STARTED]

**Goal**: Research and implement the approach that bridges the base environment gap for `existPart_succ` at n=1. At depth k+1, the quantifier conditions involve `nf_eval_nf M k 3 (Fin.cons y (Fin.cons x (fun _ => t)))` (base = `Fin.cons x (fun _ => t)`), but `ExistPart(k)` only provides formulas for base = `(fun _ => t)`.

**Options** (evaluate and choose one):

**Option A -- Generalize ExistPart to arbitrary base environments**: Change ExistPart to take an arbitrary base environment instead of `(fun _ => t)`. This gives direct access to formulas for the quantifier conditions. Risk: may require modifying charPart_succ and the entire mutual induction structure. Estimate: 200-400 lines if feasible, but potentially too invasive.

**Option B -- Encode ALL quantifier witnesses in a single ExistsForallSpec**: Instead of handling each quantifier condition independently, encode the entire quantifier structure as a single `ExistsForallSpec` and use the sorry-free `RabinovichTranslation.lean` (Prop 3.5) to get a temporal formula. This sidesteps the base environment mismatch by not using ExistPart(k) directly. Estimate: 200-300 lines.

**Option C -- Use Rabinovich Section 5 negation closure directly**: On Prior structures, temporal truth at t determines the existential properties in intervals relative to t. Use Prior-UZ/SZ to show that knowing the temporal properties at t (via CharPart(k+1)) is sufficient to determine the quantifier conditions even though x differs from t. This is Rabinovich's stated approach. Estimate: 150-250 lines.

**Tasks**:
- [ ] **Task 3.1**: Evaluate all three options by examining: (a) what modifications to existing types/theorems each requires, (b) whether the mathematical argument is sound, (c) estimated complexity. (~30 minutes research, no code changes)
- [ ] **Task 3.2**: Implement the chosen option. Create helper lemmas as needed. (~150-300 lines)
- [ ] **Task 3.3**: Verify the bridge compiles sorry-free with `lean_verify` on the helper lemmas.

**Timing**: 2.5 hours (~200-400 lines)

**Depends on**: 2

**Files to create/modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/RabinovichGeneralized.lean` -- add bridge lemmas
- Potentially `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/RabinovichWiring.lean` -- if Option B chosen

**Verification**:
- Bridge lemmas compile sorry-free
- `lake build Bimodal.Metalogic.WeakCanonical.Kamp.RabinovichGeneralized` succeeds

**Implementation Notes**:
- Option C is the most aligned with Rabinovich's paper (Section 5). The key insight is that on a Prior structure (DLO without endpoints), for any x and t, the temporal properties at t encode enough information about intervals containing x to determine the quantifier conditions. This uses the ExistsForallSpec translation (Prop 3.5, sorry-free) together with the fact that Prior-UZ/SZ give first/last occurrence semantics.
- Option B is the most self-contained: it avoids modifying ExistPart's signature and instead builds a richer ExistsForallSpec that encodes all witness constraints simultaneously.
- Option A is the most principled but potentially the most disruptive to existing infrastructure.

---

### Phase 4: Fill existPart_succ at n=1 [NOT STARTED]

**Goal**: Fill the remaining sorry in `existPart_succ` for the n=1 case, using the bridge from Phase 3. This is the core mathematical work.

**Mathematical Argument**: At depth k+1, n=1, we need a formula A such that `temporal_truth M atomMap t A <-> exists x, nf_eval_nf M (k+1) 2 (Fin.cons x (fun _ => t)) sub_nf`. The sub_nf has: (1) atom part -- predicates at x and t, order between x and t, (2) quantifier part -- for each depth-k 3-var NF ssn, whether `exists y, nf_eval_nf M k 3 (Fin.cons y (Fin.cons x (fun _ => t))) ssn` holds.

The forward direction (exists x -> formula truth) follows the pattern of `nf_exist_formula_forward` (already sorry-free in the codebase). The backward direction (formula truth -> exists x) is the hard part:
1. Extract witness x from Until/Since semantics
2. Verify atom conditions at x (from CharPart(k+1))
3. Verify quantifier conditions -- this uses the Phase 3 bridge

**Tasks**:
- [ ] **Task 4.1**: Construct the temporal formula for the n=1 case at depth k+1. The formula encodes: atom conditions on x (via char(k+1) formulas for 1-var NFs) + zone position (x < t, x = t, x > t) + quantifier conditions (via Phase 3 bridge). (~80 lines)
- [ ] **Task 4.2**: Prove the forward direction: given x satisfying the NF, show the formula holds at t. Pattern from `nf_exist_formula_forward`. (~80 lines)
- [ ] **Task 4.3**: Prove the backward direction: given the formula truth, extract x and verify all NF conditions. Uses Phase 3 bridge for quantifier conditions. (~200 lines)
- [ ] **Task 4.4**: Verify `existPart_succ` compiles sorry-free. Run `lean_verify existPart_succ` -- should show no sorryAx.
- [ ] **Task 4.5**: Verify `kamp_mutual_induction` and `nf_2var_exist_formula_prior_filled` compile sorry-free.

**Timing**: 2 hours (~300-500 lines)

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/RabinovichGeneralized.lean` -- fill n=1 sorry

**Verification**:
- `lean_verify existPart_succ` shows no sorryAx
- `lean_verify kamp_mutual_induction` shows no sorryAx
- `lean_verify nf_2var_exist_formula_prior_filled` shows no sorryAx
- `lake build Bimodal.Metalogic.WeakCanonical.Kamp.RabinovichGeneralized` succeeds with 0 sorries

---

### Phase 5: Wire into NfCharFormula.lean + Chronicle Gap + Full Verification [NOT STARTED]

**Goal**: Replace the sorry at NfCharFormula.lean:572 with the Rabinovich result, fill `chronicle_gap_contradiction`, and verify end-to-end build.

**Tasks**:
- [ ] **Task 5.1**: Replace the sorry at NfCharFormula.lean:572 (`nf_2var_exist_formula_prior`) with a call to `nf_2var_exist_formula_prior_filled` from RabinovichGeneralized.lean. Two approaches: (a) directly fill the sorry body using the filled version, or (b) modify `nf_characterizable_temporal_prior_classical` to call `nf_2var_exist_formula_prior_filled` directly, bypassing the sorry site entirely (structurally cleaner per report 25 Finding 1). (~20-30 lines)
- [ ] **Task 5.2**: Verify the Kamp chain compiles sorry-free:
  - `lean_verify nf_2var_exist_formula_prior` (or its bypass) shows no sorryAx
  - `lean_verify nf_characterizable_temporal_prior` shows no sorryAx
  - `lean_verify kamp_prior_expressive_completeness` shows no sorryAx
  - `lean_verify US_expressively_complete_over_prior` shows no sorryAx
- [ ] **Task 5.3**: Fill `chronicle_gap_contradiction` (ChronicleToCountermodel.lean). Activate and fix the OLD PROOF block. Case A (limit_f(a) != limit_f(b)): fix k=0 -> k>=1 issue, use k=1 for `contemp_equiv`. Case B (limit_f(a) = limit_f(b)): prove or mark as sub-sorry. (~50-80 lines)
- [ ] **Task 5.4**: Run `lake build` (full project) -- must succeed with 0 errors.
- [ ] **Task 5.5**: Verify axiom checks:
  - `lean_verify chronicle_gap_contradiction` -- no sorryAx
  - `lean_verify completeness_discrete` -- remaining sorryAx should trace ONLY through Task 202 chain (succ_cofinal)

**Timing**: 1 hour (~50-80 lines modification + verification)

**Depends on**: 4

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfCharFormula.lean` -- fill or bypass sorry at :572
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- fill chronicle_gap_contradiction

**Verification**:
- `lean_verify kamp_prior_expressive_completeness` shows no sorryAx
- `lean_verify chronicle_gap_contradiction` shows no sorryAx
- `lake build` succeeds (full project, clean)
- `lean_verify completeness_discrete` -- remaining sorryAx traces only through Task 202 chain

---

## Testing & Validation

- [x] Phase 1-4 (v21/v22): Vec-EA infrastructure (~2700 lines sorry-free) (DONE)
- [x] Phase 0 (v23): VecEADecomposition quarantined (DONE)
- [x] Phases 1-2 (v24): Separation module sorry-free (DONE)
- [x] Rabinovich core: 4 files, 1349 lines sorry-free (DONE)
- [ ] Phase 1 (v26): existPart_zero sorry-free for all n
- [ ] Phase 2 (v26): existPart_succ n>=2 reduces to n=1, single sorry at n=1
- [ ] Phase 3 (v26): Base environment bridge compiles sorry-free
- [ ] Phase 4 (v26): existPart_succ sorry-free for all n and k
- [ ] Phase 5 (v26): NfCharFormula:572 filled, chronicle_gap_contradiction filled, `lake build` clean

## Artifacts & Outputs

**Existing (sorry-free, preserved)**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/RabinovichTranslation.lean` (302 lines)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/RabinovichWiring.lean` (365 lines)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/RabinovichNegation.lean` (297 lines)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/RabinovichGeneralized.lean` (385 lines)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfComposition.lean` (267 lines)

**Modified (v26)**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/RabinovichGeneralized.lean` -- fill existPart_zero n>=2, factor + fill existPart_succ (~400-600 lines new/modified)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfCharFormula.lean` -- fill/bypass sorry at :572 (~20-30 lines)
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- fill chronicle_gap_contradiction (~50-80 lines)

**Estimated new Lean code**: ~500-750 lines across all files

## Rollback/Contingency

**If the 2-var projection equivalence at depth 0 is harder than expected (Phase 1)**:
- The mathematical argument is straightforward (constant base environment means all base vars are identical). If Fin bookkeeping is excessive, try a classical shortcut: use `Classical.em` on satisfiability (already in the code) and for the satisfiable branch, use the witness to extract the consistency conditions as decidable Boolean checks.

**If Phase 3 Option C (Rabinovich Section 5) doesn't work**:
- Fall back to Option B (single ExistsForallSpec encoding). The sorry-free RabinovichTranslation.lean already converts ExistsForallSpec to temporal formulas. The challenge is constructing the right ExistsForallSpec from the quantifier conditions.
- If Option B also fails, try Option A (generalize ExistPart signature). This is more invasive but mathematically the most principled.

**If Phase 4 backward direction is too complex for a single dispatch**:
- Mark as [PARTIAL], commit the forward direction and the formula construction. The backward direction can be continued in a subsequent dispatch.
- The forward direction + formula construction is useful infrastructure even without the backward direction.

**If chronicle_gap_contradiction Case B is non-trivial (Phase 5)**:
- Mark Case B as a separate sorry with a TODO comment
- Create a follow-up task for Case B
- The Kamp chain closure (the primary goal) is independent of the chronicle gap

**If the approach fails entirely**:
- All existing sorry-free code (~4000+ lines including Rabinovich files) remains valid
- The NegationClosure.lean:1712 (`nf_exist_formula_nested_backward`) sorry remains as an alternative path
- Consider a completely different approach: direct EF-game-based proof of expressive completeness
