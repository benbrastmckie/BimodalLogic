# Research Report: Task #599

**Task**: 599 - Unify total histories on PartialHistory (drop ConvexHistory as a structure)
**Started**: 2026-09-16T11:42:17-07:00
**Completed**: 2026-09-16T11:50:00-07:00
**Effort**: Medium-large (mechanical but wide: ~91 live Lean files, ~30 Markdown docs, 1 slide deck)
**Dependencies**: None
**Sources/Inputs**: - Codebase (FormalSystem/Semantics/{PartialHistory,PartialHistoryOrder,ConvexHistory,Truth,TruthTransport,TruthClauses,Validity,ValidityLayer,IntTransfer}.lean, Semantics/Extension/*), lean-lsp MCP (`lean_run_code` feasibility probe), paper source `~/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex` (sec:Construction and appendix `def:world-history`), talk `~/Philosophy/Papers/PossibleWorlds/talks/57_possible_worlds_tense_modal/slides.md`, `docs/architecture/total-history-validity-decisions.md`, `scripts/check-paper-definitions.sh`
**Artifacts**: - specs/599_unify_total_histories_partial/reports/01_unify-total-histories-partial.md
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **Convexity does no work anywhere in the live tree.** The `convex` field is only ever
  *re-established* (by `ConvexHistory.timeShift`, `ConvexHistory.map`/`comap` in
  `IntTransfer.lean`, and `toConvexHistory` in `Extension.lean`) or filled with `trivial` at a
  total construction site. No proof *uses* it. (All other `.convex` hits are in
  `DenseModelSurgery`/`DoetsTheorem` and belong to unrelated structures.)
- **Every `ConvexHistory` value built in live code is total.** The 17 `convex :=` sites and all
  the `ConvexHistory.ofTotal`/`multiFamHistoryGen`/`HFofStepPath` constructions use
  `domain := fun _ => True`. The only non-total histories are `PartialHistory` values
  (`Extension.point`, the two-point history in `DeterministicBridge.lean`, `adjoin`,
  `chainSup`), and none of them is ever turned into a `ConvexHistory` unless it is total.
- **The layer has duplicates.** Each of these exists twice, once on `PartialHistory` and once on
  `ConvexHistory`: `IsTotal`, `total_nonempty`, `timeShift`, `states_eq_of_time_eq` (with
  *different* binder explicitness), and `isTotal_timeShift`/`timeShift_mono` style lemmas.
  `Extension.lean` also carries promotion glue (`total_isConvex`, `toConvexHistory`,
  `toConvexHistory_toPartialHistory`, `isTotal_toConvexHistory`), and there is dead code:
  `ConvexHistory.universal`, `universalTrivialFrame`, `universalNatFrame` and `stateAt` are
  never referenced outside docstrings.
- **Recommended approach (sorry-free, verified by probe):** delete the `ConvexHistory`
  structure. Make `TruthAt`, the other languages' truth relations, `TruthCorr`, validity and
  `TaskFrame.HF := {τ : PartialHistory F // τ.IsTotal}` all range over `PartialHistory`.
  Keep convexity as a paper-fidelity predicate `PartialHistory.IsConvex`, with
  `IsTotal.isConvex` and `isConvex_timeShift`. `thm:extension` then needs no promotion step:
  `⟨⟨μ, htot⟩, le_def.mp hle⟩`.
- **This matches the body text of the paper, and the appendix agrees on the set.**
  sec:Construction (line ~1019) says: "A *world history* is any partial history τ : X → W whose
  domain is total". The appendix `def:world-history` still says "A *possible world* is any
  convex history whose domain is total". Total implies convex, so both describe the same
  `H_F`, and the refactor is faithful to both. The wording mismatch is a paper-side issue to
  fix outside this repository.
- **One design question goes to the user (non-blocking).** It is whether to also collapse the
  hybrid predicate/subtype encoding, i.e. Decision A of
  `docs/architecture/total-history-validity-decisions.md`, into a single bundled `F.HF`
  quantifier. Recommendation: keep the hybrid for this task and only re-base it onto
  `PartialHistory`. See Decisions.

## Context & Scope

Scope: the `Semantics/` history layer (`PartialHistory`, `ConvexHistory`, `TaskFrame.HF`, time
shift, extension, frame transport) and how it is consumed by truth and validity. Downstream
consumers were measured, not edited. Boneyard is not imported by `FormalSystem.lean`: it
contains 2 files that mention `ConvexHistory` and is out of build scope.

### Paper text (`JPL/possible_worlds.tex`)

- sec:Construction, body: partial history on a nonempty X ⊆ D; convex history = partial history
  with convex domain (the chess-game example); **world history = any partial history whose
  domain is total**; `H_F` = the set of all world histories, later also called the possible worlds.
- Appendix `def:world-history` (pinned in `docs/reference/paper-definitions-of-record.md`, not
  currently drifted): "A *possible world* is any convex history whose domain is total … The set
  of all possible worlds over F is denoted H_F."
- `scripts/check-paper-definitions.sh` already FAILs on 16 *other* anchors (pre-existing drift
  unrelated to this task). `def:world-history` is not among them.

### Measured footprint (live tree, Boneyard excluded)

| Pattern | Lines | Files |
|---------|-------|-------|
| `ConvexHistory` (any) | ~750 | 91 |
| `.IsTotal` | ~395 | 79 |
| `TruthAt` | 1330 | 123 |
| `import FormalSystem.Semantics.ConvexHistory` | 9 | 9 |
| `ConvexHistory.isTotal_timeShift` | 27 | - |
| `ConvexHistory.timeShift` | 21 | - |
| `ConvexHistory.ofTotal` / `ofTotal_isTotal` | 13 / 6 | 9 |
| `ConvexHistory.states_eq_of_time_eq` | 10 | 6 |
| `ConvexHistory.map` / `comap` | 7 / 9 | 1 (`IntTransfer.lean`) |
| `ConvexHistory.IsTotal` (qualified) | 8 | 6 |
| `ConvexHistory.mk (PartialHistory.mk _ _ _ _) _` in `change` | 6 | 2 (`FlowFrame.lean`, `ReynoldsBridge.lean`) |
| `.toPartialHistory` projections | 11 | 4 |
| Markdown docs mentioning `ConvexHistory` | - | ~30 |

## Findings

### Codebase Patterns

**Current three-tier encoding.**
- `PartialHistory F` (in `PartialHistory.lean`) has the fields `domain`, `nonempty_domain`,
  `states`, and an unconditional `respects_task`. It also defines `IsTotal`, `Extends`, `ofLe`
  and `total_nonempty`.
- `PartialHistoryOrder.lean` adds the extension preorder, `PartialHistory.timeShift` (same field
  bodies as the convex version), `states_eq_of_time_eq` with implicit times, `chainSup`, Zorn,
  and `isMax_of_total`.
- `ConvexHistory F extends PartialHistory F` adds `convex`. On top of it sit `ofTotal` and its
  simp lemmas, `universal*`, `trivial`, `stateAt`, `timeShift`, `states_eq_of_time_eq` with
  explicit times, `timeShift_congr`, `IsTotal` (defined as `τ.toPartialHistory.IsTotal`),
  `isTotal_iff`, `isTotal_timeShift` and `total_nonempty`. The same file defines
  `TaskFrame.HF := {τ : ConvexHistory F // τ.IsTotal}`, `HF.ofTotal`, `HF.timeShift` and
  `FrameOver.HF`.
- `Extension.lean` defines `total_isConvex` and `toConvexHistory` only to cross from the
  `PartialHistory` world (where Zorn works) to the `ConvexHistory` world (where `HF` lives).

**Consumers that are typed over `ConvexHistory`** and would become `PartialHistory`:
- `TruthAt` (`Truth.lean:243`) and its box clause `∀ σ : ConvexHistory F, σ.IsTotal → …`.
- `PlusTruthAt`, `MinusTruthAt`, `StarTruthAt`, and `CTruthAt` in `CoarsenedModels.lean`.
- The generic layers `TruthEnv.T` (`TruthClauses.lean:188`) and `PointTruth.sat`
  (`ValidityLayer.lean:172`).
- `TruthCorr.Rel` and `ShiftRel` in `TruthTransport.lean`, and `Aligned`/`map`/`comap` in
  `IntTransfer.lean`.
- Every validity predicate and adapter in `Validity.lean` and `ValidityLayer.lean`.

None of these depends on convexity, so the change is a type substitution plus deletion of the
`convex` obligations.

**Definitional-equality safety.** `PartialHistory.timeShift` and `ConvexHistory.timeShift` have
identical `domain` and `states` bodies. Downstream `rfl`/`show` proofs that unfold a shifted
history therefore still hold after retargeting. `ConvexHistory.IsTotal` unfolds to
`PartialHistory.IsTotal` by `Iff.rfl`, so `τ.IsTotal` dot-notation resolves to the same
predicate.

### External Resources

- Mathlib: `add_le_add_left` in this pinned Mathlib has the shape `a ≤ b → a + c ≤ b + c`.
  `add_le_add_right` yields `c + a ≤ c + b`, the opposite of what the existing
  `ConvexHistory.timeShift` proof suggests. This was confirmed by the probe below.
- `zorn_le_nonempty_Ici₀` (already used by `exists_maximal_extension`) is unaffected.

### Feasibility probe (lean_run_code, against the built project)

The following compiled with **zero diagnostics** after one lemma-name fix:
- `IsConvex (τ : PartialHistory F)`, `IsTotal.isConvex`, and `isConvex_timeShift` via
  `add_le_add_left`.
- `ofTotal : (f : D → W) → (∀ s t, TaskRel (f s) (t-s) (f t)) → PartialHistory F`.
- `isTotal_timeShift` over `PartialHistory.timeShift`.
- `HF F := {τ : PartialHistory F // τ.IsTotal}`.
- A full copy of `TruthAt` over `PartialHistory F`, with the box clause
  `∀ σ : PartialHistory F, σ.IsTotal → TruthAt M σ t φ`. The recursion is accepted unchanged.
- The `thm:extension` conclusion `∃ σ : HF F, Extends σ.val τ`, closed directly by
  `⟨⟨μ, htot⟩, le_def.mp hle⟩` with no promotion.

### Recommendations

**Target shape of the history layer.** `PartialHistory.lean` absorbs the whole non-order API
and `ConvexHistory.lean` is deleted:

1. `structure PartialHistory` stays as it is.
2. Predicates: `IsTotal` (the only one), `IsConvex` (new, paper fidelity only), `Extends`.
3. Constructors: `ofLe`, `ofTotal`, plus `ofTotal_domain`/`ofTotal_states` simp lemmas and
   `ofTotal_isTotal`.
4. Transport: move `timeShift`, `timeShift_domain` and `states_eq_of_time_eq` here from
   `PartialHistoryOrder.lean`, since they are not order-theoretic. Add `isTotal_timeShift`
   and `isConvex_timeShift`.
5. `total_nonempty`/`nonempty_of_total` keep one copy.
6. `TaskFrame.HF := {τ : PartialHistory F // τ.IsTotal}`, `HF.ofTotal`, `HF.timeShift`,
   `FrameOver.HF`. Optionally add `HF.state τ t := τ.val.states t (τ.property t)` as a
   convenience.
7. `PartialHistoryOrder.lean` keeps only the preorder, the order-related shift lemmas, `chainSup`,
   Zorn and `isMax_of_total`.
8. `IntTransfer.lean`: rename `ConvexHistory.map`/`comap` to `PartialHistory.map`/`comap` and
   drop the `convex :=` blocks.
9. `Extension.lean`: delete `total_isConvex`, `toConvexHistory`,
   `toConvexHistory_toPartialHistory` and `isTotal_toConvexHistory`, and restate `extension`
   without promotion. `Extends σ.val.toPartialHistory τ` becomes `Extends σ.val τ`, which also
   affects `PeriodicExtension.lean` and `BiLasso/Agreement.lean`.
10. Delete the dead declarations: `universal`, `universalTrivialFrame`, `universalNatFrame`,
    `stateAt`, and `timeShift_congr` (its 3 uses can be replaced by `congrArg`/`subst`, or
    moved to `PartialHistory` if still wanted). Keep `trivial` (tests use it) as
    `PartialHistory.trivial`.
11. Choose one signature for `states_eq_of_time_eq`. The explicit-times form is used at 10
    sites and the implicit form at 1 site, so keeping **explicit** times means the fewest edits.

**Mechanical migration (in dependency order, one green build per phase):**
- Phase A: core `Semantics/` history files, Extension, IntTransfer, Truth, TruthTransport,
  TruthClauses, Validity and ValidityLayer.
- Phase B: the Plus/Minus/Star languages, Correspondence, and the rest of `Semantics/`.
- Phase C: `Metalogic/` and `Automation/`, including the 6 `change ConvexHistory.mk
  (PartialHistory.mk …) _` sites, which become `change PartialHistory.mk _ _ _ _ = …`, and the
  17 `convex :=` lines, which are deleted.
- Phase D: `Examples/` and `Tests/`.
- Phase E: docs. That covers `docs/**` (about 30 files), module docstrings, and
  `docs/architecture/total-history-validity-decisions.md`: record that Decision B's "`extends`"
  sub-decision is superseded and that convexity is now a predicate. It also covers the
  `DiscreteNonCompactness.lean` and `TaskFrame.lean` docstrings that cite the deleted
  `universalNatFrame`.
- Phase F: the talk slide.

A `sed`-level rename of `ConvexHistory F` to `PartialHistory F` covers most sites. The residual
hand edits are the `convex :=` deletions, the `.toPartialHistory` projections, the qualified
`ConvexHistory.<lemma>` names, and the `mk` patterns.

**Slide update** (`talks/57_possible_worlds_tense_modal/slides.md`, "Semantics in Lean II:
Histories and Models", lines ~1556-1630; also lines 1673, 1741 and 1836):
- Replace the `ConvexHistory` block with `def IsTotal (τ : PartialHistory F) : Prop := ∀ t, τ.domain t`.
- Change `TaskFrame.HF` to `{τ : PartialHistory F // τ.IsTotal}`.
- Retarget the `TruthAt` signature and box clause to `PartialHistory F`.
- Change the gloss to "**World history**: a partial history with X = D".
- Optionally mention `IsConvex` as a one-line predicate if the convex tier is still wanted on the slide.

A sorry-free path exists. No step introduces a new axiom or new proof obligations; the
obligations removed are exactly the `convex` fields.

## Decisions

- **Delete the `ConvexHistory` structure; do not keep it as a wrapper.** Convexity is never used
  as a hypothesis, so the task's own criterion ("keeping ConvexHistory only where convexity is
  genuinely used") gives zero retained sites.
- **Keep convexity as `PartialHistory.IsConvex` (a `Prop`), not as a structure.** The paper still
  defines the tier (the chess example, and the appendix wording). A predicate costs three lines,
  introduces no second history type, and needs no bridging.
- **Totality is defined exactly once, as `PartialHistory.IsTotal`.** `ConvexHistory.IsTotal` and
  `isTotal_iff` go away.
- **Keep `TaskFrame.HF` as the only name for H_F.** Do not add an `abbrev WorldHistory`, which
  would recreate the naming ambiguity the earlier rename removed.
- **Keep the atom clause's `∃ (ht : τ.domain t)` conjunct in this task.** It is the accepted gap
  in Decision A, and removing it requires the bundled encoding (see below).
- **Considered and rejected: a separate total-function `WorldHistory` type** with
  `states : D → W`. It would give a literal atom clause but reintroduces two history types plus
  a coercion into `PartialHistory` for `Extends`. That contradicts the task's "define totality
  once on PartialHistory".
- **Deferred to the user (non-blocking): full bundling.** This would make `TruthAt` take
  `τ : F.HF`, the box clause `∀ σ : F.HF`, and every validity predicate quantify
  `∀ τ : F.HF`. It removes the unbundled `(τ) (hτ : τ.IsTotal)` pairs, the intro/elim adapters
  in `Validity.lean`/`ValidityLayer.lean`, and the atom-clause gap. However, it overturns
  settled Decision A, touches the proof bodies of ~1330 `TruthAt` lines in 123 files, and would
  also have to rework the statements `TruthCorr`/`IntTransfer`/`timeShift_preserves_truth`
  deliberately make over *arbitrary* histories. Recommended: not in this task; a follow-up if
  wanted.

## Risks & Mitigations

- **Binder-shape drift in `states_eq_of_time_eq`** (explicit vs implicit times). Mitigation: keep
  the explicit form and fix the single implicit call in `PartialHistoryOrder.lean`.
- **Wrong Mathlib lemma direction in `isConvex_timeShift`.** Use `add_le_add_left` (verified).
- **`change ConvexHistory.mk (PartialHistory.mk …) _` goals** in `FlowFrame.lean` and
  `ReynoldsBridge.lean` are syntactic and will fail to elaborate until they are rewritten to
  `PartialHistory.mk _ _ _ _`. These are small, known sites.
- **Name clash on `PartialHistory.map`/`comap`** if `IntTransfer` moves them: grep found no
  existing declarations with those names. Confirm with `lean_local_search` during implementation.
- **Simp-set changes:** `ofTotal_domain`/`ofTotal_states` move namespaces. Keep `@[simp]` so that
  sites like `trivial_truth_iff` in `Decidability/Propositional/Decidable.lean` still close
  by `simp`.
- **Build time / wide blast radius** (~91 files). Mitigation: use the phased order above with a
  detached, guarded `lake build` after each phase, and never leave the tree red between phases
  within a commit.
- **Paper inconsistency** (body says "partial history … total"; appendix says "convex history …
  total"). The Lean result is correct under both. Record it in `docs/reference/paper-definitions-of-record.md`
  as a note, and do not edit the paper from this repository.
- **Doc-lint surfaces:** `check-paper-definitions.sh` already FAILs on 16 unrelated anchors, so
  do not treat that failure as caused by this refactor. The task-reference lint applies to
  docstring edits: do not cite task numbers.

## Tactic Survey Results

| Goal | Tactic | Result | Premises/Config |
|------|--------|--------|-----------------|
| `IsConvex (τ.timeShift Δ)` | term with `add_le_add_right` | fail (wrong side: `Δ + x ≤ Δ + y`) | N/A |
| `IsConvex (τ.timeShift Δ)` | term with `add_le_add_left` | success | `add_le_add_left hxy Δ` |
| `(τ.timeShift Δ).IsTotal` | term `fun t => h (t + Δ)` | success | definitional |
| `IsTotal → IsConvex` | term `fun _ _ _ _ y _ _ => h y` | success | none |
| `∃ σ : HF F, Extends σ.val τ` from maximal total `μ` | anonymous constructor | success | `PartialHistory.le_def` |
| `TruthAt` over `PartialHistory` with box over `IsTotal` | structural recursion | success (compiles) | none |

## Context Extension Recommendations

- **Topic**: History-layer encoding after convexity demotion
- **Gap**: `docs/architecture/total-history-validity-decisions.md` Decision B still prescribes
  `extends` layering and names `WorldHistory`/`ConvexHistory` as structures.
- **Recommendation**: Add a superseding note (Decision B') in that record: convexity is a
  predicate, H_F is a subtype of `PartialHistory`, and the rationale is that no proof uses
  convexity.

## Appendix

- Searches: grep for `\.convex\b`, `convex :=`, `domain :=`, `: ConvexHistory`,
  `ConvexHistory\.<lemma>`, `toPartialHistory`, `ConvexHistory.mk`, `TruthAt`, `IsTotal`, and
  the importers of `Semantics.ConvexHistory`. Also grepped the paper for
  `world history|partial history|convex|H_{\F}` and the slides for
  `ConvexHistory|IsTotal|PartialHistory|.HF`.
- MCP: two `lean_run_code` probes (the first failed on `add_le_add_right`; the second passed).
  No rate-limited search tools were needed, since all relevant declarations are local.
- Blocked tools (`lean_diagnostic_messages`, `lean_file_outline`) were not used.
