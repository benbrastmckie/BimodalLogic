# Research Report: Task #88 (Round 4)

**Task**: Close remaining 6 BXCanonical sorries
**Date**: 2026-04-09
**Mode**: Team Research (4 teammates)
**Session**: sess_1775802574_f88757

## Summary

Round 4 research (4 teammates: Primary, Alternatives, Critic, Horizons) after 3 prior rounds + 1 implementation attempt. The X-vs-G mismatch is confirmed fundamental for the 6th time with exhaustive axiom analysis (99% confidence). All approaches based on modifying bx_le or propagating Until through g_content are definitively blocked. Two actionable paths emerge: (1) **CanonicalEmbedding:418 via two-point WorldHistory** using sorry-free infrastructure (4-8h, high confidence), and (2) **Frame.lean sorries via quasimodel/Henkin construction** that resolves eventualities by construction rather than ordering propagation (40-80h, medium confidence). Task should be split.

## Key Findings

### 1. X-vs-G Mismatch: Definitively Confirmed (99%)

All 4 teammates independently confirm: no BX axiom combination bridges `φ U ψ ∈ w` to `G(φ U ψ) ∈ w`. Teammate C performed exhaustive analysis of all 37 BX axiom constructors. Key axiom capabilities:

| Axiom | What it gives from `φ U ψ ∈ w` | Why insufficient |
|-------|-------------------------------|------------------|
| BX4 | `G(P(φ U ψ)) ∈ w` — retrospective | P-membership ≠ membership |
| BX5 | `(φ ∧ φ U ψ) U ψ ∈ w` — self-accumulation | Same X-vs-G gap on enriched formula |
| BX6 | Absorption (wrong direction) | Goes Until→Until, not Until→G(Until) |
| BX7 | Orders concurrent Until witnesses | Orders times, not propagates membership |
| BX10 | `F(ψ) ∈ w` — existence of witness | Gives one witness, not guard at all points |
| BX12 | `F(φ) → ⊤ U φ` | Direction is F→Until, not Until→G |

**The mismatch is semantically correct**: `φ U ψ` holding now does NOT imply it holds at all future times. This is not a proof gap but a mathematical fact. The canonical ordering `bx_le w v := g_content w.formulas ⊆ v.formulas` is fundamentally unsuitable for Until eventuality resolution because it requires G-membership for propagation.

### 2. CanonicalEmbedding:418 — Two-Point History Approach (NEW, HIGH confidence)

**Conflict resolved**: Teammates A and D recommend the RestrictedTemporallyCoherentFamily approach (12-18h). Teammate C identified a critical dependency: this route requires `succ_chain_restricted_forward_F` and `succ_chain_restricted_backward_P` in SuccChainFMCS.lean, which are themselves sorry'd. The 12-18h estimate is unreliable because it implicitly requires closing upstream sorries first.

**Recommended approach** (from Teammate C, supported by B): Use a **direct two-point WorldHistory** that avoids sorry'd infrastructure entirely:

1. Use `bx_forward_witness` to get `v ≥ w` (sorry-free in CanonicalFrame.lean)
2. Build a 2-time TaskModel with times {0, 1} where `history(0) = w` and `history(1) = v`
3. On this model, `truth_at G(α) at 0` requires `α` at time 1 (v), breaking the constant-history collapse
4. Use `G_iff_mcs` and `H_iff_mcs` from TruthLemma.lean (both **sorry-free**) for the truth bridge
5. Derive contradiction for imp Case B: `ψ ∈ w` but `χ ∉ w` where `ψ.imp χ` is USF

**Why this works**: The constant-history collapse (`truth_at G(α) = truth_at α`) is what blocks the current proof. A two-point history breaks this collapse. The truth bridge for USF formulas uses only sorry-free lemmas (atom, bot, imp from MCS properties; box from `Box_iff_mcs`; G/H from `G_iff_mcs`/`H_iff_mcs`).

**Estimated effort**: 4-8 hours (vs 12-18h for the RestrictedTC route)
**Confidence**: 75% (logical sketch verified; needs implementation verification)
**Dependencies**: None — uses only sorry-free infrastructure

### 3. Frame.lean Sorries — Two Viable Long-Term Approaches

All 4 teammates agree: no incremental fix to bx_le or axiom additions will close Frame.lean sorries. The approaches that remain:

**Approach A: Henkin Fair Scheduling** (Teammate A, 60% confidence, 50-90h)
- Build an ω-chain via fair scheduling: enumerate all Until obligations, resolve each at a scheduled step
- Uses existing `canonical_forward_U` (sorry-free) for single-step witnesses
- Uses `backward_until_from_step` (sorry-free) for backward propagation given step transfer
- Step transfer is provable because the chain is constructed to include Until witnesses
- Corresponds to Burgess (1984) "companion sequences"

**Approach B: Quasimodel/GHR Construction** (Teammates C, D, 50-70% confidence, 40-60h)
- Build satisfaction-compatible model where eventualities are resolved by construction
- Avoids bx_le entirely — no ordering to propagate through
- Standard technique: Gabbay-Hodkinson-Reynolds (1994)
- Risk: task 83 identified "linearization issues" that need assessment
- Requires ~1500-2000 LOC in a new module

**Both approaches share the key insight**: eventualities must be resolved BY CONSTRUCTION of the model, not by propagation through a pre-existing ordering. The current BXCanonical approach tries to find witnesses in an already-constructed canonical model, which fails because the model's ordering doesn't carry the necessary structure.

**Approach C: Enriched Lindenbaum Seeds** (Teammate B, medium-high confidence)
- Enrich seeds with Until-persistence material using BX5/BX6/BX7
- Teammate A analyzed this and found it faces the SAME X-vs-G mismatch: the step transfer `φ U ψ ∈ chain(r+1) → φ U ψ ∈ chain(r)` requires backward propagation which is the core blocker
- **Resolution**: This approach is blocked unless combined with fair scheduling (Approach A) where the chain is explicitly constructed to include Until witnesses

### 4. Additional Findings

**FMP path is sorry-free** (Teammate B): `Decidability/FMP/` has zero sorries. The G/H filtration lemmas were archived for strict semantics but may be restorable under BX's reflexive semantics (BX1 = `G(φ) → φ`). Until/Since filtration remains hard.

**Research circularity confirmed** (Teammate C): 5 rounds have rediscovered the same mismatch. Each round's innovation was demolished by the next. The correct conclusion: Frame.lean sorries require a fundamentally different model construction technique, not incremental improvements to bx_le.

**Until-induction was explicitly removed** (Teammate A): BX originally had an Until-induction axiom (Burgess-Xu induction principle) that was removed during BX refactoring. This is exactly what would bridge the guard quantification gap. Its removal is confirmed correct (it was derivable in some formulations but the BX system chose a different axiom basis), but explains why the proof cannot be done with BX5+BX6 alone.

**Axiom system is correct** (Teammate D, high confidence): BX1-BX12 is sound and complete for the intended semantics. The problem is the canonical model construction technique, not the axioms.

## Synthesis

### Conflicts Resolved

1. **CanonicalEmbedding approach**: RestrictedTC (A, D) vs two-point history (C, B). **Resolved**: Two-point history is preferred because it avoids sorry'd upstream dependencies in SuccChainFMCS. The RestrictedTC approach is conceptually valid but operationally blocked by the same class of sorries it claims to bypass.

2. **Frame.lean approach**: Enriched seeds (B) vs Henkin scheduling (A) vs quasimodel (C, D). **Resolved**: Enriched seeds alone are blocked (A's analysis). Henkin scheduling and quasimodel are closely related — both resolve eventualities by construction. The choice between them is implementation strategy, not mathematical viability. Quasimodel has more literature support; Henkin scheduling may integrate better with existing codebase infrastructure.

3. **Task scope**: All teammates support CanonicalEmbedding independence. D explicitly recommends splitting. **Resolved**: Split task 88 (CanonicalEmbedding only) from new task for Frame.lean sorries.

### Gaps Identified

1. **Quasimodel linearization issues**: Task 83 flagged but never resolved. Needs 4-8h research spike before committing to quasimodel approach for Frame.lean.
2. **FMP filtration under reflexive semantics**: Teammate B identified that archived G/H filtration lemmas may be restorable. Not investigated.
3. **Two-point history implementation details**: The truth bridge for nested G/H inside imp needs careful construction. Not yet prototyped.

### Recommendations

**Immediate action (highest ROI)**:
1. **Split task 88**: Narrow to CanonicalEmbedding:418 only (two-point history approach, 4-8h)
2. **Create task 89**: Frame.lean sorries via quasimodel or Henkin construction (research spike first)

**CanonicalEmbedding:418 plan**:
- Build two-point TaskModel with `history(0) = w`, `history(1) = bx_forward_witness w`
- Prove truth bridge for USF formulas using sorry-free `G_iff_mcs`/`H_iff_mcs`
- Close imp Case B by deriving contradiction with `ψ ∈ w`, `χ ∉ w`
- Effort: 4-8h, confidence: 75%

**Frame.lean plan** (for future task):
- 4-8h research spike: assess quasimodel viability, investigate task 83 linearization issues
- If viable: 30-40h quasimodel implementation in new module
- Alternative: Henkin fair scheduling (50-90h, more conservative)
- Either approach resolves the fundamental architectural mismatch by building models where eventualities are resolved by construction

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key Contribution |
|----------|-------|--------|------------|------------------|
| A | Primary approaches | completed | high | Exhaustive analysis of 3 approaches; all blocked; Henkin scheduling viable |
| B | Alternative approaches | completed | medium-high | FMP path sorry-free; enriched seeds proposal; UntilSinceCoherence infrastructure |
| C | Critic | completed | high | RestrictedTC upstream sorry dependency; two-point history alternative; research circularity |
| D | Strategic horizons | completed | medium-high | Task splitting; publication milestones; quasimodel assessment; axiom correctness |

## References

- Frame.lean:585-622 — X-vs-G mismatch analysis (canonical)
- TruthLemma.lean — `G_iff_mcs`, `H_iff_mcs` (sorry-free)
- CanonicalFrame.lean — `canonical_forward_U`, `bx_forward_witness` (sorry-free)
- UntilSinceCoherence.lean — `backward_until_from_step` (sorry-free, parameterized)
- SuccChainFMCS.lean:3936-3946 — `succ_chain_restricted_forward_F/backward_P` (sorry'd)
- Decidability/FMP/ — entire path sorry-free
- Burgess (1984) — companion sequences for temporal logic completeness
- Gabbay-Hodkinson-Reynolds (1994) — quasimodel approach for temporal logic
