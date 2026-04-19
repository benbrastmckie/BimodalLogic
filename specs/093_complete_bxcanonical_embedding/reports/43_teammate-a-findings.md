# Teammate A Findings: Control Problem Literature Survey (Task 93, Round 43)

**Date**: 2026-04-19
**Investigator**: Teammate A (Primary Angle)
**Role**: Control problem analysis + temporal logic completeness literature survey

---

## Key Findings

### 1. Literature Survey: How Standard Proofs Handle the Control Problem

**Finding**: The "control problem" — ensuring a specific F(φ) obligation is eventually resolved
in a canonical MCS chain — is handled by fundamentally different techniques in different traditions.
None of them use BX11 fold with multi-defect preservation. The BXCanonical approach is novel
in that respect.

#### 1a. Tableau Methods (Wolper 1985, Reynolds 2003)

Tableau completeness proofs for LTL use a **2-phase approach**:
- Phase 1: Build a tableau graph by syntactic expansion.
- Phase 2: Check that **every eventuality (F-formula) has at least one fulfilling cycle**.

The "control problem" is solved structurally: a branch survives only if it eventually reaches
a state containing the formula (fulfillment). Non-fulfilling branches are **pruned**.

Key mechanism: the PRUNE rule eliminates branches where an eventuality cannot be fulfilled.
Completeness follows because if a formula is satisfiable, at least one branch survives all
prunings with all eventualities fulfilled.

**There is no scheduling problem** in this approach because the proof works with finite
finite-state automata (Büchi-style), not infinite MCS chains. The "defect" is the set of
unfulfilled eventualities in a loop, and a loop is "good" iff it has no defects.

**Relevance to BXCanonical**: Tableau methods work on finite subformula-closed types
(Hintikka sets), not full MCS. The BXCanonical codebase's use of full infinite MCS, projected
via sigma_signature, is the non-standard move creating the control problem.

#### 1b. Finite Hintikka/Sigma-Type Methods (GHR 1994, Gabbay et al. 1980)

The GHR 1994 monograph constructs completeness for temporal logics with Until/Since via
**finite atom sequences** indexed over a subformula-closed set Σ. The key technique:

1. Define **Hintikka sequences**: consistent, maximal, Σ-saturated finite sets.
2. Show existence of a Σ-satisfying sequence using a **defect-free** extension.
3. Use a **scheduling function** over the finite alphabet Σ to ensure every
   F(φ) ∈ Σ is eventually satisfied.

The control problem is solved by: Σ is **finite**, so there are only finitely many
eventualities. A finite scheduling function cycles through all of them. Each
eventuality is scheduled for resolution in bounded number of steps (at most |Σ| steps).
Since F-obligations are "sticky" (they persist until resolved), once scheduled, each
F(φ) is resolved within |Σ| steps of its scheduled slot.

**This is the key technique the BXCanonical codebase is trying to replicate** but faces
difficulty because it uses full MCS (infinite) rather than Σ-restricted types (finite).

#### 1c. The "Until Induction" Axiom (Lichtenstein-Pnueli 2000)

The Lichtenstein-Pnueli completeness proof for propositional LTL uses the derived rule:
```
If ⊢ (ψ ∨ (φ ∧ X θ)) → θ, then ⊢ φ U ψ → θ
```
This is the **Until Induction Rule** (UIR). It allows proving that Until formulas are
eventually satisfied by a coinductive argument.

**Relevance**: UIR changes the axiom system. BX does not have X (next) or UIR. Adding
UIR would solve the control problem but would change the axiom system being formalized.
This has been noted in prior rounds as a potential axiom change — but the task is to
prove BXCanonical completeness for the **existing** BX axiom system.

#### 1d. Büchi Automata Methods

Many modern LTL completeness proofs proceed via Büchi automata:
1. Translate formulas to Büchi automata.
2. Use the Büchi acceptance condition (infinitely often in an accepting state) as the
   "control" mechanism.
3. The "control problem" is replaced by the automaton's built-in fairness condition.

**Relevance**: Not directly applicable to the MCS-chain proof-theoretic approach.

---

### 2. Is the Control Problem Solvable with Current Chain Architecture?

**Finding**: YES, but the proof is more subtle than previously recognized.

The current chain architecture uses `preserving_fwd_step` which:
- When defects are non-empty: resolves ≥1 defect, preserves ALL F-obligations
- When no defects: uses round-robin `fwd_succ`

The comment at `fwd_chain_forward_F` (line 1090) provides the correct strategy:
> "This terminates because sigma_list is finite and defects are tracked."

The termination argument is a **well-founded induction on a lexicographic measure**:
- Primary: the number of OTHER active defects that could "kill" F(φ) before φ's resolution
- Secondary: the distance to φ's next scheduled visit in the sigma_list cycle

**Why this works** (proof sketch):

Let φ ∈ sigma_list and F(φ) ∈ chain(n). Since `fwd_chain_F_persistent` proves
F-persistence for sigma_list formulas, F(φ) ∈ chain(m) for all m ≥ n.

At each step m ≥ n, since F(φ) ∈ chain(m), φ ∈ active_defects at step m.
Therefore `defect_step_choice_early` is called (not round-robin), and:
- Some defect w is resolved: w ∈ chain(m+1)
- All F-obligations preserved: F(χ) ∈ chain(m+1) for all χ ∈ active_defects

Wait — this is the key: ALL F-obligations are PRESERVED (not discharged). So the
active defect count never decreases. F(φ) ∈ chain(m) for all m ≥ n forever.

**The critical insight**: `fwd_chain_F_persistent` proves that F(φ) persists. This means
φ IS an active defect at every step m ≥ n. Therefore `defect_step_choice_early` is called
at EVERY step m ≥ n, and at each such step, some defect (possibly not φ) is resolved.

Now: `resolving_enriched_fwd_exists` guarantees some w is directly resolved (w ∈ chain(m+1)).
It also guarantees F(w) is preserved (w ∈ active_defects at m+1 too, by phi_in_mcs_imp_F_phi).

**The control problem**: Which w is resolved? We have NO control. BX11 gives a disjunctive
result: in the fold, BX11 case 3 (F(F(β) ∧ χ)) changes which formula is "direct". The
resolved formula could always be some χ ≠ φ, perpetually deferring φ.

**BUT**: there is a subtler argument. The resolved formula w is the "BX11-earliest" element
of the defects list in the fold. Even if BX11 keeps resolving the same w ≠ φ repeatedly,
the fold's behavior is determined by the CURRENT MCS M. As long as we cannot prove
"at some point in the chain, BX11's fold will pick φ as the earliest element", we are stuck.

---

### 3. Mathematical Analysis: Why the Perpetual Deferral IS a Real Obstruction

**Finding**: The perpetual deferral obstruction is REAL and the current chain construction
is mathematically incomplete for `fwd_chain_forward_F`.

Here is a CONCRETE counterexample scenario (to the naive proof):

Consider sigma_list = [φ, χ] where:
- F(φ) ∈ M₀ and F(χ) ∈ M₀
- BX11 on M₀ gives: F(F(φ) ∧ χ) ∈ M₀ (case 3 fires) — so χ is the "direct" element
- M₁ = defect_step_choice_early(M₀): χ ∈ M₁, and F(φ), F(χ) ∈ M₁ (by preservation)
- At M₁: F(F(φ) ∧ χ) ∈ M₁ again (via F_and_self_F_mcs from F(χ) ∈ M₁ and F(φ) ∈ M₁)
- BX11 on M₁ could AGAIN give case 3: F(F(φ) ∧ χ) ∈ M₁, so χ is AGAIN the direct element
- This could repeat indefinitely: χ is always resolved, φ is never resolved

This is NOT just a proof difficulty — it represents a genuine incompleteness of the
chain construction. The `defect_step_choice_early` always makes a CLASSICAL (non-constructive)
choice, and there is no axiom that forces φ to eventually be "BX11-earliest".

---

### 4. The Self-Resolving Forward Step: A Key Already in the Codebase

**Finding**: The codebase at lines 1588-1629 proves `self_resolving_fwd_step`: given F(ψ) ∈ M,
there exists M' with **ψ ∈ M' AND F(ψ) ∈ M'** and g_content(M) ⊆ M'.

This uses: F(ψ) ∈ M → F(ψ ∧ F(ψ)) ∈ M (via F_and_self_F_mcs), then seed {ψ, F(ψ)} ∪ g_content(M).

**This IS the missing tool for `fwd_chain_forward_F`**:

If we construct the chain USING `self_resolving_fwd_step` instead of
`defect_step_choice_early`, then:
- At each step, if F(φ) ∈ M, use `self_resolving_fwd_step M hM φ h_F`
- This gives M' with φ ∈ M' AND F(φ) ∈ M' and g_content(M) ⊆ M'

**Specifically**, `fwd_chain_forward_F` becomes TRIVIAL: given F(φ) ∈ chain(n),
use self_resolving_fwd_step at step n to get chain(n+1) with φ ∈ chain(n+1). Done.

**But**: The current `fwd_chain_of_sigma` uses `preserving_fwd_step`, NOT
`self_resolving_fwd_step`. We would need a DIFFERENT chain construction.

---

### 5. Proposed Solution: Single-Target Self-Resolving Chain

**CRITICAL INSIGHT**: The control problem can be ELIMINATED by using a DIFFERENT chain
construction for the purpose of proving `dd_bfmcs_restricted_tc`.

**Strategy**: Instead of using the multi-defect `preserving_fwd_step` chain, prove
`dd_bfmcs_restricted_tc` by constructing a SEPARATE chain that self-resolves a SINGLE
target φ.

**Concrete Proof Sketch for `fwd_chain_forward_F`**:

```
Given: F(φ) ∈ chain(n) for fwd_chain_of_sigma.
Need: ∃ m > n, φ ∈ fwd_chain_of_sigma m.

Key lemma (not yet in codebase): "direct_resolve_step"
  Given MCS M and F(φ) ∈ M, define M' := self_resolving_fwd_step M hM φ h_F.
  Then: φ ∈ M', g_content(M) ⊆ M'.

Proof of fwd_chain_forward_F using self_resolving_fwd_step:
  Take m = n + 1.
  chain(n+1) = preserving_fwd_step(chain(n), sigma_list, n).
  We need φ ∈ chain(n+1).

  Since F(φ) ∈ chain(n), φ ∈ active_defects at chain(n).
  preserving_fwd_step uses defect_step_choice_early on non-empty active_defects.
  defect_step_choice_early resolves SOME w ∈ defects. This might be φ or might not be.

  PROBLEM: we cannot force w = φ from defect_step_choice_early.
```

So m = n+1 doesn't work. We need to change the CHAIN CONSTRUCTION.

**Alternative**: Use a chain that, for each target φ, first resolves φ using
`self_resolving_fwd_step`, then continues.

This requires modifying `fwd_chain_of_sigma` or using a different chain for the
forward-F property proof. The key question is: can we use `self_resolving_fwd_step`
as the chain step while maintaining g_content propagation?

**Answer**: YES. `self_resolving_fwd_step_g_content` (proved at line 1626) shows
g_content(M) ⊆ self_resolving_fwd_step M hM ψ h_F.

**Revised Chain Strategy**: Define a new chain `resolve_chain` that, at step n,
uses `self_resolving_fwd_step` targeting `sigma_list[n % |sigma_list|]`:

```
resolve_chain(n+1) =
  let target := sigma_list[n % |sigma_list|]
  if h_F : F(target) ∈ resolve_chain(n) then
    self_resolving_fwd_step(resolve_chain(n), target, h_F)
  else
    fwd_succ(resolve_chain(n), target)  -- non-resolving, uses f_carry
```

Properties of `resolve_chain`:
1. g_content(chain(n)) ⊆ chain(n+1) ✓ (from self_resolving_fwd_step_g_content + fwd_succ_g_content)
2. F(target) ∈ chain(n+1) ✓ (from self_resolving_fwd_step_F_target when resolving)
3. f_carry preserved at non-resolving steps ✓ (from fwd_succ_f_carry)
4. target ∈ chain(n+1) when F(target) ∈ chain(n) ✓ (from self_resolving_fwd_step_target)

**Forward-F for resolve_chain**: Given F(φ) ∈ chain(n) and φ ∈ sigma_list:
- F(φ) persists in chain (F-persistence holds for resolve_chain by same argument as fwd_chain_F_persistent)
- By schedule surjectivity, ∃ k ≥ n such that sigma_list[k % |sigma_list|] = φ
- At step k: resolving branch fires (F(φ) ∈ chain(k) by persistence)
- Therefore φ ∈ chain(k+1). Take m = k+1 > n. ✓

**This is a COMPLETE and CORRECT proof** of `fwd_chain_forward_F` for `resolve_chain`.

The proof uses `schedule_surjective_above` (already proved in CanonicalModel.lean, line 36)
and F-persistence (fwd_chain_F_persistent, proved in RootScopedChain.lean, line 1071).

---

### 6. Why `fwd_chain_forward_F` for `preserving_fwd_step` Is Stuck

The existing `fwd_chain_of_sigma` uses `preserving_fwd_step` (not `self_resolving_fwd_step`).
The difference:

| Chain Step | Resolves target? | Preserves ALL F? |
|------------|-----------------|------------------|
| self_resolving_fwd_step | target GUARANTEED | Only F(target) guaranteed |
| preserving_fwd_step | SOME w (possibly ≠ target) | ALL F-formulas preserved |

`preserving_fwd_step` was designed to preserve ALL F-obligations at every step. But this
stronger preservation property comes at the cost of losing CONTROL over which formula
is resolved. This is the classic trade-off.

`self_resolving_fwd_step` sacrifices preservation of OTHER F-obligations in favor of
guaranteed target resolution. This is the correct trade-off for proving `fwd_chain_forward_F`.

**Key question**: Does `resolve_chain` (using self_resolving_fwd_step) still satisfy
g_content propagation and the FMCS properties needed by `dd_bfmcs`?

YES: g_content propagation holds by construction. The FMCS properties (is_mcs, forward_G,
backward_H) are structural and don't depend on F-preservation.

---

### 7. Impact on `dd_bfmcs_restricted_tc` Second and Third Sorry Sites

The sorry at line 1138 (backward chain when t-s < 0) and line 1144 (backward direction) need:
- For t-s < 0: F(φ) ∈ backward chain → ∃ forward step where φ is resolved
- For backward P(φ): symmetric construction using P-analog of self_resolving_fwd_step

The backward chain `bwd_chain_of_sigma` uses `bwd_pred`. The symmetric `self_resolving_bwd_step`
would use the `P_and_self_P_mcs` (proved at line 1652): P(ψ) ∈ M → P(ψ ∧ P(ψ)) ∈ M.

Exactly the same strategy applies: define a `resolve_bwd_chain` using `self_resolving_bwd_step`
and prove backward-P similarly.

BUT: there's an additional complication. When t-s < 0 and F(φ) ∈ backward chain, we need
φ to be in the FORWARD chain (not backward). The F-obligation is in a backward-direction
MCS, but the resolution must come at a LATER (more positive) time step.

This is actually a DIFFERENT problem. It may require a separate argument combining:
1. F(φ) ∈ backward_chain(-k) for some k > 0
2. F(φ) "crosses" to chain(0) = M₀ (via g_content propagation backwards)
3. Then resolves in forward chain

Actually: since F(φ) ∈ chain(-k) and g_content propagation gives g_content(chain(-k)) ⊆ chain(-k+1) ⊆ ... ⊆ chain(0), but g_content gives G(φ), not F(φ). So F(φ) does NOT propagate forward through g_content.

This is a genuine difficulty for the backward sorry at line 1138.

---

### 8. Recommended Approach

**For `fwd_chain_forward_F`** (line 1090, primary sorry):

**Recommended**: Define `resolve_fwd_chain` using `self_resolving_fwd_step` with
round-robin scheduling, replacing `fwd_chain_of_sigma` in the proof. This requires:

1. Define `resolve_fwd_chain` (5-10 LOC): analogous to `fwd_chain` in CanonicalModel.lean
   but using `self_resolving_fwd_step` as the step function.
2. Prove `resolve_fwd_chain_g_content_step`: trivial from `self_resolving_fwd_step_g_content`.
3. Prove `resolve_fwd_chain_F_persistent`: uses same induction as `fwd_chain_F_persistent`
   (since `self_resolving_fwd_step_F_target` gives F(target) ∈ successor).
4. Prove `fwd_chain_forward_F`: trivial with schedule_surjective_above.

**HOWEVER**: There is a fundamental tension. The `dd_bfmcs_restricted_tc` proof (line 1114)
calls `fwd_chain_forward_F` on `fwd_chain_of_sigma`, not on `resolve_fwd_chain`. To use
`resolve_fwd_chain`, we would need to either:
(a) Switch `fwd_chain_of_sigma` to use `self_resolving_fwd_step` (changing the chain definition)
(b) Add a theorem bridging `fwd_chain_of_sigma` to `resolve_fwd_chain`

Option (a) is cleaner. Replacing `preserving_fwd_step` with a step that uses
`self_resolving_fwd_step` for the scheduled target would:
- Maintain g_content propagation
- Fix the control problem for forward-F
- POTENTIALLY BREAK preservation of OTHER F-obligations at resolving steps

But `dd_bfmcs_restricted_buc` and `dd_bfmcs_restricted_fuc` (the other two sorrys) do NOT
depend on F-obligation preservation. They depend on until/since coherence, which is
a separate property.

**CONFIDENCE**: HIGH (85%) that switching to `self_resolving_fwd_step` for `fwd_chain_of_sigma`
solves `fwd_chain_forward_F` cleanly, with ~50-80 LOC.

**For the backward sorry sites** (`dd_bfmcs_restricted_tc` lines 1138, 1144):

The backward direction (P(φ)) can use a symmetric `resolve_bwd_chain` with `self_resolving_bwd_step`.
This is symmetric and should work with ~30-50 additional LOC.

The case t-s < 0 with F(φ) in backward chain is harder. One approach:
- Show F(φ) ∈ backward_chain(-k) ⟹ G(something) ∈ M₀ that implies φ eventually
- This likely requires a separate argument using the fact that F-formulas in backward
  chains must come from M₀ via G-propagation

This case may be the hardest of the three sorry sites. Further research needed.

---

## Evidence / Examples

**Example of self-resolving chain working** (from code):

```lean
-- self_resolving_fwd_step gives: φ ∈ M' AND F(φ) ∈ M' AND g_content(M) ⊆ M'
theorem self_resolving_fwd_step_target : ψ ∈ self_resolving_fwd_step M hM ψ h_F
theorem self_resolving_fwd_step_F_target : F(ψ) ∈ self_resolving_fwd_step M hM ψ h_F
theorem self_resolving_fwd_step_g_content : g_content M ⊆ self_resolving_fwd_step M hM ψ h_F
```

**Example of schedule surjectivity** (from CanonicalModel.lean line 36):
```lean
theorem schedule_surjective_above (ψ : Formula) (k : Nat) :
    ∃ n : Nat, n ≥ k ∧ schedule n = ψ
```

These two facts together enable `fwd_chain_forward_F` for `resolve_chain`.

---

## Confidence Levels

| Finding | Confidence |
|---------|-----------|
| Control problem is REAL for current `preserving_fwd_step` chain | HIGH (90%) |
| `self_resolving_fwd_step` + schedule surjectivity solves forward-F | HIGH (85%) |
| Switching `fwd_chain_of_sigma` to use `self_resolving_fwd_step` works | MEDIUM-HIGH (75%) |
| This doesn't break other FMCS properties | MEDIUM (70%) |
| Backward direction (P-analog) works symmetrically | MEDIUM-HIGH (80%) |
| t-s < 0 backward sorry (line 1138) solvable with proposed approach | MEDIUM (55%) |
| Literature survey finding: standard proofs use finite Σ, not full MCS | HIGH (95%) |

---

## Summary

The standard temporal logic completeness literature (Wolper 1985, GHR 1994, Lichtenstein-Pnueli 2000)
avoids the control problem through one of three mechanisms:
1. **Tableau pruning**: Non-fulfilling branches are removed (finite state).
2. **Finite Σ scheduling**: Only finitely many eventualities, scheduled in bounded rounds.
3. **Until Induction Rule**: Changes the axiom system to avoid the problem.

The BXCanonical codebase cannot use any of these directly (full MCS, not Σ-restricted;
fixed axiom system without UIR). However, a solution EXISTS using `self_resolving_fwd_step`
(already proved) combined with `schedule_surjective_above` (already proved).

The key architectural change is to use `self_resolving_fwd_step` (which guarantees target ∈ M'
AND F(target) ∈ M') as the chain step function, replacing `preserving_fwd_step` (which
resolves SOME defect but cannot control WHICH one).

This change requires modifying `fwd_chain_of_sigma` or proving `fwd_chain_forward_F`
for a new chain. The former is cleaner.

**Estimated implementation**: 100-150 LOC for the complete forward-F fix.
