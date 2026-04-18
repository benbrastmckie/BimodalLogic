# Implementation Plan: Quasimodel Oracle Approach with Corrected Seed Consistency (v39)

- **Task**: 93 - Complete BXCanonical embedding
- **Status**: [NOT STARTED]
- **Effort**: 10 hours
- **Dependencies**: Task 92 (truth lemma sorry-free)
- **Research Inputs**: reports/39_team-research.md, reports/38_team-research.md, reports/37_team-research.md
- **Artifacts**: plans/39_bxcanonical-embedding.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

This plan closes the three sorry sites reachable from `bx_completeness` (lines 1517, 1522, 1527 in RootScopedChain.lean): `dd_bfmcs_restricted_tc`, `dd_bfmcs_restricted_buc`, and `dd_bfmcs_restricted_fuc`. After 38 prior rounds and 21 definitively dead approaches, round 39 research identified a critical correction: Plan v37's oracle approach was abandoned on a false blocker. The extended seed consistency proof uses a subset-of-MCS argument for Until defects, NOT G-lifting. This plan re-attempts the oracle approach with the corrected understanding, starting with the independent quick win (restricted_buc), then building the HintikkaStepOracle discharge and chain-to-FMCS bridge. Definition of done: `lake build` succeeds and `#print axioms bx_completeness` lists only `propext`, `Classical.choice`, `Quot.sound`.

### Research Integration

- **Report 39** (team, 4 teammates): Systematic review of all 38 prior rounds. Critical correction: Plan v37 oracle abandoned on false blocker (G-lift concern for Until formulas is irrelevant because seed consistency uses subset-of-MCS argument). Two viable paths identified: (1) quasimodel oracle (HIGH confidence for oracle discharge), (2) sr_fwd_chain with f_carry (50% confidence). Quick win: restricted_buc is independent of forward_F blocker.
- **Report 38** (team, 4 teammates): Unanimous: do not change language. `self_resolving_fwd_step` and `defect_bwd_step` are sorry-free primitives. Plan v38 Phase 1 blocked because `self_resolving_fwd_step` produces a NEW MCS not in the dd_chain (BX11 perpetual deferral problem).
- **Report 37** (team, 4 teammates): Oracle + quasimodel architecture is correct. Extended seed consistency was blocked (now understood to be a false blocker).

### Prior Plan Reference

**Plan v38** (Direct Coherence Proofs): Attempted to prove coherence directly on existing dd_bfmcs using `self_resolving_fwd_step`. Phase 1 blocked because the new MCS from `self_resolving_fwd_step` is NOT a point in the dd_chain, and splicing it in destroys other F-obligations (the fundamental BX11 perpetual deferral tension). Key lesson: direct coherence on dd_bfmcs with its round-robin dd_chain is extremely difficult because the chain construction and coherence proofs are tightly coupled.

**Plan v37** (Extended Seed Oracle + Hybrid BFMCS): Attempted to build a quasimodel-backed BFMCS bypassing dd_fmcs. Phase 1 blocked on extended seed consistency, diagnosed as "G-lift fails for Until formulas." Report 39 corrects this diagnosis: the consistency proof does NOT need G-lifting for Until formulas. Until defects come from `w.formulas` directly and bypass G-lifting entirely. The oracle approach deserves rigorous re-examination.

**Effort calibration**: Plans v37 and v38 each estimated 6-8 hours and blocked within Phase 1. This plan allocates 10 hours to account for the deeper difficulty and includes explicit diagnostic checkpoints to detect blockers early with mathematical precision rather than abandoning prematurely.

### Guiding Principle: Mathematical Rigor Over Premature Abandonment

This plan embodies the principle that one must NOT give up on an implementation approach without definitive evidence that it cannot work. If definitive evidence emerges that an approach fails, those findings must be used to gain deeper insight into the root issues to find a better approach. The history of this task shows that at least one viable approach (Plan v37's oracle) was abandoned based on a mischaracterized blocker. Each phase below includes explicit success criteria and diagnostic steps to distinguish genuine mathematical impossibility from implementation difficulty.

### Roadmap Alignment

No ROADMAP.md found.

## Goals & Non-Goals

**Goals**:
- Close `dd_bfmcs_restricted_buc` (backward Until/Since coherence) as an independent quick win
- Discharge `HintikkaStepOracle` using `until_eventuality_resolution` + `sigma_signature` projection, with corrected extended seed consistency argument
- Build a chain-to-FMCS bridge converting finite Hintikka chains to Int-indexed FMCS families
- Close `dd_bfmcs_restricted_tc` and `dd_bfmcs_restricted_fuc` using the quasimodel-backed BFMCS
- Achieve sorry-free `bx_completeness`

**Non-Goals**:
- Replacing the BX axiom system or changing the logic's language (unanimously rejected by report 38)
- Closing the 5 dead-code sorry sites unreachable from `bx_completeness` (lines 1413, 1457, 1464, 2196, 2289)
- Dense completeness (separate task 68)
- The sr_fwd_chain approach (relegated to contingency; 50% confidence is too low for primary path)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Extended seed consistency argument has a subtle gap not caught by informal analysis | H | L (15%) | The argument is well-understood: Until defects from `w.formulas` bypass G-lifting. Formally verify the subset inclusion `seed ⊆ w.formulas` step by step. If a gap emerges, document the exact failure point as mathematical insight for future attempts. |
| Chain-to-FMCS bridge is harder than estimated (~750 LOC): converting finite Hintikka chains to Int-indexed FMCS may require non-trivial padding/extension | H | M (35%) | Phase 3 includes a preliminary design step before coding. The key question (how to extend a finite chain to a bi-infinite FMCS) has a known answer: pad with the constant chain at the witness point. If the bridge hits obstacles, document which specific FMCS property fails. |
| Backward Until coherence (restricted_buc) requires Until introduction derived rule not available from BX1-BX12 | M | M (25%) | Phase 1 begins with a 30-minute verification of BX6's exact statement and available Until infrastructure. If the derived rule is not obtainable, document the precise derivation gap as a root-cause finding. |
| Oracle discharge fails because the "witness reached" branch does NOT always fire for SubformulaClosure(root) | H | L (10%) | Report 39 analysis is clear: `SubformulaClosure_untl_closed` guarantees `psi in Sigma` whenever `phi U psi in Sigma`. Verify this formally at the start of Phase 2. |
| G-content propagation through bx_le at chain realization step fails for formulas outside Sigma | M | M (30%) | This is the known obstacle from Realization.lean:377-394. The quasimodel approach sidesteps this by building a NEW FMCS from the chain rather than threading through the existing dd_chain. If the bridge construction encounters this obstacle, use `g_content_sigma` (Sigma-restricted g_content) which IS provably propagated. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | -- |
| 3 | 3 | 2 |
| 4 | 4 | 1, 3 |
| 5 | 5 | 4 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Backward Until/Since Coherence (restricted_buc) [NOT STARTED]

**Goal**: Close `dd_bfmcs_restricted_buc` independently of the forward_F blocker. This is the easiest of the three sorry sites and does not depend on the oracle approach.

**Tasks**:
- [ ] **Diagnostic (30 min)**: Read `ProofSystem/Axioms.lean` and catalog the exact statements of BX5 (self-accumulation), BX6 (absorption), BX8 (reflexive Until intro), BX9 (Until elimination). Verify which derived rules are already available at the MCS level. Check for existing `until_intro` or backward Until infrastructure in `SuccRelation.lean`, `CanonicalChain.lean`, and `Frame.lean`.
- [ ] **Until introduction derived rule at MCS level**: Prove `psi ∈ M ∨ (phi ∈ M ∧ F(phi U psi) ∈ M) → phi U psi ∈ M` for any MCS `M`. Derivation strategy: (a) `psi → phi U psi` from BX8; (b) for the second disjunct, use BX12 (`F(chi) → top U chi`) to get `top U (phi U psi) ∈ M`, then use BX5 self-accumulation with guard strengthening. If this derived rule is not obtainable from BX1-BX12, document the exact derivation gap and attempt an alternative: direct induction using BX axioms at the chain level.
- [ ] **Backward Until by induction on witness distance**: Prove that if `psi ∈ fam.mcs(s)` and `phi ∈ fam.mcs(r)` for all `r ∈ [t, s)`, then `phi U psi ∈ fam.mcs(t)`. Induction on `s - t`:
  - Base case (`s = t`): `psi ∈ mcs(t)`, so `phi U psi ∈ mcs(t)` by BX8.
  - Step case (`s = t + k + 1`): `phi ∈ mcs(t)` (guard at t). By IH, `phi U psi ∈ mcs(t+1)`. Need: `phi ∈ mcs(t)` and `phi U psi ∈ mcs(t+1)` imply `phi U psi ∈ mcs(t)`. Use backward F-propagation: from `phi U psi ∈ mcs(t+1)`, derive `F(phi U psi) ∈ mcs(t)` via `connect_past` (BX4: `chi → H(F(chi))`) plus h_content propagation. Then apply the Until introduction derived rule.
- [ ] **Prove `F(phi U psi) ∈ mcs(t)` from `phi U psi ∈ mcs(t+1)`**: Use `connect_past`: `phi U psi ∈ mcs(t+1)` implies `H(F(phi U psi)) ∈ mcs(t+1)` by BX4. Since `h_content(mcs(t+1)) ⊆ mcs(t)` (dd_chain backward H-propagation), we get `F(phi U psi) ∈ mcs(t)`.
- [ ] **Backward Since coherence symmetrically**: Mirror the Until proof using BX8' (reflexive Since intro), BX9' (Since elimination), and forward G-propagation via `connect_future` (BX3).
- [ ] Close the sorry at line 1522

**Timing**: 2 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- backward Until/Since coherence proof
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalChain.lean` -- Until introduction derived rule (if not already present)

**Verification**:
- `dd_bfmcs_restricted_buc` compiles without sorry
- `lake build` succeeds

**Diagnostic checkpoint**: If the Until introduction derived rule cannot be obtained from BX1-BX12 within 1 hour, document the exact axiom gap and attempt a direct induction approach that avoids the derived rule entirely. Do NOT abandon the phase without definitively establishing whether the derivation is impossible or merely difficult.

---

### Phase 2: HintikkaStepOracle Discharge [NOT STARTED]

**Goal**: Prove that `HintikkaStepOracle` holds for `Sigma = SubformulaClosure(root)`. This is the key unproved piece of the quasimodel infrastructure.

**Tasks**:
- [ ] **Verify the oracle always reaches witness (30 min)**: Formally confirm that for `Sigma = SubformulaClosure(root)`, `SubformulaClosure_untl_closed` guarantees `psi ∈ Sigma` whenever `phi U psi ∈ Sigma`. This means the oracle's "witness reached" branch always fires eventually, so NO defect-monotonicity argument is needed for the `Sigma = SubformulaClosure(root)` case. Document this verification clearly in the code.
- [ ] **Construct the oracle witness**: For a Hintikka point `h` with `phi U psi ∈ h.formulas` and `psi ∉ h.formulas`:
  1. The backing BXPoint `w` (from `ChainWitnessed` or from `sigma_signature`) has `phi U psi ∈ w.formulas`.
  2. Apply `until_eventuality_resolution` to `w` to get `v : BXPoint` with `bx_le w v` and `psi ∈ v.formulas`.
  3. Project `v` through `sigma_signature` to get the successor `HintikkaPoint`.
  4. The successor has `psi ∈ sigma_signature(v, Sigma)` because `psi ∈ v.formulas` and `psi ∈ Sigma` (by `SubformulaClosure_untl_closed`).
  5. The successor is backed by `v` (as a `WitnessedHintikka`).
- [ ] **Verify hintikka_step**: Show `hintikka_step h (sigma_signature v Sigma)` holds:
  - G-propagation: if `G(chi) ∈ h.formulas`, then `G(chi) ∈ w.formulas` (backing), then `chi ∈ v.formulas` (by `bx_le w v`, so `g_content w ⊆ v`), then `chi ∈ sigma_signature(v, Sigma)` if `chi ∈ Sigma` (by `SubformulaClosure_G_closed`).
  - H-backward: if `H(chi) ∈ sigma_signature(v, Sigma)`, then `H(chi) ∈ v.formulas`, then `chi ∈ w.formulas` (by `bx_le w v` gives `g_content w ⊆ v`, but H-backward needs `h_content v ⊆ w`, which is NOT guaranteed by `bx_le`). **This is a potential gap.** Investigate: does `bx_le w v` give us `h_content(v) ⊆ w`? If not, does the H-backward clause of `hintikka_step` need modification, or does the construction need a different approach?
  - Until propagation: if `phi' U psi' ∈ h.formulas` and `psi' ∉ h.formulas`, then `phi' ∈ h.formulas` (guard from `h`'s consistency) and `phi' U psi' ∈ sigma_signature(v, Sigma)` (if it persists through `bx_le`).
- [ ] **Extended seed consistency (corrected argument)**: Prove that the seed for the oracle step is consistent. The seed is `{psi_target} ∪ g_content(w) ∪ {active Until defects from w}`. The corrected argument:
  - Until defects come from `w.formulas` directly (they are active defects of w).
  - The seed is a subset of `{psi_target} ∪ w.formulas` (since g_content(w) ⊆ w.formulas by G-reflexivity BX1, and Until defects ⊆ w.formulas).
  - Consistency: if `L ⊢ bot` and `L ⊆ seed`, then `L \ {psi_target} ⊆ w.formulas`, so `G(L \ {psi_target}) ⊢ G(neg psi_target)`, giving `G(neg psi_target) ∈ w`, contradicting `F(psi_target) ∈ w`.
  - Key verification: does `G(L \ {psi_target}) ⊢ G(neg psi_target)` follow from `L ⊢ bot`? This is the standard G-monotonicity argument used in `forward_temporal_witness_seed_consistent`. Verify the exact lemma is available.
- [ ] **Handle the H-backward gap**: If `bx_le w v` does NOT give `h_content(v) ⊆ w`, explore alternatives:
  - (a) Weaken the `hintikka_step` H-backward clause to only require `h_content_sigma` (Sigma-restricted).
  - (b) Use `until_eventuality_resolution`'s specific structure: `v` is a Lindenbaum extension that may satisfy additional properties beyond bare `bx_le`.
  - (c) Modify the oracle construction to use `bx_ge` (backward `bx_le`) if the Until resolution gives both forward and backward accessibility.
  - Document findings precisely rather than abandoning.
- [ ] Write `oracle_for_subformula_closure` or equivalent theorem

**Timing**: 2.5 hours

**Depends on**: none (independent of Phase 1)

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/Realization.lean` -- oracle discharge proof
- `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/LocusControl.lean` -- possible helper lemmas

**Verification**:
- `HintikkaStepOracle` for `SubformulaClosure(root)` compiles without sorry
- `hintikka_chain_exists` can be instantiated with the discharged oracle
- `lake build` succeeds

**Diagnostic checkpoint**: The H-backward clause (task 3) is the most likely gap. If `bx_le w v` genuinely does not provide `h_content(v) ⊆ w`, this is a STRUCTURAL issue with the oracle, not a superficial bug. In that case, document precisely what `until_eventuality_resolution` provides (what relation does `v` have to `w` beyond `bx_le`?) and whether the `hintikka_step` definition can be relaxed to a one-sided step for the oracle use case.

---

### Phase 3: Chain-to-FMCS Bridge [NOT STARTED]

**Goal**: Build the bridge from finite Hintikka chains (produced by `hintikka_chain_exists`) to Int-indexed FMCS families that can be plugged into `dd_bfmcs`.

**Tasks**:
- [ ] **Design the bridge construction (1 hour)**: Before writing code, work out the mathematical construction on paper. A Hintikka chain is a finite list `[h_0, h_1, ..., h_n]` of HintikkaPoints. An FMCS family maps `Int -> Set Formula` (the MCS at each time). The bridge must:
  1. Realize each Hintikka point `h_i` as a BXPoint `w_i` with `h_i.formulas ⊆ w_i.formulas` (already provided by `ChainWitnessed`).
  2. Extend the finite chain to a bi-infinite FMCS. Strategy: pad with the constant witness at the endpoints. For `t < 0`, use `w_0`; for `t > n`, use `w_n`. The FMCS requires `g_content(mcs(t)) ⊆ mcs(t+1)` and `h_content(mcs(t+1)) ⊆ mcs(t)` at all times.
  3. At the padding boundaries: `g_content(w_0) ⊆ w_0` (G-reflexivity, from BX1 at MCS level) and `h_content(w_n) ⊆ w_n` (H-reflexivity, from BX2 at MCS level). So constant padding works for the padding regions.
  4. At the chain-to-padding boundary: `g_content(w_{n-1}) ⊆ w_n` requires `bx_le w_{n-1} w_n`. This is provided by the chain realization if `w_i`s are constructed with `bx_le` between consecutive points. But `ChainWitnessed` only gives EXISTENCE of backing witnesses, not `bx_le` between them.
  5. Therefore, chain realization must construct `w_i`s with `bx_le w_{i-1} w_i`. This uses Lindenbaum extension from the seed `h_{i+1}.formulas ∪ g_content(w_i.formulas)`, whose consistency is proved by `chain_step_seed_consistent_enriched`.
- [ ] **Define `realize_chain`**: Given a witnessed Hintikka chain and a starting BXPoint, construct a sequence of BXPoints with `bx_le` between consecutive points and `h_i.formulas ⊆ w_i.formulas` for each point.
- [ ] **Define `chain_to_fmcs`**: Given a realized chain `[w_0, ..., w_n]`, construct the bi-infinite FMCS:
  ```
  mcs(t) = w_0.formulas         if t < 0
  mcs(t) = w_t.formulas         if 0 <= t <= n
  mcs(t) = w_n.formulas         if t > n
  ```
- [ ] **Prove FMCS coherence**: Show that `chain_to_fmcs` satisfies:
  - `g_content(mcs(t)) ⊆ mcs(t+1)` for all t (forward G-propagation)
  - `h_content(mcs(t+1)) ⊆ mcs(t)` for all t (backward H-propagation)
  - Each `mcs(t)` is an MCS
- [ ] **Prove Box coherence**: Show the FMCS satisfies the `dd_bfmcs` Box coherence conditions. This requires all `w_i` to have the SAME Box content as the starting BXPoint `w_0`. Since `bx_le w_{i-1} w_i` gives `g_content(w_{i-1}) ⊆ w_i`, and `g_content` includes `G(chi)` formulas, Box content IS preserved through `bx_le` (Box = G in the modal fragment). Verify this formally.
- [ ] **Handle the h_content direction**: The FMCS requires `h_content(mcs(t+1)) ⊆ mcs(t)`, which is the backward direction. `bx_le w_i w_{i+1}` only gives the FORWARD direction. For backward: use the Lindenbaum construction seed which includes `h.formulas` of the Hintikka point. Since `hintikka_step h_i h_{i+1}` gives `H(chi) ∈ h_{i+1} → chi ∈ h_i`, and `h_i.formulas ⊆ w_i.formulas`, we get `chi ∈ w_i.formulas` whenever `H(chi) ∈ h_{i+1}.formulas`. But we need `H(chi) ∈ w_{i+1}.formulas → chi ∈ w_i.formulas`, which is stronger (w_{i+1} may have H-formulas outside h_{i+1}). This gap must be addressed: either strengthen the Lindenbaum seed to include `h_content(w_{i+1})` (circular -- w_{i+1} not yet constructed), or ensure the Lindenbaum extension inherits H-closure from the chain structure.
- [ ] **Alternative bridge design if h_content gap is genuine**: If the h_content direction cannot be achieved constructively, consider building the FMCS with a WEAKER coherence condition (forward-only `g_content` propagation) and separately proving that `dd_bfmcs` only needs forward coherence for the restricted_tc proof. Alternatively, construct `w_i`s using a BIDIRECTIONAL Lindenbaum seed: `h_{i}.formulas ∪ g_content(w_{i-1}) ∪ h_content(w_{i+1})`. This requires a two-pass construction (forward pass to get g_content seeds, backward pass to get h_content seeds).

**Timing**: 3 hours

**Depends on**: 2 (needs discharged oracle to instantiate `hintikka_chain_exists`)

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/Realization.lean` -- chain realization
- New file: `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/ChainBridge.lean` -- chain-to-FMCS bridge (if Realization.lean becomes too large)

**Verification**:
- `chain_to_fmcs` produces a valid FMCS (all coherence conditions compile without sorry)
- The FMCS can be registered as a `dd_bfmcs` family
- `lake build` succeeds

**Diagnostic checkpoint**: The h_content backward direction (task 6) is the primary risk. If after 1.5 hours this gap is not resolved, switch to the alternative bridge design (task 7) or document the precise obstacle for the next round. The key mathematical question: does the Lindenbaum extension from `h_{i+1}.formulas ∪ g_content(w_i.formulas)` automatically include `h_content` of the next point? If not, is there a seed augmentation that achieves this without circularity?

---

### Phase 4: Wire into dd_countermodel (restricted_tc + restricted_fuc) [NOT STARTED]

**Goal**: Use the quasimodel-backed FMCS from Phase 3 to close `dd_bfmcs_restricted_tc` and `dd_bfmcs_restricted_fuc`.

**Tasks**:
- [ ] **Prove restricted_tc (F/P eventuality discharge)**: Given `F(psi) ∈ fam.mcs(t)` for a dd_bfmcs family, construct a quasimodel chain resolving psi:
  1. The family's MCS at time t is backed by a BXPoint `w_t` with `F(psi) ∈ w_t.formulas`.
  2. If `psi ∉ w_t.formulas`, apply `until_eventuality_resolution` or use the Hintikka chain from `hintikka_chain_exists` with the discharged oracle (Phase 2).
  3. The chain-to-FMCS bridge (Phase 3) produces a new FMCS family where the witness point has `psi ∈ mcs(s)` for some `s > t`.
  4. Register this new FMCS as a family in `dd_bfmcs` and show it has the same evaluation family membership.
  5. Key subtlety: the new family may differ from the original family. Show the coherence conditions are inherited.
- [ ] **Prove restricted_tc for P symmetrically**: Use `since_eventuality_resolution` and the Since dual of the Hintikka chain.
- [ ] **Prove restricted_fuc (forward Until/Since coherence)**: Given `phi U psi ∈ fam.mcs(t)`:
  1. By BX10, `F(psi) ∈ fam.mcs(t)`. By restricted_tc (just proved), there exists `s > t` with `psi ∈ fam.mcs(s)`.
  2. For the guard: need `phi ∈ fam.mcs(r)` for all `r ∈ [t, s)`. This comes from the Hintikka chain guard property (`hintikka_chain_guard_step`): at each intermediate Hintikka point where `phi U psi` is present and `psi` is absent, `phi` is present.
  3. The chain-to-FMCS bridge preserves the guard because `h_i.formulas ⊆ w_i.formulas` and the guard is in `h_i.formulas`.
  4. Wire the guard through the FMCS.
- [ ] **Prove restricted_fuc for Since symmetrically**
- [ ] **Close the sorry at line 1517 (restricted_tc)**
- [ ] **Close the sorry at line 1527 (restricted_fuc)**
- [ ] **Verify dd_countermodel compiles without sorry**: This should follow automatically from Phases 1-4 closing all three sorry sites.

**Timing**: 2 hours

**Depends on**: 1, 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- restricted_tc, restricted_fuc proofs
- Possibly `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/ChainBridge.lean` -- helper lemmas for wiring

**Verification**:
- `dd_bfmcs_restricted_tc` compiles without sorry
- `dd_bfmcs_restricted_fuc` compiles without sorry
- `dd_countermodel` compiles without sorry
- `lake build` succeeds

**Diagnostic checkpoint**: If the guard property for restricted_fuc does not thread through the FMCS as expected, check whether the Hintikka chain's Until propagation clause (clause 3 of `hintikka_step`) gives sufficient information. If not, the guard may need to be proved independently using BX9 at the MCS level at each step, which reduces to the same argument as Plan v38 Phase 2 but on the quasimodel-backed chain rather than dd_chain.

---

### Phase 5: Integration, Cleanup, and Verification [NOT STARTED]

**Goal**: Verify `bx_completeness` is sorry-free. Annotate dead code. Final build.

**Tasks**:
- [ ] Verify `bx_completeness` compiles without sorry
- [ ] Run `#print axioms bx_completeness` and confirm only `propext`, `Classical.choice`, `Quot.sound`
- [ ] Annotate the 5 dead-code sorry sites (1413, 1457, 1464, 2196, 2289) with comments explaining they are unreachable from `bx_completeness`
- [ ] Mark BX11-based `enriched_fwd_step` / `resolving_enriched_fwd_exists` and `rr_fwd_chain_forward_F` as dead code
- [ ] Add docstrings to new theorems explaining the mathematical argument
- [ ] Run full `lake build`
- [ ] Grep for remaining sorry in BXCanonical files; verify none reachable from `bx_completeness`

**Timing**: 0.5 hours

**Depends on**: 4

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- annotations, docstrings
- `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/Realization.lean` -- docstrings

**Verification**:
- `lake build` succeeds
- `#print axioms bx_completeness` shows only `propext`, `Classical.choice`, `Quot.sound`
- No reachable sorry from `bx_completeness`

---

## Testing & Validation

- [ ] `lake build` succeeds after each phase
- [ ] `lean_verify` on `dd_bfmcs_restricted_buc` after Phase 1 -- no sorry dependency
- [ ] `lean_verify` on `HintikkaStepOracle` instantiation after Phase 2 -- no sorry dependency
- [ ] `lean_verify` on `chain_to_fmcs` after Phase 3 -- no sorry dependency
- [ ] `lean_verify` on `dd_bfmcs_restricted_tc` after Phase 4 -- no sorry dependency
- [ ] `lean_verify` on `dd_bfmcs_restricted_fuc` after Phase 4 -- no sorry dependency
- [ ] `lean_verify` on `dd_countermodel` after Phase 4 -- no sorry dependency
- [ ] `lean_verify` on `bx_completeness` after Phase 5 -- only `propext`, `Classical.choice`, `Quot.sound`
- [ ] All new theorems have docstrings after Phase 5

## Artifacts & Outputs

- `specs/093_complete_bxcanonical_embedding/plans/39_bxcanonical-embedding.md` -- this plan
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- coherence proofs (Phases 1, 4)
- `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/Realization.lean` -- oracle discharge (Phase 2), chain realization (Phase 3)
- `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/ChainBridge.lean` -- chain-to-FMCS bridge (Phase 3, if needed)
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalChain.lean` -- Until introduction derived rule (Phase 1, if needed)

## Rollback/Contingency

1. **Full success**: `bx_completeness` sorry-free. No rollback needed.

2. **Phase 2 blocked (oracle discharge)**: If the H-backward clause of `hintikka_step` cannot be satisfied by `until_eventuality_resolution`, investigate whether a RELAXED `hintikka_step` (forward-only, dropping H-backward) still allows `hintikka_chain_exists` and `hintikka_chain_guard_step` to hold. If so, build the oracle with the relaxed step. If not, fall back to the sr_fwd_chain approach with f_carry augmentation (report 39, Path 2, ~400-600 LOC).

3. **Phase 3 blocked (chain-to-FMCS bridge)**: If the h_content backward direction is unresolvable, attempt a direct proof of restricted_tc on dd_bfmcs using the quasimodel chain at the ABSTRACT level (showing existence of witnesses) rather than constructing a concrete FMCS. The quasimodel chain proves `psi ∈ h_n.formulas` for some finite n, and `ChainWitnessed` gives a BXPoint with `psi`. Show this BXPoint is accessible from the dd_chain via `bx_le`.

4. **Phase 1 blocked (restricted_buc)**: If the Until introduction derived rule is unobtainable, attempt restricted_buc via the quasimodel approach as well (backward Hintikka chain via `HintikkaStepOracleSince`). This makes restricted_buc depend on Phase 2 but may be technically easier.

5. **Complete failure (all paths blocked)**: Document precisely which mathematical properties are missing. The three most informative diagnostics are: (a) does `bx_le w v` give `h_content(v) ⊆ w`? (b) does the Until introduction rule `psi ∨ (phi ∧ F(phi U psi)) → phi U psi` follow from BX1-BX12? (c) does the extended seed `{psi_target} ∪ g_content(w) ∪ Until_defects(w)` have provable consistency? Each answer narrows the space of viable approaches.

6. **Full rollback**: `git checkout -- Theories/Bimodal/Metalogic/BXCanonical/` restores current state.
