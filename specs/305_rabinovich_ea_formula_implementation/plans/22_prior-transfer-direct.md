# Implementation Plan: Direct PriorComposition Transfer via Model-Dependent Negation Closure

- **Task**: 305 - rabinovich_ea_formula_implementation
- **Status**: [NOT STARTED]
- **Effort**: 6 hours
- **Dependencies**: None (EANegationClosure, VecEATranslation, NfToVecEA all sorry-free)
- **Research Inputs**: reports/20_eanegation-sorry-analysis.md, reports/17_faithful-bridge-design.md, handoffs/phase-1-model-indep-blocker-20260623.md
- **Artifacts**: plans/22_prior-transfer-direct.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Plan v21 (EndpointBracketFormula approach) is blocked: the model-independent biconditional `neg_bracket_is_vbracket` requires a FIXED finite V-bracket for ALL models, but the beta_0(r0) case creates a self-referential structure that cannot be finitely represented. However, the implementation agent discovered that the two sorry sites S1 and S2 in EANegation.lean are UNUSED downstream -- no other file references them.

The actual downstream blockers are `prior_2var_transfer_until` and `prior_2var_transfer_since` in PriorComposition.lean (lines 131, 162), which are used at KampBypass.lean lines 646 and 713. These are mathematically independent from the EA negation closure: they transfer 2-var NF agreement between models given 1-var agreement at each variable. The proof decomposes into atom agreement (already sorry-free via `nonconstenv_atom_agree_until/since`) plus existential condition transfer, where each existential condition can be expressed as a temporal formula via `char_correct` at depth K+1 and transferred via 1-var agreement at depth K+2.

This plan abandons the model-independent V-bracket biconditional approach entirely and instead proves the transfer theorems directly using the existing sorry-free infrastructure.

### Research Integration

- **Report 20**: Root cause analysis of S1/S2 sorry stubs, downstream sorry chain traced to PriorComposition.lean
- **Report 17**: Confirmed all VecEA infrastructure is sorry-free, model-dependent path documented
- **Handoff (phase-1-model-indep-blocker-20260623.md)**: Definitive finding that S1/S2 are unused, Option A (direct Prior transfer) recommended with zone decomposition strategy

## Goals & Non-Goals

**Goals**:
- Prove `prior_2var_transfer_until` (PriorComposition.lean:131) without sorry
- Prove `prior_2var_transfer_since` (PriorComposition.lean:162) without sorry
- Verify `completeness_discrete` compiles sorry-free (no sorryAx)
- Verify full `lake build` succeeds

**Non-Goals**:
- Fixing `neg_bracket_is_vbracket` (EANegation.lean:1047) -- unused downstream, model-independent biconditional is fundamentally harder and not needed
- Fixing `neg_partialBracketExist_is_vbracket` (EANegation.lean:1172) -- unused downstream
- Modifying existing sorry-free infrastructure (EANegationClosure, VecEATranslation, VecEAClosure, NfToVecEA)
- Building EndpointBracketFormula type (plan v21 approach -- abandoned)
- Building model-independent VVecEA2 negation closure (not needed for transfer)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Zone-3 existential transfer requires expressing chi(x,t,w) as a temporal formula, but the NF structure at depth K+1 arity 1 may not directly decompose into temporal formulas | H | M | `char_correct` at d <= K+1 converts any depth-d arity-1 NF to a temporal formula. The quantifier body `nf_eval_nf M K (n+1) (Fin.cons w env) sub_nf` with arity-1 projection via `skipIdx` gives a depth-K arity-1 NF, which is within char_correct range (K <= K+1). |
| The existential `exists w, nf_eval_nf M K 3 (Fin.cons w (Fin.cons x (fun _ => t))) chi` mixes 3 variables; zone decomposition must handle all 5 ordering zones correctly | M | M | Atom agreement for zones 1,2,4,5 follows from 1-var agreement at the respective variable. Zone 3 (the interior) is the only non-trivial case. The existing `nonconstenv_atom_agree_until/since` handles the 2-var atom case; zone 3 extends this pattern to the 3-var case with the third variable in the interior. |
| The proof may require substantial helper lemmas for NF decomposition at arity 2 that do not currently exist | M | L | The NF structure at arity 2 decomposes as atoms + quantifier conditions (each at arity 3). The atom part is handled by `nonconstenv_atom_agree_until/since`. The quantifier conditions iterate over sub-NFs, each requiring the zone decomposition. The induction on depth K should provide the needed structure. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Prove prior_2var_transfer_until and prior_2var_transfer_since [BLOCKED]

**BLOCKER** (Phase 1):
- **What failed**: The quantifier step of the 2-var NF transfer requires a 3-var existential transfer at depth K+1. This transfer needs full 2-var NF agreement at depth K+1 as a hypothesis (h_rvar in the Boneyard's nvar_transfer_from_1var_agree). Without it, the zone analysis for the interior zone (t < w < x) cannot place a witness with matching depth-(K+1) 1-var NF type in the interval (t, x).
- **What was tried**: (1) Direct proof with zone decomposition using char_correct + UZ/SZ to find witnesses in the right interval -- blocked because UZ gives first occurrence above t but cannot guarantee it is below x. (2) Strong induction on K -- blocked because the IH at depth K+1 gives 2-var agreement at K+1 but the quantifier step needs 3-var existential transfer at K+1 which requires 2-var at K+2 (the target). (3) Adapting nf_skipIdx_cross pattern -- this only does projection (n+1 -> n), not lifting (n -> n+1). (4) Reverse nf_skipIdx_cross -- blocked because ordering between new variable and the "added back" variable is not determined.
- **Why stuck**: The theorem as stated requires establishing n-var NF agreement from 1-var agreements, which is an Ehrenfeucht-Fraisse back-and-forth argument. The archived Boneyard/PriorComposition.lean has a sorry-free nvar_transfer_from_1var_agree that solves this, but requires h_rvar (depth-(d+1) r-var agreement) as a hypothesis. For the main theorem at depth K+2, h_rvar needs depth-(K+3) 2-var agreement -- one depth above the target. The resolution is either (a) strong induction on K providing h_rvar from the IH, or (b) inlining the transfer into KampBypass.lean's mutual induction where the existential transfer hex is directly available from CharPart/ExistPart decomposition.
- **What is needed**: Restructure the proof to provide h_rvar. Two concrete options: (Option A) Prove by strong induction on K, using the IH at K-1 to supply h_rvar at depth K+1, then use nvar_transfer_from_1var_agree to get depth-K r-var agreement, and build up to depth K+2 using the algebraic upgrade from Boneyard's nf_eval_from_lower_agree. (Option B) Inline the transfer into KampBypass.lean where hex is available from the mutual induction.
- **Prohibited**: Do NOT use sorry, def X := True, or vacuous placeholder

**Goal**: Replace the two sorry stubs in PriorComposition.lean with complete proofs using NF structural induction and the available `char_correct` + 1-var agreement hypotheses.

**File**: `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/PriorComposition.lean` (MODIFY)

**Proof Strategy**: The theorem has signature:
```
prior_2var_transfer_until :
  ... h_x : (forall nf, nf_eval_nf M (K+2) 1 x nf <-> nf_eval_nf M0 (K+2) 1 x0 nf) ->
  ... h_t : (forall nf, nf_eval_nf M (K+2) 1 t nf <-> nf_eval_nf M0 (K+2) 1 t0 nf) ->
  ... char_correct : (forall d, d <= K+1 -> forall nf1, ...) ->
  ... sub_nf : NormalForm sig (K+2) 2 ->
  nf_eval_nf M0 (K+2) 2 (Fin.cons x0 (fun _ => t0)) sub_nf ->
  nf_eval_nf M (K+2) 2 (Fin.cons x (fun _ => t)) sub_nf
```

The key insight: `nf_eval_nf M (K+2) 2 env sub_nf` at depth K+2 with arity 2 decomposes as:
1. **Atom part**: `forall a, atom_eval M (Fin.cons x (fun _ => t)) a <-> (sub_nf.1 a = true)`
   - Already handled by `nonconstenv_atom_agree_until` (lines 30-60, sorry-free)
2. **Quantifier part**: `forall chi, (exists w, nf_eval_nf M (K+1) 3 (Fin.cons w (Fin.cons x (fun _ => t))) chi) <-> (sub_nf.2 chi = true)`
   - The existential `exists w, ...` is the same on both sides because sub_nf.2 chi is a boolean
   - Must show: `(exists w, nf_eval_nf M0 (K+1) 3 env0_w chi) -> (exists w, nf_eval_nf M (K+1) 3 env_w chi)`
   - This is the core: given w0 in M0 satisfying chi, find w in M satisfying chi

For the existential transfer, decompose by zones based on ordering of w relative to x and t:
- **Zone 1** (w <= t, Until case): w is at or below t. The 3-var NF evaluation at (w, x, t) with w <= t can be transferred using h_t (1-var agreement at t extends downward via Prior-UZ/SZ properties)
- **Zone 2** (w = t): degenerate, handled by zone 1
- **Zone 3** (t < w < x, Until case): w is strictly between t and x. This is the key case. The depth-(K+1) arity-3 NF chi at (w, x, t) can be projected to arity-1 NFs at w. By `char_correct` at depth <= K+1, the characteristic NF of w gives a temporal formula A such that `temporal_truth M atomMap w A <-> nf_eval_nf M d 1 (fun _ => w) nf_w`. Since h_t provides NF agreement at depth K+2 >= d+1, the temporal transfer gives a corresponding w' in M with the same depth-(K+1) 1-var NF type.
- **Zone 4** (w = x): handled by zone 5
- **Zone 5** (w >= x): w is at or above x. Transfer via h_x.

The proof proceeds by induction on K (the depth parameter minus 2). The base case K=0 has depth 2, arity 2, so the quantifier conditions are depth 1, arity 3. The step case reduces depth K+1 quantifier conditions to depth K via the inductive hypothesis.

Alternatively, a simpler approach: prove the transfer for the full NF by strong induction on the NF depth, decomposing into atoms (already done) + existential conditions. Each existential condition spawns a new 3-var point w; transfer w using the following: w in M0 satisfies a depth-(K+1) arity-1 NF (after projection). By `char_correct`, this NF corresponds to a temporal formula of depth <= K+1. By h_t or h_x at depth K+2, and the Prior-UZ/SZ properties, there exists a matching w in M. The 3-var NF agreement then follows from 1-var agreement at w, x, and t.

**Tasks**:
- [ ] Add helper lemma `exist_transfer_zone3_until`: given w0 in (t0, x0) satisfying a depth-(K+1) arity-3 NF chi in M0, construct w in M satisfying chi. Uses `char_correct` to characterize w0's depth-(K+1) arity-1 type, then `h_t` + Prior-UZ to find w between t and x in M with the same 1-var NF type, then lift to 3-var agreement.
- [ ] Add helper lemma `exist_transfer_zone3_since`: mirror for the Since case (w0 in (x0, t0))
- [ ] Add helper lemma `exist_3var_from_1var_agree`: if w, x, t in M have the same 1-var NF types (at appropriate depth) as w0, x0, t0 in M0, and the orderings match, then 3-var NF agreement holds. This uses structural induction on NF depth, with atom part from ordering + predicate agreement, and quantifier part from the inductive hypothesis.
- [ ] Prove `prior_2var_transfer_until`: decompose sub_nf into atom + quantifier parts. Atom part: apply `nonconstenv_atom_agree_until`. Quantifier part: for each chi, use zone decomposition on the existential witness w0, applying the appropriate helper lemma for each zone.
- [ ] Prove `prior_2var_transfer_since`: mirror of Until with reversed ordering zones
- [ ] Verify `grep -n sorry PriorComposition.lean` shows no sorry

**Timing**: 4 hours

**Depends on**: none

**Expected output**: ~200-400 lines of proof in PriorComposition.lean (replacing 2 sorry lines and adding helper lemmas)

**Verification**:
- `lake build Bimodal.Metalogic.WeakCanonical.Kamp.PriorComposition` succeeds
- `grep -n sorry PriorComposition.lean` returns 0 matches
- `lean_verify` on `prior_2var_transfer_until` and `prior_2var_transfer_since` reports no sorryAx

---

### Phase 2: Integration Verification and Sorry Audit [NOT STARTED]

**Goal**: Verify that the sorry elimination propagates through the full call chain to `completeness_discrete`. Run full build and sorry audit.

**Tasks**:
- [ ] `lake build Bimodal.Metalogic.WeakCanonical.Kamp.KampBypass` -- verify compiles (uses prior_2var_transfer at lines 646, 713)
- [ ] `lake build Bimodal.Metalogic.WeakCanonical.Kamp.KampMutualInduction` -- verify compiles
- [ ] `lake build Bimodal.Metalogic.WeakCanonical.Kamp.KampPrior` -- verify compiles
- [ ] `lean_verify` on `completeness_discrete` -- confirm no sorryAx
- [ ] Full `lake build` -- verify clean project build
- [ ] Sorry audit: `grep -rn sorry Theories/Bimodal/Metalogic/WeakCanonical/Kamp/` -- catalog remaining sorrys
  - Expected remaining: only EANegation.lean:1047 and EANegation.lean:1172 (unused downstream, model-independent biconditionals)
- [ ] Document sorry status in a brief note

**Timing**: 2 hours

**Depends on**: 1

**Files to verify** (no modifications expected):
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampBypass.lean`
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampMutualInduction.lean`
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean`
- Full project via `lake build`

**Verification**:
- `lake build` succeeds with no errors
- `lean_verify` on `completeness_discrete` reports no sorryAx
- Only dead-code sorrys remain in EANegation.lean (unused model-independent biconditionals)

## Testing & Validation

- [ ] Phase 1: `prior_2var_transfer_until` and `prior_2var_transfer_since` compile sorry-free
- [ ] Phase 1: `lean_verify` on both theorems reports no sorryAx
- [ ] Phase 2: `KampBypass.lean` compiles without modification
- [ ] Phase 2: `completeness_discrete` -- no sorryAx
- [ ] Phase 2: Full `lake build` succeeds

## Artifacts & Outputs

- `specs/305_rabinovich_ea_formula_implementation/plans/22_prior-transfer-direct.md` -- this plan
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/PriorComposition.lean` (MODIFIED, ~200-400 lines changed) -- sorry stubs replaced with proofs

## Postmortem Constraints (from v9-v21 and 20+ research rounds)

1. **S1 and S2 in EANegation.lean are UNUSED** -- do not attempt to fix them. The model-independent biconditional `neg_bracket_is_vbracket` is fundamentally harder than the model-dependent version and is not needed for completeness. 17 research rounds and 21 plan versions confirm this.
2. **The EndpointBracketFormula approach (v21) is blocked** -- the beta_0(r0) case creates self-referential V-bracket structure. Rabinovich's proof works on paper because the bracket is a syntactic notation, not a finite object. In Lean, the V-bracket must be a concrete finite data structure.
3. **The direct transfer approach uses EXISTING sorry-free infrastructure** -- `nonconstenv_atom_agree_until/since` (atom part), `char_correct` (temporal formula characterization), `nf_characteristic_satisfies` / `nf_agreement_from_shared_nf` (NF agreement), Prior-UZ/SZ (semantic properties). No new types or major definitions needed.
4. **Do NOT modify existing sorry-free files** -- PriorComposition.lean is the ONLY file that needs changes. Do not touch EANegation.lean, EANegationClosure.lean, VecEATranslation.lean, NfToVecEA.lean, or any other file.
5. **Zone decomposition is the standard technique** -- for transferring existential witnesses between models with matching 1-var NF types. The implementation agent's handoff confirms this is the recommended approach.
6. **Additive-only except at sorry sites** -- modify PriorComposition.lean to replace sorry with proofs and add helper lemmas. No other file modifications.
7. **The proof depth arithmetic works** -- char_correct at d <= K+1, h_x and h_t at depth K+2. Zone-3 witnesses have depth-(K+1) 1-var NF types, which are within char_correct range. The first-occurrence minimality argument bounds transferred witnesses to the correct interval.

## Rollback/Contingency

- **Phase 1**: Modifies PriorComposition.lean. Rollback = `git checkout -- PriorComposition.lean` (restores sorry stubs).
- **Phase 2**: Verification only -- no rollback needed.
- **If zone decomposition approach is blocked**: The alternative is to prove the transfer using the `nf_skipIdx_cross` infrastructure already in PriorComposition.lean (lines 201-273), which transfers n-var NF agreement to (n-1)-var agreement via index projection. This avoids zone decomposition entirely but requires showing that the full 3-var agreement lifts from 1-var agreements at each component, which is the same core problem stated differently.
- Git per-phase commits enable rollback to any intermediate state.
