# Research Report: Task #568

**Task**: 568 - C3/C4 consequence relations as library definitions
**Started**: 2026-09-18T19:19:03Z
**Completed**: 2026-09-18T19:40:00Z
**Effort**: L (4-5 implementation phases)
**Dependencies**: None
**Sources/Inputs**: - Codebase (`Semantics/PartialHistory.lean`, `Semantics/Truth.lean`, `Semantics/Validity.lean`, `Semantics/FrameProperty.lean`, `Semantics/FrameClassValidity.lean`, `Semantics/Extension/Extension.lean`, `ProofSystem/Axioms.lean`, `Metalogic/Soundness.lean`, `Metalogic/SoundnessLemmas/Separability.lean`, `Metalogic/SoundnessLemmas/FrameClassVariants.lean`); archived task 553 probes 02/03 and report 01 (`specs/archive/553_decide_convex_history_layer_collapse/`); the JPL paper `possible_worlds.tex` (C3 footnote); lean-lsp MCP (`lean_run_code`, `lean_goal`, `lean_verify`). No `lake build` was run (user constraint).
**Artifacts**: - specs/568_c3_c4_consequence_relations_as_library_definitions/reports/01_c3-c4-library-definitions.md
- specs/568_c3_c4_consequence_relations_as_library_definitions/probes/01_gap-closures.lean
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **All four open verdicts are now closed, and all four go the same way: each axiom SURVIVES,
  machine-checked.** The proofs are in `probes/01_gap-closures.lean`. They were compiled against
  the live tree through the LSP, and `lean_verify` reports only `propext` / `Classical.choice` /
  `Quot.sound`, with no `sorryAx`.
  - `discrete_propagate_bwd` (NA) survives on **every** frame, not only on ℤ-interval indices.
  - `z1` survives on every ZTime frame.
  - `prior_U_gap` survives on every **Complete** frame, and density is not needed.
  - `sep` survives on every RTime frame, and the proof reuses `SoundnessLemmas.sep_order`
    unchanged.
- **The endpoint behaviour of `K⁺` is harmless.** At the right endpoint of `dom τ`, `K⁺ψ` is
  vacuously TRUE, because there is no domain witness for the `untl` inside it. So `K⁺` can only
  make the Reynolds consequents easier to satisfy.
- **C3 ≠ C4, and this is a new result.** Task 553 §7.4(1) left the question open. The formula
  `F⊤ → F G⊥` ("if a later time exists, a last time exists") is C4-valid on every frame and is
  not C3-valid (`validC4_lastPoint`, `refute_C3_lastPoint`). So the containment
  `ValidC3 → ValidC4` is **strict**.
- **The tree has moved since the 553 probes, so they cannot be copied verbatim.**
  - `ConvexHistory` no longer exists. The index type is now `PartialHistory F` plus the
    `IsConvex` predicate.
  - `TruthAt` is now indexed by `WorldHistory F`, the total histories. So C2 cannot be stated
    with the library's `TruthAt` any more, which is good for a diagnostic-only relation.
  - `Axiom` has 29 constructors, not 45: past mirrors and modal 4/B are now derived.
  - `serial_future` is now `F⊤` rather than `⊤ → F⊤`.
- **Recommended approach.**
  - A new `Semantics/ConvexTruth.lean`: the definitions, the clause lemmas, the germ theorems and
    shift invariance, with no `Metalogic` imports.
  - A new `Metalogic/ConvexConsequence/` cluster: the separations, the survival table, and the
    frame-class gap closures. This cluster needs `SoundnessLemmas.Separability`.
  - The survival table is indexed by the **29 current constructors**, plus the historical 553
    mirror rows as named extra theorems.
  - A sorry-free path exists for every deliverable.

## Context & Scope

The task asks to promote the C3 and C4 definitions from probes 02 and 03 into the library, and to
turn the §4.1 survival table into theorems, with no semantic change to C1.

Scope of this research:
- The API drift between the probe code and the live tree.
- Closing the four gaps.
- Where the new modules should live in the layering.
- The design choices a plan must fix.

User constraint: no `lake build` and no `lean_build`. Every Lean fact below was checked with
`lean_run_code`, with `lean_goal` on the probe file, or with `lean_verify`.

## Findings

### Codebase Patterns

**1. The history layer was retargeted after task 553.** `Semantics/PartialHistory.lean` now has:
- `structure PartialHistory F`, with fields `domain`, `nonempty_domain`, `states` and an
  unconditional `respects_task`. It has **no convexity field**.
- `PartialHistory.IsConvex`, as a predicate.
- `PartialHistory.IsTotal`.
- `PartialHistory.timeShift`, with `timeShift_domain` and `isConvex_timeShift`.
- `PartialHistory.ofTotal`, with `ofTotal_isTotal` and `IsTotal.isConvex`.
- `WorldHistory F := {τ : PartialHistory F // τ.IsTotal}`, which is `H_F`.

The module docstring states: *"There is deliberately no `ConvexHistory` structure: no proof
consumes convexity as a hypothesis."* C3 is the first genuine consumer of convexity. The gap
proofs for NA, Z1, Prior-U and Sep all use `IsConvex`, as does the germ's convexity, so this
sentence must be amended when C3 lands. That is a documentation change, not a semantic one.

**2. `TruthAt` (`Semantics/Truth.lean`) is now indexed by `WorldHistory F`.** Its box clause
quantifies over `WorldHistory F`, and the atom clause reads `τ.state t`. Consequences:
- **C1** is `TaskFrame.ValidOn F φ`, or `ValidIn fc φ` at class level.
- The probe's `ValidC1` should be dropped in favour of `F.ValidOn`.
- `valid_C1_someFuture_top` is now `NF.ValidOn (Formula.someFuture Formula.top)`. This is
  verified, and the proof term is unchanged.
- **C2 is no longer expressible** with the library `TruthAt`, because the index type forbids a
  non-total index. C2 should therefore be recorded in a docstring as retired by the type, not as a
  definition. That fits the task's "diagnostic only" instruction exactly.

**3. The abstract clause layer does not fit C3.** `TruthClauses.lean`'s `TruthEnv` / `UntlClauses`
fix `T : TaskModel F → WorldHistory F → …`. C3's index is `PartialHistory F`, so `TruthAtConvex`
cannot instantiate that layer. It needs its own small set of clause lemmas, all proved and listed
under Recommendations: `and_iff`, `someFuture_iff`, `allFuture_iff`, `kPlus_iff`, `kMinus_iff`,
plus the past duals.

**4. The germ already exists in the library.** `PartialHistory.point F w x`
(`Semantics/Extension/Extension.lean`) is exactly the probe's `pointHist`. The missing piece is a
`point_isConvex` lemma: a four-line `subst` plus `le_antisymm`, verified. Two consequences:
- Importing `Extension.lean` into the C3 module is layering-safe. It sits below `Truth.lean`'s
  consumers, and `Semantics.lean` already aggregates it.
- The germ theorems then reuse the library's `point` rather than defining a second one-point
  history.

**5. The `Axiom` inductive (`ProofSystem/Axioms.lean`) has changed.** It now has **29**
constructors:
- 4 propositional;
- 3 S5 (MT, M5, MK);
- 11 BX, future direction only;
- 1 interaction (MF);
- 4 uniformity (NP, NF, NA, NB);
- `prior_UZ`, `z1`, `density`, `dense_indicator`, `prior_U_gap`, `sep`.

What moved:
- Past mirrors, `modal_4` and `modal_b` are now derived. The mirrors come from the time-reflection
  rule TR, in `DerivedAxioms`.
- `prior_S_gap` is now `DerivedAxioms.priorSGap`, not a constructor.
- `serial_future` is `F⊤`. The old `⊤ → F⊤` is `DerivedAxioms.serialFutureImp`.
- `Axiom.minFrameClass` gives each constructor's frame class.

Impact on the table:
- The 553 table's 45 rows no longer match the constructor set.
- Of the six machine-checked failures, `serial_past` and `discrete_symm_bwd` are **no longer
  constructors**. They are TR mirrors, and they should still be delivered as named C3 refutations
  of those formulas.

**6. There is no semantic TR-soundness to reuse for C3.** The library proves TR sound
constructor by constructor through `*_reflect_time_valid` companions, not by reflecting models.
The reason: time-reflecting a history needs the converse task relation, which a single frame does
not supply. The same holds for C3. So a C3 verdict on a derived mirror is **not** inherited from
the forward verdict; each mirror row needs its own theorem. This is also why "the logic of C3" is
not settled by the table, which fits the task's instruction to leave completeness to the sequel.

**7. Frame classes, and how to consume them.** `FrameClass.Sat` (`Semantics/FrameClassValidity.lean`,
reducible) maps:
- `.Dense` to `DenselyOrdered`;
- `.ZTime` to `IsZTime`, an existential over `SuccOrder` / `PredOrder` / the two Archimedean
  instances;
- `.RTime` to `IsDense ∧ IsComplete`.

`IsComplete` is the explicit LUB hypothesis `∀ s, s.Nonempty → BddAbove s → ∃ x, IsLUB s x`
(`Semantics/FrameProperty.lean`). The verified gap proofs take `(hZ : F.IsZTime)`,
`(hc : F.IsComplete)` and `(hR : F.IsRTime)` as explicit per-frame hypotheses, destructured by
`obtain`. A class-level `ValidC3In fc φ := ∀ F, fc.Sat F → ValidC3 F φ`, mirroring `ValidIn`, then
wraps them. The `sat_intro` macro also works.

### External Resources

- **`SoundnessLemmas.sep_order`** (`Metalogic/SoundnessLemmas/Separability.lean`). This is a pure
  order lemma over a `Set D`, with no formulas in it. Its three hypotheses (`hK`, `hNoStart`,
  `hNoTwo`) refer only to points in `(t, min s₁ s₂)`. Under C3, `t`, `s₁` and `s₂` are domain
  points, so convexity puts that whole window inside `dom τ`. This is why Sep transfers with **no
  new order theory**.
- **`SoundnessLemmas.exists_countable_order_dense`** supplies the countable dense `Q` from RTime's
  hypotheses.
- **Mathlib**:
  - `IsPredArchimedean.exists_pred_iterate_of_le`, `Order.le_of_pred_lt`, `Order.pred_le`,
    `Order.pred_iterate_le` and `Function.iterate_succ_apply'` (for Z1);
  - `IsLUB.exists_between` (for Prior-U);
  - `sub_lt_iff_lt_add'` and `lt_sub_iff_add_lt'` (for NA; `linarith` is unavailable in an
    ordered group without further imports).
- **Paper (the C3 definition of record).** `JPL/possible_worlds.tex`, in the footnote that begins
  "Alternatively, one might evaluate sentences at any convex history τ together with a time
  x ∈ dom τ, taking □ to quantify over all convex histories σ where x ∈ dom σ, restricting Past and
  Future to the times in dom τ, and adapting logical consequence to replace D with dom τ." It sits
  at **line 1106 now, not 1102**; the line drifted. The follow-on sentence about `F⊤` failing is
  commented out.
  - The footnote is **not** pinned in `docs/reference/paper-definitions-of-record.md`. Repository
    convention cites that file and never paper line numbers.
  - So docstrings should quote the footnote rather than cite a line. The plan should consider
    pinning the footnote in the definitions-of-record file.

### Recommendations

**R1. Definitions: new module `FormalSystem/Semantics/ConvexTruth.lean`.** It imports
`Semantics.Truth`, `Semantics.Extension.Extension` and `Semantics.FrameProperty`.

The core recursion, verified to elaborate:
```lean
def TruthAtConvex (M : TaskModel F) (τ : PartialHistory F) (t : F.Duration) : Formula → Prop
  | .atom p => ∃ ht : τ.domain t, M.valuation (τ.states t ht) p
  | .bot => False
  | .imp φ ψ => TruthAtConvex M τ t φ → TruthAtConvex M τ t ψ
  | .box φ => ∀ σ : PartialHistory F, σ.IsConvex → σ.domain t → TruthAtConvex M σ t φ
  | .untl ψ φ => ∃ s, τ.domain s ∧ t < s ∧ TruthAtConvex M τ s φ ∧
      ∀ r, τ.domain r → t < r → r < s → TruthAtConvex M τ r ψ
  | .snce ψ φ => ∃ s, τ.domain s ∧ s < t ∧ TruthAtConvex M τ s φ ∧
      ∀ r, τ.domain r → s < r → r < t → TruthAtConvex M τ r ψ
def ValidC3 (F) (φ) := ∀ M (τ : PartialHistory F), τ.IsConvex → ∀ x, τ.domain x → TruthAtConvex M τ x φ
def IsInterval (τ : PartialHistory F) := ∃ a b, ∀ t, τ.domain t ↔ (a ≤ t ∧ t ≤ b)
def ValidC4 (F) (φ) := ∀ M τ, IsInterval τ → ∀ x, τ.domain x → TruthAtConvex M τ x φ
```

Everything else in this module:
- **Class-level wrappers**: `ValidC3In fc` and `ValidC4In fc`, plus `ConsequenceC3` /
  `ConsequenceC4` with a finite context. The footnote adapts *consequence*, not only validity, and
  C1's own consequence is `ConsequenceOnFrames`.
- **Interval lemma**: `IsInterval.isConvex`, so that `validC3_imp_validC4` needs no convexity
  hypothesis on the C4 side.
- **Clause lemmas**: the `*_iff` lemmas.
- **The C3 box is index-independent**: `truthC3_box_indep` holds by `rfl`.
- **Germs**: `point_isConvex`, `germ_untl_false`, `germ_snce_false`, `c3_box_untl_unsat`,
  `c3_box_snce_unsat`, `c3_nec` and `c3_valid_imp_germ_valid`. These use the library's
  `PartialHistory.point` and `F.worldNonempty.some`.
- **Shift invariance**: `truthC3_timeShift`. This is the probe proof with
  `PartialHistory.isConvex_timeShift` threaded through the box case (the box step is verified as
  `truthC3_timeShift_box`); the `untl`/`snce` cases port as they are. From it,
  `c3_box_time_uniform`.

Docstrings must carry the task's "what C3 is" framing. They must **not** claim that C3 equals
BX-without-seriality plus S5.

**R2. Separations: `Metalogic/ConvexConsequence/Separations.lean`, or under `Semantics/` since
these need no Metalogic.**
- `valid_C1_someFuture_top`, stated as `NF.ValidOn`.
- `refute_C3_someFuture_top`, `refute_C3_somePast_top` and `refute_C4_someFuture_top`, over
  `NF := FrameOver.natFrame (D := ℤ)`, with `bdd : PartialHistory NF` and `bdd_isConvex`.
  - Changed API: `respects_task` is now discharged by
    `(FrameOver.natFrame_rel_iff _ _ _).mpr (Or.inr rfl)`. The old `left`/`right` fails because
    `natFrame` is now built by `ofReflective`.
- **New**: `validC4_lastPoint` and `refute_C3_lastPoint`, which make C3 ⊊ C4 strict.

**R3. Survival table: `Metalogic/ConvexConsequence/AxiomSurvival.lean`.** Index it by the **29
current constructors**. One theorem per surviving constructor, at `ValidC3In ax.minFrameClass`.
Plus named refutations of `serial_future` (now `F⊤`, so the same content as
`refute_C3_someFuture_top`), `discrete_symm_fwd`, `discrete_propagate_fwd` and
`discrete_box_necessity`.

An aggregate is optional and easy once the per-row theorems exist. It could be
`c3_axiom_survives : Axiom φ → (not one of the 4 failing constructors) → ValidC3In ax.minFrameClass φ`,
proved by `cases`, with the failing constructors listed.

A separate "historical 553 rows" block: `refute_C3_serial_past`, `refute_C3_discrete_symm_bwd`,
`c3_modal_4`, `c3_modal_b`, `c3_prior_S_gap`, plus past mirrors as the plan chooses. Keep the
names of the six failures listed in the task.

**R4. The four gaps, as checked in `probes/01_gap-closures.lean`.**

| Axiom | Class used | Verdict | Key idea |
|---|---|---|---|
| `discrete_propagate_bwd` (NA, `X⊤ → H X⊤`) | any frame | **SURVIVES** | if `s` is the next domain point after `x`, then `s - x` is the least positive duration. For `y < x` in the domain, `y + (s - x) ≤ x`, so it lies in the domain by convexity, and `(y, y+(s-x))` is empty by translating into `(x, s)`. The asymmetry with NF is exact: `H` only looks left of `x`, and `x` itself bounds every successor it needs. |
| `z1` | ZTime | **SURVIVES** | backward induction along `Order.pred^[n] s0`, where each step stays inside `(x, s0] ⊆ dom τ`. Points above `s0` are covered by `Gφ(s0)`. A vacuous `G` at the right endpoint only helps. |
| `prior_U_gap` | Complete (LUB) | **SURVIVES** | the sup is taken of `A := {u | t < u ≤ v ∧ φ on (t,u)}`, capped at the `¬φ` witness `v ∈ dom`, so the sup lands in the domain. `K⁺¬φ` failing at `s` hands back a domain witness `w`, and `min w v ∈ A` contradicts the sup. The endpoint case is vacuous and favourable. |
| `sep` | RTime | **SURVIVES** | take `P := {u | u ∈ dom τ ∧ φ(u)}` and apply `sep_order` directly. `hK` is obtained via `min v s₁`, and `hNoStart` / `hNoTwo` are read off the negated `K⁺` clauses through `kPlus_iff` / `kMinus_iff`. If the consequent fails, the witness `s₂` is itself in the domain, so no endpoint case arises. |

The mirror `prior_S_gap` should be proved the same way, dually: GLB via
`SoundnessLemmas.exists_isGLB_of_lub`, and the set capped below at the `¬φ` witness. It is
expected to be about 45 lines and was not machine-checked here. The Sep mirror via
`sep_order_mirror` is analogous.

**The table after this task.** Against the 553 table's rows:
- **4 FAILS** that are still constructors: `serial_future`, `discrete_symm_fwd`,
  `discrete_propagate_fwd`, `discrete_box_necessity`.
- **2 FAILS** that are now TR mirrors: `serial_past`, `discrete_symm_bwd`.
- **Everything else SURVIVES.**

So under C3 no axiom's status is left open: the complete list of failures is the six
existence-assertions.

**R5. Box-range design choice (working default kept).** The primary C3 is the footnote's reading:
convex `σ` with `x ∈ dom σ`, germs included. For the **named alternative**, define
`TruthAtConvexCut` with the box ranging over the convex `σ` whose domain contains `dom τ`.

Two warnings for whoever implements it:
- The alternative is **index-dependent**. `truthC3_box_indep` fails for it, and modal 5 becomes
  doubtful. The survival table would have to be redone for it.
- The "minimum-length interval" variant needs a length parameter on arbitrary `D`. That is only
  natural on ℤ or ℝ.

Recommendation: define only the `dom τ ⊆ dom σ` alternative, as a definition with at most a
contrast theorem, for example "`□F⊤` is satisfiable under the cut variant at a total index". Do
not run a second survival table in this task. Record the default choice in the module docstring.

**R6. Phasing.** Each phase must leave `lake build FormalSystem` green.
1. `Semantics/ConvexTruth.lean`: the definitions, clause lemmas, germs, `c3_nec`,
   `truthC3_timeShift`, `c3_box_time_uniform` and `validC3_imp_validC4`. Also the aggregator
   import, the README row, and the `PartialHistory.lean` docstring amendment.
2. The separations, including C3 ⊊ C4.
3. The survival rows for the 23 base constructors: propositional, S5, BX, MF and uniformity. This
   includes the NA gap closure and the four failing constructors.
4. The frame-class rows: `prior_UZ`, `z1`, `density`, `dense_indicator`, `prior_U_gap` and `sep`,
   with the mirrors `prior_S_gap` and Sep⁻, and the historical-row block.
5. Optional: the aggregate theorem, the cut-variant definition, and tests in
   `Tests/BimodalTest/`.

## Decisions

- C3's index is `τ : PartialHistory F` with an explicit `τ.IsConvex` hypothesis. It is not a new
  `ConvexHistory` subtype. This follows the repository's recorded "convexity is a predicate"
  decision (Decision B').
- The box clause carries `σ.IsConvex →`, following the footnote ("all convex histories σ").
- C2 is not re-defined. It is documented as unexpressible now that `TruthAt` is indexed by
  `WorldHistory`.
- The survival table is indexed by the current 29 constructors. The 553-era rows are kept as named
  extras.
- C1 is not touched. Every new definition sits beside `TruthAt`.

## Risks & Mitigations

- **Risk: the probe file was checked only through the LSP (`lean_run_code`, `lean_verify`), not
  `lake build`.** Mitigation: phase 1 runs the guarded scoped build first. Style linters (task 597
  is adopting the Mathlib linter set) may flag `open scoped Classical`, `push_neg`, or long lines.
  The probe already avoids the first two.
- **Risk: `truthC3_timeShift`'s `untl`/`snce` cases were not re-run against the current tree.**
  Only the box case was. The arithmetic lemmas used (`sub_add_cancel`, `add_lt_add_of_lt_of_le`,
  `lt_of_add_lt_add_right`) are stable in Mathlib, so a port failure would be cosmetic.
- **Risk: import layering.** Survival rows need `Metalogic.SoundnessLemmas.Separability`, so they
  must live under `Metalogic/`. The definitions must not import Metalogic.
- **Risk: the task-reference lint.** Docstrings must not cite "task 553/568". Cite probe content
  by theorem name, and the paper by quoted footnote text.
- **Risk: the `pin_definitions_of_record` convention.** The C3 footnote is unpinned. The plan
  should include pinning it, or explicitly defer that.

## Tactic Survey Results

| Goal | Tactic | Result | Premises/Config |
|------|--------|--------|-----------------|
| `and_iff` for C3 | `show …; tauto` | success | unfold `Formula.and` to `(_ → (_ → False)) → False` |
| NA ordered-group inequalities | `linarith` | fail (no ordered-field context) | replaced by `sub_lt_iff_lt_add'` / `lt_sub_iff_add_lt'` |
| NA full proof | term-mode + `rintro` | success | `IsConvex` applied at three sites |
| Z1 iteration | `induction n` + `Function.iterate_succ_apply'` | success | `Order.le_of_pred_lt`, `IsPredArchimedean.exists_pred_iterate_of_le` |
| Prior-U sup step | `IsLUB.exists_between` | success | `F.IsComplete` applied to a set capped at `v` |
| Sep | `refine sep_order …` | success | `exists_countable_order_dense`, `kPlus_iff`, `kMinus_iff`, `push Not` |
| `bdd.respects_task` on `natFrame` | `left`/`right` | fail (no longer an `Or` by defeq) | `(FrameOver.natFrame_rel_iff _ _ _).mpr (Or.inr rfl)` |
| C4 last-point | `rintro` + term | success | `IsInterval` destructuring |

## Context Extension Recommendations

- **Topic**: the alternative (C3/C4) consequence relations.
- **Gap**: `docs/reference/paper-definitions-of-record.md` has no entry for the footnote's
  alternative semantics, and `.claude/context/project/lean4` has nothing on the post-retarget
  `PartialHistory` / `WorldHistory` split.
- **Recommendation**: pin the footnote in the definitions-of-record file. Update the
  total-history decisions doc (Decision B') to name C3 as the first consumer of `IsConvex`.

## Appendix

- The verified probe is
  `specs/568_c3_c4_consequence_relations_as_library_definitions/probes/01_gap-closures.lean`.
  - `lean_verify` output: `c3_sep`, `c3_z1`, `c3_prior_U_gap`, `c3_discrete_propagate_bwd` and
    `refute_C3_lastPoint` show `[propext, Classical.choice, Quot.sound]`. `validC4_lastPoint`
    shows `[propext]` and `truthC3_timeShift_box` shows `[propext, Quot.sound]`.
  - No `sorryAx` anywhere.
- Source probes: `specs/archive/553_decide_convex_history_layer_collapse/probes/02_alternative-consequence.lean`
  and `.../03_axiom-survival.lean`; report §3.1 / §4.1 / §4.2 / §7.4.
- Searches: repository grep only (`lean_local_search` was not needed). The candidate names
  `TruthAtConvex`, `ValidC3`, `ValidC4` and `IsInterval` do not collide with anything in
  `FormalSystem/`, `Tests/` or `docs/`.
