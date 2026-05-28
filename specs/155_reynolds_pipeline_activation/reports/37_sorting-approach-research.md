# GHR93 Sorting Approach: Research Report

**Task**: 155 (reynolds_pipeline_activation)  
**Date**: 2026-05-27  
**Focus**: GHR93 sorting mechanism for Phase 3C fan problem resolution

---

## 1. GHR93 Sorting Mechanism (Literature)

### 1.1 What GHR93 Assumes

GHR93 Section 8 (p. 115) states:

> Spoiler chooses n+1 points x' < α₀ < ... < αₙ < y' in N_r.

The selections are **sorted by assumption**. The last element αₙ plays a distinguished role:
- **Case II**: αₙ is a carrier point. B = X_{αₙ}. The formula U(B, A) is evaluated at αₙ₋₁.
- **Cases III/IV**: αₙ is a gap, defined on left/right by some formula D.

The critical property exploited throughout: **all αₖ < αₙ for k < n**. This makes:
- `sel_pn_ord` trivial in Case II (a_init(k) < p_n for all k < n)
- The U(B,A) witness construction valid (αₙ witnesses U(B,A) at αₙ₋₁)

### 1.2 How GHR93 Handles Unsorted Spoiler Choices

GHR93 doesn't handle unsorted choices — it assumes WLOG that Spoiler's choices are sorted. This is justified by the game semantics: the winning condition `ghr93_winning_condition` is defined for ALL pairs of indices, so permuting both selection arrays by the same permutation preserves the winning condition. If Duplicator has a winning response to sorted selections, she has a winning response to any permutation of those selections by applying the inverse permutation.

### 1.3 The Distinguished Element

In GHR93, αₙ is always the **maximum** of the selections (since sorted). The split point d̄ is defined from αₙ's continuation formula C = X_{(αₙ, y')}. After sorting, αₙ is guaranteed to be at the last position.

---

## 2. Existing Lean Infrastructure

### 2.1 Sorting Machinery (Available)

| Component | Location | Status |
|-----------|----------|--------|
| `Tuple.sort f : Equiv.Perm (Fin n)` | Mathlib.Data.Fin.Tuple.Sort | Imported in CaseAnalysis.lean |
| `Tuple.monotone_sort f : Monotone (f ∘ (Tuple.sort f))` | Mathlib.Data.Fin.Tuple.Sort | Available |
| `LinearOrder (ExtendedCarrier M atomMap r)` | Defs.lean:358 | Instance exists |
| `ghr93_winning_condition_perm` | CustomGame.lean:1591 | Proved, ready to use |

### 2.2 Key API

```lean
-- Tuple.sort: returns a permutation σ such that f ∘ σ is monotone
Tuple.sort : {n : ℕ} → {α : Type} → [LinearOrder α] → (Fin n → α) → Equiv.Perm (Fin n)

-- The sorted composition is monotone
Tuple.monotone_sort (f : Fin n → α) : Monotone (f ∘ (Tuple.sort f))

-- Winning condition is permutation-invariant (already proved)
ghr93_winning_condition_perm : ... → ghr93_winning_condition n
  (game_tuple x y (a ∘ σ) b) (game_tuple x' y' (a' ∘ σ) b')
```

### 2.3 SplitPointProps Structure

`SplitPointProps` (SplitPoint.lean:44) is parameterized by `a_bwd : Fin (n+1) → ExtendedCarrier N atomMap r` and has a critical field:
```lean
hd_le_an : d ≤ a_bwd ⟨n, by omega⟩
```

The split point d is defined relative to `a_bwd(n)` — the element at index n. After sorting, the element at index n is the **maximum** of the sorted tuple (by `Tuple.monotone_sort`). This is exactly what GHR93 needs.

### 2.4 obtain_split_point_props

This theorem (SplitPoint.lean:141) computes `d` from `a_bwd(n)` — the continuation formula C is based on the type at `a_bwd(n)`. Currently, this computation doesn't require `a_bwd(n)` to be the maximum, but the downstream proofs (Case II) **do** require it.

---

## 3. Implementation Plan: Sorting as Wrapper

### 3.1 Architecture Decision: Wrapper vs Internal Restructuring

**Wrapper approach** (RECOMMENDED): Sort at the `ghr93_inductive_step` level, before calling `obtain_split_point_props`. The internal proofs never see unsorted selections.

**Why wrapper works**: 
1. `ghr93_inductive_step` receives `a_bwd` from `unfold ghr93_duplicator_wins; intro a_bwd ha_bwd`
2. We sort `a_bwd` immediately: `let σ := Tuple.sort a_bwd; let a_sorted := a_bwd ∘ σ`
3. Prove the theorem for `a_sorted` (all internal proofs see sorted selections)
4. Use `ghr93_winning_condition_perm` to transfer back to unsorted `a_bwd`

This approach requires **zero changes** to `ghr93_case_II`, `ghr93_cases_III_IV`, `SplitPointProps`, or `obtain_split_point_props`.

### 3.2 Detailed Steps

#### Step 1: Sort at ghr93_inductive_step (CaseAnalysis.lean:4378-4392)

Current code:
```lean
ghr93_duplicator_wins N M atomMap (n + 1) r x' y' x y := by
  unfold ghr93_duplicator_wins
  intro a_bwd ha_bwd
  obtain ⟨c, d, props⟩ :=
    obtain_split_point_props hxy hx'y' h_pt h_pt_M ih h_fwd h_fwd_r1 a_bwd ha_bwd
  ...
```

New code:
```lean
ghr93_duplicator_wins N M atomMap (n + 1) r x' y' x y := by
  unfold ghr93_duplicator_wins
  intro a_bwd ha_bwd
  -- GHR93 WLOG: sort Spoiler's selections so a_sorted is monotone
  let σ := Tuple.sort a_bwd
  let a_sorted : Fin (n + 1) → ExtendedCarrier N atomMap r := a_bwd ∘ σ
  have ha_sorted : ∀ i, inClosedInterval x' y' (a_sorted i) :=
    fun i => ha_bwd (σ i)
  have h_mono : Monotone a_sorted := Tuple.monotone_sort a_bwd
  -- Prove for sorted selections
  obtain ⟨c, d, props⟩ :=
    obtain_split_point_props hxy hx'y' h_pt h_pt_M ih h_fwd h_fwd_r1 a_sorted ha_sorted
  -- (rest of proof uses a_sorted instead of a_bwd)
  ...
  -- Final: transfer winning condition from sorted back to original
  -- ghr93_winning_condition_perm with σ⁻¹ transfers
  -- (a_sorted ∘ σ⁻¹ = a_bwd ∘ σ ∘ σ⁻¹ = a_bwd)
```

#### Step 2: After case dispatch, transfer back

The case dispatch produces:
```lean
∃ (a'_resp : Fin (n + 1) → ExtendedCarrier M atomMap r), ... ∧
  ghr93_winning_condition (n + 1)
    (game_tuple x' y' a_sorted b_resp) (game_tuple x y a'_resp b_sp)
```

We need to transform this to:
```lean
ghr93_winning_condition (n + 1)
    (game_tuple x' y' a_bwd b_resp) (game_tuple x y (a'_resp ∘ σ⁻¹) b_sp)
```

Using `ghr93_winning_condition_perm` with permutation `σ⁻¹`:
- N-side: `a_sorted ∘ σ⁻¹ = (a_bwd ∘ σ) ∘ σ⁻¹ = a_bwd` ✓
- M-side: `a'_resp ∘ σ⁻¹` (Duplicator's response permuted back)

#### Step 3: Exploit monotonicity in ghr93_case_II

With sorted selections, `a_sorted(n) = max(a_bwd)`. For all k < n:
```lean
a_sorted k ≤ a_sorted n   -- from Monotone
```

Since `h_no_split` gives `d ≤ a_sorted i` for all i, and `a_sorted(n)` is the maximum:
```lean
a_init k = a_sorted ⟨k, _⟩ < a_sorted ⟨n, _⟩ = extendPoint p_n   -- if strict
a_init k = a_sorted ⟨k, _⟩ ≤ a_sorted ⟨n, _⟩ = extendPoint p_n   -- from Monotone
```

Wait — `Monotone` gives `≤`, not `<`. Equal elements are possible (duplicate selections). But GHR93 also handles this: if `a_init(k) = extendPoint p_n`, then `resp_tau(k)` and `e_n` must satisfy the same formulas (both have B-type), so `resp_tau(k) = e_n` is the matching biconditional.

Actually, the critical insight is: **with sorted selections, `sel_pn_ord` becomes provable**:
- If `a_init k < extendPoint p_n`: trivially maps via U(B,A) transfer (standard GHR93)
- If `a_init k = extendPoint p_n`: both sides of the biconditional reduce to the same thing (formula agreement via hform_abig_ainit + tau formula transfer gives same position)

The `same_side` lemma becomes:

```lean
have same_side : (a'_big ⟨k.val, ...⟩ < extendPoint p_n ↔ a_init k < extendPoint p_n) ∧
    (a'_big ⟨k.val, ...⟩ = extendPoint p_n ↔ a_init k = extendPoint p_n) := by
  -- From monotonicity: a_init k ≤ a_sorted(n) = extendPoint p_n
  have h_le : a_init k ≤ extendPoint p_n := by
    have := h_mono (show (⟨k.val, by omega⟩ : Fin (n+1)) ≤ ⟨n, by omega⟩ from by omega)
    simp [a_init, a_sorted] at this ⊢; rwa [hp_n]
  -- The biconditional now only involves the ≤ direction
  -- Both a'_big(k) and a_init(k) agree on rank-r formulas (hform_abig_ainit)
  -- Since a_init(k) ≤ p_n, the "above p_n" case cannot arise
  -- ... (remaining proof details)
```

**BUT WAIT**: Even with `a_init k ≤ extendPoint p_n`, the `same_side` lemma is still about `a'_big(k)` — the big game's N-side response — not about `a_init(k)`. The key question is: does `a_init(k) ≤ p_n` help prove `a'_big(k) < p_n ↔ a_init(k) < p_n`?

**YES**, because with sorted selections, `a_init(k) ≤ p_n` always holds. So:
- `a_init(k) < p_n`: use U(B,A) to transfer the "B-point above" witness. Since there IS a B-point above a_init(k) (namely p_n itself), the formula U(B, sf_top) transfers via tau to a'_big(k). But this still doesn't tell us a'_big(k) < p_n...

Actually, re-reading GHR93 more carefully: **GHR93 does NOT prove same_side at all**. GHR93 constructs e_n differently:

1. Apply tau to α₀,...,αₙ₋₁ getting e₀,...,eₙ₋₁
2. Observe N ⊨ U(B,A)(αₙ₋₁): αₙ witnesses this (αₙ > αₙ₋₁, B(αₙ), A on (αₙ₋₁, αₙ))
3. Transfer: M ⊨ U(B,A)(eₙ₋₁) (tau preserves rank r+4 ≥ r+1 = rank of U(B,A))
4. Extract witness z > eₙ₋₁ with B(z) and A on (eₙ₋₁, z). Set eₙ = z.
5. **sel_pn_ord is NEVER NEEDED**: the ordering is built into the construction

The crucial difference: GHR93 does NOT use a big forward game to construct e_n. It constructs e_n from the U(B,A) transfer through tau. The current code constructs e_n from the forward game and THEN tries to prove sel_pn_ord. This is the fundamental architectural mismatch.

### 3.3 The Real Fix: Replace e_n Construction (Not Just Sort)

Sorting alone does NOT fix the problem. The current code constructs e_n via the forward game (big game) and then needs sel_pn_ord. GHR93 constructs e_n via U(B,A) transfer through tau, which NEVER needs sel_pn_ord.

The correct fix combines:
1. **Sorting** (wrapper): ensures αₙ is the maximum, making U(B,A)(αₙ₋₁) hold
2. **U(B,A) witness construction** (internal): replace the forward-game e_n with the U(B,A) witness z

Both are needed. Sorting alone doesn't fix sel_pn_ord. U(B,A) alone doesn't work because without sorting, αₙ₋₁ might be above αₙ, so U(B,A)(αₙ₋₁) doesn't hold.

---

## 4. Function Signatures That Need to Change

### 4.1 Sorting Wrapper (New Parameter/Change)

Only `ghr93_inductive_step` needs modification. Add sorting at the top of its proof. **No signature change required** — sorting is internal to the proof.

| Function | File:Line | Change |
|----------|-----------|--------|
| `ghr93_inductive_step` | CaseAnalysis.lean:4338 | Internal: sort a_bwd, pass sorted to downstream |

### 4.2 E_n Replacement (Major Refactor)

| Function | File:Line | Change |
|----------|-----------|--------|
| `ghr93_case_II` | CaseAnalysis.lean:1188 | Replace lines ~1241-1597 (forward-game e_n) with U(B,A) witness construction |

### 4.3 No Changes Needed

| Function | Reason |
|----------|--------|
| `SplitPointProps` | Structure is a_bwd-agnostic; receives sorted a_bwd |
| `obtain_split_point_props` | Receives sorted a_bwd; d = a_sorted(n) = max |
| `ghr93_cases_II_III_IV` | Receives sorted a_bwd transparently |
| `ghr93_cases_III_IV` | No sel_pn_ord; gap cases don't need sorting |
| `ghr93_case_I` | Split case unaffected by sorting |
| `ghr93_forward_to_backward_core` | Calls ghr93_inductive_step; sorting happens inside |
| `ghr93_forward_to_backward` | Top-level; unaware of sorting |

---

## 5. Detailed Implementation Plan

### Phase A: Sorting Wrapper (~30-50 lines)

**Location**: `ghr93_inductive_step` proof body (CaseAnalysis.lean:4378-4392)

1. After `intro a_bwd ha_bwd`, compute `σ := Tuple.sort a_bwd`
2. Define `a_sorted := a_bwd ∘ σ` and prove `ha_sorted`, `h_mono`
3. Pass `a_sorted` to `obtain_split_point_props` and case dispatch
4. After case dispatch, transform result:
   - `a'_resp_sorted` → `a'_resp := a'_resp_sorted ∘ σ⁻¹`
   - Use `ghr93_winning_condition_perm σ⁻¹` to transfer back

**Key lemma needed**:
```lean
-- a_sorted ∘ σ⁻¹ = a_bwd
have h_unsort : a_sorted ∘ σ.symm = a_bwd := by
  ext i; simp [a_sorted, Function.comp, Equiv.Perm.apply_symm_apply]
```

### Phase B: U(B,A) Witness Construction in ghr93_case_II (~200-350 lines)

**Location**: CaseAnalysis.lean, inside `ghr93_case_II` proof

#### B.1: Add `h_mono` parameter to ghr93_case_II (~5 lines)

Add a new hypothesis:
```lean
(h_mono : Monotone a_bwd)
```

This allows the proof to use `a_init k ≤ a_bwd ⟨n, _⟩ = extendPoint p_n` for all k < n.

#### B.2: Construct B and U(B,A) (~30 lines)

```lean
-- B = char_k(nf_type(p_n)): characteristic formula for p_n's NF type
-- A = char_k(nf_type(interval between a_init(n-1) and p_n))
-- phi = StaviFormula.std_untl B (.base Formula.top)  -- "B-point above"
-- stavi_depth phi = stavi_depth B + 2 ≤ r (from char_k_depth)
```

Wait — GHR93 uses U(B, A) where A is the interval type formula. But materializing A as a StaviFormula requires either:
1. A single formula A (conjunction of all rank-r formulas true at points in the interval), or
2. The game-level assertion that tau transfers rank-r+1 formulas

Actually, re-reading the literature: GHR93 says "N_r ⊨ U(B,A)(αₙ₋₁): αₙ is a witness to this." Here U(B,A) means "there exists a point above where B holds and A holds on all points in between." B = X_{αₙ} and A = X_{(αₙ₋₁, αₙ)} (the interval type disjunction).

In the Lean formalization, we can use a simpler formula that still captures the key property. The minimal requirement is:
- phi = `std_untl B (.base Formula.top)` = "there exists a B-point above me"
- This has depth ≤ stavi_depth(B) + 2 ≤ r (from char_k_depth)
- phi holds at a_init(k) for k < n whenever a_init(k) < p_n (p_n witnesses it)

With **sorted** selections, ALL a_init(k) < p_n (or = p_n). So phi holds at all a_init(k) that are strictly below p_n.

But we need more than just "B-point above" — we need the WITNESS z to satisfy A on (eₙ₋₁, z). The simplified phi doesn't give us the A-agreement.

**Alternative**: Use the full U(B, A) formula. But materializing A is complex.

**Practical approach**: Use tau's formula agreement at rank r+4 directly. Since tau preserves rank r+4 ≥ r+1, and U(B,A) has rank r+1 (as a StaviFormula), the transfer works. But we need U(B,A) as an actual StaviFormula to feed into the formula agreement.

GHR93's U(B,A) has rank max(rank(B), rank(A)) + 1 = r + 1. In Lean terms:
```lean
StaviFormula.std_untl B A  -- where B, A : StaviFormula with stavi_depth ≤ r
```

The issue is: what is A? A = X_{(αₙ₋₁, αₙ)} = disjunction over rank-r types of points in (αₙ₋₁, αₙ). This is NOT a single StaviFormula — it's a disjunction of potentially many formulas. However, since there are finitely many rank-r types (NormalForm is Fintype), A is a finite disjunction, constructible as:
```lean
A = sf_disjList (types_in_interval a_init(n-1) p_n)
```

This requires listing all rank-r NF types realized in the interval (αₙ₋₁, αₙ). This information comes from the structure N — it's a semantic property.

**Simpler alternative**: Use `std_untl B (.base Formula.top)` (just "B above"). This suffices for the ordering proof: if "B above" holds at eₙ₋₁ in M, then there exists z > eₙ₋₁ with B(z). Set eₙ = z. Then eₙ and αₙ agree on rank-r formulas (both satisfy B = X_{αₙ}). The A-agreement between eₙ₋₁ and αₙ₋₁ is already given by tau's winning condition.

**THE KEY REALIZATION**: GHR93's round-2 case analysis for t ∈ (eₙ₋₁, eₙ) uses A-agreement. But this A-agreement is NOT from the U(B,A) formula — it's from the fact that tau preserves rank-r formulas between the sub-intervals. The U(B,A) formula is only used to FIND eₙ; the A-agreement in the interval is handled separately by tau's winning condition.

So `std_untl B (.base Formula.top)` is sufficient for finding eₙ. The interval A-agreement for round-2 case analysis comes from tau directly.

#### B.3: Prove phi holds at a_init(k) for k < n (~20 lines)

With sorted selections:
```lean
have h_lt_pn : ∀ k : Fin n, a_init k ≤ extendPoint p_n := by
  intro k; exact h_mono (show (⟨k.val, by omega⟩ : Fin (n+1)) ≤ ⟨n, by omega⟩ from by omega) |>.trans (le_of_eq hp_n.symm)
```

For `a_init(k) < extendPoint p_n` (strict):
- p_n is a B-point (B = X_{p_n} = char_k(nf_type(p_n)), which holds at p_n by definition)
- p_n > a_init(k)
- So std_untl B (.base Formula.top) holds at a_init(k)

For `a_init(k) = extendPoint p_n` (equal):
- sel_pn_ord requires: `a_init k = extendPoint p_n ↔ resp_tau k = e_n`
- With tau formula agreement at rank r: a_init(k) and resp_tau(k) agree on all rank-r formulas
- If a_init(k) = p_n, then resp_tau(k) has B-type too. We need resp_tau(k) = e_n.
- But resp_tau(k) might not equal e_n — they could be different points with the same B-type.

**This shows the equality case still needs care**. However, GHR93 has strict inequality (strict sorting), which avoids the equality case entirely. Our `Tuple.monotone_sort` gives `Monotone` (≤), not `StrictMono` (<). Equal selections are possible.

**Resolution**: The equality case `a_init(k) = extendPoint p_n` means Spoiler selected the same element twice. In the winning condition, both sides of the biconditional should give the same result for equal elements. Specifically:
- If a_init(k) = p_n and resp_tau(k) has the same rank-r type as p_n/e_n, the formula agreement and ordering are consistent regardless of whether resp_tau(k) = e_n or not.

Actually, we can handle this cleanly: if a_init(k) = extendPoint p_n, then from hform_abig_ainit, a'_big(k) has the same rank-r type as p_n. From hord_big_sel_en, `resp_tau(k) < e_n ↔ a'_big(k) < p_n`. If a'_big(k) = p_n, then resp_tau(k) = e_n (from the `=` part of hord_big_sel_en applied to the `=` part of same_side). The question is whether a'_big(k) = p_n when a_init(k) = p_n.

Since a_init(k) = p_n and a'_big(k) agrees with a_init(k) on rank-r formulas (hform_abig_ainit), a'_big(k) has the same type as p_n. But a'_big(k) need not EQUAL p_n. This is the same issue as before.

**However**, with sorted selections and the GHR93 approach, we sidestep this entirely: we don't USE sel_pn_ord. We construct e_n from U(B, sf_top) transfer, which makes the ordering true by construction. The winning condition assembly uses a different case analysis.

#### B.4: Transfer phi via tau to M-side (~30 lines)

```lean
-- phi holds at a_init(n-1) in N (witnessed by p_n)
-- tau preserves rank-r+4 formulas
-- stavi_depth phi ≤ r ≤ r + 4
-- Therefore phi holds at resp_tau(n-1) in M
```

This requires tau's formula agreement at rank > r. Currently tau gives rank-r agreement. We need the rank-(r+4) tau available via tau_r2 construction (or a weaker rank-(r+2) tau).

Wait — the existing tau from `props.tau` gives rank-r agreement (from the IH at rank r). But GHR93 uses a stronger tau that preserves rank r+4. Let me check...

From SplitPointProps:
```lean
tau : ghr93_duplicator_wins N M atomMap n r d y' c y
```

This is an n-round game at rank **r**. But U(B, sf_top) has depth at most r (from char_k_depth: stavi_depth B + 2 ≤ r, so stavi_depth(std_untl B sf_top) = stavi_depth B + 2 ≤ r). So tau's rank-r agreement IS sufficient for transferring phi!

Wait: `std_untl B sf_top` has `stavi_depth = stavi_depth B + 2`. If `char_k_depth` says `stavi_depth (char_k nf) + 2 ≤ r`, then `stavi_depth(std_untl (char_k nf) sf_top) = stavi_depth(char_k nf) + 2 ≤ r`. So phi has depth ≤ r. Tau preserves rank-r. Transfer works!

**This is excellent**: we don't need tau_r2 at all for this step. The regular tau suffices.

#### B.5: Extract witness z and set e_n (~20 lines)

From M ⊨ std_untl B sf_top (resp_tau(n-1)):
- There exists z : M.carrier with z > resp_tau(n-1) and B(z) in M

Set e_n = extendPoint z.

#### B.6: Remove old forward-game e_n construction (~negative lines)

Delete lines ~1241-1280 (the a_M, a_pad_big, h_d_compat_left construction).

#### B.7: Rebuild winning condition assembly (~100-200 lines)

The round-2 case analysis follows GHR93 exactly:
1. b_sp < c: use sigma
2. c < b_sp < resp_tau(n-1): use tau
3. resp_tau(n-1) < b_sp < e_n: use A-agreement (interval type match)
4. b_sp = e_n: respond with p_n (B-agreement)
5. b_sp > e_n: use C-agreement (continuation formula)

Cases 1 and 2 are already handled in the existing code. Case 4 uses B-agreement (both e_n and p_n satisfy B). Cases 3 and 5 require interval type matching via tau's formula agreement.

---

## 6. Scope Estimate

### Lines Changed per File

| File | Additions | Deletions | Net |
|------|-----------|-----------|-----|
| CaseAnalysis.lean (ghr93_inductive_step) | 30-50 | 0 | +30-50 |
| CaseAnalysis.lean (ghr93_case_II body) | 200-350 | 300-400 | -100 to +50 |
| CaseAnalysis.lean (ghr93_case_II signature) | 5 | 0 | +5 |
| CaseAnalysis.lean (ghr93_cases_II_III_IV call) | 5 | 0 | +5 |
| **Total** | **240-410** | **300-400** | **-60 to +110** |

The net change is modest because we're replacing ~350 lines of forward-game e_n construction with ~250 lines of U(B,A) witness construction.

### Files NOT Changed

- SplitPoint.lean: 0 changes
- Theorem6.lean: 0 changes (sorting happens below it)
- CustomGame.lean: 0 changes
- GapDetection.lean: 0 changes

---

## 7. Risk Assessment

### Low Risk
- **Sorting wrapper**: Mechanical application of Tuple.sort + ghr93_winning_condition_perm. Well-tested Mathlib API. (~30-50 lines, low complexity)
- **B construction**: char_k already threaded. Building `std_untl (char_k nf_pn) (.base Formula.top)` is straightforward. (~10 lines)
- **phi transfer via tau**: tau preserves rank-r formulas, phi has depth ≤ r. Direct application of existing infrastructure. (~30 lines)

### Medium Risk
- **Witness extraction from std_untl**: Need to unfold `stavi_temporal_truth_mu` for `std_untl` and extract the existential witness z. The semantics of `std_untl` in the extended carrier may involve gaps; need z to be an actual point (carrier element). (~20-30 lines, may need careful case analysis)
- **Winning condition assembly**: The 5-way case split for round-2 is well-defined but verbose. Cases 3 and 5 (interval type matching) require showing that tau's formula agreement + interval type agreement give a matching point in N. (~100-200 lines)

### High Risk
- **Equality case (a_init(k) = p_n)**: `Tuple.monotone_sort` gives `≤`, not `<`. If Spoiler selects the same point twice, the equality case arises. GHR93 assumes strict inequality. Resolution: the equality case should be provable from the winning condition symmetry (if a_init(k) = p_n, respond with same element), but needs careful verification. (~30-50 lines, may be tricky)
- **h_d_compat_left removal**: The existing d-compatible forward game construction is deeply woven into the proof. Removing it requires verifying that no downstream sorry depends on it. (~50-100 lines of careful surgery)

### Mitigation
- **Equality case**: Can add a preliminary step that handles duplicate selections before the main proof. If any a_init(k) = p_n, the proof reduces to a simpler n-round game.
- **h_d_compat_left**: Keep it temporarily (it's used for hord_cd_en_pn). Remove only after confirming the U(B,A) approach doesn't need it.

---

## 8. Summary

The correct resolution combines two changes:

1. **Sorting wrapper** at `ghr93_inductive_step`: ensures a_bwd(n) is the maximum, matching GHR93's assumption. Uses `Tuple.sort` + `ghr93_winning_condition_perm`. ~30-50 lines, low risk.

2. **U(B,A) witness construction** inside `ghr93_case_II`: replaces the forward-game e_n with an e_n extracted from `std_untl B sf_top` transfer through tau. This eliminates sel_pn_ord entirely. ~200-350 lines, medium risk.

Neither change alone suffices. Together, they faithfully implement the GHR93 proof strategy.

**Key insight**: The regular tau (rank-r) suffices for phi transfer because `stavi_depth(std_untl B sf_top) = stavi_depth(char_k nf) + 2 ≤ r` (from char_k_depth). No need for tau_r2 or h_r1_univ for this specific step.
