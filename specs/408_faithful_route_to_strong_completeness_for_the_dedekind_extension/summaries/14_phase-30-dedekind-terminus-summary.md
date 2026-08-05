# Phase 30 — Reynolds §9 Theorem 7: the engine and the unconditional terminus

**Status**: [COMPLETED]. This is the plan's terminal phase; all 34 phase headings of
`plans/10_strong-completeness-dedekind-v10.md` now carry `[COMPLETED]` except the marker-less
`Phase 14.2 (original charter)` record, which is retained provenance and never was live work.

## What landed

| Declaration | File | Role |
|---|---|---|
| `realFlowPoint` / `realFlowPoint_val` | `BXCanonical/CompletenessDedekind.lean` | The point of an `IsRealFlow` interval structure at a given real; the dense counterpart of `toCarrier` (`ReynoldsBridge.lean:663`), total because `IsRealFlow` is `carrierSet = Set.univ` |
| `chronicle_eval_family_zero_eq_root` | same | **Root placement**, landed as a named lemma per the phase's explicit instruction: `cantorBfmcsDense`'s evaluation family takes the value `A` at time `0` |
| `chronicleMonadic_box_interp_iff` | same | The box predicate on the chronicle bridge is the box content of the root MCS, at every rational point |
| `chronicle_mem_of_box_mem` | same | Modal T along the chronicle flow |
| `countermodel_dedekind_dense` | same | **Reynolds §9 Theorem 7's countermodel, on `ℝ`** |
| `completeness_dedekind_engine` | same | The single-formula completeness engine for `ValidDedekindDense` |
| `consequence_completeness_dedekind` | `Metalogic/StrongCompleteness.lean` | The pinned `_of_engine` form, instantiated. Unconditional |
| `completeness_dedekind` | same | Weak completeness, as `consequence_completeness_dedekind []` |

Tracking table updated in `FormalSystem/Metalogic.lean` (publication-ready results, completeness
architecture, key components, axiom dependencies).

## The construction

The statement of `countermodel_dedekind_dense` follows `countermodel_dense_enriched`
(`Completeness.lean:133`) with `Rat → ℝ`, adding only `hfc : FrameClass.Dedekind ≤ fc`. The
*proof* follows `countermodel_discrete_reynolds_v2` (`ReynoldsBridge.lean:739`), because the
`ℝ` structure is produced by Doets' theorem per box-equivalence class, which forces the
multi-family shape:

1. `FamIdx` = box-equivalence classes of `fc`-MCSs containing `□(¬U(⊤,⊥))`.
2. Per family, `chronicleMonadicStructure` over `ℚ` (Reynolds' step 2, the finite language).
3. Per family, `chronicleRealFlow` at `k := operatorDepth φ + 2` — Doets' theorem at the
   chronicle bridge, landed by the previous dispatch.
4. The whole assembled into `multiFamTaskFrameGen ℝ FamIdx` with `multiFamOmegaGen ℝ FamIdx`
   shift-closed; box quantification over `Omega` ranges over every family at every offset,
   which is what makes the modal dimension come out right.
5. The truth correspondence between `TruthAt` on the task model and `TemporalTruth` on the
   `ℝ`-flowed structure, by induction on the formula, carrying `subformulaClosure` membership.

Three things differ from the `ℤ` original beyond the carrier, and all three are simplifications
or forced adaptations rather than weakenings:

- The per-family monadic structure is the chronicle bridge, so the truth correspondence is
  `chronicleMonadic_truth_correspondence_eval` directly, rather than the
  `limitdomEffectiveFormula` route.
- The interval-carrier bookkeeping collapses: `IsRealFlow` says the carrier set is *all* of
  `ℝ`, so there are no `lo`/`hi` bounds to eliminate (the `ℤ` version needs
  `z_interval_carrier_contains_all` plus two `by_contra` arguments for this).
- The induction carries `subformulaClosure` membership rather than a `predFormulas` inclusion,
  which is what the chronicle correspondence is stated against.

## Verification

- **Full `lake build` green**: 2332 jobs. The job count rose from the 1983 recorded at dispatch
  entry because `ChronicleRealFlow.lean` is no longer a leaf outside the root's reach —
  `CompletenessDedekind.lean` now imports it, so the whole `RealModel/` and
  `DenseModelSurgery/` closure is reachable from `FormalSystem.lean`. This satisfies the
  CI-edge intactness gate rather than violating anything.
- **Sorry census**: `grep -rnE "^\s*sorry\s*$|:= sorry|by sorry|exact sorry" FormalSystem/
  --include=*.lean | grep -v Boneyard` returns exactly
  `FormalSystem/Metalogic/WeakCanonical/Transfer.lean:1242` — the pre-existing, unrelated live
  sorry. Unchanged. The two out-of-territory sorries at
  `Decidability/Verified/Bridge/IntTruth.lean:434,444` recorded in the plan did **not** surface
  in this dispatch's census run; either way they are not this task's to count.
- **`#print axioms`, every new declaration**: `realFlowPoint`,
  `chronicle_eval_family_zero_eq_root`, `chronicleMonadic_box_interp_iff`,
  `chronicle_mem_of_box_mem`, `countermodel_dedekind_dense`, `completeness_dedekind_engine`,
  `consequence_completeness_dedekind`, `completeness_dedekind` — all exactly
  `[propext, Classical.choice, Quot.sound]`. No `sorryAx`.
- **Regression canaries unchanged**: `completeness_dense`, `completeness_discrete`,
  `countermodel_discrete_reynolds_v2` — all still exactly
  `[propext, Classical.choice, Quot.sound]`.
- **Frozen files byte-identical**: `git diff` over `ChronicleTypes.lean`,
  `ChronicleToCountermodelBasic.lean`, `ChronicleConstruction.lean` and `ReynoldsBridge.lean`
  is empty. The `ℤ` originals at `ReynoldsBridge.lean:671,694,708` are untouched.
- **Territory respected**: nothing under `Metalogic/Decidability/` or `Automation/` was read for
  edit, modified, or staged.
- **New axioms**: none. `grep -rn "^axiom " FormalSystem/` returns two hits, both prose inside
  Boneyard docstrings, both pre-existing.
- **No vacuous definitions**: the single grep hit
  (`Examples/TemporalStructures.lean:279`, `intTimeHistory.domain t := trivial`) is
  pre-existing and is a genuinely total domain, not a placeholder. Anti-vacuity for this
  phase: `hfc` is inhabited (`by decide` at `fc := FrameClass.Dedekind`, used by the engine),
  and `SemanticConsequenceDedekindDense` is inhabited for every derivable pair by
  `soundness_dedekind_consequence`.
- **Pinned signatures**: `consequence_completeness_dedekind_of_engine` and
  `completeness_dedekind_of_engine` are unmodified — the new theorems are their instances. The
  four `StrongCompleteness.lean` records about what strong completeness is, why it is refuted
  for this class, and why it is not expressible in this tree are untouched and unweakened.

## Deviations

Three, all recorded inline in the plan:

1. **The table `α(t)` supplier is neither of the two options the task offered.** It is the plain
   `table` / `table_correctness` / `table_depth_bound` layer (`WeakCanonical/Table.lean`),
   already consumed by the `ℤ` route — not `tableMu` / `staviFoDepth`, which is the
   μ-relativized variant belonging to the Stavi development and is not on this path. Recorded
   in the new §9 section header of `CompletenessDedekind.lean`.
2. **`k := operatorDepth φ + 2`**, two greater than the depth rather than one. The extra `+1`
   makes Doets' theorem's standing `2 ≤ k` hold with no side condition, and it matches the `ℤ`
   original's own `k` exactly.
3. **Statement vs. proof provenance** of `countermodel_dedekind_dense`, as described above.

One page-discipline record, not a deviation: the two printed-page citations (§9 Theorem 7,
p.189; §2, p.169) are **carried** from the plan and from Phases 15 and 24-29. Neither was
re-measured against the page image in this dispatch. Flagged per the Block F gate.

## What this does and does not establish

Weak completeness and finite-context consequence completeness for `FrameClass.Dedekind`,
against `ValidDedekindDense`, on the real line. It is **not** strong completeness and the
charter on that point is unchanged: `Context := List Formula`, so the finite-context form is
inter-derivable with the weak form through the deduction theorem; the infinitary statement is
*refuted* for this class by non-compactness, not merely unproved; and it is not expressible in
this tree without a set-based derivability relation no declaration here defines. Those three
facts live in `StrongCompleteness.lean`'s docstrings and were not touched.
