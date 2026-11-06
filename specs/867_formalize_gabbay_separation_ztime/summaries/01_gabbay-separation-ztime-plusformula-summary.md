# Implementation Summary: Task #867

- **Task**: 867 - Formalize Gabbay separation over discrete time for `PlusFormula`, discharging `SeparationOver TaskFrame.IsZTime` and making the open-future translation executable
- **Status**: [IN PROGRESS]
- **Started**: 2026-11-05T00:00:00Z
- **Completed**: 2026-11-06T12:40:00Z
- **Effort**: three implement dispatches (7, 12) plus one plan revision (11)
- **Dependencies**: None blocking
- **Artifacts**: plans/01_gabbay-separation-ztime-plusformula.md, reports/01_gabbay-separation-ztime-plusformula.md, prototype/cases-5-8-probe.lean, prototype/cases-5-8-reduction.lean
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Phases 1-20 of the twenty-seven-phase plan are landed, sorry-free and gate-green. **All eight
cases of GHR Lemma 10.2.3 are proved**, and so is Lemma 10.2.4's equivalence together with its
separatedness. Phase 5 had closed Phases 7-15 with exclusions on a recorded "precisely located
obstruction" at Cases 6, 7 and 8; that obstruction was an artefact of the route it measured, and
Phases 16-20 dissolved it by following the source's own reduction order.

**The task's headline deliverable is still not reached.** `SeparationOver TaskFrame.IsZTime` is
not discharged, `separationOver_ztime` does not exist, `trZ` does not exist, and no `tr` row in
`OpenFutureElimination.lean` changed. Nothing in the tree reads as if it had. Phase 21 is
`[BLOCKED]` on a **new and different** obstruction, located precisely and with two named repair
routes, in GHR 10.2.4's second conclusion clause.

## What Changed

- `FormalSystem/Metalogic/Expressiveness/SeparationZ/ElimHard.lean` — new, 954 lines. GHR Lemma
  10.2.3's four hard cases, where the eliminated `untl` occurs in **both** arguments of the
  `snce`:
  - `exists_greatest_below` — the `ℤ` greatest-witness device, dual to the landed
    `exists_least_above`.
  - `case5W`, `case5Core`, `case5Rhs`, `usTruth_case5`, `isSeparated_case5Rhs` — Case 5, the one
    hard case proved semantically. GHR's printed formula is **refuted** over `ℤ`; the landed form
    keeps GHR's pure-past core and `¬S(¬q,¬A)` verbatim and moves `A ∨ (B ∧ U(A,B))` from a
    shared conjunct to a case split.
  - `usTruth_case5_guard_iff` — the guard equivalence that repair needs: above an `A`-point and
    under `W`, the real guard `q ∨ U(A,B)` and GHR's re-anchoring guard `A ∨ B ∨ ¬S(¬q,¬A)` cut
    out the same windows. This is the only lemma in the subtree with no counterpart in the source.
  - `case8Rhs`, `usTruth_case8`, `isSeparated_case8Rhs` — Case 8 by GHR's own reduction.
  - `case7Rhs`, `usTruth_case7`, `usTruth_case7_of_anchor`, `isSeparated_case7Rhs` — Case 7.
  - `case6Rhs`, `usTruth_case6`, `usTruth_case6_of_anchor`, `isSeparated_case6Rhs` — Case 6.
  - A landed-DAG table in the module docstring, one row per case naming the lemmas it consumes,
    so acyclicity is auditable from the module alone.
- `FormalSystem/Metalogic/Expressiveness/SeparationZ/NegationEquiv.lean` — extended with
  `usTruth_neg_snce_distrib`, GHR's generic negated-since distribution identity, stated at the
  generality Case 8 substitutes into (`y = z = ¬U(A,B)`).
- `FormalSystem/Metalogic/Expressiveness/SeparationZ/NormalForm.lean` — new, 352 lines. GHR
  Lemma 10.2.4: `IsUTyped` (the precondition, strictly weaker than `IsSeparated`) with
  `isSeparated_of_isUTyped`; `substU` with `usTruth_substU` and `isSOnly_substU`;
  `usTruth_event_split` and `usTruth_guard_split`; `sepSnce` with `usTruth_sepSnce` and
  `isSeparated_sepSnce`.
- `specs/867_formalize_gabbay_separation_ztime/prototype/cases-5-8-reduction.lean` — new. The
  Phase 16 gate record: the reduction DAG with every edge quoting the sentence of GHR's proof
  that states it, five compiled probe models, and the gate verdict.
- `FormalSystem/Metalogic/Expressiveness/SeparationZ/README.md`, `FormalSystem.lean`,
  `typst/generated/status.typ`, `README.md`, `FormalSystem/README.md`,
  `FormalSystem/Metalogic/README.md` — module rows, regenerated root, re-derived counts and
  regenerated inventory blocks.

## Decisions

- **The source's printed text was read directly, not reconstructed.** GHR vol. 1 Chapter 10
  §10.2's markdown chunk in the literature corpus carries the full printed text of Lemma
  10.2.3's eight cases, including the generic negated-since distribution identity and the
  explicit reduction sentences for Cases 6, 7 and 8. Reading it replaced the plan's
  one-line reconstructed DAG with source-quoted edges, and supplied the extra semantic step each
  of Cases 7 and 6 needs before the named earlier cases apply — which the plan's summary had
  compressed away.
- **Case 5's pinned right-hand side is neither of the two candidates the plan named.** The
  two-disjunct bracketing repair the plan told Phase 17 to prefer is refuted by a new compiled
  model; Phase 5's `case5RHS` fallback is unrefuted but carries no correctness derivation
  anywhere in the record. The landed form is GHR's own `case5Core` with the `W` conjunct moved
  to a case split, pinned with its full semantic derivation before any proof was attempted.
- **Cases 6, 7 and 8 are reached by reduction, never by semantic re-anchoring.** Decision D-e's
  admission test was measured before any proof: every edge is nameable at a source step and the
  DAG is acyclic under the order `1, 2, 3, 4, 5, 8, 7, 6`.
- **Case 8 keeps all three printed disjuncts.** GHR's redundancy claim about the third is false,
  and the error is one of orientation: the **second** disjunct's event strictly implies the
  third's, so it is the second that is redundant. A compiled model exhibits a point at which the
  third is the only true disjunct.
- **GHR 10.2.4's input position is given `IsUTyped`, never `IsSeparated`** (decision D-f). The
  module docstring records that the two do not imply each other in either direction without the
  extra `IsUOnly A` and `IsUOnly B` hypotheses.

## Plan Deviations

- **Phase 16** altered: neither of the two Case 5 candidates the plan named is implemented. The
  two-disjunct bracketing repair is **refuted** by a fourth model (`a(0)`, `q ≡ ⊥`, `A ∈ {1,5}`,
  `B` on `{2,3,4}`, at `t = 2`), compiled as `v₃_not_twoDisjRhs` beside `v₃_LHS`; both printed
  bracketings keep `¬S(¬q,¬A)` as a conjunct of the second disjunct, and at that point the
  left-hand side holds while `S(a,B)` and `¬S(¬q,¬A)` both fail. Phase 5's `case5RHS` fallback is
  unrefuted but has no correctness derivation on record. A third candidate was pinned, with its
  full derivation, and Phase 17 then proved it.
- **Phase 18 and Phase 19** were committed in one commit rather than one per phase. Phase 18 was
  build-verified green on its own before Phase 19 began, but no commit fired at that boundary and
  both phases land in the same module, so they could not afterwards be separated without
  rewriting the file.
- **Phase 20** altered: general `dnf`/`cnf` on the Boolean skeleton were not built. The
  `untl`-literal normal form was built instead — `substU` plus `usTruth_event_split` and
  `usTruth_guard_split`, each with its truth-preservation lemma at every `v` and `t` as the phase
  requires. It is the specialization of DNF/CNF that isolates `±untl B A`, the only literal
  10.2.4 consumes, and it yields exactly the four hard-case constituents with no leftover clause
  shapes. GHR 10.2.1's two distributivities and the clause-by-clause case application are
  unchanged. Recorded in the plan's Phase 20 `#### Reasoned Exclusions`.
- **Phase 20** partially excluded: GHR 10.2.4's second conclusion clause, that `untl` occurs only
  as `untl B A`, is not delivered. See `## Follow-ups`.
- Phases 1-15 are left exactly as recorded, including Phase 5's superseded gate verdict and
  Phases 7-13's exclusions. The correction lives in `ElimHard.lean`'s and
  `NormalForm.lean`'s module docstrings and in the Phase 16 gate record, where a reader of the
  new phases will meet it.

## Verification

- Build: **Success**. Guarded unscoped `lake build` green — guard exit 0, zero `error:` lines
  across both captured streams, `Build completed successfully (2960 jobs)`, and `.olean` newer
  than source confirmed for each of `ElimHard`, `NegationEquiv` and `NormalForm`.
- Sorry count: **0** (`lean-sorry-census.sh` over all resolved source roots; `sorry_inventory`
  empty). Zero in each of the seven `SeparationZ/` modules.
- Vacuous count: **1**, unchanged from the pre-task baseline and outside this task's file set —
  `FormalSystem/Examples/TemporalStructures.lean:495`, a `trivial` discharge of a
  true-by-definition goal. Measured at the baseline commit by archiving it to a scratch tree:
  baseline 1, current 1.
- Axiom count: **14**, unchanged from the pre-task baseline, measured the same way. No `axiom`
  declaration and no `noncomputable` keyword anywhere in `SeparationZ/`.
- Axiom profiles, measured with `#print axioms` against the built tree, never hand-typed:
  `usTruth_case5`, `usTruth_case6`, `usTruth_case7`, `usTruth_case8`, `usTruth_sepSnce`,
  `usTruth_neg_snce_distrib` and `usTruth_case5_guard_iff` each
  `[propext, Classical.choice, Quot.sound]`; `isSeparated_sepSnce` is `[propext]` alone. All
  within the ceiling the landed eliminations already carry; no new axiom.
- `bash scripts/check-module-invariants.sh` — **ALL CHECKS PASSED**, exit 0. Two failures this
  dispatch introduced were found and fixed before commit: C9 task-number citations in two
  `ElimHard.lean` docstring lines (replaced by durable anchors) and three stale generated
  inventory blocks (regenerated with `--emit-inventory`).
- `bash scripts/check-metalogic-cycles.sh` — exit 0, all three assertions PASS. No new module
  imports another `FormalSystem.Metalogic.<other>` subdirectory, so the allowlist is unperturbed.
- `bash scripts/typst-sync-check.sh --fix` — PASS on every module-adding commit.
- Phase 16's prototype elaborates at exit 0 under the guarded `env lean` invocation; all
  nineteen probe theorems typecheck, so the entire gate measurement is machine-checked rather
  than asserted.
- Tests: N/A — no suite maps to the new paths; the subtree is additive and nothing outside it
  references these names yet.
- Files verified: Yes.

## Impacts

- GHR Lemma 10.2.3 is complete over the integer flow, with every one of its eight cases proved
  and each right-hand side's separatedness discharged as a theorem. The recorded obstruction at
  Cases 6, 7 and 8 is withdrawn: it described the defect of a route the source does not use.
- Two printed-text defects in the published source are now pinned with compiled counterexamples
  rather than prose: GHR's Case 5 formula is false over `ℤ` under every bracketing, and GHR's
  claim that Case 8's third disjunct is redundant is false with the orientation of the error
  identified.
- GHR Lemma 10.2.4 is available to the inductions above it, in the form
  `usTruth_sepSnce` + `isSeparated_sepSnce`, at the weaker `IsUTyped` precondition the source
  itself consumes.
- A third, previously unknown gap in the **landed Phase 6 layer** is now located: `case2Rhs`
  carries `untl` types other than `untl B A`, which propagates to `case3Rhs`, `case6Rhs`,
  `case7Rhs` and `case8Rhs`. This is what blocks Phase 21, and it would have surfaced at the same
  place however Cases 6-8 had been obtained.
- The `.RTime` rows, `Independence/`, the metalogic-cycles allowlist and every existing signature
  are untouched, as the plan's Non-Goals require.

## Follow-ups

- **Phase 21 is `[BLOCKED]`, and unblocking it is a planning decision, not an implementation
  one.** `uTypeCount`, "the number of distinct maximal `untl` subformulas", cannot carry GHR
  10.2.6's induction over the eliminations as landed, because `sepSnce` can increase it. The
  plan's Phase 21 blocker entry carries the full record; the cause is that `Eliminations.lean`'s
  `case2Rhs` is built as `… ∨ case1Rhs a q (A.neg.and B.neg) A.neg` together with
  `allFuture A.neg`, so it carries the `untl` types `untl A.neg (A.neg.and B.neg)` and
  `untl USForm.top A.neg.neg` beside `untl B A`. GHR's printed Case 2 carries neither, because
  its third step folds `G¬A ∨ U(¬A∧¬B,¬A)` back into `¬U(A,B)` by Lemma 10.2.2 in reverse, which
  the landed proof omits. Two repair routes:
  1. **Repair the layer** — add a second Case 2 lemma at GHR's printed three-disjunct right-hand
     side, which mentions `untl` only as `untl B A`, then re-derive Cases 3, 6, 7 and 8 through
     it. Additive throughout: `usTruth_case2` and `case2Rhs` keep their names, signatures and
     proofs. `uTypeCount` then works as Phase 21 specifies.
  2. **Change the measure** — count `untl` occurrences lying *under a `snce`* rather than
     distinct `untl` types. `isSeparated_sepSnce` already drives that count to zero for the
     subformula it rewrites, and the extra types all sit in the pure-future part. This leaves the
     landed layer untouched but redesigns the measures of Phases 21, 22 and 23.
- Phases 22-27 stay `[NOT STARTED]`, gated behind Phase 21.
- The plan's own standing warning is unchanged and still worth weighing before committing more
  effort: Phase 23's junction-depth strict decrease is **asserted without proof** in the source
  and is the plan's primary stall candidate. It has still never been reached.
- Phase 27's `verify-deploy.sh` run remains deferred from Phase 15 and is still not forgiven.
- The deployed `.claude/` tree is stale relative to the source store for the `core`, `formal`,
  `lean`, `literature`, `memory` and `typst` extensions. Pre-existing, not caused here, and not
  hand-patchable; remedy is `bash .claude/scripts/deploy-headless.sh`.

## References

- `specs/867_formalize_gabbay_separation_ztime/plans/01_gabbay-separation-ztime-plusformula.md` —
  the plan, with Phase 16-20 records and Phase 21's blocker entry
- `specs/867_formalize_gabbay_separation_ztime/reports/01_gabbay-separation-ztime-plusformula.md` —
  the research report whose six findings shape the plan
- `specs/867_formalize_gabbay_separation_ztime/prototype/cases-5-8-reduction.lean` — the Phase 16
  gate record: the source-quoted reduction DAG, five compiled probe models, the refutation of the
  two-disjunct repair, and the Case 8 non-redundancy model
- `specs/867_formalize_gabbay_separation_ztime/prototype/cases-5-8-probe.lean` — Phase 5's
  superseded gate record, left verbatim
- `FormalSystem/Metalogic/Expressiveness/SeparationZ/README.md` — the subtree's module table and
  status
- Gabbay, Hodkinson and Reynolds, *Temporal Logic: Mathematical Foundations and Computational
  Aspects*, vol. 1, Chapter 10 §10.2 — Lemmas 10.2.1-10.2.4 as transcribed, with the two printed
  defects recorded at the declarations that repair them
