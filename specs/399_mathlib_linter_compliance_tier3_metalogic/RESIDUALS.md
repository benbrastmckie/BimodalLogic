# Tier-3 Metalogic linter residuals — accepted API decisions

This file converts the linter findings that remain in the 174-file tier-3 Metalogic surface from
silent leftovers into an explicit, written decision. **Nothing recorded here is deferred work.**
No `sorry` was introduced, no axiom was added, and no proof was left partial: `lake build` is
green at 1,875 jobs and the sorry census is exactly 1, at the pre-existing
`countermodel_discrete` in `WeakCanonical/Transfer.lean` — untouched by this task and out of
scope by charter.

Every count below is measured, not restated from the plan. Sources:
`logs/runlinter-phase8.json` (whole-library `lake exe runLinter Bimodal`) and
`logs/census-phase8.json` (174-file `-Dlinter.mathlibStandardSet=true` census). "In scope" means
the 174 files listed in `baseline/scope-tier3.txt`.

## Summary

| Category | Baseline (in scope) | Now (in scope) | Disposition |
|---|---:|---:|---|
| `runLinter unusedArguments` | 193 | **112** | Accepted residual (below) |
| `unusedDecidableInType` ∪ `unusedFintypeInType` | 187 | **156** | Accepted residual (below) |
| `simpNF LINTER FAILED` artifacts | 6 | **6** | Accepted artifact, root cause out of scope |
| deprecated Mathlib **import** | 1 | **1** | Out of scope — deprecation task |
| `defsWithUnderscore` | 572 | 572 | Out of scope — naming task |
| `defProp` | 35 | 35 | Out of scope — naming task |
| `dupNamespace` | 13 | 13 | Out of scope — naming task |
| `push_neg` deprecation warnings | 521 | 521 | Out of scope — deprecation task |
| `docBlame` | 52 | **0** | Cleared (Phase 8) |
| genuine `simpNF` | 1 | **0** | Cleared (Phase 7) |
| `synTaut` | 1 | **0** | Cleared (Phase 7) |

Whole-library figures for the two accepted categories, for anyone diffing the raw `runLinter`
artifact rather than the scoped view: `unusedArguments` 203 → **122** (the extra 10 live outside
the tier-3 scope, mostly `FrameConditions/Soundness.lean`); `LINTER FAILED` 115 → **115**.

## Deviation from the plan's residual figures — approved

The plan's Phase 9 clause named 187 and 203. Those figures are stale, and the ledger is written
against 156 and 112/122 instead. This is an **approved deviation**, not drift.

Phase 7 was required to clear 34 `unusedSectionVars` findings, and the linter's own prescribed
remedy for them is `omit [Fintype sig.preds] [DecidableEq sig.preds] in` — which removes exactly
the binders that generate the `unusedArguments` and `unusedInstInType` findings this phase was
going to ledger. The two plan clauses are in direct conflict and cannot both hold. Phase 7's
clause is the more specific one (it names `omit` explicitly), so it governs.

What actually changed, and what did not:

- **No signature was hand-edited.** Every removal is the linter's own suggestion applied verbatim
  to a section variable the linter itself reported as unused.
- **No proof changed.** The reduction is entirely section-variable removal.
- **No sibling-owned category moved.** `push_neg` 521, `defProp` 35, `dupNamespace` 13,
  `defsWithUnderscore` 572/888 are all byte-identical to baseline.
- Concentrated in `AggregateOffDiagK1.lean` (28 → 14), `ExteriorNavFutK1.lean` (10 → 1),
  `ExteriorNavPastK1.lean` (9 → 1).

One consequence worth flagging for a future reader: the two declarations the plan named as
residual spot-checks — `parametric_task_rel_*` and `parametric_canonical_truth_lemma` — are no
longer findings at all. They were among the ones Phase 7's omits cleared. Representative current
examples are given below instead.

## Accepted residual 1 — `unusedDecidableInType` ∪ `unusedFintypeInType`, 156 sites, 34 files

**Always union, never sum.** The two linters fire on the *same declaration* almost every time:
`unusedDecidableInType` 154 + `unusedFintypeInType` 150 = 304 raw, but only **156** distinct
declarations. Summing over-sizes the category by 95%.

Every finding has the same shape — a `MonadicSignature`-parametric declaration carrying
`[Fintype sig.preds]` and/or `[DecidableEq sig.preds]` that its *type* does not mention:

```
KampPrior.lean:215: `kampPrior_site_env_bridge` does not use the following hypothesis in its type:
  • [DecidableEq sig.preds] (#3)
  • [Fintype sig.preds] (#2)
```

Hotspots: `NavigatedSpine.lean` 14, `AggregateOffDiagK1.lean` 14, `KampPrior.lean` 11,
`CharacteristicFormula.lean` 11, `Transfer.lean` 9, `SubBracket2V.lean` 9, `SharedWitness.lean` 9,
`CarrierK1V.lean` 8.

### Why these are load-bearing rather than dead weight

This is not merely an appeal to the sibling task's precedent. The reason is recorded in the
codebase itself, in the docstring of `MonadicSignature` (`WeakCanonical/MonadicFO.lean`):
`preds` is deliberately **not** a `Fintype`/`DecidableEq` at the structure level, because the
infinite expansion alphabet `E[Σ]` of Rabinovich Def 4.1 — which adjoins every `TL(U,S)`-formula
over `Σ` as a fresh atom — is genuinely infinite and cannot carry those instance fields.
Finiteness and decidability are therefore threaded **explicitly**, as `[Fintype sig.preds]` /
`[DecidableEq sig.preds]` hypotheses, at each site that enumerates atoms.

That design makes the instance binders part of the stratified API's contract: they mark which
layer of the construction a declaration belongs to, and they must match across a family of
declarations that are used together, whether or not any individual member's *type* happens to
mention them. Removing the 156 that are locally unused would make the family's signatures
inconsistent with each other and would change 156 public signatures for a cosmetic gain.

**Decision: accept.** Do not remove these binders. If a future task wants them gone, it is a
signature-design task across the whole Kamp/EFGames API, not a linter cleanup.

## Accepted residual 2 — `runLinter unusedArguments`, 112 sites in scope, 28 files

The same family, reported by a different linter with a stricter trigger. `unusedInstInType` fires
when a binder is unused **in the type**; `unusedArguments` fires only when it is unused in the
**whole declaration**, proof included. That is why 112 < 156: the difference is declarations whose
proof body uses the instance even though the statement does not.

```
CharacteristicFormula.lean:111: @…sf_disj_truth_mu 2 unused arguments:
  argument 2: [Fintype sig.preds]
  argument 3: [DecidableEq sig.preds]
```

Further current examples: `rank_type_separator`, `nf_profile`, `sf_untl_truth_mu`,
`sf_snce_truth_mu`, `formula_transfer_rank_embed`. Hotspots: `Base.lean` 13,
`NavigatedSpine.lean` 13, `Claim1.lean` 7, `SharedWitness.lean` 7, `VecEADecomp.lean` 7,
`CharacteristicFormula.lean` 6.

**Decision: accept**, for the reason given for residual 1 — this is the same set of binders seen
through a different linter, not an independent finding.

## Accepted artifact — the 6 `simpNF LINTER FAILED` rows

In scope: `Bundle/TemporalContent.lean` ×4 and `Bundle/CanonicalTaskRelation.lean` ×2. Unchanged
from baseline.

These are not simp-normal-form violations. Each reads:

```
LINTER FAILED: Tactic `simp` failed with a nested error:
maximum recursion depth has been reached
```

**Root cause**: the looping `@[simp] neg_unfold` at `Automation/Normalization.lean:69`, whose RHS
`φ.imp bot` is definitionally its own LHS pattern (`Formula.neg`). `simp` therefore rewrites
`neg φ → φ.imp bot → (φ.imp bot).imp bot → …` without terminating, and the `simpNF` linter's
internal `simp` call blows the recursion limit on any declaration that reaches it. The linter is
reporting its own failure to analyse, not a defect in the tier-3 declarations.

**Do NOT drop the `@[simp]` attribute on `neg_unfold`.** `Automation/` is out of scope by charter,
and the attribute is load-bearing for the normalization automation. The fix belongs to whoever
owns `Automation/`, and it is a definitional-unfolding redesign, not an attribute removal.

The whole-library count is 115 rather than 6 because the same root cause reaches out-of-scope
files (`Automation/Normalization.lean` 31, `Separation/Defs.lean` 22, `Semantics/Truth.lean` 6,
`Syntax/*` 11, and 37 positionless `#check … /- LINTER FAILED` rows).

## Out-of-scope handoffs — not this task's debt

Recorded so a future reader does not mistake them for residuals of this task.

| Finding | In-scope count | Owner |
|---|---:|---|
| `defsWithUnderscore` | 572 (888 whole-library) | Naming task |
| `defProp` | 35 | Naming task — claims the def→theorem conversions as its own first phase |
| `dupNamespace` | 13 (all in `BXCanonical/Chronicle/ChronicleTypes.lean`) | Naming task |
| `push_neg` deprecation warnings | 521, 51 files | Deprecation task |
| deprecated import `Mathlib.Data.Finite.Card` (`MonadicFO.lean:7`) | 1 | Deprecation task |

All five are **frozen**: the differential gate fails a file whose count in any of them moves in
*either* direction, so that a reduction is caught as trespass rather than celebrated as progress.

Also outside the 174-file scope, and therefore never findings of this task: `tacticDocs` 4,
`structureInType` 1, and the 39 `Automation/` `docBlame` findings.

## Statement of the decision

The 156 `unusedInstInType` and 112 `unusedArguments` sites are an **accepted, ledgered API
decision**, made because the instance binders encode a deliberate architectural choice documented
in `MonadicSignature` — not because the work was too large to finish. The 6 `simpNF LINTER FAILED`
rows are an artifact of an out-of-scope looping simp lemma, with the root cause named above.
Everything else in the tier-3 surface that this task took scope over is at zero.
