# Research Report: Task #93 - Teammate A Findings
# Complete Approach Classification and Path Forward

**Task**: 93 - Complete BXCanonical embedding
**Date**: 2026-04-18
**Session**: sess_1776533662_a1d4fd (inherited from team delegation)
**Teammate**: A (Primary: review all approaches)
**Artifact**: specs/093_complete_bxcanonical_embedding/reports/39_teammate-a-findings.md

---

## Key Findings

### Finding 1: Three Sorry Sites - Dependency Structure

The three sorry sites at lines 1517, 1522, 1527 of `RootScopedChain.lean` have a
strict dependency: Phase 1 blocks Phases 2-3 in Plan v38.

- **Line 1517**: `dd_bfmcs_restricted_tc` -- F/P eventuality discharge (DEEPEST BLOCKER)
- **Line 1527**: `dd_bfmcs_restricted_fuc` -- forward Until/Since coherence (depends on tc)
- **Line 1522**: `dd_bfmcs_restricted_buc` -- backward Until/Since coherence (depends on fuc)

All three are about `dd_bfmcs M0 h0 sigma_list`, which assembles families as
`shifted_dd_fmcs N h_N sigma_list s`. Each family uses `dd_chain` which for `t >= 0`
delegates to `rr_fwd_chain` built via `enriched_fwd_step` (BX11 fold).

The **critical structural fact**: the forward F-eventuality property requires a witness
WITHIN the existing `dd_chain`, not in a separately constructed MCS. This is what makes
`self_resolving_fwd_step` insufficient for the tc sorry: it produces a new MCS with
`psi in M'` and `g_content(M) subset M'`, but this M' is NOT a state of `dd_chain`.
(Established definitively in handoff `01_mathematical-analysis.md`, April 2026.)

### Finding 2: The 19+ Dead Approaches - Precise Classification

#### Truly Dead (Mathematically Impossible)

| Approach | Why Dead | Evidence |
|----------|----------|---------|
| f_carry seed enrichment | Concrete counterexample: `G(F(alpha)->neg(psi))` in M makes seed inconsistent | Report 10, Handoff 10 |
| until_neg_carry in seed | Forward stability semantically invalid; BX8 contrapositive gives inconsistency | Handoff 02 |
| G(neg psi) impossibility | No backward G-propagation in forward chain; Lindenbaum freely adds G(neg psi) | Reports 15-16 |
| Identity tail for F | F is strict future (s > t); identity tail cannot witness | Report 14 |
| defect counting / scheduling induction | Defect count non-monotonic; resolved formulas can be lost at subsequent steps | Reports 14-16 |
| G(F(psi)) axiom | `F(psi) -> G(F(psi))` false in linear frames (not a BX theorem) | Report 16 |
| BX12 reduction `F(phi)->top U phi` | `(top U phi)` not in deferralClosure(root) -- wrong closure | Reports 10, Handoff 08 |
| Zorn/Compactness | forward_F is Sigma_1 (existential); not preserved by directed limits | Report 15 |
| Dovetailing (Goldblatt omega^2) | Same F-preservation problem; adds complexity without resolving it | Report 15 |
| Per-formula chain | Cannot merge into single Int-indexed chain while preserving family structure | Report 16 |
| FMP bridge | FMP proves decidability; completeness requires same construction | Report 14 |
| Two-phase chain | Reduces to same core problem at the end | Report 14 |
| Quasimodel-to-Int bridge | sigma_le incompatible with g_content; finite chains can't form global FMCS | Reports 10, 14, 15 |
| Defects-only fold | Lindenbaum can create new defects from former non-defect F-obligations | Report 16 |
| Partial domination | "Bad" formulas' F-obligations not preserved; circles back to ordering problem | Report 16 |

#### Truly Dead (Implementation Not Worth Cost)

| Approach | Why Dead | Evidence |
|----------|----------|---------|
| Deterministic successor | Would require 20+ hours major restructuring of ~30 downstream theorems | Handoff 10 |
| Finding BX11-minimum | bx11_earlier non-transitive; 3-cycles proven with concrete counterexample | Reports 15-16, Handoff 02 |
| Deferral disjunctions in seed | Consistency proof non-trivial; never completed | Handoff 01_deferral-chain |

#### FiniteDeferral.lean Boneyard (Steps 1-4 Proved; Step 5 Has Gap)

`Boneyard/ChainCompleteness/Algebraic/FiniteDeferral.lean` reached step 4 of 5:
- Step 1: `F(psi) -> (top U psi)` in chain (via BX12 axiom) - PROVED
- Step 2: `(top U psi)` persists until psi appears - PROVED (`until_persists_forward_steps`)
- Step 3: Restricted theory takes finitely many values - PROVED (`restrictedTheory_mem_powerset`)
- Step 4: Pigeonhole gives repeated restricted theory - PROVED (`pigeonhole_restricted_theories`)
- **Step 5 (the gap)**: Cycle with unresolved `(top U psi)` contradicts BX axioms - SORRY

The precise failure of Step 5 (from `FiniteDeferral.lean` comment, line 325):
The `G_neg_kills_until` lemma requires `G(neg psi) in chain(t)`, but proving this from
"neg psi in chain(s) for all s > t" requires backward-G reasoning, which requires
`forward_F`. This is **circular**: we are trying to prove forward_F itself.
The attempted fix using `until_induction` axiom fails because `until_induction` is NOT
in the BX axiom system (BX1-BX12). The sorry at line 325 uses a non-existent axiom.

**This is the most developed incomplete approach but has a genuine circularity.**

### Finding 3: Plan v38 Phase 1 is Blocked - Root Cause Analysis

Plan v38 proposes using `self_resolving_fwd_step` to close `dd_bfmcs_restricted_tc`.
The mathematical analysis (handoff `01_mathematical-analysis.md`) conclusively shows this
CANNOT work as written:

The `self_resolving_fwd_step` (lines 1961-1996, sorry-free) gives an MCS M' with:
- `psi in M'`
- `F(psi) in M'`
- `g_content(M) subset M'`

But `restricted_tc` requires the witness at `dd_chain N h_N sigma_list (s'-s)` for some
`s' > t`. The new M' is NOT this chain state. The fundamental tension is:

```
Protecting F-obligations (BX11) <-> Direct resolution (fwd_succ / self_resolving_fwd_step)
```

Every known chain construction hits one side of this tension (handoff table):
- `enriched_fwd_step` (BX11): F-obligations preserved, but resolution is disjunctive
- `fwd_succ` (direct): psi resolved, but OTHER F-obligations may be lost
- `self_resolving_fwd_step`: psi + F(psi) preserved, but OTHER F-obligations may be lost
- `{psi1,...,psik} union g_content(M)`: all at once but NOT always consistent

### Finding 4: The Backward Until/Since Coherence Sorry is Actually Easier

The handoff analysis and Summary 35 both identify `restricted_buc` (line 1522) as
INDEPENDENT of the BX11 forward_F problem. Its proof structure is:

Backward Until: given `psi in mcs(s)` and `phi in mcs(r)` for all `r in [t, s)`, prove
`phi U psi in mcs(t)`. This is provable by induction on `s - t`:
- Base: `psi in mcs(t)` -> by `refl_intro_until_mcs` (BX8) -> `phi U psi in mcs(t)`. DONE.
- Step: need `phi in mcs(t)` AND `phi U psi in mcs(t+1)` -> `phi U psi in mcs(t)`.

The KEY LEMMA needed: `phi in M` AND `F(phi U psi) in M` -> `phi U psi in M`.
This follows from the BX derivation: `psi or (phi and F(phi U psi)) -> phi U psi`.
Plan v38 Phase 3 sketches this derivation using BX5+BX6+BX8+BX9+BX10.

The challenge for the step case: getting `F(phi U psi) in mcs(t)` from `phi U psi in mcs(t+1)`.
Strategy: `phi U psi in mcs(t+1)` -> `phi_imp_F_phi` gives `F(phi U psi) in mcs(t+1)` ->
`connect_past_mcs` (BX4') gives `H(F(F(phi U psi))) in mcs(t+1)` -> h_content propagation
(backward) gives `F(F(phi U psi)) in mcs(t)` -> F-transitivity (BX3 or BX2 chain) gives
`F(phi U psi) in mcs(t)`.

**This approach does NOT require forward_F.** The backward coherence only requires:
1. BX8 (reflexive Until intro) - available (`refl_intro_until_mcs`)
2. BX9 (Until elimination) - available (`until_elim_mcs`)
3. BX4' (connect_past) - available (`connect_past_mcs`)
4. h_content backward propagation through `dd_chain` - available (`rr_bwd_chain_h_content_step`)
5. The Until introduction rule: `phi and F(phi U psi) -> phi U psi`

**Status**: The Until intro rule is the missing piece. It needs to be DERIVED from BX1-12.
Plan v38 Phase 3 contains a detailed (but incomplete) derivation sketch. This looks
PLAUSIBLY completable in 2-4 hours of focused proof engineering.

### Finding 5: Forward Until/Since Coherence Needs Forward_F

`restricted_fuc` (line 1527) directly reduces to `forward_F` for tc: if `phi U psi in mcs(t)`,
then BX10 gives `F(psi) in mcs(t)`. From tc's forward_F, there exists `s > t` with
`psi in mcs(s)`. The guard `phi in mcs(r)` for `r in [t, s)` follows from:
- `phi U psi in mcs(r)` (inductively maintained) + BX9 gives `phi or psi in mcs(r)`
- Since `r < s` and `s` is minimal, `psi not in mcs(r)`, so `phi in mcs(r)`.

But `phi U psi in mcs(r)` for `r > t` is NOT guaranteed unless `phi U psi` propagates
forward, which requires g_content or h_content (neither contains Until formulas directly).

**Conclusion**: fuc is strictly harder than tc and blocked until tc is resolved.

### Finding 6: Relationship Between the 3 Sorries

```
dd_bfmcs_restricted_tc (line 1517)
     |
     v  (fuc uses F(psi) from tc's forward_F to get Until witness)
dd_bfmcs_restricted_fuc (line 1527)
     |
     v  (buc INDEPENDENT - uses BX axioms + h_content backward, NOT forward_F)
dd_bfmcs_restricted_buc (line 1522)
```

The **key asymmetry**: buc is the backward direction and can be proved independently using
the BX axioms at MCS level without resolving the forward_F obstruction. Tc and fuc share
the same core blocker.

---

## Approach Classification: Truly-Dead vs Potentially-Fixable vs Unexplored

### Truly Dead (19 approaches in Report 17 + 2 more)
All 19 approaches from the catalog in Report 17 are definitively closed. No further
investigation is warranted. The FiniteDeferral argument is ALSO dead as formulated
(circular at Step 5, requires Until Induction not in BX).

### Potentially Fixable

| Approach | Confidence | Blocker |
|----------|-----------|---------|
| **restricted_buc direct proof** (BX axioms + induction) | 65% | Until intro derived rule needs formalization |
| **Strategy C** (direct witness contradiction on existing chain) | 35% | "Permanent displacement leads to contradiction" unproven; genuinely novel |
| **New BFMCS with multiple per-formula families** (Approach A from handoff) | 30% | Temporal coherence for OTHER formulas in same family still fails |
| **Quasimodel bridge** (Approach B from handoff) | 25% | Extended seed consistency for Until formulas; G-lift fails |

### Unexplored / Insufficiently Explored

1. **Until intro derived rule via BX6+BX5+BX9+BX8** (for restricted_buc):
   Plan v38 Phase 3 has the derivation SKETCH but it was never executed. This is the
   most concrete unexplored path. The rule `psi or (phi and F(phi U psi)) -> phi U psi`
   seems derivable using BX8 (psi -> phi U psi base case) and BX6 (absorption gives
   the step case). The combination `phi and F(phi U psi) -> phi U psi` requires showing
   that F(phi U psi) forces phi U psi to hold now if phi holds. BX12 gives F(phi U psi)
   -> G(neg psi) is impossible (equivalently), but constructive derivation needs more work.

2. **Restricted_tc via constructing a NEW BFMCS (not patching dd_bfmcs)**:
   Handoff Approach A: define `sr_dd_bfmcs` that uses `self_resolving_fwd_step` targeting
   each formula in sigma_list in sequence. The key question is whether ALL F-obligations
   within `deferralClosure(root)` are preserved. The key observation: `self_resolving_fwd_step`
   with `psi` as target gives `F(psi) in M'` (self-resolving seed). But OTHER formulas
   chi in sigma_list with `F(chi) in M` are NOT guaranteed to have `F(chi) in M'` unless
   either `chi in M'` (possible since Lindenbaum extends) or the seed includes `F(chi)`.
   This is the same tension identified above.

3. **Direct proof that the `defect_fwd_chain` with singleton list resolves the target at step 1**:
   `defect_fwd_step_choice_singleton` (line 2161-2170, sorry-free) proves that with
   `defects = [psi]`, the chain resolves `psi` at step 1. If we could show that the families
   in `dd_bfmcs` can be RE-INDEXED to use per-formula singleton chains, this might close tc
   for each formula independently. The challenge: the BFMCS family structure requires a
   SINGLE chain per family, and per-formula chains are separate objects.

4. **Checking whether restricted_tc needs forward_F for ALL formulas or only depth-0**:
   Handoff Approach D: the truth lemma may only need forward_F for formulas that appear
   as `neg(chi)` where `F(neg(chi)) in fam.mcs(t)`. Such `neg(chi)` has f_nesting_depth 0
   when chi has no outer F. The sorry-free `rr_fwd_chain_forward_F_depth_pos` handles depth >= 1.
   THIS APPROACH HAS NOT BEEN SYSTEMATICALLY EXPLORED. Worth a 1-2 hour focused check.

---

## Recommended Approach

### Priority 1: Prove restricted_buc directly (INDEPENDENT of tc, Confidence: 65%)

**Rationale**: restricted_buc is provable WITHOUT resolving the forward_F obstruction.
The proof needs only BX axioms at MCS level and h_content backward propagation. This
closes 1 of 3 sorry sites with no dependency on the hardest problem.

**Concrete steps**:
1. Derive `until_intro_mcs`: `phi in M` AND `phi U psi in M'` AND `g_content(M') subset M`
   (backward) -> `phi U psi in M`. Use: BX4' + connect_past_mcs to get `H(F(phi U psi))` in
   M' + h_content backward to get `F(phi U psi) in M` + the introduction rule.
2. The introduction rule `phi and F(phi U psi) -> phi U psi`:
   - Try `DerivationTree.axiom [] _ (Axiom.until_intro phi psi)` -- check if this axiom exists
   - If not, derive: from BX5 `phi U psi -> (phi and phi U psi) U psi`, BX9 `(phi U psi) -> phi or psi`,
     and BX8 `psi -> phi U psi`, construct the contrapositive:
     `neg(phi U psi) and phi -> neg(F(phi U psi))`. This gives: assume neg(phi U psi) in M and
     phi in M. BX9 gives neg(phi and phi U psi) in M (since phi U psi not in M). Actually
     approach is: derive `phi and G(neg psi) -> G(neg(phi U psi))` from BX5+BX9, then
     `phi and F(phi U psi)` contradicts this... No, this still needs forward_F.
   - ALTERNATIVE: Check whether BX6 (absorption) directly gives the rule:
     BX6: `phi and F(phi U psi) -> phi U psi`. THIS IS BX6 DIRECTLY IF IT EXISTS.
     Need to verify the exact statement of BX6 in `Axioms.lean`.
3. Instantiate for `dd_chain` using h_content backward propagation from `rr_bwd_chain_h_content_step`.

**Expected LOC**: 50-100 lines for the backward Until coherence proof.

### Priority 2: Check BX6 exact statement for the Until intro rule (30 minutes)

Read `Theories/Bimodal/ProofSystem/Axioms.lean` to verify if BX6 directly gives
`phi and F(phi U psi) -> phi U psi` or `phi and G(chi) -> phi U psi` for some chi.
If BX6 is the absorption axiom (which typically states this directly), the restricted_buc
proof simplifies dramatically.

### Priority 3: Investigate restricted_tc via depth-0 formula classification (1-2 hours)

Check whether the truth lemma's F-case for `dd_countermodel` actually reaches formulas
of depth 0. If `neg(chi)` with depth 0 is never an F-obligation that needs resolving
in the families called from `dd_countermodel`, then `rr_fwd_chain_forward_F_depth_pos`
(sorry-free) already handles all REACHABLE cases. This would close tc without solving
the theoretical forward_F problem.

**How to check**: Trace `dd_countermodel` -> `fully_restricted_parametric_representation_from_neg_membership`
-> truth lemma invocations -> which formulas' F-eventualities are queried -> whether
any are depth-0 atoms.

### Priority 4: Strategy C (if Priorities 1-3 all fail)

Strategy C (contradiction from permanent BX11 Case 3 displacement) remains the only
truly novel mathematical approach. Confidence 35%. Cap at 4 hours per Plan v16.

---

## Evidence/Examples

### Example 1: restricted_buc Proof Sketch (NOT relying on forward_F)

```lean
-- Backward Until: phi in mcs(r) for r in [t,s), psi in mcs(s) -> phi U psi in mcs(t)
-- By induction on s - t (as Int)
-- Base s = t: psi in mcs(t) -> phi U psi in mcs(t) by refl_intro_until_mcs
-- Step s = t + k + 1: phi in mcs(t), phi U psi in mcs(t+1) by IH
--   Need: phi U psi in mcs(t)
--   From phi U psi in mcs(t+1):
--     phi_imp_F_phi gives F(phi U psi) in mcs(t+1)
--     connect_past_mcs gives H(F(F(phi U psi))) in mcs(t+1)
--     [BX4': phi -> H(F(phi))]
--     h_content backward propagation (rr_bwd_chain_h_content_step):
--       h_content(mcs(t+1)) subset mcs(t)
--     So F(F(phi U psi)) in mcs(t)
--     F-transitivity (BX3 or derived) gives F(phi U psi) in mcs(t)
--   We have: phi in mcs(t) AND F(phi U psi) in mcs(t)
--   BY BX6 (if BX6 = phi AND F(phi U psi) -> phi U psi): phi U psi in mcs(t). DONE.
--   [Need to verify BX6 axiom statement]
```

### Example 2: Why self_resolving_fwd_step Cannot Close restricted_tc

`dd_chain N h_N sigma_list n` is defined for `n >= 0` as `rr_fwd_chain N h_N sigma_list n`.
`rr_fwd_chain` applies `enriched_fwd_step` at each step (BX11 fold). The sorry at line 1413
(the depth-0 case) says:

```lean
-- F(chi) in rr_fwd_chain(m) but chi may never appear
-- enriched_fwd_step at each step gives: chi in M' OR F(chi) in M'  (disjunctive)
-- BX11 Case 3 may always choose another formula, pushing chi's resolution to next step
-- This can repeat for ALL steps -- perpetual deferral
```

`self_resolving_fwd_step` would produce a DIFFERENT MCS `M'` where chi is guaranteed present,
but `restricted_tc` needs chi at `dd_chain(M0, sigma, (t+1)-s)` for some specific shifted family.
The witness must be IN THE SAME CHAIN, not in a newly constructed MCS. This fundamental
requirement makes `self_resolving_fwd_step` insufficient.

### Example 3: BX6 / Absorption Axiom Check Needed

The absorption axiom in temporal logic typically states:
`phi and F(phi U psi) -> phi U psi`

This is directly what restricted_buc's step case needs. If BX6 states this (which is
standard in publications like Burgess 1984), then the backward coherence proof reduces
to a straightforward induction using only sorry-free lemmas already in the codebase.
The BX axiom numbers in this system follow the "Construction of Possible Worlds" paper;
the exact statement of BX6 must be verified before assuming this simplification.

---

## Confidence Assessment

| Sorry | Approach | Confidence | Effort |
|-------|----------|-----------|--------|
| restricted_buc (1522) | BX axioms + induction (check BX6 first) | 65% | 2-4 hours |
| restricted_tc (1517) | Depth-0 formula classification (quick check) | 40% | 1-2 hours |
| restricted_tc (1517) | Strategy C (permanent displacement contradiction) | 35% | 4+ hours |
| restricted_fuc (1527) | Blocked by tc | Follows from tc | 1 hour after tc |

---

## Sources Reviewed

- `specs/093_complete_bxcanonical_embedding/reports/17_round-robin-chain-history.md` (19 failed approaches)
- `specs/093_complete_bxcanonical_embedding/reports/38_team-research.md` (round 38 team synthesis)
- `specs/093_complete_bxcanonical_embedding/summaries/35_bxcanonical-embedding-summary.md`
- `specs/093_complete_bxcanonical_embedding/summaries/36_bxcanonical-embedding-summary.md`
- `specs/093_complete_bxcanonical_embedding/summaries/37_bxcanonical-embedding-summary.md`
- `specs/093_complete_bxcanonical_embedding/handoffs/01_mathematical-analysis.md`
- `specs/093_complete_bxcanonical_embedding/plans/38_bxcanonical-embedding.md`
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` (lines 1390-2290)
- `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/Construction.lean` (lines 1-250)
- `Theories/Bimodal/Boneyard/ChainCompleteness/Algebraic/FiniteDeferral.lean` (complete)
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherence.lean` (restricted coherence defs)
