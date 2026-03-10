# Implementation Plan: D Construction from Canonical Timeline (v012)

- **Task**: 956 - Construct D as translation group from syntax
- **Status**: [NOT STARTED]
- **Effort**: 14-20 hours
- **Dependencies**: None
- **Research Inputs**: research-030.md (blocker analysis + revised strategy), research-023 (complete pipeline)
- **Artifacts**: plans/implementation-012.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true
- **Supersedes**: implementation-011.md (v011 hit countability blocker; research-030 provides resolution)

## Critical Constraint

**IMPORTING Int OR Rat IS STRICTLY FORBIDDEN.**

Everything must be constructed from pure syntax:
- **D** must emerge from the temporal axioms, not be imported
- **Density** of D must emerge from the density axioms (DN)
- **task_rel** must encode the actual displacement structure, not be trivial

## v012 Corrections from Research-030

**v011 Blockers (from implementation-summary-20260309f.md)**:
1. **Countability**: Full BidirectionalQuotient is uncountable (research-018 confirmed)
2. **Linearity**: Already solved in BidirectionalReachable.lean (not a real blocker)

**v012 Resolution**:
1. **Constructive Countable Fragment**: Build a countable sub-fragment by inductive enumeration of F/P witnesses (research-030 Section 3.2)
2. **NoMax/NoMinOrder**: Already implemented in CanonicalTimeline.lean (Phase marked DONE)
3. **Density**: Attack on constructive fragment (may avoid Lindenbaum collapse)

**Key Insight**: The constructive fragment solves countability AND may help with density, because each witness is chosen to be structurally distinct from predecessors.

## Pipeline Overview (Corrected)

```
[DONE]       Phase 0-1: ROAD_MAP corrections + Boneyard archival
[DONE]       Phase 2A: NoMaxOrder + NoMinOrder (from seriality axioms)
[NOT STARTED] Phase 2B: Constructive Countable Fragment (enumerated witnesses)
[NOT STARTED] Phase 3: DenselyOrdered from DN (THE HARD STEP)
[NOT STARTED] Phase 4: Cantor Isomorphism (1 line once 2B+3 complete)
[NOT STARTED] Phase 5: D and task_rel from Cantor
[NOT STARTED] Phase 6: TaskFrame from syntax
[NOT STARTED] Phase 7: Truth lemma and Completeness
```

## Goals & Non-Goals

**Goals**:
- Construct D from canonical timeline via Cantor
- Build TaskFrame with non-trivial task_rel: `task_rel d w u := e(u) - e(w) = d`
- Complete representation theorem with pure syntax foundations
- Zero sorries in the completeness chain

**Non-Goals**:
- Using D=Int or D=Rat directly (FORBIDDEN)
- Using `task_rel = True` (defeats purpose)
- Working with the full uncountable BidirectionalQuotient

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Density proof blocked (Lindenbaum collapse) | HIGH | MEDIUM | Try on constructive fragment; escape valve to sorry + document |
| Countable fragment loses properties | MEDIUM | LOW | Inductive construction preserves all needed properties |
| Cantor application blocked | LOW | LOW | Mathlib `Order.iso_of_countable_dense` is confirmed |

## Implementation Phases

### Phase 0: ROAD_MAP.md Corrections [COMPLETED]

Completed in v011. Strategy renamed to "D Construction from Canonical Timeline".

---

### Phase 1: Boneyard Archival [COMPLETED]

Completed in v011. Int/Rat approaches archived to `Theories/Bimodal/Boneyard/Task956_IntRat/`.

---

### Phase 2A: NoMaxOrder and NoMinOrder [COMPLETED]

**Status**: Already implemented in `CanonicalTimeline.lean`.

**What exists**:
- `mcs_contains_seriality_future`: every MCS contains F(¬⊥)
- `mcs_contains_seriality_past`: every MCS contains P(¬⊥)
- `mcs_has_canonical_successor`: every MCS has a strict CanonicalR-successor
- `mcs_has_canonical_predecessor`: every MCS has a strict CanonicalR-predecessor

**Verification**:
- `lake build` passes
- NoMaxOrder and NoMinOrder derivable from these lemmas

---

### Phase 2B: Constructive Countable Fragment [NOT STARTED]

- **Dependencies**: None
- **Goal**: Build a countable sub-fragment via inductive enumeration

**Key Insight** (research-030, research-018): The full BidirectionalQuotient is uncountable. We need a *constructive countable fragment* built by enumerating specific Lindenbaum witnesses.

**Construction**:
```lean
-- Layer 0: Just the root
-- Layer (n+1): Add canonical_forward_F witness for each F(φ) ∈ M in Layer n
--              Add canonical_backward_P witness for each P(φ) ∈ M in Layer n
-- ConstructiveFragment = ⋃ n, Layer n
```

**Tasks**:
- [ ] Define `ConstructiveReachable M₀` as inductive type with:
  - `root`: M₀ is reachable
  - `forward_witness`: If M reachable and F(φ) ∈ M, then `lindenbaum_witness_forward M φ` is reachable
  - `backward_witness`: If M reachable and P(φ) ∈ M, then `lindenbaum_witness_backward M φ` is reachable
- [ ] Prove `Countable (ConstructiveFragment M₀)`:
  - Fragment injects into `List (Formula ⊕ Formula)` (witness sequence)
  - Since `Formula` is countable (`Encodable`), fragment is countable
- [ ] Prove fragment inherits LinearOrder from BidirectionalReachable
- [ ] Prove fragment inherits NoMaxOrder and NoMinOrder

**Timing**: 3 hours

**Files to create/modify**:
- `Theories/Bimodal/Metalogic/Canonical/ConstructiveFragment.lean`

**Verification**:
- `Countable (ConstructiveFragment M₀)` proven sorry-free
- `LinearOrder (ConstructiveFragment M₀)` instance available
- `NoMaxOrder` and `NoMinOrder` instances available
- `lake build` passes

---

### Phase 3: DenselyOrdered from DN Axiom [NOT STARTED]

- **Dependencies**: Phase 2B
- **Goal**: Prove the constructive fragment is densely ordered under DN axiom

**THE HARD STEP**: This is the single remaining mathematical difficulty.

**Strategy** (research-030 Section 3.3):
The constructive fragment may avoid the Lindenbaum collapse because:
- Each witness is added for a specific unsatisfied obligation
- This creates a formula φ in the new MCS that distinguishes it from predecessors
- The distinguishing formula prevents quotient identification

**Approach**:
Given [a] < [b] in the fragment quotient:
1. Extract χ ∈ b.world \ GContent(a.world) (they're distinct in quotient)
2. Use `density_of_canonicalR` (already proven in CanonicalTimeline.lean): F(χ) ∈ some M related to a implies intermediate W exists
3. W is added to constructive fragment at some enumeration step
4. Prove [a] < [W] < [b]

**Tasks**:
- [ ] Define `DenselyOrdered (ConstructiveFragment M₀)` instance
- [ ] Prove: given [a] < [b], extract distinguishing formula χ
- [ ] Apply `density_of_canonicalR` to get intermediate MCS W
- [ ] Prove W ∈ ConstructiveFragment (added at some enumeration step)
- [ ] Prove [a] < [W] < [b] (W distinct from both a and b in quotient)

**Timing**: 4 hours (may hit blocker)

**Files to modify**:
- `Theories/Bimodal/Metalogic/Canonical/ConstructiveFragment.lean`

**Verification**:
- `DenselyOrdered (ConstructiveFragment M₀)` proven sorry-free
- `lake build` passes

**Escape Valve**: If blocked after 3 hours:
1. Document the specific obstacle (which step fails, why)
2. Mark Phase 3 as [BLOCKED] with `requires_user_review: true`
3. Optionally: proceed with Phases 4-7 using sorry placeholder to validate rest of pipeline
4. Consider: discreteness path (D=Z) as alternative

---

### Phase 4: Cantor Isomorphism [NOT STARTED]

- **Dependencies**: Phase 2B (Countable), Phase 3 (DenselyOrdered), Phase 2A (NoMax/NoMin)
- **Goal**: Apply Cantor's theorem to get T ≅ Q

**Tasks**:
- [ ] Apply `Order.iso_of_countable_dense`:
  ```lean
  noncomputable def canonicalTimeline_iso_rat :
      ConstructiveFragment M₀ ≃o ℚ :=
    (Order.iso_of_countable_dense (ConstructiveFragment M₀) ℚ).some
  ```
- [ ] Document that Q is DISCOVERED via Cantor, not imported

**Timing**: 0.5 hours (one line once prerequisites proven)

**Files to create**:
- `Theories/Bimodal/Metalogic/Canonical/CantorIsomorphism.lean`

**Verification**:
- `canonicalTimeline_iso_rat` proven
- Uses Mathlib infrastructure only
- `lake build` passes

---

### Phase 5: D and task_rel from Cantor [NOT STARTED]

- **Dependencies**: Phase 4
- **Goal**: Define D as (Q, +) discovered via Cantor; define non-trivial task_rel

**Key Definitions**:
```lean
-- D is discovered via Cantor, not imported
abbrev D := ℚ  -- The content comes from T ≅ Q

-- task_rel captures genuine temporal displacement
def canonical_task_rel (e : ConstructiveFragment M₀ ≃o ℚ)
    (w : ConstructiveFragment M₀) (d : ℚ) (u : ConstructiveFragment M₀) : Prop :=
  e u - e w = d
-- Equivalently: u = e.symm (e w + d)
```

**Tasks**:
- [ ] Define `D := ℚ` with comment explaining discovery via Cantor
- [ ] Define `canonical_task_rel` as position displacement
- [ ] Prove nullity: `canonical_task_rel e w 0 w`
- [ ] Prove compositionality: `canonical_task_rel e w d₁ u → canonical_task_rel e u d₂ v → canonical_task_rel e w (d₁ + d₂) v`
- [ ] Prove order-respecting: `d > 0 → w < canonical_task_rel e w d`
- [ ] Prove determinism: for each (w, d), exactly one u satisfies `canonical_task_rel e w d u`

**Timing**: 2 hours

**Files to create**:
- `Theories/Bimodal/Metalogic/Canonical/DFromSyntax.lean`

**Verification**:
- task_rel is non-trivial (encodes actual displacement)
- All properties proven sorry-free
- `lake build` passes

---

### Phase 6: TaskFrame from Syntax [NOT STARTED]

- **Dependencies**: Phase 5
- **Goal**: Build TaskFrame using syntactically-derived D and task_rel

**Tasks**:
- [ ] Define `SyntacticTaskFrame`:
  ```lean
  def SyntacticTaskFrame : TaskFrame ℚ where
    WorldState := ConstructiveFragment M₀
    task_rel := canonical_task_rel e
    nullity := canonical_task_rel_nullity
    compositionality := canonical_task_rel_compositionality
  ```
- [ ] Verify all TaskFrame axioms satisfied (from Phase 5 proofs)
- [ ] Connect to existing TaskFrame infrastructure

**Timing**: 1.5 hours

**Files to create**:
- `Theories/Bimodal/Metalogic/Canonical/SyntacticTaskFrame.lean`

**Verification**:
- TaskFrame uses D discovered from syntax
- task_rel is actual displacement
- `lake build` passes

---

### Phase 7: Truth Lemma and Completeness [NOT STARTED]

- **Dependencies**: Phase 6
- **Goal**: Prove completeness with purely syntactic foundations

**Tasks**:
- [ ] Define canonical valuation on SyntacticTaskFrame
- [ ] Build canonical histories from ConstructiveFragment
- [ ] Adapt `canonical_truth_lemma` pattern for ConstructiveFragment:
  ```lean
  theorem syntactic_truth_lemma :
      φ ∈ (representative w).world ↔ truth_at SyntacticTaskModel ... t φ
  ```
- [ ] Prove `syntactic_weak_completeness : valid φ → ⊢ φ`
- [ ] Verify NO sorries in completeness proof chain
- [ ] Verify NO Int/Rat imports outside Cantor discovery
- [ ] Create implementation summary

**Timing**: 4 hours

**Files to create/modify**:
- `Theories/Bimodal/Metalogic/Canonical/SyntacticCompleteness.lean`

**Verification**:
- Truth lemma proven sorry-free
- Completeness theorem proven sorry-free
- `lake build` passes
- `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/Canonical/ --include="*.lean"` returns empty

---

## Testing & Validation

- [ ] `lake build` passes at each phase
- [ ] D emerges from Cantor isomorphism applied to constructive fragment
- [ ] task_rel is displacement via Cantor, not trivial
- [ ] No Int/Rat imports in active completeness chain (except via Cantor discovery)
- [ ] Completeness theorem sorry-free with pure syntax foundations

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/Canonical/ConstructiveFragment.lean` - countable fragment
- `Theories/Bimodal/Metalogic/Canonical/CantorIsomorphism.lean` - T ≅ Q
- `Theories/Bimodal/Metalogic/Canonical/DFromSyntax.lean` - D and task_rel
- `Theories/Bimodal/Metalogic/Canonical/SyntacticTaskFrame.lean` - TaskFrame from D
- `Theories/Bimodal/Metalogic/Canonical/SyntacticCompleteness.lean` - completeness
- Implementation summary

## Estimated Total

| Phase | Hours | Status |
|-------|-------|--------|
| Phase 0 (ROAD_MAP corrections) | 1 | COMPLETED |
| Phase 1 (Archival) | 0.5-1.5 | COMPLETED |
| Phase 2A (NoMax/NoMin) | 0 | COMPLETED |
| Phase 2B (Countable fragment) | 3 | NOT STARTED |
| Phase 3 (DenselyOrdered) | 4 | NOT STARTED (hard) |
| Phase 4 (Cantor) | 0.5 | NOT STARTED |
| Phase 5 (D + task_rel) | 2 | NOT STARTED |
| Phase 6 (TaskFrame) | 1.5 | NOT STARTED |
| Phase 7 (Completeness) | 4 | NOT STARTED |
| **Total** | **16.5-18.5** | |

## Rollback/Contingency

**If Phase 3 (density) is blocked**:
1. Document the specific Lindenbaum collapse scenario
2. Consider: implement Phases 4-7 with `sorry` placeholder to validate pipeline
3. Consider: discreteness path (D=Z, TM without DN) as interim
4. Consider: mark density as the single documented sorry

**If Cantor application fails**:
1. Verify Mathlib version has `Order.iso_of_countable_dense`
2. Check all prerequisites (Countable, DenselyOrdered, NoMin, NoMax, Nonempty)

## Appendix: What Changed from v011

**v011 Phase 2** combined all four properties (Linear, Countable, NoEndpoints, Dense) and hit the countability blocker because it assumed the full BidirectionalQuotient.

**v012 Corrections**:
1. **Split Phase 2**:
   - Phase 2A (NoMax/NoMin) is ALREADY DONE
   - Phase 2B (Countable fragment) is new construction
   - Phase 3 (Density) is separate hard step
2. **Constructive fragment**: Solves countability by restricting to enumerated witnesses
3. **Density attack**: May succeed on constructive fragment (Lindenbaum collapse avoidance)
4. **Clear escape valve**: If density blocked, proceed with sorry + documentation

The pipeline structure is the same (Cantor → D → task_rel → TaskFrame → Completeness). The change is HOW we construct the timeline: enumerated witnesses, not arbitrary reachability.
