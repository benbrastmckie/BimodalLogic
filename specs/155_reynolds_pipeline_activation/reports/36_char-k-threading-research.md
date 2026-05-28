# Phase 3C Blocker Research: char_k Threading and U(B,A) Witness Construction

**Task**: 155 (reynolds_pipeline_activation)
**Date**: 2026-05-27
**Focus**: Precise resolution path for same_side blocker, following GHR93 exactly

---

## 1. Circularity Analysis: CONFIRMED NO CIRCULARITY

Import chain from CaseAnalysis.lean to StaviCompleteness.lean:

```
CaseAnalysis.lean
  → SplitPoint.lean
    → DConsistencyTransport.lean
      → Claim1.lean
        → StaviCompleteness.lean (import Decomposition)
```

- `nf_characterizable_by_stavi` (StaviCompleteness.lean:2425) is **public** and already accessible from CaseAnalysis.lean.
- `ghr93_forward_to_backward` (Theorem6.lean:173) is NOT referenced anywhere in StaviCompleteness.lean or its import chain.
- StaviCompleteness.lean imports only `Decomposition.lean → CustomGame.lean`, which defines game structures but not the backward game theorem.

**Conclusion**: Threading `char_k` from `nf_characterizable_by_stavi` into the game theorem creates NO circular dependency. The two are in separate branches of the import DAG.

---

## 2. Accessibility Problem: Private Definitions

The following StaviCompleteness.lean definitions are PRIVATE and inaccessible from CaseAnalysis.lean:

| Definition | Line | Purpose |
|-----------|------|---------|
| `sf_top` | 1321 | StaviFormula representing True |
| `sf_disjList` | 1277 | Disjunction combinator |
| `sf_conjList` | 1328 | Conjunction combinator |
| `sf_disjList_iff` | 1289 | Semantics of disjunctions |
| `sf_conjList_iff` | 1333 | Semantics of conjunctions |
| `nf_exist_sf` | 1566 | The U(B,A) formula constructor |
| `interval_guard_sf` | 1926 | Disjunction of char_k for all NFs |
| `interval_guard_sf_true` | 1932 | Every point satisfies some char_k |

However, the following ARE public and accessible:

| Definition | File:Line | Purpose |
|-----------|-----------|---------|
| `StaviFormula.std_untl` | StaviConnectives.lean:147 | Constructor for standard Until |
| `StaviFormula.base` | StaviConnectives.lean:137 | Constructor for base formulas |
| `StaviFormula.neg` | StaviConnectives.lean:143 | Constructor for negation |
| `StaviFormula.conj` | StaviConnectives.lean:145 | Constructor for conjunction |
| `Formula.top` | (Syntax) | Top formula |
| `stavi_depth` | Defs.lean:164 | Depth calculation |
| `stavi_temporal_truth_mu` | TypeFormulas.lean:279 | mu-relativized truth |
| `nf_characterizable_by_stavi` | StaviCompleteness.lean:2425 | Main characterization theorem |
| `NormalForm` + `Fintype` | NormalForm.lean:178 | Finite enumeration of NFs |
| `Fintype.elems` | Mathlib | Element enumeration |

**Resolution**: We do NOT need to make any private definitions public. All needed constructions can be built directly from public StaviFormula constructors in CaseAnalysis.lean. This is cleaner than exposing internal implementation details.

---

## 3. GHR93 Case II U(B,A) Construction (pp. 115-116, faithful extraction)

### GHR93 Text (Section 8, Case II)

Setup: Spoiler chose a_0 < ... < a_n in [d, y'] with a_n a point. Duplicator uses tau on [d,y']/[c,y] for a_0,...,a_{n-1}, getting resp_tau(0),...,resp_tau(n-1).

GHR93 defines:
- **B = X_{a_n}**: the rank-r type at a_n. This is the conjunction of all rank-r formulas true at a_n.
- Since a_n is a point in [d, y'] ⊆ [x', y'], and the forward game preserves rank-(r+2) formulas:
  - **U^mu(B, sf_top)** holds at a_{n-1} in N_r (witnessed by a_n above a_{n-1})
  - U^mu(B, sf_top) has depth max(r, 0) + 2 = r + 2
  - tau_r2 (the rank-(r+2) backward game on [d,y']/[c,y]) transfers formulas of depth ≤ r+2
  - Therefore U^mu(B, sf_top) transfers from N to M: it holds at resp_tau(n-1) in M_r
  - Extract witness: ∃ z > resp_tau(n-1) in M_r with B(z). Set e_n = z.
- **Result**: resp_tau(k) < e_n holds BY CONSTRUCTION (e_n is above resp_tau(n-1), and resp_tau is ordered).

### Why This Eliminates the Fan Problem

The current code constructs e_n from a SEPARATE forward game (lines 1240-1360 of CaseAnalysis.lean). This creates two independent game responses (a'_big and resp_tau) whose relationship to a_init cannot be bridged. 

GHR93's construction makes e_n a WITNESS of a formula that holds at resp_tau(n-1). The relationship resp_tau(n-1) < e_n is immediate. The ordering e_n vs resp_tau(k) for k < n-1 follows from the ordering resp_tau(k) ≤ resp_tau(n-1) < e_n (which holds because tau preserves ordering and d ≤ a_init(k) ≤ a_init(n-1) ≤ a_n = p_n).

---

## 4. Threading Plan: char_k as Parameter

### Plan v36 Key Insight

The backward game theorem (`ghr93_forward_to_backward_core`) is proved by induction on n (number of rounds). The U(B,A) construction needs `char_k` to materialize B = X_{a_n} as a StaviFormula. But `char_k` comes from the OUTER completeness proof's induction on NF depth k, not from the game theorem's induction.

The approach: add `char_k` and `char_k_correct` as parameters to the entire call chain, supplied by `nf_characterizable_by_stavi`'s IH.

### Functions Requiring New Parameters

#### 4a. `ghr93_case_II` (CaseAnalysis.lean:1188)

Add two parameters after `h_ih_r2`:
```lean
(char_k : NormalForm sig r 1 → StaviFormula)
(char_k_correct : ∀ (nf_k : NormalForm sig r 1)
    (M' : OrderedMonadicStructure sig)
    (t : ExtendedCarrier M' atomMap r),
    mu_holds t →
    (stavi_temporal_truth_mu M' atomMap r t (char_k nf_k) ↔
     nf_eval_nf_mu M' atomMap r 1 (fun _ => t) nf_k))
```

**Note on the type**: GHR93 uses rank-r formulas, and char_k characterizes depth-k NFs where k relates to r. The precise type depends on how `nf_characterizable_by_stavi` connects k to the game rank r. In the completeness proof, the game operates at rank `game_depth sig n` ≤ f(k) where k is the NF depth. The char_k formulas characterize NFs at the depth corresponding to rank r.

**CRITICAL**: The `char_k_correct` property must work with `stavi_temporal_truth_mu` (mu-relativized truth), not `stavi_temporal_truth`. The game operates on extended carriers M_r and uses mu-relativized semantics. The formula transfer via tau_r2's winning condition (`formula_agreement`) provides `stavi_temporal_truth_mu` equivalences at rank r+2.

**File**: CaseAnalysis.lean, line 1188
**Current signature**: 13 parameters (props through h_ih_r2)
**New signature**: 15 parameters (add char_k, char_k_correct after h_ih_r2)

#### 4b. `ghr93_cases_II_III_IV` (CaseAnalysis.lean:4269)

Thread char_k, char_k_correct through to the Case II branch.

**File**: CaseAnalysis.lean, line 4269
**Current signature**: 10 parameters (props through h_ih_r2)
**New signature**: 12 parameters (add char_k, char_k_correct)
**Change in body**: Pass them to `ghr93_case_II` call at line 4308

#### 4c. `ghr93_inductive_step` (CaseAnalysis.lean:4321)

Thread char_k, char_k_correct through.

**File**: CaseAnalysis.lean, line 4321
**Current signature**: 12 parameters (atomMap through h_ih_r2)
**New signature**: 14 parameters (add char_k, char_k_correct)
**Change in body**: Pass them to `ghr93_cases_II_III_IV` call at line 4366

#### 4d. `ghr93_forward_to_backward_core` (Theorem6.lean:31)

Thread char_k, char_k_correct through. Since the function is inducting on n (not k), char_k is a parameter that stays constant.

**File**: Theorem6.lean, line 31
**Current signature**: 13 parameters (atomMap through h)
**New signature**: 15 parameters (add char_k, char_k_correct)
**Change in body**: Pass to `ghr93_inductive_step` call at line 137

#### 4e. `ghr93_forward_to_backward` (Theorem6.lean:173)

Thread char_k, char_k_correct through.

**File**: Theorem6.lean, line 173
**Current signature**: 10 parameters (atomMap through h_r1_univ)
**New signature**: 12 parameters (add char_k, char_k_correct)
**Change in body**: Pass to `ghr93_forward_to_backward_core` call at line 191

### Callers of `ghr93_forward_to_backward` (Impact Analysis)

Only one caller exists:
- `Theorem6.lean:333` inside `stavi_completeness_inductive_step` (if it exists) or the completeness proof. This is where char_k would be SUPPLIED from the outer induction.

Additional callers to check:
```bash
$ grep -rn "ghr93_forward_to_backward\b" Theories/ | grep -v "def \|theorem \|private \|-- "
```
All uses must be updated to pass char_k and char_k_correct.

---

## 5. U(B,A) Construction in Lean (Pseudocode)

### Step 1: Materialize B = X_{a_n} at rank r

```lean
-- p_n is the carrier point (from h_point : IsPoint (a_bwd ⟨n, ...⟩))
-- nf_pn : NormalForm sig r 1 is p_n's unique NF (from nf_exists_unique)
-- B = char_k nf_pn : StaviFormula
-- B has stavi_depth ≤ r (from char_k_correct properties)
let nf_pn := Classical.choose (nf_exists_unique N r 1 (fun _ => extendPoint p_n))
let B := char_k nf_pn
```

**Note**: Need to handle the fact that `nf_exists_unique` works with `nf_eval_nf` on carrier functions, while p_n is accessed via `extendPoint p_n` in the extended carrier. May need `mu_holds` (IsPoint) to bridge.

### Step 2: Construct the Until formula

```lean
-- sf_top can be reconstructed: .base Formula.top
let sf_top' : StaviFormula := .base Formula.top
-- phi = U^mu(B, sf_top') — "exists point above with type B, all points between satisfy top"
-- This simplifies to: "exists point above satisfying B"
let phi := StaviFormula.std_untl B sf_top'
-- stavi_depth phi = max (stavi_depth B) (stavi_depth sf_top') + 2
--                 = max (stavi_depth B) 0 + 2
--                 = stavi_depth B + 2 ≤ r + 2
```

### Step 3: Prove phi holds at rank_embed(a_init(n-1)) in N at rank r+2

```lean
-- a_init(n-1) < extendPoint p_n (from the sorted ordering of a_bwd)
-- p_n is a mu-point (IsPoint)
-- N |= B^mu(p_n) at rank r (from char_k_correct and nf_eval at p_n)
-- rank_embed preserves truth for formulas of depth ≤ r
-- Lift to rank r+2: N_{r+2} |= phi^mu at rank_embed(a_init(n-1))
--   witnessed by rank_embed(extendPoint p_n)
-- The sf_top' guard is trivially satisfied at all points between
```

### Step 4: Transfer phi via tau_r2

```lean
-- tau_r2 : ghr93_duplicator_wins N M atomMap n (r+2) 
--          (rank_embed d) (rank_embed y') (rank_embed c) (rank_embed y)
-- Instantiate tau_r2 with N-selections including rank_embed(a_init(n-1))
-- Get M-responses including resp_r2(n-1) in M_{r+2}
-- Formula agreement at rank r+2: 
--   N |= phi at rank_embed(a_init(n-1)) → M |= phi at resp_r2(n-1)
-- Since stavi_depth phi ≤ r+2 ≤ r+2, the transfer is valid
```

### Step 5: Extract witness e_n

```lean
-- M_{r+2} |= std_untl B sf_top' at resp_r2(n-1) means:
-- ∃ s > resp_r2(n-1), mu_holds s ∧ M |= B at s ∧ (sf_top' trivially satisfied between)
-- Get s as the witness, project to rank r if needed
-- Define e_n := project_to_rank_r(s)
-- resp_tau(n-1) ≤ project_to_rank_r(resp_r2(n-1)) < project_to_rank_r(s) = e_n
```

### Step 6: sel_pn_ord becomes trivial

With the new e_n construction:
- `resp_tau(k) < e_n` for k ≤ n-1 follows from tau ordering + e_n > resp_tau(n-1)
- `a_init(k) < extendPoint p_n` iff `resp_tau(k) < e_n` follows from the tau ordering preservation (tau_r2 preserves orderings at rank r+2, and the projected orderings match at rank r)

The `same_side` sorry is ELIMINATED entirely — it's replaced by a construction where the ordering is BY DEFINITION.

---

## 6. Estimated Changes Per File

| File | Lines Changed | Description |
|------|--------------|-------------|
| CaseAnalysis.lean | ~300-400 | Add char_k params to 3 functions, restructure e_n construction (lines 1240-1360), close sel_pn_ord, close b_resp sorries |
| Theorem6.lean | ~30-50 | Add char_k params to 2 functions, thread through |
| StaviCompleteness.lean | 0 | No changes needed — private defs stay private |
| (callers of ghr93_forward_to_backward) | ~20-40 | Supply char_k at each call site |

**Total**: ~350-490 lines

---

## 7. Risk Assessment

| Risk | Severity | Mitigation |
|------|----------|------------|
| `char_k_correct` needs mu-relativized truth, but `nf_characterizable_by_stavi` provides `stavi_temporal_truth` (non-mu) | HIGH | Need `stavi_temporal_truth` ↔ `stavi_temporal_truth_mu` at mu-points. This exists as a known property (GHR93 Def 8.4, fact 1: "If t ∈ M, then M |= A(t) iff M_r |= A^mu(t)"). Check if already formalized. |
| Rank r vs depth k mismatch: char_k characterizes NFs at depth k, but the game uses rank r. Need r ≤ k or r = game_depth(k). | MEDIUM | The completeness proof controls the relationship. Verify at the call site in `stavi_completeness_inductive_step` or wherever `ghr93_forward_to_backward` is called. |
| Projecting rank-(r+2) witnesses back to rank r | MEDIUM | `rank_embed` has projection infrastructure. Check `rank_embed_point` and related lemmas in TypeFormulas.lean. |
| NormalForm evaluation at extended carrier points (mu_holds requirement) | LOW | `nf_exists_unique` is well-established. Wrap with mu_holds discharge at IsPoint positions. |
| Breaking existing sorry-free code in Cases III/IV | LOW | Cases III/IV don't use char_k — the new parameters are simply threaded through `ghr93_cases_II_III_IV` and only consumed in the Case II branch. |

### Highest Risk Item

The connection between `stavi_temporal_truth` (used by `nf_characterizable_by_stavi`) and `stavi_temporal_truth_mu` (used in the game) is the most critical gap. If no bridge lemma exists, one must be proved (~40-80 lines). GHR93 states this as a basic fact (Def 8.4), so it should be straightforward.

---

## 8. Implementation Order (Recommended)

1. **Thread char_k through the call chain** (Theorem6.lean → CaseAnalysis.lean): pure signature changes, no proof changes. Build should still pass with existing sorries. (~50-80 lines)
2. **Verify mu-truth bridge**: check if `stavi_temporal_truth ↔ stavi_temporal_truth_mu` exists for mu-points. If not, prove it. (~0-80 lines)
3. **Restructure e_n construction** in `ghr93_case_II`: replace lines 1240-1360 with U(B,A) witness extraction. This is the core mathematical work. (~150-250 lines)
4. **Close sel_pn_ord** at both sorry sites (lines 1585, 1965): should become trivial or eliminable after e_n restructuring. (~20-40 lines)
5. **Close b_resp sorries** (lines 2180, 2233): depend on e_n properties. (~40-80 lines)
6. **Build verification**: `lake build` passes with strictly fewer sorries.
