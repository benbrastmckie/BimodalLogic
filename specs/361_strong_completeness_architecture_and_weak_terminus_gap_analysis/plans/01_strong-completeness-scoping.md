# Implementation Plan: Task #361

- **Task**: 361 - strong_completeness_architecture_and_weak_terminus_gap_analysis
- **Status**: [IMPLEMENTING]
- **Effort**: 6.5 hours
- **Dependencies**: None
- **Research Inputs**: specs/361_strong_completeness_architecture_and_weak_terminus_gap_analysis/reports/01_strong-completeness-architecture-gap-analysis.md
- **Artifacts**: plans/01_strong-completeness-scoping.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

This is an ANALYSIS / SCOPING task. It closes no proof obligations and writes no Lean code into
the tree. Its deliverables are exactly three: (a) design/scoping documents under
`specs/361_.../design/`, (b) a sub-task decomposition with a dependency graph, and (c) spawned
tasks created in `specs/state.json` + `specs/TODO.md`. Phases 1-4 write documents; Phase 5
creates the tasks; Phase 6 records the staleness corrections where the stale claims actually
live. Every proposed Lean definition lives inside a design document as a fenced code block —
never as a tree edit.

Definition of done: four design documents exist under `specs/361_.../design/`, five new task
entries exist in `specs/state.json` with correct `dependencies[]` edges and accurate
`file_scope`, `specs/TODO.md` is regenerated and shows them, and the stale Dense-weak-terminus
claims in `specs/ROADMAP.md` and in the task 170 / task 169 descriptions are corrected.

### STANDING CONSTRAINT (applies to EVERY phase, without exception)

A separate session owns task 418 and holds the advisory build lock
`.lake/.task-418-build.lock`; its acceptance gate is a full `lake build` + `lake build
BimodalTest`. Therefore, for the entire duration of this plan:

- **MUST NOT** run `lake build`, `lake clean`, `lake exe`, or the `lean_build` MCP tool.
- **MUST NOT** create, edit, or delete ANY file under `FormalSystem/` or `Tests/` — not even a
  comment, not even whitespace.
- **PERMITTED**: read-only `lean-lsp` queries (`lean_goal`, `lean_hover_info`, `lean_verify`,
  `lean_local_search`, `lean_declaration_file`, `lean_diagnostic_messages`), and `Read` / `Grep`
  / `Glob` over `FormalSystem/` and `Tests/`.
- **PERMITTED writes**: `specs/**` only (this task's `design/` and `summaries/` subdirectories,
  `specs/state.json`, `specs/TODO.md`, `specs/ROADMAP.md`).

Every phase's verification criteria below are checkable **without running `lake build`**. If a
phase appears to need a build to verify, that is a signal the phase has drifted out of scope —
stop and record the drift rather than taking the lock.

### Research Integration

The research report is authoritative and must not be re-derived. Four findings drive this plan:

1. **The task brief's weak-terminus description is materially stale.** `completeness_dense`
   (BXCanonical/Completeness.lean:255) is machine-verified sorry-free today (axioms exactly
   `propext, Classical.choice, Quot.sound`), so the Dense weak terminus is already satisfied and
   task 170 is already substantively closed. `completeness` (:196) has exactly ONE reachable
   sorry — `WeakCanonical.countermodel_discrete`, `WeakCanonical/Transfer.lean:1242` — not the
   three the brief lists. Phase 6 records this correction where the stale claims live.
2. **The BXCanonical chronicle machinery does NOT extend to a model-existence theorem.** Its
   truth lemma is architecturally tied to finite root closures (`Finset subformulaClosure` /
   `deferralClosure`), and unrestricted temporal coherence needs bounded F-nesting depth, which
   infinite premise sets destroy. No chronicle-based model existence is planned.
3. **Recommended route for Base/Dense strong completeness**: prove semantic compactness by an
   ultraproduct argument over a shift-set representation of task models, then obtain strong
   completeness as compactness + weak completeness via the already-proved, frame-class-generic
   `derivable_foldr_imp_iff` (StrongCompleteness.lean:222). This is **gated**: a cheap
   representation-theorem feasibility task must land first, and the expensive ultraproduct work
   is spawned only if that gate returns positive.
4. **The Base-to-Discrete MCS transfer route proposed in Transfer.lean's own docstring is
   REFUTED** by an explicit lexicographic-order witness (`ℤ ×ₗ ℤ` validates `□U(⊤,⊥)` while
   falsifying `Axiom.z1`). A non-Archimedean discrete carrier (`ℚ ×ₗ ℤ`) is recommended instead.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

`specs/ROADMAP.md` exists and its completeness table (lines ~43-47) is one of the two homes of
the stale claims corrected in Phase 6. The rows this plan touches:

- `| Dense | open — task 170 | ... |` — stale; Dense weak completeness is verified green.
- `| Base | open — task 169 | ... |` — accurate in verdict, stale in the number of gaps.
- The `Genuine strong (Set Formula)` column for Base and Dense currently reads "OPEN question —
  compactness research, task 361"; after this task it points at the spawned feasibility gate.

This plan does not restructure the roadmap; Phase 6 makes minimal, targeted corrections only.

## Goals & Non-Goals

**Goals**:
- Land the set-based consequence layer design (finitary `SetDerivable`, per-class
  `SetSemanticConsequence_X`, basic lemmas, the compactness-to-strong-completeness derivation)
  as a specs/ document precise enough that an implementer can transcribe it.
- Land the Base/Dense compactness feasibility verdict, the shift-set representation theorem, the
  ultraproduct route, its named risks, and the Discrete non-compactness witness sketch.
- Land the verified weak-terminus status: the exact live-sorry inventory, the corrections to the
  brief, and the Base route analysis (route (i) refuted, route (iii) blocked, route (ii)
  recommended).
- Produce a spawn manifest naming, for each task to be created, its title, `task_type`,
  `description`, `dependencies[]`, and `file_scope[]`.
- Create exactly the gated spawn set (five tasks) in `specs/state.json` + `specs/TODO.md`, with
  the dependency graph encoded as `dependencies[]` edges.
- Correct the stale Dense/Base claims in `specs/ROADMAP.md` and in the task 170 / 169
  descriptions so the staleness does not propagate.

**Non-Goals**:
- Writing, editing, or deleting any file under `FormalSystem/` or `Tests/`.
- Running any build (`lake build`, `lake clean`, `lean_build`).
- Closing `WeakCanonical.countermodel_discrete` or any other sorry.
- Spawning the expensive ultraproduct branch (S2/S3/S4/S5-Base/S5-Dense). Those are recorded in
  the decomposition document as *authorized only if the feasibility gate returns positive*, and
  are deliberately NOT created as tasks by this plan.
- Re-deriving the research report's findings. The report is the input, not a starting point for
  re-investigation.
- Marking task 170 `[COMPLETED]`. That requires a clean-build `#print axioms` re-verification by
  whoever holds the build lock next, which this task may not do. Phase 6 records the finding and
  updates the description; the status transition is left to a build-lock holder.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Concurrent session (task 418) writes `specs/state.json` between our read and write, clobbering its edits or ours | H | M | Every `state.json` mutation uses a single atomic read-modify-write: `jq ... specs/state.json > specs/tmp/state.json && mv specs/tmp/state.json specs/state.json`. Never hold a parsed copy across tool calls. Re-read `next_project_number` immediately before each allocation. After each write, re-run `jq empty specs/state.json` and confirm task 418's entry is still intact. |
| Task numbers allocated in Phase 5 are not known when the decomposition doc is written in Phase 4 | M | H | Phase 4 writes the manifest with symbolic IDs (`N1`..`N5`); Phase 5 substitutes real allocated numbers and back-fills them into the Phase 4 document as a closing step. Dependency edges between newly created tasks are written only after all five numbers are allocated. |
| Inaccurate `file_scope` on a spawned task defeats the orchestrator's admission gate and lets conflicting tasks run in parallel | H | M | Each spawned task's `file_scope` is stated as a Scope Hypothesis in Phase 4 and cross-checked in Phase 5 against existing tasks 169/170/362/408/418 for intended vs. accidental overlap. Where a new file is proposed but does not yet exist, the scope entry is still declared (the gate matches on path strings, not on existence) and flagged in the task description as implementer-confirmable. |
| Temptation to "just check" a proposed Lean definition elaborates, taking the build lock | H | M | Standing constraint above; all phase verification criteria are grep/read/jq-based. Read-only `lean_verify` / `lean_hover_info` are the only Lean tooling permitted and they consume existing oleans. |
| ROADMAP.md edited concurrently by another session | M | L | Phase 6 makes line-targeted `Edit` calls against freshly-read content, not a whole-file rewrite. |
| Design documents drift from the research report and introduce unverified claims | M | M | Documents cite the report by section (`§2.1`, `§3.3`, `§4.2`) and reproduce its Lean blocks verbatim. Any new claim must be marked `[UNVERIFIED]` inline. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2, 3 | -- |
| 2 | 4 | 1, 2, 3 |
| 3 | 5 | 4 |
| 4 | 6 | 5 |

Phases within the same wave can execute in parallel. Phases 1, 2, and 3 write three disjoint
files and share no state, so they are genuinely parallelizable; they are also safe to run
sequentially.

---

### Phase 1: Set-based consequence layer design document [COMPLETED]

**Goal**: Write `design/01_set-consequence-layer.md` — the transcribable specification of the
set-based layer, precise enough that the spawned S0 task can implement it without re-reading the
research report.

**Tasks**:
- [ ] Create `specs/361_strong_completeness_architecture_and_weak_terminus_gap_analysis/design/`
      (lazy creation; do not pre-create `summaries/`).
- [ ] Write the module header: proposed module path `FormalSystem/Metalogic/SetConsequence.lean`,
      its imports, and the fact that `StrongCompleteness.lean` is the intended consumer.
- [ ] Reproduce, verbatim from report §2.1, the `SetDerivable` definition, together with the note
      that its shape deliberately matches `SetConsistent` (`Core/MaximalConsistent.lean:96`) so
      the two compose without an adapter.
- [ ] Reproduce, verbatim from report §2.2, all four per-class definitions
      (`SetSemanticConsequenceBase`, `...Dense`, `...Discrete`, `...DedekindDense`), each
      annotated with the `Validity.lean` line number of the binder list it mirrors (`valid` :79,
      `ValidDense` :169, `ValidDiscrete` :187, `ValidDedekindDense` :276).
- [ ] Reproduce, verbatim from report §2.3, the basic lemmas: `setDerivable_mono`,
      `setSemanticConsequenceBase_mono` (and the note that the three siblings are one-line binder
      permutations), `setDerivable_iff_exists_finite`, `setDerivable_of_derivable`,
      `derivable_of_setDerivable_contextToSet`, `setDerivable_of_mem`, and
      `not_setConsistent_of_setDerivable_bot`.
- [ ] Reproduce, verbatim from report §2.4, `StrongCompletenessDense`, `CompactDense`,
      `strongCompletenessDense_of_compact`, `SatisfiableDenseSet`, and `ModelExistenceDense`,
      with the note that `derivable_foldr_imp_iff` (StrongCompleteness.lean:222) is already
      proved and already generic in `fc`.
- [ ] Add an "Acceptance criteria for the implementing task" section: zero sorries expected; the
      module must not import anything from `BXCanonical/`; the four per-class definitions must be
      byte-comparable to their `Validity.lean` binder lists with only the premise hypothesis
      inserted.
- [ ] Add a "Not in this layer" section recording that `SetSemanticConsequenceDedekind` (against
      `ValidDedekind`, :241, no `DenselyOrdered`) can be added by the same recipe but is not the
      soundness target and is not needed by the programme.
- [ ] Add the standing-constraint banner (no builds, no `FormalSystem/` edits) at the top of the
      document so the downstream implementer inherits it only if the lock is still held.

**Timing**: 1 hour

**Depends on**: none

**Verification Tier**: prose

**Verification**:
- `specs/361_.../design/01_set-consequence-layer.md` exists and is non-empty.
- `grep -c '^```lean' design/01_set-consequence-layer.md` returns at least 4 (definitions,
  lemmas, strong-completeness statement, model-existence).
- `grep -E 'SetDerivable|SetSemanticConsequenceBase|SetSemanticConsequenceDense|SetSemanticConsequenceDiscrete|SetSemanticConsequenceDedekindDense|StrongCompletenessDense|CompactDense|ModelExistenceDense'`
  each return at least one hit.
- No file under `FormalSystem/` or `Tests/` appears in `git status --short`.

---

### Phase 2: Compactness feasibility, route, and Discrete non-compactness witness [COMPLETED]

**Goal**: Write `design/02_compactness-route.md` — the Base/Dense strong-completeness feasibility
verdict, the recommended route with its gate, its named risks, and the negative half (the
machine-checkable Discrete non-compactness witness).

**Tasks**:
- [ ] Separate and state the two questions the research report insists be kept apart: (Q1)
      mathematical — is `⊨_Base` / `⊨_Dense` compact? (Q2) architectural — does the BXCanonical
      chronicle machinery deliver model existence for arbitrary `SetConsistent` sets?
- [ ] Record the **Q2 verdict: NO**, with the tree's own documented reason quoted verbatim from
      `Bundle/TemporalCoherence.lean:293-298` (bounded F-nesting depth is load-bearing for the
      chain construction and is exactly what an infinite premise set destroys), plus the
      root-relative hypotheses of
      `fully_restricted_parametric_completeness_from_neg_membership`
      (`Algebraic/RestrictedParametricTruthLemma.lean:417`) and the `Finset` return types of
      `subformulaClosure` (`Syntax/SubformulaClosure/Closure.lean:36`) and `deferralClosure`
      (`.../TemporalFormulas.lean:276`). State explicitly that no chronicle-based model-existence
      work is to be planned or spawned.
- [ ] Record the **Q1 verdict: likely-but-unproved**, with the supporting argument from report
      §3.3: `TruthAt` never mentions `TaskRel`, `respects_task`, or `convex`; every binder of
      `valid` and `ValidDense` is first-order over the two-sorted signature
      `⟨Ω, D; <, +, 0, sh, (A_p)⟩`; and the two provably non-compact classes are exactly the two
      carrying a non-elementary binder (`IsSuccArchimedean`/`IsPredArchimedean`; the lub `Prop`).
- [ ] State the shift-set representation theorem in both directions (report §3.3), as a fenced
      block, including the reverse construction using `WorldHistory.timeShift` and
      `TimeShift.time_shift_preserves_truth`.
- [ ] State the four-step Lean route (representation theorem -> bespoke ultraproduct of shift
      sets over an ultrafilter on `{L : List Formula // ∀ ψ ∈ L, ψ ∈ Γ}` -> Łoś lemma for
      `TruthAt` by induction on `Formula`, six cases -> `ModelExistence*` hence `Compact*` hence
      strong completeness), and record why formalizing the standard translation into Mathlib's
      single-sorted `FirstOrder.Language` was rejected.
- [ ] Reproduce the four named risks from report §3.4 with their Mathlib coordinates: the
      dependent-ultraproduct-of-carriers problem (`Order/Filter/FilterProduct.lean:92` gives
      `LinearOrder β*` only for the non-dependent `Filter.Germ`; `Order/Filter/Germ/Basic.lean:100`
      `Filter.Product ε` has no ordered-group instances), the `box` case of Łoś, `Type` vs
      `Type*` (`Validity.lean:77`), and the honest-uncertainty statement.
- [ ] Write the **GATING RULE** as its own section, in imperative form: the representation
      theorem is a cheap feasibility gate; if it fails, Route B is refuted and the whole
      ultraproduct branch is cancelled. The expensive branch MUST NOT be spawned before the gate
      returns positive. Name the exact evidence that constitutes "gate passed" (a sorry-free
      statement of both directions of the representation theorem, verified by `#print axioms`
      showing no `sorryAx`).
- [ ] Write the Discrete non-compactness witness section from report §4.3: `archWitness`,
      `archWitness_finitely_satisfiable`, `archWitness_not_satisfiable`,
      `discrete_consequence_not_compact`, plus the load-bearing observation that
      `Formula.next φ = Formula.untl φ Formula.bot` (`Syntax/Formula.lean:490`) is a genuine
      next-step operator, immediate from the `untl` clause of `TruthAt`.
- [ ] Record that an analogous Dedekind witness is explicitly NOT recommended here — it belongs
      to task 408 and the class's non-compactness is already established.

**Timing**: 1.5 hours

**Depends on**: none

**Verification Tier**: prose

**Verification**:
- `design/02_compactness-route.md` exists and contains sections titled (or clearly equivalent to)
  "Q1", "Q2", "Representation theorem", "Route", "Risks", "Gating rule", "Discrete
  non-compactness witness".
- The gating rule section states an explicit cancel condition and an explicit "gate passed"
  evidence standard.
- `grep -c 'TemporalCoherence.lean' design/02_compactness-route.md` >= 1 (the Q2 blocker is cited
  to its file).
- No file under `FormalSystem/` or `Tests/` appears in `git status --short`.

---

### Phase 3: Verified weak-terminus status and Base route analysis [COMPLETED]

**Goal**: Write `design/03_weak-terminus-status.md` — the machine-verified current state of both
weak termini, the itemized corrections to the task brief, and the Base route analysis.

**Tasks**:
- [ ] Reproduce the machine-checked axiom-set table from report §1.1: `completeness_dense`
      (Completeness.lean:255) = `[propext, Classical.choice, Quot.sound]`, sorry-free;
      `completeness_discrete` (:296) sorry-free; `completeness` (:196) =
      `[propext, sorryAx, Classical.choice, Quot.sound]`, one sorry. Record that the first and
      third were obtained via `lean_verify` against current oleans in the research session and
      that the import cone was unmodified at that time.
- [ ] Reproduce the live-sorry inventory from report §1.2: `Transfer.lean:1242`
      (`countermodel_discrete`, sole source reachable from `completeness`),
      `RealModel/ShuffleReal.lean:201` (`doets_lemma_1_5`, Reynolds/Dedekind axis, owned by task
      408, on neither terminus tracked here), and the archived `Kamp/Boneyard/*` sub-tree.
- [ ] Reproduce the four-row brief-correction table from report §1.3 verbatim, and state the
      consequence explicitly: the Dense weak terminus is ALREADY SATISFIED; `completeness` has
      EXACTLY ONE reachable sorry, not three.
- [ ] Write the Dense recommendation: no Lean work to do; the remaining action is an independent
      clean-build `#print axioms completeness_dense` re-verification by whoever holds the build
      lock next, then a `[COMPLETED]` transition with a completion summary recording the verified
      axiom set. State clearly that no implementation agent should be dispatched at task 170.
- [ ] Write the Base route analysis: quote the `countermodel_discrete` obligation
      (Transfer.lean:1225-1242) and note what its conclusion does NOT demand (no `ℤ`, no
      discreteness, no Archimedean-ness — any nontrivial ordered abelian group will do).
- [ ] Record **route (i) as REFUTED** with the full `ℤ ×ₗ ℤ` / `ℚ ×ₗ ℤ` lexicographic witness from
      report §4.2: every point has an immediate successor so `□U(⊤,⊥)` holds; `G(Gp → p)` holds
      at `(0,0)`; `FGp` holds at `(0,0)` but `Gp` fails there; hence `z1 p` is false, so a
      Base-MCS containing `□U(⊤,⊥)` need not be Discrete-consistent and no Base-to-Discrete MCS
      transfer lemma can exist. Note that Transfer.lean:1239-1241's two docstring sentences
      proposing this route must be corrected as part of the fix.
- [ ] Record **route (iii) as BLOCKED** and name where: `h_box_dense` feeds
      `box_dense_gives_density` (ChronicleToCountermodelBasic.lean:435), which licenses the
      Cantor isomorphism with `ℚ` used by `rootedCantorFmcsDense` (:500-506) and threaded through
      the three `cantor_bfmcs_dense_restricted_*` proofs (:629, :682, :757). With `□U(⊤,⊥) ∈ A`
      the chronicle order is discrete and the `ℚ` isomorphism is unavailable.
- [ ] Record **route (ii) as RECOMMENDED**: `succ_cofinal` was only ever needed to force the
      chronicle into `ℤ`, i.e. to make it Archimedean; `FrameClass.Base` imposes no
      Archimedean-ness (`valid`, Validity.lean:79), so the "ℤ+ℤ counterexample" that killed the
      old BX pipeline is not a counterexample here — it is the intended carrier. State the
      `ℚ ×ₗ ℤ` properties (ordered abelian group as lex product; discretely ordered with
      successor `(q,n) ↦ (q,n+1)` so `U(⊤,⊥)` holds everywhere; non-Archimedean so `z1` is not
      required; countable so the Cantor/chronicle bookkeeping transfers).
- [ ] Record the two open risks the report names for this route: the missing
      `IsOrderedAddMonoid (α ×ₗ β)` instance under `Mathlib/Algebra/Order/` (short supply if
      absent — translation-invariance of the lex order is a two-case argument, but verify
      instance availability before committing), and whether the chronicle's block order can
      always be densified without disturbing MCS-chain coherence (report §6 item 2).

**Timing**: 1 hour

**Depends on**: none

**Verification Tier**: prose

**Scope Hypothesis**: This phase asserts that `completeness` has **exactly one** reachable sorry
(`Transfer.lean:1242`) and that there are **exactly three** live `sorry` sites outside
`Boneyard/`. Both counts come from the research report's tree-wide scan, not from a fresh scan in
this phase. The implementer MUST confirm them with a read-only re-scan before writing them as
facts: `grep -rn --include='*.lean' -E '\bsorry\b' FormalSystem/ | grep -v Boneyard` for the
site count, and read-only `lean_verify FormalSystem.Metalogic.BXCanonical.completeness` for the
axiom set. If either count differs, write the observed value and flag the divergence in the
document rather than reproducing the report's number.

**Verification**:
- `design/03_weak-terminus-status.md` exists and contains the axiom-set table, the live-sorry
  inventory, the four-row correction table, and three clearly-labelled route verdicts
  (REFUTED / BLOCKED / RECOMMENDED).
- The re-scan required by the Scope Hypothesis was run and its raw output is quoted in the
  document (or the divergence is flagged).
- No file under `FormalSystem/` or `Tests/` appears in `git status --short`.

---

### Phase 4: Sub-task decomposition, dependency graph, and spawn manifest [COMPLETED]

**Goal**: Write `design/04_subtask-decomposition.md` — the full 14-item decomposition, the
dependency graph, the gated spawn policy, and a machine-followable spawn manifest giving exact
field values for each of the five tasks Phase 5 will create.

**Tasks**:
- [ ] Reproduce the 14-item table from report §5.1 (`T170-verify`, `B0`, `B1`, `B2`, `B3`,
      `B4` = task 169, `S0`, `S1`, `S2`, `S3`, `S4`, `S5-Dense`, `S5-Base`, `D1`) with titles,
      scopes, and estimates.
- [ ] Reproduce the dependency graph from report §5.2, including the two readings the report
      calls out explicitly: `S5-Base` depends on both `S4` and `B4`; `S5-Dense` depends on `S4`
      and `S0` only and does **not** wait on the Base weak terminus, which makes Dense the
      natural first strong-completeness target.
- [ ] Write the **gated spawn policy** section: exactly five tasks are created now
      (`B0+B1`, `B2+B3`, `S0`, `S1`, `D1`); `S2`, `S3`, `S4`, `S5-Dense`, and `S5-Base` are
      deliberately NOT created and are authorized only after the `S1` feasibility gate returns
      positive per Phase 2's gating rule. State the reason verbatim from report §5.3: spawning
      them now would commit plan budget to a branch `S1` can refute in one run.
- [ ] Write the **spawn manifest** as a table with one row per task to be created, columns:
      symbolic ID, title, `task_type`, `topic`, `dependencies[]`, `file_scope[]`, and a pointer
      to the full `description` text held in a subsection below. The five rows:

  | ID | Title | task_type | topic | dependencies | file_scope |
  |----|-------|-----------|-------|--------------|------------|
  | N1 | Correct Transfer.lean route guidance and probe the non-Archimedean discrete carrier | lean4 | strong_completeness | `[361]` | `["FormalSystem/Metalogic/WeakCanonical/Transfer.lean", "FormalSystem/Metalogic/BXCanonical/DiscreteCarrierProbe.lean"]` |
  | N2 | Build the discrete chronicle over the non-Archimedean block carrier with restricted coherence | lean4 | strong_completeness | `[N1]` | `["FormalSystem/Metalogic/BXCanonical/Chronicle/"]` |
  | N3 | Land the set-based consequence layer (SetDerivable and per-class SetSemanticConsequence) | lean4 | strong_completeness | `[361]` | `["FormalSystem/Metalogic/SetConsequence.lean", "FormalSystem/Metalogic/StrongCompleteness.lean"]` |
  | N4 | Prove the shift-set representation theorem for task models (compactness feasibility gate) | lean4 | strong_completeness | `[361]` | `["FormalSystem/Semantics/ShiftSet.lean"]` |
  | N5 | Machine-check the Discrete non-compactness witness | lean4 | strong_completeness | `[361, N3]` | `["FormalSystem/Metalogic/DiscreteNonCompactness.lean"]` |

- [ ] Write, for each of the five, a full `description` subsection sized for a task entry. Each
      description MUST: state the deliverable concretely; cite the governing design document by
      path and section; carry the two standing warnings where they apply (N4's description must
      state that it is the GATE for the whole ultraproduct branch and that S2-S5 are not
      authorized until it lands sorry-free; N1's description must state that route (i) is refuted
      and must not be re-attempted); and name the read-only verification the task's own acceptance
      uses.
- [ ] Add a **file_scope rationale** subsection recording, per row, which existing tasks the scope
      intentionally overlaps and therefore serializes against: `N2` overlaps tasks 169 and 170
      (`BXCanonical/Chronicle/`) — intended; `N3` overlaps task 362 (`StrongCompleteness.lean`) —
      intended; `N1`, `N4`, `N5` overlap nothing currently in flight. Record explicitly that
      tasks 418 (`Decidability/Tableau.lean`, `Tests/`) and 408 (Dedekind/`ShuffleReal.lean`) are
      NOT overlapped by any spawned scope.
- [ ] Add a **post-spawn edits** subsection listing the mutations to EXISTING tasks that Phase 6
      must make: task 169's `dependencies` gains the allocated `N2` number; task 170's
      description is corrected; the ROADMAP completeness-table rows are corrected.
- [ ] Leave the symbolic IDs `N1`..`N5` in place. Phase 5 substitutes the allocated numbers and
      back-fills this document.

**Timing**: 1 hour

**Depends on**: 1, 2, 3

**Verification Tier**: prose

**Scope Hypothesis**: This phase asserts **five** tasks to create and asserts specific
`file_scope` path lists, three of which name files that do not yet exist
(`FormalSystem/Metalogic/SetConsequence.lean`, `FormalSystem/Semantics/ShiftSet.lean`,
`FormalSystem/Metalogic/DiscreteNonCompactness.lean`,
`FormalSystem/Metalogic/BXCanonical/DiscreteCarrierProbe.lean`). Confirm at implementation time
with `ls` / `git ls-files` that (a) `Transfer.lean` and `BXCanonical/Chronicle/` exist as
written, and (b) the four proposed new paths do NOT already exist under a different name — if a
matching module already exists, use its real path instead and record the substitution. The
non-existence of a proposed new path is expected and is NOT a reason to drop it from
`file_scope`: the admission gate matches on path strings, not on file existence.

**Verification**:
- `design/04_subtask-decomposition.md` exists and contains the 14-item table, the dependency
  graph, the gated spawn policy, the five-row spawn manifest, five `description` subsections, the
  file_scope rationale, and the post-spawn edits list.
- The document states in plain language that `S2`, `S3`, `S4`, `S5-Dense`, `S5-Base` are NOT
  spawned by this task.
- `ls FormalSystem/Metalogic/WeakCanonical/Transfer.lean FormalSystem/Metalogic/BXCanonical/Chronicle/`
  succeeds (read-only existence check for the two scopes that name existing paths).
- No file under `FormalSystem/` or `Tests/` appears in `git status --short`.

---

### Phase 5: Create the five spawned tasks in state.json and TODO.md [NOT STARTED]

**Goal**: Create exactly the five manifest tasks as real entries in `specs/state.json`, encode
the dependency edges, regenerate `specs/TODO.md`, and back-fill the allocated numbers into the
Phase 4 document.

**Task-creation mechanism (exact)**: there is no single `create-task.sh`. The project's
task-creation path is the `/task` command's Create Task Mode, steps 6-7, executed directly:

1. Read the current allocation point:
   ```bash
   next_num=$(jq -r '.next_project_number' specs/state.json)
   ```
2. Insert the entry and bump the counter in ONE atomic read-modify-write (repeat per task):
   ```bash
   mkdir -p specs/tmp
   jq --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
      --arg desc "$description" \
      --arg name "$slug" \
      --argjson num "$next_num" \
      --argjson deps "$dependencies_json" \
      --argjson scope "$file_scope_json" \
      '.next_project_number = ($num + 1) |
       .active_projects = [{
         "project_number": $num,
         "project_name": $name,
         "status": "not_started",
         "task_type": "lean4",
         "topic": "strong_completeness",
         "description": $desc,
         "effort": "high",
         "dependencies": $deps,
         "file_scope": $scope,
         "created": $ts,
         "last_updated": $ts
       }] + .active_projects' \
      specs/state.json > specs/tmp/state.json && mv specs/tmp/state.json specs/state.json
   ```
3. Register the topic (idempotent), once:
   ```bash
   bash .claude/scripts/manage-topics.sh set "$num" strong_completeness
   ```
4. Regenerate the user-facing view, once, after all five entries exist:
   ```bash
   bash .claude/scripts/generate-todo.sh
   ```

`specs/state.json` is machine truth; `specs/TODO.md` is generated from it and MUST NOT be
hand-edited.

**Tasks**:
- [ ] Re-read `next_project_number` immediately before the first allocation (it is 420 as of
      planning time, but a concurrent session may have advanced it).
- [ ] Create N1, N2, N3, N4, N5 in that order, one atomic `jq` write each, using the exact field
      values from the Phase 4 manifest. Each write is followed by `jq empty specs/state.json` to
      confirm the file is still valid JSON.
- [ ] Encode the intra-spawn dependency edges once all five numbers are allocated: N2's
      `dependencies` becomes `[<N1>]`; N5's becomes `[361, <N3>]`. (N1, N3, N4 depend on 361
      only and can be written correctly at creation time.)
- [ ] Verify no dangling edges: every integer appearing in any new task's `dependencies` resolves
      to an existing `project_number` in `active_projects` or in `specs/archive/state.json`.
- [ ] Confirm task 418's and task 408's entries survived every write intact (byte-compare their
      `jq -S` serialization before and after the batch).
- [ ] Run `bash .claude/scripts/manage-topics.sh set <num> strong_completeness` for each new task.
- [ ] Run `bash .claude/scripts/generate-todo.sh` once, then confirm all five titles appear in
      `specs/TODO.md`.
- [ ] Back-fill the allocated numbers into `design/04_subtask-decomposition.md`, replacing the
      symbolic IDs `N1`..`N5` (keeping the symbolic ID in parentheses for traceability).

**Timing**: 1 hour

**Depends on**: 4

**Verification Tier**: interface

**Commit Mode**: atomic-batch

**Scope Hypothesis**: This phase asserts that **exactly five** new entries will exist in
`active_projects` after it runs, and that `next_project_number` advances by exactly five. Confirm
with `jq '.active_projects | length' specs/state.json` before and after (delta must be 5, and any
larger delta means a concurrent session also created tasks — record that, do not "correct" it)
and with `jq '.next_project_number' specs/state.json` before and after.

**Files to modify**:
- `specs/state.json` — five new `active_projects` entries, `next_project_number` advanced.
- `specs/TODO.md` — regenerated (never hand-edited).
- `specs/361_.../design/04_subtask-decomposition.md` — symbolic IDs replaced with allocated
  numbers.

**Verification**:
- `jq -e '[.active_projects[] | select(.topic == "strong_completeness" and .status == "not_started")] | length >= 5' specs/state.json`
  succeeds.
- For each new number `M`: `jq -e --argjson m M '.active_projects[] | select(.project_number == $m) | (.task_type == "lean4") and (.file_scope | length > 0) and (.dependencies | type == "array")' specs/state.json`
  succeeds.
- Every dependency target resolves: for each new task, each integer in `dependencies` matches
  some `project_number` in `specs/state.json` or `specs/archive/state.json`.
- `grep -c '<N1-title-fragment>' specs/TODO.md` >= 1 for all five titles.
- `jq empty specs/state.json` exits 0; task 418's and task 408's entries are unchanged.
- No file under `FormalSystem/` or `Tests/` appears in `git status --short`.

---

### Phase 6: Record the staleness corrections and close out [NOT STARTED]

**Goal**: Correct the stale Dense/Base claims where they actually live — `specs/ROADMAP.md` and
the task 170 / task 169 descriptions — wire task 169's new dependency, and write the task
summary.

**Tasks**:
- [ ] `specs/ROADMAP.md`, completeness table (~lines 43-47): correct the `Dense` row's
      `Weak completeness` cell from `open — task 170` to a cell recording that
      `completeness_dense` is machine-verified sorry-free (axioms `propext, Classical.choice,
      Quot.sound`) pending an independent clean-build re-verification, and that task 170 is
      therefore substantively closed. Use targeted `Edit` calls against freshly-read content, not
      a whole-file rewrite.
- [ ] `specs/ROADMAP.md`: correct the `Base` row's `Weak completeness` cell to record that
      exactly ONE reachable sorry remains (`WeakCanonical/Transfer.lean:1242`,
      `countermodel_discrete`), and that the route is now scoped (route (i) refuted, route (ii)
      recommended) with the chain of newly spawned tasks named.
- [ ] `specs/ROADMAP.md`: update the `Genuine strong (Set Formula)` cells for `Base` and `Dense`
      to point at the allocated feasibility-gate task number (N4) instead of "compactness
      research, task 361", and record the gating rule in one sentence.
- [ ] `specs/ROADMAP.md`: leave the `Discrete` and `Dedekind` rows untouched — both are already
      accurate.
- [ ] `specs/state.json`, task 170: rewrite `description` so it no longer names the archived
      declarations `succ_reaches_dom_N` / `chronicle_gap_contradiction` / the
      `MCSMixedCase.lean` sorry. The new description states the verified status, names the single
      remaining action (independent clean-build `#print axioms completeness_dense` by a build-lock
      holder, then `[COMPLETED]` with the axiom set as the completion summary), and states
      explicitly that no implementation agent should be dispatched at it. Do NOT change its
      `status` — that transition belongs to whoever runs the clean build.
- [ ] `specs/state.json`, task 169: rewrite `description` so it names exactly ONE remaining sorry
      (`Transfer.lean:1242`) rather than three, records route (i) as refuted and route (ii) as
      recommended, and cites `design/03_weak-terminus-status.md`. Add the allocated N2 number to
      its `dependencies` array (currently `[361]`).
- [ ] Each `state.json` mutation is a single atomic `jq ... > specs/tmp/state.json && mv`
      read-modify-write, followed by `jq empty`.
- [ ] Run `bash .claude/scripts/generate-todo.sh` once after the `state.json` edits.
- [ ] Write `summaries/01_strong-completeness-scoping-summary.md`: what was produced (four design
      documents, five spawned tasks), the corrected picture of both weak termini, the gating rule
      for the ultraproduct branch, and the explicit statement that no `FormalSystem/` file was
      touched and no build was run.

**Timing**: 45 minutes

**Depends on**: 5

**Verification Tier**: interface

**Commit Mode**: atomic-batch

**Files to modify**:
- `specs/ROADMAP.md` — completeness-table rows for Base and Dense only.
- `specs/state.json` — task 170 description; task 169 description and `dependencies`.
- `specs/TODO.md` — regenerated.
- `specs/361_.../summaries/01_strong-completeness-scoping-summary.md` — new.

**Verification**:
- `grep -n 'open — task 170' specs/ROADMAP.md` returns nothing (the stale cell is gone).
- `grep -n 'succ_reaches_dom_N\|chronicle_gap_contradiction' specs/ROADMAP.md` returns nothing in
  the completeness-table region.
- `jq -r '.active_projects[] | select(.project_number==170) | .description' specs/state.json |
  grep -c 'succ_reaches_dom_N'` returns 0.
- `jq -e '.active_projects[] | select(.project_number==169) | .dependencies | index(<N2>)' specs/state.json`
  succeeds.
- `jq -e '.active_projects[] | select(.project_number==170) | .status == "not_started"' specs/state.json`
  succeeds (status deliberately unchanged).
- `jq empty specs/state.json` exits 0; `specs/TODO.md` regenerated and consistent.
- `summaries/01_strong-completeness-scoping-summary.md` exists and states zero `FormalSystem/`
  writes and zero build commands.
- No file under `FormalSystem/` or `Tests/` appears in `git status --short`.

---

## Testing & Validation

There is no build to run and no test suite to exercise — this task produces documents and task
entries only. The validation set is:

- [ ] `git status --short` shows **no** modified or untracked file under `FormalSystem/` or
      `Tests/` at the end of every phase.
- [ ] No `lake build`, `lake clean`, or `lean_build` invocation appears anywhere in the phase
      transcripts; `.lake/.task-418-build.lock` is untouched.
- [ ] All four `design/*.md` documents exist, are non-empty, and each carries the
      standing-constraint banner.
- [ ] `jq empty specs/state.json` exits 0 and task 418's and task 408's entries are byte-identical
      to their pre-task serialization.
- [ ] Exactly five new tasks exist with `topic: "strong_completeness"`, `task_type: "lean4"`,
      non-empty `file_scope`, and `dependencies` arrays whose every entry resolves to a real task.
- [ ] `specs/TODO.md` is a faithful regeneration of `specs/state.json` (produced by
      `generate-todo.sh`, not hand-edited).
- [ ] `specs/ROADMAP.md` no longer asserts that the Dense weak terminus is open.
- [ ] `bash .claude/scripts/validate-artifact.sh` (if present) passes on this plan and on the
      summary.

## Artifacts & Outputs

- `specs/361_.../design/01_set-consequence-layer.md`
- `specs/361_.../design/02_compactness-route.md`
- `specs/361_.../design/03_weak-terminus-status.md`
- `specs/361_.../design/04_subtask-decomposition.md`
- `specs/361_.../summaries/01_strong-completeness-scoping-summary.md`
- Five new task entries in `specs/state.json`, rendered into `specs/TODO.md`
- Corrected completeness-table rows in `specs/ROADMAP.md`
- Corrected descriptions for tasks 169 and 170; task 169 `dependencies` extended

## Rollback/Contingency

- **Documents**: all four design documents and the summary are new files under
  `specs/361_.../`. Rollback is `git rm` of the untracked/added paths — nothing else depends on
  them.
- **Spawned tasks**: if the spawn set turns out wrong, remove the offending entries with
  `jq 'del(.active_projects[] | select(.project_number == <M>))'` (the `del()` form, not
  `map(select(!=))` — see `jq-escaping-workarounds.md`), restore `next_project_number` only if no
  other session has advanced it since, and re-run `generate-todo.sh`. Do NOT reuse a released
  number if any other session may have observed it.
- **ROADMAP.md / task descriptions**: these are targeted text edits in tracked files; revert with
  `git checkout <ref> -- specs/ROADMAP.md` after snapshotting, or by re-applying the inverse
  `Edit`. Because a concurrent session may hold uncommitted changes to `specs/state.json`, prefer
  the inverse-edit route over any destructive git operation; if a destructive operation is
  genuinely needed, run `bash .claude/scripts/git-snapshot.sh 361` first.
- **Build lock**: nothing in this plan takes the lock, so there is no lock state to unwind. If a
  build was accidentally started, that is a constraint violation to report, not a rollback step.
