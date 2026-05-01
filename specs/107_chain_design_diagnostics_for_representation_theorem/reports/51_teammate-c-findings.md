# Teammate C (Critic) Findings: Task 107 Architecture Analysis

**Date**: 2026-05-01
**Role**: Critic — identifying gaps, blind spots, and failure patterns

## Key Findings

### 1. The "Dead Code" Claim Is Correct BUT Misses the Root Cause

The audit (report 50) correctly identifies that `lemma_2_6_splitting` and `lemma_2_7` have zero callers. But the *reason* they have zero callers is that the elimination functions were written without integrating them. This is not dead code in the normal sense — it is **unfinished integration**. Burgess's proof *requires* these lemmas:

- **Lemma 2.6** is needed by Lemma 2.9 (C4 elimination) for the base case n=0.
- **Lemma 2.7** is needed by Lemma 2.10 (C5 elimination) for the inductive case where conditions (i) and (ii) both fail.

The codebase's `eliminate_C4_counterexample` hits a `sorry` at exactly the point where Lemma 2.6 should be called. The codebase's `eliminate_C5_counterexample` *completely skips* the inductive case of Burgess's Lemma 2.10 — it only handles the base case (no existing points after x). The sorry at C4 line 412 IS the missing call to Lemma 2.6.

**Critical blind spot**: Archiving `lemma_2_6_splitting` to Boneyard would be actively harmful. It should be WIRED IN to `eliminate_C4_counterexample`, not archived.

### 2. The C5 Elimination Is Structurally Incomplete

Comparing Burgess's Lemma 2.10 with the codebase's `eliminate_C5_counterexample`:

**Burgess Lemma 2.10** (C5 elimination) has two cases:
- **Base case** (n=0, no points after x): Apply Lemma 2.4 to get endpoint C with ξ ∈ C and η ∈ B. g'(x,y) = B provides the guard.
- **Inductive case** (n=m+1, x' is successor of x): Three sub-cases:
  - (i) η ∧ U(ξ,η) ∈ f(x') AND η ∈ g(x,x'): reduce to case n=m (replace x by x')
  - (ii) ξ ∈ f(x') AND η ∈ g(x,x'): not a counterexample; contradiction
  - Otherwise: Apply Lemma 2.7 or 2.8 to split (x, x') and insert new point

**Codebase `eliminate_C5_counterexample`**: Only handles the base case. It places the witness y BEYOND all domain points (`exists_rat_gt_finset`), ignoring all existing points to the right of x. It does NOT check for the inductive case conditions.

**Why this matters**: The base case produces a witness y with η ∈ f(y), but does NOT guarantee η ∈ g(x, y). In Burgess's base case, g(x,y) = B (the maximized interval set from Lemma 2.4) explicitly contains η. In the codebase, the C5 witness has:
- `c5_forward_witness`: `∃ y ∈ val.dom, pc.x < y ∧ pc.η ∈ val.f y` (NO guard info)

This is exactly why `cantor_bfmcs_restricted_fuc` has sorry sites — the C5 construction never recorded the guard.

### 3. The g Function Is a Phantom

This is the deepest architectural problem. The omega_chain only carries `c0` (MCS at domain points). The g values from elimination steps are carried through EliminationResult's `g_agrees` field, but:

- `eliminate_C5_counterexample` returns `g' = χ.g` (unchanged): `(∀ a b, χ'.g a b = χ.g a b)`. The new point y gets NO g values assigned.
- `eliminate_C4_counterexample` returns `g' = χ.g` (unchanged): same issue. The inserted point z gets NO g values.

The `limit_g` at the limit is defined as `{φ | ∀ y ∈ dom, x < y → y < z → φ ∈ f(y)}`, which is the C3-forced definition. This is correct for the dense limit, but the finite-stage g values are ALL empty (or carried from the singleton, which had g = ∅). The g function at finite stages is **never assigned meaningful values**.

In Burgess's construction:
- Lemma 2.4 produces B with R(A, B, C) (g(x,y) = B for the new pair)
- Lemma 2.6 produces B', B'' with R(A, B', D), R(D, B'', C) and B = B' ∩ D ∩ B'' (C3)
- Lemma 2.7 similarly produces B', B'' with R(A, B', D), R(D, B'', C)

The codebase NEVER assigns these B values to the g function of the new chronicle. The g function at finite stages is structurally dead.

### 4. The c2' Removal Was Correct in Spirit But Wrong in Implementation

The comment says: "The c2' invariant is no longer threaded through finite stages (Phase 7 change); it is vacuously true at the limit since the limit domain is dense with no adjacent pairs."

This is true at the limit but ignores that Lemma 2.9 (C4 elimination) needs c2' (specifically R(f(x), g(x,y), f(y)) for adjacent pairs) at FINITE stages. The audit correctly identifies this but proposes reconstructing c2' at specific call sites using `burgessR3Maximal_from_g_content_sub`. This approach can't work because:

1. `burgessR3Maximal_from_g_content_sub` needs `g_content(A) ⊆ C` as input
2. At finite stages, the g function is empty (see finding #3)
3. The actual g values (from Lemma 2.4/2.6) that WOULD satisfy c2' were never stored

### 5. BX Axiom System vs Burgess's J₀

A fundamental tension pervades all 50 reports: the codebase uses BX axioms (adapted for strict/open-guard semantics) while Burgess uses J₀ = {A1a-A7a}. The relationships are:

| Burgess | BX | Status |
|---------|-----|--------|
| A1a (left mono U) | BX2 | Valid ✓ |
| A2a (right mono U) | BX3 | Valid ✓ |
| A3a (enrichment) | BX13 | **Needs verification** — the report says A3a is "not valid under strict semantics" but BX13 exists as a replacement |
| A4a (splitting) | BX14 | **Needs verification** — A4a called "not valid" under strict semantics, BX14 is a replacement |
| A5a (self-accum) | BX5 | Valid ✓ |
| A6a (absorption) | BX6 | Valid ✓ |
| A7a (linearity) | BX7 | **A7a was found unsound** under open-guard and removed; BX7 is the replacement |

The PointInsertion.lean header (lines 17-21) says A3a and A4a are "not valid under strict semantics" and replaced by BX axioms. But Burgess's proofs of Lemmas 2.6, 2.7 use A3a and A4a explicitly. The plan v35 (Phase 3) references a detailed adaptation of A3a/A4a calls using BX5/BX14/BX13. This adaptation is UNTESTED and unimplemented. Given that A7a was found unsound (a surprise after being assumed valid for months), A3a/A4a soundness under BX semantics deserves explicit verification.

### 6. Lemma 2.6's Current Form Does NOT Match Burgess

The current `lemma_2_6_splitting` in PointInsertion.lean:
- Takes `BurgessR3Maximal A B C` as input
- Uses a seed `{β.neg} ∪ g_content(A) ∪ h_content(C)` (NOT Burgess's D₀)
- Has a `sorry` in the inconsistent case of `g_content_sub_B`

Burgess's Lemma 2.6:
- Takes `R(A, B, C)` (R-maximality) as input
- Uses a seed D₀ = `{S(α,β) : α∈A, β∈B} ∪ B ∪ {¬δ} ∪ {U(γ,β) : γ∈C, β∈B}`
- Derives consistency from A5a + A4a + A3a + 2.2
- Produces R(A, B', D) and R(D, B'', C) with B = B' ∩ D ∩ B''

These are **completely different constructions**. The codebase's version uses g_content (a syntactic concept) where Burgess uses the r-relation (a semantic concept). This mismatch is the root cause of the g_content_sub_B sorry — Burgess's seed D₀ doesn't need g_content at all.

## Gaps and Blind Spots

### Nobody Has Checked:

1. **Whether BX13 (the A3a replacement) is actually sufficient for Burgess's Lemma 2.4 and 2.6**. The proofs explicitly use `A3a: p ∧ U(q,r) → U(q ∧ S(p,r), r)`. BX13 may or may not be equivalent in the needed contexts.

2. **Whether BX14 (the A4a replacement) is sufficient for Burgess's Lemma 2.6**. The proof uses `A4a: U(p,q) ∧ ¬U(p,r) → U(q ∧ ¬r, q)`. If BX14 doesn't provide this, the entire D₀ seed construction is blocked.

3. **Whether the `EliminationResult` structure can carry g-value information**. Currently it has `g_agrees` (g unchanged on old pairs) but no field for the NEW g values that must be assigned to pairs involving the inserted point.

4. **Whether the C5 inductive case (Burgess 2.10, n=m+1) needs Lemma 2.7 or can be avoided**. The current code completely ignores this case by placing witnesses beyond all domain points. This works for the WEAK C5 (endpoint exists) but fails for the FULL C5 (endpoint + guard).

5. **Whether `limit_g` as defined actually satisfies the Burgess r-relation for the limit chronicle**. The definition `limit_g(x,z) = {φ | ∀ y ∈ dom, x < y < z → φ ∈ f(y)}` satisfies C3, but it's not obvious that `r(limit_f(x), limit_g(x,y), limit_f(y))` holds for the Burgess r-relation. This would need proof.

6. **Whether sorries anywhere outside Chronicle/ contribute to `dd_countermodel_chronicle`**. The `#print axioms` check hasn't been run on the current code.

## Pattern Analysis: Why 50 Reports, 49 Plans?

### Root Cause: Implementation Without Integration

The fundamental pattern across all 50 reports is: build infrastructure (lemma_2_6, lemma_2_7, BurgessR3Maximal, etc.) then discover it doesn't connect to the call sites. This happens because:

1. **The elimination functions were written first** (eliminate_C4/C5_counterexample) with sorry stubs
2. **The point insertion lemmas were written second** (lemma_2_4/2_6/2_7) without wiring them in
3. **Each plan tries to close the sorry stubs** without first understanding what the elimination functions actually need
4. **The g function was never properly implemented** at finite stages, creating a phantom dependency

### The Churn Cycle

1. Report identifies a sorry
2. Plan proposes closing it via some infrastructure
3. Implementation builds the infrastructure but discovers it doesn't fit
4. New report identifies a different problem
5. Return to step 2 with a new approach

This cycle has repeated ~25 times. The exit condition is: **first understand the full call chain from `dd_countermodel_chronicle` down to each sorry, then build only what that chain requires**.

### Sorry Count Trajectory

The original task started with ~4 sorry sites. Over 50 reports:
- Some sorries were eliminated (dead code removal, DCS maximality fix)
- New infrastructure created new sorry sites (g_content_sub_B, h_content_sub_B, splitting_seed_consistent, lemma_2_7)
- Net: the sorry count has oscillated between 4-12, never reaching 0
- The 7 current sorries include 3 that are dead code and 4 that are on the critical path

## Recommendations

### The Correct Architecture (Matching Burgess Exactly)

1. **The g function must be properly maintained at finite stages.** Each elimination step must assign g values to new pairs, not just f values. This is Burgess's C1 (g maps to DCS) and C2' (R-maximality for adjacent pairs).

2. **`EliminationResult` must carry g-value assignments.** The structure needs a field like `g_new_pairs : ∀ (x y : Rat), x ∈ val.dom → y ∈ val.dom → x < y → SetDeductivelyClosed (val.g x y)`.

3. **`eliminate_C4_counterexample` must call `lemma_2_6_splitting`** (after rewriting it to use Burgess's D₀ seed). The current sorry at line 412 is exactly the missing call.

4. **`eliminate_C5_counterexample` must implement Burgess's inductive case** (Lemma 2.10, n=m+1). This requires Lemma 2.7. The current base-case-only approach produces weak witnesses without guard info.

5. **The full `ChronicleInvariant` (C0, C1, C2', C3) must be threaded through the omega_chain**, not just C0.

### Minimum Viable Path

If the full architecture is too expensive, there's a narrower path:

- Keep the current weak C5 (limit_satisfies_c5_weak)
- For FUC/FSC, use limit_g directly (it's defined by the C3 formula)
- Prove that `U(ξ,η) ∈ limit_f(x)` implies `η ∈ limit_g(x,y)` for the C5 witness y
- This requires showing that the C5 witness eventually has guard info propagated to all intermediate points in the limit domain

This narrower path works IF:
- The limit_g definition correctly captures the guard
- The C5 witness from `limit_satisfies_c5_weak` can be connected to `limit_g`

But the C4 hard case STILL needs Lemma 2.6 with proper g-values at finite stages. There's no shortcut for that.

## Confidence Level

**HIGH** on findings 1-4 (verified by reading the source code against Burgess's paper).
**MEDIUM** on finding 5 (axiom correspondence — needs explicit verification).
**HIGH** on the pattern analysis (50 reports is strong evidence).
