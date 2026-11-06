# Implementation Plan: Gabbay Separation over ZTime for L⁺

- **Task**: 867 - Formalize Gabbay separation over discrete time for `PlusFormula`, discharging `SeparationOver TaskFrame.IsZTime` and making the open-future translation executable
- **Status**: [IMPLEMENTING]
- **Effort**: 53.5 hours (27 recorded for Phases 1-15; 26.5 added for Phases 16-27)
- **Dependencies**: None blocking. Consumes only already-compiled declarations.
- **Research Inputs**: specs/867_formalize_gabbay_separation_ztime/reports/01_gabbay-separation-ztime-plusformula.md;
  the blocker-research findings carried in
  specs/867_formalize_gabbay_separation_ztime/.dispatch/11-aux-plan-revision.md (dispatch 11)
- **Artifacts**: plans/01_gabbay-separation-ztime-plusformula.md (this file)
- **Reports Integrated**: 01_gabbay-separation-ztime-plusformula.md; the blocker-research
  findings of dispatch 11, which arrived as delegation context rather than as a report file
  (no `.blocker-research.json` was written by the dispatch that produced them)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

A new subtree `FormalSystem/Metalogic/Expressiveness/SeparationZ/` carries GHR Lemmas 10.2.1
through 10.2.8 and Theorem 10.2.9 over an auxiliary until/since syntax whose leaves are abstract
predicates `ℕ → ℤ → Prop`, not over `PlusFormula` directly. The development is pure combinatorics
over `ℤ`; it meets `PlusFormula` at exactly one seam, a leaf abstraction whose two interface
lemmas (truth transfer and syntactic purity) carry the separated form back into the shape
`SeparationOver` asks for. The deliverable is two additive things: the proof term
`separationOver_ztime`, which discharges the hypothesis every `tr` row in
`OpenFutureElimination.lean` currently takes, and a computable `sepZ`/`trZ` pair that makes the
ZTime translation executable without touching the frozen `noncomputable tr`.

Phases 1-4 and 6 of this plan are landed and compiled; Phase 5's decision gate measured 1 of 4
and closed Phases 7-15 as `[COMPLETED WITH EXCLUSIONS]`. That measurement rested on a route
defect, not on a mathematical obstruction: the derivation method it tried for Cases 6-8 is not the
one GHR 10.2.3 uses, and the separatedness bar it held each candidate to is stronger than the one
GHR 10.2.4 consumes. Phases 16-27 reach the excluded deliverables along the source's own reduction
order. Phases 1-15 stay exactly as recorded, including their exclusions: they are the measurement
Phase 16 re-specifies, not work to be rewritten.

Definition of done: `separationOver_ztime` and the six companion declarations of
`## Lean Challenge Statements` compile sorry-free with measured axiom profiles; the ZTime rows of
`docs/theorem-index.md` and the host module's docstring no longer say the separation hypothesis is
unformalized in this tree; `check-module-invariants.sh` and `check-metalogic-cycles.sh` are green
against their pre-task baselines. Nothing in `Independence/` is touched, no existing signature
changes, and the RTime rows stay conditional.

### Research Integration

Six findings from `reports/01_gabbay-separation-ztime-plusformula.md` shape this plan decisively,
and three of them change what gets built rather than merely how:

1. **The target reduces to the single carrier `ℤ`.** `SeparationOver`'s equivalence conjunct is,
   after unfolding `FrameClass.Sat .ZTime F = F.IsRegular ∧ F.IsZTime`, precisely
   `PlusValidZTime (φ.iff (sepForm L))`, and the compiled
   `FormalSystem.PlusLanguage.plusValidZTime_iff_plusValidInt` collapses that to validity over
   `FrameOver intOrder` at `t : ℤ`. Every hard lemma is therefore stated at concrete integers,
   with `omega` and `Int.exists_least_of_bdd` available, instead of over an abstract
   succ-Archimedean carrier whose `IsZTime` witness has no accessors by design.
2. **A direct `PlusFormula` route hits a real obstruction, so the auxiliary syntax is not a
   convenience.** GHR substitute formulas for atoms in four of their eight lemmas, and uniform
   substitution does not visibly preserve `PlusValidZTime`: `PlusFormula.atom p` is evaluated at
   `M.valuation (τ.state t)`, a function of the world state alone, while a substituend is
   history- and time-dependent. Abstracting leaves to arbitrary predicates makes every
   abstraction/resubstitution step a reindexing of the leaf valuation, so no substitution lemma
   is needed anywhere.
3. **Syntactic purity suffices, and the modal dimension costs nothing.** `IsPureFuture` and
   `IsPurePast` both take `box ψ` and `stab ψ` as leaf constructors for any `ψ`, so the leaves of
   the abstraction are simultaneously past- and future-determined, and the semantic
   `PastDet`/`FutDet` that `SepClauses` asks for comes free from the compiled
   `pastDet_of_isPurePast` / `futDet_of_isPureFuture`.
4. **GHR's printed Case 5 of Lemma 10.2.3 is refuted over integer time**, by a counterexample the
   report verified against the chapter-10 PDF rather than only the markdown chunk. Cases 5-8 are
   therefore reconstructed from the semantics and probed on concrete `ℤ` models before any proof
   is attempted (Phase 5), never transcribed.
5. **GHR's own dependency order makes 10.2.4 consume Cases 5-8**, so deriving those cases back
   from Theorem 10.2.9 — the route the archived Boneyard development takes — closes a loop. Cases
   5-8 are kept strictly upstream of 10.2.4 in this plan's phase order, and the archive's
   `_no_oracle` escape is not imported as settled (it sits behind an `#exit` and has never been
   typechecked).
6. **Discharging `SeparationOver` does not by itself make the translation executable.** `tr` reads
   its separated form off `Classical.choose` and its signature is frozen. Executability is the
   separate, additive Phase 13 deliverable: a computable `trZ` beside `tr`, which inhabits the
   translation slot of the already-generic `decidableOpenValidInOfTranslation` / `openDecider` /
   `openDecider_correct` with no signature change anywhere.

The report's own nine-phase sketch (R8) is refined here into fifteen, splitting its Phase 1 into
syntax and interface, its Phase 4 into an upstream probe gate and the proof itself, its Phase 6
into the two inductions it bundles, and its Phase 9 into translation, documentation and gate
sweep.

### Revision Integration: the Cases 6-8 Route Correction

Four findings from the blocker-research dispatch reach this plan through its delegation context
(dispatch 11; no report artifact was written). Two of them change the route, and two record
printed-text defects that the implementation must encode rather than repair silently.

1. **GHR 10.2.3 never derives Cases 6, 7 or 8 by direct semantic re-anchoring.** It derives each
   as a *reduction* to an earlier case, and the reduction order is acyclic: Cases 1 and 2 are
   base; Cases 4 and 5 are independent semantic arguments; Case 8 follows from a generic
   negated-since distribution identity plus Case 5; Case 7 from Cases 8 and 4; Case 6 from Cases 3
   and 5. The re-anchoring method Phase 5 used is what produces the unexpressible `∃∀`
   guard-failure condition recorded in its gate measurement, and the Cases 5/8 circularity that
   measurement records is an artefact of it: with Case 5 proved semantically, the edge from Case 8
   to Case 5 runs one way only.
2. **GHR 10.2.4 consumes a precondition strictly weaker than the landed `IsSeparated`.** Phase 5
   therefore measured each candidate against a bar the source itself does not meet at that step.
   The weaker predicate — every `untl` occurrence is the single type `untl B A` and none sits under
   a `snce` — is stated in its own right in Phase 20, and 10.2.4's input position is never given
   the stronger bar.
3. **The Case 5 bracketing bug has a two-disjunct repair** far simpler than the `P`/`Ev`/`Inner`
   candidate Phase 5 pinned. Phase 16 probes it on the three models already compiled in
   `prototype/cases-5-8-probe.lean` and pins whichever candidate survives; the heavier candidate
   is the recorded fallback, not the default.
4. **GHR's claim that Case 8's third disjunct is redundant is false.** Phase 16 exhibits a `ℤ`
   model and a point at which that disjunct is the only true one, and Phase 18 keeps all three
   disjuncts with that model cited at the definition.

### Prior Plan Reference

No prior plan. `prior_plan_path` was not provided in this dispatch's delegation context and
`plans/` did not exist before this file.

### Roadmap Alignment

No `roadmap_path` was provided in this dispatch's delegation context and no roadmap flag is set,
so no roadmap consultation applies and no roadmap phases are added.

## Goals & Non-Goals

**Goals**:

- `sepZ` -- the computable separation function on L⁺ formulas, returning the clause list.
- `sepZ_sepClauses` -- every clause `sepZ` returns is a (past-determined, future-determined) pair.
- `plusTruthAt_sepZ_iff` -- `sepZ` preserves truth pointwise on every regular ZTime frame.
- `separationOver_ztime` -- the discharge: `SeparationOver TaskFrame.IsZTime`, the hypothesis
  every `tr` row currently takes.
- `trZ` -- the computable ZTime translation of the open-future language into L⁺.
- `openTruthAt_iff_trZ` -- `trZ` preserves truth at every model, history and time of a regular
  ZTime frame.
- `openValidIn_ztime_iff_trZ` -- unconditional validity transfer at `.ZTime` along `trZ`.

**Non-Goals**:

- GHR Theorem 10.3.20, the Dedekind-complete counterpart. The `RTime` rows stay conditional and
  no row, docstring or README cell may read otherwise.
- Any change to an existing signature. `tr` stays `noncomputable`, keeps its name, and keeps
  taking `hsep` explicitly; `SeparationOver`, `SepClauses`, `sepForm`, `ofutElim`, `opastElim` and
  the four eliminations are consumed verbatim and never restated.
- `FormalSystem/Metalogic/Independence/`. The non-definability verdict at Base and Dense is a
  separate result, unaffected because separation does not hold there.
- The metalogic-cycles allowlist. No new module may import any `FormalSystem.Metalogic.<other>`
  subdirectory, which is what keeps assertion B unperturbed.
- A uniform `noncomputable` `Decidable (OpenValidIn FrameClass.ZTime φ)`. The host module's
  docstring records that shape as deliberately rejected and `lean4.md` classes it as a vacuity
  violation.
- `FormalSystem/PlusLanguage/README.md` and the `.claude/` context notes the research report
  recommends. The first is inside sibling task 871's declared `file_scope` this same cycle; the
  second is a deploy-artifact path governed by `rules/source-store-deploy-boundary.md`. Both are
  deferred rather than claimed here.
- Repairing `FormalSystem/Metalogic/Expressiveness/Separation/README.md`'s stale eleven-module
  table. The research report records it and proposes no action; this plan takes none.
- Adding any row to `FormalSystem/MainResults.lean`. The elimination layer is deliberately off it
  for the reason already recorded there.

## Lean Challenge Statements

```lean
import FormalSystem

namespace FormalSystem.Metalogic.Expressiveness

open FormalSystem.Syntax
open FormalSystem.Semantics
open FormalSystem.PlusLanguage
open FormalSystem.OpenLanguage
open FormalSystem.ProofSystem

def sepZ : PlusFormula → List (PlusFormula × PlusFormula) := sorry

theorem sepZ_sepClauses (φ : PlusFormula) (F : TaskFrame) (hreg : F.IsRegular)
    (hz : F.IsZTime) : SepClauses F (sepZ φ) := sorry

theorem plusTruthAt_sepZ_iff (φ : PlusFormula) {F : TaskFrame} (hreg : F.IsRegular)
    (hz : F.IsZTime) (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration) :
    PlusTruthAt M τ t φ ↔ PlusTruthAt M τ t (sepForm (sepZ φ)) := sorry

theorem separationOver_ztime : SeparationOver TaskFrame.IsZTime := sorry

def trZ : OpenFormula → PlusFormula := sorry

theorem openTruthAt_iff_trZ {F : TaskFrame} [F.IsRegular] (hz : F.IsZTime)
    (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration) (φ : OpenFormula) :
    OpenTruthAt M τ t φ ↔ PlusTruthAt M τ t (trZ φ) := sorry

theorem openValidIn_ztime_iff_trZ (φ : OpenFormula) :
    OpenValidIn FrameClass.ZTime φ ↔ PlusValidIn FrameClass.ZTime (trZ φ) := sorry

end FormalSystem.Metalogic.Expressiveness
```

The internal until/since layer (`USForm`, `usTruth`, the measures, the eliminations, the
inductions) is deliberately absent from this section. Those declarations live in the
`SeparationZ.` sub-namespace, are implementation structure rather than contract, and their exact
shapes are fixed by the phases below instead; pinning them here would freeze an internal
decomposition that Phases 1-11 are entitled to refine.

## Decisions

Four plan-time decisions refine the research report. Each is a judgement between known-workable
options, recorded here so an implementation dispatch does not reopen it.

**D-a. Leaves are indexed by `ℕ`, not `Fin n`.** The report's illustrative sketch parameterizes
the syntax as `USForm (n : ℕ)` with `leaf : Fin n → USForm n` and flags its own names as
illustrative. A single unparameterized `USForm` with `leaf : ℕ → USForm` and a valuation
`ℕ → ℤ → Prop` is taken instead: GHR's fresh-atom steps then pick an index above the formula's
own `maxLeaf` with no dependent-index casting, and the abstraction/resubstitution reindexings of
Lemmas 10.2.5 through 10.2.8 become plain function updates on the valuation. `Fin n` would force
a `Fin`-cast obligation at every one of those steps for no mathematical gain.

**D-b. Separation is targeted syntactically, as `IsUOnly`/`IsSOnly` purity on `USForm`, carried
to `IsPurePast`/`IsPureFuture` on `PlusFormula`.** GHR's own remark that syntactic separation
implies separation is the bridge, and the compiled purity-to-determinacy lemmas close the gap to
`SepClauses` frame-independently. The semantic route would have to re-derive determinacy at every
step.

**D-c. The leaf table is a `List PlusFormula` read by index, not a `Finset` or a map.** `leaves φ`
is computable, order-deterministic and duplicate-free, `toPlus` reads it with `getD`, and the
roundtrip `toPlus (leaves φ).getD (abstr φ) = φ` is one structural induction. This is what makes
`sepZ` computable by construction rather than by later repair.

**D-d. Cases 5-8 of Lemma 10.2.3 are probed before they are proved, in a phase of their own.**
Phase 5 is a decision gate, not a formality: its measurement on concrete `ℤ` leaf valuations is
what licenses Phase 7, and its failure is the plan's own contingency trigger (see
`## Rollback/Contingency`).

**D-e. Cases 6, 7 and 8 are reached by reduction to earlier cases, never by direct semantic
re-anchoring.** The reduction DAG of the Research Integration addendum's finding 1 is the route,
and Phase 16's gate criterion (b) is its admission test: every edge must be nameable at a source
step and the DAG must be acyclic. This replaces D-d's gate criterion for the three cases Phase 5
could not pin — probing is retained, but what is probed is a reduction's instantiation, not a
semantically re-derived right-hand side. A dispatch that re-derives the re-anchoring has repeated
the measured defect, not confirmed it.

**D-f. GHR 10.2.4's input precondition is its own predicate, strictly weaker than
`IsSeparated`.** `IsSeparated` stays exactly as landed in `Eliminations.lean` and remains what
10.2.4's *conclusion* and Theorem 10.2.9 carry. The new predicate serves only input positions, so
that no induction step is asked for purity the source does not demand. Approximating the
precondition by `IsSeparated` is what made Phase 5's bar unmeetable, and re-imposing it anywhere
downstream reintroduces that defect.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Cases 5-8 of GHR 10.2.3 resist reconstruction. The printed Case 5 is refuted over `ℤ` and Cases 6-8 are published as reductions with acknowledged gaps. | H | M | Phase 5 probes every candidate on small concrete `ℤ` valuations, including the adjacent-point degeneracies (`(t, t+1) ∩ ℤ = ∅`) that refuted the printed form, before Phase 7 attempts a proof. Start from the gloss-consistent Case 5 reconstruction the research report already tested against the known counterexample. A case that resists after probing is the precisely-located obstruction the dispatch accepts. |
| Circularity: GHR's 10.2.4 consumes Cases 5-8, while the archived Boneyard development derives those cases *from* the final theorem. | H | M | Phase order fixes the direction: Phases 6 and 7 (all eight cases) are strictly upstream of Phase 8 (10.2.4). The archive's `_no_oracle` variants sit behind an `#exit` and have never been typechecked -- they must not be cited as having broken the loop. |
| Junction-depth strict decrease is asserted, not proved, in the source. GHR's 10.2.6-10.2.8 each claim a measure drops under abstract-separate-resubstitute with no proof. | H | M | Phase 11 defines the measure as a structural recursion on `USForm` and proves each decrease lemma as a named obligation, with the archive's `jd_untl_le_left`-style bounds read as a shape hint and re-derived, never trusted. |
| Occurrence-level reasoning ("the most deeply nested `S(C,F)` in which `U(A,B)` appears") has no direct Lean counterpart. | M | H | Every measure is restated structurally on the syntax tree in the phase that introduces it (Phases 9, 10, 11), and the `ℕ`-indexed leaves of decision D-a keep subterms index-addressable. |
| The `FrameOver intOrder` carrier ascription bites. `plusValidZTime_iff_plusValidInt`'s own proof carries a comment that Lean cannot invert `↑E ≟ ℤ` to recover `E := intOrder`, so the target must be ascribed at `↑intOrder`. | M | H | Phase 2 lands the carrier bridge once, with the ascription written explicitly, and every later phase consumes that one lemma rather than re-deriving the transfer. If an ascription error appears downstream, fix the bridge's statement, not the call site. |
| CNF packaging blow-up: converting a separated Boolean combination into binary `sepForm` clauses can enlarge terms and slow elaboration. | M | M | `SeparationOver` places no size bound, so correctness is the whole requirement. Phase 12 keeps packaging a separate module with its own truth-preservation lemma; if elaboration slows, profile the packaging function rather than restructuring the mathematics. |
| `sepZ` or `trZ` accidentally noncomputable. A stray `Classical.choose` or a decidability gap would silently defeat the executability deliverable. | M | M | Both are declared as plain `def`s with no `noncomputable` keyword, so the compiler enforces it. If Lean demands the keyword, the construction is wrong and the phase is `[BLOCKED]` -- adding the keyword is not the fix. |
| Build cost: the subtree sits downstream of `OpenLanguage`, so an unscoped rebuild is expensive. | M | H | Scoped guarded builds per phase; the unscoped build runs only in Phase 15. Detach as a shell-level background job and block with the bounded single-call idiom per `context/patterns/bounded-build-waiter.md`; never `Bash(run_in_background: true)`. |
| C33 failure: `FormalSystem.lean` not byte-current after new modules land. | M | H | Every module-adding phase ends with `lake exe mk_all --lib FormalSystem` and commits the regenerated root; never hand-edit it. |
| readme-lint failure: a new directory with `.lean` files and no `README.md`, or a README with no "Last verified" date. | L | H | Phase 1 creates `SeparationZ/README.md` with the date line in the same commit as the first module, and each later phase adds its own module's row. |
| C28/C30 failure: a long new module exceeding its warning budget, or a blanket `set_option` to quiet a linter. | L | M | Keep modules focused (one lemma family each). If a file genuinely needs `linter.style.longFile`, that single option is C30's one sanctioned file-scoped exception; every other `set_option` must be declaration-scoped (`... in`) and carry a `--` reason comment above it per C29. |
| C14 baseline drift: appending to only one heredoc, or at mismatched positions. | H | M | Append matched pairs at the same trailing position in **both** `C14_BASELINE` and `C14LEAN`, directly after the existing `Expressiveness` lines, then re-measure. Every profile is pasted from measured `#print axioms` output; none is hand-typed. |
| Concurrency with siblings 871 (plan) and 884 (implement), dispatched this same cycle on this same tree. | M | M | This task's scope is the new `SeparationZ/` subtree plus narrow edits to `OpenFutureElimination.lean`, `Expressiveness.lean`, `Expressiveness/README.md`, `docs/theorem-index.md`, `scripts/check-module-invariants.sh` and the generated root -- disjoint from 871's `PlusLanguage/` files and 884's `specs/` files. Re-read every file immediately before editing, stage explicit file lists only, never `git-snapshot.sh` in its reverting default mode, and treat a build failure outside this task's file set as possibly a sibling's in-flight edit. On observing a foreign commit or foreign uncommitted modification, STOP and report after checking `git log`. |
| A reduction edge cannot be named at a source step, so the DAG is reconstructed rather than transcribed. | H | L | Phase 16's gate criterion (b) is exactly this test and is measured before any proof is attempted. A failing edge is recorded as the located obstruction at that edge, not worked around by returning to the re-anchoring route D-e forbids. |
| Case 8's right-hand side, with the non-redundant third disjunct kept, is large enough to slow elaboration downstream of Phase 20's clause-by-clause application. | M | M | `ElimHard.lean` stays a module of its own with its own scoped build. If elaboration slows, profile the clause application; a disjunct may be dropped only against a proof of its redundancy, never because a tactic happens to close the equivalence without it. |
| The junction-depth strict decrease — asserted without proof in the source — resists proof. It was never reached before, so it is now the live primary stall candidate rather than the secondary one. | H | M | Phase 23 defines the measure structurally and proves each decrease as a named obligation. Its contingency branch is the one added for this revision in `## Rollback/Contingency`; a `sorry` remains not an option. |
| A later reader cites Phase 5's superseded gate verdict, or Phase 7's exclusions record, as a standing mathematical obstruction. | M | M | Phase 16's gate measurement states in its own file that the verdict is superseded and why, and Phase 18's module docstring records that the Cases 5/8 loop was an artefact of the re-anchoring route. Phases 1-15 are left verbatim, so the correction lives where a reader of the new phases will meet it. |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |
| 6 | 6 | 5 |
| 7 | 7 | 6 |
| 8 | 8 | 7 |
| 9 | 9 | 8 |
| 10 | 10 | 9 |
| 11 | 11 | 10 |
| 12 | 12 | 11 |
| 13 | 13 | 12 |
| 14 | 14 | 13 |
| 15 | 15 | 14 |
| 16 | 16 | 15 |
| 17 | 17 | 16 |
| 18 | 18 | 17 |
| 19 | 19 | 18 |
| 20 | 20 | 19 |
| 21 | 21 | 20 |
| 22 | 22 | 21 |
| 23 | 23 | 22 |
| 24 | 24 | 23 |
| 25 | 25 | 24 |
| 26 | 26 | 25 |
| 27 | 27 | 26 |

Phases 1-15 are closed records. Phases 16-27 are the live sequence: Phase 16 re-specifies the
decision gate Phase 5 measured, and Phases 17-27 reach the deliverables Phases 7-15 excluded,
along the reduction order of decision D-e. Every module-adding phase among them also regenerates
`typst/generated/status.typ` in its own commit, because the pre-commit counts gate fires on each
one -- recorded as a gate-collision issue in this task's `issues.jsonl` at dispatch 7.

Phases within the same wave can execute in parallel. This plan is deliberately fully sequential:
Phases 2-5 are dependency-independent of one another in the mathematics, but every
module-adding phase rewrites the generated root `FormalSystem.lean` and the subtree README, so
running them concurrently would put two writers on the same two files for no gain.

### Phase 1: The Until/Since Syntax over Abstract Leaves [COMPLETED]

**Goal**: A new `SeparationZ/` subtree exists, registered and building, carrying the auxiliary
syntax `USForm`, its `ℤ`-indexed truth recursion `usTruth`, the derived connectives the GHR
development uses, the time-reflection `swap` with its involution, and the clause lemmas later
phases rewrite with.

**Tasks**:

- [x] Create `FormalSystem/Metalogic/Expressiveness/SeparationZ/` with the standard copyright
      header on every new file (checked by `scripts/check-copyright-headers.sh`).
- [x] Add `Syntax.lean` in namespace `FormalSystem.Metalogic.Expressiveness.SeparationZ`, with
      `inductive USForm` carrying `leaf : ℕ → USForm`, `bot`, `imp`, `untl` and `snce` --
      `untl`/`snce` taking **guard first, event second**, matching `PlusFormula.untl` and
      **opposite to GHR's `U(A, B)`** (GHR's `U(A,B)` is this repository's `untl B A`; every
      transcription flips).
- [x] Add `usTruth (v : ℕ → ℤ → Prop) (t : ℤ) : USForm → Prop`, whose `untl`/`snce` clauses are
      `PlusTruthAt`'s verbatim with `F.Duration` replaced by `ℤ` and the strict open-interval
      guard preserved.
- [x] Add the derived connectives `top`, `neg`, `and`, `or`, `iff`, `someFuture`, `somePast`,
      `allFuture` (GHR's `G`), `allPast` (GHR's `H`), `next`, `prev`, each defined by the same
      right-hand side its `PlusFormula` counterpart uses, so `toPlus` commutes with it by `rfl`.
- [x] Add the clause lemmas (`usTruth_imp_iff`, `usTruth_and_iff`, `usTruth_or_iff`,
      `usTruth_neg_iff`, `usTruth_untl_iff`, `usTruth_snce_iff`, `usTruth_allFuture_iff`,
      `usTruth_allPast_iff`), each a `simp`-usable `Iff`, since the Boolean rearrangement steps of
      Phases 3 and 8 rest entirely on them.
- [x] Add `swap : USForm → USForm` exchanging `untl` and `snce`, with `swap_involutive` and
      `usTruth_swap : usTruth v t (swap ψ) ↔ usTruth (fun i s => v i (-s)) (-t) ψ` (or the
      negation-reindexed equivalent the proof actually wants) -- this is the `USForm`-level
      counterpart of `plusValidIn_reflectTime_iff` and is what halves every later `snce` case.
- [x] Add `maxLeaf : USForm → ℕ` and `freshLeaf ψ = maxLeaf ψ + 1`, with
      `usTruth_congr_of_update`: updating `v` at an index above `maxLeaf ψ` does not change
      `usTruth v t ψ`. This is the whole content of GHR's "fresh atom" device.
- [x] Add `SeparationZ/README.md` with a module table and a `Last verified: {ISO_DATE}` line
      (required by `scripts/readme-lint.sh` check 1 and check 4).
- [x] Regenerate the library root: `lake exe mk_all --lib FormalSystem`. Never hand-edit
      `FormalSystem.lean`.
- [x] Confirm the new module imports no `FormalSystem.Metalogic.<other-subdirectory>` module --
      Mathlib plus `FormalSystem.Init` reachability only -- so `check-metalogic-cycles.sh`
      assertions A and B cannot be perturbed.

**Timing**: 2 hours

**Depends on**: none

**Verification Tier**: local

**Tier Justification**: The phase adds one new module with no external call site yet, so
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Expressiveness.SeparationZ.Syntax`
covers its entire blast radius; nothing downstream can observe a declaration that did not exist
before.

**Scope Hypothesis**: One new `.lean` module, one new `README.md`, and a regenerated
`FormalSystem.lean` whose diff adds exactly one `import` line. Confirm at implementation time by
`git diff --stat` showing exactly those three paths, and by `git diff -- FormalSystem.lean`
showing a single added line.

**Files to modify**:

- `FormalSystem/Metalogic/Expressiveness/SeparationZ/Syntax.lean` - new: `USForm`, `usTruth`,
  derived connectives, clause lemmas, `swap` and its involution, `maxLeaf`/`freshLeaf`.
- `FormalSystem/Metalogic/Expressiveness/SeparationZ/README.md` - new: module table plus
  `Last verified` line.
- `FormalSystem.lean` - regenerated by `lake exe mk_all --lib FormalSystem`.

**Verification**:

- Scoped guarded build green:
  `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Expressiveness.SeparationZ.Syntax`.
- `bash scripts/readme-lint.sh FormalSystem` exits 0 (the new directory has its README).
- `bash scripts/check-copyright-headers.sh` exits 0.
- `grep -n 'sorry' ` over the new module returns nothing, and no declaration matches a prohibited
  vacuous shape (`:= True`, `:= trivial`, `:= Unit`).

---

### Phase 2: The Leaf Abstraction Seam and the Carrier Bridge [COMPLETED]

**Goal**: The one interface between `USForm` and `PlusFormula` exists and is proved: a computable
leaf table, `toPlus`, the roundtrip, truth transfer at `t : ℤ`, syntactic purity transfer, and the
bridge that turns a pointwise ZTime equivalence into the shape `SeparationOver` asks for.

**Tasks**:

- [x] Add `LeafAbstraction.lean`. Define `leaves : PlusFormula → List PlusFormula` returning, in
      deterministic traversal order and without duplicates, the formula's atoms together with its
      **maximal** `box` and `stab` subformulas (maximal: do not descend into a `box`/`stab`
      scope).
- [x] Define `abstr : PlusFormula → USForm` replacing each entry of `leaves φ` by `leaf i` at its
      index, and `toPlus (g : ℕ → PlusFormula) : USForm → PlusFormula` sending `leaf i` to `g i`
      and every other constructor to its `PlusFormula` namesake.
- [x] Prove the roundtrip `toPlus (fun i => (leaves φ).getD i PlusFormula.bot) (abstr φ) = φ` by
      structural induction on `φ`.
- [x] Prove **truth transfer**: for `F : FrameOver intOrder`, `[F.IsRegular]`, `M`, `τ` and
      `t : ℤ`, with `v i s := PlusTruthAt M τ s ((leaves φ).getD i PlusFormula.bot)`,
      `usTruth v t ψ ↔ PlusTruthAt M τ t (toPlus (fun i => (leaves φ).getD i .bot) ψ)`, by
      induction on `ψ`. Write the carrier ascription at `↑intOrder` explicitly; do not let Lean
      try to invert `↑E ≟ ℤ`.
- [x] Prove **purity transfer**: if every `g i` is `IsPurePast` and `IsUOnly ψ` fails / `IsSOnly ψ`
      holds then `IsPurePast (toPlus g ψ)`, and the `IsUOnly`/`IsPureFuture` mirror. Define
      `IsUOnly` and `IsSOnly` inductively here (leaf and bot in both; `imp` preserving; `untl`
      only in `IsUOnly`, `snce` only in `IsSOnly`).
- [x] Prove that every entry of `leaves φ` is both `IsPurePast` and `IsPureFuture`, by case
      analysis on the three leaf shapes (`atom`, `box`, `stab`), each a leaf constructor of both
      predicates.
- [x] Add the **carrier bridge**
      `plusValidZTime_iff_pointwise : PlusValidZTime (φ.iff ψ) ↔ ∀ F : TaskFrame, F.IsRegular → F.IsZTime → ∀ M τ t, (PlusTruthAt M τ t φ ↔ PlusTruthAt M τ t ψ)`,
      unfolding `PlusValidIn`, `FrameClass.Sat .ZTime` and `PlusTruth.iff_iff`; then compose it
      with the compiled `FormalSystem.PlusLanguage.plusValidZTime_iff_plusValidInt` into the one
      lemma later phases consume to move between abstract ZTime frames and `t : ℤ`.
- [x] Append the module's row to `SeparationZ/README.md` and regenerate `FormalSystem.lean`.

**Timing**: 2 hours

**Depends on**: 1

**Verification Tier**: local

**Tier Justification**: The phase adds one new module whose only reverse dependency is the
regenerated root, so
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Expressiveness.SeparationZ.LeafAbstraction`
covers it; no existing declaration or signature is touched.

**Files to modify**:

- `FormalSystem/Metalogic/Expressiveness/SeparationZ/LeafAbstraction.lean` - new: `leaves`,
  `abstr`, `toPlus`, roundtrip, truth transfer, `IsUOnly`/`IsSOnly`, purity transfer, the carrier
  bridge.
- `FormalSystem/Metalogic/Expressiveness/SeparationZ/README.md` - add this module's row.
- `FormalSystem.lean` - regenerated.

**Verification**:

- Scoped guarded build green for the new module.
- The roundtrip, truth-transfer and purity-transfer lemmas each compile sorry-free; confirm with
  `lean_verify` on their fully qualified names.
- `bash scripts/readme-lint.sh FormalSystem` exits 0.
- Zero `sorry`, zero vacuous definitions in the new module.

---

### Phase 3: GHR Lemma 10.2.1 -- The Four Boolean Distributivities [COMPLETED]

**Goal**: The four distributivities hold for `usTruth` over `ℤ`, each stated with arbitrary
`USForm` arguments rather than atoms.

**Tasks**:

- [x] Add `Distributivity.lean`. State and prove, in this repository's guard-first order (so
      GHR's `U(A ∨ B, C)` is `untl C (A.or B)`):
      `untl C (A.or B) ↔ (untl C A).or (untl C B)`;
      the `snce` mirror; `untl (B.and C) A ↔ (untl B A).and (untl C A)`; and its `snce` mirror --
      each as a `usTruth`-level `Iff` at every `v` and `t`.
- [x] Derive each `snce` case from its `untl` case through `usTruth_swap` and `swap_involutive`
      rather than repeating the argument, establishing the duality idiom every later phase reuses.
- [x] Confirm each proof uses only linearity of `ℤ`, not discreteness -- GHR's 10.2.1 is valid
      over linear time and nothing here may silently consume `Int.exists_least_of_bdd`.
- [x] Append the module's row to `SeparationZ/README.md` and regenerate `FormalSystem.lean`.

**Timing**: 1.5 hours

**Depends on**: 2

**Verification Tier**: local

**Tier Justification**: One additive module of self-contained validities;
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Expressiveness.SeparationZ.Distributivity`
is the cheapest check covering the whole edit.

**Scope Hypothesis**: Four distributivity theorems, two proved directly and two by duality.
Confirm at implementation time by counting `theorem` keywords in the module and by checking that
the two `snce` proofs mention `usTruth_swap`.

**Files to modify**:

- `FormalSystem/Metalogic/Expressiveness/SeparationZ/Distributivity.lean` - new: GHR 10.2.1.
- `FormalSystem/Metalogic/Expressiveness/SeparationZ/README.md` - add this module's row.
- `FormalSystem.lean` - regenerated.

**Verification**:

- Scoped guarded build green for the new module.
- `grep -n 'exists_least_of_bdd\|SuccOrder\|PredOrder' ` over the module returns nothing (the
  linearity-only claim).
- Zero `sorry`, zero vacuous definitions.

---

### Phase 4: GHR Lemma 10.2.2 -- The Negation Equivalences over `ℤ` [COMPLETED]

**Goal**: The four negation equivalences hold over integer time, with the least-witness arguments
discharged by `Int.exists_least_of_bdd`.

**Tasks**:

- [x] Add `NegationEquiv.lean`. State and prove, flipped into guard-first order, GHR's
      `¬U(A,B) ↔ G(¬A) ∨ U(¬A ∧ ¬B, ¬A)`, its `snce`/`allPast` mirror, and the two variants
      carrying `B ∧ ¬A` in the guard slot.
- [x] Use `Int.exists_least_of_bdd` (`.lake/packages/mathlib/Mathlib/Data/Int/LeastGreatest.lean:69`,
      re-derived at plan time) for the "least `u > t` with `A u`" step, and `omega` for the
      adjacent-point arithmetic, including the empty open interval `(t, t+1) ∩ ℤ = ∅` that makes a
      guard vacuous on adjacent points.
- [x] Record, in the module docstring, that the vacuous-guard degeneracy on `ℤ` makes
      `snce`/`untl` *easier* to satisfy at adjacent points, not harder -- the archived Boneyard
      note states this backwards and the mistake is cheap to re-inherit.
- [x] Derive each past-side equivalence by duality from its future-side counterpart.
- [x] Append the module's row to `SeparationZ/README.md` and regenerate `FormalSystem.lean`.

**Timing**: 2 hours

**Depends on**: 3

**Verification Tier**: local

**Tier Justification**: One additive module;
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Expressiveness.SeparationZ.NegationEquiv`
covers it, and no earlier module's statement changes.

**Scope Hypothesis**: Four negation equivalences, two by duality. Confirm by counting `theorem`
keywords and checking the two mirror proofs route through `usTruth_swap`.

**Files to modify**:

- `FormalSystem/Metalogic/Expressiveness/SeparationZ/NegationEquiv.lean` - new: GHR 10.2.2.
- `FormalSystem/Metalogic/Expressiveness/SeparationZ/README.md` - add this module's row.
- `FormalSystem.lean` - regenerated.

**Verification**:

- Scoped guarded build green for the new module.
- Zero `sorry`, zero vacuous definitions.
- The module docstring carries the vacuous-guard orientation note.

---

### Phase 5: DECISION GATE -- Probe the Reconstructed Cases 5-8 [COMPLETED WITH EXCLUSIONS]

**Goal**: A candidate separated right-hand side exists for each of GHR 10.2.3's Cases 5-8,
derived from the semantics rather than transcribed, and each has survived evaluation on concrete
`ℤ` leaf valuations including the adjacency degeneracies. The gate's criterion: **all four
candidates survive**. Its measurement licenses Phase 7.

**Tasks**:

- [x] Write a prototype file under `specs/867_formalize_gabbay_separation_ztime/prototype/` that
      defines concrete leaf valuations on `ℤ` as decidable predicates and evaluates both sides of
      a candidate equivalence at a chosen `t`, so a candidate can be refuted by `decide` or by
      `native_decide`-free explicit computation rather than by hand.
- [x] Re-derive each of Cases 5-8 from the semantics by the case split GHR indicates: the position
      of the `A`-witness relative to `t`, and the position of the first `¬B` after `s`. Do not
      transcribe the printed formulas.
- [x] Start Case 5 from the gloss-consistent reconstruction the research report records --
      `S(A ∧ S(a,B), A ∨ B ∨ ¬S(¬q,¬A)) ∧ ¬S(¬q,¬A)` as the second disjunct, with the
      `[A ∨ (B ∧ U(A,B))]` conjunct belonging to the first disjunct only -- which already survives
      the report's verified counterexample.
- [x] Re-run the report's refuting model against each candidate as a regression: `a(0)`, `A(1)`,
      `B` identically false, `q(1)` and `q(2)` true, everything else false, evaluated at `t = 3`.
      The printed Case 5 is false there; a surviving candidate must be true.
- [x] Probe each candidate additionally on at least one model exercising the adjacent-point
      degeneracy (a witness at `t+1` or `t-1`, where the open interval is empty and the guard is
      vacuous) and one where the `A`-witness lies strictly in the past.
- [x] Record, in the prototype file's own comments, each candidate's exact statement and the
      models it survived, so Phase 7 implements a pinned candidate rather than re-deriving one.
- [x] **Gate measurement**: state explicitly, for each of the four cases, whether a candidate
      survived every probe. Record the count (expected: 4 of 4).

**Timing**: 2 hours

**Depends on**: 4

**Verification Tier**: local

**Tier Justification**: The phase's only files are prototype `.lean` files under `specs/`, which
are outside the build graph and covered by compiling them directly --
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- env lean specs/867_formalize_gabbay_separation_ztime/prototype/<file>.lean`
-- so no library module is touched and no suite maps to the path.

**Scope Hypothesis**: Four candidate right-hand sides, one per case, each probed on at least three
models (the report's refuting model, one adjacency-degenerate model, one past-witness model).
Confirm at implementation time by the prototype file's own recorded per-case, per-model results;
a case with fewer than three recorded probes has not met the gate.

**Files to modify**:

- `specs/867_formalize_gabbay_separation_ztime/prototype/cases-5-8-probe.lean` - new: concrete `ℤ`
  valuations, candidate statements, and the recorded probe results.

**Verification**:

- The prototype file elaborates at exit 0 under
  `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- env lean <path>`.
- Each of the four candidates is evaluated against the report's refuting model and is true there.
- Each candidate's statement is recorded verbatim in the file, in guard-first repository order,
  with its probe results beside it.
- **Gate verdict recorded**: how many of the four candidates survived. If fewer than four, the
  contingency branch in `## Rollback/Contingency` is taken instead of Phase 7's plan-as-written.

---


#### Reasoned Exclusions

| Item | Reason | Evidence |
|------|--------|----------|
| A pinned candidate right-hand side for GHR 10.2.3 **Case 6** (`S(a ∧ ¬U(A,B), q ∨ U(A,B))`) | The derivation method that works for Case 5 does not terminate here. Case 5's event conjunct is `U(A,B)@s`, i.e. `¬bad*(s)`, and that negation is exactly what makes the re-anchored guard-failure branch collapse (see the Case 5 docstring in the prototype). Case 6's event conjunct is `bad*(s)` — the un-negated existential — so the collapse is unavailable and the re-anchoring leaves an `s`-bounded forward conjunct. | `specs/867_formalize_gabbay_separation_ztime/prototype/cases-5-8-probe.lean`, `## Gate measurement`; compiles at exit 0 |
| A pinned candidate right-hand side for GHR 10.2.3 **Case 7** (`S(a ∧ U(A,B), q ∨ ¬U(A,B))`) | The guard carries `¬U(A,B)`, so the guard-failure condition is `∃r ∈ (s,t): ¬q(r) ∧ ¬bad*(r)` with `¬bad*` itself a universal over `x ∈ (r,t]`. Re-anchoring an `∃∀` needs two nested witness choices (an `A`-point `y`, then a `K`-point `x > y`) and retains a forward-looking, `t`-bounded conjunct at `r`, which is not a formula at `r` and so cannot be an `S`-guard. | same file, `## Gate measurement` |
| A pinned candidate right-hand side for GHR 10.2.3 **Case 8** (`S(a ∧ ¬U(A,B), q ∨ ¬U(A,B))`) | Both obstructions above at once: the `∃∀` guard-failure condition of Case 7 and the un-negated event existential of Case 6. The negation route that reduces Case 8 to Case 5's shape, and Case 5 to Case 8's, is circular — `¬Case8 ↔ H(¬a ∨ U) ∨ S(¬q ∧ U, ¬a ∨ U)`, whose second disjunct is Case 5's shape, and symmetrically. | same file, `## Gate measurement` |

**Gate verdict: 1 of 4.** Case 5's candidate is pinned and survives all three probe models,
including the `reports/01` model that refutes GHR's printed formula. Cases 6-8 produced no
candidate. The criterion was 4 of 4, so the primary contingency branch of
`## Rollback/Contingency` is taken.

### Phase 6: GHR Lemma 10.2.3 -- Eliminations, Cases 1-4 [COMPLETED]

**Goal**: The first four eliminations pull `untl` out from under `snce` and are proved at every
`v` and `t` over `ℤ`, with arbitrary `USForm` parameters.

**Tasks**:

- [x] Add `Eliminations.lean`. State each of Cases 1-4 with **arbitrary `USForm` parameters**
      `a`, `q`, `A`, `B`, not atoms: GHR's atomicity hypothesis exists only to license their
      substitution step and is unused in their semantic arguments.
- [x] Prove Case 1 (`S(a ∧ U(A,B), q)`), Case 2 (`S(a ∧ ¬U(A,B), q)`), Case 3
      (`S(a, q ∨ U(A,B))`) and Case 4 (`S(a, q ∨ ¬U(A,B))`), flipping every GHR `U(A,B)` to
      `untl B A`.
- [x] Reduce Case 3 to Case 2 and Case 4 as GHR's own internal reductions indicate, rather than
      proving it from scratch, and record which reduction each case uses in its docstring.
- [x] Verify, for each case, that the right-hand side is syntactically separated -- every `untl`
      occurrence sits under no `snce` and vice versa -- by discharging `IsUOnly`/`IsSOnly` side
      conditions rather than asserting it in prose.
- [x] Append the module's row to `SeparationZ/README.md` and regenerate `FormalSystem.lean`.

**Timing**: 2 hours

**Depends on**: 5

**Verification Tier**: local

**Tier Justification**: One additive module consuming only Phases 1-4's lemmas;
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Expressiveness.SeparationZ.Eliminations`
covers the whole edit.

**Scope Hypothesis**: Four eliminations in one module, each carrying a proved separatedness side
condition. Confirm by counting `theorem` keywords and by checking each case has an accompanying
`IsUOnly`/`IsSOnly` lemma or in-statement side condition.

**Files to modify**:

- `FormalSystem/Metalogic/Expressiveness/SeparationZ/Eliminations.lean` - new: GHR 10.2.3 Cases
  1-4 with their separatedness side conditions.
- `FormalSystem/Metalogic/Expressiveness/SeparationZ/README.md` - add this module's row.
- `FormalSystem.lean` - regenerated.

**Verification**:

- Scoped guarded build green for the new module.
- Each of the four cases compiles sorry-free with its separatedness condition discharged.
- Zero `sorry`, zero vacuous definitions.

---

### Phase 7: GHR Lemma 10.2.3 -- Eliminations, Cases 5-8 [COMPLETED WITH EXCLUSIONS]

**Goal**: The remaining four eliminations, the ones whose printed forms are refuted or gapped,
are proved from the candidates Phase 5 pinned.

**Tasks**:

- [ ] Add `ElimHard.lean`. Implement each of Cases 5-8 from the candidate statement Phase 5
      recorded, verbatim; do not re-derive a different right-hand side mid-proof.
- [ ] Prove Case 5 (`S(a ∧ U(A,B), q ∨ U(A,B))`), Case 6 (`S(a ∧ ¬U(A,B), q ∨ U(A,B))`), Case 7
      (`S(a ∧ U(A,B), q ∨ ¬U(A,B))`) and Case 8 (`S(a ∧ ¬U(A,B), q ∨ ¬U(A,B))`), using Phases 3,
      4 and 6 and the `swap` duality, with arbitrary `USForm` parameters throughout.
- [ ] Record in the module docstring that the printed Case 5 of the source is refuted over `ℤ`,
      name the counterexample model, and state that the landed form is a reconstruction -- with
      the literature citation kept, so a later reader does not "restore" the printed formula.
- [ ] Discharge the `IsUOnly`/`IsSOnly` separatedness side condition for each right-hand side, as
      in Phase 6.
- [ ] **Do not** derive any of these four from the junction-depth induction. They are strictly
      upstream of Lemma 10.2.4; closing that loop is the circularity risk this phase order exists
      to prevent.
- [x] Append the module's row to `SeparationZ/README.md` and regenerate `FormalSystem.lean`.

**Timing**: 2 hours

**Depends on**: 6

**Verification Tier**: local

**Tier Justification**: One additive module consuming only earlier `SeparationZ` lemmas;
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Expressiveness.SeparationZ.ElimHard`
covers it, and nothing outside the subtree can see these declarations yet.

**Scope Hypothesis**: Four eliminations, each matching the exact candidate statement recorded in
Phase 5's prototype file. Confirm at implementation time by diffing each landed statement against
that recorded candidate; a mismatch is a plan deviation to raise, not to annotate.

**Files to modify**:

- `FormalSystem/Metalogic/Expressiveness/SeparationZ/ElimHard.lean` - new: GHR 10.2.3 Cases 5-8,
  reconstructed, with the refutation note in the docstring.
- `FormalSystem/Metalogic/Expressiveness/SeparationZ/README.md` - add this module's row.
- `FormalSystem.lean` - regenerated.

**Verification**:

- Scoped guarded build green for the new module.
- Each landed statement matches Phase 5's recorded candidate verbatim.
- `grep -n 'JunctionDepth\|allFormulasSeparable\|all_formulas_separable' ` over the module returns
  nothing -- the anti-circularity check.
- Zero `sorry`, zero vacuous definitions.


#### Reasoned Exclusions

| Item | Reason | Evidence |
|------|--------|----------|
| `ElimHard.lean` with GHR 10.2.3 Cases 6, 7 and 8 | No candidate right-hand side was produced for any of the three. Their guard-failure conditions are `∃∀` over the window `(s,t]` whose re-anchoring retains an `s`-bounded forward conjunct, with no analogue of the collapse that keeps Case 5's candidate finite; the negation route between Cases 5 and 8 is circular. This is the precisely located obstruction the dispatch accepts. | Phase 5's gate measurement: `specs/867_formalize_gabbay_separation_ztime/prototype/cases-5-8-probe.lean`, `## Gate measurement` (compiles at exit 0), and this plan's Phase 5 `#### Reasoned Exclusions` |
| `ElimHard.lean` with GHR 10.2.3 Case 5 | A candidate IS pinned and survives all three probe models, including the one that refutes GHR's printed formula, so this item is unblocked mathematically. It is excluded only because the phase's deliverable is all four cases and the three above cannot be reached; a successor dispatch can land Case 5 alone from the pinned candidate and its recorded derivation without re-deriving anything. | Phase 5's gate measurement: `specs/867_formalize_gabbay_separation_ztime/prototype/cases-5-8-probe.lean`, `## Gate measurement` (compiles at exit 0), and this plan's Phase 5 `#### Reasoned Exclusions` |

Closed under the primary contingency branch of `## Rollback/Contingency`: Phase 5's gate
criterion was 4 of 4 and it measured 1 of 4, so this phase was decided against rather than
interrupted. No `sorry` and no vacuous placeholder was introduced anywhere in its place.

---

### Phase 8: Normal Forms and GHR Lemma 10.2.4 [COMPLETED WITH EXCLUSIONS]

**Goal**: A disjunctive and a conjunctive normal form exist for the Boolean skeleton of a
`USForm`, with truth preservation, and GHR 10.2.4 -- depth-one packaging for a single `U`-type --
is proved from them plus all eight eliminations.

**Tasks**:

- [ ] Add `NormalForm.lean` with `dnf` and `cnf` on the Boolean skeleton of a `USForm` (treating
      every `untl`/`snce` subformula and every `leaf` as an opaque literal), each with a truth-
      preservation lemma at every `v` and `t`.
- [ ] Add `IsSyntacticallySeparated` inductively: `leaf` and `bot` are separated; `imp` of *(deviation: altered — landed in Phase 6's `Eliminations.lean` as `IsSeparated`, since Phase 6's separatedness discharge needs it and this phase is excluded)*
      separated is separated; `untl ψ φ` is separated when `IsUOnly ψ` and `IsUOnly φ`; `snce ψ φ`
      is separated when `IsSOnly ψ` and `IsSOnly φ`.
- [ ] State GHR 10.2.4: for `untl`/`snce`-free `A` and `B`, if every `untl` occurring in `C` and
      `F` is `untl B A` and none is nested under a `snce`, then `snce F C` has a syntactically
      separated equivalent in which `untl` occurs only as `untl B A`.
- [ ] Prove it by: `dnf` on the event argument, `cnf` on the guard argument, Phase 3's
      distributivities to split the resulting clauses, then Cases 1-8 clause by clause. Each
      Boolean constituent has the shape `snce (C₂ ∨ ±untl B A) (C₁ ∧ ±untl B A)`, which is
      exactly one of the eight cases.
- [ ] Append the module's row to `SeparationZ/README.md` and regenerate `FormalSystem.lean`.

**Timing**: 2 hours

**Depends on**: 7

**Verification Tier**: local

**Tier Justification**: One additive module;
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Expressiveness.SeparationZ.NormalForm`
covers it, since no declaration outside the subtree references these names.

**Files to modify**:

- `FormalSystem/Metalogic/Expressiveness/SeparationZ/NormalForm.lean` - new: `dnf`, `cnf`,
  `IsSyntacticallySeparated`, GHR 10.2.4.
- `FormalSystem/Metalogic/Expressiveness/SeparationZ/README.md` - add this module's row.
- `FormalSystem.lean` - regenerated.

**Verification**:

- Scoped guarded build green for the new module.
- The normal-form truth-preservation lemmas and GHR 10.2.4 compile sorry-free.
- GHR 10.2.4's conclusion carries a proved `IsSyntacticallySeparated` witness, not a prose claim.
- Zero `sorry`, zero vacuous definitions.


#### Reasoned Exclusions

| Item | Reason | Evidence |
|------|--------|----------|
| `NormalForm.lean` with `dnf`, `cnf` and GHR 10.2.4 | GHR 10.2.4's proof consumes **all eight** cases of 10.2.3 clause by clause: after `dnf` on the event argument and `cnf` on the guard argument, each Boolean constituent has the shape `snce (C₂ ∨ ±untl B A) (C₁ ∧ ±untl B A)`, which is one of the eight. Three of the eight are unavailable, so 10.2.4 is unreachable. The archive's route of deriving Cases 5-8 back *from* the final theorem closes the circularity this plan's phase order exists to prevent and is not taken. | Phase 5's gate measurement: `specs/867_formalize_gabbay_separation_ztime/prototype/cases-5-8-probe.lean`, `## Gate measurement` (compiles at exit 0), and this plan's Phase 5 `#### Reasoned Exclusions` |
| `IsSyntacticallySeparated` | Landed early, as `IsSeparated` in Phase 6's `Eliminations.lean`, because Phase 6's separatedness discharge needs it. Its definition is verbatim the one this phase's task list specifies. | `FormalSystem/Metalogic/Expressiveness/SeparationZ/Eliminations.lean`, `inductive IsSeparated` |

Closed under the primary contingency branch of `## Rollback/Contingency`: Phase 5's gate
criterion was 4 of 4 and it measured 1 of 4, so this phase was decided against rather than
interrupted. No `sorry` and no vacuous placeholder was introduced anywhere in its place.

---

### Phase 9: GHR Lemmas 10.2.5 and 10.2.6 [COMPLETED WITH EXCLUSIONS]

**Goal**: The `snce`-nesting induction and the `U`-type-count induction are proved, each with its
measure defined structurally and its strict decrease proved rather than asserted.

**Tasks**:

- [ ] Add `Hierarchy.lean`. Define `snceDepthAbove : USForm → ℕ`, the maximum number of nested
      `snce`s above any `untl` occurrence, as a structural recursion -- GHR's occurrence-level
      "most deeply nested `S(C,F)`" has no Lean counterpart and must be restated this way.
- [ ] Prove GHR 10.2.5 by induction on that measure, applying Phase 8's 10.2.4 at each maximal
      `snce` and proving the measure strictly decreases at the step.
- [ ] Define `uTypeCount : USForm → ℕ`, the number of distinct maximal `untl` subformulas, again
      structurally.
- [ ] Prove GHR 10.2.6 by induction on `uTypeCount`: abstract each `untl Bᵢ Aᵢ` for `i < n` to a
      fresh leaf above `maxLeaf` (Phase 1's `freshLeaf` and `usTruth_congr_of_update` are the
      whole device), separate for the remaining type by 10.2.5, reindex back, and re-separate the
      resulting impure pure-past parts by the induction hypothesis.
- [ ] Prove the strict-decrease lemma for `uTypeCount` under abstract-separate-reindex as a named
      obligation, with its own statement; GHR assert it without proof.
- [ ] Append the module's row to `SeparationZ/README.md` and regenerate `FormalSystem.lean`.

**Timing**: 2 hours

**Depends on**: 8

**Verification Tier**: local

**Tier Justification**: One additive module;
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Expressiveness.SeparationZ.Hierarchy`
covers the whole edit.

**Files to modify**:

- `FormalSystem/Metalogic/Expressiveness/SeparationZ/Hierarchy.lean` - new: `snceDepthAbove`,
  `uTypeCount`, their strict-decrease lemmas, GHR 10.2.5 and 10.2.6.
- `FormalSystem/Metalogic/Expressiveness/SeparationZ/README.md` - add this module's row.
- `FormalSystem.lean` - regenerated.

**Verification**:

- Scoped guarded build green for the new module.
- Both measures are total structural recursions (no `partial`, no well-founded-recursion
  `sorry`), and each strict-decrease claim is a named, proved theorem.
- Zero `sorry`, zero vacuous definitions.


#### Reasoned Exclusions

| Item | Reason | Evidence |
|------|--------|----------|
| `Hierarchy.lean` with `snceDepthAbove`, `uTypeCount`, their strict-decrease lemmas, and GHR 10.2.5 and 10.2.6 | Both inductions apply GHR 10.2.4 at each step — 10.2.5 at each maximal `snce`, 10.2.6 through 10.2.5 — and 10.2.4 is excluded one phase upstream. Nothing in this phase is independently reachable. | Phase 5's gate measurement: `specs/867_formalize_gabbay_separation_ztime/prototype/cases-5-8-probe.lean`, `## Gate measurement` (compiles at exit 0), and this plan's Phase 5 `#### Reasoned Exclusions` |

Closed under the primary contingency branch of `## Rollback/Contingency`: Phase 5's gate
criterion was 4 of 4 and it measured 1 of 4, so this phase was decided against rather than
interrupted. No `sorry` and no vacuous placeholder was introduced anywhere in its place.

---

### Phase 10: GHR Lemma 10.2.7 [COMPLETED WITH EXCLUSIONS]

**Goal**: The `untl`-nesting induction is proved, for formulas with no `snce` nested within an
`untl`.

**Tasks**:

- [ ] Add `UNesting.lean`. Define `untlDepth : USForm → ℕ`, the maximum nesting depth of `untl`
      beneath a `snce`, structurally.
- [ ] Prove GHR 10.2.7 by induction on it: abstract each inner `untl Yᵢⱼ Xᵢⱼ` to a fresh leaf,
      separate by Phase 9's 10.2.6, reindex back, and re-separate.
- [ ] Prove the step's strict-decrease obligation explicitly, as in Phase 9.
- [ ] State the hypothesis "no `snce` nested within an `untl`" as a decidable structural predicate
      on `USForm`, not as prose, so 10.2.8 can discharge it mechanically.
- [ ] Append the module's row to `SeparationZ/README.md` and regenerate `FormalSystem.lean`.

**Timing**: 1.5 hours

**Depends on**: 9

**Verification Tier**: local

**Tier Justification**: One additive module;
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Expressiveness.SeparationZ.UNesting`
covers it.

**Files to modify**:

- `FormalSystem/Metalogic/Expressiveness/SeparationZ/UNesting.lean` - new: `untlDepth`, its
  strict-decrease lemma, GHR 10.2.7 and its structural hypothesis predicate.
- `FormalSystem/Metalogic/Expressiveness/SeparationZ/README.md` - add this module's row.
- `FormalSystem.lean` - regenerated.

**Verification**:

- Scoped guarded build green for the new module.
- The nesting hypothesis is a structural predicate with a `Decidable` instance or a decision
  procedure, not a prose side condition.
- Zero `sorry`, zero vacuous definitions.


#### Reasoned Exclusions

| Item | Reason | Evidence |
|------|--------|----------|
| `UNesting.lean` with `untlDepth`, its strict-decrease lemma, GHR 10.2.7 and its structural hypothesis predicate | GHR 10.2.7's induction step separates by GHR 10.2.6, which is excluded one phase upstream. | Phase 5's gate measurement: `specs/867_formalize_gabbay_separation_ztime/prototype/cases-5-8-probe.lean`, `## Gate measurement` (compiles at exit 0), and this plan's Phase 5 `#### Reasoned Exclusions` |

Closed under the primary contingency branch of `## Rollback/Contingency`: Phase 5's gate
criterion was 4 of 4 and it measured 1 of 4, so this phase was decided against rather than
interrupted. No `sorry` and no vacuous placeholder was introduced anywhere in its place.

---

### Phase 11: Junction Depth, GHR Lemma 10.2.8 and Theorem 10.2.9 [COMPLETED WITH EXCLUSIONS]

**Goal**: Junction depth is a structural measure with proved monotonicity bounds and a proved
strict decrease, GHR 10.2.8 holds, and the Separation Theorem over `ℤ` follows.

**Tasks**:

- [ ] Add `JunctionDepth.lean`. Define `junctionDepth : USForm → ℕ` -- the maximal length of a
      chain of nested `untl`/`snce` subformulas **alternating** between the two -- as a structural
      recursion, with the mutually-recursive `untl`-headed and `snce`-headed auxiliaries the
      alternation requires.
- [ ] Prove the monotonicity bounds (`junctionDepth` of each immediate subformula is at most that
      of the whole, at `imp`, `untl` and `snce`). The archived development's `jd_imp_le_left`,
      `jd_untl_le_left` and siblings indicate the shape; re-derive each, do not transplant.
- [ ] Prove that `junctionDepth ψ ≤ 1` implies `IsSyntacticallySeparated ψ`.
- [ ] Prove GHR 10.2.8 by strong recursion on `junctionDepth`: abstract each maximal `snce E F`
      inside a maximal `untl Bᵢ Aᵢ` to a fresh leaf, separate by Phase 10's 10.2.7, reindex back,
      and prove the result's junction depth is strictly smaller. **That strict decrease is the
      phase's central named obligation** -- GHR assert it with no proof and it is the secondary
      stall candidate the research report flags.
- [ ] Prove Theorem 10.2.9: every `USForm` has a syntactically separated equivalent at every `v`
      and `t`, as a function `sep : USForm → USForm` together with
      `usTruth_sep_iff : usTruth v t (sep ψ) ↔ usTruth v t ψ` and
      `isSyntacticallySeparated_sep : IsSyntacticallySeparated (sep ψ)`.
- [ ] Declare `sep` as a plain `def` with no `noncomputable` keyword. If the recursion needs
      `Classical.choose` anywhere, the construction is wrong -- the whole executability deliverable
      of Phase 13 depends on `sep` being computable.
- [ ] Append the module's row to `SeparationZ/README.md` and regenerate `FormalSystem.lean`.

**Timing**: 2 hours

**Depends on**: 10

**Verification Tier**: local

**Tier Justification**: One additive module;
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Expressiveness.SeparationZ.JunctionDepth`
covers it, and `sep`'s computability is checked inside the same build by the absence of the
`noncomputable` keyword.

**Files to modify**:

- `FormalSystem/Metalogic/Expressiveness/SeparationZ/JunctionDepth.lean` - new: `junctionDepth`,
  its bounds, the strict-decrease lemma, GHR 10.2.8, `sep`, `usTruth_sep_iff`,
  `isSyntacticallySeparated_sep`.
- `FormalSystem/Metalogic/Expressiveness/SeparationZ/README.md` - add this module's row.
- `FormalSystem.lean` - regenerated.

**Verification**:

- Scoped guarded build green for the new module.
- **Blocking check**: `sep` compiles without `noncomputable`. If Lean demands the keyword, mark
  the phase `[BLOCKED]` and raise it rather than adding it.
- The strict-decrease lemma is a named, proved theorem, not a `simp`-closed afterthought.
- Zero `sorry`, zero vacuous definitions.


#### Reasoned Exclusions

| Item | Reason | Evidence |
|------|--------|----------|
| `JunctionDepth.lean` with `junctionDepth`, its bounds, the strict-decrease lemma, GHR 10.2.8, `sep`, `usTruth_sep_iff` and `isSyntacticallySeparated_sep` | GHR 10.2.8's induction step separates by GHR 10.2.7, which is excluded upstream, and Theorem 10.2.9 is its corollary. The junction-depth strict decrease — this plan's secondary stall candidate, asserted without proof in the source — was therefore never reached and is **not** itself the obstruction on record. | Phase 5's gate measurement: `specs/867_formalize_gabbay_separation_ztime/prototype/cases-5-8-probe.lean`, `## Gate measurement` (compiles at exit 0), and this plan's Phase 5 `#### Reasoned Exclusions` |

Closed under the primary contingency branch of `## Rollback/Contingency`: Phase 5's gate
criterion was 4 of 4 and it measured 1 of 4, so this phase was decided against rather than
interrupted. No `sorry` and no vacuous placeholder was introduced anywhere in its place.

---

### Phase 12: CNF Packaging and the Discharge of `SeparationOver` [COMPLETED WITH EXCLUSIONS]

**Goal**: A separated `USForm` is packaged into the binary clause list `sepForm` consumes, and
`sepZ`, `sepZ_sepClauses`, `plusTruthAt_sepZ_iff` and `separationOver_ztime` land.

**Tasks**:

- [ ] Add `Packaging.lean`. Classify each literal of a separated `USForm`'s Boolean skeleton as
      past-admissible, future-admissible, or both (leaves are both); CNF-normalize the skeleton by
      Phase 8's `cnf`; and per clause put the `snce`-only and leaf literals in the first component
      and the `untl`-only literals in the second, padding an absent side with `PlusFormula.bot`
      (which is a leaf constructor of both `IsPurePast` and `IsPureFuture`).
- [ ] Prove the packaging's truth-preservation lemma: the packaged clause list's `sepForm` is
      equivalent to the separated formula at every `v` and `t`. This step has no counterpart in
      the source and is the phase's main new obligation.
- [ ] Add `Discharge.lean` in namespace `FormalSystem.Metalogic.Expressiveness` (not the
      `SeparationZ.` sub-namespace -- these are the contract declarations). Define
      `sepZ : PlusFormula → List (PlusFormula × PlusFormula)` as the composite: leaf-abstract,
      `sep`, package, `toPlus` each component.
- [ ] Prove `sepZ_sepClauses` from Phase 2's purity transfer plus the compiled
      `pastDet_of_isPurePast` and `futDet_of_isPureFuture`. Note that purity is
      frame-independent, so the `hreg`/`hz` hypotheses are consumed only to match
      `SeparationOver`'s shape.
- [ ] Prove `plusTruthAt_sepZ_iff` by routing through Phase 2's carrier bridge and
      `plusValidZTime_iff_plusValidInt` to `t : ℤ`, then Phase 2's truth transfer, Phase 11's
      `usTruth_sep_iff` and the packaging lemma.
- [ ] Prove `separationOver_ztime : SeparationOver TaskFrame.IsZTime` as
      `fun φ => ⟨sepZ φ, fun F hreg hz => ⟨sepZ_sepClauses φ F hreg hz, plusTruthAt_sepZ_iff φ hreg hz⟩⟩`,
      matching the `∃ L` before `∀ F` binder order exactly -- one separated form must serve every
      frame in the class, which is what the syntactic route delivers.
- [ ] Give each of the four a docstring carrying a `Paper:` line: the three `sepZ` rows cite GHR
      Theorem 10.2.9 (vol. 1, Chapter 10 §10.2); `separationOver_ztime` cites the same. C15's
      second assertion requires the anchor at the declaration itself.
- [ ] Append both modules' rows to `SeparationZ/README.md` and regenerate `FormalSystem.lean`.

**Timing**: 2 hours

**Depends on**: 11

**Verification Tier**: local

**Tier Justification**: Two additive modules introducing new names only, with no existing
signature changed, so the scoped guarded build of the second
(`... -- build FormalSystem.Metalogic.Expressiveness.SeparationZ.Discharge`) builds the first
transitively and covers the whole edit.

**Scope Hypothesis**: Two new modules carrying four contract declarations (`sepZ`,
`sepZ_sepClauses`, `plusTruthAt_sepZ_iff`, `separationOver_ztime`) plus the packaging function and
its lemma. Confirm at implementation time by `git diff --stat` showing exactly the declared paths
and by checking each of the four contract names resolves at its `## Lean Challenge Statements`
signature.

**Files to modify**:

- `FormalSystem/Metalogic/Expressiveness/SeparationZ/Packaging.lean` - new: literal
  classification, clause packaging, truth-preservation lemma.
- `FormalSystem/Metalogic/Expressiveness/SeparationZ/Discharge.lean` - new: `sepZ`,
  `sepZ_sepClauses`, `plusTruthAt_sepZ_iff`, `separationOver_ztime`.
- `FormalSystem/Metalogic/Expressiveness/SeparationZ/README.md` - add both modules' rows.
- `FormalSystem.lean` - regenerated.

**Verification**:

- Scoped guarded build green for `...SeparationZ.Discharge`.
- All four contract declarations compile sorry-free; `lean_verify` on each fully qualified name
  reports no `sorry`.
- **Blocking check**: `sepZ` compiles without `noncomputable`.
- Each landed signature matches its `## Lean Challenge Statements` form; a divergence is a
  `[BLOCKED]` escalation, not a quiet substitution (see `rules/plan-compliance.md`).
- Each of the four docstrings carries a `Paper:` line.
- Zero `sorry`, zero vacuous definitions.


#### Reasoned Exclusions

| Item | Reason | Evidence |
|------|--------|----------|
| `Packaging.lean`, and `Discharge.lean` with `sepZ`, `sepZ_sepClauses`, `plusTruthAt_sepZ_iff` and `separationOver_ztime` | Every one of the four contract declarations is a composite of `sep` from Theorem 10.2.9, which is excluded upstream. `separationOver_ztime` — this task's headline deliverable — is therefore **not** discharged, and every `tr` row in `OpenFutureElimination.lean` keeps its `SeparationOver` hypothesis unchanged. | Phase 5's gate measurement: `specs/867_formalize_gabbay_separation_ztime/prototype/cases-5-8-probe.lean`, `## Gate measurement` (compiles at exit 0), and this plan's Phase 5 `#### Reasoned Exclusions` |

Closed under the primary contingency branch of `## Rollback/Contingency`: Phase 5's gate
criterion was 4 of 4 and it measured 1 of 4, so this phase was decided against rather than
interrupted. No `sorry` and no vacuous placeholder was introduced anywhere in its place.

---

### Phase 13: The Computable Translation `trZ` [COMPLETED WITH EXCLUSIONS]

**Goal**: A computable ZTime translation exists beside the frozen `noncomputable tr`, with its own
truth-preservation and validity-transfer theorems, both unconditional.

**Tasks**:

- [ ] Add `Computable.lean` in namespace `FormalSystem.Metalogic.Expressiveness`. Define
      `trZ : OpenFormula → PlusFormula`, homomorphic on the seven shared constructors, and at
      `.ofut φ` / `.opast φ` returning `ofutElim (sepZ (trZ φ))` / `opastElim (sepZ (trZ φ))` --
      the computable `sepZ` in place of `tr`'s `Classical.choose`.
- [ ] Declare `trZ` as a plain `def`. **Do not** add `noncomputable`; the compiler enforcing
      computability is the whole point of this phase.
- [ ] Prove `openTruthAt_iff_trZ` by induction on `φ` generalizing the history and the time,
      mirroring the landed `openTruthAt_iff_tr` proof, with `plusTruthAt_sepZ_iff` where that
      proof uses `Classical.choose_spec` and the compiled `ofutP_sepForm_iff` /
      `opastP_sepForm_iff` at the two modal cases.
- [ ] Prove `openValidIn_ztime_iff_trZ` from it, unfolding
      `FrameClass.Sat .ZTime F = F.IsRegular ∧ F.IsZTime`, in the shape
      `openValidOnFrames_iff_tr` already establishes for the conditional route.
- [ ] Record in the module docstring that `tr` is untouched -- same name, still `noncomputable`,
      still taking `hsep` explicitly -- and that `trZ` is an addition, not a replacement, so no
      existing consumer changes.
- [ ] Note in the same docstring that `trZ` inhabits the translation slot of the already-generic
      `decidableOpenValidInOfTranslation`, `openDecider`, `openDecider_correct`,
      `openComplete_of_plusComplete_in` and `openValid_of_plusSound` with no change to any of the
      five, and that this makes the effectiveness gap those rows inherit closed at `.ZTime` only.
- [ ] Do **not** add a uniform `noncomputable` `Decidable (OpenValidIn FrameClass.ZTime φ)`: the
      host module's docstring records that shape as rejected and `lean4.md` classes it as vacuous.
- [ ] Give both theorems and `trZ` a `Paper:` line.
- [ ] Append the module's row to `SeparationZ/README.md` and regenerate `FormalSystem.lean`.

**Timing**: 1.5 hours

**Depends on**: 12

**Verification Tier**: local

**Tier Justification**: One additive module naming only existing declarations and Phase 12's new
ones, with no existing signature changed, so
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Expressiveness.SeparationZ.Computable`
covers it.

**Files to modify**:

- `FormalSystem/Metalogic/Expressiveness/SeparationZ/Computable.lean` - new: `trZ`,
  `openTruthAt_iff_trZ`, `openValidIn_ztime_iff_trZ`.
- `FormalSystem/Metalogic/Expressiveness/SeparationZ/README.md` - add this module's row.
- `FormalSystem.lean` - regenerated.

**Verification**:

- Scoped guarded build green for the new module.
- **Blocking check**: `trZ` compiles without `noncomputable`. If Lean demands it, a
  `Classical.choose` has leaked into `sep` or `sepZ` -- fix that, do not add the keyword.
- Both theorems' landed signatures match their `## Lean Challenge Statements` forms.
- `git diff` confirms `tr` and every other existing declaration in
  `OpenFutureElimination.lean` is byte-unchanged by this phase.
- Zero `sorry`, zero vacuous definitions.


#### Reasoned Exclusions

| Item | Reason | Evidence |
|------|--------|----------|
| `Computable.lean` with `trZ`, `openTruthAt_iff_trZ` and `openValidIn_ztime_iff_trZ` | `trZ` is defined at `.ofut`/`.opast` as `ofutElim (sepZ (trZ φ))` / `opastElim (sepZ (trZ φ))`, and `sepZ` is excluded one phase upstream. `tr` stays `noncomputable` and untouched, and the effectiveness gap recorded in `OpenFutureElimination.lean`'s `## What is NOT proved here` stands exactly as written. | Phase 5's gate measurement: `specs/867_formalize_gabbay_separation_ztime/prototype/cases-5-8-probe.lean`, `## Gate measurement` (compiles at exit 0), and this plan's Phase 5 `#### Reasoned Exclusions` |

Closed under the primary contingency branch of `## Rollback/Contingency`: Phase 5's gate
criterion was 4 of 4 and it measured 1 of 4, so this phase was decided against rather than
interrupted. No `sorry` and no vacuous placeholder was introduced anywhere in its place.

---

### Phase 14: Documentation, Theorem-Index Rows and Measured Axiom Baselines [COMPLETED WITH EXCLUSIONS]

**Goal**: Every documentation surface that says the separation hypothesis is unformalized in this
tree is corrected for `.ZTime` and left untouched for `.RTime`, the new declarations carry
measured C14 pins, and the subtree is aggregated.

**Tasks**:

- [x] Re-read each target file immediately before editing it (sibling concurrency).
- [ ] Amend `FormalSystem/Metalogic/Expressiveness/OpenFutureElimination.lean`'s module docstring: *(deviation: skipped — the contingency branch requires this docstring left unchanged, since `separationOver_ztime` was not reached)*
      `## What is NOT proved here` must no longer assert the separation hypothesis is unformalized
      at `.ZTime`. State precisely what changed -- `separationOver_ztime` discharges it at `.ZTime`
      in this tree -- and that the `.RTime` hypothesis (GHR Theorem 10.3.20) remains undischarged.
      Change no declaration in the file.
- [x] Add the new modules to `FormalSystem/Metalogic/Expressiveness.lean`'s import list, so the
      headline results are reachable from the subtree aggregator and not only from the generated
      root.
- [x] Amend `FormalSystem/Metalogic/Expressiveness/README.md` to list the `SeparationZ/`
      subdirectory with its live file count and a one-line description, and refresh its
      `Last verified` date. Do not attempt to repair the unrelated stale table in
      `Separation/README.md`.
- [x] Measure the axiom profile of each of the seven contract declarations with `#print axioms`
      (or `lean_verify`) against the built tree, and paste the **measured** output. Never hand-type
      a profile.
- [x] Append matched pairs to **both** heredocs in `scripts/check-module-invariants.sh` --
      `C14_BASELINE` and `C14LEAN` -- at the same trailing position, directly after the existing
      `Expressiveness` lines. Omit any declaration whose `#print axioms` reports no
      `depends on axioms` line at all: `C14_OUT` filters that line out, so a baseline entry for
      such a declaration can never match and a `#print axioms` line for it in `C14LEAN` is a
      silent no-op.
- [x] Update `docs/theorem-index.md`: restate the `.ZTime` rows whose Statement cell currently *(deviation: altered — no `.ZTime` row was restated and no conditionality removed; a sub-band of 20 rows was added for the landed `ℤ` validities, and the band preamble was corrected factually to say that part of the route is formalized while the hypothesis is discharged nowhere)*
      opens "Given separation over ℤ-time frames — a hypothesis this tree does not formalize"
      (`openValidIn_ztime_iff_tr`, `exists_translation_ztime`, `decidableOpenValidZTimeOfTr`) so
      the parenthetical records that the hypothesis is now discharged in-tree by
      `separationOver_ztime`; add rows for the seven new declarations; and amend the
      Expressiveness-band preamble, which currently states that the separation theorems are
      "not formalized in this tree and discharged nowhere in it".
- [x] Leave every `.RTime` row, and the preamble's `.Dense`/`.Base` sentences, unchanged: `U`/`S`
      is not separable over `ℚ` and GHR 10.3.20 is out of scope.
- [x] Add the one-line caveat the research report recommends to
      `Boneyard/Kamp/KampWeakCanonical/Separation/README.md`: the archive's
      `replace_box_with_top` normalization is sound for `Formula` over `IntStructure` and
      **unsound** for `PlusFormula` over a task frame, so it must not be transplanted.
- [x] Bring the **doc-sync pinned counts** into agreement with the tree: thirteen new modules
      change the file and line counts that `typst/generated/status.typ` and the ancestor-chain
      READMEs (`README.md`, `FormalSystem/README.md`, `FormalSystem/Metalogic/README.md`) carry,
      and C14 asserts documented counts match in `docs/`, `README.md` **and**
      `FormalSystem/**/*.lean` docstrings. Re-derive every count from the tree in this same run;
      never adjust one by hand to make a comparison pass.
- [x] Regenerate `FormalSystem.lean` if any import changed, and check each new module's warning
      count against `scripts/warning-budget.txt`.

**Timing**: 1.5 hours

**Depends on**: 13

**Verification Tier**: interface

**Tier Justification**: The phase changes the subtree aggregator's import list and the generated
library root, so the one-hop dependent set is exactly those two modules plus the amended host
module -- covered by
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Expressiveness`
followed by `bash scripts/check-module-invariants.sh`, which is what actually checks C4, C8, C14,
C15 and C33 over the changed import graph and baselines.

**Scope Hypothesis**: Seven new theorem-index rows, three restated `.ZTime` rows, and matched C14
pairs for however many of the seven declarations actually report a `depends on axioms` line (fewer
than seven if any is axiom-free). Confirm at implementation time from the measured `#print axioms`
output itself, not from this estimate, and record the actual counts in the phase's own notes.

**Files to modify**:

- `FormalSystem/Metalogic/Expressiveness/OpenFutureElimination.lean` - module docstring only; no
  declaration changes.
- `FormalSystem/Metalogic/Expressiveness.lean` - add the new modules to the import list.
- `FormalSystem/Metalogic/Expressiveness/README.md` - list `SeparationZ/`, refresh
  `Last verified`.
- `FormalSystem/Metalogic/Expressiveness/SeparationZ/README.md` - final module table.
- `scripts/check-module-invariants.sh` - matched C14 pairs in both heredocs.
- `docs/theorem-index.md` - seven new rows, three restated `.ZTime` rows, amended band preamble.
- `Boneyard/Kamp/KampWeakCanonical/Separation/README.md` - the `replace_box_with_top` caveat.
- `typst/generated/status.typ` - re-derived file and line counts.
- `README.md` - re-derived counts on the ancestor chain.
- `FormalSystem/README.md` - re-derived counts on the ancestor chain.
- `FormalSystem/Metalogic/README.md` - re-derived counts on the ancestor chain.
- `FormalSystem.lean` - regenerated if any import changed.

**Verification**:

- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Expressiveness`
  green.
- `bash scripts/check-module-invariants.sh` exits 0, including C14, both C15 assertions, C33 and
  C28.
- `bash scripts/readme-lint.sh FormalSystem` exits 0.
- Every pasted axiom profile is byte-identical to the measured `#print axioms` output captured in
  the same run.
- `grep -n 'RTime' docs/theorem-index.md` confirms no `.RTime` row's conditionality was weakened.
- No docstring, README cell or index cell reads as if separation holds at `.Dense` or `.Base`.


#### Reasoned Exclusions

| Item | Reason | Evidence |
|------|--------|----------|
| The `OpenFutureElimination.lean` module-docstring amendment | The contingency branch of `## Rollback/Contingency` requires this docstring left unchanged when `separationOver_ztime` is not reached. Its `## What is NOT proved here` still states the truth: the separation hypothesis is discharged nowhere in this tree. | `git diff` over `FormalSystem/Metalogic/Expressiveness/OpenFutureElimination.lean` is empty across this task's commits |
| Restating the three `.ZTime` rows (`openValidIn_ztime_iff_tr`, `exists_translation_ztime`, `decidableOpenValidZTimeOfTr`) as unconditional | Same reason: the hypothesis they take is not discharged, so each stays verbatim conditional. What was added instead is a sub-band of 20 rows for the landed `ℤ` validities, plus a factual correction to the band preamble recording that part of the route is formalized while the hypothesis is discharged nowhere. | `docs/theorem-index.md`; `grep -n 'RTime' docs/theorem-index.md` confirms no `.RTime` row changed either |
| C14 matched pairs for the seven contract declarations | None of the seven exists: they are Phase 12's and Phase 13's deliverables, excluded upstream. 19 matched pairs were appended instead, for the declarations that did land and that report a `depends on axioms` line; the six axiom-free ones (`isPureFuture_toPlus`, `isPurePast_toPlus`, `isSeparated_case1Rhs` through `isSeparated_case4Rhs`) are deliberately omitted, since `C14_OUT` filters that line out and a baseline entry for them could never match. | `scripts/check-module-invariants.sh`, 19 `SeparationZ` lines in each of `C14_BASELINE` and `C14LEAN`; `check-module-invariants.sh` reports `PASS C14` |

Closed under the contingency branch, not interrupted. Every axiom profile pasted into the
baseline was measured by `#print axioms` against the built tree in the same run.

---

### Phase 15: Full Gate Sweep and Commit [COMPLETED WITH EXCLUSIONS]

**Goal**: The complete gate set is green against its pre-task baselines, with zero `sorry`, zero
vacuous definitions and no new axiom beyond what the landed eliminations already carry.

**Tasks**:

- [x] Guarded **scoped** build of the subtree aggregator:
      `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Expressiveness`.
- [x] Guarded **unscoped** build: `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build`.
      Detach as a shell-level background job and block on it with the bounded single-call idiom
      (`context/patterns/bounded-build-waiter.md`); never `Bash(run_in_background: true)`.
- [x] `bash scripts/check-module-invariants.sh` -- green against its pre-task baseline, including
      C14, both C15 assertions, C19, C23, C24, C26, C28, C29, C30, C31, C32 and C33.
- [x] `bash scripts/check-metalogic-cycles.sh` -- green, all three assertions PASS. It was green
      before this task and no new module imports a `FormalSystem.Metalogic.<other>` subdirectory,
      so no perturbation of assertion A or B is expected; a failure means that constraint was
      broken and the offending import must be removed.
- [ ] `bash .claude/scripts/verify-deploy.sh` -- the complete gate set this repository aggregates. *(deviation: deferred — discharged against this dispatch's scoped verification tier per its Batch Gate Deferral directive; no gate of that script maps to this task's touched paths, so the repository's own Lean and documentation gate set was run in full instead)*
- [x] Zero-debt sweep: `grep -rn 'sorry' ` over every changed `.lean` file returns nothing, and no
      added declaration matches a prohibited vacuous shape (`:= True`, `:= trivial`, `:= Unit`,
      `:= Trivial`).
- [x] Confirm no added declaration carries `noncomputable`, in particular `sep`, `sepZ` and `trZ`.
- [x] Re-measure every axiom profile and confirm no new axiom beyond `[propext, Classical.choice,
      Quot.sound]`, the ceiling the landed eliminations already carry. A profile exceeding it is a
      finding to report, not to baseline.
- [x] Commit with explicit per-file staging (`git add -- <path> ...`), never a directory or glob,
      reviewing `git status --short` and `git diff --staged` first. If a foreign commit or foreign
      uncommitted modification is visible, STOP and report after checking `git log`.

**Timing**: 1 hour

**Depends on**: 14

**Verification Tier**: full

**Files to modify**:

- None. This phase runs gates and commits; any edit it provokes belongs to the phase that owns the
  file.

**Verification**:

- The complete gate set: `bash .claude/scripts/verify-deploy.sh` green, plus
  `bash scripts/check-module-invariants.sh` and `bash scripts/check-metalogic-cycles.sh` green
  against their pre-task baselines, plus the guarded unscoped `lake build` green.
- Zero `sorry` and zero vacuous definitions across every changed file.
- No added declaration is `noncomputable`.
- Every axiom profile measured in this same run, none exceeding the pre-task ceiling.
- `git log` confirms exactly this task's commits and that no foreign work was staged.

#### Reasoned Exclusions

| Item | Reason | Evidence |
|------|--------|----------|
| `bash .claude/scripts/verify-deploy.sh` — the complete aggregated gate set | Deferred to the batch stage under this dispatch's Batch Gate Deferral directive, which replaces the phase's declared `full` tier with a narrowing invocation for this one dispatch. No gate of that script and no suite of `run-all.sh` maps to this task's touched paths: the script compares the deployed `.claude/` tree against the source store and references neither `check-module-invariants.sh`, `readme-lint.sh`, `docs/theorem-index.md` nor `lake build`. The repository's own Lean and documentation gate set was therefore run in full in its place. Deferred, never forgiven. | `grep -n 'check-module-invariants\|readme-lint\|theorem-index\|lake build' .claude/scripts/verify-deploy.sh` returns nothing; the dispatch's own deploy-freshness context separately records the deployed tree as stale for `core` and `literature`, independently of this task |
| `check-module-invariants.sh` green on **C16** | One `unusedArguments` finding on `FormalSystem/Metalogic/Decidability/RaySummary/LadderChain.lean:2136` (`mem_cellAt_of_shift_of_hasForwardSlack`, argument 23). That file was last modified 2026-11-03, two days before this task's first commit, and is in no part of this task's file set. A **pre-existing** failure, reported rather than baselined — `lake exe runLinter --update` would grandfather it and is not run. | `git log -1 --date=short -- FormalSystem/Metalogic/Decidability/RaySummary/LadderChain.lean` → `ea08629d8 2026-11-03 task 850 phase 7` |
| C14 re-measurement of the seven contract declarations | None exists; see Phases 12 and 13. The 19 declarations that did land were re-measured in this same run and all sit at or below the pre-task ceiling `[propext, Classical.choice, Quot.sound]`. | `PASS C14  every pinned declaration matches its axiom baseline` |

Every other item of this phase ran and is green: the scoped aggregator build, the test-library
build, the guarded unscoped `lake build` (with an `.olean`-newer-than-source check for every
touched module), `check-metalogic-cycles.sh` (all three assertions), `readme-lint.sh`,
`check-copyright-headers.sh --strict`, `typst-sync-check.sh --counts-only`, the zero-sorry and
zero-vacuous sweeps, and the no-`noncomputable` confirmation.


### Phase 16: Re-specified Decision Gate -- the Reduction Order and the Two Printed-Text Defects [COMPLETED]

**Goal**: The route Phase 5 measured against is replaced by the one the source actually uses. GHR
10.2.3's reduction order is pinned as an acyclic DAG with every edge named at a source step; the
two-disjunct Case 5 bracketing repair is pinned and probed against the heavier candidate already
on record; and Case 8's printed third disjunct is pinned as non-redundant by a concrete `ℤ` model.

**Tasks**:

- [x] Add `specs/867_formalize_gabbay_separation_ztime/prototype/cases-5-8-reduction.lean`,
      importing or re-declaring the three probe models `v₀`, `v₁` and `v₂` already compiled in
      `cases-5-8-probe.lean` rather than inventing new ones.
- [x] Pin the reduction DAG in that file's own comments, one edge per line, each naming the source
      step it comes from: Cases 1 and 2 are base; Cases 4 and 5 are independent semantic
      arguments; Case 8 follows from the generic negated-since distribution identity plus Case 5;
      Case 7 from Cases 8 and 4; Case 6 from Cases 3 and 5.
- [x] **Do not re-attempt direct semantic re-anchoring for Cases 6, 7 or 8.** That method is the
      measured route defect: it is not how the source derives them, and it is what produces the
      unexpressible `∃∀` guard-failure condition recorded in Phase 5's gate measurement.
- [x] State the two-disjunct Case 5 bracketing repair as a named candidate beside the pinned
      `case5RHS`: the printed formula with `[A ∨ (B ∧ U(A,B))]` attached to the first disjunct
      only and `S(A ∧ S(a,B), A ∨ B ∨ ¬S(¬q,¬A)) ∧ ¬S(¬q,¬A)` as the second. Probe it on all three
      recorded models, including the `reports/01` model that refutes the printed formula.
- [x] Record which of the two Case 5 candidates Phase 17 implements. Prefer the two-disjunct
      repair if it survives all three probes; keep `case5RHS` as the recorded fallback. Implement
      one, not both. *(deviation: altered -- NEITHER of the two is implemented. The two-disjunct
      repair is refuted by the prototype's compiled `v₃_not_twoDisjRhs` on a fourth model, and
      `case5RHS` carries no correctness derivation anywhere in this task's record. A third
      candidate is pinned: GHR's own `Core` verbatim with `W` moved from a shared conjunct to a
      case split, with its full semantic derivation and the one new lemma it needs recorded at
      the definition. See the prototype's `## I. Gate measurement`.)*
- [x] Exhibit a concrete `ℤ` leaf valuation and an evaluation point at which Case 8's printed
      **third** disjunct holds while the first two fail, and record both. GHR's redundancy claim
      is false and Phase 18 must keep all three disjuncts.
- [x] **Gate measurement**: state explicitly whether each of the three criteria in
      `**Verification**` is met, and record the count (expected: 3 of 3). State in the same block
      that this measurement supersedes Phase 5's gate verdict for Cases 6-8, and why.

**Timing**: 2 hours

**Depends on**: 15

**Verification Tier**: local

**Tier Justification**: The phase's only file is a prototype `.lean` under `specs/`, outside the
build graph, covered by compiling it directly --
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- env lean specs/867_formalize_gabbay_separation_ztime/prototype/cases-5-8-reduction.lean`
-- so no library module is touched and no suite maps to the path.

**Scope Hypothesis**: One new prototype module carrying one named Case 5 candidate beside the
existing one, five recorded reduction edges, and one redundancy-refuting model for Case 8.
Confirm at implementation time from the file's own recorded results; a criterion with no recorded
measurement has not met the gate.

**Files to modify**:

- `specs/867_formalize_gabbay_separation_ztime/prototype/cases-5-8-reduction.lean` - new: the
  reduction DAG, the two-disjunct Case 5 candidate with its probe results, and the Case 8
  redundancy-refuting model.

**Verification**:

- The prototype file elaborates at exit 0 under the guarded `env lean` invocation above.
- **Gate criterion, 3 of 3 required**: (a) a Case 5 candidate -- the two-disjunct repair or the
  recorded `case5RHS` fallback -- survives all three probe models; (b) the five reduction edges
  are recorded, each naming its source step, and the DAG they form is acyclic; (c) a model and an
  evaluation point are recorded at which Case 8's third disjunct is the only true one.
- The gate verdict is written into the file, with the count, as Phase 5's was.
- If (b) fails, the reduction-edge contingency branch of `## Rollback/Contingency` applies and
  Phases 17-27 are not attempted as written.

---

### Phase 17: `ElimHard.lean` -- GHR 10.2.3 Case 5 [COMPLETED]

**Goal**: Case 5 lands alone, from the Phase 16 candidate. It is the only one of the four hard
cases whose derivation is semantic, and every other reduces to it or to an already-landed case.

**Tasks**:

- [x] Add `FormalSystem/Metalogic/Expressiveness/SeparationZ/ElimHard.lean`. Define `case5Rhs`
      verbatim from the Phase 16 pinned candidate; do not re-derive a different right-hand side
      mid-proof.
- [x] Prove `usTruth_case5` at arbitrary `USForm` parameters `a`, `q`, `A`, `B`, in the statement
      shape and guard-first order `Eliminations.lean`'s `usTruth_case1` through `usTruth_case4`
      already use.
- [x] Discharge `isSeparated_case5Rhs` from `IsSOnly`/`IsUOnly` hypotheses on the four parameters,
      exactly as `isSeparated_case1Rhs` does.
- [x] Record in the module docstring that the printed Case 5 is **refuted** over `ℤ`, name the
      refuting model (`a(0)`, `A(1)`, `B ≡ ⊥`, `q ∈ {1,2}`, at `t = 3`), state that the landed form
      is the bracketing repair rather than the printed formula, and keep the citation so a later
      reader does not restore the printed form.
- [x] **Do not** derive Case 5 from the junction-depth induction, from 10.2.4, or from any later
      lemma.
- [ ] Append the module's row to `SeparationZ/README.md` and regenerate `FormalSystem.lean`.
- [x] Run `bash scripts/typst-sync-check.sh --fix` and stage `typst/generated/status.typ` in this
      phase's commit: the pre-commit counts gate fires on every module-adding commit, recorded as
      a gate-collision issue in this task's `issues.jsonl` at dispatch 7.

**Timing**: 2.5 hours

**Depends on**: 16

**Verification Tier**: local

**Tier Justification**: One additive module consuming only earlier `SeparationZ` lemmas;
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Expressiveness.SeparationZ.ElimHard`
covers it, and nothing outside the subtree can see these declarations yet.

**Files to modify**:

- `FormalSystem/Metalogic/Expressiveness/SeparationZ/ElimHard.lean` - new: `case5Rhs`,
  `usTruth_case5`, `isSeparated_case5Rhs`, and the refutation note.
- `FormalSystem/Metalogic/Expressiveness/SeparationZ/README.md` - add this module's row.
- `typst/generated/status.typ` - regenerated counts.
- `FormalSystem.lean` - regenerated.

**Verification**:

- Scoped guarded build green for the new module.
- The landed `case5Rhs` matches Phase 16's recorded candidate verbatim; a mismatch is a plan
  deviation to raise under `rules/plan-compliance.md`, not to annotate.
- `grep -n 'JunctionDepth\|allFormulasSeparable\|all_formulas_separable'` over the module returns
  nothing -- the anti-circularity check.
- Zero `sorry`, zero vacuous definitions.

---

### Phase 18: The Negated-Since Distribution Identity and GHR 10.2.3 Case 8 [COMPLETED]

**Goal**: A generic negated-since distribution identity is named and proved, and Case 8 follows
from it plus Case 5 -- the reduction the source uses, not a semantic re-derivation -- with all
three disjuncts of the landed right-hand side kept.

**Tasks**:

- [x] State the distribution identity as its own named lemma, generic in the event and the guard:
      the form that rewrites `(USForm.snce G E).neg` into `USForm.allPast E.neg` disjoined with a
      `snce` whose event and guard are Boolean combinations of `E`, `G` and their negations. The
      landed `usTruth_neg_snce_strong` and `usTruth_neg_snce` of `NegationEquiv.lean` are the GHR
      10.2.2 instances to build on; if one of them already *is* the identity at the generality
      needed, consume it and record that in the docstring rather than restating it.
- [x] Prove `usTruth_case8` for `S(a ∧ ¬U(A,B), q ∨ ¬U(A,B))` by the reduction: negate the
      left-hand side, apply the identity, recognise the resulting `snce` as Case 5's shape at the
      instantiation the identity produces, apply Phase 17's `usTruth_case5`, and negate back.
- [x] Write the instantiation into the docstring explicitly: which parameters Case 5 is applied
      at, and which Boolean simplification licenses reading the identity's `snce` as Case 5's
      shape. A reduction whose instantiation is not written down is not checkable.
- [x] **Keep all three disjuncts** of `case8Rhs`. GHR's claim that the third is redundant is
      false, refuted by Phase 16's model; cite that model at the definition. Do not simplify to
      two disjuncts even if a tactic closes the equivalence without the third.
- [x] Discharge `isSeparated_case8Rhs` as in Phase 17.
- [x] Record in the docstring that the Cases 5/8 negation route is **not** circular: Case 5 is
      proved semantically in Phase 17 and is strictly upstream, so the edge runs one way only.
      Phase 5's `#### Reasoned Exclusions` recorded a loop under the assumption that Case 5 itself
      needed Case 8; it does not.
- [x] README row, regenerated root, and the `typst-sync-check.sh --fix` step as in Phase 17.

**Timing**: 2.5 hours

**Depends on**: 17

**Verification Tier**: local

**Tier Justification**: One module extended plus at most one lemma added to `NegationEquiv.lean`,
both inside the subtree;
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Expressiveness.SeparationZ.ElimHard`
builds `NegationEquiv` transitively and covers the whole edit.

**Scope Hypothesis**: One distribution identity (new, or a recorded consumption of a landed one),
`case8Rhs` with exactly three disjuncts, `usTruth_case8`, and `isSeparated_case8Rhs`. Confirm at
implementation time by `git diff --stat` over the two modules and by counting `case8Rhs`'s
top-level disjuncts.

**Files to modify**:

- `FormalSystem/Metalogic/Expressiveness/SeparationZ/ElimHard.lean` - `case8Rhs`,
  `usTruth_case8`, `isSeparated_case8Rhs`, the non-redundancy note and the acyclicity note.
- `FormalSystem/Metalogic/Expressiveness/SeparationZ/NegationEquiv.lean` - the generic
  distribution identity, if one is added rather than consumed.
- `FormalSystem/Metalogic/Expressiveness/SeparationZ/README.md` - refresh the affected rows.
- `typst/generated/status.typ` - regenerated counts.
- `FormalSystem.lean` - regenerated if any import changed.

**Verification**:

- Scoped guarded build green.
- `case8Rhs` has three top-level disjuncts and the docstring cites Phase 16's refuting model.
- The Case 5 instantiation is written in the docstring and resolves against `usTruth_case5`'s
  signature.
- The anti-circularity grep of Phase 17 returns nothing over both modules.
- Zero `sorry`, zero vacuous definitions.

---

### Phase 19: GHR 10.2.3 Cases 7 and 6 by Reduction [COMPLETED]

**Goal**: The two remaining hard cases land as the reductions the source gives -- Case 7 from
Cases 8 and 4, Case 6 from Cases 3 and 5 -- closing all eight eliminations.

**Tasks**:

- [x] Prove `usTruth_case7` for `S(a ∧ U(A,B), q ∨ ¬U(A,B))` from Phase 18's `usTruth_case8` and
      the landed `usTruth_case4`, with the instantiation of each written into the docstring.
- [x] Prove `usTruth_case6` for `S(a ∧ ¬U(A,B), q ∨ U(A,B))` from the landed `usTruth_case3` and
      Phase 17's `usTruth_case5`, likewise.
- [x] Define `case6Rhs` and `case7Rhs` as the reductions produce them; do not hand-minimise
      either. A disjunct whose redundancy is not proved stays, for the reason Phase 16 measured at
      Case 8.
- [x] Discharge `isSeparated_case6Rhs` and `isSeparated_case7Rhs`.
- [x] **Do not** derive either case from the junction-depth induction, from 10.2.4, or from
      Theorem 10.2.9: all eight cases stay strictly upstream of Phase 20.
- [x] Append a table to the module docstring recording the reduction DAG as landed -- one row per
      case, naming the lemmas it consumes -- so acyclicity is auditable from the module alone.
- [x] README row refresh, regenerated root, and the `typst-sync-check.sh --fix` step.

**Timing**: 2.5 hours

**Depends on**: 18

**Verification Tier**: local

**Tier Justification**: The same single module as Phases 17 and 18, built by the same scoped
guarded invocation; no declaration outside the subtree can see these names yet.

**Files to modify**:

- `FormalSystem/Metalogic/Expressiveness/SeparationZ/ElimHard.lean` - `case6Rhs`, `case7Rhs`,
  `usTruth_case6`, `usTruth_case7`, their separatedness lemmas, and the landed-DAG table.
- `FormalSystem/Metalogic/Expressiveness/SeparationZ/README.md` - refresh the module's row.
- `typst/generated/status.typ` - regenerated counts.
- `FormalSystem.lean` - regenerated if any import changed.

**Verification**:

- Scoped guarded build green for `...SeparationZ.ElimHard`.
- All eight `usTruth_case1` through `usTruth_case8` resolve, and each of the four hard cases
  carries a proved separatedness lemma.
- The landed-DAG table's edges match Phase 16's recorded DAG, and the anti-circularity grep
  returns nothing.
- Zero `sorry`, zero vacuous definitions.

---

### Phase 20: Normal Forms, 10.2.4's Actual Precondition, and GHR Lemma 10.2.4 [NOT STARTED]

**Goal**: Disjunctive and conjunctive normal forms for the Boolean skeleton of a `USForm` with
truth preservation; the precondition GHR 10.2.4 actually consumes, stated as its own predicate
rather than approximated by `IsSeparated`; and 10.2.4 itself, from the normal forms plus all eight
eliminations. This reinstates the deliverable Phase 8 excluded, and this task list is the
operative one.

**Tasks**:

- [ ] Add `NormalForm.lean` with `dnf` and `cnf` on the Boolean skeleton of a `USForm` (treating
      every `untl`/`snce` subformula and every `leaf` as an opaque literal), each with a
      truth-preservation lemma at every `v` and `t`.
- [ ] Define the precondition 10.2.4 consumes as its own predicate: every `untl` occurring is the
      single type `untl B A`, and none occurs under a `snce`. Prove its relationship to the landed
      `IsSeparated` of `Eliminations.lean` in whichever direction holds, as a named lemma.
- [ ] Record at that predicate, in its docstring, that it is **strictly weaker** than
      `IsSeparated` -- a formula can satisfy it while carrying an impure `snce` -- and that
      10.2.4's input position must not be given the stronger bar. Decision D-f is the ruling; a
      downstream phase that re-imposes `IsSeparated` at an input position reintroduces the defect
      Phase 5's gate measured.
- [ ] State GHR 10.2.4 at that precondition: for `untl`/`snce`-free `A` and `B`, if `C` and `F`
      satisfy it, then `snce F C` has a syntactically separated equivalent in which `untl` occurs
      only as `untl B A`.
- [ ] Prove it: `dnf` on the event argument, `cnf` on the guard argument, Phase 3's
      distributivities to split the resulting clauses, then Cases 1-8 clause by clause -- each
      Boolean constituent has the shape `snce (C₂ ∨ ±untl B A) (C₁ ∧ ±untl B A)`, which is exactly
      one of the eight.
- [ ] Give 10.2.4's **conclusion** a proved `IsSeparated` witness, not a prose claim; only its
      hypothesis is the weaker predicate.
- [ ] README row, regenerated root, and the `typst-sync-check.sh --fix` step.

**Timing**: 3 hours

**Depends on**: 19

**Verification Tier**: local

**Tier Justification**: One additive module;
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Expressiveness.SeparationZ.NormalForm`
covers it, since no declaration outside the subtree references these names.

**Scope Hypothesis**: Two normal-form functions with one truth-preservation lemma each, one new
predicate with one relationship lemma, and GHR 10.2.4. Confirm at implementation time by counting
the landed `def` and `theorem` keywords in the module against that list.

**Files to modify**:

- `FormalSystem/Metalogic/Expressiveness/SeparationZ/NormalForm.lean` - new: `dnf`, `cnf`, the
  10.2.4 precondition predicate with its relationship lemma, and GHR 10.2.4.
- `FormalSystem/Metalogic/Expressiveness/SeparationZ/README.md` - add this module's row.
- `typst/generated/status.typ` - regenerated counts.
- `FormalSystem.lean` - regenerated.

**Verification**:

- Scoped guarded build green for the new module.
- The normal-form truth-preservation lemmas, the relationship lemma and GHR 10.2.4 compile
  sorry-free.
- GHR 10.2.4's hypothesis is the new predicate and its conclusion carries a proved `IsSeparated`
  witness; neither is a prose claim.
- Zero `sorry`, zero vacuous definitions.

---

### Phase 21: GHR Lemmas 10.2.5 and 10.2.6 [NOT STARTED]

**Goal**: The `snce`-nesting induction and the `U`-type-count induction, each with its measure
defined structurally and its strict decrease proved rather than asserted. This reinstates the
deliverable Phase 9 excluded, and this task list is the operative one.

**Tasks**:

- [ ] Add `Hierarchy.lean`. Define `snceDepthAbove : USForm → ℕ`, the maximum number of nested
      `snce`s above any `untl` occurrence, as a structural recursion -- GHR's occurrence-level
      "most deeply nested `S(C,F)`" has no Lean counterpart and must be restated this way.
- [ ] Prove GHR 10.2.5 by induction on that measure, applying Phase 20's 10.2.4 at each maximal
      `snce` and proving the measure strictly decreases at the step.
- [ ] Define `uTypeCount : USForm → ℕ`, the number of distinct maximal `untl` subformulas, again
      structurally.
- [ ] Prove GHR 10.2.6 by induction on `uTypeCount`: abstract each `untl Bᵢ Aᵢ` for `i < n` to a
      fresh leaf above `maxLeaf` (Phase 1's `freshLeaf` and `usTruth_congr_of_update` are the
      whole device), separate for the remaining type by 10.2.5, reindex back, and re-separate the
      resulting impure pure-past parts by the induction hypothesis.
- [ ] Prove the strict-decrease lemma for `uTypeCount` under abstract-separate-reindex as a named
      obligation with its own statement; GHR assert it without proof.
- [ ] Where a step must discharge 10.2.4's hypothesis, discharge Phase 20's weaker predicate,
      never `IsSeparated`. D-f is the ruling.
- [ ] README row, regenerated root, and the `typst-sync-check.sh --fix` step.

**Timing**: 2.5 hours

**Depends on**: 20

**Verification Tier**: local

**Tier Justification**: One additive module;
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Expressiveness.SeparationZ.Hierarchy`
covers the whole edit.

**Files to modify**:

- `FormalSystem/Metalogic/Expressiveness/SeparationZ/Hierarchy.lean` - new: `snceDepthAbove`,
  `uTypeCount`, their strict-decrease lemmas, GHR 10.2.5 and 10.2.6.
- `FormalSystem/Metalogic/Expressiveness/SeparationZ/README.md` - add this module's row.
- `typst/generated/status.typ` - regenerated counts.
- `FormalSystem.lean` - regenerated.

**Verification**:

- Scoped guarded build green for the new module.
- Both measures are total structural recursions (no `partial`, no well-founded-recursion `sorry`),
  and each strict-decrease claim is a named, proved theorem.
- No input position in the module demands `IsSeparated` where 10.2.4's weaker predicate suffices.
- Zero `sorry`, zero vacuous definitions.

---

### Phase 22: GHR Lemma 10.2.7 [NOT STARTED]

**Goal**: The `untl`-nesting induction, for formulas with no `snce` nested within an `untl`. This
reinstates the deliverable Phase 10 excluded, and this task list is the operative one.

**Tasks**:

- [ ] Add `UNesting.lean`. Define `untlDepth : USForm → ℕ`, the maximum nesting depth of `untl`
      beneath a `snce`, structurally.
- [ ] Prove GHR 10.2.7 by induction on it: abstract each inner `untl Yᵢⱼ Xᵢⱼ` to a fresh leaf,
      separate by Phase 21's 10.2.6, reindex back, and re-separate.
- [ ] Prove the step's strict-decrease obligation explicitly, as in Phase 21.
- [ ] State the hypothesis "no `snce` nested within an `untl`" as a decidable structural predicate
      on `USForm`, not as prose, so 10.2.8 can discharge it mechanically.
- [ ] README row, regenerated root, and the `typst-sync-check.sh --fix` step.

**Timing**: 1.5 hours

**Depends on**: 21

**Verification Tier**: local

**Tier Justification**: One additive module;
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Expressiveness.SeparationZ.UNesting`
covers it.

**Files to modify**:

- `FormalSystem/Metalogic/Expressiveness/SeparationZ/UNesting.lean` - new: `untlDepth`, its
  strict-decrease lemma, GHR 10.2.7 and its structural hypothesis predicate.
- `FormalSystem/Metalogic/Expressiveness/SeparationZ/README.md` - add this module's row.
- `typst/generated/status.typ` - regenerated counts.
- `FormalSystem.lean` - regenerated.

**Verification**:

- Scoped guarded build green for the new module.
- The nesting hypothesis is a structural predicate with a `Decidable` instance or a decision
  procedure, not a prose side condition.
- Zero `sorry`, zero vacuous definitions.

---

### Phase 23: Junction Depth, GHR Lemma 10.2.8 and Theorem 10.2.9 [NOT STARTED]

**Goal**: Junction depth is a structural measure with proved monotonicity bounds and a proved
strict decrease, GHR 10.2.8 holds, and the Separation Theorem over `ℤ` follows. This reinstates
the deliverable Phase 11 excluded, and this task list is the operative one. The junction-depth
strict decrease was never reached under the earlier route; it is now the plan's primary stall
candidate.

**Tasks**:

- [ ] Add `JunctionDepth.lean`. Define `junctionDepth : USForm → ℕ` -- the maximal length of a
      chain of nested `untl`/`snce` subformulas **alternating** between the two -- as a structural
      recursion, with the mutually-recursive `untl`-headed and `snce`-headed auxiliaries the
      alternation requires.
- [ ] Prove the monotonicity bounds (`junctionDepth` of each immediate subformula is at most that
      of the whole, at `imp`, `untl` and `snce`). The archived development's `jd_imp_le_left`,
      `jd_untl_le_left` and siblings indicate the shape; re-derive each, do not transplant.
- [ ] Prove that `junctionDepth ψ ≤ 1` implies `IsSeparated ψ`.
- [ ] Prove GHR 10.2.8 by strong recursion on `junctionDepth`: abstract each maximal `snce E F`
      inside a maximal `untl Bᵢ Aᵢ` to a fresh leaf, separate by Phase 22's 10.2.7, reindex back,
      and prove the result's junction depth is strictly smaller. **That strict decrease is the
      phase's central named obligation** -- GHR assert it with no proof.
- [ ] Prove Theorem 10.2.9: every `USForm` has a syntactically separated equivalent at every `v`
      and `t`, as a function `sep : USForm → USForm` together with
      `usTruth_sep_iff : usTruth v t (sep ψ) ↔ usTruth v t ψ` and
      `isSeparated_sep : IsSeparated (sep ψ)`.
- [ ] Declare `sep` as a plain `def` with no `noncomputable` keyword. If the recursion needs
      `Classical.choose` anywhere, the construction is wrong -- Phase 25's executability
      deliverable depends on `sep` being computable.
- [ ] README row, regenerated root, and the `typst-sync-check.sh --fix` step.

**Timing**: 3 hours

**Depends on**: 22

**Verification Tier**: local

**Tier Justification**: One additive module;
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Expressiveness.SeparationZ.JunctionDepth`
covers it, and `sep`'s computability is checked inside the same build by the absence of the
`noncomputable` keyword.

**Files to modify**:

- `FormalSystem/Metalogic/Expressiveness/SeparationZ/JunctionDepth.lean` - new: `junctionDepth`,
  its bounds, the strict-decrease lemma, GHR 10.2.8, `sep`, `usTruth_sep_iff`, `isSeparated_sep`.
- `FormalSystem/Metalogic/Expressiveness/SeparationZ/README.md` - add this module's row.
- `typst/generated/status.typ` - regenerated counts.
- `FormalSystem.lean` - regenerated.

**Verification**:

- Scoped guarded build green for the new module.
- **Blocking check**: `sep` compiles without `noncomputable`. If Lean demands the keyword, mark
  the phase `[BLOCKED]` and raise it rather than adding it.
- The strict-decrease lemma is a named, proved theorem, not a `simp`-closed afterthought.
- Zero `sorry`, zero vacuous definitions.

---

### Phase 24: CNF Packaging and the Discharge of `SeparationOver` [NOT STARTED]

**Goal**: A separated `USForm` is packaged into the binary clause list `sepForm` consumes, and
`sepZ`, `sepZ_sepClauses`, `plusTruthAt_sepZ_iff` and `separationOver_ztime` land. This reinstates
the deliverable Phase 12 excluded, and this task list is the operative one.

**Tasks**:

- [ ] Add `Packaging.lean`. Classify each literal of a separated `USForm`'s Boolean skeleton as
      past-admissible, future-admissible, or both (leaves are both); CNF-normalize the skeleton by
      Phase 20's `cnf`; and per clause put the `snce`-only and leaf literals in the first
      component and the `untl`-only literals in the second, padding an absent side with
      `PlusFormula.bot` (a leaf constructor of both `IsPurePast` and `IsPureFuture`).
- [ ] Prove the packaging's truth-preservation lemma: the packaged clause list's `sepForm` is
      equivalent to the separated formula at every `v` and `t`. This step has no counterpart in
      the source and is the phase's main new obligation.
- [ ] Add `Discharge.lean` in namespace `FormalSystem.Metalogic.Expressiveness` (not the
      `SeparationZ.` sub-namespace -- these are the contract declarations). Define
      `sepZ : PlusFormula → List (PlusFormula × PlusFormula)` as the composite: leaf-abstract,
      `sep`, package, `toPlus` each component.
- [ ] Prove `sepZ_sepClauses` from Phase 2's purity transfer plus the compiled
      `pastDet_of_isPurePast` and `futDet_of_isPureFuture`. Purity is frame-independent, so the
      `hreg`/`hz` hypotheses are consumed only to match `SeparationOver`'s shape.
- [ ] Prove `plusTruthAt_sepZ_iff` by routing through Phase 2's carrier bridge and
      `plusValidZTime_iff_plusValidInt` to `t : ℤ`, then Phase 2's truth transfer, Phase 23's
      `usTruth_sep_iff` and the packaging lemma.
- [ ] Prove `separationOver_ztime : SeparationOver TaskFrame.IsZTime` as
      `fun φ => ⟨sepZ φ, fun F hreg hz => ⟨sepZ_sepClauses φ F hreg hz, plusTruthAt_sepZ_iff φ hreg hz⟩⟩`,
      matching the `∃ L` before `∀ F` binder order exactly.
- [ ] Give each of the four a docstring carrying a `Paper:` line citing GHR Theorem 10.2.9
      (vol. 1, Chapter 10 §10.2). C15's second assertion requires the anchor at the declaration.
- [ ] README rows, regenerated root, and the `typst-sync-check.sh --fix` step.

**Timing**: 2.5 hours

**Depends on**: 23

**Verification Tier**: local

**Tier Justification**: Two additive modules introducing new names only, with no existing
signature changed, so the scoped guarded build of the second
(`... -- build FormalSystem.Metalogic.Expressiveness.SeparationZ.Discharge`) builds the first
transitively and covers the whole edit.

**Scope Hypothesis**: Two new modules carrying four contract declarations plus the packaging
function and its lemma. Confirm at implementation time by `git diff --stat` showing exactly the
declared paths and by checking each of the four contract names resolves at its
`## Lean Challenge Statements` signature.

**Files to modify**:

- `FormalSystem/Metalogic/Expressiveness/SeparationZ/Packaging.lean` - new: literal
  classification, clause packaging, truth-preservation lemma.
- `FormalSystem/Metalogic/Expressiveness/SeparationZ/Discharge.lean` - new: `sepZ`,
  `sepZ_sepClauses`, `plusTruthAt_sepZ_iff`, `separationOver_ztime`.
- `FormalSystem/Metalogic/Expressiveness/SeparationZ/README.md` - add both modules' rows.
- `typst/generated/status.typ` - regenerated counts.
- `FormalSystem.lean` - regenerated.

**Verification**:

- Scoped guarded build green for `...SeparationZ.Discharge`.
- All four contract declarations compile sorry-free; `lean_verify` on each fully qualified name
  reports no `sorry`.
- **Blocking check**: `sepZ` compiles without `noncomputable`.
- Each landed signature matches its `## Lean Challenge Statements` form; a divergence is a
  `[BLOCKED]` escalation, not a quiet substitution (see `rules/plan-compliance.md`).
- Each of the four docstrings carries a `Paper:` line.
- Zero `sorry`, zero vacuous definitions.

---

### Phase 25: The Computable Translation `trZ` [NOT STARTED]

**Goal**: A computable ZTime translation beside the frozen `noncomputable tr`, with its own truth-
preservation and validity-transfer theorems, both unconditional. This reinstates the deliverable
Phase 13 excluded, and this task list is the operative one.

**Tasks**:

- [ ] Add `Computable.lean` in namespace `FormalSystem.Metalogic.Expressiveness`. Define
      `trZ : OpenFormula → PlusFormula`, homomorphic on the seven shared constructors, and at
      `.ofut φ` / `.opast φ` returning `ofutElim (sepZ (trZ φ))` / `opastElim (sepZ (trZ φ))` --
      the computable `sepZ` in place of `tr`'s `Classical.choose`.
- [ ] Declare `trZ` as a plain `def`. **Do not** add `noncomputable`.
- [ ] Prove `openTruthAt_iff_trZ` by induction on `φ` generalizing the history and the time,
      mirroring the landed `openTruthAt_iff_tr` proof, with `plusTruthAt_sepZ_iff` where that
      proof uses `Classical.choose_spec` and the compiled `ofutP_sepForm_iff` /
      `opastP_sepForm_iff` at the two modal cases.
- [ ] Prove `openValidIn_ztime_iff_trZ` from it, unfolding
      `FrameClass.Sat .ZTime F = F.IsRegular ∧ F.IsZTime`, in the shape
      `openValidOnFrames_iff_tr` already establishes for the conditional route.
- [ ] Record in the module docstring that `tr` is untouched -- same name, still `noncomputable`,
      still taking `hsep` explicitly -- and that `trZ` is an addition, not a replacement.
- [ ] Note in the same docstring that `trZ` inhabits the translation slot of the already-generic
      `decidableOpenValidInOfTranslation`, `openDecider`, `openDecider_correct`,
      `openComplete_of_plusComplete_in` and `openValid_of_plusSound` with no change to any of the
      five, and that this closes the effectiveness gap those rows inherit at `.ZTime` only.
- [ ] Do **not** add a uniform `noncomputable` `Decidable (OpenValidIn FrameClass.ZTime φ)`: the
      host module's docstring records that shape as rejected and `lean4.md` classes it as vacuous.
- [ ] Give both theorems and `trZ` a `Paper:` line.
- [ ] README row, regenerated root, and the `typst-sync-check.sh --fix` step.

**Timing**: 1.5 hours

**Depends on**: 24

**Verification Tier**: local

**Tier Justification**: One additive module naming only existing declarations and Phase 24's new
ones, with no existing signature changed, so
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Expressiveness.SeparationZ.Computable`
covers it.

**Files to modify**:

- `FormalSystem/Metalogic/Expressiveness/SeparationZ/Computable.lean` - new: `trZ`,
  `openTruthAt_iff_trZ`, `openValidIn_ztime_iff_trZ`.
- `FormalSystem/Metalogic/Expressiveness/SeparationZ/README.md` - add this module's row.
- `typst/generated/status.typ` - regenerated counts.
- `FormalSystem.lean` - regenerated.

**Verification**:

- Scoped guarded build green for the new module.
- **Blocking check**: `trZ` compiles without `noncomputable`. If Lean demands it, a
  `Classical.choose` has leaked into `sep` or `sepZ` -- fix that, do not add the keyword.
- Both theorems' landed signatures match their `## Lean Challenge Statements` forms.
- `git diff` confirms `tr` and every other existing declaration in `OpenFutureElimination.lean`
  is byte-unchanged by this phase.
- Zero `sorry`, zero vacuous definitions.

---

### Phase 26: Documentation, Theorem-Index Restatement and Re-measured Axiom Baselines [NOT STARTED]

**Goal**: The three documentation items Phase 14 excluded land, now that
`separationOver_ztime` exists, and the seven contract declarations get measured C14 pins. Phase
14's items that already landed are not redone; this phase owns only what its
`#### Reasoned Exclusions` table left open, plus the corrections those closures force.

**Tasks**:

- [ ] Re-read each target file immediately before editing it (sibling concurrency).
- [ ] Amend `FormalSystem/Metalogic/Expressiveness/OpenFutureElimination.lean`'s module docstring:
      `## What is NOT proved here` must no longer assert the separation hypothesis is unformalized
      at `.ZTime`. State precisely what changed -- `separationOver_ztime` discharges it at
      `.ZTime` in this tree -- and that the `.RTime` hypothesis (GHR Theorem 10.3.20) remains
      undischarged. Change no declaration in the file.
- [ ] Restate the three `.ZTime` rows of `docs/theorem-index.md` whose Statement cell opens
      "Given separation over ℤ-time frames -- a hypothesis this tree does not formalize"
      (`openValidIn_ztime_iff_tr`, `exists_translation_ztime`, `decidableOpenValidZTimeOfTr`), so
      each records that the hypothesis is now discharged in-tree by `separationOver_ztime`.
- [ ] Correct the Expressiveness-band preamble and the `ℤ`-validities sub-band text Phase 14
      landed: both currently record that the separation hypothesis is discharged nowhere in this
      tree, which the discharge makes false.
- [ ] Add rows for the declarations of Phases 17-25, the seven contract declarations among them.
- [ ] Measure the axiom profile of each of the seven contract declarations with `#print axioms`
      (or `lean_verify`) against the built tree and paste the **measured** output. Never hand-type
      a profile.
- [ ] Append matched pairs to **both** heredocs in `scripts/check-module-invariants.sh` --
      `C14_BASELINE` and `C14LEAN` -- at the same trailing position, after the existing
      `SeparationZ` lines. Omit any declaration whose `#print axioms` reports no
      `depends on axioms` line at all: `C14_OUT` filters that line out, so such a baseline entry
      can never match. The 19 pairs Phase 14 landed stay; this phase appends, never rewrites them.
- [ ] Leave every `.RTime` row, and the preamble's `.Dense`/`.Base` sentences, unchanged: `U`/`S`
      is not separable over `ℚ` and GHR 10.3.20 is out of scope.
- [ ] Add the new modules to `FormalSystem/Metalogic/Expressiveness.lean`'s import list and
      refresh `FormalSystem/Metalogic/Expressiveness/README.md`'s `SeparationZ/` entry with its
      live file count and `Last verified` date.
- [ ] Re-derive the doc-sync pinned counts from the tree (`typst/generated/status.typ` and the
      ancestor-chain READMEs `README.md`, `FormalSystem/README.md`,
      `FormalSystem/Metalogic/README.md`) in this same run; never adjust one by hand to make a
      comparison pass.
- [ ] Regenerate `FormalSystem.lean` if any import changed, and check each new module's warning
      count against `scripts/warning-budget.txt`.

**Timing**: 2 hours

**Depends on**: 25

**Verification Tier**: interface

**Tier Justification**: The phase changes the subtree aggregator's import list and the generated
library root, so the one-hop dependent set is exactly those two modules plus the amended host
module -- covered by
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Expressiveness`
followed by `bash scripts/check-module-invariants.sh`, which is what actually checks C4, C8, C14,
C15 and C33 over the changed import graph and baselines.

**Scope Hypothesis**: Three restated `.ZTime` rows, one corrected band preamble and sub-band text,
new rows for the Phases 17-25 declarations, and matched C14 pairs for however many of the seven
contract declarations report a `depends on axioms` line. Confirm at implementation time from the
measured `#print axioms` output itself, not from this estimate.

**Files to modify**:

- `FormalSystem/Metalogic/Expressiveness/OpenFutureElimination.lean` - module docstring only; no
  declaration changes.
- `FormalSystem/Metalogic/Expressiveness.lean` - add the new modules to the import list.
- `FormalSystem/Metalogic/Expressiveness/README.md` - refresh `SeparationZ/` and `Last verified`.
- `FormalSystem/Metalogic/Expressiveness/SeparationZ/README.md` - final module table.
- `scripts/check-module-invariants.sh` - appended matched C14 pairs in both heredocs.
- `docs/theorem-index.md` - new rows, three restated `.ZTime` rows, corrected band preamble and
  sub-band text.
- `typst/generated/status.typ` - re-derived counts.
- `README.md`, `FormalSystem/README.md`, `FormalSystem/Metalogic/README.md` - re-derived counts.
- `FormalSystem.lean` - regenerated if any import changed.

**Verification**:

- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Expressiveness`
  green.
- `bash scripts/check-module-invariants.sh` exits 0, including C14, both C15 assertions, C33 and
  C28.
- `bash scripts/readme-lint.sh FormalSystem` exits 0.
- Every pasted axiom profile is byte-identical to the measured `#print axioms` output captured in
  the same run.
- `grep -n 'RTime' docs/theorem-index.md` confirms no `.RTime` row's conditionality was weakened.
- No docstring, README cell or index cell reads as if separation holds at `.Dense` or `.Base`, or
  as if it is still undischarged at `.ZTime`.

---

### Phase 27: Full Gate Sweep and Commit [NOT STARTED]

**Goal**: The complete gate set green against its pre-task baselines, with zero `sorry`, zero
vacuous definitions and no new axiom beyond what the landed eliminations already carry. This
reinstates Phase 15 over the enlarged tree.

**Tasks**:

- [ ] Guarded **scoped** build of the subtree aggregator:
      `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Expressiveness`.
- [ ] Guarded **unscoped** build: `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build`.
      Detach as a shell-level background job and block on it with the bounded single-call idiom
      (`context/patterns/bounded-build-waiter.md`); never `Bash(run_in_background: true)`.
- [ ] `bash scripts/check-module-invariants.sh` -- green against its pre-task baseline, including
      C14, both C15 assertions, C19, C23, C24, C26, C28, C29, C30, C31, C32 and C33. C16's
      `unusedArguments` finding on
      `FormalSystem/Metalogic/Decidability/RaySummary/LadderChain.lean:2136` is **pre-existing**
      and outside this task's file set: report it, never baseline it, and do not run
      `lake exe runLinter --update`.
- [ ] `bash scripts/check-metalogic-cycles.sh` -- green, all three assertions PASS. No new module
      may import a `FormalSystem.Metalogic.<other>` subdirectory.
- [ ] `bash .claude/scripts/verify-deploy.sh` -- deferred at Phase 15 under that dispatch's Batch
      Gate Deferral directive and **not forgiven**. Run it here, or re-defer it with the same
      narrowing record and the same measured justification, never silently.
- [ ] Zero-debt sweep: `grep -rn 'sorry'` over every changed `.lean` file returns nothing, and no
      added declaration matches a prohibited vacuous shape (`:= True`, `:= trivial`, `:= Unit`,
      `:= Trivial`).
- [ ] Confirm no added declaration carries `noncomputable`, in particular `sep`, `sepZ` and `trZ`.
- [ ] Re-measure every axiom profile and confirm no new axiom beyond
      `[propext, Classical.choice, Quot.sound]`, the ceiling the landed eliminations already
      carry. A profile exceeding it is a finding to report, not to baseline.
- [ ] Commit with explicit per-file staging (`git add -- <path> ...`), never a directory or glob,
      reviewing `git status --short` and `git diff --staged` first. If a foreign commit or foreign
      uncommitted modification is visible, STOP and report after checking `git log`.

**Timing**: 1 hour

**Depends on**: 26

**Verification Tier**: full

**Files to modify**:

- None. This phase runs gates and commits; any edit it provokes belongs to the phase that owns the
  file.

**Verification**:

- The complete gate set: `bash .claude/scripts/verify-deploy.sh` green (or re-deferred with its
  record), plus `bash scripts/check-module-invariants.sh` and
  `bash scripts/check-metalogic-cycles.sh` green against their pre-task baselines, plus the
  guarded unscoped `lake build` green.
- Zero `sorry` and zero vacuous definitions across every changed file.
- No added declaration is `noncomputable`.
- Every axiom profile measured in this same run, none exceeding the pre-task ceiling.
- `git log` confirms exactly this task's commits and that no foreign work was staged.


## Testing & Validation

- [ ] All seven contract declarations compile sorry-free at exactly the signatures pinned in
      `## Lean Challenge Statements`.
- [ ] `sep`, `sepZ` and `trZ` compile as plain `def`s with no `noncomputable` keyword.
- [ ] Every measure introduced (`snceDepthAbove`, `uTypeCount`, `untlDepth`, `junctionDepth`) is a
      total structural recursion, and each strict-decrease claim is a named, proved theorem rather
      than an asserted one.
- [ ] Case 5 of GHR 10.2.3 matches the candidate Phase 16 pinned, and `ElimHard.lean`'s module
      docstring records that the printed Case 5 is refuted over `ℤ` and names the refuting model.
- [ ] No declaration in `OpenFutureElimination.lean` is modified; only its module docstring
      changes.
- [ ] No module under `SeparationZ/` imports any `FormalSystem.Metalogic.<other-subdirectory>`
      module.
- [ ] Nothing under `FormalSystem/Metalogic/Independence/` is touched, and the metalogic-cycles
      allowlist is unchanged.
- [ ] Every `.RTime` row and every `.Dense`/`.Base` statement stays conditional or negative; the
      only conditionality removed anywhere is at `.ZTime`.
- [ ] `check-module-invariants.sh` and `check-metalogic-cycles.sh` green against their pre-task
      baselines; every axiom profile measured, never hand-typed.
- [ ] `readme-lint.sh`, `check-copyright-headers.sh` and the warning-budget check green for the
      new subtree.
- [ ] All eight `usTruth_case1` through `usTruth_case8` resolve, and the four hard cases are
      reached by the reduction DAG decision D-e pins -- not by direct semantic re-anchoring and not
      from 10.2.4 or Theorem 10.2.9. The anti-circularity grep returns nothing over `ElimHard`.
- [ ] `case8Rhs` keeps all three disjuncts, with Phase 16's redundancy-refuting model cited at the
      definition.
- [ ] GHR 10.2.4's hypothesis is Phase 20's weaker predicate, not `IsSeparated`, and no downstream
      input position re-imposes the stronger bar.
- [ ] `docs/theorem-index.md` no longer states anywhere that the separation hypothesis is
      undischarged at `.ZTime`, and `OpenFutureElimination.lean`'s `## What is NOT proved here`
      says the same, while every `.RTime` row stays conditional.
- [ ] The 19 C14 pairs Phase 14 landed are intact and the new pairs are appended after them in
      both heredocs.

## Artifacts & Outputs

- A new subtree `FormalSystem/Metalogic/Expressiveness/SeparationZ/` with thirteen modules as
  planned (`Syntax`, `LeafAbstraction`, `Distributivity`, `NegationEquiv`, `Eliminations`,
  `ElimHard`, `NormalForm`, `Hierarchy`, `UNesting`, `JunctionDepth`, `Packaging`, `Discharge`,
  `Computable`), to be confirmed against the landed tree, plus its `README.md`.
- Seven contract declarations in namespace `FormalSystem.Metalogic.Expressiveness`: `sepZ`,
  `sepZ_sepClauses`, `plusTruthAt_sepZ_iff`, `separationOver_ztime`, `trZ`,
  `openTruthAt_iff_trZ`, `openValidIn_ztime_iff_trZ`.
- `specs/867_formalize_gabbay_separation_ztime/prototype/cases-5-8-probe.lean`, carrying the
  pinned Case 5 candidate and its recorded probe results, and
  `prototype/cases-5-8-reduction.lean`, carrying the reduction DAG, the two-disjunct Case 5
  candidate and the Case 8 redundancy-refuting model.
- Matched C14 baseline pairs in `scripts/check-module-invariants.sh`.
- Amended `docs/theorem-index.md` (new rows, restated `.ZTime` rows, amended band preamble),
  `FormalSystem/Metalogic/Expressiveness/OpenFutureElimination.lean` docstring,
  `FormalSystem/Metalogic/Expressiveness.lean`,
  `FormalSystem/Metalogic/Expressiveness/README.md`, and
  `Boneyard/Kamp/KampWeakCanonical/Separation/README.md`.
- A regenerated `FormalSystem.lean`.

## Rollback/Contingency

The development is strictly additive: no existing declaration, signature or import is modified,
so removing the `SeparationZ/` subtree, the matched C14 pairs, the new theorem-index rows and the
docstring amendments restores the pre-task state exactly. Each phase's edits are confined to files
no earlier phase owns except the shared `SeparationZ/README.md` and the generated
`FormalSystem.lean`, both of which are regenerated or re-edited rather than merged, so a phase can
be reverted by `git revert` of its own commit followed by `lake exe mk_all --lib FormalSystem`.

If a rollback must discard uncommitted work, take a snapshot first per
`context/contracts/recovery.md`'s rollback rung, with the task number explicit. Under this cycle's
sibling concurrency, never use `git-snapshot.sh` in its reverting default mode; an ordinary
defensive checkpoint before risky work is
`bash .claude/scripts/git-snapshot.sh 867 --no-revert`.

Contingency branches:

- **Phase 5's gate branch was taken at dispatch 7** and closed Phases 7-15 with exclusion
  records. It is superseded for Cases 6-8 by Phase 16's re-specified gate, for the reason decision
  D-e records: the method Phase 5 measured is not the source's. The branch text below is kept as
  the record of what was taken, not as a live instruction.
- **Phase 16's gate criterion (b) fails** -- a reduction edge cannot be named at a source step, so
  the DAG is a reconstruction rather than a transcription. Do not fall back to the direct semantic
  re-anchoring D-e forbids. Record which edge resists, the source text consulted, and what a
  correct derivation of that edge would need; close Phase 16 as `[COMPLETED WITH EXCLUSIONS]` with
  that evidence and do not attempt Phases 17-27 as written. A partial DAG still licenses the cases
  downstream of the edges that *were* named: if Case 8's edge holds and Case 7's does not, land
  Cases 5 and 8 and locate the obstruction at Case 7.
- **Phase 23's junction-depth strict decrease resists proof.** Now the primary stall candidate: it
  was never reached under the earlier route, so no measurement of it exists yet. Locate the
  obstruction precisely -- which abstraction step fails to reduce the measure, the goal state
  reached, and what would unblock it -- close Phase 23 and its dependents as
  `[COMPLETED WITH EXCLUSIONS]` with that evidence, and land Phases 16-22. A `sorry` is not an
  option.
- **Phase 5's gate fails for one or more of Cases 5-8** (fewer than four candidates survive
  probing). This was the plan's primary contingency and is the branch taken at dispatch 7. Do not
  proceed to Phase 7 as written for the failing case. Instead: record the failing case, the candidate forms tried, and the model that
  refutes each, as the precisely-located obstruction the dispatch's own gates accept; close
  Phase 7 as `[COMPLETED WITH EXCLUSIONS]` with a `#### Reasoned Exclusions` record whose
  `Evidence` column cites Phase 5's own measurement; and close Phases 8 through 13 the same way,
  each citing that measurement, since GHR's 10.2.4 consumes all eight cases and nothing downstream
  of it can be reached. Phases 1-6 and 14-15 still land: the distributivities, the negation
  equivalences and Cases 1-4 are independently useful `ℤ` validities and should be committed,
  pinned and documented as such, with the theorem-index rows left in their conditional form and
  the `OpenFutureElimination.lean` docstring unchanged. Do **not** leave the bypassed phases
  `[NOT STARTED]` and do **not** use `[PARTIAL]`: they were decided against, not interrupted.
- **Phase 11's junction-depth strict decrease resists proof.** The secondary stall candidate.
  Same treatment: locate the obstruction precisely -- which abstraction step fails to reduce the
  measure, the goal state reached, and what would unblock it -- close Phase 11 and the phases
  depending on it as `[COMPLETED WITH EXCLUSIONS]` with that evidence, and land Phases 1-10. A
  `sorry` is not an option: the dispatch's gates require zero.
- **`sep`, `sepZ` or `trZ` will not compile without `noncomputable`.** The construction has leaked
  a `Classical.choose`, most likely in the Phase 11 recursion. Mark the owning phase `[BLOCKED]`,
  locate the leak, and fix the construction. Adding the keyword is not the fix: it silently
  defeats the executability deliverable while leaving every signature looking correct.
- **`check-metalogic-cycles.sh` regresses.** A new module imported a
  `FormalSystem.Metalogic.<other-subdirectory>` module against this plan's explicit constraint.
  Remove the import; nothing in the development needs one, which is why the constraint was stated.
- **C14 reports a divergence that re-measurement does not resolve.** The matched pairs are at
  mismatched positions, or landed in only one of the two heredocs. Re-check both insertion points
  before touching any measured value, and never edit a measured profile to make the comparison
  pass.
