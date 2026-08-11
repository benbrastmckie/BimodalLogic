# Phase 9 Handoff — `lem:step`, the sole *Spherical* application site

## Immediate Next Action

Begin Phase 10 (`thm:extension` and hypothesis-form `cor:occurrence`). Its dependencies —
phases 5 and 9 — are both complete. Phase 10 consumes
`FormalSystem.Semantics.PartialHistory.step` under Zorn; note that `step`'s binder list is
`(F) (hSph) (hSer) (hInt) (hLim) (τ) (z)`, with `hLim` present (see Deviations below).

## Current State

- Phase 9 `[COMPLETED]`. 9 of 23 phases complete.
- New file: `FormalSystem/Semantics/Extension/Step.lean` (~140 lines), registered in the
  aggregator `FormalSystem/Semantics.lean`.
- `lake build` green over the whole project (2330 jobs).
- Sorry count: 0 in `FormalSystem/Semantics/`. Repo-wide census 161, all pre-existing (160 under
  `Boneyard/`, one at `Metalogic/WeakCanonical/Transfer.lean:1085`).
- `#print axioms ...step` → `[propext, Classical.choice, Quot.sound]`; no `sorryAx`, no project
  axiom.

## Key Decisions

1. **Composition, not re-derivation.** `step` is proved in eleven lines by chaining
   `constraint hSer hInt τ z` → `hSph (Constraints τ z) hdir …` → `(admissible hSer hLim τ hz u).mpr`
   → `adjoin`/`adjoin_extends`/`adjoin_domain_self`. No lemma from Phases 6-8 was restated or
   re-proved.
2. **`z ∈ dom τ` handled by `by_cases`**, discharged with `σ := τ` and the inline reflexivity term
   `⟨fun _ ht => ht, fun _ _ => rfl⟩` for `Extends`. This is why `lem:step` can be stated for any
   `z ∈ D` while `lem:admissible` keeps its load-bearing `z ∈ D \ X` proviso.
3. **The paper's closing remark is recorded, not exploited.** The `⊆`-least-member shortcut is
   transcribed verbatim in the theorem docstring, but the proof takes the general *Spherical*
   route, which is what makes this the axiom's sole application site.
4. **Membership in the fiber-or-segment classes** comes from the existing
   `isFiber_or_isSegment_of_mem_Constraints`; `Set.mem_sInter` converts *Spherical*'s
   `(⋂₀ S).Nonempty` witness into `∀ c ∈ Constraints τ z, u ∈ c`.

## Cross-Task §7 Acceptance Criterion — DISCHARGED

- **Deletion probe**: re-elaborating `step`'s body verbatim with the `hSph` binder removed fails
  with `error(lean.unknownIdentifier): Unknown identifier 'hSph'` (plus a cascading
  `rcases` failure on the resulting metavariable).
- **Proof-term inspection**: `#print FormalSystem.Semantics.PartialHistory.step` shows `hSph`
  bound (`hSph hSer hInt hLim τ z =>`) and **applied as a function head**
  (`hSph (τ.Constraints z) hdir fun c hc`).
- **Sole site**: the only code occurrences of `Spherical` across `FormalSystem/` are its
  definition (`Semantics/FrameAxioms.lean:122`) and `step` (`Extension/Step.lean:116,127`).
- **Invariant for the later frame-axiom-field refactor** (restated in `Step.lean`'s module
  docstring): `TaskFrame.spherical` must be *definitionally* `Spherical TaskRel` as defined in
  `FormalSystem.Semantics.FrameAxioms` (likewise `serial` / `interpolates`). A field with a
  different statement makes `step` stop typechecking — that compilation failure is the acceptance
  test.

## Plan Deviations

One, annotated inline in the plan: `step` carries an additional binder
`hLim : ∀ w v, (∀ x, 0 < x → ∃ y, |y| < x ∧ F.TaskRel w y v) → v = w` between `hInt` and `τ`.
Forced by the inherited Phase 8 interface — `PartialHistory.admissible` takes `hLim` explicitly
because `TaskFrame` deliberately does not carry *Limit* as a structure field, and
`lem:admissible` needs `lem:nullity` at `z` itself. The conclusion, the other binders, and the
proof strategy are exactly as planned.

## Sorry Inventory

Empty. No sorry was introduced by this phase, and none was inherited from Phases 7 or 8.
