# Research Report: Task #581

**Task**: 581 - Repair the four wired bi-lasso evidence probes so `check-evidence-probes.sh` exits 0, then wire it into CI
**Started**: 2026-09-16T08:52:11-07:00
**Completed**: 2026-09-16T08:58:00-07:00
**Effort**: Small (Lean repair fully drafted and machine-verified; ~25 changed lines across 4 files) + Small (one CI step)
**Dependencies**: None (task 583 has not yet recorded a wiring pattern; its report 01 supplies the de-facto template)
**Sources/Inputs**: - Codebase (`FormalSystem/Semantics/{TemporalOrder,TaskFrame,IntNormalForm,Truth}.lean`, `FormalSystem/Metalogic/Decidability/{IntPresentation,FMP/FiniteModel,FMP/Filtration}.lean`), `lake env lean` compile runs, `scripts/check-evidence-probes.sh`, `.github/workflows/ci.yml`, `specs/583_wire_check_scripts_into_ci/reports/01_uncalled-check-scripts.md`, report 01 of this task
**Artifacts**: - specs/581_repair_bilasso_evidence_probes/reports/02_probe-repair-verified-diffs.md
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **All four probes repair cleanly, and every obstruction still holds.** Each repaired draft was
  compiled with `lake env lean` (the guard's exact mechanism): exit 0, zero `sorry` warnings, and
  every `#print axioms` shows exactly `[propext, Classical.choice, Quot.sound]`. No theorem
  statement's content changed; no probe is weakened. No decision needs revisiting.
- **Drift has four causes, not two.** Report 01 named the `TemporalOrder` argument and
  `TaskFrame.step`. Measurement shows two more: (3) the step-path API moved from the total space
  `TaskFrame` to the fibre `FrameOver intOrder` (`IsStepPath`, `HFofStepPath` now live in
  `FrameOver` and take `P.toFibre`, not `P.toTaskFrame`); (4) `WorldHistory` was renamed to
  `ConvexHistory`. A fifth, proof-internal cause breaks `phase3`: `omega` does not see through
  `↑intOrder`-typed durations (documented in `intOrder`'s own docstring).
- **Report 01's "six omega failures are downstream" guess was half right**: fixing line 90 did not
  clear them. They are a genuine elaboration-typing issue, fixed by ascribing binders at `ℤ`.
- **CI wiring**: a single `run: bash scripts/check-evidence-probes.sh` step after the `lean_exe`
  step, gating (no `continue-on-error`). All probe imports are inside the `FormalSystem` root's
  import closure, so the lean-action cache is sufficient.
- **Side finding (out of scope, flag only)**: the DEFERRED probe's guard comment "It compiles
  today" is now false -- `spike-untl-unfolding-and-fwd-obstruction.lean` fails with 25 errors
  (`FrameClass.Discrete`, `TaskFrame.trivialFrame` gone). It must stay unwired; the stale comment
  should be corrected.

## Context & Scope

Research built on report 01 (sweep evidence), per its own instruction, rather than redoing it.
Scope: locate every replacement API, produce and compile a repair for each wired probe, confirm
each obstruction's force survives, and research the final CI-wiring phase. Probes were not edited
in place (research phase); drafts were compiled from the session scratchpad with `lake env lean`
from the repo root, which is byte-for-byte the guard's check.

## Findings

### Codebase Patterns: the API map

| Old spelling (probe) | Current spelling | Where defined |
|---|---|---|
| `FiniteFilteredTaskFrame ℤ phi` | `FiniteFilteredTaskFrame intOrder phi` | `FMP/FiniteModel.lean:172` (`(D : TemporalOrder)`); `intOrder := ⟨ℤ⟩`, `@[reducible]`, `Semantics/TemporalOrder.lean` |
| `(… ).toTaskFrame.WorldState` | `(… ).WorldState` | `FiniteFrameOver extends FrameOver` |
| `TaskFrame.step` / `F.toTaskFrame.step` | `FrameOver.step` / `F.toFrameOver.step` (`fun w u => F.TaskRel w 1 u`) | `Semantics/IntNormalForm.lean:181` |
| `IsStepPath X.toTaskFrame f` | `IsStepPath X.toFibre f` (takes `FrameOver intOrder`) | `IntNormalForm.lean:269` |
| `TaskFrame.HFofStepPath X.toTaskFrame f h` | `FrameOver.HFofStepPath X.toFibre f h` (returns `TaskFrame.HF F`) | `IntNormalForm.lean:314` |
| `WorldHistory F` | `ConvexHistory F` | rename, commit `b9fd6f15c` |
| `IntPresentation.toTaskFrame` | unchanged, still total-space; `toFibre : FrameOver intOrder` added | `Decidability/IntPresentation.lean` |

Note: keeping `.toTaskFrame` in phase7 is not viable -- a test with
`(FiniteFilteredTaskFrame intOrder phi).toTaskFrame.TaskRel` leaves `simp` with unsolved goals
(the total-space wrapper blocks the unfold). The fibre spelling is required, and is definitionally
the same relation (`FrameOver.toTaskFrame F := ⟨D, F⟩`).

### Per-probe verification results (drafts, `lake env lean`)

| Probe | Exit | `sorry` warnings | `#print axioms` |
|---|---|---|---|
| phase7-filtered-frame-is-universal | 0 | 0 | (examples; re-stated as theorems in a scratch copy) `[propext, Classical.choice, Quot.sound]` x3 |
| phase12-check-not-compositional | 0 | 0 | (no audit in file; scratch copy) `no_compositional_imp`, `fact1`: `[propext, Classical.choice, Quot.sound]` |
| phase3-scan-bound-is-false | 0 | 0 | `truth_prevN`, `plan_scan_bound_fails`, `no_formula_independent_scan_bound`: `[propext, Classical.choice, Quot.sound]` |
| phase10-origin-anchoring-obstruction | 0 | 0 | all four audited results: `[propext, Classical.choice, Quot.sound]` (the `sorryAx` in the rotted output was elaboration fallout, as report 01 predicted) |

phase12 emits one pre-existing linter warning (`unnecessarySeqFocus`, line 59); warnings do not
affect `lake env lean`'s exit status, so the guard passes. Leave it (not drift).

### Does each obstruction still hold? (statement-by-statement justification)

- **phase7**: `refinedFilteredTaskRel` is still `if d = 0 then w = u else True`
  (`FMP/Filtration.lean:276`), so the one-step relation is still universal. Changes: carrier `ℤ`
  -> `intOrder` (`↑intOrder` is `ℤ` by `rfl`); `.toTaskFrame.X` -> fibre-level `X`; `TaskFrame.step`
  -> `FrameOver.step` (same definition, relocated). **API-tracking only.**
- **phase12**: `univ2_all`'s statement `IsStepPath univ2.toTaskFrame f` -> `IsStepPath univ2.toFibre f`
  (predicate relocated to the fibre; `toTaskFrame := toFibre.toTaskFrame`). `hist`'s type and the
  `Sat` definition are unchanged. `no_compositional_imp` unchanged. **API-tracking only.**
- **phase3**: only statement-level change is `tau : WorldHistory …` -> `ConvexHistory …` (rename).
  All other edits are inside proofs: ascribing duration binders at `ℤ` so `omega` sees them.
  `truth_prev`, `truth_prevN`, `plan_scan_bound_fails`, `no_formula_independent_scan_bound`
  statements byte-identical. **API-tracking only.**
- **phase10**: `spikePath_isStepPath` -> `toFibre`; `spikeHF` built via `FrameOver.HFofStepPath`
  (its type `freePresentation.toTaskFrame.HF` unchanged); `truth_prev` binder and `Phase10Target`
  binder `WorldHistory` -> `ConvexHistory` (rename). `origin_past_periodic`,
  `truth_prev5_spike`, `type_at_origin_never_recurs`, `typeAt_origin_never_recurs` statements and
  proofs byte-identical. **API-tracking only.** The load-bearing anchoring obstruction stands.

### Verified repair diffs (apply verbatim)

These are the exact diffs of the compiled drafts against the current tracked probes.

```diff
--- a/specs/evidence/bi-lasso-decision-layer/phase7-filtered-frame-is-universal.lean
+++ b/specs/evidence/bi-lasso-decision-layer/phase7-filtered-frame-is-universal.lean
@@ -6,21 +6,21 @@
 open FormalSystem.Syntax
 
 -- Probe A: the finite filtered frame's one-step relation over Z is UNIVERSAL.
-example (phi : Formula) (w u : (FiniteFilteredTaskFrame ℤ phi).toTaskFrame.WorldState) :
-    (FiniteFilteredTaskFrame ℤ phi).toTaskFrame.step w u := by
-  simp [TaskFrame.step, FiniteFilteredTaskFrame, RefinedFilteredTaskFrame, refinedFilteredTaskRel]
+example (phi : Formula) (w u : (FiniteFilteredTaskFrame intOrder phi).WorldState) :
+    (FiniteFilteredTaskFrame intOrder phi).toFrameOver.step w u := by
+  simp [FrameOver.step, FiniteFilteredTaskFrame, RefinedFilteredTaskFrame, refinedFilteredTaskRel]
 
 -- Probe B: consequently EVERY function Z -> FilteredWorld is a step path,
 -- so H_F over that frame is the full function space and carries no dynamics.
 example (phi : Formula)
-    (f : ℤ → (FiniteFilteredTaskFrame ℤ phi).toTaskFrame.WorldState) :
-    IsStepPath (FiniteFilteredTaskFrame ℤ phi).toTaskFrame f := by
+    (f : ℤ → (FiniteFilteredTaskFrame intOrder phi).WorldState) :
+    IsStepPath (FiniteFilteredTaskFrame intOrder phi).toFrameOver f := by
   intro n
-  simp [TaskFrame.step, FiniteFilteredTaskFrame, RefinedFilteredTaskFrame, refinedFilteredTaskRel]
+  simp [FrameOver.step, FiniteFilteredTaskFrame, RefinedFilteredTaskFrame, refinedFilteredTaskRel]
 
 -- Probe C: the relation carries no MCS information at all -- it is universal at
 -- every nonzero duration, for every pair of filtered worlds.
 example (phi : Formula) (d : ℤ) (hd : d ≠ 0)
-    (w u : (FiniteFilteredTaskFrame ℤ phi).toTaskFrame.WorldState) :
-    (FiniteFilteredTaskFrame ℤ phi).toTaskFrame.TaskRel w d u := by
+    (w u : (FiniteFilteredTaskFrame intOrder phi).WorldState) :
+    (FiniteFilteredTaskFrame intOrder phi).TaskRel w d u := by
   simp [FiniteFilteredTaskFrame, RefinedFilteredTaskFrame, refinedFilteredTaskRel, hd]
--- a/specs/evidence/bi-lasso-decision-layer/phase12-check-not-compositional.lean
+++ b/specs/evidence/bi-lasso-decision-layer/phase12-check-not-compositional.lean
@@ -22,12 +22,12 @@
   ∃ τ : P.toTaskFrame.HF, τ.path 0 = w ∧ TruthAt P.toModel τ.val 0 φ
 
 /-- Every function into `univ2`'s carrier is a step path. -/
-theorem univ2_all (f : ℤ → Fin univ2.card) : IsStepPath univ2.toTaskFrame f := by
+theorem univ2_all (f : ℤ → Fin univ2.card) : IsStepPath univ2.toFibre f := by
   rw [univ2.isStepPath_iff]; intro _; rfl
 
 /-- The `H_F` member a bare function determines. -/
 noncomputable def hist (f : ℤ → Fin univ2.card) : univ2.toTaskFrame.HF :=
-  TaskFrame.HFofStepPath univ2.toTaskFrame f (univ2_all f)
+  FrameOver.HFofStepPath univ2.toFibre f (univ2_all f)
 
 theorem hist_path (f : ℤ → Fin univ2.card) : (hist f).path = f := rfl
 
--- a/specs/evidence/bi-lasso-decision-layer/phase3-scan-bound-is-false.lean
+++ b/specs/evidence/bi-lasso-decision-layer/phase3-scan-bound-is-false.lean
@@ -87,7 +87,7 @@
 abbrev M : TaskModel chainPresentation.toTaskFrame := chainPresentation.toModel
 
 /-- The total world history the bi-lasso decodes to. -/
-abbrev tau : WorldHistory chainPresentation.toTaskFrame := L.toHF.val
+abbrev tau : ConvexHistory chainPresentation.toTaskFrame := L.toHF.val
 
 /-! ## The truth set of `prevⁿ p` along this path is exactly `[n, ∞)` -/
 
@@ -110,14 +110,15 @@
 theorem truth_prev (s : ℤ) (psi : Formula) :
     TruthAt M tau s (Formula.snce Formula.bot psi) ↔ TruthAt M tau (s - 1) psi := by
   constructor
-  · rintro ⟨z, hzlt, hpsi, hgap⟩
+  · rintro ⟨(z : ℤ), (hzlt : z < s), hpsi, hgap⟩
     have hz : z = s - 1 := by
       by_contra hne
       have hlt : z < s - 1 := by omega
-      exact hgap (s - 1) hlt (by omega)
+      exact hgap (s - 1) hlt (show s - 1 < s by omega)
     rwa [hz] at hpsi
   · intro h
-    exact ⟨s - 1, by omega, h, fun r h1 h2 => absurd h2 (by omega)⟩
+    exact ⟨s - 1, show s - 1 < s by omega, h,
+      fun (r : ℤ) (h1 : s - 1 < r) (h2 : r < s) => absurd h2 (by omega)⟩
 
 /-- `prevⁿ`. -/
 def prevN : ℕ → Formula → Formula
@@ -149,7 +150,7 @@
       ∀ s : ℤ, -5 < s → s ≤ -5 + (L.mid.length : ℤ) + (L.fwd.length : ℤ) →
         ¬ TruthAt M tau s (Formula.atom pAtom) := by
   constructor
-  · exact ⟨0, by omega, (truth_atom 0).mpr le_rfl, fun r _ _ => truth_top r⟩
+  · exact ⟨0, show (-5 : ℤ) < 0 by omega, (truth_atom 0).mpr le_rfl, fun r _ _ => truth_top r⟩
   · intro s h1 h2 hs
     have : (0 : ℤ) ≤ s := (truth_atom s).mp hs
     simp [L] at h2
@@ -173,7 +174,8 @@
   obtain ⟨k, hkN⟩ : ∃ k : ℕ, N < (k : ℤ) := ⟨N.toNat + 1, by omega⟩
   have hk0 : (0 : ℤ) ≤ (k : ℤ) := Int.natCast_nonneg _
   refine ⟨prevN k (Formula.atom pAtom), ?_, ?_⟩
-  · exact ⟨(k : ℤ), by omega, (truth_prevN k (k : ℤ)).mpr le_rfl, fun r _ _ => truth_top r⟩
+  · exact ⟨(k : ℤ), show (-1 : ℤ) < k by omega, (truth_prevN k (k : ℤ)).mpr le_rfl,
+      fun r _ _ => truth_top r⟩
   · intro s _ hsN hs
     have := (truth_prevN k s).mp hs
     omega
--- a/specs/evidence/bi-lasso-decision-layer/phase10-origin-anchoring-obstruction.lean
+++ b/specs/evidence/bi-lasso-decision-layer/phase10-origin-anchoring-obstruction.lean
@@ -125,21 +125,21 @@
 /-- The path that visits state `1` exactly once, at time `-5`. -/
 def spikePath : ℤ → Fin freePresentation.card := fun u => if u = -5 then 1 else 0
 
-theorem spikePath_isStepPath : IsStepPath freePresentation.toTaskFrame spikePath := by
+theorem spikePath_isStepPath : IsStepPath freePresentation.toFibre spikePath := by
   rw [freePresentation.isStepPath_iff]
   intro t
   rfl
 
 /-- The total history determined by that path. -/
 def spikeHF : freePresentation.toTaskFrame.HF :=
-  TaskFrame.HFofStepPath freePresentation.toTaskFrame spikePath spikePath_isStepPath
+  FrameOver.HFofStepPath freePresentation.toFibre spikePath spikePath_isStepPath
 
 /-- `prev ψ`, in the live guard-first order: guard `⊥`, event `ψ`. -/
 def prev (ψ : Formula) : Formula := Formula.snce Formula.bot ψ
 
 /-- `prev` steps truth back exactly one tick. The guard is `⊥`, so the propagation disjunct of
 the one-step unfolding is dead and only the immediate-event disjunct survives. -/
-theorem truth_prev {τ : WorldHistory freePresentation.toTaskFrame} (t : ℤ) (ψ : Formula) :
+theorem truth_prev {τ : ConvexHistory freePresentation.toTaskFrame} (t : ℤ) (ψ : Formula) :
     TruthAt freePresentation.toModel τ t (prev ψ) ↔
       TruthAt freePresentation.toModel τ (t - 1) ψ := by
   rw [prev, truth_snce_pred]
@@ -233,7 +233,7 @@
 
 /-- The Phase 10 deliverable, in the shape that survives the anchoring obstruction. -/
 def Phase10Target (P : IntPresentation) (φ : Formula) (bx : Formula → Bool) (bound : ℕ) : Prop :=
-  ∀ (τ : WorldHistory P.toTaskFrame) (hτ : τ.IsTotal) (t : ℤ),
+  ∀ (τ : ConvexHistory P.toTaskFrame) (hτ : τ.IsTotal) (t : ℤ),
     TruthAt P.toModel τ t φ →
       ∃ A ∈ boundedAnnots P φ bx bound, ∃ i : ℤ,
         A.lasso.unroll i = τ.states t (hτ t) ∧ φ ∈ A.label i
```

### External Resources

- No Mathlib lemma search was required: every failure was project-internal renaming/relocation,
  resolved by reading the current definitions. Search tools were deliberately not spent.

### CI Wiring (final phase)

- **Template**: task 583 has not landed (status `researching`), so no pattern is "recorded" yet.
  Its report 01 names the existing "Compile lean_exe roots" step as the template: named after
  what it checks, reuses the lean-action cache, `::group::` blocks, a comment explaining the class
  of failure it observes.
- **Placement**: after "Compile lean_exe roots (outside the library closures)", before "Report
  results". The probes' imports (`FMP.FiniteModel`, `IntNormalForm`, `IntPresentation`,
  `BiLasso.Basic`, `BiLasso.SmallModel`, `Truth`) were all confirmed reachable from the
  `FormalSystem` default-target root by an import-closure walk, so `build: true` already produces
  every `.olean` a probe needs.
- **Fail vs report**: gate (fail). Rationale, from the script header and 583's report: a probe
  that silently stops compiling stops being an obstacle, so a report-only step reproduces the exact
  failure mode (four probes rotted with nothing announcing it). Record this decision in the step's
  comment.
- **Suggested step**:
  ```yaml
      # Evidence probes live under specs/, outside every Lake root, so the build above never
      # elaborates them; they rotted undetected once already. A rotted probe FAILS CI: a probe
      # that no longer compiles no longer protects the design decision it records.
      - name: check-evidence-probes.sh
        run: |
          set -euo pipefail
          echo "::group::bash scripts/check-evidence-probes.sh"
          bash scripts/check-evidence-probes.sh
          echo "::endgroup::"
  ```
  (With `set -e` a failure skips `::endgroup::`; GitHub closes the group anyway. Acceptable.)
- **"Deliberately broken probe fails the CI step" verification**: agents may not `git push`
  (`pr-prohibition.md`), and neither `act` nor `actionlint` is installed. The achievable
  verification is: (a) temporarily introduce a type error into one probe, run
  `bash scripts/check-evidence-probes.sh`, confirm exit 1 and the step's `run` inherits it under
  `set -euo pipefail`; restore the probe and confirm exit 0; (b) YAML-parse `ci.yml`
  (e.g. `python3 -c 'import yaml,sys; yaml.safe_load(open(".github/workflows/ci.yml"))'`). An
  actual remote red run requires a user push; record that as a user-side check in the summary.

## Decisions

- Use fibre-level spellings (`toFibre`, `toFrameOver`, `FrameOver.step`) everywhere the API moved;
  do not reach for the total space, since `simp` cannot close phase7 through `toTaskFrame`.
- Fix phase3's `omega` failures by ascribing binders at `ℤ` (`rintro ⟨(z : ℤ), (hzlt : z < s), …⟩`,
  `show … by omega`), matching the idiom `intOrder`'s docstring prescribes, rather than restating
  any theorem.
- Gate CI on the guard (no `continue-on-error`), since the probes will be green when the step lands.
- Do not touch the DEFERRED spike's Lean; do correct the now-false "It compiles today" sentence in
  the guard's DEFERRED comment (factual doc drift, not wiring). Planner may treat this as optional.

## Risks & Mitigations

- **Risk**: an intervening refactor (other agents are active) changes the API again before
  implementation. *Mitigation*: re-run `bash scripts/check-evidence-probes.sh` after applying the
  diffs; the diffs are small enough to re-derive from the API map above.
- **Risk**: CI wall-clock. *Mitigation*: guard measured ~1 min locally on a warm cache; four small
  files.
- **Risk**: the probe drift recurs silently. *Mitigation*: exactly what the CI step prevents.
- **Risk**: phase3 docstring text "The total world history" now sits above a `ConvexHistory`
  abbrev. Harmless prose; optionally leave, since "world history" is the paper's term.

## Tactic Survey Results

| Goal | Tactic | Result | Premises/Config |
|---|---|---|---|
| phase7 Probe A/B (`FrameOver.step` universal) | simp | success | `[FrameOver.step, FiniteFilteredTaskFrame, RefinedFilteredTaskFrame, refinedFilteredTaskRel]` |
| phase7 Probe C via `.toTaskFrame.TaskRel` | simp | fail (unsolved goals) | same set + `hd`; fibre spelling succeeds |
| phase3 `z < s - 1` with `z : ↑Duration` | omega | fail ("no usable constraints") | succeeds after `(z : ℤ)` ascription |
| phase3 `s - 1 < s`, `-5 < 0`, `-1 < k` at Duration type | omega | fail | succeeds under `show (… : ℤ) by omega` |
| phase10 / phase12 existing proofs | unchanged | success | none needed |

## Context Extension Recommendations

- **Topic**: evidence-probe maintenance across API renames
- **Gap**: no context file records that `IsStepPath`/`HFofStepPath`/`step` are fibre-level
  (`FrameOver intOrder`) and that `omega` needs `ℤ`-ascribed duration binders
- **Recommendation**: add a short note to `.claude/context/project/lean4/` (via the
  `agent-system/extensions/` source store) on the ℤ-fibre API and the `omega`/`↑intOrder` pitfall

## Appendix

- Commands: `bash scripts/check-evidence-probes.sh` (baseline: FAIL 4/4); `lake env lean <draft>`
  for each repaired draft and for scratch axiom-audit copies; import-closure walk from
  `FormalSystem.lean`; `lake env lean` on the DEFERRED spike (exit 1, 25 errors).
- Search tools (leansearch/loogle/leanfinder): not used -- no Mathlib gap involved.
