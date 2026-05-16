# Teammate D Findings: Minimal Interface Analysis of CompData and build_bicompat

**Task**: 154 - sum_preservation_ef_games
**Date**: 2026-05-16
**Focus**: What does CompData/build_bicompat ACTUALLY require? Is restructuring justified?

## 1. CompData Construction Site Map

### Site 1: Forward Oracle cd' (lines 556-602)

**Context**: Inside `build_bicompat`, case `d+1`, forward `oracle_step`, recursive call at depth `d'`.

**What it builds**: CompData for extended environments `Fin.cons <j,c> env_M` and `Fin.cons <j,c'> env_N`.

**Inputs consumed from the PRIOR cd**:
- `cd.sz j` (the old size at index j)
- `cd.eM j` (old embeddings at j)
- `cd.eN j` (old embeddings at j)
- `cd.sz_le_n j` (old size bound, used for `hbound` derivation)
- `cd.bound j'` (other components' bound, else-branch)
- `cd.agree j'` (other components' agree, else-branch)
- `cd.consistent k j' hj'` (all components, threaded through)

**Critical new values provided**:
- `h_ext_agree` (component NF agreement for extended env)
- `hK_eq2 : K = budget - (cd.sz j + 1)`
- `hbound : cd.sz j + 1 < budget`

**The sz assignment**: `fun j' => if j' = j then cd.sz j + 1 else cd.sz j'`

### Site 2: Backward Oracle cd' (lines 647-683)

**Context**: Symmetric to Site 1 (backward direction: given c, find c').

**Pattern**: Structurally identical to Site 1. Uses same sz, eM, eN patterns. Same blockers apply.

**Difference from Site 1**: The backward oracle uses a different coding style:
- Site 1: tactic-mode `by_cases h` for eM/eN
- Site 2: term-mode `if h : j' = j then h cast Fin.cons ... else cd.eM j'`

This means Site 2 has DIFFERENT errors (lines 644-646: "Invalid projection" and type mismatch from term-mode h_idx').

### Site 3: cd0 in sum_lift_one_var (lines 787-828)

**Context**: Base case construction. Environment has exactly 1 element `<i, a>` in M and `<i, b>` in N.

**What it builds**: Initial CompData with:
- `sz = fun j' => if j' = i then 1 else 0`
- `eM i = ![a]`, `eM j' = Fin.elim0` (for j' != i)
- `eN i = ![b]`, `eN j' = Fin.elim0` (for j' != i)

**Unique constraints**:
- `bound`: requires `sz j' < k + 1`, i.e., `1 < k + 1` when `j' = i`. FAILS at k=0.
- `sz_le_n`: requires `sz j' <= 1` (since n=1). Field is MISSING from current code.
- `agree`: requires NF agreement at depth `k + 1 - sz j'`. For j'=i: depth k, 1 var. For j'!=i: depth k+1, 0 vars.

**Why cd0 is simpler**: No recursive reference to a prior cd. Everything is fresh. But it has the k=0 problem for `bound`.

### Summary: Total Construction Sites = 3

| Site | Lines | Pattern | Error Count |
|------|-------|---------|-------------|
| Forward oracle cd' | 556-602 | Extension (sz+1 at j) | 8 errors |
| Backward oracle cd' | 647-683 | Extension (sz+1 at j) | 3 errors |
| cd0 base case | 787-828 | Initial (sz=0 or 1) | 11 errors |

## 2. Field-by-Field Difficulty Analysis

### Fields that ARE the source of difficulty (ite-contaminated)

**`agree`** -- The HARDEST field. After `by_cases h : j' = j`:
- The positive case needs to show NF agreement for `Fin.cons c (cd.eM j)` at depth `budget - (cd.sz j + 1)`.
- The TYPE of `nf` in the goal contains `if j' = j then cd.sz j + 1 else cd.sz j'` (from `sz`). After `subst h`, this becomes `if j = j then ...` which does NOT reduce because `DecidableEq I` (from `LinearOrder I`) is opaque.
- This is the CORE blocker. Round 7 found: use `simp only [if_pos h]` BEFORE `intro nf` (works on goal type) or use `hK_eq2 cast nf` transport. But integration in the actual file creates errors (line 574: "invalid cast notation").

**`sz_le_n`** -- Medium difficulty. After `subst h`:
- Goal contains `(if j = j then cd.sz j + 1 else cd.sz j) <= n + 1`
- `if j = j` does not reduce (same opaque DecidableEq issue)
- Fix: use `rw [if_pos h]` BEFORE `subst` (while `h : j' = j` still exists)

**`consistent`** -- Medium-high difficulty:
- The zero case after `simp [Fin.cons_zero]` gives `hj' : j = j'` (note: reversed direction)
- Must provide witness of type `Fin (if j' = j then cd.sz j + 1 else cd.sz j')` -- ite in type again
- After `subst hj'`, witness type has `if j = j then ...` -- same DecidableEq opacity
- Must use `simp [if_pos rfl]` or `show`/`rw` before introducing the witness

### Fields that are merely contaminated by ite (not intrinsically difficult)

**`sz`** -- Trivial to define: `fun j' => if j' = j then cd.sz j + 1 else cd.sz j'`
No proof obligations. Just a function definition.

**`eM` / `eN`** -- SOLVED. Tactic-mode `by_cases h : j' = j` with `h cast @Fin.cons ... (Fin.cast (if_pos h) x)` works. Verified working in the forward oracle (lines 561-565 compile).

**`bound`** -- SOLVED. `by_cases h : j' = j; rw [if_pos h]; exact hbound; rw [if_neg h]; exact cd.bound j'` works (lines 576-579 compile).

### Diagnosis

The difficulty is ENTIRELY in three fields: `agree`, `sz_le_n`, and `consistent`. All three share the same root cause: after `subst h` (or in contexts where `h : j' = j` must be consumed), the `ite` in dependent type positions becomes `ite (j = j) ...` which is irreducible. The key insight from round 7 is: perform `rw [if_pos h]` or `simp only [if_pos h]` BEFORE the `subst` / BEFORE introducing variables whose types contain the ite. But the integration in the actual 1133-line file creates cascading elaboration issues.

## 3. Analysis of the sz Representation Question

### Current: `sz : I -> Nat` with ite-based extension

**Pros**: Simple definition. Direct pattern matching on function values.
**Cons**: Extension creates `ite` in TYPE positions that Lean's elaborator cannot reduce.

### Alternative A: `Function.update cd.sz j (cd.sz j + 1)`

**Semantically identical** to the current ite pattern. `Function.update` IS defined as:
```lean
def Function.update (f : alpha -> beta) (a : alpha) (b : beta) (a' : alpha) :=
  if a' = a then b else f a'
```
So this is literally the same ite under the hood. The advantage would be `simp [Function.update_same]` and `simp [Function.update_noteq h]`. But these simp lemmas face the same opaque DecidableEq issue -- they rewrite the VALUE, not the TYPE.

**Verdict**: Does NOT help with the core blocker. The ite in TYPES (Fin (sz j'), NormalForm sig (budget - sz j') (sz j')) remains irreducible regardless of whether sz is written as `if` or `Function.update`.

### Alternative B: Finsupp

**Conceptually appealing** -- sz measures how many elements have been placed per component. Most components have 0 elements. But `Finsupp` is heavier machinery and doesn't avoid the fundamental issue: dependent types still reference `sz j'` which must equal either the new value or the old value.

**Verdict**: Does NOT help.

### Alternative C: Make sz opaque (parametric CompData)

Instead of computing sz inside CompData, pass it as a PARAMETER with proof obligations:
```lean
structure CompData (sz : I -> Nat) ... where
  eM : (j : I) -> Fin (sz j) -> (ms j).carrier
  ...
```

Then extensions would be:
```lean
have sz' := fun j' => if j' = j then cd.sz j + 1 else cd.sz j'
have cd' : CompData sz' ...
```

This doesn't help either -- `sz'` still contains the ite, and the dependent fields still reference `sz' j'`.

### Alternative D: Avoid ite entirely -- separate j from non-j

This is the ONLY approach that could truly eliminate the ite:

```lean
structure CompDataSplit ... where
  sz_j : Nat  -- size at the distinguished index j
  sz_other : (j' : I) -> j' != j -> Nat  -- sizes at other indices
  eM_j : Fin sz_j -> (ms j).carrier
  eM_other : (j' : I) -> (h : j' != j) -> Fin (sz_other j' h) -> (ms j').carrier
  ...
```

Then the extension increments `sz_j` to `sz_j + 1` and leaves `sz_other` unchanged -- no branching needed. But this requires:
1. Splitting CompData into distinguished/non-distinguished parts
2. A recombination lemma to go from Split back to the original form for the recursive call
3. All helper theorems (orderedSum_order_fwd_via_comp, etc.) to work with the split representation

**Effort estimate**: 6-10 hours to restructure. Very high risk of introducing new blockers.

## 4. Could CompData be Split into Shape/Data/Correctness?

### Proposed split:
- **Shape**: `{sz : I -> Nat, bound : forall j, sz j < budget, sz_le_n : forall j, sz j <= n}`
- **Data**: `{eM : (j : I) -> Fin (sz j) -> (ms j).carrier, eN : ...}`
- **Correctness**: `{agree : ..., consistent : ...}`

### Assessment

This split does NOT help with the fundamental blocker because:
1. Data depends on Shape (eM's type references sz)
2. Correctness depends on both Shape and Data (agree references sz, eM, eN)
3. The ite-in-types problem occurs when constructing ALL layers (Shape, Data, Correctness) of the extended cd'
4. Lean processes structure fields sequentially -- splitting into separate structures doesn't change the elaboration order or the ite-in-types issue

**Verdict**: Restructuring CompData's FIELD ORGANIZATION does not address the root cause. The root cause is that `if j' = j then X else Y` in a TYPE position is irreducible.

## 5. What Has Been Tried (Complete Catalog)

### Rounds 1-4: Mathematical Architecture (Reports 01-04)

| Round | Approach | Outcome |
|-------|----------|---------|
| 1 | Per-element 1-var NF hypothesis + induction on k | Order atom blocker: 1-var NF has no order info |
| 2 | Joint multi-var NF characteristic equality | Correct mathematically but formalization too complex |
| 3 | Bootstrap sentence-level (n=0) then lifting lemma | Off-by-one depth budget: lifting at depth k needs k+1 budget |
| 4 | Literature-guided EF game translation | Same off-by-one; correctly diagnosed as fundamental gap |
| 4b | BiCompat recursive witness oracle + CompData tracking | CORRECT ARCHITECTURE (sorries removed), build errors remain |

### Rounds 5-7: Build Error Resolution (Reports 05-07)

| Round | Approach | Outcome |
|-------|----------|---------|
| 5 | Diagnosed 2 root causes (h_idx' opacity + cd0 bound). Proposed `let envM_ext` + k-split | Partially correct diagnosis, implementations failed |
| 6 | Cluster 1 (h_idx' fix via @Fin.cons motive) + Cluster 2 (cd0 k-split + transparent eM/eN) | h_idx' fix verified; cd0 partially works; agree/consistent still blocked |
| 7 | Three verified patterns: dite+Fin.cast, simp-before-intro, Function.update | ALL verified in isolation; integration creates cascading errors |

### Implementation Attempts (Plans v2-v11, 10+ attempts)

| Attempt | Plan Version | Key Approach | Outcome |
|---------|-------------|--------------|---------|
| 1 | v2 | Direct proof with `h_elem` hypothesis | Order atom blocker (4 sorries) |
| 2 | v3 | Joint NF characteristic | Formalization too complex |
| 3 | v4 | Bootstrap + BiCompat | Architecture correct, build errors |
| 4 | v5 | Phase 1: BiCompat definitions | COMPLETED (no build errors in new code) |
| 5 | v6 | Build_bicompat extension + cd0 | `subst` creates irreducible ite |
| 6 | v7 | Team implement: multiple agents | Integration failure across agents |
| 7 | v8 | extend_CompData helper function | Same ite-in-types in helper |
| 8 | v9 | `rcases (inferInstance : Decidable ...)` | Opaque Decidable.casesOn metavars |
| 9 | v10 | Classical.dec, match decEq, restructure | All blocked; DecidableEq fundamentally opaque |
| 10 | v11 | dite+Fin.cast (from round 7 research) | PARTIAL: eM/eN/bound work, agree/sz_le_n/consistent blocked |

### The 17 Specific Approach Patterns Tried (From Handoff Analysis)

1. `if j' = j then ... else ...` (original ite)
2. `dite (j' = j) (fun h => ...) (fun h => ...)` (dependent ite)
3. `match decEq j' j` (doesn't exist in Lean 4)
4. `match inferInstance : Decidable (j' = j)` with pattern match (sort error)
5. `rcases (inferInstance : Decidable (j' = j))` + subst (wrong variable eliminated)
6. `rcases (inferInstance : Decidable (j = j'))` (right direction but opaque metavars)
7. `split_ifs with h` then `subst h` (wrong variable direction)
8. `simp only [h, if_pos rfl]` (can't rewrite through opaque DecidableEq)
9. `rw [if_neg h]` (motive not type correct in dependent types)
10. `show ... from by rw [if_pos h]; exact ...` (works for eM/eN, not agree)
11. `convert cd.agree j' nf` (too many HEq subgoals)
12. `@Decidable.rec` in term mode (universe issues)
13. `Decidable.casesOn` in refine (opaque downstream)
14. `nf_agreement_monotone` bridge (types same but wrapped in opaque ite)
15. `Function.update` + named def (same ite under the hood)
16. `Classical.dec` instead of instDecidableEq (also opaque)
17. `constructor` + separate `case` blocks (opaque metavar sharing)

## 6. What Has NOT Been Tried

### A. The "Avoid subst Entirely" Strategy

The round 7 insight is clear: `simp only [if_pos h]` BEFORE `intro nf` can reduce ite in goal TYPES while `h : j' = j` is still a hypothesis (not yet consumed by subst). This was verified in standalone tests but the current file code at line 573-574 uses `subst h` FIRST and then tries to transport, which fails.

**What's needed**: Rewrite the agree field as:
```lean
agree := fun j' => by
  by_cases h : j' = j
  · -- DO NOT subst h here. Instead:
    simp only [if_pos h]  -- reduces ite in GOAL types
    -- Now goal has clean types without ite
    rw [h]  -- or subst h AFTER simp reduced the ite
    intro nf
    exact ...
  · simp only [if_neg h]
    exact cd.agree j'
```

**Why it hasn't been tried in the actual file**: The current code (line 573) does `subst h` immediately. The handoff notes say `simp only [if_pos h]` was verified at line 550 via `lean_multi_attempt` in round 7, but the FILE was never updated to use this ordering. The plan v11 documents this as "Correction 1" but the implementation was never completed.

### B. Separate the ite-contaminated `agree` into its own lemma

Define:
```lean
private theorem CompData.extend_agree (...) (h : j' = j)
    (nf : NormalForm sig (budget - (cd.sz j + 1)) (cd.sz j + 1)) :
    nf_eval_nf (ms j') (budget - (cd.sz j + 1)) (cd.sz j + 1)
      (h cast Fin.cons c (cd.eM j)) nf <->
    nf_eval_nf (ms' j') (budget - (cd.sz j + 1)) (cd.sz j + 1)
      (h cast Fin.cons c' (cd.eN j)) nf := by
  subst h
  exact h_ext_agree (cast_proof ... nf)
```

By separating this into its own lemma, the `subst h` happens in a context where the GOAL type doesn't contain `ite` -- because the lemma's statement uses `budget - (cd.sz j + 1)` and `cd.sz j + 1` directly, not `ite`. Then in the CompData literal, the agree field simply invokes this lemma.

**Why this hasn't been tried**: All 10 implementation attempts worked INSIDE the CompData literal. No attempt extracted the agree proof into a standalone helper theorem with the "right" types in its statement.

### C. Use `Eq.mpr` / `cast` with explicit type rewrites instead of `subst`

Instead of trying to make Lean reduce `if j = j then X else Y` in dependent types, use explicit `cast` or `Eq.mpr` to transport between `NormalForm sig (budget - (if j' = j then cd.sz j + 1 else cd.sz j')) (if j' = j then cd.sz j + 1 else cd.sz j')` and `NormalForm sig (budget - (cd.sz j + 1)) (cd.sz j + 1)`:

```lean
agree := fun j' => by
  by_cases h : j' = j
  · intro nf
    have heq1 : (if j' = j then cd.sz j + 1 else cd.sz j') = cd.sz j + 1 := if_pos h
    have nf' : NormalForm sig (budget - (cd.sz j + 1)) (cd.sz j + 1) :=
      heq1 ▸ nf  -- or cast (by rw [heq1]) nf
    ...
```

The question is whether `heq1 ▸ nf` works when `nf`'s type has the ite embedded in two places (both the depth and the var count arguments of NormalForm). This is a `▸` on a non-dependent motive through a complex dependent type -- it MAY work because NormalForm is a concrete inductive and `▸` can compute through it.

### D. Define CompData with explicit Nat parameters instead of computed sz

```lean
structure CompData' ... (sz_val : I -> Nat) (h_sz_eq : sz_val = fun j' => if j' = j then cd.sz j + 1 else cd.sz j') where
  eM : (j : I) -> Fin (sz_val j) -> (ms j).carrier
  ...
```

Then `sz_val j` is a free variable, not an ite expression. The `h_sz_eq` proof is only needed when connecting to the actual values. Fields can be defined without ever touching ite.

### E. The "Nuclear Option": Rewrite build_bicompat to avoid CompData extension entirely

Instead of extending CompData one element at a time (which creates the ite), restructure the entire proof to:
1. Build CompData for the FULL budget upfront using `nf_agreement_monotone` on each component
2. Use this pre-built CompData in a single shot without needing to extend it

This would eliminate the extension step entirely. The question is whether the mathematical argument supports this -- and it does NOT directly, because the EF game argument inherently extends the environment one element at a time.

## 7. Recommendation

### Option 1: Fix-in-Place (Estimated effort: 3-5 hours)

**Strategy**: Apply the "simp before intro" pattern from round 7 at ALL three contaminated fields (agree, sz_le_n, consistent), combined with the verified dite+Fin.cast pattern for eM/eN/bound.

**Key change from all prior attempts**: The agree field must use `simp only [if_pos h]` (or `rw [if_pos h]`) BEFORE introducing `nf`, not after `subst h`. The sz_le_n and consistent fields similarly must reduce ite BEFORE subst.

**Risk**: MEDIUM. Verified in standalone tests (round 7, Teammate A) but never integrated. The main risk is that `simp only [if_pos h]` may not be able to rewrite through the complex dependent type of `NormalForm sig (budget - (if j' = j then ...)) (if j' = j then ...)` -- it needs to rewrite BOTH occurrences of the ite simultaneously.

**If `simp only [if_pos h]` fails on the NormalForm type**: Fall back to approach B (extract agree into a helper lemma with clean types).

### Option 2: Extract Proof Obligations into Helper Lemmas (Estimated effort: 5-8 hours)

**Strategy**: Define 3 helper lemmas (CompData.extend_agree_pos, CompData.extend_sz_le_n_pos, CompData.extend_consistent_zero, CompData.extend_consistent_succ) each with CLEAN type signatures that avoid ite in dependent positions. Then the CompData literal just calls these helpers.

**Key insight**: The CompData DEFINITION has ite in types. But the LEMMA statements can use the concrete values (cd.sz j + 1 for the positive case, cd.sz j' for the negative case) with explicit equality proofs connecting them to the ite. The `subst` or `cast` happens INSIDE the helper lemma, in a controlled context.

**Risk**: LOW. This is a purely mechanical decomposition. Each helper lemma has a clear mathematical meaning. The approach was never tried because all attempts worked inside the structure literal.

### Option 3: Full Restructure (Estimated effort: 10-15 hours)

**Strategy**: Redesign CompData to avoid ite in types entirely (Alternative D from section 3 -- separate j from non-j). This would eliminate the root cause but requires rewriting all helper theorems and the entire build_bicompat structure.

**Risk**: LOW (eliminates root cause) but HIGH EFFORT. Only justified if Options 1 and 2 both fail.

### My Recommendation: Option 1 first, Option 2 as fallback

1. Try the "simp/rw before intro/subst" pattern on the actual file (3 hours max)
2. If it fails on agree, extract agree into a helper lemma (Option 2B, 2 hours)
3. If systematic issues persist, do the full helper lemma extraction (Option 2, 5 hours)
4. Only resort to Option 3 if fundamental issues make Options 1-2 impossible

The CRITICAL implementation instruction that has been consistently missed across 10 attempts: **In the positive case of `by_cases h : j' = j`, REDUCE the ite BEFORE consuming h (via subst) or introducing dependent variables (via intro).** The order is: `by_cases h` -> `rw [if_pos h]` or `simp only [if_pos h]` -> then `subst h` or `intro nf`.

## 8. Current Build Error Breakdown

Total errors: 22 (from `lake build`)

**Forward oracle cd' (lines 574-601): 8 errors**
- Line 574: `agree` field -- `subst h` then `▸` fails (invalid cast notation)
- Lines 575, 582: Application type mismatches in agree/sz_le_n
- Lines 589-590: Unsolved goals in consistent (zero case)
- Lines 596, 599: No goals to be solved in consistent (succ case)

**Backward oracle cd' (lines 644-646): 3 errors**
- Lines 644-645: "Invalid projection" -- h_idx' uses term-mode `Fin.cases rfl (fun k => h_idx k)` which doesn't resolve `.1` on opaque `show T from` terms
- Line 646: Type mismatch cascading from h_idx'

**cd0 in sum_lift_one_var (lines 787-827): 11 errors**
- Line 787: Missing `sz_le_n` field
- Lines 803: Unknown identifier `i` (scoping after simp in agree)
- Lines 807-809: `funext`/`apply` failures in agree/convert
- Lines 815-817: simp no progress, application type mismatch
- Lines 820-821: omega unprovable (bound at k=0), no goals
- Line 827: Application type mismatch in consistent

## 9. Synthesis: What We Know After 7 Research Rounds + 10 Implementation Attempts

1. **The mathematical architecture is CORRECT**. BiCompat + CompData + sum_nf_lift_gen + sum_nf_agree_sentence is the right design. Zero sorries remain. The problem is purely one of Lean elaboration.

2. **The root cause is ONE thing**: `ite (j' = j) X Y` in TYPE positions (specifically as arguments to `NormalForm`, `Fin`, and `nf_eval_nf`) does not reduce because `DecidableEq I` is opaque. This affects ONLY 3 fields: agree, sz_le_n, consistent.

3. **The fix is known**: Reduce the ite BEFORE introducing variables whose types depend on it. Specifically: `by_cases h -> rw [if_pos h] -> intro nf` (not `by_cases h -> intro nf -> subst h`).

4. **The fix was never correctly applied to the file**: All 10 implementation attempts either (a) used `subst` before reducing ite, or (b) were verified in standalone snippets but not integrated into the actual file.

5. **The backward oracle has a SEPARATE issue** from the forward oracle: it still uses the term-mode h_idx' pattern (`Fin.cases rfl (fun k => h_idx k)`) which doesn't work with `show T from` opacity. This is independently fixable by applying the same tactic-mode pattern used in the forward oracle.

6. **cd0 has a THIRD independent issue**: the `bound` field is unprovable at k=0. This requires either (a) a k-split at the top of `sum_lift_one_var` (k=0 returns trivial, bypassing cd0), or (b) weakening bound to `sz j <= budget` (which breaks downstream omega proofs). The k-split is the right approach and was verified.

7. **No restructuring of CompData is needed** to solve this problem. The issue is entirely in how the PROOFS construct CompData values, not in CompData's definition. The `sz_le_n` field addition was necessary and already done.
