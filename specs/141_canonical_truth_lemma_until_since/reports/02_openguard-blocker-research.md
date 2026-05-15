# Research Report: Task #141 — Open-Guard Blocker Deep Dive

**Task**: 141 — Canonical truth lemma Until/Since and ReflexiveCanonical infrastructure
**Date**: 2026-05-14
**Mode**: Single-agent deep research

## Summary

Seven sorries remain: 1 in ReflexiveCanonical.lean (`reflCanR_linear`, line 144) and 6 in TruthLemma.lean (lines 426, 443, 479, 494, 548, 563). The `canS5R_symm` sorry from the prior count is ALREADY CLOSED (Phase 1 completed). Three major findings emerged:

1. **Critical Path Status**: None of the 7 sorries propagate into `bx_completeness` through theorem dependency. The `truth_lemma` is defined but never called. `reflCanR_linear` is defined but never used. These are architecturally dead code relative to the completeness theorem. The sorry contamination in `#print axioms bx_completeness` comes from OTHER sources (the `existsTask_transitive` sorry in `Bundle/CanonicalFrame.lean` line 259 -- which is trivially fixable -- and Chronicle pipeline sorries).

2. **The Guard Condition Is Structurally Impossible in the ReflCanDomain Model**: The intermediate guard condition for Until/Since (the core of all 6 TruthLemma sorries) CANNOT be proved in the current ReflCanDomain model because the model lacks the chronicle gap-content structure that Burgess's proof requires. The `tempR_fwd` relation (g_content inclusion) provides no mechanism to force formula membership at intermediate MCS points. Neither BX5 (self-accumulation), BX13 (enrichment), nor any other available axiom bridges this gap. This is not a missing lemma; it is a structural mismatch between the model and the proof technique.

3. **reflCanR_linear Is Provable But Unused**: The BX11-based linearity proof is straightforward (the proof sketch in the plan is correct) but the theorem has zero consumers in the codebase. Proving it has no impact on the sorry count for `bx_completeness`.

## Detailed Findings

### A. reflCanR_linear (ReflexiveCanonical.lean:144)

**Status**: Provable, but unused dead code.

**Consumer analysis**: `grep -rn "reflCanR_linear"` returns only the definition site. No theorem, lemma, or definition anywhere in the codebase references `reflCanR_linear`. It is not imported or used by Transfer.lean, ChronicleExtraction.lean, FrameProperties.lean, or any BXCanonical file.

**Proof feasibility**: The proof sketch from the plan (Phase 2) is correct:
1. By contradiction: assume incomparable y, z (both tempR_fwd x y and tempR_fwd x z).
2. Get witness formulas from non-inclusion of g_contents.
3. Derive F(neg psi) and F(neg chi) at x using negation completeness + a helper `neg_G_imp_F_neg`.
4. Apply BX11 (temp_linearity) for a 3-way case split leading to contradiction.

The `neg_G_imp_F_neg` helper (G(psi) not in x implies F(neg psi) in x) requires: (a) negation completeness gives neg(G(psi)) in x; (b) derive `neg(G(psi)) -> F(neg(psi))` as a theorem, which requires `G(neg(neg(psi))) -> G(psi)` (from double negation elimination under G via `temp_k_dist` + temporal necessitation). This is ~15 lines.

The BX11 case analysis is ~30 lines following the standard pattern from `BXCanonical/Frame.lean`.

**Recommendation**: Close this sorry ONLY if there is a downstream consumer planned (e.g., if the Reynolds pipeline or a future truth-lemma proof needs linearity of the canonical frame). Otherwise, it has zero impact on sorry-free `bx_completeness`.

**Circularity question (from research prompt)**: The previous agent claimed the BX11 argument might be circular. This is INCORRECT. BX11 (temp_linearity) is a base axiom (not derived from reflCanR_linear). The proof uses BX11 to prove reflCanR_linear, not the other way around. There is no circularity.

### B. The Until/Since Guard Condition (TruthLemma.lean: 6 sorries)

#### B.1 Structure of the 6 Sorries

The 6 sorries decompose into 3 pairs (future + past mirror):

| # | Sorry | Line | Direction | Type |
|---|-------|------|-----------|------|
| 1 | `until_forward_mcs` | 426 | U in x -> semantic U | Forward guard condition |
| 2 | `until_backward_mcs` | 443 | not-U in x -> not-semantic-U | Backward (contrapositive) |
| 3 | `since_forward_mcs` | 479 | S in x -> semantic S | Forward guard condition (mirror) |
| 4 | `since_backward_mcs` | 494 | not-S in x -> not-semantic-S | Backward (mirror) |
| 5 | `truth_lemma` Until bwd | 548 | semantic U -> U in x | Truth lemma case |
| 6 | `truth_lemma` Since bwd | 563 | semantic S -> S in x | Truth lemma case |

Sorries 5-6 depend on 1-4: if 1-4 are proved, 5-6 close by contraposition using the induction hypotheses.

Sorries 2 and 4 (backward) are contrapositives. They require: "semantic Until witness exists => U(psi1,psi2) in x.val". This is logically equivalent to the forward direction of the truth lemma, which itself depends on 1 and 3 being solved.

So the ENTIRE dependency chain reduces to sorries 1 and 3: the intermediate guard condition for Until and Since forward.

#### B.2 What the Guard Condition Requires

`until_forward_mcs` (sorry 1) states: Given U(psi1, psi2) in x.val, there exists y (an MCS) with:
- `tempR_fwd x y` (g_content x subset y.val)
- `psi1 in y.val`
- For ALL z with `tempR_fwd x z` AND `tempR_fwd z y`: `psi2 in z.val`

The third condition (the guard) is the blocker. The current proof constructs y from the seed `{psi1} union g_content(x)`, which gives the first two conditions. But there is NO mechanism to ensure psi2 at intermediate z.

#### B.3 Why the Guard Cannot Be Proved in the Current Model

**The fundamental obstacle**: `tempR_fwd x z` means `g_content(x) subset z.val`, which says "every formula G-ed by x is in z." But U(psi1, psi2) in x.val does NOT mean G(U(psi1, psi2)) in x.val. The Until formula is not a G-formula, so it does not propagate through g_content to intermediate points.

**BX5 (self_accum_until) does not help**: BX5 gives U(psi1, psi2) -> U(psi1, psi2 AND U(psi1, psi2)). This enriches the guard with U itself. But the enriched Until is STILL not a G-formula. It lives in x.val but not in g_content(x), so it does not propagate to z.

**BX13 (enrichment_until) does not help for the same reason**: BX13 gives p AND U(event, guard) -> U(event AND S(p, guard), guard). This enriches the event at the witness with Since information. Even if the witness y has S(alpha, psi2) for relevant alpha, extracting psi2 at an intermediate z from Since membership at y requires the truth lemma for Since -- which we are trying to prove.

**BX4 (connect_future) does not help**: BX4 gives phi -> G(P(phi)). So if psi2 in z, then G(P(psi2)) in z. But this is the WRONG direction -- we need to derive psi2 in z, not derive consequences of it.

**The Burgess approach does not transfer**: Burgess's Lemma 2.4 uses chronicles (f, g) where g(x,y) is a DCS describing what holds THROUGHOUT the interval. Property C3 says g(x,z) = g(x,y) intersect f(y) intersect g(y,z). This gap-content structure is what makes the guard work: beta in g(x,y) means beta holds at all intermediate points.

The ReflCanDomain has no analog of the gap-content g. The relation `tempR_fwd` is just set inclusion of g_content. There is no structure tracking what holds BETWEEN two MCS points. The model construction is missing the key ingredient.

**Enriching the witness seed**: Even if we enrich the seed to `{psi1} union {S(alpha, psi2) : alpha in g_content(x)} union g_content(x)` (a Burgess-style enrichment), and prove it consistent (which would require BX13), the resulting MCS y would contain S(alpha, psi2) for various alpha. But deriving psi2 at intermediate z from these Since formulas requires a chronicle-like chain argument that the ReflCanDomain does not support.

#### B.4 What the Removed Axioms Would Have Done

BX8 (`psi -> (phi U psi)`) and BX9 (`(phi U psi) -> (phi or psi)`) were removed because they are unsound under open-guard semantics (t < z < s, not t <= z <= s).

Under half-closed guard [t,s), BX9 gives: U(psi1, psi2) at x implies psi2 at x (since x is in [x,y)). This would let us put psi2 directly in x.val from U(psi1,psi2) in x.val. Combined with BX4, this gives G(P(psi2)) in x, propagating P(psi2) to intermediate z.

Under open guard (t,s), psi2 at the current point x is NOT guaranteed by U(psi1, psi2). The formula says there is a witness s > x with psi1 at s and psi2 on (x,s) -- but x itself is excluded.

**Is there a weaker BX8/BX9 that is sound?** No. The key property needed is "U(psi1, psi2) at x implies something about psi2 at x." Under open guard, U says nothing about x itself. Any axiom that extracts psi2 at the current point from U would be unsound on open-guard frames.

#### B.5 Alternative Completeness Approaches

**Mosaic method**: Mosaics (Caleiro-Vigano-Volpe 2013, Hodkinson-Reynolds 2006 Section 5.10) decompose models into small pieces and reassemble. This avoids the inductive chain construction. However, formalizing the mosaic method in Lean would be a major new undertaking (estimated 40+ hours) and is not practical for this task.

**Game-based approach**: Game-theoretic completeness proofs exist for some temporal logics. No published game-based completeness for US over integers is known.

**Expressive completeness (Venema 1993, BRV 2002 Section 7.2)**: The BRV approach uses: (a) Burgess-Xu for linear-order completeness, (b) definable well-ordering via the W axiom, (c) n-equivalence transfer to well-ordered models. This is the approach already implemented in the Reynolds pipeline (Transfer.lean). The truth lemma for Until/Since is NOT needed by this approach -- it uses the parametric truth lemma which handles Until/Since through the BFMCS step-transfer mechanism on discrete Int chains.

**Chronicle construction (Burgess 1982)**: This IS the approach used by `dd_countermodel_chronicle_discrete`. It works. It handles Until/Since through the C3/C4/C5 properties of chronicles. It does NOT use the ReflCanDomain model at all.

#### B.6 Can the Semantics Be Changed?

The research prompt asks: what if reflCanTruth used a different relation for the guard interval?

If we changed the guard to use `reflCanR` (the weak g_w_content relation) instead of `tempR_fwd`, we would have: for z with reflCanR x z and reflCanR z y, psi2 in z. But reflCanR x z means g_w_content(x) subset z.val, which requires both psi and G(psi) in x for each psi in the seed. This is even MORE restrictive and would not help.

If we added a new relation specifically for the guard interval (a "gap-content" relation), we would essentially be reinventing the chronicle construction inside the ReflCanDomain. This would make the ReflCanDomain approach equivalent to the existing chronicle approach, providing no benefit.

**Conclusion**: Changing the semantics in reflCanTruth would either (a) break soundness, (b) make the model equivalent to the chronicle, or (c) not help. The fundamental issue is that the ReflCanDomain model lacks gap-content structure.

### C. Critical Path Analysis

#### C.1 Do These Sorries Block bx_completeness?

**NO.** Verification:

1. `bx_completeness` (Completeness.lean:129) calls `doets_countermodel_discrete` for the discrete case.
2. `doets_countermodel_discrete` (Transfer.lean:110) falls back to `dd_countermodel_chronicle_discrete`.
3. `dd_countermodel_chronicle_discrete` (ChronicleToCountermodel.lean:3285) uses `cantor_bfmcs_discrete` + `fully_restricted_parametric_representation_from_neg_membership`.
4. Neither step uses `WeakCanonical.truth_lemma`, `reflCanR_linear`, or any of the 7 sorry'd theorems.

The `doets_countermodel_discrete` has `sorryAx` in its axioms, but this comes from:
- The `existsTask_transitive` sorry in `Bundle/CanonicalFrame.lean:259` (which is trivially fixable -- it uses `temp_4` which is already an axiom; the sorry is a stub for `DerivationTree.axiom [] _ (Axiom.temp_4 phi)`)
- Other sorries in the Chronicle pipeline (counterexample elimination, mixed case, etc.)

**None of the 7 WeakCanonical sorries are on the bx_completeness critical path.**

#### C.2 When Will These Sorries Matter?

The WeakCanonical truth lemma would matter if:
1. The Reynolds pipeline (task 140) replaces the chronicle fallback in `doets_countermodel_discrete` AND
2. The Reynolds pipeline uses the WeakCanonical truth lemma instead of the parametric truth lemma.

Looking at Transfer.lean, the Reynolds pipeline comments indicate it will use `chronicle_is_good` + `k_equiv` + truth transfer via `table` correctness. This does NOT use `WeakCanonical.truth_lemma`. The truth transfer goes through the monadic FO satisfaction layer (`Table.lean`, task 140), not through direct formula-level truth.

So even when task 140 completes, the 7 sorries will likely still be dead code.

#### C.3 Bonus Finding: Trivially Fixable Sorry

`existsTask_transitive` in `Bundle/CanonicalFrame.lean:259` has a sorry for `temp_4` derivation:
```lean
have h_T4 : [] ⊢ (Formula.all_future phi).imp (Formula.all_future (Formula.all_future phi)) :=
    sorry /- BX: derive temp_4 from BX1 -/
```

This should be:
```lean
    DerivationTree.axiom [] _ (Axiom.temp_4 phi)
```

`temp_4` IS an axiom (not derived from BX1 -- the comment is incorrect). This one-line fix would eliminate a sorry that propagates into `doets_countermodel_discrete` and `bx_completeness`. This is NOT task 141 scope but is a critical-path finding.

### D. Literature Analysis

#### D.1 Burgess 1982

Burgess's completeness proof (Section 2, Lemmas 2.4-2.10) constructs chronicles (f, g) satisfying C0-C5. The key properties:
- **C3**: g(x,z) = g(x,y) intersect f(y) intersect g(y,z) for x < y < z
- **C5a**: U(xi, eta) in f(x) implies exists y > x with xi in f(y) and eta in g(x,y)

Lemma 2.4 uses the enriched seed C0 = {gamma} union {S(alpha, beta) : alpha in A} for consistency, proved via BX13 (A3a). Lemma 2.6 handles point splitting for counterexample elimination. Lemma 2.7-2.8 handle Until counterexample elimination.

The chronicle's gap-content g is the crucial structure absent from ReflCanDomain. The proof REQUIRES tracking what holds throughout intervals, not just at endpoints.

#### D.2 Reynolds 1992 (Section 4)

Reynolds uses the Burgess-Xu result (Theorem 1 = strong completeness for B over linear orders) to get a rational-flowed model, then applies expressive completeness + Prior axioms to get definable Dedekind completeness, then uses the Doets theorem to transfer to a real-flowed model.

For integer time (Section 10), Reynolds uses the W axiom (Prior-UZ) to enforce definable well-ordering, then uses n-equivalence to transfer to Z-models.

Reynolds's approach does NOT need a separate truth lemma for Until/Since -- it gets Until/Since truth from the Burgess chronicle construction, which has the C3/C5 properties built in.

#### D.3 Blackburn-de Rijke-Venema 2002 (Section 7.2)

The BRV approach (Theorem 7.19) for well-ordered flows: (a) B-consistency gives a linear model via Burgess-Xu, (b) BW axioms make it definably well-ordered (Lemma 7.18), (c) Lemma 7.17 transfers to genuine well-ordered model via n-equivalence.

This approach is exactly what the Reynolds pipeline implements. It does not need a ReflCanDomain truth lemma.

### E. Boneyard Analysis

#### E.1 ChainCompleteness/

Contains archived chain construction attempts (MCSWitnessChain, ResolvingChain, etc.) that used the SuccChain framework. These were abandoned because the SuccChain approach on Int has the same step-transfer problem: pulling Until backward requires `(phi U psi) in chain(n+1) AND phi in chain(n) => (phi U psi) in chain(n)`, which needs BX8.

#### E.2 ClosedGuardLegacy/

Archives the removed BX8, BX9, and guard axioms. Confirms they are genuinely unsound under open guard: BX9 `(phi U psi) -> (phi or psi)` requires the current point to be in the guard interval, which open guard excludes.

#### E.3 NonBurgessSeed/

Archives a seed approach that tried to prove g_content(A) subset B for BurgessR3Maximal. Hit a "density gap" where G(phi) in A and U(neg phi, gamma) in A are semantically contradictory on dense orders but cannot derive bot without density axioms.

## Recommendations

### 1. Deprioritize All 7 WeakCanonical Sorries (Strong Recommendation)

None of the 7 sorries are on the `bx_completeness` critical path. The effort to close the 6 TruthLemma sorries is not justified by any theorem dependency. The ReflCanDomain truth lemma is dead code.

### 2. Fix the `existsTask_transitive` Sorry (1 Line, High Impact)

In `Theories/Bimodal/Metalogic/Bundle/CanonicalFrame.lean:259`, replace `sorry` with `DerivationTree.axiom [] _ (Axiom.temp_4 phi)`. This is a one-line fix that eliminates a sorry on the actual `bx_completeness` critical path. This should be a separate task or folded into an existing task.

### 3. If the Truth Lemma Must Be Closed: Restructure the Model

The ReflCanDomain model CANNOT support a truth lemma for Until/Since under open-guard semantics without fundamental restructuring. Two viable paths:

**Path A**: Add chronicle gap-content to the ReflCanDomain. Define a function `gap_content : ReflCanDomain -> ReflCanDomain -> Set Formula` tracking what holds between two MCS points, satisfying a C3-like property. This would be a substantial redesign (~20-40 hours) amounting to reimplementing the Burgess chronicle inside the ReflCanDomain.

**Path B**: Abandon the ReflCanDomain truth lemma entirely and use the parametric truth lemma (already sorry-free for the supported cases) as the sole truth lemma for the completeness theorem. The ReflCanDomain module would remain as infrastructure for frame properties (reflexivity, transitivity, symmetry of the S5 relation) but would not need its own truth lemma.

Path B is strongly recommended as it aligns with the existing architecture.

### 4. Close reflCanR_linear Only If a Consumer Is Planned

The proof is straightforward (~50 lines), but the theorem is currently unused. If a future task needs linearity of the canonical frame (e.g., for a direct completeness proof not going through chronicles), close it then.

## Artifact Inventory

| Artifact | Path | Status |
|----------|------|--------|
| This report | specs/141_canonical_truth_lemma_until_since/reports/02_openguard-blocker-research.md | New |
| Prior team research | specs/141_canonical_truth_lemma_until_since/reports/01_team-research.md | Existing |
| Implementation plan | specs/141_canonical_truth_lemma_until_since/plans/01_truth-lemma-plan.md | Existing (phases 2-5 BLOCKED) |
