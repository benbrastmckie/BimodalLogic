# Research Report: Task #77 — Critical Re-Analysis of D vs WorldState

**Task**: Research PreorderTaskFrame generalization
**Date**: 2026-03-31
**Mode**: Team Research (2 teammates, critical re-analysis)
**Session**: sess_1774981057_4f33e9
**Corrects**: Reports 01 and 02 (category error: D ≠ CanonicalMCS)

## Summary

The user identified a **fundamental category error** in prior research: the proposal "D = CanonicalMCS" conflates temporal durations (D) with world states (CanonicalMCS). These are categorically distinct components of Task Semantics. With this correction applied, the analysis reveals that:

1. **Partial order D creates multi-dimensional time** — not branching time in the CTL sense, but histories that span 2D (or higher) convex regions
2. **This is semantically exotic** — G(φ) becomes "φ in the entire future cone", fundamentally different from any standard temporal logic
3. **The F/P witness blocker is independent of linearity** — it arises from omega-saturation in canonical construction, not from the order structure on D
4. **No straightforward weaker logic avoids the blocker** — weakening D to a preorder doesn't help and creates new problems

## Critical Correction: D ≠ CanonicalMCS

### The Error in Reports 01 and 02

Prior reports stated: "Canonical model: D = CanonicalMCS with preorder = CanonicalR"

This is **mathematically incoherent** because:

| Property | D (durations) | CanonicalMCS (world states) |
|----------|---------------|----------------------------|
| Semantic role | "How long" tasks take | "What is true" in the world |
| Algebraic structure | AddCommGroup (0, +, -) | No group structure |
| Order structure | LinearOrder or Preorder | CanonicalR (g_content inclusion) |
| In TaskFrame | Parameter type | WorldState type |
| In WorldHistory | Domain of the function | Codomain of the function |

**CanonicalMCS has no group structure**: You cannot add two maximal consistent sets, there is no "zero" MCS, and negation of an MCS is meaningless.

### Correct Component Roles

```
TaskFrame D where
  D          : Type*          -- DURATIONS (ordered abelian group: Int, Rat, etc.)
  WorldState : Type           -- WORLD STATES (MCS in canonical model)
  task_rel   : W → D → W → Prop  -- "from state w, after duration d, reach state u"

WorldHistory F where
  domain       : D → Prop     -- convex subset of DURATIONS
  states       : D → WorldState  -- function from times to WORLD STATES
  respects_task: ...           -- coherence with task relation
```

## What Partial Order D Actually Means

### Geometric Structure (Both Teammates Agree)

If D is a partially ordered additive group (e.g., Z × Z with product order):
- There exist incomparable times: (1,0) and (0,1) are incomparable
- **Convex domains become 2D regions**, not intervals
  - If domain contains (0,0) and (2,2), convexity forces the entire rectangle {(a,b) : 0 ≤ a ≤ 2, 0 ≤ b ≤ 2}
- **This is NOT branching time** (CTL-style) — it's multi-dimensional time
- A single history maps an entire 2D region to world states

### Impact on Operators

| Operator | Linear D | Partial Order D |
|----------|----------|-----------------|
| G(φ) at t | φ at all s ≥ t (a ray) | φ at all s ≥ t (a future CONE) |
| H(φ) at t | φ at all s ≤ t (a ray) | φ at all s ≤ t (a past CONE) |
| F(φ) at t | ∃s ≥ t with φ at s (point on ray) | ∃s ≥ t with φ at s (point in cone) |
| □(φ) at t | φ at all histories at t | φ at all histories at t (unchanged) |

**G and H become multi-dimensional quantifiers.** This is semantically coherent but represents a fundamentally different temporal logic, not a natural weakening of TM.

### Tree-Shaped Histories (Teammate A Analysis)

Consider D = {0, 1a, 1b} with 0 ≤ 1a, 0 ≤ 1b, 1a ∥ 1b:

A history τ with domain = {0, 1a, 1b} assigns:
- τ(0) = w₀, τ(1a) = w₁, τ(1b) = w₂
- respects_task requires: task_rel(w₀, 1a, w₁) and task_rel(w₀, 1b, w₂)
- **No constraint between w₁ and w₂** (incomparable times)

So histories CAN fork — a single history assigns states to multiple incomparable "future branches" simultaneously. This is geometrically unlike anything in standard temporal or modal logic.

## Axiom Analysis Under Partial Order D

| Axiom | Requires Linearity? | Analysis |
|-------|--------------------|----|
| temp_linearity | **YES** | Encodes trichotomy of future witnesses |
| MF: □φ → □Gφ | No | Uses time-shift + ShiftClosed, works with AddCommGroup |
| TF: □φ → G□φ | No | Same reasoning as MF |
| temp_4: Gφ → GGφ | No | Only needs transitivity of ≤ |
| temp_t: Gφ → φ | No | Only needs reflexivity |
| temp_a: φ → GP(φ) | No | t < s implies t witnesses P |
| Temporal K | No | Standard distribution, any monotone operator |
| S5 axioms | No | Independent of temporal order |

**Only temp_linearity explicitly requires totality of the ordering.**

## The F/P Witness Blocker: Independent of Linearity

### Why Weakening D Doesn't Help (Teammate B Key Finding)

The F/P blocker arises from:
1. An MCS can contain infinitely many F-obligations (via closure under G)
2. All obligations must be satisfied within a SINGLE coherent timeline
3. No finite construction can accommodate unbounded future witnesses

**This is a structural problem with the canonical model construction, NOT a property of the order on D:**

- With linear D: witnesses must fit on a line → hard (the known blocker)
- With preorder D, chain-restricted histories: witnesses must fit on a chain → equally hard
- With preorder D, 2D histories: witnesses must fit in a 2D region → DIFFERENT problem but not clearly easier, and the canonical MCS construction gives points, not regions

### Teammate B's Chain Restriction Insight

If we restrict world histories to have **chain-shaped domains** (totally ordered subsets of D):
- Convexity is well-defined as usual
- G/H quantify over linear future/past within each chain
- Different histories can be on different chains (branches)
- This recovers sensible semantics

**But** the F/P blocker still applies within each chain. The preorder structure of D provides no advantage.

## Synthesis: Conflicts Resolved

### Conflict 1: Is BTM Viable?

- **Teammate A**: PreorderTaskFrame is mathematically coherent; BTM could work with careful construction
- **Teammate B**: "BTM as previously proposed is incoherent" and doesn't solve the completeness problem

**Resolution**: Both are correct at different levels:
- A PreorderTaskFrame structure IS mathematically well-defined
- But the semantics it creates (multi-dimensional time) is NOT a natural weakening of TM
- And the F/P blocker persists regardless of D's order structure

### Conflict 2: Chain Restriction vs 2D Time

- **Teammate A**: Explores both chain-restricted and 2D time approaches
- **Teammate B**: Recommends chain restriction if preorder is desired, rejects 2D time as too exotic

**Resolution**: Chain restriction is the only sensible option if we want a logic that "feels like" temporal logic. But it doesn't provide any advantage over standard TM for completeness.

## What Logic SHOULD Be Pursued First?

### Assessment of Options

| Option | Viability | Advantage Over Current TM |
|--------|-----------|--------------------------|
| BTM (preorder D, 2D time) | LOW | None — exotic semantics, doesn't solve blocker |
| BTM (chain-restricted) | LOW | None — same blocker, weaker logic for no gain |
| Full TM via FMP/filtration | **HIGH** | Known technique, bounds F-obligations |
| Full TM via omega-enumeration | MEDIUM | Directly addresses blocker, but formalization hard |
| Dense TM (D = Rat) | MEDIUM | Clean characterization theorem |
| Discrete TM (D = Int) | MEDIUM | Clean characterization theorem |

### Recommendation: Full TM Completeness via FMP/Filtration

**The F/P blocker is the core problem. Weakening the logic doesn't avoid it — only FMP/filtration does.**

FMP/filtration works because:
- Quotient by equivalence on closure(φ) creates finitely many states
- F-obligations within closure(φ) have bounded depth
- The finite quotient structure satisfies all obligations by construction
- This is the standard technique in temporal logic completeness

### Alternative: PreorderTaskFrame as Separate Investigation

A PreorderTaskFrame is mathematically interesting in its own right (multi-dimensional time, relativistic causality, multi-clock systems), but it should be pursued as a **separate research direction**, not as a path to TM completeness.

## Gaps Remaining

1. **FMP for TM**: Neither teammate provided a detailed proof sketch of filtration for TM. This is the critical next step.

2. **What distinguishes Task Semantics FMP from standard temporal FMP?** The ternary task relation with duration composition may create unique challenges in filtration.

3. **Interpretation of 2D time**: If multi-dimensional time IS pursued later, what is the intended application? Relativistic physics? Multi-agent systems?

4. **Canonical D for PreorderTaskFrame**: If not CanonicalMCS, what preordered group serves as the canonical D for a hypothetical logic over non-linear time?

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | Task Semantics structure, WorldHistory under partial order D | completed | HIGH |
| B | Completeness strategy, axiom analysis, chain restriction | completed | HIGH |

## References

### Teammate Reports
- `specs/077_research_preorder_taskframe_generalization/reports/05_teammate-a-findings.md`
- `specs/077_research_preorder_taskframe_generalization/reports/05_teammate-b-findings.md`

### Key Source Files
- `Theories/Bimodal/Semantics/TaskFrame.lean` — D is duration type, WorldState is separate
- `Theories/Bimodal/Semantics/WorldHistory.lean` — convexity, domain, respects_task
- `Theories/Bimodal/Semantics/Truth.lean` — G/H/Box semantics, ShiftClosed
- `Theories/Bimodal/ProofSystem/Axioms.lean` — temp_linearity and all TM axioms
- `Theories/Bimodal/Metalogic/Algebraic/ParametricCanonical.lean` — Canonical D is a parameter
