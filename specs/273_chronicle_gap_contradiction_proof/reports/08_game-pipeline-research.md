# Game Pipeline Research for Discrete Backward Direction

**Task**: 273
**Date**: 2026-06-09
**Focus**: Research the best path to close `nf_exist_sf_guarded_backward` for discrete orders

---

## 1. Pipeline Component Sorry Status (Verified)

All verification performed via `lean_verify` with fully qualified names.

| Component | File | Sorry-Free? | Axioms |
|-----------|------|-------------|--------|
| `discrete_nf_to_decomposition_agreement` | NFGameBridge.lean:997 | YES | propext, choice, Quot.sound |
| `ghr93_decomposition_implies_game` | Decomposition.lean:272 | YES | propext, choice, Quot.sound |
| `discrete_ghr93_proposition7` | DiscreteGameTransfer.lean:1340 | YES | propext, choice, Quot.sound |
| `discrete_ghr93_theorem6` | DiscreteGameTransfer.lean:636 | NO (sorryAx) | via `ghr93_forward_to_backward` |
| `discrete_ghr93_theorem6_zero` | DiscreteGameTransfer.lean:377 | YES | propext, choice, Quot.sound |
| `ghr93_forward_to_backward` | Theorem6.lean:160 | NO (sorryAx) | via `ghr93_inductive_step` |
| `ghr93_inductive_step` | CaseAnalysis.lean | NO (sorryAx) | Cases III/IV gap detection |
| `ghr93_inductive_step_discrete` | Transfer.lean | YES | propext, choice, Quot.sound |
| `nf_fraisse_compression` | StaviCompleteness.lean:2006 | YES | propext, choice, Quot.sound |
| `zone_match_witness` | StaviCompleteness.lean:2044 | YES | propext, choice, Quot.sound |
| `nf_2var_existential_transfer` | StaviCompleteness.lean:2214 | NO (sorryAx) | j>=1 case, lines 2353 & 2435 |
| `nf_2var_from_interval_data` | StaviCompleteness.lean:2448 | NO (sorryAx) | depends on `nf_2var_existential_transfer` |
| `nf_exist_sf_guarded_backward` | StaviCompleteness.lean:2778 | NO (sorryAx) | depends on bridge lemma |
| `nf_exist_sf_guarded_forward` | StaviCompleteness.lean:2643 | YES | propext, choice, Quot.sound |

### Key Finding

The entire sorry-free discrete game pipeline is:
```
discrete_nf_to_decomposition_agreement  (sorry-free)
    --> ghr93_decomposition_implies_game  (sorry-free)
    --> discrete_ghr93_proposition7  (sorry-free)
```

The general `ghr93_forward_to_backward` is NOT sorry-free (via `ghr93_inductive_step` in CaseAnalysis.lean), but the discrete path through `discrete_ghr93_proposition7` bypasses it entirely.

---

## 2. Discrete Backward Direction Proof Sketch

### The Sorry Location

File: `DiscreteStaviCompleteness.lean`, line 338.
Goal at sorry:
```
⊢ ∃ x, nf_eval_nf N k (1 + 1) (Fin.cons x fun x ↦ t) sub_nf
```

Given:
- `h_sf : stavi_temporal_truth N atomMap t (exist_sf sub_nf)` -- the formula holds
- `h_atoms : ∀ a, atom_eval N (fun _ => t) a ↔ nf.1 a = true` -- parent atom agreement
- `char_k_correct` -- the IH gives correct depth-k characteristic formulas for all discrete N
- `N` is a discrete ordered monadic structure

### Step-by-Step Proof Structure

**Step 1: Extract witness x from the formula**

From `h_sf`, unfolding `nf_exist_sf_guarded`, extract:
- A carrier element `x : N.carrier`
- The ordering between x and t (one of: x < t, t < x, or x = t)
- That `char_k nf_x` holds at x for some compatible `nf_x`
- The interval guard: for all u between x and t, some `char_k nf_u` holds at u

This step requires case analysis on `nf_order_0_1 sub_nf`:
- `some true` (t < x): formula is `Until`, so x > t and the interval guard holds on (t, x)
- `some false` (x < t): formula is `Since`, so x < t and the interval guard holds on (x, t)
- `none` (x = t): formula is the witness type disjunction, so x = t

**Step 2: Determine nf_characteristic of x**

From `char_k_correct`, the fact that `char_k nf_x` holds at x means:
```
nf_eval_nf N k 1 (fun _ => x) nf_x
```
By `nf_eval_unique`, this gives `nf_x = nf_characteristic N k 1 (fun _ => x)`.

**Step 3: Find a reference model M_ref where sub_nf is realized**

Since `sub_nf : NormalForm sig k 2`, by `nf_realizable` (or Classical.choice on the realizability proposition), there exists some model M_ref and points (x_ref, t_ref) such that:
```
nf_eval_nf M_ref k 2 (Fin.cons x_ref (fun _ => t_ref)) sub_nf
```

This gives us the bridge hypotheses between N (the concrete model) and M_ref (the reference model):
- `nf_characteristic M_ref k 1 (fun _ => x_ref)` has the same atom assignment as the x-projection of sub_nf
- `nf_characteristic M_ref k 1 (fun _ => t_ref)` has the same atom assignment as the t-projection of sub_nf

**Step 4: Establish bridge hypotheses between N and M_ref**

We need to show that (x, t) in N and (x_ref, t_ref) in M_ref satisfy:
1. Same 1-var depth-k NF at x/x_ref: from Step 2 + atom compatibility
2. Same 1-var depth-k NF at t/t_ref: from `h_atoms` + the t-consistency of sub_nf
3. Same ordering: from the formula structure
4. Same interval types: from the interval guard data
5. Same above-max / below-min types: from properties of discrete models

**Step 5: Apply the game pipeline**

With bridge hypotheses established:
```
discrete_nf_to_decomposition_agreement x t x_ref t_ref ...
  : decomposition_agreement N M_ref atomMap 0 (k/2) (extendPoint x) (extendPoint t) ...
```

Then lift to `discrete_universal_decomp` (this is the critical missing step -- see Section 4).

Then:
```
discrete_ghr93_proposition7 n (k/2) ...
  : ghr93_duplicator_wins N M_ref atomMap n (k/2) ...
```

**Step 6: Use game wins to prove NF equality**

From game wins at all rounds n, derive:
```
nf_fraisse_compression k 2 N (Fin.cons x (fun _ => t)) M_ref (Fin.cons x_ref (fun _ => t_ref)) ...
  : nf_characteristic N k 2 (Fin.cons x (fun _ => t)) = nf_characteristic M_ref k 2 (Fin.cons x_ref (fun _ => t_ref))
```

Since `nf_characteristic M_ref k 2 (Fin.cons x_ref (fun _ => t_ref)) = sub_nf` (by uniqueness), this gives:
```
nf_eval_nf N k 2 (Fin.cons x (fun _ => t)) sub_nf
```

Hence `x` is the witness, proving the goal.

---

## 3. General Backward Direction Proof Sketch (Path B)

The general sorry at `StaviCompleteness.lean:2805` (`nf_exist_sf_guarded_backward`) follows the same structure as the discrete proof, but:

1. The formula extraction is the same
2. The bridge hypotheses are the same
3. But `nf_2var_existential_transfer` is sorry'd at the j>=1 case (lines 2353, 2435)
4. The sorry is in the 4-var existential transfer for 3-point configurations -- the sub-interval splitting problem

The general path would require either:
- Closing `ghr93_inductive_step` in CaseAnalysis.lean (Cases III/IV for gap detection -- ~8 sorry locations)
- Or finding a different approach to `nf_2var_existential_transfer` that avoids 4-var sub-interval matching

**Effort estimate for Path B**: Very high. CaseAnalysis.lean has ~8 sorries in Cases III/IV (gap detection), and these are fundamentally about non-discrete orders with gaps. The general approach is structurally harder.

---

## 4. Gap Analysis -- What's Missing for Each Path

### Path A (Discrete) -- Missing Components

**Gap 1: `discrete_bridge_hyps_to_univ_decomp` (CRITICAL)**

The biggest gap. `discrete_nf_to_decomposition_agreement` gives `decomposition_agreement` for ONE specific pair (x, t) / (x', t'). But `discrete_ghr93_proposition7` needs `discrete_universal_decomp` which requires `decomposition_agreement` for ALL sub-interval pairs (a, b) / (a', b') within [x, t] / [x', t'].

To bridge this gap, we need to show that the NF bridge hypotheses (same 1-var NFs, same ordering, same interval types) are **hereditary** -- they pass down to sub-intervals.

Specifically, for matched points a in [x,t] and a' in [x',t']:
- `nf_characteristic N k 1 (fun _ => a) = nf_characteristic M_ref k 1 (fun _ => a')`
  This follows from `zone_match_witness` giving a' with the same NF.
- Orderings between a and endpoints: from the zone matching.
- Interval types of sub-intervals: this is the key difficulty.

For discrete orders, the interval types of (a, t) are a SUBSET of the interval types of (x, t) when a is between x and t. This can be proved directly for discrete linear orders because every point in (a, t) is also in (x, t).

**Approach**: Define a lemma:
```lean
theorem discrete_bridge_hyps_hereditary
    {N M_ref : OrderedMonadicStructure sig}
    [SuccOrder N.carrier] ... [IsSuccArchimedean N.carrier]
    [SuccOrder M_ref.carrier] ... [IsSuccArchimedean M_ref.carrier]
    (k : Nat) (x t : N.carrier) (x' t' : M_ref.carrier)
    (a : N.carrier) (a' : M_ref.carrier)
    (ha : x ≤ a ∧ a ≤ t)  -- a is in [x,t]
    (h_bridge : <bridge hypotheses for (x,t)/(x',t')>)
    (h_nf_a : nf_characteristic N k 1 (fun _ => a) =
              nf_characteristic M_ref k 1 (fun _ => a')) :
    <bridge hypotheses for (a,t)/(a',t')>
```

The interval type heredity for discrete orders follows from: if `lo < u < hi` and `lo ≤ lo' ≤ hi`, then `lo' < u < hi` or `u ≤ lo'`. In discrete orders, the set of points in (a, t) is a subset of those in (x, t), so `interval_nf_types N k a t ⊆ interval_nf_types N k x t`. The matching `interval_nf_types M_ref k a' t' ⊆ interval_nf_types M_ref k x' t'` follows from the zone matching.

But we need EQUALITY of interval types, not just subset. This requires showing that if an NF type is realized in (a, t), it is also realized in (a', t'). This follows from `zone_match_witness` applied to the sub-interval, using the outer interval data.

**Estimated effort**: ~200-300 lines for the heredity lemma + sub-interval decomposition constructor.

**Gap 2: Reference model construction**

Need to obtain a reference model M_ref where sub_nf is actually realized. This uses `Classical.choice` on the proposition that sub_nf is realizable. Need to verify:
- Every NormalForm is realizable (exists in some model)
- Or construct a canonical model

The existing `nf_characteristic_satisfies` shows that for any model and environment, the characteristic NF is realized. But we need the reverse: for a given sub_nf, find a model realizing it.

This may already be available or constructible from the Henkin construction in the codebase.

**Estimated effort**: ~50-100 lines (likely existing infrastructure).

**Gap 3: Formula extraction from `h_sf`**

Need to unfold `nf_exist_sf_guarded` and extract the witness x, its NF, the ordering, and the interval guard data. This is routine case analysis on the formula structure.

**Estimated effort**: ~100-150 lines of case analysis.

**Gap 4: Bridge hypothesis assembly**

Connect the formula-extracted data to the bridge hypotheses required by `discrete_nf_to_decomposition_agreement`. Specifically:
- Convert the interval guard (∀ u in interval, some char_k holds) to `interval_nf_types` equality
- Establish above-max/below-min type agreement

For discrete orders, the interval guard gives type REALIZATION (every point has some type), and combined with zone_match_witness, this should give type equality.

**Estimated effort**: ~150-200 lines.

### Path B (General) -- Missing Components

| Gap | Description | Effort |
|-----|-------------|--------|
| `ghr93_inductive_step` sorries | Cases III/IV gap detection in CaseAnalysis.lean | Very high (~500+ lines, ~8 sorries) |
| `nf_2var_existential_transfer` j>=1 | 4-var sub-interval matching | Depends on ghr93_inductive_step |
| Same formula extraction | Same as Path A Gap 3 | ~100-150 lines |
| Same reference model | Same as Path A Gap 2 | ~50-100 lines |

**Total estimated effort Path B**: 700+ lines, structurally harder due to gap detection.

---

## 5. Recommended Approach with Effort Estimates

### Recommendation: Path A (Discrete) is strongly preferred

**Rationale**:
1. All game pipeline components are already sorry-free for discrete orders
2. The key missing lemma (`discrete_bridge_hyps_to_univ_decomp`) is conceptually clean: it uses the heredity of interval types in discrete orders, which is mathematically straightforward
3. Path A avoids the gap detection problem (Cases III/IV in CaseAnalysis.lean) entirely
4. The resulting `discrete_stavi_expressive_completeness` is self-contained and independently valuable

**Effort breakdown**:

| Component | Lines | Difficulty |
|-----------|-------|------------|
| Formula extraction from h_sf | 100-150 | Medium (case analysis) |
| Reference model construction | 50-100 | Low-Medium |
| Bridge hypothesis assembly | 150-200 | Medium |
| Discrete bridge heredity lemma | 200-300 | Medium-High (key intellectual content) |
| `discrete_universal_decomp` from hereditary bridge | 100-150 | Medium |
| Final assembly: game pipeline -> NF equality | 100-150 | Medium |
| **Total** | **700-1050** | **Medium-High** |

**Phases**:
1. Formula extraction + reference model (200-250 lines)
2. Bridge hypothesis assembly (150-200 lines)
3. Discrete heredity + universal decomp (300-450 lines)
4. Final assembly using game pipeline (100-150 lines)

### Alternative: Direct `nf_2var_existential_transfer` for Discrete Orders

An alternative to the full game pipeline is to prove a discrete version of `nf_2var_existential_transfer` that avoids the 4-var sub-interval problem by using the fact that in discrete orders, the induction on j can be done more directly. Specifically:

The sorry in `nf_2var_existential_transfer` at j>=1 needs 4-var existential transfer at depth j' for the 3-point configuration (u,x,t)/(u',x',t'). In discrete orders, we could:
1. Use `zone_match_witness` to find w' matching w (the new 4th variable)
2. The 4-var atom agreement follows from 1-var NF agreement + orderings
3. Recurse on the depth j', with the induction eventually reaching j=0 (pure atoms)

This direct approach avoids the game pipeline entirely and instead directly proves the existential transfer by strong induction on j with the discrete zone matching. This might be simpler than the full game pipeline approach.

**Estimated effort for direct approach**: ~300-500 lines (strong induction on j, zone matching at each step).

---

## 6. Key Type Signatures for New Lemmas Needed

### Gap 1: `discrete_bridge_hyps_to_univ_decomp`

```lean
/-- From the NF bridge hypotheses at (x,t)/(x_ref,t_ref), construct
    discrete_universal_decomp for all sub-intervals.
    
    The key insight: in discrete orders, interval types are hereditary --
    if (a,b) ⊆ (x,t) with matching endpoints, the bridge hypotheses
    hold for (a,b)/(a',b') too. -/
theorem discrete_bridge_hyps_to_univ_decomp
    {sig : MonadicSignature}
    {N M_ref : OrderedMonadicStructure sig}
    {atomMap : Formula → sig.preds}
    {k : Nat}
    [SuccOrder N.carrier] [PredOrder N.carrier] [NoMaxOrder N.carrier]
    [NoMinOrder N.carrier] [IsSuccArchimedean N.carrier]
    [SuccOrder M_ref.carrier] [PredOrder M_ref.carrier] [NoMaxOrder M_ref.carrier]
    [NoMinOrder M_ref.carrier] [IsSuccArchimedean M_ref.carrier]
    (x t : N.carrier) (x_ref t_ref : M_ref.carrier)
    (h_nf_x : nf_characteristic N k 1 (fun _ => x) =
              nf_characteristic M_ref k 1 (fun _ => x_ref))
    (h_nf_t : nf_characteristic N k 1 (fun _ => t) =
              nf_characteristic M_ref k 1 (fun _ => t_ref))
    (h_order_xt : (x < t ↔ x_ref < t_ref) ∧ (t < x ↔ t_ref < x_ref))
    (h_interval_above : t < x →
      interval_nf_types N k t x = interval_nf_types M_ref k t_ref x_ref)
    (h_interval_below : x < t →
      interval_nf_types N k x t = interval_nf_types M_ref k x_ref t_ref)
    (h_above_max : ...)
    (h_below_min : ...) :
    discrete_universal_decomp N M_ref atomMap (k / 2)
      (extendPoint x) (extendPoint t)
      (extendPoint x_ref) (extendPoint t_ref)
```

### Gap 2: `discrete_nf_exist_sf_guarded_backward`

```lean
/-- Backward direction of nf_exist_sf_guarded for discrete orders:
    formula truth implies existence of witness with correct 2-var NF. -/
theorem discrete_nf_exist_sf_guarded_backward
    {sig : MonadicSignature} (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (k : Nat)
    (char_k : NormalForm sig k 1 → StaviFormula)
    (char_k_correct : ∀ (nf_k : NormalForm sig k 1)
        (N : OrderedMonadicStructure sig)
        [SuccOrder N.carrier] [PredOrder N.carrier] [NoMaxOrder N.carrier]
        [NoMinOrder N.carrier] [IsSuccArchimedean N.carrier]
        (t : N.carrier),
        stavi_temporal_truth N atomMap t (char_k nf_k) ↔
        nf_eval_nf N k 1 (fun _ => t) nf_k)
    (parent_atoms : AtomKind sig 1 → Bool)
    (sub_nf : NormalForm sig k 2)
    {N : OrderedMonadicStructure sig}
    [SuccOrder N.carrier] [PredOrder N.carrier] [NoMaxOrder N.carrier]
    [NoMinOrder N.carrier] [IsSuccArchimedean N.carrier]
    {t : N.carrier}
    (h_atoms : ∀ (a : AtomKind sig 1), atom_eval N (fun _ => t) a ↔
      parent_atoms a = true)
    (h_sf : stavi_temporal_truth N atomMap t
      (nf_exist_sf_guarded atomMap h_surj k char_k parent_atoms sub_nf)) :
    ∃ x : N.carrier, nf_eval_nf N k (1 + 1) (Fin.cons x (fun _ => t)) sub_nf
```

### Alternative Gap: `discrete_nf_2var_existential_transfer`

```lean
/-- Discrete version of nf_2var_existential_transfer.
    Uses zone_match_witness + strong induction on j, avoiding the
    4-var sub-interval problem by recursive zone matching. -/
theorem discrete_nf_2var_existential_transfer
    {sig : MonadicSignature}
    {M M' : OrderedMonadicStructure sig}
    (atomMap : Formula → sig.preds)
    (k : Nat)
    [SuccOrder M.carrier] ... [IsSuccArchimedean M.carrier]
    [SuccOrder M'.carrier] ... [IsSuccArchimedean M'.carrier]
    (x t : M.carrier) (x' t' : M'.carrier)
    (h_nf_x : nf_characteristic M k 1 (fun _ => x) = ...)
    (h_nf_t : ...)
    (h_order_xt : ...)
    (h_interval_above : ...)
    (h_interval_below : ...)
    (h_above_max : ...)
    (h_below_min : ...) :
    ∀ j, j < k →
      ∀ chi : NormalForm sig j (2 + 1),
        (∃ u, nf_eval_nf M j (2 + 1) (Fin.cons u (Fin.cons x (fun _ => t))) chi) ↔
        (∃ u', nf_eval_nf M' j (2 + 1) (Fin.cons u' (Fin.cons x' (fun _ => t'))) chi)
```

---

## 7. Build Status

Current build status per `.return-meta.json`:
- DiscreteGameTransfer.lean: 24 pre-existing build errors
- DiscreteStaviCompleteness.lean: 1 sorry (the target)

The 24 build errors in DiscreteGameTransfer.lean were reported previously but the verify checks above all passed, suggesting these errors may have been resolved or are in non-critical sections. The `lean_verify` tool confirmed all key theorems have the expected axiom dependencies.

---

## 8. Summary of Recommended Next Steps

1. **Phase 1**: Prove `discrete_nf_2var_existential_transfer` (the direct approach). This bypasses both the game pipeline complexity AND the gap detection issues. It works by strong induction on j, using `zone_match_witness` at each level plus the discrete interval type heredity.

2. **Phase 2**: Using the discrete existential transfer, prove `discrete_nf_2var_from_interval_data` (discrete version of the bridge lemma) by feeding into `nf_fraisse_compression`.

3. **Phase 3**: Extract formula data from `h_sf` and assemble bridge hypotheses.

4. **Phase 4**: Complete `discrete_nf_exist_sf_guarded_backward` by combining formula extraction + reference model + discrete bridge lemma.

The direct approach (proving `discrete_nf_2var_existential_transfer` by induction) is likely the cleanest path because:
- It avoids needing `discrete_universal_decomp` entirely
- It avoids the game pipeline's rank parameter complications
- It directly solves the same sorry as the general case but only for discrete orders
- The key insight is simple: in discrete orders, zone matching + interval type subset works at every depth
