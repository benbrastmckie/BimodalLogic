# Research Report: Task #93

**Task**: Complete BXCanonical embedding — Serial axiom analysis
**Date**: 2026-04-20
**Mode**: Team Research (4 teammates)
**Session**: sess_1776704199_a70774

## Summary

The 2 sorry sites in `serial_future_axiom_valid` and `serial_past_axiom_valid` are fixable by adding `[Nontrivial D]` to the `valid` definition. The serial axioms (BX1/BX1') MUST NOT be removed — they are essential for completeness. The fix is minimal (1-2 lines in Validity.lean + closing the proofs with `exists_gt`/`exists_lt`). However, the team also identified a deeper structural problem: `g_content_subset_self` (requiring the removed T-axiom `G(φ)→φ`) remains the true blocker for completeness, and is orthogonal to the seriality fix.

## Key Findings

### Primary Approach: Add [Nontrivial D] to valid (from Teammates B & D)

**The diagnosis is unanimous and mathematically unambiguous:**

1. `valid` currently quantifies over ALL `LinearOrderedAddCommGroup D`, including trivial one-element groups where `F(⊤)` is literally false (no strict successor exists)
2. `valid_dense` and `valid_discrete` already include `[Nontrivial D]` — the base `valid` is inconsistently weaker
3. In a `LinearOrderedAddCommGroup D`, `Nontrivial D` implies `NoMaxOrder D` and `NoMinOrder D` (Mathlib)
4. The canonical model uses `D = Int`, which is nontrivial — completeness is unaffected
5. The proofs close trivially with `exists_gt`/`exists_lt` once the constraint is added

**Concrete fix:**
```lean
-- Validity.lean: add [Nontrivial D]
def valid (φ : Formula) : Prop :=
  ∀ (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D]
    (F : TaskFrame D) (M : TaskModel F) ...

-- Also update semantic_consequence for consistency
```

**Cascade analysis (Teammate B):**
- `semantic_consequence` must also gain `[Nontrivial D]`
- `dd_countermodel` return type needs `Nontrivial D` in its existential
- `soundness` theorem signature needs the added constraint
- SoundnessLemmas.lean: 4 additional sorry sites (lines 529-536, 1022-1029, 1424-1431, 1655-1659) become closeable
- **Total: 6 sorry sites directly closeable from this one structural change**
- No existing sorry-free proofs break (all use Int, Rat, or Real which are nontrivial)

### Serial Axioms Are Essential (from Teammate A)

The seriality axioms (`⊤→F(⊤)` and `⊤→P(⊤)`) are used in `g_content_set_consistent` and `h_content_set_consistent` (Frame.lean lines 148-195). These prove that g_content of any set is consistent — the foundation for the entire canonical model construction. Removing seriality would break the only working parts of the consistency infrastructure.

### The Deeper Problem: g_content_subset_self (from Teammate C — CRITICAL)

The Critic identified a problem that is more fundamental than the seriality sorries:

- `g_content_subset_self` (i.e., `G(φ) ∈ M → φ ∈ M` for MCS) requires the temporal T-axiom `G(φ)→φ`
- This axiom was REMOVED when switching to irreflexive semantics (correctly — it's unsound under strict G)
- `bx_le_refl` is sorried and structurally FALSE for the same reason
- The chain construction's base case (`fwd_chain_g_content_trans`) depends on this
- Two repair paths exist:
  1. Add `G(φ)→φ` back (requires switching to reflexive G semantics — contradicts the irreflexive switch)
  2. Redesign canonical model to not need bx_le reflexivity (stays with irreflexive semantics but requires fundamental architecture change)

**This is ORTHOGONAL to the seriality sorry fix.** Fixing the Nontrivial issue closes the soundness sorries but does NOT address the completeness chain construction blockers.

### Build Failures in OracleStep.lean (from Teammate A)

`OracleStep.lean` (lines 76, 141) references `Axiom.temp_t_future` and `Axiom.temp_t_past` — constructors that NO LONGER EXIST after the irreflexive switch. These cause actual compilation failures (`Unknown constant` errors).

## Synthesis

### Conflicts Resolved

| Conflict | Teammate B | Teammate D | Resolution |
|----------|-----------|-----------|------------|
| Constraint choice | `[NoMaxOrder D] [NoMinOrder D]` directly | `[Nontrivial D]` | Use `[Nontrivial D]` — simpler (1 constraint), aligns with existing valid_dense/valid_discrete, and Mathlib provides the implication automatically |

### Gaps Identified

1. **OracleStep.lean build failures**: These are blocking but unrelated to the seriality fix. They need `Axiom.temp_t_future`/`Axiom.temp_t_past` replaced or the file restructured.
2. **g_content_subset_self**: The deep blocker for completeness. Requires either reflexive G semantics or a canonical model redesign. This is the hard open problem (documented across 50+ prior research rounds).
3. **until_backward_refl_mcs**: Under irreflexive Until semantics, `ψ → φ U ψ` is genuinely unprovable (no reflexive witness). This is a semantic incompatibility, not a proof gap.

### Recommendations

**Immediate action (Phase 3 completion):**
1. Add `[Nontrivial D]` to `valid` and `semantic_consequence` in Validity.lean
2. Close `serial_future_axiom_valid` and `serial_past_axiom_valid` using `exists_gt`/`exists_lt`
3. Update `dd_countermodel` return type to include `Nontrivial D`
4. Close the 4 SoundnessLemmas.lean serial sorry sites
5. Fix OracleStep.lean build failures (replace references to deleted axiom constructors with `sorry` or delete the file if it's on the dead Quasimodel path)

**DO NOT:**
- Remove BX1/BX1' seriality axioms (they are needed for g_content_set_consistent)
- Add `G(φ)→φ` as an axiom (would require switching back to reflexive semantics)
- Attempt to close g_content_subset_self without a full architectural decision

**Future work (separate task):**
- The reflexive-vs-irreflexive G semantics decision is the true fork point
- If irreflexive is maintained: canonical model must be redesigned without bx_le reflexivity
- If reflexive is preferred: add temporal T-axiom, fix soundness, simplify completeness

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | Serial axiom usage in completeness | completed | high (95%) |
| B | Nontrivial cascading impact | completed | high (85%) |
| C | Risks of removing serial axioms | completed | high |
| D | Strategic direction / literature | completed | very high (95%) |

## References

- Burgess, J. (1984). "Basic Tense Logic" — seriality derivable under reflexive G, must be axiomatized under irreflexive G
- Goldblatt, R. (1992). "Logics of Time and Computation" — serial frames = every point has successor/predecessor
- Mathlib: `LinearOrderedAddCommGroup.noMaxOrder` — Nontrivial implies NoMaxOrder
- Mathlib: `exists_gt` — provides strict successor witness given NoMaxOrder
