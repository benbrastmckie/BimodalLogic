# Handoff: Enriched Until Formula Analysis

## Immediate Next Action

Restructure `existPart_succ_n1_bypass` at k>0 in KampBypass.lean (lines 605-740) to
encode ALL quantifier conditions directly in the temporal formula, eliminating the
dependency on the false `prior_2var_transfer_until/since` (PriorComposition.lean).

## Current State

- WitnessCount.lean: cleaned up (sorry-free). Removed 3 false theorems
  (`zone3_exist_transfer`, `k0_depth1_2var_agree_until`, `k0_depth1_2var_agree_since`).
  Retained reusable infrastructure: `temporal_truth_transfer`, `depth2_quant_transfer`,
  `nf_depth0_char_operator_depth`, `nf_depth0_char_iff_eval`.
- PriorComposition.lean: K=0 sorry at lines 880 and 978 remains. These theorems are
  FALSE and cannot be proved. The fix is architectural (in KampBypass.lean, not here).
- Full `lake build` passes.

## Key Findings from This Dispatch

### 1. Cross-Structure Zone-3 Transfer is Irreducibly FALSE

`prior_nonconstenv_2var_agree_until` at K=0 is FALSE. Counterexample:
M=N=Z with is_even, t=t'=0, x=4, x'=2. Even on Prior structures (Z satisfies
semantic_prior_UZ/SZ because it's discrete). The zone-3 existential "exists even w
in (0,4)" holds but "exists even w in (0,2)" does not.

This falseness propagates through:
- `zone3_exist_transfer` (WitnessCount.lean, removed)
- `prior_nonconstenv_2var_agree_until/since` at K=0 (PriorComposition.lean:880,978)
- `prior_2var_transfer_until/since` (PriorComposition.lean:1042,1076)
- `existPart_succ_n1_bypass` backward direction at k>0 (KampBypass.lean:646,713)

### 2. The Temporal Formula Transfer Approach Also Fails for Zone-3

The plan v19 Phase 3 proposed using temporal formula transfer + HasAttainedINF
first-occurrence to handle zone-3. This fails because:
- The VecEA2 bracket with endRight = P_x gives z1 > t with P_x type
- HasAttainedINF gives FIRST P_x above t as r0 <= x
- But witnesses must be STRICTLY BETWEEN t and r0, not AT r0
- When r0 = x' (as in the counterexample), the open interval (t', r0) may lack the witness type

Specifically: Z with is_even, r0 = 2 = first even above 0. The interval (0, 2)
contains only {1} (odd). The bracket witness would need to be in this interval
but cannot be even.

### 3. The Correct Fix: Generalize the k=0 Bypass Pattern

The k=0 bypass (`existPart_succ_n1_bypass_k0`) is sorry-free. It uses VecEA2 brackets
to encode zone-3 witnesses directly in the temporal formula. The formula works on ANY
Prior structure (no cross-structure transfer needed).

The k>0 Until/Since cases (lines 605-740) should use the SAME pattern:
1. Build enriched VecEA2 formula encoding ALL quantifier conditions
2. Forward: from nf_eval at [x, t], construct the temporal formula
3. Backward: from the temporal formula, reconstruct nf_eval at [x, t]

### 4. The Remaining Challenge for k>0

At k>0, the backward direction must reconstruct the FULL 2-var NF at [x, t], including
quantifier conditions (depth-k 3-var existentials). At k=0, these are purely atomic
(determined by predicates + ordering). At k>0, they have their own quantifier conditions,
leading to recursive zone-3 sub-problems.

Two approaches:

**Approach A (Deep Bracket)**: Encode ALL levels of zone-3 witnesses in a single flat
bracket formula. The bracket witnesses include depth-k zone-3 witnesses, their depth-(k-1)
sub-witnesses, down to depth-0 (atomic). The total number is bounded by the product of
NF type counts at each level. The bracket's flat ordering naturally separates sub-intervals.

**Approach B (GeneralExistPart)**: Use the classical satisfiability argument from
GeneralExistPart.lean. For each quantifier condition at [x, t], the condition is
model-independently determined (top/bot) given the full 2-var NF at [x, t]. Since sub_nf
IS the full 2-var NF, the conditions are pre-computed from M0. The enriched formula
encodes the atoms (from char_kp1) + ordering (from Until structure) + pre-computed
quantifier conditions (as temporal conjuncts, using GeneralExistPart for non-constant-env
conditions or ih_exist for constant-env conditions).

**The core difficulty with both approaches**: the backward direction requires showing that
a point x in M with matching char_kp1 1-var NF, placed above t by the Until structure,
has the SAME multi-var NF at [x, t] as x0 at [x0, t0] in M0. This requires the multi-var
NF to be determined by the 1-var NFs + ordering, which is FALSE in general (the original
counterexample).

**Potential resolution**: Use nested enriched formulas. Instead of encoding just the
1-var types, encode the full 2-var NF via a combination of:
- 1-var type at x (char_kp1)
- For each quantifier condition at [x, t]: a dedicated temporal formula encoding
  whether the condition holds, using ih_exist for zone-1,2 (below t) and zone-4,5
  (above x), and recursive bracket encoding for zone-3 (between t and x)

This turns the problem into a well-founded recursion on NF depth, where:
- depth 0: purely atomic, handled by the k=0 bypass (sorry-free)
- depth k+1: uses depth-k conditions, handled by ih_exist + recursive brackets

### 5. Estimated Effort

Full fix (restructuring existPart_succ_n1_bypass at k>0): 800-1200 lines of new code.
Key files: KampBypass.lean (modified), possibly new helper file for generalized enriched
VecEA2 construction at arbitrary depth.

## Sorry Inventory

| File | Line | Statement | Why Deferred |
|------|------|-----------|-------------|
| PriorComposition.lean | 880 | prior_nonconstenv_2var_agree_until K=0 | FALSE (counterexample) |
| PriorComposition.lean | 978 | prior_nonconstenv_2var_agree_since K=0 | FALSE (counterexample) |
| PriorComposition.lean | 508 | zone_compatible_witness d=0 | Dead code (not on critical path) |
| PriorComposition.lean | 556 | nf_eval_from_lower_agree n=0 | Dead code |
| PriorComposition.lean | 644 | zone_compatible_witness d=1 r=0 | Dead code |
| PriorComposition.lean | 651 | nf_eval_from_lower_agree d=0 | Dead code |
| PriorComposition.lean | 663 | nf_eval_from_lower_agree d+1 | Dead code |
| NfCharFormula.lean | 542 | nf_exist_backward_depth_succ | Downstream of PriorComposition |
| NfCharFormula.lean | 657 | nf_2var_exist_formula_prior k>0 | Downstream of PriorComposition |
| EANegation.lean | 1047 | neg_ea_formula_correct bwd | Related pipeline |
| EANegation.lean | 1172 | neg_ea_formula_full bwd | Related pipeline |

## Key Decisions

- Removed 3 false theorems from WitnessCount.lean (zone3_exist_transfer,
  k0_depth1_2var_agree_until, k0_depth1_2var_agree_since)
- Kept reusable infrastructure (temporal_truth_transfer, depth bounds)
- Removed unused PriorComposition import from WitnessCount.lean
- Documented that the fix must be at the KampBypass level, not PriorComposition
