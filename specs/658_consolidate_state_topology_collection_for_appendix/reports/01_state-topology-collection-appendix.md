# Research Report: The State-Space Topology Collection for the Appendix

- **Task**: 658 - Consolidate the state-space topology into a library-grade, citable collection for the manuscript appendix
- **Started**: 2026-09-22T23:49:00Z
- **Completed**: 2026-09-23T00:35:00Z
- **Effort**: ~2 hours
- **Dependencies**: None blocking. Sibling task (Saturation for the two real witnesses; R0 without Limit) must not run concurrently; the frame-constraints audit task likewise.
- **Sources/Inputs**:
  - Seed report: `specs/658_consolidate_state_topology_collection_for_appendix/SEED.md`
  - Live tree: `FormalSystem/Semantics/StateTopology.lean`, `FormalSystem/Semantics/StateTopology/Counterexamples.lean`, `FormalSystem/Semantics/TaskFrame.lean`
  - Probe source: `specs/655_topology_characterizing_limit_nbhd_vs_subbasis/probes/TwoOrigins.lean`
  - Prior artifacts: `specs/655_topology_characterizing_limit_nbhd_vs_subbasis/reports/01_topology-characterizing-limit.md`, `specs/656_refactor_task_frames_general_with_frame_constraints/reports/01_general-frames-regular-constraints.md`
  - Wiring surfaces: `docs/theorem-index.md`, `docs/reference/paper-definitions-of-record.md`, `FormalSystem/Semantics/README.md`, `FormalSystem.lean`, `scripts/check-module-invariants.sh`
  - Tools: `lean_run_code` (compile + `#print axioms`), `scripts/check-module-invariants.sh --no-build`
- **Artifacts**:
  - `specs/658_consolidate_state_topology_collection_for_appendix/reports/01_state-topology-collection-appendix.md`
  - `specs/658_consolidate_state_topology_collection_for_appendix/probes/GapA_TwoOrigins.lean` (compiled, sorry-free)
  - `specs/658_consolidate_state_topology_collection_for_appendix/probes/GapB_Hedgehog.lean` (compiled, sorry-free)
  - `specs/658_consolidate_state_topology_collection_for_appendix/probes/FrameLevelAdditions.lean` (compiled, sorry-free)
  - `specs/658_consolidate_state_topology_collection_for_appendix/probes/README.md`
- **Standards**: report-format.md, subagent-return.md, status-markers.md, artifact-management.md

## Executive Summary

- **Gap A (the promotion gap) is closed as a research result, not merely scoped.** The entire two-origin cone-topology block from the probe was transplanted onto the live library API and **compiled with zero errors and standard axioms only** (`propext, Classical.choice, Quot.sound`). The probe's local shims (`Limit'`, `nbhdTopology'`, `coneTopology'`, `Triangle'`) are definitionally the library's `Limit`, `nbhdTopology`, `coneTopology`, `Triangle` at `D := ℝ`, and the probe's `RTO` is byte-identical to the library's `TwoOrigins.rel`. Implementation is a mechanical re-siting, not new mathematics.
- **Gap B (the hedgehog inequality) is closed as a research result too, and is cheaper than the seed expected** — three lines, not a reconstruction. `Hedgehog.coneTopology_ne_nbhdTopology` compiles, and the **strict** form `coneTopology rel < nbhdTopology rel` compiles as a bonus, which is the more quotable statement.
- **The headline organizational defect is not module shape — it is ledger coverage.** `docs/theorem-index.md` carries exactly **five** rows for the whole 1,849-line collection, and **`def:task-topology` and `app:topology-r0` have zero rows between them**. Two of the three labels the refactored appendix will carry are unrepresented in the repository's per-theorem ledger. The topology collection is also absent from `README.md`, `FormalSystem/README.md`, `docs/ARCHITECTURE.md` and `docs/reference/API_REFERENCE.md`.
- **Three frame-level declarations the appendix needs do not exist**, and all three compile: a named `FrameOver.r0Space_stateTopology` (under option (a) `app:topology-r0` is about `𝒩_F`, whose R0 is currently certified only by an **anonymous `example`** and is therefore uncitable), `FrameOver.isOpen_iff` (the replacement `def:task-topology`'s Open Sets clause at the frame level), and `FrameOver.iInter_cone_eq_singleton` (the paper's equality form at a regular frame).
- **The Lean result is stronger than the ratified manuscript statement.** `FrameOver.t1Space_iff_limit` and `TaskFrame.t1Space_nbhdTopology_iff_limit` consume **no frame constraint whatsoever** — not even *Seriality*. The appendix can state the biconditional unconditionally rather than "under *Seriality*", and should.
- **Recommend against splitting `Counterexamples.lean` and against renaming the `funnel_*` declarations.** No invariant imposes a size limit, all three witnesses are already leaf-module-isolated, and the rename would touch ~30 declarations plus their ledger rows and C14 baselines for pure symmetry. Discoverability is a ledger problem, solved by rows.

## Context & Scope

This round verifies the seed report against the live tree rather than re-deriving it, de-risks the two promotion gaps by compiling them, and produces the appendix support table.

Verified constraints held throughout:

- **Import weight lever intact.** `grep` confirms nothing under `FormalSystem/` imports either topology module except `Counterexamples.lean` importing `StateTopology.lean`; only the generated root `FormalSystem.lean` (lines 497-498) reaches them. `FormalSystem/Semantics.lean` does **not** import either. This must stay true.
- **Baseline gates green.** `bash scripts/check-module-invariants.sh --no-build` reports `ALL CHECKS PASSED`, including `C28 0 warning(s) across 0 file(s)` and `C33 FormalSystem.lean is byte-for-byte the generated root`. Zero `sorry` in both modules.
- **Out of scope by construction**: the two open mathematical questions (Gap C, Gap D below) belong to the sibling task and are recorded as support-table dependencies, not attempted.

## Findings

### Seed verification: every claim checked, two corrections

| Seed claim | Verdict |
|---|---|
| `StateTopology.lean` 629 lines, `Counterexamples.lean` 1,220 lines | Confirmed |
| Zero `sorry` in both modules | Confirmed |
| Gap A: zero occurrences of `not_triangle`, `isOpen_nbhdTopology_cone`, `not_t2Space_coneTopology` in `FormalSystem/` | Confirmed — `grep` returns nothing |
| The three `coneTopology_eq_nbhdTopology` occurrences are the general theorems only | Confirmed — `_of_triangle` (:389), `_iff` (:397), `_real` (:516) |
| Gap B: the hedgehog inequality is not a declaration | Confirmed |
| Gap C: neither `TwoOrigins` nor `Hedgehog` is an `IsRegular` instance | Confirmed — docstrings at `:611`, `:774`, `:852`, `:1010` say so deliberately |
| Gap D: no `r0Space_of_not_limit` | Confirmed — `grep` returns nothing |
| Declaration inventories of both modules | Confirmed in full; no drift |
| `app:topology-t1` will be "a biconditional **under *Seriality* alone**" | **Correction**: the Lean biconditional consumes no constraint at all. `[Nontrivial D]` is used only so that a positive radius exists, i.e. so `𝒩_F` is a topology. See `StateTopology.lean:190-194` docstring. |
| `app:topology-r0` likely certified by `r0Space_nbhdTopology_of_limit` / `r0Space_coneTop` | **Partial correction**: `r0Space_coneTop` is about `𝒯_F`, the *superseded* topology. Under option (a) the label is about `𝒩_F`. The general-layer `TaskFrame.r0Space_nbhdTopology_of_limit` exists; the **frame-level named counterpart does not** (see below). |

### Gap A: compiled, not merely scoped

The probe's `RTO` (`probes/TwoOrigins.lean:84-88`) and the library's `TwoOrigins.rel` (`Counterexamples.lean:630-634`) are character-for-character the same four-case definition. The probe's shims are the library's general-layer definitions restricted to `D = ℝ`, which satisfies the library's `[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D]` binders.

The following block was run against the live library via `lean_run_code` and compiled clean:

| Promoted declaration (proposed name, in `StateTopology.TwoOrigins`) | Probe source | Axioms |
|---|---|---|
| `not_triangle` — *Triangle* **fails** on this frame | `not_triangle_RTO` | `pcq` |
| `o_mem_cone_o` — `o b' ∈ (o b)_x ↔ b = b'` | `o_mem_cone_o` | `pcq` |
| `p_mem_cone_o` — `p t ∈ (o b)_x ↔ t < x` | `p_mem_cone_o` | `pcq` |
| `o_mem_cone_p` — `o b ∈ (p t)_x ↔ t < x` | `o_mem_cone_p` | `pcq` |
| `p_mem_cone_p` — `p s ∈ (p t)_x ↔ \|s - t\| < x` | `p_mem_cone_p` | `pcq` |
| `isOpen_nbhdTopology_cone` — every cone is `𝒩_F`-open, radii `min t (x-t)`, `x - \|s-t\|`, `x - t` | `isOpen_nbhdTopology_cone_RTO` | `pcq` |
| `coneTopology_eq_nbhdTopology` — **`𝒯_F = 𝒩_F` on this frame** | `coneTopology_eq_nbhdTopology_RTO` | `pcq` |
| `not_t2Space_coneTopology` — **`𝒯_F` is not Hausdorff either** | `not_t2Space_coneTopology_RTO` | `pcq` |

Two **frame-level wrappers** were additionally mechanics-checked and compile (the unfolding route `unfold FrameOver.coneTop FrameOver.stateTopology; rw [frame_taskRel_eq]` works):

- `TwoOrigins.frame_coneTop_eq_stateTopology : frame.coneTop = FrameOver.stateTopology frame`
- `TwoOrigins.frame_not_t2Space_coneTop : ¬ @T2Space frame.WorldState frame.coneTop`

These two are what the appendix should actually cite, since they are statements about a *frame*, matching the manuscript's register.

**What this unlocks for the appendix.** With `frame_not_t2Space` alone the manuscript may say only that the neighbourhood topology fails Hausdorff here. With the promoted pair it may say the two topologies **coincide** on this frame and neither is Hausdorff — non-Hausdorffness is a property of the frame, not an artefact of the choice of topology. Separately, `not_triangle` together with `coneTopology_eq_nbhdTopology` is the library's only witness that **`Triangle` is sufficient but not necessary** for cone-openness, a result with no home today.

### Gap B: compiled, and available in a stronger form

Three declarations compile against the live library, all `pcq`:

- `Hedgehog.not_isOpen_nbhdTopology_singleton_c : ¬ IsOpen[nbhdTopology rel] ({c} : Set HH)` — a supporting lemma needing one new cone fact, `p_mem_cone_c : t < x → p n t ∈ cone rel c x` (two lines).
- `Hedgehog.coneTopology_ne_nbhdTopology : coneTopology rel ≠ nbhdTopology rel` — **the named inequality Gap B asks for**.
- `Hedgehog.coneTopology_lt_nbhdTopology : coneTopology rel < nbhdTopology rel` — the **strict** form, via `lt_of_le_of_ne` on `coneTopology_le_nbhdTopology`. This is strictly more informative and is the better citation: it says `𝒯_F` is *strictly finer*, not merely different.

Note on Mathlib's order convention, which is easy to get backwards and which cost one compile attempt here: `t₁ ≤ t₂` on `TopologicalSpace` means `t₁` has *at least* `t₂`'s opens, i.e. `t₁` is **finer**. So `coneTopology R ≤ nbhdTopology R` says `𝒯_F` is finer, and the strict form is `coneTopology < nbhdTopology`, **not** the reverse. Any docstring or manuscript footnote restating this must match.

### Gap C and Gap D: sibling-task dependencies, precisely stated

- **Gap C (Saturation for the two real witnesses).** `TaskFrame.Saturation` (`TaskFrame.lean:577-579`) is a directed-family intersection condition: every directed family of nonempty fibers/segments has nonempty intersection. The funnel gets it free from `saturation_of_finite` (`Fin 4` is finite); `TwoOrigins` and `Hedgehog` have infinite carriers and have no such route. Consequence for the appendix, unchanged from the seed: the T1-non-Hausdorff claim is currently a claim about a **structure satisfying three of the four constraints**, not about a **task frame**. Every support-table row that would say "task frame" for these two witnesses is `pending-sibling`.
- **Gap D (R0 without Limit).** No `r0Space_of_not_limit` anywhere in `FormalSystem/`. Recorded in the topology research as a paper argument only, marked UNVERIFIED. Unchanged.

### Organization assessment (Deliverable 3)

**Q1 — Is the general-relation / frame-level split clean?** Yes, structurally: `StateTopology.lean:97-539` is `namespace ...TaskFrame` (general layer, ~30 results over bare `R : W → D → W → Prop`), `:541-629` is `namespace ...FrameOver` (frame layer, 9 thin wrappers). The layering is right and the wrappers are the correct shape for citation — the manuscript speaks about frames, so it should cite the frame layer, falling through to the general layer only where the statement is genuinely about a relation.

But the frame layer is **incomplete in exactly the places option (a) moves the appendix to**. Three declarations are missing; all three were compiled:

| Proposed | Statement | Why the appendix needs it |
|---|---|---|
| `FrameOver.isOpen_iff` | `IsOpen O ↔ ∀ w ∈ O, ∃ x, 0 < x ∧ cone F.TaskRel w x ⊆ O` (proof: `Iff.rfl`) | This **is** the replacement `def:task-topology`'s one-clause Open Sets definition, at the frame level. Today only the general-layer `nbhdTopology_isOpen_iff` states it. |
| `FrameOver.r0Space_stateTopology` | `[F.IsRegular] → R0Space F.WorldState` | Under option (a) `app:topology-r0` is about `𝒩_F`. Today `𝒩_F`'s R0 at a frame is certified **only by the anonymous `example` at `StateTopology.lean:625`**, which no citation can name. `r0Space_coneTop` certifies the *superseded* topology. This is the single sharpest citability gap in the collection. |
| `FrameOver.iInter_cone_eq_singleton` | `[F.IsRegular] → ⋂ x > 0, cone F.TaskRel w x = {w}` | The paper's equality form of *Limit*, at a frame. Today it must be assembled by the reader from `limit_eq_iff` + `mem_cone_self` + `t1Space_iff_limit`. |

**Q2 — Should `Counterexamples.lean` (1,220 lines, four witnesses) be split?** **No.** Reasons, in order of weight:

1. No invariant imposes a module size limit. The full `--no-build` pass was read for one; C1-C33 contain none.
2. The import-weight lever already gives the isolation a split would be reaching for: all three witnesses sit in one leaf module that nothing under `FormalSystem/` imports. Splitting moves zero Mathlib instances.
3. Each new module costs an aggregator decision, a `FormalSystem/Semantics/README.md` row, a `mk_all` regeneration, and C4/C6/C8/C24/C33 re-satisfaction — recurring cost against a one-time readability gain.
4. Discoverability is what the split was meant to buy, and it is not a module-boundary problem. A manuscript reader follows a *name*, not a path. The fix is ledger rows (Q3), which are needed whether or not the file is split.

**Q3 — Does `docs/theorem-index.md` cover the topology at citation granularity?** **No — this is the collection's principal defect.** Exactly five rows exist (`docs/theorem-index.md:182-184, 187-188`), covering `FrameOver.t1Space_iff_limit`, `funnel_t1Space_coneTopology`, `funnel_not_limit`, `TwoOrigins.frame_not_t2Space` and `Hedgehog.finalTopology_ne_nbhdTopology`.

Absent, among results the refactored appendix will lean on: `def:task-topology` has **no row at all**; `app:topology-r0` has **no row at all**; and there is no row for `t1Space_nbhdTopology_iff_limit` (the general-layer headline), `limit_eq_iff`, `nbhdTopology_isOpen_iff`, `continuous_nbhdTopology_of_history` / `FrameOver.continuous_of_history` (**the new history-continuity lemma the appendix is adding**), `coneTopology_le_nbhdTopology` (the footnote's "the old topology is finer" claim), `limit_of_t1Space_coneTopology`, `funnel_one_way_pair`, `funnel_saturation`, the four ℤ-layer results, the two real-frame bridge lemmas, or `Hedgehog.isOpen_coneTopology_singleton_c`.

The ledger's row schema, taken from C15's own regex in `scripts/check-module-invariants.sh:2196-2198`, is:

```
| {Paper label or —} | {Statement, one line} | `{Fully qualified Lean name}` | `{File path, no line numbers}` | {Frame class or —} | {Axioms} |
```

C15's second assertion requires, for every row, that the named declaration's own `/--` doc comment carry a `Paper:` line whose value is either the row's anchor or the literal `—` followed by a one-clause reason. Existing topology docstrings already follow this (e.g. `TwoOrigins.frame_not_t2Space` carries `Paper: — (formalization-native; ...)`), but **the probe docstrings do not**, so the promotion must add `Paper:` lines.

The `Axioms` column reads `pcq` (plain) or `pcq pinned:C14`. Pinning is a **two-place edit** in `scripts/check-module-invariants.sh`: the expected-output heredoc at ~`:1888` and the `#print axioms` list at ~`:2051`. Plain `pcq` rows are permitted (rows `:187` and `:188` use it), so pinning is a per-row choice, not an obligation.

**Q4 — Is the Lean naming still transparent once the manuscript reuses `𝒯_F` for `𝒩_F`?** **No, and this is the highest-value cheap fix.** After the rewrite the published symbol `𝒯_F` denotes what Lean calls `nbhdTopology` / `FrameOver.stateTopology`, while the footnote's superseded subbasis topology is what Lean calls `coneTopology` / `FrameOver.coneTop`. A reader following a citation lands on a name that contradicts the symbol they came from.

Compounding this: `docs/theorem-index.md`'s **"Notation and naming" table** (`:31` onward), which is the repository's declared paper-term-to-Lean-identifier mapping, **has no topology row at all**, and `docs/reference/paper-definitions-of-record.md:1963` records "`def:task-topology` and its topology properties (`T1`, `R0`, `Discrete`) — topology is not named".

Two options, with a recommendation:

- **(Recommended) Keep the Lean names; document the correspondence.** Add a "Notation and naming" row mapping the revised `def:task-topology`'s `𝒯_F` to `TaskFrame.nbhdTopology` / `FrameOver.stateTopology`, and the footnote's superseded topology to `TaskFrame.coneTopology` / `FrameOver.coneTop`. Add a matching symbol-correspondence paragraph to `StateTopology.lean`'s module header and to both topology `def` docstrings. Cost: four edits. The names `nbhdTopology` / `coneTopology` remain *mathematically* descriptive regardless of which one the paper's symbol currently denotes, which is a virtue under a paper that has now changed the symbol's referent once.
- **(Not recommended) Rename** `nbhdTopology → taskTopology`, `coneTopology → subbasisTopology`. Aligns Lean with the final manuscript but re-couples the library to a symbol assignment that has already moved once, touches both modules plus every ledger row and C14 baseline, and would need deprecation aliases whose base names C17's census then has to tolerate.

**Namespace shape.** Worth recording but **not worth acting on**: `Counterexamples.lean` declares `namespace FormalSystem.Semantics.StateTopology`, so the namespace `StateTopology` contains *only counterexamples*, while the topology API itself lives in `...TaskFrame` and `...FrameOver`. Within it, the funnel's ~30 declarations sit flat (`StateTopology.funnel_*`, `StateTopology.funnelRel_*`) while the other two witnesses are nested (`StateTopology.TwoOrigins.*`, `StateTopology.Hedgehog.*`). Giving the funnel a `Funnel` namespace for symmetry would cost ~30 renames plus deprecation aliases plus three ledger-row updates plus two C14 baseline edits, to buy consistency only — and the `funnel_` prefix already namespaces by convention, which C17's last-dot-segment census actively prefers. **Recommend leaving both as they are**, and recording the asymmetry in the module header instead.

**C17 interaction, and a synergy worth planning around.** Every Gap A / Gap B promotion is terminal — nothing else in the library will reference `not_triangle`, `coneTopology_ne_nbhdTopology` or the cone-membership lemmas — so C17's dead-declaration census would ordinarily list them. C17 is **reporting-only, never gating**, so this is not a blocker. More usefully, C17's occurrence corpus includes **every `.md` file in the repo outside `specs/`**, so a `docs/theorem-index.md` row for a promoted declaration is itself an occurrence: recommendation 5 below (ledger rows) keeps the promotions off the census as a side effect. Plan the two together.

**Deprecation precedent.** The tree uses `@[deprecated]` exactly once — `FormalSystem/Theorems/Propositional/Core.lean:340`, as `@[deprecated impOfNeg (since := "2025-12-14")]`. That is the syntax to follow if any rename is adopted after all.

**Surface coverage.** The topology collection appears in `FormalSystem/Semantics/README.md` (two good rows, `:62-63`) and `docs/theorem-index.md` (five rows). It appears **nowhere** in `README.md`, `FormalSystem/README.md`, `docs/ARCHITECTURE.md`, or `docs/reference/API_REFERENCE.md` (all grep to zero). For a collection whose stated purpose is to be cited from a published appendix, absence from the repository's front door is a defect.

**Test coverage.** `Tests/BimodalTest/` contains **zero** references to `StateTopology`, `nbhdTopology` or `coneTopology`. The acceptance criterion "`lake build --wfail` green over the library and `Tests/BimodalTest`" is therefore vacuous for this collection.

## The appendix support table

Every row's axiom profile was obtained by `#print axioms` against the live library in this round; `pcq` abbreviates exactly `[propext, Classical.choice, Quot.sound]`, matching `docs/theorem-index.md`'s legend. Names are fully qualified below `FormalSystem.Semantics.`.

Status vocabulary: `certified` (a named declaration exists today) / `to-promote` (compiled in this round, not yet in the tree) / `to-state` (compiles, proposed, not yet written) / `pending-sibling` (blocked on the open-questions task) / `not-certified`.

### Part 1 — `def:task-topology`, the replacement definition

| Manuscript element | Statement | Certifying declaration | Axiom profile | Status |
|---|---|---|---|---|
| `def:task-topology`, Open Sets clause | `O` is open iff every `w ∈ O` has some `x > 0` with `(w)_x ⊆ O` | `TaskFrame.nbhdTopology` (def) and `TaskFrame.nbhdTopology_isOpen_iff` | `pcq` | certified |
| Same, at a frame | The state space's `TopologicalSpace` instance has that `IsOpen` | `FrameOver.stateTopology` (instance); **`FrameOver.isOpen_iff` proposed** | `pcq` | certified / `to-state` |
| "the radius is chosen per point" | The `∃ x` is inside the `∀ w ∈ O` | shape of `nbhdTopology_isOpen_iff` | `pcq` | certified |
| Cone monotonicity, consumed by the topology axioms | `x ≤ y → (w)_x ⊆ (w)_y` | `TaskFrame.cone_mono` | `pcq` | certified |
| `D` has a positive duration, consumed for `W` open | some `x > 0` exists | `TaskFrame.exists_pos_of_nontrivial` | `pcq` | certified |
| `∅, W` open; closed under `⋃` and finite `∩`; hence a topology | the three `TopologicalSpace` fields | `TaskFrame.nbhdTopology`'s `isOpen_univ`, `isOpen_inter`, `isOpen_sUnion` | `pcq` | certified |
| "no frame axiom is needed for it to be a topology" | only `[Nontrivial D]` is consumed | binder list of `TaskFrame.nbhdTopology` | `pcq` | certified |
| Closure clause (unchanged wording, new `O_F`) | `cl S = {w : every open O ∋ w meets S}` | Mathlib `closure`; `Specializes` bridge via `specializes_iff_mem_closure` | — | certified (implicit bridge — see flags) |

### Part 2 — `app:topology-t1` as a biconditional

| Manuscript element | Statement | Certifying declaration | Axiom profile | Status |
|---|---|---|---|---|
| `app:topology-t1`, headline biconditional (⊆-half form of *Limit*) | `𝒩_F` is T1 ⟺ *Limit*, **no frame constraint consumed** | `TaskFrame.t1Space_nbhdTopology_iff_limit` | `pcq` | certified |
| Same, at a general frame | `T1Space F.WorldState ↔ Limit F.TaskRel` | `FrameOver.t1Space_iff_limit` | `pcq pinned:C14` | certified |
| **`app:topology-t1` exactly as drafted** — equality-form *Limit* ⟺ T1, **under *Seriality* alone** | `(∀ w, ⋂_{x>0}(w)_x = {w}) ↔ 𝒩_F` T1, given `Serial R` | **`TaskFrame.t1Space_nbhdTopology_iff_iInter_cone_of_serial` proposed** (compiled this round) | `pcq` | **`to-state`** |
| Corollary: T1 for every task frame | a regular frame's state space is T1 | `FrameOver.instT1SpaceOfRegular` | `pcq` | certified |
| Equality form `⋂_{x>0}(w)_x = {w}` decomposed | equality form ⟺ (T1 ∧ `w ∈ (w)_x`) | `TaskFrame.limit_eq_iff` | `pcq` | certified |
| The `⊇` half from nullity | `R w 0 w → w ∈ (w)_x` | `TaskFrame.mem_cone_self` | `propext` only | certified |
| Nullity derived from *Seriality* + ⊆-half *Limit* (the inline re-proof of `lem:nullity`) | `Serial R → Limit R → R w 0 w` | `TaskFrame.nullity_of_serial_limit` | `propext` only | certified |
| Same, at a regular frame, equality form | `⋂_{x>0}(w)_x = {w}` | **`FrameOver.iInter_cone_eq_singleton` proposed** | `pcq` | `to-state` |
| "the new proof does not consume the reflection convention" | `t1Space_coneTopology_of_limit` takes only `h0` and `hlim` | `TaskFrame.t1Space_coneTopology_of_limit` (binder list) | `pcq` | certified |

### Part 3 — `app:topology-r0`

| Manuscript element | Statement | Certifying declaration | Axiom profile | Status |
|---|---|---|---|---|
| `app:topology-r0` under the **new** topology | `𝒩_F` is R0 under *Limit* | `TaskFrame.r0Space_nbhdTopology_of_limit` | `pcq` | certified |
| Same, at a regular frame, **named** | `[F.IsRegular] → R0Space F.WorldState` | **`FrameOver.r0Space_stateTopology` proposed** — today only the anonymous `example` at `StateTopology.lean:625` | `pcq` | **`to-state`** |
| `app:topology-r0` for the **old** topology (footnote only) | `𝒯_F` is R0 under *Limit* and `R w 0 w` | `TaskFrame.r0Space_coneTopology_of_limit`, `FrameOver.r0Space_coneTop` | `pcq` | certified |
| "T1 ⇒ R0, so the proof is topology-agnostic" | Mathlib's `T1Space → R0Space` instance | used in both `r0Space_*` proofs | `pcq` | certified |

### Part 4 — the new history-continuity lemma

| Manuscript element | Statement | Certifying declaration | Axiom profile | Status |
|---|---|---|---|---|
| New lemma: every possible world is continuous | every history `τ : D → W` is `𝒩_F`-continuous, **no frame axiom** | `TaskFrame.continuous_nbhdTopology_of_history` | `pcq` | certified |
| Same, at a frame | `IsHistory F.TaskRel τ → Continuous τ` | `FrameOver.continuous_of_history` | `pcq` | certified |
| Source topology is the **order** topology on `D` | `[TopologicalSpace D] [OrderTopology D]` explicit binders | binder list of both | `pcq` | certified |
| "so it extends beyond task frames" | stated over bare `R`, no constraint | binder list of the general-layer form | `pcq` | certified |
| "`𝒩_F` **is** the topology that makes worlds continuous paths" | — | — | — | **`not-certified`, and refuted as a characterization — see flags** |

### Part 5 — the footnote recording the superseded subbasis topology

| Manuscript element | Statement | Certifying declaration | Axiom profile | Status |
|---|---|---|---|---|
| The old topology, defined | generated by the cones as a subbasis | `TaskFrame.coneTopology`, `FrameOver.coneTop` | `pcq` | certified |
| The old topology is **finer** | `coneTopology R ≤ nbhdTopology R` given `R w 0 w` (Mathlib order: `≤` means finer) | `TaskFrame.coneTopology_le_nbhdTopology`, `FrameOver.coneTop_le_stateTopology` | `pcq` | certified |
| The old topology is T1 in every task frame | `𝒯_F` T1 under *Limit* + nullity | `TaskFrame.t1Space_coneTopology_of_limit`, `FrameOver.t1Space_coneTop` | `pcq` | certified |
| Its T1-ness does **not** characterize *Limit* | funnel: `𝒯_F` T1 while *Limit* fails | `StateTopology.funnel_t1Space_coneTopology` + `StateTopology.funnel_not_limit` | `pcq pinned:C14` (both) | certified |
| The funnel is a four-state carrier over a dense `D` | `Fin 4`, `[DenselyOrdered ↑D]` | `StateTopology.funnelFrame`, binder lists | `pcq` | certified |
| The funnel's relation is "`w = u`, or `w` low and `u` high, at `x > 0`" | — | `StateTopology.funnelRel` (def) | — | certified |
| `(0)_x = {0, 2, 3}` for every `x > 0` | cone membership computed | `StateTopology.mem_cone_funnelRel` | `pcq` | certified |
| Every singleton is a finite intersection of cones, so `𝒯_F` is discrete there | — | `StateTopology.funnelRel_singleton_eq_biInter_cone`, `StateTopology.funnelRel_discreteTopology_coneTopology` | `pcq` | certified |
| `⋂_{x>0}(0)_x ≠ {0}`: *Limit* fails | — | `StateTopology.funnelRel_not_limit`, `StateTopology.funnel_not_limit` | `pcq pinned:C14` | certified |
| The funnel satisfies *Seriality*, *Compositionality*, *Saturation* | three separate facts | `funnel_serial`, `funnel_compositional`, `funnel_saturation` | `pcq` (each) | certified |
| "T1 inherited by finer topologies" (the *reason* the footnote gives) | — | no such general lemma in the library; the instance is proved directly | — | **`not-certified` as stated — see flags** |

### Part 6 — further results the collection now makes worth stating

| Manuscript element | Statement | Certifying declaration | Axiom profile | Status |
|---|---|---|---|---|
| **Non-Hausdorffness is a frame property, not a choice of topology** | on the two-origin frame `𝒯_F = 𝒩_F`, and neither is Hausdorff | `TwoOrigins.coneTopology_eq_nbhdTopology` + `TwoOrigins.not_t2Space_coneTopology` (+ frame-level `frame_coneTop_eq_stateTopology`, `frame_not_t2Space_coneTop`) | `pcq` (all four) | **`to-promote`** (Gap A; all compiled this round) |
| T1 but not Hausdorff, for `𝒩_F` | the two-origin state space | `TwoOrigins.frame_not_t2Space`, `TwoOrigins.not_t2Space_nbhdTopology` | `pcq` | certified |
| ...as a claim about a **task frame** | the two-origin structure satisfies all four `def:frame` constraints | — (*Saturation* not claimed; not an `IsRegular` instance) | — | **`pending-sibling`** |
| ***Triangle* is sufficient but not necessary** for cone-openness | sufficiency + a frame where it fails yet the topologies agree | `TaskFrame.coneTopology_eq_nbhdTopology_of_triangle` + `TwoOrigins.not_triangle` + `TwoOrigins.coneTopology_eq_nbhdTopology` | `pcq` | certified / **`to-promote`** |
| Cone-openness is exactly the condition for the two topologies to agree | biconditional | `TaskFrame.coneTopology_eq_nbhdTopology_iff` | `pcq` | certified |
| **The two topologies genuinely differ** | `𝒯_F ≠ 𝒩_F` on the hedgehog; indeed `𝒯_F` **strictly** finer | `Hedgehog.coneTopology_ne_nbhdTopology`, `Hedgehog.coneTopology_lt_nbhdTopology` | `pcq` | **`to-promote`** (Gap B; compiled this round) |
| `{c}` is `𝒯_F`-open but not `𝒩_F`-open | the bracketing pair | `Hedgehog.isOpen_coneTopology_singleton_c`; `Hedgehog.not_isOpen_nbhdTopology_singleton_c` | `pcq` | certified / `to-promote` |
| The gap between the two topologies' T1 behaviour is exactly one-way instantaneous pairs | `𝒯_F` T1 + *NoOneWay* (+ reflection, composition) ⇒ *Limit*; the funnel has such a pair | `TaskFrame.limit_of_t1Space_coneTopology`, `StateTopology.funnel_one_way_pair` | `pcq` | certified |
| `𝒩_F` is strictly coarser than the final topology of all histories | `⨆ coinduced ≤ 𝒩_F`, and unequal on the hedgehog | `TaskFrame.finalTopology_le_nbhdTopology`, `Hedgehog.finalTopology_ne_nbhdTopology` | `pcq` | certified |
| Histories need not be `𝒯_F`-continuous even inside the three-constraint class | explicit history | `Hedgehog.not_continuous_coneTopology_history`, `StateTopology.funnel_not_continuous_coneTopology` | `pcq` | certified |
| *sep* can hold while *Limit* fails, so `rev_sep` is one-directional | funnel | `StateTopology.funnel_sep_of_history` | `pcq` | certified |
| Over `ℤ` both topologies are the partition topology of `⇒_0`, and *Limit* ⟺ discrete ⟺ T1 | four results | `TaskFrame.cone_int_one`, `nbhdTopology_isOpen_iff_int`, `limit_int_iff`, `discreteTopology_nbhdTopology_int_iff` | `pcq` | certified |
| On the named real frames both topologies are the Euclidean one | cones are balls | `TaskFrame.nbhdTopology_eq_real`, `TaskFrame.coneTopology_eq_nbhdTopology_real`, `TaskFrame.not_discreteTopology_real` | `pcq` | certified |
| `𝒩_F` is discrete iff every state has a pointwise dwell time | — | `TaskFrame.discreteTopology_nbhdTopology_iff` | `pcq` | certified |
| The cones are a filter base; `𝒩_F` is the finest topology whose neighbourhoods contain cones | — | `TaskFrame.isBasis_cone`, `coneFilter_le_nhds`, `nbhdTopology_le_of_coneFilter_le_nhds`, `nbhdTopology_eq_mkOfNhds` | `pcq` | certified |
| Closed sets of `𝒩_F` are the sets closed under arbitrarily short tasks | — | `TaskFrame.nbhdTopology_isClosed_iff` | `pcq` | certified |
| R0 **without** *Limit* fails in the *Seriality*+*Compositionality* class | the modified hedgehog with an extra state | — (never built in Lean; an explicit Non-Goal of the prior round) | — | **`pending-sibling`** |

## Statements the manuscript would assert that the library does not certify

This is the list the user should hedge, reword, or route to the sibling task. Five items, in descending order of consequence.

1. **"`𝒩_F` is the topology that makes possible worlds continuous paths" — over-claimed, and the library refutes the "the".** What is certified is that every history is `𝒩_F`-continuous (`continuous_nbhdTopology_of_history`) and that `𝒩_F` is *coarser* than the final topology of all histories (`finalTopology_le_nbhdTopology`). `Hedgehog.finalTopology_ne_nbhdTopology` shows that containment is **strict** on a frame satisfying *Seriality*, *Compositionality* and *Limit* — so `𝒩_F` is not the finest topology making worlds continuous, and no characterization of `𝒩_F` in terms of history-continuity is available. **Recommended wording**: "a topology in which every possible world is a continuous path", or the sharp form the library does certify — `𝒩_F` is the finest topology in which every neighbourhood of `w` contains a cone at `w` (`nbhdTopology_le_of_coneFilter_le_nhds`).

2. **"The old topology is T1 for the same reason — T1 is inherited by finer topologies."** The *instance* is certified (`t1Space_coneTopology_of_limit`), but it is proved directly from *Limit* and nullity, not by an inheritance principle, and no "T1 passes to finer topologies" lemma is stated in this library. Either cite the instance and drop the reason, or add the general lemma. Note also that this reason, if given, must use the fineness direction the library proves: `coneTopology ≤ nbhdTopology` in Mathlib's order **means `𝒯_F` is finer**.

3. **Every claim that the two-origin or hedgehog witness is a *task frame*.** Neither claims *Saturation*; neither is an `IsRegular` instance. As the library stands, "there is a task frame that is T1 and not Hausdorff" is **not certified** — only "there is a structure satisfying *Seriality*, *Compositionality* and *Limit* that is T1 and not Hausdorff". `pending-sibling`.

4. **"Without *Limit*, `𝒩_F` need not be R0" (section 3.4's UNVERIFIED claim).** The witness — the hedgehog plus a second special state related to every tip at every positive duration — was never built in Lean and was an explicit Non-Goal of the prior round. The source prose breaks off mid-sentence and never introduces the state `w` it reasons about. `pending-sibling`. The contrasting positive fact (over `ℤ` with symmetric `⇒_0` the partition topology is R0) **is** certified, by the four `*_int*` results.

5. **The paper's R0 formulation versus Mathlib's `R0Space`.** The manuscript defines R0 as `w ∈ cl{u} iff u ∈ cl{w}`; the Lean results assert Mathlib's `R0Space`, which is symmetry of `Specializes`. These agree via `specializes_iff_mem_closure`, but **no bridge lemma is stated in this library**, so a reader checking `app:topology-r0` against `r0Space_nbhdTopology_of_limit` must supply the identification. Cheap to close with a one-line `theorem` or a docstring sentence. The same applies, more mildly, to the paper's `cl{w} = {w}` versus Mathlib's `T1Space`.

Two further notes, not defects:

- **The drafted `app:topology-t1` is weaker than what Lean proves.** The draft quantifies over frames satisfying *Seriality*; `t1Space_nbhdTopology_iff_limit` consumes **nothing**. *Seriality* is needed only to upgrade the library's ⊆-half `Limit` to the paper's equality form. The appendix can say so explicitly, and gains a sharper theorem for free.
- **Assertion "the `def:frame` gloss 'distinct world states are instantaneously separated' becomes literally true"** is interpretive rather than mathematical; the nearest certified content is `t1Space_nbhdTopology_iff_limit` together with `discreteTopology_nbhdTopology_iff`. No action needed beyond not presenting it as a theorem.

## Decisions

- **Deliverables 1 and 2 are re-siting work, not proof work.** Every declaration was compiled against the live library in this round. The implementation plan should treat them as transcription-plus-docstring phases, and the risk budget belongs to the wiring, not the proofs.
- **Do not split `Counterexamples.lean`.** No invariant requires it, the import-weight isolation a split would seek is already in place, and the discoverability motive is better served by ledger rows.
- **Do not rename the `funnel_*` declarations into a `Funnel` namespace.** ~30 renames plus deprecation aliases plus ledger and C14 edits, for symmetry only.
- **Do not rename `nbhdTopology`/`coneTopology`.** Document the symbol correspondence instead. The paper's `𝒯_F` has now changed referent once; the Lean names should not track it.
- **Promote both Gap A and Gap B at the frame level as well as the relation level.** The manuscript speaks about frames; the general-layer names are the wrong register for a citation.
- **State the drafted biconditional as its own declaration** rather than leaving the appendix to cite a theorem whose hypotheses differ from the ones the drafted proof announces.

## Recommendations

Ordered; each is independently shippable and green at its own boundary.

1. **Promote Gap A** into `Counterexamples.lean`'s `TwoOrigins` namespace: `not_triangle`, the four cone-membership lemmas, `isOpen_nbhdTopology_cone`, `coneTopology_eq_nbhdTopology`, `not_t2Space_coneTopology`, plus the two frame-level wrappers. Source: `specs/655_topology_characterizing_limit_nbhd_vs_subbasis/probes/TwoOrigins.lean`, renaming `RTO → rel`, `RTO_refl → rel_refl`, and dropping the `'`-shims for the library's own definitions. Every docstring needs a `Paper:` line (C15) and must cite the manuscript by label or quotable phrase, never by line number.
2. **Close Gap B** in the `Hedgehog` namespace: `p_mem_cone_c`, `not_isOpen_nbhdTopology_singleton_c`, `coneTopology_ne_nbhdTopology`, and the strict `coneTopology_lt_nbhdTopology`.
3. **Add the three missing frame-level declarations** to `StateTopology.lean`'s `FrameOver` section: `isOpen_iff`, `r0Space_stateTopology`, `iInter_cone_eq_singleton`. Consider replacing the anonymous `example` at `:625` with `r0Space_stateTopology`, or keeping both with the `example` demoted to a comment.
4. **Add `TaskFrame.t1Space_nbhdTopology_iff_iInter_cone_of_serial`** — the appendix's `app:topology-t1` exactly as drafted, in one name.
5. **Extend `docs/theorem-index.md`** to citation granularity. At minimum add rows for: the replacement `def:task-topology` (`nbhdTopology_isOpen_iff` / `FrameOver.isOpen_iff`), `app:topology-r0` (`r0Space_stateTopology`), the new continuity lemma (`FrameOver.continuous_of_history`), the equality-form biconditional, `coneTopology_le_nbhdTopology`, `limit_of_t1Space_coneTopology`, `funnel_saturation`, `funnel_one_way_pair`, and every Gap A / Gap B promotion. Use plain `pcq` unless pinning is wanted; pinning requires the paired edit at `scripts/check-module-invariants.sh` ~`:1888` and ~`:2051`.
6. **Add a "Notation and naming" row** to `docs/theorem-index.md` mapping the revised `def:task-topology`'s `𝒯_F` to `TaskFrame.nbhdTopology` / `FrameOver.stateTopology`, and the footnote's superseded topology to `TaskFrame.coneTopology` / `FrameOver.coneTop`. Mirror it in `StateTopology.lean`'s module header and both topology `def` docstrings. **This is the cheapest high-value item in the list.**
7. **Give the collection a front door**: a row or short paragraph in `FormalSystem/README.md` and `docs/reference/API_REFERENCE.md`, and a mention in `docs/ARCHITECTURE.md`. Today the collection is reachable only from `FormalSystem/Semantics/README.md`.
8. **Add the R0 and T1 formulation bridges** (one line each, or a docstring sentence) so the paper's closure-based definitions visibly match Mathlib's `R0Space` / `T1Space`.
9. **Add a minimal `Tests/BimodalTest/Semantics/` witness file** exercising the headline topology declarations, so that the "green over `Tests/BimodalTest`" criterion is not vacuous for this collection. Keep it a leaf, for the same import-weight reason.
10. **Re-read `possible_worlds.tex:1877`** (the formalization claim) once this lands: the topology results now *are* formalized, and the enumerated list should say so.

## Risks & Mitigations

- **Risk: the promotion lands warnings and `--wfail` fails.** `C28` reports `0 warning(s) across 0 file(s)`, so the budget is zero and any warning is fatal. One unused-binder warning was hit while drafting `FrameOver.iInter_cone_eq_singleton` in this round. **Mitigation**: prefix unused binders with `_`; re-run `--wfail` per phase, not only at the end.
- **Risk: a new declaration breaks C15's round trip.** Every theorem-index row requires a `Paper:` line at the declaration. The probe docstrings carry none. **Mitigation**: write `Paper:` lines as part of the promotion, using `—` plus a one-clause reason for the formalization-native results (`not_triangle`, the cone-membership lemmas, the two inequalities), following `TwoOrigins.frame_not_t2Space`'s existing pattern.
- **Risk: import weight regresses.** A topology module reaching `Semantics.lean` has caused a `Preorder ℤ` diamond twice. **Mitigation**: assert after every phase that `grep -rn "import FormalSystem.Semantics.StateTopology" FormalSystem/` returns only `Counterexamples.lean`, and that `FormalSystem.lean` is regenerated with `lake exe mk_all --lib FormalSystem` rather than hand-edited (C33 checks byte-currency).
- **Risk: renaming breaks downstream citations.** Mitigated by the decision not to rename. If any rename is nonetheless adopted, `@[deprecated (since := "...")] alias` must accompany it, and C17's base-name census must be re-read — two declarations sharing a last dot-segment mask each other in the dead-declaration report.
- **Risk: the support table drifts from the manuscript.** The user is rewriting the appendix independently. **Mitigation**: the table above is keyed by label and quotable phrase, not by line number, so it survives manuscript edits; the anchors `def:task-topology`, `app:topology-t1`, `app:topology-r0` are all recorded LIVE-UNPINNED in `docs/reference/paper-definitions-of-record.md:2084-2089` and will continue to resolve under C15.
- **Risk: concurrent task collision.** The sibling open-questions task and the frame-constraints audit task both touch these two modules. **Mitigation**: the dispatch already forbids concurrency; nothing in this round changes that.

## Tactic Survey Results

Not applicable as a search exercise — no proof goal in this round required tactic discovery. Every result was either already compiled in the live tree or transplanted verbatim from a sorry-free probe, and all four `lean_run_code` batches succeeded on first or second attempt. Recorded for completeness:

| Goal | Tactic | Result | Premises/Config |
|---|---|---|---|
| Gap A block (8 declarations) | verbatim probe tactics (`cases`/`refine`/`linarith`/`abs_sub_le`) | success | unchanged from `probes/TwoOrigins.lean` |
| `Hedgehog.coneTopology_ne_nbhdTopology` | `intro` + `heq ▸` rewrite | success | `isOpen_coneTopology_singleton_c` |
| `Hedgehog.coneTopology_lt_nbhdTopology` | `lt_of_le_of_ne` | success on 2nd attempt | first attempt had the `TopologicalSpace` order backwards |
| `FrameOver.isOpen_iff` | `Iff.rfl` | success | — |
| `FrameOver.r0Space_stateTopology` | direct term | success | `r0Space_nbhdTopology_of_limit` |
| `t1Space_nbhdTopology_iff_iInter_cone_of_serial` | `rw [limit_eq_iff]` + `refine` | success | `nullity_of_serial_limit`, `mem_cone_self` |

## Context Extension Recommendations

- **Topic**: Mathlib's `TopologicalSpace` lattice order direction.
  **Gap**: `.claude/context/project/lean4/` carries no note that `t₁ ≤ t₂` means `t₁` is the **finer** topology. This convention is counter-intuitive, is load-bearing for every fineness claim in this collection, and cost one failed compile in this round.
  **Recommendation**: add a short entry to the Lean domain context (or to `StateTopology.lean`'s module header, which already discusses fineness) stating the convention with the `coneTopology_le_nbhdTopology` example.

- **Topic**: The C15 theorem-index round trip.
  **Gap**: The requirement that every ledger row's declaration carry a `Paper:` line in its own `/--` docstring is documented only inside `scripts/check-module-invariants.sh`'s comment block. Any task adding ledger rows must rediscover it.
  **Recommendation**: record the row schema and the `Paper:`-line obligation in `docs/reference/docstring-standard.md` or `docs/theorem-index.md`'s "How to read a row" section.

## Appendix

**Transplant sources.** The three probe files in `specs/658_consolidate_state_topology_collection_for_appendix/probes/` are the compiled blocks, verbatim as verified: `GapA_TwoOrigins.lean` (10 declarations including the two frame-level wrappers), `GapB_Hedgehog.lean` (4 declarations), `FrameLevelAdditions.lean` (4 declarations). Each was re-run through `lean_run_code` **exactly as written to disk**, after docstrings and the `_x` binder fix were added, and each produced zero errors and zero warnings. They carry no `Paper:` lines; the implementation must add those.

**Verification method.** Four `lean_run_code` batches against the live library, each importing `FormalSystem.Semantics.StateTopology.Counterexamples` and closing with `#print axioms`: (1) the full Gap A block, (2) the Gap B block, (3) the three proposed `FrameOver` additions, (4) the proposed equality-form biconditional. Two further batches gathered `#print axioms` for all 29 declarations of `StateTopology.lean` and all 39 checked declarations of `Counterexamples.lean`. One frame-level mechanics check confirmed that `unfold FrameOver.coneTop FrameOver.stateTopology; rw [frame_taskRel_eq]` discharges the wrapper goals.

**Searches used.** No external Mathlib search (LeanSearch / Loogle / LeanFinder / state search) was needed: the collection is self-contained and the probe supplied every proof term. `grep` over `FormalSystem/`, `Tests/`, `docs/` and `scripts/` supplied the wiring facts.

**Gate baseline.** `bash scripts/check-module-invariants.sh --no-build` → `ALL CHECKS PASSED` (C19 docstring coverage 94.01% against a 90% floor; C28 zero warnings; C33 root byte-current). The build half (C1/C2/C6/C16/C24/C25) was skipped in this pass; that the `lean_run_code` batches resolved every import is independent evidence the library's build artefacts are current.

**Key file references.**
- `FormalSystem/Semantics/StateTopology.lean` — general layer `:97-539`, frame layer `:541-629`, anonymous R0 `example` `:625`
- `FormalSystem/Semantics/StateTopology/Counterexamples.lean` — ℤ layer `:91-146`, funnel `:148-604`, `TwoOrigins` `:618-845`, `Hedgehog` `:863-1218`
- `specs/655_topology_characterizing_limit_nbhd_vs_subbasis/probes/TwoOrigins.lean` — Gap A source, `:260-395`
- `docs/theorem-index.md` — legend `:11-18`, notation table `:31+`, topology rows `:182-184, 187-188`
- `docs/reference/paper-definitions-of-record.md` — topology anchors `:2084-2089` (all LIVE-UNPINNED)
- `scripts/check-module-invariants.sh` — C14 pinning pair `~:1888` / `~:2051`, C15 row regex `:2196-2198`
- `FormalSystem.lean:497-498` — the only imports of the two modules
