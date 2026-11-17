# RaySummary — the seam interface for `⊡` over the time axis

This directory is the decidability side's **interface** to the `k`-type summary substrate in
[`FormalSystem/Metalogic/WeakCanonical/KTypeSummary/`](../../WeakCanonical/KTypeSummary/README.md),
together with the **realizability device** that reads realized family triples off a finite
presentation. The substrate proper — Büchi's complementation chain transposed to monadic
`k`-types over the `ℤ` time axis — lives there; here are the seam interface (`Seam.lean`,
`SeamMulti.lean`), the device (`Closure.lean`, `Trace.lean`, `Compose.lean`, `Present.lean`,
`HitOf.lean`), the conditional per-seam check (`StabCheck.lean`), and the construction that
discharges the device's realization hypothesis for a model built from a presentation
(`Realize.lean`).

## Why this cluster exists beside `PlusSlicedCertificate/`

The time-sliced L⁺ certificate presents a frame on `ℤ × Fin n` with **finite fibres**, and the
finite-width finite model property for the sliced class is **refuted**
(`FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.NoFiniteWidth.not_finite_width_fmp`).
Checking `⊡φ` on the seam-gluing path-space presentation
(`FormalSystem.PlusLanguage.plusStab_iff_omega`: a backward ray glued to a forward ray at a seam)
therefore needs summaries over the **time axis** with a finite alphabet of per-time summaries,
not over states — pigeonhole-over-states lasso summaries are refuted on infinite acyclic fibres
(`not_lasso_sufficient_on_chain`, `specs/evidence/seam-gluing-ray-product/device-selection-probe.lean`).
The `KTypeSummary/` cluster is that time-axis device; this directory is where its consumer-facing
statement about `⊡` is made.

## What it holds

<!-- BEGIN GENERATED: inventory dir=FormalSystem/Metalogic/Decidability/RaySummary -->
| File | Lines | Description |
|------|-------|-------------|
| `AnchorLayer.lean` | 418 | Requirement (W), the **anchor layer** — the half of the closure-wide object the semantics lets one state on EVERY model with no hypothesis. Closure types read off a model (`tpOf`, classical, a `Finset`; `mem_tpOf_iff`, `tpOf_timeShift`), the per-state cells (`cellAt`, time-independent by `cellAt_eq_cellAt`), the four fixpoint equations a closure type satisfies by the truth clauses alone (`bot_not_mem_tpOf`, `imp_mem_tpOf_iff`; `box_mem_tpOf_iff` — ONE GLOBAL bit per `□`-subformula, `Anchored.box` with its per-time quantifier dropped by `box_time_invariant`; `stab_mem_tpOf_iff` — one bit per cell, `Anchored.stab` on types), the finite object `AnchorCons` (a set of cells satisfying the Hintikka and `box`/`stab` equations) with its completeness theorem for EVERY model `anchorCons_anchorCells` — `(M : TaskModel F.toTaskFrame) (φ : PlusFormula)` and nothing else: no presentation, no finiteness, no `[F.IsRegular]` — `anchorCells_finite` and the bound `anchorCells_ncard_le : (anchorCells M φ).ncard ≤ 2 ^ (2 ^ \|cl φ\|)` (a count of cells, not a complexity bound), and the `Finset` twin `AnchorConsFin` with `decidableAnchorConsFin` (an instance on a concrete finite object, never about a model; exercised by a non-vacuous `#guard` witness and a negative control in `KTypeFinEvalTest.lean`) and the bridge `anchorConsFin_iff`. No `untl`/`snce` equation — the run layer, blocked ("(W): what landed and what did not" below) — and no declaration mentions `PlusValidZTime`. |
| `Certificate.lean` | 1,451 | <!-- TODO: add description --> |
| `Closure.lean` | 309 | B1: the closure alphabet `clSig φ` (one letter per subformula of `φ` plus the marker `clNow`; `Fintype`/`DecidableEq` by `inferInstanceAs`), HWZ 2000 Def 11's local run conditions on colourings of `ℤ` (`LocalRun`: `bot`, `imp`, `untl`, `snce` — exactly `PlusTruthAt`'s clauses), the anchors that fix what a run condition cannot (`Anchored`: `now` at `t`, atoms at states, `box` per time — `box_time_invariant` (`PlusLanguage/PlusTruth.lean`) shows that field's `∀ z` is redundant on every `TaskFrame`, `□ψ` being a per-model datum; the structure is pinned and consumed by `Trace.lean`'s uniqueness theorem, so the redundancy is recorded here and not repaired — `stab` per state), the closure trace `clTrace` of a history (its two-letter projection is `seamTrace`, `clTrace_proj`), `HitSig` over an arbitrary signature, and the signature-generic bridge `plusStab_iff_forall_hitSig`, of which `plusStab_iff_forall_hit` is the two-letter instance (`hitSig_twoLetter` by `rfl`). |
| `Compose.lean` | 400 | B3b, the composition half: the finite segment of a list of letters `listSeg` (carrier `Fin l.length`, computable instances, `kTypeOfFin_listSeg`), the letters of a decidable colouring on `[a, b)` (`labels`) with `kTypeOf_segZ_eq_listSeg` (a time-axis segment has the `k`-type of its label list, by `k_equiv_of_iso`), `listSeg_append_kEquiv` (a concatenation is the two-point ordered sum of its parts), and the congruence `kTypeOf_listSeg_append_congr` — the `k`-type of `l₁ ++ l₂` depends only on the `k`-types of the parts, the `I = J = Bool` instance of `kEquiv_orderedSum_of_kEquiv_colour`. No `compose` on bare `KType` values, by design: most `k`-types are the type of nothing. |
| `CounterQuotient.lean` | 1,305 | <!-- TODO: add description --> |
| `HitComplete.lean` | 669 | Requirement (C), the general row — the completeness half of the run layer for EVERY regular `ℤ`-model. The three-piece gadget presenting a bi-ultimately-periodic word (`GadgetState := Fin \|w\| ⊕ Fin \|m\| ⊕ Fin \|v\|`, `gadgetLab`, `gadgetStep`: a `w`-cycle with an exit edge, an `m`-path, a `v`-cycle; a `#guard` documents the step table on a two-letter toy), its canonical run `gadgetRun` reading the periodic colouring (`runTrace_gadgetRun`) and the uniqueness `isRun_gadget_iff` (`now` sits in the `m` part, successor-determinism after it, predecessor-determinism before it), so the gadget's `hitOf` IS the family-triple set of its periodic trace (`hitOf_gadget_eq`); disjoint unions of presentations (`isRun_sigma_iff`, `hitOf_sigma_eq`, `card_sigma_le`); the exhibited count `sizeBound φ k := N^3 · (4 P^2 + 1)` and the headline `exists_hitPresented`: `Fintype.card Q ≤ sizeBound φ k ∧ HitPresented M τ t φ lab step k`, one gadget per triple of `HitCl`. `[F.IsRegular]` through `HitCl` only; `Fintype` on the presentation; noncomputable (classical choice per triple); one seam; no complexity bound; nothing about `PlusValidZTime` or `⊡(Pp)`; `Presented` stays refuted as a completeness carrier. |
| `HitOf.lean` | 810 | B3b, the read-out half: liveness over **disjoint** segments joined by one `step` (`fwdSepGraph`, `bwdSepGraph`, `fwdLiveSep`, `bwdLiveSep`, `fwdLiveSep_iff`, `bwdLiveSep_iff` — the graph a `SegmentFactorization` actually walks; with `Present.lean`'s shared-endpoint graph the characterization below is false, by a two-state counterexample `#eval`-witnessed in `KTypeFinEvalTest.lean`), the computable realized-triple set `hitOf lab step now k` (an image over state pairs of `pathTypesNow` types paired with live path types, never a filter over the triple product of `KType sig k`), and `mem_hitOf_iff`: for every anchor `t` and depth `k ≥ 1`, `hitOf` is exactly the family triples (`InFamily`) of the traces of the presentation's runs — the ⇒ direction splices runs of the presentation through a generic `ℤ`-indexed concatenation (`cutAt`, `exists_concat`, `isRun_concat`, `kTypeOf_segZ_concat`), the ⇐ direction reads a factorization's segments as `runSeg` paths and uses `k ≥ 1` through `doets_lemma_1_1` for the `k`-type visibility of nonemptiness and of a `now` state. |
| `LadderAgree.lean` | 3,362 | The **rigid-anchor, replacement and cascade layer** of the ladder, importing `AnchorLayer` and `CounterQuotient` alone and certificate-free: nothing here is a `certAdm`-shaped object, no `Dmax` is assembled, and `ParamsOk` enters only where the counter quotient's own class collisions are read. Five layers. (1) **The anchor readings of a realized type**: the `⊞` bit as a cell-level datum, the temporal fixpoint readings `untl_mem_tpOf_iff`/`snce_mem_tpOf_iff`, and the `⊞`-nesting depth's pinned-letter parameter and the three facts an induction on that depth steps by (the depth MEASURE itself, `stabDepth`, is declared one module down in `CounterQuotient.lean`, which `(K2)`'s margin conjunct and `Tcof` both read) and the narrow atom-valuation transport fragment — closure-indexed letters over the time axis with the `□` and `⊞` bits included, never a letter alphabet of its own. (2) **The components of a ladder path**: the four readings of `Count`, the rigid pending region, the window the next-deadline register imposes with its two regimes at a pending position, what a class collision of the counter quotient actually says, and the saturated segment of a long pending region. (3) **The replacement layer**: the splice `spliceObj`/`spliceCnt`/`spliceIdx` with the segment repeated once, `pinCompat_of_ladderPath` (the pins of a ladder path are pairwise compatible, which makes the splice's pin demand NECESSARY rather than merely sufficient), the lift of a walk to a ladder path, and the pending-forever discharge of the side condition. (4) **The cascade layer**, the interface the counter lift reads at the comparison position — the narrower EXISTENTIAL delivering, at that position, the original's object state with the countdown raised by exactly the cycle length, with no pointwise walk identity anywhere. The cascade's front half (`pinnedRegions` and its finiteness and `ncard` count, `pin_deficit_le_of_lengthen`, `cascadeDemand` and its sizing, every quantity a COUNT of iterations and no complexity claim) stays landed as the record of a mechanism the construction did not need: a single insertion at the region start of `a`'s own region moves every earlier region start down TOGETHER, so `insPins_of_region_start` discharges the pin side condition with no iteration and no doubling recurrence. The insertion primitive is `insIdx`/`insObj`/`insCnt` with its four LOCAL ladder conditions (`insObj_step`, `insCnt_idle`, `insCnt_pend_pend`, `insCnt_pend_idle`) and `insRegionStart_trichotomy`. Three existentials carry the interface and their CONCLUSIONS are identical: `exists_ladderPath_at_region_of_pend_past` (the pending-forever half, composed with `spliced_at_region`, and the only one of the three that reads no self-loop), `exists_ladderPath_at_region_of_idle_past_of_self_loop` (the idle-past half, landed on the INSERTED walk) and `exists_ladderPath_at_region_of_self_loop` (the plain dichotomy of the two). The latter two are **unconditional in the REGIME sense and conditional on the self-loop**: each takes `hself`, the path-local self-loop `∀ p ≤ a, pend (objAt g p) = false → step (objAt g p) (objAt g p) = true` at the path's own idle positions, which is a genuine additional premise on a general object relation and is why both carry the `_of_self_loop` suffix while the bare names `exists_ladderPath_at_region_of_idle_past` and `exists_ladderPath_at_region` stay UNCLAIMED. That premise is INDEPENDENT rather than merely undischarged: `specs/evidence/seam-gluing-ray-product/ladder-self-loop-derivability-decision.lean` compiles `hself_not_derivable` — the implication from the other binders refuted with `Fintype Q` ASSUMED — together with `hself_satisfiable_at_an_instance`. The `spliceObj`-shaped conclusion is **REFUTED in the idle-past regime, not merely absent**, which is why `exists_spliced_ladderPath_of_idle_past` is unclaimed: `spliceCnt` raises the pin at the region start by exactly `l` against `pinCompat_of_ladderPath`'s necessity, so on a PIN-TIGHT original the demand reads `s - v + l ≤ s - v`, and the tight idle-past object exists, compiled, in `specs/evidence/seam-gluing-ray-product/ladder-tight-chain-nonliftability.lean` (`tightChain_slack_zero` makes every pin pair of it exactly tight with every `v ≤ 0` idle). The insertion is therefore FORCED to differ from `spliceObj` strictly below the comparison position's region start. (5) **The history layer**: ladder paths ARE the world histories of the ladder frame, with object-trace locality (half (i) of the truth transport), model-level periodicity of the realized type, the atom-valuation closure agreement, and the pend-profile-preserving alternative history with its non-vacuity — a ladder state has MORE histories through it than its own path's. **What this module does NOT settle.** No filed Goal of the realization record lands here: no `ladderSound`, no `ladderCons_localRun`, no `ladderLift`, no `Dmax ⊆ Real`, no fibre equation. The cell-level agreement is **stated and refuted as a schema** rather than proved: `CellLEZeroConstOfKappaEq` is false at the periodicity fixpoint's own outputs for a stab-free closure, and `AtomPreservingCountMove` is refuted outright (`atomPreservingCountMove_refuted`), so the `⊞`-nesting-depth induction's depth-`0` base is claimed in neither direction here. The slice stays infinite and no fibre bound is introduced; the ladder's structural liveness is FORWARD-ONLY and nothing here claims a backward mirror of it, nor that any device discriminates between classes of structures. |
| `LadderCell.lean` | 3,285 | The **cell level**: inclusions between the cells of the ladder model at two counter states whose `kappa`-classes COLLIDE, and the arithmetic case split saying which sub-regimes such a collision can occupy. Imports `LadderChain.lean` alone and adds no pump and no pin. The COMMON-SHIFT INCLUSION: `exists_ladderPath_through_common_shifted_of_pend_past` is the landed regime-A assembly with the register CARRIED along the shift rather than held — the walk and every countdown are the landed path's, and only the deadline register is rebuilt, by the freed-anchor lift `exists_ladderPath_of_walk_nxt_at` at `z` with the anchor value `nxtAt g z + m · (P + 1)`; the anchor clause closes from the widened window alone, because the raise pushes every pin of the raised path at least `cntAt g z + m · (P + 1) + 1` beyond `z` while the pending-forever gap `n + 2 ≤ c` bounds the register at `z` by `cntAt g z − 2`, leaving exactly `m · (P + 1)` to spare. Its consumer `cellAt_subset_of_common_shift_of_pend_past` is the UPWARD cell inclusion along the common-shift chain — the sub-regime `cellAt_subset_of_shift_of_pend_past`'s docstring names and does not state — so the two together cover both sub-regimes of a collision. The DOWNWARD cell inclusion at the STATE level, the mirror of the upward one: `ForwardSlackWitnessed` lifts the forward-slack regime from one path to a whole cell — every type the cell at a state realizes is realized there by SOME path carrying `HasForwardSlack`, an existential over paths and so untouched by `ClimbWitness.hasForwardSlack_refuted_unconditional`, which is why a per-path state-level regime is refuted while this one is not — and it asserts nothing, being a hypothesis a consumer supplies; `cellAt_subset_of_shift_of_pend_past_rev` is the inclusion itself, the landed path-level `mem_cellAt_of_shift_of_hasForwardSlack_exact` applied to the witnessing path, with no new pump and no new pin. The COLLISION CASE SPLIT: `kappa_collision_regimes` reads a collision through `kappa_eq_components`, `eq_or_both_ge_of_min_eq` and `clipIdx_regime_of_eq` at `(K4)`'s `2 ≤ B` as a disjunction over named ARITHMETIC facts (not over cells) with THREE branches — equal register `n = n'` with the countdowns congruent mod `P + 1` and the two counter regimes segregated, common shift of both coordinates by the SAME multiple of `P + 1`, and a SATURATED gap coordinate at both pairs on the same side of the window. The third branch is forced, not slack: `kappa_collision_two_regimes_refuted` refutes the two-branch form as a consequence of those destructors together with `2 ≤ B`, at `Tc = Tn = P = 0`, `B = 2` and the pairs `(0, 2)`, `(0, 3)`; the refutation is scoped to that derivation and asserts nothing about the two-branch form under full `ParamsOk`, whose `(K1)`, `(K2)` and `(K4)` quantify the formula and are not read here. Neither landed inclusion addresses the saturated branch, and `kappa_collision_two_regimes_refuted_of_pend_gap` compiles that restricting a collision to the pending-forever regime at countdowns above the threshold does not remove it — at `Tc = Tn = P = 0`, `B = 2` the pairs `(2, 0)` and `(4, 1)` collide there with the registers differing and no single multiple of `P + 1` displacing both coordinates. The RESTRICTED OBLIGATION: `CellLEZeroConstOfKappaEqForwardSlack` is the depth-`0` obligation with four hypotheses added — the equal-register restriction `n = n'`, the pending-forever gap and the threshold bound at both pairs, and the forward-slack witnessing of whichever pair carries the higher countdown at exactly the separating displacement — and `cellLE_zero_const_of_kappa_eq_of_forwardSlack` proves it, as cell EQUALITY, at every tuple `ParamsOk` admits, by `Set.Subset.antisymm` on the two inclusions above. It is NOT the reserved statement: it is strictly stronger in hypotheses, bears on the unrestricted schema's truth value in neither direction, and the reserved name `cellLE_zero_const_of_kappa_eq` is claimed by nothing in this module or anywhere else. The COMMON-SHIFT DOWNWARD HALF and the BRANCH-2 OBLIGATION: `mem_cellAt_of_common_shift_of_hasForwardSlack_exact` is the downward cell membership ON THE WITNESSING PATH with the register carried DOWN by the same multiple of `P + 1` as the countdown — `LadderChain.lean`'s register-lowering deletion at `n₀ := n` and `k := m · (P + 1)`, whose regime amount is therefore DOUBLED to `m · (P + 1) + m · (P + 1)` (one for the countdown, one for the lowered anchor) and which carries a room bound `n + (m · (P + 1) + m · (P + 1)) ≤ c` that neither implies nor is implied by the pending-forever gap; `cellAt_subset_of_common_shift_of_pend_past_rev` is its state-level form under `ForwardSlackWitnessed` of the higher pair at that doubled amount. Against the upward `cellAt_subset_of_common_shift_of_pend_past` these give `CellLEZeroConstOfKappaEqCommonShiftForwardSlack` and `cellLE_zero_const_of_kappa_eq_commonShift_of_forwardSlack`: the depth-`0` cell-EQUALITY schema for branch 2 of the case split with NO EQUAL-REGISTER HYPOTHESIS, the common-shift displacement taken as an explicit hypothesis in its place. It does NOT reach the saturated branch and, being strictly stronger in hypotheses than the reserved statement, bears on its truth value in neither direction. The FREE-REGISTER RAISE and the MONOTONE DISPATCH OF BRANCH 3: `exists_ladderPath_through_free_register_shifted_of_pend_past` is that same assembly with the anchor VALUE left free — the countdown raised by exactly `m · (P + 1)`, the object state and the realized stab-free type held, and the register delivered at ANY prescribed `n₀` with `nxtAt g z ≤ n₀ ≤ cntAt g z + m · (P + 1)`; the two bounds pay for opposite directions of the one anchor clause (the lower for the register's two-sided Lipschitz bound, the upper for the pin distance) and `free_register_anchor_clause_monotone_required` compiles the LOWER one as non-removable at the arithmetic witness `X = 19`, `nz = 8`, `cz = 10`, `mP = 0`, `n₀ = 0`, `d = 11`, which is the compiled reason the raise reaches the monotone side of a collision and no further. `cellAt_subset_of_free_register_shift_of_pend_past` is the UPWARD cell inclusion it buys, consuming NO forward slack because the widened window pays for the anchor; `mem_cellAt_of_free_register_shift_of_hasForwardSlack_exact` and `cellAt_subset_of_free_register_shift_of_pend_past_rev` are the DOWNWARD half on the witnessing path and at the state level, resting on the register-lowering deletion at `n₀ := n` and `k := n' − n`, at the amount `m · (P + 1) + (n' − n)` with the room bound `n' + (n' − n) ≤ c` and the HIGHER pair's own gap `n' + 2 ≤ c + m · (P + 1)` carried explicitly (a named hypothesis here because the free register breaks the derivation the common shift gets for free at `m = 0`). `MonotoneCollisionDisplacement` names the dispatched shape — countdown and register displaced in the SAME direction — and `CellLEZeroConstOfKappaEqMonotoneForwardSlack` with `cellLE_zero_const_of_kappa_eq_monotone_of_forwardSlack` is the depth-`0` cell-EQUALITY schema for it, carrying NEITHER the equal-register restriction NOR the common-shift displacement and specializing to both landed schemas' hypotheses at `n' = n` and `n' = n + m · (P + 1)`; neither landed schema is retired and neither signature is touched. The ANTITONE complement is EXCLUDED by that hypothesis, visibly, in the schema's quantifier, and three compiled records keep the exclusion from being tacit: `kappa_collision_monotone_or_antitone` makes the two slices an exhaustive dichotomy over collisions with no third case, `kappa_collision_antitone_residue_nonvacuous` inhabits the excluded slice inside the pending-forever regime above the threshold at `(4, 2)` against `(6, 0)`, and `kappa_collision_monotone_saturated_gap_nonvacuous` exhibits the dispatched slice reaching branch 3 at `(2, 0)` against `(4, 1)` — the exact pair `kappa_collision_two_regimes_refuted_of_pend_gap` pins as reached by no landed inclusion. The ANTITONE DISPATCH: that route — forward-slack witnessing at the LOWER pair, to pay the upper anchor direction the necessity record compiles as failing — is now TAKEN. `AntitoneCollisionDisplacement` names the complement shape and `kappa_collision_monotone_or_antitone_named` restates the landed dichotomy over the two named predicates; `kappa_collision_antitone_descent_multiple` reads the register's descent as itself a multiple `j · (P + 1)`, SPLITTING the slice into a BOUNDED sub-slice (`j ≤ m`) and a DEEP-DESCENT residue, both non-empty inside the regime (`kappa_collision_antitone_bounded_descent_nonvacuous` at `(4, 2)` against `(6, 0)` with `m = 2` — the predecessor's own witness, in the cheaper half — and `kappa_collision_antitone_deep_descent_nonvacuous` at `(10, 8)` against `(11, 0)` with `m = 1`). `exists_ladderPath_through_free_register_shifted_slack_of_pend_past` is the free-anchor raise with the lower bound RELAXED to `nxtAt g z ≤ n₀ + (m · (P + 1) + L)` under forward slack `L` at the lower pair, built on `LadderChain.lean`'s slack-exposing raise and closing its pin clause through `anchor_clause_of_first_region_start` at deleted length `0` rather than through raw Lipschitz; `free_register_anchor_clause_relaxed_bound_required` compiles the RELAXED bound as non-removable too, at a deep-descent witness `X = 19`, `nz = 8`, `cz = 10`, `mP = 1`, `n₀ = 0`, `d = 12`, while `free_register_anchor_clause_monotone_required` (witness `mP = 0`, where the relaxed bound IS the landed bound) stays compiled and unamended — the bound is non-removable, as it says, and what is new is that it is RELAXABLE by exactly the raise. `cellAt_subset_of_antitone_register_shift_of_pend_past` is the upward antitone inclusion (countdown UP, register DOWN, at the truncated amount `(n − n') − m · (P + 1)` witnessed at the lower pair) and `..._rev` the downward one (countdown DOWN, register UP, at `m · (P + 1)` witnessed at the higher pair, under NO room bound — a register RAISE is free in the direction the single anchor inequality charges for, where the monotone downward half LOWERS and pays `m · (P + 1) + (n' − n)` under `n' + (n' − n) ≤ c`). Against each other they give `CellLEZeroConstOfKappaEqAntitoneForwardSlack` and `cellLE_zero_const_of_kappa_eq_antitone_of_forwardSlack`, closing the dichotomy on both sides. `forwardSlackWitnessed_zero` compiles that an amount-`0` witnessing obligation is FREE, which is why `cellLE_zero_const_of_kappa_eq_antitone_bounded_of_forwardSlack` dispatches the BOUNDED sub-slice carrying exactly ONE `ForwardSlackWitnessed` hypothesis and none upward; discharging the amount-`0` case settles nothing about whether such a hypothesis at a POSITIVE amount is satisfiable at any state the induction one layer up reaches, which stays open and claimed in neither direction. The unrestricted `CellLEZeroConstOfKappaEq` under `ParamsOk` stays neither proved nor refuted, and the reserved name `cellLE_zero_const_of_kappa_eq` is claimed by nothing. Beside that argument, and consumed by none of it, the ITERATED SPLICE'S TWO INTERIOR CLAUSES, as siblings leaving the pump spine of `LadderChain.lean` byte-identical: `exists_iterSpliced_ladderPath_idx_interior_of_pend_past` carries the four clauses of `exists_iterSpliced_ladderPath_idx_of_pend_past` plus the countdown at position `j` of copy `i` — the original's at the retracted position plus the `(d - i) * l` positions of the copies still above it, proved by re-running the parent's induction with the clause carried, since the parent's existential exposes no interior countdown to derive it from. The companion REGISTER clause is REFUTED, not open: `iterSpliced_register_interior_forces_block_drift` derives from it on any ladder path that the original's register at the block's last position is within one of its value at the block's first, and `iterSpliced_register_interior_refuted` exhibits a path (the climbing-register witness, with `fwdT`/`bwdT` the admissible carrier's two seriality conditions for that object and `labT` the all-true labelling under which `tpOf_labT_atom_const` makes the pump's type hypothesis free) on which that fails while EVERY hypothesis of the parent holds — so the register coordinate of the pump is uncontrolled at the window's interior, for every choice of how the register is rebuilt. Neither interior clause says anything about a `⊡` bit, a cell, or any `kappa` coordinate. Beside those, THE REGISTER DISCRIMINATOR: a two-sided measurement of what register relation the pump delivers against what the `⊡`-bit agreement needs, landed because the refuted register clause left the question open rather than answered. PRODUCER side — `register_displacement_bound_of_anchor` is the whole of the register coordinate's transport between two ladder paths agreeing at one anchor (the sum of the two positions' distances to it, each half `nxtAt_lipschitz_two_sided`), and `register_interior_displacement_bound_at_block` reads it at the pump's own copy pairs at the bound `i · l + 2 · j`, which GROWS with the copy index; `iterSpliced_register_clipped_interior_forces_block_drift` weakens the refuted clause from register EQUALITY to `kappa`'s own clipped reading `min · Tn` and derives the SAME block `Drift`, because below the threshold the clipped reading IS equality, and `iterSpliced_register_clipped_interior_refuted` exhibits that on the climbing-register fixture already carried here, at every `Tn ≥ 3` and every `P`, with the residue conjunct carried in the refuted hypothesis so the clipped/residue CONJUNCTION falls with it. CONSUMER side — on the same two-state object under the pending-tracking labelling `labR`, `stab_alphaR_iff` computes the `⊡` bit of the probe formula `alphaR := X r → X X ¬ r` at an idle ladder state EXACTLY: the bit is `register = 0`, because from an idle position the next region's countdown IS the register (`cntAt_eq_nxtAt_of_idle_pend`) and `regPath` exhibits the forced pending continuation at any prescribed register. Off it, `stab_bit_ne_of_register_ne` refutes dropping the register conjunct at every amount `m > 0`, refutes a `Drift`-distance bound at `m = 1` (one step's drift, bits differing), and refutes the residue reading alone at `m = P + 1`; `stab_alphaR_eq_of_clipped_eq` delivers the bit's agreement from the clipped reading alone at every `Tn ≥ 1`. The two sides DISAGREE — the pump cannot hold the clipped register at its window's interior and the bit cannot read anything weaker — so NO relation is defined, membership of no pair is claimed, and the register coordinate's bridging is a route decision between a block-selection restriction and a certificate-side move. THE PENDING-STATE MEASUREMENT settles the path-level half of that decision: the idle-state consumer measurement is taken at a state shape the pump's window never occupies (a block of a pending past is pending throughout), so `stab_gapR_iff` computes the `⊡` bit of `gapR := ¬ (r U (¬ r ∧ X r ∧ X X ¬ r))` at a PENDING ladder state `(true, c, n)` exactly, generically in the path and the history — the bit is `c + 1 < n`, a threshold on the signed GAP `n − c`, with `gapPath` the falling-register ladder path through the state (a ladder path exactly when `n ≤ c + 1`) and `pendPath` the constant-register one. Off it, the three candidate readings are each decided by a compiled object: the gap is CONSUMED at every pending state, above any positive countdown threshold and at countdown `0` alike (`stab_gapR_eq_of_gap_eq`, sufficiency for this one formula and not for a closure); the clipped/residue conjunction is REFUTED at every countdown `c ≥ Tn − 1` (`stab_gapR_ne_of_clipped_eq`, registers `c + 1` against `c + 1 + (P + 1)`) and CONSUMED only on the slice of equal countdowns `c + 2 ≤ Tn`, which contains countdown `0` (`stab_gapR_eq_of_clipped_eq_of_low`, `stab_gapR_iff_of_cnt_zero`), so the two measurement points differ on it; and reading neither is refuted by the gap's own sufficiency. On the PRODUCER side `iterSpliced_gap_interior_forces_block_gap_le` derives from the gap-shaped conjunct at copies `0` and `1` of a block — pending there, carrying the original's signed gap — that the original's gap does not rise from the block's first position to its last, because the step from the top of copy `0` to the bottom of copy `1` is one pending-to-pending step across which the gap moves by `0`, `1` or `2`; along a pending block the gap is itself non-decreasing, so the conjunct forces it constant. The wired probe `specs/evidence/seam-gluing-ray-product/ladder-clipped-register-block-nonvacuity.lean` compiles the verdict on its ramp fixture, where the gap rises by two per position: `ProbeB1.gap_conjunct_refuted_on_ramp` refutes the conjunct for every ladder path at every block of length at least two, and the same file's `ProbeB1.no_clipped_block_at_params` refutes the block-selection restriction as non-vacuous at the discharged parameters. So no register conjunct measured at the path level passes both sides, and what remains is the certificate-side move; a gap CLIPPED to a window, which is what `kappa`'s own gap coordinate carries, is a strictly weaker conjunct and is neither landed nor refuted. No relation is defined, no cell agreement is claimed, and `kappa` is applied nowhere in this measurement. No declaration in the tree carries the name `cellAt_const_of_kappa_eq`, `ladderRealized`, `ladderSound`, `ladderCons_localRun` or `ladderLift`: the agreement and the fibre equation are REFUTED as filed (`exists_kappa_collision_cellAt_ne_at_K4_clip`, `LadderRealize.lean`), and the other three are OPEN. No `docs/theorem-index.md` row: no filed Goal lands in this layer. |
| `LadderChain.lean` | 2,986 | The **realized-chain bridge**, NOT certificate-free by design: it reads the LOCAL half of the certificate layer — `locCoh`, `untlLink`, `snceLink`, `cohIdle`, `SatCl`, `prodCycleLens` — and no certificate-SET object (its own grep forbids the certificate conditions, the maximum certified subset, the consistency bundle, the periodicity bridge and the fixpoint's threshold and period), which is what keeps it clear of the recorded circularity. The budget lemmas `card_prodState`, `budget_le_cascadeBound`, `budget_le_Tc` and the EXPONENTIAL reading of the same `(K2)` conjunct (`two_pow_card_prodState_le_Tc`: every admissible `T_c` dominates `2 ^ Fintype.card (ProdState Q φ)`, which is the quantity a pigeonhole over the region starts of a doubling chain consumes); the strict one-step unfoldings `untl_mem_tpOf_succ_iff`/`snce_mem_tpOf_succ_iff`; the realized types satisfy the local conditions (`locCoh_of_realized`, `untlLink_of_realized`, `snceLink_of_realized`, `cohIdle_of_realized`); the periodic walk of a type-respecting block is a saturated `cohIdle`-cycle (`blockWalk_cohIdle`, `blockWalk_satCl`); the Goal `realized_typeBlock_mem_prodCycleLens` and its corollary `typeBlock_length_dvd_of_paramsOk` (the block's length divides `P + 1` under (K1)); and the REGIME-A ASSEMBLY `exists_ladderPath_through_shifted_of_pend_past` (through a pending-forever path's state at countdown at least `Tc`, a ladder path with the countdown raised by exactly `m · (P + 1)`, the register and the object state held, and the same realized stab-free type — the pigeonhole, the bridge, the iterated duplication, and the register rebuilt by `exists_ladderPath_of_walk_nxt` with `z` at the origin) with its corollary `cellAt_subset_of_shift_of_pend_past`, the UPWARD cell inclusion along the common-shift chain; the assembly is a corollary of the register-held iterated duplication of a GIVEN block, `exists_ladderPath_through_iterSpliced_nxt_of_pend_past`. The DOWNWARD direction under the forward-slack regime: the deletion with the register exposed at `z` (`exists_deleted_ladderPath_of_pend_past_nxt`), the collapse of its anchor clause to the first region start (`anchor_clause_of_first_region_start`), the regime `HasForwardSlack` (one inequality at that region start, a property of the PATH) with its entry lemma from a finite witness (`hasForwardSlack_of_next_region_cnt_le`), monotonicity (`hasForwardSlack_mono`), transport across a deletion decreased by exactly the deleted length (`hasForwardSlack_del`) and vacuity (`hasForwardSlack_of_idle_above`); the two-state witness `ClimbWitness` — the climbing-register path refutes the unconditional claim (`hasForwardSlack_refuted_unconditional`: `Drift` admits `n' = n + 1` at every step, so no `Drift`-level invariant bounds the climb) and the plateau inhabits the regime at every amount with a genuine next region (`exists_hasForwardSlack_inhabitant`); the single-block downward assembly `exists_ladderPath_through_deleted_of_pend_past`; the room bound `budget_mul_succ_le_Tc` (`b · (b + 1) ≤ Tc` from `(K2)` alone) and the spaced type pigeonhole `exists_typeBlock_of_spacing`; the iterated splice index map `iterSpliceIdx` (copy boundaries retract to `u`, the run's top to `u + l`, everything above by `−d · l`) with the iterated duplication and the register-held wrapper read through it, `exists_iterSpliced_ladderPath_idx_of_pend_past` and `exists_ladderPath_through_iterSpliced_nxt_idx_of_pend_past` (the walk and the realized stab-free types exposed at EVERY position, in particular at every copy boundary `u + i · l` and above the run), and the slack transport across a raise, `hasForwardSlack_raise` (increased by exactly the raised amount, the mirror of `hasForwardSlack_del`); the one-step deletion `exists_deleted_ladderPath_step_of_pend_past` and the overshoot loop `exists_deleted_ladderPath_overshoot_of_pend_past`, each with its sampling window as the one room hypothesis; the UP-FIRST EXACT-SHIFT theorem `exists_ladderPath_through_deleted_exact_upfirst_of_pend_past` (the countdown lowered by exactly `m · (P + 1)` with the register, the object state and the realized stab-free type held, under the gap and the regime at EXACTLY `m · (P + 1)`: raise by `b` copies of the original block first, overshoot above the run, delete the exact remainder inside it); and its consumer `mem_cellAt_of_shift_of_hasForwardSlack_exact`, the DOWNWARD cell inclusion ON THE WITNESSING PATH under exactly `n + 2 ≤ c`, `Tc ≤ c` and `HasForwardSlack g z (m · (P + 1)) n`. The same statements with a `b²` slack term in both anchor directions, `exists_ladderPath_through_deleted_exact_of_pend_past` and `mem_cellAt_of_shift_of_hasForwardSlack`, are corollaries by `hasForwardSlack_mono`. The REGISTER-LOWERING exact-shift deletion `exists_ladderPath_through_deleted_exact_lowered_upfirst_of_pend_past` frees the TARGET REGISTER of the up-first theorem: the countdown still lowered by exactly `m · (P + 1)` and the object state and realized stab-free type still held, but the register delivered at a prescribed `n₀ ≤ nxtAt g z` under the regime at `m · (P + 1) + k` where `n₀ + k = nxtAt g z` — the lowering costing exactly `k` in the UPPER direction of the single anchor inequality and nothing in the lower one, and `k = 0` recovering the held-register theorem hypothesis for hypothesis. Its construction performs the lowering BEFORE the surgery: the countdown of a ladder path is read off its walk but the register is not, so `exists_ladderPath_of_walk_nxt_at` re-lifts the path's own walk and countdown at the anchor `n₀` (pin clause: `anchor_clause_of_first_region_start` at deleted length `0`, where the `k` is spent; the regime transfers to the re-lift because a region start's countdown is the register's value at the idle position before it), and the held-register theorem then applies to the re-lift unchanged — so the module carries ONE copy of the pigeonhole/raise/overshoot/remainder spine, not two. Two siblings add one clause each, both for what the ANTITONE side of a collision needs and neither reachable from a landed signature: `exists_ladderPath_through_shifted_slack_of_pend_past` returns the regime-A assembly's four landed clauses PLUS `HasForwardSlack g' z (L + m · (P + 1)) (nxtAt g z)` — the raise's own bought slack, which the landed assembly discards with a `-` pattern on its `_idx_` call's `habove` — and is stated at the end of `section Slack` because `HasForwardSlack` and `hasForwardSlack_raise` are both introduced below `section AssemblyFin`; `exists_ladderPath_through_deleted_exact_raised_upfirst_of_pend_past` is the exact-shift deletion with the target register RAISED rather than lowered, at the regime amount `m · (P + 1)` UNCHANGED, because a lowering is charged for in the UPPER direction of the single anchor inequality while a raise costs nothing there (its one extra need is the named room condition `n₀ + 2 + m · (P + 1) ≤ cntAt g z`, and `n₀ = nxtAt g z` recovers the held-register theorem hypothesis for hypothesis). Both leave their landed counterparts untouched. No state-level downward inclusion, and the depth-`0` cell obligation is neither proved nor refuted here. |
| `LadderIdle.lean` | 1,358 | The **idle pump's register-anchored assembly**, importing `LadderChain` for the one register-exposing lift `exists_ladderPath_of_walk_nxt_at` and `LadderCell` for the vocabulary `ForwardSlackWitnessed` alone (the edge is acyclic: `LadderCell` imports `LadderChain`, not this module). The `d`-fold duplication of an idle block holds the next-deadline register at a chosen position `z`, holds every countdown at and below the block, lengthens the idle run by `d · k`, and preserves the realized stab-free type below it — three determinations against the REFUTED unrestricted lengthening schema (`idleGapLengthening_refuted`, the decision gate's own evidence record): (i) `idleGapLengtheningOfIdleRunRepeat_holds` under a RUN-LOCAL repeat premise, with the increment restricted to multiples of the repeat length and that restriction compiled as necessary by `idleGapLengtheningAllIncrements_refuted`; (ii) type preservation DISCHARGED rather than assumed, through the idle-restricted `(objAt, tpOf)` pigeonhole (`exists_idleTypeBlock_of_budget_le_run`) and `tpOf_eq_spliceIdx_of_tpOf_eq`; (iii) the premise is an OBJECT/RUN hypothesis and NOT a consequence of `ParamsOk` (`idle_run_lt_tIdle_of_no_idleCycle`, `LadderPump.lean`, is the bound without it), so the CONDITIONAL cell-level consequence `forwardSlackWitnessed_of_cell_idleRunPumpable` — `ForwardSlackWitnessed` at EVERY amount from the amount-free premise `IdleRunPumpable` — discharges nothing reserved. **`section IOne` REFUTES that discharge's complement at the every-amount shape.** On the two-state object `stepOr x y = x \|\| y`, serial in both directions and with NO idle self-loop — hence with every idle run of length exactly `1` on every ladder path — `forwardSlackWitnessed_refuted_I_one` falsifies `ForwardSlackWitnessed` at amount `4` at the state `xState = (true, 2, 0)`, which `xState_regime` compiles as inhabiting the pending-forever gap by a concrete path. This is the first CELL-level refutation of `ForwardSlackWitnessed` in the development: the mechanism is the amount ceiling `hasForwardSlack_amount_le` (`LadderChain.lean`), forced here by the OBJECT rather than by a choice of path, so the existential-over-paths escape that stops the pin-cascade refutation at the path level is unavailable, and `forwardSlackWitnessed_holds_below_ceiling` compiles the boundary as sharp (the same state carries every amount `l ≤ 3 = n + c + 1`). **Its reach is bounded, and the bound is compiled rather than asserted**: `ceiling_slack_at_consumer_amount` shows `l ≤ n + cntAt + I` is satisfied for free at the amount `m · (P + 1)` the five depth-`0` cell-equality schemas instantiate it at, on the HIGHER state whose countdown is `c + m · (P + 1)`, whenever `0 < I`. All five therefore KEEP `ForwardSlackWitnessed` as a carried hypothesis for a positive reason — `cellLE_zero_const_of_kappa_eq_of_forwardSlack` and its `_commonShift_`, `_monotone_`, `_antitone_`, `_antitone_bounded_` siblings — no schema signature is touched, `LadderCell.lean` is not edited, and `certStabK`'s restatement obligation stays PROVISIONAL. `not_idleRunPumpable` compiles that `IdleRunPumpable` is unsatisfiable for every path, history and anchor on that object, so the refutation and the conditional discharge cannot collide. The reserved name `cellLE_zero_const_of_kappa_eq` is claimed by nothing here and this module bears on its truth value in neither direction; the surviving frontier is route 4 at the cell level — simultaneous multi-region shortening — recorded and not attempted. No `docs/theorem-index.md` row and no `Paper:` line is added for any of it: these are negative results about an internal obstruction, not results the manual states. |
| `LadderModel.lean` | 231 | Requirement (W), the **admissible ladder carrier** beside `ladderFrame`, which stays instance-free and is not edited. The record that `ladderFrame`'s own seriality hypotheses are unsatisfiable — `no_fwd` for EVERY object (`[Nonempty Q]` only), `no_bwd_of_idle` for every object with an idle state — so the frame has no instances and the admissibility set `Adm` (`{c \| pend q = false → c = 0}`, the clause `Rlad` imposes on its source; unrelated to the `Adm` of `QuantLanguage/`) is a restriction of the CARRIER: `LadderState Q pend := {x : Q × ℕ × ℕ // x.2.1 ∈ Adm pend x.1}` (inhabited, `ladderState_nonempty`; still infinite), `RladAdm` as `Rlad` on the underlying triples with two-sided finite branching for EVERY finite object (`RladAdm_fwd`, `RladAdm_bwd` — `Rlad_fwd`/`Rlad_bwd` pulled back along `Subtype.val`), the frame `ladderFrameAdm` through `ofSlicedStepFinBranch` with `ladderFrameAdm_isRegular`, and the model `ladderModel` whose valuation reads the object component only. A carrier restriction of this shape is one of several equally valid (in-place repair, a sigma over `Adm`), none foreclosed. `[Finite Q]` on the OBJECT only; seriality `fwd`/`bwd` a genuine object condition on this carrier, taken as hypotheses. No realization theorem (the run layer's phase 2, open — the stabilization of `ladderModel`'s cells in the counter pair is refuted by the twelfth wired probe, which consumes these declarations), no index of a ladder cell claimed — the clipped-coordinate index family is refuted at the countdown coordinate as well as bounded at the gap one by the fourteenth wired probe `ladder-cell-index-obstructions.lean` (the region's first idle state sits at distance exactly `c + 1`, where the countdown's parity is observable), with the bounded-carrier alternative closed as a general route by the same probe, the residue-carrying candidate that probe exhibits refuted at both of its object-exhibited parameters by the fifteenth wired probe `ladder-residue-index-refutation.lean` (`object_only_parameters_refuted`, `reach_period_refuted`: the threshold must be formula-derived and the modulus must be a multiple of the period of every letter-definable sub-object) and the positive factorization lemma for any index open — nothing about `HitPresented`, no declaration mentions `PlusValidZTime`, no complexity bound. |
| `LadderPin.lean` | 261 | The **pin layer**, CERTIFICATE-FREE under the same grep as `LadderPump.lean` and importing it alone. A PIN is an idle position immediately followed by a pending one — a pending region's start, read at the idle position before it — and this module holds what the pins of a ladder path force. The dichotomy: pending is downward closed below a pin-free position (`idle_of_idle_of_no_pin_below`), so the past at or below such a position is either uniformly idle or uniformly pending from some position down (`pend_past_or_idle_of_no_pin_below`), and hence every pending position of a ladder path is on exactly one of the two sides the cell's replacement argument treats separately (`pendPast_or_cntAt_le_nxtAt_succ`: a uniformly pending past — the pin-free side, which is the hypothesis the upward cell inclusion already consumes — or a countdown at most the register plus one, the backward window). It sits between the two landed windows (`cntAt_le_nxtAt_succ_of_idle_past` backward, `nxtAt_le_cntAt_add_of_next_region` forward) and names the complementary side of the backward one exactly. The pigeonhole: `exists_pinTypeBlock_of_budget_lt_pins` runs the `(objAt, tpOf)` pigeonhole over the PINS rather than over the positions inside one region, so the block it produces SPANS a pin — with more than twice the type-pigeonhole budget of pins enumerated in a window, two of them at least two apart carry the same object state and the same realized type at their successor positions, and a third pin lies strictly inside the block they bound — and `exists_spanningBlock_of_pins_below` reads that tuple off in the shape the refuted spanning-block condition's statement took. NO cell-level agreement, no `ParamsOk`-level assembly, and NO claim that pins are dense on a general path — a path may carry one long region and no pin at all, and the dichotomy's point is that such a path IS the pin-free side; the pigeonhole's hypothesis is the pin COUNT, so it produces a spanning block at a given object and never revives the refuted device, which asserted one unconditionally. |
| `LadderPump.lean` | 1,926 | The **type-preserving pump layer**, certificate-free under `LadderAgree.lean`'s grep and importing `LadderAgree` alone: index-map surgery on ladder paths and on the closure types realized along them. The deletion index map `delIdx` (strictly monotone, a section of the splice retraction `spliceIdx` and definitionally the splice's order embedding `spliceEmb`), the deleted walk `delObj` and its forced countdown `delCnt` with the three local readings of `Count` (`delCnt_idle`, `delCnt_pend_pend`, `delCnt_pend_idle`) and the payoff `delCnt_sub_of_mem_region` (the countdown drops by exactly the block's length at every position whose region reaches the block), and the admissibility half `exists_deleted_ladderPath_of_pend_past` — the mirror of `exists_spliced_ladderPath_of_pend_past`, with the pins above the block displaced by `-l` and discharged through `pinCompat_of_ladderPath` on the original; and the TYPE half of both surgeries — the duplication type lemma `tpOf_eq_spliceIdx_of_tpOf_eq` (read through `spliceIdx`) and the deletion type lemma `tpOf_eq_delIdx_of_tpOf_eq` (HWZ 2000 Lemma 17 over `ℤ`, read through the monotone `delIdx`), each the `L := fun _ => False` instance of a pinned-letter truth-level transport whose temporal clauses pass through the endpoint equality of the block's ends (`endpoint_iff_of_tpOf_eq`; four clause lemmas per surgery). Exposure: `exists_iterSpliced_ladderPath_of_pend_past` exposes the realized types of the duplicated path only below `u + l` and at `u + l`, never at the copy boundaries or above the run; the full exposure at every position is re-derived in `LadderChain.lean` through the index map `iterSpliceIdx` (`exists_iterSpliced_ladderPath_idx_of_pend_past`), of which this lemma's clauses are readings. No certificate object, no `ParamsOk`-level assembly (that is `LadderChain.lean`'s), no pending-region hypothesis on the type half. |
| `LadderRealize.lean` | 4,553 | <!-- TODO: add description --> |
| `LadderStepFrag.lean` | 1,695 | The **step system**: a back-and-forth on ladder states and the cell agreement on the **step fragment** `StepFrag` — every connective, `⊡` and `□` included, with `untl`/`snce` admitted only at the guard `⊥` (as `X` and its mirror). `Zrel a b` relates two ladder states at a budget of `a` backward and `b` forward steps: same object state, countdowns equal or both `≥ 2 (a + b)`, registers equal or both `≥ 2 (a + b)`, gaps `n - c` equal or both `≥ 2 a` or both `≤ -(2 b + 2)`; those thresholds are the SOLUTION of the one-step closure conditions (`Zrel.succ`, `Zrel.pred`), and the two budgets are kept apart because the two gap arms differ (`2 a` against `2 b + 2`). `exists_linked_path` is the path forth the `⊡` clause needs (a state related to one a ladder path visits lies on a ladder path linked to it, `Lnk`, on the whole window), `truth_iff_of_lnk` is the truth lemma on the fragment, and `cellAt_eq_of_Zrel` is the agreement as its corollary — for an ARBITRARY finite object and with NO `ParamsOk` hypothesis; the parameters enter only where a `kappa`-collision is turned into membership of `Zrel`, a bridge stated in the wired probe `specs/evidence/seam-gluing-ray-product/ladder-step-fragment-gap-depth.lean` and not here. OWED and not discharged: at a formula the thresholds `2 * (dBack + dFwd) ≤ Tc, Tn` arrive as explicit hypotheses, and that the parameter outputs dominate them is compiled nowhere. The STATEMENT LAYER of the two jump clauses sits beside the system: `LnkRow a b g g' t t'` is the row link — the relation the `untl`/`snce` clauses of `PlusTruthAt` read, a witness on one row answered by a witness on the other with every passed position answered back (`FwdJump`, `BwdJump`), at the budget left after the jump — with `LnkRow.symm`, `LnkRow.mono`, the window restriction `LnkRow.toLnk` and the `⊡` clause at the budget `(0, 0)` (`exists_rowLinked_path_zero`); `LnkRow.refl` is its reflexivity, and `truth_iff_of_lnkRow` is the truth lemma over it at the `⊡`-free level (`RowFrag`: no `⊡`, no `□`; `untl` and `snce` at every guard) — a statement about paths that are ALREADY row-linked, which constructs none. The path forth with a whole-row correspondence at a positive budget is OWED, written in the module docstring as text and declared nowhere, so NO agreement of cells is landed for any formula with a jump; `LnkRow.first_zero` and `LnkRow.region_end_obj` are a NECESSARY condition on a row link (the two current pending regions end at one object state), and the wired probe `specs/evidence/seam-gluing-ray-product/ladder-row-link-residue-obstruction.lean` uses it to show the path forth has no solution from a `Zrel`-shaped hypothesis at any thresholds — its state relation must carry an object-dependent residue of the countdown. The gap clip `2 (dBack + dFwd) + 2` does NOT suffice on the whole language: the wired probe `specs/evidence/seam-gluing-ray-product/ladder-cell-agreement-refutation.lean` refutes the agreement at it (`repaired_clip_refuted`) and at every clip below `2 ^ (dBack + 1)` (`gap_clip_below_exponential_refuted`), by a family paying one `snce` jump per doubling of the idle register. A formula with an `untl` or `snce` jump at a guard other than `⊥` is OUTSIDE the fragment — the separating families `thetaC` and `mixC` each use one such jump and are not covered — so nothing here bears on `cellAt_const_of_kappa_eq_schema_refuted` or `no_fibre_equation_over_kappa`; no agreement over `kappa`-classes, no fibre equation, no soundness or lift statement and no certificate inclusion is stated, and no complexity bound is claimed. |
| `LadderWindow.lean` | 1,907 | The **ordinary window regime** `c ≤ n + 1` of the depth-`0` cell obligation, the exact complement of the pending-forever gap `n + 2 ≤ c` that all five `LadderCell.lean` schemas carry — `cntAt_le_nxtAt_succ_of_idle_past` puts a pending position with ANY idle position in its past inside this window and `pend_past_of_nxtAt_lt` puts one with `n + 2 ≤ c` on a path pending at every earlier position, so the two are the branches of one dichotomy. The ARITHMETIC layer: `kappa_collision_window_room` (at `2 ≤ B` a class collision at a fixed register either pins the two countdowns equal or exhibits a positive multiple of `P + 1` TOGETHER WITH the strict room `c' ≤ n` for the larger one — the gap coordinate paying for it through `clipIdx_regime_of_eq` with the gap branch killed, not an added assumption), and the three scale-invariant pin statements the regime's surgery reads (`window_anchor_compat_of_room`, `window_pin_compat_raise_of_gap`, `window_pin_compat_lower_of_spacing`), in which the displacement is an OPAQUE natural so none of them depends on the modulus, on `(K1)`, or on any parameter tuple. The DECISION GATE's second layer, measured rather than argued: four of the `z`-anchored lift's six clauses are free on a composite built as a ladder path, the anchor clause `hn₀` is `window_anchor_clause_of_pin_classification` at the prescribed register value, and the pin PAIR clause is where the compensator is spent (`window_pin_pair_raise_of_slack` against `no_pin_in_idle_run`). The compensator is the IDLE RUN BELOW the position, named as the checkable condition `HasIdleRunBelow` and spent once on block EXISTENCE (`exists_idleBlock_of_hasIdleRunBelow`), so nothing here touches `ForwardSlackWitnessed` and the refuted deletion-above route is not re-entered. The composite raise's ADMISSIBILITY half at one block length: `window_composite_pin_trichotomy`, `window_composite_pins` and `exists_window_composite_ladderPath`, the last lifting the composite walk twice — anchor-free through `exists_ladderPath_of_walk_of_pins` to put the trichotomy on a genuine ladder path, then through `exists_ladderPath_of_walk_nxt_at` at the PRESCRIBED register. NOT landed: the iteration to an exact multiple of `P + 1`, the model-level half carrying the realized type, the lowering primitive, and every cell-level consequence — so no cell inclusion and no schema is stated here. The reserved `cellLE_zero_const_of_kappa_eq` is claimed by nothing and no declaration carries that name or any prefix of it; `ParamsOk`'s own conditions are consumed and amended nowhere, nothing is claimed about `HitPresented` or `PlusValidZTime`, no index of a ladder cell is claimed at any parameters, and no complexity bound is claimed. |
| `Periodic.lean` | 1,627 | Periodic transport, the model-free core of (C)'s general row. The bi-ultimately-periodic colouring `periodicColouring w m v b` (`w^(ω*) · m · v^ω`) with its one-sided forms `fwdPeriodic`/`bwdPeriodic` and letter read-outs; the tail type sets `FwdTypes`/`BwdTypes` of a colouring read from a seam time, depending only on the tail (`fwdTypes_congr`, `bwdTypes_congr`); the forward Ramsey blocks `exists_blocks_fwd` (infinite Ramsey for pairs on the `(profile, cutProfile)` colouring of stretches), the refinement of piece stretches into a factorization (`refineCut`, `mem_fwdTypes_of_stretches`), the forward transport `exists_periodic_fwd` (★₊: membership read off two profiles, containment by the cut transport — the offset pigeonhole, a cut chosen in every block from the equal cut profiles, `profile_flatten_congr` block by block), its reflection `exists_periodic_bwd` (★₋: the `k`-type of a reversed word is a function of the word's, `kTypeOf_listSeg_reverse_congr`, by the order-dual symmetry of the back-and-forth game — `dualStructure` reused from `GroupModel/MonoDiscrete.lean`), family triples through the seam (`now_mem_middle`, `mem_familyTriples_iff_tails`), and the seam assembly `exists_periodic_subfamily` (★). Every length bound counts pairs of profiles. Carries the sanctioned `longFile` baseline. |
| `Present.lean` | 690 | B3b, the closure half: finite labelled presentations, unbundled (`Q` with `[Fintype Q] [DecidableEq Q]`, `lab`, `step`, `now`), their bi-infinite runs `IsRun` and decidable traces `runTrace`, finite paths `StepPath`/`stepPath_iff`, the representative-carrying closure `pathClosure` computing `pathTypes` (the `k`-types of `now`-free paths between two states) and `pathTypesNow` (paths reading `now` once) by `kTypeOfFin` on one stored label list per key, justified by the congruence (`mem_pathTypes_iff`, `mem_pathTypesNow_iff`; stationarity within `closureBound` rounds by `iterate_stabilizes`), and liveness as a greatest fixpoint (`live`, `live_iff`, `fwdLive`, `bwdLive`). `fwdLive`/`bwdLive` chain paths that share an endpoint and are **not** what `hitOf` reads (see `HitOf.lean`). |
| `Profile.lean` | 581 | The σ-star profile of a finite word — its `k`-type plus, for every type `σ`, the relation of (prefix type, suffix type) pairs around a middle in `L_σ^*` (`starProfile`, `profile`, the finite type `Profile` with `Nat.card (Profile sig k) = N · 2^(N^3)`), and the cut profile `cutProfile` (the pairs of profiles over all cuts). The summary that composes under the Kleene star of a type where bare `k`-types do not: the composition law `profile_append_congr` through the explicit four-case law `starProfile_append` (middle inside the left part, inside the right part, straddling at a piece boundary, straddling inside one piece), `profile_flatten_congr`, the star languages `StarZero`/`StarPlus`/`PrefixStar` read off the profile at `k ≥ 1` (`starPlus_iff_profile`, `prefixStar_iff_profile`), and bounded representatives by profile pumping (`exists_rep_of_length_lt`: same profile, no larger cut profile, length `< Nat.card (Profile sig k) ^ 2` — a count of pairs of profiles, not a complexity bound). |
| `Realize.lean` | 1,004 | Requirement (S), the soundness half — HWZ 2000 Thm 14 (⇐) for the box-dot fibre. The decidable per-edge consistency conditions on a finite labelled presentation (`UCoh`, `deferGraph`, `ULive`, `Disch` forward; `SCoh`, `bwdDeferGraph`, `SLive`, `DischBwd` backward, proved outright and **not** transported — no backward Bool-fixture bridge exists) with the two theorems forcing `LocalRun`'s eventuality clauses from them (`untl_iff_of_UCoh_ULive`, `snce_iff_of_SCoh_SLive`), each generic over `sig` and `Q` with no model, frame or carrier finiteness in sight. The scope predicate `PlusFormula.BoxStabFree` and the closure-vacuity it buys (`not_box_mem_plusSubformulaClosure`, `not_stab_mem_plusSubformulaClosure`), which is what makes `Anchored`'s `box` and `stab` fields vacuous. The **eleven**-field bundle `Cons` with `cons_localRun` (field by field, no new induction); ten fields mirror a `LocalRun` field or a frame law, the eleventh, `nowUnique`, was derived from the realization theorem's own obligation and is documented at the field. The constructed model `frameOf` / `modelOf` (`ofSlicedStep` on the presentation's own `[Fintype Q]`, valuation reading the state component's label), its regularity instance `frameOf_isRegular`, the explicit record `frameOf_not_finite_worldState` that the carrier `ℤ × Q` is **infinite**, and the rewrite lemmas `modelOf_valuation`, `frameOf_step`, `frameOf_mem_HF_iff`. Then `anchored_runTrace_of_boxStabFree`, the realization theorem `presented_modelOf`, and the Hit-level corollary `hitCl_modelOf_eq_hitOf`. Scope, in the statements rather than in prose: ONE seam, `box`/`stab`-free `φ`, `[Fintype Q]` on the PRESENTATION only. No declaration mentions `PlusValidZTime` and no complexity bound is claimed. |
| `RunLayer.lean` | 557 | Requirement (W), the **run layer's frame scheme** — the regularity part of its first obligation, and nothing more. The branching core transcribed from the seventh wired probe (`FwdFinBranch`, `BwdFinBranch`, `iterS_fwd_finite`, `iterS_bwd_finite`, `fib_finite_of_finBranch`, `saturation_of_finBranch`), the parallel constructor `ofSlicedStepFinBranch` (`ofSlicedStep`'s body with `[Finite W]` replaced by two-sided finite branching in its one `Saturation` slot; `Semantics/SlicedFrame.lean` untouched) with `ofSlicedStepFinBranch_isRegular`, `ofSlicedStepFinBranch_step`, the record `ofSlicedStepFinBranch_not_finite_worldState` and the history characterization `ofSlicedStepFinBranch_mem_HF_iff` (lines 72–250, 179 lines); and the **deadline ladder** `Rlad` over `Q × ℕ × ℕ` (`Drift`, `Count`: the current deadline counts down deterministically, the next deadline drifts by at most one per step, no state chooses a deadline) with two-sided finite branching for EVERY finite object (`Rlad_fwd`, `Rlad_bwd`), an infinite slice (`Rlad_slice_infinite`) and the frame `ladderFrame` with `ladderFrame_isRegular`, `ladderFrame_step` (lines 251–373, 123 lines). `[Finite Q]` on the OBJECT only; seriality is the object's own `fwd`/`bwd` hypotheses; depth `k = 1`. No realization theorem (the run layer's phase 2, open — "(W): what landed and what did not" below), nothing about `HitPresented`, no declaration mentions `PlusValidZTime`, no complexity bound. |
| `Seam.lean` | 165 | `SeamSummary` (a family triple plus a `Bool` verdict), the four-field hypothesis bundle `Presents` (`colours`; `determined`; `realized` — joint realization through the seam; `verdict`), and the bridge `plusStab_iff_seamSummary`: under `Presents`, `⊡φ` holds at the seam iff the verdict is `true`. The bundle's declarations are pinned and unchanged; what `colours` says is characterized in `SeamMulti.lean`. |
| `SeamMulti.lean` | 344 | The characterization `exists_presents_iff` (`SeamDecided`): the single-family bundle is inhabited iff the seam is `⊡`-decided — so `Presents.colours` is a seam condition, not the MSO reduction. The two-letter interface (`twoLetter`, `seamTrace`, `nowPhi`, `stabTarget`, `stabTarget_determined` from `determinedByKType_eval`), the realized set `Hit` (finite: `hit_finite`), the hypothesis-free bridge `plusStab_iff_forall_hit`, and the multi-family bundle `PresentsMulti` with its bridge `plusStab_iff_presentsMulti` and its inhabitant `presentsMulti_seamTrace` (whose `Bool` is classical). |
| `StabCheck.lean` | 252 | The per-seam `⊡` check by state liveness, **conditional on `Presented`** — the assembly that "The verdict" (below) bounds. The `now`-free step graphs `fwdNowFree`/`bwdNowFree`; `OnRun` and `onRun_iff_live` (the `now` states of runs anchored at `t` are exactly the live `now` states: a run restricted to `[t, ∞)` and `(-∞, t]` is a pair of chains, and a pair of chains with a common origin glues to a run); the decider `stabCheckSig lab step now phi` (every live `now` state reads `phi`) with `stabCheckSig_iff`, correct at every anchor (`t` does not occur in the decider); and the closure instance `stabCheck_iff_of_presented` / `decidableStabOfPresented`, composing the decider with `Trace.lean`'s run-level bridge `plusStab_iff_forall_run_of_presented` (under `Presented`, `⊡φ` at the seam iff every anchored run of the presentation reads `φ`'s letter at its `now` state). Both closure-instance statements are vacuous on model A, where `Presented` has no inhabitant (`presented-not-complete.lean`, below); no declaration mentions `PlusValidZTime`. |
| `Trace.lean` | 418 | B2a, HWZ 2000 Thm 14 in the direction that reads types off a model: the closure trace satisfies every run condition and anchor (`clTrace_localRun`, `clTrace_anchored`, each clause `Iff.rfl`) and an anchored local run **is** the trace of its history (`eq_clTrace_of_localRun_anchored`, `clTrace_unique`, by structural induction on the closure formula). The realized set over the closure alphabet `HitCl` (finite), the bridge `plusStab_iff_forall_hitCl`, and `hitCl_eq_iUnion` (the union over the seam's ray pairs of their traces' family triples — a theorem, not a computation: `SeqPair` is not finite). The realization hypothesis `Presented M τ t φ lab step` (the seam's closure traces are exactly the presentation's run traces), `presented_localRun`, the per-model bridge `hit_eq_hitOf_of_presented` (`HitCl = ↑(hitOf …)` for `1 ≤ k`), and `plusStab_iff_forall_hitOf_of_presented`, which decides nothing. Beside it the **Hit-level weakening** `HitPresented` — equality of the realized FAMILY-TRIPLE sets, `HitCl M τ t φ k = ↑(hitOf lab step (clNow φ) k)`, instead of equality of the trace sets — with `hitPresented_of_presented` (`Presented` implies it at every `k ≥ 1`, by `hit_eq_hitOf_of_presented` verbatim; no converse). It is **satisfiable** where `Presented` is refuted, with the presentation size exhibited as the count `Nat.card (KType (clSig Fp) k)` (not a complexity bound of any kind): see "The verdict" below. |
| `Transport.lean` | 441 | Transport of a family triple along the DELETION of a constant run — the bridge from `Compose.lean`'s periodicity of one finite block to `InFamily`'s cutting sequences over `ℤ`. The keystone `segZ_const_of_kTypeOf_eq_replicate` (at `k ≥ 1`, a time-axis segment whose `k`-type is that of a nonempty constant block `ℓ^j` is itself nonempty and reads `ℓ` everywhere: two depth-`1` sentences transferred by `k_equiv_preserves_sentence`), the deletion colouring `deleteRun c s p` (the positions `[s, s + p)` removed) with its `labels`/`kTypeOf` lemmas for the untouched, translated and run-holding segments, and the cut surgery `inFamily_of_shrink_run`: a factorization whose ONE segment holds a constant run of length `≥ m₀ + p` (with `(m₀, p)` a threshold/period pair, an explicit hypothesis) re-cuts to a factorization of `deleteRun c s p` with the same triple, hence `familyTriples_subset_deleteRun`. Shrink direction only, under the single-segment containment as a hypothesis (the re-cut case, several short segments meeting the run, is NOT handled; the unconditioned general threshold would be `3·(m₀ + p)` and is not claimed); no `↔`. Every count is a count of depth-`k` types and nothing else. |
<!-- END GENERATED -->

## What it does not do

- **It does not compute `Hit` for a model.** `hitOf` is computable on a finite labelled
  presentation and is exactly the family triples of that presentation's runs (`mem_hitOf_iff`);
  a seam's realized set `HitCl` equals `hitOf` **only under the explicit realization hypothesis
  `Presented`** (`hit_eq_hitOf_of_presented`) — the closure traces of the seam's splices are
  exactly the presentation's run traces — and that hypothesis is discharged only for a
  model **constructed from a presentation** (`Realize.lean`'s `presented_modelOf`), never for a
  model given independently. Without it, `HitCl` is the image of the seam's ray pairs under
  the trace map (`hitCl_eq_iUnion`), a theorem and not a computation, and
  `presentsMulti_seamTrace`'s verdict is still `decide (⊡φ)` under `open Classical` — it carries
  the answer, it does not find it. The single-family bundle `Presents` is not a reduction at all:
  it is inhabited iff the seam is `⊡`-decided (`exists_presents_iff`), and a regular `ℤ`-frame
  seam with no inhabitant for any parameters is exhibited in the wired probe
  `specs/evidence/seam-gluing-ray-product/presents-is-seam-decidedness.lean`.
- **It realizes a presentation only on the `box`/`stab`-free fragment, at one seam
  (B2b / requirement (S)).** Discharging `Presented` for a model **constructed** from a
  presentation — HWZ 2000, Definition 12 / Theorem 14 ⇐, for this semantics' `⊡` fibre — is
  landed in `Realize.lean` (`presented_modelOf`, with the Hit-level corollary
  `hitCl_modelOf_eq_hitOf`) for `box`/`stab`-free `φ` at one seam under `Cons`. It is **not**
  landed for `box`/`stab`-bearing `φ`, where the construction is degenerate by a named mechanism
  (`frameOf`'s step relation is time-constant, so `modelOf`'s `box` anchor is time-invariant and
  its `stab` letters collapse — `plusStateLocal_stab_iff`'s semantic half), and it is not landed
  at any seam but the one; both of those are assigned to requirement (W). See "(S): what landed
  and what did not" below for the full scope, for the eleventh `Cons` field, and for the
  descoped frame-constructor prerequisite. It was not a one-line mirror of `Trace.lean`, for a
  reason that is a property of the semantics: the fibre is a **product**
  (`seamOmegaEquiv`: histories through `(t, s)` are pairs of a backward and a forward
  ω-step-sequence out of `s`), so the set of traces realized at a state is closed under splicing
  the backward half of one history with the forward half of another, and a per-state summary that
  claims a set of types `S` realizes the mixed set — HWZ Lemma 17's "realised type the model
  lacked", which here is a closure property of the fibre rather than an operation that may or may
  not be sound. A sound presentation must therefore carry a product `BwdSummary × FwdSummary` of
  the two one-sided atom-sequence languages, with types derived by the trace map; liveness cannot
  be enforced by a step graph on a finite slice (a presentation deferring an eventuality without
  bound is realized together with its limit path), which is what `Cons`'s two liveness fields
  `ulive`/`slive` rule out instead. The prerequisite this bullet once named — a new
  regular-frame constructor, because `Saturation` is proved in this tree for `[Finite W]` only
  (`ofSlicedStep_saturation`) — turned out **not** to be needed: `frameOf` is `ofSlicedStep` on
  the presentation's finite `Q` whose carrier `ℤ × Q` is infinite, so no finite-fibre and no
  finite-width assumption is introduced. Its content was measured anyway and is held by the
  seventh wired probe below, which also refutes the obvious repair shapes. The wired probe `quasistate_does_not_determine_hit`
  (below) is the machine-checked verdict that HWZ's verbatim per-time quasistate shape cannot
  stand in for the hypothesis.
- **No decision procedure, no decidability result, no complexity bound.** Assembling a decidable
  `⊡` check on the path-space presentation is downstream work; `plusStab_iff_forall_hitOf_of_presented`
  restates the bridge over `hitOf` under `Presented` and decides nothing (the per-triple condition
  is the consumer's to make effective). The CTL⋆ 2EXPTIME lower bound (argued, not formalized) is
  a sanity ceiling only. `decide` on `KType sig k` is exponential in `|NormalForm sig k 0|`; the
  witnesses run at depth 1 on two-state presentations and 3-5 point segments.
- **No finite-fibre or finite-width assumption.** Everything is over the time axis with a finite
  alphabet of per-time letters under `[F.IsRegular]`; the only `[Finite W]` anywhere is the
  counterexample fixture's licence.
- **It does not decide `PlusValidZTime φ`, and the presentation cannot.** No declaration in this
  directory mentions validity, and none could be reached from it: `Presented` is refuted as a
  completeness carrier by the wired probe `presented-not-complete.lean` (`Probe735.not_presented`),
  so an enumeration of `Presented`-presentations decides nothing about `PlusValidZTime φ` — and
  that is unchanged by the B2b construction now landed above, which realizes presentations as
  models and thereby says nothing about which models have presentations. The recorded verdict, with the three theorems the
  lift to validity still needs, is the next section.

## The verdict

**The ray-product presentation, as landed, cannot deliver `Decidable (PlusValidZTime φ)`.** What
it delivers on this front is a decidable per-seam `⊡` check **conditional on `Presented`**
(`decidableStabOfPresented`, `StabCheck.lean`) and nothing further. No decision procedure for
L⁺-validity over the `ℤ` time axis is stated anywhere in this tree, in any form — unconditional,
conditional, or as a hypothesis bundle — and none is reachable from the landed substrate. The
obstruction is machine-checked, not argued, and it does not depend on whether the B2b successor
record is ever built.

**Why.** The presentation is `seamOmegaEquiv` (a history through the seam is a backward and a
forward ω-step-sequence out of the seam state) + `hitOf` (the family triples of a finite
labelled presentation's runs, `mem_hitOf_iff`) + `Presented` (the seam's closure traces are
exactly the presentation's run traces). A decision procedure for `PlusValidZTime φ` through it
would have to proceed by "every refuting regular `ℤ`-model has a `Presented` presentation", and
that is false. The wired probe `specs/evidence/seam-gluing-ray-product/presented-not-complete.lean`
proves, for fixture model A (three states on `Fin 3`, `p` at `b` only, steps `a→a, a→b, b→b`;
bi-serial, regular through `ofSlicedStep_isRegular`) at the seam `(t, a)` of the constant history
`stayA` with `φ := Fp`:

> `theorem Probe735.not_presented (t : ℤ) {Q : Type} [Fintype Q] [DecidableEq Q]`
> `    (lab : Q → (clSig Fp).preds → Bool) (step : Q → Q → Bool) :`
> `    ¬ Presented MA stayA t Fp lab step`

— for **every** finite state type, labelling and step relation, with axiom profile
`[propext, Classical.choice, Quot.sound]`. The proof in two sentences: the run-trace set of a
finite presentation is closed under pumping (a run repeating a state at `t < i < j` yields a run
repeating `[i, j)` forever, `pump_isRun`), so a presentation whose run traces include every seam
trace `(¬p, Fp)^(n+1) · (p, Fp)^ω` — the histories that stay at `a` until `t + n + 1` and then
jump to `b` — also has a run whose trace reads `Fp` at `t` and `p` nowhere after it. That trace
violates the `untl` run condition, so by `Presented` (⇐) and `clTrace_localRun` it is no seam
trace: the seam's **path** set is closed under this limit (the histories converge to `stayA`,
which is a history of the model), but the trace map is discontinuous in the `untl` letter (`Fp`
drops from `true` to `false` in the limit), so the seam's **trace** set is not closed, and no
finite presentation's run traces can equal it.

`Presented` is therefore a **soundness** device — the shape `Presented (modelOf P) … P` that a
B2b construction would discharge — and never a **completeness** carrier. On model A the
statements `hit_eq_hitOf_of_presented`, `plusStab_iff_forall_hitOf_of_presented`,
`plusStab_iff_forall_run_of_presented`, `stabCheck_iff_of_presented` and
`decidableStabOfPresented` are all vacuous (their hypothesis has no inhabitant), and an
enumeration of `Presented`-presentations decides nothing about `PlusValidZTime φ`, because a
refuting model need not have one.

**What the lift to validity still needs — three theorems that exist neither in the tree nor as
records.** Each is stated under `[F.IsRegular]`, for the fragment L⁺ (`PlusFormula`), over the
`ℤ` time axis (`PlusValidZTime`, whose integer-indexed normalization is
`plusValidZTime_iff_plusValidInt`); none is attempted here, and filing any of them, or any
dependency edit, is the user's call.

| | Requirement | Statement shape | Why the landed substrate does not supply it |
|---|---|---|---|
| (C) | **Hit-level completeness with a computable bound** | For every regular `ℤ`-model `M`, seam `(τ, t)`, formula `φ` and depth `1 ≤ k`, a finite labelled presentation `(Q, lab, step)` with `Fintype.card Q` below a computable bound in `φ`, such that `HitCl M τ t φ k = ↑(hitOf lab step (clNow φ) k)` — the Hit-level hypothesis `HitPresented` (`Trace.lean`), together with a bound | **SETTLED, in general, as a theorem.** `exists_hitPresented` (`HitComplete.lean`): for every regular `ℤ`-model `M`, seam `(τ, t)`, formula `φ` and depth `1 ≤ k`, a finite labelled presentation `(Q, lab, step)` with `Fintype.card Q ≤ sizeBound φ k` satisfies `HitPresented M τ t φ lab step k` — the filed statement verbatim, with `sizeBound φ k = N^3 · (4 P^2 + 1)` EXHIBITED in it (`N := Nat.card (KType (clSig φ) k)` depth-`k` types over the closure alphabet, `P := Nat.card (Profile (clSig φ) k)` their profiles). That count counts types and profiles and nothing else — not a complexity bound of any kind; no minimality is claimed. The route is Ramsey over a composing profile of finite words, not the fixtures' literal-segment lasso (which the cut-pair obstruction refutes as a general route): the σ-star profile composes under concatenation (`profile_append_congr`, `Profile.lean`), every word has a bounded representative of the same profile and no larger cut profile, infinite Ramsey for pairs on the `(profile, cutProfile)` colouring of a factorization's stretches gives the forward transport `exists_periodic_fwd`, its reflection through the order dual gives the backward one, the seam assembly `exists_periodic_subfamily` glues them (`Periodic.lean`), and one three-piece gadget per triple of `HitCl` in a disjoint union is the presentation (`hitOf_gadget_eq`, `hitOf_sigma_eq`). `Presented` cannot carry it (`Probe735.not_presented`) and is not used: the theorem is at the Hit level. The two fixtures stay as exhibitions: `Probe745.hitPresented_modelA` on model A with `presentationSize k = Nat.card (KType (clSig Fp) k)` and `Probe759.hitPresented_node` on `Node` (see Evidence), each with its own count. `[F.IsRegular]` is the only hypothesis on the model, entering through `HitCl`; `Fintype` is on the presentation, which is chosen classically. What (C) now delivers: at ONE seam, the realized triples are those of a finite presentation of exhibited size, so "no presentation of size `≤ sizeBound φ k` refutes `φ` at this seam" is a statement about the model's seam. What it does not deliver: validity — one seam of one model is not `PlusValidZTime φ`, the lift from seams to validity is requirement (W), and nothing here is a decision procedure or a complexity bound.
| (S) | **Hit-level soundness** — the B2b record, restated at `hitOf` level | For every finite labelled presentation `P` satisfying consistency conditions `Cons P`, a regular `ℤ`-model `modelOf P` with a seam `(τ, t)` at which `HitCl (modelOf P) τ t φ k = ↑(hitOf …)` for `1 ≤ k` (the trace-level `Presented (modelOf P) τ t φ …` is stronger and suffices) | **DISCHARGED for `box`/`stab`-free `φ` at one seam**, in `Realize.lean`, at the stronger trace level: `presented_modelOf` plus its one-line Hit-level corollary `hitCl_modelOf_eq_hitOf`. See "(S): what landed and what did not" below for the exact scope. `Cons`'s eleven fields do exclude the pumpable eventuality-deferring run sets this row named as the obstruction — the two liveness fields `ulive`/`slive` are precisely acyclicity of the deferral graph `Probe735.pump_isRun` exploits. What remains open: `box`/`stab`-bearing `φ`, and every seam but the one. |
| (W) | **A closure-wide quasimodel over all seams and times** | A finite object carrying, for every time, the `box` anchor across the whole slice and, for every state, the `stab` anchor, nested under `untl`/`snce` — so that one presentation-level object witnesses `¬ PlusValidZTime φ` for some regular `ℤ`-model, history and time, rather than one seam's `⊡` | **Characterized, and half-landed.** The object is TWO-layered. The **anchor layer** is landed in `AnchorLayer.lean` and bounded: cells (sets of closure types, one per world state), the `box`/`stab` fixpoint equations, `AnchorCons`, its completeness `anchorCons_anchorCells` for EVERY model with no presentation, finiteness or regularity hypothesis, the bound `anchorCells_ncard_le` (`≤ 2 ^ (2 ^ \|cl φ\|)`, a count of cells), and the decidable `Finset` twin `decidableAnchorConsFin` on a concrete finite object. The row's "for every time" quantifier was dropped by a theorem, not an argument: `box_time_invariant` (`PlusTruth.lean`) makes `□ψ` a per-model datum on every `TaskFrame`, so the `box` letters are global bits and `stab` letters per-cell bits. The **run layer** — the `untl`/`snce` nesting, which lives in type sequences over `ℤ` and is the lift from one seam to validity — has its **frame scheme landed** (`RunLayer.lean`: the deadline ladder `Rlad`, two-sided finite branching for EVERY finite object, an infinite slice, the regular frame `ladderFrame` with `[Finite Q]` on the object only; depth `k = 1`; the bounded-deadline variants refuted by `not_finite_width_fmp` and the seventh probe's `Rok`/`Rbad`; gate-compiled by the ninth wired probe `deadline-ladder-branching.lean`) — the regularity part of its first obligation, measured at 373 lines — together with the **admissible carrier beside it** (`LadderModel.lean`, 231 lines: `ladderFrame`'s own seriality hypotheses are unsatisfiable, `no_fwd`/`no_bwd_of_idle`, so `Adm` restricts the CARRIER; `ladderFrameAdm` regular on `LadderState`, `ladderModel` reading the object component; no realization theorem, no index of a ladder cell — the clipped-coordinate index family is refuted at the countdown coordinate by the fourteenth wired probe `ladder-cell-index-obstructions.lean` and the bounded-carrier alternative is closed as a general route by the same probe), and is otherwise **BLOCKED** on obligation (ii)'s soundness half (the stabilization lemma in the pair of ladder counters is refuted by the twelfth wired probe `ladder-cell-refutation.lean`, the realization theorem is `[BLOCKED]` on the open index of which cell a ladder state has, and the ladder's structural liveness is forward-only — thirteenth wired probe `ladder-liveness-forward-only.lean`), without a cost figure; obligation (ii)'s completeness half, (C)'s general row, is LANDED (`exists_hitPresented`, `HitComplete.lean`) (see "(W): what landed and what did not" below); the shape of (S)'s construction is refuted as its soundness half by the wired probe `w-soundness-shape-refuted.lean` (finite width; `⊡`-collapse under `Presented`+`nowUnique`) — (S) itself untouched. Nothing states `PlusValidZTime` in any form; nothing is a negative decidability result. |

### (S): what landed and what did not

**Landed.** `Realize.lean` constructs a regular `ℤ`-model from a finite labelled presentation and
discharges the realization hypothesis for it, at the stronger trace level:

> `theorem presented_modelOf {φ : PlusFormula} (hφ : φ.BoxStabFree)`
> `    {lab : Q → (clSig φ).preds → Bool} {step : Q → Q → Bool} (hC : Cons φ lab step)`
> `    (t : ℤ) (q₀ : Q) (hq₀ : lab q₀ (clNow φ) = true)`
> `    (τ : WorldHistory (frameOf hC).toTaskFrame) (hτ : τ.state t = (t, q₀)) :`
> `    Presented (modelOf φ lab step hC) τ t φ lab (fun q q' => step q q' = true)`

and the Hit-level statement this row asked for follows in one line through
`hit_eq_hitOf_of_presented`:

> `theorem hitCl_modelOf_eq_hitOf … (k : ℕ) (hk : 1 ≤ k) :`
> `    HitCl (modelOf φ lab step hC) τ t φ k = ↑(hitOf lab (fun q q' => step q q' = true) (clNow φ) k)`

Both carry axiom profile `[propext, Classical.choice, Quot.sound]` and are pinned in
`Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean`. Every qualifier is in the statements
rather than in prose: `[F.IsRegular]` through the instance `frameOf_isRegular`, the frame class
through `FrameOver intOrder`, the language fragment through `hφ : φ.BoxStabFree`, the premise set
through `hC : Cons φ lab step`, the depth bound through `1 ≤ k`, and the one-seam restriction
through the explicit `(τ, t)` with its anchor `hτ`.

**The refutation above does not bite here, and this does not weaken it.**
`Probe735.not_presented` refutes `Presented` for every finite presentation on fixture model A —
a model *not* constructed from a presentation. (S) quantifies the other way and builds the model
*from* the presentation, which is exactly the soundness/completeness distinction this verdict
drew when it called `Presented` "a soundness device … and never a completeness carrier". Both
statements stand side by side; neither retires the other, and both probes stay wired.

**`Cons` has ELEVEN fields, and one of them was derived from the realization theorem rather than
assembled with the rest.** Ten mirror a `LocalRun` field or a frame law: `serialFwd`, `serialBwd`,
`botFalse`, `impEq`, `ucoh`, `ulive`, `scoh`, `slive`, `nowOnce`, `boxStabFree`. The eleventh,
`nowUnique` (`∀ q q', lab q (clNow φ) = true → lab q' (clNow φ) = true → q = q'`), was found
*while proving* `presented_modelOf`: without it the ten admit two mutually unreachable
`now`-marked components, whose splices through a seam cannot cover the whole run set, and the
(⇐) direction fails. It is documented at the field with that obstruction.

**The `box`/`stab` limitation, with its mechanism, and where it is assigned.** The landing
statement is restricted to `φ.BoxStabFree`, and that restriction is load-bearing rather than
cosmetic: `not_box_mem_plusSubformulaClosure` and `not_stab_mem_plusSubformulaClosure` make
`Anchored`'s `box` and `stab` fields *vacuous*, which is what lets
`anchored_runTrace_of_boxStabFree` discharge them. For `box`/`stab`-bearing `φ` the construction
is not merely unproved, it is degenerate by a named mechanism: `frameOf`'s step relation is
time-constant, so `modelOf`'s `box` anchor is time-invariant across the whole slice, and its
`stab` letters collapse — `plusStateLocal_stab_iff` (`PlusLanguage/PlusStateLocal.lean`) gives
`φ ↔ ⊡φ` pointwise for state-local `φ`, and its semantic half is what forces the collapse on a
model whose fibre carries no state-distinguishing structure. Lifting past that needs `Cons`
clauses pinning `lab q (box ψ)` and `lab q (stab ψ)` against the whole slice, which is the
closure-wide object requirement **(W)** already names. The limitation is therefore assigned to
(W), not left as a gap in (S); no `box`/`stab` realization is claimed anywhere, and the
~5-line semantic-hypothesis variant of `plusStateLocal_stab_iff` that would state the collapse
formally is **not** written.

**The carried frame-constructor prerequisite was DESCOPED, with a machine-checked reason.** (S)
was filed carrying a 300-500 line prerequisite: a regular-frame constructor for "finitely many
fibre shapes per time", on the reasoning that `SlicedFrame.lean`'s `Saturation` route is
available only under `[Finite W]`. The construction turned out not to need it — `frameOf` is
`ofSlicedStep` on the presentation's own `[Fintype Q]`, whose *carrier* `ℤ × Q` is infinite
(`frameOf_not_finite_worldState`), so no finite-fibre and no finite-width assumption is
introduced and `not_finite_width_fmp` is not contradicted. The prerequisite's own content was
nevertheless measured, and the measurement is held permanently by a wired probe
(`specs/evidence/seam-gluing-ray-product/b2b-frame-constructor-branching.lean`, the seventh
below): `fib_finite_of_finBranch` proves every `TaskFrame.Fib` of `ofSlicedStepRel` finite from
*two-sided* finite branching with **no carrier hypothesis**, and `saturation_of_finBranch`
reaches `Saturation` from it — with `shift_saturation` exhibiting `Saturation` on a frame whose
slice `ℤ` is infinite. Two-sidedness is not optional, and the probe refutes the obvious repair
shapes rather than asserting the need: `Rbad` (countdown with unrestricted reset) has finite
forward branching, an infinite backward preimage at the reset target, and an outright infinite
`d = -1` fibre (`Rbad_fib_infinite`); its mirror `Rok` has finite backward branching and
infinite forward branching at the commitment state (`Rok_fwd_infinite`). So a commitment
encoding of the kind liveness would want is exactly what the bound rejects. What is left is a
**parallel** constructor beside `ofSlicedStep`, measured at ~120-160 lines rather than 300-500:
`[Finite W]` occurs 11 times across 9 declarations of `SlicedFrame.lean` and `ofSlicedStep` is
referenced in 17 files, two of them probes that may not be retired, so an in-place
generalization is prohibited. That is a named successor record, not a gap in (S).

**(S) states nothing about validity, and nothing about complexity.** `Decidable
(PlusValidZTime φ)` is not stated in `Realize.lean` in any form — one seam of one constructed
model is not validity, and (C) and (S) together still speak of ONE SEAM, which is why the lift
is (W). No complexity bound, upper or lower, is claimed for the construction, for `hitOf`, or
for the `Cons` checks (which are decidable on a `Fintype Q` and are exercised by `#guard`s at
the probe-03 fixture size only, as witnesses of computability and nothing else).

**(C) and (W) are untouched by this.** (S) is independent of (C) in both directions: the
construction has standalone value as the HWZ Theorem 14 (⇐) formalization for the box-dot fibre
regardless of (C), and nothing in `Realize.lean` bears on (C)'s general row (landed in
`HitComplete.lean`) or on (W)'s closure-wide object. The verdict's headline is unchanged: the
ray-product presentation as landed still cannot deliver `Decidable (PlusValidZTime φ)`.

**What the verdict does not establish.** Nothing about `⊡(Pp)`: every fixture is forward-only
and no backward Bool-fixture bridge exists (limit 1, below). On the Hit-level hypothesis `HitPresented` the
verdict said OPEN, not refuted, and that much is now settled in the non-refutation direction
— on **one fixture**, by `hit-presented-model-a.lean`, with the presentation size exhibited as the
count `Nat.card (KType (clSig Fp) k)`, and in general by `exists_hitPresented` (`HitComplete.lean`,
the (C) row above). The verdict itself is unchanged by that: the
ray-product presentation as landed still cannot deliver `Decidable (PlusValidZTime φ)`; (S) is
landed for `box`/`stab`-free `φ` at one seam, and (W)'s anchor layer and run-layer frame scheme are
landed while its run layer's realization is blocked (below). Nothing about models whose slices are infinite:
model A's slice is `Fin 3` (the shape `not_finite_width_fmp` leaves standing) and its carrier
`ℤ × Fin 3` is infinite; no finite-fibre or finite-width assumption is made or needed. No
complexity bound of any kind, upper or lower: the CTL⋆ 2EXPTIME lower bound remains an
**argued** (not formalized) sanity ceiling and is never a source for an upper bound. And no
negative decidability result: the verdict is that **this presentation** cannot deliver the
decision procedure, not that none exists.

**The bound: exhibited on the fixture, as a count.** (C)'s second half — `Fintype.card Q` below
a bound in `φ` — is delivered on the fixture, with the size a COUNT. `hit-presented-model-a.lean`'s
truncation step (`Probe745.hitCl_eq_truncated`) replaces the seam's infinite ray index by the
window `[t, t + presentationSize k]`, `presentationSize k := Nat.card (KType (clSig Fp) k)`, and the
headline reads `HitPresented … (labOf (presentationSize k)) (stepOf (presentationSize k)) k`, with
`card_QA_presentationSize : Fintype.card (QA (presentationSize k)) = presentationSize k + 6`. No
`Set.Finite.bddAbove`, no `∃ L`. Three landed theorems carry it:

1. `kTypeOf_listSeg_replicate_eventually_periodic_bounded` (`Compose.lean`): for every `sig`, `k`
   and letter `ℓ` there are `m₀` and `p > 0` with `m₀ + p ≤ Nat.card (KType sig k)` such that
   `ℓ^(m + p)` and `ℓ^m` have the same `k`-type for every `m ≥ m₀` — pigeonhole on the finite
   `KType sig k` plus `kTypeOf_listSeg_append_congr` applied once; no semigroup, no idempotent.
   The recorded shape `kTypeOf_listSeg_replicate_eventually_periodic` (the same statement without
   the count) is its one-line corollary.
2. `segZ_const_of_kTypeOf_eq_replicate` and `inFamily_of_shrink_run` (`Transport.lean`): at
   `k ≥ 1`, a segment with the `k`-type of a nonempty constant block is a nonempty constant
   block; and a `SegmentFactorization` whose ONE segment holds a constant run of length
   `≥ m₀ + p` re-cuts to a factorization of the colouring with `p` positions of that run deleted,
   same triple. Shrink direction only, under the single-segment containment as a hypothesis; no
   `↔`, no re-cutting of a run met by several short segments (whose honest general threshold
   would be `3·(m₀ + p)`, not claimed).
3. `Probe745.run_subset_middle` (the probe): on model A every factorization of a `jump` trace
   holds the whole `a`-run inside its middle segment, so the containment hypothesis is a fact of
   the fixture and every realized offset reduces into the window (`familyTriples_jump_shrink`).

The disclaimer, in `AnchorLayer.lean`'s words on its own cell count and binding here with
"depth-`k` types" for "cells": "The one bound (W) can state honestly: a cardinality bound on the SET OF CELLS of a model, syntactic in `|cl φ|` — a cell is a set of subsets of `cl φ`, so there are at most `2 ^ (2 ^ |cl φ|)` of them. It is not a complexity bound of any kind: it counts cells, it does not time anything, and it must not be described as a bound on any procedure's running time."
`presentationSize k` counts depth-`k` types, times nothing, bounds no procedure, and is not a
complexity bound of any kind; nothing is derived from the size of `NormalForm (clSig Fp) k 0`;
`k` is free. The CTL⋆ 2EXPTIME ceiling is neither cited nor approached.

**The bound in general.** `exists_hitPresented` (`HitComplete.lean`) carries its count in the
statement as well: `sizeBound φ k := Nat.card (KType (clSig φ) k) ^ 3 * (4 * Nat.card (Profile
(clSig φ) k) ^ 2 + 1)` — at most `N^3` triples in `HitCl`, one gadget per triple, each a `w`-cycle,
an `m`-path and a `v`-cycle with `|w|, |v| < P^2` and `|m| ≤ 2 P^2`, the lengths of bounded
representatives under profile pumping (`exists_rep_of_length_lt`, `Profile.lean`: a word of
length `≥ P^2` has two cuts with the same pair of profiles, and deleting the stretch between
them preserves the profile and shrinks the cut profile). `Profile sig k := KType sig k × (KType
sig k → KType sig k → KType sig k → Bool)`, so `P = N · 2^(N^3)` (`card_profile`); the same
disclaimer binds, with "types and profiles" for "cells": the count times nothing, bounds no
procedure, and is not a complexity bound of any kind; no minimality is claimed. The transport
`↔` of `Transport.lean` (threshold `3·(m₀ + p)`) remains a non-goal — the general row does not
use the deletion surgery at all, only the profile.

**The honest scope note on "machine-checked".** What is machine-checked is exactly the landed
theorems' statements: the explicit `presentationSize k` in the headline where the earlier shape
carried `∃ L`, so the exhibition is in the statement rather than in prose. What is not
machine-checked, because it is not a Lean-statable property of this development: that the window
is least (nothing claims minimality), and anything about the running time of anything. Nothing
here asserts a general every-model bound.

**Literature position.** HWZ 2000's Theorem 14 (⇐) realizes a quasimodel by persistent runs
satisfying the run conditions — a soundness statement — and never claims exact equality between
a model's trace set and a presentation's run-trace set; the trace-level `Presented` is this
formalization's own strengthening, and the probe shows that the strengthening is exactly what
fails on a non-trivial model. The corpus entry for HWZ 2000 is of UNVERIFIED-summary provenance
and is cited here as context only, not as a source for any claim above.

### (W): what landed and what did not

**The characterization, and the object's shape.** Requirement (W) was filed with no cost figure,
and its first phase was to characterize the closure-wide object before building anything. The
characterization (three compiled scratch files, now `box_time_invariant`, the `AnchorLayer`
module and the eighth wired probe below) found the object is **two-layered**, not the single
object the requirement imagined:

* An **anchor layer**: by `box_time_invariant` / `box_global` (`PlusLanguage/PlusTruth.lean`)
  `□ψ` has ONE truth value per model on every `TaskFrame`, and by `stab_state_only` `⊡ψ` is a
  function of the world state alone. So the "for every time, across the whole slice" quantifier
  the requirement names **does not exist in this semantics** — it was dropped by a theorem, not
  an argument. The anchor layer is a set of **cells** (the closure types realized at a world
  state, `cellAt`, time-independent by `cellAt_eq_cellAt`), a subset of `𝒫(𝒫(cl φ))`,
  satisfying the Hintikka clauses and the two fixpoint equations (`box_mem_tpOf_iff`, one global
  bit; `stab_mem_tpOf_iff`, one bit per cell) — every one a direct unfolding of a truth clause.
* A **run layer**: the `untl`/`snce` nesting, which lives in type sequences over `ℤ`. Here the
  semantics parts from HWZ 2000 Def. 12: HWZ chooses the run set `R` freely and builds the model
  ON `R`, whereas this semantics fixes the histories as ALL bi-infinite step paths of a frame
  (`mem_HF_iff_adjacent`), closed under splicing (`seamOmegaEquiv`) and under limits of chains
  (`blc_plusValid`). The run layer is therefore the path set of a yet-to-be-constructed frame.

**Landed: the anchor layer, for every model, bounded.** `AnchorLayer.lean` (see the module table
above) — the headline is

> `theorem anchorCons_anchorCells (M : TaskModel F.toTaskFrame) (φ : PlusFormula) :`
> `    AnchorCons φ (anchorCells M φ)`

over `F : FrameOver intOrder` and **nothing else**: no `Presented`, no `Cons`, no `[Finite _]`
or `[Fintype _]` on the model, no `[F.IsRegular]`. The regular `ℤ`-frames the requirement names
are an instance; the anchor layer needs only shift-closure and the truth clauses, and the
requirement's `[F.IsRegular]` is the minimum hypothesis a CLAIM ABOUT VALIDITY must carry, not
one these definitions need. Beside it, `anchorCells_finite` and

> `theorem anchorCells_ncard_le (M : TaskModel F.toTaskFrame) (φ : PlusFormula) :`
> `    (anchorCells M φ).ncard ≤ 2 ^ (2 ^ (plusSubformulaClosure φ).card)`

— a cardinality bound on a SET OF CELLS, syntactic in `|cl φ|`. **It is not a complexity bound of
any kind**, upper or lower; it counts cells and times nothing, and the ARGUED CTL⋆ 2EXPTIME
ceiling is neither cited nor approached. The `Finset` twin `AnchorConsFin` carries the one
`Decidable` instance this round lands, `decidableAnchorConsFin`, **on a concrete
`Finset (Finset (Finset PlusFormula))`** — a statement about a finite set, not about L⁺ and not
about any model; `anchorConsFin_iff` ties it to `AnchorCons`. Its non-vacuity witness in
`KTypeFinEvalTest.lean` has a cell carrying TWO types at one world state (`{{p}, ∅}` for
`φ := ⊡p`), exactly the shape trace-level `Presented` with a unique `now` state can never present
(the collapse theorem below); the negative control `{{{p}}}` violates the `stab` equation and is
rejected. All nineteen declarations of the round carry `[propext, Classical.choice, Quot.sound]`
and are pinned in `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean`.

**Landed: the run layer's frame scheme — obligation (i), regularity part.** The design
question of obligation (i) is settled by theorem rather than by argument, and the answer is
landed in `RunLayer.lean` (see the module table above). The scheme is **thread-indexed unfolding
in its general form, the deadline ladder**: a state `(q, c, n)` carries, beside the object state
`q`, two counters per `⊡`-forced eventuality — the current deadline `c`, counting down
deterministically while pending and sitting at `0` while idle, and the next deadline `n`,
drifting by at most one per step at EVERY step — so that no state ever chooses a deadline. The
`Node` shape of `Limits/NoFiniteWidth.lean` is its one-region special case. Both
bounded-deadline alternatives are refuted by landed theorems: a fixed cap on the counters gives
a finite slice, which is the finite-width shape `not_finite_width_fmp` refutes (and concretely
`Probe747.modelOf_incomplete`); a deadline chosen at a state is the seventh probe's `Rok`/`Rbad`
shape (`Rok_fwd_infinite`, `Rbad_bwd_infinite`), infinite-branching on whichever side it fires.
The ladder relation `Rlad` has two-sided finite branching for EVERY finite object (`Rlad_fwd`,
`Rlad_bwd`) and an infinite slice (`Rlad_slice_infinite`), so the seventh probe's
`fib_finite_of_finBranch` applies to it unchanged, and the frame

> `def ladderFrame (step : Q → Q → Bool) (pend : Q → Bool) (fwd : …) (bwd : …) : FrameOver intOrder`
> `instance ladderFrame_isRegular : (ladderFrame step pend fwd bwd).IsRegular`

is regular with `[Finite Q]` on the OBJECT only — `Saturation` comes from
`saturation_of_finBranch` with no `[Finite W]` on the carrier `ℤ × (Q × ℕ × ℕ)`. The constructor
behind it, `ofSlicedStepFinBranch`, is `ofSlicedStep`'s body with that one slot changed;
`Semantics/SlicedFrame.lean` is untouched and the constructor is parallel, never in place. **The
figure is measured**, replacing the carried one: 179 lines for the branching core and
constructor (the regularity part proper) and 123 lines for the ladder and `ladderFrame`, 373 in
all with the module header. Every one of the twenty declarations carries
`[propext, Classical.choice, Quot.sound]` or no axiom at all, pinned in
`KTypeSummaryAxiomTest.lean`, with `ladderFrame_isRegular` C14-pinned and indexed in
`docs/theorem-index.md`; the ninth wired probe below gate-compiles the verdict. What the
regularity part does NOT include: **seriality is an object condition** — `ladderFrame` takes
`fwd`/`bwd` as explicit hypotheses exactly as `ofSlicedStep` does, and which objects supply
them (a pending state at `c = 0` needs a discharging successor) is an admissibility restriction
`c ∈ Adm q` on the ladder's carrier — and on the FULL carrier `Q × ℕ × ℕ` no object supplies
them: `fwd`/`bwd` are unsatisfiable there for every object (twelfth wired probe, `no_fwd`,
`no_bwd_of_idle`, landed in `LadderModel.lean`), so `Adm` is a restriction of the CARRIER
(`{c | pend q = false → c = 0}`), DEFINED in `LadderModel.lean` together with the carrier
`LadderState`, the restricted relation `RladAdm` (two-sided finite branching for EVERY finite
object), the regular frame `ladderFrameAdm` and the model `ladderModel` — beside `ladderFrame`,
which stays instance-free; on that carrier `fwd`/`bwd` are genuine object conditions, taken as
hypotheses, and which objects supply them is still not costed; the run-layer consistency
conditions that would play `Cons`'s role for the ladder are likewise named and not built;
whatever form they take replaces `ulive` only (a pending region at `(q, c, n)` ends at
`z + c + 1`, by `Count`) and keeps `slive`, because an admissible ladder history can be pending at
every past time (thirteenth wired probe, `gPast_isPath`).

**Depth: `k = 1`.** Every landed bridge the run layer consumes carries `hk : 1 ≤ k` and nothing
asks more (`plusStab_iff_forall_hitCl`, `hit_eq_hitOf_of_presented`, `mem_hitOf_iff`,
`hitCl_modelOf_eq_hitOf`, `stabTarget_determined`, the `Transport.lean` lemmas), and
`Probe745.hitPresented_modelA` holds at every `k ≥ 1`. The closure alphabet carries every
nested temporal subformula as a letter, so nesting is visible at depth `1` through letters, not
through quantifiers; and the run conditions are to be enforced by the object's step structure,
as `Cons` does for (S) through `cons_localRun`, never read off `k`-types. The alternative —
making `LocalRun.untl`/`.snce` `DeterminedByKType` targets through `determinedByKType_eval` —
costs `k = 3` (the `untl` clause is `all (… ex (… all …))`, `MonadicFormula.quantifierDepth`
`= 3`) and is rejected: `Nat.card (KType sig k)` is a count of depth-`k` types, never a
complexity bound, and it grows with `k` for no gain.

**Open: obligation (ii), the Hit-level realization, in two halves.** Each has its source;
neither has a cost figure, and this record states that none exists.

1. **The soundness half (object → model) — the run layer's phase 2.** A Hit-level realization
   theorem for the ladder model on the admissible carrier (`ladderModel` over `ladderFrameAdm`,
   `LadderModel.lean`; `ladderFrame` itself has no instances, `no_fwd`/`no_bwd_of_idle`), per
   ladder cell, under run-layer consistency conditions analogous to `Cons`. The obstacle is
   precise: ladder states `(q, c, n)` with small `c` realize PROPER
   subsets of the types realized at large `c` — in `Node`, `pre 0` reads `⊡Xp` where
   `pre (k+1)` reads `¬⊡Xp` — so cells are indexed by `(q, deadline class)`, not by `q`, and the
   Hit-level per-cell hypothesis must be stated at ladder states. The stabilization of realized
   type sets in the counter pair `(c, n)` past a bound syntactic in `φ` — phase 2's FIRST
   statement — is REFUTED by the twelfth wired probe (`ladder-cell-refutation.lean`) in both the
   exhibited-bound and `∃ B` forms: the gap `n - c` between the two counters is observable, so
   bounding each counter bounds nothing that the cells depend on. Phase 2 is therefore
   `[BLOCKED]`, as this record's own contingency prescribes — never a finite-fibre retreat — and
   has no cost figure; a candidate carrying a third clipped coordinate for the gap `n - c` is
   REFUTED in turn, uniformly in the clip bound, by the fourteenth wired probe
   (`ladder-cell-index-obstructions.lean`): a pending region's first idle state sits at distance
   exactly `c + 1`, where the countdown's PARITY is observable, and the witnessing pair carries
   equal next-deadlines with both gaps saturating the clip, so the countdown coordinate is what
   fails and the gap coordinate is retained rather than displaced. The positive factorization
   lemma — for that candidate, for the residue-carrying one the same probe exhibits (REFUTED at
   BOTH of its object-exhibited parameters by the fifteenth wired probe
   `ladder-residue-index-refutation.lean`: the threshold must be formula-derived and the modulus
   must be a multiple of the period of every letter-definable sub-object), or for any other
   index — is OPEN
   and claimed nowhere; the admissible carrier is landed BESIDE
   `ladderFrame` (`LadderModel.lean`:
   `Adm`, `LadderState`, `RladAdm`, `ladderFrameAdm`, `ladderModel`), and the successor
   statement is open. Which cell a ladder state has — a computable index in place of the
   refuted `Q × Fin (B+1) × Fin (B+1)` — is an open sub-problem: no index is claimed in any
   shape, while the SET of cells stays finite and bounded (`anchorCells_finite`,
   `anchorCells_ncard_le`). That sub-problem is the hypothesis of the realization theorem
   itself, not a side question: any per-cell object must carry a SET of types per ladder state
   (saturation, HWZ Def. 12), and a finite object can do so only through a finite index of those
   states; a per-state labelling instead forces `ψ ↔ ⊡ψ` by the `stab` clause alone, with no
   `Presented` or `nowUnique` hypothesis — the eighth probe's collapse is the clause's own. The
   `box`/`stab` acceptance clause presupposes the index too (`stab_mem_tpOf_iff` is per cell), so
   no `LadderCons` is stated. What is settled: the ladder's structural liveness is forward-only
   (thirteenth wired probe, `gPast_isPath`), so such a bundle replaces `ulive` and keeps `slive`.
   The hypothesis must be Hit-level or product-level per cell
   (`HitPresented`, family-triple SETS, `hit-presented-model-a.lean`) and
   **never** trace-level `Presented`: the eighth probe's `stab_iff_of_presented_nowUnique` shows
   that at a `Presented` seam whose presentation marks at most one `now` state (exactly
   `Cons.nowUnique`, which (S) found necessary) every closure formula satisfies `ψ ↔ ⊡ψ`, so no
   `⊡`-refutation such as `Fp → ⊡Fp` is ever witnessed there, independent of width.
2. **The completeness half (model → object) — the run layer's phase 3, (C)'s general row:
   LANDED.** For every regular `ℤ`-model `M`, seam `(τ, t)`, formula `φ` and depth `1 ≤ k`, a
   finite labelled presentation `(Q, lab, step)` with `Fintype.card Q ≤ sizeBound φ k`, such
   that `HitCl M τ t φ k = ↑(hitOf lab step (clNow φ) k)` — `exists_hitPresented`
   (`HitComplete.lean`), with the count exhibited (the (C) row above). `Probe735.not_presented`
   still refutes the trace-level version, which is why the theorem is at the Hit level;
   `Probe745.hitPresented_modelA` and `Probe759.hitPresented_node` stay as the two fixture
   exhibitions. The run layer may now consume it at any seam; what remains open in (ii) is the
   soundness half alone.

Obligation (iii), the presentation-size bound `kTypeOf_listSeg_replicate_eventually_periodic`,
is proved in `Compose.lean` with its bounded form (see "The bound: exhibited on the fixture, as
a count" above): the block-length obligation is discharged for every `k`, with no `k` chosen
there — the choice `k = 1` is the run layer's own, recorded above.

**What the lift would deliver even with the run layer, and what it would not.** Without (iii),
a landed composition theorem would read `¬ PlusValidZTime φ ↔ ∃ object, …` over an UNBOUNDED
run layer — at best semi-decidable — and NOT `Decidable (PlusValidZTime φ)`. So nothing in
this round, and nothing a successor could assemble from it without (iii), states a decidability
result; `Decidable (PlusValidZTime φ)` appears nowhere in `AnchorLayer.lean`, the aggregator, the
probe, the pins or this README except in sentences saying so.

**(S) is untouched.** `presented_modelOf` is a correct soundness statement for `box`/`stab`-free
`φ` at one seam under `Cons`; the eighth probe says only that its frame SHAPE cannot be the whole
soundness half of a lift for `box`/`stab`-bearing L⁺, and that its realization hypothesis cannot
witness a `⊡`-refutation. Nothing is weakened, retired or re-proved; both (S) theorems and
every earlier probe stay exactly as they are.

**What this round does not establish.** No negative decidability result: the verdict is that
THIS construction and THIS hypothesis do not deliver the lift, not that none exists. Nothing
about `⊡(Pp)`: the fixtures of this collection are forward-only and there is still no backward
Bool-fixture bridge (`Probe719Backward.pastStab_iff_allBwdPathsMeet` on the asymmetric fixture
remains the only backward result). Nothing about `HitPresented` beyond its being the hypothesis
the run layer may use. No complexity bound. No finite-fibre or finite-width assumption on any
model anywhere — `anchorCons_anchorCells` carries none, and `not_finite_width_fmp` is the reason
the run layer's frame must have infinite-width slices. And nothing composes per-seam checks
into a model-wide witness: that is the run layer, and it is blocked, not open-ended.

**Successor.** Phase 2 of the run layer — the soundness half of obligation (ii) — is its own
record, with its first statement fixed above (the stabilization lemma in the deadline counter),
never a phase appended to this one; phase 3, (C)'s general row, is landed in `HitComplete.lean`. The semi-decidable statement above needs no dependency on the bound record, and none is
claimed.

**The obstruction has a literature description.** The quasimodel-realisation step of
Hodkinson–Wolter–Zakharyaschev 2000, *Decidable fragments of first-order temporal logics*
(Definition 12, Theorem 14 ⇐), and of Gabbay–Kurucz–Wolter–Zakharyaschev 2003,
*Many-Dimensional Modal Logics* (Theorem 13.6, the Chapter 6 quasimodels combined with the
Chapter 11 monadic second-order embeddings), presupposes a freely chosen state function `f`
and run set `R`: a quasimodel is a pair `⟨f, R⟩`, and HWZ Remark 13 (PDF p. 11) makes the run
choice free in both — any superset of a quasimodel's run set is again one, so `⟨f, Ω_f⟩` with
ALL runs may always be taken. In this semantics neither choice exists. The quasistate at every
time is the type set realised by the history set, and by shift closure it is the SAME set at
every time (`cellAt_eq_cellAt`, `AnchorLayer.lean`); and the runs are the task-respecting
paths of ONE time-invariant relation (`mem_HF_iff_adjacent`, `Semantics/IntNormalForm.lean`),
closed under splicing (`seamOmegaEquiv`) and under limits of chains (`blc_plusValid`), whose
states carry both the atoms and every `stab` formula (`stab_state_only`,
`PlusLanguage/PlusTruth.lean`). A run set that is the path set of a frame cannot be chosen
maximal, pruned, or chosen at all; that is the condition under which published quasimodel
realisation stops applying, and it is exactly what (W)'s soundness half is about.

**The CONSTRUCTION direction, and what it costs to state.** The converse — build a model FROM a
certified set — is the direction every published quasimodel proof actually carries, and
`LadderRealize.lean`'s `## The CONSTRUCTION half's carrier, frame and model` section lands three
of its four components over an arbitrary set carrying `certAdmK` as an EXPLICIT hypothesis (never
`Dmax`, whose `certStabK` and `certBoxK` are open): the carrier `ConKey`, the frame `conFrame`
whose seriality is discharged from condition (2) alone, the valuation `conModel`, and the
coverage conjunct `conKeyMap_covers`. The truth lemma is NOT landed and nothing is claimed under
`ladderConstruct`. Two compiled facts fix the shape. The carrier may not carry a closure type:
`cellAt_subsingleton_of_det` makes the cells of a two-sided deterministic frame of this scheme
subsingletons, so `fibre_subsingleton_of_det_cell_eq` turns the target cell equation at such a
frame into the claim that the fibre is a singleton — which is what rules out the runs-with-shift
carrier the literature's `W × R` suggests, the S5 dimension there being a separate coordinate
rather than the branching of histories through one state. And the remaining content is a tension
between two key-level relations: the weak `conStep` is serial but its paths need not lift into
the certified set, while the uniform `conStepStrong` lifts and refines it (`conStep_of_strong`)
but asks a seriality `certBiInfK` does not give. The constructed model's slice is FINITE, so its
width is finite: a property of the output rather than an assumption on an input, recorded here
rather than repaired.

## Evidence

The substrate this interface sits on is exercised by two wired evidence probes
(`specs/evidence/seam-gluing-ray-product/ktype-summary-substrate-probe.lean` and
`specs/evidence/seam-gluing-ray-product/stab-depth-two-probe.lean`; see the
[`KTypeSummary/` README](../../WeakCanonical/KTypeSummary/README.md) for what each establishes).
Neither inhabits `Presents`. A third wired probe,
`specs/evidence/seam-gluing-ray-product/presents-is-seam-decidedness.lean`, holds the
obstruction in place: on the E2 fixture (transcribed) the seam `(stayA c t, t)` is undecided on
`Fp` (`seam_undecided`), so no `Presents` inhabitant exists there for any `sig`, `k`, `T`, `S`
(`no_presents_on_fixture`, by the library's `seamDecided_of_presents`). It cites
`exists_presents_iff`, `plusStab_iff_forall_hit` and `presentsMulti_seamTrace` and re-proves
none of them.

A fourth wired probe, `specs/evidence/seam-gluing-ray-product/quasistate-does-not-determine-hit.lean`,
is the B2b verdict: two regular three-state `ℤ`-frame models (`a→a, a→b, b→b, d→d, d→b` and the
same graph without `a→b`; `p` at `b`; closure `{p, Fp}`) have equal per-time quasistates
`{∅, {Fp}, {p, Fp}}` (`quasiState_A_eq_B`) and equal consecutive-type relations
(`pairRel_A_eq_B`) at every time, yet the seam `(stayA, t)` satisfies `⊡¬Fp` in one and refutes
it in the other (`stab_notFp_B`, `stab_notFp_A`), so by `plusStab_iff_forall_hit` at `k = 1`
their `Hit` sets differ (`hit_ne`; headline `quasistate_does_not_determine_hit`). HWZ 2000 Defs
10-12 transcribed without the product repair cannot determine `Hit`; the realization hypothesis
must be the trace-set equality `Presented`. Forward-only (`¬Fp`); `[Finite W]` on the slice is the
counterexample's licence.

A fifth wired probe, `specs/evidence/seam-gluing-ray-product/presented-not-complete.lean`, is the
verdict's carrier: on the same model A at the seam `(t, a)` with `φ := Fp`, `Presented` fails for
**every** finite `Q`, `lab`, `step` (headline `Probe735.not_presented`, axiom profile
`[propext, Classical.choice, Quot.sound]`), by pumping a repeated run state against the `untl`
run condition (`pump_isRun`, stated over an arbitrary finite presentation, is the only part that
does not mention the fixture). It cites `Presented`, `clTrace_localRun`, `plusStab_iff_omega` and
`seamOmegaEquiv` and re-proves none of them. Forward-only; `[Finite W]` on the slice is the
fixture's licence; nothing about `HitPresented`, whose satisfiability on model A it leaves OPEN and
which the sixth probe below then establishes on that same fixture — the two hold side by side,
and nothing in the sixth weakens or retires this one.

A sixth wired probe, `specs/evidence/seam-gluing-ray-product/hit-presented-model-a.lean`, is
requirement (C)'s **satisfiability** half: on that same model A, at that same seam `(t, a)` of
`stayA`, with that same `φ := Fp`, the Hit-level hypothesis `HitPresented` **holds** at every depth
`k ≥ 1` (headline `Probe745.hitPresented_modelA`, axiom profile
`[propext, Classical.choice, Quot.sound]`). Three steps: `RA` is rigid, so every step path through
the seam is the constant `a`-path or an `a`-then-`b` jump with jump time `≥ t` (`path_classify`,
restated for the seam's splices as `splice_classify`); `hitCl_eq_truncated` replaces the infinite
ray index by a finite window; and a two-gadget presentation `QA`/`labOf`/`stepOf` has anchored runs
realizing exactly that window (`runTrace_mem_of_isRun`, `exists_isRun_runTrace`). The bridge is
`mem_hitOf_iff`, which meets `familyTriples` at `InFamily` with the trace as the only differing
argument — nothing in the proof compares trace SETS, which is why the fifth probe's refutation does
not reach it. It cites `HitPresented`, `hitCl_eq_iUnion`, `mem_hitOf_iff`, `plusStab_iff_omega`,
`seamOmegaEquiv` and `ofSlicedStep_isRegular` and re-proves none of them. The presentation is
deliberately **not** `Presented`. **The size, exhibited as a count**: `presentationSize k =
Nat.card (KType (clSig Fp) k)` is written into the headline (see "The bound: exhibited on the
fixture, as a count" above); not a complexity bound of any kind. Forward-only;
`⊡(P p)` untouched; `Decidable (PlusValidZTime φ)` not stated in any form; one fixture, one seam,
one `φ`.

A seventh wired probe, `specs/evidence/seam-gluing-ray-product/b2b-frame-constructor-branching.lean`,
holds requirement (S)'s **carried prerequisite measurement** permanently, after (S) itself landed
without needing it. Positively: `fib_finite_of_finBranch` proves every `TaskFrame.Fib` of
`ofSlicedStepRel` finite from two-sided finite branching (`FwdFinBranch`, `BwdFinBranch`) with
**no carrier hypothesis**, through the `n`-step image and preimage bounds `iterS_fwd_finite` and
`iterS_bwd_finite`; `saturation_of_finBranch` reaches `Saturation` from it by citing
`TaskFrame.saturation_of_fib_finite`; and `shift_saturation` exhibits `Saturation` on
`ofSlicedStepRel Rshift` whose slice `ℤ` is infinite (`shift_slice_infinite`) — so the
`[Finite W]` of `SlicedFrame.lean`'s route is not necessary for the conclusion. Negatively, and
this is the load-bearing half: two-sidedness cannot be dropped, because the reflection convention
makes the fibre at negative durations a **preimage** and finiteness is not converse-stable.
`Rbad` (countdown by one, reset to `0` from any level) has finite forward branching (`Rbad_fwd`),
an infinite backward preimage at the reset target (`Rbad_bwd_infinite`) and an outright infinite
`d = -1` fibre (`Rbad_fib_infinite`); its mirror `Rok` (countdown by one, fresh deadline only
from `0`) has finite backward branching (`Rok_bwd`) and infinite forward branching at the
commitment state (`Rok_fwd_infinite`). A commitment encoding of the kind liveness wants is
therefore refuted as a repair shape in both orientations. It cites `ofSlicedStepRel`,
`TaskFrame.Fib` and `TaskFrame.saturation_of_fib_finite` and re-proves none of them. It retires
nothing in `SlicedFrame.lean` or `TaskFrame.lean`, both of which are untouched: the successor it
scopes is a **parallel** constructor, never an in-place generalization.

An eighth wired probe, `specs/evidence/seam-gluing-ray-product/w-soundness-shape-refuted.lean`,
is requirement (W)'s **run-layer verdict**: requirement (S)'s construction `modelOf` cannot be the
soundness half of (W) for `box`/`stab`-bearing L⁺, on two independent axes, with no fixture —
both halves are stated over every finite presentation and every regular `ℤ`-frame. WIDTH:
`frameOf` is `ofSlicedStep` on the presentation's finite `Q`, so the library's
`no_finite_width_sat` applies verbatim and every `Cons` model validates `Φ.neg`
(`Probe747.modelOf_sat_neg_Φ`), a `ℤ`-time non-validity (`not_plusValidZTime_neg_Φ`); the gap
is `modelOf_incomplete`, and no clause added to `Cons` closes it. COLLAPSE: at any `Presented`
seam whose presentation marks at most one `now` state (`Cons.nowUnique`), every closure formula
satisfies `ψ ↔ ⊡ψ` (`stab_iff_of_presented_nowUnique`, through `exists_spliced_eq` off
`seamOmegaEquiv` and `presented_letter_at_seam`), so no `⊡`-refutation of a closure formula is
ever witnessed there, independent of width. Every declaration carries
`[propext, Classical.choice, Quot.sound]`. It cites `no_finite_width_sat`,
`not_plusValidZTime_neg_Φ`, `Presented`, `clTrace_letter`, `seamOmegaEquiv` and `Cons` and
re-proves none of them. (S) is untouched (`presented_modelOf` is correct for `box`/`stab`-free
`φ` at one seam); nothing is a negative decidability result; forward-only; nothing about
`HitPresented`; `Decidable (PlusValidZTime φ)` not stated in any form.

A ninth wired probe, `specs/evidence/seam-gluing-ray-product/deadline-ladder-branching.lean`,
is requirement (W)'s **frame-scheme design verdict**, gate-compiled: the deadline ladder of
`RunLayer.lean` has two-sided finite branching for EVERY finite object
(`Probe750.ladder_fwd`, `ladder_bwd`) and an infinite slice (`ladder_slice_infinite`), and the
frame it yields is regular (`ladder_isRegular`), so the seventh probe's positive half applies
to it unchanged; and the bounded-deadline encoding has the FINITE carrier
`Q × Fin (N + 1) × Fin (N + 1)` (`capped_carrier_finite`), the finite-width shape
`not_finite_width_fmp` refutes. Every declaration carries
`[propext, Classical.choice, Quot.sound]`. It cites `Rlad_fwd`, `Rlad_bwd`,
`Rlad_slice_infinite` and `ladderFrame_isRegular` and re-proves none of them. What it does not
say: nothing about realization (the run layer's phase 2, open), nothing about `HitPresented`,
nothing about `⊡(Pp)` (forward-only); seriality is the object's `fwd`/`bwd` hypotheses; no
complexity bound; `Decidable (PlusValidZTime φ)` not stated in any form.

A tenth wired probe, `specs/evidence/seam-gluing-ray-product/node-cell-stabilization.lean`,
is the run layer's phase-2 first statement on the one-region fixture, gate-compiled: on
`NoFiniteWidth.M` with its own witness `Φ`, the realized cells `cellAt` of `AnchorLayer.lean`
stabilize past pre-index 1 (`Probe758.preCell_stable`), differ between `pre 0` and `pre 1`
(`preCell_zero_ne`, the deadline index is real), and ignore the thread index
(`postCell_stable`), every theorem at `[propext, Classical.choice, Quot.sound]`, citing the
fixture and re-proving nothing — forward-only, with no bound of any kind claimed and no
finiteness added, and with the separator between `pre 0` and `pre 1` being the non-`⊡`
letter `Xp` as set membership of a second type, not a `⊡`-letter.

An eleventh wired probe, `specs/evidence/seam-gluing-ray-product/hit-presented-node.lean`,
is the first Hit-level positive on a ⊡-bearing alphabet and on an infinite-width model,
gate-compiled: on `NoFiniteWidth.M` with its own witness `Φ`, `HitPresented` holds at every
pre-seam `(t, pre m)` at every depth `k ≥ 1` (`Probe759.hitPresented_node`), for a presentation
of `windowN m k + 5` states with `windowN m k = min m (Nat.card (KType (clSig Φ) k) + 1)`
exhibited in the statement and bounded uniformly over every seam (`card_QN_le`) — a count of
states and of depth-`k` types, not a complexity bound — by the model-A truncation route (seam
classification in place of rigidity; the fixture's four relative-position letter classes;
`familyTriples_subset_deleteRun`), every theorem at `[propext, Classical.choice, Quot.sound]`,
citing the fixture and re-proving nothing. The negative headline is false on `Node`: its seam
fibres are finite (`m + 1` histories through `(t, pre m)`), so trace-level `Presented` holds
there too (`presented_node`), and the probe therefore does not test the truncation argument's
necessity. No Hit-level falsifier for (C) exists, on this or any regular `ℤ`-model: the general
row is a theorem (`exists_hitPresented`, `HitComplete.lean`), and the two probes stay as the
fixture exhibitions with their own counts. Forward-only; no finiteness added; nothing about
`⊡(Pp)` or `PlusValidZTime`.

A twelfth wired probe, `specs/evidence/seam-gluing-ray-product/ladder-cell-refutation.lean`, is
the run layer's phase-2 first statement over a general finite object, gate-compiled, and its
verdict is NEGATIVE in both halves. First, `ladderFrame`'s seriality hypotheses are unsatisfiable
on the full carrier `Q × ℕ × ℕ` for every object (`no_fwd`, `no_bwd_of_idle` — the idle state
`(q, 1, 0)` has neither successor nor predecessor under `Rlad`'s source clause), so the
admissibility set `Adm` is a restriction of the carrier (`{c | pend q = false → c = 0}`, realized
on the subtype `{x // x.2.1 ∈ Adm pend x.1}` with two-sided finite branching pulled back along
`Subtype.val` — one of several equally valid shapes, in-place repair of `ladderFrame` among
them) and `ladderFrame` has no instances. That general block — the two unsatisfiability
theorems, `Adm`, `LadderState`, `RladAdm`, `ladderFrameAdm`, `ladderModel` — is landed in the
library (`LadderModel.lean`, C14-pinned) and the probe imports and cites it rather than
redefining it; the fixture and the fixture-bound refutation are the probe's own, stated over the
landed `ladderModel`. Second, on that carrier the realized cells `cellAt` do
NOT stabilize in the pair of counters `(c, n)` past any bound: on the two-state object with
`p U (r ∧ X(p ∧ X r))`, `X χ := ⊥ U χ`, the cells at `(a, B, B+1)` and `(a, B, B+2)` differ for
every `B` (`cell_ne`; `exhibited_form_refuted`, `exists_form_refuted`), because the current
deadline fixes the region's end and `Count`'s idle clause `c' = n` exposes the gap `n - c`. Every
theorem at `[propext, Classical.choice, Quot.sound]` or less, citing `RunLayer.lean`,
`LadderModel.lean` and `AnchorLayer.lean` and re-proving nothing — forward-only witness for a direction-neutral
statement, no bound of any kind claimed, no finiteness added, `anchorCells_finite` and
`anchorCells_ncard_le` untouched; what is refuted is the claimed computable index
`Q × Fin (B+1) × Fin (B+1)` of which cell a ladder state has, and the successor design is not
chosen here.

A thirteenth wired probe, `specs/evidence/seam-gluing-ray-product/ladder-liveness-forward-only.lean`,
accompanies the run layer's phase-2 soundness half — the realization theorem per ladder cell —
which is `[BLOCKED]` on the open index of which cell a ladder state has: every per-cell soundness
statement for `ladderModel` presupposes a finite index of ladder states (the twelfth probe's
`cell_ne` defeats the saturation of every `Q`-indexed candidate; `Count`'s pending clause makes
the `Q`-projection of a seam fibre a proper subset of the `Q`-runs, so a presentation over `Q`
over-approximates `HitCl` even for `box`/`stab`-free `φ`; and a labelling that reads closure
truth off the world state alone forces `ψ ↔ ⊡ψ` by the `stab` clause, the eighth probe's collapse
with both of its hypotheses dropped), and the `box`/`stab` acceptance clause presupposes that
same index (`stab_mem_tpOf_iff` is per cell). What the probe settles, machine-checked on the
two-state object: an admissible ladder history can be pending at every past time
(`gPast_isPath`, `gPast_pending_past`, `gPast_count` — backward, `Count true true` grows the
countdown without bound), so the ladder's structural liveness is forward-only: a ladder
consistency bundle may replace `Cons`'s `ulive` by it and must keep `slive`. `gPast_isPath` at
`[propext, Classical.choice, Quot.sound]`, the other two at `[propext, Quot.sound]`, citing
`LadderModel.lean` and re-proving nothing — no bound of any kind, no finiteness, nothing about
`HitPresented` or `PlusValidZTime`, no library module, `anchorCells_finite` and
`anchorCells_ncard_le` untouched, the successor design not chosen here.

A fourteenth wired probe, `specs/evidence/seam-gluing-ray-product/ladder-cell-index-obstructions.lean`,
carries the cell-index sub-problem that phase 2's soundness half is `[BLOCKED]` on. It establishes
three things and withholds a fourth. **The clipped-coordinate index family is refuted at a SECOND,
independent coordinate**, the countdown's PARITY: `Count true true` admits no early discharge, so
a pending region's first idle state sits at distance exactly `c + 1`, and the step relation is
independent of the counters, so it may alternate a tag per pending step and copy it onto the
ending idle state, where an atom under `p U (r ∧ a)` reads `c mod 2` at a distance no bound on `c`
reaches (`truth_phiP`, `cell_succ_ne` at every `c` and `n` with `n` held FIXED, `index_collide`,
`ladderIndex_not_factoring` at every clip bound, `exhibited_form_refuted`, `exists_form_refuted`).
The witnessing pair carries EQUAL next-deadlines and two gaps that both saturate the clip, so the
gap coordinate is not what fails — and the gap mechanism of the twelfth probe (`cell_ne`) is real
and NOT displaced, which is why the gap coordinate is retained rather than dropped; the earlier
one-part gate was sound and non-vacuous (`gate_separates` for a clip bound of at least two,
`gate_collides_below_two` below it, so the clip bound comes from the formula and never from the
counters) and the candidate it certified is refuted at a coordinate it never touched. **The
bounded-carrier alternative is closed as a general route** (`bounded_ladder_finite`,
`finBranch_eq_ofSlicedStep` by `rfl`, `bounded_width_validates_Phi_neg`, `Phi_neg_not_valid`): its
premise fails at the non-validity the finite-width limitation exhibits, with the narrow carve-out
that a bounded carrier remains available for a target that does have a finite-width countermodel,
per `not_finite_width_fmp`'s own disclaimer. **What IS landed positively** is a GATED
six-coordinate residue-carrying candidate (`ladderIndexRes`, separating both known pairs through
`gate_gap_separates` and `gate_parity_separates` at a symbolic modulus via `consec_mod_ne`) and an
EXHIBITED threshold and period for its two residue coordinates (`iterate_eventually_periodic`,
`reachN_eventually_periodic`), together with a third gate run one region out and in the past
direction (`second_region_any_length`, `second_region_end_tag_achievable`,
`second_region_sets_agree`, `gap_step_le`, `gap_region_start_le_one`, `gap_le_region_age`,
`region_start_beyond_depth`, `clipped_gap_collides`, `third_region_any_length`) which found no
refutation on three enumerated attempts — three attempts on one fixture family, which is not a
proof that the general factorization holds. **The fourth thing is withheld**: no index is claimed
to factor the cells in any shape and the positive factorization lemma is OPEN and stated nowhere;
no seventh coordinate; no bound of any kind and no complexity bound, every quantity named being a
count; no finiteness added, with `anchorCells_finite` and `anchorCells_ncard_le` untouched, so the
SET of cells is still finite and bounded and only the computable INDEX is absent; nothing about
`HitPresented`, and `PlusValidZTime` only in the non-validity cited; no library module created and
no declaration added under `FormalSystem/`; the `box`/`stab` acceptance clause never dropped
(`stab_mem_tpOf_iff` is that cell's bit); and the successor design not chosen here — if the gated
candidate falls in turn, the direction on record is a different presentation of a cell, a
set-valued per-state datum over a quotient, and not a wider tuple. `[propext,
Classical.choice, Quot.sound]` on the refutation, bounded-carrier, periodicity and third-gate
theorems, `[propext, Quot.sound]` on `gate_gap_separates`, `gap_le_region_age`,
`region_start_beyond_depth`, `gate_separates` and `gate_collides_below_two`, citing
`LadderModel.lean` and `NoFiniteWidth.lean` and re-proving nothing.

A fifteenth wired probe, `specs/evidence/seam-gluing-ray-product/ladder-residue-index-refutation.lean`,
settles the residue-carrying six-coordinate candidate the fourteenth probe gated — thresholds and
residues on both counters beside the clipped gap, with its threshold and period EXHIBITED from the
object by `reachN_eventually_periodic` and only the clip bound from the formula — negatively, at
BOTH object-exhibited parameters, uniformly in the clip bound, by two mechanisms that sit inside
the FIRST region where the countdown is deterministic (neither uses `Drift`; `n` is held equal
across every witnessing pair, so the fourteenth probe's "no achievable window" finding at the
second region is respected rather than argued around). **The threshold cannot be object-derived**:
`PlusTruthAt`'s `untl` clause is strict in both bounds, so over integer time `⊥ U χ` is `χ` at
the next instant and `T + 1` nested nexts ending in the idle letter read whether the forced first
idle state sits at distance exactly `T + 1` (`truth_nextPow`, with the forced run generic in the
object: `pending_run_gen`, `idle_at_gen`); `(q, T, n)` against `(q, T + (P+1), n)` at
`n = T + (P+1) + B` collides in the index for EVERY `(T, P, B)` while that formula separates the
cells (`depth_collision`, `cell_depth_ne`, `object_only_parameters_refuted`). **The exhibited
period is the period of the wrong object**: `reachStep` iterates the FULL step relation, and a
formula that forbids a letter restricts the object to a sub-object with a different period — on
the object whose pending part is a 3-cycle and a 2-cycle sharing `a`, the reach sets are constant
from threshold 4 (`reach5_eventually_constant`, period 1, minimal) while every `d`-free pending
walk from `a` to `a` has length `0 mod 3` (`walk_mod3`), so every modulus coprime to 3 — both
readings of the exhibited period 1, moduli 1 and 2 — collides on a pair that
`p U (r ∧ ℓ_a)` with `⊤ U ℓ_d` in the closure separates (`period_collision`, `cell5_ne`,
`reach_period_refuted`). The refined parameter-origin rule — the threshold at least the formula's
`untl`-nesting depth, the modulus a multiple of the period of every letter-definable sub-object —
is NECESSARY and asserted as nothing more. **What is proved positively is fixture-level only**: on
the two-state object every history through a pending state is forced onto one object path
(`qp_forced_path`), truth of a box/stab-free formula depends only on that projection
(`qp_truth_of_objPath`), truth at `0` is periodic in the countdown with period 2 above a
formula-derived threshold `thr` — two per `untl` nesting, none per `snce` — (`qp_type_shift`), so
the cell at a pending state is a singleton (`cellAt_eq_singleton`) and
`qp_cell_eq_of_depth_parity` identifies the cells at countdowns of equal parity at or above
`thr φ`, for ANY next deadlines; this rests on the forced path the general object lacks and is
NOT the factorization lemma. **What is withheld**: no factorization lemma in any shape — the
positive lemma for parameters depending on the object and the formula jointly is OPEN and stated
nowhere, with its proof obligations named in the probe header; no seventh coordinate; the three
earlier negatives untouched; no bound of any kind, every quantity a count; no finiteness added,
`anchorCells_finite` and `anchorCells_ncard_le` untouched; nothing about `HitPresented`, no
mention of `PlusValidZTime`; no library declaration; the acceptance clause never dropped; the
successor design not chosen. `[propext, Classical.choice, Quot.sound]` on the cell theorems,
`reach5_eventually_constant`, `period_collision` and the fixture-level theorems;
`[propext, Quot.sound]` on `truth_nextPow`, `depth_collision`, `pending_run_gen`, `idle_at_gen`
and `walk_mod3`; citing `LadderModel.lean` and re-proving nothing.

**The successor design is chosen.** The presentation of a ladder cell is a set-valued per-state
datum over a quotient, in the sharpened form: `D`, the MAXIMUM `certAdm`-certified subset of the
finite carrier `Q × ClType φ × K`, where `K` is a quotient of the two ladder counters; the
realization theorem is the fibre equation (`cellAt` at `(q, c, n)` equals the fibre of `D` at
`(q, κ(c, n))`), and the factorization lemma for `K` is its corollary, never its hypothesis. A
parameter-coupled tuple index stated alone is dominated on every obligation, incomplete as a
presentation (a tuple class carries no types) and barred by the refutation record; no tuple index
is stated at any parameters. `K`'s SHAPE — threshold, residue and clipped gap on each counter — is
forced by the compiled mechanisms, but `K` is a coordinate of the carrier `D` is computed over, not
an index: its parameters are outputs of the first repeat of the realizable-type iteration on the
object-closure product, which is the candidate the sixteenth probe's header reserved. The wired
probe `specs/evidence/seam-gluing-ray-product/no-pending-forever-ray.lean` settles what the
decision needed: `Count true true` forces `c' + 1 = c` along every pending step
(`count_pending_step`), so a forward `Rlad` ray reaches an idle state within `c₀ + 1` steps
(`exists_idle_of_rlad_ray`; contrapositive `no_rlad_ray_of_pending_forever`); since the
certificate rounds' `coh`/`cohBi` require `pend` at BOTH endpoints, every certified
`Realizes`-chain is region-interior and is the object projection of no `Rlad` history —
label-level sufficiency transfers to a region segment, and the ladder datum still owes the
composition of regions through idle runs under `Count`/`Drift`. Exactness: `Real` is itself
certified given constancy of `cellAt` on `K`-classes and every certified set lies inside it, so
the maximum certified set is `Real`, computable by enumeration (a count of candidates), and Route A
is not entered. The open problem on which the choice rests, stated by name: the COUNTER-LIFT
LEMMA — soundness (every `RladAdm` history projects to a class-level chain) and completeness
(every class-level chain lifts), obligations (2) and (3) jointly, with two hazards (gap shift
under pumping; short idle runs cannot absorb a deadline shift) as its first gates; its failure
would close the ladder route on evidence, because both presentations need it. Withheld: no
`LadderCons`, `ladderRealized` or factorization lemma stated; no bound of any kind, every quantity
a count; no finiteness added, `anchorCells_finite` and `anchorCells_ncard_le` untouched; the
acceptance clause never dropped; `certStab` per `(q, κ)` is a rebuild the successor owes; gate 8
still SIDESTEPPED. Axioms `[propext]` on `count_pending_step`, `[propext, Quot.sound]` on the
other two, citing `RunLayer.lean` and re-proving nothing.

**The counter-lift gate table is compiled, and it collides.** The wired probe
`specs/evidence/seam-gluing-ray-product/counter-lift-gates.lean` runs that open problem as a gate
table on a 4-cycle fixture of product period four, before any sufficiency attempt. Its arithmetic
layer compiles the three derived items as theorems: the forward window (`forward_window`), the
backward constraint (`backward_constraint`) and region doubling (`region_doubling`, attained at
`j = 1` by `doubling_attained`, iterated by `iter_doubling`). Its statement-shape result is
`no_positionwise_lift`: for EVERY finite counter quotient `K`, every `κ`, and every relation on
`Bool × K` that is sound for the two-state object, some chain is the projection of no history —
so the completeness clause cannot be positionwise for any `K`, and must be allowed to PUMP. The
gate rows then separate where separation was expected — `gate1_cell_ne`, `gate2_cell_ne`,
`gate9_sep_cell_ne`, `short_idle_cell_ne` (with `short_idle_shape_collides` and
`short_idle_threshold_refuted`) — and COLLIDE at both decision gates: `gate9_col_cell_eq` and
`gap_shift_cell_eq`, each an EQUALITY of `cellAt` values with non-vacuity witnessed on both sides
before the equality. The gap-shift row's absorber is exhibited as its own theorem, `absorber4`:
the past ray is an `Rlad` ray for every countdown at fixed region age, letters and idle-run
shape, because the previous region — which the closure does not pin — may be pending forever with
its deadline unconstrained. The pin lemma's lift half compiles too: `drift_extension_of_pins` (a
pairwise `1`-Lipschitz-compatible family of pins extends to a `Drift` deadline function through
every pin) and `exists_rlad_hist_of_walk` (an object walk with its forced countdown lifts to a
full `Rlad` history), which is where the lift's counter argument ends — what remains for the
completeness clause is a chain-replacement argument on the type sequence, which no counter bound
supplies. Consequence for the record: neither decision gate exhibited a seventh mechanism, so the
ladder route is NOT closed, and the counter-lift lemma's two halves are LICENSED in pumping form
with `K`'s parameters as outputs of the first repeat of the realizable-type iteration. Licensed
is not proved: soundness, the pumping completeness clause and the parameter sources remain
statements a successor record must discharge, and a gate probing one coordinate certifies one
coordinate. Withheld, unchanged: no tuple index at any parameters, no seventh coordinate, no
bound of any kind (every quantity a count, including the gap-shift gate's threshold `1` and gap
`1`), no finiteness added, the acceptance clause never dropped, gate 8 still SIDESTEPPED and gate
3 CARRIED, and no Büchi or MSO lemma cited in place of a proof. Axioms
`[propext, Quot.sound]` on `iter_doubling`, `doubling_attained` and `short_idle_shape_collides`,
`[propext, Classical.choice, Quot.sound]` on every other headline theorem; no `sorryAx`, no
custom axiom, no `native_decide`.

The permanent computability witnesses are `Tests/BimodalTest/Metalogic/KTypeFinEvalTest.lean`
(imported from `Tests/BimodalTest.lean`): thirteen `#guard`s at depth 1 over `twoLetter` that
`kTypeOfFin` (on `segZ` and `listSeg`), `allPathTypes`, `hitOf`, `fwdLiveSep` and `bwdLiveSep`
evaluate, including the two-state discriminator on which `fwdLive`/`bwdLive` are `true` and
`fwdLiveSep`/`bwdLiveSep` `false`. Every number there is a witness of computability and nothing
else.
Four further `#guard`s in the same file, under "stabCheckSig on finite labelled presentations",
witness that `stabCheckSig` evaluates on two-state presentations and discriminates (`true`,
`false`, `true`, `true`); they, too, witness computability and nothing else.
Two further `#guard`s in the same file, under "`AnchorConsFin` on concrete cell sets", witness that
`decidableAnchorConsFin` evaluates on `Finset (Finset (Finset PlusFormula))` literals for
`φ := ⊡p` and discriminates: the three-cell witness `{{{⊡p, p}}, {∅}, {{p}, ∅}}` (its third cell
carrying two types at one state) is accepted and the one-cell control `{{{p}}}` is rejected on the
`stab` equation. They witness computability and non-vacuity of the CONDITIONS and nothing else —
neither says anything about a model.

## The consumer relation

The substrate is **built in `KTypeSummary/` and consumed downstream, never absorbed into the
consuming record**; this directory is the consumer-facing statement about `⊡` together with the
device that reads realized triples off a presentation, and the assembly of a decidable check is
the next consumer's. Headline axiom profiles — `plusStab_iff_seamSummary`, `exists_presents_iff`,
`plusStab_iff_forall_hit`, `plusStab_iff_presentsMulti`, `presentsMulti_seamTrace`,
`plusStab_iff_forall_hitSig`, `clTrace_localRun`, `eq_clTrace_of_localRun_anchored`,
`kTypeOf_listSeg_append_congr`, `mem_hitOf_iff`, `Presented`, `presented_localRun`,
`hit_eq_hitOf_of_presented`, `plusStab_iff_forall_hitOf_of_presented`, `HitPresented`,
`hitPresented_of_presented` — are pinned in
`Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean`, and `plusStab_iff_forall_hit`,
`plusStab_iff_forall_hitSig`, `mem_hitOf_iff` and `hit_eq_hitOf_of_presented` are additionally
pinned by C14 for their rows in `docs/theorem-index.md`.
The assembly those sentences leave to the next consumer is now made, and bounded: the per-seam
check stops at `decidableStabOfPresented`, under `Presented`, and "The verdict" above records why
no consumer can reach `PlusValidZTime` through this presentation. Its headline profiles —
`plusStab_iff_forall_run_of_presented`, `onRun_iff_live`, `stabCheck_iff_of_presented`,
`decidableStabOfPresented` — are pinned in the same harness, and the first, third and fourth are
additionally pinned by C14 for their **Conditional** rows in `docs/theorem-index.md`, as is
`hitPresented_of_presented` for its own.

## Two carried limits

1. The backward `⊡(Pp)` shape on the real formula is fixed by the asymmetric-fixture probe
   (`specs/evidence/seam-gluing-ray-product/backward-dual-asymmetric-fixture.lean`), not
   re-proved here; no backward Bool-fixture bridge exists.
2. The identification of the substrate's chain with the Ramsey core of Büchi complementation is
   a proof-level reading of cslib's `IsRegular.compl`. The further question — whether
   MSO-over-`⟨ℤ,<⟩` *reduces* to it — is now sharpened rather than left at a confidence level:
   the substrate supplies the complementation half in full (`plusStab_iff_forall_hit` needs no
   hypothesis), and the realizability half is landed as far as a presentation (`hitOf`,
   `mem_hitOf_iff`, `hit_eq_hitOf_of_presented` under `Presented`); and realizing a presentation
   by a constructed regular model — B2b, requirement (S) — is now landed for `box`/`stab`-free
   `φ` at one seam (`presented_modelOf`, `hitCl_modelOf_eq_hitOf`, `Realize.lean`). What remains
   is the `box`/`stab`-bearing fragment and the lift from one seam to validity, both of which are
   requirement (W). The exhibited undecided seam and the B2b verdict fixture are forward-only
   (`Fp`); limit 1 is unchanged, and the realization above is forward-only in the same sense —
   no backward Bool-fixture bridge was built or implied.

## Dependencies

- **Imports from**: `../../WeakCanonical/KTypeSummary.lean` (including `KTypeSummary/KTypeFin.lean`), `../../WeakCanonical/MixedSum.lean`, `FormalSystem/PlusLanguage/PlusRayFibre.lean`, `FormalSystem/PlusLanguage/Subformulas.lean`
- **Imported by**: `../../Decidability.lean` (the sibling aggregator), via `../RaySummary.lean`

## Related Documentation

- [Decidability README](../README.md)
- [`KTypeSummary/`](../../WeakCanonical/KTypeSummary/README.md) — the substrate proper
- [`PlusSlicedCertificate/`](../PlusSlicedCertificate/README.md) — the finite-width route this
  sits beside

---

*Last verified: 2026-10-13*

#### What the cell reads of the register

The next-deadline register is read by a cell in BOTH directions, and the two windows are
compiled. **Backward**, `cntAt_le_nxtAt_succ_of_idle_past` (`LadderAgree.lean`): a pending
position with an idle position in its past has countdown at most its register plus one.
**Forward**, `nxtAt_le_cntAt_add_of_next_region` (`LadderPump.lean`): the register at a position
is at most the countdown there plus the length of the next idle run plus the countdown at the
next region's start — the register's value at the first idle position after a region IS the
following region's start countdown (`cntAt_eq_nxtAt_of_idle_pend`), and the register is
`1`-Lipschitz. `kappa`'s gap coordinate clips `n - c` at `B`, so `(K4)` must make `B` dominate
what a closure formula can pin in EITHER direction: it bounds `B` by the backward exactness depth
`dBack` (the `S`-nesting), by the forward exactness depth `dFwd` (the `U`-nesting), and by `2`
(`CounterQuotient.lean`). The forty-seventh wired probe,
`specs/evidence/seam-gluing-ray-product/ladder-cell-obligation-refutation.lean`, is why the
forward conjunct is there: with the gap clip bounded by `dBack` alone (frozen in the probe as
`ParamsOkPre`), a `U`-only formula of bounded `X`-depth pins the register forward below the
clip and the depth-`0` cell obligation `CellLEZeroConstOfKappaEq` is FALSE at the periodicity
fixpoint's own outputs; the probe also compiles that the two-depth `(K4)` rejects that clip and
dissolves that collision.

**The depth-`0` obligation's status.** `CellLEZeroConstOfKappaEq` is refuted at the one-depth
parameter conditions and is neither proved nor refuted under `ParamsOk`; the reserved name
`cellLE_zero_const_of_kappa_eq` is claimed by nothing. What is landed around it is the
certificate-free type-preserving pump layer of `LadderPump.lean` — deletion admissibility, the
duplication and deletion TYPE lemmas (HWZ 2000 Lemma 17 and its mirror), the type pigeonhole
and the iterated duplication — and, in `LadderChain.lean`, the realized-chain bridge (a
type-respecting block's length lies in `prodCycleLens`, hence divides `P + 1` under `(K1)`) and
the one-directional regime-A assembly: through a pending-forever path's state at countdown at
least `Tc`, the countdown rises by exactly `m · (P + 1)` with the register, the object state and
the realized stab-free type held (`exists_ladderPath_through_shifted_of_pend_past`), hence the
UPWARD cell inclusion along the common-shift chain (`cellAt_subset_of_shift_of_pend_past`).
DOWNWARD, the inclusion is landed at the cell level ON THE WITNESSING PATH under the forward-slack
regime: `exists_ladderPath_through_deleted_exact_upfirst_of_pend_past` lowers the countdown by
exactly `m · (P + 1)` with the register and the realized type held (raise by `b` copies of the
original block first, overshoot above the run of copies, delete the exact remainder inside it),
and `mem_cellAt_of_shift_of_hasForwardSlack_exact` is its cell-level reading for a path `g`
satisfying `HasForwardSlack g z (m · (P + 1)) n` — the hypotheses are exactly `n + 2 ≤ c`,
`Tc ≤ c` and that regime, with no `b²` slack term in either anchor direction; the same statements
under the regime at `m · (P + 1) + b²`, `exists_ladderPath_through_deleted_exact_of_pend_past`
and `mem_cellAt_of_shift_of_hasForwardSlack`, are corollaries.
The regime is NECESSARY — the compiled climbing-register path
(`ClimbWitness.hasForwardSlack_refuted_unconditional`) is a ladder path, pending forever into
the past, satisfying the gap and violating it — and INHABITED at every amount
(`ClimbWitness.exists_hasForwardSlack_inhabitant`, the plateau). The
open core is the two cascades on a tight chain of pins — backward on the doubling chain, forward
on its mirror — where the only candidate device, a type-respecting block SPANNING a region
start, is refuted in both directions as a consequence of the parameter conditions (the wired
probe `specs/evidence/seam-gluing-ray-product/ladder-tight-chain-regime-b.lean`). The
STATE-level downward inclusion is landed too, under an existential-over-paths
hypothesis rather than a per-path one (`ForwardSlackWitnessed`,
`cellAt_subset_of_shift_of_pend_past_rev`, `LadderCell.lean`), and with the upward inclusion it
assembles to the obligation's FORWARD-SLACK-RESTRICTED form as a theorem under a name of its own —
`cellLE_zero_const_of_kappa_eq_of_forwardSlack`, four hypotheses stronger, the reserved name
untouched. See "the forward-slack-restricted obligation" below.

**The pin layer, and what it settles about the two cascades.** `LadderPin.lean` sits beside the
pump layer, certificate-free under the same grep and importing it alone, and holds what the PINS
of a ladder path — an idle position immediately followed by a pending one — force. Its first half
is the DICHOTOMY: pending is downward closed below a pin-free position
(`idle_of_idle_of_no_pin_below`), so the past at or below such a position is either uniformly idle
or uniformly pending from some position down (`pend_past_or_idle_of_no_pin_below`), and every
pending position of a ladder path is on exactly one of the two sides the cell's replacement
argument treats separately (`pendPast_or_cntAt_le_nxtAt_succ`: a uniformly pending past — the
pin-free side, which is the hypothesis `cellAt_subset_of_shift_of_pend_past` already consumes — or
a countdown at most the register plus one, which is the backward window). Its second half is a
PIGEONHOLE over the pins rather than over the positions inside one region, so the block it
produces SPANS a pin (`exists_pinTypeBlock_of_budget_lt_pins`, with the tuple read off in the
refuted condition's own shape by `exists_spanningBlock_of_pins_below`). The hypothesis is the pin
COUNT in a window: the pigeonhole produces a spanning block AT A GIVEN OBJECT where the pins are
dense, and asserts nothing unconditionally, so it does not revive the refuted device. Beside it,
`LadderChain.lean` carries the EXPONENTIAL reading of `(K2)` the pigeonhole consumes
(`two_pow_card_prodState_le_Tc`: every admissible `T_c` dominates
`2 ^ Fintype.card (ProdState Q φ)`, because `cascadeBound` carries that power as a factor).

**`(K1)` does not constrain a spanning block's length.** This is settled, by a compiled object
rather than by argument. Both cycle-length conjuncts of `(K1)` carry `∀ i, pend (f i) = true` on
the closed walk they quantify — the walk is PENDING THROUGHOUT, which is the region-interior
restriction — and the walk a spanning block induces is idle at the index of the pin strictly
inside it; `objCycleLens` additionally bounds the length by `Fintype.card Q`, which a pigeonhole
over a pin window does not respect; and `satPeriod` is a datum of `step`, `lab` and `φ` alone,
not quantified over block lengths at all. A refuting object settles it outright: the ALTERNATING
path — idle at every even position, pending at every odd one — carries, for a stab-free atomic
closure at the periodicity fixpoint's own outputs, a type-respecting block of EVERY even length
with a pin strictly inside it, so no single modulus divides them all. (The wired probe
`specs/evidence/seam-gluing-ray-product/ladder-spanning-divisibility.lean`.) The consequence for
the depth-`0` obligation is that the DOWNWARD cell inclusion cannot be assembled from the
pigeonhole's block: the deletion mirror of the regime-A assembly demands, at the first pin above
the compared position, a register bound stronger than the `1`-Lipschitz register supplies by
exactly the amount deleted, and the tight chain has slack exactly `0` at every gap between pins.
The reserved name `cellLE_zero_const_of_kappa_eq` is therefore still claimed by nothing. What it
would need is a state-level downward inclusion, and the shape of the hypothesis that buys one is
now settled in both directions. A PER-PATH state-level regime does NOT work: the obligation
quantifies over every path through the state and concludes cell EQUALITY, and the
climbing-register path (`ClimbWitness.climb`, `LadderChain.lean`) passes through a state
satisfying every state-level hypothesis the consumer carries while violating the forward-slack
regime. An EXISTENTIAL-over-paths hypothesis does: `ForwardSlackWitnessed` (`LadderCell.lean`)
asks that every type the cell at a state realizes be realized there by SOME path with forward
slack, which the climbing path's presence among the paths through the state does not contradict,
and under it the PATH-level `mem_cellAt_of_shift_of_hasForwardSlack_exact` lifts to the STATE
level as `cellAt_subset_of_shift_of_pend_past_rev` — the landed downward cell inclusion, mirror
of the upward `cellAt_subset_of_shift_of_pend_past`, carrying no new pump and no new pin. See
"the forward-slack-restricted obligation" below for what the two inclusions assemble to and what
they do not.

**Why the hypothesis is carried rather than discharged.** Discharging `ForwardSlackWitnessed`
needs a slack-normalization lemma, and the one candidate route to it is refuted rather than
unproved. The route was to LENGTHEN the idle run between the compared position's region and the
first region start above it: the deletion's anchor clause is short in its upper direction by
exactly the deleted amount `l`, inserting `l` idle positions into that run raises the run's
length by `l` and so supplies exactly the shortfall, and `pinCompat_of_ladderPath` does not
forbid it — moving a region start farther from the compared position while holding its countdown
makes the pin demand strictly looser. That reading of the pin condition is correct and
irrelevant, because the obstruction sits one level BELOW it, in `step`. A ladder path's object
walk satisfies `step (objAt g v) (objAt g (v + 1)) = true` at every position, so an idle run of
length two requires an idle-to-idle edge in the object's own step graph, and an object admitted by
`ParamsOk` need not have one: on the two-state object with exactly that edge missing — serial in
both directions, carrying one region through the compared position with the register constantly
`0` and pending forever into its past — a path satisfies every hypothesis of the lengthening while
no ladder path on that object is idle at two consecutive positions. The idle run's length is a
datum of the object's step graph, not a parameter the construction may raise. (The standalone
prototype `idle-gap-lengthening.lean` in the task record that landed this layer, not a wired
probe.) The refutation closes from `step` alone and never reaches the type clause, so nothing in
it says whether a lengthened path, on an object that admits one, holds the realized stab-free type
at the compared position; and it refutes neither the depth-`0` obligation nor any `ParamsOk`
conjunct. What it does close is the last candidate source of slack the landed layer could have
supplied on its own. The sharpening it leaves — the lengthening is available exactly where the
object's idle states carry a reachable cycle, `tIdle` (`#idle states + 1`) being the length above
which an idle run must repeat an idle state and so become duplicable — is an OBJECT hypothesis and
not a consequence of `ParamsOk`, so assuming it would restrict the obligation rather than prove
it.

**The sharpening, TAKEN: the idle-run pump discharges the hypothesis conditionally, and its
complement is REFUTED.** `LadderIdle.lean` carries the sharpening as far as it goes and then
compiles where it stops. The positive half is `forwardSlackWitnessed_of_cell_idleRunPumpable`:
from the amount-free, run-local premise `IdleRunPumpable` — the path is pending forever into the
past at `z`, sits in the regime, and the idle run separating `z`'s region from the next carries a
block whose two ends agree in object state and in realized type — `ForwardSlackWitnessed` follows
at EVERY amount, by DUPLICATING that block rather than deleting anything, so the refuted deletion
route is not re-entered and none of `(K2)`'s `cascadeBound` is spent. The premise is not
`ParamsOk`-derivable, for the reason the paragraph above gives: `(K1)` quantifies `prodCycleLens`,
`objCycleLens` and `satPeriod`, never `idleCycleLens`. Its complement — the paths whose
intervening idle run has length exactly `1`, where no repeat block exists to pump — is not a
weaker version of the same discharge awaiting a better pumping argument. At the EVERY-AMOUNT shape
it is FALSE, settled by a compiled object rather than by argument.
`forwardSlackWitnessed_refuted_I_one` (`section IOne`) falsifies `ForwardSlackWitnessed` at amount
`4` at the state `xState = (true, 2, 0)` on `stepOr x y = x || y`: two states, serial in both
directions, no idle self-loop, hence every idle run of length exactly `1` on every ladder path.
`xState_regime` inhabits the pending-forever gap there with a concrete path, so the refutation is
not vacuous, and `not_idleRunPumpable` compiles that `IdleRunPumpable` is unsatisfiable for every
path, history and anchor on that object, so the two results cannot collide. This is the first
CELL-level refutation of `ForwardSlackWitnessed` in this development, and why the
existential-over-paths escape does not save it is structural: the amount ceiling
`hasForwardSlack_amount_le` (`LadderChain.lean`) forces `(l : ℤ) ≤ n + cntAt g z + I` whenever a
genuine next region exists, and here `I = 1` is forced by the OBJECT rather than by a choice of
path, so the ceiling binds uniformly over every path through the state — which is exactly the
escape route that stops the pin-cascade refutation at the path level.
`forwardSlackWitnessed_holds_below_ceiling` compiles the boundary as sharp: the SAME state carries
`ForwardSlackWitnessed` at every amount `l ≤ 3 = n + c + 1`, so the ceiling, and not some further
obstruction, is precisely what the `I = 1` regime refuses.

**What that refutation does NOT reach, compiled rather than left to inference.** It does not touch
the five depth-`0` cell-equality schemas recorded below. Those ask for `ForwardSlackWitnessed` at
amount `m · (P + 1)` at the HIGHER state, whose countdown is `c + m · (P + 1)`, and
`ceiling_slack_at_consumer_amount` compiles that the ceiling `l ≤ n + cntAt + I` is then satisfied
for free whenever `0 < I`. All five therefore KEEP the hypothesis for a positive reason rather
than through not having been edited: no schema signature is touched, `LadderCell.lean` is
unedited, and `certStabK`'s restatement obligation stays PROVISIONAL. The surviving frontier is
route 4 at the cell level — simultaneous multi-region shortening — recorded here and not
attempted.

**The forward-slack-restricted obligation: landed as a THEOREM, under its own name.**
`CellLEZeroConstOfKappaEqForwardSlack` (`LadderCell.lean`) is the depth-`0` obligation with FOUR
hypotheses added, all four visible in the quantifier: the EQUAL-REGISTER restriction `n = n'`; the
pending-forever gap at both pairs; the threshold bounds at both pairs; and the forward-slack
witnessing of whichever pair carries the higher countdown, at exactly the displacement separating
the two. `cellLE_zero_const_of_kappa_eq_of_forwardSlack` proves it at every parameter tuple
`ParamsOk` admits, concluding cell EQUALITY: the upward half is
`cellAt_subset_of_shift_of_pend_past`, the downward half is
`cellAt_subset_of_shift_of_pend_past_rev`, and `Set.Subset.antisymm` closes it. It is NOT the
reserved statement and does not touch its truth value in either direction — it is strictly
stronger in hypotheses — and the reserved name stays claimed by nothing.
The EQUAL-REGISTER hypothesis is carried for a compiled reason, not for convenience:
`kappa_collision_two_regimes_refuted_of_pend_gap` shows that restricting a collision to the
pending-forever regime at countdowns above the threshold does NOT remove the saturated-gap branch
of `kappa_collision_regimes`. At `Tc = Tn = P = 0`, `B = 2` the pairs `(2, 0)` and `(4, 1)`
collide with both clipped coordinates pinned at their thresholds, both residues trivial, and the
gap coordinate saturated below the window on both, while the gap and threshold hypotheses hold and
the registers differ — and no single multiple of `P + 1` displaces both coordinates. On that
residue NEITHER the equal-register NOR the common-shift inclusion applies in either direction:
the obstruction is that the register must move by an amount the countdown does not match, and
forward slack at the common-shift amount does not address it — slack buys the deletion inside the
lower position's region, not the register's displacement. The restricted schema therefore covers
the equal-register slice of every collision — the first branch of the case split entire, plus the
`n = n'` slice of the saturated branch — and nothing else. The residue IS reached, on its
MONOTONE slice and in both directions, by the free-register layer recorded below; its ANTITONE
slice is excluded there by a named hypothesis rather than left tacit. What a consumer must supply, at
each state it inducts through: the register equality across the collision, and a forward-slack
witness at the higher state. Neither is a consequence of `ParamsOk`.

**The register-lowering deletion: LANDED, and the branch-2 schema it buys.**
`exists_ladderPath_through_deleted_exact_lowered_upfirst_of_pend_past` (`LadderChain.lean`) is the
exact-shift deletion with the TARGET REGISTER freed: the countdown at `z` lowered by exactly
`m · (P + 1)` as before, the object state and the realized stab-free type held as before, and the
register delivered at a prescribed `n₀ ≤ nxtAt g z` under forward slack at `m · (P + 1) + k`
where `n₀ + k = nxtAt g z`. The lowering costs exactly `k` in the UPPER direction of the single
anchor inequality and nothing in the lower one; at `k = 0` it is the held-register theorem,
hypothesis for hypothesis. The construction performs the lowering BEFORE the surgery rather than
inside it: the countdown of a ladder path is read off its walk but the REGISTER is not, so
`exists_ladderPath_of_walk_nxt_at` re-lifts the path's own walk and countdown at the anchor `n₀`
— the pin clause being `anchor_clause_of_first_region_start` at deleted length `0`, which is where
the `k` is spent — and the held-register theorem then applies to the re-lift unchanged.

What it buys, through `mem_cellAt_of_common_shift_of_hasForwardSlack_exact` and
`cellAt_subset_of_common_shift_of_pend_past_rev` (`LadderCell.lean`), is the COMMON-SHIFT
sub-regime's DOWNWARD direction, and hence `CellLEZeroConstOfKappaEqCommonShiftForwardSlack` with
`cellLE_zero_const_of_kappa_eq_commonShift_of_forwardSlack`: a depth-`0` cell-EQUALITY schema for
branch 2 of the case split carrying NO EQUAL-REGISTER HYPOTHESIS. In its place the common-shift
displacement is an explicit hypothesis, and the price of moving the register is visible in two
places — the regime amount DOUBLES to `m · (P + 1) + m · (P + 1)` (one `m · (P + 1)` for the
countdown, one for the lowered anchor) and a room bound `n + (m · (P + 1) + m · (P + 1)) ≤ c` is
carried, neither implied by nor implying the pending-forever gap. It does NOT reach the
saturated residue: on that branch the register must move by an amount the countdown does not
match, and forward slack at the common-shift amount does not address that — the free-register
layer recorded immediately below is what reaches it. The reserved
name `cellLE_zero_const_of_kappa_eq` stays claimed by nothing, and this schema — strictly
stronger in hypotheses — bears on its truth value in neither direction.

**The free-register raise: LANDED, and the monotone dispatch of branch 3.**
`exists_ladderPath_through_free_register_shifted_of_pend_past` (`LadderCell.lean`) is the same
regime-A assembly with the anchor VALUE left free: the countdown at `z` raised by exactly
`m · (P + 1)`, the object state and the realized stab-free type held, and the register delivered
at any prescribed `n₀` with `nxtAt g z ≤ n₀ ≤ cntAt g z + m · (P + 1)`. The two bounds pay for
OPPOSITE directions of the one anchor clause — the lower for the register's Lipschitz bound, the
upper for the pin distance — and `free_register_anchor_clause_monotone_required` compiles the
LOWER one as non-removable, at the arithmetic witness `X = 19`, `nz = 8`, `cz = 10`, `mP = 0`,
`n₀ = 0`, `d = 11`. At `n₀ = nxtAt g z` the raise is the held-register theorem and at
`n₀ = nxtAt g z + m · (P + 1)` it is the common-shift one, hypothesis for hypothesis.

Two cell inclusions read it: `cellAt_subset_of_free_register_shift_of_pend_past` UPWARD, which
consumes NO forward slack because the widened window pays for the anchor, and
`cellAt_subset_of_free_register_shift_of_pend_past_rev` DOWNWARD (path level:
`mem_cellAt_of_free_register_shift_of_hasForwardSlack_exact`), at the register-lowering deletion's
own amount `m · (P + 1) + (n' − n)` with the room bound `n' + (n' − n) ≤ c` and the HIGHER pair's
own gap `n' + 2 ≤ c + m · (P + 1)` carried explicitly — that last one being a named hypothesis
here precisely because the free register breaks the derivation the common-shift statement gets for
free at `m = 0`. Against each other they give `CellLEZeroConstOfKappaEqMonotoneForwardSlack` and
`cellLE_zero_const_of_kappa_eq_monotone_of_forwardSlack`: the depth-`0` cell-EQUALITY schema
carrying NEITHER the equal-register restriction NOR the common-shift displacement, with
`MonotoneCollisionDisplacement` in their place. Its hypotheses SPECIALIZE to both landed schemas'
(the `n' = n` and `n' = n + m · (P + 1)` rows of the amount table above); neither landed schema is
retired and neither signature is touched.

The ANTITONE complement — a collision whose register moves OPPOSITE to its countdown — is
EXCLUDED, by that hypothesis, visibly, in the schema's own quantifier. Three compiled records are
what keep the exclusion from being tacit: `kappa_collision_monotone_or_antitone` makes the two
slices an exhaustive dichotomy over collisions with no third case;
`kappa_collision_antitone_residue_nonvacuous` inhabits the excluded slice inside the
pending-forever regime above the threshold (`(4, 2)` against `(6, 0)` at `Tc = Tn = P = 0`,
`B = 2`); and `kappa_collision_monotone_saturated_gap_nonvacuous` exhibits the dispatched slice
reaching branch 3 at `(2, 0)` against `(4, 1)` — the exact pair
`kappa_collision_two_regimes_refuted_of_pend_gap` pins as surviving regime restriction and as
reached by no landed inclusion. The reserved name `cellLE_zero_const_of_kappa_eq` stays claimed by
nothing, and this schema — strictly stronger in hypotheses — bears on its truth value in neither
direction.

**The antitone route, TAKEN for the deep-descent residue and never needed for the bounded
sub-slice.** The route is forward-slack witnessing AT THE LOWER PAIR, paying the UPPER direction
of the anchor clause that `free_register_anchor_clause_monotone_required` compiles as failing
once the lower bound on the free anchor is dropped: lowering the anchor costs in that upper
direction, and on the raised path nothing bounds the register at a far pin from above.

The slice SPLITS, along a compiled line, and the two halves have different prices.
`kappa_collision_antitone_descent_multiple` reads the register's descent across a collision as
itself a multiple `j · (P + 1)`, so the line is the comparison of `j` against the countdown's
multiplier `m`, and both sides are non-empty inside the regime above the threshold:
`kappa_collision_antitone_bounded_descent_nonvacuous` at `(4, 2)` against `(6, 0)` with `m = 2`
(descent exactly `m · (P + 1)`) and `kappa_collision_antitone_deep_descent_nonvacuous` at
`(10, 8)` against `(11, 0)` with `m = 1` (descent `8 > 1`).

What is compiled. `exists_ladderPath_through_shifted_slack_of_pend_past` exposes the raise's own
`m · (P + 1)` of bought forward slack, which the landed regime-A assembly discards;
`exists_ladderPath_through_free_register_shifted_slack_of_pend_past` spends it on the anchor's
upper direction, RELAXING the lower bound to `nxtAt g z ≤ n₀ + (m · (P + 1) + L)`, with the
relaxed bound itself compiled as non-removable by
`free_register_anchor_clause_relaxed_bound_required` at a DEEP-DESCENT witness
(`X = 19, nz = 8, cz = 10, mP = 1, n₀ = 0, d = 12`).
`exists_ladderPath_through_deleted_exact_raised_upfirst_of_pend_past` supplies the downward
direction by RAISING the target register rather than lowering it, at the held-register amount
`m · (P + 1)` and under no room bound beyond the lower pair's own gap — a raise is free in the
direction the single anchor inequality charges for. The two cell inclusions
`cellAt_subset_of_antitone_register_shift_of_pend_past` (upward, at the truncated amount
`(n − n') − m · (P + 1)`) and `..._rev` (downward, at `m · (P + 1)`) give
`CellLEZeroConstOfKappaEqAntitoneForwardSlack` and
`cellLE_zero_const_of_kappa_eq_antitone_of_forwardSlack`: the antitone slice dispatched as
depth-`0` cell EQUALITY in both directions, exhaustive against the monotone schema by
`kappa_collision_monotone_or_antitone_named`.

On the BOUNDED sub-slice no upward hypothesis is needed at all. The truncated amount is literally
`0` there, `forwardSlackWitnessed_zero` compiles that an amount-`0` witnessing obligation is
FREE, and `cellLE_zero_const_of_kappa_eq_antitone_bounded_of_forwardSlack` therefore carries
exactly ONE `ForwardSlackWitnessed` hypothesis — the downward one. The pair
`kappa_collision_antitone_residue_nonvacuous` exhibits lies in that half, so the compiled
demonstration that the excluded slice was non-empty was a demonstration about its cheaper half.

`free_register_anchor_clause_monotone_required` is untouched, unamended and uncontradicted: its
own witness has `mP = 0`, where the relaxed bound IS the landed bound. Its bound is
non-removable, as it compiles; what is new is that the bound is RELAXABLE by exactly the raise.

What remains open, and is claimed in NEITHER direction: whether a `ForwardSlackWitnessed`
hypothesis at a POSITIVE amount is satisfiable at any state the induction one layer up actually
reaches. Discharging the amount-`0` case settles nothing about that question, and neither does
`section IOne`'s refutation: it shows a POSITIVE-amount obligation failing at a regime-inhabiting
state where `I = 1`, while `ceiling_slack_at_consumer_amount` shows the ceiling it turns on is
satisfied for free at the amount these schemas instantiate — so the obstruction compiled there is
absent here, which is not the same as the hypothesis being satisfiable. The reserved name
`cellLE_zero_const_of_kappa_eq` stays claimed by nothing, and both antitone statements — strictly
stronger in hypotheses than the reserved one — bear on its truth value in neither direction.

**The route left open**, named rather than claimed. A `(K1)` AMENDMENT constraining the
length of a type-respecting block that spans a region start — which `(K1)` does not do, compiled
above — would reopen the spanning-block device the two-sided refutation closed; it is not
undertaken here and would alter the parameter contract every wired probe discharges.

**Model-level periodicity of the realized type: the conditional form is landed, the unconditional
form is refuted, and the gap between them is the tight chain.** `LadderAgree.lean` carries
`tpOf_periodic_of_objAt_periodic` — the realized stab-free type of a ladder path is `l`-periodic
whenever that path's object walk is globally `l`-periodic — with `objAt_tpOf_eq_of_objAt_periodic`
delivering the same fact as the `(objAt, tpOf)` endpoint pair at distance `l`, in the tuple shape
`exists_typeBlock_of_spacing` and `tpOf_eq_spliceIdx_of_tpOf_eq` consume. Both are half (i)
composed with `tpOf_timeShift` at `σ' := σ.timeShift l`; axioms
`[propext, Classical.choice, Quot.sound]`, the module's own profile, citing `AnchorLayer.lean` and
re-proving nothing. **What they quantify over**: the periodicity hypothesis is GLOBAL (every
`v : ℤ`) and is on the WALK — no `ParamsOk`, no pending-region hypothesis, no `kappa`, no
certificate object. The one-sided weakening is unavailable, because the `S` clause reads the past
and half (i) needs the two walks to agree at every position; a future-only restriction would need
a future-locality lemma stated nowhere in the tree. They are NOT a surgery — one path, two of its
positions, the walk unchanged — so the splice-type refutation does not reach them, and neither do
they revive it. **The unconditional form is refuted**, by the wired probe
`specs/evidence/seam-gluing-ray-product/ladder-tpof-periodicity-refutation.lean`: EVENTUAL
periodicity of `tpOf` along an arbitrary ladder path — a threshold `N` AND a period `p > 0`, the
shape `satThreshold`/`satPeriod` carry on the certificate side — is false
(`tpOf_periodicity_refuted_unconditional`, against the schema `TpOfEventualPeriodicity`), on an
all-idle two-state object that constrains the walk not at all, with the walk `true` exactly at the
powers of two and the separating pair carried with non-vacuity on both sides
(`exists_separating_positions`: the letter in the first type and out of the second, its negation
out of the first and in the second, so neither type is empty). The witness violates the
conditional lemma's hypothesis at every nonzero distance (`wA_not_periodic`), so the two statements
do not meet. Axioms `[propext, Classical.choice, Quot.sound]` on every headline theorem,
`[propext]` on the two seriality discharges; no `sorryAx`, no custom axiom, no `native_decide`, no
vacuous definition. Registered without an ordinal, in the style the later entries of this record
use. **The verdict.** The only landed MODEL-level periodicity statement about `tpOf` is the
CONDITIONAL one above; the only landed periodicity statement elsewhere in the layer remains
`prodPre_periodic`, with `satThreshold`/`satPeriod`, a fact about the backward-reachability
fixpoint `prodPreStep` on `Finset (ProdState Q φ)` and so a CERTIFICATE-relation fact, which
`CounterQuotient.lean` states in source is related to none of `cohIdle`, `Rlad`, `ladderModel`,
`tpOf` or `cellAt`. The conditional form does NOT bridge the two: the tight (doubling) chain's
walk is not globally periodic, so the hypothesis is unavailable exactly where the depth-`0` cell
obligation needs it, and the bridge from the certificate layer's periodicity to `tpOf` remains
unbuilt (argued, not compiled — unlike the idle-gap route to the slack-normalization lemma above,
which is refuted by a compiled object).

**The certificate-side bridge, and what `certStabK` of `Real` actually asks for.** The register
bridging is now attempted on the CERTIFICATE side, where no relation between positions of two
paths carries a register conjunct at all, and `LadderRealize.lean` carries the design round's two
legs. **LEG A, the obligation named.** `certStabK`'s clause at a member of `Real` is an iff whose
two directions are NOT symmetric: `real_certStabK_mpr` lands the direction in which the fibre
forces the `⊡` letter UNCONDITIONALLY, with no cell transfer whatever and over no
register-displaced pair — every history through the member's own witnessing state projects into
`Real` at the same object component and the same counter class by `mem_real_realItem`, so that
half is discharged by `Real`'s own definition. The other direction,
`real_certStabK_mp_of_cell_stab_transfer`, consumes a CELL-SIDE obligation written out in its own
binder: a formula lying in every closure type of the cell at one admissible ladder state lies in
every closure type of the cell at every class-equal state with the same object component.
`real_certStabK_of_cell_stab_transfer` joins the two, with no parameter condition anywhere in it.
**The scope reading, stated loudly because the opposite finding would have been the prize.** That
obligation's pair set DOES contain register-displaced collisions: `kappa_eq_register_displaced`
holds all five `kappa` coordinates across `n ↦ n + (P + 1)` once `Tn ≤ n` and `c + B ≤ n`, and
`register_displaced_collision_in_domain` exhibits the two DISTINCT admissible ladder states that
carry it — at a FIXED countdown, sharing one admissibility witness. **LEG B, the transport,
decided OPEN.** `ClassRepTransport` states the class-representative transport at the history
level — every closure type realized at a ladder state is realized at every class-equal state with
the same object component — and its body is the goal state the verdict records;
`cell_stab_transfer_of_classRepTransport` and `real_certStabK_of_classRepTransport` compile the
implications out of it. The transport itself is neither proved nor refuted, and the coordinate
that refuses it is the REGISTER: the one landed tool producing `kappa`-collisions,
`kappa_eq_of_shift` with `clipIdx_sub_sub`, moves BOTH counters by a common multiple of `P + 1`
and provably does not reach a pair whose countdown is held fixed
(`register_displaced_ne_common_shift`). Nothing of this claims a cell agreement, a certificate
condition beyond the reduction, or any inclusion between `Real` and `Dmax`.

**How far the landed machinery carries the transport, and the two coordinates that refuse the
rest.** The transport was then attempted on its own ground. The one tool that moves a register at
a HELD countdown is the raised exact-shift deletion at deletion amount `0`, named here as
`exists_ladderPath_register_raised_at_held_countdown`, and
`cellAt_subset_of_register_raise` is the cell-level inclusion it yields — in
`ClassRepTransport`'s own direction, between two states differing in the register alone, with the
`kappa`-collision carried as the FIRST conjunct of the conclusion and every room condition an
explicit named binder. It covers the DOWNWARD-saturated collisions `kappa_eq_register_raise_down`
exhibits (`Tn ≤ n' ≤ n`, congruent modulo `P + 1`, with `n + B ≤ c`). It does not cover the
UPWARD-saturated family the scope reading exhibits inside the obligation's own domain, and the
exclusion is an inequality rather than an assessment:
`raise_room_excludes_upward_displacement` is the compiled contradiction between the tool's room
ceiling `n₀ + 2 ≤ cntAt g z` and that family's `c + B ≤ n₀`. A second, independent coordinate
refuses it as well — both register-moving deletions carry the stab-free premise, and
`certStabK_of_stabFree` records that at exactly those closures condition (5) is VACUOUS. So the
inclusion is a real transport across a real family of `kappa`-collisions that buys the
certificate side nothing, and `ClassRepTransport` itself remains OPEN, neither proved nor
refuted. A third gap is recorded rather than closed: the inclusion is stated at the diagonal
world state, while the bridge's own cell-side binder is at a general time component, and bridging
the two is an offset-invariance of `tpOf` that is not landed.

**The composition over the covered collisions, and what it buys — covered, and not covered.**
The transport's reverse direction is carried by the LOWERED exact-shift deletion at deletion
amount `0` (`exists_ladderPath_register_lowered_at_held_countdown`,
`cellAt_subset_of_register_lower`), whose one extra room condition over the raise's is the
lowering budget `n + (n - n') ≤ c`, carried as an explicit named binder because nothing in the
covered family implies `n - n' ≤ B`. The two inclusions together give
`cellAt_eq_of_register_displacement`, a genuine cell-level AGREEMENT — an EQUALITY of the cells
of two class-equal ladder states differing in the register alone — and
`cell_stab_transfer_of_register_displacement` reads it in the shape the bridge's own cell-side
binder consumes, in both orientations. **What is COVERED**: the downward-saturated
register-displaced pairs at a held countdown (`Tn ≤ n' ≤ n`, congruent modulo `P + 1`,
`n + B ≤ c`), at the DIAGONAL world state, at a STAB-FREE closure, under the per-path regime
each direction's tool asks of the paths through its own source state. **What is NOT covered**:
the upward-saturated family (`raise_room_excludes_upward_displacement`), any pair with a moved
countdown, a general time component (the diagonal gap, unlanded), every closure carrying a `⊡`
letter, and any path outside the regime. **What the composition buys, stated as the measurement
it is**: over the covered collisions the bridge's `certStabK` conclusion does hold —
`real_certStabK_of_stabFree` — and the transport is NOT load-bearing in it, because the covered
regime's own defining premise, stab-freeness, already gives condition (5) outright through
`certStabK_of_stabFree`. So route (P-2)'s composition closes on the covered set and closes
VACUOUSLY there. The filed agreement `cellAt_const_of_kappa_eq` is landed under no name here and
is REFUTED as filed, at the gap coordinate on a `⊡`-carrying closure and at (K4)'s own clip, by
the library theorem `exists_kappa_collision_cellAt_ne_at_K4_clip` (`LadderRealize.lean`: a finite
object, a formula, parameters satisfying `ParamsOk` at the clip
`max (2 * dBack φ + 1) (max (2 * dFwd φ + 1) 2)`, and a `kappa`-collision whose two cells differ);
the wired probe `specs/evidence/seam-gluing-ray-product/ladder-cell-agreement-refutation.lean`
compiles the same object independently (`cellAt_const_of_kappa_eq_schema_refuted`;
`LadderCell.lean`, section "The refutation of the agreement over counter classes"); nothing here
claims `ClassRepTransport`, the
factorization lemma, `real_certAdmK_of_paramsOk`, `real_subset_dmax` or `Dmax ⊆ Real`.

**The filed agreement, attempted at its own signature and not landed, and the instantiation over
the covered set.** The filed `cellAt_const_of_kappa_eq` is attempted at its recorded signature,
token-for-token, and is NOT landed: the signature elaborates, and the residual goal after the one
reduction the landed machinery offers — `kappa_eq_components`, the collision read coordinate by
coordinate — is the statement's own conclusion with the five coordinate equations in context and
no applicable tool. Five coordinates of its domain lie outside the covered set, each for a
reason that is a landed object: it carries no stab-free premise while both register-moving
deletions carry one; it carries no `c = c'`, and the first two coordinates give only a common
`min` against `Tc` and a common residue, while no landed tool moves a countdown while holding a
class; its first world-state component is general while the inclusions are stated at the DIAGONAL,
and that one coordinate is bridged by the offset-invariance below; it carries no per-path regime;
and it carries none of the room, threshold or clip conditions. So the filed statement is OPEN on
the uncovered collisions SPECIFICALLY — the upward-saturated register family, moved countdowns,
every closure carrying a `⊡` letter, and paths outside the regime — and not as a general
failure.

What IS landed is the agreement at the filed statement's own shape, restricted to the covered
family by explicit named binders: `cellAt_const_of_kappa_eq_of_covered`, which takes the
`kappa`-collision as a HYPOTHESIS and consumes it — the residue conjunct comes from `kappa`'s
fourth coordinate — together with `register_dichotomy_of_kappa_eq_held_countdown`, the gap
coordinate's own split at a held countdown: a register-displaced collision there is trivial,
downward-saturated (the covered family) or upward-saturated (outside every landed tool's reach),
with no fourth case. **What the agreement does NOT say**: it equates CELLS at `kappa`-colliding
states inside the covered family and asserts no tuple index of a ladder cell at any parameters,
no bound of any kind, and no device discrimination; the ladder's structural liveness stays
FORWARD-ONLY and is untouched by it
(`specs/evidence/seam-gluing-ray-product/ladder-liveness-forward-only.lean`); it is not the
factorization lemma; and nothing in it consumes `ladderSound`, `ladderLift`,
`ladderCons_localRun` or any (S)/(C') statement. **The route taken is the cell-level one, and
the path-level invariance it replaces is REFUTED rather than merely absent**: that statement —
that a splice preserves the realized stab-free type at a distance from its splice point — is the
compiled refutation `splice_type_invariance_refuted` in
`specs/evidence/seam-gluing-ray-product/ladder-splice-type-refutation.lean`, cited by path as
evidence and never as a proof term.

**The diagonal gap, closed: the world state's own time component is invisible to a cell.**
`cellAt_eq_cellAt` says a cell does not depend on the time at which a state is VISITED. It says
nothing about the `ℤ` component of the world STATE, which on this carrier is a coordinate of the
state itself, so `cellAt … (t, x) z` and `cellAt … (t', x) z` are cells of two DIFFERENT world
states and no history through one is a history through the other. They are equal all the same
(`cellAt_ladder_eq_of_worldTime`), because `Rlad` ignores its time argument: one ladder walk is a
world history at EVERY offset (`exists_hist_of_isLadderPath_at_offset`, whose `k = 0` instance is
`exists_hist_of_isLadderPath`), and the offset is invisible to every clause of `PlusTruthAt`
(`truthAt_iff_of_worldTime_offset`), hence to the realized closure type
(`tpOf_eq_of_worldTime_offset`). The `⊡` clause is the only one that reads the world state, and it
is PROVED rather than carried by a pinned-letter parameter — a history through the one state is
the same walk re-offset to the other, and the induction hypothesis at THAT walk transports its
truth — so **no stab-free premise, no finite-fibre assumption and no finite-width assumption
enters, and no parameter ruling is taken**. What it buys is exactly one coordinate:
`cellAt_const_of_kappa_eq_of_covered_at_time` is the covered agreement at a general time
component, every other binder unchanged token for token, and the register, countdown, `⊡`-letter
and regime coordinates of the filed statement are untouched by it.

**The path level, closed on measured evidence and recorded in that form.** Four register readings
were MEASURED against the two sides any relation between positions of two paths has to pass —
delivery by the iterated splice at the window's interior, and consumption by the `⊡` bit: the
clipped reading, the Drift-distance reading, dropping the register conjunct, and the gap reading.
Each failed one of the two sides, and the level was closed by the recorded ruling on exactly that
evidence. That is the whole of the claim: no general impossibility is asserted at that level, and
the completeness of the gap reading is not settled here.

**The object-dependent gap clip: a NAMED OPEN QUESTION, with its compiled boundary.** `kappa`'s
gap coordinate clips `n - c` at `B`, and `(K4)` fixes `B` from the formula alone. Whether the
cells are constant on `kappa`-classes at a clip `B(Q, φ)` that reads the OBJECT as well is
**OPEN** — neither proved nor refuted, here or anywhere. What is compiled is strictly narrower
than that question, by construction, and each of these is a wired probe. In
`specs/evidence/seam-gluing-ray-product/ladder-chain-object-clip-refutation.lean`:
`no_formula_only_clip`, quantified over ALL clip functions `E : PlusFormula → ℕ`, refutes every
clip reading the formula alone, with `exponential_clip_refuted` its instance at
`E φ := 2 ^ (dBack φ + 1)`. In
`specs/evidence/seam-gluing-ray-product/ladder-cell-agreement-refutation.lean`:
`gap_clip_below_exponential_refuted` and `no_keyed_cell_map_below_exponential` refute every clip
`B` with `B + 1 ≤ 2 ^ (j + 1)` on the doubling object `Qc`. The lever in all of them is the
OBJECT, not the formula: the gap threshold a formula can read scales with the object, which is
exactly why no formula-only clip survives. The refuting chain family reaches `card Q − 2` and no
further — on the chain object `Qm m := Fin (m + 3)`, `chainC_cell_ne` separates gap `m + 1` from
gap `≥ m + 2` under `c + m + 2 ≤ n'`, and a `kappa`-collision needs both gaps saturated at the
clip, so the family says nothing at `B ≥ m + 2`. That any surviving clip is of order
`card Q · 2 ^ (dBack φ)` is **INFERRED and NOT COMPILED**: no induction establishing it exists in
the tree. The accurate scope sentence is therefore: below `2 ^ (dBack + 1)` refuted on `Qc`; at
every formula-only clip refuted on the chain family; an object-dependent clip OPEN.

What a positive result would need, and what is absent: a closure theorem for definable register
sets on ARBITRARY finite objects — (i) which sets of idle registers are definable at each operator
depth (conjecturally eventually periodic with period dividing `P + 1` and a depth-indexed
threshold), (ii) closure of that class under the four jump moves and under `⊡`'s re-selection, and
(iii) the same for pending states, where the gap is converted to an exit register. No statement of
(i)–(iii) exists anywhere in the tree. The nearest compiled objects are probe-level and
object-specific: `stepFrag_gap_depth_exact`
(`specs/evidence/seam-gluing-ray-product/ladder-step-fragment-gap-depth.lean`), which is **step
fragment only** — that fragment admits `untl`/`snce` at the guard `⊥` alone, so the separating
formulas `thetaC` and `mixC`, each using one jump, are NOT covered by it — and `nxt_le_double`
(`specs/evidence/seam-gluing-ray-product/ladder-cell-agreement-refutation.lean`), on `Qc` only.
Adopting an object-dependent clip would also be a signature change rather than a proof:
`paramsOkK4` and `Bof` (`CounterQuotient.lean`), the latter
`max (2 * dBack φ + 1) (max (2 * dFwd φ + 1) 2)` with its three object binders documented in its
own body as unused, both read the formula alone, so the change would reach `paramsOk_params` and
every consumer of `ParamsOk`. The order of `K` is not the obstacle: `Tcof` already carries
`Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card * (Pof + 1) * (stabDepth sup + 1)`, so `K` is
already exponential in the formula and already reads `card Q`. No clip is adopted here, no
agreement at one is attempted, and the question is recorded as open rather than as settled,
likely or dead.
