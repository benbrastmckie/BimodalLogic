# Implementation Summary: BXCanonical Embedding

## Sessions
- sess_1776132289_bbf044 (2026-04-14): Phase 1 + partial Phase 2
- sess_1776278400_a3b7c1 (2026-04-14): Phase 2 continuation
- sess_1776180711_c675a9 (2026-04-14): Deep analysis of forward_F obstacle

## Status: PARTIAL

## What Has Been Proved (Sorry-Free)

### OrderedSeedConsistency.lean
- `enriched_resolving_seed_consistent`: If F(ψ ∧ α) ∈ M, then {ψ, α} ∪ g_content(M) is consistent
- `ordered_two_defect_seed_consistent`: Special case for two F-defects
- `temp_linearity_mcs`: BX11 at MCS level — three-way case split
- `two_defect_consistent_seed`: From two F-defects, find consistent resolving seed
- `no_new_f_defects`: If G(¬α) ∈ M and g_content(M) ⊆ M', then F(α) ∉ M'

### RootScopedChain.lean (lines 1-684 proved, 686-879 has sorries)
- `FF_imp_F`: F(F(ψ)) → F(ψ) derivable in BX
- `F_mono`, `F_conj_left_mcs`, `F_conj_right_mcs`: F-monotonicity
- `enriched_fwd_fold`: BX11 fold producing compound with extraction functions
- `enriched_fwd_exists`: Existence of MCS with g_content subset and F-preservation
- `enriched_fwd_step` + MCS/g_content/preserves properties
- `rr_fwd_chain`, `rr_bwd_chain`, `dd_chain`: Round-robin chain + Int assembly
- g_content/h_content propagation (Nat and Int), box_stable_dd_chain
- `dd_fmcs`, `shifted_dd_fmcs`: FMCS structure definitions
- `dd_bfmcs`: BFMCS with modal_forward, modal_backward proved

## Remaining Sorries (6)

| # | Sorry | Line | Blocked By |
|---|-------|------|------------|
| 1 | `rr_fwd_chain_forward_F` | 770 | **KEY BLOCKER** — needs chain restructuring |
| 2 | `dd_fmcs_forward_F` | 777 | #1 |
| 3 | `dd_fmcs_backward_P` | 784 | symmetric to #1 |
| 4 | `dd_bfmcs_restricted_tc` | 837 | #1 + #3 |
| 5 | `dd_bfmcs_restricted_buc` | 842 | step transfer |
| 6 | `dd_bfmcs_restricted_fuc` | 847 | forward Until discharge |

## Critical Analysis: Why Round-Robin Cannot Prove forward_F

Session sess_1776180711_c675a9 established that the current `enriched_fwd_step` chain **cannot** prove `forward_F`. The argument proceeds in four parts.

### 1. S(n) is constant

Define S(n) = {φ ∈ sigma_list | F(φ) ∈ chain(n)}.

**S is non-increasing**: By `no_new_f_defects` — if F(φ) ∉ chain(n) then G(¬φ) ∈ chain(n), so G(G(¬φ)) ∈ chain(n) by temp_4, so G(¬φ) ∈ g_content(chain(n)) ⊆ chain(n+1), so F(φ) ∉ chain(n+1). Contrapositive: F(φ) ∈ chain(n+1) → F(φ) ∈ chain(n).

**S is non-decreasing**: For any MCS M, φ ∈ M → F(φ) ∈ M. Proof: φ ∈ M → G(¬φ) ∉ M (otherwise ¬φ ∈ M by temp_t, contradicting φ ∈ M) → F(φ) = ¬G(¬φ) ∈ M (MCS negation completeness). So: at each step, `enriched_fwd_step_preserves` gives φ ∈ chain(n+1) or F(φ) ∈ chain(n+1). In either case F(φ) ∈ chain(n+1).

Combined: S(n+1) = S(n) for all n. S is constant.

### 2. BX11 fold may perpetually F-wrap the target

The `enriched_fwd_fold` starts with β = target. At each BX11 step with another formula χ:
- Case 1: F(β ∧ χ) — target stays direct
- Case 2: F(β ∧ F(χ)) — target stays direct
- Case 3: F(F(β) ∧ χ) — target gets F-wrapped, χ becomes direct

Once the target is F-wrapped (case 3), it cannot return to the top level in subsequent fold steps. If case 3 occurs at the FIRST fold step, the target is permanently F-wrapped for this chain step.

BX11 case 3 means: F(F(ψ) ∧ χ) ∈ chain(m), i.e., χ's witness comes before ψ's. If ψ's witness is perpetually "later" than all others, case 3 occurs at every scheduling of ψ.

### 3. No syntactic contradiction from persistent F(ψ) without ψ appearing

Assume for contradiction: F(ψ) ∈ chain(m) for all m ≥ n, but ψ ∉ chain(m) for all m > n. Then ¬ψ ∈ chain(m) for all m > n (MCS).

To derive a contradiction, we'd need G(¬ψ) ∈ chain(n) (contradicts F(ψ) ∈ chain(n)). This requires **backward_G**: if ¬ψ ∈ chain(m) for all m ≥ n, then G(¬ψ) ∈ chain(n).

But backward_G is the CONTRAPOSITIVE of forward_F: G(¬ψ) ∉ chain(n) → F(ψ) ∈ chain(n) → ∃ s > n, ψ ∈ chain(s) → ¬ψ ∉ chain(s). So backward_G REQUIRES forward_F. Circular.

Meanwhile, ¬ψ and F(ψ) are syntactically compatible: ¬ψ says "ψ false now", F(ψ) = ¬G(¬ψ) says "not always ¬ψ in the future." Both can hold in an MCS. No contradiction.

### 4. Enriched seed with f_carry can be inconsistent

The natural fix — seed = {ψ} ∪ g_content(M) ∪ f_carry(M) — fails because the seed can be inconsistent.

**Counterexample** (from report 13): Let G(F(α) → ¬ψ) ∈ M, F(α) ∈ M, F(ψ) ∈ M. Then:
- g_content contains: F(α) → ¬ψ (from G-unwrap)
- f_carry contains: F(α)
- Seed has: ψ, (F(α) → ¬ψ), F(α). Modus ponens gives ¬ψ. With ψ: inconsistent.

The G-lifting argument from `forward_temporal_witness_seed_consistent` fails because F(α) is NOT a G-formula — we cannot derive G(¬ψ) from it.

### 5. Resolution: Ordered defect-discharge chain

The correct approach uses `enriched_resolving_seed_consistent` directly: if F(ψ ∧ α) ∈ M, the seed {ψ, α} ∪ g_content(M) is consistent WITH ψ guaranteed in the seed (not a disjunction).

At each step, use BX11 to find the formula with the earliest witness. That formula satisfies F(target ∧ compound_of_F(others)) ∈ M, so it can be placed directly in the seed. The defect count strictly decreases. After at most |sigma_list| steps, extend with identity tail where all defects are resolved.

## Build Status

`lake build` succeeds. 6 sorry in RootScopedChain.lean, 6 in CanonicalModel.lean (dead code paths).
