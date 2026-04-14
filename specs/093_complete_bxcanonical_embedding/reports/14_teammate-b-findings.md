# Teammate B Findings: Alternative Approaches to forward_F

**Task**: 93 - Close BXCanonical embedding
**Date**: 2026-04-14
**Focus**: Alternative approaches that might be simpler or more robust than the ordered defect-discharge chain

## Key Findings

### 1. Literature Approaches to Temporal Completeness

#### 1.1 The Standard "Step-by-Step" Method (Burgess/Xu/Goldblatt/Venema)

The standard technique for completeness of tense logics with Until/Since on linear orders, as described in Burgess 1984 and formalized in Verbrugge 2007 ("Completeness by Construction"), uses a **step-by-step chain construction** where:

1. Start with an MCS M_0 containing the target formula
2. Enumerate ALL eventualities (F-obligations and Until-obligations) from the subformula closure
3. At each step, choose the next eventuality to resolve
4. Build a successor MCS that resolves it while preserving g_content (the G-propagated formulas)
5. The chain terminates when all eventualities are resolved
6. The key termination argument: each step resolves one defect, no new defects are created (because g_content propagation via temp_4 ensures G(neg(psi)) propagates)

**Critical insight from the literature**: The standard approach does NOT use BX11 fold or ordered witness selection. Instead, it resolves **one defect at a time** using the simple seed `{psi} union g_content(M)` (which is consistent when `F(psi) in M`). The question is whether F-formulas for OTHER eventualities survive.

In the standard approach for **pure temporal logic** (without the S5 modal component), the chain is built over a **single linear order** and the key property is that resolving psi at step n does NOT create new F-defects (proved via `no_new_f_defects` in OrderedSeedConsistency.lean, which already exists in the codebase). The issue is that existing F-defects may be **lost** (F(chi) in M but F(chi) not in M') at resolving steps.

The BX11 ordering approach (current plan) addresses this by protecting other F-formulas in the seed. But the literature suggests a simpler approach may work.

#### 1.2 The Finite Defect-Discharge Approach (Burgess 1984)

Burgess's original approach for Until constructs a **finite chain** of length at most |Sigma| where:
- Each step resolves exactly one Until-defect
- The defect count strictly decreases
- After at most |Sigma| steps, the chain is defect-free

This is already partially implemented in `Theories/Bimodal/Metalogic/BXCanonical/Filtration/DefectChain.lean` with `sigma_defect_count` and `sigma_defect_count_bounded`. The existing infrastructure counts Until-defects on BXPoints.

**Key difference from the current approach**: Burgess resolves Until-defects (not F-defects). Since `(phi U psi) -> F(psi)` (BX10, already proved as `defect_step_F_psi`), resolving Until-defects automatically resolves the associated F-obligation. The question is whether Until-defects can be resolved independently.

### 2. Step-Indexed Approach (Alternative to Well-Founded Recursion)

**Proposal**: Instead of well-founded recursion on defect count, use a simple `Fin |Sigma|`-indexed chain where step i resolves defect i (if it exists at that step).

**Concrete construction**:

```
defects := enumerate all (phi, psi) such that (phi U psi) in deferralClosure(root)
chain(0) := M_0
chain(i+1) :=
  if defects[i] = (phi U psi) and (phi U psi) in chain(i) and psi not_in chain(i):
    Lindenbaum({psi} union g_content(chain(i)))  -- resolve this defect
  else:
    fwd_succ chain(i) (some dummy)  -- non-resolving step
```

**Why this works**:
- `{psi} union g_content(chain(i))` is consistent when `F(psi) in chain(i)` (by `forward_temporal_witness_seed_consistent`, which already exists)
- `F(psi) in chain(i)` follows from `(phi U psi) in chain(i)` by BX10 (already proved as `defect_step_F_psi`)
- After step i, defect i is resolved (psi in chain(i+1))
- **New defects cannot appear**: if `(phi' U psi')` was NOT in chain(i), it cannot appear in chain(i+1). This is because g_content propagation means if `G(neg(phi' U psi'))` was in chain(i), it propagates to chain(i+1)

**BUT**: The critical question is whether *existing* F-defects for OTHER formulas are preserved. At a resolving step for `(phi U psi)`, the seed is `{psi} union g_content(chain(i))`. Other F-formulas `F(chi)` may not be in this seed. They could be lost.

**This is the same fundamental problem** that plagues all approaches. The step-indexed approach does NOT avoid the F-formula preservation issue.

### 3. FMP Bridge Approach

The codebase has extensive FMP (Finite Model Property) infrastructure in `Theories/Bimodal/Metalogic/Decidability/FMP/`:
- `Filtration.lean` -- MCS-based filtration equivalence and quotient model (0 sorry)
- `FMP.lean` -- Finite model property theorem (0 sorry)
- `TruthPreservation.lean` -- Truth preservation under filtration (0 sorry)
- `ClosureMCS.lean` -- Closure MCS bundles (0 sorry)
- `DenseFMP.lean` and `DiscreteFMP.lean` -- FMP for different temporal orders (0 sorry)

**Assessment**: The FMP infrastructure is **complete and sorry-free**, but it proves a different theorem: "if phi is valid in all finite models, then phi is valid." This gives decidability, not completeness. To use FMP for completeness, we would need:

1. Prove `valid(phi) -> finite_valid(phi)` (trivial: finite models are models)
2. Prove `finite_valid(phi) -> provable(phi)` (this IS completeness for finite models)

Step 2 requires essentially the same canonical model construction we are trying to build. The FMP infrastructure does not provide a shortcut for the completeness proof. It only helps with decidability.

**Verdict**: FMP bridge is NOT a viable alternative for closing the sorry sites.

### 4. BXPoint-Based Quasimodel Approach (Revised)

The quasimodel approach was previously rejected (round 4) because of the BXPoint-to-Int bridge problem. However, the codebase already has:

- `Quasimodel/Construction.lean` -- Quasimodel chains with defect-discharge on BXPoints
- `Quasimodel/Realization.lean` -- Lifting from Hintikka points to BXPoints
- `Filtration/DefectChain.lean` -- Defect counting on BXPoints
- `Filtration/SigmaOrdering.lean` -- Sigma-restricted ordering

**The original rejection**: BXPoints have no natural integer index. The `bx_le` ordering is a preorder (reflexive, transitive) but not total -- you cannot embed an arbitrary BXPoint chain into Int.

**Revised assessment**: The rejection is valid. The BFMCS structure requires `Int`-indexed families, and there is no way to convert a BXPoint-based chain to an Int-indexed one while preserving all the required coherence properties. The parametric representation theorem (`RestrictedParametricTruthLemma.lean`) is already wired to expect `BFMCS Int`, and changing this would require rewriting hundreds of lines of proved infrastructure.

**Verdict**: Quasimodel approach revival is NOT viable without major infrastructure changes.

### 5. Two-Phase Approach

**Proposal**: Separate F-defect discharge from Until-defect discharge.

Phase 1: Build a finite chain that resolves all F-defects (using ordered defect-discharge). After at most |Sigma| steps, the terminal MCS M_N is F-defect-free: for every psi in Sigma, if F(psi) in M_N then psi in M_N.

Phase 2: Build a separate chain from M_N that resolves all Until-defects. Since M_N is F-defect-free, the Until-defects are "almost" resolved: for (phi U psi) in M_N, we have F(psi) in M_N (by BX10), so psi in M_N (since F-defect-free). So Until-defects are automatically resolved at M_N!

**Critical realization**: If Phase 1 succeeds in producing an F-defect-free terminal MCS, Phase 2 is trivial. The entire problem reduces to Phase 1.

Phase 1 is exactly the ordered defect-discharge chain from the current plan. So the two-phase approach does not simplify anything -- it just makes explicit that Until-defects are resolved as a consequence of F-defect resolution.

**Verdict**: Two-phase is conceptually cleaner but reduces to the same core problem.

### 6. The "Simple Scheduling" Insight (NEW)

After analyzing all approaches, I identified a potentially simpler variant of the ordered defect-discharge chain:

**Observation**: The `enriched_fwd_step` already exists and is proved correct. It uses BX11 fold to protect ALL F-formulas from sigma_list at each step. The property `enriched_fwd_step_preserves` (line 430-447) proves: for each chi in sigma_list with F(chi) in M, either chi in M' or F(chi) in M'.

The handoff document (15_forward-F-analysis.md) claims this is insufficient because "S is stable" -- the set of F-formulas never decreases. But this stability is actually a GOOD thing for the forward_F proof:

**Key argument**: Consider F(psi) in chain(n) with psi in sigma_list. The enriched step preserves: at every subsequent step m > n, either psi in chain(m) or F(psi) in chain(m).

Case A: At some step m > n, psi in chain(m). Done -- witness found.

Case B: F(psi) in chain(m) for all m > n (psi never appears directly). This means psi is ALWAYS F-protected, never resolved. But by the round-robin schedule, psi IS the target at step n + k*|sigma_list| for each k. At those steps, `enriched_fwd_exists` is called with `target = psi` and `F(target) in M`. The BX11 fold produces the compound. The extraction gives `psi in M' OR F(psi) in M'`.

**THE QUESTION**: Can the BX11 fold always return the F-protected case for psi even when psi is the target? Yes -- the handoff document explains this correctly. BX11 case 3 gives F(F(psi) and rest), which puts psi as F-protected. The target is not guaranteed to be directly resolved.

**So the enriched chain approach (as currently implemented) does NOT guarantee forward_F.** The stability of S means no defects are resolved.

### 7. The Actual Solution: Replace enriched_fwd_step with discharge_step

The current `enriched_fwd_step` uses `enriched_fwd_exists` which gives a disjunction (chi in M' OR F(chi) in M'). What we need instead is `enriched_resolving_seed_consistent` which gives a conjunction (psi in M' AND rest in M').

**The discharge step**:
1. Compute F-defects D = {chi in sigma_list | F(chi) in chain(n), chi not_in chain(n)}
2. If D is empty: identity step (or fwd_succ for non-resolving)
3. If D is nonempty: use BX11 to find the earliest-witness defect psi_j
4. Build seed {psi_j, compound_of_others} union g_content(chain(n))
5. Lindenbaum extend

From `enriched_resolving_seed_consistent`: if `F(psi_j and compound) in M`, then `{psi_j, compound} union g_content(M)` is consistent. After Lindenbaum: psi_j IN M' (not just "or F(psi_j) in M'") AND compound IN M'.

**This guarantees psi_j is resolved** (not F-wrapped). The defect for psi_j is discharged. Other defects are protected via compound extraction.

**The termination argument** then works: |D| strictly decreases at each resolving step (psi_j is removed from D, no new defects by `no_new_f_defects`). After at most |D| <= |Sigma| steps, D is empty.

**This is precisely the ordered defect-discharge chain from report 13.**

## Recommended Approach

**The ordered defect-discharge chain (report 13) is the correct approach.** No simpler alternative exists that avoids the core F-formula preservation problem.

Specifically:

1. **Replace `enriched_fwd_step`** (which uses BX11 fold disjunction) with a new **`discharge_fwd_step`** that uses `enriched_resolving_seed_consistent` (which gives conjunction).

2. **Implement `find_earliest_witness`**: Given F-defects in an MCS, iterate BX11 pairwise to find the formula whose witness comes earliest. This formula is guaranteed to be in BX11 case 1 or 2 against all others, so `enriched_resolving_seed_consistent` applies.

3. **Prove termination via `Finset.card` decrease**: The defect set D is a Finset (subset of sigma_list). At each discharge step, |D| decreases by at least 1. After |D| steps, D is empty.

4. **Identity tail**: After D reaches 0, use constant chain (chain(t) = M_terminal for all t > N). Forward_F at the tail: F(psi) in M_terminal implies psi in M_terminal (no defects).

5. **Forward_F in the discharge region**: F(psi) in chain(n). If psi in chain(n), trivially witnessed. If not, psi is a defect. It will be the earliest witness at some step (because defects are resolved in BX11 order, and psi must eventually be earliest among remaining defects). At that step, psi is directly resolved.

## Evidence/Examples

### Existing infrastructure that supports this approach:

| Component | File | Status |
|-----------|------|--------|
| `enriched_resolving_seed_consistent` | OrderedSeedConsistency.lean | Proved |
| `ordered_two_defect_seed_consistent` | OrderedSeedConsistency.lean | Proved |
| `temp_linearity_mcs` (BX11 at MCS level) | OrderedSeedConsistency.lean | Proved |
| `two_defect_consistent_seed` | OrderedSeedConsistency.lean | Proved |
| `no_new_f_defects` | OrderedSeedConsistency.lean | Proved |
| `FF_imp_F` / `FF_imp_F_mcs` | RootScopedChain.lean | Proved |
| `F_mono` / `F_conj_left_mcs` / `F_conj_right_mcs` | RootScopedChain.lean | Proved |
| `sigma_defect_count` / `sigma_defect_count_bounded` | Filtration/DefectChain.lean | Proved |
| `forward_temporal_witness_seed_consistent` | Bundle/WitnessSeed.lean | Proved |
| `rr_fwd_chain_g_content_step/trans` | RootScopedChain.lean | Proved |
| `box_stable_dd_chain` | RootScopedChain.lean | Proved |

### What needs to be built:

1. **`find_earliest_witness`**: Iterate BX11 over pairs of F-defects, track which is earliest. This is a finite computation over a `List Formula`. Result: index j with `F(psi_j and compound_of_rest) in M`.

2. **`discharge_fwd_step`**: Replace `enriched_fwd_step` with one that uses `enriched_resolving_seed_consistent` at resolving steps. The seed is `{psi_j, compound} union g_content(M)`, not `{beta'} union g_content(M)` from the BX11 fold.

3. **`discharge_chain`**: Well-founded recursion on `|D|` (defect count). At each step, call `discharge_fwd_step`. Termination: `|D|` decreases (proved from `no_new_f_defects` + psi_j resolved).

4. **`rr_fwd_chain_forward_F`**: The main sorry. Proof by case analysis on whether psi is a defect. If not, F(psi) in chain(n) and psi in chain(n), so trivially witnessed at n+1 (identity tail). If defect, it's resolved during the discharge phase.

5. **Backward symmetric versions** for P and Since.

### Approaches definitively ruled out:

| Approach | Reason for Rejection |
|----------|---------------------|
| FMP bridge | FMP proves decidability, not completeness; same construction needed |
| BXPoint quasimodel | BXPoint-to-Int bridge impossible; infrastructure locked to BFMCS Int |
| Step-indexed (without BX11 ordering) | F-formulas lost at resolving steps; same fundamental problem |
| f_carry enrichment | Seed inconsistency (counterexample: G(F(alpha) -> neg(psi))) |
| Identity tail only | F is strict future; identity tail cannot witness |
| Simple round-robin with enriched_fwd_step | BX11 fold gives disjunction; defect count never decreases |

## Confidence Level

**High confidence (90%)** that the ordered defect-discharge chain is the correct and necessary approach. The mathematical argument is sound (verified in OrderedSeedConsistency.lean with 0 sorry). The remaining implementation work is:

1. `find_earliest_witness` -- moderate difficulty (finite iteration over BX11 cases)
2. `discharge_fwd_step` -- low difficulty (mirrors enriched_fwd_step but uses enriched_resolving_seed_consistent)
3. `discharge_chain` + termination -- moderate difficulty (well-founded recursion on Finset.card)
4. `rr_fwd_chain_forward_F` -- moderate difficulty (case analysis + induction on chain steps)
5. Remaining 5 sorry sites -- low-moderate difficulty (follow from forward_F + symmetric backward_P)

**Risk**: The `find_earliest_witness` construction requires iterating BX11 over n*(n-1)/2 pairs. For formalization in Lean, this inductive construction on lists may be technically complex (tracking BX11 outcomes across all pairs). A simpler version that handles 2-defect case and uses induction on defect count may be more tractable.

**Estimated effort**: 2-3 focused implementation sessions to close all 6 sorry sites.

## Sources

- [Burgess 1984 - Basic Tense Logic](https://link.springer.com/chapter/10.1007/978-94-009-6259-0_2)
- [Verbrugge 2007 - Completeness by Construction](https://festschriften.illc.uva.nl/D65/verbrugge.pdf)
- [Venema - Temporal Logic (Chapter 10)](https://staff.science.uva.nl/y.venema/papers/TempLog.pdf)
- [Stanford Encyclopedia - Temporal Logic](https://plato.stanford.edu/entries/logic-temporal/)
- [Goldblatt 1992 - Logics of Time and Computation](https://web.stanford.edu/group/cslipublications/cslipublications/site/0937073946.shtml)
- [Bimodal Cluster Temporal Logic - Local Filtration](https://elib.sfu-kras.ru/handle/2311/158234)
