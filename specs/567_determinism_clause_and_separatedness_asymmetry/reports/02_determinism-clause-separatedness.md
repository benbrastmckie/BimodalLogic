# Research Report: Task #567

**Task**: 567 - Determinism clause and separatedness asymmetry
**Started**: 2026-10-03T22:30:00Z
**Completed**: 2026-10-04T00:40:00Z
**Effort**: 2 hours (research); implementation estimated at 3-4 hours across 3 phases
**Dependencies**: 563 (landed: the `Semantics/Presheaf/` cluster exists)
**Sources/Inputs**:
- `specs/archive/553_decide_convex_history_layer_collapse/reports/01_convex-correlate-and-consequence.md` §5.2.1, §7.3-E, §7.4 item 6
- `specs/567_determinism_clause_and_separatedness_asymmetry/reports/01_retiming-invariance-definability-findings.md` (the prior advisory note)
- `FormalSystem/Semantics/Presheaf/{Site,Behavior,Sheaf,Ray}.lean`
- `FormalSystem/Semantics/{FrameProperty,PartialHistory,DeterministicBridge}.lean`, `Semantics/Extension/Extension.lean`
- `FormalSystem/PlusLanguage/PlusDeterminism.lean`, `FormalSystem/StarLanguage/StarDeterminism.lean`
- `FormalSystem/Metalogic/Independence/{DriftFrame,DriftHistories,DeterminismUndefinable,StarDiscrimination}.lean`
- Two compiled probes written for this round (below)
**Artifacts**:
- this report
- `specs/567_determinism_clause_and_separatedness_asymmetry/probes/01_determinism-clause.lean` (compiles, exit 0, no `sorry`)
- `specs/567_determinism_clause_and_separatedness_asymmetry/probes/02_cover-separated.lean` (compiles, exit 0, no `sorry`)
**Standards**: report-format.md, status-markers.md, artifact-formats.md, long-builds.md

## Executive Summary

- **The whole deliverable is already proved.** Probe 01 compiles the full theorem pair against the
  live tree: the dictionary clause as a biconditional (`separated_iff_deterministic`, under
  `[F.IsRegular]`), the choice-free forward half, the world-to-section bridge, and the asymmetry
  `separated_strictly_stronger` at the drift frame `F°`. Implementation is a siting-and-docstring
  task, not a proof-search task. No `sorry` anywhere, so the zero-debt gate is not at risk.
- **The countermodel is the repository's own, as the description requires.** `¬ Separated F0` is
  witnessed by `driftLinear 1` and `driftLinear 2` (`Independence/StarDiscrimination.lean`) cut
  down to sections over `[0, 1]`: same germ at `0`, states `1` and `2` at time `1`.
- **"Separatedness" must be read as injectivity of every restriction map, and the report settles
  why.** The *cover-relative* (sheaf-theoretic) separatedness of `Beh F` for the Johnstone
  coverage is **unconditionally true at no frame hypothesis and choice-free** — probe 02 compiles
  it. Under that reading the §5.2.1 claim would be false; under the injectivity reading it is
  exactly right. This closes the open risk flagged in report 01's Recommendation 1.
- **The declared single-file scope cannot hold the theorem pair, and the obstruction is
  mechanical.** `Semantics/DeterministicBridge.lean` transitively imports
  `FormalSystem.ProofSystem.Axioms` (via `PlusValidity → Validity → ValidityLayer →
  FrameClassValidity`), so a module in the `Presheaf/` cluster that imports it cannot carry the
  cluster's `assert_not_exists` lock — verified by a compile that fails with precisely that
  import chain. The pair must be split across two modules, mirroring the existing
  `PlusDeterminism` / `DeterministicBridge` split.
- **Choice-dependence tracks a direction, and the measurements confirm it.** `#print axioms`:
  forward half `[propext, Quot.sound]`; the section-level singleton bridge `[propext]`; the
  biconditional and the `F°` witness `[propext, Classical.choice, Quot.sound]`.
- **The posed open question is answered for `BL⋆`, not open.** Given the clause as a
  biconditional, `deterministic_starDefinable` makes `detPM` a `BL⋆` characterization of
  separatedness on regular frames, and `deterministic_not_plusDefinable` rules one out for `L⁺`.
  The honest residue is narrower and should replace the question: whether a `BL⋆` formula
  characterizes separatedness *choice-freely*.

## Context & Scope

Researched: whether `app:presheaf-dictionary`'s *Determinism* clause (`F` deterministic iff every
restriction map of `Beh(F)` is injective) is provable against the landed `Semantics/Presheaf/`
cluster; how it connects to `states_eq_of_deterministic`; what the §5.2.1 asymmetry amounts to in
Lean; where the results can be sited without breaking the cluster's layering lock; and what the
module docstring should say about the posed open question.

Not researched (deliberately, per the dispatch): whether any `BL⋆` formula characterizes
separatedness choice-freely. §5.2.1's own suggestion that it does not is recorded, not attacked.

Evidence tier: every claim below marked **compiled** was elaborated by `lake env lean` through the
build guard (`lake-build-guard.sh build --timeout 1800 -- env lean <probe>`), exit status 0. The
lean-lsp MCP server was reachable but not used for the load-bearing claims; compiled probes are the
stronger tier and were used throughout.

## Findings

### Codebase Patterns

#### 1. The clause, as a biconditional (compiled)

Probe 01 defines separatedness as injectivity of the raw-data action, which the site-indexed
action `Beh.restrictTr` is definitionally an instance of:

```
def Separated (F : TaskFrame) : Prop :=
  ∀ (l p l' : F.Duration) (hp : 0 ≤ p) (hl' : 0 ≤ l') (hple : p + l' ≤ l),
    Function.Injective (Beh.restrict (l := l) p l' hp hl' hple)
```

Four results, all compiled:

| Result | Statement | Axioms |
|---|---|---|
| `states_eq_of_deterministic_sec` | sections agreeing at one time of `[0, l]` agree at every time | `[propext]` |
| `separated_of_deterministic` | `F.Deterministic → Separated F` | `[propext, Quot.sound]` |
| `singletonClasses_of_separated` | `Separated F → F.SingletonClasses` | `[propext, Quot.sound]` |
| `separated_iff_deterministic` | `Separated F ↔ F.Deterministic`, `[F.IsRegular]` | `[propext, Classical.choice, Quot.sound]` |

- The forward half needs **nothing but determinism** — no frame bundle, no Compositionality. It is
  three lines: `respects_task p r` on each section, the hypothesis identifies the sources, and
  determinism at the (possibly negative) duration `r - p` identifies the targets. Only the germ at
  the offset `p` is consumed, so injectivity of *every* restriction reduces to injectivity of the
  germ maps.
- The converse needs `[F.IsRegular]` and is a theorem of **ZFC**. It does **not** re-derive the
  Zorn step: `singletonClasses_of_separated` is choice-free, and `deterministic_of_singletonClasses`
  (`Semantics/DeterministicBridge.lean`) supplies the `thm:extension` half that already exists.
  This is the connection the dispatch asks for, in its strongest available form — the clause is
  the presheaf-side reading of `lem:deterministic-singleton`, not a parallel result.

#### 2. The connection to `states_eq_of_deterministic` (and why it is not an import)

`PlusLanguage.states_eq_of_deterministic` is stated for **total** histories. Sections are partial,
so the `Beh`-level statement is not an instance of it; it is the same three-step proof at
`PartialHistory.respects_task`. The two meet through the world-to-section bridge, compiled in
probe 01 as

```
noncomputable def secOf (σ : WorldHistory F) (m l : F.Duration) (hl : 0 ≤ l) : Beh F l :=
  (futOf (σ.timeShift m) 0).toBeh l hl
```

whose reading equation `secOf_states : (secOf σ m l hl).val.states z hz = σ.state (z + m)` is
`rfl`. `singletonClasses_of_separated` is exactly this bridge plus one injectivity instance (germ
at the left endpoint when `x ≤ y`, germ at the right endpoint otherwise). Both the `FutRay.toBeh`
cut and `WorldHistory.timeShift` already exist; nothing new is needed at the history layer.

#### 3. The asymmetry, with the repository's own countermodel (compiled)

`¬ Separated F0` is witnessed with no new construction:

```
noncomputable def driftSec (a : ℝ) (h1 : 1 ≤ a) (h2 : a ≤ 2) : Beh F0 1 :=
  secOf (driftLinear a h1 h2) 0 1 zero_le_one
```

`driftSec 1` and `driftSec 2` have the same germ at `0` (both states `0`, closed by `ring`) and
states `1` and `2` at time `1`, so the germ restriction `Beh F0 1 → Beh F0 0` is not injective.
Composed with `fzero_determined` (`Independence/DeterminismUndefinable.lean`), probe 01 compiles
the pair:

```
theorem separated_strictly_stronger :
    (∀ φ : PlusLanguage.PlusFormula, F0.PlusValidOn (.imp φ (.stab φ))) ∧ ¬ Separated F0
```

- This is the **theorem pair** the dispatch demands: one direction proved
  (`separated_of_deterministic`, choice-free), the converse of *Determined-validity ⇒
  separatedness* refuted by `F°`.
- The pair is **not** the converse of the clause. The clause's own converse is *true* (item 1);
  what fails is the converse of the composite "validity of *Determined* ⇒ `Beh` separated". The
  module docstring must keep the two apart, or a reader will take `fzero_not_separated` for a
  counterexample to `separated_iff_deterministic`.
- `#print axioms` on the witness reports `[propext, Classical.choice, Quot.sound]`. That
  `Classical.choice` is the ambient real-analytic apparatus (`F0`'s own `fzero_not_deterministic`,
  `driftLinear` and `fzero_determined` each already measure it), **not** a `thm:extension` step —
  the same distinction `StarDeterminism.lean` and `DriftHistories.lean` draw in prose. The
  measurable fact is the axiom list; the provenance claim is prose-level and should be written as
  such ("no appeal to `thm:extension`, hence no Zorn"), exactly as those two modules word it.

#### 4. Which "separatedness" — and the trap in the word (compiled)

Two inequivalent readings are in play, and only one makes §5.2.1 true:

- **Injectivity of every restriction map** (the monopresheaf property). Equivalent to
  `F.Deterministic` on regular frames, by item 1. This is the reading the dictionary clause and
  the study intend.
- **Cover-relative separatedness** for the Johnstone coverage: two sections over `l` agreeing on
  `[0, p]` and on `[p, l]` are equal. Probe 02 compiles this **at no frame hypothesis**, axioms
  `[propext, Quot.sound]`:

```
theorem cover_separated {l p : F.Duration} (hp : 0 ≤ p) (hpl : p ≤ l) (σ τ : Beh F l)
    (h1 : ...left restriction equal...) (h2 : ...right restriction equal...) : σ = τ
```

  Every point of `[0, l]` lies in one half or the other, so the two restrictions already determine
  the section pointwise. (`glue_unique` is the same fact for a *glued* section; `cover_separated`
  is it for an arbitrary pair.)

So under the cover-relative reading "`Beh(F)` is separated" is a theorem about **every** task
frame and cannot be strictly stronger than anything. Report 01's Recommendation 1 — check which
sense is meant before planning — is hereby discharged: the injectivity sense, and the module
should say so in one sentence to stop the word doing damage.

#### 5. Siting: the declared file scope is one file short, and the obstruction is mechanical

Task 567's `file_scope` is `FormalSystem/Semantics/Presheaf/Determinism.lean` alone. The theorem
pair does not fit there:

- All four `Presheaf/` modules close with
  `assert_not_exists FormalSystem.ProofSystem.Axiom FormalSystem.ProofSystem.DerivationTree`,
  and `Presheaf/README.md` records that lock as the cluster's stated invariant.
- A compile of `import FormalSystem.Semantics.DeterministicBridge` plus that `assert_not_exists`
  **fails**, naming the chain: `ProofSystem.Axioms → Semantics.FrameClassValidity →
  Semantics.ValidityLayer → Semantics.Validity → PlusLanguage.PlusValidity →
  PlusLanguage.PlusDeterminism → Semantics.DeterministicBridge`. `TaskFrame.SingletonClasses` is
  defined in `DeterministicBridge`, so the converse half cannot be *stated* inside the cluster
  under its own name.
- `F0`, `driftLinear` and `fzero_determined` live under `Metalogic/Independence/`, far above
  `Semantics/`; importing them into `Semantics/Presheaf/` would invert the layering outright.
- `Semantics/Extension/Extension.lean` **is** lock-compatible (a compile importing it with the same
  `assert_not_exists` passes), so a cluster module may reach `thm:extension` directly — but only by
  duplicating `deterministic_of_singletonClasses`' two-point construction, which this repository
  consistently refuses.

There is an exact in-repo precedent for the split: `states_eq_of_deterministic` (choice-free, in
`PlusDeterminism.lean`) and `deterministic_of_singletonClasses` (ZFC, in `DeterministicBridge.lean`)
are the two halves of one biconditional, sited on opposite sides of this same lock, with
`deterministic_iff_singletonClasses` packaging them above it.

#### 6. The posed open question is narrower than the description states

- `L⁺`: no set of `PlusFormula`s defines the deterministic frames
  (`deterministic_not_plusDefinable`), hence none defines separatedness.
- `BL⋆`: `deterministic_starDefinable` gives `F.Deterministic ↔ ∀ φ, F.StarValidOn (detPM φ)` and
  already at bare atoms, under `[F.IsRegular]`. Composed with item 1, `detPM` **is** a `BL⋆`
  characterization of separatedness of `Beh(F)` on regular frames.
- So the question as the description poses it ("does any `BL⋆` formula characterize separatedness
  exactly?") is answered **yes**, by a theorem that landed after the study was written. What
  survives is §5.2.1's real obstruction: `deterministic_starDefinable`'s (⇒) direction runs through
  `thm:extension` and is a theorem of ZFC, so no *choice-free* characterization is known — and
  `StarDeterminism.lean`'s choice-dependence note suggests none exists.

### External Resources

- Mathlib: nothing new is needed. The compiled proofs use only `sub_nonneg`, `le_add_of_nonneg_right`,
  `sub_le_sub_right`, `add_sub_cancel`, `le_antisymm`, `ring`, `norm_num`, and `simpa` — all inside
  the existing import closure. No `linarith`/`ring` availability problem of the kind `Sheaf.lean`'s
  Implementation Notes record, because the new module sits at the same level and the two arithmetic
  steps it needs (`p + 0 = p`, `p + (r - p) = r`) are named lemmas.
- Mathlib's `CategoryTheory.Sheaf`/`Presheaf` API is still not worth adopting here; task 563's
  report already recorded that decision and nothing in this clause touches it.
- Searches run: `lean_local_search`-style grep sweeps over `FormalSystem/` for
  `states_eq_of_deterministic`, `SingletonClasses`, `Separated`, `Injective`, `driftLinear`,
  `toBeh`. No existing declaration named `Separated*` or `*_separated` exists anywhere in
  `FormalSystem/` (the `sep`/`SepSharpness` family is about `Axiom.sep`, unrelated), so the name is
  free.

### Recommendations

A three-phase plan, each phase ending green with no new `sorry`:

1. **Phase 1 — `FormalSystem/Semantics/Presheaf/Determinism.lean`** (in declared scope; keeps the
   `assert_not_exists` lock; imports `Presheaf.Sheaf` and `Presheaf.Ray` only). Deliver
   `Separated`, `states_eq_of_deterministic_sec`, `separated_of_deterministic`, `secOf` +
   `secOf_states`, and `states_eq_of_separated` — the content of `singletonClasses_of_separated`
   written out without the `SingletonClasses` name, since that name is behind the lock. Add the
   one-line aggregator import in `FormalSystem/Semantics/Presheaf.lean`, regenerate the README
   inventory block, and re-run `lake build` after the aggregator edit (the dispatch's shared-touch
   warning).
2. **Phase 2 — the biconditional, above the lock.** Append `deterministic_iff_separated` to
   `FormalSystem/Semantics/DeterministicBridge.lean`, which already owns the ZFC half and whose
   docstring already explains the direction-tracking choice profile. Recommended over a new module:
   it adds four lines and no new file, and it puts the two biconditionals (`SingletonClasses` and
   `Separated`) side by side. The alternative — fold this into phase 3's module — is acceptable but
   buries a `Semantics`-level dictionary row under `Metalogic/`.
3. **Phase 3 — `FormalSystem/Metalogic/Independence/BehSeparatedness.lean`** (new file, outside
   declared scope). Imports `Independence.StarDiscrimination` (for `driftLinear`) and the phase-1
   module. Deliver `driftSec`, `fzero_not_separated`, `separated_strictly_stronger`, and the
   module docstring carrying: the two senses of separatedness (item 4), the pair-is-not-the-clause's-
   converse warning (item 3), the narrowed open question (item 6), and the `## References` block in
   `docs/development/REFERENCE_NORMAL_FORM.md`'s form with keys resolving in the root
   `references.bib`. Add the `Metalogic/Independence.lean` aggregator import and its README row.

Docstring content to carry (durable phrasing, no task numbers):

- *Separatedness here is injectivity of every restriction map. The cover-relative sheaf-theoretic
  reading is unconditional on this site and is not what is at issue.*
- *Validity of Determined is invariant under re-timing histories; separatedness is not. The drift
  frame is the translation flow re-timed, which is why it validates the schema without being
  deterministic.* (Report 01's Finding 3 suggestion; keep it as prose and cite
  `DeterminismUndefinable.lean`, never the probe.)
- The open question, in its surviving form: *no choice-free characterization of separatedness in
  `BL⋆` is known; `detPM` characterizes it as a theorem of ZFC.*

Gate obligations to check at the end of each phase: C1 (build), C3 (no `sorry`), C4 (imports
resolve), C8 (aggregator convention), C9 (no task-number citations), C15 (`app:presheaf-dictionary`
and `app:drift` anchors are `DANGLING` rows in `docs/reference/paper-definitions-of-record.md` —
cite them the way `Behavior.lean` and `Sheaf.lean` already do, with the `DANGLING` marker), C19
(docstring coverage), C24 (`FormalSystem.Init` in the closure), C31 (`## References` bib keys), C33
(root `FormalSystem.lean` regeneration), plus the README generated-inventory blocks.

## Decisions

1. **Separatedness is defined as injectivity of every restriction map**, not cover-relative
   separatedness. Forced by item 4: the cover-relative reading is a theorem about every frame.
2. **The theorem pair is split across the import lock**, phases 1-3 above, mirroring the existing
   `PlusDeterminism` / `DeterministicBridge` precedent. The declared single-file `file_scope` is
   therefore insufficient; phases 2 and 3 touch files outside it. Recorded here rather than
   silently widened — no sibling task owns `DeterministicBridge.lean`,
   `Metalogic/Independence.lean` or the Independence README, so the collision risk is the
   aggregator one the dispatch already names.
3. **The clause is proved as a biconditional**, with the converse routed through
   `deterministic_of_singletonClasses` rather than a second Zorn argument.
4. **The "open question" paragraph is replaced, not deleted.** The description's question is
   answered by `deterministic_starDefinable`; the docstring records the narrowed question
   (choice-free characterization) and cites both definability results. This resolves the tension
   between the dispatch's "pose, do not settle" instruction and report 01's finding: the question
   is posed, in the only form in which it is still open.
5. **No new axiom, no `sorry`, no deferral.** Everything is compiled; the zero-debt gate is met by
   construction.

## Risks & Mitigations

- **Risk**: the aggregator line in `FormalSystem/Semantics/Presheaf.lean` is a shared touch across
  this categorical front and the collision gate does not see it. **Mitigation**: the dispatch's own
  rule — re-read the aggregator immediately before editing, stage only this task's hunks, re-run
  `lake build` after the edit, and keep the front to batches of at most two.
- **Risk**: scope widening past the declared single file could collide with a future task on
  `DeterministicBridge.lean`. **Mitigation**: phase 2 is four lines and can be moved into phase 3's
  module if contention appears; the plan should say so explicitly so the fallback needs no
  re-research.
- **Risk**: a reader takes `fzero_not_separated` for a counterexample to the clause.
  **Mitigation**: the docstring sentence in item 3; state the two converses in the same paragraph.
- **Risk**: `Classical.choice` on the `F°` witness invites a false "this needed Zorn" reading.
  **Mitigation**: word the provenance claim as `DriftHistories.lean` and `StarDeterminism.lean`
  already do — "no appeal to `thm:extension` or `cor:occurrence`, hence no Zorn" — and pin the
  measured axiom list beside it.
- **Risk**: probe 01 imports `StarDiscrimination`, which is heavy; elaboration of phase 3's module
  will be correspondingly slow. **Mitigation**: it is one module and the probe already elaborated
  it inside the guard's budget; route every build through `lake-build-guard.sh` detached, per
  `long-builds.md`.

## Tactic Survey Results

Tactics were exercised directly in the two probes rather than through `lean_multi_attempt`, since
every goal sits inside a multi-step proof where an isolated one-liner attempt is not meaningful.
What the compiles establish:

| Goal | Tactic | Result | Premises/Config |
|---|---|---|---|
| germ equality of two restrictions (`0 + 0 + x = x` under `state_congr`) | `rw [state_congr ...]` | fail | the ascribed type elaborates to `0 + x = x`; the pattern `?a + 0` is absent |
| same goal | `simpa using h` | success | default simp set |
| read a state back at `y - x + x` | `simpa using this` | success | `sub_add_cancel` in the default set |
| germ states of `driftSec 1` vs `driftSec 2` at `0` | `ring` | success | — |
| `1 * (1 + 0) = 2 * (1 + 0)` refutation | `norm_num` | success | — |
| the two dependent time transports (`p + 0 = p`, `p + (r - p) = r`) | `PartialHistory.states_eq_of_time_eq` | success | explicit transport, not `rw` |

Note for the implementer: `rw` with a type-ascribed equality proof against a `state_congr`
argument is the one shape that failed, twice, in the same way. Prefer `simpa using h`, or a `have
e : ... := by simp` whose statement Lean has already normalized.

## Context Extension Recommendations

- **Topic**: the `assert_not_exists` layering lock as a *planning* constraint.
- **Gap**: `context/project/lean4/` has no note that a clause of the presheaf dictionary may be
  unstatable inside the `Presheaf/` cluster, nor that `Semantics/DeterministicBridge.lean` is above
  the lock while `Semantics/Extension/Extension.lean` is below it. The cost of discovering this is
  one failed compile per task on this front.
- **Recommendation**: add a short note to `.claude/context/project/lean4/patterns/` recording the
  measured lock boundary (the `ProofSystem.Axioms → FrameClassValidity → ValidityLayer → Validity →
  PlusValidity → PlusDeterminism → DeterministicBridge` chain, and that `Extension.lean` is clean),
  with the `PlusDeterminism`/`DeterministicBridge` split as the sanctioned pattern for a
  biconditional that straddles it.

## Appendix

### Probes

- `probes/01_determinism-clause.lean` — the full theorem pair plus the axiom pins. Command:
  `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- env lean
  specs/567_determinism_clause_and_separatedness_asymmetry/probes/01_determinism-clause.lean`,
  exit status 0.
- `probes/02_cover-separated.lean` — cover-relative separatedness at no frame hypothesis, with the
  `assert_not_exists` lock asserted against an `Extension.lean` import. Same command shape, exit
  status 0 (run with `--no-share` to defeat the guard's result replay).

### Measured axiom pins (from probe 01)

```
states_eq_of_deterministic_sec   [propext]
separated_of_deterministic       [propext, Quot.sound]
singletonClasses_of_separated    [propext, Quot.sound]
separated_iff_deterministic      [propext, Classical.choice, Quot.sound]
fzero_not_separated              [propext, Classical.choice, Quot.sound]
separated_strictly_stronger      [propext, Classical.choice, Quot.sound]
cover_separated (probe 02)       [propext, Quot.sound]
```

### Existing declarations the implementation consumes

- `Beh`, `Beh.restrict`, `Beh.restrictTr`, `Beh.mem_dom`, `Beh.ext`, `partialHistory_ext`
  (`Presheaf/Behavior.lean`)
- `states_eq_of_eq` (`Presheaf/Sheaf.lean`), `futOf`, `FutRay.toBeh`, `FutRay.toBeh_states`
  (`Presheaf/Ray.lean`)
- `TaskFrame.Deterministic`, `deterministic_iff` (`Semantics/FrameProperty.lean`)
- `PartialHistory.states_eq_of_time_eq`, `WorldHistory.timeShift`, `timeShift_state`,
  `state_congr` (`Semantics/PartialHistory.lean`)
- `TaskFrame.SingletonClasses`, `deterministic_of_singletonClasses`,
  `deterministic_iff_singletonClasses` (`Semantics/DeterministicBridge.lean`)
- `driftLinear`, `driftLinear_state` (`Independence/StarDiscrimination.lean`); `fzero_determined`,
  `determined_valid_on_non_deterministic`, `deterministic_not_plusDefinable`
  (`Independence/DeterminismUndefinable.lean`); `F0`, `fzero_not_deterministic`
  (`Independence/DriftFrame.lean`)
- `deterministic_starDefinable`, `detPM` (`StarLanguage/StarDeterminism.lean`)
