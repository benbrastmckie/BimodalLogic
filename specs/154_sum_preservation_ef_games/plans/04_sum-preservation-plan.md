# Implementation Plan: Task #154 - Sum Preservation via Bootstrap Sentence-Level Induction (v4)

- **Task**: 154 - sum_preservation_ef_games
- **Status**: [NOT STARTED]
- **Effort**: 10 hours
- **Dependencies**: None (Phase 1 already completed; NormalForm.lean infrastructure complete)
- **Research Inputs**: specs/154_sum_preservation_ef_games/reports/02_team-research.md, specs/154_sum_preservation_ef_games/reports/03_team-research.md
- **Artifacts**: plans/04_sum-preservation-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Prove `sum_preservation` (NEquivalence.lean) and `doets_lemma_1_4` (OrderedSum.lean): k-equivalence is preserved under ordered sums of monadic structures. Phase 1 (orderedSum definition with `Sigma.Lex.linearOrder`) is already completed. The previous plan (v3) attempted a joint multi-variable NF approach but the implementation agent confirmed the order atom blocker is fundamental and no source files were modified. This revision adopts a **bootstrap sentence-level approach** that completely rewrites `sum_nf_agree` with a simplified signature operating only at n=0 (sentence level). The bootstrap avoids the order atom problem because `AtomKind sig 0` is empty -- there are no atoms at all at the sentence level. Definition of done: `sum_preservation` sorry-free, `doets_lemma_1_4` sorry-free, `lake build` passes.

### Research Integration

- **Report 02** (team-research.md, round 2): Established normal form induction as the correct strategy, identified carrier_order type-signature blocker. Integrated in plan v2.
- **Report 03** (team-research.md, round 3): Confirmed order atom blocker is genuine: `AtomKind sig 1` has zero order atoms. Joint multi-variable NF characteristic equality identified as consensus fix. Integrated in plan v3.
- **Implementation Handoff** (analysis-handoff-20260516.md): Implementation agent confirmed blocker is fundamental; no source files modified; recommended rewrite with simplified signature removing n, env_M, env_N, h_idx, h_atoms, h_elem. Integrated in this plan.

### Prior Plan Reference

Plans v2 and v3 (specs/154_sum_preservation_ef_games/plans/): Phase 1 completed, Phases 2-3 blocked on order atom gap, no source modifications in v3 implementation attempt. This plan supersedes v3 with the bootstrap approach.

### Key Mathematical Insight

The current `sum_nf_agree` takes 6 compatibility hypotheses (n, env_M, env_N, h_idx, h_atoms, h_elem) and tries to prove NF agreement at arbitrary variable count n. The order atom problem arises because the 1-var component NF matching hypothesis (`h_elem`) cannot encode pairwise order relationships in n >= 2 variable environments.

The bootstrap approach eliminates this entirely:

1. **Sentence-level only**: The new `sum_nf_agree` proves agreement only at n=0 with empty environments. At n=0, `AtomKind sig 0` is empty (no pred atoms with `Fin 0` index, no order atoms), so the base case is vacuously true.

2. **Quantifier step**: At depth k+1 with n=0, the quantifier part asks about depth-k NFs with 1 variable. Given witness `(i, a)` in orderedSum ms, we use component (k+1)-equivalence to find `b` in ms'(i) sharing the same depth-k 1-var component NF characteristic. Then we need a **lifting lemma** to show the ordered-sum-level depth-k 1-var NF agreement.

3. **Lifting lemma** (`sum_nf_lift_single`): Shows that if `a` and `b` share the same component NF characteristic at all depths up to k, then `(i,a)` and `(i,b)` satisfy the same depth-m NFs (for m <= k) in the ordered sum under single-element environments `(![.])`. This works because:
   - At n=1, `AtomKind sig 1` has pred atoms but NO order atoms (since `Fin 1 = {0}`, `order i j (h : i != j)` is impossible). So atom agreement reduces to pred agreement, which follows from component NF matching.
   - The quantifier sub-step asks about depth-(m-1) NFs with n=2 variables. At n=2, order atoms DO exist. But we handle this by using the **ordered sum's own existential transfer** (from the IH of the outer `sum_nf_agree` at lower depth) to find witnesses, then applying `nf_agreement_from_shared_nf` which automatically handles all atoms including order.

4. **Why this works**: The pattern mirrors `nf_agreement_monotone` (NormalForm.lean:339-421) exactly. That theorem proves depth-k agreement implies depth-m agreement by: extracting quantifier transfer from depth-k, finding witnesses via that transfer, applying `nf_agreement_from_shared_nf` to get agreement for extended environments, then using the IH. The bootstrap replicates this at the ordered-sum level.

5. **Literature alignment**: Doets (1987, 1989) treats Lemma 1.4 as a one-sentence trivial result. The bootstrap approach mirrors his actual argument: the result follows from component equivalence by a straightforward induction on quantifier depth, not from elaborate multi-variable joint NF machinery.

## Goals & Non-Goals

**Goals**:
- Completely rewrite `sum_nf_agree` in NEquivalence.lean with a sentence-level-only signature (n=0, empty environments)
- Prove a lifting lemma `sum_nf_lift_single` for single-element environments
- Close all 4 remaining sorries in NEquivalence.lean
- Fix the pre-existing build errors (stack overflow during elaboration, type mismatches)
- Verify `sum_preservation_proof`, `KEquivalenceFramework.sum_preservation`, and `doets_lemma_1_4` compile sorry-free
- Clean `lake build` with no new sorries

**Non-Goals**:
- Proving `doets_lemma_1_5` (type-matching variant, not on discrete critical path)
- Closing downstream sorries beyond sum_preservation
- Implementing EF games
- Refactoring `KEquivalenceFramework` typeclass structure

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Lifting lemma requires reasoning about n=2 order atoms in the quantifier sub-step | H | M | Use `nf_agreement_monotone` pattern: extract ordered-sum quantifier transfer from IH, find witnesses via transfer, apply `nf_agreement_from_shared_nf`. Witnesses found this way automatically satisfy the same NF (by construction), so order atoms are handled. |
| The ordered sum's quantifier transfer at depth < k is not directly available from the sentence-level IH (IH gives n=0 agreement, but we need existential transfer which comes from n=0 agreement) | M | L | The quantifier transfer IS derivable from n=0 agreement: extract the depth-(k+1) characteristic at n=0, its quantifier part provides the existential transfer. This is exactly how `sum_preservation_proof` already extracts `h_comp'` from `k_equiv_monotone`. |
| Stack overflow during elaboration in current file blocks development | H | H | Phase 2 deletes the entire current `sum_nf_agree` body first, then builds the replacement incrementally in small definitions to avoid elaboration pressure |
| The lifting lemma proof is more complex than anticipated and exceeds 200 lines | M | M | Factor into sub-lemmas: atom case, quantifier case, forward/backward directions. Each should be under 80 lines. |
| Sigma.Lex order coercions create bureaucratic overhead | L | H | Define helper simp lemma for orderedSum carrier order; use `show` to cast goals to explicit forms |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |

Phases are sequential: each phase depends on the previous one.

---

### Phase 1: Define orderedSum and Fix carrier_order Sorries [COMPLETED]

**Goal**: Replace all `carrier_order := sorry` with a proper lexicographic order construction using Mathlib's `Sigma.Lex.linearOrder`.

**Tasks**:
- [x] Import `Mathlib.Data.Sigma.Order` in NEquivalence.lean
- [x] Define `orderedSum` helper function with `Sigma.Lex.linearOrder`
- [x] Replace inline `carrier_order := sorry` in `sum_preservation` field with `orderedSum`
- [x] Replace inline `carrier_order := sorry` in `doets_lemma_1_4` and `doets_lemma_1_5` with `orderedSum`
- [x] Run `lake build` and verify no errors from carrier_order changes

**Timing**: 2 hours (completed)

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/NEquivalence.lean`
- `Theories/Bimodal/Metalogic/WeakCanonical/OrderedSum.lean`

**Verification**:
- `lake build` succeeds with no new errors
- `grep -n "carrier_order := sorry"` returns no matches
- Completed in plan v2 implementation round

---

### Phase 2: Rewrite sum_nf_agree with Bootstrap Approach [NOT STARTED]

**Goal**: Delete the current broken `sum_nf_agree` (lines 153-469) and replace with the bootstrap sentence-level proof, including the lifting lemma. Fix pre-existing build errors (stack overflow, type mismatches) by using smaller, well-factored definitions.

**Tasks**:

- [ ] **Delete current sum_nf_agree body**: Remove lines 153-497 (from `private noncomputable def sum_nf_agree` through `sum_preservation_proof`). This eliminates the 4 sorry sites and the pre-existing elaboration errors.

- [ ] **Define `sum_nf_lift_single`**: The core lifting lemma. Given that `a` in `ms i` and `b` in `ms' i` satisfy the same depth-k NFs with 1 variable in their respective components, and given that the ordered sums agree on all depth-m sentence-level NFs for m < k (from the outer IH), show that `(i,a)` and `(i,b)` satisfy the same depth-m NFs (m <= k) with 1 variable in the ordered sum under single-element environments `![⟨i,a⟩]` and `![⟨i,b⟩]`.

  **Signature**:
  ```lean
  private noncomputable def sum_nf_lift_single (sig : MonadicSignature) :
      ∀ (m k : Nat) (hm : m ≤ k)
      (I : Type) [LinearOrder I]
      (ms ms' : I → OrderedMonadicStructure sig)
      (i : I)
      (a : (ms i).carrier) (b : (ms' i).carrier)
      -- Component NF agreement for a and b at all depths up to k
      (h_comp_ab : ∀ (d : Nat) (hd : d ≤ k),
        ∀ nf1 : NormalForm sig d 1,
        nf_eval_nf (ms i) d 1 (![a]) nf1 ↔ nf_eval_nf (ms' i) d 1 (![b]) nf1)
      -- Sentence-level ordered-sum agreement at depths < k (from outer IH)
      (h_sum_lower : ∀ (d : Nat) (hd : d < k),
        ∀ nfs : NormalForm sig d 0,
        nf_eval_nf (orderedSum sig I ms) d 0 Fin.elim0 nfs ↔
        nf_eval_nf (orderedSum sig I ms') d 0 Fin.elim0 nfs)
      -- Component sentence-level agreement at all depths up to k
      (h_comp_sent : ∀ (d : Nat) (hd : d ≤ k) (j : I),
        ∀ nfs : NormalForm sig d 0,
        nf_eval_nf (ms j) d 0 Fin.elim0 nfs ↔ nf_eval_nf (ms' j) d 0 Fin.elim0 nfs)
      (nf : NormalForm sig m 1),
      nf_eval_nf (orderedSum sig I ms) m 1 (![⟨i,a⟩]) nf ↔
      nf_eval_nf (orderedSum sig I ms') m 1 (![⟨i,b⟩]) nf
  ```

  **Proof structure** (by induction on m):
  - **m=0**: NF is `AtomKind sig 1 -> Bool`. Atoms are only pred atoms (no order atoms at n=1). Pred atom `(.pred p 0)` evaluates to `(ms i).interp p a` vs `(ms' i).interp p b`. Agreement from `h_comp_ab` at depth 0.
  - **m+1**: Atom part: same as m=0 (pred only, no order at n=1). Quantifier part: given `⟨j,c⟩` in orderedSum ms satisfying sub_nf at depth m with 2 vars, find `⟨j',c'⟩` in orderedSum ms'. Extract the ordered sum's sentence-level equivalence at depth m (from `h_sum_lower` if m < k, or derive from component agreement + this-being-proved if m = k -- but note m+1 <= k so m < k). From sentence-level depth-(m+1) agreement, extract quantifier transfer for the ordered sum. Use this to find a witness satisfying the same depth-m 2-var NF. Apply `nf_agreement_from_shared_nf` for the extended environments.

  **Critical insight**: The quantifier sub-step at n=2 DOES have order atoms. But the witnesses are found via the ordered sum's own quantifier transfer (extracted from sentence-level agreement at a depth where the IH applies). `nf_agreement_from_shared_nf` guarantees that witnesses sharing the same NF agree on ALL NFs at that depth, including those with order atoms.

  **Implementation note**: The proof for the quantifier sub-step uses `nf_agreement_monotone` applied to the ordered sums themselves. Since we have sentence-level agreement at depth d < k from `h_sum_lower`, we can extract depth-d agreement at arbitrary n (via `nf_agreement_monotone`'s contrapositive -- actually, `nf_agreement_monotone` goes DOWN in depth, not up in n. We need the ordered sum's quantifier transfer specifically.)

  **Revised quantifier sub-step approach**: 
  1. We have `h_sum_lower` giving sentence-level agreement at depth m (since m < k).
  2. Extract the depth-(m+1) characteristic of orderedSum ms at n=0: `char_sum`.
  3. By `h_sum_lower` at depth m+1... wait, we only have `d < k` and `m+1 <= k`, so `m+1` might equal k. We need `m+1 < k`, but we have `m+1 <= k`. If m+1 = k, then we are at the boundary.

  **Resolution**: Restructure `sum_nf_lift_single` to use strong induction on m with k as a fixed parameter, or alternatively, prove it simultaneously with `sum_nf_agree_sentence` via mutual recursion. The cleanest approach is a single function `sum_nf_agree_sentence` that proves both the sentence-level agreement AND extracts the quantifier transfer needed for the lifting step, all in one induction on k.

- [ ] **Define `sum_nf_agree_sentence`**: The main sentence-level bootstrap proof, replacing `sum_nf_agree` entirely. Proves that component-wise k-equivalence implies ordered-sum k-equivalence at n=0 (sentence level).

  **Signature**:
  ```lean
  private noncomputable def sum_nf_agree_sentence (sig : MonadicSignature) :
      ∀ (k : Nat) (I : Type) [LinearOrder I]
      (ms ms' : I → OrderedMonadicStructure sig)
      (h_comp : ∀ (m : Nat), m ≤ k → ∀ i, ∀ nf : NormalForm sig m 0,
        nf_eval_nf (ms i) m 0 Fin.elim0 nf ↔ nf_eval_nf (ms' i) m 0 Fin.elim0 nf)
      (nf : NormalForm sig k 0),
      nf_eval_nf (orderedSum sig I ms) k 0 Fin.elim0 nf ↔
      nf_eval_nf (orderedSum sig I ms') k 0 Fin.elim0 nf
  ```

  **Proof by induction on k**:
  - **k=0**: `nf_eval_nf` at depth 0 is `forall (a : AtomKind sig 0), atom_eval M Fin.elim0 a <-> (nf a = true)`. But `AtomKind sig 0` has no inhabitants: pred atoms need `Fin 0` (empty), order atoms need two distinct elements of `Fin 0` (impossible). So both sides reduce to `forall (a : AtomKind sig 0), ...` which is vacuously true. Close by `constructor <;> intro h a <;> exact (Fin.elim0 (motive := ...) ...)` or by showing `AtomKind sig 0` is empty and using `fun a => nomatch a` / `fun a => absurd ...`.
  
    **Lean tactic for vacuous case**: After `simp only [nf_eval_nf]`, the goal should be `(forall a, ...) <-> (forall a, ...)`. Since there are no `a : AtomKind sig 0`, both sides are `True`. Use:
    ```lean
    constructor <;> intro h a <;> exact absurd (atomKind_empty a) (not_false)
    ```
    or define a helper `atomKind_zero_elim : AtomKind sig 0 -> False`.
    
    Actually, the simplest approach: `AtomKind sig 0` consists of `.pred p i` where `i : Fin 0` (empty) and `.order i j h` where `i j : Fin 0` (empty). So any `a : AtomKind sig 0` can be eliminated by `cases a with | pred _ i => exact Fin.elim0 i | order i _ _ => exact Fin.elim0 i`. This gives `False` in both cases, making the goal trivially true.

  - **k+1**: The NF is `(atom_assgn, quant_assgn)`. 
    - **Atom part**: `AtomKind sig 0` is empty, so vacuously true (same as k=0).
    - **Quantifier part**: For each `sub_nf : NormalForm sig k 1`, need:
      ```
      (exists x, nf_eval_nf (orderedSum ms) k 1 (Fin.cons x Fin.elim0) sub_nf) <->
      (exists y, nf_eval_nf (orderedSum ms') k 1 (Fin.cons y Fin.elim0) sub_nf)
      ```
      Note: `Fin.cons x Fin.elim0 = ![x]` (single-element environment).
      
      **Forward direction**: Given `⟨⟨i,a⟩, ha_eval⟩`:
      1. Get component (k+1)-equivalence for i: extract `nf_characteristic (ms i) (k+1) 0 Fin.elim0 = nf_characteristic (ms' i) (k+1) 0 Fin.elim0` from `h_comp`.
      2. Extract quantifier transfer: `forall snf, (exists x, nf_eval_nf (ms i) k 1 (![x]) snf) <-> (exists y, nf_eval_nf (ms' i) k 1 (![y]) snf)`.
      3. Get characteristic NF of `a` in component `ms i`: `char_a := nf_characteristic (ms i) k 1 (![a])`.
      4. Transfer: get `b` in `ms' i` with `nf_eval_nf (ms' i) k 1 (![b]) char_a`.
      5. Now `a` and `b` share the same depth-k 1-var NF in their components. By `nf_agreement_from_shared_nf`, they agree on ALL depth-k 1-var NFs in their components.
      6. **Key step**: Show `nf_eval_nf (orderedSum ms') k 1 (![⟨i,b⟩]) sub_nf`.
      
      For step 6, we need the lifting lemma or an inline argument. The argument is:
      - Apply `nf_agreement_monotone` at the ordered sum level? No, we don't have ordered-sum agreement at depth k yet.
      - Instead, show that `⟨i,a⟩` and `⟨i,b⟩` satisfy the same depth-k 1-var NF *in the ordered sum*. This requires showing `nf_characteristic (orderedSum ms) k 1 (![⟨i,a⟩]) = nf_characteristic (orderedSum ms') k 1 (![⟨i,b⟩])`.
      - This is `sum_nf_lift_single` -- but we can prove it inline by a nested induction on k, or by applying the IH of the outer induction.
      
      **Actually, the cleanest approach**: Use the IH at depth k (which gives sentence-level agreement for the ordered sums at depth k) to extract quantifier transfer for the ordered sums at depth k-1. Then use `nf_agreement_monotone` to get agreement at all depths <= k-1. But we need agreement at depth k with 1 var, not depth <= k-1.
      
      **The correct resolution**: Prove `sum_nf_lift_single` as a separate lemma by induction on m (the depth), using the following structure:
      - m=0: AtomKind sig 1 has only pred atoms (no order atoms). Pred atoms follow from component agreement.
      - m+1 (with m+1 <= k): Atoms as above. Quantifiers: need `exists ⟨j,c⟩ in orderedSum ms` iff `exists ⟨j,c'⟩ in orderedSum ms'` satisfying depth-m NFs with 2 vars. 
        - Extract ordered-sum sentence-level agreement at depth m+1 (from the OUTER induction's IH, since we are inside the k+1 case and m+1 <= k). This gives ordered-sum quantifier transfer at depth m.
        - Find witnesses via this transfer. By `nf_agreement_from_shared_nf`, they satisfy the same depth-m 2-var NF. Apply the IH of `sum_nf_lift_single` at depth m for the sub-goal... but wait, the IH needs single-element environments, and we now have 2-element environments.
        
      **This reveals the core difficulty**: `sum_nf_lift_single` as stated only handles single-element environments. The quantifier step produces 2-element environments, which need a generalization.

      **FINAL CORRECT APPROACH** (adapted from the revision guidance):

      Do NOT prove a separate lifting lemma at all. Instead, use the following observation:
      
      The sentence-level IH gives us: `forall nf : NormalForm sig k 0, nf_eval_nf (orderedSum ms) k 0 Fin.elim0 nf <-> nf_eval_nf (orderedSum ms') k 0 Fin.elim0 nf`. 
      
      From this, extract the ordered sum's quantifier transfer at depth k-1:
      ```
      forall sub_nf : NormalForm sig (k-1) 1,
        (exists x, nf_eval_nf (orderedSum ms) (k-1) 1 (![x]) sub_nf) <->
        (exists y, nf_eval_nf (orderedSum ms') (k-1) 1 (![y]) sub_nf)
      ```
      
      Wait -- the IH at depth k gives agreement on depth-k 0-var NFs. A depth-k 0-var NF at k >= 1 is `(atom_part, quant_part)` where `quant_part : NormalForm sig (k-1) 1 -> Bool`. The IH says both ordered sums agree on which depth-k 0-var NFs hold. This means they agree on the quantifier part, giving us existential transfer at depth k-1 with 1 var.
      
      But we need existential transfer at depth k with 1 var (to find the witness for sub_nf at depth k). The IH gives us transfer at depth k-1.
      
      **Resolution**: The outer induction is on k, and at depth k+1 we are trying to prove the quantifier part. The quantifier asks about `sub_nf : NormalForm sig k 1`. Given `⟨i,a⟩`, we find `b` in `ms' i` via COMPONENT transfer at depth k. Then to show `nf_eval_nf (orderedSum ms') k 1 (![⟨i,b⟩]) sub_nf`, we can use:
      
      `nf_agreement_from_shared_nf` applied to the ordered sums: if `⟨i,a⟩` and `⟨i,b⟩` satisfy the same depth-k 1-var NF in the ordered sum, then they agree on all depth-k 1-var NFs. But we need to show they satisfy the SAME NF -- this requires computing the characteristic and showing equality.
      
      **THE ACTUAL PROOF THAT WORKS**:
      
      Strengthen the IH. Instead of proving just sentence-level agreement, prove:
      ```
      sum_nf_agree_general(k) := 
        forall n, forall env_M env_N,
          (forall j, (env_M j).1 = (env_N j).1) ->
          (forall j, nf_characteristic (ms (env_M j).1) k 1 (![env_M j).2]) = 
                     nf_characteristic (ms' (env_N j).1) k 1 (![env_N j).2])) ->
          forall nf : NormalForm sig k n,
            nf_eval_nf (orderedSum ms) k n env_M nf <-> 
            nf_eval_nf (orderedSum ms') k n env_N nf
      ```
      
      This is the same as the original `sum_nf_agree` but with `h_elem` replaced by a stronger hypothesis: instead of matching at depth m <= k, we require the full depth-k 1-var NF characteristic equality for each pair of elements. This stronger hypothesis, combined with the component NF machinery, suffices to handle order atoms.
      
      **Wait** -- this is essentially what plan v3 proposed. The implementation agent found this doesn't work because the characteristic equality at depth k includes quantifier parts that require reasoning about the ordered sum's own structure.
      
      **SIMPLEST CORRECT APPROACH** (recommended for implementation):
      
      1. Prove `sum_nf_agree_sentence` at n=0 by induction on k. The base case is trivial (no atoms). The quantifier step at k+1 requires showing existential transfer at depth k with 1 var.
      
      2. For the existential transfer: given `⟨i,a⟩` satisfying `sub_nf` at depth k in orderedSum ms, find `⟨i,b⟩` satisfying `sub_nf` at depth k in orderedSum ms'.
      
      3. Use the component's (k+1)-equivalence to find `b` in ms'(i) with the same depth-k 1-var component NF characteristic as `a`.
      
      4. Then show `⟨i,a⟩` and `⟨i,b⟩` have the same depth-k 1-var NF characteristic IN THE ORDERED SUM. This is the lifting step.
      
      5. For the lifting step, induct on k (nested or mutual). The depth-0 case: the NF characteristic at depth 0 with 1 var is just the atom assignment. At n=1, atoms are only pred atoms. Pred agreement follows from component NF matching.
      
      6. The depth-(k'+1) case (for the lifting): atom assignment as above. Quantifier assignment: for each `snf : NormalForm sig k' 2`, need `(exists ⟨j,c⟩, nf_eval_nf (orderedSum ms) k' 2 (![⟨i,a⟩, ⟨j,c⟩]) snf) <-> (exists ⟨j',c'⟩, nf_eval_nf (orderedSum ms') k' 2 (![⟨i,b⟩, ⟨j',c'⟩]) snf)`.
      
      7. Use the OUTER IH (sentence-level agreement of ordered sums at depth k'+1) to extract ordered-sum quantifier transfer at depth k'. Then find witnesses via this transfer. Apply `nf_agreement_from_shared_nf` for the extended 2-var environments. This gives depth-k' 2-var NF agreement, including order atoms.
      
      **But**: the outer IH at depth k' + 1 is `sum_nf_agree_sentence` at k' + 1 < k + 1, i.e., k' < k. We need sentence-level agreement at depth k'+1, and we have the IH for all depths up to k. So if k'+1 <= k (i.e., k' < k), we have it. And indeed, in the lifting step we are at depth k'+1 <= k (since the lifting is for depths m <= k, and the quantifier sub-step goes to depth k' = m-1 < m <= k).
      
      Actually, the quantifier step of the lifting at depth m (with m <= k) asks about depth m-1 with 2 vars. We extract ordered-sum transfer at depth m-1 from sentence-level agreement at depth m. But we have sentence-level agreement at depth m only if m <= k via the outer induction. Let's be precise:
      
      - We are proving `sum_nf_agree_sentence` at depth k+1.
      - Inside, we need the lifting: show `⟨i,a⟩` and `⟨i,b⟩` agree on depth-k 1-var NFs in the ordered sum.
      - The lifting proof at depth k requires, in its quantifier step, ordered-sum sentence-level agreement at depth k. But depth k agreement is what the IH of the outer induction gives us.
      - So: the outer IH (at depth k) provides `sum_nf_agree_sentence(k)`. The lifting uses this to extract quantifier transfer, find witnesses, apply `nf_agreement_from_shared_nf`.
      
      **This works!** The circularity is broken because:
      - Outer induction on k proves `sum_nf_agree_sentence(k)`.
      - At step k+1: needs lifting at depth k, which needs `sum_nf_agree_sentence(k)` (from IH).
      - Lifting at depth k may need lifting at depth k-1 (for its own quantifier sub-step), which needs `sum_nf_agree_sentence(k-1)` (from IH).
      - Etc., bottoming out at depth 0 (vacuous).

  **Summary of the proof architecture**:

  ```
  sum_nf_agree_sentence(k+1):
    Atoms: vacuous (AtomKind sig 0 empty)
    Quantifiers (sub_nf at depth k, 1 var):
      Given ⟨i,a⟩ satisfying sub_nf:
        1. Component transfer -> get b with same component depth-k 1-var NF
        2. Lifting(k): show ⟨i,a⟩ and ⟨i,b⟩ agree on depth-k 1-var NFs in ordered sum
        3. nf_agreement_from_shared_nf -> b satisfies sub_nf in orderedSum ms'
  
  Lifting(m) for m <= k (called from step 2 above):
    Input: a, b with same component depth-k 1-var NF (so same at all depths <= k)
    Output: ⟨i,a⟩, ⟨i,b⟩ agree on depth-m 1-var NFs in ordered sum
    
    m=0: atoms are pred only (no order at n=1), follows from component NF matching
    m+1 (m+1 <= k):
      Atoms: pred only, as above
      Quantifiers (snf at depth m, 2 vars):
        Use sum_nf_agree_sentence(m+1) [from outer IH, since m+1 <= k]
        -> extract ordered-sum quantifier transfer at depth m
        -> find witness ⟨j',c'⟩ via transfer
        -> nf_agreement_from_shared_nf for 2-var environments
        -> depth-m 2-var agreement (including order atoms!)
  ```

- [ ] **Rewrite `sum_preservation_proof`**: Simplify to call `sum_nf_agree_sentence` directly. The current version calls `sum_nf_agree` with 6 hypotheses and Fin.elim0. The new version just calls `sum_nf_agree_sentence` with `h_comp'` derived from component k-equivalence.

- [ ] **Fix any elaboration issues**: Factor large proof terms into separate `have` bindings. Keep each definition under 100 lines to avoid stack overflow.

- [ ] **Run `lake build`** and verify NEquivalence.lean compiles. May have remaining sorries during incremental development.

**Timing**: 6 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/NEquivalence.lean` - Delete current sum_nf_agree + sum_preservation_proof, replace with sum_nf_agree_sentence + lifting + new sum_preservation_proof

**Verification**:
- `grep -n "sorry" NEquivalence.lean` shows zero sorries (except possibly during incremental development)
- `lake build` passes for NEquivalence.lean
- No stack overflow or type mismatch errors

---

### Phase 3: Verify doets_lemma_1_4 and Final Build [NOT STARTED]

**Goal**: Verify that `doets_lemma_1_4` is transitively sorry-free now that `sum_nf_agree_sentence` replaces `sum_nf_agree`, and run a clean full build.

**Tasks**:
- [ ] Verify `doets_lemma_1_4` in OrderedSum.lean still compiles (it delegates to `KEquivalenceFramework.sum_preservation` which delegates to `sum_preservation_proof` which calls the new `sum_nf_agree_sentence`)
- [ ] Run `grep -rn "sorry" Theories/Bimodal/Metalogic/WeakCanonical/NEquivalence.lean` and confirm zero sorries
- [ ] Run `grep -rn "sorry" Theories/Bimodal/Metalogic/WeakCanonical/OrderedSum.lean` and confirm only `doets_lemma_1_5` sorry remains (out of scope)
- [ ] Run full `lake build` to verify no regressions across the entire project
- [ ] Update docstrings in NEquivalence.lean: remove "4 remaining sorries" and "blocker" references from `sum_nf_agree` docstring and `sum_preservation` instance comment
- [ ] Verify total sorry count has decreased by 4 compared to pre-implementation state

**Timing**: 2 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/NEquivalence.lean` - Update docstrings
- `Theories/Bimodal/Metalogic/WeakCanonical/OrderedSum.lean` - Verify build, update docstrings if needed

**Verification**:
- `lake build` succeeds with exit code 0
- `doets_lemma_1_4` is sorry-free (transitively)
- Only remaining sorry in these two files is `doets_lemma_1_5` (explicitly out of scope)
- No new sorries introduced anywhere in the project

## Testing & Validation

- [ ] `lake build` succeeds with exit code 0
- [ ] `grep -rn "sorry" Theories/Bimodal/Metalogic/WeakCanonical/NEquivalence.lean` shows zero sorries
- [ ] `grep -rn "sorry" Theories/Bimodal/Metalogic/WeakCanonical/OrderedSum.lean` shows only `doets_lemma_1_5` sorry
- [ ] `grep -rn "carrier_order := sorry" Theories/` returns no matches
- [ ] The `orderedSum` construction type-checks and produces an `OrderedMonadicStructure` with proper lexicographic order
- [ ] No downstream regressions: files importing NEquivalence.lean and OrderedSum.lean continue to build

## Artifacts & Outputs

- `specs/154_sum_preservation_ef_games/plans/04_sum-preservation-plan.md` (this file)
- Modified: `Theories/Bimodal/Metalogic/WeakCanonical/NEquivalence.lean` (rewritten sum_nf_agree -> sum_nf_agree_sentence + lifting, closed sum_preservation)
- Modified: `Theories/Bimodal/Metalogic/WeakCanonical/OrderedSum.lean` (doets_lemma_1_4 transitively sorry-free, updated docstrings)

## Rollback/Contingency

- Git revert to pre-implementation commit restores all files
- If the lifting lemma proves intractable, try the **inline approach**: instead of a separate `sum_nf_lift_single`, prove the lifting directly inside `sum_nf_agree_sentence`'s quantifier case using well-founded recursion on `(k, m)` pairs
- If the full proof exceeds 500 lines, factor reusable parts into a `SumPreservation` section or a dedicated helper file
- If `AtomKind sig 0` emptiness is hard to prove directly, define an explicit `atomKind_zero_empty : AtomKind sig 0 -> False` lemma as infrastructure
- As a last resort, restrict to `[Fintype I]` -- sufficient for the Reynolds pipeline since the condensation quotient is finite
