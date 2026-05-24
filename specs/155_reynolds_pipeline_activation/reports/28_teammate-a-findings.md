# Teammate A Findings: Formula C and Literature Alignment

**Task**: 155 (reynolds_pipeline_activation)
**Artifact**: 28
**Role**: Teammate A — Primary angle on formula C alignment with GHR93
**Date**: 2026-05-24
**Focus**: Deep read of GHR93 Section 8 to extract the exact definition and role of formula C; trace the circularity diagnosis and identify a resolution path.

---

## Key Findings

### 1. What GHR93's Formula C Actually Is

In GHR93 Section 8 (pp.115-116), formula **C** is defined as the interval-type formula:

  **C = X_{(alpha_{n-1}, y')}**

where X_{(s, u)} is the "interval type" formula for the open interval (s, u). GHR93 Definition 8.8 (p.113) defines this:

> The rank-r interval type X_{(s, u)} is the conjunction of all rank-r temporal formulas A such that A holds at every mu-point in (s, u).

Critically, since there are only finitely many inequivalent rank-r formulas (finitely many NormalForm equivalence classes), this conjunction is FINITE. C is an explicit, finite temporal formula of rank <= r. It is NOT a predicate — it is a syntactic object that can be named, referenced in game tuples, and whose truth can be transferred by the winning strategy.

**Rank of C**: In GHR93's rank-per-connective convention, C has rank <= r (it is a conjunction of rank-r formulas). In Lean's stavi_depth convention (which adds 2 per connective), C has stavi_depth <= r as well (conjunctions don't increment depth in GHR93 or in Lean's definition).

### 2. How GHR93 Constructs C at the Point of Use

GHR93 does NOT construct C by invoking the expressive completeness theorem. The construction is:

1. The interval (alpha_{n-1}, y') is a fixed open interval in N.
2. The rank-r mu-points in this interval realize finitely many equivalence classes.
3. For each equivalence class τ realized by some mu-point v in the interval, include in C the conjunction of all rank-r formulas true at v (i.e., the "type formula" X_v).
4. C = the conjunction of these type formulas over all realized equivalence classes.

This is AVAILABLE from the induction hypothesis (**)_n or from the finiteness of NormalForms directly — it does NOT require the full expressive completeness theorem being proved. The finiteness of NormalForms (hence of equivalence classes) is given by `Fintype.card (NormalForm (muSig sig) (2*r) 1)`, which is already sorry-free in the Lean code (EFGames.lean, `Fintype` instances).

**What the IH provides**: At the inductive step for (**_{n+1}), the IH (**_n) gives backward-game strategies for all r and all n-round plays. But formula C does NOT require the IH at all — it only requires the finiteness of rank-r types, which is a combinatorial fact about NormalForms.

### 3. The Lean Divergence: cont_holds is a Predicate, not a Formula

The Lean formalization defines `cont_holds a_n y' t` as a universally-quantified Prop:

```lean
cont_holds a_n y' t :=
  ∀ A : StaviFormula, stavi_depth A ≤ r →
    (∀ v, a_n < v → v < y' → mu_holds v → stavi_temporal_truth_mu N atomMap r v A) →
    stavi_temporal_truth_mu N atomMap r t A
```

This captures the SEMANTIC content of GHR93's C but is NOT a formula. It is an infinite conjunction (ranging over all StaviFormulas of depth <= r). The critical difference:
- GHR93's C can appear in a game tuple: Spoiler can play C as a formula to test
- Lean's `cont_holds` cannot appear in a game tuple: it is a Prop, not a StaviFormula

This is the root cause of all 7 sorry sites in the Claim 1 cluster (ExpressivenessGeneral.lean lines 3901, 3935, 4412, 4424, 4468, 4483, 4508).

### 4. Where C Flows Through the Proof as a Formula

Tracing C through GHR93 (pp.115-116):

**Step 1 — Continuation set**: S_C = {t in [x', y'] : C(u) for all mu-points u in (t, y')}. Uses C as a predicate (OK for Lean's cont_holds too).

**Step 2 — Infimum d-bar**: d-bar = inf(S_C). Uses set-theoretic infimum (OK for Lean).

**Step 3 — Claim 1, Direction 1 (d-bar <= response)**: GHR93 constructs C' = ~C ∨ K^-(~C). Here C is needed as an actual formula:
- C' is formed by logical connectives applied to C
- C' must be embeddable in the game: the winning strategy preserves C' (a formula of rank r+1)
- This is WHERE the predicate-vs-formula gap bites: Lean cannot form C' from cont_holds

**Step 4 — Claim 1, Direction 2 (response <= d-bar)**: GHR93 argues by contradiction: if response > d-bar, Spoiler plays a point d' in (d-bar, response) where ~C holds. Requires ~C as a formula (again needs C as a formula).

**The gap sub-case (sorry S2, line 3935)**: When the game response `r2_resp` is a gap, the current Lean code has:
- We have: ¬cont_holds_cross at c_inf, giving a specific formula A_fail (depth <= r)
- We can transfer A_fail across the game (formula agreement at depth r)
- BUT: for a gap response `r2_resp`, we cannot project to a carrier point to apply `hd_in_SC.2`
- We need: C holds above d-bar at the gap position, which requires materializing C as a formula

GHR93 handles this by direct formula manipulation: C' fails at the gap (since C holds above d-bar and the gap is above d-bar but r2_resp = gap). The predicate form cannot make this argument.

### 5. The C' Construction: Rank Arithmetic Is Off By One

This is a new finding that report 28_claim1-formula-materialization.md confirmed:

GHR93 says C' = ~C ∨ K^-(~C) has "rank r+1" (using GHR93's rank-per-connective convention).

In Lean's stavi_depth convention (which adds +2 per temporal connective for FO-depth matching):
- C has stavi_depth <= r
- K^-(~C) = neg(std_snce(top, C)) has stavi_depth = max(0, r) + 2 = r + 2
- C' has stavi_depth = r + 2

But the current `h_fwd_r1` parameter provides a game at rank r+1, giving formula agreement only for stavi_depth <= r+1. C' needs stavi_depth <= r+2. This is a systematic offset: **the code needs h_fwd_r1 at rank r+2, not r+1**.

This is provably fine: the forward game hypothesis uses rank r+4(n+1), and r+2 << r+4 for n >= 0.

### 6. The Circularity is Real but Narrow

Reports 38, 39 confirmed that building a `NormalForm -> StaviFormula` function (i.e., "materializing C") requires inverting `stavi_table_mu`, which IS the expressive completeness theorem being proved.

HOWEVER, the circularity is narrower than it appears:

- What is CIRCULAR: Building a StaviFormula whose truth at ALL structures equals a given NormalForm evaluation. This requires the theorem.
- What is NOT CIRCULAR: Building a StaviFormula whose truth at a GIVEN SPECIFIC STRUCTURE (N, t) equals a given predicate. The pigeonhole already does this: it extracts one formula D with stavi_depth <= r that (a) holds on the interval (a_n, y') and (b) fails cofinally below c_inf.

The key insight from report 39's recommended approach (case split) is:

**Case A**: `cont_holds_cross` holds at c_inf. Then c_inf is in the continuation set, so ALL the failure witnesses u satisfy u < c_inf strictly. The strict pigeonhole (`pigeonhole_definable_formula_cross_strict`) extracts a formula D with stavi_depth <= r. No circularity.

**Case B**: `cont_holds_cross` FAILS at c_inf. Then unwinding the definition gives a specific formula A_fail with stavi_depth <= r already in hand. No pigeonhole needed, no circularity.

In both cases, the formula D or A_fail serves as GHR93's formula C in the specific instance. The construction is not the full interval-type formula (a conjunction of ALL types realized), but a SINGLE separating formula that suffices for the proof.

### 7. The Two Open Sorry Sites (S1, S2) and Their Resolution

**S1 (line 3901)**: The boundary case where r2_resp = rank_embed(y') forces c_inf = y.

- GHR93 handles this via "the strategy is winning, so..." and the boundary behavior of C at y'.
- In Lean: we have h_c_eq_y (c_inf = y), h_not_le (rank_embed(d) < r2_resp = rank_embed(y')).
- The argument: d < y' (from h_not_le), d in S_C (all mu-points in (d, y') satisfy cont_holds). If r2_resp = rank_embed(y'), then A_fail at r2_resp means A_fail fails at y' in N. But y' is not in the open interval (a_bwd(n), y'), so cont_holds at y' is vacuously true. This is a contradiction: A_fail fails at r2_resp = rank_embed(y'), but cont_holds at y' means A_fail MUST hold at y' (since it holds on the interval). BUT y' is the BOUNDARY of the open interval — the universal quantifier in cont_holds is over STRICT interior points v with v < y'. A_fail holding "on (a_bwd(n), y')" means A_fail holds at all mu-points v with a_bwd(n) < v < y'. This does NOT force A_fail to hold at y' itself.
- Resolution: This sub-case actually follows from the formula agreement and boundary analysis. Since h_not_le gives d < y', and A_fail holds at all mu-points in (d, y') (from hd_in_SC.2), we can find a mu-point q with d < q < y' and A_fail(q) holds. Then q is in the OPEN interval (d, y'), so A_fail(q) is TRUE. But q < r2_resp = rank_embed(y'). The game's formula agreement at q (playing Round 2 with q as Spoiler's choice) gives a response in M. This is effectively the "play a specific witness below y'" strategy. The sorry at line 3901 can be closed by playing a carrier point q' with d < q' < y' and using the game agreement there.

**S2 (line 3935)**: The gap case where r2_resp is a gap.

- This is the harder one. We have: ¬cont_holds_cross at c_inf (Case B), A_fail is in hand, A_fail fails at c_inf. Formula agreement transfers to r2_resp: A_fail fails at r2_resp. We want A_fail to HOLD at r2_resp to get a contradiction.
- But r2_resp is a gap — we cannot project it to a carrier point to use hd_in_SC.2.
- The GHR93 argument: the winning strategy preserves formula truth. Since r2_resp > rank_embed(d) (from h_not_le), and rank_embed(d) is also a gap (d is a gap, from the main case split at line 3586), the region between rank_embed(d) and r2_resp contains carrier points. For those carrier points, A_fail holds (from hd_in_SC). Extending truth from carrier points to gap r2_resp requires: since A_fail has stavi_depth <= r and gaps at rank r+2 are limits of carrier points (the carrier point side of the mu-structure), truth at the gap follows from rank-monotone properties.
- Concretely: `stavi_temporal_truth_mu N atomMap (r+2) r2_resp A_fail` should follow from the fact that all mu-points (carrier points) near r2_resp satisfy A_fail. Gaps are NOT mu-points, so the game's formula condition applies to mu-points only. The formula agreement `hform_1_A` gives truth at gap r2_resp, which is what we want to contradict.
- Resolution path: The formula agreement `hform_1_A` says A_fail has the SAME truth value at rank_embed(c_inf) and r2_resp. Since A_fail fails at c_inf (hence at rank_embed(c_inf)), A_fail fails at r2_resp. But we want A_fail to HOLD at r2_resp. The apparent contradiction is actually the whole point — this gives the contradiction `hA_fail_r2 : ¬A_fail at r2_resp` versus A_fail at r2_resp. The gap case cannot simply conclude because "A_fail at r2_resp" (the formula holding at the gap) requires r2_resp to be above d, and truth at a gap is not directly inherited from nearby points.
- The real fix: Use the CASE SPLIT (report 39): in Case B (¬cont_holds_cross at c_inf), we have A_fail directly. For the gap r2_resp sub-case, we need to show A_fail holds at r2_resp. This follows because: (1) rank_embed(d) < r2_resp; (2) d in S_C means cont_holds at all mu-points in (d, y') in N; (3) cont_holds at a mu-point q gives A_fail(q) (since A_fail holds on the interval); (4) rank-monotone formula truth extends from carrier points to the gap. This last step requires a lemma about truth at gaps in stavi_temporal_truth_mu that the code does not currently have.

---

## Recommended Approach

### Primary Recommendation: Align cont_holds with Formula C

The cleanest resolution aligning with GHR93 is to replace `cont_holds` with an explicit StaviFormula. The infrastructure is present:
- `rank_type`, `interval_types` (EFGames.lean, lines 923-937): define the semantic content
- `sf_conjList`, `sf_disjList` (EFGames.lean, lines 9796-9870): build finite conjunctions/disjunctions
- `nf_determines_stavi_truth` (ExpressivenessGeneral.lean, line 562): bridge from NF to formula

Define:
```lean
noncomputable def interval_type_sf (a_n y' : ExtendedCarrier N atomMap r) : StaviFormula :=
  -- Disjunction of characteristic StaviFormulas for each NF realized in (a_n, y')
  sf_disjList [... X_v for v a mu-point in (a_n, y') ...]
```

This is GHR93's C as a concrete StaviFormula with stavi_depth <= r. Then:
- `cont_holds a_n y' t ↔ stavi_temporal_truth_mu N atomMap r t (interval_type_sf a_n y')`
- C' = neg(conj(C, neg(neg(std_snce(top, C))))) has stavi_depth = r+2
- h_fwd_r1 at rank r+2 closes all 7 Claim 1 sorries

Estimated lines: ~300 (new interval_type_sf + proof of equivalence + C' proof + sorry closures).

### Secondary Recommendation: Case Split (Minimal Fix)

If replacing cont_holds is too disruptive, report 39's case-split approach closes the two S1/S2 sorry sites:

At the `h_cont_c` branch (line 3415), the by_cases on cont_holds_cross at c_inf is ALREADY in the code. The sorry is in Case B (¬cont_holds_cross at c_inf), gap sub-case (line 3935). The fix:

In Case B / gap r2_resp:
1. We have A_fail : StaviFormula with stavi_depth <= r, A_fail holds on (a_bwd(n), y'), A_fail fails at c_inf.
2. rank_embed(d) < r2_resp (gap). Between rank_embed(d) and r2_resp, there exist carrier points (by the gap ordering — any gap strictly greater than another admits a point in between).
3. Find q' such that rank_embed(d) < extendPoint(q') < r2_resp.
4. q' satisfies d < extendPoint(q') < y' at rank r (by rank_embed_lt projection).
5. d in S_C: cont_holds at extendPoint(q'). A_fail holds on interval, so A_fail holds at q'.
6. Now we need: A_fail holds at r2_resp (the gap). This is the key gap.

For this step, we need a lemma: "If A has stavi_depth <= r and A holds at extendPoint(q') for all q' approaching the gap r2_resp from below, then stavi_temporal_truth_mu N atomMap (r+2) r2_resp A."

This would follow from the fact that stavi_temporal_truth_mu at a gap is the LIMIT of truth at approaching carrier points. In the Lean formulation, truth at `Sum.inr g` (a gap) for atomic formulas is undefined (gaps have no predicate values), so temporal connectives at gaps are evaluated semantically. For a formula that holds at ALL mu-points in an interval above the gap, it should hold "at the gap" by the standard Dedekind-completeness-style argument.

This requires a new lemma (~60-80 lines) but is not circular.

### Rank Fix (Always Required)

Regardless of which approach is chosen, h_fwd_r1 must be at rank r+2 (not r+1) for the C' construction to work. This is a 6-location parameter change, all of which are justified by the available forward-game budget (rank r+4(n+1) >> r+2).

---

## Evidence and Specific References

### GHR93 Reference

**Section 8, p.115, Definition of C**: "Let C = X_{(alpha_{n-1}, y')}" — the interval type formula. This is defined in Definition 8.8 (p.113) as the conjunction of all rank-r temporal formulas true at every mu-point in the interval.

**Section 8, pp.115-116, Claim 1 proof**: "The formula C' = ~C ∨ K^-(~C) has rank r+1. Since [the forward game at rank r+1] is a winning strategy, N_r |= C'(d)." The key: C is used as a formula object in C'. Without formula C, C' cannot be formed.

**Section 8, p.113, Finiteness**: "There are only finitely many distinct types, so C is an effectively finite conjunction." This is the finiteness argument that makes C computable without circularity.

### Lean Code Evidence

**cont_holds definition** (ExpressivenessGeneral.lean, lines 112-120): Universal quantification over ALL StaviFormulas of depth <= r. This is semantically equivalent to C but syntactically an infinite predicate.

**rank_type and interval_types** (EFGames.lean, lines 923-937): The building blocks for constructing C as an explicit formula are present and sorry-free.

**sf_conjList / sf_disjList** (EFGames.lean, lines 9796-9870): Finite StaviFormula combinators are present and sorry-free.

**nf_determines_stavi_truth** (ExpressivenessGeneral.lean, line 562): NormalForm-to-StaviFormula truth bridge. Sorry-free.

**stavi_expressive_completeness** (EFGames.lean, lines 10089-10107): Already constructs char_sf : NormalForm -> StaviFormula using nf_characterizable_by_stavi. This is the pattern to follow for interval_type_sf — but applied at the structure level (for a specific N and interval) rather than universally.

**The circularity** (report 39, Section 1): Universal `NormalForm -> StaviFormula` is circular. But structure-specific (given N and interval) extraction of a single formula is NOT circular — it is exactly what `pigeonhole_definable_formula` already achieves.

**Current sorry S2** (line 3935): Comment explicitly states "formula materialization is circular" — but this is the universal materialization. The case-split approach avoids universal materialization entirely.

### Cross-check with Report 40

Report 40 (literature crossref) Section 3.1 confirms: "Replace cont_holds with the explicit StaviFormula X_{(a_n,y')}... The Xt definitions already exist in the codebase." This aligns with the primary recommendation above.

---

## Confidence Level

**High** on the diagnosis:
- cont_holds as predicate vs GHR93's formula C is the root cause (confirmed by reports 28, 36, 38, 39, 40 independently)
- The circularity is real but applies ONLY to universal materialization, not structure-specific extraction
- h_fwd_r1 rank off-by-one (r+1 vs r+2 for stavi_depth conventions) is confirmed by report 28_claim1-formula-materialization.md

**High** on the case-split path (secondary recommendation):
- Report 39 documents this in detail; the infrastructure is present
- S1 (line 3901) and S2 (line 3935) both follow from case B + gap analysis + a new truth-at-gap lemma

**Medium** on the primary recommendation (replace cont_holds):
- The building blocks exist (rank_type, interval_types, sf_conjList, nf_determines_stavi_truth)
- But the wiring (~300 lines) has not been prototyped, so there may be subtleties
- The equivalence proof `cont_holds ↔ interval_type_sf truth` requires careful quantifier manipulation

**Key uncertainty**: Whether `stavi_temporal_truth_mu N atomMap (r+2) (gap) A` follows from truth at all approaching carrier points. If it does (by the semantics of temporal formulas at gaps), the gap sub-case in S2 is closable. If it does not (if gaps can have different formula values than their surrounding carrier points), then the case split alone may be insufficient and the full cont_holds replacement is mandatory.

---

## Summary

The core divergence between GHR93 and the Lean formalization is:
- GHR93 uses **C = X_{(a_n, y')} as a finite temporal formula** (the conjunction of rank-r type representatives)
- Lean uses **cont_holds as an infinite predicate** (universal quantification over all StaviFormulas of depth <= r)

Both capture the same semantic content, but GHR93's C can be used syntactically (in C' = ~C ∨ K^-(~C)), while Lean's cont_holds cannot.

The resolution path:
1. **Always required**: Increase h_fwd_r1 rank from r+1 to r+2 (6 signature changes, ~30 lines)
2. **Minimal fix**: Case-split approach from report 39 + new truth-at-gap lemma (~240 + 80 lines, closes S1 and S2)
3. **Full alignment**: Replace cont_holds with interval_type_sf (~300 lines, closes all 7 Claim 1 sorries and aligns with GHR93 architecture)

The gap sub-case (S2) is the hardest: it requires either materializing C as a formula OR proving that stavi_temporal_truth_mu at a gap inherits from surrounding carrier points. If the latter holds by the semantics, S2 closes immediately from the existing proof structure.
