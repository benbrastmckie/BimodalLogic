# Research Report: Task #617

**Task**: 617 - Reflection clause: converse frame and naturality
**Started**: 2026-10-13T09:45:41Z
**Completed**: 2026-10-13T10:40:00Z
**Effort**: Small — one new module of roughly 120 proof lines, plus a frame-level promotion of about 60 existing lines
**Dependencies**: 563 (`Beh(F)` and `Int(D)`) — satisfied; `Site.lean` and `Behavior.lean` are both in the tree
**Sources/Inputs**: - Codebase (`FormalSystem/Semantics/Presheaf/`, `FormalSystem/Semantics/TaskFrame.lean`, `FormalSystem/OpenLanguage/OpenReversal.lean`), lean-lsp MCP (`lean_local_search`), compiled probes via `lake env lean`, the JPL paper's `app:presheaf-dictionary` recovered from the paper repository's git history
**Artifacts**: - `specs/617_reflection_clause_converse_frame_naturality/reports/01_reflection-clause-converse-frame.md`
  - `specs/617_reflection_clause_converse_frame_naturality/reflection-clause-probe.lean` (the verified probe, compiling clean)
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **The whole clause is already proved.** A compiled probe implements the reflection
  automorphism with all five of its laws, the section reflection, naturality, the involution and
  the component `Equiv`. It compiles with zero errors and zero sorries, and every result measures
  `[propext, Quot.sound]` — choice-free, matching the rest of the cluster. The probe is saved
  beside this report.
- **The converse frame already exists and must be consumed, not rebuilt.** `FrameOver.rev` /
  `TaskFrame.rev` in `FormalSystem/OpenLanguage/OpenReversal.lean` are exactly the paper's `F⁻`,
  together with `rev_taskRel`, the paper-form bridge `rev_taskRel_neg`, the involution `rev_rev`,
  and an `IsRegular` inheritance instance.
- **Consuming it requires a layering promotion, which widens file_scope.** `OpenReversal.lean`
  sits above the `Semantics` layer. A probe proved that importing it into the Presheaf cluster
  trips that cluster's `assert_not_exists FormalSystem.ProofSystem.Axiom` guard through a
  ten-link import chain. The frame-level reversal block has to move down into `Semantics/` first.
  `OpenReversal.lean`'s own siting note pre-authorizes exactly this move.
- **The clause consumes no frame constraints at all.** It needs only `FrameOver.rev_taskRel`,
  which is `Iff.rfl`. `[F.IsRegular]` is never reached, so every declaration's
  constraint-consumption line reads `None`. This is the formal content of the task's claim that
  the reflection convention supplies the involution by definition rather than by assumption.
- **The paper text was recovered from git history.** The dispatch's instruction to read the
  Reflection clauses as commented-out text in `possible_worlds.tex` cannot be followed; the
  commented block was later deleted. The full text is quoted below.

## Context & Scope

The task asks for `app:presheaf-dictionary`'s *Reflection* clause: that reflection is a natural
isomorphism `Beh(F) ≅ Beh(F⁻) ∘ ref`. Four deliverables are named — the section reflection, the
converse frame, the reflection automorphism of `Int(D)` with its three laws, and the clause
itself (well-definedness, naturality, bijectivity).

Research covered: what the paper actually says; what converse and time-reflection machinery the
repository already carries; whether that machinery is reachable from the Presheaf cluster; and
whether the clause's mathematics goes through in the repository's concrete `Tr`/`Beh` encodings.
Constraints taken as binding: no duplicate converse frame, no new sorry, `lake build
FormalSystem` green, and the declared `file_scope` of a single module
`FormalSystem/Semantics/Presheaf/Reflection.lean`.

Out of scope and deliberately untouched: the `swapUS`/`swapMinus` families the description names
as under review. They do not exist anywhere in the tree, and the task that was to review them is
absent from `specs/state.json`.

## Literature Proof Structure

**Source**: JPL paper `possible_worlds.tex`, `def:behavior-presheaf` and `app:presheaf-dictionary`
(*Reflection* clause and its proof paragraph), inside the cut appendix `app:Structure`.
**Strategy**: Direct construction. Build the automorphism, check functor laws, check the
reflected section is a section of the converse presheaf, check one naturality square, then get
bijectivity from two involutions.

**Where the text is.** The dispatch says both clauses are commented out inside the `% SECTION
CUT` block. They are not: the commented appendix was removed by a later cleanup commit
("retire pre-existing source comments and dead commented-out blocks"), leaving only a
one-sentence preview at line 1921 of the live file. The text survives in the paper repository's
git history at `b64b1ca0^` (the commit before "cut category-theory material"), lines 4002-4010
and 4052-4090. Quoted verbatim:

> *Reflection:* The *reflection* of `τ ∈ Beh(F)(ℓ)` is the function `τ^r := (z ↦ τ(ℓ - z))` on `[0, ℓ]`.
>
> *Converse Frame:* The *converse frame* of `F` is defined `F⁻ := ⟨W, D, ⇒⁻⟩` where
> `w ⇒⁻_x u := w ⇒_{-x} u` for all `x ∈ D`.
>
> *Reflection Automorphism:* The *reflection automorphism* `ref : Int(D) → Int(D)` is the
> involutive automorphism fixing objects and sending `Tr p : ℓ' → ℓ` to `Tr (ℓ - p - ℓ') : ℓ' → ℓ`,
> thereby interchanging left and right restrictions.
>
> *Reflection:* Reflection is a natural isomorphism `Beh(F) ≅ Beh(F⁻) ∘ ref`.

And the proof paragraph:

> For *Reflection*, `ref` preserves composition since
> `Tr (ℓ - p - ℓ') ∘ Tr (ℓ' - p' - ℓ'') = Tr (ℓ - (p + p') - ℓ'')` for `Tr p : ℓ' → ℓ` and
> `Tr p' : ℓ'' → ℓ'`, fixes `Tr 0 : ℓ → ℓ`, and is its own inverse, sending `Tr 0 : ℓ' → ℓ` to
> `Tr (ℓ - ℓ') : ℓ' → ℓ` and conversely. The reflection `τ^r` of `τ ∈ Beh(F)(ℓ)` lies in
> `Beh(F⁻)(ℓ)` since `τ^r(z) ⇒⁻_{z' - z} τ^r(z')` just in case `τ(ℓ - z) ⇒_{z - z'} τ(ℓ - z')`,
> which is the constraint on `τ` at the times `ℓ - z` and `ℓ - z'`. Reflection is natural since
> restricting `τ` along `Tr p : ℓ' → ℓ` and then reflecting yields `z ↦ τ(p + ℓ' - z)` on
> `[0, ℓ']`, as does reflecting `τ` and then restricting along `ref(Tr p) = Tr (ℓ - p - ℓ')`. And
> each component is a bijection since `(F⁻)⁻ = F` and `(τ^r)^r = τ`. This natural isomorphism
> underlies the soundness of the time reflection metarule TR in `thm:TR-valid`, where the
> reflection convention supplies the involution by definition rather than assumption.

### Step Map

1. Define `ref` on morphisms: `Tr p : ℓ' → ℓ` goes to `Tr (ℓ - p - ℓ')`, objects fixed — [Source] `def:behavior-presheaf`, *Reflection Automorphism*
2. `ref` preserves composition — [Source] proof paragraph, sentence 1
3. `ref` fixes identities — [Source] proof paragraph, sentence 1
4. `ref` is its own inverse, and interchanges left with right restriction — [Source] proof paragraph, sentence 1
5. Define `τ^r(z) = τ(ℓ - z)`; show it lies in `Beh(F⁻)(ℓ)` — [Source] proof paragraph, sentence 2
6. Naturality of reflection in the translations — [Source] proof paragraph, sentence 3
7. Each component is a bijection, via `(F⁻)⁻ = F` and `(τ^r)^r = τ` — [Source] proof paragraph, sentence 4
8. Record that the isomorphism underlies the soundness of TR — [Source] proof paragraph, sentence 5; belongs in the module docstring

### Dependencies

- Steps 2, 3 and 4 depend on Step 1.
- Step 6 depends on Steps 1 and 5.
- Step 7 depends on Step 5 and on the converse frame's own involution.
- Step 8 depends on nothing formal; it is the docstring obligation the dispatch names explicitly.

### Potential Formalization Challenges

All four anticipated challenges were probed and none survived.

- **Step 1, the inequality side conditions.** `Tr` carries `0 ≤ shift` and `shift + ℓ' ≤ ℓ`.
  `ref` needs `0 ≤ ℓ - p - ℓ'` and `(ℓ - p - ℓ') + ℓ' ≤ ℓ`. Both discharge from the two fields
  `f.shift_add_le` and `f.shift_nonneg` with `sub_nonneg`, `le_sub_iff_add_le`, `sub_add_cancel`
  and `sub_le_self`.
- **Step 5, the orientation of the task relation.** The paper's `⇒⁻` is defined by negation,
  `w ⇒⁻_x u := w ⇒_{-x} u`, which in the repository is `rev_taskRel_neg` and needs
  `[F.IsRegular]`. The repository's `FrameOver.rev` instead reverses the *primitive* relation,
  giving `rev_taskRel : F.rev.TaskRel w d u ↔ F.TaskRel u d w` as `Iff.rfl`, and that is the form
  the clause actually uses. The clause is therefore constraint-free and the paper's negated form
  is available as the bridge lemma rather than as the working definition.
- **Step 7, the type of the round trip.** `reflectSec` at `F.rev` lands in `Beh F.rev.rev`, and
  `TaskFrame.rev_rev` is `rfl`, so the round trip is stated and proved with no transport and no
  cast. `F.rev.Duration` is reducibly `F.Duration`, so a duration never needs moving either.
- **Steps 2, 5, 6 and 7, the additive identities.** Four goals need abelian-group normalization.
  `abel` closes all four but is not in the Presheaf cluster's import closure; see the risks below.

## Findings

### Codebase Patterns

**The converse frame exists, in full, with every property this clause needs.**
`FormalSystem/OpenLanguage/OpenReversal.lean` carries, in namespace `FormalSystem.Semantics`:

| Declaration | Content | Needs `IsRegular` |
|---|---|---|
| `FrameOver.rev` | `PosRel' w x u := PosRel u x w` | no |
| `FrameOver.rev_taskRel` | `F.rev.TaskRel w d u ↔ F.TaskRel u d w`, by `Iff.rfl` | no |
| `FrameOver.rev_taskRel_neg` | the paper's `w ⇒⁻_x u ↔ w ⇒_{-x} u` | yes |
| `FrameOver.rev_rev` | `F.rev.rev = F`, by `rfl` | no |
| `FrameOver.rev_isRegular` | all four `def:frame` constraints inherited | yes |
| `TaskFrame.rev`, `TaskFrame.rev_rev` | the bundled frame and its involution, `rfl` | no |

The module's own siting note reads: "`FrameOver.rev` is language-independent. It lives in this
component because this is its only consumer; the frame-level half may be promoted to
`Semantics/` later." This task is the second consumer, and that promotion is now due.

**The reflection convention is a definition, not an axiom.** `FrameOver.TaskRel` is
`TaskFrame.reflect F.PosRel`, a `dite` on the sign of the duration, so the converse frame's
relation agrees with the original's reversal branch-by-branch and `rev_taskRel` is literally
`Iff.rfl`. The derived reflection law `FrameOver.reflection` does need `[F.IsRegular]`, through
*Limit*. The clause never reaches it. That asymmetry is the precise sense in which this clause
"costs so little", and it belongs in the module docstring.

**What does not serve.** `Semantics/TruthTransport.lean`'s `TruthAntiIso` is a model-to-model
transport structure that takes both frames as given; it constructs no converse frame and is not
usable here. `Formula.reflectTime` is syntactic. Neither is a duplicate risk.

**The clause module has a template.** `Presheaf/Determinism.lean` and `Presheaf/Behavior.lean`
fix the house style: a long docstring with Main Definitions, Main Results, Implementation Notes
recording decisions, a `## References` block, and a closing
`assert_not_exists FormalSystem.ProofSystem.Axiom FormalSystem.ProofSystem.DerivationTree`.

### External Resources

- `Mathlib.Tactic.Abel` is the one new import needed. Precedent inside `Semantics/`:
  `FormalSystem/Semantics/Extension/Constraint.lean` imports it directly. `linarith` is likewise
  absent from the cluster closure and is not needed.
- Mathlib lemmas used, all confirmed present at this toolchain: `sub_nonneg`,
  `le_sub_iff_add_le`, `sub_add_cancel`, `sub_le_self`.
- Bibliography keys `schultz2020` and `johnstone1999` resolve in the root `references.bib`; the
  sibling Presheaf modules already cite both in the normal form of
  `docs/development/REFERENCE_NORMAL_FORM.md`.

### Recommendations

A sorry-free path exists and has been compiled. Implement in four phases.

**Phase A — promote the frame-level reversal block into `Semantics/`.** Move `FrameOver.rev`,
`rev_isRegular`, `rev_taskRel`, `rev_taskRel_neg`, `rev_rev`, `TaskFrame.rev` and
`TaskFrame.rev_rev` from `OpenReversal.lean` into `FormalSystem/Semantics/TaskFrame.lean`, and
leave the history-level and open-language halves (`TaskModel.rev`, `WorldHistory.rev`, the class
swaps, the transport theorem) where they are. `TaskFrame.lean` is already in the Presheaf
cluster's import closure through `PartialHistory.lean`, so this adds no import to either file and
`OpenReversal.lean` keeps working unchanged. Reconcile the siting note, which currently says the
promotion has not happened. Verified feasible: the probe reproduces the promoted block at the
`TaskFrame.lean` layer and compiles it with the cluster's `assert_not_exists` guard in force.

**Phase B — the reflection automorphism.** `Tr.ref` plus `ref_shift`, `ref_ref`, `ref_id`,
`ref_comp`, `ref_lres`, `ref_rres`. Note the direction of `ref_comp`: `ref` fixes objects and
preserves composition in order, so it is a covariant automorphism, not a duality.

**Phase C — the section reflection and the clause.** `Beh.reflectSec`, its reading equation,
`reflect_natural`, `reflect_reflect`, and `reflectEquiv`.

**Phase D — wiring and docstring.** One import line in `FormalSystem/Semantics/Presheaf.lean`,
the module inventory row in `Presheaf/README.md`, the `app:presheaf-dictionary` row in
`docs/reference/paper-definitions-of-record.md` recording the *Reflection* clause as formalized,
and the docstring paragraph on TR.

The verified statements, to be carried into the plan's `## Lean Challenge Statements` section
unchanged:

```lean
def Tr.ref {l' l : Obj D} (f : Tr l' l) : Tr l' l
@[simp] theorem Tr.ref_shift {l' l : Obj D} (f : Tr l' l) :
    (Tr.ref f).shift = l.val - f.shift - l'.val
theorem Tr.ref_ref {l' l : Obj D} (f : Tr l' l) : Tr.ref (Tr.ref f) = f
theorem Tr.ref_id (l : Obj D) : Tr.ref (Tr.id l) = Tr.id l
theorem Tr.ref_comp {l'' l' l : Obj D} (f : Tr l' l) (g : Tr l'' l') :
    Tr.ref (Tr.comp f g) = Tr.comp (Tr.ref f) (Tr.ref g)
theorem Tr.ref_lres {l l' : Obj D} (h : l'.val ≤ l.val) : Tr.ref (lres h) = rres h
theorem Tr.ref_rres {l l' : Obj D} (h : l'.val ≤ l.val) : Tr.ref (rres h) = lres h

def Beh.reflectSec {F : TaskFrame} (l : Obj F.Duration) (τ : Beh F l.val) : Beh F.rev l.val
theorem Beh.reflectSec_states {F : TaskFrame} (l : Obj F.Duration) (τ : Beh F l.val)
    (z : F.Duration) (hz : (reflectSec l τ).val.domain z) (h' : τ.val.domain (l.val - z)) :
    (reflectSec l τ).val.states z hz = τ.val.states (l.val - z) h'
theorem Beh.reflect_natural {F : TaskFrame} {l' l : Obj F.Duration} (f : Tr l' l)
    (τ : Beh F l.val) :
    reflectSec l' (Beh.restrictTr f τ)
      = Beh.restrictTr (F := F.rev) (Tr.ref f) (reflectSec l τ)
theorem Beh.reflect_reflect {F : TaskFrame} (l : Obj F.Duration) (τ : Beh F l.val) :
    reflectSec (F := F.rev) l (reflectSec l τ) = τ
def Beh.reflectEquiv (F : TaskFrame) (l : Obj F.Duration) : Beh F l.val ≃ Beh F.rev l.val
```

## Decisions

- **Consume `FrameOver.rev`; do not define a second converse frame.** The existing construction
  is the paper's `F⁻` and carries more than this clause needs. Rebuilding it is named a failure
  of the task.
- **Promote rather than import.** Importing `OpenReversal.lean` into the cluster is not an
  option; it is blocked by the layering guard, with the import chain recorded below. Promotion
  into `Semantics/TaskFrame.lean` rather than into a new `Semantics/Reversal.lean`, because
  `TaskFrame.lean` is already in the cluster's closure, so the move costs no new import anywhere
  and adds no module to the `Semantics/` aggregator.
- **State the clause over the primitive reversal, not the paper's negated form.** `rev_taskRel`
  is `Iff.rfl` and `rev_taskRel_neg` needs `[F.IsRegular]`; using the former keeps the whole
  clause constraint-free. The paper's form is cited in the docstring as the bridge.
- **`Beh.reflectEquiv` is the `Equiv`, by analogy with `Beh.germEquiv`.** The cluster states its
  clauses as bijections in `Equiv` form rather than as a pair of inverse maps, and the Germs
  clause is the precedent.
- **No `Category`/`Functor` instance.** `Site.lean` records a deliberate, reasoned decision to
  state the site concretely with no `Mathlib.CategoryTheory` import, and to reverse it only
  beside those declarations. `ref` follows that decision: plain `def` on `Tr`, laws as plain
  theorems, no `Functor` instance.
- **Accept `import Mathlib.Tactic.Abel`.** Four additive identities need it, there is in-cluster
  precedent in `Semantics/Extension/Constraint.lean`, and hand-rolling the four rewrite chains
  would be more fragile than the import.

## Risks & Mitigations

- **The promotion widens `file_scope` past the declared single module.** Phase A touches
  `FormalSystem/Semantics/TaskFrame.lean` and `FormalSystem/OpenLanguage/OpenReversal.lean`.
  Neither is in any concurrent sibling's `file_scope` this cycle (616, 566, 778, 716 are all
  elsewhere), so the collision risk is low, but the widening is a scope change and is raised as a
  non-blocking `user_decision`. Mitigation if declined: define the converse frame locally in
  `Reflection.lean` and record in the docstring why, which the task description permits as the
  fallback but which leaves two converse frames in the tree.
- **`abel` is absent from the cluster's import closure.** A probe importing only
  `Presheaf/Behavior.lean` reports `unknown tactic` for both `abel` and `linarith`. Mitigation:
  `import Mathlib.Tactic.Abel` in `Reflection.lean`, which the probe confirms is sufficient and
  which leaves the `assert_not_exists` guard intact.
- **The aggregator import line is a shared touch.** `FormalSystem/Semantics/Presheaf.lean` needs
  one new import and is deliberately outside this task's `file_scope`, so the collision gate will
  not protect it. Mitigation: make that edit last, re-read the file immediately beforehand, stage
  only that hunk, and re-run the build after it.
- **The paper anchor stays `DANGLING`.** `app:Structure` was cut in full and the text is only in
  git history, so `scripts/check-paper-definitions.sh --resolve` cannot pin any of these labels.
  Mitigation: follow the sibling modules and record the cut at each citation site, and add the
  *Reflection* row to the `app:presheaf-dictionary` entry in
  `docs/reference/paper-definitions-of-record.md`, which already enumerates the other five
  clauses' formalizations.
- **Build cost.** `TaskFrame.lean` is a large, widely imported module, so Phase A triggers a wide
  rebuild. Mitigation: run it detached through `lake-build-guard.sh` with a generous timeout, and
  expect one long full build rather than several scoped ones.

## Tactic Survey Results

Every row below is from a compiled run of the saved probe, not from a tactic guess.

| Goal | Tactic | Result | Premises/Config |
|------|--------|--------|-----------------|
| `ref`'s `0 ≤ ℓ - p - ℓ'` | term proof | success | `sub_nonneg.mpr (le_sub_iff_add_le.mpr …)` |
| `ref`'s `(ℓ - p - ℓ') + ℓ' ≤ ℓ` | `rw` then `exact` | success | `sub_add_cancel`, `sub_le_self` |
| `ref_ref`, `ref_comp` | `ext; simp; abel` | success | needs `Mathlib.Tactic.Abel` |
| `ref_id` | `ext; simp` | success | `Tr.ref_shift`, `Tr.id_shift` |
| `ref_lres`, `ref_rres` | `ext; simp [lres, rres]` | success | no `abel` needed |
| `reflectSec`'s `respects_task` | `refine … ; rwa [show … by abel]` | success | `FrameOver.rev_taskRel` as `Iff.rfl` |
| `reflect_natural` | `Beh.ext`, `partialHistory_ext rfl`, `states_eq_of_time_eq` | success | `by abel` for the time equality |
| `reflect_reflect` | same shape, domain half by `propext` | success | `by abel` for `ℓ - (ℓ - r) = r` |
| any of the above | `linarith` | fail | tactic not in the cluster's import closure |
| any of the above | `omega` | not attempted | `↑D` is an abstract ordered group, not `ℕ`/`ℤ` |

Axiom measurement, from `#print axioms` on the probe: `Tr.ref_ref`, `Tr.ref_comp`,
`reflect_natural`, `reflect_reflect` and `reflectEquiv` each depend on `[propext, Quot.sound]`.
No `Classical.choice`, matching the cluster's recorded standard.

The layering probe's refusal, recorded in full because it is the evidence for Phase A:

```
assert_not_exists FormalSystem.ProofSystem.Axiom
  error: Declaration FormalSystem.ProofSystem.Axiom is not allowed to be imported by this file.
  It is defined in FormalSystem.ProofSystem.Axioms,
    which is imported by FormalSystem.Semantics.FrameClassValidity,
    which is imported by FormalSystem.Semantics.ValidityLayer,
    which is imported by FormalSystem.Semantics.Validity,
    which is imported by FormalSystem.PlusLanguage.PlusValidity,
    which is imported by FormalSystem.PlusLanguage.PlusPasting,
    which is imported by FormalSystem.OpenLanguage.OpenClasses,
    which is imported by FormalSystem.OpenLanguage.OpenTruth,
    which is imported by FormalSystem.OpenLanguage.OpenValidity,
    which is imported by FormalSystem.OpenLanguage.OpenReversal,
    which is imported by this file.
```

## Context Extension Recommendations

- **Topic**: Recovering cut paper text from the paper repository's git history.
- **Gap**: `docs/reference/paper-definitions-of-record.md` records which anchors are `DANGLING`
  but not that their text is still retrievable, nor how. Three tasks on this front have now had
  to rediscover that `b64b1ca0^` holds the pre-cut appendix.
- **Recommendation**: add the recovery recipe (`git log -S` on the macro, then `git show
  <commit>^:./possible_worlds.tex`) and the commit that performed the cut to the `app:Structure`
  entry in that record file, so the next consumer of a `DANGLING` anchor does not repeat the
  search.

- **Topic**: Which tactics are available at which layer of `FormalSystem/`.
- **Gap**: `abel` and `linarith` are absent from the `Semantics/Presheaf/` import closure, and
  nothing records this. The failure mode is a bare `unknown tactic` that reads like a typo.
- **Recommendation**: note the per-layer tactic availability, and the `Mathlib.Tactic.*` direct-import
  precedents, in the Lean extension's operations context.

## Appendix

### Searches and probes used

- `lean_local_search` for `FrameOver.rev` (index reported `warming`, so the hits are positive
  evidence; no negative finding rests on it)
- Repository greps for `reflectTime`, `swapUS`, `swapMinus`, `converseFrame`, `reflectFrame`,
  `TaskFrame.mk`, `^import FormalSystem.OpenLanguage` under `Semantics/`
- `lake env lean` on three probes: the clause over the existing `OpenReversal` import; the
  layering guard under that import; the clause over a promoted frame-level block with the guard
  in force. The third is saved as
  `specs/617_reflection_clause_converse_frame_naturality/reflection-clause-probe.lean` and
  compiles with exit code 0.
- `git log --all -S` on the paper repository to locate the cut, then `git show b64b1ca0^` to
  recover the appendix

### References

* [P. Schultz, D. I. Spivak and C. Vasilakopoulou, *Dynamical Systems and Sheaves*][schultz2020],
  §3.2 — the behavior sheaf of which `Beh F` is the task-frame instance
* [P. T. Johnstone, *A Note on Discrete Conduché Fibrations*][johnstone1999], §2 — the coverage
  the site carries
* JPL paper `def:behavior-presheaf`, *Reflection*, *Converse Frame* and *Reflection
  Automorphism* clauses. **`DANGLING`**: cut with `app:Structure`; text recovered from the paper
  repository's git history
* JPL paper `app:presheaf-dictionary`, *Reflection* clause and its proof paragraph.
  **`DANGLING`**, as above
* JPL paper `thm:TR-valid` and `lem:time-reflection` — the soundness of the time reflection
  metarule this isomorphism underlies; both LIVE in the paper
* `FormalSystem/Semantics/Presheaf/Site.lean` — `Obj`, `Tr`, `Tr.comp`, `lres`, `rres`
* `FormalSystem/Semantics/Presheaf/Behavior.lean` — `Beh`, `Beh.restrictTr`, `Beh.mem_dom`,
  `Beh.ext`, `partialHistory_ext`, and `Beh.germEquiv` as the `Equiv`-form precedent
* `FormalSystem/OpenLanguage/OpenReversal.lean` — `FrameOver.rev` and the frame-level block to be
  promoted
* `FormalSystem/Semantics/TaskFrame.lean` — `TaskFrame.reflect`, `FrameOver.TaskRel`,
  `FrameOver.reflection`, `FrameOver.IsRegular`
* `docs/development/REFERENCE_NORMAL_FORM.md` — the `## References` normal form and the
  `Constraints consumed:` line, which reads `None` for every declaration of this clause
