# Research Report: Task #750

**Task**: 750 - (W)'s run layer: its own record — phase 1, the frame-scheme design question
**Started**: 2026-10-10T08:10:56Z
**Completed**: 2026-10-10T08:40:00Z
**Effort**: ~30 minutes of dispatch time (reading, two compiles of one scratch file, writing)
**Dependencies**: None (no edge to 749, by the record's own instruction; 749 is `completed` in `specs/state.json` as of this session)
**Sources/Inputs**:
- Codebase, read in this session: `FormalSystem/Metalogic/Decidability/RaySummary/README.md` (whole file), `RaySummary/AnchorLayer.lean` (whole), `RaySummary/Trace.lean:220-370` (`HitCl`, `Presented`, `HitPresented`), `RaySummary/Realize.lean:540-770` (`Cons`, `deferGraph`, `ULive`, `frameOf`, `modelOf`, `frameOf_mem_HF_iff`), `RaySummary/Closure.lean:126-150` (`LocalRun`), `PlusLanguage/PlusTruth.lean:280-378` (`stab_state_only`, `box_time_invariant`, `box_global`), `PlusSlicedCertificate/Limits/NoFiniteWidth.lean:1-420, 1230-1313` (`Node`, `Step`, `F`, `canon`, `not_finite_width_fmp`), `Semantics/IntNormalForm.lean:340-507` (`mem_HF_iff_adjacent`, `ofStepRel`, `ofStep`), `Semantics/SlicedFrame.lean` (declaration index), `Semantics/TaskFrame.lean:1470-1500, 2210-2235` (`ofReflectiveRegular`, `saturation_of_fib_finite`), `Metalogic/WeakCanonical/KTypeSummary/Universal.lean:60-110` (`DeterminedByKType`, `determinedByKType_eval`), `Metalogic/Expressiveness/MonadicFO.lean:81-170` (`MonadicFormula`, `quantifierDepth`)
- Wired probes, read whole: `specs/evidence/seam-gluing-ray-product/b2b-frame-constructor-branching.lean`, `w-soundness-shape-refuted.lean`; header and headline of `hit-presented-model-a.lean`
- Prior records: `specs/archive/747_closure_wide_quasimodel_lift_to_validity/summaries/01_*.md` and `reports/01_*.md` (F7, R4, R5); `specs/ROADMAP.md:84-100`; `docs/theorem-index.md:201-209`
- Literature, read from the corpus text: HWZ 2000 `chunk_0021` (Defs 10-11) and `chunk_0022` (Def 12, Remark 13, Thm 14; page marker `11`); GKWZ 2003 `chunk_0589` (Thm 13.6, printed p. 568, Section 13.2) and `chunk_0590`
- lean-lsp: `lean_local_search` answered with `index: unavailable` (grep tier); compiled evidence via `lake env lean`
**Artifacts**:
- `specs/750_w_run_layer_closure_wide_lift/reports/01_w-run-layer-design.md` (this report)
- `specs/750_w_run_layer_closure_wide_lift/evidence/01_deadline-ladder-branching.lean` (compiled scratch, 119 lines, axiom profile `[propext, Classical.choice, Quot.sound]` on all three theorems)
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **Phase 1 decision: thread-indexed unfolding, in its general form a DEADLINE LADDER.** A
  bounded-deadline encoding is rejected on two machine-checked grounds, one per variant: a FIXED
  bound makes the slice finite, which `not_finite_width_fmp` refutes outright (`Φ.neg` has no
  finite-width countermodel); a deadline CHOSEN at a state is the `Rok`/`Rbad` shape, refuted for
  branching by `b2b-frame-constructor-branching.lean`. The ladder carries two counters per
  `⊡`-forced eventuality — the current deadline (deterministic countdown) and the next deadline
  (drifts by at most one per step at every step) — so that no state ever chooses a deadline. The
  `Node` frame of `NoFiniteWidth.lean` is the ladder's one-region special case (drift `0`, never
  idle). Compiled in this session: the ladder relation `Rlad` over `Q × ℕ × ℕ` has `FwdFinBranch`
  and `BwdFinBranch` for EVERY finite object `(Q, step, pend)` and an infinite slice
  (`Rlad_fwd`, `Rlad_bwd`, `Rlad_slice_infinite`, `evidence/01_deadline-ladder-branching.lean`),
  so Probe746's `fib_finite_of_finBranch` / `saturation_of_finBranch` apply to it unchanged and
  the regularity half of obligation (i) is a transcription.
- **Depth `k = 1`.** Every landed bridge the run layer would consume carries exactly `hk : 1 ≤ k`
  (17 occurrences across `RaySummary/*.lean`; zero occurrences of `2 ≤ k` or `3 ≤ k` there or in
  `KTypeSummary/`), and the run conditions are to be enforced by the object's step structure (as
  `Cons` does for (S): `ucoh`/`ulive`, `scoh`/`slive`), never read off types. The only reading
  under which a larger depth is needed — making `LocalRun.untl`/`.snce` themselves
  `k`-type-determined via `determinedByKType_eval` — costs `k = 3` (the clause is `∀z ∃s ∀r`;
  `MonadicFormula.quantifierDepth` counts each binder once) and is NOT recommended.
- **The regularity figure is now measured, not carried.** The tree's two analogues of the
  constructor measure 51 lines (`FrameOver.ofStep` with its three lemmas,
  `IntNormalForm.lean:456-507`, time-invariant shape) and 73 lines (`ofSlicedStep` through
  `ofSlicedStep_mem_HF_iff`, `SlicedFrame.lean:283-356`, time-indexed shape); the two-sided
  branching core is 66 lines (`b2b-frame-constructor-branching.lean:108-173`). Sum: 117-139 lines
  for the regularity part, inside the carried 120-160 band. The ladder relation with its
  branching proofs is 119 lines as compiled. The UNFOLDING's realization content (phases 2-3)
  has no figure, and this report assigns none.
- **Phases 2-3 are characterized, not priced.** Phase 2 (object → model, Hit level per cell) has
  one named obstacle this report makes precise: ladder states `(q, c, n)` with small `c` realize
  PROPER SUBSETS of `q`'s type set (in `Node`: `pre 0` versus `pre (k+1)`), so the object's cells
  must be indexed by deadline class, not by `q` alone. Phase 3 (model → object) is open
  mathematics with one positive fixture and no Hit-level negative anywhere (re-verified: zero
  hits for `¬ HitPresented` / `not_hitPresented` under `specs/evidence/seam-gluing-ray-product/`
  and `RaySummary/`).
- **Documentation deliverable drafted** (section "The README paragraph" below), with every
  literature anchor re-verified against the corpus text: HWZ Def 12 / Remark 13 / Thm 14 on the
  page whose marker reads `11`; GKWZ Thm 13.6 at printed p. 568, Section 13.2.
- **Binding constraints honoured.** No complexity bound is stated or implied; `Decidable
  (PlusValidZTime φ)` appears in this report only in sentences saying it is not stated; the
  semi-decidability caveat is carried verbatim below.

## Context & Scope

Requirement (W)'s anchor layer is landed (`AnchorLayer.lean`); its run layer is BLOCKED on three
obligations (`README.md`, "(W): what landed and what did not"): (i) a frame-scheme constructor
producing infinite-width, finitely branching regular frames from a finite object; (ii) a
Hit-level per-cell realization hypothesis; (iii) the presentation-size bound, now discharged at
every `k` by `kTypeOf_listSeg_replicate_eventually_periodic_bounded` with no `k` chosen. This
dispatch is phase 1 only: settle (i)'s design question — thread-indexed unfolding versus a
bounded-deadline encoding — and output the depth `k`; phases 2-3 become costable afterwards and
are not costed here. The semi-decidability caveat, carried verbatim from the README and binding
on this record's acceptance: "Without (iii), a landed composition theorem would read
`¬ PlusValidZTime φ ↔ ∃ object, …` over an UNBOUNDED run layer — at best semi-decidable — and
NOT `Decidable (PlusValidZTime φ)`."

Evidence tier: `lean_local_search` reported `index: unavailable` for both lookups made, so
existence checks here are grep-tier; every claim that matters was instead checked by reading the
declaration in its file or by compiling (`lake env lean`, exit 0, `#print axioms` read).

## Findings

### Codebase Patterns

**F1. Why width is forced, mechanically.** In this semantics the history set is ALL bi-infinite
step paths of the frame (`mem_HF_iff_adjacent`), and `⊡ψ` reads every path through a state
(`PlusTruth.stab_iff`, used by `stab_mem_tpOf_iff`). So a cell whose every type contains
`⊡(ψ U χ)` demands that NO path through the state defers `χ` forever. On a finite-width frame a
state reached by deferring chains of unbounded length is the end of an infinite deferring chain
(the König step `core_false` / `long_step` and the pigeonhole `exists_long` of
`no_finite_width_sat`), so the deferring chains into such a state must be of bounded length —
and `Φ`'s `D` clause forbids that bound. The `Node` frame resolves it by making the distance to
the discharge part of the state (`pre k`, `post k j`), i.e. by an unbounded counter. This is the
whole content of "INFINITE WIDTH IS FORCED": a `⊡`-forced eventuality whose pending region can be
entered by arbitrarily long chains needs a state-carried unbounded counter.

**F2. What the counter may NOT do (both refutations, re-read).** `Rbad` resets to `0` from any
level: forward branching finite (`Rbad_fwd`), backward preimage at the reset target infinite
(`Rbad_bwd_infinite`), fibre at `d = -1` infinite outright (`Rbad_fib_infinite`). `Rok` chooses
a fresh deadline at level `0`: backward finite (`Rok_bwd`), forward infinite at the commitment
state (`Rok_fwd_infinite`). The probe's own conclusion, quoted: "a commitment encoding for
liveness must bound the deadline it commits to (or otherwise finitize the choice) BEFORE
two-sided finite branching is available, and no rearrangement of where the reset fires
substitutes for that." The design question is therefore exactly: how is the unbounded deadline
of F1 fixed without any state choosing it.

**F3. How `Node` does it, and what that generalizes to.** In `Node`, `pre (k+1) → pre k` and
`pre k → x k`: every node has one predecessor and at most two successors (`bwdList`,
`fwdList`), yet the deadline `k + 1` is unbounded across states. The nondeterminism is pushed
into WHICH thread a history is on, and a thread's deadline is "chosen at `-∞`": the pre-chain
has no start (`bwd_from_x`). That works because every history of `Φ` has exactly one pending
region (`A'`, `C'`). A general closure formula has histories with pending regions recurring
forever (any model of `□⊡Fp` with `p` infinitely often), and the deadline of the NEXT region
must come from somewhere other than a state's choice. The deadline ladder is the generalization:
state `(q, c, n)` with `c` the current region's remaining length (deterministic countdown while
pending, `0` while idle, region ends exactly at `c = 0`) and `n` the next region's length,
drifting by at most one per step at every step (`Drift`, `Count` in the scratch). From `(q, c,
n)` the successor lies in `Q × {c - 1, n, 0} × {n - 1, n, n + 1}`; into `(q', c', n')` the
predecessor lies in `Q × {c' + 1, 0} × {n' - 1, n', n' + 1}`. Both are finite for finite `Q`;
the scratch proves it (`Rlad_fwd`, `Rlad_bwd`). The "no early discharge with leftover" clause
of `Count` is what keeps the backward side finite — an early discharge from arbitrary `c` would
be `Rbad`'s preimage again. `Node` is the ladder with drift `0` and no idle state. A fixed cap
`N` on both counters is the bounded-deadline encoding; it has finite width and is refuted by
`not_finite_width_fmp` for `Φ.neg`.

**F4. The regularity part is a transcription, measured.** `NoFiniteWidth.F` is built by hand as
`FrameOver.ofReflectiveRegular Node (ofStepRel Step) … (TaskFrame.saturation_of_fib_finite
fib_finite)` (`NoFiniteWidth.lean:244-290`, 47 lines including `fib_finite`, the instance,
`F_taskRel`, `F_step`); `FrameOver.ofStep` (`IntNormalForm.lean:456-507`, 51 lines with
`ofStep_isRegular`, `ofStep_taskRel`, `ofStep_step`) is the same body with
`saturation_of_finite` in the one slot. A generic `ofStepFinBranch W R hf hb fwd bwd` is
`ofStep`'s body with `saturation_of_fib_finite (fib_finite_of_finBranch …)` in that slot — the
time-indexed branching core already exists in Probe746 (66 lines, `iterS_fwd_finite`,
`iterS_bwd_finite`, `fib_finite_of_finBranch`, `saturation_of_finBranch`), and its
time-invariant twin is `NoFiniteWidth`'s `iter_fwd_finite`/`iter_bwd_finite`/`fib_finite` with
`Step` abstracted. The `ofSlicedStep` block through `ofSlicedStep_mem_HF_iff`
(`SlicedFrame.lean:283-356`, 73 lines) is the time-indexed shape with the history
characterization the realization theorem consumes (`frameOf_mem_HF_iff` is its instance). An
in-place generalization of `ofSlicedStep` remains prohibited (`[Finite W]` on 9 declarations,
17 referencing files, per the README — [CARRIED-UNVERIFIED: `RaySummary/README.md`, "(S): what
landed and what did not", last paragraph]); the constructor is parallel.

**F5. Seriality is an OBJECT condition, not a frame fact.** The scratch proves branching only.
Forward seriality of the ladder at `(q, 0, n)` with `pend q = true` needs a successor `q'` with
`pend q' = false` reachable in one step — i.e. the countdown's `0` must only be reached at
states that discharge next. Backward seriality into `(q, c, n)` needs a predecessor `(q'', c + 1,
n'')` (pending) or `(q'', 0, c)` (idle, handing over `n'' = c`). So the ladder's carrier must be
restricted to ADMISSIBLE counter values: `c ∈ Adm q`, the set of lengths of deferring paths from
`q` to a discharge, a decidable, eventually periodic subset of `ℕ` computable from the finite
object; and the object must satisfy run-layer consistency conditions playing the role `Cons`
plays in (S) (`serialFwd`/`serialBwd`, `ucoh`/`scoh`, and a reachability condition replacing
`ulive`/`slive` — the ladder makes `ULive`'s "no infinite deferring chain" true BY CONSTRUCTION,
since `c` strictly decreases while pending). Restricting the carrier to a subset preserves both
branching properties (a subset of a finite set is finite), so F3's verdict survives the
restriction. These conditions are named here and not costed.

**F6. The per-cell realization problem, made precise (phase 2's obstacle).** `cellAt M φ w z` is
the set of closure types of histories through `w`, time-independent (`cellAt_eq_cellAt`). In the
ladder model, the histories through `(q, c, n)` are exactly the ladder paths through it, and for
small `c` they are a PROPER subset of those through `(q, c', n')` with large `c'`: at `(q, 0,
n)` every history discharges at the next step, so a closure formula such as `¬ X χ` (or any
letter whose truth needs the region to last) is absent from every type there, while `⊡ X χ`
(if in the closure) is present — a type NOT in the set the object assigned to `q`. `Node`
exhibits exactly this: `pre 0` reads `⊡Xp` and `pre (k+1)` reads `¬⊡Xp`, two distinct cells for
one object state. Consequence: the object cannot assign one cell per `q`; its cells are indexed
by `(q, deadline class)`, and the Hit-level per-cell hypothesis of obligation (ii) must be stated
at ladder states, not at object states. Whether the realized type sets at `(q, c, n)` STABILIZE
in `c` past some bound syntactic in `φ` (so that finitely many deadline classes suffice) is
plausible — the closure has finitely many letters and `X`-nesting bounded by the closure — but
it is NOT proved anywhere and this report does not assert it. This is the mathematical core of
phase 2 and the reason phase 2 is not costable before it is settled.

**F7. COLLAPSE does not reach the ladder, and WIDTH does not either.** `stab_iff_of_presented_nowUnique`
needs trace-level `Presented` plus `nowUnique`; obligation (ii) is stated at `HitPresented`
(family-triple sets) per cell, with no `now`-uniqueness field, so the collapse theorem has no
hypothesis to bite on. `modelOf_incomplete` is about `ofSlicedStep` on a finite `Q`; the ladder's
slice is infinite (`Rlad_slice_infinite`), so `no_finite_width_sat` does not apply to it.
Neither probe is weakened or retired by this.

**F8. The depth.** All 17 depth hypotheses in `RaySummary/*.lean` read `hk : 1 ≤ k`
(`plusStab_iff_forall_hitCl`, `hit_eq_hitOf_of_presented`, `mem_hitOf_iff`,
`hitCl_modelOf_eq_hitOf`, `stabTarget_determined`, the `Transport.lean` lemmas, …); none asks
more, and `Probe745.hitPresented_modelA` holds at every `k ≥ 1`. The closure alphabet carries
every nested temporal subformula as a LETTER, so `X`-nesting and `untl`/`snce` nesting are
visible at depth 1 through letters, not through quantifiers; and the run conditions are to be
enforced structurally (F5), as (S) enforces them with `Cons` and `cons_localRun`. The larger
depth `3` (the `LocalRun.untl` clause `∀z (u z ↔ ∃s (z < s ∧ e s ∧ ∀r (z < r → r < s → g r)))`
is `all (… ex (… all …))`, `quantifierDepth = 3` by `MonadicFormula.quantifierDepth`) would be
needed only to make "is a local run" a `DeterminedByKType` target via `determinedByKType_eval`;
nothing landed takes that route and this report recommends against it, since
`Nat.card (KType sig k)` — a count, never a complexity bound — grows with `k`.

### External Resources

**Literature anchors, re-verified against the corpus text.** HWZ 2000 `chunk_0022` carries
Definition 12 verbatim — "Suppose f is a state function for ϕ over F and R a set of runs in f.
The pair m = ⟨f, R⟩ is called a quasimodel for ϕ (over F) if … for every w ∈ W and every t ∈ Tw,
there exists a run r ∈ R such that r(w) = t" — then Remark 13: "for any two sets of runs R1 and
R2 in f, if R1 ⊆ R2 and ⟨f, R1⟩ is a quasimodel for ϕ then ⟨f, R2⟩ is a quasimodel for ϕ as
well. Consequently, there exists a quasimodel for ϕ based on a state function f iff ⟨f, Ωf⟩ is
a quasimodel", and Theorem 14 with its (⇒) proof reading `f(w)` off a model; the chunk ends with
the page marker `11`, matching the dispatch's "PDF p.11". GKWZ 2003 `chunk_0589` carries, at
printed page 568 under "Chapter 13. Temporal epistemic logics", Theorem 13.6 for `L ∈ {K_n, T_n,
KD45_n, S5_n}` over first-order definable classes of strict linear orders, introduced as "a
general decidability theorem … by combining the kind of quasimodels introduced in Chapter 6
with the embeddings into monadic second-order theories of strict linear orders used in Chapter
11"; its conclusion is decidability (`chunk_0590`), via a quasimodel whose run set is chosen.
The briefing flags both corpus entries as UNVERIFIED-summary provenance; what was read here is
the ingested text of the papers themselves (the definitions are verbatim), and the paragraph
below cites them as a literature DESCRIPTION of the obstruction, not as a source for any claim
of this development.

**Where this semantics parts from the literature, in the terms the paragraph needs.** HWZ's
quasimodel chooses `f` (a state candidate per time) and `R` (a run set) freely, and Remark 13
says the run choice may always be taken maximal. Here: (a) the quasistate at every time is
`anchorCells M φ`, the same set at every time by `cellAt_eq_cellAt` (shift-closure); (b) the
runs are the task-respecting paths of ONE time-invariant relation (`mem_HF_iff_adjacent` on a
regular ℤ-frame; the ladder's `Rlad` ignores its time argument), closed under splicing
(`seamOmegaEquiv`) and under limits of chains (`blc_plusValid`); (c) the states carry both the
atoms and every `stab` formula (`stab_state_only`: `⊡φ` is a function of the world state). So
neither `f` nor `R` is chosen: both are read off the frame, and a run set that is a path set of
a finitely branching frame is pumping- and limit-closed, which is precisely what the Remark-13
freedom lets HWZ avoid.

### Recommendations

**R1 (phase 1 outcome, for the planner).** Adopt the deadline ladder as the frame scheme of
obligation (i). Land, in `RaySummary/RunLayer.lean` (named in the task's `file_scope`), a
parallel constructor `ladderFrame` — `ofReflectiveRegular` over the ladder carrier with
`Saturation` from `saturation_of_fib_finite` and the two-sided branching core — taking the
object's seriality conditions (F5) as explicit hypotheses exactly as `ofStep` takes `fwd`/`bwd`;
promote the scratch's three theorems into the wired evidence collection beside Probe746
(`specs/evidence/seam-gluing-ray-product/`, `WIRED` entry in `scripts/check-evidence-probes.sh`)
so the design decision is gate-compiled; and record `k = 1` in the README's (W) section. This is
costable from measured analogues (F4): 117-139 lines for the regularity part plus the 119-line
ladder core, before the admissibility restriction of F5, which is unmeasured. Sorry-free path:
expected, since every piece is a transcription of a landed proof with one slot changed.

**R2 (phases 2-3, for the planner: characterize, do not plan).** State phase 2 as: a Hit-level
realization theorem for `ladderFrame`, per LADDER CELL `(q, c, n)` (F6), under run-layer
consistency conditions analogous to `Cons`; its first lemma must be the stabilization-in-`c`
statement of F6, and until that lemma is stated and proved the phase has no cost figure. State
phase 3 as (C)'s general row verbatim, open, with one positive fixture and no negative, no
figure. Neither phase goes into this round's plan beyond a `[BLOCKED]`-style record of what it
needs, as the dispatch instructs ("DISPATCH STOPS HERE"). If a successor attempts phase 2 and F6's
stabilization fails, the honest outcome is `[BLOCKED]` with that obstruction named — not a
finite-fibre retreat, which reproduces a refuted shape.

**R3 (documentation deliverable).** Insert the paragraph in "The README paragraph" below into
the (W) section of `RaySummary/README.md` ("(W): what landed and what did not"), after the
"Successor" paragraph or beside the three obligations. It carries file names, theorem names,
author-year citations and section/theorem numbers only.

**R4 (what not to do).** Do not add a dependency edge to 749 (completed in any case). Do not
cap the ladder's counters. Do not state `Decidable (PlusValidZTime φ)` anywhere, including as a
hypothesis bundle. Do not cite the CTL⋆ 2EXPTIME ceiling as an upper-bound source. Do not
describe `Nat.card (KType (clSig φ) k)` or any cell count as a complexity bound.

### The README paragraph (deliverable text, hygiene-checked: no task numbers, no version language)

> **The obstruction has a literature description.** The quasimodel-realisation step of
> Hodkinson–Wolter–Zakharyaschev 2000, *Decidable fragments of first-order temporal logics*
> (Definition 12, Theorem 14 ⇐), and of Gabbay–Kurucz–Wolter–Zakharyaschev 2003,
> *Many-Dimensional Modal Logics* (Theorem 13.6, the Chapter 6 quasimodels combined with the
> Chapter 11 monadic second-order embeddings), presupposes a freely chosen state function `f`
> and run set `R`: a quasimodel is a pair `⟨f, R⟩`, and HWZ Remark 13 (PDF p. 11) makes the run
> choice free in both — any superset of a quasimodel's run set is again one, so `⟨f, Ω_f⟩` with
> ALL runs may always be taken. In this semantics neither choice exists. The quasistate at every
> time is the type set realised by the history set, and by shift closure it is the SAME set at
> every time (`cellAt_eq_cellAt`, `AnchorLayer.lean`); and the runs are the task-respecting
> paths of ONE time-invariant relation (`mem_HF_iff_adjacent`, `Semantics/IntNormalForm.lean`),
> closed under splicing (`seamOmegaEquiv`) and under limits of chains (`blc_plusValid`), whose
> states carry both the atoms and every `stab` formula (`stab_state_only`,
> `PlusLanguage/PlusTruth.lean`). A run set that is the path set of a frame cannot be chosen
> maximal, pruned, or chosen at all; that is the condition under which published quasimodel
> realisation stops applying, and it is exactly what (W)'s soundness half is about.

## Decisions

- **D1.** The frame scheme is the deadline ladder (thread-indexed unfolding with two counters
  and ±1 drift), not a bounded-deadline encoding. Grounds: F1-F3; machine-checked branching in
  `evidence/01_deadline-ladder-branching.lean`; the two bounded variants are each refuted by a
  landed theorem (`not_finite_width_fmp`; `Rok_fwd_infinite`/`Rbad_bwd_infinite`).
- **D2.** `k = 1`. Grounds: F8. `k = 3` is recorded as the depth of the alternative (type-read
  run conditions) and rejected.
- **D3.** Obligation (i) is split: the regularity part is a transcription (measured, F4); the
  seriality/admissibility part is an object condition (F5, unmeasured); the realization part is
  phase 2 (F6, uncostable until its stabilization lemma is stated).
- **D4.** The HWZ/GKWZ paragraph is cited as a literature description only, with the corpus
  provenance flag noted in this report and not propagated into the README sentence (the README
  already carries a provenance disclaimer for HWZ 2000 in "(S): what landed and what did not").
- **D5.** The scratch is left in the task directory (`evidence/`) as research evidence; promoting
  it to a wired probe is an implementation step (R1), not done here.

## Risks & Mitigations

- **R-A. F6's stabilization may fail**: the realized type sets at `(q, c, n)` might not become
  constant in `c`, leaving infinitely many distinct cells and no finite object. Mitigation: make
  the stabilization lemma phase 2's FIRST statement, prove or refute it on `Node` first (where
  the cells are `pre 0`, `pre (≥1)`, `x`, `post` — four, finite), and treat a refutation as the
  obstruction that marks the route `[BLOCKED]`.
- **R-B. The ±1 drift constrains region lengths** (`L_{i+1} ≤ 2·L_i + gap_i` along a history),
  so some infinite patterns of pending-region lengths are not ladder paths. Mitigation: the
  Hit-level hypothesis is a statement about FAMILY-TRIPLE sets, which are realized by ultimately
  periodic colourings (`kTypeOf_listSeg_replicate_eventually_periodic_bounded`, the
  `Transport.lean` cut surgery) whose region lengths are bounded; whether every realized triple
  has a ladder-path witness is a phase-2 lemma, named here, not claimed.
- **R-C. Seriality at `c = 0`** fails on an object with a forced one-step deferral. Mitigation:
  the admissibility restriction of F5 (carrier `{(q, c, n) | c ∈ Adm q}`); branching is
  inherited by the restriction.
- **R-D. Several `⊡`-forced eventualities.** One ladder pair per `untl`/`snce` letter gives a
  counter vector; forward and backward branching stay finite (a product of finitely many
  three-element choices), and `snce` letters run the ladder with the two sides exchanged.
  Unmeasured.
- **R-E. Reading too much into "two-sided finite branching".** It buys `Saturation` and hence
  regularity; it does not buy realization. The scratch's header says so; the README paragraph
  must not say more.
- **R-F. Evidence tier.** `lean_local_search` was unavailable; the compensating evidence is the
  compiled scratch and the file reads listed under Sources, each at a cited line range that was
  opened in this session.

## Literature Proof Structure

**Source**: Hodkinson–Wolter–Zakharyaschev 2000, *Decidable fragments of first-order temporal
logics*, Definitions 10-12, Remark 13, Theorem 14 (corpus `chunk_0021`-`chunk_0022`);
Gabbay–Kurucz–Wolter–Zakharyaschev 2003, Theorem 13.6 (corpus `chunk_0589`-`chunk_0590`).
**Strategy**: satisfiability ⇔ existence of a quasimodel `⟨f, R⟩`; (⇒) read `f` and `R` off a
model; (⇐) build a model whose domain IS the chosen run set.

### Step Map
1. State candidates and the state function `f : W → quasistates` — HWZ Def 10. Here: `anchorCells
   M φ`, constant in time (`cellAt_eq_cellAt`); the anchor layer, landed.
2. Runs: functions `r : W → ⋃ T_w` satisfying the `U`/`S` clauses — HWZ Def 11. Here:
   `LocalRun` on closure traces (`Closure.lean`), with `clTrace_localRun`.
3. Quasimodel `⟨f, R⟩`: every `⟨t, c⟩` in `T^con_w` is a run, and every type at every time lies
   on some run in `R` — HWZ Def 12. Here: the per-cell Hit-level realization hypothesis of
   obligation (ii).
4. Run choice is free and may be taken maximal (`Ω_f`) — HWZ Remark 13. Here: NO counterpart;
   the run set is the path set of the frame (`mem_HF_iff_adjacent`). This is the step the README
   paragraph records as the obstruction.
5. (⇒) read `f`, `R` off a model — HWZ Thm 14 proof. Here: `anchorCons_anchorCells` at the cell
   level (landed); the run-layer half is phase 3.
6. (⇐) build the model on `R` with persistent runs — HWZ Thm 14. Here: for one seam,
   `presented_modelOf` (landed, (S)); closure-wide, phase 2 on the ladder frame.
7. Decidability by MSO embedding over the flow — GKWZ Thm 13.6. Here: not attempted; the
   semi-decidability caveat applies and no decidability statement is made.

### Dependencies
- Step 3 depends on Steps 1-2; Step 6 depends on Step 3 and, decisively, on Step 4's freedom.
- Step 7 depends on Step 6 and on a bound (obligation (iii)); without it the statement is
  semi-decidable at best.

### Potential Formalization Challenges
- Step 4: the freedom does not exist here; the ladder frame (D1) is the proposed replacement,
  and its realization (Step 6) is F6's open stabilization question.
- Step 6: `⊡`-letters must be realized per cell (never trace-level: `stab_iff_of_presented_nowUnique`).
- Step 7: forbidden as a statement in this record (`Decidable (PlusValidZTime φ)`).

## Tactic Survey Results

Survey performed on the scratch's goals only (the research deliverable is a design decision;
`lean_multi_attempt`/`lean_hammer_premise` were not used, the server index being unavailable).

| Goal | Tactic | Result | Premises/Config |
|------|--------|--------|-----------------|
| `(tri a b c).Finite` | `Set.toFinite _` | fail | `Finite ↑(tri a b c)` not synthesized on a three-element literal |
| `(tri a b c).Finite` | `((Set.finite_singleton c).insert b).insert a` | success | explicit `Set.Finite.insert` chain |
| `Rlad_fwd` membership in `{c-1, n, 0}` | `split_ifs at hc` then `omega` / `exact` | success | `Count` unfolded by `simp only [Count]` |
| `Rlad_fwd`/`Rlad_bwd` membership in `{n-1, n, n+1}` | `omega` | success | after `simp only [Drift, tri, Set.mem_insert_iff, Set.mem_singleton_iff]` |
| `Rlad_bwd` membership in `{c'+1, 0}` | `split_ifs` + `by_cases hp : pend q = true` | success | uses the `(pend x.1 = false → x.2.1 = 0)` and no-leftover clauses |
| `¬ Finite (Q × ℕ × ℕ)` | `Finite.of_injective` + `not_finite ℕ` | success | `Classical.arbitrary Q` |

## Context Extension Recommendations
- **Topic**: deadline-ladder unfolding as a frame scheme.
- **Gap**: `.claude/context/project/lean4/` has no note on the two refuted countdown shapes and
  the ladder that avoids them; a successor agent re-deriving F1-F3 from the probes costs a
  session each time.
- **Recommendation**: once R1 lands, add a short pattern note under
  `context/project/lean4/patterns/` pointing at `Rlad`, Probe746's `Rbad`/`Rok`, and
  `NoFiniteWidth.Node`, stating the branching verdict and the F6 open question in one paragraph.

## Appendix

- Searches: `grep -rn "¬ HitPresented\|not_hitPresented\|¬HitPresented" specs/evidence/seam-gluing-ray-product/ FormalSystem/Metalogic/Decidability/RaySummary/` → 0 lines; `grep -rn "hk : 1 ≤ k" RaySummary/*.lean` → 17; `grep -rn "2 ≤ k\|3 ≤ k" RaySummary/*.lean KTypeSummary/*.lean` → 0; `lean_local_search anchorCons_anchorCells`, `FrameOver.ofStep` → hits with `index: unavailable`.
- Corpus: `grep -rn -i "remark 13\|definition 12\|Theorem 14"` over the HWZ chunks; `grep -n -i "theorem 13.6"` over the GKWZ chunks.
- Compile: `timeout 600 lake env lean specs/750_w_run_layer_closure_wide_lift/evidence/01_deadline-ladder-branching.lean` — first run: one error (`Finite ↑(tri a b c)`), second run: exit 0, three `#print axioms` lines each `[propext, Classical.choice, Quot.sound]`.
- Line measurements: `IntNormalForm.lean:456-507` (51), `SlicedFrame.lean:283-356` (73), `NoFiniteWidth.lean:244-290` (47), `b2b-frame-constructor-branching.lean:108-173` (66), scratch 119.
- Issue log: two entries written via `issue-record.sh` (tooling/minor: LSP index unavailable; win/none: scratch compiled on the second attempt).
