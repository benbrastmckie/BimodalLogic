# Implementation Plan: Task #800

- **Task**: 800 - Extend the time-reflection transport from BL to the Stability language
- **Status**: [IMPLEMENTING]
- **Effort**: 5 hours
- **Dependencies**: The base time-reflection task — LANDED (`truthAt_rev`, `revAntiIso`,
  `validOn_rev_iff` and the frame-class closure `FrameClass.Sat.rev` are all in the tree; verified
  by direct read at plan time, see Overview)
- **Research Inputs**: `specs/800_stability_time_reflection_transport/reports/01_stability-time-reflection-transport.md`
- **Artifacts**: plans/01_stability-time-reflection-transport.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md, plan-compliance.md, lean4.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

The paper's cut proof of `cor:deterministic-completeness` states, in one sentence, that
`lem:time-reflection` extends to BL⁺ by sending `⊡φ` to `⊡(φ_{S|U})`, "since `τ ↦ τ⁻` carries
`⟨τ⟩_x` onto `⟨τ⁻⟩_{n(x)}`, and `F ↦ F⁻` preserves `C^⊡`". This plan builds exactly that
sentence in Lean and nothing else: one promoted carrying lemma, one new L⁺ reversal module, the
*Determined*-class closure, and one recorded decision. The syntactic half of the specification
(`PlusFormula.reflectTime` with `| stab φ => stab φ.reflectTime`) is **already in the tree** at
`FormalSystem/PlusLanguage/Formula.lean:218-237` together with `reflect_time_involution` and the
full `reflect_time_*` push-through family, so dispatch deliverable (1) is closed as
already-present rather than re-implemented.

Definition of done: the fifteen declarations named under `## Lean Challenge Statements` exist with
those exact signatures and real proofs, `lake build` is green with zero new `sorry` and zero new
`axiom`, and every generated surface the new module moves is current.

### Research Integration

The research report is integrated in full, with three corrections and one siting change recorded
under `## Decisions`. Its load-bearing contributions, all adopted:

- Deliverable (1) is already satisfied; deliverable (2) is already written one language *up*, as
  `OpenLanguage.sameState_rev_iff`, where the Plus layer cannot reach it because `OpenLanguage/`
  imports `PlusLanguage/`. The move is promotion to `Semantics/Reversal.lean`, leaving one copy.
- Four compiled `lean_run_code` probes (`success: true`, zero diagnostics) covering the carrying
  lemma in both its pointwise and its image form, the seven-case `plusTruthAt_rev`, the L⁺
  validity family, and the *Determined*-class closure by the paper's own mirror-image argument.
- The two mechanical traps, carried into the phases that hit them: `F.rev.TaskRel w x u` is
  **`F.TaskRel u x w`** definitionally (relation transpose), so `deterministic_rev` is *not*
  `fun w d => h w (-d)` and must route through `TaskFrame.deterministic_iff` and
  `FrameOver.rev_taskRel_neg`, which carries `[F.IsRegular]`; and that regularity hypothesis is
  free inside `DetSat fc F` via `haveI := h.1.isRegular`.
- Deliverable (5): keep the present route in the Deterministic soundness TR case, because the
  base-layer decision record at `FormalSystem/Metalogic/Soundness.lean` names the Deterministic
  variant *by name* as mirroring the paired recursion arm for arm.
- The unification question is answered negatively and reported, not acted on: a generic transport
  needs a new `ReflectableLanguage` class with four or five instances, which is a design change.

Independently of the report, this plan re-derived its own evidence at authoring time: the fifteen
Challenge signatures below were compiled as one `lean_run_code` probe against the live project,
returning `success: true` with `sorry` warnings only and **zero errors** — so every *statement*
this plan commits to is plan-time-verified, not carried.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No `roadmap_path` was supplied with this dispatch and no roadmap consultation was performed.

## Goals & Non-Goals

- **Goals**:
  The fifteen declarations this plan commits to, with their signatures fixed verbatim under
  `## Lean Challenge Statements` below.
  - `sameState_rev_iff` -- deliverable (2), the carrying lemma, promoted to the semantics layer
  - `image_rev_stabClass` -- deliverable (2) in the paper's own "carries **onto**" form
  - `plusTruthAt_rev` -- deliverable (3), the BL-plus form of `lem:time-reflection`
  - `plusValidOn_rev_iff` -- the single-frame form of the L-plus transport
  - `plusValidOnFrames_reflectTime` -- the primitive, carrying the closure as an argument
  - `plusValidIn_reflectTime` -- the frame-class form, no closure hypothesis needed
  - `plusValidIn_reflectTime_iff` -- the involution form
  - `plusValid_reflectTime` -- the unconstrained class
  - `reflect_determined` -- the reflection of a *Determined* instance is a *Determined* instance
  - `determinedValid_rev` -- deliverable (4) proper, the mirror-image argument
  - `determinedSat_rev` -- the class closure at a frame class
  - `plusValidDeterminedIn_reflectTime` -- deliverable (4)'s consequence, `thm:TR-valid` over the
    *Determined*-valid frames
  - `deterministic_rev` -- the deterministic-frames sibling of the closure (Decision 5)
  - `detSat_rev` -- the same at a frame class
  - `plusValidDetIn_reflectTime` -- `thm:TR-valid` over the deterministic frames
  - Deliverable (5) declares no identifier: it is a docstring edit to the Deterministic companion
    recursion, recording the decision rather than changing a proof

- **Non-Goals**:
  - Re-implementing `PlusFormula.reflectTime` or any `reflect_time_*` lemma — deliverable (1) is
    already in the tree and re-stating it would duplicate `PlusLanguage/Formula.lean:218-300`.
  - Porting `cor:deterministic-completeness`. It is already under `Metalogic/Deterministic/`.
  - Refactoring `OpenLanguage/OpenReversal.lean` beyond deleting the one lemma that is promoted and
    adding the one image-form lemma.
  - Unifying the base, Plus and Open reversals behind one transport. Reported in the research
    report's Unification Finding; it needs a new `ReflectableLanguage` class and is out of scope.
  - Promoting `stabClass` out of `OpenLanguage/OpenClasses.lean`. Not needed under this plan's
    siting (Decision 3), and it would split a module that currently reads as one subject.
  - Any edit to `FormalSystem/PlusLanguage/PlusStateLocal.lean`. The dispatch's gloss of
    `PlusStateLocal` as "the state-local equivalence the Stability clause quantifies over" is
    inaccurate: that module is the state-locality fragment of L⁺, a class of *formulas* whose
    headline is `φ ↔ ⊡φ`. The object the carrying lemma is about is the history class `⟨τ⟩_x`,
    inlined in the `stab` clause at `PlusLanguage/PlusTruth.lean:93`.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Territory collision with concurrent sibling **799** (implement phase, same working tree) on `FormalSystem.lean`, `README.md` and `typst/generated/status.typ`, all three in 799's declared `file_scope` | H | H | Sequence each contended edit as late as its own gate allows; re-read the file immediately before editing; confirm `git status --short` shows it clean *for that path*; stage by explicit file list only, never a directory or glob `git add`; read `git diff --staged` before each commit. Phase 5 carries an explicit two-branch step for the two generated files: regenerate and stage only when the path is clean, otherwise leave it and record the residual staleness rather than overwriting a sibling's in-flight hunk |
| `typst/generated/status.typ` is **already stale at HEAD**, before this task edits anything: `bash scripts/typst-sync-check.sh --counts-only` reports `formalsystem-file-count: committed=691 live=692` and `formalsystem-line-count: committed=358092 live=358279` | M | H (confirmed) | Measured at plan time and recorded in the issue log. This is a pre-existing red gate, not a regression from this task, and no phase may report it as one. This task's new `.lean` file moves both counts again; Phase 5's conditional step is the only place regeneration is attempted |
| `FormalSystem.lean` is a **generated** library root. C33 in `check-module-invariants.sh` compares it byte-for-byte against `lake exe mk_all --lib FormalSystem` output, and its header says explicitly not to hand-shape it | H | M | Phase 2 inserts exactly one line at the one sorted position (`import FormalSystem.PlusLanguage.PlusRayFibre` / **new line** / `import FormalSystem.PlusLanguage.PlusStateLocal` — code-point order puts `PlusRayFibre < PlusReversal < PlusStateLocal`), which is byte-identical to what the generator would emit, and verifies with C33. A full regeneration is deliberately **not** used: it would walk the live tree and pull a concurrent sibling's new files into this task's hunk |
| The generated inventory blocks go stale the moment the new file exists, so `check-module-invariants.sh`'s INV group is red by construction from Phase 2 until Phase 5 | M | H | Expected and declared, not discovered: Phases 1--4 assert their *named* checks PASS and that the only FAIL group is INV, never whole-script exit 0, which is unsatisfiable before Phase 5. Phase 5 regenerates with `--emit-inventory` and confirms with `--emit-inventory --check`. Never hand-edit a count column, and never call the deprecated `scripts/readme-inventory.sh` shim |
| `deterministic_rev` needs `[F.IsRegular]` and the natural one-liner is wrong | M | M (measured) | The research report's probe 3 failed on `fun w d => h w (-d)` before succeeding; Phase 3's task list carries the working route (`rw [deterministic_iff]` plus `FrameOver.rev_taskRel_neg`) rather than the shape that reads natural |
| Deleting `OpenLanguage.sameState_rev_iff` breaks `OpenReversal.lean`'s two use sites | M | L | `OpenReversal.lean:8` already imports `FormalSystem.Semantics.Reversal` and `:75` already has `open FormalSystem.Semantics`, so both call sites (`:165`, `:167`) resolve to the promoted name with no edit. Phase 1's verification is the `FormalSystem.OpenLanguage` build, which is the only thing that confirms this |
| `assert_not_exists` guards are violated by the promotion | M | L | Both guards (`Semantics/Truth.lean:156-157`, `Semantics/Reversal.lean:64-65`) bar `ProofSystem.{Axiom,DerivationTree,Derivable,FrameClass}`. `sameState_rev_iff` is a statement about `WorldHistory.state` with no proof-system dependency, so neither guard is at risk; Phase 1's build is the check |
| C9 (zero task-number citations under `FormalSystem/`) and C20 (no `file.lean:NNN` citations in publication scope) are tripped by new docstrings | M | M | Every phase's task list states the constraint inline: cite declaration names and module paths, never a line number and never a task number; keep every line at 100 characters or fewer |
| `check-metalogic-cycles.sh` rejects the new module's layering | L | L | `PlusReversal.lean` is a *semantic* module in `PlusLanguage/` importing `Semantics/`, which is the permitted direction (syntax modules may not). Phase 2 runs the checker |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |

Phases within the same wave can execute in parallel. This plan is fully sequential: each phase
consumes the declarations the previous one lands.

---

### Phase 1: The carrying lemma, promoted and stated onto [COMPLETED]

**Goal**: Deliverable (2). One copy of the carrying lemma, at the lowest layer that can state it,
plus the paper's "carries **onto**" image form; the Open layer's duplicate retired and every doc
surface that claimed Open ownership corrected.

**Tasks**:
- [x] In `FormalSystem/Semantics/Reversal.lean`, add `sameState_rev_iff` in namespace
      `FormalSystem.Semantics`, immediately after `WorldHistory.rev_surjective` and before the
      `/-! ## The reversal anti-isomorphism, and lem:time-reflection -/` section marker. Signature
      exactly as pinned under `## Lean Challenge Statements`. Body is the promoted one, unchanged:
      `change _ ↔ τ.state (- -t) = σ.state (- -t); rw [neg_neg]`
- [x] Give it a docstring saying what it is for: reversal fixes `⟨τ⟩_x` because the class is
      defined by a same-time condition, which is the paper's "`τ ↦ τ⁻` carries `⟨τ⟩_x` onto
      `⟨τ⁻⟩_{n(x)}`"; and that it is the one extra fact the `⊡`, `▷` and `◁` clauses need beyond
      an atom-level `TruthAntiIso`, which is why it sits here rather than in either language layer
- [x] Add one `sameState_rev_iff` bullet to `Semantics/Reversal.lean`'s `## Main Results` block
- [x] Delete `OpenLanguage.sameState_rev_iff` from `FormalSystem/OpenLanguage/OpenReversal.lean`
      (currently `:82-85`, with its docstring). Leave the two call sites at `:165`/`:167`
      **untouched** — `:8` imports `Semantics.Reversal` and `:75` opens `FormalSystem.Semantics`,
      so they resolve to the promoted name unchanged
- [x] In the same file's `/-! ## The class swaps -/` section, add `image_rev_stabClass` — the
      paper's `onto` as a `Set.image` equation, signature exactly as pinned below. Body is probe
      4's: `ext` plus `rintro`/`obtain`, consuming the promoted `sameState_rev_iff` and
      `WorldHistory.rev_surjective`. Docstring: this is the image form of the carrying lemma, the
      shape the paper's word *onto* asserts, and `stabClass` is the named `⟨τ⟩_x`
- [x] Update `OpenReversal.lean`'s module docstring: the `- sameState_rev_iff, agreeUpTo_rev_iff,
      agreeFrom_rev_iff — the class swaps` bullet at `:45` now names two swaps the Open layer owns
      plus `image_rev_stabClass`, and says `sameState_rev_iff` comes from `Semantics/Reversal.lean`.
      Fix the `:118` sentence that reads `stab` is `sameState_rev_iff` the same way
- [x] Update `FormalSystem/OpenLanguage.lean`'s docstring sentence at `:56`, which lists
      `sameState_rev_iff` among the swaps the Open layer carries
- [x] Update the two `FormalSystem/OpenLanguage/README.md` surfaces that name the lemma: the
      hand-written description column of the `OpenReversal.lean` row inside the generated
      inventory block (the generator rewrites every column *except* this one, so editing it now is
      correct), and the `lem:time-reflection` row of the paper-correspondence table below the block
- [x] Update `FormalSystem/Semantics/README.md`'s hand-maintained `Reversal.lean` row and
      `FormalSystem/Semantics.lean`'s `- Reversal:` docstring bullet to name `sameState_rev_iff`
      as a result this module now owns
- [x] Write no `file.lean:NNN` citation and no task number anywhere in a `.lean` or non-`specs/`
      markdown file; keep every line at 100 characters or fewer
- [x] Stage by explicit file list only; read `git diff --staged` and confirm no foreign hunk

**Timing**: 1.0 hours

**Depends on**: none

**Verification Tier**: interface

**Tier Justification**: the promotion moves a symbol out of one namespace into another, and the
enumerated one-hop dependent set is the Open language, so the specific covering checks are
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.OpenLanguage`
together with `bash scripts/check-module-invariants.sh --no-build`'s C4, C5, C9, C15, C20 and C31
assertions — no cheaper tier observes whether the two un-edited call sites still resolve.

**Scope Hypothesis**: the two signatures, the claim that the two call sites at `OpenReversal.lean`
`:165`/`:167` need no edit, and the enumeration of exactly six doc surfaces naming the lemma are
hypotheses. The signatures are **plan-time-verified** by this plan's own `lean_run_code` probe
(`success: true`, zero errors); the call-site and doc-surface claims are plan-time `grep` results
over `--include=*.lean --include=*.md`, excluding `specs/`. Confirm all three by this phase's
`FormalSystem.OpenLanguage` build and by re-running that same grep and finding zero residual
`OpenLanguage`-owned mentions.

**Files to modify**:
- `FormalSystem/Semantics/Reversal.lean` - add `sameState_rev_iff` plus a `## Main Results` bullet
- `FormalSystem/OpenLanguage/OpenReversal.lean` - delete the promoted copy; add
  `image_rev_stabClass`; correct two docstring sentences
- `FormalSystem/OpenLanguage.lean` - one docstring sentence
- `FormalSystem/OpenLanguage/README.md` - the `OpenReversal.lean` description column and the
  `lem:time-reflection` paper-correspondence row
- `FormalSystem/Semantics/README.md` - the `Reversal.lean` row
- `FormalSystem/Semantics.lean` - the `- Reversal:` docstring bullet

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.OpenLanguage`
  exits 0, detached via `Bash(run_in_background: true)`, exit read un-piped or from the guard's
  `result` subcommand
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Semantics.Reversal`
  exits 0, same invocation shape
- `bash scripts/check-module-invariants.sh --no-build`: C4, C5, C9, C15, C20 and C31 all PASS.
  Whole-script exit 0 is **not** asserted (INV goes red in Phase 2, and the `OpenReversal.lean`
  line count moves here)
- `bash scripts/check-metalogic-cycles.sh` exits 0
- `mcp__lean-lsp__lean_verify FormalSystem.Semantics.sameState_rev_iff` and
  `... FormalSystem.OpenLanguage.image_rev_stabClass` each report no `sorry`
- `grep -rn "sameState_rev_iff" --include=*.lean --include=*.md . | grep -v '^./specs/'` shows no
  remaining claim that the Open layer owns the lemma
- Zero `sorry` and zero new `axiom` in the diff; no line over 100 characters

---

### Phase 2: `PlusLanguage/PlusReversal.lean` — the BL⁺ transport [COMPLETED]

**Goal**: Deliverable (3). A new semantic module mirroring `OpenLanguage/OpenReversal.lean`
one-for-one at L⁺, carrying the seven-case `plusTruthAt_rev` and the L⁺ `thm:TR-valid` family,
registered in both aggregators.

**Tasks**:
- [x] Create `FormalSystem/PlusLanguage/PlusReversal.lean` with the standard copyright header
      (copy the four-line form from `FormalSystem/PlusLanguage/PlusValidity.lean`), and exactly
      two imports: `FormalSystem.PlusLanguage.PlusValidity` and `FormalSystem.Semantics.Reversal`
- [x] Write the module docstring in the shape `Semantics/Reversal.lean` and *(deviation: altered — C15 required a `cor:deterministic-completeness`
      row in `docs/reference/paper-definitions-of-record.md` before the citation could be
      written; added as DANGLING on the `cor:after-negation-stable` cut-material precedent.
      One file beyond this phase's declared list.)*
      `OpenLanguage/OpenReversal.lean` use: what the transport says, `## Main Results`, and a
      `## References` block citing `lem:time-reflection`, `thm:TR-valid`, `def:time-reflection`,
      and the paper's statement of the `⊡` extension inside the cut proof of
      `cor:deterministic-completeness`. Record there that unlike the base language L, L⁺ gets its
      own induction rather than an instance of `Truth.truthAt_of_truthAntiIso`, for the reason
      `Semantics/Reversal.lean`'s docstring already gives: the `⊡` clause quantifies over a class
      of histories, which is not what an atom-level `TruthAntiIso` does
- [x] Add `plusTruthAt_rev` in namespace `FormalSystem.PlusLanguage`, signature exactly as pinned
      below. Body: `induction φ generalizing τ t` with explicit terms, consuming
      `WorldHistory.rev_surjective`, `neg_lt_neg`, `neg_lt_neg_iff` and the promoted
      `sameState_rev_iff` — the `stab` case is where the carrying lemma is used, and the
      `untl`/`snce` cases are where the bounds negate
- [x] Add `plusValidOn_rev_iff`, `plusValidOnFrames_reflectTime`, `plusValidIn_reflectTime`,
      `plusValidIn_reflectTime_iff` and `plusValid_reflectTime`, signatures exactly as pinned
      below, mirroring `Semantics/Validity.lean`'s base family statement for statement. Each
      docstring names its paper label and says it is the L⁺ twin of the base declaration;
      `plusValidIn_reflectTime` records that no closure hypothesis is needed and that this is the
      content of `ProofSystem.FrameClass.Sat.rev`
- [x] Re-read `FormalSystem/PlusLanguage.lean` immediately before editing, confirm `git status
      --short` shows it clean, add `import FormalSystem.PlusLanguage.PlusReversal` to its import
      block, and add one `PlusLanguage.PlusReversal` bullet to the docstring's
      `## Semantic modules` list
- [x] Re-read `FormalSystem.lean` immediately before editing and confirm `git status --short`
      shows that path clean (it is in sibling 799's declared `file_scope`). Insert exactly one
      line, `import FormalSystem.PlusLanguage.PlusReversal`, between
      `import FormalSystem.PlusLanguage.PlusRayFibre` and
      `import FormalSystem.PlusLanguage.PlusStateLocal`. Do **not** regenerate the file with
      `lake exe mk_all`: a regeneration walks the live tree and would absorb a sibling's new
      modules into this task's hunk
- [x] Tag nothing `@[simp]` and declare no instance; write no `set_option`; write no *(deviation: altered — `check-metalogic-cycles.sh`
      additionally requires a per-file layer row for every new language-directory module, which
      the plan's Risks table did not anticipate; added `"PlusReversal": 1` to
      `scripts/measure-refactor-partitions.py` and the matching name to `ORGANISATION.md`, as the
      checker instructs. Two files beyond this phase's declared list.)*
      `file.lean:NNN` citation and no task number; keep every line at 100 characters or fewer
- [x] Stage the three files by explicit list only; read `git diff --staged` and confirm
      `FormalSystem.lean` shows exactly one added line and zero removed

**Timing**: 1.5 hours

**Depends on**: 1

**Verification Tier**: interface

**Tier Justification**: a root-aggregator edit's one-hop dependent set *is* the library, so the
specific covering checks are `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 --
build FormalSystem` together with `lake exe checkInitImports` (C24) and
`bash scripts/check-module-invariants.sh --no-build`'s C33, C6, C8 and C4 assertions — no cheaper
tier observes whether the new module is reachable from the generated root closure.

**Scope Hypothesis**: the six signatures, the two-import claim, and the sorted insertion point in
`FormalSystem.lean` are hypotheses. The signatures are plan-time-verified by this plan's own
`lean_run_code` probe (`success: true`, zero errors, imports
`FormalSystem.Metalogic.Deterministic.Validity` + `FormalSystem.Semantics.Reversal` +
`FormalSystem.OpenLanguage.OpenReversal`), which is a *superset* of this module's two imports —
so the narrower two-import claim is confirmed only by this phase's own build. The insertion point
is a plan-time code-point-order derivation over the committed `FormalSystem.lean`. Confirm both by
the library build and by C33.

**Files to modify**:
- `FormalSystem/PlusLanguage/PlusReversal.lean` - new module: header, two imports, module
  docstring, `plusTruthAt_rev`, and the five validity-family declarations
- `FormalSystem/PlusLanguage.lean` - one import line plus one `## Semantic modules` bullet
- `FormalSystem.lean` - exactly one sorted import line; nothing else

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem` exits 0,
  detached, exit read un-piped or from the guard's `result` subcommand
- `lake exe checkInitImports` exits 0 (C24)
- `bash scripts/check-module-invariants.sh --no-build`: C33, C24, C4, C6, C8, C9, C15, C20, C26,
  C29, C30, C31 and C32 all PASS, and C6's unreachable census does not name `PlusReversal.lean`.
  Whole-script exit 0 is **not** asserted — the INV generated-inventory group is red by
  construction from this phase until Phase 5 (see Risks)
- `bash scripts/check-metalogic-cycles.sh` exits 0
- `bash scripts/check-copyright-headers.sh` exits 0
- `mcp__lean-lsp__lean_verify FormalSystem.PlusLanguage.plusTruthAt_rev` reports no `sorry`, and
  the same for each of the five validity-family declarations
- Zero `sorry` and zero new `axiom` in the diff; no line over 100 characters in the new file
- `git diff -- FormalSystem.lean` shows exactly one added line and zero removed

---

### Phase 3: The *Determined*-class closure and its deterministic sibling [COMPLETED]

**Goal**: Deliverable (4). The task frames validating *Determined* are closed under `rev`, by the
paper's own mirror-image argument, and hence the BL⁺ form of `thm:TR-valid` over `C^⊡`; plus the
same three statements over the deterministic frames, which is the pair
`cor:deterministic-completeness` is actually about.

**Tasks**:
- [x] In `FormalSystem/Semantics/FrameProperty.lean`, inside `namespace TaskFrame` and immediately
      after `deterministic_iff`, add `deterministic_rev`, signature exactly as pinned below.
      Body routes through `rw [deterministic_iff]` and `FrameOver.rev_taskRel_neg`. Do **not**
      write `fun w d => h w (-d)`: `F.rev.TaskRel w x u` is `F.TaskRel u x w` definitionally
      (`FrameOver.rev_taskRel`, the relation transpose), and reaching
      `F.TaskRel w (-x) u` is exactly what `rev_taskRel_neg` does, which is why the `[F.IsRegular]`
      instance argument is required and not decorative *(deviation: altered — the plan's
      named repair `rw [FrameOver.rev_taskRel_neg]` also fails: `F.rev.TaskRel` is
      `F.toFibre.rev.TaskRel` only definitionally, so `rw` finds no syntactic occurrence of the
      pattern. Working route applies the lemma as an explicit term at `F.toFibre`; the
      `deterministic_iff` rewrite the plan names is still load-bearing.)*
- [x] Give it a docstring recording that trap in one sentence, and naming the paper's reason the
      converse frame "leaves the temporal order unchanged"
- [x] Add `import FormalSystem.PlusLanguage.PlusReversal` to
      `FormalSystem/Metalogic/Deterministic/Validity.lean`
- [x] In that file, add `reflect_determined` — that the reflection of a *Determined* instance is a
      *Determined* instance — by `simp only [PlusFormula.reflectTime, reflect_time_involution]`
      over the `reflect_time_*` family
- [x] Add `determinedValid_rev`, deliverable (4) proper, by the paper's mirror-image argument:
      `plusValidOn_rev_iff` at the instance `φ.reflectTime → ⊡φ.reflectTime`, whose own reflection
      is `φ → ⊡φ` by `reflect_time_involution`; `rwa [reflect_determined]` closes it. The
      docstring quotes the paper's clause — `F⁻` validates an instance of *Determined* just in
      case `F` validates its mirror image, itself an instance of *Determined*
- [x] Add `determinedSat_rev` as `⟨FrameClass.Sat.rev h.1, determinedValid_rev h.2⟩`, and
      `plusValidDeterminedIn_reflectTime` — deliverable (4)'s consequence, the BL⁺ `thm:TR-valid`
      over `C^⊡` — as `plusValidOnFrames_reflectTime` at that closure. `FrameClass.Sat.rev`
      already exists with **no** hypothesis; do not re-derive it
- [x] Add `detSat_rev` and `plusValidDetIn_reflectTime`, the deterministic-frames analogues.
      `detSat_rev` recovers `deterministic_rev`'s regularity hypothesis from inside the structure
      with `haveI := h.1.isRegular`, since every `FrameClass.Sat` value carries
      `TaskFrame.IsRegular`
- [x] Add one bullet per new declaration to `Deterministic/Validity.lean`'s `## Main Results` block
- [x] Write no `file.lean:NNN` citation and no task number; keep every line at 100 characters or
      fewer; stage by explicit file list only and read `git diff --staged`

**Timing**: 1.0 hours

**Depends on**: 2

**Verification Tier**: interface

**Tier Justification**: `FrameProperty.lean` sits far below the metalogic and is imported
transitively across the library, and a new name there can collide with a downstream `open`, which
a single-module build cannot see — so the covering checks are
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem` together with
`bash scripts/check-module-invariants.sh --no-build`'s C3, C4, C9, C15, C20 and C31 assertions.

**Scope Hypothesis**: the seven signatures and the claim that `FormalSystem.PlusLanguage.PlusReversal`
is the only import `Deterministic/Validity.lean` must gain are hypotheses. The signatures are
plan-time-verified by this plan's own probe (`success: true`, zero errors); the single-import claim
is carried from the research report's probe 2, where the probe-1 results were stubbed as `axiom`
rather than imported, so it is **not** independently confirmed and must be confirmed by this
phase's build. Confirm both by the `FormalSystem` build.

**Files to modify**:
- `FormalSystem/Semantics/FrameProperty.lean` - `TaskFrame.deterministic_rev` after
  `deterministic_iff`
- `FormalSystem/Metalogic/Deterministic/Validity.lean` - one import line; `reflect_determined`,
  `determinedValid_rev`, `determinedSat_rev`, `plusValidDeterminedIn_reflectTime`, `detSat_rev`,
  `plusValidDetIn_reflectTime`; `## Main Results` bullets

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem` exits 0,
  detached, exit read un-piped or from the guard's `result` subcommand
- `bash scripts/check-module-invariants.sh --no-build`: C3 (zero structural `sorry`), C4, C9, C15,
  C20, C31 and C32 all PASS; whole-script exit 0 is not asserted (INV still red, see Risks)
- `mcp__lean-lsp__lean_verify` reports no `sorry` for each of the seven new declarations, fully
  qualified
- `bash scripts/check-evidence-probes.sh` exits 0
- Zero `sorry` and zero new `axiom` in the diff; no line over 100 characters

---

### Phase 4: The recorded decision on the Deterministic TR case [NOT STARTED]

**Goal**: Deliverable (5). The decision on whether the Deterministic soundness proof's TR case
should now consume deliverable (4) is **recorded in the docstring**, and the verdict is: keep the
present route, with (4) named there as an independent second route.

**Tasks**:
- [ ] Edit `det_derivable_valid_and_reflect_time_validDeterminedIn`'s docstring in
      `FormalSystem/Metalogic/Deterministic/Soundness.lean`. Change nothing else in the file: the
      `.time_reflection` arm keeps its `⟨h.2, ...⟩` plus `reflect_time_involution` shape
- [ ] Write the record in the shape `Metalogic/Soundness.lean` uses for
      `axiom_reflect_time_validIn_min`: name the second route
      (`detAxiom_validDeterminedIn` together with `plusValidDeterminedIn_reflectTime` derives
      `detAxiom_reflect_time_validDeterminedIn` on its own), name what it discharges, and point at
      the base-layer decision record in `Metalogic/Soundness.lean` for why the paired shape is kept
- [ ] State the two reasons that bind here, both by reference rather than by restatement: the
      base-layer record's reason 2 names the Deterministic variant **by name** as mirroring the
      base recursion arm for arm, so switching only this copy would falsify that sentence and
      leave the four sibling recursions in three different shapes; and reason 3 — that the two
      routes are independent derivations of the same reflection validities, this one from the
      axioms' own semantics and `plusValidDeterminedIn_reflectTime` from frame reversal — applies
      verbatim, which is precisely why the second route is worth recording
- [ ] Reference the base record by declaration name and module path only. Write no
      `file.lean:NNN` citation and no task number; keep every line at 100 characters or fewer
- [ ] Stage the one file; read `git diff --staged` and confirm the diff is docstring-only

**Timing**: 0.5 hours

**Depends on**: 3

**Verification Tier**: local

**Tier Justification**: the edit is docstring-only inside one module with no change to any
signature, so `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build
FormalSystem.Metalogic.Deterministic.Soundness` together with
`bash scripts/check-module-invariants.sh --no-build`'s C5, C9, C15, C19, C20, C31 and C32
assertions is the cheapest set that covers it.

**Scope Hypothesis**: the claim that the diff is docstring-only, and the claim that the second
route really does discharge `detAxiom_reflect_time_validDeterminedIn` on its own, are both
hypotheses. The second is carried from the research report's Decision 4 and is **not**
independently compiled by this plan. Confirm the first with `git diff` read-through, and the
second by actually checking at implementation time that
`plusValidDeterminedIn_reflectTime (detAxiom_validDeterminedIn h_ax h_fc)` elaborates at that
goal — via `lean_multi_attempt` or a scratch `example`, never by landing it. If it does not, the
docstring must say so plainly rather than asserting a route that does not exist.

**Files to modify**:
- `FormalSystem/Metalogic/Deterministic/Soundness.lean` - the
  `det_derivable_valid_and_reflect_time_validDeterminedIn` docstring only

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build
  FormalSystem.Metalogic.Deterministic.Soundness` exits 0, detached, exit read un-piped or from
  the guard's `result` subcommand
- `bash scripts/check-module-invariants.sh --no-build`: C5, C9, C15, C19, C20, C31 and C32 all
  PASS; whole-script exit 0 is not asserted (INV still red, see Risks)
- `git diff -- FormalSystem/Metalogic/Deterministic/Soundness.lean` touches only docstring lines:
  no `theorem`, `def`, tactic or term line changed
- No line over 100 characters; no `file.lean:NNN` and no task number in the diff

---

### Phase 5: Generated surfaces and the full gate [NOT STARTED]

**Goal**: Every machine-owned surface the new module moves is current, and the complete repository
gate set is observed green.

**Tasks**:
- [ ] Write the hand-written description column for the new `PlusReversal.lean` row in
      `FormalSystem/PlusLanguage/README.md` — the generator owns every other column, so author the
      description first and let the regeneration place the row and its line count
- [ ] Add one `PlusLanguage/PlusReversal.lean` entry to `FormalSystem/PlusLanguage/README.md`'s
      paper-correspondence surface if that file carries one, naming `lem:time-reflection` and
      `thm:TR-valid` at L⁺; if it does not, skip and say so in the summary rather than inventing a
      section
- [ ] Run `bash scripts/check-module-invariants.sh --emit-inventory` to regenerate **every**
      generated inventory block, then `git status --short` to see exactly which blocks moved.
      Expect at minimum `FormalSystem/PlusLanguage/README.md` (new row plus counts),
      `FormalSystem/OpenLanguage/README.md` (the `OpenReversal.lean` line count) and the root
      `README.md` (`rows=totals`, the whole-tree file and line rollup). Never hand-edit a count
      column; never call the deprecated `scripts/readme-inventory.sh` shim
- [ ] **Contended path, root `README.md`** — it is in sibling 799's declared `file_scope`. Before
      staging it, re-read it and check `git status --short -- README.md`. If the only change is the
      regeneration this phase just produced, stage it. If a foreign uncommitted modification is
      present, `git checkout`-ing it is forbidden: leave the regenerated hunk unstaged for that one
      path, record the residual staleness in the summary and the handoff `blockers`, and report the
      foreign modification after confirming with `git log` that it is not this task's own work
- [ ] Confirm with `bash scripts/check-module-invariants.sh --emit-inventory --check` that every
      block is byte-current
- [ ] **Contended path, `typst/generated/status.typ`** — also in 799's `file_scope`, and
      **already stale at HEAD before this task started** (`--counts-only` reported
      `committed=691 live=692` and `committed=358092 live=358279` at plan time). Check
      `git status --short -- typst/generated/status.typ`. If clean, run
      `bash scripts/typst-sync-check.sh --fix` (or `bash scripts/typst-status-counts.sh`), read the
      diff, and stage only that file — noting in the summary that the regeneration necessarily
      absorbs the pre-existing one-file drift as well as this task's own, and that the pre-existing
      drift is not a regression from this task. If a foreign modification is present, leave it
      alone, record the residual staleness, and report it
- [ ] Run the full gate set below and read each exit status un-piped. Record each command and its
      exit code in the implementation summary
- [ ] Stage by explicit file list only; read `git diff --staged` before the phase-closing commit

**Timing**: 1.0 hours

**Depends on**: 4

**Verification Tier**: full

**Scope Hypothesis**: the claim that exactly three generated inventory blocks move
(`FormalSystem/PlusLanguage/README.md`, `FormalSystem/OpenLanguage/README.md`, root `README.md`)
is a plan-time hypothesis, derived from a `grep` for `BEGIN GENERATED: inventory` markers and
their `dir=`/`rows=` options — `FormalSystem/README.md`'s block is `rows=loose`, which lists only
files sitting directly in `FormalSystem/` and so should **not** move. Confirm by reading
`git status --short` immediately after `--emit-inventory` and comparing against that list; a fourth
moved block is a finding to record, not a surprise to absorb silently.

**Files to modify**:
- `FormalSystem/PlusLanguage/README.md` - the new `PlusReversal.lean` row's hand-written
  description, plus the regenerated columns
- `FormalSystem/OpenLanguage/README.md` - regenerated `OpenReversal.lean` line count
- `README.md` - regenerated whole-tree totals (contended; conditional, see tasks)
- `typst/generated/status.typ` - regenerated file and line counts (contended; conditional, see
  tasks)

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build` exits 0 for the whole
  project, detached, exit read un-piped or from the guard's `result` subcommand
- `bash scripts/check-module-invariants.sh` exits 0 with zero `FAIL` lines — INV included this
  time — and prints `ALL CHECKS PASSED`
- `bash scripts/check-module-invariants.sh --emit-inventory --check` exits 0
- `bash scripts/check-metalogic-cycles.sh` exits 0
- `bash scripts/typst-sync-check.sh` exits 0, **or**, if the conditional branch above left
  `typst/generated/status.typ` to its sibling owner, `--counts-only` reports exactly the two
  whole-tree count rows and no name-resolution or appendix violation, with the residual recorded
  as a `#### Reasoned Exclusions` entry on this phase citing the foreign modification as evidence
- `bash scripts/readme-lint.sh` exits 0
- `bash scripts/check-copyright-headers.sh` exits 0
- `bash scripts/check-phantom-citations.sh` exits 0
- `bash scripts/check-paper-definitions.sh` exits 0, run without tail-truncation so a drift list
  longer than 20 anchors is read in full
- `lake exe checkInitImports` exits 0
- `bash .claude/scripts/verify-deploy.sh` exits 0 — the complete repository gate aggregator, run
  un-narrowed. Neither `--skip-slow` nor `--only-gate` discharges this tier: a selected-subset
  pass is not evidence the full set holds
- `mcp__lean-lsp__lean_verify` reports no `sorry` for all fifteen declarations, fully qualified
- `grep -rn "sorry" --include=*.lean FormalSystem/PlusLanguage/PlusReversal.lean` returns nothing

---

## Lean Challenge Statements

The fifteen declarations below are the contract. All fifteen signatures were compiled as one
`lean_run_code` probe against the live project at plan-authoring time, returning `success: true`
with `declaration uses 'sorry'` warnings only and **zero errors**. Bodies are `sorry` here by
design: this section pins statements, never proofs.

```lean
import FormalSystem.Metalogic.Deterministic.Validity
import FormalSystem.Semantics.Reversal
import FormalSystem.OpenLanguage.OpenReversal

namespace FormalSystem.Semantics

open FormalSystem.Syntax

theorem sameState_rev_iff {F : TaskFrame} (τ σ : WorldHistory F) (t : F.Duration) :
    τ.state t = σ.state t ↔ τ.rev.state (-t) = σ.rev.state (-t) := sorry

end FormalSystem.Semantics

namespace FormalSystem.Semantics.TaskFrame

theorem deterministic_rev {F : TaskFrame} [F.IsRegular] (h : F.Deterministic) :
    F.rev.Deterministic := sorry

end FormalSystem.Semantics.TaskFrame

namespace FormalSystem.OpenLanguage

open FormalSystem.Semantics

variable {F : TaskFrame}

theorem image_rev_stabClass (τ : WorldHistory F) (x : F.Duration) :
    WorldHistory.rev '' stabClass τ x = stabClass τ.rev (-x) := sorry

end FormalSystem.OpenLanguage

namespace FormalSystem.PlusLanguage

open FormalSystem.Semantics

theorem plusTruthAt_rev {F : TaskFrame} (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (φ : PlusFormula) : PlusTruthAt M τ t φ ↔ PlusTruthAt M.rev τ.rev (-t) φ.reflectTime := sorry

theorem plusValidOn_rev_iff (F : TaskFrame) (φ : PlusFormula) :
    F.rev.PlusValidOn φ.reflectTime ↔ F.PlusValidOn φ := sorry

theorem plusValidOnFrames_reflectTime {P : TaskFrame → Prop} {φ : PlusFormula}
    (hP : ∀ F : TaskFrame, P F → P F.rev) (h : PlusValidOnFrames P φ) :
    PlusValidOnFrames P φ.reflectTime := sorry

theorem plusValidIn_reflectTime {fc : ProofSystem.FrameClass} {φ : PlusFormula}
    (h : PlusValidIn fc φ) : PlusValidIn fc φ.reflectTime := sorry

theorem plusValidIn_reflectTime_iff {fc : ProofSystem.FrameClass} {φ : PlusFormula} :
    PlusValidIn fc φ.reflectTime ↔ PlusValidIn fc φ := sorry

theorem plusValid_reflectTime {φ : PlusFormula} (h : PlusValid φ) :
    PlusValid φ.reflectTime := sorry

end FormalSystem.PlusLanguage

namespace FormalSystem.Metalogic.Deterministic

open FormalSystem.Syntax
open FormalSystem.ProofSystem (FrameClass)
open FormalSystem.PlusLanguage
open FormalSystem.Semantics

theorem reflect_determined (φ : PlusFormula) :
    (φ.imp φ.stab).reflectTime = φ.reflectTime.imp φ.reflectTime.stab := sorry

theorem determinedValid_rev {F : TaskFrame} (h : DeterminedValid F) :
    DeterminedValid F.rev := sorry

theorem determinedSat_rev {fc : FrameClass} {F : TaskFrame} (h : DeterminedSat fc F) :
    DeterminedSat fc F.rev := sorry

theorem plusValidDeterminedIn_reflectTime {fc : FrameClass} {φ : PlusFormula}
    (h : PlusValidDeterminedIn fc φ) : PlusValidDeterminedIn fc φ.reflectTime := sorry

theorem detSat_rev {fc : FrameClass} {F : TaskFrame} (h : DetSat fc F) :
    DetSat fc F.rev := sorry

theorem plusValidDetIn_reflectTime {fc : FrameClass} {φ : PlusFormula}
    (h : PlusValidDetIn fc φ) : PlusValidDetIn fc φ.reflectTime := sorry

end FormalSystem.Metalogic.Deterministic
```

The probe's import list is a **superset** of what the real modules will carry: it is one file
spanning five namespaces, so it imports everything any of them needs. Each real module's own
import list is pinned in its phase's task list — `PlusReversal.lean` takes exactly two imports,
and `Deterministic/Validity.lean` gains exactly one.

## Decisions

1. **Deliverable (1) is closed as already-present, not re-implemented.** `PlusFormula.reflectTime`
   is in the tree with the Stability clause already commuting (`| stab φ => stab φ.reflectTime`),
   alongside `reflect_time_involution` and the full `reflect_time_*` family. The dispatch's
   "check whether it already carries one" instruction resolves to **yes**.
2. **Deliverable (2) is delivered by promotion, not a second copy.** A Plus-local
   `sameState_rev_iff` would make three copies of a four-line, language-free fact about
   `WorldHistory.state`. Promoting it to `Semantics/Reversal.lean` leaves one, and the Open
   layer's two call sites resolve to the promoted name without editing either, because that file
   already imports `Semantics.Reversal` and already opens `FormalSystem.Semantics`.
3. **The image form is sited in `OpenLanguage/OpenReversal.lean`, not in `OpenClasses.lean`** —
   a deliberate change from the research report's recommendation. `OpenClasses.lean` imports only
   `PlusLanguage.PlusPasting` and would need a new `Semantics.Reversal` import to state a
   reversal fact, whereas `OpenReversal.lean` already reaches both `stabClass` (transitively,
   through `OpenValidity` → `OpenTruth` → `OpenClasses`) and `WorldHistory.rev`, and already
   carries a `/-! ## The class swaps -/` section that is exactly this lemma's subject. Net effect:
   zero new imports and zero module split, and the image form sits beside the pointwise lemma it
   consumes. `stabClass` is therefore **not** promoted; if a future task wants the image form at
   the Plus layer, promoting `stabClass` is that task's move.
4. **A new module `PlusLanguage/PlusReversal.lean`, not an extension of `PlusValidity.lean`.**
   Merging would compile — `PlusValidity.lean` already transitively imports `Semantics.Reversal`
   through `Semantics.Validity` — but a separate module mirrors `OpenLanguage/OpenReversal.lean`
   one-for-one, which is what makes the two layers readable side by side, and keeps
   `PlusValidity.lean` on its stated subject.
5. **The deterministic-frames sibling (`deterministic_rev`, `detSat_rev`,
   `plusValidDetIn_reflectTime`) is IN scope**, although the dispatch's five-item DELIVER list
   does not name it. Reasoning: the dispatch's SCOPE LIMIT excludes a *port of
   `cor:deterministic-completeness`*, and these three are not that — they are the same reflection
   transport at the sibling frame predicate `DetSat`, they are three lines each, they were
   compiled in the research report's probe 3, and without them the reflection story stops one
   class short of the pair `cor:deterministic-completeness` is about. They are deliberately
   confined to Phase 3's last two task bullets so they are the single droppable unit if scope must
   be cut; dropping them means also striking their three identifiers from
   `## Lean Challenge Statements`, which is a plan revision, not an implementation-time edit.
6. **Deliverable (5): the Deterministic soundness TR case KEEPS its present route**, with
   deliverable (4) recorded in the docstring as an independent second route. The base-layer
   decision record in `Metalogic/Soundness.lean` already decided this question and gave three
   reasons; its reason 2 names the Deterministic variant by name as mirroring the paired recursion
   arm for arm, so switching only this copy would falsify that sentence and leave the four sibling
   recursions in three different shapes.
7. **`PlusStateLocal` is not involved**, correcting the dispatch's gloss. See Non-Goals.
8. **`FormalSystem.lean` gets a one-line insertion, never a regeneration.** C33 compares it
   byte-for-byte against `lake exe mk_all --lib FormalSystem` output, and a single line at the
   correct code-point-sorted position is byte-identical to that output. A regeneration would walk
   the live tree and absorb concurrent sibling 799's in-flight modules into this task's hunk,
   which is exactly what the territory contract forbids.
9. **The unification question is answered and reported, not acted on.** The three reversal
   transports cannot be collapsed behind one transport at the current layers: `TruthAntiIso` and
   `truthAt_of_truthAntiIso` are `Formula`-only, the clause layer supplies clause lemmas but no
   recursor and no `reflectTime`, and L^▷ cannot be derived from L⁺ through `ofPlus` because
   `ofPlus` only reaches the image of L⁺. A generic transport needs a new `ReflectableLanguage`
   class carrying `reflectTime` plus an induction principle, with an instance per language — a
   design change with four or five instances to write. Also relevant to whoever attempts it: only
   two of the five object languages have a reversal transport today, and L⋆ would not inherit one
   for free, because `starTruthAt_timeShift` already shifts the stored-time vector separately.

## Testing & Validation

- [ ] All fifteen `## Lean Challenge Statements` declarations exist with those exact signatures and
      real proofs; `lean_verify` reports no `sorry` for each, fully qualified
- [ ] `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build` exits 0 for the
      whole project, detached, with the exit read un-piped or from the guard's `result` subcommand
- [ ] Zero new `sorry` and zero new `axiom` anywhere in the task's diff; C3 PASSes
- [ ] The `assert_not_exists` guards in `Semantics/Truth.lean` and `Semantics/Reversal.lean` remain
      satisfied (the promoted lemma mentions only `WorldHistory.state`)
- [ ] `bash scripts/check-module-invariants.sh` exits 0 with zero `FAIL` lines and prints
      `ALL CHECKS PASSED`
- [ ] `bash scripts/check-module-invariants.sh --emit-inventory --check` exits 0
- [ ] `bash scripts/check-metalogic-cycles.sh` exits 0
- [ ] `bash scripts/check-copyright-headers.sh` exits 0
- [ ] `bash scripts/readme-lint.sh` exits 0
- [ ] `bash scripts/check-phantom-citations.sh` exits 0
- [ ] `bash scripts/check-paper-definitions.sh` exits 0, read without tail-truncation
- [ ] `bash scripts/check-evidence-probes.sh` exits 0
- [ ] `lake exe checkInitImports` exits 0
- [ ] `bash scripts/typst-sync-check.sh` exits 0, or the conditional residual is recorded with the
      foreign modification cited as evidence
- [ ] `bash .claude/scripts/verify-deploy.sh` exits 0, un-narrowed
- [ ] No line over 100 characters in any new or edited `.lean` file; no `file.lean:NNN` citation and
      no task number in any file outside `specs/`

## Artifacts & Outputs

- `FormalSystem/PlusLanguage/PlusReversal.lean` — new module: `plusTruthAt_rev` and the L⁺
  `thm:TR-valid` family
- `FormalSystem/Semantics/Reversal.lean` — the promoted `sameState_rev_iff`
- `FormalSystem/Semantics/FrameProperty.lean` — `TaskFrame.deterministic_rev`
- `FormalSystem/Metalogic/Deterministic/Validity.lean` — the `C^⊡` and `DetSat` closures and their
  `thm:TR-valid` consequences
- `FormalSystem/Metalogic/Deterministic/Soundness.lean` — the recorded decision (docstring only)
- `FormalSystem/OpenLanguage/OpenReversal.lean` — duplicate retired, `image_rev_stabClass` added
- `FormalSystem.lean`, `FormalSystem/PlusLanguage.lean`, `FormalSystem/OpenLanguage.lean`,
  `FormalSystem/Semantics.lean` — registration and docstring surfaces
- `FormalSystem/PlusLanguage/README.md`, `FormalSystem/OpenLanguage/README.md`,
  `FormalSystem/Semantics/README.md`, `README.md` — inventory and correspondence surfaces
- `typst/generated/status.typ` — regenerated counts (conditional on territory, see Phase 5)
- `specs/800_stability_time_reflection_transport/summaries/01_stability-time-reflection-transport-summary.md`
  — implementation summary

## Rollback/Contingency

Every phase is a separate commit, so the ordinary contingency is to stop at the last green phase
and report; nothing in Phases 1--4 is load-bearing for an unrelated build. The three recovery
rungs, in order:

1. **Fix forward.** A build error is corrected in source. Never discard uncommitted changes to
   reach a passing build.
2. **Stop and report.** If a phase cannot be completed as written — including the case where a
   Challenge signature turns out to be wrong — mark the phase `[BLOCKED]` and raise it. Per
   `.claude/rules/plan-compliance.md`, a `.lean` plan step that cannot be executed as written is
   escalated, never silently substituted, and a recorded Challenge statement is never quietly
   weakened or quietly rewritten to match what was implemented.
3. **Snapshot, then roll back.** Only for a genuine rollback. Run
   `bash .claude/scripts/git-snapshot.sh 800` first (task number explicit), per
   `.claude/context/contracts/recovery.md`'s rollback rung, and add `--allow-out-of-scope` only in
   the deliberate whole-tree case that rung describes. For an ordinary defensive checkpoint before
   risky work, use `bash .claude/scripts/git-snapshot.sh 800 --no-revert`, which is durable without
   reverting the working tree.

Under the concurrency this cycle carries, a reverting snapshot would also revert sibling 799's
in-flight work on the same tree. Rung 3 is therefore a last resort here, and the `--no-revert`
form is the only checkpoint any phase should take.
