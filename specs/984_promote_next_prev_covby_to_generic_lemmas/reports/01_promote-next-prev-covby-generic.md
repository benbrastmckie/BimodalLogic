# Research Report: Task #984

**Task**: 984 - Promote next_iff_covBy and prev_iff_covBy to the generic next_iff/prev_iff
**Started**: 2026-11-25T02:38:23Z
**Completed**: 2026-11-25T02:49:00Z
**Effort**: Small — one new lemma pair in `TemporalRules.lean`, four one-line repoints, one docstring/README sweep, three documentation-gate reruns
**Dependencies**: None blocking. `FormalSystem/Semantics/TemporalRules.lean` is on `main` (the pointed semantic lemmas contribution, milestone C1, merged); the sibling follow-up task 989 landed its `TensePersistence` section in the same file and is complete at `055e70188`.
**Sources/Inputs**:
- Codebase: `FormalSystem/Semantics/TemporalRules.lean`, `FormalSystem/Semantics/TruthClauses.lean`, `FormalSystem/Semantics/Truth.lean`, `FormalSystem/SourceLanguage/SentenceTruth.lean`, `FormalSystem/Metalogic/DiscreteNonCompactness.lean`, `FormalSystem/Metalogic/AuxiliaryAtoms.lean`, `FormalSystem/NomicLanguage/NomicTruth.lean`, `Tests/BimodalTest/Semantics/TemporalRulesTest.lean`
- Gate scripts: `scripts/check-metalogic-cycles.sh`, `scripts/check-module-invariants.sh` (C14, INV), `scripts/readme-lint.sh`, `scripts/measure-refactor-partitions.py`
- lean-lsp MCP `lean_run_code` (six compiled probes); no external Mathlib search was needed — every lemma consumed is already in the module's import closure
**Artifacts**: - `specs/984_promote_next_prev_covby_to_generic_lemmas/reports/01_promote-next-prev-covby-generic.md`
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **The promotion is mechanically clean and compile-verified.** `TemporalRules.next_iff (L := Formula) M τ t PUnit.unit φ` inhabits `next_iff_covBy`'s statement *verbatim*, with no `show`, no conversion and no instance gymnastics; same for `prev_iff`/`prev_iff_covBy`. Both probes compiled on the first attempt.
- **The succ-form fact should be promoted too, and the promotion costs zero new imports.** A generic `next_iff_succ`/`prev_iff_pred` pair stated over `TruthEnv` + `UntlClause`/`SnceClause` and `[SuccOrder F.Duration] [NoMaxOrder F.Duration]` (resp. `Pred`/`NoMin`) compiles with `import FormalSystem.Semantics.TemporalRules` as the *only* import — `SuccOrder`, `PredOrder`, `Order.succ/pred` and all six order lemmas the proof uses are already in that module's closure. This is what lets `Metalogic/DiscreteNonCompactness.lean`'s `truthAt_next_iff` be repointed at all, since the covBy form alone cannot discharge it.
- **Repointing *improves* the axiom profile and breaks no pinned baseline.** Measured: `next_iff_covBy`/`prev_iff_covBy` carry `[propext, Quot.sound]` today; the generic `next_iff`/`prev_iff` carry `[propext]` alone, so both lose `Quot.sound`. The succ forms stay at `[propext, Classical.choice, Quot.sound]` — the exact string `check-module-invariants.sh`'s C14 heredoc pins for `truthAt_next_iff` and `truthAt_next_iterate`.
- **Hard constraint discovered mechanically: `FormalSystem.Metalogic.truthAt_next_iff` and `truthAt_next_iterate` must keep their names.** Both are pinned by fully qualified name in C14's `#print axioms` baseline. Removal-and-repoint-uses is therefore *not* an option for those two; one-line corollary is the only route.
- **Layering cost is zero, and in one direction it is literally nothing.** `FormalSystem.Semantics.TemporalRules` is *already* in `DiscreteNonCompactness.lean`'s 347-module import closure (via the `FormalSystem.Semantics` roll-up), so no import line is needed there. `SentenceTruth.lean` needs one new import, adding exactly one module to its 13-module closure. Both edges are lateral (1→1) or downward (3→1) under `LANGUAGE_FILE_LAYERS`, which files `SourceLanguage/SentenceTruth` at layer 1.
- **One pre-existing red gate to not mistake for a regression**: `scripts/readme-lint.sh` already FAILs on the current tree with 7 new stale dates, all in directories this task does not touch.

## Context & Scope

Researched: whether the two base-language `CovBy` characterizations in `SentenceTruth.lean` can be
replaced by the generic clause-layer lemmas in `TemporalRules.lean`, what shape the replacement
must take so the `succ`-form duplicate in `Metalogic/DiscreteNonCompactness.lean` can also be
retired, and which of this repository's mechanical gates decide whether the result lands.

Constraints taken as given: no statement changes for downstream users; zero `sorry`; no new axiom;
the existing clause-layer discipline recorded in `TruthClauses.lean`'s extension contract (no
attributes on a generic lemma, `Env` threaded inert, every clause field `Iff.rfl`).

Deliberately *not* in scope, and recorded as such: `NomicLanguage/NomicTruth.lean`'s own
`next_iff_succ`. That module has no `TruthEnv` instance at all — it evaluates `NomicTruthAt` over
`NomicModel`/`NomicFrame`, a different point shape — and its own docstring already records the
abstract clause layer as "unusable" there. It cannot be served by any generic lemma and must stay
a transcription.

## Findings

### Codebase Patterns

**The four copies of the `next` fact, and what each needs.**

| Declaration | File | Statement form | Can the generic lemma serve it? |
|---|---|---|---|
| `Semantics.TemporalRules.next_iff` / `prev_iff` | `Semantics/TemporalRules.lean` | `CovBy`, generic over `L` | — (this *is* the generic lemma) |
| `SourceLanguage.next_iff_covBy` / `prev_iff_covBy` | `SourceLanguage/SentenceTruth.lean` | `CovBy`, at `Formula` | Yes, verbatim (probe A/B) |
| `SourceLanguage.next_iff_succ` / `prev_iff_pred` | `SourceLanguage/SentenceTruth.lean` | `Order.succ`/`Order.pred`, at `Formula` | Yes, from a promoted generic succ form (probe C) |
| `Metalogic.truthAt_next_iff` | `Metalogic/DiscreteNonCompactness.lean` | `Order.succ`, at `Formula` | Yes, same promoted generic succ form (probe F) |
| `Metalogic.AuxiliaryAtoms.plusTruthAt_next_iff_succ` | `Metalogic/AuxiliaryAtoms.lean` | `Order.succ`, at `PlusFormula` | Yes (probe E) — **adjacent, out of this task's declared scope** |
| `NomicLanguage.NomicTruth.next_iff_succ` | `NomicLanguage/NomicTruth.lean` | `Order.succ`, at `NomicFormula` | **No** — no `TruthEnv` instance; different point shape |

`TemporalRules.next` is `UntlClause.untl BotClause.bot φ` and `Formula.next` is
`Formula.untl Formula.bot φ` (`Syntax/Formula.lean`); with `instance : UntlClauses Formula`'s
`Iff.rfl` clause fields and `instance : TruthEnv Formula` (`Env _ := PUnit`,
`T M τ t _ φ := TruthAt M τ t φ`), the two statements are definitionally the same proposition.
That is why the repoint needs no bridging lemma.

**The three `succ`-form copies share one argument, duplicated.** `SentenceTruth.next_iff_succ`,
`Metalogic.truthAt_next_iff` and `AuxiliaryAtoms.plusTruthAt_next_iff_succ` each re-derive
"the empty-gap condition forces the witness to be the immediate successor" from scratch.
`AuxiliaryAtoms.lean`'s own docstring already names itself a **promotion candidate** and asks a
later reader to promote rather than duplicate. `DiscreteNonCompactness.lean`'s docstring says the
same of `truthAt_next_iff`, naming `Semantics/Truth.lean` as the then-intended home and
"promotion is the right move once a second consumer appears". A generic lemma in
`TemporalRules.lean` is a strictly better home than `Truth.lean`: it is language-generic, so it
serves L, L⁺ and L⋆ at once instead of only L.

**`assert_not_exists` and the attribute discipline both survive.** `TemporalRules.lean`'s
`assert_not_exists FormalSystem.ProofSystem.Axiom FormalSystem.ProofSystem.DerivationTree` is
unaffected (neither new lemma reaches the proof system). The new lemmas must carry **no**
attributes: `TruthClauses.lean`'s extension contract forbids attributes on generic lemmas
outright, and `DiscreteNonCompactness.lean` independently records why a simp-normal `next` rewrite
is specifically harmful — it would fire inside the proof-theoretic reasoning in
`Theorems/DiscreteUnfolding.lean`. The two reasons agree; honour both.

**Layering, measured not argued.** `LANGUAGE_FILE_LAYERS` in
`scripts/measure-refactor-partitions.py` files `SourceLanguage/SentenceTruth` at layer 1;
`LAYERS` files `Semantics` at 1 and `Metalogic` at 3. So `SentenceTruth → Semantics.TemporalRules`
is lateral and `DiscreteNonCompactness → Semantics.TemporalRules` is downward. Neither can enter
`check-metalogic-cycles.sh`'s upward allowlist, which currently PASSes at exactly its recorded 10
lines (measured this dispatch, all three assertions green).

**Import closure, measured.** `FormalSystem.Semantics.TemporalRules` is already reachable from
`FormalSystem.Metalogic.DiscreteNonCompactness` through the `FormalSystem.Semantics` roll-up
(closure size 347), so the Metalogic-side repoint needs **no new import line**.
`SentenceTruth.lean`'s closure is 13 modules and does not contain `TemporalRules`; adding the
import grows it by exactly one module, since `TemporalRules` imports only `TruthClauses`, which
`SentenceTruth` already reaches through `Semantics.Truth`.

### External Resources

No Mathlib search was required. Every order lemma the promoted proof consumes —
`Order.succ_le_of_lt`, `Order.lt_succ`, `Order.le_of_lt_succ`, `Order.le_pred_of_lt`,
`Order.pred_lt`, `Order.le_of_pred_lt`, plus `lt_or_eq_of_le`, `not_lt`, `absurd` and `CovBy` —
`#check`s successfully against `import FormalSystem.Semantics.TemporalRules` alone. The existing
proofs in `SentenceTruth.lean` already use exactly these names; the promoted proof reuses them
unchanged rather than re-deriving a route.

### Recommendations

- **R1. Add a generic `next_iff_succ`/`prev_iff_pred` pair to `FormalSystem/Semantics/TemporalRules.lean`**, in a new section after `NextPrev` (suggested name `DiscreteCollapse`), stated over the module's existing `variable {L : Type} [TruthEnv L] [BotClause L] {F : TaskFrame}` plus `[UntlClause L] [SuccOrder F.Duration] [NoMaxOrder F.Duration]` (resp. `[SnceClause L] [PredOrder F.Duration] [NoMinOrder F.Duration]`), each proved by `rw [next_iff]` / `rw [prev_iff]` and then the same two-branch argument `SentenceTruth.next_iff_succ` uses today. No attributes. Add both names to the module docstring's `## Main Results` list. **[VERIFIED: PASS — the exact lemma pair, body included, elaborated with `import FormalSystem.Semantics.TemporalRules` as its only import via `lean_run_code`; zero diagnostics]**

- **R2. Keep `SourceLanguage.next_iff_covBy`, `prev_iff_covBy`, `next_iff_succ`, `prev_iff_pred` as names, with their statements byte-identical, and replace each body by a one-line term**: `TemporalRules.next_iff (L := Formula) M τ t PUnit.unit φ`, `TemporalRules.prev_iff …`, `TemporalRules.next_iff_succ (L := Formula) M τ t PUnit.unit φ`, `TemporalRules.prev_iff_pred …`. Add `import FormalSystem.Semantics.TemporalRules`. Do **not** delete the four names and repoint uses: `sat_iff` consumes `next_iff_covBy`/`prev_iff_covBy` as *simp lemmas*, and the generic lemma's LHS (`TruthEnv.T … (TemporalRules.next φ)`) will not syntactically match `TruthAt … (Formula.next …)` in a simp set. **[VERIFIED: PASS — all four one-line terms type-check, and `sat_iff` re-proves verbatim (all 18 cases, `simp [Sat, tr, ih, next_iff_covBy']`) against the repointed corollaries, axiom profile unchanged at `[propext, Classical.choice, Quot.sound]`]**

- **R3. Repoint `Metalogic.truthAt_next_iff`'s body to `TemporalRules.next_iff_succ (L := Formula) M τ t PUnit.unit φ`, keeping the declaration name and statement exactly as they are, and add no import.** Removal is not available: `check-module-invariants.sh`'s C14 heredoc pins `FormalSystem.Metalogic.truthAt_next_iff` and `FormalSystem.Metalogic.truthAt_next_iterate` by fully qualified name against `'…' depends on axioms: [propext, Classical.choice, Quot.sound]` by exact string equality. **[VERIFIED: PASS — the repointed `truthAt_next_iff` measures `[propext, Classical.choice, Quot.sound]`, identical to the pinned string, and its sole consumer `truthAt_next_iterate` re-proves verbatim (`rw [Function.iterate_succ_apply, ih, Function.iterate_succ_apply']; exact truthAt_next_iff' M τ _ φ`) at the same profile]**

- **R4. Add test rows to `Tests/BimodalTest/Semantics/TemporalRulesTest.lean`** for the two new generic lemmas, following that file's existing per-language `example` pattern: one at `Formula`, one at `PlusFormula`, and one at `StarFormula` passing the file's own `regs` so the `Env`-threading obligation is exercised at the one language whose `Env` is not `PUnit`. The examples need `[SuccOrder F.Duration] [NoMaxOrder F.Duration]` (resp. `Pred`/`NoMin`) added to the variable block or stated per example. **[No compiled gate applicable — the test file is a new-content addition, not an artifact an existing gate adjudicates; its correctness is decided by `lake build` at implementation time]**

- **R5. Rewrite the documentation surfaces that currently record the duplication as unresolved**, stating the current design only (per `no-record-versioning-in-deliverables.md`: no "no longer", "previously", or supersession framing):
  - `SentenceTruth.lean` module docstring — the `## CovBy is the theorem; succ/pred are corollaries` section's closing paragraph (the "deliberate and unresolved" note) and the `## References` bullet naming `truthAt_next_iff` as "duplicated here for the reason above".
  - `SourceLanguage/README.md` — the `## next/prev` section, and the `## Not formalized` table row "Consolidation with `../Metalogic/DiscreteNonCompactness.lean`'s `truthAt_next_iff`", which should be removed from that table since the consolidation is done (through the clause layer, not through an upward edge).
  - `FormalSystem/SourceLanguage.lean` — the `## Semantic modules` bullet.
  - `DiscreteNonCompactness.lean` — the `## Note on truthAt_next_iff / truthAt_next_iterate` section, which currently names `Semantics/Truth.lean` as the intended home and says promotion awaits a second consumer.
  - `FormalSystem/Metalogic.lean` — the `DiscreteNonCompactness.lean` bullet's phrase "the first semantic characterisation of `Formula.next`", which stops being true once the generic lemma exists upstream.
  - `NomicLanguage/NomicTruth.lean` — the `## References` bullet and the `next_iff_succ` docstring, both of which point at `truthAt_next_iff` as the transcription source; repoint at the generic lemma and keep the recorded reason the clause layer is unusable there.
  - `Semantics/README.md` — the `TemporalRules.lean` row's description.
  - `AuxiliaryAtoms.lean` — the `plusTruthAt_next_iff_succ` docstring's promotion note, whose named eventual home (`PlusTruth.lean`) is superseded by the generic lemma being available.

  **[No compiled gate applicable — prose, adjudicated by review and by the documentation gates in R6/R7, not by a predicate over a named artifact]**

- **R6. Regenerate the inventory blocks and rerun the INV check.** `SourceLanguage/README.md` carries `<!-- BEGIN GENERATED: inventory dir=FormalSystem/SourceLanguage -->` with `SentenceTruth.lean | 253`, and `Metalogic/README.md` carries a generated row `DiscreteNonCompactness.lean | 322`; both line counts change. Run `bash scripts/check-module-invariants.sh --emit-inventory` then `--emit-inventory --check`. **[VERIFIED: PASS (baseline) — `--emit-inventory --check` currently reports `PASS INV every generated inventory block is current, every hand-maintained one is exhaustive`, so a post-edit red is attributable to this task and nothing else]**

- **R7. Bump `FormalSystem/SourceLanguage/README.md`'s `*Last verified:*` stamp to the implementation date — this one is mandatory, not hygiene.** That README is stamped `2026-09-27`, which equals its directory's last commit date, so it is currently *fresh* and is **not** grandfathered in `scripts/readme-date-baseline.txt`. Touching `FormalSystem/SourceLanguage/` without bumping it creates a genuine new finding and turns `readme-lint.sh` from "7 new stale" to "8 new stale". `FormalSystem/Semantics/README.md` (`stale … 2026-11-06`) and `FormalSystem/Metalogic/README.md` (`stale … 2026-10-02`) *are* grandfathered; bumping them is optional and safe — a refreshed stamp un-grandfathers the row, which the script then reports as a `PRUNE:` candidate rather than a failure (observed live for `Metalogic/Conservativity/README.md`). **[VERIFIED: FAIL (pre-existing, not caused by this task) — `bash scripts/readme-lint.sh` exits 1 today with `RESULT: FAIL (7 new stale dates, 0 new missing dates)`; revised to: do not require `readme-lint.sh` to exit 0 as this task's acceptance criterion. Require instead that the set of new stale findings is unchanged from the measured pre-existing seven: `Automation/ProofMode`, `Metalogic/Conservativity/Star`, `Metalogic/Expressiveness`, `Metalogic/WeakCanonical`, `Tactic`, `Theorems/ProofMode`, `Theorems/ProofMode/TemporalComposition`.]**

- **R8. Treat the L⁺ copy as an adjacent opportunity, not this task's scope.** `AuxiliaryAtoms.plusTruthAt_next_iff_succ` is served by the same generic lemma and could become a one-liner, retiring the third copy of the succ argument. It is outside this task's declared deliverable (which names `SentenceTruth.lean` and `DiscreteNonCompactness.lean` only), and `AuxiliaryAtoms.lean` is in a different, heavily-pinned module. Record it; do not fold it in without a decision. **[VERIFIED: PASS — `Probe2.next_iff_succ (L := PlusFormula) M τ t PUnit.unit φ` inhabits `plusTruthAt_next_iff_succ`'s statement (`PlusTruthAt M τ t φ.next ↔ PlusTruthAt M τ (Order.succ t) φ`) verbatim, so the opportunity is real rather than conjectural]**

## Decisions

- **The succ form is promoted alongside the covBy form, not left behind.** The task title names only `next_iff_covBy`/`prev_iff_covBy`, but the deliverable also requires the `DiscreteNonCompactness.lean` copy to be repointed, and `truthAt_next_iff` is a `succ`-form statement that the covBy lemma alone cannot discharge. Promoting both forms is the minimum that satisfies the stated deliverable. Confirmed by measurement that this costs zero new imports in `TemporalRules.lean`.
- **Corollary, not deletion, for all five base-language names.** Forced in two independent places: C14 pins `truthAt_next_iff`/`truthAt_next_iterate` by name, and `sat_iff` consumes `next_iff_covBy`/`prev_iff_covBy` as simp lemmas whose LHS shape the generic statement does not have.
- **`TemporalRules.lean` is the home, not `Semantics/Truth.lean`.** `DiscreteNonCompactness.lean`'s docstring names `Truth.lean`; that choice predates the clause layer. `Truth.lean` is `Formula`-specific, so a lemma landed there would serve only L; `TemporalRules.lean` serves L, L⁺ and L⋆ from one statement, which is the whole point of the clause layer and what makes the promotion worth doing.
- **No attributes on the new lemmas.** Two independent recorded reasons agree (the clause-layer extension contract; the `Theorems/DiscreteUnfolding.lean` simp hazard).
- **The Nomic copy stays.** It is unreachable from the clause layer by construction, and its module docstring already records why.
- **`readme-lint.sh` exit 0 is not an acceptance criterion for this task.** It is red before this task starts, for reasons in seven unrelated directories.

## Risks & Mitigations

- **Risk: the implementer reads `readme-lint.sh`'s red as this task's regression** and either chases seven unrelated directories or marks the task blocked. *Mitigation*: R7 records the exact pre-existing seven; compare sets, not exit codes.
- **Risk: a `@[simp]` attribute gets attached to the new generic lemmas out of habit** (L's own wrappers carry `@[simp, truth_norm]`), silently changing every downstream simp set and perturbing the proof-theoretic reasoning in `Theorems/DiscreteUnfolding.lean`. *Mitigation*: R1 states the prohibition and names both recorded reasons; a full `lake build` would catch the breakage, but late.
- **Risk: deleting `next_iff_covBy`/`prev_iff_covBy` instead of repointing them**, which looks like the cleaner move and breaks `sat_iff`'s simp set. *Mitigation*: R2 states the reason explicitly and the compiled probe demonstrates the working shape.
- **Risk: documentation prose drifts into supersession narration** ("the duplication is no longer deliberate", "previously unresolved"), violating `no-record-versioning-in-deliverables.md`. *Mitigation*: R5 states the constraint inline; the `## Not formalized` row should be *removed*, not amended with a status change.
- **Risk: the `SourceLanguage/README.md` `Last verified` stamp is overlooked** because the other two directories' READMEs are grandfathered and give no signal. *Mitigation*: R7 singles it out as the one mandatory bump, with the measurement that distinguishes it.
- **Risk: C14's exact-string axiom pin is perturbed by a proof route that pulls a different axiom.** *Mitigation*: already measured — the repointed `truthAt_next_iff` and `truthAt_next_iterate` both sit at `[propext, Classical.choice, Quot.sound]`, matching the pinned baseline byte for byte. Rerun `bash scripts/check-module-invariants.sh` at phase end regardless, since it is the gate of record.
- **Risk: `TemporalRules.lean` is widely imported** (it is in the `FormalSystem.Semantics` roll-up, hence in a 347-module closure), so a mistake there is expensive to discover. *Mitigation*: the new section is additive, carries no attributes, and introduces no import; scope the phase-end build to `FormalSystem.Semantics.TemporalRules` first, then run the unscoped build only as final verification.

## Tactic Survey Results

No tactic search was needed: the promoted proof reuses, unchanged, the term-mode route the
existing `SentenceTruth.next_iff_succ`/`prev_iff_pred` proofs already use, and the two covBy
repoints are single applied terms with no tactic block at all. Candidates were nonetheless
exercised as whole-declaration compiled probes rather than as isolated tactic attempts, which is
the stronger check; the rows below record those probes.

| Goal | Tactic | Result | Premises/Config |
|------|--------|--------|-----------------|
| `next_iff_covBy` / `prev_iff_covBy` statements at `Formula` | term application | success | `TemporalRules.next_iff` / `prev_iff` `(L := Formula) M τ t PUnit.unit φ`; no `show`, no conversion |
| generic `next_iff_succ` over `TruthEnv`/`UntlClause` | `rw [next_iff]` then two-branch `rcases`/`absurd` | success | `Order.succ_le_of_lt`, `Order.lt_succ`, `Order.le_of_lt_succ`, `lt_or_eq_of_le`, `not_lt` — all already in `TemporalRules.lean`'s closure |
| generic `prev_iff_pred` over `TruthEnv`/`SnceClause` | `rw [prev_iff]` then two-branch `rcases`/`absurd` | success | `Order.le_pred_of_lt`, `Order.pred_lt`, `Order.le_of_pred_lt` — same closure |
| `SourceLanguage.next_iff_succ` / `prev_iff_pred` at `Formula` | term application | success | generic succ/pred lemma at `(L := Formula) … PUnit.unit` |
| `Metalogic.truthAt_next_iff` at `Formula` | term application | success | same generic succ lemma; axioms `[propext, Classical.choice, Quot.sound]`, matching the C14 pin |
| `Metalogic.truthAt_next_iterate` (the real consumer) | `rw [Function.iterate_succ_apply, ih, Function.iterate_succ_apply']; exact …` | success | re-proved verbatim against the repointed `truthAt_next_iff` |
| `SourceLanguage.sat_iff`, all 18 cases (the real consumer) | `induction` + per-case `simp`/`tauto`, verbatim | success | `simp [Sat, tr, ih, next_iff_covBy']` / `prev_iff_covBy'`; axioms unchanged |
| `AuxiliaryAtoms.plusTruthAt_next_iff_succ` at `PlusFormula` | term application | success | generic succ lemma at `(L := PlusFormula) … PUnit.unit`; adjacent, out of scope |

## Context Extension Recommendations

- **Topic**: Axiom-pinned declaration names as a refactor constraint.
  **Gap**: `context/project/lean4/` documents dependency tracing and gate collisions, but nothing
  states the rule this dispatch hit: a declaration whose fully qualified name appears in
  `check-module-invariants.sh`'s C14/C2 heredoc pair cannot be renamed or removed by a refactor,
  only re-bodied, because the baseline is matched by exact string equality on the
  `#print axioms` line. That is a cheap pre-refactor grep (`grep -n '<name>'
  scripts/check-module-invariants.sh`) that converts a late red into a design constraint known
  up front.
  **Recommendation**: add a short subsection to
  `context/project/lean4/patterns/plan-authoring-gate-collisions.md` naming the grep and the
  consequence ("repoint the body, keep the name").

- **Topic**: `readme-lint.sh`'s grandfathering asymmetry.
  **Gap**: nothing records that a *fresh* README (stamp equal to its directory's last commit) is
  strictly more fragile under a refactor than a *grandfathered stale* one — touching the fresh
  directory creates a new finding, touching the stale one does not. A plan that bumps the stamps
  it "notices" will reliably miss exactly the one that matters.
  **Recommendation**: record the rule and the one-line pre-check (compare each touched
  directory's `*Last verified:*` stamp against `git log -1 --format=%ad --date=short -- <dir>`
  and against `scripts/readme-date-baseline.txt`) in
  `context/project/lean4/patterns/plan-authoring-gate-collisions.md`.

## Appendix

### Compiled probes run (all via `lean_run_code`, project at `055e70188`)

- **A/B** — `TemporalRules.next_iff` / `prev_iff` `(L := Formula) M τ t PUnit.unit φ` against `next_iff_covBy` / `prev_iff_covBy` statements. Zero diagnostics.
- **C** — candidate generic `next_iff_succ` / `prev_iff_pred` plus the two `Formula` specialisations. Zero diagnostics.
- **D** — `#print axioms` for `next_iff_covBy`, `prev_iff_covBy`, `next_iff_succ`, `prev_iff_pred`, `sat_iff`, `truthAt_next_iff`, `truthAt_next_iterate`, `TemporalRules.next_iff`, `TemporalRules.prev_iff`, and for the repointed corollaries.
- **E** — generic succ lemma at `PlusFormula`, plus the generic covBy lemma at `PlusFormula`.
- **F** — repointed `truthAt_next_iff` and a verbatim re-proof of `truthAt_next_iterate` against it.
- **G** — generic lemma pair with `import FormalSystem.Semantics.TemporalRules` as the sole import (the zero-new-imports gate), and `#check` of `SuccOrder`, `PredOrder`, `NoMaxOrder`, `NoMinOrder`, `Order.succ`, `Order.pred`, `CovBy` and the six order lemmas against that same single import.

### Gate baselines measured this dispatch

| Gate | Command | Result today |
|---|---|---|
| Layer order / cycles | `bash scripts/check-metalogic-cycles.sh` | PASS (all three assertions; upward set exactly the recorded 10 lines) |
| Generated inventory | `bash scripts/check-module-invariants.sh --emit-inventory --check` | PASS |
| README health | `bash scripts/readme-lint.sh` and `… FormalSystem BimodalTools` | FAIL — 7 new stale dates, all pre-existing and in untouched directories |

### Import-closure measurements

- `FormalSystem.Metalogic.DiscreteNonCompactness`: 347 `FormalSystem.*` modules; contains `FormalSystem.Semantics.TemporalRules` already (via `FormalSystem.Semantics`).
- `FormalSystem.SourceLanguage.SentenceTruth`: 13 `FormalSystem.*` modules; does not contain `TemporalRules`; adding it grows the closure by exactly one module.

### Documentation surfaces naming the duplication

`FormalSystem/SourceLanguage/SentenceTruth.lean` (module docstring, two places; `Sat` docstring;
`next_iff_succ` docstring), `FormalSystem/SourceLanguage/README.md` (the `next`/`prev` section,
the generated inventory row, the `## Not formalized` table),
`FormalSystem/SourceLanguage.lean`, `FormalSystem/Metalogic/DiscreteNonCompactness.lean`
(module docstring `## Note on …` section), `FormalSystem/Metalogic.lean`,
`FormalSystem/Metalogic/AuxiliaryAtoms.lean`, `FormalSystem/NomicLanguage/NomicTruth.lean`,
`FormalSystem/Semantics/README.md`, `FormalSystem/Semantics/TemporalRules.lean`
(`## Main Results`).
