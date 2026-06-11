# Teammate C Findings: Critic — Verification of Past Claims (Task 273)

**Role**: Critic — verify or refute claims made in handoffs v14/v15/v16, plan v16, and report 07.
**Date**: 2026-06-11
**Method**: Direct code reading, `lean_goal` at sorry sites, `#print axioms` via `lake env lean`, and a Lean metaprogram computing the exact proof-term dependency cone of `completeness_discrete`.

---

## Key Findings

### F1. Sorry chain claim (report 07): VERIFIED and STRENGTHENED — exactly one root sorry on the critical path

I wrote a Lean metaprogram that walks the proof-term dependency cone of
`Bimodal.Metalogic.BXCanonical.completeness_discrete` and reports every declaration whose
type/value directly mentions `sorryAx`. Result:

```
Direct sorry users in cone of completeness_discrete (1):
  Bimodal.Metalogic.WeakCanonical.nf_exist_sf_guarded_backward
```

This is a stronger verification than report 07's per-theorem `lean_verify` sampling: it rules out
ALL other sorried declarations in the codebase (TruthLemma.lean, SuccExistence.lean,
SuccRelation.lean, CaseAnalysis.lean, ChronicleToCountermodel.lean:531, Transfer.lean:1297,
UntilSinceCoherence.lean, etc.) as being on the `completeness_discrete` path. Report 07's central
claim Q4 ("exactly ONE sorry must be eliminated") is correct. **Confidence: HIGH.**

`#print axioms` confirms `sorryAx` in: `completeness_discrete`, `no_gaps_discrete_model_surgery`,
`stavi_expressive_completeness`, `US_expressively_complete_over_prior`,
`nf_exist_sf_guarded_backward`, and in the (currently off-path) bridge chain
`nf_2var_existential_transfer` / `nf_2var_from_interval_data` / `nf_2var_transfer` /
`nf_2var_exist_sf_classical` / `nf_2var_existence_characterizable` / `nf_characterizable_by_stavi`.
Sorry-free (verified): `nf_fraisse_compression`, `zone_match_witness`, `atom_agree_from_pointwise`,
`nf_exist_sf_guarded_forward`.

**Important nuance report 07 obscures**: the sorries at 2405/2487 are *currently* not in the cone
only because `nf_exist_sf_guarded_backward`'s body is a bare `sorry` (line 2857) that never calls
the bridge. The code comment (2853-2856) and plan all intend to close 2857 *via*
`nf_2var_from_interval_data`. The moment that happens, 2405/2487 become the binding root sorries.
Report 07's description of `nf_2var_existential_transfer` as a "dead end" is technically true of
the current proof terms but strategically misleading. **Confidence: HIGH.**

**Stale line numbers in report 07**: it cites 2805 (now 2857) and 2353/2435 (now 2405/2487). The
file has shifted by ~50 lines since report 07 was written.

**Tooling caveat discovered**: `gap_prior_UZ_contradiction` is a `private theorem`
(GoodStructuresModelSurgery.lean:1169). The `lean_verify` MCP tool silently returns an EMPTY axiom
list when given the public-style name of a private theorem (and was also flaky on
`completeness_discrete`, once returning empty and once erroring). An empty axiom list from
`lean_verify` must NOT be read as "sorry-free". `lake env lean` + `#print axioms` is authoritative.

### F2. Counterexample claim (handoff v16): VALID for k ≤ 1; does NOT directly apply at k ≥ 2 (where the lemma is actually used)

The 5-point counterexample (M: x < A < B(=u) < C < t; M': x' < C' < B'(=u') < A' < t') is:

- **k = 0**: fully valid. Depth-0 1-var NFs are atom types; all hypotheses of
  `interval_splitting_zone_match` (h_nf_x, h_nf_t, orderings, interval type sets = {A,B,C},
  above-max = below-min = ∅) are satisfiable with the bare 5-point orders, yet the only B-point u'
  in (x',t') gives `interval_nf_types M 0 x u = {A} ≠ {C} = interval_nf_types M' 0 x' u'`.
  **Verified by hand; HIGH confidence.**
- **k = 1**: valid only WITH PADDING (the bare 5-point version fails the hypotheses: depth-1 NF of
  a records "above = {B,C,T}" in M but a' records "above = {T}" in M', so the interval type sets at
  depth 1 already differ). Fix: embed both arrangements in models where every color occurs
  unboundedly above and below every point; then depth-1 NF degenerates to atom color and the
  counterexample goes through. The handoff does not mention this needed padding — a minor
  imprecision. **MEDIUM-HIGH confidence.**
- **k ≥ 2**: the displayed counterexample is EXCLUDED by `h_nf_x`, exactly as the handoff's NOTE
  says. Concretely, the depth-2 NF of x records realized depth-1 2-var NFs (w,x); in M there is a
  type-A point above x with no type-C point in between (namely a), in (padded) M' there is not. So
  `h_nf_x` fails. **Verified by hand; HIGH confidence.**

**Consequence the handoff gets right but the plan got wrong**: every actual use of the lemma has
`hj : j' + 1 < k` (verified via `lean_goal` at line 2405), so k ≥ 2 always. The recorded
counterexample therefore does NOT formally refute the lemma in the used parameter range. What it
shows is that the hypotheses are *lossy at the bottom of the depth hierarchy*; the standard
EF-game depth-accounting argument (the conclusion "sub-interval types at depth k" is a
depth-(k+1)-type property of the triple (x,u,t), while all hypotheses are depth-k) strongly
suggests the same-depth lemma fails at every k, but no k ≥ 2 counterexample has been constructed.
Status: same-depth lemma is **refuted at k ≤ 1, unproven and likely false at k ≥ 2**.
**Confidence in this assessment: MEDIUM-HIGH.**

### F3. ERROR FOUND: plan v16 silently strengthened the lemma handoff v15 asked for

Handoff v15 ("What Is Needed to Unblock") requested interval-splitting with sub-interval agreement
**at depth k-1**:

> (c) interval_nf_types M (k-1) x u = interval_nf_types M' (k-1) x' u'
> (d) interval_nf_types M (k-1) u t = interval_nf_types M' (k-1) u' t'

Plan v16 Phase 1 stated `interval_splitting_zone_match` with the conclusion **at depth k**
(plan lines 141-142: `interval_nf_types M k x u = interval_nf_types M' k x' u'`). The v16
implementation cycle then "discovered" this depth-k version false and blocked. The
depth-(k-1) version v15 actually asked for was never formally stated, attempted, or refuted.
The v16 handoff's "approach (2) depth-decreasing game" is essentially a rediscovery of v15's
original request. This is a concrete transcription error that cost one full plan/implement cycle.
**Confidence: HIGH** (direct text comparison).

Depth-budget check for the (k-1) version: after one split the bridge depth is k-1, and the
recursive transfer is needed at depth j' with j'+1 < k, i.e. j' < k-1 — exactly the requirement of
the bridge at depth k-1. The budget closes at every level. So IF the depth-(k-1) splitting lemma
is true with 1-var types, the recursion is well-founded. Whether it IS true with 1-var types is
the open question — the v16 handoff's own intersection analysis (types_below_u ∩ types_above_x is
only a SUPERSET of types_in_(x,u)) shows the obvious proof fails. **Open.**

### F4. Circularity claim (plan v16 / handoff v15): VERIFIED at signature level; it is a property of the PROPOSED approach, not of committed code

Verified from the actual code:

- `existential_transfer_from_nf` (NFGameBridge.lean:719): hypothesis = n-var NF agreement at depth
  d+1; conclusion = (n+1)-var existential transfer at depth d. ✓ matches handoff claims.
- `nf_fraisse_compression` (StaviCompleteness.lean:2006): hypotheses = n-var atom agreement +
  (n+1)-var transfer at ALL j < k (including j = k-1); conclusion = depth-k n-var NF equality. ✓
- Therefore: 4-var transfer at depth d ⟸ 3-var NF agreement at d+1 ⟸ 4-var transfer at all
  j < d+1 — which includes j = d, the goal itself. The circle is real **when these two lemmas are
  the only devices used**. **Confidence: HIGH.**

Answers to the specific sub-questions:

- Does `nf_2var_existential_transfer` invoke `nf_fraisse_compression`? **NO.** Its body (lines
  2292-2487) uses only `zone_match_witness`, `nf_agreement_from_shared_nf`,
  `atom_agreement_from_nf`; both `j'+1` branches end in bare `sorry` (2405, 2487).
- The only committed combination is the LEGAL direction: `nf_2var_from_interval_data`
  (line 2570-2571) = `nf_fraisse_compression k 2 ... (nf_2var_existential_transfer ...)`, i.e.
  transfer at all j < k feeding compression at k. Not circular.
- Confirmed: `StaviCompleteness.lean` imports only `EFGames.Decomposition`; `NFGameBridge` is
  imported only by `DiscreteStaviCompleteness.lean`. Handoff v16's claim that
  `existential_transfer_from_nf` "is NOT imported by StaviCompleteness.lean" is **correct**, and
  no `existential_transfer_from_nf_local` exists anywhere in the tree (also as claimed).

All of handoff v15's "Key Signatures Verified" entries check out exactly:
`existential_transfer_from_nf` NFGameBridge:719 ✓, `nf_fraisse_compression` 2006 ✓,
`nf_agreement_monotone` NormalForm.lean:339 ✓, `nf_agreement_from_shared_nf` NormalForm.lean:291 ✓,
`interval_nf_types_depth_decrease` 1904 ✓, `interval_2var_nf_types` 1847 ✓,
`zone_match_witness` 2044 ✓.

### F5. game_transfer_at_depth approach (plan v16 Phase 2): TWO REAL GAPS found

(a) **`atom_agree_from_pointwise` (line 2216) — claim partially correct.** It DOES prove atom
agreement at arbitrary arity n (statement is `{n : Nat}`-generic; verified by reading the
theorem). BUT its hypothesis `h_nf` demands 1-var NF agreement **at ALL depths**
(`∀ i, ∀ k : Nat, ∀ nf, ...`), while zone matching provides agreement at one fixed depth k only
(monotonicity gives depths ≤ k, never > k). The proof body only uses `h_nf i 1`, so the lemma is
needlessly over-hypothesized — as stated it CANNOT be instantiated from zone-match data, and plan
v16's d=0 base case cannot call it without first restating it with a depth-1 (or depth ≥ 1)
hypothesis. Trivial to fix, but the plan does not notice it. **Confidence: HIGH.**

(b) **Hypothesis propagation FAILS — refuting the plan's step case as designed.**
`zone_match_witness` returns, for the new point, ONLY: matching depth-k 1-var NF and orderings
relative to the base pair (h_ux, h_xu, h_ut, h_tu — verified at lines 2060-2064). It gives NO
orderings between the new point and previously placed environment points. But
`game_transfer_at_depth`'s own IH (plan lines 718-722) requires `h_ord_env : ∀ i j, env_M i <
env_M j ↔ env_M' i < env_M' j` for the EXTENDED environment — i.e., orderings of w' vs every
earlier env point. The step case has no way to establish these from the stated hypotheses. This is
the sub-interval/arrangement problem in ordering form: placing w' in the correct gap among
{u', x', t'} is exactly what 1-var zone matching against the base pair cannot do. Moreover the
plan's `game_transfer_at_depth` statement carries NO interval data for env pairs, so even adding
`interval_splitting_zone_match` (depth-k version) would not let its induction close. The v16
Phase-1 blocker is therefore real, and it is correctly located — but it equally infects Phase 2 as
written. **Confidence: HIGH** (read directly from the signatures involved).

The plan text itself is evidence of unresolved design: lines 184-708 contain at least five
successive "Wait — this is still the same circularity" reversals before committing to a signature
that was never validated against (b).

### F6. Sorry sites and file state (Q6): VERIFIED

- `grep -n sorry` shows exactly 3 proof sorries in StaviCompleteness.lean: **2405, 2487, 2857** —
  matching all v14/v15/v16 handoff claims. No new sorries introduced. Working tree clean for
  `Theories/` (only specs/ files modified).
- `lean_goal` at 2405 reproduces the handoff's goal verbatim:
  `(∃ w', nf_eval_nf M' j' 4 (w'::u'::x'::t') sub_nf) ↔ (∃ w, nf_eval_nf M j' 4 (w::u::x::t) sub_nf)`
  with `hj : j' + 1 < k` in context.
- Line 2857: the ENTIRE body of `nf_exist_sf_guarded_backward` is one `sorry` — none of the
  4-step extraction proof (witness extraction, char_k typing, interval-guard data, bridge
  application) exists yet. Plan v16's Phase 3 estimate of 1 hour is optimistic given
  `nf_exist_sf_guarded_forward` (the template) is ~120 lines.
- Minor error in the code comment at 2855: it says "the bridge lemma is sorry'd
  (nf_2var_from_interval_data)" — in fact `nf_2var_from_interval_data`'s own proof is complete;
  the sorryAx it carries comes from consuming `nf_2var_existential_transfer`.

### F7. Cross-handoff contradictions (Q5)

The "recommended approach" has oscillated A → B → B-strengthened(false) → A:

| Doc | Recommendation | Status under verification |
|-----|----------------|---------------------------|
| v14 | 2-var interval types + NF projection lemma (~370-510 lines) | Never attempted; consistent with GHR93; re-endorsed by v16 handoff as "approach 1" |
| v15 | 1-var interval-splitting, sub-interval agreement at depth **k-1** (~200-300 lines) | Never attempted AS STATED; plan v16 transcribed it at depth k instead (F3) |
| plan v16 | 1-var splitting at depth **k** + game_transfer_at_depth | Splitting refuted at k ≤ 1 (F2); game_transfer step case cannot propagate hypotheses (F5b) |
| v16 handoff | "Recommended: approach (2) depth-decreasing game" | Internally inconsistent: the same handoff shows approach 2's core step (intersection argument) yields only a superset, i.e. it is NOT a proof plan yet. Approach 1 is the one its own "Literature Connection" section supports |

Other handoff claims spot-checked and CORRECT: v14's "arity escalation problem", v14/v16's
infrastructure line numbers (1847, 2006, 2044, 2216), v15's five failed-approach catalogue
(consistent with the code's lack of any induction structure on j — the outer quantifier is just
`intro j hj chi`, line 2292), "no code changes made" in v14/v15/v16 (git tree clean).

---

## Recommended Approach (Critic's synthesis)

1. **Treat approach 1 (2-var interval types, per GHR93 decomposition formulas) as the primary
   candidate.** It is the only approach that (i) matches the literature (GHR93 Prop 7 + Lemma 11,
   where decomposition formulas inherently carry 2-var information), (ii) was independently
   recommended in two non-adjacent cycles (v14 and v16-handoff), and (iii) has no verified-false
   intermediate lemma. Its known costs: NF projection lemma (v14's roadmap), hypothesis
   propagation through `nf_2var_transfer` and `nf_exist_sf_guarded_backward`, and — the
   **unassessed and possibly dominant cost** — constructing a Stavi temporal formula that detects
   2-var NF types in intervals (the analogue of `interval_guard_sf`). No handoff has scoped that
   formula construction; research it BEFORE committing to approach 1.
2. **If approach 2 (depth-decreasing) is pursued, state the splitting lemma at depth k-1 (v15's
   original form), never at depth k.** The depth budget closes (F3). But require a proof sketch of
   the depth-(k-1) splitting lemma from 1-var data before planning around it — the v16 handoff's
   own analysis shows the naive argument fails, and it may simply be false too.
3. **Fix `atom_agree_from_pointwise`'s hypothesis** (depth-1 instead of ∀-depth) in any plan that
   uses it — currently uninstantiable from zone-match data (F5a).
4. **Any game-style transfer theorem must carry, in its OWN hypotheses, whatever pairwise data
   (orderings + interval/2-var data vs all env points) its step case must hand to the IH** (F5b).
   This is the structural test every prior plan failed; apply it to any new statement before
   implementation starts.
5. **Re-run the cone metaprogram (F1) after any change** — it is cheap and gives exact root-sorry
   accounting, immune to the `lean_verify` private-name pitfall.

## Evidence / Examples

- Cone metaprogram + output: see F1 (run via `lake env lean` on a temp file importing
  `Bimodal.Metalogic.BXCanonical.Completeness`).
- `lean_goal` at StaviCompleteness.lean:2405: 4-var transfer goal with `hj : j' + 1 < k`,
  hypotheses include only h_ux/h_xu/h_ut/h_tu orderings for u' (no env-pair data) — supports F5b.
- `zone_match_witness` conclusion (lines 2060-2064): NF equality + 4 ordering biconditionals
  relative to x',t' only.
- `atom_agree_from_pointwise` hypothesis (lines 2219-2222): `∀ i, ∀ k : Nat, ∀ nf, ...` — supports F5a.
- `nf_2var_from_interval_data` body (lines 2570-2571): `nf_fraisse_compression k 2 ... h_atom_agree
  (nf_2var_existential_transfer ...)` — the legal, non-circular combination.
- Counterexample arithmetic for k = 0, 1, 2: see F2.
- v15 lines 42-43 vs plan v16 lines 141-142: depth k-1 vs depth k — supports F3.

## Confidence Summary

| Finding | Confidence |
|---------|------------|
| F1 single root sorry (`nf_exist_sf_guarded_backward`) | HIGH (proof-term cone, machine-checked) |
| F2 counterexample valid at k=0; needs padding at k=1; excluded at k≥2 | HIGH / MEDIUM-HIGH / HIGH |
| F2 same-depth lemma likely false at k≥2 (no concrete counterexample) | MEDIUM |
| F3 v15→v16 depth transcription error (k-1 became k) | HIGH |
| F4 circularity real at signature level; absent from committed code | HIGH |
| F5a atom_agree_from_pointwise ∀-depth hypothesis gap | HIGH |
| F5b game_transfer_at_depth cannot propagate env orderings | HIGH |
| F6 line numbers 2405/2487/2857 current; no new sorries | HIGH |
| F7 recommendation oscillation; approach-1 preference | MEDIUM (judgment call) |
