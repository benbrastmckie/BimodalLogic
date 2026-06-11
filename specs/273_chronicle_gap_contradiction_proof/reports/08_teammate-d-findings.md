# Task 273 — Teammate D (Horizons): Strategic Alternatives and Broader Context

**Date**: 2026-06-11
**Focus**: Out-of-the-box alternatives to the blocked 4-var existential transfer in `nf_2var_existential_transfer` (StaviCompleteness.lean:2405, 2487, 2857)

---

## Key Findings

### Finding 1: The discrete-first-then-lift strategy is architecturally prohibited (CONFIRMED, do not pursue)

The ROADMAP (`specs/ROADMAP.md`) contains an explicit anti-pattern warning for task 273: replacing `stavi_expressive_completeness` with `discrete_stavi_expressive_completeness` inside `US_expressively_complete_over_prior` is **circular**. The consumer `gap_prior_UZ_contradiction` (GoodStructuresModelSurgery.lean:1169) applies the expressive completeness theorem to a model M that has `SuccOrder + PredOrder + NoMaxOrder + NoMinOrder + semantic_prior_UZ/SZ` but **not** `IsSuccArchimedean` — the whole point of that theorem is to derive the contradiction that PROVES the model is `IsSuccArchimedean`. `DiscreteStaviCompleteness.lean` (1 sorry at line 338) is valuable only as a standalone result; it is not on the critical path to `completeness_discrete`.

### Finding 2: The general theorem is over-general for its only consumer — Prior-restriction is legitimate and NOT circular (KEY STRATEGIC INSIGHT)

I verified by grep over the whole codebase:

- The **only** consumer of `stavi_expressive_completeness` outside the EFGames directory is `US_expressively_complete_over_prior` (PriorExpressiveness.lean:384).
- `US_expressively_complete_over_prior` itself already restricts its correctness claim to models satisfying `semantic_prior_UZ` and `semantic_prior_SZ` (PriorExpressiveness.lean:371-393).
- Every consumer of `US_expressively_complete_over_prior` is in GoodStructuresModelSurgery.lean (lines 930, 953, 1266, 1580, 1707, 1997) plus Boneyard, and every use site supplies `h_prior_UZ`/`h_prior_SZ` from hypotheses already in scope.

Therefore an expressive completeness theorem **relativized to Prior structures** (chains where every temporal-formula-definable nonempty future/past set has a first/last occurrence — "definably complete chains") suffices for the entire downstream pipeline. This is fundamentally different from the prohibited discrete bypass: `semantic_prior_UZ/SZ` are *hypotheses* at the use site, while `IsSuccArchimedean` is the *conclusion* being proven. No circularity.

This restriction has direct literature precedent: Venema 1993 ("Completeness via Completeness") relativizes exactly this way — his Lemma 4.1 shows that on models validating the W axiom, every S'U'-formula collapses to an SU-formula (U'(ψ,χ) ≡ ⊥), the exact analogue of the already-proved sorry-free `stavi_U_false_on_prior_UZ` (PriorExpressiveness.lean:111). Doets's theorem (Venema §3.8) similarly works with "definably well-ordered" models rather than genuinely well-ordered ones.

### Finding 3: Rabinovich 2014 gives a games-free, NF-free composition proof that fits the Prior restriction exactly (PRIMARY RECOMMENDATION)

`literature/Rabinovich_2014_Proof_of_Kamps_Theorem.md` documents a self-contained proof of Kamp's theorem (TL(Until, Since) expressively complete for FOMLO over Dedekind complete chains) that **avoids EF games entirely**. Structure:

1. **Exists-forall normal form** (Def 3.1): ψ = ∃x_n...∃x_0 (ordering constraints) ∧ (α_j at each x_j) ∧ (β_j along each interval (x_{j-1}, x_j)) ∧ (boundary conditions). This is an interval decomposition with quantifier-free types.
2. **Closure lemmas** (3.2, 3.4): conjunction, disjunction, ∃-quantification — pure finite combinatorics. Crucially, Lemma 3.2(2) reduces every exists-forall formula to a conjunction with **at most two free variables** — the arity escalation that has killed 16 plan iterations does not arise.
3. **Translation** (Prop 3.5): each exists-forall formula with one free variable maps directly to nested Until/Since: `A_k ∧ (B_{k+1} U (A_{k+1} ∧ (B_{k+2} U ...)))`.
4. **Negation closure** (Prop 4.2/Lemma 5.1, the hard part): induction on the number of interval segments, splitting at a definable infimum point.

**The decisive observation**: Dedekind completeness is used in *exactly one place* (literature file, Key Insight 3) — the INF formula r_0 = inf{z ∈ (z_0,z_1) | P_1(z)} in Lemma 5.3. `semantic_prior_UZ` delivers something strictly stronger for definable sets: a first occurrence s with ¬P everywhere in (z_0, s), i.e., the infimum *exists and is attained*. (If P_1 occurs in (z_0,z_1), the global first occurrence above z_0 automatically lies in (z_0,z_1).) The K+ disjunct handling non-attained infima becomes unnecessary, so the proof on Prior structures is *simpler* than on ℝ. All sets used in the induction are definable by TL(U,S) formulas (the F_i of Corollary 5.4 are TL-definable; quantifier-free Σ-types are Boolean predicate combinations, covered via `h_surj`), and `semantic_prior_UZ/SZ` quantify over arbitrary `Formula` — exactly the right strength.

**Why this dissolves every blocker at once**:
- **No sub-interval matching**: there is no two-model transfer at all. The proof is a per-model semantic equivalence established by syntactic induction. No zone matching, no reference models, no NF agreement.
- **No circularity**: the nf_agreement ↔ transfer mutual dependence belongs to the NF/game route and simply does not appear.
- **No arity escalation**: Lemma 3.2(2) caps free variables at two.
- **No Stavi connectives**: targets TL(U,S) directly; U'/S' (always false on Prior structures) never enter.
- **No gap detection**: the 9 Cases III/IV sorries in Expressiveness/CaseAnalysis.lean become irrelevant to this path.

### Finding 4: Composition method status in the codebase (partial answer to the Thomas 1997 question)

The composition method is *already partially formalized*: `ghr93_strategy_compose` in EFGames/Composition.lean (626 lines) proves GHR93 Proposition 7 strategy composition, and report 08 verified the discrete pipeline (`discrete_nf_to_decomposition_agreement` → `ghr93_decomposition_implies_game` → `discrete_ghr93_proposition7`) sorry-free. Thomas 1997's md file is a reconstruction (PDF not obtained) confirming the general principle: the EF-type of ([a,b], z) is determined by the types of [a,z] and [z,b]. However, the **general** (non-discrete) game path remains blocked by 9 sorries in CaseAnalysis.lean Cases III/IV (gap detection via Lemma 9). I investigated whether Prior-UZ/SZ makes Cases III/IV vacuous: it does **not** — the game is played on `ExtendedCarrier`, where gaps are materialized as first-class elements, and Prior structures can have order-theoretic gaps that are definably invisible (the constant-label ℤ×ℤ-lex scenario from task 155). Duplicator must still match gap selections. So completing the general game path remains high-effort even under the Prior restriction; Rabinovich's route (Finding 3) avoids the extended carrier entirely because it never plays a game.

### Finding 5: Within-architecture fallback — 2-var interval types (handoff v16 approach 1)

If the Rabinovich route is rejected, the literature-faithful fix within the current architecture is to replace `interval_nf_types` with `interval_2var_nf_types` (already defined, StaviCompleteness.lean:1847) throughout the bridge chain. Handoff v16 documents why: GHR93's decomposition formulas inherently carry 2-var information; the 1-var type set is a lossy projection (counterexample: interval realizing types in order A<B<C vs C<B<A — same 1-var set, different sub-interval sets). Risks: (a) `nf_exist_sf_guarded_backward` must then *extract 2-var interval data from a temporal formula*, which is the same expressiveness bottleneck pushed one level down — a Stavi formula evaluated at an interior point u cannot directly reference the anchor t; (b) this is the 17th iteration against the same wall. The sorry-free decomposition machinery in NFGameBridge.lean would be the natural source of 2-var data, but connecting it generally re-encounters Cases III/IV.

### Finding 6: Burgess 1982 and remaining literature

Burgess 1982 provides axiomatic completeness for the B system over linear orders via counterexample lemmas (§2.9-2.11) — it is the foundation the project already uses (Venema §3.5 cites it as the base) and is orthogonal to the expressive-completeness sorry. Venema 1993's value here is methodological (Finding 2): "completeness via expressive completeness" with definable-completeness relativization. Neither offers an alternative proof of the transfer lemma itself.

### Finding 7: No off-the-shelf Mathlib infrastructure

Semantic search confirms Mathlib has no bounded-quantifier-rank EF games or Feferman-Vaught composition. Available: `FirstOrder.Language.PartialEquiv`/`Fraisse` (back-and-forth for full elementary equivalence of countably generated structures) — wrong granularity for rank-k equivalence. No import shortcut exists.

### Finding 8: Weaker sufficient conditions assessment

A fixed-arity (e.g., 4-var) transfer statement does **not** suffice for the NF route: the recursion at depth j requires (2 + (k−j))-var transfer in the worst case, so arity must stay free (as in plan v16's `game_transfer_at_depth`, whose induction shape is correct — the blocker is hypothesis strength, not structure). Scott-sentence/back-and-forth reformulations just rename the same obstruction. The genuinely weaker statement that suffices is the **model-class restriction** of Finding 2, which weakens what is quantified over rather than the transfer itself.

---

## Recommended Approach

**Primary: Re-prove `US_expressively_complete_over_prior` directly via Rabinovich 2014 relativized to Prior structures, bypassing `stavi_expressive_completeness` entirely.**

Concretely:

1. **Keep the signature of `US_expressively_complete_over_prior` unchanged** (it already takes `semantic_prior_UZ/SZ` per model) — downstream consumers in GoodStructuresModelSurgery.lean are unaffected. Only its body changes.
2. **Phase structure** (following Rabinovich §3-5, literature-fidelity mode):
   - Define exists-forall formulas over the existing `MonadicFormula sig` infrastructure (Def 3.1) and the bracket notation `[α_0, β_1, ..., α_n](z_0, z_1)`.
   - Prove closure Lemmas 3.2/3.4 (finite interleaving combinatorics; the heaviest grind, no semantics).
   - Prove Prop 3.5: translation of one-free-variable exists-forall formulas to `Formula` via nested `untl`/`snce`, correctness w.r.t. `temporal_truth`.
   - Prove Lemma 5.3 and Prop 4.2 (negation closure) replacing the INF/Dedekind step with `semantic_prior_UZ/SZ` first/last-occurrence (simpler: infimum always attained; the r_0 = z_0 limit case vanishes).
   - Assemble Prop 4.3 + Thm 4.4 = the new body of `US_expressively_complete_over_prior`.
3. **Aftermath**: the three sorries at StaviCompleteness.lean:2405/2487/2857, `nf_2var_from_interval_data`, `nf_exist_sf_guarded_backward`, and the general `stavi_expressive_completeness` leave the critical path to `completeness_discrete`. They can remain as documented open generalizations or be boneyarded per the ROADMAP dead-code pattern. The Stavi chain entry in ROADMAP should be updated.

**Mandatory verification before planning** (flag for planner): read the full PDF (`literature/Rabinovich_2014_Proof_of_Kamps_Theorem.pdf`) and confirm that *every* completeness invocation in §5 (Lemma 5.1's three cases, Lemma 5.3's induction, Corollary 5.4) is of the form "first/last occurrence of a TL-definable set relative to an existing point", i.e., covered by `semantic_prior_UZ/SZ`. The md summary asserts completeness is used only in the INF formula (Key Insight 3), but this must be checked against the paper before committing 3000-6000 lines.

**Fallback**: Finding 5 (2-var interval type strengthening) if the Rabinovich relativization check fails — but with the explicit warning that it re-encounters the formula-extraction bottleneck one level down.

**Effort comparison**: the Rabinovich route is a fresh ~3000-6000 line development of syntactic inductions with no known mathematical obstruction; the current route has a *demonstrated* information-loss obstruction (handoff v16 counterexample) after 16 plan iterations, and the general game alternative carries 9 gap-detection sorries on the extended carrier.

---

## Evidence/Examples

| Claim | Evidence |
|-------|----------|
| Only external consumer of `stavi_expressive_completeness` is the Prior theorem | grep: sole hit outside EFGames is PriorExpressiveness.lean:384 |
| All `US_expressively_complete_over_prior` uses supply Prior hypotheses | GoodStructuresModelSurgery.lean:930, 953, 1266-1269, 1580-1583, 1707-1710, 1992-1997; theorem signature PriorExpressiveness.lean:371-382 |
| Discrete bypass circular | ROADMAP anti-pattern warning (task 273 section); `gap_prior_UZ_contradiction` lacks `IsSuccArchimedean` instance (GoodStructuresModelSurgery.lean:1169-1182) |
| Rabinovich uses completeness in exactly one place | literature/Rabinovich_2014_Proof_of_Kamps_Theorem.md §5 Lemma 5.3, Key Insight 3 ("used in exactly one place: the INF formula (5.2)") |
| `semantic_prior_UZ` gives attained first occurrences of definable sets | PriorExpressiveness.lean:59-66 (statement quantifies over all `Formula` ψ) |
| Arity capped at 2 in Rabinovich's normal form | literature md, Lemma 3.2(2) |
| U'/S' false on Prior structures (Stavi connectives eliminable) | `stavi_U_false_on_prior_UZ`, PriorExpressiveness.lean:111 (sorry-free); same pattern as Venema 1993 Lemma 4.1 |
| Definable-completeness relativization is standard | literature/Venema_1993_Since_and_Until.md §3.6-3.8 (Doets), §4.1-4.2 |
| Sub-interval 1-var types lossy (current blocker is real) | handoff phase-1-handoff-v16-20260609T225727Z.md counterexample (A<B<C vs C<B<A) |
| Strategy composition already formalized | EFGames/Composition.lean `ghr93_strategy_compose`; discrete pipeline sorry-free per reports/08_game-pipeline-research.md §1 |
| General game path blocked by gap detection | Expressiveness/CaseAnalysis.lean: 9 sorries, Cases III/IV (lines 2151, 3376-3417) |
| Gap cases not vacuous on Prior structures | game on `ExtendedCarrier` materializes gaps; constant-label ℤ×ℤ-lex satisfies Prior-UZ yet has gaps (task 155 finding, ROADMAP) |
| No Mathlib EF games | leanfinder: only `FirstOrder.Language.PartialEquiv`/`Fraisse` (full elementary equivalence, not rank-k) |
| Current sorry sites | StaviCompleteness.lean:2405, 2487 (`nf_2var_existential_transfer` j≥1), 2857 (`nf_exist_sf_guarded_backward`); DiscreteStaviCompleteness.lean:338 |

---

## Confidence Level

| Finding | Confidence | Notes |
|---------|-----------|-------|
| 1. Discrete bypass prohibited | **High** | Explicit ROADMAP warning + verified consumer signature |
| 2. Prior-restriction sufficient for all consumers | **High** | Exhaustive grep of consumers; all use sites carry Prior hypotheses |
| 3. Rabinovich proof relativizes to Prior structures | **Medium-High** | Mathematically natural (Prior-UZ ⇒ attained definable infima); md summary asserts single use of completeness; MUST be verified against full PDF before planning |
| 3b. Rabinovich formalization effort (3-6k lines, no obstruction) | **Medium** | Lemma 3.2 interleaving combinatorics and Prop 4.2 case analysis are tedious but elementary; estimate uncertain |
| 4. Composition/game general path stays expensive (gap cases) | **High** | 9 sorries inspected; gaps materialized in ExtendedCarrier regardless of Prior-UZ |
| 5. 2-var interval type fallback viable but risky | **Medium** | Aligns with GHR93 per handoff, but formula-extraction bottleneck recurs |
| 6-8. Literature/Mathlib/weaker-condition assessments | **High** | Direct source inspection |
