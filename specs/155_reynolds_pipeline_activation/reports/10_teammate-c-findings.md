# Teammate C Findings: Critic Report — Task 155 Reynolds Pipeline Activation

**Date**: 2026-05-20
**Role**: Critic (identify gaps, correctness issues, blind spots)
**Files examined**: EFGames.lean, ExpressivenessGeneral.lean, Transfer.lean, IntegerModel.lean,
ChronicleToCountermodel.lean, Completeness.lean, all handoff files, plan v6.

---

## Key Findings

### 1. The "13 sorries" claim is understated — the actual count is higher

The plan (Phase 4C status section) claims "13 total across 2 files" (EFGames.lean + ExpressivenessGeneral.lean). This is accurate for those two files only, but the full critical-path sorry count is:

| File | Sorry count | On critical path? |
|------|-------------|-------------------|
| EFGames.lean | 4 | Yes (all) |
| ExpressivenessGeneral.lean | 9 | Yes (all) |
| Transfer.lean | 1 | Yes — h_truth_corr at line 574, BLOCKED |
| IntegerModel.lean | 3 | Yes — no_gaps_discrete (wait for Phase 6), cofinal_decomposition_k_equiv, ordered_sum_of_good_bounded_is_good |
| TruthLemma.lean | 6 | No (documented non-critical-path) |
| OrderedSum.lean | 1 | Possibly (doets_lemma_1_5) — needs verification |

**Total critical-path sorries: 17** (not 13). The plan only counts the active Phase 4C sites.

### 2. The Phase 10 handoff is misleading — the sorry was REVERTED, not closed

The Phase 10 handoff (`phase-10-handoff-20260520.md`) states:
> "Task 10.3 [x]: Replace the sorry at Transfer.lean:574 with the proved h_truth_corr. deviation: replaced countermodel_discrete proof body with dd_countermodel_chronicle_discrete..."

**This is factually wrong.** The git history shows:
- `f446497a` (12:37): Phase 10 replaced countermodel_discrete
- `4ac2184e` (12:52, 15 minutes later): **REVERTED** with message "revert Phase 10 (invalid approach), mark BLOCKED"

The sorry at Transfer.lean:574 is **still present**. The plan correctly marks Phase 10 as [BLOCKED], but the task checkboxes [x] for Tasks 10.3-10.5 and the statement "Transfer.lean has zero source-level sorries" are wrong. Transfer.lean has exactly 1 source-level sorry.

### 3. Cases I and II are genuinely sorry-free — claim is correct

Verified by scanning lines 573–1565 (Case I) and 1566–2328 (Case II) of ExpressivenessGeneral.lean:
both blocks contain zero `sorry` invocations. The claim is accurate.

### 4. Structural correctness issue: d-consistency has no proof path

The two d-consistency sorries (ExpressivenessGeneral.lean:297 and :307) state:
```
a'_full ⟨1 + 3 * n, by omega⟩ = d := by sorry
a'_full ⟨0, by omega⟩ = d := by sorry
```

These assert that for ANY play of the forward strategy where Spoiler puts `c` at the designated boundary position, the strategy MUST respond with exactly `d`. This is mathematically false in general — strategies are non-deterministic (existential), not functional. The GHR93 paper defines `d` as an **infimum over all strategy responses**, which guarantees this consistency. The Lean formalization sets `d = a_bwd(n)` (Spoiler's last backward selection) and tries to extract consistency from the forward game, but the forward strategy's response to `c` need not equal `d` — it is only guaranteed to have the **same type** as `d`.

**This may be unprovable as stated.** The correct fix requires either:
- (a) Building infimum infrastructure for ExtendedCarrier (which lacks ConditionallyCompleteLattice), or
- (b) Restructuring the argument so `d` IS the forward strategy's response to `c` (definitionally), or
- (c) Weakening the strategy restriction hypothesis to not require exact equality.

The handoff `phase-4C2-sorry-closing-20260520.md` explicitly documents this: "The GHR93 paper handles this by defining d as an infimum, which guarantees d <= a'_full(n) for all plays. Our formalization lacks ConditionallyCompleteLattice on ExtendedCarrier." The sorry was "closed" by adding `h_d_consistent` as a hypothesis — but this just moves the proof obligation upward to the caller (`obtain_split_point_props`), which now has the sorry.

### 5. Sub-interval point witness sorries: gap case is not trivially provable

Four sorries (ExpressivenessGeneral.lean:336, :345, :351, :356) state that sub-intervals [x',d] and [d,y'] contain actual points, in the case where `d` is a gap. The comment says "gap has nonempty cut, giving a point ≤ d, but bounding below by x' requires density within [x',d]." This is a genuine topological density argument about the structure of M_r with gaps. It requires a lemma showing that every open interval in M_r (with gap endpoints) contains at least one actual point from M. This is not trivially true — it depends on the definition of r-definable gaps as Dedekind cuts with nonempty complement above. Budget at least 60-100 lines.

### 6. Rank-varying Theorem 6 sorry is structural — not trivial to close

The sorry at ExpressivenessGeneral.lean:2571 (`ghr93_forward_to_backward_rank_varying`) is described as "30-50 lines, Easy" in report 13. But this requires transporting a backward strategy on ExtendedCarrier at rank r+4n back to rank r. The `rank_embed` function embeds r→r+4n but the backward direction (r+4n→r) requires checking that the r+4n backward strategy's responses at r+4n positions can be "contracted" to r positions. This is not trivial: a gap in M_{r+4n} might not be a gap in M_r (a gap is r-definable, and r-definability is monotone: fewer gaps at lower rank). The contraction argument needs to show that the n-element backward strategy at rank r+4n can be projected back to rank r without loss. This may require 80-150 lines and a new auxiliary lemma.

### 7. Propositions 6 and 7 are entirely unimplemented — not even stubs

The plan shows Tasks 4C.8 and 4C.9 as [TODO] with no implementation. In the current code, `stavi_expressive_completeness` has a single `sorry` with no structure. Propositions 6 and 7 together form the assembly bridge from Theorem 6 to Corollary 5, estimated at 250-400 lines. There is no stub, no type signature, no partial structure. These are entirely from-scratch proofs.

The dependency chain is:
```
stavi_expressive_completeness (sorry'd)
  <- Corollary 5 logic (~100 lines)
     <- Proposition 7 (~200 lines) — needs Theorem 6 + Lemma 11
        <- Proposition 6 (~150 lines) — needs X_t type formulas + decomposition formulas
           <- ghr93_game_iff_decomposition (Lemma 11 bwd sorry'd)
```

None of this is started. Even if every existing sorry were closed today, Propositions 6 and 7 would require a separate work session.

### 8. Lemma 9 has a deep mathematical issue: flatten_stavi in mu-relativized setting

Report 13 flags this (Section 3.3, Section 6) but it deserves stronger emphasis. The left_formula/right_formula definitions use `flatten_stavi` to encode S/S' cases:
```
left(S(A,B), D) = .base (.untl (flatten_stavi compound) (flatten_stavi D))
```

The `flatten_stavi_correct` theorem assumes **discrete orders** and uses non-relativized `stavi_temporal_truth`. Lemma 9 must be proved for `stavi_temporal_truth_mu` (mu-relativized) on M_r (which has gaps, hence is NOT discrete). The "mu-elimination at actual points" bridge lemma mentioned in the report (Section 6) is a prerequisite for the hard S/S' cases of Lemma 9 and is not implemented. This could add 50-100 lines of prerequisite work.

### 9. Dependency chain to bx_completeness has a blocked phase

The plan's Phase 10 (h_truth_corr discharge) is [BLOCKED] with a documented architectural issue: `zIntervalTaskFrame` has `WorldState = Unit`, making position-dependent atom truth impossible. The git history confirms this analysis is correct — the approach was tried and reverted.

**Phase 10 cannot be unblocked by any work done in Phases 4C–9.** It requires a fundamental architectural change: either
- Replacing zIntervalTaskFrame with a frame having position-dependent world state, or
- Bypassing z_interval_countermodel entirely (similar to what the reverted Phase 10 tried, but with the Reynolds pipeline providing the k-equivalence, not by delegating to dd_countermodel_chronicle_discrete which is not sorry-free).

Phase 9's plan to "remove orderIsoIntOfLinearSuccPredArch from countermodel_discrete" addresses a **separate** concern (the succ_archimedean issue), not the h_truth_corr sorry. Both issues must be resolved for countermodel_discrete to be sorry-free.

### 10. The plan's sorry count in Phase 4C status section is stale

The plan's Phase 4C section says "Sorry inventory (13 total across 2 files, verified grep count)." This was accurate at the time of the last plan update but is now stale:
- ghr93_game_implies_decomposition (EFGames.lean:2423) was **proved** (not sorry'd): this sorry was closed
- The current actual count verified by grep is 4 (EFGames) + 9 (ExpressivenessGeneral) = 13

Wait — these still sum to 13. Let me clarify: the plan lists "ghr93_game_implies_decomposition (Lemma 11 bwd)" as a sorry, but the actual file shows Lemma 11 FORWARD (`ghr93_game_implies_decomposition`) is proved, and only the BACKWARD (`ghr93_decomposition_implies_game`, line 2423) is sorry'd. The plan mislabels which direction is sorry'd. The count is right but the description is wrong.

---

## Recommended Approach

### Immediate priorities (unblocked)

1. **Sub-interval point witnesses** (ExpressivenessGeneral.lean:336, :345, :351, :356): Prove density of M-points in intervals bounded by gaps. This is self-contained and unblocks further work on obtain_split_point_props. Budget 80-100 lines.

2. **Lemma 9 easy cases first** (EFGames.lean:1423-1442): Prove left/right formula gap detection for the `base .atom`, `base .bot`, `base .box`, `.neg`, `.conj` cases. These are 40-60 lines of routine inductive cases and establish the structural framework for the hard cases.

3. **"Mu-elimination at actual points" lemma**: As a prerequisite for Lemma 9's S/S' cases, prove that `stavi_temporal_truth_mu M atomMap r (extendPoint m) A ↔ stavi_temporal_truth M atomMap m A` for all actual points m (where mu-relativization collapses to standard truth because all mu-points near m in M_r correspond to actual M-points). This is ~60-80 lines.

### Structural concerns requiring user attention

4. **d-consistency**: The sorry at lines 297/307 may require restructuring `obtain_split_point_props`. The mathematically sound approach is to define `c` as the forward strategy's response to a play that includes `d` as the boundary, making d-consistency definitional. This requires refactoring obtain_split_point_props to work with specific game plays rather than arbitrary strategy responses.

5. **Phase 10 (h_truth_corr)**: This is [BLOCKED] with no clear path. The plan should document a concrete resolution path before this phase is attempted again. Options: (a) define a new TaskFrame with position-dependent world state and prove z_interval_countermodel for it, or (b) completely restructure countermodel_discrete to not use z_interval_countermodel at all (using the Reynolds pipeline's k-equivalence to directly produce the countermodel type).

### Realistic timeline assessment

Based on the pattern from Cases I and II:
- Case I: ~623 lines, took multiple sessions
- Case II: ~760 lines, took multiple sessions
- Cases III-IV depend on Lemma 9 (200-350 lines) plus Case III (~350 lines) and Case IV (~350 lines)

Remaining work in Phase 4C alone: approximately 1300-1800 lines across Lemmas 9, Cases III-IV, Lemma 11 backward, Propositions 6-7, Corollary 5 assembly, and d-consistency restructuring. At the observed rate of ~600-800 lines per session, this is **4-6 additional sessions** for Phase 4C alone.

Phases 5', 6, 7, 8, 9 then add another 3-5 sessions (estimate from plan). Phase 10 is BLOCKED and the timeline is undefined.

**Total remaining effort for sorry-free bx_completeness: 40-60 hours minimum**, assuming no new blockers emerge. The plan's "55 hours total" estimate was for the entire task from start, not remaining work.

---

## Evidence and Examples

### Evidence: Phase 10 revert
```
commit 4ac2184e (2026-05-20 12:52:43)
"task 155: revert Phase 10 (invalid approach), mark BLOCKED
Phase 10 replaced countermodel_discrete with dd_countermodel_chronicle_discrete,
bypassing the Reynolds pipeline instead of fixing it. The delegation still carries
sorryAx and contradicts the task goal. Reverted Transfer.lean..."
```

### Evidence: Transfer.lean:574 still sorry'd
```lean
-- Transfer.lean:570-574
have h_truth_corr : ∀ (ψ : Formula) (t : Z_wit.intervalCarrier),
    truth_at TM_wit zIntervalOmega zIntervalHistory
      ((unboundedZIntervalEquiv Z_wit h_lo h_hi) t) ψ ↔
      temporal_truth (Z_wit.toOrdered sig) atomMap_fwd t ψ := by
  sorry  -- STILL PRESENT
```

### Evidence: d-consistency structural issue
```lean
-- obtain_split_point_props:297 — asserts the forward strategy MUST respond to c with exactly d
have h_d_consistent_left : ∀ (a_pad ...), a_pad ⟨1+3*n,...⟩ = c →
    ∀ (a'_full ...), (winning condition) → a'_full ⟨1+3*n,...⟩ = d := by sorry
```
This requires determinism of a nondeterministic (∃) strategy — provable only if d is defined as the infimum of all responses (as GHR93 does), which is not how d is defined in the Lean formalization.

### Evidence: Propositions 6 and 7 are zero lines implemented
The only sorry-containing stub for `stavi_expressive_completeness` (EFGames.lean:2488-2495) is:
```lean
noncomputable def stavi_expressive_completeness ... := by
  sorry
```
There is no Proposition 6 or Proposition 7 defined anywhere in the codebase.

---

## Confidence Level

**High confidence** on:
- The sorry count (verified by grep on live files)
- The Phase 10 revert (verified by git log)
- Cases I and II being sorry-free (verified by line-range scan)
- d-consistency structural issue (documented in handoffs, mathematically verified)
- Propositions 6 and 7 being entirely unimplemented (verified by search)

**Medium confidence** on:
- The rank-varying sorry requiring 80-150 lines (may be 50 lines if rank_embed is well-behaved)
- The "mu-elimination at actual points" lemma being 60-80 lines (may be shorter if definitions align well)
- The Phase 10 architectural issue being truly unresolvable without major refactoring (the reverted approach had the right idea but wrong implementation)

**Lower confidence** on:
- The realistic timeline estimate (40-60 hours) — could be shorter with expert guidance on the gap/infimum issues
- Whether d-consistency can be fixed by a local refactoring vs. a full restructuring of obtain_split_point_props

---

## Summary for User Attention

1. **The plan's sorry count is accurate (13) for EFGames + ExpressivenessGeneral, but the total critical-path count is 17.** Phase 10's blocked sorry (Transfer.lean:574) is a separate blocker not captured in the Phase 4C count.

2. **Phase 10 is genuinely blocked with no clear resolution path.** Even if Phases 4C–9 are completed, Phase 10 requires architectural work that has not been designed.

3. **The d-consistency sorries may require restructuring obtain_split_point_props**, not just filling in the proof. The current structure may be mathematically incorrect as stated.

4. **Propositions 6 and 7 are entirely unimplemented** (zero lines) — they are not "partially complete" or "in progress." They are [TODO] from scratch.

5. **The handoff for Phase 10 contains incorrect information** (marking tasks [x] that were subsequently reverted). Future agents reading the handoffs should check the git history to verify handoff claims.
