# Research Report: Task #972

**Task**: 972 - Theorem library: tableau pipeline
**Started**: 2026-11-23T20:54:00Z
**Completed**: 2026-11-23T22:05:00Z
**Effort**: large (one command spanning five stages; one missing metalogical prerequisite; two gate collisions)
**Dependencies**: `theorem_library_layout_and_registry` (landed: `BimodalLib/Registry.lean`, `Fragment.lean`, `Conjecture.lean`, `Index.lean`), `proof_mode_axiom_audit_and_cost_baseline` (landed: `BimodalLib/Diagnostics/Record.lean` with the five reserved stages, `scripts/proof-mode-cost-baseline.sh`)
**Sources/Inputs**:
- Codebase: `BimodalTools/` (enumerator, canonicalization, interestingness, dataset generator, tableau bridge, certificate import), `BimodalLib/` (registry, fragment, conjecture, index, diagnostics), `FormalSystem/Metalogic/Decidability/` (decision procedure, extraction, verified bridge, witness families), `FormalSystem/PlusLanguage/Substitution.lean`
- Design records: `records/theorem-library.md`, `records/proof-mode.md` (M19), `docs/reference/bimodal-lib.md`, `docs/reference/diagnostics.md`
- Measured data: `data/bmlogic-c4.jsonl` … `data/bmlogic-c7_metadata.json`, `data/exhaustive_c4_metadata.json`
- lean-lsp MCP: not used; evidence is from compiled probes (`lake env lean`) and source reads, which is the stronger tier for every claim below
**Artifacts**:
- `specs/972_theorem_library_tableau_pipeline/reports/01_tableau-pipeline-into-library.md`
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **The ADMIT stage has one hard missing prerequisite, and it is not in the task description.**
  `TheoremEntry.proof` has type `∀ fc, frameClass ≤ fc → ∀ v, DerivationTree fc [] (stmt v)` —
  every registry row is schematic in all its arguments **by construction**. The tableau extracts
  a derivation of a *concrete* formula over concrete atoms. Going from one to the other needs a
  `Formula → Formula` uniform substitution **as data** on `DerivationTree`, and no such thing
  exists anywhere in the tree: only the L→L⁺ pair `substPlus` / `PlusDerivationTree.ofTMSubst`.
  I built the missing L-level mirror and ran the real admission gate on it: it compiles sorry-free
  and `register_theorem` **accepts** the generalized row. This is the pipeline's critical path.
- **The quoted yield overstates the theorem half by about eight times.** Of the 17 `valid`
  formulas at complexity 4 over Base, **15 were decided by the structural prefilter and carry no
  derivation at all**; only 2 have a `proof_trace`. The same ratio holds at every measured bound
  (c5: 8 of 100; c6: 42 of 790). M19's own "Done when" admits only "each valid formula **with an
  extracted derivation**", so the admissible theorem yield at complexity 4 is **2 formulas**, not 17.
- **Proof extraction is Base-only.** `extractProof` ignores its frame-class argument (`_fc`) and
  `ProofExtractionResult.success` is hard-coded to `DerivationTree .Base`. The frame-class axis
  therefore moves only the *countermodel* half; "at each frame class the tableau accepts" buys
  nothing on the theorem half beyond `Base`.
- **Recommended ruling on open decision 3**: complexity **5** for `Boolean` and `ModalBoolean`,
  complexity **4** for `TemporalBoolean` and `ModalTemporalBoolean`; `Base` only for the theorem
  half, all four frame classes for the countermodel half; and **keep every non-subsumed theorem,
  with no interestingness filter**. The interestingness measure has no discriminating power at
  these bounds — at complexity 6, 628 of the 790 valid formulas land in the single tier `routine`
  and 153 in `trivial`, with 5 `basic`, 3 `moderate` and 1 `notable` in total.
- **Two gate collisions, both mechanically verified.** (1) `scripts/proof-mode-cost-baseline.sh`
  pins a measured surface that *includes the directory* `BimodalLib/Diagnostics`; adding the five
  reserved-stage emitters there makes the cost baseline stale (verified: exit 3, "STALE
  BASELINE"). (2) That directory is the **Evaluation** lane's territory in
  `records/proof-mode.md`, not the Library lane's, while `records/theorem-library.md`'s Layout
  section nonetheless plans `BimodalLib/Diagnostics/` as the emitters' home. Siting the pipeline
  emitters in the Library lane's own territory resolves both at once.
- **The eight gates are already implemented and directly callable.** `BranchGates` /
  `gatesOfBranch` / `evalBranchGates` in `BimodalTools/TableauBridge.lean` evaluate exactly the
  eight hypotheses of `not_valid_of_hasOpen_int` as Bools, with JSON emission. The CERTIFY stage
  for the gated-refutation grade is a function call, not new work. All four frame classes have a
  gate theorem taking the identical eight-hypothesis bundle.

## Context & Scope

What was researched: whether the five stages of `records/theorem-library.md` (enumerate, decide,
extract, certify, admit) can be assembled from existing `BimodalTools`/`FormalSystem` machinery
without rebuilding it; what is genuinely missing; what the yield is at each candidate complexity
bound, per fragment and frame class; and which record schema and gate obligations the work must
satisfy.

Constraints taken as given and checked against the tree:

- `BimodalLib` imports `FormalSystem`; `FormalSystem` never imports `BimodalLib` (check `B3` of
  `scripts/check-module-invariants.sh`). Verified: `B3` bars only
  `FormalSystem → BimodalTools|BimodalLib`. **`BimodalLib → BimodalTools` is ungated and does
  not exist today** — introducing it is an open design choice the plan must make explicitly.
- Nothing in `BimodalLib` contains `sorry`, a new `axiom` or `native_decide`.
- The task adds no rule and edits no proof-mode file.
- Certified refutations are written in the form `theorem_library_countermodels` (M20) will read,
  and are not yet admitted.

Out of scope and confirmed so: `⊡`. The decision procedure is over `Formula`, which has exactly
six primitives (`atom, bot, imp, box, untl, snce`); `⊡` lives only on `PlusFormula`. So
**every** formula the enumerator produces is already in the `□`-only cell, and `profileF` can
never set `stab` on it. The "cells whose operator set is within `□`" restriction needs no
enforcement code — it is automatic — and `maxModalDepth := 0` must **not** be used to express it,
since `◇` is a defined operator gated on the same modal budget as `□`.

## Findings

### Codebase Patterns

**What exists and is directly reusable (stage by stage).**

| Stage | Reusable now | Path |
|---|---|---|
| Enumerate | `EnumConfig`, `enumExactHelper` (memoized, cache key `(size, modal, temporal)`), `enumerateUpToDepth`, `structurallyTrivial` pruning, checkpoint/resume | `BimodalTools/FormulaEnumerator.lean:83,161,374,138` |
| Enumerate | `collectAtomsDFS`, `canonicalAtomMap`, `applyAtomMap`, `canonicalize`, `deduplicateCanonical` — one representative per atom renaming, linear per formula, measured 4.58× reduction at c7 | `BimodalTools/AtomCanonicalization.lean:64,88,102,119,130` |
| Decide | `decideAuto φ fc`, `decide`, `decideAutoAdaptive`, `soundFuel` | `FormalSystem/Metalogic/Decidability/DecisionProcedure.lean:365,174,385`; `Saturation.lean:1212` |
| Extract | `extractProof`, `ProofExtractionResult`; countermodel side `extractCountermodelSimple` / `extractCountermodelBlocked`, `EnrichedCountermodel` | `.../ProofExtraction.lean:236,260`; `.../CountermodelExtraction.lean:873,887` |
| Certify (gated tableau) | `BranchGates` (8 Bools), `BranchGates.gated`, `BranchGates.toJson`, `gatesOfBranch`, `evalBranchGates` | `BimodalTools/TableauBridge.lean:307,342,347,365,389` |
| Certify (ZTime certificate) | `decidableCertifies`, `refutes_of_certifies`, `checkCertified`, `lake exe check_certificate` | `.../WitnessFamily/Decide.lean:936`; `.../WitnessFamily/Agreement.lean:269`; `BimodalTools/CertificateImport.lean:459` |
| Admit | `register_theorem`, `TheoremEntry`, `Conjecture` + `ConjectureStatus` (`heuristicallyRefuted`, `undetermined` already present) | `BimodalLib/Registry.lean:48,168`; `BimodalLib/Conjecture.lean:32,55` |
| Diagnostics | `Stage` (7 stages), `Head` (6 fields), `Stage.reservedKeys` for the five unimplemented stages; the stamp-option route (`-Ddiagnostics.commit=…`), `diagnostics.zeroTimings` | `BimodalLib/Diagnostics/Record.lean:64,159,122`; `Emit.lean:103-126` |
| The command's own shape | staleness pin before measuring, `flock` on `.lake/build-guard.lock`, `--json` zeroed determinism contract, dataset + `_metadata.json` sidecar, field-set agreement parsed from the reference page | `scripts/proof-mode-cost-baseline.sh` |

**The five gaps, in order of cost.**

1. **No `Formula → Formula` uniform substitution, at data level or Prop level.** The only
   substitution machinery in the tree goes L→L⁺: `substPlus` (`FormalSystem/PlusLanguage/Substitution.lean:86`),
   `PlusAxiom.ofTMSubst` (`:155`), `PlusAxiom.minFrameClass_ofTMSubst` (`:184`),
   `PlusDerivationTree.ofTMSubst` (`:199`), `plusDerivable_substPlus{,_nil}` (`:222,229`).
   `BimodalTools/AtomCanonicalization.lean` is an atom→**atom** renaming with no derivability
   transfer attached — correct for ENUMERATE, useless for ADMIT. A Prop-level route through
   `plusDerivable_substPlus_nil` plus the proved L-into-L⁺ edge
   (`plusDerivable_ofFormula_iff`) would land in `Derivable = Nonempty (DerivationTree …)`
   (`FormalSystem/ProofSystem/Derivable.lean:69`), i.e. a `Prop`, from which `TheoremEntry.proof`'s
   `Type`-valued field cannot be recovered except through choice — and `addTheoremEntry` calls
   `addAndCompile` on the row.
2. **The whole ADMIT stage.** No subsumption matcher exists: nothing in `FormalSystem/`,
   `BimodalTools/`, `BimodalLib/`, `Tests/` or `scripts/` decides whether one formula is a
   substitution instance of another. The two near misses are false friends —
   `matchAxiom`/`matchDerived` (`FormalSystem/Automation/ProofSearch/Core.lean:328,1049`) are
   hand-written per-schema shape tests with local equality checks on repeated metavariables, and
   `isSubsumptionPattern` (`BimodalTools/DatasetGenerator.lean:541`) recognizes *validity*
   patterns such as `□φ → φ` as a prefilter and has nothing to do with entry subsumption.
3. **No `DerivationTree` leaves any existing process.** Every consumer collapses it immediately:
   `walkDerivationTree` → `RuleProfile` (`BimodalTools/DataExport.lean:337`), `extractProofTrace`
   → height + names (`DatasetGenerator.lean:301`), `extractStepSequence` → `List ProofStep`
   (`ProofStepExtractor.lean:212`). In `DatasetGenerator.lean:1208-1218` the tree is bound as
   `proof` and discarded on the next line. The one place a live tree is retained is
   `ForwardProofGenerator.lean:81`'s `ProofPool`, whose
   `entries : Array (Sigma fun φ => DerivationTree fc [] φ)` is the natural in-process carrier
   shape for the EXTRACT stage — and it never crosses a process boundary.
4. **No fragment awareness in `BimodalTools`.** `grep` for `profileF|profileP|Fragment|fragment`
   across `BimodalTools/*.lean` returns zero hits. Fragment selection *is* expressible through
   the two depth budgets (`maxModalDepth := 0` for `TemporalBoolean`, `maxTemporalDepth := 0` for
   `ModalBoolean`, both zero for `Boolean`), but nothing proves that encoding agrees with
   `profileF`. A post-hoc `BimodalLib.profileF` filter is the honest form. Hazard:
   `passesFilter` (`FormulaEnumerator.lean:780`) additionally requires `complexity ≥ 3` **and** at
   least one of `box`/`untl`/`snce`, so applying it on a `Boolean` run deletes the whole fragment.
5. **The four-way verdict is flattened to three.** `DecisionResult` has
   `.valid/.invalid/.fuelExhausted/.extractionFailed`
   (`DecisionProcedure.lean:80`), but `FormulaLabel` has only `valid/invalid/timeout`
   (`DatasetGenerator.lean:155`) and groups the last two into one arm (`:1251`), the distinction
   surviving only in the `decision_method` string (`adaptive_timeout` vs
   `adaptive_extraction_failed`). The pipeline needs them separate, because `extractionFailed` is
   **not** epistemically level with `fuelExhausted`: `isUndecided` holds of `fuelExhausted` only,
   and `isKnownValid` holds of `extractionFailed` — the tableau closed, the formula *is* valid,
   and no witness was found. The task description groups both as "registered as a conjecture",
   which is safe but discards that distinction; `ConjectureStatus` has no value for
   "known valid, no term", and `undetermined`'s own docstring already covers both ("ran out of
   fuel or failed to extract a certificate").

**The complexity measure, which is the load-bearing fact for stating a bound.**
`Formula.complexity` (`FormalSystem/Syntax/Formula.lean:225`) is **pattern-aware**: `atom`/`bot`
cost 1, and each *recognized derived* operator costs 1 over its argument — `always φ` matches a
20-node primitive pattern and returns `1 + φ.complexity`. The enumerator mirrors this exactly
(each arm computes `childSize := sizeBudget - 1`, `:177-336`) and generates 16 derived operators
(`someFuture`, `allFuture`, `always`, `next`, `release`, `weakUntil`, `trigger`, … ) as
first-class arms beside `untl`/`snce`. So "complexity 4" means four *pattern-aware operator
layers*, which can be an order of magnitude larger as a primitive term, and the enumeration at a
bound is **not** the set of primitive terms of that size. A stated bound must say which measure
it is in.

**Measured yield by bound** (all `Base`, exhaustive, cumulative — each dataset contains the
previous one's records, confirmed by the per-`metrics.complexity` breakdown):

| Bound | Total | `valid` | with a derivation | `invalid` | undetermined |
|---|---|---|---|---|---|
| c4 | 806 | 17 | **2** | 669 | 120 |
| c5 | 6,028 | 100 | **8** | 4,772 | 1,156 |
| c6 | 39,790 | 790 | **42** | 28,694 | 10,306 |
| c7 | 1,646,512 | 49,327 | not measured | 1,378,213 | 218,972 |

Source: `data/bmlogic-c{4,5,6,7}_metadata.json` for the totals;
the "with a derivation" column is my own count of records carrying a non-null `proof_trace`
(`proof_reconstruction_method ∈ {compositional, axiom_match, proof_search}`; every
`structural_prefilter:*` route returns `proofTrace := none`). **Note**:
`data/exhaustive_c4_metadata.json` is a *different* complexity-4 run reporting 13/673/120, so
whichever figure a record quotes must name its artifact.

**Measured yield by fragment** (my own tabulation over the record files, fragment computed by the
`profileF` rule — `box`/`stab` → Modal, `untl`/`snce`/derived → Temporal):

| Bound | Fragment | Total | `valid` | `invalid` | undetermined |
|---|---|---|---|---|---|
| c4 | Boolean | 162 | 7 | 127 | 28 |
| c4 | ModalBoolean | 105 | 6 | 93 | 6 |
| c4 | TemporalBoolean | 399 | 4 | 331 | 64 |
| c4 | ModalTemporalBoolean | 140 | 0 | 118 | 22 |
| c5 | Boolean | 902 | 24 | 703 | 175 |
| c5 | ModalBoolean | 751 | 28 | 579 | 144 |
| c5 | TemporalBoolean | 2,644 | 34 | 2,135 | 475 |
| c5 | ModalTemporalBoolean | 1,731 | 14 | 1,355 | 362 |
| c6 | Boolean | 3,738 | 110 | 2,566 | 1,062 |
| c6 | ModalBoolean | 5,618 | 172 | 4,085 | 1,361 |
| c6 | TemporalBoolean | 14,834 | 297 | 10,304 | 4,233 |
| c6 | ModalTemporalBoolean | 15,600 | 211 | 11,739 | 3,650 |

The shape of it: the two *temporal* fragments carry two thirds of the enumeration and three
quarters of the undetermined verdicts, and `ModalTemporalBoolean` yields **nothing** at
complexity 4 and only 14 valid at complexity 5. The Boolean and `ModalBoolean` fragments are
where the admissible density is.

**What the admitted theorems actually are.** The complete list of 17 at complexity 4, after
reading them:

```
⊥ → ⊥            ⊥ → p            p → p            □(p → p)        □p → p
□⊥ → ⊥           □⊥ → p           □(⊥ → ⊥)         □(⊥ → p)
U(⊥,⊤) → ⊥       U(⊥,⊤) → p       S(⊥,⊤) → ⊥       S(⊥,⊤) → p
(U(⊤,⊤) → ⊥) → ⊥   (U((p→⊥),⊤) → ⊥) → p   (S(⊤,⊤) → ⊥) → ⊥   (S((p→⊥),⊤) → ⊥) → p
```

After generalization and subsumption these collapse to roughly **eight to ten distinct schemata**
(EFQ, identity, T, necessitated identity, the `□⊥` pair, the unfulfillable-until/since pair, and
the `¬G⊥` / `¬H⊥` seriality pair). This is the real size of the theorem half at the bound the
task description quotes.

**Interestingness has no discriminating power at these bounds.** Tiers of the `valid` formulas
(`InterestingnessTier.fromScore`, cut points 50/150/300/500/700/850):

| Bound | trivial | routine | basic | moderate | notable | higher |
|---|---|---|---|---|---|---|
| c4 | 16 | 0 | 0 | 1 | 0 | 0 |
| c5 | 52 | 46 | 0 | 2 | 0 | 0 |
| c6 | 153 | 628 | 5 | 3 | 1 | 0 |

A filter at any cut point either keeps essentially everything or throws away essentially
everything. Note also that the tree carries **two** interestingness scales:
`computeInterestingness` on 0–1000 (`BimodalTools/InterestingnessMetrics.lean:490`) and
`preLabelInterestingness` on 0–100 (`DatasetGeneratorMain.lean:890`), with different formulas;
only the former's Tier-1 predicates (`operatorDiversity`, `semanticNonTriviality`,
`statementSimplicity`, `modalTemporalInteraction`) are available before a derivation exists.

**The certify half.** `not_valid_of_hasOpen_int`
(`FormalSystem/Metalogic/Decidability/Verified/Bridge/IntTruth.lean:1045`) takes exactly eight
checkable hypotheses, each already a compiled `Bool` predicate or an `Option.isNone` test:

| # | Hypothesis | Compiled predicate |
|---|---|---|
| 1 | `branchOrderValid b ord = true` | `Verified/Bridge/BranchOrder.lean:149` |
| 2 | `findUnexpanded b (timeOrd := ord) = none` | `Tableau.lean:2037`, `.isNone` |
| 3 | `findClosure b fc = none` | `Closure.lean:135`, `.isNone` |
| 4 | `timeOrderTotal b ord = true` | `Saturation.lean:234` |
| 5 | `boxAnchoredCheck b = true` | `Verified/Bridge/BoxSaturation.lean:506` |
| 6 | `regionLabelCheck b ord = true` | `Verified/Bridge/RegionLabel.lean:254` |
| 7 | `temporalWitnessCheck b ord = true` | `Verified/Bridge/TemporalGate.lean:364` |
| 8 | `l₀.world ∈ b.knownWorlds` and `⟨.neg, χ, l₀⟩ ∈ b` | `b.hasNegAt φ Label.initial && b.knownWorlds.contains Label.initial.world` |

Gates 1 and 4 are not redundant — `branchOrderValid` is strictly stronger, and a cyclic time
order passes `timeOrderTotal` while failing irreflexivity, so reporting only the "named" four
would let a cyclic order read as theorem-backed. `gatesOfBranch` computes gate 2 at
`findUnexpanded`'s default `fc := .Base` **deliberately**, because that is how the theorem states
`hSat` (its explicit `fc` threads only to `hOpen`); gate 3 is at the requested class.
`evalBranchGates` re-runs `buildTableau` because `DecisionResult` discards the branch and the
`TimeOrdering` — `buildTableau` is pure and total, so the recovered branch is the one the
`.invalid` verdict came from, the same mechanism `extractCountermodelData` already relies on.

Three further facts bearing on the countermodel half:

- The same eight-hypothesis bundle gates all four classes: `not_valid_of_hasOpen_int`,
  `not_validZTime_of_hasOpen_int` (`IntTruth.lean:1073`), `not_validDense_of_hasOpen` (ℚ,
  `DenseTruth.lean:658`), `not_validRTime_of_hasOpen` (ℝ, `DenseTruth.lean:680`). One
  `BranchGates` evaluation therefore gates refutations at every class.
- `TableauBridge.lean`'s own docstring records the measurement that **at ZTime `regionLabel` and
  `temporalWitness` come back `false`** on open branches, so `gated` is `false` there today —
  which is exactly why the record routes ZTime through `decidableCertifies` instead.
- `structural_invalid_prefilter` verdicts return `constructTrivialCountermodel φ`
  (`DatasetGenerator.lean:1124`), a synthesized atom valuation, **not an open saturated branch**.
  At complexity 7 that route accounts for 492,386 of the invalid verdicts. The gates were never
  evaluated on the object that produced those verdicts, so the certify stage must re-derive the
  branch (which `evalBranchGates` does) rather than trusting the dataset label.

The ZTime certificate route: `decidableCertifies` (`WitnessFamily/Decide.lean:936`) decides
`W.Certifies t = LocalCoherentLab ∧ FulfillingLab ∧ BoxFaithful ∧ Target t`
(`WitnessFamily/Predicates.lean:132`), and `refutes_of_certifies`
(`WitnessFamily/Agreement.lean:269`) turns acceptance into `Refutes Γ Del`, a **sequent-shaped**
statement `Γ ⊭ Del` — a better fit for the record's "a countermodel entry records an inference
`Γ ⊭ φ`" than the branch-gate route, which refutes `Valid χ` for one `χ`. Trust-model caveat,
from `CertificateImport.lean`'s own docstring: the implication is kernel-checked once at build
time, the per-certificate hypothesis comes from compiled `Decidable` instances at run time, so
**this is not per-certificate kernel checking**; `rejected` is never a validity claim.

**Scale of the conjecture half, and why it needs a decision.** `BimodalLib/Index.lean:357`'s
`renderConjectures` walks `env.constants` and keys on `ci.type.isConstOf ``Conjecture` — **one
constant per conjecture**. A literal reading of "every other outcome is registered as a
conjecture" means ~790 new constants at complexity 4 and ~5,900 at complexity 5, each needing a
docstring (`lake exe runLinter BimodalLib` requires one on every declaration, generated rows
included) and each adding a row to `BimodalLib/INDEX.md`. A `List Conjecture` would be invisible
to the index.

### External Resources

No Mathlib lemma is needed. Every missing piece is a mirror of a declaration already in this
tree. The Mathlib-side dependencies the construction actually used are `List.mem_map_of_mem` and
`List.mem_map`, both already imported wherever `PlusDerivationTree.ofTMSubst` lives.

Declarations whose exact signatures the plan will need, verified by reading the source:

- `FormalSystem.ProofSystem.DerivationTree` — 7 constructors: `axiom`, `assumption`,
  `modus_ponens`, `necessitation`, `temporal_necessitation`, `time_reflection`, `weakening`
  (`FormalSystem/ProofSystem/Derivation.lean:91`).
- `FormalSystem.ProofSystem.Axiom` — 20 constructors, of which three are parameter-free
  (`serial_future`, `discrete_box_necessity`, `dense_indicator`) and so substitution-invariant
  (`FormalSystem/ProofSystem/Axioms.lean:176-421`).
- `FormalSystem.Syntax.Formula.reflectTime` (`Formula.lean:644`) and
  `Formula.reflect_time_involution` (`:658`) — needed for the `time_reflection` case.
- `BimodalLib.schemaVar i = .atom (Atom.mkFresh "p" i)` (`Registry.lean:44`) — the canonical
  schema variables **are atoms**, which is what makes the generalization land in the registry's
  own convention.

### Recommendations

1. **Build the L-level uniform substitution first, as its own phase, and site it in
   `FormalSystem/ProofSystem/` (not under `FormalSystem/Theorems/`, so
   `assert_registry_complete` does not demand a row for it).** Five declarations, each a direct
   mirror of its L⁺ counterpart: `substF : (Atom → Formula) → Formula → Formula`;
   `substF_reflectTime`; `Axiom.ofSubst` (20 arms, every one `rfl`-shaped);
   `Axiom.minFrameClass_ofSubst` (`cases ax <;> rfl`);
   `DerivationTree.subst : DerivationTree fc Γ φ → DerivationTree fc (Γ.map (substF σ)) (substF σ φ)`
   (7 cases) and its `substNil` corollary at the empty context.
   **[VERIFIED: PASS — the full five-declaration construction plus an end-to-end admission was
   elaborated with `lake env lean` on a scratch probe against the built tree. All five compile
   sorry-free. A concrete derivation `□p → p` over the canonical atom `p` was generalized by
   `substNil` to the schema `fun A => DerivationTree Base [] (A.box.imp A)`, and
   `register_theorem` — the real admission gate — **accepted** it: the generated row reports
   `profile = {box := true, stab := false, temporal := false}`, `arity = 1`,
   `fragment = "ModalBoolean"`, and `#print axioms` on the generalized declaration reports
   `[propext, Quot.sound]` with no `sorryAx` and no `Classical.choice`.]**

2. **Do not route the generalization through the Prop-level L→L⁺ transfer.** The available
   composite (`plusDerivable_substPlus_nil` then `plusDerivable_ofFormula_iff`) lands in
   `Derivable = Nonempty (DerivationTree …)`, a `Prop`; `TheoremEntry.proof` is `Type`-valued
   and `addTheoremEntry` calls `addAndCompile` on the row, so recovering the tree would need
   choice and would not compile. **[No compiled gate applicable — this is a recommendation
   *against* an artifact, so there is nothing to run a gate on; the positive route is item 1,
   which was gated.]**

3. **Site the five reserved-stage emitters in the Library lane's own territory, not under
   `BimodalLib/Diagnostics/`.** `records/proof-mode.md`'s lane table gives the Library lane
   `BimodalLib/Theorems/`, `BimodalLib/Countermodels/`, `BimodalLib/Conjectures/` and
   `BimodalTools/`, and gives `BimodalLib/Diagnostics/` to the **Evaluation** lane (M13). The
   same directory is the staleness surface of `scripts/proof-mode-cost-baseline.sh`. Put the
   emitters in a new `BimodalLib/Pipeline/` (or under `BimodalTools/`), importing
   `BimodalLib/Diagnostics/Record.lean` read-only — the schema needs no edit, because `Stage`
   already carries all seven stages and `Stage.reservedKeys` already fixes all five payloads.
   **[VERIFIED: FAIL for the alternative — `scripts/proof-mode-cost-baseline.sh` was run with a
   deliberately mismatched `--pin` and exited **3** with "STALE BASELINE", confirming that its
   `SURFACE` array (`FormalSystem/Automation/ProofMode`, `FormalSystem/Theorems/ProofMode`,
   `BimodalLib/Diagnostics`, the cost probe) gates on that directory; and
   `git log -1 --format=%H -- BimodalLib/Diagnostics` is `9dedc3977…`, identical to the pin
   recorded in `docs/development/proof-mode-cost-baseline.md`, so the next commit touching it
   breaks the gate. Revised to: site the emitters outside `BimodalLib/Diagnostics/`; if an edit
   to `Record.lean`, `Size.lean` or `Emit.lean` nonetheless proves necessary, narrow `SURFACE`
   from the directory to those three files in the same phase, or accept the re-pin and
   re-measure the 73 baseline figures and the document's provenance line.]**

4. **Give the ENUMERATE stage a `profileF`-based fragment filter rather than relying on the
   depth-budget encoding, and never apply `passesFilter` on a `Boolean` run.**
   `BimodalLib.profileF` is a six-case fold returning a three-Bool `Profile`, cheap enough to run
   per formula, and it is the *same* function the registry's `profile_eq` closes by `rfl` — so a
   filter built on it agrees with how the row will be filed by construction, which the depth
   budgets do not. **[No compiled gate applicable — no existing gate decides whether a filter
   predicate is accepted; the agreement claim is a property of `profileF` being the registry's
   own function, read from `Registry.lean:149-152`.]**

5. **Register the non-admitted enumerated outcomes as one aggregate `Conjecture` constant per
   (fragment, frame class, verdict) cell, naming the diagnostics dataset as the per-formula
   record — not one constant per formula.** The per-formula fact is already captured by the
   ADMIT record's own `disposition` / `conjecture_verdict` fields, which is where the record's
   Diagnostics table puts it; a library-level `Conjecture` constant is for a statement someone
   will work on, and 669 ungated-invalid complexity-4 formulas are not that.
   **[No compiled gate applicable — `assert_registry_complete` gates unregistered *closed
   derivations*, not conjecture granularity, and `renderConjectures` renders whatever constants
   exist without constraining how many there should be.]**

6. **Use `evalBranchGates` for the CERTIFY stage of the invalid half, and re-derive the branch
   rather than trusting a dataset `invalid` label.** The eight gates are already implemented,
   already JSON-emitting with the exact snake_case keys the `certify` payload's `gates` object
   wants, and already pinned by `Tests/BimodalToolsTest/TableauBridgeTest.lean:55`. The
   re-derivation is required because `structural_invalid_prefilter` verdicts never had a branch.
   **[No compiled gate applicable — this recommends calling an existing, already-tested function;
   no artifact is being added for a gate to accept.]**

7. **Rule the bound as: `Boolean` and `ModalBoolean` at complexity 5; `TemporalBoolean` and
   `ModalTemporalBoolean` at complexity 4; `Base` only for the theorem half, all four classes for
   the countermodel half; and keep every non-subsumed theorem with no interestingness filter.**
   Grounds, all measured above: the theorem half is carried by Boolean and `ModalBoolean` (52 of
   100 valid at c5 from 27% of the enumeration), the two temporal fragments carry three quarters
   of the undetermined verdicts and `ModalTemporalBoolean` yields nothing at c4 and 14 at c5;
   extraction is Base-only so a stronger class cannot add a theorem; and the interestingness
   tiers do not separate (628 of 790 in one tier at c6). **[No compiled gate applicable — this is
   the user ruling the task defers; the yield figures it rests on are measured, and the bound
   itself is a CLI argument, not a landed artifact.]**

8. **Widen the verdict carried into the pipeline so `fuelExhausted` and `extractionFailed` stay
   distinct, and record the distinction in the `decide` payload's `verdict` field** using
   `DecisionResult`'s own four constructor names rather than `FormulaLabel`'s three.
   `extractionFailed` is `isKnownValid`: the tableau closed and the formula is valid. Filing it
   under the same `ConjectureStatus.undetermined` as `fuelExhausted` is acceptable (that status's
   docstring already covers both) provided the `decide` and `admit` records keep the verdict
   verbatim. **[No compiled gate applicable — the widening is internal to the pipeline's own
   types; no existing gate decides the verdict vocabulary, and `Stage.reservedKeys .decide`
   already reserves a free-form `verdict` string.]**

## Decisions

- **Evidence tier**: compiled probes (`lake env lean` against the built tree) and direct source
  reads, not lean-lsp. Every negative finding ("no `Formula → Formula` substitution exists", "no
  subsumption matcher exists") rests on exhaustive `grep` over `FormalSystem/`, `BimodalTools/`,
  `BimodalLib/`, `Tests/` and `scripts/` for every name containing `subst`, plus `isInstanceOf`,
  `unif`, `matcher`, `DerivationTree.map`, `renameAtom`, `mapAtoms`. Announced as grep-tier rather
  than claimed as LSP-backed absence.
- **The `⊡` restriction needs no code.** Decided on the ground that `Formula` has no `⊡`
  constructor at all, so "cells whose operator set is within `□`" is automatic over `Formula` and
  is not a filter to implement. Recorded here so the plan does not spend a phase on it.
- **The generalization is sound at these cells for the reason the record gives**: TM over
  `Formula` is closed under uniform substitution; TM⁺ is not, because AS (`p → ⊡p`) holds for
  atoms and state-local formulas only. Running the pipeline over `Formula` is what keeps the
  ADMIT stage's generalization sound, and `Axiom.ofSubst`'s 20 `rfl`-shaped arms are the
  mechanical content of that closure.
- **The frame-class axis is a countermodel-half axis.** Decided from `extractProof`'s `_fc` and
  the hard-coded `.Base` in `ProofExtractionResult.success`. The plan should not phase
  "re-run the theorem half at Dense/ZTime/RTime"; it should phase "run the countermodel half at
  all four classes".
- **No `native_decide` anywhere**, including in the gate evaluation: `BranchGates` is computed by
  plain `Bool`-valued functions in `BimodalTools`, and `evalBranchGates` is an ordinary call, so
  the pipeline's gate decisions need no kernel-bypassing evaluation.

## Risks & Mitigations

- **Risk**: the `BimodalLib → BimodalTools` import edge does not exist today and nothing gates it.
  Introducing it gives `BimodalLib` the enumerator and the gates directly, but makes the results
  library depend on the tooling library.
  **Mitigation**: decide it explicitly in the plan. The lakefile's header comment sanctions
  `BimodalTools → FormalSystem` and calls the `FormalSystem → BimodalTools` direction barred by
  `B3`; it says nothing about this one. The cheaper alternative is to put the pipeline's driver in
  `BimodalTools/` (which may import nothing of `BimodalLib`'s today either) and have it emit the
  registration *lines* for a `BimodalLib/Theorems/…` module, keeping both libraries siblings.
- **Risk**: the three-tier subsumption check is the one component with no verification story —
  a wrong answer silently drops an entry or admits a redundant one.
  **Mitigation**: it needs to be computable and tested, not kernel-verified, because a wrong
  answer never admits an *unproved* entry. Test it in both directions in
  `Tests/BimodalLibTest/`, following `RegistryCheckTest.lean`'s fixture pattern: positive cases
  (`□⊥ → ⊥` is an instance of `□A → A`) and negative cases (`□⊥ → p` is not an instance of
  `⊥ → A`), plus the repeated-variable agreement case that `matchAxiom`'s hand-written arms test
  locally.
- **Risk**: `BimodalLib/INDEX.md` is regenerated by `scripts/library-index.sh` and CI fails on a
  stale one (`--check`). Admitting even ten enumerated schemata changes the index, and the
  "laws with no declared dual" section is already long.
  **Mitigation**: regenerate in the same phase that admits, and declare `(dual := …)` for the
  polarity pairs the enumeration produces together (the `U(⊥,⊤) → ⊥` / `S(⊥,⊤) → ⊥` pair and the
  `¬G⊥` / `¬H⊥` pair are time reflections of each other).
- **Risk**: wall-clock cost at complexity 5. The c5 dataset run decided 6,028 formulas with
  adaptive fuel and a wall-clock deadline; at complexity 6 the `wallclock_timeout` count is 60
  and at complexity 7 it is 12,713, so the deadline is doing real work.
  **Mitigation**: reuse `labelFormulaImpl`'s existing `IO.asTask` + cooperative `abortRef` +
  adaptive-fuel machinery (`min 500 (150 + complexity * 30)`) rather than writing a new driver
  loop, and reuse the checkpoint/resume plumbing so a run is resumable. The measured fuel
  landscape is bimodal — formulas resolve at fuel 500 or not at all
  (`DecisionProcedure.lean:374-378`) — so raising fuel is not a mitigation.
- **Risk**: the record's Layout section and `records/proof-mode.md`'s lane table disagree about
  where the diagnostics emitters live.
  **Mitigation**: the task's closing instruction ("revise `docs/` to describe what now exists and
  cut that part from the record") is the sanctioned route — implement to the lane table and the
  staleness surface, then revise `records/theorem-library.md`'s Layout line to match what was
  built.

## Tactic Survey Results

Tactic candidates were exercised inside the compile-verify probe rather than against a standing
goal, so this is a record of what the construction needed, measured by elaboration:

| Goal | Tactic | Result | Premises/Config |
|------|--------|--------|-----------------|
| `substF Formula.atom φ = φ` (identity law) | `induction φ` + `simp only [substF, ih…]` | success | one arm per constructor; `atom` closes by `rfl` |
| `substF σ φ.reflectTime = (substF (… reflectTime) φ).reflectTime` | `induction φ` + `simp only [Formula.reflectTime, substF, ih…]` | success | `atom` arm needs `Formula.reflect_time_involution (σ p) |>.symm` |
| `(Axiom.ofSubst σ ax).minFrameClass = ax.minFrameClass` | `cases ax <;> rfl` | success | all 20 arms; no premises |
| `Axiom.ofSubst` per-arm obligations (20) | none — term mode | success | each arm `rfl`-shaped because `substF σ` pushes through every operator definitionally |
| `h.minFrameClass ≤ fc` after substitution | `rw [Axiom.minFrameClass_ofSubst]; exact h_fc` | success | — |
| `weakening`'s context side condition | `intro`, `obtain ⟨y, hy, rfl⟩ := List.mem_map.mp hx`, `exact List.mem_map_of_mem (h hy)` | success | Mathlib `List.mem_map`, `List.mem_map_of_mem` |
| `time_reflection` transport | `(substF_reflectTime σ φ).symm ▸ …` | success | `▸` on the commuting lemma, as `PlusDerivationTree.ofTMSubst` does |
| the concrete-to-schema step `□p → p` ⟹ `□A → A` | `simpa [substF, σOf] using h` | success | a `decide`-free route; the `if q = pAtom` reduction is discharged by `simpa` |
| `(Axiom.modal_t _).minFrameClass ≤ FrameClass.Base` | `decide` | success | `FrameClass` has `DecidableEq` and a decidable `≤` |

Not attempted, and deliberately: `aesop`, `omega`, `ring`, `norm_num`, `positivity`, `linarith`.
None of the obligations above is arithmetic, inequality-shaped or search-shaped — every one is
either a structural induction over six constructors or a definitional `rfl`, which is why the
construction has no automation in it at all. `lean_hammer_premise` was therefore not consulted;
there is no goal here whose premises needed discovering.

## Context Extension Recommendations

- **Topic**: uniform substitution as data in this tree — what exists (L→L⁺ only), why the row
  type forces it, and the five-declaration mirror shape.
  **Gap**: `context/project/lean4/patterns/` has `dependency-tracing.md` and
  `half-line-test.md` but nothing on the substitution/transport layer, and the fact that
  `TheoremEntry.proof`'s `∀ v` makes a *concrete* extracted derivation unregistrable is
  non-obvious and cost a full probe to establish.
  **Recommendation**: a new `context/project/lean4/patterns/uniform-substitution-as-data.md`
  recording the `substPlus`/`ofTMSubst` template, the Prop-vs-Type trap
  (`Derivable = Nonempty (DerivationTree …)` plus `addAndCompile` closes the choice route), and
  the measured axiom profile of a row built through it.
- **Topic**: the cost-baseline staleness surface as a standing gate collision.
  **Gap**: `context/project/lean4/patterns/plan-authoring-gate-collisions.md` exists but does not
  name this one, and the surface is a *directory*, so the collision fires for any future work
  that writes anywhere under `BimodalLib/Diagnostics/`.
  **Recommendation**: add the `proof-mode-cost-baseline.sh` `SURFACE` array to that file's
  collision list, with the verified exit-3 symptom and the two remedies (site outside the
  directory, or narrow `SURFACE` to files).
- **Topic**: the pattern-aware `Formula.complexity` measure.
  **Gap**: nothing in `context/project/lean4/` records that "complexity N" in this tree counts
  *recognized derived operator layers*, not primitive nodes, so a bound stated in one measure
  reads as a bound in the other. Three of this report's tables would be misread without it.
  **Recommendation**: a short note under `context/project/lean4/domain/` fixing the measure and
  naming `Formula.complexity`, `modalDepth` and `temporalDepth` as the three independent axes.

## Appendix

All four probe scripts are preserved under
`specs/972_theorem_library_tableau_pipeline/probes/` so every figure below is reproducible:
`subst-probe.lean`, `yield-probe.lean`, `frag.py`, `pt.py`.

**Compiled probes run (against the already-built tree, no `lake build` invoked):**

- `subst-probe.lean` — the five-declaration L-level substitution construction plus
  `register_theorem` on a generalized row. Exit 0. Output:
  `'SubstProbe.Enumerated.modalT_generalized' depends on axioms: [propext, Quot.sound]` and
  `({ box := true, stab := false, temporal := false }, 1, "ModalBoolean")`.
- `yield-probe.lean` — enumerate at bound 4 over two atoms, canonicalize, decide at `Base` and at
  `ZTime`, and tabulate verdict × `BranchGates.gated` per fragment. It compiles and runs (a 60s
  foreground attempt was killed mid-run, not by an error), but **had not finished after 25
  minutes of detached wall clock** and produced no figure within this dispatch. That
  non-completion is itself a finding worth carrying into the plan: `evalBranchGates` re-runs
  `buildTableau` for every `invalid` verdict, so gating the countermodel half roughly doubles the
  DECIDE cost per formula, on top of the second pass at `ZTime`. The gate pass rate per
  (fragment, frame class) is therefore **not measured here** and is the one figure the plan's
  first phase should take before the bound is fixed in the command's defaults.
- `scripts/proof-mode-cost-baseline.sh --pin <mismatched sha>` — exit 3, "STALE BASELINE",
  confirming the `BimodalLib/Diagnostics` staleness surface.

**Searches used** (grep over `FormalSystem/`, `BimodalTools/`, `BimodalLib/`, `Tests/`,
`scripts/`): every declaration name containing `subst`; `uniformSubst`, `Formula.subst`,
`derivable_subst`, `subst_derivable`, `DerivationTree.map`, `renameAtom`, `mapAtoms`;
`isInstanceOf`, `subsum`, `unif`, `matcher`, `substitution instance`;
`profileF|profileP|Fragment|fragment` across `BimodalTools/*.lean` (zero hits);
`DerivationTree` across `BimodalTools/` (every hit collapses the tree).

**Data tabulations** were computed by two throwaway Python scripts over
`data/bmlogic-c{4,5,6}.jsonl`, walking `formula_ast` to compute the `profileF` fragment and
counting `label`, `proof_trace` presence, `proof_reconstruction_method`, `interestingness_tier`
and `semantic_countermodel.{world_count,time_count}`. One incidental figure worth keeping: the
invalid countermodels are tiny — at complexity 4, 518 of 669 live in one world at one time, 138
in one world at two times, and only 13 use two worlds.

**Documentation read**: `records/theorem-library.md` (whole), `records/proof-mode.md` (M19, M20,
the lane table, the dependency graph), `docs/reference/bimodal-lib.md` (whole),
`docs/reference/diagnostics.md` (the reserved-stage section and the formula-codec obligation),
`BimodalTools/README.md` (the tableau-bridge, certificate and translation wire schemas).

**One schema inconsistency noted, not acted on**: `Stage.carriesFormulaField`
(`BimodalLib/Diagnostics/Record.lean:146`) returns `true` for `enumerate` and `extract`, but
neither stage's entry in `Stage.reservedKeys` contains a formula-valued field — `enumerate` is
four counts and `extract` is five scalars plus a route string. So the formula a record is about
can only be carried by the head's `statement` string, and `unregisteredStatementId` produces
`"unregistered:" ++ declName`, which an enumerated formula does not have. The pipeline needs a
formula-identifier convention for the head (the dataset `id` convention, `bmlogic-00001`, or the
canonical s-expression), and the plan should either adopt one and leave
`carriesFormulaField` as the unexercised obligation `docs/reference/diagnostics.md` describes, or
reconcile the two. No compiled test constrains `reservedKeys`' contents beyond non-emptiness
(`Tests/BimodalLibTest/DiagnosticsTest.lean:214-217`), so either route builds.
