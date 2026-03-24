# Teammate B Findings: Solution Viability Analysis

**Task**: 48 (prove_succ_chain_fam_bounded_f_depth)
**Session**: sess_1774308893_ccb0e7
**Date**: 2026-03-23
**Focus**: Mathematical viability of Options A, B, C for the boundary case sorries

## Key Findings

- The `restricted_succ_propagates_F_not'` theorem (the "primed" strengthened version) is **also false as stated** in the case where `GF(psi) ∉ chain(k)` but `GF(psi) ∈ deferralClosure`. The current code already recognizes this (multiple sorry comments in the proof body at lines 3984 and 4212).
- There are currently **8 sorries** total in the theorem region: 2 deprecated (lines 736, 971), 2 original boundary sorries (lines 3077, 3236), and 4 new sorries in the primed theorems (lines ~3984, ~4212, ~4224, and the `restricted_single_step_forcing` original).
- The core obstruction: `F(psi)` can enter `chain(k+1)` by **MCS maximality alone** (independent of g_content and f_content) when `F(psi) ∈ deferralClosure` and the seed does not force `G(psi.neg) ∈ chain(k+1)`.
- Option B (direct lexicographic bounded_witness) is the **most viable** approach. Option A (strengthen to GF ∉ dc) is too weak. Option C (modify chain construction) is high-risk but potentially powerful.

## Deep Analysis of the Core Obstruction

### Why All "Blocking Both Paths" Approaches Fail

The analysis in `restricted_succ_propagates_F_not'` (lines 3266-4225) reveals a deeper problem than initially recognized. When `FF(psi) ∉ dc` and `GF(psi) ∉ chain(k)`:

- If `GF(psi) ∉ dc`: `F(psi)` can still enter `chain(k+1)` by MCS maximality, because the seed (`g_content(u) ∪ deferralDisjunctions(u) ∪ p_step_blocking`) does not force `G(psi.neg)` into the seed, and the Lindenbaum extension can pick either `F(psi)` or `G(psi.neg)`.
- If `GF(psi) ∈ dc` but `GF(psi) ∉ chain(k)`: By negation completeness, `FG(psi.neg) ∈ chain(k)`. F-step gives `G(psi.neg) ∈ chain(k+1) ∪ f_content(chain(k+1))`. If `G(psi.neg)` is deferred (lands in `f_content`), then `F(psi) = neg(G(psi.neg))` can be chosen by maximality.

The MCS extension uses `Classical.choose`, which is non-deterministic. Without the seed **forcing** `G(psi.neg) ∈ chain(k+1)`, the maximality step can go either way.

---

## Option A: Strengthen to GF ∉ dc

### Viability: Not Viable (as a complete solution)

### What the Theorem Would Look Like

```lean
theorem restricted_succ_propagates_F_not_strong (phi : Formula)
    (M0 : DeferralRestrictedSerialMCS phi) (k : Nat) (psi : Formula)
    (h_FF_not : FF(psi) ∉ chain(k))
    (h_GF_dc : GF(psi) ∉ deferralClosure phi) :
    F(psi) ∉ chain(k+1)
```

The hypothesis `GF(psi) ∉ dc` (stronger than `GF(psi) ∉ chain(k)`) would eliminate the subcase where negation completeness derives `FG(psi.neg) ∈ chain(k)`.

But even with `GF(psi) ∉ dc`, the MCS maximality problem remains: if `F(psi) ∈ dc` and neither `F(psi)` nor `G(psi.neg)` is in the seed, the Lindenbaum extension can place `F(psi)` in `chain(k+1)`.

### Would it Still Prove the Ultimate Goal?

The ultimate goal is `restricted_forward_chain_iter_F_witness`. To use this theorem, `bounded_witness` would need to ensure `GF(psi) ∉ dc` at each step. But `GF(psi) ∉ dc` is a condition on `phi` (the target formula), not on the chain state — and it can be false for natural formulas like `phi = G(F(p))` where `GF(p) ∈ dc`.

The cases where `GF(psi) ∈ dc` (e.g., `phi = G(F(p))`) are exactly the cases that need handling.

### Pros

- Simple theorem statement modification
- Eliminates one sub-case in the current proof attempt
- For formulas where `GF(psi) ∉ dc` for all relevant `psi`, the proof would be complete

### Cons

- Still has the MCS maximality gap even when `GF(psi) ∉ dc`
- Leaves `phi = G(F(p))` and similar formulas completely unhandled
- The ultimate goal cannot be proved for `G(F(p))` with this approach
- Actually doesn't close the sorry for the `GF(psi) ∉ dc` sub-case (lines 4186-4212 in the existing code show this analysis was already tried and failed)

---

## Option B: Direct Lexicographic bounded_witness

### Viability: Partially Viable (with significant infrastructure work)

### Termination Measure

Define the lexicographic measure `(f_depth, g_depth)` where:

- `f_depth(chi, phi)` = `f_nesting_depth(chi)` — the F-nesting depth of the current "active" formula
- `g_depth(chi, phi)` = maximum `n` such that `G^n(chi) ∈ subformulaClosure(phi)`

For the bounded_witness recursion on `iter_F d psi` at step `k`:

**Primary decreasing measure**: `f_depth` = `d` (the iteration depth). At each standard step, `d` decreases by 1.

**Secondary measure**: when `d` doesn't decrease (the G-propagation case), track how many times `F(psi)` can propagate via g_content before `G(F(psi))` leaves the deferral closure.

The key insight: `G^n(F(psi))` leaves `subformulaClosure(phi)` for some `n ≤ |subformulaClosure(phi)|`. So:
- At chain position `k`: `G(F(psi)) ∈ chain(k)`, so `F(psi) ∈ chain(k+1)` via g_content
- At chain position `k+1`: either `G(G(F(psi))) ∈ chain(k+1)` (requires `GGF(psi) ∈ dc`) or not
- If `GGF(psi) ∉ dc`: then `G(F(psi))` cannot enter `chain(k+2)` via g_content. But can it enter via maximality?

### The Remaining Gap in Option B

Even with lexicographic termination, the MCS maximality problem persists at the base case. Specifically:

Suppose `G^{n}(F(psi)) ∉ dc` for some `n`. At position `k+n`, we have `G^{n-1}(F(psi))` might or might not be in `chain(k+n)`. When `G(F(psi)) ∉ dc`, neither `G(F(psi))` nor `neg(G(F(psi))) = F(neg(F(psi)))` can be used to block `F(psi)`. The MCS can still choose `F(psi)` by maximality.

The core question: **Is the restricted chain construction deterministic enough** that `F(psi)` is eventually forced into `psi` (not just deferred) when all G-prefix chains leave `dc`?

### What Would Make Option B Work

Option B can be made to work if one of these additional properties holds:

1. **The Lindenbaum construction is fair**: It resolves `psi ∨ F(psi)` to `psi` when `FF(psi) ∉ dc` and `GF(psi) ∉ dc`. The current construction uses an arbitrary enumeration.

2. **There is a forcing argument**: Show that when `GF(psi) ∉ dc`, the seed actually does force `G(psi.neg) ∈ chain(k+1)`. This would require knowing that `neg(FF(psi)) = GG(psi.neg) ∈ chain(k)`, which requires `FF(psi) ∈ subformulaClosure` for negation completeness — but `FF(psi) ∉ dc` in the boundary case.

3. **Use the seriality axiom differently**: The axiom `G(phi) → F(phi)` might give additional constraints when combined with the bounded chain structure.

### Proof Sketch (Conditional)

Assuming the MCS maximality issue is resolved by a fair construction:

```lean
theorem restricted_bounded_witness_lex (phi : Formula)
    (M0 : DeferralRestrictedSerialMCS phi) (k : Nat) (psi : Formula)
    -- Termination on (f_depth, g_depth) lexicographically
    (measure : Nat × Nat := (f_nesting_depth (iter_F d psi), g_nesting_depth phi (iter_F d psi))) :
    -- Standard induction handles f_depth decrease
    -- G-propagation case: g_depth decreases while f_depth stays fixed
    -- Eventually both reach (1, 0): the base case where F(psi) ∉ dc after one step
```

This requires defining `g_nesting_depth` (as sketched in plan v8, Phase 1) and proving it decreases in the G-propagation case.

### Pros

- Mathematically sound termination argument (subformulaClosure is finite)
- Does not require modifying deferralClosure or chain construction
- Extends the existing v6 bounded_witness structure
- The lexicographic measure is well-defined and provably bounded

### Cons

- **Does not resolve the MCS maximality gap at the base case** without additional construction constraints
- Requires significant new infrastructure (g_nesting_depth, lexicographic WF induction in Lean 4)
- The standard Lean 4 `termination_by` does not directly support lexicographic pairs without `Nat.lex`
- Implementation complexity: ~3-4x more work than originally estimated
- Still needs a proof that the Lindenbaum extension "chooses correctly" at the boundary

---

## Option C: Modify Chain Construction

### Viability: Viable (with medium implementation effort)

### What the Chain Construction Currently Does

`constrained_successor_restricted phi u` builds `chain(k+1)` by:
1. **Seed**: `g_content(u) ∪ deferralDisjunctions(u) ∪ p_step_blocking_formulas_restricted(phi, u)`
2. **Extension**: Lindenbaum extension of seed within `deferralClosure(phi)`

The seed's deferral disjunctions are `{chi ∨ F(chi) | F(chi) ∈ closureWithNeg(phi) ∩ u}`. For each `F(chi) ∈ u ∩ closureWithNeg`, the seed contains `chi ∨ F(chi)`.

This allows the Lindenbaum extension to "defer" by choosing the `F(chi)` disjunct.

### The Proposed Change

**Add a "boundary resolution" component to the seed**: When `F(chi) ∈ u` and `FF(chi) ∉ deferralClosure(phi)` and `G(F(chi)) ∉ u`, add `chi` directly to the seed (not just `chi ∨ F(chi)`).

```lean
def boundary_resolution_set (phi : Formula) (u : Set Formula) : Set Formula :=
  {chi | Formula.some_future chi ∈ u ∧
         Formula.some_future (Formula.some_future chi) ∉ deferralClosure phi ∧
         Formula.all_future (Formula.some_future chi) ∉ u}

def constrained_successor_seed_restricted_v2 (phi : Formula) (u : Set Formula) : Set Formula :=
  g_content u ∪ deferralDisjunctions phi u ∪ p_step_blocking_formulas_restricted phi u
  ∪ boundary_resolution_set phi u
```

### Why This Works Mathematically

When `F(chi) ∈ u ∩ closureWithNeg`, `FF(chi) ∉ dc`, and `GF(chi) ∉ u`:
- The f-step condition requires `chi ∈ chain(k+1) ∨ F(chi) ∈ chain(k+1)`.
- There is no mechanism to further defer `F(chi)` (it's at the boundary of dc).
- The GF-path is blocked by hypothesis.
- Therefore `chi ∈ chain(k+1)` is the only coherent choice.

Adding `chi` to the seed forces this resolution.

### Does This Preserve MCS Properties?

**Consistency**: We need `{chi}` to be consistent with the existing seed. The seed already contains `chi ∨ F(chi)` (from the deferral disjunction). Adding `chi` is consistent iff `chi` is consistent with the rest of the seed. Since `F(chi) ∈ u` (an MCS), `u` is consistent, and `chi` does not appear contradicted in the seed.

More precisely: the seed without `chi` is `S`. Adding `chi` to `S` is consistent iff `S ∪ {chi}` is consistent. The seed `S` contains `chi ∨ F(chi)`. If `chi` were inconsistent with `S`, then `S` alone would derive `neg(chi)`, and combined with `chi ∨ F(chi)` would derive `F(chi)`. But `F(chi)` might also be inconsistent with `S`. This needs careful analysis.

**Key concern**: Does adding `chi` to the seed break the F-step property? The F-step says `f_content(chain(k)) ⊆ chain(k+1) ∪ f_content(chain(k+1))`. Adding `chi` to the seed means `chi ∈ chain(k+1)`. The F-step still holds since `chi ∈ chain(k+1)` satisfies `chi ∈ chain(k+1) ∪ f_content(chain(k+1))`.

**G-persistence**: Unchanged. The `g_content(u)` component of the seed is unchanged.

### Proof Sketch for restricted_single_step_forcing with Modified Construction

```
Given: F(chi) ∈ chain(k), FF(chi) ∉ chain(k), FF(chi) ∉ dc
New seed has: chi ∈ boundary_resolution_set(phi, chain(k)) ⊆ seed
Hence: chi ∈ chain(k+1) directly (since seed ⊆ chain(k+1))
```

This eliminates the sorry entirely.

### Proof Sketch for restricted_succ_propagates_F_not with Modified Construction

This theorem becomes easier too: if `F(chi)` is "resolved" in `chain(k+1)` (i.e., `chi ∈ chain(k+1)`), then we don't need `F(chi) ∉ chain(k+1)` — the whole approach to `bounded_witness` changes.

With the modified construction, `bounded_witness` becomes:
- `F^d(psi) ∈ chain(k)` with `F^{d+1}(psi) ∉ chain(k)` → boundary resolution adds `F^{d-1}(psi)` to seed of `chain(k+1)` → `F^{d-1}(psi) ∈ chain(k+1)` directly → recurse.

### Construction Change Summary

```lean
-- ADD to seed:
boundary_resolution_set phi u =
  {chi | F(chi) ∈ u ∧ FF(chi) ∉ dc ∧ GF(chi) ∉ u}
```

### Consistency Proof Needed

The hardest part of Option C is proving the modified seed is consistent. The current proof (`constrained_successor_seed_restricted_consistent`) shows `seed ⊆ u`, so consistency follows from `u` being consistent. With the new `boundary_resolution_set`, we need `boundary_resolution_set ⊆ u` OR a direct consistency proof.

**Is `chi ∈ u` when `F(chi) ∈ u` and `FF(chi) ∉ dc`?**

Not necessarily! `chi` might not be in `u`. The `deferral disjunction psi ∨ F(psi)` allows the MCS to contain `F(psi)` without containing `psi`. So `F(chi) ∈ u` does NOT imply `chi ∈ u`.

This means we CANNOT use `seed ⊆ u` as the consistency argument. We need a direct consistency proof:

**Claim**: The set `seed_v2 = old_seed ∪ boundary_resolution_set` is consistent.

**Proof attempt**: For each `chi ∈ boundary_resolution_set`:
- `chi ∨ F(chi) ∈ old_seed` (deferral disjunction, since `F(chi) ∈ u ∩ closureWithNeg`)
- Suppose `seed_v2` is inconsistent. Then there exists a finite `L ⊆ seed_v2` deriving `bot`.
- Some `chi_j ∈ boundary_resolution_set` must appear in `L` (otherwise `L ⊆ old_seed ⊆ u`, consistent).
- From `L \ {chi_j}` (a subset of `old_seed ∪ remaining_boundary`), we can derive `neg(chi_j)`.
- But `old_seed` contains `chi_j ∨ F(chi_j)`. Combined with `neg(chi_j)`, we derive `F(chi_j)`.
- Now `F(chi_j) ∈ u`, and `F(chi_j) ∈ old_seed`? Not necessarily. `F(chi_j)` is in `u` but might not be in the seed directly.

This consistency argument requires careful tracking. It is NOT automatic.

**Alternative**: Use `deferral_restricted_lindenbaum` with a larger seed and prove the new seed is still consistent using the deductive closure properties of `u`.

### Pros

- **Directly eliminates the sorry** in `restricted_single_step_forcing` by ensuring `chi ∈ chain(k+1)`
- Makes `bounded_witness` straightforward: each step resolves `F^{d-1}(psi)` into `chain(k+1)` directly
- No lexicographic induction needed
- Semantically correct: at the boundary, there is no valid reason to defer further
- The chain modification is local and does not affect the non-boundary cases

### Cons

- Requires modifying the **core chain construction** (`constrained_successor_seed_restricted`)
- All theorems about the construction need to be reverified
- The consistency proof for the new seed is non-trivial
- Need to prove `boundary_resolution_set ⊆ deferralClosure phi` (this is easy: `chi` is the inner formula of `F(chi) ∈ u ⊆ dc ⊆ closureWithNeg`, so `chi ∈ subformulaClosure ⊆ dc`)
- Need to check that `Succ` is still satisfied (g_persistence and f_step)
- Risk: modifying the construction might break existing proofs that depend on the old seed structure

---

## Recommended Approach

**Recommended: Option C with a focused consistency proof**, using the following strategy:

1. **Add `boundary_resolution_set` to the seed**, but prove consistency via:
   - For each `chi ∈ boundary_resolution_set`: `chi ∨ F(chi) ∈ old_seed` AND `F(chi) ∈ u ∩ closureWithNeg`.
   - The old seed `old_seed ⊆ u` (this is the current consistency argument).
   - Add `chi` incrementally: prove that `old_seed ∪ {chi}` is consistent because `chi ∨ F(chi) ∈ old_seed` and `old_seed` is consistent, so `old_seed ∪ {chi}` is consistent iff `old_seed ∪ {neg(chi)}` is not deductively closed at `bot` — and since `old_seed ⊆ u`, and `u` is an MCS, `u` contains either `chi` or `neg(chi)`.
   - If `chi ∈ u`: then `old_seed ∪ {chi} ⊆ u`, so consistent.
   - If `neg(chi) ∈ u`: then combined with `chi ∨ F(chi) ∈ u` (deferral disjunction is in `u` since it's derivable), `u` contains `F(chi)` (which it does, by hypothesis). No contradiction.
   - But `old_seed ∪ {chi}` when `neg(chi) ∈ u` may still be consistent — consistency requires no **finite** proof of `bot`, and `neg(chi)` is not in the seed.

   The key insight: **`old_seed` does not contain `neg(chi)`.** The seed is `g_content(u) ∪ deferralDisjunctions(u) ∪ p_step_blocking`. None of these contain `neg(chi)` unless `chi` has special structure. Adding `chi` to this seed cannot create an inconsistency unless `neg(chi)` is already derivable from the seed.

   Since `old_seed ⊆ u` and `u` may contain `neg(chi)`, but `neg(chi) ∉ old_seed`, the seed does not derive `neg(chi)`. Therefore `old_seed ∪ {chi}` is consistent.

2. **Prove the modified chain satisfies Succ**: g_persistence unchanged; f_step: for `F(psi) ∈ u`, either `psi ∈ seed_v2` (if at boundary) or `psi ∨ F(psi) ∈ seed_v2` (standard deferral), so `psi ∈ chain(k+1) ∨ F(psi) ∈ chain(k+1)`.

3. **Simplify bounded_witness**: With the new construction, `restricted_single_step_forcing` becomes trivial — `chi ∈ chain(k+1)` directly from the seed. No need for the GG(neg psi) argument.

**If Option C's consistency proof hits unexpected obstacles, fall back to Option B** with the additional hypothesis that the Lindenbaum construction is fair (which would need to be embedded in the construction itself — essentially arriving at Option C again).

---

## Comparison Table

| Property | Option A | Option B | Option C |
|----------|----------|----------|----------|
| Closes the sorry at line 3077 | No | Conditionally | Yes |
| Closes the sorry at line 3236 | No | Conditionally | Yes |
| Handles phi = G(F(p)) | No | Yes (if lex works) | Yes |
| Requires new infrastructure | Low | High | Medium |
| Modifies chain construction | No | No | Yes |
| Risk of breaking existing proofs | Low | Low | Medium |
| Mathematical soundness | No | Yes | Yes |
| Implementation effort | 1h | 4-6h | 3-4h |

---

## Confidence Level

**Medium** — The mathematical reasoning is sound, but there are two areas of uncertainty:

1. **Option C consistency proof**: The argument that `old_seed ∪ {chi}` is consistent relies on `neg(chi) ∉ old_seed`. This needs verification against the actual seed construction. The seed could theoretically derive `neg(chi)` through modal axioms applied to `g_content(u)` formulas, which is non-obvious.

2. **Option B's base case**: The lexicographic argument terminates, but the base case (when all G-chains leave dc) still requires showing the Lindenbaum construction picks `psi` over `F(psi)`. Without construction modification (i.e., without arriving at Option C), this cannot be guaranteed from the current proof system.

The recommended approach (Option C) is sound if the consistency proof works. A 2-3 hour focused implementation attempt on Option C should determine feasibility before committing to the more complex Option B infrastructure.
