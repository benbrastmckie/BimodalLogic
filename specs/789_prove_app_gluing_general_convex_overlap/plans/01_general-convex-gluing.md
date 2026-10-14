# Implementation Plan: Task #789

- **Task**: 789 - Prove `app:gluing` in full generality (two convex histories, nonempty overlap)
- **Status**: [IMPLEMENTING]
- **Effort**: 7 hours
- **Dependencies**: None
- **Research Inputs**: specs/789_prove_app_gluing_general_convex_overlap/reports/01_general-convex-gluing.md
- **Artifacts**: plans/01_general-convex-gluing.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

The paper's Gluing lemma `app:gluing` — for convex histories `τ₁, τ₂` over a task frame `F`
whose domains overlap and which agree on the overlap, `τ₁ ∪ τ₂` is the unique convex history on
the union restricting to both — is landed once at the convex-history layer as a new module
`FormalSystem/Semantics/Gluing.lean`, in namespace `FormalSystem.Semantics.PartialHistory`. The
research round left the entire construction machine-checked in
`specs/789_prove_app_gluing_general_convex_overlap/gluing-probe.lean` (exit 0 under
`lake env lean`, no `sorry`, no linter warning, `#print axioms` reporting `[propext, Quot.sound]`
throughout), so the implementation round is transcription, wiring, and gate work rather than
discovery. Done means: the general lemma and its two entry points compile green in the library;
the choice-free claim `rmk:choice` makes for `app:gluing` is asserted on every build by the C14
baseline rather than left as docstring prose; the three landed special cases are left
independent with that decision and its reason recorded; and the citation surface points at the
general declaration where it currently names only a special case.

### Research Integration

- Every proof step is transcribed from the verified probe, not reconstructed. The probe's
  declaration list maps one-to-one onto this plan's Phase 2 and Phase 3 task lists.
- **Decision adopted (report Decision 2)**: `DecidablePred τ₁.domain` is accepted as an
  instance-implicit hypothesis and documented as a Lean-constructivity artifact (eliminating a
  two-constructor `Prop` into a `Type`), with the Mathlib `Set.piecewise` /
  `PartialEquiv.piecewise` precedent cited. The three rejected escapes — `Classical.propDecidable`
  (reinstates `Classical.choice`, destroying the pin this task exists to land), unique choice
  (unavailable in Lean 4 without `Classical.choice`), and the `pasteAt` disjointification (does
  not generalize: with `X₁ = [0,10]`, `X₂ = [5,6]`, `z = 5` the disjointified predicate is
  `[0,6]`, not `X₁ ∪ X₂`) — are recorded in the module docstring.
- **Decision adopted (report Decision 3)**: home is a new `FormalSystem/Semantics/Gluing.lean`
  importing `FormalSystem.Semantics.PartialHistory` only, so the import closure provably cannot
  reach `Extension/` or `Presheaf/` — itself evidence for the choice-free claim. `Extension/` was
  rejected on charter (that cluster is the Zorn/*Saturation* chain; this lemma is choice-free and
  independent of `thm:extension`); appending to `PartialHistory.lean` is retained as the fallback
  if aggregator contention bites.
- **Decision adopted (report Decision 6)**: the two Presheaf seam cases
  (`Presheaf.sheaf_clause`, `Ray.seamGlue`) are left **independent**, not re-derived. Re-deriving
  them would replace their `dite` tests with `τ₁.domain z`, and `Sheaf.lean`'s Implementation
  Notes record that `glue_states_le`/`glue_states_not_le` being *literally* `dif_pos`/`dif_neg`
  is load-bearing downstream. The instance claim is discharged by **witness** instead (Phase 3),
  which is already verified in the probe. `Presheaf.directed_gluing_clause` is independent as a
  matter of mathematics, not of filing: it measures `Classical.choice` and `app:gluing`'s own ℚ
  counterexample shows *Saturation* is genuinely required there.
- **Decision adopted (report Decision 7)**: the backwards-orientation cases of the unconditional
  `respects_task` field go through `TaskFrame.reflection_of_ne` (the *off-zero* law), never
  `FrameOver.reflection`. The unrestricted form closes the same goals and measures
  `Classical.choice`. Recorded as an Implementation-Notes trap, and made mechanical by Phase 5.
- **Decision adopted (report Decision 8)**: `app:gluing` is cited **by name only, never
  block-quoted**. Quoting it would oblige promoting its `LIVE-UNPINNED` row to the pinned
  manifest in `docs/reference/paper-definitions-of-record.md`, which is inside a concurrently
  dispatched sibling's declared `file_scope`. Verbatim quotation remains available for
  `def:world-history`, which is pinned, and that is the right anchor for the convexity and
  extension vocabulary.
- **Plan-time deviation from the report, recorded**: the report's four-phase recommendation is
  split into six phases here, to keep each phase inside the 2-hour sizing bound and to isolate
  the one shared-territory touch (`FormalSystem/Semantics.lean`) in a phase of its own.
- **Plan-time naming deviation, recorded**: the probe's ray-witness names `seamGlue_isTotal` /
  `seamGlue_states_past` are renamed `convexGlue_rays_isTotal` /
  `convexGlue_rays_states_past`. `FormalSystem.Semantics.Presheaf.Ray.seamGlue_isTotal` already
  exists; the namespaces differ so there is no collision, but two same-named totality lemmas for
  two different gluings would be a reader trap. This is the same reasoning behind the report's
  Decision 4 avoidance of the base identifier `glue`.
- **Carried figure corrected at plan time**: the report says the `partialHistory_ext` relocation
  keeps "all four existing uses" resolving. Re-derived here by grep plus namespace inspection:
  **13 call sites across 5 files** (`Presheaf/Behavior.lean` 3, `Presheaf/Sheaf.lean` 4,
  `Presheaf/Directed.lean` 2, `Presheaf/Determinism.lean` 3,
  `Metalogic/Independence/BehSeparatedness.lean` 1), plus 2 prose mentions in
  `Semantics/README.md` and `Presheaf/README.md`. The report's **conclusion** is unaffected: the
  four Presheaf files all sit in `namespace FormalSystem.Semantics.Presheaf` (outer-namespace
  lookup) and `BehSeparatedness.lean` already carries `open FormalSystem.Semantics`, so the
  relocation is still call-site-neutral. Carried as Phase 1's Scope Hypothesis.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

`specs/ROADMAP.md` was consulted read-only. Its Stage 1 note records that `app:gluing` "is live
and proved in `possible_worlds.tex`, its seam case written as `ρ ⌢_z σ` but commented out" — that
is the seam case; this task is the general case, which the note does not yet cover. No
`roadmap_flag` was set in the delegation context, so no roadmap-review or roadmap-update phases
are added, and ROADMAP.md is not written to by any phase of this plan.

## Goals & Non-Goals

**Goals**:
- `isConvex_union`, `rel_mixed_left`, `rel_mixed_right`, `convexGlue`, `convexGlue_domain`,
  `convexGlue_mem_left`, `convexGlue_mem_right`, `convexGlue_states_left`,
  `convexGlue_states_not_left`, `convexGlue_states_right`, `convexGlue_isConvex`,
  `convexGlue_extends_left`, `convexGlue_extends_right`, `convexGlue_unique`, `gluing_clause`,
  `gluing_clause_of_overlap`, `pastRay_isConvex`, `futRay_isConvex`, `decPastRay`,
  `convexGlue_rays_isTotal`, `convexGlue_rays_states_past` — the identifier set pinned under
  `## Lean Challenge Statements` below, exactly, no more and no fewer
- Relocate the existing extensionality lemma from Semantics/Presheaf/Behavior.lean to
  Semantics/PartialHistory.lean, honouring the deferral its own docstring records. Its statement
  is unchanged, so it is deliberately **not** in the Challenge set above: a relocation commits to
  proving nothing new
- Pin choice-freeness mechanically: two matched heredoc rows in scripts/check-module-invariants.sh
  (C14) plus one `pinned:C14` row in docs/theorem-index.md, so the axiom set is asserted on every
  build rather than claimed in prose
- Docstrings citing app:gluing by name, recording the encoding hypothesis, the measured axiom
  table, the reflection-law trap, the left-bias of the construction, the independence decision
  for the three landed special cases, and the relation to the limit presentation of H_F
- Repoint the existing app:gluing citations that currently name only a special case at the
  general declaration

**Non-Goals**:
- Re-deriving `Presheaf.sheaf_clause`, `Ray.seamGlue`, or `PlusPasting.paste`/`pasteAt` from the
  general construction (report Decision 6 forbids it; their `dif_pos`/`dif_neg` reading lemmas
  are load-bearing)
- The directed-family case `Presheaf.directed_gluing_clause` — an independent statement requiring
  *Saturation*, not an instance of this one
- The limit presentation of H_F as a limit of behavior sections — a different statement, noted in
  the docstring and not folded in. Neither direction is a dependency
- Touching docs/reference/paper-definitions-of-record.md (Decision 8 removes the need) or
  promoting the app:gluing record row from LIVE-UNPINNED
- The paper-repository edit: clearing the `% PORT:` marker under app:gluing and closing the proof
  with `\leanproof`. A different repository; listed as a follow-up for the author
- The optional, strictly additive bridge equation `paste ρ σ z hsame = ⟨convexGlue …⟩` in
  PlusLanguage/PlusPasting.lean, in the shape of the existing `paste_eq_pasteAt` — deferred; it
  converts the Phase-3 witness into an equation and is not required by any deliverable

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Aggregator collision on `FormalSystem/Semantics.lean` with the concurrently dispatched sibling (task 756 declares it in `file_scope`) | M | M | Phase 4 isolates that one appended import line; re-read the file immediately before editing, stage that hunk alone with an explicit file list, never a directory or glob add. Documented fallback: append the module's content to `PartialHistory.lean` and touch no aggregator |
| `FrameOver.reflection` substituted for `TaskFrame.reflection_of_ne` during a later cleanup, silently reinstating `Classical.choice` | H if it happens | L | Implementation-Notes trap paragraph in Phase 2 **plus** the Phase 5 C14 gate, which fails the build the moment the measured axiom set changes |
| The two C14 heredocs drift out of alignment (they are compared by exact string equality) | M | L | Both edits land in one commit, appended at the same trailing position in each heredoc; `check-module-invariants.sh` fails loudly and prints the diff on mismatch |
| A reviewer reads `DecidablePred τ₁.domain` as a weakening of the paper's ZF-level statement | M | M | Docstring frames it as what Lean charges for defining a function by cases on a union, cites the Mathlib `piecewise` precedent, and records that every instance the paper and this tree use supplies it for free from the frame's `LinearOrder` (interval domains, ray domains, and translates of both) |
| C14's probe module is `import FormalSystem`, so a stale generated library root makes the new declarations unreachable and the baseline unmatchable | M | M | Phase 4 runs `lake exe mk_all --lib FormalSystem` and Phase 5 depends on Phase 4; a stale root is also independently reported by `scripts/typst-status-counts.sh` |
| `convexGlue_rays_isTotal` / `convexGlue_rays_states_past` have no in-tree consumer, so C17's dead-declaration census lists them | L | H | C17 is reporting-only and never gated (no `ENFORCE_C17` flag). The census keys on occurrences in markdown too, so the Phase 4 README row and the Phase 5 theorem-index row keep the keystone names out of the list; expect rows to inspect, not a failure |
| Lean build wall-clock exceeds the foreground tool cap, livelocking on a partially cached module | H | H | Every `lake` invocation routes through `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- …` detached via `Bash(run_in_background: true)`, with the guard's exit captured un-piped; never a bare foreground `lake build` |
| A build failure in a file outside this task's own scope is mistaken for this task's regression | M | M | Three sibling tasks are dispatched this same cycle on this same tree (756 with a declared scope that includes `FormalSystem/Semantics.lean`, 793 with none declared). Check `git log` and `git status` before attributing; report a foreign commit or modification rather than proceeding |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3, 4 | 2 |
| 4 | 5 | 3, 4 |
| 5 | 6 | 5 |

Phases within the same wave can execute in parallel.

**Build discipline for every phase**: route each `lake` invocation through
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build <Module>`, detached via
`Bash(run_in_background: true)`, reading the guard's own exit status un-piped (or its `result`
subcommand); never a bare foreground `lake build`. See
`context/project/lean4/operations/long-builds.md`.

**Generated-surface discipline for every phase**: any change to a `.lean` file's line count makes
the `<!-- BEGIN GENERATED: inventory -->` block covering its directory stale, and
`check-module-invariants.sh`'s INV check **FAILs** on a stale block — it is gated, not
advisory. The five blocks this plan can disturb live in `FormalSystem/README.md`
(`dir=FormalSystem`, loose rows, which carry `Semantics.lean` and the generated root
`../FormalSystem.lean`), `FormalSystem/Semantics/Presheaf/README.md`,
`FormalSystem/PlusLanguage/README.md`, `FormalSystem/OpenLanguage/README.md`, and
`FormalSystem/HybridLanguage/README.md`. Regenerate with
`bash scripts/check-module-invariants.sh --emit-inventory` — never hand-edit a generated block —
and confirm with `bash scripts/check-module-invariants.sh --emit-inventory --check`. There is
deliberately **no** generated block for `dir=FormalSystem/Semantics`: that README's Contents
table is hand-maintained, which is why Phase 4 writes the new `Gluing.lean` row by hand.

**Territory discipline for every phase**: three sibling tasks share this working tree this
cycle. Before editing any file, re-read it immediately beforehand; stage only this task's own
hunks with an explicit file list (`git add -- a.lean b.lean`), never `git add -A`/`.`/a directory
or glob pathspec; and never run `git-snapshot.sh` in its default reverting mode. The one
defensive checkpoint this plan calls for (before Phase 4's shared-file touch) uses
`bash .claude/scripts/git-snapshot.sh 789 --no-revert`.

---

### Phase 1: Relocate the partial-history extensionality lemma [COMPLETED]

**Goal**: Honour the deferral `Presheaf/Behavior.lean`'s own docstring records, so a module under
`Semantics/` can use partial-history extensionality without inverting the cluster order. This is
a prerequisite for Phase 2's uniqueness proof, not an optional tidy-up.

**Tasks**:
- [x] Move `partialHistory_ext` out of `FormalSystem/Semantics/Presheaf/Behavior.lean` (currently
      at `namespace FormalSystem.Semantics.Presheaf`, declared before `namespace Beh`) into
      `FormalSystem/Semantics/PartialHistory.lean`, under `namespace FormalSystem.Semantics`
      directly — **not** inside `namespace PartialHistory`, since the name is `partialHistory_ext`
      — placed after the `PartialHistory` structure declaration and before the first
      `namespace PartialHistory` block
- [x] Keep the statement, the docstring's "written by hand because the `states` field is dependent
      on `domain`, so no `@[ext]` lemma is generated" sentence, and the proof body **verbatim**;
      this is a relocation, not a restatement
- [x] Replace `Behavior.lean`'s "**`partialHistory_ext` lives here, and that is a deliberate
      deferral**" Implementation-Note paragraph with a pointer to the new home, and drop its
      `partialHistory_ext` bullet from the module docstring's contents list (or repoint it)
- [x] Update `FormalSystem/Semantics/Presheaf/README.md`'s `partialHistory_ext` bullet and
      `FormalSystem/Semantics/README.md`'s `Presheaf/` row sentence that records the deferral;
      add the lemma to the `PartialHistory.lean` row. Refresh each touched README's
      "Last verified" date *(deviation: altered — four further files carried stale
      `Behavior.lean`-attributing pointers to the lemma that the relocation itself invalidated:
      `Presheaf/Sheaf.lean`, `Presheaf/Directed.lean` (a References line plus the sentence citing
      the deferral as precedent), `Presheaf/Determinism.lean` and `Presheaf/Ray.lean`. Each
      References line was repointed at `PartialHistory.lean`; no statement, proof or signature
      was touched. Leaving them would have left four wrong location claims in the tree.)*
- [x] Edit **no call site**. If any of the 13 call sites needs an added `open`, stop and re-read
      rather than adding one — that is the signal the lemma landed in the wrong namespace
- [x] Regenerate the generated inventory block that this phase's line-count changes make stale:
      `bash scripts/check-module-invariants.sh --emit-inventory`, then confirm with
      `--emit-inventory --check`. `Behavior.lean` shrinks and `PartialHistory.lean` grows, so
      `FormalSystem/Semantics/Presheaf/README.md`'s block is affected; `PartialHistory.lean` sits
      in `FormalSystem/Semantics/`, which carries no generated block

**Timing**: 1 hour

**Depends on**: none

**Verification Tier**: interface

**Commit Mode**: per-substep

**Scope Hypothesis**: the hypothesis is that `partialHistory_ext` has **13 call sites across 5
files** — `Presheaf/Behavior.lean` (3), `Presheaf/Sheaf.lean` (4), `Presheaf/Directed.lean` (2),
`Presheaf/Determinism.lean` (3), `Metalogic/Independence/BehSeparatedness.lean` (1) — all of
which resolve the name through `FormalSystem.Semantics` and therefore need no edit. This figure
is re-derived at plan time and **corrects** the research report's "all four existing uses", which
undercounted. Confirm at implementation time with
`grep -rn 'partialHistory_ext' FormalSystem/ Tests/` before the move and again after, and by the
scoped builds below succeeding with zero call-site edits.

**Tier Justification**: `interface` because this renames the lemma's namespace with call sites
spanning five files; the specific covering check is the guarded scoped build of
`FormalSystem.Semantics.PartialHistory` plus its enumerated direct dependents
`FormalSystem.Semantics.Presheaf` and
`FormalSystem.Metalogic.Independence.BehSeparatedness`, which together contain all 13 sites.

**Files to modify**:
- `FormalSystem/Semantics/PartialHistory.lean` - receives `partialHistory_ext` verbatim under `namespace FormalSystem.Semantics`
- `FormalSystem/Semantics/Presheaf/Behavior.lean` - lemma removed; deferral note becomes a pointer; docstring contents bullet repointed
- `FormalSystem/Semantics/Presheaf/README.md` - `partialHistory_ext` bullet repointed; Last verified date refreshed; generated inventory block regenerated
- `FormalSystem/Semantics/README.md` - `Presheaf/` row deferral sentence removed; `PartialHistory.lean` row gains the lemma; Last verified date refreshed

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Semantics.PartialHistory` exits 0
- Same guarded, detached form for `FormalSystem.Semantics.Presheaf` and
  `FormalSystem.Metalogic.Independence.BehSeparatedness`, both exit 0
- `grep -rn 'partialHistory_ext' FormalSystem/ Tests/` shows the declaration at its new location
  and no remaining declaration in `Behavior.lean`; the call-site count is unchanged at 13
- `git diff` on the four files shows no change to any call-site line
- `bash scripts/readme-lint.sh` exits 0
- `bash scripts/check-module-invariants.sh --emit-inventory --check` exits 0 (no generated
  inventory block left stale)

---

### Phase 2: The general gluing module [COMPLETED]

**Goal**: Land `FormalSystem/Semantics/Gluing.lean` — the construction, both reading equations,
convexity of the union, both restriction identities, uniqueness, and both `∃!` entry points — as
a transcription of the verified probe, with the full module docstring.

**Tasks**:
- [x] Create `FormalSystem/Semantics/Gluing.lean` with the project copyright header (checked by
      `scripts/check-copyright-headers.sh`), the module docstring immediately after the imports,
      and `import FormalSystem.Semantics.PartialHistory` as its **only** import — the narrow
      import closure is itself evidence for the choice-free claim and must not be widened
- [x] Open `namespace FormalSystem.Semantics.PartialHistory`
- [x] Transcribe probe Step 1 as `isConvex_union` (both convexities and the overlap point `z`; no
      frame constraint, no decidability)
- [x] Transcribe probe Step 2 as `rel_mixed_left` and `rel_mixed_right`, routing the `x ≤ z ≤ y`
      sub-case through `PartialHistory.rel_across_seam` with
      `by rw [add_comm]; exact (sub_add_sub_cancel y z x).symm` as the duration obligation
- [x] Transcribe probe Step 3 as `convexGlue`, with `[DecidablePred τ₁.domain]`,
      `domain := fun t => τ₁.domain t ∨ τ₂.domain t`, and the four-way `respects_task` split; the
      two backwards-orientation branches use `TaskFrame.reflection_of_ne F hne` plus `neg_sub`,
      with `hne : t - s ≠ 0` obtained from the domain-membership asymmetry by
      `sub_ne_zero_of_ne`
- [x] Transcribe the reading and bridge lemmas: `convexGlue_domain` (`Iff.rfl`),
      `convexGlue_mem_left`/`convexGlue_mem_right` (`Or.inl`/`Or.inr`),
      `convexGlue_states_left` (`dif_pos`), `convexGlue_states_not_left` (`dif_neg`), and
      `convexGlue_states_right` — the one where `hagree` is consumed
- [x] Transcribe `convexGlue_isConvex`, `convexGlue_extends_left`, `convexGlue_extends_right`,
      and `convexGlue_unique` (which takes no frame constraint, no convexity and no overlap, and
      routes through the Phase-1 `partialHistory_ext`)
- [x] Transcribe both entry points: `gluing_clause` (overlap point explicit, with the
      `include … in` binder directive) and `gluing_clause_of_overlap` (the paper's own hypothesis
      `∃ z, τ₁.domain z ∧ τ₂.domain z`, discharged by ordinary `Exists.elim`, which is why the
      existential form stays choice-free)
- [x] Build `Extends` instances by supplying the `agree` component as a **named lemma fed as a
      field**, never by `refine ⟨…, fun t ht => ?_⟩` then `rw [dif_…]`: the `dite` is not visible
      through `.states` at implicit transparency and that shape fails
- [x] Write the module docstring: `app:gluing` cited **by name, never block-quoted** (Decision 8);
      `def:world-history` available for verbatim quotation of the convexity/extension vocabulary;
      the paper's four-step proof transcribed as a step map; the `DecidablePred` record with the
      Mathlib `Set.piecewise`/`PartialEquiv.piecewise` precedent and the three rejected escapes;
      the measured-axiom table; the `TaskFrame.reflection_of_ne` trap; the note that the
      construction is left-biased on `τ₁` so "relabelling if necessary" is a `Prop`-level
      `le_total` split and not a symmetry argument at the construction level; the independence
      decision for the three landed special cases with its `dif_pos`/`dif_neg` reason; and the
      remark that a compatible family of sections in the limit presentation of `H_F` is a gluing,
      of which this is the two-member case — conceptual, a dependency in neither direction
- [x] Close the file with
      `assert_not_exists FormalSystem.ProofSystem.Axiom FormalSystem.ProofSystem.DerivationTree`,
      as every `Presheaf/` module does, pinning the module below `Truth.lean`
- [x] Use `theorem`, never `lemma` (C23 gates zero live `lemma` declarations)
- [x] Cite no task numbers anywhere in the file (C9 gates zero task-number citations under
      `FormalSystem/`)

**Timing**: 1.5 hours

**Depends on**: 1

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: the hypothesis is that this phase adds exactly one file and that the probe
transcribes without a single new proof obligation — the probe's final run is recorded as exit 0,
warning-free, `sorry`-free. Confirm at implementation time by the scoped build below exiting 0
on the first attempt after transcription, and by `#print axioms` on each declaration reproducing
the table carried from the research report (`[propext]` for `isConvex_union`,
`[propext, Quot.sound]` for everything else); a divergence from that table means the
transcription changed a proof, not merely its names.

**Tier Justification**: `local` because the edit is confined to one new file that nothing yet
imports (Phase 4 does the wiring), so the specific covering check is the guarded scoped build
`lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Semantics.Gluing` plus
`#print axioms` on each new declaration.

**Files to modify**:
- `FormalSystem/Semantics/Gluing.lean` - new module: the general gluing construction, its readings, convexity, both restriction identities, uniqueness, both `∃!` entry points, and the full docstring

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Semantics.Gluing` exits 0
- `mcp__lean-lsp__lean_verify` on `FormalSystem.Semantics.PartialHistory.gluing_clause` and
  `...gluing_clause_of_overlap` reports no `sorryAx`
- `#print axioms` on all eleven new declarations reproduces the research report's measured table;
  `Classical.choice` appears nowhere
- `grep -n 'FrameOver.reflection\|Classical\|sorry\|lemma ' FormalSystem/Semantics/Gluing.lean`
  returns nothing outside prose
- No vacuous definition (`def X := True`/`:= Unit`/`:= trivial` and the theorem/instance variants
  are prohibited and are equivalent to `sorry`)

---

### Phase 3: The seam cases exhibited as instances [COMPLETED]

**Goal**: Discharge the task's "shown to be instances or left independent, by an explicit
decision" obligation by **witness** rather than by re-derivation: exhibit the paper's `ρ ⌢_z σ`
as the general gluing at two ray domains, total and reading as `ρ` below the seam.

**Tasks**:
- [x] Append a `RayInstance` section to `FormalSystem/Semantics/Gluing.lean` transcribing probe
      Step 6 *(deviation: altered — the section was written in the same pass as Phase 2's file
      rather than appended afterwards, so both phases close on one commit. Both touch only
      `Gluing.lean` and no external surface differs; splitting the write would have left Phase 2's
      commit with a docstring pointing at an absent section.)*
- [x] `pastRay_isConvex` and `futRay_isConvex`: convexity of `PartialHistory.restrict ρ (· ≤ z)`
      and `PartialHistory.restrict σ (z ≤ ·)`, each a one-line `le_trans`
- [x] `decPastRay`: declare the `DecidablePred` instance **at the call site**, as
      `fun t => inferInstanceAs (Decidable (t ≤ z))`. This declaration is required, not
      cosmetic: `(PartialHistory.restrict ρ P hP).domain` does not reduce to `P` at
      instance-reducible transparency, so the instance is not found without it
- [x] `convexGlue_rays_isTotal`: the glued object is total, by `fun t => le_total t z` — renamed
      from the probe's `seamGlue_isTotal` to avoid shadowing
      `FormalSystem.Semantics.Presheaf.Ray.seamGlue_isTotal` in a reader's mind (different
      namespace, so no collision, but the same name for a different gluing is a trap)
- [x] `convexGlue_rays_states_past`: the glued object reads as `ρ` at every `t ≤ z`, by
      `convexGlue_states_left`
- [x] Record in the docstring that these two witnesses are what makes "the seam cases **are**
      instances of `app:gluing`" a verified pointer rather than a bare claim, and that the
      optional equation `paste ρ σ z hsame = ⟨convexGlue …⟩` (shape of the existing
      `paste_eq_pasteAt`) is a deferred, strictly additive follow-up that must not touch
      `Sheaf.lean` or `Ray.lean`

**Timing**: 0.75 hours

**Depends on**: 2

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: the hypothesis is that this phase touches exactly one file
(`Gluing.lean`) and adds exactly five declarations, with no edit to `Presheaf/Ray.lean`,
`Presheaf/Sheaf.lean`, or `PlusLanguage/PlusPasting.lean`. Confirm at implementation time by
`git status --short` naming only `FormalSystem/Semantics/Gluing.lean`.

**Tier Justification**: `local` because the edit stays inside the single file Phase 2 created and
changes no externally visible signature, so the specific covering check is the guarded scoped
build `lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Semantics.Gluing`.

**Files to modify**:
- `FormalSystem/Semantics/Gluing.lean` - appended `RayInstance` section: the two ray convexities, the `DecidablePred` instance, and the two witness lemmas

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Semantics.Gluing` exits 0
- `#print axioms` on `convexGlue_rays_isTotal` and `convexGlue_rays_states_past` reports
  `[propext, Quot.sound]`
- `git status --short` lists only `FormalSystem/Semantics/Gluing.lean` among this task's files

---

### Phase 4: Wire the module into the library [NOT STARTED]

**Goal**: Make the module part of the build graph and of the documentation surface, with the one
shared-territory touch isolated here.

**Tasks**:
- [ ] Take an ordinary defensive checkpoint first:
      `bash .claude/scripts/git-snapshot.sh 789 --no-revert` (never the default reverting form)
- [ ] **Re-read `FormalSystem/Semantics.lean` immediately before editing** — it is inside the
      concurrently dispatched sibling task's declared `file_scope` — then append the single line
      `import FormalSystem.Semantics.Gluing` in layering position, directly after
      `import FormalSystem.Semantics.PartialHistoryOrder`
- [ ] Add the matching entry to that file's `## Submodules` docstring list, in the same position,
      describing the module in the style of its neighbours and citing `app:gluing` by name
- [ ] Stage that file alone with an explicit file list and commit it as its own sub-step, so the
      shared touch is one reviewable hunk
- [ ] Add a `Gluing.lean` row to `FormalSystem/Semantics/README.md`'s Contents table, in layering
      position after the `PartialHistoryOrder.lean` row, naming `convexGlue`, `gluing_clause`,
      `gluing_clause_of_overlap`, the `DecidablePred` encoding hypothesis, the measured axiom
      profile, and the independence decision for the three landed cases. Refresh the
      "Last verified" date
- [ ] Run `lake exe mk_all --lib FormalSystem` to regenerate the library root
      `FormalSystem.lean` (one sorted import line per file under `FormalSystem/`); commit the
      regenerated root, never hand-edit it
- [ ] Regenerate the generated inventory blocks the line-count changes make stale:
      `bash scripts/check-module-invariants.sh --emit-inventory`, then confirm with
      `--emit-inventory --check`. `FormalSystem/README.md`'s `dir=FormalSystem` loose block
      carries line counts for both `Semantics.lean` and `../FormalSystem.lean`, and this phase
      changes both
- [ ] If the aggregator line cannot be landed cleanly because the sibling is mid-edit, fall back
      per the recorded contingency: move the module's content into
      `FormalSystem/Semantics/PartialHistory.lean` and touch no aggregator. Record the fallback
      in the task issue log

**Timing**: 1 hour

**Depends on**: 2

**Verification Tier**: interface

**Commit Mode**: per-substep

**Scope Hypothesis**: the hypothesis is that wiring costs exactly one appended import line in
`FormalSystem/Semantics.lean`, one docstring list entry in the same file, one hand-written README
row, one regenerated line in the generated root, and two regenerated line-count cells in
`FormalSystem/README.md`'s `dir=FormalSystem` block — five files, no call-site changes anywhere.
Confirm at implementation time with `git diff --stat` on the five paths and by `git diff` on
`FormalSystem.lean` showing a single added import line.

**Tier Justification**: `interface` because adding the module to an aggregator changes what every
downstream module's import closure contains, so the specific covering check is the guarded scoped
build of `FormalSystem.Semantics` plus its enumerated direct dependents `FormalSystem.Metalogic`
and `FormalSystem.PlusLanguage`.

**Files to modify**:
- `FormalSystem/Semantics.lean` - one appended import line plus one `## Submodules` docstring entry (SHARED TOUCH: re-read immediately before editing, stage this hunk alone)
- `FormalSystem/Semantics/README.md` - new `Gluing.lean` Contents row, hand-written (this directory carries no generated block); Last verified date refreshed
- `FormalSystem.lean` - regenerated by `lake exe mk_all --lib FormalSystem`, never hand-edited
- `FormalSystem/README.md` - `dir=FormalSystem` generated inventory block regenerated, never hand-edited

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Semantics`
  exits 0; same guarded, detached form for `FormalSystem.Metalogic` and
  `FormalSystem.PlusLanguage`, both exit 0
- `bash scripts/check-module-invariants.sh --no-build` exits 0 on C4 (every import resolves), C8
  (aggregator convention: sibling `X.lean` beside `X/`, no `X/X.lean`), C5, and INV (no stale
  generated inventory block)
- `bash scripts/check-module-invariants.sh --emit-inventory --check` exits 0
- `lake exe mk_all --lib FormalSystem --check` reports no drift in the generated root
- `bash scripts/readme-lint.sh` exits 0
- `bash scripts/check-copyright-headers.sh --strict FormalSystem` exits 0
- `git log --oneline -3` and `git diff --stat` confirm the staged hunks are this task's only; no
  foreign modification to `FormalSystem/Semantics.lean` was overwritten

---

### Phase 5: Gate the choice-free claim [NOT STARTED]

**Goal**: Turn deliverable (2) — `rmk:choice` lists `app:gluing` among the choice-free results,
so pin it — into a machine assertion that fails the build if the axiom set ever changes, rather
than a docstring table a reader must trust.

**Tasks**:
- [ ] Append one baseline line per pinned declaration at the **trailing position** of the
      `C14_BASELINE` heredoc in `scripts/check-module-invariants.sh` (the block terminated by
      `C14BASE`), in the exact form
      `'FormalSystem.Semantics.PartialHistory.convexGlue' depends on axioms: [propext, Quot.sound]`
      and the same for `...gluing_clause`
- [ ] Append the matching `#print axioms FormalSystem.Semantics.PartialHistory.convexGlue` and
      `#print axioms FormalSystem.Semantics.PartialHistory.gluing_clause` lines at the **same
      trailing position** of the `C14LEAN` heredoc in the same script. The two heredocs are
      compared by exact string equality and must stay positionally aligned — this alignment is
      the only real hazard in the phase and it is mechanical
- [ ] Add the explanatory comment pair above the heredocs, following the shape the existing
      matched-pair blocks already use, recording what these two rows pin and why
- [ ] Add one `docs/theorem-index.md` row: anchor `app:gluing`, a one-line statement, Lean name
      **fully qualified** (`FormalSystem.Semantics.PartialHistory.gluing_clause`), file
      `FormalSystem/Semantics/Gluing.lean`, frame class `—` (class-generic), axioms
      `` `[propext, Quot.sound]` pinned:C14 ``
- [ ] Both edits land in **one commit**, so the heredocs cannot be committed out of alignment

**Timing**: 1.25 hours

**Depends on**: 3, 4

**Verification Tier**: local

**Commit Mode**: atomic-batch

**Scope Hypothesis**: the hypothesis is that exactly two declarations are pinned
(`convexGlue`, `gluing_clause`), that each costs one line in each of the two heredocs, and that
`#print axioms` reports `[propext, Quot.sound]` for both — the value carried from the research
report's measured table. Confirm at implementation time by the C14 run below passing on the
first attempt; a mismatch prints the expected-versus-actual diff, and the actual value is then
the figure to record, never the carried one. If `#print axioms` emits no
`depends on axioms` line for a declaration at all, that declaration cannot be pinned by this
mechanism and its row must be omitted rather than invented.

**Tier Justification**: `local` because the edit is confined to one gate script plus one
documentation table with no compile surface; the specific covering check is
`bash scripts/check-module-invariants.sh` (the full, build-enabled run, since C14 part (ii) is
gated on `RUN_BUILD`), whose C14 and C15 assertions are exactly what these edits change.

**Files to modify**:
- `scripts/check-module-invariants.sh` - two matched pairs appended at the trailing position of the `C14_BASELINE` and `C14LEAN` heredocs, plus the explanatory comment pair
- `docs/theorem-index.md` - one new `app:gluing` row carrying `pinned:C14`

**Verification**:
- `bash scripts/check-module-invariants.sh` exits 0, with C14 reporting PASS and its notes listing
  both new declarations at the measured axiom values
- The same run's C15 passes both of its assertions: every cited paper anchor resolves against the
  record (`app:gluing` has a KNOWN-ANCHORS row, so no edit to
  `docs/reference/paper-definitions-of-record.md` is needed) and every
  `docs/theorem-index.md` row carries its anchor at the declaration itself
- The exit status of the invariants script is checked directly, not inferred from a diff of its
  stdout against a baseline

---

### Phase 6: Citation surface and full gate set [NOT STARTED]

**Goal**: Point the existing `app:gluing` citations at the general declaration where they
currently name only a special case, and close the task against the complete repository gate set.

**Tasks**:
- [ ] Re-derive the citation list before editing with
      `grep -rn 'app:gluing' FormalSystem/` — the expected set is
      `Semantics/Presheaf/Sheaf.lean`, `Semantics/Presheaf/Ray.lean`,
      `Semantics/Presheaf/Directed.lean`, `Semantics/Presheaf/README.md`,
      `PlusLanguage/PlusRayFibre.lean`, `OpenLanguage/OpenClasses.lean`,
      `OpenLanguage/README.md`, `HybridLanguage/HybridTransposition.lean`,
      `HybridLanguage/README.md`, `HybridLanguage.lean`
- [ ] In each, extend the existing `app:gluing` References line (or the sentence that calls the
      local result "the two-history instance of `app:gluing`") to name
      `FormalSystem/Semantics/Gluing.lean`'s general declaration as the general case this one is
      an instance of. **Docstring and README prose only — no statement, no proof, no signature
      changes anywhere**
- [ ] Keep every citation by name; add no block quotation of `app:gluing`'s text (Decision 8)
- [ ] Refresh the "Last verified" date on each touched README
- [ ] Regenerate the generated inventory blocks: `bash scripts/check-module-invariants.sh
      --emit-inventory`, then confirm with `--emit-inventory --check`. This phase changes line
      counts in five covered directories — `FormalSystem/` (loose: `HybridLanguage.lean`),
      `FormalSystem/Semantics/Presheaf/`, `FormalSystem/PlusLanguage/`,
      `FormalSystem/OpenLanguage/`, `FormalSystem/HybridLanguage/` — so all five blocks go stale
- [ ] Run `bash scripts/typst-sync-check.sh` and check its exit status. **No edit in this plan is
      expected to move any count `typst/generated/status.typ` carries** (it counts axiom
      constructors in `ProofSystem/Axioms.lean`, rule constructors in `ProofSystem/Derivation.lean`,
      and `sorry` occurrences under `Metalogic/**`, none of which this task touches). If the sync
      check nevertheless reports drift, regenerate with `bash scripts/typst-status-counts.sh`
      against a built library rather than hand-editing the generated file, and record the
      surprise in the task issue log
- [ ] Run the complete gate set and record each exit status
- [ ] Record the paper-side follow-up for the author in the implementation summary: clear the
      `% PORT:` comment under `app:gluing` in `possible_worlds.tex` and close the proof with
      `\leanproof` naming `FormalSystem.Semantics.PartialHistory.gluing_clause`. That is an edit
      in a different repository and is deliberately not performed here

**Timing**: 1.5 hours

**Depends on**: 5

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: the hypothesis is **10 citation sites** across 7 Lean modules and 3
READMEs, carried from the research report's Phase-4 list and re-derived at plan time by
`grep -rn 'app:gluing' FormalSystem/`. Confirm at implementation time by re-running that grep
immediately before editing: a site the grep finds that is not on this list is in scope, and a
listed site the grep no longer finds is a reasoned exclusion to record, not a silent drop. The
eleventh file below, `FormalSystem/README.md`, is not a citation site — it carries a generated
inventory block this phase's line-count changes make stale, and is regenerated, not edited.

**Files to modify**:
- `FormalSystem/Semantics/Presheaf/Sheaf.lean` - References line repointed at the general declaration
- `FormalSystem/Semantics/Presheaf/Ray.lean` - References line repointed
- `FormalSystem/Semantics/Presheaf/Directed.lean` - References line repointed; the independence of the directed case stated explicitly
- `FormalSystem/Semantics/Presheaf/README.md` - `app:gluing` prose repointed; Last verified date refreshed
- `FormalSystem/PlusLanguage/PlusRayFibre.lean` - References line repointed
- `FormalSystem/OpenLanguage/OpenClasses.lean` - "two-history instance" prose and References line repointed
- `FormalSystem/OpenLanguage/README.md` - `app:gluing` row and References list repointed; Last verified date refreshed
- `FormalSystem/HybridLanguage/HybridTransposition.lean` - References line and pasting-step prose repointed
- `FormalSystem/HybridLanguage/README.md` - `app:gluing` row and References list repointed; Last verified date refreshed
- `FormalSystem/HybridLanguage.lean` - aggregator References line repointed
- `FormalSystem/README.md` - `dir=FormalSystem` generated inventory block regenerated, never hand-edited

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build` (full project,
  unscoped) exits 0, detached, with the guard's exit captured un-piped
- `bash scripts/check-module-invariants.sh` exits 0 — C1, C3 (zero structural `sorry`, asserted
  by content), C4, C5, C8, C9, C14, C15, C16 (no linter finding beyond
  `scripts/nolints.json`), C19 (docstring-coverage floor), C23 (zero live `lemma`), and INV
  (every generated inventory block current)
- `bash scripts/typst-sync-check.sh` exits 0
- `bash scripts/readme-lint.sh` exits 0
- `bash scripts/check-copyright-headers.sh --strict FormalSystem` exits 0
- `bash .claude/scripts/verify-deploy.sh` — the complete repository gate set this tier requires —
  exits 0
- Every command's exit status is checked directly; a diff of captured stdout against a baseline
  is not accepted as evidence for any of them
- `git log --oneline` shows one commit per phase and no foreign commit interleaved into this
  task's range

## Lean Challenge Statements

```lean
import FormalSystem.Semantics.PartialHistory

namespace FormalSystem.Semantics.PartialHistory

variable {F : TaskFrame}

/-- Step 2 of the paper's proof: the union of two convex domains sharing a point is convex. -/
theorem isConvex_union {τ₁ τ₂ : PartialHistory F} (h₁ : τ₁.IsConvex) (h₂ : τ₂.IsConvex)
    {z : F.Duration} (hz₁ : τ₁.domain z) (hz₂ : τ₂.domain z) :
    ∀ a c : F.Duration, (τ₁.domain a ∨ τ₂.domain a) → (τ₁.domain c ∨ τ₂.domain c) →
      ∀ b : F.Duration, a ≤ b → b ≤ c → (τ₁.domain b ∨ τ₂.domain b) := sorry

/-- Step 3's mixed pair, left-to-right: `x` in the first domain, `y` only in the second. -/
theorem rel_mixed_left {τ₁ τ₂ : PartialHistory F} (hcomp : TaskFrame.Compositional F.TaskRel)
    (h₁ : τ₁.IsConvex) (h₂ : τ₂.IsConvex)
    {z : F.Duration} (hz₁ : τ₁.domain z) (hz₂ : τ₂.domain z)
    (hagree : ∀ (t : F.Duration) (p : τ₁.domain t) (q : τ₂.domain t),
      τ₁.states t p = τ₂.states t q)
    {x y : F.Duration} (hx₁ : τ₁.domain x) (hy₂ : τ₂.domain y) (hy₁ : ¬ τ₁.domain y)
    (hxy : x ≤ y) :
    F.TaskRel (τ₁.states x hx₁) (y - x) (τ₂.states y hy₂) := sorry

/-- The mirror of `rel_mixed_left`. -/
theorem rel_mixed_right {τ₁ τ₂ : PartialHistory F} (hcomp : TaskFrame.Compositional F.TaskRel)
    (h₁ : τ₁.IsConvex) (h₂ : τ₂.IsConvex)
    {z : F.Duration} (hz₁ : τ₁.domain z) (hz₂ : τ₂.domain z)
    (hagree : ∀ (t : F.Duration) (p : τ₁.domain t) (q : τ₂.domain t),
      τ₁.states t p = τ₂.states t q)
    {x y : F.Duration} (hx₂ : τ₂.domain x) (hy₁ : τ₁.domain y) (hx₁ : ¬ τ₁.domain x)
    (hxy : x ≤ y) :
    F.TaskRel (τ₂.states x hx₂) (y - x) (τ₁.states y hy₁) := sorry

/-- The glued convex history `τ₁ ∪ τ₂`, left-biased on `τ₁`. -/
def convexGlue (hcomp : TaskFrame.Compositional F.TaskRel) (τ₁ τ₂ : PartialHistory F)
    [DecidablePred τ₁.domain] (h₁ : τ₁.IsConvex) (h₂ : τ₂.IsConvex)
    {z : F.Duration} (hz₁ : τ₁.domain z) (hz₂ : τ₂.domain z)
    (hagree : ∀ (t : F.Duration) (p : τ₁.domain t) (q : τ₂.domain t),
      τ₁.states t p = τ₂.states t q) :
    PartialHistory F := sorry

section Readings

variable {τ₁ τ₂ : PartialHistory F} (hcomp : TaskFrame.Compositional F.TaskRel)
  [DecidablePred τ₁.domain] (h₁ : τ₁.IsConvex) (h₂ : τ₂.IsConvex) {z : F.Duration}
  (hz₁ : τ₁.domain z) (hz₂ : τ₂.domain z)
  (hagree : ∀ (t : F.Duration) (p : τ₁.domain t) (q : τ₂.domain t),
    τ₁.states t p = τ₂.states t q)

theorem convexGlue_domain (t : F.Duration) :
    (convexGlue hcomp τ₁ τ₂ h₁ h₂ hz₁ hz₂ hagree).domain t ↔ (τ₁.domain t ∨ τ₂.domain t) := sorry

theorem convexGlue_mem_left {t : F.Duration} (h : τ₁.domain t) :
    (convexGlue hcomp τ₁ τ₂ h₁ h₂ hz₁ hz₂ hagree).domain t := sorry

theorem convexGlue_mem_right {t : F.Duration} (h : τ₂.domain t) :
    (convexGlue hcomp τ₁ τ₂ h₁ h₂ hz₁ hz₂ hagree).domain t := sorry

theorem convexGlue_states_left {t : F.Duration}
    {ht : (convexGlue hcomp τ₁ τ₂ h₁ h₂ hz₁ hz₂ hagree).domain t} (h : τ₁.domain t) :
    (convexGlue hcomp τ₁ τ₂ h₁ h₂ hz₁ hz₂ hagree).states t ht = τ₁.states t h := sorry

theorem convexGlue_states_not_left {t : F.Duration}
    {ht : (convexGlue hcomp τ₁ τ₂ h₁ h₂ hz₁ hz₂ hagree).domain t} (h : ¬ τ₁.domain t)
    (h' : τ₂.domain t) :
    (convexGlue hcomp τ₁ τ₂ h₁ h₂ hz₁ hz₂ hagree).states t ht = τ₂.states t h' := sorry

/-- The right-hand reading, where the seam hypothesis `hagree` is consumed. -/
theorem convexGlue_states_right {t : F.Duration}
    (ht : (convexGlue hcomp τ₁ τ₂ h₁ h₂ hz₁ hz₂ hagree).domain t) (h' : τ₂.domain t) :
    (convexGlue hcomp τ₁ τ₂ h₁ h₂ hz₁ hz₂ hagree).states t ht = τ₂.states t h' := sorry

theorem convexGlue_isConvex : (convexGlue hcomp τ₁ τ₂ h₁ h₂ hz₁ hz₂ hagree).IsConvex := sorry

theorem convexGlue_extends_left : (convexGlue hcomp τ₁ τ₂ h₁ h₂ hz₁ hz₂ hagree).Extends τ₁ :=
  sorry

theorem convexGlue_extends_right : (convexGlue hcomp τ₁ τ₂ h₁ h₂ hz₁ hz₂ hagree).Extends τ₂ :=
  sorry

/-- Uniqueness: no frame constraint, no convexity, no overlap. -/
theorem convexGlue_unique (υ : PartialHistory F)
    (hdom : ∀ t, υ.domain t ↔ (τ₁.domain t ∨ τ₂.domain t))
    (he₁ : υ.Extends τ₁) (he₂ : υ.Extends τ₂) :
    υ = convexGlue hcomp τ₁ τ₂ h₁ h₂ hz₁ hz₂ hagree := sorry

include hcomp h₁ h₂ hz₁ hz₂ hagree in
/-- `app:gluing` with the overlap point explicit. -/
theorem gluing_clause :
    ∃! υ : PartialHistory F,
      (∀ t, υ.domain t ↔ (τ₁.domain t ∨ τ₂.domain t)) ∧ υ.IsConvex ∧
        υ.Extends τ₁ ∧ υ.Extends τ₂ := sorry

end Readings

/-- `app:gluing` under the paper's own hypothesis `X₁ ∩ X₂ ≠ ∅`. -/
theorem gluing_clause_of_overlap {τ₁ τ₂ : PartialHistory F}
    (hcomp : TaskFrame.Compositional F.TaskRel) [DecidablePred τ₁.domain]
    (h₁ : τ₁.IsConvex) (h₂ : τ₂.IsConvex)
    (hov : ∃ z : F.Duration, τ₁.domain z ∧ τ₂.domain z)
    (hagree : ∀ (t : F.Duration) (p : τ₁.domain t) (q : τ₂.domain t),
      τ₁.states t p = τ₂.states t q) :
    ∃! υ : PartialHistory F,
      (∀ t, υ.domain t ↔ (τ₁.domain t ∨ τ₂.domain t)) ∧ υ.IsConvex ∧
        υ.Extends τ₁ ∧ υ.Extends τ₂ := sorry

section RayInstance

variable (ρ σ : WorldHistory F) (z : F.Duration)

theorem pastRay_isConvex : (PartialHistory.restrict ρ (fun t => t ≤ z) ⟨z, le_rfl⟩).IsConvex :=
  sorry

theorem futRay_isConvex : (PartialHistory.restrict σ (fun t => z ≤ t) ⟨z, le_rfl⟩).IsConvex :=
  sorry

instance decPastRay :
    DecidablePred (PartialHistory.restrict ρ (fun t => t ≤ z) ⟨z, le_rfl⟩).domain := sorry

/-- The paper's `ρ ⌢_z σ` is the general gluing at two ray domains, and it is total. -/
theorem convexGlue_rays_isTotal (hcomp : TaskFrame.Compositional F.TaskRel)
    (hsame : ρ.state z = σ.state z) :
    (convexGlue hcomp (PartialHistory.restrict ρ (fun t => t ≤ z) ⟨z, le_rfl⟩)
        (PartialHistory.restrict σ (fun t => z ≤ t) ⟨z, le_rfl⟩)
        (pastRay_isConvex ρ z) (futRay_isConvex σ z) le_rfl le_rfl
        (fun t p q => by obtain rfl := le_antisymm p q; exact hsame)).IsTotal := sorry

/-- Below the seam the ray gluing reads as `ρ`. -/
theorem convexGlue_rays_states_past (hcomp : TaskFrame.Compositional F.TaskRel)
    (hsame : ρ.state z = σ.state z) (t : F.Duration) (ht : t ≤ z)
    (hmem : (convexGlue hcomp (PartialHistory.restrict ρ (fun t => t ≤ z) ⟨z, le_rfl⟩)
        (PartialHistory.restrict σ (fun t => z ≤ t) ⟨z, le_rfl⟩)
        (pastRay_isConvex ρ z) (futRay_isConvex σ z) le_rfl le_rfl
        (fun t p q => by obtain rfl := le_antisymm p q; exact hsame)).domain t) :
    (convexGlue hcomp (PartialHistory.restrict ρ (fun t => t ≤ z) ⟨z, le_rfl⟩)
        (PartialHistory.restrict σ (fun t => z ≤ t) ⟨z, le_rfl⟩)
        (pastRay_isConvex ρ z) (futRay_isConvex σ z) le_rfl le_rfl
        (fun t p q => by obtain rfl := le_antisymm p q; exact hsame)).states t hmem
      = ρ.state t := sorry

end RayInstance

end FormalSystem.Semantics.PartialHistory
```

## Testing & Validation

- [ ] `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build` (full project)
      exits 0, with no new `sorry` and no new linter warning
- [ ] `mcp__lean-lsp__lean_verify` reports no `sorryAx` for
      `FormalSystem.Semantics.PartialHistory.gluing_clause`,
      `...gluing_clause_of_overlap`, `...convexGlue`, and `...convexGlue_unique`
- [ ] `#print axioms` reports `[propext]` for `isConvex_union` and `[propext, Quot.sound]` for
      every other new declaration; `Classical.choice` appears in none of them
- [ ] `FormalSystem/Semantics/Gluing.lean` contains no occurrence of `FrameOver.reflection`,
      `Classical`, `sorry`, or `lemma`
- [ ] The relocation of the extensionality lemma required zero call-site edits across its 13
      sites in 5 files
- [ ] `bash scripts/check-module-invariants.sh` exits 0, with C14 asserting the two new pinned
      declarations and C15 passing both of its assertions
- [ ] `bash scripts/readme-lint.sh`, `bash scripts/check-copyright-headers.sh --strict
      FormalSystem`, and `bash .claude/scripts/verify-deploy.sh` each exit 0
- [ ] `lake exe mk_all --lib FormalSystem --check` reports no drift in the generated library root
- [ ] `bash scripts/check-module-invariants.sh --emit-inventory --check` exits 0 and
      `bash scripts/typst-sync-check.sh` exits 0 — no generated surface left stale by the
      line-count changes this task makes
- [ ] `FormalSystem/Semantics/Gluing.lean`'s import list is exactly
      `import FormalSystem.Semantics.PartialHistory`, so the import closure provably excludes
      `Extension/` and `Presheaf/`
- [ ] `docs/reference/paper-definitions-of-record.md` is unmodified (Decision 8), and
      `specs/ROADMAP.md` is unmodified

## Artifacts & Outputs

- `FormalSystem/Semantics/Gluing.lean` — new module: `isConvex_union`, `rel_mixed_left`,
  `rel_mixed_right`, `convexGlue` and its six reading/bridge lemmas, `convexGlue_isConvex`,
  both `Extends` identities, `convexGlue_unique`, `gluing_clause`, `gluing_clause_of_overlap`,
  and the five-declaration ray-instance witness section
- `FormalSystem/Semantics/PartialHistory.lean` — gains the relocated extensionality lemma
- `FormalSystem/Semantics/Presheaf/Behavior.lean` — lemma removed, deferral note becomes a pointer
- `FormalSystem/Semantics.lean` and the regenerated `FormalSystem.lean` — the module wired in
- `scripts/check-module-invariants.sh` — two matched C14 heredoc pairs
- `docs/theorem-index.md` — one `app:gluing` row carrying `pinned:C14`
- `FormalSystem/Semantics/README.md`, `FormalSystem/Semantics/Presheaf/README.md`,
  `FormalSystem/OpenLanguage/README.md`, `FormalSystem/HybridLanguage/README.md` — rows and
  citations updated
- Regenerated generated inventory blocks in `FormalSystem/README.md`,
  `FormalSystem/Semantics/Presheaf/README.md`, `FormalSystem/PlusLanguage/README.md`,
  `FormalSystem/OpenLanguage/README.md`, `FormalSystem/HybridLanguage/README.md` — produced by
  `check-module-invariants.sh --emit-inventory`, never hand-edited
- Seven further Lean modules with repointed `app:gluing` References lines
- `specs/789_prove_app_gluing_general_convex_overlap/summaries/01_general-convex-gluing-summary.md`
  — written at implementation close, carrying the paper-side `% PORT:` / `\leanproof` follow-up
  for the author

## Rollback/Contingency

- Phases 1-3 are additive or call-site-neutral and each closes on its own green commit: revert
  the individual commit. The relocation in Phase 1 is reverted by moving the lemma back into
  `Behavior.lean`; nothing between Phase 1 and Phase 2 depends on its new position.
- Phase 4 is the one phase that touches a file a concurrently dispatched sibling has declared.
  It is preceded by an ordinary defensive checkpoint, `bash .claude/scripts/git-snapshot.sh 789
  --no-revert`, which is durable without reverting the working tree. If the aggregator line
  cannot be landed because the sibling is mid-edit, do not fight for it: fall back to appending
  the module's content to `FormalSystem/Semantics/PartialHistory.lean`, which touches no
  aggregator at all, and record the fallback in the task issue log. Reverting the import line
  alone leaves Phases 1-3 in a valid state — the module simply sits outside the build graph.
- Phase 5's two heredoc edits are one atomic batch in one commit. A misaligned pair fails C14
  loudly with an expected-versus-actual diff; correct the alignment and re-run rather than
  reverting. If `#print axioms` turns out to emit no `depends on axioms` line for one of the two
  declarations, omit that row from both heredocs rather than inventing a baseline line for it,
  and record the omission as a reasoned exclusion.
- Phase 6 is docstring and README prose only, so a bad edit is corrected in place rather than
  rolled back.
- If a genuine rollback of uncommitted work becomes necessary at any point, follow
  `context/contracts/recovery.md`'s rollback rung: run
  `bash .claude/scripts/git-snapshot.sh 789` (task number explicit, reverting mode) first, then
  the destructive command. Never discard uncommitted changes to reach a passing build — fix
  forward, or place a declared strategic sorry, before considering a rollback.
- The generated library root `FormalSystem.lean` is always regenerated by
  `lake exe mk_all --lib FormalSystem`, never hand-patched, so a bad regeneration is rerun.
