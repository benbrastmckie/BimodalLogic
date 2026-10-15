# Research Report: Task #796

**Task**: 796 - Prove lem:time-reflection for BL and the semantic form of thm:TR-valid by instantiating the generic anti-isomorphism transport at the reflected model
**Started**: 2026-10-15T02:29:00Z
**Completed**: 2026-10-15T02:55:00Z
**Effort**: Small — roughly 60 lines of new proof, all of it compiled and verified during research; plus a layering move of ~120 existing lines across three files
**Dependencies**: None blocking. Shares one file with task 617 (see Risks); task 801 holds `scripts/lean-citation-manifest.json` and `docs/reference/paper-definitions-of-record.md`
**Sources/Inputs**: - Codebase (`FormalSystem/Semantics/`, `FormalSystem/OpenLanguage/OpenReversal.lean`, `FormalSystem/Metalogic/Soundness.lean`), lean-lsp MCP (`lean_run_code` compiled probes, `lean_local_search`), the JPL paper `/home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex` (`def:time-reflection`, `lem:time-reflection`, `thm:TR-valid`, `thm:TM-soundness`), task 617's research report
**Artifacts**: - `specs/796_time_reflection_bl_tr_valid_anti_iso/reports/01_time-reflection-bl-tr-valid.md`
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **Every deliverable in (1) and (2) is already written and compiled.** Five declarations —
  `revHistEquiv`, `revAntiIso`, `truthAt_rev`, `FrameClass.Sat.rev`, `validOn_rev_iff` /
  `validOnFrames_reflectTime` / `validIn_reflectTime` / `valid_reflectTime` — were verified by
  `lean_run_code` against the current `.olean` tree. Every one compiled with zero diagnostics,
  no `sorry`, and no proof search. The exact verified sources are reproduced in **Findings**;
  implementation is transcription plus siting, not discovery.
- **The frame-class closure is unconditional, so the theorem needs no closure hypothesis.** All
  four tags are closed under `rev` because `F.rev.Duration = F.Duration` by `rfl`, so `IsDense`,
  `IsZTime` and `IsRTime` transfer by `exact h.2` and regularity by `inferInstance` on the
  existing `FrameOver.rev_isRegular` instance. `FrameClass.Sat.rev` discharges Base, Dense, ZTime
  and RTime in one `cases fc`. The non-tag predicates `IsComplete` and `IsQTime` are closed too,
  so `ValidComplete` and `ValidQTime` come free from a generic `ValidOnFrames` form.
- **Decision on (3): leave `derivable_valid_and_reflect_time_validIn` as is, with a
  cross-reference docstring.** It *is* now fully derivable — verified: both
  `validIn_reflectTime (axiom_validIn_min ax)` and
  `⟨soundness_validIn d, validIn_reflectTime (soundness_validIn d)⟩` compile — but a real collapse
  needs a replacement single-valued `derivable_validIn` recursion with a fresh termination proof,
  and it would break the "arm for arm" parallelism three sibling language layers document
  themselves by. Full argument in **Decisions**.
- **Decision on (4): promote, in three pieces, and align with task 617.** Frame level
  (`FrameOver.rev`, `rev_isRegular`, `rev_taskRel`, `rev_taskRel_neg`, `rev_rev`, `TaskFrame.rev`,
  `TaskFrame.rev_rev`) to `Semantics/TaskFrame.lean` — which is exactly task 617's Phase A, so the
  two tasks are idempotent on each other. Model/history/transport level to a new
  `Semantics/Reversal.lean` carrying the G-15 `assert_not_exists` guard; verified to compile with
  only `Semantics.TruthTransport` imported and the full guard in force. Validity level into
  `Semantics/Validity.lean` and `Semantics/FrameClassValidity.lean`. No cycle; `Truth.lean`'s
  guards are untouched because nothing upstream of it changes.
- **Two dispatch details corrected.** `atom` is *not* `rfl` (it needs `change` + `rw [neg_neg]`),
  and `WorldHistory.rev`'s `abel` step must become `rwa [neg_sub_neg]` if the history-level
  declaration is sited above `Mathlib.Tactic.Abel`'s entry point. Both verified.

## Context & Scope

The paper's `lem:time-reflection` (time reflection for BL) and `thm:TR-valid` (validity is closed
under the mirror image) are the two unported anchors. Both carry `% PORT:` comments at
`possible_worlds.tex:3973` and `:4003`; `def:time-reflection` at `:3963` has no `% PORT:` comment
of its own and is ported in substance already (it is `FrameOver.rev` / `TaskModel.rev` /
`WorldHistory.rev`).

The paper's own route is short. `lem:time-reflection` is an induction on `φ` with the `□` case
using the history bijection and the `U`/`S` cases substituting `z' = n(z)`; `thm:TR-valid` applies
the lemma twice, at `M` and at `M⁻`, using `(M⁻)⁻ = M`, `(σ⁻)⁻ = σ` and `n(n(y)) = y`. The
soundness theorem's TR case then reads off per class, "the reflected frame sharing its temporal
order" (`thm:TM-soundness`, paper line 4021).

The repository holds every piece of that route already, in two places that have never been
connected: the generic order-reversing transport
`Truth.truthAt_of_truthAntiIso` (`FormalSystem/Semantics/TruthTransport.lean`) and the frame
reversal machinery in `FormalSystem/OpenLanguage/OpenReversal.lean`. The task is the
instantiation, the validity-level consequence, and the layering move that lets the former see the
latter.

Research scope was: confirm what exists, write and compile each target declaration, settle the two
judgment calls the dispatch names (items 3 and 4), and map the territory overlap with the
concurrent and adjacent tasks.

## Findings

### Codebase Patterns

**What exists, confirmed by reading and by compilation.**

`FormalSystem/Semantics/TruthTransport.lean` supplies the generic machinery:

- `TruthCorr` / `Truth.truthAt_of_truthCorr` — the one order-*preserving* induction.
- `TruthAntiIso` (lines ~390) — `dur : F.Duration ≃ F'.Duration` plus
  `dur_rev : ∀ s t, dur s < dur t ↔ t < s`, `hist : WorldHistory F ≃ WorldHistory F'`, and `atom`
  quantified over every history.
- `Truth.truthAt_of_truthAntiIso (I) (φ) (τ) (t) : TruthAt M τ t φ ↔ TruthAt M' (I.hist τ) (I.dur t) φ.reflectTime`
  — the six-case induction, already written, already discharging the `untl`/`snce` exchange.

`FormalSystem/OpenLanguage/OpenReversal.lean` supplies the reversal, under
`namespace FormalSystem.Semantics` (lines 60–184) even though the file sits in `OpenLanguage/`:
`FrameOver.rev`, the `FrameOver.rev_isRegular` instance (all four `def:frame` constraints),
`FrameOver.rev_taskRel`, `FrameOver.rev_taskRel_neg` (the paper's `w ⇒⁻_x u := w ⇒_{-x} u`),
`FrameOver.rev_rev`, `@[reducible] TaskFrame.rev`, `TaskFrame.rev_rev`, `TaskModel.rev`,
`TaskModel.rev_rev`, `WorldHistory.rev`, `@[simp] WorldHistory.rev_state`,
`WorldHistory.rev_rev_hist` and `WorldHistory.rev_surjective`.

`TruthAntiIso` has exactly **one** existing instance in the tree:
`Metalogic/Independence/CoNotPriorU.lean:404`'s `clockMirrorIso`, a concrete single-model mirror
with `dur := Equiv.neg ℚ` and `dur_rev := fun _ _ => neg_lt_neg_iff`. It is the template the
deliverable follows, and it confirms the shape works: `clockReflectEquiv` there is built exactly
as `revHistEquiv` is below, from a reflection that is its own inverse.

**Verified deliverable (1).** Compiled with zero diagnostics against
`FormalSystem.OpenLanguage.OpenReversal` + `FormalSystem.Semantics.Validity`:

```lean
/-- Reversal of world histories as an equivalence `H_F ≃ H_{F⁻}` — the paper's bijection
`τ ↦ τ⁻`, packaged in the form `TruthAntiIso.hist` requires. -/
def revHistEquiv (F : TaskFrame) : WorldHistory F ≃ WorldHistory F.rev where
  toFun := WorldHistory.rev
  invFun := fun σ => (σ.rev : WorldHistory F)
  left_inv := WorldHistory.rev_rev_hist
  right_inv := fun σ => WorldHistory.rev_rev_hist (F := F.rev) σ

/-- The reversal anti-isomorphism: `dur` is negation, `hist` is the reversal involution,
`atom` holds because the two models share their valuation. -/
def revAntiIso {F : TaskFrame} (M : TaskModel F) : TruthAntiIso M M.rev where
  dur := Equiv.neg F.Duration
  dur_rev := fun _ _ => neg_lt_neg_iff
  hist := revHistEquiv F
  atom := by
    intro τ t p
    change M.valuation (τ.state t) p ↔ M.valuation (τ.state (- -t)) p
    rw [neg_neg]

/-- `lem:time-reflection` for BL. -/
theorem truthAt_rev {F : TaskFrame} (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (φ : Formula) : TruthAt M τ t φ ↔ TruthAt M.rev τ.rev (-t) φ.reflectTime :=
  Truth.truthAt_of_truthAntiIso (revAntiIso M) φ τ t
```

Three mechanical points the implementation must keep:

1. **`atom` is not `rfl`.** The dispatch specifies it as such; it is not. The goal after `intro` is
   `M.valuation (τ.state t) p ↔ M.rev.valuation ((revHistEquiv F τ).state (-t)) p`, which `change`
   normalises to `… τ.state (- -t) …` and `rw [neg_neg]` closes. This is the same two-step that
   `openTruthAt_rev`'s own `atom` case already uses (`OpenReversal.lean`, `| atom p =>` arm).
2. **`truthAt_rev` closes by a bare `exact`.** No `change` or `simp only` is needed to reduce
   `(revAntiIso M).hist τ` to `τ.rev` or `(revAntiIso M).dur t` to `-t`. The warning on
   `TimeShift.shiftCorr`'s docstring about a hand-built `Equiv` leaving an unreduced `let` does
   not bite here, because `revHistEquiv` is built with structure-instance `where` syntax rather
   than through `toEquiv`.
3. **`TaskFrame.rev`'s `@[reducible]` is load-bearing** and must not be dropped in the move.
   `revHistEquiv`'s `invFun` has type `WorldHistory F.rev → WorldHistory F.rev.rev`, and it is
   accepted as `WorldHistory F` only because `F.rev.rev = F` holds by `rfl` at reducible
   transparency. `WorldHistory.rev_surjective` already depends on this, via its type ascription.

**Verified deliverable (2).** Same probe, same result:

```lean
/-- Frame-level form: `φ` is valid on `F` exactly when its reflection is valid on `F⁻`. -/
theorem validOn_rev_iff (F : TaskFrame) (φ : Formula) :
    F.rev.ValidOn φ.reflectTime ↔ F.ValidOn φ := by
  constructor
  · intro h M τ t
    exact (truthAt_rev M τ t φ).mpr (h M.rev τ.rev (-t))
  · intro h M' τ' t'
    obtain ⟨τ, rfl⟩ := WorldHistory.rev_surjective τ'
    have key := (truthAt_rev (M'.rev : TaskModel F) τ (-t') φ).mp (h _ τ (-t'))
    rw [neg_neg] at key
    exact key

/-- Generic frame-predicate form: validity over any `rev`-closed class of frames is closed
under reflection. -/
theorem validOnFrames_reflectTime {P : TaskFrame → Prop} {φ : Formula}
    (hP : ∀ F : TaskFrame, P F → P F.rev) (h : ValidOnFrames P φ) :
    ValidOnFrames P φ.reflectTime :=
  fun F hF => (validOn_rev_iff F.rev φ).mpr (h F.rev (hP F hF))

/-- **Every frame class is closed under reversal**, because the reflected frame shares its
temporal order. Base by the `FrameOver.rev_isRegular` instance; Dense, ZTime and RTime because
`F.rev.Duration` is `F.Duration` by `rfl`, so the tag's own conjunct transfers unchanged. -/
theorem FrameClass.Sat.rev {fc : FrameClass} {F : TaskFrame} (h : fc.Sat F) : fc.Sat F.rev := by
  haveI := h.isRegular
  cases fc
  · exact inferInstance
  · exact ⟨inferInstance, h.2⟩
  · exact ⟨inferInstance, h.2⟩
  · exact ⟨inferInstance, h.2⟩

/-- `thm:TR-valid`, frame-class form. -/
theorem validIn_reflectTime {fc : FrameClass} {φ : Formula} (h : ValidIn fc φ) :
    ValidIn fc φ.reflectTime :=
  validOnFrames_reflectTime (fun _ => FrameClass.Sat.rev) h

/-- `thm:TR-valid`. -/
theorem valid_reflectTime {φ : Formula} (h : Valid φ) : Valid φ.reflectTime :=
  validIn_reflectTime h
```

The involution form compiles too, and is worth keeping because it is what a caller reasoning
backwards wants:

```lean
theorem validIn_reflectTime_iff {fc : FrameClass} {φ : Formula} :
    ValidIn fc φ.reflectTime ↔ ValidIn fc φ := by
  constructor
  · intro h
    have := validIn_reflectTime h
    rwa [Formula.reflect_time_involution] at this
  · exact validIn_reflectTime
```

**The two non-tag validity predicates come free.** `ValidComplete` and `ValidQTime` are
`ValidOnFrames (fun F => F.IsRegular ∧ F.IsComplete)` and
`ValidOnFrames (fun F => F.IsRegular ∧ F.IsQTime)` — neither is any `FrameClass`'s `Sat`, so
`validIn_reflectTime` does not reach them, but `validOnFrames_reflectTime` does. Verified
closures:

```lean
theorem regComplete_rev {F : TaskFrame} (h : F.IsRegular ∧ F.IsComplete) :
    F.rev.IsRegular ∧ F.rev.IsComplete := by
  haveI := h.1
  exact ⟨inferInstance, h.2⟩
-- and the identical proof at `IsQTime`
```

This is why `validOnFrames_reflectTime` is worth stating as the primitive and
`validIn_reflectTime` as its instance at `fc.Sat`, rather than proving `validIn_reflectTime`
directly: the same lemma then covers the two predicates no tag denotes. It also mirrors how
`Validity.lean` already organises `ValidOnFrames.mono` above `ValidIn.mono`.

**Names are free.** A grep over `FormalSystem/` found no existing `truthAt_rev`,
`validOn_rev_iff`, `valid_reflectTime`, `validIn_reflectTime`, `revAntiIso`, `revHistEquiv`,
`validOnFrames_reflectTime`, or `Sat.rev`. The proposed names are the exact base-language
analogues of the open-language siblings `openTruthAt_rev`, `openValidOn_rev_iff` and
`openValid_reflectTime`, which is the naming pattern to preserve.

### External Resources

No Mathlib search was needed. Every lemma consumed is either repository-local or an elementary
Mathlib order/group fact already in scope: `neg_neg`, `neg_lt_neg_iff`, `neg_sub_neg`,
`Equiv.neg`. One substitution matters:

- `neg_sub_neg : -a - -b = b - a` replaces the `abel` call in `WorldHistory.rev`'s
  `respects_task` obligation. `abel` is **not** available from
  `Semantics/TaskModel.lean` + `Semantics/PartialHistory.lean` alone (probe: `unknown tactic`),
  so the substitution is required if that declaration is sited at or above the PartialHistory
  layer. Verified: `rwa [neg_sub_neg] at this` compiles at that import level. It also compiles at
  the `TruthTransport` layer, so making the substitution unconditionally costs nothing and
  removes a latent siting constraint.

### Recommendations

A sorry-free path exists for the whole deliverable and has been exercised end to end. The
recommended decomposition is five phases.

**Phase 1 — promote the frame level into `Semantics/TaskFrame.lean`.** Move `FrameOver.rev`, the
`FrameOver.rev_isRegular` instance, `FrameOver.rev_taskRel`, `FrameOver.rev_taskRel_neg`,
`FrameOver.rev_rev`, `TaskFrame.rev` (keeping `@[reducible]`) and `TaskFrame.rev_rev` out of
`OpenReversal.lean` and into `Semantics/TaskFrame.lean`. Verified: the whole block compiles
against `import FormalSystem.Semantics.TaskFrame` alone, needing only `F.comp`, `F.serial`,
`F.limit`, `F.saturation`, `F.reflection`, `add_comm`, `neg_neg` and `and_comm` — all
TaskFrame-level. `TaskFrame.lean`'s own `assert_not_exists` guard (line 276) stays satisfied
because no new import is added. **This phase is byte-for-byte task 617's Phase A**; see Risks.

**Phase 2 — new module `FormalSystem/Semantics/Reversal.lean`.** Imports
`FormalSystem.Semantics.TruthTransport` and nothing else. Carries the G-15 guard verbatim from
`TruthTransport.lean`. Contents: `TaskModel.rev`, `TaskModel.rev_rev`, `WorldHistory.rev` (with
`neg_sub_neg`), `@[simp] WorldHistory.rev_state`, `WorldHistory.rev_rev_hist`,
`WorldHistory.rev_surjective`, `revHistEquiv`, `revAntiIso`, `truthAt_rev`. **Verified as a unit**:
this exact content compiled with only `Semantics.TruthTransport` imported *and* the full
`assert_not_exists FormalSystem.ProofSystem.Axiom …FrameClass` in force.

**Phase 3 — `FrameClass.Sat.rev` into `Semantics/FrameClassValidity.lean`.** It belongs beside
`FrameClass.Sat.isRegular` and `FrameClass.Sat.anti`, in the `FormalSystem.ProofSystem` namespace
that file already declares (and already documents as a deliberate namespace exception). After
Phase 1 that file sees `TaskFrame.rev` and the regularity instance transitively via
`FrameProperty.lean`. Nothing else is needed: the proof uses only `h.isRegular`, `inferInstance`
and `h.2`.

**Phase 4 — the validity level into `Semantics/Validity.lean`.** Add
`import FormalSystem.Semantics.Reversal`, then `validOn_rev_iff`, `validOnFrames_reflectTime`,
`validIn_reflectTime`, `validIn_reflectTime_iff`, `valid_reflectTime`, plus
`validComplete_reflectTime` and `validQTime_reflectTime` as the two instances at the non-tag
predicates. Site them after `ValidIn.mono`, which is the existing home of the structural validity
lemmas. No cycle: `Reversal.lean` imports only `TruthTransport.lean`, which `Validity.lean`
already imports.

**Phase 5 — reconcile the dependents and the records.**

- `OpenLanguage/OpenReversal.lean`: delete its `namespace FormalSystem.Semantics` block
  (lines 60–184), add `import FormalSystem.Semantics.Reversal`, and rewrite the module
  docstring's **Siting** paragraph, which currently states the promotion has not happened. Keep
  everything in the `OpenLanguage` namespace — the class swaps, `openTruthAt_rev`,
  `openValidOn_rev_iff`, `openValid_reflectTime` — untouched and unchanged in statement.
- `Metalogic/Soundness.lean`: the docstring cross-reference decided under (3) below.
- Registration: `FormalSystem/Semantics.lean` (import + module-doc entry),
  `FormalSystem/Semantics/README.md` (one table row, following the `TruthTransport.lean` row's
  shape), and `FormalSystem/OpenLanguage.lean`'s `OpenReversal` entry (line 55), which currently
  credits that module with `FrameOver.rev`.
- `% PORT:` comments in `/home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex`:
  line 3973 (`lem:time-reflection`) and line 4003 (`thm:TR-valid`). Both become fully ported.
  This is an edit **outside this repository**.

**Do not** re-derive `openTruthAt_rev` from `truthAt_rev`. `OpenReversal.lean`'s docstring already
records why the `TruthAntiIso` machinery cannot serve L^▷ — the `▷`/`◁`/`⊡` clauses quantify over
a *class* of histories, and transporting a class is not what an atom-level `TruthAntiIso` does.
That reasoning is unchanged by this task and the two inductions stay separate.

## Decisions

### Decision (3): leave `derivable_valid_and_reflect_time_validIn` as is, with a cross-reference

Both halves of the collapse were *verified to be available*, so this is a judgment call made with
the facts in hand, not an untested guess:

```lean
-- compiles, against FormalSystem.Metalogic.Soundness:
example {φ : Formula} (ax : Axiom φ) : ValidIn ax.minFrameClass φ.reflectTime :=
  validIn_reflectTime (axiom_validIn_min ax)

example {fc : FrameClass} {φ : Formula} (d : DerivationTree fc [] φ) :
    ValidIn fc φ ∧ ValidIn fc φ.reflectTime :=
  ⟨soundness_validIn d, validIn_reflectTime (soundness_validIn d)⟩
```

The first one-liner subsumes the whole of `axiom_reflect_time_validIn_min`
(`Soundness.lean:1252`) — its `.Base` branch `SoundnessLemmas.axiom_reflect_time_valid_general`
and its four constrained arms alike. The second shows the pair is reconstructible.

**It is nonetheless not collapsed, for three reasons.**

1. **The second example is not actually a collapse.** `soundness_validIn` is *defined* as `.1` of
   `derivable_valid_and_reflect_time_validIn`, so using it to rebuild the pair is circular as a
   replacement. A real collapse means writing a new single-valued
   `derivable_validIn : DerivationTree fc [] φ → ValidIn fc φ` recursion whose `time_reflection`
   arm applies `validIn_reflectTime` to the induction hypothesis, with a fresh
   `termination_by d.height` / `decreasing_by` block, and then rewiring `soundness_in`
   (`Soundness.lean:1362`), `soundness_validIn` (`:1370`) and
   `Metalogic/Independence/CoarsenedModels.lean:424`. That is a soundness-core refactor, not a
   consequence of porting two paper anchors.
2. **It would break a documented cross-layer parallelism.** `plus_derivable_valid_and_reflect_time_validIn`,
   `star_derivable_valid_and_reflect_time_validIn` and the Deterministic variant each describe
   themselves in their own docstrings as a mirror of the base recursion "arm for arm, well-founded
   on the derivation's height". Collapsing the base layer alone would make three sibling
   docstrings false, and collapsing all four is a far larger change than this task.
3. **The per-axiom route retains independent value.** `axiom_reflect_time_validIn_min` proves the
   twenty reflection-validities from the axioms' own semantics; `validIn_reflectTime` proves them
   from frame reversal. Two independent derivations of the same twenty facts is a genuine
   cross-check. And most of the ~700-line family in
   `Metalogic/SoundnessLemmas/FrameClassVariants.lean` is the *past-mirror schema* validities
   (`left_mono_since_H_reflect_time_valid`, `connect_past_reflect_time_valid`,
   `linear_since_reflect_time_valid`, `since_P_reflect_time_valid`, …) which are consumed
   elsewhere and survive any collapse regardless.

**What the docstring must therefore say**, on `derivable_valid_and_reflect_time_validIn`: that the
paper's own soundness proof routes the TR rule through `thm:TR-valid` and not through a per-axiom
dispatch (`thm:TM-soundness`, "**TR** preserves validity over each class by **thm:TR-valid**, the
reflected frame sharing its temporal order"); that `Semantics.validIn_reflectTime` is now that
argument in the tree, and that `validIn_reflectTime (axiom_validIn_min ax)` alone proves
`axiom_reflect_time_validIn_min`; and that the per-axiom dispatch is retained deliberately as an
independent re-derivation and for the three mirrored language layers, not because it is the only
available route. A matching back-reference belongs on `axiom_reflect_time_validIn_min`.

The collapse is a legitimate follow-up and should be raised as its own task rather than folded in
here.

### Decision (4): promote in three pieces, with the frame level going to `TaskFrame.lean`

`OpenReversal.lean`'s siting note says `FrameOver.rev` "lives in this component because this is
its only consumer; the frame-level half may be promoted to `Semantics/` later". That is now due,
and this task is one of two consumers forcing it.

The frame level must go to `Semantics/TaskFrame.lean` specifically, **not** into the new
`Semantics/Reversal.lean`. Task 617 needs `FrameOver.rev` inside the `Semantics/Presheaf/`
cluster, which carries a `ProofSystem`-free layering guard. `Reversal.lean` as specified above is
guard-clean, so 617 could in principle import it — but if the validity-level theorems were put
*in* `Reversal.lean` it would have to import `Validity.lean`, hence `FrameClassValidity.lean`,
hence `ProofSystem.Axioms`, and the guard would fire. Splitting the validity level off into
`Validity.lean` (Phase 4) is what keeps `Reversal.lean` guard-clean, and putting the frame level
in `TaskFrame.lean` keeps it reachable from the Presheaf cluster with no new import anywhere.

Sub-decision: `TaskModel.rev` and `WorldHistory.rev` go to the new `Reversal.lean`, not to
`TaskModel.lean` and `PartialHistory.lean`. Their natural homes were probed and **do work** once
`abel` becomes `neg_sub_neg`, so this is a preference, not a constraint: keeping the
model/history/transport reversal story in one new module avoids churning two more large,
widely-imported files, and leaves a single place where a reader finds the whole involution. If a
later consumer needs `WorldHistory.rev` above the `TruthTransport` layer, the move is already
known to be feasible.

### Smaller decisions

- **State `validIn_reflectTime` without a closure hypothesis.** The dispatch asks for the form
  "for every `fc` closed under `rev`". Since all four tags *are* closed, parameterising on the
  closure would push a hypothesis onto every call site for no gain. The generality lives one level
  down, in `validOnFrames_reflectTime`, which takes the closure as an argument and is what serves
  `ValidComplete` and `ValidQTime`.
- **Make `validOnFrames_reflectTime` the primitive**, with `validIn_reflectTime` as its instance
  at `fc.Sat`. Mirrors the existing `ValidOnFrames.mono` / `ValidIn.mono` pairing in the same
  file.
- **Keep `validIn_reflectTime_iff`.** One extra verified line, and it is the form a caller
  reasoning from a reflected formula back to the original needs.

## Risks & Mitigations

- **Territory collision with task 617 on `FormalSystem/Semantics/TaskFrame.lean`.** 617's research
  report (`specs/617_reflection_clause_converse_frame_naturality/reports/01_reflection-clause-converse-frame.md`,
  Phase A) specifies the same promotion of the same declarations into the same file, and its probe
  file `reflection-clause-probe.lean` opens by simulating exactly that. 617 was not dispatched
  this cycle, so there is no live writer, but either task may land first. *Mitigation*: the
  implementation's Phase 1 must begin by re-reading `Semantics/TaskFrame.lean` and treating the
  promotion as idempotent — if the block is already there, verify and move on rather than
  duplicating it. The two designs agree, including on the destination file, so neither needs to
  change. 617 additionally decides to leave `TaskModel.rev` and `WorldHistory.rev` in
  `OpenReversal.lean`; this task moves them, which 617 does not depend on and which leaves its
  Phase A conclusion intact.
- **Territory overlap with task 801 on the citation records.** 801 declares
  `docs/reference/paper-definitions-of-record.md` and `scripts/lean-citation-manifest.json` in its
  `file_scope`. The manifest is generated by `scripts/export-lean-citations.py`, so it should not
  be hand-edited here in any case. *Mitigation*: this task touches neither file. If the record's
  `KNOWN-ANCHORS` row for `lem:time-reflection` (currently `LIVE-UNPINNED`, line 2322) needs
  updating once the anchors are ported, raise it rather than editing into 801's scope.
- **Wide rebuild.** `Semantics/TaskFrame.lean` is ~2700 lines and is imported by almost everything
  downstream, so Phase 1 triggers a near-full rebuild. *Mitigation*: run the scoped guarded build
  after Phases 2–4 and reserve the full unscoped build for final verification, per
  `context/project/lean4/operations/long-builds.md`. Budget for it rather than being surprised by
  it.
- **An `instance` and a `@[simp]` lemma become visible much earlier.** `FrameOver.rev_isRegular`
  and `WorldHistory.rev_state` move from a leaf module to the base of the semantics layer.
  *Mitigation*: both are keyed on a `.rev` head, so instance search and `simp` only engage on
  goals that already mention reversal. Task 617's probe already compiled the promoted instance
  inside the Presheaf cluster, which is the most instance-sensitive consumer in the tree.
- **`@[reducible]` on `TaskFrame.rev` is silently load-bearing.** Dropping it during the move
  would break `revHistEquiv.invFun`, `WorldHistory.rev_surjective` and `validIn_reflectTime`'s
  final step, all of which rely on `F.rev.rev = F` by `rfl`. *Mitigation*: preserve the attribute
  verbatim; the plan should name it as a check.
- **The `% PORT:` edits are outside this repository.** `possible_worlds.tex` lives at
  `/home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/`. *Mitigation*: treat it as its own phase
  step with the two line numbers named (3973, 4003), and do not assume the repository's git
  workflow covers it.

## Tactic Survey Results

Candidate tactics were exercised directly against the real goals via `lean_run_code` probes rather
than against a reconstruction, so each row below is a compiled result, not an estimate.

| Goal | Tactic | Result | Premises/Config |
|------|--------|--------|-----------------|
| `revAntiIso.dur_rev` | `fun _ _ => neg_lt_neg_iff` | success | term-mode; matches `clockMirrorIso`'s own `dur_rev` |
| `revAntiIso.atom` | `rfl` | fail | the two sides sit at `t` and `- -t` |
| `revAntiIso.atom` | `change` + `rw [neg_neg]` | success | same two-step as `openTruthAt_rev`'s `atom` arm |
| `truthAt_rev` | `exact Truth.truthAt_of_truthAntiIso (revAntiIso M) φ τ t` | success | no `change`/`simp only` needed |
| `validOn_rev_iff` forward | `exact (truthAt_rev …).mpr (h M.rev τ.rev (-t))` | success | — |
| `validOn_rev_iff` backward | `obtain ⟨τ, rfl⟩ := WorldHistory.rev_surjective τ'` then `rw [neg_neg]` | success | mirrors `openValidOn_rev_iff` arm for arm |
| `FrameClass.Sat.rev` | `haveI := h.isRegular; cases fc` + `inferInstance` / `⟨inferInstance, h.2⟩` | success | the `.Base` arm is `inferInstance` alone |
| `validIn_reflectTime` | `validOnFrames_reflectTime (fun _ => FrameClass.Sat.rev) h` | success | term-mode |
| `validIn_reflectTime_iff` forward | `rwa [Formula.reflect_time_involution]` | success | — |
| `WorldHistory.rev` `respects_task`, at the TaskModel/PartialHistory layer | `rwa [show (-s) - -t = t - s by abel]` | fail | `abel` unavailable at that import level |
| `WorldHistory.rev` `respects_task`, same layer | `rwa [neg_sub_neg]` | success | the recommended substitution |
| `axiom_reflect_time_validIn_min` via TR-valid | `validIn_reflectTime (axiom_validIn_min ax)` | success | decision evidence for item (3) |

`lean_hammer_premise` and the rate-limited search tools were not called: every goal closed on a
first, reasoned attempt from repository-local lemmas, so premise suggestion had nothing to
contribute and spending the rate limit would have bought no evidence.

## Context Extension Recommendations

- **Topic**: Siting a promoted declaration against a layering guard.
- **Gap**: `context/project/lean4/` has no note on the move this task and task 617 each
  independently had to work out — that a declaration promoted out of a leaf module must land
  *above* the `assert_not_exists` guard of its intended consumers, which means splitting the
  promotion by layer (frame level above the `ProofSystem` seam, validity level below it) rather
  than moving a module wholesale. Both tasks rediscovered the same split from first principles.
- **Recommendation**: add `context/project/lean4/patterns/layered-promotion.md` recording the
  rule, with the G-15 guard in `Semantics/Truth.lean` / `TruthTransport.lean` /
  `FrameProperty.lean` and the documented `FrameClassValidity.lean` seam as the worked example,
  and with the diagnostic that reveals the problem (a promoted module importing `Validity.lean`
  pulls in `ProofSystem.Axioms` and fires a consumer's guard).

## Appendix

### Probes run

All via `mcp__lean-lsp__lean_run_code` against the committed `.olean` tree at `c7c257267`; each
returned `success: true` with an empty `diagnostics` array except where a failure is reported
above.

1. `revHistEquiv` + `revAntiIso` + `truthAt_rev`, over
   `OpenLanguage.OpenReversal` + `Semantics.Validity`.
2. The above plus `validOn_rev_iff`, `satRev`, `validIn_reflectTime`, `valid_reflectTime`.
3. The above plus `validIn_reflectTime_iff` and
   `example (ax : Axiom φ) : ValidIn ax.minFrameClass φ.reflectTime`, over
   `Metalogic.Soundness`.
4. `⟨soundness_validIn d, validIn_reflectTime (soundness_validIn d)⟩`, over `Metalogic.Soundness`.
5. The frame-level block (`FrameOver.rev`, `rev_isRegular`, `TaskFrame.rev`, `rev_rev`) over
   `import FormalSystem.Semantics.TaskFrame` alone.
6. `TaskModel.rev` / `WorldHistory.rev` / `rev_rev_hist` / `rev_surjective` over
   `Semantics.TaskModel` + `Semantics.PartialHistory` — first with `abel` (failed), then with
   `neg_sub_neg` (passed).
7. The whole Phase-2 module content over `import FormalSystem.Semantics.TruthTransport` **with**
   `assert_not_exists FormalSystem.ProofSystem.Axiom FormalSystem.ProofSystem.DerivationTree
   FormalSystem.ProofSystem.Derivable FormalSystem.ProofSystem.FrameClass` in force.
8. `#print ValidComplete` / `#print ValidQTime`, then the two `IsRegular ∧ _` closure lemmas.

### References

- Paper: `/home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex` —
  `def:time-reflection` (line 3963), `lem:time-reflection` (3969, `% PORT:` at 3973),
  `thm:TR-valid` (3999, `% PORT:` at 4003), `thm:TM-soundness` TR clause (4021).
- `FormalSystem/Semantics/TruthTransport.lean` — `TruthAntiIso`,
  `Truth.truthAt_of_truthAntiIso`, and the G-15 guard to copy.
- `FormalSystem/OpenLanguage/OpenReversal.lean` — the reversal machinery and its Siting note;
  `openTruthAt_rev`, `openValidOn_rev_iff`, `openValid_reflectTime` as the naming and
  proof-shape template.
- `FormalSystem/Metalogic/Independence/CoNotPriorU.lean:376-440` — `clockReflectEquiv` /
  `clockMirrorIso` / `truthAt_mirror`, the one existing `TruthAntiIso` instance.
- `FormalSystem/Semantics/Validity.lean` — `TaskFrame.ValidOn` (255), `ValidOnFrames` (337),
  `ValidIn` (348), `Valid` (385), `ValidIn.mono` (491), `ValidComplete` (620), `ValidQTime` (678).
- `FormalSystem/Semantics/FrameClassValidity.lean` — `FrameClass.Sat`, `Sat.isRegular`,
  `Sat.anti`, and the recorded namespace exception that `Sat.rev` joins.
- `FormalSystem/Metalogic/Soundness.lean:1252-1335` — `axiom_reflect_time_validIn_min`,
  `axiom_reflect_time_validIn`, `derivable_valid_and_reflect_time_validIn`.
- `specs/617_reflection_clause_converse_frame_naturality/reports/01_reflection-clause-converse-frame.md`
  — the convergent Phase A promotion decision.
