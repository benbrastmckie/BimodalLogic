# Teammate A Findings: Primary Approach for Closing Until/Since Sorries

- **Task**: 102 - implement_quotient_filtration_close_sorries
- **Artifact**: reports/02_teammate-a-findings.md
- **Date**: 2026-04-11
- **Focus**: Modifying Frame.lean sorry signatures to use a weaker, provable guard condition

## Key Findings

### Finding 1: The sorry signatures in Frame.lean and Realization.lean are structurally identical

Frame.lean defines 4 sorry functions (lines 607-647):
- `bx_until_eventuality_resolution` -- forward Until
- `bx_until_backward` -- backward Until
- `bx_since_eventuality_resolution` -- forward Since
- `bx_since_backward` -- backward Since

Realization.lean (Quasimodel namespace) defines 6 sorry functions that attempt to prove the same obligations but also end in sorry. LocusControl.lean wraps the Realization versions as `bx_until_eventuality_resolution'` etc., simply delegating.

The call chain is: TruthLemma.lean -> Frame.lean (the `bx_` prefixed versions). Realization.lean's versions are NOT currently wired into TruthLemma -- they were an attempt at an alternative proof path that hit the same blocker.

### Finding 2: The guard condition `not bx_le v u` is the root problem, confirmed by detailed code analysis

The sorry signatures all use this pattern for the guard:
```lean
-- eventuality_resolution (produces the guard):
∀ u : BXPoint, bx_le w u → bx_le u v ∧ ¬bx_le v u → φ ∈ u.formulas

-- backward (consumes the guard):
(h_guard : ∀ u : BXPoint, bx_le w u → bx_le u v ∧ ¬bx_le v u → φ ∈ u.formulas)
```

The condition `bx_le u v ∧ ¬bx_le v u` is `bx_lt u v` (defined in TruthLemma.lean line 212). The problem: `bx_le` is g_content inclusion, and `¬bx_le v u` means "there exists some G-formula in v whose content is NOT in u" -- this is VERY strong, requiring that u differs from v on the ENTIRE g_content, not just on Sigma-relevant formulas.

### Finding 3: The TruthLemma callers use the guard through `bx_lt`, which equals the Frame.lean guard

In TruthLemma.lean, `until_iff_mcs` (line 281) states:
```lean
∃ v : BXPoint, bx_le w v ∧ ψ ∈ v.formulas ∧
  ∀ u : BXPoint, bx_le w u → bx_lt u v → φ ∈ u.formulas
```

The forward direction (line 294-296) calls `bx_until_eventuality_resolution` and directly passes the guard through. The backward direction (line 305-307) calls `bx_until_backward` and passes the guard through. No transformation of the guard happens -- it is consumed and produced verbatim.

This means: **modifying the guard in Frame.lean requires also modifying the `until_iff_mcs` / `since_iff_mcs` statement in TruthLemma.lean**, since both sides of the biconditional use the same guard.

### Finding 4: `until_iff_mcs` / `since_iff_mcs` are NOT consumed by anything downstream in the Lean source

Searching the `Theories/` directory: these theorems are only defined (TruthLemma.lean:281 and 315) and referenced in comments. They are NOT used by Completeness.lean -- that file has its own sorry that blocks before needing them. This means modifying their statement is safe with zero downstream cascade.

### Finding 5: `sigma_strict` is the correct replacement for `bx_lt`

`SigmaOrdering.lean` already defines:
```lean
def sigma_strict (Sigma : Finset Formula) (w v : BXPoint) : Prop :=
  sigma_le Sigma w v ∧
  ∃ f : Formula, Formula.all_future f ∈ Sigma ∧
    Formula.all_future f ∈ v.formulas ∧ f ∉ w.formulas
```

Key proven properties:
- `not_bx_le_of_sigma_strict`: sigma_strict u v implies not (bx_le v u) -- so sigma_strict is WEAKER than bx_lt
- `sigma_strict_irrefl`: no point is sigma_strict above itself
- `not_sigma_le_of_sigma_strict`: blocks reverse sigma_le
- `sigma_strict_of_bx_le_and_witness`: constructible from bx_le + distinguishing witness

Since `sigma_strict` implies `not (bx_le v u)`, it is strictly weaker than `bx_lt`. The forward direction PRODUCES a weaker property (easier to prove), and the backward direction CONSUMES a weaker hypothesis (harder to use, but the key benefit is that sigma_strict is Sigma-determined -- the guard formula phi itself is in Sigma, so its membership is determined by the sigma_strict witness).

### Finding 6: The Realization.lean sorries diagnose the exact gap

Looking at `until_eventuality_resolution` in Realization.lean (lines 471-504), the proof:
1. Gets a raw witness v with bx_le w v and psi in v
2. For the guard at u: derives P(phi U psi) in u, gets backward witness u' with phi U psi in u'
3. BX9 gives phi in u' OR psi in u'
4. **GAP**: phi in u' does NOT lift to phi in u because bx_le u' u only propagates G-content

For `until_backward` (lines 518-564):
1. Constructs u via enriched seed {neg(phi U psi)} union g_content(w) union h_content(v)
2. Gets bx_le w u AND bx_le u v AND neg(phi U psi) in u
3. **GAP**: Cannot show not(bx_le v u) to apply the guard, AND even if we could, phi in u combined with neg(phi U psi) in u is consistent (phi can hold without phi U psi)

### Finding 7: The backward direction needs a fundamentally different proof strategy

The backward direction's gap (both in Frame.lean and Realization.lean) is NOT just about weakening the guard. Even with sigma_strict, the enriched seed gives u with:
- bx_le w u, bx_le u v, neg(phi U psi) in u
- But we cannot show sigma_strict u v (no distinguishing witness is guaranteed)

The backward direction needs to work by contradiction using F(psi) in u (derivable from bx_le u v and psi in v via connect_past + bx_H_forward). With F(psi) in u and neg(phi U psi) in u, we need a BX axiom that derives a contradiction. The relevant axiom is BX12 (F(psi) -> top U psi) combined with BX7 (linearity). The BX7 approach from the plan v5 (specs/098) is the correct path here.

### Finding 8: The forward direction CAN be solved by the defect-chain approach if the guard uses sigma_strict

For eventuality_resolution, if the guard only needs to produce `sigma_strict Sigma u v -> phi in u`, then:
- We know phi U psi in w, psi not in w
- BX9: phi in w
- BX5: (phi and (phi U psi)) U psi in w -- self-accumulation
- BX10: F(psi) in w
- Construct v via forward_witness with psi in v and bx_le w v
- For the guard at u with sigma_strict u v: sigma_strict gives a G-formula distinguishing u from v. If phi U psi is in Sigma, and psi is not in u (which can be derived from sigma_strict in certain cases), then BX9 gives phi in u.

But this requires phi U psi in u, which needs `bx_le w u` to propagate. Since bx_le w u is given and phi U psi in w, we need G(phi U psi) in w... which is NOT guaranteed. BX4 gives G(P(phi U psi)) in w, which via bx_le w u gives P(phi U psi) in u, then backward_witness gives phi U psi at some u' with bx_le u' u. Same gap.

The defect chain approach from the plan attempts to avoid this by constructing the witness v through a chain of one-step extensions, each reducing the defect count. This could work if the guard at each step only needs phi at the CURRENT point (which BX9 guarantees) rather than at an arbitrary intermediate point.

## Recommended Approach

### Option A: Restructure the biconditional to use chain-local guards (HIGHEST CONFIDENCE)

Instead of modifying the guard predicate, restructure `until_iff_mcs` to use a different characterization of Until truth:

**Current statement**:
```lean
φ U ψ ∈ w ↔ ∃ v, bx_le w v ∧ ψ ∈ v ∧ ∀ u, bx_le w u → bx_lt u v → φ ∈ u
```

**Proposed statement (weaker but equivalent for MCS)**:
```lean
φ U ψ ∈ w ↔ ∃ v, bx_le w v ∧ ψ ∈ v ∧
  ∀ u, bx_le w u → bx_le u v → ψ ∉ u → φ ∈ u
```

The guard `ψ ∉ u` replaces `bx_lt u v`. This is provable because:
- **Forward**: Given u with bx_le w u, bx_le u v, psi not in u: by BX4 G(P(phi U psi)) in w, so P(phi U psi) in u. Backward witness gives u' with phi U psi in u'. Since psi not in u, and phi U psi in u' with bx_le u' u... still the same gap.

Actually this does NOT avoid the gap. The fundamental issue is that no matter how we characterize "intermediate point," we need phi at u, but we can only derive phi at some u' with bx_le u' u.

### Option B: Direct BX7-based proof (RECOMMENDED, from plan v5)

The plan v5 (specs/098) recommends a direct proof using BX7 (Until linearity) at the MCS level. This avoids the sigma_strict / guard weakening approach entirely.

**Strategy for eventuality_resolution (forward)**:
1. Given phi U psi in w, psi not in w
2. BX9: phi in w. BX10: F(psi) in w
3. Construct v via bx_forward_witness with psi in v, bx_le w v
4. For the guard: given u with bx_le w u and bx_lt u v (or whatever strictness):
   - phi U psi in w and bx_le w u via BX4: G(P(phi U psi)) in w, so P(phi U psi) in u
   - backward_witness: u' with bx_le u' u and phi U psi in u'
   - Now apply BX7 to (phi U psi) at u' and (top U psi) at u (from F(psi) in u via BX12):
     BX7 gives three disjuncts -- one of which gives phi in u
   - **KEY**: This requires F(psi) in u, which IS derivable: bx_le u v and psi in v gives F(psi) in u (via connect_past + bx_H_forward, already noted in Realization.lean line 560)

This approach needs careful analysis of which BX7 disjunct applies, but it is the mathematically correct path.

**Strategy for backward**:
1. Given v with bx_le w v, psi in v, guard phi on [w,v), psi not in w
2. Contradiction: assume neg(phi U psi) in w
3. BX11 (temporal linearity) + the guard should yield a contradiction
4. The enriched seed construction already gives u with bx_le w u, bx_le u v, neg(phi U psi) in u
5. F(psi) in u (from bx_le u v and psi in v)
6. phi in u (from the guard, IF we can show bx_lt u v)
7. phi and F(psi) at u with neg(phi U psi) in u -- this IS a contradiction via BX axioms

The remaining question: can we derive bx_lt u v (i.e., not bx_le v u) for the enriched-seed constructed u? The enriched seed includes h_content(v), so bx_le u v. Does it also guarantee not bx_le v u? If psi in v but psi not in u (which follows from neg(phi U psi) in u... wait, that's wrong: neg(phi U psi) does not imply neg(psi)).

### Option C: Modified signatures with Sigma parameter (FALLBACK)

Add a Sigma parameter to the Frame.lean sorry functions and use sigma_strict instead of bx_lt:

```lean
noncomputable def bx_until_eventuality_resolution
    (Sigma : Finset Formula) (w : BXPoint) (φ ψ : Formula)
    (h_sigma_phi : Formula.untl φ ψ ∈ Sigma)
    (h_until : Formula.untl φ ψ ∈ w.formulas)
    (h_not_psi : ψ ∉ w.formulas) :
    ∃ v : BXPoint, bx_le w v ∧ ψ ∈ v.formulas ∧
      ∀ u : BXPoint, bx_le w u → sigma_strict Sigma u v → φ ∈ u.formulas
```

This weakens the guard from `bx_lt u v` to `sigma_strict Sigma u v`, which is strictly weaker (sigma_strict implies bx_lt but not vice versa). The `until_iff_mcs` statement would also need a Sigma parameter.

**Problem**: This pushes the Sigma parameter all the way up to TruthLemma.lean and potentially Completeness.lean. The biconditional statement becomes Sigma-dependent, which is mathematically inelegant. And importantly, the backward direction still has the same gap.

## Evidence/Examples

### Exact sorry locations in Frame.lean (lines 607-647)

```
Frame.lean:613  bx_until_eventuality_resolution  sorry
Frame.lean:624  bx_until_backward                sorry
Frame.lean:636  bx_since_eventuality_resolution  sorry
Frame.lean:647  bx_since_backward                sorry
```

### Exact sorry locations in Realization.lean (lines 500-622)

```
Realization.lean:500  until_eventuality_resolution (case phi in u')  sorry
Realization.lean:504  until_eventuality_resolution (case psi in u')  sorry
Realization.lean:564  until_backward                                 sorry
Realization.lean:590  since_eventuality_resolution (case phi in u')  sorry
Realization.lean:592  since_eventuality_resolution (case psi in u')  sorry
Realization.lean:622  since_backward                                 sorry
```

### F(psi) derivable at intermediate points (critical for BX7 approach)

From Realization.lean line 560 analysis:
```
bx_le u v and psi in v:
  BX4' on psi: H(F(psi)) in v
  bx_H_forward with bx_le u v: F(psi) in u   -- YES, this works
```

This is the critical enabler for the BX7 approach: F(psi) is available at every intermediate point u between w and v.

### BX7 linearity axiom (critical for the recommended approach)

```lean
| linear_until (φ ψ χ θ : Formula) :
    Axiom (Formula.and (Formula.untl φ ψ) (Formula.untl χ θ)
      |>.imp (Formula.or
          (Formula.or
            (Formula.untl (Formula.and φ χ) (Formula.and ψ θ))
            (Formula.untl (Formula.and φ χ) (Formula.and ψ χ)))
          (Formula.untl (Formula.and φ χ) (Formula.and φ θ))))
```

BX7 says: if (phi U psi) and (chi U theta) both hold, then one of three combined Until formulas holds. Applied to (phi U psi) at u' and (top U psi) at u, this constrains the relationship between their witnesses.

## Confidence Level

**Medium-High** for the BX7 direct approach (Option B). The mathematical ingredients are all present:
- F(psi) at intermediate points is derivable (verified in Realization.lean)
- BX7 provides the linearity constraint
- BX9 provides the elimination at each step
- The approach avoids sigma_strict entirely and works at the raw MCS level

**Low** for the sigma_strict guard weakening (Option C). The backward direction has the same fundamental gap regardless of how the guard is weakened.

**Low** for Option A (restructured biconditional). The gap persists under any reformulation of the guard that still requires phi at arbitrary intermediate BXPoints.

The key remaining uncertainty for Option B is the BX7 disjunct analysis: which of the three BX7 disjuncts applies, and does it give phi at u directly? This requires careful case analysis that has not been fully worked out. The plan v5 (specs/098) should contain more detail on this.
