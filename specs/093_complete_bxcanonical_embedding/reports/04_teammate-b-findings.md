# Teammate B Findings: Tuple Strategy (V,F Pairs) — Task 93

**Date**: 2026-04-13
**Assignment**: Research the strategy of AVOIDING LINDENBAUM MAXIMIZATION altogether by
working with tuples of consistent sets (V, F) to represent propositions instead of MCS.

---

## Key Findings

### 1. The Core Idea is Sound in Classical Model Theory, But Incompatible with the FMCS Infrastructure

The tuple approach (V, F) — where V is a consistent deductively-closed set and F tracks
"falsified" formulas — is legitimate in abstract completeness theory. It corresponds to
**Hintikka sets** or **consistent complete theories** (not necessarily maximal). However,
the entire `FMCS D` / `BFMCS D` infrastructure requires `SetMaximalConsistent`:

```lean
-- FMCSDef.lean:103
is_mcs : forall t, SetMaximalConsistent (mcs t)
```

Every place the infrastructure relies on `FMCS`, it calls `fam.is_mcs t` to get
`SetMaximalConsistent`. The truth lemma (`ParametricTruthLemma.lean`) uses MCS properties
in at least 8 critical ways:

1. `SetMaximalConsistent.negation_complete` — the `imp` backward case (line 271, 451)
2. `SetMaximalConsistent.implication_property` — modus ponens reflection (lines 266, etc.)
3. `SetMaximalConsistent.closed_under_derivation` — deductive closure (lines 278-289, 454-467)
4. Consistency of the MCS for the `bot` case (lines 246, 438)
5. `set_consistent_not_both` — contradiction from φ ∧ ¬φ in MCS (lines 301, 475)

**A partial (V, F) world fails `negation_complete`**: for a formula φ in neither V nor F,
neither φ ∈ V nor ¬φ ∈ V holds, which breaks the backward direction of the `imp` truth
lemma case. The `imp` backward direction needs negation completeness to case-split.

### 2. The Truth Lemma Cannot Be Adapted for Partial Worlds Without a Major Rewrite

The bidirectionality constraint documented in `ParametricTruthLemma.lean` (lines 22-50) shows
that the forward direction for `imp` (φ → ψ) requires the **backward IH for φ**, which in
turn for the `G`/`H` cases requires `forward_F`. This circular dependency is fundamental:

```
Forward (φ→ψ)∈MCS, truth φ → truth ψ:
  Step 1: truth φ → φ ∈ MCS   [BACKWARD IH for φ — requires negation completeness]
```

For negation completeness to hold for partial (V, F) worlds, we would need V to be a
*prime consistent theory*: for every φ, either φ ∈ V or ¬φ ∈ V. But a prime consistent
theory IS a maximal consistent set by definition. So the tuple approach collapses back
to MCS whenever the truth lemma is needed.

### 3. The Advantage is Real But the Scope is Wrong

The genuine advantage of tuples is exactly as stated: when constructing a successor for
`F(ψ) ∈ M_t`, we include `ψ ∈ V_{t+1}` and `g_content(M_t) ⊆ V_{t+1}` without
maximization, so Lindenbaum cannot add `G(¬χ)` for other F-obligations. This is valid.

The problem is: **we still need to maximize at some point** to satisfy the truth lemma.
The intermediate partial world (V_{t+1}, F_{t+1}) cannot be used directly in the FMCS
because it lacks the MCS properties that the truth lemma requires. We must eventually
extend it to an MCS, and the moment we do, we re-encounter the Lindenbaum control problem.

In other words: tuples defer the problem but do not solve it.

### 4. The Deferral Disjunction Approach Is the Existing Equivalent

`SuccExistence.lean` already implements a conceptually similar idea via the **successor
deferral seed**:

```lean
-- SuccExistence.lean:87
def successor_deferral_seed (u : Set Formula) : Set Formula :=
  g_content u ∪ deferralDisjunctions u
-- where deferralDisjunctions u = {φ ∨ F(φ) | F(φ) ∈ u}
```

This seed encodes the tuple (V, F) idea: the disjunction `φ ∨ F(φ)` means "either
resolve now (φ ∈ V) or defer (F(φ) ∈ V)". This IS a controlled Lindenbaum extension
that handles ALL F-obligations simultaneously. The seed is consistent and can be extended
to an MCS by Lindenbaum.

However, this construction is used in the `SuccRelation` infrastructure (discrete-time,
seriality-based), not directly in the `int_chain` construction used by `bx_fmcs_forward_F`.

### 5. Why `bx_fmcs_forward_F` Cannot Use the Deferral Disjunction Approach Directly

The `bx_fmcs_forward_F` theorem requires:

```lean
theorem bx_fmcs_forward_F (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (t : Int) (ψ : Formula)
    (h_F : Formula.some_future ψ ∈ (bx_fmcs M₀ h₀).mcs t) :
    ∃ s : Int, t < s ∧ ψ ∈ (bx_fmcs M₀ h₀).mcs s
```

The `int_chain` at position `t+1` is fixed by the forward schedule:
`fwd_succ (chain(t)) (schedule t)` resolves whichever formula is scheduled at step t.
There is no way to insert an ad-hoc successor that resolves `ψ` — the successor at `t+1`
is already determined by the chain construction.

The problem: when `F(ψ) ∈ chain(t)` but `schedule t ≠ ψ`, the chain step at `t+1`
only resolves `schedule t`. The theorem requires that `ψ` eventually appears in
`chain(s)` for some `s > t`, but this is only guaranteed if `schedule n = ψ` for some
`n ≥ t`. The current chain does schedule `ψ` infinitely often (by `schedule_surjective_above`),
but each resolution step via `forward_temporal_witness_seed` uses the SINGLE-formula seed
`{ψ} ∪ g_content(chain(t'))` and may add `G(¬χ)` for other F-formulas,
potentially destroying `F(χ) ∈ chain(t'+1)` even though `F(χ) ∈ chain(t')`.

The deferral disjunction seed handles all F-obligations simultaneously via disjunctions, but
it gives a WEAKER guarantee: the successor contains `χ ∨ F(χ)` for each `F(χ) ∈ M`,
not necessarily `χ` itself. This is exactly the Succ relation, not forward_F.

### 6. Forward_F Requires Eventual Resolution, Not Just Deferral

The temporal coherence predicate requires:
```
F(ψ) ∈ fam.mcs t → ∃ s > t, ψ ∈ fam.mcs s
```

This is **strict resolution** of `ψ`, not deferral. The deferral seed's MCS extension
may contain `F(ψ)` (deferred) rather than `ψ` (resolved), which does NOT satisfy
`forward_F`. The Succ-based approach provides F-step but not forward_F directly.

---

## Recommended Approach

**The tuple/partial world strategy should NOT be pursued as a standalone solution.**

The correct approach, consistent with the prior team research synthesis, is:

### Option A: Restricted Temporal Coherence (Primary Recommendation)

Use `BFMCS.restricted_temporally_coherent root` (defined at `TemporalCoherence.lean:295`)
instead of full `temporally_coherent`. This restricts forward_F to the FINITE set
`deferralClosure(root)`.

**Why this resolves the interference problem:**
- For a finite formula set Φ = `deferralClosure(root)`, we can use a PRIORITY SCHEDULE
  that cycles through ALL formulas in Φ at each stage of the chain construction.
- Instead of resolving one formula per step, use a ROUND-ROBIN schedule over Φ at each
  time step, building the seed as:
  ```
  seed_t = g_content(chain(t)) ∪ {ψ | F(ψ) ∈ chain(t) ∧ ψ ∈ Φ ∧ priority(ψ) = round(t)}
  ```
- Because Φ is finite, every formula in Φ ∩ f_content(chain(t)) is scheduled within
  |Φ| steps, and by the finite nature of Φ, the schedule is well-founded.

**Key Lean theorem to write:**
```lean
theorem bx_fmcs_restricted_forward_F (root : Formula) (M₀ : Set Formula)
    (h₀ : SetMaximalConsistent M₀) (t : Int) (ψ : Formula)
    (h_dc : ψ ∈ deferralClosure root)
    (h_F : Formula.some_future ψ ∈ (bx_fmcs M₀ h₀).mcs t) :
    ∃ s : Int, t < s ∧ ψ ∈ (bx_fmcs M₀ h₀).mcs s
```

### Why the Deferral Disjunction Idea Has Merit for a Modified Chain

The tuple/deferral intuition suggests a useful **intermediate construction**: instead of
the current single-formula `fwd_succ`, build a `fwd_succ_all` that extends
`g_content(M) ∪ {ψ ∨ F(ψ) | F(ψ) ∈ M ∧ ψ ∈ Φ}`. This gives:

1. The MCS containing this seed either has `ψ` or `F(ψ)` for each F-obligation in Φ.
2. Forward_G coherence is maintained (g_content included in seed).
3. F-obligations are not destroyed by Lindenbaum: if `G(¬χ)` were added, then
   `¬(χ ∨ F(χ)) ∈ MCS`, i.e., `¬χ ∧ ¬F(χ) ∈ MCS`, but we forced `χ ∨ F(χ) ∈ seed ⊆ MCS`.
   Contradiction — so `G(¬χ)` can NOT be added when `F(χ) ∈ M` and we include
   `χ ∨ F(χ)` in the seed.

The chain built this way satisfies: if `F(ψ) ∈ chain(t)` and `ψ ∈ Φ`, then either
`ψ ∈ chain(t+1)` (resolved) or `F(ψ) ∈ chain(t+1)` (deferred). By BX11 (temporal
linearity axiom), F-obligations are eventually resolved in any infinite MCS chain.

However, exploiting BX11 for finite resolution in Lean still requires careful formalization.

---

## Evidence and Proof Sketches

### Sketch 1: Why Full MCS (Not Tuples) Is Required for the Truth Lemma

**The imp-backward case** in the truth lemma (ParametricTruthLemma.lean:269-301):
```
Backward (φ→ψ): (truth φ → truth ψ) → (φ→ψ) ∈ fam.mcs t
```
The proof uses `SetMaximalConsistent.negation_complete` to case-split on whether
`(φ→ψ)` or `¬(φ→ψ)` is in the MCS. For a partial world (V, F), neither may hold.
The proof then derives `φ ∈ MCS` from `¬(φ→ψ) ∈ MCS` using `neg_imp_implies_antecedent`.
For a partial world, we cannot derive `φ ∈ V` — it may be in neither V nor F.

**Conclusion**: A partial world cannot satisfy the truth lemma's backward direction.

### Sketch 2: Why Deferral Disjunction Seeds Are Consistent

For `M` an MCS with `F(ψ) ∈ M`, the seed `g_content(M) ∪ {ψ ∨ F(ψ)}` is consistent.

**Proof**: Suppose inconsistent. Then there exist `L ⊆ seed` with `L ⊢ ⊥`.
Since `ψ ∨ F(ψ) ∉ g_content(M)` (g_content contains G-formulas, not disjunctions),
`L` must include `ψ ∨ F(ψ)`. Let `L' = L \ {ψ ∨ F(ψ)} ⊆ g_content(M)`.
Then `L', ψ ∨ F(ψ) ⊢ ⊥`, so `L' ⊢ ¬ψ ∧ ¬F(ψ)` (by disjunction elimination).
From `L' ⊢ ¬ψ`: by generalized G-necessitation, `G(L') ⊢ G(¬ψ)`.
Since `G(χ) ∈ M` for all `χ ∈ L'`, by MCS closure `G(¬ψ) ∈ M`.
But `F(ψ) = ¬G(¬ψ) ∈ M` — contradiction.

This sketch confirms the seed is consistent, justifying the SuccExistence approach.

### Sketch 3: The Non-Interference Argument for Φ-Restricted Seeds

For a FINITE Φ and seed `g_content(M) ∪ {χ ∨ F(χ) | F(χ) ∈ M ∧ χ ∈ Φ}`:

Suppose Lindenbaum extends this seed to MCS N. For any `χ ∈ Φ` with `F(χ) ∈ M`:
- `χ ∨ F(χ) ∈ N` (from seed)
- By MCS disjunction property: `χ ∈ N` or `F(χ) ∈ N`
- In either case, the F-obligation is NOT destroyed

This provides the round-by-round deferral guarantee needed to prove that every
`F(ψ) ∈ chain(t)` eventually reaches a time `s` where `ψ ∈ chain(s)`.

The crucial remaining question is: can we bound the number of deferral steps?
For BX (with BX11: `F(ψ) → ψ ∨ F(ψ ∧ ¬φ) ∨ (φ U ψ)`), the deferral must terminate
after finitely many steps for any ψ ∈ Φ, since the underlying linear model is well-ordered.

---

## Feasibility in Current Codebase

### What Needs to Change

| Component | Current State | Required Change |
|-----------|--------------|-----------------|
| `FMCS.is_mcs` | Requires `SetMaximalConsistent` | No change (MCS still used) |
| `bx_fmcs` construction | Uses `schedule`-based `fwd_succ` | New variant with Φ-restricted schedule |
| `bx_fmcs_forward_F` | `sorry` | Must be proved via restricted coherence |
| Truth lemma | Uses `BFMCS.temporally_coherent` | Adapter to accept `restricted_temporally_coherent` |
| Completeness wiring | Uses full `temporally_coherent` | Use `restricted_temporally_coherent root` |

### What DOES NOT Change

- The `FMCS` structure definition (MCS is still needed)
- The `BFMCS` structure definition
- The parametric truth lemma body (the theorem is the same, just with restricted hypothesis)
- The box stability theorem and all G/H coherence results
- The `set_lindenbaum` and MCS infrastructure

### Estimated Effort

The tuple approach itself is NOT viable and requires no new code. The adjacent
deferral disjunction insight, if formalized, amounts to:

1. **New `fwd_succ_Φ`** using `{χ ∨ F(χ) | F(χ) ∈ M ∧ χ ∈ Φ}` as seed (~80 lines)
2. **`fwd_succ_Φ_defers`**: each step either resolves or defers each χ ∈ Φ (~50 lines)
3. **Finite resolution lemma**: any F(ψ) with ψ ∈ Φ is resolved within |Φ| steps
   using BX11 (~100-150 lines, the hardest part)
4. **Restricted forward_F from finite resolution** (~40 lines)
5. **Adapter lemma**: `restricted_temporally_coherent` suffices for the truth lemma (~50 lines)

Total for the deferral path contribution: ~320-370 lines.

---

## Confidence Level

**Confidence (tuple approach as standalone): Very Low (5%)**

The tuple/partial-world approach is fundamentally incompatible with the `FMCS` infrastructure
and the bidirectional truth lemma. Every attempt to use partial worlds eventually requires
maximization, reintroducing the Lindenbaum control problem.

**Confidence (deferral disjunction insight contributing to restricted coherence): Medium-High (70%)**

The deferral disjunction seed construction IS the right intermediate tool for building the
finite-formula-restricted chain. Combined with the BX11 axiom (temporal linearity), this
provides a path to proving `restricted_temporally_coherent` for `bx_fmcs`. The primary
risk is formalizing the finite resolution bound using BX11, which may require careful
case analysis on BX axiom structure.

---

## Summary

- Tuple/partial worlds cannot replace MCS in the current FMCS architecture.
- The truth lemma requires `SetMaximalConsistent` and cannot be adapted for partial worlds.
- The key intuition behind tuples — controlling what Lindenbaum can add — IS captured
  by the deferral disjunction seed in `SuccExistence.lean`.
- The right path is `restricted_temporally_coherent` with a Φ-restricted schedule that
  uses deferral disjunction seeds to prevent F-obligation destruction.
- This aligns with the synthesis recommendation from the prior team research round.
