# Research Report: Task #93 — Reflexive Completeness Strategy

**Task**: 93 - Complete BXCanonical embedding (reflexive semantics)
**Date**: 2026-04-21
**Branch**: `until` (reflexive semantics: G ≤, H ≤, Until s ≥ t, Since s ≤ t)
**Context**: Synthesized from task 109 research reports 09-12 conducted on the `irr_until` branch

## Summary

This report consolidates findings from four rounds of deep team research (reports 09-12 on `irr_until`) back into the context of the `until` branch's reflexive completeness proof. The key conclusion: **the `until` branch is 5 sorries from sorry-free completeness**, all concentrated in `RootScopedChain.lean`. The mathematical arguments for all 5 are understood. The gap is formalization in Lean 4.

## Current State of the `until` Branch

### Sorry-Free Infrastructure (Confirmed)

| File | Lines | Sorries | Status |
|------|-------|---------|--------|
| `OrderedSeedConsistency.lean` | 255 | **0** | Fully proved — BX11 ordered defect discharge |
| `Frame.lean` | 673 | **0** | Fully proved — S5 modal equivalence, g_content closure |
| `CanonicalModel.lean` | 498 | **0** | Fully proved — chain construction, box stability, FMCS assembly |
| `TruthLemma.lean` | 320 | **0** | Fully proved — all formula cases |
| `Completeness.lean` | 152 | **0** | Fully proved — wires through `dd_countermodel` |
| `Soundness.lean` | — | **0** | Fully proved |
| `TemporalDerived.lean` | 526 | **0** | Fully proved — BX8 gives ψ→φUψ, BX1 gives φ→F(φ) |

### The 5 Sorry Sites (All in `RootScopedChain.lean`, 1681 lines)

| # | Line | Theorem | What It Needs | Difficulty |
|---|------|---------|---------------|------------|
| 1 | 1111 | `fwd_chain_forward_F` | F-resolution: F(φ) ∈ chain(n) → ∃m>n, φ ∈ chain(m) | MEDIUM |
| 2 | 1138 | `dd_bfmcs_restricted_tc` (bwd case) | F in backward chain → propagate to origin → use #1 | LOW-MEDIUM |
| 3 | 1145 | `dd_bfmcs_restricted_tc` (P-direction) | Symmetric P-resolution via `bwd_chain_backward_P` | MEDIUM |
| 4 | 1153 | `dd_bfmcs_restricted_buc` | Backward Until coherence — step transfer property | HARD |
| 5 | 1160 | `dd_bfmcs_restricted_fuc` | Forward Until coherence — BX10 + F-resolution + guard | MEDIUM |

### Completeness Architecture

```
bx_completeness (Completeness.lean, sorry-free)
  → dd_countermodel (RootScopedChain.lean)
    → dd_bfmcs (BFMCS construction)
      → dd_bfmcs_restricted_tc   [sorries #1, #2, #3]
      → dd_bfmcs_restricted_buc  [sorry #4]
      → dd_bfmcs_restricted_fuc  [sorry #5]
    → fully_restricted_parametric_representation_from_neg_membership (sorry-free)
```

## Key Mathematical Arguments

### Sorry #1: F-Resolution via Schedule Surjectivity

The `fwd_chain` uses `fwd_succ` which at step n targets `schedule(n)`. `schedule_surjective_above` guarantees every formula is visited infinitely often.

**Argument**: Given F(φ) ∈ chain(n), by `schedule_surjective_above` there exists m ≥ n with schedule(m) = φ. If F(φ) ∈ chain(m) (still present), then `fwd_succ_resolves` gives φ ∈ chain(m+1). The question is whether F(φ) persists to step m.

**Under reflexive semantics**: F(φ) ∈ M means ¬G(¬φ) ∈ M, i.e., ∃s ≥ t, φ(s). By BX1 (G(φ)→φ), g_content(M) ⊆ M, so the Lindenbaum seed is richer than under irreflexive semantics. However, F(φ) is still not a G-formula, so it's not directly in g_content.

**The `f_carry` enrichment**: The `until` branch's `fwd_succ` already includes `f_carry` at non-resolving steps, explicitly preserving all F-obligations in the seed. At resolving steps, the target is resolved directly. This means F(φ) persists across all steps until its scheduled resolution.

### Sorry #4: Backward Until Coherence (The Hard One)

Requires the step transfer: `(φ U ψ) ∈ chain(r+1) ∧ φ ∈ chain(r) → (φ U ψ) ∈ chain(r)`.

**Under reflexive semantics**: BX8 gives ψ → φ U ψ (reflexive Until introduction). If ψ ∈ chain(r), done immediately. If ψ ∉ chain(r), need (φ U ψ) at r from the witness at r+1. Under reflexive Until (s ≥ r), the witness s from (φ U ψ) at r+1 satisfies s ≥ r+1 ≥ r, so it's also a valid witness for (φ U ψ) at r. The guard at r covers [r, s) = {r} ∪ [r+1, s). φ(r) is given; [r+1, s) from the Until at r+1. Semantically valid.

The step transfer must be proved syntactically within the BX proof system. The key tools are BX8, BX5 (self-accumulation), BX6 (absorption), and `or_until_in_mcs` (the disjunction introduction for Until).

### Sorries #2, #3, #5: Dependencies on #1

- Sorry #2: F in backward chain → propagate F to origin via chain connectivity → use F-resolution (#1) in forward chain
- Sorry #3: Symmetric to #1 using `bwd_chain_backward_P` and backward schedule
- Sorry #5: BX10 extracts F(ψ) from (φ U ψ), then #1 resolves it; BX5 + BX9 give guard persistence

## What Changed Since Plan v13

Plan v13 on the `until` branch targeted 50 hours across an elaborate defect-discharge construction. The current analysis (informed by 60+ rounds of research on `irr_until`) identifies a simpler path:

1. **The schedule-based chain already exists and is sorry-free** in `CanonicalModel.lean`. The `f_carry` enrichment preserves F-obligations. No new chain construction needed.
2. **OrderedSeedConsistency.lean is proved** — the mathematical breakthrough from report 13 is fully formalized.
3. **The 5 sorries are pure proof obligations**, not architectural gaps. The existing infrastructure supports all 5 arguments.

## Recommendations

1. **Do not restart from scratch** — the `until` branch is in excellent shape
2. **Focus on sorry #1 first** — it unblocks #2, #3, and #5
3. **Sorry #4 may benefit from the step transfer approach** documented in `UntilSinceCoherence.lean` — the `backward_until_from_step` parameterized theorem is already there, waiting for a step transfer proof
4. **Estimated effort: 28-43 hours** to close all 5 sorries

## References

- Task 109 Report 09: A2 convention non-standard; 33 approaches cataloged
- Task 109 Report 10: B1 convention analysis; enriched-seed chain under irreflexive G
- Task 109 Report 11: `until` branch 5 sorries from complete; no conservative extension for U/S
- Task 109 Report 12: Van Benthem irreflexivity undefinability — no obstruction to strategy
- `until` branch `RootScopedChain.lean`: 1681 lines, 5 sorries
- `until` branch `OrderedSeedConsistency.lean`: 255 lines, 0 sorries
