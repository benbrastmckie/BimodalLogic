# Phase 11.33 handoff — the repaired gap clip: outcome (a), REFUTED

**Status**: Phase 11.33 `[COMPLETED]` (plan v24, dispatch 68).

**Immediate next action**: close Phase 11.35 `[COMPLETED WITH EXCLUSIONS]` (its own entry
condition, on this outcome); then a `/revise` — the repaired clip of Ruling 10 is wrong and the
derivation phases are built on it.

**Current state**:
- `specs/evidence/seam-gluing-ray-product/ladder-cell-agreement-refutation.lean` (3343 lines)
  carries a fifth section, appended: `Kc`, `lvlC`, `dblC`, `nxt_le_double`, `lvlC_false`,
  `lvlC_true`, `dblC_mem`, `dblC_not_mem`, `dblC_cell_ne`, `ParamsOkRep`, `paramsOkRep_params`,
  `gap_clip_below_exponential_refuted`, `repaired_clip_refuted`. Zero `sorry`.
- Headline: for every `j ≥ 3`, `dblC j` (`dBack = j`, `dFwd = 3`, repaired clip `2 j + 8`)
  separates the gap `2 ^ (j + 1) - 1` from the gap one modulus above it, a `kappa`-collision at
  the repaired parameter conditions. And at every clip `B < 2 ^ (j + 1)`, every `Tc`, `Tn`, `P`.
- All gates green: guarded `lake build` (2976 jobs), `build BimodalTest` (3044 jobs),
  `check-module-invariants.sh`, `readme-lint.sh`, `check-evidence-probes.sh` (65 probes),
  `typst-sync-check.sh`, `verify-deploy.sh` (15 checks).

**Key findings**:
- The mechanism is the idle register's doubling across one region read BACKWARDS through `⊡`
  (`nxt_le_double`): one `snce` at the guard `p` per doubling. It is the same doubling `(K2)`'s
  cascade bound iterates.
- No clip polynomial in `dBack`, `dFwd` works: `F (a, 3) ≥ 2 ^ (a + 1)`.
- Not known: whether a clip exponential in `dBack` makes the agreement true.

**Deviations**: no `sorry`-bodied intermediate was committed; `LadderStepFrag.lean`'s docstring,
the RaySummary README row and a comment row of `scripts/check-evidence-probes.sh` were amended
because each asserted the refuted clip as a conjecture; three README inventories and
`typst/generated/status.typ` regenerated.

**Record**: `records/round-24-repaired-clip-verdict.md`.
