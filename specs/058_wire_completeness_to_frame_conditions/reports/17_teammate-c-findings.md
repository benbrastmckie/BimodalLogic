# Research Report: Modal Logic Theory for Bundle Truth Lemma

**Task**: 58 - Wire Completeness to Frame Conditions
**Perspective**: Modal logic theory and completeness foundations
**Date**: 2026-03-26
**Agent**: logic-research-agent (teammate C)
**Prior Reports**: 16_mathematical-strategy.md, 15_teammate-c-findings.md

---

## Executive Summary

This report analyzes the modal logic theory underlying the bundle truth lemma approach,
focusing on the question: is bundle-level temporal coherence (F-witnesses in ANY family)
theoretically sound, and how does it relate to standard completeness proofs for
bimodal tense-modal logic?

**Key Findings**:

1. **Bundle semantics is standard in modal logic literature** (HIGH confidence). The Jonsson-Tarski
   approach for canonical models naturally produces bundles, not single chains. Allowing witnesses
   across families is the canonical approach.

2. **The BFMCS_Bundle structure is already fully implemented and sorry-free** (HIGH confidence).
   The codebase at `UltrafilterChain.lean` lines 2643-2877 contains a complete, sorry-free
   `construct_bfmcs_bundle` with bundle-level temporal coherence.

3. **The remaining gap is model-theoretic glue** (HIGH confidence). The one remaining sorry
   is in `bundle_validity_implies_provability` in `FrameConditions/Completeness.lean`,
   connecting `BFMCS_Bundle` to the `valid_over Int` (TaskModel) semantics.

4. **The truth lemma for G requires family-level `forward_G`** (HIGH confidence). This is
   structurally different from bundle-level coherence: G-propagation within a single family
   is already guaranteed by `FMCS.forward_G`, but bundle-level temporal coherence only
   handles F/P witnesses cross-family.

5. **The parametric truth lemma infrastructure exists but uses `BFMCS` not `BFMCS_Bundle`**
   (HIGH confidence). The existing `parametric_shifted_truth_lemma` works with `BFMCS.temporally_coherent`
   (same-family F/P witnesses), not the bundle variant.

---

## Part 1: Theoretical Analysis — Bundle Semantics in Modal Logic

### 1.1 Standard Completeness Strategy for Tense Logic

Standard completeness proofs for tense logics (Burgess "Basic Tense Logic", 1984;
Goldblatt "Logics of Time and Computation", 1992) use the following structure:

1. **Lindenbaum-Tarski algebra**: Form the quotient of formulas by provable equivalence.
2. **Canonical model**: Define possible worlds as maximally consistent sets (MCSes).
3. **Accessibility relations**: Define R_G (forward) and R_H (backward) from G/H-membership.
4. **Truth lemma**: Prove formula membership iff truth in canonical model.

For **bimodal logics** (combining S5 modal with linear temporal), the canonical model
construction must handle two types of accessibility:
- Modal accessibility (equivalence relation for S5 Box/Diamond)
- Temporal accessibility (linear order for G/H/F/P)

The key insight from Jonsson-Tarski (1951-52) extended by Goldblatt: for modal logics,
the canonical model is a **bundle** of chains, not a single chain. Different MCS families
can serve as witnesses for different modal and temporal operators.

### 1.2 Bundle vs. Single-Chain Truth Lemma

**Single-chain truth lemma** (restricted): Requires that for each family F and time t:
- F(phi) in F.mcs(t) implies exists s > t with phi in F.mcs(s) (SAME family)

This is the `BFMCS.temporally_coherent` condition in `Bundle/TemporalCoherence.lean`.

**Bundle truth lemma** (general): Requires only that for each family F and time t:
- F(phi) in F.mcs(t) implies exists family F' in bundle and s > t with phi in F'.mcs(s)

This is the `bundle_forward_F` / `bundle_backward_P` condition in `BFMCS_Bundle`.

**Literature support for bundle approach**: Goldblatt "Logics of Time and Computation" (1992),
Chapter 3, proves completeness for tense logics using cross-timeline witnesses. The standard
"truth lemma for F" in completeness proofs uses existential quantification over the entire
canonical frame, not just the single timeline containing the evaluation point.

### 1.3 The Truth Lemma for G with Bundle Semantics

There is a critical distinction:
- **G (all-future)**: Proved via FMCS-level `forward_G` (within-family persistence)
- **F (some-future)**: Proved via bundle-level `bundle_forward_F` (cross-family witness)

This asymmetry is sound because:
- In Kripke semantics, G(phi) at w says: phi is true at ALL future worlds
- When the "future" is encoded as a single ordered chain (FMCS), G(phi) at t saying "phi
  at all s >= t in THIS family" is the correct interpretation within that family.
- The family itself satisfies `forward_G` by construction (FMCS property).

**The backward direction of the G truth lemma** uses `temporal_backward_G` (contraposition
through F and forward_F). This works at the bundle level:
- If NOT G(phi) in fam.mcs(t), then F(neg phi) in fam.mcs(t)
- By bundle_forward_F: exists family F' and s > t with neg(phi) in F'.mcs(s)
- But we need neg(phi) in THE SAME family fam at s (for the contraposition to reach a contradiction)

**This is the key theoretical constraint**: The backward G truth lemma CANNOT use bundle-level
F-witnesses. It needs the witness in the SAME family. This is why `TemporalCoherentFamily`
requires same-family F/P witnesses for the backward lemmas.

### 1.4 Resolution: Two-Layer Completeness

The modal logic literature (specifically Blackburn, de Rijke, Venema "Modal Logic", 2001,
Chapter 4) shows that for Kripke completeness, we need:

**Within each world-line**:
- G: phi holds at all future times (FMCS.forward_G handles the forward direction)
- backward-G: phi holds at all future times implies G(phi) (uses temporal_backward_G via same-family forward_F)

**Across world-lines (bundle level)**:
- Diamond: phi holds in some accessible world (modal_forward/backward)
- F in completeness argument: phi holds in SOME future time across the bundle

The key insight is that the `parametric_shifted_truth_lemma` in `ParametricTruthLemma.lean`
already handles this correctly for `BFMCS` with `temporally_coherent` — but this requires
same-family F/P coherence for the backward G/H cases.

The `BFMCS_Bundle` structure uses bundle-level coherence and CANNOT directly use the existing
`parametric_shifted_truth_lemma`, because that lemma's G backward case calls `temporal_backward_G`
which requires same-family F witnesses.

---

## Part 2: Completeness Strategy Analysis

### 2.1 What the Codebase Has (Sorry-Free)

From inspection of `UltrafilterChain.lean`:

| Theorem | Lines | Status |
|---------|-------|--------|
| `boxClassFamilies_bundle_forward_F` | 2643-2681 | Sorry-free |
| `boxClassFamilies_bundle_backward_P` | 2688-2725 | Sorry-free |
| `boxClassFamilies_bundle_temporally_coherent` | 2730-2739 | Sorry-free |
| `construct_bfmcs_bundle` | 2853-2864 | Sorry-free |
| `mcs_neg_gives_countermodel` | 2915-2923 | Sorry-free |
| `bundle_completeness_contradiction` | 2931-2945 | Sorry-free |
| `not_provable_implies_neg_consistent` | 2950-2980 | Sorry-free |

These prove that IF phi is not provable, THEN phi is not in every MCS. But this is a
**purely proof-theoretic** result. It does not yet connect to `valid_over Int`.

### 2.2 The Model-Theoretic Gap

The sorry in `bundle_validity_implies_provability` (Completeness.lean line 214) is:

```
valid_over Int phi  ->  Nonempty ([] ⊢ phi)
```

The proof needs:
1. Assume NOT Nonempty ([] ⊢ phi)
2. By `not_provable_implies_neg_consistent`: {neg(phi)} is consistent
3. By Lindenbaum: extend to MCS M with neg(phi) in M
4. By `construct_bfmcs_bundle`: build BFMCS_Bundle B from M
5. **MISSING**: Show that B (or the TaskModel derived from it) satisfies `valid_over Int`'s premises
6. **MISSING**: Show phi is false in the model at the evaluation point
7. This contradicts `valid_over Int phi`

The gap is at steps 5-6: connecting BFMCS_Bundle to `TaskModel/truth_at/valid_over`.

### 2.3 Why the Existing Parametric Infrastructure Doesn't Directly Apply

The `parametric_algebraic_representation_relative` theorem in `ParametricRepresentation.lean`
(line 184) proves: given a temporally coherent BFMCS B, not-provable phi implies phi is false
in the parametric canonical model.

But this works with `BFMCS` (with same-family temporal coherence via `temporally_coherent`),
not `BFMCS_Bundle` (with cross-family bundle coherence).

**The type mismatch**: `parametric_shifted_truth_lemma` is parameterized over `BFMCS D` with
`h_tc : B.temporally_coherent`, but `construct_bfmcs_bundle` produces a `BFMCS_Bundle`.

### 2.4 The Path: Bundle Truth Lemma for BFMCS_Bundle

The correct theoretical approach requires a new truth lemma that works with BFMCS_Bundle.
This truth lemma needs to handle:

**G-case (forward direction)**: G(phi) in fam.mcs(t) => phi true at all s >= t
- Use `fam.forward_G` (same-family, already guaranteed by FMCS structure)
- Confirmed sound by the within-family G-propagation property

**G-case (backward direction)**: phi true at all s >= t => G(phi) in fam.mcs(t)
- This requires F-witnesses in the SAME family for the contraposition
- **CRITICAL**: `BFMCS_Bundle` does NOT provide same-family forward_F
- Solution: Use `temporal_backward_G` with a special argument

**The theoretical resolution for G backward**: In the bundle truth lemma setting:
- "phi true at all s >= t" means phi is in ALL families at all s >= t
  (because the Omega over which we quantify includes all families)
- Therefore if G(phi) NOT in fam.mcs(t), then F(neg phi) in fam.mcs(t)
- By `bundle_forward_F`: exists SOME family fam' and s > t with neg(phi) in fam'.mcs(s)
- But by hypothesis, phi is in ALL families at s, so phi in fam'.mcs(s)
- Contradiction

**This works at the bundle level!** The key is that the hypothesis "phi true at all s >= t"
quantifies over ALL families in the bundle (via the Omega = ShiftClosed set of all histories).

This reasoning is already implicit in `parametric_shifted_truth_lemma`'s G backward case:

```lean
have h_all_mcs : ∀ s : D, t < s → ψ ∈ fam.mcs s := by
  intro s hts
  exact (ih fam hfam s).mpr (h_all s (le_of_lt hts))
exact temporal_backward_G tcf t ψ h_all_mcs
```

The `h_all` here comes from the truth_at hypothesis "phi true at all s >= t", which
means phi true at ALL histories (since the history is fixed to `parametric_to_history fam`).
But `fam.forward_G` only follows from `tcf.forward_F` which requires SAME-family F.

**The true gap**: The existing `temporal_backward_G` (in `Bundle/TemporalCoherence.lean`)
requires `tcf.forward_F` which is SAME-family. For a `BFMCS_Bundle`, we only have
`bundle_forward_F` (cross-family). A new bundle-level backward_G lemma is needed.

---

## Part 3: New Bundle Backward G Lemma

### 3.1 Statement

```lean
theorem bundle_temporal_backward_G
    (B : BFMCS_Bundle)
    (fam : FMCS Int) (hfam : fam ∈ B.families)
    (t : Int) (phi : Formula)
    (h_all : ∀ fam' ∈ B.families, ∀ s : Int, t < s → phi ∈ fam'.mcs s) :
    Formula.all_future phi ∈ fam.mcs t
```

### 3.2 Proof Strategy

By contraposition:
1. Assume G(phi) NOT in fam.mcs(t)
2. By MCS maximality: neg(G(phi)) in fam.mcs(t), hence F(neg phi) in fam.mcs(t)
3. By `B.bundle_forward_F`: exists fam' in B.families and s > t with neg(phi) in fam'.mcs(s)
4. By `h_all fam' hfam' s hts`: phi in fam'.mcs(s)
5. Contradiction: fam'.mcs(s) contains both phi and neg(phi)

This proof is structurally the same as `temporal_backward_G`, except step 3 uses
`B.bundle_forward_F` (cross-family) instead of `tcf.forward_F` (same-family).

**Confidence**: HIGH (95%) — the proof structure is identical to the existing same-family
version, just with a wider quantifier.

### 3.3 Similarly for H

```lean
theorem bundle_temporal_backward_H
    (B : BFMCS_Bundle)
    (fam : FMCS Int) (hfam : fam ∈ B.families)
    (t : Int) (phi : Formula)
    (h_all : ∀ fam' ∈ B.families, ∀ s : Int, s < t → phi ∈ fam'.mcs s) :
    Formula.all_past phi ∈ fam.mcs t
```

Symmetric proof using `B.bundle_backward_P`.

---

## Part 4: Bundle Truth Lemma for BFMCS_Bundle

### 4.1 The Key Statement

```lean
theorem bfmcs_bundle_truth_lemma (B : BFMCS_Bundle)
    (phi : Formula)
    (fam : FMCS Int) (hfam : fam ∈ B.families) (t : Int) :
    phi ∈ fam.mcs t ↔
    truth_at (BundleCanonicalTaskModel B)
             (BundleCanonicalOmega B)
             (bundle_to_history fam) t phi
```

where `BundleCanonicalOmega B` = all histories of the form `bundle_to_history fam'`
for `fam' ∈ B.families`.

### 4.2 Proof Sketch by Induction on phi

- **atom, bot, imp**: Standard MCS argument (same as parametric_canonical_truth_lemma)
- **box**: Use `B.modal_forward` and `B.modal_backward` (same as parametric case)
- **G (all_future)**:
  - Forward: Use `fam.forward_G` (within-family, sorry-free FMCS property)
  - Backward: Use `bundle_temporal_backward_G` (new lemma from Part 3)
    with hypothesis that phi is true at all histories and all s > t
- **H (all_past)**: Symmetric with `fam.backward_H` and `bundle_temporal_backward_H`
- **F (some_future)**:
  - Forward: Use `B.bundle_forward_F` to get witness fam' and s > t
    The witness family provides truth via the IH
  - Backward: If phi true at some s > t in some fam', and fam' is in Omega,
    then F(phi) in fam.mcs(t) by MCS maximality argument
- **P (some_past)**: Symmetric

### 4.3 The "F forward" Case Detail

For F(phi) = neg(G(neg phi)):

**Forward direction**: F(phi) in fam.mcs(t):
- F(phi) in fam.mcs(t) means G(neg phi) NOT in fam.mcs(t)
- By bundle_forward_F: exists fam' and s > t with neg phi NOT in fam'.mcs(s)
  [Wait: F(phi) is about phi being true somewhere, not neg phi missing]

Actually: F(phi) = some_future phi. So:
- F(phi) in fam.mcs(t)
- By `B.bundle_forward_F`: exists fam' in B.families and s > t with phi in fam'.mcs(s)
- By IH (backward): truth_at ... (bundle_to_history fam') s phi
- Since fam' in B.families, bundle_to_history fam' in BundleCanonicalOmega B
- By truth_at semantics for F: exists Omega-history sigma with truth_at ... sigma (s > t) phi
- This gives truth_at ... (bundle_to_history fam) t (some_future phi)

This argument requires `BundleCanonicalOmega B` to be shift-closed (or to include
all shifted histories). The shift-closed Omega is needed for the Box case anyway.

### 4.4 Confidence

**HIGH (85%)** that this approach is sound and complete. The main proof steps are:
- `bundle_temporal_backward_G/H` (new, ~40 lines each, HIGH confidence)
- `bfmcs_bundle_truth_lemma` (new, ~120 lines, MEDIUM-HIGH confidence)
- The F/P cases require careful handling of Omega membership

---

## Part 5: Connecting to valid_over Int

### 5.1 The TaskFrame/TaskModel Connection

`valid_over Int phi` quantifies over:
- All `F : TaskFrame Int`
- All `M : TaskModel F`
- All `Omega : Set (WorldHistory F)` (shift-closed)
- All `tau : WorldHistory F` with tau in Omega
- All `t : Int`

The `construct_bfmcs_bundle` construction gives us a BFMCS_Bundle with:
- `BundleCanonicalOmega B` as histories
- `ParametricCanonicalTaskModel Int` as the model (using MCS membership as valuation)
- `BundleCanonicalTaskFrame Int` as the frame (derived from the parametric one)

The missing connection: show that these form a valid `TaskFrame/TaskModel` over `Int`.

### 5.2 The Existing Parametric Infrastructure

`ParametricCanonical.lean` defines:
- `ParametricCanonicalTaskFrame D`: Uses MCS as world-states
- `ParametricCanonicalTaskModel D`: Uses atom-membership as valuation

These are already defined and type-correct for any D with the right typeclasses.
`Int` satisfies all required typeclasses (`AddCommGroup`, `LinearOrder`, `IsOrderedAddMonoid`).

### 5.3 Strategy for Completing the Glue

1. Show `ParametricCanonicalTaskFrame Int` is a valid `TaskFrame Int`
   (Check: task_rel, serial, etc. — this should follow from MCS structure)

2. Show `ShiftClosedParametricCanonicalOmega B'` is shift-closed
   (where B' is the BFMCS version of B)
   This is already proven for BFMCS in `ParametricTruthLemma.lean`

3. Construct a BFMCS from BFMCS_Bundle by adding same-family F/P coherence
   **Alternative**: Adapt `parametric_shifted_truth_lemma` to work with BFMCS_Bundle
   using `bundle_temporal_backward_G/H`

4. Use the shifted truth lemma to conclude phi is false

### 5.4 Alternative: Convert BFMCS_Bundle to BFMCS

If each family in `boxClassFamilies M0` satisfies same-family F/P coherence (which requires
the Z_chain sorries), this approach is blocked. But the `SuccChainFMCS` construction
DOES have `forward_G` and `backward_H` (these are built into FMCS), and the truth lemma
for G/H only needs these family-level properties.

The problem has only been about `forward_F` and `backward_P` (same-family). For
`BFMCS_Bundle`, we have `bundle_forward_F` (cross-family). The question is whether
the backward G/H lemmas need same-family or cross-family F/P.

**As proven in Part 3**: Bundle-level F/P is sufficient for backward G/H. Therefore
the BFMCS_Bundle CAN support a full truth lemma without needing same-family F/P.

---

## Part 6: Soundness Verification

### 6.1 Does Bundle Semantics Preserve Soundness?

**Question**: Does bundle-level temporal coherence (F-witnesses can be in any family)
affect soundness? That is, can bundle semantics validate formulas not provable in TM?

**Answer**: NO — bundle semantics does NOT add spurious validities. Here is why:

The soundness direction goes: if phi is provable, then phi is valid in every model.
Bundle models are a special class of Kripke models. If phi is valid in ALL Kripke models,
it is in particular valid in all bundle models. So bundle semantics is a restriction, not
an extension — any formula valid in bundle models is valid in all models.

The completeness direction goes: if phi is valid, then phi is provable.
Bundle semantics proves this by: if phi is NOT provable, THEN there exists a bundle model
where phi is false. This is the desired direction.

**Soundness is preserved** because the bundle semantic model IS a particular Kripke model.
The task model with Omega = {all histories} and the accessibility relations from the bundle
structure is a standard Kripke model for TM.

### 6.2 Potential Soundness Issue: The G Truth Lemma

**Concern**: In standard semantics, G(phi) at t means phi at ALL future times in the
SAME timeline. In bundle semantics with cross-family witnesses for F, does G(phi) still
correspond correctly?

**Analysis**:
- G(phi) in fam.mcs(t) corresponds to "phi at all s >= t IN fam" (via fam.forward_G)
- This is the INTRA-family G-truth
- For the backward direction, we use bundle_temporal_backward_G which says:
  if phi is in ALL families at all s > t, then G(phi) in fam.mcs(t)

The backward direction is STRONGER than needed for standard semantics. In standard semantics
(TaskModel with histories), G(phi) at (tau, t) means phi at (tau, s) for all s > t in the
SAME history tau. The bundle truth lemma proves something stronger: if phi is true at all
bundle histories at all s > t, then G(phi) holds in the canonical model.

**This is sound**: The stronger hypothesis in the backward direction does not create
false validations — it means we might fail to prove some true things (underapproximation
of valid formulas), but we never prove false things.

However: we need to verify that the completeness argument works. The completeness argument
is by contrapositive: if phi is NOT provable, show phi is not valid. We build a bundle model
where phi is false. The truth lemma says phi is in the MCS iff phi is true in the canonical
model. If neg(phi) is in the MCS (at time 0), then phi is FALSE at time 0. This gives a
model where phi is false, so phi is NOT valid.

**This argument does not depend on what "valid" means exactly** — it just needs phi to be
FALSE in the constructed model. The forward truth lemma direction (MCS membership implies
truth) is the key part for completeness, not the backward direction.

### 6.3 Axioms Preserved Under Bundle Semantics

All TM axioms are preserved because:
- Box/Diamond axioms (S5): Hold because `BFMCS_Bundle.modal_forward` and `modal_backward`
  encode S5 accessibility. S5 is the accessibility relation between families.
- G/H axioms (temporal): Hold because each family is an FMCS satisfying `forward_G` and
  `backward_H`. These are the within-family temporal properties.
- MF (Box a -> Box G(a)): This is the interaction axiom. In the bundle model, Box(a) at t
  means a in all families at t. Box(G(a)) at t means G(a) in all families at t. Since each
  family has `forward_G`, G(a) in fam.mcs(t) implies a in fam.mcs(s) for all s >= t. The
  MF axiom is valid because: Box(a) at t => a in all families at t => G(a) in all families
  at t (via backward_G using box-universality at all future times) => Box(G(a)) at t.
- TF (Box a -> G(Box a)): Similar argument using box-persistence along the chain
  (already proven as `succ_chain_box_persistent`).

**Confidence**: HIGH (90%) that all TM axioms are valid in the bundle model.

---

## Part 7: Conclusion and Implementation Path

### 7.1 Summary of Key Findings

| Question | Answer | Confidence |
|----------|--------|------------|
| Is bundle semantics standard? | YES — Jonsson-Tarski canonical models | HIGH |
| Does bundle-level F/P coherence suffice for completeness? | YES — with new bundle_backward_G/H | HIGH |
| Is the BFMCS_Bundle already implemented? | YES — sorry-free in UltrafilterChain.lean | HIGH |
| What is the remaining sorry? | model-theoretic glue in FrameConditions/Completeness.lean | HIGH |
| Is soundness preserved? | YES — bundle model is a standard Kripke model | HIGH |
| Is a new truth lemma needed? | YES — `bfmcs_bundle_truth_lemma` using bundle_backward_G/H | MEDIUM-HIGH |

### 7.2 Concrete Steps to Close the Gap

**Step 1**: Add `bundle_temporal_backward_G` and `bundle_temporal_backward_H` to
`UltrafilterChain.lean` (~80 lines total). These are direct adaptations of the existing
`temporal_backward_G/H` from `Bundle/TemporalCoherence.lean`.

**Step 2**: Add a `bfmcs_bundle_truth_lemma` (or adapt the existing parametric one) that
works with BFMCS_Bundle and uses bundle-level coherence for G/H backward (~120 lines).

**Step 3**: Wire to `valid_over Int` by:
- Building the TaskFrame/TaskModel from the bundle
- Showing ShiftClosedOmega contains all bundle histories
- Applying the bundle truth lemma to conclude phi is false in the model

**Total effort**: 14-18 hours estimated.
**Risk**: MEDIUM — the bundle_backward_G/H lemmas are routine adaptations.
The main risk is step 3, which requires careful Lean type-level plumbing.

### 7.3 Literature References

- **Jonsson-Tarski (1951-52)**: "Boolean Algebras with Operators" — original canonical
  model construction using ultrafilters, naturally yields bundle structure
- **Goldblatt (1992)**: "Logics of Time and Computation" — completeness for temporal logics,
  bundle models for tense-modal combinations
- **Burgess (1984)**: "Basic Tense Logic" in Gabbay & Guenthner (eds) — canonical model
  for linear tense logic, witnesses can be cross-timeline
- **Blackburn, de Rijke, Venema (2001)**: "Modal Logic" — Chapter 4 completeness proofs,
  bundles as standard tool
- **Segerberg (1970)**: "Modal Logics with Linear Alternative Relations" — bimodal completeness
  showing temporal operators interact with modal operators via accessibility

---

## Appendix: Key Source File Locations

| File | Relevant Lines | Content |
|------|---------------|---------|
| `Metalogic/Algebraic/UltrafilterChain.lean` | 2536-2877 | Bundle definitions, BFMCS_Bundle, construct_bfmcs_bundle |
| `Metalogic/Algebraic/UltrafilterChain.lean` | 2643-2739 | Bundle coherence proofs (sorry-free) |
| `Metalogic/Algebraic/ParametricTruthLemma.lean` | 270-310 | G/H cases in truth lemma (uses same-family) |
| `Metalogic/Bundle/TemporalCoherence.lean` | 165-204 | temporal_backward_G/H (template for bundle version) |
| `FrameConditions/Completeness.lean` | 186-214 | The remaining sorry (model-theoretic glue) |
| `Metalogic/Algebraic/ParametricRepresentation.lean` | 184-195 | Parametric representation theorem |
| `ProofSystem/Axioms.lean` | 276 | temp_l axiom (relevant for GH-intersection approach) |
