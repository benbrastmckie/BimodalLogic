# Teammate B Findings: Quasimodel Run-Composition Path (Option 3)

**Task**: 109 (Close chain construction sorries)
**Date**: 2026-04-20
**Focus**: Deep analysis of using `hintikka_chain_exists` infrastructure to prove `fwd_chain_forward_F`

## Executive Summary

The quasimodel run-composition path faces **three structural gaps** that make it significantly harder than initially estimated. The core issue is that the Hintikka chain infrastructure solves a *different problem* (Until defect discharge) than what `fwd_chain_forward_F` requires (F-formula resolution). Bridging these two domains requires substantial new infrastructure that is unlikely to be less complex than a direct chain redesign.

**Confidence Level**: LOW for the run-composition bridge approach as described. MEDIUM for a hybrid approach that restructures `dd_chain` to directly use the Hintikka chain oracle pattern.

## Step 1: Oracle Gap Analysis

### What the Realization.lean sorry sites need

The 4 sorry sites in Realization.lean are in:
1. `enriched_seed_consistent_until` (line 197): needs `g_content(w) ⊆ w.formulas`, i.e., `G(chi) in w -> chi in w` (BX1, removed under irreflexive semantics)
2. `enriched_seed_consistent_since` (line 249): needs `h_content(w) ⊆ w.formulas`, i.e., `H(chi) in w -> chi in w` (BX1', removed under irreflexive semantics)
3. `F_of_mem` (line 67): needs `psi in w -> F(psi) in w` (requires BX1)
4. `P_of_mem` (line 73): needs `psi in w -> P(psi) in w` (requires BX1')

### Can we replace `g_content(w)` with `g_content_sigma(w, Sigma)`?

**No, not directly.** The issue is fundamental:

- `enriched_seed_consistent_until` proves consistency of `{neg(phi U psi)} union g_content(w) union h_content(v)`.
- The `g_content(w)` term contains ALL `chi` where `G(chi) in w`, not just those where `G(chi) in Sigma`.
- Under irreflexive semantics, `G(chi) in w` does NOT imply `chi in w`. So `g_content(w)` is NOT a subset of `w.formulas`.
- Even restricting to `g_content_sigma(w, Sigma)` doesn't help: we still need `chi in w.formulas` for each `chi` with `G(chi) in w` and `G(chi) in Sigma`. The Hintikka step guarantees `chi in h2.formulas` (the *next* point), but not `chi in w.formulas` (the *current* point).

**Key insight**: The Realization sorry sites are blocked by the removal of BX1 (reflexivity axiom `G(phi) -> phi`). This is an irreflexive-semantics blocker that affects ALL approaches using `g_content` self-inclusion, not just the oracle path.

### Can we bypass Realization entirely?

**Yes, and we should.** The Realization module is confirmed dead code (not called anywhere in the critical path). The critical path flows through `dd_countermodel -> dd_bfmcs_restricted_tc/buc/fuc -> fwd_chain_forward_F`. We should look at whether `hintikka_chain_exists` can be used *directly* at the `dd_chain` level without going through Realization.

## Step 2: Bridge Construction Analysis

### The fundamental type mismatch

| Component | Domain | Key Type |
|-----------|--------|----------|
| `fwd_chain_forward_F` | `Set Formula` (MCS) | `fwd_chain_of_sigma M0 h0 sigma_list n : {M : Set Formula // SetMaximalConsistent M}` |
| `hintikka_chain_exists` | `HintikkaPoint Sigma` | `HintikkaRawChain Sigma` with `ChainWitnessed` |

To use `hintikka_chain_exists` to prove `fwd_chain_forward_F`, we would need:

1. **Convert the goal**: Given `F(phi) in fwd_chain(n)`, construct a `HintikkaPoint Sigma` carrying `phi U X` for some suitable Until formula, then invoke `hintikka_chain_exists` to get a chain ending at a point with `phi`.

2. **Problem**: `fwd_chain_forward_F` is about F-formulas (`F(phi)`), not Until formulas (`phi U psi`). The Hintikka chain infrastructure is designed for Until defect discharge. There is no direct F-formula analogue.

### Can we reduce F-resolution to Until-resolution?

Using BX12: `F(phi) -> (true U phi)` (where `true = neg bot`). If this axiom exists:

```
F(phi) in chain(n)
  -> (true U phi) in chain(n)  [by BX12 at MCS level]
  -> hintikka_chain_exists gives chain ending with phi  [by oracle]
```

Let me check whether BX12 exists in the axiom set.

**BX12 (`until_F`)**: The existing axiom is `(phi U psi) -> F(psi)` (BX10). We need the REVERSE direction: `F(phi) -> (true U phi)`. This is the standard equivalence in many temporal logics but it requires:
- Under reflexive semantics: `F(phi) <-> (true U phi)` is standard.
- Under irreflexive semantics: `F(phi) -> (true U phi)` is NOT derivable because `true U phi` requires `phi` at a STRICTLY future point while also requiring the guard to hold at all intermediate points, but `true` trivially holds everywhere, so the constraint is just that `phi` holds at some strictly future point -- which IS what `F(phi)` means under irreflexive semantics.

**Critical check**: Does `F(phi) -> (true U phi)` hold under irreflexive `F`?

Under irreflexive semantics:
- `F(phi)` means: exists t' > t such that phi holds at t'
- `true U phi` means: exists t' > t such that phi holds at t' AND for all t < s < t', true holds at s

Since "true" holds everywhere, `true U phi` reduces to `exists t' > t, phi at t'` = `F(phi)`.

So `F(phi) <-> (true U phi)` is semantically valid under irreflexive semantics. But is it DERIVABLE from BX axioms?

Looking at BX12 (Axiom.lean): Need to check what axiom maps `F` to `Until`.

### Checking the axiom set

The relevant axioms are:
- BX10: `(phi U psi) -> F(psi)` -- already used in `until_F_mcs`
- BX12: If it exists, would be `F(phi) -> (true U phi)` or similar

If BX12 gives `F(phi) -> (true U phi)`, then we have a reduction from F-resolution to Until-resolution. But this needs verification against the actual axiom definitions.

Even without BX12, the reduction might work via BX5 (self-accumulation) + BX10: Given `F(phi) in M`, we need `(true U phi) in M`. The standard derivation in many BX systems uses an induction axiom for Until, but this may not be available.

**Assessment**: The F-to-Until reduction is the CRITICAL feasibility question. If `F(phi) -> (neg bot) U phi` is derivable in BX, the approach opens up. If not, the entire run-composition path is blocked.

## Step 3: Witness Extraction (Assuming F-to-Until works)

Assuming we can derive `(neg_bot U phi) in chain(n)` from `F(phi) in chain(n)`:

### Constructing the HintikkaStepOracle

The oracle signature is:
```lean
HintikkaStepOracle (Sigma := Sigma) (neg_bot) phi :=
  forall h : HintikkaPoint Sigma,
    (neg_bot U phi) in h.formulas -> phi notin h.formulas ->
    exists wh' : WitnessedHintikka Sigma, hintikka_step h wh'.point /\ ...
```

To construct this oracle, at each Hintikka point `h` carrying `(neg_bot U phi)` but not `phi`:
1. Extract the backing BXPoint `w` (from `ChainWitnessed`)
2. `(neg_bot U phi) in h.formulas` and `h.formulas ⊆ w.formulas` gives `(neg_bot U phi) in w.formulas`
3. `phi notin h.formulas` -- but we need `phi notin w.formulas`! We only know `phi notin h.formulas`, which means `phi notin Sigma` OR `phi notin w.formulas`.
   - If `phi in Sigma` and `phi notin h.formulas`, then `phi notin w.formulas` (by sigma_signature construction)... **WAIT**: `h.formulas = sigma_signature_formulas w Sigma = Sigma.filter (f in w.formulas)`. So `phi notin h.formulas` means `phi notin Sigma` OR `phi notin w.formulas`. If `phi in Sigma` (which it is, since `phi` is a subformula of the root), then `phi notin h.formulas` implies `phi notin w.formulas`.
4. So: `(neg_bot U phi) in w.formulas` and `phi notin w.formulas`. By `bx_until_eventuality_resolution`: exists `v` with `bx_le w v` and `phi in v.formulas`.
5. Project `v` to `sigma_signature v Sigma` to get the next Hintikka point.
6. Need: `hintikka_step h (sigma_signature v Sigma)`.

### The hintikka_step obligation

`hintikka_step h1 h2` requires:
1. **G-propagation**: `G(chi) in h1.formulas -> chi in h2.formulas`
   - `G(chi) in h1` means `G(chi) in Sigma` and `G(chi) in w.formulas`
   - `bx_le w v` means `g_content(w) ⊆ v.formulas`, so `chi in v.formulas`
   - `chi in Sigma` (by SubformulaClosure_G_closed)
   - Therefore `chi in sigma_signature v Sigma`. CHECK.

2. **H-backward**: `H(chi) in h2.formulas -> chi in h1.formulas`
   - `H(chi) in sigma_signature v Sigma` means `H(chi) in Sigma` and `H(chi) in v.formulas`
   - Need `chi in w.formulas`. We have `bx_le w v`, which gives `g_content(w) ⊆ v.formulas`.
   - `H(chi) in v.formulas` means `chi in h_content(v)`. We need `chi in w.formulas`.
   - From `bx_le w v` and `H(chi) in v`: by BX4' (connect_past), `chi in v -> H(F(chi)) in v`. But we need the reverse: `H(chi) in v -> chi in w`.
   - **This requires**: `H(chi) in v` and `bx_le w v` implies `chi in w`. This is `bx_H_forward`:
     ```lean
     theorem bx_H_forward (h_le : bx_le w v) (h_H : Formula.all_past chi in v.formulas) :
         chi in w.formulas
     ```
   - Does this exist? Let me check... Yes, `bx_H_forward` is referenced in Realization.lean line 199: "h_content(v) ⊆ w.formulas (by bx_H_forward)". So this IS proved.
   - Therefore: `chi in w.formulas`, and if `chi in Sigma`, then `chi in h1.formulas`. CHECK (assuming chi in Sigma, which follows from SubformulaClosure_H_closed).

3. **Until defect propagation**: `(alpha U beta) in h1 -> beta notin h1 -> alpha in h1 AND (alpha U beta) in h2`
   - `(alpha U beta) in h1` means in `w.formulas`. `beta notin h1` with `beta in Sigma` means `beta notin w.formulas`.
   - By BX9: `alpha in w.formulas` (and `alpha in Sigma` by closure). So `alpha in h1`. First conjunct CHECK.
   - By BX5 (self_accum): `(alpha /\ (alpha U beta)) U beta in w.formulas`.
   - By BX10: `F(beta) in w.formulas`. Then `bx_le w v` gives... no, `F(beta) in w` does not propagate to `(alpha U beta) in v`.
   - **GAP**: We need `(alpha U beta) in v.formulas`. But `bx_le w v` only propagates `g_content(w)` to `v`. `G(alpha U beta) in w` would propagate, but we don't have that.
   - This is the **Until-propagation gap**: the `bx_forward_witness` gives us `v` with `phi in v`, but does NOT guarantee that other Until formulas from `w` survive to `v`.

**This is a CRITICAL gap.** The `hintikka_step` requires Until-propagation, but `bx_forward_witness` (Lindenbaum extension of `{phi} union g_content(w)`) does not force Until-formulas from `w` into `v`.

### Fixing the Until-propagation gap

To fix this, the Lindenbaum seed for `v` would need to include not just `{phi} union g_content(w)` but also all active Until formulas from `w`. Specifically, for each `(alpha U beta) in w` with `beta notin w`, we need `(alpha U beta) in v`.

This means replacing `bx_forward_witness` with an enriched version:
```lean
theorem enriched_forward_witness (w : BXPoint) (phi : Formula)
    (h_F : F(phi) in w.formulas)
    (untils : List Formula)
    (h_untils : forall u in untils, u in w.formulas) :
    exists v : BXPoint, bx_le w v /\ phi in v.formulas /\
      forall u in untils, u in v.formulas \/ F(u) in v.formulas
```

This is essentially `enriched_fwd_exists` from RootScopedChain.lean (line 404)! The `enriched_fwd_exists` theorem already provides exactly this:
- Given `F(target) in M` and `F(chi_i) in M` for others
- Get `M'` with `g_content(M) ⊆ M'` and each formula either directly present or F-protected

But wait -- `enriched_fwd_exists` requires `F(chi_i) in M` for the Until formulas, not just `chi_i in M`. For Until formulas `(alpha U beta) in w`, we have `F(beta) in w` by BX10, but we need `F(alpha U beta) in w`. Under irreflexive semantics:
- `(alpha U beta) in w` does NOT give `F(alpha U beta) in w` (that would require reflexivity).
- It gives `F(beta) in w` (by BX10), which is different.

So `enriched_fwd_exists` cannot directly propagate Until formulas.

**Alternative**: Include Until formulas directly in the Lindenbaum seed. The seed `{phi, (alpha U beta)} union g_content(w)` is consistent if `{phi} union g_content(w)` is consistent (since adding a formula that's already in `w` doesn't create inconsistency... but `(alpha U beta)` might NOT be in `g_content(w)`).

The seed consistency for `{phi} union {all active Until formulas from w} union g_content(w)` needs proof. Since all these formulas are in `w.formulas`, and we need `F(phi) in w` to justify `phi` in the seed, the standard forward temporal witness argument applies: the seed is `{phi} union g_content(w)`, and adding formulas from `g_content(w)` is fine. But Until formulas from `w` are NOT in `g_content(w)` unless `G(alpha U beta) in w`.

**Conclusion on Step 3**: The Until-propagation gap makes the direct bridge construction infeasible without a new enriched forward step that simultaneously resolves `F(phi)` AND propagates Until formulas. This is essentially the same BX11 fold that `preserving_fwd_step` already does -- bringing us back full circle to the existing chain construction.

## Step 4: Alternative -- Restructure dd_chain as Hintikka Chain

### The idea

Instead of building `dd_chain` via `preserving_fwd_step` (which can't prove termination of F-resolution), restructure the forward chain to BE a realized Hintikka chain:

1. At `dd_chain(0) = M0`, project to `h0 = sigma_signature M0 Sigma`
2. For each active F-defect `F(phi)` in `h0`, convert to `(true U phi)` in `M0` (if derivable)
3. Use `hintikka_chain_exists` with a suitable oracle to get a Hintikka chain resolving each Until defect
4. Realize the Hintikka chain as a sequence of BXPoints (the `dd_chain` entries)

### What this requires

**A. F-to-Until derivation** (same as Step 2): Need `F(phi) -> (neg_bot U phi)` in BX.

**B. HintikkaStepOracle construction**: For each Until defect, need an oracle that:
- Takes a HintikkaPoint with the Until defect
- Produces a next HintikkaPoint with `hintikka_step` relation
- Either resolves the defect or strictly decreases defect count

This oracle is the heart of the construction. The existing `bx_until_eventuality_resolution` gives us a BXPoint `v` with `bx_le w v` and `psi in v`, but:
- We need `hintikka_step h1 h2` (Hintikka-level), not just `bx_le w v` (BXPoint-level)
- The Until-propagation gap (from Step 3) blocks this

**C. Chain realization**: Convert the Hintikka chain back to MCS chain.
- `ChainWitnessed` gives us BXPoints backing each Hintikka point
- These BXPoints are NOT necessarily the same as what `preserving_fwd_step` produces
- The `dd_chain` would need to be redefined to use these BXPoint witnesses

### Assessment

This restructuring effectively means:
1. Abandoning the current `preserving_fwd_step` chain
2. Building a completely new chain using the Hintikka oracle pattern
3. The oracle construction faces the same Until-propagation gap

The fundamental issue is: **the Hintikka chain infrastructure was designed for finite Until defect discharge within a fixed Sigma closure, not for infinite F-resolution across an unbounded chain.**

## Gap Analysis Summary

| Gap | Description | Severity | Can Be Closed? |
|-----|-------------|----------|----------------|
| **G1: F-to-Until reduction** | Need `F(phi) -> (true U phi)` derivable in BX | HIGH | Likely yes under irreflexive semantics, needs axiom check |
| **G2: Oracle gap (BX1 removal)** | `g_content(w) ⊆ w.formulas` fails without BX1 | CRITICAL | No -- fundamental to irreflexive semantics |
| **G3: Until-propagation** | `hintikka_step` requires Until formulas to survive in successor, but `bx_forward_witness` doesn't guarantee this | CRITICAL | Requires enriched seed that simultaneously resolves target AND propagates Untils -- essentially rebuilding the BX11 fold |
| **G4: Hintikka-to-dd_chain lift** | Hintikka chain is NOT a sub-chain of `dd_chain`; indices don't correspond | HIGH | Would require `dd_chain` to be redefined entirely |
| **G5: Realization sorry sites** | Dead code, blocked by BX1 removal | LOW (dead code) | Not needed for critical path |

## Recommended Approach

**Do NOT pursue run-composition as described.** The gap analysis shows it converges back to the same fundamental problem as direct chain redesign (Gap G3), with additional overhead from the Hintikka-to-MCS bridge.

### What run-composition infrastructure IS useful for

The `hintikka_chain_exists` pattern provides a clean termination argument via `defect_count` descent. This pattern could be adapted DIRECTLY at the MCS level:

**Hybrid approach**: Define an "MCS step oracle" analogous to `HintikkaStepOracle`:
```lean
def MCSStepOracle (phi : Formula) (sigma_list : List Formula) : Prop :=
  forall M : Set Formula, SetMaximalConsistent M ->
    F(phi) in M ->
    exists M' : Set Formula, SetMaximalConsistent M' /\
      g_content M ⊆ M' /\
      (phi in M' \/ (F(phi) in M' /\ f_defect_count M' sigma_list < f_defect_count M sigma_list))
```

where `f_defect_count M sigma_list = |{chi in sigma_list | F(chi) in M}|`.

The key insight: if we can show that `enriched_fwd_exists` (the BX11 fold) either resolves `phi` directly OR strictly decreases the number of F-defects, then strong induction on `f_defect_count` gives termination.

**But this is Gap G3 again**: the BX11 fold's Case 3 can maintain `F(phi)` while resolving a different defect, without decreasing the F-defect count (the resolved defect might re-enter via `F(w) in M'`).

### Bottom line

The quasimodel run-composition path (Option 3) is **not independently viable**. It reduces to the same core blocker as Option 1 (chain redesign): proving that the BX11 fold eventually terminates F-resolution for each specific defect.

The Hintikka chain termination argument works for Until defects because Until has a STRUCTURAL termination measure (the defect set is bounded by Sigma and strictly decreases). F-defects lack this structural measure because F-obligations can be regenerated by the BX11 fold's Case 3.

**The true blocker is not the chain construction but the BX11 fold's non-determinism.**

## Files Analyzed

- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/Construction.lean` -- `hintikka_chain_exists`, oracle pattern, defect count descent
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/Realization.lean` -- Oracle gap, sorry sites (dead code), `g_content_sigma`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- `dd_chain`, `fwd_chain_of_sigma`, `preserving_fwd_step`, 5 sorry sites
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/HintikkaPoint.lean` -- `HintikkaPoint`, `sigma_signature`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/BXCanonical/Frame.lean` -- `bx_le`, `bx_forward_witness`, `bx_until_eventuality_resolution`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/TemporalContent.lean` -- `g_content`, `h_content` definitions
