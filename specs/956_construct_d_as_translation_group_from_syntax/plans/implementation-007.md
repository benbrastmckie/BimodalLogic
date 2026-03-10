# Implementation Plan: Product Domain Construction (RestrictedQuotient × Q)

- **Task**: 956 - Construct D as translation group from syntax
- **Status**: [NOT STARTED]
- **Effort**: 15-20 hours
- **Dependencies**: None
- **Research Inputs**: research-025.md (product domain solution), research-024.md (seriality axioms)
- **Artifacts**: plans/implementation-007.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true
- **Supersedes**: implementation-006.md (blocked at Phase 5 due to G-closed MCS singleton)

## Overview

This plan implements the **product domain construction** from research-025. Instead of proving `NoMaxOrder` directly on `RestrictedQuotient` (which fails for G-closed MCSes), we construct the temporal domain as:

```
TemporalDomain := RestrictedQuotient × Q
```

with lexicographic ordering. This automatically provides all required properties:
- `LinearOrder` (lexicographic on products)
- `NoMaxOrder` (Q has no max)
- `NoMinOrder` (Q has no min)
- `DenselyOrdered` (Q is dense)
- `Countable` (countable × countable)

### Why This Works

The G-closed MCS blocker arose because `RestrictedQuotient` can be a singleton `{[M₀]}` when the root is G-closed. But `{[M₀]} × Q ≅ Q`, which has all the required properties. The product "bulldozes" singleton quotients into Q.

### Key Insight from Research-025

Truth at `([M], q)` depends ONLY on M, not on q. This means:
- All points `([M], q)` for different q satisfy the same formulas
- The T-axiom `G(φ) → φ` holds at such points (because `([M], q+1)` exists with the same truth)
- **This is NOT a problem** - we don't need T-axiom to fail, we just don't have it as an axiom

## Changes from v006

| v006 | v007 |
|------|------|
| Prove `NoMaxOrder (RestrictedQuotient)` directly | Use `RestrictedQuotient × Q` product |
| Phase 4 (density) on quotient | Density inherited from Q |
| Phase 5 (no endpoints) blocked | Eliminated - Q provides this |
| Phase 6 (Cantor) applies theorem | Eliminated - Q IS the target |
| Complex 12 phases | Simplified 8 phases |

## Implementation Phases

### Phase 0: Verify Prior Progress [NOT STARTED]

- **Dependencies:** None
- **Goal:** Confirm Phase 0 from v006 (seriality axioms) is complete

**Tasks:**
- [ ] Verify seriality axioms in Axioms.lean
- [ ] Verify soundness proofs in Soundness.lean
- [ ] Verify `mcs_has_F_top`, `mcs_has_P_top` work
- [ ] Run `lake build` to confirm

**Timing:** 15 minutes

**Verification:** Build passes, seriality infrastructure working

---

### Phase 1: Define Product Domain [NOT STARTED]

- **Dependencies:** Phase 0
- **Goal:** Define `TemporalDomain := RestrictedQuotient × Q` with lexicographic order

**Design:**
```lean
-- The temporal domain is the product of the restricted quotient with rationals
abbrev TemporalDomain (M₀ : Set Formula) (h_mcs₀ : SetMaximalConsistent M₀) :=
  RestrictedQuotient M₀ h_mcs₀ × ℚ

-- Use lexicographic ordering
instance : LinearOrder (TemporalDomain M₀ h_mcs₀) :=
  Prod.Lex.linearOrder
```

**Mathlib Support:**
- `Prod.Lex` for lexicographic ordering
- `Prod.Lex.linearOrder` for LinearOrder instance
- `Prod.Lex.noMaxOrder` / `noMinOrder` should exist or be derivable

**Tasks:**
- [ ] Create `Theories/Bimodal/Metalogic/Bundle/TemporalDomain.lean`
- [ ] Define `TemporalDomain` as `RestrictedQuotient × Rat`
- [ ] Prove/derive `LinearOrder (TemporalDomain M₀ h_mcs₀)`
- [ ] Check Mathlib for lexicographic order instances

**Timing:** 1 hour

**Files to create:**
- `Theories/Bimodal/Metalogic/Bundle/TemporalDomain.lean` (~50 lines)

**Verification:**
- `lake build` passes
- `LinearOrder` instance available

---

### Phase 2: Prove Product Properties [NOT STARTED]

- **Dependencies:** Phase 1
- **Goal:** Prove NoMaxOrder, NoMinOrder, DenselyOrdered, Countable for product

**Mathematical Argument:**

For `A × Q` with lexicographic ordering where A is any type:
- `NoMaxOrder (A × Q)`: For any `(a, q)`, we have `(a, q) < (a, q+1)`. So no maximum.
- `NoMinOrder (A × Q)`: For any `(a, q)`, we have `(a, q-1) < (a, q)`. So no minimum.
- `DenselyOrdered (A × Q)`: Between `(a, q)` and `(a, q')` with `q < q'`, we have `(a, (q+q')/2)`.
- `Countable (A × Q)`: If A is countable and Q is countable, A × Q is countable.

**Tasks:**
- [ ] Prove or find `NoMaxOrder (TemporalDomain M₀ h_mcs₀)`
- [ ] Prove or find `NoMinOrder (TemporalDomain M₀ h_mcs₀)`
- [ ] Prove or find `DenselyOrdered (TemporalDomain M₀ h_mcs₀)`
- [ ] Prove or find `Countable (TemporalDomain M₀ h_mcs₀)`

**Timing:** 2 hours

**Files to modify:**
- `Theories/Bimodal/Metalogic/Bundle/TemporalDomain.lean` (extend)

**Verification:**
- All four instances available
- `grep -n "\bsorry\b"` returns empty

---

### Phase 3: Define TaskFrame with D = Q [NOT STARTED]

- **Dependencies:** Phase 2
- **Goal:** Build TaskFrame using the product domain

**Design:**
```lean
def CanonicalTaskFrame (M₀ : Set Formula) (h_mcs₀ : SetMaximalConsistent M₀) : TaskFrame ℚ where
  WorldState := TemporalDomain M₀ h_mcs₀
  task_rel w d u := (w.2 + d = u.2) ∧ (w.1 = u.1 ∨ CanonicalRStar w.1 u.1)
  -- Actually simpler: task_rel (m, q) d (m', q') := q' - q = d
  -- The MCS component can vary freely (any m' reachable from m works)
```

**Non-Trivial task_rel:**
```lean
def canonical_task_rel (w : TemporalDomain) (d : ℚ) (u : TemporalDomain) : Prop :=
  u.2 - w.2 = d  -- The rational coordinates differ by exactly d
```

**Properties:**
- **Nullity**: `task_rel (m, q) 0 (m, q)` iff `q - q = 0`. True.
- **Compositionality**: If `q₁ - q₀ = d₁` and `q₂ - q₁ = d₂`, then `q₂ - q₀ = d₁ + d₂`. True.

**Tasks:**
- [ ] Define `canonical_task_rel` on TemporalDomain
- [ ] Prove nullity
- [ ] Prove compositionality
- [ ] Construct `CanonicalTaskFrame : TaskFrame ℚ`

**Timing:** 2 hours

**Files to create:**
- `Theories/Bimodal/Metalogic/Bundle/CanonicalTaskFrame.lean` (~100 lines)

**Verification:**
- TaskFrame constructed
- `grep -n "\bsorry\b"` returns empty

---

### Phase 4: Define Canonical Model and Valuation [NOT STARTED]

- **Dependencies:** Phase 3
- **Goal:** Define truth depending only on MCS component

**Design:**
```lean
-- Truth at (m, q) depends only on m (the MCS quotient class)
def canonical_valuation (p : PropVar) (w : TemporalDomain M₀ h_mcs₀) : Bool :=
  Formula.atom p ∈ (representative w.1).world

def CanonicalModel : TaskModel CanonicalTaskFrame where
  val := canonical_valuation
```

**Tasks:**
- [ ] Define `representative : RestrictedQuotient → RestrictedFragment`
- [ ] Define `canonical_valuation`
- [ ] Define `CanonicalModel`

**Timing:** 1.5 hours

**Files to modify:**
- `Theories/Bimodal/Metalogic/Bundle/CanonicalTaskFrame.lean` (extend)

---

### Phase 5: Define World Histories [NOT STARTED]

- **Dependencies:** Phase 4
- **Goal:** Construct world histories with respects_task

**Design:**
A world history `τ : ℚ → TemporalDomain` with `respects_task`:
```lean
τ t := (m_t, t)  -- The rational coordinate IS the time
```

where `m_t` is some MCS at time t. The simplest: fix one MCS m and use `τ t := (m, t)`.

**respects_task proof:**
`task_rel (τ t₁) d (τ t₂)` requires `t₂ - t₁ = d`, which is exactly our definition.

**Tasks:**
- [ ] Define `CanonicalHistory : WorldHistory CanonicalTaskFrame`
- [ ] Prove `respects_task`
- [ ] Define `CanonicalOmega : Set (WorldHistory CanonicalTaskFrame)`
- [ ] Prove `ShiftClosed CanonicalOmega`

**Timing:** 2 hours

**Files to modify:**
- `Theories/Bimodal/Metalogic/Bundle/CanonicalTaskFrame.lean` (extend)

---

### Phase 6: Prove Truth Lemma [NOT STARTED]

- **Dependencies:** Phase 5
- **Goal:** φ ∈ M iff truth_at(([M], 0), φ)

**Structure:**
- **Atom**: By valuation definition (truth depends on MCS membership)
- **Bot**: By MCS consistency
- **Imp**: By MCS implication property
- **Box**: By modal_forward/modal_backward (existing infrastructure)
- **G/H**: Key case - truth at `([M], q)` for G(φ) requires φ at all `([M'], q')` with `([M], q) < ([M'], q')`. Since truth depends only on M', this reduces to: φ ∈ M' for all M' > M in the quotient, AND φ at `([M], q')` for `q' > q` (which is just φ ∈ M since same MCS).

**Tasks:**
- [ ] Prove truth_lemma for atoms, bot, imp
- [ ] Prove truth_lemma for box using existing infrastructure
- [ ] Prove truth_lemma for G/H using product structure

**Timing:** 3 hours

**Files to create:**
- `Theories/Bimodal/Metalogic/Bundle/ProductTruthLemma.lean` (~200 lines)

---

### Phase 7: Prove Representation and Completeness [NOT STARTED]

- **Dependencies:** Phase 6
- **Goal:** Completeness for TM + DN

**Structure:**
1. Consistent φ → MCS M₀ containing ¬φ (Lindenbaum)
2. Build TemporalDomain from M₀
3. Truth lemma: ¬φ ∈ M₀ iff ¬φ true at ([M₀], 0)
4. So φ is false at ([M₀], 0)
5. CanonicalModel falsifies φ
6. Therefore φ is not valid
7. Contrapositive: valid → provable

**Tasks:**
- [ ] Prove representation theorem
- [ ] Prove weak completeness
- [ ] Prove strong completeness

**Timing:** 2 hours

**Files to create:**
- `Theories/Bimodal/Metalogic/ProductCompleteness.lean` (~100 lines)

---

### Phase 8: Final Verification [NOT STARTED]

- **Dependencies:** Phase 7
- **Goal:** Build verification, sorry audit

**Tasks:**
- [ ] Run full `lake build`
- [ ] `grep -rn "\bsorry\b"` on new files
- [ ] Verify no new axioms
- [ ] Create implementation summary

**Timing:** 1 hour

---

## Testing & Validation

- [ ] `lake build` passes
- [ ] Zero new sorries
- [ ] Zero new axioms
- [ ] TaskFrame with non-trivial task_rel constructed
- [ ] Completeness theorem proven

## Artifacts & Outputs

**New Files (~500 lines total):**
- `Theories/Bimodal/Metalogic/Bundle/TemporalDomain.lean` (~100 lines)
- `Theories/Bimodal/Metalogic/Bundle/CanonicalTaskFrame.lean` (~150 lines)
- `Theories/Bimodal/Metalogic/Bundle/ProductTruthLemma.lean` (~200 lines)
- `Theories/Bimodal/Metalogic/ProductCompleteness.lean` (~50 lines)

**Preserved from v006:**
- Seriality axioms (Phase 0)
- RestrictedFragment.lean (Phases 1-3)

## Comparison with Prior Plans

| Aspect | v006 | v007 |
|--------|------|------|
| Phases | 12 | 8 |
| Hard blockers | 2 (density + G-closed) | 0 |
| Lines estimate | ~795 | ~500 |
| Complexity | High (prove properties on quotient) | Low (inherit from Q) |
| Mathematical cleanliness | Medium | High (standard bulldozing) |

## Risk Assessment

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Mathlib lexicographic order gaps | MEDIUM | LOW | Instances likely exist; can prove manually |
| Truth lemma G/H case complex | MEDIUM | MEDIUM | Follows from truth depending only on MCS |
| TaskFrame respects_task subtle | LOW | LOW | Straightforward from definition |

## Philosophical Note

The product construction `RestrictedQuotient × Q` is the **standard bulldozing technique** (Segerberg 1971, Blackburn et al. 2001) applied to temporal logic. It handles the canonical model's potential reflexivity by "unfolding" each MCS into infinitely many time points.

The key insight: truth depends only on the MCS, not the rational coordinate. This preserves all logical properties while giving the temporal domain the required order-theoretic structure (dense, linear, no endpoints).
