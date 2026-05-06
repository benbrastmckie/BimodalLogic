# Guard Exposure for FUC/FSC -- Deep Analysis Handoff

## Status
**BLOCKED** -- FUC (Forward Until Coherence) is the fundamental open problem in the BX completeness theorem. It is sorry'd in ALL pathways:
- `ChronicleToCountermodel.lean:634,638` (chronicle pathway, 2 sorries)
- `RootScopedChain.lean:198` (legacy pathway, 1 sorry)
- `Boneyard/QuasimodelOracle/OracleCoherence.lean:494` (boneyard, 2 sorries)
- `Boneyard/DefectDirectedChain/RootScopedChain.lean:1183` (boneyard, 1 sorry)

## The FUC Goal

Given `U(phi, psi) in fam.mcs(t)`, produce `s > t` with:
- `psi in fam.mcs(s)` (endpoint: event at witness)
- `phi in fam.mcs(r)` for all `t < r < s` (guard at all intermediate rationals)

The endpoint is available from `limit_satisfies_c5_weak`. The guard is the unsolved part.

## What Was Attempted

### 1. Pure Limit-Level Proof by Contradiction
Tried: assume guard fails at some w between x and y, derive contradiction.
**Result**: FAILED. Having xi.neg at w and U(xi,eta) at x does not yield a contradiction because:
- C4 requires neg(U(xi,eta)) at x, but we have the positive
- BX5 self-accumulation doesn't prevent guard failure at w (strict open guard: guard is for intermediate points, not the current point)
- P(U(xi,eta)) at w (from connect_future + forward_G) gives U(xi,eta) at some v < w, but this doesn't force xi at w

### 2. Pure Axiomatic Approach
Tried: use BX5 (self-accumulation), BX7 (linearity), BX14 (separation) to find a guard-safe witness.
**Result**: FAILED. These axioms can modify the guard/event formulas but cannot establish the guard at intermediate points. The FUC direction is exactly the completeness direction for Until, which requires construction-level arguments.

### 3. Strengthening EliminationResult
Tried: add guard field `forall z in val.dom, pc.x < z -> z < y -> xi in val.f z` to c5_forward_witness.
**Result**: PARTIALLY WORKS at finite stage but INSUFFICIENT for limit. The finite-stage guard holds at current domain points (vacuously in n=0 case, from push_neg in not-actual case). However, points added at later stages are NOT covered by the finite-stage guard. The limit_g is defined as intersection over ALL limit_dom intermediate points, including those added after the C5 elimination.

### 4. Using Finite-Stage g Function
Tried: show xi in finite g(x,y) at the elimination stage, then use C3 to propagate to later points.
**Result**: FAILED for two reasons:
- C3 is NOT maintained as an invariant at finite stages (only C0 and C2' are tracked)
- xi is NOT necessarily in B (the interval set from lemma_2_4), as shown in analysis below

## Root Cause: Guard Not in Interval Set

Burgess Lemma 2.4 claims: given U(gamma, beta) in A, exists B, C with **beta in B** (guard in interval set). In our formalization:

- `lemma_2_4` gives `BurgessR3Maximal(f(x), B, C)` with `eta in C` (event at endpoint)
- The B is constructed via `burgessR3Maximal_from_g_content_sub` which seeds with `{top}` via Zorn extension
- To have `xi in B`, we need `burgessR(f(x), xi, C)`: for all gamma in C, `U(xi, gamma) in f(x)`
- This holds for gamma in `{eta} union g_content(f(x))` (via BX3 right_mono_until + G reasoning)
- But C is a Lindenbaum extension that may contain gamma outside this set, breaking the requirement

## Correct Solution: Joint B-C Construction

Burgess's original proof constructs B and C simultaneously. The correct approach requires:

### Option A: Modify lemma_2_4 + RRelation.lean

1. Define `S_xi = {gamma | U(xi, gamma) in A}` -- the "xi-reachable" set
2. Show S_xi is consistent, deductively closed (DCS)
3. Show `{eta} union g_content(A) subset S_xi` (proved via BX3)
4. Construct C as Lindenbaum extension of S_xi (ensures C subset-of-closure of S_xi)
   - Problem: C may contain gamma outside S_xi since Lindenbaum adds arbitrary formulas
5. Need: construct C so that for all gamma in C, U(xi, gamma) in A
   - This requires a SIMULTANEOUS construction: choose each Lindenbaum step to maintain burgessR(A, xi, current_set)
   - When extending with psi: if U(xi, psi) in A, add psi; otherwise add psi.neg (if U(xi, psi.neg) in A)
   - Problem: both U(xi, psi) and U(xi, psi.neg) might NOT be in A

### Option B: Lindenbaum with R-Compatibility (Recommended)

Create a new Lindenbaum variant `lindenbaum_r_compatible` that:
1. Takes a seed set S and a "compatibility predicate" P(gamma) = [U(xi, gamma) in A]
2. At each step, when both psi and psi.neg are consistent with current set:
   - If P(psi): add psi
   - Elif P(psi.neg): add psi.neg
   - Else: add either (both are compatible since neither has a U-witness)
3. The resulting MCS C has: for all gamma in C where P(gamma) is relevant, P(gamma) holds

**Key insight**: When NEITHER U(xi, psi) nor U(xi, psi.neg) is in A, then neg(U(xi, psi)) AND neg(U(xi, psi.neg)) are both in A. In this case, adding either psi or psi.neg to C is fine because xi won't be used as a seed for B anyway for this gamma (the Until fails regardless).

Actually this doesn't quite work. The issue is more subtle: xi in B requires burgessR for ALL gamma in C, not just some.

### Option C: Use the Xu/Reynolds Approach

Xu's thesis (1988) and Reynolds (2003) handle this differently:
- They work with a "cluster" construction where the interval sets are built from explicit subformula closure
- The guard membership follows from the construction being restricted to a finite subformula set
- This avoids the Lindenbaum compatibility issue

### Option D: Direct Limit-Level Proof via Stronger Omega Chain Invariant

Add a new invariant to the omega chain that tracks "accumulated guard witnesses":
1. Define: `omega_chain_c5_guard(n) = for all (x, xi, eta, y) where y is a C5 witness from stage <= n: for all w in dom(n) between x and y, xi in f_n(w)`
2. Show this is maintained across elimination steps
3. At the limit: the guard holds at all limit_dom intermediate points

This requires proving that EVERY elimination step preserves the guard for previously-established C5 witnesses. When a new point w is inserted between x and y:
- If w is from density: the splitting lemma determines f(w), and the BurgessR3 structure may or may not place xi in f(w)
- If w is from C4: similar issue
- If w is from C5: the new witness may be between x and y

This option requires significant new invariant tracking in the omega chain.

## Recommended Path Forward

**Option D** (Direct Limit-Level Proof) is the most practical, as it:
1. Doesn't require modifying the Zorn/Lindenbaum infrastructure (RRelation.lean)
2. Doesn't require modifying lemma_2_4
3. Works within the existing omega chain framework
4. Requires adding an invariant to the omega chain (moderate complexity)

### Implementation Steps for Option D:

1. Add to ChronicleTypes.lean: a record type `C5GuardTracker` that maps (x, xi, eta) to witness y
2. Add to the omega chain: a `c5_guards` field tracking established C5 witnesses with guards
3. In eliminate_potential_counterexample: when a new C5 witness is established, add to tracker; when a point is inserted between an existing (x, y) pair, verify the guard
4. Prove: at the limit, for tracked (x, xi, eta, y), the guard xi holds at all intermediate limit_dom points
5. Use limit_satisfies_c5_strong (based on guard tracker) to close FUC/FSC

### Estimated Effort
- Option D: 200-400 lines of new Lean code, primarily in ChronicleConstruction.lean
- The key difficulty: proving the guard is preserved during density/C4/C5 elimination steps when new points are inserted between existing C5 witness pairs

## Files Involved

| File | Role | Modification |
|------|------|-------------|
| ChronicleTypes.lean | Type definitions | Add C5GuardTracker type (if using Option D) |
| CounterexampleElimination.lean | Finite elimination | Strengthen c5_forward_witness (all options) |
| ChronicleConstruction.lean | Omega chain | Add guard invariant + limit_satisfies_c5_strong |
| ChronicleToCountermodel.lean | Integration | Close FUC/FSC sorry using limit_satisfies_c5_strong |
| RRelation.lean | Zorn/R3 | Modify only for Options A/B |
| PointInsertion.lean | lemma_2_4 | Modify only for Options A/B |

## Current Sorry Count
- ChronicleToCountermodel.lean: 2 sorry (lines 634, 638) -- FUC/FSC
- Build passes with these 2 sorries
