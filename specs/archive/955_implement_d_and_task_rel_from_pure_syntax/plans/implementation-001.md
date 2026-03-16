# Implementation Plan: D and task_rel from Pure Syntax

**Task**: 955 - Implement D and task_rel from pure syntax
**Version**: v1
**Created**: 2026-03-06
**Session**: sess_1772822140_51132d
**Status**: [NOT STARTED]
**Estimated Effort**: 25-40 hours
**Dependencies**: Task 951 (BFMCS infrastructure), BidirectionalReachable.lean (sorry-free), CanonicalCompleteness.lean (fragmentFMCS)

---

## Objective

Construct the temporal duration group `D` and a non-trivial `task_rel` entirely from syntactic proof-theoretic data (maximal consistent sets, temporal operators G/H), yielding a canonical `TaskFrame D` where:
- `D` has `[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]`
- `task_rel` encodes genuine temporal accessibility (not `fun _ _ _ => True`)
- `nullity` and `compositionality` are proven from MCS properties and axioms
- The construction is compatible with both discrete and dense extensions of TM

---

## Background: What "From Pure Syntax" Means

The completeness theorem for TM requires constructing a **semantic model** that satisfies a given consistent formula. The model includes a `TaskFrame D` with:

```lean
structure TaskFrame (D : Type*) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] where
  WorldState : Type
  task_rel : WorldState → D → WorldState → Prop
  nullity : ∀ w, task_rel w 0 w
  compositionality : ∀ w u v x y, task_rel w x u → task_rel u y v → task_rel w (x + y) v
```

"From pure syntax" means every component of this structure is derived from:
1. **Maximal Consistent Sets (MCSes)**: The syntactic objects from the proof system
2. **Temporal operators G and H**: Which define `GContent(M) = {φ | G(φ) ∈ M}` and `HContent(M) = {φ | H(φ) ∈ M}`
3. **The CanonicalR relation**: `CanonicalR M₁ M₂ ≡ GContent(M₁) ⊆ M₂` (syntactically defined accessibility)
4. **Axioms of TM**: Propositional, modal S5, temporal (T, 4, A, L, linearity), interaction (MF, TF)

No external mathematical structure (like pre-choosing `D = Int`) should be assumed without justification from the syntax.

---

## The Core Problem

### What the axioms give us

The TM axioms, through the CanonicalR relation on MCSes, yield:
- **Reflexive preorder**: `CanonicalR` is reflexive (via T-axiom: `Gφ → φ`) and transitive (via 4-axiom: `Gφ → GGφ`)
- **Totality within fragments**: The linearity axiom gives `CanonicalR M₁ M₂ ∨ CanonicalR M₂ M₁` for connected MCSes
- **No endpoints**: `F(¬⊥) ∈ M` and `P(¬⊥) ∈ M` for all MCSes (every MCS has strict future/past witnesses)

### What the axioms do NOT give us

- **Group structure on worlds**: There is no natural `(+)`, `(-)`, or `0` on MCSes
- **Metric distance**: The CanonicalR relation is qualitative (ordering), not quantitative (distance)
- **Successor/predecessor inverses**: `quotientPred(quotientSucc(q)) = q` is NOT provable (would require the invalid `Gφ → Hφ`)

### The fundamental tension

`TaskFrame` requires `D` to be an **ordered abelian group**, but the syntax only produces an **ordered set** (the BidirectionalQuotient). The group structure must be constructed or imported.

---

## Analysis of All Approaches

### Approach 1: D = BidirectionalQuotient (Direct)

**Idea**: Use the quotient of MCSes as D itself, defining group operations from successor/predecessor.

**Status**: IMPOSSIBLE

**Why**: The BidirectionalQuotient `Q = Antisymmetrization(BidirectionalFragment, ≤)` has `LinearOrder` but cannot carry `AddCommGroup` because:
- **No natural zero**: Which MCS equivalence class is "zero"? Any choice is arbitrary.
- **No addition**: There is no operation `[M₁] + [M₂]` on equivalence classes of MCSes.
- **No negation**: There is no involution `- : Q → Q`.
- By Holder's theorem, an Archimedean ordered group embeds in ℝ, but we'd need to PROVE Q is such a group.

**References**: research-018 §5.2, research-019 §1

---

### Approach 2: Grothendieck Group Completion

**Idea**: Embed Q into a free abelian group and transport the ordering.

**Status**: BLOCKED

**Why**: The Grothendieck construction `G(M)` applies to commutative monoids `M`, producing their group completion as `M × M / ~`. But Q is only a linearly ordered set, not a monoid. There is no associative binary operation on Q to apply the construction to.

**Mathlib**: `Algebra.GrothendieckAddGroup` exists for `AddCommMonoid`, which Q is not.

**References**: research-018 §5.3, research-019 §1

---

### Approach 3: orderIsoIntOfLinearSuccPredArch

**Idea**: Prove Q satisfies `SuccOrder`, `PredOrder`, `IsSuccArchimedean`, `NoMaxOrder`, `NoMinOrder`, then use Mathlib's `orderIsoIntOfLinearSuccPredArch : Q ≃o ℤ` to transport Int's group structure.

**Status**: BLOCKED (SuccOrder unprovable)

**Why**: `SuccOrder` requires the **coverness** property: `a < b → succ(a) ≤ b`. For `quotientSucc`, this means if `[w₁] < [w₂]`, then `[fragmentGSucc(w₁)] ≤ [w₂]`. But `fragmentGSucc(w₁)` is a Lindenbaum extension of `GContent(w₁)`, and the Lindenbaum extension can introduce G-formulas not in `w₂`, making `GContent(fragmentGSucc(w₁)) ⊄ w₂`.

This is a **mathematical impossibility**, not a proof difficulty: the BidirectionalQuotient may have a dense ordering (where no "next element" exists), making `SuccOrder` semantically false.

**References**: research-019 §2

---

### Approach 4: AddTorsor (G-torsor)

**Idea**: Show Q is a ℤ-torsor (free transitive ℤ-action), then extract the group from the torsor structure.

**Status**: BLOCKED (requires succ/pred inverses)

**Why**: A ℤ-torsor requires the ℤ-action to be **free** (no fixed points) and **transitive** (every element reachable). The action `n · q = quotientSucc^n(q)` for `n ≥ 0` and `quotientPred^|n|(q)` for `n < 0` requires `quotientPred(quotientSucc(q)) = q` for the action to be well-defined. This property requires `Gφ → Hφ`, which is semantically invalid.

**References**: research-019 §3

---

### Approach 5: D = Int with Chain-Based task_rel

**Idea**: Use `D = Int`, define `task_rel w d u := ∃ i, chain(i) = w ∧ chain(i+d) = u` where `chain : ℤ → BidirectionalFragment` is iterated succ/pred.

**Status**: REJECTED (compositionality requires chain injectivity, which requires succ/pred inverse)

**Why**: Compositionality of the existential formulation requires that if `chain(i+x) = u` and `chain(j) = u`, then `i+x = j`. This needs injectivity, which needs `quotientSucc` to be strictly increasing and `quotientPred` to be its inverse.

**References**: research-018 §8-9

---

### Approach 6: D = Int with Sign-Based task_rel

**Idea**: `task_rel w d u := if d ≥ 0 then CanonicalR w u else CanonicalR u w`

**Status**: FAILS (compositionality in mixed-sign case)

**Why**: With `x ≥ 0, y < 0, x+y ≥ 0`: Have `CanonicalR w u` and `CanonicalR v u`. Need `CanonicalR w v`. By totality, either `CanonicalR w v` or `CanonicalR v w`, but we cannot determine which without quantitative information about the "distances" `x` and `y`.

**References**: research-018 §6.2, §7

---

### Approach 7: D = Int with CanonicalR task_rel (Direction-Insensitive) [RECOMMENDED]

**Idea**: `task_rel w _d u := CanonicalR w.val u.val`

**Status**: VIABLE -- the strongest achievable non-trivial task_rel

**Properties**:
- **Nullity**: `CanonicalR w w` by `canonicalR_reflexive` (T-axiom). ✓
- **Compositionality**: `CanonicalR w u ∧ CanonicalR u v → CanonicalR w v` by `canonicalR_transitive` (4-axiom). ✓
- **Non-trivial**: `CanonicalR M₁ M₂` fails when `GContent(M₁) ⊄ M₂` (e.g., cross-fragment MCS pairs). ✓
- **respects_task**: For canonical histories with `s ≤ t`, `CanonicalR (fam.mcs s) (fam.mcs t)` holds by iterated `forward_G`. ✓

**Limitation**: Ignores the duration parameter `d`. The relation says "u is temporally accessible from w" regardless of how long it takes. This is the canonical model analog of an "accessibility relation" in Kripke semantics.

**Justification**: The TM axioms reference only `(≤)` on D, never `(+)` or `0`. The group structure is required by the `TaskFrame` definition (for `WorldHistory` operations), not by the logic's axioms. Since the axioms don't constrain the duration parameter's interaction with accessibility, the canonical task_rel correctly reflects what the syntax determines.

**References**: research-019 §8.2, §9

---

## Recommended Implementation Strategy

### Architecture Overview

```
BidirectionalFragment (linearly ordered MCSes)
         │
         ├── WorldState = CanonicalWorldState B (MCSes from BFMCS)
         │
         ├── D = Int (provides AddCommGroup + LinearOrder + IsOrderedAddMonoid)
         │
         ├── task_rel = CanonicalR (from GContent/HContent inclusion)
         │       nullity: canonicalR_reflexive (T-axiom)
         │       compositionality: canonicalR_transitive (4-axiom)
         │
         └── FMCS Int via chain embedding
                 forward_G/backward_H: from CanonicalR monotonicity
                 forward_F/backward_P: from fragment-level proofs
```

---

## Phase 1: Canonical TaskFrame with Non-Trivial task_rel [NOT STARTED]

**Goal**: Replace the trivial `task_rel := fun _ _ _ => True` in `Representation.lean` with `task_rel := fun w _d u => CanonicalR w.val u.val`.

**Estimated effort**: 3-5 hours

### Step 1.1: Define canonical_task_rel

**File**: `Theories/Bimodal/Metalogic/Bundle/CanonicalConstruction.lean`

```lean
/-- Non-trivial canonical task relation derived from pure syntax.
    `canonical_task_rel w d u` holds iff u is temporally accessible from w,
    defined by GContent inclusion: GContent(w.val) ⊆ u.val.

    The duration parameter `d` is not constrained because the TM axioms
    reference only (≤) on D, never (+) or 0. The group structure on D is
    structural overhead required by TaskFrame, not semantically constrained
    by the axioms. -/
def canonical_task_rel (_B : BFMCS Int)
    (w : CanonicalWorldState _B) (_d : Int) (u : CanonicalWorldState _B) : Prop :=
  CanonicalR w.val u.val
```

### Step 1.2: Prove nullity

```lean
theorem canonical_task_rel_nullity (B : BFMCS Int) (w : CanonicalWorldState B) :
    canonical_task_rel B w 0 w :=
  canonicalR_reflexive w.val w.property
```

**Proof**: Direct from `canonicalR_reflexive`, which follows from the T-axiom (`Gφ → φ`): if `Gφ ∈ M` then `φ ∈ M`, so `GContent(M) ⊆ M`, hence `CanonicalR M M`.

### Step 1.3: Prove compositionality

```lean
theorem canonical_task_rel_compositionality (B : BFMCS Int)
    (w u v : CanonicalWorldState B) (x y : Int)
    (h1 : canonical_task_rel B w x u) (h2 : canonical_task_rel B u y v) :
    canonical_task_rel B w (x + y) v :=
  canonicalR_transitive w.val u.val v.val h1 h2
```

**Proof**: Direct from `canonicalR_transitive`, which follows from the 4-axiom (`Gφ → GGφ`): if `GContent(w) ⊆ u` and `GContent(u) ⊆ v`, then for any `φ` with `Gφ ∈ w`, we have `φ ∈ u` (from first) and `GGφ ∈ w` (by 4-axiom), so `Gφ ∈ u` (from GContent), so `φ ∈ v` (from second). Hence `GContent(w) ⊆ v`.

### Step 1.4: Assemble the canonical TaskFrame

**File**: `Theories/Bimodal/Metalogic/Representation.lean`

Replace:
```lean
def canonicalFrame (B : BFMCS Int) : TaskFrame Int where
  WorldState := CanonicalWorldState B
  task_rel := fun _ _ _ => True
  nullity := fun _ => trivial
  compositionality := fun _ _ _ _ _ _ _ => trivial
```

With:
```lean
def canonicalFrame (B : BFMCS Int) : TaskFrame Int where
  WorldState := CanonicalWorldState B
  task_rel := canonical_task_rel B
  nullity := canonical_task_rel_nullity B
  compositionality := canonical_task_rel_compositionality B
```

### Step 1.5: Update WorldHistory.respects_task proofs

The canonical histories must satisfy `respects_task` with the new task_rel. For `s ≤ t`:

```
task_rel (states s) (t - s) (states t)
  = CanonicalR (fam.mcs s).val (fam.mcs t).val
```

This follows from iterated `forward_G`: for an FMCS `fam`, `s ≤ t` implies `CanonicalR (fam.mcs s) (fam.mcs t)` by the chain of `GContent ⊆` inclusions.

**Verification**: `forward_G` gives `GContent(fam.mcs t) ⊆ fam.mcs (t+1)` for all t, which by induction gives `CanonicalR (fam.mcs s) (fam.mcs t)` for `s ≤ t`.

### Verification Criteria

- [ ] `lake build Theories.Bimodal.Metalogic.Representation` succeeds
- [ ] No new sorries introduced
- [ ] `task_rel` is non-trivial (provably not `fun _ _ _ => True`)
- [ ] All existing soundness proofs still compile

---

## Phase 2: Prove CanonicalR Properties from Axioms [NOT STARTED]

**Goal**: Ensure `canonicalR_reflexive` and `canonicalR_transitive` are sorry-free and clearly trace to TM axioms.

**Estimated effort**: 2-3 hours

### Step 2.1: Verify canonicalR_reflexive is sorry-free

**File**: `Theories/Bimodal/Metalogic/Bundle/CanonicalFrame.lean`

The proof should trace to:
1. T-axiom: `⊢ Gφ → φ` (proven in `Axioms.lean`)
2. MCS closure under modus ponens
3. `Gφ ∈ M → φ ∈ M` for any MCS M

### Step 2.2: Verify canonicalR_transitive is sorry-free

The proof should trace to:
1. 4-axiom: `⊢ Gφ → GGφ` (proven in `Axioms.lean`)
2. If `GContent(M₁) ⊆ M₂` and `GContent(M₂) ⊆ M₃`
3. For `Gφ ∈ M₁`: by 4-axiom, `GGφ ∈ M₁`, so `Gφ ∈ GContent(M₁) ⊆ M₂`, so `φ ∈ GContent(M₂) ⊆ M₃`

### Step 2.3: Document axiom-to-property traceability

Create a reference showing which TM axioms support which task_rel properties:

| task_rel Property | TM Axiom | Proof Path |
|---|---|---|
| Nullity (reflexivity) | T: `Gφ → φ` | `canonicalR_reflexive` |
| Compositionality (transitivity) | 4: `Gφ → GGφ` | `canonicalR_transitive` |
| Totality (within fragment) | Linearity: `Fφ ∧ Fψ → F(φ ∧ ψ) ∨ F(φ ∧ Fψ) ∨ F(Fφ ∧ ψ)` | `bidirectional_totally_ordered` |
| No endpoints | `⊢ F(¬⊥)`, `⊢ P(¬⊥)` | `mcs_has_F_top`, `mcs_has_P_top` |
| HContent symmetry | A: `φ → G(Pφ)` | `canonicalR_reverse_H` |

### Verification Criteria

- [ ] `canonicalR_reflexive` and `canonicalR_transitive` are sorry-free
- [ ] Clear axiom attribution in docstrings
- [ ] No circular dependencies

---

## Phase 3: Canonical WorldHistory Construction [NOT STARTED]

**Goal**: Construct canonical `WorldHistory`s that satisfy `respects_task` with the non-trivial task_rel, using FMCS families.

**Estimated effort**: 5-8 hours

### Step 3.1: Prove iterated forward_G implies CanonicalR

```lean
/-- For an FMCS with forward_G, CanonicalR holds between any s ≤ t. -/
theorem fmcs_canonicalR_monotone {fam : FMCS Int} (s t : Int) (hst : s ≤ t) :
    CanonicalR (fam.mcs s) (fam.mcs t) := by
  -- Induction on (t - s) using forward_G at each step
  sorry -- implementation target
```

### Step 3.2: Construct canonical WorldHistory from FMCS

```lean
def canonicalWorldHistory (B : BFMCS Int) (fam : FMCS Int) :
    WorldHistory (canonicalFrame B) where
  domain := fun _ => True  -- universal domain
  convex := fun _ _ _ _ _ _ _ => trivial
  states := fun t _ht => ⟨fam.mcs t, fam.mcs_maximal t⟩
  respects_task := by
    intros s t _hs _ht hst
    -- Need: canonical_task_rel B (states s) (t - s) (states t)
    -- i.e., CanonicalR (fam.mcs s) (fam.mcs t)
    exact fmcs_canonicalR_monotone s t hst
```

### Step 3.3: Update Omega (shift-closed set of histories)

Verify that `ShiftClosed Ω` still holds with the non-trivial task_rel. The shift-closure condition requires that time-shifted histories remain in Ω. Since the task_rel is direction-insensitive, the shifted histories still satisfy `respects_task`.

### Verification Criteria

- [ ] `canonicalWorldHistory` compiles with no sorries
- [ ] `fmcs_canonicalR_monotone` proven sorry-free
- [ ] Shift-closure proofs updated

---

## Phase 4: Truth Lemma Compatibility [NOT STARTED]

**Goal**: Verify the truth lemma is compatible with the non-trivial task_rel.

**Estimated effort**: 3-5 hours

### Step 4.1: Audit truth lemma for task_rel dependencies

The truth lemma says: `φ ∈ fam.mcs t ↔ truth_at M Ω τ t φ`

Key cases:
- **atom**: Uses `valuation`, not task_rel. No change needed.
- **bot**: Trivial. No change needed.
- **imp**: Inductive. No change needed.
- **box**: Quantifies over histories in Ω. Needs Ω to contain appropriate histories. The construction of Ω (from BFMCS witness families) may need updating.
- **all_past / all_future**: Quantifies over times. Uses `(≤)` on Int. No change needed.

### Step 4.2: Verify box case

The box case requires: for each MCS M' with `BoxContent(M₀) ⊆ M'`, there exists a history in Ω that visits M' at time t. This is the modal saturation condition, handled by the BFMCS witness families.

Each witness family generates a `canonicalWorldHistory` that satisfies `respects_task` with the non-trivial task_rel (Phase 3). So the box case should be unaffected.

### Step 4.3: Verify time_shift_preserves_truth

The time-shift preservation theorem uses the full group structure of D:
```lean
theorem time_shift_preserves_truth ... :
    truth_at M Ω (time_shift σ Δ) x φ ↔ truth_at M Ω σ (x + Δ) φ
```

This theorem does NOT reference task_rel directly. It uses `time_shift` which constructs a new WorldHistory, and the construction must satisfy `respects_task`. With the CanonicalR-based task_rel, `respects_task` for shifted histories follows from the original history's `respects_task` plus CanonicalR transitivity.

### Verification Criteria

- [ ] Truth lemma compiles with non-trivial task_rel
- [ ] Box case: Ω construction compatible
- [ ] Time-shift preservation: respects_task maintained under shift

---

## Phase 5: D Construction Justification and Neutrality [NOT STARTED]

**Goal**: Document and prove that `D = Int` is justified from syntactic considerations and is neutral with respect to future extensions.

**Estimated effort**: 3-5 hours

### Step 5.1: Prove the canonical model witnesses satisfiability

The completeness theorem says: if `φ` is consistent, there exists a TaskFrame model satisfying `φ`. The model uses `D = Int`. This does NOT restrict the logic to discrete time because:

1. **Completeness is existential**: We produce ONE model, not ALL models
2. **Soundness is universal**: Already proven for arbitrary D
3. **Int is a valid witness**: Int satisfies all algebraic requirements

### Step 5.2: Document extensibility to discrete/dense time

| Extension | D Choice | Justification | Blocked? |
|---|---|---|---|
| Base TM | Int | Countable discrete group, neutral witness | No |
| TM + Discreteness axioms | Int | Discreteness forces Z-like time | No |
| TM + Density axioms | Rat | Density forces Q-like time | Separate construction needed |
| TM + Continuity axioms | Real | Continuity forces ℝ-like time | Separate construction needed |

For discrete extensions: Int already works. The discreteness axioms (successor coverness) would provide `SuccOrder` on the BidirectionalQuotient, enabling `orderIsoIntOfLinearSuccPredArch` as a principled justification.

For dense extensions: A separate completeness proof using `D = Rat` would be needed. The CanonicalR-based task_rel generalizes naturally (replace Int with any ordered abelian group).

### Step 5.3: Create formal justification theorem

```lean
/-- The canonical model for TM completeness uses D = Int with a non-trivial
    task relation derived from CanonicalR (GContent inclusion).

    This is justified because:
    1. Int satisfies [AddCommGroup Int] [LinearOrder Int] [IsOrderedAddMonoid Int]
    2. CanonicalR is reflexive (nullity, from T-axiom) and transitive (compositionality, from 4-axiom)
    3. The TM axioms do not constrain the interaction between duration values and accessibility
    4. The canonical model is a satisfiability witness, not a universal model

    For extensions:
    - TM + discreteness: Int remains correct (discreteness axioms validate the choice)
    - TM + density: Replace Int with Rat (separate construction, same task_rel pattern)
-/
theorem canonical_model_justification : ... := sorry -- documentation theorem, not computational
```

### Verification Criteria

- [ ] Extensibility analysis documented
- [ ] No new sorries in computational code
- [ ] Clear separation of structural (D = Int) vs semantic (task_rel = CanonicalR) choices

---

## Phase 6: Integration and Sorry Elimination [NOT STARTED]

**Goal**: Integrate the non-trivial task_rel into the full completeness pipeline, ensuring no regressions.

**Estimated effort**: 8-15 hours

### Step 6.1: Update Representation.lean

Replace the trivial canonicalFrame with the non-trivial version from Phase 1.

### Step 6.2: Update all downstream consumers

Files that reference `canonicalFrame` or `task_rel`:
- `Theories/Bimodal/Metalogic/Representation.lean`
- `Theories/Bimodal/Metalogic/Bundle/CanonicalCompleteness.lean`
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean`
- Any file constructing `WorldHistory` for the canonical model

### Step 6.3: Verify full build

```bash
lake build Theories.Bimodal.Metalogic.Representation
lake build Theories.Bimodal.Metalogic.Soundness
lake build  # full project
```

### Step 6.4: Sorry audit

Count sorries before and after. The non-trivial task_rel should not INTRODUCE any new sorries. It may help ELIMINATE sorries by providing stronger `respects_task` guarantees.

### Verification Criteria

- [ ] `lake build` succeeds
- [ ] Sorry count: no increase
- [ ] All soundness proofs preserved
- [ ] All existing completeness infrastructure preserved

---

## Key Mathematical Insights

### Why CanonicalR IS the task_rel

The task relation `task_rel w d u` is supposed to mean: "starting from world state w, executing a task of duration d can result in world state u." In the canonical model:

- **World states are MCSes**: Complete consistent theories describing possible states of affairs
- **Temporal accessibility is GContent inclusion**: `CanonicalR M₁ M₂` means "everything that MUST be true in the future of M₁ IS true at M₂"
- **This IS a task relation**: It describes which states are reachable from which

The duration parameter `d` is not constrained because the TM axioms encode temporal ordering through G and H operators (which reference `(≤)` on D), not through duration arithmetic (which would reference `(+)` on D).

### Why compositionality holds from 4-axiom

Compositionality says: if you can reach u from w, and v from u, you can reach v from w. In the canonical model:

1. `CanonicalR w u`: Everything necessarily future at w is true at u (GContent(w) ⊆ u)
2. `CanonicalR u v`: Everything necessarily future at u is true at v (GContent(u) ⊆ v)
3. By 4-axiom (`Gφ → GGφ`): If `Gφ ∈ w`, then `GGφ ∈ w`, so `Gφ ∈ GContent(w) ⊆ u`
4. So `Gφ ∈ u`, hence `φ ∈ GContent(u) ⊆ v`
5. Therefore `GContent(w) ⊆ v`, i.e., `CanonicalR w v`

### Why duration-sensitivity is impossible without stronger axioms

For task_rel to be duration-sensitive, we'd need the canonical model to encode "how far apart" two MCSes are. This requires either:
- A **metric** on MCSes (no such notion exists in the logic)
- A **successor/predecessor inverse** (requires the invalid `Gφ → Hφ`)
- A **canonical enumeration** with injectivity (requires the BidirectionalQuotient to have SuccOrder, which it doesn't)

The TM axioms deliberately leave the duration dimension unconstrained, allowing the logic to be extended with either discreteness or density axioms. A duration-sensitive canonical task_rel would pre-commit to one of these.

---

## Risk Analysis

### Risk 1: Non-trivial task_rel breaks existing proofs
**Severity**: MEDIUM
**Likelihood**: LOW (the task_rel was previously trivial, so proofs likely don't depend on specific task_rel values)
**Mitigation**: Phase 6 includes full build verification

### Risk 2: WorldHistory construction fails with stricter respects_task
**Severity**: HIGH
**Likelihood**: MEDIUM (canonical histories need to satisfy CanonicalR between consecutive times)
**Mitigation**: Phase 3 proves `fmcs_canonicalR_monotone` before integration

### Risk 3: User rejects duration-insensitive task_rel
**Severity**: HIGH
**Likelihood**: MEDIUM
**Mitigation**: This plan documents comprehensively why duration-sensitivity is mathematically impossible. The CanonicalR-based task_rel is the strongest achievable construction from pure syntax.

### Risk 4: Box-case truth lemma requires additional Ω constraints
**Severity**: MEDIUM
**Likelihood**: LOW (Ω construction uses BFMCS, which should work with any non-trivial task_rel)
**Mitigation**: Phase 4 audits the truth lemma before integration

---

## Success Criteria

1. **Non-trivial task_rel**: `canonicalFrame.task_rel` is provably not `fun _ _ _ => True`
2. **Zero new sorries**: All new code is sorry-free
3. **Full build passes**: `lake build` succeeds
4. **Axiom traceability**: Every task_rel property traces to specific TM axioms
5. **Documentation**: Clear justification for `D = Int` and the CanonicalR-based task_rel
6. **Extensibility**: Design is compatible with discrete/dense extensions

---

## Appendix: File Map

| File | Role | Changes Expected |
|---|---|---|
| `Metalogic/Bundle/CanonicalConstruction.lean` | canonical_task_rel definition | ADD: new definition + nullity/compositionality proofs |
| `Metalogic/Bundle/CanonicalFrame.lean` | CanonicalR properties | VERIFY: reflexivity/transitivity sorry-free |
| `Metalogic/Representation.lean` | canonicalFrame assembly | MODIFY: use canonical_task_rel |
| `Metalogic/Bundle/CanonicalCompleteness.lean` | Completeness pipeline | MODIFY: WorldHistory construction |
| `Semantics/TaskFrame.lean` | TaskFrame definition | NO CHANGE |
| `Semantics/WorldHistory.lean` | WorldHistory definition | NO CHANGE |
| `Semantics/Truth.lean` | truth_at definition | NO CHANGE |
| `Metalogic/Soundness.lean` | Soundness proof | VERIFY: still compiles |
