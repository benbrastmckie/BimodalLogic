# Implementation Plan: Task #859

- **Task**: 859 - Land the open-future NON-definability result as a library module
- **Status**: [COMPLETED]
- **Effort**: 6.25 hours
- **Dependencies**: The companion elimination module `FormalSystem/Metalogic/Expressiveness/OpenFutureElimination.lean` (landed; owns `PastDet`, `FutDet`, `OfutP`, `OpastP`)
- **Research Inputs**: `specs/859_qtime_open_future_definability_base_dense/reports/01_qtime-open-future-definability.md`; `specs/859_qtime_open_future_definability_base_dense/probes/01_ofut-marker-gadget-and-nondefinability.lean` (419 lines, compiled-live, sorry-free, no axiom declarations)
- **Artifacts**: plans/01_open-future-undefinable-module.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

The research is done and must not be reopened: the open-future modal `▷` is **not**
L⁺-definable at `.Base` and not at `.Dense`, and with the companion positive result at `.ZTime`
and `.RTime` the class split closes. This task moves that round's durable content out of a
disposable task directory and into the library, as a new module
`FormalSystem/Metalogic/Independence/OpenFutureUndefinable.lean` beside its two direct
analogues (`StabUndefinable.lean`, `DeterminismUndefinable.lean`), with the probe's content
re-expressed as documented library code and the shared determinedness vocabulary **imported**
from the companion module rather than redeclared.

The central theorem is conditional, and the plan's single most important discipline is that
every landed surface says so. The marker-gadget reduction
(`ofut_not_plusDefinable_of_deltaProp_inexpressible`) and the four-colour clock frame's
regularity (`colourFibre_isRegular`) are machine-checked and earn pinned theorem-index rows.
The unconditional verdict "not definable at `.Base`/`.Dense`" rests on `hinexpr` — a GHR
Lemma 12.4.2-style collapse argument derived in the report and **not** formalized — so it lives
in the module docstring as cited prose, with `hinexpr` named as the open hypothesis, and gets no
row claiming machine-checked status. A row that overstates this is worse than no row.

Five phases: the module and its aggregator wiring; the re-measured C14 axiom baseline; two
conditional theorem-index rows; the directory README, the fourteenth numbered result, and the
regenerated inventories; then a full audit.

### Research Integration

The plan is built on the report's F1-F6 and its Decisions D1-D7, which fix the content:

- **F1** (`ofut_pastDet`, `opast_futDet`) is the structural constraint that explains why no
  separator was found before, and is recorded first in the module for exactly that reason.
- **F2** (the marker gadget `theta_eq_iff`, `nu_iff_le`, `run_iff`) is the round's main finding:
  the point of evaluation is nameable from inside L⁺ at the cost of one atom, so a bounded
  universal over a gap-anchored region becomes an L⁺ formula.
- **F3** (`DeltaProp`, `delta_iff`, `deltaProp_pastDet`, `dofut_probe_iff`,
  `ofut_neg_probe_iff`) is the exactness claim: `▷` computes `DeltaProp` with no slack, because
  the marker atom occurs in the probe formula only inside the marker condition itself.
- **F4** (`cRel`, `colourFibre`, `colourFibre_isRegular`) is the witness frame, and the
  *Limit* obstruction that forced it. D2 records that the frame, not the duration, was the
  obstruction — the naive permissive rational-time frame is not regular, because finitely many
  colour states over a dense duration give uniformly discrete step histories with nothing
  accumulating and so no gap to anchor at. The repository's own `colourClock` removes it: the
  clock discharges *Limit*, finiteness discharges *Saturation*.
- **F5** is the paper step. It is NOT formalized and must not be presented as if it were.
- **F6** is the conditional conclusion, and D5 records why `hmarkers`/`hinexpr` stay hypotheses:
  the frame-independent content compiles and the frame-specific content is named and audited,
  which also makes the theorem reusable at any frame satisfying the two.

Two report items are deliberately **not** acted on here. R3 (formalizing F5) is a multi-phase
task of its own and is out of scope; the prior-cycle decision on record accepted the paper step.
R4 (the `colourClock` history bridge lemma that would turn `hmarkers` from a hypothesis into an
applied lemma) is the related, non-blocking task and may land before or after this one; nothing
in this plan depends on it, and nothing here blocks it.

### Prior Plan Reference

No prior plan for this task. The companion task's plan
(`specs/854_open_future_modal_lplus_definability/plans/01_open-future-elimination-module.md`,
completed in five phases at ~5 hours) is the calibration reference, not a template: it landed a
module in the sibling `Expressiveness/` directory against the same five gate surfaces (scoped
guarded build, the C14 heredoc pair, theorem-index rows, the generated inventories, a full
audit), so its phase shapes and measured timings inform this plan's estimates. Two lessons
carried over from its execution record: a new module under `FormalSystem/` forces a
`FormalSystem.lean` regeneration (C33) that its own scope list had omitted, and the harness
gate set is inapplicable here because this repository carries no `agent-system/` source store.

### Roadmap Alignment

No `roadmap_path` was provided in this dispatch, and no roadmap phases are therefore included.

## Goals & Non-Goals

**Goals**:

- Land `FormalSystem/Metalogic/Independence/OpenFutureUndefinable.lean` carrying the probe's
  content as namespaced, fully documented library code, sorry-free, with no new axiom
  declaration and no vacuous definition.
- Import the companion module's `PastDet`/`FutDet`/`OfutP`/`OpastP` vocabulary rather than
  redeclaring it, and route the `▷`-level bridge through the companion's `ofutP_iff`.
- Wire the module into `FormalSystem/Metalogic/Independence.lean` so `lake build` compiles it,
  and record it as the directory's fourteenth result in both places that enumerate them.
- Pin the measured axiom profile of eleven declarations in `scripts/check-module-invariants.sh`'s
  C14 heredoc pair, measured and never typed.
- Add exactly two theorem-index rows, both stating the conditional form.
- Keep every landed surface honest about what is and is not machine-checked: no surface may
  state the unconditional `.Base`/`.Dense` verdict as machine-checked, and none may suggest
  `hinexpr` is discharged in this tree.

**Non-Goals**:

- Formalizing `hinexpr` (report F5, R3). The collapse argument stays a cited paper step.
- Compiling the "every colour function is a history" bridge that would discharge `hmarkers` at
  `colourFibre` (report R4). That is the separate, non-blocking related task; this module keeps
  `hmarkers` as a hypothesis and says so.
- Proving that the companion's `openTruthAt_iff_tr` is literally a positive instance of this
  module's `OfutPlusDefinable`. The relationship is stated in the docstring as a cross-reference
  only; proving a bridge would be new mathematics the probe does not carry.
- Touching `FormalSystem/Metalogic/Expressiveness/` in any way. The companion task owns it.
- Editing `scripts/check-metalogic-cycles.sh` or its recorded 8-line allowlist. The new imports
  are downward or same-layer edges; the allowlist must come out unchanged.
- Filing anything under `specs/evidence/`. `scripts/check-evidence-probes.sh` governs records of
  why the decision layer has its shape, not results about the logic.
- Any claim about completeness or decidability for L^▷ or L⁺, and any claim at `.ZTime`/`.RTime`
  beyond citing the companion module.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| A landed surface overstates the verdict as machine-checked | H | M | The conditionality discipline is written into every phase that produces prose (1, 3, 4) and is re-read as an explicit audit step in Phase 5. Exactly two declarations earn rows, both named in this plan; `hinexpr` is named as the open hypothesis in the module docstring and in the theorem-index lead. |
| Territory collision with concurrent sibling task 559 on `docs/theorem-index.md`, `FormalSystem.lean`, `typst/generated/status.typ`, `FormalSystem/Metalogic/README.md` | H | H | 559 declares `docs/theorem-index.md` and `FormalSystem/Metalogic.lean` in its `file_scope`, and as a new-module task will also regenerate the library root, the typst counts and the generated inventory blocks. Every phase that touches a shared path must re-read the file immediately before editing, stage with an explicit file list (never a directory or glob), and treat a foreign hunk as a sibling's in-flight edit to report rather than revert. Never run `git-snapshot.sh` in its reverting default mode. |
| The probe's generic identifiers (`theta`, `nu`, `delta`, `probe`, `holds`, `Colour`) collide or shadow in a namespace shared by 29 modules | M | M | The marker-gadget block goes in a nested `namespace MarkerGadget` — the idiom this directory already uses (`CTruth` in `CoarsenedModels.lean`, `OrderFlow` in `OrderTransfer.lean`) — and the two one-word type names are renamed (`Colour` → `MarkerColour`, `pAtom`/`mAtom` → `dataAtom`/`markerAtom`). C23's naming assertions are then re-run in Phase 5. |
| C17's dead-declaration scan flags a declaration nothing names outside its declaring line | M | M | Several probe declarations (`ofut_pastDet`, `opast_futDet`, `deltaProp_of_no_p_between`, the four `cRel_*` conditions, `MarkerColour`) are used only as inputs to other proofs or not at all. Phase 1 requires every declaration's base identifier to appear in the module docstring's `## Main Results` list, and Phase 4 names the headline ones in the README's Key Results. |
| `@[simp] holds_iff` draws a new simpNF finding inside C16's gated batch | L | M | If simpNF reports a new finding on it, drop the `@[simp]` attribute and name `holds_iff` in the module docstring instead — the attribute is what currently keeps it out of C17's scan, so the two mitigations must be swapped together, not dropped together. |
| A measured axiom profile diverges from the report's reading | M | M | Phase 2 measures and pins the measured value; a divergence is a finding to record and investigate, never grounds to force either side. A measured `sorryAx` anywhere is a hard stop, phase `[BLOCKED]`. |
| The new `Independence` → `Expressiveness` import reads as a cycle risk | M | L | Nothing under `Metalogic/Expressiveness/` imports `Metalogic.Independence` (verified at plan time), so the edge is unreciprocated and assertion A's "exactly one directory-level cycle" count is unchanged. Phase 5 re-derives this by running the check rather than trusting this row. |
| `typst/generated/status.typ` is already stamped at an earlier commit than HEAD | L | H | The stamp is not part of Check 2's comparison; the repair path is `bash scripts/typst-sync-check.sh --fix` (needs a built library), which reports which fields the regeneration resolved. A stamp-only diff cannot be created by a no-op run. |
| The deployed `.claude/` tree is stale for the `core` extension | L | H | This repository has no `agent-system/` source store, so no plan step hand-patches `.claude/**`. Every command named below is a repository script under `scripts/` or `.claude/scripts/`; if a deployed instruction appears to conflict with observed behavior, trust the observed behavior and record it. |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 4 | 1 |
| 3 | 3 | 2 |
| 4 | 5 | 2, 3, 4 |

Phases within the same wave can execute in parallel.

### Phase 1: The `OpenFutureUndefinable` module and its aggregator wiring [COMPLETED]

**Goal**: Land `FormalSystem/Metalogic/Independence/OpenFutureUndefinable.lean` carrying the
probe's content as documented library code against the companion module's imported vocabulary,
add its import to `FormalSystem/Metalogic/Independence.lean` with the fourteenth numbered result
in that aggregator's docstring, and regenerate the library root so `lake build` compiles it.

**Tasks**:

- [x] Create `FormalSystem/Metalogic/Independence/OpenFutureUndefinable.lean` with the
      repository's standard four-line copyright header (copy the form from
      `FormalSystem/Metalogic/Independence/StabUndefinable.lean`).
- [x] Declare exactly two imports, in this order:
      `import FormalSystem.Metalogic.Expressiveness.OpenFutureElimination` and
      `import FormalSystem.Semantics.Frames.TranslationProduct`. The first supplies the shared
      determinedness vocabulary and reaches `FormalSystem.OpenLanguage` (and hence
      `FormalSystem.Init`, which C24 requires) transitively; the second supplies `colourClock`,
      `colourClock_isRegular`, `prodRel` and `prodRel_limit`. Do **not** import
      `FormalSystem.OpenLanguage` directly as a third import, and do **not** import the
      `Expressiveness` aggregator — name the one module whose content is used.
- [x] Open `namespace FormalSystem.Metalogic.Independence` and close it with the matching
      `end FormalSystem.Metalogic.Independence`, as every module in this directory does. Open
      `FormalSystem.Syntax`, `FormalSystem.Semantics`, `FormalSystem.PlusLanguage`,
      `FormalSystem.OpenLanguage` and `FormalSystem.Metalogic.Expressiveness`, and declare
      `variable {F : TaskFrame}`.
- [x] Transcribe `ofut_pastDet` and `opast_futDet` first, with the probe's term proofs unchanged
      and their docstrings stating what they rule out: a separator for `▷` must be a pair of
      worlds with L⁺-indistinguishable but `DeltaProp`-distinguishable **pasts**, so no pair
      differing only in the future can work. These are open-level facts about every
      `OpenFormula`; they are **not** instances of the companion's `PastDet`/`FutDet`, which are
      predicates on `PlusFormula`, and must not be restated as such.
- [x] Open `namespace MarkerGadget` for the gadget block, following this directory's own nested
      namespace idiom (`CTruth` in `CoarsenedModels.lean`, `OrderFlow` in `OrderTransfer.lean`),
      and close it with `end MarkerGadget`. The probe's one-word identifiers are generic and
      this directory's outer namespace is shared by 29 modules; the nesting is what keeps them
      safe, and C23's shadowing assertion is what would otherwise catch them.
- [x] Inside `MarkerGadget`, transcribe in the probe's order, with the probe's proofs unchanged:
      `dataAtom`, `markerAtom`, `holds`, `holds_iff`, `theta`, `nu`, `runAt`, `delta`, `probe`,
      `MarkedAt`, `theta_iff`, `theta_eq_iff`, `nu_iff_le`, `PRun`, `run_iff`, `DeltaProp`,
      `delta_iff`, `deltaProp_pastDet`, `dofut_probe_iff`, `ofut_neg_probe_iff`,
      `deltaProp_of_no_p_between`.
- [x] Rename the two atoms from the probe's `pAtom`/`mAtom` to `dataAtom`/`markerAtom`, and
      define each with `Atom.mkBase` (`Atom.mkBase "p"`, `Atom.mkBase "m"`) rather than the
      probe's anonymous-constructor form. `Atom.mkBase s` is `⟨s, none⟩` by definition
      (`FormalSystem/Syntax/Atom.lean`), so every transcribed proof still closes; the rename
      also avoids a base-identifier clash with `FormalSystem/Examples/Walkthrough.lean`'s own
      `pAtom`.
- [x] Restate `ofut_neg_probe_iff` through the companion's `ofutP_iff` rather than re-proving the
      `openTruthAt_ofPlus` unfolding inline: `OfutP M τ t probe.neg` is what
      `OpenTruthAt M τ t (.ofut (ofPlus probe.neg))` reduces to, and `ofutP_iff` is the bridge
      the companion module owns. The statement is unchanged; only the proof routes through the
      imported lemma. If that rewrite does not close in two attempts, keep the probe's proof
      verbatim and record the deviation — the statement is what matters and the probe's proof is
      already green.
- [x] After `end MarkerGadget`, add `open MarkerGadget` (or qualify at use sites) and declare
      `OfutPlusDefinable (F : TaskFrame) : Prop` — the probe's `Definable`, renamed because
      `Definable` is far too generic for this shared namespace and the tree's existing idiom is
      `X_not_plusDefinable` (`deterministic_not_plusDefinable`). Its docstring must state that
      this is the truth-level notion the companion module's `openTruthAt_iff_tr` is the positive
      instance of, and that truth-level definability is the **weaker, correct** target for a
      negative result: nothing here refutes a validity-level-only translation, which is the one
      thing the verdict does not settle.
- [x] Transcribe the probe's `not_definable_of_deltaProp_inexpressible` as
      `ofut_not_plusDefinable_of_deltaProp_inexpressible`, with the probe's proof unchanged. Its
      docstring must name both hypotheses for what they are: `hmarkers` is the frame's
      "enough worlds" condition, true at `colourFibre D` for every `D` though not compiled here
      (the related bridge-lemma task would compile it); `hinexpr` is **the paper step of record**,
      discharged in the research round by a GHR Lemma 12.4.2-style collapse argument transposed
      from their flow `T` to `ℚ`, and **not formalized in this tree**.
- [x] Open `section WitnessFrame` with `variable {D : TemporalOrder}` and transcribe
      `MarkerColour` (the probe's `Colour`, renamed), `cRel`, `cRel_reflection`, `cRel_comp`,
      `cRel_serial`, `cRel_zero`, `colourFibre` and the `colourFibre_isRegular` instance, with
      the probe's proofs unchanged; close with `end WitnessFrame`.
- [x] Give the `colourFibre` / `colourFibre_isRegular` block a docstring carrying the *Limit*
      fact, because it is the frame-constraint discovery worth keeping: *Limit* forbids the naive
      permissive rational-time frame — with states as atom colours, distinct states are unrelated
      at all small durations, so over a dense duration a finite-state history is a uniformly
      discrete step function, nothing accumulates, and there is no gap to anchor at. The
      repository's own `colourClock` removes the obstruction: the clock discharges *Limit*
      (`prodRel_limit`) and finiteness of `MarkerColour` discharges *Saturation*, giving a
      regular four-colour frame over **every** temporal order.
- [x] Give **every** declaration a `/-- ... -/` doc comment. `docBlame` sits inside C16's gated
      batch, so an undocumented declaration is a new failure; the probe leaves `theta_iff`,
      `holds`, `holds_iff`, `cRel_reflection`, `cRel_comp`, `cRel_serial`, `cRel_zero` and the
      `colourFibre_isRegular` instance undocumented, and those are the ones to write from
      scratch.
- [x] Give the two declarations that will carry theorem-index rows in Phase 3 —
      `ofut_not_plusDefinable_of_deltaProp_inexpressible` and `colourFibre_isRegular` — a doc
      comment whose last line is `Paper: — (reason)`, modelled on `openValid_reflectTime` in
      `FormalSystem/OpenLanguage/OpenReversal.lean`. C15's second assertion requires the value to
      start with `— (`; the reason is formalization-native (the manuscript states no
      definability question for the restricted modals and supplies no witness frame).
- [x] Keep `@[simp]` on `holds_iff`. It is the attribute that keeps the lemma out of C17's
      dead-declaration scan. **If** C16's simpNF reports a new finding on it in Phase 5, drop the
      attribute and name `holds_iff` in the module docstring's `## Main Results` list in the same
      edit — the two mitigations are a swap, not a pair to drop together.
- [x] Ensure every declaration's base identifier appears at least once outside its own declaring
      line, by listing them all in the module docstring's `## Main Results` block. C17's scan is
      what this satisfies, and `ofut_pastDet`, `opast_futDet`, `deltaProp_of_no_p_between`, the
      four `cRel_*` conditions and `MarkerColour` are the declarations at risk.
- [x] Write the module docstring (`/-! ... -/`) with these parts, and no others:
      (a) **what is proved**: the marker gadget (`theta_eq_iff` names the evaluation point,
      `nu_iff_le` names the closed past, `run_iff` names run membership without naming the run's
      lower endpoint), that `▷` computes `DeltaProp` exactly (`dofut_probe_iff`), and the
      conditional non-definability theorem;
      (b) **the verdict, as prose, with its status stated**: `▷` (and its mirror `◁`) is not
      L⁺-definable at `.Base` and not at `.Dense`, so with the companion module's positive result
      at `.ZTime`/`.RTime` the class split closes and `▷` is a genuine expressive extension of
      L⁺ over non-Dedekind-complete time — **and that this unconditional reading depends on
      `hinexpr`, which is not formalized in this tree**;
      (c) **what is not proved here**: `hinexpr` (the collapse of every L⁺ formula to one of
      `p`, `¬p`, `⊤`, `⊥` on GHR-nice `ℚ`-structures, plus the two structures of run order type
      `ℤ` and `ω + 1 + ω` that `DeltaProp` separates) is a derived argument in the style of
      GHR Lemma 12.4.2, not a quoted theorem, and is UNVERIFIED in Lean; `hmarkers` holds at
      `colourFibre D` for every `D` but is stated rather than compiled;
      (d) **the frame-constraint fact**: the *Limit* paragraph above, in short form, with
      `colourClock` named as the sanctioned way around it;
      (e) **why `DeltaProp` and not GHR's `γ₀⁺`**: `▷` yields pure-past properties
      (`ofut_pastDet`), so the target had to be the past-side `γ₀⁻`-shaped transposition;
      (f) a `## Main Results` bullet list naming every identifier;
      (g) a `## References` block citing `gabbay1994` (vol. 1, Lemmas 12.4.1-12.4.2, 12.4.7,
      §12.5) and `rabinovich2014` (§2.3, §7) by their `references.bib` keys — both keys were
      confirmed present at plan time; re-confirm before writing.
- [x] **No `specs/` path and no task number anywhere in the file.** Do not cite the research
      report or the probe by path: C9 gates task-number citations under `FormalSystem/` at zero,
      and both artifacts are disposable by design once this lands. The docstring must stand on
      its own with the GHR and Rabinovich citations.
- [x] Re-read `FormalSystem/Metalogic/Independence.lean` immediately before editing it (sibling
      task 559 is live on this tree), then add
      `import FormalSystem.Metalogic.Independence.OpenFutureUndefinable` to the existing import
      block, at its end.
- [x] In that same aggregator's module docstring, add the **fourteenth** numbered result and
      change the count sentence from `Thirteen results are carried here` to `Fourteen`. The entry
      must state the result in its conditional form and name `hinexpr` as the unformalized step;
      it must not read as "`▷` is not L⁺-definable at `.Base`/`.Dense`" full stop. The docstring
      also claims its list and `Independence/README.md`'s enumerate the same results in the same
      order, so the entry's position and wording must match what Phase 4 writes in the README.
- [x] Regenerate the library root: a new file under `FormalSystem/` adds an import line to
      `FormalSystem.lean`, which C33 asserts is byte-for-byte the `mk_all --lib FormalSystem`
      output. Regenerate it with C33's own render algorithm (dotted names sorted in code-point
      order, exactly one trailing newline) rather than hand-inserting the line, re-reading the
      file immediately beforehand because sibling 559 will also be adding a line to it.
- [x] Run the scoped guarded build and confirm green with no new warnings:
      `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build
      FormalSystem.Metalogic.Independence`. Never bare `lake`; read the verdict from the guard's
      exit status or its `result` subcommand, never from a pipe's exit code.
- [x] Confirm the new file has zero `sorry`, zero `axiom` declarations and no vacuous definition:
      `grep -n 'sorry\|^axiom ' <path>` returns nothing, and no declaration body is of the
      `:= True` / `:= trivial` / `:= Unit` shape.

**Timing**: 2 hours

**Depends on**: none

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: One new file of roughly 430-500 lines carrying 31 declarations
(2 open-level determinacy theorems, 1 `OfutPlusDefinable` predicate, 1 conditional
non-definability theorem, 20 declarations inside `MarkerGadget`, and 7 in `WitnessFrame`
including the `MarkerColour` abbrev and the `colourFibre_isRegular` instance), plus one import
line and two docstring edits in `FormalSystem/Metalogic/Independence.lean` and one regenerated
import line in `FormalSystem.lean`. The probe is 419 lines at plan time and the growth is
docstrings, namespacing and the renames, not new mathematics. Confirm at implementation time by
`wc -l` on the new path, by `lean_verify` resolving each fully-qualified name under
`FormalSystem.Metalogic.Independence`, and by `git diff --stat` showing single-digit insertion
counts and no deletions in the two existing files.

**Tier Justification**: `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build
FormalSystem.Metalogic.Independence` elaborates the new module together with the aggregator that
imports it, and the phase changes no existing signature — every edit is additive — so no other
module in the tree can break.

**Files to modify**:

- `FormalSystem/Metalogic/Independence/OpenFutureUndefinable.lean` - new module: the two
  open-level determinacy facts, the `MarkerGadget` block, `OfutPlusDefinable`, the conditional
  non-definability theorem, and the `colourFibre` witness frame with its regularity instance, all
  documented
- `FormalSystem/Metalogic/Independence.lean` - one import line; the fourteenth numbered result
  and the `Thirteen` → `Fourteen` count sentence in the module docstring
- `FormalSystem.lean` - the generated library root, regenerated for the new module (C33); no hand
  insertion

**Verification**:

- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build
  FormalSystem.Metalogic.Independence` — exit 0, no new warnings.
- Zero `sorry`, zero `axiom` declarations, no vacuous-definition body in the new file.
- Every declaration carries a `/-- ... -/` doc comment; the two future-rowed declarations each
  end theirs with a `Paper: — (` line.
- `grep -n 'specs/\|859' FormalSystem/Metalogic/Independence/OpenFutureUndefinable.lean
  FormalSystem/Metalogic/Independence.lean` returns nothing.
- `FormalSystem.lean` contains the new import in its sorted position and ends in exactly one
  newline; nothing under `FormalSystem/Metalogic/Expressiveness/` is modified.

---

### Phase 2: Re-measure the axiom profiles and pin the C14 baseline [COMPLETED]

**Goal**: Measure `#print axioms` on each landed declaration against the built library and pin
the measured values as matched heredoc pairs in `scripts/check-module-invariants.sh`, so the
module's axiom profile is asserted on every run rather than claimed in prose.

**Tasks**:

- [x] Run the unscoped guarded build first, so `import FormalSystem` elaborates for the
      measurement: `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build`.
- [x] **Measure, do not type.** Obtain `#print axioms` output (via `lean_verify` or a
      `lake env lean` snippet importing `FormalSystem`) for each of these eleven fully-qualified
      names:
      `FormalSystem.Metalogic.Independence.ofut_pastDet`,
      `...Independence.opast_futDet`,
      `...Independence.MarkerGadget.theta_eq_iff`,
      `...Independence.MarkerGadget.nu_iff_le`,
      `...Independence.MarkerGadget.run_iff`,
      `...Independence.MarkerGadget.delta_iff`,
      `...Independence.MarkerGadget.deltaProp_pastDet`,
      `...Independence.MarkerGadget.dofut_probe_iff`,
      `...Independence.MarkerGadget.ofut_neg_probe_iff`,
      `...Independence.ofut_not_plusDefinable_of_deltaProp_inexpressible`,
      `...Independence.colourFibre_isRegular`.
- [x] Compare the measured values against the research report's recorded reading —
      `[propext]` for `ofut_pastDet` and `opast_futDet`, and
      `[propext, Classical.choice, Quot.sound]` for the gadget chain and the non-definability
      theorem. `deltaProp_pastDet` and `colourFibre_isRegular` were not measured in the research
      round, so their values are new measurements with nothing to compare against. A divergence
      on any of the nine that *were* measured is a finding to record and investigate, **not** a
      reason to force either side: record the measured value and state the divergence in the
      handoff.
- [x] A measured `sorryAx` anywhere is a hard stop: mark the phase `[BLOCKED]` and report. Do not
      pin a baseline containing `sorryAx`.
- [x] Re-read `scripts/check-module-invariants.sh` immediately before editing it, then append the
      measured lines to `C14_BASELINE` (the `C14BASE` heredoc) as a contiguous block,
      immediately after the existing `FormalSystem.Metalogic.Expressiveness.ofutP_of_futDet`
      line — the natural position, since that block is the open-modal neighbourhood of the
      baseline and this module is its negative half.
- [x] Append the matching `#print axioms <name>` lines to the `C14LEAN` heredoc **in the same
      order and the same relative position** (immediately after its own
      `...Expressiveness.ofutP_of_futDet` line). The two heredocs are compared by exact string
      equality, so a position or order mismatch fails even when every value is right.
- [x] Add a short comment block above the new pair, in the style of the existing per-block
      comments, recording what these declarations pin and — explicitly — what they do **not**:
      they pin the axiom profile of a non-definability theorem **conditional on `hmarkers` and
      `hinexpr`**, the second of which stands for an argument this tree does not formalize, so no
      unconditional `.Base`/`.Dense` non-definability claim is asserted by their presence. Write
      this comment with no task number and no `specs/` path (C9 gates `scripts/` too).
- [x] Run `bash scripts/check-module-invariants.sh` and confirm the C14 `#print axioms` half
      reports PASS at the new baseline. The first, markdown-scanning half of C14 and the other
      checks are Phase 5's business.

**Timing**: 1 hour

**Depends on**: 1

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: Eleven matched pairs of lines (eleven in `C14BASE`, eleven in `C14LEAN`)
plus one comment block, in the single file `scripts/check-module-invariants.sh`; the baseline
carries eight `FormalSystem.Metalogic.Expressiveness.*` lines ending at `ofutP_of_futDet`
immediately before the insertion point at plan time. Confirm at implementation time by a
`grep -c` for the eleven new names returning the same count on each side of the pair, and by the
C14 `#print axioms` half passing.

**Tier Justification**: `bash scripts/check-module-invariants.sh`'s C14 `#print axioms` half
compares the two heredocs against live `#print axioms` output by exact string equality, which is
precisely the edit this phase makes and the only thing it can break.

**Files to modify**:

- `scripts/check-module-invariants.sh` - eleven matched lines appended to the `C14BASE` and
  `C14LEAN` heredocs in the same relative position, plus one explanatory comment block recording
  that these pin a conditional result

**Verification**:

- `bash scripts/check-module-invariants.sh` — the C14 `#print axioms` half reports
  `PASS C14 every pinned declaration matches its axiom baseline`.
- Every pinned line's value is the measured `#print axioms` output, with no `sorryAx` in any of
  them.
- `grep -n '859\|specs/' scripts/check-module-invariants.sh` shows no new occurrence introduced by
  this phase.

---

### Phase 3: Two theorem-index rows, in the conditional form [COMPLETED]

**Goal**: Add exactly two rows to `docs/theorem-index.md`'s `### Characterization and
definability` table — the marker-gadget reduction and the witness frame's regularity — each
stating its conditional form, with a short lead note recording that the unconditional verdict is
not machine-checked.

**Tasks**:

- [x] Re-read `docs/theorem-index.md` immediately before editing. **This file is in concurrent
      sibling task 559's declared `file_scope`**; a foreign hunk is that sibling's in-flight
      edit, to be reported rather than reverted, and staging must name this file explicitly and
      nothing else.
- [x] Add the two rows to the `### Characterization and definability` table, in its exact
      six-column shape (`| Paper label | Statement | Lean name | File | Frame class | Axioms |`),
      immediately after the existing `stabNotDefinable` row — the two direct analogues
      (`deterministic_not_plusDefinable`, `stabNotDefinable`) already sit in that table, which is
      why this result belongs there rather than in `### Expressiveness` (the companion's band) or
      `### L^▷` (validity and refutation rows only).
- [x] Paper-label cell: `—` for both (formalization-native; the manuscript states no definability
      question for the restricted modals and supplies no witness frame). C15's second assertion
      then requires each declaration's own `Paper:` line to read `— (reason)`, which Phase 1
      wrote.
- [x] Lean-name cells: **fully qualified** —
      `FormalSystem.Metalogic.Independence.ofut_not_plusDefinable_of_deltaProp_inexpressible` and
      `FormalSystem.Metalogic.Independence.colourFibre_isRegular`. A bare base identifier is not
      a row key.
- [x] File cells: `FormalSystem/Metalogic/Independence/OpenFutureUndefinable.lean`, **path only,
      no line numbers** (C20 tier 2).
- [x] Frame-class cells: `—` for the reduction theorem (it is stated at an arbitrary
      `F : TaskFrame`, class-generic); for `colourFibre_isRegular`, the cell is the class whose
      `Sat` predicate the instance discharges — `Sat .Base F` is definitionally `F.IsRegular`
      (`FormalSystem/Semantics/FrameClassValidity.lean`), so `Base` is the value to write.
      Re-confirm that reading against the `Sat` table before writing it rather than taking it
      from this sentence.
- [x] Axioms cells: exactly as measured in Phase 2, with the `pinned:C14` token —
      `pcq pinned:C14` where the measured value is `[propext, Classical.choice, Quot.sound]`, and
      anything else written out literally. This column is generated from the baselines, never
      typed independently of them.
- [x] **Statement cells state the conditional.** The reduction row must open with its two
      hypotheses — "Given an enough-worlds condition on the frame and the inexpressibility of the
      gap-anchored past property `DeltaProp` — the second a derived collapse argument this tree
      does not formalize — the open-future modal is not L⁺-definable at that frame". No row may
      read "`▷` is not L⁺-definable at `.Base`/`.Dense`" full stop. The regularity row states
      the frame fact only: the four-colour clock frame is regular over **every** temporal order,
      the clock discharging *Limit* and finiteness discharging *Saturation*.
- [x] Do **not** add a row for the unconditional verdict, for `hinexpr`, or for any
      `MarkerGadget` lemma. The unconditional claim lives only in the module docstring, cited to
      GHR; the gadget lemmas are pinned by C14 without being rowed, exactly as the companion
      round pinned `openTruthAt_iff_tr` without rowing it.
- [x] Add a two-sentence lead note immediately above that table, modelled in shape on the
      `### Expressiveness` section's own lead: it must say that the two open-future
      non-definability rows are conditional on an unformalized inexpressibility hypothesis, that
      the unconditional `.Base`/`.Dense` verdict is therefore **not** machine-checked and is
      recorded in the module docstring with its literature citation, and that nothing in the band
      bears on `.ZTime`/`.RTime`, where the companion elimination layer gives the positive
      result.
- [x] **No `specs/` path and no task number** in any added row or sentence: C9D gates `docs/` at
      zero, and C12 requires every slash-shaped source path in `docs/` to resolve — a
      `specs/859_...` path fails the moment the task directory is archived.
- [x] Run `bash scripts/check-module-invariants.sh` and confirm C15's second assertion
      (`all N theorem-index row(s) carry their anchor`) PASSes with the row count increased by
      two, and that C12 and C13 PASS.

**Timing**: 0.75 hours

**Depends on**: 2

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: Two new rows plus one two-sentence lead note in the single file
`docs/theorem-index.md`, whose `### Characterization and definability` table carries 17 rows and
no lead paragraph at plan time, against 383 pipe-prefixed table lines in the file overall.
Confirm at implementation time by `git diff --stat` on that one path showing a single-digit
insertion count, and by C15's second assertion reporting a row total exactly two higher than its
pre-phase reading.

**Tier Justification**: `bash scripts/check-module-invariants.sh`'s C15 second assertion plus C12
and C13 lint this one markdown file's rows, source paths and relative links, which is the entire
blast radius of a rows-only edit to the ledger.

**Files to modify**:

- `docs/theorem-index.md` - two rows added to the `### Characterization and definability` table,
  plus a two-sentence lead note stating the conditionality and the `.ZTime`/`.RTime`
  non-involvement

**Verification**:

- `bash scripts/check-module-invariants.sh` — C15's second assertion PASSes at a row total two
  higher than before; C12 and C13 PASS.
- Both added rows: Paper label `—`, fully qualified Lean name, path-only File cell, Axioms cell
  equal to the Phase 2 measurement with its `pinned:C14` token.
- Read-through: neither added row nor the lead note asserts the unconditional verdict is
  machine-checked, and neither claims anything at `.ZTime` or `.RTime`.
- `grep -n '859' docs/theorem-index.md` shows no new occurrence.

---

### Phase 4: The directory README, the fourteenth result, and the regenerated inventories [COMPLETED]

**Goal**: Record the module in `FormalSystem/Metalogic/Independence/README.md` in that file's
existing shapes — the fourteenth numbered result, Key Results bullets, the Dependencies bullet,
the `Last verified` dates — and regenerate every machine-owned block the new file changes.

**Tasks**:

- [x] Add the **fourteenth** numbered result to the README's opening enumeration and change
      `Thirteen results are carried here` to `Fourteen`. The entry must match Phase 1's
      aggregator-docstring entry in position and substance: the README's own sentence claims the
      two lists enumerate the same results in the same order, and that claim has to stay true.
      State the result conditionally and name `hinexpr` as the unformalized step; note that the
      companion elimination layer carries the positive half at `.ZTime`/`.RTime`, so the two
      together close the class split.
- [x] Add Key Results bullets in that section's existing
      `` `name` (`File.lean`) — description `` shape, naming the headline declarations and the
      ones C17 would otherwise flag:
      `ofut_not_plusDefinable_of_deltaProp_inexpressible`, `colourFibre_isRegular`,
      `ofut_pastDet` / `opast_futDet`, the gadget chain
      (`MarkerGadget.theta_eq_iff`, `nu_iff_le`, `run_iff`, `delta_iff`, `dofut_probe_iff`,
      `ofut_neg_probe_iff`), `MarkerGadget.deltaProp_of_no_p_between` (the non-vacuity witness),
      `MarkerColour` and the four `cRel_*` frame conditions. Each bullet states what the
      declaration is for, and the headline bullet states the conditionality.
- [x] Update the README's `## Dependencies` section: its `**Imports from**` bullet currently
      names `FormalSystem.Semantics`, `FormalSystem.Metalogic.Soundness`,
      `FormalSystem.ProofSystem` and Mathlib's `ℚ ⧸ ℤ`, and must now also name
      `FormalSystem.Metalogic.Expressiveness.OpenFutureElimination` (the shared determinedness
      vocabulary) and `FormalSystem.Semantics.Frames.TranslationProduct` (`colourClock`).
- [x] Note that the README's `## Modules` table is a **generated** block
      (`<!-- BEGIN GENERATED: inventory dir=FormalSystem/Metalogic/Independence -->`), so the new
      module's row is produced by the regeneration step below and must **not** be hand-written.
      Do not hand-edit anything between a `BEGIN GENERATED` / `END GENERATED` pair.
- [x] Update both trailing `Last verified` dates to the implementation date (the file carries the
      date twice, at `**Last verified**:` and at `*Last verified: ...*`); `readme-lint.sh`
      Check 4 reports a date older than the directory's last commit.
- [x] Regenerate the machine-owned inventory blocks, which the new file changes in two places —
      this directory's own `## Modules` table and the `Independence/` file/line row in
      `FormalSystem/Metalogic/README.md` (29 files / 8,619 lines at plan time), plus that file's
      `Independence.lean` line-count row: `bash scripts/check-module-invariants.sh
      --emit-inventory`. Re-read both markdown files immediately beforehand — sibling 559 adds a
      module under `FormalSystem/Metalogic/` too, so its regeneration touches the same rows.
      *(deviation: altered — `--emit-inventory` rewrote FOUR files, not the two named here:
      `FormalSystem/README.md` (the `../FormalSystem.lean` line count) and the repository-root
      `README.md` (the live file/line/comment totals) also carry generated inventory blocks that
      the new module changes. All four diffs are attributable solely to this module; INV had
      flagged all four as stale.)*
- [x] Confirm the regeneration is idempotent and the gated INV check is clean:
      `bash scripts/check-module-invariants.sh --emit-inventory --check` exits 0.
- [x] Regenerate the typst count surface, which the new module changes
      (`formalsystem-file-count` 720 and `formalsystem-line-count` 378026 at plan time), via the
      sanctioned repair path and not by calling the generator directly:
      `bash scripts/typst-sync-check.sh --fix`. It needs a built library (it reads a
      per-declaration axiom report out of the build), so run it after Phase 1's build; it reports
      which fields the regeneration resolved and never stages anything itself.
      *(deviation: altered — this step ran in PHASE 1, not here: the `typst-sync-check`
      pre-commit gate refused Phase 1's commit because the new module changed
      `formalsystem-line-count`, so the regeneration had to precede the first commit.
      `typst/generated/status.typ` is in Phase 1's commit; this phase only re-verified it.)*
- [x] Run `bash scripts/typst-sync-check.sh` and confirm exit 0, with Check 2 in sync. A Check 1
      finding about an identifier this task did not touch is pre-existing and not this phase's to
      fix; a Check 2 mismatch after `--fix` is.
- [x] Run `bash scripts/readme-lint.sh FormalSystem` and confirm exit 0 (Checks 1 and 3 are the
      gated ones; a `NOT LISTED` or stale-date report for an untouched directory is pre-existing).
- [x] **No task number and no `specs/` path** in any README edit: C9 gates `README.md` and
      `FormalSystem/` at zero, and C5 requires every module-shaped path in non-specs markdown to
      resolve.

**Timing**: 1.25 hours

**Depends on**: 1

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: In `FormalSystem/Metalogic/Independence/README.md` (433 lines at plan
time): one new numbered entry, one changed count word, roughly six Key Results bullets, one
changed Dependencies bullet and two dates — plus whatever `--emit-inventory` rewrites inside the
generated blocks of that file and of `FormalSystem/Metalogic/README.md`, and whatever
`typst-sync-check.sh --fix` rewrites in `typst/generated/status.typ` (expected: the file and
line counts, and the commit stamp). Confirm at implementation time by `git diff --stat` on
exactly those three paths and by `--emit-inventory --check` plus `typst-sync-check.sh` both
exiting 0 on a second run.

**Tier Justification**: `bash scripts/check-module-invariants.sh --emit-inventory --check`,
`bash scripts/typst-sync-check.sh` and `bash scripts/readme-lint.sh FormalSystem` together cover
every surface this phase touches — the generated blocks and the typst counts by byte equality,
the hand-written README by link and presence lint — and the phase elaborates no Lean of its own.

**Files to modify**:

- `FormalSystem/Metalogic/Independence/README.md` - the fourteenth numbered result and the count
  word, Key Results bullets, the Dependencies `Imports from` bullet, both `Last verified` dates;
  its `## Modules` table only via `--emit-inventory`
- `FormalSystem/Metalogic/README.md` - generated inventory blocks only, rewritten by
  `--emit-inventory`; no hand edit
- `typst/generated/status.typ` - regenerated by `scripts/typst-sync-check.sh --fix`; no hand edit

**Verification**:

- `bash scripts/check-module-invariants.sh --emit-inventory --check` — exit 0 (a second run would
  change no byte).
- `bash scripts/typst-sync-check.sh` — exit 0 with Check 2 in sync.
- `bash scripts/readme-lint.sh FormalSystem` — exit 0.
- The new module's row is present in the generated `## Modules` table; the numbered enumeration
  reads `Fourteen` and its new entry matches the aggregator docstring's entry in position and
  substance.
- `grep -n '859' FormalSystem/Metalogic/Independence/README.md FormalSystem/Metalogic/README.md
  typst/generated/status.typ` shows no new occurrence.

---

### Phase 5: Full verification and axiom audit [COMPLETED]

**Goal**: Establish on the whole repository that the module is landed and compiled, sorry-free
and axiom-pinned at its measured profile, that every gate holds at its re-derived baseline, that
the layering is legal with the cycles allowlist untouched, and that no surface overclaims the
verdict.

**Tasks**:

- [x] Run the unscoped guarded build: `bash .claude/scripts/lake-build-guard.sh build --timeout
      1800 -- build`. Never bare `lake`. Read the verdict from the guard's exit status or its
      `result` subcommand, never from a pipe's exit code.
- [x] Re-measure axioms on all eleven pinned fully-qualified names with `lean_verify` (or
      `#print axioms`) and confirm each matches the value Phase 2 pinned. A declaration that has
      acquired `sorryAx` is a hard stop: mark the phase `[BLOCKED]` and report. A declaration
      that has acquired `Classical.choice` where Phase 2 measured none is a regression to
      investigate, not a new baseline.
- [x] Run `bash scripts/check-module-invariants.sh` and assert **per-check, not by exit code**:
      INV PASS, C2 PASS, C3 (zero structural `sorry`) PASS, C4/C5 PASS, C9 PASS, C9D PASS, C12
      PASS, C13 PASS, both C14 halves PASS, both C15 assertions PASS, C17's gated count at its
      pre-task baseline, C20 PASS, C21 PASS, C23 PASS (no new Uppercase_x name and no new
      outer-shadows-inner bare-declaration pair — the nested `MarkerGadget` namespace and the
      `MarkerColour`/`dataAtom`/`markerAtom` renames exist for this check), C24 PASS, C33 PASS,
      and the C16 finding list byte-identical to its pre-task baseline. The script's nonzero exit
      on a pre-existing C16 finding is not this task's to fix; a NEW finding is — and a new
      simpNF finding on `holds_iff` is handled by the attribute/docstring swap recorded in
      Phase 1, applied in Phase 1's file.
- [x] Run `bash scripts/check-metalogic-cycles.sh` and require **exit 0** on all three
      assertions, with the upward import set still exactly the recorded 8 lines and the
      allowlist file untouched. Both new imports are legal: `Metalogic` (layer 3) →
      `Semantics.Frames.TranslationProduct` (layer 1) is downward, and `Independence` →
      `Expressiveness` is a same-layer directory edge that is unreciprocated (nothing under
      `Metalogic/Expressiveness/` imports `Metalogic.Independence`), so assertion A's
      exactly-one-cycle count is unchanged. A nonzero exit here means an import landed the wrong
      way round. **Do not edit the allowlist.**
- [x] Run `bash scripts/check-copyright-headers.sh` and confirm the new module's header is
      accepted.
- [x] Confirm `git status --short` shows changes in exactly the eight intended paths
      (the new module; `FormalSystem/Metalogic/Independence.lean`; `FormalSystem.lean`;
      `scripts/check-module-invariants.sh`; `docs/theorem-index.md`;
      `FormalSystem/Metalogic/Independence/README.md`; `FormalSystem/Metalogic/README.md`;
      `typst/generated/status.typ`) and **nothing** under
      `FormalSystem/Metalogic/Expressiveness/`, nothing in
      `scripts/check-metalogic-cycles.sh`, and nothing under `specs/evidence/`. A foreign
      modification in any shared path is sibling task 559's in-flight edit: check `git log` to
      confirm it is not this task's own, then STOP and report it rather than reverting or
      dismissing it.
- [x] Confirm zero `sorry`, zero `axiom` declarations and zero vacuous definitions in the new
      module: `grep -n 'sorry\|^axiom '
      FormalSystem/Metalogic/Independence/OpenFutureUndefinable.lean` returns nothing, and no
      declaration body is of the `:= True` / `:= trivial` / `:= Unit` shape.
- [x] Re-read every landed prose surface — the module docstring, the aggregator's numbered entry
      and count sentence, the README's numbered entry, Key Results bullets and Dependencies
      bullet, the two theorem-index rows and their lead note, and the invariants-script comment
      block — against the overclaim test: **no pinned row or generated cell may state the
      unconditional `.Base`/`.Dense` verdict as machine-checked**; `hinexpr` must be named as
      unformalized wherever the verdict is stated; `hmarkers` must be described as stated rather
      than compiled; no surface may make a completeness or decidability claim for L^▷ or L⁺; and
      no surface may claim the validity-level-only translation is refuted, which it is not.
- [x] Confirm the two enumerations still agree: the numbered list in
      `FormalSystem/Metalogic/Independence.lean`'s docstring and the one in
      `FormalSystem/Metalogic/Independence/README.md` must carry the same fourteen results in the
      same order, which is what both files claim of themselves.
- [x] Confirm no landed file cites a `specs/` path or a task number:
      `grep -rn '859\|specs/859' FormalSystem/ docs/theorem-index.md
      scripts/check-module-invariants.sh typst/generated/status.typ FormalSystem.lean` returns
      nothing.
- [x] Run `bash .claude/scripts/validate-artifact.sh
      specs/859_qtime_open_future_definability_base_dense/plans/01_open-future-undefinable-module.md
      plan` and confirm no errors.

**Timing**: 1.25 hours

**Depends on**: 2, 3, 4

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: Eight changed paths in all, enumerated in the `git status` step above, with
two gate baselines carried in from this round: `check-metalogic-cycles.sh` exit 0 at exactly 8
recorded upward lines, and `check-module-invariants.sh` exiting nonzero only on a pre-existing
C16 finding. Both figures are **re-derived in this phase by running the commands**, never trusted
from this sentence.

**Files to modify**:

- none planned - this phase runs verification commands only and edits no file; any repair it
  triggers is made in the phase that owns the file (Phase 1, 2, 3 or 4)

**Verification**:

This phase's complete gate set for this task's surfaces, all of which must be observed green in
this dispatch and none of which may be trusted on sight. This repository carries no
`agent-system/` source store and every path this task modifies is project-domain, so neither
`run-all.sh --only` nor `verify-deploy.sh --only-gate` applies and no harness suite covers any of
them; the scoped set that does cover them is the repository Lean/ledger gate set below, run in
full:

- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build` — unscoped, exit 0.
- `lean_verify` on all eleven pinned fully-qualified names, each matching the Phase 2
  measurement, with no `sorryAx` anywhere.
- `bash scripts/check-module-invariants.sh` — INV, C2, C3, C4, C5, C9, C9D, C12, C13, both C14
  halves, both C15 assertions, C20, C21, C23, C24 and C33 all PASS; C16 and C17 at their
  pre-task baselines.
- `bash scripts/check-metalogic-cycles.sh` — exit 0 on all three assertions, upward import set
  unchanged at 8 lines, the allowlist file untouched.
- `bash scripts/check-copyright-headers.sh` — the new module accepted.
- `bash scripts/check-module-invariants.sh --emit-inventory --check` — exit 0.
- `bash scripts/typst-sync-check.sh` — exit 0.
- `bash scripts/readme-lint.sh FormalSystem` — exit 0.
- Zero `sorry`, zero `axiom`, zero vacuous definitions in the new module.
- The overclaim read-through passes on all landed surfaces; the two fourteen-result enumerations
  agree; `git status --short` shows exactly the eight intended paths and no foreign hunk.

## Lean Challenge Statements

These are the signatures the module must land, pinned before implementation. Bodies are `sorry`
here **only** so the signatures are machine-comparable; the probe proves every one of them in
full and the implementation transcribes those proofs. No declaration below takes an
`[F.IsRegular]` binder: the marker gadget needs only the existence of one world with the right
future, which is strictly weaker than pasting, and regularity enters the result solely through
`colourFibre_isRegular`, which puts the witness frame in the class.

```lean
namespace FormalSystem.Metalogic.Independence

open FormalSystem.Syntax FormalSystem.Semantics FormalSystem.PlusLanguage
open FormalSystem.OpenLanguage FormalSystem.Metalogic.Expressiveness

variable {F : TaskFrame}

theorem ofut_pastDet (M : TaskModel F) (τ σ : WorldHistory F) (t : F.Duration)
    (hag : AgreeUpTo τ σ t) (ψ : OpenFormula) :
    OpenTruthAt M τ t (.ofut ψ) ↔ OpenTruthAt M σ t (.ofut ψ) := sorry

theorem opast_futDet (M : TaskModel F) (τ σ : WorldHistory F) (t : F.Duration)
    (hag : AgreeFrom τ σ t) (ψ : OpenFormula) :
    OpenTruthAt M τ t (.opast ψ) ↔ OpenTruthAt M σ t (.opast ψ) := sorry

namespace MarkerGadget

def dataAtom : Atom := Atom.mkBase "p"
def markerAtom : Atom := Atom.mkBase "m"

def holds (M : TaskModel F) (τ : WorldHistory F) (s : F.Duration) (a : Atom) : Prop :=
  M.valuation (τ.state s) a

@[simp] theorem holds_iff (M : TaskModel F) (τ : WorldHistory F) (s : F.Duration) (a : Atom) :
    PlusTruthAt M τ s (.atom a) ↔ holds M τ s a := sorry

def theta : PlusFormula :=
  (PlusFormula.atom markerAtom).neg.and (PlusFormula.allFuture (.atom markerAtom))
def nu : PlusFormula := theta.or (PlusFormula.someFuture theta)
def runAt : PlusFormula :=
  (PlusFormula.atom dataAtom).and (PlusFormula.allFuture (nu.imp (.atom dataAtom)))
def delta : PlusFormula :=
  PlusFormula.snce (((PlusFormula.atom dataAtom).and runAt.neg).neg)
    (PlusFormula.atom dataAtom).neg
def probe : PlusFormula := theta.and delta

def MarkedAt (M : TaskModel F) (ρ : WorldHistory F) (t : F.Duration) : Prop :=
  ¬ holds M ρ t markerAtom ∧ ∀ s, t < s → holds M ρ s markerAtom

theorem theta_iff (M : TaskModel F) (ρ : WorldHistory F) (s : F.Duration) :
    PlusTruthAt M ρ s theta ↔ MarkedAt M ρ s := sorry

theorem theta_eq_iff (M : TaskModel F) (ρ : WorldHistory F) (t : F.Duration)
    (h : MarkedAt M ρ t) (s : F.Duration) :
    PlusTruthAt M ρ s theta ↔ s = t := sorry

theorem nu_iff_le (M : TaskModel F) (ρ : WorldHistory F) (t : F.Duration)
    (h : MarkedAt M ρ t) (v : F.Duration) :
    PlusTruthAt M ρ v nu ↔ v ≤ t := sorry

def PRun (M : TaskModel F) (ρ : WorldHistory F) (v t : F.Duration) : Prop :=
  holds M ρ v dataAtom ∧ ∀ s, v < s → s ≤ t → holds M ρ s dataAtom

theorem run_iff (M : TaskModel F) (ρ : WorldHistory F) (t : F.Duration)
    (h : MarkedAt M ρ t) (v : F.Duration) :
    PlusTruthAt M ρ v runAt ↔ PRun M ρ v t := sorry

def DeltaProp (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration) : Prop :=
  ∃ u, u < t ∧ ¬ holds M τ u dataAtom ∧
    ∀ v, u < v → v < t → holds M τ v dataAtom → PRun M τ v t

theorem delta_iff (M : TaskModel F) (ρ : WorldHistory F) (t : F.Duration)
    (h : MarkedAt M ρ t) :
    PlusTruthAt M ρ t delta ↔ DeltaProp M ρ t := sorry

theorem deltaProp_pastDet (M : TaskModel F) (τ σ : WorldHistory F) (t : F.Duration)
    (hag : AgreeUpTo τ σ t) : DeltaProp M τ t ↔ DeltaProp M σ t := sorry

theorem dofut_probe_iff (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (hm : ¬ holds M τ t markerAtom)
    (hex : ∃ ρ : WorldHistory F, AgreeUpTo τ ρ t ∧ ∀ s, t < s → holds M ρ s markerAtom) :
    (∃ ρ : WorldHistory F, AgreeUpTo τ ρ t ∧ PlusTruthAt M ρ t probe) ↔ DeltaProp M τ t := sorry

theorem ofut_neg_probe_iff (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (hm : ¬ holds M τ t markerAtom)
    (hex : ∃ ρ : WorldHistory F, AgreeUpTo τ ρ t ∧ ∀ s, t < s → holds M ρ s markerAtom) :
    OpenTruthAt M τ t (.ofut (ofPlus probe.neg)) ↔ ¬ DeltaProp M τ t := sorry

theorem deltaProp_of_no_p_between (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    {u : F.Duration} (hut : u < t) (hnp : ¬ holds M τ u dataAtom)
    (hclear : ∀ v, u < v → v < t → ¬ holds M τ v dataAtom) :
    DeltaProp M τ t := sorry

end MarkerGadget

open MarkerGadget

def OfutPlusDefinable (F : TaskFrame) : Prop :=
  ∃ tr : OpenFormula → PlusFormula, ∀ (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (φ : OpenFormula), OpenTruthAt M τ t φ ↔ PlusTruthAt M τ t (tr φ)

theorem ofut_not_plusDefinable_of_deltaProp_inexpressible
    (hmarkers : ∀ (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration),
      ¬ holds M τ t markerAtom →
        ∃ ρ : WorldHistory F, AgreeUpTo τ ρ t ∧ ∀ s, t < s → holds M ρ s markerAtom)
    (hinexpr : ∀ ψ : PlusFormula, ∃ (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration),
      ¬ holds M τ t markerAtom ∧ ¬ (DeltaProp M τ t ↔ PlusTruthAt M τ t ψ)) :
    ¬ OfutPlusDefinable F := sorry

section WitnessFrame

variable {D : TemporalOrder}

abbrev MarkerColour := Bool × Bool

def cRel : MarkerColour → ↑D → MarkerColour → Prop := fun w d u => d = 0 → u = w

theorem cRel_reflection : ∀ w (d : ↑D) u, cRel w d u ↔ cRel u (-d) w := sorry
theorem cRel_comp : TaskFrame.Compositional (cRel (D := D)) := sorry
theorem cRel_serial : TaskFrame.Serial (cRel (D := D)) := sorry
theorem cRel_zero : ∀ w u, cRel (D := D) w 0 u → u = w := sorry

def colourFibre (D : TemporalOrder) : FrameOver D :=
  colourClock (W := MarkerColour) cRel cRel_reflection cRel_comp cRel_serial cRel_zero

instance colourFibre_isRegular : (colourFibre D).IsRegular := sorry

end WitnessFrame

end FormalSystem.Metalogic.Independence
```

Two fidelity notes the implementation must not quietly relax. First, `ofut_pastDet` and
`opast_futDet` quantify over **every** `OpenFormula` `ψ`, not over an embedded L⁺ formula —
weakening either to `ofPlus φ` would make them restatements of the companion module's `PastDet`
machinery and throw away exactly the content that rules out future-side separators. Second,
`cRel_comp`, `cRel_serial` and `cRel_zero` are stated against the repository's own
`TaskFrame.Compositional` / `TaskFrame.Serial` predicates, so `colourFibre` is built by the
repository's `colourClock` and not by a local re-derivation; a hand-rolled frame would not carry
`colourClock_isRegular` and the regularity row would not be the fact the research round
established.

## Testing & Validation

- [x] `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build` exits 0 with no
      new warnings.
- [x] Zero `sorry`, zero `axiom` declarations and zero vacuous definitions in the new module.
- [x] All eleven pinned declarations' `#print axioms` output matches the C14 baseline exactly,
      with no `sorryAx` anywhere.
- [x] `bash scripts/check-module-invariants.sh`: every check named in Phase 5 PASSes, with C16
      and C17 at their pre-task baselines.
- [x] `bash scripts/check-metalogic-cycles.sh` exits 0 with the 8-line allowlist unchanged and
      untouched.
- [x] `bash scripts/check-module-invariants.sh --emit-inventory --check`,
      `bash scripts/typst-sync-check.sh`, `bash scripts/readme-lint.sh FormalSystem` and
      `bash scripts/check-copyright-headers.sh` each exit 0.
- [x] The two theorem-index rows carry their measured `pinned:C14` axiom cells and their
      conditional statements; no row claims the unconditional verdict.
- [x] The overclaim read-through passes on every landed surface: `hinexpr` is named as
      unformalized wherever the verdict appears, `hmarkers` is described as stated rather than
      compiled, and nothing asserts a completeness, decidability, or validity-level-refutation
      claim.
- [x] The fourteen-result enumerations in `Independence.lean` and
      `Independence/README.md` agree in content and order.
- [x] No landed file cites a `specs/` path or a task number.
- [x] Nothing under `FormalSystem/Metalogic/Expressiveness/`, nothing in
      `scripts/check-metalogic-cycles.sh`, and nothing under `specs/evidence/` is modified.

## Artifacts & Outputs

- `FormalSystem/Metalogic/Independence/OpenFutureUndefinable.lean` — the new library module.
- `FormalSystem/Metalogic/Independence.lean` — import line plus the fourteenth numbered result.
- `FormalSystem.lean` — regenerated library root.
- `scripts/check-module-invariants.sh` — eleven matched C14 baseline pairs and a comment block.
- `docs/theorem-index.md` — two conditional rows and a lead note.
- `FormalSystem/Metalogic/Independence/README.md` — fourteenth result, Key Results bullets,
  Dependencies bullet, dates, regenerated `## Modules` row.
- `FormalSystem/Metalogic/README.md` — regenerated inventory blocks.
- `typst/generated/status.typ` — regenerated counts.
- One summary under `specs/859_qtime_open_future_definability_base_dense/summaries/` at
  completion.
- After this lands, the report and probe under this task directory are safely disposable: their
  durable content lives in the module, its docstring and the ledger, which is the point of the
  task.

## Rollback/Contingency

Every phase is additive, so rollback is per-phase and local. Because a concurrent sibling is live
on this working tree, rollback must never use a reverting `git-snapshot.sh` invocation and never
a directory or glob `git add`; take an ordinary defensive checkpoint with
`bash .claude/scripts/git-snapshot.sh 859 --no-revert` before any risky edit, and revert by
re-editing the specific hunks this task introduced.

- **Phase 1 fails to compile**: the module is the only new file and nothing imports it except the
  aggregator, so removing its import line from `FormalSystem/Metalogic/Independence.lean` and
  regenerating `FormalSystem.lean` restores the pre-task build exactly. Keep the file on disk and
  mark the phase `[BLOCKED]` with the goal state reached.
- **A measured axiom profile contains `sorryAx`**: hard stop. Do not pin the baseline; mark
  Phase 2 `[BLOCKED]` and report, since a `sorryAx` in a transcribed probe proof means the
  transcription diverged from the probe.
- **A gate fails at a baseline this plan recorded**: re-derive the baseline by running the
  command rather than trusting the plan's number, and record the divergence. A pre-existing C16
  or C17 finding is not this task's to fix; a new one is, and is fixed in the phase that owns the
  file.
- **A foreign hunk appears in a shared path**: check `git log` to confirm the work is not this
  task's own, then STOP and report it. Do not revert it and do not proceed past it.
- **The conditionality discipline is found violated in Phase 5**: repair the offending prose in
  the phase that owns the file and re-run that phase's verification; an overstated row is a
  correctness defect, not a cosmetic one, and the task does not complete with one standing.
