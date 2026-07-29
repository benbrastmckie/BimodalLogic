# Design: sub-task decomposition, dependency graph, and spawn manifest

**Source**: `reports/01_strong-completeness-architecture-gap-analysis.md` §5 (authoritative), plus
`design/01_set-consequence-layer.md`, `design/02_compactness-route.md`,
`design/03_weak-terminus-status.md`.
**Status**: design document, **executed**. The five tasks it specifies now exist as **421, 422,
423, 424, 425** in `specs/state.json` — see §0 for the allocation record.
**Intended consumer**: Phases 5 and 6 of `plans/01_strong-completeness-scoping.md` (both now
`[COMPLETED]`).

---

## STANDING CONSTRAINT BANNER

> At the time of writing, a separate session owns task 418 and holds the advisory build lock
> `.lake/.task-418-build.lock`. While that lock is held:
>
> - **MUST NOT** run `lake build`, `lake clean`, `lake exe`, or the `lean_build` MCP tool.
> - **MUST NOT** create, edit, or delete any file under `FormalSystem/` or `Tests/`.
> - **PERMITTED**: read-only `lean-lsp` queries and `Read`/`Grep`/`Glob` over the tree.

---

## 0. Execution status of this document

**This document was a MANIFEST; the spawn it describes has now been EXECUTED.** Phases 5 and 6 of
the governing plan were originally deferred for a concurrency hazard (the orchestrator was
concurrently rewriting `specs/state.json` and `specs/TODO.md` for another in-flight task, and a
second writer would have risked a lost-update race that silently drops task records). **That
conflict has since been resolved and both phases have been executed.**

Consequently:

- The symbolic IDs `N1`..`N5` have been **allocated to real task numbers** and back-filled
  throughout this document. The symbolic ID is retained in parentheses for traceability.
- §8 ("Post-spawn edits") records the checklist both phases executed.

**Allocation record**:

| Symbolic ID | Allocated task number |
|---|---|
| N1 | **421** |
| N2 | **422** |
| N3 | **423** |
| N4 | **424** |
| N5 | **425** |

`next_project_number` was **421** at allocation time — **not** the 420 recorded below at manifest
time; a concurrent session had created task 420 (`align_task_frame_with_positive_cone_limit_nullity`)
in the interim. The re-read mandated by §8 step 1 caught this, which is exactly what it exists for.
After the batch, `next_project_number` is **426** (advanced by exactly five).

---

## 1. The 14-item decomposition

From report §5.1. Each item is sized for one agent run unless noted. Items marked **(new)** do not
correspond to an existing task number.

| ID | Title | Scope | Est. |
|---|---|---|---|
| **T170-verify** | Verify and close the Dense weak terminus | Clean-build `#print axioms completeness_dense`; record the axiom set; update task 170's description (it names archived declarations) and mark `[COMPLETED]`. **No Lean edits.** | small |
| **B0** (new) | Correct `Transfer.lean` route guidance | Replace the "candidate route (i)" comment (`Transfer.lean:1239-1241`) with the refutation in `design/03_weak-terminus-status.md` §5.3 and point at route (ii). Docstring-only. | small |
| **B1** (new) | Non-Archimedean discrete carrier: instance probe | Confirm `AddCommGroup`, `LinearOrder`, `IsOrderedAddMonoid`, `Nontrivial` for `ℚ ×ₗ ℤ`; add a `CarrierProbe`-style `example` block mirroring `CompletenessDedekind.lean:61-100` showing the parametric canonical machinery elaborates at that carrier. | 1 phase |
| **B2** (new) | Discrete chronicle over the block carrier | The analogue of `box_dense_gives_density` + `cantorIsoDense` for the `□U(⊤,⊥)` case: block decomposition, densified block order, iso into `ℚ ×ₗ ℤ`. | 2-3 phases |
| **B3** (new) | `restricted_*` coherence for the discrete chronicle | The three `cantor_bfmcs_dense_restricted_{tc,buc,fuc}` analogues at the new carrier. | 2 phases |
| **B4** = task **169** | Close `countermodel_discrete`, rewire `completeness` | Assemble B1-B3 into `countermodel_discrete`; delete the `Transfer.lean` sorry; re-verify `#print axioms completeness` reports no `sorryAx`. | 1 phase |
| **S0** (new) | Set-based consequence layer | Land `design/01_set-consequence-layer.md` §2-§4 in `Metalogic/SetConsequence.lean`, imported by `StrongCompleteness.lean`. Pure definitions + easy lemmas; zero sorries expected. | 1 phase |
| **S1** (new) | Shift-set representation theorem | `design/02_compactness-route.md` §Representation theorem, both directions. **GATE: if this fails, Route B is refuted and S2-S5 are cancelled.** | 2 phases |
| **S2** (new) | Ultraproduct carrier | Bespoke dependent ultraproduct of ordered abelian groups + instances + `DenselyOrdered`/`Nontrivial` preservation. Largest unknown (risk R1). | 2-3 phases |
| **S3** (new) | Łoś lemma for `TruthAt` | Induction on `Formula`, six cases, over ultraproducts of shift sets. | 2 phases |
| **S4** (new) | Compactness of `⊨_Base` and `⊨_Dense` | Assemble S1-S3 into `ModelExistenceBase`/`ModelExistenceDense`, then `CompactBase`/`CompactDense`. | 1 phase |
| **S5-Dense** (new) | Strong completeness for `FrameClass.Dense` | `design/01` §5 with `engine := completeness_dense`. Small once S4 lands. | 1 phase |
| **S5-Base** (new) | Strong completeness for `FrameClass.Base` | `design/01` §5 with `engine := completeness`. Requires B4. | 1 phase |
| **D1** (new) | Discrete non-compactness, machine-checked | `design/02` §Discrete non-compactness witness. Independent of everything except S0's vocabulary. | 2 phases |

---

## 2. Dependency graph

From report §5.2:

```
T170-verify ──(independent, do first, cheap)

B0 ──▶ B1 ──▶ B2 ──▶ B3 ──▶ B4 (=task 169) ──┐
                                              │
S0 ──┬──▶ D1                                  │
     │                                        ▼
     └──▶ S5-Dense ◀── S4 ◀── S3 ◀──┬── S1   S5-Base
                                     └── S2    ▲
                                               │
                              S4 ──────────────┘
```

Two readings the report calls out explicitly, and which drive scheduling:

1. **`S5-Base` depends on BOTH `S4` and `B4`.** Base strong completeness needs the compactness
   result *and* the Base weak terminus closed.
2. **`S5-Dense` depends on `S4` and `S0` only — it does NOT wait on the Base weak terminus.**
   `completeness_dense` is already machine-verified green (`design/03` §1), so the Dense engine
   hypothesis is dischargeable today. **This makes Dense the natural first strong-completeness
   target**, and it is the single most schedule-relevant fact in this decomposition.

`S1` is the gate for the entire S-branch. Schedule it before `S2`, and do not authorize `S2` (the
expensive one) until `S1` lands.

---

## 3. Gated spawn policy

> ### Exactly five tasks are created now
>
> **Created**: `B0+B1` (as one task, 421 (N1)), `B2+B3` (as one task, 422 (N2)), `S0` (423 (N3)), `S1` (424 (N4)),
> `D1` (425 (N5)).
>
> **Deliberately NOT created**: **`S2`, `S3`, `S4`, `S5-Dense`, and `S5-Base`.**
>
> These five are authorized **only after the `S1` feasibility gate returns positive** per the
> GATING RULE in `design/02_compactness-route.md`. That rule's evidence standard is repeated here
> so it cannot be lost: *a sorry-free Lean statement of **both directions** of the representation
> theorem, verified by `#print axioms` on each direction reporting no `sorryAx`.* A statement that
> type-checks with a `sorry` body does not pass; a proof of only the forward direction does not
> pass; a prose argument does not pass.
>
> **The reason, verbatim from report §5.3**: spawning them now "would commit plan budget to a
> branch that S1 can refute in one run."

`T170-verify` is also not spawned as a new task: it is an action on the **existing** task 170, and
`design/03_weak-terminus-status.md` §4 specifies it. `B4` is not spawned either: it is the
**existing** task 169.

---

## 4. Pre-flight checks performed for this manifest

Per the plan's Scope Hypothesis for this phase, the asserted paths were checked read-only:

```
$ ls -d FormalSystem/Metalogic/WeakCanonical/Transfer.lean \
        FormalSystem/Metalogic/BXCanonical/Chronicle/ \
        FormalSystem/Metalogic/StrongCompleteness.lean
FormalSystem/Metalogic/BXCanonical/Chronicle/
FormalSystem/Metalogic/StrongCompleteness.lean
FormalSystem/Metalogic/WeakCanonical/Transfer.lean

$ for p in FormalSystem/Metalogic/SetConsequence.lean \
           FormalSystem/Semantics/ShiftSet.lean \
           FormalSystem/Metalogic/DiscreteNonCompactness.lean \
           FormalSystem/Metalogic/BXCanonical/DiscreteCarrierProbe.lean; do …; done
absent: FormalSystem/Metalogic/SetConsequence.lean
absent: FormalSystem/Semantics/ShiftSet.lean
absent: FormalSystem/Metalogic/DiscreteNonCompactness.lean
absent: FormalSystem/Metalogic/BXCanonical/DiscreteCarrierProbe.lean

$ git ls-files 'FormalSystem/**' | grep -iE 'setconsequence|shiftset|noncompact|carrierprobe|compact'
(no near-matches)
```

**Findings**:
- The three existing paths named in `file_scope` all exist as written. ✓
- All four proposed new paths are absent, **and no module under a different name already covers
  them** — so no path substitution is required. ✓
- **Non-existence of a proposed new path is expected and is NOT a reason to drop it from
  `file_scope`**: the orchestrator's admission gate matches on path *strings*, not on file
  existence. All four stay in the manifest.

---

## 5. Spawn manifest

`next_project_number` was **420** when this manifest was written. Phase 5 **must re-read it
immediately before the first allocation** — a concurrent session may have advanced it.

| ID | Title | task_type | topic | dependencies | file_scope |
|----|-------|-----------|-------|--------------|------------|
| 421 (N1) | Correct Transfer.lean route guidance and probe the non-Archimedean discrete carrier | lean4 | strong_completeness | `[361]` | `["FormalSystem/Metalogic/WeakCanonical/Transfer.lean", "FormalSystem/Metalogic/BXCanonical/DiscreteCarrierProbe.lean"]` |
| 422 (N2) | Build the discrete chronicle over the non-Archimedean block carrier with restricted coherence | lean4 | strong_completeness | `[421]` (N1) | `["FormalSystem/Metalogic/BXCanonical/Chronicle/"]` |
| 423 (N3) | Land the set-based consequence layer (SetDerivable and per-class SetSemanticConsequence) | lean4 | strong_completeness | `[361]` | `["FormalSystem/Metalogic/SetConsequence.lean", "FormalSystem/Metalogic/StrongCompleteness.lean"]` |
| 424 (N4) | Prove the shift-set representation theorem for task models (compactness feasibility gate) | lean4 | strong_completeness | `[361]` | `["FormalSystem/Semantics/ShiftSet.lean"]` |
| 425 (N5) | Machine-check the Discrete non-compactness witness | lean4 | strong_completeness | `[361, 423]` (N3) | `["FormalSystem/Metalogic/DiscreteNonCompactness.lean"]` |

**Common fields for all five**: `status: "not_started"`, `effort: "high"` (except 421 (N1), see below),
`task_type: "lean4"`, `topic: "strong_completeness"`.

**Effort override**: 421 (N1) is `"medium"` — it is a docstring correction plus an instance probe, and
`design/03` §5.6 retired its main risk by confirming the Mathlib lex instance exists.

**Dependency-edge ordering note**: `421 (N1)`, `423 (N3)`, and `424 (N4)` depend on `361` only and can be written
correctly at creation time. `422 (N2)` (`[421]` (N1)) and `425 (N5)` (`[361, 423]` (N3)) reference newly-allocated numbers
and must be **patched after all five allocations complete**.

---

## 6. Task descriptions

Verbatim text for each task's `description` field.

### 421 (N1) — Correct Transfer.lean route guidance and probe the non-Archimedean discrete carrier

> Two deliverables on the Base weak terminus, both small.
>
> **(a) Correct the refuted route guidance.** `FormalSystem/Metalogic/WeakCanonical/Transfer.lean:1239-1241`
> currently proposes "(i) a Base-MCS → Discrete-MCS transfer lemma that lets
> `countermodel_discrete_reynolds_v2` apply". **Route (i) is REFUTED and MUST NOT be
> re-attempted.** The witness: over `D := ℤ ×ₗ ℤ` (lex, first coordinate dominant) with `p` true
> exactly at points `≥ (1,0)`, every point has an immediate successor so `□U(⊤,⊥)` holds;
> `G(Gp → p)` holds at `(0,0)`; `FGp` holds at `(0,0)` (witness `(1,0)`) but `Gp` fails there
> (witness `(0,1)`); hence `Axiom.z1 p` is false. So a Base-MCS containing `□U(⊤,⊥)` need not be
> Discrete-consistent and no Base-to-Discrete MCS transfer lemma can exist. Replace those comment
> lines with the refutation and point at route (ii). Docstring/comment-only — do not touch the
> `sorry` at :1242 in this task.
>
> **(b) Probe the recommended carrier.** Confirm `AddCommGroup`, `LinearOrder`,
> `IsOrderedAddMonoid`, `Nontrivial` all resolve for `ℚ ×ₗ ℤ`, and add a `CarrierProbe`-style
> `example` block (mirroring the pattern at
> `FormalSystem/Metalogic/BXCanonical/CompletenessDedekind.lean:61-100`) showing the parametric
> canonical machinery elaborates at that carrier. **This is a confirmation step, not a supply
> step**: `Mathlib/Algebra/Order/Monoid/Prod.lean:52-59` declares
> `@[to_additive] instance Lex.isOrderedMonoid … : IsOrderedMonoid (α ×ₗ β)`, whose additive form
> supplies `IsOrderedAddMonoid (α ×ₗ β)`. Confirm the instance actually *fires* for `ℚ ×ₗ ℤ` (in
> particular that `AddLeftStrictMono ℚ` is found) — the generated instance name was inferred from
> the attribute and not resolved by lookup.
>
> **Governing design document**: `specs/361_strong_completeness_architecture_and_weak_terminus_gap_analysis/design/03_weak-terminus-status.md`,
> §5.3 (the refutation), §5.5 (the carrier), §5.6 (the Mathlib instance).
>
> **Acceptance**: the refuted-route comment no longer appears at `Transfer.lean:1239-1241`; the
> probe block elaborates; `lake build` is green; `#print axioms` on any new declaration shows no
> `sorryAx`; the live non-Boneyard sorry count is unchanged at 2 (verify with
> `grep -rn --include='*.lean' -E '^\s*sorry\s*$' FormalSystem/ | grep -vc Boneyard`).

### 422 (N2) — Build the discrete chronicle over the non-Archimedean block carrier with restricted coherence

> Construct the discrete-case analogue of the existing dense chronicle machinery, over the
> non-Archimedean carrier `ℚ ×ₗ ℤ` confirmed by the predecessor task.
>
> **Deliverable (a)**: the analogue of `box_dense_gives_density`
> (`FormalSystem/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodelBasic.lean:435`) and
> `cantorIsoDense` for the `□U(⊤,⊥) ∈ A` case — block decomposition of the chronicle order into
> ℤ-blocks, densification of the block order, and the isomorphism into `ℚ ×ₗ ℤ`.
>
> **Deliverable (b)**: the three restricted-coherence analogues, mirroring
> `cantor_bfmcs_dense_restricted_tc` (:629), `_buc` (:680), `_fuc` (:755) at the new carrier.
>
> **Why this carrier and not `ℤ`**: `succ_cofinal` — the obligation that killed the old BX
> pipeline, refuted by the ℤ+ℤ counterexample in `Boneyard/BXPipelineGapAnalysis/` — was only ever
> needed to force the chronicle into `ℤ`, i.e. to make it Archimedean. `FrameClass.Base` imposes no
> Archimedean-ness (`valid`, `FormalSystem/Semantics/Validity.lean:79`, has no `IsSuccArchimedean`
> binder). **The ℤ+ℤ shape is not a counterexample here — it is the intended carrier.** Do not
> re-attempt `succ_cofinal`.
>
> **PRINCIPAL RISK, unresolved at scoping time**: it has NOT been verified that the chronicle's
> block order can always be densified without disturbing MCS-chain coherence. A countable discrete
> order without endpoints is a ℤ-indexed fibration over its block order, but making the *total*
> structure a group requires the block order to carry a compatible group structure. If this fails,
> escalate as [BLOCKED] with the failing coherence obligation named — do not paper over it with a
> `sorry` or a vacuous placeholder.
>
> **Governing design document**: `design/03_weak-terminus-status.md` §5.4-§5.7.
>
> **Acceptance**: the block-carrier construction and all three restricted-coherence analogues are
> sorry-free; `#print axioms` on each reports no `sorryAx`; `lake build` green. This task does NOT
> close the `Transfer.lean:1242` sorry — that is task 169's job, which consumes this output.

### 423 (N3) — Land the set-based consequence layer (SetDerivable and per-class SetSemanticConsequence)

> Create `FormalSystem/Metalogic/SetConsequence.lean` containing the finitary set-derivability
> relation `SetDerivable`, the four per-class `SetSemanticConsequence*` predicates, the basic
> lemmas, and the strong-completeness / compactness / model-existence statements. Then import it
> from `FormalSystem/Metalogic/StrongCompleteness.lean`.
>
> **This is vocabulary only.** It proves no compactness result and closes no existing sorry. It is
> self-contained and unblocks two downstream branches (the Discrete non-compactness witness, and
> Dense strong completeness).
>
> **Governing design document**:
> `specs/361_strong_completeness_architecture_and_weak_terminus_gap_analysis/design/01_set-consequence-layer.md`
> — transcribe §2 (`SetDerivable`), §3 (the four per-class definitions), §4 (basic lemmas), §5
> (`StrongCompletenessDense`, `CompactDense`, `strongCompletenessDense_of_compact`,
> `SatisfiableDenseSet`, `ModelExistenceDense`). §4's "Implementer notes" name three elaboration
> risks; §7 records what is deliberately out of scope.
>
> **Acceptance** (from `design/01` §6, all five required): zero sorries and zero vacuous
> placeholders; `grep -c 'import FormalSystem.Metalogic.BXCanonical'` on the new module returns 0;
> each `SetSemanticConsequence*` binder list is byte-comparable to its `Validity.lean` source
> (`valid` :79, `ValidDense` :169, `ValidDiscrete` :187, `ValidDedekindDense` :276) with only the
> premise hypothesis inserted, and uses `Type` not `Type*` (`Validity.lean:77` records this as
> deliberate); `#print axioms` on every new declaration reports no `sorryAx`; `StrongCompleteness.lean`
> imports the module and still builds.

### 424 (N4) — Prove the shift-set representation theorem for task models (compactness feasibility gate)

> Prove, in both directions, that the task-model class is representable by **shift sets**
> `⟨Ω, D, sh, A⟩` — `D` an ordered abelian group, `Ω` a nonempty type with a `D`-action
> `sh : Ω → D → Ω`, and `A : Atom → Ω → Prop`.
>
> **THIS TASK IS THE GATE FOR THE ENTIRE ULTRAPRODUCT BRANCH.** The follow-on work — the
> ultraproduct carrier (`S2`), the Łoś lemma for `TruthAt` (`S3`), compactness of `⊨_Base`/`⊨_Dense`
> (`S4`), and strong completeness for Dense and Base (`S5-Dense`, `S5-Base`) — **is NOT AUTHORIZED
> and has deliberately NOT been created as tasks.** It becomes authorized only when this task
> lands sorry-free. Do not spawn, plan, or dispatch any of it from within this task.
>
> **Gate-passed evidence standard, and nothing weaker**: a sorry-free Lean statement of **both**
> directions, with `#print axioms` on **each direction** reporting no `sorryAx`. A statement that
> type-checks with a `sorry` body does not pass. Proving only the forward direction does not pass.
> A prose argument does not pass.
>
> **Cancel condition**: if either direction is refuted, or the construction cannot be stated
> without an additional non-elementary hypothesis, then **Route B (semantic compactness via
> ultraproduct) is REFUTED and the whole branch is cancelled, not retried.** Record the refutation
> and re-open the compactness question; do not proceed to `S2` hoping the gap can be patched
> downstream.
>
> **Governing design document**: `design/02_compactness-route.md` — §"Representation theorem" for
> both directions (the reverse direction uses `WorldHistory.timeShift` and
> `FormalSystem.Semantics.TimeShift.time_shift_preserves_truth`, `FormalSystem/Semantics/Truth.lean:446`),
> §"Risks" R3 for the `Type` vs `Type*` constraint (assert it EARLY, not at assembly time), and
> §"GATING RULE" for the full gate contract.
>
> **Acceptance**: both directions sorry-free; `#print axioms` clean on each; `lake build` green;
> the task's summary states explicitly whether the gate PASSED or FAILED.

### 425 (N5) — Machine-check the Discrete non-compactness witness

> Convert the informal argument at `FormalSystem/Metalogic/StrongCompleteness.lean:56-62` into a
> machine-checked theorem: the `FrameClass.Discrete` consequence relation is **not compact**, hence
> strong completeness is **refuted** for that class.
>
> The witness is the premise set `{F p} ∪ {¬ Xⁿ p : n ∈ ℕ}` where `X φ = Formula.next φ`. Every
> finite subset is satisfiable over `ℤ` (place `p` beyond the largest `n` used); the whole set is
> unsatisfiable over any Archimedean discrete carrier, because the `F p` witness would lie at some
> finite successor distance, contradicting the corresponding `¬ Xⁿ p`.
>
> **The load-bearing ingredient is already in the tree**: `Formula.next φ = Formula.untl φ Formula.bot`
> (`FormalSystem/Syntax/Formula.lean:490`) genuinely is a next-step operator — through the `untl`
> clause of `TruthAt`, `∃ s > t, φ(s) ∧ ∀ r ∈ (t,s), ⊥` says exactly that `s` is the immediate
> successor. No extra hypothesis is needed for this. The `¬ satisfiable` half is where
> `IsSuccArchimedean` does its work, via `Order.succ_iterate`-style reachability lemmas in Mathlib.
>
> **This is the negative half of the per-class split and is independent of the compactness gate** —
> it is not affected by whether Route B succeeds. It depends only on the set-based layer's
> vocabulary (`SatisfiableDiscreteSet` / `CompactDiscrete` are the Discrete analogues of
> `SatisfiableDenseSet` / `CompactDense`).
>
> **Explicitly out of scope**: an analogous Dedekind non-compactness witness. That belongs to task
> 408 and the class's non-compactness is already established; duplicating it here would create
> scope overlap with an in-flight task for no gain.
>
> **Governing design document**: `design/02_compactness-route.md` §"Discrete non-compactness witness".
>
> **Acceptance**: `archWitness_finitely_satisfiable`, `archWitness_not_satisfiable`, and
> `discrete_consequence_not_compact` all land sorry-free; `#print axioms` clean on each;
> `lake build` green.

---

## 7. file_scope rationale

Overlap analysis against tasks in flight. `file_scope` values below were read from
`specs/state.json` **this session**.

| New task | file_scope | Overlaps | Intended? |
|---|---|---|---|
| 421 (N1) | `Transfer.lean`, `BXCanonical/DiscreteCarrierProbe.lean` | nothing currently in flight | — |
| 422 (N2) | `BXCanonical/Chronicle/` | **task 169** and **task 170** (both declare `["…/BXCanonical/Completeness.lean", "…/BXCanonical/Chronicle/"]`) | **YES — intended.** 422 (N2) produces exactly what 169 consumes; serializing them is correct. The 170 overlap is incidental (170 has no Lean work at all per `design/03` §4). |
| 423 (N3) | `Metalogic/SetConsequence.lean`, `Metalogic/StrongCompleteness.lean` | **task 362** (`["…/StrongCompleteness.lean", "FormalSystem/Metalogic.lean"]`) | **YES — intended.** Both edit `StrongCompleteness.lean`; serializing them prevents a merge conflict on the same file. |
| 424 (N4) | `Semantics/ShiftSet.lean` | nothing currently in flight | — |
| 425 (N5) | `Metalogic/DiscreteNonCompactness.lean` | nothing currently in flight | — |

### Explicitly NOT overlapped

- **Task 418** (`fix_tableau_engine_crossworld_temporalcopy_unsoundness_in_boxnegdiamondpos`,
  `implementing`) declares `["FormalSystem/Metalogic/Decidability/Tableau.lean",
  "Tests/BimodalTest/TableauConformance.lean", "Tests/BimodalTest/BoxNegReachabilityProbe.lean",
  "Tests/BimodalTest/BoxNegPreservationProbe.lean"]`. **No spawned scope touches
  `Decidability/` or `Tests/`.** ✓
- **Task 408** (`faithful_route_to_strong_completeness_for_the_dedekind_extension`,
  `implementing`) — its subject matter is the Dedekind/`ShuffleReal.lean` axis, which no spawned
  scope touches. ✓

> **[OBSERVED DIVERGENCE from the plan's assumption]** The governing plan's Phase 4 task list says
> to record that "tasks 418 (`Decidability/Tableau.lean`, `Tests/`) and 408
> (Dedekind/`ShuffleReal.lean`) are NOT overlapped by any spawned scope". Task 418's `file_scope`
> matches that description. **Task 408's `file_scope` is EMPTY (`[]`)** in `specs/state.json`, not
> the `ShuffleReal.lean` entry the plan implies. The *substantive* claim still holds — no spawned
> scope touches the Dedekind axis — but the mechanism differs: an empty `file_scope` means task 408
> does not participate in path-based admission gating at all, so it can never be serialized against
> by scope matching. Anyone relying on the gate to keep 408 separate should know that the gate is
> not what is doing the work here.

---

## 8. Post-spawn edits — the checklist executed by Phases 5 and 6

> **EXECUTION RECORD**: every step below has been carried out. Step 1's re-read found
> `next_project_number` at **421**, not the 420 recorded at manifest time. Kept in imperative form
> as the audit trail of what was done.

Phase 5 (task creation) must:

1. Re-read `next_project_number` from `specs/state.json` immediately before the first allocation
   (it was **420** at manifest time; a concurrent session may have advanced it — **it had, to 421**).
2. Create 421 (N1)..425 (N5) in that order, **one atomic `jq` read-modify-write each**
   (`jq … specs/state.json > specs/tmp/state.json && mv specs/tmp/state.json specs/state.json`),
   using the field values in §5 and the descriptions in §6. Follow each write with
   `jq empty specs/state.json`.
3. Patch the two intra-spawn dependency edges once all five numbers are allocated: 422 (N2)'s
   `dependencies` becomes `[<421 (N1)>]`; 425 (N5)'s becomes `[361, <423 (N3)>]`.
4. Verify no dangling edges — every integer in any new task's `dependencies` resolves to a real
   `project_number` in `specs/state.json` or `specs/archive/state.json`.
5. Confirm tasks 418 and 408 survived every write intact (`jq -S` byte-compare before/after).
6. `bash .claude/scripts/manage-topics.sh set <num> strong_completeness` for each new task.
7. `bash .claude/scripts/generate-todo.sh` **once**, then confirm all five titles appear in
   `specs/TODO.md`.
8. Back-fill the allocated numbers into **this document**, replacing the symbolic IDs `N1`..`N5`
   and keeping the symbolic ID in parentheses for traceability.

Phase 6 (staleness corrections) must then:

1. **`specs/ROADMAP.md`, `Dense` row, `Weak completeness` cell**: replace `open — task 170` with a
   cell recording that `completeness_dense` is machine-verified sorry-free (axioms `propext,
   Classical.choice, Quot.sound`) pending an independent clean-build re-verification, and that
   task 170 is therefore substantively closed. Use targeted `Edit` calls against freshly-read
   content, never a whole-file rewrite.
2. **`specs/ROADMAP.md`, `Base` row, `Weak completeness` cell**: record that exactly ONE reachable
   sorry remains (`WeakCanonical/Transfer.lean:1242`, `countermodel_discrete`), and that the route
   is now scoped (route (i) refuted, route (ii) recommended), naming the chain 421 (N1) → 422 (N2) → 169.
3. **`specs/ROADMAP.md`, `Genuine strong (Set Formula)` cells for `Base` and `Dense`**: point at
   the allocated 424 (N4) number instead of "compactness research, task 361", and state the gating rule
   in one sentence.
4. **`specs/ROADMAP.md`**: leave the `Discrete` and `Dedekind` rows untouched — both are accurate.
5. **`specs/state.json`, task 170 `description`**: rewrite so it no longer names the archived
   declarations `succ_reaches_dom_N` / `chronicle_gap_contradiction` / the `MCSMixedCase.lean`
   sorry. State the verified status, name the single remaining action (independent clean-build
   `#print axioms completeness_dense` by a build-lock holder, then `[COMPLETED]` with the axiom set
   as the completion summary), and state explicitly that **no implementation agent should be
   dispatched at it**. **Do NOT change its `status`** — that transition belongs to whoever runs the
   clean build.
6. **`specs/state.json`, task 169 `description`**: rewrite so it names **exactly ONE** remaining
   sorry (`Transfer.lean:1242`) rather than three, records route (i) as refuted and route (ii) as
   recommended, and cites `design/03_weak-terminus-status.md`. **Add the allocated 422 (N2) number to its
   `dependencies`** (currently `[361]`).
7. Each `state.json` mutation is a single atomic `jq … > specs/tmp/state.json && mv`, followed by
   `jq empty`. Run `bash .claude/scripts/generate-todo.sh` **once** after the `state.json` edits.
8. Write `summaries/01_strong-completeness-scoping-summary.md`.

---

## 9. Divergences from the research report

| # | Report claim | Observed | Impact |
|---|---|---|---|
| 1 | Report §5.3 suggested spawn set: B0+B1, B2+B3, S0, S1, D1 | Reproduced exactly as 421 (N1)..425 (N5) | none |
| 2 | (plan assumption) task 408 scoped to `ShuffleReal.lean` | task 408's `file_scope` is **`[]`** | Substantive non-overlap claim holds; the *mechanism* differs — see §7 |

Divergences affecting the *content* of the spawned tasks (the live sorry count, the Mathlib lex
instance, the route-label collision) are recorded in `design/03_weak-terminus-status.md` §7 and are
already reflected in the §6 descriptions above.
