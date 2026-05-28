# Literature Analysis: How GHR93 Handles Interval Splitting

**Task**: 155 (reynolds_pipeline_activation)
**Date**: 2026-05-28
**Focus**: Determine how GHR93 resolves the sub-interval splitting problem in the bridge lemma

---

## 1. GHR93's Decomposition Data: 1-var Types (Same as ours)

GHR93 Definition 8.8 / Ch.12 Definition 12.8.10 defines the n;r-decomposition formula. It includes:

**(a)** For each element t in the configuration: rank-r type formulas θ(t) — predicates, temporal formulas of rank ≤ r. This is **1-var type data** (equivalent to our `interval_nf_types` / `rank_type`).

**(b)** For each pair of adjacent elements a < b: `μ(z) ∧ a < z < b → X_{(a,b)}(z)` — for every actual point z between a and b, z has one of the types in X_{(a,b)}. This is the **interval type** — a set of 1-var rank-r types realized in the interval.

GHR93 text (p. 112, line 644 of ch12.md):
> "If t < u in M_r, define X_{(t,u)} to be ∨_{v ∈ (t,u)} X_v. Again the disjunction is effectively finite, so that X_{(t,u)} can be taken to be a formula of rank r. Note that only non-gaps contribute to the disjunction."

**Conclusion**: GHR93's decomposition uses **1-var interval types**, the same as our `interval_nf_types`. NOT 2-var types.

---

## 2. How GHR93 Handles Sub-Interval Splitting: Via the GAME

GHR93 **never derives sub-interval types from full-interval types directly**. Instead, it uses the EF game as an intermediary.

### Lemma 11 (Game ↔ Decomposition)

Lemma 11 (p. 113 / line 660) states:
> Game winning G_{n;r}(M, xy; N, x'y') ⟺ decomposition formula agreement

**Proof of (2)⟹(1)** (decomposition ⟹ game): Spoiler picks a_1,...,a_n. Construct the decomposition formula Ψ encoding ALL data: types at each a_i, AND interval types X_{(a_i, a_{i+1})} for ALL adjacent pairs. Since M_r ⊨ Ψ(x,y) and decomposition agreement gives N_r ⊨ Ψ(x',y'), the existential witnesses e_i come with **sub-interval types already matched**.

**Key**: The decomposition formula Ψ **packages the sub-interval types into a single first-order formula**. The existential quantifiers in Ψ produce witnesses that satisfy ALL constraints simultaneously — including sub-interval type matching. The sub-interval splitting is handled by the **first-order witnessing**, not by a separate derivation.

### Proposition 12.8.18 (Composition Lemma)

When Spoiler picks a new point a between x_i and x_{i+1} (p. 116 / line 708):

1. Duplicator uses the **forward game** G_{f(n+1), r}(M, x_i x_{i+1}; N, y_i y_{i+1}) to find e corresponding to a
2. But she doesn't just match a — she first computes ALL the decomposition formulas φ_s for (x_i, a) and ψ_s for (a, x_{i+1})
3. She plays the forward game with ALL witnesses for these decomposition formulas (at most f(n+1) points)
4. The game's winning condition guarantees: N_r ⊨ φ_s(y_i, e) AND N_r ⊨ ψ_s(e, y_{i+1})
5. By Lemma 11: these decomposition agreements give forward game strategies for the SUB-intervals
6. By Theorem 12.8.15: forward strategies give backward strategies

**Key**: The high-rank forward game (rank f(n+1), which is much larger than r) has enough rounds to match not just the point a, but the **entire decomposition structure** around a. This automatically provides sub-interval type matching.

---

## 3. Why Direct NF Induction Fails (and GHR93 Doesn't Try It)

GHR93 proves Lemma 11 using the GAME, not by induction on formula depth or NF depth. The bridge between decomposition data and NF agreement goes:

```
Decomposition data → (package into Ψ) → First-order witnessing → Game winning → NF agreement
```

The Lean code's `nf_2var_from_interval_data` tries a SHORTCUT:

```
Decomposition data → (direct induction on k) → NF agreement
```

This shortcut fails because NF induction at depth k+1 requires sub-interval data at depth k, which the hypotheses don't provide. GHR93 avoids this by going through the game.

---

## 4. What the Lean Code Already Has

### Decomposition.lean (sorry-free)
- `decomposition_agreement`: Semantic content of decomposition formula agreement ✓
- `ghr93_game_implies_decomposition`: Game winning → decomposition agreement ✓
- `ghr93_decomposition_implies_game`: Decomposition agreement → game winning ✓
- Both directions of Lemma 11 are proved ✓

### Missing Bridge
- **No theorem connecting**: bridge hypotheses (1-var NFs + ordering + interval_nf_types) → `decomposition_agreement`
- **No theorem connecting**: `decomposition_agreement` → `nf_characteristic` equality (NF agreement)

---

## 5. The Correct Resolution Path

Following GHR93, the bridge lemma should be proved as:

### Step 1: Bridge hypotheses → decomposition_agreement at n=0

The bridge hypotheses (1-var NF agreement at endpoints, ordering, interval types, above/below types) are exactly the semantic content of a 0;k-decomposition. Show this implies `decomposition_agreement M N atomMap 0 k x y x' y'`.

This should be ~50-100 lines: the n=0 decomposition has no interior selections (n=0), so the forward/backward directions are vacuous for selections, and the point-challenge condition follows from the interval type matching.

### Step 2: decomposition_agreement at n=0 → game winning at appropriate depth

By `ghr93_decomposition_implies_game` (already sorry-free): decomposition_agreement at n=0 gives `ghr93_duplicator_wins` at n=0 rounds.

### Step 3: Game winning → rank_type agreement → NF agreement

Game winning at rank r with 0 rounds gives formula agreement at rank r between endpoints. Combined with game winning at higher rounds (via Lemma 11 + composition), this gives formula agreement at all depths ≤ r. This implies `rank_type` agreement, which implies NF agreement.

The missing piece: a theorem `rank_type_agreement_implies_nf_agreement` connecting `rank_type` (Set StaviFormula agreement) to `nf_characteristic` (NormalForm equality). This requires the Stavi normal form theorem: every depth-k StaviFormula is equivalent to some NormalForm, and vice versa.

### Alternative Step 3: Game winning → NF agreement directly

If the Stavi connection is complex, use the game directly: game winning at n=k rounds at rank r means Duplicator can match k witnesses while preserving rank-r formula agreement. By induction on k, this gives 2-var NF agreement at depth k. This IS the Fraissé theorem, and the proof goes through because the GAME handles sub-interval matching internally.

---

## 6. Recommendation

**Do NOT try to prove `nf_2var_from_interval_data` by NF induction.** GHR93 doesn't do this, and 5 sessions have confirmed it doesn't work.

**Instead, follow GHR93's architecture**:

1. **Bridge hypotheses → decomposition_agreement** (~50-100 lines)
   - Package 1-var NFs + ordering + interval types into the decomposition format
   
2. **decomposition_agreement → game winning** (already done: `ghr93_decomposition_implies_game`)

3. **Game winning → NF agreement** (~100-200 lines)
   - Either via rank_type → NF connection
   - Or directly via game induction (Fraissé theorem)

**Total new infrastructure**: ~150-300 lines, going THROUGH the game rather than around it.

This is exactly how GHR93 works: decomposition data → game → NF agreement. The game handles sub-interval splitting internally because the game's round structure naturally propagates decomposition data to sub-intervals.

---

## 7. Why `interval_2var_nf_types` Is Not Needed

The proposed enrichment to 2-var interval types is an attempt to encode sub-interval data WITHOUT going through the game. This is unnecessary because:

1. GHR93 uses 1-var interval types (same as current `interval_nf_types`)
2. Sub-interval splitting is handled by the GAME, not by enriched types
3. The existing game infrastructure (Decomposition.lean) is sorry-free and provides exactly the tools needed

The enrichment would be a deviation from GHR93 that adds complexity without solving the root issue. The root issue is: the proof tries to avoid the game. The fix is: go through the game.
