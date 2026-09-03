# Implementation Summary: Generic Consequence / Compactness / Strong-Completeness Theorems

- **Task**: 524
- **Plan**: `specs/524_consequence_compactness_generic_theorems/plans/01_generic-consequence-compactness-theorems.md`
- **Status**: COMPLETED (Phase 10 closed as `[COMPLETED WITH EXCLUSIONS]`)
- **Phases**: 11 of 11 closed
- **Session**: sess_1788416566_823cec

## What landed

The theorem layer of the consequence/compactness/strong-completeness stack is now generic in
`FrameClass`. The three textbook facts that were missing as declarations are named, and the
per-class layer is a set of one-line instantiations.

**New generic vocabulary**
- `WeakCompleteness fc` (`SetConsequence.lean`) — the single-formula completeness statement the
  tree had been writing out longhand as an `engine` hypothesis at three sites.
- `PointedModel fc Γ` — a seven-field structure replacing the anonymous existential chain;
  `SatisfiableSet fc Γ` is now `Nonempty (PointedModel fc Γ)`.
- `FinitelySatisfiableSet fc Γ`, `TMComplete fc`, `Forward fc`.

**New generic theorems**
- `semantic_deduction_in`, `soundness_consequence`, `consequence_completeness_of_engine`
- `strongCompleteness_iff_compact (engine : WeakCompleteness fc)` and
  `compact_iff_modelExistence` — the two named iffs the task asked for
- `compact_of_strongCompleteness`, `modelExistence_of_compact`
- `setConsequence_of_not_satisfiable`, `setConsequence_iff_not_satisfiable`
- `not_compact_of_witness`, `not_strongCompleteness_of_witness` — the shared refutation skeleton
- `modelExistence_of_satPreserved` with the `sat_ofModel_frame` bridge
- `satisfiableSet_iff_finitelySatisfiable`, `modelExistence_iff_finitelySatisfiable`,
  `SatisfiableSet.mono`, `PointedModel.mono`, `PointedModel.of`
- `tmComplete_iff_forward`, plus the two free rows `.Dense` and `.Dedekind` it yields
- `qAlpha_step`, `exists_strictMono_qPoints` extracted out of `dedWitness_core`
- `modelExistenceDedekind_refuted` — the corollary the tree had declined to draw
- `@[simp] mem_archWitness_iff`, `@[simp] mem_dedWitness_iff`

**Structural work**
- `FormalSystem/Metalogic/Conservativity/` created, holding `Backward.lean` (the old body),
  `BaseLanguageSoundness.lean`, `TMCompletenessReduction.lean`, `SpWitness.lean`,
  `Z1Countermodel.lean`, under a sibling aggregator carrying the prohibition narrative.
- Twelve dead `SetConsequence` declarations and the `Core.MaximalConsistent` import deleted.
- The `not<PropName>` naming scheme adopted: `notCompactDiscrete`, `notCompactDedekind`,
  `notStrongCompletenessDiscrete`, `notStrongCompletenessDedekind`.
- 48 `#print axioms` directives migrated from four modules into the C14 heredoc pair in
  `scripts/check-module-invariants.sh`; exactly five in-file directives remain, on the five
  termini.

## Verification

| Check | Result |
|-------|--------|
| `lake build` | green, 2522 jobs |
| `scripts/check-module-invariants.sh` | ALL CHECKS PASSED (18 PASS rows) |
| Structural sorries under `FormalSystem/` | 0 (C3) |
| New axioms | 0 — `^axiom ` count is 7 before and after |
| Vacuous definitions | none introduced |
| Per-class copies of the deduction theorem | 0 of 4 (all instantiate `semantic_deduction_in`) |
| Per-class copies of the soundness guard | 0 of 4 (all instantiate `soundness_consequence`) |
| Per-class model-existence proofs | 0 of 2 (both instantiate `modelExistence_of_satPreserved`) |
| Per-class refutation skeletons | 0 of 4 (all instantiate the shared skeleton) |

Axiom profiles are `[propext, Classical.choice, Quot.sound]` throughout, with four literal
exceptions carrying strict *subsets*, recorded rather than rounded up:
`setConsequence_of_not_satisfiable`, `satisfiableSet_iff_finitelySatisfiable` and
`modelExistence_iff_finitelySatisfiable` are `[propext]`; `qDepth_qAlpha` is
`[propext, Quot.sound]`.

## The line-count acceptance criterion was not met

The task and plan projected a net removal of roughly 230 lines. The measured figure across the
five collapsed Metalogic modules is **+245 net** (+803/-558). Splitting by line kind: prose
+509/-271 (net +238), executable code +290/-274 (net **+16**). The four-fold duplication is
genuinely gone — the per-class-copy counts above are all zero — but the ~18 new generic
declarations cost about what the copies returned, and the docstrings explaining the collapse cost
more than the false docstrings they replaced. The collapse bought a single point of proof and a
single point of failure, not a smaller file.

## Plan Deviations

Each is annotated inline on the corresponding plan checklist item.

1. **Phase 2** — the `¬X^(n+1) p` extraction site in `archWitness_not_satisfiable` keeps an
   explicit witness rather than plain `simp`: `simp` rewrites `next^[n+1] φ` to `next^[n] φ.next`
   in the goal but not under the existential binder.
2. **Phase 3** — `{fc : ProofSystem.FrameClass}` written qualified; `Compactness.lean` does not
   open `FormalSystem.ProofSystem`.
3. **Phase 5** — `modelExistenceDedekind_refuted` is homed in `DedekindNonCompactness.lean`, not
   `SetConsequence.lean` as the plan's file list says. It consumes `notCompactDedekind`, and that
   module imports `SetConsequence.lean`; the planned placement is an import cycle.
4. **Phase 6** — a new `import FormalSystem.Metalogic.StrongCompleteness` was required on
   `TMCompletenessReduction.lean`.
5. **Phase 7** — `modelExistence_of_satPreserved`'s `choose` needed rewriting to
   `Nonempty.some` + field projections. The plan's six named destructuring sites did all compile
   unchanged, as predicted; this was a seventh site, created by Phase 3, that `choose` could not
   handle once `SatisfiableSet` stopped being an `∃`-chain.
6. **Phase 8** — the citation sweep was scoped to non-`specs/**` files; `specs/**` artifacts are
   historical records, and no invariant reads them.
7. **Phase 9** — the plan says 13 dead declarations and lists 12; the list is right. All 12 were
   re-measured as having zero external consumers and deleted. `SetSemanticConsequence{Discrete,
   Dedekind}` were kept as instructed even though Phase 5 removed their last consumers.
8. **Phase 10** — neither old refutation name occurs in `scripts/check-module-invariants.sh`, and
   `FormalSystem/Metalogic/README.md` does not exist; both plan premises were wrong, so neither
   edit was made.
9. **Phase 11** — all 48 migrated entries went into the C14 pair, none into C2, to preserve C2's
   documented "four flagship theorems" meaning.

## Two items needing the user's attention

1. **Phase 10 exclusion.** One occurrence of the old name `discrete_consequence_not_compact`
   remains, in `FormalSystem/Semantics/Ultraproduct/Carrier.lean` docstring prose.
   `FormalSystem/Semantics/` is task 525's territory and this plan forbids writing there. No
   invariant covers it (C5/C12/C13 are markdown-only), so the gate stays green. One-line
   follow-up for whoever holds that file next.

2. **Six files under `FormalSystem/Semantics/` were modified**, against the plan's Non-Goals —
   `BLSchemaValidity.lean`, `BLTruth.lean`, `BLValidity.lean`, `DurationClassification.lean`,
   `LexCarrier.lean`, `README.md`. The plan is internally inconsistent here: Phase 8 requires
   every file citing the five moved paths to be swept, and these six do. **Every change is a
   docstring path string; no Lean code was touched**, verified by reading the entire diff over
   that directory. `FormalSystem/Semantics/Correspondence/`, the directory the Non-Goal names
   explicitly, is untouched. Flagged for task 525.
