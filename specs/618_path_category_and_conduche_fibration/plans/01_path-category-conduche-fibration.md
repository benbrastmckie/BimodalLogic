# Implementation Plan: Task #618

- **Task**: 618 - Formalize the path category `Path(F)` and prove `cor:path-fibration`
- **Status**: [IMPLEMENTING]
- **Effort**: 11.5 hours
- **Dependencies**: 563 (interval site, behavior presheaf), 564 (Sheaf clause), 616 (duration monoid, twisted-arrow site), 617 (Reflection clause) — all landed; `Presheaf/{Site,Duration,Behavior,Sheaf,Reflection}.lean` are in the tree at `d034460fd`
- **Research Inputs**: specs/618_path_category_and_conduche_fibration/reports/01_path-category-conduche-fibration.md
- **Artifacts**: plans/01_path-category-conduche-fibration.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Build the instance of Johnstone's sheaf/Conduché correspondence at `X = Beh F` as one new
module, `FormalSystem/Semantics/Presheaf/Path.lean` (the declared `file_scope`): the hom type
`PathHom F w u` (a section of `Beh F` with its length carried in the hom), the category `PathCat F`
on the world states, the one-object category `BObj D` of durations, the length functor
`PathCat.len`, the discrete Conduché fibration property of `len` in a cast-free `PathHom`-level
form and in the packaged `∃!` form, the associated presheaf of `len` identified with `Beh F` as an
**equality** (its middle factor is `Beh.restrictTr` by `rfl`, with uniqueness the theorem), and
the `D = ℤ` clause in two layers: sections over `[0, n]` are exactly the adjacency-respecting
windows, and `PathHom F.toTaskFrame w u ≃ Quiver.Path w u` over the one-step quiver, with
composition carried to concatenation. The HARD SCOPE LIMIT holds: `fact:conduche-equivalence`
is cited, never proved, and the module docstring says so. Definition of done: the module compiles
under the cluster's `assert_not_exists` lock with zero sorries, every declaration measures
`[propext, Quot.sound]` (no `Classical.choice`), the aggregator, library root, READMEs and the
paper-definitions record carry the module, and `lake build FormalSystem` plus the complete gate
set are green.

### Research Integration

The report's encoding (R1-R5) is adopted unchanged and its phase shape (R6) is adopted with two
splits so that no phase exceeds two hours: R6's Phase 2 becomes Phases 2-3 (the unit laws and the
associativity law are separated, since `assoc` is the long `glue_unique` proof), R6's Phase 3
becomes Phases 4-5 (the fibration property and the associated-presheaf equality), and R6's
Phase 5 becomes Phases 7-8 (sections-to-paths, then paths-to-sections and the round trips).
Every "compiles" claim below rests on the report's four `lean_run_code` probes plus one further
plan-time compile: the entire `## Lean Challenge Statements` block (55 declarations, bodies
`sorry`) was compiled with `lake env lean` against the built tree at plan authoring and exits 0
(saved as `specs/618_path_category_and_conduche_fibration/challenge-statements-probe.lean`).
That compile corrected one point of the report's R5: a bare `def stepQuiver : Quiver F.WorldState`
is not found by instance synthesis, so `Quiver.Path.length`/`nil`/`comp` fail to elaborate; the
quiver is therefore carried on a synonym `StepGraph F := F.WorldState` with an `instance`, exactly
as `PathCat F` carries the `Category` instance, so no instance leaks onto a cluster type.

Carried figures re-verified at authoring: `schultz2020` and `johnstone1999` resolve in the root
`references.bib`; `def:conduche`, `def:path-category`, `fact:conduche-equivalence` have no row in
`docs/reference/paper-definitions-of-record.md` (grep), while `cor:path-fibration` has a
`DANGLING` row stating "NO Path(F) exists in the tree"; `FormalSystem/Semantics/ShiftFiniteType.lean`
lines 75-80 describe the `D = ℤ` clause and say "no `Path(F)` exists in this tree";
`TaskFrame.comp : TaskFrame.Compositional F.TaskRel` is at `Semantics/TaskFrame.lean:2682`;
`intOrder` is `@[reducible]` (`Semantics/TemporalOrder.lean:152`) so `Beh F.toTaskFrame n` takes a
bare `n : ℤ`.

### Prior Plan Reference

No prior plan for this task. The sibling plan
`specs/617_reflection_clause_converse_frame_naturality/plans/01_reflection-clause-converse-frame.md`
(completed) is the template for the module shape, the wiring phase, and the gate list; its
Phase 3 record shows two shared touches it did not anticipate — the `FormalSystem.lean` library
root import and `typst/generated/status.typ` regeneration — which this plan names up front.

### Roadmap Alignment

Not consulted: this dispatch carries no `roadmap_path`.

## Goals & Non-Goals

**Goals**:
- `Beh.castLen`, `Beh.castLen_val`, `Beh.castLen_eq_iff`, `glueSum`, `glueSum_restrict_left`, `glueSum_restrict_right`, `glueSum_states_zero`, `glueSum_states_end`
- `PathHom.ext'`, `PathHom.id`, `PathHom.comp`, `PathHom.comp_len`, `PathHom.id_len`, `PathHom.id_comp`, `PathHom.comp_id`, `BObj.instCategory`
- `PathHom.comp_assoc`, `PathCat`, `PathCat.instCategory`, `PathCat.len`, `PathCat.len_map`
- `IsDiscreteConduche`, `PathHom.cutState`, `PathHom.factorLeft`, `PathHom.factorRight`, `PathHom.factorLeft_len`, `PathHom.factorRight_len`, `PathHom.factor_comp`, `PathHom.factor_unique`, `PathCat.len_isDiscreteConduche`
- `PathHom.assocRestrict`, `PathHom.assocRestrict_len`, `PathHom.assocRestrict_sec`, `PathHom.assocRestrict_unique`, `PathHom.assocRestrict_id`, `PathHom.assocRestrict_comp`
- `iter_of_adjacent_window`, `Beh.ofAdjacentWindow`, `Beh.ofAdjacentWindow_states`, `beh_int_iff_adjacent_window`
- `StepGraph`, `StepGraph.instQuiver`, `PathHom.toPathAux`, `PathHom.toPath`, `PathHom.toPath_length`, `PathHom.toPath_id`, `PathHom.toPath_comp`
- `PathHom.ofStep`, `PathHom.ofPath`, `PathHom.ofPath_toPath`, `PathHom.toPath_ofPath`, `PathHom.pathEquiv`

**Non-Goals**:
- Johnstone's general equivalence (`fact:conduche-equivalence`, Prop. 3.6; Schultz-Spivak-
  Vasilakopoulou Thm. A.2.1): no general sheaf-to-category or fibration-to-presheaf construction
  is defined. The "associated category" and "associated presheaf" of the paper's `def:conduche`
  are instantiated at `Beh F` and at `len`; the general notions are named in the docstring as the
  two halves of the cited, external equivalence. The report's Decisions record that no phase found
  the general proof cheap (extracting data from a general fibration's `∃!` needs choice)
- A `Category` instance on `Obj D`, `Dur D`, `Int(D)`, or `F.WorldState` itself, or a `Functor`
  from `Int(D)` to `Type`; `Site.lean` and `Duration.lean` stay concrete and untouched except for
  a one-sentence forward pointer in their Implementation Notes (Phase 9)
- Mathlib's `CategoryTheory.Paths V` or an equivalence of categories with it: `Quiver.Path`
  (`Mathlib.Combinatorics.Quiver.Path`, no `CategoryTheory` dependency) is the free-category hom
  type, and the hom-set `Equiv` plus `toPath_id`/`toPath_comp` is the statement; the docstring
  cites `CategoryTheory.Paths.categoryPaths` as the definition this matches
- The forwarded appendix item (pullback of `len` along `(D, ≤) → BD⁺` for the translation
  product; questions (a)-(c)): posed in the module docstring's closing paragraph with a pointer to
  `FormalSystem/Semantics/Frames/TranslationProduct.lean`, not built
- Re-proving the sum-form gluing: `glueSum` is `glue` at the cut `l₁` under a val-preserving cast,
  and its lemmas delegate to `restrict_glue_left`/`restrict_glue_right`; `Sheaf.lean` is untouched
  except for a one-sentence pointer reconciling its "buys nothing" note (Phase 9)

**Declarations outside the identifier list above** (not Challenge-pinned because the snapshot
tool's declaration regex admits only `theorem`/`lemma`/`def`/`instance`): the two `structure`s
`PathHom` and `BObj`, and the `abbrev` `StepPath`. Their shapes are fixed by the
`## Lean Challenge Statements` block all the same.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Phases 7-8 (the `Quiver.Path` round trip) are the only phases with real proof-engineering risk: `toPath` recurses on a `ℕ` extracted from an `ℤ`-valued `len`, and `toPath_comp` needs `Int.toNat_add` on nonnegative summands plus a `castLen` at every peeled step | H | M | Define `toPathAux` on an explicit `n : ℕ` with `hn : (n : ℤ) = e.len.val`, prove everything there, derive the `len`-indexed forms with `Int.toNat_of_nonneg`; `Periodicity.exists_path_of_iter` is the in-tree model for the `n`-indexed induction. If the round trips resist, Phase 7's `toPath_length`/`toPath_id`/`toPath_comp` already deliver "sections are paths" and "gluing is concatenation"; `pathEquiv` is the last 20 % and Phase 8 may close `[PARTIAL]` with that recorded |
| `PathHom.comp_assoc` by `glue_unique` needs `Beh.restrict_comp` with specific offset proofs, and `rw` on `restrict_comp` is sensitive to the proof arguments | M | M | Keep every comparison at the `.val` level via the cast kit (`castLen_val` `@[simp]`, `castLen_eq_iff`) and `Beh.ext`, where proof arguments are irrelevant — the same way `restrict_glue_left` already works; never case-split on `glue`'s `dite` |
| C15 fails on the first build of a docstring citing `def:conduche`, `def:path-category`, `fact:conduche-equivalence` (no record rows exist) | M | H (certain without Phase 1) | Phase 1 adds three `DANGLING` rows modelled on the `def:twisted-arrow` row before any `.lean` text cites them, exactly as task 616 phase 1 did (`e74fa4368`) |
| `Mathlib.CategoryTheory.Functor.Basic` changes elaboration in the module: the report's probe 2 saw `simpa using hmatch` fail where `exact hmatch` (definitional, `castLen` is val-preserving) succeeds | M | M | Import both Mathlib files in Phase 1's skeleton so every later phase elaborates under the final import set; prefer `exact`/`rfl` over `simpa` at casts; `castLen_val` is `@[simp]` |
| Axiom profile: `Classical.choice` could enter through `Int.toNat`/`omega` arithmetic in Phases 6-8 or through `simp` on `↑D` | M | L | `#print axioms` sweep at the end of every phase; route ℤ arithmetic through `taskRel_eq_iter_int`/`reflection_int` (choice-free), never `taskRel_eq_iter`/`reflection` |
| Aggregator clobber: `FormalSystem/Semantics/Presheaf.lean` and the library root `FormalSystem.lean` are shared touches outside every task's `file_scope` on this front | M | L | Phase 9 edits them last; re-read immediately before editing; `git log -1 --` and `git status --short` on each first; stage only this task's own hunks with an explicit-file `git add`; STOP and report on any foreign in-flight edit |
| `typst/generated/status.typ` is in concurrent sibling 782's declared `file_scope` this cycle, and this task's Phase 9 regenerates it (module count changes) | M | M | Treat as a generated file: regenerate, never hand-edit; re-read and check `git status --short typst/generated/status.typ` immediately before; if a foreign uncommitted modification is present, STOP and report per `context/contracts/territory.md` rather than overwrite |
| The Lean Challenge snapshot tool forces every declaration body to `:= sorry`; the two `instance` declarations in the block carry real `where` bodies because downstream statements (`PathCat.len_map`, `IsDiscreteConduche`, `len_isDiscreteConduche`) only typecheck when `Hom` in `BObj D` is definitionally `Dur D` | L | M | Recorded here and under the block; the block as written in this plan compiles (plan-time probe); the tool's `--check` verdict is advisory only per `.claude/rules/plan-compliance.md`, and a mismatch traced to the sorry-forcing is a tooling finding, not a statement defect |
| `scripts/check-paper-definitions.sh` exits 1 on pre-existing drift of pinned definitions by the external paper (task 617 phase 3 recorded 9 such rows, identical against HEAD) | L | H | This task pins nothing and leaves every cut anchor `DANGLING`; confirm the failing rows are the same pre-existing set (`git stash`-free: compare against `git show HEAD:docs/reference/paper-definitions-of-record.md`) and record the exit as pre-existing in the phase notes, as 617 did |
| Full `lake build FormalSystem` at the final gate is long on a loaded host (two other implement dispatches run this cycle) | M | M | Route through `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem` with the Bash tool timeout raised to 600000, or detach and wait via `context/patterns/bounded-build-waiter.md`; never an unbounded foreground call |
| The sum-form `hmatch` at `castLen` is accepted by `exact` only because `castLen` preserves `.val` definitionally; a later refactor of `castLen` to a `▸`-based transport would silently break every `comp` | L | L | `castLen` is `⟨τ.val, fun t => by rw [← h]; exact τ.property t⟩` and `castLen_val` is `rfl`; the module's Implementation Notes record this as load-bearing |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |
| 6 | 6 | 5 |
| 7 | 7 | 6 |
| 8 | 8 | 7 |
| 9 | 9 | 8 |

Phases within the same wave can execute in parallel. This plan is fully sequential: Phases 1-8
all edit the single new module `Presheaf/Path.lean` (Phase 6's content is logically independent
of Phases 2-5, but it shares the file, so it is sequenced rather than parallelized), and Phase 9's
wiring and full gate must observe everything.

### Phase 1: Record rows, module skeleton, cast kit, and sum-form gluing [COMPLETED]

**Goal**: Make the three uncited paper anchors citable (C15), create
`FormalSystem/Semantics/Presheaf/Path.lean` with its full module docstring and import set, and
land the val-preserving cast kit and the sum-form gluing `glueSum` with its four reading lemmas —
the bedrock every later phase composes over.

**Tasks**:
- [x] `docs/reference/paper-definitions-of-record.md`: add three `DANGLING` `KNOWN-ANCHORS` rows
      — `def:conduche`, `def:path-category`, `fact:conduche-equivalence` — in alphabetical position
      among the existing rows, modelled word-for-word in structure on the `def:twisted-arrow` row
      (statement of record transposed from `appendix_cut_material.tex`; the `app:Structure` cut
      note; "NOT PINNABLE, as for app:Structure"), each ending with a FORMALIZED clause naming
      `FormalSystem/Semantics/Presheaf/Path.lean` and, for `fact:conduche-equivalence`, saying
      explicitly that only the INSTANCE at `Beh F` is formalized and the general equivalence is
      cited and external. Update the prose paragraph "The remaining seven of the twelve ..." (near
      line 1000) so the count and list reflect that `def:path-category`, `def:conduche`, and
      `cor:path-fibration` are now load-bearing (the `cor:path-fibration` row itself is edited in
      Phase 9, once `Path(F)` exists). Re-read the surrounding lines immediately before editing —
      sibling tasks on this front edit the same rows
- [x] Create `FormalSystem/Semantics/Presheaf/Path.lean` with the repository header,
      `import FormalSystem.Init`, `import Mathlib.CategoryTheory.Functor.Basic`,
      `import Mathlib.Combinatorics.Quiver.Path`, `import FormalSystem.Semantics.Presheaf.Sheaf`,
      `import FormalSystem.Semantics.Presheaf.Duration`,
      `import FormalSystem.Semantics.IntNormalFormEffective`, the `/-! ... -/` module docstring
      (structure as `Presheaf/Reflection.lean`: title, narrative, `## Main Definitions`,
      `## Main Results`, `## Implementation Notes`, `## References`, `## Tags`),
      `namespace FormalSystem.Semantics.Presheaf`, `open CategoryTheory`, and the closing
      `assert_not_exists FormalSystem.ProofSystem.Axiom FormalSystem.ProofSystem.DerivationTree`
- [x] Write the docstring's load-bearing paragraphs now, not as a Phase 9 afterthought:
      (a) **the HARD SCOPE LIMIT** — `fact:conduche-equivalence` (Johnstone 1999 Prop. 3.6;
      Schultz-Spivak-Vasilakopoulou 2020 Thm. A.2.1) is cited and external; this module builds the
      INSTANCE at `X = Beh F` and proves the fibration property for it; the "associated category of
      a sheaf" and "associated presheaf of a fibration" of `def:conduche` are instantiated, not
      defined in general, and a reader must not mistake the instance for the theorem;
      (b) **what `Path(F)` is** — objects the world states (the *Germs* clause), a morphism
      `w → u` of length `l` a section `τ ∈ Beh F l` with `τ(0) = w`, `τ(l) = u`, composition by
      gluing (the *Sheaf* clause), identities the germs; the length lives in the hom, so `comp` is
      total and `len` a projection; (c) **why `Mathlib.CategoryTheory` enters here and nowhere
      else in the cluster** — the weighing `Duration.lean`'s Implementation Notes deferred to this
      task comes out the other way because the first deliverable (a discrete Conduché fibration
      `P : E → BD⁺` in general) is unstatable without categories and functors; instances sit only
      on the synonyms `BObj D`, `PathCat F`, `StepGraph F`, never on `Obj D`, `Dur D`, `Int(D)` or
      `F.WorldState`; the `assert_not_exists` lock is unaffected; (d) **reuse** — `glueSum` is
      `glue` under a val-preserving cast, and the `D = ℤ` clause consumes `FrameOver.step`, `iter`,
      `taskRel_natCast_iff_iter`, and the choice-free `taskRel_eq_iter_int`/`reflection_int` of
      `Semantics/IntNormalForm*.lean` rather than re-deriving them; (e) the **forwarded appendix
      item** as an open closing paragraph: a `PathHom (prodFrame F).toTaskFrame (w,d) (v,e)` of
      length `l` projects to a `PathHom F w v` with `e = d + l`, the shape of the pullback of `len`
      along `(D, ≤) → BD⁺`; questions (a)-(c) posed, not settled, pointer to
      `FormalSystem/Semantics/Frames/TranslationProduct.lean` (`prodRel`, `liftH`, `projH`)
- [x] Write `## References` in the normal form of `docs/development/REFERENCE_NORMAL_FORM.md`:
      `[P. T. Johnstone, *A Note on Discrete Conduché Fibrations*][johnstone1999]` (Introduction,
      §2, Prop. 3.6 cited only); `[P. Schultz, D. I. Spivak and C. Vasilakopoulou, *Dynamical
      Systems and Sheaves*][schultz2020]` (Def. A.1.1, §§A.2-A.3, Prop. 3.2.3, Thm. A.2.1 cited
      only); the JPL anchors `def:conduche`, `def:path-category`, `fact:conduche-equivalence`,
      `cor:path-fibration`, `app:presheaf-dictionary` (*Germs*, *Sheaf*), `lem:nullity`, each
      marked **`DANGLING`** where cut, text in
      `/home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/appendix_cut_material.tex`; the
      repository modules `Presheaf/Behavior.lean`, `Presheaf/Sheaf.lean`, `Presheaf/Duration.lean`,
      `Semantics/IntNormalForm.lean`, `Semantics/IntNormalFormEffective.lean`,
      `Semantics/ShiftFiniteType.lean`; and Mathlib's `CategoryTheory.Paths.categoryPaths` as the
      definition the `D = ℤ` clause matches
- [x] Define the cast kit: `Beh.castLen (h : l = l') (τ : Beh F l) : Beh F l'` as
      `⟨τ.val, fun t => by rw [← h]; exact τ.property t⟩`, `@[simp] Beh.castLen_val` (`rfl`),
      `Beh.castLen_eq_iff` (via `Beh.ext`/`Subtype.ext_iff`)
- [x] Define `glueSum hcomp h₁ h₂ τ₁ τ₂ hmatch : Beh F (l₁ + l₂)` as
      `glue hcomp h₁ (le_add_of_nonneg_right h₂) τ₁ (Beh.castLen (add_sub_cancel_left l₁ l₂).symm τ₂) hmatch`
      with `hmatch` passed by `exact` (definitional); prove `glueSum_restrict_left` (delegate to
      `restrict_glue_left`), `glueSum_restrict_right` (delegate to `restrict_glue_right`, landing
      the cast with `Beh.ext`/`castLen_val`), `glueSum_states_zero` and `glueSum_states_end` (the
      three-step `states_eq_of_eq` + `Beh.restrict_states` + `PartialHistory.states_eq_of_time_eq`
      shape of `restrict_glue_left`'s body, read against the two restriction identities)
- [x] Every declaration docstring carries `Constraints consumed: Compositionality` for `glueSum`
      and its lemmas (explicit `hcomp`, the Sheaf module's convention) and
      `Constraints consumed: None` for the cast kit (closed vocabulary of
      `REFERENCE_NORMAL_FORM.md` §3; C34)
- [x] Record the issue log as events arise (`issue-record.sh --phase implement`), with an
      explicit "nothing to record" attestation in the phase commit if that is the case

**Timing**: 1 hour

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: Eight declarations in the new module (three cast-kit, `glueSum`, four
lemmas) and three new record rows plus one edited prose paragraph; confirm with
`grep -c '^def \|^theorem \|^@\[simp\] theorem \|^instance \|^structure \|^abbrev ' FormalSystem/Semantics/Presheaf/Path.lean`
expecting 8, and `grep -c '^def:conduche|\|^def:path-category|\|^fact:conduche-equivalence|' docs/reference/paper-definitions-of-record.md`
expecting 3.

**Tier Justification**: `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Semantics.Presheaf.Path`
is the complete covering check for the module (new and unimported until Phase 9, so nothing else
can observe it), and `bash scripts/check-module-invariants.sh --no-build` read at its C15 line is
the covering check for the record rows (C15 scans every live `.lean`/`.md`, so the new
docstring's anchors are checked against the new rows even before wiring).

**Files to modify**:
- `FormalSystem/Semantics/Presheaf/Path.lean` - create: header, imports, module docstring, cast kit, `glueSum` and its four lemmas, `assert_not_exists` lock
- `docs/reference/paper-definitions-of-record.md` - three `DANGLING` rows for `def:conduche`, `def:path-category`, `fact:conduche-equivalence`; the "remaining seven of the twelve" paragraph updated

**Verification**:
- Guarded scoped build of `FormalSystem.Semantics.Presheaf.Path` exits 0 with no `sorry` warning
- `bash scripts/check-module-invariants.sh --no-build` reports C15 PASS (every anchor the new
  docstring cites resolves against the record)
- `#print axioms` on `glueSum_restrict_right` and `glueSum_states_end` (via a scratch
  `lake env lean` probe or a temporary line removed before commit) reports `[propext, Quot.sound]`
- The file ends with the `assert_not_exists` line and it passes
- Commit: `task 618 phase 1: record rows, module skeleton, cast kit, and sum-form gluing`, staged
  by explicit file list *(deviation: altered — the pre-commit `typst-sync-check.sh` gate refuses any commit while `typst/generated/status.typ`'s FormalSystem file/line counts are stale, and the new module changes both; `status.typ` was therefore regenerated via `typst-sync-check.sh --fix` and staged with this phase's commit — and will be at every later phase commit — rather than only in Phase 9 as planned. `git status --short typst/generated/status.typ` was clean beforehand: sibling 782 had already completed)*
- Verification record (2026-10-18): guarded scoped build of `FormalSystem.Semantics.Presheaf.Path` exit 0, no sorry; full guarded `lake build` exit 0 (2878 jobs, 0 errors); `check-module-invariants.sh --no-build` C15 PASS (93 citations), C34a/C34b PASS; `#print axioms`: `glueSum_restrict_right`, `glueSum_states_end`, `glueSum_states_zero` all `[propext, Quot.sound]`, `Beh.castLen_eq_iff` `[propext]`; declaration count 8, record rows 3. C6/INV/C33 report the module as unwired, as expected before Phase 9

---

### Phase 2: The hom type, identities, composition, unit laws, and the duration category [NOT STARTED]

**Goal**: Define `PathHom F w u` (length in the hom), its extensionality principle, the identity
(the germ at `w`) and the composition (sum-form gluing), the two length-reading lemmas, the two
unit laws, and the one-object `Category` instance on `BObj D` whose homs are the durations.

**Tasks**:
- [ ] Define `structure PathHom (F : TaskFrame) (w u : F.WorldState)` with fields
      `len : Dur F.Duration`, `sec : Beh F len.val`,
      `src : sec.val.states 0 (Beh.mem_dom sec le_rfl len.property) = w`,
      `tgt : sec.val.states len.val (Beh.mem_dom sec len.property le_rfl) = u` (the probed shape)
- [ ] Prove `PathHom.ext' (hl : f.len = g.len) (hs : f.sec.val = g.sec.val) : f = g` by
      `obtain`/`subst`/`Subtype.ext` (`[propext]`); this is the key that keeps every category law
      at a `Dur` equation plus a `PartialHistory` equation, with no `HEq` and no `▸`
- [ ] Define `PathHom.id F [F.IsRegular] w := ⟨Dur.id, Beh.ofGerm F w, rfl, rfl⟩` and
      `PathHom.comp hcomp f g := { len := Dur.comp f.len g.len, sec := glueSum hcomp f.len.property g.len.property f.sec g.sec (f.tgt.trans g.src.symm), src := (glueSum_states_zero …).trans f.src, tgt := (glueSum_states_end …).trans g.tgt }`
      — rewrite the hypotheses, never the goal (`rw [← f.src]` on the goal fails: motive not type
      correct, per the report's tactic survey)
- [ ] Prove `@[simp] PathHom.comp_len` and `@[simp] PathHom.id_len` (both `rfl`)
- [ ] Prove `PathHom.id_comp` and `PathHom.comp_id` by `PathHom.ext'`: the length half is
      `Dur.id_comp`/`Dur.comp_id`; the section half via `glue_unique` with `υ := castLen … f.sec`
      — the left restriction to `0` is `Beh.ofGerm (…)` by `Beh.ofGerm_germ` after `Beh.ext`, the
      restriction to the full length is `f.sec` by `Beh.restrict_id` up to `castLen`
- [ ] Define `structure BObj (D : TemporalOrder) where unit : Unit` and
      `instance BObj.instCategory (D) : Category (BObj D)` with `Hom _ _ := Dur D`,
      `id _ := Dur.id`, `comp f g := Dur.comp f g`, laws `Dur.id_comp`/`Dur.comp_id`/`Dur.comp_assoc`
      verbatim (the reconciliation `Duration.lean`'s note promised)
- [ ] Docstrings: `Constraints consumed: Compositionality` on `comp`, `comp_len`;
      `Constraints consumed: Seriality, Limit` on `id`, `id_len` (through `Beh.ofGerm`'s
      `[F.IsRegular]` via `nullity_identity`); `Constraints consumed: Compositionality, Seriality, Limit`
      on `id_comp`/`comp_id` (they take `[F.IsRegular]` and use `F.comp`);
      `Constraints consumed: None` on `ext'`, `BObj`, `BObj.instCategory`
- [ ] Record the issue log as events arise

**Timing**: 1.5 hours

**Depends on**: 1

**Verification Tier**: local

**Scope Hypothesis**: Ten further declarations (`PathHom`, seven `PathHom.*`, `BObj`,
`BObj.instCategory`), eighteen in the module in total; confirm with the Phase 1 grep, expecting
18.

**Tier Justification**: The same guarded scoped build of `FormalSystem.Semantics.Presheaf.Path`
remains the complete covering check — the module is still unimported, so nothing outside it can
break.

**Files to modify**:
- `FormalSystem/Semantics/Presheaf/Path.lean` - add `PathHom`, `ext'`, `id`, `comp`, the two length lemmas, the two unit laws, `BObj` and its `Category` instance

**Verification**:
- Guarded scoped build exits 0 with no `sorry` warning
- `#print axioms` on `PathHom.id_comp` and `PathHom.comp_id` reports `[propext, Quot.sound]`
- Commit: `task 618 phase 2: the hom type, identities, composition, unit laws, and the duration category`

---

### Phase 3: Associativity, the path category, and the length functor [NOT STARTED]

**Goal**: Prove associativity of `PathHom.comp` through uniqueness of gluing, package
`PathCat F := F.WorldState` as a `Category`, and define the length functor
`PathCat.len : PathCat F ⥤ BObj F.Duration` with its reading lemma.

**Tasks**:
- [ ] Prove `PathHom.comp_assoc hcomp f g h`: by `PathHom.ext'`, the length half is
      `Dur.comp_assoc`; the section half via `glue_unique` applied to
      `castLen (add_assoc …) (glueSum (glueSum f.sec g.sec) h.sec)`, whose left restriction to
      `l₁` is `f.sec` (`Beh.restrict_comp` chaining `restrict 0 l₁ ∘ restrict 0 (l₁ + l₂)`, then
      `glueSum_restrict_left` twice) and whose right restriction onto `l₂ + l₃` is
      `glueSum g.sec h.sec` (itself characterized by `glue_unique`); every comparison at the
      `.val` level through the cast kit (R2)
- [ ] Define `def PathCat (F : TaskFrame) : Type := F.WorldState` and
      `instance PathCat.instCategory (F) [F.IsRegular] : Category (PathCat F)` with
      `Hom w u := PathHom F w u`, `id w := PathHom.id F w`, `comp f g := PathHom.comp F.comp f g`,
      `id_comp f := PathHom.id_comp f`, `comp_id f := PathHom.comp_id f`,
      `assoc f g h := PathHom.comp_assoc F.comp f g h`
- [ ] Define `PathCat.len (F) [F.IsRegular] : PathCat F ⥤ BObj F.Duration` with `obj _ := ⟨()⟩`,
      `map f := f.len`, `map_id _ := rfl`, `map_comp _ _ := rfl` (both `rfl` per the probe), and
      prove `PathCat.len_map (f : w ⟶ u) : (PathCat.len F).map f = PathHom.len f` (`rfl`)
- [ ] Docstrings: `Constraints consumed: Compositionality` on `comp_assoc`;
      `Constraints consumed: Compositionality, Seriality, Limit` on `PathCat.instCategory`,
      `PathCat.len`, `PathCat.len_map`; `Constraints consumed: None` on `PathCat`. Note in
      `PathCat`'s docstring that it is a synonym so that no `Category` instance is placed on
      `F.WorldState`
- [ ] Record the issue log as events arise

**Timing**: 1.25 hours

**Depends on**: 2

**Verification Tier**: local

**Scope Hypothesis**: Five further declarations, twenty-three in total; confirm with the Phase 1
grep, expecting 23.

**Tier Justification**: The same guarded scoped build of `FormalSystem.Semantics.Presheaf.Path`
remains the complete covering check — the module is still unimported.

**Files to modify**:
- `FormalSystem/Semantics/Presheaf/Path.lean` - add `comp_assoc`, `PathCat` and its `Category` instance, `PathCat.len`, `len_map`

**Verification**:
- Guarded scoped build exits 0 with no `sorry` warning
- `#print axioms` on `PathHom.comp_assoc` and `PathCat.instCategory` reports `[propext, Quot.sound]`
- Commit: `task 618 phase 3: associativity, the path category, and the length functor`

---

### Phase 4: The discrete Conduché fibration property of `len` [NOT STARTED]

**Goal**: Define the general predicate `IsDiscreteConduche (P : E ⥤ BObj D)` (the paper's
`def:conduche`, first clause), prove the cast-free `PathHom`-level factorization existence and
uniqueness, and derive `PathCat.len_isDiscreteConduche` — the first half of `cor:path-fibration`.

**Tasks**:
- [ ] Define `IsDiscreteConduche {D} {E : Type*} [Category E] (P : E ⥤ BObj D) : Prop :=
      ∀ {A B : E} (e : A ⟶ B) (fac : Factorization (P.map e)), ∃! t : Σ C : E, (A ⟶ C) × (C ⟶ B), t.2.1 ≫ t.2.2 = e ∧ (P.map t.2.1).val = fac.fst ∧ (P.map t.2.2).val = fac.snd`
      (the probed form; `Factorization e.len` is exactly the paper's "factorization
      `P(e) = x + y`")
- [ ] Define `PathHom.cutState e fac := e.sec.val.states fac.fst (Beh.mem_dom e.sec fac.fst_nonneg fac.fst_le)`,
      `PathHom.factorLeft e fac : PathHom F w (e.cutState fac)` with `len := ⟨fac.fst, fac.fst_nonneg⟩`
      and `sec := Beh.restrict 0 fac.fst le_rfl fac.fst_nonneg _ e.sec`, and
      `PathHom.factorRight e fac : PathHom F (e.cutState fac) u` with `len := ⟨fac.snd, fac.snd_nonneg⟩`
      and `sec := Beh.restrict fac.fst fac.snd fac.fst_nonneg fac.snd_nonneg (by rw [fac.add_eq]) e.sec`;
      endpoints by `Beh.restrict_states` + `PartialHistory.states_eq_of_time_eq`
- [ ] Prove `@[simp] factorLeft_len`, `@[simp] factorRight_len` (`rfl`)
- [ ] Prove `PathHom.factor_comp hcomp e fac : PathHom.comp hcomp (e.factorLeft fac) (e.factorRight fac) = e`
      by `ext'` (length: `Factorization.add_eq`) + `glue_unique` with `υ := castLen fac.add_eq.symm e.sec`
      and the two restriction identities
- [ ] Prove `PathHom.factor_unique hcomp e fac e₁ e₂ h h₁ h₂ : c = e.cutState fac ∧ e₁.sec.val = (e.factorLeft fac).sec.val ∧ e₂.sec.val = (e.factorRight fac).sec.val`
      by reading `glueSum_restrict_left`/`glueSum_restrict_right` against `e` through `h`, with
      `c` recovered as `e₁.tgt` (the `.val`-level statement keeps the dependent equality out)
- [ ] Prove `PathCat.len_isDiscreteConduche F : IsDiscreteConduche (PathCat.len F)`: existence
      from `factorLeft`/`factorRight`/`factor_comp`/the two length lemmas; uniqueness from
      `factor_unique`, then `subst` on `c = e.cutState fac` and `Sigma.ext`/`Prod.ext`/`ext'` —
      this sigma form is where the one dependent equality lives; keep it out of the `PathHom`-level
      statements
- [ ] Docstrings: `Constraints consumed: None` on `IsDiscreteConduche`, `cutState`,
      `factorLeft`, `factorRight`, the two length lemmas; `Constraints consumed: Compositionality`
      on `factor_comp`, `factor_unique`; `Constraints consumed: Compositionality, Seriality, Limit`
      on `len_isDiscreteConduche`. Say in `IsDiscreteConduche`'s docstring that this is the general
      notion of `def:conduche` stated so that `len` can be shown to satisfy it, and that no general
      construction from a fibration is built (the HARD SCOPE LIMIT)
- [ ] Record the issue log as events arise

**Timing**: 1.5 hours

**Depends on**: 3

**Verification Tier**: local

**Scope Hypothesis**: Nine further declarations, thirty-two in total; confirm with the Phase 1
grep, expecting 32.

**Tier Justification**: The same guarded scoped build of `FormalSystem.Semantics.Presheaf.Path`
remains the complete covering check — the module is still unimported.

**Files to modify**:
- `FormalSystem/Semantics/Presheaf/Path.lean` - add `IsDiscreteConduche`, `cutState`, the two factors, their length lemmas, `factor_comp`, `factor_unique`, `len_isDiscreteConduche`

**Verification**:
- Guarded scoped build exits 0 with no `sorry` warning
- `#print axioms` on `PathHom.factor_unique` and `PathCat.len_isDiscreteConduche` reports
  `[propext, Quot.sound]` and no `Classical.choice`
- Commit: `task 618 phase 4: the discrete Conduché fibration property of len`

---

### Phase 5: The associated presheaf of `len` is `Beh F`, as an equality [NOT STARTED]

**Goal**: Formalize the paper's sharper claim: the associated presheaf of `len` (sections over
`l` the morphisms of length `l`; restriction along `Tr p : l' → l` the middle factor of the unique
three-fold factorization) is EQUAL to `Beh F`, because the middle factor is `Beh.restrictTr` by
construction (`rfl`) and uniqueness is the theorem; its functoriality is then `Beh.restrictTr_id`/
`restrictTr_comp`.

**Tasks**:
- [ ] Define `PathHom.assocRestrict (f : Tr l' l) (e : PathHom F w u) (hl : e.len = l) : Σ c c' : F.WorldState, PathHom F c c'`
      as the middle factor: endpoints `e.sec` read at `f.shift` and `f.shift + l'.val`, section
      `Beh.restrictTr f (Beh.castLen (congrArg Subtype.val hl) e.sec)`, length `l'`
- [ ] Prove `assocRestrict_len` (`rfl`) and `assocRestrict_sec : (assocRestrict f e hl).2.2.sec.val = (Beh.restrictTr f (Beh.castLen (congrArg Subtype.val hl) e.sec)).val`
      **by `rfl`** — this is the equality `cor:path-fibration`'s proof claims; the docstring says
      so and says why it is available where `fact:conduche-equivalence` returns only a natural
      isomorphism (the middle factor is *defined* as the restriction; uniqueness is a theorem about
      it)
- [ ] Prove `assocRestrict_unique hcomp f e hl e₁ e₂ e₃ h h₁ h₂ : e₂.sec.val = (assocRestrict f e hl).2.2.sec.val`
      from Phase 4's `factor_unique` applied twice (first cut at `f.shift`, then at `l'.val` inside
      the right factor), comparing at the `.val` level through `Beh.restrict_comp`
- [ ] Prove the functoriality corollaries `assocRestrict_id` (from `Beh.restrictTr_id`) and
      `assocRestrict_comp` (from `Beh.restrictTr_comp`), each a `.val`-level equation so that no
      transport along `assocRestrict_len` appears
- [ ] Add to the module docstring's `## Main Results` the sentence that the associated presheaf
      of `len` is `Beh F` itself — same sections (`PathHom` of length `l` is a `Beh F l` with two
      endpoint equations), same restriction (`assocRestrict_sec`), same functoriality
      (`assocRestrict_id`/`assocRestrict_comp`) — and that the "associated presheaf of a
      fibration" notion is thereby instantiated at `len`, not defined in general
- [ ] Docstrings: `Constraints consumed: None` on `assocRestrict`, `assocRestrict_len`,
      `assocRestrict_sec`, `assocRestrict_id`, `assocRestrict_comp`;
      `Constraints consumed: Compositionality` on `assocRestrict_unique`
- [ ] Record the issue log as events arise

**Timing**: 1 hour

**Depends on**: 4

**Verification Tier**: local

**Scope Hypothesis**: Six further declarations, thirty-eight in total; confirm with the Phase 1
grep, expecting 38.

**Tier Justification**: The same guarded scoped build of `FormalSystem.Semantics.Presheaf.Path`
remains the complete covering check — the module is still unimported.

**Files to modify**:
- `FormalSystem/Semantics/Presheaf/Path.lean` - add `assocRestrict` and its five lemmas; `## Main Results` paragraph on the equality

**Verification**:
- Guarded scoped build exits 0 with no `sorry` warning
- `assocRestrict_sec` closes by `rfl` (if it does not, the definition of `assocRestrict` has
  drifted from "the restriction" and must be corrected, not the lemma weakened)
- `#print axioms` on `assocRestrict_unique` reports `[propext, Quot.sound]`
- Commit: `task 618 phase 5: the associated presheaf of len is Beh F, as an equality`

---

### Phase 6: `D = ℤ`, layer 1 — sections over `[0, n]` are the adjacency-respecting windows [NOT STARTED]

**Goal**: Prove the paper's first `D = ℤ` sentence: for `F : FrameOver intOrder` regular and
`0 ≤ n`, a function `g : ℤ → F.WorldState` is the state function of some `τ : Beh F.toTaskFrame n`
iff `F.step (g i) (g (i+1))` for all `0 ≤ i < n` — iterating *Compositionality* identifies `⇒ₙ`
with the `n`-fold composite of `⇒₁`, `⇒₀` is the identity by `lem:nullity` and *Limit*, and the
reflection convention covers negative differences. Choice-free by routing through the `_int`
lemmas.

**Tasks**:
- [ ] Prove `iter_of_adjacent_window F n g hg s t hs hst htn : iter (FrameOver.step F) (Int.toNat (t - s)) (g s) (g t)`
      by induction on `Int.toNat (t - s)` (the ℤ-window twin of `Periodicity.iter_of_path`; model
      the induction on `Periodicity.exists_path_of_iter`), consuming only `hg` — no frame
      constraint
- [ ] Define `Beh.ofAdjacentWindow F n hn g hg : Beh F.toTaskFrame n` with domain `0 ≤ i ∧ i ≤ n`,
      states `g i`, and `respects_task` from `iter_of_adjacent_window` through
      `taskRel_natCast_iff_iter` (for `s ≤ t`, with `((t - s).toNat : ℤ) = t - s` by
      `Int.toNat_of_nonneg`) and `reflection_int` (for `t < s`) — never `taskRel_eq_iter` or
      `reflection`, which pull `Classical.choice`
- [ ] Prove `Beh.ofAdjacentWindow_states` (`rfl`)
- [ ] Prove `beh_int_iff_adjacent_window`: forward from `τ.val.respects_task` at `(i, i+1)` with
      `(i + 1) - i = 1` and `FrameOver.step`'s definition (`F.TaskRel w 1 u`), states read through
      the hypothesis; backward from `ofAdjacentWindow` and `ofAdjacentWindow_states`
- [ ] Docstrings: `Constraints consumed: None` on `iter_of_adjacent_window`;
      `Constraints consumed: Compositionality, Seriality, Limit` on the other three (they take
      `[F.IsRegular]` through `taskRel_natCast_iff_iter`/`reflection_int`). Cite
      `FrameOver.taskRel_natCast_iff_iter` as "iterating Compositionality",
      `FrameOver.nullity_identity` as `lem:nullity` + *Limit*, and the reflection convention, as
      `Semantics/ShiftFiniteType.lean`'s docstring already does
- [ ] Record the issue log as events arise

**Timing**: 1 hour

**Depends on**: 5

**Verification Tier**: local

**Scope Hypothesis**: Four further declarations, forty-two in total; confirm with the Phase 1
grep, expecting 42.

**Tier Justification**: The same guarded scoped build of `FormalSystem.Semantics.Presheaf.Path`
remains the complete covering check — the module is still unimported.

**Files to modify**:
- `FormalSystem/Semantics/Presheaf/Path.lean` - add `iter_of_adjacent_window`, `Beh.ofAdjacentWindow`, its reading lemma, `beh_int_iff_adjacent_window`

**Verification**:
- Guarded scoped build exits 0 with no `sorry` warning
- `#print axioms` on `beh_int_iff_adjacent_window` reports `[propext, Quot.sound]` and no
  `Classical.choice`
- Commit: `task 618 phase 6: D = Z layer 1, sections over a window are the adjacency-respecting functions`

---

### Phase 7: `D = ℤ`, layer 2a — sections to paths in the one-step graph [NOT STARTED]

**Goal**: Carry the one-step quiver on a synonym `StepGraph F`, define `toPath` from a
`PathHom F.toTaskFrame w u` to a `Quiver.Path w u` by peeling the last step, and prove its
length, identity, and composition laws — "sections are paths" and "gluing is concatenation".

**Tasks**:
- [ ] Define `def StepGraph (F : FrameOver intOrder) : Type := F.WorldState` and
      `instance StepGraph.instQuiver F : Quiver (StepGraph F) := ⟨fun a b => PLift (FrameOver.step F a b)⟩`
      (`Quiver.Hom` is `Type v`-valued in this Mathlib, so the `Prop`-valued `step` is lifted;
      `PLift` of a `Prop` is a `Subsingleton`, so path equality is unaffected by proof terms), and
      `abbrev StepPath F (w u : F.WorldState) : Type := Quiver.Path (V := StepGraph F) w u`. Record in
      the docstring that the synonym exists so that no `Quiver` instance is placed on
      `F.WorldState` (the plan-time compile showed a bare `def`-valued quiver is not found by
      instance synthesis)
- [ ] Define `PathHom.toPathAux F (n : ℕ) (e : PathHom F.toTaskFrame w u) (hn : (n : ℤ) = e.len.val) : StepPath F w u`
      by recursion on `n`: at `0`, `w = u` from `src`/`tgt` and `Quiver.Path.nil` transported along
      that equality; at `n+1`, `Quiver.Path.cons (toPathAux n (restriction of e to [0, n]) _) ⟨step at (n, n+1)⟩`
      with the restriction a `PathHom` built from `Beh.restrict 0 n` and the step from
      `respects_task` at `(n, n+1)`
- [ ] Define `PathHom.toPath F e := toPathAux F (Int.toNat e.len.val) e (Int.toNat_of_nonneg e.len.property)`
- [ ] Prove `toPath_length : (toPath F e).length = Int.toNat e.len.val` (by `toPathAux`
      induction, `Quiver.Path.length_cons`), `toPath_id : toPath F (PathHom.id F.toTaskFrame w) = Quiver.Path.nil`
      (length `0`), and `toPath_comp : toPath F (PathHom.comp (TaskFrame.comp F.toTaskFrame) f g) = (toPath F f).comp (toPath F g)`
      (induction on `g`'s length via `toPathAux`; `Int.toNat_add` on the two nonnegative lengths;
      `Quiver.Path.comp_cons`; a `castLen` at every peeled step, compared at `.val`)
- [ ] Docstrings: `Constraints consumed: None` on `StepGraph`, `StepGraph.instQuiver`;
      `Constraints consumed: Compositionality, Seriality, Limit` on the `toPath*` family (they take
      `[F.IsRegular]`)
- [ ] Record the issue log as events arise — in particular any divergence from the recursion shape
      above, since this is the phase the report flags as the largest risk

**Timing**: 1.5 hours

**Depends on**: 6

**Verification Tier**: local

**Scope Hypothesis**: Eight further declarations (`StepGraph`, its instance, `StepPath`,
`toPathAux`, `toPath`, three lemmas), fifty in total; confirm with the Phase 1 grep, expecting
50.

**Tier Justification**: The same guarded scoped build of `FormalSystem.Semantics.Presheaf.Path`
remains the complete covering check — the module is still unimported.

**Files to modify**:
- `FormalSystem/Semantics/Presheaf/Path.lean` - add `StepGraph`, its `Quiver` instance, `StepPath`, `toPathAux`, `toPath`, `toPath_length`, `toPath_id`, `toPath_comp`

**Verification**:
- Guarded scoped build exits 0 with no `sorry` warning
- `#print axioms` on `toPath_comp` reports `[propext, Quot.sound]` and no `Classical.choice`
  (`Int.toNat` arithmetic must stay off `omega`-introduced choice; if a lemma pulls it, replace the
  arithmetic step with the named `Int.toNat_*` lemma)
- Commit: `task 618 phase 7: D = Z layer 2a, sections to paths in the one-step graph`

---

### Phase 8: `D = ℤ`, layer 2b — paths to sections, the round trips, the free category [NOT STARTED]

**Goal**: Define the inverse `ofPath` by `Quiver.Path.rec` (nil to the germ, cons to a composite
with a one-step hom), prove both round trips, and package `pathEquiv : PathHom F.toTaskFrame w u ≃ StepPath F w u`
— with Phase 7's `toPath_id`/`toPath_comp` this is "`Path(F)` is the free category on
`(W, ⇒₁)`", matching Mathlib's `CategoryTheory.Paths.categoryPaths` (`Hom := Quiver.Path`,
`id := nil`, `comp := Path.comp`) without importing it.

**Tasks**:
- [ ] Define `PathHom.ofStep F (h : FrameOver.step F w u) : PathHom F.toTaskFrame w u` of length
      `1`: a two-point section on `[0, 1]` with `respects_task` from `h` (forward), `nullity`
      (same point) and `reflection_int` (backward), all choice-free
- [ ] Define `PathHom.ofPath F : StepPath F w u → PathHom F.toTaskFrame w u` by `Quiver.Path.rec`:
      `nil ↦ PathHom.id F.toTaskFrame w`, `cons p ⟨h⟩ ↦ PathHom.comp (TaskFrame.comp F.toTaskFrame) (ofPath p) (ofStep F h)`
- [ ] Prove `toPath_ofPath : toPath F (ofPath F p) = p` by induction on `p`, using `toPath_id`,
      `toPath_comp`, and `toPath (ofStep F h) = Path.cons nil ⟨h⟩` (length `1`,
      `Subsingleton.elim` on the `PLift` proof)
- [ ] Prove `ofPath_toPath : ofPath F (toPath F e) = e` by `toPathAux` induction and `ext'`:
      the length half is `Int.toNat_of_nonneg`; the section half by `glue_unique` with the
      restriction identities, comparing at `.val`
- [ ] Define `PathHom.pathEquiv F w u` with `toFun := toPath F`, `invFun := ofPath F`, the two
      round trips — by analogy with `Beh.germEquiv` and `Beh.reflectEquiv`
- [ ] Add to the module docstring's `## Main Results` the `D = ℤ` paragraph: the sections of
      `Beh F` over `n` are the paths of length `n` in `(W, ⇒₁)` (`beh_int_iff_adjacent_window`,
      `pathEquiv`, `toPath_length`), gluing is concatenation (`toPath_comp`), identities are the
      empty paths (`toPath_id`), so `Path(F)` is the free category on that graph; cite
      `CategoryTheory.Paths.categoryPaths` as the definition this matches and
      `specs/archive/718_omega_sequence_decidability_full_lplus/reports/01_gluing-route-seed.md` §3
      is NOT cited (task artifact; the connection to the root-path presentation is stated in the
      prose of `Presheaf/README.md` instead, Phase 9)
- [ ] Measure `#print axioms` on `pathEquiv`, `len_isDiscreteConduche`, `assocRestrict_unique`,
      `comp_assoc`, `beh_int_iff_adjacent_window` and record the measured profile in the module
      docstring's `## Implementation Notes` ("Measured axiom profile", as `Reflection.lean` does)
- [ ] Docstrings: `Constraints consumed: Compositionality, Seriality, Limit` on every declaration
      of this phase
- [ ] Record the issue log as events arise

**Timing**: 1.25 hours

**Depends on**: 7

**Verification Tier**: local

**Scope Hypothesis**: Five further declarations, fifty-five in total; confirm with the Phase 1
grep, expecting 55. The challenge-statement identifier set in `## Lean Challenge Statements`
below (52 `theorem`/`def`/`instance` identifiers; the two `structure`s and the `abbrev` are not
counted by the tool) must equal the `**Goals**:` list — confirm with
`bash .claude/scripts/lean-challenge-snapshot.sh --check 618 /home/benjamin/Projects/BimodalLogic`
if a Challenge module has been snapshotted for this task, else by eye.

**Tier Justification**: The same guarded scoped build of `FormalSystem.Semantics.Presheaf.Path`
remains the complete covering check — the module is still unimported until Phase 9.

**Files to modify**:
- `FormalSystem/Semantics/Presheaf/Path.lean` - add `ofStep`, `ofPath`, the two round trips, `pathEquiv`; `## Main Results` `D = ℤ` paragraph and the measured axiom record

**Verification**:
- Guarded scoped build exits 0 with no `sorry` warning
- `#print axioms` on the five declarations named above each reports `[propext, Quot.sound]` and
  no `Classical.choice`
- The `assert_not_exists` lock still passes
- Commit: `task 618 phase 8: D = Z layer 2b, paths to sections and the free category`

---

### Phase 9: Wiring, records, reconciliation notes, and the full gate [NOT STARTED]

**Goal**: Make the module part of the cluster and of the record of the paper: the aggregator
import and module bullet, the library root, the README inventory row and prose, the
paper-definitions-of-record rows, the reconciliation pointers in the sibling modules, the
generated status counts, then the complete gate set and a green `lake build FormalSystem`.

**Tasks**:
- [ ] **Aggregator and library root (shared touches — handle last among the edits, per the task's
      SCOPE AND AGGREGATOR CONTENTION note)**: re-read `FormalSystem/Semantics/Presheaf.lean`
      immediately beforehand; add `import FormalSystem.Semantics.Presheaf.Path` in alphabetical
      position and a `- \`Presheaf.Path\` — ...` bullet to its `## Modules` list; regenerate the
      library root with `lake exe mk_all --lib FormalSystem` (C33) and confirm the diff is the one
      new import line; check `git log -1 -- FormalSystem/Semantics/Presheaf.lean FormalSystem.lean`
      and `git status --short` for a foreign in-flight edit first and STOP and report if one is
      found
- [ ] `FormalSystem/Semantics/Presheaf/README.md`: add a prose section on `Path(F)` and
      `cor:path-fibration` (what it says; that the fibration property and the equality of the
      associated presheaf with `Beh F` are proved for the instance while Johnstone's general
      equivalence is cited and external; the `D = ℤ` clause as the free category on `(W, ⇒₁)` and
      its bearing on the decidability route's root-path presentation; the constraint footprint);
      update the "nine modules" / "all nine modules close with `assert_not_exists`" sentences to
      ten and the first paragraph's import description to include `Path.lean`'s two Mathlib
      imports; add `PathHom`, `PathCat`, `PathCat.len`, `IsDiscreteConduche`, `pathEquiv` to
      `## Key Definitions`; add a recorded verdict "Sum-form gluing is cut-form gluing under a
      val-preserving cast" (the report's first Context Extension Recommendation) and a second
      "`Mathlib.CategoryTheory` enters the cluster synonym-scoped, in `Path.lean` only"; regenerate
      the inventory table with `bash scripts/check-module-invariants.sh --emit-inventory` (after
      `--emit-inventory --check` to see the delta)
- [ ] `docs/reference/paper-definitions-of-record.md`: rewrite the `cor:path-fibration` row's
      "NO Path(F) exists in the tree" clause as FORMALIZED (`PathHom`/`PathCat`/`PathCat.len`,
      `PathCat.len_isDiscreteConduche`, `PathHom.assocRestrict_sec`, `beh_int_iff_adjacent_window`,
      `PathHom.pathEquiv` in `FormalSystem/Semantics/Presheaf/Path.lean`; the general equivalence
      cited only), and update its citation-site sentence (`ShiftFiniteType.lean` now also points
      to the module); finish the FORMALIZED clauses of the three Phase 1 rows with the final
      declaration names — hand edit, no re-pin, the anchors remain unpinnable
- [ ] `FormalSystem/Semantics/ShiftFiniteType.lean` (docstring lines 75-80): replace "no
      `Path(F)` exists in this tree" with a pointer to `Presheaf/Path.lean`'s `PathCat` and
      `PathHom.pathEquiv`, keeping the clause described rather than cited as an authority
- [ ] One-sentence forward pointers, Implementation Notes only: `Presheaf/Site.lean`,
      `Presheaf/Duration.lean`, `Presheaf/Reflection.lean` — "weighed and adopted,
      synonym-scoped, in `Presheaf/Path.lean`; see its Implementation Notes" after each "no
      `Mathlib.CategoryTheory`" note; `Presheaf/Sheaf.lean` — the sum form "buys nothing" note
      gains "for the Sheaf clause; `Presheaf/Path.lean`'s `glueSum` is that form, as a
      val-preserving cast of `glue`, where composition in `Path(F)` consumes it"
- [ ] Count/list lines in `FormalSystem/README.md` and `FormalSystem/Semantics/README.md`
      (`Presheaf/` row: "(9 files)" becomes 10 and the list gains `Path`); regenerate
      `typst/generated/status.typ` via the sanctioned generator (`bash scripts/typst-status-counts.sh`,
      or `typst-sync-check.sh --fix` as 617 did) — **this file is in sibling 782's declared
      `file_scope` this cycle**: `git status --short typst/generated/status.typ` first; if a foreign
      uncommitted modification is present, STOP and report rather than regenerate over it
- [ ] Record the issue log as events arise; attest explicitly if nothing arose
- [ ] Run the complete gate set (below); fix forward on any failure — never discard uncommitted
      work to reach green

**Timing**: 1.5 hours

**Depends on**: 8

**Verification Tier**: full

**Scope Hypothesis**: Nine files edited plus the two shared touches; the record file's
"remaining seven of the twelve" paragraph and the `cor:path-fibration` row text are carried from
a plan-time read (lines 991-1004 and 2528) — confirm by re-reading before editing, since sibling
tasks on this front edit the same rows; the README's "nine modules" count is carried from a
plan-time read of its first paragraph.

**Files to modify**:
- `FormalSystem/Semantics/Presheaf/README.md` - `Path(F)` prose, counts, Key Definitions, two recorded verdicts, regenerated inventory row
- `docs/reference/paper-definitions-of-record.md` - `cor:path-fibration` row FORMALIZED; the three Phase 1 rows' FORMALIZED clauses finalized
- `FormalSystem/Semantics/ShiftFiniteType.lean` - docstring pointer replacing "no `Path(F)` exists in this tree"
- `FormalSystem/Semantics/Presheaf/Site.lean` - one-sentence Implementation Notes pointer
- `FormalSystem/Semantics/Presheaf/Duration.lean` - one-sentence Implementation Notes pointer
- `FormalSystem/Semantics/Presheaf/Reflection.lean` - one-sentence Implementation Notes pointer
- `FormalSystem/Semantics/Presheaf/Sheaf.lean` - one-sentence Implementation Notes pointer reconciling the sum-form note
- `FormalSystem/README.md` - module count line
- `FormalSystem/Semantics/README.md` - `Presheaf/` row count and list
- `FormalSystem/Semantics/Presheaf/Path.lean` - final docstring touch-ups only, if the gate demands any
- Shared touches deliberately not listed as path entries, per the task description's instruction not to widen `file_scope` to the cluster aggregator: the one-line import and module bullet in FormalSystem/Semantics/Presheaf.lean, the regenerated library root FormalSystem.lean, and the regenerated typst/generated/status.typ (handled with the re-read / own-hunk-only / rebuild / STOP-on-foreign-edit discipline named in the Tasks)

**Verification** (the complete gate set — `full` tier, nothing deferred unless the dispatch file
carries a `## Batch Gate Deferral` section, in which case record the deferral in this phase's
notes exactly as 617 phase 3 did):
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem` exits 0;
  `bash .claude/scripts/lean-sorry-census.sh` (or `grep -rn "sorry" FormalSystem/Semantics/Presheaf/Path.lean`)
  shows no new sorry
- `#print axioms` sweep over every declaration named under `**Goals**:` reports no
  `Classical.choice`
- `bash scripts/check-module-invariants.sh` exits 0 (C15: every anchor cited resolves; C23: no
  underscore-suffixed shadow of a live declaration; C24: the new module is in the root closure
  through the aggregator; C33: the library root is byte-current; C34: every
  `Constraints consumed:` marker is well-formed; `--emit-inventory --check` is byte-stable)
- `bash scripts/check-paper-definitions.sh`: the four cut anchors remain `DANGLING` rows, no pin
  attempted; a non-zero exit attributable only to the pre-existing pinned-row drift 617 recorded
  is noted as pre-existing, with the failing rows compared against `git show HEAD:` of the record
- `bash .claude/scripts/verify-deploy.sh` exits 0 (the repository's complete gate set, every gate
  — no `--only-gate`, no `--skip-slow`)
- `bash .claude/scripts/check-task-references.sh` (or the task-reference gate of `verify-deploy.sh`)
  reports no task-number citation in `FormalSystem/**` or `docs/**` from this task
- Commit: `task 618 phase 9: wiring, records, reconciliation notes, and the full gate`, staged by
  explicit file list (`git add -- <files>`), never a directory or glob

## Lean Challenge Statements

The block below was compiled at plan authoring with `lake env lean` against the built tree
(saved as `specs/618_path_category_and_conduche_fibration/challenge-statements-probe.lean`) and
exits 0 with only `declaration uses 'sorry'` warnings. Two declarations carry real `where`
bodies rather than `sorry`: `BObj.instCategory` and `PathCat.instCategory`. This is necessary,
not decorative — `PathCat.len_map`, `IsDiscreteConduche` and `PathCat.len_isDiscreteConduche`
typecheck only when the hom-sets of `BObj D` and `PathCat F` are definitionally `Dur D` and
`PathHom F w u`. The snapshot tool forces bodies to `sorry` on assembly; the consequence for its
assembled module is recorded in Risks & Mitigations and is a tooling finding, not a statement
defect. The two `structure`s and the `abbrev` are not counted by the tool's identifier regex and
are therefore absent from `**Goals**:`.

```lean
import Mathlib.CategoryTheory.Functor.Basic
import Mathlib.Combinatorics.Quiver.Path
import FormalSystem.Semantics.Presheaf.Sheaf
import FormalSystem.Semantics.Presheaf.Duration
import FormalSystem.Semantics.IntNormalFormEffective

namespace FormalSystem.Semantics.Presheaf

open CategoryTheory

variable {F : TaskFrame}

-- Phase 1: the cast kit and sum-form gluing

def Beh.castLen {l l' : F.Duration} (h : l = l') (τ : Beh F l) : Beh F l' := sorry

@[simp] theorem Beh.castLen_val {l l' : F.Duration} (h : l = l') (τ : Beh F l) :
    (Beh.castLen h τ).val = τ.val := sorry

theorem Beh.castLen_eq_iff {l l' : F.Duration} (h : l = l') (τ : Beh F l) (σ : Beh F l') :
    Beh.castLen h τ = σ ↔ τ.val = σ.val := sorry

def glueSum (hcomp : TaskFrame.Compositional F.TaskRel) {l₁ l₂ : F.Duration}
    (h₁ : 0 ≤ l₁) (h₂ : 0 ≤ l₂) (τ₁ : Beh F l₁) (τ₂ : Beh F l₂)
    (hmatch : τ₁.val.states l₁ (Beh.mem_dom τ₁ h₁ le_rfl)
      = τ₂.val.states 0 (Beh.mem_dom τ₂ le_rfl h₂)) : Beh F (l₁ + l₂) := sorry

theorem glueSum_restrict_left (hcomp : TaskFrame.Compositional F.TaskRel) {l₁ l₂ : F.Duration}
    (h₁ : 0 ≤ l₁) (h₂ : 0 ≤ l₂) (τ₁ : Beh F l₁) (τ₂ : Beh F l₂)
    (hmatch : τ₁.val.states l₁ (Beh.mem_dom τ₁ h₁ le_rfl)
      = τ₂.val.states 0 (Beh.mem_dom τ₂ le_rfl h₂)) :
    Beh.restrict 0 l₁ le_rfl h₁ (by rw [zero_add]; exact le_add_of_nonneg_right h₂)
      (glueSum hcomp h₁ h₂ τ₁ τ₂ hmatch) = τ₁ := sorry

theorem glueSum_restrict_right (hcomp : TaskFrame.Compositional F.TaskRel) {l₁ l₂ : F.Duration}
    (h₁ : 0 ≤ l₁) (h₂ : 0 ≤ l₂) (τ₁ : Beh F l₁) (τ₂ : Beh F l₂)
    (hmatch : τ₁.val.states l₁ (Beh.mem_dom τ₁ h₁ le_rfl)
      = τ₂.val.states 0 (Beh.mem_dom τ₂ le_rfl h₂)) :
    Beh.restrict l₁ l₂ h₁ h₂ le_rfl (glueSum hcomp h₁ h₂ τ₁ τ₂ hmatch) = τ₂ := sorry

theorem glueSum_states_zero (hcomp : TaskFrame.Compositional F.TaskRel) {l₁ l₂ : F.Duration}
    (h₁ : 0 ≤ l₁) (h₂ : 0 ≤ l₂) (τ₁ : Beh F l₁) (τ₂ : Beh F l₂)
    (hmatch : τ₁.val.states l₁ (Beh.mem_dom τ₁ h₁ le_rfl)
      = τ₂.val.states 0 (Beh.mem_dom τ₂ le_rfl h₂)) :
    (glueSum hcomp h₁ h₂ τ₁ τ₂ hmatch).val.states 0
        (Beh.mem_dom _ le_rfl (add_nonneg h₁ h₂))
      = τ₁.val.states 0 (Beh.mem_dom τ₁ le_rfl h₁) := sorry

theorem glueSum_states_end (hcomp : TaskFrame.Compositional F.TaskRel) {l₁ l₂ : F.Duration}
    (h₁ : 0 ≤ l₁) (h₂ : 0 ≤ l₂) (τ₁ : Beh F l₁) (τ₂ : Beh F l₂)
    (hmatch : τ₁.val.states l₁ (Beh.mem_dom τ₁ h₁ le_rfl)
      = τ₂.val.states 0 (Beh.mem_dom τ₂ le_rfl h₂)) :
    (glueSum hcomp h₁ h₂ τ₁ τ₂ hmatch).val.states (l₁ + l₂)
        (Beh.mem_dom _ (add_nonneg h₁ h₂) le_rfl)
      = τ₂.val.states l₂ (Beh.mem_dom τ₂ h₂ le_rfl) := sorry

-- Phase 2: the hom structure, identities, composition, unit laws, the one-object category

structure PathHom (F : TaskFrame) (w u : F.WorldState) where
  len : Dur F.Duration
  sec : Beh F len.val
  src : sec.val.states 0 (Beh.mem_dom sec le_rfl len.property) = w
  tgt : sec.val.states len.val (Beh.mem_dom sec len.property le_rfl) = u

theorem PathHom.ext' {w u : F.WorldState} {f g : PathHom F w u} (hl : f.len = g.len)
    (hs : f.sec.val = g.sec.val) : f = g := sorry

def PathHom.id (F : TaskFrame) [F.IsRegular] (w : F.WorldState) : PathHom F w w := sorry

def PathHom.comp (hcomp : TaskFrame.Compositional F.TaskRel) {w u v : F.WorldState}
    (f : PathHom F w u) (g : PathHom F u v) : PathHom F w v := sorry

@[simp] theorem PathHom.comp_len (hcomp : TaskFrame.Compositional F.TaskRel)
    {w u v : F.WorldState} (f : PathHom F w u) (g : PathHom F u v) :
    (PathHom.comp hcomp f g).len = Dur.comp f.len g.len := sorry

@[simp] theorem PathHom.id_len (F : TaskFrame) [F.IsRegular] (w : F.WorldState) :
    (PathHom.id F w).len = Dur.id := sorry

theorem PathHom.id_comp [F.IsRegular] {w u : F.WorldState} (f : PathHom F w u) :
    PathHom.comp F.comp (PathHom.id F w) f = f := sorry

theorem PathHom.comp_id [F.IsRegular] {w u : F.WorldState} (f : PathHom F w u) :
    PathHom.comp F.comp f (PathHom.id F u) = f := sorry

structure BObj (D : TemporalOrder) where
  unit : Unit

instance BObj.instCategory (D : TemporalOrder) : Category (BObj D) where
  Hom _ _ := Dur D
  id _ := Dur.id
  comp f g := Dur.comp f g
  id_comp := Dur.id_comp
  comp_id := Dur.comp_id
  assoc := Dur.comp_assoc

-- Phase 3: associativity, the path category, the length functor

theorem PathHom.comp_assoc (hcomp : TaskFrame.Compositional F.TaskRel)
    {w u v x : F.WorldState} (f : PathHom F w u) (g : PathHom F u v) (h : PathHom F v x) :
    PathHom.comp hcomp (PathHom.comp hcomp f g) h
      = PathHom.comp hcomp f (PathHom.comp hcomp g h) := sorry

def PathCat (F : TaskFrame) : Type := F.WorldState

instance PathCat.instCategory (F : TaskFrame) [F.IsRegular] : Category (PathCat F) where
  Hom w u := PathHom F w u
  id w := PathHom.id F w
  comp f g := PathHom.comp F.comp f g
  id_comp f := PathHom.id_comp f
  comp_id f := PathHom.comp_id f
  assoc f g h := PathHom.comp_assoc F.comp f g h

def PathCat.len (F : TaskFrame) [F.IsRegular] : PathCat F ⥤ BObj F.Duration := sorry

theorem PathCat.len_map (F : TaskFrame) [F.IsRegular] {w u : PathCat F} (f : w ⟶ u) :
    (PathCat.len F).map f = PathHom.len f := sorry

-- Phase 4: the discrete Conduché fibration property of `len`

def IsDiscreteConduche {D : TemporalOrder} {E : Type*} [Category E] (P : E ⥤ BObj D) : Prop :=
  ∀ {A B : E} (e : A ⟶ B) (fac : Factorization (P.map e)),
    ∃! t : Σ C : E, (A ⟶ C) × (C ⟶ B),
      t.2.1 ≫ t.2.2 = e ∧ (P.map t.2.1).val = fac.fst ∧ (P.map t.2.2).val = fac.snd

def PathHom.cutState {w u : F.WorldState} (e : PathHom F w u) (fac : Factorization e.len) :
    F.WorldState := sorry

def PathHom.factorLeft {w u : F.WorldState} (e : PathHom F w u) (fac : Factorization e.len) :
    PathHom F w (e.cutState fac) := sorry

def PathHom.factorRight {w u : F.WorldState} (e : PathHom F w u) (fac : Factorization e.len) :
    PathHom F (e.cutState fac) u := sorry

@[simp] theorem PathHom.factorLeft_len {w u : F.WorldState} (e : PathHom F w u)
    (fac : Factorization e.len) : (e.factorLeft fac).len.val = fac.fst := sorry

@[simp] theorem PathHom.factorRight_len {w u : F.WorldState} (e : PathHom F w u)
    (fac : Factorization e.len) : (e.factorRight fac).len.val = fac.snd := sorry

theorem PathHom.factor_comp (hcomp : TaskFrame.Compositional F.TaskRel) {w u : F.WorldState}
    (e : PathHom F w u) (fac : Factorization e.len) :
    PathHom.comp hcomp (e.factorLeft fac) (e.factorRight fac) = e := sorry

theorem PathHom.factor_unique (hcomp : TaskFrame.Compositional F.TaskRel) {w u : F.WorldState}
    (e : PathHom F w u) (fac : Factorization e.len) {c : F.WorldState}
    (e₁ : PathHom F w c) (e₂ : PathHom F c u) (h : PathHom.comp hcomp e₁ e₂ = e)
    (h₁ : e₁.len.val = fac.fst) (h₂ : e₂.len.val = fac.snd) :
    c = e.cutState fac ∧ e₁.sec.val = (e.factorLeft fac).sec.val
      ∧ e₂.sec.val = (e.factorRight fac).sec.val := sorry

theorem PathCat.len_isDiscreteConduche (F : TaskFrame) [F.IsRegular] :
    IsDiscreteConduche (PathCat.len F) := sorry

-- Phase 5: the associated presheaf of `len` is `Beh F`, as an equality

def PathHom.assocRestrict {w u : F.WorldState} {l' l : Obj F.Duration} (f : Tr l' l)
    (e : PathHom F w u) (hl : e.len = l) : Σ c c' : F.WorldState, PathHom F c c' := sorry

theorem PathHom.assocRestrict_len {w u : F.WorldState} {l' l : Obj F.Duration} (f : Tr l' l)
    (e : PathHom F w u) (hl : e.len = l) :
    (PathHom.assocRestrict f e hl).2.2.len = l' := sorry

theorem PathHom.assocRestrict_sec {w u : F.WorldState} {l' l : Obj F.Duration} (f : Tr l' l)
    (e : PathHom F w u) (hl : e.len = l) :
    (PathHom.assocRestrict f e hl).2.2.sec.val
      = (Beh.restrictTr f (Beh.castLen (congrArg Subtype.val hl) e.sec)).val := sorry

theorem PathHom.assocRestrict_unique (hcomp : TaskFrame.Compositional F.TaskRel)
    {w u : F.WorldState} {l' l : Obj F.Duration} (f : Tr l' l) (e : PathHom F w u)
    (hl : e.len = l) {c c' : F.WorldState} (e₁ : PathHom F w c) (e₂ : PathHom F c c')
    (e₃ : PathHom F c' u) (h : PathHom.comp hcomp (PathHom.comp hcomp e₁ e₂) e₃ = e)
    (h₁ : e₁.len.val = f.shift) (h₂ : e₂.len.val = l'.val) :
    e₂.sec.val = (PathHom.assocRestrict f e hl).2.2.sec.val := sorry

theorem PathHom.assocRestrict_id {w u : F.WorldState} (e : PathHom F w u) :
    (PathHom.assocRestrict (Tr.id e.len) e rfl).2.2.sec.val = e.sec.val := sorry

theorem PathHom.assocRestrict_comp {w u : F.WorldState} {l'' l' l : Obj F.Duration}
    (f : Tr l' l) (g : Tr l'' l') (e : PathHom F w u) (hl : e.len = l) :
    (PathHom.assocRestrict g (PathHom.assocRestrict f e hl).2.2
        (PathHom.assocRestrict_len f e hl)).2.2.sec.val
      = (PathHom.assocRestrict (Tr.comp f g) e hl).2.2.sec.val := sorry

-- Phase 6: `D = ℤ`, layer 1 — sections over `[0, n]` are the adjacency-respecting windows

theorem iter_of_adjacent_window (F : FrameOver intOrder) (n : ℤ) (g : ℤ → F.WorldState)
    (hg : ∀ i, 0 ≤ i → i < n → FrameOver.step F (g i) (g (i + 1)))
    (s t : ℤ) (hs : 0 ≤ s) (hst : s ≤ t) (htn : t ≤ n) :
    iter (FrameOver.step F) (Int.toNat (t - s)) (g s) (g t) := sorry

def Beh.ofAdjacentWindow (F : FrameOver intOrder) [F.IsRegular] (n : ℤ) (hn : 0 ≤ n)
    (g : ℤ → F.WorldState) (hg : ∀ i, 0 ≤ i → i < n → FrameOver.step F (g i) (g (i + 1))) :
    Beh F.toTaskFrame n := sorry

theorem Beh.ofAdjacentWindow_states (F : FrameOver intOrder) [F.IsRegular] (n : ℤ) (hn : 0 ≤ n)
    (g : ℤ → F.WorldState) (hg : ∀ i, 0 ≤ i → i < n → FrameOver.step F (g i) (g (i + 1)))
    (i : ℤ) (hi : (Beh.ofAdjacentWindow F n hn g hg).val.domain i) :
    (Beh.ofAdjacentWindow F n hn g hg).val.states i hi = g i := sorry

theorem beh_int_iff_adjacent_window (F : FrameOver intOrder) [F.IsRegular] (n : ℤ) (hn : 0 ≤ n)
    (g : ℤ → F.WorldState) :
    (∃ τ : Beh F.toTaskFrame n, ∀ i (hi : τ.val.domain i), τ.val.states i hi = g i)
      ↔ ∀ i, 0 ≤ i → i < n → FrameOver.step F (g i) (g (i + 1)) := sorry

-- Phase 7: `D = ℤ`, layer 2a — sections to paths in the one-step graph

def StepGraph (F : FrameOver intOrder) : Type := F.WorldState

instance StepGraph.instQuiver (F : FrameOver intOrder) : Quiver (StepGraph F) :=
  ⟨fun a b => PLift (FrameOver.step F a b)⟩

abbrev StepPath (F : FrameOver intOrder) (w u : F.WorldState) : Type :=
  Quiver.Path (V := StepGraph F) w u

def PathHom.toPathAux (F : FrameOver intOrder) [F.IsRegular] (n : ℕ) {w u : F.WorldState}
    (e : PathHom F.toTaskFrame w u) (hn : (n : ℤ) = e.len.val) : StepPath F w u := sorry

def PathHom.toPath (F : FrameOver intOrder) [F.IsRegular] {w u : F.WorldState}
    (e : PathHom F.toTaskFrame w u) : StepPath F w u := sorry

theorem PathHom.toPath_length (F : FrameOver intOrder) [F.IsRegular] {w u : F.WorldState}
    (e : PathHom F.toTaskFrame w u) :
    (PathHom.toPath F e).length = Int.toNat e.len.val := sorry

theorem PathHom.toPath_id (F : FrameOver intOrder) [F.IsRegular] (w : F.WorldState) :
    PathHom.toPath F (PathHom.id F.toTaskFrame w) = Quiver.Path.nil := sorry

theorem PathHom.toPath_comp (F : FrameOver intOrder) [F.IsRegular] {w u v : F.WorldState}
    (f : PathHom F.toTaskFrame w u) (g : PathHom F.toTaskFrame u v) :
    PathHom.toPath F (PathHom.comp (TaskFrame.comp F.toTaskFrame) f g)
      = (PathHom.toPath F f).comp (PathHom.toPath F g) := sorry

-- Phase 8: `D = ℤ`, layer 2b — paths to sections, the round trips, the free category

def PathHom.ofStep (F : FrameOver intOrder) [F.IsRegular] {w u : F.WorldState}
    (h : FrameOver.step F w u) : PathHom F.toTaskFrame w u := sorry

def PathHom.ofPath (F : FrameOver intOrder) [F.IsRegular] {w u : F.WorldState}
    (p : StepPath F w u) : PathHom F.toTaskFrame w u := sorry

theorem PathHom.ofPath_toPath (F : FrameOver intOrder) [F.IsRegular] {w u : F.WorldState}
    (e : PathHom F.toTaskFrame w u) : PathHom.ofPath F (PathHom.toPath F e) = e := sorry

theorem PathHom.toPath_ofPath (F : FrameOver intOrder) [F.IsRegular] {w u : F.WorldState}
    (p : StepPath F w u) : PathHom.toPath F (PathHom.ofPath F p) = p := sorry

def PathHom.pathEquiv (F : FrameOver intOrder) [F.IsRegular] (w u : F.WorldState) :
    PathHom F.toTaskFrame w u ≃ StepPath F w u := sorry

end FormalSystem.Semantics.Presheaf
```

## Testing & Validation

- [ ] Phases 1-8: guarded scoped build of `FormalSystem.Semantics.Presheaf.Path` green, no sorry,
      `assert_not_exists` lock passes; Phase 1 additionally `check-module-invariants.sh --no-build`
      C15 PASS
- [ ] Phases 2-8: the named `#print axioms` targets each `[propext, Quot.sound]`, never
      `Classical.choice`; Phase 8 records the measured profile in the module docstring
- [ ] Phase 5: `PathHom.assocRestrict_sec` closes by `rfl`
- [ ] Phase 9: `lake build FormalSystem` green through the guard; `check-module-invariants.sh`,
      `verify-deploy.sh`, `check-task-references.sh` all exit 0; `check-paper-definitions.sh`'s
      exit, if non-zero, is attributable only to the pre-existing pinned-row drift
- [ ] The `**Goals**:` identifier list and the `## Lean Challenge Statements`
      `theorem`/`def`/`instance` declaration set are identical (fifty-two identifiers)
- [ ] The HARD SCOPE LIMIT is visible: `grep -n "fact:conduche-equivalence" FormalSystem/Semantics/Presheaf/Path.lean`
      hits only docstring text that says "cited" / "external", and no declaration constructs a
      category from an arbitrary sheaf or a presheaf from an arbitrary fibration
- [ ] No `Category`/`Quiver` instance on a cluster type:
      `grep -n "^instance" FormalSystem/Semantics/Presheaf/Path.lean` shows exactly three
      instances, on `BObj D`, `PathCat F`, `StepGraph F`
- [ ] No task-number reference in any file outside `specs/**`

## Artifacts & Outputs

- `FormalSystem/Semantics/Presheaf/Path.lean` — the new module (fifty-five declarations)
- `FormalSystem/Semantics/Presheaf.lean` — one import line and one module bullet (shared touch)
- `FormalSystem.lean` — regenerated library root, one new import (shared touch)
- `FormalSystem/Semantics/Presheaf/README.md` — `Path(F)` prose, two recorded verdicts, inventory row, key definitions
- `docs/reference/paper-definitions-of-record.md` — three new `DANGLING` rows and one rewritten row
- `FormalSystem/Semantics/ShiftFiniteType.lean`, `Presheaf/{Site,Duration,Reflection,Sheaf}.lean` — one-sentence docstring pointers each
- `FormalSystem/README.md`, `FormalSystem/Semantics/README.md`, `typst/generated/status.typ` — count lines / regenerated
- `specs/618_path_category_and_conduche_fibration/challenge-statements-probe.lean` — the compiled Challenge block (plan-time, already written)
- `specs/618_path_category_and_conduche_fibration/summaries/01_path-category-conduche-fibration-summary.md`
  — written at implementation completion

## Rollback/Contingency

Each phase closes with exactly one commit and each sub-step is committed green, so a failed phase
is isolated by construction. Phases 1-8 touch an unimported module (plus, in Phase 1, three
additive record rows), so an unfinished phase leaves `lake build FormalSystem` green regardless;
Phase 8 may close `[PARTIAL]` with `pathEquiv` outstanding if the round trips resist, since
Phase 7's laws already carry the two `D = ℤ` sentences. If the Phase 9 full gate cannot be made
green by fixing forward, the module can be left out of the aggregator and library root (reverting
only the one import line in each by an ordinary edit) so the rest of the tree builds while the
module is repaired, and the phase stays `[PARTIAL]`. If uncommitted work must actually be
discarded, follow `context/contracts/recovery.md`'s rollback rung:
`bash .claude/scripts/git-snapshot.sh 618` first (with `--allow-out-of-scope` only for the
deliberate whole-tree case), then the destructive command; never a bare
`git checkout --`/`git reset --hard` on a dirty tree, and never a precautionary default-mode
snapshot at the start of a phase (`--no-revert` is the durable checkpoint form).
