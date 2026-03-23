# Research Report: Task #29 — MCS-Decided Atom Blocker Resolution

**Task**: 29 - switch_to_reflexive_gh_semantics
**Date**: 2026-03-22
**Mode**: Team Research (3 teammates)
**Session**: sess_1774430280_c4d5e6
**Supersedes**: Report 30 (blocker analysis)

## Summary

The MCS-decided atom blocker from plan v7 is **real and unfixable** within that approach. All three teammates converge on the same conclusion: the correct mathematical path is to **accept preorder structure** for the canonical frame and **separate concerns** between basic completeness (which needs no strict successors) and order-theoretic constructions (which may need a minimal axiom).

### Key Conclusions

1. **Derivation G(¬q) → G(¬G(q)) is VALID** (Teammate A, HIGH confidence) — confirmed by T-axiom structure in the codebase
2. **Per-construction strictness FAILS for seriality sites** (Teammate B, MEDIUM confidence) — ¬⊥ is a theorem in ALL MCS, so seriality witnesses are indistinguishable from source
3. **Preorder acceptance is viable** (Teammate C, HIGH confidence) — standard completeness for reflexive modal logics works with preorders; strict successors are NOT required
4. **Pathological MCS are reachable** but **irrelevant for basic completeness** (Teammates A+C)

## Detailed Findings

### 1. Derivation Validity (Teammate A)

The derivation G(¬q) → G(¬G(q)) is valid under reflexive semantics:

```
G(¬q)           — premise: always ¬q
  → ¬q          — T-axiom (Gφ → φ, reflexivity)
  → F(¬q)       — reflexivity of F: φ → Fφ (the present counts)
  → G(F(¬q))    — from G(¬q), at every time ¬q holds, so F(¬q) holds at every time
  = G(¬G(q))    — by definition: F = ¬G¬
```

This is confirmed by the axiom structure in `Axioms.lean` (lines 279-304, `temp_t_future`).

**Consequence**: For pathological MCS where G(¬q) ∈ M for all atoms q:
- G(¬G(q)) ∈ M for all q
- ¬G(q) ∈ g_content(M) for all q
- Adding G(q) to g_content(M) creates inconsistent seed for ALL atoms
- The MCS-decided atom pattern has NO consistent seed

### 2. Per-Construction Strictness Analysis (Teammate B)

**13 files, ~40 call sites** need strict successors. Categorized:

| Category | Sites | Per-Construction Works? |
|----------|-------|----------------------|
| Seriality (NoMaxOrder/NoMinOrder) | 6 | **NO** — ¬⊥ is in ALL MCS |
| Transfer (FMCSTransfer) | ~10 | Conditional |
| Transitivity closure | ~8 | Conditional |
| Dovetailing/staged | ~16 | Conditional |

**Why seriality fails**: Forward seed is `{¬⊥} ∪ g_content(M)`. Since ¬⊥ is a theorem in every MCS and g_content(M) ⊆ M (by T-axiom/reflexivity), NO seed formula distinguishes the Lindenbaum witness from M.

**Conclusion**: Per-construction strictness is NOT a universal solution. It cannot handle seriality-based sites.

### 3. Frame-Theoretic Analysis (Teammate C)

**The canonical frame under reflexive G/H is a reflexive transitive linear preorder.** This is analogous to S4.3 (S4 + linearity).

**Critical finding**: Standard completeness for reflexive modal logics works with preorders:
- Truth lemma handles reflexive cases via T-axiom
- Lindenbaum witnesses handle non-reflexive cases
- No strict M ≠ M' requirement for basic completeness

**Seriality interpretation**: Under reflexive G, the operator F = ¬G¬ is also reflexive. The seriality axiom Gφ → Fφ becomes trivially valid (follows from T-axiom: Gφ → φ → Fφ). This means:
- NoMaxOrder/NoMinOrder for the STRICT order may not be needed
- The reflexive frame is already serial (every point reaches itself)

### Separation of Concerns

| Concern | Strict Successors Needed? | Solution |
|---------|--------------------------|----------|
| Basic completeness | **NO** | Preorder structure sufficient |
| Truth lemma | **NO** | Reflexivity + Lindenbaum |
| Seriality axiom soundness | **NO** | Trivially valid under reflexive F |
| Cantor isomorphism | **YES** | Requires NoMaxOrder/NoMinOrder |
| Dovetailed timeline | **YES** | Requires strict interleaving |
| Discrete successor | **YES** | Requires SuccOrder structure |

## Synthesis: Conflicts and Resolution

### Conflict 1: Is an axiom needed?

- **Teammate B**: Suggests accepting axiom for NoMaxOrder/NoMinOrder
- **Teammate C**: Says axiom unnecessary for basic completeness

**Resolution**: Both are correct at different levels. Basic completeness needs NO axiom. Order-theoretic constructions (Cantor, dovetailing) DO need strict successors. The question is whether those constructions are essential.

### Conflict 2: Per-construction vs. preorder

- **Teammate B**: Per-construction works for some sites
- **Teammate C**: Preorder acceptance eliminates the need entirely

**Resolution**: These are complementary. The preorder approach removes the NEED for strict successors in basic completeness. The few constructions that still need them (Cantor, discrete) can use construction-specific arguments or a targeted axiom.

### Gaps Identified

1. **Cantor isomorphism dependency**: Does the completeness pipeline ACTUALLY use Cantor? Or is Cantor a separate result?
2. **Dovetailed timeline role**: Is dovetailing needed for completeness, or is it an optimization?
3. **F/P interpretation**: The codebase may have inconsistency between strict and reflexive F/P — needs audit

## Recommended Approach (Plan v8)

### Architecture: Two-Layer Solution

**Layer 1: Basic Completeness (no axiom needed)**
1. Accept CanonicalR as a reflexive preorder
2. Remove NoMaxOrder/NoMinOrder requirements from basic completeness path
3. Seriality is trivially valid under reflexive F
4. Truth lemma + Lindenbaum + reflexivity = completeness

**Layer 2: Order-Theoretic Enhancements (optional, may need axiom)**
1. For Cantor isomorphism: Add minimal axiom `∀M. ∃p:Atom. G(¬p) ∉ M` (excludes pathological MCS)
2. For discrete successor: Construction-specific argument (DF/SF axiom provides witness)
3. For dovetailed timeline: Assess whether needed at all

### Implementation Strategy

1. **Phase 5A-ter**: Refactor completeness to not require strict successors
   - Remove NoMaxOrder/NoMinOrder from completeness pipeline
   - Verify truth lemma works with preorder
   - Seriality via reflexivity

2. **Phase 5B-alt**: Isolate order-theoretic constructions
   - Identify which constructions genuinely need strict successors
   - Add minimal axiom ONLY for those constructions
   - Or defer those constructions to future work

3. **Phase 6-8**: Proceed as in plan v7 (delete old axiom, update docs, T-axiom proofs)

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | Derivation verification & reachability | completed | medium-high |
| B | Per-construction strictness | completed | medium |
| C | Frame theory & axioms | completed | high |

## References

### Codebase
- `Theories/Bimodal/Metalogic/Axioms/Axioms.lean` — T-axiom (temp_t_future)
- `Theories/Bimodal/Metalogic/Canonical/CanonicalFrame.lean` — CanonicalR definition
- `Theories/Bimodal/Metalogic/Canonical/CanonicalSerialFrameInstance.lean` — NoMaxOrder/NoMinOrder
- `Theories/Bimodal/Metalogic/Bundle/CanonicalIrreflexivity.lean` — strict successor infrastructure
- `Theories/Bimodal/Metalogic/StagedConstruction/CantorApplication.lean` — Cantor isomorphism
- `Theories/Bimodal/Metalogic/StagedConstruction/DovetailedTimelineQuot.lean` — dovetailing

### Literature
- Standard completeness for S4/KT4 uses preorder canonical frames
- S4.3 = S4 + linearity (analogous to our reflexive TM)
