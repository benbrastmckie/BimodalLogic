# Implementation Plan: Task #675

- **Task**: 675 - Close the sep row of Axiom.minFrameClass by constructing a densely ordered countermodel
- **Status**: [IMPLEMENTING]
- **Effort**: 6.5 hours
- **Dependencies**: None (`DenseRTimeSharpness.lean`, `ZTimeSharpness.lean` and `Soundness.lean` are landed)
- **Research Inputs**: specs/675_close_sep_row_minframeclass_dense_countermodel/reports/01_close-sep-row-dense-countermodel.md
- **Artifacts**: plans/01_close-sep-row-dense-countermodel.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

The research phase did not merely survey routes — it **elaborated the entire countermodel
end-to-end** under real project imports via `lean_run_code`, with zero errors, zero sorries, and
`#print axioms sep_minFrameClass_sharp` returning the pinned `[propext, Classical.choice,
Quot.sound]`. Route 2 (`D = Lex (ℚ →₀ ℚ)`, the Hahn group over a dense index order, φ-region the
positive single-support generators, evaluation point `0`) is therefore **selected and verified**,
not assumed. This plan is consequently a transcription, assembly, and documentation exercise,
not a discovery exercise: phases 1–3 land verified proof text into a new sibling module
`FormalSystem/Metalogic/Independence/SepSharpness.lean` under scoped builds, phase 4 batches every
docstring and ledger edit, and phase 5 spends the single budgeted full rebuild on the gate set.

One finding materially changes the deliverable's *shape* relative to the dispatch's expectation
and must not be lost in transcription: **`Axiom.sep` is valid at `.ZTime`**, schematically, because
`IsZTime` supplies a `SuccOrder` and hence a least positive duration, feeding the landed
`sep_validOn_of_isLeastPos`. The exhaustive characterization is therefore
`ValidIn fc φ ↔ fc = .ZTime ∨ .RTime ≤ fc`, **not** `↔ .RTime ≤ fc`. Copying
`density_validIn_iff`'s shape mechanically would state something false.

### Research Integration

Findings carried directly into the phase structure:

- **The verified proof text** (research report, Findings → *The verified countermodel*) is the
  literal input to phases 1–3. Each phase transcribes a contiguous, already-elaborated block.
- **The dispatch's recorded instance gap is stale.** `IsOrderedAddMonoid (Lex (ℚ →₀ ℚ))` is
  already available from Mathlib via `Finsupp.Lex.isOrderedCancelAddMonoid`; no instance need be
  written off `Finsupp.Lex.addLeftMono` / `addRightMono`. The one genuinely missing instance is
  `DenselyOrdered (Lex (ℚ →₀ ℚ))` (14 lines, proved in the report).
- **Elaboration trap, load-bearing**: helper lemmas MUST be stated at the bare carrier
  abbreviation, never at `(sepSharpOrder : Type)` — `ofLex r j` fails to elaborate at
  `TemporalOrder.carrier` ("Function expected at `ofLex r`"). This was an observed failure during
  probing, not a precaution.
- **Mathlib trap**: `Finsupp.Lex.single_lt_iff` / `single_strictAnti` are value-type-specialised
  in the pinned snapshot and do **not** apply at value type `ℚ`; the replacement is the report's
  three-line `sg_lt_sg`, proved directly from `Finsupp.Lex.lt_iff`.
- **Proof-size decision**: refute `K⁺φ` at every `r > 0` (two-way split on `sg i ≤ r`), never
  `K⁻φ` or the conjunction (which forces a three-way split on the leading coefficient). Recorded
  as the single largest proof-size saving found.
- **Route 1 is dead and the reason is sharper than the dispatch recorded**: one infinitesimal
  level is never enough, and neither is any finite number. **Route 3** (bespoke Cantor set in `ℚ`)
  is excluded on cost, not refuted — record it that way.
- **Landing site**: a new module, not an extension of `DenseRTimeSharpness.lean` (already 400
  lines; the new carrier brings ~90 lines of `Finsupp.Lex` order machinery unrelated to the
  `.Dense` rows).
- **`DenselyOrdered` stays local**, not `ForMathlib/` — a new `ForMathlib/` file is a recorded
  C24 exception requiring edits to `scripts/CheckInitImportsMain.lean` and `FormalSystem/Init.lean`,
  churn out of proportion to a 14-line instance. Record the generalisation as an upstreaming
  candidate in the module docstring instead.

### Prior Plan Reference

No prior plan. This is round 1 for this task.

### Roadmap Alignment

No `roadmap_path` was provided in the delegation context and no roadmap consultation was
requested. No ROADMAP.md phases are included.

## Goals & Non-Goals

**Goals**:

- Land sorry-free, named, frame-level refutations of `Axiom.sep`'s atomic instance establishing
  non-validity at **both** `.Base` and `.Dense`, and hence `sep_minFrameClass_sharp` at every
  class strictly below `.RTime`.
- Land `sep_validIn_ztime` (positive, schematic) and the exhaustive `sep_validIn_iff` in its
  **correct** form, `ValidIn fc φ ↔ fc = .ZTime ∨ .RTime ≤ fc`.
- Carry the underivability corollary `not_derivable_dense_sep` through `soundness_validIn`,
  matching `not_derivable_dense_prior_U_gap`.
- Carry an `Axiom.sep` shape pin, making formula-transcription fidelity a compiler obligation.
- Update `Axiom.minFrameClass`'s docstring to record the closed row, and add the new result to
  both Independence ledgers in each ledger's own numbering convention.
- Keep the measured axiom set at `[propext, Classical.choice, Quot.sound]`; no new axiom
  declaration, no `sorry`.
- Leave `scripts/check-module-invariants.sh` green across all check groups and
  `scripts/readme-lint.sh` at PASS.

**Non-Goals**:

- Re-proving or restating the `density`, `dense_indicator`, `prior_U_gap` or `.ZTime` rows — all
  landed.
- Attempting a discrete carrier. `sep_validOn_of_isLeastPos` plus
  `Semantics.duration_dense_or_least_pos` proves that a dead end.
- Attempting route 1 or route 3. Route 1 is refuted; route 3 is excluded on cost.
- Generalising `DenselyOrdered (Lex (α →₀ N))` into `FormalSystem/ForMathlib/` (recorded as an
  upstreaming candidate only).
- Stating `ValidIn fc φ ↔ .RTime ≤ fc`. It is **false** — `.RTime ≰ .ZTime`, yet `sep` is
  `.ZTime`-valid.
- Deleting entries from either ledger to reconcile them, the compression/adequacy direction, and
  any change to the ModelChecker repository.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Helper lemmas stated at `(sepSharpOrder : Type)` fail to elaborate (`ofLex r j`) | H | H if ignored | State every helper at the bare carrier abbreviation; let reducibility bridge at the frame-level theorem. Observed failure, not a precaution |
| Overclaiming the characterization as `↔ .RTime ≤ fc` | H | M | `sep_validIn_ztime` fixes the correct form `↔ fc = .ZTime ∨ .RTime ≤ fc`; Phase 3 states it explicitly and Phase 4's docstrings must not drift from it |
| `AddCommGroup (Lex (ℚ →₀ ℚ))` is noncomputable | M | M | `sepSharpOrder` must be a `noncomputable abbrev` (matching `denseSharpOrder`/`ztimeSharpOrder`) and the generator a `noncomputable def` |
| INV check fails because a docstring edit grew a file *after* inventory regeneration | M | M | Regenerate via `scripts/check-module-invariants.sh --emit-inventory` strictly AFTER the last docstring edit (Phase 5, not Phase 4). `scripts/readme-inventory.sh` is only a pointer script |
| New README inventory description silently truncated | M | M | The generator splits rows on `\|`. Keep the `SepSharpness.lean` description pipe-free — write "the region of single-support generators", never set-builder or absolute-value bars |
| C20 tier 2 failure on README prose | M | L | Tree is at zero `file.lean` line-number citations under `FormalSystem/`. Cite declaration names and bare file names only |
| Growing `ProofSystem/Axioms.lean` shifts live line-number citations elsewhere | M | M | Remedy is `scripts/reanchor-lean-citations.py --by-name`; run in Phase 5 if the gate flags it |
| Budget overrun from repeated full rebuilds | H | M | All verification via `lean_run_code` and scoped module builds; every `Axioms.lean`/ledger edit batched into ONE detached `scripts/lake-build-guard.sh build --timeout 1800 -- build` (note the `lake` subcommand after the bare `--`; omitting it exits 77) |
| Mathlib's `Finsupp.Lex.single_lt_iff` looks applicable but is value-type-specialised | M | M | Do not reach for it; use the report's `sg_lt_sg`, proved from `Finsupp.Lex.lt_iff` |
| Concurrent sibling task 676 shares this working tree and declares no `file_scope` | M | M | Re-read every file immediately before editing; stage only this task's own hunks with an explicit file list, never a directory or glob `git add`; never run `git-snapshot.sh` in its reverting default mode; report any foreign commit or foreign uncommitted modification rather than proceeding |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |

Phases within the same wave can execute in parallel. This plan is strictly linear: the order
machinery must elaborate before the frame-level refutation is written against it, the class-level
results must carry their final names before any docstring cites them, and the single budgeted
full rebuild must come after the last edit.

---

### Phase 1: Carrier, instance, and order machinery [COMPLETED]

**Goal**: `FormalSystem/Metalogic/Independence/SepSharpness.lean` exists, with the Hahn carrier,
the missing `DenselyOrdered` instance, the `TemporalOrder`, the generator, the φ-region, and the
six order helper lemmas — all elaborating sorry-free under a scoped build.

**Tasks**:

- [x] Re-read `FormalSystem/Metalogic/Independence/DenseRTimeSharpness.lean`'s header (copyright
      block, module docstring shape, `Tags` line, `open`/`namespace` ritual) and mirror it.
- [x] Create `FormalSystem/Metalogic/Independence/SepSharpness.lean` with imports
      `FormalSystem.Metalogic.Independence.DenseRTimeSharpness` and `Mathlib.Data.Finsupp.Lex`,
      namespace `FormalSystem.Metalogic.Independence`.
- [x] Transcribe the carrier abbreviation for `Lex (ℚ →₀ ℚ)` (the Hahn group `⊕_{γ∈ℚ} ℚ`).
- [x] Transcribe the `DenselyOrdered` instance verbatim from the report (the explicit
      `rw [ofLex_toLex, Finsupp.add_apply, Finsupp.single_apply, …]` chain plus `linarith`; a bare
      `simp` over-simplifies the `<` goal to `False`).
- [x] Declare `noncomputable abbrev sepSharpOrder : TemporalOrder := TemporalOrder.of …`, the
      `noncomputable def` generator, and the φ-region set. Follow `denseSharpOrder` /
      `ztimeSharpOrder` for naming and the `noncomputable` ritual.
- [x] Transcribe the six helpers: the `@[simp]` generator-application lemma, positivity of the
      generator, the two index-comparison lemmas (generator below a term from its leading index,
      and a doubled term below a generator), leading-index extraction from positivity, and the
      order-reversal equivalence replacing Mathlib's unusable `Finsupp.Lex.single_lt_iff`.
- [x] State **every** helper at the bare carrier abbreviation, never at `(sepSharpOrder : Type)`.
- [x] Record in the module docstring that a generalised
      `[LinearOrder α] [AddCommGroup N] [LinearOrder N] [DenselyOrdered N] → DenselyOrdered (Lex (α →₀ N))`
      holds (replace the midpoint by `exists_between` in `N`) and is an upstreaming candidate for
      `FormalSystem/ForMathlib/Order/`, kept local here to avoid the C24 `ForMathlib/` exception.
- [x] Do **not** add the import to `FormalSystem/Metalogic/Independence.lean` yet — that edit is
      batched into Phase 4 so the aggregator (and its dependents) rebuild exactly once.

**Timing**: 1.5 hours

**Depends on**: none

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: this phase is estimated at ~120–160 lines of the new module, and the whole
module at 380–460 lines with this repository's docstring density. Confirm at implementation time
with `wc -l` on the file after Phase 3, and treat a large overshoot as a signal that the proof
text has drifted from the verified original rather than as a reason to trim docstrings.

**Files to modify**:

- `FormalSystem/Metalogic/Independence/SepSharpness.lean` — new file: header, imports, carrier,
  `DenselyOrdered` instance, `TemporalOrder`, generator, φ-region, six order helpers.

**Verification**:

- `lean_run_code` on the phase's content plus its imports elaborates with zero diagnostics.
- Scoped build green: `lake build FormalSystem.Metalogic.Independence.SepSharpness`.
- `lean_diagnostic_messages` on the file reports no errors, no warnings, no `sorry`.

---

### Phase 2: The three order facts and the frame-level refutation [COMPLETED]

**Goal**: the three accumulation facts about the φ-region and the frame-level non-validity
theorem `not_validOn_sep_lexHahn` land sorry-free, with the `Axiom.sep` shape pin compiling.

**Tasks**:

- [x] Transcribe the three order facts (the report's `L1`/`L2`/`L3`), giving each a
      project-styled name and a docstring stating what it says in order language:
      (a) the φ-region accumulates at `0` from the right — this is `K⁺φ` at `0`;
      (b) no φ-point has an immediate φ-successor across a gap, so `φ ∧ U(φ,¬φ)` is false
      everywhere and the second antecedent conjunct holds at `0`;
      (c) no `r > 0` is a right-accumulation point of the φ-region — the two-way split on
      `sg i ≤ r` versus `r < sg i`, never the three-way split on the leading coefficient.
- [x] Add a `/-! ## Shape pins` section mirroring `DenseRTimeSharpness.lean`'s, carrying
      `example (φ : Formula) : Axiom (…) := Axiom.sep φ` with the formula written out in full.
- [x] Transcribe `not_validOn_sep_lexHahn`: the frame-level `¬ (translationFrame …).toTaskFrame.ValidOn …`
      statement at `Formula.atom a`, evaluated at `translationModel` / `translationHist` / `0`,
      driven by the named clause lemmas `Truth.imp_iff`, `Truth.and_iff`, `Truth.kPlus_iff`,
      `Truth.neg_iff`, `Truth.untl_iff` — never `simp [TruthAt]`.
- [x] Write the formula out in full at every occurrence; do not factor it behind a local
      abbreviation that the shape pin does not also pin.
- [x] Beware the constructor argument-order trap the Independence README flags: the prose reads
      `U(φ,¬φ)` event-first, the constructor is `Formula.untl φ.neg φ`, guard-first. The shape pin
      is what makes this a compiler obligation rather than a reviewer obligation.

**Timing**: 1.5 hours

**Depends on**: 1

**Verification Tier**: local

**Commit Mode**: per-substep

**Files to modify**:

- `FormalSystem/Metalogic/Independence/SepSharpness.lean` — three order facts, shape-pin section,
  `not_validOn_sep_lexHahn`.

**Verification**:

- Scoped build green: `lake build FormalSystem.Metalogic.Independence.SepSharpness`.
- The `example … := Axiom.sep φ` shape pin type-checks (this is the transcription-fidelity gate).
- `lean_diagnostic_messages` clean; no `sorry` in the file.

---

### Phase 3: Class-level results and the exhaustive characterization [IN PROGRESS]

**Goal**: the named deliverable theorems land sorry-free with the pinned axiom set, including the
`.ZTime` positive result and the **correct** characterization.

**Tasks**:

- [ ] `not_validIn_base_sep` and `not_validIn_dense_sep`, each discharging its class membership by
      `inferInstance` / `⟨inferInstance, inferInstance⟩` (`translationFrame_isRegular` is a global
      instance).
- [ ] `sep_minFrameClass_sharp`: `rcases base_or_dense_of_lt_rtime hfc` into the two refutations.
      Do not attempt `by decide` on `FrameClass` `<` — only `≤` has a `DecidableRel` instance, and
      `base_or_dense_of_lt_rtime` already packages what is needed.
- [ ] `isLeastPos_of_succOrder` and `sep_validIn_ztime`, the latter schematic in `φ` (sound here
      precisely because it is a *validity* claim, not a non-validity claim). Destructure `IsZTime`
      with `obtain ⟨-, so, -, -⟩ := hF`; do not `haveI`. These **consume**
      `sep_validOn_of_isLeastPos`, so that lemma must not be deleted from `DenseRTimeSharpness.lean`.
- [ ] `sep_validIn_iff (a : Atom) (fc : FrameClass) : ValidIn fc (…) ↔ (fc = FrameClass.ZTime ∨ FrameClass.RTime ≤ fc)`
      by `cases fc`: `.Base`/`.Dense` from the two refutations, `.ZTime` from `sep_validIn_ztime`,
      `.RTime` from `sep_valid` (`Metalogic/Soundness.lean`, definitionally `ValidIn FrameClass.RTime`).
      **Do not** state `↔ .RTime ≤ fc` — it is false.
- [ ] `not_derivable_dense_sep` through `soundness_validIn`, in the
      `fun ⟨d⟩ => not_validIn_dense_sep a (soundness_validIn d)` shape that
      `not_derivable_dense_prior_U_gap` uses.
- [ ] Write the module docstring's `## Main results` bullet list and a `## The `sep` row` section
      explaining why the carrier is what it is (the φ-region is anti-isomorphic to `ℚ_{>0}`, its
      elements are mutually infinitely separated, so it accumulates at `0` yet nowhere above it),
      and recording route 1 as refuted and route 3 as excluded-by-cost.
- [ ] `#print axioms` on `sep_minFrameClass_sharp`, `sep_validIn_iff` and `sep_validIn_ztime`;
      confirm `[propext, Classical.choice, Quot.sound]` on each.

**Timing**: 1 hour

**Depends on**: 2

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: this phase asserts exactly seven new named declarations
(`not_validIn_base_sep`, `not_validIn_dense_sep`, `sep_minFrameClass_sharp`,
`isLeastPos_of_succOrder`, `sep_validIn_ztime`, `sep_validIn_iff`, `not_derivable_dense_sep`).
Confirm by grepping `^theorem\|^lemma` in the finished module and reconciling against the
`## Main results` bullet list before Phase 4 cites any of them.

**Files to modify**:

- `FormalSystem/Metalogic/Independence/SepSharpness.lean` — class-level results, characterization,
  underivability corollary, module docstring.

**Verification**:

- Scoped build green: `lake build FormalSystem.Metalogic.Independence.SepSharpness`.
- `lean_verify` (or `#print axioms`) on the three headline theorems returns exactly
  `[propext, Classical.choice, Quot.sound]`.
- `grep -n "sorry" FormalSystem/Metalogic/Independence/SepSharpness.lean` returns nothing.
- Every name in the module docstring's `## Main results` list resolves to a declaration in the file.

---

### Phase 4: Docstring and ledger edits, batched [NOT STARTED]

**Goal**: every prose surface that must change is changed, in one batch, with no build run — so
that Phase 5 spends exactly one full rebuild.

**Tasks**:

- [ ] Re-read each file immediately before editing (concurrent sibling task 676 shares this tree
      and declares no `file_scope`).
- [ ] `FormalSystem/Metalogic/Independence.lean`: add
      `import FormalSystem.Metalogic.Independence.SepSharpness` to the import block.
- [ ] `FormalSystem/Metalogic/Independence.lean` ledger: change "Eleven results are carried here."
      to "Twelve"; rewrite item 11's closing sentence (its claim that `Axiom.sep` is the one row
      still upper-bound-only becomes false); append item 12 for the closed `sep` row, naming
      `sep_minFrameClass_sharp`, `sep_validIn_ztime` and `sep_validIn_iff` and stating the
      characterization in its correct `fc = .ZTime ∨ .RTime ≤ fc` form. Also fix the trailing
      sentence "Results 10 and 11 together leave `Axiom.sep` as the only row … not known to be
      minimal", which likewise becomes false.
- [ ] `FormalSystem/Metalogic/Independence.lean` `## Contents`: add a `SepSharpness.lean` bullet,
      and amend the `DenseRTimeSharpness.lean` bullet's closing clause ("leaves `Axiom.sep` the
      last open row") to point at the new module.
- [ ] `FormalSystem/Metalogic/Independence/README.md` ledger: the same three edits in the README's
      own numbering convention — "Eleven" → "Twelve", item 11's closing sentence, new item 12.
- [ ] `FormalSystem/Metalogic/Independence/README.md` `## Key Results`: add the new headline
      entries alongside the existing `*_validIn_iff` / `*_minFrameClass_sharp` entries.
- [ ] `FormalSystem/Metalogic/Independence/README.md` countermodel kit: add the short subsection
      "When one infinitesimal level is not enough", pointing at `SepSharpness.lean` and recording
      the two elaboration traps (helpers must be stated at the bare carrier abbreviation;
      `Finsupp.Lex.single_lt_iff` is value-type-specialised upstream and unusable at `ℚ`).
- [ ] `FormalSystem/Metalogic/Independence/DenseRTimeSharpness.lean`: rewrite the module
      docstring's "The `sep` row" section and the `## Row 4: sep — the obstruction, not the
      refutation` section docstring — replace the three-route survey with "closed; see
      `SepSharpness.lean`", noting that `sep_validOn_of_isLeastPos` is now *consumed* by
      `sep_validIn_ztime`. **Do not delete** `not_kPlus_of_isLeastPos` or
      `sep_validOn_of_isLeastPos`. Amend the `## Main results` bullet that calls `sep` "the open
      `sep` row".
- [ ] `FormalSystem/ProofSystem/Axioms.lean`: replace the "**`sep` is the one row still carrying
      the upper bound only.**" paragraph in `Axiom.minFrameClass`'s docstring with the closed row —
      an "RTime row, `sep`" bullet alongside the existing "RTime row, `prior_U_gap` only" bullet,
      citing `Metalogic.Independence.sep_minFrameClass_sharp` and
      `Metalogic.Independence.sep_validIn_iff`, and stating the `.ZTime` divergence explicitly
      (this is where `sep`'s row shape genuinely differs from `prior_U_gap`'s). Amend the
      "every row but one is also known *minimal*" lead sentence, which becomes false.
- [ ] Keep all new README prose free of `file.lean` line-number citations (C20 tier 2 covers every
      `README.md` under `FormalSystem/`; the tree is currently at zero such citations).
- [ ] Do **not** run `--emit-inventory` yet, and do **not** hand-edit the generated `## Modules`
      inventory block — the generator owns it, and it runs in Phase 5 after the last docstring edit.

**Timing**: 1.5 hours

**Depends on**: 3

**Verification Tier**: interface

**Commit Mode**: per-substep

**Scope Hypothesis**: this phase asserts that the count word "Eleven" occurs in exactly two files
(`FormalSystem/Metalogic/Independence.lean` line 39 and
`FormalSystem/Metalogic/Independence/README.md` line 6) and that exactly five files need edits.
Confirm at implementation time with `grep -rn "results are carried here" FormalSystem/` and
`grep -rn "upper bound only\|last open row\|only row" FormalSystem/` before declaring the batch
complete — a missed occurrence of the now-false claim is the most likely defect in this phase.

**Files to modify**:

- `FormalSystem/Metalogic/Independence.lean` — import line, ledger count, item 11, new item 12,
  `## Contents` bullet.
- `FormalSystem/Metalogic/Independence/README.md` — ledger count, item 11, new item 12,
  `## Key Results`, countermodel-kit subsection.
- `FormalSystem/Metalogic/Independence/DenseRTimeSharpness.lean` — module docstring "The `sep`
  row" section, `## Row 4` section docstring, `## Main results` bullet. Docstrings only; no
  declaration is added, changed or removed.
- `FormalSystem/ProofSystem/Axioms.lean` — `Axiom.minFrameClass` docstring only. No constructor,
  no definition body.
- `FormalSystem/Metalogic/Independence/SepSharpness.lean` — cross-references back to the ledgers
  if the module docstring names them.

**Verification**:

- Diff read-through confirming every hunk in `Axioms.lean` and `DenseRTimeSharpness.lean` lies
  strictly inside a docstring region (these two files' edits are prose-only by contract; the
  phase's `interface` tier is driven by the `Independence.lean` import-graph change).
- `grep -c "results are carried here" ` across both ledgers shows the count word updated in both.
- No `file.lean:NNN` line-number citation appears in any changed README prose.
- No new ledger description contains a literal pipe character.
- Build is deliberately NOT run in this phase.

---

### Phase 5: Single full rebuild, inventory regeneration, and the gate set [NOT STARTED]

**Goal**: one budgeted full rebuild, all gates green, the task's claim verified end to end.

**Tasks**:

- [ ] Confirm no further docstring edit is pending — the INV check compares generated inventory
      blocks against actual file line counts and will fail if a file grows after regeneration.
- [ ] Run the single budgeted full rebuild, detached:
      `bash scripts/lake-build-guard.sh build --timeout 1800 -- build`. Note the `lake` subcommand
      after the bare `--`; omitting it is a usage error (exit 77). Wait on it per
      `context/patterns/bounded-build-waiter.md`: a hard timeout, writer liveness via `kill -0` on
      the captured PID, one waiter per log — never `ps | grep` or `pgrep -f`.
- [ ] Regenerate the inventory AFTER the last docstring edit:
      `bash scripts/check-module-invariants.sh --emit-inventory`. This is the real command and it
      propagates counts into several READMEs; `scripts/readme-inventory.sh` is only a pointer script.
- [ ] Hand-write the `SepSharpness.lean` inventory description (it regenerates as
      `<!-- TODO: add description -->`), **pipe-free** — describe the φ-region as "the region of
      single-support generators", never with set-builder or absolute-value bars, which the
      generator swallows.
- [ ] If the gate flags shifted line-number citations caused by the grown `Axioms.lean`, run
      `python3 scripts/reanchor-lean-citations.py --by-name`.
- [ ] `bash scripts/check-module-invariants.sh` — green across all check groups, C2's flagship
      axiom sets unchanged and C3's structural sorry inventory still ZERO.
- [ ] `bash scripts/readme-lint.sh` — PASS.
- [ ] Confirm the measured axiom set of `FormalSystem/MainResults.lean`'s build-time
      `print axioms` audit is unchanged at `[propext, Classical.choice, Quot.sound]`.
- [ ] Commit with an explicit file list only — never `git add -A`, never a directory or glob
      pathspec (sibling task 676 is live on this tree).

**Timing**: 1 hour

**Depends on**: 4

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: this phase asserts exactly one full rebuild suffices. If a second is forced
(e.g. `--emit-inventory` changes a file that itself feeds the build), record *why* in the summary
rather than silently spending it, and re-check whether a Phase 4 edit leaked outside a docstring.

**Files to modify**:

- `FormalSystem/Metalogic/Independence/README.md` — generated `## Modules` inventory block plus the
  hand-written `SepSharpness.lean` description.
- Any README whose generated counts the `--emit-inventory` run propagates into.
- Potentially any file `reanchor-lean-citations.py --by-name` corrects.

**Verification**:

- `scripts/lake-build-guard.sh` build exits 0.
- `bash scripts/check-module-invariants.sh` green across all check groups (B0–B3, C1–C7 and the
  remaining groups), with C2 matching baseline and C3 at ZERO.
- `bash scripts/readme-lint.sh` reports PASS.
- `grep -rn "sorry" FormalSystem/Metalogic/Independence/SepSharpness.lean` returns nothing.
- The `SepSharpness.lean` row in the generated inventory table renders with a full, untruncated
  description.

---

## Testing & Validation

- [ ] `lake build FormalSystem.Metalogic.Independence.SepSharpness` exits 0 (phases 1–3).
- [ ] Full `lake build` via `scripts/lake-build-guard.sh` exits 0 (phase 5).
- [ ] `#print axioms sep_minFrameClass_sharp` = `[propext, Classical.choice, Quot.sound]`.
- [ ] `#print axioms sep_validIn_iff` and `#print axioms sep_validIn_ztime` — same set.
- [ ] The `example (φ : Formula) : Axiom (…) := Axiom.sep φ` shape pin type-checks.
- [ ] Zero `sorry` in the new module; C3 structural sorry inventory still ZERO tree-wide.
- [ ] No new axiom declaration anywhere in the diff.
- [ ] `sep_validIn_iff` states `fc = FrameClass.ZTime ∨ FrameClass.RTime ≤ fc`, not `.RTime ≤ fc`.
- [ ] Both ledgers say "Twelve results are carried here." and enumerate the same twelve results in
      the same order.
- [ ] `scripts/check-module-invariants.sh` green; `scripts/readme-lint.sh` PASS.
- [ ] No `file.lean` line-number citation introduced into any `README.md` under `FormalSystem/`.
- [ ] `not_kPlus_of_isLeastPos` and `sep_validOn_of_isLeastPos` still present in
      `DenseRTimeSharpness.lean` (the latter is now consumed by `sep_validIn_ztime`).

## Artifacts & Outputs

- `FormalSystem/Metalogic/Independence/SepSharpness.lean` — new module (est. 380–460 lines)
  carrying the Hahn carrier, the `DenselyOrdered` instance, the order machinery, the frame-level
  refutation, the class-level results, the characterization, the underivability corollary, and the
  `Axiom.sep` shape pin.
- `FormalSystem/Metalogic/Independence.lean` — import, ledger item 12, `## Contents` bullet.
- `FormalSystem/Metalogic/Independence/README.md` — ledger item 12, `## Key Results` entries,
  the "When one infinitesimal level is not enough" kit subsection, regenerated inventory row.
- `FormalSystem/Metalogic/Independence/DenseRTimeSharpness.lean` — docstrings rewritten to record
  the row as closed.
- `FormalSystem/ProofSystem/Axioms.lean` — `Axiom.minFrameClass` docstring recording the closed
  `sep` row and its `.ZTime` divergence.
- Task summary at `specs/675_close_sep_row_minframeclass_dense_countermodel/summaries/01_*-summary.md`.

## Rollback/Contingency

- **Phases 1–3 (new module only)**: the module is not yet imported by any aggregator, so reverting
  is deleting the file. Nothing downstream depends on it. No snapshot is warranted.
- **Phase 4–5**: if a gate fails after the full rebuild, revert the specific hunks with
  `git checkout HEAD -- <explicit file>` **only** for files this task owns, never a directory
  pathspec, and never while sibling task 676 has uncommitted work in the same file. Per the
  territory contract, if a foreign commit or foreign uncommitted modification is observed, STOP
  and report it after checking `git log`, rather than reverting over it.
- **If a defensive checkpoint is wanted before Phase 5's batched edits**, use
  `bash .claude/scripts/git-snapshot.sh 675 --no-revert` — durable and non-reverting. The bare
  default (reverting) form is for a genuine rollback only and must not be emitted as a routine
  checkpoint.
- **If the route unexpectedly resists** (it should not — it is machine-checked): close it as a
  reasoned exclusion with the obstruction recorded in `DenseRTimeSharpness.lean`'s Row 4 section,
  rather than leaving the module half-landed. Do not introduce a `sorry` and do not add an axiom.
  The research report records that no `sorry`-deferral, new axiom, or `[BLOCKED]` outcome is
  warranted.
