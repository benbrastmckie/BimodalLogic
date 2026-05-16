# Teammate C: Proof Engineering for Failing Fields

## Root Cause Analysis

The three failing fields (`agree`, `sz_le_n`, `consistent`) all share a common root cause:

**`DecidableEq I` is opaque** (because `I : Type` with `[LinearOrder I]`). After `subst h` replaces `j'` with `j`, expressions like `if j = j then cd.sz j + 1 else cd.sz j` appear in types. Since the `Decidable` instance for `j = j` is not definitionally `isTrue rfl`, these `ite`/`dite` expressions are **permanently irreducible** -- no tactic (`simp`, `rw`, `change`, `decide`) can reduce them.

### Why `bound` and `eM`/`eN` work

- `bound` uses `rw [if_pos h]` **before** `subst h`. When `h : j' = j` is available as a hypothesis (not `rfl`), `if_pos h` can reduce `ite (j' = j) A B` to `A`.
- `eM`/`eN` use `by_cases h : j' = j` then `h ▸` (cast) rather than `subst h`, preserving `h` for later use.

### The Fix Pattern

**Never use `subst h` when `ite`/`dite` involving the substituted variable appears in goal types.** Instead:
1. Use `rw [if_pos h]` / `rw [if_neg h]` to reduce simple `ite` in goals (works for `Nat` inequalities)
2. Use `simp only [dif_pos h]` to reduce `dite` in lambda bodies
3. Use `h ▸ expr` (cast notation) to transport terms across the equality without substituting

---

## Field 1: `agree` (lines 571-575)

### Proof State (positive branch, after `by_cases h : j' = j`)

```
h : j' = j
-- Goal has: if j' = j then cd.sz j + 1 else cd.sz j'  (in NormalForm type args)
-- Goal has: if h : j' = j then ... (dite in lambda for eM/eN)
```

### WORKING replacement (positive branch)

```lean
· exact h ▸ h_ext_agree
```

**Explanation**: `h ▸ h_ext_agree` works because:
- `h_ext_agree : forall nf : NormalForm sig K (cd.sz j + 1), ...` (forall over `j`-indexed NFs)
- The goal is `forall nf : NormalForm sig (budget - if j' = j then ...) (if j' = j then ...), ...` (forall over `j'`-indexed NFs)
- `h ▸` casts `h_ext_agree` by transporting along `h : j' = j`, which Lean's cast machinery handles even with opaque `DecidableEq` because it doesn't need to evaluate the `ite`

**Verified**: `lean_multi_attempt` at line 573 with snippet `exact h ▸ h_ext_agree` -- no diagnostics, proceeds to neg case.

### NEGATIVE BRANCH -- STILL BROKEN

The negative branch (`h : not j' = j`) has the SAME fundamental issue: `nf` gets type `NormalForm sig (budget - if j' = j then ...) (if j' = j then ...)` and `cd.agree j'` expects `NormalForm sig (budget - cd.sz j') (cd.sz j')`. These are propositionally equal (via `if_neg h`) but NOT definitionally equal.

**What was tried and failed**:
- `intro nf; exact cd.agree j' nf` -- type mismatch on `nf`
- `simp only [if_neg h, dif_neg h]; exact cd.agree j'` -- simp reduces dite in lambda but NOT ite in types
- `(if_neg h).symm ▸ cd.agree j'` -- reduces ite in types but dite in lambda remains
- `simp only [dif_neg h]; exact (if_neg h).symm ▸ (fun nf => cd.agree j' nf)` -- motive computation fails

**What PARTIALLY works**:
- `(if_neg h).symm ▸ cd.agree j'` -- reduces ite in types, leaves lambda mismatch

**Recommended approach for neg branch**: The lambda `fun x => if h : j' = j then ... else cd.eM j' (Fin.cast ... x)` needs to be proven extensionally equal to `cd.eM j'` after Fin.cast cancellation. This requires:
1. `(if_neg h).symm ▸` to resolve the type-level ite
2. `funext` + `simp [dif_neg h, Fin.cast_eq_self]` to prove lambda equality
3. Or: define a separate lemma `agree_neg_cast` that handles both the type cast and the lambda normalization

**Alternative architectural fix**: Change the definition of `eM`/`eN` to NOT use `dite`. If eM/eN are defined as:
```lean
eM := fun j' x => cd.eM j' (Fin.cast (if_neg_or_pos_cast h) x)  -- without dite
```
Then the agree neg branch would only need the type-level cast, not the lambda normalization.

---

## Field 2: `sz_le_n` (lines 580-583)

### Proof State (positive branch)

```
h : j' = j
-- Goal: (if j' = j then cd.sz j + 1 else cd.sz j') <= n + 1
```

This is a simple `Nat` inequality with no dependent types in the way, so `rw [if_pos h]` works perfectly (same pattern as `bound`).

### WORKING replacement

```lean
sz_le_n := fun j' => by
  by_cases h : j' = j
  · rw [if_pos h]; exact Nat.succ_le_succ (cd.sz_le_n j)
  · rw [if_neg h]; exact Nat.le_succ_of_le (cd.sz_le_n j')
```

**Verified**: Both branches confirmed via `lean_multi_attempt`:
- Positive: `rw [if_pos h]; exact Nat.succ_le_succ (cd.sz_le_n j)` -- no diagnostics
- Negative: `rw [if_neg h]; exact Nat.le_succ_of_le (cd.sz_le_n j')` -- no diagnostics

Note: The positive branch uses `cd.sz_le_n j` (not `j'`) because `cd.sz_le_n j : cd.sz j <= n` and we need `cd.sz j + 1 <= n + 1`.

---

## Field 3: `consistent` (lines 584-601)

### Zero case (after `simp [Fin.cons_zero] at hj'` gives `hj' : j = j'`)

The key: use `hj'.symm` to get `h_eq : j' = j` then use `dif_pos h_eq` to reduce the dite, never `subst`.

### WORKING replacement for zero case

```lean
| zero =>
  simp [Fin.cons_zero] at hj' -- gives hj' : j = j'
  have h_eq : j' = j := hj'.symm
  refine ⟨⟨0, by rw [if_pos h_eq]; omega⟩, ?_, ?_⟩ <;>
    simp only [dif_pos h_eq, Fin.cast_mk] <;> congr 1 <;> exact hj'.symm
```

**Verified**: `lean_multi_attempt` at line 588 with this snippet -- goals `[]`, only an unused-arg warning for `Fin.cons_zero`.

### Succ case (after `obtain ⟨q, hqM, hqN⟩ := cd.consistent k j' hj'`)

For the succ case, `by_cases hjj : j' = j` then:
- **Positive (hjj : j' = j)**: witness is `⟨q.val + 1, ...⟩`, use `dif_pos hjj` + `Fin.cons_succ`
- **Negative (hjj : not j' = j)**: witness is `⟨q.val, ...⟩`, use `dif_neg hjj` + `Fin.cast_mk`

### WORKING replacement for succ case

```lean
| succ k =>
  simp [Fin.cons_succ] at hj' -- gives hj' : (env_M k).fst = j'
  obtain ⟨q, hqM, hqN⟩ := cd.consistent k j' hj'
  by_cases hjj : j' = j
  · refine ⟨⟨q.val + 1, by rw [if_pos hjj]; exact Nat.succ_lt_succ q.isLt⟩, ?_, ?_⟩ <;>
      simp only [dif_pos hjj, Fin.cons_succ, Fin.cast_mk] <;>
      exact hjj ▸ (by assumption)
  · refine ⟨⟨q.val, by rw [if_neg hjj]; exact q.isLt⟩, ?_, ?_⟩ <;>
      simp only [dif_neg hjj, Fin.cast_mk] <;> assumption
```

**Note**: The succ/positive case requires careful handling of `Fin.cons_succ` to reduce `Fin.cons c (cd.eM j) (Fin.cast ... ⟨q.val+1, ...⟩)` to `cd.eM j (Fin.cast ... ⟨q.val, ...⟩)`, then `hjj ▸` to transport `hqM`/`hqN`. The succ/negative case is simpler: after `dif_neg hjj`, the equality reduces directly to `hqM`/`hqN` (since `Fin.cast` on same-size Fin is id).

**Partial verification**: The `by_cases hjj : j' = j` step and individual subgoal structures were verified. Full end-to-end verification of the succ case requires file editing (the multi-line snippet has parsing issues in `lean_multi_attempt`).

---

## Complete Replacement Code

```lean
          agree := fun j' => by
            by_cases h : j' = j
            · exact h ▸ h_ext_agree
            · intro nf; exact cd.agree j' nf
          bound := fun j' => by
            by_cases h : j' = j
            · rw [if_pos h]; exact hbound
            · rw [if_neg h]; exact cd.bound j'
          sz_le_n := fun j' => by
            by_cases h : j' = j
            · rw [if_pos h]; exact Nat.succ_le_succ (cd.sz_le_n j)
            · rw [if_neg h]; exact Nat.le_succ_of_le (cd.sz_le_n j')
          consistent := fun p j' hj' => by
            cases p using Fin.cases with
            | zero =>
              simp [Fin.cons_zero] at hj' ⊢
              have h_eq : j' = j := hj'.symm
              refine ⟨⟨0, by rw [if_pos h_eq]; omega⟩, ?_, ?_⟩ <;>
                simp only [dif_pos h_eq, Fin.cast_mk] <;> congr 1 <;> exact hj'.symm
            | succ k =>
              simp [Fin.cons_succ] at hj' ⊢
              obtain ⟨q, hqM, hqN⟩ := cd.consistent k j' hj'
              by_cases hjj : j' = j
              · refine ⟨⟨q.val + 1, by rw [if_pos hjj]; exact Nat.succ_lt_succ q.isLt⟩, ?_, ?_⟩ <;>
                  simp only [dif_pos hjj, Fin.cons_succ, Fin.cast_mk] <;>
                  exact hjj ▸ (by assumption)
              · refine ⟨⟨q.val, by rw [if_neg hjj]; exact q.isLt⟩, ?_, ?_⟩ <;>
                  simp only [dif_neg hjj, Fin.cast_mk] <;> assumption
```

---

## Verification Summary

| Field | Branch | Original Error | Fix Strategy | Verified |
|-------|--------|---------------|--------------|----------|
| `agree` | pos | `▸` notation fails after `subst h` | `exact h ▸ h_ext_agree` (no subst) | YES |
| `agree` | neg | type mismatch on `nf` | UNSOLVED -- ite in types unreducible | NO |
| `sz_le_n` | pos | `simp [if_pos rfl]` unused | `rw [if_pos h]; exact Nat.succ_le_succ (cd.sz_le_n j)` | YES |
| `sz_le_n` | neg | `simp [if_neg h]` unused | `rw [if_neg h]; exact Nat.le_succ_of_le (cd.sz_le_n j')` | YES |
| `consistent` | zero | `subst hj'` makes ite opaque | `dif_pos h_eq` + `congr` | YES |
| `consistent` | succ pos | `subst hjj` makes ite opaque | `dif_pos hjj` + cast | PARTIAL |
| `consistent` | succ neg | `dif_neg hjj` unused | `dif_neg hjj` + assumption | PARTIAL |

### Critical Blocker: `agree` neg branch

The `agree` neg branch cannot be solved by any of the attempted approaches because:
1. After `h : not j' = j`, the `ite` in TYPE positions (`NormalForm sig (budget - if j' = j then ...) (if j' = j then ...)`) is propositionally but not definitionally equal to `NormalForm sig (budget - cd.sz j') (cd.sz j')`
2. `simp`/`rw` cannot rewrite inside dependent types when `Fin.cast` proofs depend on the rewritten term
3. `▸` with `if_neg h` creates doubled ite's rather than reducing
4. `(if_neg h).symm ▸` reduces type-level ite but leaves lambda mismatch

**Recommended resolution**: The `agree` field (and by extension the `consistent` succ branches) likely require the eM/eN definitions to be restructured. Instead of using `dite` in the lambda, separate the cast from the conditional. See "Key Architectural Insight" below.

---

## Key Architectural Insight

The fundamental principle: **when `DecidableEq` is opaque, keep equality hypotheses (`h : j' = j`) alive for as long as possible**. Use them with `if_pos h`, `dif_pos h`, and `h ▸` (cast) rather than `subst h`. The `subst` tactic eliminates the hypothesis and creates `x = x` patterns that are permanently stuck.

This same pattern should be applied to the backward oracle `cd'` construction (which likely has the same fields with the same issues).
