# Research Report: Task #107

**Task**: Chain design diagnostics for representation theorem
**Date**: 2026-04-23
**Mode**: Team Research (4 teammates)
**Session**: sess_1776982947_8aac3b
**Round**: 6 (Semantic/axiom design options)

## Summary

Four teammates investigated what axiom and semantic changes would enable a representation theorem, given the user's preference for irreflexive (strict) G/H and the constraint that TaskFrame must not change. The findings reveal a **fundamental design decision** with two viable paths and one clear quick-win entry point.

**Critical findings**:
1. **A3a and A4a are NOT derivable from BX under reflexive semantics** (Teammate C, concrete counterexample: A3a requires r at intermediate points that reflexive Until does not guarantee)
2. **Switching G/H to strict requires only 4 lines changed in Truth.lean** (`<=` to `<`), but invalidates 3 axiom pairs (BX1, BX8, BX9) affecting ~105 usage sites and ~8,000 lines of sorry-free code (Teammate A, C)
3. **A Box+G+H-only representation theorem is dramatically simpler** — zero sorry sites arise from Box/G/H alone; all 5 sorries are Until/Since-specific (Teammate B)
4. **The project previously had strict semantics and switched to reflexive** for axiom-system reasons; if Burgess's axioms are adopted, the original reason for the switch disappears (Teammate D)
5. **temp_4 (G→GG) is NOT valid on discrete strict orders** — only on dense orders, consistent with Burgess working over Q (Teammate A)

## Key Findings

### 1. The Strict Semantic Change (Teammate A, HIGH confidence)

Switching to strict G/H requires:
```lean
-- Current (reflexive)
| Formula.all_future φ => ∀ (s : D), t ≤ s → truth_at M Omega τ s φ
| Formula.untl φ ψ => ∃ s : D, t ≤ s ∧ ...

-- Proposed (strict)
| Formula.all_future φ => ∀ (s : D), t < s → truth_at M Omega τ s φ
| Formula.untl φ ψ => ∃ s : D, t < s ∧ ...
```

**Axioms that become INVALID**: BX1/BX1' (G(phi)→phi), BX8/BX8' (psi→phi U psi), BX9/BX9' (phi U psi → phi ∨ psi) — 6 constructors total.

**Axioms that REMAIN VALID**: All other 31 axioms, critically including BX4 (phi→G(P(phi))), BX5, BX6, BX7, BX10, BX11, BX12, temp_4, and all modal axioms.

### 2. Box+G+H Fragment Is Dramatically Simpler (Teammate B, HIGH confidence)

A representation theorem for just Box+G+H (no Until/Since) under strict semantics:
- Uses standard S5 + Kt.4 completeness (17 axioms, down from 37)
- Needs only Verbrugge's Theorem 1 construction (step-by-step point insertion)
- Has **zero sorry sites** — all 5 current sorries arise from Until/Since coherence
- No chronicles, no interval functions, no BX11 fold needed
- Estimated **8-15 hours** for a sorry-free theorem

This provides a **quick-win entry point** that validates the semantic change before tackling Until/Since.

### 3. A3a/A4a Gate is Definitively Closed (Teammate C, HIGH confidence)

**A3a is NOT semantically valid under reflexive Until**. Counterexample:
- p = true always, q = true always, r only at s = 5, t = 0
- p ∧ U(q,r) holds at t=0 (witness s=5, guard vacuous since q=true)
- But U(q ∧ S(p,r), r) fails at t=0 because at u=3: S(p,r) requires a Since witness v≤3 with r(v), but r only holds at s=5 > 3

This definitively closes the "derive A3a/A4a" approach for the reflexive system.

### 4. The Central Tradeoff (Teammates C vs D)

| Criterion | Stay Reflexive (BX-native chronicle) | Switch Strict (Burgess direct) |
|-----------|--------------------------------------|-------------------------------|
| Sorry-free code at risk | 0 lines | ~8,000 lines |
| Axioms dropped | 0 | 6 (BX1/BX8/BX9 + mirrors) |
| Axioms added | 0 | 2 (A3a, A4a) |
| Net axiom count | 37 | 33 |
| Proof technique | Novel BX-native chronicle (unpublished) | Direct Burgess 1982 (peer-reviewed 44 years) |
| Matches user preference | No (reflexive) | Yes (strict, more expressive) |
| Gate risk | None (A3a/A4a bypassed) | None (A3a/A4a become axioms) |
| Estimated total effort | 90-130 hours | 88-130 hours (after 20-30h semantic rework) |
| Mathematical confidence | 70% (novel proof design) | 90% (known construction) |

**Teammate C argues**: The rework cost of switching to strict is 177-264 hours additional, making the total 280-420 hours — 3x the reflexive path.

**Teammate D argues**: Most of the "rework" is REPLACEMENT, not adaptation. The Burgess construction replaces RootScopedChain.lean (1,681 lines) entirely. Soundness re-proof is mechanical (remove 3 cases, add 2). The sorry-free Quasimodel infrastructure becomes unnecessary under Burgess.

**Resolution**: D's argument is stronger for the representation theorem specifically. The 177-264h estimate counts line-by-line adaptation of ALL infrastructure, but much of it (Quasimodel, Filtration, existing chain construction) would be REPLACED, not adapted. However, C's point about preserving the sorry-free Decidability/FMP infrastructure (which does NOT need the representation theorem) is valid — that module should be preserved even if its axioms change.

## Synthesis

### Recommended Path: Phased Strict Adoption

Given the user's explicit preference for strict G/H and the goal of "simplest representation first":

**Phase 0: Box+G+H Fragment (8-15 hours)**
- Change Truth.lean G/H to strict (2 lines)
- Create a new `StrictCompleteness.lean` proving Box+G+H representation
- Standard S5+Kt.4 completeness — no chronicles needed
- Delivers a sorry-free theorem quickly
- Validates the semantic change before committing further

**Phase 1: Semantic and Axiom Transition (20-30 hours)**
- Change Until/Since in Truth.lean to strict (2 more lines)
- Remove BX1/BX1', BX8/BX8', BX9/BX9' from Axioms.lean
- Add A3a (Until-Since connectedness) and A4a (Until decomposition) as axioms
- Fix soundness proof (remove 6 cases, add 2 new soundness lemmas)
- Fix exhaustive pattern matches (~30 files)
- Archive affected sorry-free code to Boneyard if needed

**Phase 2: Burgess Chronicle Construction (60-90 hours)**
- Define chronicle type over Q
- Implement Lemmas 2.2-2.10 (now directly applicable — same axiom system as Burgess)
- Counterexample elimination for C4a/C5a
- Omega-union and truth claim

**Phase 3: Integration (15-20 hours)**
- BFMCS wrapper from chronicle
- Replace dd_countermodel with chronicle-based construction
- Close all 5 sorry sites
- `lake build` verification

**Total: 103-155 hours, 85-90% confidence**

### Alternative: Stay Reflexive, BX-Native Chronicle (90-130 hours)

If the user decides the semantic change is too disruptive:
- Keep all 37 BX axioms unchanged
- Design a novel chronicle construction using BX4+BX5+BX7+BX10 directly
- This is an unpublished proof design (70% confidence)
- Does NOT deliver the user's preferred strict semantics

### NOT Recommended
- **Dual operator system** (Path 4): Over-engineered, adds Formula constructors, 150+ hours
- **Derive A3a/A4a under reflexive** (Path 2 gate): Definitively closed by counterexample

## Teammate Contributions

| Teammate | Angle | Status | Key Contribution | Confidence |
|----------|-------|--------|------------------|------------|
| A | Strict G/H design | completed | Exact semantic changes; axiom validity analysis; temp_4 density dependency | high |
| B | Box+G+H minimal | completed | Box+G+H fragment is zero-sorry; standard S5+Kt.4 proof; 8-15h quick win | high |
| C | Impact analysis | completed | A3a counterexample; 8000+ lines at risk; BX-native chronicle alternative (90-130h) | high |
| D | Strategic path | completed | Path 3 recommended; phased delivery; historical context (project had strict before) | high |

## References

- Burgess 1982: Strict Until/Since axiom system (A1a-A7a)
- Verbrugge 2004: Step-by-step Lin completeness (Theorem 1) — directly applicable to Box+G+H
- Round 5 synthesis: `specs/107_.../reports/05_team-research.md`
