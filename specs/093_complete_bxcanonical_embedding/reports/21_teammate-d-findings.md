# Teammate D Findings: Round 20 — Strategic Horizons

## Key Findings

### 1. Architectural Reality Check: Two Sorry Sites, Not One

The ROAD_MAP.md states there are 6 sorries "all in RootScopedChain.lean." This description is
outdated. A direct examination of the codebase reveals two files with sorries on the active
completeness path:

**RootScopedChain.lean** (6 sorries):
- Line 1295: `rr_fwd_chain_forward_F` — PRIMARY BLOCKER
- Line 1326: `dd_fmcs_forward_F` (t < 0 case) — depends on primary blocker
- Line 1333: `dd_fmcs_backward_P` — symmetric to forward_F
- Line 1386: `dd_bfmcs_restricted_tc` — restricted temporal coherence
- Line 1391: `dd_bfmcs_restricted_buc` — restricted backward Until/Since coherence
- Line 1396: `dd_bfmcs_restricted_fuc` — restricted forward Until/Since coherence

**CanonicalModel.lean** (5 sorries, partially dead code):
- Line 518: `bx_fmcs_forward_F` — DEAD CODE (not on active path)
- Line 525: `bx_fmcs_backward_P` — DEAD CODE (not on active path)
- Line 614: `bx_bfmcs_buc` — DEAD CODE (not on active path)
- Line 619: `bx_bfmcs_fuc` — DEAD CODE (not on active path)
- Lines 649, 655: `bx_bfmcs_restricted_buc/fuc` — possibly DEAD CODE

The `Completeness.lean` theorem calls `dd_countermodel` from `RootScopedChain.lean`, not from
`CanonicalModel.lean`. The `bx_countermodel` in CanonicalModel.lean exists in parallel but is
not the active completeness path.

**Strategic implication**: The CanonicalModel.lean sorries are candidates for aggressive pruning
(either deletion or `sorry`-propagation without blocking path closure). The real problem is
concentrated in `rr_fwd_chain_forward_F` and its two restricted coherence consequences
(`dd_bfmcs_restricted_buc`, `dd_bfmcs_restricted_fuc`).

### 2. The Dependency Chain Is Simpler Than Assumed

Tracing the dependencies from `bx_completeness` backward:

```
bx_completeness
  └── dd_countermodel (RootScopedChain.lean:1400)
        ├── dd_bfmcs_restricted_tc (sorry, line 1386)
        │     └── dd_fmcs_forward_F (sorry) and dd_fmcs_backward_P (sorry)
        │           └── rr_fwd_chain_forward_F (sorry, PRIMARY)
        ├── dd_bfmcs_restricted_buc (sorry, line 1391)
        └── dd_bfmcs_restricted_fuc (sorry, line 1396)
```

**Key observation**: `dd_bfmcs_restricted_buc` and `dd_bfmcs_restricted_fuc` are NOT downstream
of `rr_fwd_chain_forward_F`. They are siblings of `dd_bfmcs_restricted_tc`. They deal with
Until/Since coherence (backward Until witnesses, forward Until/Since witnesses) rather than
F/P temporal coherence.

This means the forward_F blocker is NOT the sole blocker — the buc and fuc sorry sites are
independent problems. However, examining the `Quasimodel/Realization.lean` infrastructure:
`bx_until_eventuality_resolution` and `bx_since_eventuality_resolution` were proved sorry-free.
The analogous `dd_bfmcs_restricted_buc/fuc` proofs may be closeable by adapting the
quasimodel approach to the `dd_fmcs`/`dd_bfmcs` context.

### 3. The Two-Layer Chain Architecture Creates Leverage

The `dd_fmcs` uses the `rr_fwd_chain` (round-robin forward chain over `sigma_list`) as its
forward sub-chain. The sigma_list is `(extendedDeferralClosure φ).toList` — a finite list of
formulas derived from the target formula φ.

**Critical insight**: The round-robin structure visits each formula in sigma_list in cyclic order.
The forward_F problem is that F(ψ) can remain in every chain step without ψ ever appearing.
The round-robin guarantees INFINITE VISITS to ψ's schedule slot — but the existing step function
(`enriched_fwd_step`) uses a non-deterministic Lindenbaum extension that may always choose F(ψ)
over ψ.

The sigma_list restriction is actually a STRENGTH from the strategic viewpoint: the set of
F-formulas we need to resolve is bounded by |sigma_list|, which is finite. This finite bound is
exactly what the defect-discharge approach (used in `Construction.lean` for Until/Since) relied on.

**Strategic observation**: The Until/Since eventuality problem was solved using a well-founded
measure (defect_count on sigma-closure). The forward_F problem has the same structure in
principle — but the existing `rr_fwd_chain` does NOT define a well-founded measure because
(per the comment at line 1265-1272) "the defect set can fluctuate: formulas can be resolved
then lost again." This fluctuation is the fundamental obstacle.

### 4. Is There a Route Around the Chain Entirely?

**Alternative A: Exploit the dd_bfmcs Structure Directly**

The `dd_bfmcs` is defined with a `families` field containing all modal-equivalent FMCSes.
The `restricted_temporally_coherent` property needs: for each FMCS in families, if F(ψ) ∈ fam.mcs(t)
for ψ ∈ deferralClosure(root), then ∃ s > t with ψ ∈ fam.mcs(s).

The key question: can we define a *different* chain for the BFMCS families that avoids the
forward_F problem? The existing `dd_fmcs` uses `rr_fwd_chain` which is the problematic
construction. If we instead used the quasimodel `QuasimodelChain` from `Construction.lean`
for each family, we would have:

- QuasimodelChain already resolves eventuality obligations via defect-discharge
- The defect count strictly decreases at each step (well-founded)
- BUT: QuasimodelChain produces HintikkaPoints (Hintikka sets), not BXPoints (MCS)

**Assessment**: Bridging from HintikkaPoints to BXPoints is exactly what `Realization.lean`
does for Until/Since. The same lifting could theoretically work for F/P obligations.
This is a high-complexity route but has mathematical precedent in the codebase.

**Alternative B: Use deferralClosure Directly in the Chain Construction**

The `rr_fwd_chain` takes sigma_list as a list of formulas to resolve round-robin. If instead
of a round-robin schedule we used a DEFECT-ORDERED schedule — at each step, resolve the
F-formula with the highest defect count — we would have a well-founded termination argument.

The obstacle: defect count itself is not well-founded when formulas can be un-resolved (appear
resolved at step n, then re-appear as defects at step n+2). This was explicitly documented in
the code comment.

The fix: the round-robin chain must be replaced with a construction that ACCUMULATES resolved
F-obligations. Once ψ is resolved (ψ ∈ chain(n)), the next step must either:
(a) keep ψ ∈ chain(n+1), or
(b) transition so that F(ψ) ∉ chain(n+1) either (making the obligation discharged)

This is the "ordered-discharge" approach from Plan v18. The never-resolved count — the count
of F-formulas in sigma_list that have NEVER appeared in any step — is a valid well-founded
measure because it is bounded by |sigma_list| and strictly decreases each time a formula
is resolved for the first time.

**Alternative C: Bypass the Chain and Use a Finite Model**

The project ROAD_MAP.md explicitly notes (Dead End #10): "FMP bridge to completeness does NOT
provide a shortcut." This was investigated in task 86. The reason: FMP produces a finite
model but the truth lemma connecting FMP to BX completeness requires the same chain/canonical
model machinery.

However, the assessment in the ROAD_MAP was for the *full* completeness theorem. For the
*restricted* variants (`restricted_temporally_coherent`, `restricted_backward_until_since_coherent`,
`restricted_forward_until_since_coherent`), the finite restriction to `subformulaClosure(root)` or
`deferralClosure(root)` brings the problem much closer to a finite model argument.

**Key question**: Can `dd_bfmcs_restricted_buc` and `dd_bfmcs_restricted_fuc` be proved using
the quasimodel/filtration infrastructure already in `Quasimodel/` and `Filtration/`? These
modules were built precisely for Until/Since eventuality obligations — which are exactly what
buc and fuc coherence require.

**Assessment**: The buc and fuc sorries are likely closeable by adapting the machinery from
`LocusControl.lean` (`bx_until_eventuality_resolution'`, `bx_since_eventuality_resolution'`)
to the `dd_bfmcs` context. This does NOT require solving the forward_F problem. If true, only
the restricted_tc sorry (which depends on forward_F) would remain after buc and fuc are closed.

### 5. Long-Term Investment Assessment

After 20+ research rounds, the state is:
- **6,400+ lines of sorry-free infrastructure** built across 13+ files
- **The Until/Since problem was fully solved** (5 Frame.lean sorries closed by tasks 98+102)
- **The forward_F problem has resisted 19 research rounds** with 21+ documented dead ends

The investment is real and the infrastructure is valuable. But the pattern suggests the
forward_F problem may require a genuinely different proof-theoretic insight, not incremental
refinement of the current chain construction.

**Investment breakpoint analysis**:
- If Plan v18 (ordered-discharge, never-resolved count) works: ~24 additional hours to close
- If Plan v18 fails: the problem may require architectural rethinking
- Current probability of Plan v18 success: 55-65% (per prior rounds)

The project's ROAD_MAP says: "Only the algebraic/canonical model approach is pursued for
completeness." This is a deliberate choice that forecloses decidability-based shortcuts. The
reasoning is that the representation theorem is the scientific contribution. This constraint
is CORRECT from a scientific standpoint — but it means the forward_F problem cannot be
sidestepped.

### 6. Radical Alternatives That Have NOT Been Tried

**R1: Dovetailing at the BFMCS Level (Not the FMCS Level)**

The current approach builds a single FMCS (int_chain) and then wraps it in a BFMCS. The
forward_F problem is at the FMCS level (each int_chain must independently satisfy forward_F).

An alternative: build a BFMCS whose families collectively satisfy forward_F via the modal
structure. For formula ψ with F(ψ) ∈ chain(t), we need some future s > t with ψ ∈ chain(s).
The BFMCS modal_forward property says: for any Box formula holding in any family at time t,
it holds in all other families at time t. This modal coherence could potentially be exploited:
if ψ holds in SOME family at time s, and ψ is Box-closed... but ψ need not be Box-closed.

**Assessment**: Does not provide direct leverage for forward_F. The non-Box formulas are not
transmitted across families.

**R2: Infinite Descent / Koenig's Lemma**

The forward_F problem is: given an infinite chain where F(ψ) holds at every step, we need ψ
to eventually hold. This is a compactness/completeness argument in disguise.

Koenig's Lemma states: every infinite finitely-branching tree has an infinite branch. The
sigma_list is finite. The chain steps produce MCSes from a discrete set (sigma_list
restricted). If the set of MCS values (restricted to sigma_list propositions) is FINITE, then
by the pigeonhole principle, the chain must revisit some MCS value repeatedly — and by
`enriched_fwd_step_resolves_one` (proved sorry-free), each visit resolves at least one
F-formula.

**Assessment**: This IS the never-resolved count argument from Plan v18, stated in Koenig's
lemma terms. The finite model property of BXPoint sets restricted to sigma_list is the key
premise. This is mathematically sound but requires formalizing the pigeonhole step in Lean.

**R3: Directly Prove via BX Axioms That F(ψ) Cannot Persist Forever in a Complete Theory**

Theorem statement: In any MCS M over the BX axiom system, if F(ψ) ∈ M, then the canonical
chain built from M must contain ψ at some future step.

This is not directly provable from BX axioms alone — the axioms constrain DERIVATIONS, not
CHAIN CONSTRUCTIONS. The Lindenbaum extension's `.choose` is not constrained by the axioms.
This is the fundamental gap the entire task 93 effort is trying to bridge.

### 7. The buc and fuc Sorries: Closer Than Estimated

`dd_bfmcs_restricted_buc` and `dd_bfmcs_restricted_fuc` are about Until/Since coherence in
the `dd_fmcs` chain. Specifically:
- **buc**: if (φ U ψ) witness r exists in chain, then φ holds at all intermediate steps
- **fuc**: if φ U ψ holds in chain, then a witness r exists

These correspond exactly to the Until/Since eventuality obligations that `bx_until_backward`
and `bx_until_eventuality_resolution` handle (both proved sorry-free via tasks 98+102).

The `dd_fmcs` chain has g_content propagation (`dd_chain_g_content` proves g_content(chain(t)) ⊆ chain(t')),
which is the key property that Realization.lean uses to lift quasimodel chains to BXPoint chains.

**Strategic insight**: The buc and fuc sorries may be provable NOW using the existing quasimodel
infrastructure, independently of forward_F. Proving them would reduce the sorry count to 3
(rr_fwd_chain_forward_F, dd_fmcs_forward_F for t<0, dd_bfmcs_restricted_tc).

## Recommended Approach

**Tier 1 (immediate, 5-10 hours): Close the buc and fuc sorries**

The `dd_bfmcs_restricted_buc` and `dd_bfmcs_restricted_fuc` at lines 1391 and 1396 are
likely closeable by delegating to the existing `bx_until_eventuality_resolution` and
`bx_until_backward` (proved sorry-free). The proof structure would:

1. Show that `dd_fmcs` chain has the same g_content propagation properties as `bx_fmcs`
2. Apply the quasimodel lemmas (`LocusControl.lean`) to get Until/Since witnesses
3. Translate witnesses back to chain indices

This approach does NOT require solving forward_F. Success would reduce active sorries from 6 to 3.

**Tier 2 (24-40 hours): Plan v18 for forward_F**

With buc and fuc closed, the remaining barrier is forward_F (and its t<0 case). Plan v18
(ordered-discharge chain, never-resolved count) remains the best documented approach.

The never-resolved count is well-founded:
- Bounded by |sigma_list| (finite)
- Strictly decreasing when a formula is resolved for the first time
- Cannot increase (once resolved, "never-resolved" count is decremented permanently)

This requires replacing `rr_fwd_chain` with a new chain that tracks which sigma_list
formulas have ever been resolved and prioritizes unresolved formulas.

**Tier 3 (contingency): If Plan v18 fails after 40 hours**

Consider whether the forward_F problem is actually provable for the RESTRICTED case
(`deferralClosure(root)` is finite). A finite argument via the following:
- sigma_list = deferralClosure(root).toList has length |sigma_list|
- The set of distinct MCS "sigma-signatures" (restrictions to sigma_list) is finite
- The chain must eventually revisit a sigma-signature
- By `enriched_fwd_step_resolves_one`, each resolving step resolves one F-formula
- By the finite return time argument (Ramsey/pigeonhole on sigma-signatures), every F-formula
  must eventually be resolved

This argument may be formalizable in Lean using `Finset.exists_ne_map_eq_of_card_lt_of_maps_to`
(pigeonhole). This is the same mathematical insight as Plan v18 but approached via finite
state arguments rather than well-founded induction on a never-resolved count.

## Evidence and Examples

From `RootScopedChain.lean:1265-1272`:
```
-- The defect set {χ | F(χ) ∈ chain(m) ∧ χ ∉ chain(m)} can fluctuate:
-- formulas can be resolved (χ ∈ chain(m+1)) but then lost again at a later
-- step (χ ∉ chain(m+2) while F(χ) persists)
-- So the defect count is NOT a valid well-founded measure for induction.
```

From `CanonicalModel.lean:491-508`:
```
-- BLOCKED: unprovable for scheduling chain (see obstacle analysis above)
-- Root cause: at resolving steps for chi, the Lindenbaum seed does NOT
-- include f_carry. So F(psi) for psi != chi may be lost. Once lost
-- (G(neg psi) appears), the loss is permanent.
```

The buc/fuc connection to existing infrastructure:
- `LocusControl.lean:bx_until_eventuality_resolution'` — proved sorry-free (task 98)
- `Realization.lean:until_forward_seed` — proved sorry-free
- `dd_fmcs` has g_content propagation via `dd_chain_g_content` — proved sorry-free

## Confidence Level

**High (85%)** on the immediate priority: the buc and fuc sorries are closeable independently
of forward_F, using the existing quasimodel infrastructure. This has not been systematically
attempted — it is a gap in the task 93 investigation.

**High (90%)** that the never-resolved count approach (Plan v18) is the correct mathematical
route for forward_F. The well-foundedness argument is sound; the formalization challenge is
significant but not insurmountable.

**Medium (60%)** on the timeline: 24 hours for buc+fuc+forward_F is optimistic. 40-60 hours
is realistic with Lean 4 formalization overhead.

**Low (20%)** that any radical alternative (finite state pigeonhole, Koenig's lemma, dovetailing
at BFMCS level) is meaningfully faster than Plan v18. These are equivalent arguments in different
mathematical clothing.

**Recommendation**: Before committing to the full Plan v18 chain replacement, invest 5-10 hours
specifically in `dd_bfmcs_restricted_buc` and `dd_bfmcs_restricted_fuc`. Success would provide
psychological momentum and reduce the sorry count significantly. Then commit to Plan v18 for
forward_F with high confidence in its eventual success.
