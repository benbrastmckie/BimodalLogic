# Implementation Plan: Task #799

- **Task**: 799 - Choice-free `StateOccurs` for the state-set applications
- **Status**: [IMPLEMENTING]
- **Effort**: 4.75 hours
- **Dependencies**: the state-set pin task (landed — `StateOccurs.of_isRegular` and the three
  `_of_isRegular` corollaries are in the tree)
- **Research Inputs**: `specs/799_choice_free_state_occurrence_applications/reports/01_choice-free-state-occurrence.md`
- **Artifacts**: plans/01_choice-free-state-occurrence.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

The paper's cut footnote to `lem:state-set` claims the appeals to `cor:occurrence` — and hence to
Zorn — are inessential at the frames where the lemma is *applied*, because a possible world
through a given state at a given time is there exhibited explicitly as a translation. This task
builds that second route in Lean, as one new leaf module, without touching the general
two-hypothesis originals or the Zorn-routed `_of_isRegular` forms. Two layers land: an
**absolutely choice-free** layer over an arbitrary duration group, routing the translation flow
through `ShiftSet` (whose `sep` field supplies the *Limit* obligation directly, bypassing
`TaskFrame.limit_of_shift`, the single `Classical.choice` source in the neighbourhood); and the
same (H1)/(H2) discharge plus corollaries at `translationFrame D`, where the frame constant's own
profile makes only a **relative** pin available. A read-only audit of every consumer in
`DeterminismUndefinable.lean` and a three-route record in `StateSetTruth.lean`'s module docstring
complete the four deliverables. Done means `lake build` green for the whole project, zero new
`sorry`, `check-module-invariants.sh` green, the existing axiom pin in
`DeterminismUndefinable.lean` still passing with that file byte-identical to HEAD, and every new
declaration's measured `#print axioms` profile recorded in a docstring.

### Research Integration

The report's four load-bearing findings are the plan's premises, and all four were **re-measured
at plan time** against a clean `FormalSystem/` tree rather than carried:

1. **`#print axioms` traverses a declaration's type as well as its value**, so no theorem whose
   statement mentions `translationFrame D` can pin choice-free: `translationFrame` itself reports
   `[propext, Classical.choice, Quot.sound]` (re-measured). Deliverable (2) is therefore met
   *absolutely* at the `ShiftSet` avatar and *relatively* at `translationFrame`.
2. **The `ShiftSet` route escapes the choice source entirely.** `ShiftSet.fibre_isRegular` takes
   *Limit* from the structure's own `sep` field and never calls `TaskFrame.limit_of_shift`.
   Re-measured: `selfShift` and `translationFlow` at `[propext]`; `translationFlow_taskRel`,
   `translationFlow_states_eq`, `translationFlow_orderFlow`, `translationFlow_stateOccurs`,
   `translationFlow_deterministic` and all three state-set corollaries at `[propext, Quot.sound]`
   — **no `Classical.choice` anywhere**, over an arbitrary `(D : TemporalOrder)`.
3. **The left/right mono asymmetry is real and binding.** At a `TemporalOrder`,
   `add_lt_add_right` is `[propext]` while `add_lt_add_left` and `sub_pos` are choice-borne. Every
   proof pinned below respects that discipline: witnesses are written additively as
   `-(τ.state 0) + v`, `sub_pos` never appears, and `abs_eq_zero` is replaced by `by_contra` plus
   `abs_pos.mpr`.
4. **Deliverable (3)'s audit is a no-op finding, not work.** All four consumers in
   `DeterminismUndefinable.lean` already discharge (H2) by explicit witness and consume the
   two-hypothesis route; no consumer of any `_of_isRegular` form exists anywhere in
   `FormalSystem/` or `Tests/`. Nothing can move to a choice-free route because nothing is on the
   Zorn route. Phase 4 performs and records the audit; it changes no consumer.

The settled prior decision is carried unchanged: **`TaskFrame.limit_of_shift` is left alone.** The
report's Recommendation 5 (a verified choice-free rewrite of it, which would make
`translationFrame` itself choice-free) is out of scope — it would shrink axiom sets that
`check-module-invariants.sh` C2/C14 pin by exact string equality across 202 declarations, whose
failure text calls any divergence "a HARD STOP, not a new baseline", and would falsify
`MainResults.lean`'s prose axiom contract. Deliverable (2) is met at the `ShiftSet` avatar
instead, with an explicitly relative pin at `translationFrame`.

**Plan-time re-derivations and divergences from the report, all load-bearing:**

- **The report's `rfl` consolidation claim does not reproduce, and is dropped.** The report states
  that `(selfShift realTemporalOrder).frame = F1` holds by `rfl` (and `.Carrier = ℝ` likewise),
  and offers restating `f1_orderFlow`/`f1_stateOccurs` as instances of the generic lemmas.
  Measured at plan time, three ways: term-mode `rfl` fails to elaborate (`?m = ?m` against the
  stated type), `by rfl` reports "not definitionally equal", and `with_unfolding_all rfl` also
  fails. The cause is the instance-path divergence between `oneShift`'s direct `HAdd ℝ` and
  `selfShift`'s `HAdd` routed through `TemporalOrder.addCommGroup`. **Consequence**: this plan
  asserts no Lean-level identity between `translationFlow realTemporalOrder` and `F1`, states the
  F¹ connection in prose only, and makes any edit to `DeterminismUndefinable.lean` a non-goal —
  which also discharges the dispatch's constraint that its axiom pin keep passing, by leaving it
  byte-identical.
- **Two of the report's proof snippets are wrong as printed, and are corrected here.** In the
  `translationFrame` (H1) proof, the `hits_future`/`hits_past` `change` lines omit the history
  argument `τ`; and `translationFlow_deterministic` needs the named argument
  `(f := fun w d => w + d)` for `TaskFrame.fib_subsingleton_of_functional` to elaborate (its
  conclusion is a fibre-subsingleton statement over an explicit `f`, not a bare `Deterministic`).
  Both corrections are compiled, and the `## Lean Challenge Statements` block pins the corrected
  forms.
- **No C15 unblock phase is needed** — the single most expensive surprise in the predecessor pin
  task's plan. All twelve paper anchors this plan's docstrings cite (`def:state-set`, `def:flow`,
  `lem:state-set`, `rmk:choice`, `cor:occurrence`, `thm:extension`, `cor:no-characterization`,
  `app:drift`, `lem:canonical-frames`, `def:canonical-frames`, `def:deterministic`,
  `lem:deterministic-singleton`) already have a row in
  `docs/reference/paper-definitions-of-record.md`. Verified at plan time by a field-1 grep per
  anchor. No row is added and no `sha256:` commitment is incurred.
- **C35 is clear.** `scripts/lean-citation-manifest.json` contains zero occurrences of
  `StateSetTruth`, and `scripts/lean-citation-seeds.txt` seeds no declaration in
  `StateSetTruth.lean` or the new module, so the docstring span shifts this task causes are
  invisible to C35 — which matters, because that file is in a concurrent sibling's declared
  `file_scope`.
- **C33 and the aggregator are in scope this time.** Unlike the predecessor task, this one adds a
  module, so `FormalSystem.lean` needs the sorted import line (C33 compares it byte-for-byte
  against `lake exe mk_all --lib FormalSystem`) and `FormalSystem/Metalogic/Independence.lean`
  needs the import plus a `## Contents` bullet. Sorted position in `FormalSystem.lean`: directly
  after `import FormalSystem.Metalogic.Independence.TranslationProductCoarse`.
- **`typst/generated/status.typ` is stale by construction.** It carries whole-tree `.lean` line
  and file counts, which a whole new module necessarily moves. It is also in a concurrent
  sibling's declared `file_scope` — see Risks.
- **C27 needs no allow-list entry**, because every `#print axioms` this plan records lives inside
  a fenced block in a module docstring, which C27 is comment-aware about. The precedent is
  `DeterminismUndefinable.lean`'s own `## Axiom pin (C4)` section. No live `#print` line is added
  to `FormalSystem/`.
- **C17 is reporting-only**, so a new declaration named nowhere else would not gate; naming every
  new declaration in the two docstrings and the `Independence/README.md` row is nonetheless done,
  as house style and so the census stays clean.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No `roadmap_path` was provided in the delegation context; no roadmap phases are included.

## Goals & Non-Goals

**Goals**:
- One new leaf module, `FormalSystem/Metalogic/Independence/TranslationStateSet.lean`, registered
  in `FormalSystem/Metalogic/Independence.lean` and `FormalSystem.lean`
- **Deliverable (1), absolute half**: `selfShift`, `translationFlow`, `translationFlow_taskRel`,
  `translationFlow_states_eq`, `translationFlow_orderFlow` (H1), `translationFlow_stateOccurs`
  (H2, by an explicit translation history, never `PartialHistory.extension`), and
  `translationFlow_deterministic`
- **Deliverable (1), `translationFrame` half**: `translationState`,
  `translationFrame_worldLinearOrder`, `translationFrame_orderFlow`,
  `translationFrame_stateOccurs` (H2, by the paper's own `σ_c` through `translationSigma`)
- **Deliverable (2)**: the three state-set corollaries at each layer —
  `translationFlow_plusTruthAt_iff_mem_satSet`, `translationFlow_determined`,
  `translationFlow_plusValidOn_iff_satSet_univ`, and the `translationFrame_*` counterparts — with
  the measured `#print axioms` profile of every new declaration recorded in the module docstring:
  absolute (`[propext]` / `[propext, Quot.sound]`, no `Classical.choice`) for the flow layer,
  relative (equal to `translationFrame`'s own) for the frame layer
- **Deliverable (3)**: a recorded audit of all four consumers in `DeterminismUndefinable.lean`,
  stating per consumer whether it can move to the choice-free route, and moving the ones that can
  (expected: none can, because none is on the Zorn route)
- **Deliverable (4)**: a `## Choice dependence` section in `StateSetTruth.lean`'s module
  docstring, with the three-route table (hypotheses, how (H2) is discharged, choice cost,
  consumers) so a reader can tell at a glance whether a given result is choice-dependent
- `FormalSystem/Metalogic/Independence/README.md`'s generated inventory current, with a written
  description cell and a `## Key Results` bullet for the new module

**Non-Goals**:
- **Any edit to `FormalSystem/Metalogic/Independence/DeterminismUndefinable.lean`.** Its axiom pin
  and its claim that the generic argument is choice-free both stay true under additive siblings;
  leaving it byte-identical is the cheapest way to satisfy the dispatch's constraint. The
  `f1_orderFlow`/`f1_stateOccurs` consolidation is dropped outright — see Research Integration for
  the measurement that killed it.
- **Any change to `TaskFrame.limit_of_shift`**, or to anything else that would shrink a pinned
  axiom set. This is the settled prior decision; it is not revisited.
- Any change to the two-hypothesis originals or the three `_of_isRegular` forms in
  `StateSetTruth.lean` — signatures, proofs, `variable` lines, or the `satSet` recursion. Only the
  module docstring is touched there, additively.
- Weakening `OrderFlow`, or any attempt at a choice-free `occurrence` in general. `rmk:choice`
  records that the general case genuinely needs the extension theorem.
- Any claim, in Lean or in prose, that `translationFlow realTemporalOrder` *is* `F1` as a term.
- Any change to the "thirteen results" count in `Independence.lean` or
  `Independence/README.md`. The new module is additive material, not a fourteenth underivability
  result — `TranslationProductCoarse.lean` is the precedent for a `## Contents` bullet without a
  numbered-result entry.
- Any addition to `FormalSystem/MainResults.lean`, `scripts/check-module-invariants.sh`'s C2/C14
  baselines, `docs/reference/paper-definitions-of-record.md`, `docs/theorem-index.md`, or
  `scripts/lean-citation-seeds.txt`.
- Any `Tests/BimodalTest/` axiom pin for the new declarations. A reasonable later addition.
- Any edit to `possible_worlds.tex` or `appendix_cut_material.tex` — read-only inputs from another
  repository. Clearing the `% PORT:` comment at `lem:state-set` is paper-side work, and the
  citation-manifest and paper-facing records are a concurrent sibling's declared territory.
- Any live `#print`/`#eval`/`#check` line under `FormalSystem/`, which would need a C27 allow-list
  row with an exact per-file count.
- Any `Constraints consumed:` marker, and any `set_option`.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `typst/generated/status.typ` is in concurrent sibling 801's declared `file_scope`, and this task makes it stale by construction (a whole new `.lean` module moves the whole-tree line and file counts) | H | H | Phase 5 regenerates it with `bash scripts/typst-sync-check.sh --fix` only after re-reading it and checking `git status --short`. On a foreign uncommitted modification, STOP and report rather than regenerate over it. Stage it by explicit path together with this task's own hunks |
| `README.md` and `FormalSystem/README.md` are also in sibling 801's declared `file_scope`, and `--emit-inventory` rewrites whole registered blocks, so a silent absorb of a sibling's in-flight hunk is possible | H | M | Phase 5 reaches them only through the generator, never by hand; re-read plus `git status --short` on each first, STOP on a foreign modification, stage by explicit file list, and read `git diff --staged` to confirm every hunk is a count this task's own additions moved |
| Sibling 801 also declares `scripts/lean-citation-manifest.json` (C35) and `docs/reference/*` (C15) — a red C35 or C15 could look like this task's regression | M | M | Verified at plan time that the manifest and seeds name nothing in `StateSetTruth.lean` or the new module, and that all twelve cited anchors already have record rows. On a C15/C35 failure, check `git status --short` and `git log` for 801's in-flight edit before treating it as a 799 regression; report rather than repair |
| C33 goes red because the new module is missing from `FormalSystem.lean`, or inserted out of sorted order | M | M | Phase 1 adds the import line in sorted position (directly after `…Independence.TranslationProductCoarse`) as part of the same phase that creates the file, and Phase 1's own verification runs `check-module-invariants.sh --no-build` and names C33 |
| The new global `instance translationFrame_worldLinearOrder` interferes with instance search elsewhere | M | L | Keyed on `(translationFrame D).toTaskFrame.WorldState`, a head symbol no existing instance mentions, and definitionally the carrier's own `LinearOrder`, so no diamond arises. Phase 3 is tiered `interface` and builds the `Independence` aggregator, not just the module. If a diamond does appear, make it `local`/`scoped` and pass it explicitly — the `OrderFlow` statements accept an explicit instance argument |
| A docstring line names one of the seven capitalized constraint tokens (`Compositionality`, `Compositional`, `Seriality`, `Serial`, `Limit`, `Saturation`, `Saturated`) beside a negation or consumption word, and C34b fires | M | L | C34b is bracketed-binder-only and no new declaration has a bracketed binder, so it cannot fire here; belt-and-braces, write the *Limit*-via-`sep` explanation with the token on its own line, away from any negation or consumption word, and write no `Constraints consumed:` marker |
| A new docstring trips C14's stale-axiom-count tripwire (`\b(14\|21\|42\|44\|45)\s+(\w+\s+)?(axiom\|constructor\|schema)` on a line also containing "axiom") | L | L | Write no numeral from that set adjacent to `axiom`/`constructor`/`schema` in any new docstring; spell small counts as words. Phase 1-4 verification runs `check-module-invariants.sh --no-build`, which names C14 |
| A `#print axioms` fence in a docstring is read by C27 as a live debug directive | L | L | C27 is comment-aware and `DeterminismUndefinable.lean`'s `## Axiom pin` fence is the standing precedent; add no live directive outside a comment, and confirm by C27 PASSing in each phase's `--no-build` run |
| A concurrent unguarded `lake` invocation collides with this task's build, losing it | M | M | Route every `lake` call through `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- …`, detached via `Bash(run_in_background: true)`, exit read un-piped or from the guard's `result` subcommand. Never bare `lake` |
| A build failure lands in a file outside this task's scope and is read as a 799 regression | M | M | Three siblings are dispatched on this same working tree, two with no declared `file_scope` at all. Check `git status --short` and `git log` before assuming the code is wrong, and report rather than repair |
| `lean-challenge-snapshot.sh --check` reports drift against the pinned signatures | L | M | Advisory only per `plan-compliance.md`: never on its own grounds to fail a phase. A drift finding on the *logical content* of a pinned statement is escalated as `[BLOCKED]`, never quietly re-pinned |
| The new module's line count makes `Independence/README.md`'s inventory and three ancestor blocks stale, failing INV late | M | H | Phase 5 regenerates with `--emit-inventory` and confirms with `--emit-inventory --check`; never hand-edit a count column, and never call the deprecated `scripts/readme-inventory.sh` shim (it exits 2) |
| The `lean_run_code` probes that pin these signatures were run against a built library whose state could change under a sibling's `.lean` edit | L | L | `FormalSystem/` was clean at plan time (`git status --short` showed only `specs/**` modified), and every signature below was compiled in that state. Each phase re-confirms by scoped build plus `lean_verify` rather than trusting the probe |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |

Phases within the same wave can execute in parallel.

### Phase 1: The new leaf module and the choice-free translation flow [COMPLETED]

**Goal**: A registered, building leaf module carrying the generic `ShiftSet` avatar of the
translation flow with (H1) and (H2) discharged by explicit translation, and no `Classical.choice`
anywhere in it.

**Tasks**:
- [ ] Create `FormalSystem/Metalogic/Independence/TranslationStateSet.lean` with the house
      copyright header, the three imports
      (`FormalSystem.Metalogic.Independence.StateSetTruth`, `FormalSystem.Semantics.ShiftSet`,
      `FormalSystem.Semantics.Correspondence.DurationFrames`), `namespace
      FormalSystem.Metalogic.Independence`, and `open FormalSystem.Syntax`,
      `open FormalSystem.Semantics`, `open FormalSystem.PlusLanguage`
- [ ] Write a provisional module docstring with `# `, a one-paragraph statement of what the
      module does, `## Main Definitions`, `## Main Results`, `## References` and `## Tags`
      sections. The `#print axioms` fences land in Phase 2; the docstring's
      `## Choice dependence` prose lands in Phase 4
- [ ] Add `selfShift`, `translationFlow`, `translationFlow_taskRel`,
      `translationFlow_states_eq`, `translationFlow_orderFlow`, `translationFlow_stateOccurs`
      and `translationFlow_deterministic` exactly as `## Lean Challenge Statements` pins them.
      `selfShift` and `translationFlow` carry `@[reducible]` and are **not** `noncomputable` —
      the reducibility is what lets `[LinearOrder F.WorldState]` synthesize with no help, and is
      load-bearing for every proof below
- [ ] Write every proof additively: witnesses as `-(τ.state 0) + v`, `add_lt_add_right` rather
      than `add_lt_add_left`, `by_contra` plus `abs_pos.mpr` rather than `abs_eq_zero`, and
      `sub_pos` nowhere. Each of those three substitutions is the difference between a
      choice-free and a choice-borne proof at a `TemporalOrder`
- [ ] Give every declaration a docstring (C16's `docBlame`). Cite `def:flow`, `def:state-set`,
      `lem:state-set`, `rmk:choice`, `lem:canonical-frames` and `def:deterministic` by anchor
      name where relevant; cite no `file.lean:NNN` location and no task number anywhere
- [ ] Keep every line at or under 100 characters (`linter.style.longLine`), and add no
      `set_option`
- [ ] Add `import FormalSystem.Metalogic.Independence.TranslationStateSet` to
      `FormalSystem/Metalogic/Independence.lean`'s import list (after
      `…Independence.DeterminismUndefinable`, since this module imports `StateSetTruth`), and add
      a `## Contents` bullet for it in that file's module docstring. Change **no** numbered
      result and **not** the "thirteen results" count
- [ ] Re-read `FormalSystem.lean` immediately before editing, then add
      `import FormalSystem.Metalogic.Independence.TranslationStateSet` in sorted position,
      directly after `import FormalSystem.Metalogic.Independence.TranslationProductCoarse`

**Timing**: 1.0 hours

**Depends on**: none

**Verification Tier**: local

**Tier Justification**: `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Independence.TranslationStateSet`
is the specific covering check — a brand-new leaf module plus two import-list registrations
changes no existing declaration's signature, so nothing downstream can observe anything but the
new module's existence.

**Scope Hypothesis**: the seven declarations' signatures and proof terms are pinned in
`## Lean Challenge Statements` from this plan's own compiled `lean_run_code` probes against a
clean `FormalSystem/` tree, not carried from the research report (whose `translationFlow_deterministic`
snippet does not elaborate). The claim that **no new import beyond the three named is needed** is
likewise from those probes, which imported exactly those three modules. Confirm by the scoped
build below; if an import is missing, add it and say so rather than restructuring the module.

**Files to modify**:
- `FormalSystem/Metalogic/Independence/TranslationStateSet.lean` - new file: header, three
  imports, provisional module docstring, and the seven flow-layer declarations
- `FormalSystem/Metalogic/Independence.lean` - one import line and one `## Contents` bullet; no
  numbered-result change
- `FormalSystem.lean` - one import line in sorted position

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Independence.TranslationStateSet`
  exits 0, detached via `Bash(run_in_background: true)`, exit read un-piped or from the guard's
  `result` subcommand
- `bash scripts/check-module-invariants.sh --no-build` runs with C33, C8, C4, C5, C9, C14, C20,
  C26, C27, C29, C30, C32 and C34 all PASSing (INV is expected to FAIL until Phase 5 regenerates
  the inventory blocks, so whole-script exit 0 is not yet attainable — say so rather than
  chasing it)
- `lean_verify FormalSystem.Metalogic.Independence.selfShift` and
  `…translationFlow` report `[propext]`; `…translationFlow_taskRel`,
  `…translationFlow_states_eq`, `…translationFlow_orderFlow`, `…translationFlow_stateOccurs` and
  `…translationFlow_deterministic` report `[propext, Quot.sound]`. **No `Classical.choice` on any
  of the seven**, and no `sorry`
- `grep -nE '\b(task|tasks) [0-9]+' FormalSystem/Metalogic/Independence/TranslationStateSet.lean`
  returns nothing
- `git diff -- FormalSystem/Metalogic/Independence.lean` shows exactly one added import line and
  one added `## Contents` bullet, with no numbered result touched

---

### Phase 2: The three choice-free corollaries and the absolute axiom pin [COMPLETED]

**Goal**: `lem:state-set`'s three sentences hold at the translation flow over an arbitrary
duration group with no appeal to choice, and the module docstring records the measured profiles
that prove it.

**Tasks**:
- [ ] Re-read `FormalSystem/Metalogic/Independence/TranslationStateSet.lean` immediately before
      editing
- [ ] Add `translationFlow_plusTruthAt_iff_mem_satSet`, `translationFlow_determined` and
      `translationFlow_plusValidOn_iff_satSet_univ`, each a term-mode application of the
      corresponding two-hypothesis original to `(translationFlow_orderFlow D)` and
      `(translationFlow_stateOccurs D)`, exactly as `## Lean Challenge Statements` pins them
- [ ] Each docstring names which sentence of `lem:state-set` it is, and records that (H2) is
      discharged by an explicit translation rather than by `cor:occurrence` — so neither
      `thm:extension` nor Zorn is reached
- [ ] Add an `## Axiom pin` section to the module docstring, on
      `DeterminismUndefinable.lean`'s `## Axiom pin (C4)` precedent: a fenced block listing the
      `#print axioms` lines for all ten flow-layer declarations, commented out, with the measured
      profiles recorded in the prose beneath — `[propext]` for `selfShift` and `translationFlow`,
      `[propext, Quot.sound]` for the other eight, and **no `Classical.choice` on any of them**.
      State explicitly that this is an *absolute* pin, and that it holds over an arbitrary
      `(D : TemporalOrder)`
- [ ] Record in the same section why the route escapes: `ShiftSet.fibre_isRegular` takes the
      *Limit* obligation from the structure's own `sep` field. Put that capitalized token on its
      own line, with no negation or consumption word beside it
- [ ] Add no live `#print` line outside the fenced comment, and no C27 allow-list row
- [ ] Tag none of the three `@[simp]`; add no import; cite no `file.lean:NNN` and no task number

**Timing**: 0.75 hours

**Depends on**: 1

**Verification Tier**: local

**Tier Justification**: `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Independence.TranslationStateSet`
is the specific covering check — three additive, untagged theorems plus a docstring edit inside
one leaf module change no existing signature and no `simp` set.

**Scope Hypothesis**: the three delegation proof terms, the claim that each closes by term-mode
application alone, and the ten recorded axiom profiles are pinned from this plan's own compiled
`lean_run_code` probes. Confirm by re-running `lean_verify` on each of the ten against the
implemented file — never copy a profile from this plan into the docstring without that
re-measurement, since the docstring is a dated record of a measurement.

**Files to modify**:
- `FormalSystem/Metalogic/Independence/TranslationStateSet.lean` - three theorems with
  docstrings, plus the `## Axiom pin` docstring section and the `## Main Results` entries for
  them

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Independence.TranslationStateSet`
  exits 0, detached and guarded as in Phase 1
- `lean_verify` on all ten flow-layer declarations reports the profiles written into the
  docstring, with **zero** `Classical.choice` and zero `sorry`
- `bash scripts/check-module-invariants.sh --no-build` runs with C27, C14, C16, C9 and C20
  PASSing (INV still expected red until Phase 5)
- Diff read-through confirms the `#print axioms` lines lie inside the `/-! … -/` fenced block and
  that no live directive was added

---

### Phase 3: (H1), (H2) and the three corollaries at `translationFrame D` [COMPLETED]

**Goal**: The same results are available at the frame constant the `*Sharpness` countermodels
actually build on, with the witness exhibited as the paper's own `σ_c`, and the pin recorded as
*relative* in exactly the words the measurement supports.

**Tasks**:
- [ ] Re-read `FormalSystem/Metalogic/Independence/TranslationStateSet.lean` immediately before
      editing
- [ ] Open a trailing `section TranslationFrame … end TranslationFrame` and add
      `translationState` (the identity view), the `translationFrame_worldLinearOrder` instance,
      `translationFrame_orderFlow`, `translationFrame_stateOccurs`,
      `translationFrame_plusTruthAt_iff_mem_satSet`, `translationFrame_determined` and
      `translationFrame_plusValidOn_iff_satSet_univ`, exactly as
      `## Lean Challenge Statements` pins them
- [ ] Write the (H1) proof through the `translationStates` view, never a type ascription: a
      `show (τ.state s : ↑D) < (τ.state t : ↑D)` for `strictMono`, and a `change` to a
      `translationStates τ …` application — **with the history argument `τ` present** — before
      each `rw` in `hits_future`/`hits_past`. The research report's snippet omits that `τ` and
      does not compile; the pinned form below is the compiled one
- [ ] Write (H2) as `translationSigma D (-x + translationState w)`, i.e. the paper's `σ_c` at
      `c = -x + w`, and close with `rw [translationSigma_states]` then `abel`. Reach
      `PartialHistory.extension` nowhere
- [ ] Extend the module docstring's `## Axiom pin` section with the **relative** pin: the five
      new theorem-shaped declarations report exactly what `translationFrame` itself reports,
      `[propext, Classical.choice, Quot.sound]`, so the (H2) discharge contributes nothing — no
      `cor:occurrence`, no `thm:extension`, no Zorn — while the frame constant's own
      `Classical.choice`, arriving through `TaskFrame.limit_of_shift`, remains. Name
      `TaskFrame.limit_of_shift` explicitly as the residual source, and state that
      `#print axioms` traverses a declaration's type as well as its value, so no statement
      mentioning `translationFrame D` can pin better
- [ ] Record the reducibility contrast in prose, since it is what forces the two routes apart:
      `ShiftSet.fibre`/`ShiftSet.frame` are `@[reducible]` so instance search sees through them,
      while `translationFrame` is a plain `def`, which is why this half needs the
      `inferInstanceAs` instance and the `translationState` view at all
- [ ] Make no claim that `translationFlow realTemporalOrder` equals `F1`
- [ ] Give every declaration a docstring; cite `def:canonical-frames` and `lem:canonical-frames`
      by anchor name for `σ_c`; cite no `file.lean:NNN` and no task number

**Timing**: 1.25 hours

**Depends on**: 2

**Verification Tier**: interface

**Tier Justification**: this phase adds a **global instance**, so the covering check is the
module build plus its one enumerated direct dependent —
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Independence`
— which is what would surface an instance-search diamond that a single-module build cannot see.

**Scope Hypothesis**: the seven signatures and proof terms, and the five recorded
`[propext, Classical.choice, Quot.sound]` profiles, are pinned from this plan's own compiled
`lean_run_code` probes (the corrected `change` lines included). The claim that the profiles are
*identical to* `translationFrame`'s own — which is what makes the pin relative rather than a
regression — is likewise measured. Confirm by `lean_verify` on the five plus
`FormalSystem.Semantics.translationFrame` and comparing the strings, not by assuming them.

**Files to modify**:
- `FormalSystem/Metalogic/Independence/TranslationStateSet.lean` - a trailing
  `section TranslationFrame` with one definition, one instance and five theorems, their
  docstrings, the relative-pin extension to `## Axiom pin`, and the matching
  `## Main Definitions` / `## Main Results` entries

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Independence.TranslationStateSet`
  exits 0, detached and guarded
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Independence`
  exits 0 — the one direct dependent elaborates with the new global instance in scope
- `lean_verify` on `…translationFrame_orderFlow`, `…translationFrame_stateOccurs`,
  `…translationFrame_plusTruthAt_iff_mem_satSet`, `…translationFrame_determined` and
  `…translationFrame_plusValidOn_iff_satSet_univ` reports
  `[propext, Classical.choice, Quot.sound]` for each, with no `sorry`; and
  `lean_verify FormalSystem.Semantics.translationFrame` reports the same string, confirming the
  pin is relative and the discharge adds nothing
- `lean_verify` on the ten flow-layer declarations still reports their Phase 2 profiles — the
  new global instance has not perturbed the choice-free half
- `grep -n 'PartialHistory.extension\|StateOccurs.of_isRegular' FormalSystem/Metalogic/Independence/TranslationStateSet.lean`
  returns nothing
- `bash scripts/check-module-invariants.sh --no-build` runs with C16, C26, C27, C34a, C34b, C9
  and C20 PASSing (INV still expected red until Phase 5)

---

### Phase 4: The consumer audit and the three-route record [NOT STARTED]

**Goal**: Deliverables (3) and (4): every consumer in `DeterminismUndefinable.lean` carries a
recorded verdict on whether it can move to the choice-free route, and
`StateSetTruth.lean`'s module docstring lets a reader tell at a glance which route any given
result takes.

**Tasks**:
- [ ] Audit, read-only, every consumer of the state-set results in
      `FormalSystem/Metalogic/Independence/DeterminismUndefinable.lean`. Enumerate them
      mechanically rather than from this plan — `grep -n` for `plusTruthAt_iff_mem_satSet`,
      `plusValidOn_iff_satSet_univ`, `determined_of_orderFlow` and the three `_of_isRegular`
      names across `FormalSystem/` and `Tests/` — and for each, state whether it can move to the
      choice-free route and why
- [ ] Move every consumer that can move. The expected finding is that none can, because none is
      on the Zorn route: each already discharges (H2) at `F°` or `F¹` by an explicit witness, and
      its residual `Classical.choice` is carrier-borne (`ℝ`). If the audit instead finds a
      consumer that *is* on the Zorn route, move it and record the move; if moving it would
      require editing `DeterminismUndefinable.lean`, mark the phase `[BLOCKED]` and escalate
      rather than editing a file this plan declares a non-goal
- [ ] Re-read `FormalSystem/Metalogic/Independence/StateSetTruth.lean` immediately before editing
- [ ] Add a `## Choice dependence` section to its module docstring carrying the three-route
      table: route | hypotheses | how (H2) is discharged | choice cost | consumers. Rows: the
      two-hypothesis originals (assumed (H2); `[propext]` / `[propext, Quot.sound]`; consumed at
      `F°` and `F¹` by explicit witness); the `_of_isRegular` forms (`StateOccurs.of_isRegular` →
      `cor:occurrence` → `thm:extension` → Zorn; `Classical.choice`, argument-borne; no consumer
      yet, they state `lem:state-set` at `def:flow`'s hypotheses); and the new
      `translationFlow`/`translationFrame` instances (explicit translation; none at
      `translationFlow`, frame-constant-borne at `translationFrame`)
- [ ] Record alongside the table that `plusTruthAt_iff_mem_satSet` reports `[propext]` alone and
      `determined_of_orderFlow` `[propext, Quot.sound]`, so the generic argument is choice-free
      and only instantiation can add choice — and name
      `Independence/TranslationStateSet.lean` as where the choice-free instantiation lives
- [ ] Add the consumer-audit verdict to the same section, in one or two sentences: which
      consumers take which route, and that none is on the Zorn route
- [ ] Phrase everything as the **current design**, never relative to an unstated past: no "is
      now", "no longer", "previously", "formerly" (`.claude/rules/no-record-versioning-in-deliverables.md`)
- [ ] Change nothing in `StateSetTruth.lean` outside the module docstring — not `satSet`, not the
      `Clauses` section, not the `variable` lines, not any of the six theorems, not the
      `section Regular`
- [ ] Write none of the seven capitalized constraint tokens beside a negation or consumption word
      on any new line; cite no `file.lean:NNN` and no task number

**Timing**: 0.75 hours

**Depends on**: 3

**Verification Tier**: local

**Tier Justification**: `bash scripts/check-module-invariants.sh --no-build` is the specific
covering check for this edit's whole risk surface (C15 anchor resolution, C9's task-number
assertion, C14's stale-count tripwire, C20's citation assertions, C18's duplicated-prose
census), run together with the single-module scoped build that confirms the `/-! -/` block still
parses.

**Scope Hypothesis**: the claim that there are exactly **four** consumers in
`DeterminismUndefinable.lean` and that **none** is on the Zorn route is carried from the research
report's grep census over `FormalSystem/` and `Tests/`. Confirm by re-running that census as the
phase's first task — the six-name `grep -n` sweep named above — and record the verdict from what
it returns, not from this plan's expectation.

**Files to modify**:
- `FormalSystem/Metalogic/Independence/StateSetTruth.lean` - module docstring only: the
  `## Choice dependence` section with the three-route table, the generic-argument profiles, and
  the consumer-audit verdict

**Verification**:
- `bash scripts/check-module-invariants.sh --no-build` runs with C15, C9, C14, C20, C32 and C34
  PASSing (INV still expected red until Phase 5)
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Independence.StateSetTruth`
  exits 0
- `git diff -- FormalSystem/Metalogic/Independence/StateSetTruth.lean` shows every hunk inside
  the leading `/-! … -/` module docstring, and zero hunks in `satSet`, the `Clauses` section, any
  `variable` line, any of the six theorems, or the `section Regular`
- `lean_verify FormalSystem.Metalogic.Independence.plusTruthAt_iff_mem_satSet` still reports
  `[propext]` and `…determined_of_orderFlow` still `[propext, Quot.sound]`
- `FormalSystem/Metalogic/Independence/DeterminismUndefinable.lean` is byte-identical to HEAD
  (`git diff --stat` on it is empty)
- `grep -niE '\b(is now|no longer|previously|formerly|used to)\b' FormalSystem/Metalogic/Independence/StateSetTruth.lean`
  returns nothing added by this task
- The audit's enumeration and per-consumer verdict are recorded in the docstring, not only in the
  dispatch's prose

---

### Phase 5: Inventory refresh, status sync, and the full gate sweep [NOT STARTED]

**Goal**: Every generated surface the new module makes stale is current, every axiom profile is
confirmed against the implemented files rather than a probe, and the whole repository gate set is
green.

**Tasks**:
- [ ] `bash scripts/check-module-invariants.sh --emit-inventory` to regenerate **every**
      registered `BEGIN GENERATED` block. Four are implicated: `FormalSystem/Metalogic/Independence/README.md`
      (a new per-file row), `FormalSystem/Metalogic/README.md` (the `Independence/` subdir
      files/lines totals row), `README.md` (the `dir=FormalSystem rows=totals` row), and
      `FormalSystem/README.md` (`rows=loose` over the `FormalSystem/` top level — may not change;
      let the generator decide). Hand-edit no count column in any of the four, and never call
      `scripts/readme-inventory.sh` (a deprecated shim that exits 2)
- [ ] **Before touching `README.md`, `FormalSystem/README.md` or `typst/generated/status.typ`**,
      re-read each and check `git status --short`: all three are in concurrent sibling 801's
      declared `file_scope`. On a foreign uncommitted modification in any of them, STOP and
      report rather than regenerate over it — the generator rewrites whole blocks and would
      silently absorb a sibling's in-flight hunk
- [ ] Hand-write the new module's description cell in `FormalSystem/Metalogic/Independence/README.md`
      (the generator leaves a TODO placeholder for a file it has not seen before), naming every
      new declaration, and add a `## Key Results` bullet for the two routes
- [ ] `bash scripts/check-module-invariants.sh --emit-inventory --check` to confirm every block
      is current
- [ ] `bash scripts/typst-sync-check.sh --counts-only`; the whole-tree line and file counts in
      `typst/generated/status.typ` necessarily moved, so regenerate with
      `bash scripts/typst-sync-check.sh --fix` rather than hand-patching, and stage the result by
      explicit path
- [ ] Re-confirm, with `lean_verify` against the implemented files, every axiom profile this
      plan's docstrings record: the ten flow-layer declarations choice-free, the five
      `translationFrame` theorems at `translationFrame`'s own profile,
      `plusTruthAt_iff_mem_satSet` at `[propext]`, `determined_of_orderFlow` at
      `[propext, Quot.sound]`
- [ ] Stage by explicit file list only — never a directory or glob `git add` — and review
      `git diff --staged` to confirm every hunk in a shared generated file is a count this task's
      own additions moved
- [ ] Run the full gate set (below). If a failure lands in a file outside this task's declared
      scope, check `git status --short` and `git log` for a sibling's in-flight edit before
      treating it as a 799 regression, and report rather than repair
- [ ] Record the issue-log entries for this phase, and write the implementation summary

**Timing**: 1.0 hours

**Depends on**: 4

**Verification Tier**: full

**Scope Hypothesis**: the claim that **four** registered `BEGIN GENERATED` inventory blocks are
implicated, and that `typst/generated/status.typ` is stale, are hypotheses derived at plan time
from the generator's block registrations (`grep` for `BEGIN GENERATED` across the tree) and from
`typst/generated/status.typ`'s own whole-tree line/file-count fields. The predecessor pin task's
plan carried the opposite expectation for `status.typ` (byte-identical) and was wrong, which is
why it is asserted stale here rather than hoped clean. Confirm by letting
`--emit-inventory` and `typst-sync-check.sh --counts-only` decide which files actually move, and
record what they report rather than this list.

**Files to modify**:
- `FormalSystem/Metalogic/Independence/README.md` - regenerated per-file inventory plus the
  hand-written description cell and the `## Key Results` bullet
- `FormalSystem/Metalogic/README.md` - regenerated `Independence/` subdir files/lines totals row
- `README.md` - regenerated `dir=FormalSystem rows=totals` row
- `FormalSystem/README.md` - regenerated only if the generator's `rows=loose` block actually
  changes; leave untouched otherwise
- `typst/generated/status.typ` - regenerated whole-tree counts only, via
  `typst-sync-check.sh --fix`
- `specs/799_choice_free_state_occurrence_applications/summaries/01_choice-free-state-occurrence-summary.md` -
  implementation summary

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build` exits 0 for the whole
  project, detached via `Bash(run_in_background: true)`, exit read un-piped or from the guard's
  `result` subcommand
- `bash scripts/check-module-invariants.sh --no-build` exits 0 with zero `FAIL` lines
- `bash scripts/check-module-invariants.sh --emit-inventory --check` exits 0
- `bash scripts/check-paper-definitions.sh` — no **new** drifted anchor and no new `sha256:` line
  (this task changes none); report the inherited drift wave rather than repairing it
- `bash scripts/check-phantom-citations.sh` exits 0
- `bash scripts/readme-lint.sh` exits 0
- `bash scripts/typst-sync-check.sh` exits 0
- `python3 scripts/export-lean-citations.py --check` exits 0
- `bash .claude/scripts/verify-deploy.sh` exits 0 — the complete repository gate aggregator, run
  un-narrowed: no `--only-gate` subset and no `--skip-slow`
- Zero `sorry` and zero new `axiom` anywhere in the diff
- `FormalSystem/Metalogic/Independence/DeterminismUndefinable.lean` is byte-identical to HEAD,
  and its three pinned declarations still report `[propext, Classical.choice, Quot.sound]`
- `FormalSystem/Semantics/TaskFrame.lean` is byte-identical to HEAD —
  `TaskFrame.limit_of_shift` was not touched, so no pinned axiom set shrank

---

## Lean Challenge Statements

Every signature and proof term below was **compiled at plan time** by `lean_run_code` against the
built library with `FormalSystem/` clean, under the three imports Phase 1 names. Two of them
differ from the research report's printed snippets, which do not compile: the
`hits_future`/`hits_past` `change` lines carry the history argument `τ`, and
`translationFlow_deterministic` carries the named argument `(f := fun w d => w + d)`. The
measured `#print axioms` profile follows each group.

```lean
import FormalSystem.Metalogic.Independence.StateSetTruth
import FormalSystem.Semantics.ShiftSet
import FormalSystem.Semantics.Correspondence.DurationFrames

namespace FormalSystem.Metalogic.Independence

open FormalSystem.Syntax
open FormalSystem.Semantics
open FormalSystem.PlusLanguage

-- Phase 1 — the choice-free flow layer.
-- `selfShift`, `translationFlow`: [propext]
-- the five below: [propext, Quot.sound]

@[reducible] def selfShift (D : TemporalOrder) : ShiftSet D where
  Carrier := ↑D
  carrier_nonempty := ⟨0⟩
  sh := fun w d => w + d
  sh_zero := by intro w; exact add_zero w
  sh_add := by intro w a b; exact add_assoc w a b
  sep := by
    intro w u h
    by_contra hne
    have hpos : (0 : ↑D) < |u - w| := abs_pos.mpr (sub_ne_zero.mpr hne)
    obtain ⟨y, hy, hu⟩ := h (|u - w|) hpos
    have hy' : y = u - w := by rw [hu]; abel
    rw [hy'] at hy
    exact lt_irrefl _ hy
  A := fun _ _ => False

@[reducible] def translationFlow (D : TemporalOrder) : TaskFrame := (selfShift D).frame

theorem translationFlow_taskRel (D : TemporalOrder) (w x u : ↑D) :
    (translationFlow D).TaskRel w x u ↔ u = w + x := (selfShift D).fibre_taskRel w x u

theorem translationFlow_states_eq (D : TemporalOrder)
    (τ : WorldHistory (translationFlow D)) (r : ↑D) : τ.state r = τ.state 0 + r := by
  have h := (translationFlow_taskRel D _ _ _).mp (τ.respects_task 0 r)
  rw [sub_zero] at h
  exact h

theorem translationFlow_orderFlow (D : TemporalOrder) : OrderFlow (translationFlow D) where
  strictMono := by
    intro τ s t hst
    rw [translationFlow_states_eq D τ s, translationFlow_states_eq D τ t]
    exact add_lt_add_right hst _
  hits_future := by
    intro τ x v hv
    refine ⟨-(τ.state 0) + v, ?_, ?_⟩
    · rw [translationFlow_states_eq D τ x] at hv
      have h2 := add_lt_add_right hv (-(τ.state 0))
      rw [show -(τ.state 0) + (τ.state 0 + x) = x by abel] at h2
      exact h2
    · rw [translationFlow_states_eq D τ (-(τ.state 0) + v)]; abel
  hits_past := by
    intro τ x v hv
    refine ⟨-(τ.state 0) + v, ?_, ?_⟩
    · rw [translationFlow_states_eq D τ x] at hv
      have h2 := add_lt_add_right hv (-(τ.state 0))
      rw [show -(τ.state 0) + (τ.state 0 + x) = x by abel] at h2
      exact h2
    · rw [translationFlow_states_eq D τ (-(τ.state 0) + v)]; abel

theorem translationFlow_stateOccurs (D : TemporalOrder) : StateOccurs (translationFlow D) := by
  intro w x
  refine ⟨(selfShift D).hist (-x + w), ?_⟩
  change -x + w + x = w
  abel

theorem translationFlow_deterministic (D : TemporalOrder) :
    (translationFlow D).Deterministic :=
  TaskFrame.fib_subsingleton_of_functional (f := fun w d => w + d) (translationFlow_taskRel D)

-- Phase 2 — the three corollaries at the flow. All three: [propext, Quot.sound]

theorem translationFlow_plusTruthAt_iff_mem_satSet (D : TemporalOrder)
    (M : TaskModel (translationFlow D)) (φ : PlusFormula) :
    ∀ (τ : WorldHistory (translationFlow D)) (t : ↑D),
      PlusTruthAt M τ t φ ↔ τ.state t ∈ satSet M.valuation φ :=
  plusTruthAt_iff_mem_satSet (translationFlow_orderFlow D) (translationFlow_stateOccurs D) M φ

theorem translationFlow_determined (D : TemporalOrder) (φ : PlusFormula) :
    (translationFlow D).PlusValidOn (.imp φ (.stab φ)) :=
  determined_of_orderFlow (translationFlow_orderFlow D) (translationFlow_stateOccurs D) φ

theorem translationFlow_plusValidOn_iff_satSet_univ (D : TemporalOrder) (φ : PlusFormula) :
    (translationFlow D).PlusValidOn φ ↔ ∀ V : ↑D → Atom → Prop, satSet V φ = Set.univ :=
  plusValidOn_iff_satSet_univ (translationFlow_orderFlow D) (translationFlow_stateOccurs D) φ

-- Phase 3 — the `translationFrame` layer. Every theorem below:
-- [propext, Classical.choice, Quot.sound], identical to `translationFrame`'s own profile.

def translationState {D : TemporalOrder}
    (w : (translationFrame D).toTaskFrame.WorldState) : ↑D := w

instance translationFrame_worldLinearOrder (D : TemporalOrder) :
    LinearOrder ((translationFrame D).toTaskFrame.WorldState) := inferInstanceAs (LinearOrder ↑D)

theorem translationFrame_orderFlow (D : TemporalOrder) :
    OrderFlow (translationFrame D).toTaskFrame where
  strictMono := by
    intro τ s t hst
    show (τ.state s : ↑D) < (τ.state t : ↑D)
    rw [show (τ.state s : ↑D) = translationStates τ 0 + s from translationStates_eq τ s,
        show (τ.state t : ↑D) = translationStates τ 0 + t from translationStates_eq τ t]
    exact add_lt_add_right hst _
  hits_future := by
    intro τ x v hv
    refine ⟨-(translationStates τ 0) + translationState v, ?_, ?_⟩
    · have h : translationStates τ 0 + x < translationState v := by
        rw [← translationStates_eq τ x]; exact hv
      have h2 := add_lt_add_right h (-(translationStates τ 0))
      rw [show -(translationStates τ 0) + (translationStates τ 0 + x) = x by abel] at h2
      exact h2
    · change translationStates τ (-(translationStates τ 0) + translationState v)
        = translationState v
      rw [translationStates_eq τ (-(translationStates τ 0) + translationState v)]
      abel
  hits_past := by
    intro τ x v hv
    refine ⟨-(translationStates τ 0) + translationState v, ?_, ?_⟩
    · have h : translationState v < translationStates τ 0 + x := by
        rw [← translationStates_eq τ x]; exact hv
      have h2 := add_lt_add_right h (-(translationStates τ 0))
      rw [show -(translationStates τ 0) + (translationStates τ 0 + x) = x by abel] at h2
      exact h2
    · change translationStates τ (-(translationStates τ 0) + translationState v)
        = translationState v
      rw [translationStates_eq τ (-(translationStates τ 0) + translationState v)]
      abel

theorem translationFrame_stateOccurs (D : TemporalOrder) :
    StateOccurs (translationFrame D).toTaskFrame := by
  intro w x
  refine ⟨translationSigma D (-x + translationState w), ?_⟩
  change translationStates (translationSigma D (-x + translationState w)) x = translationState w
  rw [translationSigma_states]
  abel

theorem translationFrame_plusTruthAt_iff_mem_satSet (D : TemporalOrder)
    (M : TaskModel (translationFrame D).toTaskFrame) (φ : PlusFormula) :
    ∀ (τ : WorldHistory (translationFrame D).toTaskFrame) (t : ↑D),
      PlusTruthAt M τ t φ ↔ τ.state t ∈ satSet M.valuation φ :=
  plusTruthAt_iff_mem_satSet (translationFrame_orderFlow D) (translationFrame_stateOccurs D) M φ

theorem translationFrame_determined (D : TemporalOrder) (φ : PlusFormula) :
    (translationFrame D).toTaskFrame.PlusValidOn (.imp φ (.stab φ)) :=
  determined_of_orderFlow (translationFrame_orderFlow D) (translationFrame_stateOccurs D) φ

theorem translationFrame_plusValidOn_iff_satSet_univ (D : TemporalOrder) (φ : PlusFormula) :
    (translationFrame D).toTaskFrame.PlusValidOn φ
      ↔ ∀ V : (translationFrame D).toTaskFrame.WorldState → Atom → Prop,
          satSet V φ = Set.univ :=
  plusValidOn_iff_satSet_univ (translationFrame_orderFlow D) (translationFrame_stateOccurs D) φ

end FormalSystem.Metalogic.Independence
```

## Decisions

- **One new leaf module, not an addition to `StateSetTruth.lean`.** That file's import closure
  (via `PlusValidity`) contains neither `Semantics.ShiftSet` nor
  `Semantics.Correspondence.DurationFrames`, and widening it would drag both into every consumer
  of the bridge — including `DeterminismUndefinable.lean`, which this plan keeps byte-identical.
  `ZTimeSharpness.lean` importing `Semantics.Correspondence.DurationFrames` is the precedent for
  an `Independence/` module reaching that far.
- **`selfShift` lives in the new `Independence/` module, not in `Semantics/ShiftSet.lean`.** This
  keeps the blast radius at one new leaf. `ShiftSet.ofIntAction` is the precedent for the
  alternative placement if a later consumer outside `Independence/` wants it.
- **Both halves land, not just the absolutely choice-free one.** The absolute pin at the
  `ShiftSet` avatar is the headline, but the `*Sharpness` countermodels build on
  `translationFrame D`, so the results must exist there too. Recording only the absolute half
  would leave the applications the footnote actually points at without a statement.
- **The `translationFrame` pin is recorded as *relative*, in the words the measurement
  supports.** The five theorems report exactly what `translationFrame` reports, so the (H2)
  discharge contributes nothing — no `cor:occurrence`, no `thm:extension`, no Zorn — while the
  frame constant's own `Classical.choice` remains, through `TaskFrame.limit_of_shift`. This is
  the same carrier-borne-not-argument-borne distinction `DeterminismUndefinable.lean`'s pin
  already draws, applied to a frame constant instead of to `ℝ`.
- **`TaskFrame.limit_of_shift` is left alone**, per the settled prior decision: a choice-free
  rewrite is verified to exist, but shrinking an axiom set trips C2/C14's exact-string baseline
  across 202 pinned declarations and falsifies `MainResults.lean`'s prose contract. That is a
  decision about a repository-wide invariant, not a detail of this task.
- **The `f1_orderFlow`/`f1_stateOccurs` consolidation is dropped, on a plan-time
  measurement.** The identity it would rest on, `(selfShift realTemporalOrder).frame = F1`, is
  **not** definitionally true — term-mode `rfl`, `by rfl` and `with_unfolding_all rfl` all fail.
  Dropping it also keeps `DeterminismUndefinable.lean` byte-identical, which is the cleanest
  possible discharge of the dispatch's pin constraint.
- **`translationFlow_deterministic` is included.** It generalises `f1_deterministic` off `ℝ` at
  no cost, and makes the frame's `def:deterministic` status part of the same choice-free record
  — which is the point of a record a reader consults at a glance.
- **Mechanical `translationFlow_` / `translationFrame_` prefixes.** Each name greps straight back
  to the frame it is about, matches the tree's existing `f1_*` / `fzero_*` convention for
  per-frame instances of the generic lemmas, and matches the
  `\leanproof{\texttt{Independence.…}}` form the paper already uses at `app:drift` and
  `cor:no-characterization`.
- **The three-route table goes in `StateSetTruth.lean`, not in the new module.** Deliverable (4)
  names that file, and it is the right one: a reader asking "is this result choice-dependent?" is
  already looking at the bridge, not at a leaf that instantiates it.
- **The `#print axioms` pins are recorded as commented fences in docstrings, not as live
  directives.** C27 requires every live `#print` under `FormalSystem/` to carry an allow-list row
  with an exact per-file count; `DeterminismUndefinable.lean`'s `## Axiom pin (C4)` section is the
  standing precedent for the comment form, and it costs no companion-file maintenance.
- **No numbered-result entry in `Independence.lean` or its README.** The new module instantiates
  an existing result choice-freely; it establishes no new underivability.
  `TranslationProductCoarse.lean` is the precedent for a `## Contents` bullet with no numbered
  entry, and leaving the "thirteen results" count alone keeps the two enumerations in agreement.

## Testing & Validation

- [ ] `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build` exits 0 for the
      whole project (the dispatch's headline constraint)
- [ ] Zero `sorry` and zero new `axiom` in the diff
- [ ] **The absolute pin**: `lean_verify` reports `[propext]` for `selfShift` and
      `translationFlow`, and `[propext, Quot.sound]` for `translationFlow_taskRel`,
      `translationFlow_states_eq`, `translationFlow_orderFlow`, `translationFlow_stateOccurs`,
      `translationFlow_deterministic`, `translationFlow_plusTruthAt_iff_mem_satSet`,
      `translationFlow_determined` and `translationFlow_plusValidOn_iff_satSet_univ` — **no
      `Classical.choice` on any of the ten**
- [ ] **The relative pin**: `lean_verify` reports `[propext, Classical.choice, Quot.sound]` for
      the five `translationFrame_*` theorems, the same string
      `lean_verify FormalSystem.Semantics.translationFrame` reports
- [ ] `lean_verify FormalSystem.Metalogic.Independence.plusTruthAt_iff_mem_satSet` still reports
      `[propext]`, and `…determined_of_orderFlow` still `[propext, Quot.sound]`
- [ ] The three pinned declarations in `DeterminismUndefinable.lean` still report
      `[propext, Classical.choice, Quot.sound]`, and that file is byte-identical to HEAD
- [ ] `FormalSystem/Semantics/TaskFrame.lean` is byte-identical to HEAD
- [ ] `bash scripts/check-module-invariants.sh --no-build` exits 0 with zero `FAIL` lines; C33,
      C8, C4, C5, C9, C14, C15, C16, C20, C26, C27, C29, C30, C32, C34 and C35 all PASS
- [ ] `bash scripts/check-module-invariants.sh --emit-inventory --check` exits 0
- [ ] `bash scripts/check-paper-definitions.sh` adds no new drifted anchor and no new `sha256:`
      line
- [ ] `bash scripts/check-phantom-citations.sh` exits 0
- [ ] `bash scripts/readme-lint.sh` exits 0
- [ ] `bash scripts/typst-sync-check.sh` exits 0
- [ ] `python3 scripts/export-lean-citations.py --check` exits 0
- [ ] `bash .claude/scripts/verify-deploy.sh` exits 0, un-narrowed
- [ ] `PartialHistory.extension`, `PartialHistory.occurrence` and `StateOccurs.of_isRegular`
      appear nowhere in the new module
- [ ] No docstring added by this task cites a task number or a `file.lean:NNN` location, and none
      phrases the design relative to an unstated past
- [ ] The consumer audit's enumeration and per-consumer verdict are recorded in
      `StateSetTruth.lean`'s docstring

## Artifacts & Outputs

- `specs/799_choice_free_state_occurrence_applications/plans/01_choice-free-state-occurrence.md`
  (this file)
- `FormalSystem/Metalogic/Independence/TranslationStateSet.lean` — both routes, their
  docstrings, and the `## Axiom pin` section recording the absolute and relative profiles
- `FormalSystem/Metalogic/Independence.lean` — one import line and one `## Contents` bullet
- `FormalSystem.lean` — one import line in sorted position
- `FormalSystem/Metalogic/Independence/StateSetTruth.lean` — the `## Choice dependence`
  three-route table and the consumer-audit verdict, module docstring only
- `FormalSystem/Metalogic/Independence/README.md` — refreshed inventory, the new description
  cell, and a `## Key Results` bullet
- `FormalSystem/Metalogic/README.md`, `README.md`, and (conditionally) `FormalSystem/README.md` —
  regenerated inventory count rows only
- `typst/generated/status.typ` — regenerated whole-tree counts only
- `specs/799_choice_free_state_occurrence_applications/summaries/01_choice-free-state-occurrence-summary.md`

## Rollback/Contingency

Every phase is additive and commits independently, so the ordinary contingency is `git revert` of
the offending phase commit — no snapshot is required and none should be taken as a routine
start-of-phase precaution.

- **A phase's gate fails**: fix forward. Never discard uncommitted changes to reach a passing
  build (`.claude/rules/error-handling.md`).
- **A pinned signature will not elaborate as `## Lean Challenge Statements` states**: this is a
  Challenge statement discrepancy, so `plan-compliance.md` applies — mark the phase `[BLOCKED]`,
  record the goal state reached, and escalate. Do not substitute a different, more convenient
  statement, and do not quietly re-pin the Challenge block to match what compiled.
- **The `translationFrame_worldLinearOrder` instance creates a diamond**: make it `local`/`scoped`
  and pass it explicitly to the `OrderFlow` statements, which accept an explicit instance
  argument. Record the change; do not delete the instance and inline `inferInstanceAs` at each
  use.
- **The consumer audit finds a consumer genuinely on the Zorn route whose move would require
  editing `DeterminismUndefinable.lean`**: mark Phase 4 `[BLOCKED]` and escalate. That file is a
  declared non-goal precisely because its axiom pin is a dispatch constraint.
- **A shared generated surface carries a foreign uncommitted modification in Phase 5**: STOP and
  report. Do not regenerate over it — whole-block regeneration is exactly where a silent absorb
  of a sibling's hunk happens.
- **A build failure lands outside this task's declared file scope**: do not repair it. Check
  `git status --short` and `git log` for a concurrent sibling's in-flight edit, report it, and
  treat the failure as not necessarily this task's regression.
- **A genuine whole-tree rollback becomes necessary**: take the snapshot first, per
  `context/contracts/recovery.md`'s rollback rung (including its out-of-scope override flag) —
  never a bare reverting `git-snapshot.sh` as a precaution.
