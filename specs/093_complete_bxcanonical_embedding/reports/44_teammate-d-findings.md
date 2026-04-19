# Teammate D Findings: Round 44 - Horizons

**Task**: 93 - Complete BXCanonical embedding
**Date**: 2026-04-19
**Role**: Horizons (literature-aligned architecture)
**Session**: Round 44 team research

---

## Key Findings

### 1. Architecture Redesign: Should dd_countermodel Use Quasimodel-Derived BFMCS?

**Yes, but with a specific structure.** After reading the code and literature, the current `dd_bfmcs` architecture (RootScopedChain.lean:1024-1029) creates families indexed by modal-equivalence classes, where each family is a `shifted_dd_fmcs N h_N sigma_list s`. The chain `dd_chain` (line 608-611) assembles forward and backward chains into an Int-indexed MCS sequence. The 3 sorries all live in proving coherence properties of this chain.

The quasimodel approach would replace the chain construction with one derived from `QuasimodelChain` (Construction.lean), which has **sorry-free** defect-discharge guarantees. The dependency graph would be:

```
dd_countermodel (RootScopedChain.lean)
  └── dd_bfmcs (quasimodel-derived)
        ├── qm_dd_fmcs: Int → MCS  (periodic extension of QuasimodelChain)
        │     ├── QuasimodelChain (Construction.lean, sorry-free)
        │     ├── Realization lifting (Realization.lean, sorry-free)
        │     └── Periodic tiling (NEW: ~200 lines)
        ├── modal_forward / modal_backward (box stability, reuse existing)
        └── restricted_tc / restricted_buc / restricted_fuc
              └── Follow from periodic structure BY CONSTRUCTION
```

### 2. The Unraveling Question: Finite Chain to Int-Indexed Chain

In the literature (Goldblatt 1992, Reynolds 2003), a finite quasimodel **graph** is unraveled into an infinite chain. The codebase has finite **chains** (`QuasimodelChain` is a `List (HintikkaPoint Sigma)`, Construction.lean:382-391), not graphs. The mathematical content of "unraveling" a finite chain into an Int-indexed chain is simply **periodic extension**:

Given a finite chain `h_0, h_1, ..., h_k` of HintikkaPoints (backed by BXPoints via `ChainWitnessed`), define:

```
chain(t) = h_{t mod (k+1)}    for t >= 0
chain(t) = h_{(-t) mod (k+1)} for t < 0  (mirror)
```

This is mathematically trivial as a definition. The non-trivial content is proving the resulting Int-indexed chain satisfies the FMCS coherence requirements. See Finding 3 below.

### 3. Periodic Extension: Does It Satisfy Coherence Properties?

**G-content propagation**: The `hintikka_step` relation (Construction.lean:45-52) guarantees G-propagation: `G(chi) in h_i.formulas -> chi in h_{i+1}.formulas`. For a periodic chain with period `k+1`, this means `G(chi) in chain(t) -> chi in chain(t+1)`. At the BXPoint level (after realization lifting), this gives `g_content(chain(t)) subset chain(t+1)`, which is exactly the FMCS `forward_G` property.

**H-content propagation**: The `hintikka_step` relation also guarantees H-backward: `H(chi) in h_{i+1}.formulas -> chi in h_i.formulas`. For the periodic chain, `H(chi) in chain(t+1) -> chi in chain(t)`, giving the FMCS `backward_H` property.

**Box stability**: This is the critical gap. The `hintikka_step` relation does NOT constrain box formulas. Different HintikkaPoints in the chain can have different box content. However, the `WitnessedHintikka` structure (Construction.lean:459-465) provides a backing `BXPoint` for each HintikkaPoint. If all backing BXPoints are **modal-equivalent** (same box formulas), then box stability holds.

**Key observation**: The `hintikka_chain_exists` theorem (Construction.lean:594-659) builds chains starting from a single BXPoint `w0`. The oracle at each step produces a `WitnessedHintikka` whose backing BXPoint comes from `bx_until_eventuality_resolution` or `bx_since_eventuality_resolution` (Realization.lean:428-442). These are produced by `bx_forward_witness` / `bx_backward_witness` in Frame.lean, which construct new MCS via Lindenbaum extension. The backing BXPoints are NOT guaranteed to be modal-equivalent to `w0`.

**Verdict**: G/H propagation works by construction. Box stability requires additional work -- either constraining the oracle to produce modal-equivalent witnesses, or adding `modal_fix(M_0)` to the seed (similar to what `dd_bfmcs` already does at RootScopedChain.lean:1030-1041).

### 4. "Lift then Tile" vs "Tile then Lift"

**Approach A (Lift then Tile)**: Lift each HintikkaPoint to a BXPoint (via `WitnessedHintikka`), getting a finite chain of BXPoints `v_0, ..., v_k`. Then tile Z with copies: `chain(t) = v_{t mod (k+1)}`.

- **Advantage**: Each `v_i` is already a full MCS, so the periodic chain is immediately an FMCS (each point is MCS).
- **Problem**: `bx_le v_i v_{i+1}` (i.e., `g_content(v_i) subset v_{i+1}`) must hold for all consecutive pairs, including the **wraparound** `v_k -> v_0`. The hintikka_step guarantees `G(chi) in h_i -> chi in h_{i+1}`, but not `G(chi) in v_i -> chi in v_{i+1}` (because `v_i` may contain G-formulas outside Sigma). Furthermore, the wraparound `v_k -> v_0` has no hintikka_step guarantee at all.

**Approach B (Tile then Lift)**: Tile the HintikkaPoint chain into a Z-indexed HintikkaPoint sequence. Then lift the entire infinite sequence to BXPoints.

- **Advantage**: The Sigma-restricted propagation (`hintikka_step`) is uniform across the periodic extension. Lifting can be done with a SINGLE Lindenbaum extension per period, since the finite Sigma determines only finitely many distinct HintikkaPoints.
- **Problem**: Lifting an infinite sequence of HintikkaPoints to BXPoints requires an infinite sequence of Lindenbaum extensions, each dependent on the previous one. This is exactly the current `fwd_chain_of_sigma` architecture, inheriting its control problems.

**Recommendation**: **Neither approach in pure form.** Instead, use a **hybrid**: construct the finite QuasimodelChain (sorry-free), lift it to a finite BXPoint chain with modal-fix constraints (new, ~100 lines), then tile periodically. The modal-fix constraint is key: include `{box(phi) | box(phi) in M_0} union {neg(box(phi)) | box(phi) not in M_0}` in every Lindenbaum seed, ensuring all backing BXPoints share the same box content as `M_0`. This is already done in `dd_bfmcs.modal_forward` (RootScopedChain.lean:1030-1041).

### 5. The BFMCS Family Question

Currently `dd_bfmcs` creates ONE family per modal-equivalence class: `shifted_dd_fmcs N h_N sigma_list s` for each MCS `N` modal-equivalent to `M_0` and each shift `s`. This gives a set of families parametrized by `(N, s)`.

For the quasimodel approach, the family structure would be similar but simpler:

- **One family per (modal-equiv MCS N, shift s)**: `qm_fmcs N h_N sigma_list s`
- The chain within each family is the **periodic extension** of N's QuasimodelChain
- All families share the same period length (determined by `|SubformulaClosure root|`)
- Box stability follows from the modal-fix constraint in the lifting step

The key difference: the current `dd_chain` builds a DIFFERENT chain for each `N` using Lindenbaum extensions (inheriting non-determinism). The quasimodel chain builds ONE canonical chain pattern from the Sigma-closure, then instantiates it per `N`. Since the Sigma-closure is finite and the QuasimodelChain is finite, the whole construction is combinatorially bounded.

**Can we have ONE family for the whole quasimodel chain?** No. The BFMCS needs multiple families for the Box truth lemma: `Box(phi) not in M_0` requires a witness family where `phi` fails. This is handled by `bx_modal_witness` (Frame.lean), and the multi-family structure is essential. One family per modal-equivalence class is the minimum.

### 6. Completeness of the Approach

Does a quasimodel-derived BFMCS satisfy ALL properties needed by `dd_countermodel`?

**Root formula's negation at time 0**: YES. The initial HintikkaPoint `h_0` is the Sigma-signature of `M_0` (where `neg(phi) in M_0`). Since `neg(phi) in SubformulaClosure phi in Sigma`, we get `neg(phi) in h_0.formulas`. After lifting to BXPoint `v_0` with seed including `h_0.formulas`, `neg(phi) in v_0.formulas`. With the shifted family at `s=0`, `fam.mcs(0) = v_0`, preserving the root negation.

**Box stability**: YES, if the modal-fix constraint is applied during lifting (see Finding 4). All backing BXPoints share the same box content as `M_0`, so `box_stable_dd_chain` holds trivially.

**All families agree on modal content**: YES, by the same modal-fix constraint. This is identical to how `dd_bfmcs.modal_forward` and `dd_bfmcs.modal_backward` currently work.

**Restricted temporal coherence (restricted_tc)**: YES, by construction. The periodic chain resolves every Until/Since defect within one period (bounded by `|Sigma|` steps, from `hintikka_step_target_decrease`). For any `F(phi)` in `chain(t)` with `phi in deferralClosure(root)`, the periodic structure guarantees `phi in chain(t + period)` at worst, since the defect-discharge chain within one period resolves all defects in `SubformulaClosure(root) superset deferralClosure(root)`.

**Restricted backward Until/Since coherence (restricted_buc)**: This requires: if there exists `s >= t` with `psi in fam.mcs(s)` and `phi in fam.mcs(r)` for all `t <= r < s`, then `phi U psi in fam.mcs(t)`. This is a **semantic** property that does NOT follow directly from the periodic structure. It requires that the MCS at time `t` contains `phi U psi` whenever the Until witness pattern holds on the chain. This is provable by the **BX axioms at the MCS level**: specifically BX8 (reflexive intro) when `s = t`, and BX5+BX6 (self-accumulation + absorption) for the inductive case. The proof would use `refl_intro_until_mcs` (Construction.lean:157-162) and the guard propagation from `hintikka_chain_guard_step` (Construction.lean:842-848).

**Restricted forward Until/Since coherence (restricted_fuc)**: Requires: if `phi U psi in fam.mcs(t)`, then there exists `s >= t` with `psi in fam.mcs(s)` and the guard holds. This follows from the QuasimodelChain's defect-discharge property: the chain resolves the Until defect within `|Sigma|` steps, and the periodic extension ensures the resolution pattern repeats.

### 7. Incremental vs Revolutionary

**Can we use quasimodel chains to close the 3 sorries WITHOUT replacing dd_bfmcs?**

Partially. The quasimodel chain infrastructure provides:

1. **For restricted_tc**: The `hintikka_chain_exists` theorem (Construction.lean:594) gives a finite chain resolving any Until defect. If we can show that the existing `dd_chain` visits every HintikkaPoint that the quasimodel chain visits, then restricted_tc follows. But this requires proving the `preserving_fwd_step` chain explores the same state space as the quasimodel chain -- which is exactly the control problem we cannot solve.

2. **For restricted_buc**: The backward coherence is a property of MCS membership, provable from BX axioms. The quasimodel infrastructure provides the guard propagation lemmas but doesn't directly help with the MCS-level argument. However, the `enriched_seed_consistent_until` lemma (Realization.lean:195-245) and the backward seed construction could be adapted.

3. **For restricted_fuc**: Similar to restricted_tc -- needs the chain to resolve Until defects.

**Verdict**: An incremental approach using quasimodel chains as lemma-level evidence within the existing `dd_chain` structure is BLOCKED by Dead End #25 (BXPoint-to-Int bridging gap) and Dead End #30 (per-formula witness must be in same-family chain). The quasimodel produces abstract BXPoint chains that are NOT the same as the `dd_chain` MCS sequence.

**A revolutionary approach (replacing dd_bfmcs) is required** to fully benefit from the quasimodel infrastructure.

### 8. Long-term Project Health

Reading `specs/ROAD_MAP.md`, the quasimodel approach affects other pending tasks as follows:

**Task 95 (#print axioms audit)**: Unaffected. The quasimodel approach uses the same axioms (BX1-BX12, propext, Classical.choice, Quot.sound). No new axioms needed.

**Task 68 (dense completeness)**: The quasimodel approach works over ANY linear order, not just Int. If the periodic extension is parameterized by `D : Type` with `[LinearOrder D]`, the same construction could serve dense completeness over Q. This makes task 68 EASIER.

**Task 82 (FMP)**: The quasimodel approach is closely related to the FMP (both use finite Hintikka sets). The SubformulaClosure and HintikkaPoint infrastructure is shared. This makes future FMP work EASIER.

**Future extensions**: The quasimodel approach aligns with the standard literature, making the proof more recognizable and easier to extend to richer logics (CTL*, PDL, etc.). The current `preserving_fwd_step` approach is non-standard and harder to generalize.

**LOC estimate**: ~400-600 new lines for the periodic extension and coherence proofs. Much of the infrastructure is already sorry-free (QuasimodelChain, HintikkaRawChain, WitnessedHintikka, ChainWitnessed, hintikka_chain_exists, etc.). The new code would be:
- Periodic tiling definition: ~50 lines
- Modal-fix constrained lifting: ~100 lines
- FMCS construction from periodic chain: ~80 lines
- restricted_tc proof: ~60 lines (follows from period-bounded defect discharge)
- restricted_buc proof: ~80 lines (BX axiom argument at MCS level)
- restricted_fuc proof: ~60 lines (delegates to QuasimodelChain witness)
- BFMCS assembly and dd_countermodel rewiring: ~70 lines

---

## Recommended Approach

**Replace `dd_bfmcs` with a quasimodel-derived BFMCS.** The specific architecture:

**Phase 1: Periodic FMCS (NEW, ~150 lines)**
- Define `periodic_fmcs`: given a finite chain of BXPoints `v_0, ..., v_k` (all modal-equivalent to `M_0`), construct an FMCS by periodic extension `fam.mcs(t) = v_{t mod (k+1)}`
- Prove FMCS properties: `is_mcs` (each `v_i` is MCS), `forward_G` (from hintikka_step G-propagation + lifting), `backward_H` (from hintikka_step H-backward + lifting)
- The wraparound `v_k -> v_0` requires: `g_content(v_k) subset v_0`. This holds if the chain is a CYCLE (last point steps back to first). Alternatively, concatenate the chain with its reverse to get a palindromic cycle.

**Phase 2: Modal-Fix Lifting (NEW, ~100 lines)**
- Given QuasimodelChain `h_0, ..., h_k` with `ChainWitnessed`, lift each `h_i` to a BXPoint `v_i` using seed `h_i.formulas union modal_fix(M_0) union g_content(v_{i-1})` (for i > 0)
- Prove modal equivalence: all `v_i` have the same box content as `M_0`
- Prove `bx_le v_i v_{i+1}`: follows from seed including `g_content(v_i)`

**Phase 3: Coherence Proofs (~200 lines)**
- `restricted_tc`: F(phi) in chain(t) implies phi in chain(t + period). The QuasimodelChain resolves each defect within one period. The periodic extension replicates this resolution.
- `restricted_buc`: Until backward coherence from BX8 (refl_intro_until_mcs) + BX5 (self_accum_mcs) + induction on the witness distance `s - t`.
- `restricted_fuc`: Until forward coherence delegates to the QuasimodelChain's defect-discharge property.

**Phase 4: BFMCS Assembly and Integration (~50 lines)**
- Define `qm_bfmcs`: families = `{ periodic_fmcs(v_chain_N, s) | N modal-equiv M_0, s in Int }`
- Rewire `dd_countermodel` to use `qm_bfmcs`
- Verify `bx_completeness` builds with 0 sorries

---

## Evidence/Examples

**Sorry-free infrastructure available** (2,289 lines across 9 files):
- `SubformulaClosure.lean`: 114 lines, finite Sigma
- `HintikkaPoint.lean`: 166 lines, sigma_signature projection
- `Construction.lean`: 887 lines, `hintikka_chain_exists` (sorry-free well-founded recursion)
- `Realization.lean`: 444 lines, enriched seed consistency, realization lifting
- `LocusControl.lean`: 47 lines, delegation layer
- `SigmaOrdering.lean`: 179 lines, sigma-restricted ordering
- `DefectChain.lean`: 137 lines, defect-discharge chain
- `CanonicalChain.lean`: 157 lines, MCS-level BX axiom lemmas
- `OrderedSeedConsistency.lean`: 255 lines, ordered seed consistency

**The wraparound problem**: The critical technical challenge is ensuring `g_content(v_k) subset v_0` for the periodic chain to satisfy FMCS forward_G at the wraparound. Three solutions:
1. **Palindromic cycle**: Use chain `v_0, v_1, ..., v_k, v_{k-1}, ..., v_1, v_0` (period 2k). H-backward gives the reverse direction for free.
2. **G-closed QuasimodelChain**: Construct the chain so that `G(chi) in h_k -> chi in h_0` (strong closure). This is NOT guaranteed by the current `hintikka_step` definition.
3. **Fresh Lindenbaum at wraparound**: At the wraparound, construct a new BXPoint from seed `h_0.formulas union g_content(v_k) union modal_fix(M_0)`. This is consistent if `g_content(v_k) subset M_0.formulas` (which holds when `v_k` is `bx_le`-below `M_0`).

**Evidence for palindromic cycle (option 1)**: The `hintikka_step` H-backward clause (Construction.lean:49) gives `H(chi) in h_{i+1} -> chi in h_i`. For the reverse chain `v_k, v_{k-1}, ..., v_0`, H-backward becomes the forward direction. The palindromic construction thus has both G-forward and H-backward at every step, with no wraparound problem (the chain endpoint `v_0` appears at both ends).

---

## Confidence Level

| Assessment | Confidence |
|-----------|------------|
| Quasimodel-derived BFMCS is the correct long-term architecture | **HIGH (90%)** |
| G/H propagation works for periodic extension | **HIGH (90%)** |
| Box stability achievable via modal-fix constraint | **HIGH (85%)** |
| restricted_tc provable from periodic defect-discharge | **HIGH (85%)** |
| restricted_buc provable from BX axioms at MCS level | **MEDIUM-HIGH (75%)** |
| restricted_fuc provable from QuasimodelChain witness | **HIGH (85%)** |
| Wraparound solvable via palindromic cycle | **MEDIUM (65%)** |
| Total LOC estimate 400-600 is realistic | **MEDIUM (70%)** |
| Approach makes future tasks (68, 82) easier | **HIGH (85%)** |
| Current plan v42 can close all 3 sorries without architecture change | **LOW (15%)** |

---

## Summary

The current `dd_bfmcs` architecture faces an irreducible control problem: `Classical.choice` in Lindenbaum extensions cannot be constrained to resolve specific eventualities while preserving all F-obligations. After 43 prior rounds confirming this obstruction, the recommended path is to **replace `dd_bfmcs` with a quasimodel-derived BFMCS** that uses the existing sorry-free `QuasimodelChain` infrastructure (2,289 lines). The key mathematical content is periodic extension of finite Hintikka chains into Int-indexed FMCS families, with coherence following by construction from the defect-discharge property. The wraparound at the period boundary is the main technical challenge, addressable via palindromic cycling. This approach aligns with the standard literature (Goldblatt, Reynolds, Burgess), makes the proof more recognizable, and simplifies future tasks (dense completeness, FMP).
