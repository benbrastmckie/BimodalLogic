# Phase 2 Handoff: Multi-Family Z-Interval Countermodel Analysis

**Task**: 281
**Session**: sess_1780545588_1d9001
**Status**: Blocked (extensive analysis complete, implementation path identified)
**Timestamp**: 2026-06-03

## What Was Accomplished

### Exhaustive Analysis of All Approaches

Seven distinct approaches to eliminating the sorry at `countermodel_discrete_reynolds_v2` were thoroughly analyzed:

1. **Single Z-interval truth correspondence** -- FAILS at box case. With WorldState=Z and Omega={all offsets}, truth_at(.box psi) = forall offsets, truth_at psi, which equals "psi true everywhere". But temporal_truth(.box psi) = Z.interp(atomMap(.box psi)) z, which is just a predicate lookup. When .box psi is not in A but psi IS true everywhere on the Z-interval, forward direction (truth_at -> temporal_truth) fails.

2. **Prove restricted_tc/fuc without succ_embed_surjective via k-equiv** -- FAILS. The chronicle's C5 gives rational witnesses. K-equivalence gives Z-interval witnesses. But neither converts to succ_embed-image integers. The missing link: succ_embed might not be cofinal, so Z-interval/limitdom witnesses might be beyond all embedded integers.

3. **Step decomposition with next_top** -- FAILS for F(phi). F(phi) = U(phi, top), NOT U(phi, bot). The guard is top (always true), so the C5 witness can be any future domain point, not just the immediate successor. Step decomposition gives F(phi) persistence, but termination requires cofinality of succ_embed.

4. **Z1 axiom for termination** -- FAILS to give integer witness. Z1 (G(G(phi)->phi) -> (F(G(phi))->G(phi))) gives F(phi) propagation to all future integers, but doesn't produce the resolution witness.

5. **BFMCS from Z-interval temporal_truth** -- FAILS. The set {psi | temporal_truth psi at t on Z} is NOT an MCS because temporal_truth treats box as predicate lookup, while the proof system's box axioms (Modal T) require box to imply the subformula. The set is not closed under the proof system.

6. **Proving succ_embed_surjective differently** -- The original problem. succ_cofinal -> chronicle_gap_contradiction -> sorry. Extensive analysis by 8 research agents concluded this is unprovable from the current axioms.

7. **Multi-family Z-interval model** -- VIABLE but complex (~500+ lines). Build TaskFrame with WorldState = FamIdx x Z, where FamIdx indexes box-equivalent MCS families. Each family gets its own Z-interval via limitdom_is_good. Box quantification ranges over all families, resolving the S5 semantics mismatch.

### Current Code State

`countermodel_discrete_reynolds_v2` (ReynoldsBridge.lean:607) now compiles using the same parametric canonical model framework as `countermodel_discrete_reynolds`, but inherits the same sorry through restricted_tc/fuc. It's structurally equivalent to the existing v1.

### Key Mathematical Finding

The FMCS on Z (with mcs(t) = limit_f(succ_embed(t+off))) does NOT necessarily satisfy restricted_tc. When succ_embed is not cofinal, F(phi) can persist at every integer while phi only appears at non-embedded domain points beyond the succ_embed range. This is mathematically consistent: the MCS sequence at integers samples the chronicle, and the F(phi) witness is in the chronicle domain but not at any sampled point.

This means restricted_tc CANNOT be proved for the existing cantor_bfmcs_discrete without either:
(a) Proving succ_embed_surjective (= the original sorry)
(b) Building a different model that doesn't depend on chronicle sampling via succ_embed

## Multi-Family Z-Interval Approach (Implementation Plan)

### Architecture

```
For each box-equivalent MCS N (indexed by FamIdx):
  chronicle_N = omega-chain construction from N
  limitdom_N = LimitDomSubtype from chronicle_N
  M_N = limitdom_monadic_structure N
  Z_N = Z-interval from limitdom_is_good applied to M_N

TaskFrame:
  D = Z (integers)
  WorldState = FamIdx x Z
  task_rel (f, w) d (f', w') = f = f' and w' = w + d

TaskModel:
  valuation (f, w) atom = Z_f.interp(atomMap(.atom atom)) w

Omega = {sigma_fw0 | f : FamIdx, w0 : Z}
  where sigma_fw0.states t _ = (f, w0 + t)
```

### Truth Correspondence (by induction on formula)

For subformulas psi of phi, at family f with offset w0, time t:
```
truth_at TM Omega (sigma_fw0) t psi <-> temporal_truth (Z_f) atomMap (w0+t) psi
```

- **Atom**: Both sides = Z_f.interp(atomMap(.atom a))(w0+t). Direct.
- **Bot**: Both False.
- **Imp**: By IH on both subformulas.
- **Until/Since**: Within one family. Z-interval is unbounded (z_interval_carrier_contains_all). Witnesses map directly.
- **Box** (key case):
  - LHS: forall (f', w0') in Omega, truth_at psi at (f', w0'+t)
       = forall f', forall s, temporal_truth psi at s on Z_f'  (by IH)
  - RHS: Z_f.interp(atomMap(.box psi))(w0+t)  (predicate lookup, constant by k-equiv)
  
  **Box universality lemma**:
  Z_f.interp(atomMap(.box psi)) z <-> forall f', forall s, temporal_truth psi s on Z_f'
  
  Forward: box pred True on Z_f -> (k-equiv) .box psi in limit_f_f(x) forall x -> .box psi in N -> (box equiv) .box psi in A -> (modal_forward of BFMCS) psi in every family's MCS at every time -> (limitdom_temporal_truth_effective) temporal_truth psi everywhere on each limitdom -> (k-equiv) temporal_truth psi everywhere on each Z_f'
  
  Backward: forall f', forall s, temporal_truth psi s on Z_f' -> (k-equiv) forall x, table(psi)(x) on each limitdom -> effectiveFormula(psi) in limit_f at all domain points -> psi in N' for each N' -> (modal_backward of BFMCS) .box psi in A -> (box stability) .box psi in limit_f_f(x) forall x -> (k-equiv) box pred True on Z_f

### Estimated Effort

- Multi-family TaskFrame/History/Omega: ~80 lines
- TaskModel and shift-closure: ~50 lines
- Truth correspondence atom/bot/imp: ~30 lines
- Truth correspondence until/since: ~80 lines
- Box universality (both directions): ~150 lines
- Final assembly and wiring: ~60 lines
- Total: ~450 lines

### Dependencies

All required infrastructure is sorry-free:
- cantor_bfmcs_discrete (modal_forward, modal_backward)
- limitdom_is_good
- z_interval_carrier_contains_all
- k_equiv_preserves_sentence
- table_correctness
- limitdom_temporal_truth_effective
- effectiveFormula_id_of_sub
- box_stable_in_limit_f

### Critical Sub-Lemmas Needed

1. `box_universality_forward`: Z_f.interp(atomMap(.box psi)) z -> forall f' s, temporal_truth psi s on Z_f'
2. `box_universality_backward`: (forall f' s, temporal_truth psi s on Z_f') -> Z_f.interp(atomMap(.box psi)) z
3. `multifam_until_forward`: temporal_truth U(psi1,psi2) at z on Z_f -> truth_at U(psi1,psi2) at sigma_fw0 t
4. `multifam_until_backward`: truth_at U(psi1,psi2) at sigma_fw0 t -> temporal_truth U(psi1,psi2) at z on Z_f

## Immediate Next Action

Implement the multi-family Z-interval model:
1. Define FamIdx type from cantor_bfmcs_discrete families
2. For each family, extract the Z-interval via limitdom_is_good (using Choice)
3. Define TaskFrame with WorldState = FamIdx x Z
4. Define TaskModel, Omega, histories
5. Prove truth correspondence by structural induction
6. Wire into countermodel_discrete_reynolds_v2
7. Wire into completeness_discrete (Completeness.lean:369)

## Key Decisions

- The single Z-interval approach is provably insufficient (box case fails)
- restricted_tc/fuc cannot be proved without succ_embed_surjective for the existing BFMCS
- Multi-family Z-interval is the mathematically correct approach
- The implementation is substantial (~450 lines) but structurally clear
- All required infrastructure lemmas are sorry-free

## Files Modified

- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/ReynoldsBridge.lean` -- countermodel_discrete_reynolds_v2 restructured to use parametric model (compiles, still has sorry through restricted_tc/fuc)
