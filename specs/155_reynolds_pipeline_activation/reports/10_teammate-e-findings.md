# Report 10-E: Literature Alignment — GHR93 and Reynolds 1994 vs. Lean Implementation

**Task**: 155 — Reynolds Pipeline Activation
**Date**: 2026-05-20
**Focus**: Literature fidelity analysis, deviation classification, and path forward for remaining sorries

---

## Key Findings

1. **The game definition (G_{n;r}) is substantially faithful to GHR93 Definition 8.7**, though with a deliberate structural encoding difference that is mathematically equivalent.

2. **Lemma 9 is correctly stated** in the Lean formalization (EFGames.lean lines 1412–1442), precisely matching GHR93's semantic content, but is sorry'd. The GHR93 paper gives the proof as "clear" (one word), which conceals significant case-analysis work for the S/S' cases.

3. **The most critical deviation from the literature** is in the left_formula/right_formula definition for the S/S' cases: the paper uses "U(compound, D)" where compound contains Stavi subterms, but StaviFormula has no "standard Until of StaviFormulas" constructor. The implementation uses flatten_stavi as an encoding bridge. This is a necessary Lean adaptation, not a conceptual error, but it introduces a semantic gap that must be bridged by a sorry-free proof in Lemma 9.

4. **The assembly chain (Props 5–7, Corollary 5) is missing three critical theorems**: Proposition 6 (formula agreement → games), Proposition 7 (composition theorem), and the final expressive completeness derivation from Corollary 5. The plan correctly identifies these as Phase 4C Tasks 4C.8–4C.10, but they are labeled [TODO] with no implementation started.

5. **Reynolds 1994 Section 7 (Lemmas 6–13, Theorem 14) is correctly surveyed** in the plan and not yet begun. The plan's Phase 6 matches the paper structure accurately.

6. **The uniform-rank deviation in Theorem 6** (using rank r for both forward and backward games instead of r+4n forward / r backward) is a real simplification that avoids cross-rank coercion infrastructure. The rank-varying version (ghr93_forward_to_backward_rank_varying, line 2553–2571) is stated but sorry'd, leaving a gap between the uniform-rank theorem and what Proposition 7 needs.

7. **8 active sorries remain** across EFGames.lean (4) and ExpressivenessGeneral.lean (9, though lines 2432–2435 are comments listing known sorry'd cases). The plan's count of 13 total is accurate.

---

## Literature-Implementation Alignment

### GHR93 Definition 8.3 (Gaps and M_r) — Faithful

The Gap definition (EFGames.lean lines 255–267) matches the paper precisely:
- Non-empty downward-closed proper subset
- No supremum in the cut
- Complement has no minimum

The ExtendedCarrier definition (M_r = M.carrier ⊕ RDefinableGap M atomMap r, lines 354–356) is faithful to GHR93's construction.

The LinearOrder on ExtendedCarrier (lines 375–445) correctly implements the ordering: point x ≤ gap γ iff x ∈ γ.cut; gaps ordered by cut inclusion.

**Note**: The plan's deviation note that discrete orders "require IsSuccArchimedean in addition to four basic discrete conditions" is confirmed by GHR93 itself (p. 110: M_r = M for discrete orders, but the proof requires that the successor chain reaches every element — precisely IsSuccArchimedean).

### GHR93 Definition 8.4 / Remark 2 (Relativised Connectives, μ-relativization) — Faithful

The mu atom (h'(μ) = M, making μ true exactly at actual points) is implemented via the `mu_holds` predicate (IsPoint). The stavi_temporal_truth_mu function correctly relativizes U, S, U', S' to only quantify over μ-points.

The key fact in the GHR93 Remark 2(2): "If t ∈ M then M ⊨ A(t) iff M_r ⊨ A^μ(t)" is captured by rank_embed_stavi_truth_mu (lines 985–1044), which is a fully proved, sorry-free theorem.

### GHR93 Definition 8.5 (left(A,D) and right(A,D)) — Mostly Faithful with One Necessary Encoding

The GHR93 Definition 8.5 specifies left(A, D) by cases. Comparing the paper directly with the Lean code:

| Case (paper) | Paper formula | Lean (EFGames.lean) | Status |
|---|---|---|---|
| left(p, D) = ⊥ | atom → bot | line 1085–1086: `.base .bot` | Exact match |
| left(¬A, D) = U'(⊤,D) ∧ ¬left(A,D) | neg | lines 1131–1132: `.conj (.stavi_untl top D) (.neg ...)` | Exact match |
| left(A∧B, D) = left(A,D) ∧ left(B,D) | conj | lines 1134–1135: `.conj (left_formula A D) (left_formula B D)` | Exact match |
| left(U(A,B), D) = U'(B∧U(A,B), D) | untl (base) | line 1099: `.stavi_untl (.conj (.base ψ) (.base (.untl φ ψ))) D` | Exact match |
| left(U'(A,B), D) = U'(B∧U'(A,B), D) | stavi_untl | lines 1136–1138: `.stavi_untl (.conj B (.stavi_untl A B)) D` | Exact match |
| left(S(A,B), D) = U(D∧B∧S(A,B)∧U'(⊤,B∧D)∧¬U'(D,B∧D), D) | snce (base) | lines 1101–1113: uses flatten_stavi | **Encoding deviation** |
| left(S'(A,B), D) = U(D∧B∧S'(A,B)∧U'(⊤,B∧D)∧¬U'(D,B∧D), D) | stavi_snce | lines 1139–1150: uses flatten_stavi | **Encoding deviation** |

The S/S' deviation: GHR93 writes "U(compound, D)" where compound contains Stavi subterms (U'(⊤, B∧D), ¬U'(D, B∧D)). The paper treats temporal connectives and Stavi connectives as syntactically unified. In the Lean implementation, StaviFormula is a distinct type from Formula, and there is no "Formula.untl applied to StaviFormula arguments" constructor. The flatten_stavi function (StaviConnectives.lean) provides the bridge: it converts a StaviFormula to a Formula in discrete orders, but the semantic correspondence in general linear orders is what Lemma 9 must establish.

This is a **necessary adaptation** for the Lean type system, not an error. However, it means Lemma 9 for the S/S' cases cannot follow the paper's "clear" dismissal — it requires proving that the flatten_stavi encoding is semantically correct on M_r structures. This is the hardest part of Lemma 9.

**Rank bound claim**: GHR93 states rank(left(A,D)) ≤ max(rk(A), rk(D)) + 2. The plan notes this is sorry'd for the S/S' cases due to "nested max arithmetic involving operator_depth of flatten_stavi results." This is not a conceptual error; the bound is correct by the paper but requires a careful monotonicity proof for flatten_stavi composition depth.

### GHR93 Definition 8.7 (Game G_{n;r}) — Faithful with Structural Encoding Difference

GHR93 Def 8.7: "Round 1: Spoiler chooses n elements a_1,...,a_n from [x,y]_r; Duplicator responds with n elements from [x',y']_r. Round 2: Spoiler chooses one actual point b' from [x',y'] (not a gap); Duplicator responds with actual point b from [x,y]."

Lean (ghr93_duplicator_wins, lines 1559–1578): Faithfully encodes this as a Prop — for all Spoiler selections (a : Fin n → ...), there exist Duplicator responses (a' : Fin n → ...), such that for all Spoiler point challenges (b' : N.carrier), there exists a Duplicator point response (b : M.carrier), and the winning condition holds.

Winning condition (ghr93_winning_condition, lines 1536–1543): same_order_type ∧ gap_point_agreement ∧ formula_agreement. This matches GHR93 conditions (1), (2), (3) on page 112 (same order type, gap↔gap, rank-r formula agreement).

**One distinction**: The paper plays the game symmetrically (Spoiler can pick from either structure in Round 2). The Lean encoding fixes Round 1 to be M-side Spoiler picks and Round 2 to be N-side challenge / M-side response. This is the "forward game" direction; the backward game is a separate instantiation. GHR93 also distinguishes forward/backward in its proof structure, so this is faithful.

### GHR93 Lemma 10 (Monotonicity) — Partial Faithful

GHR93 Lemma 10: wins G_{n;r} → wins G_{n';r'} for n' ≤ n, r' ≤ r (provided x,y ∈ M_{r'}).

Lean (ghr93_duplicator_wins_round_mono, lines 1662–1679): Only round monotonicity (n' ≤ n at same r). Rank monotonicity is not implemented.

**Assessment**: This is a **necessary simplification** given the type-indexed rank parameter. The plan acknowledges it. The round monotonicity version is what Theorem 6's induction actually uses; rank monotonicity is only needed for Proposition 7 composition. The rank-varying Theorem 6 (lines 2553–2571, sorry'd) is where rank changes occur.

### GHR93 Definition 8.8 (X_t formulas, Decomposition Formulas) — Semantically Adapted

GHR93 Def 8.8(1): X_t = conjunction of all rank ≤ r formulas A such that M_r ⊨ A^μ(t). This is the "type" of an extended element.

Lean (rank_type, EFGames.lean lines ~830–904): Defined as a Set StaviFormula — the set of all StaviFormulas of depth ≤ r satisfied at t under mu-relativization. This is the right semantic content but uses a set rather than a finite conjunction.

GHR93 justifies finiteness: "because L is finite there are up to logical equivalence only finitely many distinct formulas of any rank." The Lean formalization avoids constructing the actual formula (a syntactic conjunction) and instead works with the set directly, which is mathematically cleaner and avoids finiteness arguments.

**Assessment**: Semantically correct. The deviation (set vs. conjunction) is a **beneficial improvement** — it avoids the finiteness argument that GHR93 waves away.

GHR93 Def 8.8(2) (n;r-decomposition formulas): The plan's deviation note says these are defined "semantically via decomposition_agreement rather than as syntactic FO formulas." This matches — Lemma 11's forward direction (game → decomposition) is proved (lines ~2290–2398), and the backward direction (decomposition → game) is sorry'd (line 2423). The semantic definition is a **beneficial simplification** that avoids syntactic FO formula construction in Lean.

### GHR93 Lemma 11 (Game ↔ Decomposition) — Partial Faithful

Forward direction (game → decomposition agreement): Proved at lines 2290–2398. The proof extracts decomposition witnesses from the game's Duplicator strategy. This is a long, careful proof that follows the paper's argument.

Backward direction (decomposition → game): Sorry'd at line 2423. GHR93's proof constructs Duplicator's strategy from the decomposition witnesses — this is the harder direction and requires the Round 2 challenge handling.

**For Phase 4C Tasks 4C.8–4C.10**: The backward direction of Lemma 11 is needed for Proposition 7 (which goes from decomposition agreement to the standard EF game). This sorry is on the critical path.

### GHR93 Theorem 6 (Forward-to-Backward Transfer) — Substantially In Progress

The theorem statement (ghr93_forward_to_backward, lines 2436–2531) is faithful to GHR93's (**)_n formulation, with the uniform-rank deviation already noted.

**Base case** (n=0): Fully proved (lines 2454–2498). Faithful to the paper: Duplicator applies the 1-round forward strategy with the Spoiler's challenge point as selection.

**Inductive step structure**: Faithful to the paper — split points c, d are constructed; four-case analysis dispatches to Cases I-IV.

**Case I** (a_0 < d): The plan states this is "DONE" and sorry-free. Examining the code structure at ExpressivenessGeneral.lean lines 2409–2410, ghr93_case_I is called without apology. Case I was confirmed proved in recent commits.

**Case II** (a_n is a point): ghr93_case_II is called at line 2375 and confirmed proved (~760 lines). The paper's argument uses U(B, A) with B = X_{a_n}, and the Lean proof uses tau + sigma approach with c as the a_n response. This is a **permissible deviation** — the paper uses U(B,A) to find the witness z, while the Lean proof uses the tau backward strategy's existing output directly, which is logically equivalent.

**Cases III-IV** (a_n is a gap): ghr93_cases_III_IV is sorry'd at line 2350. These cases require Lemma 9 gap detection, which is the primary remaining blocker.

### GHR93 Proposition 6 — Not Yet Implemented

GHR93 Prop 6 (lines 1261–1288 of the markdown): "If x and y satisfy the same temporal formulas of rank r + 4n + 1, then Duplicator has winning strategies for G_{n;r}(M, -∞x; N, -∞y) and G_{n;r}(M, x∞; N, y∞)."

This is [TODO] in the plan (Task 4C.8, ~100–150 lines). No Lean code exists yet. The paper's proof uses the type formulas C_i (involving X_{a_i} and U/U' for point/gap cases) to construct Duplicator's responses from the forward direction. This proposition bridges formula agreement to game existence.

### GHR93 Proposition 7 (Composition) — Not Yet Implemented

GHR93 Prop 7 (markdown lines 1294–1325): "If Duplicator wins G_{f(n);g(n)+4f(n)} on all sub-intervals between corresponding selected points (both forward and backward), she wins the standard EF game G_n."

This is [TODO] in the plan (Task 4C.9, ~150–250 lines). The proof uses Theorem 6 inductively and requires the rank-varying version of Theorem 6 (which is sorry'd). This is the most complex of the three assembly lemmas.

**Critical observation**: Proposition 7 requires the rank-varying Theorem 6 (which lives at different ExtendedCarrier types for the forward vs. backward game). The sorry at line 2571 for ghr93_forward_to_backward_rank_varying is therefore on the critical path for Proposition 7.

### GHR93 Corollary 5 = stavi_expressive_completeness — Not Yet Implemented

The main theorem (stavi_expressive_completeness, lines 2488–2495) is sorry'd. The paper's proof from Corollary 5 (markdown lines 1341–1357) assembles Props 5, 6, 7 as follows:
1. Apply Prop 7 (composition) to get EF game from sub-interval games
2. Apply Prop 5 (EF games ↔ FO sentences) to get formula equivalence
3. Obtain the temporal formula A as V{B ∈ Φ : M ⊨ B(t) and M ⊨ φ(t) for some linear M}

This requires the full assembly chain to be sorry-free.

---

## Deviations Found

### Deviation 1: Uniform Rank in Theorem 6
**Nature**: Simplification
**Classification**: Necessary adaptation (type system) — acceptable
**Impact**: The rank-varying version (ghr93_forward_to_backward_rank_varying) must be proved separately to feed Proposition 7. This is on the critical path.
**Location**: ExpressivenessGeneral.lean lines 2553–2571

### Deviation 2: flatten_stavi Encoding in left/right_formula S/S' Cases
**Nature**: Necessary type adaptation
**Classification**: Necessary adaptation (Lean type system) — acceptable
**Impact**: Lemma 9 for the S/S' cases must bridge flatten_stavi semantics. This is the hardest part of Lemma 9.
**Location**: EFGames.lean lines 1101–1113, 1139–1150

### Deviation 3: Set-based Type Formulas (rank_type) vs. Finite Conjunction
**Nature**: Simplification / improvement
**Classification**: Beneficial improvement — the set avoids syntactic finiteness arguments
**Impact**: None negative. Lemma 11 forward direction already proved using this representation.
**Location**: EFGames.lean lines ~830–904

### Deviation 4: d = a_bwd(n) Instead of Infimum
**Nature**: Structural deviation from GHR93 Theorem 6 proof
**Classification**: Acceptable deviation — mathematically equivalent for the purpose
**Impact**: The d-consistency hypotheses (sorry'd at lines 297, 307) are the price paid. GHR93 defines d as an infimum which automatically satisfies the consistency condition; the Lean proof sets d = a_bwd(n) and must separately prove consistency. This is the source of two non-trivial sorries in obtain_split_point_props.
**Location**: ExpressivenessGeneral.lean lines 170–260

### Deviation 5: Round Monotonicity Only (no rank monotonicity in Lemma 10)
**Nature**: Simplification
**Classification**: Necessary adaptation — but creates a gap for Proposition 7
**Impact**: Proposition 7 requires rank-varying game transfers. The sorry'd ghr93_forward_to_backward_rank_varying must be proved to close this gap.
**Location**: EFGames.lean lines 1662–1679

### Deviation 6: Lemma 9 Stated but Sorry'd (paper says "Clear")
**Nature**: Missing proof
**Classification**: Critical gap — on the path to Cases III/IV
**Impact**: Cases III and IV of Theorem 6 depend on Lemma 9. The paper dismisses the proof as "clear" (GHR93 p. 111: "PROOF. Clear."), but the Lean encoding complexity (especially for the S/S' cases via flatten_stavi) makes this non-trivial.
**Location**: EFGames.lean lines 1422–1442

---

## Recommendations for Remaining Work

### Priority 1: Lemma 9 (blocks Cases III/IV)

The left_formula and right_formula gap detection proofs (EFGames.lean lines 1412–1442) are the most critical remaining sorries. The paper treats these as obvious, but the Lean proof requires:

1. **Atom/boolean/Until/Since cases**: Straightforward structural induction following GHR93 Definition 8.5. The paper's "clear" is warranted here.

2. **S/S' cases via flatten_stavi**: This is the hard part. The proof must show that for a gap γ defined by D on the left, if stavi_temporal_truth_mu evaluated at Sum.inr γ produces the S/S' condition, then the left_formula_base (which uses flatten_stavi for the S case) correctly detects this at actual points. The key is that flatten_stavi preserves truth on discrete-like sub-intervals (which the cut of a D-defined gap approximates from below).

**Recommended approach**: Prove Lemma 9 first for the non-S/S' cases (one sub-lemma per constructor), then address the flatten_stavi encoding via a separate bridge lemma connecting flatten_stavi truth with stavi_temporal_truth_mu on M_r.

### Priority 2: Sub-interval Point Witnesses in obtain_split_point_props

Lines 336 and 345 in ExpressivenessGeneral.lean are sorry'd for the case "p_N > d (gap), need a point in [x',d]." This requires a density/cut argument: the gap γ = d has a nonempty cut, giving points below γ, but bounding below by x' requires showing the cut contains points in [x',d].

**Recommended approach**: Use the h_pt hypothesis (∃ p, inClosedInterval x' y' (extendPoint p)) plus the gap's nonempty cut property. If p_N > d, then p_N ∉ d.val.cut, so p_N is in the complement of d.val.cut. The cut contains points below γ, and since x' ≤ γ, any point in the cut is in [x',d). This requires a careful argument about the relationship between the gap ordering and the point p_N.

### Priority 3: d-Consistency Sorries (lines 297, 307)

The d-consistency hypotheses are sorry'd because the GHR93 proof constructs d as an infimum (automatically ensuring uniqueness), while the Lean proof sets d = a_bwd(n) and needs to prove the forward strategy must respond with d to selections that include c. This is the "Claim 1" of GHR93's Theorem 6 proof (p. 115: "As the strategy is winning, any rank r' temporal formula satisfied by one of V's choices must also be satisfied by the corresponding choice of ∃").

**Recommended approach**: The consistency follows from the formula_agreement component of the winning condition. If the forward strategy produces a response a'(i) for a selection including c at position i, then formula_agreement implies that a'(i) satisfies all the same rank-r formulas as c, and in particular the formula C' = ¬C ∨ K^-¬C that uniquely characterizes d = a_bwd(n). This is exactly Claim 1 in GHR93. The Lean proof should extract this from the formula_agreement field of ghr93_winning_condition.

### Priority 4: Rank-Varying Theorem 6 (ghr93_forward_to_backward_rank_varying)

Sorry'd at line 2571. Required for Proposition 7. The proof should derive from the uniform-rank version (ghr93_forward_to_backward) by using rank_embed_stavi_truth_mu to transfer formula agreement between ranks. The key property is already proved: rank_embed preserves stavi_temporal_truth_mu (lines 985–1044).

**Recommended approach**: Apply ghr93_forward_to_backward at rank r+4n, then use rank_embed to transport the backward strategy from rank r+4n back to rank r. The transport requires showing that a game at rank r+4n, when restricted to rank-r formulas, gives a winning strategy at rank r. This uses stavi_n_equiv_mono.

### Priority 5: Propositions 6 and 7

These are [TODO] with no implementation. Proposition 6 (~100–150 lines) is more straightforward: given formula agreement at rank r+4n+1, construct Duplicator's selections using the type formulas C_i from GHR93 p. 113–114. Proposition 7 (~150–250 lines) is harder: it uses Theorem 6 inductively across the composition of sub-interval games.

**Recommended approach**: Implement Proposition 6 first (it only requires ghr93_forward_to_backward and the type formula machinery). Then implement Proposition 7 using Proposition 6 and the rank-varying Theorem 6.

---

## Reynolds 1994 Section 7: Gap Elimination Coverage

Reynolds 1994 Section 7 (Lemmas 6–13, Theorem 14) provides exactly what the plan's Phase 6 needs. The literature markdown (Reynolds_1994_Axiomatising_U_and_S_over_integer_time.md, lines 466–816) gives the full proof:

- **Lemma 6** (lines 542–548): Temporal formula R detecting class-ends-at-gap. Uses expressive completeness of U and S for Prior structures (Theorem 5 = Phase 5' output).
- **Lemma 7** (lines 559–591): Maximal R-intervals are open. Uses Prior-U/S.
- **Lemma 8** (lines 593–611): No first/last class in R-intervals. Uses expressive completeness again.
- **Lemma 9** (lines 613–648): If temporal formula holds somewhere in one class in R-interval, holds in all classes. Proof uses Prior-U and the contemporaneity of the equivalence relation.
- **Lemma 10** (lines 650–684): Bad points in non-singleton bad intervals. Both R and L hold.
- **Lemma 11** (lines 686–709): Formula propagation across bad intervals.
- **Lemma 12** (lines 711–788): Model surgery — replace bad interval by one class, preserve temporal truth. This is the 14-case induction proof (U forward: cases 1–7; U backward: cases 1–6; Since cases by duality).
- **Lemma 13** (lines 790–809): Contradiction — R holds in I in N but N is a Prior structure.
- **Theorem 14** (lines 811–816): Contemporaneous equivalence classes don't end at gaps.

**Key observation**: The plan's Phase 6 structure (Tasks 6.1–6.9) accurately mirrors this structure. The dependency on Theorem 5 (US expressive completeness for Prior structures = Phase 5' output) is correctly identified.

**One potential issue**: Reynolds Lemma 12 (model surgery) has the case structure for Until only (7 cases for M ⊨ U(A,B)(t) ↔ N ⊨ U(A,B)(t), split into (→) and (←) sub-cases). The plan estimates 14 cases "for Until plus Since cases" — this count is correct (7 cases × 2 directions for U, 7 × 2 for S, but the S cases are symmetric). The plan should proceed case by case exactly as Reynolds presents them.

**Reynolds Lemma 9 in the gap elimination context** (not to be confused with GHR93 Lemma 9) has a different statement: "If a temporal formula holds somewhere in one ≈-class in a maximal interval of R, then it holds somewhere in each ≈-class in the interval." This is a lemma about the contemporaneous equivalence relation, not about gap detection. The naming collision between "Reynolds Lemma 9" (gap elimination) and "GHR93 Lemma 9" (gap detection) is noted — they are completely different lemmas.

---

## Confidence Level

- **Gap definition (Def 8.3) alignment**: High confidence — faithful implementation
- **Relativization / mu-encoding (Def 8.4)**: High confidence — faithful and proved
- **left/right_formula (Def 8.5) alignment**: High confidence — faithful except S/S' encoding (necessary Lean adaptation, well-understood)
- **Game definition (Def 8.7) alignment**: High confidence — faithful encoding
- **Lemma 10 (monotonicity) alignment**: Medium confidence — round monotonicity proved, rank monotonicity missing
- **Lemma 9 (gap detection) alignment**: High confidence on statement, medium confidence on provability of the S/S' cases via flatten_stavi
- **Theorem 6 proof structure**: High confidence — Cases I and II proved, Cases III/IV blocked on Lemma 9
- **Assembly chain (Props 5–7, Cor 5)**: Low confidence — not yet implemented; structural plan is sound but 400–600 lines of non-trivial proofs remain
- **Reynolds 1994 Section 7 (gap elimination)**: High confidence on plan structure; not yet implemented

---

## Summary for Implementers

The implementation is mathematically sound and the plan correctly identifies the remaining work. The critical path is:

1. **Lemma 9** → unblocks Cases III/IV of Theorem 6 induction
2. **d-consistency sorries** (lines 297, 307) + **sub-interval point witnesses** (lines 336, 345) → unblocks obtain_split_point_props
3. **ghr93_forward_to_backward_rank_varying** → unblocks Proposition 7
4. **Propositions 6 and 7** → unblocks Corollary 5 = stavi_expressive_completeness

The most faithful path through the literature for Lemma 9 is to prove it by structural induction on A, following GHR93's "clear" for all non-S/S' cases, and then proving a dedicated bridge lemma for the S/S' cases connecting flatten_stavi semantics with the mu-relativized truth on M_r. The d-consistency sorries should be addressed by extracting the proof from ghr93_winning_condition's formula_agreement field — this is exactly GHR93's "Claim 1" argument.
