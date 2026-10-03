# Implementation Plan: Task #564 — the Sheaf clause and the seam-argument de-duplication

- **Task**: 564 - sheaf_clause_gluing_and_starpasting_generalization
- **Status**: [NOT STARTED]
- **Effort**: 5 hours
- **Dependencies**: None (563 is `[COMPLETED]`; `Presheaf/{Site,Behavior}.lean` are on the tree)
- **Research Inputs**: `specs/564_sheaf_clause_gluing_and_starpasting_generalization/reports/02_sheaf-clause-and-seam-dedup.md`, `specs/564_sheaf_clause_gluing_and_starpasting_generalization/reports/01_finite-vs-directed-gluing-findings.md`
- **Artifacts**: plans/02_sheaf-clause-and-seam-dedup.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Land the *Sheaf* clause of the presheaf dictionary as a new `FormalSystem/Semantics/Presheaf/Sheaf.lean`
— the glued section, its two reading equations, both restriction identities, uniqueness, and the
`∃!` packaging in both raw-data and site-indexed form — and, in the same task, remove the
duplication the clause would otherwise create by extracting the seam-composition argument once as
`PartialHistory.rel_across_seam` and rewiring `PlusLanguage.paste_rel_le_lt` to delegate to it.
Every mathematical obligation is **already compiled sorry-free** in this task's three probes, so
the work is siting, docstrings, choice-freedom measurement and gate compliance — not discovery.
Definition of done: one new `.lean` file, three edited ones, `lake build FormalSystem` green with
no new `sorry` at the end of **every** phase, and `#print axioms` measuring `[propext, Quot.sound]`
on every new declaration (and on `PlusLanguage.paste`, which this task incidentally clears of
`Classical.choice`).

### Research Integration

`reports/02_sheaf-clause-and-seam-dedup.md` is integrated wholesale. It is a compiled report, not
a sketch: probes 01–03 under `specs/564_.../probes/` are the transcription source for every
declaration below, and they compile against the live tree with `lake env lean`, exit 0. Five of
its findings shape this plan structurally.

1. **The clause is stated in CUT form `(l, p)`, not sum form `(l₁, l₂)`.** Probe 02 shows
   `Beh.restrictTr (coverLeft …)` and `Beh.restrictTr (coverRight …)` are **definitionally**
   (`rfl`) the raw-data restrictions `Beh.restrict 0 p …` and `Beh.restrict p (l - p) …`, so the
   site-indexed clause follows from the raw one with no transport and no cast. The sum form would
   need a dependent transport along `l₁ + l₂ - l₁ = l₂` and buys nothing (report §§3, 5).
2. **The de-duplication is one lemma with TWO seam coordinates.** `rel_across_seam` is stated at
   `PartialHistory` with independent seam points `m` in `σ` and `m'` in `τ`, and an explicit
   duration-splitting hypothesis `hd : d = (m - s) + (s' - m')`. Both consumers derive from it at
   **byte-unchanged signatures**: `paste_rel_le_lt` (total histories, `m = m' = t`) and the
   interval-site step (`m = l₁`, `m' = 0`). A one-coordinate lemma covers only the first
   (report §2).
3. **"Sheaf is choice-free" is true but not for free.** The single source of `Classical.choice` on
   this front is `TaskFrame.reflection`, whose proof opens with a classical `eq_or_ne d 0`. The
   mixed-orientation case of both `glue` and `paste_rel` is **strict**, so the off-zero law
   `TaskFrame.reflect_reflection_of_ne` (`[propext]`) suffices — but `rw` cannot see through
   `F.TaskRel` to the underlying `reflect` pattern, so a four-line wrapper is required. That
   wrapper is Phase 1 content, in the **same** phase as the lemma, never a follow-on
   (report §4).
4. **Three references in the dispatch are stale and this plan is built against the corrections.**
   The probe path it names is archived under the gitignored `specs/archive/`; `ShiftSet.wh_ext`
   no longer exists and is replaced by `Beh.ext (partialHistory_ext …)`; and the DEPENDENCY NOTE's
   namespace is superseded by the POST-RELOCATION NOTE's `FormalSystem.PlusLanguage` at
   `FormalSystem/PlusLanguage/PlusPasting.lean`, which is the accurate one (report, "Three stale
   references in the task description, corrected").
5. **Scope must widen past the declared `file_scope`** of `Presheaf/Sheaf.lean` alone — see
   **Shared Touches** below for the full set and the reason each is unavoidable (report §6).

The report sets **no** `user_decision`, and this plan adds none: every fork it names was resolved
from the artifacts plus a compiled probe.

### Prior Plan Reference

No prior plan. This is round 2 for this task (round 1 produced `reports/01_…` only, a
finite-vs-directed gluing study with no plan), so there is no phase structure, effort calibration
or risk record to inherit. Report 01 contributes one standing constraint this plan honours:
`paste`'s definition and signature must not move, because the six pasting validities and their
`*_plusValid` packagings rest on them.

### Roadmap Alignment

No `roadmap_path` was provided in this dispatch and no roadmap phases are included. This task's
position on the categorical front is recorded by the dispatch: it owns the *Sheaf* clause of
`app:presheaf-dictionary`, downstream of 563 (the site and the presheaf, now landed), and its
`rel_across_seam` is the shared asset the directed-gluing and totality clauses will reuse.

## Goals & Non-Goals

- **Goals**: `reflection_of_ne`, `rel_across_seam`, `paste_rel_le_lt`, `paste_rel`,
  `glue_states_le`, `glue_states_not_le`, `restrict_glue_left`, `restrict_glue_right`,
  `states_eq_of_eq`, `glue_unique`, `sheaf_clause`, `restrictTr_coverLeft`,
  `restrictTr_coverRight`, `compat_iff_match`, `sheaf_clause_site`, `pasteAt_states_le`,
  `pasteAt_states_not_le`, `isTotal_pasteAt`, `paste_eq_pasteAt`
- **Goals (not challenge-pinned)**: the two definitional carriers whose bodies the snapshot
  matcher would erase — `glue` (the glued section, in cut form) and `pasteAt` (`paste`
  generalized off totality); the module docstring's two-sense choice-freedom record; and the
  plumbing — the `Sheaf` import in the cluster aggregator, `Presheaf/README.md`'s inventory and
  Key Definitions/Results, the regenerated library root, the regenerated inventory blocks, the
  regenerated typst counts, and the two stale `KNOWN-ANCHORS` row descriptions.
- **Non-Goals**: any change to `paste`'s own definition or signature (report 01's recommendation 2
  — the six pasting validities and their `*_plusValid` packagings must not move); the sum-form
  `(l₁, l₂)` corollary and its `Beh.cast` transport (report Decision 1 explicitly declines it a
  phase); moving `partialHistory_ext` down into `PartialHistory.lean` (563's recorded follow-up,
  which would churn `Behavior.lean` for no gain here); the directed/ω-indexed gluing clause and
  anything resting on *Saturation* through the Extension Theorem; the Totality, Possible Worlds,
  Determinism and Reflection clauses of the dictionary; any row in `docs/theorem-index.md` (a
  concurrent sibling owns that file this cycle, and C15 checks that existing rows are anchored,
  not that every declaration has one); any attempt to *pin* `app:gluing`, whose
  `LIVE-UNPINNED` record row states that no docstring quotes its text.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| **Concurrent sibling owns three of this task's shared touches.** Task 710 is dispatched for `implement` this same cycle and its declared `file_scope` includes `FormalSystem.lean`, `README.md` and `FormalSystem/README.md` — exactly the three regenerated files every module-adding task must re-emit | H | H (declared) | Treat all three as **regenerate-never-hand-edit** and stage hunk-by-hunk. Re-read each immediately before touching it; run `lake exe mk_all --lib FormalSystem` and `check-module-invariants.sh --emit-inventory` rather than editing; stage only the generated-block hunks (563's proven technique: `git apply --cached` on a filtered diff), never a directory or glob `git add`. If a foreign commit, a foreign uncommitted hunk inside a generated block, or a build this task did not start is observed, **STOP and report** after checking `git log` — do not reconcile |
| **Docstring overclaims "choice-free" while `glue` still routes through `TaskFrame.reflection`** | H | M | The off-zero reflection wrapper and both its call sites are Phase 1 content, in the same phase as `rel_across_seam` — not a follow-on. Re-measure with `#print axioms` **before** writing the docstring sentence in Phase 3. Honest fallback wording if the wrapper were ever dropped: the *Saturation*-independence claim alone, which is still true and still worth recording |
| **Docstring overclaims by citing probe results as library facts** | M | M | `#print axioms` rows are quotable only for declarations that are **in** the library after Phase 3. For the contrasting directed case cite `app:gluing`'s footnote and `FormalSystem/Semantics/Extension.lean` only — never a probe path, which `/todo` will archive |
| **Quoting `app:gluing`'s text falsifies its own record row**, which reads "Not pinned: no docstring quotes its text" | M | M | Cite it as a pointer (`* JPL paper \`app:gluing\` — …`) and never quote. Phase 3 also amends that row's own citer enumeration, which names only `FormalSystem/OpenLanguage/` today |
| **Aggregator edit clobbered by a concurrent sibling.** `FormalSystem/Semantics/Presheaf.lean` needs one import line, and the collision gate cannot see it because the dispatch forbids widening `file_scope` to cover it | M | M | Re-read the aggregator immediately before the edit, add exactly one `import` line plus one `## Modules` bullet, re-run `lake build` afterwards, and stage that file alone in the same scoped commit. A sibling with undeclared scope is live this cycle |
| **`FormalSystem.lean` hand-edited and C33 fails byte-comparison** | H | M | Always `lake exe mk_all --lib FormalSystem`; never add the import by hand. Confirm with `check-module-invariants.sh --no-build` before committing the phase |
| **A README inventory block left stale, failing INV**; the root `README.md` block is `rows=totals` and tracks live **line** counts, so *every* phase that edits a `.lean` file makes it stale | M | H (certain) | Re-emit with `check-module-invariants.sh --emit-inventory` at the end of **each** Lean phase, then `--emit-inventory --check` to prove no byte would change |
| **Pre-commit hook blocks the commit on stale typst counts.** `.githooks/pre-commit` refuses any commit that changes live `.lean` line counts without a regenerated `typst/generated/status.typ` | M | H (certain) | In every phase that commits a `.lean` change, run `bash scripts/typst-sync-check.sh --fix` and stage `typst/generated/status.typ` — the same obligation 563 recorded as a deviation in each of its Lean phases |
| **A `Constraints consumed:` marker written over a bundling binder, failing C34a** | M | L | Keep the binder-free form primary at an explicit `(hcomp : TaskFrame.Compositional F.TaskRel)`. The wrapper `reflection_of_ne` carries **no** constraint binder at all. The safest route, which 563 took and this plan repeats, is to write **no** marker and keep all constraint discussion in the `/-!` module block, whose span C34b does not read |
| **C20's declaration-span assertion fires on a `file.lean:NNN` citation** in a new docstring | L | M | Cite declaration **names**, never `file.lean:NNN`, in every docstring and README line this task writes |
| **Phase 1's build is the expensive one**: editing `TaskFrame.lean` and `PartialHistory.lean` invalidates a large transitive closure (the cached baseline is 2810 jobs, ~8s) | M | H (certain) | Run every build detached through `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem`, never in the foreground, and read the verdict from the guard's own `result` rather than a pipe exit code |
| **`ring` and `linarith` are unavailable in the `Semantics/` import closure** | L | H (certain) | Use the lemma routes the probes already measured: `add_sub_cancel_left` for `p + r - p = r`, `sub_nonpos.mpr` for `r ≤ 0` from `p + r ≤ p`, `sub_sub_sub_cancel_right` for `(t - p) - (s - p) = t - s`. Do **not** "simplify" any of these to `linarith` |
| **A choice-free step silently replaced by a classical one.** `le_of_add_le_add_left` closes the `r ≤ 0` goal but measures `Classical.choice` | M | M | Use `sub_nonpos.mpr` plus `add_sub_cancel_left`, as probe 01 does, and re-measure with `#print axioms` at the end of Phases 2 and 3 |
| **`Beh`'s `Iff.rfl` discharges lost** by building the glued section as a `PartialHistory`-level paste and then proving its domain *equal* to `Interval 0 l` | M | L | Write `glue`'s domain as the literal `fun z => 0 ≤ z ∧ z ≤ l` with `property := fun _ => Iff.rfl`, verbatim from probe 01. Never restate it as a domain equality |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |

Phases within the same wave can execute in parallel. This plan is **fully sequential by
construction**, for two reasons worth stating because they are not both dependency-graph facts.
Phase 2's `glue` calls Phase 1's `rel_across_seam`, and Phase 3's statements mention Phase 2's
`glue` — those are genuine content dependencies. Phase 4's Lean content, by contrast, depends only
on Phase 1, so it is *mathematically* parallel to Phases 2–3; it is nevertheless sequenced last
because it shares the four regenerated files (library root, two inventory blocks, typst counts)
with every other phase, and running two phases concurrently against those would reproduce exactly
the clobbering the dispatch's aggregator note warns about. Phase 4 is also the **droppable** phase
if scope must be cut: report Decision 4 is explicit that §2's de-duplication (Phase 1) discharges
the stated harm on its own and §7's `pasteAt` does not.

### Shared Touches (deliberately outside `Files to modify`)

Four paths are edited by this task but are **intentionally absent** from every phase's
`Files to modify`, so that `plan-file-scope-harvest.sh` does not widen `file_scope` to cover them.
The dispatch instructs this directly for the cluster aggregator — widening would make the
collision gate defer the whole categorical front every cycle — and the same reasoning applies to
the three regenerated files, which are produced by a command rather than authored and which a
concurrent sibling declares this cycle. This subsection is the record that the omission is a
decision, not an oversight.

| Path | How it is touched | Gate that makes it mandatory |
|---|---|---|
| `FormalSystem/Semantics/Presheaf.lean` | one `import FormalSystem.Semantics.Presheaf.Sheaf` line + one `## Modules` bullet (Phase 2) | C24/C6 root closure |
| `FormalSystem.lean` | regenerated: `lake exe mk_all --lib FormalSystem` (Phase 2) | C33, byte-exact |
| `README.md`, `FormalSystem/README.md` | regenerated: `bash scripts/check-module-invariants.sh --emit-inventory` (every Lean phase) | INV |
| `typst/generated/status.typ` | regenerated: `bash scripts/typst-sync-check.sh --fix` (every Lean phase) | `.githooks/pre-commit` |

Protocol for all four, in every phase: re-read immediately before touching; regenerate rather
than hand-edit; stage only the generated hunks with an explicit pathspec list; re-run the build
after the aggregator edit; **STOP and report** on any foreign change inside a generated block.

---

### Phase 1: The shared seam argument and the two delegations [NOT STARTED]

**Goal**: The seam-composition argument exists **once** in the tree, at `PartialHistory`, with two
independent seam coordinates; `PlusLanguage.paste_rel_le_lt` becomes a four-line delegation at a
byte-identical signature; and `paste` is incidentally cleared of `Classical.choice` by routing
`paste_rel`'s mixed-orientation case through the off-zero reflection law.

**Tasks**:
- [ ] Add `TaskFrame.reflection_of_ne` to `FormalSystem/Semantics/TaskFrame.lean`, immediately
      after `TaskFrame.reflection` inside the existing `namespace TaskFrame` block that also holds
      `comp`, `serial`, `limit` and `saturation`:
      `theorem reflection_of_ne (F : TaskFrame) {w u : F.WorldState} {d : F.Duration} (hd : d ≠ 0) : F.TaskRel w d u ↔ F.TaskRel u (-d) w := TaskFrame.reflect_reflection_of_ne hd`.
      It carries **no** constraint binder — that is the point, and it is what makes the
      choice-freedom claim readable from the signature. Its `/--` block must say *why* the wrapper
      exists: `rw` cannot see through `F.TaskRel` to the underlying `TaskFrame.reflect` pattern, so
      the bare lemma fails with "did not find an occurrence of the pattern" while the wrapper
      applies. Keep the block free of the constraint vocabulary C34b triggers on
      (`Compositionality`/`Seriality`/`Limit`/`Saturation`, `Serial`/`Compositional`/`Saturated`)
- [ ] Add `PartialHistory.rel_across_seam` to `FormalSystem/Semantics/PartialHistory.lean`, in the
      first `namespace PartialHistory` block, next to `respects_task_le` which it generalizes.
      Transcribe the statement and proof verbatim from `probes/01_seam-lemma-and-glue.lean`
      lines 24–37: two seam coordinates `m` in `σ` and `m'` in `τ`, an explicit duration parameter
      `d` with the splitting hypothesis `hd : d = (m - s) + (s' - m')`, and an explicit
      `(hcomp : TaskFrame.Compositional F.TaskRel)` with no bundling binder. Proof route:
      `σ.respects_task`, `τ.respects_task`, `rw [hmatch]`, then
      `TaskFrame.forward_of_comp hcomp` with `sub_nonneg.mpr` on both nonnegativity slots
- [ ] Record in `rel_across_seam`'s `/--` block the three load-bearing design points, in words and
      without naming any task: two seam coordinates rather than one (a one-coordinate lemma would
      force a `PartialHistory.timeShift` at the interval-site call site, strictly more work); the
      duration as a parameter plus a splitting hypothesis rather than the literal
      `(m - s) + (s' - m')`, so each call site supplies its own arithmetic identity and no
      post-hoc rewrite is needed; and the explicit `Compositional` hypothesis
- [ ] Rewrite `paste_rel_le_lt`'s body in `FormalSystem/PlusLanguage/PlusPasting.lean` as a
      delegation to `rel_across_seam`, per `probes/01_…` lines 41–46, passing `F.comp` and
      supplying `by rw [add_comm]; exact (sub_add_sub_cancel s' t s).symm` in the `hd` slot. The
      **signature line must stay byte-identical**, `[F.IsRegular]` included, so no call site moves
- [ ] Rewrite `paste_rel`'s third case in the same file: replace `F.reflection` with
      `TaskFrame.reflection_of_ne F (sub_ne_zero_of_ne (ne_of_lt …))`. The case is strict
      (`s' ≤ t < s`), so the off-zero hypothesis is in hand. This is the step that clears
      `Classical.choice` from `paste`
- [ ] Update `PlusPasting.lean`'s module docstring where it says `paste` uses "the converse
      convention (`TaskFrame.reflection`) for the reverse orientation": it now uses the **off-zero**
      reflection law, and the construction is therefore choice-free. State it as the measured fact
      it is, naming declarations rather than `file.lean:NNN`
- [ ] Measure and record: `#print axioms` (equivalently `lean_verify` on the fully qualified name)
      on `FormalSystem.Semantics.PartialHistory.rel_across_seam`,
      `FormalSystem.Semantics.TaskFrame.reflection_of_ne`,
      `FormalSystem.PlusLanguage.paste_rel_le_lt` and `FormalSystem.PlusLanguage.paste`. Expected:
      `[propext]` for the wrapper, `[propext, Quot.sound]` for the other three — `paste` dropping
      `Classical.choice` is the observable proof that the rewiring took
- [ ] Re-emit the generated blocks and commit, staging exactly this phase's three files plus the
      generated ones, per **Shared Touches**

**Timing**: 1.25 hours

**Depends on**: none

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: this phase asserts **two new declarations** (`TaskFrame.reflection_of_ne`,
`PartialHistory.rel_across_seam`) and **two rewritten bodies at unchanged signatures**
(`paste_rel_le_lt`, `paste_rel`), across **three** files. Confirm at implementation time by
`git diff --stat` naming exactly those three `.lean` paths, and by
`git diff -U0 FormalSystem/PlusLanguage/PlusPasting.lean` showing **no** change to either
rewritten declaration's signature line. A fourth `.lean` file in the diff means the lemma's home
was chosen differently from the report's §6 decision and must be re-read against it, not improvised.

**Files to modify**:
- `FormalSystem/Semantics/TaskFrame.lean` - add `TaskFrame.reflection_of_ne`, the binder-free
  off-zero reflection wrapper, beside `TaskFrame.reflection`
- `FormalSystem/Semantics/PartialHistory.lean` - add `PartialHistory.rel_across_seam`, the shared
  seam-composition argument, beside `respects_task_le`
- `FormalSystem/PlusLanguage/PlusPasting.lean` - `paste_rel_le_lt` becomes a delegation;
  `paste_rel`'s mixed case routes through the off-zero law; module docstring updated

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem` — exit 0,
  detached, read the verdict from the guard's `result`
- No new `sorry`: `grep -rn 'sorry' FormalSystem/Semantics/PartialHistory.lean FormalSystem/Semantics/TaskFrame.lean FormalSystem/PlusLanguage/PlusPasting.lean` returns nothing
- `#print axioms FormalSystem.PlusLanguage.paste` no longer lists `Classical.choice`
- `bash scripts/check-module-invariants.sh --no-build` — C20, C31, C33, C34a, C34b and INV green
- `bash scripts/check-copyright-headers.sh --strict FormalSystem` — exit 0
- The six pasting validities still compile untouched: `paste_valid`, `paste_valid'`,
  `future_dstab_valid`, `stab_allFuture_valid`, `untl_dstab_valid`, `snce_dstab_valid` appear in
  the green build with no edit to their text (`git diff` shows no hunk inside them)

---

### Phase 2: `Presheaf/Sheaf.lean` — the glued section, the restriction identities, uniqueness [NOT STARTED]

**Goal**: The *Sheaf* clause lands as a module: the glued section in cut form, its two reading
equations, both restriction identities, the state-reading helper, uniqueness, and the raw-data
`∃!` packaging — with the cluster aggregator reaching it and the library root regenerated.

**Tasks**:
- [ ] Create `FormalSystem/Semantics/Presheaf/Sheaf.lean` with the header shape the cluster
      already uses: copyright block, then
      `import FormalSystem.Init` and `import FormalSystem.Semantics.Presheaf.Behavior`, then a
      **Tier-3** module docstring (Title + scope paragraph, `## Main Definitions`,
      `## Main Results`, `## Implementation Notes`, `## References`, in that order per
      `docs/reference/docstring-standard.md`), then `namespace FormalSystem.Semantics.Presheaf`.
      Mirror `Site.lean`/`Behavior.lean` rather than inventing a shape
- [ ] Transcribe from `probes/01_seam-lemma-and-glue.lean`, replacing its local `rel_across_seam`
      and `taskRel_reflection_of_ne` with Phase 1's library declarations: `glue` (lines 65–97),
      `glue_states_le` and `glue_states_not_le` (101–112), `restrict_glue_left` (116–130),
      `restrict_glue_right` (134–158), `states_eq_of_eq` (162–164), `glue_unique` (168–199),
      `sheaf_clause` (203–212). Give every declaration a `/--` docstring
- [ ] Write out the `hmatch` hypothesis type in full wherever the probe wrote `(hmatch : _)` — the
      probe's elaborated underscore is not acceptable in a library signature. The pinned form is in
      **Lean Challenge Statements** below and is the contract
- [ ] Keep `glue`'s domain as the literal `fun z => 0 ≤ z ∧ z ≤ l` with
      `property := fun _ => Iff.rfl`, and keep `states` a **dependent** `if hzp : z ≤ p` (`dite`,
      not `ite`) so each branch has its domain witness. `glue_states_le`/`glue_states_not_le` are
      then literally `dif_pos hzp` / `dif_neg hzp`, and **every** later proof reads through them
      rather than unfolding `glue`
- [ ] Record in `## Implementation Notes`: (a) the decidability of `z ≤ p` comes from the
      `LinearOrder` field of the temporal order, not from `Classical.propDecidable`; (b)
      `respects_task` is unconditional at `PartialHistory` — all pairs `(s, t)`, no `s ≤ t` guard —
      which is why the obligation has **four** cases rather than two and why the mixed-orientation
      case is unavoidable; (c) the four-way split mirrors `paste_rel`'s own, which is the
      structural evidence that the two are one argument; (d) the right restriction identity is
      where `hmatch` is consumed, because the `dite` test `p + r ≤ p` is *true* at `r = 0`;
      (e) `r ≤ 0` from `p + r ≤ p` is taken choice-free as `sub_nonpos.mpr` plus
      `add_sub_cancel_left`, and `le_of_add_le_add_left` must **not** be substituted because it
      measures `Classical.choice`; (f) `ring` and `linarith` are unavailable in this import
      closure, so `add_sub_cancel_left` and `sub_sub_sub_cancel_right` are not stylistic choices
- [ ] Write **no** `Constraints consumed:` marker, and keep every mention of the frame constraints
      in the `/-!` module block, whose span C34b does not read. The declarations here are
      binder-free (explicit `hcomp`), so C34b does not reach them in any case
- [ ] End the file with
      `assert_not_exists FormalSystem.ProofSystem.Axiom FormalSystem.ProofSystem.DerivationTree`
      after the closing `end`, as both sibling modules do, locking the layering positively
- [ ] Re-read `FormalSystem/Semantics/Presheaf.lean` immediately beforehand, then add
      `import FormalSystem.Semantics.Presheaf.Sheaf` in its existing ordering and one
      `## Modules` bullet describing the clause
- [ ] Update `FormalSystem/Semantics/Presheaf/README.md`: re-emit its gated inventory block and
      hand-write the new Key Definitions (`glue`) and Key Results (`sheaf_clause`,
      `restrict_glue_left`, `restrict_glue_right`, `glue_unique`) entries
- [ ] Regenerate the library root (`lake exe mk_all --lib FormalSystem`), re-emit the inventory
      blocks (`bash scripts/check-module-invariants.sh --emit-inventory`), regenerate the typst
      counts (`bash scripts/typst-sync-check.sh --fix`), and commit with the **Shared Touches**
      staging protocol

**Timing**: 1.5 hours

**Depends on**: 1

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: this phase asserts **eight declarations** in `Sheaf.lean` — `glue`,
`glue_states_le`, `glue_states_not_le`, `restrict_glue_left`, `restrict_glue_right`,
`states_eq_of_eq`, `glue_unique`, `sheaf_clause` — and roughly **150 lines of Lean plus a ~70-line
docstring**. Confirm the count with
`grep -cE '^\s*(@\[[^]]*\]\s*)?(theorem|def|abbrev|structure)\b' FormalSystem/Semantics/Presheaf/Sheaf.lean`
against that list, and the "already proved" premise by diffing the transcribed proof terms against
`probes/01_seam-lemma-and-glue.lean`. Any proof needing *new* tactic work is a signal the
transcription drifted and should be re-read against the probe rather than re-proved. An overcount
closes as a Reasoned Exclusion; an undercount means a probe declaration was dropped and must be
restored.

**Files to modify**:
- `FormalSystem/Semantics/Presheaf/Sheaf.lean` - new: the *Sheaf* clause in cut form
- `FormalSystem/Semantics/Presheaf/README.md` - re-emitted inventory block, plus Key Definitions
  and Key Results for the new module

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem` — exit 0,
  detached
- No new `sorry`: `grep -rn 'sorry' FormalSystem/Semantics/Presheaf/` returns nothing
- `#print axioms` on `glue`, `restrict_glue_left`, `restrict_glue_right`, `glue_unique` and
  `sheaf_clause`, each fully qualified: all `[propext, Quot.sound]`, no `Classical.choice`
- `bash scripts/check-module-invariants.sh --no-build` — C8, C9, C15, C20, C24, C26, C31, C33,
  C34a, C34b and INV green
- `bash scripts/readme-lint.sh FormalSystem` — exit 0 (checks 1 and 3 are the gated ones)
- `bash scripts/check-copyright-headers.sh --strict FormalSystem` — exit 0
- `lake env lean FormalSystem/Semantics/Presheaf/Sheaf.lean` compiles warning-free, so no
  `scripts/warning-budget.txt` row is needed. If the `linter.style.show` warning fires, replace
  `show` with `change` — the linter's own remedy, identical tactic semantics — rather than adding
  a budget row

---

### Phase 3: The site-level clause, the compatible-family theorem, and the choice-freedom record [NOT STARTED]

**Goal**: The clause is stated in the vocabulary of the site's own coverage and shown equivalent
to the raw form; the coverage's compatible-family condition becomes a theorem rather than a
docstring remark; and the module records, in two distinguished senses, which dictionary clauses
are choice-free.

**Tasks**:
- [ ] Add to `Sheaf.lean`, transcribed from `probes/02_site-and-compatible-family.lean`:
      `restrictTr_coverLeft` and `restrictTr_coverRight` — the two `rfl` identities that make the
      site-indexed clause free — and `compat_iff_match`, the equivalence between the coverage's
      compatible-family condition (an equality of germ sections in `Beh F 0`) and the raw
      `hmatch`. The probe's two identities are `example`s; name them here
- [ ] Add `sheaf_clause_site`, the site-indexed `∃!` stated along `coverLeft`/`coverRight`,
      derived from `sheaf_clause` through the two `rfl` identities with **no** transport and no
      cast. This is what closes the loop `Site.lean`'s `cover_germ_composites` docstring opens
- [ ] Record in `compat_iff_match`'s `/--` block that `Beh.restrictTr` must be unfolded
      (`simp only [Beh.restrictTr, rres, lres]`) before `rw` can see the `Beh.restrict_states`
      pattern — a measured fact from the probe, not a stylistic note
- [ ] Write the module docstring's choice-freedom record as **two** sentences, because the two
      claims are different and the dispatch's "Sheaf is choice-free" is sound in both senses:
      (1) *saturation-independence* — the binary seam gluing uses **Compositionality only**, whose
      honest witness is the signature's explicit `(hcomp : TaskFrame.Compositional F.TaskRel)`
      rather than an `[F.IsRegular]` binder that would bundle *Saturation* and make the claim
      unreadable; and (2) *axiom-freedom* — `[propext, Quot.sound]`, no `Classical.choice`, as
      measured on the landed declarations. Name directed gluing as the contrasting case, which
      rests on *Saturation* through the Extension Theorem, citing
      `FormalSystem/Semantics/Extension.lean` and `app:gluing`'s footnote as a pointer
- [ ] Write `## References` in the normal form of `docs/development/REFERENCE_NORMAL_FORM.md`:
      bibliographic entries as `* [Author, *Title*][key]` against the root `references.bib`
      (`schultz2020` and `johnstone1999` both resolve there and are the right keys to reuse);
      `* JPL paper \`app:gluing\` — …` as a **pointer only**, never a verbatim quote, because its
      `LIVE-UNPINNED` record row states that no docstring quotes its text; and
      `app:presheaf-dictionary` / `app:Structure` cited exactly as `Site.lean` and `Behavior.lean`
      already cite them, recording at the citation site that the appendix was cut in full under an
      explicit `% SECTION CUT` record and carries a bare `% CHECK`
- [ ] Amend two now-stale row descriptions inside the `<!-- KNOWN-ANCHORS:BEGIN -->` fence of
      `docs/reference/paper-definitions-of-record.md`: `app:gluing`'s row enumerates
      `FormalSystem/OpenLanguage/` as its only citer, and `app:presheaf-dictionary`'s row says the
      Sheaf clause is formalized only as its *site-side* content `cover_germ_composites`. Both
      are falsified by this module. Add `FormalSystem/Semantics/Presheaf/Sheaf.lean` as a citer and
      record `sheaf_clause` as the clause's formalization, keeping each row's existing status
      verbatim (`LIVE-UNPINNED` and `DANGLING` respectively) and the block's sort order intact.
      Do **not** attempt to pin either anchor
- [ ] Update `FormalSystem/Semantics/Presheaf/README.md`'s Key Results for the site-level
      declarations, re-emit the generated blocks, regenerate the typst counts, and commit per the
      **Shared Touches** protocol

**Timing**: 1.25 hours

**Depends on**: 2

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: this phase asserts **four new declarations** (`restrictTr_coverLeft`,
`restrictTr_coverRight`, `compat_iff_match`, `sheaf_clause_site`) and **exactly two** amended rows
in the anchor record. Confirm the declaration count by re-running Phase 2's `grep -c` and reading
twelve where it read eight; confirm the row count by
`git diff docs/reference/paper-definitions-of-record.md` touching exactly the `app:gluing` and
`app:presheaf-dictionary` lines. A third amended row means a third anchor is being cited and must
be checked against C15 before the commit, not after.

**Files to modify**:
- `FormalSystem/Semantics/Presheaf/Sheaf.lean` - the site-level clause, the compatible-family
  theorem, the two-sense choice-freedom record, and `## References`
- `FormalSystem/Semantics/Presheaf/README.md` - Key Results for the site-level declarations
- `docs/reference/paper-definitions-of-record.md` - amend the `app:gluing` and
  `app:presheaf-dictionary` row descriptions, statuses unchanged

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem` — exit 0,
  detached
- No new `sorry` under `FormalSystem/Semantics/Presheaf/`
- `#print axioms` on `compat_iff_match` and `sheaf_clause_site`: `[propext, Quot.sound]`
- `bash scripts/check-module-invariants.sh --no-build` — C15, C20, C31, C33, C34a, C34b and INV
  green. **C15 is the one to read closely**: the module now cites three paper anchors
- `bash scripts/check-paper-definitions.sh` — compare its exit code against the pre-existing
  `def:BX` drift (the paper renamed axiom `SU` to `US`), which predates this task and is recorded
  in the tree. A *new* failure naming any of this task's three anchors is this task's; the `def:BX`
  one is not, and must be reported rather than fixed
- `bash scripts/readme-lint.sh FormalSystem` — exit 0

---

### Phase 4: `pasteAt` — `paste` generalized off totality [NOT STARTED]

**Goal**: The literal reading of "generalize `paste` off its totality hypothesis" lands:
`pasteAt` pastes two **arbitrary** partial histories agreeing at a seam, and the existing
total-history `paste` is recovered as a corollary with its definition and signature untouched.

**Note on droppability.** This is the one phase that may be cut, and the cut is pre-authorized by
report Decision 4: Phase 1's `rel_across_seam` plus the two delegations already discharge the
stated harm ("the same argument should not be written twice"), whereas `pasteAt` alone would not.
If the phase is cut, close it as `[COMPLETED WITH EXCLUSIONS]` with a `#### Reasoned Exclusions`
record enumerating all five declarations — not `[BLOCKED]`, and never `[DESCOPED]`, which is not a
recognized marker.

**Tasks**:
- [ ] Add to `FormalSystem/PlusLanguage/PlusPasting.lean`, transcribed from
      `probes/03_pasteat-off-totality.lean` with its local seam lemma and reflection wrapper
      replaced by Phase 1's library declarations: `pasteAt` (domain
      `fun z => (z ≤ t ∧ σ.domain z) ∨ (¬ z ≤ t ∧ τ.domain z)`), the two reading equations
      `pasteAt_states_le` / `pasteAt_states_not_le`, `isTotal_pasteAt`, and the bridge
      `paste_eq_pasteAt`
- [ ] Place them **after** `paste` in the file, not before it, so that `paste`'s own definition,
      signature and docstring are provably untouched by this phase's diff
- [ ] Record in `pasteAt`'s `/--` block why the `states` field splits on the decidable `z ≤ t` and
      *then* resolves the disjunction inside each branch
      (`hz.resolve_right (fun h => h.1 hzt) |>.2`): that is what keeps a `Prop`-valued `Or` from
      being eliminated into a `Type`
- [ ] Record in the module docstring that `paste` is now a **corollary** of a construction stated
      off totality, that its definition and signature are unchanged, and that the six pasting
      validities and their `*_plusValid` packagings therefore do not move
- [ ] Measure `#print axioms` on `pasteAt` and `paste_eq_pasteAt`: both must be
      `[propext, Quot.sound]`. `paste_eq_pasteAt` mentions `paste`, so it clears
      `Classical.choice` only because Phase 1 rerouted `paste_rel`'s mixed case — a **second**
      observable check that Phase 1 took effect
- [ ] Re-emit the generated blocks, regenerate the typst counts, and commit per the
      **Shared Touches** protocol

**Timing**: 1 hour

**Depends on**: 3

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: this phase asserts **five new declarations** in one file (`pasteAt`,
`pasteAt_states_le`, `pasteAt_states_not_le`, `isTotal_pasteAt`, `paste_eq_pasteAt`) and roughly
**55 lines** of Lean. Confirm by `git diff --stat` naming `PlusPasting.lean` alone among `.lean`
paths, and — the load-bearing check — by `git diff -U0 FormalSystem/PlusLanguage/PlusPasting.lean`
showing **no hunk inside `pasteFun`, `paste_rel` or `paste`** other than Phase 1's already-committed
ones. A hunk inside `paste` means the non-goal was crossed and must be reverted before the commit.

**Files to modify**:
- `FormalSystem/PlusLanguage/PlusPasting.lean` - add `pasteAt`, its two reading equations,
  `isTotal_pasteAt` and `paste_eq_pasteAt` after `paste`; module docstring records that `paste` is
  now a corollary

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem` — exit 0,
  detached
- No new `sorry` in `FormalSystem/PlusLanguage/PlusPasting.lean`
- `#print axioms FormalSystem.PlusLanguage.pasteAt` and
  `#print axioms FormalSystem.PlusLanguage.paste_eq_pasteAt`: both `[propext, Quot.sound]`
- `bash scripts/check-module-invariants.sh --no-build` — C20, C31, C33, C34a, C34b and INV green
- The six pasting validities and both agreement lemmas (`paste_agreeFrom`, `paste_agreeUpTo`) are
  untouched in the diff and green in the build
- Full-project final verification:
  `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build` — exit 0

---

## Lean Challenge Statements

**Authoring note.** The snapshot matcher recognizes `theorem|lemma|def|instance` followed by a
*simple* name, forces that body to `sorry`, and discards everything between the `:=` and the next
matched declaration. The block below is shaped so nothing is lost: the two definitional carriers
this task delivers (`glue`, `pasteAt`) sit in the **preamble**, before the first `theorem`, and are
written as `abbrev` (unmatched, so their bodies survive and they stay out of the identifier set);
the library declares each with `def`. Two further `abbrev`s, `taskRelReflectionOfNe` and
`relAcrossSeam`, carry the Phase 1 content the carriers' own proofs call — they are not
deliverables under those names, and their library forms are pinned below as `reflection_of_ne` and
`rel_across_seam`. No pinned name is dotted, and no `namespace`/`end` sits between two theorems. In
the library the declarations live in four places: `reflection_of_ne` in
`FormalSystem.Semantics.TaskFrame`, `rel_across_seam` in
`FormalSystem.Semantics.PartialHistory`, `paste_rel_le_lt`/`paste_rel`/`pasteAt_states_le`/
`pasteAt_states_not_le`/`isTotal_pasteAt`/`paste_eq_pasteAt` in `FormalSystem.PlusLanguage`, and
the rest in `FormalSystem.Semantics.Presheaf`. Binder names are immaterial; binder types,
hypotheses and conclusions are the contract.

`paste_rel_le_lt` and `paste_rel` are pinned although they **already exist**: this task rewrites
their bodies, and pinning them is how the byte-identical-signature requirement becomes mechanically
checkable rather than a prose hope.

**Verified**: this exact block was compiled against the live tree with `lake env lean` and returns
exit 0 with 19 `declaration uses 'sorry'` warnings and no errors — one per pinned identifier, and
no more.

```lean
import FormalSystem.Semantics.Presheaf.Behavior
import FormalSystem.PlusLanguage.PlusPasting

namespace FormalSystem.Semantics.Presheaf

open FormalSystem.Semantics
open FormalSystem.PlusLanguage

variable {F : TaskFrame}

/-! Challenge carriers. -/

/-- Challenge carrier; `theorem` in the library (`TaskFrame.reflection_of_ne`). -/
abbrev taskRelReflectionOfNe (F : TaskFrame) {w u : F.WorldState} {d : F.Duration}
    (hd : d ≠ 0) : F.TaskRel w d u ↔ F.TaskRel u (-d) w :=
  TaskFrame.reflect_reflection_of_ne hd

/-- Challenge carrier; `theorem` in the library (`PartialHistory.rel_across_seam`). -/
abbrev relAcrossSeam {F : TaskFrame} (hcomp : TaskFrame.Compositional F.TaskRel)
    {σ τ : PartialHistory F}
    {m m' : F.Duration} (hσm : σ.domain m) (hτm' : τ.domain m')
    (hmatch : σ.states m hσm = τ.states m' hτm')
    {s s' d : F.Duration} (hs : σ.domain s) (hs' : τ.domain s')
    (hsm : s ≤ m) (hm's' : m' ≤ s')
    (hd : d = (m - s) + (s' - m')) :
    F.TaskRel (σ.states s hs) d (τ.states s' hs') := by
  have h1 : F.TaskRel (σ.states s hs) (m - s) (σ.states m hσm) := σ.respects_task s m hs hσm
  have h2 : F.TaskRel (τ.states m' hτm') (s' - m') (τ.states s' hs') :=
    τ.respects_task m' s' hτm' hs'
  rw [hmatch] at h1
  rw [hd]
  exact TaskFrame.forward_of_comp hcomp _ _ _ _ _ (sub_nonneg.mpr hsm) (sub_nonneg.mpr hm's') h1 h2

/-- Challenge carrier; `def` in the library. -/
abbrev glue (hcomp : TaskFrame.Compositional F.TaskRel) {l p : F.Duration} (hp : 0 ≤ p)
    (hpl : p ≤ l) (τ₁ : Beh F p) (τ₂ : Beh F (l - p))
    (hmatch : τ₁.val.states p (Beh.mem_dom τ₁ hp le_rfl)
      = τ₂.val.states 0 (Beh.mem_dom τ₂ le_rfl (sub_nonneg.mpr hpl))) : Beh F l :=
  ⟨{ domain := fun z => 0 ≤ z ∧ z ≤ l
     nonempty_domain := ⟨0, le_refl 0, le_trans hp hpl⟩
     states := fun z hz =>
       if hzp : z ≤ p then τ₁.val.states z (Beh.mem_dom τ₁ hz.1 hzp)
       else τ₂.val.states (z - p)
         (Beh.mem_dom τ₂ (sub_nonneg.mpr (le_of_lt (not_le.mp hzp))) (sub_le_sub_right hz.2 p))
     respects_task := by
       intro s t hs ht
       by_cases hsp : s ≤ p <;> by_cases htp : t ≤ p
       · rw [dif_pos hsp, dif_pos htp]
         exact τ₁.val.respects_task s t _ _
       · rw [dif_pos hsp, dif_neg htp]
         exact relAcrossSeam hcomp (Beh.mem_dom τ₁ hp le_rfl)
           (Beh.mem_dom τ₂ le_rfl (sub_nonneg.mpr hpl)) hmatch _ _ hsp
           (sub_nonneg.mpr (le_of_lt (not_le.mp htp)))
           (by rw [sub_zero, add_comm]; exact (sub_add_sub_cancel t p s).symm)
       · have hts : t < s := lt_of_le_of_lt htp (not_le.mp hsp)
         rw [dif_neg hsp, dif_pos htp,
           taskRelReflectionOfNe F (sub_ne_zero_of_ne (ne_of_lt hts)), neg_sub]
         exact relAcrossSeam hcomp (Beh.mem_dom τ₁ hp le_rfl)
           (Beh.mem_dom τ₂ le_rfl (sub_nonneg.mpr hpl)) hmatch _ _ htp
           (sub_nonneg.mpr (le_of_lt (not_le.mp hsp)))
           (by rw [sub_zero, add_comm]; exact (sub_add_sub_cancel s p t).symm)
       · rw [dif_neg hsp, dif_neg htp]
         have h := τ₂.val.respects_task (s - p) (t - p)
           (Beh.mem_dom τ₂ (sub_nonneg.mpr (le_of_lt (not_le.mp hsp))) (sub_le_sub_right hs.2 p))
           (Beh.mem_dom τ₂ (sub_nonneg.mpr (le_of_lt (not_le.mp htp))) (sub_le_sub_right ht.2 p))
         rwa [sub_sub_sub_cancel_right] at h },
   fun _ => Iff.rfl⟩

/-- Challenge carrier; `def` in the library. -/
abbrev pasteAt (hcomp : TaskFrame.Compositional F.TaskRel) (σ τ : PartialHistory F)
    (t : F.Duration) (hσt : σ.domain t) (hτt : τ.domain t)
    (hmatch : σ.states t hσt = τ.states t hτt) : PartialHistory F :=
  { domain := fun z => (z ≤ t ∧ σ.domain z) ∨ (¬ z ≤ t ∧ τ.domain z)
    nonempty_domain := ⟨t, Or.inl ⟨le_rfl, hσt⟩⟩
    states := fun z hz =>
      if hzt : z ≤ t then σ.states z (hz.resolve_right (fun h => h.1 hzt)).2
      else τ.states z (hz.resolve_left (fun h => hzt h.1)).2
    respects_task := by
      intro s s' hs hs'
      by_cases hst : s ≤ t <;> by_cases hs't : s' ≤ t
      · rw [dif_pos hst, dif_pos hs't]; exact σ.respects_task s s' _ _
      · rw [dif_pos hst, dif_neg hs't]
        exact relAcrossSeam hcomp hσt hτt hmatch _ _ hst (le_of_lt (not_le.mp hs't))
          (by rw [add_comm]; exact (sub_add_sub_cancel s' t s).symm)
      · have hne : s' - s ≠ 0 :=
          sub_ne_zero_of_ne (ne_of_lt (lt_of_le_of_lt hs't (not_le.mp hst)))
        rw [dif_neg hst, dif_pos hs't, taskRelReflectionOfNe F hne, neg_sub]
        exact relAcrossSeam hcomp hσt hτt hmatch _ _ hs't (le_of_lt (not_le.mp hst))
          (by rw [add_comm]; exact (sub_add_sub_cancel s t s').symm)
      · rw [dif_neg hst, dif_neg hs't]; exact τ.respects_task s s' _ _ }

/-! Pinned statements begin here. -/

theorem reflection_of_ne (F : TaskFrame) {w u : F.WorldState} {d : F.Duration} (hd : d ≠ 0) :
    F.TaskRel w d u ↔ F.TaskRel u (-d) w := sorry

theorem rel_across_seam {F : TaskFrame} (hcomp : TaskFrame.Compositional F.TaskRel)
    {σ τ : PartialHistory F}
    {m m' : F.Duration} (hσm : σ.domain m) (hτm' : τ.domain m')
    (hmatch : σ.states m hσm = τ.states m' hτm')
    {s s' d : F.Duration} (hs : σ.domain s) (hs' : τ.domain s')
    (hsm : s ≤ m) (hm's' : m' ≤ s')
    (hd : d = (m - s) + (s' - m')) :
    F.TaskRel (σ.states s hs) d (τ.states s' hs') := sorry

theorem paste_rel_le_lt [F.IsRegular] (ρ σ : WorldHistory F) (t : F.Duration)
    (hsame : ρ.state t = σ.state t) {s s' : F.Duration} (hs : s ≤ t) (hs' : ¬ s' ≤ t) :
    F.TaskRel (ρ.state s) (s' - s) (σ.state s') := sorry

theorem paste_rel [F.IsRegular]
    (ρ σ : WorldHistory F) (t : F.Duration) (hsame : ρ.state t = σ.state t) :
    ∀ s s' : F.Duration, F.TaskRel (pasteFun ρ σ t s) (s' - s) (pasteFun ρ σ t s') := sorry

theorem glue_states_le (hcomp : TaskFrame.Compositional F.TaskRel) {l p : F.Duration} (hp : 0 ≤ p)
    (hpl : p ≤ l) (τ₁ : Beh F p) (τ₂ : Beh F (l - p))
    (hmatch : τ₁.val.states p (Beh.mem_dom τ₁ hp le_rfl)
      = τ₂.val.states 0 (Beh.mem_dom τ₂ le_rfl (sub_nonneg.mpr hpl)))
    (z : F.Duration) (hz : (glue hcomp hp hpl τ₁ τ₂ hmatch).val.domain z) (hzp : z ≤ p) :
    (glue hcomp hp hpl τ₁ τ₂ hmatch).val.states z hz
      = τ₁.val.states z (Beh.mem_dom τ₁ hz.1 hzp) := sorry

theorem glue_states_not_le (hcomp : TaskFrame.Compositional F.TaskRel) {l p : F.Duration}
    (hp : 0 ≤ p) (hpl : p ≤ l) (τ₁ : Beh F p) (τ₂ : Beh F (l - p))
    (hmatch : τ₁.val.states p (Beh.mem_dom τ₁ hp le_rfl)
      = τ₂.val.states 0 (Beh.mem_dom τ₂ le_rfl (sub_nonneg.mpr hpl)))
    (z : F.Duration) (hz : (glue hcomp hp hpl τ₁ τ₂ hmatch).val.domain z) (hzp : ¬ z ≤ p)
    (h2 : τ₂.val.domain (z - p)) :
    (glue hcomp hp hpl τ₁ τ₂ hmatch).val.states z hz = τ₂.val.states (z - p) h2 := sorry

theorem restrict_glue_left (hcomp : TaskFrame.Compositional F.TaskRel) {l p : F.Duration}
    (hp : 0 ≤ p) (hpl : p ≤ l) (τ₁ : Beh F p) (τ₂ : Beh F (l - p))
    (hmatch : τ₁.val.states p (Beh.mem_dom τ₁ hp le_rfl)
      = τ₂.val.states 0 (Beh.mem_dom τ₂ le_rfl (sub_nonneg.mpr hpl))) :
    Beh.restrict 0 p le_rfl hp (by rw [zero_add]; exact hpl)
      (glue hcomp hp hpl τ₁ τ₂ hmatch) = τ₁ := sorry

theorem restrict_glue_right (hcomp : TaskFrame.Compositional F.TaskRel) {l p : F.Duration}
    (hp : 0 ≤ p) (hpl : p ≤ l) (τ₁ : Beh F p) (τ₂ : Beh F (l - p))
    (hmatch : τ₁.val.states p (Beh.mem_dom τ₁ hp le_rfl)
      = τ₂.val.states 0 (Beh.mem_dom τ₂ le_rfl (sub_nonneg.mpr hpl))) :
    Beh.restrict p (l - p) hp (sub_nonneg.mpr hpl) (by rw [add_sub_cancel])
      (glue hcomp hp hpl τ₁ τ₂ hmatch) = τ₂ := sorry

theorem states_eq_of_eq {l : F.Duration} {σ τ : Beh F l} (h : σ = τ) (r : F.Duration)
    (hσ : σ.val.domain r) (hτ : τ.val.domain r) : σ.val.states r hσ = τ.val.states r hτ := sorry

theorem glue_unique (hcomp : TaskFrame.Compositional F.TaskRel) {l p : F.Duration} (hp : 0 ≤ p)
    (hpl : p ≤ l) (τ₁ : Beh F p) (τ₂ : Beh F (l - p))
    (hmatch : τ₁.val.states p (Beh.mem_dom τ₁ hp le_rfl)
      = τ₂.val.states 0 (Beh.mem_dom τ₂ le_rfl (sub_nonneg.mpr hpl)))
    (υ : Beh F l)
    (hL : Beh.restrict 0 p le_rfl hp (by rw [zero_add]; exact hpl) υ = τ₁)
    (hR : Beh.restrict p (l - p) hp (sub_nonneg.mpr hpl) (by rw [add_sub_cancel]) υ = τ₂) :
    υ = glue hcomp hp hpl τ₁ τ₂ hmatch := sorry

theorem sheaf_clause (hcomp : TaskFrame.Compositional F.TaskRel) {l p : F.Duration} (hp : 0 ≤ p)
    (hpl : p ≤ l) (τ₁ : Beh F p) (τ₂ : Beh F (l - p))
    (hmatch : τ₁.val.states p (Beh.mem_dom τ₁ hp le_rfl)
      = τ₂.val.states 0 (Beh.mem_dom τ₂ le_rfl (sub_nonneg.mpr hpl))) :
    ∃! υ : Beh F l,
      Beh.restrict 0 p le_rfl hp (by rw [zero_add]; exact hpl) υ = τ₁ ∧
      Beh.restrict p (l - p) hp (sub_nonneg.mpr hpl) (by rw [add_sub_cancel]) υ = τ₂ := sorry

theorem restrictTr_coverLeft (l : Obj F.Duration) (p : ↑F.Duration) (hp : 0 ≤ p)
    (hpl : p ≤ l.val) (υ : Beh F l.val) :
    Beh.restrictTr (coverLeft l p hp hpl) υ
      = Beh.restrict 0 p le_rfl hp (by rw [zero_add]; exact hpl) υ := sorry

theorem restrictTr_coverRight (l : Obj F.Duration) (p : ↑F.Duration) (hp : 0 ≤ p)
    (hpl : p ≤ l.val) (υ : Beh F l.val) :
    Beh.restrictTr (coverRight l p hp hpl) υ
      = Beh.restrict p (l.val - p) hp (sub_nonneg.mpr hpl) (by rw [add_sub_cancel]) υ := sorry

theorem compat_iff_match (l p : F.Duration) (hp : 0 ≤ p) (hpl : p ≤ l)
    (τ₁ : Beh F p) (τ₂ : Beh F (l - p)) :
    Beh.restrictTr (l' := (⟨0, le_refl 0⟩ : Obj F.Duration)) (l := ⟨p, hp⟩) (rres hp) τ₁
        = Beh.restrictTr (l' := (⟨0, le_refl 0⟩ : Obj F.Duration))
            (l := ⟨l - p, sub_nonneg.mpr hpl⟩) (lres (sub_nonneg.mpr hpl)) τ₂
      ↔ τ₁.val.states p (Beh.mem_dom τ₁ hp le_rfl)
          = τ₂.val.states 0 (Beh.mem_dom τ₂ le_rfl (sub_nonneg.mpr hpl)) := sorry

theorem sheaf_clause_site (hcomp : TaskFrame.Compositional F.TaskRel) (l : Obj F.Duration)
    (p : ↑F.Duration) (hp : 0 ≤ p) (hpl : p ≤ l.val)
    (τ₁ : Beh F p) (τ₂ : Beh F (l.val - p))
    (hmatch : τ₁.val.states p (Beh.mem_dom τ₁ hp le_rfl)
      = τ₂.val.states 0 (Beh.mem_dom τ₂ le_rfl (sub_nonneg.mpr hpl))) :
    ∃! υ : Beh F l.val,
      Beh.restrictTr (coverLeft l p hp hpl) υ = τ₁ ∧
      Beh.restrictTr (coverRight l p hp hpl) υ = τ₂ := sorry

theorem pasteAt_states_le (hcomp : TaskFrame.Compositional F.TaskRel) (σ τ : PartialHistory F)
    (t : F.Duration) (hσt : σ.domain t) (hτt : τ.domain t)
    (hmatch : σ.states t hσt = τ.states t hτt) (z : F.Duration)
    (hz : (pasteAt hcomp σ τ t hσt hτt hmatch).domain z) (hzt : z ≤ t) (hσz : σ.domain z) :
    (pasteAt hcomp σ τ t hσt hτt hmatch).states z hz = σ.states z hσz := sorry

theorem pasteAt_states_not_le (hcomp : TaskFrame.Compositional F.TaskRel) (σ τ : PartialHistory F)
    (t : F.Duration) (hσt : σ.domain t) (hτt : τ.domain t)
    (hmatch : σ.states t hσt = τ.states t hτt) (z : F.Duration)
    (hz : (pasteAt hcomp σ τ t hσt hτt hmatch).domain z) (hzt : ¬ z ≤ t) (hτz : τ.domain z) :
    (pasteAt hcomp σ τ t hσt hτt hmatch).states z hz = τ.states z hτz := sorry

theorem isTotal_pasteAt (hcomp : TaskFrame.Compositional F.TaskRel) (ρ σ : WorldHistory F)
    (t : F.Duration) (hmatch : ρ.val.states t (ρ.property t) = σ.val.states t (σ.property t)) :
    (pasteAt hcomp ρ.val σ.val t (ρ.property t) (σ.property t) hmatch).IsTotal := sorry

theorem paste_eq_pasteAt [F.IsRegular] (ρ σ : WorldHistory F) (t : F.Duration)
    (hsame : ρ.state t = σ.state t) :
    paste ρ σ t hsame
      = ⟨pasteAt F.comp ρ.val σ.val t (ρ.property t) (σ.property t) hsame,
         isTotal_pasteAt F.comp ρ σ t hsame⟩ := sorry

end FormalSystem.Semantics.Presheaf
```

## Testing & Validation

- [ ] `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem` exits
      0 at the end of **every** phase, run detached, verdict read from the guard's `result`
- [ ] No new `sorry` anywhere at the end of every phase:
      `grep -rn 'sorry' FormalSystem/Semantics/Presheaf/ FormalSystem/PlusLanguage/PlusPasting.lean FormalSystem/Semantics/PartialHistory.lean FormalSystem/Semantics/TaskFrame.lean`
      returns nothing
- [ ] Choice-freedom, measured not asserted: `#print axioms` (or `lean_verify`) reports
      `[propext]` for `TaskFrame.reflection_of_ne` and `[propext, Quot.sound]` with **no**
      `Classical.choice` for `rel_across_seam`, `glue`, `restrict_glue_left`,
      `restrict_glue_right`, `glue_unique`, `sheaf_clause`, `compat_iff_match`,
      `sheaf_clause_site`, `pasteAt`, `paste_eq_pasteAt` — and for `PlusLanguage.paste`, which
      starts the task at `[propext, Classical.choice, Quot.sound]`
- [ ] Signature preservation: `git diff -U0` over the whole task shows no change to the signature
      lines of `paste_rel_le_lt`, `paste_rel`, `paste`, `paste_agreeFrom` or `paste_agreeUpTo`
- [ ] `bash scripts/check-module-invariants.sh --no-build` green on C8, C9, C15, C20, C24, C26,
      C31, C33, C34a, C34b and INV
- [ ] `bash scripts/readme-lint.sh FormalSystem` exits 0
- [ ] `bash scripts/check-copyright-headers.sh --strict FormalSystem` exits 0
- [ ] `bash scripts/typst-sync-check.sh --counts-only` exits 0 before each commit (this is what
      `.githooks/pre-commit` runs)
- [ ] `bash scripts/check-paper-definitions.sh`'s exit code is unchanged from the task's start —
      the pre-existing `def:BX` drift is not this task's and must be reported, not fixed
- [ ] Final full-project verification after Phase 4:
      `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build` exits 0
- [ ] Reproduce the three probes once more at the end, as the transcription audit:
      `lake env lean specs/564_sheaf_clause_gluing_and_starpasting_generalization/probes/0{1,2,3}_*.lean`
      each exit 0

## Artifacts & Outputs

- `FormalSystem/Semantics/Presheaf/Sheaf.lean` — new module: `glue`, its two reading equations,
  both restriction identities, `states_eq_of_eq`, `glue_unique`, `sheaf_clause`,
  `restrictTr_coverLeft`, `restrictTr_coverRight`, `compat_iff_match`, `sheaf_clause_site`, and
  the two-sense choice-freedom record
- `FormalSystem/Semantics/TaskFrame.lean` — `TaskFrame.reflection_of_ne`
- `FormalSystem/Semantics/PartialHistory.lean` — `PartialHistory.rel_across_seam`
- `FormalSystem/PlusLanguage/PlusPasting.lean` — `paste_rel_le_lt` as a delegation, `paste_rel`
  rerouted through the off-zero law, and `pasteAt` + `pasteAt_states_le` +
  `pasteAt_states_not_le` + `isTotal_pasteAt` + `paste_eq_pasteAt`
- `FormalSystem/Semantics/Presheaf/README.md` — inventory, Key Definitions, Key Results
- `docs/reference/paper-definitions-of-record.md` — two amended row descriptions
- Shared/regenerated, outside `Files to modify` by design: `FormalSystem/Semantics/Presheaf.lean`,
  `FormalSystem.lean`, `README.md`, `FormalSystem/README.md`, `typst/generated/status.typ`
- `specs/564_…/summaries/02_*-summary.md` — the implementation summary, recording each gate's exit
  code and every `#print axioms` row

## Rollback/Contingency

The phases are independently green and independently committed, so the ordinary contingency is to
stop at the last green phase rather than to revert: Phases 1–3 deliver the Sheaf clause and the
de-duplication without Phase 4, and Phase 1 alone delivers the de-duplication the task exists to
produce. Closing a phase short is `[COMPLETED WITH EXCLUSIONS]` plus a `#### Reasoned Exclusions`
record enumerating every remaining item — never `[BLOCKED]` for a deliberate cut, and never
`[DESCOPED]`, which is not a recognized marker.

If a genuine rollback of **uncommitted** work is needed, take the snapshot first using the
invocation shape in `context/contracts/recovery.md`'s rollback rung (including its
out-of-scope override flag for the deliberate whole-tree case), then run the destructive command.
Do **not** emit a bare reverting `git-snapshot.sh` as a precaution before risky work: use
`--no-revert`, which is durable without touching the working tree.

Two task-specific cautions. First, a sibling task is live on this same working tree this cycle and
owns three of the regenerated files, so a revert must never be taken with a directory or glob
pathspec — revert by explicit file list, and if a foreign hunk is present inside a generated block,
STOP and report instead. Second, `paste`'s consumers are the risk surface for Phase 1: if the
delegation or the reflection reroute breaks any of the six pasting validities, the correct move is
to restore `paste_rel_le_lt`'s original eight-line body (it is in git history and in the module's
own diff) and keep `rel_across_seam` — the lemma is sound independently of whether `paste_rel_le_lt`
delegates to it, and the clause in Phases 2–3 needs only the lemma.
