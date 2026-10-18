# Implementation Plan: Task #617

- **Task**: 617 - Reflection clause: converse frame and naturality
- **Status**: [NOT STARTED]
- **Effort**: 3.5 hours
- **Dependencies**: 563 (`Beh(F)` and `Int(D)`) — satisfied; `Presheaf/Site.lean` and `Presheaf/Behavior.lean` are in the tree
- **Research Inputs**: specs/617_reflection_clause_converse_frame_naturality/reports/01_reflection-clause-converse-frame.md
- **Artifacts**: plans/01_reflection-clause-converse-frame.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Discharge the *Reflection* clause of `app:presheaf-dictionary` as one new module,
`FormalSystem/Semantics/Presheaf/Reflection.lean`: the reflection automorphism `ref` of the
interval site with its five laws, the section reflection `τ^r(z) = τ(ℓ - z)` landing in
`Beh(F⁻)(ℓ)`, naturality in the translations, the involution, and the component bijections as an
`Equiv`. The converse frame `F⁻` is **consumed, not rebuilt**: `FrameOver.rev` / `TaskFrame.rev`
and their laws are already sited in `FormalSystem/Semantics/TaskFrame.lean` (section
`ConverseFrame`), which is in the Presheaf cluster's import closure through
`Semantics/PartialHistory.lean`. Definition of done: the module compiles under the cluster's
`assert_not_exists` lock with zero sorries, every result measures choice-free, the aggregator,
README and the paper-definitions record carry the clause, and `lake build FormalSystem` is green.

### Research Integration

The report's proof route, statements and tactic survey are adopted unchanged: every declaration
below was compiled in the saved probe
(`specs/617_reflection_clause_converse_frame_naturality/reflection-clause-probe.lean`) with zero
sorries and axiom profile `[propext, Quot.sound]`.

**One recommendation is dropped, with re-derived evidence.** The report's Phase A — promote the
frame-level reversal block out of `OpenLanguage/OpenReversal.lean` into `Semantics/TaskFrame.lean`,
widening `file_scope` and raising a non-blocking `user_decision` — was written against the tree of
2026-10-13. It has since been done by another task: commit `bf33d8e71` landed the `ConverseFrame`
section in `Semantics/TaskFrame.lean` (`FrameOver.rev`, `rev_isRegular`, `rev_taskRel`,
`rev_taskRel_neg`, `rev_rev`, `@[reducible] TaskFrame.rev`, `TaskFrame.rev_rev`) together with
`Semantics/Reversal.lean`, and `OpenReversal.lean` now imports both and declares none of them. At
plan time the saved probe was recompiled with its simulated promotion block stripped
(`import Mathlib.Tactic.Abel`, `import FormalSystem.Semantics.Presheaf.Behavior`, no
`OpenLanguage` import): exit 0, all five `#print axioms` lines `[propext, Quot.sound]`, and the
closing `assert_not_exists FormalSystem.ProofSystem.Axiom` passes. The clause therefore needs no
scope widening and no user decision; the research's conditional `user_decision` is moot and is not
raised.

Carried figures from the report that this plan relies on and re-verified at authoring time:
`Mathlib.Tactic.Abel` is not in the cluster closure (confirmed necessary by the recompile — the
four `abel` calls are live); `schultz2020` and `johnstone1999` resolve in the root `references.bib`
(lines 830, 841); `validOn_rev_iff` is the formalized `thm:TR-valid` in `Semantics/Validity.lean`
(line 514) and `truthAt_rev` is `lem:time-reflection` in `Semantics/Reversal.lean`.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

Not consulted: this dispatch carries no `roadmap_path`.

## Goals & Non-Goals

**Goals**:
- `Tr.ref`, `Tr.ref_shift`, `Tr.ref_ref`, `Tr.ref_id`, `Tr.ref_comp`, `Tr.ref_lres`, `Tr.ref_rres`
- `Beh.reflectSec`, `Beh.reflectSec_states`, `Beh.reflect_natural`, `Beh.reflect_reflect`, `Beh.reflectEquiv`
- A module docstring that states, in its own words, why this clause matters: the natural
  isomorphism `Beh(F) ≅ Beh(F⁻) ∘ ref` is what underlies the soundness of the time reflection
  metarule `TR` (`thm:TR-valid`, formalized as `validOn_rev_iff`), and the reflection convention on
  the task relation supplies the involution by definition (`rev_taskRel` is `Iff.rfl`,
  `TaskFrame.rev_rev` is `rfl`), which is why the clause consumes no frame constraint at all
- The clause wired into the cluster: the aggregator import, the README inventory row and prose,
  and the `app:presheaf-dictionary` / `def:behavior-presheaf` rows of
  `docs/reference/paper-definitions-of-record.md`

**Non-Goals**:
- A second converse-frame construction. `FrameOver.rev` / `TaskFrame.rev` in
  `Semantics/TaskFrame.lean` are the paper's `F⁻` and are consumed as they stand
- A `CategoryTheory.Functor` instance for `ref`. `Site.lean` records the decision to state the
  site concretely with no `Mathlib.CategoryTheory` import; `ref` is a plain `def` on `Tr` with its
  laws as plain theorems, following that decision
- The BL truth transfer under reflection and `thm:TR-valid` themselves — already formalized
  (`truthAt_rev`, `validOn_rev_iff`) and only pointed to from the docstring
- Any edit to `OpenLanguage/OpenReversal.lean` or to the `ConverseFrame` section of
  `Semantics/TaskFrame.lean`
- The `swapUS`/`swapMinus` families named in the task description: they do not exist in the tree
  (research grep; recorded in the task issue log)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| The aggregator `FormalSystem/Semantics/Presheaf.lean` is a shared touch outside every task's `file_scope` on this front; a concurrently dispatched sibling (566, 616 — both in *plan* phase this cycle, not implement) could clobber the one-line import | M | L | Make the aggregator edit last (Phase 3); re-read the file immediately before editing; stage only this task's hunk with an explicit-file `git add`; re-run the guarded build after the edit |
| `abel` is absent from the cluster's import closure and fails as a bare `unknown tactic` | M | L | `import Mathlib.Tactic.Abel` in `Reflection.lean` — confirmed sufficient by the probe, and confirmed to leave the `assert_not_exists` lock intact; in-cluster precedent `Semantics/Extension/Constraint.lean` |
| `lean-challenge-snapshot.sh` cross-validates the `## Lean Challenge Statements` identifier set against the `**Goals**:` identifiers and fails on any disagreement | M | L | The two lists in this plan are copied from one source; the implementer MUST NOT rename a declaration without editing both |
| `scripts/check-module-invariants.sh --emit-inventory` regenerates every row of the README inventory table, not only the new one, so unrelated rows (line counts) may move | L | M | Run `--emit-inventory --check` first to see the delta; accept the generator's output as authoritative; mention any unrelated-row movement in the phase commit message |
| Full `lake build FormalSystem` at the final gate is long on a loaded host | M | M | Route through `lake-build-guard.sh build --timeout 1800` with the Bash tool timeout raised to 600000, or detach and block via the bounded single-call idiom in `context/project/lean4/operations/long-builds.md`; never an unbounded foreground call |
| The paper anchors `app:presheaf-dictionary`, `def:behavior-presheaf`, `app:Structure` stay `DANGLING` (cut from the paper; text in `appendix_cut_material.tex` and in the paper repo's git history) | L | H (certain) | Follow the sibling modules: cite with the `DANGLING` marker and record the cut at each citation site; the record file rows are edited, not pinned |
| `Beh.reflect_reflect` is stated at `F.rev.rev`, which must be `F` by `rfl` | M | L | `TaskFrame.rev` is `@[reducible]` and `TaskFrame.rev_rev` is `rfl` — the probe states and proves the round trip with no cast; if an elaboration order changes this, state through `F.rev.rev` with an explicit `(F := F.rev)` as the probe does |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |

Phases within the same wave can execute in parallel. This plan is fully sequential: Phases 1 and 2
edit the same new module, and Phase 3's wiring and full gate must observe both.

### Phase 1: The reflection automorphism of `Int(D)` [NOT STARTED]

**Goal**: Create `FormalSystem/Semantics/Presheaf/Reflection.lean` with its full module docstring
and the reflection automorphism `ref` on translations, together with its five laws: it fixes
identities, preserves composition (covariantly — `ref` fixes objects and is an automorphism, not a
duality), is its own inverse, and interchanges `lres` with `rres`.

**Tasks**:
- [ ] Create the module with the repository header, `import FormalSystem.Init`,
      `import Mathlib.Tactic.Abel`, `import FormalSystem.Semantics.Presheaf.Behavior`, the
      `/-! ... -/` module docstring (structure as `Presheaf/Determinism.lean`: title, narrative,
      `## Main Definitions`, `## Main Results`, `## Implementation Notes`, `## References`,
      `## Tags`), `namespace FormalSystem.Semantics.Presheaf`, and the closing
      `assert_not_exists FormalSystem.ProofSystem.Axiom FormalSystem.ProofSystem.DerivationTree`
- [ ] Write the docstring's load-bearing paragraphs now, not as a Phase 3 afterthought:
      (a) **the point of the clause** — the natural isomorphism `Beh(F) ≅ Beh(F⁻) ∘ ref` is what
      underlies the soundness of the time reflection metarule `TR` (`thm:TR-valid`, formalized as
      `validOn_rev_iff` in `Semantics/Validity.lean`, resting on `truthAt_rev` in
      `Semantics/Reversal.lean`); the reflection convention on the task relation supplies the
      involution by definition (`FrameOver.rev_taskRel` is `Iff.rfl`, `TaskFrame.rev_rev` is
      `rfl`), so the clause reaches no field of `FrameOver.IsRegular` — along with the
      *Determinism* clause of `Presheaf/Determinism.lean`, one of the few places where the
      categorical packaging says something about the logic rather than restating the semantics;
      (b) **reuse** — the converse frame is `FrameOver.rev` / `TaskFrame.rev` of
      `Semantics/TaskFrame.lean`, consumed through `rev_taskRel`; no second construction is
      defined; `Semantics/TruthTransport.lean`'s `TruthAntiIso` is a model-level transport that
      takes both frames as given, and `Formula.reflectTime` is syntactic — neither is a converse
      frame and neither is duplicated; (c) **the two forms of `⇒⁻`** — the clause is stated over
      the primitive reversal `rev_taskRel`; the paper's negated form `w ⇒⁻_x u := w ⇒_{-x} u` is
      `rev_taskRel_neg`, which needs `[F.IsRegular]`, and is cited as the bridge, not used;
      (d) **no `Functor` instance**, following `Site.lean`'s recorded decision
- [ ] Write `## References` in the normal form of `docs/development/REFERENCE_NORMAL_FORM.md`:
      `[P. Schultz, D. I. Spivak and C. Vasilakopoulou, *Dynamical Systems and Sheaves*][schultz2020]`;
      `[P. T. Johnstone, *A Note on Discrete Conduché Fibrations*][johnstone1999]`; the JPL anchors
      `def:behavior-presheaf` (*Reflection*, *Converse Frame*, *Reflection Automorphism* clauses),
      `app:presheaf-dictionary` (*Reflection* clause and proof paragraph) and `app:Structure`, each
      marked **`DANGLING`** with the cut recorded, text in
      `/home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/appendix_cut_material.tex`;
      `thm:TR-valid` and `lem:time-reflection` (LIVE); and the repository modules
      `Presheaf/Site.lean`, `Presheaf/Behavior.lean`, `Semantics/TaskFrame.lean` (the
      `ConverseFrame` section), `Semantics/Reversal.lean`, `Semantics/Validity.lean`
- [ ] Define `Tr.ref` with `ref_shift` (`@[simp]`, `rfl`); the two side conditions discharge from
      `f.shift_add_le` and `f.shift_nonneg` via `sub_nonneg`, `le_sub_iff_add_le`,
      `sub_add_cancel`, `sub_le_self` exactly as in the probe
- [ ] Prove `Tr.ref_ref` and `Tr.ref_comp` (`ext; simp; abel`), `Tr.ref_id` (`ext; simp`),
      `Tr.ref_lres` and `Tr.ref_rres` (`ext; simp [lres, rres]`)
- [ ] Give every declaration a `/-- ... -/` docstring carrying the line
      `Constraints consumed: None` (closed vocabulary of `REFERENCE_NORMAL_FORM.md` §3; check C34
      of `scripts/check-module-invariants.sh` reads it)
- [ ] Record the issue log as events arise (`issue-record.sh --phase implement`), including an
      explicit "nothing to record" attestation in the phase commit if that is the case

**Timing**: 0.75 hours

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: Seven declarations (`Tr.ref` and six lemmas) in one new file; confirm by
`grep -c '^def \|^theorem \|^@\[simp\] theorem ' FormalSystem/Semantics/Presheaf/Reflection.lean`
after the phase, expecting 7.

**Tier Justification**: `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build
FormalSystem.Semantics.Presheaf.Reflection` is the complete covering check — the module is new and
nothing imports it until Phase 3, so no other module can observe this phase.

**Files to modify**:
- `FormalSystem/Semantics/Presheaf/Reflection.lean` - create: header, module docstring, `Tr.ref` and its six laws, `assert_not_exists` lock

**Verification**:
- Guarded scoped build of `FormalSystem.Semantics.Presheaf.Reflection` exits 0 with no `sorry`
  warning and no `unknown tactic` error
- `#print axioms` on `Tr.ref_ref` and `Tr.ref_comp` (via `lake env lean` on a scratch probe or a
  temporary `#print axioms` line removed before commit) reports `[propext, Quot.sound]`
- The file ends with the `assert_not_exists` line and it passes
- Commit: `task 617 phase 1: the reflection automorphism of Int(D)`

---

### Phase 2: The section reflection, naturality, and the component bijections [NOT STARTED]

**Goal**: Add the section reflection `Beh.reflectSec` landing in `Beh F.rev l.val`, its reading
equation, naturality in the translations against `Tr.ref`, the involution `(τ^r)^r = τ`, and the
`Equiv` `Beh F l.val ≃ Beh F.rev l.val`; measure and record the axiom profile.

**Tasks**:
- [ ] Define `Beh.reflectSec {F} (l : Obj F.Duration) (τ : Beh F l.val) : Beh F.rev l.val` with
      domain `0 ≤ z ∧ z ≤ l.val`, states `τ.val.states (l.val - z) _` via `Beh.mem_dom`, and
      `respects_task` through `(FrameOver.rev_taskRel F.toFibre _ (t - s) _).mpr` and
      `τ.val.respects_task (l.val - t) (l.val - s)`, closing the time identity by `abel`
- [ ] Prove `Beh.reflectSec_states` (`rfl`)
- [ ] Prove `Beh.reflect_natural`: `reflectSec l' (Beh.restrictTr f τ) = Beh.restrictTr (F := F.rev)
      (Tr.ref f) (reflectSec l τ)` via `Beh.ext (partialHistory_ext rfl ?_)` and
      `PartialHistory.states_eq_of_time_eq` with the time equality by `abel`
- [ ] Prove `Beh.reflect_reflect`: `reflectSec (F := F.rev) l (reflectSec l τ) = τ`; the domain
      half by `propext ((τ.property z).symm)`, the states half as in naturality with
      `l.val - (l.val - r) = r` by `abel`
- [ ] Define `Beh.reflectEquiv (F) (l) : Beh F l.val ≃ Beh F.rev l.val` with `toFun := reflectSec l`,
      `invFun := reflectSec (F := F.rev) l`, both inverse laws from `reflect_reflect` — the
      `Equiv` form by analogy with `Beh.germEquiv`
- [ ] Every declaration docstring carries `Constraints consumed: None`
- [ ] Measure `#print axioms` on `Beh.reflect_natural`, `Beh.reflect_reflect`,
      `Beh.reflectEquiv` and record the measured profile in the module docstring's
      `## Implementation Notes` ("Measured axiom profile", as `Determinism.lean` does), together
      with the sentence that the clause is choice-free in both of the README's measured senses
- [ ] Record the issue log as events arise

**Timing**: 1.25 hours

**Depends on**: 1

**Verification Tier**: local

**Scope Hypothesis**: Five further declarations, twelve in the module in total; confirm with the
Phase 1 grep, expecting 12. The challenge-statement identifier set in `## Lean Challenge
Statements` below must then equal the `**Goals**:` list — confirm with
`bash .claude/scripts/lean-challenge-snapshot.sh --check` if a Challenge module has been
snapshotted for this task, else by eye.

**Tier Justification**: The same guarded scoped build of
`FormalSystem.Semantics.Presheaf.Reflection` remains the complete covering check — the module is
still unimported, so nothing outside it can break.

**Files to modify**:
- `FormalSystem/Semantics/Presheaf/Reflection.lean` - add the section reflection, the three results, the `Equiv`, and the measured axiom record in the docstring

**Verification**:
- Guarded scoped build exits 0 with no `sorry` warning
- `#print axioms` on `Beh.reflect_natural`, `Beh.reflect_reflect`, `Beh.reflectEquiv` reports
  `[propext, Quot.sound]` and no `Classical.choice`
- The `assert_not_exists` lock still passes
- Commit: `task 617 phase 2: section reflection, naturality, and the component bijections`

---

### Phase 3: Wiring, records, and the full gate [NOT STARTED]

**Goal**: Make the module part of the cluster and the record of the paper: the aggregator import
and module bullet, the README inventory row and prose, the paper-definitions-of-record rows, the
cross-pointer in `Semantics/Reversal.lean`, then the complete gate set and a green
`lake build FormalSystem`.

**Tasks**:
- [ ] **Aggregator (shared touch — handle last among the edits, per the task's SCOPE AND
      AGGREGATOR CONTENTION note)**: re-read `FormalSystem/Semantics/Presheaf.lean` immediately
      beforehand; add `import FormalSystem.Semantics.Presheaf.Reflection` in alphabetical position
      and a `- \`Presheaf.Reflection\` — ...` bullet to its `## Modules` list; check `git log -1 --
      FormalSystem/Semantics/Presheaf.lean` and `git status --short` for a foreign in-flight edit
      first and STOP and report if one is found
- [ ] `FormalSystem/Semantics/Presheaf/README.md`: add a prose paragraph on the *Reflection*
      clause (what it says, that it is constraint-free and why, that it is the categorical
      packaging of the involution behind `TR`, and that it consumes the converse frame of
      `Semantics/TaskFrame.lean`); update the "Four clauses ... are discharged here" count and the
      module-count sentences; add `Tr.ref`, `Beh.reflectSec`, `Beh.reflectEquiv` to
      `## Key Definitions`; regenerate the inventory table with
      `bash scripts/check-module-invariants.sh --emit-inventory` (after `--emit-inventory --check`
      to see the delta)
- [ ] `docs/reference/paper-definitions-of-record.md`: extend the `app:presheaf-dictionary`
      `DANGLING` row with the *Reflection* clause's formalization (`Tr.ref` and its laws,
      `Beh.reflectSec`, `Beh.reflect_natural`, `Beh.reflectEquiv` in
      `FormalSystem/Semantics/Presheaf/Reflection.lean`, consuming `FrameOver.rev` of
      `Semantics/TaskFrame.lean`), and the `def:behavior-presheaf` row with the *Reflection*,
      *Converse Frame* and *Reflection Automorphism* clauses now formalized; update the citation-site
      count ("All six citation sites" becomes seven) — hand edit, no re-pin, the anchors remain
      unpinnable
- [ ] `FormalSystem/Semantics/Reversal.lean`: tighten the `## References` bullet that currently
      points at `FormalSystem/Semantics/Presheaf/` generically so it names
      `Presheaf/Reflection.lean` and `Beh.reflectEquiv`
- [ ] Record the issue log as events arise; attest explicitly if nothing arose
- [ ] Run the complete gate set (below); fix forward on any failure — never discard uncommitted
      work to reach green

**Timing**: 1.5 hours

**Depends on**: 2

**Verification Tier**: full

**Scope Hypothesis**: Four files edited plus the aggregator; the record file's
`app:presheaf-dictionary` row currently reads "All six citation sites record the cut" (carried
from a plan-time read of line 2498) — confirm the count and the row's current text by re-reading
before editing, since sibling tasks on this front edit the same rows.

**Files to modify**:
- `FormalSystem/Semantics/Presheaf/README.md` - Reflection clause prose, counts, Key Definitions, regenerated inventory row
- `docs/reference/paper-definitions-of-record.md` - `app:presheaf-dictionary` and `def:behavior-presheaf` rows record the formalization
- `FormalSystem/Semantics/Reversal.lean` - one `## References` bullet names `Presheaf/Reflection.lean`
- `FormalSystem/Semantics/Presheaf/Reflection.lean` - final docstring touch-ups only, if the gate demands any
- Shared touch deliberately not listed as a path entry, per the task description's instruction not to widen `file_scope` to the cluster aggregator: the one-line import and module bullet in FormalSystem/Semantics/Presheaf.lean (the file every module-adding task on this front must touch; handled with the re-read / own-hunk-only / rebuild discipline named in the Tasks)

**Verification** (the complete gate set — `full` tier, nothing deferred):
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem` exits 0;
  `bash .claude/scripts/lean-sorry-census.sh` (or `grep -rn "sorry" FormalSystem/Semantics/Presheaf/Reflection.lean`)
  shows no new sorry
- `bash scripts/check-module-invariants.sh` exits 0 (C24: the new module is in the root closure
  through the aggregator; C34: every `Constraints consumed:` marker is well-formed;
  `--emit-inventory --check` is byte-stable)
- `bash scripts/check-paper-definitions.sh` exits 0 — the three cut anchors remain `DANGLING`
  rows, no pin attempted
- `bash .claude/scripts/verify-deploy.sh` exits 0 (the repository's complete gate set, every gate
  — no `--only-gate`, no `--skip-slow`)
- `bash .claude/scripts/check-task-references.sh` (or the task-reference gate of `verify-deploy.sh`)
  reports no task-number citation in `FormalSystem/**` or `docs/**` from this task
- Commit: `task 617 phase 3: wiring, records, and the full gate`, staged by explicit file list
  (`git add -- <files>`), never a directory or glob

## Lean Challenge Statements

```lean
import Mathlib.Tactic.Abel
import FormalSystem.Semantics.Presheaf.Behavior

namespace FormalSystem.Semantics.Presheaf

def Tr.ref {D : TemporalOrder} {l' l : Obj D} (f : Tr l' l) : Tr l' l := sorry

@[simp] theorem Tr.ref_shift {D : TemporalOrder} {l' l : Obj D} (f : Tr l' l) :
    (Tr.ref f).shift = l.val - f.shift - l'.val := sorry

theorem Tr.ref_ref {D : TemporalOrder} {l' l : Obj D} (f : Tr l' l) :
    Tr.ref (Tr.ref f) = f := sorry

theorem Tr.ref_id {D : TemporalOrder} (l : Obj D) : Tr.ref (Tr.id l) = Tr.id l := sorry

theorem Tr.ref_comp {D : TemporalOrder} {l'' l' l : Obj D} (f : Tr l' l) (g : Tr l'' l') :
    Tr.ref (Tr.comp f g) = Tr.comp (Tr.ref f) (Tr.ref g) := sorry

theorem Tr.ref_lres {D : TemporalOrder} {l l' : Obj D} (h : l'.val ≤ l.val) :
    Tr.ref (lres h) = rres h := sorry

theorem Tr.ref_rres {D : TemporalOrder} {l l' : Obj D} (h : l'.val ≤ l.val) :
    Tr.ref (rres h) = lres h := sorry

def Beh.reflectSec {F : TaskFrame} (l : Obj F.Duration) (τ : Beh F l.val) :
    Beh F.rev l.val := sorry

theorem Beh.reflectSec_states {F : TaskFrame} (l : Obj F.Duration) (τ : Beh F l.val)
    (z : F.Duration) (hz : (Beh.reflectSec l τ).val.domain z) (h' : τ.val.domain (l.val - z)) :
    (Beh.reflectSec l τ).val.states z hz = τ.val.states (l.val - z) h' := sorry

theorem Beh.reflect_natural {F : TaskFrame} {l' l : Obj F.Duration} (f : Tr l' l)
    (τ : Beh F l.val) :
    Beh.reflectSec l' (Beh.restrictTr f τ)
      = Beh.restrictTr (F := F.rev) (Tr.ref f) (Beh.reflectSec l τ) := sorry

theorem Beh.reflect_reflect {F : TaskFrame} (l : Obj F.Duration) (τ : Beh F l.val) :
    Beh.reflectSec (F := F.rev) l (Beh.reflectSec l τ) = τ := sorry

def Beh.reflectEquiv (F : TaskFrame) (l : Obj F.Duration) : Beh F l.val ≃ Beh F.rev l.val :=
  sorry

end FormalSystem.Semantics.Presheaf
```

## Testing & Validation

- [ ] Phases 1-2: guarded scoped build of `FormalSystem.Semantics.Presheaf.Reflection` green, no
      sorry, `assert_not_exists` lock passes
- [ ] Phase 2: `#print axioms` on `Beh.reflect_natural`, `Beh.reflect_reflect`,
      `Beh.reflectEquiv`, `Tr.ref_ref`, `Tr.ref_comp` each `[propext, Quot.sound]`
- [ ] Phase 3: `lake build FormalSystem` green through the guard; `check-module-invariants.sh`,
      `check-paper-definitions.sh`, `verify-deploy.sh` all exit 0
- [ ] The `**Goals**:` identifier list and the `## Lean Challenge Statements` declaration set are
      identical (twelve identifiers)
- [ ] No duplicate converse frame: `grep -rn "def .*rev\b\|converse" FormalSystem/Semantics/Presheaf/Reflection.lean`
      shows no new frame construction, only consumption of `FrameOver.rev` / `TaskFrame.rev`
- [ ] No task-number reference in any file outside `specs/**`

## Artifacts & Outputs

- `FormalSystem/Semantics/Presheaf/Reflection.lean` — the new module (twelve declarations)
- `FormalSystem/Semantics/Presheaf.lean` — one import line and one module bullet
- `FormalSystem/Semantics/Presheaf/README.md` — Reflection clause prose, inventory row, key definitions
- `docs/reference/paper-definitions-of-record.md` — two extended `DANGLING` rows
- `FormalSystem/Semantics/Reversal.lean` — one sharpened `## References` bullet
- `specs/617_reflection_clause_converse_frame_naturality/summaries/01_reflection-clause-converse-frame-summary.md`
  — written at implementation completion

## Rollback/Contingency

Each phase closes with exactly one commit and each sub-step is committed green, so a failed phase
is isolated by construction. If the Phase 3 full gate cannot be made green by fixing forward, the
module can be left out of the aggregator (reverting only the one-line import and bullet in
`FormalSystem/Semantics/Presheaf.lean` by an ordinary edit) so the rest of the tree builds while
the module is repaired — C24 would then flag the orphan, which is the intended signal, and the
phase stays `[PARTIAL]`. If uncommitted work must actually be discarded, follow
`context/contracts/recovery.md`'s rollback rung: `bash .claude/scripts/git-snapshot.sh 617` first
(with `--allow-out-of-scope` only for the deliberate whole-tree case), then the destructive
command; never a bare `git checkout --`/`git reset --hard` on a dirty tree, and never a
precautionary default-mode snapshot at the start of a phase (`--no-revert` is the durable
checkpoint form).
