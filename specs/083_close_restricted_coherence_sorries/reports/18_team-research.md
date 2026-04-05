# Research Report: Task #83 — Comprehensive State Review

**Task**: Close Restricted Coherence Sorries
**Date**: 2026-04-04
**Mode**: Team Research (3 teammates)
**Session**: sess_1775426400_a83rev

## Summary

Three research teammates conducted a comprehensive review of the representation theorem, completeness pipeline, and publication readiness. The central finding is that **`completeness_over_Int` is NOT sorry-free** despite docstring claims — 4 sorries directly block it via DovetailedChain's forward_F/backward_P and the restricted truth lemma's Until/Since cases. Forward_F is genuinely unprovable for deterministic chains (confirmed by impossibility argument). The most actionable path forward is closing backward Until/Since coherence (HIGH confidence, 8-12 hours), while forward_F requires a fundamentally different chain construction.

## Key Findings

### 1. Sorry Inventory (Teammate A)

**Total**: ~76 sorry instances across the codebase.

**Critical path (blocking `completeness_over_Int`)**: 4 direct + 4 transitive = 8 sorries

| # | File | Line | Description | Type |
|---|------|------|-------------|------|
| 1 | DovetailedChain.lean | 1258 | `DovetailedFMCS_forward_F` | **DIRECT** |
| 2 | DovetailedChain.lean | 1266 | `DovetailedFMCS_backward_P` | **DIRECT** |
| 3 | CanonicalConstruction.lean | 940 | `restricted_shifted_truth_lemma` untl | **DIRECT** |
| 4 | CanonicalConstruction.lean | 943 | `restricted_shifted_truth_lemma` snce | **DIRECT** |
| 5 | DovetailedChain.lean | 621 | `forward_dovetailed_until_persists` | Transitive |
| 6 | DovetailedChain.lean | 989 | `backward_dovetailed_since_persists` | Transitive |
| 7 | DovetailedChain.lean | 1085 | `until_backward_to_zero` | Transitive |
| 8 | DovetailedChain.lean | 1098 | `since_forward_to_zero` | Transitive |

**Non-blocking breakdown**: 28 in Soundness, ~13 in Examples/Demo, 14 in deprecated Bundle path, 6 in DeterministicFMCS (alternate path), ~8 in Boneyard, others scattered.

### 2. DeterministicChain: ZERO SORRY (confirmed)

All proofs complete: `deterministic_chain_mcs`, `forward_G_int`, `backward_H_int`, Until/Since persistence. Relies on `x_content_mcs`, `y_content_mcs`, and axiom-derived temporal content properties.

### 3. DeterministicFMCS: 6 sorries (ALTERNATE PATH, not used by completeness_over_Int)

- 2 for forward_F/backward_P (lines 60, 66)
- 4 for Until/Since coherence in `usc` (lines 193-199)
- These are structurally identical to the DovetailedChain blockers

### 4. Forward_F is GENUINELY UNPROVABLE for Deterministic Chains (Teammate B)

**Impossibility argument**: The set `S = {F(A), neg(A), X(neg(A)), X(F(A)), X(X(neg(A))), X(X(F(A))), ...}` is finitely consistent. By compactness, S extends to an MCS. The deterministic chain from this MCS has `neg(A)` at every position, so A never appears — F(A) defers forever.

All 17+ prior research rounds confirm this from different angles. Three independent completeness paths (SuccChain, Dovetailed, Deterministic) all hit the same wall.

**What published proofs do differently** (Burgess 1984, GHR 1994, Goldblatt 1992, Reynolds 2003): They all build F-resolution INTO the chain construction, not prove it after the fact. The canonical model has all MCS as worlds; the challenge is arranging them into a linear chain while guaranteeing F-witnesses.

### 5. Backward Until/Since IS CLOSABLE (Teammate B — HIGH confidence 90%)

**Proof outline**: Backward induction from witness position using `until_intro` axiom + x_content linkage.

Given: `psi in chain(s)` and `phi in chain(r)` for all `t < r < s`. Prove: `(phi U psi) in chain(t)`.

- **Base (s-1)**: `psi in chain(s) = x_content(chain(s-1))` implies `X(psi) in chain(s-1)`. By `until_intro`: `(phi U psi) in chain(s-1)`.
- **Step (k+1 to k)**: IH gives `(phi U psi) in chain(k+1)`, guard gives `phi in chain(k+1)`. So `phi AND (phi U psi) in chain(k+1)`, hence `psi v (phi AND (phi U psi)) in chain(k+1)`. Via x_content: `X(psi v ...) in chain(k)`. By `until_intro`: `(phi U psi) in chain(k)`.
- **Terminal (t+1 to t)**: Same argument closes the last step.

The x_content linkage of the deterministic chain is exactly what makes this work. Backward_since is symmetric via `since_intro` + y_content.

**This would close 2 of the 4 until/since coherence sorries in DeterministicFMCS (and corresponding ones in DovetailedChain).**

### 6. Axiom Safety: CLEAN (Teammate C)

- Zero custom `axiom` declarations anywhere in the codebase
- Only standard Lean axioms: `propext`, `Classical.choice`, `Quot.sound`
- Proof system axioms correctly declared as constructors of inductive `Axiom` type
- All `sorry` instances are honest gaps, not disguised axioms

### 7. ParametricRepresentation.lean: NOT BROKEN (Teammate C)

Contrary to Report 17 concerns, the file is 303 lines, well-documented, with zero sorry. The `h_uc` parameter was correctly threaded through. The conditional representation theorem is fully proven — the gap is only in the callback implementations.

### 8. Representation Theorem Status (Teammate C)

Two representation theorems exist:
- **Algebraic**: `algebraic_representation_theorem` — SORRY-FREE, proves AlgSatisfiable <-> AlgConsistent
- **D-Parametric**: `parametric_algebraic_representation_conditional` — SORRY-FREE as stated, but conditional on a BFMCS construction callback. The callback implementations depend on sorry-bearing forward_F/backward_P.

### 9. Publication Readiness: 6/10 (Teammate C)

**Strengths**: Algebraic representation (sorry-free), soundness for 17 base axioms, decidability via FMP/tableau, deduction theorem, clean proof system design, ~61k lines across 134 files.

**Gaps**: Completeness has sorry, soundness has 28 sorry (Until/Since axioms), misleading "sorry-free" docstrings, dense completeness entirely blocked.

## Synthesis

### Conflicts Resolved

| Topic | Teammate A | Teammate B | Resolution |
|-------|-----------|-----------|------------|
| Which sorries block completeness? | 4 direct via DovetailedChain path | 6 in DeterministicFMCS | Both correct — A traces the actual `completeness_over_Int` dependency (Dovetailed path), B analyzes the alternate Deterministic path. The root cause is identical. |
| Total sorry count | 76 instances | Not counted | A's count is authoritative (exhaustive grep) |
| Is forward_F closable? | Root cause is Until/Since propagation | Genuinely unprovable (impossibility proof) | B is more precise — the impossibility is fundamental, not a proof engineering gap |

### Gaps Identified

1. **Soundness sorries (28)** were catalogued by A and C but not deeply analyzed. Until/Since axiom soundness is a separate concern that could invalidate completeness even if proven.
2. **Dense completeness** (`dense_completeness_fc`) is entirely blocked with no infrastructure — separate major effort.
3. **Misleading documentation** in FrameConditions/Completeness.lean needs correction regardless of approach.

### Recommendations

**Tier 1: Immediate (HIGH confidence, 8-12 hours)**
- Close backward Until/Since in DeterministicFMCS using the proof from Teammate B
- Fix misleading "sorry-free" docstrings in Completeness.lean
- Clean up dead code markers in RestrictedTruthLemma.lean

**Tier 2: Medium-term (MEDIUM confidence, 25-40 hours)**
- Build a modified chain with F-resolution built in (round-robin targeted Lindenbaum extension)
- OR implement GHR-style quasimodel approach (40-60 hours)
- Both would resolve ALL remaining completeness sorries

**Tier 3: Publication strategy (no code changes)**
- **Option A** (ready NOW): Publish as "Formalized Bimodal Logic Infrastructure" — soundness + decidability + algebraic representation, all sorry-free for base operators
- **Option B** (achievable): Publish as "Towards Completeness for TM Logic" — full architecture with admitted forward_F lemmas, honest framing
- **Option C** (long-term): Zero sorry — requires Tier 2 chain construction

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key Contribution |
|----------|-------|--------|------------|-----------------|
| A | Sorry audit + dependency chain | Completed | HIGH | Exhaustive 76-sorry inventory, precise dependency tracing |
| B | Mathematical approach assessment | Completed | MEDIUM | Forward_F impossibility proof, backward Until/Since closure path |
| C | Publication readiness + safety | Completed | HIGH | Axiom audit (clean), representation theorem status, publication options |

## Critical Action Items

1. **Fix docstrings**: `completeness_over_Int` claims "sorry-free" — this is false and must be corrected
2. **Close backward Until/Since**: Highest-value next step, proof outline available
3. **Decide publication strategy**: Option A or B is achievable now; Option C requires 25-60 additional hours
4. **Prioritize Until/Since soundness**: 14 axiom soundness sorries could invalidate the completeness theorem even if proven

## References

- Burgess, J. (1984). "Basic Tense Logic" — canonical frame approach
- Gabbay, D., Hodkinson, I., Reynolds, M. (1994). *Temporal Logic Vol. 1* — quasimodel construction
- Goldblatt, R. (1992). *Logics of Time and Computation* — existence lemma approach
- Reynolds, M. (2003). "Axiomatization of CTL" — tableau-based F-resolution
