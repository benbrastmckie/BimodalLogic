# Teammate A Findings: Skip C5 for ξ=⊥ Approach

**Task**: 121 — Fix discrete completeness blocker
**Angle**: Skip C5 counterexample processing when ξ=⊥
**Date**: 2026-05-11

## Key Findings

### 1. The C5 Counterexample Check (lines 1821-1828)

The check at `eliminate_potential_counterexample` (CounterexampleElimination.lean:1825) for `.c5_forward` is:

```lean
by_cases h_actual : pc.x ∈ χ.dom ∧ Formula.untl pc.η pc.ξ ∈ χ.f pc.x ∧
    ¬∃ y ∈ χ.dom, pc.x < y ∧ pc.η ∈ χ.f y ∧
      (∀ a b, Adjacent χ.dom a b → pc.x ≤ a → b ≤ y → pc.ξ ∈ χ.g a b) ∧
      (∀ w ∈ χ.dom, pc.x < w → w < y → pc.ξ ∈ χ.f w)
```

The "already resolved" check requires `pc.ξ ∈ χ.g a b` for adjacent pairs. For ξ=⊥, this requires ⊥ ∈ g(a,b). Since g-values are BurgessR3Maximal sets and ⊥ can never be in a consistent such set, this check ALWAYS fails. This is the root cause of infinite midpoint insertion.

When `h_actual` holds (counterexample is "live"), the code enters a case split on whether `pc.x = max(dom)`:
- **n=0 case** (line 1836): pc.x is max → insert y beyond max via `lemma_2_4_with_guard`. Not relevant to the midpoint problem.
- **n≥1 case** (line 1978): pc.x is not max → find dom-successor x', enter `c5_forward_walk`.

The `c5_forward_walk` (line 668) is where midpoints are inserted. It has:
- **Base case** (line 683): pt = max(dom) → insert beyond max (no midpoint).
- **Recursive case**: pt ≠ max → find dom-successor x', case split on "condition (i)":
  - Condition (i) holds: walk forward recursively, no new point inserted at THIS pair.
  - Condition (i) fails: **insert midpoint z = (pt + x')/2** (line 2145).

For U(⊤,⊥), condition (i) requires `⊥ ∧ U(⊤,⊥) ∈ f(x')` and `⊥ ∈ g(pt, x')`. Since ⊥ ∧ U(⊤,⊥) = ⊥, which is never in an MCS, condition (i) ALWAYS FAILS. So a midpoint is ALWAYS inserted. This confirms the infinite accumulation.

### 2. PotentialCounterexample Structure (line 542)

```lean
structure PotentialCounterexample where
  x : Rat
  y : Rat
  ξ : Formula
  η : Formula
  kind : PotentialCounterexampleKind
```

Counterexamples are enumerated via `counterexample_enum : Nat → PotentialCounterexample` using a Denumerable instance (line 200 of ChronicleConstruction.lean). The enumeration ranges over ALL formulas ξ,η and ALL rationals x,y. Filtering at the enumeration level would change the Denumerable bijection, breaking the surjectivity proofs.

**Recommendation**: Filter at the CHECK level (the `by_cases h_actual` on line 1825), NOT at the enumeration level.

### 3. `limit_satisfies_c5_strong` Analysis (line 1440)

This lemma is sorry-free. For U(η,ξ) at x, it:
1. Finds stage n where the counterexample `⟨x, 0, ξ, η, .c5_forward⟩` is processed
2. Gets witness y from `omega_chain_c5_witness` at step n+1
3. Shows `ξ ∈ limit_g x y`, meaning: for all w ∈ limit_dom between x and y, ξ ∈ limit_f(w)

For ξ=⊥: the guard says "for all w between x and y, ⊥ ∈ limit_f(w)." Since ⊥ is never in any MCS, this means NO limit_dom points exist between x and y. The proof IS correct — the witness y (a midpoint) has an empty gap to x.

**Critical insight**: `limit_satisfies_c5_strong` does NOT depend on the witness being a midpoint. It depends on `omega_chain_c5_witness`, which delegates to `c5_forward_witness` in the `EliminationResult`. The proof would work equally well if the witness were the dom-successor c (rather than a midpoint z), AS LONG AS the adjacent-pair guard condition is satisfied.

### 4. Dependency Chain Analysis

If we skip C5 elimination for ξ=⊥ (return the chronicle unchanged), the key question is: would `c5_forward_witness` still produce a valid result?

When the counterexample is NOT "actual" (line 2335-2352), the code returns the chronicle unchanged with `val := χ` and uses the existing witness:
```lean
c5_forward_witness := by
  intro _ h_mem h_until
  push_neg at h_actual
  obtain ⟨y, hy_dom, ...⟩ := h_actual h_mem h_until
  exact ⟨y, hy_dom, ...⟩
```

If we short-circuit ξ=⊥ to always return "not actual," we need `h_actual` to be true. But `h_actual` is the NEGATION — it says "there EXISTS a witness satisfying the g-value check." For ξ=⊥, this requires ⊥ ∈ g(a,b), which is always false. So `h_actual` is NEVER true for ξ=⊥, and we CANNOT use the "not actual" branch.

**This means we can't just skip the check — we need to provide a valid witness without inserting a new point.**

### 5. The Correct Fix: Vacuous Witness for ξ=⊥

For U(η, ⊥) at x, the dom-successor x' IS a valid C5 witness at the LIMIT level:
- η = ⊤ ∈ f(x') since f(x') is MCS (for η=⊤; for general η, need η ∈ f(x') which may not hold)
- Guard: ⊥ ∈ g(a,b) for all adjacent pairs between x and x'. Since x' is the dom-successor of x, the only such pair is (x, x'), and the condition becomes ⊥ ∈ g(x, x'). But this is FALSE at the finite stage!

The problem: at the finite stage, the g-value check fails. The "vacuous" truth only holds at the LIMIT level (where we interpret g via limit_g, which checks `ξ ∈ limit_f(w)` for intermediate w). The finite-stage check uses the g-VALUE of the chronicle, not the semantic interpretation.

**The mismatch**: The finite-stage C5 check uses `pc.ξ ∈ χ.g a b` (a membership test on the g-value set). The limit-level C5 uses `ξ ∈ limit_g x y` (which is defined as `∀ w ∈ limit_dom, x < w → w < y → ξ ∈ limit_f w` — a universal quantifier). These are NOT the same thing. For ξ=⊥, the universal quantifier is vacuously true (no w exists), but the membership test always fails.

### 6. Is ⊥ the Only Problematic Guard?

**Yes, ⊥ is unique.** For any formula ξ ≠ ⊥:
- If ξ is consistent, it CAN appear in g-values (BurgessR3Maximal sets can contain consistent formulas)
- The C5 walk may or may not insert a midpoint, but it will eventually terminate because the walk reduces `(dom.filter (· > pt)).card` at each step (the walk moves to the dom-successor x', which has fewer points above it)
- Even if a midpoint is inserted, the g-value B' of the left gap WILL contain ξ (from lemma_2_7: h_ξ_B' guarantees pc.ξ ∈ B'), and condition (i) check at the NEXT visit MAY succeed

For ξ=⊥:
- ⊥ can NEVER be in g-values (BurgessR3Maximal with ⊥ implies ⊥ in the endpoint MCS, contradiction)
- Condition (i) requires `⊥ ∧ U(η,⊥) ∈ f(x')`, which equals `⊥ ∈ f(x')`, always false for MCS
- So the walk ALWAYS inserts and NEVER walks forward
- Each new midpoint gets its own C5 obligation, generating another midpoint forever

**Other "inconsistent-like" formulas**: Any formula ξ such that ξ is never in any MCS would cause the same problem. But ⊥ is the ONLY formula that's never in any MCS (by definition — MCS requires consistency, and ⊥ ∈ S means S is inconsistent). So ⊥ is the unique problematic case.

### 7. Proposed Fix: Add ξ=⊥ Short-Circuit

**Location**: `eliminate_potential_counterexample`, line 1821, inside the `.c5_forward` branch.

**Change**: Before the `by_cases h_actual` check, add:

```lean
-- Short-circuit for ξ = ⊥: U(η, ⊥) is vacuously satisfied by any dom-successor
-- in the limit (no domain points between x and succ(x) can have ⊥ ∈ f(w)).
-- Skip insertion to prevent infinite midpoint accumulation.
if h_bot : pc.ξ = Formula.bot then
  exact { val := χ
          dom_sub := le_refl _
          c0 := h_c0
          f_agrees := fun _ _ => rfl
          g_agrees := fun _ _ _ _ => rfl
          c2' := h_c2'
          c5_forward_witness := ...  -- USE DOM-SUCCESSOR AS WITNESS
          ... }
```

**The problem with this approach**: The `c5_forward_witness` field requires:
```lean
∃ y ∈ χ.dom, pc.x < y ∧ pc.η ∈ χ.f y ∧
  (∀ a b, Adjacent χ.dom a b → pc.x ≤ a → b ≤ y → pc.ξ ∈ χ.g a b) ∧
  (∀ w ∈ χ.dom, pc.x < w → w < y → pc.ξ ∈ χ.f w)
```

For ξ=⊥ with y = dom-successor x':
- `pc.η ∈ χ.f x'`: Need η ∈ f(x'). For η=⊤ this is trivially true (⊤ ∈ every MCS). But for general η, NOT guaranteed.
- `⊥ ∈ χ.g pc.x x'`: ALWAYS FALSE. This field CANNOT be satisfied.

**The g-value guard condition makes it impossible to provide a "no-op" result that satisfies the EliminationResult spec.** The spec demands `pc.ξ ∈ χ.g a b` for adjacent pairs, and ⊥ is never in g-values.

### 8. The Real Fix: Change the EliminationResult Spec

The root issue is that `EliminationResult.c5_forward_witness` uses the finite-stage g-value check, but the LIMIT-level C5 uses a different (vacuous) interpretation. The spec conflates these.

**Option A: Weaken the witness spec for ξ=⊥.** Add a disjunct: the witness either satisfies the g-value check OR ξ=⊥ (in which case the vacuous limit argument applies). This requires changing `EliminationResult` and all lemmas that use `c5_forward_witness`.

**Option B: Change the g-value of closed gaps.** When splitting at (x, x') for U(η, ⊥), set g'(x, z) = Set.univ (not just B'). Since the gap is permanently empty, g = Set.univ is semantically correct. This makes ⊥ ∈ g'(x, z) = true.

**Option C: Modify the "already resolved" check.** Add a special case: when ξ=⊥ and x has a dom-successor, consider the counterexample already resolved (return `χ` unchanged). The `c5_forward_witness` then uses the dom-successor and provides a WEAKENED guard that only claims the f-value condition (no g-value claim). This requires changing `EliminationResult`.

### 9. Scope Estimate

| Approach | Lines Changed | Proofs Affected | Risk |
|----------|--------------|-----------------|------|
| A: Weaken spec | ~50-100 | EliminationResult, omega_chain_c5_witness, limit_satisfies_c5_strong, limit_dom_has_succ | Medium — must verify all consumers handle the new disjunct |
| B: Set.univ g-value | ~20-30 | c5_forward_walk (B' construction), c2' proofs | High — BurgessR3Maximal(f(x), Set.univ, D) may not hold |
| C: Modified check | ~80-120 | EliminationResult, eliminate_potential_counterexample, omega_chain_c5_witness, limit_satisfies_c5_strong | Medium-High — similar to A but more surgical |

**Recommended: Option A** (weaken spec). The EliminationResult should allow "vacuous satisfaction" for ξ=⊥ cases. The change propagates through:
1. `EliminationResult.c5_forward_witness` — add `∨ (pc.ξ = Formula.bot ∧ y ∈ χ.dom ∧ ...)`
2. `omega_chain_c5_witness` — propagate the disjunct
3. `limit_satisfies_c5_strong` — handle the new case (vacuous argument)
4. `limit_dom_has_succ` — unchanged (it already handles the vacuous case)

## Confidence Level

**High** on the analysis. The root cause is precisely identified: the finite-stage g-value check `pc.ξ ∈ χ.g a b` always fails for ξ=⊥, forcing infinite midpoint insertion. The fix requires changing the `EliminationResult` spec to distinguish the ξ=⊥ case.

**Medium** on the specific fix approach. Option A (weaken spec) is cleanest conceptually but has moderate blast radius (~50-100 lines across 4 files). Options B and C have different trade-offs. All require careful proof repair.
