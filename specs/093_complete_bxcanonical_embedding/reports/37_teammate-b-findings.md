# Teammate B: Alternative Approaches Study (Round 37)

**Session**: sess_1776441600_b37alt
**Date**: 2026-04-17
**Focus**: Alternatives that do NOT rely on enriching Lindenbaum seed / adapting
`resolving_enriched_fwd_exists` (Teammate A's focus)

---

## Executive Summary

The 8 sorry sites in `RootScopedChain.lean` reduce to two independent problems:

1. **Forward_F / Backward_P eventualities** (sorries at lines 1413, 1457, 1464, 2196, 2289)
2. **Three restricted coherence theorems** (sorries at lines 1517, 1522, 1527):
   `dd_bfmcs_restricted_tc`, `dd_bfmcs_restricted_buc`, `dd_bfmcs_restricted_fuc`

Round 36 converged on one correct architecture: build a `HintikkaStepOracle` from
`bx_forward_witness`, use `hintikka_chain_exists` (already sorry-free), build a new BFMCS
from the resulting BXPoint chain, and prove full Until/Since coherence to close all 8 sorries.

This round evaluates the 5 Alternative approaches asked about in the task brief, all of which
BYPASS the Lindenbaum/seed-enrichment track entirely. My conclusion: all 5 alternatives have
genuine merit for specific subsets of the sorry sites, but **none solves all 8 sorries** without
the oracle + BFMCS replacement architecture. The most useful alternative is a hybrid: use
`self_resolving_fwd_step` (Alternative 1b) to close the 5 forward_F / backward_P sorries, and
the oracle/BFMCS approach to close the 3 coherence sorries.

---

## Key Findings

### Finding 1: The sorry landscape has two separate root causes

Inspecting the sorry sites:

- **Eventualities** (sorries 1413, 1457, 1464, 2196, 2289): All reduce to
  `rr_fwd_chain_forward_F`'s depth-0 base case. The `defect_fwd_chain_forward_F` (line 2196)
  and `defect_bwd_chain_backward_P` (line 2289) sorries are noted in comments as depending on
  solving the depth-0 obstruction first. Lines 1457, 1464 (`dd_fmcs_forward_F` backward case
  and `dd_fmcs_backward_P`) are similarly downstream.

- **Coherence** (sorries 1517, 1522, 1527): Independent of forward_F. These are
  `dd_bfmcs_restricted_tc/buc/fuc` which need the BFMCS to satisfy restricted temporal
  coherence, backward Until/Since coherence, and forward Until/Since coherence. These require
  Until/Since-witnessing properties that the `rr_fwd_chain` / `rr_bwd_chain` construction
  does NOT provide.

**Consequence**: Any approach that only fixes forward_F leaves the 3 coherence sorries open,
and vice versa.

### Finding 2: The `self_resolving_fwd_step` infrastructure is fully proved

`self_resolving_fwd_step` (lines 1961-1996) provides:
- Given `F(psi) in M`, constructs `M'` with `psi in M'`, `F(psi) in M'`, `g_content(M) in M'`
- All necessary properties have been proved (no sorries in this section)
- Key: `F(psi ∧ F(psi)) in M` follows from `F_and_self_F_mcs` (proved), enabling the enriched
  seed with `{psi, F(psi)}` to be consistent

This is the engine for **Alternative 1** below.

### Finding 3: `defect_fwd_step_choice_singleton` already closes the single-defect case

Line 2161-2170: `defect_fwd_step_choice_singleton` is proved (no sorry). Given `F(psi) in M`
and defects = `[psi]`, it shows `psi in defect_fwd_step_choice M ... [psi] ...`.

So the single-defect base case of `defect_fwd_chain_forward_F` is already handled. The sorry
(line 2196) is for the multi-defect case where a specific defect `psi` is in a larger list
and must eventually be resolved. The depth-0 base case of `rr_fwd_chain_forward_F` (line 1413)
is the same obstruction.

### Finding 4: The backward chain is structurally weaker

`defect_bwd_chain` uses `bwd_pred` with `Formula.bot` (non-resolving mode) at EVERY step.
P-obligations persist via `p_carry`, but the chain never directly resolves any defect (line
2279 comment confirms). Alternative approaches for forward_F may not transfer to backward_P
without a symmetric resolving `bwd_pred`.

### Finding 5: The `enriched_fwd_step` BX11 fold provably resolves something each step

`defect_fwd_step_choice_spec` (proved, line 2036-2046) guarantees that in each `h_all` step,
`exists w in defects, F(w) in M and w in M'`. So something IS resolved at each step. The sorry
for multi-defect `defect_fwd_chain_forward_F` needs to track WHICH formula gets resolved and
prove that any given `psi` must be resolved eventually. This is a counting/progress argument.

---

## Alternative 1: Bypass hintikka_step entirely via direct BXPoint chain

### Approach

Build a quasimodel chain directly from BXPoints using `bx_forward_witness`, bypassing
`HintikkaPoint` entirely. The chain would be:
- `w_0 = root BXPoint`
- `w_{i+1} = bx_forward_witness w_i psi_i` (for some target psi_i)
- Prove forward_F: `F(psi) in w_k -> exists s > k, psi in w_s`

### Feasibility Assessment

**PARTIALLY VIABLE for forward_F, BLOCKED for Until/Since coherence.**

BXPoints (which are MCS) satisfy: if `F(psi) in w_k`, then by `until_F_mcs` (proved) there
exists a BXPoint `v` with `bx_le w_k v` and `psi in v`. This is essentially what
`bx_forward_witness` provides. The chain `w_0, w_1, ...` built this way would have:
- `bx_le w_i w_{i+1}` (by construction)
- `g_content(w_i) subset w_{i+1}.formulas` (from `bx_le`)

The problem: for the restricted coherence sorries, we need the chain to satisfy
`restricted_forward_until_since_coherent root`, which requires that for `phi U psi in chain(t)`
with `psi notin chain(t)`, there exists `s > t` with `psi in chain(s)` AND `phi in chain(r)`
for all `r in [t, s)`. The BXPoint chain's `bx_le` relation gives `phi` propagation via
G-formulas, but `phi U psi` is NOT a G-formula. G-propagation carries `G(phi U psi)`, not
`phi U psi`.

**Verdict**: Alternative 1 could close forward_F (sorries 1413, 1457, 1464) but cannot
close the coherence sorries (1517, 1522, 1527) without Until-tracking.

**Effort**: ~150-300 LOC for the BXPoint chain + forward_F proof.
**Risk**: MEDIUM. The BXPoint chain misses Until propagation without additional infrastructure.

### Sub-variant 1b: Use `self_resolving_fwd_step` chain

A more direct path: build a `self_resolving_fwd_step` chain. Since `self_resolving_fwd_step`
guarantees `psi in M'` (not just `F(psi) in M' OR psi in M'`), a chain of such steps where
the target cycles through sigma_list would directly resolve each formula:
- At step `k` (when psi is the target), `psi in chain(k)`
- Forward_F follows immediately

**The gap**: must show `F(psi) in chain(k)` when psi is scheduled (i.e., F-persistence).
`self_resolving_fwd_step_F_target` (proved, line 1987) shows `F(psi) in M'` after a
self-resolving step for psi. So `F(psi)` is present AFTER psi's step, meaning at step k+1.
If psi cycles every N steps, then from step k+1 onward `F(psi)` is present, but we need
`F(psi) in chain(k)` as the PRECONDITION for applying `self_resolving_fwd_step`. This is
circular: the step requires F(psi) as hypothesis but only produces F(psi) AFTER.

**Resolution**: The standard approach is: if `F(psi) in chain(n)`, use F-persistence
(`rr_fwd_chain_F_obligation_forward`, proved) to carry `F(psi)` to the scheduled step, then
apply `self_resolving_fwd_step`. This works IF the chain uses `self_resolving_fwd_step` at
psi's visit. But the current `rr_fwd_chain` uses `enriched_fwd_step`, not
`self_resolving_fwd_step`. We would need an alternative chain using `self_resolving_fwd_step`.

**Conclusion**: Build a chain `direct_resolve_chain` that uses `self_resolving_fwd_step` when
visiting each formula in sigma_list. The key property:
- At step `k * |sigma_list| + i` (when sigma_list[i] = psi is the target): if `F(psi) in chain(k*N+i)`, then `psi in chain(k*N+i+1)`
- F-persistence carries `F(psi)` from step n to step k*N+i

**Feasibility**: This chain is CONCRETE and avoids BX11 entirely. The depth-0 base case
becomes: given `F(psi) in chain(n)`, `psi in sigma_list`, and the chain uses
`self_resolving_fwd_step` at psi's visit, show `psi in chain(s)` for `s = n + (position
of psi's next visit)`. This is PROVABLE once we define the chain correctly.

**Effort**: ~200-400 LOC.
**Risk**: LOW-MEDIUM. The key lemma is that F-persistence holds until the visit step.

---

## Alternative 2: Weaken hintikka_step requirements

### Approach

Modify `hintikka_step` to not require the Until propagation clause (the 3rd conjunct at line
52 of Construction.lean). Then `hintikka_chain_exists` would work with a weaker step relation.

### Feasibility Assessment

**BLOCKED for coherence sorries, VIABLE as a simplification only.**

The `hintikka_step` definition (Construction.lean lines 45-52) has three clauses:
1. G-propagation: `G(chi) in h1 -> chi in h2`
2. H-backward: `H(chi) in h2 -> chi in h1`
3. Until defect propagation: if `phi U psi in h1` and `psi notin h1`, then `phi in h1 AND phi U psi in h2`

Removing clause 3 would break the guard condition of restricted Until/Since coherence. The
guard requires that at non-discharge steps, the guard formula `phi` remains in scope. Clause 3
is ESSENTIAL for this -- it's what guarantees `phi in chain(r)` for `r in [start, discharge)`.

Without clause 3, `hintikka_chain_exists` would still produce a chain (via clauses 1-2 only),
but the chain would NOT satisfy `restricted_forward_until_since_coherent root`. The coherence
sorries require Until tracking through the chain.

**Conclusion**: Weakening `hintikka_step` makes construction easier but makes the coherence
proofs impossible. This alternative is strictly worse than the current formulation.

**Verdict**: BLOCKED. Do not pursue.

---

## Alternative 3: Use defect_count argument differently

### Approach

Instead of the HintikkaPoint-level defect_count, use a BXPoint-level counting argument
directly on the `rr_fwd_chain`. The key: among sigma_list formulas with active F-obligations,
the BX11 fold at each `enriched_fwd_step` resolves SOME formula. Count how many formulas
CAN block resolution of psi. When that count reaches 0, psi must be resolved.

### Detailed Analysis

`defect_fwd_step_choice_spec` (proved) guarantees that at each step where `h_all` holds
(all defects active), some `w in defects` is directly resolved: `w in defect_fwd_step_choice M ...`.
The question is: does `psi` ever become the resolved formula?

The BX11 fold works as follows (from `resolving_enriched_fwd_exists`, lines 368-402):
- Given F(target), F(others)
- Finds `beta'` with `F(beta') in M` such that `beta'` implies all others
- Returns `M'` with `w in M'` for some `w = target or w in others`

The resolved formula `w` is determined by the fold's implementation -- which is existential
(`Classical.choose`). Without ADDITIONAL axioms to control which `w` gets chosen, the fold
could always choose `target` and never choose `psi`.

**The counting argument requires a new proof obligation**: for each OTHER formula that can be
resolved instead of psi, its resolution must either:
(a) decrease the number of "psi-blocking" formulas, or
(b) eventually force psi to be resolved

This requires knowing something about what happens AFTER each "wrong" resolution. If chi is
resolved at step k (instead of psi), what happens to psi at step k+1? The chain continues
with all F-obligations preserved (proved), but the BX11 fold at step k+1 might again choose chi.

**The cycle problem**: The BX11 fold could resolve {chi, chi, chi, ...} in a cycle, if
F(chi ∧ psi) ∈ M perpetually. Resolution 3 cannot break this cycle without showing F(chi ∧ psi)
must eventually leave the chain. But F-formulas are PERMANENT (rr_fwd_chain_F_obligation_forward,
proved), so F(chi ∧ psi) stays forever, and the BX11 fold is free to always choose chi.

**Verdict**: BLOCKED by the perpetual deferral cycle. The counting argument would require the
BX11 fold to be deterministic or for some structural property to break the cycle. Neither holds
in the current formulation.

**Resolution**: If we REPLACE the BX11 fold with a deterministic round-robin `self_resolving_fwd_step`
(Alternative 1b above), the counting argument works trivially: psi is resolved at its scheduled
visit. So this alternative is subsumed by Alternative 1b.

---

## Alternative 4: Literature-based approach

### Standard approach for completeness proofs (Burgess 1984, Reynolds 2003)

Literature-backed analysis (confirmed by D's round-36 survey):

Standard temporal logic completeness over ℤ uses one of:
1. **Filtration**: Build a quotient structure from the canonical model's subformula-closed
   equivalence classes. Until formulas are handled via the "eventuality preservation" step
   using a specific selection function. **Problem**: Filtration requires the original (infinite)
   canonical model to be defined, then quotiented. The BX canonical model lacks Until coherence,
   so filtration doesn't inherit it.

2. **Step-by-step model building** (Burgess's direct approach): Build the model point-by-point,
   at each step extending to an MCS that resolves one pending eventuality. Use a fixed enumeration
   of eventualities and cycle through them.

3. **Finite quasimodel construction** (Fisher-Wooldridge, Reynolds): Build a finite state machine
   satisfying an LTL formula, then unroll it into an infinite model. Requires the finite model
   property (which BX has, but only over restricted classes).

For BX specifically:
- **Approach 2 is the correct approach** and maps directly to the `self_resolving_fwd_step` chain
  (Alternative 1b). At step k, resolve eventuality sigma_list[k mod N]. The seed is `{psi, F(psi)} union g_content(M)` which is always consistent (proved).
- **The key missing piece** in the codebase is: the existing `rr_fwd_chain` uses the WRONG step
  function (`enriched_fwd_step` with BX11 fold). Replacing it with `self_resolving_fwd_step`
  would give a chain that provably resolves each formula in turn.

**The backward direction**: Standard completeness proofs for logics with Since (past) use a
SYMMETRIC construction going backward. The standard technique is: for each `P(psi) in M`,
use the "past temporal witness" construction (which the codebase has: `past_temporal_witness_seed_consistent`, proved). Build a backward chain using `defect_bwd_step` (lines 1699-1754, proved infrastructure), not the non-resolving `bwd_pred`.

**Finding**: The `defect_bwd_chain` (line 2208) uses `bwd_pred ... Formula.bot` which is
ALWAYS non-resolving (P(bot) never in MCS, so the resolving branch is never taken). This
confirms D's finding from round 36: the backward chain was incorrectly implemented. It should
use a resolving backward step when `P(psi) in M`.

**Verdict**: The literature-based approach CONFIRMS Alternative 1b and diagnoses the backward
chain correctly. Two concrete changes needed:
1. Replace `rr_fwd_chain`'s `enriched_fwd_step` with `self_resolving_fwd_step` for forward_F
2. Replace `defect_bwd_chain`'s `bwd_pred ... bot` with a resolving backward step for backward_P

Both changes require ~100-300 LOC each to prove the resulting chain's properties.

---

## Alternative 5: Direct countermodel construction

### Approach

Skip the quasimodel + BFMCS framework entirely. Build a `BFMCS` directly from BXPoints using
the axiom system properties (BX8-BX12) without going through HintikkaPoint chains.

### Feasibility Assessment

**VIABLE but EXPENSIVE -- equivalent to the round-36 recommended architecture.**

The `dd_countermodel` theorem (lines 1531-1557) already builds a countermodel via `dd_bfmcs`.
The sorry sites are the 3 coherence theorems (`dd_bfmcs_restricted_tc/buc/fuc`). To prove these
directly without the quasimodel framework:

- `restricted_temporally_coherent root`: For each `fam` in `families`, the `fam.mcs` is an
  FMCS satisfying G/H coherence for subformulas of root. The `dd_fmcs` construction has
  g-content propagation (proved), so temporal coherence follows from the G/H structure.
  **Status**: This is the simplest of the three. dd_chain_g_content and backward H are proved.
  The sorry at line 1517 may be closable with ~100 LOC using the existing infrastructure.

- `restricted_backward_until_since_coherent root`: For `S U psi in fam.mcs t` with `psi notin t`,
  there exists `s > t` in the FMCS with `psi in s` and guard in intermediate steps.
  **Problem**: The `dd_fmcs` chain does NOT guarantee this. The sorry at line 1522 is the
  forward_F problem for Until formulas. Without a resolving step, we cannot force `psi in chain(s)`.

- `restricted_forward_until_since_coherent root`: The Since analog of the above.

**Conclusion**: Alternative 5 (direct construction) reduces to the same core problem as the
eventualities: we need the chain to resolve Until/Since goals. Without the quasimodel or a
resolving chain, the coherence properties cannot be proved.

**One promising sub-path**: Prove `dd_bfmcs_restricted_tc` directly (the SIMPLEST sorry at
1517) using only the existing g-content / h-content propagation. This sorry might be closable
without any new chain construction.

**Verdict**: Alternative 5 is VIABLE for `dd_bfmcs_restricted_tc` (line 1517) specifically,
but BLOCKED for `dd_bfmcs_restricted_buc` (line 1522) and `dd_bfmcs_restricted_fuc` (line 1527).

---

## Recommended Approach

### Primary: Replace forward chain with resolving round-robin

**Implement `direct_resolve_chain` using `self_resolving_fwd_step`** (Alternative 1b):

```
direct_resolve_chain M₀ h₀ sigma_list (n : Nat) :=
  if n = 0 then M₀
  else let psi := sigma_list[(n-1) mod sigma_list.length]
       self_resolving_fwd_step (direct_resolve_chain ... (n-1)) ... psi (F-psi-proof)
```

This chain has:
- `psi in chain(n)` when `n mod |sigma_list| = position(psi) + 1` and `F(psi) in chain(n-1)`
- F-persistence: `F(psi) in chain(n)` → `F(psi) in chain(n+1)` (via `self_resolving_fwd_step_F_target`)
- Combined: `F(psi) in chain(n)` → `psi in chain(m)` for `m = n + (scheduled steps to psi's visit)`

**Forward_F proof outline**:
1. `F(psi) in chain(n)` -- hypothesis
2. Let `k = |sigma_list|, pos = index of psi in sigma_list`
3. `s = n + (pos - n mod k + k) mod k + 1` -- next visit step
4. F-persistence gives `F(psi) in chain(s-1)` (trivial induction)
5. `self_resolving_fwd_step_target` gives `psi in chain(s)` directly

**Backward_P**: Replace `defect_bwd_chain`'s non-resolving step with `defect_bwd_step` (the
resolving backward step at line 1699, with infrastructure proved). Analogous chain construction.

### Secondary: Close `dd_bfmcs_restricted_tc` directly (line 1517)

The `restricted_temporally_coherent root` property is weaker than the Until/Since properties.
It requires only that the FMCS satisfies G/H propagation for subformulas of `root`. The
`dd_fmcs` chain has `dd_chain_g_content` (proved) and backward H (proved). A direct proof
of `dd_bfmcs_restricted_tc` using only these facts should close sorry 1517 in ~100 LOC.

### Full solution: Oracle + BFMCS replacement (as recommended in round 36)

For all 8 sorries, the round-36 architecture remains correct:
1. `self_resolving_fwd_step` chain closes forward_F (sorries 1413, 1457, 1464, 2196)
2. Symmetric resolving backward chain closes backward_P (sorries 1464, 2289)
3. New BFMCS from quasimodel chain closes Until/Since coherence (sorries 1517, 1522, 1527)

The alternative approaches (1b, 4, 5) are COMPATIBLE with round-36 architecture, not competing.
They provide more concrete implementation paths for specific sorry sites.

---

## Evidence and Examples

### Evidence for Alternative 1b viability

From `self_resolving_fwd_step_target` (line 1981): given `F(psi) in M`, we get `psi in M'`
directly (not just `psi in M' OR F(psi) in M'`). This is the key difference from
`enriched_fwd_step` which only gives the disjunction.

The infrastructure is completely proved:
- `F_and_self_F_mcs` (line 1950): `F(psi) in M → F(psi ∧ F(psi)) in M`
- `self_resolving_fwd_step_mcs` (line 1967): result is MCS
- `self_resolving_fwd_step_target` (line 1981): `psi in M'`
- `self_resolving_fwd_step_F_target` (line 1987): `F(psi) in M'`
- `self_resolving_fwd_step_g_content` (line 1993): `g_content(M) ⊆ M'`

### Evidence for backward chain diagnosis

Comment at line 2200-2205: `defect_bwd_chain` uses `bwd_pred M hM Formula.bot` because
"P(bot) is never in any MCS". This means the chain is ALWAYS in non-resolving mode.
`defect_bwd_step` (proved, line ~1699) provides the resolving backward step using
`past_defect_resolving_seed` (proved, lines 1657-1710). The sorry at 2289 could be
addressed by switching to a resolving backward chain.

### Evidence that `dd_bfmcs_restricted_tc` is the easiest sorry

`restricted_temporally_coherent root` (defined in the codebase context) requires only:
- Forward: `G(phi) in fam.mcs t → phi in fam.mcs t'` for `t ≤ t'` -- this is `dd_chain_g_content`
- Backward: `H(phi) in fam.mcs t → phi in fam.mcs t'` for `t' ≤ t` -- this is `dd_chain_backward_H_helper`

Both are proved. The sorry at 1517 may be a case of wiring these existing lemmas together.

---

## Confidence Level

- **Alternative 1b (self_resolving chain)**: HIGH confidence this works for forward_F (sorries
  1413, 1457, 2196). The key lemma (F-persistence to scheduled step) is straightforward.
- **Backward chain fix**: MEDIUM confidence. Requires defining a new resolving backward chain
  using `defect_bwd_step` and proving symmetric properties.
- **`dd_bfmcs_restricted_tc` direct closure**: HIGH confidence (line 1517 only). Should close
  with existing proved lemmas.
- **`dd_bfmcs_restricted_buc/fuc` (lines 1522, 1527)**: LOW confidence via any alternative.
  These genuinely require Until/Since resolution, which needs the oracle + BFMCS architecture.
- **Full solution (all 8 sorries)**: MEDIUM confidence via round-36 architecture. Implementation
  is ~800-1200 LOC, the largest work package identified.

---

## Open Questions

1. **Does `dd_bfmcs_restricted_tc` follow directly from existing lemmas?** A 30-minute
   implementation attempt could confirm or refute. If yes, it's easy to close sorry 1517
   independently of the main architecture.

2. **What is `restricted_temporally_coherent` defined as?** The definition is in
   `Algebraic/RestrictedParametricTruthLemma.lean` (imported at the top of RootScopedChain).
   The exact definition determines whether `dd_chain_g_content` + backward H suffice.

3. **Is there a cleaner entry point for the oracle construction?** Round 36 identified that
   `bx_forward_witness` gives a one-step Oracle. But for the full quasimodel chain, we also
   need the `sigma_signature` projection to produce a valid `HintikkaPoint`. Does
   `EnrichedClosure` already contain all necessary formulas?

4. **Can `self_resolving_fwd_step` be substituted into `defect_fwd_chain`?** The `defect_fwd_chain`
   uses `defect_fwd_step_choice` in the `h_all` case. If `self_resolving_fwd_step` is used
   instead, the sorry at 2196 (`defect_fwd_chain_forward_F`) would close with the same
   round-robin argument. But `defect_fwd_chain`'s signature expects a `defect_step` interface;
   swapping would require minor refactoring.

5. **Are sorries 1457 and 1464 truly downstream of 1413?** The comments suggest so, but
   if the backward chain fix is independent of `rr_fwd_chain_forward_F`, sorry 1464 could
   be addressed separately.
