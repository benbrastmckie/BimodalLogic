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
- **Plan Version**: 6 (revision of `plans/02_lplus-certificate-limits-graph-certificate.md` at
  v4, amended in place at v5 and again at v6; artifact number 03 is deliberately skipped — the
  artifact counter, not the file listing, is authoritative. **Plan v5 changes no mathematics**: it
  adds the execution preconditions recorded under "Revision record — plan v5" below and integrates
  no new report. **Plan v6 adds one mathematical obligation and corrects four stale citations**,
  and integrates no new report either — every claim it adds is a cited reading of a landed Lean
  file. Its four changes: (1) Phase 15's "GROUNDING ADDENDUM FOR 15.3", which names the L⁺-side
  transcription source, records `SharingWindow`-instantiation as a **blocked** route, and adds the
  **combined-window** obligation (d) that the seq-27 resolution block does not state; (2) Phase 16's
  "SUB-PHASE DEPENDENCY SPLIT", reconciling the seq-27 amendment's "build the fixture first" with
  this phase's `Depends on: 15`, which had scheduled it last; (3) the stale citations
  `exists_path_of_mem_live` → `exists_path_of_live` in Phases 17 and 18 and `Finset (G.Pos χ)` →
  `Finset G.Pos` in Phase 16, all against names 15.1/15.2 actually landed; (4) Phase 17's Scope
  Hypothesis amended, since "nothing is aligned here" is confirmed for two of its four clause groups
  and not for the existential side. Effort is unchanged at 67 hours because no phase is added,
  removed or rescoped: the combined window **replaces** the single-period window 15.3 was already
  going to define, and the 16.1/16.2 split redistributes Phase 16's four hours without changing them)
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

### Revision record — plan v5: the dispatch-isolation incident and the nested-checkout gate hazard

**Nothing in Stage 1 or Stage 2's mathematics changes at plan v5.** No phase is added, removed,
renumbered or rescoped; no theorem statement, field list, bound commitment, dependency or non-goal
moves; no landed phase's text is retouched. This revision is about the *execution environment* the
remaining phases run in, and it exists because one dispatch of this plan lost twenty of its
twenty-one phases to that environment rather than to the mathematics.

**No new research report is integrated at plan v5.** The `Reports Integrated` list above is
unchanged, deliberately: this revision's inputs are a dispatch post-mortem and measurements taken
in the working tree at revision time, both reproduced below together with the commands that
produced them, so that a successor can re-derive them rather than trust them.

#### What happened at dispatch 21

Dispatch 21 closed **1 of 21 phases**. The cause was not in this plan, not in the dispatch file,
and not in `scripts/dispatch-worktree.sh`:

- The dispatch **site** passed the Agent tool's harness-level `isolation: "worktree"` parameter in
  addition to the orchestrator's own already-provisioned worktree at
  `.orchestrate-worktrees/703-21`. Those are two mutually exclusive isolation mechanisms.
- The harness therefore created a **second** checkout,
  `.claude/worktrees/agent-aa19bfa3bfef394ff`, pinned the agent inside it, and its
  worktree-isolation guard refused every cross-checkout `git` invocation by design — the `cd`
  form, the `-C` form and `EnterWorktree` alike.
- **File writes and `lake` runs into the orchestrator's worktree stayed permitted.** So the agent
  could author, build and verify there, and could never commit. That asymmetry is the whole
  failure: the work was real and the record of it was unobtainable.
- Already remediated for dispatch 21: the four byte-identical verified files were committed on
  `orchestrate/task-703-21` as `9355b68fe` and landed to `main` via `f90e45cdf`. Phase 9 is on
  `main` — confirmed at revision time by `git log -1 9355b68fe`, which reads "task 703: phase 9:
  the two limit targets and their ZTime non-validity" — and that worktree was released.

The durable consequence for this plan is a **commit-availability precondition**, next. It is not a
mitigation for a hypothetical: the mechanism is understood, the remedy is one line at the dispatch
site, and the condition is silent from inside the agent until the first commit is attempted.

#### Commit-availability precondition — binding on every remaining phase (14-21)

Additive to each remaining phase's own task list. No phase body is edited.

- [ ] **Attempt a real commit at the first green sub-step, not at the end of the phase.** The
      repository's commit-per-green-substep mandate (`.claude/rules/git-workflow.md`) already
      requires this; dispatch 21 is the evidence for why it is load-bearing here rather than merely
      tidy. A phase that authors three files and then discovers commits are refused has produced
      nothing recoverable; a phase that commits its first green file has produced one.
- [ ] **If a `git` invocation is refused by the harness rather than by the repository, STOP and
      report it as a dispatch-site defect.** Do not continue accumulating uncommittable work, do
      not retry in another form — dispatch 21 tried all three — and do not read it as licence to
      batch phases. The distinguishing signal is that file writes and `lake` runs into the *same*
      directory still succeed; a repository-level refusal (a hook, a guard, a dirty-tree block)
      looks different and is to be fixed, not reported as this defect.
- [ ] Record, in the phase's closing note, the sha of every commit the phase made. A phase that
      closes with no sha is a phase whose verification cannot be reproduced.

#### The nested-checkout gate hazard — measured, and on Phase 21's critical path

Phase 21's acceptance gate requires `bash scripts/check-module-invariants.sh` to pass **in full**.
Invariant **B0** — "expected exactly 1 Boneyard directory at ./Boneyard" — cannot currently pass
from either tree, and the reason is nested checkouts inside the repository root, not anything in
this task's file scope.

Measured at plan v5:

| Counted from | `Boneyard` directories found | B0 verdict |
|---|---|---|
| main tree, `/home/benjamin/Projects/BimodalLogic` | **4** | FAIL (expects 1) |
| dispatch worktree, `.orchestrate-worktrees/703-25` | **2** | FAIL (expects 1) |

The four, from `find . -type d -name Boneyard` in the main tree:

1. `./Boneyard` — the real archive.
2. `./.claude/worktrees/agent-aa19bfa3bfef394ff/Boneyard` — dispatch 21's leftover harness
   checkout, **still registered** in `git worktree list` at plan v5.
3. `./.orchestrate-worktrees/703-25/Boneyard` — the live dispatch worktree.
4. `./.orchestrate-worktrees/703-25/.claude/worktrees/agent-aa19bfa3bfef394ff/Boneyard` — because
   a dispatch worktree carries a copy of the `.claude/` tree, item 2 is **inherited by every
   dispatch worktree provisioned while it remains**. This is the fact that moves the leftover from
   nuisance to blocker.

Why the checker does not filter these: B0's `find` excludes only `./.lake/*` and `./.git/*`
(`scripts/check-module-invariants.sh:816-822`), and the `archive_dir_count` walk that feeds the
`INV` inventory prunes only `.lake` and `.git` (same file, `:328-343`). Neither prunes `.claude` or
`.orchestrate-worktrees`. The same omission affects the script's other `os.walk(".")` traversals,
which prune `.git`, `.lake`, `specs`, `Boneyard`, `build` and `__pycache__` but not `.claude` or
`.orchestrate-worktrees` (`:1221`, `:2624`, `:3503`) — so while a dispatch worktree is live those
walks additionally see a duplicate of every live `.lean` and `.md` file in the repository. Phase
21's gate run is therefore not merely at risk on B0; it is being run against a doubled file
inventory.

**This is the same condition Phase 12 recorded as its Exclusion 1, and plan v5 does not overturn
that exclusion's judgement** — deleting a registered worktree belonging to another session is
outside an implementation agent's scope, and `/refresh` remains the sanctioned remedy. What plan v5
adds is that the count has grown from 2 to 4, that it now reproduces *inside* dispatch worktrees by
inheritance, and that it therefore sits on Phase 21's critical path rather than on its exclusion
list.

**Correction to Phase 12's Exclusion 1, on one point of fact.** That exclusion argues that removing
the leftover loses nothing because "its only commit `228168b3b` is already landed on `main` as
`9355b68fe`". The commit claim is confirmed. But the leftover's *working tree* also carries two
**uncommitted** artifact copies — `plans/04_lplus-sliced-certificate-and-completeness.md`
(178,052 bytes) and `summaries/04_lplus-sliced-certificate-and-completeness-summary.md`
(14,416 bytes) — against the main tree's 189,809 and 30,463. Both are strictly earlier drafts of
files the main tree already holds; a line-level comparison finds 42 lines present only in the stale
copy, every one of them superseded wording of a task checkbox. Removal is therefore still lossless,
but it is lossless *because those copies are superseded*, not because the worktree is empty. A
successor should re-confirm that rather than inherit the weaker claim.

#### Amendment to Phase 21's verification — additive

Phase 21's text is **not edited**. These preconditions are additive to it, in the same style as the
"Amendment to Phase 12 at plan v4" note below.

- [ ] **Run the full gate from the main tree with no nested checkout live** — that is, after the
      final dispatch worktree has landed and been released, and after the dispatch-21 leftover has
      been removed. B0 is a whole-repository `find`; it cannot be satisfied from inside a dispatch
      worktree for as long as that worktree carries a copy of another checkout.
- [ ] **The leftover is removed by the sanctioned remedy, not by an implementation agent.**
      `/refresh` is the sanctioned command; the single-command equivalent Phase 12 recorded is
      `git worktree remove --force .claude/worktrees/agent-aa19bfa3bfef394ff`. Either way it is an
      orchestrator- or user-level action. Before it runs, confirm that
      `git log --oneline main..worktree-agent-aa19bfa3bfef394ff` and the two superseded artifact
      copies named above are the whole of what is there.
- [ ] **Do not close Phase 21 by loosening B0.** Adding `.claude` or `.orchestrate-worktrees` to
      B0's exclusions would make the gate pass while emptying the self-test of its only content —
      precisely the "tautology: it would pass while proving nothing" that the script's own comment
      immediately below the check (`:822-830`) says B0 exists to avoid. If that hardening is worth
      doing it is a separate, system-level task on `scripts/check-module-invariants.sh` (open
      question 6 below), and it is **not** a licence to edit B0 from inside this task.
- [ ] If B0 still fails once the leftover is gone and no dispatch worktree is live, that is a
      genuine finding about the archive and belongs in the closing record — not in an exclusion,
      and not behind `--no-verify`.

---

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

**Integrated at plan v6 — no report, and that is a deliberate statement, not an omission.** The v6
revision round received its findings as a blocker-research relay in its own dispatch context rather
than as a new report file, and every claim v6 adds was then re-derived by reading landed Lean
sources, each cited by `file:line` at its point of use in Phase 15's grounding addendum. **`Reports
Integrated` is therefore unchanged**; do not add a phantom entry to it, and do not cite plan v6's
additions to a report. The sources actually read were
`WitnessFamily/Sharing/Fulfil.lean` (`AUFix`), `WitnessFamily/Sharing/Window.lean` (`SharingWindow`
and its time-arithmetic layer), `WitnessFamily/Sharing/Skeleton.lean` (`SharingSkeleton`'s field
list, which is what blocks the instantiation route), `PlusWitnessFamily/Fulfil.lean` and
`PlusWitnessFamily/Decide.lean` (the L⁺-side re-indexing and its doubled window), and
`PlusSlicedCertificate/Basic.lean` (`G.nb` / `G.nm` / `G.nf`, `exists_window_eq`,
`forall_slab_iff_window`, and the `target` field). One finding among them is **new to this plan at
v6 and is not in any report**: the certificate's periods and its target path's periods are unrelated
integers, so the checker needs a combined window. See Phase 15's addendum (d).

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
- **The orchestration system itself.** The dispatch-site defect recorded under "Revision record —
  plan v5" is a change to the dispatch layer, not to this library, and this plan writes none of it.
  Two constraints on whoever does: the fix is to stop passing the Agent tool's
  `isolation: "worktree"` parameter when the orchestrator has already provisioned a worktree — not
  to relax the harness's cross-checkout `git` guard, which behaved as designed — and per
  `.claude/rules/source-store-deploy-boundary.md` the edit belongs in the source store resolved
  from `.claude-extensions.json`, never hand-authored under `.claude/**`, which is a regenerated
  deploy artifact.

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
6. **Whether `scripts/check-module-invariants.sh` should be made nested-checkout-safe.** Added at
   plan v5. B0 and at least four `os.walk(".")` traversals in that script treat any checkout nested
   inside the repository root — `.claude/worktrees/*`, `.orchestrate-worktrees/*` — as part of the
   repository, so the gate's verdict depends on which dispatch worktrees happen to be live. A naive
   fix (prune those two directories) would make B0 vacuous, which the script's own comment forbids;
   a correct fix would distinguish "this checkout" from "a checkout under this directory", probably
   via `git rev-parse --show-toplevel` rather than a name list. **This plan records the question and
   allocates no phase to it**: it is a system-level change to a gate script, outside this task's
   Lean file scope, and Phase 21 works around it by running the gate from a clean main tree
   instead. If it is filed, it is filed by declaration and script name, never by an invented task
   number — the same discipline this plan already applies to the `trans_refl` follow-on.

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
| **The checker cannot fold the existential side to a window, because the target path's periods are unrelated to the certificate's.** `PlusSlicedCertificate` relates `G.target`'s `nb`/`nm`/`nf` to `G.nb`/`G.nm`/`G.nf` by no field at all, and neither `exists_window_eq` nor `forall_slab_iff_window` folds a pair of objects with different periods | H | M | Identified at plan v6 by reading the landed sources, **before** Phase 17 starts, which is the whole value of catching it here. 15.3 defines its window from **combined** periods (response (α) of Phase 15's addendum (d)), and Phase 17 carries an explicit task bullet for the clause. Fallback (β) — the three compatibility facts as `Certifies` hypotheses — narrows the certificate class and shifts an obligation onto Phase 19, so it is second choice and must be recorded if taken. The `Formula` side solved exactly this with `SharingWindow`'s `NB`/`NF`/`NM`-as-data plus `nbr_dvd_NB`/`nfr_dvd_NF`/`nmr_le_NM`, so the shape of the fix is known, not invented |
| **A dispatch spends a run trying to instantiate `SharingWindow` for a sliced certificate**, since it would inherit the whole position graph | M | M | Closed at plan v6 as a measured negative: `SharingWindow extends SharingSkeleton`, whose fields include `rep_idem`-constrained representative maps and `lift : LiftableRaw …`, none of which a sliced certificate has or will acquire — a `Decidable (LiftableRaw …)` instance is an explicit Non-Goal and avoiding the sharing substrate is why the sliced class exists. Phase 15's addendum (b) states the negative and addendum (c) names the sub-layer that **does** transcribe, with the six things it consumes. Weakening `SharingSkeleton` to permit the instantiation is prohibited: it is a landed `Formula`-side module the whole L-side decision procedure rests on |
| A concurrent sibling touches this working tree | M | M | Re-read every file immediately before editing; stage only this task's own files by explicit path, never a directory or glob `git add`; never run `git-snapshot.sh` in its reverting default mode; treat a build failure outside this task's files as possibly a sibling's in-flight edit; stop and report any foreign commit or foreign uncommitted modification after checking `git log`. **Task 706 is live in this tree**; its scope is `specs/706_*/` plus a future `PlusWitnessFamily/FiniteCarrier.lean`, neither of which this plan writes |
| A phase cannot close a goal and reaches for a `sorry` | H | L | Acceptance is zero sorries and no vacuous placeholder definitions. The correct response is plan decomposition into a new decimal sub-phase, never deferral and never a `def X := True` |
| Documentation corrections in Phase 12 overstate in the other direction, reading the refutation as a defect in the substrate redesign | M | M | It is not one. The redesign did what it was for: `Examples.lean`'s two certificates are real and `Incompleteness.lean`'s two refuted congruences are real. What Phase 12 corrects is a claim about **coverage**, and each edit must say what remains true as well as what does not |
| **A dispatch cannot commit**: the dispatch site stacks the harness's `isolation: "worktree"` on top of the orchestrator's own provisioned worktree, and the harness's cross-checkout `git` guard then refuses every commit while still permitting file writes and `lake` runs | H | M | This is the dispatch-21 failure mode, recorded in full under "Revision record — plan v5" above, where it cost 20 of 21 phases. Mitigation is a precondition, not a recovery: commit at the **first** green sub-step so a refusal surfaces while only one file is at stake, then STOP and report it as a dispatch-site defect rather than accumulating uncommittable work. Never retry in another form; dispatch 21 tried `cd`, `-C` and `EnterWorktree`, and all three are refused by the same guard |
| **Phase 21's full gate cannot pass because of nested checkouts**, not because of this task's files: B0 counts `Boneyard` directories repository-wide and finds 4 from the main tree and 2 from the dispatch worktree, since neither B0's `find` nor the script's `os.walk(".")` traversals prune `.claude` or `.orchestrate-worktrees` | H | H | Measured, not predicted — see the plan v5 record above for the counts, the four paths and the script line numbers. Phase 21's additive preconditions require the gate to be run from the main tree with no nested checkout live and with dispatch 21's leftover removed by `/refresh`. **Loosening B0 is prohibited**: it would empty the self-test, which the script's own comment names as the failure it exists to avoid. Hardening the script is open question 6, a separate system-level task |

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

**Waves 12-13 interleave at the sub-phase level — read this before dispatching Phase 16.** The
table above is stated at whole-phase granularity and is *conservative*, not wrong: every dependency
it records holds. But Phase 15 is `[PARTIAL]` with 15.1 and 15.2 landed, and the seq-27 amendment
made Phase 16's fixture a **prerequisite** of 15.3, so the two waves are not sequential in
execution. The true order is:

| Sub-wave | Work | Blocked by |
|----------|------|------------|
| 12a | 15.1, 15.2 | 14 — **both landed** |
| 12b | **16.1** — `Fixture.fourState`, its two asymmetry lemmas, `Φ_back` / `Φ_fwd` + monotonicity | 15.2 |
| 12c | 15.3 — the rolled timed carrier, the combined window, the two fixpoints, the bridge | 16.1 |
| 13 | 16.2 — `TailStable`, `tailStable_iff_window`, `exists_tailStable_repr` | 15.3 |
| 14 | 17 | 16.2 |

Nothing downstream of Phase 16 changes, and Phase 17's `Depends on: 16` still holds because 16.2
precedes it. See Phase 16's "SUB-PHASE DEPENDENCY SPLIT" for the reasoning and Phase 15's grounding
addendum for why 16.1 must come first (the fixture is what decides 15.3's window width).

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
- [x] Record in the module docstring why the carrier is sliced — **citing no probe, by path or by
      declaration name** (USER RULING, see `.decisions.json`): a certificate presenting a
      finite-carrier frame cannot certify a `⊡`-free ℤ-time non-validity that the landed L family
      already certifies. State the claim itself as the anchor. State plainly that the finite graph is the one-slice
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

### Phase 14: The presented frame on `ℤ × Fin n` [COMPLETED]

**Goal**: Define the generic `FrameOver.ofSlicedStep`, instantiate it as `G.frame`, define
`G.model`, and prove that the frame's histories are exactly the offset step paths of the slice
sequence. This is the phase that replaces plan v2's `FrameOver.ofStep` and it is where the
amendment is cashed out.

**Tasks**:
- [x] Create `FormalSystem/Semantics/SlicedFrame.lean` with a module docstring; add its import to
      `FormalSystem/Semantics.lean` and regenerate the library root.
- [x] Define `FrameOver.ofSlicedStep` on the carrier `ℤ × W` with `[Finite W] [Nonempty W]`,
      following `SharingSkeleton.frame` (`WitnessFamily/Sharing/Skeleton.lean:1404`) as the
      template: a literal `FrameOver intOrder`, a two-sided relation
      `(t, w) —d→ (t + d, u)` holding exactly when a `d`-step `R`-path runs from `w` at `t` to `u`
      at `t + d`, with the negative direction by the reflection law.
- [x] Prove the frame laws as **named lemmas**, not inline `by` blocks, so Phase 19 can cite them:
      - reflection, by symmetry of the two-sided relation;
      - *Limit*, by `TaskFrame.limit_of_succOrder` (`Semantics/TaskFrame.lean:1591`) at the
        zero-duration law;
      - *Saturation*, by `TaskFrame.saturation_of_fib_finite` (`Semantics/TaskFrame.lean:2222`),
        whose docstring names exactly this case — **infinite carrier, finite fibres**. The fibre
        over a time is `W`, which is `Finite` by hypothesis; the carrier `ℤ × W` is not.
- [x] Prove `FrameOver.ofSlicedStep_isRegular`, and `ofSlicedStep_mem_HF_iff`: a function
      `ℤ → ℤ × W` is the path of a world history exactly when it is `fun t => (t + k, f t)` for
      some offset `k` and some `f` with `R (t + k) (f t) (f (t + 1))` for all `t`. Route it through
      `FrameOver.mem_HF_iff_adjacent` (`Semantics/IntNormalForm.lean:348`). **Both directions are
      required**: Phase 18 needs `←` and Phase 19 needs `→`.
- [x] Record in that module's docstring that `FrameOver.ofStep` (`IntNormalForm.lean:456`) is
      **not** a special case to route through, because it requires `[Finite W]` on the whole
      carrier, and cite `Probe706.no_ofStep_sat` for why that matters. Do not modify
      `IntNormalForm.lean`.
- [x] Create `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Frame.lean`; define
      `G.frame h := FrameOver.ofSlicedStep (fun t w u => G.edge t w u = true) …` at `W := Fin G.n`,
      discharging `[Finite]` and `[Nonempty]` from `n_pos` and the two seriality obligations from
      `h : G.BiSerial` through `biSerial_iff_window`.
- [x] Define `G.model h : TaskModel (G.frame h).toTaskFrame`, valuing an atom at `(t, w)` by its
      membership in `G.slab t w`.
- [x] Prove `G.mem_HF_iff_slicedPath`, the specialization of `ofSlicedStep_mem_HF_iff` to `G`, and
      define `G.pathHistory : PlusGraphPath … → WorldHistory (G.frame h).toTaskFrame` for a path
      whose state sequence follows `G.edge`.
- [x] Prove the **shift-normalization lemma** *(deviation: altered — landed as TWO named lemmas, `plusTruthAt_shiftBack` and `timeShift_offset_zero`)*: by `plusTruthAt_timeShift`
      (`PlusLanguage/PlusTruth.lean:264`) every truth question on `G.frame h` can be asked at
      offset `0`, so a position is `(t, w)` with `t` the slice time and no separate origin is
      carried. This is what keeps the position space finite per slice and is cited by Phases 15
      and 17.
- [x] Confirm the new modules transitively import `FormalSystem.Init` (invariant C24).

**Verification — MEASURED**:
- Both new modules build clean: guarded, detached, `--no-share` scoped builds of
  `FormalSystem.Semantics.SlicedFrame` and
  `FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.Frame` each report
  `exit_status=0` with **zero** `error:` and **zero** `warning:` lines over both captured streams.
  `.olean` files written for both.
- `lean-sorry-census.sh`: `sorry_count: 0`.
- `#print axioms` on all fifteen new declarations checked: each within
  `[propext, Classical.choice, Quot.sound]`. Three are strictly cheaper — `iterS_add`,
  `ofSlicedStep_serial` and `ofSlicedStep_compositional` need only `[propext, Quot.sound]`, so the
  `Classical.choice` cost enters exactly at the *Saturation* discharge and nowhere else.
- **The carrier's infinitude is PROVED, not asserted**, and generically rather than on one concrete
  certificate: `FrameOver.ofSlicedStep_worldState_infinite` is an `Infinite` instance on the
  world-state type and `ofSlicedStep_not_finite_worldState` / `frame_worldState_not_finite` are the
  `¬ Finite` theorems at the generic frame and at `G.frame h` respectively. A concrete two-slice
  `example` would have been strictly weaker, so it was not written.
- `ofSlicedStep_mem_HF_iff` and `mem_HF_iff_slicedPath` are proved **biconditionals** (`constructor`
  with both branches discharged), as Phases 18 and 19 each need one direction.
- `git diff --stat FormalSystem/Semantics/IntNormalForm.lean` shows **no hunk**: the Scope
  Hypothesis's relocation branch was **not** taken.
- C24: `SlicedFrame.lean` reaches `FormalSystem.Init` through `IntNormalForm.lean`'s existing
  closure; `Frame.lean` reaches it through `PlusSlicedCertificate/Basic.lean`.

**Scope Hypothesis — CONFIRMED, both halves**:
1. *`FrameOver.ofSlicedStep` belongs in a new Semantics module.* Confirmed by checking what it
   consumes: `IsStepPath`, `FrameOver.mem_HF_iff_adjacent` and
   `FrameOver.worldHistoryOfStepPath` are all exported, and the time-indexed iterate `iterS` is
   **new** rather than a reuse of `IntNormalForm.lean`'s `iter` (the step index has to advance with
   the slice, which `iter` has no room for). No private definition of `IntNormalForm.lean` is
   needed, so the relocation branch is not taken and no landed core file is edited.
2. *The two frame-law discharges are one `TaskFrame` lemma each.* Confirmed by reading
   `limit_of_succOrder`'s and `saturation_of_fib_finite`'s hypotheses against the constructed
   relation **before** writing the proofs: the first needs only the zero-duration law, the second
   only finite fibres. Neither needed a side condition the template does not supply. The finite-fibre
   fact itself is written as its own named lemma, `ofSlicedStep_fib_finite`, per this hypothesis's
   own instruction — it is a one-line consequence of the relation's first conjunct (the target's time
   component is pinned to `p.1 + d`), which is exactly what buys an infinite carrier.

**Deviations from the plan as written**:
- **Split into 14.1 and 14.2 as the Contingency directs**, and committed separately: 14.1 is
  `FormalSystem/Semantics/SlicedFrame.lean` (the generic frame, its five named laws, and
  `ofSlicedStep_mem_HF_iff`); 14.2 is `PlusSlicedCertificate/Frame.lean` (`frame`, `model`,
  `mem_HF_iff_slicedPath`, `pathHistory`, shift-normalization).
- **`Nonempty (Fin G.n)` is supplied through a `NeZero G.n` instance, not a `haveI` in `frame`'s
  body.** A `haveI` would bake one particular instance term into `G.frame h`, and every later lemma
  about the frame would then have to reproduce that same term to unify. `instNeZeroN` makes both
  `Nonempty (Fin G.n)` and `Finite (Fin G.n)` findable by synthesis, so `G.frame h` is a bare
  `FrameOver.ofSlicedStep` application whose instance arguments reproduce at every call site.
- **The edge relation is named `G.stepRel`, not inlined as `fun t w u => G.edge t w u = true`.** The
  plan writes the lambda inline; naming it is what lets `stepRel_fwd`, `stepRel_bwd`, `frame_step`,
  `mem_HF_iff_slicedPath` and `pathHistory` all cite one relation rather than five copies of a
  lambda that would have to unify syntactically.
- **Shift-normalization is two lemmas, not one.** `plusTruthAt_shiftBack` moves the offset into the
  time argument (by `plusTruthAt_timeShift`); `timeShift_offset_zero` is the companion fact that the
  shifted history then occupies slice `t` at time `t`. One lemma cannot carry both, because the
  second is about the history's *path* and the first about *truth*.
- **`FrameOver.ofSlicedStep`'s reflection law is stated as a plain `↔` at `ℤ`
  (`ofSlicedStepRel_reflect`), while the other four are stated by citation
  (`TaskFrame.Compositional`, `TaskFrame.Serial`, `TaskFrame.Limit`, `TaskFrame.Saturation`).**
  `ofReflectiveRegular`'s `hR` argument has no named predicate to cite, so there is nothing to cite
  for that one.
- **`iterS_add`'s cast bridge is oriented to match the goal's syntactic form.** `Nat`'s `m + n`
  appears in the elaborated goal as `m.add n`, which `rw` will not match; the equation is therefore
  written with its left-hand side in the goal's own form and the residual `↑(m + n)` / `↑(m.add n)`
  gap is closed by `exact`, which works up to definitional equality.
- **`Syntax.Atom` needs qualification in this subtree.** `model_valuation` names
  `FormalSystem.Syntax.Atom` in full; the short name is not in scope through
  `PlusSlicedCertificate/Basic.lean`'s import closure.


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

### Phase 15: Positions, computed liveness, and the Q5 factorization [COMPLETED]

**Goal**: Build the position space over a slice, compute liveness on it as a fixpoint in both time
directions with **both** directions of the characterization proved, and prove the factorization
that justifies combining them. This is Stage 2's novel core and one of its two highest-risk phases.

**Tasks**:
- [x] Create `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Live.lean`. *(deviation: altered — 15.1's content landed in two files instead, `Splice.lean` and `Position.lean`; `Live.lean` itself was created in 15.2 and holds the declarative liveness layer, not a computed fixpoint. See the 15.2 resolution block.)*
- [x] Define `G.Pos χ`: *(deviation: altered — `G.Pos` carries no `χ` parameter; see the deviations block)* pairs of a slice state and a Hintikka type over the subformulas of `χ`
      that agrees with `G.slab t w` on the state formulas at the relevant slice. Prove it is a
      `Fintype` with a `DecidableEq`, and bound its cardinality by `G.n * 2 ^ |subformulas χ|`.
      **This is a cardinality of the position space, not a bound on `n`** — it is not the bound
      "Bounds: none, deliberately" forbids, and the docstring must say so.
- [x] Define `G.succP t` and `G.predP t`, the `Finset`-valued one-step successor and predecessor
      on positions **from slice `t` to slice `t + 1`** and back: an edge requires `G.edge t` on the
      state component and the (C1') one-step unfolding clauses on the type component.
- [x] Prove `succP` and `predP` are non-empty on the position space, *(deviation: altered — the claim is FALSE as stated and a counterexample is recorded; replaced by `mem_succP_of_path`/`mem_predP_of_path`, which is what the fixpoints actually need. See the deviations block.)* from `G.BiSerial` and the
      type-completion argument. Without this the fixpoints are vacuous.
- [x] Prove the **Q5 factorization**, as an explicit named lemma rather than as a rationale in a
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
- [x] Record, as a one-line lemma or a docstring note citing `PlusFormula.reflectTime`, *(deviation: altered — the reflection was NOT cheap at the declarative level, so the plan's own sanctioned fallback was taken: `BwdLive` and its whole supporting chain (`snce_push`, `plusBwdFulfilling_of_le`, `splice_bwdFulfilling`, `bwdLive_step`) were WRITTEN as the mirror of the forward chain rather than DERIVED from it by time reflection. `mem_succP_iff_mem_predP` remains the mechanical half. Whether 15.3's computed backward fixpoint can be derived by reflection instead is reopened there, where the objects are `Finset`s and a reflection is a concrete map.)* that the
      backward condition is the forward one on the reversed slice graph, so `bwdLive` is `fwdLive`
      of the time-reflected certificate. Use this to avoid writing the backward fixpoint twice if
      the reflection is cheap; if it is not, write both and record that it was written rather than
      derived.
- [x] *(deviation: deferred to 15.3 and re-carriered — the greatest-fixpoint `Finset` is ill-posed on the time-indexed carrier; 15.2 landed the declarative `FwdLive` with both characterization directions instead. See the 15.2 resolution block. FURTHER at seq 31: the re-carriered object exists (`Nu.gfp` on `TPos` over `verts`) and its two halves are landed as `fwdWalkable` (`EGFix.gfp`, the infinite-walk half) and `untlReach` (`EUFix.lfp`, the discharge half); the eventuality-aware combination of the two is STEP 6c and is still open. ALSO altered: this item's instruction to use `AUFix.lfp` for the inner reachability step is SUPERSEDED — `AUFix` is the universal operator and cannot serve an existential outer fixpoint; `EUFix`, its existential dual, is what landed. See the amended Scope Hypothesis and the STEP 5 record. FURTHER at seq 33: the computed object EXISTS as `fwdLiveT` (`LiveFix.lean`), a nested `Nu.gfp` whose inner reachability is relativized to the contracted set with the delivering vertex included, together with `exists_fwdLive_walk` — one walk discharging every eventuality. CHECKED at seq 34: the equality with `Live.lean`'s declarative `FwdLive` is landed as `Bridge.lean`'s `mem_fwdLiveT_of_fwdLive`, and the two-sided bridge as `live_iff_mem_liveT`, at a window time.)* Define `G.fwdLive t χ`, the forward-live positions at slice `t`: the greatest set `X` of
      positions such that from every position of `X` there is a `succP`-path inside `X`
      discharging each eventuality pending at it. Implement as a decreasing `Finset` iteration
      whose inner reachability step is the least fixpoint `AUFix.lfp`, imported from
      `WitnessFamily/Sharing/Fulfil.lean` — it is stated at `{α : Type*} [DecidableEq α]` and
      mentions no formula, so it is reused, not transcribed. Prove termination and the fixpoint
      property.
- [x] Define `G.bwdLive t χ` symmetrically on `predP`, and `G.live t χ := G.fwdLive t χ ∩ G.bwdLive t χ`. *(deviation: deferred to 15.3; 15.2 landed `BwdLive` and `Live := FwdLive ∧ BwdLive` declaratively, with `live_iff` as the justification for the conjunction. FURTHER at seq 31: the backward halves `bwdWalkable` and `snceReach` are landed as the mirror instantiations at `predT`, written once generically rather than twice; the intersection awaits STEP 6c. FURTHER at seq 33: `bwdLiveT` and `liveT := fwdLiveT ∩ bwdLiveT` are landed in `LiveFix.lean`, with `exists_bwdLive_walk` as the backward headline; CHECKED at seq 34 — the equality with `Live` is `Bridge.lean`'s `mem_bwdLiveT_of_bwdLive` / `mem_liveT_of_live` / `live_of_mem_liveT`.)*
- [x] *(deviation: altered — landed as `live_of_path`, not `mem_live_of_path`: `Live` is a `Prop`, so there is no `∈` to name. Stated at `∀ t`, no window restriction.)* Prove the **soundness direction**, `mem_live_of_path`: a position occupied at slice time `t`
      by a bi-infinite locally coherent, fulfilling labelled path of `G` is live.
- [x] *(deviation: altered — landed as `exists_path_of_live`, and factored through the LABEL-level splice (`splice`, `splice_fwdFulfilling`, `splice_bwdFulfilling`) rather than through `stab_factors`, which is the SEMANTIC counterpart and is what Phases 18/19 consume. Neither derives the other; both are landed and the plan now says so.)* Prove the **completeness direction**, `exists_path_of_mem_live`: every live position lies on
      such a path. Factor it through the Q5 factorization above — a position lies on a bi-infinite
      fulfilling labelled path exactly when it has a fulfilling forward half and a fulfilling
      backward half — so the two fixpoints are combined rather than solved jointly.
- [x] *(deviation: altered — `Live.lean`'s header records why liveness is a property of the certificate's own runs rather than a demanded field, naming `not_exists_plusCertifies_pumpTarget`. "Computed" is 15.3's word: 15.2's claim is the weaker and true one, that liveness adds no field and no obligation on the certificate's author.)* Record in the module docstring why liveness is computed rather than demanded, naming the
      refutation: a demanded all-threads fulfilment condition on a finite eventually periodic
      structure is refuted by `not_exists_plusCertifies_pumpTarget`, and asking only live positions
      to fulfil is exactly what removes that root cause.

**Verification — MEASURED (15.1 only; 15.2 is NOT started)**:
- Both new modules build clean: guarded, detached, `--no-share` scoped builds of
  `...PlusSlicedCertificate.Splice` and `...PlusSlicedCertificate.Position` each report
  `exit_status=0`. `Splice.lean` compiled with **zero** `error:` and **zero** `warning:` lines on
  the **first** attempt.
- Full guarded, detached `--no-share` `lake build` over the whole library: `exit_status=0`,
  zero `error:` and zero `warning:` lines.
- `lean-sorry-census.sh`: `sorry_count: 0`.
- `#print axioms` on all fourteen new declarations: each within
  `[propext, Classical.choice, Quot.sound]`; `truth_of_agree_of_type_eq` needs only `[propext]`.
- `stab_factors` **exists as a named declaration**, not as a comment — the plan's own grep check.
  So do `histories_through_paste`, `label_splices_of_type_eq` and `forall_forall_or_iff`, the three
  pieces, each named separately as the plan requires and in the plan's stated order.
- `StepClause`'s, `LabCoherent`'s and `AgreesOnState`'s `Decidable` instances all synthesize by
  `inferInstance`, confirmed by an `example`.

**Scope Hypothesis — first half CONFIRMED by reading, second half NOT YET REACHED**:
1. *`AUFix` is reusable verbatim for the inner reachability step.* Confirmed by reading its binders:
   `AUFix` is stated at `{α : Type*} [DecidableEq α]` with an arbitrary `succ : α → Finset α` and two
   `Bool`-valued predicates, mentions no formula, and exports `lfp`, `lfp_fixed`, `lfp_least`,
   `mem_lfp_iff` and `lfp_induction`. It is the **universal** `A[g U e]` operator, so — exactly as the
   hypothesis anticipated — it supplies the inner "all successors eventually deliver" half and **not**
   the existential fair-path half. The outer greatest fixpoint therefore remains new work, as asserted.
   **AMENDED at dispatch seq 31, and the amendment is stronger than this reading.** Carrying the
   reading through to STEP 5's implementation shows `AUFix` supplies **neither** half on the sliced
   side, not merely "not the outer one". The inner eventuality-discharge step of an *existential*
   outer fixpoint is `E[g U e]`, not `A[g U e]`: `A[g U e]` at a vertex says nothing about whether the
   particular walk the outer fixpoint is building ever delivers, and the all-walks reading is
   precisely the (C2') demand whose failure is why this subtree exists. So the inner operator is
   `EUFix`, the existential dual, written generically once in
   `PlusSlicedCertificate/Fixpoint.lean`. `AUFix` itself is untouched and remains in use, unchanged,
   on the `Formula` side — the amendment removes nothing from the tree. See the STEP 5 record below.
2. *`truth_paste_of_type_eq` transcribes from the probe without change of hypotheses.* **CONFIRMED by
   diffing**: `Splice.lean`'s `truth_of_agree_of_type_eq` and `label_splices_of_type_eq` carry the
   probe's statement, hypothesis list and proof unchanged. **No hypothesis was added.**

**Deviations from the plan as written**:
- **This phase is PARTIAL: 15.1 is landed, 15.2 is not started.** The Contingency's split is taken.
  15.1 = the position space, `succP`/`predP`, and the three-piece Q5 factorization with
  `stab_factors`. 15.2 = `fwdLive`, `bwdLive`, `live`, and both directions of the characterization.
  No `sorry` and no vacuous placeholder was written for the missing half: the declarations simply do
  not exist yet.
- **15.1 landed in two files, not in `Live.lean`.** `PlusSlicedCertificate/Splice.lean` holds the
  frame-generic Q5 factorization; `PlusSlicedCertificate/Position.lean` holds the position space and
  the one-step graph. Writing a `Live.lean` that contains no `live` would have been misleading;
  `Live.lean` is left for 15.2, which is what defines `live`.
- **`G.Pos` carries no `χ` parameter.** The plan writes `G.Pos χ`, "a Hintikka type over the
  subformulas of `χ`". In this subtree the relevant formula set is already determined by the
  certificate's own indices: it is `plusClosureOf (Γ ++ Del)`, which is what `slab`, `lab_sub`,
  `BoxFaithful` and `PlusLocalCoherentSeqLab` are all stated against. A separate `χ` would be a
  second, redundant formula set that every lemma would then have to relate to the first.
- **`succP`/`predP` TOTALITY IS FALSE, and this is the loud record the plan's own instructions ask
  for.** The plan's task reads "Prove `succP` and `predP` are non-empty on the position space, from
  `G.BiSerial` and the type-completion argument. Without this the fixpoints are vacuous." The claim
  does not hold. Counterexample, recorded in `Position.lean`'s module header: take a closure
  containing `untl g e` with `e` and `g` both atoms, a certificate whose slice labelling carries no
  atom at all, and the label `X = {untl g e}`. `X` is `LabCoherent` (no `⊥`; no implication in the
  closure to constrain) and it `AgreesOnState` with the empty atom set, so `(w, X) ∈ G.posAt t` for
  every `t`. But every successor label `Y` must also carry no atom, so `e ∉ Y` and `g ∉ Y`, and the
  `untl` clause then demands `untl g e ∉ X` — contradiction. `G.succP t (w, X)` is therefore empty.
  *The parenthetical worry is also mistaken*: positions without successors are not what makes a
  fixpoint vacuous — they are exactly what the **greatest** fixpoint `fwdLive` exists to discard.
  What the fixpoints genuinely need is that they are non-empty when the certificate admits a real
  labelled path, and that is `mem_succP_of_path` / `mem_predP_of_path`, both **proved** here: every
  position a genuine locally-coherent labelled path visits has that same path's next (resp.
  previous) position as a witness. Those two are the soundness direction's engine and are what 15.2
  will cite. **The obligation is replaced, not dropped.** A machine-checked `#eval` witness for the
  counterexample above is **not** landed; it is stated as an argument over the definitions in this
  tree and is flagged here rather than concealed.
- **`forall_forall_or_iff` needs no inhabited index type.** The plan says "Non-emptiness of both
  index sets is supplied by `G.BiSerial`". It is not needed: when an index type is empty the
  corresponding universal is vacuously true on both sides of the equivalence. The lemma is stated
  over bare `Sort*` with no hypothesis, which is strictly more general, and `G.BiSerial` is not
  consumed by it.
- **`stab_factors` is stated over abstract `Bwd`/`Fwd` predicates with explicit locality
  hypotheses**, rather than hard-wiring `snce`-past-fulfilment and `untl`-future-fulfilment. The two
  hypotheses are exactly what `label_splices_of_type_eq` delivers, so the factorization applies to
  any backward/forward condition expressible in the `C`-labels — including the two the fixpoints
  use, and including whatever Phase 16's transfer operators need.
- **`not_stab_factors` is added.** The plan names only `stab_factors`; the `⊡`-shaped reading (no
  realization ↔ no backward half **or** no forward half) is the form a `⊡χ`-clause is actually read
  through, and it is one `not_and_or` away, so it is landed beside it rather than re-derived at each
  use.
- **`LabCoherent` / `StepClause` split.** The plan speaks of "the (C1') one-step unfolding clauses on
  the type component". Those clauses are conditions on a *pair* of labels, so they are `StepClause`
  and live on the edge; the clauses internal to one label (`⊥`-absence, the implication clause) are
  `LabCoherent` and live on `posAt`. The `□`-clause and the fulfilment clauses are in neither: the
  first is global and the second is what liveness computes.

**Remaining for 15.2** (not started, nothing stubbed):
`G.fwdLive`, `G.bwdLive`, `G.live`, the termination/fixpoint properties, `mem_live_of_path` (the
soundness direction) and `exists_path_of_mem_live` (the completeness direction), plus the
`PlusFormula.reflectTime` note on deriving `bwdLive` from `fwdLive` on the reversed slice graph.

> **SUPERSEDED — history, not instructions (marked at dispatch seq 28).** 15.2 is landed. This
> paragraph and the FINDING that follows it are the record of what was believed *before* it was,
> and they are left unedited on purpose: the FINDING's diagnosis is what the seq-27 resolution
> block below then corrected, and deleting it would erase why the design changed. Three of the
> names above do not exist in the tree — `fwdLive` / `bwdLive` / `live` landed as the `Prop`s
> `FwdLive` / `BwdLive` / `Live`, `mem_live_of_path` landed as `live_of_path`, and
> `exists_path_of_mem_live` as `exists_path_of_live`. **Read the seq-27 resolution block and the
> seq-28 grounding addendum for what is actually owed**; take no instruction from the two
> paragraphs between here and there.

**FINDING FOR 15.2 — the Phase 15 / Phase 16 ordering may be inverted.** Recorded here so the next
dispatch confronts it before writing a definition rather than after.

The position space is **slice-indexed**: `posAt t` depends on `G.slab t`, so it genuinely differs
from slice to slice, and `succP t` runs from `posAt t` to `posAt (t + 1)`. The plan asks 15.2 for
`G.fwdLive t χ` at an **arbitrary `t : ℤ`**, as "the greatest set `X` of positions such that from
every position of `X` there is a `succP`-path inside `X` discharging each eventuality pending at
it", implemented as "a decreasing `Finset` iteration". But a greatest fixpoint of a condition whose
successor relation changes with `t` is not one `Finset` — it is a ℤ-indexed **family** of `Finset`s,
and a decreasing iteration on a ℤ-indexed family does not terminate for the reason a decreasing
iteration on one `Finset` does.

What makes it finite is that `G.slice` is eventually periodic (`slice_periodic_back`,
`slice_periodic_fwd`, `exists_window_eq`, all landed in Phase 13), so `posAt` and `succP` are
eventually periodic in `t` as well. Turning that into a finite computation is exactly what
**Phase 16's** `Φ_back` / `Φ_fwd` one-period transfer operators and `tailStable_iff_window` are for.
So either
  (i) 15.2 needs the transfer operators, in which case Phase 16's first two tasks come **before**
      15.2 and the phase boundary should move; or
  (ii) `fwdLive` is defined only on the window (a finite index set) and its extension to all `t` is
      Phase 16's business, in which case 15.2's `mem_live_of_path` and `exists_path_of_mem_live`
      must be stated for window times only and Phase 16 must carry the `∀ t` versions.
Route (ii) looks right — it mirrors `biSerial_iff_window` and `forall_slab_iff_window`, the two
window/`∀ t` bridges already landed — but it is a **design decision that changes two phases' task
lists** and must be taken deliberately and recorded, not absorbed. Phase 16's four-state fixture is
precisely the object that shows the naive periodic extension is unsound, which is further evidence
that the two phases are entangled.


**RESOLUTION OF THE 15.2 ORDERING QUESTION — dispatch seq 27, recorded not absorbed.**

The question above is **settled, and both of its candidate routes are superseded.** The decision
rests on a mid-dispatch blocker-research finding (`.blocker-research.json`, this task's directory),
which root-caused the symptom the FINDING correctly described but misattributed.

*Root cause, restated.* `Position.lean`'s carrier factors time **out**:
`Pos := Fin G.n × Lab Γ Del`, so time reappears as an index on everything derived (`posAt : ℤ → …`,
`succP : ℤ → …`). A greatest fixpoint of a slice-indexed condition therefore lives in
`(Finset Pos)^ℤ`, a lattice of **infinite height**, and the finite-lattice termination argument is
not merely unavailable but false as a *uniform* claim: each individual `t` stabilizes within
`card Pos` strict decreases, but bad news propagates leftward one slice per iteration, so strict
decreases occur at unboundedly large iteration counts and no single `K` works for every `t`.

*The fix is a transcription, not new mathematics.* The `Formula` side does the **opposite** in the
very module Phase 15 was told to import `AUFix` from: `SharingWitnessFamily.Pos` is
`Fin S.lassos.length × ℤ` — time **in** the carrier — with finiteness living on `verts`, a `Finset`
of positions formed as `Finset.univ ×ˢ winTimes`, closed under **wrapping** `nextTime` / `prevTime`
that fold by one period at the window edges. `AUFix` needs only `[DecidableEq α]` and an explicit
`V : Finset α`, and terminates by `V.card`. So termination never needed eventual periodicity at all.

*Consequence for the two recorded candidates.* **Route (i) is unnecessary** — Phase 16's transfer
operators are not what makes the computation finite. **Route (ii) has the right statement shape but
keeps the disease** — it leaves `fwdLive` a `t`-indexed object. The L-side rolled carrier is a third
route the plan did not list, and it is the right one for the *computation*.

**The split actually taken — the Prop/compute seam, and why it is neither (i) nor (ii) nor a bare
(iii).** Sub-phase 15.2 lands `Live.lean`: the **declarative** liveness predicates and **both**
characterization directions, at an arbitrary `t : ℤ` with no window restriction. The *computation*
on the rolled timed carrier moves to sub-phase 15.3 and Phase 16. The reason for cutting here rather
than at route (ii)'s window/`∀ t` seam: route (ii) would have restricted `mem_live_of_path` and
`exists_path_of_mem_live` to window times, and Phases 18 and 19 — the two phases that cite them —
need the `∀ t` form, so each would have had to re-extend a lemma the plan promised them whole. The
seam taken leaves both lemmas in the form those phases consume, and makes the rolled carrier's job
precise and checkable: 15.3 must prove its computed `Finset` **equals** this module's declarative
object at the times the checker reads, which is exactly the wrap-faithfulness obligation and is a
statement the route-(ii) split could not even have formulated.

**What 15.2 landed** (all in `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Live.lean`):
- `PlusFwdFulfilling` / `PlusBwdFulfilling`, the two halves of `PlusFulfillingSeqLab`, with
  `plusFulfillingSeqLab_iff_halves` (definitional, so no use site unfolds the conjunction).
- `untl_push` / `snce_push` — **the content**: an undischarged eventuality propagates across the
  splice time. Each consumes only the corresponding one-step unfolding clause of
  `PlusLocalCoherentSeqLab`, so each holds of an arbitrary locally coherent labelling, not only of a
  run. `plusFwdFulfilling_of_ge` / `plusBwdFulfilling_of_le` are the half-line forms.
- `PlusSlicedCertificate.LabRun`, a bi-infinite labelled run, with `pos`, `pos_eq_iff`,
  `pos_mem_posAt`, `pos_mem_succP`, `pos_mem_predP` — the last three are exactly the three lemmas
  15.1 landed in place of the false totality obligation, consumed here as intended.
- `FwdLive` / `BwdLive` / `Live`, and `mem_posAt_of_fwdLive` / `mem_posAt_of_live`.
- `fwdLive_step` / `bwdLive_step` — liveness advances along `succP` / `predP`. These are what 15.3's
  transfer operators consume. Only these directions are available from the definitions, and
  deliberately so: the converse needs the splice, not a one-step lemma.
- `spliceSt` / `spliceLab` / `splice` with `splice_pos`, `splice_fwdFulfilling`,
  `splice_bwdFulfilling` — the label-level splice. **No `paste` is needed**: two runs agreeing at
  `t` splice by a literal `if s ≤ t`, and `PlusPasting` is required only once the claim is
  transported to histories, which is Phase 18/19's business.
- `live_of_path` (soundness), `exists_path_of_live` (completeness, by splicing), and `live_iff`,
  the two directions as one biconditional. **Both directions are named declarations at `∀ t`**,
  which is the plan's own verification criterion for this phase.

**`live = fwdLive ∩ bwdLive` is now justified twice, at two levels, and neither derives the other.**
`stab_factors` (15.1, `Splice.lean`) splits the existential over `WorldHistory`; `live_iff` (15.2)
splits the same existential over label sequences. The semantic half is what Phases 18 and 19 read
the `⊡`-clause through; the syntactic half is what the liveness computation is about. Recorded here
because a reader could reasonably expect one to be a corollary of the other, and it is not.

**Deviation: `Live` is a `Prop`, not a `Finset`.** The plan asks for `G.fwdLive t χ` as a computed
`Finset` and for "termination and the fixpoint property". Neither is in 15.2, and no placeholder
stands in for them — the declarations simply do not exist yet. `Live` is not vacuous: it is the
genuine semantic object, and both directions of its characterization are proved. What it is **not**
is decidable, and Phase 17's decidability therefore depends on 15.3's computed form plus the
equality theorem, not on this module. That dependency is stated rather than discovered later.

**Non-emptiness is Phase 19's obligation, and is flagged rather than assumed.** Nothing in 15.2
exhibits a `LabRun`. If no run existed for a given certificate, every position would be non-live and
the checker's `⊡`-clause would be trivially satisfied. `live_iff`'s `→` direction is what makes that
visible rather than silent, and Phase 19 must exhibit runs from `G.BiSerial` plus type completion.
Do not treat 15.2 as having discharged it.

**Verification — MEASURED (15.2):**
- Guarded, detached, `--no-share` scoped build of
  `FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.Live`: `exit_status=0`, 1213 jobs,
  **zero** `error:` and **zero** `warning:` lines; `Live.olean` confirmed newer than `Live.lean`.
  The module compiled on the **first** attempt (the two warnings the first build emitted were
  unused `simp` arguments, removed before the recorded run).
- `#print axioms` on all twenty-six new declarations: each within
  `[propext, Classical.choice, Quot.sound]`; no other axiom appears anywhere in the output.
- No `sorry`, no `admit`, no vacuous placeholder in the module.

**Remaining for sub-phase 15.3** (not started, nothing stubbed) — the L-side transcription, in this
order, with the plan's anti-goals restated at the end:
1. **Re-carrier.** `TPos := G.Pos × ℤ`, `winTimes`, `verts`, mirroring
   `SharingWitnessFamily.Pos` / `winTimes` / `verts` name for name so the correspondence is
   auditable. `Pos`, `posAt`, `succP`, `predP` stay **untouched** and become the per-slice
   ingredients. Record in the docstring, citing `Fulfil.lean`'s own docstring, that `TPos` is
   deliberately **not** a `Fintype` and that finiteness lives on `verts`.
2. **Window width, fixture first.** `winLo := -2 * G.nb`, `winHi := G.nm + 2 * G.nf`, matching the
   `Formula` side's `cohWindowLo` / `cohWindowHi`. The landed `exists_window_eq` window is
   **single**-period `[-nb, nm + nf)`, which is *not* wide enough for a sound wrap: identical local
   graphs do not imply identical liveness, because an eventuality may only be dischargeable by
   reaching the non-periodic window and the distance to it differs between same-residue times.
   Phase 16's `Fixture.fourState` is exactly that phenomenon, so **build the fixture before fixing
   the width** and let it confirm the doubling rather than assuming it. Prove the wrap lemmas from
   the generic inequalities (`winLo ≤ -nb`, `nm + nf ≤ winHi`) rather than from the literal
   doubling, so a widening the fixture forces is a local change.
3. **Wrapping time successors.** `nextTime u := if u + 1 < winHi then u + 1 else u + 1 - G.nf`,
   `prevTime u := if winLo ≤ u - 1 then u - 1 else u - 1 + G.nb`, with the edge and membership
   lemmas. Soundness of the fold is `slice_periodic_back` / `slice_periodic_fwd`, already landed —
   citation, not proof work.
4. **The timed graph.** `succT` / `predT` off `succP` / `predP` and `nextTime` / `prevTime`, with
   their `verts` subset lemmas; `mem_succP_iff_mem_predP` supplies adjointness.
5. **The fixpoints.** `AUFix.lfp G.verts G.succT isE isG` for the inner eventuality-discharge step.
   For the **outer** greatest fixpoint — the existential fair-path half `AUFix` does not supply,
   as this phase's Scope Hypothesis correctly established — write a decreasing `Finset` iteration on
   `G.verts` whose termination is `G.verts.card`, by the same shape as `AUFix.exists_stab`. Write it
   **generically in that module**, once, rather than inlining it for `fwd` and `bwd` separately.
6. **The bridge.** Prove the computed object equals `Live` at the times the checker reads. This is
   the wrap-faithfulness obligation, and it is what Phase 16's `TailStable` certifies.

**Anti-goals for 15.3, from the blocker research and binding:** do **not** add `[Fintype TPos]` (it
is false, and the `Formula`-side docstring explains why it must stay false); do **not** weaken the
liveness characterization to a one-directional implication to dodge wrap soundness; do **not** widen
the window silently if the fixture rejects the doubling; and do **not** introduce any bound on `n`,
the periods, or lasso counts — "Bounds: none, deliberately" still governs, and `winLo` / `winHi` are
window endpoints computed from the certificate's own segment lengths, not bounds imposed on it.

**GROUNDING ADDENDUM FOR 15.3 — dispatch seq 28. Measured against the landed tree, not reasoned
from the plan.** The resolution block above is confirmed in every claim it makes about `AUFix`. This
addendum changes none of it. What it adds is (a) a nearer and cheaper transcription source than the
one named, (b) a tempting route that is **blocked**, recorded so no dispatch spends a run
discovering it, and (c) **one obligation the resolution block does not state and that 15.3 must
carry**. No new report is integrated; every claim below is a reading of a landed file, cited.

**(a) The transcription source is the L⁺ module, not the `Formula` module.** The resolution block
says to mirror `SharingWitnessFamily.Pos` / `winTimes` / `verts` "name for name". There is a nearer
model: `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Fulfil.lean` already does this
re-indexing **at `PlusFormula`**, for `PlusSharingWitnessFamily`, and its own header states the
division of labour 15.3 is about to repeat — `AUFix` "imported … and used as-is"; the position graph
"inherited, not transcribed"; and "what is genuinely re-indexed here is exactly the part that reads
a label". Read that header first. Its `cohWindowLo = -2 * S.NB` / `cohWindowHi = S.NM + 2 * S.NF`
(`PlusWitnessFamily/Decide.lean:300,303`) is the doubling the resolution block predicts, already
landed in this language.

**(b) `SharingWindow` cannot be instantiated from a sliced certificate — a measured negative.** The
inherited graph layer lives on `SharingWindow`
(`FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/Window.lean:93`), and the obvious move
is to instantiate it for `G` and inherit ~40 landed declarations. **That route is closed.**
`SharingWindow extends SharingSkeleton` (`Sharing/Skeleton.lean:653`), whose fields include
`repBack` / `repMid` / `repFwd` with `rep_idem`, `transBack` / `transMid` / `transFwd` with
`trans_refl`, and `lift : LiftableRaw n repBack repMid repFwd transBack transMid transFwd`. A
sliced certificate has none of these and is not going to acquire them: a `Decidable (LiftableRaw …)`
instance is an explicit Non-Goal of this plan, and avoiding the sharing substrate is the whole
reason the sliced class exists. Do **not** attempt the instantiation, and do **not** weaken
`SharingSkeleton` to permit it — that would edit a landed `Formula`-side module on which the whole
L-side decision procedure rests. The reuse is by transcription of a sub-layer, stated next.

**(c) The sub-layer that transcribes mechanically, and why it is mechanical.** Every declaration in
this list depends on `SharingWindow` **only** through the three integers `NB` / `NF` / `NM` and the
three facts `NB_pos` / `NF_pos` / `NM_nonneg` (`Window.lean:95-105`), plus `n` for the carrier. None
of them reads `rep*`, `trans*`, `share` or `lift` — checked by reading each proof:
`cohWindowLo`, `cohWindowHi`, `winTimes`, `mem_winTimes`, `Pos`, `verts`, `mem_verts`, `nextTime`,
`prevTime`, `nextTime_edge`, `prevTime_edge`, `nextTime_mem`, `prevTime_mem`, `FoldRel`, `FoldRelB`,
their `refl` / `symm` / `trans`, `exists_fold_fwd`, `exists_fold_back`. The sliced certificate
already supplies exactly the six things that layer consumes: `G.nb` / `G.nm` / `G.nf` with
`G.nb_pos` / `G.nf_pos` / `G.nm_nonneg` (`PlusSlicedCertificate/Basic.lean:381-393`). In the source
the proofs are `omega` after unfolding the two window endpoints by `rfl` — see `nextTime_mem`
(`Window.lean:250`) and `exists_fold_fwd` (`Window.lean:484`). Budget this layer as transcription,
and if any of it needs an argument the source did not need, **stop and record that** — it is
evidence the carriers differ in a way this addendum missed.

*Two places the transcription is strictly simpler than its source, so do not import the machinery
for them.* `SharingWindow` carries `NB` / `NF` / `NM` as **data** with side conditions
`nbr_dvd_NB` / `nfr_dvd_NF` / `nmr_le_NM`, because on the `Formula` side the combined period is a
join of the skeleton's and the lassos' segment lengths and is not a function of the skeleton. On the
sliced side `G.nb` is the `abbrev` `(G.back.length : ℤ)` — the period **is** the segment length —
and `slice_periodic_back` / `slice_periodic_fwd` are already stated at exactly that period. So the
three divisibility fields have no sliced counterpart and none is needed for the **slices**. Second,
`SharingWindow`'s `succF_nonempty` / `predF_nonempty` come from the skeleton; the sliced analogue
comes from `G.BiSerial`, which is a hypothesis the checker already carries, not a field.

**(d) THE OBLIGATION THE RESOLUTION BLOCK DOES NOT STATE: the window must be a COMBINED window,
because the target path has its own periods.** This is the one genuinely new demand in this
addendum and it is not a refinement — a 15.3 that ignores it hands Phase 17 an unprovable clause.

`PlusSlicedCertificate` (`Basic.lean:330-349`) carries `target : PlusGraphPath n (plusClosureOf (Γ
++ Del))` and **no field whatsoever relating the target path's periods to the certificate's**.
`PlusGraphPath` has its own `nb` / `nm` / `nf` (`Basic.lean:188-200`), so `G.target.nb` and `G.nb`
are unrelated integers. Consequently `exists_window_eq`'s window `[-G.nb, G.nm + G.nf)`
(`Basic.lean:437`) folds `G.slice` and nothing else, and `forall_slab_iff_window`
(`Basic.lean:543`) folds `G.slab` and nothing else. **Neither folds a pair.**

Where this bites: Phase 17's existential side demands the target path "agrees with `G.slab` on the
state formulas at **every time**" — a `∀ t` claim over a conjunction of two objects with different
periods and different offsets. No landed lemma reduces it to a window, and `Basic.lean`'s own
docstring assertion that "the slice time is the only time there is" is confirmed **only** for the
two clauses landed in Phase 13 (`BoxFaithful` and `Target`, the latter reading one time on one
path), not for this one. This is precisely the gap `SharingWindow`'s `NB` / `NF` / `NM`-as-data plus
its three divisibility conditions close on the `Formula` side, and the sliced side has no
counterpart.

Two admissible responses, and 15.3 must take one **explicitly** and record which:
  (α) Define `winLo` / `winHi` from **combined** periods — e.g. `NB := lcm G.nb G.target.nb`,
      `NF := lcm G.nf G.target.nf`, `NM := max G.nm G.target.nm`, then
      `winLo := -2 * NB`, `winHi := NM + 2 * NF` — and prove the three compatibility facts
      (`G.nb ∣ NB`, `G.nf ∣ NF`, `G.nm ≤ NM`, and the same for `target`) as lemmas. This is the
      `Formula` side's own answer and it keeps the target path inside the window discipline.
  (β) Add the three compatibility facts as hypotheses on `Certifies` (not as fields on
      `PlusSlicedCertificate`, which is landed and whose field list Phase 13 already confirmed) and
      keep the single-period definitions. Cheaper, but it narrows the certificate class, and Phase
      19 then owes a construction that meets them.
(α) is expected to be right, for the same reason it was right on the `Formula` side, and it composes
with the doubling: the doubling and the combining are independent and **both** are needed. Take (α)
unless the fixture or a concrete obstruction says otherwise, and record the choice at this heading.

**This is not a bound, and the anti-goal is unamended.** `NB` / `NF` / `NM` above are least common
multiples and a maximum of the certificate's own segment lengths — quantities computed *from* the
certificate, exactly as `winLo` / `winHi` already are. No theorem below states an inequality on `n`,
on a period, or on a lasso count, and none may. "Bounds: none, deliberately" still governs verbatim.

**One further confirmation, so the Scope Hypothesis need not wait for implementation.**
`AUFix.lfp V succ isE isG := iter V succ isE isG (V.card + 1)` is the **least** fixpoint from `∅`
(`Sharing/Fulfil.lean:159,242`), and `AUFix.step` filters `V` by "every successor either delivers
now or carries the guard and is already in `X`" (`Fulfil.lean:142`) — the **universal** `A[g U e]`
operator, over `[DecidableEq α]` with an explicit `V : Finset α` and no `Fintype`. The phase's Scope
Hypothesis is therefore confirmed in advance: `AUFix` supplies the inner eventuality-discharge step
and supplies **nothing** for the outer existential fair-path half, which is genuinely new work.
Write that outer iteration once, generically, in 15.3's module, as the resolution block already
instructs — not twice, and not inside `AUFix`.

**SUB-PHASE 15.3 STEP 2 IS LANDED — dispatch seq 29. Response (α) is taken, and this is the record
addendum (d) asks for.**

*The choice, recorded explicitly as (d) requires.* **Response (α)**, the combined periods. `(β)` was
not taken and is not held in reserve as an equal option: it narrows the certificate class and moves
an obligation onto Phase 19, and (α) turned out to need no new field and no new hypothesis — every
compatibility fact is a theorem about the certificate's own data, which is exactly why (α) is
cheaper here than the `Formula` side's field-carrying `SharingWindow`.

*What landed*, all in the new module `PlusSlicedCertificate/Window.lean`:
- `NBnat` / `NFnat` and `NB` / `NF` / `NM` — `NB := lcm G.back.length G.target.back.length`,
  `NF := lcm G.fwd.length G.target.fwd.length`, `NM := max G.nm G.target.nm`, verbatim the shapes
  addendum (d) prescribes, with `NB_pos` / `NF_pos` / `NM_nonneg`.
- **The six compatibility facts as theorems**, not fields and not hypotheses: `nb_dvd_NB`,
  `target_nb_dvd_NB`, `nf_dvd_NF`, `target_nf_dvd_NF`, `nm_le_NM`, `target_nm_le_NM`. These are the
  sliced-side counterpart of `SharingWindow`'s `nbr_dvd_NB` / `nfr_dvd_NF` / `nmr_le_NM`, and each
  is one `Nat.lcm` projection.
- `winLo := -2 * NB`, `winHi := NM + 2 * NF`, `winTimes := Finset.Ico winLo winHi` with
  `mem_winTimes`, and the **generic** inequalities `winLo_le_neg_NB` / `le_winHi` /
  `winLo_lt_winHi`.
- `emod_eq_of_dvd_of_emod_eq` — the one arithmetic fact every fold rests on: agreement modulo the
  combined period descends to each component period.
- **`exists_combined_window_eq`** — the statement `Basic.lean` cannot make: every time `t` has a
  representative `s` in `[-NB, NM + NF)` with `G.slice s = G.slice t` **and**
  `G.target.datum s = G.target.datum t`. Proved by residue in the three regions, exactly as
  `exists_window_eq` is; the only new step is choosing the representative modulo the combined period
  and pushing down to each component.
- `exists_win_eq` (the same inside the doubled window) and `exists_win_eq_slice`, which recovers
  `exists_window_eq`'s slice-only shape and thereby shows the combined window refines the landed one
  rather than replacing it with a different object.
- **`forall_iff_win`** — **the lemma Phase 17's fourth task bullet demands.** Any predicate on times
  that factors through `G.slice` and `G.target.datum` has its `∀ t` form decided on the window. It is
  stated with the factoring as a hypothesis rather than against a concrete clause, so the box clause,
  the target-agreement clause and the universal side can each cite **one named lemma** — which is
  precisely what the amended Phase 17 Scope Hypothesis says to confirm ("by a **named lemma**, not by
  a `decide` that happens to typecheck").

*The doubling and the combining are both present and are independent, as (d) says.* `winLo` carries
the factor `2` (the fixture's verdict) applied to `NB` (the combining). `Fixture.window_verdict`
states the verdict against these very definitions: `cert.NB = 1`, `cert.winLo = -2`, `p₀` is live at
`-cert.NB = -1` and dead at `cert.winLo = -2`. So the lower endpoint cannot be raised from the
doubled value to the single-period one, by a proved lemma about a named certificate.

*Not a bound.* `NB` / `NF` / `NM` are a least common multiple, a least common multiple and a maximum
**of the certificate's own segment lengths**. No declaration in `Window.lean` states an inequality on
`n`, on a period, or on a lasso count. The anti-goal is unamended and unviolated.

*Every later consumer is insulated from the factor `2`.* `exists_win_eq`, `forall_iff_win` and
`exists_win_eq_slice` are all proved from `winLo_le_neg_NB` and `le_winHi` rather than from `winLo`'s
definition, so a widening forced by a future fixture is a change to two `def`s and nothing else.

**Verification — MEASURED (15.3 STEP 2):**
- Guarded, detached, `--no-share` scoped build of `…PlusSlicedCertificate.Window`: `exit_status=0`,
  **zero** `error:` and **zero** `warning:` lines; `.olean` newer than source.
- Guarded, detached, `--no-share` full `lake build`: `exit_status=0`, **zero** `error:` and **zero**
  `warning:` lines.
- `lean-sorry-census.sh` over all four resolved source roots: `sorry_count: 0`.
- `#print axioms` on **every** public declaration of `Window.lean` (30, audited by name, zero
  unknown-constant errors): each within `[propext, Classical.choice, Quot.sound]` or a subset.
- Two Mathlib imports were added to reach `Int.ModEq` and `Finset.Ico`
  (`Mathlib.Data.Int.ModEq`, `Mathlib.Data.Int.Interval`). `Basic.lean`'s import closure supplies
  neither, and direct Mathlib imports are the established pattern in this library
  (`Metalogic/Core/MaximalConsistent.lean`).

**SUB-PHASE 15.3 STEPS 1 AND 3 ARE ALSO LANDED — dispatch seq 29**, in the new module
`PlusSlicedCertificate/Timed.lean`.

*STEP 1, the re-carrier.* `TPos := G.Pos × ℤ`; `verts`; `mem_verts` with the two projections
`snd_mem_winTimes_of_mem_verts` / `fst_mem_posAt_of_mem_verts`. The docstring records, citing
`Fulfil.lean`'s own docstring, that `TPos` is deliberately **not** a `Fintype` and that finiteness
lives on `verts`; both the `Fintype {v // v ∈ verts}` and the `DecidableEq TPos` that `AUFix` asks
for are confirmed by `example … := inferInstance`, not asserted. The anti-goal "do not add
`[Fintype TPos]`" is honoured: no such instance exists anywhere in the module.

**One deviation from the L-side transcription, deliberate.** `verts` is
`(Finset.univ ×ˢ winTimes).filter (fun v => v.1 ∈ G.posAt v.2)`, **not** `Finset.univ ×ˢ winTimes`.
On the `Formula` side the first coordinate is a lasso index and every index is legitimate at every
time, so no filter is needed; here it is a (state, label) pair and `posAt` is precisely the predicate
separating the legitimate ones. Starting a greatest-fixpoint iteration from a set containing pairs
that are not positions of their own slice would make the fixpoint's *statement* harder rather than
its proof easier. Recorded because a reader diffing against `SharingWitnessFamily.verts` will see the
difference.

*Two supporting lemmas landed here rather than in `Position.lean`.* `slab_congr` and **`posAt_congr`**
— the position space depends on the time only through the slice. They belong with Position's
development and are landed in `Timed.lean` so that no already-landed module has to be reopened; the
module docstring says so. `posAt_congr` is what turns each wrap-faithfulness lemma about `slice` into
one about `posAt`.

*STEP 3, the wrapping time successors.* `nextTime u := if u + 1 < winHi then u + 1 else u + 1 - NF`
and `prevTime u := if winLo ≤ u - 1 then u - 1 else u - 1 + NB`, transcribed from
`Fulfil.lean:343-348` with the combined periods in place of `SharingWitnessFamily`'s. Landed with
them:
- `nextTime_edge` / `prevTime_edge` — what the fold does at each edge, in the `Formula` side's own
  shape (`u + 1 = NM + 2 * NF ∧ nextTime u = NM + NF`, and the mirror).
- `nextTime_mem` / `prevTime_mem` — the graph never leaves the window.
- **The four faithfulness lemmas**: `slice_nextTime`, `slice_prevTime`, `target_datum_nextTime`,
  `target_datum_prevTime`. These are the pair `rep_nextTime` / `L_nextTime` and duals, re-indexed —
  and they are the point at which the **combined** window of STEP 2 earns its definition: a
  single-source window could not state them at all, because one of the two objects would be folded by
  a period that is not its own. Each is a residue computation via `Int.modEq_iff_dvd` against a
  divisor of the combined period, citing `nb_dvd_NB` / `nf_dvd_NF` and the two target-side facts —
  **citation, not proof work**, exactly as STEP 3 predicted.
- `posAt_nextTime` / `posAt_prevTime` — the same at the level of the position space. These are what
  will license STEP 4's graph reading `succP` at the **unwrapped** time while placing its result at
  the **wrapped** one.
- `slice_nextTime_pred` / `slice_prevTime_succ` — landed here because they are what STEP 4's
  adjointness needs, and they are facts about the fold rather than about any edge relation.

**Verification — MEASURED (15.3 STEPS 1 and 3):**
- Guarded, detached, `--no-share` scoped build of `…PlusSlicedCertificate.Timed`: `exit_status=0`,
  **zero** `error:` and **zero** `warning:` lines; `.olean` newer than source.
- Guarded, detached, `--no-share` full `lake build`: `exit_status=0`, **zero** `error:` and **zero**
  `warning:` lines.
- `sorry_count: 0`; axiom census 14, unchanged from `main`; vacuous census 1, unchanged from `main`.
- `#print axioms` on **every** public declaration of `Timed.lean` (21, audited by name, zero
  unknown-constant errors): each within `[propext, Classical.choice, Quot.sound]`.
- Across all four new modules: **150 declarations, 149 of them public and all 149 audited by name**.
  Nine depend on no axiom at all, one on `[propext]`, one on `[propext, Quot.sound]`, and 138 on
  `[propext, Classical.choice, Quot.sound]`. No `sorryAx` anywhere.

**SUB-PHASE 15.3 STEP 4 IS LANDED — dispatch seq 31**, appended to
`PlusSlicedCertificate/Timed.lean`.

*What landed.* `succT` / `predT`, each reading `succP` / `predP` at the **unwrapped** time `v.2` and
placing the result at the **wrapped** one, which is exactly what `posAt_nextTime` / `posAt_prevTime`
license. With them: `mem_succT` / `mem_predT`, the two `verts` subset lemmas, the four projections,
and two new congruences with their transports — `succP_congr` (which needs **both** slices `succP`
touches, since `succP t` reads `slice t` through `edge` and `slice (t + 1)` through `posAt`),
`predP_congr` (which needs only one, since `predP t` reads `slice (t - 1)` through both),
`predP_nextTime` and `succP_prevTime`.

*DEVIATION, and it is a correction to the plan rather than a shortcut: `succT` and `predT` are NOT
mutual inverses, and the resolution block's "`mem_succP_iff_mem_predP` supplies adjointness" is
discharged in its honest form only.* `prevTime (nextTime u) ≠ u` at the window's right edge —
`nextTime` folds back by `NF` there while `prevTime` merely decrements — so `w ∈ succT v ↔ v ∈ predT w`
is **false**, and no landed lemma claims it. What is true, and what STEP 5 actually consumes, is the
*edge-level* adjointness `mem_succT_iff_mem_predP` / `mem_predT_iff_mem_succP`: at a fixed pair of
vertices whose times are one wrap apart, the forward and backward one-step relations agree, with the
time-matching conjunct as a **hypothesis** rather than a conclusion. Confirmed against the `Formula`
side: `SharingWitnessFamily.succF` / `predF` (`Sharing/Fulfil.lean:458,463`) are built the same way
and carry **no** adjointness lemma either. The module header records the negative so no later
dispatch spends a run trying to prove it.

**Verification — MEASURED (15.3 STEP 4):** guarded, detached, `--no-share` scoped build of
`…PlusSlicedCertificate.Timed`: `exit_status=0`, 1218 jobs, **zero** `error:` and **zero** `warning:`
lines, compiled on the **first** attempt; `.olean` newer than source. `#print axioms` on all 17 new
declarations by name: each within `[propext, Classical.choice, Quot.sound]`, zero unknown-constant
errors, no `sorryAx`.

**SUB-PHASE 15.3 STEP 5 IS LANDED — dispatch seq 31**, in two new modules.

*THE DEVIATION THIS STEP TURNS ON, and the plan's own Scope Hypothesis is what asked for it.* STEP 5
as planned names `AUFix.lfp G.verts G.succT isE isG` "for the inner eventuality-discharge step", and
the Scope Hypothesis says to "confirm at implementation time by reading `AUFix`'s binders". Read, they
give a **stronger** conclusion than the hypothesis stated: `AUFix` supplies **neither** half on the
sliced side. `AUFix` is the *universal* `A[g U e]`; the outer condition here is *existential* (some
infinite walk exists), and `A[g U e]` at a vertex says nothing about whether the particular walk the
outer fixpoint is building ever delivers. Worse, the all-walks reading is precisely the (C2') demand
whose failure is the reason this subtree exists at all (`PlusSlicedCertificate.lean`'s header, on
`not_exists_plusCertifies_pumpTarget`). So the inner operator is the **existential dual**, written
generically once. `AUFix` itself is untouched and remains in use, unchanged, on the `Formula` side —
this deviation removes nothing from the tree.

*What landed, 5a — `PlusSlicedCertificate/Fixpoint.lean` (new), generic, no certificate anywhere.*
Two operators at an arbitrary vertex type with `DecidableEq` and an explicit `V : Finset α`, with no
`Fintype` on the carrier:
- **`EGFix`** — the outer half, the one the Scope Hypothesis correctly called new work with no
  counterpart in the tree. `step succ X` keeps the vertices of `X` with a successor inside `X`;
  `iter` contracts from `V`; `gfp` is the iteration at `V.card + 1`. The decreasing-chain pigeonhole
  is the mirror of `AUFix.exists_stab` (`exists_stab`, `iter_stab`, `gfp_fixed`), and `gfp_greatest`
  is the coinduction principle. **Membership is proved *equivalent* to beginning an infinite walk**,
  in both directions (`exists_walk_of_mem_gfp`, `mem_gfp_of_walk`) — so the test is complete, not
  merely sufficient, and a soundness proof cites one direction where a completeness proof cites the
  other.
- **`EUFix`** — the inner half. `AUFix` with its universal successor quantifier replaced by an
  existential one and nothing else changed: the same `step` / `iter` / `lfp` / `mem_lfp_iff` /
  `lfp_least` / `lfp_induction` shapes, the same proofs. Membership is likewise proved **equivalent**
  to the existence of a delivering finite path (`exists_path_of_mem_lfp`, `mem_lfp_of_path`), with a
  `cons` helper whose two definitional equations keep the path arithmetic free of natural subtraction.

*What landed, 5b — `PlusSlicedCertificate/Computed.lean` (new).* Each generic operator instantiated
**twice**, once at `succT` and once at `predT`, which is the "written once rather than inlined for
`fwd` and `bwd`" the resolution block demands: `fwdWalkable` / `bwdWalkable` (`EGFix.gfp`) and
`untlReach` / `snceReach` (`EUFix.lfp`), plus `atPosT`, the subset lemmas, the one-step unfoldings
`mem_untlReach_iff` / `mem_snceReach_iff`, the two induction principles in `untlFix_induction`'s own
shape, the four walk-readout lemmas, and each of the four characterizations in **both** directions.

*The anti-goals, checked explicitly.* No `[Fintype TPos]` and no `Fintype` on any carrier — both
generic operators are stated at `[DecidableEq α]` with an explicit `Finset`. No one-directional
weakening: every one of the four fixpoints carries **both** directions of its characterization. No
widening of the window: `Fixpoint.lean` and `Computed.lean` add no definition that mentions `winLo`
or `winHi`. No bound on `n`, on a period, or on a lasso count: the only cardinality any declaration
mentions is `V.card`, the termination measure of a `Finset` iteration.

**Verification — MEASURED (15.3 STEP 5):**
- Guarded, detached, `--no-share` full `lake build` after each sub-step: `exit_status=0`, **2792**
  then **2793** jobs, **zero** `error:` and **zero** `warning:` lines.
- `#print axioms` on **every** declaration of both modules by name (38 in `Fixpoint.lean`, 28 in
  `Computed.lean`): three depend on no axiom at all, the remaining 63 within
  `[propext, Classical.choice, Quot.sound]`. Zero unknown-constant errors, no `sorryAx` anywhere.

**SUB-PHASE 15.3 STEP 6 IS PART-LANDED — dispatch seq 31. Two of its four pieces are done; the
remaining two are named below and nothing is stubbed for them.**

*6a — `PlusSlicedCertificate/Fold.lean` (new). The transcription grounding addendum (c) predicted
would be mechanical, and it was: the module compiled on the **first** attempt with zero errors and
zero warnings, and no lemma needed an argument the `Formula`-side source did not need.* `FoldF` /
`FoldB`, the equivalences the two wraps generate, each carrying the **residue** condition rather
than the data agreement it implies — `foldF_succ` / `foldB_pred` are the lemmas that would be false
for the weaker relation. Landed with them: refl/symm/trans for each; the **data pair** for each
direction (`foldF_slice` with `foldF_target_datum`, and the backward pair), which is where
`Window.lean`'s combined period earns its definition a second time, since a single-source window
cannot state the pair at all; the three graph-layer liftings `foldF_edge` / `foldF_posAt` /
`foldF_succP` and their backward analogues ending in `foldB_predP`; `foldF_nextTime` /
`foldB_prevTime`, each wrap proved to be a fold; and `exists_foldF` / `exists_foldB`.

*6b — `PlusSlicedCertificate/Unroll.lean` (new). A graph walk read as a ℤ-indexed half-run.*
`fwdWalk_foldF` / `bwdWalk_foldB` are the induction the whole module rests on: at step `k` a walk
sits at a window time that is **not** `(f 0).2 ± k`, because the wrap has folded it back possibly
many times, but the two are fold-equivalent. Everything else is that lemma composed with one of
`Fold.lean`'s transports, and the payoff is that the walk's positions are positions of the
**genuine** slices and step along `succP` / `predP` at the **genuine** times: `fwdWalk_posAt`,
`fwdWalk_succP` and the backward pair, then `fwdWalkPos` / `bwdWalkPos` reading them off as functions
of the time, then the eight `LabRun`-shaped readouts (`lab_sub`, `labCoherent`, `agrees`, `edge`,
`stepClause`, each in both directions). It builds **no** `LabRun` and mentions **no** `Live`.

**Verification — MEASURED (15.3 STEP 6a and 6b):**
- Guarded, detached, `--no-share` full `lake build` after each: `exit_status=0`, **2794** then
  **2795** jobs, **zero** `error:` and **zero** `warning:` lines.
- `#print axioms` on all 24 declarations of `Fold.lean` and all 26 of `Unroll.lean`, by name: 48
  within `[propext, Classical.choice, Quot.sound]` and two within `[propext, Quot.sound]`. Zero
  unknown-constant errors, no `sorryAx`.

*6c-prep, landed as part of 6b's wave — the generic ν-iteration at an ARBITRARY contraction.*
`Fixpoint.lean` gained a `Nu` namespace: `Nu.gfp V F` for any `F : Finset α → Finset α` that is
*deflating* (`F X ⊆ X`) and *monotone*, with `iter` / `iter_anti` / `iter_stab` / `exists_stab` /
`gfp_fixed` / `gfp_greatest`, and no `DecidableEq` on the carrier at that level (nothing there
filters). `EGFix` is now the **instance** at "has a successor in the set": its own iteration block is
gone and its six public iteration lemmas with it, replaced by four one-line derivations, while every
name `Computed.lean` consumes is unchanged. `EUFix` gained `step_mono_V` / `iter_mono_V` /
`lfp_mono_V`, monotonicity in the **vertex set** (not immediate from `iter_mono_V` alone, since the
two iterations run to different bounds). Both additions exist for one reason, stated in the module
header: **the eventuality-aware liveness fixpoint is a nested one**, its inner reachability test is
taken inside the set being contracted, so it is not of the form `step succ` and could not be an
`EGFix` instance. 6c can now define its contraction and get the fixpoint and the coinduction
principle for free.

**SUB-PHASE 15.3 STEP 6c IS LANDED — dispatch seq 33.** Route (α) is taken, route (β) stays
rejected, and the round-robin concatenation this plan named as "the single largest remaining piece of
STEP 6" is landed **generically**, at `Nu` / `EUFix`'s own level, exactly as instructed.

*THE CORRECTION THIS STEP TURNS ON, and it is a correction to the resolution below, not to the plan.*
The prescribed inner test `EUFix.lfp X G.succT (G.atPosT e) (G.atPosT g)` is **not sufficient**. The
delivering vertex `EUFix` produces need not lie in `X`: `mem_lfp_iff` puts every *intermediate*
vertex in the vertex set, and says nothing about the endpoint. A walk obliged to stay inside `X`
forever therefore cannot splice that segment in — which is the **same defect as route (β)**, one
level further in. The fix is to relativize the **event** as well as the interior:
`Fair.inSet X (G.atPosT e) := G.atPosT e w && decide (w ∈ X)`. Two additive changes in
`Fixpoint.lean` make that legal, and neither weakens anything landed:
- `EUFix.exists_path_of_mem_lfp` now *also* concludes `∀ k < m, f k ∈ V` (strictly more than before);
  `Computed.lean`'s `exists_untlPath_of_mem` / `exists_sncePath_of_mem` carry the conjunct through.
- `EUFix.lfp_mono_all` generalizes `lfp_mono_V` to monotonicity in the **event and guard predicates**
  as well as the vertex set. An event predicate carrying a `w ∈ X` conjunct varies with `X`, so
  without this the outer contraction is **not monotone** and `Nu` does not apply at all.
  `step_mono_V` / `iter_mono_V` / `lfp_mono_V` survive unchanged as the special cases.

*What landed, generically, in `Fixpoint.lean`.* Two new namespaces, neither with a counterpart
anywhere in the tree:
- `Glue` — a sequence of finite paths glued into one infinite walk. `off` addresses blocks; `idx`
  addresses an index's block **by recursion, not by minimization**, which makes its characterization
  an induction; `walk` reads the two off each other; `walk_mem` / `walk_step` / `walk_eq` are the
  three readouts a fairness argument consumes. Recorded for whoever edits it: `idx` and both its
  characterizations are phrased with `off len n + len n` rather than `off len (n + 1)` **on purpose**
  — `omega` treats `off len (n + 1)` as an atom unrelated to `off len n`, so the friendly phrasing is
  load-bearing, not cosmetic, and reverting it re-introduces four arithmetic failures.
- `Fair` — the round-robin. `inSet` is the endpoint condition; `fair_of_blocks` is the
  propagation-plus-schedule argument stated at an **arbitrary** block structure (it needs only
  `n ≤ start n`); `exists_block` builds one block; `exists_fair_walk_of_blocks` and
  `exists_fair_walk` assemble them. **The schedule is a parameter**, so the modular arithmetic of a
  concrete round-robin stays at the call site where the obligation set is known.

*What landed at the certificate, in the new module
`FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/LiveFix.lean`.*
- `untlLive` / `snceLive`, the relativized inner reachability, with `untlLive_mono` / `snceLive_mono`.
- `untlLiveAt` / `snceLiveAt`, the per-formula clause, `Bool`-valued with a vacuous default at the
  wrong shape, in `Position.lean`'s own `untlClauseAt` idiom — so the whole clause is decided by a
  **bounded** quantifier over `plusClosureOf (Γ ++ Del)`, which is what the handoff asked for.
- `fwdLiveStep` / `bwdLiveStep` (deflating, monotone); `fwdLiveT` / `bwdLiveT` as `Nu.gfp` at each;
  `liveT := fwdLiveT ∩ bwdLiveT`; `fwdLiveT_fixed` / `fwdLiveT_greatest` and the backward pair, so
  Phase 18 cites one direction and Phase 19 the other.
- `fwdLiveT_subset_fwdWalkable` / `bwdLiveT_subset_bwdWalkable` — one line each, as predicted, and
  **not** a substitute for liveness in either direction.
- `untl_step_dichotomy` / `snce_step_dichotomy` — the (C1') propagation clause read along an edge.
  It needs no shape case-split, because obligations are indexed by the `(guard, event)` **pair**
  rather than by a formula shape.
- `exists_fwdLive_walk` / `exists_bwdLive_walk` — **the headline of 6c**: one infinite walk inside the
  fixpoint discharging **every** eventuality pending anywhere along it, guard included, stated in the
  shape `PlusFwdFulfilling` / `PlusBwdFulfilling` will consume so the bridge has nothing to rearrange.

*One recorded cost.* `untlTasks` / `snceTasks` / `untlSched` / `snceSched` are `noncomputable`,
because `Finset.toList` is. That costs nothing: a schedule is only ever the parameter of an existence
theorem, and every `Finset` the checker evaluates — `verts`, `succT`, `predT`, `fwdLiveT`, `bwdLiveT`,
`liveT` — stays computable.

**Verification — MEASURED (15.3 STEP 6c):**
- Guarded, detached, `--no-share` **full** `lake build`: `exit_status=0`, **2796** jobs, **zero**
  `error:` and **zero** `warning:` lines.
- `sorry_count: 0`. Vacuous census **1**, unchanged from `main` (the pre-existing
  `FormalSystem/Examples/TemporalStructures.lean:495 int_domain_universal`). Axiom census **14**,
  unchanged from `main`.
- All **116** declarations of `Fixpoint.lean` and `LiveFix.lean` audited by name with
  `#print axioms`: 60 depend on **no axiom at all**, 6 on `[propext, Quot.sound]`, 50 within
  `[propext, Classical.choice, Quot.sound]`; zero unknown constants, no `sorryAx`.
- Anti-goals checked explicitly: no `[Fintype TPos]` and no `Fintype` on any carrier; **both**
  directions of every characterization; no declaration added mentions `winLo` or `winHi`; the only
  cardinality mentioned anywhere is `V.card`, a `Finset` iteration's termination measure.

**SUB-PHASE 15.3 STEP 6d IS LANDED — dispatch seq 34, and with it sub-phase 15.3 is COMPLETE,
including Phase 15's last verification bullet.** The record below keeps dispatch 33's blocker
statement verbatim as the design record, then states what was done about it.

*THE CONDITION-SET QUESTION IS RESOLVED BY TAKING (a), AND THIS IS THE RECORD.* Resolution (a) is
implemented: `Basic.lean` gains `BoxLabelFaithful` — the (C3b) box-**label** clause — with
`BoxLabelFaithfulWindow` and `boxLabelFaithful_iff_window`, its two-directional window reduction,
proved by the same residue argument as (C3)'s `forall_slab_iff_window`. It is threaded as an
explicit hypothesis through every soundness statement in the new module and through nothing else.

The choice was the agent's own, not the user's, and per
`context/standards/user-decision-contract.md`'s "When NOT to Raise One" that is the correct
channel: the risk is fully reversible inside this repository. Overturning it costs one `def` plus
one `theorem` in `Basic.lean` and the removal of one hypothesis from four declarations in
`Bridge.lean` — no proof of anything else changes, because (C3b) is consumed at exactly one place,
`spliceWalkPos_coherent`'s box clause. Dispatch 33's `user_decision` on this question is therefore
**closed**, not carried forward, and it is recorded here rather than re-asked.

Two independent facts confirm (a) does not narrow the certificate class where it matters. First,
(C3b) is satisfied by any certificate a genuine countermodel presents, for the same reason (C3) is:
`plusBox_const` makes a boxed L⁺ formula's truth independent of history and time, so `box χ` belongs
to the L⁺ type at a carrier element exactly when `χ` is true everywhere, which is what `bx` reports.
Second, it is satisfied **vacuously** by `Fixture.cert`, whose closure carries no `□`-formula
(`Fixture.boxLabelFaithful`), so the gate below exercises the rest of the splice with the box clause
doing no work at all.

*THE FINDING THIS STEP RECORDS, and it corrects this plan rather than absorbing it: the bridge
cannot be stated at a general `t`, and the reason is structural.* This plan asks for
`G.Live t p ↔ (p, s) ∈ G.liveT` "at a folded time `s`, with `exists_foldF` / `exists_foldB`
supplying `s`". That needs ONE window time `s` carrying BOTH `G.FoldF s t` (for the forward
half-line readout) and `G.FoldB s t` (for the backward one). Read the two definitions (`Fold.lean`):
`FoldF a b` holds only when `a = b` or both `a, b ≥ G.NM`; `FoldB a b` only when `a = b` or both
`a, b < 0`. Away from the diagonal the two relations are **disjoint**, so at a general `t` outside
the window no such `s` exists and the biconditional as written is not provable — it is not a matter
of finding the right argument. At a **window time** it is provable, because both folds hold
reflexively there, and that is the form landed:
`live_iff_mem_liveT (hbox) (hs : s ∈ G.winTimes) (p) : G.Live s p ↔ (p, s) ∈ G.liveT`. This is not
a weakening for the checker: `winTimes` is exactly the finite set a checker iterates over.
`exists_foldF` / `exists_foldB` are consequently **not** what supply the bridge's time; they remain
`Unroll.lean`'s internal machinery, and this plan's instruction to use them here is superseded.

*THE SECOND FINDING: the soundness direction does not factor into halves, although the completeness
direction does.* This plan's 6d entry treats the two directions symmetrically. They are not.
Completeness splits cleanly into `mem_fwdLiveT_of_fwdLive` and `mem_bwdLiveT_of_bwdLive`, proved
independently of each other and of (C3b), each by handing `fwdLiveT_greatest` / `bwdLiveT_greatest`
the run's own visited timed positions folded into the window as a post-fixpoint — and the
discharging segment is a segment *of the run*, which is exactly why it never leaves the set and why
the relativized inner reachability accepts it. Soundness does not split: `G.FwdLive s p` demands a
**bi-infinite** `LabRun`, while membership in `G.fwdLiveT` yields a forward walk and says nothing
whatever about the past, and `succP`-totality is false (`Position.lean`), so no seriality argument
recovers a backward half. Both halves of `G.liveT` are therefore consumed together by
`live_of_mem_liveT`. **There is deliberately no `fwdLive_iff_mem_fwdLiveT`**: it would be false as
stated, and landing it would hand Phase 18 a lemma it cannot use. Recorded so no later dispatch
spends a run looking for it.

**What landed, by declaration.** `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/`
`Bridge.lean` (new, 609 lines):
- `fwdOrbit` / `bwdOrbit` with `fwdOrbit_mem` / `bwdOrbit_mem` and `foldF_fwdOrbit` /
  `foldB_bwdOrbit` — the window times a wrapped walk visits, and each one a fold of the genuine time
  it stands for. The same induction as `Unroll.lean`'s `fwdWalk_foldF`, run on the orbit instead of
  on a walk, because the completeness direction starts from a run and needs the orbit, not a walk
- `fwdVert` / `bwdVert` with `fwdVert_mem_verts` / `fwdVert_mem_succT` and the backward pair — a
  run's own positions, folded into the window, as vertices of the timed graph
- `mem_fwdLiveT_of_fwdLive` / `mem_bwdLiveT_of_bwdLive` / `mem_liveT_of_live` — the completeness
  direction
- `spliceWalkPos` with `spliceWalkPos_ge` / `_le` / `_add` / `_sub` — the **position-level** splice.
  `Live.lean`'s own `splice` takes two `LabRun`s and is `live_iff`'s justification, so it is not
  reusable here, exactly as dispatch 33 recorded; this one takes the two half-lines and is small
- `spliceWalkPos_labCoherent` / `_agrees` / `_edge` / `_stepClause` / `_coherent` and `runOfWalks`
  with `runOfWalks_lab` / `_st` / `_pos` / `_pos_start` — the five `LabRun` fields off the splice.
  Four are a case split over `Unroll.lean`'s two half-line readouts; the fifth is the box clause and
  is where (C3b) is consumed, together with `AgreesOnState` and nothing else
- `fwdFulfilling_runOfWalks` / `bwdFulfilling_runOfWalks` — `plusFwdFulfilling_of_ge` /
  `plusBwdFulfilling_of_le` applied, citation as this plan says, not proof work
- `live_of_mem_liveT`, `live_iff_mem_liveT`, and `decidableLive` — **the bridge and its payoff**.
  `decidableLive` is the declaration Phase 17 exists to consume: `Live` as `Live.lean` states it
  quantifies over runs of a structure with an infinite carrier and admits no instance

**Phase 15's last verification bullet is CLOSED — `Fixture.lean`, +62 lines.** Dispatch 33 warned
that a `decide`-based evaluation may be infeasible and asked that the route be established before a
run was spent on it. It was, and it is infeasible: `liveT` is `Nu.gfp` over `verts` iterated
`verts.card + 1` times, every iteration running an inner `EUFix.lfp` of the same height over a
vertex set of size `n * 2 ^ |Cl| * |winTimes|`. The hand route is what landed, and it uses the
bridge in **both** directions, which is what makes the gate evidence that neither direction is
vacuous: `mem_liveT_neg_one` is completeness applied to `live_neg_one`, `not_mem_liveT_neg_two` is
soundness contraposed against `not_live_of_le_neg_two`, `mem_verts_neg_two` confirms the excluded
pair is a vertex at all, and `liveT_ne_empty_and_ne_verts` is the gate itself —
`cert.liveT ≠ ∅ ∧ cert.liveT ≠ cert.verts`. One and the same position is a live vertex at `-1` and a
dead one at `-2`, on a certificate whose slice is literally the same at both times.

**Verification — MEASURED (15.3 STEP 6d and the gate):**
- Full guarded, detached, `--no-share` `lake build` over the whole library: `exit_status=0`,
  **2797** jobs, **zero** `error:` and **zero** `warning:` lines. Run twice, once per green
  sub-step. `.olean`-newer-than-source confirmed for `Bridge`, `Basic` and `Fixture`.
- `lean-sorry-census.sh` over the resolved source roots: `sorry_count: 0`.
- Vacuous census **1**, unchanged from `main` (the pre-existing `int_domain_universal`). Axiom
  census **14**, unchanged from `main`.
- All **48** new declarations audited by name with `#print axioms`: every one within
  `[propext, Classical.choice, Quot.sound]`; zero `sorryAx`, zero unknown constants.
- Anti-goals checked explicitly: no `[Fintype TPos]` and no `Fintype` on any carrier; **both**
  directions of the bridge landed as separately named theorems, so Phase 17 cites one and Phase 18
  the other; no declaration added cites a probe, by path or by name (the `.decisions.json` C9
  ruling); the only cardinality mentioned is `V.card`, a `Finset` iteration's termination measure.

**The design record dispatch 33 wrote, kept verbatim below.**

**STEP 6d WAS BLOCKED ON A CONDITION-SET QUESTION, and this was dispatch 33's second finding.**
This plan states that a spliced forward/backward walk's "five `LabRun` fields are exactly the eight
readouts 6b landed". **Four of the five, not five.** `LabRun.coherent` demands
`PlusLocalCoherentSeqLab Γ Del G.bx lab`, whose **box clause** is
`PlusFormula.box χ ∈ lab t ↔ G.bx χ = true`
(`PlusWitnessFamily/Compression/Types.lean:234`). Nothing supplies it, and the gap is not an
oversight in 6b:
- `Position.lean`'s `LabCoherent` **deliberately omits** the box clause (its own docstring says so:
  "the `□`-clause (global) … deliberately absent").
- `AgreesOnState` gives only `box χ ∈ lab t ↔ box χ ∈ G.slab t (st t)`, since `box` is a state shape.
- So what is needed is `PlusFormula.box χ ∈ G.slab t w ↔ G.bx χ = true`, and **no clause in the
  condition set says that.** (C3) `BoxFaithful` (`Basic.lean:521`) relates `G.bx χ = true` to
  `∀ t w, χ ∈ G.slab t w` — the **subformula** `χ`, not the boxed formula `box χ`. The subtree's
  complete inventory of `Prop`-valued certificate conditions is `BiSerial`, `BiSerialWindow`,
  `BoxFaithful`, `Target` (plus `AgreesOnState` and the `Fold` relations), and none of them closes it.
- `Position.lean:243 mem_posAt_of_path` runs the *other* way — it derives `posAt` membership **from**
  `PlusLocalCoherentSeqLab`, dropping the box clause on the way in — so the information is genuinely
  lost rather than merely unstated.

Two candidate resolutions, with a recommendation, **not decided unilaterally** because either changes
the condition set this task depends on:
- **(a), RECOMMENDED.** Add a (C3b) box-**label** clause to the condition set:
  `∀ χ, PlusFormula.box χ ∈ plusClosureOf (Γ ++ Del) → ∀ (t : ℤ) (w : Fin G.n),`
  `(PlusFormula.box χ ∈ G.slab t w ↔ G.bx χ = true)`, and thread it as a hypothesis through 6d's
  `LabRun` construction. It is decided on the window by `exists_window_eq` exactly as `BoxFaithful`
  is, so it costs the checker one more bounded quantifier and nothing else.
- **(b), REJECTED as written.** Fold the box clause into `LabCoherent`, so `posAt` membership carries
  it. Since `AgreesOnState` already pins `box χ ∈ lab t ↔ box χ ∈ G.slab t w`, this would *silently*
  force `box χ ∈ G.slab t w ↔ G.bx χ = true` on the certificate — a condition smuggled into the
  position space, making `posAt t` empty for a violating certificate with no stated clause saying why.
  It also perturbs `succP` / `predP` / `verts` and the landed `mem_posAt_of_path`.

Until that is settled, 6d's remaining three pieces are unchanged and still open: the position-level
splice into a `LabRun` (small, once `coherent` is available), `plusFwdFulfilling_of_ge` /
`plusBwdFulfilling_of_le` to lift the half-line discharge (landed, citation only), and the two
directions of `G.Live t p ↔ (p, s) ∈ G.liveT` at a folded time with `exists_foldF` / `exists_foldB`
supplying `s`.

**Nothing remains for sub-phase 15.3.** The entries below are retained as the design record that
dispatches 33 and 34 executed, not as open work.

- **6c, the eventuality-aware liveness fixpoint. The design question is SETTLED by this dispatch's
  reading, and the settling is the finding: the two routes are not a 50/50 choice, because one of
  them is unsound.**
  - *Route (α), the nested (Emerson–Lei) fixpoint, is the correct one.* Compute `Nu.gfp G.verts F`
    where `F X` keeps the vertices of `X` that have a successor in `X` **and**, for each `untl g e`
    pending in the vertex's own label, lie in `EUFix.lfp X G.succT (atPosT e) (atPosT g)` — the
    reachability taken **inside `X`**. `F` is deflating by construction and monotone by
    `EGFix.step_mono` together with `EUFix.lfp_mono_V`, both landed.
  - *Route (β), two separate clauses — `fwdWalkable` membership plus "every walkable position with a
    pending eventuality lies in `untlReach g e`" — is UNSOUND and must not be taken.* `untlReach` takes
    its reachability inside all of `verts`, so a discharging path it certifies may leave the set from
    which the walk can be continued forever. The round-robin construction then has nothing to
    concatenate: a segment that delivers `e` but strands the walk at a dead end does not extend to a
    fair walk. This is why the reachability must be relativized to the set being contracted, and
    therefore why the nested fixpoint is not an optional refinement. Recorded so no dispatch spends a
    run on the cheaper-looking clause pair.
  - *What (α) does NOT buy, and this is the remaining hard work:* the fixpoint being the right **set**
    does not by itself produce the single walk that discharges **every** eventuality. That still needs
    the **round-robin concatenation** — finitely many eventualities, each deliverable from every
    vertex of the fixpoint without leaving it, so splice the delivering segments in rotation and
    interleave them into one infinite walk. That argument has no counterpart in the tree: the
    `Formula` side never needed it, because there the demand is universal over threads and
    `threadFulfilling_iff_window` is proved directly. It is the single largest remaining piece of
    STEP 6 and it should be written **generically**, at `Nu` / `EUFix`'s own level, not at the
    certificate.
- **6d, the splice and the equality.** With 6c in hand: a forward walk and a backward walk agreeing at
  one vertex splice at **position** level into a `LabRun` (`st t := if t₀ ≤ t then (fwdWalkPos …).1
  else (bwdWalkPos …).1`, and likewise the labelling), whose five fields are exactly the eight
  readouts 6b landed; `plusFwdFulfilling_of_ge` / `plusBwdFulfilling_of_le` (both landed in
  `Live.lean`) turn the half-line discharge into full fulfilment; and the equality
  `G.Live t p ↔ (p, s) ∈ …` at a folded time `s` follows, with `exists_foldF` / `exists_foldB`
  supplying `s`. **Note for whoever writes it:** `Live.lean`'s own `splice` takes two **`LabRun`s**,
  not two half-lines, so it is `live_iff`'s justification and is **not** directly reusable here. The
  position-level splice is new, and small.
- Phase 15's last verification bullet (`G.live` evaluated on a concrete certificate and confirmed
  neither empty nor the whole position space) **is CLOSED at seq 34** by
  `Fixture.liveT_ne_empty_and_ne_verts`, and not by evaluation — see the STEP 6d record above for
  why evaluation is infeasible here and what replaced it.

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
  whole position space, so the fixpoint is not vacuous in either direction. **Scoped to 15.3 at
  dispatch seq 28**: `Live` as 15.2 landed it is a `Prop` with no `Decidable` instance, so there is
  nothing to evaluate yet and this criterion cannot be met by 15.2 — it is not a defect of 15.2 and
  must not be recorded as one. It becomes checkable once 15.3's computed `Finset` and its equality
  bridge exist, and it is 15.3's gate. The non-vacuity it probes is the same fact Phase 19 owes as a
  theorem; passing it here is evidence, not the discharge.

---

### Phase 16: Tail-stability, with the four-state fixture [IN PROGRESS]

**Goal**: Define the one-period transfer operators on live-position sets, define `TailStable`,
prove the re-presentation lemma that makes the demand harmless, and **build the four-state
counterexample as a named test fixture** confirming the demand is actually needed. This is the
amendment's only visible failure mode (report 706, risk R2), so it gets its own phase and is
scheduled **before** the checker.

**AMENDMENT TO PHASE 16 — dispatch seq 27. The job of every declaration in this phase changed, and
the change is a reframing, not a relaxation.**

`Φ_back`, `Φ_fwd`, `TailStable`, `tailStable_iff_window` and `exists_tailStable_repr` all stay, with
their statements intact. What changed is **what they are for**. As written, this phase's heading
reads as though eventual periodicity is what makes the liveness computation finite. It is not:
termination comes from `AUFix`'s explicit `V : Finset α` and its `V.card` bound, on the rolled timed
carrier sub-phase 15.3 introduces (see the 15.2 resolution block under Phase 15). Eventual
periodicity is what makes the **wrap sound** — that the liveness read at a wrapped window time
really is the liveness at every time that window time represents. That is a different obligation, it
is the harder one, and this phase is where it is discharged.

Three consequences, each of which changes what a reader should check:

1. **`TailStable` is a wrap-faithfulness demand, not a finiteness device.** Under the rolled carrier
   it says the orbit of the window's edge value under one period is already fixed, and
   `tailStable_iff_window` is the bridge from the window-local fixpoint to the `∀ t` claim. Read
   both that way; a proof that only established finiteness would not establish anything this phase
   needs.

2. **The four-state fixture is now a PREREQUISITE of 15.3, not a consequence of this phase.** The
   landed `exists_window_eq` window is single-period `[-nb, nm + nf)`; the `Formula` side's is
   **doubled** on both sides. Identical local graphs do not imply identical liveness, because an
   eventuality may only be dischargeable by reaching the non-periodic window and the distance to it
   differs between same-residue times — which is exactly what the fixture's `⊡(XX ¬q)` asymmetry
   between `(-1, a)` and `(-2, a)` at back period 1 exhibits. So **build the fixture first**, before
   15.3 fixes its window width, and let it confirm the doubling. The fixture's task bullet already
   says "build the fixture first"; this amendment says *how early* "first" is.

3. **The plan's original route (i)/route (ii) dichotomy was superseded, not resolved in favour of
   either.** Do not read this phase as having been chosen over 15.2, or vice versa. The ordering
   question was dissolved by a carrier change, and the record of that is under Phase 15.

**One thing this amendment does NOT license.** If the fixture shows the doubled window is still too
narrow, the response is to widen it and record the widening loudly at this heading — never to weaken
`tailStable_iff_window` to one implication, never to relax the fixture, and never to reach for a
`sorry`. That is the phase's existing Scope Hypothesis, restated because the reframing makes it
easier to lose.

**Tasks**:
- [x] Create `FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Stable.lean`. *(deviation: altered — landed as TWO files: the fixture went to its own new `PlusSlicedCertificate/Fixture.lean`, and `Stable.lean` holds the Φ operators only. See the 16.1 record below.)*
- [x] **Build the fixture first**, before the definitions, as `Fixture.fourState`: a certificate *(deviation: altered — the four-state design is NOT realizable in this carrier and was redesigned; the landed object is `Fixture.cert`, and the `#eval`/`#guard` half is dropped as impossible. Three independent reasons and the replacement obligation are in the 16.1 record below and in `Fixture.lean`'s header.)*
      with back-tail slice `{a, b}` and edges `a → a`, `a → b`, `b → b`, with an atom `q` true at
      `b` only; `mid = [c]` with `a → c`, `b → c`; forward tail `{d}` with `c → d`, `d → d`.
      Evaluate the stability label of `⊡(XX ¬q)` at `(-1, a)` and at `(-2, a)` with `#eval` or
      `#guard`, and prove as named lemmas that it is **true** at `(-1, a)` and **false** at
      `(-2, a)`. This is the fact that forces the design: the checker must not read tail
      stability-labels at one residue only.
- [x] Define `Φ_back`, the one-period transfer of live-position sets leftward through the back
      tail, carrying pending eventualities on the type component; and `Φ_fwd`, its mirror. Prove
      each is monotone on `Finset G.Pos` — **not** `Finset (G.Pos χ)` as this bullet read before
      dispatch seq 28: 15.1 landed `G.Pos` with no `χ` parameter, because the relevant formula set is
      already fixed as `plusClosureOf (Γ ++ Del)`. See Phase 15's deviations block.
- [x] Define `L₀`, the live-position set computed from the window together with the forward tail,
      and its mirror `R₀`. *(deviation: altered — landed as `liveAt` at two reference times, and the Φ operators were RE-INDEXED to the combined periods to make those reference times the window's own endpoints. See the 16.2 record below.)*
- [x] Define `PlusSlicedCertificate.TailStable` as `Φ_back L₀ = L₀ ∧ Φ_fwd R₀ = R₀`, and prove it
      `Decidable`. Prove `tailStable_iff_window`: under tail-stability, the true forward-live sets
      at every `t = -k · |back|` coincide with `L₀`, so every stability clause is decidable on the
      window. **This is the lemma the whole design rests on**; state it as a biconditional or as
      two named implications, never as a one-line `by simp`. *(deviation: altered — landed as a biconditional AND as two separately named implications, and about two-directional `Live` rather than `FwdLive`; the period is the combined `G.NB` / `G.NF`, not `|back|` / `|fwd|`. See the 16.2 record below.)*
- [ ] Prove the **re-presentation lemma**, `exists_tailStable_repr`: for any `G`, there is a `G'`
      with the pre-period absorbed into `mid` and the period multiplied by the cycle length such
      that `G'.TailStable`, and `G'.frame` is isomorphic to `G.frame` — hence truth is unchanged.
      The sequence `Φ_back^k L₀` is eventually periodic because subsets of a finite position space
      are finite, which is what makes the pre-period and period exist. **State no order for
      either**; see "Bounds: none, deliberately". *(deviation: deferred to sub-phase 16.2c — see the 16.2 record below.)*
- [ ] Prove `Fixture.fourState` is **not** tail-stable as presented, and exhibit its
      re-presentation, so the fixture doubles as the worked example of
      `exists_tailStable_repr`. *(deviation: deferred to sub-phase 16.2c, with `exists_tailStable_repr` it is the worked example of.)*
- [x] Record in the module docstring: what tail-stability is, why it is required (the fixture),
      that it costs the checker exactly one `Φ` application beyond the Phase 15 fixpoints, and
      that a search on the paired repository's side must re-present an unstable countermodel
      rather than reject it. *(all four recorded on `TailStable`'s own docstring and in `Stable.lean`'s header; the fourth is flagged there as argued-but-not-yet-proved until `exists_tailStable_repr` lands.)*

**SUB-PHASE DEPENDENCY SPLIT — dispatch seq 28. The `Depends on` line below is correct for the
phase as a whole and wrong for the fixture, and the seq-27 amendment left that unreconciled.**
The amendment above makes `Fixture.fourState` a **prerequisite of 15.3** while this phase still
declares `Depends on: 15`, which would schedule the fixture after all of Phase 15 — the opposite
order. Take the Contingency's split as the standing plan, not as a fallback, with these
dependencies:
- **16.1** — `Fixture.fourState`, its two asymmetry lemmas, and `Φ_back` / `Φ_fwd` with their
  monotonicity. **Depends on: 14, and on 15.2 only** (it needs the slice labelling and the position
  space, both landed; it needs nothing from 15.3). **Runs before 15.3**, because its two asymmetry
  lemmas are what decide 15.3's window width.
- **16.2** — `TailStable`, `tailStable_iff_window`, `exists_tailStable_repr`. **Depends on 15.3**,
  since tail-stability is what certifies 15.3's wrap.
So the executed order is 15.2 (landed) → **16.1** → 15.3 → 16.2 → 17, and Phase 17's `Depends on: 16`
still holds because 16.2 precedes it. The phase-level line below is left at `15` deliberately: it is
the conservative value for wave analysis and is not a licence to run 16.1 late.

**SUB-PHASE 16.1 IS LANDED — dispatch seq 29. What it landed, what it decided, and the two
deviations, recorded not absorbed.**

*Files.* Two new modules, not one. `PlusSlicedCertificate/Fixture.lean` holds the fixture;
`PlusSlicedCertificate/Stable.lean` holds the Φ operators. `Stable.lean` was created without
`TailStable` in it because `L₀` / `R₀` have nothing to be yet — they are the *computed* liveness sets
and 15.3 has not built the computed object. Writing a `Stable.lean` whose headline declaration was
absent would have repeated 15.1's `Live.lean` mistake; both module headers say where the missing half
went. Two commits, one per green sub-step: the fixture, then the operators.

*DEVIATION 1 — the fixture is not `Fixture.fourState`, and the four-state design is not realizable.*
The landed object is `Fixture.cert`, a **two**-state, three-slice certificate with back period `1`.
The plan's design was attempted first and fails for three independent reasons, each recorded in
`Fixture.lean`'s header:
1. **Slice width is uniform and `edge` is per slice.** The plan's `a → c` / `b → c` edges are the step
   *out of* a negative time, so they must live in the back slice's single `edge` — and therefore hold
   at `-2`, `-3`, … as well. The intended asymmetry does not survive, which is exactly the caution
   dispatch seq 27 recorded in its handoff.
2. **"`q` true at `b` only" destroys the asymmetry the fixture exists for.** A run at `a` at `-2`
   could step to `b` at `-1` and discharge there, making the position live at `-2` too.
3. **`XX` is not in L⁺ and `⊡`-truth is not `Decidable`.** `PlusFormula` has no `next`, and the
   `⊡`-clause is a universal over histories of an infinite carrier, so the `#eval` / `#guard` half of
   the task bullet is impossible, not merely inconvenient. The plan's own stronger requirement
   — **named lemmas** — is what is satisfied.
The *obligation* is unchanged and discharged: a proved instance of "identical slices, different
liveness". The theorem was not weakened and the fixture was not relaxed; it was rebuilt on a
temporal rather than a branching mechanism. Two states are kept rather than one so that the failure
at `-2` is visibly **not** a lack of successors: the edge relation is total at every slice
(`Fixture.edge_eq_true`, `Fixture.biSerial`).

*THE WINDOW VERDICT — this is what 15.3 STEP 2 must obey.* All four facts are proved named lemmas of
`Fixture`:
- `slice_of_neg` / `posAt_eq_of_neg`: every negative time carries **literally the same** slice and the
  **same** position set (back period `1`).
- `succP_ne_empty_neg_one` and `succP_eq_empty_of_le_neg_two`: `succP (-1) p₀` is non-empty and
  `succP t p₀` is **empty** for every `t ≤ -2`. So `succP t` is not a function of `slice t`: it reads
  `posAt (t + 1)` too, and at `t = -1` that is the mid slice.
- `live_neg_one` and `not_live_of_le_neg_two`, strengthened to `not_exists_labRun_of_le_neg_two`:
  `p₀` is live at `-1` and is occupied by **no run at all** at any `t ≤ -2`.
- `live_not_determined_by_slice` and `neg_two_outside_single_period_window` bundle the verdict.

Read off it, and binding on 15.3:
(i) **`winLo = -NB` is UNSOUND.** With `nb = 1` the single-period lower endpoint is `-1`, and
    `prevTime`'s fold at the left edge makes `-1` its own predecessor, asserting liveness at `-1` on
    behalf of `-2`. That is false here, by proved lemmas rather than by expectation.
(ii) **`winLo = -2 * NB` is exactly sufficient *for this fixture*, not merely wider.**
     `not_exists_labRun_of_le_neg_two` holds **uniformly for every `t ≤ -2`**, so `-2` is a faithful
     representative of the whole left tail. The doubling is therefore *confirmed*, which is what the
     seq-27 amendment asked this fixture to do.
(iii) **HONEST LIMIT.** The fixture confirms the factor at `nb = 1`; it does **not** prove the
      doubling sufficient in general. The general wrap-soundness lemma remains 15.3 STEP 3's
      obligation, and per STEP 2 must be proved from the generic inequalities `winLo ≤ -NB` and
      `NM + NF ≤ winHi` together with `slice_periodic_back` / `slice_periodic_fwd`, never from the
      literal doubling.
(iv) **The verdict composes with addendum (d)'s combined window and does not weaken it.** The two
     constraints are orthogonal: (d) says the window must absorb the *target path's* independent
     period triple; the fixture says the *back factor* must be at least `2`. Both hold of
     `winLo := -2 * NB` with `NB := lcm G.nb G.target.nb`. The fixture's own `target` has
     `target.nb = 1`, so `lcm 1 1 = 1` and the verdict reads on the combined window unchanged — which
     is why the fixture does not adjudicate between (α) and (β) and must not be cited as if it did.

*What the Φ half landed.* `stepBack` / `stepFwd` (the one-step transfers, `Finset`-valued and
decidable, with `mem_stepBack` / `mem_stepFwd`), `iterBack` / `iterFwd` (the `k`-fold iterates from a
reference time, with `iterBack_subset_posAt` / `iterFwd_subset_posAt` pinning which slice each
iterate lands on), and `Φ_back` / `Φ_fwd` as one full period. Monotonicity is proved at all three
levels (`stepBack_mono`, `iterBack_mono`, `Φ_back_mono`, plus `monotone_Φ_back` / `monotone_Φ_fwd` in
the lattice form) — which is the plan's stated 16.1 deliverable, on `Finset G.Pos` as seq 28
corrected. `Φ_back_subset_posAt` / `Φ_fwd_subset_posAt` prove the operators run from the
single-period endpoints to the **doubled** ones, so the arithmetic of the verdict above is a lemma
rather than a comment.

*DEVIATION 2 — a soundness pair was added that the plan does not name.*
`fwdLive_subset_stepBack` / `bwdLive_subset_stepFwd`: if `X` over-approximates the forward-live set at
`t`, then one leftward step over-approximates it at `t - 1`. They consume 15.2's `fwdLive_step` /
`bwdLive_step` exactly as that phase predicted, and they are added because they settle the direction
Φ is usable in: **Φ over-approximates, and the converse is false** — a position with a successor in
`X` need not be live, since liveness demands a whole fulfilling run and not one edge. That asymmetry
is *why* 16.2's `TailStable` has to be the equation `Φ_back L₀ = L₀` and not an inclusion, and it is
better recorded as a lemma here than rediscovered in 16.2.

**Verification — MEASURED (16.1):**
- Guarded, detached, `--no-share` scoped builds of `…PlusSlicedCertificate.Fixture` and
  `…PlusSlicedCertificate.Stable`: each `exit_status=0`, **zero** `error:` and **zero** `warning:`
  lines; each `.olean` confirmed newer than its source.
- Two full guarded, detached, `--no-share` `lake build` runs over the whole library (one per
  commit): `exit_status=0`, 2788 and 2789 jobs, **zero** `error:` and **zero** `warning:` lines in
  each.
- `lean-sorry-census.sh` over all four resolved source roots: `sorry_count: 0`.
- `#print axioms` on **every** public declaration of both new modules — 70 in `Fixture` and 28 in
  `Stable`, audited by name with zero unknown-constant errors. Each is within
  `[propext, Classical.choice, Quot.sound]` or a subset of it; no `sorryAx` and no other axiom
  appears anywhere in the output. One `private` helper (`Fixture.cyc_singleton`) is not nameable
  from outside and is covered transitively by every lemma that uses it.
- No `sorry`, no `admit`, no vacuous placeholder in either module.

**Remaining for 16.2** (not started, nothing stubbed): `L₀` / `R₀`, `TailStable` with its `Decidable`
instance, `tailStable_iff_window`, `exists_tailStable_repr`, and the fixture's own re-presentation as
the worked example. All four need 15.3's computed liveness `Finset` first. The task bullet asking for
`Fixture.fourState` to be shown not tail-stable now reads on `Fixture.cert`.

**SUB-PHASES 16.2a AND 16.2b ARE LANDED — dispatch seq 36. One deviation of substance, the linchpin
proved in both directions, and one sub-phase left.**

*What landed, in three green sub-steps.* All in `PlusSlicedCertificate/Stable.lean`, which grew from
287 to roughly 1,300 lines; no new module and no new import.
- **16.2a** — the Φ re-indexing, the congruence/composition/period-shift machinery, `liveAt` with
  `L₀` / `R₀`, `TailStable` with `decidableTailStable`, the `Live`-level transfer soundness, and the
  forward half of the linchpin (`mem_L₀_of_live_tail`, `live_ref_of_live_tail`, and mirrors).
- **16.2b** — `runOfPos`, `exists_chain_of_mem_iterBack`, and the three-region run, giving
  `live_of_mem_L₀_tail`.
- **16.2b (right tail)** — `exists_chain_of_mem_iterFwd`, `headPos`, `live_of_mem_R₀_head`, and then
  `tailStable_iff_window` / `tailStable_iff_window_fwd` as biconditionals, with
  `liveAt_tail_eq_L₀` / `liveAt_winLo_eq_L₀` as the `Finset` equalities Phase 17 reads.

*DEVIATION OF SUBSTANCE — `Φ_back` / `Φ_fwd` are re-indexed to the COMBINED periods.* 16.1 landed
them at the single-object reference times `-G.nb` → `-2 * G.nb` and `G.nm + G.nf` → `G.nm + 2 * G.nf`.
They now run `-G.NB` → `G.winLo` and `G.NM + G.NF` → `G.winHi`. The handoff at the end of dispatch 34
flagged this indexing mismatch and required it be settled explicitly rather than left to coexist; it
is settled in favour of re-indexing, for a reason that is forced and not stylistic:

1. **The fold `TailStable` exists to certify moves by `G.NB`, not by `G.nb`.** `Timed.lean`'s
   `prevTime_edge` sends the unwrapped predecessor `-2 * G.NB - 1` to the window time `-G.NB - 1`,
   and `nextTime_edge` shifts by `G.NF`. An operator fixed for one `G.nb`-period constrains nothing
   about a fold that moves by `G.NB`.
2. **`L₀` has to be readable off `G.liveT`, which is supported only on `G.winTimes`.** The re-indexed
   reference times are window times by `neg_NB_mem_winTimes` / `NM_add_NF_mem_winTimes`, so
   `mem_liveAt_iff_live` makes `L₀` / `R₀` *exactly* the declarative live sets there rather than
   merely over-approximating them.
3. **`Stable.lean`'s own 16.1 header already claimed the reference times "match the doubled window
   endpoints"** — which `-G.nb` / `-2 * G.nb` are not, since `G.winLo = -2 * G.NB`. The landed
   indexing contradicted its own stated purpose; this is a repair, not a redesign.
Nothing outside `Stable.lean` consumed `Φ_back` / `Φ_fwd`, so the re-index touched no other module.
Every 16.1 lemma survives with its statement re-indexed; the generic `stepBack` / `iterBack`,
monotonicity at all three levels, and `fwdLive_subset_stepBack` / `bwdLive_subset_stepFwd` are
unchanged.

*THREE FURTHER CORRECTIONS TO THIS PHASE'S TASK BULLETS, recorded not absorbed.*
1. **`tailStable_iff_window` is about two-directional `Live`, not `FwdLive`.** The bullet says "the
   true forward-live sets". It cannot: `fwdLiveT` membership does **not** imply `FwdLive` (no
   bi-infinite run), so a biconditional stated on the forward half alone is false in the `←`
   direction. `G.liveT` is exact for `Live` in both directions (`Bridge.live_iff_mem_liveT`), so
   `L₀` is a set of two-directionally live positions and the transfer's soundness had to be re-proved
   at that strength — `live_subset_stepBack` / `live_subset_stepFwd`, whose witness is `live_iff`'s
   single fully fulfilling run. This is a strengthening of what was asked, not a weakening.
2. **The `←` direction needs a genuine three-region run, and no shift of a `LabRun` is a `LabRun`.**
   `LabRun.agrees` and `LabRun.steps` are conditions at *every* time while the slice sequence is
   periodic only away from `mid`, so the obvious "shift the run" argument fails outright. The landed
   route is `runOfPos` (a `LabRun` from any family of positions at their own slices stepping along
   `succP` — `Bridge`'s two-region walk splice is a special case) applied to: the reference run of
   `p` shifted by the whole distance on the closed left half-line, the `Φ_back`-chain in the middle,
   and the reference run of the chain's **endpoint** — a different member of `L₀` — on the closed
   right half-line. Fulfilment is not spliced: `plusBwdFulfilling_of_le` reads the backward half off
   region one and `plusFwdFulfilling_of_ge` the forward half off region three.
3. **The right tail is a separate construction, not a symmetry argument.**
   `PlusSlicedCertificate` is not symmetric under time reversal (`mid` sits at `[0, G.nm)`,
   `slice_fwd` reads at or past `G.nm` and `slice_neg` strictly below `0`) and `runOfPos` asks for
   `succP` steps in the one direction the carrier fixes, so the right-tail chain runs along `predP`
   and is converted by `mem_succP_iff_mem_predP`. That adjointness lemma earns its keep here.

*THE SCOPE HYPOTHESIS IS CONFIRMED, and the confirmation is not the trivial one.* The hypothesis
asserts that one application suffices, noting that `Φ_back^k L₀ = L₀` is "immediate from the
equation" but is "not by itself the claim that the true forward-live sets equal `L₀`". Both halves are
now discharged separately: `iterBack_L₀` is the first (and is *not* immediate — the reference time
moves one period left with each application, so the iterate has to be transported by
`iterBack_shift`, which needs `slice` periodicity at a multiple of the combined period), and
`tailStable_iff_window` is the second. **No strengthening of the demand was needed**, so the
Contingency's "strengthen the demand" branch was not taken and the fixture was not relaxed.

**Remaining as sub-phase 16.2c** (not started, nothing stubbed, no `sorry` and no placeholder
anywhere): `exists_tailStable_repr`, and `Fixture.cert` shown not tail-stable together with its
re-presentation as that lemma's worked example. `Frame.lean` is where the frame isomorphism has to
land. Note for whoever takes it: dispatch 34 already landed the computed-side facts the fixture's
instability argument needs (`mem_liveT_neg_one`, `mem_verts_neg_two`, `not_mem_liveT_neg_two`,
`liveT_ne_empty_and_ne_verts`), and `Fixture.cert` has `G.NB = 1`, so its `L₀` sits at `-1` and
`G.Φ_back L₀` at `-2` — which is exactly where `not_mem_liveT_neg_two` bites. Until 16.2c lands,
`TailStable`'s docstring flags the harmlessness of the demand as argued but not proved.

**Verification — MEASURED (16.2a + 16.2b):**
- Four full guarded, detached, `--no-share` `lake build` runs over the whole library (one per green
  sub-step plus the final docstring pass): each `exit_status=0`, **2797** jobs, **zero** `error:` and
  **zero** `warning:` lines.
- `lean-sorry-census.sh` over all four resolved source roots: `sorry_count: 0`.
- `#print axioms` on **every** public declaration of `Stable.lean`, audited by name: each within
  `[propext, Classical.choice, Quot.sound]`; zero unknown constants, no `sorryAx`.
- `decidableTailStable` confirmed by `example (G) : Decidable G.TailStable := inferInstance`
  synthesizing, as this phase's Verification block requires.
- `exists_tailStable_repr` is absent rather than weakened, and no landed statement mentions a bound
  on a period — confirmed by reading, since the lemma that would state one does not exist yet.
- Vacuous census **1** and axiom census **14**, both unchanged from `main`.

**Timing**: 4 hours (16.1 ≈ 2, 16.2 ≈ 2)

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
      `(t, w)` omits `χ`", by Phase 15's `exists_path_of_live`. *(name corrected at dispatch seq 28:
      15.2 landed `exists_path_of_live`, not `exists_path_of_mem_live`; `Live` is a `Prop`, so there
      is no `∈`. **And note which object this clause must read**: `exists_path_of_live` is
      declarative and undecidable, so `Certifies` must be written against 15.3's **computed** form
      plus 15.3's equality bridge, citing `live_iff` only for the mathematics. Writing the clause
      against `Live` directly will fail `decidableCertifies` and is the failure mode to avoid.)*
- [ ] **Fold the target path, not only the slices.** The existential side's "agrees with `G.slab`
      on the state formulas at every time" is a `∀ t` claim over two objects with **different**
      periods: `G.slice` at `G.nb` / `G.nf` / `G.nm`, and `G.target` at its own `target.nb` /
      `target.nf` / `target.nm`, which no field of `PlusSlicedCertificate` relates. Neither
      `exists_window_eq` nor `forall_slab_iff_window` folds a pair. Write this clause against
      15.3's **combined** window (response (α) of Phase 15's grounding addendum), and if 15.3 took
      response (β) instead, carry its three compatibility facts as hypotheses here. Do not discover
      this at the end of the phase.
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
is the only time.

**Amended at dispatch seq 28 — the "nothing is aligned" assertion is confirmed for two clauses, not
four, and the gap is named.** `Basic.lean`'s own docstring makes this claim, and Phase 13 confirmed
it for `BoxFaithful` (`∀ t`, folded by `forall_slab_iff_window`) and `Target` (one time on one
path). It is **not** confirmed for the existential side, which reads `G.target` and `G.slab`
together at every time under two unrelated period triples. That is a *period-combining* demand, not
an alignment-offset demand — no origin, no `plusAlignOffset`, nothing of plan v1's shape — so it is
**not** a relapse and must not be recorded as one. It is discharged by the combined window of Phase
15's grounding addendum (d). Confirm here by checking that the existential clause's `∀ t` reduces to
the combined window by a **named lemma**, not by a `decide` that happens to typecheck. Separately asserted: dropping the `witness` field costs the checker nothing,
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
        completeness direction of liveness (`exists_path_of_live` — name corrected at dispatch seq
        28; `Live` is a `Prop`, so there is no `∈`) gives the `←` direction, which is where the
        dropped `witness` field is paid for. This phase cites the **declarative** lemma, correctly:
        soundness is a proof, not a computation, so it reads `live_iff` and needs nothing from
        15.3's computed form. Only Phase 17 needs the computed form.
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
      exactly what the withdrawn `PlusGraphCertificate` was not. **Cite no probe, by path or by
      declaration name** (USER RULING, see `.decisions.json`); state the mathematical claim itself
      as the anchor. State plainly that this is **not** completeness for L⁺: targets containing
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

**GATE-STATE FINDINGS from dispatch seq 25 (measured, not predicted).** `check-module-invariants.sh`
was run in full at the end of Phase 15.1. Three check groups fail, and Phase 21 must dispose of each
by name rather than discovering them late:

1. **B0 — PRE-EXISTING, not this task's.** `expected exactly 1 Boneyard directory at ./Boneyard,
   found 2`; the second is `./.claude/worktrees/agent-aa19bfa3bfef394ff/Boneyard`, a leftover harness
   worktree from an earlier dispatch. It fails **identically at `main`'s HEAD**. Another session's
   registered git worktree must not be deleted to quiet a gate; report it as a known pre-existing
   exclusion.
2. **C23 — PRE-EXISTING, not this task's.** One outer-shadows-inner bare-declaration pair on the base
   name `datum`: outer `FormalSystem.Metalogic.Decidability.datum`
   (`BiLasso/Realized.lean:156`), inner `...PlusGraphPath.datum`
   (`PlusSlicedCertificate/Basic.lean:178`). **Both declarations are on `main`** — the inner one
   landed with Phase 13 — so this fails at `main`'s HEAD too. Phase 21 must either rename
   `PlusGraphPath.datum` or record the pair as an accepted exclusion; renaming is the cheaper of the
   two, since `datum` is used only inside `Basic.lean` and `Frame.lean`.
3. **C9 — a DIRECT CONFLICT between this plan and
   `.claude/rules/no-task-references-in-deliverables.md`, and it needs ONE decision for all four
   citations.** C9 reports four task-number citations under `FormalSystem/`:
   `PlusSlicedCertificate/Basic.lean:22` (landed Phase 13, already failing at `main`'s HEAD),
   `Splice.lean:54`, `Frame.lean:21` and `Semantics/SlicedFrame.lean:23`. Every one of them is a
   `specs/{NNN}_{slug}/probes/...` path, and **this plan mandates exactly those citations** — Phase
   13, Phase 14, Phase 20 and Phase 21 each instruct citing the 706 probe "by path". The exemption
   taxonomy at `.claude/context/standards/task-reference-exemptions.md` has **no category** covering
   "a `specs/**` research probe cited as provenance in a Lean docstring". Two candidate resolutions,
   to be chosen deliberately and recorded:
   - **(a)** Drop the `specs/` path from all four and keep the probe's **declaration name** as the
     anchor (`Probe706.no_ofStep_sat`, `Probe703Paste.truth_of_agree_of_type_eq`). This satisfies C9
     with no tooling change, at the cost of a reader not being told where the probe file lives.
   - **(b)** Add a category to the exemption taxonomy and mark the four lines `task-ref-ok`. This
     keeps the paths but edits the agent system, which must be done in the **source store** named by
     `.claude-extensions.json`'s `source_dir`, never under `.claude/**` — a strictly wider blast
     radius than this task.
   **(a) is the recommendation**; either way the choice must be recorded, and it must be applied to
   all four citations at once rather than piecemeal.

Also measured at the same run, and already fixed in dispatch seq 25 rather than deferred here: the
`INV` group failed with `FormalSystem/Semantics/README.md: SlicedFrame.lean is live but has no row`
plus three stale generated inventory blocks. The row was written and
`bash scripts/check-module-invariants.sh --emit-inventory` was run; `INV` now passes. **Every new
module added by Phases 15.2-20 will reproduce this failure**, so run `--emit-inventory` (and write
the hand-maintained row for each new subtree README) as part of each phase rather than only here.


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
      carrier with finite fibres, and **why** — **citing no probe, by path or by declaration
      name** (USER RULING, see `.decisions.json`; this README is under `FormalSystem/`, which
      invariant C9 scans for `*.md` too), stating instead the claim that no finite-carrier
      certificate can certify a `⊡`-free ℤ-time non-validity the landed L family already
      certifies; that soundness, relative completeness for tail-stable sliced
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
