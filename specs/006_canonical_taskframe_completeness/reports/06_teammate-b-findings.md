# Research Report: Task #1006 (Teammate B - Alternative Approaches)

**Task**: Canonical TaskFrame Completeness - Alternative Constructions for Convex WorldHistory
**Date**: 2026-03-20
**Focus**: SOLUTIONS — alternative approaches avoiding the non-convex domain problem in `shiftedFlagWorldHistory`

---

## Key Findings

The current v3 plan (`FlagBFMCSRatBundle.lean`) has reached Phase 4 with two sorry stubs:
1. `convex` proof in `shiftedFlagWorldHistory` (line 364) — the image of a discrete chain in Rat is NOT convex
2. `shifted_truth_lemma` (line 438) — truth lemma for the shifted WorldHistory

These are the blocking sorries. This report focuses on alternatives that avoid or dissolve them.

---

## The Exact Problem

`WorldHistory` requires:
```lean
convex : ∀ (x z : D), domain x → domain z → ∀ (y : D), x ≤ y → y ≤ z → domain y
```

The current construction sets `domain := fun q => q ∈ ShiftedFlagTimeDomain F center`, where
`ShiftedFlagTimeDomain F center = Set.range (shifted_flag_embed F center)`.

This is the image of a countable discrete chain under an order-embedding into ℚ. This image has
**gaps** between consecutive chain elements — rationals between `embed(m₁)` and `embed(m₂)` where
`m₁ < m₂` are adjacent in the chain are NOT in the domain. The convexity proof is therefore false.

The `sorry` at line 364 is mathematically unsound, not just unproven.

---

## Alternative Analysis

### Alternative 1: Use `Set.univ` as Domain (Full Rat Domain) — BEST APPROACH

**Idea**: Set `domain := fun _ => True` (all of ℚ), then extend the MCS assignment outside the
chain image by using a constant MCS (e.g., the center element's MCS).

**Construction**:
```lean
noncomputable def extendedFlagWorldHistory (F : Flag CanonicalMCS) (center : ChainFMCSDomain F) :
    WorldHistory (ParametricCanonicalTaskFrame ℚ) where
  domain := fun _ => True
  convex := fun _ _ _ _ _ _ _ => True.intro  -- trivially convex
  states := fun q _ =>
    if hq : q ∈ ShiftedFlagTimeDomain F center
    then shiftedWorldState F center q hq
    else shiftedWorldState F center 0 (zero_mem_shiftedFlagTimeDomain F center)
  respects_task := ...
```

**Convexity**: Trivially satisfied — full domain is always convex.

**Respects_task proof**: For s ≤ t in ℚ:
- If both s, t in image: follows from `shiftedFlagWorldHistory`'s respects_task (already proven at line 373)
- If s in image, t not in image: need `task_rel (state_at_s) (t - s) (center_state)`.
  Since `parametric_canonical_task_rel` at `d = t - s ≠ 0` requires `CanonicalR M_s M_center`
  or `CanonicalR M_center M_s`. This is NOT generally provable — the MCS at s is not
  necessarily R-related to center.

**Verdict**: The extension approach fails at `respects_task` unless the constant extension MCS
is an "absorbing" state for CanonicalR, which it generally is not.

**Mitigation**: Use a REFLEXIVE extension where `states q _ = center_state` for ALL q outside image.
Then `respects_task` for (s ∉ image, t ∉ image) requires `parametric_canonical_task_rel center_state d center_state`:
- `d = 0`: need `M = M` (trivial)
- `d > 0`: need `CanonicalR center_state.val center_state.val` — but `canonicalR_irreflexive` says CanonicalR is irreflexive!
- `d < 0`: same issue

**Conclusion**: Full Rat domain with constant extension CANNOT satisfy `respects_task` due to
CanonicalR irreflexivity.

---

### Alternative 2: Use Flag Elements as Domain Directly — CORRECT APPROACH

**Idea**: Instead of embedding into Rat and getting a non-convex image, work with
`ChainFMCSDomain F` as the time domain directly, without going through Rat.

The parametric machinery requires `D : AddCommGroup`. `ChainFMCSDomain F` has no group structure.

**Resolution**: Use a different completeness pathway that doesn't require AddCommGroup on D.

Looking at `WorldHistory.lean` line 69:
```lean
structure WorldHistory {D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    (F : TaskFrame D) where
```

D must be an ordered abelian group. There is no way around this requirement in the current
`WorldHistory` definition.

**Verdict**: Cannot use `ChainFMCSDomain F` as D directly without adding artificial group structure.

---

### Alternative 3: Add Endpoints to Make Chain Dense — WRONG DIRECTION

**Idea**: Between any two adjacent chain elements m₁ < m₂, the interval (embed m₁, embed m₂)
is non-empty in ℚ. What if we assign MCS values to these intermediate rationals by interpolation?

For `q ∈ (embed m₁, embed m₂)`, define `state(q) = state(m₁)` (left-constant extension) or
`state(q) = state(m₂)` (right-constant extension).

**Convexity**: Trivially satisfied if we extend to all ℚ between the chain's inf and sup.

**Respects_task for intermediate q**: For `s ≤ t` both in (embed m₁, embed m₂):
- Both get `state(m₁)`
- Need `parametric_canonical_task_rel m₁_state (t - s) m₁_state`
- `t - s ≥ 0` but `t ≠ s` generically, so `t - s > 0`
- This requires `CanonicalR m₁_state m₁_state` (CanonicalR is irreflexive!) — FAILS

**Verdict**: Constant extension between chain elements breaks `respects_task`.

---

### Alternative 4: Use the FlagTimeDomain Subtype as D — RECOMMENDED

**The key insight**: The problem isn't "how to embed into Rat" but "what should D be?"

`FlagTimeDomain F = Set.range (flag_embed F)` is already defined in `FlagBFMCSRatBundle.lean`
(line 114). It IS a subtype of ℚ with the inherited order.

The current `flagTimeDomain_FMCS` (line 191) builds an FMCS over this type. The issue is that
`FlagTimeDomain F` is not an `AddCommGroup` — it's a subtype of ℚ, not closed under subtraction.

**But**: `FlagBFMCSRatBundle.lean` already constructs `shiftedFlagWorldHistory` with
`domain := fun q => q ∈ ShiftedFlagTimeDomain F center`. The convexity fails because the
domain is a SUBSET of ℚ, not all of ℚ, and the FMCS states must be defined on all of ℚ.

**The real fix**: Instead of using `WorldHistory` (which requires AddCommGroup D and a full domain),
use `parametric_to_history` with an FMCS on ALL of ℚ.

`parametric_to_history` sets `domain := fun _ => True`, so convexity is trivial. The key is that
`parametric_to_history` takes an `FMCS D`, and the FMCS must assign an MCS to EVERY element of D,
with `forward_G : t < t' → G(φ) ∈ mcs(t) → φ ∈ mcs(t')` for ALL t, t' in D.

**Problem**: We have an FMCS on `FlagTimeDomain F` (a strict subset of ℚ), not on all of ℚ.
Extending to all ℚ while preserving `forward_G` requires: for t < t' in ℚ,
`G(φ) ∈ mcs_extended(t) → φ ∈ mcs_extended(t')`.

If we use the chain-order FMCSTransfer approach (transferring from CanonicalMCS to ℚ via the
order embedding), the transferred FMCS assigns MCS to ALL of ℚ via retraction. This IS done in
`FMCSTransfer.lean` — `transferredFMCS` is defined over ALL of D.

**The gap**: `FMCSTransfer` requires `embed_retract_eq : embed (retract d) = d` for ALL d : D.
This means the embedding must be SURJECTIVE, which a countable chain embedding into ℚ is NOT.

---

### Alternative 5: ChainFMCS with CanonicalMCS as Domain (No Embedding)

**Idea**: Use `CanonicalMCS` directly as D by equipping it with an artificial group structure.

`CanonicalMCS` is a preorder. If we could make it an `AddCommGroup`, we could define
an FMCS on it directly (the `canonicalMCSBFMCS` from `CanonicalFMCS.lean` already does this).

**Problem**: `CanonicalMCS` has no natural group operation. Addition is not defined.

**Non-canonical path**: Use the order-isomorphism `CanonicalMCS ≅ Int` (since CanonicalMCS is
countable and totally ordered on each Flag) to pull back Int's group structure.

- This requires EACH FLAG to be infinite (which may not hold in general).
- The isomorphism is per-Flag, not global.

**Verdict**: Mathematically unsound for arbitrary canonical models.

---

### Alternative 6: The Orthogonal Approach — Bypass WorldHistory Convexity Entirely

**Key architectural observation**: The proof obligation is:

```
MCS membership ↔ truth_at (ParametricCanonicalTaskModel ℚ) Omega τ t φ
```

The `truth_at` function for `all_future` (G) at `(τ, t)` quantifies over times `t' > t`
WITH `t' ∈ τ.domain`. Since `τ.domain = ShiftedFlagTimeDomain F center` (the chain image),
this quantification is RESTRICTED to chain image points — not all of ℚ.

Similarly for `all_past` (H).

For the BOX operator, `truth_at` quantifies over ALL histories in Omega, evaluated at time t.

The `truth_at` semantics at (τ, t) requires t ∈ τ.domain. The completeness proof uses t = 0,
which is in the domain (proven at `shiftedFlagWorldHistory_domain_zero`).

**The issue with the truth lemma** (`shifted_truth_lemma`) is the G-backward case:
```
¬G(φ) ∈ mcs(0) → ¬∀ t' > 0, t' ∈ domain → φ ∈ mcs(t')
```
This requires finding t' in the domain where φ fails. The canonical proof uses `canonical_forward_F`
to get a CanonicalMCS witness W with `CanonicalR chain_retract W`, then shows `embed W > 0`.
But W may not be in the same Flag F — hence not in `ShiftedFlagTimeDomain F center`.

**This is the real blocker**: The truth lemma's G-backward case requires witnesses that are
in the same Flag's shifted image. A witness from a different Flag is in a different family's
domain, not τ.domain.

---

## Feasibility Assessment

| Alternative | Convexity Fix | Respects_task | Truth Lemma | Overall |
|-------------|--------------|---------------|-------------|---------|
| 1: Full Rat domain + constant extension | Trivial | Fails (CanonicalR irreflexive) | N/A | BLOCKED |
| 2: ChainFMCSDomain as D directly | N/A | N/A | Bypasses issue | Requires new infrastructure |
| 3: Interpolate between chain points | Trivial | Fails (CanonicalR irreflexive) | N/A | BLOCKED |
| 4: FMCSTransfer with surjective image | N/A | Via FMCSTransfer | Same sorry | Partial |
| 5: CanonicalMCS as D with artificial group | N/A | N/A | Requires new framework | Complex |
| 6: Restrict truth lemma to chain domain | N/A | Already proven | Requires proof | PROMISING |

---

## Recommended Approach

### Primary: Use `parametric_to_history` with the FMCSTransfer-based FMCS

The infrastructure in `FMCSTransfer.lean` provides `transferredFMCS T : FMCS D` for any D given
an `FMCSTransfer D`. The `FMCSTransfer` requires `embed_retract_eq : embed (retract d) = d`.

The currently implemented `flag_embed_retract_eq` (line 146) proves exactly this for the image
subtype `FlagTimeDomain F`. But the completion requires converting to the FULL FMCS on ℚ.

**The correct fix**: Don't use `WorldHistory` with a non-trivial domain. Instead:

1. Keep the existing `shiftedFlagWorldHistory` structure but change the convexity proof.
2. **Accept a sorry for now** on `convex` (the existing approach) since the truth lemma is
   separately sorry'd anyway — removing `convex` sorry doesn't unblock the theorem.
3. Focus on the `shifted_truth_lemma` sorry, which is the logically harder problem.

**For the `shifted_truth_lemma` sorry**: The proof structure should be:
- Atom/bot/imp cases: Direct from MCS properties (routine)
- All_future (G) case: `G(φ) ∈ mcs(t) ↔ ∀ t' > t, t' ∈ domain → φ ∈ mcs(t')`
  - Forward: Use `flagTimeDomain_forward_G` (already proven)
  - Backward: Use `chainFMCS_forward_F_in_CanonicalMCS` to get canonical witness,
    then use `temporally_complete`/`allFlagsBFMCS` to find the witness's Flag

The G-backward case requires that witnesses are in `ShiftedFlagTimeDomain F center`. This is only
guaranteed if we use `allFlagsBFMCS` (all Flags) and extend the domain to include witnesses from
ALL flags. This is the cross-Flag coherence problem.

### Simplest Correct Path: Direct WorldHistory with Extended Domain

Build a WorldHistory over ℚ with `domain = Set.univ` (all of ℚ) where:
- States in the chain image get the actual chain MCS
- States outside the chain image get the nearest chain element's MCS

The `respects_task` proof fails due to CanonicalR irreflexivity ONLY for `d > 0` cases where
source = target = same constant MCS. This can be avoided by choosing the extension carefully.

**Revised extension**: For `q ∉ ShiftedFlagTimeDomain F center`:
- If `q < 0`: assign the MCS of the MINIMUM element of the chain (or a "past infinity" MCS)
- If `q > 0`: assign the MCS of the MAXIMUM element of the chain (or a "future infinity" MCS)

Since Flags are infinite in both directions (by TF/MF axioms guaranteeing witnesses),
the minimum/maximum elements don't exist. But we can use the infimum/supremum in the order.

**This fails**: A Dedekind-complete extension of a discrete chain into ℚ has the same
irreflexivity problem for adjacent extension points.

### Alternative: A Direct Bridge Without WorldHistory Convexity

The most practical path (avoiding the convexity issue entirely) is:

**Observation**: The completeness proof (`completeness_via_flagbfmcs`) in `FlagBFMCSRatBundle.lean`
(lines 483-508) is already FULLY WRITTEN. It only needs two things:
1. `shiftedFlagWorldHistory.convex` to be non-sorry
2. `shifted_truth_lemma` to be non-sorry

For (1), the quickest fix is to CHANGE THE DEFINITION of `shiftedFlagWorldHistory` to use
`domain := fun _ => True` and then fix `respects_task`. The `respects_task` outside the image
is the hard part.

**The actual simplest fix** (no sorry, mathematically sound):

Use `parametric_to_history` with a full FMCS on ℚ. This requires building
`fullFlagFMCS_Rat : FMCS ℚ` where:

```lean
noncomputable def fullFlagFMCS_Rat (F : Flag CanonicalMCS) (center : ChainFMCSDomain F) :
    FMCS ℚ where
  mcs := fun q =>
    if hq : q ∈ ShiftedFlagTimeDomain F center
    then shiftedMCS F center q hq
    else center.val.world  -- constant MCS for out-of-image points
  is_mcs := ...
  forward_G := fun t t' φ h_lt h_G => by
    by_cases ht : t ∈ ShiftedFlagTimeDomain F center
    by_cases ht' : t' ∈ ShiftedFlagTimeDomain F center
    · -- Both in image: use shifted chain coherence
    · -- t in image, t' not: need φ ∈ center.val.world
      -- G(φ) ∈ shiftedMCS t means G(φ) ∈ chainFMCS_mcs F (retract t)
      -- retract t < retract t' (by shifted_flag_retract_lt if t < t')
      -- But t' ∉ image, so we can't retract it!
      -- BLOCKED: t' ∉ image means there's no corresponding chain element above retract(t)
      sorry
    · ...
```

The `forward_G` case where `t ∈ image` and `t' ∉ image` is still blocked.

---

## The Fundamental Insight

**The convexity requirement for WorldHistory is precisely what prevents a simple embedding from
working.** The problem is not a proof engineering issue but a mathematical one:

The image of a discrete countable chain in ℚ is NOT convex. Period. There is no way to make it
convex without extending the domain to fill the gaps. But filling the gaps requires defining MCS
values at intermediate points, and the only valid MCS at an intermediate point requires
CanonicalR between adjacent chain elements and the intermediate point's MCS — which cannot be
defined without creating new MCSes.

**The correct solution** is not to use a discrete chain embedded in ℚ as the WorldHistory domain.
Instead:

### Final Recommendation: Use FMCS on ALL of ℚ via FMCSTransfer

The `FMCSTransfer` approach (plan v3 Phase 2) is the correct mathematical path. It requires:
- `embed : CanonicalMCS →o D` (monotone, not necessarily surjective)
- `retract : D → CanonicalMCS` (total function)
- `embed_retract_eq : embed (retract d) = d` for ALL d : D

This last condition (`embed_retract_eq`) forces the image of `embed` to be ALL of D, i.e.,
`embed` is surjective. This is the key constraint.

**For D = ℚ**: CanonicalMCS is countable; ℚ is countable. We need a bijection
`CanonicalMCS ↔ ℚ` that is ORDER-PRESERVING in both directions. This is possible IF
CanonicalMCS is a countable dense linear order without endpoints (i.e., order-isomorphic to ℚ).

CanonicalMCS with the Preorder from CanonicalR is:
- Countable: Yes
- Linearly ordered? No — it's only a partial order. Different MCSes may be incomparable.
- Dense? Unknown without further analysis.

For a SINGLE FLAG F, `ChainFMCSDomain F` IS a countable linear order. Whether it is dense
and without endpoints determines whether it is order-isomorphic to ℚ (or to ℤ).

If the flag chain is order-isomorphic to ℤ (discrete), then `FMCSTransfer ℤ` works directly
with `embed : ChainFMCSDomain F ↪o ℤ` (surjective by choosing a flag with infinitely many
elements in both directions). If the chain is order-isomorphic to ℚ (dense), then
`FMCSTransfer ℚ` works.

**Key question**: Is a Flag always infinite in both directions with no endpoints?

Looking at `FlagBFMCSTruthLemma.lean` and the temporal axioms: the TF axiom `G(φ) → F(φ)` and
MF axiom `Box(φ) → G(Box(φ))` guarantee temporal witnesses exist. For a SATURATED Flag (one
built by the dovetailed construction), both forward and backward witnesses are in the Flag,
ensuring the Flag is infinite in both directions.

The `allFlagsBFMCS` construction (using ALL Flags) guarantees witnesses exist in SOME Flag,
not necessarily the same Flag. This is the cross-Flag issue.

### Concrete Recommended Path (Resolving Current Sorries)

**For the `convex` sorry**: Change the WorldHistory to use a full FMCS (via `parametric_to_history`)
rather than a restricted-domain WorldHistory. The FMCS should be the `transferredFMCS` from
`FMCSTransfer.lean`, but this requires a surjective embedding.

**For the `shifted_truth_lemma` sorry**: This is the mathematically deep sorry. The proof requires
the G-backward case: F(φ) ∈ mcs(t) → witness exists in the same timeline. This is only provable
for DOVETAILED chains where the Flag itself contains F/P witnesses. Such chains exist by
task 1004's `DovetailedBuild` construction.

**Shortest path to sorry-free completeness**:

1. Use `DovetailedBuild` to construct a Flag F₀ that contains ALL F/P witnesses for M₀.
2. Build `ChainFMCSDomain F₀` as the time domain.
3. Use the order-preserving bijection `ChainFMCSDomain F₀ ≅ ℤ` (since it's a countable
   linear order — dovetailed construction ensures it's infinite in both directions).
4. Pull back ℤ's group structure to `ChainFMCSDomain F₀` via this bijection.
5. Build FMCS on ℤ where `mcs(n) = chainFMCS_mcs F₀ (iso⁻¹ n)`.
6. Prove `forward_G`, `backward_H`, `forward_F`, `backward_P` using the Flag's dovetailed structure.
7. Apply `parametric_to_history` to get a WorldHistory with full domain.
8. Apply `parametric_shifted_truth_lemma`.

This avoids ALL the convexity issues (full domain, hence trivially convex) and resolves the
truth lemma (witnesses are in the same dovetailed Flag by construction).

**Effort**: This requires importing/using `DovetailedBuild` results, which exist in
`StagedConstruction/DovetailedBuild.lean`. The connection between `DovetailedBuild` and
`Flag` (maximal chain) needs to be established.

---

## Confidence Level: High

The analysis is grounded in the actual Lean 4 code. The convexity sorry is provably unsound
(the discrete chain image is not convex in ℚ). The recommended path (dovetailed Flag + ℤ
isomorphism) is mathematically correct.

The main uncertainty is the effort required to:
1. Connect `DovetailedBuild` outputs to the `Flag` structure
2. Prove the ℤ-isomorphism of the dovetailed chain
3. Pull back the group structure via the isomorphism

These are non-trivial but tractable Lean 4 engineering tasks.

---

## References

- `FlagBFMCSRatBundle.lean`: Current implementation with 2 sorries (convex + truth_lemma)
- `FMCSTransfer.lean`: Transfer infrastructure (requires surjective embedding)
- `WorldHistory.lean`: Full domain required (AddCommGroup + convexity)
- `ParametricHistory.lean`: `parametric_to_history` — full domain, no convexity issue
- `StagedConstruction/DovetailedBuild.lean`: Dovetailed chain construction with F/P witnesses
- `ChainFMCS.lean`: Chain FMCS and `chainFMCS_pairwise_comparable`
- Plan v3 (`03_fmcstransfer-rat-plan.md`): Current implementation plan
