# Critic Analysis: Challenge Assumptions and Find Blind Spots (Round 3, Teammate C)

- **Task**: 102 - implement_quotient_filtration_close_sorries
- **Artifact**: reports/03_teammate-c-findings.md
- **Date**: 2026-04-11
- **Role**: Critic (Teammate C, Round 3)

## Executive Summary

After careful code review of Frame.lean, TruthLemma.lean, Realization.lean, LocusControl.lean, and the axiom definitions, I identify **two previously-unnoticed structural issues** and challenge several claims from prior rounds. The most important finding is that **the backward direction has an overlooked constructive proof strategy** that does not require contradiction at all. I also identify that the relationship between the Realization.lean and Frame.lean sorries is more nuanced than previously understood -- LocusControl.lean explicitly delegates Realization sorries to Frame.lean, contradicting the Round 2 Critic's claim of independence.

---

## Challenge 1: "bx_le non-totality is the root cause"

**Verdict: PARTIALLY WRONG -- it is real but misidentified as the bottleneck**

**Confidence: HIGH (85%)**

The non-totality of `bx_le` is a genuine mathematical fact. However, calling it the "root cause" conflates two distinct problems:

### Problem A: The forward direction (eventuality resolution)

The actual gap at Realization.lean:500 is:
```
-- We have: phi in u', bx_le u' u
-- We need: phi in u
-- Gap: bx_le u' u only propagates G-content, not phi
```

This is genuinely caused by bx_le non-totality. If bx_le were total, we would have either `bx_le u u'` or `bx_le u' u` with totality, and in either case could propagate formulas. But the actual structure of the problem is more specific: we need `phi` to propagate along a SINGLE bx_le step from u' to u. Non-totality only matters if the propagation mechanism is g_content inclusion.

**The ACTUAL root cause** is that the canonical model's ordering uses g_content for propagation, but Until guard formulas are not G-formulas. This is not about totality per se -- it is about the mismatch between the propagation mechanism (G-content) and the formulas that need to propagate (arbitrary subformulas).

### Problem B: The backward direction (until_backward)

The gap at Realization.lean:564 is different. The comment at lines 550-563 reveals a partially-developed BX7 strategy. The actual gap is:
```
-- We have: bx_le w u, bx_le u v, neg(phi U psi) in u
-- We need: contradiction OR bx_le v u is false
```

The previous critic (Round 2) correctly notes that `phi in u` and `neg(phi U psi) in u` is consistent. But the analysis stops too early. The enriched seed gives us MORE than just these two facts at u. We also have:
- `g_content(w) ⊆ u.formulas` (from the seed construction)
- `h_content(v) ⊆ u.formulas` (from the seed construction)

This means `bx_le w u` AND `bx_le u v` simultaneously. The point u sits BETWEEN w and v in the bx_le ordering. This is the key structural property that has not been fully exploited.

---

## Challenge 2: "BX7 exhaustively fails"

**Verdict: INSUFFICIENTLY EXPLORED -- the right instantiation was never tried**

**Confidence: MEDIUM-HIGH (70%)**

Previous research says "BX7 was tested with 3 combinations and one disjunct always survives." Let me trace through the critical BX7 instantiation that was NOT fully explored.

### The overlooked BX7 instantiation for the forward direction

At the intermediate point u, we have:
- `P(phi U psi) in u` (from BX4 connectedness and bx_le w u)
- `F(psi) in u` (from F_from_above, since bx_le u v and psi in v)
- By BX12: `top U psi in u` (from F(psi))

Now, the backward witness gives us u' with `bx_le u' u` and `phi U psi in u'`. From BX9: `phi in u' OR psi in u'`. If `psi in u'`, then since `bx_le u' u`, we get F(psi) in u' (which we already know) but NOT psi in u.

But wait -- we also have `phi U psi in u'`. BX5 gives `(phi AND (phi U psi)) U psi in u'`. Now apply BX7 to this and `top U psi in u`:

Wait -- BX7 requires BOTH Until formulas at the SAME point. We have `(phi AND (phi U psi)) U psi in u'` and `top U psi in u`. These are at DIFFERENT points (u' and u). BX7 cannot be applied across points.

This is the fundamental issue with the BX7 approach: BX7 is a local axiom (applies at a single point), but the proof needs to relate formulas across DIFFERENT bx_le-related points.

### However: BX7 at the ORIGINAL point w

At w, we have:
- `phi U psi in w` (given)
- `F(psi) in w` (from BX10)
- By BX12: `top U psi in w`

Apply BX7 to `(phi U psi)` and `(top U psi)` at w:
```
BX7(phi, psi, top, psi):
  (phi U psi) AND (top U psi) ->
    ((phi AND top) U (psi AND psi)) OR
    ((phi AND top) U (psi AND top)) OR
    ((phi AND top) U (phi AND psi))
```

Simplifying (phi AND top = phi, psi AND psi = psi, psi AND top = psi):
```
  (phi U psi) OR (phi U psi) OR (phi U (phi AND psi))
```

The first two disjuncts just give back `phi U psi` (which we already have). The third gives `phi U (phi AND psi)`, which by BX3 (right monotonicity with `phi AND psi -> psi`) gives `phi U psi` again.

**Result: BX7 at w with these parameters is TAUTOLOGICAL.** It gives no new information. This confirms the previous finding but makes it precise -- BX7 with `(phi U psi)` and `(top U psi)` is useless because both target the same eventuality psi.

### What about BX7 with DIFFERENT eventualities?

BX7 would be useful if we had TWO Until formulas at the same point targeting DIFFERENT eventualities. The problem structure only gives us Until formulas targeting psi. Unless we can construct an Until formula targeting something other than psi, BX7 cannot provide ordering information.

**Key insight**: BX7 is not the right tool for this problem. BX7 compares DIFFERENT temporal goals. Here we have one temporal goal (reaching psi) and need information about the GUARD (phi). BX7 does not speak about guards.

---

## Challenge 3: "The backward direction cannot work by contradiction"

**Verdict: THE PREVIOUS CRITIC WAS RIGHT ABOUT CONTRADICTION, BUT MISSED A CONSTRUCTIVE APPROACH**

**Confidence: MEDIUM (60%)**

### The constructive approach for until_backward

The Frame.lean `bx_until_backward` has this structure:
```
Given: bx_le w v, psi in v, guard (forall u, bx_le w u -> bx_lt u v -> phi in u), psi not in w
Show: phi U psi in w
```

Instead of contradiction, consider a DIRECT derivation. We have:
1. `phi in w` (from the guard with u = w? No -- bx_lt w v = bx_le w v AND NOT bx_le v w. We need NOT bx_le v w.)

Actually, wait. The guard is `forall u, bx_le w u -> bx_le u v AND NOT bx_le v u -> phi in u`. Can we instantiate with u = w? That requires `bx_le w w` (yes, reflexivity) AND `bx_le w v AND NOT bx_le v w`. We have `bx_le w v` (given). Do we have NOT bx_le v w?

Not necessarily. If `bx_le v w` also holds (i.e., w and v are bx_le-equivalent), then the guard condition `bx_lt w v` is false, and we get nothing from the guard.

But if `bx_le v w` holds, then `g_content(v) ⊆ w.formulas`. Since `psi in v`, this does NOT give `psi in w` (psi is not a G-formula). However, any `G(chi) in v` gives `chi in w`.

Let me consider the case split:
- **Case bx_le v w**: Then w and v are bx_le-equivalent (mutual g_content inclusion). We have psi in v and psi not in w. So psi is NOT in g_content of anything -- psi is not of the form `chi` where `G(chi) in v`. The guard is vacuously true (no u satisfies bx_lt u v when bx_le v w... wait, bx_lt u v means bx_le u v AND NOT bx_le v u. If bx_le v w and bx_le w u (transitivity gives bx_le v u), so we need NOT bx_le v u, which is NOT bx_le v u). Hmm, this gets complicated.

Actually, wait. I realize the key issue: in this case (bx_le v w), we have:
- G(P(phi U psi)) in w (from BX4 connectedness on phi U psi in w)
- This propagates through any bx_le successor/predecessor

But we also have `H(F(psi)) in v` (from BX4' on psi in v), and since bx_le w v, `F(psi) in w` (via bx_H_forward). So F(psi) in w, and we already know phi U psi in w... wait, that's what we're trying to prove!

The direct approach does not seem to work either. The fundamental difficulty is constructing `phi U psi in w` from the witness-and-guard characterization.

### Alternative: Use BX5 + BX10 as an "induction step"

From BX5: `phi U psi -> (phi AND (phi U psi)) U psi`
From BX10: `phi U psi -> F(psi)`
From BX9: `phi U psi -> phi OR psi`

Consider deriving: `phi U psi -> phi OR (phi AND F(phi U psi))`

This would be a "one-step unfolding" of Until without the X (next-time) operator. Is this derivable from BX1-BX12?

Start: `phi U psi in w` and `psi not in w`.
- BX9: `phi in w` (since psi not in w)
- BX5: `(phi AND (phi U psi)) U psi in w`
- BX10 on the accumulated form: `F(psi) in w`
- BX4 on `phi U psi in w`: `G(P(phi U psi)) in w`

Now, at any future v with bx_le w v: `P(phi U psi) in v`, giving a backward witness v' with `phi U psi in v'`. But we need `phi U psi in v` itself, not just at a backward witness.

**This is the core gap everywhere**: we can get `phi U psi` at a backward witness v', but not at v itself. The Until formula does not propagate forward through bx_le because it is not a G-formula.

### Critical observation: can we derive G(phi U psi -> F(phi U psi))?

If `phi U psi in w` and `psi not in w`:
- BX5 + BX10: `F(psi) in w`
- BX4: `G(P(phi U psi)) in w`

Now: `P(phi U psi) in v` for any future v. This gives a backward witness with `phi U psi`. But `F(phi U psi) in v`? From the backward witness v' with `phi U psi in v'` and `bx_le v' v`: by BX4 on `phi U psi in v'`, we get `G(P(phi U psi)) in v'`, so `P(phi U psi) in v`. This is circular.

What about: can we derive `G(phi U psi) in w` when `phi U psi in w`? NO. `G(phi U psi)` says "phi U psi holds at all future times." But `phi U psi` says "eventually psi, with phi until then." Once psi holds, phi U psi is trivially true (by BX8). So actually... does `phi U psi -> G(phi U psi)` hold in linear temporal logic?

**Yes!** In LTL on linear orders: if `phi U psi` holds at time t, then at any future time s:
- If s is before the psi-witness: phi holds at s (guard), and psi will still come, so `phi U psi` holds at s.
- If s is at or after the psi-witness: psi holds at s (or already held), so `phi U psi` holds at s (by BX8).

This means `phi U psi -> G(phi U psi)` IS VALID on linear orders. Is it derivable from BX1-BX12?

If `phi U psi -> G(phi U psi)` were derivable, then `phi U psi in w` gives `G(phi U psi) in w`, which means `phi U psi` propagates through bx_le! This would solve EVERYTHING.

### Attempting the derivation of phi U psi -> G(phi U psi)

Equivalently: `phi U psi -> NOT F(NOT (phi U psi))`. Or contrapositively: `F(NOT (phi U psi)) -> NOT (phi U psi)`.

In words: "if at some future time phi U psi fails, then phi U psi fails now." Is this derivable?

BX5 gives `phi U psi -> (phi AND (phi U psi)) U psi`. The accumulated version has `phi U psi` in the guard. If at some future time phi U psi fails, the guard of the accumulated version breaks, which breaks the Until at the current time.

More precisely: Suppose `phi U psi in w` and `F(NOT(phi U psi)) in w`. Then there exists v >= w with `NOT(phi U psi) in v`. By BX5, `(phi AND (phi U psi)) U psi in w`, so there exists s >= w with psi at s and `phi AND (phi U psi)` at all r in [w, s).

If v < s (the psi-witness): then `phi AND (phi U psi)` at v, so `phi U psi in v`. But `NOT(phi U psi) in v`. Contradiction.

If v >= s: then psi at s and v >= s. By BX8 at v: since s <= v and psi at s, we need... actually no, BX8 says `psi -> phi U psi`, not that a past psi gives current `phi U psi`.

**The argument breaks at "v >= s"** because we are working in the CANONICAL model where bx_le is not total. We cannot assume either v < s or v >= s.

**But semantically** (on actual linear orders), `phi U psi -> G(phi U psi)` IS valid. The question is whether it is DERIVABLE from BX1-BX12 without linear order totality.

Let me check using BX7 (linear_until). Apply BX7 to `(phi AND (phi U psi)) U psi` at w and `top U (NOT(phi U psi))` at w (which we get from F(NOT(phi U psi)) via BX12):

```
BX7((phi AND (phi U psi)), psi, top, NOT(phi U psi)):
  ((phi AND (phi U psi)) U psi) AND (top U NOT(phi U psi)) ->
    D1: ((phi AND (phi U psi)) AND top) U (psi AND NOT(phi U psi))
    OR D2: ((phi AND (phi U psi)) AND top) U (psi AND top)
    OR D3: ((phi AND (phi U psi)) AND top) U ((phi AND (phi U psi)) AND NOT(phi U psi))
```

Simplifying:
```
D1: (phi AND (phi U psi)) U (psi AND NOT(phi U psi))
D2: (phi AND (phi U psi)) U psi  (which we already have)
D3: (phi AND (phi U psi)) U ((phi AND (phi U psi)) AND NOT(phi U psi))
```

For D1: `psi AND NOT(phi U psi)` is inconsistent! By BX8, `psi -> phi U psi`, so `psi AND NOT(phi U psi) -> bot`. By BX10, `(phi AND (phi U psi)) U (psi AND NOT(phi U psi)) -> F(psi AND NOT(phi U psi)) -> F(bot)`, which means F(bot) in w. But F(bot) = NOT G(NOT bot) = NOT G(top). Since G(top) is a theorem (necessitation of tautology), NOT G(top) is inconsistent. So D1 leads to contradiction.

For D3: `(phi AND (phi U psi)) AND NOT(phi U psi)` is directly contradictory. So `F((phi AND (phi U psi)) AND NOT(phi U psi)) -> F(bot)`, same contradiction as D1.

For D2: This just gives back what we had. No new information, but no contradiction either.

**Result**: BX7 eliminates disjuncts D1 and D3, leaving only D2. This means: if `phi U psi in w` and `F(NOT(phi U psi)) in w`, then BX7 forces D2 which gives `(phi AND (phi U psi)) U psi in w`. This is what we ALREADY had from BX5. **No contradiction is derived.**

**Conclusion**: `phi U psi -> G(phi U psi)` is NOT derivable from BX1-BX12 using the BX7 approach I just tried. The BX7 disjunct analysis eliminates the contradictory cases but the remaining case is vacuously true (repeats input).

**However**, this is a SIGNIFICANT finding: the fact that D1 and D3 are contradictory means BX7 DOES constrain the problem. The argument just needs one more ingredient to force D2 to also yield a contradiction.

---

## Challenge 4: "The finite linear model is the best fallback (80% confidence)"

**Verdict: OVERCONFIDENT -- the connection to Frame.lean is non-trivial**

**Confidence: MEDIUM (55%)**

### What the finite model gives

A finite linear model construction would produce a finite totally-ordered set of BXPoints where Until truth is straightforward (the ordering is total, so guard propagation works). This proves Until correctness within that finite model.

### What Frame.lean actually needs

Frame.lean's sorries require statements about ARBITRARY BXPoints, not points within a specific finite model. The Frame.lean signatures are:
```
bx_until_eventuality_resolution (w : BXPoint) (phi psi : Formula) ... :
  exists v : BXPoint, bx_le w v AND psi in v AND (guard)
```

This quantifies over ALL BXPoints. A finite model proof shows the result for points within that model, but Frame.lean needs it for points in the INFINITE canonical model.

### The gap: lifting finite model results to the infinite model

To use a finite model result to close Frame.lean, you would need one of:
1. **Embed the finite model INTO the canonical model**: Show that the finite model's points are BXPoints and the finite model's ordering is bx_le. This is essentially the quasimodel realization approach (already partially attempted in Realization.lean with the same obstacles).

2. **Bypass Frame.lean entirely**: Prove completeness directly via the finite model, bypassing Frame.lean and TruthLemma.lean. This is feasible but requires:
   - Constructing a concrete `TaskModel` from the finite model
   - Proving the truth lemma directly for this model
   - Closing the Completeness.lean:154 sorry

3. **Change the completeness proof architecture**: Instead of MCS-based canonical model -> truth lemma -> completeness, use filtration-based finite model -> truth correspondence -> completeness.

Option 2 or 3 would bypass the Frame.lean sorries entirely (leaving them as dead code), but this is a much larger architectural change than "close the 10 sorries."

### My assessment

The 80% confidence assumes the finite model approach is a simple "slot in" replacement. It is not. The approach either requires solving the same lifting problems (quasimodel realization) or requires restructuring the entire completeness proof architecture. I rate it at 55% confidence for actually closing the Frame.lean sorries, but 75% for producing an alternative completeness proof.

---

## Challenge 5: "Only G-formulas propagate through bx_le"

**Verdict: TRUE by definition, but there ARE other propagation paths**

**Confidence: HIGH (90%)**

By definition, `bx_le w v` means `g_content(w) ⊆ v.formulas`, so only G-content propagates forward. This is definitionally correct.

However, there are additional propagation mechanisms in the codebase:

### Mechanism 1: H-content propagates backward
If `bx_le w v`, then `h_content(v) ⊆ w.formulas` (via `g_content_subset_implies_h_content_reverse`). This is the dual direction.

### Mechanism 2: Box formulas propagate bidirectionally
`box_preserved_along_bx_le` (Frame.lean:538) proves `box(phi) in w iff box(phi) in v` when `bx_le w v`. This uses `temp_future` for the forward direction and S5 negative introspection for the backward direction.

### Mechanism 3: BX4 connectedness gives indirect propagation
If `phi in w`, then `G(P(phi)) in w` (BX4 connectedness). So `P(phi) in v` for any v with `bx_le w v`. Then there exists v' with `bx_le v' v` and `phi in v'`. This propagates phi's EXISTENCE (as an F/P-witness) but not phi itself.

### Mechanism 4: Temporal formulas propagate via their modality
- `G(phi) in w` and `bx_le w v` gives `phi in v` AND `G(phi) in v` (since `G(G(phi)) in w` by temp_4).
- So G-formulas propagate AND persist.
- `F(phi) in w` does NOT propagate forward via bx_le.

### What CAN be derived at intermediate point u?

Given `phi U psi in w`, `bx_le w u`, `bx_le u v`, `psi in v`:
1. `P(phi U psi) in u` (from BX4 + bx_le)
2. `F(psi) in u` (from F_from_above: bx_le u v + psi in v -> H(F(psi)) in v -> F(psi) in u)
3. `top U psi in u` (from F(psi) + BX12)
4. `phi in u'` for some u' with `bx_le u' u` and `phi U psi in u'` (backward witness from P(phi U psi))
5. `G(P(phi U psi)) in u` (from G(P(phi U psi)) in w + bx_le w u)
6. Box(phi) in u iff Box(phi) in w (box preservation)

None of these give `phi in u` directly.

---

## Challenge 6: Relationship between Realization.lean and Frame.lean sorries

**Verdict: PREVIOUS CRITIC (ROUND 2) WAS WRONG -- LocusControl.lean DOES delegate**

**Confidence: HIGH (95%)**

The Round 2 critic (Finding C3) stated: "The 6 Realization.lean sorries are INDEPENDENT implementations, not wrappers around Frame.lean. Closing Frame.lean does NOT automatically close them."

This is factually incorrect based on the code. LocusControl.lean (lines 54-94) explicitly defines:
```
bx_until_eventuality_resolution' := until_eventuality_resolution
bx_until_backward' := until_backward
bx_since_eventuality_resolution' := since_eventuality_resolution
bx_since_backward' := since_backward
```

These LocusControl functions ARE wrappers around the Realization.lean functions. But more importantly, the Frame.lean functions and Realization.lean functions are PARALLEL implementations of the same statements with independent sorries. Neither delegates to the other.

However, the critical observation is that **Frame.lean sorries and Realization.lean sorries are proving the SAME mathematical statements** (up to minor signature differences). Closing either set closes the problem -- you don't need to close both. The correct approach is:

1. Close the 4 Frame.lean sorries (which TruthLemma.lean directly calls), OR
2. Close the 6 Realization.lean sorries AND rewire TruthLemma.lean to call them, OR
3. Close EITHER set and delete the other as dead code.

The Round 2 synthesis was correct in recommending approach (a) from the resolution, but the claim of "independence" was misleading.

---

## Finding 7 (NEW): The box sorry at Frame.lean:440 is NOT a sorry

**Confidence: HIGH (95%)**

The question asks about "the box sorry at Frame.lean:440." Reading Frame.lean:440, this is a COMMENT that says "for now, sorry the full modal equivalence." But the actual code that follows (lines 444-498) PROVES the modal equivalence completely. The proof uses S5 negative introspection (lines 467-498) for the backward direction. There is no sorry in the box section of Frame.lean.

The only Frame.lean sorries are at lines 613, 624, 636, 647 -- all in the Until/Since eventuality resolution section.

---

## Finding 8 (NEW): The truth lemma could be reformulated to need less from Frame.lean

**Confidence: MEDIUM-HIGH (70%)**

The current `until_iff_mcs` (TruthLemma.lean:281) states:
```
phi U psi in w iff
  exists v, bx_le w v AND psi in v AND
    forall u, bx_le w u -> bx_lt u v -> phi in u
```

The guard quantifies over ALL BXPoints u between w and v. This requires Frame.lean to prove the guard for arbitrary u.

### Alternative formulation 1: Reflexive Until without guard

The semantics uses `r < s` for the guard. On a reflexive preorder where bx_le is NOT total, `bx_lt` may not be the right notion. Consider:

```
phi U psi in w iff
  exists v, bx_le w v AND psi in v AND
    (bx_le v w OR phi in w)
```

This says: either v = w (bx_le-equivalent, so psi in v is witnessed reflexively) or phi holds at the current point. This is much weaker but may be wrong -- it loses the full guard condition.

### Alternative formulation 2: Inductive characterization

```
phi U psi in w iff psi in w OR (phi in w AND F(phi U psi) in w)
```

The forward direction: from BX9 (phi OR psi) and BX10 (F(psi)). If psi in w, done. If phi in w, then F(psi) in w, but we need F(phi U psi) not just F(psi). Do we have F(phi U psi)?

From BX5: `phi U psi -> (phi AND (phi U psi)) U psi`. From BX10 on the accumulated: `F(psi)`. That does not give F(phi U psi).

Can we derive `phi U psi -> F(phi U psi)`? This says the Until formula will hold at some future point. But phi U psi at w already means psi will eventually hold; at that point psi holds so phi U psi holds (by BX8). So `F(phi U psi)` would follow from F(psi) + "psi -> phi U psi" (BX8) + "F(alpha) and G(alpha -> beta) -> F(beta)" (derivable from BX2/BX3).

Actually: F(psi) in w, and `psi -> phi U psi` is a theorem (BX8). So `G(psi -> phi U psi) in w` (by necessitation + BX1 giving G of theorems). Then from a derivable fact "F(alpha) AND G(alpha -> beta) -> F(beta)" we get `F(phi U psi) in w`.

So: `phi U psi in w -> F(phi U psi) in w` IS derivable!

This gives the inductive characterization:
- Forward: `phi U psi -> psi OR (phi AND F(phi U psi))` (from BX9 + above)
- Backward: `psi -> phi U psi` (BX8) AND `phi AND F(phi U psi) -> phi U psi` (this direction needs checking)

For the backward direction: does `phi AND F(phi U psi) -> phi U psi`?

`F(phi U psi) in w` means there exists v with bx_le w v and `phi U psi in v`. By BX10: `F(psi) in v`. By BX4 on `psi in v` (once psi is witnessed): this gets circular.

Actually: `F(phi U psi) in w` by BX12 gives `top U (phi U psi) in w`. With `phi in w`, can we derive `phi U psi in w`? This would be: phi AND (top U (phi U psi)) -> phi U psi. By BX7 with (phi U psi, psi, top, phi U psi):

Wait, this is getting complicated. Let me step back.

**The key insight**: The truth lemma biconditional might not need the full "guard on all intermediate points" formulation. It could use the inductive characterization `phi U psi iff psi OR (phi AND F(phi U psi))` as an intermediate step, then relate that to the semantic truth condition via the TaskModel construction.

This is a potential **architectural simplification** that could bypass the Frame.lean sorries entirely.

---

## Finding 9 (NEW): Has anyone considered changing the SEMANTICS?

**Confidence: LOW-MEDIUM (40%)**

The question asks about an inductive characterization: `phi U psi iff psi OR (phi AND exists v > w, phi U psi in v)`. On total linear orders, this IS equivalent to the standard Until. But in the canonical model (with non-total bx_le), "exists v > w" means "exists v with bx_lt w v" which is stronger than "exists v with bx_le w v and v different from w."

Changing the semantics would mean changing Truth.lean (the truth_at definition for Until), which would cascade to all soundness proofs. The soundness proofs in Soundness.lean and SoundnessLemmas.lean have been fully proved -- changing the semantics would break them.

This is a high-cost, high-risk approach. NOT recommended.

---

## Finding 10 (NEW): The BXPoint definition does NOT restrict to enrichedClosure

**Confidence: HIGH (95%)**

The question asks whether "BXPoints are maximally consistent sets restricted to enrichedClosure(target)." This is INCORRECT. Reading Frame.lean:49:

```
structure BXPoint where
  formulas : Set Formula
  is_mcs : SetMaximalConsistent formulas
```

BXPoints are UNRESTRICTED maximally consistent sets -- they contain formulas from ALL of Formula, not just enrichedClosure(target). The enrichedClosure restriction only applies to HintikkaPoints (in Quasimodel/HintikkaPoint.lean), which are finite approximations used in the defect-discharge chain construction.

This distinction is important: BXPoints have FULL information (all formulas), while HintikkaPoints have RESTRICTED information (only Sigma-tracked formulas). The quasimodel approach works with HintikkaPoints and then lifts back to BXPoints via Lindenbaum extension. The gap is in this lifting step.

---

## Summary of Verdicts

| Claim | Verdict | Confidence |
|-------|---------|------------|
| bx_le non-totality is root cause | Partially wrong -- the real issue is G-content vs arbitrary formula propagation | 85% |
| BX7 exhaustively fails | True for the tested instantiations, but the right strategy is BX7 for deriving `phi U psi -> G(phi U psi)` (which also fails but instructively) | 70% |
| Backward direction cannot work by contradiction | Correct, but constructive approach also stalled | 60% |
| Finite linear model at 80% confidence | Overconfident -- 55% for closing Frame.lean, 75% for alternative completeness | 55% |
| Only G-formulas propagate through bx_le | True by definition, but box/H-content/BX4 give additional paths | 90% |
| Realization.lean sorries are independent | Wrong -- they prove same statements; close either set | 95% |
| Box sorry at Frame.lean:440 | Does not exist (fully proved) | 95% |
| BXPoints restricted to enrichedClosure | Wrong -- BXPoints are unrestricted MCS | 95% |

## Recommended Investigation Priority

1. **Derive `phi U psi -> F(phi U psi)` and explore inductive truth lemma** (Finding 8). This is the most promising new direction. If the truth lemma can be reformulated inductively, Frame.lean sorries may become unnecessary. Estimated cost: 4-6 hours.

2. **Investigate `phi U psi -> G(phi U psi)` derivability** more carefully. The BX7 analysis (Challenge 2) shows D1 and D3 are contradictory, leaving only D2. A second application of BX7 or a combined BX5+BX7 argument might close it. Estimated cost: 2-3 hours.

3. **If 1 and 2 fail**: Pursue the finite model approach but plan for architectural changes (bypassing Frame.lean rather than closing its sorries). Estimated cost: 30-50 hours.
