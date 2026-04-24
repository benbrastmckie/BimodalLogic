# Teammate C Findings: Lean 4 Definitions and Completeness Wiring

**Task**: 107 - Chain Design Diagnostics for Representation Theorem
**Focus**: Exact Lean 4 types, structures, and theorem statements for Path A
**Date**: 2026-04-24

## 1. Existing Truth Evaluation (`truth_at`)

The existing `truth_at` in `Theories/Bimodal/Semantics/Truth.lean` (line 119-130):

```lean
def truth_at (M : TaskModel F) (Omega : Set (WorldHistory F))
    (τ : WorldHistory F) (t : D) : Formula → Prop
  | Formula.atom p => ∃ (ht : τ.domain t), M.valuation (τ.states t ht) p
  | Formula.bot => False
  | Formula.imp φ ψ => truth_at M Omega τ t φ → truth_at M Omega τ t ψ
  | Formula.box φ => ∀ (σ : WorldHistory F), σ ∈ Omega → truth_at M Omega σ t φ
  | Formula.all_past φ => ∀ (s : D), s < t → truth_at M Omega τ s φ
  | Formula.all_future φ => ∀ (s : D), t < s → truth_at M Omega τ s φ
  | Formula.untl φ ψ => ∃ s : D, t < s ∧ truth_at M Omega τ s ψ ∧
      ∀ r : D, t ≤ r → r < s → truth_at M Omega τ r φ
  | Formula.snce φ ψ => ∃ s : D, s < t ∧ truth_at M Omega τ s ψ ∧
      ∀ r : D, s < r → r ≤ t → truth_at M Omega τ r φ
```

**Key observations**:
- Requires `[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]` on `D` (via `TaskFrame D`)
- Requires a `TaskFrame D` with `WorldState` type, task relation, nullity, compositionality, converse
- Requires `WorldHistory F` with domain predicate, convexity, states function, coherence
- Atoms check domain membership: false outside the history's domain
- Box quantifies over a set `Omega` of world histories (S5 with parameterized accessibility)
- Temporal operators use strict `<` (irreflexive semantics)

**The Box case is the critical architectural issue for Path A**: Box quantifies over `Omega`, a set of `WorldHistory F` structures. On a bare linear order, there is no notion of "world history" -- one must either (a) define a stripped-down version without the WorldHistory/TaskFrame apparatus, or (b) show that every strict linear order embeds into a TaskFrame model.

## 2. Existing Soundness Theorem

From `Theories/Bimodal/Metalogic/Soundness.lean` (line 982-987):

```lean
theorem soundness (Γ : Context) (φ : Formula) :
    DerivationTree Γ φ → (D : Type) → [AddCommGroup D] → [LinearOrder D] → [IsOrderedAddMonoid D] →
    [Nontrivial D] → (F : TaskFrame D) → (M : TaskModel F) →
    (Omega : Set (WorldHistory F)) → (h_sc : ShiftClosed Omega) →
    (τ : WorldHistory F) → (h_mem : τ ∈ Omega) → (t : D) →
    (h_ctx : ∀ ψ ∈ Γ, truth_at M Omega τ t ψ) →
    truth_at M Omega τ t φ
```

**Type requirements on D**: `[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D]`

This does NOT merely require `[LinearOrder D]`. It requires `[AddCommGroup D]` and `[IsOrderedAddMonoid D]` because:
1. `TaskFrame D` requires these typeclasses
2. `WorldHistory F` requires them (for time-shift: `σ.time_shift Δ`)
3. `ShiftClosed Omega` is defined as `∀ σ ∈ Omega, ∀ (Δ : D), σ.time_shift Δ ∈ Omega` -- needs group addition
4. The MF/TF axiom soundness proofs use time-shift invariance

**Conclusion**: Soundness is inherently tied to the `AddCommGroup D` structure through `TaskFrame`. It cannot be trivially restated for bare linear orders.

## 3. Existing Validity Definition

From `Theories/Bimodal/Semantics/Validity.lean` (line 73-78):

```lean
def valid (φ : Formula) : Prop :=
  ∀ (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D]
    (F : TaskFrame D) (M : TaskModel F)
    (Omega : Set (WorldHistory F)) (h_sc : ShiftClosed Omega)
    (τ : WorldHistory F) (h_mem : τ ∈ Omega) (t : D),
    truth_at M Omega τ t φ
```

Validity quantifies over `(D : Type)` with `AddCommGroup D` + `LinearOrder D` + `IsOrderedAddMonoid D` + `Nontrivial D`, plus all TaskFrames, TaskModels, shift-closed Omega sets, histories in Omega, and times.

## 4. Existing Completeness Theorem

From `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` (line 128-150):

```lean
theorem bx_completeness (φ : Formula) :
    valid φ → Nonempty (DerivationTree [] φ)
```

The proof works by contraposition:
1. Assume not derivable
2. Build MCS containing neg(φ) via Lindenbaum
3. Call `dd_countermodel_chronicle` which produces a countermodel over **Rat**
4. The countermodel contradicts validity

`dd_countermodel_chronicle` (line 396-402):
```lean
theorem dd_countermodel_chronicle (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (φ : Formula) (h_neg_in : φ.neg ∈ M) :
    ∃ (D : Type) (_ : AddCommGroup D) (_ : LinearOrder D) (_ : IsOrderedAddMonoid D)
      (_ : Nontrivial D) (F : TaskFrame D) (TM : TaskModel F)
      (Omega : Set (WorldHistory F)) (_ : ShiftClosed Omega)
      (τ : WorldHistory F) (_ : τ ∈ Omega) (t : D),
      ¬truth_at TM Omega τ t φ
```

This existentially witnesses D = Rat, plus a TaskFrame, TaskModel, Omega, history, and time point where phi is false. The core machinery uses:
- `ParametricCanonicalTaskFrame Rat` -- a canonical TaskFrame over Rat
- `ParametricCanonicalTaskModel Rat` -- canonical valuation
- `ShiftClosedParametricCanonicalOmega` -- built from a BFMCS
- `chronicle_bfmcs` -- the Burgess-style BFMCS construction

## 5. Design Analysis: truth_at_lo Without TaskFrame

### The Box Problem

For a new `truth_at_lo` on bare `(X, <)` with `[LinearOrder X]`:
- Temporal cases (G, H, U, S) are straightforward: just quantify over `X` with `<`
- Atom case: simply `t ∈ V p` (no domain restriction needed)
- **Box case**: S5 box means "true at all accessible worlds." On a single linear order with universal accessibility, this is `∀ s : X, truth_at_lo V φ s`. But this creates a problem:

If Box phi = "phi everywhere on X", then the system degenerates -- Box becomes equivalent to "always was and always will be and holds now", which is strictly stronger than S5 box should be. In the task frame semantics, Box quantifies over different *histories* at the same time, not over different times. The modal dimension is orthogonal to the temporal dimension.

### Why This Matters

The existing completeness proof builds a *bundle* of FMCS families (BFMCS), where each family is a time-indexed sequence of MCS. The Box case of the truth lemma works because different FMCS families in the bundle provide different "worlds" for Box quantification -- at time t, Box phi is true iff phi is in the MCS of every family at time t.

A pure `truth_at_lo` on a bare linear order **cannot handle Box** because there is only one "world" at each time. The modal dimension requires multiple parallel linear orders (one per FMCS family).

### Recommended Approach: Bundle-Indexed Truth

Instead of truth on a bare linear order, define truth on a *bundle of linear orders* (which is exactly what the existing BFMCS + ParametricCanonical machinery provides). The "linear order" aspect comes from Rat (or any D with the right structure), and the "bundle" aspect provides the modal dimension.

**The existing approach is already Path A**. The task should focus on eliminating the sorry sites in the BFMCS construction (ChronicleToCountermodel.lean), not on building a new truth evaluation.

### Alternative: Frame-Stripped Truth (Limited Scope)

If the goal is specifically to prove completeness for "truth on strict linear orders" as a separate theorem:

```lean
-- This only works for the BOX-FREE fragment
def truth_at_lo {X : Type*} [LinearOrder X] (V : Atom → Set X) : Formula → X → Prop
  | .atom p, t => t ∈ V p
  | .bot, _ => False
  | .imp φ ψ, t => truth_at_lo V φ t → truth_at_lo V ψ t
  | .box φ, t => ∀ s : X, truth_at_lo V φ s  -- S5 as universal quantification
  | .all_future φ, t => ∀ s : X, t < s → truth_at_lo V φ s
  | .all_past φ, t => ∀ s : X, s < t → truth_at_lo V φ s
  | .untl φ ψ, t => ∃ s : X, t < s ∧ truth_at_lo V ψ s ∧ ∀ r : X, t ≤ r → r < s → truth_at_lo V φ r
  | .snce φ ψ, t => ∃ s : X, s < t ∧ truth_at_lo V ψ s ∧ ∀ r : X, s < r → r ≤ t → truth_at_lo V φ r
```

With this definition, `Box φ` = `∀ s, truth_at_lo V φ s`, which is stronger than what the task-frame semantics gives (there, Box quantifies over histories, not times). This means:

- **Soundness direction** (deriv -> valid_lo): HARDER, because Box axioms like MT (Box phi -> phi) become trivially valid, but the MF axiom (Box(Gφ) -> G(Boxφ)) requires `∀ s, ∀ r > s, φ(r)` implies `∀ r > t, ∀ s, φ(s)`, which is trivially true. So soundness should work.
- **Completeness direction** (valid_lo -> deriv): REQUIRES the Box case of the truth lemma to show `Box φ ∈ MCS(t) ↔ ∀ s, φ ∈ MCS(s)`, which requires modal saturation across all time points. This is NOT what the FMCS construction gives -- the FMCS gives `Box φ ∈ MCS(t) ↔ ∀ families, φ ∈ family.mcs(t)`.

**Verdict**: A `truth_at_lo` with Box = universal is NOT equivalent to the task-frame semantics. The two notions of validity differ. Completeness for `truth_at_lo` would require a different proof strategy than the existing BFMCS approach.

## 6. Soundness for General Linear Orders

### Can soundness be restated for bare linear orders?

No, not straightforwardly:

1. **`TaskFrame D` requires `AddCommGroup D`**: The task frame structure includes task_rel, nullity, compositionality, converse -- all requiring group operations.
2. **`ShiftClosed` requires addition**: `WorldHistory.time_shift σ Δ` uses `D` addition.
3. **MF/TF axiom soundness uses time-shift**: The proofs of MF (`Box(Gφ) -> G(Boxφ)`) and TF (`G(Boxφ) -> Box(Gφ)`) essentially use the fact that `D` is a group to shift histories.

### Can every strict linear order embed into a TaskFrame model?

This requires: for every strict linear order `(X, <)`, there exists `D` with `AddCommGroup D + LinearOrder D`, a `TaskFrame D`, and an order-embedding `X ↪ D`.

By Szpilrajn/order-embedding theorems, any linear order embeds into the reals, and `Real` has `AddCommGroup`. So in principle yes -- but this embedding is highly non-constructive and would require significant Mathlib infrastructure.

### Recommended approach

Rather than building new soundness infrastructure, the biconditional "valid iff derivable" should be stated purely in terms of the existing `valid` definition (which uses TaskFrame). The "valid on all strict linear orders" characterization is a SEPARATE theorem (frame definability) that would be a nice-to-have but is not needed for the core completeness result.

## 7. Recommended Completeness Statement

### Option 1: Keep existing statement (RECOMMENDED)

```lean
theorem bx_completeness (φ : Formula) :
    valid φ → Nonempty (DerivationTree [] φ)
```

This is already the right statement. The work is to eliminate the sorry sites in the proof, not to change the statement.

### Option 2: Separate linear-order completeness (FUTURE WORK)

If desired later, a separate representation theorem:

```lean
-- Every MCS is realized in a Rat model (existing dd_countermodel_chronicle, modulo sorries)
theorem bx_representation (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
    ∃ (F : TaskFrame Rat) (TM : TaskModel F) (Omega : Set (WorldHistory F))
      (_ : ShiftClosed Omega) (τ : WorldHistory F) (_ : τ ∈ Omega) (t : Rat),
      ∀ φ, φ ∈ M ↔ truth_at TM Omega τ t φ
```

This is essentially what the existing `dd_countermodel_chronicle` + truth lemma provides, but stated as a biconditional rather than just the forward direction.

### Option 3: truth_at_lo completeness (NOT RECOMMENDED)

For the reasons in Section 5, this requires fundamentally different proof infrastructure and the Box semantics differ from the task-frame semantics. Not recommended.

## 8. Sorry Site Classification

### Active sorry sites (11 total, all on critical path)

**ChronicleToCountermodel.lean (9 sorries)**:

| Line | Function | Description | Path A Impact |
|------|----------|-------------|---------------|
| 192 | `chronicle_fmcs.forward_G` | G-formula propagation across chronicle | Shared |
| 196 | `chronicle_fmcs.backward_H` | H-formula propagation across chronicle | Shared |
| 234 | `box_stable_in_chronicle_fmcs` | Box stability along chronicle | Shared |
| 320 | `chronicle_bfmcs_restricted_tc` (F) | F-resolution via C5 | Shared |
| 323 | `chronicle_bfmcs_restricted_tc` (P) | P-resolution via C5' | Shared |
| 342 | `chronicle_bfmcs_restricted_buc` (U) | Backward Until witness -> membership | Shared |
| 345 | `chronicle_bfmcs_restricted_buc` (S) | Backward Since witness -> membership | Shared |
| 374 | `chronicle_bfmcs_restricted_fuc` (U) | Forward Until via C5 | Shared |
| 377 | `chronicle_bfmcs_restricted_fuc` (S) | Forward Since via C5' | Shared |

**CounterexampleElimination.lean (2 sorries)**:

| Line | Function | Description | Path A Impact |
|------|----------|-------------|---------------|
| 289 | `eliminate_C4_counterexample` sub-case 1a | C4 hard case (delta in both f(x),f(y)) | Shared |
| 355 | `eliminate_C4'_counterexample` sub-case 1a | C4' mirror of hard case | Shared |

### Classification Summary

- **(a) Shared with Path A**: ALL 11 sorry sites. The existing architecture IS Path A -- the Burgess chronicle construction over Rat with BFMCS is exactly the "general linear order" approach. The parametric canonical model machinery already works over any `D` with `AddCommGroup + LinearOrder`.

- **(b) Specific to Rat-based approach only**: NONE. The Rat instantiation is just a convenient choice. The parametric machinery in `Algebraic/` works for any D.

- **(c) New for Path A**: NONE needed if "Path A" means "completeness via BFMCS over a specific linear order." The existing codebase already implements this over Rat. A hypothetical `truth_at_lo` completeness would require MANY new sorry sites (entire new truth lemma, new soundness, embedding theorems).

## 9. Key Architectural Insight

**The existing codebase already implements "Path A"**. The completeness proof constructs a countermodel over Rat (a strict linear order). The BFMCS bundle provides the modal dimension that a bare linear order cannot. The "new truth evaluation on strict linear orders" idea from the task prompt conflates two different things:

1. **The temporal domain** is already a strict linear order (Rat with <)
2. **The modal dimension** requires the bundle of FMCS families -- this is NOT captured by a single linear order

The correct path forward is to eliminate the 11 sorry sites in the existing Burgess chronicle construction, not to build new truth evaluation infrastructure.

## 10. How Soundness + Completeness Combine

The current architecture gives:

```
soundness:     Γ ⊢ φ  →  Γ ⊨ φ    (sorry-free)
completeness:  ⊨ φ    →  ⊢ φ       (11 sorries)
```

Where `valid φ` quantifies over ALL `(D, TaskFrame D, TaskModel, Omega, τ, t)` with:
- `D : Type` with `AddCommGroup + LinearOrder + IsOrderedAddMonoid + Nontrivial`
- `F : TaskFrame D`
- `M : TaskModel F`
- `Omega : Set (WorldHistory F)` shift-closed
- `τ ∈ Omega`
- `t : D`

The biconditional `⊢ φ ↔ ⊨ φ` follows directly from soundness + completeness once the 11 sorries are eliminated. No additional theorems or definitions are needed.
