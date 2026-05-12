# Implementation Plan: Construction-Specific IsSuccArchimedean via Limit-Point Contradiction

- **Task**: 123 - fix_c5_witness_bot_and_prove_icc_finite
- **Status**: [NOT STARTED]
- **Effort**: 4-6 hours
- **Dependencies**: None (all prerequisite infrastructure exists sorry-free)
- **Research Inputs**:
  - specs/123_fix_c5_witness_bot_and_prove_icc_finite/reports/04_team-research.md
  - specs/123_fix_c5_witness_bot_and_prove_icc_finite/reports/05_team-research.md
  - specs/123_fix_c5_witness_bot_and_prove_icc_finite/reports/05_teammate-a-findings.md
  - specs/123_fix_c5_witness_bot_and_prove_icc_finite/reports/05_teammate-b-findings.md
  - specs/123_fix_c5_witness_bot_and_prove_icc_finite/reports/05_teammate-c-findings.md
  - specs/123_fix_c5_witness_bot_and_prove_icc_finite/reports/05_teammate-d-findings.md
- **Artifacts**: plans/05_construction-specific.md (this file)
- **Standards**:
  - .claude/context/formats/plan-format.md
  - .claude/rules/artifact-formats.md
  - .claude/rules/state-management.md
  - .claude/rules/lean4.md
- **Type**: lean4
- **Lean Intent**: true

### Research Integration

**Round 4** (`04_team-research.md`, 4 teammates): Confirmed that `IsSuccArchimedean` is provable and that pure order theory is insufficient -- real analysis (monotone convergence) is needed. All Mathlib imports are already present. 6 of 7 typeclass prerequisites exist; only `IsSuccArchimedean` is missing.

**Round 5** (`05_team-research.md`, 4 teammates): **CRITICAL REVISION.** Two teammates (B, C) independently confirmed that the monotone convergence + predecessor contradiction approach from plan v4 has a genuine mathematical gap. When the limit L of the pred-chain is NOT in `limit_dom` (e.g., L is irrational), there is no domain point at L, so the predecessor contradiction never fires. The gap-at-L configuration (two infinite orbits converging from opposite sides with no domain point at L) is order-theoretically consistent.

**Key findings from round 5:**
- Plan v4 Phase 2 proof strategy is incorrect as stated (convergence gap in Case B: L not in limit_dom)
- Pure order theory + real analysis convergence CANNOT close this sorry alone
- A construction-specific argument is needed that exploits properties of the omega-chain enumeration
- TC can be proved without surjectivity (Teammate D), but FUC still requires it
- The correct contradiction when L IS in limit_dom: `pred(L_sub) < L_sub`, orbit elements eventually exceed `pred(L_sub).val`, placing a domain point between `pred(L_sub)` and `L_sub` -- contradiction with immediate successor property (Teammate B, Section 4.4)
- The fix: after monotone convergence to L, case split on whether L is in limit_dom; the L-in-domain case works; the L-not-in-domain case needs a construction-specific argument showing L MUST be in limit_dom (or that the scenario is impossible)

### Prior Plan Reference

Plan v4 (`04_issucc-archimedean.md`) had 3 phases:
- **Phase 1** [COMPLETED]: Mathlib imports + `order_succ_eq` / `order_pred_eq` (both `rfl`)
- **Phase 2** [PARTIAL]: IsSuccArchimedean convergence proof -- sorry at line 1211
- **Phase 3** [COMPLETED]: `succ_embed_surjective` rewritten to use IsSuccArchimedean -- 2 original sorry sites eliminated

**Lesson learned from plan v4**: The convergence argument establishes that both the succ-orbit and pred-chain converge to limits in R, but the final contradiction step only works when the limit L is a domain point. The gap-at-L scenario (L not in limit_dom) is consistent with all abstract order properties, so the proof must invoke a construction-specific property to rule it out.

### Roadmap Alignment

This plan advances:
- "Discrete completeness: 1 sorry remains (task 122)" -- closing `succ_embed_surjective` makes the discrete countermodel sorry-free
- "Full `bx_completeness`: Blocked by 1 sorry in discrete case" -- unblocking the discrete case moves toward sorry-free `bx_completeness`

## Overview

This plan replaces Phase 2 from plan v4 with a corrected proof strategy that addresses the convergence gap. The sole remaining sorry is at line 1211 of `ChronicleToCountermodel.lean`: given `a b : LimitDomSubtype` with `a <= b` and `forall n, succ^[n](a) < b`, derive `False`.

The proof strategy has two stages:
1. **Monotone convergence** (same as plan v4, correct): establish that the succ-orbit `succ^[n](a).val` converges to a limit L in R, and that the pred-chain `pred^[k](b).val` converges to the same limit L.
2. **Construction-specific contradiction** (NEW): prove that L must be in `limit_dom` by exploiting the omega-chain enumeration structure. Specifically, each element of `limit_dom` enters at a finite stage via `counterexample_enum`. The limit L is the supremum of a bounded increasing sequence of rationals, hence L is rational (since `LimitDomSubtype` is a subtype of Q, all orbit values are rational, and the supremum of a bounded monotone sequence of rationals need not be rational -- BUT we can show that for any domain point z above L, `pred(z)` is also a domain point above L, which means the pred-chain from b stays above L. If no domain point equals L, then the open interval `(pred(z).val, z.val)` for z = smallest pred-chain element close to L contains orbit elements, contradicting the immediate successor property). The key insight from Teammate B's analysis (Section 4.4): when L is in the domain, `pred(L_sub)` is below L, and orbit elements eventually lie between `pred(L_sub)` and `L_sub`, contradicting the immediate successor property.

**The corrected argument**: After establishing convergence to L, show L is in `limit_dom` by contradiction. If L is not in `limit_dom`, then for every pred-chain element `pred^[k](b)` (which is above L), `pred(pred^[k](b)) = pred^[k+1](b)` is also above L. But the succ-orbit is below L and approaches L. Consider any pred-chain element z close to L from above. Between `pred(z)` and `z`, there are no domain points (immediate successor property). But `pred(z).val > L > succ^[n](a).val` for all n (since all orbit elements are below L). However, if `pred(z).val < L`, then for large n, orbit elements sit between `pred(z)` and `z` -- contradiction. The only way to avoid this is `pred(z).val >= L` for all domain z > L. If `pred(z).val > L` strictly for all z above L, the pred-chain stays above L, converging to L but never reaching it. In this scenario, the gap between consecutive pred-chain elements shrinks to zero, and both sequences (orbit and pred-chain) converge to L from opposite sides with no domain point at L. This is the gap-at-L scenario.

To rule out the gap-at-L scenario, we need a construction-specific argument. The most promising approach: use `Countable` + strict monotonicity to show the orbit maps N injectively into the Icc, then use Bolzano-Weierstrass (the limit L as an accumulation point) to find a domain point at L, OR use the omega-chain stage structure to show a domain point must be placed at L.

**Alternative approach (simpler to formalize)**: Instead of proving L is in `limit_dom`, prove `Set.Icc a b` is finite directly, then use `LocallyFiniteOrder.ofFiniteIcc` to get `IsSuccArchimedean` from Mathlib. Icc finiteness can be proved by showing the succ-orbit from a reaches b (circular?) OR by showing the omega-chain construction only puts finitely many points in any bounded interval. This is the approach recommended by Teammate D (Strategy 1).

**Practical implementation strategy**: The plan provides THREE ordered approaches. The implementation agent should attempt them in order, moving to the next only if the current one encounters a formalization barrier.

**Definition of done**: `limitDomSubtype_isSuccArchimedean` at line 1211 is sorry-free. `succ_embed_surjective` is sorry-free. `dd_countermodel_chronicle_discrete` is sorry-free. The only remaining sorry sites in `ChronicleToCountermodel.lean` are `dd_countermodel_chronicle_nondense_sorry` (line 839) and `dd_countermodel_chronicle_mixed_sorry` (line 2638).

## Goals & Non-Goals

**Goals:**
- Close the sorry at line 1211 (`limitDomSubtype_isSuccArchimedean`)
- Try Approach A first, then B, then C (see Phase 2)
- Make `dd_countermodel_chronicle_discrete` sorry-free

**Non-Goals:**
- Modifying the omega-chain construction (`ChronicleConstruction.lean`)
- Modifying BUC (already sorry-free)
- Solving the mixed case (`dd_countermodel_chronicle_mixed_sorry`)
- Modifying Phase 1 or Phase 3 from plan v4 (both [COMPLETED])

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Approach A (L-in-domain) cannot show L is rational or in limit_dom | H | M | Fall through to Approach B (Icc finiteness) |
| Approach B (Icc finiteness) requires proving stabilization of the construction | H | M | Use omega-chain stage + dom_new_unique to bound interval growth |
| Approach C (WellFoundedGT) is too abstract | M | M | Only attempt if A and B fail; has Mathlib instance `WellFoundedGT.toIsSuccArchimedean` |
| Formalization of the L-in-domain case is straightforward but the L-not-in-domain case requires novel argument | H | L | The L-in-domain case is cleanly described by Teammate B; if L-not-in-domain is too hard, pivot to Approach B |
| `lake build` time increases with new helper lemmas | L | L | Incremental builds; use `lean_goal` for fast feedback |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |

Phases within the same wave can execute in parallel.

### Phase 1: Add Imports and Prove Order.succ Equality [COMPLETED]

**Goal**: Add the two missing Mathlib imports and prove that `Order.succ` equals `limitDomSubtype_succ` when the `SuccOrder` instance is registered via `letI`.

**Tasks**:
- [x] Add `import Mathlib.Topology.Instances.Real.Lemmas` (already present, line 11)
- [x] Add `import Mathlib.Data.Rat.Cast.Order` (already present, line 12)
- [x] Prove `order_succ_eq` (line 1006, `rfl`)
- [x] Prove `order_pred_eq` (line 1017, `rfl`)

**Timing**: 0.5-1 hour (completed)

**Depends on**: none

**Completed**: 2026-05-11

---

### Phase 2: Close the Sorry at limitDomSubtype_isSuccArchimedean [PARTIAL]

**Goal**: Replace the `sorry` at line 1211 with a valid proof. The goal state is:
```
a b : LimitDomSubtype A h_mcs
hab : a <= b
h_not_cofinal : forall (n : Nat), (limitDomSubtype_succ A h_mcs h_discrete)^[n] a < b
|- False
```

The implementation agent should attempt the following approaches in order. If Approach A encounters a formalization barrier at the L-not-in-domain case, pivot to Approach B. If Approach B encounters difficulty proving Icc finiteness, pivot to Approach C.

#### Approach A: Monotone Convergence with Construction-Specific L-in-Domain Proof

**Mathematical argument:**

Step 1: From `h_not_cofinal`, derive `succ^[n](a) <= pred(b)` for all n (using `succ_iter_le_pred_of_lt_forall`, line 1155).

Step 2: Show `succ^[n](a) < pred^[k](b)` for all n, k, by induction on k:
- Base: `succ^[n](a) < b = pred^[0](b)` (from `h_not_cofinal`).
- Step: If `succ^[n](a) < pred^[k](b)` for all n, then if `succ^[m](a) = pred^[k](b)` for some m, then `succ^[m+k](a) = b` (using `succ_iter_eq_gives_next` and `limitDomSubtype_succ_pred` iteratively), contradicting `h_not_cofinal`. So `succ^[n](a) < pred^[k](b)` strictly for all n.

Step 3: Cast the succ-orbit to R. Define `f_up : Nat -> R` by `f_up(n) = (succ^[n](a).val : R)`. This is:
- Monotone increasing (from `limitDomSubtype_succ_iter_mono`, line 1280)
- Bounded above by `(b.val : R)` (from `h_not_cofinal` + `Rat.cast_le`)
- Hence converges to some `L_up : R` by `Real.tendsto_of_bddAbove_monotone`

Step 4: Cast the pred-chain to R. Define `f_down : Nat -> R` by `f_down(k) = (pred^[k](b).val : R)`. This is:
- Antitone (from `limitDomSubtype_pred_lt` iterated, line 1100)
- Bounded below by `(a.val : R)` (from Step 2: `a <= succ^[0](a) < pred^[k](b)`)
- Hence converges to some `L_down : R` by `Real.tendsto_of_bddBelow_antitone`

Step 5: Show `L_up <= L_down`. From Step 2: `f_up(n) < f_down(k)` for all n, k. Taking limits: `L_up <= L_down`.

Step 6: Show `L_up = L_down = L`. Each pred-chain element `pred^[k](b)` is a domain point above all orbit elements. Since `pred^[k](b) > succ^[n](a)` for all n, and `succ(succ^[n](a)) = succ^[n+1](a)` is the immediate successor (no domain points between), `pred^[k](b) >= succ^[n+1](a)` for all n. Taking n -> infinity: `pred^[k](b).val >= L_up` for all k. Taking k -> infinity: `L_down >= L_up`. Combined with Step 5: `L_up = L_down`.

Step 7 (the construction-specific step): **Case split on whether L is in limit_dom.**

**Case L in limit_dom** (L is rational and in `limit_dom`): Let `z : LimitDomSubtype` have `z.val = L`. Then `pred(z) < z` (by `limitDomSubtype_pred_lt`). Since `succ^[n](a).val -> L = z.val` from below, for large enough n, `succ^[n](a).val > pred(z).val` (because `pred(z).val < z.val = L` and `f_up(n) -> L`). So `succ^[n](a)` is a domain point with `pred(z) < succ^[n](a) < z`. But `succ(pred(z)) = z` by `limitDomSubtype_succ_pred` (line 1029), so no domain points exist between `pred(z)` and `z`. This is a contradiction.

**Case L not in limit_dom**: This is the case the convergence argument alone cannot handle. The plan proposes two sub-approaches:

**(A.i) L is irrational**: If L is irrational, it cannot be the value of any `LimitDomSubtype` element (which are rational). This case may be handleable if we can show L must be rational. Since L = sup of a set of rationals (the orbit values), L is the supremum in R of a bounded set of rationals. The supremum need not be rational in general. However, we can observe: if L is irrational, then no domain point has value L, and we enter the gap-at-L scenario. We need a construction-specific argument to rule this out.

**(A.ii) L is rational but not in limit_dom**: Similarly enters the gap-at-L scenario.

**For both A.i and A.ii**, the construction-specific argument is: consider the `counterexample_enum` enumeration. The orbit `succ^[n](a)` and the pred-chain `pred^[k](b)` are both sequences of `limit_dom` points converging to L. Each `limit_dom` point enters at a finite omega-chain stage. The C5 elimination at each stage adds at most one point (`dom_new_unique`, line 1196). The question is whether the construction forces a point at L.

**Concrete construction argument**: Consider the succ-orbit element `succ^[n](a)` for large n. Its MCS contains `next_top = U(T, bot)` (from `h_discrete`). By C5, there must be a witness y > `succ^[n](a)` with `bot in guard(succ^[n](a), y)` -- i.e., y is the immediate successor. This y is `succ^[n+1](a)`. Now consider the pred-chain element `pred^[k](b)` for large k. Between `succ^[n](a)` and `pred^[k](b)`, there are domain points (all orbit elements `succ^[j](a)` for j > n, and all pred-chain elements `pred^[i](b)` for i > k). The C5 formula `U(T, bot)` at `succ^[n](a)` requires the witness `succ^[n+1](a)` to be the immediate successor -- but this is within the orbit, not crossing the gap. So C5 does not directly force a gap-closing point.

**Fallback if A.i/A.ii cannot be resolved**: Pivot to Approach B.

**Tasks for Approach A**:
- [ ] Implement Steps 1-6 as helper lemmas (monotone convergence, both sequences converge to same L)
- [ ] Implement the L-in-domain case (Step 7, Case L in limit_dom): this should close the sorry IF L is always in limit_dom
- [ ] Attempt to prove L is always in limit_dom (the construction-specific step)
- [ ] If L-in-domain cannot be proved within ~2 hours, pivot to Approach B

**Key Mathlib lemmas for Approach A**:
- `Real.tendsto_of_bddAbove_monotone` -- succ-orbit convergence
- `Real.tendsto_of_bddBelow_antitone` -- pred-chain convergence  
- `Rat.cast_le`, `Rat.cast_lt` -- transfer Q ordering to R
- `Rat.cast_mono` -- monotonicity of Q -> R cast
- `Filter.Tendsto.mono_left` -- filter manipulation
- `tendsto_order` -- decompose convergence into eventually-above/below
- `Filter.eventually_atTop` -- convert eventually to exists N forall n >= N

#### Approach B: Prove Set.Icc Finiteness from Construction Properties

If Approach A fails at the L-not-in-domain case, pivot to proving `Set.Finite (Set.Icc a b)` for all `a b : LimitDomSubtype`, then derive `IsSuccArchimedean` via the Mathlib pipeline.

**Mathematical argument**: The succ-orbit `n -> succ^[n](a)` is a strict injection from N into `Set.Icc a b` (by `limitDomSubtype_succ_iter_injective` + the bounds from `h_not_cofinal`). If `Set.Icc a b` is finite, this contradicts `Set.Finite.not_injective_of_infinite` (pigeonhole). So it suffices to prove `Set.Icc a b` is finite.

**Finiteness proof sketch**: Each `LimitDomSubtype` element is a rational in `limit_dom = Union_n dom(omega_chain_val n)`. Each `dom(omega_chain_val n)` is a `Finset Rat`. Each step adds at most one element (`dom_new_unique`). The question is whether only finitely many stages insert into the interval `[a.val, b.val]`.

The construction adds points via:
- C4 forward/backward: inserts midpoints between existing adjacent pairs
- C5 forward/backward: inserts witnesses above/below a reference point
  - When the formula is `U(T, bot)` (the `next_top` case), the witness is an immediate successor (no domain points between)
  - When the formula is other `U(xi, eta)`, the witness can be further away

In the discrete case (`h_discrete`), `next_top in limit_f(x)` for all domain x. The C5 elimination for `U(T, bot)` creates immediate successors. Other C5 eliminations for `U(xi, eta)` with `xi != T` or `eta != bot` may insert points further away, but they must still satisfy the bot-guard property in the limit (no domain points between x and its immediate successor).

**Key insight for finiteness**: At each stage, a new point is only added when a counterexample is not yet resolved. Once a counterexample `(x, xi, eta, kind)` is resolved (a witness exists in the current domain), subsequent processing of the same counterexample adds nothing (`c5_forward_resolved_no_new`, line 1212). The counterexample enumeration covers all `(x, xi, eta, kind)` tuples. For a fixed interval `[a.val, b.val]`, the counterexamples that can insert points into this interval involve domain points x in the interval. The number of formulas is bounded by the subformula closure (finite). But x ranges over all rationals, and there are infinitely many rationals in any interval.

**Problem**: The finiteness argument is hard because there are infinitely many counterexamples targeting any interval. Each time a new point is inserted, it creates new adjacent pairs, which may trigger new counterexamples for those pairs at later stages.

**Alternative finiteness path**: Use the contradiction approach more directly. Instead of proving Icc finiteness independently, combine it with the convergence argument:
1. The succ-orbit injects N into Icc a b
2. If Icc a b is infinite, Bolzano-Weierstrass gives an accumulation point L
3. Use the construction to show a domain point must exist at L
4. Then the L-in-domain case of Approach A gives the contradiction

**Tasks for Approach B**:
- [ ] Attempt to prove `Set.Finite (Set.Icc a b)` for `LimitDomSubtype` using construction properties
- [ ] If finiteness is proved, instantiate `LocallyFiniteOrder.ofFiniteIcc` and get `IsSuccArchimedean`
- [ ] If finiteness cannot be proved directly, try the combined convergence + Bolzano-Weierstrass approach

#### Approach C: Well-Founded Ordering (Fallback)

If both A and B fail, attempt to prove `WellFoundedGT` for `LimitDomSubtype`, which gives `IsSuccArchimedean` automatically via `WellFoundedGT.toIsSuccArchimedean`.

**Mathematical argument**: `WellFoundedGT` means no infinite strictly decreasing sequence. Suppose `f : N -> LimitDomSubtype` is strictly decreasing. Then `f(n).val` is a strictly decreasing sequence of rationals bounded below (say by the minimum domain point if it exists, or by any domain point). Cast to R and use monotone convergence to get a contradiction -- but this is essentially the same convergence argument, with the same gap.

This approach is unlikely to help if Approaches A and B fail, since it reduces to the same mathematical content. Include it only as a last resort.

**Tasks for Approach C**:
- [ ] Only attempt if A and B both fail
- [ ] Try `WellFoundedGT` via convergence (same core argument)
- [ ] If this also fails, document the gap and return status `partial`

#### Approach D: Bypass Surjectivity for TC (Partial Win)

If all proof approaches for `IsSuccArchimedean` fail within the time budget, there is a partial win available: Teammate D showed that TC (temporal coherence) can be proved WITHOUT surjectivity by using `limit_forward_G` directly on `succ_embed` points. This does not close the sorry, but it narrows the dependency: only FUC needs surjectivity.

This approach should NOT be implemented unless all of A, B, C fail. It does not close the sorry.

**Timing**: 2-4 hours total for Phase 2 (across all approaches)

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- replace `sorry` at line 1211 with proof body (~80-150 lines)
- Possibly `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean` -- if construction-specific helper lemmas are needed (new lemmas only, no modifications to existing code)

**Verification**:
- `lean_goal` at each step of the proof shows expected intermediate goals
- `lean_verify` on `limitDomSubtype_isSuccArchimedean` shows no sorry
- `lake build ChronicleToCountermodel` compiles
- `lean_verify` on `succ_embed_surjective` shows no sorry
- `lean_verify` on `dd_countermodel_chronicle_discrete` shows no sorry
- `grep sorry ChronicleToCountermodel.lean` shows only `dd_countermodel_chronicle_nondense_sorry` and `dd_countermodel_chronicle_mixed_sorry`

## Testing & Validation

- [ ] `lake build ChronicleToCountermodel` passes after Phase 2
- [ ] `lean_verify` on `limitDomSubtype_isSuccArchimedean` confirms no sorry
- [ ] `lean_verify` on `succ_embed_surjective` confirms no sorry
- [ ] `lean_verify` on `dd_countermodel_chronicle_discrete` confirms no sorry
- [ ] `lean_verify` on `cantor_bfmcs_discrete_restricted_tc` confirms no sorry
- [ ] `lean_verify` on `cantor_bfmcs_discrete_restricted_fuc` confirms no sorry
- [ ] Grep for sorry in `ChronicleToCountermodel.lean` shows only the nondense and mixed stubs
- [ ] Full `lake build` passes

## Artifacts & Outputs

- **Plan**: `specs/123_fix_c5_witness_bot_and_prove_icc_finite/plans/05_construction-specific.md` (this file)
- **Modified files**:
  - `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` (IsSuccArchimedean proof body, ~80-150 lines replacing sorry at line 1211)
  - Possibly `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean` (new helper lemmas only)
- **Summary**: `specs/123_fix_c5_witness_bot_and_prove_icc_finite/summaries/05_construction-specific-summary.md` (after implementation)

## Rollback/Contingency

All changes are in a single file (`ChronicleToCountermodel.lean`), with potential small additions to `ChronicleConstruction.lean`. The theorem statement of `limitDomSubtype_isSuccArchimedean` is unchanged -- only the proof body (currently `sorry`) is replaced. Reverting: restore the sorry at line 1211 and remove any new helper lemmas.

If all approaches fail:
1. **Document the gap**: Write a detailed comment at the sorry site explaining that the convergence argument has a known gap in the L-not-in-domain case, and that a construction-specific argument is needed.
2. **Keep the sorry**: The sorry is well-localized and does not affect the overall architecture. `succ_embed_surjective` is already sorry-free conditional on this instance.
3. **Partial progress**: If Approach A's L-in-domain case is proved as a helper lemma, keep it -- it reduces the sorry to "prove L is in limit_dom."
4. **Consider task splitting**: If the construction-specific argument requires significant new infrastructure in `ChronicleConstruction.lean`, create a subtask for that infrastructure.
