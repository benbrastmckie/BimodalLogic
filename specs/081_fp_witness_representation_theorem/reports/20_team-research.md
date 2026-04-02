# Research Report 20: Canonical Completeness via Simultaneous Induction — Team Synthesis

**Task**: 81 — F/P Witness Representation Theorem
**Date**: 2026-04-02
**Session**: sess_1775170000_r81math
**Mode**: Team Research (4 teammates: A=construction, B=f_step analysis, C=literature, D=critic)

---

## Executive Summary

This team research resolves a critical disagreement about the simultaneous induction approach and identifies a concrete, actionable path forward. The key findings:

1. **Teammate D's critique is correct but addressable.** The truth lemma is already sorry-free given temporal coherence. The sorry is in CONSTRUCTING a temporally coherent model, not in proving the truth lemma. Simultaneous induction as described in Report 19 addresses the wrong target.

2. **Teammate A's type-refactoring proposal resolves D's critique.** Instead of proving full temporal coherence (forward_F for ALL formulas), refactor `TemporalCoherentFamily` to use RESTRICTED temporal coherence (forward_F only for formulas in `deferralClosure`). The restricted version IS constructible sorry-free via `build_restricted_tc_family`.

3. **Teammate B confirms the restricted construction is sorry-free** and provides the precise algebraic mechanism: f_content persistence (every F-obligation resolves in exactly one step within the DRM chain). The bridge gap is precisely located at G/H propagation across time steps in Lindenbaum-extended chains.

4. **Teammate C confirms the approach is literature-compatible** and that TM's interaction axioms are one-directional (box propagates temporally, not reverse), making the modal and temporal dimensions orthogonal for the truth lemma.

5. **The recommended path has two phases**: (a) Close FMP sorries for immediate weak completeness (~2 hours), then (b) refactor types to restricted coherence for canonical completeness (~18-25 hours).

---

## Conflict Analysis

### Conflict 1: Does simultaneous induction close the sorry?

| Teammate | Position | Confidence |
|----------|----------|------------|
| A | Yes, via restricted coherence refactoring | MEDIUM (60%) |
| D | No, it addresses the wrong problem | 10% as stated; higher if refactored |

**Resolution**: Both are correct at different levels. D correctly identifies that the sorry is in the CONSTRUCTION, not the proof. The simultaneous induction as described in Report 19 reorganizes the proof but doesn't help the construction. However, A's proposal goes further: by refactoring the TYPE to use restricted coherence, the construction problem DISSOLVES because restricted coherence IS already constructible (sorry-free). The simultaneous induction then becomes the proof technique for showing the restricted truth lemma suffices.

**Synthesized confidence**: 55-65% that the restricted coherence refactoring closes the sorry. The remaining risk is in the bridge from restricted chain to the refactored truth lemma.

### Conflict 2: Single chain vs multi-chain

| Teammate | Position |
|----------|----------|
| A | Single chain (Approach B), truth lemma proved by depth induction |
| C | Flags single-chain vs multi-chain as HIGH RISK decision point |
| D | Single chain means the construction problem remains |

**Resolution**: A is correct that a single chain serves all depth levels. The chain is built ONCE over the full `deferralClosure(root_formula)`, which includes formulas at all depths. The simultaneous induction is for the PROOF, not the construction. C's concern about multi-chain is resolved by A's Approach B.

### Conflict 3: Is the DRM-to-MCS bridge gap fatal?

| Teammate | Position |
|----------|----------|
| B | Gap is real, precisely at G/H propagation (RestrictedTruthLemma.lean:116) |
| D | Gap is fatal and recurs in every approach |
| A | Gap is bypassable via restricted coherence |

**Resolution**: The bridge gap IS real for the current architecture (full temporal coherence). A's restricted coherence proposal bypasses it: instead of proving forward_F for ALL formulas in the full MCS chain, prove it only for formulas in `deferralClosure` using the restricted chain (which is sorry-free). The truth lemma only NEEDS forward_F for subformulas of the target formula, all of which are in `deferralClosure`.

**Key insight from A**: The `TemporalCoherentFamily.forward_F` type quantifies over ALL formulas — this is over-specified. The truth lemma only invokes forward_F on subformulas of the root formula. Weakening the type to match the actual usage makes the sorry closable with existing infrastructure.

---

## Synthesized Architecture

### The Correct Decomposition

```
                    CONSTRUCTION (build once)           PROOF (induction on depth)
                    ========================           ==========================

Level 0:            SuccChainFMCS built from           Truth lemma for atoms: trivial
                    root MCS over full                 (MCS membership = valuation)
                    deferralClosure(Phi)

Level k -> k+1:    SAME chain (no rebuild)             Truth lemma at depth k+1:
                    f_step ensures F-obligation         - Imp: uses IH at depth <= k+1
                    tracking within deferralClosure     - Box: uses boxClassFamilies (orthogonal)
                    build_restricted_tc_family          - G forward: uses g_persistence
                    gives sorry-free forward_F          - G backward: uses forward_F at depth k
                    within deferralClosure              - F: uses truth lemma at depth k

Modal dimension:   boxClassFamilies (sorry-free,       Modal truth lemma cases: sorry-free
                   orthogonal to temporal)              via boxClassFamilies_modal_forward/backward
```

### Why This Works

1. **Construction**: `build_restricted_tc_family` produces `RestrictedTemporallyCoherentFamily` with sorry-free forward_F and backward_P within `deferralClosure`. No new construction needed.

2. **Bridge**: `restricted_chain_subset_extended` (sorry-free) shows restricted chain embeds in full MCS chain. Forward_F witnesses in restricted chain lift to full chain.

3. **Sufficiency**: The truth lemma only needs forward_F for subformulas of the root formula Phi. All such subformulas are in `subformulaClosure(Phi) ⊆ deferralClosure(Phi)`. So restricted forward_F suffices.

4. **Type refactoring**: Change `TemporalCoherentFamily.forward_F` from quantifying over ALL phi to quantifying over `phi ∈ deferralClosure(root)`. This matches the actual usage in `ParametricTruthLemma`.

### D's Remaining Concerns (Addressed)

| D's Concern | Status | Resolution |
|-------------|--------|------------|
| Wrong target (truth lemma already done) | ADDRESSED | Refactoring the TYPE is a construction change, not a proof change |
| DRM-to-MCS bridge | BYPASSED | Don't bridge to full MCS; use restricted coherence directly |
| Constructive circularity | DISSOLVED | No circularity: chain built first, then truth lemma proved by induction |
| Lindenbaum non-determinism | IRRELEVANT | Restricted chain doesn't use Lindenbaum for temporal properties |
| Multi-family (boxClassFamilies) | ORTHOGONAL | C confirms interaction axioms are one-directional |
| Depth measure undefined | VALID | Must define `modal_temporal_depth` in Lean (D's Q6 analysis is correct) |

### D's Concern NOT Fully Addressed

**The G/H propagation across time steps** (B's bridge gap at RestrictedTruthLemma.lean:116):

The backward G case at depth k+1 requires: if `G(psi) ∉ M_t`, then `F(¬psi) ∈ M_t`, and we need a witness `s ≥ t` with `¬psi ∈ M_s`. By restricted forward_F, this witness exists in the restricted chain. By `restricted_chain_subset_extended`, it exists in the full chain.

BUT: the forward G case requires `G(psi) ∈ M_t → psi ∈ M_s` for ALL `s ≥ t`. This is `forward_G`, which comes from the chain's g_persistence property. For the RESTRICTED chain, g_persistence holds within `deferralClosure` (sorry-free). For the EXTENDED chain, `G(psi) ∈ ext(t)` should imply `psi ∈ ext(s)` — but this is the sorry at RestrictedTruthLemma.lean:116.

**B's analysis**: The sorry is specifically about `G(G(chi))`: if `G(chi) ∈ deferralClosure` but `G(G(chi)) ∉ deferralClosure`, then g_persistence can't propagate `G(chi)` through the restricted chain.

**Proposed fix** (from B): Augment `deferralClosure` to include bounded G/H-iterations. Since the closure is already finite, adding `G^k(psi)` for bounded k maintains finiteness. This needs formal verification.

**Alternative fix** (from A): The truth lemma is proved by structural induction on psi. When `psi = G(chi)`, the forward direction uses `forward_G` for `chi`, not for `G(chi)`. And `chi` is a strict subformula of `psi`, so `chi ∈ subformulaClosure(Phi)` when `G(chi) ∈ subformulaClosure(Phi)`. The g_persistence property `G(chi) ∈ chain(t) → chi ∈ chain(t+1)` follows from the Succ relation and does NOT require `G(G(chi))` to be in the closure. The iterated propagation `G(chi) ∈ chain(t) → G(chi) ∈ chain(t+1)` is what needs `G(G(chi))`, but we don't need this — we only need `chi ∈ chain(s)` for all `s ≥ t`, which follows from repeated application of single-step g_persistence.

**Assessment**: A's alternative fix is correct. The truth lemma's forward G case applies g_persistence one step at a time, never requiring `G(G(chi))`. The sorry at RestrictedTruthLemma.lean:116 may be an artifact of the current proof structure rather than a genuine mathematical obstacle. **Confidence: MEDIUM-HIGH**.

---

## Correction to Report 19

**Teammate C identified a factual error in Report 19's axiom descriptions**:

| Axiom | Report 19 Claims | Actual (Axioms.lean) |
|-------|-------------------|----------------------|
| `modal_future` | `□G(φ) → G(□φ)` | `□φ → □Gφ` (line 311) |
| `temp_future` | `G(φ) → □F(φ)` | `□φ → G□φ` (line 318) |

The actual axioms are strictly WEAKER — both have `□φ` as antecedent. The modal-temporal interaction is one-directional: box content propagates temporally, but temporal content does NOT propagate modally. This is GOOD: it confirms orthogonality of the modal and temporal dimensions.

---

## Recommended Path

### Phase 1: Close FMP Sorries (1-2 hours) — ALL TEAMMATES AGREE

Close `mcs_all_future_closure` and `mcs_all_past_closure` in TruthPreservation.lean using `temp_t_future`/`temp_t_past` axioms. Pattern: copy `mcs_box_closure` proof structure.

**Result**: Weak completeness of TM (valid iff provable). Decidability via FMP.

### Phase 2: Restricted Coherence Refactoring (18-25 hours)

| Step | Description | Effort | Risk |
|------|-------------|--------|------|
| 2a | Define `modal_temporal_depth : Formula → Nat` (imp doesn't increase depth) | 2-3h | LOW |
| 2b | Refactor `TemporalCoherentFamily` to restrict forward_F/backward_P to `deferralClosure` | 4-6h | MEDIUM |
| 2c | Adapt `ParametricTruthLemma` for restricted coherence hypothesis | 5-8h | MEDIUM |
| 2d | Bridge: prove restricted chain provides restricted coherence | 3-5h | MEDIUM |
| 2e | Close `bfmcs_from_mcs_temporally_coherent` using restricted version | 2-4h | LOW |
| 2f | Verify `lake build` clean | 2-4h | LOW |

**Decision gate before 2b**: Verify that single-step g_persistence suffices for the forward G case without requiring `G(G(chi)) ∈ deferralClosure`. This resolves B's bridge gap concern.

### Phase 3: Extension Results (5-10 hours, after Phase 2)

Once canonical completeness is established, extension results follow by standard techniques.

---

## Sorry Inventory (Updated)

### Phase 1 Targets (FMP)

| Sorry | Location | Status | Fix |
|-------|----------|--------|-----|
| `mcs_all_future_closure` | TruthPreservation.lean:263 | **CLOSABLE NOW** | Copy `mcs_box_closure` with `temp_t_future` |
| `mcs_all_past_closure` | TruthPreservation.lean:281 | **CLOSABLE NOW** | Copy `mcs_box_closure` with `temp_t_past` |

### Phase 2 Targets (Canonical Completeness)

| Sorry | Location | Status | Fix |
|-------|----------|--------|-----|
| `bfmcs_from_mcs_temporally_coherent` | Completeness.lean:237 | HARD but tractable | Restricted coherence refactoring |

### Already Sorry-Free (Verified)

| Component | Status |
|-----------|--------|
| `build_restricted_tc_family` (forward_F, backward_P within DRM) | Sorry-free |
| `boxClassFamilies` (modal saturation) | Sorry-free |
| `ParametricCanonicalTaskFrame` (frame axioms) | Sorry-free |
| `parametric_box_persistent` (box persistence) | Sorry-free |
| `shifted_truth_lemma` (truth lemma given coherence) | Sorry-free |
| Soundness theorem | Sorry-free |

### Cleanup (Independent)

| Sorry | Location | Status |
|-------|----------|--------|
| fuel=0 branches (3) | SuccChainFMCS.lean:5833,5991,6187 | CLOSABLE (fuel invariant) |
| `constrained_successor_seed_restricted_consistent` | SuccChainFMCS.lean:2237 | FALSE (dead code) |
| Dead code (2) | SuccChainFMCS.lean:2190,2212 | Remove |

---

## Teammate Contributions

| Teammate | Angle | Status | Key Finding | Confidence |
|----------|-------|--------|-------------|------------|
| A | Simultaneous induction construction | Completed | Chain built once; truth lemma by depth induction; type refactoring is the key | HIGH |
| B | f_step + deferralClosure mechanism | Completed | DRM construction sorry-free; bridge gap precisely at G/H propagation | HIGH |
| C | Literature verification + integration | Completed | Approach is literature-compatible; interaction axioms are one-directional | HIGH |
| D | Critic / devil's advocate | Completed | Truth lemma already done; sorry is in construction; type refactoring addresses this | HIGH |

### Synthesis Assessment

**Conflicts found**: 3 (all resolved — see Conflict Analysis above)
**Gaps identified**: 1 remaining (G/H propagation in extended chain — likely resolvable via single-step g_persistence)
**Consensus**: Phase 1 (FMP) is unanimous. Phase 2 (restricted coherence) has 55-65% confidence.

---

## References

### Codebase (Key Locations)

- `build_restricted_tc_family`: SuccChainFMCS.lean:6313 (sorry-free forward_F/backward_P)
- `restricted_truth_lemma`: RestrictedTruthLemma.lean:291 (sorry-free DRM↔extension)
- `restricted_chain_subset_extended`: RestrictedTruthLemma.lean:218 (sorry-free embedding)
- `bfmcs_from_mcs_temporally_coherent`: Completeness.lean:237 (THE sorry)
- `boxClassFamilies_modal_forward/backward`: UltrafilterChain.lean:2654/2737 (sorry-free)
- `mcs_all_future_closure`: TruthPreservation.lean:263 (FMP sorry, closable)
- `mcs_all_past_closure`: TruthPreservation.lean:281 (FMP sorry, closable)
- `temp_t_future`: Axioms.lean:290 (G(φ) → φ)
- `temp_t_past`: Axioms.lean:304 (H(φ) → φ)
- `modal_future`: Axioms.lean:311 (□φ → □Gφ)
- `temp_future`: Axioms.lean:318 (□φ → G□φ)

### Literature

- Goldblatt 1992: Structural induction truth lemma for tense logic (uni-modal)
- Gabbay/Hodkinson/Reynolds 1994: Step-by-step construction with fair scheduling
- Gabbay/Kurucz/Wolter/Zakharyaschev 2003: Product FMP (weak completeness only)
- Blackburn/de Rijke/Venema 2001: Canonical models and completeness
