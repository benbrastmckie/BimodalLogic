# Research Report: Constructing Fully Adequate Canonical World History via `truth_at`

**Task**: 956 - Construct D as translation group from syntax
**Date**: 2026-03-09
**Session**: sess_1773117868_29907
**Run**: 028
**Effort**: High
**Dependencies**: research-027 (BFMCS-to-TaskFrame lifting analysis), CanonicalConstruction.lean (sorry-free truth lemma), CanonicalFMCS.lean (all-MCS FMCS), FragmentCompleteness.lean (fragment chain)
**Sources/Inputs**: Full codebase analysis (Truth.lean, BFMCSTruth.lean, TruthLemma.lean, CanonicalConstruction.lean, Representation.lean, CanonicalFMCS.lean, CanonicalCompleteness.lean, FragmentCompleteness.lean, TemporalDomain.lean, TranslationGroup.lean, TemporalCoherentConstruction.lean, BFMCS.lean, FMCSDef.lean, ROAD_MAP.md)
**Artifacts**: This report
**Standards**: report-format.md, return-metadata-file.md

## Executive Summary

- The project already HAS a sorry-free `canonical_truth_lemma` in `CanonicalConstruction.lean` that connects MCS membership directly to `truth_at` -- the standard semantic truth predicate. This is the "disciplined approach" the user requests.
- The `bmcs_truth_at` predicate (in `BFMCSTruth.lean`) and its associated `bmcs_truth_lemma` (in `TruthLemma.lean`) are **structurally redundant** -- they duplicate `truth_at` with a different quantification domain for box. The sorry-free `canonical_truth_lemma` in `CanonicalConstruction.lean` already proves the same result directly at the `truth_at` level.
- The remaining sorry is **`fully_saturated_bfmcs_exists_int`** in `TemporalCoherentConstruction.lean` -- constructing a BFMCS over Int that is simultaneously temporally coherent and modally saturated. This sorry propagates through `construct_saturated_bfmcs_int` to `Representation.lean`.
- The `CanonicalFMCS.lean` module provides a **sorry-free** `temporal_coherent_family_exists_CanonicalMCS` that constructs a temporally coherent FMCS over `CanonicalMCS` (the type of ALL maximal consistent sets). This is the correct foundation.
- The path forward: build a BFMCS over `CanonicalMCS` (not Int) with both temporal coherence and modal saturation, apply the existing `canonical_truth_lemma` pattern, and prove completeness. The Int-indexed chain approach is a dead end for temporal coherence.
- Several files and definitions should be archived to Boneyard to reduce distraction.

## Context & Scope

The user's instruction is precise: construct a fully adequate canonical world history (FMCS) and bundle that works directly with `truth_at` from `Semantics/Truth.lean`, avoiding `bmcs_truth_at` and the bridge theorem it would require. Additionally, identify definitions that should be archived.

### What `truth_at` Requires

From `Truth.lean` (lines 112-119), `truth_at` is parameterized by:
- `M : TaskModel F` (a TaskFrame `F` with valuation)
- `Omega : Set (WorldHistory F)` (admissible histories for box)
- `tau : WorldHistory F` (a specific history)
- `t : D` (a time point, where `D` has `AddCommGroup`, `LinearOrder`, `IsOrderedAddMonoid`)
- `phi : Formula`

The box case: `forall sigma in Omega, truth_at M Omega sigma t phi`
Temporal cases: `forall s, s < t -> ...` (irreflexive, strict ordering)

### What Already Works

`CanonicalConstruction.lean` already provides:
1. `CanonicalWorldState` = `{ M : Set Formula // SetMaximalConsistent M }`
2. `CanonicalTaskFrame : TaskFrame Int` with `canonical_task_rel` (GContent/HContent)
3. `CanonicalTaskModel : TaskModel CanonicalTaskFrame` with valuation = MCS membership
4. `to_history : FMCS Int -> WorldHistory CanonicalTaskFrame` with domain = `fun _ => True`
5. `CanonicalOmega B` = histories from bundle families
6. **`canonical_truth_lemma`**: sorry-free proof that `phi in fam.mcs t <-> truth_at CanonicalTaskModel (CanonicalOmega B) (to_history fam) t phi`

This theorem is EXACTLY what we want. It uses `truth_at` directly, no `bmcs_truth_at` involved.

### Why the Sorry Remains

The `canonical_truth_lemma` requires:
- `B : BFMCS Int` -- a bundle of FMCS families over Int
- `h_tc : B.temporally_coherent` -- each family has forward_F and backward_P

The sorry is in constructing such a `B`. Specifically, `fully_saturated_bfmcs_exists_int` (line 470-490 of `TemporalCoherentConstruction.lean`) is sorry-backed because combining temporal coherence with modal saturation over Int is hard -- the Int-indexed dovetailing chain has F-persistence problems (fragment elements may be "jumped over").

## Findings

### Finding 1: The Existing Architecture is Correct

The codebase has TWO parallel truth lemma chains:

**Chain A (via `bmcs_truth_at` -- REDUNDANT)**:
```
BFMCSTruth.lean: defines bmcs_truth_at
TruthLemma.lean: proves bmcs_truth_lemma (phi in MCS <-> bmcs_truth_at)
Representation.lean: proves shifted_truth_lemma (phi in MCS <-> truth_at ... shiftClosedCanonicalOmega ...)
```

**Chain B (via `truth_at` directly -- THE CORRECT PATH)**:
```
CanonicalConstruction.lean: proves canonical_truth_lemma (phi in MCS <-> truth_at ... CanonicalOmega ...)
```

Chain B is strictly better because:
- It proves the result DIRECTLY against `truth_at`, no intermediate
- It does not import `BFMCSTruth.lean`
- The proof structure is identical to Chain A's box/temporal cases
- It was completed in Task 945 and is sorry-free

Chain A exists because historically `bmcs_truth_at` was introduced as an intermediate step. But `CanonicalConstruction.lean` proved the intermediate is unnecessary.

**Conclusion**: Chain A (`bmcs_truth_at` and its truth lemma) is dead weight. The project should use Chain B exclusively.

### Finding 2: The `CanonicalMCS` Approach Resolves the Int Problem

The fundamental problem with Int-indexed FMCS is that the dovetailing chain cannot guarantee visiting all F/P witnesses. The `CanonicalMCS` approach in `CanonicalFMCS.lean` resolves this completely:

- `CanonicalMCS` is the type of ALL maximal consistent sets
- `canonicalMCSBFMCS : FMCS CanonicalMCS` maps each MCS to itself
- `canonicalMCS_forward_F` and `canonicalMCS_backward_P` are **sorry-free**
- `temporal_coherent_family_exists_CanonicalMCS` is **sorry-free**

The obstacle: `truth_at` requires `D` to have `AddCommGroup`, `LinearOrder`, `IsOrderedAddMonoid`. The type `CanonicalMCS` has only `Preorder` (not even total, let alone linear). So we cannot directly use `truth_at` with `D = CanonicalMCS`.

### Finding 3: The Two Viable Paths to Completeness

**Path A: Build BFMCS over CanonicalMCS, prove completeness at BFMCS level, then lift**

1. Build a BFMCS over `CanonicalMCS` with modal saturation (sorry-free using `CanonicalCompleteness.lean` diamond witness infrastructure)
2. Temporal coherence is sorry-free from `canonicalMCS_forward_F/backward_P`
3. Apply `canonical_truth_lemma` from `CanonicalConstruction.lean` -- BUT this requires `D = Int`, not `D = CanonicalMCS`

Problem: The `canonical_truth_lemma` in `CanonicalConstruction.lean` is hard-coded to `BFMCS Int`. To use `CanonicalMCS`, we need to generalize it.

**Path B: Generalize `canonical_truth_lemma` to arbitrary Preorder D**

Looking at `CanonicalConstruction.lean`, the proof of `canonical_truth_lemma` requires:
- `BFMCS Int` with `temporally_coherent`
- `to_history : FMCS Int -> WorldHistory CanonicalTaskFrame`

The `to_history` construction requires:
- `domain = fun _ => True` -- works for any D
- `states t _ = (fam.mcs t, fam.is_mcs t)` -- works for any D
- `respects_task` -- requires proving `canonical_task_rel` between adjacent MCS

The `CanonicalTaskFrame` requires D to have `AddCommGroup`, `LinearOrder`, `IsOrderedAddMonoid` because `TaskFrame` requires these typeclass constraints on D. But the `canonical_task_rel` definition `GContent(M) ⊆ N ∧ HContent(N) ⊆ M` is independent of the group/order structure.

**Key Insight**: The `truth_at` definition in `Truth.lean` requires these typeclass constraints. So we CANNOT avoid them if we want to use `truth_at`.

**Path C (Recommended): Prove completeness via `CanonicalMCS` BFMCS, connect to standard validity via representation**

1. Observe that `bmcs_truth_lemma` works for ANY `Preorder D` with `Zero D`. It is already sorry-free.
2. Build a BFMCS over `CanonicalMCS` that is:
   - Temporally coherent (from `canonicalMCS_forward_F/backward_P`, sorry-free)
   - Modally saturated (using diamond witness construction, adapting `CanonicalCompleteness.lean`)
3. Apply `bmcs_truth_lemma` to get: `phi in fam.mcs t <-> bmcs_truth_at B fam t phi`
4. State completeness as: if `phi` is consistent, then `bmcs_truth_at` satisfies `phi` in the canonical BFMCS
5. To connect to standard `truth_at` validity, construct the TaskFrame model separately (using the product domain or Int embedding)

Wait -- the user said to AVOID `bmcs_truth_at`. Let me reconsider.

### Finding 4: Adapting `CanonicalConstruction.lean` to CanonicalMCS

The `canonical_truth_lemma` in `CanonicalConstruction.lean` has type:
```lean
theorem canonical_truth_lemma
    (B : BFMCS Int) (h_tc : B.temporally_coherent)
    (fam : FMCS Int) (hfam : fam ∈ B.families)
    (t : Int) (phi : Formula) :
    phi ∈ fam.mcs t ↔ truth_at CanonicalTaskModel (CanonicalOmega B) (to_history fam) t phi
```

This is parameterized over `BFMCS Int`. The proof uses:
- `forward_G`, `backward_H` (from FMCS coherence)
- `modal_forward`, `modal_backward` (from BFMCS modal coherence)
- `temporal_backward_G`, `temporal_backward_H` (from temporal coherence via `TemporalCoherentFamily`)
- `to_history` (converts FMCS to WorldHistory)

None of these intrinsically require `D = Int`. The `Int` appears because:
1. `TaskFrame Int` requires `Int` to have `AddCommGroup`, `LinearOrder`, `IsOrderedAddMonoid` (which it does)
2. `to_history` builds a `WorldHistory (CanonicalTaskFrame)` where `CanonicalTaskFrame : TaskFrame Int`

To use `D = CanonicalMCS`, we would need `CanonicalMCS` to have these instances. It does not, and proving `AddCommGroup CanonicalMCS` would require Holder's theorem (as noted in `TranslationGroup.lean`).

**Resolution**: The user's instruction to "construct a fully adequate canonical world history (FMCS) and bundle thereof" and "use `truth_at`" means we need a BFMCS where D is a type compatible with `truth_at`. The existing `CanonicalConstruction.lean` already does this with `D = Int`. The only missing piece is constructing the BFMCS Int.

### Finding 5: The Correct Construction Strategy

The key insight from `CanonicalFMCS.lean` is that `canonicalMCSBFMCS` (FMCS over all MCS) has sorry-free temporal coherence. To get from this to `BFMCS Int`, we need an order-preserving embedding `Int -> CanonicalMCS`.

But this is exactly what `FragmentCompleteness.lean` does with `buildFragmentChain`! And `buildFragmentChain` is monotone (proven sorry-free). The sorry is only in `fragmentChainFMCS_forward_F/backward_P` -- proving that F/P witnesses are *visited* by the chain.

**Alternative strategy**: Instead of requiring the chain to visit every witness, modify the approach:

1. Build `canonicalMCSBFMCS` (sorry-free temporal coherence) over CanonicalMCS
2. For modal saturation: each diamond witness can be a NEW `canonicalMCSBFMCS` rooted at the witness MCS
3. This gives a BFMCS over CanonicalMCS that is both temporally coherent and modally saturated
4. To get from CanonicalMCS to a TaskFrame-compatible domain, use the existing `CanonicalConstruction.lean` pattern but with a pullback

**The pullback approach**:
- Given `chain : Int -> CanonicalMCS` (monotone, from `buildFragmentChain` or similar)
- Define `pullback_fam : FMCS Int` where `pullback_fam.mcs t = canonicalMCSBFMCS.mcs (chain t) = (chain t).world`
- `forward_G` for pullback: if `G phi in (chain t).world` and `t < t'`, then `chain t <= chain t'` (monotone), so `phi in (chain t').world` by `canonicalMCSBFMCS.forward_G`
- `backward_H` for pullback: symmetric
- `forward_F` for pullback: if `F phi in (chain t).world`, need `exists s > t, phi in (chain s).world` -- THIS IS THE SAME SORRY

The F-persistence problem is unavoidable when pulling back from CanonicalMCS to Int via a chain. The chain may jump over witnesses.

### Finding 6: The Real Solution -- Direct BFMCS over CanonicalMCS with Custom TaskFrame

We cannot avoid the domain constraint. `truth_at` requires `AddCommGroup D`, `LinearOrder D`, `IsOrderedAddMonoid D`. But we CAN construct a TaskFrame where `D` is one of:
- `Int` (current approach, has F-persistence problem in chain)
- `Q` (rationals, used in product domain TemporalDomain.lean)
- The `TranslationGroup` (from TranslationGroup.lean, lacks `AddCommGroup`)

The **product domain approach** from `TemporalDomain.lean` already constructs `D = Q` with:
- `CanonicalProductFrame : TaskFrame Q`
- `CanonicalProductModel` with valuation depending only on MCS component
- `CanonicalProductHistory m` for each quotient class `m`
- `ShiftClosedProductOmega` that IS shift-closed

This gives us a working TaskFrame with `D = Q`. The missing piece is the truth lemma connecting MCS membership to `truth_at` via this frame.

For the product domain, truth at `([M], q)` depends only on `M`. Each `CanonicalProductHistory m` maps time `t` to `(m, t)`. The key question is: can we prove

```
phi in (representative [M]).world <-> truth_at CanonicalProductModel Omega (CanonicalProductHistory [M]) t phi
```

For the **atom** case: `truth_at` gives `exists ht, valuation (m, t) p` = `atom p in (representative m).world`. This matches.

For the **box** case: `truth_at` quantifies over `sigma in Omega`. If `Omega = CanonicalProductOmega`, then `sigma = CanonicalProductHistory m'` for some `m'`. So box becomes: `forall m', truth_at ... (CanonicalProductHistory m') t phi`. This is the BFMCS pattern -- quantify over all families/histories.

For **temporal** cases: `forall s, t < s -> truth_at ... tau s phi`. Since `tau = CanonicalProductHistory m` and states at time `s` = `(m, s)`, truth at `s` depends on the SAME `m`. So `G phi` holds iff `phi` holds at all future times for the SAME quotient class. But MCS membership is constant (the quotient class maps to a fixed representative MCS). So `G phi` is true iff `phi in (representative m).world` -- which would make G trivially equivalent to the identity, collapsing temporal semantics.

**This is the fatal flaw of constant-family approaches for temporal operators.**

### Finding 7: The Fundamental Architecture Decision

The codebase faces a fundamental tension:

1. `truth_at` requires a rich domain D (AddCommGroup, LinearOrder, etc.)
2. Temporal coherence (forward_F, backward_P) requires non-constant families
3. Non-constant families over Int have the F-persistence problem
4. The all-MCS approach (`CanonicalMCS`) resolves F-persistence but lacks the algebraic structure for `truth_at`

**The `CanonicalConstruction.lean` approach resolves this** by:
- Using `D = Int` for the TaskFrame
- Using non-constant families (each FMCS has `mcs t` varying with `t`)
- The `to_history` function maps each time `t` to `(fam.mcs t, fam.is_mcs t)` as the world state
- The `canonical_truth_lemma` proof works because it uses `forward_G`, `backward_H`, `modal_forward`, `modal_backward`, and `temporal_backward_G/H` -- all proven sorry-free

The ONLY remaining problem is constructing the BFMCS Int itself. This is `fully_saturated_bfmcs_exists_int`.

### Finding 8: Resolution Path for `fully_saturated_bfmcs_exists_int`

The sorry in `fully_saturated_bfmcs_exists_int` requires providing:
```lean
exists (B : BFMCS Int),
  (forall gamma in Gamma, gamma in B.eval_family.mcs 0) ∧
  B.temporally_coherent ∧
  is_modally_saturated B
```

**Temporal coherence** means: for each family `fam` in `B.families`:
- `forward_F`: `F phi in fam.mcs t -> exists s > t, phi in fam.mcs s`
- `backward_P`: `P phi in fam.mcs t -> exists s < t, phi in fam.mcs s`

**Modal saturation** means: for each family `fam` in `B.families`, for each diamond obligation `Diamond(psi) in fam.mcs t`, there exists a witness family `fam'` in `B.families` with `psi in fam'.mcs t`.

**The approach that could work**:

1. Use the `CanonicalMCS`-level BFMCS (sorry-free temporal coherence, sorry-free modal saturation) as the "conceptual" model
2. Instead of embedding into Int via a single chain, use `CanonicalMCS` as the domain D
3. BUT `CanonicalMCS` does not satisfy `AddCommGroup` etc.
4. So state completeness differently: prove `bmcs_valid phi -> derivable phi` (this is `bmcs_truth_lemma` based)
5. Then prove `valid phi -> bmcs_valid phi` as a separate theorem (standard validity implies BFMCS validity)

Wait -- `valid phi -> bmcs_valid phi` is the wrong direction. We need `valid phi -> derivable phi`. The contrapositive is: `not derivable phi -> exists model falsifying phi`. The model is the canonical BFMCS.

Actually, looking at `Representation.lean` lines 611-636 (`standard_weak_completeness`), the proof works by:
1. Assume `not derivable phi`
2. Then `[phi.neg]` is consistent
3. Construct BFMCS from `construct_saturated_bfmcs_int`
4. By `shifted_truth_lemma`: neg phi is true at the canonical model with shift-closed Omega
5. By `valid phi`: phi is true at the SAME model (since Omega is shift-closed)
6. Contradiction

The key: step 3 uses `construct_saturated_bfmcs_int` which has the sorry. If we could construct the BFMCS over CanonicalMCS instead, we'd need step 4 to work with CanonicalMCS, but `shifted_truth_lemma` requires `BFMCS Int`.

### Finding 9: The Correct Disciplined Approach

Given the constraints, the disciplined approach is:

**Step 1**: Accept that `CanonicalConstruction.lean` already provides the correct truth lemma (`canonical_truth_lemma`). This uses `truth_at` directly, exactly as the user requests.

**Step 2**: The remaining work is constructing `BFMCS Int` with temporal coherence + modal saturation. This is `fully_saturated_bfmcs_exists_int`.

**Step 3**: The construction should proceed as follows:
1. Start with consistent context Gamma
2. Extend to MCS M0 via Lindenbaum
3. Build the BidirectionalFragment rooted at M0
4. Use `buildFragmentChain` to get `chain : Int -> BidirectionalFragment M0`
5. Build `fragmentChainFMCS` as the eval family
6. For each diamond obligation `Diamond(psi)` at time t:
   a. Get witness MCS W from `diamondWitnessMCS`
   b. Build BidirectionalFragment rooted at W
   c. Build `fragmentChainFMCS` for W
   d. This witness family has sorry-free temporal coherence (inherits from fragment)
7. Bundle all families into BFMCS Int

**The remaining sorry** is proving `forward_F` and `backward_P` for `fragmentChainFMCS` (lines 414-471 of `FragmentCompleteness.lean`). The F-persistence problem means that even though the fragment has witnesses, the Int chain may not visit them.

**Step 4**: To resolve the F-persistence problem, consider:
- Using a different chain construction (omega-squared, priority queue)
- Using the reactive schedule more carefully (process F-obligations BEFORE they are jumped over)
- Proving that the chain construction can be bounded to prevent jumping

### Finding 10: Summary of What Works and What Doesn't

| Component | File | Status | Notes |
|-----------|------|--------|-------|
| `truth_at` definition | Truth.lean | OK | Irreflexive semantics |
| `canonical_truth_lemma` (truth_at) | CanonicalConstruction.lean | SORRY-FREE | Uses BFMCS Int + temporal coherence |
| `bmcs_truth_lemma` (bmcs_truth_at) | TruthLemma.lean | SORRY-FREE | Redundant with above |
| `canonicalMCSBFMCS` (FMCS CanonicalMCS) | CanonicalFMCS.lean | SORRY-FREE | All-MCS approach |
| `temporal_coherent_family_exists_CanonicalMCS` | CanonicalFMCS.lean | SORRY-FREE | The key victory |
| `fragmentFMCS` (FMCS BidirectionalFragment) | CanonicalCompleteness.lean | SORRY-FREE | Fragment-level |
| `fragmentChainFMCS` (FMCS Int via chain) | FragmentCompleteness.lean | 2 SORRIES | forward_F, backward_P |
| `fully_saturated_bfmcs_exists_int` | TemporalCoherentConstruction.lean | 1 SORRY | The main blocker |
| `standard_weak_completeness` | Representation.lean | SORRY-DEPENDENT | Inherits from above |
| Product domain (D = Q) | TemporalDomain.lean | OK | No truth lemma proven |
| Translation group | TranslationGroup.lean | PARTIAL | Lacks AddCommGroup |

## ROAD_MAP.md Reflection

### Pitfalls Checked

| Dead End | Relevance | Impact on Recommendations |
|----------|-----------|--------------------------|
| Single-History FDSM | Low | Not recommending single-history |
| Constant Witness Family | HIGH | Product domain constant families have same problem |
| Single-Family BFMCS modal_backward | Medium | Using multi-family approach |
| Non-Standard Validity | HIGH | Must use `truth_at`, not `bmcs_truth_at`, for final result |
| MCS-Membership Semantics for Box | HIGH | `bmcs_truth_at` IS this pattern -- must avoid |

### Strategy Alignment

| Strategy | Status | Relevance |
|----------|--------|-----------|
| Indexed MCS Family | ACTIVE | Core strategy, `CanonicalConstruction.lean` implements it |
| Representation-First | CONCLUDED | `canonical_truth_lemma` is the representation theorem |

## Boneyard Archival Recommendations

The following files/definitions should be archived to remove distraction:

### Priority 1: Archive `bmcs_truth_at` Infrastructure

**Files to archive**:

1. **`BFMCSTruth.lean`** -- The entire file defines `bmcs_truth_at`, `bmcs_valid`, and derived properties. All of this is redundant with `truth_at` from `Truth.lean`. The `canonical_truth_lemma` in `CanonicalConstruction.lean` proves the truth lemma directly at the `truth_at` level without this intermediate.

   **Justification**: `bmcs_truth_at` was created as an intermediate step when it was unclear whether the truth lemma could be proven directly against `truth_at`. Task 945 proved it could. The intermediate is now dead weight.

   **Impact**: `TruthLemma.lean` and `Representation.lean` import `BFMCSTruth.lean`. These would need to be updated.

2. **`TruthLemma.lean`** -- Proves `bmcs_truth_lemma` connecting MCS membership to `bmcs_truth_at`. This is entirely superseded by `canonical_truth_lemma` in `CanonicalConstruction.lean` which proves the same connection directly to `truth_at`.

   **Justification**: `bmcs_truth_lemma` was the first truth lemma proven. `canonical_truth_lemma` is strictly better (fewer indirections, same sorry dependencies).

   **Impact**: `Representation.lean` uses `bmcs_truth_lemma` indirectly. The shifted truth lemma in `Representation.lean` should be kept (it handles shift-closure) but refactored to use `canonical_truth_lemma` directly.

### Priority 2: Archive Product Domain (if not pursuing that approach)

3. **`TemporalDomain.lean`** -- Defines `TemporalDomain = RestrictedQuotient x Q` with product frame. This was an attempt to sidestep the G-closed MCS problem but research-027 showed it doesn't solve the truth lemma. The product domain has the constant-family problem for temporal operators.

   **Justification**: The product domain approach was explored in plan v007 but research-026 and research-027 showed it does not work for the truth lemma. The correct approach uses non-constant families over Int (CanonicalConstruction.lean).

   **Consider keeping if**: The product domain could serve as the representation target (showing the canonical model embeds into a TaskFrame with rational time). In that case, keep it but mark it as optional representation infrastructure, not truth lemma infrastructure.

### Priority 3: Clean Up Obsolete Int Constructions

4. **`DovetailingChain.lean`** (if it still exists) -- The original Int chain construction, superseded by `FragmentCompleteness.lean`'s `buildFragmentChain`.

5. **`temporal_coherent_family_exists_Int`** in `TemporalCoherentConstruction.lean` (lines 387-396) -- This is a sorry-backed theorem for Int that is superseded by `temporal_coherent_family_exists_CanonicalMCS` in `CanonicalFMCS.lean`. The Int version delegates to a non-existent construction.

   **Justification**: The CanonicalMCS version is sorry-free. The Int version is unused (the active path goes through `fully_saturated_bfmcs_exists_int` which has its own sorry).

### Priority 4: Archive FMCS Definitions with Reflexive Semantics

6. Any residual references to reflexive G/H semantics (forward_G with `<=` instead of `<`). The codebase was migrated to irreflexive semantics in Task 956 but some comments/dead code may remain.

### Files to KEEP

- **`CanonicalConstruction.lean`** -- The canonical truth lemma. This is the heart of the approach.
- **`CanonicalFMCS.lean`** -- Sorry-free temporal coherence over CanonicalMCS.
- **`CanonicalCompleteness.lean`** -- Fragment FMCS, enriched seeds, diamond witness infrastructure.
- **`FragmentCompleteness.lean`** -- The Int chain construction (has sorries but is the active approach).
- **`Representation.lean`** -- Standard completeness theorems (need the shifted truth lemma).
- **`BFMCS.lean`** -- BFMCS definition with modal coherence.
- **`FMCSDef.lean`** -- FMCS definition.
- **`Truth.lean`** -- Standard truth definition.
- **`TranslationGroup.lean`** -- Future use for D construction (AddGroup proven).

## Recommendations

### Recommendation 1: Refactor `Representation.lean` to Use `canonical_truth_lemma` Directly

Currently `Representation.lean` has its OWN copy of the truth lemma (`canonical_truth_lemma_all` at line 269). This duplicates `CanonicalConstruction.lean`'s `canonical_truth_lemma`. The two are structurally identical. Consolidate by:

1. Making `Representation.lean` import `CanonicalConstruction.lean`
2. Removing the duplicate `canonical_truth_lemma_all` from `Representation.lean`
3. Updating `shifted_truth_lemma` to build on `CanonicalConstruction.lean`'s version

### Recommendation 2: Focus on Resolving `fully_saturated_bfmcs_exists_int`

The single remaining sorry that blocks standard completeness. The approach:

1. Use `fragmentChainFMCS` from `FragmentCompleteness.lean` as the eval family
2. For modal saturation, add witness families built from `buildWitnessFMCS`
3. Prove temporal coherence for witness families:
   - Each witness family IS a `fragmentChainFMCS` rooted at the diamond witness MCS
   - So each inherits the same temporal coherence properties
   - The sorry reduces to `fragmentChainFMCS_forward_F/backward_P`

4. The remaining mathematical challenge: prove `fragmentChainFMCS_forward_F`. This requires either:
   a. A refined chain construction that bounds step sizes
   b. An omega-squared construction
   c. A completely different approach (e.g., compactness argument)

### Recommendation 3: Archive `bmcs_truth_at` Infrastructure

Per the Boneyard recommendations above. This directly addresses the user's instruction to avoid `bmcs_truth_at` and its bridge theorem.

### Recommendation 4: Do NOT Pursue Product Domain for Truth Lemma

The product domain (`TemporalDomain.lean`) cannot support a truth lemma for temporal operators because:
- Each `CanonicalProductHistory m` is constant in the MCS component (always `m`)
- So `G phi` collapses to `phi` (temporal trivialization)
- This is the same problem as constant witness families (Dead End in ROAD_MAP.md)

The product domain may have value for the representation theorem (optional), but NOT for the truth lemma.

## Decisions

- **D1**: `canonical_truth_lemma` in `CanonicalConstruction.lean` is the correct and only truth lemma to use. It connects MCS membership to `truth_at` without any intermediate.
- **D2**: `bmcs_truth_at`, `bmcs_truth_lemma`, and `bmcs_valid` should be archived to Boneyard as redundant intermediates.
- **D3**: The remaining sorry is `fully_saturated_bfmcs_exists_int` -- constructing a temporally coherent, modally saturated BFMCS over Int.
- **D4**: The product domain approach does NOT work for the truth lemma and should not be pursued further for that purpose.
- **D5**: The `CanonicalMCS` approach provides sorry-free temporal coherence but cannot be used with `truth_at` directly due to typeclass constraints.

## Risks & Mitigations

| Risk | Severity | Mitigation |
|------|----------|------------|
| `fragmentChainFMCS_forward_F` may be unprovable for the current chain | High | Investigate omega-squared construction or compactness argument |
| Archiving `BFMCSTruth.lean` may break `TruthLemma.lean` | Medium | TruthLemma.lean should also be archived since it proves bmcs_truth_lemma |
| Archiving may break downstream imports in `Representation.lean` | Medium | Refactor Representation.lean first to remove bmcs_truth_at dependency |
| Product domain work (TemporalDomain.lean) becomes stranded | Low | Keep as optional representation infrastructure, mark as non-critical |

## Context Extension Recommendations

### Discovered Concepts Requiring Documentation

| Concept | Report Section | Currently Documented? | Gap Type |
|---------|----------------|----------------------|----------|
| Dual truth lemma chains (bmcs_truth_at vs truth_at) | Finding 1 | No | extension |
| F-persistence problem in Int chains | Finding 5 | Partial (in code comments) | extension |
| CanonicalMCS vs Int domain tradeoff | Finding 7 | No | new_file |

### Summary

- **New files needed**: 0 (the existing domain context files are sufficient after archival)
- **Extensions needed**: 1 (update kripke-semantics-overview.md with F-persistence discussion)
- **Tasks to create**: 0 (meta task)
- **High priority gaps**: 0

## Appendix

### Search Queries Used

- `Glob Theories/Bimodal/**/*.lean` -- full module listing
- `Grep bmcs_truth_at` -- identify all references to the redundant predicate
- `Grep import.*BFMCSTruth` -- identify import dependencies
- `Read` of 15+ source files covering the complete metalogic pipeline

### Key File Relationships

```
Truth.lean (truth_at)
  |
  +-- CanonicalConstruction.lean (canonical_truth_lemma: MCS <-> truth_at) [SORRY-FREE]
  |     |
  |     +-- BFMCS.lean (modal coherence)
  |     +-- TemporalCoherentConstruction.lean (temporal backward G/H) [SORRY-FREE]
  |     +-- CanonicalFrame.lean (GContent/HContent)
  |
  +-- Representation.lean (standard completeness) [SORRY-DEPENDENT]
        |
        +-- construct_saturated_bfmcs_int [SORRY in TemporalCoherentConstruction.lean]
        |
        +-- BFMCSTruth.lean (bmcs_truth_at) [SHOULD BE ARCHIVED]
        +-- TruthLemma.lean (bmcs_truth_lemma) [SHOULD BE ARCHIVED]

CanonicalFMCS.lean (temporal_coherent_family_exists_CanonicalMCS) [SORRY-FREE]
  |
  +-- CanonicalCompleteness.lean (fragment FMCS) [SORRY-FREE]
  |
  +-- FragmentCompleteness.lean (Int chain) [2 SORRIES: forward_F, backward_P]
```
