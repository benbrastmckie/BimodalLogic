# Critic Analysis: Until/Since Sorry Closure (Teammate C)

- **Task**: 102 - implement_quotient_filtration_close_sorries
- **Artifact**: reports/02_teammate-c-findings.md
- **Date**: 2026-04-11
- **Role**: Critic (Teammate C)

## Key Findings

### Finding 1: The bx_lt Definition Is Consistent but the Guard Mismatch Is Subtler Than Described

The TruthLemma.lean `bx_lt` definition (line 212-213) is:
```lean
def bx_lt (w v : BXPoint) : Prop := bx_le w v ∧ ¬bx_le v w
```

This matches exactly with the Frame.lean sorry signatures, which use `bx_le u v ∧ ¬bx_le v u` as the guard. The plan proposes to replace `¬bx_le v u` with `sigma_strict Sigma u v`. However, there is a critical asymmetry that the current analysis glosses over:

- `sigma_strict Sigma u v` is WEAKER than `bx_le u v ∧ ¬bx_le v u`. Specifically, `not_bx_le_of_sigma_strict` (SigmaOrdering.lean line 116) proves `sigma_strict u v -> not bx_le v u`, but the converse does NOT hold: `¬bx_le v u` does not imply `sigma_strict Sigma u v` because the distinguishing G-formula might be outside Sigma.

- This means the MODIFIED Frame.lean signatures (with `sigma_strict`) have a WEAKER precondition on the guard, making them EASIER to prove but HARDER for callers to use. The TruthLemma caller currently provides `bx_lt u v = bx_le u v ∧ ¬bx_le v u`. To call the modified functions, it would need to provide `sigma_strict Sigma u v`, which requires a STRONGER hypothesis from the caller.

**Impact**: The plan's Phase 4 says "update TruthLemma.lean call sites" but underestimates this: the TruthLemma's `until_iff_mcs` currently states the biconditional with `bx_lt`, and the callers (Completeness.lean and the semantic truth definition) use `bx_lt`. Changing the guard condition fundamentally changes the truth lemma statement. Either:
  (a) The truth lemma statement itself must change to use `sigma_strict`, which cascades to the completeness theorem statement, or
  (b) A bridge lemma must show that the old `bx_lt` guard implies the new `sigma_strict` guard -- but this requires the enrichedClosure to capture ALL distinguishing G-formulas, which it does NOT (enrichedClosure is finite; the set of all G-formulas is infinite).

**This is a potential showstopper for the plan's Phase 4.**

### Finding 2: The Backward Direction Analysis Has a Critical Logical Gap

The Realization.lean `until_backward` (line 518) already has significant progress: it constructs `u` with `bx_le w u`, `bx_le u v`, and `¬(phi U psi) in u`. The comment (lines 550-563) correctly identifies the gap: we need either `¬bx_le v u` (to apply the guard) or a direct contradiction.

However, the analysis in the research report and implementation plan misses a simpler approach. Consider:

1. We have `bx_le u v` and `psi in v` (hypothesis).
2. By `F_from_above` (Realization.lean line 126): `F(psi) in u`.
3. By BX12 (`F_until_equiv`): `top U psi in u`.
4. We have `¬(phi U psi) in u`.
5. By BX7 (`linear_until`): Apply to `top U psi` and ... wait, we need `phi U psi in u` for BX7, but we have `¬(phi U psi) in u`.

Actually, this approach does not work either. But here is a different angle that WAS missed:

**From `¬(phi U psi) in u` and `F(psi) in u`**: We know psi will eventually hold but `phi U psi` fails. This means there must be a gap in the phi-guard. Specifically, `¬(phi U psi)` combined with `F(psi)` is consistent only if there exists a future point where `¬phi ∧ ¬psi` holds (before psi arrives). This is EXACTLY what `¬(phi U psi) ∧ F(psi)` encodes in linear temporal logic.

Now: if we could show `phi in u`, we get `phi in u` and `¬(phi U psi) in u`. These are consistent (phi can hold now while phi U psi fails if the guard will eventually break). So the guard gives us `phi in u` (if the guard applies), but this does NOT yield a contradiction with `¬(phi U psi) in u`.

**The backward direction therefore cannot work by simple contradiction.** The current enriched-seed approach constructs `u` between `w` and `v`, but the guard hypothesis only gives `phi in u` (not `phi U psi in u`). Having both `phi in u` and `¬(phi U psi) in u` is perfectly consistent -- it just means the Until formula fails starting from `u`.

### Finding 3: G(phi) IS in enrichedClosure When phi U psi Is a Subformula -- This Changes Everything

The `SubformulaClosure` includes `ghEnrichment(subformulas(target))`, which adds `G(f)` for every subformula `f`. Since `phi` is a subformula of `phi U psi`, and `phi U psi` is a subformula of the target, `G(phi)` is in `SubformulaClosure(target)` and hence in `enrichedClosure(target)`.

This is the key fact that the plan's Phase 3 fallback sub-strategy (lines 169-173) correctly identifies but does not adequately develop. The argument would be:

1. `phi U psi in w` and `bx_le w u` gives `P(phi U psi) in u` (via BX4 connectedness).
2. Backward witness: exists `u'` with `bx_le u' u` and `phi U psi in u'`.
3. `phi U psi in u'` and `psi not in u'` (need to establish this) gives `phi in u'` (BX9).
4. `phi in u'` gives `G(P(phi)) in u'` (BX4 connectedness: `phi -> G(P(phi))`).

Wait -- BX4 gives `phi -> G(P(phi))`, not `G(phi)`. We need `G(phi) in u'` to propagate phi to u via `bx_le u' u`. Having `G(P(phi)) in u'` only gives `P(phi) in u` via bx_le, which gives ANOTHER backward witness, not phi itself.

**The fallback sub-strategy in the plan explicitly claims "Show G(phi) in u' using enrichedClosure membership of G(phi) when phi U psi in Sigma"**. But enrichedClosure MEMBERSHIP of `G(phi)` is a property of the finite set Sigma, not of the MCS u'. The formula `G(phi)` being in Sigma does not mean `G(phi) in u'.formulas`. These are completely different things.

**This is a critical error in the plan.** Sigma membership (set-theoretic) is confused with MCS membership (logical). `G(phi) in enrichedClosure(target)` means the formula G(phi) is one of the formulas tracked by the finite closure. It does NOT mean G(phi) holds at any particular BXPoint.

### Finding 4: The Realization.lean Sorries Are NOT Purely Dependent on Frame.lean

The 6 Realization.lean sorries are at:
- `until_eventuality_resolution` (2 sorries, lines 500 and 504)
- `until_backward` (1 sorry, line 564)
- `since_eventuality_resolution` (2 sorries, lines 590 and 592)
- `since_backward` (1 sorry, line 622)

These are INDEPENDENT implementations that attempt the same mathematical content as the Frame.lean sorries but via a different approach (using the Quasimodel chain infrastructure). They are NOT wrappers around the Frame.lean functions.

The Frame.lean functions (`bx_until_eventuality_resolution`, `bx_until_backward`, etc.) are called by TruthLemma.lean. The Realization.lean functions (`until_eventuality_resolution`, `until_backward`, etc.) are parallel implementations that try to prove the same statements through the quasimodel/chain approach.

**Impact**: Closing the Frame.lean sorries does NOT automatically close the Realization.lean sorries. The plan's Phase 5 assumes the Realization.lean sorries "delegate to Frame.lean", but this is incorrect -- they are separate implementations. To close the Realization.lean sorries, one must either:
  (a) Delete the Realization.lean implementations and have them call the Frame.lean versions, or
  (b) Independently close the Realization.lean sorries using the same or different techniques.

### Finding 5: The enrichedClosure G/H Properties Are Narrower Than Claimed

The enrichedClosure adds `G(neg(bigconj T))` and `H(neg(bigconj T))` for every subset T of the SubformulaClosure. These are for "locus control" -- ensuring that g_content_closed_derivation results land within Sigma.

However, what the guard extension lemma needs is something different: it needs to show that `phi in u` for an arbitrary intermediate BXPoint `u`. The G/H-enrichment properties ensure that CERTAIN G-formulas are in Sigma (so sigma_strict can detect them), but they do NOT provide a mechanism to DERIVE `phi in u`.

The only mechanism to get `phi in u` from information about other BXPoints is:
- If `G(phi) in u'` and `bx_le u' u`, then `phi in u` (G-content propagation)
- If `phi in Sigma` and `sigma_equiv w u` and `phi in w`, then `phi in u` (Sigma-equivalence)

For the first: we need `G(phi) in u'.formulas` for some `u'` with `bx_le u' u`. This requires PROVING that some specific MCS contains `G(phi)`, not just that `G(phi)` is in Sigma.

For the second: we need `sigma_equiv` between `u` and some known point. But intermediate points are arbitrary -- we have no control over their Sigma-signatures.

### Finding 6: The TruthLemma Does NOT Actually Need the Full Guard Strength

A closer reading of TruthLemma.lean reveals that the truth lemma for Until (line 281-307) and Since (line 315-357) calls the Frame.lean functions and passes their output directly to the semantic truth condition. The semantic truth definition in `Semantics/Truth.lean` defines Until truth as:

```
truth_at M w (phi U psi) = exists v, le w v ∧ truth_at M v psi ∧
    forall u, le w u → lt u v → truth_at M u phi
```

where `lt` is the strict ordering of the TaskModel. The Completeness theorem (Completeness.lean) constructs a TaskModel from BXPoints and needs the MCS truth lemma to bridge formula membership with semantic truth.

The key question is: what does `lt u v` mean in the TaskModel constructed from BXPoints? If the TaskModel uses `bx_le` as its ordering, then `lt` would be `bx_le u v ∧ ¬bx_le v u` -- which is exactly `bx_lt`. So the truth lemma statement with `bx_lt` IS correct for the intended TaskModel.

However, there is an alternative: if the TaskModel used a DIFFERENT ordering (e.g., sigma_strict-based), then the truth lemma could use that ordering instead. This would require changing the Completeness.lean TaskModel construction, which the plan declares as out of scope (non-goal: "Closing the TaskModel embedding sorry").

## Assumptions Challenged

### Assumption 1: "sigma_strict is the correct weakening of ¬bx_le"

**Challenged**: sigma_strict is weaker as a PRECONDITION (easier to prove), but this means the CONCLUSION is less useful. The TruthLemma needs the result with `¬bx_le v u` in the guard, not `sigma_strict`. Using sigma_strict requires changing the truth lemma statement, which changes the completeness theorem, which may require changing the TaskModel construction.

### Assumption 2: "The enrichedClosure G/H-enrichment properties are the key ingredient for the guard extension lemma"

**Challenged**: The enrichedClosure properties ensure certain formulas are TRACKED in Sigma. They do not provide a way to DERIVE that those formulas hold at specific BXPoints. Sigma membership (a set-theoretic property of a finite set) and MCS membership (a logical property of a maximal consistent set) are completely different things.

### Assumption 3: "The backward direction fails because phi and F(psi) at u do not imply phi U psi at u"

**Confirmed but incomplete**: This is true, but the analysis should also note that the backward direction's enriched-seed approach DOES successfully construct a point `u` between `w` and `v` with `¬(phi U psi) in u`. The actual gap is that having `phi in u` (from the guard) and `¬(phi U psi) in u` is NOT contradictory. So the backward proof needs a fundamentally different approach than contradiction via the guard.

### Assumption 4: "All 6 Realization.lean sorries are blocked by the same root cause as Frame.lean"

**Partially challenged**: While the mathematical obstacle is the same (non-totality of bx_le making guard propagation impossible), the Realization.lean implementations are structurally independent from Frame.lean. They use different proof strategies (chain-based rather than direct Lindenbaum extension). Closing Frame.lean does not automatically close Realization.lean.

### Assumption 5: "BX7/BX11 are NOT needed for the final design"

**Partially confirmed, but premature**: The plan dismisses BX7 and BX11, but the research report (sections 6.3-6.7) extensively explores how BX7 might help with the guard. BX7 (linear_until) provides ordering information about Until witnesses that could be relevant. The plan should not dismiss it without explanation.

## Questions That Should Be Asked

1. **Can the truth lemma use a different ordering than bx_le?** If the TaskModel in Completeness.lean used a sigma_strict-based ordering, the truth lemma could use that ordering directly, avoiding the bridge problem. Has anyone checked whether the TaskModel construction in Completeness.lean is flexible enough?

2. **Can we construct the witness v in bx_until_eventuality_resolution to have ADDITIONAL properties?** The current approach uses `bx_forward_witness` to get any v with `bx_le w v` and `psi in v`. But we have freedom in choosing v (via the Lindenbaum extension). Can we construct v such that `bx_le u v → sigma_strict Sigma u v` holds for all intermediate u? This would require including additional formulas in the Lindenbaum seed for v.

3. **Is the plan's Phase 3 guard extension lemma actually provable?** The plan's risk assessment rates the failure likelihood as Medium, but the mathematical analysis suggests it might be fundamentally unprovable. The core issue -- propagating a non-G-formula across bx_le -- cannot be resolved by sigma_strict or enrichedClosure. The only workaround is:
   - Change what "intermediate" means (use a different ordering)
   - Change the witness v to be constructed more carefully
   - Change the truth lemma statement entirely

4. **Would it be simpler to replace bx_le entirely?** Instead of the patchwork of sigma_strict modifications, would it be cleaner to define a new ordering `bx_le_sigma` that IS total (at least on the relevant fragment) and use THAT throughout the completeness proof? This is a bigger change but may be more mathematically sound.

5. **Is there a proof strategy for the backward direction that avoids contradiction?** The current approach assumes contradiction (suppose ¬(phi U psi), derive absurdity). But perhaps a constructive/direct approach would work: show that the hypothesis (exists witness v with psi and guard) directly DERIVES phi U psi via the BX axioms. For instance, can we use BX2 (left monotonicity) or BX3 (right monotonicity) to build phi U psi from the witness and guard?

6. **Can we use BX5 (self-accumulation) + BX6 (absorption) together with BX7 (linearity) in a novel way?** BX5 gives `phi U psi -> (phi ∧ (phi U psi)) U psi`. BX6 gives `phi U (phi ∧ (phi U psi)) -> phi U psi`. BX7 gives linearity of Until witnesses. Combined with the defect-discharge chain, is there a way to force the guard formula to propagate?

## Confidence Level

**Medium-Low** on the current plan succeeding as written.

**Specific confidence assessments**:
- Phase 1 (sigma ordering infrastructure): HIGH -- already completed, building well.
- Phase 2 (defect-discharge chain): MEDIUM -- the chain construction is standard, but connecting it to arbitrary intermediate BXPoints is the unsolved problem.
- Phase 3 (guard extension lemma): LOW -- the mathematical argument has not been demonstrated to work. The plan's fallback sub-strategy contains a critical error (confusing Sigma membership with MCS membership). The enrichedClosure properties do not provide what the proof needs.
- Phase 4 (modify Frame.lean): MEDIUM -- contingent on Phase 3, plus the bridge between sigma_strict and bx_lt is non-trivial.
- Phase 5 (close Realization.lean): LOW -- the plan incorrectly assumes these are wrappers around Frame.lean.

**Overall assessment**: The plan identifies the right problem space but the core mathematical difficulty (Phase 3) remains unsolved. The sigma_strict approach weakens the guard condition, which helps Frame.lean but creates a new problem at the TruthLemma/Completeness level. A fundamentally different approach may be needed -- either changing the canonical model's ordering to be total by construction, or restructuring the completeness proof to use a finite model with a provably total ordering.
