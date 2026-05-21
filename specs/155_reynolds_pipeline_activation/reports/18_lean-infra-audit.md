# Lean Infrastructure Audit: GHR93 Claim 1 (Infimum-Based d-Consistency)

**Date**: 2026-05-21
**Scope**: Audit of existing codebase for implementing infimum-based d-consistency

---

## 1. ExtendedCarrier Definition and Order Properties

### Type Definition

```lean
def ExtendedCarrier {sig : MonadicSignature} (M : OrderedMonadicStructure sig)
    (atomMap : Formula → sig.preds) (r : Nat) : Type :=
  M.carrier ⊕ RDefinableGap M atomMap r
```

Where `RDefinableGap M atomMap r = { g : Gap M.carrier // r_definable_gap M atomMap g r }`.

### Gap Structure (EFGames.lean lines 257-269)

```lean
structure Gap (T : Type) [LinearOrder T] where
  cut : Set T
  nonempty : cut.Nonempty
  proper : cut ≠ Set.univ
  downward_closed : ∀ x y, x ∈ cut → y ≤ x → y ∈ cut
  no_sup : ¬∃ s, IsLUB cut s ∧ s ∈ cut
  complement_no_min : ¬∃ m, m ∉ cut ∧ ∀ y, y ∉ cut → m ≤ y
```

### Order Properties

**Existing instances** (EFGames.lean lines 377-447):
- `extendedLinearOrder : LinearOrder (ExtendedCarrier M atomMap r)` -- FULLY PROVED

Ordering rules:
- `(.inl x, .inl y)`: inherits from M's order (`x ≤ y`)
- `(.inl x, .inr g)`: `x ∈ g.val.cut`
- `(.inr g, .inl x)`: `x ∉ g.val.cut`
- `(.inr g₁, .inr g₂)`: `g₁.val.cut ⊆ g₂.val.cut`

**Missing instances**:
- NO `ConditionallyCompleteLattice` on `ExtendedCarrier`
- NO `SupSet` / `InfSet` on `ExtendedCarrier`
- NO `CompleteLattice` on `ExtendedCarrier`
- NO infimum/supremum operations of any kind

### Key Helper Lemmas

| Lemma | File:Line | Status |
|-------|-----------|--------|
| `extendPoint_le_iff` | EFGames:478 | Proved |
| `extendPoint_lt_iff` | EFGames:1916 | Proved |
| `extendPoint_le_gap_iff` | EFGames:487 | Proved |
| `isPoint_or_isGap` | EFGames:464 | Proved |
| `point_between_strict_gaps` | EFGames:2478 | Proved |
| `gap_cuts_total` | EFGames:283 | Proved |
| `gap_ext` | EFGames:276 | Proved |

---

## 2. Infimum: Does Not Exist, Must Be Constructed

**Status: No infimum infrastructure exists on ExtendedCarrier.**

The only infimum-like infrastructure in the codebase is `Int.exists_least_above` in `Separation/IntHelpers.lean` (line 40), which is specific to integers and irrelevant to the general case.

### What Would Be Needed

For Claim 1, `d̄ = inf{t ∈ [x',y'] : N |= C(u) for all u ∈ (t,y')}`, we need:

1. **Define the infimum set**: `S = {t : ExtendedCarrier N atomMap r | inClosedInterval x' y' t ∧ ∀ u, t < u → u < y' → mu_holds u → stavi_temporal_truth_mu N atomMap r u C}`

2. **Prove S is non-empty**: Since `y'` is in `[x',y']` and the condition is vacuously true for u > y', the point y' itself (or something close) would need to be in S. This depends on whether C needs to hold at y' itself.

3. **Construct the infimum**: Either:
   - (a) Build `ConditionallyCompleteLattice` on `ExtendedCarrier` (heavy infrastructure)
   - (b) Use `sInf` on the set with classical choice (requires `sSup`/`sInf` instances)
   - (c) Use a custom infimum construction specific to the d-consistency context
   - (d) Avoid infimum entirely by restructuring the argument

### Why Approach (c) or (d) Is Preferred

Building a full `ConditionallyCompleteLattice` on `ExtendedCarrier` would require:
- Proving `sSup` exists for bounded-above nonempty sets
- Proving `sInf` exists for bounded-below nonempty sets
- These are NOT trivially derivable: `ExtendedCarrier` is `M.carrier ⊕ RDefinableGap`, and the gap type is indexed by definability conditions. Completeness depends on whether every descending chain of cut-sets converges to a cut-set that is still r-definable.

The r-definability constraint makes general completeness non-trivial. The specific infimum needed for d-consistency may be easier to construct directly.

---

## 3. SplitPointProps and How d Is Currently Defined

### SplitPointProps Structure (ExpressivenessGeneral.lean lines 137-173)

```lean
structure SplitPointProps {sig : MonadicSignature}
    {M N : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {r : Nat} (n : Nat)
    (x y : ExtendedCarrier M atomMap r)
    (x' y' : ExtendedCarrier N atomMap r)
    (c : ExtendedCarrier M atomMap r)
    (d : ExtendedCarrier N atomMap r)
    (a_bwd : Fin (n + 1) → ExtendedCarrier N atomMap r) where
  hc_interval : inClosedInterval x y c
  hd_interval : inClosedInterval x' y' d
  hd_eq_an : d = a_bwd ⟨n, by omega⟩     -- KEY: d is defined as Spoiler's last pick
  hxc : x ≤ c
  hcy : c ≤ y
  hx'd : x' ≤ d
  hdy' : d ≤ y'
  h_pt_xc : ∃ (p : M.carrier), inClosedInterval x c (extendPoint p)
  h_pt_cy : ∃ (p : M.carrier), inClosedInterval c y (extendPoint p)
  sigma : ghr93_duplicator_wins N M atomMap n r x' d x c
  tau : ghr93_duplicator_wins N M atomMap n r d y' c y
```

### Current Definition of d

In `obtain_split_point_props` (line 222):
```lean
let d := a_bwd ⟨n, by omega⟩
```

**d is simply Spoiler's last backward pick**. The field `hd_eq_an : d = a_bwd ⟨n, by omega⟩` is `rfl`.

### Where d Is Obtained

`obtain_split_point_props` (lines 202-551) constructs both c and d:
- **d = a_bwd(n)** (Spoiler's last pick, line 222)
- **c** comes from one of two cases:
  - If d is a point: c = extendPoint b where b is a Round 2 response (lines 476-531)
  - If d is a gap: sorry'd entirely (line 551)

---

## 4. Where d-Consistency Is Consumed

### Direct Sorry Locations

| Location | Type | Description |
|----------|------|-------------|
| ExpressivenessGeneral.lean:306 | `sorry` | `h_d_consistent_left`: for any padded selection ending in c, strategy response at position `1+3*n` equals d |
| ExpressivenessGeneral.lean:316 | `sorry` | `h_d_consistent_right`: for any padded selection starting with c, strategy response at position 0 equals d |

### Exact Signatures of d-Consistency Hypotheses

**Left** (line 297-306):
```lean
h_d_consistent_left : ∀ (a_pad : Fin (1 + 3 * n + 1) → ExtendedCarrier M atomMap r),
    (∀ i, inClosedInterval x y (a_pad i)) →
    a_pad ⟨1 + 3 * n, by omega⟩ = c →
    ∀ (a'_full : Fin (1 + 3 * n + 1) → ExtendedCarrier N atomMap r),
      (∀ i, inClosedInterval x' y' (a'_full i)) →
      (∀ (b' : N.carrier), inClosedInterval x' y' (extendPoint b') →
        ∃ (b : M.carrier), inClosedInterval x y (extendPoint b) ∧
          ghr93_winning_condition (1 + 3 * n + 1)
            (game_tuple x y a_pad b) (game_tuple x' y' a'_full b')) →
      a'_full ⟨1 + 3 * n, by omega⟩ = d
```

**Right** (line 307-316):
```lean
h_d_consistent_right : ∀ (a_pad : Fin (1 + 3 * n + 1) → ExtendedCarrier M atomMap r),
    (∀ i, inClosedInterval x y (a_pad i)) →
    a_pad ⟨0, by omega⟩ = c →
    ∀ (a'_full : Fin (1 + 3 * n + 1) → ExtendedCarrier N atomMap r),
      (∀ i, inClosedInterval x' y' (a'_full i)) →
      (∀ (b' : N.carrier), inClosedInterval x' y' (extendPoint b') →
        ∃ (b : M.carrier), inClosedInterval x y (extendPoint b) ∧
          ghr93_winning_condition (1 + 3 * n + 1)
            (game_tuple x y a_pad b) (game_tuple x' y' a'_full b')) →
      a'_full ⟨0, by omega⟩ = d
```

### How d-Consistency Is Consumed Downstream

These hypotheses are passed to `ghr93_strategy_restrict_left` and `ghr93_strategy_restrict_right` (EFGames.lean lines 2912 and 3146). The strategy restriction theorems use d-consistency to:

1. **Prove `hd_eq : a'_full ⟨n, by omega⟩ = d`** (line 2953): establishes that the N-side response at the boundary equals d, enabling index embedding transfer.
2. **Prove response containment** (line 2972): `a'_full(i) ≤ d` follows from same_order_type and hd_eq.
3. **Transfer winning condition** (lines 3050-3063): the index embedding maps boundary index to the d/c position.

---

## 5. Assessment of Effort to Implement Claim 1

### Claim 1 Statement (GHR93 p.28)

Define:
- `c = inf{t ∈ [x,y] : M |= C(u) for all u ∈ (t,y)}` (in M_r)
- `d̄ = inf{t ∈ [x',y'] : N |= C(u) for all u ∈ (t,y')}` (in N_r)

Claim: Any winning strategy response d to c must satisfy d = d̄.

### Effort Breakdown

**Option A: Full infimum construction on ExtendedCarrier**

| Component | Estimated Effort | Risk |
|-----------|-----------------|------|
| Define `sInf` / `sSup` on ExtendedCarrier | 200-300 lines | High: r-definability complicates completeness |
| Prove ConditionallyCompleteLattice instance | 300-500 lines | High: need to handle gap creation from infima |
| Define c, d̄ as infima | 50-100 lines | Medium |
| Prove d = d̄ from winning condition | 200-400 lines | Medium |
| **Total** | **750-1300 lines** | **High** |

**Option B: Custom infimum for the specific context (RECOMMENDED)**

Rather than building general completeness, construct the infimum directly for the specific set needed:

| Component | Estimated Effort | Risk |
|-----------|-----------------|------|
| Define the continuation formula C | 50-100 lines | Low: C is determined by rank_type and interval_types |
| Define S = {t ∈ [x,y] : C holds on (t,y)} as a downward-closed tail | 30-50 lines | Low |
| Show S has a natural infimum in ExtendedCarrier (either as a point via Zorn-like argument, or as a gap via the cut S itself) | 150-300 lines | Medium: need to show the cut is r-definable |
| Prove d̄ = inf of the corresponding N-side set | 100-200 lines | Medium |
| Prove d = d̄ using winning condition + type agreement | 200-400 lines | Medium |
| **Total** | **530-1050 lines** | **Medium** |

**Option C: Avoid infimum entirely (current approach, with restructuring)**

The current code defines d = a_bwd(n) and sorries d-consistency. An alternative:

| Component | Estimated Effort | Risk |
|-----------|-----------------|------|
| Show d = a_bwd(n) satisfies type agreement with c (already done for point case) | 0 lines | Done |
| Prove d-consistency: any winning response to c at the boundary must equal a_bwd(n) | 300-500 lines | HIGH: this IS the Claim 1 argument, just restated |
| **Total** | **300-500 lines** | **High: fundamentally requires Claim 1 reasoning** |

The problem with Option C is that it defers the hard part: proving d-consistency for d = a_bwd(n) essentially requires the same infimum argument, because you need to show that the strategy has no freedom at the boundary (the response is forced).

### Recommendation

**Option B** is the most tractable. The key insight: the infimum of the set S = {t : C holds on (t,y)} in ExtendedCarrier can be constructed as follows:

1. If `inf S` is achieved by a point, it is straightforwardly `extendPoint p` for the least p in M.carrier with the property.
2. If `inf S` is not achieved by any point, then `S ∩ M.carrier` defines a downward-closed set (gap cut), and `inf S` is the corresponding gap.
3. The gap is r-definable because C has depth ≤ r (it's defined by the rank_type and interval_types which are bounded by r).

This avoids general completeness and only constructs the specific infimum needed.

---

## 6. Lean Types/Lemmas Mapping to Each Step of Claim 1

### Step 1: Define the continuation formula C

**Needed**: A StaviFormula C of depth ≤ r that captures the type pattern at d.

**Existing infrastructure**:
- `rank_type M atomMap r t : Set StaviFormula` (EFGames.lean line 883) -- captures all formulas of depth ≤ r true at t
- `interval_types M atomMap r t u : Set (Set StaviFormula)` (EFGames.lean line 893) -- types realized in (t,u)
- `NormalForm sig k n : Type` (from NormalForm.lean) -- finitely many types exist
- `stavi_depth : StaviFormula → Nat` (EFGames.lean line 185)

**Gap**: Need to construct a single StaviFormula C whose truth characterizes a specific rank_type. This requires the normal form ↔ single formula translation from the NormalForm infrastructure.

### Step 2: Define c = inf of the C-set in M_r

**Existing**:
- `inClosedInterval x y e : Prop` (EFGames.lean line 2462)
- `stavi_temporal_truth_mu M atomMap r t A : Prop` (EFGames.lean line 806)
- `mu_holds : ExtendedCarrier → Prop` (EFGames.lean line 736)
- `extendPoint : M.carrier → ExtendedCarrier M atomMap r` (EFGames.lean line 472)

**Gap**: Need custom infimum construction for `S = {t ∈ [x,y] | ∀ u, t < u → u ≤ y → mu_holds u → stavi_temporal_truth_mu M atomMap r u C}`.

### Step 3: Define d̄ = inf of the C-set in N_r

**Same infrastructure as Step 2, applied to N.**

### Step 4: Prove d = d̄ from winning condition

**Existing**:
- `ghr93_winning_condition n tM tN : Prop` (EFGames.lean line 2576) includes `formula_agreement n tM tN`
- `formula_agreement` (EFGames.lean line 2553): for all StaviFormulas A of depth ≤ r, truth at corresponding positions is equivalent
- `rank_type_eq_iff` (EFGames.lean line 901): equal rank_types imply formula agreement
- `stavi_truth_mu_at_point` (EFGames.lean line 1973): mu-relativized truth at actual points equals standard truth

**Proof sketch**: If the winning condition holds at tuples containing c (in M) and d (in N), and C has depth ≤ r, then formula_agreement gives `M |= C(c) ↔ N |= C(d)`. By the infimum property, c is the inf of the C-set in M. By formula agreement, d must be the inf of the corresponding C-set in N, hence d = d̄.

### Step 5: Use d = d̄ to close d-consistency sorry

**Existing**:
- `ghr93_strategy_restrict_left` (EFGames.lean line 2912): proved, takes h_d_consistent as hypothesis
- `ghr93_strategy_restrict_right` (EFGames.lean line 3146): proved, takes h_d_consistent as hypothesis

**What's needed**: Replace the sorry'd `h_d_consistent_left` and `h_d_consistent_right` with proofs that follow from d = d̄.

---

## 7. Complete Sorry Inventory (For Context)

### ExpressivenessGeneral.lean (8 sorries)

| Line | Context | Dependencies |
|------|---------|-------------|
| 306 | `h_d_consistent_left` | Claim 1 (infimum) |
| 316 | `h_d_consistent_right` | Claim 1 (infimum) |
| 430 | `h_pt_xc_w` degenerate gap case | SplitPointProps restructuring |
| 447 | `h_pt_cy_w` degenerate gap case | SplitPointProps restructuring |
| 551 | Gap case in `obtain_split_point_props` | Lemma 9 (gap detection) |
| 948 | Case I same_order_type | Index manipulation (Phase 4C.3) |
| 2455 | Cases III-IV | Lemma 9 |
| 2676 | `ghr93_forward_to_backward_rank_varying` | Full inductive step |

### EFGames.lean (4 sorries)

| Line | Context | Dependencies |
|------|---------|-------------|
| 2415 | `left_formula_gap_detection` (Lemma 9 left) | Semantic case analysis |
| 2434 | `right_formula_gap_detection` (Lemma 9 right) | Semantic case analysis |
| 3504 | `ghr93_game_implies_decomposition` (Lemma 11 fwd) | Game theory |
| 3576 | `stavi_expressive_completeness` (main thm) | Everything |

---

## 8. Summary of Findings

1. **ExtendedCarrier** has `LinearOrder` but no completeness properties. No `sInf`, `sSup`, `ConditionallyCompleteLattice`, or any lattice instances exist.

2. **The infimum must be constructed from scratch**. A full `ConditionallyCompleteLattice` instance is overkill and technically questionable (r-definability may not be preserved under arbitrary infima). A custom construction for the specific C-set infimum is recommended.

3. **d is currently defined as `a_bwd(n)`** (Spoiler's last pick). The `hd_eq_an` field makes this definitional equality. Changing to an infimum-based definition requires restructuring SplitPointProps.

4. **d-consistency is consumed at exactly 2 locations** (lines 306, 316), each a sorry. These feed into `ghr93_strategy_restrict_left/right` which are themselves fully proved modulo the d-consistency hypothesis.

5. **Estimated effort for Option B (custom infimum)**: 530-1050 lines of new Lean code, with medium risk. The hardest part is proving the gap case: that the infimum, when it falls in a gap, produces an r-definable gap.

6. **Key blocker**: The continuation formula C must be explicitly constructed from rank_type and interval_types. This requires NormalForm → StaviFormula translation infrastructure, which exists conceptually (NormalForm is Fintype) but needs explicit construction.
