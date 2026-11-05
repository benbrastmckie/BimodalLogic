# Implementation Plan: Gabbay Separation over ZTime for L⁺

- **Task**: 867 - Formalize Gabbay separation over discrete time for `PlusFormula`, discharging `SeparationOver TaskFrame.IsZTime` and making the open-future translation executable
- **Status**: [IMPLEMENTING]
- **Effort**: 27 hours
- **Dependencies**: None blocking. Consumes only already-compiled declarations.
- **Research Inputs**: specs/867_formalize_gabbay_separation_ztime/reports/01_gabbay-separation-ztime-plusformula.md
- **Artifacts**: plans/01_gabbay-separation-ztime-plusformula.md (this file)
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

### Phase 4: GHR Lemma 10.2.2 -- The Negation Equivalences over `ℤ` [NOT STARTED]

**Goal**: The four negation equivalences hold over integer time, with the least-witness arguments
discharged by `Int.exists_least_of_bdd`.

**Tasks**:

- [ ] Add `NegationEquiv.lean`. State and prove, flipped into guard-first order, GHR's
      `¬U(A,B) ↔ G(¬A) ∨ U(¬A ∧ ¬B, ¬A)`, its `snce`/`allPast` mirror, and the two variants
      carrying `B ∧ ¬A` in the guard slot.
- [ ] Use `Int.exists_least_of_bdd` (`.lake/packages/mathlib/Mathlib/Data/Int/LeastGreatest.lean:69`,
      re-derived at plan time) for the "least `u > t` with `A u`" step, and `omega` for the
      adjacent-point arithmetic, including the empty open interval `(t, t+1) ∩ ℤ = ∅` that makes a
      guard vacuous on adjacent points.
- [ ] Record, in the module docstring, that the vacuous-guard degeneracy on `ℤ` makes
      `snce`/`untl` *easier* to satisfy at adjacent points, not harder -- the archived Boneyard
      note states this backwards and the mistake is cheap to re-inherit.
- [ ] Derive each past-side equivalence by duality from its future-side counterpart.
- [ ] Append the module's row to `SeparationZ/README.md` and regenerate `FormalSystem.lean`.

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

### Phase 5: DECISION GATE -- Probe the Reconstructed Cases 5-8 [NOT STARTED]

**Goal**: A candidate separated right-hand side exists for each of GHR 10.2.3's Cases 5-8,
derived from the semantics rather than transcribed, and each has survived evaluation on concrete
`ℤ` leaf valuations including the adjacency degeneracies. The gate's criterion: **all four
candidates survive**. Its measurement licenses Phase 7.

**Tasks**:

- [ ] Write a prototype file under `specs/867_formalize_gabbay_separation_ztime/prototype/` that
      defines concrete leaf valuations on `ℤ` as decidable predicates and evaluates both sides of
      a candidate equivalence at a chosen `t`, so a candidate can be refuted by `decide` or by
      `native_decide`-free explicit computation rather than by hand.
- [ ] Re-derive each of Cases 5-8 from the semantics by the case split GHR indicates: the position
      of the `A`-witness relative to `t`, and the position of the first `¬B` after `s`. Do not
      transcribe the printed formulas.
- [ ] Start Case 5 from the gloss-consistent reconstruction the research report records --
      `S(A ∧ S(a,B), A ∨ B ∨ ¬S(¬q,¬A)) ∧ ¬S(¬q,¬A)` as the second disjunct, with the
      `[A ∨ (B ∧ U(A,B))]` conjunct belonging to the first disjunct only -- which already survives
      the report's verified counterexample.
- [ ] Re-run the report's refuting model against each candidate as a regression: `a(0)`, `A(1)`,
      `B` identically false, `q(1)` and `q(2)` true, everything else false, evaluated at `t = 3`.
      The printed Case 5 is false there; a surviving candidate must be true.
- [ ] Probe each candidate additionally on at least one model exercising the adjacent-point
      degeneracy (a witness at `t+1` or `t-1`, where the open interval is empty and the guard is
      vacuous) and one where the `A`-witness lies strictly in the past.
- [ ] Record, in the prototype file's own comments, each candidate's exact statement and the
      models it survived, so Phase 7 implements a pinned candidate rather than re-deriving one.
- [ ] **Gate measurement**: state explicitly, for each of the four cases, whether a candidate
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

### Phase 6: GHR Lemma 10.2.3 -- Eliminations, Cases 1-4 [NOT STARTED]

**Goal**: The first four eliminations pull `untl` out from under `snce` and are proved at every
`v` and `t` over `ℤ`, with arbitrary `USForm` parameters.

**Tasks**:

- [ ] Add `Eliminations.lean`. State each of Cases 1-4 with **arbitrary `USForm` parameters**
      `a`, `q`, `A`, `B`, not atoms: GHR's atomicity hypothesis exists only to license their
      substitution step and is unused in their semantic arguments.
- [ ] Prove Case 1 (`S(a ∧ U(A,B), q)`), Case 2 (`S(a ∧ ¬U(A,B), q)`), Case 3
      (`S(a, q ∨ U(A,B))`) and Case 4 (`S(a, q ∨ ¬U(A,B))`), flipping every GHR `U(A,B)` to
      `untl B A`.
- [ ] Reduce Case 3 to Case 2 and Case 4 as GHR's own internal reductions indicate, rather than
      proving it from scratch, and record which reduction each case uses in its docstring.
- [ ] Verify, for each case, that the right-hand side is syntactically separated -- every `untl`
      occurrence sits under no `snce` and vice versa -- by discharging `IsUOnly`/`IsSOnly` side
      conditions rather than asserting it in prose.
- [ ] Append the module's row to `SeparationZ/README.md` and regenerate `FormalSystem.lean`.

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

### Phase 7: GHR Lemma 10.2.3 -- Eliminations, Cases 5-8 [NOT STARTED]

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
- [ ] Append the module's row to `SeparationZ/README.md` and regenerate `FormalSystem.lean`.

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

---

### Phase 8: Normal Forms and GHR Lemma 10.2.4 [NOT STARTED]

**Goal**: A disjunctive and a conjunctive normal form exist for the Boolean skeleton of a
`USForm`, with truth preservation, and GHR 10.2.4 -- depth-one packaging for a single `U`-type --
is proved from them plus all eight eliminations.

**Tasks**:

- [ ] Add `NormalForm.lean` with `dnf` and `cnf` on the Boolean skeleton of a `USForm` (treating
      every `untl`/`snce` subformula and every `leaf` as an opaque literal), each with a truth-
      preservation lemma at every `v` and `t`.
- [ ] Add `IsSyntacticallySeparated` inductively: `leaf` and `bot` are separated; `imp` of
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

---

### Phase 9: GHR Lemmas 10.2.5 and 10.2.6 [NOT STARTED]

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

---

### Phase 10: GHR Lemma 10.2.7 [NOT STARTED]

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

---

### Phase 11: Junction Depth, GHR Lemma 10.2.8 and Theorem 10.2.9 [NOT STARTED]

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

---

### Phase 12: CNF Packaging and the Discharge of `SeparationOver` [NOT STARTED]

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

---

### Phase 13: The Computable Translation `trZ` [NOT STARTED]

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

---

### Phase 14: Documentation, Theorem-Index Rows and Measured Axiom Baselines [NOT STARTED]

**Goal**: Every documentation surface that says the separation hypothesis is unformalized in this
tree is corrected for `.ZTime` and left untouched for `.RTime`, the new declarations carry
measured C14 pins, and the subtree is aggregated.

**Tasks**:

- [ ] Re-read each target file immediately before editing it (sibling concurrency).
- [ ] Amend `FormalSystem/Metalogic/Expressiveness/OpenFutureElimination.lean`'s module docstring:
      `## What is NOT proved here` must no longer assert the separation hypothesis is unformalized
      at `.ZTime`. State precisely what changed -- `separationOver_ztime` discharges it at `.ZTime`
      in this tree -- and that the `.RTime` hypothesis (GHR Theorem 10.3.20) remains undischarged.
      Change no declaration in the file.
- [ ] Add the new modules to `FormalSystem/Metalogic/Expressiveness.lean`'s import list, so the
      headline results are reachable from the subtree aggregator and not only from the generated
      root.
- [ ] Amend `FormalSystem/Metalogic/Expressiveness/README.md` to list the `SeparationZ/`
      subdirectory with its live file count and a one-line description, and refresh its
      `Last verified` date. Do not attempt to repair the unrelated stale table in
      `Separation/README.md`.
- [ ] Measure the axiom profile of each of the seven contract declarations with `#print axioms`
      (or `lean_verify`) against the built tree, and paste the **measured** output. Never hand-type
      a profile.
- [ ] Append matched pairs to **both** heredocs in `scripts/check-module-invariants.sh` --
      `C14_BASELINE` and `C14LEAN` -- at the same trailing position, directly after the existing
      `Expressiveness` lines. Omit any declaration whose `#print axioms` reports no
      `depends on axioms` line at all: `C14_OUT` filters that line out, so a baseline entry for
      such a declaration can never match and a `#print axioms` line for it in `C14LEAN` is a
      silent no-op.
- [ ] Update `docs/theorem-index.md`: restate the `.ZTime` rows whose Statement cell currently
      opens "Given separation over ℤ-time frames — a hypothesis this tree does not formalize"
      (`openValidIn_ztime_iff_tr`, `exists_translation_ztime`, `decidableOpenValidZTimeOfTr`) so
      the parenthetical records that the hypothesis is now discharged in-tree by
      `separationOver_ztime`; add rows for the seven new declarations; and amend the
      Expressiveness-band preamble, which currently states that the separation theorems are
      "not formalized in this tree and discharged nowhere in it".
- [ ] Leave every `.RTime` row, and the preamble's `.Dense`/`.Base` sentences, unchanged: `U`/`S`
      is not separable over `ℚ` and GHR 10.3.20 is out of scope.
- [ ] Add the one-line caveat the research report recommends to
      `Boneyard/Kamp/KampWeakCanonical/Separation/README.md`: the archive's
      `replace_box_with_top` normalization is sound for `Formula` over `IntStructure` and
      **unsound** for `PlusFormula` over a task frame, so it must not be transplanted.
- [ ] Bring the **doc-sync pinned counts** into agreement with the tree: thirteen new modules
      change the file and line counts that `typst/generated/status.typ` and the ancestor-chain
      READMEs (`README.md`, `FormalSystem/README.md`, `FormalSystem/Metalogic/README.md`) carry,
      and C14 asserts documented counts match in `docs/`, `README.md` **and**
      `FormalSystem/**/*.lean` docstrings. Re-derive every count from the tree in this same run;
      never adjust one by hand to make a comparison pass.
- [ ] Regenerate `FormalSystem.lean` if any import changed, and check each new module's warning
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

---

### Phase 15: Full Gate Sweep and Commit [NOT STARTED]

**Goal**: The complete gate set is green against its pre-task baselines, with zero `sorry`, zero
vacuous definitions and no new axiom beyond what the landed eliminations already carry.

**Tasks**:

- [ ] Guarded **scoped** build of the subtree aggregator:
      `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Expressiveness`.
- [ ] Guarded **unscoped** build: `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build`.
      Detach as a shell-level background job and block on it with the bounded single-call idiom
      (`context/patterns/bounded-build-waiter.md`); never `Bash(run_in_background: true)`.
- [ ] `bash scripts/check-module-invariants.sh` -- green against its pre-task baseline, including
      C14, both C15 assertions, C19, C23, C24, C26, C28, C29, C30, C31, C32 and C33.
- [ ] `bash scripts/check-metalogic-cycles.sh` -- green, all three assertions PASS. It was green
      before this task and no new module imports a `FormalSystem.Metalogic.<other>` subdirectory,
      so no perturbation of assertion A or B is expected; a failure means that constraint was
      broken and the offending import must be removed.
- [ ] `bash .claude/scripts/verify-deploy.sh` -- the complete gate set this repository aggregates.
- [ ] Zero-debt sweep: `grep -rn 'sorry' ` over every changed `.lean` file returns nothing, and no
      added declaration matches a prohibited vacuous shape (`:= True`, `:= trivial`, `:= Unit`,
      `:= Trivial`).
- [ ] Confirm no added declaration carries `noncomputable`, in particular `sep`, `sepZ` and `trZ`.
- [ ] Re-measure every axiom profile and confirm no new axiom beyond `[propext, Classical.choice,
      Quot.sound]`, the ceiling the landed eliminations already carry. A profile exceeding it is a
      finding to report, not to baseline.
- [ ] Commit with explicit per-file staging (`git add -- <path> ...`), never a directory or glob,
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

## Testing & Validation

- [ ] All seven contract declarations compile sorry-free at exactly the signatures pinned in
      `## Lean Challenge Statements`.
- [ ] `sep`, `sepZ` and `trZ` compile as plain `def`s with no `noncomputable` keyword.
- [ ] Every measure introduced (`snceDepthAbove`, `uTypeCount`, `untlDepth`, `junctionDepth`) is a
      total structural recursion, and each strict-decrease claim is a named, proved theorem rather
      than an asserted one.
- [ ] Cases 5-8 of GHR 10.2.3 match the candidates Phase 5 probed, and their module docstring
      records that the printed Case 5 is refuted over `ℤ`.
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

## Artifacts & Outputs

- A new subtree `FormalSystem/Metalogic/Expressiveness/SeparationZ/` with thirteen modules as
  planned (`Syntax`, `LeafAbstraction`, `Distributivity`, `NegationEquiv`, `Eliminations`,
  `ElimHard`, `NormalForm`, `Hierarchy`, `UNesting`, `JunctionDepth`, `Packaging`, `Discharge`,
  `Computable`), to be confirmed against the landed tree, plus its `README.md`.
- Seven contract declarations in namespace `FormalSystem.Metalogic.Expressiveness`: `sepZ`,
  `sepZ_sepClauses`, `plusTruthAt_sepZ_iff`, `separationOver_ztime`, `trZ`,
  `openTruthAt_iff_trZ`, `openValidIn_ztime_iff_trZ`.
- `specs/867_formalize_gabbay_separation_ztime/prototype/cases-5-8-probe.lean`, carrying the
  pinned Case 5-8 candidates and their recorded probe results.
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

- **Phase 5's gate fails for one or more of Cases 5-8** (fewer than four candidates survive
  probing). This is the plan's primary contingency. Do not proceed to Phase 7 as written for the
  failing case. Instead: record the failing case, the candidate forms tried, and the model that
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
