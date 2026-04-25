# Handoff: Task 107 Phases 5-7 Analysis

Session: sess_1777153147_aeaa28
Date: 2026-04-25

## Summary

Deep analysis of the 4 remaining sorry sites revealed fundamental architectural issues that require restructuring before the sorries can be closed. This document records the analysis and outlines the correct approach.

## Current State

- Build passes (1097 jobs)
- 4 active sorry sites (unchanged from start):
  1. `CounterexampleElimination.lean:329` -- C4 hard sub-case (G(gamma) in f(x) AND H(gamma) in f(y))
  2. `CounterexampleElimination.lean:439` -- C4' hard sub-case (mirror)
  3. `ChronicleToCountermodel.lean:964` -- restricted_fuc Until
  4. `ChronicleToCountermodel.lean:968` -- restricted_fuc Since
- No files modified (incomplete edits reverted)

## Key Findings

### Finding 1: Omega Chain Does Not Track g

The Chronicle structure has a `g : Rat -> Rat -> Set Formula` field, but:
- `singleton_chronicle` sets `g := fun _ _ => emptyset`
- Every elimination function passes `chi.g` unchanged
- The omega chain's g field is always empty

This means the plan's Phase 5 approach (defining limit_g from omega chain g values) is a dead end. The interval function g is never populated.

### Finding 2: C4 Hard Sub-Case is Contradictory at the Limit

The hard sub-case (G(xi) in f(x) AND H(xi) in f(y)):
- From G(xi) in f(x), xi in f(x), and BX2 with phi=top, chi=xi, psi=eta:
  `(top -> xi) AND G(top -> xi) -> ((top U eta) -> (xi U eta))` is in f(x)
- Contrapositive + neg(xi U eta) in f(x) gives: neg(top U eta) in f(x)
- BX12 contrapositive: neg(F(eta)) in f(x), i.e., G(neg eta) in f(x)
- forward_G: neg eta in f(y). But eta in f(y). Contradiction.

**However**, this uses `limit_forward_G`, creating a circular dependency.

### Finding 3: limit_forward_G Proof is Circular via C4

The current proof of `limit_forward_G` uses `limit_satisfies_c4` with gamma=top, delta=phi.neg. But:
- gamma=top means G(top) in f(x) is always true (theorem)
- The C4 hard sub-case is ALWAYS triggered
- The hard sub-case contradiction uses forward_G itself

So `limit_forward_G` and `limit_satisfies_c4` have a mutual dependency through the hard sub-case.

### Finding 4: temp_4 Enables G-Propagation Chaining

BX axiom `temp_4: G(phi) -> G(G(phi))` means:
- From G(phi) in f(x), get G(G(phi)) in f(x)
- G(phi) in g_content(f(x))
- g_propagation_witness gives MCS D with phi in D AND g_content(f(x)) subset D
- Therefore G(phi) in D (from g_content)
- So the G-propagation mechanism produces points with BOTH phi AND G(phi)

This breaks the chaining problem: inserted intermediate points preserve G(phi).

### Finding 5: U(phi,psi) -> phi is Not BX-Derivable

Under the A2 guard convention (strict witness, half-open guard [t,s)):
- BX9 gives U(phi,psi) -> phi OR psi (not phi alone)
- U(phi,psi) AND psi AND neg phi is not BX-inconsistent
- The configuration CAN occur in an MCS
- But semantically, the guard [t,s) forces phi(t)
- Report 10 (task 109) identified this as a gap in the BX axiom system

This blocks the restricted_fuc proof at the base point r = t.

## Correct Approach

### Step 1: Reprove limit_forward_G Using Omega Chain Directly

Instead of the C4-based proof, use the omega chain's g_prop_forward mechanism:

1. G(phi) in f(x) and phi not in f(y) (by contradiction)
2. At finite stage N with x,y in dom_N: between x and y are points p0=x < p1 < ... < pk=y
3. The g_prop counterexample for the first adjacent pair (pi, pi+1) where phi fails is processed
4. By temp_4: G(G(phi)) in f(x), so G(phi) in g_content(f(x))
5. The g_propagation_witness at the inserted point z has g_content(f(x)) subset f(z), so G(phi) in f(z)
6. The argument chains: G(phi) persists at each inserted point
7. Eventually all adjacent pairs between x and y have phi, by induction on the finite domain

**Key insight**: temp_4 makes the g_prop mechanism chain properly.

The proof should use `omega_chain_g_prop_witness` (or similar) to show that at the limit, G(phi) at x forces phi at all y > x.

### Step 2: Prove limit_satisfies_c4 Using forward_G for Hard Case

Once forward_G is proved independently (without C4), reprove limit_satisfies_c4:
- Non-hard sub-cases: use omega chain C4 mechanism (unchanged)
- Hard sub-case: derive contradiction using BX2+BX12+forward_G

### Step 3: Close restricted_fuc

For U(phi,psi) in f(t) -> exists s > t, psi in f(s) AND guard phi on [t,s):

**Endpoint**: C5 weak gives s > t with psi in f(s)

**Guard at t < r < s**: The omega chain C5 mechanism (line 728-730 of CounterexampleElimination.lean) checks the full guard at domain points. Strengthen EliminationResult.c5_forward_witness to include guard info. In the "not actual counterexample" case, the guard is available from push_neg. In the "actual counterexample" case, the new point is beyond all domain, so the guard is vacuously true at stage n+1.

**Guard at r = t**: From U(phi,psi), BX9 gives phi OR psi at t.
- If phi in f(t): done.
- If psi in f(t) but phi not in f(t): this case may require adding U(phi,psi)->phi as a new axiom (BX9s). OR change the restricted_fuc guard from t<=r to t<r and adjust the truth lemma accordingly. OR prove this case is actually impossible from the construction (unlikely given Finding 5).

### Step 4: Close C4' Mirror

Mirror of Step 2 for the Since direction.

## Files Relevant

- `ChronicleConstruction.lean` (line 979): limit_forward_G -- needs reproof
- `ChronicleConstruction.lean` (line 734): limit_satisfies_c4 -- needs reproof after forward_G
- `CounterexampleElimination.lean` (line 329, 439): C4/C4' hard sub-cases -- closed by limit-level approach
- `ChronicleToCountermodel.lean` (line 964, 968): restricted_fuc -- needs Step 3
- `PointInsertion.lean` (line 496): G_implies_F_mcs -- useful helper
- `PointInsertion.lean` (line 582): g_propagation_witness -- key for forward_G reproof
- `ProofSystem/Axioms.lean` (line 112): temp_4 axiom -- key for G-chaining

## Estimated Effort

- Step 1 (forward_G reproof): 3-4 hours (most complex, requires induction on finite domain)
- Step 2 (C4 with forward_G): 1-2 hours (straightforward given forward_G)
- Step 3 (restricted_fuc): 2-3 hours (strengthening C5 witness + base point handling)
- Step 4 (C4' mirror): 1 hour

Total: 7-10 hours remaining.
