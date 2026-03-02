# Teammate C: Minimal Frame Definition for TruthLemma

## Task 951: Implement sorry-free completeness via CanonicalMCS domain

**Date**: 2026-03-01
**Focus**: Analyze what properties the TruthLemma ACTUALLY requires from the frame/domain

---

## Key Findings

1. **The TruthLemma itself is already sorry-free.** All six cases (atom, bot, imp, box, all_future, all_past) are proven in `TruthLemma.lean`. The sorries exist ONLY in the construction that provides the BFMCS (specifically `fully_saturated_bfmcs_exists_int` in `TemporalCoherentConstruction.lean`).

2. **The TruthLemma requires exactly `[Preorder D]` and `[Zero D]` from D.** The `[Zero D]` is only used in the corollaries (`bmcs_eval_truth`, `bmcs_eval_mcs`) to reference `mcs 0` as the evaluation point. The main `bmcs_truth_lemma` uses only `[Preorder D]` (via the `<=` in temporal operators).

3. **The TruthLemma requires exactly 4 properties from FMCS**: `mcs`, `is_mcs`, `forward_G`, `backward_H` -- and 2 additional properties from the temporal coherence condition: `forward_F` and `backward_P`. No other properties are needed.

4. **The `BidirectionalFragment` already satisfies ALL requirements sorry-free** via `fragmentFMCS`. The conversion to `FMCS Int` is the sole remaining obstacle.

5. **The `BidirectionalFragment` (or its quotient) could serve directly as the time domain D** if downstream infrastructure were generalized from `Int` to `[LinearOrder D]`.

---

## Properties Used by TruthLemma (with line references)

### From `BFMCS D` (BFMCS.lean)

| Property | Type | Used At | Purpose |
|----------|------|---------|---------|
| `families` | `Set (FMCS D)` | Lines 261, 336, 342 | Quantification domain for box case |
| `nonempty` | `families.Nonempty` | Not directly | Implicit in BFMCS structure |
| `modal_forward` | Box phi in fam -> phi in all fam' | Line 336 | Box forward direction |
| `modal_backward` | phi in all fam' -> Box phi in fam | Line 346 | Box backward direction |
| `eval_family` | `FMCS D` | Lines 411-421 (corollaries) | Evaluation point |
| `eval_family_mem` | `eval_family in families` | Lines 411-421 (corollaries) | Membership |

### From `FMCS D` (FMCSDef.lean)

| Property | Type | Used At | Purpose |
|----------|------|---------|---------|
| `mcs` | `D -> Set Formula` | Lines 263, 274, 289, etc. | MCS at each time |
| `is_mcs` | `forall t, SetMaximalConsistent (mcs t)` | Lines 274, 284, 290, 294 | MCS properties |
| `forward_G` | `t <= t' -> G phi in mcs t -> phi in mcs t'` | Lines 98-99 (helper), 353 | G forward case |
| `backward_H` | `t' <= t -> H phi in mcs t -> phi in mcs t'` | Lines 108-110 (helper), 380 | H forward case |

### From `TemporalCoherentFamily D` (TemporalCoherentConstruction.lean)

| Property | Type | Used At | Purpose |
|----------|------|---------|---------|
| `forward_F` | `F phi in mcs t -> exists s >= t, phi in mcs s` | Line 241, via temporal_backward_G | G backward (contraposition) |
| `backward_P` | `P phi in mcs t -> exists s <= t, phi in mcs s` | Line 278, via temporal_backward_H | H backward (contraposition) |

### From `D` (type class constraints)

| Constraint | Used At | Purpose |
|------------|---------|---------|
| `[Preorder D]` | Throughout | `<=` for temporal operators |
| `[Zero D]` | Corollaries only (lines 411-421) | Reference point `0` |

---

## Properties in Signature But UNUSED by TruthLemma

### FMCS fields NOT used:

There are no unused FMCS fields. The FMCS structure has exactly 4 fields (`mcs`, `is_mcs`, `forward_G`, `backward_H`) and ALL are used by TruthLemma (either directly or through helpers).

**Historical note**: The FMCS structure PREVIOUSLY had `forward_H` and `backward_G` fields (noted in FMCSDef.lean docstring, Task 843). These were removed because the TruthLemma does NOT use them. This cleanup was already done.

### Type class constraints NOT needed by main theorem:

- `[Zero D]`: Only used by corollaries `bmcs_eval_truth` and `bmcs_eval_mcs` (lines 410-421). The main `bmcs_truth_lemma` (line 260) does NOT require `[Zero D]`.

### TemporalCoherentFamily properties NOT needed beyond forward_F/backward_P:

The `TemporalCoherentFamily` extends `FMCS` adding only `forward_F` and `backward_P`. Both are used. No excess.

### BFMCS properties NOT needed:

`nonempty` is structurally required but never directly referenced in the truth lemma proof.

---

## Minimal Frame Definition Proposal

### What the TruthLemma Actually Needs

The TruthLemma needs the following **minimal bundle**:

```lean
-- Minimal requirements for truth lemma:
structure MinimalTemporalBundle (D : Type*) [Preorder D] where
  -- Modal structure
  families : Set (FMCS D)
  modal_forward : forall fam in families, forall phi t,
    Box phi in fam.mcs t -> forall fam' in families, phi in fam'.mcs t
  modal_backward : forall fam in families, forall phi t,
    (forall fam' in families, phi in fam'.mcs t) -> Box phi in fam.mcs t
  -- Temporal coherence
  temporally_coherent : forall fam in families,
    (forall t phi, F phi in fam.mcs t -> exists s >= t, phi in fam.mcs s) /\
    (forall t phi, P phi in fam.mcs t -> exists s <= t, phi in fam.mcs s)
```

Where each `FMCS D` requires:
```lean
structure FMCS (D : Type*) [Preorder D] where
  mcs : D -> Set Formula
  is_mcs : forall t, SetMaximalConsistent (mcs t)
  forward_G : forall t t' phi, t <= t' -> G phi in mcs t -> phi in mcs t'
  backward_H : forall t t' phi, t' <= t -> H phi in mcs t -> phi in mcs t'
```

**This is EXACTLY what is already defined.** The existing infrastructure has already been minimized.

### Key Observation: D Need Not Be Int

The TruthLemma is polymorphic over `D` with `[Preorder D]`. The only hard requirement for `[Zero D]` comes from the evaluation corollaries (reference point for "time 0"). The main truth lemma works for ANY preorder.

---

## How the Canonical Model Satisfies Each Property

### Using `BidirectionalFragment M0 h_mcs0` as D

The `BidirectionalFragment` with `fragmentFMCS` satisfies ALL properties sorry-free:

| Property | How Satisfied | Sorry-Free? | Reference |
|----------|---------------|-------------|-----------|
| `mcs` | `fun w => w.world` | Yes | CanonicalCompleteness.lean:75 |
| `is_mcs` | `fun w => w.is_mcs` | Yes | CanonicalCompleteness.lean:76 |
| `forward_G` | CanonicalR = GContent subset | Yes | CanonicalCompleteness.lean:77-79 |
| `backward_H` | GContent/HContent duality | Yes | CanonicalCompleteness.lean:80-82 |
| `forward_F` | `forward_F_stays_in_fragment` | Yes | CanonicalCompleteness.lean:91-97 |
| `backward_P` | `backward_P_stays_in_fragment` | Yes | CanonicalCompleteness.lean:105-113 |
| `[Preorder D]` | CanonicalR is reflexive + transitive | Yes | BidirectionalReachable.lean:263-266 |
| `LinearOrder D` (quotient) | `bidirectional_totally_ordered` | Yes | BidirectionalReachable.lean:728-740 |

### What's Missing for the Fragment-as-D Approach

To use `BidirectionalFragment` directly as D, the downstream infrastructure needs:

1. **`[Zero D]` for evaluation**: Need a distinguished element. `BidirectionalFragment.root` serves as the "origin" (the MCS we start from). Provide `[Zero D]` via:
   ```lean
   instance : Zero (BidirectionalFragment M0 h_mcs0) :=
     ⟨BidirectionalFragment.root⟩
   ```

2. **BFMCS construction**: Need `modal_forward` and `modal_backward`. For a SINGLE-family BFMCS (just `{fragmentFMCS}`), both hold trivially: Box phi in the only family implies phi in the only family (by T-axiom). But single-family modal saturation is limited.

3. **Modal saturation**: For Diamond witnesses, need multiple families. This is where `diamondWitnessMCS` in CanonicalCompleteness.lean comes in -- but each witness family also needs to be a FULL FMCS with F/P coherence, which brings back the construction challenge.

4. **Representation.lean bridge**: The `Representation.lean` module constructs `TaskFrame Int`, `TaskModel`, `WorldHistory` from a BFMCS. This currently hardcodes `Int`. Generalizing to arbitrary `D` requires refactoring.

---

## The Sorry Chain: Precisely Where It Breaks

```
standard_weak_completeness (Representation.lean)
  <- construct_saturated_bfmcs_int (TemporalCoherentConstruction.lean)
    <- fully_saturated_bfmcs_exists_int [1 SORRY]
      Needs: temporal coherence + modal saturation simultaneously

      Temporal coherence alone: SOLVED
        fragmentFMCS has sorry-free forward_F/backward_P

      Modal saturation alone: SOLVED
        exists_fullySaturated_extension (ModalSaturation.lean) is sorry-free

      The combination: UNSOLVED
        Modal saturation creates new witness families
        Each witness family needs its own FMCS with temporal coherence
        Building temporally coherent FMCS for witness roots is the blocker
```

The 1 sorry in `fully_saturated_bfmcs_exists_int` (line 600 of TemporalCoherentConstruction.lean) encapsulates the ENTIRE remaining gap.

---

## Architectural Options for Eliminating the Sorry

### Option A: Use Fragment Directly as D (Recommended)

**Approach**: Replace `BFMCS Int` with `BFMCS (BidirectionalFragment M0 h_mcs0)` (or its quotient).

**What this eliminates**: The entire Int-chain construction problem. No need for dovetailing, successor orders, or chain-to-Int conversion.

**What remains**: Modal saturation for the fragment-based BFMCS. Each diamond witness needs a temporally coherent FMCS over the fragment. But since each witness root is also in the canonical frame, we can build a fragment rooted at the witness MCS, giving another sorry-free FMCS.

**Effort**: Refactor `Representation.lean` to accept `D` with `[LinearOrder D]` + `[Zero D]` instead of hardcoded `Int`. The truth lemma and BFMCS definitions already support this.

**Key insight**: The diamond witness for `Diamond(psi) in M` produces a witness MCS W via Lindenbaum. W is an MCS. We can build `BidirectionalFragment W h_mcs_W` which gives another sorry-free fragment-level FMCS. The families in the BFMCS would be indexed by witness roots.

**Challenge**: Each witness family has a DIFFERENT fragment (different root). The domain D must be the SAME across all families. This means D cannot be a single fragment -- it would need to be some common structure that embeds all fragments.

### Option B: Universal Canonical Frame as D

**Approach**: Use the set of ALL MCSes as D (the full canonical frame), ordered by CanonicalR.

**What this gives**: Every MCS is a point in D. Every fragment embeds. F/P witnesses exist at the canonical frame level (proven in `canonical_forward_F`/`canonical_backward_P`).

**Challenge**: The universal canonical frame is NOT totally ordered (it's a preorder, not linear). The truth definition requires `Preorder D` which suffices, but the completeness bridge to standard semantics may need linearity.

### Option C: Single-Family Completeness

**Approach**: Prove completeness using a SINGLE FMCS family (no bundle). This avoids the modal saturation problem entirely.

**What changes**: The box case in the truth lemma becomes trivial for a single-family BFMCS. Box phi is true iff phi is true (S5 with one world = trivial). This might be TOO weak if the logic has proper S5 modal content that distinguishes worlds.

**Analysis**: Since the logic has Diamond (the dual of Box), and the modal axioms include K + T + 4 + 5 (full S5), the single-world/single-family approach is actually SOUND for S5 -- every S5 formula valid on a single point is valid everywhere. But we need the CONVERSE: consistent formulas are satisfiable. A consistent formula like `Diamond(p) & Diamond(neg p)` requires multiple worlds. So single-family is insufficient.

---

## Confidence Level

**High confidence** in the following findings:
- The TruthLemma requires exactly `[Preorder D]` + `[Zero D]` (for corollaries only)
- The FMCS fields `mcs`, `is_mcs`, `forward_G`, `backward_H` are ALL used and NONE are excess
- The temporal coherence properties `forward_F`, `backward_P` are both needed
- The `fragmentFMCS` satisfies all requirements sorry-free at the fragment level
- The conversion to `FMCS Int` is the sole remaining obstacle

**Medium confidence** in the Option A recommendation:
- The fragment-as-D approach eliminates the Int conversion problem
- But the modal saturation challenge (multiple families over a common D) remains
- The key unresolved question: can we define a common domain that embeds all witness fragments?

**Low confidence** in effort estimates:
- The Representation.lean refactoring scope depends on how tightly `Int` is hardcoded
- The modal saturation integration may surface new blockers

---

## Summary: The Minimal Frame

The TruthLemma's requirements are already minimal. The existing FMCS and BFMCS definitions contain no excess fields. The problem is NOT in the type signatures but in the CONSTRUCTION: building a concrete instance that satisfies all requirements simultaneously.

The fragment-level `fragmentFMCS` proves that ALL requirements CAN be satisfied sorry-free -- just not yet for a domain that matches the downstream `Int` requirement. The path forward is either:

1. Generalize downstream from `Int` to `[LinearOrder D]` (then fragment works directly), OR
2. Build a sorry-free `FMCS Int` from the fragment (the current blocked approach)

Option 1 avoids the fundamental blocker (Int conversion) by removing the requirement.
