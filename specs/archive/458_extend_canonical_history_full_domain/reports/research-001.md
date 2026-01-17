# Research Report: Task #458 - Extend canonical_history to Full Domain

**Task**: 458 - Extend canonical_history from singleton domain to full domain
**Date**: 2026-01-13
**Session ID**: sess_1768268266_129193
**Started**: 2026-01-13T07:37:46Z
**Completed**: 2026-01-13T08:30:00Z
**Effort**: 8-12 hours (estimated implementation)
**Priority**: High
**Parent**: Task 257 (Completeness Proofs)
**Dependencies**: Task 448 (Build canonical_history - singleton domain MVP)
**Language**: lean
**Sources/Inputs**:
  - Completeness.lean (current state with singleton domain canonical_history)
  - WorldHistory.lean (WorldHistory type requirements)
  - Truth.lean (Semantic truth evaluation)
  - Task 448 research-001.md (singleton domain analysis)
  - Task 447 research-001.md (canonical_task_rel definition)
  - research-004.md (relativized completeness approach)
  - research-008.md (agnostic duration construction)
  - Modal Logic literature (Blackburn et al., Goldblatt)
**Artifacts**: This report
**Standards**: report-format.md, subagent-return.md, artifact-formats.md

## Executive Summary

- The singleton domain canonical_history (Task 448) makes temporal operators G and H **vacuously true** at time 0, breaking the truth lemma correspondence
- For a correct truth lemma, we need: `G phi in Gamma iff truth_at ... (all_future phi)` - but singleton domain makes the right side always true
- **Solution requires existence lemmas**: Given MCS Gamma, construct MCS Delta such that `canonical_task_rel Gamma d Delta` (forward) or `canonical_task_rel Delta d Gamma` (backward)
- The existence lemmas use a **seed set + Lindenbaum** pattern: collect formulas that MUST be in Delta, prove consistency, extend to MCS
- **Temporal compositionality gap** in Task 447 (sorry placeholders) blocks the full domain respects_task proof
- **Recommended approach**: Fix temporal compositionality first, then implement existence lemmas, then extend domain

## Context & Scope

### The Problem

The current `canonical_history` (lines 2223-2241 of Completeness.lean) uses singleton domain:

```lean
def canonical_history (S : CanonicalWorldState) : WorldHistory canonical_frame where
  domain := fun t => t = 0
  ...
```

For the truth lemma, we need bidirectional correspondence at time 0:
- `G phi in S.val` iff `truth_at canonical_model (canonical_history S) 0 h0 (all_future phi)`

But with singleton domain:
- `all_future phi` = `forall (s : T) (hs : tau.domain s), t < s -> truth_at ... phi`
- At t = 0, there are NO times s > 0 in the domain (only 0 is in domain)
- So the quantifier is **vacuously true** - `G phi` is always satisfied

This means:
- **Forward direction** (`G phi in S -> G phi true`): Works, but trivially
- **Backward direction** (`G phi true -> G phi in S`): FAILS - G phi is always "true" even when `G phi not_in S`

### Why Full Domain Is Needed

For the truth lemma to work, we need:
1. If `G phi not_in S`, there must exist some time s > 0 in domain where phi is false
2. If `H phi not_in S`, there must exist some time s < 0 in domain where phi is false

This requires constructing MCSs at times other than 0, related to S via `canonical_task_rel`.

## Findings

### 1. Truth Lemma Requirements Analysis

From Truth.lean (lines 95-102):

```lean
| Formula.all_past phi => forall (s : T) (hs : tau.domain s), s < t -> truth_at M tau s hs phi
| Formula.all_future phi => forall (s : T) (hs : tau.domain s), t < s -> truth_at M tau s hs phi
```

For the truth lemma temporal cases:

**Future case** (`G phi`):
- Forward: `G phi in S` implies `phi` true at all future times (need future times to exist)
- Backward: `G phi true` (phi true at all future times) implies `G phi in S`
  - Contrapositive: `G phi not_in S` implies `G phi false` (phi false at some future time)
  - Requires: existence of a future time where phi is false

**Past case** (`H phi`):
- Same structure, reversed direction

### 2. Existence Lemma Requirements

#### Forward Existence Lemma

**Statement**:
```lean
lemma forward_existence (S : CanonicalWorldState) (d : Duration) (hd : d > 0) :
    exists T : CanonicalWorldState, canonical_task_rel S d T
```

**Proof Strategy**:

1. **Define seed set** `T_seed`:
   ```lean
   T_seed := { phi | G phi in S.val } ∪ { phi | box phi in S.val }
   ```

2. **Prove seed set is consistent**:
   - Assume T_seed is inconsistent
   - Then there exist phi_1, ..., phi_n in T_seed such that `{phi_1, ..., phi_n} derives bot`
   - Each phi_i is either of form `psi` where `G psi in S` or `chi` where `box chi in S`
   - Using deduction theorem and propositional reasoning:
     - `S derives (G phi_1 and ... and G phi_k) -> not (box chi_1 and ... and box chi_m)`
   - This contradicts properties of MCS S (using axioms connecting G and box)

3. **Extend to MCS via Lindenbaum**:
   - `set_lindenbaum T_seed h_consistent` gives us T : CanonicalWorldState with T_seed subseteq T.val

4. **Verify canonical_task_rel S d T**:
   - Modal transfer: `box phi in S -> phi in T_seed subseteq T.val` (by construction)
   - Future transfer (d > 0): `G phi in S -> phi in T_seed subseteq T.val` (by construction)
   - Past transfer: vacuously true (d > 0, not d < 0)

#### Backward Existence Lemma

**Statement**:
```lean
lemma backward_existence (S : CanonicalWorldState) (d : Duration) (hd : d > 0) :
    exists T : CanonicalWorldState, canonical_task_rel T d S
```

**Proof Strategy**:

1. **Define seed set** `T_seed`:
   ```lean
   T_seed := { phi | H phi in S.val } ∪ { phi | box phi in S.val }
   ```

2. **Prove seed set is consistent** (similar reasoning)

3. **Extend to MCS via Lindenbaum**

4. **Verify canonical_task_rel T d S**:
   - Modal transfer: `box phi in T -> phi in S` (need to verify this holds)
   - Future transfer: vacuously true (d > 0 but we need T -> S relation)
   - Past transfer: would need `H phi in T -> phi in S`

**Challenge**: The backward case is more complex because we need:
- T is related to S at positive duration d
- This means: at T (earlier), looking forward by d, we reach S
- For modal transfer: if `box phi in T`, then `phi in S`
- This requires careful axiom analysis

### 3. Key Axioms Required

The existence lemma proofs rely on these TM axioms:

**Modal Axioms**:
- Modal T: `box phi -> phi` (used in canonical_nullity, proven)
- Modal 4: `box phi -> box box phi` (used in compositionality)
- Modal K: `box (phi -> psi) -> (box phi -> box psi)`

**Temporal Axioms**:
- Temporal G-4: `G phi -> G G phi` (G-formulas persist into future)
- Temporal H-4: `H phi -> H H phi` (H-formulas persist into past)
- G-box interaction: Properties connecting box and G

**Critical for Seed Set Consistency**:
- If `{phi | G phi in S} ∪ {psi | box psi in S}` were inconsistent:
  - Some conjunction from this set derives bot
  - By careful propositional manipulation, this would mean S is inconsistent
  - Contradiction since S is MCS

### 4. Temporal Compositionality Gap

From Task 447 (lines 2093-2131 of Completeness.lean), the temporal cases of `canonical_compositionality` have `sorry`:

```lean
-- Part 2: Future transfer when x + y > 0
· intro h_sum_pos phi h_all_future_S
  -- CHALLENGE: The current definition's future_transfer gives us:
  --   x > 0 -> (G psi in S -> psi in T)  [for all psi]
  -- But to compose, we need G phi in T, not just phi in T.
  sorry

-- Part 3: Past transfer when x + y < 0
· intro h_sum_neg phi h_all_past_S
  -- Similar challenge
  sorry
```

**Impact on Full Domain**:

For full domain, `respects_task` requires:
```lean
respects_task := forall (s t : T) (hs : domain s) (ht : domain t),
    s <= t -> F.task_rel (states s hs) (t - s) (states t ht)
```

With full domain over all Duration:
- For s < t (positive duration t - s), need `canonical_task_rel (S_at_s) (t-s) (S_at_t)`
- This requires composing relations from 0 to s and from s to t
- The temporal compositionality gap blocks this

**Resolution Required**: Complete the temporal compositionality proof before implementing full domain.

### 5. Alternative: Domain as Dense Orbit

Instead of full Duration domain, consider a **generated domain**:

```lean
def canonical_domain (S : CanonicalWorldState) : Duration -> Prop :=
  fun t => exists n : Nat, exists d : Duration,
    (d > 0 or d < 0) and t = n * d -- Times reachable from 0
```

This is more tractable but still requires existence lemmas.

**Simpler alternative**: Use Int as canonical domain

```lean
def canonical_history (S : CanonicalWorldState) : WorldHistory canonical_frame where
  domain := fun t => exists n : Int, t = of_int n  -- All integer times
```

But this requires:
1. Embedding `Int` into `Duration`
2. Proving existence lemmas for each integer step

### 6. Literature Review: Standard Approaches

From modal logic literature (Blackburn et al., Goldblatt):

**Standard Canonical Model for Temporal Logic**:

1. **Worlds**: Maximal consistent sets (as we have)

2. **Temporal Ordering**: Define `w R_F v` (w is before v) iff:
   - For all phi: `G phi in w -> phi in v`
   - For all phi: `G phi in w -> G phi in v` (persistence)

3. **Existence Lemma** (for F operator):
   - If `not (G phi) in w`, then there exists v with `w R_F v` and `not phi in v`
   - Proof: Show set `{psi | G psi in w} ∪ {not phi}` is consistent
   - Extend to MCS via Lindenbaum

4. **Key Properties**:
   - The relation R_F is transitive (from G-4 axiom)
   - The relation R_F is serial if logic has `G phi -> F phi` (or similar)

**Adaptation to TM Logic**:

TM logic uses:
- Duration-indexed task relation (not just accessibility)
- Modal box independent of temporal structure
- Three-part canonical_task_rel definition

The standard existence lemma pattern applies but needs adaptation:
- Seed set must include both temporal (G/H) and modal (box) formulas
- Duration parameter affects which direction (past/future) applies

### 7. Proposed Construction for Full Domain

**Step 1: Fix Temporal Compositionality**

Add "temporal persistence" to the task relation or prove it follows from axioms:
```lean
-- G-formulas persist forward
lemma future_persistence (S T : CanonicalWorldState) (d : Duration) (hd : d > 0)
    (hrel : canonical_task_rel S d T) (phi : Formula) :
    G phi in S.val -> G phi in T.val

-- H-formulas persist backward
lemma past_persistence (S T : CanonicalWorldState) (d : Duration) (hd : d > 0)
    (hrel : canonical_task_rel S d T) (phi : Formula) :
    H phi in T.val -> H phi in S.val
```

**Step 2: Implement Existence Lemmas**

```lean
-- Forward extension
lemma forward_extension (S : CanonicalWorldState) :
    forall d > 0, exists T, canonical_task_rel S d T

-- Backward extension
lemma backward_extension (S : CanonicalWorldState) :
    forall d > 0, exists T, canonical_task_rel T d S
```

**Step 3: Construct Full Domain History**

```lean
def canonical_history (S : CanonicalWorldState) : WorldHistory canonical_frame where
  domain := fun _ => True  -- Full domain
  convex := fun _ _ _ _ _ _ _ => trivial
  states := fun t _ =>
    if ht : t >= 0 then
      forward_chain S t  -- Use forward_extension iteratively
    else
      backward_chain S (-t)  -- Use backward_extension iteratively
  respects_task := by
    intros s t hs ht hst
    -- Use compositionality (requires fixing temporal cases)
    sorry  -- Blocked until compositionality is complete
```

**Challenge**: The `states` function construction is non-trivial because:
- We need to pick specific MCSs at each time, not just prove existence
- This likely requires Choice axiom
- The construction must be coherent (same MCS at same time regardless of path)

### 8. Using Classical Choice

The existence lemmas prove `exists T, canonical_task_rel S d T` but don't construct T.

To build `states : Duration -> CanonicalWorldState`, we need Classical.choice:

```lean
noncomputable def forward_witness (S : CanonicalWorldState) (d : Duration) (hd : d > 0) :
    CanonicalWorldState :=
  Classical.choose (forward_extension S d hd)
```

Then construct iteratively or use well-founded recursion.

**Alternative**: Use the Axiom of Dependent Choice for building infinite chains.

## Decisions

1. **Temporal compositionality must be fixed first** - this is a blocker
2. **Existence lemmas use seed set + Lindenbaum pattern** - standard approach
3. **Classical.choice required for states function** - noncomputable but acceptable
4. **Full Duration domain preferred** over integer subsets - more general

## Recommendations

### Implementation Order

1. **Phase 1: Complete Temporal Compositionality** (4-6 hours)
   - Add temporal persistence lemmas (G/H formulas persist through task relation)
   - Complete the sorry cases in canonical_compositionality
   - This may require strengthening canonical_task_rel definition

2. **Phase 2: Implement Existence Lemmas** (6-8 hours)
   - `forward_extension`: Given MCS S and d > 0, construct MCS T with canonical_task_rel S d T
   - `backward_extension`: Given MCS S and d > 0, construct MCS T with canonical_task_rel T d S
   - Both use seed set + consistency + Lindenbaum pattern

3. **Phase 3: Construct Full Domain History** (4-6 hours)
   - Define states function using Classical.choice on existence lemmas
   - Prove convexity (trivial for full domain)
   - Prove respects_task using compositionality

4. **Phase 4: Verify Truth Lemma Compatibility** (2-3 hours)
   - Check that temporal cases of truth lemma now work
   - Ensure witnesses exist when `G phi not_in S` or `H phi not_in S`

### Key Helper Lemmas Needed

```lean
-- Seed set consistency for forward extension
lemma forward_seed_consistent (S : CanonicalWorldState) :
    SetConsistent ({phi | G phi in S.val} ∪ {phi | box phi in S.val})

-- Seed set consistency for backward extension
lemma backward_seed_consistent (S : CanonicalWorldState) :
    SetConsistent ({phi | H phi in S.val} ∪ {phi | box phi in S.val})

-- G-formula persistence (may need new axiom or derive from existing)
lemma set_mcs_all_future_persistence {S : Set Formula} (h : SetMaximalConsistent S)
    (phi : Formula) : G phi in S -> G (G phi) in S

-- H-formula persistence
lemma set_mcs_all_past_persistence {S : Set Formula} (h : SetMaximalConsistent S)
    (phi : Formula) : H phi in S -> H (H phi) in S
```

### Files to Modify

1. `Theories/Bimodal/Metalogic/Completeness.lean`:
   - Add temporal persistence lemmas
   - Complete canonical_compositionality
   - Add existence lemmas
   - Replace singleton canonical_history with full domain version

### Verification Checklist

- [ ] `set_mcs_all_future_all_future` proven (G-4 analog)
- [ ] `set_mcs_all_past_all_past` proven (H-4 analog)
- [ ] `canonical_compositionality` completed (no sorry)
- [ ] `forward_extension` implemented
- [ ] `backward_extension` implemented
- [ ] `canonical_history` updated to full domain
- [ ] `lake build Bimodal.Metalogic.Completeness` succeeds
- [ ] Truth lemma temporal cases work with new history

## Risks & Mitigations

### Risk 1: Temporal Compositionality Harder Than Expected

**Risk**: The canonical_task_rel definition may fundamentally not support compositionality for temporal cases.

**Likelihood**: Medium

**Mitigation**:
- Consider strengthening the definition to include persistence
- Alternative: revise to a relation that composes more naturally
- Worst case: use a different canonical model construction

### Risk 2: Seed Set Consistency Proof Complexity

**Risk**: Proving `forward_seed_consistent` may require complex axiom interactions.

**Likelihood**: Medium

**Mitigation**:
- Start with simpler cases (specific formulas)
- Use proof by contradiction carefully
- May need additional lemmas about axiom interactions

### Risk 3: Choice Axiom Dependencies

**Risk**: Heavy use of Classical.choice may complicate proofs.

**Likelihood**: Low

**Mitigation**:
- Accept noncomputability for metalogic
- Document choice dependencies clearly
- All canonical model proofs in literature use choice

### Risk 4: Coherence of States Function

**Risk**: Different paths to same time might yield different MCSs.

**Likelihood**: Low (by compositionality)

**Mitigation**:
- Use canonical representative selection
- Prove coherence follows from compositionality
- If needed, quotient by extensional equality

## Appendix

### Key Code Locations

- Singleton canonical_history: `Completeness.lean` lines 2223-2241
- canonical_task_rel: `Completeness.lean` lines 2014-2017
- canonical_compositionality: `Completeness.lean` lines 2076-2131
- Truth evaluation: `Truth.lean` lines 95-102
- WorldHistory structure: `WorldHistory.lean` lines 69-97

### References

1. [Modal Logic, Blackburn et al., Chapter 4](https://www.cambridge.org/core/books/modal-logic/F7FE8F7606F871A0BC498A3C12C0EC97) - Canonical Models
2. [Temporal Logic (Stanford Encyclopedia)](https://plato.stanford.edu/entries/logic-temporal/) - Temporal logic overview
3. [Goldblatt, Logics of Time and Computation](https://csli.sites.stanford.edu/publications/csli-lecture-notes/logics-time-and-computation) - Canonical models for temporal logic
4. Task 447 research-001.md - Canonical frame construction
5. Task 448 research-001.md - Singleton domain MVP analysis
6. research-004.md - Relativized completeness approach

### Seed Set Construction Template

```lean
/--
Seed set for forward existence lemma.

Given MCS S and positive duration d, this set contains formulas that MUST
be in any MCS T such that canonical_task_rel S d T holds.
-/
def forward_seed (S : CanonicalWorldState) : Set Formula :=
  {phi | Formula.all_future phi in S.val} ∪
  {phi | Formula.box phi in S.val}

/--
The forward seed set is consistent for any MCS S.

Proof outline:
1. Assume forward_seed S is inconsistent
2. Then exists finite L subseteq forward_seed S with L derives bot
3. Each formula in L is either G-content or box-content from S
4. By propositional manipulation, this implies S derives bot
5. Contradiction with S being MCS
-/
lemma forward_seed_consistent (S : CanonicalWorldState) :
    SetConsistent (forward_seed S) := by
  intro L hL
  -- Proof by contradiction
  by_contra h_incons
  -- ... detailed proof using axiom properties
  sorry
```

## Next Steps

1. Run `/plan 458` to create implementation plan based on this research
2. First implement temporal persistence lemmas
3. Complete canonical_compositionality temporal cases
4. Then implement existence lemmas
5. Finally extend canonical_history to full domain
