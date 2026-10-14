# Implementation Plan: Task #788

- **Task**: 788 - Reduce TM and its extensions TM_z, TM_d, and TM_r to minimal axiom sets
- **Status**: [IMPLEMENTING]
- **Effort**: 17 hours
- **Dependencies**: None
- **Research Inputs**: specs/788_reduce_tm_and_extensions_to_minimal_axiom_sets/reports/01_reduce-tm-minimal-axiom-sets.md
- **Artifacts**: plans/01_reduce-tm-minimal-axiom-sets.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Nine `Axiom` constructors — UE `until_F`, UT `F_until_equiv`, TC `connect_future`, NF
`discrete_propagate_fwd`, NP `discrete_symm_fwd`, NA `discrete_propagate_bwd`, TL
`temp_linearity`, DN `density`, Z1 `z1` — are derivable from the remaining twenty, and the research
round left a compiling derivation of each (`evidence/Scratch788.lean`, `#print axioms` clean). The
plan lands the derived theorems first, in modules placed by the import DAG, repoints every genuine
axiom site to them while the constructors still exist (so each step stays green), then deletes the
nine constructors in one atomic batch that is verified by the single unavoidable whole-tree
rebuild, and finally regenerates the tooling/Typst outputs and refreshes the prose. The reduced
inductive has 20 constructors (Base 17 / Dense 1 / ZTime 1 / RTime 2).

### Research Integration

- Every derivation is transcribed from the verified scratch, not reconstructed: UE from UG + TN;
  UT as `identity`; NF as `NB ; MF ; MT`; TC via US, UC, TN and two deduction-theorem discharges;
  NP via US, UC, TR(NF), UE and `F(Hχ) → χ`; NA from NP, TR(NF), TR(TN NP), `pastKDist`; TL from
  UF, CN, UE, `someFutureMono`, `orElim`; DN directly from NN + UG + UF + UC + TN + K-dist; Z1
  through `derivable_of_validZTime` + `z1_valid` (engine measured non-circular: the ZTime engine
  uses only `Axiom.prior_UZ`, the Dense engine only `Axiom.dense_indicator`).
- TL decision (task item): **derive from CN**, do not restore Burgess A4a. Xu 1988 §3's Σ₄ is
  complete for linear frames with A4a deleted and the chronicle construction already uses Xu
  3.2.1/3.2.2 in its place; Xu §4 Theorem 4.3 shows the G/H-level linearity formula (13) is
  strictly weaker than (10), which is the precise sense in which TL is subsumed by CN. The
  `LinearityDerivedFacts.lean` underivability claim is stale: its branching frame refutes the CN
  instance `linear_until (Fp) p (Fq) q` at 0, so it is not a model of the current base.
- `z1_in_frame` has no dependents (re-verified at planning: the only hit is its definition at
  `FormalSystem/Metalogic/WeakCanonical/FrameProperties.lean:28`); it is deleted with its BLOCKED
  docstring.
- **One deviation from the report's placement**: the report puts TC/NP/NA/TL/DN in a single
  `Theorems/DerivedSchemata.lean` importing `TemporalDerived`. But `TemporalDerived.connectFutureThm`
  (consumed inside `TemporalDerived.lean` at lines 675, 703, 716) is itself TC, so the repoint would
  need TC *below* `TemporalDerived` — an import cycle. The plan therefore splits the module:
  `Theorems/ConnectDerived.lean` (TC, NP, NA; imports `GeneralizedNecessitation`, which sits below
  `TemporalDerived`) and `Theorems/LinearityDerived.lean` (TL, DN; imports `TemporalDerived`).
  Recorded in the task issue log.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

`specs/ROADMAP.md` was consulted read-only; no roadmap item names the axiom-set reduction. The
README item "the BX axiom layers" (ROADMAP line 217) is the closest documentation surface and is
refreshed in Phase 10. No `roadmap_flag` was set, so no roadmap phases are added.

## Goals & Non-Goals

**Goals**:
- `untilF`, `fUntilEquiv`, `discretePropagateFwd`, `discretePropagateFwdMirror`, `connectFuture`,
  `discreteSymmFwd`, `discretePropagateBwd`, `tempLinearity`, `density`, `z1Derivable`, `z1Thm`
- Delete the nine constructors and their `minFrameClass` rows; reduce `Axiom` to 20 constructors
- Repoint every call site, automation table, tableau `ruleAxioms` row, Plus/Star/Minus bridge,
  Independence shape pin, test, and tooling entry; delete `z1_in_frame`
- Retract the stale claim in `LinearityDerivedFacts.lean` and the `Axioms.lean` docstring
- Regenerate `typst/generated/*`; refresh the `Axioms.lean` table, `axiom-reference.md`,
  `paper-definitions-of-record.md`, `theorem-index.md`, and every count pin C14 checks

**Non-Goals**:
- Reducing `PlusAxiom`/`StarAxiom` (separate, result-9-incomplete systems; only their dead arms
  and TM-validity bridges change)
- Investigating derivability of TS, UG, UC, US, UF, UI, CN, MF, NB, UZ, NN, PU, SEP
- A direct (engine-free) derivation of Z1 — optional follow-up, not a blocker
- Editing the paper's `def:BX` text or `typst/FormalFoundations.typ`; the divergence is recorded
  as a tree-side amendment in `paper-definitions-of-record.md`
- Restoring Burgess A4a

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Hidden transitive use of a demoted constructor inside a completeness engine (would make the Z1 route circular) | H | L | Research grep sweeps found none; Phase 7's whole-tree rebuild is the decisive check — a hidden use fails to compile |
| Import cycle when `Conservativity/Backward.lean` imports the new engine-derived module | M | L | `BXCanonical`, `Core`, `WeakCanonical`, `Bundle`, `Soundness`, `SoundnessLemmas` import nothing from `Conservativity`/`MinusLanguage` (grep at planning); Phase 4's scoped build of `Backward` confirms |
| `contrapositive` lives in `TemporalDerived` (line 372) but TC's `fHImp` needs it below `TemporalDerived` | M | H | Phase 2 re-derives a local propositional contrapositive from `Propositional.Core` stock (or uses an existing Core equivalent if grep finds one) |
| Multiple whole-tree rebuilds from iterating on `Axioms.lean` | M | M | All `Axioms.lean` code edits are batched into Phase 7 (`atomic-batch`); the docstring refresh in Phase 9 is prose-tier and is observed by the final full build only |
| Exhaustive-match blast radius (~130 arms, ~25 files incl. tooling) | M | H | Purely mechanical; let the compiler enumerate missing/extra arms; named tooling entries are repointed, not dropped, so dataset coverage is preserved |
| `MachineAppendixMain` asserts exactly 29 entries; `typst-sync-check.sh` CHECK3 compares live count | M | H | Phase 7 updates the assertion to 20 and the entry list; Phase 8 regenerates `machine-appendix.jsonl` and runs CHECK3 |
| Automation regressions for gated schemata (DN at `Dense`, Z1 at `ZTime`) — `@[tmLemma]` cannot discharge a frame-class hypothesis | M | M | Follow `Search.lean`'s `tryGatedDerivedMatch` (line 167) exactly as `priorSZ`/`priorSGap` are handled; keep `WeakeningSearchTest.lean:74` green |
| Benchmark/dataset baselines drift (`c20-declaration-baseline.txt`, `certificate-witness-inventory.txt`, decidability inventory) | L | M | Diff after Phase 8 with the repository's own `--diff` tooling; never hand-edit in advance |
| Lean build wall-clock exceeds the foreground cap | H | H | Every build runs detached through `lake-build-guard.sh build --timeout 1800`, per `context/project/lean4/operations/long-builds.md`; un-piped exit capture |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 4 | -- |
| 2 | 2, 3 | 1 |
| 3 | 5 | 1, 2, 3, 4 |
| 4 | 6 | 5 |
| 5 | 7 | 5, 6 |
| 6 | 8, 9 | 7 |
| 7 | 10 | 8, 9 |

Phases within the same wave can execute in parallel.

Build discipline for every phase: route each `lake` invocation through
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build <Module>` detached via
`Bash(run_in_background: true)`, capturing the guard's exit un-piped; never a bare foreground
`lake build`. Before Phase 7 take an ordinary defensive checkpoint with
`bash .claude/scripts/git-snapshot.sh 788 --no-revert` (never the default reverting form).

---

### Phase 1: Raw-constructor derived stock in `DerivedAxioms.lean` (UE, UT, NF, TR(NF)) [COMPLETED]

**Goal**: Add the four schemata that need only raw constructors to
`FormalSystem/ProofSystem/DerivedAxioms.lean`, and make the existing TR mirrors `sinceP` and
`pSinceEquiv` reflect the derived theorems instead of `Axiom.until_F`/`Axiom.F_until_equiv`. No
change to `Axiom`.

**Tasks**:
- [x] Add private helpers built from `prop_k`/`prop_s` only (the module imports just
      `Syntax.Formula` and `ProofSystem.Derivation`): an identity term (`⊤` as `bot.imp bot`), an
      `impTrans`, an `impTop φ : φ → ⊤`, and theorem-level guard/event monotonicity
      (`guardMonoThm` via UG + TN, `eventMonoThm` via UC + TN) as in the scratch
- [x] `untilF (φ ψ) : ⊢[fc] (untl φ ψ).imp ψ.someFuture := guardMonoThm φ ⊤ ψ (impTop φ)` — tag
      `@[tmLemma]`
- [x] `fUntilEquiv (φ) : ⊢[fc] φ.someFuture.imp (untl (bot.imp bot) φ) := identity` — `@[tmLemma]`
- [x] `discretePropagateFwd : ⊢[fc] X⊤ → G X⊤ := NB ; MF ; MT` with `X⊤` spelled
      `untl bot (bot.imp bot)` exactly as the constructor does — `@[tmLemma]`
- [x] `discretePropagateFwdMirror : ⊢[fc] Y⊤ → H Y⊤ := ofReflect discretePropagateFwd rfl` —
      `@[tmLemma]`
- [x] Repoint `sinceP` (line 135) to `ofReflect (untilF ..) rfl` and `pSinceEquiv` (line 142) to
      `ofReflect (fUntilEquiv ..) rfl`; leave `connectPast` and `discreteSymmBwd` untouched here
      (they move in Phase 5)
- [x] Update the module docstring's derived-stock list (lines 34-40) for the new entries
- [x] Scoped guarded build of `FormalSystem.ProofSystem.DerivedAxioms`; `lean_verify` each new
      declaration (expect `propext` only, no `sorryAx`)

**Timing**: 1.5 hours

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: This phase asserts the four derivations need no helper beyond `prop_k`,
`prop_s`, UG, UC, TN, NB, MF, MT (carried from the report's Tactic Survey table, verified in the
scratch with `Combinators` available); confirm by building the module with its unchanged two-line
import list — any missing helper surfaces as an unknown identifier.

**Tier Justification**: `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.ProofSystem.DerivedAxioms` is the complete covering check: every edit is confined to this one module, and the two repointed mirrors keep their statements, so no importer's elaboration can change until Phase 7's full build observes the module anyway.

**Files to modify**:
- `FormalSystem/ProofSystem/DerivedAxioms.lean` - add helpers, `untilF`, `fUntilEquiv`, `discretePropagateFwd`, `discretePropagateFwdMirror`; repoint `sinceP`, `pSinceEquiv`; docstring list

**Verification**:
- Scoped guarded build exits 0
- `lean_verify` on `FormalSystem.ProofSystem.DerivedAxioms.{untilF,fUntilEquiv,discretePropagateFwd,discretePropagateFwdMirror}` reports no `sorryAx`
- `grep -n "Axiom.until_F\|Axiom.F_until_equiv" FormalSystem/ProofSystem/DerivedAxioms.lean` returns only docstring prose

---

### Phase 2: `Theorems/ConnectDerived.lean` — TC, NP, NA below `TemporalDerived` [COMPLETED]

**Goal**: Create `FormalSystem/Theorems/ConnectDerived.lean` holding `connectFuture`, `fHImp`,
`discreteSymmFwd`, `discretePropagateBwd`, importing `Theorems.GeneralizedNecessitation` and
`Theorems.Propositional.Core` (so it sits *below* `TemporalDerived` in the DAG), and register it in
`FormalSystem/Theorems.lean`.

**Tasks**:
- [x] Create the module with imports `FormalSystem.Theorems.GeneralizedNecessitation`,
      `FormalSystem.Theorems.Propositional.Core`, `FormalSystem.Theorems.DeductionTheorem`
      (transitively: `Combinators`, `DerivedAxioms`, `Connectives`); namespace
      `FormalSystem.Theorems.ConnectDerived`
- [x] `connectFuture (φ) : ⊢[fc] φ.imp φ.somePast.allFuture` — transcribe the scratch proof
      (`deductionTheorem` twice, `enrichment_until ⊤ ¬Pφ φ`, `andIntro`/`andFst`/`andSnd`,
      `eventMono`, `untlBotFalse`) — `@[tmLemma]`
- [x] `fHImp (ψ) : ⊢[fc] ψ.allPast.someFuture.imp ψ` from `connectFuture ψ.neg` via
      contraposition and `notNotIntro`/`doubleNegation`; `contrapositive` is defined only in
      `TemporalDerived.lean:372`, so re-derive a local propositional contrapositive from
      `Propositional.Core` stock (or use a Core equivalent if `grep` finds one) *(completed: used the existing `Propositional.contraposeImp` from `Connectives.lean`, the plan's own "Core equivalent" branch)*
- [x] `discreteSymmFwd : ⊢[fc] X⊤ → Y⊤` via `enrichment_until ⊥ ⊤ ⊤`, `pairing`, `rceImp`,
      `eventMonoThm`, `DerivedAxioms.discretePropagateFwdMirror`, `DerivedAxioms.untilF`, `fHImp` —
      `@[tmLemma]`
- [x] `discretePropagateBwd : ⊢[fc] X⊤ → H X⊤` from `discreteSymmFwd`,
      `discretePropagateFwdMirror`, `ofReflect (temporal_necessitation discreteSymmFwd) rfl`, and
      `pastKDist` — `@[tmLemma]`
- [x] Register `import FormalSystem.Theorems.ConnectDerived` in `FormalSystem/Theorems.lean`
- [x] Scoped guarded build of `FormalSystem.Theorems.ConnectDerived`; `lean_verify` each declaration

**Timing**: 2 hours

**Depends on**: 1

**Verification Tier**: local

**Scope Hypothesis**: This phase asserts `contrapositive` is the only `TemporalDerived`-resident
helper the scratch's TC/NP/NA proofs use (planning grep: `contrapositive`, `someFutureMono`, and
`temporalKDistDerived` are the TemporalDerived names the scratch opens, and only the first appears
in TC/NP/NA); confirm by building with `TemporalDerived` absent from the import list.

**Tier Justification**: `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Theorems.ConnectDerived` plus `-- build FormalSystem.Theorems` (the umbrella) is the complete covering check: the phase adds one new module and one import line, and no existing declaration changes.

**Files to modify**:
- `FormalSystem/Theorems/ConnectDerived.lean` - new module: `connectFuture`, `fHImp`, `discreteSymmFwd`, `discretePropagateBwd`
- `FormalSystem/Theorems.lean` - register the new module

**Verification**:
- Both scoped guarded builds exit 0
- `lean_verify` on the four declarations: no `sorryAx`; `discreteSymmFwd`'s statement is
  literally `Axiom.discrete_symm_fwd`'s formula (check with `example : ... := discreteSymmFwd`)
- `grep -c "Axiom.connect_future\|Axiom.discrete_symm_fwd\|Axiom.discrete_propagate" FormalSystem/Theorems/ConnectDerived.lean` is 0

---

### Phase 3: `Theorems/LinearityDerived.lean` — TL and DN above `TemporalDerived` [COMPLETED]

**Goal**: Create `FormalSystem/Theorems/LinearityDerived.lean` holding `tempLinearity` (paper
order, derived from CN) and `density` (direct derivation from NN), importing `TemporalDerived`
and `Propositional.Core`; register in `Theorems.lean`.

**Tasks**:
- [x] Create the module with imports `FormalSystem.Theorems.TemporalDerived`,
      `FormalSystem.Theorems.Propositional.Core`, `FormalSystem.Theorems.DeductionTheorem`;
      namespace `FormalSystem.Theorems.LinearityDerived`
- [x] `orInlThm`/`orInrThm` theorem-level disjunction introductions via `deductionTheorem` (as in
      the scratch, or reuse Core equivalents if present)
- [x] `tempLinearity (φ ψ)` with the statement of `Axiom.temp_linearity` verbatim (paper order,
      right-associated): UF on `Fφ`, `Fψ`; `linear_until g₁ φ g₂ ψ`; `untilF` on each disjunct;
      `someFutureMono` with `combineImpConj`/`lceImp`/`rceImp`; two `orElim`s — `@[tmLemma]`
- [x] `density (h : FrameClass.Dense ≤ fc) (φ) : ⊢[fc] GGφ → Gφ` — transcribe the scratch
      (`temporalKDistDerived`, `necG`, `left_mono_until_G ⊤ Gφ ¬φ`, `self_accum_until Gφ ¬φ`,
      guard collapse to `⊥` via `untilF`, `eventMono` to `X⊤`, `Axiom.dense_indicator h`);
      untagged (gated), handled by Phase 5's automation step
- [x] Register in `FormalSystem/Theorems.lean`
- [x] Scoped guarded build; `lean_verify` both

**Timing**: 1.5 hours

**Depends on**: 1

**Verification Tier**: local

**Scope Hypothesis**: This phase asserts the scratch's TL proof lands on the paper's disjunct
order with one `orInl`/`orInr` placement per disjunct and no `orRotate` (carried from the report
§Findings); confirm by the `example` shape pin against `Axiom.temp_linearity`'s formula.

**Tier Justification**: `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Theorems.LinearityDerived` plus the `FormalSystem.Theorems` umbrella is the complete covering check: one new module, one import line, no existing declaration changed.

**Files to modify**:
- `FormalSystem/Theorems/LinearityDerived.lean` - new module: `tempLinearity`, `density`, disjunction helpers
- `FormalSystem/Theorems.lean` - register the new module

**Verification**:
- Scoped guarded builds exit 0; `lean_verify` reports no `sorryAx`
- `example (φ ψ) : ⊢[.Base] <Axiom.temp_linearity's formula> := tempLinearity φ ψ` and
  `example (φ) : ⊢[.Dense] φ.allFuture.allFuture.imp φ.allFuture := density le_rfl φ` elaborate
- `grep -c "Axiom.temp_linearity\|Axiom.density" FormalSystem/Theorems/LinearityDerived.lean` is 0

---

### Phase 4: `Metalogic/CompletenessDerived.lean` — Z1 through the ZTime engine [COMPLETED]

**Goal**: Create `FormalSystem/Metalogic/CompletenessDerived.lean` with `z1Derivable` (Prop-level,
via `derivable_of_validZTime` + `z1_valid`), `z1Thm` (`noncomputable`, `Classical.choice`
packaging for term consumers), and `densityDerivable` as an optional cross-check of Phase 3's
direct DN; register it in `FormalSystem/Metalogic.lean` next to `ZTimeProvability`.

**Tasks**:
- [x] Create the module importing `FormalSystem.Metalogic.BXCanonical.Completeness`,
      `FormalSystem.Metalogic.Soundness`, `FormalSystem.Metalogic.SoundnessLemmas.FrameClassVariants`
      (the scratch's import profile); namespace `FormalSystem.Metalogic.CompletenessDerived`
- [x] `theorem z1Derivable (φ) : Derivable FrameClass.ZTime [] (Z1 φ) :=
      BXCanonical.derivable_of_validZTime _ (SoundnessLemmas.z1_valid φ)`
- [x] `noncomputable def z1Thm (φ) : ⊢[FrameClass.ZTime] Z1 φ := Classical.choice (z1Derivable φ)`
- [x] `theorem densityDerivable (φ) : Derivable FrameClass.Dense [] (GGφ → Gφ)` via
      `derivable_of_validQTime` + `validQTime_of_validDense (density_valid φ)` — docstring says it
      is a cross-check only; Phase 3's `density` is canonical
- [x] Module docstring: record the non-circularity measurement (ZTime engine uses only
      `Axiom.prior_UZ`, `Completeness.lean:351`; Dense engine only `Axiom.dense_indicator`, line
      305) and that Phase 7's full build is the mechanical confirmation
- [x] Register in `FormalSystem/Metalogic.lean`
- [x] Scoped guarded build; `lean_verify` (expect `propext`, `Classical.choice`, `Quot.sound`)

**Timing**: 1 hour

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: This phase asserts no module under `BXCanonical`, `Core`, `WeakCanonical`,
`Bundle`, `Soundness`, or `SoundnessLemmas` imports `Conservativity` or `MinusLanguage` (planning
grep: none), so `Conservativity/Backward.lean` can import this module in Phase 6 without a cycle;
confirm in Phase 6 by the scoped build of `FormalSystem.Metalogic.Conservativity.Backward`.

**Tier Justification**: `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.CompletenessDerived` plus the `FormalSystem.Metalogic` umbrella is the complete covering check: one new module and one import line, nothing existing changed.

**Files to modify**:
- `FormalSystem/Metalogic/CompletenessDerived.lean` - new module: `z1Derivable`, `z1Thm`, `densityDerivable`
- `FormalSystem/Metalogic.lean` - register the new module

**Verification**:
- Scoped guarded builds exit 0; `lean_verify` on `z1Derivable`, `z1Thm`, `densityDerivable`
  reports no `sorryAx`
- `example (φ) : ⊢[.ZTime] <Axiom.z1's formula> := z1Thm φ` elaborates

---

### Phase 5: Repoint FormalSystem core and Metalogic engines; move the dependent mirrors [COMPLETED]

**Goal**: With all nine derived theorems in place and the constructors still present, repoint
every genuine `DerivationTree.axiom … (Axiom.X …)` site in `FormalSystem/Theorems`,
`ProofSystem`, `Examples`, `Automation`, and the Metalogic engines
(`BXCanonical`, `WeakCanonical`, `Bundle`, `Filtration`, `Chronicle`, `Quasimodel`,
`Decidability`) to the derived theorems; move the mirrors whose primaries are now derived
(`connectPast`, `connectPastAt`, `discreteSymmBwd` into `ConnectDerived`;
`tempLinearityLegacy`, `tempLinearityPast` into `LinearityDerived`); wire automation. Every
substep stays green because nothing is deleted yet.

**Tasks**:
- [x] `Theorems/TemporalDerived.lean`: add `import FormalSystem.Theorems.ConnectDerived`;
      `connectFutureThm := ConnectDerived.connectFuture φ` (line 306);
      `untilImpliesSomeFuture`/`untilImpF` (338, 355) become `DerivedAxioms.untilF`
- [x] `Theorems/Propositional/Core.lean:756` (`untlBotFalse`) → `DerivedAxioms.untilF`
- [x] `Theorems/ContextualProofs.lean:256,285,412,463`, `Theorems/DiscreteUnfolding.lean:493`,
      `Theorems/DedekindDerived.lean:168` → derived theorems (optionally make
      `someFutureAllPastImp` an alias of `ConnectDerived.fHImp`)
- [x] Move `connectPast`/`connectPastAt` (DerivedAxioms 107, 196) and `discreteSymmBwd` (148)
      into `ConnectDerived`, reflecting `connectFuture`/`discreteSymmFwd`; repoint every
      `DerivedAxioms.connectPast`/`.connectPastAt`/`.discreteSymmBwd` reference (grep the tree) *(deviation: altered — the Phase 2/3 proofs of TC, `fHImp`, NP, NA, TL, DN were rewritten as computable combinator terms (statements verbatim) because `ProofSearch/Core.mirrorCandidate`, `BimodalTools/ProofExtractorMain` and `connectFutureThm` are computable consumers and the scratch route through `deductionTheorem`/`orElim`/`lceImp`/`rceImp`/`pastKDist`/`untlBotFalse` is `noncomputable`; see issues.jsonl)*
- [x] Move `tempLinearityLegacy`/`tempLinearityPast` (Combinators 813-860) into
      `LinearityDerived`, built from `tempLinearity` + `orRotate`; repoint references
- [x] `Examples/Walkthrough.lean:237` (DN) → `LinearityDerived.density`
- [x] Metalogic engines: `BXCanonical/Frame.lean:697`, `CanonicalChain.lean:56`,
      `OrderedSeedConsistency.lean:128` (`temp_linearity_mcs` — consumed by
      `WeakCanonical/ReflexiveCanonical.lean:284,371`), `Bundle/WitnessSeed.lean:442`,
      `Filtration/DefectChain.lean:84,93`, `Chronicle/RRelation.lean:89,654,1364,1368,1641,1666`,
      `Chronicle/PointInsertion.lean:152,178,191,220,390,397,700,777,3412`,
      `Chronicle/ChronicleConstruction.lean:783,1148`, `Chronicle/CounterexampleElimination.lean:320`,
      `Chronicle/ChronicleToCountermodelBasic.lean:902`, `Quasimodel/Construction.lean:133,143`
- [x] `Decidability/Verified/RuleSpec.lean` `ruleAxioms`: `untlPos`/`sncePos` drop the `until_F`
      instance (keep `self_accum_until`); `orderTrichotomy`, `timeLinearity`, `densityRule`,
      `z1Rule` become `[]` with a comment pointing at the derived theorem (the module docstring
      already allows empty lists for semantically grounded rules) — decision: do not generalize
      `AxiomInstance` *(deviation: altered — GATE 3 `ruleAxioms_covers_ruleFrameClass` (proved by `decide`) requires a rule gated above `.Base` to name an axiom at its own class, so `[]` fails the build for `densityRule`/`z1Rule`; those two are grounded in `dense_indicator`/`prior_UZ`, the constructors their derivations consume (the `priorSZ => prior_UZ` precedent); `orderTrichotomy`/`timeLinearity` are `[]` as planned)*
- [x] Automation: `@[tmLemma]` already on UE/UT/TC/NF/NP/NA/TL from Phases 1-3; add
      `LinearityDerived.density` and `CompletenessDerived.z1Thm` to `tryGatedDerivedMatch`'s
      lemma list (`Tactics/Search.lean:167`) exactly as `priorSZ`/`priorSGap` are handled, with
      their gates discharged by `decide`/`le_rfl`; do NOT remove the `axiomCtors` entries or the
      `ProofSearch/Core.lean` matcher arms yet (Phase 7)
- [x] Scoped guarded builds of each touched module and its direct dependents
      (`FormalSystem.Theorems`, `FormalSystem.Metalogic.BXCanonical`,
      `FormalSystem.Metalogic.WeakCanonical`, `FormalSystem.Metalogic.Decidability`,
      `FormalSystem.Automation`, `FormalSystem.Examples`)

**Timing**: 2 hours

**Depends on**: 1, 2, 3, 4

**Verification Tier**: interface

**Scope Hypothesis**: This phase asserts ~22 genuine axiom-instance sites across the listed
files (carried from the report's call-site inventory, line numbers as of the research commit);
confirm with `grep -rn "Axiom\.\(until_F\|F_until_equiv\|connect_future\|discrete_symm_fwd\|discrete_propagate_fwd\|discrete_propagate_bwd\|temp_linearity\|density\|z1\)\b" FormalSystem --include=*.lean | grep -v "^\s*--"` before and after — the remaining hits must all be exhaustive `match` arms, soundness/validity lemma names, or docstrings.

**Tier Justification**: Moving `connectPast`, `connectPastAt`, `discreteSymmBwd`, `tempLinearityLegacy`, and `tempLinearityPast` changes their qualified names across files, and Lean body changes can reach dependents through definitional unfolding (`rfl` reflections), so the covering check is the scoped guarded build of each touched module plus its enumerated direct dependents listed in the last task — no cheaper tier covers a cross-file rename.

**Files to modify**:
- `FormalSystem/Theorems/TemporalDerived.lean` - import `ConnectDerived`; `connectFutureThm`, `untilImpliesSomeFuture`, `untilImpF` repoint
- `FormalSystem/Theorems/Propositional/Core.lean` - `untlBotFalse` repoint
- `FormalSystem/Theorems/ContextualProofs.lean` - repoint four sites
- `FormalSystem/Theorems/DiscreteUnfolding.lean` - repoint one site
- `FormalSystem/Theorems/DedekindDerived.lean` - repoint one site
- `FormalSystem/Theorems/Combinators.lean` - remove `tempLinearityLegacy`/`tempLinearityPast`
- `FormalSystem/Theorems/ConnectDerived.lean` - receive `connectPast`, `connectPastAt`, `discreteSymmBwd`
- `FormalSystem/Theorems/LinearityDerived.lean` - receive `tempLinearityLegacy`, `tempLinearityPast`
- `FormalSystem/ProofSystem/DerivedAxioms.lean` - remove the moved mirrors; docstring list
- `FormalSystem/Examples/Walkthrough.lean` - DN repoint
- `FormalSystem/Metalogic/BXCanonical/Frame.lean` - repoint
- `FormalSystem/Metalogic/BXCanonical/CanonicalChain.lean` - repoint
- `FormalSystem/Metalogic/BXCanonical/OrderedSeedConsistency.lean` - `temp_linearity_mcs` repoint
- `FormalSystem/Metalogic/Bundle/WitnessSeed.lean` - repoint
- `FormalSystem/Metalogic/Filtration/DefectChain.lean` - repoint
- `FormalSystem/Metalogic/Chronicle/RRelation.lean` - repoint
- `FormalSystem/Metalogic/Chronicle/PointInsertion.lean` - repoint
- `FormalSystem/Metalogic/Chronicle/ChronicleConstruction.lean` - repoint
- `FormalSystem/Metalogic/Chronicle/CounterexampleElimination.lean` - repoint
- `FormalSystem/Metalogic/Chronicle/ChronicleToCountermodelBasic.lean` - repoint
- `FormalSystem/Metalogic/Quasimodel/Construction.lean` - repoint
- `FormalSystem/Metalogic/Decidability/Verified/RuleSpec.lean` - `ruleAxioms` rows
- `FormalSystem/Automation/Tactics/Search.lean` - `tryGatedDerivedMatch` lemma list

**Verification**:
- Every scoped guarded build exits 0
- The Scope Hypothesis grep shows no remaining `DerivationTree.axiom … (Axiom.X …)` site in
  `FormalSystem/` for the nine names outside `Conservativity/`, `MinusLanguage/`, `Independence/`,
  `PlusLanguage/`, `StarLanguage/` (Phase 6's territory)
- `Tests/BimodalTest/Automation/WeakeningSearchTest.lean` still builds (gated DN path)

---

### Phase 6: Repoint Conservativity, Minus/Plus/Star bridges, Independence pins, Tests, and tooling [COMPLETED]

**Goal**: Repoint the remaining genuine axiom sites outside the engines, retarget the two
Independence shape pins at the derived theorems' statements, and update every test and tooling
entry that *names* a demoted schema — still with the constructors present, so each substep is
green.

**Tasks**:
- [x] `Metalogic/Conservativity/Backward.lean:205` (`z1_translate`): add
      `import FormalSystem.Metalogic.CompletenessDerived` and consume `z1Derivable` directly (it
      already returns `Derivable`); confirm no cycle via the scoped build
- [x] `Metalogic/Conservativity/MinusTemporalDerived.lean:353,360`,
      `Metalogic/Conservativity/SpCountermodel.lean:153` → `LinearityDerived.tempLinearity`
      (or the moved `tempLinearityLegacy`, whichever order they consume) *(deviation: skipped — probe (definition lookup): both files `open FormalSystem.MinusLanguage` and their `Axiom.temp_linearity` is `MinusLanguage.Axiom.temp_linearity`, the Minus system's own constructor, not the TM one; nothing to repoint)*
- [x] `MinusLanguage/AxiomDischarge.lean:233` (TC), `:318` (DN), `:372` (TL) → derived theorems;
      refresh its docstring asset table (line 37 "L asset: `Axiom.density`")
- [x] `Metalogic/Conservativity/Plus/AxiomValidity.lean:122,238` and the Plus/Star validity
      bridges: repoint to the `plusValidIn_of_tm_deriv` idiom (`AxiomValidity.lean:136` is the
      precedent); leave `PlusAxiom`/`StarAxiom` constructor sets unchanged
- [x] Independence shape pins: `Independence/DenseRTimeSharpness.lean:119` →
      `example (φ) : ⊢[.Dense] … := LinearityDerived.density le_rfl φ`;
      `Independence/ZTimeSharpness.lean:152` → `example (φ) : ⊢[.ZTime] … := z1Thm φ`
      (statements unchanged; the semantic results `z1_validIn_iff_ztime`, `z1_minFrameClass_sharp`,
      `density_validIn_iff`, `density_minFrameClass_sharp`, `not_derivable_base_z1` are formula-level
      and survive); update the docstring "exactly the one the matching `Axiom` constructor produces"
- [x] Tests: `TacticsTest` (×8), `TemporalIntegrationTest` (×5), `AxiomsTest`, `DerivationTest`,
      `DerivationPropertyTest`, `ProofSystemSemanticsTest`, `AutomationProofSystemTest` — replace
      `Axiom.connect_future`-style instances with the derived theorems; tests that assert
      `modal_search` closes a TC/UE/TL-shaped goal must now succeed through `@[tmLemma]`
- [x] Tooling named entries (not the exhaustive arms): `BimodalTools/ProofExtractorMain.lean`
      (`F_until_equiv_axiom`, `ctx_until_F`, layer name list 1392-1408),
      `FormulaEnumerator`, `InterestingnessMetrics`, `ProofFirstBenchmark`,
      `BenchmarkAnchorsMain` — repoint to the derived theorem so dataset coverage is preserved,
      never dropped *(deviation: altered — `ProofExtractorMain`'s four `z1_axiom*` runtime rows cannot be repointed: `z1Thm` is `Classical.choice`-packaged (noncomputable) and the extractor walks trees at runtime; they are deleted in Phase 7 with a reasoned exclusion. `FormulaEnumerator`'s matcher returns `Σ φ, Axiom φ`, so its arms are deleted in Phase 7 and coverage rides on its formula lists. Every other named entry is repointed.)*
- [x] Scoped guarded builds: `FormalSystem.Metalogic.Conservativity`, `FormalSystem.MinusLanguage`,
      `FormalSystem.PlusLanguage`, `FormalSystem.StarLanguage`, `FormalSystem.Metalogic.Independence`,
      `BimodalTest`, `BimodalTools`, `BimodalToolsTest`

**Timing**: 2 hours

**Depends on**: 5

**Verification Tier**: interface

**Scope Hypothesis**: This phase asserts the Independence results 10 and 11 need only their two
shape-pin `example`s and prose retargeted (carried from the report §Findings "Semantic results
that mention the constructors by name but are formula-level"); confirm with
`grep -n "Axiom\.\(z1\|density\)" FormalSystem/Metalogic/Independence/*.lean` — every hit must be
a shape pin, a docstring, or a `validIn`-level name.

**Tier Justification**: The `Backward.lean` import addition and the retargeted shape pins change what dependents elaborate against, so the covering check is the scoped guarded build of each touched library target enumerated in the last task (the direct dependents of every touched module); no cheaper tier covers an import-graph change.

**Files to modify**:
- `FormalSystem/Metalogic/Conservativity/Backward.lean` - import `CompletenessDerived`; `z1_translate` consumes `z1Derivable`
- `FormalSystem/Metalogic/Conservativity/MinusTemporalDerived.lean` - TL repoint
- `FormalSystem/Metalogic/Conservativity/SpCountermodel.lean` - TL repoint
- `FormalSystem/MinusLanguage/AxiomDischarge.lean` - TC/DN/TL repoint; asset table docstring
- `FormalSystem/Metalogic/Conservativity/Plus/AxiomValidity.lean` - repoint to `plusValidIn_of_tm_deriv`
- `FormalSystem/Metalogic/Independence/DenseRTimeSharpness.lean` - shape pin retarget
- `FormalSystem/Metalogic/Independence/ZTimeSharpness.lean` - shape pin retarget
- `Tests/BimodalTest/**/*.lean` - the seven test files named above
- `BimodalTools/ProofExtractorMain.lean` - named entries repoint
- `BimodalTools/FormulaEnumerator.lean` - matchers repoint
- `BimodalTools/InterestingnessMetrics.lean` - named entries
- `BimodalTools/ProofFirstBenchmark.lean` - named entries
- `BimodalTools/BenchmarkAnchorsMain.lean` - named entries

**Verification**:
- Every scoped guarded build exits 0 (an import cycle from `Backward.lean` is an immediate error)
- `grep -rn "Axiom\.\(until_F\|F_until_equiv\|connect_future\|discrete_symm_fwd\|discrete_propagate_fwd\|discrete_propagate_bwd\|temp_linearity\|density\|z1\)\b" FormalSystem Tests BimodalTools --include=*.lean | grep -v "^\s*--"` now returns only exhaustive `match` arms, soundness/validity/C3 lemma names, `AxiomNames`/`MachineAppendixMain` tables, `ProofSearch/Core.lean` matcher arms, `Search.lean`'s `axiomCtors`, and docstrings — Phase 7's deletion set

---

### Phase 7: Delete the nine constructors — the single whole-tree rebuild [COMPLETED]

**Goal**: In one pre-declared atomic batch, delete the nine constructors and their
`minFrameClass` rows from `Axioms.lean`, delete every exhaustive-match arm, matcher, and table
entry that enumerates them, delete `z1_in_frame`, retract the one-line underivability claim in
the `temp_linearity` docstring, update the count pins C14 checks, and verify with one guarded
full build of all four libraries.

**Tasks**:
- [x] `bash .claude/scripts/git-snapshot.sh 788 --no-revert` (defensive checkpoint, non-reverting)
- [x] `FormalSystem/ProofSystem/Axioms.lean`: delete constructors `until_F` (270), `temp_linearity`
      (280), `F_until_equiv` (289), `connect_future` (199), `discrete_symm_fwd` (305),
      `discrete_propagate_fwd` (311), `discrete_propagate_bwd` (319), `z1` (363), `density` (374)
      with their docstrings; delete the `density _ => .Dense` and `z1 _ => .ZTime` rows (666, 669)
      and the base rows for the other seven from `minFrameClass`; the Layer 3b comment (272)
      goes with its two constructors
- [x] Soundness arms: `Metalogic/Soundness.lean:1245` and neighbours,
      `SoundnessLemmas/FrameClassVariants.lean:729` and neighbours, reflect-time soundness arms;
      the formula-level lemmas `until_F_valid`, `F_until_equiv_validIn`, `temp_linearity_validIn`,
      `density_valid`, `z1_valid`, `discrete_*_reflect_time_valid` stay (they are consumed by
      Phases 3-4 and the Independence results)
- [x] C3 `ConvexConsequence/SurvivalTable.lean:79,114` arms (the `c3_*` results about the formulas
      stay, following `Mirrors.lean`'s precedent for derived schemata);
      `Independence/CoarsenedModels.lean:524,633`; `Conservativity/Plus/AxiomValidity.lean` arms;
      `PlusLanguage/Derivation.lean:204-220`, `StarLanguage/Embedding.lean:113-138` dead arms *(deviation: altered — `StarLanguage/Embedding.lean`'s arms match over `PlusAxiom` (whose constructors stay), so they are live, not dead, and are untouched; the TM-matching arms in `PlusLanguage/Derivation.lean` AND the plan-unlisted `PlusLanguage/Substitution.lean` (`PlusAxiom.ofTMSubst`) were deleted)*
- [x] `Automation/ProofSearch/Core.lean:382-473`: delete the nine matcher arms; *(completed; additionally seven computable derived arms — TC, UT, UE, TL, NP, NF, NA — were added to `mirrorCandidate` so the runtime engine keeps closing those shapes at Base)*
      `Automation/Tactics/Search.lean:115-132`: delete the nine `axiomCtors` entries and fix the
      comment counts
- [x] `Decidability/Verified/RuleSpec.lean` constructor-enumeration section: remove the nine *(deviation: skipped — probe (definition lookup): that section enumerates `TableauRule` constructors (`allTableauRules`), not `Axiom` ones; nothing to remove)*
- [x] `Metalogic/WeakCanonical/FrameProperties.lean:28-33`: delete `z1_in_frame` and its BLOCKED
      docstring (`prior_UZ_in_frame`/`prior_SZ_in_frame` untouched)
- [x] Tooling: `BimodalTools/AxiomNames.lean` (20-name list; header), `MachineAppendixMain.lean`
      (one `mkAxiomEntry` per deleted constructor removed; assertion at 423-424 → 20; docstring
      counts at 16, 38, 69, 72, 183, 414, 437), `ProofStepExtractor`/`DatasetGenerator` exhaustive
      name matches, `FormulaEnumerator` matcher arms *(completed: the nine `mkAxiomAtIdx` arms deleted and the index space renumbered 0-19 with `pickSchemaIdx` ranges updated; `ProofExtractorMain`'s four `z1_axiom*` runtime rows deleted — `z1Thm` is noncomputable — and `Tests/BimodalToolsTest/ProofFirstTests.lean` re-pinned to 20; two further exhaustive matches the plan did not list, `Independence/RationalWitness.lean` and `Independence/LexIntWitness.lean`, lost their `z1` arms)*
- [x] Tests: delete arms/`#guard`s that enumerate the constructors (`AxiomsTest` count guards)
- [x] Count pins (literal `29` → `20`, by-class `Base 17 / Dense 1 / ZTime 1 / RTime 2`): run
      `bash scripts/check-module-invariants.sh --no-build` and fix exactly what C14 flags in
      `docs/`, `README.md`, and `FormalSystem/*.lean` (research inventory: `docs/ARCHITECTURE.md:135`,
      `docs/user-guide/architecture.md:1112,1584,1586`, `docs/project-info/{FEATURE_REGISTRY.md:20,implementation-status.md:32,36,78,known-limitations.md:381}`,
      `docs/reference/axiom-reference.md:7,49,426-428`, `docs/development/MODULE_ORGANIZATION.md:335`,
      `FormalSystem/README.md:93,306,406`, `FormalSystem/ProofSystem.lean:17`,
      `FormalSystem/Automation.lean:98`, `FormalSystem/Metalogic/README.md:347`,
      `Metalogic/ConvexConsequence.lean:36` + `ConvexConsequence/README.md:26`, `Soundness.lean:911`,
      `FrameClassVariants.lean:18`, `scripts/check-module-invariants.sh:2009` note text,
      `Axioms.lean:72,133,654`); narrative prose waits for Phase 9
- [x] One guarded full build: `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build`
      (default target `FormalSystem`), then `-- build BimodalTest BimodalTools BimodalToolsTest`;
      detached, un-piped exit capture; do not iterate `Axioms.lean` across partial builds
- [x] `lean_verify` on all eleven Goals identifiers (no `sorryAx`)

**Timing**: 2 hours (agent effort; the detached full-build wall-clock is wait time)

**Depends on**: 5, 6

**Verification Tier**: full

**Commit Mode**: atomic-batch

**Scope Hypothesis**: This phase asserts ~130 exhaustive-match arms over ~25 files and 20
count-pin sites (carried from the report §Findings "Blast radius" and "Count pins",
CARRIED-UNVERIFIED as to the exact counts); confirm by letting the compiler enumerate every
missing/extra arm at a named line and by `check-module-invariants.sh --no-build` C14's own report
of stale counts — the plan does not pre-commit to the figures.

**Tier Justification**: The `Axiom` inductive is a core type every module in all four libraries elaborates against, so no enumerated-dependent set is smaller than the whole tree; the covering check is the guarded full build of `FormalSystem`, `BimodalTest`, `BimodalTools`, and `BimodalToolsTest` plus `bash scripts/check-module-invariants.sh --no-build`, and `bash .claude/scripts/verify-deploy.sh` for the gate set it aggregates.

**Files to modify**:
- `FormalSystem/ProofSystem/Axioms.lean` - delete nine constructors, `minFrameClass` rows, Layer 3b comment, counts at 72/133/654
- `FormalSystem/Metalogic/Soundness.lean` - delete arms; count at 911
- `FormalSystem/Metalogic/SoundnessLemmas/FrameClassVariants.lean` - delete arms; count at 18
- `FormalSystem/Metalogic/ConvexConsequence/SurvivalTable.lean` - delete arms
- `FormalSystem/Metalogic/ConvexConsequence.lean` - count at 36
- `FormalSystem/Metalogic/Independence/CoarsenedModels.lean` - delete arms
- `FormalSystem/Metalogic/Conservativity/Plus/AxiomValidity.lean` - delete arms
- `FormalSystem/PlusLanguage/Derivation.lean` - delete dead arms
- `FormalSystem/StarLanguage/Embedding.lean` - delete dead arms
- `FormalSystem/Automation/ProofSearch/Core.lean` - delete nine matcher arms
- `FormalSystem/Automation/Tactics/Search.lean` - delete nine `axiomCtors` entries
- `FormalSystem/Automation.lean` - count at 98
- `FormalSystem/ProofSystem.lean` - count at 17
- `FormalSystem/Metalogic/Decidability/Verified/RuleSpec.lean` - constructor enumeration
- `FormalSystem/Metalogic/WeakCanonical/FrameProperties.lean` - delete `z1_in_frame`
- `BimodalTools/AxiomNames.lean` - 20-name list
- `BimodalTools/MachineAppendixMain.lean` - entries, assertion `20`, docstring counts
- `BimodalTools/ProofStepExtractor.lean` - exhaustive name matches
- `BimodalTools/DatasetGenerator.lean` - exhaustive name matches
- `BimodalTools/FormulaEnumerator.lean` - matcher arms
- `Tests/BimodalTest/**/*.lean` - constructor-enumerating guards
- `docs/ARCHITECTURE.md` - count pin
- `docs/user-guide/architecture.md` - count pins
- `docs/project-info/FEATURE_REGISTRY.md` - count pin
- `docs/project-info/implementation-status.md` - count pins
- `docs/project-info/known-limitations.md` - count pin
- `docs/reference/axiom-reference.md` - count pins (narrative in Phase 10)
- `docs/development/MODULE_ORGANIZATION.md` - count pin
- `FormalSystem/README.md` - count pins
- `FormalSystem/Metalogic/README.md` - count pin
- `FormalSystem/Metalogic/ConvexConsequence/README.md` - count pin
- `scripts/check-module-invariants.sh` - note text at 2009

**Verification**:
- Guarded full build of all four libraries exits 0 (un-piped `GUARD_EXIT`)
- `grep -rn "Axiom\.\(until_F\|F_until_equiv\|connect_future\|discrete_symm_fwd\|discrete_propagate_fwd\|discrete_propagate_bwd\|temp_linearity\|density\|z1\)\b" FormalSystem Tests BimodalTools --include=*.lean | grep -v "^\s*--"` returns nothing outside docstrings
- `grep -rn "z1_in_frame" FormalSystem Tests BimodalTools` returns nothing
- `bash scripts/check-module-invariants.sh --no-build` exits 0 (C14 green)
- `bash .claude/scripts/verify-deploy.sh` exits 0
- `lean_verify` on all eleven Goals identifiers reports no `sorryAx`

---

### Phase 8: Regenerate Typst/tooling outputs and diff the baselines [NOT STARTED]

**Goal**: Regenerate `typst/generated/*` from the reduced tree and confirm the sync checks and
dataset/benchmark baselines agree with it.

**Tasks**:
- [ ] `bash scripts/typst-status-counts.sh` → `typst/generated/status.typ`
- [ ] `bash scripts/typst-machine-appendix.sh` → `typst/generated/machine-appendix.jsonl` and
      `machine-appendix.typ` (interpreter path; needs
      `lake build BimodalTools.MachineAppendixMain` oleans from Phase 7); consider adding the
      derived schemata as "derived theorem" rows so the Typst reference does not silently lose
      them — record the decision either way in the commit
- [ ] `bash scripts/typst-sync-check.sh` (CHECK3 live count vs appendix)
- [ ] `bash scripts/generate-decidability-inventory.sh --diff`; diff
      `scripts/c20-declaration-baseline.txt` and `scripts/certificate-witness-inventory.txt`
      against the tree with their own tooling; regenerate benchmark anchors if
      `BenchmarkAnchorsMain` output changed (`lake exe benchmark_anchors` via the guard)
- [ ] `bash scripts/check-module-invariants.sh --no-build` (C2/C14 baselines)

**Timing**: 1 hour

**Depends on**: 7

**Verification Tier**: local

**Scope Hypothesis**: This phase asserts only generated artifacts and baseline inventories change
(no Lean source); confirm with `git status --short` showing changes confined to `typst/generated/`,
`scripts/*-baseline*.txt`, `scripts/certificate-witness-inventory.txt`, and benchmark data files.

**Tier Justification**: `bash scripts/typst-sync-check.sh`, `bash scripts/check-module-invariants.sh --no-build`, and `bash scripts/generate-decidability-inventory.sh --diff` (each checked by exit status) are the complete covering check: the touched files are generated outputs whose only consumers are those same checks.

**Files to modify**:
- `typst/generated/status.typ` - regenerated
- `typst/generated/machine-appendix.jsonl` - regenerated
- `typst/generated/machine-appendix.typ` - regenerated
- `scripts/decidability-inventory-baseline.txt` - re-baselined if the diff is explained
- `scripts/c20-declaration-baseline.txt` - re-baselined if the diff is explained
- `scripts/certificate-witness-inventory.txt` - re-baselined if the diff is explained

**Verification**:
- `typst-sync-check.sh`, `check-module-invariants.sh --no-build`, and
  `generate-decidability-inventory.sh --diff` all exit 0
- `machine-appendix.jsonl` metadata line reports 20 axiom entries

---

### Phase 9: Lean-side prose: `Axioms.lean` docstring, `LinearityDerivedFacts.lean`, module READMEs [NOT STARTED]

**Goal**: Refresh every Lean-resident docstring and module README that narrates the axiom set,
and rewrite `LinearityDerivedFacts.lean` as the short record the research specifies. Prose only;
no declaration changes.

**Tasks**:
- [ ] `Axioms.lean` module docstring: `### Layers` (40-72) and the nine-layer paragraph (133) now
      describe 20 constructors by layer; Axiom Sources table rows for UE and TL (and the line-110
      sentence on TC, UT, NP, NF, NA) say "derived — see `DerivedAxioms.untilF`" etc.; the
      line-212 REMOVED note gains "TL, UE, UT, TC, NP, NF, NA, DN, Z1 are derived
      (`ConnectDerived`, `LinearityDerived`, `CompletenessDerived`)"; the Layer 7/8 comments
      (348, 365) are deleted with their constructors in Phase 7 — confirm nothing dangling
- [ ] `LinearityDerivedFacts.lean` (prose-only module, imported by `ProofSystem.lean`): replace
      the docstring with (i) the branching frame `{0, 1a, 1b}` refutes the CN instance
      `linear_until (Fp) p (Fq) q` at 0, so it is not a model of the current base and is not an
      independence witness; (ii) TL is derived from CN + UF + UE (`LinearityDerived.tempLinearity`),
      with Xu 1988 §3 (Σ₄ complete for 𝒞₄ without A4a) and §4 Thm 4.3 ((13) strictly weaker than
      (10)) as the literature anchors; (iii) a historical note that TL was once primitive because
      CN was absent; delete the "currently believed impossible" remediation list; keep the
      Goldblatt/Blackburn references
- [ ] `DerivedAxioms.lean` docstring: final derived-stock list
- [ ] `ConnectDerived.lean`, `LinearityDerived.lean`, `CompletenessDerived.lean` docstrings: name
      the primitives each derivation uses (as in the Research Integration bullets)
- [ ] `Metalogic/Independence/README.md` results 10 and 11 and `FormalSystem/MainResults.lean:260-295`:
      `Axiom.z1`/`Axiom.density` → "the Z1/DN formula (now `z1Thm`/`density`)"; the sharpness
      results are about formulas and are unchanged in content
- [ ] `FormalSystem/README.md`, `FormalSystem/Metalogic/README.md`, `ConvexConsequence/README.md`,
      `ProofSystem.lean`, `Automation.lean:98` ("27 of the 29" → the new ratio),
      `Soundness.lean:911`, `FrameClassVariants.lean:18`, `Decidability/Verified/RuleSpec.lean`
      docstrings: narrative consistent with 20 primitives + derived stock
- [ ] Add the "where a derived schema lives" note to `FormalSystem/Theorems/README.md` (or
      `ProofSystem/README.md`): `ProofSystem/` imports only `Syntax`; `Combinators` extends
      `DerivedAxioms`; the chain `Combinators → DeductionTheorem → Propositional.Core → Connectives
      → GeneralizedNecessitation → ConnectDerived → TemporalDerived → LinearityDerived →
      DedekindDerived`
- [ ] Diff read-through confirming every hunk is inside a `/-! -/`, `/-- -/`, `--`, or markdown
      region; `bash scripts/readme-lint.sh`; `bash .claude/scripts/verify-deploy.sh --only-gate 4`

**Timing**: 2 hours

**Depends on**: 7

**Verification Tier**: prose

**Scope Hypothesis**: This phase asserts the `Axioms.lean` Sources table has exactly two rows
(UE, TL) naming demoted constructors and one sentence (line 110) naming the other five; confirm
with `grep -n "until_F\|temp_linearity\|TC, UT" FormalSystem/ProofSystem/Axioms.lean` before
editing.

**Tier Justification**: Every hunk is confined to Lean docstrings/comments and markdown with no elaboration surface, so the diff read-through plus `bash scripts/readme-lint.sh` and `bash .claude/scripts/verify-deploy.sh --only-gate 4` (task-reference lint in this deploy-consumer tree; gate 3 would SKIP here) is the complete covering check, and the final phase's full build observes the docstring boundaries.

**Files to modify**:
- `FormalSystem/ProofSystem/Axioms.lean` - module docstring: Layers, counts, Sources table, REMOVED note
- `FormalSystem/ProofSystem/LinearityDerivedFacts.lean` - rewrite as the CN/TL record
- `FormalSystem/ProofSystem/DerivedAxioms.lean` - docstring list
- `FormalSystem/Theorems/ConnectDerived.lean` - docstring
- `FormalSystem/Theorems/LinearityDerived.lean` - docstring
- `FormalSystem/Metalogic/CompletenessDerived.lean` - docstring
- `FormalSystem/Metalogic/Independence/README.md` - results 10, 11 prose
- `FormalSystem/MainResults.lean` - prose at 260-295
- `FormalSystem/README.md` - narrative
- `FormalSystem/Metalogic/README.md` - narrative
- `FormalSystem/Metalogic/ConvexConsequence/README.md` - narrative
- `FormalSystem/ProofSystem.lean` - docstring
- `FormalSystem/Automation.lean` - docstring at 98
- `FormalSystem/Metalogic/Soundness.lean` - docstring at 911
- `FormalSystem/Metalogic/SoundnessLemmas/FrameClassVariants.lean` - docstring at 18
- `FormalSystem/Metalogic/Decidability/Verified/RuleSpec.lean` - docstrings
- `FormalSystem/Theorems/README.md` - derived-schema placement note

**Verification**:
- `git diff` read-through: no hunk outside comment/docstring/markdown regions
- `grep -n "NOT derivable\|believed impossible" FormalSystem/ProofSystem/Axioms.lean FormalSystem/ProofSystem/LinearityDerivedFacts.lean` returns nothing
- `bash scripts/readme-lint.sh` and `bash .claude/scripts/verify-deploy.sh --only-gate 4` exit 0

---

### Phase 10: Documentation refresh and the full gate set [NOT STARTED]

**Goal**: Refresh the three documents the task names plus the architecture/project-info pages,
then run the complete gate set over the finished tree.

**Tasks**:
- [ ] `docs/reference/axiom-reference.md`: §Paper Key Correspondence gains a "primitive vs
      derived" column (UE, UT, TC, NP, NF, NA, TL, DN, Z1 → derived, with the fully qualified
      theorem name); the count paragraph (426-428) describes 20 primitives by layer and class
- [ ] `docs/reference/paper-definitions-of-record.md`: a dated amendment under the "Constructor
      naming audit: closed" paragraph (line 209) — the tree's primitive set is now a proper
      subset of `def:BX`'s list with the same theorems; TL derived from CN (A4a not restored);
      link to `LinearityDerivedFacts.lean` as the derivation record; keep the existing footnote
      errata (the "UE follows from UC" erratum is confirmed as UG)
- [ ] `docs/theorem-index.md`: rows for `untilF`, `fUntilEquiv`, `discretePropagateFwd`,
      `discretePropagateFwdMirror`, `connectFuture`, `discreteSymmFwd`, `discretePropagateBwd`,
      `tempLinearity`, `density`, `z1Derivable`, `z1Thm` with fully qualified names and the
      primitives each uses; remove rows that pointed at the deleted constructors
- [ ] `docs/ARCHITECTURE.md`, `docs/user-guide/architecture.md`, `docs/project-info/*`,
      `docs/development/MODULE_ORGANIZATION.md`: narrative (counts were fixed in Phase 7); note
      that `ProofSystem/` still imports only `Syntax` (`ARCHITECTURE.md:135`)
- [ ] Do not edit `typst/FormalFoundations.typ` (paper's own `def:BX`); the divergence lives in
      the `paper-definitions-of-record.md` amendment
- [ ] Full gate set: guarded full build `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build`
      and `-- build BimodalTest BimodalTools BimodalToolsTest`; `lean_verify` on the eleven Goals
      identifiers; `bash scripts/check-module-invariants.sh --no-build`;
      `bash scripts/typst-sync-check.sh`; `bash scripts/check-paper-definitions.sh`;
      `bash scripts/readme-lint.sh`; `bash .claude/scripts/lean-challenge-snapshot.sh --check`
      (advisory); `bash .claude/scripts/verify-deploy.sh`; record each exit status

**Timing**: 2 hours

**Depends on**: 8, 9

**Verification Tier**: full

**Scope Hypothesis**: This phase asserts the three task-named documents plus five
architecture/project-info pages are the complete non-count documentation surface (carried from
the report's Recommendation 5); confirm with `grep -rln "until_F\|temp_linearity\|F_until_equiv\|connect_future\|discrete_symm_fwd\|discrete_propagate\|Axiom.density\|Axiom.z1\|29 axiom" docs README.md` after editing — every remaining hit must be historical prose explicitly marked as such.

**Files to modify**:
- `docs/reference/axiom-reference.md` - primitive-vs-derived column; count paragraph narrative
- `docs/reference/paper-definitions-of-record.md` - dated amendment
- `docs/theorem-index.md` - new rows; removed rows
- `docs/ARCHITECTURE.md` - narrative
- `docs/user-guide/architecture.md` - narrative
- `docs/project-info/FEATURE_REGISTRY.md` - narrative
- `docs/project-info/implementation-status.md` - narrative
- `docs/project-info/known-limitations.md` - narrative
- `docs/development/MODULE_ORGANIZATION.md` - narrative

**Verification**:
- Guarded full build of all four libraries exits 0 (un-piped `GUARD_EXIT`)
- `lean_verify` on all eleven Goals identifiers: no `sorryAx`
- `bash scripts/check-module-invariants.sh --no-build`, `bash scripts/typst-sync-check.sh`,
  `bash scripts/check-paper-definitions.sh`, `bash scripts/readme-lint.sh`, and
  `bash .claude/scripts/verify-deploy.sh` each exit 0
- `bash .claude/scripts/lean-challenge-snapshot.sh --check` reports no drift (advisory)
- `grep -c "^  | " FormalSystem/ProofSystem/Axioms.lean`-style constructor count of the
  `inductive Axiom` block is 20

## Lean Challenge Statements

```lean
import FormalSystem.ProofSystem.Derivable
import FormalSystem.Theorems.TemporalDerived

open FormalSystem.Syntax
open FormalSystem.ProofSystem

namespace FormalSystem.ProofSystem.DerivedAxioms

def untilF {fc : FrameClass} (φ ψ : Formula) :
    ⊢[fc] (Formula.untl φ ψ).imp (Formula.someFuture ψ) := sorry

def fUntilEquiv {fc : FrameClass} (φ : Formula) :
    ⊢[fc] (Formula.someFuture φ).imp (Formula.untl (Formula.bot.imp Formula.bot) φ) := sorry

def discretePropagateFwd {fc : FrameClass} :
    ⊢[fc] (Formula.untl Formula.bot (Formula.bot.imp Formula.bot)).imp
      (Formula.allFuture (Formula.untl Formula.bot (Formula.bot.imp Formula.bot))) := sorry

def discretePropagateFwdMirror {fc : FrameClass} :
    ⊢[fc] (Formula.snce Formula.bot (Formula.bot.imp Formula.bot)).imp
      (Formula.allPast (Formula.snce Formula.bot (Formula.bot.imp Formula.bot))) := sorry

end FormalSystem.ProofSystem.DerivedAxioms

namespace FormalSystem.Theorems.ConnectDerived

def connectFuture {fc : FrameClass} (φ : Formula) :
    ⊢[fc] φ.imp (φ.somePast.allFuture) := sorry

def discreteSymmFwd {fc : FrameClass} :
    ⊢[fc] (Formula.untl Formula.bot (Formula.bot.imp Formula.bot)).imp
      (Formula.snce Formula.bot (Formula.bot.imp Formula.bot)) := sorry

def discretePropagateBwd {fc : FrameClass} :
    ⊢[fc] (Formula.untl Formula.bot (Formula.bot.imp Formula.bot)).imp
      (Formula.allPast (Formula.untl Formula.bot (Formula.bot.imp Formula.bot))) := sorry

end FormalSystem.Theorems.ConnectDerived

namespace FormalSystem.Theorems.LinearityDerived

def tempLinearity {fc : FrameClass} (φ ψ : Formula) :
    ⊢[fc] (Formula.and (Formula.someFuture φ) (Formula.someFuture ψ) |>.imp
      (Formula.or (Formula.someFuture (Formula.and (Formula.someFuture φ) ψ))
        (Formula.or (Formula.someFuture (Formula.and φ ψ))
          (Formula.someFuture (Formula.and φ (Formula.someFuture ψ)))))) := sorry

def density {fc : FrameClass} (h : FrameClass.Dense ≤ fc) (φ : Formula) :
    ⊢[fc] φ.allFuture.allFuture.imp φ.allFuture := sorry

end FormalSystem.Theorems.LinearityDerived

namespace FormalSystem.Metalogic.CompletenessDerived

theorem z1Derivable (φ : Formula) :
    Derivable FrameClass.ZTime []
      ((φ.allFuture.imp φ).allFuture.imp (φ.allFuture.someFuture.imp φ.allFuture)) := sorry

noncomputable def z1Thm (φ : Formula) :
    ⊢[FrameClass.ZTime]
      ((φ.allFuture.imp φ).allFuture.imp (φ.allFuture.someFuture.imp φ.allFuture)) := sorry

end FormalSystem.Metalogic.CompletenessDerived
```

## Testing & Validation

- [ ] Every new declaration passes `lean_verify` with no `sorryAx` (Phases 1-4, re-checked in 7
      and 10)
- [ ] `inductive Axiom` has exactly 20 constructors; `minFrameClass` has no `density`/`z1` rows
- [ ] No non-comment reference to the nine deleted constructor names in `FormalSystem/`, `Tests/`,
      `BimodalTools/`; `z1_in_frame` absent
- [ ] Guarded full build of `FormalSystem`, `BimodalTest`, `BimodalTools`, `BimodalToolsTest`
      exits 0 (Phase 7 and Phase 10)
- [ ] `Tests/BimodalTest/Automation/WeakeningSearchTest.lean:74` (density-shaped goal at the Dense
      gate) and the TC/UE/TL tactic tests pass through `@[tmLemma]`/`tryGatedDerivedMatch`
- [ ] `check-module-invariants.sh --no-build` (C14), `typst-sync-check.sh` (CHECK3),
      `check-paper-definitions.sh`, `readme-lint.sh`, `verify-deploy.sh` all exit 0
- [ ] `lean-challenge-snapshot.sh --check` reports no statement drift (advisory)
- [ ] Independence results 10 and 11 still build with their shape pins retargeted at
      `z1Thm`/`density`

## Artifacts & Outputs

- `FormalSystem/ProofSystem/DerivedAxioms.lean` (extended), `FormalSystem/Theorems/ConnectDerived.lean`
  (new), `FormalSystem/Theorems/LinearityDerived.lean` (new),
  `FormalSystem/Metalogic/CompletenessDerived.lean` (new)
- `FormalSystem/ProofSystem/Axioms.lean` reduced to 20 constructors; `LinearityDerivedFacts.lean`
  rewritten as the CN/TL record
- Regenerated `typst/generated/{status.typ,machine-appendix.jsonl,machine-appendix.typ}`
- Refreshed `docs/reference/axiom-reference.md`, `docs/reference/paper-definitions-of-record.md`
  (dated amendment), `docs/theorem-index.md`, architecture/project-info pages
- `specs/788_reduce_tm_and_extensions_to_minimal_axiom_sets/summaries/01_reduce-tm-minimal-axiom-sets-summary.md`
  (written at implementation close)

## Rollback/Contingency

- Phases 1-4 are purely additive (new declarations, new modules, two body-only mirror repoints):
  revert their commits individually; nothing else depends on them until Phase 5.
- Phases 5-6 repoint while the constructors still exist, so any single substep can be reverted
  to the previous green commit without touching `Axioms.lean`.
- Phase 7 is the one irreversible-looking step. It is preceded by
  `git-snapshot.sh 788 --no-revert` and committed as one atomic batch; if the full build cannot
  be made green within the dispatch, revert the batch to the snapshot (the sanctioned
  `git-snapshot.sh 788` rollback rung from `context/contracts/recovery.md`, task number explicit)
  and leave Phases 1-6 in place — the tree is then a valid state with the derived theorems
  coexisting with the primitives.
- If `derivable_of_validZTime` turns out to depend on `Axiom.z1` after all (the research measured
  it does not), fall back to the direct Z1 derivation sketched in the report (UZ + mirror +
  CN-mirror + US + UF + UE + TC) as a new `LinearityDerived`-level theorem; Phase 4's module then
  becomes the term packaging only.
- Generated Typst outputs and baselines (Phase 8) are regenerated, never hand-edited, so a bad
  regeneration is rerun, not patched.
