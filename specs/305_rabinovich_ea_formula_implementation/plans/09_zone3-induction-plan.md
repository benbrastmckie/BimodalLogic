# Implementation Plan: One-Directional Zone-3 Existential Transfer

- **Task**: 305 - Rabinovich EA-formula implementation
- **Status**: [COMPLETED]
- **Effort**: 6 hours
- **Dependencies**: Phases 1-5, 6a-6c [COMPLETED]; Phase 6d [BLOCKED] (prior plan v8)
- **Research Inputs**: specs/305_rabinovich_ea_formula_implementation/reports/07_zone3-induction-design.md
- **Artifacts**: plans/09_zone3-induction-plan.md (this file)
- **Standards**:
  - .claude/rules/artifact-formats.md
  - .claude/rules/state-management.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

This plan resolves the final 4 sorries in `PriorComposition.lean` (lines 563, 568, 619, 623) by implementing a new lemma `prior_zone3_exist_transfer` proved by well-founded induction on the NF depth d (decreasing), with arity universally quantified. The key insight: we need only ONE direction of existential transfer (not full biconditional agreement), which avoids the circular h_rvar dependency that blocked all prior approaches. At each induction step, `ih_strong`'s 2-var quantifier condition provides a zone-3 witness at depth d-1, atoms are verified directly, and quantifier conditions are handled by recursive descent to depth d-1.

### Research Integration

Report 07 (zone3-induction-design) exhaustively analyzed 8 approaches and verified via H4 adversarial self-verification that every bidirectional approach hits the h_rvar circularity. The recommended resolution: one-directional existential transfer by well-founded induction on sub_nf depth. The termination argument is sound (depth decreases; arity does not appear in the well-founded measure). The base case (d=0) is purely atomic.

### Prior Plan Reference

Plan v8 (strengthen-inputs-plan) completed phases 1-5 and 6a-6c successfully (nvar_transfer_from_1var_agree is now sorry-free). Phase 6d was BLOCKED because:
- Applying nvar_transfer_from_1var_agree at depth K+1, arity 3 requires h_rvar at depth K+2 arity 3 -- which is HARDER than the goal being proved
- The ih_strong at m=K-1 gives depth-(K+1) 2-var, whose quantifier condition gives depth-K (not K+1) 3-var existential transfer
- This one-depth gap is intrinsic to any approach seeking full biconditional agreement via nvar_transfer

Lessons learned: (1) The gap from depth K to K+1 cannot be bridged with nvar_transfer alone. (2) The existing sorry-free nvar_transfer mechanism works well when h_rvar is available but is NOT the right tool for the downstream consumers. (3) A fundamentally different architecture (one-directional, depth-decreasing induction) is needed for the final step.

### Roadmap Alignment

No ROADMAP.md found.

## Goals & Non-Goals

**Goals**:
- Define and prove `prior_zone3_exist_transfer` by well-founded induction on depth d
- Fill all 4 sorry sites (lines 563, 568, 619, 623) using this new lemma
- Achieve `lake build` clean on the entire Kamp module (PriorComposition.lean sorry-free)
- Verify that `completeness_discrete` compiles sorry-free (propagation through KampBypass)

**Non-Goals**:
- Proving full biconditional r-var agreement (only one direction is needed for existential transfer)
- Restructuring the outer strong induction to handle all arities simultaneously
- Modifications to the already sorry-free `nvar_transfer_from_1var_agree`
- Changes to EANegationClosure.lean (already sorry-free)
- Dead-code sorry elimination in NfCharFormula.lean

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Inner recursion on depth d encounters type-level termination issues in Lean (arity grows) | H | M | Use `Nat.rec` on d with explicit type annotation; the well-founded measure is d alone (monotone arity increase is invisible to the kernel). If Lean rejects, use `decreasing_by omega`. |
| The ih_2var quantifier condition produces a witness that does NOT lie in zone 3 | H | L | The research report proves this cannot happen: the quantifier condition of the 2-var NF at [x,t]/[x',t'] applied to the zone-3 characteristic chi encodes order t' < z' < x' in its atom part. The zone placement is guaranteed by the NF structure. |
| Quantifier conditions at depth d require reverse direction (N to M) in addition to forward | M | M | The sorry at line 568 (backward) needs M-to-N direction inverted. Use symmetric argument: apply cross_extend_fwd_1var and the same induction with M/N roles swapped. Factor the lemma to handle both directions via a parameter or prove a symmetric variant. |
| Extracting h_tw and h_wx from the NF atom part is not directly available as a lemma | M | M | Write a small helper `zone3_order_from_nf_eval` that extracts order atoms from the evaluation witness. This is a straightforward projection from the atom component of `nf_eval_nf`. |
| K=0 base case requires special handling (ih_strong is vacuous) | M | L | At K=0, the goal is depth-1 3-var transfer. The sub_nf is a depth-1 NF: atoms + depth-0 quantifier conditions. At depth 0, everything is atomic and transfers via h_x/h_t directly. Handle K=0 as a separate `match` branch. |

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

### Phase 1: Define `prior_zone3_exist_transfer` Statement and Base Case [COMPLETED]

**Resolution** (Phase 1): The h_agree_env approach from the user's task description was implemented
instead of the prior_zone3_exist_transfer lemma originally planned. The approach adds a joint r-var
agreement hypothesis (h_agree_env) to zone_compatible_witness. For d>=2 r>=1, the proof uses
exist_transfer_from_full_agree on h_agree_env to get matched witnesses at depth-(d-1) with full
(r+1)-var agreement, then nf_eval_from_lower_agree upgrades to depth d. Internal recursion on K in
prior_nonconstenv_2var_agree_until/since provides h_agree_env via the theorem at K-1.

*(deviation: altered -- replaced planned prior_zone3_exist_transfer with h_agree_env approach)*

**Goal**: Add the new lemma with its full type signature and prove the base case (d=0). The lemma proves one-directional existential transfer: given w in zone 3 of M satisfying depth-d 3-var sub_nf, produce w' in zone 3 of N satisfying the same sub_nf.

**Tasks**:
- [ ] Define the statement of `prior_zone3_exist_transfer` in `PriorComposition.lean` (above the `prior_nonconstenv_2var_agree_until` theorem, around line 475). Type signature:
  ```lean
  private theorem prior_zone3_exist_transfer {sig : MonadicSignature}
      (atomMap : Formula → sig.preds)
      (K : Nat)
      (M N : OrderedMonadicStructure sig)
      (h_UZ_M : semantic_prior_UZ M atomMap) (h_SZ_M : semantic_prior_SZ M atomMap)
      (h_UZ_N : semantic_prior_UZ N atomMap) (h_SZ_N : semantic_prior_SZ N atomMap)
      (x t : M.carrier) (x' t' : N.carrier)
      (h_order_M : t < x) (h_order_N : t' < x')
      (h_x : ∀ nf : NormalForm sig (K + 2) 1,
        nf_eval_nf M (K + 2) 1 (fun _ => x) nf ↔
        nf_eval_nf N (K + 2) 1 (fun _ => x') nf)
      (h_t : ∀ nf : NormalForm sig (K + 2) 1,
        nf_eval_nf M (K + 2) 1 (fun _ => t) nf ↔
        nf_eval_nf N (K + 2) 1 (fun _ => t') nf)
      (char_fn : ∀ (d : Nat), NormalForm sig d 1 → Formula)
      (char_correct : ∀ (d : Nat) (_ : d ≤ K + 1) (nf_1 : NormalForm sig d 1)
          (S : OrderedMonadicStructure sig)
          (h_UZ : semantic_prior_UZ S atomMap) (h_SZ : semantic_prior_SZ S atomMap)
          (t : S.carrier),
          temporal_truth S atomMap t (char_fn d nf_1) ↔
          nf_eval_nf S d 1 (fun _ => t) nf_1)
      (ih_2var : ∀ nf : NormalForm sig (K + 1) 2,
        nf_eval_nf M (K + 1) 2 (Fin.cons x (fun _ => t)) nf ↔
        nf_eval_nf N (K + 1) 2 (Fin.cons x' (fun _ => t')) nf) :
      ∀ (d : Nat) (_ : d ≤ K + 1)
        (sub_nf : NormalForm sig d 3)
        (w : M.carrier) (_ : t < w) (_ : w < x),
        nf_eval_nf M d 3 (Fin.cons w (Fin.cons x (fun _ => t))) sub_nf →
        ∃ w' : N.carrier, t' < w' ∧ w' < x' ∧
          nf_eval_nf N d 3 (Fin.cons w' (Fin.cons x' (fun _ => t'))) sub_nf
  ```
- [ ] Prove the base case d=0: sub_nf is purely atomic (AtomKind sig 3 -> Bool). Use ih_2var's quantifier condition at depth 1 (which gives depth-0 3-var existential transfer): apply to the characteristic of [w,x,t] at depth 0. The resulting z' has matching atoms, and from the order atoms extract t' < z' < x'.
- [ ] Verify with `lean_goal` that the base case compiles sorry-free
- [ ] Leave the inductive step as `sorry` for Phase 2

**Timing**: 1.5 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/PriorComposition.lean` -- new theorem (~40-60 lines for signature + base case)

**Verification**:
- `lean_goal` at the sorry for the inductive step shows a well-formed goal
- `lake build Bimodal.Metalogic.WeakCanonical.Kamp.PriorComposition` succeeds (sorry count should remain at 5: 4 downstream + 1 inductive step)

---

### Phase 2: Inductive Step -- Witness Localization via ih_2var [NOT STARTED]

**Goal**: Prove the inductive step (d+1, d <= K): find a zone-3 witness z' in N using ih_2var's quantifier condition, and verify its atom part matches sub_nf. Leave quantifier conditions as sorry.

**Tasks**:
- [ ] In the `succ d` case: extract sub_nf into its atom component and quantifier component via the NF structure (`obtain ⟨h_atoms, h_quant⟩ := hw`)
- [ ] Use `ih_2var` at depth d+1 (which is <= K+1): its quantifier condition gives depth-d 3-var existential transfer: `(∃ z, nf_eval M d 3 [z,x,t] chi) ↔ (∃ z', nf_eval N d 3 [z',x',t'] chi)`. Apply to `chi := nf_characteristic M d 3 (Fin.cons w (Fin.cons x (fun _ => t)))` to get z' in N.
- [ ] From z' satisfying the characteristic at depth d: extract atom agreement. The atom part gives t' < z' < x' (zone-3 placement) and predicate matching.
- [ ] Show z' satisfies the atom part of the original sub_nf (at depth d+1): since sub_nf's atoms are the same type as depth-d atoms (just boolean on AtomKind sig 3), and z' has depth-d agreement which includes all atoms. This may require `atom_agreement_from_nf` or direct extraction.
- [ ] Leave the quantifier part of sub_nf (depth-d 4-var existential conditions) as sorry for Phase 3
- [ ] Verify with `lean_goal` that the sorry for the quantifier part has the expected shape

**Timing**: 1.5 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/PriorComposition.lean` -- inductive step skeleton (~60-100 lines)

**Verification**:
- `lean_goal` at the quantifier sorry shows goal of form `∀ chi, (∃ u, nf_eval M d 4 ...) ↔ sub_nf.quant chi`
- Atom part compiles sorry-free
- Sorry count reduced to 5 (4 downstream + 1 quantifier step)

---

### Phase 3: Quantifier Conditions via Recursive Descent [NOT STARTED]

**Goal**: Fill the quantifier condition sorry from Phase 2. For each depth-d 4-var sub_nf in the quantifier part, use the fact that `hw`'s quantifier gives the M-side existential, and transfer it to N-side by recursive application at depth d (one lower) with arity 4 (one higher).

**Tasks**:
- [ ] For the quantifier condition: need `(∃ u', nf_eval N d 4 [u',z',x',t'] chi) ↔ sub_nf.quant chi`. Since sub_nf.quant chi = (∃ u, nf_eval M d 4 [u,w,x,t] chi) from hw, need forward and backward transfer.
- [ ] Forward direction (M to N): Given u in M with `nf_eval M d 4 [u,w,x,t] chi`, produce u' in N with `nf_eval N d 4 [u',z',x',t'] chi`. Use `exist_transfer_from_full_agree` from the depth-d 3-var agreement at [w,x,t]/[z',x',t'] (which we have from the ih_2var characteristic match). This gives depth-(d-1) 4-var existential transfer, which handles chi when d >= 1 and chi is at depth d-1.
- [ ] Handle the depth gap: `exist_transfer_from_full_agree` from depth-d 3-var gives depth-(d-1) 4-var transfer. But we need depth-d 4-var. Use the following mechanism: from the depth-d 3-var agreement at [w,x,t]/[z',x',t'], the quantifier condition DIRECTLY provides `(∃ u, nf_eval M (d-1) 4 [u,w,x,t] chi2) ↔ (∃ u', nf_eval N (d-1) 4 [u',z',x',t'] chi2)`. This IS at depth d-1. For depth-d 4-var chi: unpack chi into (atoms, quant), verify atoms at the witness found from the IH at depth d-1, then recurse for chi's quantifier at depth d-1 (arity 5). Terminate at depth 0 (atoms only).
- [ ] Implement the recursive chain: at each level, depth decreases by 1 and arity increases by 1. The IH of the outer d-induction handles this: the recursive call is at depth d-1 (strictly smaller), so well-founded termination holds regardless of arity.
- [ ] Handle the reverse direction (N to M): symmetric, using `exist_transfer_from_full_agree` in the reverse direction (or the backward direction of the depth-d 3-var agreement biconditional).
- [ ] Verify the entire `prior_zone3_exist_transfer` compiles sorry-free

**Timing**: 1.5 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/PriorComposition.lean` -- quantifier transfer (~80-120 lines)

**Key Mechanism**:
```
depth d+1, arity 3:
  -> atoms: from z' (depth-d 3-var agreement includes atoms)
  -> quantifier chi at depth d, arity 4:
     -> from depth-d 3-var agreement at [w,x,t]/[z',x',t']:
        quantifier condition gives depth-(d-1) 4-var existential transfer
     -> apply exist_transfer_from_full_agree at d-1 from the d-level agreement
     -> for the remaining 1-depth gap (d-1 to d at arity 4):
        use IH of outer induction at depth d (strictly < d+1)
        with base env [w,x,t]/[z',x',t'] treated as the new 3-element base
```

**Verification**:
- `prior_zone3_exist_transfer` compiles sorry-free
- `lean_verify` shows no sorry axiom
- Sorry count = 4 (only the downstream consumers remain)

---

### Phase 4: Fill Downstream Consumers (Lines 563/568/619/623) [NOT STARTED]

**Goal**: Apply `prior_zone3_exist_transfer` at the 4 sorry sites to complete the proof of `prior_nonconstenv_2var_agree_until` and `prior_nonconstenv_2var_agree_since`.

**Tasks**:
- [ ] Fill line 563 (Until forward): Replace `exact ⟨w₂, sorry⟩` with an application of `prior_zone3_exist_transfer`. The caller context has:
  - `w` in M with `hw : nf_eval_nf M (K+1) 3 (Fin.cons w (Fin.cons x (fun _ => t))) sub_nf`
  - From hw, extract `h_tw : t < w` and `h_wx : w < x` (order atoms from nf_eval)
  - Construct `ih_2var` for the lemma: from `ih_strong` at m=K-1 (for K >= 1), get depth-(K+1) 2-var agreement at [x,t]/[x',t']. For K=0, handle separately.
  - Apply `prior_zone3_exist_transfer` with d=K+1, obtaining ⟨w', h_tw', h_wx', hw'⟩
  - Return `⟨w', hw'⟩`
- [ ] Fill line 568 (Until backward): The backward direction needs `∃ w in M, nf_eval M (K+1) 3 [w,x,t] sub_nf` given `w'` in N. Apply the symmetric version: either define `prior_zone3_exist_transfer_rev` (M/N swapped) or factor the original to take a direction parameter. Use `cross_extend_fwd_1var` witness and the same induction with N as source, M as target.
- [ ] Fill line 619 (Since forward): Same as Until forward but with reversed order (x < t in M, x' < t' in N). The zone-3 witnesses are above x (not between t and x). Adjust the lemma call or define a Since variant.
- [ ] Fill line 623 (Since backward): Symmetric to line 619.
- [ ] Handle the K=0 edge case: at K=0, ih_strong is vacuous (no m < 0). The goal at K=0 is depth-1 3-var transfer. The sub_nf has atoms + depth-0 4-var quantifier. At depth 0, the quantifier is atomic and transfers via h_x/h_t directly. Verify this case is handled (either by the general lemma or a separate branch).
- [ ] Verify PriorComposition.lean compiles sorry-free

**Timing**: 1.5 hours

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/PriorComposition.lean` -- replace 4 sorry sites (~40-80 lines total)

**Verification**:
- `grep -n sorry Theories/Bimodal/Metalogic/WeakCanonical/Kamp/PriorComposition.lean` returns no results
- `lake build Bimodal.Metalogic.WeakCanonical.Kamp.PriorComposition` succeeds sorry-free

---

### Phase 5: Integration Verification and KampBypass Propagation [NOT STARTED]

**Goal**: Verify that sorry elimination propagates through KampBypass to completeness_discrete, and the full project builds clean.

**Tasks**:
- [ ] Run `lake build Bimodal.Metalogic.WeakCanonical.Kamp.KampBypass` -- verify sorry-free
- [ ] Run `lake build Bimodal.Metalogic.WeakCanonical.Kamp.KampMutualInduction` -- verify sorry-free
- [ ] Run `lake build Bimodal.Metalogic.WeakCanonical.Kamp.KampPrior` -- verify sorry-free
- [ ] Run `lean_verify` on `completeness_discrete` to confirm no sorry axiom
- [ ] Run full `lake build` -- verify clean project build
- [ ] Final sorry audit: `grep -rn sorry Theories/Bimodal/Metalogic/WeakCanonical/Kamp/` to confirm only non-critical dead-code sorrys remain (NfCharFormula.lean)
- [ ] If any downstream module has independent sorrys unrelated to PriorComposition, document them (not in scope for this plan)

**Timing**: 0.5 hours

**Depends on**: 4

**Files to verify** (no modifications expected):
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampBypass.lean`
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampMutualInduction.lean`
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean`

**Verification**:
- `lake build` succeeds with no sorry on critical path
- `lean_verify Bimodal.Metalogic.WeakCanonical.Kamp.KampPrior.completeness_discrete` reports no sorry axiom
- `grep -rn sorry Theories/Bimodal/Metalogic/WeakCanonical/Kamp/` shows only NfCharFormula.lean dead-code sorrys

## Testing & Validation

- [ ] Phase 1: Base case (d=0) compiles sorry-free within the new lemma
- [ ] Phase 2: Witness localization (atom part) compiles sorry-free; quantifier is isolated sorry
- [ ] Phase 3: `prior_zone3_exist_transfer` compiles fully sorry-free
- [ ] Phase 4: All 4 downstream sorry sites eliminated
- [ ] Phase 4: `prior_nonconstenv_2var_agree_until/since` compile sorry-free
- [ ] Phase 5: `completeness_discrete` compiles sorry-free (no sorry axiom)
- [ ] Phase 5: Full `lake build` succeeds
- [ ] Final sorry audit confirms only non-critical-path sorrys remain

## Artifacts & Outputs

- `plans/09_zone3-induction-plan.md` -- this plan
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/PriorComposition.lean` -- sorry-free (all phases)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampBypass.lean` -- sorry-free critical path (Phase 5, verification only)

## Postmortem Constraints (H8)

Previous plans failed for specific reasons that this plan must avoid:

1. **Do NOT attempt nvar_transfer_from_1var_agree at depth K+1 arity 3** -- it requires h_rvar at depth K+2 arity 3 which is circular (proven by 8 failed approaches).
2. **Do NOT seek full biconditional agreement at the new witness** -- only one direction (existence) is needed. Bidirectional approaches all hit the same circularity.
3. **Do NOT use exist_transfer_from_full_agree as the primary mechanism for depth K+1** -- it produces depth K (one short). It IS usable as a sub-mechanism within the recursive descent at LOWER depths.
4. **Do NOT increase phase size beyond H8 bounds** -- each phase targets ~100-500 lines of output and one clear sub-goal.

## Rollback/Contingency

- Phase 1 adds new code only (no modifications to existing proofs). Rollback = delete the new theorem.
- Phases 2-3 extend the same new theorem. Rollback = revert to the Phase 1 sorry.
- Phase 4 modifies existing sorry sites. Rollback = `git revert` to pre-Phase-4 commit (restores the sorry placeholders).
- Phase 5 is verification only. No rollback needed.
- Git per-phase commits enable rollback to any intermediate state.
- **If the one-directional induction proves infeasible** (e.g., Lean kernel rejects the termination argument): fall back to explicit well-founded recursion with `WellFoundedRelation` on Nat and `decreasing_by omega`, or restructure as a mutual definition with `termination_by d`.
