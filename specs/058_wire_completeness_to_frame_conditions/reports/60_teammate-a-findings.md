# Teammate A: Survey of Attempted Approaches

## Key Findings

### Approaches Tried (Chronological)

**1. Omega-Enumeration / SuccChain Construction (Early research, reports 01-12)**

- **Approach**: Build families with family-level temporal coherence by enumerating F/P obligations via a dovetailed SuccChain over Z.
- **Outcome**: BLOCKED permanently.
- **Why**: Required `f_nesting_is_bounded` — that any MCS has bounded F-nesting depth. This is FALSE. Counterexample: the set `{F^n(p) | n ∈ N}` is finitely consistent (any finite subset satisfiable on Z), so by Lindenbaum it extends to an MCS with unbounded F-nesting. The sorry at `UltrafilterChain.lean:1822` (`boxClassFamilies_temporally_coherent`) is permanently blocked via this approach.
- **Omega-enumeration also blocked**: The construction at `UltrafilterChain.lean:2424-2494` (`Z_chain_forward_F`, `Z_chain_backward_P`) only resolves `F_top` = `F(¬⊥)` at each step, not arbitrary F-obligations.

**2. GH-Intersection / Dual-Theory Witness (Reports 11-16)**

- **Approach**: Use "eternal" formulas where both G(a) and H(a) hold in M0 as the seed, restricting chain construction to avoid G/H theory oscillation.
- **Outcome**: BLOCKED by sub-case (b).
- **Why**: When `F(phi)` enters the backward chain with `G(neg phi)` in M0, the witness for phi must exist at some time `t` with `-n < t < 0`. The backward chain only resolves P-obligations (moves earlier in time), so F-obligations arising in the backward portion have no resolution mechanism. The extended witness theorem `{phi, psi} union G_theory(M0) union H_theory(M0) union box_theory(M)` was shown NOT provable consistent (H-theory elements are not G-liftable without also having their G-version in M0).

**3. Double-Rooted / Interleaved Chain Architectures (Report 11)**

- **Approach**: Various alternative chain structures: double-rooted chains, interleaved F/P steps, bidirectional chains.
- **Outcome**: All deemed infeasible.
- **Why**: Double-rooted chains yield disconnected timelines with no coherent ordering. Interleaved steps cause G/H theories to oscillate — neither theory accumulates. The unified bidirectional chain (report 16) showed promise but hit the G-formula propagation gap at the chain boundary.

**4. Bundle-Level Coherence as Truth Lemma Input (Reports 16-19)**

- **Approach**: Accept that bundle-level (cross-family) F-witnesses are all that can be proven, and modify or replace the truth lemma to work with this weaker coherence.
- **Outcome**: BLOCKED. This is a mathematically incorrect path.
- **Why**: The backward G case of `shifted_truth_lemma` uses `temporal_backward_G` via contraposition:
  1. Assume `G(phi) not in fam.mcs t`
  2. By MCS maximality: `F(neg phi) in fam.mcs t`
  3. By `forward_F` (SAME family): exists `s > t` with `neg(phi) in fam.mcs s`
  4. Hypothesis gives `phi in fam.mcs s` — contradiction.
  Step 3 requires the witness to be in the SAME family. Bundle coherence gives `neg(phi) in fam'.mcs s` for potentially different `fam'`, breaking the contradiction. Proven in report 45 that `G(phi) -> Box(G(phi))` is not derivable (countermodel exists with two families where one satisfies `G(p)` but the other does not), so bundle-to-family upgrade is impossible.

**5. Algebraic Bypass (Reports 40, 45, 50)**

- **Approach**: The algebraic path `not_provable_implies_neg_consistent + construct_bfmcs_bundle + bundle_completeness_contradiction` is already sorry-free. Use it directly to bypass the truth lemma.
- **Outcome**: RULED OUT. Proves a different theorem.
- **Why**: The algebraic path proves `not prov phi -> exists MCS M, phi not in M` (syntactic). The target theorem is `valid_over Int phi -> prov phi` (semantic). Connecting these requires showing `valid_over Int phi -> forall MCS M, phi in M`, which IS the truth lemma (contrapositive). There is no algebraic bypass for semantic validity.

**6. Forward-Only Truth Lemma (Reports 40, 45, 50, 65 reports 02-09)**

- **Approach**: Completeness via contrapositive only needs the forward direction (MCS membership implies truth), not the backward direction (truth implies MCS membership).
- **Outcome**: BLOCKED. The `imp` case creates an inherent bidirectionality.
- **Why**: The forward direction of the truth lemma for `psi -> chi` requires the BACKWARD IH for `psi` (CanonicalConstruction.lean:677, `.mpr` call). To show "(psi -> chi) in MCS implies (truth psi -> truth chi)," when given "truth psi" as hypothesis, the proof must convert it back to "psi in MCS" to apply the MCS implication property — that requires the backward direction for psi. Additionally, the completeness bridge itself requires the backward direction: instantiating `valid_over Int phi` gives "phi is true in the canonical model," but we need "phi is in MCS" — that is the backward direction (truth implies membership). Two independent teammates confirmed this (reports 50 and 65-wave3) after initial confusion.

**7. Restricted Completeness via RestrictedMCS (Reports 49-51, spawned as Task 65)**

- **Approach**: For a specific formula phi, `closureWithNeg(phi)` is FINITE. Within this closure, F-nesting IS bounded. Use `RestrictedTemporallyCoherentFamily` (already constructed in `SuccChainFMCS.lean:4191-4202`) to build a model with family-level temporal coherence for just this formula.
- **Outcome**: IDENTIFIED as most tractable path. Task 65 was spawned to implement it.
- **Current status**: Task 65 (reports 02-09) hit TWO dead ends:
  - (a) Single-history Omega for restricted construction fails because it cannot distinguish `G(phi)` from `Box(phi)` — all shifts evaluate to same world-states.
  - (b) Forward-only truth lemma path (the approach most analyzed) was ultimately blocked by the `imp` case bidirectionality (wave 3 report, CanonicalConstruction.lean:677).
- **Remaining open question**: Whether omega-enumeration construction achieving full family-level temporal coherence can be built for the restricted case (where F-nesting IS bounded). Wave 3 (report 09) identifies this as "Path A: Omega-Enumeration Construction (Recommended)" but notes the construction is "not yet implemented."

**8. Alternative Semantic Framework (Reports 45, 50, 65-wave3)**

- **Approach**: Redefine `valid_over` in terms of MCS membership rather than truth semantics, or redefine truth_at to allow cross-family F witnesses.
- **Outcome**: NOT RECOMMENDED.
- **Why**: Changing semantics changes the theorem statement, not the proof. The entire codebase is built around the current semantic definitions.

**9. Per-Family Omega Restriction (Report 45, Option D)**

- **Approach**: For each family `fam`, define `Omega_fam` restricted to family-compatible histories. Use per-family truth lemma where temporal witnesses are same-family by construction.
- **Outcome**: UNEXPLORED. Flagged as alternative if omega-enumeration fails.
- **Current status**: Never developed past the suggestion stage.

### Definitive Dead Ends

1. **SuccChain / omega-enumeration for arbitrary MCS**: Permanently blocked because `f_nesting_is_bounded` is false for arbitrary MCS (counterexample: `{F^n(p) | n ∈ N}`).

2. **Bundle-level coherence substituting for family-level in truth lemma**: Mathematically impossible. The backward G/H cases of `temporal_backward_G` require same-family F-witnesses for the contradiction to work. Bundle witnesses in a different family break the argument. `G(phi) -> Box(G(phi))` is not derivable (proven by countermodel).

3. **Algebraic bypass of truth lemma**: Proves `(forall MCS M, phi in M) -> prov phi`, not `valid_over Int phi -> prov phi`. Connecting these requires the truth lemma itself.

4. **Forward-only truth lemma**: The `imp` forward case uses `.mpr` (backward IH) for the antecedent at CanonicalConstruction.lean:677. This is fundamental to the MCS-based proof strategy and cannot be avoided.

5. **Extended witness theorem with GH-intersection**: `{phi, psi} union G_theory(M0) union H_theory(M0) union box_theory(M)` cannot be proven consistent because H-theory elements are not G-liftable without their G-version.

### Promising Unexplored Paths

**1. Omega-Enumeration Construction for Restricted Case (Highest priority)**

The `RestrictedTemporallyCoherentFamily` construction (`SuccChainFMCS.lean:4191-4202`) already provides family-level temporal coherence for the restricted formula closure. Wave 3 (Task 65 report 09) identifies this as the correct resolution: build families using omega-enumeration where F-nesting is bounded (guaranteed for restricted case), then prove full `shifted_truth_lemma` with these families.

- Within `closureWithNeg(phi)`, F-nesting IS bounded (`iter_F_not_mem_closureWithNeg` at `CanonicalTaskRelation.lean:175-182`).
- The SuccChain approach SHOULD work for RestrictedMCS precisely because F-obligations eventually terminate.
- Status: Construction approach documented but not implemented (`UltrafilterChain.lean:1865-1893` — documentation only).

**2. Per-Family Omega Restriction (Fallback)**

Define `Omega_fam` for each family restricted to that family's histories plus shifts. This would make temporal witnesses automatically same-family. Mentioned in report 45 (Option D) and report 45 (Option 4 at team research) but never developed.

- Requires re-examining what the Box case looks like when Omega is per-family.
- Would require showing that per-family Omega is sufficient for proving `valid_over`.

**3. Proof-Theoretic Bridge Avoiding Semantics**

From Task 65 wave-2 research: explore whether a soundness + proof-theoretic argument can provide `valid_over Int phi -> phi in all MCS` without using the truth lemma semantically. This is "Path 3" in the wave-3 report — unexplored and marked "not recommended" but not proven impossible.

### Current Understanding

The core mathematical obstacle is a **coherence level mismatch** in the completeness proof:

**What exists (sorry-free)**:
- Bundle-level temporal coherence: `F(phi) in fam.mcs t -> exists fam' in bundle, exists s > t, phi in fam'.mcs s`
- Full algebraic completeness chain (`not_provable_implies_neg_consistent`, `construct_bfmcs_bundle`, `bundle_completeness_contradiction`)
- `shifted_truth_lemma` proven — but it requires FAMILY-level temporal coherence as hypothesis

**What is missing**:
- Family-level temporal coherence: `F(phi) in fam.mcs t -> exists s > t, phi in fam.mcs s` (SAME family)
- Without this, `shifted_truth_lemma` cannot be instantiated with the bundle construction

**Why the gap exists**:
- Building families with same-family F-witnesses for ARBITRARY MCS requires resolving all F-obligations within one chain, but F-nesting can be unbounded (counterexample with `{F^n(p) | n ∈ N}`).
- The logical reason bundle-to-family upgrade fails: `G(phi) -> Box(G(phi))` is not derivable. Without this, knowing phi holds in all future states of one family does not guarantee it holds in all states of all families.

**The consensus resolution path**:
Restrict to a SINGLE formula phi (finite formula closure), where F-nesting IS bounded. Build family-level coherent model just for `closureWithNeg(phi)`. The omega-enumeration construction works in this bounded setting. This gives a countermodel for any unprovable phi, proving completeness by contrapositive.

There is consensus on this path (reports 49, 50, 51) but implementation has been blocked at each attempt:
- Single-history Omega fails (distinguishing G from Box)
- Forward-only truth lemma fails (imp case)
- The omega-enumeration construction for restricted case is still NOT IMPLEMENTED

## Evidence

| Claim | File | Lines |
|-------|------|-------|
| Family-level coherence definition (SAME family) | TemporalCoherence.lean | 216-219 |
| Bundle-level coherence definition (ANY family) | UltrafilterChain.lean | 2536-2555 |
| shifted_truth_lemma requires family-level `h_tc` | CanonicalConstruction.lean | 652 |
| `imp` forward uses backward IH (`.mpr`) | CanonicalConstruction.lean | 677 |
| G backward requires same-family forward_F | CanonicalConstruction.lean | 744-754 |
| `temporal_backward_G` contradiction same-MCS | TemporalCoherence.lean | 165-178 |
| Family-level coherence sorry (blocked) | UltrafilterChain.lean | 1822 |
| Z_chain_forward_F sorry (F_top only) | UltrafilterChain.lean | 2424-2485 |
| Z_chain_backward_P sorry | UltrafilterChain.lean | 2494 |
| Bundle construction sorry-free | UltrafilterChain.lean | 2853-2945 |
| Target sorries: model-theoretic glue | Completeness.lean | 115-120, 158-163, 186-214 |
| Omega-enumeration construction (docs only) | UltrafilterChain.lean | 1865-1893 |
| RestrictedTemporallyCoherentFamily | SuccChainFMCS.lean | 4191-4202 |
| iter_F_not_mem_closureWithNeg (bounded nesting) | CanonicalTaskRelation.lean | 175-182 |
| G->Box(G) not derivable (countermodel) | report 45_team-research.md | lines 46-55 |
| f_nesting_is_bounded FALSE (counterexample) | report 50_team-research.md | lines 40-44 |
| Wave-3 final assessment | task 65 report 09 | lines 84-121 |

## Confidence Level

**High** for the enumeration of dead ends — all of these have been confirmed by multiple independent teammates across many research waves.

**High** for the identification of the omega-enumeration construction for restricted case as the remaining viable path.

**Medium** for the claim that omega-enumeration will succeed for restricted case — F-nesting is bounded, which removes the primary obstacle, but the construction still needs to be built and verified.

**Low** for the per-family Omega restriction path — this is unexplored and may have subtle issues with the Box case that haven't been analyzed.
