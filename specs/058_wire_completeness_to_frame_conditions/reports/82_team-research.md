# Research Report: Task #58 — Systematic Review

**Task**: Wire completeness to FrameConditions
**Date**: 2026-03-27
**Mode**: Team Research (4 teammates)
**Session**: sess_1774651248_efe3ad
**Focus**: Find the mathematically correct path, not shortcuts

## Summary

After 80+ research reports and 17 plan versions, all 4 teammates converge on the same diagnosis: the core blocker is the gap between **bundle-level** temporal coherence (what `construct_bfmcs_bundle` provides) and **family-level** temporal coherence (what `parametric_shifted_truth_lemma` requires). Every approach tried so far falls into one of two categories: (1) "easy shortcuts" that are mathematically insufficient (bundle substitution, forward-only truth lemma, algebraic bypass — all definitively ruled out), or (2) "principled paths" that hit the **multi-BRS seed consistency** wall (the G-lift barrier). Two genuinely untested alternatives were identified by multiple teammates, plus an immediate 3→1 sorry reduction.

## Key Findings

### The Root Problem (All Teammates Agree)

The 3 sorries in `FrameConditions/Completeness.lean` all reduce to one:

> **`bundle_validity_implies_provability`**: `valid_over Int φ → Nonempty ([] ⊢ φ)`

This requires bridging two type-incompatible constructions:

| What we have | What we need |
|---|---|
| `BFMCS_Bundle` with `BundleTemporallyCoherent` | `BFMCS Int` with `BFMCS.temporally_coherent` |
| F-witness in **any** family (`fam'`) | F-witness in **same** family (`fam`) |
| Sorry-free (`construct_bfmcs_bundle`) | Requires family-level `forward_F` |

The truth lemma **inherently** requires same-family witnesses (Teammate B, D confirmed): the backward G case derives a contradiction by finding `ψ` and `¬ψ` in the same MCS at the same family, which fails when witnesses are in different families.

### Why All 24 Approaches Failed (Teammate A)

The approach catalog identifies 24 distinct approaches across all reports. The failures cluster into three patterns:

**Pattern 1 — The G-Lift Barrier** (blocks approaches 4, 8, 9, 21, 24):
Every seed consistency proof for multiple BRS elements requires `G(x) ∈ M` for each seed element `x`. For BRS elements `ψ`, we have `F(ψ) ∈ M` but **not** `G(ψ) ∈ M`. The algebraic fact `F(ψ) ⊬ G(F(ψ))` (Teammate C proved with countermodel) makes this barrier fundamental, not a formalization artifact.

**Pattern 2 — "Easy Shortcut" Temptations** (blocks approaches 10, 11, 12, 13, 14):
- Bundle-level substitution: rediscovered as insufficient in 6+ independent analyses
- Forward-only truth lemma: the `imp` case uses `.mpr` (backward IH), making it inherently bidirectional
- Algebraic bypass: proves `(∀ MCS, φ ∈ M) → ⊢ φ` (syntactic), not `valid_over Int φ → ⊢ φ` (semantic)
- All three are **definitively dead ends**, yet kept being re-proposed

**Pattern 3 — Correct Path, Wrong Sub-Problem** (blocks approaches 1-3, 16-21):
The restricted construction (deferral closure) is the correct mathematical approach, but every implementation hits multi-BRS seed consistency, which is the same G-lift barrier.

### Task Frame Semantics: Key Insights (Teammate B)

Critical differences from standard Kripke that inform the correct approach:

1. **Truth is evaluated at `(Ω, τ, t)`** — a set of histories, a specific history, and a time. Box quantifies across histories at fixed time; temporal operators quantify across times within a fixed history.

2. **The canonical frame's task relation is forward-only** — `task_rel M d N` is `False` for `d < 0`. This works because `respects_task` only uses non-negative durations.

3. **ShiftClosed has no Kripke analog** — validity requires `ShiftClosed Ω`, meaning histories are closed under time-translation. This is specific to Task Frame semantics.

4. **Atoms are FALSE outside domain, not undefined** — temporal operators "see beyond" a history's domain, with atoms defaulting to false.

5. **G is single-history, not cross-history** — `G(φ)` at `(τ, t)` means φ true at all `s ≥ t` in the **same** history τ. This is precisely why bundle-level coherence (cross-history witnesses) cannot substitute.

### The Sorry Dependency Chain (Teammate C)

```
bundle_validity_implies_provability [SORRY - the ONE target]
  ├── not_provable_implies_neg_consistent [sorry-free]
  ├── construct_bfmcs_bundle [sorry-free → BFMCS_Bundle]
  ├── mcs_neg_gives_countermodel [sorry-free → φ ∉ eval_family.mcs 0]
  │
  ╰── GAP: need semantic falsehood in valid_over Int model
       │
       ├── need: parametric_shifted_truth_lemma [sorry-free]
       │         requires: BFMCS.temporally_coherent (family-level)
       │
       ╰── GAP: BFMCS_Bundle ≠ BFMCS (bundle ≠ family coherence)
                │
                ╰── FUNDAMENTAL: SuccChainFMCS lacks forward_F
                    (G-lift fails for F-formulas; 24 attempts blocked)
```

### Metalogic Audit: We ARE Solving the Right Problem (Teammate D)

The sorry-free infrastructure is extensive and robust:
- All algebraic infrastructure (Lindenbaum algebra, STSA, ultrafilters, R_G, R_Box)
- Full bidirectional truth lemma (`parametric_shifted_truth_lemma`)
- Bundle construction and bundle-level coherence
- Single-BRS seed consistency
- F-nesting boundedness for restricted construction

The gap is **purely** in the temporal coherence layer. We are correctly identified on the problem — we just keep hitting the same wall with different tools.

## Synthesis

### Conflicts Resolved

**Conflict 1: Forward-only truth lemma viability**
- Teammate B notes report 77 suggests a forward-only truth lemma might suffice
- Teammate A catalogs this as definitively blocked (approach #11): the `imp` case backward direction uses `.mpr`
- **Resolution**: The forward-only truth lemma IS blocked. Report 77's suggestion of bypassing the truth lemma entirely is also the "algebraic bypass" approach (#12), which is insufficient.

**Conflict 2: Z-chain tractability**
- Teammate C argues the dovetailing proof is fundamentally hard (Lindenbaum extension cannot be controlled)
- Teammate D argues the Z-chain sorries are "different" from the multi-BRS wall and might be engineering problems
- **Resolution**: Both are partially right. The Z-chain sorries at lines 2347/2369 (G/H crossing case) MAY be tractable engineering (G_theory propagation through chain seam). But `Z_chain_forward_F` (line 2485) IS the dovetailing argument, which Teammate C correctly identifies as mathematically hard. A targeted audit is needed to distinguish the tractable from the hard.

### Gaps Identified

1. **No teammate fully analyzed the deferral disjunction seed approach** — all note it as "untested, promising" but none worked through the detailed proof obligations
2. **The Z-chain crossing-case sorries have never been specifically audited** — are they G-lift barrier instances or different?
3. **The `⊥ ∈ deferralClosure φ` question** (Teammate A, Thread 3) has never been checked

### Recommendations

#### Tier 1: Immediate (reduce scope)

**Wire 3 sorries to 1 via `completeness_over_Int`** — This is typeclass plumbing, not new math. `dense_completeness_fc` and `discrete_completeness_fc` both delegate through `completeness_over_Int`, which delegates to `bundle_validity_implies_provability`. Achievable in 1-2 hours.

#### Tier 2: Targeted Audit (1-2 hours each)

**A. Audit the Z-chain (OmegaFMCS) sorries in `UltrafilterChain.lean`:**
- Lines 2347, 2369: G/H crossing case — is this the G-lift barrier or a tractable seam-propagation argument?
- Lines 2485, 2494: forward_F/backward_P — this IS the dovetailing argument; how close is the existing infrastructure to proving it?
- If the crossing-case sorries are tractable, this path may be shorter than multi-BRS.

**B. Test the deferral disjunction seed approach:**
- Replace bare `ψ` in BRS with `ψ ∨ F(ψ)` in the successor seed
- `ψ ∨ F(ψ)` is already in the MCS (as a deferral disjunction), so consistency is trivial
- Key question: does the `bounded_witness` theorem still extract `ψ` from the Lindenbaum extension of a disjunction seed?
- If yes, this eliminates the G-lift barrier entirely.

**C. Check `⊥ ∈ deferralClosure φ`:**
- If bot is in the closure, the finite-inconsistency argument via `drm_closed_under_derivation` provides a different consistency proof path
- Quick 30-minute check

#### Tier 3: The Hard Mathematical Problem

If Tier 2 audits reveal no shortcut, the remaining path is:

**Prove `Z_chain_forward_F`** — the Burgess/Goldblatt dovetailing argument that the omega-chain resolves all F-obligations. This is the genuine mathematical heart of temporal completeness. It requires either:
- (a) A priority-queue argument with well-founded induction showing all F-obligations are eventually resolved
- (b) A constructive Lindenbaum extension that controls which formulas are added

This is the **mathematically correct** solution — not a shortcut, not a bypass, but the actual hard step that the standard literature hand-waves through.

#### Do NOT Pursue (Definitively Dead)

| Approach | Why Dead |
|---|---|
| Bundle-level truth lemma | Changes semantics; mathematically insufficient |
| Forward-only truth lemma | `imp` backward case uses `.mpr` |
| Algebraic bypass (no truth lemma) | Proves syntactic, not semantic completeness |
| Any approach needing `G(F(ψ)) ∈ M` from `F(ψ) ∈ M` | Algebraically impossible (countermodel exists) |
| Multi-BRS consistency via G-lift | Proven impossible for ≥2 BRS elements |
| Transfer Theorem / History Unification | False theorem |

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key Contribution |
|----------|-------|--------|------------|------------------|
| A | Historical Synthesis | completed | high | Catalog of all 24 approaches; identified 4 recurring "shortcut temptations" |
| B | Task Frame Semantics | completed | high | 6 key differences from Kripke; confirmed G is single-history semantics |
| C | Root Cause Algebraic | completed | high | Precise sorry chain; `F(ψ) ⊬ G(F(ψ))` countermodel; dovetailing analysis |
| D | Metalogic State Audit | completed | high | Confirmed correct problem targeting; Z-chain as alternative path; sorry inventory |

## References

- Burgess, J.P. (1979). "Logic and time." Journal of Symbolic Logic.
- Goldblatt, R. (1992). "Logics of Time and Computation." CSLI Lecture Notes.
- Report 77: Deep path-forward analysis
- Report 76: Multi-BRS consistency team research
- Reports 60-65: BRS consistency analysis
- Reports 40-50: Bundle-level analysis
