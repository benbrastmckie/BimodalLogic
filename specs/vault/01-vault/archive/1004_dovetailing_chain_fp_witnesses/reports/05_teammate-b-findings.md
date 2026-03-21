# Research Report: Task #1004 - Teammate B Findings

**Task**: Literature on Semantic Frameworks that Separate World States from Times
**Date**: 2026-03-19
**Focus**: Thomason's bundled tree semantics, Prior's tense logic, two-dimensional semantics, and frameworks relevant to the codebase's W/D separation

## Key Findings

### 1. The Codebase's Unique Framework: World Histories over Task Frames

The codebase implements a distinctive semantic framework where:
- **World States (W)**: Elements of `F.WorldState` in a TaskFrame - independent of time
- **Durations (D)**: An ordered abelian group - the temporal translation space
- **World Histories**: Functions `tau: D -> W` (with convex domain) respecting the task relation
- **Times are RELATIVE**: Times only exist within a history as domain elements

This is NOT the standard Ockhamist/Thomason framework where moments are tree nodes. The codebase's `WorldHistory` (line 69 of WorldHistory.lean) explicitly separates:
```lean
structure WorldHistory {D : Type*} [AddCommGroup D] [LinearOrder D] (F : TaskFrame D) where
  domain : D -> Prop
  states : (t : D) -> domain t -> F.WorldState
  respects_task : ...  -- Task relation constraint
```

**Critical Insight**: Times in this framework are domain elements of individual histories, not primitive moments shared across all histories. This is closer to a "possible trajectories" view than to branching tree semantics.

### 2. Thomason's Bundled Tree Semantics

#### Historical Background

Thomason (1970) introduced bundled tree semantics as a refinement of Ockhamist branching time. The key innovation was restricting quantification over histories to a designated "bundle" rather than all maximal chains.

**Thomason's Framework** (from SEP Temporal Logic):
- Tree structure T = (Moments, <) where < is a left-linear partial order
- Histories H = maximal linearly ordered subsets of T
- A **bundle B** is a subset of histories satisfying: every moment belongs to some history in B
- Truth is evaluated at moment-history pairs (m, h) where m is on h

**F/P Interpretation in Bundled Trees**:
```
M, (m, h) |= F(phi)  iff  exists m' > m on h such that M, (m', h) |= phi
M, (m, h) |= P(phi)  iff  exists m' < m on h such that M, (m', h) |= phi
M, (m, h) |= Box(phi) iff  forall h' in B passing through m, M, (m, h') |= phi
```

**Completeness Status**: A complete axiomatization for bundled tree validity is given in Zanardo (1985) and Reynolds (2002, 2003). The proof technique uses canonical model constructions where each MCS corresponds to a moment-history pair.

#### Relationship to Codebase

The codebase's BFMCS (Bundle of Families of MCS) implements a variant of bundled semantics:
- Each FMCS family corresponds to a "history" in the bundle
- Modal coherence conditions (lines 101-110 of BFMCS.lean) correspond to bundle closure
- The `modal_forward` and `modal_backward` conditions ensure S5-style behavior

**Key difference**: In Thomason's trees, moments are SHARED across histories (they branch from common nodes). In the codebase, times are relative to each history via the duration group D. There is no shared "moment space" - only the algebraic structure of D.

### 3. Prior's Tense Logic: Ockhamist vs Peircean

#### Prior's Original Treatment (1967)

Prior identified two fundamental interpretations of future operators:

**Peircean Semantics**:
- F(phi) means "phi will necessarily be true" (in ALL possible futures)
- Future truth is modalized - true only if inevitable
- Validates: F(phi) <-> Box(F(phi)) (future = necessary future)

**Ockhamist Semantics**:
- F(phi) means "phi will be true" (in THE actual future - one selected history)
- Requires an "actual history" parameter for evaluation
- Future truth and modality come apart
- Peircean F(phi) = Ockhamist Box(F(phi))

#### Burgess and Reynolds Extensions

Modern extensions (Burgess 1979, Reynolds 2003) addressed:
- Axiomatization of Ockhamist validity (still partially open for full trees)
- Bundled tree completeness (decidable, axiomatizable)
- Relationship between Peircean and Ockhamist operators

#### Relevance to Codebase

The codebase's `all_future` (G) and `some_future` (F) operators follow Ockhamist semantics within each history:
```lean
| Formula.all_future phi => forall s, t <= s -> truth_at M sigma s phi
| Formula.some_future phi => exists s, t < s /\ truth_at M sigma s phi
```

The "actual history" in the codebase is the `sigma : WorldHistory` parameter. Box separately quantifies over histories in the model's Omega set.

**Key insight for F/P witnesses**: In Ockhamist semantics, F(phi) witnesses exist WITHIN the current history. The challenge is ensuring the canonical construction produces histories where these internal witnesses exist at the right positions.

### 4. Two-Dimensional Semantics: Separating Contexts and Circumstances

#### Kaplan-Stalnaker Framework

Two-dimensional semantics (Kaplan 1989, Stalnaker 1978) uses two indices for evaluation:
1. **Context of use** (w_c): Determines which content is expressed
2. **Circumstance of evaluation** (w_e): Evaluates the modal profile

The semantic matrix M[c, e] gives truth value for context c and circumstance e.

**Key Operators**:
- `actually`: Refers back to context (M[c,e] |= actually(phi) iff M[c,c] |= phi)
- `now`: Similar for temporal index
- These operators "rigidify" reference across possible evaluations

#### Application to Temporal Logic

In temporal 2D semantics:
- First dimension: Time of utterance / evaluation base
- Second dimension: Time being quantified over

This enables distinguishing:
- "It will be that it was raining" (past within future)
- Nested temporal operators with different scopes

#### Relevance to Codebase

The codebase's time-shift construction (WorldHistory.lean lines 238-260) implements a form of 2D navigation:
```lean
def time_shift (sigma : WorldHistory F) (Delta : D) : WorldHistory F where
  domain := fun z => sigma.domain (z + Delta)
  states := fun z hz => sigma.states (z + Delta) hz
```

This is exactly the "change of evaluation point" operation from 2D semantics. The duration Delta translates between evaluation contexts.

**Insight**: The codebase's `ShiftClosed` property (requiring Omega to be closed under time-shift) is the temporal analog of requiring evaluation contexts to be "accessible" in 2D semantics.

### 5. Belnap's Branching Space-Times and STIT Logic

#### Histories in Belnap's Framework

Belnap (1992) extended branching time to branching space-time, with key concepts:
- **Histories**: Maximal sets of pairwise spacelike-related events
- **Moment-history pairs**: Evaluation points for STIT operators
- **Choice cells**: Equivalence classes of histories determined by an agent's choice at a moment

**Completeness for BTC**: Ciuni & Zanardo (2010) proved completeness for a branching-time logic with possible choices (BTC), where modal operators quantify over histories and temporal operators involve restricted quantification over choices.

#### Relevance to Codebase

The codebase doesn't implement STIT-style agency, but Belnap's treatment of histories as complete developments is relevant:
- Each `FMCS` family is a "complete development" in Belnap's sense
- The bundle structure allows multiple possible developments
- Modal coherence corresponds to histories being "modally connected"

### 6. Completeness Approaches in Bundled Semantics

#### Standard Bundled Tree Completeness (Zanardo 1985)

The completeness proof for bundled tree validity uses:
1. **Canonical model**: Worlds = MCSes labeled by moment-history pairs
2. **Tree structure**: Induced from temporal relations between MCS labels
3. **Bundle constraint**: Every moment has at least one history through it

**Key technique**: For F(phi) witnesses, construct an MCS extending the current seed with phi at a future moment. The MCS automatically corresponds to a moment-history pair in the canonical tree.

#### Why Standard Technique Fails for Codebase

The codebase's `intChainMCS` construction (IntBFMCS.lean) differs fundamentally:
1. Times are Int-indexed, not tree moments
2. The chain is constructed step-by-step via Lindenbaum extension
3. F(phi) witnesses from `canonical_forward_F` are SEPARATE MCSes, not positions in the chain

**The gap**: In standard bundled semantics, adding an MCS automatically places it in the tree structure. In the codebase, adding an MCS does NOT automatically assign it an Int position.

### 7. Recommended Framework for This Codebase

#### The "Possible Trajectories" View

The codebase's semantics is best understood as:
- **W (WorldState)**: The space of possible instantaneous states
- **D (Duration)**: The translation group for time
- **Trajectories (WorldHistory)**: Complete evolutions through W indexed by D
- **Bundle (BFMCS)**: Collection of canonical trajectories with modal coherence

This is closest to **dynamical systems semantics** where:
- W is the phase space
- D is the time parameter space (often R or Z)
- Trajectories are orbits of the dynamics
- The task relation is the transition relation

#### F/P Witnesses in This Framework

In a dynamical systems view:
- F(phi) means "phi holds somewhere along the forward orbit"
- P(phi) means "phi holds somewhere along the backward orbit"

The witness problem becomes: ensuring the canonical orbit (chain) passes through states satisfying phi.

**Proposed solution alignment**: The dovetailing approach works because it explicitly enumerates positions and ensures witnesses are placed at enumerated positions. This is analogous to constructing a dense orbit that visits all required phase space regions.

### 8. Connection to Codebase Infrastructure

#### CanonicalFMCS: The All-MCS Domain

The `CanonicalFMCS.lean` construction uses ALL MCSes as the domain, with no Int-indexing. This sidesteps the witness placement problem entirely:
- `canonical_forward_F` provides an MCS W with phi
- W is automatically in the domain (all MCSes)
- No position assignment needed

This corresponds to taking the FULL phase space rather than a single orbit.

#### Why Int-Indexing Matters

For decidability and computation, Int-indexing is valuable:
- Finite model property arguments require bounded time
- Explicit witness positions enable constructive proofs
- The algebraic structure of Int enables group-theoretic techniques

The task 1004 challenge is bridging these views: construct an Int-indexed chain that contains the witnesses from the all-MCS construction.

#### The "Dense Embedding" Perspective

If CanonicalMCS (with CanonicalR ordering) could be embedded densely into Int, the F/P witnesses would automatically have Int positions. The dovetailing construction approximates this by:
1. Enumerating all (position, formula) obligations
2. Placing witnesses at reserved positions
3. Proving coverage via Cantor pairing

## Confidence Level

**HIGH** for:
- Literature framework analysis (Thomason, Prior, Belnap, 2D semantics)
- Identification that codebase framework differs from standard tree semantics
- Recognition that CanonicalFMCS is the mathematically correct approach

**MEDIUM** for:
- Recommended "possible trajectories" framing
- Assessment that dovetailing can bridge Int-indexing with all-MCS witnesses

**LOW** for:
- Whether a clean embedding/retraction between CanonicalMCS and Int exists
- Whether the bundled tree completeness proofs can be directly adapted

## Summary Table

| Framework | Time Structure | History Definition | F/P Witnesses | Completeness |
|-----------|---------------|-------------------|---------------|--------------|
| Thomason Bundled Trees | Tree of moments | Maximal chains | Exist in same history (internal) | Zanardo 1985, Reynolds 2002 |
| Ockhamist | Tree of moments | Selected actual history | Internal to history | Open for full trees |
| Belnap BT | Tree of moments | Maximal linear sets | Internal with choice cells | Ciuni & Zanardo 2010 (BTC) |
| 2D Semantics | Two indices | Context + circumstance | Via index manipulation | Standard |
| **Codebase (BFMCS)** | Duration group D | FMCS families | Canonical witnesses (separate MCS) | Via CanonicalFMCS (no Int) |
| **Codebase (Int chain)** | Int | Single chain via Lindenbaum | **GAP** - need enriched construction | Task 1004 goal |

## Recommendations

1. **Accept CanonicalFMCS as the primary completeness mechanism** - It's sorry-free and matches standard literature approaches.

2. **View Int-indexed chains as computational approximations** - The Int structure is useful for decidability/FMP but not essential for completeness.

3. **For task 1004, use dovetailing to enumerate witnesses** - The Cantor pairing ensures coverage, bridging the all-MCS view with Int-indexing.

4. **Consider dense linear order (Q or R) instead of Int** - The literature uses dense time for temporal completeness; Int's discreteness may introduce artificial gaps.

## Sources

- [Stanford Encyclopedia: Temporal Logic](https://plato.stanford.edu/entries/logic-temporal/)
- [Stanford Encyclopedia: Branching Time](https://plato.stanford.edu/entries/branching-time/)
- [Stanford Encyclopedia: Two-Dimensional Semantics](https://plato.stanford.edu/entries/two-dimensional-semantics/)
- [Ciuni & Zanardo: Completeness of a Branching-Time Logic with Possible Choices](https://link.springer.com/article/10.1007/s11225-010-9291-1)
- [Thomason on T x W Semantics](https://philarchive.org/archive/IACCOT)
- [A.N. Prior's Logic - Internet Encyclopedia of Philosophy](https://iep.utm.edu/prior-an/)
- [Belnap on Indeterminism (OAPEN Library)](https://library.oapen.org/bitstream/id/7670f914-dce8-42af-9927-53e30128c4cc/612711.pdf)
- [Transition Semantics for Branching Time](https://link.springer.com/article/10.1007/s10849-015-9231-6)
