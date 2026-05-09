# Implementation Plan: Case-Split Completeness (Dense/Discrete)

- **Task**: 117 - Remove Cantor isomorphism and build countermodel on limit domain
- **Status**: [NOT STARTED]
- **Effort**: 28 hours
- **Dependencies**: 107 (completed)
- **Research Inputs**: reports/04_extension-blocker-research.md, reports/05_dense-case-research.md, reports/05_discrete-case-research.md, reports/05_axiom-soundness-research.md, reports/05_critic-review.md, reports/06_mf-tf-correspondence.md, reports/06_minimal-structure.md
- **Artifacts**: plans/04_case-split-completeness.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

The original plan's natural inclusion approach (Phase 4) was proved mathematically impossible: extending `limit_f` to non-domain rationals while preserving `forward_G` under strict G semantics is blocked (report 04). This revised plan replaces that approach with a case-split completeness strategy. The key insight: every ordered abelian group is either uniformly dense or uniformly discrete (translation invariance of adjacency). Four new axioms encoding this uniformity are added to BX (all valid over AddCommGroups). The completeness proof case-splits on the root MCS: if `F'T in A0`, density propagates to all domain points via propagation axioms, enabling Cantor iso restoration from Boneyard; if `U(T,bot) in A0`, discreteness propagates similarly, enabling Z-isomorphism via Mathlib. Both cases produce sorry-free countermodels. Phases 1-3 of the original plan are COMPLETED and not re-planned.

### Research Integration

Integrates findings from 7 reports across 2 research rounds:
- **Report 04** (extension blocker): Proves natural inclusion impossible; all 5 approaches (A-E) fail due to strict G preventing `forward_G` at non-domain rationals.
- **Report 05 (dense)**: Confirms `limit_satisfies_c4` with xi=bot, eta=top gives density; F'T propagation works via temp_4 + `limit_forward_G`/`limit_backward_H`; Cantor iso restoration is a 3-line proof once `DenselyOrdered` is established.
- **Report 05 (discrete)**: Mathlib's `orderIsoIntOfLinearSuccPredArch` gives Z-isomorphism; all three coherence properties transport directly from chronicle when domain = all of D.
- **Report 05 (axiom soundness)**: `U(T,bot) <-> S(T,bot)` valid over all AddCommGroups via translation invariance; propagation axioms valid by same argument. No circularity.
- **Report 05 (critic)**: F'T propagation resolved by including `{F'T, G(F'T), H(F'T)}` in root MCS extension; Archimedean is not blocking because we CHOOSE D (Rat or Int), not assume properties of arbitrary D; `truth_at bot = False` definitionally.
- **Reports 06**: AddCommGroup is minimal for MF/TF soundness (Holder's theorem); ShiftClosed is necessary and sufficient.

### Prior Plan Reference

Prior plan `03_natural-inclusion-refactor.md` had 5 phases. Phases 1-3 completed successfully: density code archived to Boneyard (Phase 1), `.density` enum removed from CounterexampleElimination.lean (Phase 2), density infrastructure removed from ChronicleConstruction.lean (Phase 3). Phase 4 (natural inclusion) was attempted and blocked -- the forward_G extension problem is mathematically impossible, not merely difficult. Phase 5 (verification) was never reached. Effort estimates from the prior plan were accurate for Phases 1-3 (3h estimated, completed on time). The Phase 4 estimate (5.5h) was insufficient even in theory given the fundamental impossibility.

## Goals and Non-Goals

**Goals**:
- Add four uniformity axioms to `Axiom` inductive (valid over all AddCommGroups)
- Prove soundness of all four new axioms
- Build sorry-free `dd_countermodel_chronicle` for the dense case (D = Rat via Cantor iso)
- Build sorry-free `dd_countermodel_chronicle_discrete` for the discrete case (D = Int via Z-iso)
- Restructure `bx_completeness` with a case split on `F'T vs U(T,bot)` in the root MCS
- Eliminate `sorryAx` from `#print axioms bx_completeness`

**Non-Goals**:
- Modifying `valid` to add `[Archimedean D]` (not needed: we choose D, not assume it)
- Changing `truth_at`, `TaskFrame`, `ShiftClosed`, or parametric infrastructure
- Proving completeness for arbitrary (non-Archimedean) D separately
- Modifying the chronicle construction (`ChronicleConstruction.lean`)
- Re-doing Phases 1-3 of the original plan (already completed)

## Risks and Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Axiom match exhaustiveness: adding 4 constructors breaks downstream match expressions | M | H | Phase 1 includes audit of all match sites; all current matches use wildcard `| _ =>` patterns, confirmed by `frameClass`/`isBase`/etc. |
| Cantor iso archived code incomplete (stubs for shifted/rooted/bfmcs) | H | M | Phase 4 reconstructs from the complete working version that existed pre-archival, using archived `cantor_fmcs` as template and mirroring the discrete case structure |
| SuccOrder/PredOrder instances on LimitDomSubtype are hard | M | L | C5 gives immediate successor from `U(T,bot)` in f(x); the empty guard condition directly yields adjacency. Research report 05 (discrete) provides complete proof sketch |
| IsSuccArchimedean on LimitDomSubtype requires delicate argument | M | M | Use embedding into Rat (Archimedean): finite successor steps increase Rat value monotonically, bounded above by target, so must reach it |
| Backward Until coherence (restricted_buc) in discrete case | M | L | Contrapositive via `limit_satisfies_c4`: if neg(phi U psi) in f(n), C4 produces guard violation z, contradicting the guard hypothesis. Proved in report 05 |
| Case-split consistency: `{neg(phi), F'T, G(F'T), H(F'T)}` might be inconsistent | L | L | Handled by the discrete case: if dense extension is inconsistent, the discrete extension `{neg(phi), U(T,bot), G(U(T,bot)), H(U(T,bot))}` must be consistent (propositional tautology: either `F'T` or `U(T,bot)` is in any MCS) |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3, 4 | 2 |
| 4 | 5, 6 | 3, 4 |
| 5 | 7 | 5, 6 |
| 6 | 8 | 7 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Add Uniformity Axioms to BX [NOT STARTED]

**Goal**: Add four new axiom constructors to the `Axiom` inductive type encoding the uniformity of discreteness in ordered abelian groups.

**Tasks**:
- [ ] Add `discrete_symm_fwd` constructor: `Axiom ((Formula.untl (Formula.bot.imp Formula.bot) Formula.bot).imp (Formula.snce (Formula.bot.imp Formula.bot) Formula.bot))` (U(T,bot) -> S(T,bot))
- [ ] Add `discrete_symm_bwd` constructor: `Axiom ((Formula.snce (Formula.bot.imp Formula.bot) Formula.bot).imp (Formula.untl (Formula.bot.imp Formula.bot) Formula.bot))` (S(T,bot) -> U(T,bot))
- [ ] Add `discrete_propagate_fwd` constructor: `Axiom ((Formula.untl (Formula.bot.imp Formula.bot) Formula.bot).imp (Formula.all_future (Formula.untl (Formula.bot.imp Formula.bot) Formula.bot)))` (U(T,bot) -> G(U(T,bot)))
- [ ] Add `discrete_propagate_bwd` constructor: `Axiom ((Formula.untl (Formula.bot.imp Formula.bot) Formula.bot).imp (Formula.all_past (Formula.untl (Formula.bot.imp Formula.bot) Formula.bot)))` (U(T,bot) -> H(U(T,bot)))
- [ ] Update `Axiom.frameClass` wildcard match -- verify no change needed (current `| _ => .Base`)
- [ ] Update `Axiom.isBase`, `isDenseCompatible`, `isDiscreteCompatible` -- verify wildcards handle new constructors
- [ ] Update axiom docstring count (currently says "41 constructors", will be 45)
- [ ] Audit all other match expressions on `Axiom` across the codebase (run `grep -rn "cases.*Axiom\|match.*Axiom\|fun.*Axiom" Theories/`)
- [ ] Run `lake build Bimodal.ProofSystem.Axioms` to verify

**Timing**: 1.5 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/ProofSystem/Axioms.lean` -- add 4 constructors at end of inductive, update docstring

**Verification**:
- `lake build Bimodal.ProofSystem.Axioms` succeeds
- All downstream match expressions still compile (full `lake build` may fail until Phase 2)

---

### Phase 2: Prove Axiom Soundness [NOT STARTED]

**Goal**: Prove all four new axioms are valid over all `AddCommGroup D` with `IsOrderedAddMonoid D`.

**Tasks**:
- [ ] Prove `discrete_symm_fwd_valid`: If `U(T,bot)` at t, then (t,s) is empty for some s > t, so gap d = s-t > 0. Then (t-d, t) is empty by translation invariance (`Set.image_const_add_Ioo` or direct `add_lt_add_right`). So `S(T,bot)` at t.
- [ ] Prove `discrete_symm_bwd_valid`: Mirror of fwd. If `S(T,bot)` at t, then (r,t) is empty for some r < t, gap d = t-r > 0. Then (t, t+d) is empty by translation. So `U(T,bot)` at t.
- [ ] Prove `discrete_propagate_fwd_valid`: If `U(T,bot)` at t, gap d > 0 exists with (t, t+d) empty. For any s > t, (s, s+d) is empty by translation (`y -> y + (s-t)` maps (t,t+d) to (s,s+d)). So `U(T,bot)` at s. Therefore `G(U(T,bot))` at t.
- [ ] Prove `discrete_propagate_bwd_valid`: If `U(T,bot)` at t, gap d exists. For any s < t, (s, s+d) is empty by translation. So `U(T,bot)` at s. Therefore `H(U(T,bot))` at t.
- [ ] Add all four cases to `axiom_base_valid` match (Soundness.lean, line ~862)
- [ ] Add corresponding cases to `axiom_valid_dense` match (Soundness.lean, line ~908)
- [ ] Add corresponding cases to `axiom_valid_discrete` match (Soundness.lean, line ~954)
- [ ] Run `lake build Bimodal.Metalogic.Soundness` to verify

**Timing**: 3 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/Soundness.lean` -- add 4 validity theorems (~40 lines each), add 4 cases to each of 3 match expressions

**Verification**:
- `lake build Bimodal.Metalogic.Soundness` succeeds
- Full `lake build` succeeds (no downstream breakage from new axioms)

---

### Phase 3: Dense Case -- Density from F'T and Cantor Iso [NOT STARTED]

**Goal**: Given F'T in all domain MCS's, prove `DenselyOrdered (LimitDomSubtype A h_mcs)` and restore the Cantor isomorphism from Boneyard.

**Tasks**:

*Density proof (~30 lines)*:
- [ ] Define helper: `top_formula := Formula.bot.imp Formula.bot`
- [ ] Define helper: `next_top := Formula.untl top_formula Formula.bot` (= U(T,bot))
- [ ] Define helper: `F'T := next_top.neg` (= neg(U(T,bot)))
- [ ] Prove `limit_dom_dense_from_F'T`: given `forall x in limit_dom, F'T in limit_f(x)`, for any x < y in limit_dom, exists z in limit_dom with x < z < y. Proof: instantiate `limit_satisfies_c4` at line 741 with xi=bot, eta=top_formula. Hypothesis `h_neg_until` requires `(Formula.untl top_formula Formula.bot).neg in limit_f(x)` which is exactly F'T. Hypothesis `h_event` requires `top_formula in limit_f(y)` which follows from `theorem_in_mcs` + `identity`. Conclusion gives z with `Formula.bot.neg in limit_f(z)` which is trivially satisfied.
- [ ] Prove `limitDomSubtype_denselyOrdered_from_F'T`: instance wrapping `limit_dom_dense_from_F'T`, mirroring archived code at `Boneyard/DenseChronicle/DenseLimitDomain.lean:82-88` (3-line proof).

*Cantor iso restoration (~20 lines)*:
- [ ] Add import `Mathlib.Order.CountableDenseLinearOrder` to ChronicleToCountermodel.lean
- [ ] Define `cantor_iso` using `Classical.choice (Order.iso_of_countable_dense ...)` -- requires `DenselyOrdered`, `Countable`, `NoMinOrder`, `NoMaxOrder`, `Nonempty` (all available)
- [ ] Define `cantor_f : Rat -> Set Formula` via `limit_f (cantor_iso.symm q).val`
- [ ] Prove `cantor_zero`, `cantor_f_at_zero`, `cantor_f_is_mcs` (mirror archived code lines 58-72)

*FMCS construction (~30 lines)*:
- [ ] Define `cantor_fmcs : FMCS Rat` with `forward_G` and `backward_H` from `limit_forward_G`/`limit_backward_H` transported via `cantor_iso.symm.strictMono` (mirror archived code lines 74-96)

- [ ] Run `lake build ...ChronicleToCountermodel` to verify (partial -- BFMCS and countermodel in Phase 5)

**Timing**: 3 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- add density proof, Cantor iso, cantor_f, cantor_fmcs

**Verification**:
- `lake build Bimodal.Metalogic.BXCanonical.Chronicle.ChronicleToCountermodel` succeeds (with BFMCS/countermodel deferred to Phase 5)

---

### Phase 4: Discrete Case -- Z-Isomorphism from U(T,bot) [NOT STARTED]

**Goal**: Given `U(T,bot)` in all domain MCS's, prove `SuccOrder`, `PredOrder`, `IsSuccArchimedean` on `LimitDomSubtype`, obtain Z-isomorphism, and define `discrete_fmcs : FMCS Int`.

**Tasks**:

*SuccOrder instance (~40 lines)*:
- [ ] Prove `limit_dom_has_succ`: given `U(T,bot) in limit_f(x)` for x in limit_dom, use `limit_satisfies_c5_strong` to get witness y with x < y and bot on guard (t,s). Since bot is never in any MCS (consistency), no domain point exists between x and y. So y is the immediate successor.
- [ ] Define `limitDomSubtype_succOrder`: `SuccOrder (LimitDomSubtype A h_mcs)` using `limit_dom_has_succ`. Define `succ x` as the y from the C5 witness. Prove `succ_le_of_lt` and `lt_succ_of_lt` from the adjacency property.

*PredOrder instance (~40 lines)*:
- [ ] Prove `limit_dom_has_pred`: mirror using `S(T,bot) in limit_f(x)` (derived from `U(T,bot)` via the `discrete_symm_fwd` axiom in every MCS) and `limit_satisfies_c5'_strong`.
- [ ] Define `limitDomSubtype_predOrder`: `PredOrder (LimitDomSubtype A h_mcs)` mirroring SuccOrder.

*IsSuccArchimedean instance (~30 lines)*:
- [ ] Prove `limitDomSubtype_isSuccArchimedean`: For a <= b in LimitDomSubtype, show succ^n(a) >= b for some n. Use the Rat embedding: a.val < b.val in Rat. Each `succ` step strictly increases the Rat value (a.val < succ(a).val). The sequence a.val, succ(a).val, succ^2(a).val, ... is strictly increasing in Rat and bounded above by b.val. Since Rat is Archimedean, finitely many steps suffice. Alternative: use `Fintype.card` of `Set.Icc a b` in the LimitDomSubtype order (finite since discrete + bounded).

*Z-isomorphism (~10 lines)*:
- [ ] Define `discrete_iso`: `LimitDomSubtype A h_mcs ≃o Int` via `orderIsoIntOfLinearSuccPredArch`. Verify all prerequisites: `LinearOrder` (inherited), `SuccOrder`, `PredOrder`, `IsSuccArchimedean`, `NoMaxOrder` (existing), `NoMinOrder` (existing), `Nonempty` (existing).

*FMCS on Int (~30 lines)*:
- [ ] Define `discrete_f : Int -> Set Formula := fun n => limit_f (discrete_iso.symm n).val`
- [ ] Prove `discrete_f_is_mcs`, `discrete_f_at_zero`
- [ ] Define `discrete_fmcs : FMCS Int` with `forward_G`/`backward_H` from `limit_forward_G`/`limit_backward_H` transported via `discrete_iso.symm.strictMono` (same pattern as `cantor_fmcs`)

- [ ] Run `lake build ...ChronicleToCountermodel` to verify

**Timing**: 4 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- add SuccOrder, PredOrder, IsSuccArchimedean instances, Z-iso, discrete_fmcs
- May need to add import `Mathlib.Order.SuccPred.LinearLocallyFinite` (check if already transitive via existing imports)

**Verification**:
- `lake build Bimodal.Metalogic.BXCanonical.Chronicle.ChronicleToCountermodel` succeeds

---

### Phase 5: Dense Case -- BFMCS and Countermodel [NOT STARTED]

**Goal**: Build `cantor_bfmcs : BFMCS Rat` with all three coherence properties, then construct `dd_countermodel_chronicle` for the dense case.

**Tasks**:

*Shifted/rooted FMCS (~40 lines)*:
- [ ] Define `shifted_cantor_fmcs s := { mcs := fun t => cantor_fmcs.mcs (t + s), ... }`
- [ ] Define `rooted_cantor_fmcs N h_N s` for box-equivalent N, following the BFMCS pattern from `RootScopedChain.lean` or `CanonicalModel.lean`
- [ ] Prove `rooted_cantor_fmcs_at_s`: `rooted_cantor_fmcs.mcs t = cantor_fmcs.mcs (t + s)`

*Box stability (~30 lines)*:
- [ ] Prove `box_stable_in_rooted_cantor_fmcs`: Box(phi) in rooted_cantor_fmcs.mcs t implies phi in rooted_cantor_fmcs'.mcs t for any box-equivalent pair. Uses MCS properties of cantor_f and Box-closure.

*BFMCS construction (~20 lines)*:
- [ ] Define `cantor_bfmcs : BFMCS Rat` with `modal_forward`/`modal_backward` using box stability and shifted families.

*Restricted temporal coherence (~30 lines)*:
- [ ] Prove `cantor_bfmcs_restricted_tc`: F(phi) in cantor_f(t) implies exists s > t with phi in cantor_f(s). Transport from `limit_F_resolution`: F(phi) in limit_f(cantor_iso.symm(t)) gives y in limit_dom with phi in limit_f(y). Set s = cantor_iso(y). Mirror for P direction.

*Restricted backward Until/Since coherence (~30 lines)*:
- [ ] Prove `cantor_bfmcs_restricted_buc`: Given phi in cantor_f(s) and psi in cantor_f(r) for all t < r < s, prove (phi U psi) in cantor_f(t). Use contrapositive via `limit_satisfies_c4`: if neg(phi U psi) in f(t), C4 produces z between t and s with psi.neg in f(z), contradicting psi in f(z) (from guard). Transport through cantor_iso.

*Restricted forward Until/Since coherence (~30 lines)*:
- [ ] Prove `cantor_bfmcs_restricted_fuc`: (phi U psi) in cantor_f(t) implies exists s > t with phi in cantor_f(s) and psi on guard. Transport from `limit_satisfies_c5_strong`: exists y in limit_dom with phi in limit_f(y) and psi in limit_g. Since cantor_iso is a bijection limit_dom <-> Rat, limit_g covers ALL rationals between t and cantor_iso(y).

*Countermodel (~20 lines)*:
- [ ] Define `dd_countermodel_chronicle_dense`: uses `cantor_bfmcs`, `fully_restricted_parametric_representation_from_neg_membership`, and the fact that `cantor_f_at_zero = A` to produce the existential countermodel.

- [ ] Run `lake build ...ChronicleToCountermodel` to verify

**Timing**: 5 hours

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- add shifted/rooted FMCS, box stability, BFMCS, coherence proofs, countermodel

**Verification**:
- `lake build Bimodal.Metalogic.BXCanonical.Chronicle.ChronicleToCountermodel` succeeds
- `dd_countermodel_chronicle_dense` compiles without sorry

---

### Phase 6: Discrete Case -- BFMCS and Countermodel [NOT STARTED]

**Goal**: Build `discrete_bfmcs : BFMCS Int` with all three coherence properties, then construct `dd_countermodel_chronicle_discrete` for the discrete case.

**Tasks**:

*Shifted/rooted FMCS (~40 lines)*:
- [ ] Define `shifted_discrete_fmcs s := { mcs := fun t => discrete_fmcs.mcs (t + s), ... }`
- [ ] Define `rooted_discrete_fmcs N h_N s` mirroring the dense case pattern
- [ ] Prove `rooted_discrete_fmcs_at_s`

*Box stability (~30 lines)*:
- [ ] Prove `box_stable_in_rooted_discrete_fmcs` -- identical structure to dense case

*BFMCS construction (~20 lines)*:
- [ ] Define `discrete_bfmcs : BFMCS Int` with `modal_forward`/`modal_backward`

*Restricted temporal coherence (~30 lines)*:
- [ ] Prove `discrete_bfmcs_restricted_tc`: Transport from `limit_F_resolution` via `discrete_iso`. Since discrete_iso bijects limit_dom <-> Int, F-resolution gives a domain witness, which maps to an Int witness.

*Restricted backward Until/Since coherence (~30 lines)*:
- [ ] Prove `discrete_bfmcs_restricted_buc`: Contrapositive via `limit_satisfies_c4` transported through `discrete_iso`. Key insight (report 05 discrete, section 4.2): domain = all of Z via iso, so the guard over D = Int equals the domain-point guard. C4 produces a contradiction point.

*Restricted forward Until/Since coherence (~30 lines)*:
- [ ] Prove `discrete_bfmcs_restricted_fuc`: Transport from `limit_satisfies_c5_strong` via `discrete_iso`. Key insight: since domain IS all of Int (via iso), `limit_g(x,y)` covers all integers between the two points, which is exactly the D-guard.

*Countermodel (~20 lines)*:
- [ ] Define `dd_countermodel_chronicle_discrete`: uses `discrete_bfmcs`, `fully_restricted_parametric_representation_from_neg_membership`, and `discrete_f_at_zero = A`.

- [ ] Run `lake build ...ChronicleToCountermodel` to verify

**Timing**: 5 hours

**Depends on**: 4

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- add discrete BFMCS, coherence proofs, countermodel

**Verification**:
- `lake build Bimodal.Metalogic.BXCanonical.Chronicle.ChronicleToCountermodel` succeeds
- `dd_countermodel_chronicle_discrete` compiles without sorry

---

### Phase 7: Case-Split Completeness Restructuring [NOT STARTED]

**Goal**: Restructure `bx_completeness` in Completeness.lean to use a case split on `F'T vs U(T,bot)` in the root MCS, dispatching to the dense or discrete countermodel.

**Tasks**:

*F'T propagation lemma (~40 lines)*:
- [ ] Prove `F'T_propagates_to_all_domain_points`: Given MCS A0 with `F'T in A0` and `G(F'T) in A0` and `H(F'T) in A0`, show `F'T in limit_f(x)` for all x in limit_dom. Proof:
  - x = 0: `F'T in A0 = limit_f(0)` directly
  - x > 0: `G(F'T) in A0`. By temp_4, `G(G(F'T)) in A0`. By `limit_forward_G`, `G(F'T) in limit_f(x)`. By `limit_forward_G` again, `F'T in limit_f(y)` for all y > x. But we need `F'T in limit_f(x)` itself. Use: `G(F'T) in limit_f(0)` and `0 < x` gives `F'T in limit_f(x)` directly by `limit_forward_G`.
  - x < 0: `H(F'T) in A0`. By past temp_4 (derivable via duality), `H(H(F'T)) in A0`. By `limit_backward_H`, `H(F'T) in limit_f(x)`. By `limit_backward_H`, `F'T in limit_f(y)` for y < x. For F'T at x itself: `H(F'T) in limit_f(0)` and `x < 0` gives `F'T in limit_f(x)` by `limit_backward_H`.

*U(T,bot) propagation lemma (~40 lines)*:
- [ ] Prove `next_top_propagates_to_all_domain_points`: Given MCS A0 with `U(T,bot) in A0`, show `U(T,bot) in limit_f(x)` for all x in limit_dom. Proof:
  - From `U(T,bot) in A0` and axiom `discrete_propagate_fwd` (U(T,bot) -> G(U(T,bot))): `G(U(T,bot)) in A0`.
  - From `discrete_propagate_bwd`: `H(U(T,bot)) in A0`.
  - x > 0: `G(U(T,bot)) in A0` + `limit_forward_G` gives `U(T,bot) in limit_f(x)`.
  - x < 0: `H(U(T,bot)) in A0` + `limit_backward_H` gives `U(T,bot) in limit_f(x)`.
  - x = 0: direct.
  - Additionally derive `S(T,bot) in limit_f(x)` for all x via `discrete_symm_fwd` axiom in each MCS.

*Case-split consistency lemma (~30 lines)*:
- [ ] Prove `dense_or_discrete_consistent`: Given `SetConsistent ({neg(phi)} : Set Formula)`, either `SetConsistent ({neg(phi), F'T, G(F'T), H(F'T)})` or `SetConsistent ({neg(phi), U(T,bot)})`. Proof: In any MCS extending `{neg(phi)}`, exactly one of `F'T` or `U(T,bot)` is present (they are negations of each other: `F'T = neg(U(T,bot))`). If `F'T in M`, then by propagation axioms (which are BX theorems, hence in every MCS by MCS closure), `G(F'T)` and `H(F'T)` are also in M. So the dense extension set is consistent. If `U(T,bot) in M`, the discrete set is consistent. At least one must hold (excluded middle on `F'T`).

*Restructure `bx_completeness` (~40 lines)*:
- [ ] Modify `bx_completeness` to:
  1. Assume not derivable, get consistency of `{neg(phi)}`
  2. Case split via `dense_or_discrete_consistent`
  3. Dense case: extend to MCS A0, build chronicle, apply `F'T_propagates_to_all_domain_points`, invoke `dd_countermodel_chronicle_dense`
  4. Discrete case: extend to MCS A0, build chronicle, apply `next_top_propagates_to_all_domain_points`, invoke `dd_countermodel_chronicle_discrete`
- [ ] Remove the current direct call to `Chronicle.dd_countermodel_chronicle` (line 148)
- [ ] Update module docstring and axiom audit comments

- [ ] Run `lake build ...Completeness` to verify

**Timing**: 4 hours

**Depends on**: 5, 6

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` -- restructure bx_completeness with case split, add propagation lemmas and consistency lemma
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- remove BLOCKED status comments, update module docstring

**Verification**:
- `lake build Bimodal.Metalogic.BXCanonical.Completeness` succeeds
- The theorem `bx_completeness` compiles without sorry

---

### Phase 8: Full Verification and Axiom Audit [NOT STARTED]

**Goal**: Verify the entire project builds sorry-free, perform axiom audit, and clean up documentation.

**Tasks**:
- [ ] Run `lake build` (full project rebuild)
- [ ] Run `#print axioms bx_completeness` -- must show NO `sorryAx`
- [ ] Run `lean_verify` MCP tool on `Bimodal.Metalogic.BXCanonical.bx_completeness`
- [ ] Update axiom audit section in Completeness.lean to reflect new state
- [ ] Update ChronicleToCountermodel.lean module docstring (remove BLOCKED status, describe case-split)
- [ ] Verify Boneyard files are NOT imported by active modules
- [ ] Verify `#print axioms dd_countermodel` still shows `sorryAx` (dead code path via RootScopedChain -- acceptable)
- [ ] Run `lake build` after documentation updates to confirm no regressions

**Timing**: 2 hours

**Depends on**: 7

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` -- update axiom audit comments
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- update docstring

**Verification**:
- Full `lake build` succeeds
- `#print axioms bx_completeness` shows: `{propext, Classical.choice, Lean.ofReduceBool, Lean.trustCompiler, Quot.sound}` -- NO `sorryAx`
- `lean_verify` confirms no sorry dependencies

---

## Testing and Validation

- [ ] `lake build Bimodal.ProofSystem.Axioms` after Phase 1
- [ ] `lake build Bimodal.Metalogic.Soundness` after Phase 2
- [ ] `lake build` (full) after Phase 2 to confirm no downstream breakage from new axioms
- [ ] `lake build Bimodal.Metalogic.BXCanonical.Chronicle.ChronicleToCountermodel` after Phases 3, 4, 5, 6
- [ ] `lake build Bimodal.Metalogic.BXCanonical.Completeness` after Phase 7
- [ ] `lake build` (full) after Phase 8
- [ ] `#print axioms bx_completeness` must show NO `sorryAx`
- [ ] `lean_verify` on `Bimodal.Metalogic.BXCanonical.bx_completeness`
- [ ] Verify Boneyard files exist but are NOT imported by active modules

## Artifacts and Outputs

- `plans/04_case-split-completeness.md` (this plan)
- Modified: `Theories/Bimodal/ProofSystem/Axioms.lean` (4 new constructors)
- Modified: `Theories/Bimodal/Metalogic/Soundness.lean` (4 validity proofs + match cases)
- Modified: `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` (major reconstruction: density proof, Cantor iso, discrete iso, FMCS/BFMCS for both cases, countermodels)
- Modified: `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` (case-split restructuring)

## Rollback/Contingency

- Git commits at each phase boundary. Rollback any phase via `git revert`.
- Phases 1-2 (axioms + soundness) are additive -- zero risk to existing proofs.
- Phases 3-4 (density/discreteness proofs) are independent of each other. If one case is harder than expected, the other can proceed independently.
- Phases 5-6 (BFMCS + coherence) are the highest-risk phases. Fallbacks:
  - **Fallback A**: If a specific coherence property (e.g., `restricted_buc`) is hard, use `sorry` with a focused follow-up task. The other case still provides partial progress.
  - **Fallback B**: If the Cantor iso archived code is incomplete and reconstruction is too complex, focus on the discrete case first (coherence is easier per report 05: domain = all of D eliminates the extension gap).
- Phase 7 (case split) depends on both cases. If only one case is complete, the completeness theorem can be stated conditionally (partial result).
- Archived code in `Boneyard/DenseChronicle/` preserves the old pathway for reference.
