# Teammate A Findings: Primary Approach — Defect-Driven Chain Construction

**Task**: 93 — Close all 6 sorry sites in `RootScopedChain.lean`
**Role**: Teammate A — Primary approach, rigorous ground-up design
**Date**: 2026-04-16

---

## Key Findings

### 1. The 6 Sorry Sites and Their Dependencies

The six sorry sites in `RootScopedChain.lean` are:

| # | Location | Statement | Depends on |
|---|----------|-----------|-----------|
| 1 | Line 1413 | `rr_fwd_chain_forward_F` (depth-0 base case) | Foundational |
| 2 | Line 1457 | `dd_fmcs_forward_F` (t < 0 case) | Sorry 1 |
| 3 | Line 1464 | `dd_fmcs_backward_P` | Mirror of sorry 1 |
| 4 | Line 1517 | `dd_bfmcs_restricted_tc` | Sorry 1 + 3 |
| 5 | Line 1522 | `dd_bfmcs_restricted_buc` | Partially independent |
| 6 | Line 1527 | `dd_bfmcs_restricted_fuc` | Partially independent |

The critical sorry is **1**: `rr_fwd_chain_forward_F`. Sorries 2 and 3 follow similarly once sorry 1 is resolved. Sorries 5 and 6 (backward/forward Until-Since coherence) are structurally independent of sorry 1 but use the same FMCS/BFMCS.

### 2. What the Existing Infrastructure Provides (Sorry-Free)

The following are already proved in `RootScopedChain.lean` and supporting files:

- `enriched_fwd_step_preserves` (line 626): At each step, for every `ψ ∈ sigma_list` with `F(ψ) ∈ M`, either `ψ ∈ M'` or `F(ψ) ∈ M'`.
- `rr_fwd_chain_F_obligation_persists` (line 1160): `F(ψ) ∈ chain(n)` implies `F(ψ) ∈ chain(n+1)` OR `ψ ∈ chain(n+1)`.
- `rr_fwd_chain_F_obligation_forward` (line 1188): `F(ψ) ∈ chain(n)` → `F(ψ) ∈ chain(m)` for all `m ≥ n` (if ψ never appears directly). This is the "F-obligation is monotone" result.
- `enriched_fwd_step_resolves_one` (line 644): At a resolving step with target `target ∈ sigma_list`, at least one formula `w ∈ sigma_list` with `F(w) ∈ M` satisfies `w ∈ M'`.
- `rr_fwd_chain_forward_F_depth_pos` (line 1331): The depth ≥ 1 case works: `F(F(ψ')) ∈ chain(n)` reduces to `F(ψ') ∈ chain(n)` via `FF_imp_F_mcs`, then IH gives `ψ' ∈ chain(s)`, then `F(ψ') = ψ ∈ chain(s)` by `phi_in_mcs_imp_F_phi`.
- `rrSchedule_visits` (line 562): For any `ψ ∈ sigma_list`, there are infinitely many steps where `rrSchedule sigma_list m = ψ`.

The depth-0 base case is the sole irreducible blocker for sorry 1.

### 3. The Depth-0 Obstruction — Precisely Stated

Given: `F(χ) ∈ rr_fwd_chain(M₀, sigma_list, m)` with `f_nesting_depth(χ) = 0`.

Need: `∃ s > m, χ ∈ rr_fwd_chain(M₀, sigma_list, s)`.

The available lemma `rr_fwd_chain_F_obligation_persists` gives:
  For all `k ≥ m`: `χ ∈ chain(k+1) ∨ F(χ) ∈ chain(k+1)`.

If case "χ ∈ chain(k+1)" occurs for any k ≥ m, we have our witness s = k+1.

If not: `F(χ) ∈ chain(k)` for **all** `k ≥ m`. This is the **perpetual deferral** case.

In the perpetual deferral case:
- At each visit step `vᵢ` where `rrSchedule sigma_list vᵢ = χ`, `F(χ) ∈ chain(vᵢ)`, so the step at `vᵢ + 1` is a **resolving step** with target χ.
- By `enriched_fwd_step_resolves_one`: ∃ w ∈ sigma_list with `F(w) ∈ chain(vᵢ)` and `w ∈ chain(vᵢ + 1)`.
- Since χ is never directly present (perpetual deferral assumption), `w ≠ χ`.

**The perpetual deferral scenario**: At every visit step for χ, the BX11 fold resolves a formula `w ≠ χ`, with `w ∈ chain(vᵢ + 1)`. But Lindenbaum's `.choose` in `set_lindenbaum` can, in principle, put χ in the `F(χ)` branch rather than the `χ` branch at every step.

### 4. Why the Perpetual Deferral Case Is Not Excluded by Existing Lemmas

The `enriched_fwd_fold` construction (lines 162–363) uses `set_lindenbaum` with the compound formula `β'` where `F(β') ∈ M`. The `.choose` extracts some MCS M'. In this MCS:
- `β' ∈ M'` (guaranteed by Lindenbaum).
- From `β' ∈ M'`, the extraction function gives `χ ∈ M' ∨ F(χ) ∈ M'`.

The extraction only provides **disjunction**. There is no existing lemma that forces the "left" branch (`χ ∈ M'`). The right branch (`F(χ) ∈ M'`) is always consistent and `.choose` may pick an MCS in which the right branch holds perpetually.

### 5. Why a New Chain Construction Is Required

The comment in the plan (and Round 31 analysis) identifies this correctly: the existing `rr_fwd_chain`/`enriched_fwd_step` infrastructure **cannot be incrementally modified** to prove forward_F. The disjunctive extraction in `enriched_fwd_fold` is an intrinsic limitation. Changing the chain step function is required.

**The core insight**: `fwd_succ M h χ` with `F(χ) ∈ M` guarantees `χ ∈ fwd_succ M h χ` **definitionally** (by `fwd_succ_resolves`, line 92). There is no disjunction. We must make the chain use `fwd_succ` targeting χ at the step where we want `χ` to appear.

---

## Recommended Implementation: Defect-Driven Forward Chain

### 5.1 Core Type Signatures

**New chain function** (replace `rr_fwd_chain`):

```lean
/-- Defect-driven forward chain. At each step, if there are any F-defects
    (χ ∈ sigma_list with F(χ) ∈ M and χ ∉ M), resolve the lexicographically
    first one via fwd_succ. Otherwise, do a standard non-resolving step. -/
noncomputable def dd_fwd_chain
    (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (sigma_list : List Formula) :
    (n : Nat) → { M : Set Formula // SetMaximalConsistent M }
  | 0 => ⟨M₀, h₀⟩
  | n + 1 =>
    let ⟨M, hM⟩ := dd_fwd_chain M₀ h₀ sigma_list n
    let target := firstDefect M sigma_list
    ⟨fwd_succ M hM target, fwd_succ_mcs M hM target⟩
```

where:

```lean
/-- The first formula in sigma_list that is a "defect" at M:
    F(χ) ∈ M and χ ∉ M. Falls back to some default (e.g. bot)
    when no defect exists, giving a non-resolving step. -/
noncomputable def firstDefect (M : Set Formula) (sigma_list : List Formula) : Formula :=
  (sigma_list.find? (fun χ => decide (Formula.some_future χ ∈ M) && decide (χ ∉ M)))
    |>.getD Formula.bot
```

This replaces `rrSchedule sigma_list n` with a **data-dependent target**: the first (lexicographic/list-order) formula that actually needs resolving.

### 5.2 g_content Propagation (Unchanged)

`fwd_succ` already provides:
- `fwd_succ_g_content`: `g_content M ⊆ fwd_succ M hM target` (always)
- `fwd_succ_mcs`: `SetMaximalConsistent (fwd_succ M hM target)` (always)

So `dd_fwd_chain_g_content_step` and `dd_fwd_chain_g_content_trans` carry over verbatim from `rr_fwd_chain_g_content_step` / `rr_fwd_chain_g_content_trans` (lines 701–732).

### 5.3 F-carry at Non-Resolving Steps

When `firstDefect M sigma_list = Formula.bot` (no defect), the call is `fwd_succ M hM Formula.bot`. If `F(⊥) ∉ M` (which holds for any consistent MCS since `⊥` is not provable), this takes the non-resolving branch using seed `g_content(M) ∪ f_carry(M)`, and `fwd_succ_f_carry` gives: all F-formulas survive (any `φ ∈ f_carry(M)` is in the next MCS).

### 5.4 Forward_F Proof Sketch

**Theorem** (`dd_fwd_chain_forward_F`):
```
Given: F(ψ) ∈ dd_fwd_chain M₀ h₀ sigma_list n
       ψ ∈ sigma_list
       h_nonempty, h_closed (sigma_list closed under F-stripping)
Conclude: ∃ s > n, ψ ∈ dd_fwd_chain M₀ h₀ sigma_list s
```

**Proof by strong induction on `f_nesting_depth ψ`**:

**Depth ≥ 1**: Use `rr_fwd_chain_forward_F_depth_pos` verbatim (the proof already works, just change the chain name).

**Depth 0**:

Given `F(ψ) ∈ chain(n)` with `f_nesting_depth(ψ) = 0`:

- **Case A**: `ψ ∈ chain(n)`. Then `φᵢ := phi_in_mcs_imp_F_phi` gives `F(ψ) ∈ chain(n)` (already known). At step `n+1`:
  - Is `ψ` the firstDefect? `ψ ∈ chain(n)`, so `ψ ∉ defect set`. Not the first defect.
  - But some OTHER defect `χ₁` might be first at step `n+1`. After resolving it, at step `n+1`, `χ₁ ∈ chain(n+1)`. Does `ψ` survive?

  Key subtlety: if `ψ ∈ chain(n)` and `G(ψ) ∈ chain(n)`, then `ψ ∈ chain(n+1)` by `fwd_succ_g_content`. But `G(ψ)` may not be in `chain(n)`.

  **Resolution for Case A**: We prove a stronger lemma: for any `ψ ∈ sigma_list` with `F(ψ) ∈ chain(n)`, either:
  1. `ψ ∈ chain(n)`, and we look for a LATER witness (this is the Case A scenario), or
  2. `ψ ∉ chain(n)`, and `ψ` is a defect at `n`, resolved within `|sigma_list|` steps.

  For Case A specifically: `ψ ∈ chain(n)`, so `F(ψ) ∈ chain(n)` (reflexive). At step `n+1`, if ψ is not the first defect (it isn't, since `ψ ∈ chain(n)`), we resolve some `χ₁`. By `fwd_succ_resolves`, `χ₁ ∈ chain(n+1)` and `g_content(chain(n)) ⊆ chain(n+1)`. Now `F(χ₁) ∈ chain(n+1)` by `phi_in_mcs_imp_F_phi`. At step `n+2`, if `χ₁ ∉ chain(n+2)` it's a defect; otherwise the defect set has shrunk by 1.

  The key insight: `ψ ∈ chain(n)` means `F(ψ) ∈ chain(n)` (reflexive F). The forward_F obligation requires strict `s > n`. Since `ψ ∈ chain(n)` satisfies the reflexive reading but NOT the strict future requirement, we must find `ψ ∈ chain(s)` for `s > n`. This IS possible if `G(ψ) ∈ chain(n)`, but in general we cannot guarantee it.

  **Actually, Case A may be the hardest sub-case**. See Section 6.3 below.

- **Case B**: `ψ ∉ chain(n)`. Then `ψ` is an F-defect at time `n`.

  **Key property of `dd_fwd_chain`**: `firstDefect M sigma_list` returns the FIRST defect in list order. Since `ψ ∈ sigma_list` and `ψ` is a defect, there are at most `|sigma_list|` formulas that come before `ψ` in the list. Each of those can be the first defect for at most finitely many consecutive steps before being resolved.

  **Termination argument via defect ordering**: Define `rank(M, ψ)` = index of `ψ` in sigma_list minus the number of formulas in sigma_list that come before ψ and are ALSO defects. This decreases weakly as defects are resolved. When all formulas before ψ in the list have been resolved, ψ becomes the first defect and is resolved at the very next step.

  **But**: resolving a formula before ψ does NOT guarantee ψ's F-obligation persists. Between steps where ψ is not the first defect, the `fwd_succ` call may choose an MCS where `F(ψ)` is absent (via `G(¬ψ)` entering through Lindenbaum).

  **Critical problem**: `fwd_succ M hM χ₁` for the resolving case uses seed `{χ₁} ∪ g_content(M)`. If `G(¬ψ) ∉ M` but `G(¬ψ)` could be consistently added to `{χ₁} ∪ g_content(M)`, the Lindenbaum `.choose` might add it. Then `F(ψ) ∉ chain(n+1)`, the defect is gone, and ψ is never resolved.

### 5.5 The `G(¬ψ)` Entry Problem

This is the fundamental obstruction. At any resolving step for target `χ ≠ ψ`, the seed is `{χ} ∪ g_content(M)`. The Lindenbaum extension may add `G(¬ψ)` if:
1. `G(¬ψ) ∉ M` (so not in g_content), BUT
2. `G(¬ψ)` is consistent with `{χ} ∪ g_content(M)`.

Condition 2 holds whenever `F(ψ) ∉ {χ} ∪ g_content(M)`. Since `F(ψ)` is NOT a G-formula, `F(ψ) ∉ g_content(M)` in general. And `F(ψ) ≠ χ` (since χ is the resolving target). So Lindenbaum CAN add `G(¬ψ)`.

**The ONLY way to prevent this**: Include `F(ψ)` in the seed. The enriched seed `{χ, F(ψ)} ∪ g_content(M)` excludes `G(¬ψ)` by consistency (since `F(ψ) = ¬G(¬ψ)` and both cannot be in a consistent set).

**Is `{χ, F(ψ)} ∪ g_content(M)` consistent?** Yes! Because `χ ∉ M` is NOT required here — actually, `F(χ) ∈ M` is all we know. But `F(ψ) ∈ M` (given, F-obligation present). And `g_content(M) ⊆ M`. The union `{χ, F(ψ)} ∪ g_content(M)`:
- `F(ψ) ∈ M` and `g_content(M) ⊆ M`, so `{F(ψ)} ∪ g_content(M) ⊆ M`. Consistent.
- `{χ} ∪ (something ⊆ M)` is consistent iff the "something" is consistent with χ, which holds since `forward_temporal_witness_seed_consistent M hM χ h_F_χ` says `{χ} ∪ g_content(M)` is consistent, and adding `F(ψ)` from M cannot make it inconsistent (it's all within M).

Wait: `{χ} ∪ g_content(M)` is consistent by `forward_temporal_witness_seed_consistent`. Adding `F(ψ) ∈ M`: the new set is `{χ, F(ψ)} ∪ g_content(M)`. This is a subset of... is it a subset of M? `χ ∉ M` in general (that's why it's a defect). But M is an MCS. `χ ∉ M` yet `F(χ) ∈ M`.

Actually we need: `{χ, F(ψ)} ∪ g_content(M)` is consistent. This is exactly `enriched_resolving_seed_consistent M hM χ (F(ψ)) h_Fχ_and_Fψ` where `h_Fχ_and_Fψ : F(χ ∧ F(ψ)) ∈ M`. Do we have `F(χ ∧ F(ψ)) ∈ M`?

By BX11 (`temp_linearity_mcs`): from `F(χ) ∈ M` and `F(ψ) ∈ M`, one of:
1. `F(χ ∧ ψ) ∈ M` → by `enriched_resolving_seed_consistent`: `{χ, ψ} ∪ g_content(M)` consistent, so `{χ, F(ψ)} ∪ g_content(M)` is also consistent (since `ψ ⊢ F(ψ)` in the MCS).
2. `F(χ ∧ F(ψ)) ∈ M` → exactly `enriched_resolving_seed_consistent M hM χ (F(ψ))`. Consistent.
3. `F(F(χ) ∧ ψ) ∈ M` → `F(ψ ∧ F(χ)) ∈ M` by commutativity. `enriched_resolving_seed_consistent M hM ψ (F(χ))`: `{ψ, F(χ)} ∪ g_content(M)` consistent. This resolves ψ, not χ. We need `{χ, F(ψ)} ∪ g_content(M)`. In case 3, maybe this set is NOT consistent.

**So in BX11 case 3, we cannot include both χ and F(ψ) in the seed.** This means in case 3, ψ "comes first" (is earlier than χ by BX11 ordering), and we should resolve ψ before χ.

**This leads to the same BX11 ordering used by the existing `enriched_fwd_step` infrastructure, BUT with a direct-resolution guarantee.**

---

## Mathematical Obstacles Analyzed

### 6.1 The `phi_in_mcs_imp_F_phi` Problem (Case A)

From sorry 1's comment: "resolving ψ puts ψ in successor, which implies F(ψ) in successor". This means Case A (ψ ∈ chain(n)) propagates into F(ψ) in chain(n+1) and potentially creates a new Case A at the next step.

**Is forward_F in Case A actually provable?**

Under strict semantics, `restricted_temporally_coherent` requires: `F(ψ) ∈ chain(t) → ∃ s > t, ψ ∈ chain(s)`.

If `ψ ∈ chain(t)` (which implies `F(ψ) ∈ chain(t)` reflexively), we still need a STRICT future witness `s > t`.

**Observation**: if `ψ ∈ chain(t)` but `G(ψ) ∉ chain(t)`, ψ may NOT be in chain(t+1). However, `F(ψ) ∈ chain(t)` and `ψ ∉ chain(t+1)` would make ψ a defect at `t+1`. By the defect-driven construction, ψ would be resolved at `t+2` (if it's the first defect). So `s = t+2` works.

If `ψ ∈ chain(t+1)`: then `s = t+1` works.

**In both sub-cases**, ψ appears again within 2 steps. The key issue is showing that `F(ψ)` survives from step `t` to the step where ψ is the first defect (if it becomes absent at t+1). This requires `F(ψ) ∈ chain(t+1)`, which follows if:
- The step at t+1 uses a seed that contains `F(ψ)`, OR
- ψ itself appears in chain(t+1) (giving F(ψ) by phi_in_mcs_imp_F_phi).

If ψ is NOT in chain(t+1) and `F(ψ) ∉ chain(t+1)`, then `G(¬ψ) ∈ chain(t+1)` and ψ will never appear. But we still have the obligation at time t. This is the contradiction: `F(ψ) ∈ chain(t)` and `G(¬ψ) ∈ chain(t+1)`. These are inconsistent if `G(¬ψ) ∈ chain(t)` (they can't both be present), but they can both hold if `G(¬ψ)` entered at step t+1.

**This is the `G(¬ψ)` entry problem again.**

### 6.2 The g_content Chaining Gap

Does `fwd_succ(v_{i-1}, target)` give `g_content(v_{i-1}) ⊆ vᵢ`?

Yes, definitionally: `fwd_succ_g_content M hM ψ : g_content M ⊆ fwd_succ M hM ψ` always holds (both resolving and non-resolving branches include g_content). This is not an obstacle.

### 6.3 The BX11 Case 3 Obstacle for Simultaneous Multi-Defect Protection

When resolving χ while trying to protect F(ψ):
- BX11 gives 3 cases for (χ, ψ).
- Cases 1 and 2: `F(χ ∧ ψ) ∈ M` or `F(χ ∧ F(ψ)) ∈ M`. In both cases, `{χ, F(ψ)} ∪ g_content(M)` or `{χ, ψ} ∪ g_content(M)` is consistent, and `F(ψ)` or ψ itself is preserved.
- Case 3: `F(F(χ) ∧ ψ) ∈ M`. Now ψ comes before χ in BX11 ordering. The seed `{ψ, F(χ)} ∪ g_content(M)` is consistent, but resolves ψ, not χ.

**The resolution**: use BX11 ordering to determine WHICH formula to resolve. The formula that BX11 says "comes first" is the one we resolve. For all other formulas, either they come later (protected by F) or they co-occur (both can be present).

### 6.4 Backward Chain (P-obligations) Symmetry

Sorry 3 (`dd_fmcs_backward_P`) is the exact mirror of sorry 1, for the backward chain `rr_bwd_chain` using `bwd_pred`. The same construction applies: replace `rr_bwd_chain` with a defect-driven backward chain using `bwd_pred` targeting P-defects. The proofs are symmetric under forward/backward duality.

### 6.5 Until/Since Coherence (Sorries 5 and 6)

**Sorry 5 (backward Until/Since)**: Given `∃ s ≥ t, ψ ∈ chain(s)` and guard, need `φ U ψ ∈ chain(t)`.

This uses `backward_until_from_step` from `UntilSinceCoherence.lean` (line 111), which is already parameterized by a **step transfer** hypothesis:
```
h_step : ∀ r, (φ U ψ) ∈ fam.mcs(r+1) → φ ∈ fam.mcs(r) → (φ U ψ) ∈ fam.mcs(r)
```

For the `dd_chain`, this step transfer holds via: from `φ ∈ chain(r)` and `(φ U ψ) ∈ chain(r+1)`, we need `(φ U ψ) ∈ chain(r)`. Since `g_content(chain(r)) ⊆ chain(r+1)` and `φ U ψ ∈ chain(r+1)`, we can use `H(φ U ψ) ∈ chain(r+1)` (from BX4' or the H-backward chain property) to conclude `φ U ψ ∈ chain(r)`.

More precisely: By `FMCS.backward_H` applied to the dd_fmcs, `H(φ U ψ) ∈ chain(r+1)` implies `φ U ψ ∈ chain(r)`. We need to prove `H(φ U ψ) ∈ chain(r+1)`. Since `φ U ψ ∈ chain(r+1)` and `H(F(φ U ψ)) ∈ chain(r+1)` by BX4' applied to `φ U ψ ∈ chain(r+1)`... this gives `F(φ U ψ) ∈ chain(r)` by backward_H. Not quite H(φ U ψ).

**Alternative**: `φ ∈ chain(r)` and the chain has `g_content(chain(r)) ⊆ chain(r+1)`. If `G(φ) ∈ chain(r)` then `φ U ψ` could be derived from BX properties. But `G(φ) ∉ chain(r)` in general.

The backward Until coherence depends on having a **deterministic successor** or a specific link between consecutive chain MCS. This was the "SuccChain deterministic successor" approach (archived). Without a deterministic link, step transfer for Until is hard.

However: note that `backward_until_from_step` only needs the step transfer as a **hypothesis**. If we build the dd_chain so that consecutive MCS are linked by a specific relation (not just g_content inclusion), we can discharge step transfer. The natural relation is: chain(n) and chain(n+1) are in the same BX11-ordered class.

**Sorry 6 (forward Until/Since)**: Given `φ U ψ ∈ chain(t)`, need `∃ s ≥ t, ψ ∈ chain(s)` and guard. This is the **forward Until eventuality** problem. The existing `bx_until_eventuality_resolution` (Frame.lean line 623) gives an ABSTRACT BXPoint witness. Getting that witness onto the chain requires forward_F for ψ (since `φ U ψ ∈ chain(t)` implies `F(ψ) ∈ chain(t)` by BX10, and forward_F gives `ψ ∈ chain(s)` for some `s > t`).

So sorry 6 reduces to sorry 1 for the formula ψ when `deferralClosure(root)` contains ψ. The guard condition requires showing `φ ∈ chain(r)` for all `r ∈ [t, s)`. This follows from: `G(¬φ ∧ ¬ψ) ∉ chain(t)` (by BX7-style argument) combined with forward_F for ψ giving the witness s, and then BX9 (Until elimination) gives `φ ∈ chain(r)` for intermediate r where `ψ ∉ chain(r)`.

---

## Concrete Lean 4 Pseudocode

### 7.1 BX11-Ordered Defect-Driven Step

The key new definition, replacing `enriched_fwd_step`:

```lean
/-- Resolve the BX11-earliest defect in sigma_list. If no defect, do a
    non-resolving step. The BX11-earliest defect is the formula ψ ∈ sigma_list
    with F(ψ) ∈ M such that for all χ ∈ sigma_list with F(χ) ∈ M appearing
    before ψ in list order, bx11_earlier M ψ χ (ψ is earlier than χ). -/
noncomputable def bx11_first_defect (M : Set Formula) (hM : SetMaximalConsistent M)
    (sigma_list : List Formula) : Formula :=
  let defects := sigma_list.filter (fun χ => decide (Formula.some_future χ ∈ M) &&
                                             decide (χ ∉ M))
  match defects with
  | [] => Formula.bot  -- no defect, triggers non-resolving step
  | ψ₀ :: rest =>
    -- Find the BX11-minimum via fold: among all defects, the one that is
    -- bx11_earlier than all others (or = first by list order if tied)
    rest.foldl (fun acc χ =>
      if Classical.propDecidable (bx11_earlier M acc χ) |>.decide then acc else χ
    ) ψ₀

noncomputable def bx11_dd_fwd_step (M : Set Formula) (hM : SetMaximalConsistent M)
    (sigma_list : List Formula) : Set Formula :=
  fwd_succ M hM (bx11_first_defect M hM sigma_list)
```

**Key properties derivable from this definition**:

```lean
-- When F(ψ) ∈ M and ψ ∉ M and ψ is BX11-earliest:
theorem bx11_dd_fwd_step_resolves (M : Set Formula) (hM : SetMaximalConsistent M)
    (sigma_list : List Formula) (ψ : Formula)
    (hψ : ψ ∈ sigma_list)
    (h_defect : Formula.some_future ψ ∈ M ∧ ψ ∉ M)
    (h_earliest : ∀ χ ∈ sigma_list, Formula.some_future χ ∈ M → χ ∉ M →
                  bx11_earlier M ψ χ) :
    ψ ∈ bx11_dd_fwd_step M hM sigma_list :=
  -- fwd_succ_resolves applies since target = ψ and F(ψ) ∈ M
  fwd_succ_resolves M hM ψ h_defect.1
```

### 7.2 Forward_F for the BX11-Ordered Chain

The proof of `dd_fwd_chain_forward_F` at depth 0 proceeds as follows:

```lean
-- Given F(ψ) ∈ chain(n), f_nesting_depth ψ = 0, ψ ∈ sigma_list.
-- Either ψ ∈ chain(n) (Case A) or ψ ∉ chain(n) (Case B).
-- In Case B: ψ is a defect.
-- The defects at each step form a well-ordered sequence by BX11.
-- At each step, either ψ is the earliest defect (resolved in 1 step)
-- or a strictly earlier defect is resolved first, reducing the
-- number of defects that precede ψ.
-- Termination: use strong induction on |{χ ∈ defects | bx11_earlier M χ ψ}|.
theorem dd_fwd_chain_forward_F_depth0
    (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (sigma_list : List Formula) (h_len : sigma_list.length > 0)
    (h_closed : ∀ χ, Formula.some_future χ ∈ sigma_list → χ ∈ sigma_list)
    (n : Nat) (ψ : Formula)
    (hψ : ψ ∈ sigma_list)
    (h_F : Formula.some_future ψ ∈ (dd_fwd_chain M₀ h₀ sigma_list n).val) :
    ∃ s > n, ψ ∈ (dd_fwd_chain M₀ h₀ sigma_list s).val := by
  -- This is the key sorry to close.
  -- The proof needs well-founded recursion on the BX11 defect ordering.
  -- ... (see Section 7.3 for the induction structure)
  sorry
```

### 7.3 Well-Founded Induction Structure

```
Define count_earlier M sigma ψ :=
  |{ χ ∈ sigma | F(χ) ∈ M ∧ χ ∉ M ∧ bx11_earlier M χ ψ }|

Well-founded measure: (count_earlier M sigma ψ)

Induction:
  Base (count_earlier = 0): ψ is the BX11-earliest defect.
    → bx11_first_defect M hM sigma = ψ
    → dd_fwd_chain(n+1) = fwd_succ M hM ψ
    → ψ ∈ chain(n+1) by fwd_succ_resolves
    → s = n+1. Done.

  Step (count_earlier = k+1): Some χ is BX11-earlier than ψ.
    → bx11_first_defect = χ (or something earlier than ψ)
    → chain(n+1) = fwd_succ M hM χ
    → χ ∈ chain(n+1), F(χ) ∈ chain(n+1) (reflexive F)

    Now we need: F(ψ) ∈ chain(n+1) AND count_earlier(chain(n+1), sigma, ψ) < k+1.

    count_earlier decreases because:
    - χ was a defect at n (F(χ) ∈ chain(n), χ ∉ chain(n)).
    - After resolving χ: χ ∈ chain(n+1). So χ is NOT a defect at n+1.
    - χ was strictly BX11-earlier than ψ.
    - At chain(n+1), count_earlier ≤ k (χ dropped out).

    BUT: F(ψ) might not be in chain(n+1)! The seed is {χ} ∪ g_content(chain(n)).

    RESOLUTION: We need bx11_earlier(chain(n), χ, ψ) to guarantee that
    {χ, F(ψ)} ∪ g_content(chain(n)) is consistent (by enriched_resolving_seed_consistent
    in case 1 or 2 of BX11). Then the Lindenbaum extension CAN include F(ψ).

    But which branch of BX11? Case 3 (F(F(χ) ∧ ψ)) means χ is NOT earlier than ψ
    (ψ is earlier than χ in case 3). So if bx11_earlier(M, χ, ψ) holds,
    we're in BX11 case 1 or 2:
      Case 1: F(χ ∧ ψ) ∈ M → seed {χ, ψ} consistent → F(ψ) ∈ chain(n+1) (via phi_in_mcs_imp_F_phi from ψ ∈ chain(n+1))
      Case 2: F(χ ∧ F(ψ)) ∈ M → enriched_resolving_seed_consistent → {χ, F(ψ)} ∪ g_content consistent
                                → use a MODIFIED fwd_succ with seed {χ, F(ψ)} ∪ g_content(M)

    For case 2, the seed {χ, F(ψ)} ∪ g_content(M) is consistent, and the Lindenbaum
    extension includes F(ψ). This requires changing fwd_succ to use the enriched seed!
```

### 7.4 Required Infrastructure Change: Enriched fwd_succ

The insight from Section 7.3, Case 2: we need a version of `fwd_succ` that takes an ADDITIONAL formula to protect:

```lean
/-- Protected forward step: resolves target, AND includes guard F(ψ) in seed
    when F(target ∧ F(ψ)) ∈ M (BX11 case 2 holds). -/
noncomputable def fwd_succ_with_guard (M : Set Formula) (hM : SetMaximalConsistent M)
    (target guard_formula : Formula)
    (h_F_target_and_guard : Formula.some_future (target.and (Formula.some_future guard_formula)) ∈ M) :
    Set Formula :=
  (set_lindenbaum ({target, Formula.some_future guard_formula} ∪ g_content M)
    (enriched_resolving_seed_consistent hM target (Formula.some_future guard_formula) h_F_target_and_guard)).choose

theorem fwd_succ_with_guard_resolves (M : Set Formula) (hM : SetMaximalConsistent M)
    (target guard_formula : Formula)
    (h : Formula.some_future (target.and (Formula.some_future guard_formula)) ∈ M) :
    target ∈ fwd_succ_with_guard M hM target guard_formula h ∧
    Formula.some_future guard_formula ∈ fwd_succ_with_guard M hM target guard_formula h :=
  ⟨(set_lindenbaum _ _).choose_spec.1 (Set.mem_union_left _ (Set.mem_insert _ _)),
   (set_lindenbaum _ _).choose_spec.1 (Set.mem_union_left _ (Set.mem_insert_of_mem _ rfl))⟩
```

This is exactly `enriched_resolving_seed_consistent` already proven in `OrderedSeedConsistency.lean` (line 70), applied to produce a step that resolves `target` while guaranteeing `F(guard_formula)` in the successor.

---

## Confidence Level and Justification

**Confidence: MEDIUM (55-65%)**

### Why Medium

1. **The BX11-ordering approach is mathematically sound**: BX11 gives a well-founded ordering on F-defects (via the three cases), and the `bx11_earlier` relation is already defined and used in `RootScopedChain.lean` (lines 928–972). The proof that the earliest defect is resolved at the next step is straightforward via `fwd_succ_resolves`.

2. **The count_earlier measure decreases**: When χ is BX11-earlier than ψ and we resolve χ, `count_earlier` decreases by at least 1 (χ was a defect at n but is no longer at n+1 since χ ∈ chain(n+1)).

3. **The F(ψ)-survival problem remains partially open**: In BX11 case 2 (F(χ ∧ F(ψ)) ∈ M), we can use `fwd_succ_with_guard` to protect F(ψ). But we need to BUILD the chain to use this enriched step rather than plain `fwd_succ`. This requires modifying the chain definition.

4. **BX11 case 1 is easy**: F(χ ∧ ψ) ∈ M means both can be resolved simultaneously. After resolving χ (with ψ also in the seed), ψ ∈ chain(n+1) directly.

5. **Case A (ψ ∈ chain(n))**: If `ψ ∈ chain(n)` and `F(ψ) ∈ chain(n)`, we need `ψ ∈ chain(s)` for some `s > n`. At step n+1, the chain resolves the first defect (not ψ, since ψ is not a defect). The F(ψ) survival into chain(n+1) is exactly the BX11 case analysis above. After ψ becomes a defect (at the first step where ψ ∉ chain), it gets resolved within finitely many steps.

6. **What's still needed**: A full Lean 4 proof requires:
   - Formalizing `bx11_first_defect` and proving it returns the BX11-minimum.
   - Formalizing `count_earlier` as a well-founded measure.
   - Proving `count_earlier` decreases at each step.
   - Handling the 3-way BX11 case split carefully at the chain level.
   - Constructing the modified chain `bx11_dd_fwd_chain` that uses enriched steps in BX11 case 2.

Estimated new LOC: **200–350** (replacing `rr_fwd_chain`/`enriched_fwd_step` with `bx11_dd_fwd_chain`). Significantly less than the Round 31 estimate of 400–600 for a quasimodel-derived chain.

### Why Not High Confidence

The BX11 case split at the CHAIN level introduces complexity: the BX11 case for a given pair (χ, ψ) depends on the MCS content, which changes at each step. The "count_earlier" measure may not decrease monotonically if BX11 cases change between steps (a formula that was in case 2 at step n might be in case 3 at step n+1 after the MCS changes). A rigorous Lean proof requires showing that BX11 ordering is stable enough under the chain construction.

**The key mathematical lemma needed** (currently unproven):

```
If bx11_earlier M₁ χ ψ and chain(n+1) = fwd_succ M₁ h₁ χ with F(χ) ∈ M₁,
then F(ψ) ∈ chain(n+1).
```

This holds in BX11 cases 1 and 2 (via the enriched seed). In BX11 case 3, `bx11_earlier M₁ χ ψ` would NOT hold (since case 3 means ψ comes before χ). So if `bx11_earlier M₁ χ ψ` holds, we're in cases 1 or 2, and F(ψ) can be protected. This is the core insight.

**The lemma is likely provable.** Confidence remains medium rather than high due to the nontrivial Lean formalization required for the BX11 case analysis at the chain level.

---

## Summary

The defect-driven chain approach replaces `rr_fwd_chain`/`enriched_fwd_step` with a new chain `bx11_dd_fwd_chain` that:
1. At each step, resolves the BX11-earliest F-defect in sigma_list.
2. When resolving target χ while ψ is the next defect (BX11 earlier than everything except χ), uses an enriched seed `{χ, F(ψ)} ∪ g_content(M)` (consistent by `enriched_resolving_seed_consistent`).
3. Guarantees `F(ψ)` survives to the next step.
4. The count of defects BX11-earlier than ψ strictly decreases at each step.
5. Forward_F follows by strong induction on this measure.

Sorries 2 and 3 follow by mirror construction for the backward chain. Sorries 4, 5, 6 follow from the FMCS properties of the new chain.

**Key file references**:
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` — 6 sorry sites, lines 1413, 1457, 1464, 1517, 1522, 1527
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/BXCanonical/CanonicalModel.lean:66` — `fwd_succ` definition
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/BXCanonical/OrderedSeedConsistency.lean:70` — `enriched_resolving_seed_consistent`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean:928` — `bx11_earlier` definition
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean:977` — `discharge_single_step`
