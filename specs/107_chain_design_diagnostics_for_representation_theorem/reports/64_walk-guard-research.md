# Walk Guard Invariant Research Report

## Summary

The walk guard invariant requires proving `pc.ξ ∈ val.g a b` for every adjacent pair (a, b) between pc.x and the C5 witness y. This is needed at 8 build error sites in CounterexampleElimination.lean and feeds into 2 sorry sites in ChronicleConstruction.lean. The fundamental issue is a structural mismatch between the code's walk implementation (which jumps to u_max = max of the walk set U) and the Burgess 2.10 proof (which walks step by step via induction on n). The code's u_max does not track the guard at intermediate adjacent pairs, and this guard CANNOT be derived from BurgessR3Maximal alone. The fix requires restructuring the condition (i) branch to use explicit recursion on the number of domain points after the starting point.

## 1. How the Walk Works in the Code (Step by Step)

### Current Code Structure (lines 864-1282)

When condition (i) holds at (pc.x, x'):
1. **Line 866**: Check `h_cond_i : conj ∈ f(x') ∧ ξ ∈ g(pc.x, x')`
2. **Line 872-878**: Compute walk set `U = {w ∈ dom : pc.x ≤ w ∧ U(ξ,η) ∈ f(w)}`
3. **Line 878**: Set `u_max = max(U)`
4. **Line 888**: Case split on `u_max = max_old`:
   - **Walk A** (u_max = max_old, lines 889-995): Place fresh y > max_old, use lemma_2_4_with_guard
   - **Walk B** (u_max < max_old, lines 996-1281):
     - Find u_next = successor of u_max in dom (line 1003)
     - **Line 1032**: Case split on `η ∈ f(u_next)`:
       - **Eta-shortcut** (η ∈ f(u_next), lines 1033-1051): Return χ unchanged, witness = u_next
       - **Splitting** (η ∉ f(u_next), lines 1052-1281): Split at (u_max, u_next), insert z = midpoint

### Mismatch with Burgess 2.10

The paper's proof works by **induction on n** (points after x):
- n=0: lemma 2.4 (base case)
- n=m+1: Check condition (i) at (x, x'). If holds, **replace x by x'** (reducing n by 1) and recurse. If fails, split at (x, x').

The paper walks step by step, obtaining the guard ξ ∈ g(x, x') at EACH step from condition (i). The code jumps to u_max without tracking intermediate guards.

### Critical Difference

The code's walk set U = {w : U(ξ,η) ∈ f(w)} does NOT equal the paper's walk endpoint. Condition (i) checks TWO things: (1) conj ∈ f(successor), (2) ξ ∈ g(current, successor). Part (2) is NOT derivable from U-membership alone. So there can be gaps where a point is in U but the guard fails at the adjacent pair.

## 2. Whether Condition (i) Tracking is Available or Discarded

**Discarded.** Condition (i) is checked ONCE at (pc.x, x') on line 866. The result `h_cond_i.2` gives `ξ ∈ g(pc.x, x')`. This is the guard for the FIRST pair only. No subsequent pairs are checked.

For intermediate pairs (a, b) with pc.x < a < b ≤ u_max:
- `a ∈ U` gives U(ξ,η) ∈ f(a), but NOT ξ ∈ g(a, b)
- BurgessR3Maximal(f(a), g(a,b), f(b)) does NOT imply ξ ∈ g(a,b) (see Section 2.1)
- The guard at (a, b) is neither tracked nor derivable

### 2.1 Why BurgessR3Maximal Cannot Provide the Guard

BurgessR3Maximal(A, B, C) says:
- `burgessRSet(A, B, C)`: ∀ β ∈ B, ∀ γ ∈ C, untl(β, γ) ∈ A (CONTENT direction)
- `burgessRSetSince(C, B, A)`: ∀ β ∈ B, ∀ γ ∈ A, snce(β, γ) ∈ C
- Maximality over CUD extensions

This goes A → B → C: if β ∈ B then untl(β, γ) ∈ A. We need B ← A: from untl(ξ,η) ∈ A, derive ξ ∈ B. This is the REVERSE direction.

The codebase's `rRelation(A, B)` (obligation propagation) provides this: untl(γ,δ) ∈ A → δ ∈ B ∨ (γ ∈ B ∧ untl(γ,δ) ∈ B). But BurgessR3Maximal uses `burgessRSet` (content-based), NOT `rRelation`. These are fundamentally different (ChronicleTypes.lean:273-285) and NEITHER implies the other.

Maximality might help (if ξ ∉ B, consider DC(B ∪ {ξ}) and use the neg-until witness), but this gives: ∃ β₀ ∈ B, γ₀ ∈ C, untl(β₀ ∧ ξ, γ₀).neg ∈ A. This does NOT contradict untl(ξ, η) ∈ A in general (different formulas).

## 3. The Exact Proof Structure for the Walk Guard Invariant

### Required Approach: Explicit Recursion

Replace the walk set U / u_max computation with recursion on `n = |{w ∈ dom : w > start}|`:

```
c5_forward_recursive(χ, start, ξ, η, h_untl, h_no_wit, n_points_after):
  if start = max_old (n=0):
    -- Base: use lemma_2_4_with_guard
    -- Guard: only pair (max_old, y) → ξ ∈ B from lemma_2_4_with_guard
    DONE
  else (n ≥ 1):
    let x' = successor of start in dom
    if condition_i_holds(start, x'):  -- conj ∈ f(x') ∧ ξ ∈ g(start, x')
      -- RECURSE: c5_forward_recursive(χ, x', ξ, η, ..., n-1)
      -- Recursive result gives: witness y, guard at pairs from x' to y
      -- Compose: ξ ∈ g(start, x') from condition (i) + recursive guard
      DONE
    else:
      -- Split at (start, x'): use splitting lemmas
      -- Guard: only pair (start, z) → ξ ∈ B' from splitting result
      DONE
```

### Guard Composition in the Recursive Case

When condition (i) holds at (start, x'):
1. `ξ ∈ g(start, x')` from condition (i) part 2
2. Recursive call produces `y_rec` and guard at all adjacent pairs from x' to y_rec in the new domain
3. The new point (if any) is inserted AFTER x', so (start, x') remains adjacent in the new domain
4. `g_agrees` for old domain pairs: g'(start, x') = g(start, x'), so ξ ∈ g'(start, x')
5. Full guard = {(start, x')} ∪ {recursive guard at pairs from x' to y}

### Proof that No Walk Pair is Affected by Insertion

The recursive call inserts a point z with x' < z (either between two points after x', or beyond max_old). The pair (start, x') has both start and x' in the old domain, and z is after x', so no point is inserted between start and x'. Therefore (start, x') remains adjacent in the new domain.

## 4. What Code Changes are Needed

### Phase 1: Extract Recursive Helper (estimated ~150 lines)

Create a well-founded recursive function:

```lean
private noncomputable def c5_forward_helper
    (χ : Chronicle) (h_c0 : χ.c0) (h_c2' : χ.c2')
    (h_nubr3 : NoUnivBurgessR3)
    (start : Rat) (ξ η : Formula)
    (h_start_mem : start ∈ χ.dom)
    (h_untl : Formula.untl ξ η ∈ χ.f start)
    (h_no_wit : ¬∃ y ∈ χ.dom, start < y ∧ η ∈ χ.f y ∧
      ∀ a b, Adjacent χ.dom a b → start ≤ a → b ≤ y → ξ ∈ χ.g a b)
    (n : Nat) (hn : n = (χ.dom.filter (fun w => decide (start < w))).card) :
    -- Returns: extended chronicle with witness and guard
    ∃ val : Chronicle,
      χ.dom ⊆ val.dom ∧ val.c0 ∧ val.c2' ∧
      (∀ x ∈ χ.dom, val.f x = χ.f x) ∧
      (∀ a b, a ∈ χ.dom → b ∈ χ.dom → val.g a b = χ.g a b) ∧
      (∃ y ∈ val.dom, start < y ∧ η ∈ val.f y ∧
        ∀ a b, Adjacent val.dom a b → start ≤ a → b ≤ y → ξ ∈ val.g a b) ∧
      -- Additional fields for EliminationResult
      ... := by
  -- Well-founded recursion on n
```

The recursion terminates because the number of domain points after `start` strictly decreases when we replace `start` by `x'`.

### Phase 2: Replace Walk Cases with Helper Call (~50 lines change)

In `eliminate_potential_counterexample`, when condition (i) holds:
- Delete the walk set U, u_max, Walk A, Walk B code (~300 lines)
- Replace with a single call to c5_forward_helper

### Phase 3: Fix Not-Condition(i) Splitting (Error 4, ~20 lines)

Add `ξ ∈ B'` to h_split_result return type. In each sub-case:
- lemma_2_6 + ξ ∈ g: `h_g_sub_B' (ξ ∈ g)` gives ξ ∈ B'
- lemma_2_7: returns ξ ∈ B' directly
- lemma_2_8: returns ξ ∈ B'
- lemma_2_7 with conj: returns conj ∈ B'; since B' is CUD, ξ ∈ B' from conjunction elimination
- lemma_2_6 + ξ ∉ g: redirect to lemma_2_7 with ξ

Then in c5_forward_witness: only one adjacent pair (start, z), and ξ ∈ B' = g'(start, z).

### Phase 4: Fix Backward Cases (Mirror, ~300 lines)

1. Update backward h_actual to use adjacent-pair guard (line 1538-1539)
2. Mirror the recursive helper for Since
3. Mirror the not-condition(i) fix

### Phase 5: Connect to Limit (2 sorry sites, ~30 lines)

With the EliminationResult guard available, prove limit_satisfies_c5_strong:
1. At stage n, c5_forward_witness gives guard at all adjacent pairs
2. For any intermediate w in limit_dom: w was introduced at some stage m
3. At stage m, w is between some adjacent pair (a, b) in dom_m
4. ξ ∈ g_m(a, b) by the stage-level guard (propagated through g_agrees and g_sub_g_new)
5. ξ ∈ f_{m+1}(w) by g_sub_f_insert
6. ξ ∈ limit_f(w) by f_agrees_le

## 5. Whether the Walk B Eta-Shortcut Can Be Kept

**No, it must be removed (or absorbed into the recursion).**

The eta-shortcut returns χ unchanged with u_next as witness when η ∈ f(u_next). This requires the guard at ALL adjacent pairs from pc.x to u_next, which the current code cannot provide (the guard at intermediate pairs is not tracked).

In the recursive approach, this case is naturally handled:
- If η ∈ f(x') at the first successor: then x' is a witness. But is the guard at (pc.x, x') available? Only if condition (ii) holds (ξ ∈ g(pc.x, x')). The paper says condition (ii) contradicts the counterexample assumption, so this case doesn't arise.
- If η ∈ f(u_next) for a later u_next: the recursion has already accumulated the guard at earlier pairs. At the final pair (u_max, u_next), the recursion would check condition (i) at (u_max, u_next). If condition (i) fails, the recursion splits. If condition (i) holds... but condition (i) requires conj ∈ f(u_next), which requires U(ξ,η) ∈ f(u_next). But u_next > u_max means U(ξ,η) ∉ f(u_next) (by maximality of u_max in U). So condition (i) fails at (u_max, u_next), and the recursion splits there.

The eta-shortcut was an optimization that avoided splitting when η was already in f(u_next). In the recursive approach, this case manifests differently: at the split point, η ∈ f(u_next) means the splitting lemma can produce a witness. But the splitting lemma always produces a witness D with η ∈ D, regardless of whether η ∈ f(u_next) or not. So the eta-shortcut is unnecessary.

**However**, the eta-shortcut avoids inserting a new point (returns χ unchanged). Removing it means we always insert a point when condition (i) fails. This is fine for correctness but slightly changes the domain structure.

## 6. Estimated Effort

| Phase | Description | Lines Changed | Estimated Time |
|-------|-------------|---------------|----------------|
| 1 | Extract c5_forward_helper (recursive) | +150 new | 2-3 hours |
| 2 | Replace walk cases with helper call | -300, +50 | 1 hour |
| 3 | Fix not-condition(i) splitting (forward) | +20 | 30 min |
| 4 | Mirror for Since (backward) | +200 | 2-3 hours |
| 5 | Connect to limit (2 sorry sites) | +30 | 1 hour |
| **Total** | | ~150 net new | **6-9 hours** |

### Risk Assessment

- **Medium risk**: The recursive helper is conceptually clear but Lean's well-founded recursion can be finicky. The termination proof (decreasing Finset.card) should be straightforward but may require careful setup.
- **Low risk**: Phases 3-5 are mechanical once Phase 1-2 work.
- **Key dependency**: Phase 5 (limit proof) depends on Phase 1-4 being complete with the correct guard type.

## 7. Alternative Considered and Rejected

### Alternative: Derive guard from BurgessR3Maximal

Attempted to prove ξ ∈ g(a,b) from BurgessR3Maximal(f(a), g(a,b), f(b)) when untl(ξ,η) ∈ f(a). This fails because:
1. burgessRSet goes the wrong direction (content: B → A, not obligation: A → B)
2. Maximality gives a neg-until witness but no contradiction with untl(ξ,η) ∈ f(a)
3. rRelation is different from burgessRSet and not implied by BurgessR3Maximal

### Alternative: Restructure as splitting at (pc.x, x') instead of walking

Analyzed in the handoff (64_phase4-c5-forward.md). Fails for the BLOCKED sub-case: η ∉ g, η.neg ∈ g, ξ ∈ g, conj ∈ g with condition (i). In this case, no splitting lemma can produce η ∈ D. The walk (induction) is mathematically essential per Burgess 2.10.

## Key Files

- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` — 8 build errors, main target
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean` — 2 sorry sites at lines 1445, 1457
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleTypes.lean` — Adjacent (line 139), BurgessR3Maximal (line 351)
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` — lemma_2_4_with_guard (line 5255)
