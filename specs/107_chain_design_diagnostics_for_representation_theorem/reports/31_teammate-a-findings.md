# Teammate A Findings: Can BUC Be Proved Without limit_satisfies_c4?

**Task**: 107 - Chain design diagnostics for representation theorem
**Focus**: Whether backward Until coherence (BUC) can bypass the C4 dependency
**Date**: 2026-04-26

## Executive Summary

**Answer: No, BUC cannot be proved directly (without contradiction via C4) in the current architecture.** The fundamental obstacle is that the domain is dense (rationals), and no BX axiom provides a way to "pull Until backward across a dense interval" without appealing to the negation/C4 contrapositive argument. However, BUC CAN be proved without the *sorry-tainted* `limit_satisfies_c4` if C4 elimination is first made sorry-free --- and the analysis reveals a promising path to do this.

## Finding 1: Burgess's Claim 2.11 Uses C4 Only for the Backward Direction of Until

Burgess's truth lemma (Claim 2.11) for `alpha = U(beta, gamma)` has two directions:

**Forward** (`alpha in f(x) => x in V(alpha)`): Uses C5a to get witness y with gamma in f(y) and beta in g(x,y). Then C3 gives beta in f(z) for intermediate z. Induction hypothesis lifts to semantic truth. **No C4 used.**

**Backward** (`alpha not in f(x) => x not in V(alpha)`): Since alpha not in f(x), we have neg(alpha) in f(x). For any y > x with gamma in f(y) (by IH from y in V(gamma)), C4a gives z with x < z < y and neg(beta) in f(z). By IH, z not in V(beta). So x not in V(alpha). **C4 is essential here.**

The handoff claim that "C4 is only used for the backward direction of the NEGATION case" is **confirmed**. More precisely: C4 is used to show that neg(U(beta,gamma)) in f(x) implies x not in V(U(beta,gamma)). This is exactly the contrapositive of BUC.

## Finding 2: Direct Proof via BX Axioms Is Not Possible on Dense Domains

The question asks whether we can prove BUC directly: from the semantic pattern (psi at s, phi at all r in [t,s)), derive untl(phi,psi) at t using BX axioms alone.

**Why this fails on dense domains:**

The BX axioms operate formula-by-formula within single MCSs. The relevant axioms are:
- **BX5** (self_accum): `(phi U psi) -> ((phi /\ (phi U psi)) U psi)` --- enriches the guard but STARTS from phi U psi already being present
- **BX6** (absorb): `((phi /\ (phi U psi)) U psi) -> (phi U psi)` --- the reverse direction, could help build phi U psi
- **BX9** (until_elim): `(phi U psi) -> (phi \/ psi)` --- eliminates, doesn't construct
- **BX12** (F_until_equiv): `F(psi) <-> (top U psi)` --- only gives top U psi from F(psi)

**The gap**: To use BX6 to construct `phi U psi` at t, we would need `(phi /\ (phi U psi)) U psi` at t. But this requires `phi U psi` at intermediate points --- exactly what we're trying to prove. The axioms are designed for DEDUCTION within a single MCS, not for synthesizing membership from a semantic pattern across multiple points.

On a **discrete** domain (integers), one could do induction: at the immediate predecessor of s, if psi is at s and phi is at the predecessor, then phi U psi holds at the predecessor (by the semantics of Until with adjacent witness). Then induct backward. This is exactly `backward_until_from_step` in `UntilSinceCoherence.lean`. But this requires a **step transfer** property:

```
phi U psi in mcs(r+1) /\ phi in mcs(r) => phi U psi in mcs(r)
```

The step transfer IS the hard part. In the boneyard `OracleCoherence.lean` (line 458), this step transfer is sorry'd, confirming it cannot be derived from BX axioms alone for arbitrary chains.

**On dense domains** (rationals), there is no "immediate predecessor", so the induction approach breaks down entirely.

## Finding 3: The Contradiction Argument IS the Correct Approach

Burgess proves the backward direction of the truth lemma by contradiction, and this is not an artifact of his proof style --- it is the mathematically natural approach. The key insight:

1. **Assume** neg(untl(phi,psi)) in f(t) (contradiction hypothesis)
2. **Given** psi in f(s) for some s > t, and phi in f(r) for all r in [t,s)
3. **By C4**: there exists z in (t,s) with phi.neg in f(z)
4. **But** z in [t,s) so phi in f(z) by the guard hypothesis
5. **Contradiction** with MCS consistency

This argument is elegant and short. The question is whether the C4 it depends on can be made sorry-free.

## Finding 4: The Sorry in C4 Is Localized to a Single Sub-Case

The sorry sites in `CounterexampleElimination.lean` (lines 332, 448) are in the **hard sub-case** of C4 elimination:

- gamma in f(x) AND gamma in f(y) (guard formula at both endpoints)
- G(gamma) in f(x) AND H(gamma) in f(y) (gamma persists in both directions)

The resolution requires:
1. `BurgessR3Maximal(f(x), g(x,y), f(y))` (from chronicle invariant c2')
2. `gamma not in g(x,y)` (from `burgessR3_gamma_not_in_B`, proved sorry-free)
3. Construct D containing gamma.neg via Lindenbaum extension
4. Set f(z) = D for new intermediate point z

Step 1 is the blocker: the current `limit_g` is a **placeholder** (line 867 of ChronicleConstruction.lean):
```lean
noncomputable def limit_g ... := fun x _y => deductiveClosure (g_content (limit_f A h_mcs x))
```
This ignores y entirely and does NOT satisfy the true three-way C3 or BurgessR3Maximal.

## Finding 5: The Correct limit_g Would Break the Cycle

The correct `limit_g` should be:
```
limit_g(x,y) = omega_chain_g(n₀, x, y) where n₀ = first stage where both x,y in dom
```

With this definition:
- **C3 at the limit** follows from C3 at finite stages (by f-agreement and g-agreement)
- **BurgessR3Maximal at the limit** follows from BurgessR3Maximal at finite stages

But this requires the finite-stage construction to track g-values properly --- which is exactly "Phase 3" from the handoff, described as "populating g-values in elimination functions."

## Finding 6: Induction on Domain Points Between t and s Cannot Work

Research direction 3 asked about induction on the number of domain points between t and s. This fails because:

1. The domain is **dense** (rationals) and **countably infinite** at the limit
2. Between any two points, there are infinitely many domain points (by `limit_dom_dense`)
3. There is no well-ordering of intermediate points that enables induction

At finite stages, the domain IS finite, so induction works (this is how `omega_chain_c4_witness` works --- it finds the specific finite step where the counterexample is processed). But BUC is a property of the *limit* structure, where the domain is dense.

## Finding 7: Burgess Proves BUC/FUC as Part of the Truth Lemma (Claim 2.11)

Research direction 5 asked whether Burgess proves BUC and FUC separately or as part of the truth lemma.

**Answer**: They are part of the truth lemma (Claim 2.11), proved by formula induction on complexity of alpha. The Until case (`alpha = U(beta, gamma)`) establishes both:
- **FUC** (forward): from `U(beta,gamma) in f(x)`, uses C5a + C3 + IH
- **BUC** (backward): from `neg(U(beta,gamma)) in f(x)`, uses C4a + IH

The dependency structure IS: truth lemma depends on both C4 and C5 (and C3 for the g-values). In the codebase, BUC and FUC are factored out as separate theorems (`cantor_bfmcs_restricted_buc`, `cantor_bfmcs_restricted_fuc`) rather than being proved inline during a formula induction. This factoring is valid because BUC/FUC don't need the induction hypothesis --- they work at the level of f-membership directly.

## Finding 8: The limit_g Intersection Approach (Direction 4) Is Viable But Redundant

Research direction 4 asked about `limit_g(x,y) = intersection of limit_f(w) for x < w < y`. This would satisfy:
- C3: `g(x,z) = g(x,y) intersect f(y) intersect g(y,z)` --- would need proof
- BurgessR3 at limit --- would need proof from BUC... creating a chicken-and-egg problem

The intersection approach creates the same circular dependency: to prove BurgessR3 for this limit_g, you need BUC, and BUC uses C4 which needs BurgessR3 for the g-values. This is Option C from the handoff, and it is correctly identified as BLOCKED.

## Recommended Resolution Path

The findings point clearly to one path:

1. **Fix the finite-stage g-values** (Phase 3 from handoff): Make `eliminate_potential_counterexample` produce proper g-values at each step, ensuring BurgessR3Maximal at adjacent pairs.

2. **Define limit_g correctly**: `limit_g(x,y) = omega_chain_g(n₀, x, y)` where n₀ is the first stage where both x,y are in the domain.

3. **Prove C4 sorry-free**: With correct g-values, the hard sub-case resolves via `burgessR3_gamma_not_in_B` (already sorry-free) + Lindenbaum extension.

4. **BUC then follows automatically**: The existing BUC proof via contradiction + `limit_satisfies_c4` becomes sorry-free.

5. **FUC follows from C5 + correct limit_g**: With true C3, the guard at intermediate points is obtained via `c3_interval_subset_point`.

**Alternative (Option B from handoff)**: Prove BurgessR3Maximal existence without seeds, via a direct Zorn argument on `{B : DCS | burgessR3(A, B, C)}`. This avoids modifying finite-stage elimination functions but requires showing this set is non-empty (which is the kernel-set problem from the handoff).

## Appendix: Search Queries and Key File Locations

### Codebase Files Examined
- `CounterexampleElimination.lean` (sorry sites at lines 332, 448)
- `ChronicleConstruction.lean` (limit_satisfies_c4 at line 763, limit_g placeholder at line 867)
- `ChronicleToCountermodel.lean` (BUC at line 495, uses limit_satisfies_c4 at line 525)
- `RRelation.lean` (r-relation definition, BX axiom lemmas)
- `Axioms.lean` (BX5, BX6, BX7, BX9, BX10, BX12)
- `UntilSinceCoherence.lean` (backward_until_from_step, requires step transfer)
- `OracleCoherence.lean` (boneyard: sorry'd step transfer at line 458)

### Burgess Reference
- Claim 2.11 uses C4a for the backward direction of Until truth lemma
- Lemma 2.6 constructs intermediate point via R(A,B,C) + delta not in B
- C4 elimination (Lemma 2.9) works by induction on intermediate points in FINITE domain
