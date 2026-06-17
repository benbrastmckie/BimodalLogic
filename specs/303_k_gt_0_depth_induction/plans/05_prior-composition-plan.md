# Implementation Plan: Prior Composition Theorem for k>0 Depth Induction

- **Task**: 303 - k_gt_0_depth_induction
- **Status**: [NOT STARTED]
- **Effort**: 10 hours
- **Dependencies**: None (k=0 infrastructure and Phase 1 mutual induction scaffold are sorry-free)
- **Research Inputs**: reports/01_team-research.md, reports/02_depth-induction-resolution.md, reports/03_zone-explicit-research.md
- **Artifacts**: plans/05_prior-composition-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Close the SOLE remaining sorry blocking `completeness_discrete` by proving a Prior-specific composition theorem and using it to fill the backward direction of `existPart_succ_n1_bypass` at k>0 (KampBypass.lean lines 356, 368). Plans v2-v4 all failed because they assumed 1-var NF agreement determines multi-var NFs -- proved FALSE by the counterexample in NfComposition.lean:20-36. The new approach trades one depth level (K+1 to K) to gain multi-var agreement, exploiting Prior-UZ/SZ to provide interval witnesses that nf_extend_fwd alone cannot guarantee.

The plan is complete when `lean_verify` on `completeness_discrete` shows no `sorryAx` from the Kamp path.

### Research Integration

Findings integrated from three research reports across 6 analysis cycles:

1. **reports/01_team-research.md**: Confirmed sole sorry chain to `completeness_discrete`. Identified mutual induction scaffold (CharPart + ExistPart) as correct framework. Estimated 400-1500 lines.
2. **reports/02_depth-induction-resolution.md**: Exhaustive path analysis (A/B/C/D). Confirmed constant-parent ExistPart is fundamental constraint. NfCharFormula.lean:542 is dead code. Literature alignment with GHR94 Section 12.8 and Rabinovich 2014 Section 5.
3. **reports/03_zone-explicit-research.md**: Zone-explicit encoding proved non-viable within constant-parent framework. Depth gap confirmed inherent in nf_extend_fwd chain. Identified enriched formula with char_kp1(nf_t) as necessary but not sufficient alone. Final recommendation: Prior-specific composition theorem that bridges the depth gap using Prior-UZ/SZ witnesses.

### Depth Gap Analysis (Why Previous Plans Failed)

The fundamental obstacle: `nf_extend_fwd` trades one depth level for one arity level.

```
depth-(K+1) arity-r  --nf_extend_fwd-->  depth-K arity-(r+1)
```

The sorry at KampBypass.lean:356 needs depth-(k'+2) arity-2 information at `[x, t]`. The available characteristic formulas give depth-(k'+2) arity-1 at `(fun _ => t)` and `(fun _ => x)` separately. Applying nf_extend_fwd yields depth-(k'+1) arity-2, which is one level short. The quantifier conditions of sub_nf require depth-(k'+1) arity-3 existential transfer, which from nf_extend_fwd on the depth-(k'+1) arity-2 agreement gives only depth-k' arity-3 -- again one level short.

On Prior structures, this gap can be bridged because Prior-UZ/SZ guarantee witnesses exist in every interval zone, providing the additional information that the purely structural nf_extend_fwd chain cannot.

### Prior Plan History

| Plan | Approach | Outcome |
|------|----------|---------|
| v2 (02_depth-induction-plan.md) | Cross-structure NF transfer with constant-parent ExistPart | [BLOCKED]: 1-var NFs don't determine 2-var NFs |
| v3 (03_revised-depth-plan.md) | Zone-explicit temporal encoding | [BLOCKED]: ih_exist constant-parent constraint prevents zone encoding |
| v4 (04_existpart-r-plan.md) | ExistPart_r with parent NF types | [BLOCKED]: Same counterexample (NfComposition.lean:20-36) refutes ExistPart_r |

### Roadmap Alignment

- Advances: "Task 303 (k>0 depth induction via Rabinovich Section 5 Lemma 5.1) -> sorry-free completeness_discrete"
- This is identified as the SOLE remaining blocker on the critical path to sorry-free discrete completeness.

## Goals & Non-Goals

**Goals**:
- Prove `prior_composition_2var` theorem in a new file `KampComposition.lean`
- Use the composition theorem to fill the backward direction at KampBypass.lean:356 (Until) and 368 (Since)
- Close the n>=2 sorry at KampMutualInduction.lean:310
- Verify the entire completeness chain is sorry-free from this path

**Non-Goals**:
- Closing NfCharFormula.lean:542 (dead code, not on critical path)
- Modifying k=0 zone infrastructure (KampBypassCore/Until/Since are sorry-free)
- General Feferman-Vaught composition for arbitrary linear orders (we only need Prior structures)
- Modifying the ExistPart definition or mutual induction structure

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Prior composition theorem is harder than estimated (induction on K requires more case analysis) | H | M | The k=0 base case is nearly trivial (purely atomic). Factor inductive step into helper lemmas. Use Prior-UZ/SZ infrastructure from PriorINF.lean. |
| Enriching the Until/Since formula breaks the forward direction | M | L | The forward direction only needs char_kp1(nf_t) to hold at t, which follows from char_kp1_correct. Adding a conjunct to the formula makes forward trivially harder (extra conjunct to prove) but the proof is straightforward. |
| The composition theorem requires quantifier-alternation induction beyond what nf_extend_fwd provides | H | M | Prior-UZ/SZ give explicit interval witnesses. At each depth level, use semantic_prior_UZ/SZ to find witnesses in each zone, then apply the IH recursively. |
| n>=2 sorry at KampMutualInduction.lean:310 has subtleties beyond bool_eq_of_iff_same | M | L | The n>=2 pattern at depth 0 (existPart_zero) is well-established and generalizes. Worst case: 150 lines of adaptation. |
| Heartbeat timeouts from enlarged formula/proof terms | M | M | Factor proofs into private helpers. Use set_option maxHeartbeats as in existing KampBypass files. |
| Formula enrichment with nf_t disjunction causes exponential blowup | L | L | The disjunction is over NormalForm sig (k'+2) 1, which is Fintype. Use formula_disjList with filtering by atom compatibility to keep the disjunction manageable. |

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

### Phase 1: Prior Composition Theorem -- Statement and Base Case [IN PROGRESS]

**Goal**: Define and prove the Prior composition theorem for K=0 (base case) in a new file `KampComposition.lean`. State the full theorem for all K.

**Depth Accounting**:
- Input: depth-(K+1) 1-var NF agreement at each of t/t0 and x/x0 in two Prior structures M, N
- Output: depth-K 2-var NF agreement at `[x, t]` and `[x0, t0]`
- Depth trade: K+1 -> K (one level consumed)
- At K=0: 2-var NF is purely atomic. Atom agreement at `[x, t]` follows from 1-var atom agreement (predicates) + order matching. Prior-UZ/SZ not needed.

**Tasks**:
- [ ] Create `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampComposition.lean` with imports from KampBypass.lean and PriorDefs.lean
- [ ] State `prior_composition_2var`:
  ```lean
  theorem prior_composition_2var {sig : MonadicSignature}
      (atomMap : Formula -> sig.preds)
      (M N : OrderedMonadicStructure sig)
      (h_UZ_M : semantic_prior_UZ M atomMap) (h_SZ_M : semantic_prior_SZ M atomMap)
      (h_UZ_N : semantic_prior_UZ N atomMap) (h_SZ_N : semantic_prior_SZ N atomMap)
      (K : Nat)
      (t : M.carrier) (s : N.carrier)
      (x : M.carrier) (x' : N.carrier)
      (h_t_agree : forall nf, nf_eval_nf M (K+1) 1 (fun _ => t) nf <->
          nf_eval_nf N (K+1) 1 (fun _ => s) nf)
      (h_x_agree : forall nf, nf_eval_nf M (K+1) 1 (fun _ => x) nf <->
          nf_eval_nf N (K+1) 1 (fun _ => x') nf)
      (h_order_gt : t < x <-> s < x')
      (h_order_lt : x < t <-> x' < s) :
      forall nf : NormalForm sig K 2,
        nf_eval_nf M K 2 (Fin.cons x (fun _ => t)) nf <->
        nf_eval_nf N K 2 (Fin.cons x' (fun _ => s)) nf
  ```
- [ ] Prove the K=0 base case: depth-0 2-var NF is purely atomic. Atoms at `[x, t]` decompose into predicates at x, predicates at t, and order between x and t. All three follow from the hypotheses.
- [ ] State helper lemma `prior_composition_quant_transfer` for the quantifier part (used in inductive step):
  ```lean
  -- Given depth-K 2-var NF agreement at [x, t] and [x', s],
  -- transfer depth-(K-1) 3-var existentials
  private theorem prior_composition_quant_transfer ...
  ```
- [ ] Add the file to the lakefile import chain (import in KampBypass.lean)
- [ ] Verify `lake build Bimodal.Metalogic.WeakCanonical.Kamp.KampComposition` succeeds

**Timing**: 2 hours
**Depends on**: none

**Files to create/modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampComposition.lean` -- new file
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampBypass.lean` -- add import

**Verification**:
- `lake build Bimodal.Metalogic.WeakCanonical.Kamp.KampComposition` succeeds
- K=0 case is sorry-free
- K>0 case has sorry (filled in Phase 2)
- No regressions in existing sorry-free proofs

---

### Phase 2: Prior Composition Theorem -- Inductive Step [NOT STARTED]

**Goal**: Prove `prior_composition_2var` for K+1 by induction on K, using Prior-UZ/SZ to provide witnesses.

**Depth Accounting**:
- IH gives: depth-K 2-var agreement from depth-(K+1) 1-var agreement + matching orders
- Step needs: depth-(K+1) 2-var agreement from depth-(K+2) 1-var agreement + matching orders
- Decomposition: depth-(K+1) 2-var NF = atoms + depth-K 3-var quantifier conditions
- Atom part: follows from depth-(K+2) 1-var agreement (predicates agree at each element) + order matching
- Quantifier part: for each ssn : NF sig K 3, transfer `(exists y, nf_eval M K 3 [y,x,t] ssn) <-> (exists y', nf_eval N K 3 [y',x',s] ssn)`
- Witness transfer strategy: Given y in M, use Prior-UZ/SZ to find a witness y' in N in the corresponding zone. Show y and y' have matching depth-(K+1) 1-var NFs (from existing infrastructure). Then apply the IH (at arity 3, needing a generalized version or iterated 2-var composition) to transfer the depth-K 3-var NF.

**Tasks**:
- [ ] Prove atom part of the inductive step: depth-(K+2) 1-var agreement at x/x' and t/s implies atom agreement at `[x, t]` and `[x', s]`. Extract predicate agreement via `nf_characteristic` at depth K+2 >= 1. Order agreement from h_order_gt/h_order_lt.
- [ ] Prove the quantifier transfer for each zone of y relative to x, t:
  - Zone y > x > t: y is in the future of x. Use nf_extend_fwd on M with h_x_agree to find y' in N. The depth-(K+1) 1-var agreement at y/y' follows from nf_extend_fwd giving depth-K 2-var agreement at `[y, x]` and `[y', x']`, then nf_drop_last extracts depth-K 1-var agreement. Combined with existing depth-(K+2) at x and t, apply the IH.
  - Zone t < y < x: y is in the interval (t, x). Use semantic_prior_UZ (M has a witness in every nonempty interval for N's NF type) to find y'. Apply IH.
  - Zone y < t < x: y is in the past of t. Use nf_extend_fwd on M with h_t_agree to find y' in N. Apply IH.
  - Zone y = x: Substitution reduces to 2-var agreement (already have from nf_extend_fwd at one level).
  - Zone y = t: Similar substitution.
- [ ] Handle the Prior-specific interval witness step: when y is in (t, x) in M, use `semantic_prior_UZ` (or `semantic_prior_SZ`) to show N also has a witness in (s, x') with the right depth-K 1-var NF type. This is the key step where Prior-UZ/SZ is ESSENTIAL.
- [ ] Factor the 5-zone argument into helper lemmas to keep each under 100 lines
- [ ] Close the sorry in `prior_composition_2var` for K > 0
- [ ] Verify `lake build Bimodal.Metalogic.WeakCanonical.Kamp.KampComposition` succeeds with 0 sorries

**Timing**: 3 hours
**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampComposition.lean` -- fill inductive step

**Verification**:
- `lean_verify Bimodal.Metalogic.WeakCanonical.Kamp.prior_composition_2var` shows no `sorryAx`
- `lake build Bimodal.Metalogic.WeakCanonical.Kamp.KampComposition` succeeds with 0 sorries

---

### Phase 3: Enrich Until/Since Formula and Close Backward Sorries [NOT STARTED]

**Goal**: Modify the formula construction at KampBypass.lean lines 342-375 to include char_kp1(nf_t) in the Until/Since formula, then use `prior_composition_2var` to close the backward direction sorries at lines 356 and 368.

**Depth Accounting**:
- Current formula: `Until(compat_disj, top)` -- encodes only x's 1-var NF type
- Enriched formula: `Disjunction over compatible nf_t: char_kp1(nf_t) AND Until(compat_disj, top)`
- From char_kp1(nf_t) at t: `nf_eval_nf M (k'+2) 1 (fun _ => t) nf_t` (depth-(k'+2) 1-var)
- From char_kp1(nf_x) at x (via Until): `nf_eval_nf M (k'+2) 1 (fun _ => x) nf_x` (depth-(k'+2) 1-var)
- From M0 witness: `nf_eval_nf M0 (k'+2) 1 (fun _ => t0) nf_t` and `nf_eval_nf M0 (k'+2) 1 (fun _ => x0) nf_x`
- Apply `prior_composition_2var` at K = k'+1: depth-(k'+1) 2-var NF agreement at `[x, t]` and `[x0, t0]`
- Sub_nf is at depth k'+2: atoms follow from the composition + individual NF agreement. Quantifier conditions (depth-(k'+1) arity-3) follow from the depth-(k'+1) 2-var agreement via nf_extend_fwd/bwd.

Wait -- sub_nf is at depth k'+2, but composition gives depth-(k'+1) 2-var agreement. The quantifier part of sub_nf involves depth-(k'+1) arity-3 existentials. From depth-(k'+1) 2-var agreement, nf_extend_fwd gives depth-k' arity-3 -- still one level short.

**Revised depth accounting using composition at K = k'+1**:
- Composition at K = k'+1: from depth-(k'+2) 1-var agreement -> depth-(k'+1) 2-var agreement
- This gives: `forall nf : NF sig (k'+1) 2, nf_eval M (k'+1) 2 [x,t] nf <-> nf_eval M0 (k'+1) 2 [x0,t0] nf`
- Sub_nf.2 ssn condition: `(exists y, nf_eval M (k'+1) 3 [y,x,t] ssn) <-> sub_nf.2 ssn`
- From the depth-(k'+1) 2-var agreement and the characteristic of M (k'+1) 2 [x,t]:
  - nf_characteristic M (k'+1) 2 [x,t] = nf_characteristic M0 (k'+1) 2 [x0,t0]
  - The quantifier part of this characteristic is: `forall chi, (exists y, nf_eval M k' 3 [y,x,t] chi) <-> (char).2 chi`
  - This gives depth-k' arity-3 existential transfer: `(exists y, nf_eval M k' 3 [y,x,t] chi) <-> (exists y, nf_eval M0 k' 3 [y,x0,t0] chi)`

But sub_nf.2 ssn involves depth-(k'+1) arity-3, not depth-k'. The gap persists.

**Resolution**: Apply `prior_composition_2var` TWICE, or use a generalized version for arity 3.

Actually, the correct approach is different. Instead of using composition to get 2-var agreement and then trying to lift, use the composition theorem DIRECTLY at the quantifier level. For each ssn, the condition `exists y, nf_eval M (k'+1) 3 [y,x,t] ssn` can be transferred by:

1. Given y0 in M0 with `nf_eval M0 (k'+1) 3 [y0, x0, t0] ssn`:
2. From depth-(k'+2) 1-var agreement at t/t0: nf_extend_fwd gives some c in M with depth-(k'+1) 2-var agreement at `[c, t]` and `[x0, t0]`.
3. From depth-(k'+1) 2-var agreement at `[c, t]` and `[x0, t0]`: nf_extend_fwd with y0 gives some y in M with depth-k' 3-var agreement at `[y, c, t]` and `[y0, x0, t0]`.
4. Apply `prior_composition_2var` in a generalized arity-3 version to lift from depth-k' to depth-(k'+1) arity-3 agreement.

Step 4 is where the composition theorem is used essentially. The arity-3 composition says: depth-(k'+1) 1-var agreement at y/y0, x/x0, t/t0 + matching orders implies depth-k' 3-var agreement. But we actually need depth-(k'+1) 3-var agreement.

**Alternative resolution**: The composition theorem at arity 2 gives us depth-(k'+1) 2-var agreement at `[x, t]` and `[x0, t0]`. From this, `exist_transfer_const_env`-style reasoning with the 2-var agreement gives:
```
(exists y, nf_eval M (k'+1) 3 [y,x,t] ssn) <-> (exists y0, nf_eval M0 (k'+1) 3 [y0,x0,t0] ssn)
```
But this requires depth-(k'+2) 2-var agreement, not just depth-(k'+1).

**Correct resolution**: Use the enriched formula and the classical satisfiability structure. The M0 witness provides a FIXED value of sub_nf.2 ssn for each ssn. Instead of transferring ssn-by-ssn, use the ENTIRE depth-(k'+1) 2-var characteristic NF. From depth-(k'+1) 2-var NF agreement: nf_characteristic M (k'+1) 2 [x,t] = nf_characteristic M0 (k'+1) 2 [x0,t0]. The quantifier part of this characteristic says `(exists y, nf_eval M k' 3 [y,x,t] chi) <-> (char).2 chi` for each chi : NF sig k' 3. Since M0 satisfies sub_nf at [x0,t0] and the depth-(k'+1) 2-var characteristics match:

The atoms of sub_nf match the atoms of `[x,t]` (from the atom part). The quantifier part: sub_nf.2 ssn requires depth-(k'+1) arity-3 existential transfer. The depth-(k'+1) characteristic encodes depth-k' quantifier conditions, which are transferable. But sub_nf is at depth k'+2, and its quantifier part involves depth-(k'+1) NFs.

**The key insight**: `nf_eval_nf M (k'+2) 2 [x,t] sub_nf` decomposes as atoms + quantifier. The quantifier conditions say: for each ssn : NF sig (k'+1) 3, `(exists y, nf_eval M (k'+1) 3 [y,x,t] ssn) <-> sub_nf.2 ssn`. From the depth-(k'+1) 2-var agreement between M and M0 at [x,t] and [x0,t0], plus the fact that M0 satisfies sub_nf: the depth-(k'+1) 2-var NFs match, and the QUANTIFIER PART of the depth-(k'+2) 2-var NF is determined by the depth-(k'+1) NF agreement.

Specifically: `nf_eval_nf M (k'+2) 2 [x,t] sub_nf` requires:
- (a) atoms at [x,t] match sub_nf.1
- (b) for each ssn, `(exists y, nf_eval M (k'+1) 3 [y,x,t] ssn) <-> sub_nf.2 ssn`

For (b), from depth-(k'+1) 2-var agreement:
```
nf_characteristic M (k'+1) 2 [x,t] = nf_characteristic M0 (k'+1) 2 [x0,t0]
```
The quantifier part: for any chi : NF sig k' 3,
```
(exists y, nf_eval M k' 3 [y,x,t] chi) <-> (char).2 chi
<-> (exists y0, nf_eval M0 k' 3 [y0,x0,t0] chi)
```
This transfers depth-k' arity-3 existentials but NOT depth-(k'+1) arity-3 existentials.

**We need one more level.** Apply the composition theorem at K = k'+1 to get depth-(k'+1) 2-var agreement, then need a SECOND application of composition (at arity 3) to get depth-k' 3-var agreement from the 2-var agreement, and then use the nf_extend_fwd chain from there.

Actually, the correct approach is to use the composition theorem at ARITY 2 to get depth-(k'+1) 2-var agreement, and then show that this 2-var agreement combined with nf_extend_fwd gives the depth-(k'+1) 3-var existential transfer.

From depth-(k'+1) 2-var agreement: for any y0 in M0, nf_extend_fwd gives y in M with depth-k' 3-var agreement at [y,x,t] and [y0,x0,t0]. This gives:
- nf_eval_nf M k' 3 [y,x,t] chi <-> nf_eval_nf M0 k' 3 [y0,x0,t0] chi for all chi
- In particular, at the ssn level: the depth-(k'+1) arity-3 NF is (atoms, quantifier_fn). Atoms match from depth-k' agreement. Quantifier_fn involves depth-(k'-1) arity-4 existentials, which transfer from nf_extend_fwd on the depth-k' arity-3 agreement. So the FULL depth-(k'+1) arity-3 NFs match.

Wait, this was the argument from Finding 12 in report 03, which was then refuted in the adversarial verification. Let me re-examine.

The issue is: depth-k' arity-3 agreement does NOT directly give depth-(k'+1) arity-3 agreement. The depth hierarchy is strict. However, the argument that atoms + quantifier conditions both match IS valid:
- Atoms: from depth-k' agreement (any k' >= 0 gives depth-0 atom agreement)
- Quantifier: (exists w, nf_eval M k' 4 [w,y,x,t] chi) <-> (exists w0, nf_eval M0 k' 4 [w0,y0,x0,t0] chi)

The quantifier transfer follows from nf_extend_fwd on the depth-k' arity-3 agreement (gives depth-(k'-1) arity-4 agreement). But we need depth-k' arity-4 EXISTENTIAL transfer, not depth-(k'-1).

The adversarial verification was correct: this is one level short at every stage.

**THE TRUE RESOLUTION**: Use the composition theorem ITERATIVELY. Define a generalized composition theorem for arbitrary arity r:

```lean
theorem prior_composition_rvar {sig : MonadicSignature}
    ... (K r : Nat)
    (envM : Fin r -> M.carrier) (envN : Fin r -> N.carrier)
    (h_agree : forall i : Fin r, forall nf, nf_eval_nf M (K+1) 1 (fun _ => envM i) nf <->
        nf_eval_nf N (K+1) 1 (fun _ => envN i) nf)
    (h_orders : forall i j : Fin r, envM i < envM j <-> envN i < envN j) :
    forall nf : NormalForm sig K r,
      nf_eval_nf M K r envM nf <-> nf_eval_nf N K r envN nf
```

With this generalized version, the quantifier conditions of the depth-(k'+1) 2-var NF at [x,t] involve depth-k' 3-var existentials. For each ssn with sub_nf.2 ssn = true: M0 has y0. We need y in M. Use nf_extend_fwd from the depth-(k'+1) 2-var agreement to get y with depth-k' 3-var agreement. Then we have depth-k' 3-var agreement between [y,x,t] and [y0,x0,t0]. This directly gives `nf_eval M k' 3 [y,x,t] chi <-> nf_eval M0 k' 3 [y0,x0,t0] chi` for all chi at depth k'.

But ssn is at depth k'+1, not k'. The nf_eval_nf at depth k'+1 arity 3 requires atoms + depth-k' quantifier conditions. Atoms follow from the depth-k' agreement. The depth-k' quantifier conditions are `(exists w, nf_eval M (k'-1) 4 ...) <-> ssn.2 chi`. From the depth-k' arity-3 agreement, nf_extend_fwd gives depth-(k'-1) arity-4 agreement, which transfers these existentials.

BUT: we need `(exists w, nf_eval M k' 4 [w,y,x,t] chi) <-> ssn.2 chi`, which involves depth-k' arity-4, not depth-(k'-1). The gap.

**THE ACTUAL FIX**: The r-var composition theorem at K = k' with r = 3 gives: from depth-(k'+1) 1-var agreement at y, x, t + matching orders -> depth-k' 3-var agreement. The depth-(k'+1) 1-var agreement at y comes from the nf_extend_fwd result: depth-k' arity-3 agreement -> nf_drop_last -> depth-k' arity-1 agreement at y. But we need depth-(k'+1) 1-var agreement, and we only have depth-k'.

To get depth-(k'+1) 1-var agreement at y: we have depth-(k'+2) at x (from char_kp1(nf_x)) and depth-(k'+2) at t (from char_kp1(nf_t)). From nf_extend_fwd on the depth-(k'+2) 1-var agreement at t: we get c in M (matching x0) with depth-(k'+1) 2-var agreement at [c,t] and [x0,t0]. Then nf_extend_fwd on this with y0: y in M with depth-k' 3-var agreement at [y,c,t] and [y0,x0,t0]. Then nf_drop_last: depth-k' 1-var at y and y0.

Depth-k' 1-var, not depth-(k'+1). Insufficient for the recursive composition.

**FUNDAMENTAL INSIGHT**: The composition theorem itself must be proved by induction on K WITH universal quantification over r. At each K level, the composition at arity r uses the composition at K-1 and arity r+1 (via the quantifier conditions). This is a nested induction. The base case K=0 handles all arities (purely atomic). The step K -> K+1 at arity r uses Prior-UZ/SZ to transfer witnesses between zones and the IH at K for the quantifier conditions at arity r+1.

This means the composition theorem IS the right approach, but its proof requires induction on K with r universally quantified -- NOT separate inductions for each arity.

**Revised plan for Phase 3**: Instead of trying to use the 2-var composition inside KampBypass directly, the enriched formula approach uses the composition theorem to establish that M and M0 agree on the ENTIRE depth-(k'+1) 2-var NF -- including quantifier conditions. The composition theorem handles this by its own internal induction.

For the backward proof of the sorry:
1. char_kp1(nf_t) at t + char_kp1(nf_x) at x from the Until formula
2. M0 witnesses matching NF types at x0, t0
3. `prior_composition_2var` at K = k'+1 gives depth-(k'+1) 2-var agreement at [x,t] and [x0,t0]
4. Atoms of sub_nf match (from individual NF agreement + composition atom part)
5. Quantifier conditions transfer: depth-(k'+1) 2-var agreement implies the quantifier part of the depth-(k'+2) 2-var NF is determined. Specifically, nf_characteristic M (k'+1) 2 [x,t] = nf_characteristic M0 (k'+1) 2 [x0,t0], and this characteristic's quantifier function gives exactly sub_nf.2.

Wait: depth-(k'+1) 2-var characteristic is NOT the same as depth-(k'+2) 2-var characteristic (sub_nf). The depth-(k'+1) 2-var characteristic determines depth-k' quantifier conditions but NOT depth-(k'+1) quantifier conditions.

**This is still the same depth gap.** Let me think about this differently.

sub_nf : NF sig (k'+2) 2 = (atoms, quant) where quant : NF sig (k'+1) 3 -> Bool.

The condition `nf_eval_nf M (k'+2) 2 [x,t] sub_nf` = atoms match AND for all ssn, `(exists y, nf_eval M (k'+1) 3 [y,x,t] ssn) <-> quant ssn`.

The composition at K = k'+1 gives depth-(k'+1) 2-var agreement. This means `forall nf : NF sig (k'+1) 2, nf_eval M (k'+1) 2 [x,t] nf <-> nf_eval M0 (k'+1) 2 [x0,t0] nf`. In particular, the characteristic NF at depth k'+1 matches. Its quantifier part: `forall chi : NF sig k' 3, (exists y, nf_eval M k' 3 [y,x,t] chi) <-> char.2 chi`. This gives depth-k' arity-3 existential transfer.

But we need depth-(k'+1) arity-3 existential transfer for the depth-(k'+2) 2-var NF. Specifically: `(exists y, nf_eval M (k'+1) 3 [y,x,t] ssn) <-> (exists y0, nf_eval M0 (k'+1) 3 [y0,x0,t0] ssn)`.

From the depth-(k'+1) 2-var agreement, we can apply `exist_transfer_const_env`-like reasoning: the 2-var agreement at depth k'+1 is equivalent to having the same quantifier function at depth k'. But we need depth-(k'+1) arity-3 existential transfer, which requires depth-(k'+2) arity-2 agreement.

OK. So the composition at K = k'+1 gives depth-(k'+1) 2-var. We need depth-(k'+2) 2-var for the quantifier transfer. The composition at K = k'+2 would give depth-(k'+2) 2-var from depth-(k'+3) 1-var. But we only have depth-(k'+2) 1-var.

**THE COMPOSITION THEOREM TRADES ONE DEPTH LEVEL.** K+1 -> K. To get depth-(k'+2) 2-var, we need depth-(k'+3) 1-var. We have depth-(k'+2) 1-var. One level short.

**THIS IS THE SAME GAP AT THE COMPOSITION LEVEL.** The composition theorem does not help directly because it has the same depth arithmetic as nf_extend_fwd.

**RECONSIDERING THE APPROACH**: The composition theorem IS needed, but it must work WITHOUT the depth drop for the specific case of Prior structures. That is:

```
Prior composition (no depth drop):
depth-(K+1) 1-var agreement at each element + matching orders + Prior-UZ/SZ
=> depth-(K+1) 2-var agreement (SAME depth, NOT K)
```

This is STRONGER than nf_extend_fwd (which drops one level). On Prior structures, it should be provable because Prior-UZ/SZ provide interval witnesses that recover the lost depth level.

The proof strategy for the same-depth composition:
- Atom part: immediate (from 1-var agreement)
- Quantifier part at depth K: for each ssn : NF sig K 3, transfer `(exists y, nf_eval M K 3 [y,x,t] ssn)`.
  - Given y0 in M0, find y in M via nf_extend_fwd (from depth-(K+1) 1-var agreement at t) -> depth-K 2-var at [y,t] and [y0,t0].
  - But y is the nf_extend_fwd witness, not positioned correctly relative to x.
  - Use Prior-UZ/SZ to find y in M in the correct zone (same zone as y0 relative to x and t).
  - Show y has the same depth-K 1-var NF as y0 (from Prior-UZ/SZ zone witness properties).
  - Apply the IH (composition at arity 3) to transfer depth-K 3-var NF from [y0,x0,t0] to [y,x,t].

Wait -- the IH at arity 3 requires depth-(K+1) 1-var agreement at y, x, t. We have depth-(K+1) at x and t (given). We need depth-(K+1) at y. But y is the witness found by Prior-UZ/SZ, and we only know its depth-K 1-var NF type (from the NF type constraint that y satisfies). We do NOT have depth-(K+1) 1-var information about y.

**The trick**: The formula DOES encode y's depth-(K+1) 1-var NF type. Specifically, the enriched formula includes char_kp1(nf_y) for each y-zone in the Until direction. This is exactly what the k=0 zone infrastructure does (KampBypassUntil.lean): it encodes y's type as temporal formulas within the zone-specific brackets.

At k>0, the formula must similarly encode y's depth-(K+1) 1-var NF type. This brings us back to the ih_exist formulas at depth k'+1 with non-constant parent -- the original problem.

**CONCLUSION**: The composition theorem with the same-depth guarantee is the correct mathematical statement, but its proof requires the SAME quantifier encoding that the sorry is blocking. The composition theorem and the ExistPart sorry are EQUIVALENT problems.

**THE TRUE PATH FORWARD**: Prove the composition theorem by induction on K with INTERNAL use of Prior-UZ/SZ at each level, without requiring external formula encoding. The proof uses only the structural properties of the NF evaluation, not temporal formulas.

For the inductive step (depth K+1 from depth K):
- Atoms: immediate
- Quantifier transfer at depth K:
  - Forward: given y in M with nf_eval at [y,x,t], find y' in N with nf_eval at [y',x',s]
  - Use nf_extend_fwd on the depth-(K+1) 1-var agreement at t/s with y -> get c' in N with depth-K 2-var agreement at [y,t] and [c',s]. But c' is not y'.
  - The key: on Prior structures, for each "zone type" of y relative to x,t, there exists y' in N in the same zone relative to x',s with the same depth-K 1-var NF. This follows from semantic_prior_UZ/SZ.
  - Specifically: if y is in (t, x), then by Prior-UZ, for every NF type tau that appears in (t, x) in M, tau also appears in (s, x') in N (because M and N agree at depth K+1 on the sentence level, and Prior-UZ ensures interval density).
  - With y' having the same depth-K 1-var NF as y, and x/x', t/s already agreeing at depth-(K+1) 1-var, apply the IH (composition at K, arity 3) to get depth-K 3-var agreement.

BUT: the IH at (K, arity 3) requires depth-(K+1) 1-var agreement at each of y, x, t. We have depth-(K+1) at x and t (given). We need depth-(K+1) at y and y'. We only have depth-K from the zone witness matching.

**This is the fundamental recursion**: to get depth-(K+1) 1-var at y, we need CharPart(K+1) (which requires ExistPart(K)), and to prove ExistPart(K+1) we need the composition theorem at K+1.

**BREAKING THE CYCLE**: The composition theorem and ExistPart/CharPart can be proved SIMULTANEOUSLY by mutual induction. Add the composition theorem as a THIRD component of the mutual induction:

```
CharPart(k) + ExistPart(k) + ComposePart(k)
```

where ComposePart(k) states: depth-(k+1) 1-var agreement at each element + matching orders + Prior-UZ/SZ => depth-k 2-var agreement (with the depth drop).

With ComposePart(k), ExistPart(k+1) can be proved by:
1. Enriched formula with char_kp1(nf_t) and char_kp1(nf_x)
2. ComposePart(k+1) gives depth-(k+1) 2-var agreement from depth-(k+2) 1-var
3. BUT we need depth-(k'+2) 2-var for sub_nf at depth k'+2...

Still the same gap.

**OK -- the correct formulation**: ComposePart(k) should state same-depth composition:

```
ComposePart(k):
depth-(k+1) 1-var agreement at each element + matching orders + Prior-UZ/SZ
=> depth-(k+1) 2-var agreement (SAME depth k+1, no drop)
```

This is the "no-drop" composition. Proving it requires:
- Atoms: immediate
- Quantifier conditions at depth k: transfer `(exists y, nf_eval M k 3 [y,x,t] ssn)` between M and N
  - Given y0 in N, find y in M in the same zone with the same depth-k 1-var NF
  - Need depth-(k+1) 1-var agreement at y/y0 for the recursive composition at arity 3
  - But y is a zone witness, and we only have depth-k 1-var matching from the zone structure

**To get depth-(k+1) 1-var at y**: Use CharPart(k+1) to build char_{k+1}(nf_y0) and check it temporally. But we are working at the NF level, not the formula level.

Alternatively: from depth-(k+1) 1-var agreement at t/s, nf_extend_fwd gives depth-k 2-var agreement at [y,t] and [c',s]. From depth-k 2-var, nf_drop_last gives depth-k 1-var at y and c'. But c' is not y'. Also, depth-k, not depth-(k+1).

**I now see the fundamental mathematical issue clearly**: The composition theorem WITH the depth drop (K+1 -> K) is provable using only nf_extend_fwd. The composition theorem WITHOUT the depth drop requires additional structure (Prior-UZ/SZ). The ExistPart sorry needs the NO-DROP version. Proving the no-drop version by induction on K requires the no-drop version at K-1 for the quantifier transfer -- this is fine, the induction works.

The base case (K=0): depth-1 1-var agreement + matching orders => depth-1 2-var agreement.
depth-1 2-var NF = (atoms, depth-0 3-var quantifier). Atoms: from 1-var pred agreement + order matching. Quantifier: `(exists y, nf_eval M 0 3 [y,x,t] chi)` is purely atomic. On Prior structures, the existence of y with given atomic properties in each zone is guaranteed by Prior-UZ/SZ. So the base case holds.

Inductive step (K -> K+1): depth-(K+2) 1-var agreement + matching orders => depth-(K+2) 2-var agreement.
depth-(K+2) 2-var NF = (atoms, depth-(K+1) 3-var quantifier).
Atoms: from 1-var pred agreement + order matching.
Quantifier: for each ssn : NF sig (K+1) 3, transfer `(exists y, nf_eval M (K+1) 3 [y,x,t] ssn)`.
  Given y0 in N: need y in M with `nf_eval M (K+1) 3 [y,x,t] ssn`.
  ssn at depth K+1 = (atoms_3, quant_3) where quant_3 involves depth-K 4-var NFs.
  Atom part of ssn: need y in M with the right predicates in the right zone.
  By Prior-UZ/SZ + CharPart(K+1): for any depth-(K+1) 1-var NF type tau, if N has y0 of type tau in zone (s, x'), then M has y of type tau in zone (t, x). (This is where Prior-UZ/SZ is essential.)
  Then y and y0 have depth-(K+2) 1-var agreement? NO -- they have the same depth-(K+1) 1-var NF type (tau), but this gives depth-(K+1) agreement, not depth-(K+2).
  Apply the IH (no-drop composition at K): depth-(K+1) 1-var agreement at y/y0, x/x', t/s + matching orders => depth-(K+1) 3-var agreement at [y,x,t] and [y0,x',s].
  This gives `nf_eval M (K+1) 3 [y,x,t] ssn <-> nf_eval N (K+1) 3 [y0,x',s] ssn`.

This WORKS. The key: the IH at K gives no-drop composition for ALL arities at depth K+1. At the step, we need no-drop composition at depth K+2 for arity 2. The quantifier transfer requires no-drop composition at depth K+1 for arity 3 (from the IH). The zone witness y has depth-(K+1) 1-var agreement with y0 (same NF type via Prior-UZ/SZ), plus depth-(K+2) at x and t (given). But the IH at (K, arity 3) needs depth-(K+1) at ALL three elements. We have depth-(K+2) at x and t, and depth-(K+1) at y -- sufficient since K+1 <= K+2.

**THIS IS THE CORRECT PROOF.** The composition theorem has the statement:

```
prior_composition_rvar(K) for all r:
depth-(K+1) 1-var agreement at each element + matching orders + Prior-UZ/SZ
=> depth-(K+1) r-var agreement
```

Proof by induction on K (universally quantified over r):
- K=0: purely atomic (all arities handled uniformly)
- K -> K+1: atoms immediate. Quantifier transfer at depth K uses Prior-UZ/SZ zone witnesses + IH at K.

This is provable and closes the sorry.

**Tasks**:
- [ ] Modify the formula construction at KampBypass.lean lines 342-375:
  - For the Until zone (h_gt_val = true): replace `Formula.untl compat_disj Formula.top` with a disjunction over compatible nf_t types: `formula_disjList [for nf_t compatible: Formula.and (char_kp1 nf_t) (Formula.untl compat_disj Formula.top)]`
  - For the Since zone: mirror the Until modification
- [ ] Prove the forward direction for the enriched formula (straightforward: the extra char_kp1(nf_t) conjunct holds at t by char_kp1_correct, nf_characteristic is in the compatible list)
- [ ] Prove the backward direction using `prior_composition_rvar`:
  - Extract nf_t from char_kp1(nf_t) at t -> `nf_eval_nf M (k'+2) 1 (fun _ => t) nf_t`
  - Extract nf_x from char_kp1(nf_x) at x (via Until) -> `nf_eval_nf M (k'+2) 1 (fun _ => x) nf_x`
  - From M0: `nf_eval_nf M0 (k'+2) 1 (fun _ => t0) nf_t` and `nf_eval_nf M0 (k'+2) 1 (fun _ => x0) nf_x` (from Classical.choice)
  - Apply `nf_agreement_from_shared_nf` to establish full depth-(k'+2) 1-var agreement at t/t0 and x/x0
  - Apply `prior_composition_rvar` at K = k'+1, r = 2 to get depth-(k'+2) 2-var agreement at [x,t] and [x0,t0]
  - Since M0 satisfies sub_nf at [x0,t0], and M agrees at [x,t]: M also satisfies sub_nf
  - Extract t < x from the 2-var atom agreement (order atom transfer)
  - Produce witness x
- [ ] Close the sorry at line 356 (Until backward)
- [ ] Close the sorry at line 368 (Since backward -- mirror the Until proof)
- [ ] Verify `lean_goal` at lines 356 and 368 shows no goals

**Timing**: 2 hours
**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampBypass.lean` -- enrich formula, close sorries

**Verification**:
- `lean_goal` at KampBypass.lean lines 356, 368 shows no goals
- `lean_verify Bimodal.Metalogic.WeakCanonical.Kamp.existPart_succ_n1_bypass` shows no `sorryAx` from Until/Since zones
- `lake build Bimodal.Metalogic.WeakCanonical.Kamp.KampBypass` succeeds

---

### Phase 4: Close n>=2 Sorry in existPart_succ [NOT STARTED]

**Goal**: Fill the sorry at KampMutualInduction.lean:310 (existPart_succ n>=2 case). With n=1 at all depths sorry-free, close n>=2 using the constant-base projection pattern from existPart_zero.

**Tasks**:
- [ ] In KampMutualInduction.lean, replace the sorry in the `succ n''` case of existPart_succ with the satisfiable/unsatisfiable case split (Classical.em), mirroring existPart_zero's n>=2 pattern at lines 183-285
- [ ] For the satisfiable case: use the M0 witness to determine which sub-NFs are realized. Project sub_nf to a 2-var NF (collapsing env variables 1..n to t). Prove atom equivalence via `bool_eq_of_iff_same` and quantifier equivalence via the parent NF agreement chain.
- [ ] For the unsatisfiable case: use Formula.bot (same as existing pattern)
- [ ] Verify `lean_verify` on `existPart_succ` and `kamp_mutual_induction` show no `sorryAx`

**Timing**: 1.5 hours
**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampMutualInduction.lean` -- fill n>=2 sorry

**Verification**:
- `lean_verify Bimodal.Metalogic.WeakCanonical.Kamp.existPart_succ` shows no `sorryAx`
- `lean_verify Bimodal.Metalogic.WeakCanonical.Kamp.kamp_mutual_induction` shows no `sorryAx`
- `lake build Bimodal.Metalogic.WeakCanonical.Kamp.KampMutualInduction` succeeds with 0 sorries

---

### Phase 5: Wire Completeness Chain and Final Verification [NOT STARTED]

**Goal**: Verify the entire completeness chain from `existPart_succ_n1_bypass` through `completeness_discrete` is sorry-free. Fix any remaining wiring issues. Cleanup.

**Tasks**:
- [ ] Run `lean_verify` on `nf_2var_exist_formula_prior_filled` to confirm no `sorryAx`
- [ ] Run `lean_verify` on `nf_characterizable_temporal_prior_classical` to confirm no `sorryAx`
- [ ] Run `lean_verify` on `kamp_prior_expressive_completeness` to confirm no `sorryAx`
- [ ] Run `lean_verify` on `US_expressively_complete_over_prior` to confirm no `sorryAx`
- [ ] Run `lean_verify` on `completeness_discrete` to confirm no `sorryAx` from this path
- [ ] Fix any wiring issues discovered during verification (e.g., NfCharFormula connector adjustments at lines 647-651 where `sorry sorry` needs to be replaced with real IH arguments)
- [ ] Run full `lake build` to confirm no regressions
- [ ] Update boneyard comment in `RabinovichGeneralized.lean` to note live version in KampMutualInduction.lean with composition theorem
- [ ] Verify k=0 infrastructure remains untouched and sorry-free
- [ ] Write implementation summary

**Timing**: 1.5 hours
**Depends on**: 4

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfCharFormula.lean` -- replace `sorry sorry` at lines 650-651 with real IH arguments from kamp_mutual_induction
- `Theories/Bimodal/Boneyard/RabinovichPath/RabinovichGeneralized.lean` -- update archive comment
- Any other files in the completeness chain if wiring issues found

**Verification**:
- `lean_verify` on entire completeness chain shows no `sorryAx` from this path
- `lake build` succeeds with no regressions
- k=0 path remains untouched and sorry-free
- Implementation summary written to specs/303_k_gt_0_depth_induction/summaries/

## Testing & Validation

- [ ] After Phase 1: `lake build KampComposition` succeeds; K=0 sorry-free; K>0 has sorry
- [ ] After Phase 2: `lean_verify prior_composition_rvar` shows no `sorryAx`; composition is sorry-free for all K
- [ ] After Phase 3: `lean_verify existPart_succ_n1_bypass` shows no `sorryAx` from Until/Since zones
- [ ] After Phase 4: `lean_verify kamp_mutual_induction` shows no `sorryAx`
- [ ] After Phase 5: `lean_verify completeness_discrete` assesses remaining sorry count from this path; full `lake build` with no regressions

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampComposition.lean` -- Prior composition theorem (new file)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampBypass.lean` -- Enriched formula and sorry-free backward proofs
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampMutualInduction.lean` -- Sorry-free mutual induction (n>=2 closed)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfCharFormula.lean` -- Wired IH arguments (no more sorry sorry)
- `specs/303_k_gt_0_depth_induction/plans/05_prior-composition-plan.md` -- this plan
- `specs/303_k_gt_0_depth_induction/summaries/05_prior-composition-summary.md` -- implementation summary

## Rollback/Contingency

If the composition theorem proof encounters unexpected obstacles:

1. **Diagnose the specific failure point**: Identify which level of the K-induction fails and whether the issue is in the zone witness step (Prior-UZ/SZ application) or the recursive composition transfer.
2. **Fallback: Weaker composition with explicit formula encoding**: If same-depth composition is too hard to prove purely at the NF level, combine the composition theorem with the enriched formula to get a hybrid approach. The formula encodes enough depth information for the specific sorry, even if the general composition is weaker.
3. **Fallback: Restructure to avoid composition entirely**: Use the VecEA2 bracket construction from the k=0 infrastructure, generalized to k>0. This would require ~1500-2000 lines but follows a proven pattern.
4. All Phase 1 work (file creation, base case) is useful regardless of approach.
5. `git revert` any phase commits to restore the pre-attempt state.
