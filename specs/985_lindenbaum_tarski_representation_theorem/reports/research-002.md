# Research Report: TaskFrame-Specific Lindenbaum-Tarski Representation

**Task**: 985 — Lindenbaum-Tarski algebraic representation theorem
**Session**: sess_1773710714_8a9e6a
**Focus**: TaskFrame semantics (not Kripke), detailed algebraic construction

---

## Critical Clarification: TaskFrame vs Kripke

The previous research (research-001) conflated TaskFrame semantics with general Kripke
semantics. **This is incorrect.** The TM logic uses a fundamentally different semantic
structure:

| Feature | Kripke Semantics | TaskFrame Semantics |
|---------|------------------|---------------------|
| Primitive | Worlds + Binary Relation R | WorldStates + Duration Type D + Ternary task_rel |
| Modal Box | `∀ w', R w w' → φ(w')` | `∀ τ ∈ Ω, truth_at τ t φ` (quantifies over HISTORIES) |
| Temporal | Binary relation on worlds | Function D → WorldState (HISTORY) |
| Time | Implicit (or single linear order) | Explicit type D with ordered abelian group structure |

The algebraic representation theorem must be geared specifically for TaskFrame.

---

## TaskFrame Semantics: The Precise Structure

From `TaskFrame.lean` and `Truth.lean`:

### TaskFrame D
```lean
structure TaskFrame (D : Type*) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] where
  WorldState : Type
  task_rel : WorldState → D → WorldState → Prop
  nullity_identity : ∀ w u, task_rel w 0 u ↔ w = u
  forward_comp : ∀ w u v x y, 0 ≤ x → 0 ≤ y → task_rel w x u → task_rel u y v → task_rel w (x+y) v
  converse : ∀ w d u, task_rel w d u ↔ task_rel u (-d) w
```

### Truth Evaluation
```lean
def truth_at (M : TaskModel F) (Omega : Set (WorldHistory F)) (τ : WorldHistory F) (t : D) : Formula → Prop
  | atom p => ∃ (ht : τ.domain t), M.valuation (τ.states t ht) p
  | bot => False
  | imp φ ψ => truth_at φ → truth_at ψ
  | box φ => ∀ (σ : WorldHistory F), σ ∈ Omega → truth_at σ t φ   -- SAME time t, different history
  | all_past φ => ∀ (s : D), s ≤ t → truth_at τ s φ    -- SAME history τ, different time s
  | all_future φ => ∀ (s : D), t ≤ s → truth_at τ s φ  -- SAME history τ, different time s
```

### WorldHistory
```lean
structure WorldHistory (F : TaskFrame D) where
  domain : D → Prop
  convex : ∀ x z, domain x → domain z → ∀ y, x ≤ y → y ≤ z → domain y
  states : (t : D) → domain t → F.WorldState
  respects_task : ∀ s t (hs : domain s) (ht : domain t), s ≤ t → F.task_rel (states s hs) (t - s) (states t ht)
```

---

## The Algebraic Representation Theorem: Correct Statement

**Theorem (TaskFrame Algebraic Representation)**:
Let D be any totally ordered abelian group. If φ is not provable in TM, then there exists:
1. A TaskFrame F over D
2. A TaskModel M over F
3. A shift-closed set Ω ⊆ WorldHistory F
4. A history τ ∈ Ω and time t : D

Such that: `¬(truth_at M Ω τ t φ)`

This is fundamentally different from Kripke representation because:
- D is an explicit parameter (not implicit)
- Ω is a set of HISTORIES (not worlds)
- Box quantifies over Ω at a FIXED time
- Temporal operators quantify over times in a FIXED history

---

## The Algebraic Construction: Detailed

### Stage 1: The Lindenbaum Algebra (Already Complete)

**LindenbaumAlg** = `Formula / ProvEquiv` where `ProvEquiv φ ψ ↔ (⊢ φ ↔ ψ)`

This is a Boolean algebra with interior operators G, H, □.

**Existing infrastructure** (all sorry-free in `Algebraic/`):
- `BooleanAlgebra LindenbaumAlg`
- `G_interior : InteriorOp LindenbaumAlg` (deflationary, monotone, idempotent)
- `H_interior : InteriorOp LindenbaumAlg`
- `box_interior : InteriorOp LindenbaumAlg`
- Ultrafilter ↔ MCS bijection

### Stage 2: WorldState from the Algebra

**Definition**: `CanonicalWorldState := Ultrafilter LindenbaumAlg`

Via the proven bijection, this equals `{ S : Set Formula // SetMaximalConsistent S }` (MCSs).

**Valuation**: For `U : CanonicalWorldState` and atom `p`:
```
M.valuation U p := [p] ∈ U   (equivalently: p ∈ mcs(U))
```

### Stage 3: task_rel from the Algebra

The existing `canonical_task_rel` in `CanonicalConstruction.lean` defines:

```lean
def canonical_task_rel (M : CanonicalWorldState) (d : Int) (N : CanonicalWorldState) : Prop :=
  if d > 0 then CanonicalR M.val N.val
  else if d < 0 then CanonicalR N.val M.val
  else M = N  -- d = 0
```

where `CanonicalR M N := ∀ φ, φ.all_future ∈ M → φ ∈ N` (G-content inclusion).

**The Algebraic Perspective**: `CanonicalR` is exactly the Stone relation for the G interior operator!
```
CanonicalR U V  ↔  ∀ [φ], G_quot [φ] ∈ U → [φ] ∈ V
```

This is NOT a Kripke accessibility relation — it's the canonical task relation derived from
the G operator on the Lindenbaum algebra, with converse for negative durations.

**TaskFrame Axiom Verification** (all proven in existing code):

| Axiom | Source | Status |
|-------|--------|--------|
| nullity_identity | `canonical_task_rel M 0 N ↔ M = N` | Proven |
| forward_comp | `canonicalR_transitive` (uses 4-axiom) | Proven |
| converse | Symmetry of definition | Proven |

### Stage 4: D-Parametric Construction

**Critical insight**: The current construction hardcodes D = Int. The algebraic approach should
be **D-parametric**: the same construction works for ANY totally ordered abelian group D.

**Why this works**: The TaskFrame axioms depend ONLY on:
1. Group structure of D (for nullity_identity: 0, for forward_comp: +)
2. Order structure of D (for forward_comp: 0 ≤ x, 0 ≤ y)
3. Properties of CanonicalR (transitivity from 4-axiom)

None of these depend on D being specifically Int, Rat, or any particular group.

**The parametric TaskFrame**:
```lean
def AlgebraicCanonicalTaskFrame (D : Type*) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] :
    TaskFrame D where
  WorldState := CanonicalWorldState  -- = Ultrafilter LindenbaumAlg = MCS
  task_rel M d N := if d > 0 then CanonicalR M.val N.val
                    else if d < 0 then CanonicalR N.val M.val
                    else M = N
  nullity_identity := canonical_task_rel_nullity_identity
  forward_comp := canonical_task_rel_forward_comp
  converse := canonical_task_rel_converse
```

This construction is **uniform in D** — the same algebraic structure works regardless
of whether D = Int (discrete), D = Rat (dense), or any other ordered abelian group.

### Stage 5: Histories from the Algebra

A WorldHistory is a function `D → WorldState` (restricted to a convex domain) that respects task_rel.

**FMCS (Family of MCS indexed by D)**: This is exactly a WorldHistory!

```lean
structure FMCS (D : Type*) :=
  mcs : D → Set Formula
  each_mcs : ∀ t, SetMaximalConsistent (mcs t)
  temporal_coherent : ... (G/H witnesses exist)
```

Converting FMCS to WorldHistory:
```lean
def to_history (fam : FMCS D) : WorldHistory (AlgebraicCanonicalTaskFrame D) where
  domain := fun _ => True  -- full domain
  states t _ := ⟨fam.mcs t, fam.each_mcs t⟩
  respects_task s t _ _ h := fam.temporal_coherent_implies_task_rel s t h
```

**Key Lemma**: If FMCS is temporally coherent (G-witnesses and H-witnesses exist),
then `to_history fam` satisfies `respects_task`. This follows from:
- If Gφ ∈ fam.mcs s and s ≤ t, then φ ∈ fam.mcs t (by temporal coherence)
- This is exactly `CanonicalR (fam.mcs s) (fam.mcs t)` for s ≤ t

### Stage 6: Bundle (Ω) from the Algebra

**BFMCS (Bundle of FMCS)**: A bundle is a set of families with modal saturation:
```lean
structure BFMCS (D : Type*) :=
  families : Set (FMCS D)
  modal_forward : ∀ fam ∈ families, ∀ t φ, □φ ∈ fam.mcs t → ∀ fam' ∈ families, φ ∈ fam'.mcs t
  modal_backward : ...
```

**Canonical Omega**:
```lean
def CanonicalOmega (B : BFMCS D) : Set (WorldHistory (AlgebraicCanonicalTaskFrame D)) :=
  { τ | ∃ fam ∈ B.families, τ = to_history fam }
```

**Shift-Closed Enlargement**: `ShiftClosedCanonicalOmega` includes all time-shifts of histories
in `CanonicalOmega`, ensuring the ShiftClosed property required by validity definitions.

### Stage 7: Truth Lemma (The Core)

**Theorem (Algebraic Truth Lemma)**: For D-parametric canonical structures:
```
∀ (B : BFMCS D) (h_tc : B.temporally_coherent)
  (fam : FMCS D) (hfam : fam ∈ B.families)
  (t : D) (φ : Formula),
  φ ∈ fam.mcs t ↔ truth_at (AlgebraicCanonicalModel D) (CanonicalOmega B) (to_history fam) t φ
```

**Proof by structural induction on φ**:
- **atom p**: `p ∈ fam.mcs t ↔ valuation (fam.mcs t) p` (by definition of valuation)
- **⊥**: Both sides are False
- **φ → ψ**: By induction (MCS implication property ↔ material conditional)
- **□φ**: By modal_forward/modal_backward of BFMCS
- **Gφ**: By temporal coherence (G-witnesses) and induction
- **Hφ**: By temporal coherence (H-witnesses) and induction

This is exactly what `canonical_truth_lemma` in `CanonicalConstruction.lean` proves,
but viewed algebraically and generalized to arbitrary D.

### Stage 8: Representation Theorem

**Theorem (TaskFrame Algebraic Representation)**:
```
∀ (D : Type*) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D],
∀ (φ : Formula), ¬(⊢ φ) →
  ∃ (M : TaskModel (AlgebraicCanonicalTaskFrame D))
    (Ω : Set (WorldHistory (AlgebraicCanonicalTaskFrame D)))
    (τ : WorldHistory) (t : D),
    ShiftClosed Ω ∧ τ ∈ Ω ∧ ¬(truth_at M Ω τ t φ)
```

**Proof**:
1. If ¬(⊢ φ), then φ.neg is consistent
2. By `set_lindenbaum`: extend {φ.neg} to MCS Γ₀
3. By `temporal_coherent_family_exists`: build FMCS fam₀ with Γ₀ = fam₀.mcs 0
4. By bundle construction: build BFMCS B with fam₀ ∈ B.families
5. By shift-closed enlargement: ShiftClosedCanonicalOmega B
6. By truth lemma: φ.neg ∈ fam₀.mcs 0 ↔ truth_at ... (to_history fam₀) 0 φ.neg
7. Hence: φ is false at (AlgebraicCanonicalModel, ShiftClosedCanonicalOmega B, to_history fam₀, 0)

---

## Dense and Discrete Extensions

### Dense Completeness (D with DenselyOrdered)

When the density axiom DN is in the proof system, the algebraic structure gains:
```
F_quot [φ] ≤ F_quot (F_quot [φ])   (algebraic density)
```

**Effect on FMCS**: For any s < t, there exists r with s < r < t such that the
MCS at r interpolates the temporal content. This follows from DN forcing G-witnesses
to themselves have G-witnesses.

**Instantiation**: Use D = Rat (or any DenselyOrdered group) in the parametric construction.
The algebraic truth lemma automatically specializes to dense time.

### Discrete Completeness (D with SuccOrder)

When the discreteness axiom DF is in the proof system:
```
(F⊤ ∧ φ ∧ Hφ) → F(Hφ)   (discrete immediate successor)
```

**Effect on FMCS**: Between any MCS and its temporal successors, there are no
intermediates — immediate successors exist.

**Instantiation**: Use D = Int (or any SuccOrder group) in the parametric construction.

**Caveat**: The algebraic proof that DF forces immediate successors among MCSs
is the same challenge as task 974's `succ_le_of_lt`. However, the algebraic
perspective may simplify this: the successor property is a consequence of DF
forcing the G-content inclusion to have no strict refinements.

---

## What's New vs. Existing Infrastructure

| Component | Existing Location | Algebraic Perspective |
|-----------|-------------------|----------------------|
| LindenbaumAlg | `Algebraic/LindenbaumQuotient.lean` | Unchanged |
| BooleanAlgebra | `Algebraic/BooleanStructure.lean` | Unchanged |
| G/H interior | `Algebraic/InteriorOperators.lean` | Unchanged |
| UF ↔ MCS | `Algebraic/UltrafilterMCS.lean` | Unchanged |
| CanonicalWorldState | `Bundle/CanonicalConstruction.lean` | Same as Ultrafilter LindenbaumAlg |
| canonical_task_rel | `Bundle/CanonicalConstruction.lean` | = Stone relation for G |
| TaskFrame axioms | `Bundle/CanonicalConstruction.lean` | Already proven for D = Int |
| Truth lemma | `Bundle/CanonicalConstruction.lean` | Proven for D = Int |

**What needs to be added**:
1. **D-parametric TaskFrame**: Generalize from D = Int to any D
2. **D-parametric truth lemma**: The proof structure is unchanged; just polymorphism
3. **Dense/discrete instantiation**: Plug in D = Rat or D = Int

The key insight is that **nothing algebraically new** is needed. The existing
`CanonicalConstruction.lean` already implements the algebraic construction
(task_rel from G-content, truth lemma, BFMCS), just without the parametric D.

---

## Implementation Phases

### Phase 1: D-Parametric Canonical TaskFrame
- Generalize `CanonicalWorldState` (already D-independent)
- Generalize `canonical_task_rel` to use `D` instead of `Int`
- Prove TaskFrame axioms parametrically (should be copy-paste with type generalization)

### Phase 2: D-Parametric FMCS and BFMCS
- Generalize `FMCS D` and `BFMCS D` (already partially done)
- Generalize `to_history` and `CanonicalOmega`
- Prove `respects_task` parametrically

### Phase 3: D-Parametric Truth Lemma
- Generalize `canonical_truth_lemma` to arbitrary D
- Generalize `shifted_truth_lemma` for shift-closed Omega
- The proof structure is unchanged; just type polymorphism

### Phase 4: Algebraic Representation Theorem
- State the representation theorem with parametric D
- Combine Lindenbaum extension + BFMCS construction + truth lemma
- This gives: ¬⊢φ → countermodel exists for ANY D

### Phase 5: Completeness Corollaries
- **Base completeness**: Instantiate with any D
- **Dense completeness**: Instantiate with DenselyOrdered D + verify density axiom
- **Discrete completeness**: Instantiate with SuccOrder D + verify discreteness axiom

---

## Confidence Assessment

**High confidence** (9/10):
- The algebraic structure already exists in `Algebraic/` modules
- The TaskFrame construction already exists in `CanonicalConstruction.lean`
- The D-parametric generalization is mechanical (type polymorphism)
- The truth lemma proof structure transfers directly

**Medium confidence** (7/10):
- Discrete completeness (DF → immediate successors) has the same difficulty as task 974
- Shift-closure for arbitrary D needs verification (but pattern exists for D = Int)

**Key Realization**:
The "domain mismatch" (tasks 977/978/982) is NOT a fundamental obstacle. It arose from
trying to BUILD D from syntax (TimelineQuot). The algebraic approach ACCEPTS D as a
parameter, avoiding the construction problem entirely. The representation theorem is
parametric: it works for ANY D, and we simply instantiate with the D we need.

---

## Relationship to Stone Duality

The previous research mentioned Stone duality, but this is **not** the right framing for
TaskFrame semantics. Stone duality relates:
- Boolean algebras ↔ Stone spaces (ultrafilters as points)
- Interior operators ↔ Accessibility relations (Kripke frames)

TaskFrame semantics has a more complex structure:
- WorldStates = ultrafilters (Stone-like)
- task_rel = parametric in duration D (NOT a binary relation)
- Histories = functions D → WorldState (NOT just points)
- Omega = sets of histories with shift-closure (NOT just subsets of worlds)

The correct algebraic perspective is:
- LindenbaumAlg provides WorldStates (via ultrafilters)
- G operator provides temporal accessibility (via Stone relation for G)
- D is an explicit parameter (not derived algebraically)
- Histories emerge from temporal coherence of MCSs

This is a **hybrid algebraic-semantic** construction, not pure Stone duality.

---

## Summary

The Lindenbaum-Tarski algebraic representation theorem for TaskFrame semantics is:

1. **D-parametric**: The duration type D is a parameter, not constructed from syntax
2. **WorldState = Ultrafilter LindenbaumAlg**: Algebraically derived world-states
3. **task_rel from G**: The Stone relation for the G interior operator, with converse
4. **Histories from FMCS**: Temporally coherent families of MCSs
5. **Omega from BFMCS**: Bundles with modal saturation and shift-closure
6. **Truth lemma**: MCS membership ↔ truth_at (proven by induction)
7. **Representation**: ¬⊢φ → countermodel exists for any D

This avoids the "domain mismatch" by not trying to construct D from syntax. Instead,
D is accepted as a parameter, and the construction works uniformly for all D.
