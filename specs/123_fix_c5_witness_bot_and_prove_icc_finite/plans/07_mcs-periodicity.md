# Implementation Plan: MCS Periodicity for Gap-at-L Elimination

- **Task**: 123 - fix_c5_witness_bot_and_prove_icc_finite
- **Status**: [NOT STARTED]
- **Effort**: 4-7 hours
- **Dependencies**: None (all prerequisite infrastructure exists sorry-free)
- **Research Inputs**:
  - specs/123_fix_c5_witness_bot_and_prove_icc_finite/reports/04_team-research.md
  - specs/123_fix_c5_witness_bot_and_prove_icc_finite/reports/05_team-research.md
  - specs/123_fix_c5_witness_bot_and_prove_icc_finite/reports/06_team-research.md
  - specs/123_fix_c5_witness_bot_and_prove_icc_finite/reports/07_verbrugge-deep-study.md
  - specs/123_fix_c5_witness_bot_and_prove_icc_finite/reports/07_doets-reynolds-deep-study.md
  - specs/123_fix_c5_witness_bot_and_prove_icc_finite/reports/07_codebase-fit-analysis.md
  - specs/123_fix_c5_witness_bot_and_prove_icc_finite/reports/07_mathematical-comparison.md
- **Artifacts**: plans/07_mcs-periodicity.md (this file)
- **Standards**:
  - .claude/context/formats/plan-format.md
  - .claude/rules/artifact-formats.md
  - .claude/rules/state-management.md
  - .claude/rules/lean4.md
- **Type**: lean4
- **Lean Intent**: true

### Research Integration

**Rounds 4-6** (prior plans v4-v6): Established convergence framework, proved three helper lemmas (h_below_L_is_orbit, h_pred_below_L_contradiction, h_pred_at_L_contradiction) that reduce the sorry to ruling out the gap-at-L scenario. Plans v5-v6 proposed Icc finiteness via construction stabilization as primary approach; the implementation agent instead refined the convergence approach and produced the three helper lemmas, which was valuable but did not close the sorry.

**Round 7** (4 research agents, newly integrated):
- `07_verbrugge-deep-study.md`: Verbrugge's adequate-set approach makes intervals finite by construction but requires a ground-up rebuild (~3000 lines). His key insight: finite formula space forces cyclic MCS repetition along tails.
- `07_doets-reynolds-deep-study.md`: Both Doets (modified Lob + EF games) and Reynolds (k-equivalence + expressive completeness) are prohibitively expensive (700-2500 lines of new infrastructure). Neither should be adopted wholesale.
- `07_codebase-fit-analysis.md`: No existing Icc finiteness infrastructure. The Mathlib pipeline LocallyFiniteOrder -> IsSuccArchimedean works IF Icc finiteness can be established. The sorry is a leaf -- fixing it makes 6 downstream theorems sorry-free.
- `07_mathematical-comparison.md`: All six methods exploit the same core fact -- finite subformula closure forces MCS periodicity. The hybrid approach (option e) extracts this single insight without importing any method's apparatus. Estimated 150-250 lines, low-medium risk.

**Convergence across all agents**: The shared mathematical insight is that the finite subformula closure bounds the number of distinguishable MCS labels. Along the succ-orbit, MCS labels must repeat (pigeonhole). This periodicity argument, applied within the existing construction, is the recommended approach. It does not require adequate sets, EF games, k-equivalence, or expressive completeness.

### Prior Plan Reference

Plan v6 (`06_icc-finiteness-stabilization.md`) had 3 phases:
- **Phase 1** [COMPLETED]: Mathlib imports + `order_succ_eq` / `order_pred_eq` (both `rfl`)
- **Phase 2** [PARTIAL]: IsSuccArchimedean proof -- sorry narrowed to gap-at-L case via three helper lemmas, but the gap-at-L argument itself remains unproved
- **Phase 3** [NOT STARTED]: Verification and cleanup

### Roadmap Alignment

This plan advances:
- "Discrete completeness: 1 sorry remains (task 122)" -- closing `limitDomSubtype_isSuccArchimedean` makes the discrete countermodel sorry-free
- "Full `bx_completeness`: Blocked by 1 sorry in discrete case" -- unblocking the discrete case moves toward sorry-free `bx_completeness`

## Overview

This plan replaces Phase 2 from plan v6 with a focused strategy for the single remaining sub-goal: ruling out the gap-at-L scenario. Two previous implementation rounds built a convergence framework (Steps 1-6) and three helper lemmas that together prove: if any domain point c above the succ-orbit has pred(c).val <= L, then False. The remaining sorry (line 1402 of `ChronicleToCountermodel.lean`) must show that the third case -- every domain point c above the orbit has pred(c).val > L -- is also impossible.

The strategy uses MCS periodicity along the succ-orbit: the finite subformula closure means at most 2^K distinct restricted MCS labels exist (where K = |SubformulaClosure(A)|). By pigeonhole, two orbit points share the same restricted label. In the discrete case, `U(T,bot)` is in every MCS, so the C5 forward counterexample for U(T,bot) at each orbit point inserts an immediate successor. The periodicity of MCS labels implies that the witness insertion pattern repeats with a fixed period p, and each period inserts at least one new domain point (the U(T,bot) witness). But in the gap-at-L scenario, all these inserted points must fit in the interval [a.val, L) in Q, with the orbit converging to L. A periodic pattern that inserts a fixed quantum of "rational distance" per period cannot converge -- it must eventually reach or exceed L, contradicting the gap.

**Key simplification over plan v6**: This plan does NOT attempt to prove `Set.Finite (Set.Icc a b)` for arbitrary a, b. It directly targets the gap-at-L contradiction for the specific sorry site. The Icc finiteness approach is available as a fallback but is not the primary strategy.

**Definition of done**: `limitDomSubtype_isSuccArchimedean` at line 1190 is sorry-free. `succ_embed_surjective` is sorry-free. `dd_countermodel_chronicle_discrete` is sorry-free. The only remaining sorry sites in `ChronicleToCountermodel.lean` are `dd_countermodel_chronicle_nondense_sorry` (line 839) and `dd_countermodel_chronicle_mixed_sorry` (line 2730).

## Goals & Non-Goals

**Goals:**
- Close the sorry at line 1402 (the gap-at-L case in `limitDomSubtype_isSuccArchimedean`)
- Use MCS periodicity as the primary argument
- Preserve all existing compiled code (convergence framework, three helper lemmas)
- Make `dd_countermodel_chronicle_discrete` sorry-free

**Non-Goals:**
- Proving `Set.Finite (Set.Icc a b)` for general a, b in LimitDomSubtype (not needed for this sorry)
- Modifying the omega-chain construction (`ChronicleConstruction.lean`) beyond adding new helper lemmas
- Solving the mixed or nondense cases
- Implementing adequate sets, EF games, k-equivalence, or expressive completeness
- Modifying Phase 1 from plan v5 (already [COMPLETED])
- Changing the existing three helper lemmas or convergence framework

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| MCS periodicity is hard to formalize for full (non-restricted) MCS | H | M | Restrict attention to MCS intersected with SubformulaClosure(A), which is a finite set; periodicity follows from pigeonhole on Finset |
| The "fixed quantum" argument for periodic witness insertion is imprecise | H | M | Two sub-approaches: (A) directly show periodic MCS forces periodic rational offsets, or (B) show periodicity means the orbit is eventually constant modulo some relabeling, contradicting strict monotonicity in the gap scenario |
| C4 counterexamples disrupt MCS periodicity | M | L | In discrete case, `neg(U(T,bot))` is never in any MCS, so C4 for (T,bot) never fires. C4 for other formulas may fire but they also draw from the finite subformula closure, so periodicity is preserved modulo a larger period |
| The proof restructuring breaks compiled code | M | L | The sorry at line 1402 is the ONLY change point; all existing helper lemmas and convergence framework are preserved as-is |
| Time budget exceeded | H | L | Fallback: if MCS periodicity fails within ~4 hours, attempt direct construction argument using `counterexample_enum_surjective_above` to produce a domain point in the gap |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |

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

### Phase 2: Prove Gap-at-L Contradiction via MCS Periodicity [NOT STARTED]

**Goal**: Replace the `sorry` at line 1402 with a valid proof that rules out the gap-at-L scenario. The existing helpers already handle pred(c).val < L and pred(c).val = L. Phase 2 handles the remaining case: all domain points c above the orbit satisfy pred(c).val > L.

**Context**: The sorry is inside `limitDomSubtype_isSuccArchimedean` (line 1190). The proof state at line 1402 has:
- `a b : LimitDomSubtype A h_mcs` with `a <= b`
- `h_not_cofinal : forall n, s^[n] a < b` (succ-orbit never reaches b)
- `s := limitDomSubtype_succ`, `p := limitDomSubtype_pred`
- `L := iSup f_up` where `f_up n = (s^[n] a).val` cast to R
- `h_orbit_lt_pred : forall n k, s^[n] a < p^[k] b`
- `h_below_L_is_orbit : forall w, a <= w -> w.val < L -> exists k, s^[k] a = w`
- `h_pred_below_L_contradiction : forall c, (forall n, s^[n] a < c) -> (p c).val < L -> False`
- `h_pred_at_L_contradiction : forall c, (forall n, s^[n] a < c) -> (p c).val = L -> False`

The sorry must derive `False`. The only remaining case (by trichotomy on `(p c).val` vs `L` for any c above the orbit) is `(p c).val > L` for all such c. The argument uses MCS periodicity.

#### Approach A (Primary): MCS Periodicity Contradiction

**Mathematical argument in detail:**

**(A.1) Restricted MCS labels are finite.** Define `label(w) = limit_f(w.val) intersect SubformulaClosure(A)` for each `w : LimitDomSubtype`. Since `SubformulaClosure(A)` is a `Finset Formula`, `label(w)` is a subset of a finite set, so there are at most `2^K` distinct labels (where `K = SubformulaClosure(A).card`).

**(A.2) Pigeonhole on the orbit.** The sequence `n -> label(s^[n] a)` is a function from N to a finite set. By pigeonhole, there exist `i < j` such that `label(s^[i] a) = label(s^[j] a)`.

**(A.3) Same label implies same U(T,bot) C5 structure.** Both `s^[i] a` and `s^[j] a` have `U(T,bot)` in their MCS (by `h_discrete`). The C5 forward counterexample for `U(T,bot)` at `s^[i] a` inserts a witness y_i with `s^[i] a < y_i` and `T` (= bot.imp bot) in `f(y_i)`. Similarly for `s^[j] a`. Since both have the same restricted MCS label, the Lindenbaum extension for the witness at `s^[i] a` and `s^[j] a` are "structurally similar" in their subformula content.

**(A.4) Key construction property: succ IS the U(T,bot) witness.** In the discrete case, `limitDomSubtype_succ` is defined as the immediate successor in the limit domain. This successor is the C5 witness for `U(T,bot)`. The value `s(w).val` is a rational number > `w.val`, and the distance `s(w).val - w.val` is a positive rational.

**(A.5) The gap scenario is impossible.** Assume the gap-at-L scenario: orbit values converge to L but no domain point sits at L or has pred value <= L. Consider the sequence of rational gaps `delta_n = (s^[n+1] a).val - (s^[n] a).val > 0`. In the gap scenario, `sum_{n=0}^{infinity} delta_n = L - a.val < infinity` (finite sum, since the orbit converges). But we need to show this is impossible given the construction.

**(A.5 -- approach variant 1: direct period bound)** If `label(s^[i] a) = label(s^[j] a)` with period `p = j - i`, consider the sub-orbit `s^[i], s^[i+1], ..., s^[j-1]` (length p). These p points have successor gaps summing to `(s^[j] a).val - (s^[i] a).val =: Delta > 0`. Now consider `s^[j], s^[j+1], ..., s^[2j-i-1]`. If the MCS labels repeat with period p (to be shown), the gaps also repeat, giving another Delta contribution. After N repetitions, the orbit advances by `N * Delta`, which eventually exceeds `L - a.val`. Contradiction with convergence.

The critical sub-lemma: once MCS labels match at positions i and j, do they repeat periodically? Not necessarily for the FULL MCS, but for the RESTRICTED MCS (intersected with the finite SubformulaClosure). The construction processes counterexamples for ALL formulas, so restricted periodicity may not imply full periodicity. However, the restricted MCS determines which C5 counterexamples fire for subformulas of A, and in the gap-at-L scenario, the only relevant C5 is U(T,bot) (which is always present and always fires, producing the successor).

**(A.5 -- approach variant 2: uniform lower bound on gaps)** Alternatively, show that in the gap-at-L scenario, succ gaps cannot converge to zero. Each orbit point w has `U(T,bot) in limit_f(w.val)`. The C5 witness for U(T,bot) at w is placed at a rational y > w.val, where y is the midpoint between w and the next existing domain point (by the PointInsertion procedure). In the gap-at-L scenario, there are no domain points in `[L, infinity) intersect limit_dom` that are "close" to L (since all above-orbit points have pred value > L, meaning they are bounded away from L). So the "next existing domain point" above each orbit point is at least at distance > L - w.val from w. The midpoint placement gives y at distance >= (L - w.val)/2 from w. But succ(w) need not be this midpoint -- it could be an earlier domain point. This reasoning is fragile and depends on the exact insertion mechanism.

**(A.5 -- approach variant 3: b is reachable by construction)** The cleanest variant may be: use `counterexample_enum_surjective_above` to find, for each orbit point `s^[n] a`, a stage N_n at which the counterexample `(s^[n] a.val, 0, bot, T, c5_forward)` is processed. At that stage, a witness y_n is inserted with `s^[n] a.val < y_n` and `y_n in limit_dom`. This y_n becomes `s^[n+1] a` (the succ). Now consider the counterexample `(s^[n] a.val, b.val, bot, T, c5_forward)` -- actually, counterexamples are parameterized by (x, y, xi, eta, kind) where y is not used for C5. The witness for U(T,bot) at `s^[n] a` is placed above `s^[n] a`. In the gap-at-L scenario, the immediate successor `s^[n+1] a` has value < L. But the enumeration is surjective: for every rational q in (a.val, L), the counterexample (q, ...) is eventually processed. When q is in the gap (L, (p b).val), the enumeration also processes counterexamples at rational coordinates in the gap -- but these are not in `limit_dom`, so they are vacuous.

The key realization: the counterexample `(s^[n] a.val, 0, bot, top_formula, c5_forward)` at stage N produces a witness y > s^[n] a.val in `dom(N+1)`. If y >= (p b).val for some pred-iterate, then we have a domain point with value < (p b).val... no, y >= (p b).val means y is above the pred-chain, giving a domain point near L. This needs careful case analysis.

**Implementation strategy**: The implementation agent should attempt the variants in order: variant 1 (period bound) first, variant 3 (direct construction argument) second, variant 2 (gap lower bound) last.

**CRITICAL CONSTRAINT**: The implementation agent MUST NOT restructure the existing proof body. The sorry at line 1402 is the ONLY change point. All code above line 1402 (the convergence framework, Steps 1-4, the three helper lemmas) must be preserved exactly as-is. The agent adds new code ONLY at line 1402, replacing `sorry` with a proof term or tactic block.

**Specific lemmas to prove** (all new, added either inline at the sorry site or as separate `have` statements before it):

1. `h_gap_scenario`: Assume `forall c : LimitDomSubtype, (forall n, s^[n] a < c) -> ((p c).val : R) > L`. Derive False.

2. Within the proof of `h_gap_scenario`:
   - `h_label_periodic`: Define `label n := limit_f A h_mcs (s^[n] a).val intersect SubformulaClosure A` (as a Finset via `Finset.filter`). Prove `exists i j, i < j and label i = label j` by pigeonhole (`Finset.exists_ne_map_eq_of_card_lt`).
   - `h_gap_delta`: Define `delta n := (s^[n+1] a).val - (s^[n] a).val`. Show `delta n > 0` for all n (from strict monotonicity).
   - `h_periodic_sum`: Show that `sum_{k=0}^{p-1} delta(i+k) = (s^[j] a).val - (s^[i] a).val =: Delta > 0`.
   - `h_orbit_unbounded_or_reaches_L`: Show that either the orbit is unbounded (contradicting `BddAbove`) or it reaches a domain point at L (contradicting the gap assumption). The key step: the label periodicity forces the gap deltas to NOT converge to zero (because the same MCS labels produce structurally similar witness placements), so the orbit cannot converge to a finite limit while maintaining the gap.

3. Alternatively (if periodicity of gaps is too hard to formalize): use `counterexample_enum_surjective` to show that for b itself (which is a domain point), the C5 counterexample at each orbit point eventually pushes the orbit past b. Since `h_not_cofinal` says this never happens, derive a contradiction from the structural properties of the construction.

**Key existing lemmas to use**:
- `limit_satisfies_c5_weak` (ChronicleConstruction.lean:636): C5 holds in the limit -- every U(eta,xi) in limit_f(x) has a witness y > x
- `counterexample_enum_surjective` (ChronicleConstruction.lean:209): every counterexample tuple is processed
- `counterexample_enum_surjective_above` (ChronicleConstruction.lean:223): processed above any threshold
- `omega_chain_c5_witness` (ChronicleConstruction.lean:391): detailed witness structure at step n+1
- `omega_chain_dom_new_unique` (ChronicleConstruction.lean:1196): at most one new point per stage
- `omega_chain_c5_forward_resolved_no_new` (ChronicleConstruction.lean:1212): resolved C5 does not re-fire
- `h_below_L_is_orbit` (proved in current code): any domain point below L is an orbit element
- `h_pred_below_L_contradiction` (proved in current code): above-orbit point with pred < L gives False
- `h_pred_at_L_contradiction` (proved in current code): above-orbit point with pred = L gives False
- `SubformulaClosure` (SubformulaClosure.lean:61): finite subformula closure as Finset
- `limitDomSubtype_succ_iter_strictMono` (ChronicleToCountermodel.lean): strict monotonicity of orbit

**Key Mathlib lemmas to use**:
- `Finset.exists_ne_map_eq_of_card_lt` or `Fintype.exists_ne_map_eq_of_card_lt`: pigeonhole
- `Finset.Finite.toFinset` / `Set.Finite.toFinset`: convert finite set intersections
- `Rat.cast_lt`, `Rat.cast_le`: cast ordering between Q and R

#### Approach B (Fallback): Direct Domain-Point Production

If MCS periodicity cannot be formalized within ~4 hours, pivot to a direct construction argument.

**Mathematical argument**: The counterexample enumeration is surjective. For each orbit point `s^[n] a`, U(T,bot) is in its MCS. The C5 forward witness for U(T,bot) at `s^[n] a` places a new domain point y_n > `s^[n] a`. In the limit, `s^[n+1] a` is the least domain point above `s^[n] a`. Now consider: what prevents some stage from inserting a domain point at a rational >= L?

In the gap-at-L scenario, no domain point has value in `[L, pred(b).val]` (where pred(b).val > L by the gap assumption). The enumeration processes the counterexample `(q, 0, bot, T, c5_forward)` for every rational q. When q is an orbit point, the witness is placed above q but below the next existing domain point. In the gap scenario, the "next existing domain point" above all orbit points is the smallest above-orbit point c_min with c_min.val > L. The witness for U(T,bot) at s^[n] a is placed at a rational in `(s^[n] a.val, c_min.val)`. If this rational is >= L, we have a domain point in the gap, contradicting the gap assumption.

The key question: can the construction always choose a witness rational < L? The PointInsertion procedure picks a rational between the reference point and the next domain point. If the reference point has value close to (but below) L and the next domain point has value c_min.val > L, the midpoint is approximately (s^[n] a.val + c_min.val) / 2. As n grows and s^[n] a.val approaches L, the midpoint approaches (L + c_min.val) / 2 > L. So eventually the witness is placed at or above L.

But this argument assumes the midpoint is the chosen rational. The actual placement depends on `PointInsertion`, which may use any rational between the two endpoints. If it uses a fresh rational (as it does), and the interval (s^[n] a.val, c_min.val) always includes L, then the fresh rational may be either below or above L. The deterministic choice (via Cantor pairing or similar) need not place a rational at L.

**This approach is riskier** because it depends on the exact rational placement mechanism in PointInsertion. Use only if Approach A fails.

**Tasks for Approach B**:
- [ ] Analyze PointInsertion.lean to determine how witness rationals are chosen
- [ ] Prove that eventually a witness rational >= L is chosen, or find a different argument
- [ ] If the placement is via midpoint: prove midpoint >= L for sufficiently large n

#### Decision Criteria

- If Approach A (MCS periodicity) closes the sorry within ~4 hours, done.
- If Approach A stalls at formalizing the "periodic gaps cannot converge" step, try the variant 3 (direct construction argument using surjectivity).
- If both variants of A fail, pivot to Approach B (PointInsertion analysis).
- If all approaches fail within time budget, leave sorry with detailed comment, return `partial`.

**Tasks for Phase 2**:
- [ ] Read the exact proof state at line 1402 using `lean_goal`
- [ ] Implement the gap-at-L case analysis: `have h_gap : forall c, ... -> (p c).val > L -> False`
- [ ] Define restricted MCS labels and prove pigeonhole
- [ ] Derive the periodic sum bound and contradiction
- [ ] If periodicity approach fails: attempt direct construction argument
- [ ] If direct approach fails: attempt PointInsertion analysis
- [ ] Verify: `lean_goal` at each proof step, `lean_verify` on `limitDomSubtype_isSuccArchimedean`

**Timing**: 3-5 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- replace `sorry` at line 1402 with proof (~50-200 lines)
- Possibly `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean` -- new helper lemmas only (no modifications to existing code)

---

### Phase 3: Verification and Cleanup [NOT STARTED]

**Goal**: Verify the proof compiles, confirm sorry elimination downstream, and clean up any temporary scaffolding.

**Tasks**:
- [ ] `lake build ChronicleToCountermodel` passes
- [ ] `lean_verify` on `limitDomSubtype_isSuccArchimedean` confirms no sorry
- [ ] `lean_verify` on `succ_embed_surjective` confirms no sorry
- [ ] `lean_verify` on `dd_countermodel_chronicle_discrete` confirms no sorry
- [ ] `lean_verify` on `cantor_bfmcs_discrete_restricted_tc` confirms no sorry
- [ ] `lean_verify` on `cantor_bfmcs_discrete_restricted_fuc` confirms no sorry
- [ ] Grep for sorry in `ChronicleToCountermodel.lean` confirms only nondense and mixed stubs remain
- [ ] Full `lake build` passes
- [ ] Remove any temporary `#check` or `#eval` scaffolding

**Timing**: 0.5-1 hour

**Depends on**: 2

## Testing & Validation

- [ ] `lake build ChronicleToCountermodel` passes after Phase 2
- [ ] `lean_verify` on `limitDomSubtype_isSuccArchimedean` confirms no sorry
- [ ] `lean_verify` on `succ_embed_surjective` confirms no sorry
- [ ] `lean_verify` on `dd_countermodel_chronicle_discrete` confirms no sorry
- [ ] `lean_verify` on `cantor_bfmcs_discrete_restricted_tc` confirms no sorry
- [ ] `lean_verify` on `cantor_bfmcs_discrete_restricted_fuc` confirms no sorry
- [ ] Grep for sorry in `ChronicleToCountermodel.lean` shows only `dd_countermodel_chronicle_nondense_sorry` and `dd_countermodel_chronicle_mixed_sorry`
- [ ] Full `lake build` passes

## Artifacts & Outputs

- **Plan**: `specs/123_fix_c5_witness_bot_and_prove_icc_finite/plans/07_mcs-periodicity.md` (this file)
- **Modified files**:
  - `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` (gap-at-L proof body, ~50-200 lines replacing sorry at line 1402)
  - Possibly `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean` (new helper lemmas only)
- **Summary**: `specs/123_fix_c5_witness_bot_and_prove_icc_finite/summaries/07_mcs-periodicity-summary.md` (after implementation)

## Rollback/Contingency

All changes are localized to a single sorry site (line 1402 of `ChronicleToCountermodel.lean`), with potential new helper lemmas in `ChronicleConstruction.lean`. The theorem statement of `limitDomSubtype_isSuccArchimedean` is unchanged -- only the sorry is replaced. Reverting: restore `sorry` at line 1402 and remove any new helper lemmas.

If all approaches fail:
1. **Document the gap**: Write a detailed comment at the sorry site explaining the MCS periodicity argument, the three approaches attempted, and why formalization stalled.
2. **Keep the sorry**: Well-localized, does not affect overall architecture.
3. **Preserve helper lemmas**: The three proved helpers (h_below_L_is_orbit, h_pred_below_L_contradiction, h_pred_at_L_contradiction) reduce the gap to a single case and should be kept.
4. **Consider architectural change**: If the gap-at-L argument proves fundamentally difficult within the current construction, a future task could explore Verbrugge-style adequate sets as a separate completeness proof for Z (a standalone formalization project, not a patch to the current pipeline).
