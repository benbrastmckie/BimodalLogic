# Research Findings: Base TM Completeness Viability

**Teammate**: A (second pass)
**Focus**: Mathematical analysis of base TM completeness - validity semantics, well-formedness, and CanonicalMCS vs TaskFrame mismatch
**Date**: 2026-03-20

## Orientation

Prior reports (01, 02, 03, and the first 03_teammate-a-findings.md) cover blocker identification, modal saturation, omega-squared, and FMP approaches. This report focuses specifically on the four questions assigned: (1) what base TM validity means semantically, (2) whether the completeness statement is well-formed, (3) a fresh analysis of the fundamental blockers, and (4) the precise nature of the CanonicalMCS vs TaskFrame D mismatch.

---

## Key Findings

### 1. Base TM Validity Semantics

**What class of frames does base TM validity quantify over?**

From `Theories/Bimodal/Semantics/Validity.lean` lines 72-76:

```lean
def valid (φ : Formula) : Prop :=
  ∀ (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] (F : TaskFrame D) (M : TaskModel F)
    (Omega : Set (WorldHistory F)) (h_sc : ShiftClosed Omega)
    (τ : WorldHistory F) (h_mem : τ ∈ Omega) (t : D),
    truth_at M Omega τ t φ
```

The `valid` predicate is universal over ALL types `D` carrying `[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]` — i.e., all **linearly ordered abelian groups (LOAGs)**. This includes:
- `Int` (discrete, order type ℤ)
- `Rat` (dense, order type ℚ)
- `Real` (continuous, order type ℝ)
- Any product group with lexicographic order
- Any subgroup of ℝ

From `TaskFrame.lean` lines 93-97, a `TaskFrame D` for such a D requires:
- `WorldState : Type` (unconstrained)
- `task_rel : WorldState → D → WorldState → Prop`
- `nullity_identity` (zero duration = identity)
- `forward_comp` (non-negative durations compose additively)
- `converse` (temporal symmetry via negation)

**Semantic characterization**: Base TM validity is truth in ALL task frames over ALL LOAGs. The class is NOT characterized by density or discreteness conditions (those are additional constraints for `valid_dense` and `valid_discrete` respectively). There is no explicit "frame condition" beyond the LOAG structure on D itself plus the three frame axioms (nullity_identity, forward_comp, converse).

**Key insight**: The paper (JPL paper app:TaskSemantics, def:frame, line 1835) requires D to be a totally ordered abelian group. The Lean `valid` predicate matches this exactly. `IsOrderedAddMonoid` plus `AddCommGroup` plus `LinearOrder` together constitute a linearly ordered abelian group in Mathlib.

---

### 2. Well-Formedness of the Completeness Statement

**Is it meaningful to say "φ is valid over all LOAGs" for base TM?**

The completeness statement takes the form:
```
∀ φ, valid φ → provable φ
```
equivalently (by contrapositive):
```
∀ φ, ¬provable φ → ∃ D [LOAG D] (F : TaskFrame D) ..., ¬truth_at ... φ
```

This is a perfectly well-formed mathematical statement. The concern is whether the universal quantification over ALL D is the "right" notion, or whether validity over a specific D (e.g., Int) would be more appropriate.

**Can a formula be valid over Int but not over Rat, or vice versa?**

Yes, this is the precise point of the density axiom DN: `F(φ) → F(F(φ))`. This formula is:
- Valid over `Rat` (densely ordered) — because between any two times there is a third
- NOT valid over `Int` (discrete) — because F(φ) at t only requires witness at t+1, and F(F(φ)) would need witness strictly between t and t+1, which doesn't exist

Similarly, the discreteness axioms DF/DP distinguish Int from Rat.

**For base TM (without DN, DF, DP)**: The provable theorems are exactly those valid in ALL LOAGs. The completeness statement says: if φ is provable from the base TM axioms, then φ is true in every LOAG frame; and conversely, if φ fails in some LOAG frame, then φ is not provable.

**Is this well-formed?** Yes. The base TM axioms define precisely the formulas valid in ALL LOAG task frames. The completeness proof merely needs to produce ONE countermodel in SOME LOAG. The `parametric_algebraic_representation_conditional` theorem (ParametricRepresentation.lean line 255) already captures this correctly:

```lean
theorem parametric_algebraic_representation_conditional
    (φ : Formula) (h_not_prov : ¬Nonempty (...))
    (construct_bfmcs : (M : Set Formula) → SetMaximalConsistent M →
      Σ' (B : BFMCS D) (h_tc : B.temporally_coherent)
         (fam : FMCS D) (hfam : fam ∈ B.families) (t : D),
         M = fam.mcs t) :
    ∃ ..., ¬truth_at (ParametricCanonicalTaskModel D) ...
```

**This is parametric in D**: provide a `construct_bfmcs` for ANY particular D, and you get a completeness proof over that D. Completeness for base TM is proven by instantiating with any convenient D.

**Conclusion**: The completeness statement is well-formed. The universal quantification in `valid` is appropriate. To prove completeness, it suffices to exhibit countermodels for any specific D that supports a BFMCS construction.

---

### 3. Fundamental Blockers Analysis

**Why does IntBFMCS have forward_F/backward_P sorries while CanonicalFMCS is sorry-free?**

The sorries are at `IntBFMCS.lean` lines 1175, 1177, 1199, 1213. The code comments (lines 1157-1174) explain:

```
FUNDAMENTAL BLOCKER (Task 1004 research):
Linear chain constructions cannot satisfy forward_F because F-formulas
don't persist through generic Lindenbaum extensions. When we build position
n+1 from position n, the Lindenbaum extension can introduce G(~phi), which
kills F(phi) = ~G(~phi).
```

**Why is this fundamental and not just a proof gap?**

Consider the `intChainMCS` construction (IntBFMCS.lean lines ~1136-1177):
- Position 0: seed MCS M₀ (contains F(p))
- Position 1: Lindenbaum extension of g_content(M₀)

The Lindenbaum extension is maximally consistent by taking any consistent extension. There is no constraint preventing it from including G(~p). Once G(~p) is at position 1, by the FMCS axiom `forward_G`, ~p is in ALL positions ≥ 1. The F(p) witness — an MCS containing p — cannot appear anywhere in the chain.

This is not a bug in the Lindenbaum lemma; it reflects the logical independence of F(p) from the constraint that the chain be built from g_content. The g_content of M₀ (i.e., {φ : G(φ) ∈ M₀}) does NOT contain G(~p) if F(p) = ~G(~p) is in M₀. But after Lindenbaum extension, G(~p) can be added if it is consistent with g_content(M₀), which it is if the particular formula p is irrelevant to the rest of the theory.

**Why CanonicalFMCS is sorry-free (CanonicalFMCS.lean lines 226-269):**

The domain for `canonicalMCSBFMCS` is ALL maximal consistent sets (the type `CanonicalMCS`). The `forward_F` proof is:

```lean
theorem canonicalMCS_forward_F (w : CanonicalMCS) (phi : Formula)
    (h_F : Formula.some_future phi ∈ canonicalMCS_mcs w) :
    ∃ s : CanonicalMCS, w ≤ s ∧ phi ∈ canonicalMCS_mcs s := by
  obtain ⟨W, h_W_mcs, h_R, h_phi_W⟩ := canonical_forward_F w.world w.is_mcs phi h_F
  let s : CanonicalMCS := { world := W, is_mcs := h_W_mcs }
  exact ⟨s, CanonicalMCS.le_of_canonicalR w s h_R, h_phi_W⟩
```

The key lemma `canonical_forward_F` (from `CanonicalFrame.lean`) guarantees existence of an MCS W with `CanonicalR w.world W` and `phi ∈ W`. Because `CanonicalMCS` = ALL MCSes, W is automatically in the domain as `s = { world := W, is_mcs := h_W_mcs }`. No reachability check. No Lindenbaum extension needed. The witness is found in the full space.

**Is this a construction problem or a fundamental semantic incompatibility?**

It is a **fundamental construction problem** for linear chains, not a semantic incompatibility. The logic TM IS complete (it has the FMP, as established by prior research). The problem is that building a linearly-indexed BFMCS from the bottom up (Lindenbaum step-by-step) cannot guarantee F/P witnesses remain in the chain. The solution requires either:
1. Using a non-linear index type (CanonicalMCS), OR
2. Using a finite filtration (FMP approach), OR
3. Building witnesses into the chain before Lindenbaum (omega-squared approach)

---

### 4. CanonicalMCS vs TaskFrame Mismatch

**Is this mismatch fundamental or bridgeable?**

**The type-level mismatch:**

| | `FMCS CanonicalMCS` (CanonicalFMCS.lean) | `TaskFrame D` (TaskFrame.lean) |
|--|--|--|
| Index/duration type | `CanonicalMCS` | `D : Type` |
| Required structure on D | `[Preorder D]` | `[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]` |
| What D is | All MCSes (a set of type `Set Formula`) | An abstract LOAG (Int, Rat, etc.) |
| Order structure | Preorder only (CanonicalR; NOT total) | Total linear order |
| Group structure | None | Full abelian group |

**Why CanonicalMCS cannot satisfy the TaskFrame constraints:**

From `BFMCS.lean` line 57: `BFMCS` requires `[Preorder D]` only. The BFMCS and FMCS structures work with just a Preorder. The mismatch is at a HIGHER level: `TaskFrame D` requires the full LOAG structure on D.

Concretely:
- `CanonicalMCS` has no `Add : CanonicalMCS → CanonicalMCS → CanonicalMCS` operation (adding MCSes makes no sense)
- `CanonicalMCS` has no `Zero : CanonicalMCS` (except artificially via `CanonicalMCS.instZero` using a specific root MCS as zero — but this is not a genuine zero element for any group)
- `CanonicalMCS` has no `Neg : CanonicalMCS → CanonicalMCS` (no negation/inverse of an MCS)
- `CanonicalMCS` ordering (via CanonicalR) is NOT total: two MCSes may be incomparable

From `CanonicalFMCS.lean` lines 59-63:
```
The FMCS and TemporalCoherentFamily only require [Preorder D], not totality.
The completeness chain (TruthLemma, Completeness) does NOT use totality, IsTotal,
or LinearOrder. So using the non-total CanonicalR Preorder on all MCSes is sound.
```

**The ParametricCanonicalTaskFrame resolution:**

`ParametricCanonical.lean` provides a sorry-free `TaskFrame D` for any LOAG D:

```lean
def ParametricCanonicalTaskFrame (D : Type*) [AddCommGroup D] [LinearOrder D]
    [IsOrderedAddMonoid D] : TaskFrame D where
  WorldState := ParametricCanonicalWorldState  -- = { M : Set Formula // SetMaximalConsistent M }
  task_rel := parametric_canonical_task_rel    -- sign-based: d>0 ↔ CanonicalR M N
```

This **separates** the two roles:
- **World states** = MCSes (D-independent)
- **Duration type** = D (the LOAG parameter)

The task relation `parametric_canonical_task_rel M d N` uses the SIGN of `d ∈ D`:
- d > 0: `CanonicalR M.val N.val` (forward temporal accessibility)
- d = 0: `M = N` (identity)
- d < 0: `CanonicalR N.val M.val` (backward direction)

This is a legitimate `TaskFrame D` for ANY D. The mismatch is now at the BFMCS level: we need a `BFMCS D` (not `BFMCS CanonicalMCS`) to feed into `ParametricHistory.lean`.

**The bridge problem:**

`parametric_to_history` (ParametricHistory.lean line 62) converts a `FMCS D` to a `WorldHistory (ParametricCanonicalTaskFrame D)`. It requires `fam : FMCS D`, i.e., the FMCS must be indexed by D.

But `canonicalMCSBFMCS` is `FMCS CanonicalMCS`, not `FMCS D`. These are different types.

**Is bridging feasible?**

The prior attempts (IntFMCSTransfer.lean, CanonicalEmbedding.lean) tried to map CanonicalMCS → D injectively. This fails because:
- CanonicalMCS has cardinality 2^ℵ₀ (uncountably many MCSes over a countable formula language)
- Int has cardinality ℵ₀

However, the **correct bridge** is already in place via the `ParametricCanonicalTaskFrame`:

The BFMCS needed for completeness does NOT have to be `BFMCS CanonicalMCS`. What we need is:
- A `BFMCS D` for some concrete D (say D = Int)
- With `temporally_coherent` (forward_F/backward_P in each family)
- With modal coherence (modal_forward/modal_backward)

The `ParametricCanonicalTaskFrame D` provides the semantic frame; the BFMCS provides the proof-theoretic model. The problem is constructing the BFMCS, not the TaskFrame.

**Alternative bridge: Relax TaskFrame to Preorder**

As noted in the prior teammate-a report, one could define:
```lean
structure WeakTaskFrame (D : Type*) [Preorder D] where ...
```
and restate validity/completeness for this weaker class. Then `CanonicalMCS` (with its Preorder) COULD serve as D. However:

1. This would change the semantics — the paper specifically requires a LOAG
2. The resulting completeness theorem would be weaker (valid over all preorder frames, not all LOAG frames)
3. The gap between preorder completeness and LOAG completeness would need to be addressed separately

**Conclusion on the mismatch**: The mismatch between `FMCS CanonicalMCS` (Preorder-indexed) and `TaskFrame D` (LOAG-indexed) is **fundamental at the type level but bridgeable architecturally**. The correct bridge is the `ParametricCanonicalTaskFrame`, which already exists and is sorry-free. What remains is constructing `BFMCS D` (for D = Int) with temporal and modal coherence. The prior approach of trying to TRANSFER from `CanonicalMCS` to `Int` by bijection fails (cardinality mismatch), but the `ParametricCanonicalTaskFrame` approach avoids this by using MCSes as WORLD STATES within a D-indexed frame.

---

## Recommended Approach

**Primary**: Use the existing `ParametricCanonicalTaskFrame D` infrastructure and construct `BFMCS Int` directly, exploiting the FMP (Finite Model Property).

The FMP approach (recommended by prior Teammate B research, confirmed by prior research in reports 03_teammate-b-findings.md and 03_team-research.md) is the cleanest path:

1. TM has FMP: any non-valid formula has a FINITE countermodel
2. Finite task frames have finite world state sets
3. The F/P witness problem disappears: in a finite model, witnesses are explicitly enumerable
4. Completeness follows from: ¬provable → ¬valid → finite countermodel exists → countermodel within `ParametricCanonicalTaskFrame`

**Key architectural insight not yet exploited**: The `temporal_coherent_family_exists_CanonicalMCS` theorem (CanonicalFMCS.lean line 312) is already sorry-free. To make it serve completeness for `TaskFrame D`:

We need `BFMCS D` satisfying `temporally_coherent` and `modal_backward`. These two conditions are independent:
- **Temporal coherence**: Supplied by FMP (finite witnesses, no chain extension problem)
- **Modal coherence (modal_backward)**: Supplied by using ALL Box-equivalence-class representatives as families

The FMP route constructs a FINITE `BFMCS Int` where:
- Each family is a finite filtration-based MCS family
- F/P witnesses are trivial because the formula set is closure-bounded
- Modal saturation is achievable because there are only finitely many equivalence classes

---

## Evidence/Examples

### Code Evidence 1: ParametricHistory shows domain = True sidesteps convexity

`ParametricHistory.lean` line 63-64:
```lean
domain := fun _ => True
convex := fun _ _ _ _ _ _ _ => True.intro
```
The `domain = True` means every time point t : D is in scope. This sidesteps the convexity problem that blocked earlier FlagBFMCS approaches.

### Code Evidence 2: BFMCS and FMCS only require Preorder

`BFMCS.lean` line 57: `variable (D : Type*) [Preorder D]`
`FMCSDef.lean` line 78: `variable (D : Type*) [Preorder D]`

Neither BFMCS nor FMCS requires AddCommGroup on D. Only `ParametricHistory.lean` (and its `respects_task` proof) requires the LOAG structure, because `TaskFrame D` requires it.

### Code Evidence 3: BFMCS.temporally_coherent works over any Preorder

`TemporalCoherence.lean` line 43: `variable {D : Type*} [Preorder D] [Zero D]`
`BFMCS.temporally_coherent` (line 217) only requires `[Preorder D] [Zero D]`.

This means a `BFMCS CanonicalMCS` with `temporally_coherent` CAN be constructed (CanonicalMCS has a Preorder and a Zero via `CanonicalMCS.instZero`). The gap is that `BFMCS CanonicalMCS` cannot be directly used as a `BFMCS D` for D = Int.

### Code Evidence 4: The parametric_algebraic_representation_conditional is the right interface

The conditional theorem (ParametricRepresentation.lean line 255) takes any `construct_bfmcs` for BFMCS D and produces a completeness proof. The **only missing piece** is:

```lean
construct_bfmcs : (M : Set Formula) → SetMaximalConsistent M →
  Σ' (B : BFMCS Int) (h_tc : B.temporally_coherent)
     (fam : FMCS Int) (hfam : fam ∈ B.families) (t : Int),
     M = fam.mcs t
```

This is exactly what the FMP would provide: given any consistent formula, the finite model witnessing its satisfiability gives us the BFMCS Int.

---

## Confidence Level

**High** for the analysis of what base TM validity means and why the mismatch exists.

**High** for the conclusion that the mismatch is architectural (not semantic) and that the ParametricCanonicalTaskFrame correctly handles it.

**Medium** for the claim that the FMP is the right resolution path — this depends on the FMP infrastructure being complete enough to build `BFMCS Int` with temporal and modal coherence, which has not yet been fully verified (see prior Teammate B findings for the FMP infrastructure status).

**High** that the forward_F/backward_P sorries in IntBFMCS.lean are genuinely fundamental for linear chain constructions and cannot be resolved without either a different construction technique (FMP, omega-squared) or a different index type (CanonicalMCS).
