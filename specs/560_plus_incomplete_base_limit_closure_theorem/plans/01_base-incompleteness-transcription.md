# Implementation Plan: Task #560

- **Task**: 560 - plus_incomplete_base_limit_closure_theorem
- **Status**: [COMPLETED]
- **Effort**: 9 hours
- **Dependencies**: None
- **Research Inputs**: specs/560_plus_incomplete_base_limit_closure_theorem/reports/01_base-incompleteness-transcription.md
- **Artifacts**: plans/01_base-incompleteness-transcription.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Land the machine-checked theorem that the current TM+ axiom set is incomplete over the
all-histories task semantics at Base: the Burgess/Thomason formula transposed to the stability
modal (called blc below) is valid at Base and is not a Base theorem of TM+. Both halves already
compile sorry-free against the LIVE definitions in this task's two probes
(`probes/01_blc-base-validity.lean`, `probes/02_blc-base-nonderivability.lean`), so the work is a
disciplined transcription of roughly 760 probe lines into five new library modules, followed by an
axiom pin and a status sweep of every README and docstring that still says general TM+
completeness is open. Definition of done: `lake build FormalSystem` green, no new `sorry`, the
headline pinned in the C14 baseline pair with profile `[propext, Classical.choice, Quot.sound]`,
`scripts/check-module-invariants.sh` green (C2/C3/C14/C24 and the generated-inventory check), and
no completeness theorem stated anywhere.

### Research Integration

From `reports/01_base-incompleteness-transcription.md`:

- Both formerly paper-only steps are closed in the probes: (i) Base validity by Zorn plus
  `PartialHistory.extension`, via the general chain-closed-property lemma report 03 of the research
  programme asked for; (ii) Saturation of the frame eR, via one new helper (a directed family with
  one finite member) and a "contains the hub or is finite" case split.
- Coarse soundness is reusable unchanged: `naiveAxiom_cValid` and
  `naiveAxiom_cValid_reflect_time` cover every naive arm at Base, `PlusAxiom.IsNaive` is false
  exactly on `paste` and `untl_paste`, and the derivation recursion is
  `naive_cValid_and_reflect_time` with the `NaiveOnly` argument deleted and a `PasteClosed`
  hypothesis threaded; the `termination_by`/`decreasing_by` block copies verbatim.
- `PasteClosed` is image-level and is a `def` on `CoarseModel`, not a structure field, so
  `CoarseModel` and every landed consumer stay untouched.
- The formula blc must be defined in the Semantics-layer file because both the countermodel and
  the assembly import it. Research recommends the order "soundness, validity, countermodel,
  assembly"; this plan adopts it and additionally splits the countermodel into a frame module and
  a model module (see Decisions).
- The only recurring compile friction is `omega` against `TemporalOrder.of ℤ` carriers; the four
  workarounds are listed in the report's Codebase Patterns item 8 and are repeated in the phases
  that need them.
- The ZTime corollary is unprobed and needs a class-indexed generalisation of `cValid_of_tm`;
  research recommends a separate task.

Planner-side findings from targeted reads (not in the report):

- `FormalSystem.Semantics.Walk.IsWalk` already exists
  (`FormalSystem/Semantics/Correspondence/FwdRecPeriodicity.lean`), generic in the relation. The
  probe's `IsWalk f` is definitionally `Walk.IsWalk eR f`. Reuse it rather than redefining.
- `exists_maximal_of_chainClosed` already exists as a base identifier in
  `FormalSystem.Metalogic.Core` (`Metalogic/Core/MaximalConsistent.lean`), for sets of formulas.
  The new lemma lives in the `PartialHistory` namespace, so there is no clash, but the docstring
  must say which one it is.
- The axiom pin is a pair of heredocs in `scripts/check-module-invariants.sh` (`C14BASE` and
  `C14LEAN`), compared by exact string equality: append the same declaration to both, in the same
  position. `docs/theorem-index.md` carries `pinned:C14` rows for the existing Independence
  results.
- `FormalSystem/Metalogic/Independence/README.md`, `FormalSystem/Semantics/PlusLanguage/README.md`
  and `FormalSystem/Metalogic/README.md` contain machine-owned
  `<!-- BEGIN GENERATED: inventory ... -->` blocks (file lists and line counts). Every phase that
  adds a `.lean` file makes them stale; `bash scripts/check-module-invariants.sh --emit-inventory`
  rewrites them and only the trailing description column is hand-written.
- Stale "TM+ completeness is open" claims exist well beyond the two READMEs the task names; the
  grep census is recorded as a Scope Hypothesis in Phase 6.
- The draft challenge statements in `## Lean Challenge Statements` below were type-checked with
  bare `lean` against the live oleans (exit 0, two `sorry` warnings only).

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

`specs/ROADMAP.md` lists this task in the deferred front "TM-star completeness / non-definability"
(with 537, 559, 561). This plan advances that row by replacing an open question with a negative
result at Base: completeness of the current TM+ axioms is false at Base, and completeness of any
extension remains open. No `roadmap_flag` was set, so the plan carries no ROADMAP.md review or
update phase and must not edit `specs/ROADMAP.md`.

## Goals & Non-Goals

**Goals**:
- Land the headline `plus_incomplete_base`: the limit-closure formula is valid at Base and is not
  derivable in TM+ at Base, from the empty context.
- Land the corollary `not_plus_complete_base`: the exact hypothesis of the conditional
  TM-star-over-TM+ conservativity theorem is refuted at Base.
- Supporting library modules (paste-closed coarse soundness; the general Zorn-plus-extension lemma
  for chain-closed properties of partial histories; the countermodel frame over integer time with
  every frame field including Saturation; the paste-closed coarse model and the refutation).
- Axiom pin for the headline in the C14 baseline pair; theorem-index row.
- Status sweep: every README row and docstring that says general TM+ completeness is open now
  says false at Base for the current axioms, open for any extension at every class.

**Non-Goals**:
- The ZTime corollary `plus_incomplete_ztime` and the second witness lcPlus (dispatch Phase 5,
  optional). Deferred to a follow-up task; see Decisions.
- Dense and RTime non-derivability (the dense saturated countermodel is unverified research).
- Any new axiom, rule or constructor; any change to `PlusAxiom` or `PlusDerivationTree`
  (`plus_soundness_validIn`, `forward_plus`, `plusDerivable_ofFormula_iff` keep their statements
  and proofs untouched).
- Any completeness theorem, stated, sorried or conditional, beyond what is already landed.
- The limit-closure schema LC_n at Base (research: it needs an omega-chain seed and does not fall
  out of the general lemma for free).
- Generalising `PlusPasting.paste` off total histories (another task owns that; this plan uses the
  current total-history signature).
- The clock/translation product.
- Editing `specs/ROADMAP.md`.

## Decisions

- **Phase order and file split.** The dispatch lists the countermodel as one phase in one file
  (roughly 350 probe lines plus docstrings). It is split here into
  `LimitClosureFrame.lean` (the frame, Saturation, walks; imports nothing new) and
  `LimitClosureCountermodel.lean` (image facts, the coarse model, PasteClosed, the refutation).
  This keeps every phase under two hours, gives one new file per phase, and lets the frame phase
  run in Wave 1 alongside the soundness and validity phases. The research's single-file layout is
  a valid alternative; nothing mathematical depends on the choice.
- **ZTime corollary excluded, not optional-in-plan.** An unexecuted optional phase would leave a
  `[NOT STARTED]` heading that blocks the phase-completion check, and the work is unprobed and
  needs an interface-level change threaded through `cValid_of_tm` and both dispatch lemmas in
  `CoarsenedModels.lean`. The dispatch says to skip it if it threatens the headline; research
  recommends a separate task. It is a Non-Goal here. The implementation summary should recommend a
  follow-up task naming the two ingredients: a class-indexed `CValidIn fc` recursion with the three
  ZTime arms (`prior_UZ`, `prior_SZ`, `z1`), and `FrameClass.ZTime.Sat EF`.
- **Home of the general lemma.** `exists_maximal_of_chainClosed` and `restrictIic` are
  language-independent, but stay in `Semantics/PlusLanguage/PlusLimitClosure.lean` as the dispatch
  names, under `namespace PartialHistory` for the lemma so dot notation works and the base
  identifier does not collide with the formula-set lemma of the same name.
- **`sInter_nonempty_of_directed_of_finite_mem` stays local** to `LimitClosureFrame.lean`.
  `Semantics/TaskFrame.lean` is 2,358 lines with heavy rebuild fan-out; moving the helper beside
  `saturation_of_fib_finite` is recorded as an optional later cleanup, not done here.
- **Headline statement shape.** The landed `plus_incomplete_base` is stated through the
  definition blc (`PlusValid (blc p) ∧ ¬ PlusDerivable FrameClass.Base [] (blc p)`), as the task
  asks. The challenge statement below writes the formula out in full, because the snapshot tool
  forces every declaration body, including a `def`, to `sorry`, which would make a challenge that
  mentions blc meaningless. The two statements are definitionally equal by unfolding blc. An
  advisory textual-drift verdict from `lean-challenge-snapshot.sh --check` on this one identifier
  is therefore expected and is not a defect; `not_plus_complete_base` is definition-free and
  should match exactly.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Probe code drifts from what lands (restyling breaks a proof) | M | M | Copy declarations verbatim first, build green, commit, then restyle (docstrings, 100-column, namespace) in a second green sub-step |
| Linter findings: `docBlame`, 100-column, unused arguments, `defsWithUnderscore` (C16), compiler-warning budget (C28, ceiling is zero for a new file) | M | H | Every landed declaration gets a docstring; probe headers are deliberately not copy-ready; run the module build and read its warnings before closing each phase; no `nolint` attributes (C26) |
| C14 heredoc pair edited asymmetrically, or the measured profile is a strict subset of the expected one | M | L | Append to `C14BASE` and `C14LEAN` together in the same position; record the literal `#print axioms` output, never a rounded-up profile |
| Generated inventory blocks go stale (file lists, line counts) | M | H | Each file-adding phase runs `--emit-inventory`, fills the description cell, and stages the README by explicit path |
| Concurrent sessions are editing `FormalSystem/Metalogic/README.md` and holding builds | M | M | Re-read immediately before editing; stage only this task's hunks/files by explicit path (never `git add -A`, never a directory pathspec); all builds detached through `.claude/scripts/lake-build-guard.sh build` |
| `omega` cannot see through `EF.Duration.carrier` | L | H | Helper lemmas with `(t : ℤ)` binders; `sub_pos.mpr` / `sub_neg.mpr`; `show (t : ℤ) < t + 1 by omega`; `Int.lt_succ` (all verified in the probe) |
| `@[reducible]` dropped from `eFrameOver`/`EF`, so `WorldState` stops reducing to the carrier | H | L | Keep `@[reducible]` on both, as `ForwardDeterministicFrame.lean` does for `fnFrameOver`/`FN`; verify with `ef_taskRel_iff := Iff.rfl`-style check from the probe |
| Reusing `Walk.IsWalk` pulls a heavier import into the Independence module or perturbs a probe proof | L | M | Default is reuse; fallback is a local `abbrev` in a sub-namespace stated as `Walk.IsWalk eR`-equivalent, decided in Phase 3 and recorded in the summary |
| Wildcard arm `| _ => exact absurd trivial hn` in the axiom dispatch violates a no-wildcard convention | L | M | Replace by the explicit two-arm `cases` after the `by_cases` on `IsNaive`; if a full enumeration is unavoidable keep the `by_cases` structure so a future naive constructor lands in the first branch |
| Task-number or probe-namespace residue under `FormalSystem/` | M | M | No `Probe560`, no task numbers, no `specs/` paths in any landed file or README; the write-time hook and `check-task-references.sh` enforce it, grep before each commit |
| Docstring-only edits to `Star/Forward.lean` accidentally touch code, violating the untouched-statements constraint | H | L | Phase 6 verifies by `git diff` that every changed hunk in a `.lean` file lies inside a comment, then rebuilds |
| Status sweep overclaims (e.g. says TM-star is non-conservative over TM+) | H | M | Incompleteness refutes the hypothesis of the conditional; it does NOT decide conservativity. The row must say "hypothesis refuted at Base; conservativity over TM+ at Base undecided by this route" |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2, 3 | -- |
| 2 | 4 | 1, 2, 3 |
| 3 | 5 | 2, 4 |
| 4 | 6 | 5 |

Phases within the same wave can execute in parallel. They touch disjoint `.lean` files, but
Phases 1 and 3 both append an import line to `FormalSystem/Metalogic/Independence.lean` and both
regenerate the same inventory blocks; if run in parallel, serialise those two small edits and the
builds (the build guard already serialises `lake`).

Standing rules for every phase: builds run detached through
`bash .claude/scripts/lake-build-guard.sh build -- build <target>`; no `sorry`; no task numbers,
probe namespaces or `specs/` paths under `FormalSystem/`; commit each verified-green sub-step with
explicit-path staging; never state a completeness theorem.

### Phase 1: Paste-closed coarse soundness [COMPLETED]

**Goal**: A new module proving that every Base theorem of TM+ is valid on every paste-closed
coarse model, plus the refutation-to-non-derivability bridge.

**Tasks**:
- [x] Create `FormalSystem/Metalogic/Independence/PastedCoarseModels.lean` importing
  `FormalSystem.Metalogic.Independence.CoarsenedModels`, in
  `namespace FormalSystem.Metalogic.Independence`, with the standard copyright header and a module
  docstring (what paste-closed means, that PS and US are exactly the two non-naive arms, that the
  recursion mirrors `naive_cValid_and_reflect_time`).
- [x] Transcribe from probe 02 (section "PC"): `CoarseModel.PasteClosed` (image-level splice at
  equal `π`-class, both clauses including `t`), the purity congruences `c_truth_congr_from` and
  `c_truth_congr_upTo` (the `π`-image versions of `truth_congr_agreeFrom` / `agreeUpTo`), the four
  arms `c_paste`, `c_paste'`, `c_untl_paste`, `c_snce_paste`, the validity notion `PCValid`, the
  axiom dispatch `plusAxiom_pcValid` (valid and reflect-time valid), the derivation recursion
  `plus_pcValid_and_reflect_time`, and `not_plusDerivable_of_pcRefuted`.
- [x] Make `PasteClosed` a `def` in the `CoarseModel` namespace (dot notation `K.PasteClosed`);
  do not add a field to `CoarseModel`; do not edit `CoarsenedModels.lean`.
- [x] Replace the wildcard arm in `plusAxiom_pcValid` with the explicit two-arm `cases` in the
  non-naive branch *(completed: two `case` arms, remaining arms closed by `all_goals exact absurd trivial hn`, no `| _` wildcard)*; reflected arms follow the `AxiomValidity.lean` normal form
  (`simp only [PlusFormula.reflectTime, reflect_time_dstab, reflect_time_and]`, then the primed
  lemma at the reflected hypotheses).
- [x] Copy the `termination_by` / `decreasing_by` block from `naive_cValid_and_reflect_time`
  verbatim.
- [x] Docstring every declaration; 100-column; rename to repository naming conventions only where
  a linter demands it (record any rename in the summary, since Phase 4 consumes these names).
- [x] Register the module in `FormalSystem/Metalogic/Independence.lean` (import line plus a
  bullet in its module docstring) and run
  `bash scripts/check-module-invariants.sh --emit-inventory`; fill the description cell for the
  new row in `FormalSystem/Metalogic/Independence/README.md`.
- [x] Build `FormalSystem.Metalogic.Independence.PastedCoarseModels`, then `FormalSystem`.

**Timing**: 1.5 hours

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: eleven declarations, about 165 probe lines (probe 02 lines 244-415). Confirm
by diffing the landed declaration list against the probe's "PC" section; any declaration dropped or
added is recorded in the summary.

**Files to modify**:
- `FormalSystem/Metalogic/Independence/PastedCoarseModels.lean` - new
- `FormalSystem/Metalogic/Independence.lean` - import line and docstring bullet
- `FormalSystem/Metalogic/Independence/README.md` - generated inventory row plus description
- `FormalSystem/Metalogic/README.md` - generated subdirectory line counts only (if rewritten)

**Verification**:
- Module and `lake build FormalSystem` green; zero warnings from the new file.
- `grep -n sorry` on the new file is empty.
- `#print axioms FormalSystem.Metalogic.Independence.not_plusDerivable_of_pcRefuted` (run in a
  scratch file, not left in-tree: C27 fails on in-file directives) reports
  `[propext, Classical.choice, Quot.sound]`.
- `bash scripts/check-module-invariants.sh --emit-inventory --check` exits 0.

---

### Phase 2: General maximality lemma and Base validity of the formula [COMPLETED]

**Goal**: The Semantics-layer module defining the formula and proving it valid at Base through a
general Zorn-plus-extension lemma.

**Tasks**:
- [x] Create `FormalSystem/Semantics/PlusLanguage/PlusLimitClosure.lean` importing
  `FormalSystem.Semantics.Extension.Extension` and
  `FormalSystem.Semantics.PlusLanguage.PlusPasting`, in `namespace FormalSystem.Semantics`.
- [x] Transcribe from probe 01: the general lemma `PartialHistory.exists_maximal_of_chainClosed`
  (for a property of partial histories closed under `chainSup` of nonempty chains, every member
  lies below a maximal member, and that maximal member extends to a world history; proof:
  `zorn_le_nonempty₀` then `extension`), `restrictIic`, the structure `LCProp`
  (down-set, anchor, some p-point, recur-or-maximum), `lcProp_restrictIic`, `lcProp_chainSup`,
  `limit_history`, the definition `blc`, and `blc_plusValid : PlusValid (blc p)`.
- [x] State the general lemma for an arbitrary chain-closed property exactly as in the probe; the
  docstring distinguishes it from the formula-set lemma of the same base name in
  `Metalogic/Core/MaximalConsistent.lean` and notes that the limit-closure schema instance is not
  stated.
- [x] Keep p-points in the dependent form `∃ hx : μ.domain x, P (μ.states x hx)` and rewrite along
  `Extends.agree`, as the probe does.
- [x] Step 6 uses `PlusPasting.paste` at its current total-history signature; do not generalise
  it.
- [x] Module docstring: the six-step map (define the property; nonempty by restriction of the
  witness; chain-closed; Zorn plus extension; failure of `G(p → Fp)` at `f` bounds the maximal
  domain by `f`; one paste strictly extends, contradiction); attribution to Burgess and to
  Thomason 1984 for the untransposed formula; and the consistency check (under stability = identity
  the formula reduces to `(Fp ∧ G(p → Fp)) → (Fp ∧ G(p → Fp))`, a theorem of TM+ plus
  Determined).
- [x] Use `push Not`, not the deprecated `push_neg`.
- [x] Register in `FormalSystem/Semantics/PlusLanguage.lean` (import plus Modules bullet); run
  `--emit-inventory`; fill the description cell in
  `FormalSystem/Semantics/PlusLanguage/README.md`.
- [x] Build the module, then `FormalSystem`.

**Timing**: 1.5 hours

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: eight declarations, 169 probe lines. Confirm against probe 01's declaration
list.

**Files to modify**:
- `FormalSystem/Semantics/PlusLanguage/PlusLimitClosure.lean` - new
- `FormalSystem/Semantics/PlusLanguage.lean` - import line and Modules bullet
- `FormalSystem/Semantics/PlusLanguage/README.md` - generated inventory row plus description

**Verification**:
- Module and `lake build FormalSystem` green; zero warnings from the new file; no `sorry`.
- Scratch `#print axioms FormalSystem.Semantics.blc_plusValid` reports
  `[propext, Classical.choice, Quot.sound]`.
- C24: the new module reaches `FormalSystem.Init` through its imports (checked by the full
  invariants run in Phase 5; here confirm both imports are already in the root closure).
- `--emit-inventory --check` exits 0.

---

### Phase 3: The countermodel frame over integer time [COMPLETED]

**Goal**: The frame eR on `Option (Bool × ℕ)` as a `FrameOver (TemporalOrder.of ℤ)` satisfying
every field of the live `TaskFrame`, including Saturation, plus the walk API.

**Tasks**:
- [x] Create `FormalSystem/Metalogic/Independence/LimitClosureFrame.lean`, in
  `namespace FormalSystem.Metalogic.Independence`, following the construction pattern of
  `ForwardDeterministicFrame.lean` (`fnRel`, `fnFrameOver`, `FN`, `fn_taskRel_iff`). Imports: what
  that file imports for the frame API, plus Mathlib finiteness lemmas as needed; do not import
  `CoarsenedModels` unless required.
- [x] Transcribe from probe 02 (lines 21-243): the carrier abbreviation, `eR` (the hub `none`
  reaches everything and is reached only from itself; between non-hub states the natural-number
  budget is non-increasing and strictly decreases on entering the `true` class), `eπ`,
  `eR_trans`, `eR_dense`, `eR_succ`, the two-sided `eRel` with `eRel_zero`, `eRel_pos`,
  `eRel_neg`, `eRel_reflection`, `eRel_serial`, `eRel_comp`, `eRel_limit` (via
  `TaskFrame.limit_of_succOrder (D := ℤ)`).
- [x] Saturation: `sInter_nonempty_of_directed_of_finite_mem` (local, frame-agnostic, stated next
  to a pointer to `sInter_nonempty_of_directed_of_minimal`), `eR_fwd_finite`,
  `eRel_fib_hub_or_finite`, `eRel_seg_hub_or_finite`, `eRel_saturation`. The argument: eR is
  transitive and dense so the n-step relation is eR for n ≥ 1; forward fibres of non-hub states are
  finite; every infinite fibre or segment contains the hub.
- [x] `@[reducible] def eFrameOver` and `@[reducible] def EF`, fields citing
  `TaskFrame.*_reflect_of_reflective`; `ef_taskRel_iff`.
- [x] Walks: reuse `FormalSystem.Semantics.Walk.IsWalk` at `eR` (default) or a local abbreviation
  (fallback, see Risks); `isWalk_state`, `walk_lt`, `histOfWalk`. *(completed: default taken, `Walk.IsWalk eR` reused via `Semantics/Correspondence/FwdRecPeriodicity.lean`; no fallback needed)*
- [x] Use the four `omega`-versus-carrier workarounds where times have type `EF.Duration`.
- [x] Module docstring: the frame in one paragraph, why the budget bounds future p-visits, that
  the frame is necessarily nondeterministic (the hub reaches every state), and the one-line
  reading (the countermodel it supports is a dense, non-closed bundle).
- [x] Register in `FormalSystem/Metalogic/Independence.lean`; `--emit-inventory`; description
  cell.
- [x] Build the module, then `FormalSystem`.

**Timing**: 1.5 hours

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: about 25 declarations, about 225 probe lines. Confirm against probe 02's
Parts A-C declaration list.

**Files to modify**:
- `FormalSystem/Metalogic/Independence/LimitClosureFrame.lean` - new
- `FormalSystem/Metalogic/Independence.lean` - import line and docstring bullet
- `FormalSystem/Metalogic/Independence/README.md` - generated inventory row plus description
- `FormalSystem/Metalogic/README.md` - generated subdirectory line counts only (if rewritten)

**Verification**:
- Module and `lake build FormalSystem` green; zero warnings from the new file; no `sorry`.
- `EF : TaskFrame` elaborates with every field supplied (no field defaulted by `sorry` or an
  auxiliary axiom); scratch `#print axioms` on `EF` and `histOfWalk` reports
  `[propext, Classical.choice, Quot.sound]`.
- `--emit-inventory --check` exits 0.

---

### Phase 4: The paste-closed coarse model and the refutation [COMPLETED]

**Goal**: The coarse model on `EF` with `π` the Boolean component, its paste-closedness, the
refutation of the formula, and the non-derivability half of the headline.

**Tasks**:
- [x] Create `FormalSystem/Metalogic/Independence/LimitClosureCountermodel.lean` importing
  `PastedCoarseModels`, `LimitClosureFrame` and
  `FormalSystem.Semantics.PlusLanguage.PlusLimitClosure` (for `blc`; delete the probe's local copy
  of the definition).
- [x] Transcribe from probe 02 (Part D, lines 417-590): `evFalse` (eventually-false Boolean
  sequences), `eR_budget`, `eR_evFalse_aux`, `eR_image_mem`, `mem_eR_image`, `hist_image_mem`,
  `exists_hist_of_evFalse`, the coarse model `eK` (every atom read on the `true` class, so
  `atom_inv` is a rewrite), `eK_pasteClosed_aux`, `eK_pasteClosed`, `blc_cRefuted`
  (`¬ CTruthAt eK τ t (blc p)` at every history and time), and
  `blc_not_plusDerivable_base : ¬ PlusDerivable FrameClass.Base [] (blc p)`.
- [x] Adjust names consumed from Phases 1 and 3 if either renamed anything.
- [x] Module docstring: the image of the histories of `EF` under `π` is exactly `evFalse`; splicing
  two eventually-false sequences at a common value is eventually false (paste-closed); the
  all-true-forever limit is missing (not closed), which is what refutes the consequent while the
  antecedent holds; consistency check that the countermodel is necessarily nondeterministic.
- [x] Register in `FormalSystem/Metalogic/Independence.lean`; `--emit-inventory`; description
  cell.
- [x] Build the module, then `FormalSystem`.

**Timing**: 2 hours

**Depends on**: 1, 2, 3

**Verification Tier**: local

**Scope Hypothesis**: twelve declarations, about 175 probe lines. Confirm against probe 02's
Part D declaration list.

**Files to modify**:
- `FormalSystem/Metalogic/Independence/LimitClosureCountermodel.lean` - new
- `FormalSystem/Metalogic/Independence.lean` - import line and docstring bullet
- `FormalSystem/Metalogic/Independence/README.md` - generated inventory row plus description
- `FormalSystem/Metalogic/README.md` - generated subdirectory line counts only (if rewritten)

**Verification**:
- Module and `lake build FormalSystem` green; zero warnings from the new file; no `sorry`.
- Scratch `#print axioms FormalSystem.Metalogic.Independence.blc_not_plusDerivable_base` reports
  `[propext, Classical.choice, Quot.sound]`.
- `--emit-inventory --check` exits 0.

---

### Phase 5: Assemble the headline and pin its axioms [COMPLETED]

**Goal**: The headline theorem, its corollary, the C14 axiom pin and the theorem-index row.

**Tasks**:
- [x] Create `FormalSystem/Metalogic/Independence/PlusIncompleteness.lean` importing
  `LimitClosureCountermodel` (which brings `PlusLimitClosure`), with:
  `plus_incomplete_base (p : Atom) : PlusValid (blc p) ∧ ¬ PlusDerivable FrameClass.Base [] (blc p)`
  as the pair of `blc_plusValid p` and `blc_not_plusDerivable_base p`; and
  `not_plus_complete_base : ¬ ∀ ψ : PlusFormula, PlusValidIn FrameClass.Base ψ → PlusDerivable FrameClass.Base [] ψ`
  (`PlusValid` unfolds to `PlusValidIn FrameClass.Base`, so this is the headline applied at any
  atom; it is verbatim the `hcomplete` hypothesis of `starConservative_of_plusComplete` at Base).
- [x] Module docstring: the statement in words; what is and is not shown (the CURRENT axiom set is
  incomplete at Base; nothing is claimed about any extension, any other class, or conservativity
  of TM-star over TM+); the consistency check required by the task (under stability = identity the
  formula is a theorem of TM+ plus Determined by the landed deterministic completeness, and the
  countermodel is necessarily nondeterministic); the one-line reading (the coarsened countermodel
  is a dense, non-closed bundle: PS and US say paste-closed, MF says translation-closed, nothing
  says closed); attribution. No completeness theorem is stated.
- [x] Axiom pin: append
  `'FormalSystem.Metalogic.Independence.plus_incomplete_base' depends on axioms: [propext, Classical.choice, Quot.sound]`
  to the `C14BASE` heredoc and the matching
  `#print axioms FormalSystem.Metalogic.Independence.plus_incomplete_base` to the `C14LEAN`
  heredoc in `scripts/check-module-invariants.sh`, in the same relative position (after the
  existing Independence entries). Record the literal measured profile; if it differs from the
  expected one, stop and report rather than editing the expectation.
- [x] Add a `docs/theorem-index.md` row beside the existing Independence rows (class Base, tag
  `pcq pinned:C14`), and correct the sentence near its deterministic-rows note that says general
  TM+ completeness is open (full sweep is Phase 6; this one line travels with the row). *(deviation: altered — the closing "Completeness for TM-star" bullet of the same file also asserted TM+ completeness open at every class; corrected here too, since the plan assigns this file to Phase 5)*
- [x] Register in `FormalSystem/Metalogic/Independence.lean`, adding the result to the numbered
  list of results in that aggregator's module docstring; `--emit-inventory`; description cell.
- [x] Build `FormalSystem`, then run the full `bash scripts/check-module-invariants.sh`.

**Timing**: 1 hour

**Depends on**: 2, 4

**Verification Tier**: full

**Files to modify**:
- `FormalSystem/Metalogic/Independence/PlusIncompleteness.lean` - new
- `FormalSystem/Metalogic/Independence.lean` - import line and results list
- `scripts/check-module-invariants.sh` - `C14BASE` and `C14LEAN` heredocs, one line each
- `docs/theorem-index.md` - one row, one corrected sentence
- `FormalSystem/Metalogic/Independence/README.md` - generated inventory row plus description
- `FormalSystem/Metalogic/README.md` - generated subdirectory line counts only (if rewritten)

**Verification**:
- `lake build FormalSystem` green; no `sorry` anywhere in the five new files
  (`grep -n "sorry"` empty).
- `bash scripts/check-module-invariants.sh` green, in particular C2 (four flagship axiom sets
  unchanged), C3 (exactly one structural `sorry`, unchanged), C14 (both halves, including the new
  pin), C21 if the theorem-index row falls in its scope, C24 (all five new modules reach
  `FormalSystem.Init`), C27 (no in-file `#print axioms`), C28 (warning budget), and the
  generated-inventory check.
- `git diff` shows no change to `PlusAxiom`, `PlusDerivationTree`, `plus_soundness_validIn`,
  `forward_plus` or `plusDerivable_ofFormula_iff`.
- `bash .claude/scripts/lean-challenge-snapshot.sh --check 560 .` (advisory, and only if a
  challenge manifest was snapshotted before implementation began): exact match expected for
  `not_plus_complete_base`; a textual-drift verdict for `plus_incomplete_base` is expected (see
  Decisions) and is recorded, not acted on.

---

### Phase 6: Status sweep of READMEs and docstrings [COMPLETED]

**Goal**: Every statement in the tree that general TM+ completeness is open is replaced by the
three-part status: completeness of the current TM+ axioms is FALSE at Base
(`Independence/PlusIncompleteness.lean`); completeness of any extension is OPEN at every class;
the hypothesis of the conditional TM-star-over-TM+ row is REFUTED at Base.

**Tasks**:
- [x] Re-read each file immediately before editing (concurrent sessions are active in
  `FormalSystem/Metalogic/README.md`).
- [x] `FormalSystem/Metalogic/Conservativity/Plus/README.md`: the "General TM+ completeness and
  TM+ decidability are open" paragraph and the status-table rows (completeness row, the
  conditional conservativity row, and the section "The L-star rows sit on top of this open
  problem"). Add the one-line reading: the coarsened countermodel is a dense, non-closed bundle;
  PS and US say paste-closed, MF says translation-closed, nothing says closed. TM+ decidability
  stays OPEN.
- [x] `FormalSystem/Metalogic/README.md`: the TM+ status table row and the sentence after it
  ("The two open rows are stated nowhere..."), and the TM-star table's conditional row.
- [x] Conditional-row wording, everywhere it appears: the hypothesis is refuted at Base, so
  `starConservative_of_plusComplete` is vacuous at Base; conservativity of TM-star over TM+ at
  Base is NOT thereby decided (incompleteness does not yield a separating witness);
  `plusIncomplete_of_starNonconservative` remains the only route from non-conservativity; at
  Dense, ZTime and RTime the hypothesis is still open.
- [x] Remaining census hits: `FormalSystem/Metalogic.lean` module docstring,
  `FormalSystem/Metalogic/Deterministic/README.md` (section heading "General TM+ completeness is
  open"), `FormalSystem/Metalogic/Deterministic/Completeness.lean` docstring,
  `FormalSystem/Metalogic/Conservativity/README.md` (the `Star/` row),
  `FormalSystem/Metalogic/Conservativity/Star/README.md`,
  `FormalSystem/Metalogic/Conservativity/Star.lean` and `Star/Forward.lean` docstrings (three
  places, including the docstring of `starConservative_of_plusComplete`),
  `FormalSystem/Metalogic/Conservativity/Plus.lean` ("What is open" section). *(deviation: altered — a wider census grep found further stale statements outside this list, all edited, comments/prose only: `FormalSystem/Metalogic/Deterministic.lean`, `FormalSystem/Metalogic/Conservativity.lean`, `FormalSystem/Metalogic/Conservativity/Plus/Forward.lean`, a second passage in `Deterministic/Completeness.lean`, a second passage in `Star/Forward.lean`, the root `README.md` open-problems bullet, and the conditional row of `FormalSystem/Syntax/StarLanguage/README.md`)*
- [x] In every `.lean` file touched here, edit comments and docstrings ONLY.
- [x] Hand-written prose in `FormalSystem/Metalogic/Independence/README.md`: add the result to
  the narrative list of results (the generated table rows were added in earlier phases).
- [x] Re-run the census grep and confirm no remaining hit asserts that completeness of the
  current axioms is open at Base.
- [x] Build `FormalSystem` (docstring edits still recompile their modules), then the full
  invariants script and `bash scripts/readme-lint.sh`.

**Timing**: 1.5 hours

**Depends on**: 5

**Verification Tier**: prose

**Scope Hypothesis**: the census
`grep -rniE "completeness.{0,60}open|open at every class" FormalSystem docs README.md typst`
filtered to TM+ / L+ mentions returned 15 hits in 12 files at plan time (the ten files listed
above plus `docs/theorem-index.md`, handled in Phase 5, and lines about TM or TM-star
decidability/completeness that are NOT about TM+ and must be left alone). Confirm by re-running
the census at the start of the phase; classify each hit as edit / leave, and record the
classification in the summary. Hits about TM-star completeness and about decidability stay OPEN.

**Files to modify**:
- `FormalSystem/Metalogic/Conservativity/Plus/README.md` - status paragraph and rows
- `FormalSystem/Metalogic/README.md` - two status-table rows and following sentence
- `FormalSystem/Metalogic/Independence/README.md` - narrative entry
- `FormalSystem/Metalogic/Deterministic/README.md` - section heading and body
- `FormalSystem/Metalogic/Conservativity/README.md` - `Star/` row wording
- `FormalSystem/Metalogic/Conservativity/Star/README.md` - conditional-pair paragraph
- `FormalSystem/Metalogic.lean`, `FormalSystem/Metalogic/Conservativity/Plus.lean`,
  `FormalSystem/Metalogic/Conservativity/Star.lean`,
  `FormalSystem/Metalogic/Conservativity/Star/Forward.lean`,
  `FormalSystem/Metalogic/Deterministic/Completeness.lean` - docstrings only

**Verification**:
- `git diff -U0` on the five `.lean` files: every changed hunk lies inside a `/-! ... -/` or
  `/-- ... -/` block (diff read-through); no statement, proof or import line changes.
- `lake build FormalSystem` green; full `bash scripts/check-module-invariants.sh` green (C12,
  C13, C14's documentation half, C15 and the inventory check are the ones prose edits can trip);
  `bash scripts/readme-lint.sh` green.
- No sentence anywhere claims TM-star is non-conservative over TM+, claims completeness of any
  extended axiom set, or states a completeness theorem.
- `bash .claude/scripts/check-task-references.sh` (or the repository's equivalent lint) reports no
  task-number reference in any file this task touched outside `specs/`.

## Lean Challenge Statements

The formula is written out in full because the snapshot tool forces every declaration body to
`sorry`, including a `def`. The landed headline is stated through the definition blc and is equal
to the first statement by unfolding. Type-checked at plan time with bare `lean` against the live
oleans.

```lean
import FormalSystem.Semantics.PlusLanguage.PlusValidity
import FormalSystem.Syntax.PlusLanguage.Derivation

open FormalSystem.Syntax FormalSystem.PlusLanguage FormalSystem.PlusLanguage.PlusFormula
open FormalSystem.ProofSystem FormalSystem.Semantics

theorem plus_incomplete_base (p : Atom) :
    PlusValid
        (((dstab (someFuture (.atom p))).and
            (.stab (allFuture ((PlusFormula.atom p).imp (dstab (someFuture (.atom p))))))).imp
          (dstab ((someFuture (.atom p)).and
            (allFuture ((PlusFormula.atom p).imp (someFuture (.atom p))))))) ∧
      ¬ PlusDerivable FrameClass.Base []
        (((dstab (someFuture (.atom p))).and
            (.stab (allFuture ((PlusFormula.atom p).imp (dstab (someFuture (.atom p))))))).imp
          (dstab ((someFuture (.atom p)).and
            (allFuture ((PlusFormula.atom p).imp (someFuture (.atom p))))))) := sorry

theorem not_plus_complete_base :
    ¬ ∀ ψ : PlusFormula, PlusValidIn FrameClass.Base ψ → PlusDerivable FrameClass.Base [] ψ := sorry
```

## Testing & Validation

- [x] `lake build FormalSystem` green at the close of every phase, run detached through
  `.claude/scripts/lake-build-guard.sh build`.
- [x] No `sorry` in any of the five new modules; C3 still finds exactly one structural `sorry`,
  the pre-existing one.
- [x] `#print axioms` for `plus_incomplete_base`, `blc_plusValid`,
  `blc_not_plusDerivable_base`, `not_plusDerivable_of_pcRefuted`, `EF`:
  `[propext, Classical.choice, Quot.sound]`; the headline is pinned in both C14 heredocs.
- [x] Full `bash scripts/check-module-invariants.sh` green at the close of Phases 5 and 6
  (C2, C3, C14, C24 named by the task; also C16, C26, C27, C28 and the generated-inventory check,
  which new files can trip).
- [x] `PlusAxiom`, `PlusDerivationTree`, `plus_soundness_validIn`, `forward_plus`,
  `plusDerivable_ofFormula_iff`, `CoarseModel` and `CoarsenedModels.lean` are unchanged
  (`git diff --stat` over the task's commits).
- [x] No completeness theorem is stated; no task number, probe namespace or `specs/` path appears
  under `FormalSystem/`, `docs/` or `scripts/`.
- [x] The two probes still compile (they import only landed modules), as a regression check that
  no landed dependency was perturbed.

## Artifacts & Outputs

- `FormalSystem/Metalogic/Independence/PastedCoarseModels.lean`
- `FormalSystem/Semantics/PlusLanguage/PlusLimitClosure.lean`
- `FormalSystem/Metalogic/Independence/LimitClosureFrame.lean`
- `FormalSystem/Metalogic/Independence/LimitClosureCountermodel.lean`
- `FormalSystem/Metalogic/Independence/PlusIncompleteness.lean`
- Aggregator edits: `FormalSystem/Metalogic/Independence.lean`,
  `FormalSystem/Semantics/PlusLanguage.lean`
- `scripts/check-module-invariants.sh` (C14 pin), `docs/theorem-index.md` (row)
- README and docstring status sweep (Phase 6 file list)
- `specs/560_plus_incomplete_base_limit_closure_theorem/summaries/01_base-incompleteness-transcription-summary.md`,
  including the recommendation for a follow-up task on the ZTime corollary

## Rollback/Contingency

- Each phase adds one new leaf module plus an import line, so a failed phase is reverted by
  removing that module's import from its aggregator and deleting the new file in a normal commit;
  nothing landed depends on it until the next phase. Prefer fixing forward: the probes are a
  known-green reference for every declaration.
- If a transcribed proof breaks under restyling, restore the probe's text for that declaration
  verbatim (the first sub-step of every phase is a verbatim, green, committed copy).
- If the measured axiom profile of the headline is not the expected one, do not edit the C14
  expectation to match; stop, mark the phase `[BLOCKED]` and report the literal output.
- If Phase 6 cannot be completed (for example, an unresolvable conflict with a concurrent
  session's edits to `FormalSystem/Metalogic/README.md`), mark it `[PARTIAL]` with the list of
  files done; Phases 1-5 stand on their own and the headline is already pinned.
- A rollback that would discard uncommitted work follows the snapshot-then-rollback rung of
  `.claude/context/contracts/recovery.md`, including its out-of-scope override for a deliberate
  whole-tree case. No phase begins with a precautionary snapshot; an ordinary defensive checkpoint
  before risky work uses the non-reverting `--no-revert` form.
