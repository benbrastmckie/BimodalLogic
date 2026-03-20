# Research Report: Task #1004 (Round 2)

**Task**: Dovetailing Chain F/P Witnesses - Semantic Foundations
**Date**: 2026-03-19
**Mode**: Team Research (2 teammates)
**Focus**: World states vs durations vs world histories; times relative to histories

## Summary

This round investigated the semantic foundations underlying the F/P witness problem, with emphasis on the user's critical insight that **world states and durations are distinct theoretical roles** and that **times are relative to each world history**, not absolute. Two teammates analyzed the codebase's semantic architecture and the relevant literature, revealing both a significant semantic-syntactic gap in the current infrastructure and a rich theoretical context from bundled tree semantics, Ockhamist logic, and dynamical systems perspectives.

## Key Findings

### 1. The Codebase Has Two Semantic Layers That Don't Connect

**Semantic Layer** (WorldHistory.lean): Properly separates world states, durations, and histories:
```lean
structure WorldHistory (F : TaskFrame D) where
  domain : D → Prop                           -- times RELATIVE TO this history
  states : (t : D) → domain t → F.WorldState  -- maps times to world states
  respects_task : ...                          -- task relation constraint
```
This IS close to the desired framework: histories are functions from (relative) times to world states, with convex domains.

**Metalogic Layer** (BFMCS/FMCS): Conflates roles:
```lean
structure FMCS where
  mcs : D → Set Formula    -- D serves as both "time" and indexing domain
  is_mcs : ∀ t, SetMaximalConsistent (mcs t)
```
Here D is treated as absolute time shared across all families. MCSes serve as both syntactic proof objects and semantic "worlds."

**The gap**: The metalogic layer (where completeness is proven) does not connect to the semantic layer (where world states, durations, and histories are properly separated).

### 2. Current Semantic Roles (Teammate A Analysis)

| Concept | Current Implementation | Proper Thomason Framework |
|---------|----------------------|--------------------------|
| World States | `CanonicalMCS.world : Set Formula` (syntactic) | Primitive modal dimension W |
| Durations | `D : Type*` with `[Preorder D]` | Temporal translation group |
| Families/Histories | `FMCS D` - D-indexed MCS function | Functions τ: X → W with convex domain X ⊆ D |
| Times | Implicitly = D (absolute) | **RELATIVE TO each history** |
| Accessibility | `CanonicalR` (g_content inclusion) | Temporal succession within history |
| Modal | Box quantifies over families at same t | Box quantifies over histories through moment |

### 3. The Framework Is NOT Standard Thomason (Teammate B Analysis)

The codebase implements a **distinctive framework** that differs fundamentally from Thomason's bundled trees:

**Thomason**: Tree of shared moments; histories are maximal chains in the tree; moments are primitive objects shared across histories.

**Codebase**: Duration group D as translation space; histories are trajectories through world states; times are elements of each history's convex domain in D. **No shared moment space exists.**

The codebase is closest to **"possible trajectories" semantics** (dynamical systems perspective):
- W = phase space (world states)
- D = time parameter space (duration group)
- Trajectories = orbits of the dynamics (world histories)
- Bundle = collection of dynamically compatible trajectories

### 4. Why Standard Completeness Fails Here

In standard bundled tree completeness (Zanardo 1985, Reynolds 2002):
- Each MCS corresponds to a **moment-history pair**
- Adding an MCS **automatically places it** in the tree structure
- F(phi) witnesses are just new moment-history pairs — they fit in the tree by construction

In the codebase's Int-indexed chain:
- MCSes are built step-by-step via Lindenbaum extension
- Adding an MCS does **NOT** automatically assign it an Int position
- F(phi) witnesses from `canonical_forward_F` are separate MCSes outside the chain

**This is the core structural mismatch**: the codebase's framework separates world states from times (which is mathematically correct), but this separation means witnesses can't be trivially placed.

### 5. The Ockhamist Semantics Connection

The codebase follows **Ockhamist semantics** (Prior 1967):
- F(phi) means "phi will be true" within the current history (not all possible futures)
- G(phi) means "phi will always be true" within the current history
- Box quantifies over histories in the bundle, not over future moments

F/P witnesses must exist **within the current history**. This is the user's key point: times are relative to histories, so witnesses must be found at times within the same history, not at arbitrary MCSes.

### 6. The AddCommGroup Requirement Revisited

| Layer | Requirement | Purpose |
|-------|-------------|---------|
| Semantic (TaskFrame) | `[AddCommGroup D] [LinearOrder D]` | Duration arithmetic, time-shift |
| Metalogic (FMCS) | `[Preorder D]` | Ordering only |
| CanonicalFMCS | Domain = CanonicalMCS with Preorder | No AddCommGroup |

The mismatch: completeness at the metalogic level works with `[Preorder D]`, but connecting to semantics requires `[AddCommGroup D]`. CanonicalMCS has a natural Preorder (from CanonicalR reflexive closure) but NOT an AddCommGroup structure.

### 7. Time-Shift and ShiftClosed Properties

The semantic layer has crucial infrastructure that the metalogic doesn't use:
```lean
def time_shift (sigma : WorldHistory F) (Delta : D) : WorldHistory F where
  domain := fun z => sigma.domain (z + Delta)
  states := fun z hz => sigma.states (z + Delta) hz
```

`ShiftClosed` requires the bundle Omega to be closed under time-shift. This is the temporal analog of requiring evaluation contexts to be "accessible" in 2D semantics — and it's exactly what ensures that F/P witnesses exist within shifted copies of histories.

## Synthesis

### Conflicts Found: 1

**Teammate A** suggests enriched chain construction may still work (hybrid approach), while **Teammate B** recommends accepting CanonicalFMCS as primary and treating Int as computational approximation.

**Resolution**: Both positions are compatible. The question is whether Int-indexing is *needed* for completeness or merely *desired* for computational purposes. If the completeness theorem can be stated over CanonicalMCS (with Preorder), the Int-indexed construction becomes a separate concern (decidability, finite model property). The fundamental completeness can use CanonicalFMCS.

### Gaps Identified: 3

1. **Semantic-Syntactic Bridge**: No connection between WorldHistory (semantic) and FMCS (metalogic). This bridge would formalize "FMCS families ARE world histories" and could make F/P coherence follow from semantic properties.

2. **History-Relative Times in Metalogic**: FMCS treats D as absolute time. Need convex domain subsets per history if following the user's framework strictly.

3. **Task Relation in Metalogic**: CanonicalR is purely syntactic (g_content inclusion). No connection to the semantic `task_rel` that governs world state transitions.

## Recommended Approaches

### Approach A: CanonicalFMCS + Semantic Bridge (HIGH CONFIDENCE)

**Principle**: Use CanonicalFMCS for completeness (already sorry-free), then build a semantic bridge to connect metalogic families to WorldHistory semantics.

1. Completeness: `temporal_coherent_family_exists_CanonicalMCS` (done, sorry-free)
2. Bridge: Define `CanonicalTaskFrame` and show FMCS families over CanonicalMCS correspond to WorldHistories
3. Int/Rat: Domain transfer for computational applications (separate concern)

**Why this is correct**: It respects the user's framework — world states (MCSes) are distinct from durations (D), and completeness doesn't conflate them.

### Approach B: History-Relative FMCS Reformulation (MEDIUM CONFIDENCE)

**Principle**: Reformulate FMCS to use history-relative times (convex domains), matching the semantic WorldHistory structure.

```lean
structure FMCS_Relative where
  time_domain : D → Prop           -- convex subset of D
  mcs : (t : D) → time_domain t → Set Formula
  is_mcs : ∀ t ht, SetMaximalConsistent (mcs t ht)
```

**Risk**: Major refactoring; may break existing sorry-free proofs.

### Approach C: Dynamical Systems Perspective (EXPLORATORY)

**Principle**: Frame the completeness proof in dynamical systems terms — the canonical model is the full phase space, histories are orbits, and completeness shows the orbit structure captures the logic.

**Potential**: Could provide a unifying mathematical framework. Aligns with the user's emphasis on world states vs durations.

**Risk**: Novel approach without established precedent in modal logic literature.

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | Codebase semantic structures | completed | MEDIUM-HIGH |
| B | Literature semantic frameworks | completed | HIGH (literature), MEDIUM (recommendations) |

## Key Insight for Next Steps

The user's emphasis on separating world states from durations/times is **already partially implemented** in the semantic layer (WorldHistory.lean) but **not yet connected** to the metalogic layer (BFMCS/FMCS). The F/P witness problem is a symptom of this disconnection: at the metalogic level, we try to build Int-indexed chains (conflating time with indexing), when the semantic layer already handles times-relative-to-histories correctly.

The mathematically correct path is to:
1. Use CanonicalFMCS for completeness (keeps world states and times separate)
2. Build the semantic bridge (connect FMCS to WorldHistory)
3. Treat Int/Rat indexing as a domain transfer concern, not a completeness concern

## References

### Literature
- Thomason (1970) - Bundled tree semantics for indeterminist tense logic
- Zanardo (1985) - Completeness for bundled tree validity
- Reynolds (2002, 2003) - Axiomatization of Ockhamist branching time
- Prior (1967) - Past, Present, and Future (Ockhamist vs Peircean distinction)
- Burgess (1979) - Logic and time
- Belnap (1992) - Branching space-times
- Ciuni & Zanardo (2010) - Completeness for BTC logic
- Kaplan (1989) - Two-dimensional semantics

### Codebase
- WorldHistory.lean (semantic history structure with proper separation)
- BFMCS.lean, FMCS.lean (metalogic bundle/family structures)
- CanonicalFrame.lean (accessibility relation, canonical_forward_F/P)
- CanonicalFMCS.lean (sorry-free completeness for all-MCS domain)
- IntBFMCS.lean (blocked Int-indexed construction)
