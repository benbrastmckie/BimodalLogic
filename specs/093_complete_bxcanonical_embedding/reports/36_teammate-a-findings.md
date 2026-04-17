# Teammate A: Quasimodel Bridge Deep Study

## Executive Summary

After exhaustive reading of all 6 Quasimodel files (~2132 LOC), both Filtration
files, and all key dependent files (Frame.lean, RootScopedChain.lean sorry sites,
TemporalCoherence.lean, UntilSinceCoherence.lean), the quasimodel bridge approach
faces a **fundamental type/architecture mismatch** that cannot be patched without
either (a) abandoning the existing chain infrastructure entirely or (b) adding a
completely new chain-bypass pathway.

The 8 sorry sites in RootScopedChain.lean are NOT directly about Until/Since
coherence at the quasimodel level — they are about three distinct properties on
the `dd_bfmcs` structure which operates over `Int`-indexed FMCS families and
uses round-robin and defect-driven `Set Formula` chains. The quasimodel
infrastructure operates at the `BXPoint` / `HintikkaPoint` level and produces
`HintikkaRawChain` objects with `BXPoint` witnesses. There is no existing bridge
lemma connecting the two worlds.

The critical insight: **the quasimodel chain's oracle (`HintikkaStepOracle`) has
never been constructed**. The entire `Realization.lean` layer simply delegates to
`Frame.lean`'s `bx_until_eventuality_resolution`, which itself is a sorry-carrying
function. The quasimodel pipeline is built but has no input.

---

## Key Findings

### Finding 1: The 8 Sorry Sites Are Three Distinct Properties

The 8 sorry sites decompose as follows:

**Sites 1413, 1457 (depth-0 base case of rr_fwd_chain_forward_F):**
- These are inside the proof of `rr_fwd_chain_forward_F`, in the induction on
  `f_nesting_depth`. The depth-0 case has no proven path.
- `rr_fwd_chain_forward_F` is the inner workhorse: for `F(ψ) ∈ rr_fwd_chain(n)`,
  find `s > n` with `ψ ∈ rr_fwd_chain(s)`.
- The obstruction: BX11 fold can perpetually defer ψ by resolving other targets
  at each visit of ψ's schedule slot.

**Sites 1464 (dd_fmcs_backward_P):**
- `dd_fmcs_backward_P`: `P(ψ) ∈ dd_fmcs(t) → ∃ s < t, ψ ∈ dd_fmcs(s)`.
- The backward chain uses `bwd_pred ... bot` (non-resolving mode). P-obligations
  persist forever but the chain never places ψ directly.

**Sites 1517, 1522, 1527 (dd_bfmcs restricted coherence):**
- `dd_bfmcs_restricted_tc`: For each FMCS family in the BFMCS, restricted F/P
  temporal coherence for `deferralClosure root`.
- `dd_bfmcs_restricted_buc`: Restricted backward Until/Since coherence.
- `dd_bfmcs_restricted_fuc`: Restricted forward Until/Since coherence.
- These directly depend on the forward_F / backward_P properties above.

**Sites 2196, 2289 (defect chain forward_F and backward_P):**
- `defect_fwd_chain_forward_F`: Same obstruction as rr_fwd_chain_forward_F but
  for the defect_fwd_chain (which uses a different step mechanism).
- `defect_bwd_chain_backward_P`: Backward analog with the same structure.

### Finding 2: HintikkaStepOracle Has Never Been Constructed

The `HintikkaStepOracle` signature (Construction.lean:477-483) requires:
```
∀ h : HintikkaPoint Sigma,
  Formula.untl φ ψ ∈ h.formulas → ψ ∉ h.formulas →
  ∃ wh' : WitnessedHintikka Sigma, hintikka_step h wh'.point ∧ ...
```

This oracle is the ONLY input to `hintikka_chain_exists` (the Phase 3 main
theorem, which IS proved). But looking at ALL of Realization.lean, LocusControl.lean,
and the rest of the quasimodel pipeline:

- `until_eventuality_resolution` (Realization.lean:428-433) delegates directly to
  `bx_until_eventuality_resolution` from Frame.lean
- `bx_until_eventuality_resolution'` (LocusControl.lean:31-37) also delegates
- Neither constructs the oracle

The oracle construction was PLANNED (as the Phase 5 "chain realization" step) but
was never implemented. The pipeline is:

```
bx_forward_witness (Frame.lean, PROVED)
  ↓ use to build HintikkaStepOracle
    ↓ feed to hintikka_chain_exists (PROVED)
      ↓ extract HintikkaRawChain
        ↓ ??? → forward_F for dd_bfmcs families
```

Step 2 (oracle construction) and step 4 (connecting to dd_bfmcs) are both missing.

### Finding 3: The G-Persistence Obstacle Is Fatal for Chain Realization

Realization.lean:368-396 documents a proven-unsolvable obstacle in the Phase 5
chain realization approach:

**Obstacle A**: `g_content(v_i) ⊆ w_{i+1}.formulas` fails when `G(χ) ∈ v_i` with
`G(χ) ∉ Sigma`. The strict seed approach (C.4) forces `¬χ ∈ v_{i+1}` when
`χ ∈ Sigma` and `χ ∉ h_{i+1}`, while bx_le forces `χ ∈ v_{i+1}`. Contradiction.

**Obstacle B (G-persistence failure)**: G-formulas do NOT persist through
Hintikka chains. For `G(χ) ∈ h_i` with `G(χ) ∈ Sigma`, `hintikka_step` gives
`χ ∈ h_{i+1}`, but `G(χ) ∈ h_{i+1}` is NOT guaranteed. Without G-persistence,
the chain cannot realize more than 2 steps coherently.

This means the **"quasimodel chain → BXPoint chain" realization step is
mathematically blocked** by current infrastructure.

### Finding 4: The Architecture Gap Between Quasimodel and dd_bfmcs

The three restricted coherence predicates need proofs for `dd_bfmcs`:

**restricted_temporally_coherent (line 1517)** requires: for every family in
`dd_bfmcs.families`, for every `φ ∈ deferralClosure root`,
- `F(φ) ∈ fam.mcs t → ∃ s > t, φ ∈ fam.mcs s`
- `P(φ) ∈ fam.mcs t → ∃ s < t, φ ∈ fam.mcs s`

These are exactly `rr_fwd_chain_forward_F` and `defect_bwd_chain_backward_P`
for the respective chain directions.

**restricted_forward/backward_until_since_coherent** require witnesses for
Until/Since formulas in `subformulaClosure(root)` in the `dd_bfmcs.families`.
By BX12, `F(ψ) → ⊤ U ψ`, so Until coherence reduces to forward_F (which is blocked).
Similarly for Since and backward_P.

The quasimodel bridge would need to:
1. For each `FMCS fam ∈ dd_bfmcs.families` and each `φ ∈ deferralClosure root`
   with `F(φ) ∈ fam.mcs t`
2. Identify a starting BXPoint w (= the MCS at time t)
3. Project to a HintikkaPoint h0 using sigma_signature
4. Run hintikka_chain_exists to get a HintikkaRawChain
5. Extract the last point's BXPoint witness
6. Map its time coordinate back to the dd_chain's Int index

Steps 3-6 all require new infrastructure that does not exist.

### Finding 5: What the Quasimodel Infrastructure Does Provide (Correctly)

The quasimodel layer IS complete and sorry-free for:
- `hintikka_chain_exists`: proven at Construction.lean:594-659
- `hintikka_chain_exists_since`: proven at Construction.lean:769-824
- `chain_step_seed_consistent`: proven at Construction.lean:676-690
- `hintikka_step_target_decrease`: proven at Construction.lean:275-299
- All defect counting infrastructure in DefectChain.lean and SigmaOrdering.lean
- All enriched closure infrastructure in EnrichedClosure.lean

The abstract existence theorem for quasimodel chains is complete. What's missing
is connecting it to the concrete chain constructions used in RootScopedChain.lean.

### Finding 6: The BX12 Reduction Helps But Is Insufficient

BX12: `F(ψ) → ⊤ U ψ` (CanonicalChain.lean:61-74, proved).

This means `F(φ) ∈ chain(n) → (⊤ U φ) ∈ chain(n)`. For the restricted forward
Until/Since coherence (site 1527), if `φ U ψ ∈ fam.mcs t` and `φ U ψ ∈ subformulaClosure(root)`,
we need a witness time s ≥ t with ψ ∈ fam.mcs s and φ in all intermediate steps.

BX10 gives `F(ψ) ∈ fam.mcs t`. BX12 converts to `(⊤ U ψ) ∈ fam.mcs t`.
This REDUCES the Until coherence problem to forward_F for ψ (within `deferralClosure root`,
since ψ is a subformula of root and deferralClosure ⊇ subformulaClosure by definition).

So forward_F IS the master bottleneck: solving forward_F solves all three restricted
coherence predicates.

---

## Construction Blueprint for Quasimodel Bridge

### Overview

The quasimodel bridge would need to prove forward_F for the `rr_fwd_chain` (and
`defect_fwd_chain`) by constructing:

1. A `HintikkaStepOracle` backed by `bx_forward_witness`
2. A proof that this oracle's chain witnesses live in the Int-indexed family
3. A mapping from chain position to Int-index

### Component A: Oracle Construction via bx_forward_witness

**Definition needed** (new):
```lean
noncomputable def hintikka_oracle_from_forward_witness
    (Sigma : Finset Formula) (φ ψ : Formula)
    (h_sigma_neg : ∀ f ∈ Sigma, Formula.neg f ∈ Sigma) :
    HintikkaStepOracle (Sigma := Sigma) φ ψ
```

**Core idea**: Given `h : HintikkaPoint Sigma` with `φ U ψ ∈ h.formulas` and
`ψ ∉ h.formulas`, find a BXPoint w backing h (from `ChainWitnessed`). Then:
1. Use `until_F_mcs` to get `F(ψ) ∈ w.formulas`
2. Apply `bx_forward_witness` to get BXPoint v with `bx_le w v` and `ψ ∈ v.formulas`
3. Project v to `sigma_signature v Sigma h_sigma_neg` to get next HintikkaPoint
4. Verify `hintikka_step h (sigma_signature v Sigma h_sigma_neg)`

**The G-persistence problem surfaces here**: `hintikka_step` requires:
- G-propagation: `G(χ) ∈ h.formulas → χ ∈ next.formulas`
- H-backward: `H(χ) ∈ next.formulas → χ ∈ h.formulas`
- Until defect propagation

For the G-propagation: `G(χ) ∈ h.formulas` means `G(χ) ∈ w.formulas` (since
`h.formulas ⊆ w.formulas` by ChainWitnessed). Then `bx_le w v` gives `χ ∈ v.formulas`.
Since `χ ∈ Sigma` (if `G(χ) ∈ Sigma`), `χ ∈ sigma_signature v Sigma`. This part WORKS.

For H-backward: `H(χ) ∈ (sigma_signature v Sigma).formulas` means `H(χ) ∈ v.formulas`
and `H(χ) ∈ Sigma`. Need `χ ∈ h.formulas`. This requires `χ ∈ w.formulas` (via
`bx_H_forward h_le_wv` for some BXPoint with `bx_le ? v`). But we have `bx_le w v`,
not `bx_le v w`. So H-backward FAILS in general.

**This is the core gap**: `bx_forward_witness` gives a FORWARD step `w → v`, but
`hintikka_step` requires H-backward coherence which needs a BACKWARD linking from v to w.
In the canonical model, bx_le is not symmetric. The H-backward condition requires
`H(χ) ∈ v → χ ∈ w`, which is equivalent to `bx_le w v` being the CORRECT direction.

Actually rereading: `bx_H_forward (h_le : bx_le w v) (h_Hf_v : H(f) ∈ v) : f ∈ w`.
So `bx_le w v` and `H(f) ∈ v` gives `f ∈ w`. This means the H-backward clause of
`hintikka_step h1 h2` (which says `H(χ) ∈ h2.formulas → χ ∈ h1.formulas`) is
**satisfiable** IF we can construct v with `bx_le w v` AND there is a BXPoint `w'`
backing h1 with `bx_le w' v` as well. But we'd need `w' = w` (the backing BXPoint of h1).

**Corrected assessment**: If `w` backs `h1` (i.e., `h1.formulas ⊆ w.formulas`) and
we take the forward step to `v` via `bx_forward_witness` with `bx_le w v`, then:
- H-backward clause: `H(χ) ∈ sigma_signature v → χ ∈ h1.formulas`
- Since `H(χ) ∈ sigma_signature v → H(χ) ∈ v.formulas`
- And `bx_le w v → H(χ) ∈ v.formulas → χ ∈ w.formulas` (bx_H_forward)
- But we need `χ ∈ h1.formulas`, not just `χ ∈ w.formulas`.
- Since `h1.formulas ⊆ w.formulas` is forward inclusion only, `χ ∈ w.formulas`
  does NOT imply `χ ∈ h1.formulas`.

**CONCLUSION**: The H-backward clause of hintikka_step CANNOT be satisfied by a
naive `bx_forward_witness` step, unless `χ ∈ Sigma` (Sigma-membership would help
via sigma_signature if we also know `χ ∈ sigma_signature w Sigma`).

**More precise analysis**: Since `w` backs h1 (any `h1.formulas` is in `w.formulas`)
AND `h1.formulas` = `sigma_signature w Sigma h_neg` (by construction via sigma_signature),
AND `χ ∈ Sigma`, then:
- `χ ∈ w.formulas → χ ∈ sigma_signature w Sigma → χ ∈ h1.formulas`.
- So: `bx_H_forward(bx_le w v)(H(χ) ∈ v) → χ ∈ w → χ ∈ h1.formulas`.

This chain WORKS IF we always track h1 = sigma_signature w Sigma and use w to back h1.
The key assumption is that `h1 = sigma_signature w Sigma` (not just a subset),
which is exactly what `WitnessedHintikka` combined with sigma_signature gives.

**So the oracle construction is feasible IF**: each Hintikka point in the chain is
constructed as `sigma_signature w Sigma h_neg` for some BXPoint `w`. This is what
the WitnessedHintikka structure enables (it carries the backing BXPoint).

### Component B: Int-Indexed Embedding

The deepest gap: the quasimodel chain produces a FINITE list `c : HintikkaRawChain Sigma`.
The `dd_bfmcs` needs the witness at an INFINITE Int-indexed position.

The `rr_fwd_chain` is indexed by `Nat`. Given `F(ψ) ∈ rr_fwd_chain(n)`, we need
`s > n` with `ψ ∈ rr_fwd_chain(s)`.

The quasimodel chain would give us a finite list `[h0, h1, ..., hk]` where
- `ψ ∈ hk.formulas` (last point has the witness)
- Each `hi = sigma_signature vi Sigma` for some BXPoints `v0, ..., vk`
- `bx_le v0 v1`, ..., `bx_le v(k-1) vk`

But we need to show that some `vj = rr_fwd_chain(s).val` for `s > n`. This requires:
- The BXPoints in the quasimodel chain are members of the `rr_fwd_chain` sequence
- OR there exist Int indices mapping to those BXPoints

This is the **fundamental mismatch**: the quasimodel chain lives in the abstract
canonical model (all BXPoints that exist), while `rr_fwd_chain` is a specific
constructive sequence parameterized by a starting MCS M₀ and a sigma_list. There
is no guarantee that `vk` (from the quasimodel chain) is reachable as any
`rr_fwd_chain(s)`.

### Component C: The Only Viable Bridge Path

The only way to use the quasimodel machinery to prove forward_F would be:

**Alternative approach**: Don't try to show the quasimodel witness IS a chain element.
Instead, show that a chain DOES satisfy forward_F by a direct argument that uses
quasimodel reasoning at the BFMCS level.

The restricted_temporally_coherent predicate needs:
```
∀ t, ∀ φ ∈ deferralClosure root,
  F(φ) ∈ fam.mcs t → ∃ s > t, φ ∈ fam.mcs s
```

For a `shifted_dd_fmcs N h_N sigma_list` family, `fam.mcs t = dd_chain N h_N sigma_list t`.

**The true quasimodel bridge** would be: given `F(ψ) ∈ dd_chain(t)`, use BX12 to
get `(⊤ U ψ) ∈ dd_chain(t)`, apply `bx_until_eventuality_resolution` to get
BXPoint `v` with `bx_le chain(t) v` and `ψ ∈ v`, then use the observation that
the Int-indexed chain contains SOME MCS with `ψ ∈ it` because the chain cycles
through all possibilities.

But this is CIRCULAR: `bx_until_eventuality_resolution` in Frame.lean is itself
a sorry-delegating function (see Realization.lean:428-433 and LocusControl.lean:31-37).

---

## Gaps and Risks

### Gap 1: HintikkaStepOracle Construction (CRITICAL, BLOCKING)

The oracle exists as a type but has never been constructed for any concrete
starting point. Every call site in Realization.lean delegates to Frame.lean sorries.

**Risk**: HIGH. The oracle construction requires the G-persistence property to
hold through the chain (needed for hintikka_step's G-propagation clause). While
the H-backward clause can be satisfied via sigma_signature (as analyzed above),
the G-persistence clause over multiple steps is the known obstacle from
Realization.lean:368-396.

### Gap 2: Finite-to-Int-Indexed Gap (CRITICAL, STRUCTURAL)

The quasimodel produces finite chains; dd_bfmcs needs Int-indexed witnesses.

**Risk**: FATAL for direct bridge. There is no existing mechanism to say "the
quasimodel witness is one of the rr_fwd_chain elements". This would require
either:
- Proving the rr_fwd_chain contains ALL BXPoints reachable from M₀ (false in general)
- OR completely bypassing the rr_fwd_chain and building a new FMCS

### Gap 3: Closure Alignment (MEDIUM RISK)

The quasimodel uses `SubformulaClosure target` or `enrichedClosure target` as
Sigma. The `top U ψ` formula is NOT in `SubformulaClosure ψ` (the closure of
`top U ψ` is much larger). BX12 converts F to Until, but Until coherence needs
Sigma to contain the Until formula.

The `untilDeferralSet` in `extendedDeferralClosure` contains Until formulas.
The sigma_list in `dd_bfmcs` is `extendedDeferralClosure(φ).toList`. So
`⊤ U ψ` is in sigma_list IF it's in `untilDeferralSet φ`, which requires
`⊤ U ψ` to be an Until-deferral of `φ`. This holds IF `ψ` is in
`subformulaClosure φ`.

This alignment check is non-trivial but likely solvable.

### Gap 4: ChainWitnessed Maintenance Over Many Steps (HIGH RISK)

The oracle's well-founded recursion in `hintikka_chain_exists` maintains
`ChainWitnessed` by construction (each step from the oracle carries a
`WitnessedHintikka`). The G-persistence problem is: when the oracle produces
step `w → v`, the next Hintikka point is `sigma_signature v Sigma`. But
`G(χ) ∈ sigma_signature v Sigma` does NOT imply `G(χ) ∈ sigma_signature next Sigma`
after a second step. The GUARANTEE is only one-step G-propagation via
`hintikka_step.1` (which says `G(χ) ∈ h1 → χ ∈ h2`, not `G(χ) ∈ h2`).

So after 2 steps, G-formulas may vanish, breaking any attempt to realize
chains longer than 2 as BXPoint chains.

---

## Confidence Level: LOW

**Justification**: The quasimodel bridge approach as originally conceived (realize
a Hintikka chain as a sequence of BXPoints, then map to Int indices) faces two
independently fatal obstacles:

1. **The HintikkaStepOracle has never been constructed** because its construction
   requires exactly the G-persistence property that Realization.lean:368-396
   identifies as the known obstacle. The analysis shows this problem is NOT
   insurmountable for the H-backward clause (sigma_signature saves us), but the
   G-PERSISTENCE for longer chains remains blocked.

2. **The finite-to-Int-indexed gap** cannot be bridged without either (a) showing
   dd_bfmcs families ARE the quasimodel chains (they're not — different construction),
   or (b) building a completely new chain construction that replaces dd_bfmcs.

The quasimodel infrastructure (hintikka_chain_exists, chain_step_seed_consistent, etc.)
is CORRECT and COMPLETE as an abstract framework. The problem is that no one has
discharged the oracle hypothesis with a concrete BXPoint-backed construction.

**Revised assessment of the approach**: The quasimodel bridge is not a "patch" on
the existing dd_bfmcs. It is an alternative completeness proof strategy that would
require replacing the dd_bfmcs BFMCS construction entirely with a quasimodel-based
one. This would be a ~1500-2000 LOC rewrite of the BFMCS layer, not an 800-1200 LOC
addition.

**Most viable remaining path**: Prove forward_F directly for the rr_fwd_chain by
showing that the defect_fwd_chain with `defects = [ψ]` (singleton) resolves ψ at
step n+1, then use that as a "single-defect chain" to discharge the sorry at site
1413. The singleton defect chain resolves exactly ψ at the very next step when
`F(ψ) ∈ chain(n)` and `defects = [ψ]` — the defect_fwd_step_choice lemma at
RootScopedChain.lean:2063-2065 does exactly this. The missing piece is mapping
this singleton to the general rr_fwd_chain.

---

## Appendix: File Summary

| File | LOC | Sorry-free? | Key Contribution |
|------|-----|-------------|-----------------|
| SubformulaClosure.lean | 115 | YES | Sigma = SubformulaClosure, neg-pairing |
| HintikkaPoint.lean | 167 | YES | HintikkaPoint def, sigma_signature construction |
| EnrichedClosure.lean | 158 | YES | Fisher-Ladner enrichedClosure with G/H-bigconj terms |
| Construction.lean | 887 | YES | hintikka_chain_exists, HintikkaStepOracle type |
| Realization.lean | 445 | YES* | Delegates to Frame.lean sorries; analysis of Phase 5 obstacles |
| LocusControl.lean | 47 | YES* | Primed wrappers delegating to Realization.lean |
| DefectChain.lean | 137 | YES | sigma_defect_count, defect step properties |
| SigmaOrdering.lean | 179 | YES | sigma_le, sigma_strict, sigma_equiv |

*"YES" with sorries inherited via delegation to Frame.lean functions.

**RootScopedChain.lean sorry sites** (the actual targets):
- Lines 1413, 1457: rr_fwd_chain_forward_F depth-0 base case
- Line 1464: dd_fmcs_backward_P
- Lines 1517, 1522, 1527: dd_bfmcs restricted coherence predicates
- Lines 2196, 2289: defect chain forward_F and backward_P
