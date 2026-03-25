# Research Report: Task #55 — Final Blocker Resolution

**Task**: Prove SuccChain Temporal Coherence Directly
**Date**: 2026-03-24
**Mode**: Team Research (2 teammates)
**Session**: sess_1774404539_851a33

## Executive Summary

The blocker `f_nesting_is_bounded` is mathematically FALSE for arbitrary MCS. After analyzing three proposed resolution paths, the team identified a **fourth, simpler option**: bypass the sorry chain entirely by using the existing `CanonicalConstruction.lean` infrastructure, which already has sorry-free `forward_F`.

**Recommended Resolution**: Use the canonical model approach (already implemented) rather than attempting to fix the SuccChain-based sorry chain.

---

## Key Findings

### 1. The Blocker is Precisely Diagnosed (HIGH CONFIDENCE)

The theorem `f_nesting_is_bounded` claims that for ANY MCS M, F-nesting eventually terminates. This is **mathematically FALSE**.

**Counterexample**: `{F^n(p) | n ∈ ℕ}` is finitely consistent and extends to an MCS M∞ with no nesting bound. This MCS is satisfiable on ℤ with successor, where point 0 satisfies all `F^n(p)` by having `p` at position `n`.

### 2. Bundle-Level Coherence (Option 3) BREAKS the Proof (HIGH CONFIDENCE)

Teammate B demonstrated that weakening `forward_F` to allow phi in ANY family (not the SAME family) breaks `temporal_backward_G`:
- The backward lemma requires `neg(phi) ∈ fam.mcs s` AND `phi ∈ fam.mcs s` in the **SAME** family at the **SAME** time to derive a contradiction
- Cross-family witnesses don't provide this

**Conclusion**: Option 3 is NOT viable.

### 3. Fischer-Ladner Closure Restriction (Option 1) is Partially Implemented (HIGH CONFIDENCE)

Teammate A found that the restricted chain infrastructure exists:
- `f_nesting_is_bounded_restricted` (SuccChainFMCS.lean:715) — PROVEN
- `restricted_forward_chain_F_bounded` (SuccChainFMCS.lean:2298) — PROVEN
- `restricted_forward_chain_forward_F` — PROVEN (modulo 2 boundary sorries)

**Gap**: The Case 1 boundary sorry (`FF(psi) ∉ deferralClosure`) has a genuine mathematical gap — the proof structure needs redesign at the `bounded_witness` level. This is NOT a trivial fix.

### 4. Canonical Construction Already Has Sorry-Free forward_F (CRITICAL FINDING)

**Both teammates converged on this insight**:

| Component | Location | Status |
|-----------|----------|--------|
| `canonical_forward_F` | CanonicalFrame.lean:139-154 | **PROVEN** (no sorry) |
| `canonical_truth_lemma` | CanonicalConstruction.lean:80-91 | **PROVEN** (no sorry) |
| `temporal_theory_witness_exists` | UltrafilterChain.lean:1158-1191 | **PROVEN** (no sorry) |

The sorry chain (f_nesting_is_bounded → succ_chain_forward_F → boxClassFamilies_temporally_coherent) is **only used in `construct_bfmcs`**. The canonical construction does NOT use this chain.

---

## Synthesis: The Correct Resolution Path

### Option A: Use Existing CanonicalConstruction (RECOMMENDED — Most Elegant)

**Key insight**: The project already has a working sorry-free completeness proof in `CanonicalConstruction.lean`. The SuccChain-based `construct_bfmcs` is an alternative approach that introduced the sorry.

**Action**: Verify whether `construct_bfmcs` can delegate to or be replaced by the canonical construction. If the canonical construction provides the same type signature, the entire sorry chain dissolves.

**Confidence**: HIGH — the canonical approach is the standard in modal logic completeness proofs.

### Option B: ResolvingChainFMCS with Per-Obligation Witnesses

Build a new chain type where each step uses `temporal_theory_witness_exists` explicitly:
- For obligation `F(phi)` at step n, create step n+1 with `phi ∈ chain(n+1)`
- `forward_F` holds by construction

This is essentially what Plan v4 Phase 3 proposed, but the insight is that this is NOT the restricted chain — it's a fresh construction.

**Confidence**: MEDIUM — requires new definitions but mathematics is sound.

### Option C: Fair-Scheduling Chain (Not Recommended)

Build an enumeration-based chain that schedules each F-obligation in turn. Standard in LTL literature but complex to implement in Lean 4.

**Confidence**: MEDIUM — technically correct but high implementation effort (5-10 hours).

---

## Conflicts Resolved

| Conflict | Resolution |
|----------|------------|
| Fischer-Ladner vs Fair-Scheduling priority | Teammate A recommended Fischer-Ladner, Teammate B noted its gaps. Resolution: **Both are superseded by Option A** (use existing CanonicalConstruction) |
| Whether restricted chain sorries are fixable | Teammate A suggested boundary argument; Teammate B identified genuine mathematical gap. Resolution: **Case 1 gap is real — don't pursue restricted chain fix** |

---

## Gaps Identified

1. **Verification needed**: Does `CanonicalConstruction.lean` provide a type that can replace `construct_bfmcs`? Need to check type signatures.

2. **Bridge lemma**: If `construct_bfmcs` cannot be directly replaced, need a bridge showing that canonical families ⊆ boxClassFamilies (or vice versa).

---

## Recommendations

### Immediate Action (Phase 3 Resolution)

1. **Read `CanonicalConstruction.lean`** to understand its output type
2. **Compare to `construct_bfmcs`** return type `Σ' (B : BFMCS Int) ...`
3. **If compatible**: Replace `construct_bfmcs` body with delegation to canonical construction
4. **If not compatible**: Implement `ResolvingChainFMCS` as described in Option B

### Why This is Most Elegant

- **Uses existing sorry-free code** — no new mathematics required
- **Standard approach** — the canonical model is how completeness is proven in textbooks
- **Minimal changes** — `construct_bfmcs` is the only consumer; change one function

---

## Teammate Contributions

| Teammate | Angle | Key Finding | Confidence |
|----------|-------|-------------|------------|
| A | Fischer-Ladner / Fair Scheduling | Restricted chain infrastructure exists but has Case 1 gap; boundary argument outlined | HIGH |
| B | Bundle-Level / Prior Art | Bundle-level breaks backward_G; CanonicalConstruction has sorry-free forward_F | HIGH |

---

## References

- **Codebase**: CanonicalFrame.lean, CanonicalConstruction.lean, SuccChainFMCS.lean, UltrafilterChain.lean
- **Fischer-Ladner (1979)**: PDL completeness via closure restriction
- **Blackburn/de Rijke/Venema (2001)**: Modal Logic, Ch. 4 — saturated canonical model
- **Emerson & Clarke (1982)**: Fair scheduling for LTL
- **Manna & Pnueli (1992)**: Temporal Logic of Reactive Systems, Ch. 5

---

## Next Steps

1. **Verify**: Check if `CanonicalConstruction.lean` provides a drop-in replacement for `construct_bfmcs`
2. **If yes**: Replace and remove deprecated SuccChain temporal coherence code
3. **If no**: Implement `ResolvingChainFMCS` with per-obligation witnesses (Option B)
4. **Document**: Mark f_nesting_is_bounded as FALSE with explanation in module doc
