# Research Report: Task #77 — Time-Shift Invariance Analysis for BTM

**Task**: 77 - research_preorder_taskframe_generalization (Follow-up)
**Date**: 2026-03-31
**Focus**: Time-shift invariance under preorder semantics
**Session**: sess_1774980147_15379d

## Executive Summary

The user's claim is **PARTIALLY TRUE but SUBTLE**. Branching histories over preorders CAN admit time-shift operations, but the shift-closure property needed for the truth lemma becomes TRIVIAL to satisfy in the canonical construction. The root cause is NOT that branching prevents time-shift — it's that the canonical model for BTM uses a DIFFERENT construction where Omega is defined by family membership, and shifted histories naturally remain in Omega.

**Key Finding**: The F/P witness blocker for full TM is actually INDEPENDENT of time-shift invariance. BTM completeness doesn't require "sliding histories" in the geometric sense — it requires the weaker property that `ShiftClosed(Omega)` holds for the canonical Omega set.

## Analysis

### 1. What Does ShiftClosed Actually Require?

From `Truth.lean` (lines 236-238):

```lean
def ShiftClosed (Omega : Set (WorldHistory F)) : Prop :=
  ∀ σ ∈ Omega, ∀ (Δ : D), WorldHistory.time_shift σ Δ ∈ Omega
```

This says: for any history σ in Omega and any duration Δ, the time-shifted history `time_shift σ Δ` must also be in Omega.

**Critical Observation**: This is a property of the SET Omega, not of individual histories. The algebraic time-shift operation itself is ALWAYS well-defined for any `[AddCommGroup D]` — you can always add Δ to time indices. The question is whether the resulting history stays in your chosen Omega set.

### 2. Time-Shift Operation Under Preorder

From `WorldHistory.lean` (lines 238-260), the time-shift construction is:

```lean
def time_shift (σ : WorldHistory F) (Δ : D) : WorldHistory F where
  domain := fun z => σ.domain (z + Δ)
  convex := [preserved by translation]
  states := fun z hz => σ.states (z + Δ) hz
  respects_task := [preserved because duration (t-s) is invariant under translation]
```

**Key Insight**: The time-shift operation only requires:
1. `[AddCommGroup D]` — to add Δ to time indices
2. Convexity preservation — convex domains are closed under translation
3. Task relation preservation — durations are translation-invariant

**NONE of these require `[LinearOrder D]`!** The time-shift operation is perfectly well-defined over preorders.

### 3. Where Does Linearity Actually Matter?

The linearity axiom `temp_linearity`:
```
F(φ) ∧ F(ψ) → F(φ ∧ ψ) ∨ F(φ ∧ F(ψ)) ∨ F(F(φ) ∧ ψ)
```

This axiom characterizes that for any two future witnesses s₁ and s₂:
- Either s₁ = s₂ (first disjunct)
- Or s₁ < s₂ (second disjunct)
- Or s₂ < s₁ (third disjunct)

This is a SEMANTIC property of how worlds relate, not a property of time-shift operations.

**The user's intuition is CORRECT** that branching breaks this trichotomy — with incomparable branches, you can have F(p) witnessed at branch A and F(q) witnessed at branch B with A, B incomparable. But this doesn't affect the algebraic time-shift operation.

### 4. Why BTM Doesn't Need Time-Shift for the F/P Witness Problem

The F/P witness problem is:
> Given F(φ) ∈ MCS(t), we need to find s > t with φ ∈ MCS(s) **within the same family**.

In full TM with linear time, this is hard because:
- There may be infinitely many F-obligations
- All witnesses must coexist on the SAME linear timeline
- No finite construction can accommodate unbounded future witnesses

In BTM with preorder time:
- F-witnesses can be on DIFFERENT branches
- The canonical construction uses D = CanonicalMCS (the set of all MCS)
- The preorder is the CanonicalR relation (content inclusion)
- Each F(φ) at M gets a witness by Lindenbaum extension of {φ} ∪ g_content(M)
- These witnesses are NOT required to be on the same linear chain

**This is why BTM completeness "works" — the preorder structure doesn't force witnesses onto a single timeline.**

### 5. Time-Shift and the Truth Lemma

The truth lemma for Box (from `ParametricTruthLemma.lean` lines 428-461):

```lean
| box ψ ih =>
  -- Forward: Box ψ in fam.mcs t -> forall sigma in ShiftClosedParametricCanonicalOmega B, truth_at ... sigma t ψ
  intro h_box σ h_σ_mem
  -- sigma = time_shift (parametric_to_history fam') delta for some fam', delta
  -- Use parametric_box_persistent: Box ψ persists to all times
  -- Use modal_forward: ψ in fam'.mcs (t + delta)
  -- Use time_shift_preserves_truth to relate shifted and unshifted
```

**Key insight**: The proof uses:
1. `parametric_box_persistent`: Box φ persists to all times (TF axiom consequence)
2. `modal_forward`: Modal saturation across families
3. `time_shift_preserves_truth`: Relating truth at shifted vs unshifted histories

The TF axiom (□φ → G□φ) is what makes Box formulas persist across time-shifts. This axiom is STILL VALID under preorder semantics because:
- It says "if φ is necessary at all histories NOW, then at all future times, φ is necessary at all histories"
- This doesn't require linearity — it only requires that the temporal ordering exists

### 6. The Geometric Intuition Explained

The user's geometric intuition — "you can't slide branching histories forwards/backwards" — is appealing but imprecise:

**What IS true**:
- In a branching structure, different branches may not have the same "shape"
- You cannot translate a history from one branch to another and preserve the branching pattern

**What is NOT the issue**:
- You CAN always translate within a single branch (single linear chain)
- The time-shift operation translates the DOMAIN, not the branching structure
- For the truth lemma, we only need shift-closure of Omega, not geometric congruence of branches

**The correct statement**: In BTM, the canonical Omega is `{parametric_to_history fam | fam ∈ B.families}` union with all their time-shifts. Since each family corresponds to a linear chain through the preorder, time-shifts within that chain stay coherent.

### 7. Root Cause Analysis

| Candidate Root Cause | Analysis | Verdict |
|---------------------|----------|---------|
| Preorder lacks translation | AddCommGroup provides translation | NOT THE CAUSE |
| Branches can't be slid | True geometrically, but irrelevant to ShiftClosed | NOT THE CAUSE |
| Incomparable elements | Affects temp_linearity validity, not time-shift | CONTRIBUTES but not blocking |
| No total order | Means temp_linearity fails, but BTM drops it | ACKNOWLEDGED |
| Canonical Omega definition | BTM uses different Omega that IS shift-closed | KEY DIFFERENCE |

**ROOT CAUSE**: The user's concern conflates TWO distinct issues:
1. **Linearity of time** — required for temp_linearity, dropped in BTM
2. **Algebraic time-shift** — requires only AddCommGroup, preserved in BTM

### 8. Implications for the Truth Lemma

**Full TM Truth Lemma**:
- Requires `ShiftClosed(Omega)` for the box case
- Omega = all histories in the canonical model
- Time-shift preserves truth: proven in `Truth.lean`
- WORKS for any `[AddCommGroup D] [LinearOrder D]`

**BTM Truth Lemma**:
- Would use `[AddCommGroup D] [Preorder D]`
- ShiftClosed still well-defined and satisfiable
- The FMCS construction works the same way
- Modal coherence (Box forward/backward) unchanged
- Temporal forward/backward use preorder ≤, still valid

**The truth lemma does NOT require linearity for the time-shift mechanism.**

### 9. Which Logic Should Be Prioritized?

| Logic | Key Axiom Status | Completeness Difficulty | Recommendation |
|-------|------------------|------------------------|----------------|
| **Full TM** | temp_linearity included | F/P witness blocker | Hard, requires FMP/filtration |
| **BTM** | temp_linearity dropped | F/P blocker vanishes | **EASIER, prioritize first** |
| **Dense TM** | density added | Same as TM + density constraint | Medium, after TM |
| **Discrete TM** | discreteness added | Same as TM + discreteness | Medium, after TM |

**Strategic Recommendation**: Prove BTM completeness FIRST because:
1. No F/P witness blocker
2. Simpler canonical construction
3. Demonstrates the parametric machinery works
4. Provides baseline for understanding what linearity adds

Then tackle full TM via filtration/FMP, which bounds the F-obligations.

## Mathematical Details

### Time-Shift Preserves Truth (Preorder Version)

The theorem `time_shift_preserves_truth` from `Truth.lean` lines 350-503:

```lean
theorem time_shift_preserves_truth (M : TaskModel F) (Omega : Set (WorldHistory F))
    (h_sc : ShiftClosed Omega) (σ : WorldHistory F) (x y : D)
    (φ : Formula) :
    truth_at M Omega (WorldHistory.time_shift σ (y - x)) x φ ↔ truth_at M Omega σ y φ
```

**Proof structure** (by induction on φ):
- **Atom**: Domain shifts with time, states are equal by translation
- **Bot**: Both sides False
- **Imp**: By IH on subformulas
- **Box**: Uses `ShiftClosed(Omega)` to ensure shifted histories stay in Omega
- **G/H**: Times shift together, ordering preserved under translation

**Critical observation for preorder**: The proof uses:
- `add_sub` lemmas (AddCommGroup)
- `add_le_add_right` (ordered additive structure)
- `ShiftClosed` assumption for Box case

NONE of these require totality/linearity. They work for any ordered additive group over a preorder.

### What Preorder Loses

The ONLY place linearity matters semantically is in the validity of `temp_linearity`:

```lean
-- Requires linear order to prove:
-- Given s₁ ≥ t with φ true and s₂ ≥ t with ψ true,
-- by trichotomy: s₁ < s₂ or s₁ = s₂ or s₁ > s₂
-- This gives one of the three disjuncts
```

Without linearity, you can have s₁ || s₂ (incomparable), and the axiom fails.

**BTM accepts this**: By dropping temp_linearity, BTM is sound over preorder frames and complete via the standard canonical construction.

## Risks and Considerations

### Risk 1: PreorderTaskFrame Axiom Compatibility

**Question**: Do `nullity_identity`, `forward_comp`, and `converse` still make sense over preorders?

**Analysis**:
- `nullity_identity`: `task_rel w 0 u ↔ w = u` — requires zero element, not linearity
- `forward_comp`: `0 ≤ x → 0 ≤ y → task_rel w x u → task_rel u y v → task_rel w (x+y) v` — requires preorder for `0 ≤ x`
- `converse`: `task_rel w d u ↔ task_rel u (-d) w` — requires group inverse, not linearity

**Verdict**: All three axioms are well-defined over `[AddCommGroup D] [Preorder D]`.

### Risk 2: WorldHistory Convexity

**Question**: Does convexity make sense in a preorder?

**Analysis**: Convexity is defined as:
```lean
convex : ∀ (x z : D), domain x → domain z → ∀ (y : D), x ≤ y → y ≤ z → domain y
```

This says "between x and z (in the preorder sense), domain is filled in."

In a preorder, "between" can have multiple paths. If x ≤ y ≤ z along one path but y' on a different branch also has x ≤ y' ≤ z, convexity requires BOTH y and y' to be in the domain.

**Implication**: BTM world histories may have "wider" domains than linear TM histories. This is FINE for soundness and completeness — it just means histories cover more temporal possibilities.

### Risk 3: FMCS Forward/Backward Requirements

**Question**: Do `forward_G`, `backward_H`, `forward_F`, `backward_P` work over preorders?

**Analysis**:
- `forward_G`: `t ≤ s → G(φ) ∈ mcs t → φ ∈ mcs s` — uses preorder ≤
- `backward_H`: `s ≤ t → H(φ) ∈ mcs t → φ ∈ mcs s` — uses preorder ≤
- `forward_F`: `F(φ) ∈ mcs t → ∃ s, t ≤ s ∧ φ ∈ mcs s` — uses preorder ≤
- `backward_P`: `P(φ) ∈ mcs t → ∃ s, s ≤ t ∧ φ ∈ mcs s` — uses preorder ≤

**Verdict**: All four properties are well-defined over preorders. The key difference is that the witness in `forward_F` need not be on the same linear chain as t — it can be on ANY branch with t ≤ s.

## Conclusions

### Answer to Research Questions

**Q1: Is the user's claim TRUE or FALSE?**

**PARTIALLY TRUE, MOSTLY FALSE.**
- TRUE: Branching breaks the temp_linearity axiom
- TRUE: Different branches don't have congruent "shapes" for sliding
- FALSE: Time-shift operations ARE well-defined over preorders
- FALSE: ShiftClosed property CAN be satisfied in BTM canonical construction

**Q2: What is the ROOT CAUSE?**

The conflation of two distinct concepts:
1. **Temporal linearity** — a semantic property requiring trichotomy
2. **Algebraic time-shift** — an algebraic operation requiring only AddCommGroup

Branching breaks (1) but not (2). BTM completeness only needs (2).

**Q3: Implications for truth lemma and completeness?**

- Truth lemma: `time_shift_preserves_truth` works unchanged for preorders
- ShiftClosed: The canonical Omega can be made shift-closed by construction
- Box case: Uses TF axiom (still valid) and ShiftClosed (still satisfiable)
- G/H cases: Use preorder ≤ instead of linear order <, still work

**Q4: Which logic to prioritize?**

**BTM FIRST**, then full TM via filtration/FMP.

## Recommendations

### Immediate Actions

1. **Define PreorderTaskFrame** in Lean:
   ```lean
   structure PreorderTaskFrame (D : Type*) [AddCommGroup D] [Preorder D] where
     WorldState : Type
     task_rel : WorldState → D → WorldState → Prop
     nullity_identity : ∀ w u, task_rel w 0 u ↔ w = u
     forward_comp : ∀ w u v x y, 0 ≤ x → 0 ≤ y → task_rel w x u → task_rel u y v → task_rel w (x + y) v
     converse : ∀ w d u, task_rel w d u ↔ task_rel u (-d) w
   ```

2. **Verify time-shift works** over PreorderTaskFrame (should be trivial given current proof)

3. **Define BTM axiom system** (TM minus temp_linearity)

4. **Prove BTM completeness** using the existing parametric machinery with D = CanonicalMCS

### Medium-Term

5. **Investigate FMP for full TM** — filtration by closure(φ) makes F-obligations finite

6. **Establish BTM-TM relationship** — prove temp_linearity is independent, show BTM ⊂ TM

## References

### Key Source Files

| File | Relevance |
|------|-----------|
| `Theories/Bimodal/Semantics/Truth.lean` | ShiftClosed definition, time_shift_preserves_truth |
| `Theories/Bimodal/Semantics/WorldHistory.lean` | time_shift construction |
| `Theories/Bimodal/Semantics/TaskFrame.lean` | TaskFrame axioms |
| `Theories/Bimodal/Metalogic/Algebraic/ParametricTruthLemma.lean` | Truth lemma for Box case |
| `Theories/Bimodal/Metalogic/Bundle/TemporalCoherence.lean` | forward_F, backward_P |
| `Theories/Bimodal/ProofSystem/Axioms.lean` | temp_linearity axiom |

### Prior Research

- `specs/077_research_preorder_taskframe_generalization/reports/01_team-research.md` — BTM proposal, F/P blocker analysis
