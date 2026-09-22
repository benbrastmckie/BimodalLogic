# Implementation Plan: Task #655

- **Task**: 655 - Topology characterizing Limit: cone-neighbourhood topology 𝒩_F vs subbasis topology 𝒯_F
- **Status**: [IMPLEMENTING]
- **Effort**: 10 hours
- **Dependencies**: None
- **Research Inputs**: specs/655_topology_characterizing_limit_nbhd_vs_subbasis/reports/01_topology-characterizing-limit.md
- **Artifacts**: plans/01_topology-characterizing-limit.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

This is a research task whose deliverable is the report plus sorry-free probe files under the
task directory; the research round already answered Q1-Q6 with five compiled probes (1225 lines,
zero `sorry`). What remains for the implementation round is to *harden* that deliverable: every
topological claim the task's hard constraint requires to carry "a sorry-free probe ... or the label
UNVERIFIED" currently carries one or the other, and this plan discharges the UNVERIFIED labels
that are within reach of a bounded Lean effort, mechanically audits the axiom claim the report
makes without evidence, and reconciles the report's results table and refactor specification with
whatever the new probes establish. Definition of done: all probes (old and new) compile with
`lake env lean`, each headline theorem's `#print axioms` output is recorded, and the report's
table cites a declaration name for every cell that is no longer UNVERIFIED.

Explicitly **not** done here, despite the research handoff's `next_action_hint`: lifting the
probes into `FormalSystem/Semantics/StateTopology.lean`. The task description forbids changes to
`FormalSystem/` or `Tests/` and assigns the frame refactor to the separate task that depends on
this one (task 656, whose `file_scope` is the library); report section 5 already specifies what
that task should build.

### Research Integration

The report (`reports/01_topology-characterizing-limit.md`) fixes the mathematics; this plan only
adds evidence. The items it labels UNVERIFIED, and their disposition here:

| Report item | Claim | Disposition |
|---|---|---|
| 1.6 | `sep` holds on the funnel's histories while Limit fails | Phase 2, `R4_sep` (general `D`) |
| 3.2 / 3.5 table cell "history continuity, 𝒯_F over ℚ/ℝ" | fails in general | Phase 2, `not_continuous_coneTopology_R4_history` (general class); Phase 5, `not_continuous_coneTopology_RHH_history` (regular class minus Saturation) |
| 3.5 | 𝒩_F discrete iff pointwise dwell time | Phase 3, `discreteTopology_nbhdTopology_iff` |
| table cell "Hausdorff, 𝒯_F over ℝ" | fails on two-origins since 𝒯_F = 𝒩_F there | Phase 3, `RTO_triangle`, `coneTopology_eq_nbhdTopology_RTO`, `not_t2Space_coneTopology_RTO` |
| 2.3 | 𝒩_F is strictly below the final topology (hedgehog) | Phases 4-5, `finalTopology_ne_nbhdTopology_RHH` |
| executive summary | "zero axioms beyond Mathlib's" | Phase 1, `#print axioms` on every headline theorem |
| 3.3 Saturation of the two-origin frame; 3.4 R0 without Limit; 2.3 hedgehog Saturation; ℚ analogue of 3.3 | -- | Remain UNVERIFIED (Non-Goals); the report already assigns the Saturation proofs to the refactor task |

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No ROADMAP.md found.

## Goals & Non-Goals

**Goals**:
- Re-verify the five research-round probes against the current tree and record per-theorem axiom output, turning the report's axiom claim into cited evidence.
- Discharge report item 1.6 with `R4_sep`, and the general-class 𝒯_F-discontinuity claim with `not_continuous_coneTopology_R4_history`.
- Discharge report item 3.5 with `discreteTopology_nbhdTopology_iff`.
- Verify 𝒯_F = 𝒩_F on the two-origin frame and its non-Hausdorffness for 𝒯_F: `RTO_triangle`, `coneTopology_eq_nbhdTopology_RTO`, `not_t2Space_coneTopology_RTO`.
- Build the hedgehog frame of report item 2.3 with its three checkable axioms `RHH_serial`, `RHH_compositional`, `RHH_limit`, and separate 𝒩_F from the final topology of all histories: `not_isOpen_nbhdTopology_hedgehogOpen`, `isOpen_preimage_hedgehogOpen_of_history`, `finalTopology_ne_nbhdTopology_RHH`, plus the in-class 𝒯_F-discontinuity witness `not_continuous_coneTopology_RHH_history`.
- Reconcile the report: replace each discharged UNVERIFIED label with the declaration name, keep the rest labelled, list the new probes, and record the verification log.

**Non-Goals**:
- Any edit under `FormalSystem/`, `Tests/`, `FormalSystem.lean`, or `docs/` (the refactor task owns those).
- Any edit to the manuscript `possible_worlds.tex`; the draft statements in report section 5 are the deliverable.
- Saturation for the two-origin or hedgehog frames (report 3.3 shadow argument): a compactness proof against the library's `Saturation` is out of budget; stays UNVERIFIED and is already assigned to the refactor task in report section 5 item 4.
- R0-without-Limit (report 3.4) and the ℚ analogue of the two-origin frame: stay UNVERIFIED / open.
- Deciding whether 𝒩_F equals the final topology under some frame condition: stays open.
- Running the Comparator: the probes are not Lake modules, so `lean-challenge-snapshot.sh`/`lean-comparator-run.sh` cannot resolve them; the Lean Challenge Statements section below pins statements for plan-compliance purposes only.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `R4_sep` over a general ordered group: the "cut" argument needs no density or Archimedean property, but the arithmetic must avoid `linarith` (no ordered field) | M | M | Follow the proof sketch in Phase 2 exactly; the only order facts needed are `t + d ≤ t ↔ d ≤ 0` and `abs_lt`; the report's Tactic Survey lists the lemma names that worked (`lt_sub_iff_add_lt'`, `sub_lt_iff_lt_add`, `abs_of_nonneg/neg`) |
| Hedgehog final-openness proof (Phase 5) exceeds its time box | M | M | Phase 5 is time-boxed at 2 h; the fallback is a `[COMPLETED WITH EXCLUSIONS]` record naming the exact goal state reached, and Phase 6 keeps the 2.3 label UNVERIFIED with that obstruction cited |
| `Compositional RHH` interpolation half: the spoke index adds an equality obligation to every case of the `RTO_compositional` proof | L | L | Copy `RTO_compositional` structurally; the extra conjunct is discharged by `rfl`/`h.1` in every case |
| Sibling tasks 651 and 653 are dispatched in the same cycle on this working tree | M | M | Only files under this task's `probes/` and `reports/` are written; stage with explicit `git add -- <file>` per file, never a directory add; re-read each file immediately before editing; see `context/contracts/territory.md` |
| `FormalSystem.Semantics.TaskFrame` olean stale relative to source (a sibling could touch the library) | L | L | Phase 1 checks mtimes and, only if needed, rebuilds the single module through `lake-build-guard.sh` detached |
| Report edits drift from what the probes actually prove | M | L | Phase 6 cites only declaration names that appear in a compiled probe; a grep over the probes for every cited name is the phase's verification step |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3, 4 | 1 |
| 3 | 5 | 4 |
| 4 | 6 | 2, 3, 5 |

Phases within the same wave can execute in parallel (they touch disjoint files: Phase 2 edits
`FourState.lean`, Phase 3 edits `NbhdTopology.lean` and `TwoOrigins.lean`, Phase 4 creates
`Hedgehog.lean`).

### Phase 1: Baseline re-verification and axiom audit [COMPLETED]

**Goal**: Establish that the five research-round probes still compile on the current tree and
replace the report's unevidenced "zero axioms beyond Mathlib's" with recorded `#print axioms`
output.

**Tasks**:
- [x] Confirm `git log -1` and `git status --short` show nothing unexpected outside the sibling task directories named in the dispatch's Territory section (651, 653); if a foreign modification touches `FormalSystem/`, stop and report per `context/contracts/territory.md`. *(completed: HEAD `d9cfc7f61`; only sibling `.return-meta.json`/plan files and the shared `specs/TODO.md`, `state.json`, `events.jsonl` modified; `FormalSystem/`, `Tests/` clean)*
- [x] Compare the mtime of `FormalSystem/Semantics/TaskFrame.lean` with `.lake/build/lib/lean/FormalSystem/Semantics/TaskFrame.olean`; only if the source is newer, rebuild that one module: `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Semantics.TaskFrame`, detached via `Bash(run_in_background: true)`, waited on per `context/patterns/bounded-build-waiter.md`. *(completed: olean mtime 1790011263 > source 1790006647; no rebuild needed)*
- [x] Run `lake env lean <probe>` on each of `NbhdTopology.lean`, `FourState.lean`, `IntPartition.lean`, `RealFrames.lean`, `TwoOrigins.lean`; capture exit code and full output to the scratchpad. *(deviation: altered — `NbhdTopology.lean` as committed at `9ec16ee08` did NOT compile: `341:73 error: unexpected token 'omit'; expected 'lemma'`, because `omit [Nontrivial D] in` sat between the docstring and `theorem limit_of_t1Space_coneTopology`; moved the `omit` above the docstring (the file's own idiom at line 58). The other four compiled unchanged. After the fix all five exit 0 with zero `error:` lines.)*
- [x] Append a trailing `#print axioms` line per headline theorem to each probe (the headline names are the ones the report's section 7 table cites), recompile, and confirm every output lists only `propext`, `Classical.choice`, `Quot.sound` (or a subset). Keep the lines in the probes: they make the axiom claim self-checking on every compile. *(completed: 36 theorems audited — 13 NbhdTopology, 7 FourState, 4 IntPartition, 7 RealFrames, 5 TwoOrigins — every one `[propext, Classical.choice, Quot.sound]`)*
- [x] `grep -n -E 'sorry|native_decide|admit' probes/*.lean` -- the only permitted hit is the word "sorry" in a docstring. *(completed: single hit, `NbhdTopology.lean:18` docstring)*
- [x] Commit: `task 655 phase 1: baseline re-verification and axiom audit` (stage the five probe files by explicit path).

**Timing**: 0.75 hours

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: five probe files, listed in the report's Artifacts block; confirm with
`ls probes/*.lean | wc -l` before starting. The headline-theorem list for the axiom audit is
every declaration name that appears in the report's section 7 table; confirm by grepping the
table for backticked identifiers.

**Files to modify**:
- `specs/655_topology_characterizing_limit_nbhd_vs_subbasis/probes/NbhdTopology.lean` - append `#print axioms` lines
- `specs/655_topology_characterizing_limit_nbhd_vs_subbasis/probes/FourState.lean` - same
- `specs/655_topology_characterizing_limit_nbhd_vs_subbasis/probes/IntPartition.lean` - same
- `specs/655_topology_characterizing_limit_nbhd_vs_subbasis/probes/RealFrames.lean` - same
- `specs/655_topology_characterizing_limit_nbhd_vs_subbasis/probes/TwoOrigins.lean` - same

**Verification**:
- All five `lake env lean` invocations exit 0 with no `error:` lines.
- The `#print axioms` output for every headline theorem is saved in the scratchpad log and contains no axiom outside `propext`, `Classical.choice`, `Quot.sound`.

---

### Phase 2: The funnel: `sep` without Limit, and a 𝒯_F-discontinuous history [COMPLETED]

**Goal**: Discharge report item 1.6 (the separation property of `ShiftSet.lean` holds on the
funnel's histories while Limit fails, so `rev_sep` is genuinely one-directional) and the
general-class claim that histories need not be 𝒯_F-continuous, both as additions to
`FourState.lean` where `R4` already lives.

**Tasks**:
- [x] Add a section `/-! ## Histories over the funnel -/` to `FourState.lean` with `IsHistory'` restated from `NbhdTopology.lean` (`∀ x y, R (τ x) (y - x) (τ y)`), over the file's general `D`. *(completed)*
- [x] Prove the two structural lemmas: `R4_history_low_past` (if `(τ t).val < 2` then `τ s = τ t` for all `s ≤ t`; from `R4_neg` at duration `s - t < 0`, the second disjunct needs `2 ≤ (τ t).val`, contradiction) and `R4_history_high_future` (if `2 ≤ (τ t).val` then `τ s = τ t` for all `t ≤ s`; from `R4_pos`, symmetric). *(completed; both via `R4_pos` at the positive duration `t - s` resp. `s - t`, equivalent to the `R4_neg` route)*
- [x] Prove `R4_history_shift_fixed`: if `∀ t, σ (t + a) = σ (t + b)` then `∀ u, σ (u + (a - b)) = σ u` (substitute `u = t + b`). *(completed)*
- [x] Prove `R4_sep` with the statement pinned below. Sketch: if `τ ≠ σ`, pick `t` with `τ t ≠ σ t`. From `h` at `x = 1`-style positive duration obtain `y₁` (if `y₁ = 0` then `τ = σ`, done); from `h` at `|y₁|` obtain `y₂` with `|y₂| < |y₁|`, so `d := y₁ - y₂ ≠ 0` and `σ` is fixed by `d`. Now `σ (t + y₁) = τ t ≠ σ t`, so by the structural lemmas either (`σ t` low, `σ (t + y₁)` high, hence `t + y₁ > t` and, using `d`-invariance and `low_past`/`high_future`, `t + d` and `t - d` are both low and both high -- contradiction) or the mirror case. No density and no Archimedean property is used; the only order facts are `t + d ≤ t ↔ d ≤ 0` and `abs_lt`. *(deviation: altered — the pinned statement is proved verbatim, but the sketch's closing case split ("`t + d` and `t − d` both low and both high") only closes when `2·y₂ ≤ y₁`, which nothing guarantees; replaced by one extra helper `R4_history_invariant_of_le` (the shift-invariance set of a funnel history is convex: invariance under `s ≥ 0` gives invariance under every `0 ≤ y ≤ s`) and a third application of `h` at radius `|d|`, whose witness `y₃` then fixes `σ` by convexity, so `τ = y₃·σ = σ`. Still no density and no Archimedean property; the order facts used are `abs_of_nonneg/neg`, `sub_pos`, `add_le_add_iff_left`, `le_add_of_nonneg_right`.)*
- [x] Prove `not_continuous_coneTopology_R4_history` (statement pinned below) at `D = ℝ`: the history `τ t := if t < 0 then 1 else 2` respects `R4` (four sign cases, each closed by `R4_pos`/`R4_neg`/`R4_zero`), `{2}` is `𝒯_F`-open by `discreteTopology_coneTopology_R4`, and `τ ⁻¹' {2} = Set.Ici 0` is not open in ℝ (an open set containing `0` contains `-ε`). *(completed; added `import Mathlib.Topology.MetricSpace.Basic` for `Metric.isOpen_iff` on ℝ)*
- [x] Recompile `FourState.lean`; add `#print axioms R4_sep` and `#print axioms not_continuous_coneTopology_R4_history`. *(completed: exit 0, no warnings; both `[propext, Classical.choice, Quot.sound]`)*
- [x] Commit: `task 655 phase 2: funnel sep and discontinuity witnesses`.

**Timing**: 2 hours

**Depends on**: 1

**Verification Tier**: local

**Files to modify**:
- `specs/655_topology_characterizing_limit_nbhd_vs_subbasis/probes/FourState.lean` - new section with `IsHistory'`, the two structural lemmas, `R4_history_shift_fixed`, `R4_sep`, `not_continuous_coneTopology_R4_history`

**Verification**:
- `lake env lean probes/FourState.lean` exits 0; `#print axioms` for both new headline theorems lists only the three standard axioms.
- The statement of `R4_sep` matches the Lean Challenge Statements block character-for-character modulo the file's own `Limit'`/`IsHistory'` names.

---

### Phase 3: Dwell-time discreteness and 𝒯_F = 𝒩_F on the two-origin frame [BLOCKED]

**BLOCKER** (Phase 3):
- **What failed**: the pinned Challenge statement `RTO_triangle : Triangle' RTO` is **false**, so the phase's third task, and the fourth task that routes `coneTopology_eq_nbhdTopology_RTO` through it, cannot be executed as written. The task list's claim that the `o → p → o` case is "trivial or impossible" is wrong: `o b ⇒_y p t` needs only `t ≤ y` and `p t ⇒_z o b'` needs only `t ≤ -z`, so the mixed-sign two-step path `o true ⇒₁ p ⟨1⟩ ⇒₋₁ o false` is a legitimate path between the two origins, and `RTO (o true) t (o false)` is `true = false` for every `t` — no shortcut exists at any duration.
- **What was tried**: a compiled refutation (scratchpad, `lake env lean`, exit 0, axioms `[propext, Classical.choice, Quot.sound]`), reproduced here so the reviser can re-run it against `TwoOrigins.lean`'s own `RTO` and the pinned `Triangle'`:
  ```lean
  theorem not_triangle_RTO : ¬ Triangle' RTO := by
    intro h
    obtain ⟨t, _, hR⟩ := h (o true) (p ⟨1, one_pos⟩) (o false) 1 (-1)
      (show (1 : ℝ) ≤ 1 from le_rfl) (show (1 : ℝ) ≤ -(-1) by norm_num)
    exact Bool.noConfusion (hR : true = false)
  ```
- **Why it's stuck**: `plan-compliance.md` (Statement Fidelity) forbids quietly proving a different statement under the same name or quietly editing the recorded Challenge; a false pinned statement is exactly the "genuinely wrong recorded statement" case it names, whose sanctioned route is `[BLOCKED]` plus escalation. The two *headline* results of this phase remain true and are the actual deliverable; only the intermediate route is wrong.
- **What is needed** (for the reviser; one plan revision): drop `RTO_triangle` and the `Triangle'` scaffolding from this phase and from the Lean Challenge Statements block, and prove `coneTopology_eq_nbhdTopology_RTO` by the direct route the report already provides in general form (`coneTopology_eq_nbhdTopology_iff`: `𝒯_F = 𝒩_F` iff every cone is `𝒩_F`-open, given `RTO_refl w 0 le_rfl`). Every cone of `RTO` *is* `𝒩_F`-open; the explicit radii, checked by hand:
  - `cone RTO (o b) x = {o b} ∪ {p t : t < x}`; at `o b` use radius `x`; at `p t` (`t < x`) use radius `min t (x - t)` — no origin lies in `cone RTO (p t) ε` when `ε ≤ t` (an origin needs `t ≤ -y`, i.e. `|y| ≥ t`), and a ray point `p s` there has `s ≤ t + y < t + ε ≤ x` or `s ≤ t`.
  - `cone RTO (p t) x = {p s : |s - t| < x} ∪ (if t < x then {o true, o false} else ∅)`; at `p s` use radius `x - |s - t|` (a ray point stays within `x` of `t`; an origin enters only if `s < x - |s - t|`, whence `t ≤ s + |s - t| < x`, so the origins are already in the cone); at an origin (`t < x`) use radius `x - t` (`o b ∈` since `t < x`; `p s` with `s < x - t` has `|s - t| < x`).
  So the replacement decomposition is: a `mem_cone_RTO` characterisation lemma (two cases on the centre), `isOpen_nbhdTopology_cone_RTO : ∀ w x, 0 < x → IsOpen[nbhdTopology' RTO] (cone RTO w x)`, then `coneTopology_eq_nbhdTopology_RTO` via the restated `coneTopology_eq_nbhdTopology_iff'`, and `not_t2Space_coneTopology_RTO` exactly as planned. The restated `coneTopology'`/`coneTopology_le_nbhdTopology'` from the second task are still needed; `Triangle'`/`isOpen_cone_of_triangle'`/`coneTopology_eq_nbhdTopology_of_triangle'` are not.
- **Prohibited workarounds**: Do NOT use `sorry`, `def X := True`, or any vacuous placeholder; do NOT weaken `Triangle'` (e.g. to same-sign `y, z`) under the same name.

**Goal**: Discharge report item 3.5 in `NbhdTopology.lean` and the "𝒯_F over ℝ is not Hausdorff"
cell in `TwoOrigins.lean`.

**Tasks**:
- [x] In `NbhdTopology.lean`, after `nbhdTopology_isClosed_iff`, prove `discreteTopology_nbhdTopology_iff` (statement pinned below) via Mathlib's `singletons_open_iff_discrete` (confirm the name with `lean_local_search` first; the fallback is `discreteTopology_iff_forall_isOpen` plus `isOpen_singleton`): a singleton `{w}` is 𝒩_F-open iff some cone at `w` is contained in it, by `nbhdTopology_isOpen_iff`. *(completed: via `discreteTopology_iff_isOpen_singleton` (the name that exists on the pinned Mathlib; `singletons_open_iff_discrete` does not) + `simp only [nbhdTopology_isOpen_iff, Set.mem_singleton_iff, forall_eq]`, the same shape as `discreteTopology_nbhdTopology_int_iff`; `NbhdTopology.lean` exits 0, axioms standard)*
- [ ] In `TwoOrigins.lean`, restate `Triangle'` (as in the pinned block) and the two general lemmas `isOpen_cone_of_triangle'`/`coneTopology_eq_nbhdTopology_of_triangle'` verbatim from `NbhdTopology.lean` specialised to `D = ℝ` (this file is standalone, per the report's Decisions), together with `coneTopology'` and the ℝ-specialised `coneTopology_le_nbhdTopology'` already present in `RealFrames.lean`. *(not started — scaffolding only for the blocked route; see BLOCKER)*
- [ ] Prove `RTO_triangle`: nine constructor cases on `(w, u, v)`; witnesses: `o → o → v`: `t := z`; `o → p t → p s`: `t := |y| + |z|` (since `s ≤ t + |z| ≤ y + |z|`); `p t → o → p s`: `t := s - t` (sign split, using `t ≤ -y` and `s ≤ z`); `p t → p r → p s`: `t := s - t` (`|s - t| ≤ |s - r| + |r - t| ≤ |z| + |y|`); `p t → p r → o`: `t := -(|y| + |z|)`; `p t → o → o`: `t := y`; the two `o → o → o`/`o → p → o` cases are trivial or impossible. Every arithmetic goal is `linarith` after `abs_of_nonneg`/`abs_of_neg` rewrites, exactly as in `RTO_compositional`. *(BLOCKED — statement is false; see BLOCKER)*
- [ ] Prove `coneTopology_eq_nbhdTopology_RTO` from `RTO_refl w 0 le_rfl` and `RTO_triangle`, then `not_t2Space_coneTopology_RTO` by rewriting with it and applying `not_t2Space_nbhdTopology_RTO`. *(BLOCKED — depends on `RTO_triangle`; both statements are true and the direct route is spelled out in the BLOCKER)*
- [ ] Recompile both probes; append `#print axioms` for the three new headline theorems; commit: `task 655 phase 3: dwell-time discreteness and two-origins cone topology`. *(partial: `NbhdTopology.lean` recompiled with `#print axioms discreteTopology_nbhdTopology_iff`; committed as `task 655 phase 3: dwell-time discreteness (TwoOrigins blocked)`)*

**Timing**: 1.5 hours

**Depends on**: 1

**Verification Tier**: local

**Files to modify**:
- `specs/655_topology_characterizing_limit_nbhd_vs_subbasis/probes/NbhdTopology.lean` - add `discreteTopology_nbhdTopology_iff` (stated with the file's unprimed `nbhdTopology`)
- `specs/655_topology_characterizing_limit_nbhd_vs_subbasis/probes/TwoOrigins.lean` - add `coneTopology'`, `Triangle'`, the two restated triangle lemmas, `RTO_triangle`, `coneTopology_eq_nbhdTopology_RTO`, `not_t2Space_coneTopology_RTO`

**Verification**:
- Both `lake env lean` runs exit 0; the new theorems' `#print axioms` output is standard.

---

### Phase 4: The hedgehog frame and its checkable axioms [NOT STARTED]

**Goal**: Realise the hedgehog of report item 2.3 as a compiled frame over `D = ℝ`: one centre
`c`, countably many rays `p n t` indexed by `n : ℕ`, with the two-origin frame's drift law on
each ray and no cross-ray tasks. Prove Seriality, Compositionality and Limit for it.

**Tasks**:
- [ ] Create `probes/Hedgehog.lean` with the same header structure as `TwoOrigins.lean` (imports, `open`, namespace, restated `Limit'`, `IsHistory'`, `coneTopology'`, `nbhdTopology'`, `t1Space_nbhdTopology_iff_limit'`), and the `inductive HH` / `def RHH` exactly as pinned below (the pinned block uses `abbrev` only to keep the snapshot extractor from counting them; the probe uses `def`).
- [ ] Prove `RHH_refl (w) (x) (hx : 0 ≤ x) : RHH w x w` and `RHH_serial` (as for `RTO`).
- [ ] Prove `RHH_compositional` by transcribing `RTO_compositional` case by case: in every `p n t`/`p m s` case the extra `n = m` conjunct is obtained by `subst` from the hypothesis or supplied by `rfl` for the interpolating point, which lies on the same ray as its endpoints.
- [ ] Prove `RHH_limit` by transcribing `RTO_limit`: the `c`/`p` cases are as before; the `p n t`/`p m s` case first extracts `n = m` from any single witness, then runs the `|s - t| < x` argument.
- [ ] Derive `t1Space_nbhdTopology_RHH` from `RHH_limit` (one line).
- [ ] Recompile; append `#print axioms` for `RHH_serial`, `RHH_compositional`, `RHH_limit`; commit: `task 655 phase 4: hedgehog frame and axioms`.

**Timing**: 2 hours (time-boxed)

**Depends on**: 1

**Verification Tier**: local

**Files to modify**:
- `specs/655_topology_characterizing_limit_nbhd_vs_subbasis/probes/Hedgehog.lean` - new file

**Verification**:
- `lake env lean probes/Hedgehog.lean` exits 0 with no `sorry`; the three axiom theorems have standard `#print axioms` output.
- If the time box is exhausted with an axiom theorem unfinished, do not leave a `sorry`: remove the unfinished declaration, mark this phase `[COMPLETED WITH EXCLUSIONS]` with a `#### Reasoned Exclusions` record quoting the last goal state, and Phase 5 is then skipped with the same record (Phase 6 keeps report item 2.3 UNVERIFIED and cites the obstruction).

---

### Phase 5: 𝒩_F is strictly below the final topology; 𝒯_F-discontinuity inside the class [NOT STARTED]

**Goal**: Separate 𝒩_F from the final topology of all histories on the hedgehog, and give an
in-class witness that histories need not be 𝒯_F-continuous, closing report item 2.3's main claim
with machine-checked evidence.

**Tasks**:
- [ ] Define `hedgehogOpen : Set HH := {v | ∀ n t, v = HH.p n t → t.1 < 1 / ((n : ℝ) + 1)}` (the complement of the "tips" `p n ⟨1/(n+1)⟩` and everything beyond them).
- [ ] Prove `not_isOpen_nbhdTopology_hedgehogOpen`: `c ∈ hedgehogOpen`, but for any `x > 0` choose `n` with `1/(n+1) < x` (`exists_nat_one_div_lt`), and `p n ⟨1/(n+1), _⟩ ∈ cone RHH c x` is not in the set.
- [ ] Prove three history lemmas: `RHH_history_single_ray` (`τ a = p n t → τ b = p m s → n = m`, from `RHH` at duration `b - a` or its reflection), `RHH_history_centre_past` (`τ z = c → s ≤ z → τ s = c`, since `p _ t ⇒_x c` needs `t ≤ -x`, impossible for `x ≥ 0`), and `RHH_history_reach` (`τ z = c → τ (z + s) = p n t → t.1 ≤ s`).
- [ ] Prove `isOpen_preimage_hedgehogOpen_of_history` via `isOpen_iff_forall_mem_open`/`Metric.isOpen_iff` on ℝ: at `z` with `τ z = c`, by cases on whether `τ` ever visits a ray after `z`; if it visits ray `n₀`, radius `1/(n₀+1)` works by `single_ray` + `reach` + `centre_past`; if never, radius `1` works. At `z` with `τ z = p n t` and `t < 1/(n+1)`, radius `1/(n+1) - t` works because `RHH (p n t) s (τ (z + s))` bounds `|t' - t| ≤ |s|` on the same ray (or lands at `c`, which is in the set).
- [ ] Prove `finalTopology_ne_nbhdTopology_RHH`: if the two topologies were equal, `hedgehogOpen` would be 𝒩_F-open because it is open in every `coinduced τ.1` (`isOpen_iSup_iff`, `isOpen_coinduced`), contradicting the second task.
- [ ] Prove `not_continuous_coneTopology_RHH_history`: `{c} = cone RHH (p 0 ⟨1,_⟩) 2 ∩ cone RHH (p 1 ⟨1,_⟩) 2` (cross-ray cones meet only at the centre, and `c ∈ (p n t)_x` iff `t < x`), so `{c}` is 𝒯_F-open; the history `τ s := if s ≤ 0 then c else p 0 ⟨s, _⟩` respects `RHH` (four sign cases) and `τ ⁻¹' {c} = Set.Iic 0` is not open.
- [ ] Recompile; append `#print axioms` for the four new headline theorems; commit: `task 655 phase 5: hedgehog final-topology separation`.

**Timing**: 2 hours (time-boxed)

**Depends on**: 4

**Verification Tier**: local

**Files to modify**:
- `specs/655_topology_characterizing_limit_nbhd_vs_subbasis/probes/Hedgehog.lean` - the set, the history lemmas, the four headline theorems

**Verification**:
- `lake env lean probes/Hedgehog.lean` exits 0 with no `sorry`; standard `#print axioms` output for every new theorem.
- Priority order if the time box binds: `not_isOpen_nbhdTopology_hedgehogOpen` and `isOpen_preimage_hedgehogOpen_of_history` and `finalTopology_ne_nbhdTopology_RHH` first (they are the claim in report 2.3); `not_continuous_coneTopology_RHH_history` last. Anything unfinished is removed (no `sorry` left in the file) and recorded under `#### Reasoned Exclusions` with the goal state reached, so Phase 6 can cite the precise obstruction.

---

### Phase 6: Reconcile the report and record the verification log [NOT STARTED]

**Goal**: Make the report's text, results table and refactor specification agree exactly with what
the probes now prove, and turn the research-time verification claims into cited evidence.

**Tasks**:
- [ ] Re-read the report immediately before editing (sibling dispatches share the tree).
- [ ] Section 1.6: replace "(UNVERIFIED in Lean; re-derived)" with the `R4_sep` citation and note that the proof needs neither density nor an Archimedean order.
- [ ] Section 2.3: cite `finalTopology_ne_nbhdTopology_RHH` (and the hedgehog probe) for "no in general"; keep the hedgehog's Saturation labelled UNVERIFIED; keep the "frame condition equivalent to 𝒩_F = final" open.
- [ ] Sections 3.2/3.3: cite `coneTopology_eq_nbhdTopology_RTO` and `not_t2Space_coneTopology_RTO`; section 3.5: cite `discreteTopology_nbhdTopology_iff`.
- [ ] Section 7 table: update the cells listed in this plan's Research Integration table with declaration names; every remaining UNVERIFIED cell must still say UNVERIFIED. Verify by grepping the probes for each cited name (`grep -n "theorem <name>" probes/*.lean` must hit for every name cited anywhere in the report).
- [ ] Executive summary: replace "zero axioms beyond Mathlib's" with the Phase 1 evidence ("`#print axioms` on every headline theorem lists only `propext`, `Classical.choice`, `Quot.sound`").
- [ ] Artifacts block and Appendix: add `probes/Hedgehog.lean`; add a "Verification log" appendix listing each probe, its `lake env lean` exit code, and the axiom output, taken from the scratchpad logs of Phases 1-5.
- [ ] Section 5 item 4 (counterexamples module for the refactor): add the sep witness, the hedgehog, and the 𝒯_F-discontinuity witnesses to the list of facts the refactor should lift; item 6: remove whatever is no longer "not library-grade yet".
- [ ] Also correct the research handoff's misdirection in the report's Decisions: one sentence stating that lifting into `FormalSystem/Semantics/StateTopology.lean` is the refactor task's job, not this one's.
- [ ] Commit: `task 655 phase 6: reconcile report with hardened probes` (stage the report by explicit path).

**Timing**: 1.5 hours

**Depends on**: 2, 3, 5

**Verification Tier**: prose

**Scope Hypothesis**: the UNVERIFIED labels to touch are the seven rows of this plan's Research
Integration table; confirm by `grep -c UNVERIFIED reports/01_topology-characterizing-limit.md`
before and after, and by listing every label that remains with its reason.

**Files to modify**:
- `specs/655_topology_characterizing_limit_nbhd_vs_subbasis/reports/01_topology-characterizing-limit.md` - citations, table cells, appendix, refactor spec items 4 and 6

**Verification**:
- Every backticked declaration name in the report resolves to a `theorem`/`def` line in some file under `probes/` (or to a library declaration in `FormalSystem/`), checked by grep.
- No new topological claim was added without either a declaration name or the label UNVERIFIED.

## Lean Challenge Statements

The identifier set below equals the set named under Goals. Supporting definitions are restated
as `abbrev`/`inductive` and precede every theorem so that `lean-challenge-snapshot.sh`'s
extractor neither counts them as Challenge identifiers nor truncates them; the probes themselves
use `def`, and `NbhdTopology.lean` uses the unprimed `nbhdTopology`. This block type-checks
standalone with `lake env lean` on the pinned toolchain (verified at planning time). The
Comparator route is not applicable to this task (the probes are not Lake modules), so the block
serves `plan-compliance.md`'s Statement Fidelity requirement only.

```lean
import Mathlib.Topology.Separation.Basic
import Mathlib.Topology.Order
import Mathlib.Topology.MetricSpace.Basic
import FormalSystem.Semantics.TaskFrame

open Topology TopologicalSpace Set

set_option warn.classDefReducibility false

namespace FormalSystem.Semantics.TaskFrame

variable {D : Type} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D]

abbrev Limit' {W : Type} (R : W → D → W → Prop) : Prop :=
  ∀ w u, (∀ x, 0 < x → ∃ y, |y| < x ∧ R w y u) → u = w

abbrev IsHistory' {W : Type} (R : W → D → W → Prop) (τ : D → W) : Prop :=
  ∀ x y, R (τ x) (y - x) (τ y)

abbrev Triangle' {W : Type} (R : W → D → W → Prop) : Prop :=
  ∀ w u v y z, R w y u → R u z v → ∃ t, |t| ≤ |y| + |z| ∧ R w t v

abbrev coneTopology' {W : Type} (R : W → D → W → Prop) : TopologicalSpace W :=
  generateFrom {s | ∃ w x, 0 < x ∧ s = cone R w x}

abbrev nbhdTopology' {W : Type} (R : W → D → W → Prop) : TopologicalSpace W where
  IsOpen O := ∀ w ∈ O, ∃ x, 0 < x ∧ cone R w x ⊆ O
  isOpen_univ := fun _ _ => by
    obtain ⟨a, ha⟩ := exists_ne (0 : D)
    rcases lt_or_gt_of_ne ha with h | h
    · exact ⟨-a, neg_pos.mpr h, subset_univ _⟩
    · exact ⟨a, h, subset_univ _⟩
  isOpen_inter := fun _ _ h₁ h₂ w hw => by
    obtain ⟨x₁, hx₁, hc₁⟩ := h₁ w hw.1
    obtain ⟨x₂, hx₂, hc₂⟩ := h₂ w hw.2
    exact ⟨min x₁ x₂, lt_min hx₁ hx₂,
      subset_inter ((cone_mono R w (min_le_left _ _)).trans hc₁)
        ((cone_mono R w (min_le_right _ _)).trans hc₂)⟩
  isOpen_sUnion := fun S hS w hw => by
    obtain ⟨O, hO, hwO⟩ := mem_sUnion.mp hw
    obtain ⟨x, hx, hc⟩ := hS O hO w hwO
    exact ⟨x, hx, hc.trans (subset_sUnion_of_mem hO)⟩

abbrev R4 (w : Fin 4) (x : D) (u : Fin 4) : Prop :=
  (x = 0 ∧ w = u) ∨ (0 < x ∧ (w = u ∨ (w.val < 2 ∧ 2 ≤ u.val))) ∨
    (x < 0 ∧ (w = u ∨ (u.val < 2 ∧ 2 ≤ w.val)))

inductive TO
  | o (b : Bool)
  | p (t : {t : ℝ // 0 < t})

abbrev RTO : TO → ℝ → TO → Prop
  | .o b, _, .o b' => b = b'
  | .o _, x, .p t => t.1 ≤ x
  | .p t, x, .o _ => t.1 ≤ -x
  | .p t, x, .p s => (0 ≤ x ∧ t.1 ≤ s.1 ∧ s.1 ≤ t.1 + x) ∨ (x < 0 ∧ s.1 ≤ t.1 ∧ t.1 ≤ s.1 - x)

inductive HH
  | c
  | p (n : ℕ) (t : {t : ℝ // 0 < t})

abbrev RHH : HH → ℝ → HH → Prop
  | .c, _, .c => True
  | .c, x, .p _ t => t.1 ≤ x
  | .p _ t, x, .c => t.1 ≤ -x
  | .p n t, x, .p m s =>
      n = m ∧ ((0 ≤ x ∧ t.1 ≤ s.1 ∧ s.1 ≤ t.1 + x) ∨ (x < 0 ∧ s.1 ≤ t.1 ∧ t.1 ≤ s.1 - x))

abbrev hedgehogOpen : Set HH := {v | ∀ n t, v = HH.p n t → t.1 < 1 / ((n : ℝ) + 1)}

-- NbhdTopology.lean (there the topology is the unprimed `nbhdTopology`)

theorem discreteTopology_nbhdTopology_iff {W : Type} (R : W → D → W → Prop) :
    @DiscreteTopology W (nbhdTopology' R) ↔ ∀ w, ∃ x, 0 < x ∧ cone R w x ⊆ {w} := sorry

-- FourState.lean

theorem R4_sep {τ σ : D → Fin 4} (hσ : IsHistory' R4 σ)
    (h : ∀ x : D, 0 < x → ∃ y : D, |y| < x ∧ ∀ t, τ t = σ (t + y)) : τ = σ := sorry

theorem not_continuous_coneTopology_R4_history :
    ∃ τ : ℝ → Fin 4, IsHistory' (R4 (D := ℝ)) τ ∧
      ¬ @Continuous ℝ (Fin 4) _ (coneTopology' (R4 (D := ℝ))) τ := sorry

-- TwoOrigins.lean

theorem RTO_triangle : Triangle' RTO := sorry

theorem coneTopology_eq_nbhdTopology_RTO : coneTopology' RTO = nbhdTopology' RTO := sorry

theorem not_t2Space_coneTopology_RTO : ¬ @T2Space TO (coneTopology' RTO) := sorry

-- Hedgehog.lean

theorem RHH_serial : Serial RHH := sorry

theorem RHH_compositional : Compositional RHH := sorry

theorem RHH_limit : Limit' RHH := sorry

theorem not_isOpen_nbhdTopology_hedgehogOpen : ¬ IsOpen[nbhdTopology' RHH] hedgehogOpen := sorry

theorem isOpen_preimage_hedgehogOpen_of_history {τ : ℝ → HH} (hτ : IsHistory' RHH τ) :
    IsOpen (τ ⁻¹' hedgehogOpen) := sorry

theorem finalTopology_ne_nbhdTopology_RHH :
    (⨆ τ : {τ : ℝ → HH // IsHistory' RHH τ}, coinduced τ.1 inferInstance) ≠
      nbhdTopology' RHH := sorry

theorem not_continuous_coneTopology_RHH_history :
    ∃ τ : ℝ → HH, IsHistory' RHH τ ∧ ¬ @Continuous ℝ HH _ (coneTopology' RHH) τ := sorry

end FormalSystem.Semantics.TaskFrame
```

## Testing & Validation

- [ ] `lake env lean` exits 0 on each of the six probes (`NbhdTopology`, `FourState`, `IntPartition`, `RealFrames`, `TwoOrigins`, `Hedgehog`).
- [ ] `grep -n -E 'sorry|native_decide|admit' probes/*.lean` matches only the docstring word in `NbhdTopology.lean`.
- [ ] Every `#print axioms` line's output is a subset of `{propext, Classical.choice, Quot.sound}`.
- [ ] Every declaration name cited in the report resolves by grep to a probe or library declaration.
- [ ] `git status --short` shows no modification outside `specs/655_topology_characterizing_limit_nbhd_vs_subbasis/` attributable to this task; `FormalSystem/` and `Tests/` untouched.
- [ ] The plan's phase headings carry the closed six-value marker vocabulary only.

## Artifacts & Outputs

- `specs/655_topology_characterizing_limit_nbhd_vs_subbasis/probes/Hedgehog.lean` (new)
- `specs/655_topology_characterizing_limit_nbhd_vs_subbasis/probes/{NbhdTopology,FourState,TwoOrigins}.lean` (extended), `{IntPartition,RealFrames}.lean` (axiom-print lines only)
- `specs/655_topology_characterizing_limit_nbhd_vs_subbasis/reports/01_topology-characterizing-limit.md` (reconciled)
- `specs/655_topology_characterizing_limit_nbhd_vs_subbasis/summaries/01_topology-characterizing-limit-summary.md` (written by the implementation agent at completion)

## Rollback/Contingency

- The research-round probes and report are committed at `9ec16ee08`. If an edit to an existing
  probe leaves it uncompilable and cannot be fixed forward, restore that single file's content
  with `git show 9ec16ee08:<path> > <path>` (a read of history, not a working-tree reset) and
  re-apply only the green additions. Never run a tree-wide reset or `git-snapshot.sh` in its
  default mode: sibling dispatches share this working tree (see
  `context/contracts/recovery.md`'s rollback rung for the sanctioned shape if a genuine
  whole-tree rollback ever became necessary).
- `Hedgehog.lean` is new; if Phases 4-5 are abandoned, delete the file and leave report item 2.3
  labelled UNVERIFIED with the obstruction recorded.
- No change here affects the library build, so there is nothing to roll back outside `specs/`.
