# Implementation Plan: Depth-Induction Fill for prior_exist_transfer_one_dir

- **Task**: 305 - Rabinovich EA-formula implementation
- **Status**: [NOT STARTED]
- **Effort**: 4 hours
- **Dependencies**: Phases 1-5, 6a-6c [COMPLETED] from prior plans; sorry-free nvar_transfer_from_1var_agree, exist_transfer_from_full_agree, reconstruction_depth_agree
- **Research Inputs**: specs/305_rabinovich_ea_formula_implementation/reports/07_zone3-induction-design.md
- **Artifacts**: plans/11_depth-induction-plan.md (this file)
- **Standards**:
  - .claude/rules/artifact-formats.md
  - .claude/rules/state-management.md
  - .claude/context/formats/plan-format.md
  - .claude/rules/plan-format-enforcement.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Plan v10 (VecEA bridge) attempted to resolve the 5 sorries in PriorComposition.lean via a standalone bridge file (PriorExistPart.lean) that would convert bounded 3-var existentials into temporal formulas and transfer via 1-var agreement. Phase 1 was BLOCKED because 1-var NF agreement at individual endpoints t/t' and x/x' does NOT jointly constrain the interval (t',x'). The bounded existential `exists w in (t',x')` requires joint pair information about [x,t]/[x',t'] -- the very 2-var agreement being proved. All 5 approaches tried (cross_extend, VecEA2 temporal, nested Until, Prior-UZ, depth-1 encoding) fail for this same fundamental reason.

The correct resolution is much simpler and does not require new files: fill the existing `prior_exist_transfer_one_dir` sorry (line 524 of PriorComposition.lean) via `Nat.rec` on the NF depth `d`, then wire the 4 downstream sorry sites (lines 595/599/650/654) using that lemma. The key insight from research report 07: the quantifier conditions at depth d need (r+2)-var existential transfer at depth d-1, which is provided by the IH. The arity grows but the depth strictly decreases, giving well-founded termination on d alone.

Definition of done: `PriorComposition.lean` compiles sorry-free; `lake build` succeeds with no sorry on the critical path through KampBypass to completeness_discrete.

### Research Integration

Report 07 (zone3-induction-design) analyzed 8 approaches and verified that the one-directional depth-induction approach is sound. The function signature already exists at line 491-514 with exactly the right type; only the sorry at line 524 needs replacement. Report 07 confirmed the Nat.rec strategy, the K=0 edge case handling, and the well-founded termination argument.

### Prior Plan Reference

Plan v10 was BLOCKED at Phase 1. The VecEA bridge approach is abandoned. Plan v9 was BLOCKED at Phase 1 for the same depth-gap reason (bidirectional approach). The sorry-free infrastructure from earlier plans (nvar_transfer_from_1var_agree, exist_transfer_from_full_agree, reconstruction_depth_agree, zone 1/2/4/5 transfer code) remains intact and is used by this plan.

### Postmortem Constraints (Accumulated)

1. Do NOT attempt `nvar_transfer_from_1var_agree` at depth K+1 arity 3 -- requires h_rvar at depth K+2 arity 3 (circular, proven by 8 failed approaches across 3 cycles).
2. Do NOT seek full biconditional NF agreement at the new witness -- only one-directional existential transfer needed.
3. Do NOT use `exist_transfer_from_full_agree` as the primary mechanism for depth K+1 -- it outputs depth K (one short).
4. Do NOT modify existing sorry-free infrastructure (NfToVecEA, VecEADecomp, VecEATranslation, RabinovichTranslation, NfComposition, VecEAClosure, nvar_transfer_from_1var_agree, etc.).
5. Do NOT create standalone bridge files (PriorExistPart.lean) -- all work is within PriorComposition.lean.
6. Do NOT attempt temporal formula conversion as a transfer mechanism -- the bounded existential cannot be decomposed to individual endpoints.

## Goals & Non-Goals

**Goals**:
- Fill the sorry at line 524 (`prior_exist_transfer_one_dir`) via `Nat.rec` on depth d
- Wire the 4 downstream sorry sites (lines 595/599/650/654) using `prior_exist_transfer_one_dir`
- Achieve `lake build` clean on the entire Kamp module (PriorComposition.lean sorry-free)
- Verify `completeness_discrete` compiles sorry-free (propagation through KampBypass)

**Non-Goals**:
- Proving full biconditional r-var NF agreement for zone-3 witnesses
- Modifying the outer strong induction structure of prior_nonconstenv_2var_agree_until/since
- Creating new files (all work is in PriorComposition.lean)
- Changes to NfToVecEA.lean, VecEADecomp.lean, VecEATranslation.lean, or RabinovichTranslation.lean
- Dead-code sorry elimination in NfCharFormula.lean or EANegation.lean
- Restructuring nvar_transfer_from_1var_agree

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Arity-growing recursion fails Lean's termination checker | H | M | Use `decreasing_by omega` or explicit well-founded measure on d alone. The recursion only decreases d; arity r grows but is universally quantified per call, not part of the recursive structure. |
| K=0 edge case: ih_strong is vacuous and char_correct bound d <= 0 is degenerate | M | L | Handle K=0 separately: at d=0 the sub_nf is purely atomic. Atom transfer uses h_1var and h_order directly. No char_fn needed at d=0. |
| Depth gap at recursion: quantifier conditions at depth d need (r+2)-var existential transfer at depth d-1 but IH only provides (r+1)-var | H | L | IH is universally quantified over ALL arities r. At depth d, quantifier conditions produce sub-sub-NFs at depth d-1 arity (r+2). Apply IH at d-1 with r' = r+1 to get the (r+2)-var existential transfer. |
| Zone analysis for general arity r: need to case-split on where the new witness z sits relative to ALL r env elements | M | M | The char_fn formulas characterize 1-var NF types. HasAttainedINF.first_occ (from Prior-UZ) finds a witness between any two ordered points with the right 1-var type. Zone 3 (between two specific env elements) is the only non-trivial case; zones 1/2/4/5 use cross_extend. |
| cross_extend_bwd_1var witness w2 does not satisfy sub_nf at higher depths | M | M | At depth 0, w2 satisfies atoms directly. At depth d+1, w2's 1-var agreement plus IH at d gives the quantifier conditions. The reconstruction_depth_agree machinery handles the depth climb. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Fill prior_exist_transfer_one_dir Sorry (Line 524) [BLOCKED]

**BLOCKER** (Phase 1):
- **What failed**: The theorem `prior_exist_transfer_one_dir` as stated (with only h_1var at depth d+1 for each env component + h_order) is not provable by induction on d alone. The zone-3 witness placement requires finding z' in N with correct ordering relative to ALL r env elements simultaneously, but:
  - `cross_extend_bwd_1var` from a single anchor gives ordering relative to ONE anchor only
  - The Prior-UZ/SZ axioms find first/last occurrences but cannot guarantee existence in a specific interval without independent confirmation
  - Building depth-(d+1) r-var agreement (which would give correct ordering via quantifier conditions) requires `exist_transfer_from_full_agree` at depth d+1, which itself needs the agreement at depth d+2 (circular)
  - The research report (07_zone3-induction-design.md) confirmed after 8 approaches that every mechanism via `nvar_transfer_from_1var_agree` or `exist_transfer_from_full_agree` hits a one-depth circular dependency
- **What was tried**:
  1. Induction on d with cross_extend for witness + zone analysis for ordering: ordering relative to non-anchor env elements not provable from single cross_extend
  2. Building depth-(d+1) r-var agreement from h_1var + IH: quantifier conditions of agreement need the very existential transfer being proved (circular)
  3. Combined induction proving both transfer and agreement: circular at same depth level
  4. Using `exist_transfer_from_full_agree` from IH-derived agreement: always one depth short
  5. Zone-3 via Prior-UZ/SZ with char_fn: cannot guarantee formula holds in specific interval (envN_lo, envN_hi)
  6. Adding h_rvar parameter: callers cannot supply it (they have depth K+1 from ih_strong but need K+2)
- **Why stuck**: The depth-one-offset in NF quantifier structure (depth-(d+1) NF has quantifiers at depth d) creates a fundamental circularity when the only available data is componentwise 1-var agreements. Every approach either needs one depth higher than available or creates circular dependence.
- **What is needed**: The outer theorem `prior_nonconstenv_2var_agree_until/since` must be restructured to either:
  (a) Generalize the strong induction to prove ALL arities r simultaneously (not just r=2), allowing h_rvar to come from ih_strong at the same K but different arity
  (b) Wire the zone-3 existential transfer directly in the outer theorem using the one-directional depth-induction approach from report 07 (well-founded on depth d with arity universally quantified, using ih_strong's 2-var quantifier conditions for witness localization)
  (c) Both: restructure as a single theorem `prior_composition_all_arities` that proves r-var agreement for all r >= 2 by strong induction on K
- **Prohibited**: Do NOT use sorry, def X := True, or vacuous placeholder

**Goal**: Replace the sorry at line 524 of PriorComposition.lean with a proof by `Nat.rec` on d (NF depth), with arity r universally quantified at each step.

**Tasks**:
- [ ] Replace `sorry` at line 524 with `Nat.rec` (or `induction d with`) on the depth parameter d
- [ ] **Base case (d=0)**: Sub_nf is a depth-0 NF at arity r+1. The existential `exists z, nf_eval_nf M 0 (r+1) (Fin.cons z envM) sub` is purely atomic. Strategy:
  - Extract the 1-var NF type of z (its characteristic NF at depth 1)
  - Use ih_2var quantifier condition: from h_1var at depth d+1=1, the characteristic NF of z's 1-var type exists at some z' in N with matching 1-var type
  - For zone-3 witness (z between two env elements): use HasAttainedINF.first_occ with char_fn formula at depth 0 to find z' between the corresponding env' elements. The UZ/SZ axioms guarantee the zone-3 witness exists.
  - Verify atoms: predicates transfer via 1-var agreement (from matched NF type), orders transfer via zone placement + h_order
  - Apply depth0_3var_witness_check (or generalized version) to assemble the nf_eval_nf proof
- [ ] **Inductive step (d+1)**: Sub_nf at depth d+1 arity r+1 decomposes into atom part and quantifier part.
  - Atoms: same as base case (predicate and order matching from 1-var agreement at depth d+2)
  - Quantifier conditions: for each quantifier sub-sub-nf `chi` at depth d arity r+2, need `exists z'', nf_eval_nf N d (r+2) (Fin.cons z'' (Fin.cons z' envN)) chi` from the corresponding M-side existential. Apply the IH at depth d with arity r+1 (the IH provides one-directional transfer for ALL arities).
  - The IH inputs: h_1var at depth d+1 for the new env (including z and z'), h_order for the extended env, sub = chi. These are obtained from the reconstruction_depth_agree machinery applied to the witness z/z'.
- [ ] Handle termination: ensure Lean accepts the recursion. The measure is d alone (strictly decreasing). Arity r is universally quantified, not part of the recursive call structure. Use `decreasing_by omega` if needed.
- [ ] Verify `prior_exist_transfer_one_dir` compiles sorry-free via `lake build Bimodal.Metalogic.WeakCanonical.Kamp.PriorComposition`

**Timing**: 2 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/PriorComposition.lean` (~150-200 lines replacing the sorry block at line 524)

**Key Function Signature** (lines 491-514, already exists):
```lean
private theorem prior_exist_transfer_one_dir {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (M N : OrderedMonadicStructure sig)
    (h_UZ_M : semantic_prior_UZ M atomMap) (h_SZ_M : semantic_prior_SZ M atomMap)
    (h_UZ_N : semantic_prior_UZ N atomMap) (h_SZ_N : semantic_prior_SZ N atomMap)
    (K : Nat)
    (char_fn : ∀ (d : Nat), NormalForm sig d 1 → Formula)
    (char_correct : ∀ (d : Nat) (_ : d ≤ K + 1) (nf_1 : NormalForm sig d 1)
        (S : OrderedMonadicStructure sig)
        (_ : semantic_prior_UZ S atomMap) (_ : semantic_prior_SZ S atomMap)
        (t : S.carrier),
        temporal_truth S atomMap t (char_fn d nf_1) ↔
        nf_eval_nf S d 1 (fun _ => t) nf_1) :
    ∀ (d : Nat) (_ : d ≤ K + 1) (r : Nat)
      (envM : Fin r → M.carrier) (envN : Fin r → N.carrier)
      (_ : ∀ (i : Fin r), ∀ nf : NormalForm sig (d + 1) 1,
        nf_eval_nf M (d + 1) 1 (fun _ => envM i) nf ↔
        nf_eval_nf N (d + 1) 1 (fun _ => envN i) nf)
      (_ : ∀ (i j : Fin r), envM i < envM j ↔ envN i < envN j)
      (sub : NormalForm sig d (r + 1)),
      (∃ z : M.carrier, nf_eval_nf M d (r + 1) (Fin.cons z envM) sub) →
      ∃ z' : N.carrier, nf_eval_nf N d (r + 1) (Fin.cons z' envN) sub
```

**Key Available Infrastructure**:
- `exist_transfer_from_full_agree` (line 222): depth-d (n+2)-var existential transfer from depth-(k+1) (n+1)-var agreement. Useful for the inductive step when we have full agreement at the witness.
- `reconstruction_depth_agree` (line 293): builds depth-d agreement for all d <= K+1 from depth-(K+1) agreement. Useful for climbing from matched witnesses.
- `nf_characteristic_satisfies`: gives the characteristic NF at any env. Used to lift depth-d witness matching to depth-(d+1).
- `cross_extend_bwd_1var`/`cross_extend_fwd_1var`: finds witnesses with matching 1-var types in outer zones.
- `HasAttainedINF.first_occ` (from PriorINF): Prior-UZ gap placement for zone-3 witnesses.
- `char_fn`/`char_correct`: temporal formulas characterizing 1-var NF types, available at depths d' <= K+1.
- `depth0_3var_witness_check` (line 152): assembles depth-0 3-var NF from individual atom conditions.

**Proof Sketch**:
```
Nat.rec on d:
  Base (d=0):
    Given: ∃ z, nf_eval M 0 (r+1) (Fin.cons z envM) sub
    sub is purely atomic at depth 0
    z has a 1-var type at depth 1; by h_1var the env elements have matched types
    Use char_fn at depth 0 for z's 1-var type
    Apply semantic_prior_UZ/SZ with char_fn to find z' between matched envN elements
    Verify atoms at z'/envN via predicate agreement + order placement
    
  Step (d+1 → d):
    Given: ∃ z, nf_eval M (d+1) (r+1) (Fin.cons z envM) sub
    Extract atom part + quantifier part of sub
    Find z' candidate via cross_extend + char_fn (same as base)
    Atom part: transfers as in base case
    Quantifier part: for each chi at depth d arity r+2:
      Have: ∃ w, nf_eval M d (r+2) (Fin.cons w (Fin.cons z envM)) chi
      Need: ∃ w', nf_eval N d (r+2) (Fin.cons w' (Fin.cons z' envN)) chi
      Apply IH at depth d with env = (Fin.cons z envM), env' = (Fin.cons z' envN)
      IH inputs: h_1var at depth (d+1) for z/z' and envM/envN elements (from matched types),
                  h_order for extended env (from zone placement + h_order)
```

**Verification**:
- `prior_exist_transfer_one_dir` compiles sorry-free
- Sorry count in PriorComposition.lean drops from 5 to 4

---

### Phase 2: Wire 4 Downstream Sorry Sites (Lines 595/599/650/654) [NOT STARTED]

**Goal**: Replace the 4 remaining sorry sites in `prior_nonconstenv_2var_agree_until` and `prior_nonconstenv_2var_agree_since` with applications of `prior_exist_transfer_one_dir`.

**Tasks**:
- [ ] **Line 595** (Until forward: `exists w in M -> exists w' in N`):
  - Context: `w : M.carrier`, `hw : nf_eval M (K+1) 3 [w,x,t] sub_nf`, `w2 : N.carrier` from `cross_extend_bwd_1var`
  - Replace `sorry` with application of `prior_exist_transfer_one_dir` at d = K+1, r = 2:
    - `envM = Fin.cons x (fun _ => t)`, `envN = Fin.cons x' (fun _ => t')`
    - h_1var: depth-(K+2) 1-var agreement at x/x' (from h_x) and t/t' (from h_t)
    - h_order: order matching (t < x iff t' < x', from h_order_M/h_order_N)
    - sub = sub_nf, witness = w, goal = exists w' with nf_eval N (K+1) 3 [w',x',t'] sub_nf
  - Note: the cross_extend_bwd_1var result `w2` is not used; the transfer lemma finds its own witness
- [ ] **Line 599** (Until backward: `exists w' in N -> exists w in M`):
  - Symmetric to line 595 with M and N swapped
  - Apply `prior_exist_transfer_one_dir` with M := N, N := M (reversed direction)
  - h_1var: use `(h_x _).symm` and `(h_t _).symm` for the reverse direction
  - h_order: use `h_order_N` / `h_order_M` reversed
  - Note: the cross_extend_fwd_1var result `w2` is not used
- [ ] **Line 650** (Since forward: `exists w in M -> exists w' in N`):
  - Same structure as line 595 but with reversed order (x < t in M, x' < t' in N)
  - Apply `prior_exist_transfer_one_dir` with appropriate env ordering
- [ ] **Line 654** (Since backward: `exists w' in N -> exists w in M`):
  - Symmetric to line 650 with M and N swapped
- [ ] Remove unused `cross_extend_bwd_1var`/`cross_extend_fwd_1var` calls at lines 594/598/649/653 if they are no longer needed (the transfer lemma finds its own witnesses)
- [ ] Verify PriorComposition.lean compiles sorry-free via `lake build Bimodal.Metalogic.WeakCanonical.Kamp.PriorComposition`

**Timing**: 1.5 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/PriorComposition.lean` (~60-100 lines replacing 4 sorry sites around lines 590-655)

**Key Insight**: All 4 sorry sites have the same pattern:
```
  obtain <w2, hw2> := cross_extend_..._1var M t N t' h_t w
  exact <w2, sorry>
```
Replace with:
```
  exact prior_exist_transfer_one_dir atomMap M N h_UZ_M h_SZ_M h_UZ_N h_SZ_N
    K char_fn char_correct (K+1) (by omega) 2
    (Fin.cons x (fun _ => t)) (Fin.cons x' (fun _ => t'))
    (fun i => Fin.cases h_x (fun _ => h_t) i)
    (fun i j => ...)
    sub_nf <w, hw>
```
(Or the reverse-direction variant for backward cases.)

**Important**: The `cross_extend_bwd_1var`/`cross_extend_fwd_1var` lines (594, 598, 649, 653) should be removed or commented out since the transfer lemma finds its own witnesses internally. Keeping them would introduce unused variables.

**Verification**:
- `grep -n sorry Theories/Bimodal/Metalogic/WeakCanonical/Kamp/PriorComposition.lean` returns no results
- `lake build Bimodal.Metalogic.WeakCanonical.Kamp.PriorComposition` succeeds sorry-free

---

### Phase 3: Integration Verification and Sorry Audit [NOT STARTED]

**Goal**: Verify sorry elimination propagates through KampBypass to completeness_discrete, run full project build, and confirm no regressions.

**Tasks**:
- [ ] Run `lake build Bimodal.Metalogic.WeakCanonical.Kamp.KampBypass` -- verify sorry-free
- [ ] Run `lake build Bimodal.Metalogic.WeakCanonical.Kamp.KampMutualInduction` -- verify sorry-free
- [ ] Run `lake build Bimodal.Metalogic.WeakCanonical.Kamp.KampPrior` -- verify sorry-free
- [ ] Run `lean_verify` on `completeness_discrete` to confirm no sorry axiom
- [ ] Run full `lake build` -- verify clean project build
- [ ] Final sorry audit: `grep -rn sorry Theories/Bimodal/Metalogic/WeakCanonical/Kamp/` to confirm only non-critical dead-code sorries remain (NfCharFormula.lean, EANegation.lean)
- [ ] Optional cleanup: remove stale comments referencing VecEA bridge approach in PriorComposition.lean if any were added during v10 implementation attempts

**Timing**: 0.5 hours

**Depends on**: 2

**Files to verify** (no modifications expected):
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampBypass.lean`
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampMutualInduction.lean`
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean`

**Verification**:
- `lake build` succeeds with no sorry on critical path
- `lean_verify` on `completeness_discrete` reports no sorry axiom
- `grep -rn sorry Theories/Bimodal/Metalogic/WeakCanonical/Kamp/` shows only NfCharFormula.lean and EANegation.lean non-critical sorries

## Testing & Validation

- [ ] Phase 1: `prior_exist_transfer_one_dir` compiles sorry-free; sorry count drops from 5 to 4
- [ ] Phase 2: All 4 downstream sorry sites eliminated; PriorComposition.lean sorry-free
- [ ] Phase 3: `completeness_discrete` compiles sorry-free (no sorry axiom via lean_verify)
- [ ] Phase 3: Full `lake build` succeeds with clean project build
- [ ] Final sorry audit confirms only non-critical-path sorries remain (NfCharFormula.lean, EANegation.lean)

## Artifacts & Outputs

- `plans/11_depth-induction-plan.md` -- this plan
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/PriorComposition.lean` -- sorry-free (Phases 1-2)

## Rollback/Contingency

- Phase 1 modifies the sorry at line 524. Rollback = `git revert` to pre-Phase-1 commit.
- Phase 2 modifies 4 sorry sites around lines 590-655. Rollback = `git revert` to pre-Phase-2 commit.
- Phase 3 is verification only. No rollback needed.
- Git per-phase commits enable rollback to any intermediate state.
- **If Lean's termination checker rejects the Nat.rec**: use `Nat.strongRecOn` or explicit well-founded recursion with `WellFoundedRelation` on d. The termination argument is d decreasing, which is trivially well-founded.
- **If zone-3 witness placement via char_fn + Prior-UZ fails at general arity**: specialize to the 2-element env case (r=2) first, verify it works, then generalize. The 4 downstream consumers all use r=2 (env = [x,t]).
- **If h_1var inputs for the IH at the extended env are hard to construct**: use nf_agreement_monotone to weaken the available depth-(K+2) 1-var agreement down to depth-(d+1) as needed. The signature requires h_1var at depth (d+1), which is <= K+2 by the bound d <= K+1.
