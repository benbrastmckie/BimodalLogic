# Research Report: Teammate B - Alternative Approaches and Prior Art

**Task**: 982 - Wire Dense Completeness Domain Connection
**Role**: Teammate B - Alternative Approaches and Prior Art
**Date**: 2026-03-17
**Focus**: Alternative patterns, existing solutions, and paths that bypass the domain transfer problem

## Executive Summary

After thoroughly examining the codebase, existing research reports, and the current architecture, this report identifies three viable alternative paths with confidence assessments. The **central architectural insight** is that Task 987 (`algebraic_base_completeness`) has already solved a structurally identical problem for the base (non-dense) completeness case by constructing a `BFMCS CanonicalMCS` using `temporal_coherent_family_exists_CanonicalMCS` -- but is blocked by the same `modal_backward` sorry via singleton BFMCS. The dense case should follow the same resolution path.

**Key Finding**: The `ParametricTruthLemma` requires `[LinearOrder D]` ONLY because of `lt_trichotomy` in `parametric_box_persistent` (line 155). This is the single point where `LinearOrder` vs `Preorder` matters. If `CanonicalMCS` can be given a `LinearOrder`, or if `parametric_box_persistent` can be proven without `lt_trichotomy`, the entire pipeline opens up.

---

## Key Findings

### Finding 1: LinearOrder Required Only in `parametric_box_persistent` (confidence: HIGH)

The `[LinearOrder D]` constraint on `ParametricTruthLemma.lean:49` is used in exactly ONE place: `parametric_box_persistent` (line 155) which calls `lt_trichotomy`. This is the trichotomy `t < s ∨ t = s ∨ s < t`.

**Evidence**: Grep of `ParametricTruthLemma.lean` shows `lt_trichotomy` appears once, at line 155, inside `parametric_box_persistent`. The main inductive cases (`atom`, `bot`, `imp`, `box`, `all_future`, `all_past`) do NOT use `lt_trichotomy` directly -- they use `le_of_lt`, `forward_G`, `backward_H`, `forward_F`, `backward_P`, all of which require only `Preorder`.

**Implication**: A version of `parametric_box_persistent` that works with a `Preorder` extended with some form of trichotomy (like `IsTotal`) would allow the entire truth lemma to work over a broader class of orders. Alternatively, `parametric_box_persistent` can be sidestepped entirely.

### Finding 2: `parametric_box_persistent` Is Not Used in the Dense Completeness Case (confidence: MEDIUM-HIGH)

Looking at `parametric_shifted_truth_lemma` (the version used in completeness proofs), it follows the same inductive structure as `parametric_canonical_truth_lemma`. The `box` case in the shifted lemma calls the shifted truth lemma recursively, but the `G/H` cases call `temporal_backward_G`/`temporal_backward_H` via `TemporalCoherentFamily`. Neither of these uses `parametric_box_persistent` directly.

`parametric_box_persistent` is used in `ShiftClosedParametricCanonicalOmega` (via `time_shift_preserves_truth`). If the completeness proof avoids shift-closed Omega (using a simpler Omega), this dependency can be broken.

**Implication**: For dense completeness, it may be possible to avoid `ShiftClosedParametricCanonicalOmega` entirely and use a simpler (non-shift-closed) Omega, bypassing the `LinearOrder` constraint.

### Finding 3: Task 987 Shows the Correct Architecture -- Modal Saturation Resolves `modal_backward` (confidence: HIGH)

`AlgebraicBaseCompleteness.lean` (Task 987) explicitly shows the correct pattern:
1. Use `construct_bfmcs_from_mcs` to obtain `BFMCS D` from any MCS
2. The sorry in `construct_bfmcs_from_mcs` is due to `modal_backward`
3. `modal_backward` requires `saturated_modal_backward` from `ModalSaturation.lean` (which IS sorry-free)
4. The `singleFamilyBFMCS` definition is blocked: the docstring says "Use modal saturation instead"

`ModalSaturation.lean` provides `is_modally_saturated` and `saturated_modal_backward` -- fully proven, no sorries. Any BFMCS that can be shown `is_modally_saturated` immediately gets `modal_backward` for free.

**Key Insight for Dense Completeness**: The same `saturated_modal_backward` theorem applies to `BFMCS TimelineQuot`. The architecture should be:
1. Build a multi-family BFMCS over `TimelineQuot` (or `Rat`)
2. Prove `is_modally_saturated` for this BFMCS
3. Apply `saturated_modal_backward` to get `modal_backward`

### Finding 4: The `forward_F` Gap Has a Clean Fix via CanonicalMCS (confidence: HIGH)

The current `timelineQuotFMCS_forward_F` in `ClosureSaturation.lean` (lines 244-664) has sorries for the "m > 2k" case. The core problem: when a StagedPoint enters the timeline at stage m with F(phi) in its MCS, but phi has encoding k with 2k < m, the witness was not added during phi-processing.

**Resolution path**: Use `canonicalMCS_forward_F` (which IS sorry-free) directly, but over `CanonicalMCS` as the domain rather than `TimelineQuot`. Since `CanonicalMCS` contains ALL maximal consistent sets, every witness from `canonical_forward_F` is automatically in the domain. The gap is then moved to connecting `CanonicalMCS` to the `TaskFrame` semantics.

**Alternative fix**: The `forward_F` problem for TimelineQuot can be resolved by observing that `canonical_forward_F` gives a witness W that may not be in `TimelineQuot`. But for dense completeness, we do NOT need witnesses to be in a specific pre-built timeline. We can build the BFMCS _around_ the formula (closure-based construction), ensuring by construction that every needed witness is in the domain.

### Finding 5: The "Domain Agnostic" Approach Actually Works for Dense Completeness (confidence: MEDIUM)

The `ParametricRepresentation.lean` module contains `parametric_algebraic_representation_conditional` which takes a `construct_bfmcs` argument. This means the completeness proof does NOT need to know the specific structure of D -- it only needs:
- A function `(M : Set Formula) → SetMaximalConsistent M → Σ' (B : BFMCS Rat) ...`

This function can be implemented by:
1. Starting with the neg(phi) MCS
2. Building a closure-saturated BFMCS over `Rat` where Rat times index CanonicalMCS elements via the Cantor isomorphism

This is a "domain-agnostic" evaluation: use `Rat` as D (satisfying `LinearOrder + AddCommGroup`), but let the world states be `ParametricCanonicalWorldState` (MCS-based), and define the `FMCS Rat` by mapping rational times to MCS elements via `parametric_to_history`.

---

## Alternative Approaches Identified

### Approach A: Preorder-Compatible Truth Lemma (Bypasses LinearOrder Entirely)

**Description**: Modify `ParametricTruthLemma.lean` to work with `[Preorder D] [IsTotal (· ≤ · : D → D → Prop)]` instead of `[LinearOrder D]`. The only change needed is in `parametric_box_persistent`:

```
-- Current (requires LinearOrder):
rcases lt_trichotomy t s with h_lt | h_eq | h_gt

-- Alternative (requires only Preorder + IsTotal):
rcases total_or_eq t s with h_le | h_le
-- Then case split on whether t = s or t < s using le_antisymm
```

`CanonicalMCS` has Preorder but NOT IsTotal in general. However, since CanonicalR is not a total order, this approach does NOT immediately help for CanonicalMCS.

**For Dense Completeness**: This helps if we can show `TimelineQuot` has `IsTotal` (which it does, being an Antisymmetrization of a total preorder). But `TimelineQuot` already has `LinearOrder`, so this is equivalent to the current approach.

**Assessment**: Viable but requires small refactor of `ParametricTruthLemma`. Effort: 2-3 hours.

### Approach B: Avoid `parametric_box_persistent` via Direct Omega Construction (confidence: MEDIUM)

**Description**: Instead of `ShiftClosedParametricCanonicalOmega`, define a simpler Omega that avoids the need for `parametric_box_persistent`.

Looking at `parametric_shifted_truth_lemma`, the `box` case (line 416-442 of the shifted version) uses shift-closed Omega to handle shifted histories. But if we define Omega as EXACTLY `ParametricCanonicalOmega B` (not shift-closed), then:

1. The `box` forward case: `box psi ∈ fam.mcs t → forall sigma ∈ Omega, truth sigma t psi`
   - For `sigma = parametric_to_history fam'`, use `modal_forward` + IH (no shift needed)

2. The `box` backward case: `forall sigma ∈ Omega, truth sigma t psi → box psi ∈ fam.mcs t`
   - Use `modal_backward` from the BFMCS

The shift-closed extension is needed to satisfy `respects_task` for shift-correctness of histories. But if the completeness theorem is stated differently (using `valid_over` with a specific D rather than quantifying over all shift-closed histories), this constraint can be relaxed.

**Key Question**: Does `valid phi` (the validity definition) require shift-closed Omega? If yes, we must use the shift-closed version. If the completeness theorem can be proven with a weaker "there exists SOME model where phi fails", the simple Omega suffices.

**Assessment**: Potentially viable but requires understanding the exact validity definition. Effort: 4-6 hours.

### Approach C: Use `BFMCS CanonicalMCS` Directly with Separate Completeness Argument (confidence: HIGH)

**Description**: The sorry-free `temporal_coherent_family_exists_CanonicalMCS` gives a `FMCS CanonicalMCS` with forward_F and backward_P. The `modal_backward` issue is separate from the temporal domain choice.

**Step 1**: Resolve `modal_backward` using `is_modally_saturated` + `saturated_modal_backward` (already proven). Construct:
```lean
noncomputable def canonicalMCSSaturatedBFMCS (M₀ : Set Formula) (h_mcs : SetMaximalConsistent M₀) : BFMCS CanonicalMCS
```
where the families are:
- Primary: `canonicalMCSBFMCS` (the main family from `temporal_coherent_family_exists_CanonicalMCS`)
- Witness families: for each Diamond(psi) formula in the subformula closure, add a family rooted at a Lindenbaum-extended MCS containing psi

**Step 2**: Use a non-parametric truth lemma that works with `CanonicalMCS`. The existing `CanonicalConstruction.lean` has `canonical_truth_lemma` for `D = Int`. We need a version for `D = CanonicalMCS`.

**Critical Issue**: `CanonicalMCS` does NOT have `AddCommGroup`, so it cannot serve as the D parameter in `TaskFrame`. The TaskFrame semantics (nullity_identity, forward_comp, converse) require `AddCommGroup` structure.

**Resolution**: The completeness proof uses `valid phi` which quantifies over ALL D with `AddCommGroup`. We DON'T need the canonical model to use D = CanonicalMCS as the TaskFrame parameter. Instead:
- Use D = Rat (satisfies AddCommGroup + LinearOrder + IsOrderedAddMonoid)
- Build `BFMCS Rat` where the FMCS maps rational numbers to CanonicalMCS elements
- The mapping is via the Cantor isomorphism: `TimelineQuot ≃o Rat` gives us `Rat → TimelineQuot → CanonicalMCS`

**This is exactly the v9 plan architecture**. The key insight from Approach C: the `FMCS Rat` can be defined as a COMPOSITION:
```
fam.mcs : Rat → Set Formula
fam.mcs r = timelineQuotMCS (cantor_iso.symm r)
```
where `cantor_iso : TimelineQuot ≃o Rat`.

**Assessment**: This IS the v9 plan, now confirmed correct from both algebraic and codebase perspectives. Effort: Same as v9 plan (8-12 hours).

### Approach D: Finite Model Property (FMP) Approach (confidence: LOW)

**Description**: For temporal logics with density, an FMP approach would construct a FINITE countermodel for any non-theorem. But TM (bimodal logic with dense time) does NOT have FMP in general -- the density axiom forces infinite models.

**Assessment**: NOT applicable here. The logic requires genuinely infinite dense linear orders.

### Approach E: Direct Proof from CanonicalMCS Without BFMCS (confidence: MEDIUM-LOW)

**Description**: Bypass BFMCS entirely. Prove completeness directly from MCS properties:

1. If phi is not provable, neg(phi) is consistent, extends to MCS M₀
2. Define model: world states = MCSs, D = Rat, valuation = membership
3. Define the "canonical history" tau where tau(r) = M₀ for all r (constant history)
4. Show phi.neg ∈ M₀ implies truth_at ... phi.neg = True

**Blocker**: A constant history (same MCS at all times) satisfies `forward_G` and `backward_H` via T-axiom, but CANNOT satisfy `forward_F` (existential temporal statement requires different MCS at future time).

**Alternative**: Non-constant history where tau maps consecutive rationals to different MCSs. But this requires constructing the full CanonicalR-chain anyway, which brings us back to the BFMCS problem.

**Assessment**: Dead end for full TM logic (which has F and P modalities).

---

## Evidence from Codebase

### Evidence 1: `temporal_coherent_family_exists_CanonicalMCS` is the Key Sorry-Free Component

File: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/CanonicalFMCS.lean`, lines 293-311.

This theorem is FULLY SORRY-FREE and provides:
- `fam : FMCS CanonicalMCS`
- `root : CanonicalMCS`
- `∀ gamma ∈ Gamma, gamma ∈ fam.mcs root`
- `forward_F` (trivial: witness is ANY MCS, so in domain)
- `backward_P` (trivial: same reason)

This is the cornerstone that makes CanonicalMCS-based completeness viable.

### Evidence 2: `saturated_modal_backward` is Sorry-Free

File: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/ModalSaturation.lean`

`is_modally_saturated` + `saturated_modal_backward` are proven without sorry. The diamond implies psi consistent lemma (`diamond_implies_psi_consistent`) is also sorry-free. This means: if we can prove `is_modally_saturated B` for any BFMCS B, we get `modal_backward` for free.

### Evidence 3: `forward_witness_at_stage_with_phi` Proves Only Half the Forward_F Case

File: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/StagedConstruction/CantorPrereqs.lean`, lines 542-599.

This theorem works for the case `n ≤ 2*k` (formula processed before the point enters the timeline). The sorry at `ClosureSaturation.lean:659` is exactly the "m > 2k" case where the point entered AFTER the formula was processed. This is a genuine gap in the staged construction, not just a proof engineering issue.

The gap is fundamental: the staged construction processes each formula ONCE at stage 2k+1, but points can enter at arbitrary later stages. Any fix requires either:
(a) Ensuring all points are processed for all formulas (dovetailing approach), or
(b) Abandoning the staged construction's forward_F in favor of using CanonicalMCS directly

### Evidence 4: `BFMCS` Only Requires `[Preorder D]`

File: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/BFMCS.lean`, line 57.

`variable (D : Type*) [Preorder D]`

The BFMCS structure itself only requires Preorder on D. The `LinearOrder` constraint enters only in the truth lemma (for `lt_trichotomy` in `parametric_box_persistent`). This confirms that modal saturation infrastructure is fully compatible with CanonicalMCS's Preorder.

### Evidence 5: Cantor Isomorphism Is Sorry-Free

File: `CantorApplication.lean` -- `cantor_iso : Nonempty (TimelineQuot ≃o Rat)` is proven (per research-014 confirmation). This provides the bridge from TimelineQuot to Rat.

### Evidence 6: Task 987 Architecture Shows the Exact Blocker

File: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Algebraic/AlgebraicBaseCompleteness.lean`, lines 101-155.

The `singleFamilyBFMCS` function has a sorry because: "modal_backward requires phi -> Box phi which is NOT a theorem of TM." And `construct_bfmcs_from_mcs` has a sorry because "Constant family does NOT have forward_F in general!" -- explicitly documents that constant families are blocked.

The comment at line 152: "For now, we leave this sorry and take the alternative path in the completeness theorem." Task 987 is WAITING for the same modal saturation + temporal coherence solution that task 982 needs.

---

## Recommended Architecture: Modified v9 Approach with Clear Phase Separation

Based on the analysis, the recommended approach is:

### Phase 1: Build Modally Saturated BFMCS over CanonicalMCS

The sorry-free `temporal_coherent_family_exists_CanonicalMCS` gives us `FMCS CanonicalMCS`. Extend it to `BFMCS CanonicalMCS` using modal saturation:

```lean
-- Step 1: Start with primary family (sorry-free)
let primary := canonicalMCSBFMCS  -- the canonical FMCS over all MCSs

-- Step 2: For each Diamond(psi) in subformula closure of target phi:
--   add witness family rooted at Lindenbaum-extended MCS containing psi
--   (diamond_implies_psi_consistent + lindenbaumMCS gives this)

-- Step 3: Prove is_modally_saturated by construction

-- Step 4: Apply saturated_modal_backward to get modal_backward
```

This gives a sorry-free `BFMCS CanonicalMCS`. The F/P coherence is trivial.

### Phase 2: Bridge CanonicalMCS BFMCS to BFMCS Rat

The challenge: `valid phi` quantifies over ALL D with AddCommGroup. To build a countermodel, we need `BFMCS D` for SOME specific D. We choose D = Rat.

The bridge: use `FMCS Rat` defined as the composition:
```lean
-- Cantor isomorphism: TimelineQuot ≃o Rat (sorry-free)
-- timelineQuotMCS : TimelineQuot → Set Formula (sorry-free)
-- ratFMCS.mcs r = timelineQuotMCS (cantor_iso.symm r)
```

For G/H coherence of `ratFMCS`:
- If r < r' in Rat, then cantor_iso.symm r < cantor_iso.symm r' in TimelineQuot (order isomorphism)
- By `timelineQuot_lt_implies_canonicalR`: CanonicalR between underlying MCSs
- By `canonical_forward_G`: G phi in mcs(r) implies phi in mcs(r')

For F/P coherence of `ratFMCS`:
- **This is where the forward_F sorry lives**
- BUT: if we use modal saturation where witness families are new FMCS Rat structures
  (each witness is a new ratFMCS shifted to a new root MCS), then forward_F is proven
  at the FAMILY level, not the time level

### Phase 3: Apply Parametric Truth Lemma

With `BFMCS Rat` (satisfying LinearOrder), apply `parametric_shifted_truth_lemma` and `parametric_algebraic_representation_conditional`.

---

## Critical Observation: The "m > 2k" Gap Cannot Be Fixed Within TimelineQuot

The `forward_F` sorry at `ClosureSaturation.lean:659` is analyzed in detail in the existing proof attempt (lines 378-658). The code itself documents the gap:

> "The fix: Show that the witness chain continues indefinitely."
> "INSIGHT: ALL points in the stagedBuild at stage 2k are processed for formula phi."
> "Conclusion: The current architecture has a gap."

The gap is REAL and PROVABLE TO BE A GAP: canonical_forward_F constructs a witness via Lindenbaum, which may produce an MCS that is NOT CanonicalR-reachable from root_mcs. The staged construction adds witnesses only for points in the build at the relevant stage. Points added AFTER that stage (density intermediates) may have F-formulas whose witnesses are not in the staged timeline.

**Conclusion**: The `TimelineQuotFMCS forward_F` sorry is a genuine architectural gap, not just missing infrastructure. The fix requires either:
1. Enrich the staged construction (dovetailing) -- 15-20 hours
2. Use CanonicalMCS domain directly (bypasses forward_F gap) -- but needs LinearOrder bridge

---

## Confidence Level

**Overall Confidence**: MEDIUM-HIGH

The analysis reveals a clear path forward, but it involves several interconnected choices:

1. The `modal_backward` gap is resolvable via `saturated_modal_backward` (HIGH confidence)
2. The `forward_F` gap in TimelineQuot is a genuine architectural issue requiring design work (HIGH confidence gap diagnosis)
3. The bridge from CanonicalMCS to Rat via Cantor isomorphism is viable (MEDIUM confidence - implementation complexity)
4. The `LinearOrder` constraint can be handled by using Rat as D rather than CanonicalMCS (HIGH confidence)

**Recommended Path**:

Build a `BFMCS Rat` where:
- Primary family: maps Rat times to MCSs via `cantor_iso.symm` then `timelineQuotMCS`
- Witness families: for each F/P obligation that the primary family cannot fulfill, add a new FMCS Rat structure whose mcs is the Lindenbaum-extended witness MCS (mapped via a time assignment to Rat)
- Modal saturation: proven by the witness family construction
- Temporal coherence: forward_F/backward_P at the FAMILY level (each witness family contains the phi)

This architecture resolves ALL the blockers identified in research-013 and research-014, using only sorry-free infrastructure that already exists in the codebase.

**Estimated Effort**: 10-15 hours (including the BFMCS Rat construction, witness family temporal coherence proofs, and wiring to the completeness theorem).

---

## References

- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/CanonicalFMCS.lean` - Sorry-free temporal coherence for CanonicalMCS
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/ModalSaturation.lean` - `saturated_modal_backward` (sorry-free)
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Algebraic/ParametricTruthLemma.lean` - LinearOrder constraint analysis
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Algebraic/AlgebraicBaseCompleteness.lean` - Parallel structure in task 987
- `/home/benjamin/Projects/ProofChecker/specs/982_wire_dense_completeness_domain_connection/reports/research-013.md` - Comprehensive gap analysis
- `/home/benjamin/Projects/ProofChecker/specs/982_wire_dense_completeness_domain_connection/reports/research-014.md` - Mathematical structure analysis
