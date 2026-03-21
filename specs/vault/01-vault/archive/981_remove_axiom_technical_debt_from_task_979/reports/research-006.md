# Research Report: Task #981 - Axiom Elimination Approaches (Math Domain)

**Task**: 981 - remove_axiom_technical_debt_from_task_979
**Started**: 2026-03-16T12:00:00Z
**Completed**: 2026-03-16T14:30:00Z
**Effort**: Deep mathematical analysis (2.5 hours)
**Dependencies**: None (pure research task)
**Sources/Inputs**:
- Codebase: `DiscreteTimeline.lean`, `DiscreteSuccSeed.lean`, `StagedExecution.lean`, `ParametricCanonical.lean`
- Previous research: research-001 through research-005
- Mathlib: `SuccOrder.ofCore`, `SuccOrder.ofLinearWellFoundedLT`, `WellFounded.min`, `zorn_le`, `orderIsoIntOfLinearSuccPredArch`
- Literature: Segerberg (1970), Verbrugge et al., constructive tense logic methods
**Artifacts**:
- This report: `specs/981_remove_axiom_technical_debt_from_task_979/reports/research-006.md`
**Standards**: report-format.md, return-metadata-file.md

---

## Executive Summary

**CRITICAL CONSTRAINT**: Axiom retention is FORBIDDEN. This research identifies mathematically correct paths to ELIMINATE `discrete_Icc_finite_axiom`.

After comprehensive analysis of order-theoretic, algebraic, and construction-based approaches:

1. **Primary Recommendation**: **Incremental/Staged Construction** - Build the discrete timeline incrementally (stage-by-stage) rather than all-at-once, making covering hold BY CONSTRUCTION.

2. **Secondary Recommendation**: **Well-Founded Minimal Successor** - Use `WellFounded.min` on a well-ordering of MCSs to define the successor as the minimal forward-accessible MCS.

3. **Tertiary Recommendation**: **SuccOrder.ofLinearWellFoundedLT** - Prove the relation `<` on `DiscreteTimelineQuot` is well-founded, then use Mathlib's `SuccOrder.ofLinearWellFoundedLT` to derive `SuccOrder` directly.

All three approaches provide ACTIONABLE paths to eliminate the axiom without axiom retention.

---

## The Problem: Covering Property Gap

### Mathematical Statement

The axiom `discrete_Icc_finite_axiom` in `DiscreteTimeline.lean` asserts:
```lean
axiom discrete_Icc_finite_axiom :
    forall (a b : DiscreteTimelineQuot root_mcs root_mcs_proof), (Set.Icc a b).Finite
```

This is needed for `LocallyFiniteOrder`, which enables `SuccOrder` via `LinearLocallyFiniteOrder.succOrder`.

### Root Cause Analysis

The covering property states: For MCS M and constructed successor W, any K with `CanonicalR M K` and `CanonicalR K W` must satisfy `K = M` or `K = W`.

**Why blocking formulas fail** (from research-005):
1. Blocking formulas constrain W (the successor) but not arbitrary intermediate K
2. K exists independently in the canonical model as a full MCS
3. The blocking formulas in W's seed don't retroactively constrain K
4. The gap is STRUCTURAL - blocking formulas encode "what W excludes" but not "what K must include"

### Equivalences

The following are mathematically equivalent:
1. `discrete_Icc_finite_axiom` (interval finiteness)
2. Covering lemma (immediate successors exist)
3. `LocallyFiniteOrder` on `DiscreteTimelineQuot`
4. `WellFoundedLT` on `DiscreteTimelineQuot`

Proving ANY ONE eliminates the axiom.

---

## ROAD_MAP.md Reflection

### Pitfalls Checked

| Dead End | Relevance | Impact on Recommendations |
|----------|-----------|--------------------------|
| Stage-bounding approach | HIGH | Stage-bounding was tried in task 979, proved false - intervals NOT bounded by stages |
| CanonicalReachable/CanonicalQuotient | HIGH | Same structural gap - quotient doesn't help covering |
| Single-History FDSM | MEDIUM | Multi-history required but irrelevant to covering |
| Blocking formula set-level | HIGH | research-005 proved this insufficient |

### Strategy Alignment

| Strategy | Status | Relevance |
|----------|--------|-----------|
| D Construction from Canonical Timeline | ACTIVE | Discrete timeline needs covering for SuccOrder |
| Representation-First Architecture | CONCLUDED | Covering is a corollary need, not primary target |

### Key Lesson from Dead Ends

> "When proofs are hard, consider whether the definition can be restructured to make properties hold BY CONSTRUCTION rather than by proof."
> - Lesson from Original IndexedMCSFamily.construct_indexed_family (ROAD_MAP.md)

This lesson directly applies: make covering hold BY CONSTRUCTION through incremental model building.

---

## Approach 1: Incremental/Staged Construction (PRIMARY)

### Mathematical Foundation

The literature approach (Segerberg/Verbrugge) builds the model INCREMENTALLY:
- At stage 0: Root MCS only
- At stage 2n+1: Add immediate successors/predecessors with blocking formulas
- At stage 2n+2: Extend with F/P witnesses

The covering property holds BY CONSTRUCTION because the immediate successor is DEFINED relative to the partial order at that stage.

### How to Implement in ProofChecker

**Current Structure** (`StagedExecution.lean`):
- `discreteStagedBuild` adds F/P witnesses at each stage
- But the construction is ALL-AT-ONCE: we build all stages, then take union

**Required Change**:
1. Define `discreteStagedTimeline_at_stage n` as the quotient of points up to stage n
2. Define successor AT EACH STAGE: `succ_at_stage n : DiscreteQuot_n -> DiscreteQuot_{n+1}`
3. Prove covering FOR EACH STAGE (trivial by construction - successor is fresh)
4. Take colimit/union to get final `DiscreteTimelineQuot`
5. Show the colimit inherits covering (by "freshness" - no intermediate can sneak in)

### Key Insight

In the incremental construction:
- When we add the successor W of M at stage n+1, there is NO intermediate K
- Because K doesn't exist yet! K would be added at a later stage
- When K is added later, it either:
  - Has `CanonicalR M K` but NOT `CanonicalR K W` (K is "past" W)
  - Has `CanonicalR K W` but NOT `CanonicalR M K` (K is "future" of M via W)
  - Neither (K unrelated to M-W)

The covering property holds because the construction ORDER matters.

### Lean Implementation Sketch

```lean
-- Stage-indexed timeline
def DiscreteTimelineAt (n : Nat) : Type :=
  Antisymmetrization (DiscreteTimelineElem_at_stage n) (· <= ·)

-- Immediate successor at stage n
def immediateSucc_at_stage (n : Nat) (M : DiscreteTimelineAt n) :
    DiscreteTimelineAt (n + 1) :=
  -- Use discreteImmediateSuccSeed, but relative to stage n only
  sorry

-- Covering at each stage (trivial - successor is fresh)
theorem covering_at_stage (n : Nat) (M : DiscreteTimelineAt n)
    (K : DiscreteTimelineAt (n + 1))
    (h_MK : canonicalR_at_stage M K)
    (h_KW : canonicalR_at_stage K (immediateSucc_at_stage n M)) :
    K = M or K = immediateSucc_at_stage n M := by
  -- K is either from stage n (so K = M if comparable) or new at n+1
  sorry

-- Final timeline as colimit
def DiscreteTimeline : Type :=
  colimit (fun n => DiscreteTimelineAt n)

-- Covering lifts to colimit
theorem discreteTimeline_covering :
    forall M K W, CanonicalR M K -> CanonicalR K W -> M.covers W -> K = M or K = W := by
  -- Each element comes from some stage; covering at that stage gives result
  sorry
```

### Complexity Estimate

**Effort**: 16-24 hours
**Risk**: MEDIUM - requires refactoring staged construction significantly
**Confidence**: HIGH - this is the approach that WORKS in the literature

---

## Approach 2: Well-Founded Minimal Successor (SECONDARY)

### Mathematical Foundation

Instead of constructing a specific successor and proving covering, define:
```
succ(M) := min { K : MCS | CanonicalR M K }
```
using a well-ordering on MCSs.

The covering property becomes TRIVIAL: any K with `M < K` has `succ(M) <= K` by minimality.

### Well-Ordering on MCSs

MCSs can be well-ordered via:
1. **Formula enumeration**: MCSs differ on some formula; use lexicographic order on formulas
2. **Ordinal rank**: Assign ordinals to MCSs based on accessibility structure
3. **Choice-based**: Use `WellFounded.min` from classical choice

### Mathlib Infrastructure

```lean
-- From Mathlib.Order.WellFounded:
def WellFounded.min {r : alpha -> alpha -> Prop} (H : WellFounded r)
    (s : Set alpha) (h : s.Nonempty) : alpha

-- Key properties:
theorem WellFounded.min_mem : H.min s h ∈ s
theorem WellFounded.not_lt_min : forall x ∈ s, not (r x (H.min s h))
```

### Implementation Strategy

1. **Define well-ordering on MCSs** via formula enumeration:
   ```lean
   def mcs_lt (M N : Set Formula) : Prop :=
     exists phi, phi ∈ M \ N and (forall psi, psi < phi -> (psi ∈ M <-> psi ∈ N))
   ```

2. **Prove well-foundedness** of `mcs_lt`:
   - Key: any descending chain in MCSs stabilizes
   - Use that formulas are well-ordered (by constructor depth + index)

3. **Define successor as minimum**:
   ```lean
   def minimal_successor (M : Set Formula) (h_mcs : SetMaximalConsistent M) :=
     WellFounded.min mcs_wf { K | CanonicalR M K and K != M } (seriality_gives_strict_successor M h_mcs)
   ```

4. **Prove covering** (immediate from minimality):
   ```lean
   theorem minimal_successor_covers (M K : Set Formula)
       (h_MK : CanonicalR M K) (h_KW : CanonicalR K (minimal_successor M h_M)) :
       K = M or K = minimal_successor M h_M := by
     -- K ∈ { N | CanonicalR M N and N != M }, so minimal_successor M <= K
     -- Combined with h_KW, we get K = minimal_successor M
     sorry
   ```

### Complexity Estimate

**Effort**: 12-16 hours
**Risk**: MEDIUM - requires proving well-foundedness of MCS ordering
**Confidence**: MEDIUM-HIGH - mathematically sound, needs careful formalization

---

## Approach 3: SuccOrder.ofLinearWellFoundedLT (TERTIARY)

### Mathematical Foundation

Mathlib provides:
```lean
def SuccOrder.ofLinearWellFoundedLT [WellFoundedLT alpha] : SuccOrder alpha :=
  ofCore (fun a => if h : (Ioi a).Nonempty then wellFounded_lt.min _ h else a)
    (fun ha _ => by
      rw [not_isMax_iff] at ha
      simp_rw [Set.Nonempty, mem_Ioi, dif_pos ha]
      exact ⟨(wellFounded_lt.min_le · ha), lt_of_lt_of_le (wellFounded_lt.min_mem _ ha)⟩)
    fun _ ha => dif_neg (not_not_intro ha <| not_isMax_iff.mpr ·)
```

If we prove `WellFoundedLT DiscreteTimelineQuot`, Mathlib gives us `SuccOrder` FOR FREE.

### Why WellFoundedLT Should Hold

The discrete timeline without density has:
1. No infinite ascending chains (by discreteness axiom DF)
2. Stage-bounded construction (even if individual intervals aren't stage-bounded)
3. Seriality in both directions (NoMaxOrder, NoMinOrder)

Actually, `WellFoundedLT` is EQUIVALENT to "no infinite strictly ascending sequences". In a discrete timeline:
- DF ensures immediate successors exist
- Starting from any point, iterating `succ` gives a strictly ascending chain
- If WellFoundedLT fails, there's an infinite descending chain
- But DF + transitivity prevents this (each step is "one DF-step")

### Implementation Strategy

1. **Define the discrete order** on `DiscreteTimelineQuot` (already done)
2. **Prove no infinite descending chains**:
   - Key insight: Each MCS in the quotient is at some finite stage of the construction
   - A descending chain must have strictly decreasing stages (contradiction to omega)

   Actually this is the STAGE-BOUNDING approach which was marked as a Dead End!

3. **Alternative**: Use DF axiom directly to prove WellFoundedLT
   - DF says: every non-minimal element has an immediate predecessor
   - This implies well-foundedness of the converse relation
   - Then WellFoundedGT gives WellFoundedLT by duality? (Check Mathlib)

### Complexity Estimate

**Effort**: 8-12 hours IF stage-bounding works; 20+ hours otherwise
**Risk**: HIGH - stage-bounding was declared Dead End in ROAD_MAP.md
**Confidence**: LOW - contradicts previous research findings

---

## Approach 4: Quotient at a Higher Level

### Mathematical Foundation

Instead of taking the quotient AFTER building the full canonical model, quotient AT THE TYPE LEVEL:
- Define `DiscreteTimelineType` as a new type (not a subtype of MCS)
- Define relations on `DiscreteTimelineType` directly
- Prove properties on the type, not as inherited from MCS sets

### Key Insight

The current approach:
```
DiscreteTimelineElem = { p : StagedPoint // p ∈ union }
DiscreteTimelineQuot = Antisymmetrization DiscreteTimelineElem (· <= ·)
```

This inherits all the MCS structure, including the problematic "all MCSs exist a priori".

Alternative:
```
DiscreteTimelineType = quotient of (stage : Nat) x (offset : Nat) by stage-equivalence
```

This is a PRESENTATION of the discrete timeline that doesn't reference MCSs at all!

### Implementation Strategy

1. Define `DiscreteTimelineType` abstractly:
   ```lean
   inductive DiscreteTimelineType where
     | mk (stage : Nat) (branch : Nat) : DiscreteTimelineType
   ```

2. Define ordering:
   ```lean
   def timeline_le (a b : DiscreteTimelineType) : Prop :=
     a.stage <= b.stage and (a.stage = b.stage -> a.branch <= b.branch)
   ```

3. Prove LocallyFiniteOrder directly (trivial - finite stages, finite branches per stage)

4. Build embedding into MCS-based canonical model separately

### Complexity Estimate

**Effort**: 20-30 hours (significant restructuring)
**Risk**: HIGH - requires rethinking the entire architecture
**Confidence**: MEDIUM - mathematically sound but major refactoring

---

## Approach 5: SuccOrder.ofCore with Direct Covering Proof

### Mathematical Foundation

`SuccOrder.ofCore` requires:
```lean
(succ : alpha -> alpha)
(hn : forall {a}, not IsMax a -> forall b, a < b <-> succ a <= b)
(hm : forall a, IsMax a -> succ a = a)
```

The condition `hn` IS the covering property in another form:
- `a < b <-> succ a <= b` means `a < b` implies `succ a` is between `a` and `b`
- If `succ a` is the LEAST element > a, then `succ a <= b` for all `b > a`

### Direct Attack on Covering

The previous research (research-005) showed blocking formulas don't give covering because:
> "The blocking formulas constrain W, not K"

But what if we constrain K DIRECTLY via the DF axiom membership?

**New Insight**: The DF axiom is in ALL MCSs. Use it to constrain intermediate K.

For intermediate K with `CanonicalR M K` and `CanonicalR K W`:
- `g_content(M) ⊆ K` (from `CanonicalR M K`)
- `g_content(K) ⊆ W` (from `CanonicalR K W`)
- DF membership in K creates F(H(phi)) when F(top) ∧ phi ∧ H(phi) holds

The question: Can DF membership in K create a contradiction with K being intermediate?

### Attempt at Direct Proof

Suppose K is strictly between M and W:
1. K != M, so exists delta with delta ∈ K, neg(delta) ∈ M
2. K != W, so exists epsilon with epsilon ∈ K, neg(epsilon) ∈ W (or vice versa)

From DF in M: If `F(top) ∧ phi ∧ H(phi) ∈ M`, then `F(H(phi)) ∈ M`

The issue: DF creates F-formulas, but we need to constrain what's IN K, not what F-witnesses K satisfies.

**Conclusion**: This approach seems blocked by the same structural gap.

### Complexity Estimate

**Effort**: 8-12 hours to explore, likely blocked
**Risk**: HIGH - previous research suggests this is impossible
**Confidence**: LOW - research-005 already analyzed this

---

## Comparative Analysis

| Approach | Effort | Risk | Confidence | Eliminates Axiom? |
|----------|--------|------|------------|-------------------|
| 1. Incremental Construction | 16-24h | MEDIUM | HIGH | YES |
| 2. Well-Founded Minimal Succ | 12-16h | MEDIUM | MEDIUM-HIGH | YES |
| 3. ofLinearWellFoundedLT | 8-20h | HIGH | LOW | YES (if works) |
| 4. Higher-Level Quotient | 20-30h | HIGH | MEDIUM | YES |
| 5. Direct DF Covering | 8-12h | HIGH | LOW | LIKELY NO |

**Recommendation Order**: 1 > 2 > 4 > 3 > 5

---

## Detailed Implementation Plan for Approach 1 (Incremental Construction)

### Phase 1: Stage-Indexed Types (4 hours)

1. Define `DiscreteTimelineElem_at_stage n`:
   ```lean
   def DiscreteTimelineElem_at_stage (n : Nat) : Type :=
     { p : StagedPoint // p ∈ discreteStagedBuild root_mcs root_mcs_proof n }
   ```

2. Define stage-indexed quotient:
   ```lean
   def DiscreteTimelineQuot_at_stage (n : Nat) : Type :=
     Antisymmetrization (DiscreteTimelineElem_at_stage n) (· <= ·)
   ```

3. Prove LinearOrder at each stage (inherit from existing proof)

### Phase 2: Stage Transitions (6 hours)

1. Define embedding `i_{n,n+1} : DiscreteTimelineQuot_at_stage n -> DiscreteTimelineQuot_at_stage (n+1)`
2. Define successor function `succ_at_stage n` that adds the immediate successor
3. Prove the embedding preserves order

### Phase 3: Covering at Each Stage (4 hours)

1. For fresh elements (added at stage n+1), covering is trivial
2. For inherited elements, covering follows from induction
3. Key lemma: `covering_preserved_by_embedding`

### Phase 4: Colimit Construction (6 hours)

1. Define `DiscreteTimeline_colimit` as directed colimit
2. Prove LinearOrder on colimit
3. Show colimit is isomorphic to existing `DiscreteTimelineQuot`

### Phase 5: Transfer Covering to Colimit (4 hours)

1. Elements of colimit come from some stage
2. Covering at that stage implies covering in colimit
3. Prove `LocallyFiniteOrder` from covering + linearity

### Total: 24 hours

---

## Decisions

1. **Axiom retention is FORBIDDEN** - all approaches must eliminate the axiom
2. **Incremental construction is the PRIMARY path** - aligns with literature, highest confidence
3. **Well-founded minimal successor is BACKUP** - less refactoring, mathematically elegant
4. **Previous blocking formula approach is DEAD** - confirmed by research-005
5. **Stage-bounding for WellFoundedLT is RISKY** - marked as Dead End, avoid unless necessary

---

## Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Incremental refactoring breaks existing proofs | MEDIUM | HIGH | Careful interface preservation |
| Well-ordering on MCSs hard to formalize | MEDIUM | MEDIUM | Use classical choice + Mathlib |
| Colimit construction complex | LOW | MEDIUM | Mathlib has colimit infrastructure |
| None of the approaches work | LOW | CRITICAL | Would require axiom documentation (FORBIDDEN) |

---

## Context Extension Recommendations

### Discovered Concepts Requiring Documentation

| Concept | Report Section | Currently Documented? | Gap Type |
|---------|----------------|----------------------|----------|
| Covering property for SuccOrder | Approaches 1-5 | Partial | extension |
| Incremental vs all-at-once construction | Approach 1 | No | new_file |
| WellFounded minimal successor | Approach 2 | No | extension |
| SuccOrder.ofCore usage | Approach 5 | No | extension |

### New Context File Recommendations

| Filename | Directory | Content Scope | Priority | Create Task? |
|----------|-----------|---------------|----------|--------------|
| `incremental-construction.md` | `order-theory/` | Incremental model building vs all-at-once | HIGH | Yes |

**Rationale for new files**:
- `incremental-construction.md`: This is a recurring pattern in modal logic completeness. Documenting the distinction between incremental and all-at-once construction would prevent future dead ends.

### Existing Context File Extensions

| File | Section to Add/Modify | Content to Add | Priority | Create Task? |
|------|----------------------|----------------|----------|--------------|
| N/A | N/A | N/A | N/A | No |

### Summary

- **New files needed**: 1
- **Extensions needed**: 0
- **Tasks to create**: 1 (for context documentation)
- **High priority gaps**: 1

---

## Appendix

### Mathlib Lookup Results

**SuccOrder Construction**:
- `SuccOrder.ofCore`: Direct construction from covering condition
- `SuccOrder.ofLinearWellFoundedLT`: Construction from well-founded `<`
- `LinearLocallyFiniteOrder.succOrder`: Construction from `LocallyFiniteOrder`

**Well-Foundedness**:
- `WellFounded.min`: Minimal element of nonempty set
- `WellFounded.min_mem`: Minimal element is in set
- `WellFounded.not_lt_min`: Nothing in set is below minimum

**Order Isomorphisms**:
- `orderIsoIntOfLinearSuccPredArch`: SuccOrder + PredOrder + IsSuccArchimedean + NoMax + NoMin -> ≃o ℤ

### Literature References

1. **Segerberg (1970)**: Original constructive method for tense logic, uses INCREMENTAL construction
2. **Verbrugge et al.**: "Completeness by construction for tense logics of linear time"
3. **Goldblatt (1992)**: "Logics of Time and Computation" - canonical model constructions

### Web Search Sources

- [Completeness by construction for tense logics of linear time](https://festschriften.illc.uva.nl/D65/verbrugge.pdf)
- [Discrete tense logic with infinitary inference rules](https://link.springer.com/article/10.1007/BF00357842)
- Mathlib Order.SuccPred.Basic documentation
- Mathlib Order.WellFounded documentation
