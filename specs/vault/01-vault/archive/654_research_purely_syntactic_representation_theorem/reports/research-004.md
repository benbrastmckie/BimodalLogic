# Research Report: Reflexive vs Irreflexive Temporal Operators in Canonical Model Construction

- **Task**: 654 - Research Purely Syntactic Representation Theorem
- **Started**: 2026-01-20T19:00:00Z
- **Completed**: 2026-01-20T20:30:00Z
- **Effort**: 1.5 hours
- **Priority**: High
- **Dependencies**: research-003.md, implementation-summary-20260121.md
- **Sources/Inputs**:
  - Implementation attempt: CanonicalHistory.lean, TaskRelation.lean
  - Current semantics: Truth.lean, Formula.lean, Axioms.lean
  - Temporal logic literature: Prior, Goldblatt, Blackburn et al.
- **Artifacts**: This report (research-004.md)
- **Standards**: report-format.md, artifact-formats.md

## Executive Summary

- **The core issue**: The canonical history construction with same MCS at all times requires temporal T-axioms (`G phi -> phi`, `H phi -> phi`) which TM logic does NOT have because G/H are irreflexive (exclude present)
- **Keeping G/H primitive (irreflexive) IS possible** but requires a **different MCS at each time point** in the canonical history
- **Switching to G'/H' primitive (reflexive)** would simplify the construction but changes the logic's character
- **Recommended approach**: Keep G/H primitive (irreflexive) and redesign the canonical history to use indexed families of MCS with explicit formula propagation constraints between adjacent times
- This preserves the user's desired conceptual elegance while achieving implementation feasibility

## Context & Scope

### Problem Statement

The implementation attempt in Phase 4 (CanonicalHistory.lean) hit a fundamental design flaw:

```lean
-- Current (broken) approach: same MCS at all times
def canonical_history_states (Gamma : Set Formula) (h_mcs : SetMaximalConsistent Gamma) :
    (t : D) -> full_domain D t -> (UniversalCanonicalFrame D).WorldState :=
  fun t _ => { mcs := Gamma, time := t, is_mcs := h_mcs }
```

For `canonical_task_rel (Gamma, s) (t - s) (Gamma, t)` to hold when `t - s > 0`, the definition requires:
- `G phi in Gamma -> phi in Gamma` (all future formulas imply present)
- `H phi in Gamma -> phi in Gamma` (all past formulas imply present)

These are **temporal T-axioms** (`G phi -> phi`, `H phi -> phi`). TM logic does NOT include these axioms because:
- `G phi` means "phi holds at ALL FUTURE times" (strictly greater than now)
- `H phi` means "phi holds at ALL PAST times" (strictly less than now)
- Neither includes the present moment

### User Preference

The user stated:
> "I am OK changing the semantics for the tense operators to take G' and H' to be primitive where these read `It is and is always going to be` and `It is and always was` if this eases the construction of a canonical frame since the G and H could still be defined in terms of G', H', and negation. If possible, I would nevertheless prefer to keep G and H primitive as they have a certain conceptual elegance given the intuitive readings of these terms."

### Research Questions

1. Can we keep G/H primitive (irreflexive semantics) while making the canonical construction work?
2. What would switching to G'/H' as primitive (reflexive semantics) entail?
3. What is the recommended approach considering both feasibility and elegance?

## Findings

### 1. Analysis of Irreflexive vs Reflexive Temporal Operators

#### Current Semantics (Irreflexive, from Truth.lean)

```lean
def truth_at (M : TaskModel F) (tau : WorldHistory F) (t : D) : Formula -> Prop
  | Formula.all_past phi => forall (s : D), s < t -> truth_at M tau s phi
  | Formula.all_future phi => forall (s : D), t < s -> truth_at M tau s phi
```

**Key observations**:
- `all_past phi` (H) quantifies over `s < t` (strictly less)
- `all_future phi` (G) quantifies over `s > t` (strictly greater)
- Neither includes `s = t`

This means:
- `H phi` at time t says nothing about phi at time t
- `G phi` at time t says nothing about phi at time t
- There is NO temporal T-axiom: `G phi -> phi` is NOT valid

#### Reflexive Semantics (G', H')

If we define reflexive variants:
```lean
def all_future' phi := forall s, t <= s -> truth_at M tau s phi  -- includes present
def all_past' phi := forall s, s <= t -> truth_at M tau s phi    -- includes present
```

Then:
- `G' phi -> phi` would be valid (reflexive temporal operators)
- `H' phi -> phi` would be valid
- This matches the T-axiom pattern from modal S5

#### Definability Relationships

**G/H in terms of G'/H' and negation**:
```
G phi = (G' phi) AND (G' neg(phi) -> phi)  -- No, this doesn't work
```

Actually, the correct relationships are:
```
G' phi = phi AND G phi     -- "phi now AND always in future"
H' phi = phi AND H phi     -- "phi now AND always in past"

G phi = G' phi AND neg(G' neg phi)  -- No, still wrong
```

Let me be more careful:
```
G' phi = phi AND G phi
H' phi = phi AND H phi

-- Inverting:
G phi = some_past (G' phi) OR (G' phi AND NOT phi)  -- Complex
```

**Simpler approach**: Define G/H directly from G'/H':
```
G phi := "At all strictly future times phi"
     = (G' phi) restricted to strictly future times
     = NOT(neg(phi) AND some_future(neg phi))  -- existential dual
```

This is getting complex. The clean relationship is:
- **G' = phi AND G** (reflexive = present AND strict future)
- **H' = phi AND H** (reflexive = present AND strict past)
- **G = G' without requiring present** (harder to express)
- **H = H' without requiring present** (harder to express)

**Key insight**: G' and H' naturally include G and H, but extracting G/H from G'/H' is not as clean because you need to "subtract" the present moment.

### 2. Why the Same-MCS Approach Fails for Irreflexive Operators

#### The Sorried Proof in CanonicalHistory.lean

```lean
lemma canonical_history_respects ... :
  by_cases hpos : 0 < t - s
  case positive =>
    refine <?, ?, ?>
    -- G phi in Gamma -> phi in Gamma
    intro phi hG
    sorry -- T-axiom application for future (UNPROVABLE)
    -- H phi in Gamma -> phi in Gamma
    intro phi hH
    sorry -- T-axiom application for past (UNPROVABLE)
```

#### Why This Is Fundamental

When we have the same MCS Gamma at times s and t where s < t:
- The task relation requires `G phi in Gamma(s) -> phi in Gamma(t)`
- But Gamma(s) = Gamma(t) = Gamma (by construction)
- So we need `G phi in Gamma -> phi in Gamma`
- This is exactly the temporal T-axiom, which is NOT derivable in TM

**This is not a gap in the proof; it's a fundamental mismatch between**:
1. The canonical history design (same MCS everywhere)
2. The task relation definition (formula propagation)
3. The logic's axiom system (no temporal T-axioms)

### 3. Two Viable Approaches

#### Approach A: Keep G/H Irreflexive, Use Different MCS at Different Times

**Core Insight**: Instead of one MCS Gamma at all times, build a family of MCS indexed by time:
```lean
structure CanonicalHistoryMCS (D : Type*) where
  mcs : D -> Set Formula
  is_mcs : forall t, SetMaximalConsistent (mcs t)
  forward_propagation : forall t t', t < t' ->
    (forall phi, G phi in mcs t -> phi in mcs t')
  backward_propagation : forall t t', t' < t ->
    (forall phi, H phi in mcs t -> phi in mcs t')
```

**Construction**: Given a single MCS Gamma at the "origin" time 0:
1. For each future time t > 0, define mcs(t) = Lindenbaum extension of {phi | G phi in Gamma}
2. For each past time t < 0, define mcs(t) = Lindenbaum extension of {phi | H phi in Gamma}
3. The propagation conditions are satisfied by construction

**Proof of respects_task**:
- When t > s: mcs(t) contains phi whenever G phi in mcs(s) (by forward_propagation)
- When t < s: mcs(s) contains phi whenever H phi in mcs(t) (by backward_propagation)
- This is exactly what the task relation requires

**Compositionality**: Follows from transitivity of formula propagation:
- G phi in mcs(s) -> phi in mcs(t) for all t > s
- G phi in mcs(s) -> G phi in mcs(t) for t > s (by MCS closure under Temporal 4: G phi -> GG phi)
- So G phi in mcs(s) -> phi in mcs(u) for all u > t > s (transitivity)

**Complexity**: Medium-High
- Need to carefully construct the indexed family of MCS
- Need to prove the propagation conditions hold
- Need to handle the interaction between G/H propagation

#### Approach B: Switch to Reflexive G'/H' as Primitive

**Syntax Change**:
```lean
inductive Formula where
  | all_past' : Formula -> Formula   -- H' (reflexive)
  | all_future' : Formula -> Formula -- G' (reflexive)
```

**Semantics Change**:
```lean
| Formula.all_past' phi => forall (s : D), s <= t -> truth_at M tau s phi
| Formula.all_future' phi => forall (s : D), t <= s -> truth_at M tau s phi
```

**Axiom Changes**:
- ADD: Temporal T: `G' phi -> phi` (valid by reflexivity)
- ADD: Temporal T: `H' phi -> phi` (valid by reflexivity)
- MODIFY: Temporal 4 becomes `G' phi -> G' G' phi` (still valid)
- MODIFY: Temporal A becomes `phi -> G' P' phi` (needs checking)

**Derived G/H Definitions**:
```lean
def all_future (phi : Formula) := all_future' phi AND NOT phi  -- Problematic!
```

Wait, this is wrong. If G' phi means "phi at present AND all future", then:
- G phi should mean "phi at all strictly future times"
- But `G' phi AND NOT phi` means "phi at all future including present, BUT NOT at present" = contradiction!

The correct derivation:
```lean
def some_future (phi : Formula) := NOT (all_future' (NOT phi))
-- F phi = "phi at some time >= now"

def all_future (phi : Formula) := all_future' phi AND (phi -> some_future phi)
-- G phi requires: phi at all times >= now, AND if phi now then phi at some future time
-- This is still wrong...
```

**The real issue**: G' and G have different domains, and you can't easily define one from the other without adding explicit "next moment" or "strictly after" operators.

**Better Approach for Derivation**:
```
G phi := "For all t' > t, phi holds at t'"
G' phi := "For all t' >= t, phi holds at t'"

G' phi <-> (phi AND G phi)  -- CORRECT

G phi <-> G' phi AND NOT(G' NOT_phi implies phi)  -- Complicated
```

Actually:
```
G phi = G' phi WITHOUT the requirement that phi holds at t
      = "G' (phi at strictly future times)"
```

This requires second-order quantification or explicit time terms, which TM doesn't have.

**Conclusion**: Deriving G/H from G'/H' is NOT clean in the object language. You would need to add a "strictly future" modality explicitly, defeating the purpose.

### 4. Analysis of Axiom System Impact

#### Current TM Axioms (from Axioms.lean)

The temporal axioms are:
- TK: `G(phi -> psi) -> (G phi -> G psi)` (distribution)
- T4: `G phi -> GG phi` (transitivity)
- TA: `phi -> G(P phi)` (connectedness: present was past of future)
- TL: `always phi -> G(H phi)` (introspection)
- MF: `box phi -> box(G phi)` (modal-future interaction)
- TF: `box phi -> G(box phi)` (temporal-future interaction)

**Note**: There is NO temporal T-axiom (`G phi -> phi`).

#### Why No Temporal T-Axiom Makes Sense

The intuitive reading:
- "It will always be the case that phi" does NOT imply "phi is the case now"
- Example: "I will always be retired" (at age 25) doesn't mean "I am retired now"
- The future tense operator G is naturally irreflexive

#### Impact of Adding Temporal T-Axiom

If we added `G phi -> phi` (and `H phi -> phi`):
1. The logic would become **reflexive** in the temporal dimension
2. `G phi` would mean "phi now AND at all future times" = G' phi
3. The canonical construction with same-MCS-at-all-times would work
4. BUT: The logic's character changes - G becomes G'

This is exactly what the user asked about, and the analysis shows it's a non-trivial change to the logic itself.

### 5. Recommended Approach: Keep G/H Primitive with Indexed MCS Family

#### Why This Is Preferable

1. **Preserves intuitive semantics**: G/H remain "strictly future/past"
2. **No logic modification needed**: Axiom system stays the same
3. **Conceptual elegance preserved**: User's preference respected
4. **Implementation is feasible**: Standard temporal logic completeness technique

#### Construction Outline

**Step 1: Define the Indexed MCS Family Structure**

```lean
/-- A family of MCS indexed by time, with temporal coherence -/
structure CanonicalHistoryMCS (D : Type*) [AddCommGroup D] [LinearOrder D] where
  mcs : D -> Set Formula
  is_mcs : forall t, SetMaximalConsistent (mcs t)
  -- Forward temporal coherence: G formulas propagate to future
  forward_G : forall t t' phi, t < t' -> Formula.all_future phi in mcs t -> phi in mcs t'
  -- Backward temporal coherence: H formulas propagate to past
  backward_H : forall t t' phi, t' < t -> Formula.all_past phi in mcs t -> phi in mcs t'
  -- Future looking back: H formulas at future times relate to past
  forward_H : forall t t' phi, t < t' -> Formula.all_past phi in mcs t' -> phi in mcs t
  -- Past looking forward: G formulas at past times relate to future
  backward_G : forall t t' phi, t' < t -> Formula.all_future phi in mcs t' -> phi in mcs t
```

**Step 2: Construct the Family from a Root MCS**

Given MCS Gamma at time 0, construct mcs(t) for each t in D:

For t > 0:
```
mcs(t) = Lindenbaum extension of:
  {phi | G phi in Gamma} ∪ {phi | some predecessor s < t has G phi in mcs(s)}
```

For t < 0:
```
mcs(t) = Lindenbaum extension of:
  {phi | H phi in Gamma} ∪ {phi | some successor s > t has H phi in mcs(s)}
```

**Step 3: Prove Coherence Conditions**

The forward_G condition follows from:
- If G phi in mcs(t), then by construction phi is in the generating set for mcs(t')
- Lindenbaum extension preserves the generating set

**Step 4: Define CanonicalHistory**

```lean
def canonical_history (family : CanonicalHistoryMCS D) : WorldHistory (UniversalCanonicalFrame D) where
  domain := fun _ => True
  convex := trivial
  states := fun t _ => { mcs := family.mcs t, time := t, is_mcs := family.is_mcs t }
  respects_task := -- Uses family's coherence conditions
```

**Step 5: Prove respects_task**

When t > s (positive duration):
- Need: canonical_task_rel (mcs(s), s) (t - s) (mcs(t), t)
- This requires: G phi in mcs(s) -> phi in mcs(t) (by forward_G condition)
- And: H phi in mcs(t) -> phi in mcs(s) (by forward_H condition)

When t < s (negative duration):
- Symmetric using backward_G and backward_H conditions

#### Estimated Effort

| Phase | Effort | Risk |
|-------|--------|------|
| Define CanonicalHistoryMCS structure | 2 hours | Low |
| Prove coherence of construction | 6 hours | Medium |
| Construct family from root MCS | 4 hours | Medium |
| Prove respects_task | 4 hours | Medium |
| Truth lemma for indexed family | 8 hours | High |
| **Total** | **24 hours** | Medium |

## Decisions

### D1: Keep G/H Primitive (Irreflexive)
**Decision**: Maintain the current irreflexive semantics for G and H operators.
**Rationale**: Preserves conceptual elegance and intuitive readings; avoids modifying the logic's character.

### D2: Use Indexed MCS Family for Canonical History
**Decision**: Redesign the canonical history construction to use different MCS at different times, connected by temporal coherence conditions.
**Rationale**: This is the standard technique in temporal logic completeness proofs and directly addresses the T-axiom gap.

### D3: Do NOT Add Reflexive Operators G'/H' as Primitive
**Decision**: Avoid switching to reflexive operators as primitive.
**Rationale**:
- Deriving G/H from G'/H' is not clean in the object language
- Would require modifying the axiom system
- Changes the fundamental character of the logic

## Recommendations

### Primary Recommendation: Implement Indexed MCS Family

1. **Archive current CanonicalHistory.lean** (blocked implementation)

2. **Create new module** `Metalogic/Representation/IndexedMCSFamily.lean`:
   - Define `CanonicalHistoryMCS` structure with coherence conditions
   - Prove existence of such families starting from any root MCS
   - Use transfinite induction or Choice axiom for construction

3. **Refactor CanonicalHistory.lean** to use the indexed family:
   - Replace single-MCS construction with family-based construction
   - Prove respects_task using coherence conditions
   - This removes the sorries

4. **Update Truth Lemma** to work with indexed families:
   - Truth at time t depends on mcs(t), not a fixed MCS
   - The proof structure is similar but propagates through the family

### Alternative: Semantic Shortcut (If Blocked)

If the indexed family construction proves too difficult:

1. **Keep the semantic canonical model** (SemanticCanonicalModel.lean)
2. **Accept the compositionality sorry** with documented justification:
   - The sorry only affects unbounded durations
   - Actual formula evaluation uses bounded temporal depth
   - The completeness proof can proceed with this known limitation

3. **Document the limitation** clearly:
   - The canonical frame is a TaskFrame Int
   - Compositionality holds for bounded durations (practically sufficient)
   - Full compositionality requires the indexed MCS approach

### Not Recommended: Adding Temporal T-Axiom

Do NOT add `G phi -> phi` or `H phi -> phi` as axioms because:
- This fundamentally changes the logic (G becomes G')
- The semantic interpretation would need modification
- Existing proofs about G/H may need revision
- The intuitive readings of G/H would change

## Risks & Mitigations

### Risk 1: Indexed Family Construction Complexity
**Risk**: The transfinite construction of indexed MCS families is complex.
**Mitigation**: Use Choice axiom directly; the construction is noncomputable anyway. Focus on proving the structure exists, not computing it.

### Risk 2: Coherence Condition Proofs
**Risk**: Proving forward_G, forward_H, backward_G, backward_H may be difficult.
**Mitigation**: These follow from MCS closure properties and the Temporal 4 axiom (`G phi -> GG phi`). Break into small lemmas.

### Risk 3: Truth Lemma for Indexed Families
**Risk**: The truth lemma becomes more complex with varying MCS.
**Mitigation**: The key insight is that truth at time t depends only on mcs(t). The induction proceeds similarly but uses coherence conditions for temporal cases.

### Risk 4: Time Synchronization
**Risk**: Ensuring the indexed family is consistent across all time points.
**Mitigation**: The coherence conditions are exactly designed to ensure this. Prove them carefully during construction.

## Appendix

### A1: Comparison of Approaches

| Aspect | Same MCS (Failed) | Indexed MCS (Recommended) | Reflexive G'/H' |
|--------|-------------------|---------------------------|-----------------|
| MCS at time t | Fixed Gamma | mcs(t) varies | Fixed Gamma |
| Temporal T-axiom needed | Yes | No | Yes (built-in) |
| respects_task proof | Blocked (sorry) | Via coherence | Trivial |
| Logic modification | None | None | Yes (axioms) |
| Implementation effort | N/A (blocked) | Medium-High | Medium |
| Conceptual elegance | N/A | High | Lower |

### A2: Literature References

- **Prior, A.N.** "Past, Present, and Future" - Original work on tense logic with strict temporal operators
- **Goldblatt, R.** "Logics of Time and Computation" - Canonical model construction for temporal logics
- **Blackburn, P., de Rijke, M., Venema, Y.** "Modal Logic" - Comprehensive treatment including indexed frame constructions
- **Reynolds, M.** "Axioms for Logics of Temporal Refinement" - Techniques for temporal accessibility

### A3: Key Files for Implementation

| File | Purpose |
|------|---------|
| `Metalogic/Core/MaximalConsistent.lean` | MCS theory, Lindenbaum's lemma |
| `Metalogic/Representation/CanonicalWorld.lean` | CanonicalWorld structure |
| `Metalogic/Representation/TaskRelation.lean` | Task relation definition |
| `Metalogic/Representation/CanonicalHistory.lean` | Needs refactoring |
| `Semantics/Truth.lean` | Semantic truth definition |
| `ProofSystem/Axioms.lean` | Axiom definitions (Temporal 4) |

### A4: Pseudocode for Indexed MCS Construction

```
function construct_indexed_family(Gamma : MCS, origin : D) -> CanonicalHistoryMCS:
  mcs : D -> Set Formula
  mcs(origin) := Gamma

  -- Forward construction (future times)
  for each t > origin in increasing order:
    let predecessors := {s | s < t and mcs(s) defined}
    let seed := {phi | exists s in predecessors, G phi in mcs(s)}
    mcs(t) := lindenbaum_extension(seed)

  -- Backward construction (past times)
  for each t < origin in decreasing order:
    let successors := {s | s > t and mcs(s) defined}
    let seed := {phi | exists s in successors, H phi in mcs(s)}
    mcs(t) := lindenbaum_extension(seed)

  return { mcs := mcs, ... coherence proofs ... }
```

### A5: Why Temporal 4 Axiom Helps

The Temporal 4 axiom `G phi -> GG phi` is crucial for compositionality:

If G phi in mcs(s) for s < t < u:
- By forward_G: phi in mcs(t)
- Also by Temporal 4: GG phi in mcs(s), so G phi in mcs(s)
- We need: G phi in mcs(t) to propagate to phi in mcs(u)

The question is whether we can derive G phi in mcs(t) from G phi in mcs(s).

**Key observation**: The coherence condition forward_G only says phi propagates, not G phi.

**Solution**: Include in the seed not just {phi | G phi in mcs(s)} but also {G psi | G psi in mcs(s) and need to preserve}. This is where the construction becomes subtle and requires careful induction.
