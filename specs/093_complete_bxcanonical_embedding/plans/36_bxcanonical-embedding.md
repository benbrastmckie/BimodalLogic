# Implementation Plan: Oracle Construction + Quasimodel-Backed BFMCS (v36)

- **Task**: 93 - Complete BXCanonical embedding
- **Status**: [IMPLEMENTING]
- **Effort**: 10 hours
- **Dependencies**: Task 92 (truth lemma sorry-free)
- **Research Inputs**: reports/36_team-research.md
- **Artifacts**: plans/36_bxcanonical-embedding.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

This plan replaces the sorry-carrying `dd_bfmcs` chain infrastructure with a quasimodel-backed BFMCS construction. The core insight (from 36 rounds of research) is that the existing `defect_fwd_chain`/`defect_bwd_chain` approach is fundamentally blocked by the BX11 perpetual deferral obstruction. Instead, we build `HintikkaStepOracle` from `bx_forward_witness`, use the already sorry-free `hintikka_chain_exists` (Construction.lean) to produce finite Until/Since-resolving chains, construct a new BFMCS from the backing BXPoints, and derive full temporal coherence via BX12. Definition of done: `lake build` succeeds, `#print axioms bx_completeness` lists only `propext`, `Classical.choice`, `Quot.sound`.

### Research Integration

- **Report 36** (team research, 4 teammates): Confirmed the quasimodel oracle construction is feasible -- `bx_forward_witness` provides the one-step BXPoint witness, `sigma_signature` projects it to HintikkaPoint level, and `hintikka_step` only requires one-step G-propagation (not multi-step persistence). Full Until/Since coherence avoids the `subformulaClosure` membership gap for BX12-derived `(top U psi)` formulas. The `dd_bfmcs` construction must be REPLACED, not patched.

### Prior Plan Reference

Plan v35 attempted to prove Until/Since coherence directly on the existing `dd_bfmcs` chain but reached [BLOCKED] at Phase 1 due to the same perpetual deferral obstruction. The BX12 bridge was correctly identified as the F->Until reduction path, but the termination argument for `forward_until` on the defect-driven chain could not be closed. Key lessons: (1) proving temporal properties on the defect-driven chain is fundamentally blocked; (2) the quasimodel framework provides the right abstraction level; (3) full (unrestricted) coherence is easier than restricted coherence because it avoids closure membership checks.

### Roadmap Alignment

No ROADMAP.md found.

## Goals & Non-Goals

**Goals**:
- Construct `HintikkaStepOracle` from `bx_forward_witness` (forward) and `bx_backward_witness` (backward Since)
- Build a new BFMCS construction backed by quasimodel chains instead of defect-driven chains
- Prove full Until/Since coherence from the quasimodel chain properties
- Derive forward_F/backward_P via BX12 bridge
- Close all 3 critical sorry sites (1517, 1522, 1527) by replacing `dd_bfmcs_restricted_tc`, `dd_bfmcs_restricted_buc`, `dd_bfmcs_restricted_fuc`
- Achieve sorry-free `bx_completeness`

**Non-Goals**:
- Fixing `defect_fwd_chain_forward_F` (line 2196) or `defect_bwd_chain_backward_P` (line 2289) -- these become dead code
- Fixing `rr_fwd_chain_forward_F` (line 1413) or its dependents (1457, 1464) -- same dead code
- Modifying the quasimodel framework itself (Construction.lean, HintikkaPoint.lean -- already sorry-free)
- Dense completeness (task 68)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Oracle construction: BXPoint witness does not satisfy all hintikka_step clauses | H | L (20%) | Research A confirmed H-backward and G-propagation both work via `bx_le`. Until defect propagation follows from BX9/BX10 on the backing MCS. |
| Sigma closure: `enrichedClosure` may not include all needed formulas for sigma_signature | H | M (30%) | Use `enrichedClosure root` as Sigma. If specific formulas are missing, extend enrichedClosure. Fallback: use a custom Finset containing all needed subformulas. |
| Int extension: extending finite quasimodel chain to Int-indexed FMCS | M | M (35%) | Forward: repeat last BXPoint (all defects resolved). Backward: symmetric. The last-state extension preserves g_content reflexively. |
| `dd_countermodel` wiring: new BFMCS may not fit existing `dd_countermodel` signature | M | L (15%) | The new BFMCS has the same type (`BFMCS Int`). Only the construction changes, not the interface. |
| BX12 bridge: `top U psi` not in `subformulaClosure(root)` for restricted coherence | M | M (40%) | Prove FULL (unrestricted) Until/Since coherence on the new BFMCS, then restricted versions follow as corollaries. This avoids the closure membership check entirely. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2 | -- |
| 2 | 3 | 1, 2 |
| 3 | 4 | 3 |
| 4 | 5 | 4 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Build HintikkaStepOracle from bx_forward_witness [IN PROGRESS]

**Goal**: Construct `HintikkaStepOracle` for arbitrary Until formulas `(phi U psi)` using `bx_forward_witness`, and the symmetric `HintikkaStepOracleSince` using `bx_backward_witness`. This is the central novel construction.

**Tasks**:
- [ ] Choose Sigma: use `enrichedClosure root` (already defined, negation-closed, contains subformulaClosure). Verify that for the formulas we need (Until/Since formulas, their guards, G/H formulas), Sigma membership holds. If enrichedClosure is insufficient, define a custom `oracleSigma` that extends it.
- [ ] Prove `enrichedClosure_neg_closed`: `forall f in enrichedClosure root, f.neg in enrichedClosure root`. This is needed by `sigma_signature` to construct HintikkaPoints. (May already exist as `enriched_neg_pairing_core`.)
- [ ] Define helper: given BXPoint `w` and `Sigma`, construct `WitnessedHintikka Sigma` from `sigma_signature w Sigma h_neg`. The witness is `w` itself, and `point_subset_witness` follows from `sigma_signature_mem`.
- [ ] Prove `bx_forward_oracle_step`: Given HintikkaPoint `h` with backing BXPoint `w` (via `WitnessedHintikka`), if `(phi U psi) in h.formulas` and `psi not in h.formulas`:
  - From `sigma_signature_mem`: `(phi U psi) in w.formulas`
  - By BX9 on MCS `w`: `phi in w.formulas` and `F(phi U psi) in w.formulas`
  - By `bx_forward_witness`: get `v` with `bx_le w v` and `(phi U psi) in v.formulas`... Actually, we need the oracle to either reach psi or decrease defect_count. The step is: BX9 gives `psi in w OR (phi in w AND F(phi U psi) in w)`. Since `psi not in h`, and `h = sigma_signature(w, Sigma)`, we have `psi not in w` (if `psi in Sigma`, then `psi in w` would imply `psi in h`). So BX9 gives `phi in w AND F(phi U psi) in w`. Use `bx_forward_witness` on `F(phi U psi)` to get `v` with `bx_le w v` and `(phi U psi) in v.formulas`. Project: `h' = sigma_signature(v, Sigma)`. Verify hintikka_step h h': G-propagation from `bx_le w v`, H-backward from `bx_le w v`, Until defect propagation from BX9 on `v`.
  - Either `psi in h'.formulas` (done), or `(phi U psi) in h'.formulas` with `defect_count h' < defect_count h`. The defect decrease requires showing that some Until formula discharged in `v` that was defective in `w`. Since `bx_forward_witness` gives `v` with `(phi U psi) in v`, and `bx_le w v` propagates G-formulas, the key is showing the oracle step resolves at least one defect. Use the `hintikka_step_target_decrease` theorem from Construction.lean.
- [ ] Handle the subtlety: `psi not in h.formulas` does NOT directly give `psi not in w.formulas` if `psi not in Sigma`. Prove: if `(phi U psi) in Sigma` and Sigma is subformula-closed, then `psi in Sigma`. This follows from subformula closure properties.
- [ ] Prove `bx_forward_oracle`: `HintikkaStepOracle (Sigma := enrichedClosure root) phi psi` for all `(phi U psi)` in the closure. Wrap `bx_forward_oracle_step` in the universal quantifier.
- [ ] Prove `bx_backward_oracle`: `HintikkaStepOracleSince (Sigma := enrichedClosure root) phi psi` by symmetric construction using `bx_backward_witness`.
- [ ] Verify each new theorem compiles (`lake build` on the modified file)

**Timing**: 3 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/Realization.lean` -- add oracle construction from bx_forward_witness/bx_backward_witness
- `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/EnrichedClosure.lean` -- verify/add negation closure property

**Verification**:
- `bx_forward_oracle` and `bx_backward_oracle` compile without sorry
- `lake build` succeeds

---

### Phase 2: Quasimodel-Backed BFMCS Construction [NOT STARTED]

**Goal**: Build a new `BFMCS Int` from quasimodel chains backed by BXPoints, replacing the sorry-carrying `dd_bfmcs`. This construction takes an MCS `M0` and produces families indexed by `Int`, where each family's chain is built from quasimodel chains that resolve all Until/Since defects.

**Tasks**:
- [ ] Define `qm_fwd_chain`: Given BXPoint `w0` and Sigma, use `hintikka_chain_exists` with `bx_forward_oracle` to build a finite chain resolving all Until defects. Extract backing BXPoints via `ChainWitnessed`. The chain has length <= |Sigma| per defect.
- [ ] Define `qm_bwd_chain`: Symmetric using `hintikka_chain_exists_since` with `bx_backward_oracle`.
- [ ] Define `qm_to_int_fmcs`: Extend the finite quasimodel chain to an Int-indexed FMCS. Strategy: (a) Forward: for `t >= 0`, walk the quasimodel forward chains, iterating over Until defects. For `t` beyond the chain length, repeat the last BXPoint (all defects resolved at that point). (b) Backward: symmetric with Since chains for `t < 0`. (c) Each `mcs(t)` is the formula set of the BXPoint at position `t` in the extended chain.
- [ ] Prove `qm_fmcs_is_mcs`: each `qm_to_int_fmcs.mcs(t)` is MCS (follows from BXPoint.is_mcs).
- [ ] Prove `qm_fmcs_g_content`: `g_content(mcs(t)) subset mcs(t+1)`. For positions within the chain: follows from `bx_le` between consecutive backing BXPoints. For the extension region (repeating last point): `g_content(M) subset M` for MCS `M` follows from G(chi) in M implies chi in M (by S5 reflexivity, i.e., BX4/T axiom).
- [ ] Define `qm_bfmcs`: the full BFMCS construction. Families = `{ shifted(qm_to_int_fmcs(N, h_N), s) | N modal-equivalent to M0, s in Int }`. Modal forward/backward proofs follow the same pattern as existing `dd_bfmcs` (using `bx_modal_witness`).
- [ ] Verify compilation

**Timing**: 3 hours

**Depends on**: none (can proceed in parallel with Phase 1 -- the oracle is needed for the chain, but the BFMCS scaffold and Int-extension can be defined with the oracle as a parameter)

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- add `qm_bfmcs` construction alongside existing `dd_bfmcs`

**Verification**:
- `qm_bfmcs` definition compiles
- `qm_fmcs_is_mcs` and `qm_fmcs_g_content` compile without sorry
- `lake build` succeeds

---

### Phase 3: Full Until/Since Coherence on Quasimodel BFMCS [NOT STARTED]

**Goal**: Prove full (unrestricted) Until/Since coherence on `qm_bfmcs`. This is the central correctness theorem: the quasimodel chain structure gives Until/Since coherence for free via `hintikka_chain_exists`.

**Tasks**:
- [ ] Prove forward Until coherence: Given `(phi U psi) in qm_bfmcs.fam.mcs(t)`, the backing BXPoint `w` at position `t` has `(phi U psi) in w.formulas`. By BX12+BX9 on `w`, get the Until defect. The quasimodel chain from `w` (via oracle) produces a finite chain ending at a point where `psi` holds. The guard `phi` holds at all intermediate positions (from `hintikka_step` Until propagation, lifted via `sigma_signature_mem` to BXPoint level). The witness time `s` is `t + chain_length`.
- [ ] Prove forward Since coherence: Given `(phi S psi) in qm_bfmcs.fam.mcs(t)`, symmetric using the backward oracle and `hintikka_chain_exists_since`.
- [ ] Prove backward Until coherence: Given semantic witnesses (psi at s, phi guarding [t,s)), derive `(phi U psi) in qm_bfmcs.fam.mcs(t)`. Proof: by backward induction from s to t. At s: `psi in mcs(s)` implies `(phi U psi) in mcs(s)` by BX8 (refl_intro_until). At each step r from s-1 down to t: `(phi U psi) in mcs(r+1)` and `phi in mcs(r)` implies `F(phi U psi) in mcs(r)` (from F-introduction on the chain), which combined with `phi in mcs(r)` gives `(phi U psi) in mcs(r)` by BX8.
- [ ] Prove backward Since coherence: symmetric.
- [ ] Derive restricted versions as corollaries: `qm_bfmcs_restricted_fuc` from full forward coherence (just drop the subformulaClosure check). Similarly for `qm_bfmcs_restricted_buc`.

**Timing**: 2 hours

**Depends on**: 1, 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- add Until/Since coherence proofs for `qm_bfmcs`

**Verification**:
- Full Until/Since coherence theorems compile without sorry
- Restricted coherence corollaries compile
- `lake build` succeeds

---

### Phase 4: Temporal Coherence via BX12 Bridge + Countermodel Wiring [NOT STARTED]

**Goal**: Derive restricted temporal coherence (forward_F, backward_P) from Until/Since coherence via BX12/BX12', and wire `qm_bfmcs` into `dd_countermodel` to close all 3 critical sorry sites.

**Tasks**:
- [ ] Prove `qm_bfmcs_forward_F`: Given `F(psi) in fam.mcs(t)`, by BX12 (`F_imp_top_until_mcs`), `(top U psi) in fam.mcs(t)`. Apply full forward Until coherence to get witness `s >= t` with `psi in fam.mcs(s)` and `top` guarding [t,s). The guard is trivially satisfied (top = bot.imp bot, which is in every MCS). If `s = t`, psi already present; use g_content propagation to get a strict witness at `t+1`. Final result: `exists s > t, psi in fam.mcs(s)`.
- [ ] Prove `qm_bfmcs_backward_P`: Symmetric using BX12' (`P_imp_top_since_mcs`).
- [ ] Prove `qm_bfmcs_restricted_tc`: restricted temporal coherence follows from forward_F and backward_P restricted to `deferralClosure root`.
- [ ] Replace `dd_bfmcs` usage in `dd_countermodel`: Change `dd_countermodel` to use `qm_bfmcs` instead of `dd_bfmcs`. The type signature is unchanged (`BFMCS Int`). Replace the three sorry-carrying calls:
  - `dd_bfmcs_restricted_tc` -> `qm_bfmcs_restricted_tc`
  - `dd_bfmcs_restricted_buc` -> `qm_bfmcs_restricted_buc`
  - `dd_bfmcs_restricted_fuc` -> `qm_bfmcs_restricted_fuc`
- [ ] Verify `dd_countermodel` compiles without sorry
- [ ] Verify `bx_completeness` compiles without sorry (it calls `dd_countermodel`)
- [ ] Run `lean_verify` on `bx_completeness` to check axiom list

**Timing**: 1.5 hours

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- BX12 bridge lemmas, replace dd_bfmcs with qm_bfmcs in dd_countermodel
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` -- verify sorry-free path to bx_completeness

**Verification**:
- `dd_countermodel` compiles without sorry
- `bx_completeness` compiles without sorry
- `lean_verify` on `bx_completeness` shows only `propext`, `Classical.choice`, `Quot.sound`
- `lake build` succeeds

---

### Phase 5: Cleanup, Documentation, and Dead Code Annotation [NOT STARTED]

**Goal**: Annotate dead code (old sorry sites), add docstrings to new theorems, and verify the full build.

**Tasks**:
- [ ] Annotate sorry sites at lines 1413, 1457, 1464, 2196, 2289 as dead code (superseded by qm_bfmcs). Add comments explaining they are unreachable from `bx_completeness`.
- [ ] Add docstrings to all new theorems: oracle construction, qm_bfmcs, coherence proofs, BX12 bridge
- [ ] Run full `lake build` to confirm no regressions
- [ ] Run `lean_verify` on `bx_completeness` one final time
- [ ] Grep for remaining sorry in BXCanonical files; verify none are reachable from `bx_completeness`
- [ ] If any reachable sorry found, close it or escalate

**Timing**: 0.5 hours

**Depends on**: 4

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- dead code annotations, docstrings

**Verification**:
- `lake build` succeeds
- `lean_verify` on `bx_completeness` shows only `propext`, `Classical.choice`, `Quot.sound`
- No reachable sorry from `bx_completeness`

---

## Testing & Validation

- [ ] `lake build` succeeds after each phase
- [ ] `lean_verify` on `bx_forward_oracle` after Phase 1 -- no sorry-dependency
- [ ] `lean_verify` on `qm_bfmcs` after Phase 2 -- no sorry-dependency
- [ ] `lean_verify` on full Until/Since coherence after Phase 3 -- no sorry-dependency
- [ ] `lean_verify` on `dd_countermodel` after Phase 4 -- no sorry-dependency
- [ ] `lean_verify` on `bx_completeness` after Phase 4 -- only `propext`, `Classical.choice`, `Quot.sound`
- [ ] All new theorems have docstrings after Phase 5

## Artifacts & Outputs

- `specs/093_complete_bxcanonical_embedding/plans/36_bxcanonical-embedding.md` -- this plan
- `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/Realization.lean` -- oracle construction
- `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/EnrichedClosure.lean` -- negation closure (if needed)
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- qm_bfmcs construction, coherence proofs, BX12 bridge, dd_countermodel rewiring

## Rollback/Contingency

1. **Full success**: bx_completeness sorry-free. No rollback needed.

2. **Oracle construction blocked (~20%)**: If `bx_forward_witness` does not provide enough structure for `hintikka_step` (e.g., Until defect propagation fails), fall back to building a custom one-step oracle directly from BX9+Lindenbaum extension, bypassing `sigma_signature`. Estimated additional 2-3 hours.

3. **Int extension blocked (~35%)**: If the finite-to-Int extension cannot preserve g_content, use the existing `dd_fmcs` Int-indexing and only replace the forward/backward chain contents with quasimodel-derived BXPoints. The `dd_fmcs` infrastructure already handles Int indexing correctly.

4. **Backward Until coherence blocked (~15%)**: Forward direction still succeeds. Close `dd_bfmcs_restricted_fuc` and `dd_bfmcs_restricted_tc` (the latter via BX12 from forward Until). Spawn focused task for backward coherence.

5. **Full rollback**: `git checkout -- Theories/Bimodal/Metalogic/BXCanonical/` restores current state. All existing sorry-free infrastructure is preserved.
