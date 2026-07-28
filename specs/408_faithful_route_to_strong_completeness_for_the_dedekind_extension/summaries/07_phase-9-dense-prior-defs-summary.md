# Phase 9 Summary — `SemanticPriorU` / `SemanticPriorS` and the dense-flow vacuity witness

- **Plan**: `plans/07_strong-completeness-dedekind-v7.md`, Phase 9 (Block D, wave 1)
- **Status**: `[COMPLETED]`
- **Owned file**: `FormalSystem/Metalogic/WeakCanonical/PriorDefsDense.lean` (new, 408 lines)
- **Also touched**: `FormalSystem/Metalogic/WeakCanonical.lean` (one import line, so the new
  module is CI-reachable from `FormalSystem.lean`)

## What landed

Eleven new declarations, all sorry-free and axiom-clean.

| Declaration | Content |
|---|---|
| `SemanticPriorU` | Semantic reading of Prior-U, `U(⊤,p) ∧ F¬p → U(¬p ∨ K⁺(¬p),p)`, at every point and every `Formula` |
| `SemanticPriorS` | The past mirror, with `K⁻` |
| `FlowGLB` / `FlowLUB` | Dedekind completeness of the flow as an explicit `Prop` on the structure's own order |
| `semanticPriorU_of_flowGLB` | **Every** flow with greatest lower bounds satisfies `SemanticPriorU`, for every interpretation and every formula |
| `semanticPriorS_of_flowLUB` | The `sSup` mirror |
| `semanticPriorUZ_fails_of_interval_witness` | **Exclusion lemma**: on any densely ordered flow, `SemanticPriorUZ` fails as soon as one formula holds throughout one nonempty open interval |
| `densePriorSig`, `realFlowStructure`, `densePriorAtomMap`, `realFlowStructure_flowGLB/_flowLUB/_dense`, `temporalTruth_realFlowStructure_atom` | The `ℝ`-carrier witness apparatus |
| `denseRayFlow`, `denseWindowFlow` | The two concrete witnesses: predicate true exactly on `(0,∞)`, resp. exactly on `(0,1)` |
| `semanticPriorUZ_fails_on_dense` | **Anti-vacuity part 1 (negative)**: `SemanticPriorUZ` refuted on the dense ray |
| `semanticPriorU_of_dense_ray`, `semanticPriorS_of_dense_ray` | **Anti-vacuity part 2 (positive)**: the same structure satisfies both dense hypotheses |
| `semanticPriorU_not_implies_semanticPriorUZ` | **Rule 6**, machine-checked: one structure satisfying `SemanticPriorU ∧ SemanticPriorS ∧ ¬SemanticPriorUZ` |
| `denseRayFlow_pred_nontrivial`, `semanticPriorU/S_of_dense_window`, `densePriorU_antecedent_reachable` | Non-triviality of the predicate; the Prior-U antecedent actually satisfied on the window flow |

## Anti-vacuity gate

All three admissible forms are present, not just the minimum one:

1. **Witness** — `denseRayFlow` and `denseWindowFlow` satisfy `SemanticPriorU` and `SemanticPriorS`
   with a predicate that is neither empty nor the whole carrier, on a densely ordered carrier.
2. **Derivation** — `semanticPriorU_of_flowGLB` derives the hypothesis for every Dedekind-complete
   flow, so the class of models is large rather than a single hand-built example.
3. **Exclusion lemma** — `semanticPriorUZ_fails_of_interval_witness` names exactly what the
   *integer* hypothesis admits and forbids, which is the content of the Block D re-base.

Additionally `densePriorU_antecedent_reachable` shows the Prior-U antecedent is satisfiable on a
witness, so `SemanticPriorU` is not discharged there by an empty antecedent.

## Verification

| Gate | Result |
|---|---|
| Scoped build | `lake build FormalSystem.Metalogic.WeakCanonical.PriorDefsDense` — "Build completed successfully (1097 jobs)" |
| Full build | `lake build` — "Build completed successfully (1909 jobs)", no errors |
| Sorry census (outside `Boneyard/`) | exactly `FormalSystem/Metalogic/WeakCanonical/Transfer.lean:1242` — unchanged |
| `#print axioms`, all 11 new declarations | `[propext, Classical.choice, Quot.sound]`; `semanticPriorUZ_fails_of_interval_witness` needs only `[propext]` |
| Regression canaries | `completeness_dense`, `completeness_discrete`, `countermodel_discrete_reynolds_v2` — all `[propext, Classical.choice, Quot.sound]`, unchanged |
| Frozen files | `ChronicleTypes.lean`, `ChronicleToCountermodelBasic.lean`, `ChronicleConstruction.lean`, `CounterexampleElimination.lean`, `PriorDefs.lean`, `DedekindINF.lean`, `PriorINF.lean` — byte-identical (`git diff` empty) |
| Territory | Nothing under `Metalogic/Decidability/` or `Automation/` read for edit, modified or staged |
| Vacuous definitions | none (`def X := True` etc. absent) |
| Task-number citations outside `specs/` | none |

## Citation verification (honesty charter Rule 2)

Both printed pages used in the module's docstrings were re-verified against
`Literature/sources/reynolds_1992/Reynolds_1992_Axiomatization_Until_Since_without_IRR.pdf`
in this dispatch, not carried:

- **printed p.168 = PDF page 4** — confirmed. The axioms appear there verbatim as
  `Prior-U: U(⊤,p) ∧ F¬p → U(¬p ∨ K⁺(¬p),p)` and `Prior-S: S(⊤,p) ∧ P¬p → S(¬p ∨ K⁻(¬p),p)`,
  followed by *"It is clear that all these axioms are valid over the reals."*
- **printed p.176 = PDF page 12** — confirmed. The Prior-structure definition and Theorem 3 appear
  there, including *"Note that this result does not hold for the original Prior axioms in the
  language of `F` and `P`."*
- **printed p.169** additionally supplies *"The axioms are valid in structures over the reals
  because there are no gaps at all so no definable ones"* — the source sentence for the
  Dedekind-complete-flow theorem's statement. Reynolds gives no proof of it, so the module's
  docstring records the greatest-lower-bound derivation as original glue on a sourced statement.

No correction to the plan's Source-to-Implementation Mapping was needed for the Phase 9 rows.

## Design notes (not deviations)

- **Negations are read at the metalevel** (`¬ TemporalTruth …`) rather than through
  `Formula.neg`. The two agree — `temporal_truth_neg` (`Kamp/Translation.lean:47`) — and reading
  them metalevel keeps this module's only in-tree import at `PriorDefs.lean`, avoiding an import
  edge into the `Kamp/` subtree from a defs module. Phase 10 converts with that one lemma; the
  conversion is exercised in the probe below and costs three rewrites.
- **Flow completeness is an explicit `Prop`**, not a typeclass, matching `ValidDedekindDense`
  (`Semantics/Validity.lean:255`) and `real_lub_of_bddAbove`
  (`BXCanonical/CompletenessDedekind.lean:127`). This avoids transporting a
  `ConditionallyCompleteLinearOrder` along `OrderedMonadicStructure.carrierOrder`.
- **Completeness is sufficient, not necessary.** The `ℚ`-flowed chronicle this development
  ultimately consumes is a Prior structure because the axioms are valid in the canonical model
  (Reynolds §4 Cor 1), not because its flow is complete. The module docstring says so, so that no
  later dispatch mistakes the witness route for the intended route.

## Findings for Phase 10 (route-critical)

Two facts established as `lean_run_code` probes against the landed witnesses. **Neither is in the
tree** — `DedekindINFDense.lean` is Phase 10's owned file and was not created here.

1. **`HasDedekindINF` as literally stated is false on a dense Prior structure.**
   `denseWindowFlow` satisfies `SemanticPriorU` and `SemanticPriorS` (landed theorems) and refutes
   `HasDedekindINF denseWindowFlow densePriorAtomMap`. Counterexample: `P` the atom, `z₀ = 1/2`,
   `z₁ = 1`. `P` occurs in `(z₀,z₁)`; the left disjunct `kplus P z₀` fails because `kplus`
   (`PriorINF.lean:86`) demands `¬P(z₀)` while `P(1/2)` holds; the right disjunct fails because it
   demands a `P`-free interval `(z₀,r₀)`, unavailable on a dense flow when `P` holds throughout
   `(z₀,z₁)`. The gap is exactly Rabinovich's `r₀ = z₀` subcase **with `P` true at `z₀`**, which
   this tree's `kplus` cannot express.
2. **With the endpoint guard `¬TemporalTruth M atomMap z0 P`, the plan's Phase 10 skeleton (steps
   1-6) goes through verbatim from `SemanticPriorU` alone** — verified generically in `sig`, `M`,
   `atomMap`, using no completeness and no attainment, translating at `p := P.neg` through
   `temporal_truth_neg`.

So the crux is reachable, but `prior_hasDedekindINF_dense` cannot conclude in bare
`HasDedekindINF`. A note recording both facts was added under the plan's Phase 10 heading.
