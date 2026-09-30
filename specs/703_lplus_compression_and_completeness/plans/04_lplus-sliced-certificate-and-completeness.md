# Implementation Plan: L⁺ Certificate Limits and the Time-Sliced Certificate

- **Task**: 703 - lplus_compression_and_completeness
- **Status**: [IMPLEMENTING] (Phases 1-8 landed; Stage 2 amended at plan v4, Phases 13-21 re-authored)
- **Effort**: 67 hours (16 landed in Phases 1-8; 13 in Stage 1, Phases 9-12; 38 in the amended
  Stage 2, Phases 13-21)
- **Dependencies**: `FormalSystem.PlusLanguage.plusValidZTime_iff_plusValidInt` (landed,
  `FormalSystem/PlusLanguage/PlusIntTransfer.lean`) — still required by the Stage 3 successor
  named under Non-Goals, and no longer on this plan's own critical path, for the reason given
  under "What the carrier-normalization prerequisite now buys" below; the redesigned sharing
  substrate as finally corrected, i.e.
  `FormalSystem.Metalogic.Decidability.SharingSkeleton` together with
  `FormalSystem.Metalogic.Decidability.PlusSharingWitnessFamily` and its `trans`/`share`
  projections (landed). See "Dependency statement by declaration name" below for the
  `trans_refl` follow-on and for the declarations the amended Stage 2 adds.
- **Research Inputs**:
  - `specs/703_lplus_compression_and_completeness/reports/01_lplus-compression-completeness-research.md`
  - `specs/703_lplus_compression_and_completeness/reports/02_semantics-first-compression-research.md`
  - `specs/706_lplus_finite_model_property_and_completeness/reports/01_lplus-finite-model-property-research.md`
    (cross-task; the report that forces this revision)
- **Artifacts**: plans/04_lplus-sliced-certificate-and-completeness.md (this file)
- **Reports Integrated**: `01_lplus-compression-completeness-research.md`,
  `02_semantics-first-compression-research.md`,
  `706/01_lplus-finite-model-property-research.md`
- **Plan Version**: 4 (revision of `plans/02_lplus-certificate-limits-graph-certificate.md`;
  artifact number 03 is deliberately skipped — the artifact counter, not the file listing, is
  authoritative)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

The theorem this task was originally asked to prove is **false**, and the refutation is
machine-checked. `specs/703_lplus_compression_and_completeness/probes/NoFiniteCertificate.lean`
proves that a specific ℤ-time non-validity of a `PlusFormula` admits **no**
`PlusSharingWitnessFamily` satisfying `PlusCertifies` at any time, for every lasso count, every
segment length and every succession relation. No choice of bounds repairs it. **Stage 1** turns
that refutation into library declarations and corrects every piece of in-tree documentation that
overstates the landed certificate class's coverage. Stage 1 is unchanged by this revision.

**Stage 2 is amended by this revision, before Phase 13 is started.** Plan v2's Stage 2 built a
certificate over a *finite* bi-serial one-step graph (`FrameOver.ofStep` on `Fin n`). That
certificate class is now known to be the wrong shape:
`specs/706_lplus_finite_model_property_and_completeness/probes/NoFiniteCarrierModel.lean` proves,
sorry-free, that the finite-carrier finite model property **fails** for L⁺ over ℤ-time. Stage 2 is
therefore re-authored around a **time-sliced** certificate whose presented frame has the infinite
carrier `ℤ × Fin n` with finite fibres. Stage 3, the finite model property for the sliced class
and hence full completeness, remains an explicit **non-goal** and is specified below as a
separate, research-first successor that is **not filed here**.

Definition of done: Stages 1 and 2 land sorry-free with no new axioms, every new flagship carries
a `docs/theorem-index.md` row and a C2 `AXIOM_BASELINE` pin, and
`bash scripts/check-module-invariants.sh` passes in full.

### Amendment record — why Stage 2 changed at plan v4

**The `PlusGraphCertificate` of plan v2 is WITHDRAWN as a certificate class.** This is a defect in
the **type**, not in a bound: no value of `n`, no change to the checker's clauses, and no
alternative liveness formulation repairs it.

- **Evidence**: `specs/706_lplus_finite_model_property_and_completeness/probes/NoFiniteCarrierModel.lean`,
  declarations `Probe706.no_ofStep_sat`, `Probe706.no_finite_carrier_sat`,
  `Probe706.not_finite_carrier_fmp`, `Probe706.not_plusValidZTime_neg_θ`. Sorry-free; axioms
  `[propext, Classical.choice, Quot.sound]`. Recompile from the repository root with
  `lake env lean specs/706_lplus_finite_model_property_and_completeness/probes/NoFiniteCarrierModel.lean`
  (about three seconds). Treated here as established fact, not as a claim to re-litigate.
- **The witness**: `θ := □(p ∨ Fp ∨ Pp) ∧ □(p → ¬Pp)` — "every history meets `p` somewhere, and
  never twice". It is ℤ-time satisfiable (on the shift set with carrier `ℤ`, `p` true exactly at
  state `0`), so `θ.neg` is a genuine ℤ-time non-validity; and it is satisfied at **no** history
  and time of **any** regular ℤ-frame whose `WorldState` carrier is `Finite`. The argument is
  pigeonhole plus limit closure: a history meets `p` at some `a`, is `p`-free to the left of `a`,
  and a repeated state to the left of `a` pumps into a bi-infinite step path — hence a history,
  by `FrameOver.mem_HF_iff_adjacent` — that never meets `p`.
- **Why it hits plan v2's type exactly**: `PlusGraphCertificate`'s five carrier fields `n`,
  `n_pos`, `stepR`, `stepR_fwd`, `stepR_bwd` are literally `IntPresentation`'s `card`,
  `card_pos`, `step`, `fwd`, `bwd`, and plan v2's Phase 13 defines
  `G.frame := FrameOver.ofStep …`. A certified `G` for `[] ⊢ [θ.neg]` would therefore be a model
  of `θ` on a finite-carrier regular ℤ-frame, which `no_ofStep_sat` forbids.
- **`θ` is `⊡`-free** (`Probe706.θ_eq_ofFormula`, by `decide`). So plan v2's class is **strictly
  weaker than the already-landed L witness family on stability-modal-free targets**: the L family
  certifies every ℤ-time non-validity of L
  (`exists_witnessFamily_of_not_validZTime`, `WitnessFamily/Compression/Family.lean:153`),
  including `θ.neg`, which no `PlusGraphCertificate` can certify.
- **The CTL-like fragment does not rescue it** (`Probe706.not_finite_carrier_fmp_fragment`, for
  `θ' := □(p ∨ ⊡Fp ∨ ⊡Pp) ∧ □(p → ⊡¬Pp)`, every `⊡` and `□` governing a state formula or a single
  temporal operator). The sliced shape is needed already for the fragment.
- **What is withdrawn and what is not.** Withdrawn: the structure `PlusGraphCertificate` with its
  finite carrier, its `stateLab`/`stateLab_sub` fields and its `witness` field; the theorem
  `exists_plusGraphCertificate_of_finite_countermodel`; and the frame construction
  `G.frame := FrameOver.ofStep …`. **Not** withdrawn and carried forward unchanged in shape:
  `PlusGraphPath` (the three-segment labelled-path readout), the four clause groups of
  `Certifies`, the computed-liveness design, and the soundness theorem's conclusion
  `PlusWitnessFamily.PlusRefutes Γ Del`.
- **Nothing is lost.** The finite graph is recovered as the one-slice special case of the amended
  type: `back = fwd = [slice]`, `mid = []`.
- **Plan v1 of this very task already committed to a statement that turned out false.** That is
  why this plan commits to **no bound** on the slice width and to **no order** for the tail
  periods. See "Bounds: none, deliberately" below.

### Withdrawal record — read this before resurrecting anything

**The Lean Challenge Statement of plan v1 is WITHDRAWN.** The withdrawn statement was
`FormalSystem.Metalogic.Decidability.exists_plusSharingWitnessFamily_of_not_plusValidZTime`,
together with the bound `plusFamilyBound` it quantified over. It is not blocked, not
under-resourced, and not waiting on a better bound: **it is false**, and this plan carries the
refutation into the library precisely so that a later reader meets it as a theorem rather than
as a finding in a report.

- **Evidence**: `probes/NoFiniteCertificate.lean`, declaration `Probe703.compression_statement_fails`.
  Sorry-free; axioms `[propext, Classical.choice, Quot.sound]`. The orchestrator independently
  recompiled it, and `probes/HopFreeIncomplete.lean`, at dispatch 20. Treated here as established
  fact, not as a claim to re-litigate.
- **Root cause**, from research report 02 section 2.5: the presented frame is limit closed, so a
  path postponing an eventuality for any finite length exists and needs a truthful thread; the
  certificate is finite and eventually periodic, so long postponements can be pumped; and (C2')
  quantifies over **all** threads, so the pumped thread must fulfil, and it cannot. The landed
  class can express only safety structure on threads, while the true type sequences of a
  branching model are defined by a fairness condition.
- **Scope of the failure**: not a corner case. Any target whose countermodels must contain, in a
  periodic region, a cycle with an exit under a pending eventuality is affected.
- **The three Phase 8 BLOCKER resolutions of plan v1 are NOT carried forward.** Widening the
  `mid` bound, reinstating a common cycle length by strengthening Phase 4, and seeking a
  seam-preserving rotation each change a bound or a construction and leave the certificate class
  alone, so each inherits the refutation. They fail the gate criterion (the target statement must
  be true). They are recorded in `plans/01_lplus-compression-completeness.md`, which is retained
  unedited as history; nothing in this plan depends on them and no phase should reopen them.
- **The cycle-6 decision to drop Invariant A is moot**, not overturned. It was sound reasoning
  about a route that does not reach a true theorem. It is preserved in `.decisions.json` and in
  Phase 7 below because the work it governs is landed and stays landed.
- **Also not carried forward**: plan v1's Phases 9 through 13 (`Rep.lean`, `Lift.lean`,
  `Stab.lean`, `Family.lean` and the gate phase that pinned the withdrawn theorem). All five were
  `[NOT STARTED]`, all five exist only to serve the withdrawn statement, and none of the four
  Lean files was ever created. **Do not create them.**

### The amended Stage 2, stated concretely

Seven changes, taken from report 706 section Q1.4 items 1-7 and followed exactly. Phases 13-21
below implement them.

1. **The carrier becomes time-sliced.** `stepR`, `stepR_fwd`, `stepR_bwd`, `stateLab` and
   `stateLab_sub` are replaced by a `PlusSlice` structure — per-slice `edge`, `lab`, `lab_sub` —
   plus three segments `back` / `mid` / `fwd` of slices, decoded by the **same** three-segment
   readout `PlusGraphPath` already uses (`WitnessFamily/Compression/Extract.lean`'s `getD_mapC`,
   `readout_backC`, `readout_midC`, `readout_fwdC`). Bi-seriality is **per slice**, decided on the
   window `[-nb, nm + nf)` and extended to all `t` by periodicity, exactly as
   `WitnessFamily/Decide.lean`'s `coherent_iff_window` does on the L side.
2. **The `witness` field is dropped.** Its index set would be `ℤ × Fin n`, which is infinite. It
   was already redundant in plan v2 given **both** directions of the liveness characterization:
   "`⊡χ ∉ slab t w`" is "some live position over `(t, w)` omits `χ`", and a live position *is* a
   witness path.
3. **The presented frame has carrier `ℤ × Fin n`.** It is built the way `SharingSkeleton.frame`
   already is (`WitnessFamily/Sharing/Skeleton.lean:1404`): a literal `FrameOver intOrder`, a
   two-sided relation, reflection by symmetry, *Limit* by `TaskFrame.limit_of_succOrder` at the
   zero-duration law, and *Saturation* by `TaskFrame.saturation_of_fib_finite`
   (`Semantics/TaskFrame.lean:2222`), whose docstring names exactly this case — infinite carrier,
   finite fibres. **`FrameOver.ofStep` cannot be used**: it requires `[Finite W]`
   (`Semantics/IntNormalForm.lean:456`). The reusable form is a generic
   `FrameOver.ofSlicedStep`. Shift invariance (`plusTruthAt_timeShift`) lets every truth question
   be asked at offset `0`, so a position is `(t, w)` with `t` the slice time.
4. **Positions and liveness become two-regime, and tail-stability is required.** Forward liveness
   from the back tail is **not** periodic in `t` in general: it depends on the distance to the
   window. Phase 16 carries report 706's concrete four-state counterexample as its **named test
   fixture** and scope hypothesis — back-tail slice `{a, b}` with edges `a→a`, `a→b`, `b→b` and
   `q` true at `b` only; `mid = [c]` with `a→c`, `b→c`; forward tail `{d}` with `c→d`, `d→d`; then
   `⊡(XX¬q)` is **true** at `(-1, a)` and **false** at `(-2, a)`. So the checker must not read
   tail stability-labels at one residue only. The certificate is therefore required
   **tail-stable**: compute `L₀` from the window and the forward tail, then `Φ_back L₀`, and
   demand `Φ_back L₀ = L₀` (mirror for the forward tail). A certificate whose tails are not yet
   stable is **re-presented** with the pre-period absorbed into `mid` and the period multiplied by
   the cycle length; the frame — and hence truth — is unchanged. This keeps the checker one `Φ`
   application beyond plan v2's fixpoints and every clause decidable on the window.
5. **`Certifies` keeps its four clause groups** — existential from liveness, universal, box,
   target — all read on the window under tail-stability. Plan v2's Phase 15 constraint survives
   verbatim: no clause may quantify over a time in a way that would need alignment. Nothing is
   aligned; the slice time is the only time.
6. **Relative completeness is relative to tail-stable sliced models**, and a **new phase** proves
   the landed L witness family **embeds**: a `WitnessFamily [] [φ]` with `k` lassos becomes a
   sliced certificate with `n = k`, edges `i → i` only, `slab t i` the atoms and `bx`-boxes of
   `(lassos i).lab t`, and tails and window taken from the lassos' common periods (their product,
   as `perBack` in `PlusWitnessFamily/Decide.lean:181` already computes). With
   `plusTruthAt_ofFormula` this yields
   `∀ φ : Formula, ¬ PlusValidZTime (ofFormula φ) → ∃ G : PlusSlicedCertificate [] [ofFormula φ], G.Certifies`.
   This restores parity with L, proves the class is **non-vacuous on branching-free targets**, and
   is **the only completeness theorem this research supports**.
7. **Cost.** Phases 13-17 grow by roughly the tail-stability mechanism and the sliced frame
   (+8-12 h on plan v2's 10 h for its Phases 13-15); soundness is unchanged in shape; the
   embedding phase is new (~4 h).

**Report 706's item 6 calls the embedding phase "Phase 17b". This plan calls it Phase 20.**
Letter-suffixed sub-phase numbers are prohibited by `plan-format.md`'s "Canonical phase-heading
shape" — no consumer in this codebase recognizes them — so the phase is given its own integer
number instead. Where report 706 says "Phase 13-17" it means plan v2's numbering; this plan's
Stage 2 is Phases 13-21.

### The alternative substrate, considered and not taken

Report 706 states an **alternative amendment with the same content on a different substrate**:
keep the landed `SharingSkeleton` (share-classes of `(index, time)` pairs, periodic in both
tails, frame already built, histories already characterized by `SharingSkeleton.total_eq_thread`)
and replace the all-threads (C2') condition by computed liveness on the folded class graph. This
is 703 round-2's candidates G and H combined.

**It is not taken.** Recorded reasons, in the order they weigh:

1. A **slice is the natural unit** of the semantics being presented, and the paired model
   checker's registry already folds by period — so the sliced graph is the shape both sides
   converge on, and report 706's Q7 item 2 names it as the intended wire contract.
2. The alternative inherits the **row-against-absolute-time representation** whose costs (a), (b)
   and (d) the round-2 report diagnosed. Those costs are what produced plan v2's alignment
   machinery, which this plan's Phase 15 constraint exists to keep out.
3. Its genuine advantage — **it reuses more landed code** — is real and is recorded here rather
   than dismissed. It is outweighed by (1) and (2), and partly recovered anyway: the sliced
   frame is built from `SharingSkeleton.frame`'s own template and the same two `TaskFrame`
   lemmas, and the three-segment readout is reused verbatim.

If Phase 14 or Phase 16 fails in a way that is specific to the sliced substrate rather than to
the mathematics, this alternative is the first thing to reconsider, and this section is the
record of what it costs.

### Bounds: none, deliberately

**This plan commits to no bound on the slice width `n`, and to no order for the tail periods.**

- None is proved. Report 706's Q4 records the honest expectation — **doubly exponential** slice
  width for full L⁺ — as an expectation and not as a theorem: a singly exponential,
  polynomially-checkable certificate would place a 2EXPTIME-hard problem in co-NEXPTIME. Singly
  exponential width is expected only for the CTL-like fragment.
- The natural tail-stability argument iterates `Φ` on subsets of `Fin n × H`, giving a pre-period
  plus period of at most `2^(n · 2^κ)` — a third exponential — but that is an **artefact of that
  argument**, and report 706 explicitly declines to claim any order for the periods. This plan
  declines likewise.
- **Plan v1 of this task committed to a statement that turned out false.** That is the direct
  reason for this section. No phase below may state a width bound, a period bound, or a
  complexity claim as a theorem of this tree.
- What *is* proved and stays: the per-history **segment** bound `plusCompressionBound`
  (`PlusWitnessFamily/Compression/Extract.lean:116`), singly exponential in
  `κ := |plusClosureOf (Γ ++ Del)|`, which bounds the target path's and any witness path's
  segments and is unaffected by this revision.

### Research Integration

This plan integrates `specs/706_lplus_finite_model_property_and_completeness/reports/01_lplus-finite-model-property-research.md`
(a **cross-task** report; 703's own `reports/` has nothing new since plan v2) on top of
`reports/02_semantics-first-compression-research.md` (round 2, semantics first) and
`reports/01_lplus-compression-completeness-research.md` (round 1). Where they disagree, the later
report supersedes.

**From report 706 (new at this revision):**

- **Q1.1-Q1.2 — the finite-carrier finite model property fails, and it is the type.** Recorded in
  full in the Amendment record above. `[checked]`.
- **Q1.3 — what plan v2's Stage 2 would still have delivered, and what it loses.** Its relative
  completeness theorem would have remained true; but the class is strictly weaker than the landed
  L class on `⊡`-free targets, and the export expectation plan v2's Phase 12 relays ("the search
  bound is a bound on the number of world states") is **wrong in kind** — there is no finite
  number of world states to bound. See the Phase 12 amendment note.
- **Q1.4 items 1-7 — the amendment.** Implemented by Phases 13-21. `[argued]` as a design;
  its one visible failure mode is tail-stability, carried as risk R2 below.
- **Q3 — the CTL-like fragment does not rescue the finite-graph shape** (`[checked]`,
  `not_finite_carrier_fmp_fragment`). The fragment's own finite model property is a separate,
  research-first successor and is **not planned in this task**.
- **Q4 — bound order.** See "Bounds: none, deliberately" above.
- **Q5 — the two-sided stability modal factors.** Histories through `w` at `t` are pasts × futures
  (`FormalSystem.PlusLanguage.paste`, S4, needing only Compositionality), and a Hintikka labelling
  of a bi-infinite path with origin type `h` is a backward half and a forward half agreeing at the
  origin (S5, `truth_paste_of_type_eq`, checked in this task's own
  `probes/TypePreservingPaste.lean`). Hence `⊡¬ψ` at `w` holds iff, for each Hintikka type `h`,
  either no backward continuation lies in `L(N_b^h)` or no forward continuation lies in
  `L(N_f^h)` — by the elementary equivalence `(∀ρ ∀σ, P ρ ∨ Q σ) ↔ ((∀ρ, P ρ) ∨ (∀σ, Q σ))`. The
  backward condition is the forward one on the reversed graph (`PlusFormula.reflectTime`). **This
  is folded into Phase 15 as an explicit named lemma, not as a rationale**: it is exactly what
  justifies `live = fwdLive ∩ bwdLive`.
- **Q7 — the paired model checker.** The finite graph must **not** become an export contract; the
  intended contract is the time-sliced graph, of which the current lasso family is the special
  case with edges `i → i` only, so the wire format is a strict extension rather than a
  replacement. The search bound is a tuple `(n, nb, nm, nf)` and **no bound on `n` is proved for
  any L⁺ target**. Phases 12 and 21 own the recording; neither writes to that repository.

**From reports 01 and 02 (unchanged at this revision, restated because they remain binding):**

- **Round 1's O2 and O3 answers are superseded.** O3's lasso-count bound does not exist for the
  landed class, because for some targets no family exists at all. O2's general liftable `trans`
  construction serves a withdrawn route.
- **Round 1's O1 and O4 answers stand.** `LiftableRaw` is decidable by subset construction, and
  no GKWZ-style product-undecidability result bounds this combination. Neither is on this plan's
  critical path; both are recorded so a later task does not re-derive them.
- **Round 1's F3 was wrong**: splicing two histories of a regular frame at a common state **does**
  yield a history — `FormalSystem.PlusLanguage.paste` constructs it from Compositionality alone.
  The true seam fact is that a *label row* splices only where state and type agree, proved in
  `probes/TypePreservingPaste.lean`. The corresponding risk row of plan v1 is retired.
- **The five structural facts (S1-S5) of report 02 Part 1 are this plan's semantic ground.**
  Over ℤ a regular task frame is a bi-serial one-step graph whose histories are exactly the
  bi-infinite step paths (`FrameOver.mem_HF_iff_adjacent`); truth is shift invariant
  (`plusTruthAt_timeShift`); `⊡` is state determined (`stab_state_only`); the histories are fusion
  closed and limit closed; and type-preserving pasting is the correct seam lemma. Stage 2's design
  is read off these five facts plus report 706's Q1.1 and nothing else.
  **One correction at this revision**: report 02's section 1.3 conclusion "period one and no time
  origin" is refuted by `θ`. A countermodel to `θ.neg` must have a time at which something happens
  once, so its state space cannot be both time-homogeneous and finite. Report 02's S1-S5 remain
  true; only the time-homogeneity inference drawn from them does not.
- **Complexity, stated at its true order.** CTL\* satisfiability reduces to L⁺ ℤ-time
  satisfiability, so ℤ-time validity of L⁺ is 2EXPTIME-hard. Report 706's Q4 completes both
  directions of that reduction, still `[argued]`, not machine-checked. The landed **segment**
  bounds of Phases 3-7 are singly exponential and true, but they bound one history's type sequence
  and say nothing about the state space.

### What the carrier-normalization prerequisite now buys

`FormalSystem.PlusLanguage.plusValidZTime_iff_plusValidInt` was Step 0 of the withdrawn
compression theorem: the rewrite that normalizes an arbitrary discrete duration carrier to `ℤ`
before a countermodel is dissected. Under the re-scoped target **no phase of Stage 1 or the
amended Stage 2 needs it**: Stage 1 refutes certificate existence, and Stage 2 goes from a
tail-stable sliced countermodel to a certificate and back to `PlusRefutes`.

One qualification is new at this revision. Phase 20's embedding theorem is stated at
`¬ PlusValidZTime (ofFormula φ)` and discharges it through the **landed** L-side
`exists_witnessFamily_of_not_validZTime`, whose own Step 0 is the `Formula`-side
`validZTime_iff_validInt`, already landed and already used at
`WitnessFamily/Compression/Family.lean:165`. So Phase 20 consumes a landed transfer rather than
needing the L⁺ one. `plusValidZTime_iff_plusValidInt` remains a genuine prerequisite of the
**Stage 3 successor**, which starts from `¬ PlusValidZTime φ` for an arbitrary `PlusFormula`, and
the dependency is therefore retained in the metadata block rather than dropped.

### Corrections to the dispatch's inherited path claims

Both corrections come from round 1 and are retained because both are still true.

1. `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Compression/Family.lean:165` does not
   exist and will not be created — see the withdrawal record. The `rw [validZTime_iff_validInt]`
   that is Step 0 lives in the `Formula`-side file
   `FormalSystem/Metalogic/Decidability/WitnessFamily/Compression/Family.lean:165`.
2. The acceptance gate the dispatch calls "a C2 `AXIOM_BASELINE` pin" is real. The `Formula`-side
   compression theorem is pinned by **C14**, not C2, but every landed `PlusSharingWitnessFamily`
   flagship is pinned by **C2**, so the new L⁺ declarations follow the L⁺ convention and go in
   the C2 pair. Phases 12 and 21 own this.

### Dependency statement by declaration name

Stated by fully-qualified declaration name rather than by task number, including the follow-on
that has been proposed but not filed.

- **Required and used by Stage 1** (the refutation quantifies over them, so they must not move):
  `FormalSystem.Metalogic.Decidability.PlusSharingWitnessFamily` and its `trans`, `share`, `L`,
  `lassos` and `bx` projections; `...PlusSharingWitnessFamily.PlusCertifies`; the six condition
  predicates in `PlusWitnessFamily/Predicates.lean`;
  `FormalSystem.Metalogic.Decidability.SharingSkeleton.Thread` and its `step` field;
  `...SharingSkeleton.transRaw_congr_NF` and `...data_congr_fwd` (the pumping step);
  `FormalSystem.PlusLanguage.PlusNonValidities.NF` and `natModel` (the refuting frame).
- **Required and used by the amended Stage 2**:
  `FormalSystem.Semantics.FrameOver.mem_HF_iff_adjacent`,
  `...FrameOver.worldHistoryOfStepPath`, `...FrameOver.taskRel_eq_iter`;
  `FormalSystem.Semantics.TaskFrame.limit_of_succOrder` (`Semantics/TaskFrame.lean:1591`) and
  `...TaskFrame.saturation_of_fib_finite` (`Semantics/TaskFrame.lean:2222`) — the two frame-law
  discharges for an infinite carrier with finite fibres;
  `FormalSystem.Metalogic.Decidability.SharingSkeleton.frame`
  (`WitnessFamily/Sharing/Skeleton.lean:1404`) as the **construction template**, read not reused;
  `FormalSystem.PlusLanguage.plusTruthAt_timeShift`, `...stab_state_only`, `...stab_congr_state`,
  `...paste`, `...PlusFormula.reflectTime`;
  `FormalSystem.Metalogic.Decidability.AUFix` (`WitnessFamily/Sharing/Fulfil.lean`, generic over
  an arbitrary vertex type with `[DecidableEq]`, so reusable verbatim);
  the three-segment readout lemmas `getD_mapC`, `readout_backC`, `readout_midC`, `readout_fwdC`
  (`WitnessFamily/Compression/Extract.lean`) and the window-decision pattern of
  `...WitnessFamily.coherent_iff_window` (`WitnessFamily/Decide.lean:336`);
  `...PlusWitnessFamily.PlusRefutes` (the interface Stage 2's soundness lands).
- **Required and used by Phase 20 only** (the embedding):
  `FormalSystem.Metalogic.Decidability.exists_witnessFamily_of_not_validZTime`
  (`WitnessFamily/Compression/Family.lean:153`);
  `FormalSystem.PlusLanguage.plusTruthAt_ofFormula` (`PlusLanguage/PlusValidity.lean:168`);
  `...PlusSharingWitnessFamily.perBack` (`PlusWitnessFamily/Decide.lean:181`) as the
  common-period computation to mirror.
- **NOT used by any phase, and named here so it is not reached for**:
  `FormalSystem.Semantics.FrameOver.ofStep` (`Semantics/IntNormalForm.lean:456`). It requires
  `[Finite W]`, which is precisely the hypothesis `Probe706.no_ofStep_sat` refutes for this
  purpose. It stays in the tree, true and used elsewhere; no module of this plan's Stage 2 calls
  it.
- **Proposed but not filed as a numbered task**: an audit of the substrate redesign found that
  the skeleton-wide field `FormalSystem.Metalogic.Decidability.SharingSkeleton.trans_refl`,
  mirrored at `...PlusSharingWitnessFamily.trans_refl`, relocates rather than repairs a
  clause-shape collapse, and should be replaced by a per-producer existential. **No task number
  exists for that follow-on and none is invented here.**
- **Why it is not a blocker.** This plan **constructs no `PlusSharingWitnessFamily` at all**:
  Stage 1 quantifies over arbitrary ones and Stage 2 introduces a new certificate type that does
  not extend `SharingSkeleton`. If the follow-on lands mid-task, Stage 1's theorems continue to
  hold — they are universally quantified over whatever the structure's fields are — and Stage 2 is
  untouched. The one obligation is mechanical: Phase 9's restatement must be re-checked against
  the field set on the day it is written, since it names `S.trans` in the hop-free hypothesis.

### Soundness is not in question

`FormalSystem.Metalogic.Decidability.PlusSharingWitnessFamily.plusTruth_iff_mem` and
`...plusRefutes_of_certifies` are **consumed, never modified**. Their statements must survive this
task **verbatim**, and both are C2-pinned, so any edit to either would be caught by the gate. No
phase below lists `PlusWitnessFamily/Agreement.lean` for modification except as a read. Stage 2's
own soundness theorem is a **new** declaration in a **new** namespace
(`PlusSlicedCertificate.plusRefutes_of_certifies`); it lands the same
`PlusWitnessFamily.PlusRefutes Γ Del` interface and does not shadow, replace or weaken the landed
one. **This revision changes nothing here**: the amendment is to the certificate type, not to the
soundness interface.

## Goals & Non-Goals

**Goals**:

The identifier set below is exactly the identifier set declared under
`## Lean Challenge Statements`, as that section's contract requires.

- Stage 1, the refutation as library declarations: `pumpTarget`,
  `not_plusValidZTime_pumpTarget`, `not_exists_plusCertifies_pumpTarget`, `hopTarget`,
  `not_plusValidZTime_hopTarget`, `not_exists_hopFree_plusCertifies_hopTarget`.
- Stage 2, the sliced certificate type and its presented frame: `PlusGraphPath`, `PlusSlice`,
  `PlusSlicedCertificate`, `PlusSlicedCertificate.BiSerial`, `FrameOver.ofSlicedStep`,
  `PlusSlicedCertificate.frame`, `PlusSlicedCertificate.model`.
- Stage 2, tail-stability and the checker: `PlusSlicedCertificate.TailStable`,
  `PlusSlicedCertificate.Certifies`, `PlusSlicedCertificate.decidableCertifies`.
- Stage 2, soundness into the existing interface:
  `PlusSlicedCertificate.plusRefutes_of_certifies`.
- Stage 2, completeness relative to tail-stable sliced models:
  `exists_plusSlicedCertificate_of_tailStable_countermodel`.
- Stage 2, the landed L witness family embeds:
  `exists_plusSlicedCertificate_of_not_plusValidZTime_ofFormula`.
- Beyond the pinned identifiers, and deliberately named without backticks so the identifier-set
  cross-check above is not polluted: correct every piece of in-tree documentation that overstates
  the landed certificate class's coverage, and add the theorem-index rows and C2 axiom-baseline
  pins the new declarations need. Phases 12 and 21 own that work and name the files.

**Non-Goals**:

- **Stage 3 — the finite model property for the sliced class, and hence full completeness for L⁺
  over ℤ — is a NON-GOAL of this task.** Its ready-to-file successor description is given below.
  It is **not filed here**, and no phase of this plan may file it. Note the standing of the
  statement after this revision: the **finite-carrier** version is now a refuted theorem
  (`Probe706.not_finite_carrier_fmp`); the **sliced** version is **open**, with no counterexample
  known. It is not refuted, and no phase may describe it as refuted.
- **The CTL-like fragment's finite model property is a NON-GOAL of this task**, and is a separate
  research-first successor of its own. Report 706 files it as such. No phase below plans it.
- The withdrawn compression theorem, its bound `plusFamilyBound`, and the four Lean modules of
  plan v1's Phases 9-12 (`Rep.lean`, `Lift.lean`, `Stab.lean`, `Family.lean`). Do not create them.
- The withdrawn `PlusGraphCertificate` of plan v2 and its
  `exists_plusGraphCertificate_of_finite_countermodel`. Do not create them; see the Amendment
  record.
- Any slice-width bound, tail-period bound, or complexity claim stated as a theorem. See
  "Bounds: none, deliberately".
- Characterizing the fragment the landed certificate class **does** cover. Recorded below as an
  open question rather than planned as a phase.
- An L⁺ enumerator or a decidability assembly. Stage 2 gives a checker, not a search.
- A `Decidable (LiftableRaw …)` instance. Round 1 established it is provable by subset
  construction; nothing here needs it.
- Any change to `plusTruth_iff_mem`, `plusRefutes_of_certifies`, or any other soundness-side
  declaration.
- Any write to the paired repository `/home/benjamin/Projects/ModelChecker`. Phases 12 and 21
  **read** it; they do not edit it.
- Landing report 706's probe declarations as library theorems. That is task 706's own
  implementation scope (its recommendation 2 names a new `FiniteCarrier.lean` beside
  `PlusWitnessFamily/Incompleteness.lean`), not this task's. This plan **cites** the probe as
  evidence and does not transcribe it.
- Restating task 704's non-vacuity and shape gates. See "Notes for other tasks" below.

### The Stage 3 successor, specified and deliberately not filed

A future task should be filed with the following description. **This plan does not file it**, and
no phase below may.

> RESEARCH-FIRST. Establish the finite model property for L⁺ over ℤ **for the time-sliced
> certificate class**, with a computable bound on the slice width and the two tail periods, and
> derive full completeness of that class from it: every ℤ-time non-validity of a `PlusFormula`
> admits a `PlusSlicedCertificate` meeting `PlusSlicedCertificate.Certifies`, with `n`, `nb`,
> `nm` and `nf` bounded by stated, computable functions of `plusClosureOf (Γ ++ Del)`. Together
> with the landed `PlusSlicedCertificate.plusRefutes_of_certifies` and
> `PlusSlicedCertificate.decidableCertifies` this yields decidability of L⁺ ℤ-time validity.
> `FormalSystem.PlusLanguage.plusValidZTime_iff_plusValidInt` is the Step 0 this statement rests
> on and has no substitute.
>
> The **finite-carrier** form of this statement is already refuted and must not be restated: see
> `Probe706.not_finite_carrier_fmp`. The sliced form is open and has no known counterexample.
>
> This is expected to be **at least as hard as the corresponding result for CTL\***, and **doubly
> exponential slice width is the honest expectation**: L⁺ ℤ-time validity is 2EXPTIME-hard by the
> CTL\* reduction argued in report 706's Q4, and a singly exponential, polynomially-checkable
> certificate would place a 2EXPTIME-hard problem in co-NEXPTIME. Any computable bound suffices
> for decidability; the bound must be stated at its true order and never tuned silently.
>
> The research round must decide between the two known routes before any plan is written: the
> deterministic-automata route the CTL\* proofs take (Emerson and Jutla 1988 via Reynolds 2001),
> which needs ω-automaton determinization and complementation that exist neither in this tree nor
> in Mathlib; and a direct construction over the product of the state graph with the Hintikka
> types, which report 706's Q2 **refutes for full L⁺** (a quotient by realized types admits a path
> that postpones an eventuality forever; a four-state example is given there) and which is
> therefore only the fragment's route. Zero sorries, no new axioms. If the property cannot be
> proved, the correct outcome is a task marked blocked with the obstruction recorded as a theorem
> where possible, never a deferred obligation behind a placeholder.

### Notes for other tasks

- **Task 704 (`certificate_non_vacuity_and_shape_gates`).** Its non-vacuity and shape gates are
  specified against the **old** certificate class and need restating against whichever class
  survives — which, after this revision, is `PlusSlicedCertificate`, not `PlusGraphCertificate`.
  That restatement is **work for 704, not for this task**, and no phase below touches it.
  Concretely: 704's standin/non-vacuity assertion should be restated against
  `PlusSlicedCertificate` once Stage 2 lands, it should gate on the Stage 1 refutation
  declarations continuing to exist, and it now has a ready-made non-vacuity witness in Phase 20's
  embedding. This note is the hand-off; it is not a dependency edit, and this plan does not modify
  task 704's description or state.
- **Task 706.** Its probe is this revision's evidence and its report is this revision's research
  input. Its own implementation scope — landing the probe's declarations as library theorems,
  restating the finite model property for the sliced class in a module docstring, and marking the
  full-L⁺ statement blocked — is **not** duplicated here. The one coupling to respect: 706's
  recommendation 2 defers the L-family embedding until "the amended Stage 2 lands", which is this
  plan's Phase 20; if 706 lands the embedding first, Phase 20 becomes a citation rather than a
  construction, and that is a deviation to record, not a conflict.
- **The paired repository** `/home/benjamin/Projects/ModelChecker` is hand-off by content only.
  Phases 12 and 21 read it and record what they find; neither ever writes to it.

### Open questions recorded, not planned

1. **Which fragment does the landed `PlusSharingWitnessFamily` class actually cover?**
   Uncharacterized, and report 706's Q6 leaves it explicitly open. The two refutations delimit it
   from above (it does not cover `pumpTarget`, and hop-free families do not cover `hopTarget`) and
   `probes/HoppingCertificateExists.lean` delimits it from below, but no characterization exists.
   What report 706 adds is a necessary condition only: a target is certifiable by the landed class
   only if it has a countermodel that is a finite, eventually periodic sharing structure **all of
   whose threads are fulfilling**. **This plan records the question and does not allocate a phase
   to it.** Phase 12 records it in the corrected module documentation so a reader meets the
   question where the class is described.
2. **Whether the sliced class is complete for full L⁺.** Unknown; this is the Stage 3 successor's
   question. No candidate counterexample is known, and the class contains every eventually
   periodic time-stamped countermodel. Until a proof exists the class is called complete only on
   the `⊡`-free fragment, which is exactly what Phase 20 proves.
3. **Whether a singly exponential slice width is possible for L⁺.** Unknown. Nothing excludes it
   unconditionally, but a singly exponential certificate checkable in time polynomial in its size
   would put a 2EXPTIME-hard problem in co-NEXPTIME. Stage 3's question, not this task's.
4. **The order of the tail periods.** Unknown and explicitly unclaimed. See "Bounds: none,
   deliberately".
5. **The CTL\* reduction of report 02 section 1.6, completed in report 706's Q4, is argued, not
   formalized.** It affects the complexity picture only. No declaration of this plan depends on it.

## Lean Challenge Statements

Two blocks, one per stage. They concatenate in document order.

Note on shape: `PlusGraphPath`, `PlusSlice` and `PlusSlicedCertificate` are `structure`s and
therefore carry no proof body to set to `sorry`. They appear in the second block because the
declarations below cannot be stated, let alone type-check standalone, without them — the field
lists are this plan's design commitment, and Phase 13 carries a Scope Hypothesis for recording any
divergence rather than absorbing it. Every declaration that does have a body carries `sorry`, as
the contract requires.

**The first block is unchanged from plan v2.** Only the second is re-authored.

```lean
import FormalSystem

open FormalSystem FormalSystem.PlusLanguage FormalSystem.Semantics

namespace FormalSystem.Metalogic.Decidability

namespace PlusSharingWitnessFamily

/-- The pumping target: a ℤ-time non-validity no sharing family certifies, at any size. -/
def pumpTarget : PlusFormula := sorry

/-- `pumpTarget` is a genuine ℤ-time non-validity. -/
theorem not_plusValidZTime_pumpTarget : ¬ PlusValidZTime pumpTarget := sorry

/-- **The landed certificate class is incomplete.** No sharing witness family certifies
`pumpTarget` at any time, for any lasso count, segment length or succession relation. -/
theorem not_exists_plusCertifies_pumpTarget :
    ¬ ∃ (S : PlusSharingWitnessFamily ([] : PlusContext) [pumpTarget]) (t : ℤ),
        S.PlusCertifies t := sorry

/-- The hop-free target: a ℤ-time non-validity with no long-range eventuality. -/
def hopTarget : PlusFormula := sorry

/-- `hopTarget` is a genuine ℤ-time non-validity. -/
theorem not_plusValidZTime_hopTarget : ¬ PlusValidZTime hopTarget := sorry

/-- **Hop-free families are incomplete independently.** No family whose succession relation
never leaves the index it is read at certifies `hopTarget`. -/
theorem not_exists_hopFree_plusCertifies_hopTarget :
    ¬ ∃ (S : PlusSharingWitnessFamily ([] : PlusContext) [hopTarget]) (t : ℤ),
        (∀ (u : ℤ) (i j : Fin S.lassos.length), S.trans u i j → i = j) ∧ S.PlusCertifies t :=
  sorry

end PlusSharingWitnessFamily

end FormalSystem.Metalogic.Decidability
```

```lean
import FormalSystem

open FormalSystem FormalSystem.PlusLanguage FormalSystem.Semantics

namespace FormalSystem.Semantics

/-- **A regular ℤ-frame on a time-sliced carrier.** The carrier is `ℤ × W`: infinite, with
finite fibres. `R t w u` is the one-step edge from slice `t` to slice `t + 1`. Limit is
discharged by `TaskFrame.limit_of_succOrder` and Saturation by
`TaskFrame.saturation_of_fib_finite`, whose docstring names exactly this case. This is the
sliced counterpart of `FrameOver.ofStep`, which cannot be used here because it requires
`[Finite W]` on the whole carrier. -/
def FrameOver.ofSlicedStep {W : Type} [Finite W] [Nonempty W]
    (R : ℤ → W → W → Prop)
    (fwd : ∀ t w, ∃ u, R t w u) (bwd : ∀ t w, ∃ v, R (t - 1) v w) :
    FrameOver intOrder := sorry

end FormalSystem.Semantics

namespace FormalSystem.Metalogic.Decidability

/-- **A labelled path through the carrier.** An eventually periodic bi-infinite sequence of
(label, state) pairs, on the same three-segment scheme a `PlusLabelledLasso` decodes. Pairing
the label with the state in one object is what keeps the certificate finite data: the state
sequence and the label sequence are cut at the same recurrence, so they decode together.
Unchanged from plan v2: the path's state component is a slice index, and the slice it lives in
is determined by the time. -/
structure PlusGraphPath (n : ℕ) (C : Finset PlusFormula) where
  /-- Labels and states for the leftward cycle, indexed left-to-right in time. -/
  back : List (Finset PlusFormula × Fin n)
  /-- Labels and states for the finite window `[0, |mid|)`. -/
  mid : List (Finset PlusFormula × Fin n)
  /-- Labels and states for the rightward cycle, indexed left-to-right in time. -/
  fwd : List (Finset PlusFormula × Fin n)
  /-- The leftward cycle is non-empty, so leftward decoding is periodic. -/
  back_ne : back ≠ []
  /-- The rightward cycle is non-empty, so rightward decoding is periodic. -/
  fwd_ne : fwd ≠ []
  /-- Every listed label is drawn from the given closure. -/
  label_sub : ∀ X ∈ back ++ mid ++ fwd, X.1 ⊆ C

/-- **One time slice.** The edge relation into the next slice, and the state labelling of this
slice. The labelling is per slice, not per state: that is the whole amendment. -/
structure PlusSlice (n : ℕ) (C : Finset PlusFormula) where
  /-- The one-step edge relation from this slice to the next. -/
  edge : Fin n → Fin n → Bool
  /-- The state labelling of this slice: the closure's atoms, `⊡`-formulas and `□`-formulas
  true at a state of this slice. -/
  lab : Fin n → Finset PlusFormula
  /-- Every slice label is drawn from the given closure. -/
  lab_sub : ∀ w, lab w ⊆ C

/-- **The time-sliced certificate.** Three segments of slices, decoded by the same three-segment
readout `PlusGraphPath` uses, presenting a frame on the infinite carrier `ℤ × Fin n` with finite
fibres. There is no `witness` field: its index set would be `ℤ × Fin n`, and it is redundant
given both directions of the liveness characterization. The finite-graph certificate is the
special case `back = fwd = [slice]`, `mid = []`. -/
structure PlusSlicedCertificate (Γ Del : PlusContext) where
  /-- The slice width. -/
  n : ℕ
  /-- Slices are non-empty. -/
  n_pos : 0 < n
  /-- The leftward period, left-to-right in time. -/
  back : List (PlusSlice n (plusClosureOf (Γ ++ Del)))
  /-- The window `[0, |mid|)`. -/
  mid : List (PlusSlice n (plusClosureOf (Γ ++ Del)))
  /-- The rightward period, left-to-right in time. -/
  fwd : List (PlusSlice n (plusClosureOf (Γ ++ Del)))
  /-- The leftward period is non-empty, so leftward decoding is periodic. -/
  back_ne : back ≠ []
  /-- The rightward period is non-empty, so rightward decoding is periodic. -/
  fwd_ne : fwd ≠ []
  /-- The box guess. -/
  bx : PlusFormula → Bool
  /-- The target path. -/
  target : PlusGraphPath n (plusClosureOf (Γ ++ Del))
  /-- The time on the target path at which the target is read. -/
  targetTime : ℤ

/-- **Bi-seriality, per slice.** Decided on the window `[-|back|, |mid| + |fwd|)` and extended
to all `t` by periodicity, exactly as `coherent_iff_window` does on the L side. -/
def PlusSlicedCertificate.BiSerial {Γ Del : PlusContext}
    (G : PlusSlicedCertificate Γ Del) : Prop := sorry

/-- **The presented frame**, on the carrier `ℤ × Fin G.n`. -/
def PlusSlicedCertificate.frame {Γ Del : PlusContext}
    (G : PlusSlicedCertificate Γ Del) (h : G.BiSerial) : FrameOver intOrder := sorry

/-- **The presented model**, valuing atoms by the slice labelling. -/
def PlusSlicedCertificate.model {Γ Del : PlusContext}
    (G : PlusSlicedCertificate Γ Del) (h : G.BiSerial) :
    TaskModel (G.frame h).toTaskFrame := sorry

/-- **Tail-stability.** Forward liveness from the back tail is not periodic in `t` in general,
so the checker computes `L₀` from the window and the forward tail, applies the one-period
transfer `Φ_back`, and demands a fixed point; mirrored for the forward tail. A certificate with
unstable tails is re-presented with the pre-period absorbed into `mid` and the period multiplied
by the cycle length, which changes neither the frame nor truth. -/
def PlusSlicedCertificate.TailStable {Γ Del : PlusContext}
    (G : PlusSlicedCertificate Γ Del) : Prop := sorry

/-- **The checker.** Four clause groups — existential from liveness, universal, box, target —
all read on the window under tail-stability, plus bi-seriality and tail-stability themselves.
Liveness is COMPUTED as a fixpoint on the finite product of a slice's state set with the
Hintikka types, never demanded as a field. No clause quantifies over a time in a way that would
need alignment: the slice time is the only time. -/
def PlusSlicedCertificate.Certifies {Γ Del : PlusContext}
    (G : PlusSlicedCertificate Γ Del) : Prop := sorry

/-- The checker is decidable. -/
def PlusSlicedCertificate.decidableCertifies {Γ Del : PlusContext}
    (G : PlusSlicedCertificate Γ Del) : Decidable G.Certifies := sorry

/-- **Soundness.** A certificate meeting the checker produces an explicit ℤ-time joint
countermodel, landing the existing refutation interface unchanged. -/
theorem PlusSlicedCertificate.plusRefutes_of_certifies {Γ Del : PlusContext}
    (G : PlusSlicedCertificate Γ Del) (h : G.Certifies) :
    PlusWitnessFamily.PlusRefutes Γ Del := sorry

/-- **Completeness relative to tail-stable sliced models.** A countermodel carried by a
bi-serial, tail-stable sliced structure yields a certificate on the SAME carrier that the
checker accepts; only the guessed fields (`bx`, `target`, `targetTime`) are re-chosen. This is
NOT the finite model property: it says nothing about whether a ℤ-time non-validity has such a
countermodel at all. -/
theorem exists_plusSlicedCertificate_of_tailStable_countermodel
    (Γ Del : PlusContext) (G₀ : PlusSlicedCertificate Γ Del)
    (hser : G₀.BiSerial) (hstab : G₀.TailStable)
    (τ : WorldHistory (G₀.frame hser).toTaskFrame) (t : ℤ)
    (hΓ : ∀ γ ∈ Γ, PlusTruthAt (G₀.model hser) τ t γ)
    (hDel : ∀ δ ∈ Del, ¬ PlusTruthAt (G₀.model hser) τ t δ) :
    ∃ G : PlusSlicedCertificate Γ Del,
      G.n = G₀.n ∧ G.back = G₀.back ∧ G.mid = G₀.mid ∧ G.fwd = G₀.fwd ∧ G.Certifies := sorry

/-- **The landed L witness family embeds, so the sliced class is complete on the `⊡`-free
fragment.** Every ℤ-time non-validity of L, transported to L⁺ by `ofFormula`, has a sliced
certificate: the family's `k` lassos become `k` slice states with edges `i → i` only. This is
the only completeness theorem the research supports, and it is what restores parity with the
landed L class that the withdrawn finite-graph shape gave up. -/
theorem exists_plusSlicedCertificate_of_not_plusValidZTime_ofFormula
    (φ : Formula) (h : ¬ PlusValidZTime (ofFormula φ)) :
    ∃ G : PlusSlicedCertificate ([] : PlusContext) [ofFormula φ], G.Certifies := sorry

end FormalSystem.Metalogic.Decidability
```

## Reuse of landed work, stated per file

This section exists so the implementer neither deletes landed true work nor rebuilds what
already exists. **Nothing listed below is to be deleted.** "Unused" means no declaration of
Stage 1 or Stage 2 calls it; it stays compiled, documented and in the tree.

| File | Status under the amended target | What specifically |
|------|-----------------------------------|-------------------|
| `PlusWitnessFamily/TransId.lean` | **True, left in place, unused.** Not a completeness route | `plusLocalCoherentShare_of_transId`, `transId_forces_const_thread`, `thread_eq_const_of_transId`, `plusThreadFulfilling_of_transId`, `transIdOf_hid` are all true and all stay. The hop-free collapse they prove is exactly what Phase 10's refutation shows is **incomplete**, so its module header needs the correction Phase 12 makes — the declarations themselves need nothing |
| `Compression/Types.lean` | **Reused unchanged** | `plusTypeAtM`, `mem_plusTypeAtM`, `plusTypeAtM_subset`, `PlusLocalCoherentSeqLab`, `PlusFulfillingSeqLab`, `plusTypeAtM_localCoherentSeqLab`, `plusTypeAtM_fulfillingSeqLab`, and the three added truth lemmas `plusBox_const`, `plusTruth_untl_succ`, `plusTruth_snce_pred`. This is the label machinery for the target path and every liveness path in Stage 2 |
| `Compression/Cycle.lean` | **Reused unchanged** | `PlusTypeState`, `plusTypeOfT`, `card_plusTypeState`, `natCard_plusTypeState`, `PlusSeqStepT`, `iter_plusSeqStepT`, `plusJoinPathT` and its three lemmas, `exists_recurring_plusTypeState`, `plusUntlEventT`/`plusSnceEventT` and their inversions, `plusCycleBoundC`, `exists_base_plusCycleT`, `exists_good_cycle_of_plusTypeSeq`. Phase 19 uses the pigeonhole and the good-cycle theorem to make the target path eventually periodic |
| `Compression/Fulfil.lean` | **Reused unchanged** | `plusUntl_propagates_to_endC`, `plusSnce_propagates_to_startC`, `plusLab_add_mul_nfC`, `plusLab_sub_mul_nbC`, `plusFulfillingSeqLab_of_good_cycles` |
| `Compression/Extract.lean` — reused half | **Reused unchanged, and reused MORE than in plan v2**: the generic three-segment readout now decodes the slice sequence as well as the labelled paths | `plusTypeOfT_unrollOf`, `plusMidBoundC`, `plusMidBoundC_eq`, `plusCompressionBound`, `plusCycleBoundC_le_plusCompressionBound`, `plusMidBoundC_le_plusCompressionBound`, `plusCompressionBound_pos`, `plusLocalCoherentSeqLab_of_edges`, `exists_plusLabelledLasso_of_history_realized`, `exists_plusLabelledLasso_of_history`, `plusLocalCoherentSeqLab_congr_bx`, `lab_neg`, `lab_mid`, `lab_fwd` |
| `WitnessFamily/Compression/Extract.lean` (the `Formula`-side generic readout) | **Reused by import, generic** | `getD_mapC`, `readout_backC`, `readout_midC`, `readout_fwdC`, `periodic_rel_of_windowC`, stated over `{α} [Inhabited α]` and mentioning no formula. Phase 13 instantiates them **twice**: at `Finset PlusFormula × Fin n` for `PlusGraphPath`, and at `PlusSlice n C` for the slice sequence |
| `Compression/Extract.lean` — alignment half | **True, left in place, UNUSED.** Nothing is aligned, because on a sliced graph the slice time is the only time (report 02 section 1.3, as corrected by report 706) | `plusAlignOffset`, `plusAlignOffset_pos`, `plusAlignOffset_eq_natCard`, `two_mul_plusAlignOffset_le`, `preBlock`, `shiftBack`, `getD_preBlock`, `getD_shiftBack`, `mem_preBlock_subset`, `mem_shiftBack_subset`, `shiftBy`, `shiftBy_back_length`, `shiftBy_mid_length`, `lab_shiftBy`, `lab_shiftBy_eq`, `plusLocalCoherentSeqLab_comp_sub`, `plusFulfillingSeqLab_comp_sub`, `exists_plusLabelledLasso_of_history_aligned`. **Do not delete any of them** |
| `Compression/Saturate.lean` | **Reused, in a new role**: the (C5) demand layer becomes the **slice** labelling's well-definedness. Note the shift from plan v2: the congruences are now applied at a state *of a slice*, i.e. at a carrier element `(t, w)`, not at a time-free state | `plusSameState` and its three equivalence lemmas, `plusTruthAt_stab_of_sameState`, `plusTypeAtM_mem_of_stab_of_state_eq`, `plusTypeAtM_stab_congr_state`, `plusTypeAtM_atom_congr_state`, `exists_history_state_eq_of_not_stab`, `plusTypeAtM_stab_demand`, `plusTypeAtM_stab_iff_forall_sameState` |
| `WitnessFamily/Sharing/Skeleton.lean` | **READ-ONLY, used as the construction TEMPLATE** | `SharingSkeleton.frame` (line 1404) is the worked example of a literal `FrameOver intOrder` on an infinite, time-stamped carrier with finite fibres: two-sided relation, reflection by symmetry, Limit by `limit_of_succOrder`, Saturation by `saturation_of_fib_finite`. Phase 14 follows its shape; it does not call it, because the carrier differs (`ℤ × Fin n` against share-classes) |
| `Semantics/TaskFrame.lean` | **READ-ONLY, consumed** | `TaskFrame.limit_of_succOrder` (line 1591) and `TaskFrame.saturation_of_fib_finite` (line 2222). The second is the load-bearing one: its docstring names the infinite-carrier/finite-fibre case this plan needs |
| `Semantics/IntNormalForm.lean` | **READ-ONLY, partly consumed and partly deliberately NOT used** | Consumed: `worldHistoryOfStepPath` (line 323), `mem_HF_iff_adjacent` (line 348). **Not used: `ofStep` (line 456)** — it requires `[Finite W]`, which is exactly what `Probe706.no_ofStep_sat` refutes for this purpose. It stays in the tree and is used elsewhere; no Stage 2 module calls it |
| `WitnessFamily/Decide.lean` | **READ-ONLY, used as a PATTERN** | `coherent_iff_window` (line 336) is the worked example of deciding a bi-infinite periodic condition on a finite window. Phase 13's bi-seriality decision follows it |
| `WitnessFamily/Sharing/Fulfil.lean` | **Reused by import**, generic | `AUFix.step`, `AUFix.iter`, `AUFix.lfp` and their monotonicity/fixpoint/induction lemmas are stated at `{α : Type*} [DecidableEq α]` and mention no formula, so Phase 15 imports them. **`AUFix` is the universal (`A[g U e]`) fixpoint**; Phase 15 additionally needs an existential fair-path fixpoint, which does not exist in the tree and is new work |
| `WitnessFamily/Compression/Family.lean` | **READ-ONLY, consumed by Phase 20 only** | `exists_witnessFamily_of_not_validZTime` (line 153) is the landed L-side completeness theorem the embedding starts from. Phase 20 consumes it; no other phase touches it |
| `PlusLanguage/PlusValidity.lean`, `PlusLanguage/PlusPasting.lean` | **READ-ONLY, consumed** | `plusTruthAt_ofFormula` (PlusValidity line 168) transports L countermodels to L⁺ for Phase 20; `paste` (PlusPasting line 111) is the S4 half of the Q5 factorization Phase 15 proves |
| `PlusWitnessFamily/{Basic,Closure,Predicates,Decide,Fulfil,Examples,Incompleteness}.lean` | **Unchanged, consumed.** Phase 12 edits documentation in some of them; no declaration changes | Stage 1 quantifies over `PlusSharingWitnessFamily` and `PlusCertifies`; Stage 2 reuses `PlusLabelledLasso` and its decoding, and Phase 20 mirrors `Decide.lean`'s `perBack` (line 181) common-period computation |
| `PlusWitnessFamily/Agreement.lean` | **READ-ONLY throughout.** `plusTruth_iff_mem` and `plusRefutes_of_certifies` keep their statements verbatim; `PlusWitnessFamily.PlusRefutes` is the interface Stage 2 lands | Confirmed by an empty `git diff` over the file at Phases 18 and 21 |
| `WitnessFamily/**` (the rest of the `Formula` side) | **Read-only throughout.** No phase edits it | |
| `Compression/{Rep,Lift,Stab,Family}.lean` | **Never created; retired with the withdrawn route** | Do not create them |
| `PlusGraphCertificate/{Basic,Live,Check,Sound,Finite}.lean` | **Never created; retired with the withdrawn certificate class at plan v4** | Do not create them. Their amended counterparts live under `PlusSlicedCertificate/` |

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| **R2 (report 706).** The tail-stability design has a gap not visible without building it: forward liveness from the back tail is not periodic in `t`, and the `Φ`-fixpoint demand is the proposed repair rather than a proved one. This is the amendment's **only** visible failure mode | H | M | Phase 16 is dedicated to it, is scheduled **before** the checker rather than discovered inside it, and carries report 706's concrete four-state counterexample as a **named test fixture** that must be built and evaluated before the demand is declared correct. If the fixture shows the demand is too weak, the correct response is to strengthen the demand (a deeper `Φ` iteration, or a type-recurrence cut on slices) and record the change loudly — never to weaken the theorem or reach for a `sorry` |
| The sliced frame's Saturation and Limit discharges are new work on an infinite carrier | H | M | `SharingSkeleton.frame` is the worked template and `saturation_of_fib_finite`'s docstring names exactly this case. Phase 14 is a whole phase for the frame alone, and its verification requires the two instance discharges to be named lemmas rather than inline `by` blocks, so Phase 19 can cite them |
| Phase 15's existential fair-path fixpoint has no precedent in the tree. `AUFix` is the universal operator and gives the `A[g U e]` half only; the liveness computation needs a greatest-fixpoint / cycle-reachability argument over the product graph, in both time directions | H | M | Phase 15 is dedicated to it, is scheduled before the checker, and carries an explicit decimal-sub-phase contingency. The Q5 factorization proved in that same phase is what lets the forward and backward halves be computed separately and then combined, so the two fixpoints never have to be solved jointly |
| Phase 19 (relative completeness) needs the **completeness direction** of the liveness fixpoint: that every live position is realized by an actual labelled path | H | M | Phase 15 proves both directions of the characterization as named lemmas, so Phase 19 cites a lemma rather than re-deriving it. If Phase 19 overruns one agent run it decomposes into 19.1 and 19.2, never into a `sorry` |
| Phase 20's embedding turns out to need more than "edges `i → i` only": the landed L family's `trans` may relate distinct indices, so the `k`-slice-state picture may need the family's succession relation as genuine edges | M | M | Phase 20 carries a Scope Hypothesis naming exactly this: read `WitnessFamily`'s `trans` field before building the edge relation, and if `i → i` is insufficient, use the family's own `trans` as the slice edge relation and **record the correction**. Either way the theorem statement is unchanged; only the construction is |
| A field of `PlusSlicedCertificate` turns out wrong once the checker is written, invalidating the pinned Lean Challenge Statement | M | M | Phase 13 carries a Scope Hypothesis: the field list is confirmed by writing the **signature** of `Certifies` and of `BiSerial` against it before the structures are declared final, and any divergence is recorded at the phase heading as a deviation rather than absorbed. The six theorem/def statements that are flagships are what must not drift; the field list is a design commitment that may be corrected once, loudly. **Plan v2's field list was corrected by a refutation, not by a build failure** — that is the precedent this mitigation exists to handle better |
| A bound creeps back in — a width, a period, or a complexity claim stated as though proved | H | M | "Bounds: none, deliberately" above is binding, Phase 21's verification greps both new subtrees for a stated bound, and plan v1's false commitment is named in this plan three times as the reason |
| Phase 11's restatement of `no_certificate` is the largest single transcription (the probe is about 420 lines) and may overrun one agent run | M | M | Phase 9 lifts out the shared target syntax and closure-membership scaffolding first, so Phase 11 carries only the pumping argument. Declared contingency: split at the pigeonhole step into 11.1 (the forced-successor consequences of (C0), (C3), (C4), (C5)) and 11.2 (the pumping contradiction with (C2')) |
| The probes were compiled against built `.olean` files that could have gone stale, and the library restatement will be compiled against a different import surface | M | L | Each of Phases 9-11 ends with a real `lake build` of the new module, not a probe recompile. The probes stay in `probes/` as the provenance record and are **not** deleted when the library declarations land. The same applies to task 706's probe, which this plan cites but does not transcribe |
| C17's dead-declaration census reports the now-unused alignment half of `Compression/Extract.lean` | L | H | **Not a gate failure.** C17 is reporting-only: `scripts/check-module-invariants.sh` states "No ENFORCE_C17 flag -- reporting-only per the delegation", and a textual census with a known false-positive rate never affects the exit code. Phase 12 records the expected C17 report in the module docstring so a later reader does not mistake it for rot |
| `.githooks/pre-commit` fires on every commit staging a `.lean` file because this task's new modules move the committed counts in `typst/generated/status.typ` | M | H | Same mechanism plan v1 recorded, and its condition is now met: `specs/state.json` reports task 650 as `completed`. Phase 21 runs `bash scripts/typst-sync-check.sh --fix` and commits **only** `typst/generated/status.typ`, by explicit path. Before any use of the hook's `--no-verify` bypass, confirm the count drift is the **only** failing gate; anything else the hook reports is to be fixed, never bypassed |
| A concurrent sibling touches this working tree | M | M | Re-read every file immediately before editing; stage only this task's own files by explicit path, never a directory or glob `git add`; never run `git-snapshot.sh` in its reverting default mode; treat a build failure outside this task's files as possibly a sibling's in-flight edit; stop and report any foreign commit or foreign uncommitted modification after checking `git log`. **Task 706 is live in this tree**; its scope is `specs/706_*/` plus a future `PlusWitnessFamily/FiniteCarrier.lean`, neither of which this plan writes |
| A phase cannot close a goal and reaches for a `sorry` | H | L | Acceptance is zero sorries and no vacuous placeholder definitions. The correct response is plan decomposition into a new decimal sub-phase, never deferral and never a `def X := True` |
| Documentation corrections in Phase 12 overstate in the other direction, reading the refutation as a defect in the substrate redesign | M | M | It is not one. The redesign did what it was for: `Examples.lean`'s two certificates are real and `Incompleteness.lean`'s two refuted congruences are real. What Phase 12 corrects is a claim about **coverage**, and each edit must say what remains true as well as what does not |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2 | -- |
| 2 | 3, 6 | 2 |
| 3 | 4 | 3 |
| 4 | 5 | 4 |
| 5 | 7 | 4, 5, 6 |
| 6 | 8 | 7 |
| 7 | 9 | 8 |
| 8 | 10, 11 | 9 |
| 9 | 12 | 10, 11 |
| 10 | 13 | 12 |
| 11 | 14 | 13 |
| 12 | 15 | 14 |
| 13 | 16 | 15 |
| 14 | 17 | 16 |
| 15 | 18 | 17 |
| 16 | 19 | 18 |
| 17 | 20 | 19 |
| 18 | 21 | 20 |

Phases within the same wave can execute in parallel. Phases 1 through 8 are landed and are
reproduced below as the record of what exists; the live work starts at Phase 9.

## Landed work, preserved (Phases 1-8)

The eight phases below are the record of what exists in the tree. Phases 1 through 7 are
reproduced from plan v1 unchanged, including their deviation and closure records, because the
work they describe is landed, true and — with the single exception noted in the reuse table —
reused by Stage 2. **Nothing in these eight phases is to be redone, and nothing is to be
deleted.** Phase 8 is the one whose status changed at this revision; its own heading says why.

**Forward references inside the preserved text point at plan v1's numbering, not this plan's.**
Where Phases 1, 6 and 7 below say "Phase 8", "Phase 9" or "Phase 12" they mean plan v1's
representative-structure, splice-closure and assembly phases — all withdrawn, none of which
exists here. Phases 9 through 18 of *this* plan are Stage 1 and Stage 2 and have nothing to do
with them. The preserved sentences are history and are left unedited so the record is not
retouched; they are not instructions.

One superseding note applies to Phases 7 and 8 and is stated once, here, rather than being
interleaved into their preserved text: both phases argue about **alignment**, and alignment is
an artefact of representing a shift-invariant semantics as rows pinned to absolute time. On the
graph Stage 2 builds there is nothing to align to, so neither phase's remaining difficulty
recurs. Their landed declarations are unaffected by that observation and remain correct.

---

### Phase 1: The `transId` collapse for (C1') and (C2') [COMPLETED]

**Goal**: Prove that on a hop-free family — one whose `trans` relates an index only to itself —
the two branching conditions (C1') and (C2') follow from the per-lasso conditions
`PlusLocalCoherentLab` and `PlusFulfillingLab`. This is the design claim the whole route rests
on, so it is established first and as a reusable library lemma rather than as a throwaway probe.

**Tasks**:
- [x] Create `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/TransId.lean` with the module
      docstring, `import FormalSystem.Metalogic.Decidability.PlusWitnessFamily.Predicates`, and
      the `FormalSystem.Metalogic.Decidability` namespace.
- [x] Prove `plusLocalCoherentShare_of_transId`. Under `hid`, the `untl` clause's `j` and the
      `snce` clause's `k` are forced equal to `i`, so each branching clause is exactly its
      one-position instance. Mirror the shape of the landed `plusUntl_self_of_share` and
      `plusSnce_self_of_share`, which are the same instantiation read in the opposite direction.
- [x] Prove `transId_forces_const_thread`: under `hid`, every `Thread`'s index function is
      constant. `Thread.step θ u : S.trans u (θ.idx u) (θ.idx (u + 1))` plus `hid` gives
      `θ.idx u = θ.idx (u + 1)`; extend to all of ℤ by induction in both directions.
- [x] Prove `plusThreadFulfilling_of_transId` from the previous item plus `Thread.ext` and
      `Thread.const_idx`. *(deviation: altered — routed through a named intermediate
      `thread_eq_const_of_transId`, which is exactly the `Thread.ext` + `Thread.const_idx` step
      the task names, extracted as a reusable lemma rather than inlined)*
- [x] Prove `transIdOf_hid`: a family whose three `trans` segments are `transIdOf` applied to the
      three `rep` segments satisfies `hid`. This is the form Phase 9 will hand in.
- [x] Add the import line to `FormalSystem/Metalogic/Decidability/PlusWitnessFamily.lean`.
- [x] Confirm the new module transitively imports `FormalSystem.Init` (invariant C24).

**Timing**: 2 hours

**Depends on**: none

**Verification Tier**: interface

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/TransId.lean` - new file, the five
  declarations above
- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily.lean` - one added import line

**Verification**:
- `lake build FormalSystem.Metalogic.Decidability.PlusWitnessFamily` exits 0.
- `#print axioms` on each new declaration shows no axiom beyond `propext`,
  `Classical.choice`, `Quot.sound`.
- No `sorry` in the new file.

---

### Phase 2: L⁺ compression types and the sequence-level predicates [COMPLETED]

**Goal**: Transcribe the `Formula`-side `Compression/Types.lean` layer to L⁺: the type-at-a-model
map and the two sequence-level predicates that the cycle extraction and the readout both consume.

**Tasks**:
- [x] Create `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Compression/Types.lean`.
- [x] Define `plusTypeAtM`, the L⁺ twin of `typeAtM` (`Compression/Types.lean:81`): the closure
      members true at a history and time. Note the model side needs no new types —
      `PlusValidInt` quantifies over the same `FrameOver intOrder`, `TaskModel` and
      `WorldHistory` the `Formula` side uses; only the truth predicate differs (`PlusTruthAt`
      rather than `TruthAt`).
- [x] Prove `mem_plusTypeAtM` and `plusTypeAtM_subset`, the membership characterization and the
      closure containment.
- [x] Define `PlusLocalCoherentSeqLab` and `PlusFulfillingSeqLab`, the sequence-level twins of
      `LocalCoherentSeqLab` and `FulfillingSeqLab`. These are stated on a bare `ℤ → Finset
      PlusFormula`, with no family in sight, which is what lets the cycle extraction manipulate
      them.
- [x] Prove `plusTypeAtM_localCoherentSeqLab` and `plusTypeAtM_fulfillingSeqLab`: the truth oracle
      realizes both predicates. Five clauses for the first, two directions for the second.
- [x] Add the import line to `FormalSystem/Metalogic/Decidability/PlusWitnessFamily.lean`.

**Timing**: 2 hours

**Depends on**: none

**Verification Tier**: interface

**Scope Hypothesis** *(confirmed at implementation time)*: the declaration list was diffed
against `WitnessFamily/Compression/Types.lean`. The L⁺ `stab` constructor forces **no** extra
clause in either predicate — `⊚` is not an eventuality and has no one-step unfolding, and (C5) is
a family condition that cannot be stated at a bare label sequence — so both predicates keep
exactly five and two clauses respectively. Three supporting truth lemmas *were* added, and are
recorded rather than absorbed: `plusBox_const`, `plusTruth_untl_succ` and `plusTruth_snce_pred`.
The `Formula` side gets these free from `Semantics/TruthTransport.lean` and
`BiLasso/Unfold.lean`; neither has an L⁺ counterpart anywhere in the tree, so the L⁺ module
proves all three. Original hypothesis, for the record: the `Formula`-side `Compression/Types.lean` is 224 lines and the L⁺
transcription is estimated at a comparable size with no structural additions. Confirm at
implementation time by diffing the declaration list against
`FormalSystem/Metalogic/Decidability/WitnessFamily/Compression/Types.lean`; if the L⁺ `stab`
constructor forces an extra clause in either predicate, record the addition rather than absorbing
it silently.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Compression/Types.lean` - new file
- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily.lean` - one added import line

**Verification**:
- `lake build` exits 0; no `sorry`; axioms unchanged.
- Each of the two realization lemmas is confirmed to mention `PlusTruthAt`, not `TruthAt`.

---

### Phase 3: Type-state carrier, pigeonhole, and path joining [COMPLETED]

**Goal**: Transcribe the first half of the cycle machinery: the finite type-state carrier, its
cardinality bound, the step relation on it, and the path-joining lemmas that let two cycles be
concatenated.

**Tasks**:
- [x] Create `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Compression/Cycle.lean`.
- [x] Define `PlusTypeState` over a `C : Finset PlusFormula` and `plusTypeOfT`; prove
      `plusTypeOfT_subset`.
- [x] Prove `card_plusTypeState` and `natCard_plusTypeState`, the cardinality bounds that make the
      pigeonhole finite.
- [x] Define `PlusSeqStepT` and prove `iter_plusSeqStepT`.
- [x] Transcribe `exists_iterT_lt_card_aux` and `exists_iterT_lt_card`, the generic finite-relation
      pigeonhole. *(deviation: altered — REUSED by import, not transcribed; see the Scope
      Hypothesis result below)* These are stated over an abstract `[Finite W] [Nonempty W]`, so they may be
      reusable verbatim from the `Formula` side — check before re-proving.
- [x] Define `plusJoinPathT` and prove `plusJoinPathT_left`, `plusJoinPathT_right`,
      `plusJoinPathT_steps`.
- [x] Prove `exists_recurring_plusTypeState`.

**Timing**: 2 hours

**Depends on**: 2

**Verification Tier**: local

**Scope Hypothesis** *(confirmed at implementation time: REUSE, not transcribe)*: both
signatures were read. `exists_iterT_lt_card_aux {W : Type} [Finite W] [Nonempty W]
(R : W → W → Prop)` and `exists_iterT_lt_card` mention neither `Formula` nor `TypeState C`
anywhere, load-bearing or otherwise. Both are therefore reused by importing
`FormalSystem.Metalogic.Decidability.WitnessFamily.Compression.Cycle`, and that import is
recorded in the new module's header as a decision. Every other declaration of the `Formula`-side
module IS monomorphic in `Formula` through `TypeState C = {S : Finset Formula // S ∈ C.powerset}`
and was transcribed. Original hypothesis, for the record: the generic pigeonhole pair `exists_iterT_lt_card_aux` /
`exists_iterT_lt_card` is asserted to be formula-agnostic and therefore reusable from the
`Formula`-side module without re-proof. Confirm at implementation time by reading their
signatures in `WitnessFamily/Compression/Cycle.lean`; if either mentions `Formula` or
`TypeState C` in a load-bearing position, transcribe instead of importing and say so.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Compression/Cycle.lean` - new file,
  first half

**Verification**:
- `lake build` of the new module exits 0; no `sorry`.
- `card_plusTypeState` is checked against a small concrete closure to confirm the bound is not
  off by a factor.

---

### Phase 4: Eventuality events, the cycle bound, and good cycles [COMPLETED]

**Goal**: Complete the cycle machinery: the eventuality-event decoders, the cycle-length bound,
and the extraction of a good cycle from an arbitrary type sequence.

**Tasks**:
- [x] Define `plusUntlEventT` and `plusSnceEventT` and prove their `eq_some` inversion lemmas.
- [x] Define `plusCycleBoundC` and prove `plusCycleBoundC_eq`.
- [x] Prove `exists_base_plusCycleT`.
- [x] Prove `exists_good_cycle_of_plusTypeSeq`, the phase's deliverable: from any type sequence,
      a cycle bounded by `plusCycleBoundC` on which every eventuality present is discharged.
- [x] Confirm the L⁺ closure's `stab` members need no event decoder. `⊡` is not an eventuality —
      it has no unfolding clause in (C1') by design — so the two decoders stay at `untl` and
      `snce` exactly as on the `Formula` side.

**Timing**: 2 hours

**Depends on**: 3

**Verification Tier**: local

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Compression/Cycle.lean` - second half,
  appended

**Verification**:
- `lake build` exits 0; no `sorry`.
- `exists_good_cycle_of_plusTypeSeq`'s statement is diffed against the `Formula`-side
  `exists_good_cycle_of_typeSeq` and any divergence is explained in the docstring.

---

### Phase 5: Fulfilment from good cycles [COMPLETED]

**Goal**: Transcribe the fulfilment layer: eventuality propagation to a cycle endpoint, label
periodicity under the two cycle lengths, and the assembly of `PlusFulfillingSeqLab` from a pair of
good cycles.

**Tasks**:
- [x] Create `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Compression/Fulfil.lean`.
- [x] Prove `plusUntl_propagates_to_endC` and `plusSnce_propagates_to_startC`.
- [x] Prove `plusLab_add_mul_nfC` and `plusLab_sub_mul_nbC`, the forward and backward label
      periodicities.
- [x] Prove `plusFulfillingSeqLab_of_good_cycles`, the phase's deliverable.
- [x] Add the import line to `FormalSystem/Metalogic/Decidability/PlusWitnessFamily.lean`.

**Timing**: 2 hours

**Depends on**: 4

**Verification Tier**: interface

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Compression/Fulfil.lean` - new file
- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily.lean` - one added import line

**Verification**:
- `lake build` exits 0; no `sorry`; axioms unchanged.

---

### Phase 6: Generic readout and the segment bound [COMPLETED]

**Goal**: Transcribe the generic readout layer — the lemmas that turn three finite segments into a
bi-infinite function and back — and define `plusCompressionBound`.

**Tasks**:
- [x] Create `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Compression/Extract.lean`.
- [x] *(resolved: ALL EIGHT reused by import, zero transcribed)* Transcribe or import `getD_mapC`, `getD_range_mapC`, `reduce_emodC`, `emod_succ_congrC`,
      `periodic_rel_of_windowC`, `readout_backC`, `readout_midC`, `readout_fwdC`. These are
      generic over `α` with `[Inhabited α]` on the `Formula` side, so they are candidates for
      reuse rather than transcription — check each signature first.
- [x] Prove `plusTypeOfT_unrollOf`, the decoding lemma specialized to L⁺ type states.
- [x] Define `plusMidBoundC` and prove `plusMidBoundC_eq`.
- [x] Define `plusCompressionBound` and prove `plusCycleBoundC_le_plusCompressionBound` and
      `plusMidBoundC_le_plusCompressionBound`.

**Timing**: 2 hours

**Depends on**: 2

**Verification Tier**: local

**Scope Hypothesis** *(confirmed at implementation time; count: 8 reused, 0 transcribed)*: each
signature was read. `getD_mapC`, `getD_range_mapC`, `periodic_rel_of_windowC`, `readout_backC`,
`readout_midC` and `readout_fwdC` are declared over `{α : Type*} [Inhabited α]`; `reduce_emodC`
and `emod_succ_congrC` are pure `Int.emod` facts over bare integers. None mentions `Formula`,
`Context`, `closureOf` or `TypeState`, so all eight are reused by importing
`WitnessFamily/Compression/Extract.lean`. The one readout-layer declaration that is NOT generic,
`typeOfT_unrollOf`, is stated at `TypeState C` and was transcribed as `plusTypeOfT_unrollOf`.
One declaration was added beyond the plan's list and is recorded here rather than absorbed:
`plusCompressionBound_pos`, which Phase 7's Invariant A needs so a padded segment is never the
empty list.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Compression/Extract.lean` - new file,
  first half

**Verification**:
- `lake build` of the new module exits 0; no `sorry`.
- `plusCompressionBound` is evaluated on a small concrete `φ` to confirm it is finite and
  non-zero.

---

### Phase 7: Single-history lasso extraction, with the two construction invariants [COMPLETED WITH EXCLUSIONS]

**PLAN DEVIATION — Invariant A dropped (orchestrator decision, cycle 6, 2026-09-29)**:
resolution 1 of the "What is needed" list below was taken. Invariant A ("pad every segment to a
common length `plusCompressionBound`") is **dropped**: it is unprovable as written, and nothing
downstream needs it for correctness. The segment bounds Phase 12 states come free from the
unpadded extraction. Invariant B survives via the shift mechanism recorded in the BLOCKER's
"Invariant B is not blocked by the same argument" bullet. The compression theorem's stated
segment bound and the Lean Challenge Statement are **unchanged**. Recorded in
`specs/703_lplus_compression_and_completeness/.decisions.json`. The decision was taken by the
orchestrator on the previous agent's recommendation because the user was unavailable, and the
user may overturn it.

*Refinement found at implementation time*: the BLOCKER's Invariant B sketch normalizes to the
**maximum landing offset over the extracted lassos**, which makes the common offset depend on the
list and pushes `|mid'|` to below `3 · 2^κ`. The implementation instead normalizes to the
**constant** `plusAlignOffset Γ Del = 2 ^ κ`, which is independent of the history, the time and
the list, and which keeps `|mid'| < 2 · 2^κ = plusMidBoundC ≤ plusCompressionBound` — the original
mid bound rather than a widened one. This is strictly stronger than the sketched mechanism and
needs no `κ ≥ 1` side condition.

**BLOCKER** (Phase 7) *(retained for the record; resolved by the deviation above)*:

- **What failed**: Invariant A, "pad `back` and `fwd` by repetition so every extracted lasso has
  `back.length = fwd.length = plusCompressionBound Γ Del`". It is not provable as written, and
  the risk-table mitigation it serves ("so `NB = NF = plusCompressionBound`") is false about the
  landed substrate independently of it.

- **What was tried**: the padding lemma was attempted first, before the main extraction, exactly
  as this phase's Scope Hypothesis directs. Three routes were considered and each fails on the
  arithmetic rather than on a tactic.

  1. *Padding by repetition.* Repeating a cycle list `m` times preserves the decoded label
     function, because `Periodic.cyc` reads `i % length` and `i % (m·L) % L = i % L`. So
     repetition reaches exactly the multiples of `L` and nothing else. Hitting
     `plusCompressionBound` therefore requires `L ∣ plusCompressionBound` for every extracted
     cycle length `L`, which the good-cycle theorem does not provide and which is false.
  2. *Changing a cycle's length some other way.* The decoded function's period on the `back`
     segment is exactly `back.length`, through `Periodic.cyc`. A non-multiple length changes the
     decoded function, so no other length-changing operation preserves `lab`.
  3. *Choosing a common length at construction time.* Achievable cycle lengths through a
     recurring type are the differences of its recurrence times, closed under addition but not
     arbitrary. `exists_base_plusCycleT` returns `L = b + 1` with `b < Nat.card (PlusTypeState C)`,
     so every `L` in `1 … 2^|C|` is permitted by its own statement.

- **Concrete refutation** (κ = |plusClosureOf (Γ ++ Del)| = 3): `Nat.card (PlusTypeState C) = 8`,
  so `exists_base_plusCycleT` permits every cycle length in `1 … 8`, and
  `plusCompressionBound = (2·3 + 1) · 2^3 = 56`. Three lassos with back lengths 5, 7 and 8 admit
  no common padded length below `lcm(5, 7, 8) = 280`, which exceeds 56. So no common segment
  length satisfying the theorem's own `Λ.back.length ≤ plusCompressionBound` bound exists.
  (At κ = 2 the invariant happens to be satisfiable — `lcm(1…4) = 12 ≤ 20` — which is why the
  failure is not visible on a small example.)

- **Why it is stuck — the second, independent defect**: the invariant's stated purpose does not
  describe this tree. `PlusWitnessFamily/Decide.lean`'s `perBack` is
  `repBack.length * (lassos.map (·.back.length)).prod` — a **product**, never a least common
  multiple. So "leaving segments at differing lengths makes `NB`/`NF` a least common multiple
  over up to `n` lengths" is not what the landed substrate does, and a common length `L` would
  give `NB = |repBack| · L^n`, not `plusCompressionBound`. The mitigation's stated outcome
  `NB = NF = plusCompressionBound` holds only when `n = 1` and `|repBack| = 1`.

- **What is needed** (a plan decision, not a proof): one of

  1. **Drop Invariant A.** Nothing downstream needs it for *correctness*. The segment bounds
     Phase 12 states come free from the unpadded extraction, which already returns
     `≤ plusCompressionBound`. Phase 9's `repBack_ne` / `repFwd_ne` are about the representative
     segments, which this task constructs directly and can make non-empty without A. `NB`/`NF`
     are `abbrev`s whose well-formedness (`NB_pos`, `nbr_dvd_NB`, …) is already proved generically
     for an arbitrary family. This is the recommended resolution.
  2. **Keep a common length and widen the bound.** Set the common length to a common multiple of
     the extracted cycle lengths and enlarge `plusCompressionBound` accordingly, propagating the
     new form into Phases 8 and 12 and into the Lean Challenge Statement's segment bounds. This
     makes the stated bound substantially worse for no correctness gain.
  3. **Strengthen the good-cycle theorem** so it returns a cycle whose length divides a declared
     modulus. That is a real change to Phase 4's landed `exists_good_cycle_of_plusTypeSeq` and
     needs its own design round.

- **Invariant B is not blocked by the same argument, but its stated mechanism is.** B ("normalize
  the landing position to a single canonical offset, by rotating the padded segments") is
  achievable by a *different* mechanism: shift a lasso rightward by `k` by prepending the `k`
  labels `lab (-k) … lab (-1)` to `mid` and rotating `back` by `-k`, which satisfies
  `lab' t = lab (t - k)` on all four decoding regions. Taking `k` to the maximum landing offset
  keeps `|mid'| = |mid| + k < 3 · 2^κ ≤ plusCompressionBound` for `κ ≥ 1`. It was **not
  implemented**, because its stated mechanism presupposes Invariant A's padded segments and
  substituting a different mechanism while A is unresolved is exactly the silent substitution
  `.claude/rules/plan-compliance.md` forbids on `.lean` files.

- **Prohibited workarounds**: no `sorry`, no `def X := True`, no vacuous placeholder. Nothing of
  the kind was written; the subtree is sorry-free and axiom-clean.


**Goal**: Prove the L⁺ twin of `exists_labelledLasso_of_history_realized`: every history of a
ℤ-frame countermodel compresses, at a given time, to a bounded `PlusLabelledLasso` that is locally
coherent, fulfilling, and realized by the model. Establish the two construction invariants the
later phases depend on.

**Tasks**:
- [x] Prove `exists_plusLabelledLasso_of_history_realized`. It must return, alongside the lasso,
      the landing position of the original time and the realization fact
      `∀ j, ∃ u, Λ.lab j = plusTypeAtM M Γ Del σ u`.
- [ ] **Invariant A — common cycle length.** *(deviation: skipped — dropped by the orchestrator
      decision recorded above; not provable as written, and not needed for correctness)* Pad
      `back` and `fwd` by repetition so every extracted
      lasso has `back.length = fwd.length = plusCompressionBound Γ Del`, and `mid.length` likewise
      padded to that bound. Prove padding preserves `lab`, hence preserves local coherence,
      fulfilment and realization. This is what keeps `NB`/`NF` from becoming a least common
      multiple over `n` differing lengths.
- [x] **Invariant B — common time alignment.** *(deviation: altered — normalized to the constant
      `plusAlignOffset Γ Del = 2 ^ κ` rather than to the maximum landing offset over a list, and
      by the `plusShift` prepend-and-rotate mechanism rather than by rotating Invariant A's padded
      segments, which no longer exist)* Prove that the landing position can be normalized
      to a single canonical offset across all extracted lassos, by rotating the padded segments.
      (C5) pins its witness to the same time `u` as the demand, so without this the witness lassos
      are re-timed and certify nothing.
- [x] Prove `plusLocalCoherentSeqLab_congr_bx`, transport of local coherence along a change of box
      guess that agrees on the boxed part of the closure.
- [x] Prove `exists_plusLabelledLasso_of_history`, the realization-free corollary.
- [x] *(addition, recorded)* Prove `plusLocalCoherentSeqLab_of_edges`, the presentation-free
      splice lemma the extraction consumes. It is monomorphic in `PlusFormula` and was held back
      from Phase 6 so that Phase 6 matched its own task list exactly.
- [x] Add the import line to `FormalSystem/Metalogic/Decidability/PlusWitnessFamily.lean`.

**Timing**: 2 hours

**Depends on**: 4, 5, 6

**Verification Tier**: interface

**Scope Hypothesis** *(result: REFUTED for Invariant A)*: the padding and rotation lemmas were
attempted before the main extraction, as directed. Invariant A does **not** force a structural
change to `PlusLabelledLasso` — the landed type was not edited and must not be — but it is not
provable at the extraction site either, for arithmetic reasons recorded in the BLOCKER above.
Original hypothesis, for the record: this phase asserts that Invariants A and B are provable at the extraction
site rather than requiring a change to `PlusLabelledLasso`. Confirm at implementation time by
proving the padding and rotation lemmas before the main extraction; if either forces a structural
change to the lasso type, stop and record it as a plan deviation rather than editing the landed
type in passing.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Compression/Extract.lean` - second half,
  appended
- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily.lean` - one added import line

**Verification**:
- `lake build` exits 0; no `sorry`; axioms unchanged.
- The two invariants are stated as named lemmas, not as side conditions buried in the extraction
  proof, so Phases 8 and 9 can cite them.

#### Reasoned Exclusions

*(Added at plan v2. The exclusion itself was decided and recorded at plan v1; this table states
it in the format the checklist requires, and adds nothing that was not already decided.)*

| Item | Reason | Evidence |
|------|--------|----------|
| Invariant A, "pad `back` and `fwd` by repetition so every extracted lasso has `back.length = fwd.length = plusCompressionBound Γ Del`" | Not provable as written: repetition reaches only multiples of a cycle's length, and `exists_base_plusCycleT` permits every length in `1 … 2^κ`, so a common padded length would have to exceed the bound the theorem itself states. Nothing downstream needs it for correctness | The concrete refutation at κ = 3 recorded in this phase's BLOCKER: cycle lengths 5, 7 and 8 admit no common padded length below `lcm(5, 7, 8) = 280`, against `plusCompressionBound = 56`. Recorded decision in `specs/703_lplus_compression_and_completeness/.decisions.json`, cycle 6 |
| The invariant's stated purpose, "so `NB = NF = plusCompressionBound`" | False about the landed substrate independently of the invariant: `perBack` is a product, never a least common multiple | `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Decide.lean:181`, `perBack := repBack.length * (lassos.map (·.back.length)).prod` |

**No residual work**: Invariant B was landed by a different and strictly stronger mechanism (the
constant-offset shift), and the segment bounds come free from the unpadded extraction. At plan v2
the question is moot in a second way as well: nothing in Stage 2 is aligned, so no later phase
reopens it.

**Closure record** *(exclusion: Invariant A, per the deviation at this phase's heading)*:
Invariant B is stated as the named lemmas `PlusLabelledLasso.shiftBy`,
`PlusLabelledLasso.lab_shiftBy`, `plusLocalCoherentSeqLab_comp_sub`,
`plusFulfillingSeqLab_comp_sub` and the consumer form
`exists_plusLabelledLasso_of_history_aligned`, all in `Compression/Extract.lean`, so Phases 8 and
9 cite a lemma rather than re-deriving a side condition. `exists_plusLabelledLasso_of_history_realized`
was strengthened, not weakened: it now additionally returns `i < plusAlignOffset Γ Del` and
`Λ.nm - i < plusAlignOffset Γ Del`, which is what makes the shifted mid bound come out at the
original `plusMidBoundC` rather than a widened one. The module builds with zero errors and zero
warnings and the subtree is sorry-free.

---

### Phase 8: The (C5) saturation — the lasso list and its bound [COMPLETED WITH EXCLUSIONS]

**Status change at plan v2, recorded**: this phase was `[BLOCKED]` in plan v1. It is now closed
with exclusions, because the target its remaining tasks served is **withdrawn as false** and no
future dispatch will revisit them. This is the canonical decision-gate shape: the phase's
blocker was the gate, the gate failed, and the plan's contingency branch — Stages 1 and 2 —
runs instead of the phases the gate would have unlocked. **The three resolutions plan v1
enumerated under this phase's BLOCKER are not carried forward and are not to be reopened**; all
three leave the certificate class alone and therefore inherit the refutation. They remain
readable in `plans/01_lplus-compression-completeness.md`.

**Goal** *(as planned; partly achieved, see the exclusions)*: build the lasso list by saturating
the (C5) witness demand, and prove the resulting count is bounded by `plusFamilyBound`.

**Tasks**:
- [x] Define the (C5) demand: for an index `i`, a window time `u`, and `stab φ` in the closure
      with `stab φ ∉ L i u`, the countermodel supplies a history `τ` with the same world state as
      `i`'s history at `u` and `¬ PlusTruthAt M τ u φ`. Prove this from `PlusTruthAt`'s `stab`
      clause. **Landed** as `Compression/Saturate.lean`, sorry-free and axiom-clean:
      `plusSameState`, `plusSameState_refl`, `plusSameState_symm`, `plusSameState_trans`,
      `plusTruthAt_stab_of_sameState`, `plusTypeAtM_mem_of_stab_of_state_eq`,
      `plusTypeAtM_stab_congr_state`, `plusTypeAtM_atom_congr_state`,
      `exists_history_state_eq_of_not_stab`, `plusTypeAtM_stab_demand`,
      `plusTypeAtM_stab_iff_forall_sameState`. *(the `→` direction and the two state congruences
      were added beyond plan v1's list and are recorded rather than absorbed)* This work is
      **design-independent** and is reused by Stage 2 — see the reuse table above.
- [~] *(excluded)* Define the saturation operator.
- [~] *(excluded)* Prove the saturation closes.
- [~] *(excluded)* Define `plusFamilyBound` and prove `lassos.length ≤ plusFamilyBound Γ Del`.
- [~] *(excluded)* Prove every listed lasso is bounded, locally coherent, fulfilling and realized.
- [~] *(excluded)* Record the superseded bound accountings in the module docstring.

#### Reasoned Exclusions

| Item | Reason | Evidence |
|------|--------|----------|
| The (C5) saturation operator | It exists only to build a `PlusSharingWitnessFamily` certifying an arbitrary ℤ-time non-validity. No such family exists for `pumpTarget`, so the operator cannot have the property it was to be built for, at any size | `probes/NoFiniteCertificate.lean`, `Probe703.compression_statement_fails`: sorry-free, axioms `[propext, Classical.choice, Quot.sound]`, recompiled independently at dispatch 20 |
| The proof that the saturation closes | Same reason: the fixpoint it would reach is a family that is proved not to exist for this target | Same declaration |
| `plusFamilyBound` and the lasso-count bound | There is no lasso-count bound to prove. Round 1's `2^|closure| × W` estimate is superseded, not merely unproved, because for some targets no family exists at any count | `reports/02_semantics-first-compression-research.md`, "Corrections to round 1", item 3; and the probe above |
| The per-lasso preservation lemmas across the saturation | They are properties of a construction that is not being built | Withdrawal record at the head of this plan |
| The module-docstring record of superseded accountings | Superseded by Phase 12, which corrects the coverage claims across the whole subtree in one pass rather than per module | Phase 12 below |
| The alignment budget that blocked this phase | The binding constraint was the withdrawn theorem's own `mid` bound. With the theorem withdrawn there is no budget to resolve, and on a graph there is nothing to align to | `reports/02_semantics-first-compression-research.md` section 1.3 and section 2.2 |

**No residual work**: nothing above is deferred, and no follow-up task records any of it. The
useful content of this phase — the demand layer — is landed and is consumed by Stage 2.

**Timing**: 2 hours planned; the landed task 1 took approximately 1 hour

**Depends on**: 7

**Verification Tier**: interface

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Compression/Saturate.lean` - new file, landed
- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily.lean` - one added import line, landed

**Verification** *(as achieved)*:
- `lake build` exits 0; the module is sorry-free and axiom-clean; zero errors and zero warnings.
- The count bound is **not** proved, and is excluded above rather than left as a commented
  estimate.

---

## Stage 1 — Land the refutation and correct the record (Phases 9-12)

Stage 1 turns two machine-checked probes into library declarations and stops the tree from
overstating what the landed certificate class covers. It depends on no open problem and it
changes no existing declaration.

---

### Phase 9: The two targets and their ℤ-time non-validity [COMPLETED]

**Goal**: Restate, in library style rather than as a probe copy, the two targets the refutations
are about, prove each is a genuine ℤ-time non-validity, and land the closure-membership
scaffolding both refutations consume.

**Tasks**:
- [x] Create `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Limits/Targets.lean` with a
      module docstring, `import FormalSystem.Metalogic.Decidability.PlusWitnessFamily.Examples`
      and `import FormalSystem.PlusLanguage.PlusNonValidities`, in the
      `FormalSystem.Metalogic.Decidability` namespace, `PlusSharingWitnessFamily` sub-namespace —
      matching where `Incompleteness.lean` puts its targets. *(completed)*
- [x] Define `pumpTarget` and `hopTarget`. Record the primitive syntax in the module docstring
      exactly as the research appendix gives it, so a reader can check the abbreviations:
      `Xp := untl ⊥ p`, `Xnp := untl ⊥ (p → ⊥)`, `Fp := untl (⊥ → ⊥) p`,
      `dXp := (⊡(Xp → ⊥)) → ⊥`, `dXnp := (⊡(Xnp → ⊥)) → ⊥`,
      `hopTarget := □dXp → (□dXnp → ⊥)` and
      `pumpTarget := □dXp → (□dXnp → ((Fp → Fp) → ⊥))`.
      *(deviation: altered — the abbreviation table is in the docstring verbatim as required, but
      the declarations are named after what they say (`nextTrue`, `nextFalse`, `someFuture`,
      `someNextTrue`, `someNextFalse`) rather than carrying the probes' `Xp`/`dXp` spellings into
      library names, per invariant C26's camelCase rule and this phase's own "name them after the
      formula" instruction. Both targets are parametric in `(p : Atom)` rather than fixed to a
      concrete atom, which the probes' own proofs permit because `natModel`'s valuation is
      atom-agnostic.)*
- [x] Prove `not_plusValidZTime_pumpTarget` and `not_plusValidZTime_hopTarget`. Both are refuted
      on the permissive frame `FormalSystem.PlusLanguage.PlusNonValidities.NF` with `natModel`,
      at the constant history and time `0`. This is the probes' own route and it transfers.
      *(deviation: altered — factored through two shared antecedent lemmas,
      `plusTruthAt_box_someNextTrue` and `plusTruthAt_box_someNextFalse`, since both targets have
      the same two antecedents; each non-validity theorem is then three lines. This is the
      factoring the Scope Hypothesis expected, relocated from the membership block, where it is
      not available, to the semantic side, where it is.)*
- [x] Land the closure-membership chain for both targets — the `plusConclusion_mem_closure` root
      and the `plusClosureOf_imp_left` / `_imp_right` / `_box` / `_stab` / `_untl_left` /
      `_untl_right` steps down to `Xp`, `Xnp`, `np`, `Fp` and `tp`. Name them after the formula
      they place, not after the probe's local abbreviations.
      *(deviation: altered — landed as TWO chains, 13 steps for `hopClosure` and 17 for
      `pumpClosure`, not one shared scaffolding. See the Scope Hypothesis resolution below.)*
- [x] Prove the closure-shape fact each refutation uses — that every `untl` member of the target
      closure has the guard the argument assumes — by `decide` on the concrete closure, and state
      the proved form rather than the assumed one.
      *(deviation: altered — proved by `simp` on the computed subformula list rather than by
      `decide`. `decide` cannot run here: with the atom left as a parameter the closure is not a
      closed term, so no `Decidable` instance evaluates. The `simp` route is strictly better than
      the `decide`-on-a-concrete-atom alternative, because it holds for every atom. The proved
      form is the strong guard-AND-event characterization, not the guard-only fact: `untl` members
      of `hopClosure p` are exactly `Xp` and `X¬p` (`untl_mem_hopClosure`), and of `pumpClosure p`
      exactly `Xp`, `X¬p` and `Fp` (`untl_mem_pumpClosure`), with the guard corollaries
      `untl_guard_eq_bot_of_mem_hopClosure` and
      `untl_guard_eq_bot_or_top_of_mem_pumpClosure` derived from them.)*
- [x] Add the import line to `FormalSystem/Metalogic/Decidability/PlusWitnessFamily.lean`.
      *(completed; the aggregator's `## Submodules` list gained the matching bullet in the same
      edit, so the docstring and the import block do not disagree.)*
- [x] Regenerate the library root: `lake exe mk_all --lib FormalSystem`. **Never hand-edit
      `FormalSystem.lean`** — invariant C33 compares it byte-for-byte against the generator.
      *(completed; the generator added exactly one line and nothing else, confirmed by diff.)*
- [x] Confirm the new module transitively imports `FormalSystem.Init` (invariant C24).
      *(completed; reached through `FormalSystem/Syntax/Atom.lean`, which imports
      `FormalSystem.Init` directly and is in the new module's import closure via the `PlusFormula`
      stack.)*
- [x] **Do not delete the probes.** `specs/703_lplus_compression_and_completeness/probes/`
      remains the provenance record for every declaration landed in Stage 1.
      *(completed — nothing under `probes/` was touched, renamed, or deleted.)*

**Timing**: 3 hours

**Depends on**: 8

**Verification Tier**: interface

**Scope Hypothesis**: the two targets share the `Xp`/`Xnp`/`dXp`/`dXnp` prefix, so one
membership scaffolding is asserted to serve both. Confirm at implementation time by diffing the
two probes' membership blocks (`probes/NoFiniteCertificate.lean` lines 72-91 against
`probes/HopFreeIncomplete.lean` lines 64-79); if the two closures diverge enough that factoring
costs more than it saves, land two blocks and record the count rather than forcing the estimate.

**Scope Hypothesis — RESOLVED, FALSIFIED.** The diff was performed as instructed, and the shared
prefix is real: the two probes' membership blocks agree on eleven of thirteen lines, differing only
in that the pump block adds `tail`, `FpFp`, `Fp` and `tp`. But the shared *text* cannot become a
shared *theorem*, and the reason is structural rather than a matter of cost. `plusClosureOf` is
indexed by the context, so `plusClosureOf ([] ++ [hopTarget p])` and
`plusClosureOf ([] ++ [pumpTarget p])` are two different `Finset PlusFormula` values. Every
membership fact is a fact about one of them, and nothing stated about either transports to the
other without a closure-monotonicity principle — which would additionally need
`hopTarget p ∈ plusClosureOf [pumpTarget p]`, and that is false: `hopTarget` is not a subformula
of `pumpTarget` (the two differ at the innermost consequent, `⊥` against `(Fp → Fp) → ⊥`, so
neither is a subformula of the other). Factoring here is not expensive; it is unavailable.

Two blocks were therefore landed, with the counts the hypothesis asked to be recorded: **13 steps
for `hopClosure`** (`hopTarget_mem_hopClosure` down to `notAtom_mem_hopClosure`) and **17 for
`pumpClosure`** (`pumpTarget_mem_pumpClosure` down to `notAtom_mem_pumpClosure`), plus 2
closure-shape lemmas on each side and one shared helper
(`untl_not_mem_top_subformulas`) — 35 declarations of membership scaffolding in all.

What *was* factored is the semantic side, which the hypothesis did not anticipate: both targets
carry the identical two antecedents `□⟐Xp` and `□⟐X¬p`, and both hold at the constant history of
the permissive frame for one reason, so `plusTruthAt_box_someNextTrue` and
`plusTruthAt_box_someNextFalse` are proved once and consumed by both non-validity theorems. The
sharing the hypothesis was reaching for exists; it lives one layer over from where the hypothesis
looked for it.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Limits/Targets.lean` - new file
- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily.lean` - one added import line
- `FormalSystem.lean` - regenerated by `lake exe mk_all --lib FormalSystem`, never by hand

**Verification**:
- `lake build FormalSystem.Metalogic.Decidability.PlusWitnessFamily` exits 0.
- No `sorry` in the new file; `#print axioms` on each new theorem shows no axiom beyond
  `propext`, `Classical.choice`, `Quot.sound`.
- The two non-validity theorems are confirmed to mention `PlusValidZTime`, not `PlusValidInt`.

**Verification — MEASURED**:
- Scoped build `lake build FormalSystem.Metalogic.Decidability.PlusWitnessFamily`: exit 0,
  1243 jobs, zero errors and zero warnings over both captured streams.
- Full `lake build`: exit 0, 2778 jobs, zero errors and zero warnings. The `.olean` of each of the
  three touched modules (`…Limits.Targets`, `…PlusWitnessFamily`, `FormalSystem`) is newer than
  the last source write, so the success line is backed by a real re-elaboration rather than a
  cache hit.
- `sorry` census over all four resolved source roots: `sorry_count: 0`, empty inventory.
- `#print axioms` on all fourteen new theorems: `[propext, Classical.choice, Quot.sound]`, except
  `untl_not_mem_top_subformulas`, which needs only `[propext]`. No axiom beyond the permitted
  three, and the new module declares no `axiom` of its own, so the repository's axiom count is
  unchanged at 14.
- Both non-validity theorems are stated against `PlusValidZTime`. `PlusValidInt` does not occur in
  the new module, and no carrier-normalization step is used — which is why this phase does not
  consume the `plusValidZTime_iff_plusValidInt` prerequisite.
- The vacuous-definition scan reports one repository-wide match,
  `FormalSystem/Examples/TemporalStructures.lean:495` (`int_domain_universal … := trivial`). It is
  pre-existing, outside this task's file scope, and not a placeholder: the ℤ-time history's domain
  is total by construction, so `trivial` is the honest proof term there. Zero vacuous definitions
  are attributable to this phase.

---

### Phase 10: Hop-free families are incomplete [COMPLETED]

**Goal**: Land `not_exists_hopFree_plusCertifies_hopTarget`: no family whose succession relation
never leaves the index it is read at certifies `hopTarget`. This is an independent incompleteness,
and it is what retires the hop-free route of Phase 1 as a completeness strategy while leaving
Phase 1's theorems true.

**Tasks**:
- [x] Create `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Limits/HopFree.lean`,
      importing `Limits/Targets.lean` and `PlusWitnessFamily/TransId.lean`.
- [x] Derive the forced structure: (C4) and the `imp`/`box` clauses of (C1') force both box
      guesses true, (C3) puts the two `⟐X`-formulas in every label, and (C5) with (C0) then give
      every state, at every time, a successor state carrying `p` and one omitting it.
- [x] Construct `n + 1` pairwise distinct `Step`-paths from that branching, where `n` is the
      family's lasso count.
- [x] Close the contradiction: under the hop-free hypothesis, `lift` makes every state path
      class-equal to a constant index, so a family with `n` indices presents at most `n` state
      paths. Use `Fintype.card_le_of_injective`, which the probe confirms closes this goal.
- [x] Record in the module docstring what this does **not** say: hop-freedom is incomplete, and
      `TransId.lean`'s four collapse theorems remain true and remain in the tree. The theorem
      bounds a *strategy*, not the substrate.
- [x] Add the import line to `FormalSystem/Metalogic/Decidability/PlusWitnessFamily.lean`;
      regenerate the library root with `lake exe mk_all --lib FormalSystem`.

**Timing**: 3 hours

**Depends on**: 9

**Verification Tier**: interface

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Limits/HopFree.lean` - new file
- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily.lean` - one added import line
- `FormalSystem.lean` - regenerated

**Verification**:
- `lake build` exits 0; no `sorry`; axioms unchanged.
- The theorem's hypothesis is confirmed to be exactly the hop-free condition
  `∀ u i j, S.trans u i j → i = j`, matching `TransId.lean`'s `hid`, so the two are about the
  same class.

**Verification — MEASURED**:
- Guarded, detached `lake build` of the two `Limits` modules: `exit_status=0`, 1236 jobs, **zero**
  `error:` and **zero** `warning:` lines over both captured streams; `HopFree.olean` present and
  newer than the source.
- `lean-sorry-census.sh FormalSystem FormalSystem.lean`: `sorry_count: 0`.
- `grep -c '^axiom '` over the resolved source roots: **14**, unchanged from the pinned baseline.
- `#print axioms` on all four new declarations
  (`not_exists_hopFree_plusCertifies_hopTarget`, `hopFree_branchesTrue`, `hopFree_branchesFalse`,
  `hopFree_deviates`): each exactly `[propext, Classical.choice, Quot.sound]`.
- Hypothesis confirmed identical to `TransId.lean`'s `hid`, character for character.

**Deviations from the plan as written**:
- The three forced-successor steps were factored out as three *named* lemmas
  (`hopFree_branchesTrue`, `hopFree_branchesFalse`, `hopFree_deviates`) rather than left inline,
  because each is a statement about an arbitrary family with no hop-freedom hypothesis and the
  plan's Phase 11 asks for the same three facts. They are still re-derived in Phase 11 against
  `pumpClosure`, as Phase 11 directs — the factoring is within one closure, not across the two.
- The probe's `Int.induction_on` route to "a hop-free succession path is constant" did not
  elaborate in this module's import closure (`ring` is not available there, and the `pred`-case
  goal shape `-↑i - 1` resisted the rewrite). Replaced with an `ℕ`-shift lemma plus `omega`, which
  needs no Mathlib tactic import and never produces a goal mentioning `-↑i - 1`.

---

### Phase 11: The landed certificate class is incomplete [COMPLETED]

**Goal**: Land `not_exists_plusCertifies_pumpTarget`, the phase that makes the withdrawal a
theorem of the tree: **no** `PlusSharingWitnessFamily` certifies `pumpTarget` at any time, for
any lasso count, any segment length and any succession relation.

**Tasks**:
- [x] Create `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Limits/NoCertificate.lean`,
      importing `Limits/Targets.lean`.
- [x] Reuse Phase 10's forced-successor consequences where they factor, and otherwise re-derive
      them here: (C4) and (C1')'s `imp`/`box` clauses force both box guesses true; (C3) puts
      `⟐Xp` and `⟐Xnp` in every label; (C5) and (C0) give every state, at every time, a successor
      carrying `p` and one omitting it.
- [x] Build the long-postponement path: start in the forward-periodic region at the mid length,
      follow `¬p`-successors for `k := n · perFwd + 1` steps, then take a `p`-successor. Prove it
      is a `Step`-path.
- [x] Obtain the tracking thread from `lift`, and read `Fp` along the whole run backwards through
      (C1')'s `untl` clause.
- [x] Apply the pigeonhole over the `n + 1` times spaced by the forward period, using
      `Fintype.exists_ne_map_eq_of_card_lt`, to find two times carrying the same index.
- [x] Loop the thread between those two times. `SharingSkeleton.transRaw_congr_NF` and
      `...data_congr_fwd` are what make the loop a genuine thread with the same labels; cite them
      rather than re-proving the congruence.
- [x] Contradict (C2'): the looped thread carries `Fp` at its entry and never reads `p`.
- [x] Record in the module docstring the **scope** of the failure, at its true generality: any
      target whose countermodels must contain, in a periodic region, a cycle with an exit under a
      pending eventuality. Name the root cause — limit closure against a finite, eventually
      periodic, all-threads-fulfilling structure — and say plainly that no bound repairs it.
- [x] Add the import line to `FormalSystem/Metalogic/Decidability/PlusWitnessFamily.lean`;
      regenerate the library root.

**Timing**: 4 hours

**Depends on**: 9

**Verification Tier**: interface

**Scope Hypothesis**: this phase is asserted to fit one agent run. The source probe is about 420
lines and Phase 9 lifts out roughly 90 of them. Confirm by writing the forced-structure block
first and measuring; if the phase overruns, split at the pigeonhole into **11.1** (the forced
successors from (C0), (C1'), (C3), (C4), (C5), plus the long-postponement path and its thread)
and **11.2** (the pigeonhole, the loop, and the (C2') contradiction). Decompose into decimal
sub-phases; never carry a `sorry`.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Limits/NoCertificate.lean` - new file
- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily.lean` - one added import line
- `FormalSystem.lean` - regenerated

**Verification**:
- `lake build` exits 0; no `sorry`; axioms unchanged.
- The theorem quantifies over **every** `S` and **every** `t`, with no bound, no lasso-count
  hypothesis and no hypothesis on `trans` — confirmed by reading the statement, since a stray
  hypothesis would make the theorem far weaker than the withdrawal it is recording.
- `#print axioms` reports exactly `[propext, Classical.choice, Quot.sound]`.

**Verification — MEASURED**:
- Full guarded, detached `lake build`: `exit_status=0`, **2780 jobs**, **zero** `error:` and
  **zero** `warning:` lines over both captured streams.
- `.olean` newer than source confirmed for `Limits/HopFree`, `Limits/NoCertificate`,
  `Limits/Targets`, `PlusWitnessFamily` and the `FormalSystem` root.
- `lean-sorry-census.sh`: `sorry_count: 0`. `grep -c '^axiom '` over the resolved roots: **14**,
  unchanged.
- `#print axioms` on `not_plusCertifies_pumpTarget`, `not_exists_plusCertifies_pumpTarget` and
  `plusCompression_fails_at_pumpTarget`: each exactly `[propext, Classical.choice, Quot.sound]`.
- Statement read back: `not_plusCertifies_pumpTarget (S : PlusSharingWitnessFamily ([] :
  PlusContext) (pumpDelta p)) (t : ℤ) : ¬ S.PlusCertifies t`. No bound, no lasso-count hypothesis,
  no hypothesis on `trans`, no hypothesis on the window or the periods.

**Scope Hypothesis — RESOLVED, not split.** The phase fit one run: the module is 440 lines, and the
forced-structure block is 90 of them. No decomposition into 11.1/11.2 was needed and none was made.

**Deviations from the plan as written**:
- The module adds three explicit Mathlib imports — `Mathlib.Data.Fintype.Pigeonhole`,
  `Mathlib.Tactic.Ring`, `Mathlib.Tactic.WLOG`. The plan's file list did not anticipate them
  because the probe it transcribes does `import FormalSystem` and so has the whole tree. `ring` is
  genuinely absent from `Limits/`'s closure; the three-file precedent for importing
  `Mathlib.Tactic.Ring` directly is followed.
- The forced-successor facts are re-derived here, as the plan's own task list directs, rather than
  imported from Phase 10's named lemmas: the two closures are distinct `Finset PlusFormula` values.

---

### Phase 12: Correct the record, pin Stage 1, and read the paired repository [COMPLETED WITH EXCLUSIONS]

**Goal**: Stop the tree overstating the landed certificate class's coverage, land Stage 1's
documentation and gate rows, and establish by reading — not by assumption — what the paired
model checker's export contract currently is.

**Tasks**:
- [x] Correct `FormalSystem/Metalogic/Decidability/PlusWitnessFamily.lean`'s header section
      "A tense operator under a `⊡`: the certificate class was empty, and is not any more". What
      it says is true and stays: the class is non-empty and certifies both stability targets. What
      it must now add is that **non-empty is not complete** — the class does not certify
      `pumpTarget`, by `not_exists_plusCertifies_pumpTarget` — and that which fragment it does
      cover is an open question. Record the open question here, where the class is described.
- [x] Correct `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Incompleteness.lean`'s
      header sentence "It no longer records an obstruction, because there is no longer one to
      record." There is one to record; point at `Limits/`. Keep the rest, which is about the
      retired congruences and is accurate.
- [x] Correct `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/README.md` where it says
      completeness of the certificate class "is now repaired". It was repaired **on those two
      targets**; it is refuted in general.
- [x] Correct `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/TransId.lean`'s header,
      which describes hop-freedom as "the compression's choice". There is no compression; add the
      pointer to `Limits/HopFree.lean` and state that the four theorems remain true and are kept.
- [x] Read `FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/README.md` around its
      "empty certificate class" sentence and correct it **only if** it makes a coverage claim
      about the L⁺ class; if it is about the pre-redesign history, leave it and say so.
- [x] Record in `Compression/Extract.lean`'s module docstring that the alignment half
      (`plusAlignOffset` through `exists_plusLabelledLasso_of_history_aligned`) is retained and
      unused, why, and that C17's dead-declaration census is expected to report it. C17 is
      reporting-only and never affects the exit code, so this is documentation, not a waiver.
- [x] Add four rows to `docs/theorem-index.md`'s Decidability section, in the format of the
      neighbouring L⁺ rows, for `not_plusValidZTime_pumpTarget`,
      `not_exists_plusCertifies_pumpTarget`, `not_plusValidZTime_hopTarget` and
      `not_exists_hopFree_plusCertifies_hopTarget`: paper label `—`, frame class `ZTime` for the
      two non-validities and `—` for the two incompleteness theorems, axioms `pcq pinned:C2`.
- [x] Add the four matching `#print axioms` lines to the `AX_SRC` heredoc and the four
      `'<name>' depends on axioms: [propext, Classical.choice, Quot.sound]` lines to the
      `AXIOM_BASELINE` heredoc of `scripts/check-module-invariants.sh`, **in the same relative
      order**. The check is a whole-string equality, so an order mismatch fails the gate.
- [x] Update the C2 pass message's number word. The rule is mechanical: the word must spell the
      value of `grep -c 'depends on axioms'` over the `AXIOM_BASELINE` heredoc. This does not fail
      the gate, which is exactly why it is easy to miss.
- [x] Satisfy invariant C15 for the four new declarations: `Paper: —` plus a reason at the
      declaration, since all four are formalization-native.
- [x] **Read the paired repository's export contract**, at
      `/home/benjamin/Projects/ModelChecker`, together with the hand-off note
      `specs/archive/700_lplus_completeness_programme_survey/notes/02_cross-repo-handoff.md`,
      which names the issue whose fourth need was to be this task's compression bound. Record, in
      this task's implementation summary, three things: what the export format is today, that the
      compression bound it expected **does not exist** for the landed certificate class, and that
      under the re-scoped target the contract changes shape from a list of lassos to a finite
      model — states, edges, valuation, state labels, one path and a time — whose search bound is
      a bound on the number of world states, expected doubly exponential in the closure in the
      worst case. **This is a read and a record, not a claim to make in advance**: the paired
      repository was not read in research round 2, so nothing above may be asserted about its
      current format until this task is done.
- [x] **Never write to `/home/benjamin/Projects/ModelChecker`.** The hand-off is by content. No
      file in that repository is created, edited or staged by this task.
- [x] Run `bash scripts/check-module-invariants.sh` in full and confirm every gate passes.

**Timing**: 3 hours

**Depends on**: 10, 11

**Verification Tier**: full

**Scope Hypothesis**: the gate edits are asserted to be exactly ten — four index rows, four
`AX_SRC` lines, four `AXIOM_BASELINE` lines and one message string, counted as ten line-groups —
and the baseline count is asserted to move from 18 to 22. Confirm by running
`grep -c 'depends on axioms'` over the heredoc before and after. If any other check (C15, C19
docstring coverage, C23 naming, C24 imports, C33 root currency) newly reports against the new
subtree, fix it in this phase rather than deferring it to Phase 18.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily.lean` - header correction
- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Incompleteness.lean` - header correction
- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/README.md` - coverage-claim correction
- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/TransId.lean` - header correction
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/README.md` - conditional correction
- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Compression/Extract.lean` - docstring note
- `docs/theorem-index.md` - four added rows
- `scripts/check-module-invariants.sh` - four `AX_SRC` lines, four `AXIOM_BASELINE` lines, one
  message string

**Verification**:
- `bash scripts/check-module-invariants.sh` exits 0 with C2 reporting twenty-two pinned sets.
- `grep -c 'depends on axioms'` over the `AXIOM_BASELINE` heredoc returns 22.
- No file under `/home/benjamin/Projects/ModelChecker` is modified, confirmed by
  `git -C /home/benjamin/Projects/ModelChecker status --porcelain` being unchanged from its
  state before the read.

**Verification — MEASURED**:
- Full guarded, detached `lake build`: `exit_status=0`, **2780 jobs**, **zero** `error:` and
  **zero** `warning:` lines. Run after each edit round; clean each time.
- `grep -c 'depends on axioms'` over the `AXIOM_BASELINE` heredoc: **22** (was 18), and the
  `AX_SRC` heredoc carries **22** `#print axioms` lines in the same relative order.
- `bash scripts/check-module-invariants.sh`: `PASS C2 all twenty-two pinned axiom sets match
  baseline` (verified against a live compile, not transcribed); `PASS C15` for all 61 paper-anchor
  citations and all 231 theorem-index rows; `PASS INV`; `PASS` for C8, C11, C16, C21, C22, C23,
  C24, C25, C25N, C33, C34b, C35, C9D and the rest. **1 check group failed: B0 only** — see the
  exclusion below.
- `sorry_count: 0`; axiom count **14**, unchanged; one pre-existing vacuous match outside this
  task's file scope, zero attributable here.
- `plusTruth_iff_mem` and `plusRefutes_of_certifies` both still print exactly
  `[propext, Classical.choice, Quot.sound]`, and neither statement was edited.
- `git -C /home/benjamin/Projects/ModelChecker status --porcelain`: only its pre-existing
  ` M specs/events.jsonl`, identical before and after the read. **No file in that repository was
  created, edited or staged.**

**Scope Hypothesis — CONFIRMED.** The gate edits were exactly the asserted ten line-groups, and the
baseline count moved from 18 to 22 as predicted.

**Exclusions** (enumerated, reasoned, evidenced — this is why the marker is
`[COMPLETED WITH EXCLUSIONS]` rather than `[COMPLETED]`):

1. **Invariant B0 does not pass.** `FAIL B0 expected exactly 1 Boneyard directory at ./Boneyard,
   found 2`. The second is `./.claude/worktrees/agent-aa19bfa3bfef394ff/Boneyard`, a leftover
   *harness* worktree from the aborted dispatch 21, still registered in `git worktree list`.
   *Evidence it is not this task's*: it fails identically at `main`'s own HEAD with none of this
   dispatch's changes present, confirmed by running B0's own `find` in the main tree with the
   dispatch worktree excluded; the directory is gitignored (`.gitignore:106:/.claude`); and its
   only commit `228168b3b` is already landed on `main` as `9355b68fe`, so nothing is lost by
   removing it. *Reason it was not fixed here*: deleting a registered git worktree belonging to
   another session is a destructive git operation outside an implementation agent's scope, and
   `/refresh` is the sanctioned remedy. *Remedy, one command*:
   `git worktree remove --force .claude/worktrees/agent-aa19bfa3bfef394ff`.
2. **The paired-repository read is partially discharged.** The five points plan v4's amendment
   directs be recorded ARE recorded, in the implementation summary — but they are read off report
   706 and plan v4, which are this repository's own artifacts, not off
   `/home/benjamin/Projects/ModelChecker`. The read of that repository's *current* export format and
   bound configuration was delegated and had not reported when this phase closed. The summary says
   so plainly rather than presenting the five points as a completed read. A successor closing Phase
   21 must complete it. The standing prohibition on writing to that repository was honoured and is
   evidenced above.

**Additional work not in the plan, done here rather than deferred**: the `INV` invariant went stale
because Phases 10-11 added two modules, so the generated inventory blocks in `README.md`,
`FormalSystem/README.md`, `FormalSystem/Metalogic/README.md` and `Boneyard/README.md` were
regenerated with `check-module-invariants.sh --emit-inventory`. The phase's own Scope Hypothesis
directs exactly this ("If any other check ... newly reports against the new subtree, fix it in this
phase rather than deferring it to Phase 18").

---


### Amendment to Phase 12 at plan v4 — the paired-repository record

**Phase 12's text above is preserved verbatim and is not edited by this revision.** Stage 1 is
unchanged; only Stage 2 is amended. One bullet of Phase 12 nonetheless instructs the implementer
to record a claim that report 706 has since refuted, so the correction is stated here, additively,
rather than by retouching the phase.

The bullet in question is the paired-repository read, which says the contract "changes shape from
a list of lassos to a finite model — states, edges, valuation, state labels, one path and a time —
whose search bound is a bound on the number of world states, expected doubly exponential in the
closure in the worst case."

**Record this instead** (report 706, Q1.3 and Q7):

1. The **finite-graph** certificate must not become an export contract. It cannot represent
   countermodels the current lasso-family contract already represents — `θ.neg` is a `⊡`-free
   target the landed L family certifies and no finite-carrier certificate can.
2. The intended L⁺ contract is the **time-sliced graph**: per slice, an edge matrix and a state
   labelling; three segments `back`/`mid`/`fwd` of slices; one target path and time; `bx`. The
   current lasso family is the special case of `k` lassos with edges `i → i` only, so the wire
   format is a **strict extension, not a replacement**.
3. The search bound is a **tuple** `(n, nb, nm, nf)` — slice width and three segment lengths. **No
   bound on `n` is proved for any L⁺ target**, and none should be configured from a formula yet.
   The claim "the search bound is a bound on the number of world states" is wrong in kind: there
   is no finite number of world states to bound. For `⊡`-free targets the landed L bounds apply
   unchanged, and the registry's period-folding caveat carries over to `nb`/`nf`.
4. The checker additionally requires **tail-stability**, so a search that finds a countermodel
   with unstable tails must re-present it with the pre-period moved into `mid` and the period
   multiplied.
5. The never-report-validity discipline stands: an empty search at any bound licenses nothing for
   L⁺ targets containing `⊡`, and will until a finite model property is proved.

Everything else in Phase 12 — the six documentation corrections, the four theorem-index rows, the
four `AX_SRC`/`AXIOM_BASELINE` lines, the C2 message word, C15, the standing prohibition on
writing to `/home/benjamin/Projects/ModelChecker`, and the full gate run — is unchanged and
binding as written.

---
## Stage 2 — The time-sliced certificate (Phases 13-21)

Stage 2 builds the certificate the semantics actually has: a **time-sliced** bi-serial labelled
graph presenting a frame on the infinite carrier `ℤ × Fin n` with finite fibres, whose liveness is
computed rather than demanded and whose tails are required stable. It yields **completeness
relative to tail-stable sliced models**, plus the **embedding of the landed L witness family**,
which is the only completeness theorem this research supports and is what restores parity with the
L side that plan v2's finite-graph shape gave up.

Each root cause of the withdrawn routes disappears by construction, and the plan records which:

- **The finite carrier is gone.** The frame's carrier is `ℤ × Fin n`, infinite with finite fibres,
  so `Probe706.no_ofStep_sat` does not apply and `θ` is representable. This is the plan v4
  amendment.
- **Absolute-time alignment is gone.** The slice time is the only time; there are no rows pinned
  to an absolute origin, so there is no period to align and no offset to compute. Plan v2's
  constraint survives verbatim as Phase 17's Scope Hypothesis.
- **Histories are no longer the unit**, so there are no witness paths raising demands of their
  own — and the `witness` field, whose index set would now be infinite, is dropped.
- **All-threads fulfilment is replaced by fulfilment of live positions only**, so a path that
  postpones an eventuality forever is simply a different, truthful, labelled path. This is what
  `not_exists_plusCertifies_pumpTarget` forces.
- **The demanded `lift` field is gone**, because every history of the presented frame is an offset
  step path and every step path carries its own true type sequence.

---

### Phase 13: The sliced certificate type and the three-segment slice readout [COMPLETED]

**Goal**: Declare `PlusGraphPath`, `PlusSlice` and `PlusSlicedCertificate`, define the slice
readout and the derived per-slice edge and label functions, and define `BiSerial` as a condition
**decided on the window** and extended by periodicity.

**Tasks**:
- [x] Create `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Basic.lean` and the
      aggregator `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate.lean`; add the
      aggregator's import to `FormalSystem/Metalogic/Decidability.lean`; regenerate the library
      root with `lake exe mk_all --lib FormalSystem`. **Never hand-edit `FormalSystem.lean`** —
      invariant C33 compares it byte-for-byte against the generator.
- [x] Declare `PlusGraphPath` with the fields fixed in the Lean Challenge Statements block. This
      structure is **carried forward unchanged from plan v2**; do not redesign it.
- [x] Declare `PlusSlice` and `PlusSlicedCertificate` with the fields fixed in the Challenge
      block. Confirm by reading the declarations that `PlusSlicedCertificate` carries **no**
      `stepR`, **no** `stateLab`, and **no** `witness` field. Their absence is the amendment.
- [x] Define `PlusGraphPath.lab : ℤ → Finset PlusFormula` and `PlusGraphPath.st : ℤ → Fin n` by
      the three-segment readout, reusing the generic readout lemmas of
      `WitnessFamily/Compression/Extract.lean` (`getD_mapC`, `readout_backC`, `readout_midC`,
      `readout_fwdC`, `periodic_rel_of_windowC`), which are stated over `{α} [Inhabited α]` and
      mention no formula. Supply the `Inhabited (Finset PlusFormula × Fin n)` instance from
      `n_pos`.
- [x] Define `PlusSlicedCertificate.slice : ℤ → PlusSlice n C` by the **same** readout at
      `α := PlusSlice n C`, supplying `Inhabited (PlusSlice n C)` from `n_pos` (the everywhere-false
      edge relation with the empty labelling; it is never read inside the window, and the readout
      lemmas are what guarantee that).
- [x] Define the two derived accessors `G.edge t w u := (G.slice t).edge w u` and
      `G.slab t w := (G.slice t).lab w`, and prove `G.slab_sub : ∀ t w, G.slab t w ⊆ plusClosureOf (Γ ++ Del)`
      from `lab_sub` through the readout.
- [x] Prove the three decoding-region lemmas for the slice sequence, mirroring `lab_neg`,
      `lab_mid` and `lab_fwd`, so later phases cite a lemma rather than unfolding the readout. Do
      the same for `PlusGraphPath` if plan v2's three lemmas are not already reusable verbatim.
- [x] Prove `G.slice_periodic_back` and `G.slice_periodic_fwd`: outside the window the slice
      sequence is periodic with period `|back|` leftward and `|fwd|` rightward. This is what makes
      every later window decision sound, and it is the fact `coherent_iff_window` plays on the L
      side.
- [x] Define `PlusSlicedCertificate.BiSerial` as the window-decided condition: bi-seriality is
      checked for every `t` in `[-|back|, |mid| + |fwd|)` and every `w`, and extended to all `t` by
      the two periodicity lemmas. Prove `biSerial_iff_window`, the equivalence between the
      window-decided form and the `∀ t` form, **in both directions** — the `←` direction is what
      the checker needs and the `→` direction is what Phase 14's frame construction needs.
- [x] Prove `BiSerial` is `Decidable`.
- [x] Record in the module docstring, citing
      `specs/706_lplus_finite_model_property_and_completeness/probes/NoFiniteCarrierModel.lean`
      by path and `Probe706.no_ofStep_sat` by name, why the carrier is sliced: a certificate
      presenting a finite-carrier frame cannot certify `θ.neg`, a `⊡`-free ℤ-time non-validity the
      landed L family already certifies. State plainly that the finite graph is the one-slice
      special case (`back = fwd = [slice]`, `mid = []`), so nothing was lost.
- [x] Confirm the new modules transitively import `FormalSystem.Init` (invariant C24).

**Timing**: 4 hours

**Depends on**: 12

**Verification Tier**: interface

**Scope Hypothesis**: the field lists pinned in the Lean Challenge Statements block are asserted to
be sufficient for the frame of Phase 14, the checker of Phase 17 and the soundness proof of
Phase 18. Confirm at implementation time by writing the **signatures** of `BiSerial` and
`Certifies` against the declared fields before the structures are declared final. If a field is
missing or wrong, record the correction as a deviation at this phase's heading and update the
Challenge block in this plan, loudly and once — do not absorb it silently, and do not let the
flagship statements drift. Separately asserted: the generic readout lemmas instantiate at
`PlusSlice n C` with no change. Confirm by reading their binders; if any is monomorphic in a
load-bearing position, write the slice-sequence readout explicitly in this module and record that
it was written rather than reused.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Basic.lean` - new file
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate.lean` - new aggregator
- `FormalSystem/Metalogic/Decidability.lean` - one added import line
- `FormalSystem.lean` - regenerated by `lake exe mk_all --lib FormalSystem`, never by hand

**Verification**:
- `lake build` exits 0; no `sorry`; `#print axioms` on each new declaration shows no axiom beyond
  `propext`, `Classical.choice`, `Quot.sound`.
- `biSerial_iff_window` is a proved biconditional, not a one-directional lemma.
- The structures carry no field named `lift`, no field named `trans`, no field named `witness`,
  no field named `stepR` and no field named `stateLab` — confirmed by reading the declarations.
  Their absence is the design.
- A one-slice certificate (`back = fwd = [s]`, `mid = []`) elaborates, confirming the finite-graph
  special case is recovered.

**Verification — MEASURED**:
- Full guarded, detached `lake build` (`--no-share`): `exit_status=0`, **2782 jobs**, **zero**
  `error:` and **zero** `warning:` lines over both captured streams.
- `lean-sorry-census.sh`: `sorry_count: 0`.
- `#print axioms` on all twelve new declarations: each within
  `[propext, Classical.choice, Quot.sound]`; `getD_mem_of_lt` needs only `[propext]` and `cyc_mem`
  only `[propext, Quot.sound]`.
- `biSerial_iff_window` is a proved **biconditional** (`constructor` with both branches discharged),
  not a one-directional lemma. `forall_slab_iff_window` likewise.
- **Field-absence confirmed by reading the declarations**: `PlusGraphPath` has exactly
  `back`/`mid`/`fwd`/`back_ne`/`fwd_ne`/`label_sub`; `PlusSlice` exactly `edge`/`lab`/`lab_sub`;
  `PlusSlicedCertificate` exactly `n`/`n_pos`/`back`/`mid`/`fwd`/`back_ne`/`fwd_ne`/`bx`/`target`/
  `targetTime`. A grep for `lift`, `trans`, `witness`, `stepR` and `stateLab` as field names over all
  three structures returns **0**.
- The one-slice special case is not merely asserted: `onePointCertificate` elaborates and
  `slice_onePointCertificate` **proves** its slice sequence is the constant `s` at every time.
- C24: both new modules reach `FormalSystem.Init` through `BiLasso/Periodic.lean`, which imports it
  directly.

**Scope Hypothesis — CONFIRMED, both halves**:
1. *The field lists are sufficient.* Confirmed by **writing**, not asserting: `BiSerial` and
   `BiSerialWindow` are defined in full against the declared fields, and two of the checker's four
   clause groups — `BoxFaithful` (C3, on `bx` and `slab`) and `Target` (C4, on `target` and
   `targetTime`) — are written here rather than deferred to Phase 17, which will consume them. The
   two remaining groups need Phase 15's computed liveness for their *content*, but their field
   dependencies (`slice`, `edge`, `slab`) are all present and are exercised by the two written here.
   **No field was found missing or wrong, so no correction to the Challenge block is needed.**
2. *The generic readout lemmas instantiate at `PlusSlice n C` with no change.* Confirmed by reading
   their binders: `getD_mapC`, `getD_range_mapC`, `readout_backC`, `readout_midC`, `readout_fwdC`
   and `periodic_rel_of_windowC` are all stated over `{α : Type*} [Inhabited α]`, with no
   monomorphic load-bearing position. The slice-sequence readout is therefore **reused, not
   rewritten**.

**Deviations from the plan as written**:
- **`Inhabited (PlusSlice n C)` needs no `n_pos`.** The plan says to supply it "from `n_pos`"; in
  fact the inert slice (everywhere-false `edge`, empty `lab`) is definable at every `n`, including
  `n = 0`, because `edge` and `lab` are total functions out of `Fin n`. The instance is
  unconditional and the hypothesis is not threaded.
- **`Inhabited (Finset PlusFormula × Fin n)` is supplied from `back_ne`, not from `n_pos`.**
  `PlusGraphPath` has no `n_pos` field, and using the head of its own `back` segment is strictly
  better than adding one: the default is then automatically a *member* of the path's own data, which
  is what makes `datum_mem` hold at every time with no special case and `lab_sub` hold with no side
  condition. `PlusGraphPath.n_pos` is recovered as a **theorem** from `back_ne`.
- **`BiSerial` is the `∀ t` form and `BiSerialWindow` the window-decided one**, with
  `biSerial_iff_window` bridging them. The plan's wording ("define `BiSerial` as the window-decided
  condition") would make `G.frame h`'s hypothesis the decided form, but the frame construction reads
  the condition at an arbitrary time, so the `∀ t` form has to be the one the Challenge block's
  `frame (h : G.BiSerial)` signature names. Both forms exist and are provably equivalent, so nothing
  is lost either way.
- **`exists_window_eq` is proved by residue, not by induction.** The plan says bi-seriality is
  "extended to all `t` by the two periodicity lemmas"; stating bi-seriality *at one slice* makes the
  extension a single residue computation (`t % nb - nb` on the left, `nm + (t - nm) % nf` on the
  right) rather than a double induction. The two periodicity lemmas are still proved and exported.
- **Two extra lemmas were needed that the `Formula`-side readout layer does not state**:
  `getD_mem_of_lt` and `cyc_mem`. The `Formula` side never needs a decoded datum's *membership*,
  only its value.
- **`ring` is unavailable in this module's import closure** (as in `Limits/`), so the arithmetic in
  `exists_window_eq` is done with `omega` plus `Periodic.emod_add_mul` and `Int.emod_eq_of_lt`.

---

### Phase 14: The presented frame on `ℤ × Fin n` [NOT STARTED]

**Goal**: Define the generic `FrameOver.ofSlicedStep`, instantiate it as `G.frame`, define
`G.model`, and prove that the frame's histories are exactly the offset step paths of the slice
sequence. This is the phase that replaces plan v2's `FrameOver.ofStep` and it is where the
amendment is cashed out.

**Tasks**:
- [ ] Create `FormalSystem/Semantics/SlicedFrame.lean` with a module docstring; add its import to
      `FormalSystem/Semantics.lean` and regenerate the library root.
- [ ] Define `FrameOver.ofSlicedStep` on the carrier `ℤ × W` with `[Finite W] [Nonempty W]`,
      following `SharingSkeleton.frame` (`WitnessFamily/Sharing/Skeleton.lean:1404`) as the
      template: a literal `FrameOver intOrder`, a two-sided relation
      `(t, w) —d→ (t + d, u)` holding exactly when a `d`-step `R`-path runs from `w` at `t` to `u`
      at `t + d`, with the negative direction by the reflection law.
- [ ] Prove the frame laws as **named lemmas**, not inline `by` blocks, so Phase 19 can cite them:
      - reflection, by symmetry of the two-sided relation;
      - *Limit*, by `TaskFrame.limit_of_succOrder` (`Semantics/TaskFrame.lean:1591`) at the
        zero-duration law;
      - *Saturation*, by `TaskFrame.saturation_of_fib_finite` (`Semantics/TaskFrame.lean:2222`),
        whose docstring names exactly this case — **infinite carrier, finite fibres**. The fibre
        over a time is `W`, which is `Finite` by hypothesis; the carrier `ℤ × W` is not.
- [ ] Prove `FrameOver.ofSlicedStep_isRegular`, and `ofSlicedStep_mem_HF_iff`: a function
      `ℤ → ℤ × W` is the path of a world history exactly when it is `fun t => (t + k, f t)` for
      some offset `k` and some `f` with `R (t + k) (f t) (f (t + 1))` for all `t`. Route it through
      `FrameOver.mem_HF_iff_adjacent` (`Semantics/IntNormalForm.lean:348`). **Both directions are
      required**: Phase 18 needs `←` and Phase 19 needs `→`.
- [ ] Record in that module's docstring that `FrameOver.ofStep` (`IntNormalForm.lean:456`) is
      **not** a special case to route through, because it requires `[Finite W]` on the whole
      carrier, and cite `Probe706.no_ofStep_sat` for why that matters. Do not modify
      `IntNormalForm.lean`.
- [ ] Create `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Frame.lean`; define
      `G.frame h := FrameOver.ofSlicedStep (fun t w u => G.edge t w u = true) …` at `W := Fin G.n`,
      discharging `[Finite]` and `[Nonempty]` from `n_pos` and the two seriality obligations from
      `h : G.BiSerial` through `biSerial_iff_window`.
- [ ] Define `G.model h : TaskModel (G.frame h).toTaskFrame`, valuing an atom at `(t, w)` by its
      membership in `G.slab t w`.
- [ ] Prove `G.mem_HF_iff_slicedPath`, the specialization of `ofSlicedStep_mem_HF_iff` to `G`, and
      define `G.pathHistory : PlusGraphPath … → WorldHistory (G.frame h).toTaskFrame` for a path
      whose state sequence follows `G.edge`.
- [ ] Prove the **shift-normalization lemma**: by `plusTruthAt_timeShift`
      (`PlusLanguage/PlusTruth.lean:264`) every truth question on `G.frame h` can be asked at
      offset `0`, so a position is `(t, w)` with `t` the slice time and no separate origin is
      carried. This is what keeps the position space finite per slice and is cited by Phases 15
      and 17.
- [ ] Confirm the new modules transitively import `FormalSystem.Init` (invariant C24).

**Timing**: 5 hours

**Depends on**: 13

**Verification Tier**: interface

**Scope Hypothesis**: `FrameOver.ofSlicedStep` is asserted to belong in a **new** Semantics module
rather than appended to the landed `Semantics/IntNormalForm.lean`, so that no landed core file is
edited. Confirm at implementation time by checking whether `ofSlicedStep` needs any private
definition of `IntNormalForm.lean` that is not exported; if it does, place it in
`IntNormalForm.lean` instead and **record the relocation**, since that widens this phase's blast
radius from "new file" to "landed core file edited". Separately asserted: the two frame-law
discharges are one `TaskFrame` lemma each. Confirm by reading
`saturation_of_fib_finite`'s and `limit_of_succOrder`'s hypotheses against the constructed
relation before writing the proofs; if either needs a side condition the template does not supply,
prove it as its own named lemma in this phase rather than inlining it.

**Contingency**: if this phase overruns one agent run, split into **14.1** (the generic
`FrameOver.ofSlicedStep`, its three frame laws and `ofSlicedStep_mem_HF_iff`) and **14.2**
(`G.frame`, `G.model`, `G.mem_HF_iff_slicedPath`, `G.pathHistory` and the shift-normalization
lemma). Decompose into decimal sub-phases; never carry a `sorry`.

**Files to modify**:
- `FormalSystem/Semantics/SlicedFrame.lean` - new file, the generic sliced frame
- `FormalSystem/Semantics.lean` - one added import line
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Frame.lean` - new file
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate.lean` - one added import line
- `FormalSystem.lean` - regenerated

**Verification**:
- `lake build` exits 0; no `sorry`; axioms unchanged.
- `#check` confirms `G.frame h` elaborates at `FrameOver intOrder` and that its `WorldState` is
  **not** `Finite` — the whole point of the amendment. State this as an explicit
  `example : ¬ Finite ((G.frame h).WorldState)` where `G` is a concrete two-slice certificate, or,
  if that is awkward to prove directly, as an `Infinite` instance on the carrier; either form must
  be proved, not asserted in a comment.
- `ofSlicedStep_mem_HF_iff` and `G.mem_HF_iff_slicedPath` are proved biconditionals.
- `git diff` over `FormalSystem/Semantics/IntNormalForm.lean` shows **no hunk**, unless the Scope
  Hypothesis's relocation branch was taken and recorded.

---

### Phase 15: Positions, computed liveness, and the Q5 factorization [NOT STARTED]

**Goal**: Build the position space over a slice, compute liveness on it as a fixpoint in both time
directions with **both** directions of the characterization proved, and prove the factorization
that justifies combining them. This is Stage 2's novel core and one of its two highest-risk phases.

**Tasks**:
- [ ] Create `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Live.lean`.
- [ ] Define `G.Pos χ`: pairs of a slice state and a Hintikka type over the subformulas of `χ`
      that agrees with `G.slab t w` on the state formulas at the relevant slice. Prove it is a
      `Fintype` with a `DecidableEq`, and bound its cardinality by `G.n * 2 ^ |subformulas χ|`.
      **This is a cardinality of the position space, not a bound on `n`** — it is not the bound
      "Bounds: none, deliberately" forbids, and the docstring must say so.
- [ ] Define `G.succP t` and `G.predP t`, the `Finset`-valued one-step successor and predecessor
      on positions **from slice `t` to slice `t + 1`** and back: an edge requires `G.edge t` on the
      state component and the (C1') one-step unfolding clauses on the type component.
- [ ] Prove `succP` and `predP` are non-empty on the position space, from `G.BiSerial` and the
      type-completion argument. Without this the fixpoints are vacuous.
- [ ] Prove the **Q5 factorization**, as an explicit named lemma rather than as a rationale in a
      comment. Three named pieces, in this order:
      1. `histories_through_paste`: two histories of `G.frame h` agreeing on the state at `t` paste
         into a history following the first before `t` and the second from `t` on. This is S4, and
         it is `FormalSystem.PlusLanguage.paste` (`PlusLanguage/PlusPasting.lean:111`) plus its
         `paste_agreeUpTo` / `paste_agreeFrom` lemmas — cite them, do not re-prove them.
      2. `label_splices_of_type_eq`: a Hintikka labelling of a bi-infinite path with origin type
         `h` is a backward half and a forward half agreeing at the origin. This is S5; the checked
         form is `truth_paste_of_type_eq` in this task's own
         `probes/TypePreservingPaste.lean`, which is a **probe, not a library declaration**, so
         this phase restates and re-proves it in library style rather than importing it.
      3. `forall_forall_or_iff`, the elementary equivalence
         `(∀ ρ, ∀ σ, P ρ ∨ Q σ) ↔ ((∀ ρ, P ρ) ∨ (∀ σ, Q σ))` at inhabited index types, stated
         generically and used to split the universal condition. Non-emptiness of both index sets
         is supplied by `G.BiSerial`.
      Together these give `stab_factors`: for each Hintikka type `h` at `(t, w)`, "`⊡¬ψ` at
      `(t, w)`" is "no backward continuation in the backward language at `h`, **or** no forward
      continuation in the forward language at `h`". **This lemma is the justification for
      `live = fwdLive ∩ bwdLive`**, and the module docstring must say so by name.
- [ ] Record, as a one-line lemma or a docstring note citing `PlusFormula.reflectTime`, that the
      backward condition is the forward one on the reversed slice graph, so `bwdLive` is `fwdLive`
      of the time-reflected certificate. Use this to avoid writing the backward fixpoint twice if
      the reflection is cheap; if it is not, write both and record that it was written rather than
      derived.
- [ ] Define `G.fwdLive t χ`, the forward-live positions at slice `t`: the greatest set `X` of
      positions such that from every position of `X` there is a `succP`-path inside `X`
      discharging each eventuality pending at it. Implement as a decreasing `Finset` iteration
      whose inner reachability step is the least fixpoint `AUFix.lfp`, imported from
      `WitnessFamily/Sharing/Fulfil.lean` — it is stated at `{α : Type*} [DecidableEq α]` and
      mentions no formula, so it is reused, not transcribed. Prove termination and the fixpoint
      property.
- [ ] Define `G.bwdLive t χ` symmetrically on `predP`, and `G.live t χ := G.fwdLive t χ ∩ G.bwdLive t χ`.
- [ ] Prove the **soundness direction**, `mem_live_of_path`: a position occupied at slice time `t`
      by a bi-infinite locally coherent, fulfilling labelled path of `G` is live.
- [ ] Prove the **completeness direction**, `exists_path_of_mem_live`: every live position lies on
      such a path. Factor it through the Q5 factorization above — a position lies on a bi-infinite
      fulfilling labelled path exactly when it has a fulfilling forward half and a fulfilling
      backward half — so the two fixpoints are combined rather than solved jointly.
- [ ] Record in the module docstring why liveness is computed rather than demanded, naming the
      refutation: a demanded all-threads fulfilment condition on a finite eventually periodic
      structure is refuted by `not_exists_plusCertifies_pumpTarget`, and asking only live positions
      to fulfil is exactly what removes that root cause.

**Timing**: 5 hours

**Depends on**: 14

**Verification Tier**: interface

**Scope Hypothesis**: `AUFix` is asserted to be reusable verbatim for the inner reachability step,
and the outer greatest fixpoint is asserted to be new work with no counterpart in the tree.
Confirm at implementation time by reading `AUFix`'s binders: it is the **universal** `A[g U e]`
operator, so it supplies the inner "all successors eventually deliver" half and **not** the
existential fair-path half. If the outer iteration needs a second generic fixpoint library rather
than a bespoke `Finset` loop, write it generically in this module and say so, rather than inlining
it twice. Separately asserted: `truth_paste_of_type_eq` transcribes from the probe without change
of hypotheses. Confirm by diffing the probe's statement against the library restatement and
recording any added hypothesis.

**Contingency**: if this phase overruns one agent run, split into **15.1** (positions, `succP`,
`predP`, their non-emptiness, and the three-piece Q5 factorization) and **15.2** (`fwdLive`,
`bwdLive`, `live`, and both directions of the characterization). Decompose into decimal
sub-phases; never carry a `sorry` and never define a placeholder that is vacuously true.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Live.lean` - new file
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate.lean` - one added import line
- `FormalSystem.lean` - regenerated

**Verification**:
- `lake build` exits 0; no `sorry`; axioms unchanged.
- **Both** directions of the liveness characterization are stated as named lemmas, so Phase 18
  cites one and Phase 19 cites the other rather than re-deriving either.
- `stab_factors` exists as a named declaration, not as a comment — grep for it.
- `G.live` is evaluated on a small concrete certificate and confirmed to be neither empty nor the
  whole position space, so the fixpoint is not vacuous in either direction.

---

### Phase 16: Tail-stability, with the four-state fixture [NOT STARTED]

**Goal**: Define the one-period transfer operators on live-position sets, define `TailStable`,
prove the re-presentation lemma that makes the demand harmless, and **build the four-state
counterexample as a named test fixture** confirming the demand is actually needed. This is the
amendment's only visible failure mode (report 706, risk R2), so it gets its own phase and is
scheduled **before** the checker.

**Tasks**:
- [ ] Create `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Stable.lean`.
- [ ] **Build the fixture first**, before the definitions, as `Fixture.fourState`: a certificate
      with back-tail slice `{a, b}` and edges `a → a`, `a → b`, `b → b`, with an atom `q` true at
      `b` only; `mid = [c]` with `a → c`, `b → c`; forward tail `{d}` with `c → d`, `d → d`.
      Evaluate the stability label of `⊡(XX ¬q)` at `(-1, a)` and at `(-2, a)` with `#eval` or
      `#guard`, and prove as named lemmas that it is **true** at `(-1, a)` and **false** at
      `(-2, a)`. This is the fact that forces the design: the checker must not read tail
      stability-labels at one residue only.
- [ ] Define `Φ_back`, the one-period transfer of live-position sets leftward through the back
      tail, carrying pending eventualities on the type component; and `Φ_fwd`, its mirror. Prove
      each is monotone on `Finset (G.Pos χ)`.
- [ ] Define `L₀`, the live-position set computed from the window together with the forward tail,
      and its mirror `R₀`.
- [ ] Define `PlusSlicedCertificate.TailStable` as `Φ_back L₀ = L₀ ∧ Φ_fwd R₀ = R₀`, and prove it
      `Decidable`. Prove `tailStable_iff_window`: under tail-stability, the true forward-live sets
      at every `t = -k · |back|` coincide with `L₀`, so every stability clause is decidable on the
      window. **This is the lemma the whole design rests on**; state it as a biconditional or as
      two named implications, never as a one-line `by simp`.
- [ ] Prove the **re-presentation lemma**, `exists_tailStable_repr`: for any `G`, there is a `G'`
      with the pre-period absorbed into `mid` and the period multiplied by the cycle length such
      that `G'.TailStable`, and `G'.frame` is isomorphic to `G.frame` — hence truth is unchanged.
      The sequence `Φ_back^k L₀` is eventually periodic because subsets of a finite position space
      are finite, which is what makes the pre-period and period exist. **State no order for
      either**; see "Bounds: none, deliberately".
- [ ] Prove `Fixture.fourState` is **not** tail-stable as presented, and exhibit its
      re-presentation, so the fixture doubles as the worked example of
      `exists_tailStable_repr`.
- [ ] Record in the module docstring: what tail-stability is, why it is required (the fixture),
      that it costs the checker exactly one `Φ` application beyond the Phase 15 fixpoints, and
      that a search on the paired repository's side must re-present an unstable countermodel
      rather than reject it.

**Timing**: 4 hours

**Depends on**: 15

**Verification Tier**: interface

**Scope Hypothesis**: the demand `Φ_back L₀ = L₀` (one application) is asserted to be sufficient —
that is, asserted to imply `Φ_back^k L₀ = L₀` for all `k`, which is immediate from the equation but
is **not** by itself the claim that the true forward-live sets equal `L₀`. Confirm at
implementation time by proving `tailStable_iff_window` before any checker clause depends on it,
and by evaluating the fixture. **If the fixture shows the demand is too weak**, the correct
response is to strengthen the demand — a deeper `Φ` iteration, or a type-recurrence cut on slices
as the L side uses for a single history — and to record the change loudly at this phase's heading.
It is **never** to weaken a theorem, to relax the fixture, or to reach for a `sorry`.

**Contingency**: if this phase overruns one agent run, split into **16.1** (the fixture and the
two transfer operators with their monotonicity) and **16.2** (`TailStable`,
`tailStable_iff_window`, and `exists_tailStable_repr`). Decompose into decimal sub-phases; never
carry a `sorry`.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Stable.lean` - new file, including
  the `Fixture` namespace
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate.lean` - one added import line
- `FormalSystem.lean` - regenerated

**Verification**:
- `lake build` exits 0; no `sorry`; axioms unchanged.
- The fixture's two asymmetry lemmas are **proved**, not `#eval`-ed only, so a later refactor
  cannot silently break the fact that motivates the design.
- `TailStable` synthesizes a `Decidable` instance by `inferInstance`, not by assertion.
- `exists_tailStable_repr`'s statement mentions **no** bound on the resulting periods — confirmed
  by reading it.

---

### Phase 17: The decidable checker [NOT STARTED]

**Goal**: Define `PlusSlicedCertificate.Certifies` and prove it decidable, with liveness computed
by Phase 15's fixpoints and every clause read on the window under Phase 16's tail-stability.

**Tasks**:
- [ ] Create `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Check.lean`.
- [ ] Include `G.BiSerial` and `G.TailStable` as the first two conjuncts of `Certifies`. Both are
      window-decided and both are already `Decidable`.
- [ ] Define the **existential side**: the target path is locally coherent
      (`PlusLocalCoherentSeqLab` on its decoded labels, reused from `Compression/Types.lean`),
      fulfilling (`PlusFulfillingSeqLab`, likewise), follows `G.edge` on its state component at
      each slice time, and agrees with `G.slab` on the state formulas at every time. There are
      **no witness paths**: the `witness` field is dropped, and the existential obligations it
      carried are discharged by liveness — "`⊡χ ∉ G.slab t w`" is "some live position over
      `(t, w)` omits `χ`", by Phase 15's `exists_path_of_mem_live`.
- [ ] Define the **universal side**: for every slice time `t` in the window, every state `w` and
      every `⊡χ` in `G.slab t w`, no live position over `(t, w)` omits `χ`. This is the clause that
      replaces plan v2's time-indexed (C5) demand, and under tail-stability it is a property of a
      **window position**, extended to all `t` by periodicity.
- [ ] Define the **box clause**: `G.bx χ = true` exactly when `χ` belongs to every live position of
      every state of every window slice. By `plusBox_const` this is what a global modality needs,
      and by the periodicity lemmas the window suffices.
- [ ] Define the **target clause**: every `γ ∈ Γ` is in the target path's label at `targetTime` and
      every `δ ∈ Del` is not.
- [ ] Assemble `Certifies` as the conjunction and prove `decidableCertifies`. Every quantifier
      ranges over a `Finset` or a `Fintype`: window slice times, slice states, closure members,
      position sets, and the three finite segments of the target path.
- [ ] Exhibit a small concrete certificate — the one-slice finite-graph special case is the
      natural first one, and `Fixture.fourState`'s re-presentation the natural second — and run
      the checker on each with `#guard`, confirming the checker actually evaluates rather than
      merely type-checking. Record the wall time. Note for the record that the landed (C2')
      decision procedure of the withdrawn route did not finish in 150 seconds interpreted on a
      four-lasso family, so a checker that runs is itself a result.

**Timing**: 4 hours

**Depends on**: 16

**Verification Tier**: interface

**Scope Hypothesis**: `Certifies` is asserted to need exactly the two structural conjuncts
(`BiSerial`, `TailStable`) plus four groups of clauses — existential, universal, box, target — with
no residual field-shaped demand. Confirm by checking that **no clause quantifies over a time in a
way that would need alignment**; any clause that does is a relapse into the withdrawn plan v1
design and must be recorded and redesigned, not absorbed. Nothing is aligned here: the slice time
is the only time. Separately asserted: dropping the `witness` field costs the checker nothing,
because both directions of the Phase 15 characterization are available. Confirm by writing the
`⊡`-clauses first; if an existential obligation cannot be discharged from liveness, **stop and
record it** rather than reinstating a field whose index set is infinite.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Check.lean` - new file
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate.lean` - one added import line
- `FormalSystem.lean` - regenerated

**Verification**:
- `lake build` exits 0; no `sorry`; axioms unchanged.
- `decidableCertifies` is confirmed by `example (G) : Decidable G.Certifies := inferInstance`
  synthesizing, not by assertion.
- The `#guard` on each concrete certificate returns, within a recorded wall time.
- No clause of `Certifies` mentions an alignment offset, a period product, or an absolute origin —
  confirmed by grep for `plusAlignOffset` and by reading the definition.

---

### Phase 18: Soundness into the existing interface [NOT STARTED]

**Goal**: Prove `PlusSlicedCertificate.plusRefutes_of_certifies`, landing
`PlusWitnessFamily.PlusRefutes Γ Del` unchanged.

**Tasks**:
- [ ] Create `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Sound.lean`.
- [ ] Prove the truth lemma: for a labelled path of `G` meeting the existential side, and every `χ`
      in the target closure, `χ ∈ path.lab t ↔ PlusTruthAt (G.model h) (G.pathHistory path) t χ`.
      Structural induction on `χ`, restricted to the subformulas of the formula in hand.
      - `atom`, `bot`, `imp`: local coherence, plus the slice labelling at the position's own slice
        time.
      - `box`: the box clause plus `plusBox_const`.
      - `untl`, `snce`: fulfilment plus the one-step clauses. These are the cases
        `plusTruth_iff_mem` already proves along a thread; mirror that proof rather than inventing
        a new one.
      - `stab`: the universal side gives the `→` direction, because every history of `G.frame h`
        is an **offset** step path (Phase 14's `mem_HF_iff_slicedPath`), hence, after the
        shift-normalization lemma, a labelled path of `G`, hence occupies a live position; the
        completeness direction of liveness (`exists_path_of_mem_live`) gives the `←` direction,
        which is where the dropped `witness` field is paid for.
- [ ] Prove `plusRefutes_of_certifies` by instantiating `PlusWitnessFamily.PlusRefutes` at
      `(G.frame h).toTaskFrame`, its `FrameClass.ZTime.Sat` instance, `G.model h`, the target
      path's history and `G.targetTime`, discharging the two conjuncts from the target clause and
      the truth lemma.
- [ ] Record in the module docstring that this declaration is **beside** the landed
      `PlusSharingWitnessFamily.plusRefutes_of_certifies`, not in place of it: the two are about
      different certificate classes and land the same interface. Record also that the presented
      frame's carrier is infinite, and why that is required.

**Timing**: 5 hours

**Depends on**: 17

**Verification Tier**: full

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Sound.lean` - new file
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate.lean` - one added import line
- `FormalSystem.lean` - regenerated

**Verification**:
- Full `lake build` exits 0; no `sorry`.
- `#print axioms FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.plusRefutes_of_certifies`
  reports exactly `[propext, Classical.choice, Quot.sound]`.
- `plusTruth_iff_mem` and `plusRefutes_of_certifies` are unchanged: confirmed by `git diff` over
  `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Agreement.lean` showing **no hunk**.
- The theorem's conclusion is confirmed to be `PlusWitnessFamily.PlusRefutes Γ Del` verbatim, not a
  new refutation predicate.

---

### Phase 19: Completeness relative to tail-stable sliced models [NOT STARTED]

**Goal**: Prove `exists_plusSlicedCertificate_of_tailStable_countermodel`: a countermodel carried
by a bi-serial, tail-stable sliced structure yields a certificate on the same carrier that the
checker accepts.

**Tasks**:
- [ ] Create `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Complete.lean`.
- [ ] Take the carrier from `G₀` unchanged — `n`, `back`, `mid`, `fwd` — so the produced `G` differs
      from `G₀` only in the guessed fields `bx`, `target` and `targetTime`. The conclusion's four
      equations pin exactly that, and they are what make the theorem a statement about the class
      rather than about a re-derived structure.
- [ ] Confirm the slice labelling is **well defined** at each carrier element `(t, w)`: `⊡` and the
      atoms are state determined, and `Compression/Saturate.lean`'s `plusTypeAtM_stab_congr_state`
      and `plusTypeAtM_atom_congr_state` are exactly this fact, with `plusBox_const` handling `□`.
      Cite them; do not re-prove them. Note the difference from plan v2: the "state" here is the
      carrier element `(t, w)`, not a time-free graph vertex.
- [ ] Build the target path. The label sequence and the state sequence must be cut at the **same**
      recurrence, so run the pigeonhole on the **paired** carrier `Fin n × PlusTypeState C` rather
      than on `PlusTypeState C` alone. `exists_iterT_lt_card` and `exists_iterT_lt_card_aux` are
      stated over `{W : Type} [Finite W] [Nonempty W]` with an abstract relation, so they apply at
      the paired carrier directly. The slice time supplies the period; there is nothing to align.
- [ ] Discharge the **existential side** from the extraction's realization facts:
      `plusTypeAtM_localCoherentSeqLab` and `plusTypeAtM_fulfillingSeqLab` give local coherence and
      fulfilment, and agreement with `G.slab` is the state-determination step above.
- [ ] Discharge the **universal side**: a live position over `(t, w)` is realized by an actual
      labelled path through `(t, w)` (Phase 15's completeness direction), and
      `plusTypeAtM_stab_iff_forall_sameState` turns `⊡χ ∈ G.slab t w` into `χ` at every history
      through `(t, w)`. So no live position over `(t, w)` omits `χ`. Tail-stability is what makes
      the window check equivalent to the `∀ t` statement — cite `tailStable_iff_window`.
- [ ] Discharge the **box clause** from `plusBox_const`, and the **target clause** from the
      refuting time.
- [ ] Discharge `BiSerial` and `TailStable` from the hypotheses `hser` and `hstab` directly; they
      are carried, not re-derived.
- [ ] Record in the module docstring what this theorem is and is not. It is **completeness relative
      to tail-stable sliced models**. It is **not** the finite model property: it says nothing
      about whether a ℤ-time non-validity has such a countermodel at all. It is also **not**
      completeness relative to *finite* models, which is the statement plan v2 aimed at and which
      `Probe706.not_finite_carrier_fmp` shows would have been the wrong target. No slice-width
      bound and no period bound is stated here, because none is proved; and the full-L⁺ sliced
      finite model property is **open, not refuted**.

**Timing**: 5 hours

**Depends on**: 18

**Verification Tier**: full

**Scope Hypothesis**: the landed extraction pipeline is asserted to transfer from
`PlusTypeState C` to the paired carrier `Fin n × PlusTypeState C` by instantiating the generic
pigeonhole, with the good-cycle theorem re-run rather than re-proved. Confirm at implementation
time by reading `exists_good_cycle_of_plusTypeSeq`'s binders: if it is monomorphic in
`PlusTypeState C` in a load-bearing position, a parallel paired-carrier version must be **written
and recorded**, not substituted silently. Whichever way it goes, record the count of declarations
added.

**Contingency**: if this phase overruns one agent run, split into **19.1** (the well-definedness of
the slice labelling and the paired-carrier extraction of the target path) and **19.2** (the four
groups of `Certifies` clauses plus the two carried structural conjuncts). Decompose into decimal
sub-phases; never carry a `sorry`.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Complete.lean` - new file
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate.lean` - one added import line
- `FormalSystem.lean` - regenerated

**Verification**:
- Full `lake build` exits 0; no `sorry`; axioms unchanged.
- The theorem's hypotheses are confirmed to place **no** bound on `G₀.n`, `|G₀.back|`, `|G₀.mid|`
  or `|G₀.fwd|`: it is relative completeness for an arbitrary tail-stable sliced structure, and a
  bound would be a different, weaker theorem.
- The theorem's conclusion is confirmed to carry the four carrier equations, so it is a statement
  about the same carrier and not about a re-derived one.
- The module states no width bound and no period bound anywhere, confirmed by grep.
- The module nowhere describes the sliced finite model property as refuted, confirmed by grep for
  "refut" in its docstrings.

---

### Phase 20: The landed L witness family embeds [NOT STARTED]

**Goal**: Prove `exists_plusSlicedCertificate_of_not_plusValidZTime_ofFormula` — every ℤ-time
non-validity of L, transported to L⁺, has a sliced certificate. This restores parity with the
landed L class that plan v2's finite-graph shape gave up, and it is **the only completeness theorem
this research supports**.

**Tasks**:
- [ ] Create `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Embed.lean`.
- [ ] Define the embedding `slicedOfWitnessFamily`: from a `WitnessFamily [] [φ]` with `k` lassos,
      build a certificate with `n = k`, edges `i → i` only, and `G.slab t i` the atoms and
      `bx`-boxes of `(lassos i).lab t`.
- [ ] Build the tails and the window from the lassos' **common periods** — their product, which is
      exactly what `perBack` (`PlusWitnessFamily/Decide.lean:181`) already computes on the L⁺ side;
      mirror that computation rather than inventing a second one. **Claim no order for the
      resulting periods**; a product of the family's own periods is a construction, not a bound.
- [ ] Prove the embedded certificate is `BiSerial` (each `i → i` self-loop is its own forward and
      backward successor) and `TailStable` (with edges `i → i` only, `Φ_back` is the identity on
      the position sets it acts on, so the fixed-point demand is immediate). Both proofs are short
      and both must be **proved**, not asserted.
- [ ] Prove `slicedOfWitnessFamily_certifies`: the embedded certificate meets `Certifies`. The four
      clause groups come from the family's own certification conditions; the universal side is the
      one to watch, since with edges `i → i` only, the live positions over `(t, i)` are exactly the
      ones the single lasso `i` realizes.
- [ ] Assemble the flagship: start from `¬ PlusValidZTime (ofFormula φ)`, transport to
      `¬ ValidZTime φ` with `plusTruthAt_ofFormula` (`PlusLanguage/PlusValidity.lean:168`), apply
      the landed `exists_witnessFamily_of_not_validZTime`
      (`WitnessFamily/Compression/Family.lean:153`), and embed.
- [ ] Record in the module docstring what this theorem buys: the sliced class is **non-vacuous on
      branching-free targets** and is at least as strong as the landed L class there — which is
      exactly what the withdrawn `PlusGraphCertificate` was not, by `Probe706.no_ofStep_sat`. Cite
      the probe by path. State plainly that this is **not** completeness for L⁺: targets containing
      `⊡` are not covered, and that is the open Stage 3 question.
- [ ] Record the hand-off to task 704: this theorem is a ready-made non-vacuity witness for its
      shape gates.

**Timing**: 4 hours

**Depends on**: 19

**Verification Tier**: full

**Scope Hypothesis**: "edges `i → i` only" is asserted to suffice — that is, the landed
`WitnessFamily`'s per-lasso structure is asserted to need no cross-index edge in the embedded
slice graph. Confirm at implementation time by **reading the `WitnessFamily` structure's fields
before building the edge relation**: if its succession relation genuinely relates distinct indices
in a way the certification conditions depend on, use that relation as the slice edge relation
instead and **record the correction**. The theorem statement is unchanged either way; only the
construction is. Separately asserted: the common period is the product of the lassos' periods, as
`perBack` computes. Confirm by reading `perBack`; if the L-side family's periods are stored
differently from the L⁺ side's, mirror the L-side computation and record which was used.

**Contingency**: if this phase overruns one agent run, split into **20.1** (the construction, plus
`BiSerial` and `TailStable`) and **20.2** (`slicedOfWitnessFamily_certifies` and the flagship
assembly). Decompose into decimal sub-phases; never carry a `sorry`.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Embed.lean` - new file
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate.lean` - one added import line
- `FormalSystem.lean` - regenerated

**Verification**:
- Full `lake build` exits 0; no `sorry`; axioms unchanged.
- The flagship's statement is confirmed to quantify over **every** `φ : Formula` with no bound and
  no side condition beyond `¬ PlusValidZTime (ofFormula φ)`.
- `#guard` evaluates the embedded certificate's checker on one concrete L non-validity, confirming
  the construction is not merely type-correct.
- The module nowhere claims completeness for L⁺, confirmed by reading its docstrings.

---

### Phase 21: Acceptance gates and the closing record [NOT STARTED]

**Goal**: Land Stage 2's documentation rows and axiom pins, run the full gate set, and close the
task with an honest record of what was proved and what was not.

**Tasks**:
- [ ] Add four rows to `docs/theorem-index.md`'s Decidability section, for
      `PlusSlicedCertificate.decidableCertifies`,
      `PlusSlicedCertificate.plusRefutes_of_certifies`,
      `exists_plusSlicedCertificate_of_tailStable_countermodel` and
      `exists_plusSlicedCertificate_of_not_plusValidZTime_ofFormula`: paper label `—`, frame class
      `ZTime`, axioms `pcq pinned:C2`.
- [ ] Add the four matching `#print axioms` lines to `AX_SRC` and the four `AXIOM_BASELINE` lines,
      **in the same relative order**, in `scripts/check-module-invariants.sh`. The check is a
      whole-string equality, so an order mismatch fails the gate.
- [ ] Update the C2 pass-message number word again, by the same mechanical rule: it must spell the
      value of `grep -c 'depends on axioms'` over the heredoc.
- [ ] Satisfy invariant C15 for the four new declarations: `Paper: —` plus a reason, since all four
      are formalization-native.
- [ ] Write the `PlusSlicedCertificate` subtree README, or a header section in the aggregator,
      stating plainly: what the certificate class is; that its presented frame has an **infinite**
      carrier with finite fibres, and **why** — citing
      `specs/706_lplus_finite_model_property_and_completeness/probes/NoFiniteCarrierModel.lean`
      and `Probe706.no_ofStep_sat`; that soundness, relative completeness for tail-stable sliced
      models, and the L-family embedding are proved; that the **finite-carrier** finite model
      property is **refuted**; that the **sliced** finite model property is **open, not refuted**,
      and is a separate task; and that the expected slice width is doubly exponential as a research
      finding rather than a theorem of this tree.
- [ ] Record, in the same place, that the CTL-like fragment does not rescue the finite-carrier
      shape (`Probe706.not_finite_carrier_fmp_fragment`), so the sliced shape is needed already
      there, and that the fragment's own finite model property is a separate research-first
      successor that this task does not plan.
- [ ] **Read the paired repository's export contract** at `/home/benjamin/Projects/ModelChecker`
      and record, in this task's implementation summary, the five points of the Phase 12 amendment
      note above: the finite graph is withdrawn as a contract; the time-sliced graph is the target;
      the search bound is the tuple `(n, nb, nm, nf)` with **no bound on `n` proved**;
      tail-stability requires re-presentation rather than rejection; and the never-report-validity
      discipline stands. **This is a read and a record, not a claim to make in advance.**
- [ ] **Never write to `/home/benjamin/Projects/ModelChecker`.** The hand-off is by content. No
      file in that repository is created, edited or staged by this task.
- [ ] Regenerate the library root with `lake exe mk_all --lib FormalSystem` and confirm C33 passes.
- [ ] **Regenerate `typst/generated/status.typ`.** This task's new `.lean` modules move the
      committed counts that `.githooks/pre-commit` gates on. Run
      `bash scripts/typst-sync-check.sh --fix` and commit **only** `typst/generated/status.typ`, by
      explicit path. Re-read task 650's status from `specs/state.json` at implementation time
      rather than trusting this line; `specs/TODO.md` has been stale on this point before and
      `state.json` is authoritative.
- [ ] Before any use of the pre-commit hook's `--no-verify` bypass, confirm the status-file count
      drift is the **only** failing gate. Anything else the hook reports is to be fixed, never
      bypassed.
- [ ] Run `bash scripts/check-module-invariants.sh` in full and confirm every gate passes — C2,
      C15, C19, C23, C24 and C33 included.
- [ ] Run `#print axioms` on all eight new pinned declarations and confirm each reports exactly
      `[propext, Classical.choice, Quot.sound]`.
- [ ] Confirm the whole new subtree is sorry-free by content, not by line number (invariant C3).

**Timing**: 2 hours

**Depends on**: 20

**Verification Tier**: full

**Scope Hypothesis**: the gate edits are asserted to be exactly seven line-groups — four index
rows, four `AX_SRC` lines and four `AXIOM_BASELINE` lines counted as one group each, plus one
message string — and the baseline count is asserted to move from 22 to 26. Confirm with
`grep -c 'depends on axioms'` before and after. If another check newly reports against either new
subtree, fix it here rather than closing the task over it.

**Files to modify**:
- `docs/theorem-index.md` - four added rows
- `scripts/check-module-invariants.sh` - four `AX_SRC` lines, four `AXIOM_BASELINE` lines, one
  message string
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate.lean` - closing header section, or a
  new `PlusSlicedCertificate/README.md`
- `typst/generated/status.typ` - regenerated by `scripts/typst-sync-check.sh --fix`
- `FormalSystem.lean` - regenerated

**Verification**:
- `bash scripts/check-module-invariants.sh` exits 0 with C2 reporting twenty-six pinned sets.
- `grep -c 'depends on axioms'` over the `AXIOM_BASELINE` heredoc returns 26.
- `git diff` over `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Agreement.lean` shows no
  hunk across the whole task.
- `git -C /home/benjamin/Projects/ModelChecker status --porcelain` is unchanged from its state
  before the read.

---

## Testing & Validation

- [ ] `lake build` exits 0 at the end of every phase, and at task end from a clean state.
- [ ] Zero `sorry` anywhere in either new subtree, asserted by content rather than by line number
      (invariant C3).
- [ ] Zero vacuous placeholder definitions. In particular `Certifies` is confirmed non-trivial by
      the Phase 17 `#guard`s, `live` is confirmed non-degenerate by the Phase 15 evaluation, and
      `TailStable` is confirmed non-trivial by `Fixture.fourState` failing it as presented.
- [ ] `#print axioms` on each of the eight new pinned declarations reports exactly
      `[propext, Classical.choice, Quot.sound]` — no new axiom.
- [ ] `plusTruth_iff_mem` and `plusRefutes_of_certifies` have unchanged statements, confirmed by an
      empty `git diff` over `PlusWitnessFamily/Agreement.lean`.
- [ ] `FormalSystem/Semantics/IntNormalForm.lean` is unmodified, unless Phase 14's Scope
      Hypothesis relocation branch was taken and recorded.
- [ ] The presented frame's carrier is confirmed **infinite** by a proved `example`, not by a
      comment — the amendment's whole content.
- [ ] `FrameOver.ofStep` is called by **no** module of Stage 2, confirmed by grep.
- [ ] `bash scripts/check-module-invariants.sh` passes in full, C2 and C33 included.
- [ ] Every new module transitively imports `FormalSystem.Init` (invariant C24).
- [ ] `FormalSystem.lean` is byte-current against `lake exe mk_all --lib FormalSystem`, never
      hand-edited (invariant C33).
- [ ] The four probe files under `specs/703_lplus_compression_and_completeness/probes/` still exist
      and are unmodified, since they are the provenance record for Stage 1 and for Phase 15's Q5
      restatement.
- [ ] `specs/706_lplus_finite_model_property_and_completeness/probes/NoFiniteCarrierModel.lean` is
      unmodified. This task **cites** it and does not transcribe or edit it.
- [ ] No slice-width bound, tail-period bound, or complexity claim appears as a proved statement
      anywhere in either new subtree, since none is proved.
- [ ] No module describes the **sliced** finite model property as refuted. Only the
      **finite-carrier** one is refuted.
- [ ] No file under `/home/benjamin/Projects/ModelChecker` was created, edited or staged.

## Artifacts & Outputs

New Lean modules, Stage 1, under `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Limits/`:

- `Targets.lean` - the two targets, their ℤ-time non-validity, the closure scaffolding
- `HopFree.lean` - hop-free families are incomplete
- `NoCertificate.lean` - the landed certificate class is incomplete

New Lean module, Stage 2, under `FormalSystem/Semantics/`:

- `SlicedFrame.lean` - the generic `FrameOver.ofSlicedStep` on `ℤ × W`, its three frame laws and
  its history characterization

New Lean modules, Stage 2, under `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/`:

- `Basic.lean` - `PlusGraphPath`, `PlusSlice`, `PlusSlicedCertificate`, the slice readout,
  `BiSerial`
- `Frame.lean` - `G.frame`, `G.model`, the history characterization, shift normalization
- `Live.lean` - positions, the two liveness fixpoints with both directions, the Q5 factorization
- `Stable.lean` - the transfer operators, `TailStable`, the re-presentation lemma, and
  `Fixture.fourState`
- `Check.lean` - `Certifies` and `decidableCertifies`
- `Sound.lean` - the truth lemma and `plusRefutes_of_certifies`
- `Complete.lean` - completeness relative to tail-stable sliced models
- `Embed.lean` - the landed L witness family embeds

Modified:

- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily.lean` - three added imports, header
  correction
- `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate.lean` - new aggregator
- `FormalSystem/Metalogic/Decidability.lean` - one added import
- `FormalSystem/Semantics.lean` - one added import
- `FormalSystem.lean` - regenerated, never hand-edited
- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/{Incompleteness,TransId}.lean`,
  `.../PlusWitnessFamily/README.md`, `.../PlusWitnessFamily/Compression/Extract.lean`,
  `.../WitnessFamily/Sharing/README.md` - documentation corrections only, no declaration changes
- `docs/theorem-index.md` - eight added rows
- `scripts/check-module-invariants.sh` - eight `AX_SRC` lines, eight `AXIOM_BASELINE` lines, the
  C2 message string
- `typst/generated/status.typ` - regenerated

Retained and NOT modified:

- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Agreement.lean` - read-only, soundness
- `FormalSystem/Semantics/IntNormalForm.lean` - read-only, including `ofStep`, which no Stage 2
  module calls
- The whole `Formula`-side `WitnessFamily/` tree - read-only, consumed by Phase 20
- `specs/703_lplus_compression_and_completeness/probes/` - the provenance record
- `specs/706_lplus_finite_model_property_and_completeness/probes/NoFiniteCarrierModel.lean` - the
  evidence for this revision, cited and never edited
- `specs/703_lplus_compression_and_completeness/plans/01_lplus-compression-completeness.md` and
  `plans/02_lplus-certificate-limits-graph-certificate.md` - retained unedited as the history of
  the withdrawn route and the withdrawn certificate class

Task artifacts:

- `specs/703_lplus_compression_and_completeness/plans/04_lplus-sliced-certificate-and-completeness.md`
  (this file)
- `specs/703_lplus_compression_and_completeness/summaries/04_lplus-sliced-certificate-summary.md`
  at implementation time, carrying the paired-repository read of Phases 12 and 21

## Rollback/Contingency

Each phase is a self-contained new module plus one aggregator import line and a root
regeneration, so a failed phase is reverted by removing its file, removing its import line and
re-running `lake exe mk_all --lib FormalSystem` — a targeted, non-destructive edit needing no
working-tree rollback. This is the expected recovery path and the one to reach for first.

Phases 12 and 21 are the only phases editing files outside the new subtrees. Their edits are
small, individually revertible, and each is verified by re-running the gate script.

A genuine whole-tree rollback should not be needed. If one becomes necessary, follow
`context/contracts/recovery.md`'s rollback rung for the exact snapshot-then-revert invocation
shape, including its out-of-scope override flag for the deliberate whole-tree case. Note that
sibling tasks have shared this working tree with no declared `file_scope`, so a whole-tree revert
would discard their work too; prefer the per-file revert above in every case. **Never take a bare
precautionary snapshot in the default reverting mode as a start-of-phase checkpoint**; a defensive
checkpoint before risky work uses the non-reverting `--no-revert` form instead.

Phases 11, 14, 15, 16, 19 and 20 carry their own declared contingencies, stated at the phase:
decompose into decimal sub-phases, never defer behind a `sorry` and never define a vacuous
placeholder.

**If the amendment itself fails** — specifically, if Phase 16's tail-stability demand turns out to
be unrepairable rather than merely needing strengthening — the fallback is **not** a return to the
finite-graph certificate, which `Probe706.no_ofStep_sat` refutes, and **not** a return to the
withdrawn compression theorem, which `probes/NoFiniteCertificate.lean` refutes. It is the
alternative substrate recorded under "The alternative substrate, considered and not taken":
computed liveness on the landed `SharingSkeleton`'s folded class graph. That section states what
that route costs and why it was not taken first, so the decision can be re-made on evidence rather
than re-derived.

**The two contingencies this plan does not have** are a fallback to plan v1's compression theorem
and a fallback to plan v2's finite-graph certificate. Both are refuted. If Stage 2 cannot be
completed, the correct outcome is a task marked blocked with Stage 1 landed and the amendment
recorded, not a return to a statement the tree now refutes.
