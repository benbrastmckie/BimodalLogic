# Teammate B Findings: Task Frame Semantics Analysis

**Task**: 58 - Wire Completeness to Frame Conditions
**Date**: 2026-03-27
**Focus**: Task Frame semantic definitions (not Kripke semantics)

---

## Task Frame Definition Summary

### The Actual Structure

A `TaskFrame D` (in `Theories/Bimodal/Semantics/TaskFrame.lean`) is a 4-field structure:

```
TaskFrame D where
  WorldState : Type
  task_rel : WorldState → D → WorldState → Prop
  nullity_identity : ∀ w u, task_rel w 0 u ↔ w = u
  forward_comp : ∀ w u v x y, 0 ≤ x → 0 ≤ y → task_rel w x u → task_rel u y v → task_rel w (x+y) v
  converse : ∀ w d u, task_rel w d u ↔ task_rel u (-d) w
```

The type parameter `D` must carry `[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]` — it is a totally ordered abelian group of "durations". The interpretation is `task_rel w x u` = "from world state `w`, executing a task of duration `x` can produce world state `u`".

### WorldHistory

A `WorldHistory F` (in `Theories/Bimodal/Semantics/WorldHistory.lean`) is NOT simply a sequence indexed by all of D. It is a partial structure:

```
WorldHistory F where
  domain : D → Prop              -- which times are in scope
  convex : ∀ x z, domain x → domain z → ∀ y, x ≤ y → y ≤ z → domain y
  states : (t : D) → domain t → F.WorldState
  respects_task : ∀ s t hs ht, s ≤ t → F.task_rel (states s hs) (t - s) (states t ht)
```

The domain must be **convex** (no temporal gaps). The history must respect the task relation: consecutive times must be connected by the task relation with the appropriate duration `t - s`.

### Truth Evaluation

Truth is evaluated at a triple `(M, Ω, τ, t)` — a model, an admissible set of histories, a specific history, and a time point:

```
truth_at M Omega τ t : Formula → Prop
  atom p     := ∃ ht : τ.domain t, M.valuation (τ.states t ht) p
  bot        := False
  imp φ ψ    := truth_at ... φ → truth_at ... ψ
  box φ      := ∀ σ ∈ Omega, truth_at M Omega σ t φ
  all_past φ := ∀ s, s ≤ t → truth_at M Omega τ s φ   (reflexive: includes now)
  all_future φ := ∀ s, t ≤ s → truth_at M Omega τ s φ (reflexive: includes now)
```

**Critical**: atoms are FALSE outside domain (not undefined). Temporal operators quantify over ALL of D (not just `domain`). The `box` operator quantifies over ALL histories in `Omega` (an external admissibility parameter), not over "accessible worlds" in a Kripke sense.

### Validity

Validity quantifies over ALL totally ordered abelian groups D, ALL task frames, ALL models, ALL shift-closed `Omega`, ALL histories in `Omega`, and ALL times:

```
valid φ := ∀ D [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
             (F : TaskFrame D) (M : TaskModel F)
             (Omega : Set (WorldHistory F)) (h_sc : ShiftClosed Omega)
             (τ : WorldHistory F) (_ : τ ∈ Omega) (t : D),
             truth_at M Omega τ t φ
```

---

## Key Differences from Kripke

### 1. The "World" Is a History, Not a Point

In Kripke semantics, truth is evaluated at a single possible world `w`. Here truth is evaluated at a **triple** `(Omega, τ, t)` — an admissible set of histories, a specific history within it, and a time point. The "current context" is a trajectory through world-states, not a static snapshot.

This fundamentally changes what it means to satisfy a formula: the same world-state can appear at different times in different histories, and the truth of temporal formulas depends on the entire trajectory.

### 2. The Box Operator is NOT Kripke Accessibility

In standard Kripke modal logic, `□φ` means φ is true at all worlds accessible via the accessibility relation R. Here `□φ` means φ is true at ALL histories in `Omega` at the SAME time `t`. There is no "modal accessibility relation" on worlds — box quantifies across histories at a fixed temporal moment.

This is why the canonical model construction uses `ExistsTask M M' = (g_content M ⊆ M')` — it is an abstract relation on MCS-worlds derived from temporal structure, not a primitive Kripke accessibility relation.

### 3. The Temporal Accessibility IS the Group Structure

In standard temporal Kripke frames, accessibility `R` is a separate binary relation. Here there is NO separate accessibility relation for temporal operators. Instead:
- `all_future φ` quantifies directly over times `s ≥ t` in D
- `all_past φ` quantifies directly over times `s ≤ t` in D
- The group structure of D provides the "temporal accessibility"

This means: the frame condition for temporal operators is encoded in the ALGEBRAIC TYPE of D (dense, discrete, etc.), not as a property on a relation R.

### 4. World-States vs. Times Are Separate Types

In some temporal Kripke models, worlds already carry a temporal structure. Here `WorldState` and `D` are entirely separate types. `D` carries the group structure. `WorldState` is arbitrary. The history `τ` is what connects them: a partial function from D to WorldState.

The task relation `task_rel : WorldState → D → WorldState → Prop` describes which state-transitions are possible over which durations — it is not a binary relation on worlds indexed by time.

### 5. The ShiftClosed Requirement Has No Kripke Analog

Validity requires `ShiftClosed Omega`, where:
```
ShiftClosed Omega := ∀ σ ∈ Omega, ∀ Δ : D, time_shift σ Δ ∈ Omega
```

This means the admissible histories must be closed under time-translation. There is no direct analog in Kripke semantics. This condition is crucial for proving the MF and TF axioms (modal-temporal interaction), which is why the `valid` definition includes it explicitly.

### 6. Atoms Are False Outside Domain, Not Undefined

In many temporal Kripke models, atoms outside a world's "epistemic domain" are undefined or indeterminate. In Task Frame semantics, atoms at times `t ∉ domain(τ)` are FALSE by definition. This matters because temporal operators quantify over ALL of D, so they "see beyond" the history's domain.

---

## Critical Algebraic Properties

### What the Proofs Actually Need

**1. Nullity Identity (not just reflexivity)**: `task_rel w 0 u ↔ w = u`

This is STRONGER than Kripke reflexivity (`w R w`). It says zero duration is equivalent to identity. This is what makes the canonical frame construction work: `CanonicalTaskFrame` sets `task_rel M 0 N ↔ M = N` for the zero case.

**2. Forward Compositionality (restricted to non-negative durations)**: Only for `0 ≤ x`, `0 ≤ y`. The full unrestricted compositionality `task_rel w x u → task_rel u y v → task_rel w (x+y) v` is algebraically impossible for non-deterministic relations with mixed signs (proved false in prior research). The restriction to non-negative x, y is sufficient because `respects_task` in WorldHistory only uses `t - s ≥ 0`.

**3. Converse**: `task_rel w d u ↔ task_rel u (-d) w`

This provides temporal symmetry. It enables backward_comp (derivable from forward_comp + converse). It also makes the canonical construction's `d < 0 → False` design consistent: if d < 0 is false, then task_rel in forward direction is also constrained by converse.

**4. Convexity of WorldHistory domains**: A history cannot skip over times. This ensures the `respects_task` condition is non-trivially constrained — consecutive domain times must be connected by task relation.

**5. Group structure of D governs validity classes**:
- No extra axioms → valid on ALL linearly ordered abelian groups (base TM)
- `[DenselyOrdered D]` → valid on dense orders (density axiom DN)
- `[SuccOrder D] [PredOrder D]` → valid on discrete orders (discreteness axioms DF/DP)

---

## Semantic Insights for the Completeness Proof

### Insight 1: The Canonical Frame Task Relation is Forward-Only

The canonical frame construction (`CanonicalConstruction.lean`) uses:
- `d > 0`: `ExistsTask M N` (g_content M ⊆ N)
- `d = 0`: `M = N`
- `d < 0`: `False`

This works because `respects_task` only invokes `task_rel (states s) (t - s) (states t)` where `s ≤ t`, so `t - s ≥ 0`. Negative durations are never tested. The canonical model never needs to witness backward task-steps semantically.

### Insight 2: The Box Operator's Semantic Role Is Different From Temporal

In the truth evaluation, `box φ` quantifies over ALL histories in Omega at the same time. This means:
- Box-persistence theorems (`box_persistent`) say: if Box(φ) is true at time t, it's true at ALL times. This follows because box doesn't "see" time — it sees only which histories are in Omega.
- The modal axioms S5 (T, 4, B) are valid NOT because of a reflexive/transitive/symmetric accessibility relation, but because Omega quantification has these properties universally.

### Insight 3: The Family-Level vs. Bundle-Level Coherence Mismatch

The core blocking issue is:

**The truth lemma** (as currently written in `ParametricTruthLemma.lean`) proves:
```
φ ∈ fam.mcs t ↔ truth_at ... (to_history fam) t φ
```

For the backward direction of `all_future`: if φ is true at all `s ≥ t` on history `to_history fam`, then `G(φ) ∈ fam.mcs(t)`.

The proof requires: if `G(φ) ∉ fam.mcs(t)`, then `F(¬φ) ∈ fam.mcs(t)`, then by `forward_F` there exists `s > t` with `¬φ ∈ fam.mcs(s)` **in the same family**, which contradicts φ being true at `(fam, s)`.

The available `BFMCS_Bundle` provides only **bundle-level** coherence: the witness `¬φ` might be in a DIFFERENT family `fam'`. Different families correspond to different world-histories, so there is no contradiction.

### Insight 4: Why F-Preservation is Hard from Semantics

The semantic structure reveals WHY F-obligation preservation is hard:

Semantically, a valid Task Frame model satisfying `F(p)` and `F(¬p)` simply puts `p` true at some future time and `¬p` true at some (different) future time. Both can coexist in the same history.

In the proof-theoretic canonical construction, when we build a successor MCS for `F(φ)`, we must commit to a specific MCS that contains φ. That commitment can introduce `G(¬ψ)` for other pending F-obligations `F(ψ)`. Semantically, this would mean ¬ψ is always true in the future — but in the actual semantic model, ψ might be true in the future too (just at a different time or via a different history).

The gap is: **the canonical model conflates "obligation resolved" with "obligation resolved THIS STEP"**. The semantic model allows arbitrarily delayed resolution; the syntactic construction needs finite, deterministic extension.

### Insight 5: The Recommended Semantic Path

The deep path-forward analysis (report 77) identifies:

**Viable approach**: Build a forward-direction truth lemma that is sufficient for the completeness contradiction argument:
- `φ ∈ fam.mcs(t) → truth_at ... φ` (forward direction only)
- This suffices for completeness because completeness is contrapositive: if φ is not provable, show `¬φ` is true somewhere

The atom, bot, imp-antecedent, and G-forward cases all work for a forward-only lemma. The G-backward case (the problematic one) is not needed for the completeness direction — we need to show `¬φ` is true at the evaluation point, not that `φ` being true everywhere implies `G(φ)`.

---

## Confidence Level: **High**

The above analysis is based on direct reading of all semantic definition files:
- `TaskFrame.lean` (definitions and axioms)
- `WorldHistory.lean` (history structure and shift operations)
- `Truth.lean` (truth evaluation)
- `Validity.lean` (validity and consequence)
- `TaskModel.lean` (model structure)
- `CanonicalConstruction.lean` (canonical frame)
- `CanonicalFrame.lean` (canonical relations)
- `TemporalCoherence.lean` (coherence definitions)
- `ParametricTruthLemma.lean` (truth lemma)
- `BaseCompleteness.lean` and `ParametricRepresentation.lean` (completeness architecture)
- Report 77 (deep path-forward analysis)

The key facts are all derivable from the actual definitions, not from external assumptions.
