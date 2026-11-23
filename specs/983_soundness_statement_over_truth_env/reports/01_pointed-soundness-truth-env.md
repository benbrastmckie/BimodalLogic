# Research Report: Task #983

**Task**: 983 - State pointed soundness once over TruthEnv (milestone D4)
**Started**: 2026-11-23T19:35:26Z
**Completed**: 2026-11-23T19:39:01Z
**Effort**: Small implementation (about 30 lines of proof, one new module of about 60 lines, one test file)
**Dependencies**: None (D4 waits on nothing in records/milestones.md)
**Sources/Inputs**: - Codebase (`FormalSystem/Metalogic/Soundness.lean`, `Conservativity/Plus/PlusSoundness.lean`, `Conservativity/Star/StarSoundness.lean`, `Semantics/TruthClauses.lean`, `Semantics/ValidityLayer.lean`, `StarLanguage/{StarTruth,StarValidity,Derivation}.lean`), `records/milestones.md`, `records/proof-mode-architecture.md`, commit `b3d8f6463` (`ProofModeSoundness.lean`, the shape to avoid), compiled probes via `lake env lean`
**Artifacts**: - specs/983_soundness_statement_over_truth_env/reports/01_pointed-soundness-truth-env.md
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **Phase 1 goes through unchanged.** `star_soundness_in` is `plus_soundness_in` arm for arm with the register vector `v` added as one fixed binder. A scratch probe compiles it with zero errors and the standard axiom set `[propext, Classical.choice, Quot.sound]`, identical to `plus_soundness_in`.
- **The register environment is quantified once, outside the premises**: one `v`, with `h_ctx : ∀ ψ ∈ Γ, StarTruthAt M τ t v ψ` and conclusion `StarTruthAt M τ t v φ` at the same `v`. The induction generalizes `τ t` only; `v` need not be generalized, because no TM⋆ rule moves it. The three empty-context rules need nothing new: their contexts are `[]`, so the premise hypothesis is vacuous, and `time_reflection` defers to the existing companion recursion, whose `StarValidIn` already quantifies `v` universally.
- **Phase 2**: recommended shape is a `Prop`-valued mixin `PointedSound L D` over an explicit derivation relation `D`, with one field (pointed soundness at `TruthEnv.T`), three instances, and one generic theorem `truth_of_derivation`. Compiled with tests at all three languages, zero errors. It carries no data and no connective, so the later object-level interface can require it of its own derivation relation.
- `star_soundness_in` is a new theorem, not a corollary of `star_soundness_validIn`: TM⋆ has no deduction theorem in the tree (D3 lists it as pending), so the context form cannot be obtained by discharging premises.

## Context & Scope

Milestone D4 of `records/milestones.md` and its join 7: pointed soundness with premises for TM, TM⁺ and TM⋆, stated once over `TruthEnv`, each language an instance, no module restating a language's soundness theorem under another name. The adapter paragraph of `records/proof-mode-architecture.md` places the statement in one layer-3 module under `FormalSystem/Metalogic/`, importing each language's soundness and nothing under `FormalSystem/Automation/ProofMode/`. The tactic that applies the statement belongs to C4 and is out of scope here.

Evidence tier: all claims below about elaboration are from compiled probes against the built tree (`lake env lean` on scratch files importing the three soundness modules), not from LSP lookups.

## Findings

### Codebase Patterns

- `soundness_in` (`Metalogic/Soundness.lean:1371`) and `plus_soundness_in` (`PlusSoundness.lean`) share one binder shape: `(Γ) (φ) (d : Tree fc Γ φ) (F) (hF : fc.Sat F) (M) (τ) (t) (h_ctx : ∀ ψ ∈ Γ, Truth M τ t ψ) : Truth M τ t φ`, by `induction d generalizing τ t`.
- `StarDerivationTree` (`StarLanguage/Derivation.lean:81`) has exactly the seven constructors of `PlusDerivationTree`; `necessitation`, `temporal_necessitation` and `time_reflection` are all at context `[]`. There is no rule specific to the register operators; they enter only through `StarAxiom`.
- `StarTruthAt M τ t v` threads `v` unchanged through every clause except `timeStore` (updates `v`) and `timeRecall` (moves `t`). Neither is touched by a rule arm; both are handled inside `starAxiom_validIn`.
- `StarValidIn fc φ` unfolds to `∀ F, fc.Sat F → ∀ M τ x v, StarTruthAt M τ x v φ` (`StarValidity.lean`), so `starAxiom_validIn h_ax h_fc F hF M τ t v` and `(star_derivable_valid_and_reflect_time_validIn d').2 F hF M τ t v` apply directly.
- `TruthEnv` (`Semantics/TruthClauses.lean`) has `Env : TaskFrame → Type` and `T M τ t e φ`. Instances: `Formula` and `PlusFormula` with `Env _ := PUnit`, `StarFormula` with `Env F := ℕ → F.Duration`. `TruthEnv.T M τ t e φ` is definitionally the native truth predicate in all three, so each language's context-form theorem is a term of the class field with no `show` or rewriting.
- All three context types are `List` of the formula type (`Context`, `PlusContext`, `StarContext` are `abbrev`s), so one relation shape `FrameClass → List L → L → Sort u` fits all three trees and also the `Prop`-valued `*Derivable`.
- `PointTruth` (`Semantics/ValidityLayer.lean`) is the ∀-closed relation and is the wrong base: closing over `v` would force premises true at every register vector, which is weaker than the pointed statement D4 asks for. `TruthEnv` keeps `e` exposed and is the right base, as the task states.
- The sound-direction guard convention already exists: `FormalSystem/Automation/ProofMode.lean` and `FormalSystem/Theorems/ProofMode.lean` carry `assert_not_exists` on `FormalSystem.Metalogic.completeness_{base,dense,ztime,rtime}` (all four declared in `Metalogic/StrongCompleteness.lean`).
- Shape to avoid, `ProofModeSoundness.lean` at commit `b3d8f6463`: four theorems, each `soundness_in`/`plus_soundness_in` re-exported under a new name with the same statement, two of them only re-typed at `TruthEnv.T`. Nothing there is generic; TM⋆ is absent.
- No name collision: `PointedSound`, `truth_of_derivation` and `star_soundness_in` occur nowhere under `FormalSystem/`, `Tests/` or `docs/`.
- Registries that mention the neighbours: `docs/theorem-index.md:719` (row for `star_soundness_validIn`), `FormalSystem/Metalogic.lean` (aggregator import list and docstring), `Tests/BimodalTest.lean` (test aggregator, `BimodalTest.Metalogic.*` rows), and the "Main Results" list in `StarSoundness.lean`'s module docstring.

### External Resources

- None needed. No Mathlib lemma beyond `List.not_mem_nil`-level simp facts is consumed; the `by simp` closing the vacuous premise in the two necessitation arms is the same call the plus proof uses.

### Recommendations

1. **Add `star_soundness_in` to `StarSoundness.lean`, directly after `star_soundness_validIn`**, with `v` as a single binder after `t` and the premise and conclusion at that same `v`: [VERIFIED: PASS -- compiled via `lake env lean` on a scratch file importing `StarSoundness`; zero errors; `#print axioms` gives `[propext, Classical.choice, Quot.sound]`, the same set as `plus_soundness_in`]

   ```lean
   theorem star_soundness_in {fc : FrameClass} (Γ : StarContext) (φ : StarFormula)
       (d : StarDerivationTree fc Γ φ)
       (F : TaskFrame) (hF : fc.Sat F) (M : TaskModel F)
       (τ : WorldHistory F) (t : F.Duration) (v : ℕ → F.Duration)
       (h_ctx : ∀ ψ ∈ Γ, StarTruthAt M τ t v ψ) :
       StarTruthAt M τ t v φ := by
     induction d generalizing τ t with
     | «axiom» Γ' φ' h_ax h_fc => exact starAxiom_validIn h_ax h_fc F hF M τ t v
     | assumption Γ' φ' h_in => exact h_ctx φ' h_in
     | modus_ponens Γ' φ' ψ' _ _ ih1 ih2 => exact (ih1 τ t h_ctx) (ih2 τ t h_ctx)
     | necessitation φ' _ ih => intro σ; exact ih σ t (by simp)
     | temporal_necessitation φ' _ ih =>
       rw [StarTruth.allFuture_iff]; intro s _; exact ih τ s (by simp)
     | time_reflection φ' d' _ih =>
       exact (star_derivable_valid_and_reflect_time_validIn d').2 F hF M τ t v
     | weakening Γ' Δ' φ' _ h_sub ih =>
       exact ih τ t (fun ψ h_in => h_ctx ψ (h_sub h_in))
   ```

2. **State the class as a `Prop`-valued mixin over an explicit derivation relation**, in a new module `FormalSystem/Metalogic/PointedSoundness.lean` (name open to the planner), importing `Metalogic.Soundness`, `Conservativity.Plus.PlusSoundness` and `Conservativity.Star.StarSoundness` only: [VERIFIED: PASS -- class, three tree instances, a fourth instance at the `Prop`-valued `StarDerivable`, the generic theorem, and tests at all three languages compiled via `lake env lean`, zero errors; `truth_of_derivation` depends on `[propext]` only]

   ```lean
   class PointedSound (L : Type) [TruthEnv L] (D : FrameClass → List L → L → Sort u) : Prop where
     sound : ∀ {fc : FrameClass} {Γ : List L} {φ : L}, D fc Γ φ →
       ∀ (F : TaskFrame), fc.Sat F → ∀ (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
         (e : TruthEnv.Env L F), (∀ ψ ∈ Γ, TruthEnv.T M τ t e ψ) → TruthEnv.T M τ t e φ

   instance : PointedSound Formula DerivationTree where
     sound d F hF M τ t _ h := soundness_in _ _ d F hF M τ t h
   instance : PointedSound PlusFormula PlusDerivationTree where
     sound d F hF M τ t _ h := Conservativity.plus_soundness_in _ _ d F hF M τ t h
   instance : PointedSound StarFormula StarDerivationTree where
     sound d F hF M τ t v h := Conservativity.star_soundness_in _ _ d F hF M τ t v h

   theorem truth_of_derivation {L : Type} [TruthEnv L] {D : FrameClass → List L → L → Sort u}
       [PointedSound L D] {fc : FrameClass} {Γ : List L} {φ : L} (d : D fc Γ φ)
       {F : TaskFrame} (hF : fc.Sat F) {M : TaskModel F} {τ : WorldHistory F} {t : F.Duration}
       (e : TruthEnv.Env L F) (h : ∀ ψ ∈ Γ, TruthEnv.T M τ t e ψ) : TruthEnv.T M τ t e φ :=
     PointedSound.sound d F hF M τ t e h
   ```

   `L` and `D` are both inferred from the type of `d` at every call site in the probe; no annotation was needed when `d` is a hypothesis.

3. **Keep `e` an explicit argument of the generic theorem.** [VERIFIED: FAIL -- with `{e}` implicit, `truth_of_derivation d hF h` at `Formula` fails with "don't know how to synthesize implicit argument `e`" (compiled probe): the `PUnit` instances ignore `e`, so unification against a native `TruthAt` goal never assigns it; revised to: `e` explicit, passed as `PUnit.unit` for TM and TM⁺ and as `v` for TM⋆ -- this form compiled] Write `PUnit.unit`, not `⟨⟩`: the anonymous constructor fails in that position because the expected type is still a metavariable when it is elaborated (also measured).

4. **Guard the module with `assert_not_exists` on the four `completeness_*` names**, copying the block from `FormalSystem/Automation/ProofMode.lean`. [VERIFIED: PASS -- the probe file imports all three soundness modules and carries this guard directly after the imports; it elaborated without error, so none of the three soundness modules pulls `StrongCompleteness` into the import closure]

5. **Tests in `Tests/BimodalTest/Metalogic/PointedSoundnessTest.lean`**, registered in `Tests/BimodalTest.lean`: for each of the three languages, one `example` deriving native pointed truth from an abstract tree and premises via `truth_of_derivation`; for TM⋆ additionally a register axiom at a point (`recall_rigid_future` at `.Base`, frame evidence by `inferInstance` under `[F.IsRegular]`) and a two-premise modus ponens from the context. [VERIFIED: PASS -- all five example shapes compiled in the probe]

6. **Do not add native-vocabulary corollaries** (`TruthAt`-typed or `StarTruthAt`-typed re-exports of the generic theorem) to the module. The instances are the only place a language theorem is named; the goals in the tests show the generic theorem already closes native goals by definitional unfolding. [No compiled gate applicable]

7. **Update the registries in the same change**: the "Main Results" list of `StarSoundness.lean`, a `docs/theorem-index.md` row beside line 719, the import list of `FormalSystem/Metalogic.lean`, and `Tests/BimodalTest.lean`. Then run `bash scripts/check-module-invariants.sh --no-build` and `bash scripts/check-metalogic-cycles.sh`; these were not run during research because no tree file was changed. [No compiled gate applicable]

## Decisions

- **Mixin over a relation parameter, not a class owning the relation.** The alternative, a class `PointedSound L` with a data field `Deriv : FrameClass → List L → L → Type`, was also compiled and works. Its merit: `L` alone determines the instance. It is not recommended because it makes this class a second owner of each language's derivation relation; the object-level interface of `proof_mode_abstract_frontend_interface` will have its own, and would then have to prove the two agree. With `D` a parameter, that interface writes `[PointedSound L D]` about its own relation and nothing is packaged twice. The mixin is also `Prop`-valued, so instances carry no data and cannot conflict.
- **`Sort u` for the relation** so the same class covers trees (`Type`) and `*Derivable` (`Prop`). Only the tree instances are recommended for landing; a `Derivable` instance is a one-liner if C4 wants it.
- **Base class is `TruthEnv`, not `PointTruth`.** The pointed statement needs the environment exposed.
- **`v` is not generalized in `star_soundness_in`'s induction.** Generalizing it also works but is unnecessary and departs from the plus proof for no gain.
- **No user decision is needed.** The module name and the class name are ordinary planner choices.

## Risks & Mitigations

- **Higher-order inference of `D`.** `D` is recovered by pattern unification from `d`'s type. This worked for hypotheses and for constructor terms given `(D := StarDerivationTree)`; an anonymous-constructor argument (`.axiom …`) needs `D` named, since its expected type is otherwise a metavariable application. C4's tactic will have the tree's type in hand, so this does not affect it. If a later interface wants instance search to find `D` from `L`, `D` can be made an `outParam` then without changing any statement.
- **Instance at an `abbrev` context type.** Instances are stated at `List L`; `StarContext` etc. are reducible `abbrev`s and unified without help in the probe.
- **Shared working tree.** A sibling task has `FormalSystem/StarLanguage/Formula.lean` and `FormalSystem/PlusLanguage/Formula.lean` in scope. This task edits neither, but `StarSoundness.lean` depends on both; a red build there during implementation may be the sibling's in-flight edit.
- **Documentation rules.** New module docstrings must state the current design only and cite no task number or branch history; in particular, do not describe the module by contrast with the rejected branch file.

## Tactic Survey Results

| Goal | Tactic | Result | Premises/Config |
|------|--------|--------|-----------------|
| Vacuous premise `∀ ψ ∈ [], StarTruthAt M σ t v ψ` (both necessitation arms) | `simp` | success | default |
| `StarTruthAt M τ t v (allFuture φ')` | `rw [StarTruth.allFuture_iff]` then `intro` | success | as in the plus proof |
| `StarTruthAt M τ t v (box φ')` | `intro σ` | success | clause is definitional |
| Premises of a two-element context in a test | `intro χ hχ; simp at hχ; rcases hχ with rfl \| rfl <;> assumption` | success | default |
| Implicit `e : TruthEnv.Env Formula F` | unification | fail | pass `PUnit.unit` explicitly |

## Context Extension Recommendations

- **Topic**: `TruthEnv` environment arguments at `PUnit` languages
- **Gap**: nothing records that a generic statement over `TruthEnv` cannot leave `e` implicit, because the `PUnit` instances discard it and unification never assigns it
- **Recommendation**: one sentence in the "environment parameter" section of `FormalSystem/Semantics/TruthClauses.lean`'s contract, if the implementer finds it useful; not required by this task

## Appendix

- Probe files (scratch, session-local, not part of the tree): `/tmp/claude-1000/-home-benjamin-Projects-BimodalLogic/e83fc3b6-ad91-42b1-8850-97e34fd38c71/scratchpad/Probe983.lean` (data-field class variant, includes the failing implicit-`e` example) and `/tmp/claude-1000/-home-benjamin-Projects-BimodalLogic/e83fc3b6-ad91-42b1-8850-97e34fd38c71/scratchpad/Probe983B.lean` (recommended mixin variant, zero errors). Command: `lake env lean <file>`.
- Searches: `grep` for `TruthEnv`, `inductive StarDerivationTree`, `abbrev *Context`, `theorem *completeness*`, `assert_not_exists`, and for the proposed names; `git show b3d8f6463:FormalSystem/Metalogic/ProofModeSoundness.lean`.
- No Mathlib search tools were needed; no MCP tool failed.
