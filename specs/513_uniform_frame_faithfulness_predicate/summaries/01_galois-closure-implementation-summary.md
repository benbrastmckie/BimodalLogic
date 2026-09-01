# Implementation Summary: Galois-closure implementation for the frame-class layer

- **Task**: 513 - Uniform frame faithfulness predicate
- **Plan**: `specs/513_uniform_frame_faithfulness_predicate/plans/01_galois-closure-implementation.md`
- **Type**: lean4
- **Session**: sess_1788282938_f2ac03

## What landed

Seven new Lean modules plus two in-place edits, all sorry-free, axiom-clean, and green under a
full `lake build`.

### `Semantics/Correspondence/` (new directory)

| Module | Content |
|---|---|
| `Galois.lean` | `Th`/`Mod`, `th_anti`/`mod_anti`, both round trips, both triple-composite collapses, `GaloisClosed`, `galoisClosed_mod`, `galoisClosed_of_indicator`, `AxiomSet`, `densitySchema`, and deliverable (6)'s non-goals recorded verbatim in the module docstring |
| `Indicator.lean` | `validOn_neg_nextTop_iff` (IND-D), `validOn_nextTop_iff` (IND-F), `validOn_nextTop_iff_isDiscrete`, and both closure corollaries `galoisClosed_sat_dense` / `galoisClosed_isDiscrete` as single applications of `galoisClosed_of_indicator` |
| `FwdRec.lean` | `TaskFrame.FwdRec` over bundled frames, `validOn_iff_total`, and `validOn_atomic_density_iff_fwdRec` — the atomic correspondence at arbitrary `D` |
| `DurationFrames.lean` | The translation frame and the two-state permissive frame with their histories and models, the `NoMaxOrder`/`SuccOrder` glue, `truth_and_iff`/`truth_always_of_forall`/`truth_of_always`, and the three (T1) biconditionals `validOn_dn_iff_denselyOrdered`, `validOn_df_iff_isDiscrete`, `validOn_co_iff_isComplete`, with the (T0) refutation recorded in the header |
| `FwdRecPeriodicity.lean` | The `Walk`/`MinCyc` apparatus (`IsWalk`, `AllRec`, `per`, `MinCyc`, `exists_minCyc`, `minCyc_mem`, `succ_unique`, `det`, `periodic`), plus `truthAt_add_hist_period` and `density_of_hist_periodic` |
| `FwdRecBridge.lean` | The frame/digraph dictionary at `ℤ` (`step`, `taskRel_diff`, `ofWalk`, `hist_isWalk`), `allRec_of_fwdRec`, `hist_periodic`, `hist_deterministic`, the full-schema exactness `density_schema_iff_fwdRec`, and `mod_densitySchema_int` |

### `Metalogic/Independence/` (new modules)

| Module | Content |
|---|---|
| `StaticFrame.lean` | `staticFrame_looping`, `static_time_invariant`, the four tense-transparency lemmas, the `untl`/`snce` calculus in its general, dense and discrete forms, `static_kPlus_iff_dense`/`static_kMinus_iff_dense`, and `static_validates_z1` |
| `RationalWitness.lean` | `rat_not_complete`, `ratStaticFrame` with its membership and non-membership, and the Dedekind sandwich `sat_dedekind_ssubset_mod_axiomSet` / `mod_axiomSet_dedekind_subset_sat_dense` |
| `LexIntWitness.lean` | The `ℤ ×ₗ ℤ` order facts (`lexInt_isLeast_pos`, `lexInt_isLeast_succ`, `lexInt_isGreatest_pred`, `lexInt_not_archimedean`), `lexIntStaticFrame` with its membership and non-membership, `validOn_nextTop_of_mem_mod_discrete`, and the Discrete sandwich |

### In-place edits

- `Theorems/DiscreteUnfolding.lean` — `succIndicator` generalized to `succIndicatorAt {fc} (h : FrameClass.Discrete ≤ fc)`, with `succIndicator := succIndicatorAt le_rfl` so both existing call sites are untouched; docstrings updated.
- `Theorems.lean`, `Semantics.lean`, `Metalogic/Independence.lean` — aggregator registration and summary lines.

## Verification

- `lake build`: green at a genuine full job count — **2514 jobs**, zero errors, and zero warnings
  attributable to any file this task touched. (A scoped invocation replays as ~1000-1338 jobs;
  the count above is from a `--no-share` full build, which is what the plan's "force a full build
  and confirm the count" step asks for.)
- `lake test`: green, 2564 jobs, zero errors.
- `bash scripts/check-module-invariants.sh`: every check group passes except the pre-existing
  `C6` recorded above. In particular `C1` (build), `C3` (zero structural sorries across
  `FormalSystem/`), `C8` (every subdirectory has exactly one sibling aggregator) and `C14` (axiom
  baselines) all pass.
- Sorry census: zero `sorry`/`admit`/`native_decide` in every new or edited file.
- Axioms: no new `axiom` declaration anywhere; every headline result profiles as
  `[propext, Classical.choice, Quot.sound]` (`galoisClosed_mod` and `galoisClosed_of_indicator`
  need only `[propext, Quot.sound]`). `rat_not_complete` matches the profile the research
  measured.
- Statement hygiene: no declaration named `nextTop`; `Formula.next Formula.top` used throughout.
  The paper-Discrete closure corollary and the Discrete sandwich's upper bound are both over
  `{F | F.IsDiscrete}`, never `Sat .Discrete`. Both sandwiches are over `AxiomSet`; no
  single-frame `swapTemporal` closure lemma was reached for or needed. `ValidDedekind` appears
  nowhere in the new code.

## Reasoned exclusions (pre-existing gate failures, not absorbed)

| Item | Reason | Evidence |
|---|---|---|
| `check-module-invariants.sh` C6 — 4 unreachable live modules absent from the manifest | Pre-existing; all four (`Metalogic.SpWitness`, `Metalogic.TMCompletenessReduction`, `Metalogic.Z1Countermodel`, `Semantics.LexCarrier`) come from earlier tasks. None of this task's seven new modules appears in the list: every one is registered in `Semantics.lean` or `Metalogic/Independence.lean` and is therefore reachable. | Final run at `ae45edf11`: `FAIL C6` names exactly those four; every other check group passes, including `C3` (zero sorries tree-wide) and `C2`/`C14` (flagship axiom baselines unchanged). |
| `readme-lint.sh` check 1 — missing `FormalSystem/Semantics/Ultraproduct/README.md` | Pre-existing, and outside this task's file scope. The *new* check-1 entry this task introduced — `FormalSystem/Semantics/Correspondence/README.md` — was written, and the three new `Independence/` modules were added to that directory's README inventory, so check 2 reports none of this task's files. | `readme-lint.sh` after the README commit reports `Ultraproduct` alone under check 1. |

## Design decisions of record

- **`Mod` is ambiguous with core's `Mod` class outside the `Semantics` namespace.** Consumers in
  `Metalogic/Independence/` write `Semantics.Mod` explicitly. No rename was applied — the plan
  fixes the name `Mod`, and the ambiguity is confined to cross-namespace call sites.
- **The Discrete sandwich's upper bound is semantic and independent of Phase 3.**
  `validOn_nextTop_of_mem_mod_discrete` replays `prior_UZ ⊤` at the `ValidOn` level and closes
  the `⊤.neg`-versus-`⊥` guard gap by observing the two are false everywhere, rather than by
  `Combinators.guardMono`. That independence is deliberate: no proof theory enters the sandwich.

## Optional phases

Phases 10 and 11 were marked OPTIONAL in the plan and both landed. The `Walk`/`MinCyc`
transcription went into `FwdRecPeriodicity.lean` and the `ℤ` bridge into `FwdRecBridge.lean`, so
the module boundary now separates the arbitrary-`D` periodicity layer from the `ℤ`-only one.
Nothing was excluded, so no `#### Reasoned Exclusions` record was needed.

## Plan Deviations

- **Phase 2 verification step, altered.** The plan asks that
  `grep "Sat FrameClass.Discrete\|Sat .Discrete"` on `Indicator.lean` return nothing, but the same
  phase's task list requires the paper-Discrete corollary's docstring to name `Sat .Discrete`
  explicitly as the class it is *not*. The two cannot both hold literally. The check was applied
  to statement position: all four occurrences are in docstrings, and both closure corollaries are
  stated over `FrameClass.Sat FrameClass.Dense` and `{F | F.IsDiscrete}` respectively.
- **Phase 6 non-membership route, altered.** The plan routes the refutation of
  `Sat .Discrete` through `DurationClassification.intIso`. It goes instead through
  `DurationClassification.archimedean_of_succ` — the lemma `intIso` itself consumes, in the same
  file — because converting `intIso`'s `≃+o ℤ` into `Archimedean D` would need an
  Archimedean-transfer-along-`≃+o` lemma that Mathlib does not carry, while `archimedean_of_succ`
  delivers `Archimedean D` from the same two components of the `IsSuccArchDiscrete` existential
  in one step. The route the plan prohibits — refuting the `∃ (_ : SuccOrder D)` existential via
  `Subsingleton (SuccOrder _)` — was not used.
- **Phase 10 placement, altered (permitted by the plan).** The `Walk`/`MinCyc` apparatus went
  into a separate `FwdRecPeriodicity.lean` rather than appended to `FwdRec.lean`; the plan
  explicitly leaves that split to the implementer, and the module is registered in
  `Semantics.lean`. Phase 11's bridge went into a further module `FwdRecBridge.lean`, also
  registered, which keeps the `ℤ`-only layer separate from the arbitrary-`D` one.
- **Phase 11 statement shape, altered.** The plan asks for
  `Mod densitySchema = {F : TaskFrame | F.FwdRec}` "at `ℤ`". It is stated as an equality of
  subsets of the *fibre*, `{F : FrameOver intOrder | F.toTaskFrame ∈ Mod densitySchema} =
  {F : FrameOver intOrder | F.toTaskFrame.FwdRec}`, because the unrestricted equality over
  `Set TaskFrame` is not what was proved and not what is true: `Mod densitySchema` as a set of
  bundled frames also contains frames over other duration groups. The fibre form is the same
  shape phase 8's (T1) biconditionals use, and its docstring says so.
