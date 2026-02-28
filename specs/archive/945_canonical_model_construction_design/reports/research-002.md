# Research Report: Task 945 -- Canonical Model Construction Design (research-002)

**Task**: 945 -- Design canonical model construction for TruthLemma
**Started**: 2026-02-27
**Completed**: 2026-02-27
**Effort**: Large (intensive study)
**Dependencies**: TruthLemma.lean, BFMCS.lean, BFMCSTruth.lean, CanonicalFMCS.lean, CanonicalFrame.lean, TemporalCoherentConstruction.lean, Completeness.lean, Representation.lean, Semantics/Truth.lean, Semantics/Validity.lean
**Sources/Inputs**: Codebase analysis, research-001.md (previous research), ROAD_MAP.md Dead Ends, SEP Temporal Logic, Goldblatt (1987/1992), Zanardo bundled trees, Burgess tense logic
**Artifacts**: This report (research-002.md)
**Standards**: report-format.md, return-metadata-file.md

---

## Executive Summary

- The user explicitly rejects the FMP bypass recommended in research-001 and demands a direct BFMCS construction.
- The single blocking sorry is `fully_saturated_bfmcs_exists_int` (line 600 of TemporalCoherentConstruction.lean), which must produce a BFMCS satisfying temporal coherence for ALL families AND modal saturation simultaneously.
- Two construction strategies are analyzed in depth: **bottom-up recursive unraveling** and **top-down canonical MCS approach**. Both are mathematically viable but face distinct obstacles.
- The top-down approach using CanonicalMCS as the domain (already partially implemented in CanonicalFMCS.lean) is the more promising foundation, but requires a novel **multi-family construction** with non-constant temporally coherent witness families.
- The key mathematical insight is that the time domain D should be CanonicalMCS itself (a Preorder, not necessarily a LinearOrder), which already gives sorry-free temporal coherence for a single family. The challenge is extending to a bundle.
- A concrete construction proposal is presented using **CanonicalMCS-indexed witness families** where each diamond obligation spawns a family that is itself a CanonicalMCS FMCS rooted at the witness MCS.

---

## Context & Scope

### What Was Researched

This report conducts an intensive study of how to define the correct BFMCS construction that is sorry-free and axiom-free. The study was prompted by the user's explicit rejection of the FMP bypass approach recommended in research-001.

### Constraints

1. **Standard semantics only**: Must use `bmcs_truth_at` as defined in BFMCSTruth.lean (NOT the banned `bmcs_truth_at_mcs`)
2. **Sorry-free and axiom-free**: No `sorry`, no `axiom` in the construction
3. **Time domain D**: Must be a totally ordered commutative group of durations, with density/discreteness left open unless the logic adds corresponding axioms
4. **The TruthLemma must hold**: `bmcs_truth_lemma` is already sorry-free; the construction must provide a BFMCS satisfying `B.temporally_coherent` and `is_modally_saturated B`

### The Blocking Sorry

The single sorry at TemporalCoherentConstruction.lean:600 is:

```lean
theorem fully_saturated_bfmcs_exists_int (Gamma : List Formula) (h_cons : ContextConsistent Gamma) :
    exists (B : BFMCS Int),
      (forall gamma in Gamma, gamma in B.eval_family.mcs 0) /\
      B.temporally_coherent /\
      is_modally_saturated B := by
  sorry
```

This must produce a BFMCS over some domain satisfying three properties simultaneously:
1. **Context preservation**: `Gamma` is in the eval family at time 0
2. **Temporal coherence**: ALL families satisfy forward_F and backward_P
3. **Modal saturation**: Every diamond formula has a witness family

---

## Findings

### 1. Codebase Architecture Analysis

#### Current Type Hierarchy

```
FMCS D          -- Single family: D -> Set Formula (with forward_G, backward_H)
BFMCS D         -- Bundle: Set (FMCS D) with modal_forward, modal_backward
TemporalCoherentFamily D  -- FMCS + forward_F + backward_P
```

#### What Is Already Sorry-Free

| Component | Status | Domain |
|-----------|--------|--------|
| `bmcs_truth_lemma` | Sorry-free | Any `D` with `[Preorder D] [Zero D]` |
| `canonicalMCSBFMCS` (single FMCS) | Sorry-free | `CanonicalMCS` |
| `canonical_forward_F` | Sorry-free | `CanonicalMCS` |
| `canonical_backward_P` | Sorry-free | `CanonicalMCS` |
| `saturated_modal_backward` | Sorry-free | Any `D` with `[Preorder D]` |
| `bmcs_representation`, `bmcs_weak_completeness`, `bmcs_strong_completeness` | Sorry-free | Inherits from construction |
| `temporal_backward_G`, `temporal_backward_H` | Sorry-free | Any `D` with `[Preorder D] [Zero D]` |

#### What Has a Sorry

| Component | Sorry Count | Reason |
|-----------|-------------|--------|
| `fully_saturated_bfmcs_exists_int` | 1 | Must combine temporal coherence + modal saturation |
| `buildDovetailingChainFamily_forward_F` | 1 | Int-indexed chain cannot satisfy F witnesses |
| `buildDovetailingChainFamily_backward_P` | 1 | Int-indexed chain cannot satisfy P witnesses |

#### Key Observation: The TruthLemma Requirements

From `bmcs_truth_lemma`, the BFMCS must satisfy:
- `B.temporally_coherent`: i.e., `forall fam in B.families`, fam has forward_F and backward_P
- The BFMCS structure itself provides `modal_forward` and `modal_backward`

The `modal_backward` is derived from `is_modally_saturated B` via `saturated_modal_backward` (sorry-free). So the construction needs:
1. A `BFMCS D` (with `modal_forward` given by construction)
2. Every family temporally coherent (forward_F, backward_P)
3. Modal saturation (diamond witnesses exist)

#### Standard Semantics

From `Semantics/Truth.lean`, the standard truth definition is:

```lean
def truth_at (M : TaskModel F) (Omega : Set (WorldHistory F)) (tau : WorldHistory F) (t : D) : Formula -> Prop
  | Formula.box phi => forall (sigma : WorldHistory F), sigma in Omega -> truth_at M Omega sigma t phi
  | Formula.all_future phi => forall (s : D), t <= s -> truth_at M Omega tau s phi
  | Formula.all_past phi => forall (s : D), s <= t -> truth_at M Omega tau s phi
```

From `Semantics/Validity.lean`:

```lean
def valid (phi : Formula) : Prop :=
  forall (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] ...
```

Standard validity quantifies over `D` with `LinearOrderedAddCommGroup` structure. The `Representation.lean` module bridges BFMCS to standard semantics.

### 2. Analysis of the Time Domain D

#### What the Logic Requires

The standard semantics (`TaskFrame`, `truth_at`, `valid`) require:
- `D : Type` with `[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]`

This means D is a **totally ordered commutative group**. Examples: `Int`, `Rat`, `Real`.

#### What the BFMCS Construction Requires

The BFMCS machinery (`FMCS`, `BFMCS`, `TruthLemma`) only requires:
- `D : Type*` with `[Preorder D]` (and `[Zero D]` for the TruthLemma)

This is significantly weaker. The `CanonicalMCS` type already has a `Preorder` instance (via `CanonicalR`), and it is NOT a total order in general.

#### Key Insight: Domain Mismatch

The standard semantics requires `LinearOrderedAddCommGroup D`, but the BFMCS construction only needs `Preorder D`. The `Representation.lean` module bridges this by constructing a `TaskFrame Int` from the BFMCS and mapping families to world histories.

For the BFMCS construction itself, we are free to use ANY `Preorder D`, because `fully_saturated_bfmcs_exists_int` only promises a `BFMCS Int`, and the `Representation` module handles the embedding.

However, the user's specification says: "Time is a totally ordered commutative group of durations D." This suggests the user wants the construction to be parametric in D, or at least to use Int (which is such a group). The existing sorry is for Int.

#### The User's Density/Discreteness Point

The user says:
- If a density axiom is added to the logic, D should be dense
- If a discreteness axiom is added, D should be discrete
- If neither, D is left undetermined

This is about the standard semantics, not the BFMCS construction. The BFMCS construction uses `CanonicalMCS` as domain, which is neither dense nor discrete in any standard sense -- it is a non-total Preorder of all MCS. The Representation module then embeds this into a standard model over Int (or another group).

### 3. Bottom-Up Recursive Unraveling Analysis

#### The User's Description

Start with `{phi}` assumed consistent. Recursively unravel:
- F psi: Add {psi} to the family at a later time
- P psi: Similar for past
- G psi: Argument must be in all future sets
- H psi: Argument must be in all past sets
- Diamond psi: Creates new families in the bundle
- Box psi: Argument added to every set at the same time in every family

After finite unraveling terminates, all sets are closed under deduction and filled out to MCS.

#### Mathematical Analysis

**Strengths**:
1. Each obligation is satisfied by explicit placement
2. The construction is constructive and finite (for any given formula)
3. Time ordering arises naturally from the placement of temporal witnesses

**Obstacles**:

**(a) Termination and Closure**: The recursive unraveling terminates only for the specific subformulas of the input. But MCS requires closure under ALL formulas. After extending to MCS via Lindenbaum, NEW F/P/Diamond obligations may arise that were not in the original formula. The unraveling must handle these too.

This is exactly the problem that killed the DovetailingChain: Lindenbaum extensions introduce F-formulas whose witnesses were not pre-placed, and subsequent GContent-based extensions can corrupt earlier placements.

**(b) Partial Time Ordering**: The user notes that `F psi /\ F chi` creates two future obligations with no determined order. This means the time structure starts as a partial order. The question is whether the partial order can be extended to a total order compatible with all obligations.

For a single family, this is essentially the problem of embedding a partial order into a linear order (always possible by Szpilrajn's extension theorem). But the obligations (G psi must be in ALL future sets) create constraints that the extension must satisfy.

**(c) G/H Obligations**: If `G psi` is in the set at time t, then psi must be in ALL sets at times >= t. After Lindenbaum extension, the set at time t may contain G(chi) for chi not in the original formula. Then chi must be at ALL future times. This creates a cascading obligation.

In the CanonicalMCS approach, this is handled definitionally: `forward_G` holds because the Preorder is defined by `GContent` inclusion. In the bottom-up approach, it must be ensured explicitly.

**(d) Modal Obligations and Coherence**: Box psi at family fam and time t requires psi in ALL families at time t. This means adding psi to witness families, which may introduce new obligations in those families.

Diamond psi creates a new family. This new family must be temporally coherent. If the witness MCS at the originating time contains F(chi), then the witness family must have chi at some future time. But if the witness family is constant (same MCS at all times), temporal coherence fails for exactly the reasons documented in Dead End "Constant Witness Family Approach".

**Verdict**: The bottom-up approach is conceptually clear but faces the same fundamental obstacles as the DovetailingChain: Lindenbaum extensions introduce obligations that cannot be controlled. The recursive unraveling is essentially a finite approximation that must be extended to an infinite structure, and the extension step is where things break.

### 4. Top-Down Canonical MCS Approach Analysis

#### The User's Description

Start with the set of all maximal consistent sets. Define families as any temporally coherent set of MCS ordered by D. Show the bundle of all such families is naturally closed under time-shift. Define sentence evaluation at (world-history, time) such that the TruthLemma holds.

#### Mathematical Analysis

**Strengths**:
1. All MCS are available from the start -- no Lindenbaum extension surprises
2. CanonicalMCS already provides sorry-free temporal coherence for a single family
3. The canonical relations (CanonicalR, CanonicalR_past) are already proven reflexive and transitive

**The Key Question: What Is "Temporally Coherent"?**

A family (FMCS) over domain D assigns an MCS to each time point d in D:
- `mcs : D -> Set Formula`
- `forward_G : t <= t' -> G(phi) in mcs(t) -> phi in mcs(t')`
- `backward_H : t' <= t -> H(phi) in mcs(t) -> phi in mcs(t')`

A TemporalCoherentFamily additionally requires:
- `forward_F : F(phi) in mcs(t) -> exists s >= t, phi in mcs(s)`
- `backward_P : P(phi) in mcs(t) -> exists s <= t, phi in mcs(s)`

For the CanonicalMCS domain:
- `forward_G` holds by definition of CanonicalR (GContent inclusion)
- `backward_H` holds by duality (HContent/GContent reverse)
- `forward_F` holds trivially: each F-obligation gets a fresh Lindenbaum witness MCS which IS a CanonicalMCS element
- `backward_P` holds trivially: same argument for past

ALL of these are sorry-free in `CanonicalFMCS.lean`. The single family `canonicalMCSBFMCS` over CanonicalMCS is fully temporally coherent.

**The Multi-Family Problem**

A BFMCS needs MULTIPLE families for modal saturation. If Diamond(psi) is in some family's MCS at time t, there must exist another family with psi in its MCS at time t.

The existing `canonicalMCSBFMCS` maps each CanonicalMCS element to its own world:
```lean
def canonicalMCS_mcs (w : CanonicalMCS) : Set Formula := w.world
```

For modal saturation, we need: if Diamond(psi) is in w.world for some w, then there exists a family fam' in the bundle such that psi is in fam'.mcs(w).

**Why the Identity Family Alone Fails**: Consider a single identity family where `fam.mcs(w) = w.world`. If Diamond(psi) is in w.world, modal saturation requires a family fam' with psi in fam'.mcs(w). If fam' is also the identity family, then psi must be in w.world. But Diamond(psi) = neg(Box(neg(psi))) does not imply psi in the same MCS (that would be the T axiom for Diamond, which is not valid for arbitrary consistent sets).

So we need witness families that are NOT the identity family.

### 5. The Central Mathematical Obstacle

The obstacle documented in research-001 remains: combining temporal coherence with modal saturation.

**The Constant Family Impossibility (Documented Dead End)**: A constant family (same MCS at all times) cannot satisfy forward_F if the MCS contains `F(psi)` but not `psi`. This is a mathematical impossibility, not a formalization artifact.

**What This Means for Witness Families**: Each diamond witness family must be NON-CONSTANT and satisfy forward_F and backward_P. In other words, each witness family must be a full TemporalCoherentFamily.

### 6. Proposed Construction: CanonicalMCS Bundle with Re-Rooted Witness Families

#### Core Idea

Given a consistent context Gamma:

1. **Eval Family**: Extend Gamma to MCS M_0 via Lindenbaum. The eval family is `canonicalMCSBFMCS` with root at M_0. This is the existing sorry-free construction from CanonicalFMCS.lean.

2. **Witness Families**: For each diamond obligation Diamond(psi) at time point w (a CanonicalMCS element) in any family, create a witness family that:
   - At time w, maps to an MCS containing psi (the diamond witness)
   - Is itself a full CanonicalMCS FMCS (with the witness MCS as root)
   - Therefore inherits sorry-free temporal coherence

3. **Bundle Closure**: The bundle is the smallest set of FMCS over CanonicalMCS that:
   - Contains the eval family
   - Is closed under witness family creation for all diamond obligations

#### Construction Detail

**Step 1: Define the Witness FMCS**

Given a CanonicalMCS element w and a formula psi such that Diamond(psi) is in w.world:
- By `diamond_implies_psi_consistent`, {psi} is consistent
- By Lindenbaum, extend to MCS W containing psi
- The witness family is `canonicalMCSBFMCS` -- the SAME family structure as the eval family

Wait -- this is the critical point. `canonicalMCSBFMCS` maps EVERY CanonicalMCS element to its own world. It is a single, universal FMCS. If we put it in the bundle, then at time w, the witness family also maps to w.world. But we need a family where psi is at time w, and psi may not be in w.world.

**The Problem with the Identity Family**: The identity mapping `fam.mcs(w) = w.world` is universal: it does not depend on a "root". Every CanonicalMCS element maps to itself. So there is only ONE identity family, and it is the same for all "roots".

To get modal diversity, we need families where `fam.mcs(w)` is NOT `w.world` for some w. But the FMCS coherence conditions (forward_G, backward_H) constrain how the mapping can deviate from the identity.

#### Alternative: Non-Identity FMCS over CanonicalMCS

**Approach A: Shifted Families**

Define a family parameterized by an MCS shift. Given a CanonicalMCS element W_0 (the "origin"), define:
```
fam_shift.mcs(w) = W_0.world   -- constant at W_0
```

This is a constant family, which we already know fails for temporal coherence.

**Approach B: Translation Families**

Given a "translation" that maps each CanonicalMCS element to another one while preserving the Preorder structure, define:
```
fam_sigma.mcs(w) = sigma(w).world
```

For this to satisfy forward_G, we need: if `G(phi) in sigma(w).world` and `w <= w'`, then `phi in sigma(w').world`. This holds if `sigma` is order-preserving (i.e., `w <= w'` implies `sigma(w) <= sigma(w')`), because then `GContent(sigma(w).world) subset sigma(w').world`.

For forward_F: if `F(phi) in sigma(w).world`, need `exists s >= w, phi in sigma(s).world`. Since `sigma(w)` is an MCS, `canonical_forward_F` gives a witness MCS V with `CanonicalR sigma(w).world V` and `phi in V`. We need `V = sigma(s).world` for some `s >= w`. This is where it breaks: the witness V is a fresh Lindenbaum MCS that may not be in the image of sigma.

**Approach C: Free Families (Arbitrary Mappings with Coherence)**

Allow each family to be an arbitrary mapping `CanonicalMCS -> Set Formula` satisfying the FMCS axioms. The identity mapping is one such family. Other families assign different MCS to different time points.

The challenge is constructing such families that:
1. Satisfy forward_G and backward_H (by construction, via some ordering structure)
2. Satisfy forward_F and backward_P
3. Place the diamond witness psi at the desired time point w

### 7. The Fundamental Tension Revisited

The fundamental tension, now understood more deeply:

**For ANY family in a BFMCS over any domain D:**
- If `Diamond(psi)` is in `fam.mcs(t)` for some family fam, we need a DIFFERENT family `fam'` with `psi in fam'.mcs(t)`.
- This family `fam'` must satisfy `forward_F` and `backward_P` (temporal coherence for ALL families).
- If `fam'` is "rooted" at time t with seed psi, then `fam'.mcs(t)` is some MCS containing psi.
- But `fam'.mcs(t)` may contain `F(chi)` for some chi. By forward_F, there must exist `s >= t` with `chi in fam'.mcs(s)`.
- This `fam'.mcs(s)` is an MCS at a different time, and it may contain its own F-obligations.
- The cascading obligations must all be satisfiable.

This is exactly what the CanonicalMCS identity family handles trivially for a SINGLE family: each F-obligation gets a fresh independent Lindenbaum witness. The problem is that each family is the SAME identity mapping, so there is only ONE family.

### 8. Key Insight: The Bundled CanonicalMCS Approach

Here is the core mathematical insight that emerges from the analysis:

**Theorem (Informal)**: The bundle consisting of the single identity family `canonicalMCSBFMCS` over CanonicalMCS is NOT modally saturated, because `modal_backward` fails for a single family (documented Dead End).

**Observation**: We need a bundle where `modal_forward` and `modal_backward` hold. `modal_backward` requires: if phi is in ALL families' MCS at time w, then Box(phi) is in fam.mcs(w).

For the identity family, `fam.mcs(w) = w.world`. So `modal_backward` requires: if phi is in w.world for all "views" of w from different families, then Box(phi) is in w.world.

If ALL families are the identity family, then "phi in ALL families' MCS at w" just means "phi in w.world" (one family, one view). So `modal_backward` becomes: "phi in w.world implies Box(phi) in w.world", i.e., phi -> Box(phi). This is NOT valid in TM logic (Dead End: Single-Family BFMCS modal_backward).

**To get modal_backward**, we need families that "disagree" at some time points. If fam1.mcs(w) = M1 and fam2.mcs(w) = M2 where M1 != M2, then "phi in ALL families" at w means phi in M1 AND phi in M2. This is a stronger condition, making modal_backward (the converse) easier to satisfy.

### 9. Concrete Construction Proposal

#### Proposal: "All CanonicalMCS FMCS" Bundle

**Domain**: D = CanonicalMCS (with the existing Preorder)

**Families**: For each MCS W, define a family `fam_W`:
```
fam_W.mcs(v) = v.world    -- same as identity for all v
```

Wait -- this gives the SAME family for all W. The families do not depend on W.

**Alternative**: For each MCS W, define a "W-shifted" family where the MCS at some reference point is W:

But CanonicalMCS has no additive group structure, so "shifting" is not well-defined.

#### Proposal: Generalized Assignment Families

Let `Sigma` be the set of all functions `sigma : CanonicalMCS -> CanonicalMCS` that are:
1. **Order-preserving**: `v <= v'` implies `sigma(v) <= sigma(v')`
2. **GContent-compatible**: `GContent(sigma(v).world) subset sigma(v').world` whenever `v <= v'`

For each such sigma, define `fam_sigma.mcs(v) = sigma(v).world`.

This automatically satisfies forward_G and backward_H by the same argument as canonicalMCSBFMCS.

For forward_F: If `F(phi) in sigma(v).world`, then by `canonical_forward_F`, exists MCS W with `CanonicalR sigma(v).world W` and `phi in W`. We need `W = sigma(s).world` for some `s >= v`.

This is the "controlled Lindenbaum" problem: the witness MCS W must land in the image of sigma. This generally fails unless sigma is surjective (i.e., every MCS is in the image).

**If sigma is the identity**, then sigma is surjective, and the witness W IS some CanonicalMCS element s. We need `v <= s`, i.e., `CanonicalR v.world s.world`. We have `CanonicalR sigma(v).world W = CanonicalR v.world W`. And W = s.world. So `v <= s` holds. Forward_F works.

**If sigma is not the identity**, forward_F may fail because W may not be in the image of sigma.

This confirms that the identity family is special: it is the ONLY order-preserving assignment for which forward_F holds trivially.

### 10. Breaking Through: The "Bundle of All Coherent Families" Approach

**Definition**: A "coherent family assignment" is a function `f : CanonicalMCS -> Set Formula` such that:
1. `f(v)` is an MCS for all v
2. `v <= v'` implies `GContent(f(v)) subset f(v')`  (forward_G)
3. `v' <= v` implies `HContent(f(v)) subset f(v')`  (backward_H)
4. `F(phi) in f(v)` implies `exists s >= v, phi in f(s)` (forward_F)
5. `P(phi) in f(v)` implies `exists s <= v, phi in f(s)` (backward_P)

**The Bundle**: Let `B.families = { f | f is a coherent family assignment }`.

**Eval Family**: The identity assignment `f(v) = v.world` is a coherent family assignment (by all the sorry-free proofs in CanonicalFMCS.lean).

**Modal Saturation**: Does every diamond obligation have a witness?

If `Diamond(psi) in f(v)` for some coherent f and some v, we need another coherent family g with `psi in g(v)`.

**Constructing g**: We need g(v) to be an MCS containing psi, and g must satisfy all five coherence conditions.

Set `g(v) = W` where W is the Lindenbaum extension of `{psi}` (or more precisely, of `{psi} union GContent(M)` for some appropriate M). For other points u, set g(u) = u.world (identity).

But this g may not satisfy forward_G at v: if `G(chi) in g(v) = W`, then `chi` must be in `g(v') = v'.world` for all `v' >= v`. Since `g(v') = v'.world` for `v' != v`, this requires `chi in v'.world` whenever `v <= v'`. But `G(chi) in W` does NOT imply `G(chi) in v.world` (W may differ from v.world), so the forward_G condition at v for g is not guaranteed.

**The root cause**: Changing g(v) from v.world to some other MCS W breaks the coherence conditions that relied on the identity mapping structure.

### 11. The Depth-Stratified Approach (Unexplored)

Research-001 mentioned this as speculative with 40-60% success probability. Let me analyze it more carefully.

**Idea**: Reformulate the truth lemma to use well-founded induction on formula depth.

**Define**: `temporally_coherent_upto d B` = all families in B satisfy forward_F and backward_P for formulas of depth < d.

**Base case (d = 0)**: No temporal formulas at depth 0, so `temporally_coherent_upto 0` holds vacuously for any bundle, including one with constant witness families.

**Inductive step**: Assuming `temporally_coherent_upto d B`, show that the truth lemma holds for formulas of depth <= d, then use this to construct a bundle that is `temporally_coherent_upto (d+1)`.

**Problem**: The truth lemma for `Box(G(psi))` at depth d requires the truth lemma for `G(psi)` at depth d-1, which requires temporal coherence at depth d-1 for ALL families including witness families. But depth d-1 temporal coherence was only proven for the PREVIOUS bundle, and the d-step may have added new witness families.

This seems to require rebuilding the bundle at each depth level, potentially creating an infinite ascending chain of bundles. The limit of this chain would be the desired BFMCS, but proving its properties requires careful transfinite induction.

**Feasibility**: This approach has significant formalization complexity but is mathematically plausible. It would require:
1. A formula-depth measure
2. A sequence of bundles B_0, B_1, ..., B_n where n = max depth
3. Proof that each B_{d+1} extends B_d
4. Proof that the final B_n satisfies full temporal coherence and modal saturation

Estimated effort: 15-30 hours. Success probability: 50-65%.

### 12. The "Time-Varying Witness Family" Construction

Here is a potentially viable approach that combines insights from both the bottom-up and top-down perspectives:

**Key Insight**: In the CanonicalMCS domain, each MCS IS a time point. A family assigns an MCS to each time point. The identity family assigns each time point to itself. A witness family must assign a DIFFERENT MCS to at least one time point.

**For a diamond obligation Diamond(psi) at v**:
1. By `diamond_implies_psi_consistent`, `{psi}` is consistent
2. Extend `{psi} union GContent(v.world)` to MCS W (the diamond witness)
3. `CanonicalR v.world W` holds (W contains GContent(v.world))
4. `psi in W`

Now define the witness family `g`:
```
g(u) = u.world             -- for all u != v (and u not related to the W adjustment)
g(v) = W                   -- the witness MCS at the diamond point
```

But we need g to be a FMCS. Check forward_G:
- If u <= u' and `G(phi) in g(u)`, then `phi in g(u')`
- If u, u' are both != v: `g(u) = u.world`, `g(u') = u'.world`. Since u <= u' means CanonicalR u.world u'.world, and `G(phi) in u.world` means `phi in GContent(u.world)`, so `phi in u'.world = g(u')`. OK.
- If u = v, u' != v: `g(v) = W`, `g(u') = u'.world`. We need: `G(phi) in W` implies `phi in u'.world`. We have `v <= u'` means `CanonicalR v.world u'.world`. But `G(phi) in W` does NOT mean `G(phi) in v.world` (W may have G-formulas that v.world does not). So this fails.

**The Problem**: Changing g(v) from v.world to W changes which G-formulas are "active" at v, and the downstream propagation may not reach the same places.

**Fix Attempt**: Define g(u) = W for ALL u >= v (not just u = v). Then:
- For u >= v: g(u) is determined by "what should follow from W"
- Specifically, for u > v: define g(u) as a Lindenbaum extension of GContent(W) union (some seed)

This is essentially building a DovetailingChain rooted at W, which has the same forward_F problem.

### 13. The CanonicalMCS Multi-Root Approach

**Idea**: Instead of a single identity family, use MULTIPLE identity-like families, each "rooted" at a different MCS.

**Problem**: As analyzed above, the identity mapping `v -> v.world` is canonical and does not depend on any root. There is only one identity family over CanonicalMCS.

**Variation**: Use different Preorder structures on the same set of MCS. For each "root" MCS W, define a different accessibility relation and therefore a different FMCS.

This would require proving that the resulting FMCS still satisfies all coherence conditions under the new Preorder. The existing proofs are tied to the CanonicalR Preorder.

### 14. Literature Comparison

#### Standard Tense Logic Completeness (Goldblatt 1987)

In Goldblatt's treatment of tense logic over flows of time:
- **Worlds** = MCS of the tense logic
- **Accessibility**: w R w' iff {phi : G(phi) in w} subset w' (same as CanonicalR)
- **Truth Lemma**: Standard induction, Box case quantifies over ALL worlds

The standard approach does NOT use bundles/families. It defines a single Kripke frame where Box quantifies over ALL MCS (not bundled families). The TruthLemma for Box is:
```
Box(phi) in w  iff  forall w' with wRw', phi in w'
```

This works because the Box semantics in standard Kripke frames quantifies over ALL accessible worlds, and "accessible" is defined by CanonicalR.

**Why This Works for Standard Modal Logic But Not for TM**: In standard modal logic, the accessibility relation for Box is the SAME as for the temporal operators. In TM logic, Box represents a DIFFERENT modality (necessity across possible worlds/histories) than G/H (necessity across times). The BFMCS approach uses families to model temporal evolution and the bundle to model modal diversity.

#### Zanardo's Bundled Trees

Zanardo's work on branching-time temporal logic uses bundled trees where a bundle is a set of histories through a tree. A complete bundle contains ALL histories. The bundle restricts which histories the modal operators quantify over.

This is analogous to the BFMCS approach: the bundle restricts box quantification. In Zanardo's framework:
- Completeness for full trees (all histories) may fail
- Completeness for bundled trees requires the bundle to satisfy certain closure conditions
- A "complete axiomatization for bundled tree validity" exists (Zanardo 1985, Reynolds 2002/2003)

### 15. Proposed Resolution Path

Given the analysis, here is the most viable path:

#### Option A: CanonicalMCS + Saturation Extension (Recommended)

**Phase 1**: Start with the single identity family `canonicalMCSBFMCS` over CanonicalMCS. This gives temporal coherence for free (sorry-free).

**Phase 2**: Extend the bundle to achieve modal saturation using the `SaturatedConstruction` approach (which uses Zorn's lemma to find a maximally saturated extension).

**Phase 3**: Prove that the Zorn extension preserves temporal coherence. This is the hard part.

**Key Question**: Does the SaturatedConstruction (Zorn's lemma extension) add families that are temporally coherent?

The SaturatedConstruction (referenced in ModalSaturation.lean) extends a BFMCS by adding witness families for unwitnessed diamond formulas. If the witness families are built using CanonicalMCS-style constructions (fresh Lindenbaum witnesses at each time point), they inherit temporal coherence.

**Concrete Approach**:

For each unwitnessed diamond obligation Diamond(psi) at time w in family fam:
1. Construct a witness FMCS `fam_w_psi` over CanonicalMCS where:
   - `fam_w_psi.mcs(w) = W` where W is a Lindenbaum extension of `{psi} union BoxContent(w)` -- ensuring psi is present AND all Box-formulas propagate
   - `fam_w_psi.mcs(v) = v.world` for all v != w ... (BUT this breaks forward_G as analyzed)

The technical difficulty remains: we cannot "patch" the identity family at a single point without breaking coherence.

#### Option B: Fully Non-Identity Witness Families

For each diamond witness, build an entirely new CanonicalMCS-indexed family that:
- Assigns each time point a fresh MCS based on some "seed" that propagates from the witness
- Uses the dovetailing/recursive seed approach

This is essentially rebuilding the CanonicalFMCS construction for each witness, but with a different root. Since CanonicalFMCS has no root (it is the identity), this requires a fundamentally different family construction.

**Approach**: For each MCS W (the diamond witness), define:
```
fam_W.mcs(v) = v.world     for all v   (identity mapping)
```

This is the SAME family again. The issue is that CanonicalMCS FMCS is unique.

#### Option C: Change the Domain

Instead of CanonicalMCS, use a richer domain that encodes both the time point AND the "perspective" (which family we are in).

**Domain**: `CanonicalMCS x FamilyIndex`

Each family would use a different projection of this product domain. Time would be the CanonicalMCS component, and the family index would select which MCS to evaluate at.

This is essentially the "bundled" domain idea, and it connects to the standard Kripke semantics where worlds are pairs (history, time).

However, the FMCS infrastructure requires a single domain D with a Preorder. Putting families into the domain type changes the semantics fundamentally.

---

## ROAD_MAP.md Reflection

### Pitfalls Checked

| Dead End | Relevance | Impact on Recommendations |
|----------|-----------|--------------------------|
| Constant Witness Family Approach | **HIGH** | Must NOT use constant families for diamond witnesses. Any witness family must be time-varying. |
| Single-Family BFMCS modal_backward | **HIGH** | Must have multiple families. Single family cannot satisfy modal_backward without phi -> Box(phi). |
| MCS-Membership Semantics for Box | **HIGH** | Must use standard recursive bmcs_truth_at, NOT flat membership. |
| DovetailingChain forward_F/backward_P | **MEDIUM** | Int-indexed linear chains cannot satisfy F/P witnesses. CanonicalMCS domain avoids this. |
| CanonicalReachable/CanonicalQuotient | **MEDIUM** | Future-reachable subset is insufficient for backward_P. All-MCS approach is correct. |
| Single-History FDSM | **LOW** | Single history trivializes Box. Not relevant to multi-family BFMCS. |

### Strategy Alignment

| Strategy | Status | Relevance |
|----------|--------|-----------|
| Indexed MCS Family Approach | ACTIVE | Directly relevant. CanonicalMCS FMCS is the current best single-family construction. |
| Representation-First Architecture | CONCLUDED | BFMCS completeness is a corollary of representation. Construction must provide the representation. |
| Algebraic Verification Path | PAUSED | Could provide alternative proof route, but not for the BFMCS construction itself. |

---

## Obstacles and Open Questions

### Obstacle 1: Non-Identity Families over CanonicalMCS

The CanonicalMCS FMCS is essentially unique (identity mapping). There is no obvious way to define a DIFFERENT temporally coherent family over the same domain that assigns a different MCS at some time point.

**Root cause**: The Preorder on CanonicalMCS is defined by GContent inclusion. The coherence conditions (forward_G, backward_H) follow from this definition and the identity mapping. Changing the assignment at any point breaks the alignment between the Preorder and the assignment.

### Obstacle 2: Temporal Coherence of Witness Families

Any witness family for a diamond obligation must satisfy forward_F and backward_P. The only known temporally coherent family over CanonicalMCS is the identity family. Constructing additional temporally coherent families is the core open problem.

### Obstacle 3: The Interaction Between Time and Modal Diversity

In TM logic, time (G/H) and modality (Box/Diamond) are independent. But in the BFMCS construction, families encode BOTH temporal and modal structure. The tension arises because temporal coherence constrains how families can differ, while modal saturation requires them to differ.

### Open Question 1: Is There a Domain D Where Multiple Temporally Coherent Families Exist?

For D = Int: The DovetailingChain gives one temporally coherent family (with sorries for forward_F/backward_P). Additional families are constant (which fail temporal coherence) or require separate DovetailingChain constructions (with the same sorries).

For D = CanonicalMCS: One temporally coherent family (identity) exists sorry-free. Additional families are unknown.

**Conjecture**: For any domain D, the "natural" temporally coherent family is unique up to isomorphism. Multiple families require "moving" the domain or changing the Preorder.

### Open Question 2: Can the Bundle Be Defined Over a Product Domain?

Define D = T x W where T is the time type and W indexes the "perspective". Each family uses a fixed w in W and maps T to MCS. Different w values give different families.

This changes the domain structure and requires new coherence proofs.

### Open Question 3: Is Depth Stratification Viable?

The depth-stratified approach (Section 11) avoids the temporal coherence problem for witness families by only requiring coherence up to a bounded depth. This is the most promising unexplored avenue but requires significant formalization effort.

---

## Recommendations

### Primary: Depth-Stratified BFMCS Construction

The depth-stratified approach is the most promising path to a sorry-free BFMCS construction:

1. Define `bmcs_truth_lemma_depth d B fam t phi` by well-founded induction on formula depth
2. At each depth d, construct a bundle B_d with:
   - Temporal coherence for formulas of depth < d (vacuous at d = 0)
   - Modal saturation for formulas of depth < d
3. Use constant witness families at depth 0 (vacuously temporally coherent)
4. At each step, extend B_{d-1} with new witness families for depth-d diamond formulas
5. Prove the limit B_n (n = max formula depth) satisfies full temporal coherence and modal saturation

**Estimated effort**: 15-30 hours
**Success probability**: 50-65%
**Key risk**: The extension step may introduce new temporal obligations that cascade

### Secondary: CanonicalMCS with Novel Multi-Family Construction

Investigate whether the CanonicalMCS domain can support multiple temporally coherent families through:

1. Using a product domain `CanonicalMCS x Nat` where the Nat component indexes families
2. Each family uses its Nat index to select which "perspective" MCS to use at each time point
3. The Preorder on the product extends CanonicalR to both components

**Estimated effort**: 20-40 hours
**Success probability**: 35-50%
**Key risk**: The product domain Preorder may not yield the right coherence conditions

### Tertiary: Enriched Seed Construction

Build each witness family via an enriched seed construction that:
1. Starts with the diamond witness MCS W at the obligation point
2. Extends forward and backward using a modified DovetailingChain that interleaves F/P witness placement
3. Uses the CanonicalMCS canonical_forward_F/backward_P at each step to guarantee witness existence

This is essentially a "CanonicalMCS-informed DovetailingChain" that avoids the linear chain topology constraint by using the full CanonicalMCS structure at each step.

**Estimated effort**: 10-20 hours
**Success probability**: 40-55%
**Key risk**: The same F-formula non-persistence through GContent seeds that blocked the original DovetailingChain

### What NOT to Pursue

1. **Constant witness families**: Provably impossible (Dead End)
2. **Single-family bundles**: Cannot satisfy modal_backward (Dead End)
3. **MCS-membership semantics**: Banned (Dead End, Task 931)
4. **FMP bypass**: Explicitly rejected by user for this task
5. **CanonicalReachable/CanonicalQuotient**: Archived, insufficient for backward_P (Dead End)

---

## Decisions

1. The FMP bypass is NOT pursued per user directive
2. The construction should target CanonicalMCS as the domain (sorry-free temporal coherence for single family)
3. The key challenge is identified as constructing multiple temporally coherent families
4. Depth stratification is the recommended primary approach
5. The time domain D question is resolved: use CanonicalMCS (Preorder) for the BFMCS, with Representation.lean handling the embedding to standard semantics over LinearOrderedAddCommGroup

---

## Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Depth stratification encounters cascading obligations | Medium | High | Bound the cascade by formula complexity |
| No multi-family construction exists for CanonicalMCS | Medium | High | Fall back to enriched seed construction |
| Enriched seed construction has same problems as DovetailingChain | High | Medium | Use CanonicalMCS witnesses at each step |
| Construction exists but formalization is prohibitively complex | Medium | Medium | Prototype key steps before full formalization |

---

## Appendix

### A. Search Queries Used

- "canonical model construction temporal modal logic completeness Kripke bundles families Prior tense logic"
- "Goldblatt canonical model tense logic totally ordered group completeness proof temporal coherence"
- "Burgess completeness theorem basic tense logic canonical model construction indexed families MCS accessibility relation time flow"
- "Zanardo bundled tree temporal logic completeness history set accessibility relation canonical model"
- lean_leansearch: "maximal consistent set temporal logic Kripke frame completeness"

### B. Literature References

- Goldblatt, R. (1987/1992). *Logics of Time and Computation*. CSLI Publications.
- Zanardo, A. (1985). Complete axiomatization for bundled tree validity.
- Reynolds, M. (2002/2003). Axiomatization of temporal logic.
- Burgess, J. Basic tense logic completeness.
- Stanford Encyclopedia of Philosophy: [Temporal Logic](https://plato.stanford.edu/entries/logic-temporal/)
- Stanford Encyclopedia of Philosophy: [Modal Logic](https://plato.stanford.edu/entries/logic-modal/)
- Open Logic Project: [Completeness and Canonical Models](https://builds.openlogicproject.org/content/normal-modal-logic/completeness/completeness.pdf)

### C. Key Codebase Files Analyzed

| File | Lines | Key Content |
|------|-------|-------------|
| `Bundle/BFMCS.lean` | 269 | BFMCS structure: families, modal_forward, modal_backward |
| `Bundle/BFMCSTruth.lean` | 314 | bmcs_truth_at: recursive truth definition |
| `Bundle/FMCSDef.lean` | 219 | FMCS structure: mcs, forward_G, backward_H |
| `Bundle/TruthLemma.lean` | 488 | bmcs_truth_lemma: sorry-free for all 6 cases |
| `Bundle/CanonicalFrame.lean` | 233 | CanonicalR, canonical_forward_F/G, canonical_backward_P/H |
| `Bundle/CanonicalFMCS.lean` | 285 | canonicalMCSBFMCS: sorry-free single FMCS |
| `Bundle/TemporalCoherentConstruction.lean` | 658 | TemporalCoherentFamily, fully_saturated_bfmcs_exists_int (SORRY) |
| `Bundle/ModalSaturation.lean` | 544 | is_modally_saturated, saturated_modal_backward |
| `Bundle/Completeness.lean` | 476 | bmcs_representation, bmcs_weak/strong_completeness |
| `Semantics/Truth.lean` | 515 | Standard truth_at definition |
| `Semantics/Validity.lean` | 217 | Standard valid and semantic_consequence |
| `Metalogic/Representation.lean` | ~400+ | Bridge from BFMCS to standard semantics |

### D. Formalization Complexity Assessment

| Approach | New Definitions | New Theorems | Estimated LOC | Difficulty |
|----------|----------------|--------------|---------------|------------|
| Depth-stratified | 5-8 | 15-25 | 800-1500 | High |
| Product domain | 3-5 | 10-20 | 500-1000 | Medium-High |
| Enriched seed | 4-6 | 12-20 | 600-1200 | High |
