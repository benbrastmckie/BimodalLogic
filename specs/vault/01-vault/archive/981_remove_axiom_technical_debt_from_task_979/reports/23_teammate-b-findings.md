# Research Report: Task #981 - Teammate B Findings (Alternative Approaches)

**Task**: 981 - remove_axiom_technical_debt_from_task_979
**Date**: 2026-03-18
**Session**: sess_1773867883_4f74c5
**Role**: Teammate B - Alternative approaches to the dense completeness sorry
**Focus**: Alternative paths that avoid the primary blocker in TimelineQuotCompleteness.lean:127

---

## Executive Summary

Three mathematically sound alternative approaches exist for completing the dense completeness
proof, all avoiding the primary blocker (truth lemma over TimelineQuot). The strongest
alternative is the **D-parametric approach with D = Rat**, which leverages already-proven
infrastructure in ParametricRepresentation.lean and DenseInstantiation.lean. This path
requires only constructing a temporally coherent BFMCS over Rat from an MCS - a construction
that is fully supported by CanonicalFMCS.lean's sorry-free `temporal_coherent_family_exists_CanonicalMCS`.

The critical insight: `CanonicalMCS` already has sorry-free F/P witness construction,
and `ParametricRepresentation.lean` provides the full representation theorem. The gap
for dense completeness is bridging from `FMCS CanonicalMCS` to `BFMCS Rat` - but this
may not actually be needed if we can work with `valid_over Rat` instead of `valid_over D`
for arbitrary D.

---

## Key Findings

### Finding 1: The D-Parametric Infrastructure Is Already Complete

The file `ParametricRepresentation.lean` contains a fully proven theorem:

```lean
theorem parametric_algebraic_representation_conditional
    (φ : Formula) (h_not_prov : ¬Nonempty (DerivationTree [] φ))
    (construct_bfmcs : (M : Set Formula) → SetMaximalConsistent M →
      Σ' (B : BFMCS D) (h_tc : B.temporally_coherent)
         (fam : FMCS D) (hfam : fam ∈ B.families) (t : D), M = fam.mcs t) :
    ∃ (B : BFMCS D) (...), ¬truth_at (ParametricCanonicalTaskModel D) ...
```

This conditional form says: **if** you can construct a temporally coherent BFMCS over D
containing any given MCS, **then** non-provability implies a countermodel.

### Finding 2: CanonicalMCS Already Has Sorry-Free F/P Witnesses

The file `CanonicalFMCS.lean` proves `temporal_coherent_family_exists_CanonicalMCS`:

```lean
theorem temporal_coherent_family_exists_CanonicalMCS
    (Gamma : List Formula) (h_cons : ContextConsistent Gamma) :
    ∃ (fam : FMCS CanonicalMCS) (root : CanonicalMCS),
      (∀ gamma ∈ Gamma, gamma ∈ fam.mcs root) ∧
      forward_F_prop ∧ backward_P_prop
```

This is **sorry-free**. The F/P witnesses work because CanonicalMCS uses ALL MCSs as the
domain, so any witness MCS is automatically in the domain.

### Finding 3: `DenseInstantiation.lean` Has the Conditional Dense Theorem

The file `DenseInstantiation.lean` provides:
- `DenseCanonicalTaskFrame` = `ParametricCanonicalTaskFrame Rat` (sorry-free)
- `dense_representation_conditional` = the representation theorem for D=Rat (sorry-free)
- The ONLY gap is providing the `construct_bfmcs` argument for BFMCS over Rat

### Finding 4: `AlgebraicBaseCompleteness.lean` Has Two Sorry-Backed Constructions

Two sorries in `AlgebraicBaseCompleteness.lean` are relevant:
1. `singleFamilyBFMCS` (line 104): Blocked because `modal_backward` fails for single-family
2. `construct_bfmcs_from_mcs` (line 155): General BFMCS construction, blocked by F/P

These sorries are in the BFMCS construction path but are **not on the direct completion path**.

### Finding 5: The ModalSaturation Module Exists But Is Unused

`ModalSaturation.lean` defines `is_modally_saturated` and `saturated_modal_backward`.
A modally saturated BFMCS automatically satisfies `modal_backward`. This infrastructure
is available but not yet used to build a sorry-free BFMCS over Rat.

### Finding 6: The `valid_dense` Definition Quantifies over ALL Dense D

The dense completeness theorem quantifies over ALL types D with DenselyOrdered:
```lean
theorem dense_completeness_theorem {φ : Formula} :
    (∀ (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
       [Nontrivial D] [NoMaxOrder D] [NoMinOrder D] [DenselyOrdered D]
       [DenseTemporalFrame D], valid_over D φ) →
    Nonempty ([] ⊢ φ)
```

For the contrapositive proof, we only need to find ONE dense D where phi fails.
Rat is a canonical dense D, so `valid_over Rat phi` failing suffices.

---

## Alternative Approaches Found

### Approach A: D-Parametric Algebraic Completeness via BFMCS Rat (RECOMMENDED)

**Description**: Use the existing `ParametricRepresentation` infrastructure with D = Rat,
constructing a BFMCS Rat from the CanonicalMCS infrastructure.

**Key insight**: Instead of trying to build the BFMCS directly over Rat (which requires
F/P witnesses indexed by Rat), we can convert the CanonicalMCS-indexed FMCS into a
BFMCS over Rat by using a constant-time embedding.

**The core gap**: We need `construct_bfmcs : (M : Set Formula) → SetMaximalConsistent M → Σ' (B : BFMCS Rat) ...`

**How to fill the gap**:
The `canonical_coherent_family_exists_CanonicalMCS` gives us `FMCS CanonicalMCS`.
We need to "realize" this over Rat. One path:
- Build a `FMCS Rat` from an `FMCS CanonicalMCS` by post-composing with a monotone map
- CanonicalMCS has a Preorder but not AddCommGroup; we cannot directly use `parametric_to_history`
- However, we can construct a **constant FMCS over Rat**: `mcs_rat(r) = M` for all r : Rat
- Constant FMCS over Rat satisfies forward_G/backward_H (via T-axiom: G phi -> phi)
- The F/P coherence fails for a constant FMCS (F phi in M does not imply phi in M)
- **Resolution**: Use the CanonicalMCS F/P witnesses as Rat witnesses via a dummy time

**Status**: This path is blocked by the F/P coherence of the constant FMCS, which is the
same obstacle as the Int-based approach. However, the density of Rat enables a variant.

**Density-specific variant**: Since Rat is densely ordered, for F(phi) in M, the density
axiom gives F(F(phi)) in M, and eventually F^n(phi) in M for all n. We can use this to
construct a chain of witnesses 0 < 1/2 < 3/4 < ... in Rat, each satisfying phi. This
directly exploits the DenselyOrdered property.

### Approach B: Direct Instantiation Using valid_over Rat

**Description**: Rather than proving completeness for arbitrary dense D, prove:
1. If phi not provable, then phi fails at (ParametricCanonicalTaskModel Rat, ...)
2. Since Rat is DenselyOrdered, this gives ¬(valid_over Rat phi)
3. Since the completeness hypothesis says valid_over D phi for ALL dense D,
   instantiating at D = Rat gives a contradiction

**Key advantage**: Avoids constructing a BFMCS over Rat. Instead uses the
`CanonicalMCS` FMCS + Cantor isomorphism.

**The connection**: We have a sorry-free FMCS CanonicalMCS. The Cantor isomorphism
gives TimelineQuot ≃o Rat. Can we transfer the CanonicalMCS FMCS truth to Rat?

**The mathematical argument** (for TimelineQuot):
- Build FMCS over TimelineQuot via `timelineQuotFMCS` (sorry-free, from TimelineQuotCanonical)
- timelineQuotFMCS assigns MCS(t) = timelineQuotMCS(t) to each t : TimelineQuot
- This is sorry-free (forward_G and backward_H are proven)
- phi.neg is in MCS(rootTime) = root_mcs (proven: `timelineQuotMCS_root_time_eq`)
- For truth lemma, we need a BFMCS containing this FMCS

**Remaining gap**: Building the BFMCS over TimelineQuot with:
- modal_backward: Box phi in mcs(t) iff phi in all families' mcs(t)

This is exactly the sorry being investigated. However, Approach B reframes the problem:
instead of needing the full biconditional truth lemma, we only need the **forward direction**
for the box case (Box phi true implies phi in mcs). This is just `modal_forward`.

### Approach C: Forward-Only Truth Lemma for Dense Completeness

**Description**: For the completeness direction (valid phi -> provable phi, via contrapositive),
we only need the BACKWARD direction of the truth lemma:
  `truth_at ... phi implies phi in fam.mcs t` (to derive contradiction from validity hypothesis)

And the FORWARD direction to show phi.neg is true:
  `phi.neg in fam.mcs t implies truth_at ... phi.neg at some t`

**Key insight**: The full biconditional truth lemma is needed for the correctness of the
truth lemma itself, but for completeness we can use a weaker version.

**What we need precisely**:
1. `phi.neg in root_mcs` (given by Lindenbaum)
2. Construct a model M, Omega, tau where `truth_at M Omega tau t phi.neg`
3. valid_over D phi means phi is true in all such models -> contradiction

For step 2, the forward direction of the truth lemma suffices:
  If phi.neg in mcs(t), and mcs is the "right" MCS assignment, then phi.neg is true at t.

The "right" MCS assignment is determined by the TimelineQuot FMCS:
- At rootTime: mcs = root_mcs (containing phi.neg)
- At other times: mcs = timelineQuotMCS(t)

**The box case**: The difficulty is in the box case of the forward truth lemma.
Box phi at time t in mcs means (by modal_forward of BFMCS): phi is true at all
families. This requires knowing the Omega set contains exactly the right histories.

**Approach**: Use a singleton Omega = {tau} where tau is the one history from timelineQuotFMCS.
For box, we need: Box phi in mcs(t) implies phi true at ALL histories in Omega.
With Omega = {tau}: Box phi in mcs(t) implies phi true at tau at t.

This requires: Box phi in mcs(t) and mcs(t) is the ONLY family -> phi true at tau.

But "phi true at tau at t" requires phi in mcs(t) (by the atom/truth correspondence).
And Box phi does NOT imply phi in mcs(t) under the strict semantics (no T-axiom for G/H).

However, for the **modal** box, the TM modal T-axiom DOES hold: Box phi -> phi.
So Box phi in mcs(t) -> phi in mcs(t) (by modal_t axiom closure under MCS).

**Critical observation**: For the singleton Omega = {tau}, box phi at time t means:
`∀ sigma ∈ {tau}, truth_at M {tau} sigma t phi`
= `truth_at M {tau} tau t phi`

So the box case reduces to: Box phi in mcs(t) implies phi true at tau at t.
By modal_t (Box phi -> phi), phi in mcs(t), and by forward truth lemma for phi, phi true at tau at t.

This means for singleton Omega, the box forward direction of the truth lemma HOLDS
using only the modal T-axiom and forward direction of phi, with NO BFMCS machinery!

### Approach D: Transfer via Order Isomorphism (TimelineQuot ≃o Rat)

**Description**: Use the Cantor isomorphism `TimelineQuot ≃o Rat` to transfer a
countermodel from TimelineQuot to Rat.

**Mechanism**:
1. Construct countermodel over TimelineQuot using timelineQuotFMCS
2. The Cantor isomorphism gives a bijection f: TimelineQuot -> Rat preserving order
3. Define the Rat model by "pulling back" along f: mcs_rat(r) = mcs_tq(f^{-1}(r))
4. Truth is preserved under order isomorphism (since G/H/F/P only depend on order)
5. phi.neg is true at rootTime in TimelineQuot -> phi.neg is true at f(rootTime) in Rat

**Challenge**: "Pulling back" a model along an order isomorphism requires:
- The TaskFrame for Rat to be order-isomorphic to the TaskFrame for TimelineQuot
- The truth definition to be invariant under order isomorphism
- The model (valuation) to be compatible with the pullback

**Assessment**: This approach is mathematically sound but requires significant
infrastructure to formalize the "transfer along order isomorphism" property.
The Cantor isomorphism is non-constructive (uses AC), which may complicate
explicit computation of the transferred model.

---

## Pros and Cons of Each Approach

### Approach A: D-Parametric via BFMCS Rat

**Pros**:
- Uses existing D-parametric infrastructure (ParametricRepresentation.lean)
- DenseInstantiation.lean already frames the problem correctly
- Methodologically clean: proves completeness via the representation theorem framework

**Cons**:
- Still requires constructing BFMCS Rat with modal_backward
- The density argument for F/P witnesses over Rat requires non-trivial lemmas
- Rat indices for witnesses are arbitrary (no canonical choice)

**Estimated effort**: 8-16 hours

### Approach B: Direct via valid_over Rat (Reframes the problem)

**Pros**:
- Uses the existing Cantor isomorphism + TimelineQuot FMCS machinery
- Avoids the D=Rat specific BFMCS construction
- Mathematically cleaner: TimelineQuot IS the canonical dense domain

**Cons**:
- The blocking sorry is still needed (TimelineQuot truth lemma for box case)
- Doesn't actually bypass the current blocker, just reframes it

**Estimated effort**: Same as primary approach (no bypass)

### Approach C: Forward-Only Truth Lemma with Singleton Omega (KEY ALTERNATIVE)

**Pros**:
- **Avoids BFMCS entirely** - uses singleton Omega
- The box case is handled by modal T-axiom (Box phi -> phi)
- All required components are proven:
  - `timelineQuotFMCS`: G/H coherence for TimelineQuot (sorry-free)
  - `timelineQuotMCS_root_time_eq`: root MCS is correct (sorry-free)
  - modal T-axiom: available in all MCS
  - `timelineQuotParametricTaskFrame`: Sorry-free (ParametricCanonical.lean)
  - `SeparatedHistory`, `ShiftClosedSeparatedOmega`: sorry-free
- Does NOT require modal_backward (backwards direction of box case)

**Cons**:
- The temporal operators F (some_future) need witnesses in Omega for the backward
  direction of the truth lemma (G-backward: from truth of phi to G-phi in MCS)
- The completeness proof needs the BACKWARD direction of the truth lemma for phi
  (to derive contradiction: if valid phi, then phi in mcs)
- The backward direction of G (temporal_backward_G) requires temporal coherence
  (forward_F witnesses)

**Critical limitation**: For the backward direction of G-phi:
  `(∀ s > t, truth_at ... s phi) → G phi ∈ mcs(t)`
This uses `temporal_backward_G` which requires `TemporalCoherentFamily` (forward_F).
But forward_F for TimelineQuot requires witnesses in the TimelineQuot domain,
which is exactly what the dovetailed construction provides!

**Assessment**: Approach C is viable for the FORWARD direction (MCS membership -> truth).
For the completeness proof (contradiction from validity), we need the backward direction,
which requires the temporal coherence (forward_F). This is the original blocker.

**Revised assessment**: We need forward_F for TimelineQuot to handle the backward-G case
of the truth lemma. The dovetailed construction (DovetailedCoverage.lean) provides this,
but `dovetailedTimeline_has_future` is itself sorry-backed (the density argument gap).

### Approach D: Transfer via Order Isomorphism

**Pros**:
- Mathematically elegant
- Uses the Cantor isomorphism which is already proven

**Cons**:
- Requires new infrastructure for "model transfer along order isomorphism"
- Truth-invariance under order isomorphism is a non-trivial theorem
- The Cantor isomorphism is non-constructive

**Estimated effort**: 20+ hours for new infrastructure

---

## Evidence and Examples

### Evidence for Approach C Viability (Forward-Only Truth Lemma)

The `parametric_shifted_truth_lemma` in `ParametricTruthLemma.lean` has this structure
for the box case (forward direction):
```lean
intro h_box σ h_σ_mem
obtain ⟨fam', hfam', delta, h_σ_eq⟩ := h_σ_mem
have h_box_shifted := parametric_box_persistent fam ψ t (t + delta) h_box
have h_ψ_fam' := B.modal_forward fam hfam ψ (t + delta) h_box_shifted fam' hfam'
```

For singleton Omega = {tau}, h_σ_mem gives sigma = tau directly (no delta shifts needed
in the simplest case). The `modal_forward` requirement is replaced by the modal T-axiom.

### Evidence for Approach A Being the Main Highway

The `AlgebraicBaseCompleteness.lean` file shows the pattern:
```lean
theorem algebraic_base_completeness (phi : Formula) (h_valid : valid phi) :
    Nonempty (DerivationTree [] phi) := by
  ...
  obtain ⟨B, h_tc, fam, hfam, t, h_M_eq⟩ :=
    construct_bfmcs_from_mcs (D := Int) M h_mcs
```

This is the intended pattern for dense completeness with D = Rat. The `construct_bfmcs_from_mcs`
is sorry-backed for general D, but for D = CanonicalMCS it works (CanonicalFMCS.lean).

The dense completeness proof can instantiate `valid_dense phi` at D = TimelineQuot
(which is DenselyOrdered) and derive contradiction using the TimelineQuot FMCS machinery.
The one sorry needed is exactly in `timelineQuot_not_valid_of_neg_consistent`.

### Evidence for the Dovetailing Path (Forward-F for TimelineQuot)

From `DovetailedCompleteness.lean`, the structure is clear:
```lean
theorem dovetailed_dense_completeness {phi : Formula} :
    ... →  Nonempty ([] ⊢ phi) := by
  ...
  have h_not_valid : ¬valid_over (TimelineQuot M₀ h_M₀_mcs) phi := by
    have key := TimelineQuotCompleteness.timelineQuot_not_valid_of_neg_consistent phi h_cons
    ...
  exact h_not_valid h_valid_TQ
```

This is the intended proof structure. The sorry in `timelineQuot_not_valid_of_neg_consistent`
is the ONE gap. The dovetailed construction provides `has_future/has_past` but those
themselves have a gap in `DovetailedCoverage.lean`.

---

## Critical Analysis: What Does the Sorry Actually Need?

The sorry in `timelineQuot_not_valid_of_neg_consistent` needs to show:
```
∃ F M Omega τ h_sc h_mem t, ¬truth_at M Omega τ t φ
```
where D = TimelineQuot M₀ h_M₀_mcs.

Breaking this into components, we need:
1. **F** (TaskFrame over TimelineQuot): `timelineQuotParametricTaskFrame` is **sorry-free**
2. **M** (TaskModel): `ParametricCanonicalTaskModel TimelineQuot` is **sorry-free**
3. **Omega** (shift-closed set of histories): `ShiftClosedSeparatedOmega` is **sorry-free**
4. **tau** (WorldHistory): `separatedHistory` is **sorry-free**
5. **h_sc** (Omega is shift-closed): `shiftClosedSeparatedOmega_is_shift_closed` is **sorry-free**
6. **h_mem** (tau in Omega): `separatedHistory_in_shiftClosed` is **sorry-free**
7. **t** (evaluation time): `rootTime` is **sorry-free**
8. **¬truth_at**: requires truth lemma ← **THIS IS THE GAP**

For step 8, we need: `phi.neg in root_mcs` AND the truth lemma to say `truth_at ... phi.neg`.

Since phi.neg in root_mcs = mcs(rootTime) (by `timelineQuotMCS_root_time_eq`), the
forward direction of the truth lemma gives `truth_at ... phi.neg` at rootTime.

**The forward truth lemma** for singleton Omega `{separatedHistory}`:
- atom: direct from valuation definition (sorry-free)
- bot: trivial (sorry-free)
- imp: by IH (sorry-free once IH holds)
- box: Box phi in mcs(t) -> phi in mcs(t) (by modal T-axiom) -> IH
- G (all_future): G phi in mcs(t) -> for s > t, phi in mcs(s) -> IH for phi at s
- H (all_past): symmetric

ALL of these cases require only the **forward** FMCS coherence (forward_G/backward_H)
which IS proven sorry-free for timelineQuotFMCS! The temporal F/P witnesses are only
needed for the **backward** direction of G/H (temporal_backward_G/H).

**CRITICAL FINDING**: For the purpose of showing `¬truth_at ... phi` (not `truth_at ... phi.neg`
or equivalently `truth_at ... phi` fails), we need:

The completeness proof via contradiction is:
1. Assume phi valid over TimelineQuot
2. So truth_at M {tau} tau rootTime phi
3. But phi.neg in mcs(rootTime) by construction
4. By BACKWARD truth lemma: phi in mcs(rootTime) implies phi is true (forward)
5. phi.neg in mcs(rootTime) contradicts phi in mcs(rootTime) (MCS consistency)

Actually step 2-3-4-5 can be simplified: we need to show phi is NOT true at rootTime.

The forward truth lemma gives: `phi.neg in mcs(t)` implies `truth_at ... phi.neg`.
Since phi.neg = neg phi = phi.imp bot, `truth_at ... (phi.imp bot)` means `truth_at ... phi -> False`.
So from `truth_at ... phi` (step 1-2) and the forward truth lemma for phi.neg, we get `False`.

This requires the FORWARD truth lemma for phi.neg, which is:
- For atoms: direct
- For bot: trivial
- For imp: forward only needs IH
- For box: Box phi -> phi (modal T) + IH (forward only)
- For G: G phi in mcs -> forward_G + IH (forward only for G)
- For H: H phi in mcs -> backward_H + IH (forward only for H)

**These all work without F/P witnesses** (F/P are only in the backward direction of G/H)!

---

## Confidence Level and Recommendation

### Confidence Level: HIGH

**The forward-only truth lemma approach (Approach C variant) is viable** because:

1. All components for the forward direction are sorry-free:
   - `timelineQuotFMCS` with `forward_G` and `backward_H`
   - `timelineQuotMCS_root_time_eq` (root time has the right MCS)
   - Modal T-axiom handles box case
   - `SeparatedHistory`, `ShiftClosedSeparatedOmega` (singleton Omega)

2. The completeness proof only needs the FORWARD direction of the truth lemma for phi.neg

3. This completely avoids the modal_backward, temporal_coherent (F/P), and dovetailing issues

### Recommended Implementation Strategy

**Option 1 (RECOMMENDED)**: Implement a specialized forward truth lemma for the countermodel:

```lean
theorem timelineQuot_truth_lemma_forward
    (root_mcs : Set Formula) (h_mcs : SetMaximalConsistent root_mcs)
    (phi : Formula) (t : TimelineQuot root_mcs h_mcs) :
    phi ∈ timelineQuotMCS root_mcs h_mcs t →
    truth_at (ParametricCanonicalTaskModel (TimelineQuot root_mcs h_mcs))
      (ShiftClosedSeparatedOmega root_mcs h_mcs)
      (separatedHistory root_mcs h_mcs)
      t phi
```

This has a clean inductive proof using only `timelineQuotFMCS` forward_G/backward_H
and the modal T-axiom.

Then fill the sorry:
```lean
theorem timelineQuot_not_valid_of_neg_consistent (φ ...) :
  ¬@valid_over D ... φ := by
  intro M₀ h_M₀_mcs D ...
  -- Need to exhibit a countermodel
  let F := timelineQuotParametricTaskFrame ...
  let M := ParametricCanonicalTaskModel ...
  let Omega := ShiftClosedSeparatedOmega ...
  let tau := separatedHistory ...
  use F, M, Omega, tau, shiftClosedSeparatedOmega_is_shift_closed, ...
  -- Show phi.neg is true at rootTime
  apply timelineQuot_truth_lemma_forward
  rw [timelineQuotMCS_root_time_eq]
  exact (lindenbaumMCS_extends ... phi.neg ...)
```

**Option 2 (FALLBACK)**: Pursue dovetailing completion per the density argument in 17_blocker-resolution.md

The density argument is mathematically sound (as confirmed by report 17) but requires:
- `encoding_unbounded` lemma
- `density_iterate_in_mcs` lemma
- `witness_at_large_step` lemma
- Connecting these to `dovetailedTimeline_has_future`

This is ~4-6 hours of additional work but the math is validated.

---

## Connection to Other Open Tasks

| Task | Relevance |
|------|-----------|
| Task 982 | Originally the wiring task; DovetailedCoverage.lean has partial work |
| Task 987 | AlgebraicBaseCompleteness uses construct_bfmcs_from_mcs (sorry-backed) |
| Task 988 | Dense algebraic completeness (likely waiting on 981 resolution) |
| Task 990 | D-parametric design - confirms parametric approach is the right architecture |

The recommended forward-only truth lemma (Option 1 above) is **independent of Tasks 982, 987,
988, 990**. It requires only existing sorry-free infrastructure.

---

## Summary of Findings

The blocking sorry in `timelineQuot_not_valid_of_neg_consistent` requires showing that
`phi.neg` is true at `rootTime` in the separated model. This needs only the **forward
direction** of the truth lemma for `phi.neg`. The forward direction works by induction:

- **atom/bot/imp**: Straightforward (no F/P witnesses needed)
- **box**: Handled by modal T-axiom (Box phi -> phi, which is in the proof system)
- **G/H**: Handled by `forward_G`/`backward_H` of `timelineQuotFMCS` (sorry-free)

The forward-only truth lemma avoids:
- modal_backward (BFMCS requirement)
- temporal F/P witnesses (only needed for backward G/H)
- dovetailing construction (only needed for F/P coherence)

This is the cleanest path to completing the dense completeness theorem. Estimated effort
is 4-6 hours for implementation, primarily in formalizing the forward truth lemma induction.

---

## References

- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/StagedConstruction/TimelineQuotCompleteness.lean` - The sorry (line 127)
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/StagedConstruction/TimelineQuotCanonical.lean` - Sorry-free FMCS and TaskFrame
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Algebraic/SeparatedHistory.lean` - Sorry-free WorldHistory
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Algebraic/ParametricTruthLemma.lean` - Full truth lemma (requires BFMCS)
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Algebraic/DenseInstantiation.lean` - D=Rat instantiation
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Algebraic/AlgebraicBaseCompleteness.lean` - Base completeness pattern
- `/home/benjamin/Projects/ProofChecker/specs/982_wire_dense_completeness_domain_connection/reports/17_blocker-resolution.md` - Dovetailing density argument
- `/home/benjamin/Projects/ProofChecker/specs/981_remove_axiom_technical_debt_from_task_979/reports/research-011.md` - Prior assessment post-task 991
