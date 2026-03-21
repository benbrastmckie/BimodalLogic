# Research Report: Completeness Architecture - Base TM vs Dense/Discrete Extensions

**Task**: 8 - Establish genuine truth_at completeness theorems for TM logic
**Date**: 2026-03-20
**Mode**: Team Research (2 teammates)
**Session**: sess_1774063039_c87a2a

## Summary

Two teammates systematically analyzed whether base TM completeness makes sense vs focusing on dense/discrete extensions, examining the TaskFrame requirements and identifying the mathematically sound construction path. The investigation confirms that **all three completeness theorems are mathematically well-formed**, but **dense completeness is the most natural primary target** due to having a canonical domain (Rat via Cantor isomorphism). The key insight: the "trivial" CanonicalFMCS construction is legitimate Henkin technique; the gap is bridging it to TaskFrame D via the ParametricCanonicalTaskFrame infrastructure, which requires only modal_backward to complete.

## Key Findings

### 1. Base TM Completeness is Well-Formed (from Teammate A)

**The base TM completeness statement is mathematically meaningful.**

The `valid` predicate quantifies over ALL linearly ordered abelian groups (LOAGs) D with `[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]`. This matches the paper's definition (JPL paper, def:frame, line 1835) exactly.

**Important observation**: A formula CAN be valid over Int but not Rat (e.g., discreteness axiom DF), or valid over Rat but not Int (e.g., density axiom DN). Base TM completeness captures exactly the formulas valid in ALL LOAGs.

**The parametric representation theorem** (`parametric_algebraic_representation_conditional` in ParametricRepresentation.lean:255) correctly captures this: provide a `construct_bfmcs` for ANY specific D, and you get completeness over that D. Base TM completeness follows by instantiating with any convenient D.

### 2. Dense Completeness is the Most Natural Target (from Teammate B)

| Extension | Canonical D | Domain Characterization |
|-----------|-------------|------------------------|
| Base TM | None (any LOAG) | No axiom forces a specific D |
| Dense TM | `TimelineQuot ≃o Rat` | **Proven sorry-free** (CantorApplication.lean) |
| Discrete TM | `DiscreteTimelineQuot ≃o Int` | **Blocked by Task 974** |

Dense completeness has:
- A canonical domain (Rat via Cantor isomorphism) - proven sorry-free
- Complete proof structure (`TimelineQuotCompleteness.lean`) with **one central sorry**
- All typeclass verification done (`DenseInstantiation.lean`)

### 3. The Fundamental Blocker is Construction, Not Semantics (from both)

**Why IntBFMCS has sorries while CanonicalFMCS is sorry-free**:

Linear chain constructions (IntBFMCS) cannot preserve F-witnesses because Lindenbaum extensions can introduce G(~phi), killing F(phi) = ~G(~phi). This is **mathematically fundamental**, not a proof gap.

CanonicalFMCS uses ALL MCSes as domain, making F/P witnesses trivially exist:
```lean
theorem canonicalMCS_forward_F (w : CanonicalMCS) (phi : Formula)
    (h_F : Formula.some_future phi ∈ canonicalMCS_mcs w) :
    ∃ s : CanonicalMCS, w ≤ s ∧ phi ∈ canonicalMCS_mcs s := by
  obtain ⟨W, h_W_mcs, h_R, h_phi_W⟩ := canonical_forward_F w.world w.is_mcs phi h_F
  let s : CanonicalMCS := { world := W, is_mcs := h_W_mcs }
  exact ⟨s, CanonicalMCS.le_of_canonicalR w s h_R, h_phi_W⟩
```

The witness W is in the domain by construction (CanonicalMCS = all MCSes). No Lindenbaum extension needed.

### 4. The "Trivial" Construction is Legitimate (from both)

The CanonicalFMCS construction with `mcs(w) = w.world` (identity mapping) is **standard Henkin/Lindenbaum technique**, not a corner-cutting shortcut. From CanonicalFMCS.lean lines 19-30:

| Aspect | Standard FMCS | FMCS CanonicalMCS |
|--------|---------------|-------------------|
| Indexing Type | Int, Rat, TimelineQuot | CanonicalMCS |
| mcs Function | Maps time points to worlds | Identity: mcs(w) = w.world |
| F/P Witnesses | Must be constructed | Trivial (every MCS in domain) |
| Purpose | Semantic model | TruthLemma proof |

The document states: "This construction is **legitimate and necessary** for the completeness proof pipeline."

### 5. CanonicalMCS vs TaskFrame Mismatch is Architectural, Not Semantic (from Teammate A)

**The mismatch**:
- CanonicalMCS has Preorder only (CanonicalR; NOT total)
- TaskFrame D requires `[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]`

**Why CanonicalMCS cannot be D**:
- No `Add : CanonicalMCS → CanonicalMCS → CanonicalMCS`
- No group negation
- Ordering is NOT total (MCSes can be incomparable)

**The bridge (ParametricCanonicalTaskFrame)**:

The existing `ParametricCanonicalTaskFrame D` separates the roles:
- **World states** = MCSes (D-independent)
- **Duration type** = D (any LOAG)

The task relation uses the SIGN of duration d:
- d > 0: CanonicalR forward
- d = 0: identity
- d < 0: CanonicalR backward

**This is already sorry-free**. The gap is constructing `BFMCS D` (not `BFMCS CanonicalMCS`).

### 6. Convexity Problem is Solved by `domain = True` (from Teammate B)

Prior approaches (FlagBFMCSRatBundle) failed on WorldHistory convexity. The parametric infrastructure sidesteps this entirely:

From `ParametricHistory.lean` lines 63-64:
```lean
domain := fun _ => True
convex := fun _ _ _ _ _ _ _ => True.intro
```

Using `domain = True` (full domain) makes convexity trivially satisfied. This is the correct architectural choice.

### 7. Sorry Inventory for Dense Completeness (from Teammate B)

The entire dense completeness proof reduces to **two connected sorries**:

| Sorry | File:Line | Description |
|-------|-----------|-------------|
| `modal_backward` | IntFMCSTransfer.lean:134 | Singleton BFMCS cannot satisfy modal backward |
| `timelineQuot_not_valid_of_neg_consistent` | TimelineQuotCompleteness.lean:127 | Central gap - depends on modal_backward |

The `forward_F`/`backward_P` sorries in ClosureSaturation.lean are **bypassed** by using the CanonicalMCS → D transfer approach where F/P are trivially sorry-free.

## Synthesis

### Conflicts Found: 0

Both teammates reached complementary conclusions from different angles:
- Teammate A: Base TM is well-formed; FMP or ParametricCanonicalTaskFrame are viable paths
- Teammate B: Dense is most natural; ParametricCanonicalTaskFrame with CanonicalMCS transfer is the path

### Gaps Identified: 2

1. **Modal saturation construction**: The `SaturatedBFMCSConstruction.lean` machinery exists but its completeness for `modal_backward` was not fully verified
2. **Transfer implementation**: The CanonicalMCS → Rat transfer via ParametricHistory is architecturally clear but not yet implemented

### Recommended Strategy

**Phase 1**: Target dense completeness using existing infrastructure

The proof reduces to filling `timelineQuot_not_valid_of_neg_consistent` by:
1. Building `BFMCS Rat` (or `BFMCS TimelineQuot`) with temporal coherence (use CanonicalMCS construction, which is sorry-free)
2. Building modal coherence (use multi-family bundle from SaturatedBFMCSConstruction + ClosedFlagBundle)
3. Wiring to `ParametricCanonicalTaskFrame Rat` via `parametric_to_history` with `domain = True`

**Phase 2**: Base TM completeness follows automatically

Once dense completeness is proven, base TM completeness follows by observing that the same construction works for D = Int (Int is a LOAG). The `parametric_algebraic_representation_conditional` theorem is already D-polymorphic.

**Phase 3**: Discrete completeness (deferred)

Blocked by Task 974 (SuccOrder/PredOrder for DiscreteTimelineQuot). This is an independent obstruction requiring the `succ_le_of_lt` coverness lemma.

### Why NOT to Focus on Base TM First

1. Base TM has no canonical D - "any LOAG works" makes the construction arbitrary
2. Dense completeness has the same core difficulty (modal_backward) but with clearer structure
3. The Cantor isomorphism provides a concrete semantic target (TimelineQuot ≃o Rat)
4. Dense proof structure already exists with one central sorry

### On "Following TaskFrame Closely"

The user's concern about avoiding "trivial constructions" is addressed:

The CanonicalFMCS construction IS the correct TaskFrame-compliant approach when combined with ParametricCanonicalTaskFrame. The key insight:

1. TaskFrame D uses WorldState = MCS (not D)
2. Duration D indexes time (Int, Rat, etc.)
3. The task relation is defined by SIGN of duration (not by MCS ordering)
4. Histories map D → WorldState (not CanonicalMCS → CanonicalMCS)

This is NOT cutting corners - it's the correct separation of concerns. The "trivial" CanonicalMCS identity mapping happens at the BFMCS level (proof-theoretic), while the TaskFrame semantics use a proper D with group structure.

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key Finding |
|----------|-------|--------|------------|-------------|
| A | Base TM validity semantics, TaskFrame mismatch | Completed | High | Mismatch is architectural, not semantic; ParametricCanonicalTaskFrame solves it |
| B | Dense/discrete naturalness, construction survey | Completed | High | Dense is most natural target; one central sorry remains |

## References

### Codebase (Sorry-Free Infrastructure)
- `Theories/Bimodal/Metalogic/Bundle/CanonicalFMCS.lean` - forward_F, backward_P proven
- `Theories/Bimodal/Metalogic/Algebraic/ParametricRepresentation.lean` - Conditional completeness
- `Theories/Bimodal/Metalogic/Algebraic/ParametricCanonical.lean` - TaskFrame D construction
- `Theories/Bimodal/Metalogic/Algebraic/ParametricHistory.lean` - domain = True pattern
- `Theories/Bimodal/Metalogic/StagedConstruction/CantorApplication.lean` - TimelineQuot ≃o Rat

### Codebase (Sorries to Fill)
- `Theories/Bimodal/Metalogic/Bundle/IntFMCSTransfer.lean:134` - modal_backward
- `Theories/Bimodal/Metalogic/StagedConstruction/TimelineQuotCompleteness.lean:127` - Central gap
