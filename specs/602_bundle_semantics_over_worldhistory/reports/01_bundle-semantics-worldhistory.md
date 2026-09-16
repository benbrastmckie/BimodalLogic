# Research Report: Task #602

**Task**: 602 - Bundle semantics over WorldHistory
**Started**: 2026-09-16T21:04:41Z
**Completed**: 2026-09-16T21:40:00Z
**Effort**: Large (about 87 Lean files, 1329 `TruthAt` lines, 398 `IsTotal` lines, about 85 `SameStateAt` lines, plus about 12 docs/typst files)
**Dependencies**: Coordinate with task 601 (whichever lands second rebases)
**Sources/Inputs**: - Codebase (FormalSystem/, Tests/, docs/, typst/), lean-lsp MCP (`lean_run_code` prototypes, `#print axioms`), PossibleWorlds talk `talks/57_possible_worlds_tense_modal/slides.md`, prior report `specs/599_unify_total_histories_partial/reports/01_unify-total-histories-partial.md`, `docs/architecture/total-history-validity-decisions.md`
**Artifacts**: - specs/602_bundle_semantics_over_worldhistory/reports/01_bundle-semantics-worldhistory.md
**Standards**: report-format.md, subagent-return.md

## Executive Summary
- **Nothing blocks the refactor.** An audit of every live `PartialHistory` construction found that no consumer evaluates truth at a non-total history. The only non-total histories in the tree are Extension-machinery objects: `Extension.point`, `Admissible.adjoin`, `PartialHistoryOrder.chainSup` and the two-point history in `DeterministicBridge.deterministic_of_singletonClasses`. None of these is ever passed to `TruthAt`, `PlusTruthAt`, `MinusTruthAt` or `StarTruthAt`. `atom_false_of_not_domain` has no callers.
- **Keep the subtype design as the task describes it.** `def WorldHistory (F : TaskFrame) : Type _ := {τ : PartialHistory F // τ.IsTotal}`, plus `WorldHistory.state τ t := τ.val.states t (τ.property t)`. This is exactly what the talk slides already show. A separate total-function structure was considered and rejected (see Decisions).
- **Prototypes compile with no `sorry`** (run through `lean_run_code` against the real imports):
  - the new `TruthAt` (atom `M.valuation (τ.state t) p`, box `∀ σ : WorldHistory F, …`);
  - `box_iff` by `Iff.rfl`;
  - `timeShift_state` and `ofTotal_state` by `rfl`;
  - `TruthCorr` over `WorldHistory`, with a non-dependent `atom` field and `fwd`/`bwd` fields that no longer need `IsTotal`, plus the full six-case `truthAt_of_truthCorr`;
  - `shiftCorr`, with `ShiftRel Δ ρ ρ' := ∀ z, ρ.state z = ρ'.state (z + Δ)`;
  - `timeShift_preserves_truth` over `WorldHistory`. Its axioms are `[propext, Quot.sound]`, the same as today's baseline.
- The bundled `ShiftRel` and `TruthCorr.atom` are **strictly simpler** than today's: the domain-transport halves and `states_eq_of_time_eq` rewrites disappear.
- **Recommended approach:** one atomic-batch change done in layers (details under Recommendations). The type of `TruthAt` changes, so no green intermediate state exists once the core signature moves. Only the first sub-step, which introduces `WorldHistory` and renames `HF`, is independently green.

## Context & Scope
The task asks for four things:
1. Replace `TaskFrame.HF` with `WorldHistory F`, with no alias left behind.
2. Give `WorldHistory` a `state` API.
3. Retarget `TruthAt`, `PlusTruthAt`, `MinusTruthAt`, `StarTruthAt` and every validity, consequence and satisfiability predicate to take `WorldHistory F`. This drops the atom-clause domain conjunct, the `σ.IsTotal →` quantifier pattern and `SameStateAt`.
4. Record Decision A' and update the docs.

This research covered:
- the design;
- whether any consumer needs truth at a partial history (item (4) of the task);
- the size and shape of the migration;
- how elaboration behaves: `def` subtype, field notation, the `FrameOver` coercion, simp normal form;
- which bridge lemmas become dead.

Constraints: zero `sorry`, axiom baselines unchanged (C2/C14), no compatibility shims, Boneyard excluded (0 Boneyard files mention `PartialHistory`/`IsTotal`).

## Findings

### Codebase Patterns

**Current encoding (Decision A / B')**
- `TruthAt (M) (τ : PartialHistory F) (t)`, defined in `FormalSystem/Semantics/Truth.lean:257`:
  - atom clause `∃ (ht : τ.domain t), M.valuation (τ.states t ht) p`;
  - box clause `∀ σ : PartialHistory F, σ.IsTotal → …`.
- The same shape appears in:
  - `MinusTruthAt` (`MinusLanguage/MinusTruth.lean:108`), including the atom conjunct;
  - `PlusTruthAt` (`PlusLanguage/PlusTruth.lean:121`), whose stab clause is `∀ σ, σ.IsTotal → SameStateAt τ σ t → …`;
  - `StarTruthAt` (`StarLanguage/StarTruth.lean:111`);
  - `CTruthAt` (`Metalogic/Independence/CoarsenedModels.lean:143`);
  - the test-only `ToyTruthAt` (`Tests/BimodalTest/Semantics/ValidityLayerTest.lean:222`).
- `SameStateAt τ σ t := ∀ hτ hσ, τ.states t hτ = σ.states t hσ` (`PlusTruth.lean:79`). At a non-total history this is vacuous, which is what forces `hτ t`/`hσ t` arguments into `sameStateAt_congr_left`, `stab_congr_sameState` and `SameStateAt.trans`.
- The abstract layers are typed over `PartialHistory F` and must change signature:
  - `TruthClauses.TruthEnv.T` (`TruthClauses.lean:~180`);
  - `StabClause.sameState` (`TruthClauses.lean:258`);
  - `ValidityLayer.PointTruth.sat` (`ValidityLayer.lean:172`).
- `TaskFrame.HF` (`PartialHistory.lean`) is used only for:
  - `thm:extension` and `cor:occurrence`;
  - `TaskFrame.ValidOn` and `GenericValidOn`;
  - `TruthIso.hist`;
  - `ShiftSet`, `IntNormalForm`, `Correspondence/{DurationFrames,FwdRec,FwdRecBridge}`, `PeriodicExtension`;
  - `BiLasso.{Basic,Extend,Realized}` (`toHF`);
  - `Compactness`, `CoNotPriorU`.
- `FrameOver.HF` exists only so that dot-notation `F.HF` resolves for a fibre-typed `F`. Under `WorldHistory F`, written as ordinary application, the existing `FrameOver → TaskFrame` coercion fires (verified), so this alias can simply be deleted.

**Measured migration surface (live tree, Boneyard excluded)**

| Pattern | Count |
|---|---|
| Files mentioning `IsTotal` / `HF` / `SameStateAt` | 87 |
| Files mentioning any truth relation | 128 |
| `TruthAt` lines | 1329 |
| `IsTotal` lines | 398 |
| `.IsTotal →` quantifier sites | 111 |
| `.IsTotal ∧` existential sites | 14 |
| `SameStateAt` lines | about 85, in 22 files |
| `.val` / `.property` uses near HF/states/Truth | 157 |

Largest `IsTotal` users:

| File | `IsTotal` lines |
|---|---|
| `Semantics/Validity.lean` | 35 |
| `PlusLanguage/PlusPasting.lean` | 16 |
| `ValidityLayer.lean` | 14 |
| `PlusTruth.lean` | 14 |
| `Independence/StaticFrame.lean` | 14 |
| `Decidability/Verified/Decidable.lean` | 14 |
| `StarValidity.lean` | 13 |
| `MinusValidity.lean` | 13 |
| `OrderTransfer.lean` | 11 |
| `CoarsenedModels.lean` | 11 |

**Audit for truth at a partial history (task item 4)**

| Consumer | Evaluates truth at a non-total history? | Restatement over `WorldHistory` |
|---|---|---|
| `TruthTransport.truthAt_of_truthCorr` / `TruthCorr` | No. `Rel` is stated on arbitrary histories, but every instance's `total_fwd`/`total_bwd` produce total ones, and all callers pass total pairs | `Rel : WorldHistory F → WorldHistory F' → Prop`; `atom : Rel σ σ' → (M.valuation (σ.state t) p ↔ M'.valuation (σ'.state (dur t)) p)`; `fwd : ∀ σ, ∃ σ', Rel σ σ'`; `bwd` likewise. **Prototyped, compiles.** |
| `TimeShift.shiftCorr`, `timeShift_preserves_truth` | No. The arbitrary-σ statement is documented as free extra generality; every live consumer passes a total history | `ShiftRel Δ ρ ρ' := ∀ z, ρ.state z = ρ'.state (z+Δ)`; `timeShift_preserves_truth (σ : WorldHistory F)`. **Prototyped, compiles**, axioms `[propext, Quot.sound]` (the baseline). Delete `timeShift_preserves_truth_total`, which becomes a duplicate. |
| `Truth.box_const` / `box_time_const` | No. `_hτ`/`_hσ` are documented as unconsumed | Drop the hypotheses; the proof uses `WorldHistory.timeShift`. |
| `TruthIso` / `TruthAntiIso` | No. Already total-only (`F.HF ≃ F'.HF`) | `hist : WorldHistory F ≃ WorldHistory F'`; `Rel σ σ' := I.hist σ = σ'`; `atom` stated with `.state`. |
| `IntTransfer.alignedCorr` / `truthAt_map` / `validZTime_iff_validInt` | No. `Aligned` is stated on arbitrary histories, but the only consumer (`validZTime_iff_validInt`) passes total ones | Add `WorldHistory.map e` and `WorldHistory.comap e` (subtype of `PartialHistory.map`/`comap` with `isTotal_map`, `fun s => hσ' (e s)`); `Aligned` can become `∀ n, σ'.state n = σ.state (e.symm n)`. The dependent `dom`/`st` pair collapses. |
| Extension Theorem (`Extension/*.lean`, `PartialHistoryOrder`) | No. None of these files mentions any truth relation | `extension : ∃ σ : WorldHistory F, Extends σ.val τ` and `occurrence : ∃ τ : WorldHistory F, τ.state x = w`. **Prototyped against the live theorems: they typecheck unchanged**, because `WorldHistory` unfolds to the same subtype. `Extends` stays on `PartialHistory`. |
| `DeterministicBridge.deterministic_of_singletonClasses` | Builds a non-convex two-point `PartialHistory`, but only to feed `thm:extension`, never truth | `SingletonClasses` over `WorldHistory` with `τ.state x = σ.state x`; the `hsame` step becomes `h₁0.trans h₂0.symm`. |
| Canonical / chronicle countermodels (`BXCanonical`, `WeakCanonical/…/ReynoldsBridge`, `Algebraic/FlowFrame`) | No. All histories are `domain := fun _ => True` records or `multiFamHistoryGen`, with `IsTotal` proved by `fun _ => trivial` | Rebuild as `WorldHistory.ofTotal …` or `⟨rec, fun _ => trivial⟩`. The set equalities `{σ | ∀ t, σ.domain t} = Set.range zHistoryV2` (`ReynoldsBridge.lean:671`, `ChronicleMonadicBridge.lean:155`) become surjectivity or `Set.univ = Set.range …` statements over `WorldHistory`. |
| Decidability bridge (`Verified/Bridge/RegionFrame.lean`, `Interpolate.lean`, `TruthLemma.lean`, `Verified/Decidable.lean`) | No. Every truth call is at a total history; `RegionConstant f τ` hypotheses are guarded by `τ.IsTotal` | `regionHistory : WorldHistory _`; `isTotal_iff_regionHistory` (`RegionFrame.lean:387`) becomes `∀ σ : WorldHistory F, ∃ w Δ, σ = regionHistory f w Δ` via `Subtype.ext` on the existing proof; `RegionConstant` retyped to `WorldHistory` (or applied to `σ.val`). |
| BiLasso (`Basic`, `Extend`, `Realized`, `SmallModel`, `TruthLemma`, `BoxOracle`, …) | No. `hist A := A.lasso.toHF.val` | `toHF` becomes `toWorldHistory`, and `hist A := A.lasso.toWorldHistory` with no `.val`. |
| MinusLanguage native semantics (`MinusTruthAt`, `MinusLanguageSoundness.truthAt_tr`, `minusTruthAt_timeShift`) | No. `truthAt_tr` is stated for arbitrary τ, but it is an induction, and restating it over `WorldHistory` is uniform | Same retarget as `TruthAt`. `MinusFrameTruth` (`MinusFrame.lean:186`) is a non-`TaskFrame` semantics and is untouched. |
| Plus/Star pasting (`PlusPasting.paste`, `StarPasting`) | No. `paste` already requires `hρ hσ : IsTotal` | `WorldHistory.paste (ρ σ : WorldHistory F) (t) (hsame : ρ.state t = σ.state t) : WorldHistory F`. |
| `Correspondence/FwdRecPeriodicity.truthAt_add_hist_period` (own induction) | No. Stated with `(τ) (hτ : τ.IsTotal)` | Mechanical retarget. |
| `CoarsenedModels.CTruthAt` (a separate coarse truth relation with `SameUnder`) | No | Retarget in parallel. It is not a `TruthClauses` instance, so it moves on its own. |

Conclusion: **no obstruction site exists.** Truth never needs to be evaluated at a genuinely partial history, so no parallel partial-history truth relation is needed.

### External Resources
- No Mathlib search was needed: every declaration involved is local.
- Mathlib facts relied on: `Subtype.ext` (for a `WorldHistory.ext` lemma) and `OrderIso.addRight`, whose `dur t` reduction to `t + Δ` still needs the `change` step already recorded in `timeShift_preserves_truth`.
- Talk slides (`~/Philosophy/Papers/PossibleWorlds/talks/57_possible_worlds_tense_modal/slides.md`) quote the target names:
  - lines 1623-1626: `def WorldHistory (F : TaskFrame) : Type _ := {τ : PartialHistory F // τ.IsTotal}` and `def WorldHistory.state`;
  - line 1694: `TruthAt (τ : WorldHistory F)`;
  - line 1712: the atom clause `M.valuation (τ.state t) p`;
  - line 1763: `∀ σ : WorldHistory F`;
  - lines 1818-1819: the stab clause `τ.state t = σ.state t → …`;
  - lines 1888-1892: `timeShift_preserves_truth (σ : WorldHistory F)` with `σ.timeShift`.
- The recommended design matches every one of these names **character for character**.
- Caveat: the slide shows `stab` inside `TruthAt`, but in Lean `stab` is a clause of `PlusTruthAt`/`StarTruthAt`. The slide merges the layers for exposition and should be re-checked only for the clause text.

### Recommendations

**API to introduce (in `Semantics/PartialHistory.lean`, replacing the `TaskFrame.HF` section)**

Keeping it in this file avoids a new module and any manifest or import churn.

```lean
def WorldHistory (F : TaskFrame) : Type _ := {τ : PartialHistory F // τ.IsTotal}
namespace WorldHistory
instance : CoeOut (WorldHistory F) (PartialHistory F) := ⟨Subtype.val⟩
def state (τ : WorldHistory F) (t : F.Duration) : F.WorldState := τ.val.states t (τ.property t)
@[simp] theorem states_eq_state (τ) (t) (h : τ.val.domain t) : τ.val.states t h = τ.state t := rfl
@[ext] theorem ext {τ σ : WorldHistory F} (h : τ.val = σ.val) : τ = σ := Subtype.ext h
def ofTotal (F) (f) (h) : WorldHistory F := ⟨PartialHistory.ofTotal F f h, PartialHistory.ofTotal_isTotal F f h⟩
@[simp] theorem ofTotal_state … : (ofTotal F f h).state t = f t := rfl
@[simp] theorem ofTotal_val … := rfl          -- keep only if still used
def timeShift (τ : WorldHistory F) (Δ) : WorldHistory F := ⟨τ.val.timeShift Δ, isTotal_timeShift τ.property Δ⟩
@[simp] theorem timeShift_state (τ) (Δ t) : (τ.timeShift Δ).state t = τ.state (t + Δ) := rfl
theorem state_congr (τ) {s t} (h : s = t) : τ.state s = τ.state t   -- replaces states_eq_of_time_eq at WorldHistory sites
end WorldHistory
```

All of the above except `state_congr` and `ofTotal_val` were compiled in prototypes; both are one-liners. Notes:
- **Simp direction:** `WorldHistory.state` is the normal form, and `states_eq_state` rewrites toward it. The proof-irrelevance lemma the task asks for is `states_eq_state`, whose `h` argument is arbitrary.
- **Keep `WorldHistory` a `def`, not an `abbrev`.** That matches `HF` today and the slide, and stops `Subtype` simp lemmas and instances from leaking. Verified: `τ.val`, `τ.property` and `τ.state` all resolve by field notation, and `WorldHistory G` with `G : FrameOver D` elaborates through the coercion.

**Signature changes**
- `TruthEnv.T` and `PointTruth.sat` take `WorldHistory F`.
- Delete the `StabClause.sameState` field and state `stab_clause` directly with `τ.state t = σ.state t`. All four instances (`PlusTruth.lean:153`, `StarTruth.lean:150`) supply `SameStateAt`, so the field no longer abstracts anything.
- `TruthAt`, `MinusTruthAt`, `PlusTruthAt`, `StarTruthAt`, `CTruthAt` and `ToyTruthAt`:
  - atom clause becomes `M.valuation (τ.state t) p`;
  - box becomes `∀ σ : WorldHistory F, …`;
  - stab becomes `∀ σ : WorldHistory F, τ.state t = σ.state t → …`.
- All validity-style predicates quantify `∀ τ : WorldHistory F`: `Valid`, `ValidIn`, `ValidOnFrames`, `ConsequenceOnFrames`, `SemanticConsequenceIn`, `SemanticConsequence`, `satisfiable`, `SatisfiableAbs`, `FormulaSatisfiable`, `TaskFrame.ValidOn`, `GenericValidOn`, and the Plus/Minus/Star validity layers.

**Bridge-lemma disposition (delete when unused, per item (5))**
- **Delete outright:**
  - `Truth.atom_false_of_not_domain` (0 callers);
  - `TimeShift.timeShift_preserves_truth_total`;
  - `FrameOver.HF` and its `example`;
  - `SameStateAt` and its whole API: `sameStateAt_iff_of_total`, `.refl/.symm/.trans`, `sameStateAt_timeShift`, `sameStateAt_congr_left`. `Eq.refl`/`Eq.symm`/`Eq.trans` and `timeShift_state` replace them;
  - `PlusTruth.timeShift_isTotal'`, `shift_neg_shift_domain`, `shift_neg_shift_states`;
  - `TruthTransport.shiftRel_timeShift_neg`'s domain half.
- **Collapse to trivial, then delete if no caller remains:**
  - `validOn_iff_total` and `valid_iff_forall_validOn` (both sides now coincide);
  - the unbundled adapters `Valid.of_forall_total`/`apply`/`of_not`, `ValidIn.of_forall_total`/`apply_total`/`of_not`, `ValidOnFrames.of_forall_total`/`apply_total`/`of_not`, `SemanticConsequence(In).of_forall(_total)`/`apply(_total)`, and the `ValidityLayer` generic counterparts. They existed only to reshape `(τ)(hτ)` into `F.HF`.
  - Recommendation: keep one `apply`/`of_forall` pair per predicate only if a call site still benefits from the binder order (e.g. `validZTime_iff_validInt` uses `ValidIn.apply_total`), and rename it without the `_total` suffix.
- **Retype:**
  - `Truth.atom_iff_of_domain` becomes `Truth.atom_iff : TruthAt M τ t (atom p) ↔ M.valuation (τ.state t) p := Iff.rfl`;
  - `stab_congr_sameState` becomes `stab_congr_state` (it takes `h : τ.state t = σ.state t` and drops the `hτ hσ` domain arguments).
- **Ideally zero transitional lemmas survive.** A temporary `WorldHistory.mk_state : (⟨τ, hτ⟩ : WorldHistory F).state t = τ.states t (hτ t) := rfl` may help `simp` during migration; delete it at the end if it is unused.

**Migration idioms (mechanical)**
- `∀ σ : PartialHistory F, σ.IsTotal → P σ` becomes `∀ σ : WorldHistory F, P σ`. Proof bodies change `intro σ hσ` to `intro σ`, and `hσ t` to `σ.property t`, or disappear under `states_eq_state`.
- `(τ : PartialHistory F) (hτ : τ.IsTotal)` binders become `(τ : WorldHistory F)`. Inside proofs that manipulate the raw record, `obtain ⟨τ, hτ⟩ := τ` recovers the old names. Truth statements then mention `⟨τ, hτ⟩`, so prefer `τ.val`/`τ.property`.
- `τ.states t (hτ t)` becomes `τ.state t`.
- `∃ σ, σ.IsTotal ∧ P σ` becomes `∃ σ : WorldHistory F, P σ`.
- Histories built with `domain := fun _ => True` become `WorldHistory.ofTotal F f h`, or `⟨{…}, fun _ => trivial⟩` where the record has non-trivial `states`.

**Execution order**

Once `TruthAt`'s parameter type changes, every consumer breaks at the same moment (no green reverse-topological order like Decision D exists). Run it as a declared atomic-batch:
1. **Green on its own:** rename `TaskFrame.HF` to `WorldHistory` and add the `state`/`timeShift`/`ofTotal` API; migrate the `HF` users (about 20 files). Commit.
2. **Atomic batch A, the semantic core:**
   - `TruthClauses`, `ValidityLayer`, `Truth`, `TruthTransport`;
   - `Validity`, `FrameClassValidity`, `IntTransfer`, `IntNormalForm`, `ShiftSet`, `DeterministicBridge`, `StateLocalTransfer`;
   - `Correspondence/*`, `Extension/PeriodicExtension`.

   Check each module with a targeted `lake build FormalSystem.Semantics.<Module>` in import order.
3. **Batch B:** the Minus, Plus and Star languages (`MinusLanguage/*`, `PlusLanguage/*`, `StarLanguage/*`).
4. **Batch C, Metalogic consumers, directory by directory:** `Soundness`/`SetConsequence`/`Deterministic`, then `Conservativity`, `Independence`, `Decidability` (`BiLasso`, then `Verified/Bridge`, then `Verified/Decidable`), `WeakCanonical`/`BXCanonical`/`Algebraic`, `Automation/PrefilterSoundness`, `Examples`, and `Tests`.
5. Full guarded detached `lake build`, `scripts/check-module-invariants.sh` (C2/C14), and the acceptance greps (below). Commit batches A to C together when green, or on a task branch per the atomic-batch carve-out.
6. **Docs:**
   - record Decision A' in `docs/architecture/total-history-validity-decisions.md`, superseding Decision A, the accepted atom-clause gap, and B''s "deferred alternative";
   - rewrite the `PartialHistory.lean` module docstring table (and delete its "no `abbrev WorldHistory`" note);
   - update the `Truth.lean` docstring (the "ProofChecker Implementation Alignment" section and the simp-normal-form table rows for `box_iff`/`diamond_iff`);
   - update `FormalSystem/Semantics.lean` lines 75-77, 131, 219 and 250;
   - update `docs/user-guide/architecture.md` (14 hits), `tutorial.md` (6), `docs/reference/API_REFERENCE.md` (5), `paper-definitions-of-record.md` (4), `LEAN_STYLE_GUIDE.md` (3), `theorem-index.md` (2), `typst/chapters/02-semantics.typ` (2), `FormalSystem/Semantics/README.md` (2), `README.md`, `operators.md`, `INTEGRATION.md` and `DIRECTORY_README_STANDARD.md`;
   - re-check the talk slides.

   The docs pass can run as its own green phase after the Lean work.

**Acceptance greps (outside Boneyard)**
- `grep -rnE "\.IsTotal *(→|∧)" --include=*.lean FormalSystem Tests` returns 0.
- `grep -rn "∃ (ht : τ.domain t)" --include=*.lean` returns 0 in truth definitions.
- No `\bHF\b` and no `SameStateAt` remain.

Sub-step 1 and batch A were sized so that each fits one agent run. Batch C is the largest (about 55 files), so the planner should split it by directory into atomic-batch sub-steps that share one final green commit.

## Decisions
- **Subtype `def WorldHistory` rather than a standalone structure with `state : D → W`.** The slides already quote the subtype. It leaves `PartialHistory.IsTotal` as the one defining predicate, as the task requires. `thm:extension` and `cor:occurrence` typecheck with no promotion step (prototyped). The structure alternative would bring back two history types and a coercion into `PartialHistory` for `Extends`, which the report for task 599 already rejected.
- **Delete the `StabClause.sameState` field.** The agreement relation becomes the fixed equation `τ.state t = σ.state t`; the field would carry no abstraction.
- **Delete `FrameOver.HF` with no replacement.** Function-application syntax `WorldHistory F` goes through the existing coercion (verified).
- **Retype `IntTransfer.Aligned` and `TruthCorr.Rel` to `WorldHistory`.** Nothing needs their arbitrary-history generality, and bundling removes the dependent domain-transport halves that the old "Aligned, not Equiv" design note guarded against. `Aligned` stays a relation rather than an `Equiv`.
- **Keep `WorldHistory` in `PartialHistory.lean`** rather than a new module, to avoid manifest and import churn. The module docstring title already says "partial and world histories".
- **No user decision is required.** The design matches the task description and the slides, and no obstruction was found.

## Risks & Mitigations
- **Blast radius and red window.** About 87 files are touched with no green midpoint after sub-step 1. Mitigation: atomic-batch phases with targeted per-module builds; a task branch or worktree; detached guarded full builds only at batch ends.
- **Axiom baseline drift (C2/C14).** A proof that used to discharge the atom conjunct through `rintro ⟨h, hv⟩` may now close through `simp`, which can add or remove `propext`/`Quot.sound`. Mitigation: after batch C, compare `#print axioms` for the C2 flagship theorems and C14 subjects before committing. Prefer `Iff.rfl` or `rw [h]` over `simp` in the clause lemmas, following `TruthClauses`' "Classical discipline" note. The prototype `timeShift_preserves_truth` already matches the baseline `[propext, Quot.sound]`.
- **Simp normal form regressions.** Proofs that now unfold `WorldHistory.state` can leave `τ.val.states t _` terms. Mitigation: `@[simp] states_eq_state` rewrites toward `state`. Do not tag `WorldHistory.state` as simp-unfoldable.
- **Structural recursion.** Verified: `TruthAt` over `WorldHistory` compiles with no termination annotation, since recursion is on the formula.
- **Collision with task 601** (reflection convention; touches `TaskFrame.lean` and frame constructions). Mitigation: whichever lands second rebases. Construction sites move to `WorldHistory.ofTotal`, a local and mechanical conflict.
- **Set-equality statements over `{σ | ∀ t, σ.domain t}`** (`ReynoldsBridge.lean:671`, `ChronicleMonadicBridge.lean:155`) need restating as surjectivity or `Set.univ` equalities. These are small, known sites.
- **Docs lint.** `check-paper-definitions.sh` has pre-existing unrelated failures. Do not cite task numbers in deliverables (`no-task-references-in-deliverables`).

## Tactic Survey Results

| Goal | Tactic | Result | Premises/Config |
|------|--------|--------|-----------------|
| `TruthAt` over `WorldHistory F` (6 clauses) | structural recursion | success | none |
| `box_iff` over `WorldHistory` | `Iff.rfl` | success | definitional |
| `(τ.timeShift Δ).state t = τ.state (t + Δ)` | `rfl` | success | definitional |
| `(ofTotal F f h).state t = f t` | `rfl` | success | definitional |
| `ShiftRel Δ ρ (ρ.timeShift (-Δ))` | `simp [add_neg_cancel_right]` | success | `timeShift_state` |
| `truthAt_of_truthCorr` over `WorldHistory` | existing induction with `IsTotal` args removed | success | `OrderIso.lt_iff_lt`, `surjective` |
| `timeShift_preserves_truth` over `WorldHistory` | `change` + `rwa [add_sub_cancel]` | success, axioms `[propext, Quot.sound]` | `shiftCorr` |
| `∃ σ : WorldHistory F, Extends σ.val τ` | existing `PartialHistory.extension` term | success | definitional unfolding |
| `∃ τ : WorldHistory F, τ.state x = w` | existing `PartialHistory.occurrence` term | success | definitional unfolding |
| states equality from `τ.state t = σ.state t` | `simpa using h` | success | `states_eq_state` |
| `box` backward case of time shift without a relation (direct induction) | direct | not closed (needs history equality) | use `TruthCorr` relation instead |

## Context Extension Recommendations
- **Topic**: Bundled world-history encoding
- **Gap**: `docs/architecture/total-history-validity-decisions.md` records Decision A, the accepted atom-clause gap, and B''s deferred alternative, all of which this task supersedes.
- **Recommendation**: add Decision A' (bundled `WorldHistory`, literal atom clause, no `SameStateAt`) and mark A superseded. Also add a `.claude/context/project/lean4` pattern note: when bundling a subtype, prefer a `def` with a simp lemma rewriting dependent projections toward the non-dependent accessor.

## Appendix
- Searches:
  - greps for `IsTotal`, `\bHF\b`, `SameStateAt`, `domain :=`, `.IsTotal →`/`∧`, `atom_false_of_not_domain`, `atom_iff_of_domain`, `sameState`, `toHF`, `FrameOver.HF`, `PartialHistory` definitions, and `non-total`/`arbitrary histor` prose;
  - doc/typst greps for `IsTotal|HF|PartialHistory F`;
  - a slides grep for `WorldHistory|TruthAt|timeShift_preserves_truth`.
- MCP: four `lean_run_code` prototypes (all succeeded; the only error was a missing `TaskModel` import in one probe, which was fixed). `#print axioms` was run on the live `timeShift_preserves_truth`, `truthAt_of_truthCorr` and `validZTime_iff_validInt` for the baseline.
- No rate-limited search tools were used, since all declarations are local. The blocked tools were not used.
- State: task 601 is `researching`; task 603 is unrelated.
