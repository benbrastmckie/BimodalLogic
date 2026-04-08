# Research Report: Task #83 — BXCanonical Phase 4 Completion Strategy

**Task**: 83 - close_restricted_coherence_sorries
**Date**: 2026-04-07
**Mode**: Team Research (3 teammates: math, lean-infrastructure, literature)
**Session**: sess_1775605000_r83math

## Summary

Three-teammate investigation of the 4 remaining BXCanonical sorries (Until/Since truth lemma + completeness theorem) and 3 Soundness.lean sorries. All teammates converge on a consistent strategy with one critical prerequisite and one resolved conflict.

## Key Findings

### 1. The Critical Prerequisite: `ψ → φ U ψ` Derivability

All three teammates independently identified that **`ψ → φ U ψ` must be derivable from BX axioms** as a prerequisite for both forward and backward directions. Under reflexive Until semantics this is semantically valid (witness = current time, guard vacuous).

**Derivation approach**: Use BX3 (right monotonicity) with a suitable substitution, or derive from BX1 + BX5 structure. If this proves difficult in Lean, add as a derived theorem from the axioms via semantic validity + soundness.

### 2. Forward Direction Strategy (Sorry 1 — hardest)

**Agreed approach across all teammates**:

1. **Derive key lemmas first**:
   - `φ U ψ → φ ∨ ψ` (from reflexive witness: if ψ ∉ w then φ ∈ w for the guard)
   - `φ U ψ → F(ψ)` (via BX3 + BX1: right-monotonicity gives `φ U ψ → φ U ⊥` under `G(ψ → ⊥)`, then `φ U ⊥ → ⊥` since no witness for ⊥ exists; contrapositive gives `¬G(¬ψ)` = `F(ψ)`)
   - `ψ → φ U ψ` (reflexive witness)

2. **Construct witness v**: From `F(ψ) ∈ w`, use existing `bx_forward_witness` to get `v ≥ w` with `ψ ∈ v`. No separate Zorn application beyond Lindenbaum.

3. **Verify guard** (the hard part): Show `φ ∈ u` for all `u` with `w ≤ u < v`.

   **The guard problem**: `φ U ψ ∈ w` does NOT propagate to arbitrary `u ≥ w` via `bx_le` (that would require `G(φ U ψ) ∈ w`). The guard verification requires BX5 (self-accumulation) + BX7 (linearity):

   - BX5 gives: `(φ ∧ φ U ψ) U ψ ∈ w` — enriched guard persists
   - For any intermediate `u`, BX7 (linearity) constrains the ordering of Until witnesses
   - The argument: at any `u` between `w` and `v` where `ψ ∉ u`, the enriched Until must still hold at `u`, forcing `φ ∈ u`

   **Alternative (Zorn-based)**: Define `S_bad = {M : MCS | w ≤ M, φ U ψ ∈ M, ψ ∉ M}`, find maximal element via Zorn, build witness just above it. This gives a "closest" witness where the guard is easier to verify.

### 3. Backward Direction Strategy (Sorry 2)

**Two-case proof**:
- **Case v = w** (reflexive): `ψ ∈ w`, use `ψ → φ U ψ` to get `φ U ψ ∈ w`
- **Case v > w** (strict): `φ ∈ w` (from guard), `ψ ∈ v`, need to propagate. Use BX4 (connectedness) + derived unfolding: `ψ ∨ (φ ∧ G(φ U ψ)) → φ U ψ` if derivable, or use contrapositive approach.

**Contrapositive approach**: From `¬(φ U ψ) ∈ w`, derive `¬ψ ∈ w` (since `ψ → φ U ψ` gives contrapositive `¬(φ U ψ) → ¬ψ`). Then for any `v ≥ w` with `ψ ∈ v`, use BX4 to find an intermediate `u` where `φ` fails.

### 4. Since Cases (Sorry 3) — Mechanical Mirror

All dual infrastructure exists: `h_content_closed_derivation`, `bx_backward_witness`, BX5'/BX6'/BX4'/BX7'. Direct temporal mirror of Until proofs.

### 5. Completeness Theorem (Sorry 4) — Canonical TaskModel

**Conflict resolved**: Teammate A showed that constant histories are **insufficient** (G/H truth quantifies over all times in history, but constant histories only visit one MCS). Teammates B and C initially suggested constant histories but the analysis confirms they fail.

**Agreed approach**: Build richer histories following `CanonicalConstruction.lean` pattern:
- D = Int, WorldState = BXPoint (or CanonicalWorldState)
- For each BXPoint w₀, build a history visiting multiple MCS along the bx_le chain
- Reuse existing `CanonicalTaskFrame`, `canonical_task_rel`, `to_history` infrastructure
- Define Omega as shift-closed set of all canonical histories
- Wire BXCanonical truth lemma into existing completeness infrastructure

### 6. Soundness.lean Sorries (Lines 877, 1094, 1151)

**Unified fix** (HIGH confidence, all teammates agree):
- All 3 sorries are `temporal_duality` cases requiring `derivable_implies_swap_valid`
- The density constraint in `derivable_implies_swap_valid` is **inherited, not used** — `axiom_swap_valid` doesn't use `DenselyOrdered` or `Nontrivial`
- **Fix**: Factor out `derivable_swap_valid_general` without density constraints
- Estimated effort: 1-2 hours (mechanical refactoring)
- These do NOT block BXCanonical completeness

### 7. No Prior Formalization Exists

Literature survey (Teammate C) confirms: **no proof assistant has formalized Until/Since canonical completeness**. Our work would be the first mechanized completeness proof for a temporal logic with Until/Since via canonical models.

## Synthesis

### Conflicts Resolved

| Conflict | Resolution |
|----------|------------|
| Constant vs rich histories for TaskModel | Constant histories fail for G/H — must use rich histories visiting multiple BXPoints |
| Zorn vs direct witness for forward direction | Both viable; direct witness via `bx_forward_witness` is simpler but guard is harder; Zorn gives "closest witness" with easier guard. **Recommend trying direct first, Zorn as fallback** |
| Whether `ψ → φ U ψ` needs separate proof | All agree it's needed and semantically valid; derivation path via BX3 or BX1+structure |

### Gaps Identified

1. **Guard verification for forward Until**: The exact BX7 argument for proving `φ ∈ u` at intermediate points is not fully worked out. This is the single hardest step.
2. **Unfolding equivalence**: Whether `φ U ψ ↔ ψ ∨ (φ ∧ G(φ U ψ))` is derivable from BX axioms (it should be, but needs verification).
3. **Canonical TaskModel wiring**: How exactly to connect BXCanonical truth lemma to the existing `CanonicalConstruction.lean` infrastructure.

### Recommended Implementation Order

| Step | What | Depends On | Effort | Confidence |
|------|------|-----------|--------|------------|
| 0 | Fix Soundness.lean sorries (swap-valid refactor) | Nothing | 1-2h | HIGH |
| 1 | Derive `ψ → φ U ψ` from BX axioms | Nothing | 1h | HIGH |
| 2 | Derive `φ U ψ → φ ∨ ψ` | Step 1 | 1h | HIGH |
| 3 | Derive `φ U ψ → F(ψ)` | Nothing | 1h | HIGH |
| 4 | Prove backward Until (Sorry 2) | Steps 1-2 | 2h | MEDIUM-HIGH |
| 5 | Prove forward Until (Sorry 1) | Steps 1-3, possibly 4 | 3-4h | MEDIUM |
| 6 | Mirror for Since (Sorry 3) | Steps 4-5 | 1h | HIGH (once Until done) |
| 7 | Canonical TaskModel + completeness (Sorry 4) | Steps 4-6 | 2-3h | MEDIUM-HIGH |

**Total estimated**: 12-15 hours remaining for Phase 4 completion.

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key Contribution |
|----------|-------|--------|------------|-----------------|
| A | Mathematical proof structure | completed | medium | Guard verification analysis, constant-history failure, Zorn chain approach |
| B | Lean infrastructure inventory | completed | high | Unified soundness fix, MCS property inventory, Mathlib Zorn API |
| C | Published literature | completed | medium-high | No prior formalization, BX5/BX6 argument from Burgess/Xu, F(ψ) derivation strategy |

## References

- Burgess 1982, "Axioms for Tense Logic I: Since and Until", NDJFL 23(4)
- Xu 1988, "On some U,S-tense logics", JPL 17
- Goldblatt 1992, "Logics of Time and Computation", 2nd ed.
- Gabbay, Hodkinson, Reynolds 1994, "Temporal Logic: Mathematical Foundations", Vol. 1
- Venema 1993, "Completeness via Completeness"
- Hodkinson & Reynolds 2007, "Temporal Logic", Handbook of Modal Logic Ch. 11
