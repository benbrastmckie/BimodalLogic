# Teammate A Findings: GHR93 Proposition 7 Game-Theoretic Proof Structure

- **Task**: 273 - chronicle_gap_contradiction_proof
- **Angle**: Exact mathematical structure of GHR93 Prop 7 (= GHR94 Prop 12.8.18) and its fit with plan v16's `game_transfer_at_depth`
- **Sources read**:
  - `literature/Gabbay_Hodkinson_Reynolds_1994_Temporal_Logic_Foundations_Vol1_ch12.md` (clean transcription; Defs 12.8.8-12.8.17, Lemmas 12.8.12/12.8.14, Thm 12.8.15 full proof, Props 12.8.16/12.8.18, Cor 12.8.19)
  - `literature/Gabbay_Hodkinson_Reynolds_1993_Temporal_expressive_completeness_gaps.md` (Prop 7 lines 1293-1340; identical content, noisier OCR)
  - `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean` (lines 1813-2060, 2240-2580, 2620-2860)
  - `specs/273_chronicle_gap_contradiction_proof/plans/16_interval-zone-match-plan.md`

---

## Key Findings

### Finding 1: The exact proof architecture of GHR94 12.8.18 (= GHR93 Prop 7)

The proof is a three-component engine; Prop 12.8.18 is only the outer loop.

**Statement** (GHR94 ch12, lines 690-704): For all n, for ARBITRARY m, if for every ADJACENT pair (x_i, x_{i+1}) / (y_i, y_{i+1}) (including the end zones with x_0 = -inf, x_{m+1} = +inf) Duplicator has winning strategies for the two-round interval games in BOTH directions

```
G_{f(n),g(n)}(M, x_i x_{i+1}; N, y_i y_{i+1})  and  G_{f(n),g(n)}(N, y_i y_{i+1}; M, x_i x_{i+1})
```

then Duplicator wins the n-round EF game G^n((M, x-bar), (N, y-bar)).

**Proof structure** (lines 706-720), induction on n with m FREE:

1. Spoiler plays a with x_i < a < x_{i+1}.
2. Duplicator lists ALL the [1+3f(n)];r-decomposition formulas phi_s(u,v) true of (x_i, a) and all psi_s(u,v) true of (a, x_{i+1}) in M, where r = g(n) + 4f(n).
3. She collects the existential witnesses of ALL these decomposition formulas, plus a itself — at most (1+3f(n))(j+k)+1 <= f(n+1) points — and plays this entire batch as the first move of the SINGLE two-round game G_{f(n+1),r}(M, x_i x_{i+1}; N, y_i y_{i+1}) on the full interval. Her winning strategy returns a batch of responses; e is the response corresponding to a.
4. Because the strategy is winning, the responses witness the same decomposition formulas in N: N_r |= phi_s(y_i, e) and N_r |= psi_s(e, y_{i+1}). By **Lemma 12.8.14** (decomposition formulas exactly characterize the two-round interval games), Duplicator now has winning strategies for the FORWARD games on both new sub-intervals: G_{1+3f(n),r}(M, x_i a; N, y_i e) and G_{1+3f(n),r}(M, a x_{i+1}; N, e y_{i+1}).
5. "Crucially, by **theorem 12.8.15**" (the game-inversion theorem (*)_n: forward at (1+3n, r+4n) implies backward at (n, r)) she also gets the BACKWARD games G_{f(n),g(n)}(N, y_i e; M, x_i a) and G_{f(n),g(n)}(N, e y_{i+1}; M, a x_{i+1}).
6. The invariant is now re-established for the (m+1)-tuple (x-bar, a)/(y-bar, e) at index n. The inner induction hypothesis (at n, arity m+1) finishes the game.

**Where the interval-game hypotheses come from in the application** (Cor 12.8.19, line 722-724): the application has **m = 1** — a single distinguished point x. The only adjacent intervals are the END ZONES (-inf, x) and (x, +inf), and **Prop 12.8.16** supplies the games for those from the 1-var temporal type of x alone: if x, y satisfy the same temporal formulas of rank r+4n+1, Duplicator wins G_{n,r}(M, -inf x; N, -inf y) and G_{n,r}(M, x inf; N, y inf). The mechanism is the nested formula family (line 686):

```
C_n = X_{a_n} /\ ~U(~X_{(a_n, inf)}, T),    C_i = X_{a_i} /\ U(C_{i+1}, X_{(a_i, a_{i+1})})
```

i.e., a NESTED Until chain that encodes the full n-point ARRANGEMENT (marked-point types X_{a_i} AND per-segment filler constraints X_{(a_i,a_{i+1})}), all folded into the single-point rank-(r+4n+1) type of x.

**Confidence: HIGH** (direct quotation from clean transcription; GHR93 Prop 7 text verified identical).

### Finding 2: How arity escalation is avoided — uniformity via a pairwise-local invariant

The answer to research question 1: the induction is on n (rounds remaining / quantifier depth) with arity m universally quantified INSIDE the statement ("for arbitrary m < omega"). Arity grows by exactly 1 per round and the game lasts exactly n rounds, so arity is bounded by m_initial + n. There is no induction on arity anywhere.

What makes this work is that the maintained invariant is **pairwise-local**: it mentions only ADJACENT pairs of the current configuration, never the whole tuple. This is sufficient because:

- predicate atoms are 1-point properties (carried by each point's type, preserved because every Duplicator response satisfies the same rank-r formulas as Spoiler's point);
- order atoms between non-adjacent points follow from adjacency placement plus transitivity;
- the data needed to place the NEXT point inside any one interval is carried entirely by that interval's two-round game invariant.

The per-round bookkeeping (Definition 12.8.17) is: round budget f(n+1) >= (1+3f(n))(2k_n)+1 and rank budget g(n+1) >= g(n)+4f(n), where k_n = number of inequivalent decomposition formulas at level n. The budgets shrink as the game proceeds; the invariant at level n is re-established at level n-1 after each round. **Duplicator's strategy is uniform across arities precisely because the invariant never quantifies over the tuple as a whole.**

This CONFIRMS the core idea of plan v16's `game_transfer_at_depth` (induction on depth d with arity n free, d decreasing and arity growing by 1 per step, base case d=0 = atoms for any arity). The skeleton is GHR-faithful. The hypotheses are not (Finding 4).

**Confidence: HIGH**.

### Finding 3: What decomposition formulas encode, vs `interval_nf_types` and `interval_2var_nf_types`

**Definition 12.8.13(2)** (lines 646-654): an n;r-decomposition formula is

```
psi(x1, x2) = EXISTS y1..yn [x1 < y1 < ... < yn < x2  /\  FORALL x  chi]
```

where chi conjoins (a) rank-<=r 1-var type assertions theta(t) at each marked point y_i and at the endpoints, and (b) **per-segment filler constraints**: for each ADJACENT pair (a,b) in the sequence x1 y1 ... yn x2, a clause `u(x) /\ a < x < b -> B(x)` constraining ALL points of that sub-segment to a rank-<=r type disjunction B.

So a decomposition formula encodes a full ARRANGEMENT: an ordered sequence of n marked types together with the set of types allowed in each of the n+1 sub-segments. **Lemma 12.8.14** proves these formulas exactly characterize the two-round interval game G_{n,r}: agreement on all n;r-decomposition formulas <-> Duplicator wins the forward game.

Comparison with the formalization's invariants:

| Invariant | What it encodes | GHR analogue |
|---|---|---|
| `interval_nf_types M k lo hi` (line 1835) | SET of 1-var depth-k types realized in (lo,hi); no arrangement, no fillers | strictly weaker than even 1;k-decomposition formulas (those add per-segment fillers around the single mark) |
| `interval_2var_nf_types M k lo hi` (line 1847) | SET of 2-var depth-k NFs of (u, hi) for u in (lo,hi) | each element coordinates u with ONE endpoint (hi) only, and the SET still loses cross-witness coordination; roughly 1-mark decomposition data relative to hi with depth-graded fillers |
| 2-var depth-d NF of the pair (lo,hi) itself | quantifier part enumerates exactly which 3-var depth-(d-1) NFs (w,lo,hi) are realizable, i.e., COORDINATED one-point-extension data, recursively graded in depth | the faithful analogue of "Duplicator wins the two-round games on (lo,hi) in both directions" |

The key observation: in the Hintikka-NF framework the project uses (`nf_fraisse_compression` shows `NormalForm sig k n` is a standard FO Hintikka normal form: depth-(k+1) quant part = set of realizable (n+1)-var depth-k NFs), **the 2-var NF of the pair is itself the decomposition data**. Its quantifier part gives coordinated placement of one new point relative to BOTH endpoints at one lower depth; unfolding recursively gives multi-point arrangements, exactly as GHR's nested C_i formulas do. Neither `interval_nf_types` (1-var sets) nor `interval_2var_nf_types` (2-var sets) is the right primary invariant; `interval_2var_nf_types` is closer but still a set-of-types abstraction that discards the coordination GHR's batched-witness move (Finding 1, step 3) depends on.

This explains precisely why Phase 1 of plan v16 found `interval_splitting_zone_match` to be FALSE for `interval_nf_types`: the 1-var type set is the (filler-free, 1-mark) fragment of decomposition data, and GHR's proof never attempts to split intervals using type sets — it splits using batched decomposition witnesses inside a single coordinated game (one game on the WHOLE interval whose winning strategy answers all witnesses simultaneously, which is what keeps the two sub-intervals consistent with each other).

**Confidence: HIGH** for the GHR reading; **MEDIUM-HIGH** for the claim that pair-2-var-NF is the correct NF-internal analogue (it follows from the Hintikka structure of `NormalForm`, verified against `nf_fraisse_compression` at line 2006, but I have not machine-checked a projection lemma — see Finding 5).

### Finding 4: Plan v16's `game_transfer_at_depth` — skeleton correct, hypotheses insufficient

Answers to research question 3, point by point:

1. **Is zone matching at each depth step sufficient?** No. `zone_match_witness` (line 2044) delivers a point u' with matching 1-var depth-k NF and matching zone/orderings. GHR's Duplicator delivers strictly more: after her round, BOTH new sub-intervals carry full two-round-game invariants in BOTH directions (Finding 1, steps 4-5). In NF terms, placing w into interval (p_i, p_{i+1}) must produce **3-var depth-(d-1) NF agreement for (w, p_i, p_{i+1}) / (w', p'_i, p'_{i+1})**, not merely 1-var NF + orderings. The proposed signature in plan v16 (lines 710-733) carries only: bridge hypotheses for the BASE pair (x,t), pairwise 1-var depth-k NFs for env points, and pairwise orderings. After the first round, the new point w sits in some sub-interval between env points; placing the NEXT point inside that sub-interval requires arrangement data for it — which the signature does not carry and cannot reconstruct (this is the Phase-1 counterexample recurring one level down). **The invariant must be upgraded to adjacent-pair 2-var NF agreement at the current depth.**

2. **Is the arity growth bounded?** Yes, and this part of v16 is exactly right. The game runs at most d rounds (depth d down to 0); arity is bounded by initial arity + d. GHR's "for arbitrary m" in Prop 12.8.18 is the same device. No issue here.

3. **Is `interval_splitting_zone_match` still needed?** No — and it should be abandoned. In the corrected formulation, interval splitting is not a separate Finset-partition lemma; the splitting is DELIVERED by the quantifier part of the adjacent pair's 2-var depth-d NF: that quant part says exactly which 3-var depth-(d-1) NFs (w, p_i, p_{i+1}) are realizable, and realizing the same 3-var NF on the other side automatically makes both sub-pairs (p_i, w) and (w, p_{i+1}) agree on their 2-var depth-(d-1) NFs (by projection). GHR's analogue of this bypass is steps 3-5 of Finding 1: a SINGLE game on the whole interval, not two separate type-set splittings.

**Answer to research question 4 (what does the invariant actually need?):** GHR's invariant per adjacent pair is "both-direction two-round games at level (f(n), g(n))" = agreement on all f(n);g(n)-decomposition formulas. The pairwise 1-var NF + orderings + base-pair interval-type-sets + above-max/below-min of plan v16 is NOT sufficient. The NF-internal sufficient invariant is:

```
I(d, config): configurations order-isomorphic, and for every adjacent pair
(p_i, p_{i+1})/(p'_i, p'_{i+1}) including implicit end zones:
  nf_characteristic M d 2 (p_i, p_{i+1}) = nf_characteristic M' d 2 (p'_i, p'_{i+1})
(end zones are covered by 1-var depth-d NF agreement of the extreme points,
since the 1-var NF quant part quantifies over the whole domain including
points above/below).
```

**Confidence: HIGH** that v16's hypothesis set is insufficient (follows from the Phase-1 counterexample plus the GHR proof structure); **HIGH** that I(d) as above supports the round step (it is the Hintikka unfolding, one depth unit per round, cheaper than GHR's 4f(n)-rank cost because Hintikka NFs are FO-graded while GHR pays for the temporal-to-FO translation).

### Finding 5: The corrected master lemma (Hintikka form of Prop 12.8.18) and its proof obligations

**Master lemma** (recommended replacement for `game_transfer_at_depth`): by strong induction on d, with m free:

```
For all m, all order-isomorphic configs p_1 < ... < p_m in M, p'_1 < ... < p'_m in M':
if every adjacent pair agrees on its 2-var depth-d NF
   (and the extreme points agree on 1-var depth-d NFs),
then nf_characteristic M d m p-bar = nf_characteristic M' d m p'-bar.
```

Proof sketch per round (the analogue of GHR's round in Finding 1):
- d = 0: atoms. Predicates from per-point 1-var data (projections of pair NFs); orders from order-isomorphism. Matches v16's base case.
- d+1: atoms as above. Quantifier part: given chi : NormalForm sig d (m+1) and a witness w with p_i < w < p_{i+1} (or w in an end zone, or w equal to some p_i):
  1. The pair (p_i, p_{i+1}) has equal 2-var depth-(d+1) NFs; the quant part of that NF yields w' with the 3-var depth-d NF of (w', p'_i, p'_{i+1}) equal to that of (w, p_i, p_{i+1}). The order atoms inside that 3-var NF put w' strictly inside (p'_i, p'_{i+1}); position relative to all other p'_j follows by transitivity.
  2. New adjacent pairs (p_i, w), (w, p_{i+1}): their 2-var depth-d NFs agree, by **projection** from the 3-var depth-d NF agreement.
  3. Old adjacent pairs: depth-(d+1) agreement gives depth-d agreement by `nf_char_depth_decrease` (exists, line 1857).
  4. End-zone w (w above all p's or below all): use the quant part of the extreme point's 1-var depth-(d+1) NF the same way (it includes order atom w vs p_m).
  5. Apply the IH at depth d to the (m+1)-configuration; conclude the (m+1)-tuple depth-d NFs agree; chi transfers by `nf_agreement_from_shared_nf`/`nf_eval_unique`.

No circularity: the IH is at strictly smaller d with arity free, exactly GHR's induction. This dissolves the v15 circularity AND the v16 Phase-1 blocker simultaneously, because the sub-interval arrangement data is never assumed — it is produced by step 1 and consumed at one lower depth.

**New infrastructure required**:
- **NF projection/restriction lemma** (the one genuinely new nontrivial lemma): the depth-d n-var NF of a tuple determines the depth-d NF of any sub-tuple (specifically: 3-var depth-d NF agreement of (w,a,b)/(w',a',b') implies 2-var depth-d agreement of (a,w)/(a',w'), (w,b)/(w',b'), and 1-var agreement of components). For Hintikka NFs this is standard but requires an induction on d against the `NormalForm` quant-part definition. Estimate 150-300 lines.
- The master lemma itself, with configuration bookkeeping over `Fin m` ordered tuples. Estimate 250-450 lines. The "insert into sorted tuple" Fin manipulation is the main Lean pain point (plan v16's own troubleshooting note about Fin.append applies).

**Confidence: MEDIUM-HIGH** on provability of the master lemma as stated (mathematically it is the textbook EF/Hintikka argument; the literature confirms the round structure; Lean-level risk is concentrated in the projection lemma and tuple bookkeeping).

### Finding 6 (CRITICAL, scope-affecting): the entry-point hypotheses and the third sorry site do not match GHR

Two structural mismatches sit UPSTREAM of the sorry sites and limit what any version of the game lemma can achieve:

**(a) `nf_2var_existential_transfer` / `nf_2var_from_interval_data` hypotheses are GHR-unfaithful for bounded intervals.** The hypotheses provide 1-var depth-k NFs of x,t + ordering + `interval_nf_types` at depth k + above/below sets. In GHR, 1-var single-point data yields interval games ONLY for end zones (Prop 12.8.16); the application Cor 12.8.19 has m = 1 so no bounded interval ever needs to be seeded from 1-var data. There is NO GHR result deriving the bounded-interval games for (x,t) from 1-var endpoint types + type SETS, and the Phase-1 counterexample shows why (arrangement loss). Even with the corrected master lemma, the top round (j = k-1, only one unit of depth slack) cannot start from these hypotheses: the master lemma needs 2-var depth-(j+1) NF agreement of (x,t), i.e., for j = k-1 the full 2-var depth-k agreement — which is the bridge lemma's CONCLUSION. With MORE slack (j+1 < k) one can attempt mutual recursion (bridge at depth j+1 from transfer at depths < j+1), but the top depth j = k-1 remains out of reach from 1-var + type-set data. The bridge lemma `nf_2var_from_interval_data` is therefore likely UNPROVABLE (and possibly false) as stated at full depth k. **Confidence: MEDIUM-HIGH** (the unprovability-as-stated follows from the counterexample pattern; outright falsity at every k would need a concrete model pair, which the Phase-1 analysis already sketched for the splitting variant).

**(b) `nf_exist_sf_guarded` (line 2656) encodes far less than a decomposition formula, so the backward direction (sorry at 2857) is very likely false as stated.** Inspection of the definition shows: for the x < t / t < x cases the formula is a single `U`/`S` whose witness disjunct constrains ONLY the predicate atoms of x (`atom_compat` compares `.pred` entries only; the disjunction then ranges over ALL atom-compatible 1-var types) and whose guard is `interval_guard_sf` — the disjunction of ALL depth-k types, i.e., **trivially true** (proved so by `interval_guard_sf_true`, line 2637). Consequently the map sub_nf -> formula discards sub_nf's entire quantifier part: two 2-var NFs differing only in quant part (e.g., "some point between x and t satisfies P" vs not, at k = 1) produce the SAME formula, yet in a model realizing only the second, the formula is true while `∃x, nf_eval ... sub_nf1` is false. A GHR-faithful existence formula must be (a Stavi translation of) a decomposition-formula family: a disjunction over arrangement patterns, each rendered as NESTED U/S in the style of Prop 12.8.16's C_i chain — marked-point types via char_k and PER-SEGMENT filler disjunctions, with enough marked points to pin sub_nf (GHR's f/g budget governs how many). **Confidence: HIGH** that the current formula under-determines sub_nf (read directly off the definition); **MEDIUM** on the exact counterexample details (not machine-checked).

Implication: closing the three sorries is not a matter of finishing `game_transfer_at_depth` with the current hypotheses. The GHR-faithful path requires (i) the master lemma (Finding 5), (ii) replacing the interval-type-set hypotheses by pair-2-var-NF agreement where the bridge is consumed, and (iii) strengthening `nf_exist_sf_guarded` to a decomposition-style formula whose backward direction is proven via (i). Item (iii) is where GHR's Prop 12.8.16 / Thm 12.8.15 content (nested-Until decomposition encodings; the only place the Stavi connectives and gap cases I-IV genuinely matter) enters the formalization.

## Recommended Approach (concrete formalization strategy)

1. **Prove the NF projection lemma** (sub-tuple restriction of Hintikka NFs), by induction on depth. This is reusable and unblocks everything else.
2. **Prove the master lemma of Finding 5** (`nf_tuple_agreement_from_adjacent_pairs`, strong induction on d, arity free, adjacent-pair 2-var depth-d NF invariant). This replaces both `game_transfer_at_depth` and `interval_splitting_zone_match` from plan v16. Do NOT route through `interval_nf_types` Finsets.
3. **Rebase the sorry sites at 2405/2487**: within `nf_2var_existential_transfer`, the master lemma needs 2-var depth-(j+1) NF agreement of (x,t) for j+1 <= k. Restate the theorem (or add a variant) taking `h_nf_xt : nf_characteristic M k 2 (x,t) = nf_characteristic M' k 2 (x',t')` as hypothesis instead of the interval-type-set hypotheses; the transfer at all j < k then follows from the master lemma + monotonicity, in ~50 lines, with no game machinery at the call site.
4. **Re-derive the bridge data at the consumers**: audit who must supply `h_nf_xt`. For `nf_exist_sf_guarded_backward` (sorry at 2857) this forces the formula upgrade of Finding 6(b): replace the vacuous guard with a decomposition encoding (disjunction over arrangement patterns; nested std_untl/std_snce with per-segment filler disjunctions of char_k types). Prove its backward direction by the master lemma applied to the m = 1 / end-zone style argument of Prop 12.8.16 (depth slack of the char formulas pays for the marked points, one depth unit per point in the NF world).
5. **Treat GHR's f/g budget as simplified in the NF setting**: because `NormalForm` is FO-Hintikka-graded (not temporal-rank-graded), one EF round costs exactly 1 depth unit, not 4f(n) rank; the f(n) witness-count blowup reappears only in step 4 (number of marked points in the decomposition patterns), not in the master lemma.
6. If step 4's formula upgrade exceeds the task budget, mark the task [BLOCKED] for user review with this analysis rather than attempting further variants of zone matching at the current hypothesis strength — sixteen plan iterations have effectively enumerated the approaches that the GHR proof structure rules out.

## Evidence / Examples (key quotations)

- Prop 12.8.18 hypothesis is pairwise-adjacent and bidirectional: "Suppose that Exists has winning strategies for G_{f(n),g(n)}(M, x_i, x_{i+1}; N, y_i, y_{i+1}) and G_{f(n),g(n)}(N, y_i, y_{i+1}; M, x_i, x_{i+1}) for all 0 <= i <= m." (ch12 lines 692-704)
- The batched-witness round: "Let Exists choose witnesses for the existential quantifiers of each phi_s, psi_s, together with a, making at most n' = (1+3f(n))(j+k)+1 <= f(n+1) points in (x_i, x_{i+1})_r in all. She now applies her winning strategy for G_{f(n+1),r}(M, x_i x_{i+1}; N, y_i y_{i+1})." (ch12 line 710)
- Game inversion is what re-establishes the backward half of the invariant: "Crucially, by theorem 12.8.15, she also has winning strategies for G_{f(n),g(n)}(N, y_i e; M, x_i a) and G_{f(n),g(n)}(N, e y_{i+1}; M, a x_{i+1})." (ch12 lines 710-716)
- Decomposition formulas carry arrangement + fillers: clauses "(b) u(x) /\ a < x < b -> B(x), where a < b are adjacent elements of the sequence x1 y1 ... yn x2" (ch12 line 654); Lemma 12.8.14 equates them with the two-round games (lines 658-668).
- 1-var data seeds only end zones, with depth slack, via nested Untils: Prop 12.8.16 and "C_i = X_{a_i} /\ U(C_{i+1}, X_{(a_i, a_{i+1})}) ... rank(C_0) <= r + 4n + 1" (ch12 line 686). The application has m = 1 (Cor 12.8.19, line 722).
- The codebase's `interval_guard_sf` is provably vacuous: `interval_guard_sf_true` holds for every point of every model (StaviCompleteness.lean lines 2637-2652), so the guard contributes no constraint in the backward direction.
- The Hintikka structure of `NormalForm` (quant part = set of realizable (n+1)-var depth-(k-1) extensions) is visible in `nf_fraisse_compression` (lines 2006-2038), licensing the 1-depth-per-round accounting.

## Confidence Level Summary

| Finding | Confidence |
|---|---|
| 1. GHR proof architecture (batched witnesses, Lemma 12.8.14, Thm 12.8.15 inversion) | HIGH |
| 2. Arity uniformity via pairwise-local invariant; v16 d-induction skeleton is GHR-faithful | HIGH |
| 3. Decomposition formulas = arrangement + fillers; pair 2-var NF is the NF analogue; `interval_nf_types` strictly weaker | HIGH (GHR reading) / MEDIUM-HIGH (NF-analogue claim) |
| 4. v16 hypothesis set insufficient; corrected invariant = adjacent-pair 2-var NF agreement | HIGH |
| 5. Master lemma provable by induction on d (needs projection lemma) | MEDIUM-HIGH |
| 6a. Bridge lemma unprovable as stated at full depth k from 1-var + type sets | MEDIUM-HIGH |
| 6b. `nf_exist_sf_guarded` backward direction false as stated (vacuous guard, quant part dropped) | HIGH (under-determination) / MEDIUM (counterexample not machine-checked) |
