# Research Report: Task #273 — Chronicle Gap Contradiction Proof

**Task**: 273 - chronicle_gap_contradiction_proof
**Date**: 2026-06-11
**Mode**: Team Research (4 teammates)
**Session**: sess_1781191352_6f253f
**Focus**: Literature-grounded resolution of the sub-interval matching blocker; verification of past handoff claims; alternative paths

## Summary

Plan v16 is unsalvageable in all three phases, and — more importantly — **sorry site 3 (`nf_exist_sf_guarded_backward`, line 2857) is mathematically FALSE as stated**, a finding reached independently by two teammates. The formula `nf_exist_sf_guarded` reads only the atom part of `sub_nf` and its guard is provably vacuous (`interval_guard_sf_true`), so distinct 2-var NFs sharing atoms map to the same Stavi formula; no amount of bridge-lemma work can close that sorry. Closing the chain therefore requires either a **formula redesign** (in-architecture) or an **architecture bypass**.

Two viable paths emerged:

1. **Path A (primary recommendation, from Horizons)**: Bypass `stavi_expressive_completeness` entirely. Re-prove `US_expressively_complete_over_prior` directly via Rabinovich 2014's games-free composition proof of Kamp's theorem, relativized from Dedekind completeness to the Prior structure hypotheses (`semantic_prior_UZ/SZ`) that the theorem already carries. This dissolves all recurring blockers at once (no two-model transfer, no zone matching, no circularity, no arity escalation — Rabinovich's Lemma 3.2(2) caps free variables at 2, no Stavi connectives, no gap detection). The Prior restriction is NOT circular (unlike the prohibited discrete bypass): `semantic_prior_UZ/SZ` are hypotheses at every use site, while `IsSuccArchimedean` is the conclusion being proven. Estimated 3000-6000 lines with no known mathematical obstruction. **Mandatory pre-planning gate**: verify against the full Rabinovich PDF that every completeness invocation in §5 reduces to first/last occurrences of TL-definable sets.

2. **Path B (fallback, GHR-faithful in-architecture)**: From the Primary teammate's exact extraction of the GHR94 §12.8 proof: (i) NF projection lemma (~150-300 lines), (ii) master lemma `nf_tuple_agreement_from_adjacent_pairs` — strong induction on depth d with arity free, invariant = **adjacent-pair 2-var NF agreement** (not interval type sets, not 1-var splitting) (~250-450 lines), (iii) decomposition-style replacement for `nf_exist_sf_guarded` using nested Until/Since chains in the style of GHR's Prop 12.8.16 C_i formulas — this last item is the dominant, currently unscoped cost. The bridge lemma `nf_2var_from_interval_data` is likely unprovable as stated at full depth k from 1-var data (GHR seeds bounded intervals from 1-var types nowhere; its application has m=1, end zones only).

## Key Findings

### Verified facts (Critic, machine-checked)

- **Exactly one root sorry on the critical path**: a Lean metaprogram walking the proof-term cone of `completeness_discrete` confirms `nf_exist_sf_guarded_backward` is the sole declaration using `sorryAx`. Sorries 2405/2487 are off-path only because 2857 is a bare `sorry` that never calls the bridge; they become root blockers the moment Phase 3 wiring happens.
- **Current sorry sites verified**: StaviCompleteness.lean 2405, 2487, 2857 (+ DiscreteStaviCompleteness.lean:338, off-path). Report 07's line numbers are stale (~50-line shift).
- **No call-graph circularity exists in committed code**: `nf_2var_existential_transfer` does NOT call `nf_fraisse_compression`. The circularity is real only at the proof-strategy level (closing 2405 via `existential_transfer_from_nf` + compression for the inner configuration loops back to the goal). The only committed combination (`nf_2var_from_interval_data`:2570) is the legal direction.
- **Tooling pitfall**: `lean_verify` silently returns an empty axiom list for `private` theorems (e.g., `gap_prior_UZ_contradiction`). Use `lake env lean` + `#print axioms` as authoritative.

### Errors found in past findings (Critic)

- **Transcription error cost one full cycle (F3)**: handoff v15 requested the splitting lemma with sub-interval agreement at depth **k-1**; plan v16 transcribed it at depth **k**, then "discovered" that strengthened version false and blocked. The depth-(k-1) version was never attempted, and its depth budget closes (j' < k-1 after one split). Any future splitting lemma must be stated at depth k-1, never k.
- **Counterexample scope (F2)**: the v16 handoff counterexample is rigorously valid at k=0, valid at k=1 only with padding (handoff omits this), and EXCLUDED by `h_nf_x` at k≥2 — exactly the regime where the lemma is used (`hj : j'+1 < k`). The same-depth splitting lemma is refuted at k≤1 and unproven-likely-false at k≥2. The handoff's headline "FALSE for 1-var interval types" overstates what was proven.
- **Stale code comment at 2855**: claims `nf_2var_from_interval_data` is sorry'd; in fact its proof body is complete (sorry-taint inherited from `nf_2var_existential_transfer`).
- **`atom_agree_from_pointwise` is uninstantiable as stated (F5a)**: its hypothesis demands 1-var NF agreement at ALL depths, while zone matching provides one fixed depth k (monotonicity gives ≤ k only). The proof body only uses depth 1 — trivially fixable, but no prior plan noticed.

### Sorry 3 is false as stated (Primary + Infrastructure, independent convergence)

`nf_exist_sf_guarded` (2656) depends only on `sub_nf.atom_assgn`: `nf_t_consistent` reads pred atoms, the order checks read order atoms, `atom_compat` filters witness types by pred atoms only, and the guard `interval_guard_sf` is a disjunction over ALL 1-var NFs — provably always true (`interval_guard_sf_true`, 2637). The quantifier part `sub_nf.quant_assgn` is never consulted. For k≥1, an unrealizable sibling NF (same atoms, all-false quant part) yields a counterexample to the backward direction.

**Containment**: damage is modular. `nf_characterizable_by_stavi` consumes only the existential statement `nf_2var_existence_characterizable` via `Classical.choose`; that existential is plausibly TRUE — only its current witness formula is wrong. Replacing the witness breaks nothing downstream. The file's own comments (2613-2624) sketch a configuration-enumerating replacement formula.

### Why plan v16 Phase 2 cannot close as designed (Primary + Critic, independent convergence)

- **GHR's game proof structure** (extracted verbatim from GHR94 ch12): induction on rounds-remaining n with arity m universally quantified inside the statement; the maintained invariant is **pairwise-local** — both-direction two-round interval games for every ADJACENT pair. Duplicator does not zone-match by 1-var type: she batches witnesses of ALL decomposition formulas of both sub-intervals into ONE coordinated game on the whole interval, then uses Lemma 12.8.14 + Theorem 12.8.15 (game inversion) to re-establish the invariant on the new sub-intervals. Plan v16's induction skeleton (on d, arity free) is GHR-faithful; its hypothesis set is not.
- **Concrete failure (Critic F5b)**: `zone_match_witness` returns orderings only relative to the base pair; `game_transfer_at_depth`'s IH requires orderings of the new point vs ALL env points, which the step case cannot establish. The signature also carries no interval data for env pairs.
- **Decomposition formulas encode arrangement + per-segment fillers** (marked-point types AND interval filler constraints). `interval_nf_types` is strictly weaker (filler-free 1-mark fragment); `interval_2var_nf_types` is closer but still a set abstraction that loses cross-witness coordination. In the Hintikka-NF framework, the correct invariant is the **adjacent pair's 2-var depth-d NF itself** — its quant part is exactly the coordinated one-point-extension data. `interval_splitting_zone_match` should be abandoned: splitting falls out of the quant part plus an NF projection lemma.

### Approach feasibility (Infrastructure)

| Approach | Verdict | Reason |
|---|---|---|
| 1. Replace `interval_nf_types` with `interval_2var_nf_types` throughout | Not recommended as stated | `interval_2var_nf_types` is dead code (zero supporting lemmas); anchored at `hi` only so the lower sub-interval split is still undetermined; breaks proved discrete pipeline call sites; and the temporal formula interface can only extract 1-var data (`char_k`) — no 2-var detector exists |
| 2. Depth-decreasing game, arity free | Skeleton correct, hypotheses must be upgraded to adjacent-pair 2-var NF agreement (= corrected Path B) | Reuses `nf_fraisse_compression`, `atom_agree_from_pointwise` (after depth-hypothesis fix), `existential_transfer_from_nf` — all already arity-generic |
| 3. Hybrid (derive 2-var interval agreement from 1-var) | Not viable | The derivability claim IS the sub-interval matching problem relocated |

**Exact goal at 2405** (via `lean_goal`): 4-var existential transfer at depth j' for (u,x,t)/(u',x',t'), with depth-k pairwise 1-var NF equality and all orderings, but interval/above/below data only for the (x,t) pair. Missing: data for the new pairs (u,x), (u,t).

### Strategic findings (Horizons)

- **Discrete-first-then-lift is prohibited** (confirmed by code): `gap_prior_UZ_contradiction` applies expressive completeness to a model WITHOUT `IsSuccArchimedean` precisely to prove that property. `DiscreteStaviCompleteness.lean` is off the critical path.
- **`stavi_expressive_completeness` is over-general for its only consumer**: the sole external consumer is `US_expressively_complete_over_prior` (PriorExpressiveness.lean:384), which already restricts to models satisfying `semantic_prior_UZ/SZ`; every downstream use site supplies those hypotheses (verified by exhaustive grep). Restricting expressive completeness to Prior structures loses nothing and is not circular.
- **Rabinovich 2014 fits the Prior restriction exactly**: his proof uses Dedekind completeness in exactly one place (the INF formula in Lemma 5.3); `semantic_prior_UZ` delivers something stronger for definable sets — attained first occurrences. The proof on Prior structures is *simpler* than on ℝ (the non-attained-infimum disjunct vanishes). Stavi connectives never enter (`stavi_U_false_on_prior_UZ` is already proved sorry-free). Venema 1993 provides direct literature precedent for definable-completeness relativization.
- **Gap detection is NOT made vacuous by Prior-UZ** (kills hope of cheaply finishing the general game path): the game is played on `ExtendedCarrier` where gaps are materialized; Prior structures can have definably-invisible order gaps. The 9 Cases III/IV sorries in CaseAnalysis.lean remain expensive. Rabinovich's route avoids the extended carrier entirely.
- **No Mathlib shortcut**: no rank-k EF game or Feferman-Vaught infrastructure exists in Mathlib.

## Synthesis

### Conflicts Resolved

1. **Infrastructure (B) recommended Approach 2 gated on literature; Primary (A) answered the gate negatively.** B's open kernel — "is the splitting lemma provable from 1-var full-model type sets?" — is resolved by A's extraction: GHR93/94 never derives bounded-interval data from 1-var types + type sets (the application Cor 12.8.19 has m=1; 1-var data seeds only end zones via Prop 12.8.16). The 1-var splitting kernel has no literature support. Approach 2 survives only in its hypothesis-upgraded form (adjacent-pair 2-var NF invariant), which is Path B.
2. **Critic (C) leaned approach 1 (2-var interval types); Infrastructure (B) showed the formula-extraction interface blocks it.** Resolution: both are right at different layers. The bridge-side invariant must indeed be 2-var (per GHR), but `interval_2var_nf_types` as a Finset hypothesis is the wrong vehicle (anchor asymmetry, no temporal detector). A's formulation — pair 2-var NF agreement as the invariant, decomposition-style formula at the consumer — subsumes C's preference while answering B's objection. C's own caveat ("research the 2-var-detecting formula cost BEFORE committing") aligns with this: that formula construction is exactly A's item (iii) and is the dominant unscoped risk of Path B.
3. **Depth accounting**: C's F3 (state splitting at k-1, budget closes) is consistent with A's master lemma (one depth unit per round). No conflict — A's formulation simply never states a same-depth lemma.

### Gaps Identified

- The Rabinovich relativization check (every §5 completeness use = first/last occurrence of a TL-definable set) has not been performed against the full PDF — only the md summary asserts it. This is the single gating risk of Path A and must be the first step of any plan adopting it.
- Path B's decomposition-formula redesign (nested U/S encodings with per-segment filler disjunctions of `char_k` types, enough marked points to pin `sub_nf`) has no line estimate; GHR's f/g budget governs the marked-point count and could make the formula family large.
- No concrete k≥2 counterexample exists for the same-depth splitting lemma (only a strong depth-accounting heuristic). Irrelevant if either path is adopted, but worth noting if anyone proposes resurrecting plan v16.

### Recommendations

1. **Adopt Path A (Rabinovich relativization) as the primary plan**, with the PDF verification as Phase 0 / a hard gate. Keep the signature of `US_expressively_complete_over_prior` unchanged; only its body changes; downstream consumers unaffected. On success, the three sorry sites and the Stavi NF chain leave the critical path (boneyard or keep as documented open generalizations; update ROADMAP).
2. **Hold Path B as the documented fallback** if the verification gate fails: projection lemma → master lemma (`nf_tuple_agreement_from_adjacent_pairs`, strong induction on d, arity free, adjacent-pair 2-var NF invariant) → decomposition-style formula replacement for `nf_exist_sf_guarded` → rebase 2405/2487 on a 2-var-NF-hypothesis variant of the transfer theorem.
3. **In either path, do not attempt to prove `nf_exist_sf_guarded_backward` as stated** — it is false. Plan v16 Phase 3 must not be executed.
4. Process fixes for future cycles: state any splitting-type lemma at depth k-1; any game-style transfer theorem must carry in its own hypotheses whatever pairwise data its step case hands to the IH (the structural test every prior plan failed); fix `atom_agree_from_pointwise`'s ∀-depth hypothesis if used; use `#print axioms` not `lean_verify` for private theorems; re-run the proof-term cone metaprogram after changes.

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | Primary — GHR93/94 Prop 7 proof extraction | completed | HIGH (proof architecture), MEDIUM-HIGH (master lemma provability) |
| B | Alternatives — codebase infrastructure, approach feasibility | completed | HIGH (sorry-3 falsity, inventory), MEDIUM (line estimates) |
| C | Critic — claim verification, error hunting | completed | HIGH (machine-checked cone, F3/F5 errors) |
| D | Horizons — strategic alternatives | completed | HIGH (Prior-restriction sufficiency), MEDIUM-HIGH (Rabinovich relativization) |

Teammate findings: `08_teammate-a-findings.md`, `08_teammate-b-findings.md`, `08_teammate-c-findings.md`, `08_teammate-d-findings.md` (same directory).

## References

- GHR94 ch12 transcription: `literature/Gabbay_Hodkinson_Reynolds_1994_Temporal_Logic_Foundations_Vol1_ch12.md` (Defs 12.8.8-12.8.17, Lemma 12.8.14, Thm 12.8.15, Props 12.8.16/12.8.18, Cor 12.8.19)
- GHR93: `literature/Gabbay_Hodkinson_Reynolds_1993_Temporal_expressive_completeness_gaps.md` (Prop 7)
- Rabinovich 2014: `literature/Rabinovich_2014_Proof_of_Kamps_Theorem.md` + PDF (verification gate)
- Venema 1993: `literature/Venema_1993_Since_and_Until.md` (definable-completeness relativization precedent)
- Code: `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean` (sorry sites 2405/2487/2857), `NFGameBridge.lean`, `PriorExpressiveness.lean`, `GoodStructuresModelSurgery.lean`
