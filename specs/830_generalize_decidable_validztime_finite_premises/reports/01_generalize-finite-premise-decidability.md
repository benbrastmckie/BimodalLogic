# Research Report: Generalizing the ZTime Decision Procedure to Finite Premises

**Task**: 830 - Generalize `Compression.decidableValidZTime` from the empty-premise case to arbitrary finite premises
**Started**: 2026-11-12T00:00:00Z
**Completed**: 2026-11-12T00:00:00Z
**Effort**: ~1 dispatch (research); implementation estimated small-to-medium (transcription, no new mathematics)
**Dependencies**: None
**Sources/Inputs**:
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Compression/README.md`
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Compression/{Assembly,Family,Enumerate,Extract,Types}.lean`
- `FormalSystem/Metalogic/Decidability/WitnessFamily/{Basic,Predicates,Closure,Agreement,Decide}.lean`
- `FormalSystem/Semantics/{Validity,IntTransfer}.lean`
- `FormalSystem/Metalogic/StrongCompleteness.lean`
- `FormalSystem/Metalogic/ZTimeProvability.lean`
- `docs/theorem-index.md`
- lean-lsp MCP (`lean_run_code`), `lake env lean` via `lake-build-guard.sh`, `scripts/check-module-invariants.sh`
**Artifacts**:
- `specs/830_generalize_decidable_validztime_finite_premises/reports/01_generalize-finite-premise-decidability.md`
- `specs/830_generalize_decidable_validztime_finite_premises/reports/01_verified-general-form.lean`
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **The whole residue compiles.** All three items the `Compression/README.md` enumerates as
  unproved — the consequence-form carrier normalization, `WitnessFamily.Target`'s premise
  clause, and `Enumerate.lean`'s `φ`-specializations — were written out and elaborated
  sorry-free against the current tree. The README's caveat "it is unproved … the general form is
  not known to compile" is discharged.
- **The risk-bearing item was not risky.** The consequence analogue of `validZTime_iff_validInt`
  compiled on the first attempt, mirroring that lemma's own proof. `truthAt_map` is stated at a
  fixed aligned triple and quantified over the formula, so one aligned pair discharges every
  premise and the conclusion together; no new transfer machinery is needed.
- **A second, four-line route exists, and a recorded claim blocking it is false.**
  `Compression/README.md:116-121` and `Assembly.lean`'s docstring both state that the *reduction*
  route is unavailable because the tree has no context-conjunction deduction theorem.
  `StrongCompleteness.lean:262`'s `semantic_deduction_in` is exactly that theorem in
  iterated-implication form, generic in the frame class, already proved. Correcting that claim is
  required work wherever it appears.
- **Everything measures at the required axioms.** All four headline declarations of the direct
  route, and the reduction-route corollary, pin to exactly
  `[propext, Classical.choice, Quot.sound]`.
- **Scope, restated.** This strengthens the base-language result only. `ValidZTime` is stated for
  `FormalSystem.Syntax.Formula`, which carries no stability operator, so nothing here advances
  the L+ aim (`Decidable (PlusValidZTime φ)`).

## Context & Scope

The task asks for the general finite-premise form of the witness-family decision procedure:
`Decidable (SemanticConsequenceIn FrameClass.ZTime Γ σ)` at arbitrary finite `Γ`, where
`decidableSemanticConsequenceNil` currently covers `Γ = []` only.

Research was conducted by compiled probe rather than by argument: each residue item was written
out in full and elaborated, so the findings below are measured, not estimated. The probe text is
preserved as a transcription target at
`specs/830_generalize_decidable_validztime_finite_premises/reports/01_verified-general-form.lean`
(394 lines, namespaced `Probe830`, not part of the build).

Constraints carried from the dispatch and honored here: no `sorry` deferral and no new axioms; no
performance work (`cands` is astronomically large and [GKWZ] §6.5's EXPSPACE-hardness lower bound
for `PTL × S5` makes that the literature's cost, not an encoding artefact); no claim that this
advances L+ Stage 1.

One path assertion in the dispatch is wrong and is corrected here:
`FormalSystem/Metalogic/Decidability/WitnessFamily/Target.lean` does not exist.
`WitnessFamily.Target` is defined in `Predicates.lean:115`.

## Findings

### Codebase Patterns

**Everything downstream of the entry point is already general.** Verified by reading the
signatures: `WitnessFamily` (`Basic.lean:167`), `Target`/`Certifies`/`LocalCoherentLab`/
`BoxFaithful` (`Predicates.lean`), `Refutes`/`joint_countermodel`/`refutes_of_certifies`
(`Agreement.lean:248-284`), `decidableCertifies` (`Decide.lean:936`), `compressionBound` and
`exists_labelledLasso_of_history_realized` (`Extract.lean:311,342`), and `typeAtM`
(`Types.lean:81`) are each stated at arbitrary `Γ Del`. The dispatch's inventory of these is
accurate.

**Residue item 2 is smaller than "a premise clause".** `Target` is *already* stated at arbitrary
`Γ`: `(∀ γ ∈ Γ, γ ∈ W.main t) ∧ (∀ σ ∈ Del, σ ∉ W.main t)` (`Predicates.lean:115-116`). What is
`Γ = []`-specific is only its *discharge* inside the compression theorem, where
`Family.lean:309` uses `List.not_mem_nil`. The general discharge is the three-line mirror of the
conclusion clause beside it, using `WitnessFamily.premise_mem_closure` (`Predicates.lean:136`,
already present) and `mem_typeAtM.mpr`.

**Residue item 3's only real obstacle is a computable universe list.** `Enumerate.lean`'s header
records why `closureSubsetsOf` is indexed by a formula: `Finset.toList` is noncomputable, and
only a formula carries a computable underlying list (`Formula.subformulas φ`). At arbitrary
`Γ ++ Del` the analogue is `(Γ ++ Del).flatMap Formula.subformulas`, which computes and has
exactly `closureOf (Γ ++ Del)`'s members — because `closureOf` is a `foldr (· ∪ ·)` over
`List.map subformulaClosure` (`Closure.lean:54`) and `subformulaClosure χ` is
`(Formula.subformulas χ).toFinset` (`SubformulaClosure/Closure.lean:36`). With that one new
definition, the remaining five `φ`-specializations transcribe verbatim with
`closureOf ([] ++ [φ])` replaced by `closureOf (Γ ++ Del)`.

**`Enumerate.lean` has no external consumers.** `closureSubsetsOf`, `rawLabelledLassos`,
`IsLabelledLasso`, `boundedLassos`, `cands` and `mem_cands_of_bounded` are referenced only from
`Assembly.lean` (a repo-wide grep over `*.lean` returns no other use; the `cands=` strings in
`Tests/BimodalTest/Metalogic/Decidability/RegionGateProbe.lean` belong to an unrelated
`candidateGrid` probe). They can therefore be generalized in place.

**No new imports are required for the direct route.** The consequence-form normalization uses
`truthAt_map`, `intIso`, `aligned_map` and the `sat_intro` macro, all from
`FormalSystem.Semantics.IntTransfer`, which `Family.lean:9` already imports.

### Compiled Verification

Each result below was elaborated against the current tree. The direct-route declarations were
run twice: once through `lean_run_code`, once through
`lake-build-guard.sh build --timeout 540 -- env lean <probe file>` (exit 0, no diagnostics), the
latter also emitting the axiom measurements.

| Item | Declaration probed | Result |
|---|---|---|
| Residue 1 | `consequenceZTime_iff_consequenceInt` | compiles; `[propext, Classical.choice, Quot.sound]` |
| Residue 3 | `closureList`, `closureSubsetsOfC`, `rawLabelledLassosC`, `IsLabelledLassoC`, `boundedLassosC`, `candsC`, `mem_candsC_of_bounded` | all compile |
| Residue 2 + compression | `exists_witnessFamily_of_not_consequence` | compiles; `[propext, Classical.choice, Quot.sound]` |
| Criterion | `consequence_iff_noCertifiedCandidate` | compiles; `[propext, Classical.choice, Quot.sound]` |
| Procedure | `decidableSemanticConsequenceZTime` | compiles as a plain `def` (computes); `[propext, Classical.choice, Quot.sound]` |
| Reduction route | `decidableSemanticConsequenceZTime_reduction` | compiles; `[propext, Classical.choice, Quot.sound]` |

The compression theorem's 180-line proof generalizes with exactly **two** edits: step 0 becomes
`rw [consequenceZTime_iff_consequenceInt]` followed by `simp only [ConsequenceInt, not_forall]`
(which yields the premise hypothesis alongside the failure hypothesis — `Classical.not_imp` is
not needed and the linter flags it as unused), and `htgt`'s first component becomes the mirror
described above. Every other line is unchanged modulo `[] [φ] ↦ Γ [σ]`.

`scripts/check-module-invariants.sh` passes on the working tree with the probe artifact present
(`ALL CHECKS PASSED`), confirming the artifact file itself introduces no regression.

### The Reduction Route, and a False Recorded Claim

`Compression/README.md:116-121` states:

> The obstruction is narrower than it may look: a context-conjunction deduction theorem — which
> the tree does not have — is what the *reduction* route (`Γ ⊨ σ` from `⊨ ⋀Γ → σ`) needs

`Assembly.lean:55-59` restates it: "the tree has none: there is no `Context.conj`, `bigConj` or
equivalent."

The literal half is true — there is no `Context.conj`. The conclusion drawn from it is not. The
reduction does not need a conjunction; it needs the premises discharged one at a time, and
`FormalSystem/Metalogic/StrongCompleteness.lean:262` supplies exactly that, generic in the frame
class:

```lean
theorem semantic_deduction_in {fc : FrameClass} (Γ : Context) (φ : Formula) :
    SemanticConsequenceIn fc Γ φ ↔ ValidIn fc (Γ.foldr Formula.imp φ)
```

`Γ.foldr Formula.imp φ` is `γ₁ → (γ₂ → … → φ)`, the curried equivalent of `⋀Γ → φ`. Composed
with the existing `Compression.decidableValidZTime`, this yields the task's deliverable in four
lines, measured at the required axioms:

```lean
def decidableSemanticConsequenceZTime (Γ : Context) (σ : Formula) :
    Decidable (SemanticConsequenceIn ProofSystem.FrameClass.ZTime Γ σ) :=
  letI := Compression.decidableValidZTime (Γ.foldr Formula.imp σ)
  decidable_of_iff (ValidZTime (Γ.foldr Formula.imp σ)) (semantic_deduction_in Γ σ).symm
```

The two routes are not redundant. The reduction route produces a `Decidable` and nothing else:
its candidate objects are `WitnessFamily [] [Γ.foldr Formula.imp σ]`, which fold the premises
into the conclusion formula. The direct route produces a decision *criterion* whose candidates
are `WitnessFamily Γ [σ]` — the shape `Basic.lean`'s "Field names are an export contract" and
`Closure.lean`'s "Why not index by a single formula" say the certificate layer exists to have,
because the model checker's JSON export names `Γ` and `Δ` separately. Only the direct route
delivers a general-`Γ` enumerated criterion against that contract.

**Import siting.** `StrongCompleteness.lean` does not import the Decidability tree, so no cycle
exists in either direction. But importing it *into* `Compression/` would pull `Soundness.lean`
and `BXCanonical/CompletenessDedekind.lean` into a subdirectory whose README is explicit about
keeping its dependency surface minimal. `FormalSystem/Metalogic/ZTimeProvability.lean` already
imports `Compression/Assembly.lean` plus `Soundness` and `BXCanonical.Completeness`, and is
already the module where the decidability results are composed with completeness; the reduction
corollary belongs there, at the cost of one added import.

### Recommendations

- **Land the direct route in `Compression/`, transcribed from the verified probe.** Generalize
  `Enumerate.lean`'s five definitions in place from `φ` to `Γ Del` (adding `closureList` and
  `mem_closureList` first), generalize `Family.lean`'s compression theorem with the two edits
  named above, add the consequence-form normalization, and add the criterion and procedure to
  `Assembly.lean`. No new imports.
  `[VERIFIED: PASS — all six declarations elaborated via lake-build-guard.sh build -- env lean on specs/830_generalize_decidable_validztime_finite_premises/reports/01_verified-general-form.lean, exit 0, zero diagnostics; #print axioms on each of consequenceZTime_iff_consequenceInt, exists_witnessFamily_of_not_consequence, consequence_iff_noCertifiedCandidate and decidableSemanticConsequenceZTime reports exactly [propext, Classical.choice, Quot.sound]]`
- **Keep the `φ`-indexed names as thin wrappers over the context-indexed ones**
  (`cands φ := candsC [] [φ]`, and likewise for the others), so that
  `validZTime_iff_noCertifiedCandidate` — pinned in `docs/theorem-index.md:207` under C14 — keeps
  its current statement and the pinned-name set does not churn.
  `[No compiled gate applicable]`
- **Land the reduction corollary in `ZTimeProvability.lean`, not in `Compression/`.** Four lines,
  one added import (`FormalSystem.Metalogic.StrongCompleteness`); it is the cheapest honest
  statement of the headline result and is worth having beside the direct route.
  `[VERIFIED: PASS — decidableSemanticConsequenceZTime_reduction elaborated via lean_run_code importing both Compression.Assembly and StrongCompleteness, zero error diagnostics; #print axioms reports exactly [propext, Classical.choice, Quot.sound]]`
- **Correct the false claim wherever it appears.** `Compression/README.md:114-129`,
  `Assembly.lean`'s "Scope: no premises, and no stability modal" section, and
  `Family.lean`'s header all need rewriting once the general form lands: the residue is no
  longer residue, and the "tree has no deduction theorem" sentence is wrong independently of this
  task. `FormalSystem/Metalogic/Decidability/WitnessFamily/README.md:97` needs its module-table
  row updated.
  `[No compiled gate applicable]`
- **Add `docs/theorem-index.md` rows for each new headline declaration**, following the existing
  Decidability-section rows (`pcq pinned:C14` for the criterion and procedure). The axiom
  measurements above are the evidence those rows assert.
  `[No compiled gate applicable]`
- **Do not file performance work.** `candsC Γ [σ]` is at least as large as `cands φ`, and the
  cost is the literature's own.
  `[No compiled gate applicable]`

## Decisions

- **Research proceeded by compiled probe rather than by argument.** The dispatch named item 1 as
  risk-bearing on the strength of a README caveat; the only way to settle that was to write it.
  It cost one tool call.
- **The probe text is preserved as an artifact**, not merely described in prose, so the
  implementation phase transcribes verified text instead of re-deriving it.
- **The direct route is recommended as the primary deliverable** despite the reduction route
  being four lines, because only the direct route produces a general-`Γ` criterion in the
  exported certificate shape. The reduction route is recommended additionally, not instead.
- **The false README/docstring claim is reported rather than quietly worked around.** It is
  restated in `specs/reviews/review-2026-11-02.md` and in this task's own description, so it has
  already propagated once.

## Risks & Mitigations

- **Territory collision on `WitnessFamily/README.md`.** That file is in concurrent task 817's
  declared `file_scope` this same orchestrate cycle. Mitigation: 817's dispatch is a *research*
  phase, so the overlap is read-only for now; the implementation phase here must re-read the file
  immediately before editing it and stage only its own hunk.
- **`Finset.toList` noncomputability.** `closureList` avoids it by construction, and the
  `boundedLassosC`/`candsC` probes compiled as plain `def`s (no `noncomputable`), which is the
  evidence that computability survived the generalization. The implementation must not introduce
  `noncomputable` on any of these.
- **Vacuous-`Decidable` trap.** `decidableSemanticConsequenceZTime` takes no hypothesis and is a
  plain computable `def`, so `rules/lean4.md`'s `noncomputable`-`Decidable` prohibition does not
  bite. It must stay a `def`, not an `instance`, for the reason `Assembly.lean`'s header gives.
- **Statement drift on `Del`.** The enumeration generalizes in `Del` as well as `Γ`, but
  `SemanticConsequenceIn` is single-conclusion, so the headline result is stated at `Del = [σ]`.
  A multi-conclusion form would be free from the same machinery; it is not in scope and should
  not be added speculatively.

## Tactic Survey Results

No tactic survey was performed, and none was warranted: every proof in the general form is a
transcription of an existing proof whose tactic script already works, and each transcription
elaborated on its first attempt. The one tactic-level observation worth recording is a
simplification, not a search result:

| Goal | Tactic | Result | Premises/Config |
|---|---|---|---|
| Destructure `¬ ConsequenceInt Γ σ` into carrier, model, history, time, premise hypothesis and failure hypothesis | `simp only [ConsequenceInt, not_forall]` | success | `Classical.not_imp` is *not* required — `not_forall` peels the premise implication too, and including `Classical.not_imp` draws an unused-simp-argument linter warning |

## Context Extension Recommendations

- **Topic**: Recorded-claim verification before citation.
- **Gap**: `rules/lean4.md` and the Lean context pointers cover blocked MCP tools, build
  discipline and literature fidelity, but nothing instructs an agent to re-derive a *negative*
  claim ("the tree does not have X") recorded in a module docstring before building on it. The
  false deduction-theorem claim found here had propagated from `Assembly.lean` into
  `Compression/README.md`, into `specs/reviews/review-2026-11-02.md`, and into this task's own
  description.
- **Recommendation**: add a short section to
  `.claude/context/project/lean4/patterns/dependency-tracing.md` (or a sibling pattern file) on
  verifying recorded absence claims by `lean_local_search` plus a grep for the *concept* rather
  than the named shape — here, searching for "deduction" rather than for `Context.conj` would
  have surfaced `semantic_deduction_in` immediately.

## Appendix

**Probe artifact**:
`/home/benjamin/Projects/BimodalLogic/specs/830_generalize_decidable_validztime_finite_premises/reports/01_verified-general-form.lean`

**Reproduce the direct-route verification**:

```bash
cd /home/benjamin/Projects/BimodalLogic
timeout 560 bash .claude/scripts/lake-build-guard.sh build --timeout 540 -- env lean \
  specs/830_generalize_decidable_validztime_finite_premises/reports/01_verified-general-form.lean
```

Expected: exit 0, four `#print axioms` lines each reporting
`[propext, Classical.choice, Quot.sound]`.

**Declaration references consulted** (all re-grepped during this dispatch, per the dispatch's
standing instruction):

| Declaration | Location |
|---|---|
| `Compression.decidableValidZTime`, `decidableSemanticConsequenceNil`, `validZTime_iff_noCertifiedCandidate` | `Compression/Assembly.lean:147,161,113` |
| `exists_witnessFamily_of_not_validZTime`, `closureOf_nil_singleton`, `semanticConsequenceIn_nil_iff`, `boxedPart` | `Compression/Family.lean:153,113,118,91` |
| `closureSubsetsOf`, `rawLabelledLassos`, `IsLabelledLasso`, `boundedLassos`, `cands`, `mem_cands_of_bounded` | `Compression/Enumerate.lean:128,162,192,202,245,258` |
| `compressionBound`, `exists_labelledLasso_of_history_realized` | `Compression/Extract.lean:311,342` |
| `typeAtM`, `mem_typeAtM` | `Compression/Types.lean:81,86` |
| `WitnessFamily`, `LabelledLasso` | `WitnessFamily/Basic.lean:167,75` |
| `Target`, `Certifies`, `premise_mem_closure` | `WitnessFamily/Predicates.lean:115,132,136` |
| `Refutes`, `joint_countermodel`, `refutes_of_certifies` | `WitnessFamily/Agreement.lean:269,248,282` |
| `decidableCertifies` | `WitnessFamily/Decide.lean:936` |
| `closureOf`, `mem_closureOf` | `WitnessFamily/Closure.lean:54,63` |
| `truthAt_map`, `ValidInt`, `validZTime_iff_validInt` | `Semantics/IntTransfer.lean:300,315,338` |
| `ConsequenceOnFrames`, `SemanticConsequenceIn`, `ValidZTime` | `Semantics/Validity.lean:81,90,638` |
| `semantic_deduction_in`, `SemanticConsequenceZTime` | `Metalogic/StrongCompleteness.lean:262,1052` |
| `decidableDerivableZTime` | `Metalogic/ZTimeProvability.lean:105` |

**Corrected path assertion**: the dispatch's
`FormalSystem/Metalogic/Decidability/WitnessFamily/Target.lean` does not exist;
`WitnessFamily.Target` is in `Predicates.lean`.

**Literature**: no literature source was supplied with this dispatch. [GKWZ] 2003 §6.5 is cited
only for the EXPSPACE-hardness lower bound already recorded in `Assembly.lean`'s header; nothing
here re-derives or extends it.
