# Research Report: Architectural Insight — Forward vs Backward Zone Construction

- **Task**: 273 - chronicle_gap_contradiction_proof
- **Session**: sess_1781438804_42f71b
- **Date**: 2026-06-14
- **Status**: researched
- **Tier**: Tier 1 (literature-backed)

## Summary

After 10 orchestration runs and 45+ agent dispatches, the KampBypass.lean sorries resist closure despite having all the mathematical infrastructure in place (ZoneBridge.lean, VecEADecomp.lean, NfToVecEA.lean — all sorry-free). The root cause is an **architectural mismatch**: KampBypass works backwards from NF order booleans to temporal positions, while the literature (GHR94, Rabinovich) works forwards — letting the temporal structure determine the ordering. This mismatch creates a 13-ordering combinatorial explosion that the literature avoids entirely.

The fix is not more helper lemmas. It is to replace KampBypass's custom zone formula construction with direct calls to the existing sorry-free VecEADecomp zone theorems + VecEA2 translation pipeline, aligning the codebase with the literature's forward approach.

## Findings

### Finding 1: The Architectural Mismatch

KampBypass.lean constructs temporal formulas for `∃ y, nf_eval M 0 3 (y, x, t) ssn` by:

1. Extracting 6 order booleans from `ssn` (y<x, x<y, y<t, t<y, x<t, t<x)
2. Classifying into a zone via `ssn_zone_until` (13 realizable orderings)
3. Building a per-zone temporal formula (`depth0_3var_exist_formula`)
4. Assembling into `enriched_point_type_x_until`, `pre_conditions_at_t_until`, `interval_guard_until`
5. Proving the assembled formula equivalent to the NF existential (THIS IS WHERE IT FAILS)

Step 5 fails repeatedly because it requires reconstructing the NF evaluation from the temporal formula's truth — working backwards from the formula to the NF. Each dispatch discovers a new edge case (v1: lost y-t order; v2: order-inconsistent ssn values; v3: zone classification gaps).

The literature takes the **opposite direction**:

1. The temporal structure (Until/Since nesting) DETERMINES the zone
2. Witnesses are placed structurally (bracket points, endpoint conditions)
3. The ordering follows from the nesting, not from boolean extraction
4. No 13-ordering case analysis is needed

### Finding 2: GHR94 Approach — 3 Sub-Cases, Not 13

**Source**: `specs/literature/Gabbay_Hodkinson_Reynolds_1994_Temporal_Logic_Foundations_Vol1_ch10.md`

GHR94 Lemma 10.2.3, Case 1 handles `S(a ∧ U(A,B), q)` — a Since formula with an Until subformula. The Until witness `u` is relative to the Since witness `s`, and the evaluation point is `t`. The proof splits on `u`'s position relative to `t` into exactly **3 sub-cases**:

| Sub-case | Condition | Result |
|----------|-----------|--------|
| u > t | U(A,B) witness is in the future | `S(a,q) ∧ S(a,B) ∧ B ∧ U(A,B)` |
| u = t | U(A,B) witness is at the evaluation point | `A ∧ S(a,B) ∧ S(a,q)` |
| u < t | U(A,B) witness is in the past of t | `S(A ∧ q ∧ S(a,B) ∧ S(a,q), q)` |

The other reference point `s` is **structurally bound** by the Since operator — its position (s < t) is guaranteed by the Since semantics. No case analysis on s's ordering is needed. The total case count is 3 × 8 = 24 elimination equivalences for all combinations, not 13^n orderings.

The key design principle: **each temporal operator binds one reference point, reducing the free ordering to a single relative position**.

### Finding 3: Rabinovich Approach — Structural Ordering via Interval Decomposition

**Source**: `specs/literature/Rabinovich_2014_Proof_of_Kamps_Theorem.md`

Rabinovich Definition 3.1 defines exists-forall formulas as **interval decompositions**:

```
ψ(z₀, ..., z_m) := ∃ x_n ... ∃ x_0
  (ordering constraints) ∧ (point types α_j at x_j) ∧ (interval types β_j along intervals)
```

Proposition 3.5 translates these to TL(Until, Since) by **directly mapping the interval structure to nested temporal operators**:

- Future part: `A_k ∧ (B_{k+1} Until (A_{k+1} ∧ (B_{k+2} Until ... )))`
- Past part: `A_k ∧ (B_k Since (A_{k-1} ∧ (B_{k-1} Since ... )))`

The ordering is **structural** — encoded in the nesting of Until/Since, not inferred from boolean atoms. Adding an existential witness (Lemma 3.4(3)) means adding one more point to the interval decomposition. No order boolean extraction occurs anywhere in the proof.

### Finding 4: VecEADecomp Already Implements the Forward Approach

**Source**: `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/VecEADecomp.lean` (898 lines, sorry-free)

VecEADecomp follows the literature pattern exactly. Each zone theorem constructs a specific VecEA2 with the ordering **built into the structure**:

| Theorem | Zone | VecEA2 structure |
|---------|------|-----------------|
| `nf_3var_bracket_tyx_correct` | t < y < x | y is bracket witness between z₀=t, z₁=x |
| `nf_3var_bracket_xyt_correct` | x < y < t | y is bracket witness between z₀=x, z₁=t |
| `nf_3var_zone_ytx_correct` | y < t < x | y is Since-witness endpoint |
| `nf_3var_zone_txy_correct` | t < x < y | y is Until-witness endpoint |
| `nf_3var_zone_yxt_correct` | y < x < t | y is Since-witness endpoint |
| `nf_3var_zone_xty_correct` | x < t < y | y is Until-witness endpoint |

Each theorem proves a biconditional between `nf_eval_nf M 0 3 env ssn` and `VecEA2.holds M atomMap z₀ z₁`. The VecEA2 structure handles the ordering — no boolean extraction needed.

Additionally, `ZoneBridge.lean` (422 lines, sorry-free) provides the NF-level equivalences:

| Theorem | Bridge |
|---------|--------|
| `zone_bridge_above_x` | nf_eval ↔ ∃ y > x with right preds |
| `zone_bridge_between_tx` | nf_eval ↔ ∃ y ∈ (t,x) with right preds |
| `zone_bridge_below_t` | nf_eval ↔ ∃ y < t with right preds |
| `zone_bridge_eq_x` | nf_eval at (x,x,t) ↔ pred + order conditions |
| `zone_bridge_eq_t` | nf_eval at (t,x,t) ↔ pred + order conditions |

### Finding 5: KampBypass Reverses the Correct Direction

**Source**: `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampBypass.lean` (1269 lines, 7 sorries)

KampBypass builds custom zone formulas via:
- `depth0_3var_exist_formula` — constructs temporal formula per ssn by extracting order booleans
- `ssn_zone_until` — classifies ssn into 6 zones based on order booleans
- `enriched_point_type_x_until` — assembles zone formulas at x
- `pre_conditions_at_t_until` — assembles zone formulas at t
- `interval_guard_until` — assembles guard conditions in (t,x)

This is the **reverse** of the literature approach:
- Literature: temporal nesting → ordering → NF evaluation (forward)
- KampBypass: NF booleans → zone classification → temporal formula → prove equivalence back to NF (backward)

The backward direction repeatedly fails because reconstructing `nf_eval_nf M 0 3 env ssn` from temporal formula truth requires re-establishing all atom conditions — the same 13-ordering combinatorics that the forward approach avoids.

### Finding 6: Recommended Direction

**Replace KampBypass's custom zone formulas with VecEADecomp + VecEA2 translation.**

The pipeline should be:

```
For each ssn with sub_nf.2 ssn = true:
  1. Determine ssn's zone from order atoms (ssn_zone_until — already exists)
  2. Call the corresponding VecEADecomp zone theorem to get VecEA2
  3. Translate VecEA2 → Formula via VVecEA2.translateLeft/translateRight (sorry-free)
  4. The correctness proof follows by composition of sorry-free theorems

For each ssn with sub_nf.2 ssn = false:
  1. Same as above, but negate the resulting formula
  2. ¬(Formula) is directly a Formula
  3. Or use neg_2var_vec_ea (sorry-free Prop 4.2) for the VecEA2-level negation
```

This eliminates the backward-direction proofs entirely. The formula IS the VecEA2 translation, and its correctness IS the composition of VecEADecomp + VecEA2.translateLeft_correct — both sorry-free.

The existing KampBypass infrastructure (ssn_order_consistent, ssn_xt_compatible, zone classification) can be **reused** for step 1. Only the formula construction (steps 2-3) and correctness proof need to change.

**Estimated effort**: ~300-500 lines to restructure KampBypass, replacing custom zone formulas with VecEADecomp calls. Most of the existing 1269 lines can be simplified or removed.

## References

| Source | Path | Relevance |
|--------|------|-----------|
| GHR94 Ch. 10 | `specs/literature/Gabbay_Hodkinson_Reynolds_1994_Temporal_Logic_Foundations_Vol1_ch10.md` | 8 elimination lemmas, 3-sub-case pattern |
| Rabinovich 2014 | `specs/literature/Rabinovich_2014_Proof_of_Kamps_Theorem.md` | Interval decomposition, structural ordering |
| VecEADecomp | `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/VecEADecomp.lean` | Sorry-free zone theorems (898 lines) |
| ZoneBridge | `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/ZoneBridge.lean` | Sorry-free NF↔zone bridges (422 lines) |
| KampBypass | `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampBypass.lean` | Current approach with 7 sorries (1269 lines) |
| VecEATranslation | `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/VecEATranslation.lean` | Sorry-free VecEA2 → TL translation |
| NegationClosureProp42 | `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NegationClosureProp42.lean` | Sorry-free Prop 4.2 negation closure |
| NfToVecEA | `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfToVecEA.lean` | Sorry-free depth-0 2-var bridge (634 lines) |
| Team Research | `specs/273_chronicle_gap_contradiction_proof/reports/26_team-research.md` | Teammate B finding: "VecEADecomp should be used AS-IS" |
