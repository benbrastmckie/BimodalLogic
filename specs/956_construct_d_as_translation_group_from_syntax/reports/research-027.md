# Research Report: Multi-MCS Histories, Point-Wise Truth, and BFMCS-to-TaskFrame Lifting

**Task**: 956 - Construct D as translation group from syntax
**Date**: 2026-03-09
**Session**: sess_1773116954_13125
**Run**: 027
**Effort**: High
**Dependencies**: research-026 (reflexive G/H consequence analysis), research-025 (product domain solution)
**Sources/Inputs**: Codebase (TemporalDomain.lean, TruthLemma.lean, BFMCSTruth.lean, Truth.lean, FMCSDef.lean, BFMCS.lean, CanonicalCompleteness.lean, RestrictedFragment.lean), research-026
**Artifacts**: This report
**Standards**: report-format.md, return-metadata-file.md

## Executive Summary

- **Multi-MCS histories** in the product domain `RestrictedQuotient x Q` would take the form `tau(t) = (m(t), t)` where `m : Q -> RestrictedQuotient` is a non-constant function assigning MCS classes to time points. Constructing such histories with all required properties (domain convexity, task relation coherence, shift-closure) is technically feasible but creates a non-trivial verification burden that does NOT actually solve the truth lemma problem, because the truth lemma needs a correspondence between MCS membership and semantic truth, not just richer histories.

- **Point-wise truth reformulation** is the key insight that unblocks Phase 6. The BFMCS truth lemma (`bmcs_truth_at`) already defines truth point-wise relative to MCS membership -- it does NOT use histories at all. The TaskFrame truth (`truth_at`) uses histories, but truth for G/H quantifies over ALL times in D, not just domain times. If we can show that for canonical product histories, `truth_at` reduces to `bmcs_truth_at`, the existing sorry-free BFMCS truth lemma can be directly reused.

- **The BFMCS truth lemma CAN be lifted** to the product domain. The critical observation is that `bmcs_truth_at` and `truth_at` have structurally identical definitions for all cases EXCEPT atoms and box. For atoms, the product valuation `canonical_product_valuation` is defined so that truth at `([M], q)` equals `atom p in M.world`, which matches `bmcs_truth_at`. For box, the BFMCS quantifies over families in the bundle while `truth_at` quantifies over histories in Omega -- these are different quantifications, but can be made equivalent by choosing Omega = the set of canonical product histories (one per quotient class).

- **Recommendation**: Bypass multi-MCS history construction entirely. Instead, prove a bridge theorem connecting `bmcs_truth_at` to `truth_at` via the canonical product model. This avoids the history construction problem and leverages the existing sorry-free BFMCS truth lemma.

## Context & Scope

### The Blocker

Phase 6 of implementation-007 requires proving a truth lemma for the product domain `TemporalDomain := RestrictedQuotient x Q`. Research-026 established that:
1. The blocker is a history construction problem, not a semantics problem
2. The backward direction for G requires witnesses at points with DIFFERENT MCS components
3. Reflexive G/H does not solve this

This research investigates three approaches to unblocking Phase 6.

## Findings

### Finding 1: Multi-MCS History Construction is Technically Possible but Unnecessary

**What multi-MCS histories would look like:**

A multi-MCS history `tau : Q -> TemporalDomain` would be:
```
tau(t) = (m(t), t)
```
where `m : Q -> RestrictedQuotient` is a function that can vary with time.

**Requirements:**
- `tau.domain = Set.univ` (or at least a convex interval) -- achievable
- `tau.respects_task`: for `s < t`, `canonical_task_rel (m(s), s) (t - s) (m(t), t)`, which requires `t - s = t - s` -- trivially true regardless of `m`
- `m` should be monotone (non-decreasing) in the quotient order for the history to traverse MCS classes "forward"

**Connection to BFMCS:**

To make multi-MCS histories useful for the truth lemma, each MCS class visited by the history must correspond to a family in the BFMCS. If `m(t) = [M_i]` at time `t`, then truth at `(m(t), t)` should depend on MCS `M_i`.

**Why this is unnecessary:**

The BFMCS truth lemma already handles multiple MCS families -- that is exactly what the bundle structure provides. The BFMCS approach quantifies box over FAMILIES in the bundle, and the truth lemma proves this corresponds to MCS membership. Multi-MCS histories would be trying to replicate what BFMCS already does, but through the more complex medium of TaskFrame histories.

### Finding 2: Point-Wise Truth Reformulation is Feasible and Powerful

**Comparison of truth definitions:**

The two truth definitions have structurally parallel forms:

| Case | `bmcs_truth_at B fam t phi` | `truth_at M Omega tau t phi` |
|------|---------------------------|------------------------------|
| atom p | `atom p in fam.mcs t` | `exists (ht : tau.domain t), M.valuation (tau.states t ht) p` |
| bot | `False` | `False` |
| imp | `phi -> psi` | `phi -> psi` |
| box | `forall fam' in B.families, truth at fam'` | `forall sigma in Omega, truth at sigma` |
| G phi | `forall s, t < s -> truth at s` | `forall s, t < s -> truth at s` |
| H phi | `forall s, s < t -> truth at s` | `forall s, s < t -> truth at s` |

**Key structural match:**
- Bot, imp, G, H are IDENTICAL in structure (both quantify the same way over times)
- Atom differs only in HOW truth is determined at a point
- Box differs in WHAT is quantified over (families vs histories)

**Atom alignment:**

For the canonical product model:
```lean
canonical_product_valuation (w : TemporalDomain) (p : String) :=
  Formula.atom p in (quotientRepresentative w.1).world
```

And for `CanonicalProductHistory m`:
- `tau.domain = fun _ => True` (all times are in domain)
- `tau.states t _ = (m, t)`

So `truth_at M Omega tau t (atom p)` = `M.valuation (m, t) p` = `atom p in (quotientRepresentative m).world`.

Meanwhile `bmcs_truth_at B fam t (atom p)` = `atom p in fam.mcs t`.

These match if `fam.mcs t` corresponds to `(quotientRepresentative m).world`. In the BFMCS construction, `fam.mcs t` IS the MCS at time t, and in the product model, `m` is the quotient class. So they align when `fam` is the constant family for MCS `m`.

**Box alignment:**

This is the critical case. `bmcs_truth_at` quantifies over families in the bundle. `truth_at` quantifies over histories in Omega.

If we set `Omega = CanonicalProductOmega` (one history per quotient class), then quantifying over `sigma in Omega` is the same as quantifying over quotient classes `m'`. This matches quantifying over FMCS families in the bundle, provided we have one FMCS per quotient class.

**Conclusion:** A point-wise truth lemma can be stated as:
```
For all [M] in RestrictedQuotient, for all q in Q, for all phi:
  phi in (representative [M]).world <-> truth_at CanonicalProductModel Omega (CanonicalProductHistory [M]) q phi
```

This avoids histories entirely on the left-hand side and reduces the right-hand side to a specific canonical history.

### Finding 3: The BFMCS Truth Lemma Can Be Directly Lifted

**The lifting strategy:**

1. **Construct a BFMCS over RestrictedQuotient x Q** (or equivalently, over Q with MCS from RestrictedQuotient):
   - Families: one FMCS per quotient class `[M]`
   - Each FMCS: `fam_[M].mcs q = (representative [M]).world` (constant in q)
   - Modal coherence: inherited from the quotient structure

2. **The existing `bmcs_truth_lemma` applies directly** to this BFMCS:
   ```
   phi in fam_[M].mcs q <-> bmcs_truth_at B fam_[M] q phi
   ```

3. **Prove a bridge theorem**: `bmcs_truth_at B fam_[M] q phi <-> truth_at CanonicalProductModel Omega (CanonicalProductHistory [M]) q phi`

The bridge theorem follows by induction on phi, with each case matching structurally (Finding 2).

**HOWEVER, there is a critical obstacle:**

The BFMCS truth lemma requires `B.temporally_coherent`, which means:
- `forward_F`: If `F(phi) in fam.mcs t`, there exists `s > t` with `phi in fam.mcs s`
- `backward_P`: If `P(phi) in fam.mcs t`, there exists `s < t` with `phi in fam.mcs s`

For CONSTANT families (where `fam.mcs t = M` for all t), `forward_F` requires: if `F(phi) in M`, then `phi in M`. But this is exactly the temporal saturation property that was proven FALSE for general MCS in research-010 (counterexample: `{F(psi), neg psi}` is consistent).

**This is the SAME blocker** that blocked `TemporalCoherentConstruction.lean` at line 396 (sorry in `temporal_coherent_family_exists_Int`) and `fully_saturated_bfmcs_exists_int` at line 490.

### Finding 4: The Real Solution -- Non-Constant FMCS over Q

The solution is to use the **BidirectionalFragment infrastructure** (from `CanonicalCompleteness.lean`) rather than constant families:

1. **`fragmentFMCS`** is an FMCS over `BidirectionalFragment M0 h_mcs0` with sorry-free forward_F and backward_P
2. **The fragment is totally ordered** (proven in `BidirectionalReachable.lean`)
3. **We need an order-embedding** from Q (or some dense linear order) into the fragment

The approach would be:
1. Build `fragmentFMCS` (already done, sorry-free)
2. Embed Q into the BidirectionalFragment via a monotone map
3. Pull back `fragmentFMCS` along this embedding to get `FMCS Q`
4. Build a BFMCS over Q from multiple such pulled-back families
5. Apply `bmcs_truth_lemma`

**The fragment-level FMCS resolves the temporal coherence problem** because it uses NON-CONSTANT families: `fragmentFMCS.mcs w = w.world`, so different fragment elements have different MCSes. When `F(phi) in w.world`, the fragment provides a witness `s > w` with `phi in s.world` (proven sorry-free).

### Finding 5: The Two-Layer Architecture

The cleanest approach has two layers:

**Layer 1: BFMCS over BidirectionalFragment (sorry-free)**
- `fragmentFMCS` with sorry-free forward_G, backward_H, forward_F, backward_P
- `bmcs_truth_lemma` applied to a BFMCS built from fragment families
- This gives: `phi in w.world <-> bmcs_truth_at B fam_w 0 phi` for fragment elements w

**Layer 2: TaskFrame over product domain**
- `CanonicalProductFrame` with `TemporalDomain = RestrictedQuotient x Q`
- `CanonicalProductModel` with valuation depending on MCS component
- `ShiftClosedProductOmega` as the history set

**Bridge**: Connect Layer 1 to Layer 2 by:
- Noting that `RestrictedQuotient` quotients `RestrictedFragment` which embeds into `BidirectionalFragment`
- Each quotient class `[M]` corresponds to a fragment family
- Truth at product domain point `([M], q)` via canonical history equals BFMCS truth at the fragment family for `[M]`

**Key advantage**: This avoids constructing multi-MCS histories, avoids temporal saturation of constant families, and reuses the sorry-free fragment infrastructure.

### Finding 6: Remaining Sorries in the Pipeline

Even with this approach, there are blockers:

1. **`instNoMaxOrderRestrictedQuotient`** (RestrictedFragment.lean line 460): sorry for G-closed MCS case. The product domain sidesteps this for the TaskFrame (Q provides NoMaxOrder), but the BFMCS construction over the fragment still needs the fragment to have all temporal witnesses.

2. **`instNoMinOrderRestrictedQuotient`** (RestrictedFragment.lean line 524): sorry for H-closed MCS case.

3. **`fully_saturated_bfmcs_exists_int`** (TemporalCoherentConstruction.lean line 490): sorry combining temporal + modal saturation.

The fragment-level FMCS (`fragmentFMCS`) is sorry-free for forward_F and backward_P. But building a full BFMCS with modal saturation on TOP of the fragment FMCS requires the same diamond-witness construction that `CanonicalCompleteness.lean` addresses.

The `CanonicalCompleteness.lean` infrastructure provides:
- `fragmentFMCS` (sorry-free temporal coherence)
- `box_witness_seed_consistent` (sorry-free diamond witness construction)
- But the combination into a full `BFMCS` with both temporal coherence AND modal saturation has not been completed

### Finding 7: Recommended Architecture for Phase 6

**Option A: Direct BFMCS-to-Product Bridge (Recommended)**

1. Use `fragmentFMCS` as the eval family
2. For each diamond witness obligation, construct witness families rooted at the diamond witness MCS (using `diamondWitnessMCS`)
3. Each witness family is a NEW fragmentFMCS rooted at the witness MCS
4. Build BFMCS from these families
5. Prove modal coherence: forward is by construction (BoxContent subset); backward by MCS maximality
6. Prove temporal coherence: each family is a fragmentFMCS, which has sorry-free F/P
7. Apply `bmcs_truth_lemma` to get truth correspondence at the BFMCS level
8. Bridge to TaskFrame truth via canonical product histories

**The critical insight**: We do NOT need to embed into Q first. The BFMCS truth lemma works over ANY preorder D with Zero. The BidirectionalFragment already IS such a preorder. We can state completeness using BFMCS truth directly, without going through TaskFrame truth at all.

**This means Phase 6 might be better reformulated as**: Prove completeness via BFMCS directly, then show that the BFMCS model can be realized as a TaskFrame model (optional, for the representation theorem).

**Option B: Direct Point-Wise Truth Lemma on Product Domain**

1. Define `product_truth_at` point-wise: truth at `([M], q)` depends only on `M`
2. Prove `product_truth_at` matches `bmcs_truth_at` for a suitable BFMCS
3. Prove `product_truth_at` matches `truth_at` for canonical product histories
4. Conclude: `phi in M <-> truth_at CanonicalProductModel Omega tau q phi` for `tau = CanonicalProductHistory [M]`

**The problem with Option B**: It still requires a BFMCS with temporal coherence, which requires the fragment infrastructure. So it adds complexity without eliminating the core dependency.

**Option C: Completeness Without TaskFrame (Most Direct)**

1. State completeness as: consistent phi implies exists BFMCS falsifying phi
2. Use `bmcs_truth_lemma` directly (already proven, modulo temporal coherence)
3. Build the satisfying BFMCS from the fragment infrastructure
4. TaskFrame representation becomes a separate optional theorem

This is the most direct path to completeness and avoids the product domain entirely for the truth lemma.

## Recommendation

**Primary recommendation: Option C -- prove completeness via BFMCS directly.**

The TaskFrame product domain construction (Phases 0-5) provides the frame-theoretic infrastructure (dense linear order, no endpoints, etc.) but is NOT needed for the truth lemma itself. The BFMCS truth lemma already handles all cases sorry-free. The remaining work is:

1. Complete the BFMCS construction: build a BFMCS from fragment families with both temporal coherence (from fragmentFMCS, sorry-free) and modal saturation (from diamond witness construction, sorry-free for individual steps)

2. The combination of temporal coherence + modal saturation in a single BFMCS is the ONLY remaining sorry in the pipeline (`fully_saturated_bfmcs_exists_int`)

3. This sorry can potentially be resolved by making each diamond witness family a fragmentFMCS rooted at the witness MCS (using `CanonicalCompleteness.lean` infrastructure)

**The product domain work is NOT wasted** -- it provides the TaskFrame realization for the representation theorem. But the truth lemma and completeness can proceed independently via BFMCS.

## Decisions

- **D1**: Multi-MCS histories are unnecessary -- the BFMCS approach already handles multiple MCS families without constructing explicit multi-MCS histories
- **D2**: Point-wise truth reformulation is the correct conceptual frame -- `bmcs_truth_at` is already point-wise
- **D3**: The BFMCS truth lemma can be lifted to TaskFrame truth, but this lifting is optional for completeness
- **D4**: The remaining blocker is `fully_saturated_bfmcs_exists_int` (combining temporal coherence with modal saturation in one BFMCS)

## Next Steps

1. Investigate whether `CanonicalCompleteness.lean`'s diamond witness infrastructure can produce temporally coherent witness families (each witness family as its own fragmentFMCS)
2. If yes: prove `fully_saturated_bfmcs_exists_int` without sorry
3. If no: identify the specific blocker in making witness families temporally coherent
4. Optionally: prove the BFMCS-to-TaskFrame bridge theorem for the representation result

## Confidence Assessment

| Finding | Confidence | Notes |
|---------|------------|-------|
| Multi-MCS histories unnecessary | High | BFMCS already provides multi-family quantification |
| Point-wise truth is correct frame | High | bmcs_truth_at is already point-wise |
| BFMCS truth lemma can be lifted | High | Structural comparison confirms alignment |
| Fragment FMCS has sorry-free temporal coherence | High | Verified in CanonicalCompleteness.lean |
| Completeness via BFMCS (Option C) most direct | High | Avoids unnecessary TaskFrame complexity |
| Remaining blocker is temporal+modal combination | High | Matches known sorry in codebase |
