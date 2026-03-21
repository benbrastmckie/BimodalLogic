# Role of the Three-Place Task Relation in Representation Theorems

**Date**: 2026-03-21
**Status**: Research Report
**Companions**: Reports 04 (discrete) and 05 (dense) define the constructions; this report analyzes their role in the completeness/representation pipeline.

---

## 1. The Representation Theorem Pattern

### 1.1 Overall Shape

The completeness theorem for each logic variant takes the **weak completeness** form:

```
valid_X φ  →  ⊢_X φ
```

where X ∈ {base, dense, discrete}. By contrapositive, this is equivalent to:

```
⊬_X φ  →  ∃ countermodel M over D where φ is false
```

The proof constructs an explicit countermodel from the unprovable formula's negation.

### 1.2 Validity Definitions

Each variant quantifies over a different class of temporal duration types D:

| Variant | D constraint | Axioms | Target D |
|---------|-------------|--------|----------|
| **Base** | `AddCommGroup D`, `LinearOrder D`, `IsOrderedAddMonoid D` | 18 base axioms | Any (e.g., ℤ) |
| **Dense** | Base + `DenselyOrdered D`, `Nontrivial D` | Base + DN | ℚ |
| **Discrete** | Base + `SuccOrder D`, `PredOrder D`, `Nontrivial D` | Base + DF, SF, SP | ℤ |

The validity definition universally quantifies over **all** `TaskFrame D`, **all** `TaskModel`, **all** shift-closed history sets, **all** histories, and **all** times. This is the target that the representation theorem must refute.

### 1.3 The Proof Pipeline

```
⊬ φ
  ↓  (consistency of {¬φ})
{¬φ} is consistent
  ↓  (Lindenbaum's lemma)
MCS M₀ with ¬φ ∈ M₀
  ↓  (BFMCS construction)
Bundle B of families of MCSs with modal/temporal coherence
  ↓  (canonical model construction)
TaskFrame D + TaskModel + WorldHistories + Omega
  ↓  (truth lemma)
¬φ ∈ M₀  ⟺  ¬truth_at(canonical_model, history₀, t₀, φ)
  ↓  (shift closure)
countermodel in shift-closed Omega
  ↓  (instantiation)
∃ D, ∃ frame, ∃ model, ∃ Omega, ... ¬truth_at(M, Omega, τ, t, φ)
  ↓  (negation of validity)
¬valid_X φ
```

---

## 2. Where the Three-Place Task Relation Enters

### 2.1 The Central Problem: TaskFrame Instantiation

The representation theorem must produce a concrete `TaskFrame D`:

```lean
structure TaskFrame (D : Type*) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] where
  WorldState : Type
  task_rel : WorldState → D → WorldState → Prop
  nullity_identity : ∀ w u, task_rel w 0 u ↔ w = u
  forward_comp : ∀ w u v x y, 0 ≤ x → 0 ≤ y → task_rel w x u → task_rel u y v → task_rel w (x + y) v
  converse : ∀ w d u, task_rel w d u ↔ task_rel u (-d) w
```

The `task_rel` field is exactly a **three-place relation** `W → D → W → Prop`. The representation theorem must instantiate this from pure syntax.

### 2.2 Current Approach: Duration-Coarse Parametric Relation

The codebase currently uses a **duration-coarse** instantiation:

```lean
def parametric_canonical_task_rel (M : WorldState) (d : D) (N : WorldState) : Prop :=
  if d > 0 then CanonicalR M.val N.val      -- forward: g_content(M) ⊆ N
  else if d < 0 then CanonicalR N.val M.val  -- backward: converse
  else M = N                                  -- identity
```

This collapses all positive durations to the same relation (CanonicalR) and all negative durations to its converse. It satisfies the TaskFrame axioms but discards duration information.

**Problem**: This relation is maximally non-deterministic. For any `d₁, d₂ > 0`, the sets `{(u,v) | task_rel u d₁ v}` and `{(u,v) | task_rel u d₂ v}` are identical. The duration parameter is semantically vacuous beyond its sign.

### 2.3 Proposed Approach: Duration-Precise Relations

The three-place canonical task relations from reports 04 and 05 provide **duration-precise** instantiations:

**Discrete** (from report 04):
```
CanonicalTask(u, 0, v)      ⟺  u = v
CanonicalTask(u, n+1, v)    ⟺  ∃ w, Succ(u, w) ∧ CanonicalTask(w, n, v)
CanonicalTask(u, -(n+1), v) ⟺  CanonicalTask(v, n+1, u)
```

**Dense** (from report 05):
```
DenseTask(u, q, v)  ⟺  e(tᵥ) - e(tᵤ) = q
```
where `e : TimelineQuot ≃o ℚ` is the Cantor isomorphism.

---

## 3. Role in Each Logic's Representation Theorem

### 3.1 Base Logic (D generic)

**Current status**: Complete (sorry-free) using the parametric duration-coarse relation.

**Role of three-place relation**: **Not needed** for the base case. The parametric relation suffices because `valid` quantifies over all D and all frames — the duration-coarse frame is one valid instantiation, and finding ¬φ there refutes validity.

**Why it works**: The base validity definition makes no assumptions about D beyond ordered abelian group. The duration-coarse relation is a legitimate `TaskFrame D` for any D. The truth lemma works because temporal quantification (`G φ` = all future, `F φ` = some future) cares only about the sign of the duration, not its magnitude.

### 3.2 Dense Logic (D densely ordered)

**Current status**: All components proven except final wiring (Task 977 domain mismatch).

**The problem**: `valid_dense` quantifies over all D with `DenselyOrdered D`. The countermodel must live in some specific dense D — canonically, ℚ. But the truth lemma is proven for the parametric canonical model over generic D, while the `DenselyOrdered` instance lives on `TimelineQuot`.

**Role of the dense three-place relation**:

The `DenseTask` relation serves as the **bridge** between the syntactic canonical model and the semantic target:

```
MCS (syntax)  →  TimelineQuot (order theory)  →  ℚ (semantics)
     CanonicalR        Cantor isomorphism          DenseTask
```

Specifically:

1. **TaskFrame instantiation**: `DenseTask` provides a `TaskFrame ℚ` where `task_rel = canonicalTaskRel` (deterministic: `w + d = w'`). This frame has `DenselyOrdered ℚ` automatically.

2. **Truth lemma connection**: The truth lemma says `φ ∈ fam.mcs(t) ↔ truth_at(model, history, t, φ)`. With `DenseTask`, the FMCS `fam.mcs` maps timeline quotient elements to MCSs, and temporal quantification over `q > 0` corresponds to quantification over `CanonicalR`-accessible worlds.

3. **Closing the gap**: The domain mismatch (Task 977) can be resolved by building BFMCS directly over `TimelineQuot` (using `timelineQuotFMCS` from `TimelineQuotCanonical.lean`) and proving the truth lemma for `D = TimelineQuot`. The `DenseTask` relation makes this natural: the TaskFrame over TimelineQuot uses `canonicalTaskRel` (addition in the group), which is compatible with the FMCS's temporal coherence properties.

**Status**: The `DenseTask` relation is the **missing ingredient** that unifies the Cantor isomorphism, the group structure transfer, and the truth lemma into a single coherent instantiation.

### 3.3 Discrete Logic (D with SuccOrder/PredOrder)

**Current status**: Blocked at SuccOrder/PredOrder construction (Task 974).

**The problem**: `valid_discrete` quantifies over all D with `SuccOrder D` and `PredOrder D`. The countermodel must live in some discrete D — canonically, ℤ. But constructing `SuccOrder` on the discrete timeline quotient requires proving the covering lemma (no intermediate MCS between successive elements).

**Role of the discrete three-place relation**:

The `CanonicalTask` relation from report 04 provides a **direct path** that potentially **bypasses the SuccOrder construction entirely**:

1. **Succ relation as SuccOrder surrogate**: The `Succ(u, v)` relation (G-persistence + F-step) defines immediate successors syntactically. Instead of proving `SuccOrder` on a quotient type and then deriving the integer isomorphism, we can:
   - Define `CanonicalTask` inductively from `Succ`
   - Verify TaskFrame axioms directly
   - Use `CanonicalTask` to instantiate `TaskFrame ℤ`

2. **Covering lemma bypass**: The current blocker is proving that the discrete axiom DF implies no intermediate MCS exists between successive elements. The `Succ` relation sidesteps this: it defines "immediate successor" by the F-step condition (`f_content(u) ⊆ v ∪ f_content(v)`) rather than by absence of intermediates. The covering property becomes a *consequence* rather than a *prerequisite*.

3. **Integer characterization**: With `CanonicalTask` defined, the integer characterization `DiscreteTimelineQuot ≃o ℤ` becomes a secondary result. The primary result is the TaskFrame over ℤ itself, constructed by:
   - Enumerating `Succ`-chains from the root MCS
   - Mapping each chain position to an integer
   - Verifying TaskFrame axioms by chain concatenation

**Status**: The `CanonicalTask` relation offers a **potential resolution** to the Task 974 blocker by reframing the problem from "prove SuccOrder on quotient" to "define single-step relation and build integer tasks inductively."

---

## 4. Detailed Role Analysis by Pipeline Stage

### Stage 1: Lindenbaum Extension (MCS Construction)

**Role of three-place relation**: None. This stage is purely proof-theoretic and independent of duration.

### Stage 2: BFMCS Construction (Bundle of Families)

**Current approach**: Build FMCS families indexed by a generic domain D, with temporal coherence:
```lean
structure FMCS where
  mcs : D → Set Formula
  is_mcs : ∀ t, SetMaximalConsistent (mcs t)
  forward_G : ∀ t t' φ, t < t' → G φ ∈ mcs t → φ ∈ mcs t'
  backward_H : ∀ t t' φ, t' < t → H φ ∈ mcs t → φ ∈ mcs t'
```

**Role of three-place relation**:

- **Dense case**: The FMCS should be indexed by `TimelineQuot` (or ℚ via the isomorphism). The `DenseTask` relation ensures that `forward_G` and `backward_H` are compatible with the canonical task relation: if `t < t'` in TimelineQuot, then `CanonicalR(mcs(t), mcs(t'))`, so G-propagation holds.

- **Discrete case**: The FMCS should be indexed by ℤ. The `CanonicalTask` relation ensures that `forward_G` holds for integer-separated times: if `n < m`, then there is a Succ-chain from `mcs(n)` to `mcs(m)`, and by transitivity of G-propagation through each step, `G φ ∈ mcs(n) → φ ∈ mcs(m)`.

### Stage 3: Canonical TaskModel Construction

**Current approach**: The parametric canonical model sets:
- `WorldState := {M : Set Formula // SetMaximalConsistent M}` (all MCSs)
- `task_rel` := duration-coarse CanonicalR-based relation
- `valuation := fun M p => atom p ∈ M.val`

**Role of three-place relation**: Replace `task_rel` with the duration-precise version:

| Component | Base (current) | Dense (proposed) | Discrete (proposed) |
|-----------|---------------|-----------------|-------------------|
| `WorldState` | All MCSs | All MCSs | All MCSs |
| `D` | Any | ℚ (via Cantor) | ℤ (via Succ-chain) |
| `task_rel` | CanonicalR if d>0 | `w + d = w'` (group) | Succ-chain of length d |
| `valuation` | MCS membership | MCS membership | MCS membership |

### Stage 4: World History Construction

**Current approach**: Each FMCS family `fam` gives a history:
```lean
def to_history (fam : FMCS D) : WorldHistory (TaskFrame D)
```

with `states(t) = fam.mcs(t)` and `respects_task` verified using `task_rel`.

**Role of three-place relation**: The `respects_task` obligation requires:
```
∀ s t, s ≤ t → task_rel(states(s), t - s, states(t))
```

- **Duration-coarse**: `t - s > 0` implies `CanonicalR(mcs(s), mcs(t))`, which follows from `forward_G` coherence. ✓
- **Dense DenseTask**: `mcs(s) + (t-s) = mcs(t)` in the group, which holds by construction of the FMCS over TimelineQuot. ✓
- **Discrete CanonicalTask**: Need Succ-chain of length `(t-s)` from `mcs(s)` to `mcs(t)`, which holds by the inductive FMCS construction over ℤ. ✓

### Stage 5: Shift-Closed Omega

**Current approach**: `ShiftClosedOmega(B) = {time_shift(to_history(fam), δ) | fam ∈ B.families, δ ∈ D}`.

**Role of three-place relation**: Shift closure requires the task relation to be compatible with time translation. For the duration-precise relations:

- **DenseTask**: Shift by δ means `(w + d = w') → ((w + δ) + d = (w' + δ))`, which holds in any abelian group. ✓
- **CanonicalTask**: Shift by δ means relabeling the Succ-chain starting point, which preserves chain structure. ✓

### Stage 6: Truth Lemma

The critical bridge: `φ ∈ fam.mcs(t) ↔ truth_at(model, history, t, φ)`.

**Role of three-place relation**:

The temporal cases of the truth lemma require:

**G case** (forward): `G φ ∈ mcs(t) → ∀ s > t, truth_at(..., s, φ)`
- Need: for all s > t, `task_rel(mcs(t), s-t, mcs(s))` implies `φ ∈ mcs(s)`
- **Duration-coarse**: Follows from CanonicalR and forward_G. ✓
- **DenseTask**: Follows from the order on TimelineQuot and forward_G. ✓
- **CanonicalTask**: Follows from Succ-chain propagation: each Succ step preserves g_content, so G-formulas propagate through. ✓

**F case** (existential): `F φ ∈ mcs(t) → ∃ s > t, truth_at(..., s, φ)`
- Need: ∃ s > t and ∃ v with `task_rel(mcs(t), s-t, v)` and `φ ∈ v`
- **Duration-coarse**: Uses `canonical_forward_F` (Lindenbaum witness). The witness exists somewhere in the canonical model, but placing it at a specific time requires the BFMCS temporal completeness property.
- **DenseTask**: The witness from `canonical_forward_F` is an MCS v with `CanonicalR(mcs(t), v)`. By the Cantor isomorphism, v corresponds to some rational `s > t`. Then `DenseTask(mcs(t), s-t, v)` holds. ✓
- **CanonicalTask**: The witness v with `F φ ∈ mcs(t)` is reachable by some Succ-chain. The single-step forcing theorem (report 04) bounds the chain length when `FF φ ∉ mcs(t)`. When `FF φ ∈ mcs(t)`, the F-step condition defers to the successor, eventually resolving by well-foundedness of the subformula relation. ✓

**Box case** (modal): `□φ ∈ mcs(t) → ∀ σ ∈ Omega, truth_at(..., σ, t, φ)`
- Independent of the task relation. Uses BFMCS modal coherence. ✓

---

## 5. How the Three-Place Relation Resolves Current Gaps

### 5.1 Task 977: Dense Domain Mismatch

**Current gap**: Truth lemma proven for `D = Int`, but `valid_dense` needs `DenselyOrdered D`.

**Resolution via DenseTask**: Build the BFMCS directly over `D = TimelineQuot`:
1. Use `timelineQuotFMCS` (already constructed in `TimelineQuotCanonical.lean`) as the base family
2. Construct BFMCS bundle with families indexed by TimelineQuot
3. The `DenseTask` relation on TimelineQuot provides `TaskFrame TimelineQuot` with `DenselyOrdered`
4. Prove truth lemma for `D = TimelineQuot` (structure identical to Int case, only duration type changes)
5. Instantiate `valid_dense` with `D = TimelineQuot`

The parametric truth lemma infrastructure (`ParametricTruthLemma.lean`) is already D-generic. The missing piece is constructing a **temporally complete** BFMCS over TimelineQuot rather than over Int.

### 5.2 Task 974: Discrete SuccOrder Construction

**Current gap**: Cannot prove `SuccOrder DiscreteTimelineQuot` from the DF axiom.

**Resolution via CanonicalTask**: Bypass SuccOrder entirely:
1. Define `Succ(u, v)` purely syntactically (G-persistence + F-step)
2. Define `CanonicalTask(u, n, v)` inductively from Succ
3. Build `TaskFrame ℤ` using CanonicalTask as task_rel
4. The DF axiom guarantees Succ-successor existence (already proven in `DiscreteSuccSeed.lean`)
5. Use the Succ-chain FMCS construction for the truth lemma
6. Instantiate `valid_discrete` with `D = ℤ` and the Succ-chain TaskFrame

This avoids the quotient-then-characterize pipeline entirely. The SuccOrder on ℤ is already known (it's a Mathlib instance). The Succ relation on MCSs maps directly to the successor operation on ℤ.

---

## 6. Summary: Each Construction's Role

### Discrete CanonicalTask

| Pipeline stage | Role |
|---------------|------|
| BFMCS construction | Index families by ℤ via Succ-chain enumeration |
| TaskFrame instantiation | Provide `task_rel` as Succ-chain composition |
| WorldHistory construction | Verify `respects_task` via Succ-chain propagation |
| Truth lemma (G case) | G-persistence through each Succ step |
| Truth lemma (F case) | Single-step forcing bounds witness distance |
| Completeness | Instantiate `valid_discrete` with D = ℤ and Succ-TaskFrame |
| **Key advantage** | Bypasses SuccOrder construction on quotient type |

### Dense DenseTask

| Pipeline stage | Role |
|---------------|------|
| BFMCS construction | Index families by TimelineQuot via Cantor isomorphism |
| TaskFrame instantiation | Provide deterministic `task_rel` via group addition |
| WorldHistory construction | Verify `respects_task` via group associativity |
| Truth lemma (G case) | Forward_G over TimelineQuot order |
| Truth lemma (F case) | Lindenbaum witness placed at Cantor-assigned rational |
| Completeness | Instantiate `valid_dense` with D = TimelineQuot (DenselyOrdered) |
| **Key advantage** | Resolves domain mismatch by building directly over dense D |

---

## 7. Open Questions

1. **Parametric unification**: Can a single three-place relation definition subsume both discrete and dense cases, parametric in D? The duration-coarse relation achieves this but loses precision. A duration-precise parametric version would need to abstract over both "Succ-chain induction" and "Cantor group addition."

2. **Base logic**: The base logic has no characterization of D (no DN, no DF). Is there a natural three-place relation for the base case, or is the duration-coarse relation the best possible?

3. **Truth lemma genericity**: The parametric truth lemma (`ParametricTruthLemma.lean`) is already D-generic. Can it be instantiated directly with the duration-precise relations, or does the proof need modification?

4. **WorldState identity**: In both constructions, `WorldState = CanonicalMCS` (all MCSs). The three-place relation only changes `task_rel`, not the world state type. Is this the right decomposition, or should the world state type also be specialized (e.g., to elements of a specific Succ-chain or TimelineQuot)?
