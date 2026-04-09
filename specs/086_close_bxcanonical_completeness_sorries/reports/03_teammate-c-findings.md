# Teammate C Findings: Risk Analysis and Gap Detection

**Task**: 86 - Close BXCanonical completeness sorries
**Focus**: Risks, blockers, edge cases, and gaps in current reasoning
**Date**: 2026-04-08

## Key Findings

### 1. The Exact Goal State at the Sorry

The sorry at `CanonicalEmbedding.lean:409` has this precise goal:

```
case neg
psi chi : Formula
ih_psi : untilSinceFree psi -> valid psi -> Nonempty (DerivationTree [] psi)
ih_chi : untilSinceFree chi -> valid chi -> Nonempty (DerivationTree [] chi)
h_usf : untilSinceFree (psi.imp chi)
h_valid : valid (psi.imp chi)
h_psi_valid : not (valid psi)
h_not_deriv : not (Nonempty (DerivationTree [] (psi.imp chi)))
h_cons : SetConsistent {(psi.imp chi).neg}
M : Set Formula
hM_sup : {(psi.imp chi).neg} <= M
hM_mcs : SetMaximalConsistent M
h_not_in : psi.imp chi not in M
w : BXPoint := { formulas := M, is_mcs := hM_mcs }
h_psi_in : psi in w.formulas
h_chi_not : chi not in w.formulas
|- False
```

We need to derive `False` from: `valid (psi -> chi)`, `not (valid psi)`, and an MCS `w` containing `psi` but not `chi` (and not `psi -> chi`).

### 2. The Induction Hypotheses Are NOT Directly Usable

The IH `ih_chi` requires `valid chi`, but we do NOT have `valid chi`. We have `valid (psi -> chi)` and `not (valid psi)`. This means:

- We CANNOT apply `ih_chi` directly because there is no way to extract `valid chi` from these hypotheses when `psi` is not valid.
- We CANNOT apply `ih_psi` because `not (valid psi)` is the wrong polarity.

The proof must find a contradiction WITHOUT using the induction hypotheses in Case B. This is a structural constraint that severely limits options.

### 3. The Proof Strategy Must Build a Countermodel to (psi -> chi)

The available path to `False`:

1. We have `h_valid : valid (psi.imp chi)`.
2. `valid` means: for ALL D, F, M, Omega (shift-closed), tau in Omega, t: `truth_at M Omega tau t psi -> truth_at M Omega tau t chi`.
3. To get False, we need to CONSTRUCT a specific (D, F, M, Omega, tau, t) where `truth_at ... psi` holds but `truth_at ... chi` does not.
4. We then apply `h_valid` to get `truth_at ... chi`, contradicting our construction.

This means we need:
- (A) A model where `truth_at ... psi` holds, which we get from `psi in w.formulas` via a FORWARD truth bridge.
- (B) A model where `truth_at ... chi` does NOT hold, which we get from `chi not in w.formulas` via a BACKWARD truth bridge (MCS non-membership implies truth failure).

Both (A) and (B) must be in the SAME model (same D, F, M, Omega, tau, t).

### 4. The `fragment_truth_iff` Only Works for `temporalFree` Formulas

The existing `fragment_truth_iff` gives a bidirectional bridge but ONLY for temporal-free formulas (no G, H, U, S). When `psi` or `chi` contains G or H:

- **Forward direction** (membership -> truth): On constant histories, `G(alpha) in w` gives `alpha in v` for all `v >= w` (by G_iff_mcs), but `truth_at ... G(alpha)` requires `truth_at ... alpha` at all future times `s >= t`. On a constant history (all times map to w), this collapses to `truth_at ... alpha` at w -- so the forward direction works because `G(alpha) in w` implies `alpha in w` (by BX1: G -> phi), and then the recursive forward bridge gives `truth_at ... alpha`.

- **Backward direction** (truth -> membership): On a constant history, `truth_at ... G(alpha)` at time t means `for all s >= t, truth_at ... alpha` at s. Since the history is constant (all states = w), this just means `truth_at ... alpha` at w for all future times -- but since the state is always w, this is the SAME condition as `truth_at ... alpha` at t. The backward bridge then gives `alpha in w`, NOT `G(alpha) in w`. Getting `G(alpha) in w` requires `alpha in v` for ALL bx_le successors v, not just w.

This is the EXACT gap documented in the sorry comment. The constant history collapses the distinction between `phi` and `G(phi)` semantically, making it impossible to distinguish them for the backward bridge.

### 5. The Fundamental Mathematical Question: Is the Theorem TRUE?

**Yes, the theorem is true.** The `usf_completeness` theorem states: for `untilSinceFree phi`, `valid phi -> Nonempty (DerivationTree [] phi)`. This IS true because:

1. The BX axiom system (with S5 modal + BX temporal axioms) is known to be complete for all linear temporal orders (Burgess 1984, Xu 1988).
2. The Until/Since-free fragment is a sub-fragment, so completeness of the full system implies completeness of the fragment.
3. Soundness is proved sorry-free, confirming the axiom system is consistent.

The issue is purely TECHNICAL -- the proof strategy in the imp case is flawed, not the mathematical claim.

### 6. Analysis of What Went Wrong in Previous Attempts

**Round 1**: Built `fragment_completeness` for `temporalFree` formulas (no G/H). This WORKS because constant histories give a perfect bidirectional truth bridge when there are no temporal operators. The imp case uses the bridge on both sub-formulas, and since both are temporal-free, both directions work.

**Round 2**: Extended to `usf_completeness` by handling G, H, box at the top level via proof-theoretic reduction (`valid G(phi) -> valid phi -> derivable phi -> derivable G(phi)`). This works for outermost G/H/box. But it FAILS when G/H appear INSIDE an implication, because the imp case needs the truth bridge on sub-formulas that may contain G/H.

**Pattern of failure**: Each attempt works at the OUTERMOST level but fails when temporal operators are nested INSIDE implications. The root cause is the same in both rounds: the constant-history canonical model cannot faithfully represent the difference between `phi` and `G(phi)` for the backward truth bridge.

### 7. The ShiftClosed Constraint Analysis

`ShiftClosed Omega` means: `for all sigma in Omega, for all delta, time_shift sigma delta in Omega`.

For the `modal_omega w` construction currently used:
- `modal_omega w = { sigma | exists v, bx_modal_equiv w v and sigma = constant_history v }`
- `modal_omega_shift_closed` is proved because `time_shift (constant_history v) delta = constant_history v` (constant histories are shift-invariant).

This means ALL histories in `modal_omega w` are constant. The Omega never contains non-constant histories. This is by design -- it makes ShiftClosed trivial -- but it means the model collapses all temporal structure.

**Could we use `Set.univ` as Omega?** Yes, `Set.univ` is trivially shift-closed (`univ_shift_closed` exists in the codebase). But box then quantifies over ALL histories, which is too strong -- we lose control of what box means. The box case in `fragment_truth_iff` relies on `modal_omega` to match box with modal equivalence.

**Could we use non-constant histories?** This is the right direction, but requires building histories that visit MULTIPLE BXPoints and proving the truth bridge on those histories. The two-point history approach from the plan was supposed to do this but was never implemented for the imp case.

## Identified Risks and Blockers

### Risk 1: The Proof-Theoretic Reduction Strategy Is FUNDAMENTALLY Limited (CRITICAL)

The current strategy of reducing `valid G(phi) -> valid phi` only peels off the outermost operator. It cannot handle:
- `valid (G(alpha) -> beta)` (G inside imp)
- `valid (alpha -> G(beta))` (G inside imp)
- `valid (G(alpha) -> G(beta))` (G in both positions)

The IH in the imp case gives `ih_chi : untilSinceFree chi -> valid chi -> Nonempty (DerivationTree [] chi)`, but Case B has `not (valid psi)`, so we CANNOT derive `valid chi`. The reduction approach is a dead end for imp Case B.

### Risk 2: Non-Constant History Construction Is Complex

Building non-constant histories requires:
1. Defining a `WorldHistory` that maps different times to different BXPoints
2. Proving `respects_task` for all time transitions (the permissive task_rel helps here)
3. Building an appropriate Omega that is shift-closed
4. Proving the truth bridge on non-constant histories for ALL formula constructors (not just the top-level one)

This is essentially building the FULL canonical model that was avoided by the fragment approach. It is 4-8 hours of work minimum.

### Risk 3: The Full Truth Lemma on Non-Constant Histories May Not Hold

Even with non-constant histories, the bidirectional truth bridge for G requires:
- Forward: `G(phi) in w` implies `truth_at ... G(phi)` at time t where state is w.
  This means `for all s >= t, truth_at ... phi` at s. If s maps to some BXPoint v with `bx_le w v`, we need `phi in v` (which follows from G_iff_mcs) AND the forward bridge at v.
- Backward: `truth_at ... G(phi)` at time t implies `G(phi) in w`.
  This means `for all s >= t, truth_at ... phi` at s. By backward bridge at each s, we get `phi in states(s)`. For `G(phi) in w`, we need `phi in v` for ALL `v >= w`. But the history only visits FINITELY MANY (or at most countably many) BXPoints. If there are bx_le successors of w that the history never visits, we cannot conclude `G(phi) in w`.

This is the SURJECTIVITY PROBLEM identified in prior research. A single history cannot visit all bx_le-successors of w. This is why the full canonical model approach uses the ENTIRE set of BXPoints as states with ALL histories, not just a single history.

### Risk 4: The Problem May Require a Different Proof Architecture

The sorry may not be closeable within the current `usf_completeness` proof structure. The induction on formula structure with case split on validity of sub-formulas may be the wrong approach for the imp case. Alternative architectures:

1. **Direct contrapositive on the full formula**: Instead of induction, use a single global canonical model for the full formula. This is the standard textbook approach.
2. **Strong induction with countermodel construction**: For each sub-formula, build a countermodel (not a truth bridge). The imp case would combine countermodels.
3. **Proof-theoretic approach**: Avoid semantics entirely. Show that `not (derivable (psi -> chi))` and `valid (psi -> chi)` lead to contradiction via proof search or cut-elimination arguments.

## Gap Analysis

### Gap 1: Two-Point History Never Implemented

The plan (Phase 2) specified `bxpoint_two_history` for building histories that visit two BXPoints. This was never defined. The execution summary confirms only constant histories were used. The two-point history was supposed to solve the G/H countermodel case, but it was only planned for the G/H TOP-LEVEL case, not for G/H INSIDE imp.

### Gap 2: Per-Formula Countermodel Approach Not Fully Explored

The plan said "tailored per-formula countermodel" but Round 2 abandoned this for proof-theoretic reduction. The countermodel approach for imp Case B would need:
- Given MCS w with psi in w, chi not in w
- Build a model where psi is true and chi is false at some point
- For the FORWARD bridge (psi in w -> truth_at psi): works for temporal-free psi, and for psi with G/H if the history visits all relevant successors
- For the BACKWARD bridge (chi not in w -> not truth_at chi): this is the hard direction

The backward direction for chi not in w -> not truth_at chi can be rephrased as its contrapositive: truth_at chi -> chi in w. This is what fails for G/H on constant histories.

### Gap 3: The `fragment_completeness` Already Solves the Problem for temporalFree Sub-Formulas

There is an unexplored middle ground: when BOTH psi and chi are temporal-free, the imp case should work via `fragment_truth_iff` directly (both directions work). The sorry only arises when psi or chi contains G/H.

Could we split `usf_completeness` into finer cases:
- If phi is temporal-free: delegate to `fragment_completeness`
- If phi = G(psi): reduction
- If phi = H(psi): reduction
- If phi = box(psi): reduction
- If phi = psi -> chi: case split on whether psi and chi are temporal-free or not

This would reduce the sorry to the specific case where phi = psi -> chi and at least one of psi/chi contains G/H. But it doesn't eliminate it.

### Gap 4: Alternative Proof via `not (valid psi)` Decomposition

We have `not (valid psi)`. This means there EXISTS a specific model (D0, F0, M0, Omega0, tau0, t0) where `not (truth_at M0 Omega0 tau0 t0 psi)`. But this countermodel for psi is in a DIFFERENT model than our canonical model. We cannot directly combine them.

However, there is a subtlety: `h_valid : valid (psi.imp chi)` is universal over ALL models. So it applies to the countermodel for psi too. In that countermodel, `truth_at ... (psi.imp chi)` holds, which means `truth_at ... psi -> truth_at ... chi`. Since `not (truth_at ... psi)`, the implication holds vacuously. This gives us no information about chi.

Could we combine the countermodel for psi with the canonical model? The `valid` quantifier ranges over ALL models, so we'd need a SINGLE model where psi is true and chi is false. The canonical model gives psi true (forward bridge from psi in w) but we can't show chi false (backward bridge fails). The countermodel for psi gives psi false, which is useless.

This line of reasoning confirms that the backward truth bridge for chi is the core obstacle.

### Gap 5: Possibility of a Purely Proof-Theoretic Argument

Instead of building a semantic countermodel, could we derive `psi -> chi` proof-theoretically?

We have: `not (valid psi)` and `valid (psi -> chi)`.

Could we derive `psi -> chi` from `not (valid psi)` alone? In classical logic, if `psi` is not a tautology, that does not mean `not psi` is a tautology. So we cannot derive `not psi`, and hence cannot derive `psi -> chi` by ex falso.

But we DO have the IH: `ih_psi : untilSinceFree psi -> valid psi -> Nonempty (DerivationTree [] psi)`. The contrapositive gives: `not (Nonempty (DerivationTree [] psi)) -> not (valid psi)` -- but this is the WRONG direction. We have `not (valid psi)` and would need `not (Nonempty (DerivationTree [] psi))`, which is not available.

In fact, `ih_psi` is irrelevant in Case B because we have `not (valid psi)`, and `ih_psi` needs `valid psi`.

## Confidence Assessment

| Aspect | Assessment | Confidence |
|--------|-----------|------------|
| The theorem is mathematically true | YES | 95% |
| The issue is purely technical (encoding) | YES | 90% |
| The current proof structure can be fixed | UNCERTAIN | 40% |
| A non-constant history approach would work | LIKELY | 70% |
| The sorry is closeable within 8 hours | UNCERTAIN | 50% |
| The sorry requires architectural change | LIKELY | 75% |

### Overall: The sorry is closeable but likely requires a different proof architecture for the imp case.

The proof-theoretic reduction (peel off outermost operator) is the wrong tool for the imp case. A semantic countermodel construction (build a model where psi is true and chi is false) is the right approach, but requires the full bidirectional truth bridge on non-constant histories.

## Recommendations

### 1. IMMEDIATE: Verify fragment_truth_iff handles imp when sub-formulas are temporal-free

The existing `fragment_truth_iff` already proves the imp case when both sub-formulas are temporal-free. Confirm that `usf_completeness` for `psi.imp chi` where both psi and chi happen to be temporal-free delegates correctly to `fragment_completeness`. This may already work implicitly via the structural induction.

### 2. SHORT-TERM: Build full bidirectional truth lemma on the canonical model

Rather than per-formula countermodels, build a SINGLE canonical model using:
- Non-constant histories that map integers to BXPoints along bx_le chains
- An Omega that contains enough histories to represent all bx_le-successors
- A full bidirectional truth bridge for all Until/Since-free formulas

This is the standard approach in Burgess/Goldblatt. The `fragment_truth_iff` for temporal-free formulas and `G_iff_mcs`/`H_iff_mcs`/`box_iff_mcs` at the MCS level are already proved -- the missing piece is connecting MCS-level truth to semantic `truth_at` on non-constant histories.

### 3. MEDIUM-TERM: Consider restructuring usf_completeness

Instead of induction on formula structure with a case split on validity:

```
usf_completeness phi h_usf h_valid := by
  by_contra h_not_deriv
  -- Extend {neg phi} to MCS w
  -- Build canonical model with non-constant histories
  -- Prove full truth lemma (by induction on phi) on canonical model
  -- Get truth_at ... phi from h_valid
  -- Get phi in w from backward truth bridge
  -- Contradiction with phi not in w
```

This avoids the problematic imp Case B entirely because the truth bridge is proved uniformly for all formulas, not case-by-case during the completeness induction.

### 4. DO NOT PURSUE

- Further proof-theoretic reduction attempts for imp Case B -- the approach is structurally limited
- `Set.univ` as Omega -- loses control of box semantics
- Combining countermodels from different type universes -- impossible due to type quantification in `valid`
