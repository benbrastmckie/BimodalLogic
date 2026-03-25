# Research Report: Task #63 — Round 2

**Task**: Prove Box backward via BFMCS modal saturation and eliminate singleton-Omega dead end
**Date**: 2026-03-24
**Mode**: Team Research (2 teammates, Opus)
**Session**: sess_1774416945_bbe82c
**Focus**: Full sorry-free completeness — modal and temporal unification with algebraic perspective

## Summary

A full sorry-free completeness theorem for TM (Tense + Modality = S5 + linear temporal logic) requires solving two structurally independent problems: **modal coherence** (Box/Diamond) and **temporal coherence** (G/H/F/P). The modal direction is **fully solved** via `boxClassFamilies_modal_backward`. The temporal direction is **fundamentally different** from the modal direction due to an algebraic distinction: Box is an S5 operator with negative introspection, while G/H are S4-like operators without it. This distinction is not a proof gap but a **mathematical reality** — the proof techniques must differ, and no algebraic unification can collapse them.

The recommended path forward is the **per-obligation witness architecture** for temporal coherence, combined with the existing BFMCS modal saturation.

## Key Findings

### The Algebraic Root Cause (from Teammate B)

The fundamental difference between modal and temporal completeness:

| Property | Box (S5) | G/H (S4-like) |
|----------|----------|----------------|
| Negative introspection | `neg(Box(a)) → Box(neg(Box(a)))` | **None** |
| Theory includes negatives | `box_theory` has ± elements | `G_theory` is positive only |
| R-relation type | Equivalence (symmetric) | Preorder (asymmetric) |
| Witness existence | Algebraic saturation | Iterative construction |
| Persistence along FMCS | Constant (`parametric_box_persistent`) | Shifts forward in time |

**S5 negative introspection** is what enables `box_theory_witness_consistent`: the box_theory includes both `Box(phi) ∈ M` and `neg(Box(phi)) when Box(phi) ∉ M`, giving complete information about box-content. The G_theory can only include positive G-formulas, so temporal witnesses must be constructed iteratively rather than by saturation.

This is not a deficiency of the current approach — it reflects a **genuine logical distinction**. Attempting to find a unified algebraic solution would require canonical extensions or forcing, which are significantly more complex and may not align with Lean 4's foundations.

### Truth Lemma Dependency Structure (from Teammate A)

The truth lemma proves `phi ∈ MCS t ↔ truth_at M t phi` by structural induction. Each operator contributes:

| Operator | Forward (MCS → truth) | Backward (truth → MCS) | Dependency |
|----------|----------------------|------------------------|------------|
| `atom p` | valuation = membership | valuation = membership | None |
| `bot` | MCS consistency | Vacuous | None |
| `psi → chi` | MCS closure | Backward IH on psi, forward IH on chi | Requires biconditional IH |
| `Box psi` | `modal_forward` | `modal_backward` (S5 witness) | **SOLVED** |
| `G psi` | `forward_G` (G(phi) + t ≤ s → phi at s) | `temporal_backward_G` | Requires `forward_F` |
| `H psi` | `backward_H` (H(phi) + s ≤ t → phi at s) | `temporal_backward_H` | Requires `backward_P` |

The Imp backward case requires the backward IH on subformulas — this is why the induction must provide the full biconditional at each step, and why both modal and temporal backward directions are needed for full completeness.

### Why Deterministic SuccChain Fails (from both teammates)

The `f_nesting_is_bounded` lemma is **mathematically false**:

**Counterexample**: `{F^n(p) | n ∈ ℕ}` is finitely consistent (each finite subset is satisfiable on ℤ) and extends to an MCS with unbounded F-nesting by compactness.

A deterministic successor function commits to a specific extension at each step and may perpetually defer F-obligations. The issue is not the existence of satisfying models but the constructibility via a deterministic process.

### Modal-Temporal Structural Independence (synthesis)

Both teammates independently confirmed the **structural independence**:
- Modal operators quantify over **families** at the **same time**
- Temporal operators quantify over **times** in the **same family**

This separation means we can (and must) solve them independently:
- **Modal**: boxClassFamilies saturation (DONE, sorry-free)
- **Temporal**: per-obligation witness iteration (TODO)

The only interaction is `temp_future: Box(phi) → G(Box(phi))`, which makes Box-content time-invariant. This interaction is already handled by `parametric_box_persistent`.

## Three Architectures for Temporal Coherence

### Option A: Per-Obligation Witness Architecture (RECOMMENDED)

**Construction**: Instead of one chain satisfying all F-obligations, build many chains each satisfying one obligation. The canonical model is their union.

**Why it works**: `temporal_theory_witness_exists` (UltrafilterChain.lean:1153-1186) already provides per-obligation witnesses — given F(phi) ∈ M, it produces W with phi ∈ W and same G-theory (forward direction) and box-class.

**Status**: Partially implemented in `CanonicalFrame.lean`. Needs completion.

**Algebraic interpretation**: This is a directed colimit in the category of MCS extensions (Teammate B's categorical analysis).

### Option B: Ultrafilter Chain Extension

**Construction**: Work at the Lindenbaum algebra level. Use R_G chains of ultrafilters. Extend partial chains to maximal chains via Zorn's lemma.

**Why it works**: Ultrafilters have automatic negation completeness, and the algebraic structure provides the necessary witnesses.

**Status**: R_G and R_Box defined with basic properties (UltrafilterChain.lean:52-226), but chain extension not completed.

**Risk**: Converting between ultrafilter-level and MCS-level proofs adds complexity.

### Option C: Fair-Scheduling Chain Construction

**Construction**: Modify the successor function to fairly schedule F-obligations with smallest-index-first priority.

**Risk**: Still requires boundedness reasoning or omega-indexed chains. Most fragile of the three approaches.

## Synthesis

### Conflicts Resolved

None — teammates are fully complementary. Teammate A analyzed the logical structure (what completeness requires), Teammate B analyzed the algebraic structure (why modal works and temporal doesn't).

### Gaps Identified

1. **CanonicalFrame.lean completion**: The per-obligation architecture is sketched but not wired
2. **restricted_forward_chain_iter_F_witness repair**: Build blocker in SuccChainFMCS.lean:2215
3. **Integration**: How to compose modal saturation with temporal per-obligation witnesses into one BFMCS

### Recommendations

**For Task 63 (immediate scope)**:
1. Fix the SuccChainFMCS.lean build blocker
2. Create `bfmcs_from_mcs` with sorry-free modal coherence
3. Wire completeness through `parametric_canonical_truth_lemma`
4. Accept temporal sorry for now — document as separate task
5. Update ROADMAP.md with algebraic explanation of modal vs temporal distinction

**For full sorry-free completeness (follow-up tasks)**:
1. Complete CanonicalFrame.lean per-obligation witness architecture
2. Prove temporal coherence from per-obligation structure
3. Wire into BFMCS construction
4. Remove deprecated `construct_bfmcs` and `boxClassFamilies_temporally_coherent`

### Effort Assessment

| Phase | Scope | Effort |
|-------|-------|--------|
| Task 63 | Modal completeness + documentation | 4-6 hours |
| Follow-up | Temporal per-obligation architecture | 8-16 hours |
| Follow-up | Full sorry-free completeness | 4-8 hours (wiring) |

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key Insight |
|----------|-------|--------|------------|-------------|
| A | Modal-temporal unification | completed | high | Per-obligation architecture; structural independence |
| B | Algebraic perspective | completed | high | S5 negative introspection is WHY modal works; S4 is WHY temporal is different |

## References

- `UltrafilterChain.lean:1678-1782` — `boxClassFamilies_modal_backward` (proven, sorry-free)
- `UltrafilterChain.lean:1153-1186` — `temporal_theory_witness_exists` (proven, sorry-free)
- `UltrafilterChain.lean:794-899` — `box_theory_witness_consistent` (the S5 negative introspection proof)
- `TenseS5Algebra.lean` — STSA axioms showing S5 vs S4 distinction
- `TemporalCoherence.lean:165-178` — `temporal_backward_G` (requires forward_F)
- `ParametricTruthLemma.lean:170-310` — Truth lemma with all operator cases
- `CanonicalFrame.lean:19-25` — Per-obligation architecture sketch
- `SuccChainFMCS.lean:39-59` — Documentation of f_nesting_is_bounded failure
