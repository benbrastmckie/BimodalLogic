# Implementation Plan: Task #737

- **Task**: 737 - Discharge the Presents hypothesis bundle: formalize the MSO-over-Z-less-than reduction behind the seam summary
- **Status**: [IMPLEMENTING]
- **Effort**: 8 hours
- **Dependencies**: 711 (satisfied; substrate landed and re-verified by the research dispatch)
- **Research Inputs**: specs/737_discharge_presents_mso_reduction_seam_summary/reports/01_discharge-presents-verdict.md
- **Artifacts**: plans/01_discharge-presents-verdict.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

The research dispatch settled the question this task was filed to answer, and settled it in the
direction the task description names as outcome (b): **the single-family bundle `Presents` cannot
be discharged on this route in its landed shape, and the obstruction is a theorem, not prose.**
For every signature and depth, `∃ T S, Presents M τ t φ sig k T S` holds iff `φ` is `⊡`-decided
at the seam (`⊡φ ∨ ⊡¬φ`), so the landed `colours` field is a semantic condition that is false in
general — exhibited false on the E2 fixture — and not the MSO reduction its docstring calls it.
The same dispatch compiled the corrected shape: under a two-letter trace encoding (seam marker +
`φ`'s truth along the history) and the depth-1 target `∃x (now x ∧ φ x)`, the `⊡` bridge becomes a
hypothesis-free theorem over the finite set `Hit` of realized family triples, field (3)
`determined` is a nine-line corollary of Doets 1.1, and a four-field `PresentsMulti` mirroring
the landed bundle is inhabited outright — with the entire unformalized content now isolated in
one named object, `Hit`, which nothing landed computes.

This plan lands that verdict in the tree: the Doets corollary beside its special case in
`KTypeSummary/Universal.lean`; the characterization and the corrected interface as a new module
`RaySummary/SeamMulti.lean` beside (never replacing) the pinned `Seam.lean`; the fixture-level
obstruction as a wired evidence probe; axiom pins, the C14 baseline pair and one theorem-index
row; and the record corrections the finding forces (the "unformalized MSO reduction" wording in
`Seam.lean`, both READMEs, the aggregators and `specs/ROADMAP.md`), with the residue B1-B4 named
as the gap between this record and the assembly record. Every statement stays under
`[F.IsRegular]`, over the time axis, with a finite alphabet of per-time summaries; no complexity
bound is claimed anywhere. Definition of done: the 11 Challenge identifiers below exist with the
pinned signatures and the standard axiom profile, the probe compiles in the collection, the full
gate set is green, and no surviving sentence in the tree calls `Presents.colours` the MSO
reduction or calls `Presents` discharged.

### Research Integration

Integrated from `reports/01_discharge-presents-verdict.md`:

- The characterization `exists_presents_iff` (forward via `colours` + `determined` + `verdict`
  through `family_saturation`, `realized` unused; backward via the constant target and the
  seam's own ray pair) — Phase 2, statements pinned under Lean Challenge Statements.
- The undecided seam `(stayA c t, t)` on `Fp` over the transcribed E2 fixture and
  `no_presents_on_fixture` for every `sig`, `k`, `T`, `S` — Phase 3, kept in the evidence
  collection per Recommendation 4.
- The corrected shape: trace, `nowPhi`, target, `Hit`, `hit_finite`, the hypothesis-free bridge
  `plusStab_iff_forall_hit`, `PresentsMulti`, `plusStab_iff_presentsMulti`, and the inhabitant
  whose `Bool` is classical — Phase 2, from the compiled probe text with the renames in Decision
  D-3.
- `determinedByKType_eval` via `doets_lemma_1_1`, the predicted quick win for field (3) and,
  as the dispatch warned, no evidence for the rest — Phase 1.
- The coverage answer (the cluster supplies Büchi's complementation half in full and nothing of
  the realizability half) and the costed residue B0-B4: B0 is this plan; B1-B3 and B4 are
  recorded in the ROADMAP and the summary as the named gap before the assembly record (Phase 5).
- Tooling lesson: `lake-build-guard.sh build` replays a stale result for `env lean <file>` after
  the file changes (argv-keyed sharing); single-file recompiles pass `--no-share`.
- Decisions D-1 through D-5 of the report are adopted; this plan adds D-6 (probe cites, never
  re-declares) and D-3's naming table.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No `roadmap_path` was supplied to this dispatch and `roadmap_flag` is not set, so no roadmap
review/update phases are mandated. `specs/ROADMAP.md` Phase 1 was consulted read-only for context:
this task is the middle of the critical path **711 → 737 → 735**, and its bullet there names
outcome (b) as a valid completion. Phase 5 of this plan updates that bullet (the task-management
record under `specs/`) and inserts the B1-B4 residue as a named gap before the 735 bullet; it does
not mark 735 and does not edit 735's description.

## Goals & Non-Goals

**Goals**:
- `determinedByKType_eval` — field (3) discharged for every depth-at-most-k sentence, landed in Universal.lean beside its normal-form special case
- `SeamDecided`, `seamDecided_of_presents`, `exists_presents_of_seamDecided`, `exists_presents_iff` — the single-family bundle characterized as seam decidedness: the machine-checked obstruction for field (1) in the landed shape
- `seamTrace`, `nowPhi`, `stabTarget`, `Hit`, `hit_finite`, `plusStab_iff_forall_hit` — the corrected two-letter interface and the hypothesis-free bridge over the realized set
- The fixture-level obstruction (the undecided seam on the E2 fixture, no inhabitant for any parameters) landed as a wired evidence probe
- Axiom pins for the new headline results, the C14 baseline pair extended, one Decidability row in the theorem index
- Every record that calls the colours field the unformalized MSO reduction corrected, and the residue named in the ROADMAP

**Non-Goals**:
- Computing `Hit`, deciding anything, or assembling `Decidable (PlusValidZTime φ)` — that is 735's frame, and B1-B3 (closure alphabet, realizability/quasimodel direction, effective `k`-type composition) are a successor record's work, recorded here as the named gap, not attempted.
- Deleting or restating `Presents` or `plusStab_iff_seamSummary` — both are pinned, cited and correct as theorems; the degeneracy is recorded beside them (report D-4).
- Generalizing the two-letter alphabet to a subformula-closure signature — B1's business (Decision D-3).
- A backward Bool-fixture bridge, or any claim about `⊡(Pp)` — the exhibited undecided seam is forward-only (`Fp`) and says so; `pastStab_iff_allBwdPathsMeet` remains the only backward fixture result.
- E2's three-state falsifier fixture (separate record) and the mosaic route (734).
- Any complexity bound, upper or lower.
- Porting or `require`-ing anything from cslib.
- Edits under `.claude/**` (the report's two context-extension recommendations belong to a meta task; see `rules/source-store-deploy-boundary.md`).
- Re-pointing 735's description or spawning the B1-B3 successor task — task-management actions outside an implementation dispatch; the summary carries the recommendation verbatim.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| The landed `presentsMulti_seamTrace` is read, by 735 or a later reader, as "`Presents` discharged" — its `Bool` is `decide` under `open Classical` and computes nothing | H | M | Module docstring, the theorem-index row and the axiom-test header all state "hypothesis-free bridge over the realized set; `Hit` is not computed"; the wording is pinned beside the term so it cannot drift silently |
| The evidence probe re-declares `SeamDecided`/`exists_presents_iff`, duplicating the library and making `lean-challenge-snapshot.sh --check` report ambiguous resolution (it scans every `.lean` under the project, `specs/` included) | M | M | Decision D-6: the probe imports the library and cites; it declares only the fixture and the two fixture theorems. Verified this dispatch that Lean prefers a current-namespace declaration over a same-named opened one, so even an accidental duplicate would not break compilation — but the duplicate itself is what D-6 forbids |
| `#guard_msgs` expected text for the new pins wraps differently from the hand-typed line (the existing `plusStab_iff_seamSummary` pin is three-line-wrapped) | L | H | Copy the exact emitted text from the first red `lake build BimodalTest...` run into the `/-- info: ... -/` block; never hand-type the wrapping |
| C14 heredoc pair diverges (one side appended, the other not, or at different positions) | M | L | Append the matched pair at the same trailing position of `C14BASE` and `C14LEAN` in one edit; `check-module-invariants.sh` fails C14 loudly on any divergence |
| `lake-build-guard.sh build` replays a stale `env lean` result after the probe file is edited | L | H | Single-file recompiles pass `--no-share` (report issue log, reproduced in Phase 3's commands) |
| `FormalSystem.lean` root drifts from the module set after `SeamMulti.lean` is added (C33) | M | M | Regenerate with `lake exe mk_all --lib FormalSystem` in Phase 2 and commit the result |
| Unused-instance linter on `[F.IsRegular]` for the lemmas that do not use regularity (`stabTarget_seamTrace` needed `omit [F.IsRegular] in` in the probe) | L | H | Carry the probe's `omit` lines verbatim; add further `omit`s only where the linter fires |
| A reader takes the undecided-seam fixture as a claim about `⊡(Pp)` | M | L | The probe header and the README carried-limits bullet state the forward-only scope explicitly |
| The record corrections leave a stale "unformalized MSO reduction"/"discharges nothing" sentence somewhere | M | M | Phase 5 greps the tree for `unformalized MSO reduction`, `discharges nothing`, `Medium, not High` and `One family per summary` and visits every hit |
| Carried line counts in README tables go stale | L | H | Re-derive every `Lines` cell with `wc -l` at write time (carried-figure discipline) |

## Decisions

- **D-1 Outcome (b), not (a), stated as such.** The deliverable is the recorded, machine-checked
  verdict plus the corrected interface; no partial discharge is presented as more than it is. The
  summary and every docstring say which fields are discharged in which shape and what `Hit` is.
- **D-2 Library and probe split by content, not by Part number.** The research probe's Parts 1
  and 3 (characterization; corrected shape) are library content and land in `SeamMulti.lean`;
  Part 2 (the E2 fixture and its two theorems) is a design obstruction and lands in the evidence
  collection. The research's "verbatim" recommendation is honoured for the proof texts; the
  file split is this plan's.
- **D-3 Two-letter alphabet, verbatim; library names.** The library version is stated over the
  probe's `Bool` signature exactly as compiled (zero risk; the Mathlib-style generalization to a
  marker-plus-closure signature introduces `Fintype`/`DecidableEq` plumbing for a `PlusFormula`
  subtype and is B1's business). Unicode-free library names replace the probe's:

  | Probe | Library (`FormalSystem.Metalogic.Decidability.RaySummary`) |
  |---|---|
  | `sig2` | `twoLetter` (abbrev) |
  | `trace` | `seamTrace` |
  | `nowPhi`, `nowPhi_depth` | unchanged |
  | `Tφ` | `stabTarget` |
  | `Tφ_determined` | `stabTarget_determined` |
  | `Tφ_trace` | `stabTarget_seamTrace` |
  | `world` | `spliced` (abbrev) |
  | `Hit`, `hit_finite`, `plusStab_iff_forall_hit` | unchanged |
  | `PresentsMulti`, `plusStab_iff_presentsMulti` | unchanged |
  | `presentsMulti_trace` | `presentsMulti_seamTrace` |
  | `SeamDecided`, `seamDecided_of_presents`, `exists_presents_of_seamDecided`, `exists_presents_iff` | unchanged |
  | `determinedByKType_eval` | unchanged, in `FormalSystem.Metalogic.WeakCanonical` (Universal.lean) |

- **D-4 One new module, not an edit to `Seam.lean`.** `Seam.lean`'s declarations are pinned and
  cited; its only edits are prose. `SeamMulti.lean` imports it and is imported by the
  `RaySummary.lean` aggregator.
- **D-5 Pins and the ledger.** Five `#guard_msgs` pins in `KTypeSummaryAxiomTest.lean`
  (`determinedByKType_eval`, `exists_presents_iff`, `plusStab_iff_forall_hit`,
  `plusStab_iff_presentsMulti`, `presentsMulti_seamTrace`); one theorem-index row, for
  `plusStab_iff_forall_hit` only, which therefore also enters the C14 baseline pair and carries a
  `Paper: — (reason)` docstring line (C15's second assertion).
- **D-6 The probe cites, never re-declares.** `presents-is-seam-decidedness.lean` in the
  collection imports `FormalSystem`, uses the library's `SeamDecided` and
  `seamDecided_of_presents`, and declares only the fixture (`Rg`, `Fg`, `Mg`, `pa`, `Fp`,
  `stayA`, `jumpB`, their state lemmas, `not_Fp_stayA`, `Fp_jumpB`) and the two obstruction
  theorems `seam_undecided`, `no_presents_on_fixture`. The 330-line research probe stays in
  `probes/` untouched as the research record.
- **D-7 No `user_decision`.** Every choice above is routine engineering; the successor-record
  question is a recommendation for the summary, not a gate.

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |

Phases within the same wave can execute in parallel. This plan is fully sequential: Phases 2
and 3 touch disjoint files but share one working tree and one Lake build, and Phase 3's probe
imports Phase 2's module. Dispatch singly (contention with 733/734 on
`scripts/check-evidence-probes.sh` stands, per the report).

### Phase 1: Field (3) — `determinedByKType_eval` beside its special case [COMPLETED]

**Goal**: Land the depth-at-most-k generalization of `determinedByKType_nfEval` in
`KTypeSummary/Universal.lean`, discharging field (3) `determined` for every sentence target, and
record it in the module docstring and the cluster README.

**Tasks**:
- [x] Re-verify by name (never by line) the anchors this phase builds on: `DeterminedByKType`,
      `determinedByKType_nfEval` (Universal.lean), `doets_lemma_1_1` (Expressiveness/NormalForm.lean),
      `kTypeOf` (WeakCanonical/NEquivalence.lean), `eval`/`quantifierDepth` (Expressiveness/MonadicFO.lean),
      `zFiber` (GroupModel/BlockDecomposition.lean). Confirm `Universal.lean`'s import closure
      already reaches `doets_lemma_1_1`; if not, add the one import.
- [x] Add `determinedByKType_eval` immediately after `determinedByKType_nfEval`, statement
      exactly as pinned under Lean Challenge Statements (namespace
      `FormalSystem.Metalogic.WeakCanonical`), proof as the probe's: `intro c c' h`, then
      `doets_lemma_1_1 k 0 ψ hψ (zFiber sig c) (zFiber sig c') Fin.elim0 Fin.elim0` on the
      `nf`-pointwise hypothesis obtained by `unfold kTypeOf at h; congr_fun h nf; simp only
      [decide_eq_decide]`. Docstring: "a depth-`≤ k` sentence target is `k`-type-determined
      (Doets 1989, Lemma 1.1); `determinedByKType_nfEval` is its normal-form instance".
- [x] Update `Universal.lean`'s module docstring: the "non-vacuous" paragraph and the "Main
      definitions and results" list gain the new lemma; keep the paragraph that says the module
      is not about `⊡` (still true of this module).
- [x] Update `KTypeSummary/README.md`: the `Universal.lean` row (re-derived line count, new
      lemma named) only — the cluster-level prose corrections wait for Phase 5.
- [x] `lean_verify FormalSystem.Metalogic.WeakCanonical.determinedByKType_eval` reports
      `[propext, Classical.choice, Quot.sound]`, no sorry.
- [x] Guarded scoped build: `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 --
      build FormalSystem.Metalogic.WeakCanonical.KTypeSummary.Universal` (detached), exit 0.
- [x] Commit (`task 737 phase 1: ...`) via `git-commit-scoped.sh` with the two files staged
      explicitly.

**Timing**: 1 hour

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: One ~12-line theorem plus two docstring edits; no existing declaration
changes. Confirm by `git diff --stat` showing only the two files below and no hunk inside an
existing proof. The carried figure "9 lines" (report, Findings) is re-derived at write time.

**Files to modify**:
- `FormalSystem/Metalogic/WeakCanonical/KTypeSummary/Universal.lean` - new theorem `determinedByKType_eval`, docstring additions
- `FormalSystem/Metalogic/WeakCanonical/KTypeSummary/README.md` - `Universal.lean` row (line count, new lemma)

**Verification**:
- `lean_verify` on the new name: standard profile, no `sorryAx`.
- Scoped guarded build exits 0; `readme-lint.sh` reports no new finding for the cluster.

---

### Phase 2: The corrected interface — `RaySummary/SeamMulti.lean` [COMPLETED]

**Goal**: Land the characterization of the single-family bundle and the two-letter corrected
interface as a new library module, wired into the aggregator and the generated root, with the
degeneracy and the residue stated in the docstrings — and `Hit` named as not computed.

**Tasks**:
- [x] Create `FormalSystem/Metalogic/Decidability/RaySummary/SeamMulti.lean` with the copyright
      header, `import FormalSystem.Metalogic.Decidability.RaySummary.Seam` (plus whatever
      `Seam.lean`'s closure does not already reach — the probe compiled under `import
      FormalSystem`, so confirm `doets_lemma_1_1`, `SeqPair`, `seamOmegaEquiv`,
      `plusStab_iff_omega`, `PlusTruth.neg_iff` all resolve; add the minimal imports otherwise),
      the same `open` lines as `Seam.lean`, and namespace
      `FormalSystem.Metalogic.Decidability.RaySummary`.
- [x] Section 1, the characterization: `SeamDecided` (definition body
      `PlusTruthAt M τ t (.stab φ) ∨ PlusTruthAt M τ t (.stab φ.neg)`),
      `seamDecided_of_presents`, `exists_presents_of_seamDecided`, `exists_presents_iff` —
      statements exactly as pinned under Lean Challenge Statements, proofs the probe's Part 1
      verbatim.
- [x] Section 2, the two-letter interface, in this order so the preamble precedes every
      theorem: `twoLetter` (abbrev `⟨Bool⟩`) with its two `inferInstanceAs` instances,
      `spliced` (abbrev), then `seamTrace` (body `fun (p : Bool) z => bif p then z = t else
      PlusTruthAt M σ z φ`), `nowPhi` (body `.ex (.and (.atom true 0) (.atom false 0))`),
      `nowPhi_depth` (`rfl`), `stabTarget` (body `fun c => eval (zFiber twoLetter c) Fin.elim0
      nowPhi`), `stabTarget_determined (k) (hk : 1 ≤ k) : DeterminedByKType twoLetter k
      stabTarget`, `stabTarget_seamTrace` (with `omit [F.IsRegular] in`), `Hit` (body the
      probe's set-builder over `SeqPair F (τ.state t)` and `InFamily`), `hit_finite`,
      `plusStab_iff_forall_hit` — the last three exactly as pinned; proofs the probe's Part 3
      verbatim under the D-3 renames.
- [x] Section 3, the multi-family bundle, statements verbatim from the probe (not pinned under
      Lean Challenge Statements because `PresentsMulti` is a `structure`; see the plan-format
      precedent in the substrate plan's D-14):

      ```lean
      structure PresentsMulti (M : TaskModel F.toTaskFrame) (τ : WorldHistory F.toTaskFrame) (t : ℤ)
          (φ : PlusFormula) (sig : MonadicSignature) [Fintype sig.preds] [DecidableEq sig.preds]
          (k : ℕ) (T : (sig.preds → ℤ → Prop) → Prop)
          (hit : Set (KType sig k × KType sig k × KType sig k)) (holds : Bool) : Prop where
        colours : ∀ bf : SeqPair F (τ.state t), ∃ c : sig.preds → ℤ → Prop, ∃ tr ∈ hit,
          InFamily sig k tr.1 tr.2.1 tr.2.2 c ∧
            (PlusTruthAt M ((seamOmegaEquiv t (τ.state t)).symm bf).1 t φ ↔ T c)
        determined : DeterminedByKType sig k T
        realized : ∀ tr ∈ hit, ∃ c : sig.preds → ℤ → Prop, InFamily sig k tr.1 tr.2.1 tr.2.2 c ∧
          ∃ bf : SeqPair F (τ.state t),
            (PlusTruthAt M ((seamOmegaEquiv t (τ.state t)).symm bf).1 t φ ↔ T c)
        verdict : holds = true ↔ ∀ tr ∈ hit, ∃ c, InFamily sig k tr.1 tr.2.1 tr.2.2 c ∧ T c

      theorem plusStab_iff_presentsMulti {M : TaskModel F.toTaskFrame} {τ : WorldHistory F.toTaskFrame}
          {t : ℤ} {φ : PlusFormula} {sig : MonadicSignature} [Fintype sig.preds]
          [DecidableEq sig.preds] {k : ℕ} {T : (sig.preds → ℤ → Prop) → Prop}
          {hit : Set (KType sig k × KType sig k × KType sig k)} {holds : Bool}
          (h : PresentsMulti M τ t φ sig k T hit holds) :
          PlusTruthAt M τ t (.stab φ) ↔ holds = true

      open Classical in
      theorem presentsMulti_seamTrace (M : TaskModel F.toTaskFrame) (τ : WorldHistory F.toTaskFrame)
          (t : ℤ) (φ : PlusFormula) (k : ℕ) (hk : 1 ≤ k) :
          PresentsMulti M τ t φ twoLetter k stabTarget (Hit M τ t φ k)
            (decide (PlusTruthAt M τ t (.stab φ)))
      ```

      `open Classical in` precedes the docstring (the probe's parse lesson); the `verdict`
      field is proved by `rw [decide_eq_true_iff, plusStab_iff_forall_hit ...]` as in the probe.
- [x] Module docstring, structured as `Seam.lean`'s: (a) what is established — the
      characterization, the fixture pointer to the evidence probe, the hypothesis-free bridge,
      the inhabited multi-family bundle; (b) **what is NOT established**: `Hit` is semantic and
      not computed, `presentsMulti_seamTrace`'s `Bool` is `decide` under `open Classical`, no
      decision procedure, no decidability result, no complexity bound, the exhibited undecided
      seam is forward-only and no backward Bool-fixture bridge exists; (c) the residue named:
      computing `Hit` is the realizability direction (HWZ 2000 Def 12 / Thm 14 with the
      one-sided-liveness repair) and effective `k`-type composition, B1-B3 of the research
      report, then the quantification over models, B4; (d) references (HWZ 2000; GKWZ 2003;
      Thomas 1997 §5.1; Doets 1989 §1), same citation keys as `Seam.lean`. Every theorem
      docstring names what it uses; `plusStab_iff_forall_hit`'s docstring ends with the line
      `Paper: — (the formalization's own seam interface; the paper has no counterpart)` so C15's
      second assertion passes once the theorem-index row lands in Phase 4.
- [x] No `#print axioms`, `#check` or `#eval` in the module (C27 allow-list); profiles are
      measured in Phase 4's test file.
- [x] `RaySummary.lean`: add `import FormalSystem.Metalogic.Decidability.RaySummary.SeamMulti`
      and a `RaySummary.SeamMulti` bullet under `## Modules`; the sentence "stated against the
      hypothesis bundle `Presents` and discharging nothing" is rewritten in Phase 5.
- [x] Regenerate the library root: `lake exe mk_all --lib FormalSystem` (through the guard:
      `bash .claude/scripts/lake-build-guard.sh build --timeout 600 -- exe mk_all --lib
      FormalSystem`), confirm the diff to `FormalSystem.lean` is exactly one new sorted import.
      *(deviation: altered — the `INV` gate of `check-module-invariants.sh --no-build` then
      reported three stale generated inventory blocks (`README.md`, `FormalSystem/README.md`,
      `FormalSystem/Metalogic/README.md`) because the file/line counts moved; regenerated with
      `--emit-inventory` and committed with this phase — three generated-block files beyond the
      Scope Hypothesis's three)*
- [x] `lean_verify` on `exists_presents_iff`, `plusStab_iff_forall_hit`,
      `plusStab_iff_presentsMulti`, `presentsMulti_seamTrace` (fully qualified): standard
      profile, no `sorryAx`.
- [x] Guarded scoped build of `FormalSystem.Metalogic.Decidability.RaySummary` (detached), exit
      0; then `bash scripts/check-module-invariants.sh --no-build` for the structural checks
      (C33 root, README presence, C27).
- [x] Commit per green sub-step: section 1 green, sections 2-3 green, aggregator + root.

**Timing**: 2 hours

**Depends on**: 1

**Verification Tier**: interface

**Scope Hypothesis**: One new module of roughly 260 lines (the probe's Parts 1 and 3 are 69 +
142 lines of code plus the docstring), one import line in the aggregator, one import line in
the generated root. Confirm by `wc -l` on the new file and `git diff --stat`; if the module
needs more than one additional import beyond `Seam`, record which in the summary (the
closure measurement the report carries is for `Segment.lean`, not for this module).

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/SeamMulti.lean` - new module: characterization, two-letter interface, hypothesis-free bridge, multi-family bundle
- `FormalSystem/Metalogic/Decidability/RaySummary.lean` - import and Modules bullet
- `FormalSystem.lean` - regenerated root (one sorted import, C33)

**Verification**:
- The four `lean_verify` calls above report `[propext, Classical.choice, Quot.sound]`.
- `grep -c sorry FormalSystem/Metalogic/Decidability/RaySummary/SeamMulti.lean` is 0.
- `bash .claude/scripts/lean-challenge-snapshot.sh --check 737 .` (advisory) reports no drift
  for the 11 pinned identifiers once a snapshot exists; if no snapshot was taken before
  implementation, run `--dry-run` and confirm the identifier sets agree.
- Scoped guarded build exits 0; `check-module-invariants.sh --no-build` exits 0.

---

### Phase 3: The fixture obstruction in the evidence collection [COMPLETED]

**Goal**: Land the undecided E2 seam and `no_presents_on_fixture` as a tracked, wired evidence
probe that cites the library's characterization, so the obstruction to field (1) in the landed
shape is held in place by the collection gate.

**Tasks**:
- [x] Create `specs/evidence/seam-gluing-ray-product/presents-is-seam-decidedness.lean`,
      namespace `Probe737Presents`, `import FormalSystem`, the same `open` lines as the research
      probe **plus** `open FormalSystem.Metalogic.Decidability.RaySummary` so `SeamDecided`,
      `seamDecided_of_presents` and `Presents` resolve to the library (Decision D-6). Content:
      the research probe's Part 2 verbatim (`Rg`, `Rg_fwd`, `Rg_bwd`, `Fg`, its `IsRegular`
      instance via `FrameOver.ofSlicedStep_isRegular`, `pa`, `Mg`, `Fp`, `stayA`, `jumpB`,
      `stayA_state`, `stayA_state_t`, `jumpB_state`, `jumpB_state_t`, `jumpB_state_succ`,
      `not_Fp_stayA`, `Fp_jumpB`, `seam_undecided`, `no_presents_on_fixture`), with
      `seam_undecided`'s statement now `¬ SeamDecided Mg (stayA c t) t Fp` against the library
      definition and `no_presents_on_fixture` proved by `seamDecided_of_presents` from the
      library. Follow with `#check` citations of `exists_presents_iff`,
      `plusStab_iff_forall_hit` and `presentsMulti_seamTrace` (cited, as the substrate probe
      cites `plusStab_iff_seamSummary`) and a `#print axioms` foot for `seam_undecided` and
      `no_presents_on_fixture`.
- [x] Header in the collection's form: **What is established** (1. the seam `(stayA c t, t)` is
      undecided on `Fp` — `stayA` refutes, `jumpB` satisfies, both through `(c, a)`; 2. no
      `Presents` inhabitant at that seam for any `sig`, `k`, `T`, `S`, by the library's
      `seamDecided_of_presents`; 3. the fixture is E2's, transcribed, never imported), **What is
      NOT established** (nothing about `⊡(Pp)` — forward-only; no claim that `Hit` is computable;
      no decidability, no complexity bound; the characterization itself is the library's
      `exists_presents_iff`, cited not re-proved), **Axiom record** (both theorems
      `[propext, Classical.choice, Quot.sound]`, no `sorryAx`), **Compile line** (`lake env lean
      specs/evidence/seam-gluing-ray-product/presents-is-seam-decidedness.lean`, wired).
- [x] `scripts/check-evidence-probes.sh`: append
      `"seam-gluing-ray-product/presents-is-seam-decidedness"` to `WIRED` and a doc-block row in
      the table above it, in the collection's column format, naming the decision it holds in
      place: the single-family `Presents` is seam decidedness, so no decidability result may be
      assembled on `plusStab_iff_seamSummary` as if `colours` were the MSO reduction — the
      consumer must go through `Hit`.
- [x] Elaborate the probe once with `bash .claude/scripts/lake-build-guard.sh build --no-share
      --timeout 900 -- env lean specs/evidence/seam-gluing-ray-product/presents-is-seam-decidedness.lean`
      and read the `#print axioms` foot; then `bash scripts/check-evidence-probes.sh` must
      report `PASS  all 17 wired probe(s) compile`.
- [x] Leave `specs/737_.../probes/presents-is-seam-decidedness.lean` and its compile log
      untouched (research record).
- [x] Commit: the probe and the gate script, staged explicitly.

**Timing**: 1.5 hours

**Depends on**: 2

**Verification Tier**: local

**Scope Hypothesis**: Roughly 120 lines (Part 2's 88 lines plus the header and citations); the
collection grows from 16 to 17 `WIRED` entries. Confirm the count in the gate's PASS line.

**Files to modify**:
- `specs/evidence/seam-gluing-ray-product/presents-is-seam-decidedness.lean` - new probe: the E2 fixture, `seam_undecided`, `no_presents_on_fixture`, citations
- `scripts/check-evidence-probes.sh` - `WIRED` entry and doc-block row

**Verification**:
- `bash scripts/check-evidence-probes.sh` exits 0 with 17/17.
- `grep -c sorry` on the probe is 0; the `#print axioms` foot shows the standard profile for
  both theorems.
- `grep -n "def SeamDecided\|theorem exists_presents_iff" specs/evidence/seam-gluing-ray-product/presents-is-seam-decidedness.lean`
  returns nothing (D-6: cited, not re-declared).

---

### Phase 4: Pins, the C14 baseline pair, and the theorem-index row [COMPLETED]

**Goal**: Pin the new headline profiles in the invariants harness, extend the C14 baseline for
the one theorem that enters the ledger, and add that ledger row — so every claim this record
makes about axioms is machine-asserted on every build.

**Tasks**:
- [x] `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean`: after the
      `plusStab_iff_seamSummary` block, add five `#guard_msgs in #print axioms` rows for
      `FormalSystem.Metalogic.WeakCanonical.determinedByKType_eval`,
      `FormalSystem.Metalogic.Decidability.RaySummary.exists_presents_iff`,
      `...RaySummary.plusStab_iff_forall_hit`, `...RaySummary.plusStab_iff_presentsMulti`,
      `...RaySummary.presentsMulti_seamTrace`, each with a short section comment on the pattern
      of the existing rows; copy the expected `info:` text verbatim from the first (red) run's
      output, including its line wrapping. Update the header's "What is pinned" table (five rows,
      chain step "—" / "seam interface") and rewrite the "What this does **not** pin" paragraph:
      *(deviation: altered — the first run was green: the wrapping was derived from Lean's
      120-column format width (the 120-character `determinedByKType_eval` line unwrapped, the
      four longer lines wrapped as the existing rows are) and every guard matched on the first
      build; only the two header-table rows had to be shortened for the 100-column linter)*
      it currently says no reduction from a `⊡` fibre condition to a `k`-type-determined target
      exists in Lean anywhere — now say the bridge over the realized set is hypothesis-free
      (`plusStab_iff_forall_hit`) but `Hit` is not computed and `presentsMulti_seamTrace`'s
      `Bool` is classical, so a green build still certifies profiles, not adequacy and not
      decidability.
- [x] `scripts/check-module-invariants.sh`: append the matched pair for
      `FormalSystem.Metalogic.Decidability.RaySummary.plusStab_iff_forall_hit` at the trailing
      position of both `C14BASE` (the `'...' depends on axioms: [propext, Classical.choice,
      Quot.sound]` line) and `C14LEAN` (the `#print axioms ...` line); update the comment block
      above them ("The final four lines ..." becomes five, naming the new declaration and its
      theorem-index row).
- [x] `docs/theorem-index.md`, Decidability table, appended as the last row: Paper label `—`;
      Statement "`⊡φ` at a seam of a regular ℤ-frame is a finite conjunction over the realized
      family triples of the two-letter trace — the hypothesis-free `⊡` bridge; `Hit` is not
      computed"; Lean name fully qualified; File
      `FormalSystem/Metalogic/Decidability/RaySummary/SeamMulti.lean`; Frame class `ZTime`;
      Axioms `pcq pinned:C14`.
- [x] Guarded scoped build of `BimodalTest.Metalogic.KTypeSummaryAxiomTest` (detached), exit 0
      with all guards matching.
- [x] `bash scripts/check-module-invariants.sh` (full, with build): C14 passes with the new
      line, C15's second assertion passes (the `Paper: —` line landed in Phase 2), C21/C27/C33
      unchanged.
- [x] Commit per green sub-step: the test file; the harness pair + the ledger row together
      (they are one assertion).

**Timing**: 1.5 hours

**Depends on**: 3

**Verification Tier**: full

**Scope Hypothesis**: Five pins, one matched C14 pair, one ledger row; the pin count in the test
file goes from 11 to 16 (the carried "eleven" is from the task description and the test header —
re-count `grep -c '#print axioms'` at write time and correct the README/ROADMAP sentences that
quote eleven in Phase 5).

**Files to modify**:
- `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` - five pins, header table, "does not pin" paragraph
- `scripts/check-module-invariants.sh` - C14 baseline pair, one matched line each, comment block
- `docs/theorem-index.md` - one Decidability row for `plusStab_iff_forall_hit`

**Verification**:
- `bash scripts/check-module-invariants.sh` exits 0 (the complete gate set this repository
  aggregates: C1-C36 including C2/C14 axiom baselines, C15 ledger anchoring, C27 debug
  directives, C33 root).
- `lake build BimodalTest.Metalogic.KTypeSummaryAxiomTest` (guarded) exits 0 with no
  `#guard_msgs` mismatch.
- `bash scripts/check-evidence-probes.sh` still 17/17.

---

### Phase 5: Correct the record, name the residue, close out [NOT STARTED]

**Goal**: Replace every sentence in the tree that calls `Presents.colours` the unformalized MSO
reduction (or calls the interface "discharging nothing" without the characterization) with the
finding; record the B1-B4 residue in the ROADMAP; run the full gate set; write the summary.

**Tasks**:
- [ ] Sweep: `grep -rn "unformalized MSO reduction\|discharges nothing\|Medium, not High\|One family per summary\|the reduction is the hypothesis" FormalSystem/ docs/ Tests/ specs/ROADMAP.md`
      and visit every hit below; re-run at the end and justify any survivor in the summary.
- [ ] `Seam.lean` (prose only — no statement changes; the file's declarations stay pinned):
      point (c) of the module docstring rewritten — the single-family bundle is inhabited iff the
      seam is decided (`exists_presents_iff`, `SeamMulti.lean`), so `colours` in this shape is a
      seam condition, not the reduction; the multi-family shape is the interface and the
      reduction's content is `Hit`; the "Medium, not High" confidence sentence replaced by the
      pointer. `Presents`'s `colours` bullet and `plusStab_iff_seamSummary`'s closing sentence
      ("the reduction is the hypothesis `colours`") gain the same pointer. Point (f) notes that
      discharging the landed bundle for a concrete frame is exactly deciding the seam.
- [ ] `RaySummary/README.md`: the file table (two rows, line counts re-derived); "What it does
      not do" rewritten (the characterization; `Hit` not computed; no decision procedure, no
      decidability, no complexity bound; two-letter alphabet, closure is B1); "Evidence" gains
      the new probe; "Two carried limits" keep the backward limit and replace limit 2's
      Medium-confidence sentence with the characterization; "Last verified" date.
- [ ] `RaySummary.lean` aggregator docstring: the "discharging nothing" sentence rewritten to
      the two-module description.
- [ ] `KTypeSummary/README.md`: "What this cluster does not give you" first bullet (the seam
      interface no longer "carries it as a hypothesis field and discharges nothing" — it
      characterizes the single-family bundle and states the hypothesis-free bridge; `Hit` is
      the residue), "Two carried limits" item 2, "The consumer relation" sentence, the pin
      count in "Evidence"/consumer prose, "Last verified".
- [ ] `FormalSystem/Metalogic/Decidability/README.md`: the `RaySummary/` row — "(1 file)" to
      "(2 files)", description updated; `FormalSystem/Metalogic/Decidability.lean`: the
      `RaySummary` bullet of the module docstring likewise.
- [ ] `specs/ROADMAP.md` Phase 1: mark the 737 bullet `- [x]` with the completion annotation
      `*(Completed: Task 737, {DATE})*` and a two-sentence outcome-(b) record (the single-family
      bundle is seam decidedness — `exists_presents_iff`, `no_presents_on_fixture`; the
      hypothesis-free bridge `plusStab_iff_forall_hit` over `Hit`; `Hit` uncomputed); insert
      immediately before the 735 bullet a new unchecked bullet naming the residue B1-B3
      (closure alphabet and local run conditions; realizability — HWZ Def 12 / Thm 14 with the
      one-sided-liveness repair, 711's dropped D2-D5 in trace form; effective `k`-type
      composition) as the gap between this record and the assembly, with B4 named as 735's own
      frame; do not mark or edit the 735 bullet beyond that insertion.
- [ ] `bash scripts/check-phantom-citations.sh` exits 0 (every new backticked name resolves);
      `bash scripts/readme-lint.sh` reports no new gated finding.
- [ ] Final gates: full guarded `lake build` (detached, `--timeout 1800`); `bash
      scripts/check-module-invariants.sh` exit 0; `bash scripts/check-evidence-probes.sh` 17/17;
      guarded `lake build BimodalTest`; re-run the sweep grep.
- [ ] Write `summaries/01_discharge-presents-verdict-summary.md`: the field-by-field table
      (landed shape vs corrected shape) from the report, what was landed where, the axiom
      profiles as measured, the residue B1-B4 with the report's cost table carried as
      `CARRIED-UNVERIFIED`, the recommendation to spawn a successor lean4 record for B1-B3 and to
      re-point 735 at `Hit`/`plusStab_iff_forall_hit`, and the two inherited limits unchanged.
- [ ] Commit per green sub-step (library prose; READMEs/aggregators; ROADMAP; summary).

**Timing**: 2 hours

**Depends on**: 4

**Verification Tier**: prose

**Scope Hypothesis**: Seven prose files (listed below) and no code change; every hunk lies inside
a comment, docstring or markdown region. Confirm by `git diff` read-through and by the scoped
Lean builds of `RaySummary` and `KTypeSummary.Universal` still passing (a docstring edit that
crosses a comment boundary would turn them red).

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/Seam.lean` - docstring corrections only (point (c), `colours` bullet, bridge docstring, point (f))
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md` - table, "What it does not do", Evidence, carried limits, date
- `FormalSystem/Metalogic/Decidability/RaySummary.lean` - aggregator docstring
- `FormalSystem/Metalogic/WeakCanonical/KTypeSummary/README.md` - "does not give you", carried limit 2, consumer relation, pin count, date
- `FormalSystem/Metalogic/Decidability/README.md` - `RaySummary/` row
- `FormalSystem/Metalogic/Decidability.lean` - `RaySummary` docstring bullet
- `specs/ROADMAP.md` - 737 bullet marked with outcome (b); residue bullet inserted before 735

**Verification**:
- The sweep grep returns no unjustified hit; `check-phantom-citations.sh` and `readme-lint.sh`
  are clean.
- Full guarded `lake build`, `check-module-invariants.sh`, `check-evidence-probes.sh` and the
  `BimodalTest` build all exit 0.
- The summary exists and names every file touched and every profile measured.

## Lean Challenge Statements

The eleven declarations this plan commits to, with bodies `sorry` by this section's rule. The
block type-checked standalone against the tree at plan time (eleven `declaration uses sorry`
warnings, exit 0). All eleven are placed in one namespace so the block survives the snapshot
tool's body-forcing (which drops everything after a declaration's `:=` up to the next
declaration, `end`/`namespace` lines included); the preamble — opens, the `twoLetter` abbrev with
its instances, the `[F.IsRegular]` variable and the `spliced` abbrev — therefore sits before the
first pinned declaration. `determinedByKType_eval`'s library home is
`FormalSystem.Metalogic.WeakCanonical` (`KTypeSummary/Universal.lean`, Phase 1); its namespace
here is a pinning artefact, and the drift check is keyed on the base identifier. The
`PresentsMulti` family is specified verbatim in Phase 2 instead (a `structure` cannot be pinned
by this section; the substrate plan's D-14 is the precedent).

```lean
import FormalSystem

open FormalSystem.Syntax FormalSystem.Semantics FormalSystem.PlusLanguage
open FormalSystem.PlusLanguage.PlusFormula
open FormalSystem.Metalogic.WeakCanonical FormalSystem.Metalogic.Expressiveness

namespace FormalSystem.Metalogic.Decidability.RaySummary

/-- Two letters: `true` is the seam marker `now`, `false` is `φ`. -/
abbrev twoLetter : MonadicSignature := ⟨Bool⟩

instance : Fintype twoLetter.preds := inferInstanceAs (Fintype Bool)
instance : DecidableEq twoLetter.preds := inferInstanceAs (DecidableEq Bool)

variable {F : FrameOver intOrder} [F.IsRegular]

/-- The spliced history of a ray pair. -/
abbrev spliced (τ : WorldHistory F.toTaskFrame) (t : ℤ) (bf : SeqPair F (τ.state t)) :
    WorldHistory F.toTaskFrame :=
  ((seamOmegaEquiv t (τ.state t)).symm bf).1

theorem determinedByKType_eval (sig : MonadicSignature) (k : ℕ) (ψ : MonadicFormula sig 0)
    (hψ : ψ.quantifierDepth ≤ k) :
    DeterminedByKType sig k (fun c => eval (zFiber sig c) Fin.elim0 ψ) := sorry

def SeamDecided (M : TaskModel F.toTaskFrame) (τ : WorldHistory F.toTaskFrame) (t : ℤ)
    (φ : PlusFormula) : Prop := sorry

theorem seamDecided_of_presents {M : TaskModel F.toTaskFrame} {τ : WorldHistory F.toTaskFrame}
    {t : ℤ} {φ : PlusFormula} {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] {k : ℕ} {T : (sig.preds → ℤ → Prop) → Prop} {S : SeamSummary sig k}
    (h : Presents M τ t φ sig k T S) : SeamDecided M τ t φ := sorry

theorem exists_presents_of_seamDecided {M : TaskModel F.toTaskFrame}
    {τ : WorldHistory F.toTaskFrame} {t : ℤ} {φ : PlusFormula} (hdec : SeamDecided M τ t φ)
    (sig : MonadicSignature) [Fintype sig.preds] [DecidableEq sig.preds] (k : ℕ) :
    ∃ (T : (sig.preds → ℤ → Prop) → Prop) (S : SeamSummary sig k),
      Presents M τ t φ sig k T S := sorry

theorem exists_presents_iff {M : TaskModel F.toTaskFrame} {τ : WorldHistory F.toTaskFrame}
    {t : ℤ} {φ : PlusFormula} (sig : MonadicSignature) [Fintype sig.preds]
    [DecidableEq sig.preds] (k : ℕ) :
    (∃ (T : (sig.preds → ℤ → Prop) → Prop) (S : SeamSummary sig k),
      Presents M τ t φ sig k T S) ↔ SeamDecided M τ t φ := sorry

def seamTrace (M : TaskModel F.toTaskFrame) (φ : PlusFormula) (t : ℤ)
    (σ : WorldHistory F.toTaskFrame) : twoLetter.preds → ℤ → Prop := sorry

def nowPhi : MonadicFormula twoLetter 0 := sorry

def stabTarget : (twoLetter.preds → ℤ → Prop) → Prop := sorry

def Hit (M : TaskModel F.toTaskFrame) (τ : WorldHistory F.toTaskFrame) (t : ℤ)
    (φ : PlusFormula) (k : ℕ) :
    Set (KType twoLetter k × KType twoLetter k × KType twoLetter k) := sorry

theorem hit_finite (M : TaskModel F.toTaskFrame) (τ : WorldHistory F.toTaskFrame) (t : ℤ)
    (φ : PlusFormula) (k : ℕ) : (Hit M τ t φ k).Finite := sorry

theorem plusStab_iff_forall_hit (M : TaskModel F.toTaskFrame) (τ : WorldHistory F.toTaskFrame)
    (t : ℤ) (φ : PlusFormula) (k : ℕ) (hk : 1 ≤ k) :
    PlusTruthAt M τ t (.stab φ) ↔
      ∀ tr ∈ Hit M τ t φ k, ∀ c, InFamily twoLetter k tr.1 tr.2.1 tr.2.2 c → stabTarget c := sorry

end FormalSystem.Metalogic.Decidability.RaySummary
```

The definition bodies the implementer lands (Phase 2) are the probe's: `SeamDecided` is
`PlusTruthAt M τ t (.stab φ) ∨ PlusTruthAt M τ t (.stab φ.neg)`; `seamTrace` is
`fun (p : Bool) z => bif p then z = t else PlusTruthAt M σ z φ`; `nowPhi` is
`.ex (.and (.atom true 0) (.atom false 0))`; `stabTarget` is
`fun c => eval (zFiber twoLetter c) Fin.elim0 nowPhi`; `Hit` is
`{tr | ∃ bf : SeqPair F (τ.state t), InFamily twoLetter k tr.1 tr.2.1 tr.2.2 (seamTrace M φ t (spliced τ t bf))}`.

## Literature Proof Structure

Carried from the research report's step map (HWZ 2000 §3 Defs 10-12 / Thm 14, read directly
there; GKWZ 2003 Lemma 11.23 / Thm 1.28 / Thm 13.6 and Thomas 1997 §5.1 carried from 711's
report; the (c)/(d) shared-core check is settled and is not re-run here):

1. Trace of a history = the set of subformulas true at each time (HWZ Thm 14 proof) →
   `seamTrace` (two letters; B1 widens to the closure).
2. Realized types per time, every type realized by a run (HWZ Def 12, second clause) → `Hit`
   and the corrected `realized` field.
3. Universal over histories ⟺ conjunction over realized types (Thm 14 `⇒`, read at the seam)
   → `plusStab_iff_forall_hit`.
4. Complementation/saturation making the conjunction finite (Thomas p. 30) →
   `family_saturation`, `finite_family_triples` (landed; used, not re-proved).
5. Deciding quasimodel existence (HWZ Thm 15 / GKWZ 1.28) → **blocked** under zero-debt; the
   `k`-type analogue is B3-B4 and is out of scope here.

Literature fidelity: steps 1-4 are transcribed as the probe proved them; no `simp`/`omega`/
`aesop` bypasses a step the source handles explicitly (the only automation is `ring`/`omega`
on the fixture's integer arithmetic, as in E2).

## Testing & Validation

- [ ] `lean_verify` on all 11 Challenge identifiers plus `plusStab_iff_presentsMulti`,
      `presentsMulti_seamTrace`, `seam_undecided`, `no_presents_on_fixture`: each
      `[propext, Classical.choice, Quot.sound]`, no `sorryAx`.
- [ ] `grep -c sorry` is 0 over `SeamMulti.lean`, the Universal.lean diff and the probe.
- [ ] Guarded scoped builds after Phases 1, 2, 4; guarded full `lake build` and `lake build
      BimodalTest` at close-out; all exit 0.
- [ ] `bash scripts/check-module-invariants.sh` exits 0 (C14 with the new matched pair; C15's
      second assertion with the `Paper: —` line; C27 with no new directive in library code; C33
      with the regenerated root).
- [ ] `bash scripts/check-evidence-probes.sh` reports 17/17.
- [ ] `bash scripts/check-phantom-citations.sh` and `bash scripts/readme-lint.sh` clean.
- [ ] `bash .claude/scripts/lean-challenge-snapshot.sh --dry-run 737 .` (before implementation)
      and `--check 737 .` (after, advisory) agree on the 11-identifier set with no drift.
- [ ] The sweep grep of Phase 5 returns no unjustified survivor.
- [ ] No file under this plan's scope introduces a finite-fibre or finite-width assumption, an
      unconditional (non-`[F.IsRegular]`) statement, or a complexity claim — checked by reading
      every new docstring and statement.

## Artifacts & Outputs

- `FormalSystem/Metalogic/WeakCanonical/KTypeSummary/Universal.lean` — `determinedByKType_eval`
- `FormalSystem/Metalogic/Decidability/RaySummary/SeamMulti.lean` — new module (characterization, two-letter interface, hypothesis-free bridge, `PresentsMulti`)
- `FormalSystem/Metalogic/Decidability/RaySummary.lean`, `FormalSystem.lean` — wiring
- `specs/evidence/seam-gluing-ray-product/presents-is-seam-decidedness.lean` — wired probe (fixture obstruction)
- `scripts/check-evidence-probes.sh` — 17th `WIRED` entry
- `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` — five pins
- `scripts/check-module-invariants.sh` — C14 matched pair
- `docs/theorem-index.md` — one Decidability row
- `FormalSystem/Metalogic/Decidability/RaySummary/{Seam.lean,README.md}`, `FormalSystem/Metalogic/WeakCanonical/KTypeSummary/README.md`, `FormalSystem/Metalogic/Decidability/{README.md,Decidability.lean}` — record corrections
- `specs/ROADMAP.md` — 737 bullet closed under outcome (b); B1-B3 residue bullet
- `specs/737_discharge_presents_mso_reduction_seam_summary/summaries/01_discharge-presents-verdict-summary.md`

## Rollback/Contingency

- Every phase is additive (new theorem, new module, new probe, new pins, new row) or prose-only;
  nothing pinned today is restated or removed, so a phase that fails to go green is reverted by
  not committing it — the Commit-Per-Green-Substep mandate keeps each committed state green.
- If `SeamMulti.lean` does not elaborate under `Seam.lean`'s import closure, add the minimal
  imports the probe's `import FormalSystem` supplied, never `import FormalSystem` itself in
  library code; record the added imports in the summary.
- If a `#guard_msgs` pin or the C14 pair does not match, the mismatch is a measurement: compare
  against the probe's compile log (`probes/presents-is-seam-decidedness.compile.log`), fix the
  proof or the expected text in the same commit with the reason stated, never rewrite a baseline
  to turn a red build green.
- If a genuine rollback of uncommitted work is needed, follow `context/contracts/recovery.md`'s
  rollback rung (snapshot via `git-snapshot.sh 737`, then the destructive command); an ordinary
  defensive checkpoint before a risky edit uses `git-snapshot.sh 737 --no-revert` instead.
- Under no contingency are `Presents`, `plusStab_iff_seamSummary`, or their pins touched.
