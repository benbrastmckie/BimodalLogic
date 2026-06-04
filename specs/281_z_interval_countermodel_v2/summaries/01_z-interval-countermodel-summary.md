# Implementation Summary: Z-Interval Countermodel v2

- **Task**: 281 - Complete countermodel_discrete_reynolds_v2
- **Status**: [BLOCKED]
- **Cycles Used**: 2/5
- **Session**: sess_1780545588_1d9001

## Accomplished

### Phase 1: Z-Interval Unboundedness (COMPLETED)

- Proved `z_interval_carrier_contains_all`: every integer is in the Z-interval carrier
- Proof transfers depth-2 FO sentences ("has maximum"/"has minimum") via `k_equiv_preserves_sentence`
- If Z-interval had bounded endpoints, the sentence would be true on Z but false on M (NoMaxOrder/NoMinOrder), contradiction
- Result: `Z.lo = none` and `Z.hi = none`, making all carrier membership trivially True

### Infrastructure (compiles, no sorry)

- `zTaskFrame_v2`: TaskFrame on Z with WorldState = Z, deterministic task_rel
- `zHistory_v2 w₀`: offset-parameterized history, domain = True, states t _ = w₀ + t
- `zOmega_v2`: Set.range zHistory_v2, all offset histories
- `zOmega_v2_shiftClosed`: ShiftClosed proof for zOmega_v2
- `zTaskModel_v2`: position-dependent atom valuation from Z-interval
- `limitdom_root_neg_truth`: temporal truth of φ.neg at root (sorry-free)

### Countermodel Pipeline (partial)

Lines 607-661 of ReynoldsBridge.lean:
1. `limitdom_is_good` → Z-interval + k-equivalence ✓
2. `truth_transfer` → temporal truth of φ.neg on Z-interval ✓
3. Existential package with D=ℤ, all typeclass instances ✓
4. Final goal: `¬truth_at TM zOmega_v2 (zHistory_v2 0) s.val φ` — **BLOCKED**

## Mathematical Blocker: Box Semantics Mismatch

The truth correspondence between `truth_at` (TaskModel semantics) and `temporal_truth` (FO semantics on Z-interval) cannot be established for box formulas. This is a fundamental mathematical issue, not an implementation difficulty.

### The Problem

- `temporal_truth(.box ψ) = Z.interp(atomMap(.box ψ)) t` — opaque predicate lookup from the Z-interval construction
- `truth_at(.box ψ)` with WorldState=Z and zOmega_v2 = `∀ w₀, truth_at ψ (zHistory_v2 w₀) t` = `∀ s, temporal_truth ψ s` (universal temporal truth)

These represent different semantic notions:
- The box predicate on the Z-interval inherits from the chronicle's MCS membership: `.box ψ ∈ limit_f(t)`. This encodes whether `ψ` holds at ALL S5-accessible worlds (including non-chronicle worlds).
- Universal temporal truth `∀ s, temporal_truth ψ s` encodes whether `ψ` holds at all CHRONICLE points (one temporal path through the S5 class).

### Why They Diverge

The chronicle visits a single temporal path through the S5 equivalence class. Other S5-accessible worlds (not on the chronicle) may have different truth values for ψ. Specifically:

- `.box ψ ∉ A` implies `◇¬ψ ∈ A` (S5), meaning ¬ψ holds at some accessible world W
- W might NOT be any chronicle point limit_f(t) — it could be a world not visited by this chronicle
- So `.box ψ ∉ A` is compatible with `∀t, ψ ∈ limit_f(t)` (ψ true everywhere on chronicle)
- On the Z-interval: box predicate = False, but universal temporal truth = True — MISMATCH

### Why k-Equiv Cannot Help

k-equivalence preserves FO sentences within a SINGLE structure. The box semantics require a multi-world structure (BFMCS with multiple families). A single Z-interval encodes one world's temporal truth, not the full S5 equivalence class.

The FO sentence `∀x. P_box(x) ↔ ∀y. table(ψ)(y)` is FALSE on the limitdom when `.box ψ ∉ A` but ψ holds at all chronicle points. So it cannot be transferred via k-equiv.

### Why the Alternative (WorldState=Unit) Also Fails

With WorldState=Unit and singleton Omega: `truth_at(.box ψ) = truth_at(ψ)` (box = identity). By IH: = `temporal_truth(ψ) at t`. Need: = `Z.interp(atomMap(.box ψ)) t` = `.box ψ ∈ limit_f(t)`.

Forward direction fails: `ψ ∈ limit_f(t)` does NOT imply `.box ψ ∈ limit_f(t)`. Having ψ at one time point doesn't make □ψ true.

## Alternative Approaches (for future work)

### Approach A: Prove restricted_tc/fuc Without succ_embed_surjective

Use the existing BFMCS (cantor_bfmcs_discrete, sorry-free) and its parametric model. The bottleneck is restricted_tc/fuc which use `succ_embed_surjective`. If these can be proved by a different method (e.g., using the Z-interval as witness source for temporal properties), the existing `countermodel_discrete_reynolds` becomes sorry-free.

**Challenge**: restricted_tc needs φ ∈ fam.mcs(s) at a specific INTEGER s, not just existence on the Z-interval. k-equiv gives sentence-level correspondence, not pointwise.

### Approach B: Hybrid Multi-Z-Interval BFMCS

Build a BFMCS where each family corresponds to a different chronicle (different root in the S5 class), each with its own Z-interval. Temporal coherence comes from each Z-interval's temporal truth semantics. Modal coherence comes from the S5 relationship between chronicles.

**Challenge**: Establishing modal coherence (Box φ → φ in all families) requires cross-Z-interval correspondence, which k-equiv doesn't provide.

### Approach C: Direct Parametric Truth via Z-Interval Witnesses

Modify the restricted parametric truth lemma to accept Z-interval-sourced witnesses instead of succ_embed-sourced witnesses. The temporal resolution properties (F, P, Until, Since) would be proved using Z-interval temporal truth + k-equiv sentence transfer.

**Challenge**: The parametric truth lemma expects witnesses at specific integer positions in a family's MCS. Connecting Z-interval positions to family MCS positions requires the pointwise correspondence that k-equiv doesn't give.

## Files Modified

- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/ReynoldsBridge.lean` — v2 infrastructure + unboundedness proof
- `specs/281_z_interval_countermodel_v2/plans/01_z-interval-countermodel.md` — Phase 1 [COMPLETED], Phase 2 [BLOCKED]

## Remaining Sorry

One sorry at ReynoldsBridge.lean:661 in `countermodel_discrete_reynolds_v2`: the final goal `¬truth_at TM zOmega_v2 (zHistory_v2 0) s.val φ`, blocked by the box semantics mismatch described above.
