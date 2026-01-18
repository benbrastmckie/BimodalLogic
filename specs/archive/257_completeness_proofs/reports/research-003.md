# Research Report: Task #257 (Canonical Model Construction Details)

**Task**: Completeness Proofs for TM Bimodal Logic
**Date**: 2026-01-12
**Focus**: Canonical task relation and time construction following the canonical model method

## Summary

This report analyzes how to construct the canonical task relation and times for the TM bimodal logic completeness proof. The key insight is that times are NOT constructed - they are `Int` (inherited from the frame structure). The task relation is constructed syntactically from formula membership in maximal consistent sets, encoding both modal accessibility (S5) and temporal progression.

## Canonical Model Architecture

### Times: No Construction Needed

**Critical Insight**: Times are NOT constructed as part of the canonical model.

The semantic framework already defines:
```lean
-- From Completeness.lean:180
def CanonicalTime : Type := Int
```

This is a **type alias**, not a construction. The canonical frame uses `Int` directly because:

1. `Int` already has the required `AddCommGroup`, `LinearOrder`, and `IsOrderedAddMonoid` instances
2. The semantic definitions in `TaskFrame.lean:83` require these instances:
   ```lean
   structure TaskFrame (T : Type*) [AddCommGroup T] [LinearOrder T] [IsOrderedAddMonoid T]
   ```
3. The temporal operators (`all_past`, `all_future`) quantify over times in the history's domain

**Implementation**: No implementation required. Use `Int` directly.

### World States: Maximal Consistent Sets

From `Completeness.lean:172`:
```lean
def CanonicalWorldState : Type := {Γ : Context // MaximalConsistent Γ}
```

This is a subtype - a context paired with a proof that it's maximal consistent. Construction requires:
1. Proving `lindenbaum` lemma to show such sets exist
2. Using Zorn's lemma on consistent extensions

## Task Relation Construction

### Semantic Requirements

From `TaskFrame.lean:86-102`, the task relation must satisfy:
```lean
task_rel : WorldState → T → WorldState → Prop
nullity : ∀ w, task_rel w 0 w
compositionality : ∀ w u v x y, task_rel w x u → task_rel u y v → task_rel w (x + y) v
```

### Proposed Definition

The canonical task relation should encode:
1. **Modal accessibility** (S5): `□φ ∈ Γ → φ ∈ Δ` for all accessible Δ
2. **Temporal progression**: Future/past formula transfer based on time offset

**Definition (based on Completeness.lean:193-198 sketch)**:
```lean
def canonical_task_rel : CanonicalWorldState → CanonicalTime → CanonicalWorldState → Prop :=
  fun Γ t Δ =>
    -- Modal component: box formulas transfer
    (∀ φ, Formula.box φ ∈ Γ.val → φ ∈ Δ.val) ∧
    -- Temporal future component: when t > 0
    (t > 0 → ∀ φ, Formula.all_future φ ∈ Γ.val → φ ∈ Δ.val) ∧
    -- Temporal past component: when t < 0
    (t < 0 → ∀ φ, Formula.all_past φ ∈ Γ.val → φ ∈ Δ.val)
```

### Nullity Proof Strategy

**Claim**: `∀ Γ : CanonicalWorldState, canonical_task_rel Γ 0 Γ`

**Proof**:
1. **Modal component**: Need `∀ φ, □φ ∈ Γ.val → φ ∈ Γ.val`
   - By Modal T axiom: `□φ → φ`
   - Since Γ is maximal consistent and contains `□φ`, and `Γ ⊢ □φ → φ`
   - By deductive closure (`maximal_consistent_closed`), `φ ∈ Γ.val`

2. **Temporal components**: Vacuously true when `t = 0`
   - `0 > 0` is false, so `(0 > 0 → ...)` is vacuously true
   - `0 < 0` is false, so `(0 < 0 → ...)` is vacuously true

### Compositionality Proof Strategy

**Claim**: `∀ Γ Δ Σ x y, canonical_task_rel Γ x Δ → canonical_task_rel Δ y Σ → canonical_task_rel Γ (x + y) Σ`

**Proof Sketch**:

1. **Modal component**: Need `□φ ∈ Γ.val → φ ∈ Σ.val`
   - From first relation: `□φ ∈ Γ.val → φ ∈ Δ.val`
   - By Modal 4 axiom: `□φ → □□φ`
   - So `□φ ∈ Γ.val → □□φ ∈ Γ.val → □φ ∈ Δ.val` (by deductive closure)
   - From second relation: `□φ ∈ Δ.val → φ ∈ Σ.val`
   - Chain: `□φ ∈ Γ.val → □φ ∈ Δ.val → φ ∈ Σ.val` ✓

2. **Temporal future component** (when `x + y > 0`):

   Case analysis on `x` and `y`:

   a) If `x > 0` and `y > 0`: Both x and y trigger future transfer
      - `Fφ ∈ Γ → φ ∈ Δ` (first relation, since x > 0)
      - By Temp 4 axiom: `Fφ → FFφ`
      - So `Fφ ∈ Γ → Fφ ∈ Δ` (by deductive closure for FFφ → Fφ at Δ)
      - Then `Fφ ∈ Δ → φ ∈ Σ` (second relation, since y > 0)

   b) If `x ≤ 0` and `y > 0` with `x + y > 0`:
      - Need additional lemmas relating past and future formulas

   c) If `x > 0` and `y ≤ 0` with `x + y > 0`:
      - Similar case analysis

   **Challenge**: The cases where signs differ require the interaction axioms (MF, TF) and potentially the temporal A axiom.

3. **Temporal past component** (when `x + y < 0`): Symmetric to future.

### Alternative Definition: Witness-Based

An alternative is a witness-based definition that's closer to standard modal logic treatments:

```lean
def canonical_task_rel_alt : CanonicalWorldState → CanonicalTime → CanonicalWorldState → Prop :=
  fun Γ t Δ =>
    -- For every boxed formula in Γ, its content is in Δ
    (∀ φ, Formula.box φ ∈ Γ.val → φ ∈ Δ.val) ∧
    -- Δ is "reachable" via temporal chain from Γ at offset t
    temporal_chain Γ t Δ
```

Where `temporal_chain` would need to be defined to capture the temporal progression. This is more complex but may make the truth lemma easier.

## Comparison with Mathlib First-Order Logic

Mathlib's `FirstOrder.Language.Theory.IsMaximal` (from search results) provides:

```lean
-- IsMaximal.mem_or_not_mem
T.IsMaximal → ∀ φ, φ ∈ T ∨ ¬φ ∈ T

-- IsMaximal.mem_of_models
T.IsMaximal → T.ModelsBoundedFormula φ → φ ∈ T
```

These properties match what we need:
- `mem_or_not_mem` ↔ `maximal_negation_complete`
- `mem_of_models` ↔ `maximal_consistent_closed` (with semantic completeness)

## Truth Lemma Dependencies

The truth lemma (`φ ∈ Γ.val ↔ truth_at canonical_model (canonical_history Γ) 0 φ`) requires:

### Modal Case (□φ)
From `Truth.lean:100`:
```lean
| Formula.box φ => ∀ (σ : WorldHistory F) (hs : σ.domain t), truth_at M σ t hs φ
```

**Need to prove**: `□φ ∈ Γ.val ↔ ∀ σ (hs : σ.domain 0), truth_at M σ 0 hs φ`

**Forward direction**: Modal saturation
- `□φ ∈ Γ` means φ holds at all accessible worlds
- Need: every history at time 0 corresponds to some Δ with Γ R Δ
- By canonical task relation: if `canonical_task_rel Γ 0 Δ`, then φ ∈ Δ

**Backward direction**: Contrapositive
- If `□φ ∉ Γ`, then `◇¬φ ∈ Γ` (by negation completeness + duality)
- Need to construct a history where ¬φ holds at time 0
- Use Lindenbaum: extend `{¬φ}` to maximal consistent Δ
- Construct history through Δ

### Temporal Cases (Fφ, Pφ)
From `Truth.lean:101-102`:
```lean
| Formula.all_past φ => ∀ (s : T) (hs : τ.domain s), s < t → truth_at M τ s hs φ
| Formula.all_future φ => ∀ (s : T) (hs : τ.domain s), t < s → truth_at M τ s hs φ
```

**Key insight**: The temporal operators quantify over times in the SAME history.

This means the canonical history construction must:
1. Have domain containing all integers (or at least all relevant times)
2. Map each time t to a maximal consistent set Γ_t
3. Satisfy: `task_rel Γ_s (t-s) Γ_t` for all s < t in domain

## Canonical History Construction

### Proposed Structure

```lean
def canonical_history (Γ : CanonicalWorldState) : WorldHistory canonical_frame where
  domain := fun _ => True  -- All times are in domain
  convex := by intros; trivial  -- Trivially convex
  states := fun t _ => ??? -- Map each time to a maximal consistent set
  respects_task := ???
```

### Challenge: State Assignment

The difficult part is defining `states : (t : Int) → True → CanonicalWorldState`.

**Approach 1: Fixed Base State**
Define `states t _ := Γ` for all times. But then `respects_task` requires:
- `canonical_task_rel Γ (t-s) Γ` for all s ≤ t
- This only works if the frame is "reflexive for all durations"
- Our task relation may not satisfy this

**Approach 2: Time-Shifted Sets**
For each time t, construct Γ_t such that:
- Γ_0 = Γ (the base set)
- Γ_t contains "shifted" versions of formulas

This requires defining what "shifted formula" means in the syntactic setting.

**Approach 3: Equivalence Classes**
Use equivalence classes of formulas under temporal equivalence:
- φ ~_t ψ if `Fφ ↔ Fψ` holds at t steps forward
- Each time t gets the equivalence class representing that temporal position

### Simplification for S5 Modal

In S5 modal logic (which our box operator has), all worlds are mutually accessible. This means:
- `□φ ∈ Γ ↔ □φ ∈ Δ` for any maximal consistent Γ, Δ
- Modal formulas are "global" - either true everywhere or false everywhere

This significantly simplifies the modal component of the task relation.

## Recommended Implementation Order

1. **Maximal Consistent Set Properties** (use deduction theorem)
   - `maximal_consistent_closed`
   - `maximal_negation_complete`
   - Modal/temporal saturation lemmas

2. **Lindenbaum's Lemma** (use Zorn from Mathlib)
   - Import `Mathlib.Order.Zorn`
   - Define preorder on consistent extensions
   - Prove chain upper bound property

3. **Task Relation Definition**
   - Define `canonical_task_rel` as proposed above
   - Prove `nullity` using Modal T axiom
   - Prove `compositionality` using Modal 4 and Temporal 4 axioms

4. **Frame Construction**
   - Assemble `canonical_frame : TaskFrame Int`
   - Verify all field types check

5. **History Construction**
   - Define `canonical_history`
   - Address state assignment challenge

6. **Truth Lemma** (most complex)
   - Prove by induction on formula structure
   - Use task relation properties for modal/temporal cases

## Key Dependencies

| Definition | Depends On | Axioms Used |
|------------|------------|-------------|
| `nullity` | `maximal_consistent_closed` | Modal T |
| `compositionality` | `maximal_consistent_closed` | Modal 4, Temp 4, (MF, TF) |
| `truth_lemma` (□ case) | `canonical_task_rel`, `lindenbaum` | Modal K, T, 4, B |
| `truth_lemma` (F case) | `canonical_history`, temporal transfer | Temp K, 4, A, L |

## Risks and Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Task relation too weak for compositionality | High | Add more conditions (witness sets) |
| History state assignment undefined | High | Use fixed base state for MVP |
| Temporal cases require complex induction | Medium | Factor into small lemmas |
| S5 global nature complicates task relation | Medium | Exploit symmetry to simplify |

## Conclusion

The canonical model construction for TM logic:
1. **Times**: Use `Int` directly (no construction)
2. **World States**: Maximal consistent sets via Lindenbaum
3. **Task Relation**: Syntactic definition based on formula transfer
4. **History**: Most challenging - requires careful state assignment

The proposed task relation definition encodes modal accessibility and temporal progression. Nullity follows from Modal T; compositionality requires Modal 4, Temporal 4, and potentially interaction axioms.

## Appendix: Axioms Used in Canonical Model

| Axiom | Formula | Use in Canonical Model |
|-------|---------|------------------------|
| Modal T | `□φ → φ` | Nullity of task relation |
| Modal 4 | `□φ → □□φ` | Compositionality (modal chain) |
| Modal B | `φ → □◇φ` | Backward modal reasoning |
| Modal K | `□(φ→ψ) → (□φ→□ψ)` | Truth lemma modal case |
| Temp K | `F(φ→ψ) → (Fφ→Fψ)` | Temporal distribution |
| Temp 4 | `Fφ → FFφ` | Compositionality (temporal chain) |
| Temp A | `φ → F(Pφ)` | Past-future interaction |
| Temp L | `△φ → F(Pφ)` | Always-future interaction |
| MF | `□φ → □Fφ` | Modal-temporal frame property |
| TF | `□φ → F□φ` | Temporal-modal frame property |

## References

- `Theories/Bimodal/Semantics/TaskFrame.lean` - Frame structure
- `Theories/Bimodal/Semantics/WorldHistory.lean` - History definition
- `Theories/Bimodal/Semantics/Truth.lean` - Truth evaluation
- `Theories/Bimodal/Metalogic/Completeness.lean` - Current completeness infrastructure
- Mathlib `FirstOrder.Language.Theory.IsMaximal` - First-order maximal theory pattern
- Modal Logic (Blackburn et al.), Chapter 4 - Standard canonical model construction
