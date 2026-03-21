# Three-Place Canonical Task Relation: Dense Extension

**Date**: 2026-03-21
**Status**: Research Report / Implementation Proposal
**Companion**: `04_three-place-canonical-task-relation.md` (discrete extension)
**Scope**: Define a syntactically-derived three-place task relation for dense temporal logic (D = Q)

---

## 1. The Dense Setting

### 1.1 The Density Axiom

The dense extension adds a single axiom to the base logic:

```
DN:  GGφ → Gφ        (Sahlqvist universal form)
     equivalently:  Fφ → FFφ   (existential dual)
```

**Frame condition**: DN is valid on a frame iff the temporal order is `DenselyOrdered` — for all `s < t`, there exists `r` with `s < r < t`.

**Soundness proof** (from `Soundness.lean`): Given `GGφ` true at time `t` and any `s > t`, by `DenselyOrdered` there exists `r` with `t < r < s`. Then `GGφ` at `t` gives `Gφ` at `r`, which gives `φ` at `s`. So `Gφ` holds at `t`.

### 1.2 Why the Discrete Approach Fails

The discrete report (`04_three-place-canonical-task-relation.md`) builds on the **Succ** (immediate successor) relation and single-step forcing. In the dense case, this approach is impossible for two independent reasons:

**Reason 1: No immediate successors**. `DenselyOrdered` is incompatible with `SuccOrder`. Between any two distinct points there is always an intermediate, so no element has an "immediate next" element.

**Reason 2: Single-step forcing is vacuous**. The single-step forcing theorem requires `Fφ ∈ u` and `FFφ ∉ u`. But in the dense logic, the DN axiom gives `Fφ → FFφ`, so for any MCS u:

```
Fφ ∈ u  ⟹  FFφ ∈ u     (by DN and deductive closure)
```

The premise `FFφ ∉ u` is never satisfiable. The theorem is vacuously true and useless.

**Conclusion**: The dense three-place task relation requires a fundamentally different construction — one based on **density interpolation** rather than successor induction.

---

## 2. Mathematical Development

### 2.1 The Density Frame Condition (Syntactic)

The central construction for the dense case is the **density frame condition**, proven purely from axioms in `DensityFrameCondition.lean`.

**Theorem** (Density Frame Condition). For MCSs M, M' with `CanonicalR(M, M')` and `¬CanonicalR(M', M)`, there exists an MCS W with:
```
CanonicalR(M, W)  ∧  CanonicalR(W, M')
```

**Proof strategy** (the "double-density trick"):

1. From `¬CanonicalR(M', M)`, extract a **distinguishing formula** δ with `Gδ ∈ M'` but `δ ∉ M`.
2. **Case A** (`Gδ ∉ M`): Then `F(¬δ) ∈ M`. By density axiom DN, `FF(¬δ) ∈ M`. Construct intermediate witness W₁ with `CanonicalR(M, W₁)` and `F(¬δ) ∈ W₁`. Then construct V with `CanonicalR(W₁, V)` and `¬δ ∈ V`. Apply temporal linearity on M, V, M' to extract the required W.
3. **Case B** (`Gδ ∈ M`): If `CanonicalR(M', M')`, take W = M'. Otherwise extract another distinguishing formula and reduce to Case A.

**Key insight**: This theorem is the dense analogue of the discrete successor existence theorem. Where discrete logic provides a *unique immediate next world*, dense logic provides *interpolation between any two related worlds*.

### 2.2 The Dense Preorder and Timeline

The dense canonical timeline is constructed in stages:

**Stage 1**: Build `StagedPoint` — pairs (MCS, stage_number) with a preorder:
```
a ≤ b  ⟺  a.mcs = b.mcs  ∨  CanonicalR(a.mcs, b.mcs)
```

**Stage 2**: Extend with density intermediates via the density frame condition.

**Stage 3**: Form `DenseTimelineElem` — staged points in the dense timeline union.

**Stage 4**: Quotient by antisymmetrization to get `TimelineQuot`:
```
TimelineQuot = Antisymmetrization(DenseTimelineElem, ≤)
```

The antisymmetrization identifies elements with mutual ≤, which (by `canonicalR_irreflexive`) corresponds exactly to MCS equality. The result is a `LinearOrder`.

**Stage 5**: Verify Cantor prerequisites on `TimelineQuot`:
- `Countable`: Staged points are countable (formulas are countable)
- `DenselyOrdered`: From the density frame condition
- `NoMaxOrder`, `NoMinOrder`: From seriality axioms
- `Nonempty`: From the root MCS

**Stage 6**: Apply Cantor's uniqueness theorem:
```
TimelineQuot ≃o ℚ
```

### 2.3 The Three-Place Task Relation (Dense)

In the dense case, the task relation cannot be built inductively from single steps. Instead, it is defined **directly** through the Cantor isomorphism.

**Definition** (Dense Canonical Task Relation). Let `e : TimelineQuot ≃o ℚ` be the Cantor isomorphism. For MCSs u, v represented by timeline elements `tᵤ, tᵥ ∈ TimelineQuot`, and rational duration `q ∈ ℚ`:

```
DenseTask(u, q, v)  ⟺  e(tᵥ) - e(tᵤ) = q
```

Equivalently, using the transferred group structure on `TimelineQuot`:
```
DenseTask(u, q, v)  ⟺  tᵤ + q = tᵥ
```

where addition on `TimelineQuot` is defined by transfer along the Cantor isomorphism:
```
a + b := e⁻¹(e(a) + e(b))
```

This is the **deterministic** task relation from `DurationTransfer.lean`:
```lean
def canonicalTaskRel (w : T) (d : T) (w' : T) : Prop := w + d = w'
```

### 2.4 Alternative: The Parametric Task Relation

The codebase already defines a D-parametric three-place relation in `ParametricCanonical.lean`:

```lean
def parametric_canonical_task_rel (M : WorldState) (d : D) (N : WorldState) : Prop :=
  if d > 0 then CanonicalR M.val N.val
  else if d < 0 then CanonicalR N.val M.val
  else M = N
```

This is **duration-coarse**: all positive durations map to the same relation (CanonicalR), and all negative durations map to the converse. It satisfies the TaskFrame axioms but is maximally non-deterministic — it does not distinguish between short and long tasks.

**The refined dense task relation** (Section 2.3) is **duration-precise**: each rational duration q determines a unique world state. The two are related by:

```
parametric_canonical_task_rel(u, d, v)  ⟹  DenseTask(u, q, v)  for some q with sgn(q) = sgn(d)
```

The parametric version is a necessary stepping stone (used in the truth lemma), while the refined version is the semantic target.

### 2.5 Verification of TaskFrame Axioms

**Theorem** (TaskFrame Compliance for DenseTask). The deterministic task relation satisfies:

**(i) Nullity identity**: `DenseTask(u, 0, v) ↔ u = v`

*Proof*: `tᵤ + 0 = tᵥ ↔ tᵤ = tᵥ ↔ u = v` (since the quotient separates distinct MCSs). ∎

**(ii) Forward compositionality**: If `DenseTask(u, q₁, w)` and `DenseTask(w, q₂, v)` with `q₁, q₂ ≥ 0`, then `DenseTask(u, q₁ + q₂, v)`.

*Proof*: `tᵤ + q₁ = t_w` and `t_w + q₂ = tᵥ`, so `tᵤ + (q₁ + q₂) = tᵥ` by associativity. ∎

**(iii) Converse**: `DenseTask(u, q, v) ↔ DenseTask(v, -q, u)`

*Proof*: `tᵤ + q = tᵥ ↔ tᵥ + (-q) = tᵤ` by group theory. ∎

### 2.6 The Density Interpolation Theorem

This is the dense analogue of the discrete single-step forcing theorem.

**Theorem** (Density Interpolation). For MCSs u, v with `DenseTask(u, q, v)` where `q > 0`, and any `0 < r < q`, there exists an MCS w with `DenseTask(u, r, w)` and `DenseTask(w, q - r, v)`.

*Proof*: By definition, `tᵤ + q = tᵥ` in `TimelineQuot`. Let `t_w = tᵤ + r`. Since `TimelineQuot ≃o ℚ` and `ℚ` is closed under addition, `t_w` is a valid timeline element. Let w be the MCS corresponding to `t_w`. Then:
- `DenseTask(u, r, w)`: `tᵤ + r = t_w` ✓
- `DenseTask(w, q - r, v)`: `t_w + (q - r) = (tᵤ + r) + (q - r) = tᵤ + q = tᵥ` ✓ ∎

**Corollary** (Infinite Subdivision). Any positive-duration task can be subdivided into arbitrarily many sub-tasks of equal rational duration. There is no minimal task duration.

### 2.7 F-Obligation Resolution in Dense Logic

In the dense case, F-obligations behave fundamentally differently from the discrete case:

**No bounded witness distance**. Since `Fφ ∈ u` implies `FFφ ∈ u` (by DN), and `FFFφ ∈ u`, and so on ad infinitum, there is no finite F-nesting bound. Every F-obligation can be witnessed at *any* positive rational distance.

**Density of witnesses**. For any MCS u with `Fφ ∈ u` and any `ε > 0`, there exists an MCS v with `DenseTask(u, q, v)` for some `0 < q < ε` and `φ ∈ v` (provided the formula is satisfiable in the future). Witnesses can be arbitrarily close.

**The truth lemma for F**: In the dense canonical model:
```
Fφ ∈ u  ⟺  ∃ v, ∃ q > 0, DenseTask(u, q, v) ∧ φ ∈ v
```

This follows from `canonical_forward_F` (the existing Lindenbaum witness construction) combined with the timeline embedding. The witness v from `canonical_forward_F` is an MCS with `CanonicalR(u, v)`, which corresponds to some `q > 0` via the Cantor isomorphism.

---

## 3. Comparison: Discrete vs Dense Three-Place Relations

| Aspect | Discrete (`CanonicalTask`) | Dense (`DenseTask`) |
|--------|---------------------------|---------------------|
| Duration type | ℤ (integers) | ℚ (rationals) |
| Atomic building block | `Succ(u, v)` (immediate successor) | Cantor isomorphism `e : TimelineQuot ≃o ℚ` |
| Construction method | Inductive (chain of single steps) | Direct (group operation via isomorphism) |
| Determinism | Non-deterministic (multiple successors) | Deterministic (unique target per duration) |
| Minimal task duration | 1 (single step) | None (arbitrarily small) |
| Interpolation | No (integer gaps) | Yes (density of ℚ) |
| Single-step forcing | Yes (when `FFφ ∉ u`) | N/A (always `FFφ ∈ u` by DN) |
| Witness distance bound | Bounded by F-nesting depth | Unbounded (witnesses at any distance) |
| F-obligation resolution | Step-by-step resolution/deferral | Lindenbaum witness at arbitrary distance |
| Axiom requirements | Base + DF + seriality | Base + DN + seriality |
| Construction pipeline | Seeds → Lindenbaum → Succ chain | Seeds → Lindenbaum → Staged → Quotient → Cantor |

---

## 4. The Elegant Structure

### 4.1 Why the Dense Case is Simpler in One Way

The dense task relation is **deterministic**: given a world u and a duration q, the target world v is uniquely determined (if it exists). This is because the Cantor isomorphism provides a group structure where `v = u + q` is a well-defined operation.

In contrast, the discrete task relation is **non-deterministic**: an MCS u may have multiple successors v₁, v₂, ... satisfying `Succ(u, v)`, and `CanonicalTask(u, 1, v₁)` and `CanonicalTask(u, 1, v₂)` may both hold for different v's.

### 4.2 Why the Dense Case is Harder in Another Way

The dense construction requires **more infrastructure**:
1. The staged timeline construction (inductive stages)
2. Density intermediates at each stage
3. Antisymmetrization to linear order
4. Verification of Cantor prerequisites (4 properties)
5. The Cantor isomorphism itself
6. Group structure transfer along the isomorphism

The discrete case needs only: successor seeds, Lindenbaum extension, and induction on ℤ.

### 4.3 Unified View

Both cases instantiate the same `TaskFrame D` structure:

```lean
structure TaskFrame (D : Type*) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] where
  WorldState : Type
  task_rel : WorldState → D → WorldState → Prop
  nullity_identity : ∀ w u, task_rel w 0 u ↔ w = u
  forward_comp : ∀ w u v x y, 0 ≤ x → 0 ≤ y → task_rel w x u → task_rel u y v → task_rel w (x + y) v
  converse : ∀ w d u, task_rel w d u ↔ task_rel u (-d) w
```

| Component | Discrete (D = ℤ) | Dense (D = ℚ) |
|-----------|------------------|---------------|
| `WorldState` | `CanonicalMCS` | `CanonicalMCS` (same!) |
| `task_rel` | Succ-chain induction | Cantor isomorphism + group addition |
| `nullity_identity` | By definition | By group identity |
| `forward_comp` | Chain concatenation | Associativity of addition |
| `converse` | Definitional flip | Group inverse |

The world states are **identical** — all MCSs. Only the duration type and task relation differ.

---

## 5. Replacing CanonicalR in the Dense Setting

### 5.1 CanonicalR as Positive Reachability

In the dense setting:
```
CanonicalR(u, v)  ⟺  ∃ q > 0, DenseTask(u, q, v)
                  ⟺  e(tᵥ) > e(tᵤ)       (via Cantor isomorphism)
                  ⟺  tᵤ < tᵥ               (in TimelineQuot order)
```

This recovers CanonicalR as "u is strictly before v in the timeline" — precisely the semantic content we want.

### 5.2 Eliminating CanonicalR

With `DenseTask` defined, all uses of CanonicalR can be replaced:

| Current usage | Replacement |
|--------------|-------------|
| `CanonicalR(u, v)` | `∃ q > 0, DenseTask(u, q, v)` |
| `CanonicalR_past(u, v)` | `∃ q > 0, DenseTask(u, -q, v)` |
| `canonical_forward_G` | `∀ q > 0, DenseTask(u, q, v) → Gφ ∈ u → φ ∈ v` |
| `canonical_forward_F` | `Fφ ∈ u → ∃ v q, q > 0 ∧ DenseTask(u, q, v) ∧ φ ∈ v` |
| Preorder `u ≤ v` | `∃ q ≥ 0, DenseTask(u, q, v)` |

### 5.3 What's Gained

1. **Structural match**: The canonical model directly instantiates `TaskFrame ℚ` rather than requiring a separate duration pipeline.

2. **Interpolation for free**: The density interpolation theorem (Section 2.6) is immediate from the group structure, providing arbitrarily fine subdivision of tasks.

3. **Semantic transparency**: The truth conditions become:
   ```
   Gφ ∈ u  ⟺  ∀ v, ∀ q > 0, DenseTask(u, q, v) → φ ∈ v
   Fφ ∈ u  ⟺  ∃ v, ∃ q > 0, DenseTask(u, q, v) ∧ φ ∈ v
   ```
   which is a direct transcription of the semantic definition.

---

## 6. Open Questions

1. **Non-canonicity of the Cantor isomorphism**. The isomorphism `TimelineQuot ≃o ℚ` is non-constructive (Cantor's theorem is classical). Different isomorphisms assign different rational durations to the same MCS pair. Is there a **canonical** choice? This may not matter for completeness (any isomorphism works) but affects the philosophical interpretation of "syntactically-derived" duration.

2. **Interaction with BFMCS bundles**. The dense task relation assigns durations within a single flag (maximal chain). Cross-flag quantification for the box modality needs duration alignment across flags. The current `FlagBFMCS` approach uses a shared preorder — can this be lifted to shared rational durations?

3. **Unification with discrete case**. Can a single definition subsume both cases, parametric in D? The parametric task relation in `ParametricCanonical.lean` achieves this but is duration-coarse. A duration-precise parametric version would need both the Cantor isomorphism (dense) and the successor characterization (discrete) as special cases.

4. **Domain mismatch resolution** (Task 977). The truth lemma is proven for `D = CanonicalMCS` (or `D = Int`), but `valid_dense` quantifies over all `D` with `DenselyOrdered D`. The three-place task relation may help bridge this gap by providing an explicit `TaskFrame ℚ` instantiation directly on the canonical model.

---

## 7. Conclusion

The dense three-place canonical task relation differs fundamentally from the discrete case:

- **Discrete**: Built inductively from a single-step relation `Succ`, with integer durations and bounded witness distances.
- **Dense**: Built holistically via the Cantor isomorphism `TimelineQuot ≃o ℚ`, with rational durations, deterministic target selection, and density interpolation.

Both constructions replace CanonicalR with a strictly more informative relation that directly instantiates the semantic `TaskFrame` structure. The dense version is deterministic (unique target per duration) while the discrete version is non-deterministic (multiple possible successors), reflecting the fundamental difference between dense and discrete temporal orders.

The key mathematical insight: **density eliminates the need for step-by-step construction but requires the full Cantor machinery to assign durations**. Where the discrete case derives duration from syntactic nesting depth (F-count), the dense case derives duration from the order-theoretic structure of the canonical timeline via a classical isomorphism theorem.
