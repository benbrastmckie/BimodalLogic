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

| File | Lines | Description |
|------|-------|-------------|
| `Seam.lean` | 165 | `SeamSummary` (a family triple plus a `Bool` verdict), the four-field hypothesis bundle `Presents` (`colours`; `determined`; `realized` — joint realization through the seam; `verdict`), and the bridge `plusStab_iff_seamSummary`: under `Presents`, `⊡φ` holds at the seam iff the verdict is `true`. The bundle's declarations are pinned and unchanged; what `colours` says is characterized in `SeamMulti.lean`. |
| `SeamMulti.lean` | 344 | The characterization `exists_presents_iff` (`SeamDecided`): the single-family bundle is inhabited iff the seam is `⊡`-decided — so `Presents.colours` is a seam condition, not the MSO reduction. The two-letter interface (`twoLetter`, `seamTrace`, `nowPhi`, `stabTarget`, `stabTarget_determined` from `determinedByKType_eval`), the realized set `Hit` (finite: `hit_finite`), the hypothesis-free bridge `plusStab_iff_forall_hit`, and the multi-family bundle `PresentsMulti` with its bridge `plusStab_iff_presentsMulti` and its inhabitant `presentsMulti_seamTrace` (whose `Bool` is classical). |
| `Closure.lean` | 309 | B1: the closure alphabet `clSig φ` (one letter per subformula of `φ` plus the marker `clNow`; `Fintype`/`DecidableEq` by `inferInstanceAs`), HWZ 2000 Def 11's local run conditions on colourings of `ℤ` (`LocalRun`: `bot`, `imp`, `untl`, `snce` — exactly `PlusTruthAt`'s clauses), the anchors that fix what a run condition cannot (`Anchored`: `now` at `t`, atoms at states, `box` per time — `box_time_invariant` (`PlusLanguage/PlusTruth.lean`) shows that field's `∀ z` is redundant on every `TaskFrame`, `□ψ` being a per-model datum; the structure is pinned and consumed by `Trace.lean`'s uniqueness theorem, so the redundancy is recorded here and not repaired — `stab` per state), the closure trace `clTrace` of a history (its two-letter projection is `seamTrace`, `clTrace_proj`), `HitSig` over an arbitrary signature, and the signature-generic bridge `plusStab_iff_forall_hitSig`, of which `plusStab_iff_forall_hit` is the two-letter instance (`hitSig_twoLetter` by `rfl`). |
| `Trace.lean` | 418 | B2a, HWZ 2000 Thm 14 in the direction that reads types off a model: the closure trace satisfies every run condition and anchor (`clTrace_localRun`, `clTrace_anchored`, each clause `Iff.rfl`) and an anchored local run **is** the trace of its history (`eq_clTrace_of_localRun_anchored`, `clTrace_unique`, by structural induction on the closure formula). The realized set over the closure alphabet `HitCl` (finite), the bridge `plusStab_iff_forall_hitCl`, and `hitCl_eq_iUnion` (the union over the seam's ray pairs of their traces' family triples — a theorem, not a computation: `SeqPair` is not finite). The realization hypothesis `Presented M τ t φ lab step` (the seam's closure traces are exactly the presentation's run traces), `presented_localRun`, the per-model bridge `hit_eq_hitOf_of_presented` (`HitCl = ↑(hitOf …)` for `1 ≤ k`), and `plusStab_iff_forall_hitOf_of_presented`, which decides nothing. Beside it the **Hit-level weakening** `HitPresented` — equality of the realized FAMILY-TRIPLE sets, `HitCl M τ t φ k = ↑(hitOf lab step (clNow φ) k)`, instead of equality of the trace sets — with `hitPresented_of_presented` (`Presented` implies it at every `k ≥ 1`, by `hit_eq_hitOf_of_presented` verbatim; no converse). It is **satisfiable** where `Presented` is refuted, with the presentation size exhibited as the count `Nat.card (KType (clSig Fp) k)` (not a complexity bound of any kind): see "The verdict" below. |
| `Compose.lean` | 400 | B3b, the composition half: the finite segment of a list of letters `listSeg` (carrier `Fin l.length`, computable instances, `kTypeOfFin_listSeg`), the letters of a decidable colouring on `[a, b)` (`labels`) with `kTypeOf_segZ_eq_listSeg` (a time-axis segment has the `k`-type of its label list, by `k_equiv_of_iso`), `listSeg_append_kEquiv` (a concatenation is the two-point ordered sum of its parts), and the congruence `kTypeOf_listSeg_append_congr` — the `k`-type of `l₁ ++ l₂` depends only on the `k`-types of the parts, the `I = J = Bool` instance of `kEquiv_orderedSum_of_kEquiv_colour`. No `compose` on bare `KType` values, by design: most `k`-types are the type of nothing. |
| `Transport.lean` | 441 | Transport of a family triple along the DELETION of a constant run — the bridge from `Compose.lean`'s periodicity of one finite block to `InFamily`'s cutting sequences over `ℤ`. The keystone `segZ_const_of_kTypeOf_eq_replicate` (at `k ≥ 1`, a time-axis segment whose `k`-type is that of a nonempty constant block `ℓ^j` is itself nonempty and reads `ℓ` everywhere: two depth-`1` sentences transferred by `k_equiv_preserves_sentence`), the deletion colouring `deleteRun c s p` (the positions `[s, s + p)` removed) with its `labels`/`kTypeOf` lemmas for the untouched, translated and run-holding segments, and the cut surgery `inFamily_of_shrink_run`: a factorization whose ONE segment holds a constant run of length `≥ m₀ + p` (with `(m₀, p)` a threshold/period pair, an explicit hypothesis) re-cuts to a factorization of `deleteRun c s p` with the same triple, hence `familyTriples_subset_deleteRun`. Shrink direction only, under the single-segment containment as a hypothesis (the re-cut case, several short segments meeting the run, is NOT handled; the unconditioned general threshold would be `3·(m₀ + p)` and is not claimed); no `↔`. Every count is a count of depth-`k` types and nothing else. |
| `Present.lean` | 690 | B3b, the closure half: finite labelled presentations, unbundled (`Q` with `[Fintype Q] [DecidableEq Q]`, `lab`, `step`, `now`), their bi-infinite runs `IsRun` and decidable traces `runTrace`, finite paths `StepPath`/`stepPath_iff`, the representative-carrying closure `pathClosure` computing `pathTypes` (the `k`-types of `now`-free paths between two states) and `pathTypesNow` (paths reading `now` once) by `kTypeOfFin` on one stored label list per key, justified by the congruence (`mem_pathTypes_iff`, `mem_pathTypesNow_iff`; stationarity within `closureBound` rounds by `iterate_stabilizes`), and liveness as a greatest fixpoint (`live`, `live_iff`, `fwdLive`, `bwdLive`). `fwdLive`/`bwdLive` chain paths that share an endpoint and are **not** what `hitOf` reads (see `HitOf.lean`). |
| `HitOf.lean` | 810 | B3b, the read-out half: liveness over **disjoint** segments joined by one `step` (`fwdSepGraph`, `bwdSepGraph`, `fwdLiveSep`, `bwdLiveSep`, `fwdLiveSep_iff`, `bwdLiveSep_iff` — the graph a `SegmentFactorization` actually walks; with `Present.lean`'s shared-endpoint graph the characterization below is false, by a two-state counterexample `#eval`-witnessed in `KTypeFinEvalTest.lean`), the computable realized-triple set `hitOf lab step now k` (an image over state pairs of `pathTypesNow` types paired with live path types, never a filter over the triple product of `KType sig k`), and `mem_hitOf_iff`: for every anchor `t` and depth `k ≥ 1`, `hitOf` is exactly the family triples (`InFamily`) of the traces of the presentation's runs — the ⇒ direction splices runs of the presentation through a generic `ℤ`-indexed concatenation (`cutAt`, `exists_concat`, `isRun_concat`, `kTypeOf_segZ_concat`), the ⇐ direction reads a factorization's segments as `runSeg` paths and uses `k ≥ 1` through `doets_lemma_1_1` for the `k`-type visibility of nonemptiness and of a `now` state. |
| `Realize.lean` | 1004 | Requirement (S), the soundness half — HWZ 2000 Thm 14 (⇐) for the box-dot fibre. The decidable per-edge consistency conditions on a finite labelled presentation (`UCoh`, `deferGraph`, `ULive`, `Disch` forward; `SCoh`, `bwdDeferGraph`, `SLive`, `DischBwd` backward, proved outright and **not** transported — no backward Bool-fixture bridge exists) with the two theorems forcing `LocalRun`'s eventuality clauses from them (`untl_iff_of_UCoh_ULive`, `snce_iff_of_SCoh_SLive`), each generic over `sig` and `Q` with no model, frame or carrier finiteness in sight. The scope predicate `PlusFormula.BoxStabFree` and the closure-vacuity it buys (`not_box_mem_plusSubformulaClosure`, `not_stab_mem_plusSubformulaClosure`), which is what makes `Anchored`'s `box` and `stab` fields vacuous. The **eleven**-field bundle `Cons` with `cons_localRun` (field by field, no new induction); ten fields mirror a `LocalRun` field or a frame law, the eleventh, `nowUnique`, was derived from the realization theorem's own obligation and is documented at the field. The constructed model `frameOf` / `modelOf` (`ofSlicedStep` on the presentation's own `[Fintype Q]`, valuation reading the state component's label), its regularity instance `frameOf_isRegular`, the explicit record `frameOf_not_finite_worldState` that the carrier `ℤ × Q` is **infinite**, and the rewrite lemmas `modelOf_valuation`, `frameOf_step`, `frameOf_mem_HF_iff`. Then `anchored_runTrace_of_boxStabFree`, the realization theorem `presented_modelOf`, and the Hit-level corollary `hitCl_modelOf_eq_hitOf`. Scope, in the statements rather than in prose: ONE seam, `box`/`stab`-free `φ`, `[Fintype Q]` on the PRESENTATION only. No declaration mentions `PlusValidZTime` and no complexity bound is claimed. |
| `StabCheck.lean` | 252 | The per-seam `⊡` check by state liveness, **conditional on `Presented`** — the assembly that "The verdict" (below) bounds. The `now`-free step graphs `fwdNowFree`/`bwdNowFree`; `OnRun` and `onRun_iff_live` (the `now` states of runs anchored at `t` are exactly the live `now` states: a run restricted to `[t, ∞)` and `(-∞, t]` is a pair of chains, and a pair of chains with a common origin glues to a run); the decider `stabCheckSig lab step now phi` (every live `now` state reads `phi`) with `stabCheckSig_iff`, correct at every anchor (`t` does not occur in the decider); and the closure instance `stabCheck_iff_of_presented` / `decidableStabOfPresented`, composing the decider with `Trace.lean`'s run-level bridge `plusStab_iff_forall_run_of_presented` (under `Presented`, `⊡φ` at the seam iff every anchored run of the presentation reads `φ`'s letter at its `now` state). Both closure-instance statements are vacuous on model A, where `Presented` has no inhabitant (`presented-not-complete.lean`, below); no declaration mentions `PlusValidZTime`. |
| `AnchorLayer.lean` | 406 | Requirement (W), the **anchor layer** — the half of the closure-wide object the semantics lets one state on EVERY model with no hypothesis. Closure types read off a model (`tpOf`, classical, a `Finset`; `mem_tpOf_iff`, `tpOf_timeShift`), the per-state cells (`cellAt`, time-independent by `cellAt_eq_cellAt`), the four fixpoint equations a closure type satisfies by the truth clauses alone (`bot_not_mem_tpOf`, `imp_mem_tpOf_iff`; `box_mem_tpOf_iff` — ONE GLOBAL bit per `□`-subformula, `Anchored.box` with its per-time quantifier dropped by `box_time_invariant`; `stab_mem_tpOf_iff` — one bit per cell, `Anchored.stab` on types), the finite object `AnchorCons` (a set of cells satisfying the Hintikka and `box`/`stab` equations) with its completeness theorem for EVERY model `anchorCons_anchorCells` — `(M : TaskModel F.toTaskFrame) (φ : PlusFormula)` and nothing else: no presentation, no finiteness, no `[F.IsRegular]` — `anchorCells_finite` and the bound `anchorCells_ncard_le : (anchorCells M φ).ncard ≤ 2 ^ (2 ^ \|cl φ\|)` (a count of cells, not a complexity bound), and the `Finset` twin `AnchorConsFin` with `decidableAnchorConsFin` (an instance on a concrete finite object, never about a model; exercised by a non-vacuous `#guard` witness and a negative control in `KTypeFinEvalTest.lean`) and the bridge `anchorConsFin_iff`. No `untl`/`snce` equation — the run layer, blocked ("(W): what landed and what did not" below) — and no declaration mentions `PlusValidZTime`. |
| `RunLayer.lean` | 373 | Requirement (W), the **run layer's frame scheme** — the regularity part of its first obligation, and nothing more. The branching core transcribed from the seventh wired probe (`FwdFinBranch`, `BwdFinBranch`, `iterS_fwd_finite`, `iterS_bwd_finite`, `fib_finite_of_finBranch`, `saturation_of_finBranch`), the parallel constructor `ofSlicedStepFinBranch` (`ofSlicedStep`'s body with `[Finite W]` replaced by two-sided finite branching in its one `Saturation` slot; `Semantics/SlicedFrame.lean` untouched) with `ofSlicedStepFinBranch_isRegular`, `ofSlicedStepFinBranch_step`, the record `ofSlicedStepFinBranch_not_finite_worldState` and the history characterization `ofSlicedStepFinBranch_mem_HF_iff` (lines 72–250, 179 lines); and the **deadline ladder** `Rlad` over `Q × ℕ × ℕ` (`Drift`, `Count`: the current deadline counts down deterministically, the next deadline drifts by at most one per step, no state chooses a deadline) with two-sided finite branching for EVERY finite object (`Rlad_fwd`, `Rlad_bwd`), an infinite slice (`Rlad_slice_infinite`) and the frame `ladderFrame` with `ladderFrame_isRegular`, `ladderFrame_step` (lines 251–373, 123 lines). `[Finite Q]` on the OBJECT only; seriality is the object's own `fwd`/`bwd` hypotheses; depth `k = 1`. No realization theorem (the run layer's phase 2, open — "(W): what landed and what did not" below), nothing about `HitPresented`, no declaration mentions `PlusValidZTime`, no complexity bound. |

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
| (C) | **Hit-level completeness with a computable bound** | For every regular `ℤ`-model `M`, seam `(τ, t)`, formula `φ` and depth `1 ≤ k`, a finite labelled presentation `(Q, lab, step)` with `Fintype.card Q` below a computable bound in `φ`, such that `HitCl M τ t φ k = ↑(hitOf lab step (clNow φ) k)` — the Hit-level hypothesis `HitPresented` (`Trace.lean`), together with a bound | **Half-settled, and only the easier half.** `Presented` cannot carry it (`Probe735.not_presented`), and the Hit-level hypothesis is no longer open on the fixture: `HitPresented` **holds** on model A at the seam `(t, a)` of `stayA` with `φ := Fp` at every depth `k ≥ 1`, by the wired probe `hit-presented-model-a.lean` (`Probe745.hitPresented_modelA`) — the refutation does not transfer, exactly as the forward-type observation predicted, so the route through (C) is **not** closed by the verdict above. The bound half is settled ON THE FIXTURE, as a count: the probe's headline carries `presentationSize k = Nat.card (KType (clSig Fp) k)` in its statement (no `∃ L`), by `kTypeOf_listSeg_replicate_eventually_periodic_bounded` (`Compose.lean`), the cut surgery of `Transport.lean` and the fixture's containment `run_subset_middle`. That count counts depth-`k` types and nothing else — not a complexity bound of any kind. It is **two fixtures** (model A and `Node`, the latter ⊡-bearing and infinite-width — see Evidence), so the general regular `ℤ`-model statement is still the (W) run-layer record's completeness half. See "The bound: exhibited on the fixture, as a count" below. Without (C), "no presentation refutes `φ`" never certifies validity, since the refuting models need not be among the presented ones. |
| (S) | **Hit-level soundness** — the B2b record, restated at `hitOf` level | For every finite labelled presentation `P` satisfying consistency conditions `Cons P`, a regular `ℤ`-model `modelOf P` with a seam `(τ, t)` at which `HitCl (modelOf P) τ t φ k = ↑(hitOf …)` for `1 ≤ k` (the trace-level `Presented (modelOf P) τ t φ …` is stronger and suffices) | **DISCHARGED for `box`/`stab`-free `φ` at one seam**, in `Realize.lean`, at the stronger trace level: `presented_modelOf` plus its one-line Hit-level corollary `hitCl_modelOf_eq_hitOf`. See "(S): what landed and what did not" below for the exact scope. `Cons`'s eleven fields do exclude the pumpable eventuality-deferring run sets this row named as the obstruction — the two liveness fields `ulive`/`slive` are precisely acyclicity of the deferral graph `Probe735.pump_isRun` exploits. What remains open: `box`/`stab`-bearing `φ`, and every seam but the one. |
| (W) | **A closure-wide quasimodel over all seams and times** | A finite object carrying, for every time, the `box` anchor across the whole slice and, for every state, the `stab` anchor, nested under `untl`/`snce` — so that one presentation-level object witnesses `¬ PlusValidZTime φ` for some regular `ℤ`-model, history and time, rather than one seam's `⊡` | **Characterized, and half-landed.** The object is TWO-layered. The **anchor layer** is landed in `AnchorLayer.lean` and bounded: cells (sets of closure types, one per world state), the `box`/`stab` fixpoint equations, `AnchorCons`, its completeness `anchorCons_anchorCells` for EVERY model with no presentation, finiteness or regularity hypothesis, the bound `anchorCells_ncard_le` (`≤ 2 ^ (2 ^ \|cl φ\|)`, a count of cells), and the decidable `Finset` twin `decidableAnchorConsFin` on a concrete finite object. The row's "for every time" quantifier was dropped by a theorem, not an argument: `box_time_invariant` (`PlusTruth.lean`) makes `□ψ` a per-model datum on every `TaskFrame`, so the `box` letters are global bits and `stab` letters per-cell bits. The **run layer** — the `untl`/`snce` nesting, which lives in type sequences over `ℤ` and is the lift from one seam to validity — has its **frame scheme landed** (`RunLayer.lean`: the deadline ladder `Rlad`, two-sided finite branching for EVERY finite object, an infinite slice, the regular frame `ladderFrame` with `[Finite Q]` on the object only; depth `k = 1`; the bounded-deadline variants refuted by `not_finite_width_fmp` and the seventh probe's `Rok`/`Rbad`; gate-compiled by the ninth wired probe `deadline-ladder-branching.lean`) — the regularity part of its first obligation, measured at 373 lines — and is otherwise **BLOCKED** on obligation (ii), the Hit-level realization in both halves (soundness: the stabilization lemma in the pair of ladder counters is refuted by the twelfth wired probe `ladder-cell-refutation.lean`, and phase 2 is `[BLOCKED]` on the successor design; completeness: (C)'s general row, open), neither with a cost figure (see "(W): what landed and what did not" below); the shape of (S)'s construction is refuted as its soundness half by the wired probe `w-soundness-shape-refuted.lean` (finite width; `⊡`-collapse under `Presented`+`nowUnique`) — (S) itself untouched. Nothing states `PlusValidZTime` in any form; nothing is a negative decidability result. |

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
regardless of whether (C) survives, and nothing in `Realize.lean` bears on (C)'s missing
computable bound or on (W)'s closure-wide object. The verdict's headline is unchanged: the
ray-product presentation as landed still cannot deliver `Decidable (PlusValidZTime φ)`.

**What the verdict does not establish.** Nothing about `⊡(Pp)`: every fixture is forward-only
and no backward Bool-fixture bridge exists (limit 1, below). On the Hit-level hypothesis `HitPresented` the
verdict said OPEN, not refuted, and that much is now settled in the non-refutation direction
— on **one fixture**, by `hit-presented-model-a.lean`, with the presentation size exhibited as the
count `Nat.card (KType (clSig Fp) k)`; general (C) is open. The verdict itself is unchanged by that: the
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
`no_bwd_of_idle`), so `Adm` is a restriction of the CARRIER (`{c | pend q = false → c = 0}`),
defined in that probe and not in the library, and still not costed; the run-layer consistency
conditions that would play `Cons`'s role for the ladder are likewise named and not built.

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
   theorem for `ladderFrame`, per ladder cell, under run-layer consistency conditions analogous
   to `Cons`. The obstacle is precise: ladder states `(q, c, n)` with small `c` realize PROPER
   subsets of the types realized at large `c` — in `Node`, `pre 0` reads `⊡Xp` where
   `pre (k+1)` reads `¬⊡Xp` — so cells are indexed by `(q, deadline class)`, not by `q`, and the
   Hit-level per-cell hypothesis must be stated at ladder states. The stabilization of realized
   type sets in the counter pair `(c, n)` past a bound syntactic in `φ` — phase 2's FIRST
   statement — is REFUTED by the twelfth wired probe (`ladder-cell-refutation.lean`) in both the
   exhibited-bound and `∃ B` forms: the gap `n - c` between the two counters is observable, so
   bounding each counter bounds nothing that the cells depend on. Phase 2 is therefore
   `[BLOCKED]`, as this record's own contingency prescribes — never a finite-fibre retreat — and
   has no cost figure; the plausible true index carries a third clipped coordinate `n - c` and is
   not claimed; the design decision (the successor statement, and whether `ladderFrame` is
   repaired in place or beside) is open. The hypothesis must be Hit-level or
   product-level per cell (`HitPresented`, family-triple SETS, `hit-presented-model-a.lean`) and
   **never** trace-level `Presented`: the eighth probe's `stab_iff_of_presented_nowUnique` shows
   that at a `Presented` seam whose presentation marks at most one `now` state (exactly
   `Cons.nowUnique`, which (S) found necessary) every closure formula satisfies `ψ ↔ ⊡ψ`, so no
   `⊡`-refutation such as `Fp → ⊡Fp` is ever witnessed there, independent of width.
2. **The completeness half (model → object) — the run layer's phase 3, (C)'s general row.**
   For every regular `ℤ`-model `M`, seam `(τ, t)`, formula `φ` and depth `1 ≤ k`, a finite
   labelled presentation `(Q, lab, step)` with `Fintype.card Q` below a computable bound in
   `φ`, such that `HitCl M τ t φ k = ↑(hitOf lab step (clNow φ) k)`. Open mathematics with two
   positive fixtures and no general argument: `Probe735.not_presented` refutes the trace-level
   version (which is why the Hit level is the only one left), `Probe745.hitPresented_modelA` and
   `Probe759.hitPresented_node` are the Hit-level positives, and no Hit-level negative exists
   anywhere in the tree (none can on `Node`, whose seam fibres are finite). No figure.

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

**Successor.** Phases 2 and 3 of the run layer — the soundness half and the completeness half
of obligation (ii) — are their own records, each with its first statement fixed above (the
stabilization lemma in the deadline counter; (C)'s general row), never phases appended to this
one. The semi-decidable statement above needs no dependency on the bound record, and none is
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
necessity — a Hit-level falsifier for (C) needs a seam with infinitely many histories through
it. Forward-only; no finiteness added; nothing about `⊡(Pp)`, the general row, or
`PlusValidZTime`.

A twelfth wired probe, `specs/evidence/seam-gluing-ray-product/ladder-cell-refutation.lean`, is
the run layer's phase-2 first statement over a general finite object, gate-compiled, and its
verdict is NEGATIVE in both halves. First, `ladderFrame`'s seriality hypotheses are unsatisfiable
on the full carrier `Q × ℕ × ℕ` for every object (`Probe760.no_fwd`, `no_bwd_of_idle` — the idle
state `(q, 1, 0)` has neither successor nor predecessor under `Rlad`'s source clause), so the
admissibility set `Adm` is a restriction of the carrier (`{c | pend q = false → c = 0}`, realized
there on the subtype `{x // x.2.1 ∈ Adm pend x.1}` with two-sided finite branching pulled back
along `Subtype.val` — one of several equally valid shapes, in-place repair of `ladderFrame` among
them) and `ladderFrame` has no instances. Second, on that carrier the realized cells `cellAt` do
NOT stabilize in the pair of counters `(c, n)` past any bound: on the two-state object with
`p U (r ∧ X(p ∧ X r))`, `X χ := ⊥ U χ`, the cells at `(a, B, B+1)` and `(a, B, B+2)` differ for
every `B` (`cell_ne`; `exhibited_form_refuted`, `exists_form_refuted`), because the current
deadline fixes the region's end and `Count`'s idle clause `c' = n` exposes the gap `n - c`. Every
theorem at `[propext, Classical.choice, Quot.sound]` or less, citing `RunLayer.lean` and
`AnchorLayer.lean` and re-proving nothing — forward-only witness for a direction-neutral
statement, no bound of any kind claimed, no finiteness added, `anchorCells_finite` and
`anchorCells_ncard_le` untouched; what is refuted is the claimed computable index
`Q × Fin (B+1) × Fin (B+1)` of which cell a ladder state has, and the successor design is not
chosen here.

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

*Last verified: 2026-10-11*
