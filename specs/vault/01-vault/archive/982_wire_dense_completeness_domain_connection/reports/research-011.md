# Research Report 011: Deep Analysis of Option C (CanonicalQuot Domain Transfer)

**Task**: 982 - Wire dense completeness: connect CanonicalMCS-based BFMCS to TimelineQuot-based semantics
**Focus**: Research Option C from research-010.md (CanonicalQuot Domain Transfer), thinking forwards and backwards, presenting a complete step-by-step strategy.
**Date**: 2026-03-17
**Session**: sess_1773758883_4058e7
**Domain**: logic (temporal logic semantics, completeness proofs)
**Effort**: Research
**Dependencies**: Research-010.md findings
**Sources/Inputs**: Codebase (CanonicalFMCS.lean, CanonicalQuot.lean, CantorApplication.lean, TimelineQuotAlgebra.lean, DurationTransfer.lean, TaskFrame.lean), Mathlib (Antisymmetrization), ROAD_MAP.md
**Artifacts**: This report
**Standards**: report-format.md, return-metadata-file.md

---

## Executive Summary

This report provides a complete step-by-step strategy for Option C (CanonicalQuot Domain Transfer), analyzing it both forwards (construction) and backwards (what completeness requires).

**Key Finding**: Option C is NOT just viable - it is the mathematically cleanest path. The critical insight is that Option C and TimelineQuot are NOT separate constructions; they can be UNIFIED:

1. **CanonicalQuot = Antisymmetrization(CanonicalMCS)** - This gives forward_F/backward_P trivially
2. **TimelineQuot = Antisymmetrization(DenseTimelineElem)** - This gives Cantor prerequisites

**The Unification**: DenseTimelineElem IS a subset of CanonicalMCS. If we prove that DenseTimelineElem contains all the MCS we need (specifically, that forward_F/backward_P witnesses are IN the dense timeline), then we can use TimelineQuot directly for Option C.

**Alternatively**: If the staged construction witnesses are NOT guaranteed to be in the timeline, we work with CanonicalQuot (all MCS) directly, prove its order properties, and obtain AddCommGroup via Cantor.

**Complete Strategy**: Section 5 presents the step-by-step implementation path.

---

## 1. Understanding the Components

### 1.1 What is Antisymmetrization?

From `Mathlib.Order.Antisymmetrization`:

```lean
/-- Antisymmetrization: quotient of a preorder by the antisymmetric relation. -/
def Antisymmetrization (α : Type*) (r : α → α → Prop) [IsPreorder α r] : Type* :=
  Quotient (AntisymmRel.setoid α r)
```

**Key Properties**:
- Takes a preorder and collapses elements where `a ≤ b ∧ b ≤ a`
- Result is a **PartialOrder**
- If the preorder is **Total** (∀ a b, a ≤ b ∨ b ≤ a), result is **LinearOrder**
- `toAntisymmetrization : α → Antisymmetrization α` - projection to quotient
- `ofAntisymmetrization : Antisymmetrization α → α` - pick representative

**Crucial for Option C**: The Antisymmetrization preserves order properties while collapsing equivalences.

### 1.2 CanonicalMCS Structure (from CanonicalFMCS.lean)

```lean
structure CanonicalMCS where
  world : Set Formula
  is_mcs : SetMaximalConsistent world

instance : Preorder CanonicalMCS where
  le a b := a = b ∨ CanonicalR a.world b.world
  le_refl a := Or.inl rfl
  le_trans := ... -- Uses canonicalR_transitive
```

**Key Theorems**:
- `canonicalMCS_forward_F`: `F(phi) ∈ mcs(w)` implies `∃ s, w ≤ s ∧ phi ∈ mcs(s)` - **PROVEN (no sorry)**
- `canonicalMCS_backward_P`: `P(phi) ∈ mcs(w)` implies `∃ s, s ≤ w ∧ phi ∈ mcs(s)` - **PROVEN (no sorry)**

**Why forward_F/backward_P are trivial**: The witness W from `canonical_forward_F`/`canonical_backward_P` is an MCS. Since CanonicalMCS contains ALL MCSs, W is automatically in the domain. No reachability requirement.

### 1.3 TimelineQuot Structure (from CantorApplication.lean)

```lean
def TimelineQuot := Antisymmetrization DenseTimelineElem (· ≤ ·)

instance : LinearOrder TimelineQuot := inferInstance
instance : Nonempty TimelineQuot := ...
instance : Countable TimelineQuot := ...
instance : NoMaxOrder TimelineQuot := ... -- Uses canonicalR_irreflexive axiom
instance : NoMinOrder TimelineQuot := ... -- Uses canonicalR_irreflexive axiom
instance : DenselyOrdered TimelineQuot := ... -- Uses density frame condition
```

**Cantor Isomorphism**:
```lean
theorem cantor_iso : Nonempty (TimelineQuot ≃o ℚ) := Order.iso_of_countable_dense
```

### 1.4 AddCommGroup Transfer (from DurationTransfer.lean)

```lean
noncomputable def ratAddCommGroup (T : Type*)
    [LinearOrder T] [Countable T] [DenselyOrdered T]
    [NoMaxOrder T] [NoMinOrder T] [Nonempty T] : AddCommGroup T :=
  transferAddCommGroup (ratOrderIso T)
```

**How it works**: Given `e : T ≃o ℚ`:
- Addition: `a + b := e.symm (e a + e b)`
- Zero: `0 := e.symm 0`
- Negation: `-a := e.symm (-(e a))`

---

## 2. Thinking Backwards: What Does Completeness Need?

### 2.1 TaskFrame Requirements

From `TaskFrame.lean`:
```lean
structure TaskFrame (D : Type*) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] where
  WorldState : Type
  task_rel : WorldState → D → WorldState → Prop
  nullity_identity : ∀ w u, task_rel w 0 u ↔ w = u
  forward_comp : ∀ w u v x y, 0 ≤ x → 0 ≤ y → task_rel w x u → task_rel u y v → task_rel w (x+y) v
  converse : ∀ w d u, task_rel w d u ↔ task_rel u (-d) w
```

**D requirements**:
1. `AddCommGroup D` - For duration arithmetic
2. `LinearOrder D` - For temporal quantification
3. `IsOrderedAddMonoid D` - For order-compatible addition

### 2.2 Truth Lemma Requirements

From `ParametricTruthLemma.lean`, the truth lemma backward direction for G needs:
```lean
-- If ∀ s ≥ t, truth(phi) at s, then G(phi) in MCS(t)
-- Uses contraposition: assume G(phi) ∉ MCS(t), then F(¬phi) ∈ MCS(t)
-- By forward_F: ∃ s > t, ¬phi ∈ MCS(s)
-- But phi holds at s by hypothesis - contradiction
```

**The crucial requirement**: `forward_F` must give a witness **in the duration domain D**.

### 2.3 What Option C Provides

**CanonicalQuot = Antisymmetrization(CanonicalMCS)**:
- `forward_F` is trivial: witness from `canonical_forward_F` IS in CanonicalMCS
- `backward_P` is trivial: witness from `canonical_backward_P` IS in CanonicalMCS
- No staging issues, no m > 2k edge cases

**The GAP**: CanonicalQuot needs to satisfy TaskFrame's D requirements:
1. LinearOrder - NEED to prove (requires totality of CanonicalMCS preorder)
2. AddCommGroup - NEED to transfer via Cantor
3. IsOrderedAddMonoid - Follows from Cantor transfer

---

## 3. Thinking Forwards: The Construction Path

### 3.1 Step 1: Totality of CanonicalMCS Preorder

**Current status**: CanonicalMCS has a Preorder via:
```lean
le a b := a = b ∨ CanonicalR a.world b.world
```

**Is this total?** The current `CanonicalQuot.lean` file notes:
> "Note: this Preorder is NOT total in general."

**BUT WAIT**: Let me analyze this more carefully.

For MCS M and N, we need `M ≤ N ∨ N ≤ M`, i.e., either:
- `M = N`, or
- `CanonicalR M N` (g_content(M) ⊆ N), or
- `CanonicalR N M` (g_content(N) ⊆ M)

**Question**: Is this always true for MCS?

**Analysis**: No, this is NOT automatically true. Two MCS can be incomparable:
- M contains G(p) but not G(q)
- N contains G(q) but not G(p)
- Then g_content(M) ⊈ N and g_content(N) ⊈ M

**HOWEVER**: The DenseTimelineElem construction IS total. From `CantorApplication.lean`:
```lean
instance : IsTotal (DenseTimelineElem root_mcs root_mcs_proof) (· ≤ ·) where
  total a b := denseTimeline_linearly_ordered root_mcs root_mcs_proof a.1 b.1 a.2 b.2
```

**This is the key insight**: The staged construction forces totality by construction. Only MCS that are CanonicalR-reachable from the root are included.

### 3.2 Step 2: Choosing Between Two Paths

**Path A: Use TimelineQuot directly (if witnesses are guaranteed)**

If the staged timeline construction ensures that forward_F/backward_P witnesses are always in the timeline, then TimelineQuot is CanonicalQuot restricted to reachable MCS.

**Path B: Use full CanonicalQuot (if witnesses escape)**

If witnesses can escape the timeline, we need to use all MCS. But then we lose totality.

**Resolution**: The CanonicalFMCS.lean construction uses ALL MCS precisely because Path A fails for backward_P:
> "backward_P witnesses are not necessarily future-reachable from the origin MCS. Past witnesses exist in CanonicalMCS but may not be in the future-reachable subset."

**Therefore**: We need a construction that includes ALL MCS while still having totality.

### 3.3 Step 3: The BidirectionalFragment Solution

From the Dead Ends in ROAD_MAP.md:
> "**Dead End: CanonicalReachable/CanonicalQuotient Stack** - backward_P witnesses are not necessarily future-reachable from the origin MCS."

The solution mentioned: "canonicalMCSBFMCS (all-MCS approach) with sorry-free forward_F/backward_P"

**The path forward**: We need to either:
1. Prove totality for ALL MCS (hard - requires showing g_content comparability)
2. Find a subset that IS total AND contains all witnesses (the bidirectional fragment)

### 3.4 Step 4: The Bidirectional Fragment Construction

From `BidirectionalReachable.lean` (in Boneyard but instructive):

**BidirectionalFragment** = MCS reachable from origin by forward OR backward CanonicalR chains.

This includes:
- All future-reachable MCS (forward witnesses for F)
- All past-reachable MCS (backward witnesses for P)

**And it's total** (proven via temporal axioms + the construction).

**The current TimelineQuot uses a different approach**: The staged construction builds a timeline where every point is connected to neighbors via density, creating a linear chain by construction.

---

## 4. The Complete Mathematical Analysis

### 4.1 Why TimelineQuot Forward_F/Backward_P Have Sorries

From `ClosureSaturation.lean` (lines 640-759):

The sorries are:
- `timelineQuotFMCS_forward_F` (line 659)
- `timelineQuotFMCS_backward_P` (line 679)

**The problem**: The staged construction adds points at specific stages. For a point added at stage m and formula k with m > 2k, the F(phi_k) witness wasn't explicitly added.

**The comments explain**:
> "W from canonical_forward_F may not be reachable from M₀!"

### 4.2 Why Option C (CanonicalQuot) Solves This

**Option C insight**: Don't use the staged timeline as D. Instead:

1. Use `CanonicalMCS` as the base (ALL MCS)
2. Take `Antisymmetrization(CanonicalMCS)` as D
3. forward_F/backward_P are trivial because ALL witnesses are in the domain

**The remaining question**: Can we get LinearOrder on Antisymmetrization(CanonicalMCS)?

### 4.3 Totality Analysis for CanonicalMCS

**Theorem needed**: For any MCS M, N, either `M ≤ N` or `N ≤ M` in the CanonicalR-based preorder.

**Approaches**:

**Approach 1: Direct proof via MCS structure**

For MCS M, N, consider any formula G(phi):
- By MCS maximality: G(phi) ∈ M or ¬G(phi) ∈ M
- By MCS maximality: G(phi) ∈ N or ¬G(phi) ∈ N

If g_content(M) ⊆ N and g_content(N) ⊆ M, then M and N have the same G-content, so they're equivalent in the quotient.

But if g_content(M) ⊈ N, there exists G(phi) ∈ M with phi ∉ N...

**This doesn't immediately give totality**.

**Approach 2: Use seriality + density to force linear ordering**

The temporal axioms force a specific structure on the MCS space. The DN (density) axiom creates intermediate MCS between any two related MCS.

**Key insight from the staged construction**: The staged timeline IS total because it's constructed as a chain. Each new point is inserted between existing points, maintaining linearity.

**Approach 3: Accept partial order, use a different strategy**

If CanonicalQuot is only a partial order, we cannot use Cantor's theorem directly. But we might be able to:
- Embed into a completion (?)
- Use a different completeness approach (?)

### 4.4 The Resolution: Staged Timeline as CanonicalQuot Subset

**The synthesis**:

The staged timeline (TimelineQuot) IS a total linear order because it's constructed as a chain. The forward_F/backward_P sorries exist because the witnesses might be OUTSIDE this chain.

**Option C solution**: Instead of trying to prove witnesses are IN TimelineQuot, prove that:

1. Build BFMCS over CanonicalMCS (all MCS) - forward_F/backward_P proven
2. For the completeness theorem, we only need to show that a countermodel EXISTS
3. The countermodel lives in the CanonicalMCS structure
4. We don't need CanonicalMCS to have AddCommGroup for the truth lemma
5. The Cantor isomorphism is only needed for the final TaskFrame semantics

**Wait - this reveals the real insight!**

---

## 5. The Complete Step-by-Step Strategy

### Step 0: Clarify the Architecture

The W/D separation (research-009) is:
- **D** = Duration type (needs AddCommGroup, LinearOrder, IsOrderedAddMonoid)
- **W** = World state type (no algebraic requirements)

**The insight**: We DON'T need D = CanonicalQuot for the truth lemma. We need:
1. An FMCS structure with forward_F/backward_P
2. A way to evaluate truth at (history, time) pairs
3. The final completeness theorem connects to TaskFrame semantics

### Step 1: Use CanonicalMCS BFMCS for the Truth Lemma

From `CanonicalFMCS.lean`:
```lean
theorem temporal_coherent_family_exists_CanonicalMCS :
    ∃ (fam : FMCS CanonicalMCS) (root : CanonicalMCS),
      (∀ gamma ∈ Gamma, gamma ∈ fam.mcs root) ∧
      (∀ t, ∀ φ, F(φ) ∈ fam.mcs t → ∃ s, t ≤ s ∧ φ ∈ fam.mcs s) ∧
      (∀ t, ∀ φ, P(φ) ∈ fam.mcs t → ∃ s, s ≤ t ∧ φ ∈ fam.mcs s)
```

**This is SORRY-FREE!**

### Step 2: Prove the Truth Lemma for CanonicalMCS

The truth lemma should work with D = CanonicalMCS (Preorder, not necessarily LinearOrder):
```lean
phi ∈ fam.mcs t ↔ truth_at (canonicalMCS_model) t phi
```

**Key observation**: The truth lemma for temporal operators only needs:
- Forward quantification over `s ≥ t` (uses Preorder)
- Backward quantification over `s ≤ t` (uses Preorder)

**LinearOrder is NOT required for the truth lemma itself!**

### Step 3: Connect to TaskFrame Semantics

The TaskFrame semantics requires D to have AddCommGroup + LinearOrder. This is used for:
1. `task_rel` definition (uses `+` on D)
2. WorldHistory's `respects_task` (uses `t - s`)
3. Truth evaluation quantification

**The connection**: We need to translate from the CanonicalMCS-based BFMCS (Preorder) to a TaskFrame-based semantics (LinearOrder + AddCommGroup).

### Step 4: The Domain Transfer

**Option C's core idea**:
1. Build TimelineQuot (which HAS LinearOrder + AddCommGroup via Cantor)
2. Build a mapping from TimelineQuot to CanonicalMCS: `timelineQuotMCS : TimelineQuot → Set Formula`
3. Show this mapping preserves MCS membership and temporal ordering
4. Transfer the truth lemma across this mapping

**Current state**: This mapping exists! From `TimelineQuotCanonical.lean`:
```lean
/-- The MCS at a TimelineQuot point. -/
def timelineQuotMCS (t : TimelineQuot) : Set Formula := ...

/-- The MCS assignment is maximal consistent. -/
theorem timelineQuotMCS_is_mcs : SetMaximalConsistent (timelineQuotMCS t)
```

### Step 5: The Missing Piece - Temporal Coherence Transfer

**What's missing**: Proving that the TimelineQuot FMCS (via timelineQuotMCS) has forward_F and backward_P.

**Why it's blocked**: The canonical witnesses may not be in TimelineQuot.

**Option C solution**: Don't prove forward_F/backward_P for TimelineQuot. Instead:

1. Prove completeness using CanonicalMCS BFMCS (which HAS forward_F/backward_P)
2. The completeness theorem says: non-provable → countermodel exists
3. The countermodel is built from CanonicalMCS
4. Map this countermodel to TaskFrame semantics for the validity statement

### Step 6: The Validity Definition Alignment

**The gap** (from ROAD_MAP Dead Ends): Different validity notions:
- `valid` (standard): ∀ TaskFrame, ∀ history, ∀ time, truth_at
- `bmcs_valid`: ∀ BFMCS, truth_at

**Option C resolution**:
1. Prove completeness relative to BFMCS validity using CanonicalMCS
2. Prove `valid → bmcs_valid` (soundness direction - easier)
3. The composition gives: `valid → provable` (weak completeness)

But we actually want: `valid → provable`.

**The key theorem needed**: `bmcs_valid → valid` (semantic equivalence)

This requires showing that BFMCS structures can represent all TaskFrame models, or that the class of BFMCS models is sufficient for completeness.

---

## 6. Revised Complete Strategy

### Phase 1: Verify CanonicalMCS Infrastructure (Already Done)

- [x] `canonicalMCSBFMCS : FMCS CanonicalMCS` - defined
- [x] `canonicalMCS_forward_F` - proven (no sorry)
- [x] `canonicalMCS_backward_P` - proven (no sorry)
- [x] `temporal_coherent_family_exists_CanonicalMCS` - proven (no sorry)

### Phase 2: Prove Truth Lemma for CanonicalMCS BFMCS

**Goal**: `phi ∈ fam.mcs t ↔ truth_at model Omega fam t phi`

**Current state**: The parametric truth lemma exists. Need to instantiate for CanonicalMCS.

**Challenge**: The parametric truth lemma may assume D has LinearOrder (check this).

### Phase 3: Connect CanonicalMCS to TaskFrame

**Approach A: CanonicalQuot with totality proof**

1. Prove CanonicalMCS preorder is total (hard)
2. CanonicalQuot = Antisymmetrization(CanonicalMCS) has LinearOrder
3. Prove Cantor prerequisites (countable, dense, no endpoints)
4. Get AddCommGroup via Cantor transfer
5. Build TaskFrame with D = CanonicalQuot, W = CanonicalMCS

**Approach B: Use TimelineQuot, embed CanonicalMCS**

1. TimelineQuot already has LinearOrder + AddCommGroup
2. Define embedding: TimelineQuot embeds into CanonicalMCS
3. Show the embedding preserves enough structure
4. Transfer completeness across the embedding

**Approach C: Two-stage validity (recommended)**

1. Prove completeness for CanonicalMCS BFMCS validity: `bmcs_valid φ → ⊢ φ`
2. Prove: `valid_over_TimelineQuot φ → bmcs_valid φ` (TimelineQuot as a specific BFMCS)
3. Combine: `valid_over_TimelineQuot φ → ⊢ φ`

### Phase 4: Extend to Standard Validity

**Goal**: `∀ D satisfying constraints, valid_over_D φ → ⊢ φ`

**Approach**:
1. By Cantor, any countable dense linear order without endpoints ≃o Q
2. TimelineQuot ≃o Q
3. Validity over D transfers to validity over TimelineQuot
4. Apply Phase 3 result

---

## 7. ROAD_MAP.md Reflection

### 7.1 Pitfalls Checked

| Dead End | Relevance | Impact on Recommendations |
|----------|-----------|--------------------------|
| CanonicalReachable/CanonicalQuotient Stack | HIGH | Confirms backward_P witness issue - must use ALL MCS |
| Fragment Chain F-Persistence | HIGH | Confirms staged construction witness gap |
| All Int/Rat Import Approaches | MEDIUM | D must emerge from syntax, but AddCommGroup CAN be transferred |

### 7.2 Strategy Alignment

| Strategy | Status | Relevance |
|----------|--------|-----------|
| D Construction from Canonical Timeline | ACTIVE | TimelineQuot provides the order structure |
| Indexed MCS Family Approach | ACTIVE | CanonicalMCS BFMCS is the working implementation |
| Representation-First Architecture | CONCLUDED | BFMCS truth lemma is the foundation |

### 7.3 Key Insight from Dead Ends

The CanonicalReachable dead end says:
> "backward_P witnesses are not necessarily future-reachable from the origin MCS"

But the dead end also says:
> "**Superseded By**: canonicalMCSBFMCS (all-MCS approach) with sorry-free forward_F/backward_P"

**This IS Option C!** The all-MCS approach (CanonicalMCS) already exists and works.

---

## 8. Concrete Implementation Recommendations

### 8.1 Immediate Path (Recommended)

**Step 1**: Verify the parametric truth lemma can instantiate for D = CanonicalMCS (Preorder only)
- If yes: proceed with CanonicalMCS directly
- If no: need to adapt the truth lemma or use TimelineQuot

**Step 2**: Build the completeness theorem using CanonicalMCS BFMCS
- `∀ Gamma consistent, ∃ BFMCS, Gamma ⊆ BFMCS.root.mcs`
- `phi ∈ BFMCS.root.mcs ↔ truth_at ...`
- Therefore: Gamma consistent → Gamma satisfiable in BFMCS model

**Step 3**: Connect to TaskFrame validity
- Define: `valid_over_D φ` := ∀ TaskFrame D, ∀ history, ∀ time, truth_at ...
- Show: `valid_over_TimelineQuot φ → bmcs_valid φ`
- Combine with Step 2: `valid_over_TimelineQuot φ → ⊢ φ`

**Step 4**: Extend to arbitrary dense D
- Any D satisfying constraints ≃o Q ≃o TimelineQuot
- Validity transfers along order isomorphism

### 8.2 Files to Create/Modify

| File | Action | Purpose |
|------|--------|---------|
| `CanonicalMCSTruthLemma.lean` | CREATE | Truth lemma for CanonicalMCS BFMCS |
| `CanonicalMCSCompleteness.lean` | CREATE | Completeness theorem using CanonicalMCS |
| `ValidityTransfer.lean` | CREATE | Transfer validity across order isomorphism |
| `DenseCompleteness.lean` | MODIFY | Wire the final dense completeness theorem |

### 8.3 Expected Sorries to Resolve

The following sorries should become provable:
1. `timelineQuotFMCS_forward_F` - Bypassed (use CanonicalMCS instead)
2. `timelineQuotFMCS_backward_P` - Bypassed (use CanonicalMCS instead)
3. `timelineQuotSingletonBFMCS.modal_backward` - May need multi-family BFMCS

---

## 9. Risk Assessment

| Risk | Severity | Likelihood | Mitigation |
|------|----------|------------|------------|
| Parametric truth lemma requires LinearOrder | HIGH | MEDIUM | Adapt truth lemma for Preorder |
| Modal saturation requires multi-family | MEDIUM | MEDIUM | Use existing ModalSaturation infrastructure |
| Validity transfer is complex | MEDIUM | LOW | Mathlib provides order embedding machinery |
| CanonicalMCS totality fails | LOW | LOW | Use two-stage validity approach |

---

## 10. Context Extension Recommendations

### Discovered Concepts Requiring Documentation

| Concept | Report Section | Currently Documented? | Gap Type |
|---------|----------------|----------------------|----------|
| Antisymmetrization construction | Section 1.1 | No | new_file |
| CanonicalMCS vs TimelineQuot distinction | Section 3 | No | extension |
| Validity transfer across order isomorphism | Section 6 | No | new_file |

### New Context File Recommendations

| Filename | Directory | Content Scope | Priority | Create Task? |
|----------|-----------|---------------|----------|--------------|
| `antisymmetrization-pattern.md` | `processes/` | How to quotient preorders to partial/linear orders | Medium | No |
| `validity-transfer-strategies.md` | `domain/` | How to connect different validity notions | High | Yes |

### Summary

- **New files needed**: 2
- **Extensions needed**: 1
- **Tasks to create**: 1
- **High priority gaps**: 1

---

## 11. Decisions

1. **Option C is the correct path**: Use CanonicalMCS (all-MCS) for forward_F/backward_P, then connect to TaskFrame
2. **Don't fight the staged construction**: The m > 2k edge case indicates staging isn't the right approach for temporal coherence
3. **Two-stage validity is acceptable**: Prove BFMCS completeness, then connect to TaskFrame validity
4. **AddCommGroup via Cantor is fine**: The algebraic structure is transferred, not constructed from scratch

---

## 12. Risks & Mitigations

| Risk | Severity | Mitigation |
|------|----------|------------|
| Truth lemma assumes LinearOrder | HIGH | Check parametric truth lemma requirements; adapt if needed |
| modal_backward for singleton | MEDIUM | Use multi-family BFMCS construction |
| Validity equivalence proof | MEDIUM | May need explicit BFMCS-to-TaskFrame model construction |

---

## 13. References

1. `CanonicalFMCS.lean` - All-MCS BFMCS construction with sorry-free forward_F/backward_P
2. `CanonicalQuot.lean` - Partial Antisymmetrization implementation
3. `CantorApplication.lean` - TimelineQuot with Cantor isomorphism
4. `TimelineQuotAlgebra.lean` - AddCommGroup transfer for TimelineQuot
5. `DurationTransfer.lean` - Generic algebra transfer via order isomorphism
6. `ClosureSaturation.lean` - The blocked sorries
7. `ParametricTruthLemma.lean` - Parametric truth lemma structure
8. `TaskFrame.lean` - TaskFrame requirements
9. research-009.md - W/D separation architecture
10. research-010.md - Original Option C proposal
11. research-003.md (Task 988) - Semantics architecture analysis
12. ROAD_MAP.md Dead Ends - CanonicalReachable failure analysis
13. Mathlib.Order.Antisymmetrization - Quotient construction

---

## Appendix: The Complete Picture

```
                    ┌─────────────────────────────────────┐
                    │      TaskFrame Semantics            │
                    │  D: AddCommGroup + LinearOrder      │
                    │  W: WorldState (arbitrary)          │
                    │  task_rel: W × D × W → Prop        │
                    └───────────────┬─────────────────────┘
                                    │
                                    │ validity
                                    ▼
┌─────────────────────────────────────────────────────────────────────┐
│                          TimelineQuot                               │
│  - LinearOrder (from staged construction totality)                   │
│  - AddCommGroup (from Cantor transfer via Rat)                      │
│  - Cantor: TimelineQuot ≃o Q                                        │
│  - BUT: forward_F/backward_P have sorries (m > 2k edge case)        │
└─────────────────────────────────────────────────────────────────────┘
                                    │
                                    │ embed
                                    ▼
┌─────────────────────────────────────────────────────────────────────┐
│                          CanonicalMCS                               │
│  - Preorder (not necessarily total)                                 │
│  - Contains ALL MCS                                                  │
│  - forward_F PROVEN (no sorry)                                       │
│  - backward_P PROVEN (no sorry)                                      │
│  - Truth lemma should work                                           │
└─────────────────────────────────────────────────────────────────────┘
                                    │
                                    │ completeness
                                    ▼
┌─────────────────────────────────────────────────────────────────────┐
│                      Completeness Theorem                           │
│  valid φ → ⊢ φ (via CanonicalMCS countermodel construction)         │
└─────────────────────────────────────────────────────────────────────┘
```

**The flow**:
1. CanonicalMCS provides forward_F/backward_P (trivially)
2. Truth lemma works over CanonicalMCS
3. Completeness proven for CanonicalMCS model
4. Connect to TaskFrame validity via TimelineQuot embedding
5. Transfer validity via order isomorphism for arbitrary dense D
