# Seed Report: Porting cslib's Sublogics and Generic Infrastructure Back into BimodalLogic

- **Task**: 803 - Port the relevant, self-authored cslib sublogics and generic infrastructure back into BimodalLogic
- **Started**: 2026-10-15
- **Completed**: 2026-10-15 (seed only; the research round starts from here)
- **Effort**: ESTIMATE for the research round: 3 to 5 working days. One pin-distance measurement, one Boneyard reconciliation, one consumer census, one build-in-isolation probe per unit, ten unit verdicts, one on-disk placement ruling.
- **Dependencies**: none recorded. Territory overlap with the Stage 1 decidability tasks (761, 763, 714) is real for one unit (U7) and is the reason that unit is deferred, not a dependency edge.
- **Sources/Inputs** (all MEASURED on the working trees at the revisions below unless labelled otherwise):
  - `~/Projects/cslib` at `3bdf16d` ("task 620: complete implementation"), the fork `benbrastmckie/cslib`
  - this repository at `0d8f017`
  - `Boneyard/README.md`, `Boneyard/Kamp/KampWeakCanonical/Separation/README.md`, `Boneyard/ConservativeExtension/`
  - `docs/development/MODULE_SYSTEM_EVALUATION.md`, `docs/development/MODULE_INVARIANTS.md`, `docs/development/MODULE_ORGANIZATION.md`, `docs/development/MODULE_RELOCATION.md`, `ORGANISATION.md`, `scripts/measure-refactor-partitions.py`
  - `specs/TODO.md` task 741 (the external-library-port-assessment pattern, and the scope of the earlier "port nothing" verdict)
  - cslib's `specs/ROADMAP.md` ("Porting BimodalLogic to CSLib") and its `Authors:` headers
- **Artifacts**: this report
- **Standards**: report-format, artifact-formats

## Project Context

- **Upstream Dependencies**: none in the Lake sense. This task adds no `require`. cslib is a source of files to copy, convert and re-base, exactly as cslib's own port of this repository was.
- **Downstream Dependents**: task 798 (the eleven unported modal-temporal interaction theorems) and task 802 (deriving every cited TM theorem) both touch `Theorems/`; a generic-theorem layer (U8) would change where those derivations live. Task 177 (README and docs polish) must run after any directory this task adds.
- **Alternative Paths**: leave every unit in cslib and keep treating it as a read-only reference. That is the current state and the default verdict for any unit whose research round finds no consumer here.
- **Potential Extensions**: once a sublogic directory exists, the paper's own BX tense logic (def:BX, def:BX-z, def:BX-d, def:BX-r) could be stated as a standalone logic with its own completeness, matching the way task 802 already reads the paper ("a theorem of TM, or of BX and its extensions").

## Executive Summary

- Nothing legal or technical forbids the port. Both repositories are Apache-2.0; both pin Lean `v4.33.0-rc1`; the headers are byte-identical in form; all but a handful of cslib's logic files carry `Authors: Benjamin Brast-McKie` alone. The earlier "port nothing" verdict (task 736, recorded in 741) ruled on upstream cslib's omega-automata as a dependency for L⁺ decidability, and the "no cslib require" guardrails in 763 and 781 forbid a Lake edge. Neither rules on copying self-authored code.
- cslib's logic trees divide into two provenance classes, measured by the `Ported from BimodalLogic` docstring marker: 63 files are ports of this repository (53 in `Logics/Bimodal/Metalogic`, 8 in `Logics/Bimodal/Theorems`, 2 in `Logics/Bimodal/Syntax`); the other 645 were authored in cslib. Only the second class is a port candidate. Two of its sub-trees are maintained continuations of developments this repository archived to `Boneyard/`: the GHR separation theorem and the `ConservativeExtension/` ext-formula lifting layer.
- Ten units are named below. Three are recommended for the first wave (the proof-system morphism engine, the generic MCS seam, and the sublogic triple with its three conservativity theorems). Two need git archaeology before a verdict (the separation theorem, the parametric algebraic completeness). Four are declined or deferred with the reason stated (frame-condition typeclasses, the generic tableau substrate, the Chronicle interface, Hilbert search). One (the generic theorem layer) is conditional on the first two landing.
- The sublogic triple is the unit the owner named. It is not free: `bimodal_conservative_over_{cpl,s5,temporal}` each route through the sublogic's own completeness theorem, so the port carries a propositional, an S5 and a temporal logic with completeness, not just three embeddings. cslib's temporal logic also axiomatizes BX with 26 primitive schemata (past mirrors primitive) where this repository uses 7 future-direction schemata plus time reflection; the port must re-base one onto the other.
- Every candidate file is a `module` file. This repository's own evaluation (`MODULE_SYSTEM_EVALUATION.md`) rules the module system out for now, so each ported file is converted to plain-import form. The conversion is mechanical and is specified below; it is the same operation in reverse that cslib's port performed.
- The decisive first gate is the Mathlib pin distance (this repository: tag `79d0395a`; cslib: commit `169c26b5`, both on the `v4.33.0-rc1` toolchain), which could not be measured here because neither checkout carries a `.lake/`. Task 741's pattern names this gate first and names 76 commits as the figure that was decisive last time.

## Context and Scope

The owner's framing, after the strategy discussion of 2026-10-15: the sublogics are carefully arranged in cslib, and the question is how to port the relevant, self-authored parts back into this repository systematically. SPSLib and its book convention are out of this task's scope (that discussion concluded against both a port into SPSLib and a convention refactor here).

Evidence labels: **MEASURED** read from one of the two trees; **VERIFIED-DOC** read in a document of one of the two trees; **PROPOSAL** this report's own.

## Findings

### F1. Provenance and authorship (MEASURED)

| cslib tree | Files | Lines | Authored in cslib | Co-authored files | Sorries |
|---|---:|---:|---|---|---:|
| `Foundations/Logic/` | 42 | 10,635 | yes | 2 Montesi, 1 Montesi+Waring | 0 |
| `Logics/Propositional/` | 121 | 43,520 | yes | 2 Waring+Brast-McKie | 7 lines (3 bare, cslib's own red `--wfail`) |
| `Logics/Modal/` | 163 | 83,533 | yes | 2 Montesi+Brast-McKie, 1 Montesi+Girlando+Brast-McKie | 2 |
| `Logics/Temporal/` | 58 | 20,314 | yes | none | 0 |
| `Logics/Bimodal/` | 139 | 52,470 | 76 files; 63 are `Ported from BimodalLogic` | none | 23 (all in the ported discrete pipeline) |
| `Logics/LTL/` | 12 | 2,750 | yes | none | 0 |

Co-authored files are excluded from every unit below unless their co-authors' contribution is re-attributed; the research round lists them by name.

### F2. The two Boneyard continuations (MEASURED)

| cslib tree | This repository's archive | Archive reason recorded | What cslib's copy is |
|---|---|---|---|
| `Logics/Bimodal/Metalogic/Separation/` (17 files, 10,638 lines, sorry-free, `[Infinite Atom]`, GHR94 Theorem 10.2.9 as `all_separable`) | `Boneyard/Kamp/KampWeakCanonical/Separation/` (same eleven file names plus `DedekindZ/`, `Hierarchy/`) | "Bit rot": archived with `ExpressiveCompleteness/` when it stopped typechecking against the live separation development, which then moved on to the zeta route | A maintained, typechecking continuation of the archived route |
| `Logics/Bimodal/Metalogic/ConservativeExtension/{ExtFormula,ExtDerivation,Substitution,Lifting}.lean` | `Boneyard/ConservativeExtension/` (same four files) | Zero live importers; reachable only from a deleted aggregator | The same layer, now with three live consumers (`*Conservativity.lean`) |

A defect found on the way: `FormalSystem/Metalogic/Expressiveness/Separation/README.md` still lists eleven modules with line counts (`Distributivity`, `Eliminations`, `SeparationThm`, ...) that do not exist in that directory, which holds `Defs`, `KampTranslation` and `SemanticBridge` only. The README's table uses bare file names, which is why C5 and C12 never saw it. The research round should file or fix it.

### F3. The ten candidate units

Sizes are MEASURED; "analogue here" is MEASURED; verdicts are PROPOSAL, to be tested.

| # | Unit (cslib path) | Files / lines | Analogue in this repository | Verdict to test |
|---|---|---:|---|---|
| U1 | Proof-system morphism engine: `Foundations/Logic/Metalogic/ProofSystemMorphism.lean` (`ProofSig`, `ProofSigHom`, `Deriv.map`), plus `Connectives.lean` it depends on | 2 / 545 | The per-language lifts `plusDerivable_of_derivable`, `plus_backward_{base,dense}`, `PlusDerivable.mono`, `PlusAxiom.minFrameClass_ofTM` (`PlusLanguage/Derivation.lean`) and their `StarLanguage`/`MinusLanguage` siblings; cslib's own docstring names this repository's `DerivationTree.lift` and `liftDerivationWith` as two of its four instances | **Port in wave 1.** Modest de-duplication (two to four lift lemmas per extension language), but it is the seam every later unit instantiates |
| U2 | Generic MCS seam: `Foundations/Logic/Metalogic/{Consistency,GenericMCS,ListDeduction,SetDeduction,DeductionCharacterization,DeductionHelpers,MCSProperties,PrimeExclusion}.lean` | 8 / 1,815 | Three separate MCS developments: `Metalogic/Core/MaximalConsistent.lean` (509), `Conservativity/MinusMCS.lean` (398, for TM⁻), `Core/RestrictedMCS/` (368) | **Port in wave 1**, if the research round confirms the three developments can be instances of one seam. cslib's `Bimodal/Core/GenericMCSBridge.lean` is the worked bridge for TM and is itself cslib-authored |
| U3 | Sublogic triple and conservativity: `Logics/Propositional/` core, `Logics/Modal/` S5 core, `Logics/Temporal/`, `Logics/Bimodal/Embedding/` (3 / 288), `Bimodal/Metalogic/ConservativeExtension/` (7 / 2,360) | see F4 | None standalone. `Conservativity/Fragment.lean` gives the H/G-fragment `TMFrag` and `Conservativity/Plus`, `Star` give the extension-language results; there is no propositional, S5 or U/S-temporal logic as an object of its own | **Port in wave 2**, the owner's named unit, at the minimal closure F4 measures. One sorry (`TemporalConservativity.lean`, cslib task 450: TM soundness needs `AddCommGroup D`, temporal completeness an arbitrary serial linear order) must be discharged or the theorem left out, since C3 admits exactly one structural sorry here |
| U4 | GHR separation theorem: `Bimodal/Metalogic/Separation/` | 17 / 10,638 | `Boneyard/Kamp/KampWeakCanonical/Separation/` (archived); live `Expressiveness/Separation/` holds the zeta-route successor | **Archaeology first.** Port only if a live front consumes syntactic separation over ℤ (candidates: 798's interaction theorems, the Kamp pipeline, Stage 1). If ported, it replaces a Boneyard entry and the Boneyard README's taxonomy row is updated; if not, it stays in cslib and the Boneyard README gains one line saying where the maintained copy lives |
| U5 | D-parametric algebraic completeness: `Bimodal/Metalogic/Algebraic/{ParametricCanonical,ParametricCompleteness,ParametricHistory,ParametricTruthLemma,RestrictedParametricTruthLemma}.lean` and `Algebraic.lean` | 6 / ~1,500 | cslib's docstring says "Ported from BimodalLogic/Theories/Bimodal/Metalogic/Algebraic/ParametricCompleteness.lean". No file of that name exists in the live tree, in `Boneyard/`, or in `git log --diff-filter=D` on this history | **Archaeology first.** Establish whether the live `Algebraic/FlowFrame.lean` and `UltrafilterMCS.lean` subsume it (cslib's own roadmap lists "BX+ metric tense base + completeness over group flows" as landed there too) |
| U6 | Frame-condition typeclasses: `Bimodal/FrameConditions/` (`LinearTemporalFrame`, `SerialFrame`, `DenseTemporalFrame`, `DiscreteTemporalFrame`, `AxiomLinearCompatible`) | 4 / 569 | `inductive FrameClass` (`ProofSystem/Axioms.lean`), `FrameClass.Sat` (`Semantics/FrameClassValidity.lean`), `TemporalOrder` | **Decline.** A second frame-class encoding beside the one the whole tree is indexed by. Record the decline |
| U7 | Generic tableau substrate and driver: `Foundations/Logic/Tableau/` (9 / 878) and `Modal/Tableau/{GenericDriver,Saturation,FmpMeasure}.lean` with `RuleApplicationSpec` | 12 / ~2,900 | `Metalogic/Decidability/` (169 files, 98,924 lines): its own `SignedFormula`, `Tableau`, `Saturation`, `Closure`; cslib's `Bimodal/Decidability/` was ported from here before the abstraction was made | **Defer** until 763 lands. The target is the live Stage 1 and Stage 4 front; a substrate port is a refactor of a moving tree and would contend with 761, 763, 714, 428 and 464 for territory |
| U8 | Generic theorem layer: `Foundations/Logic/Theorems/{Combinators,DerivationCombinators,BigConj,Propositional/*,Modal/*,Temporal/*}.lean` | 10 / 2,948 | `Theorems/{Combinators,Propositional/*,ModalS5,ModalS4,TemporalDerived,Perpetuity/*}.lean`, TM-specific over `Derivable` | **Conditional on U1 and U2.** Without the classes, this duplicates `Theorems/`; with them, `Theorems/` becomes instances. Measure the re-derivation cost on `ModalS5.lean` first |
| U9 | Chronicle generic interface: `Foundations/Logic/Metalogic/Chronicle/` | 5 / 2,657 | `BXCanonical/Chronicle/` | **Decline.** cslib's own consolidation was descoped (its roadmap, task 530) because generic lifting broke `rcases`/`simp` on locally indexed Chronicle atoms |
| U10 | `Foundations/Logic/Automation/HilbertSearch.lean` | 1 / 268 | `Automation/ProofSearch/` (2 / 1,671) | **Decline unless** the research round finds a capability the bounded DFS has that `modal_search` lacks |

### F4. The minimal closure of U3 (partly MEASURED, partly to measure)

What each conservativity theorem needs, read from its imports and proof route:

| Theorem | Route | cslib modules reached outside `Bimodal/` |
|---|---|---|
| `bimodal_conservative_over_cpl` | TM-derivable → valid in task models → valid under every Boolean valuation via an adapter → CPL strong completeness → CPL-derivable | `Propositional/{Defs,ProofSystem/*,Semantics/Bool,Metalogic/{Soundness,StrongCompleteness,MCS,DeductionTheorem}}` and `Foundations/Logic/{Axioms,Connectives,ProofSystem,InferenceSystem}` |
| `bimodal_conservative_over_s5` | same shape through a Kripke adapter (`kripkeAdapterOmega`) and S5 completeness | `Modal/{Basic,Metalogic/{DerivationTree,MCS,Soundness,Completeness,FrameCorrespondence},ProofSystem/{SchemaUnion,Instances/S5},Metalogic/Systems/S5/*}`; measured at about 3,100 lines for the S5-only subset |
| `bimodal_conservative_over_temporal` | same shape through `temporal_valid_on_addcommgroup` and temporal completeness over `[Denumerable (Formula Atom)]` | `Temporal/{Syntax,Semantics,ProofSystem,Metalogic/{Completeness,Soundness,MCS,DeductionTheorem,GenericMCSBridge,...}}`; whole tree 20,314 lines, subset unmeasured |

The whole `Propositional/` tree (natural deduction, LJ/LK/LM sequent calculi, three tableau families, the 32-file algebraic semantics) and the whole `Modal/` tree (the fifteen-system cube, intuitionistic, constructive, minimal families, the 49,000-line tableau subsystem) are far beyond what the three theorems need, and TM instantiates none of it. The research round measures the exact closure with `lake exe shake`-style reachability from the three theorems and reports it as the port surface.

Two design mismatches the closure carries, both MEASURED:

- cslib's `Temporal/ProofSystem` is a 26-axiom BX with past mirrors primitive; `ProofSystem/Axioms.lean` here has 7 future-direction BX schemata and derives every past mirror by time reflection (TR). A ported temporal logic must be re-based onto the 7-plus-TR design or the two axiomatizations must be proved equivalent, or the result is a second BX beside the paper's.
- cslib's `Bimodal/Syntax/Formula` and this repository's `Formula` agree on the five primitives, but cslib's `Bimodal` sits on the older `TaskFrame` (nullity, forward composition and converse as fields; 42 axioms). The three conservativity proofs go through `Bimodal.Metalogic.Soundness.Soundness`, which must be re-pointed at this repository's `soundness_validIn`.

### F5. Conversion mechanics (MEASURED on the candidate files)

Every candidate file is a `module` file with `@[expose] public section` and `public import` lines; none uses `import all` or `meta import`; two files (one in `Foundations/Logic`, one in `Propositional`) carry a bare `public` modifier. `MODULE_SYSTEM_EVALUATION.md` Probe 1 establishes that a `module` file cannot import the non-module `FormalSystem.Init`, so every ported file is converted:

| cslib form | Converted form | Why |
|---|---|---|
| leading `module` line | removed | Probe 1 |
| `public import X`, `import X` | `import X` | plain-import file |
| `import Cslib.Init` | `import FormalSystem.Init` | C24: every module transitively imports `Init` |
| `@[expose] public section` | removed (or a plain `section` if a matching `end` exists) | no exposure in plain files |
| bare `public` on a declaration | removed | 2 sites |
| `namespace Cslib.Logic.Bimodal.*`, `Cslib.Logic.Metalogic`, `Cslib.Logic.Modal`, `Cslib.Logic.PL`, `Cslib.Logic.Temporal` | the path-derived `FormalSystem.*` namespace (`MODULE_ORGANIZATION.md` §2) | namespace follows path below the root |
| `set_option warn.sorry false` and the sorry it guards | not admissible | C3 admits exactly one structural sorry, located by content |
| header | unchanged | byte-identical form (`Copyright (c) 2026 Benjamin Brast-McKie ... Authors: Benjamin Brast-McKie`); `check-copyright-headers.sh` and the Mathlib header linter both pass |

Gate-relevant hygiene of the candidate trees, MEASURED: zero task-number citations (C9) in every candidate directory; zero `file.lean:NNN` citations (C20) in `Foundations/Logic`, `Separation`, `ConservativeExtension`, `Embedding`, `FrameConditions`, `Algebraic`; 3 in `Temporal`, 68 in `Propositional`, 248 in `Modal`, every one pointing at a cslib path and so a guaranteed C20 failure unless re-anchored by name or stripped; zero `#eval`/`#check`/`#print` lines (C27); files over the 1,500-line `longFile` limit: 2 in `Separation`, 1 each in `Temporal` and `Propositional`, 13 in `Modal`, each needing an in-source baseline.

What a landed unit additionally owes this repository's gates: a sibling aggregator per new directory (C8); a row in `LAYERS` or `LANGUAGE_FILE_LAYERS` in `scripts/measure-refactor-partitions.py`, since `layer_of` raises on an unrowed file and `check-metalogic-cycles.sh` turns red; a mirrored test directory under `Tests/BimodalTest/`; a `docs/theorem-index.md` row and a C2/C14 axiom pin for any headline result (the three conservativity theorems qualify); `mk_all`-regenerated `FormalSystem.lean`; and no new upward import against the measured layer table (`ORGANISATION.md`). `MODULE_RELOCATION.md`'s pre-move checklist applies to the namespace rewrite.

### F6. The pin-distance gate (NOT MEASURED here)

Both repositories pin `leanprover/lean4:v4.33.0-rc1`. This repository's Mathlib is the tag `v4.33.0-rc1` (`79d0395a1825a6264ad5d269e35e60537518955e`); cslib's is commit `169c26b52a38b704fad2c009372d76844a059bdf` on `main`. Neither checkout used for this seed carried a `.lake/`, so the distance is unmeasured. The research round measures it first, in a checkout with Mathlib fetched:

```bash
git -C .lake/packages/mathlib log --oneline 79d0395a..169c26b5 | wc -l   # cslib ahead
git -C .lake/packages/mathlib log --oneline 169c26b5..79d0395a | wc -l   # this repo ahead
```

and records whether the candidate units' Mathlib imports (F7) are touched by any commit in that range. Task 741's pattern treats this as the first gate and names 76 commits as the figure that was decisive against the omega-automata port.

### F7. Mathlib surface of the wave-1 and wave-2 units (MEASURED)

| Unit | Mathlib modules imported directly |
|---|---|
| U1 | `Mathlib.Tactic.Attr.Core`, `Mathlib.Tactic.SetNotationForOrder` |
| U2 | `Mathlib.Order.Zorn`, `Mathlib.Data.Set.Insert`, `Mathlib.Tactic.SetLike`, `Mathlib.Tactic.Linarith`, `Mathlib.Tactic.Attr.Core` |
| U3 (Propositional core) | `Mathlib.Data.Fintype.Pi`, `Mathlib.Data.FunLike.Basic`, `Mathlib.Data.Set.Basic`, `Mathlib.Order.TypeTags` |
| U3 (ConservativeExtension) | `Mathlib.Data.Int.Basic`, `Mathlib.Algebra.Order.Group.Int`, `Mathlib.Data.Fintype.EquivFin`, `Mathlib.Tactic.Bound.Init` |
| U4 | `Mathlib.Data.Int.Interval`, `Mathlib.Data.Set.Finite.Basic`, `Mathlib.Algebra.Order.ZeroLEOne`, `Mathlib.Algebra.Group.Int.Defs`, `Mathlib.Tactic.ToAdditive` |

All of these are already in this repository's closure (`Mathlib.Order.Zorn` and `Mathlib.Algebra.Order.Group.Int` are among its most-imported modules), so the pin gate is about API drift inside them, not about new dependencies.

### F8. On-disk placement (PROPOSAL, with the constraint MEASURED)

Two placements are consistent with `ORGANISATION.md`'s rule that every file has a measured layer:

1. **Sublogics as object-language directories.** `FormalSystem/PropositionalLanguage/`, `FormalSystem/ModalLanguage/`, `FormalSystem/TemporalLanguage/`, each "one object language, syntax through semantics" exactly like `MinusLanguage/`, `PlusLanguage/` and `StarLanguage/`, each file taking a row in `LANGUAGE_FILE_LAYERS` by the syntax-0, semantics-1, metalogic-3 rule already applied to `OpenLanguage/`, `HybridLanguage/` and `QuantLanguage/`. The embeddings and the three conservativity theorems live beside the existing `Metalogic/Conservativity/` (layer 3). This is the placement that reuses an existing precedent without a new `LAYERS` row.
2. **Generic infrastructure at layer 0.** U1 and U2 are consumed by `Syntax/`-adjacent code (connective classes) and by `Metalogic/`. A new layer-0 directory (`FormalSystem/Logic/` or `FormalSystem/Foundations/`) needs one `LAYERS` row and an `ORGANISATION.md` table row; placing them under `Metalogic/Core/` instead keeps them at layer 3 and forbids `Syntax/` from instantiating the classes. The research round decides by measuring which modules would import them.

### F9. What the earlier verdict did and did not rule (VERIFIED-DOC)

Task 741's description records that "port nothing, treat cslib as a read-only reference" is the settled outcome of task 736, the omega-automata survey, and that its method (pin distance first, `proof_wanted`/`sorry` census, fork-versus-upstream divergence, the cost of a `require` edge) is to become a reusable pattern. This task applies that method; it does not relitigate 736's verdict, which concerned different content and a dependency edge.

## Decisions

- None binding. The unit table in F3 and the placement in F8 are the research round's hypotheses, to be confirmed or refuted by measurement.

## Recommendations

### Proposed phases for the research round

1. **Gates before any file moves.** Measure the Mathlib pin distance (F6) and the API drift it implies for F7's modules. Reproduce cslib's own `lake build` state for each candidate unit in isolation (cslib's tree is red under `--wfail` because of three bare sorries in `Propositional/`, so a green cslib build is not available as a baseline).
2. **Boneyard reconciliation for U4 and U5.** For U4, diff cslib's `Separation/` against `Boneyard/Kamp/KampWeakCanonical/Separation/` and against the live zeta route, and census every live declaration that would consume `all_separable`. For U5, run the git archaeology (`git log --all --follow`, commit-message search for "Parametric") and compare against `Algebraic/FlowFrame.lean`.
3. **Consumer census for U1, U2, U8.** List the lift lemmas and MCS developments that would become instances, by name, with the line count each would lose. Decide U8 on that number.
4. **Closure measurement for U3.** Compute the reachable module set from the three conservativity theorems (F4) and report it as the port surface, with the BX re-basing (26 schemata versus 7-plus-TR) costed separately.
5. **Placement ruling.** Decide between F8's two shapes on the measured import graph; write the `LAYERS`/`LANGUAGE_FILE_LAYERS` rows the ruling implies.
6. **Verdict table.** One row per unit: port now, port later with trigger, decline with reason. Declines are recorded in the implementation plan so a later audit reads them as decisions.
7. **Plan.** Phase the landed units so that each phase is one unit, converted by F5's recipe, green on `bash scripts/check-module-invariants.sh --no-build` and `lake build`, with its aggregator, tests, layer rows and theorem-index rows, before the next unit starts.

### Questions the research round must answer

- What is the measured pin distance, and does any commit in the range touch F7's modules?
- Does any live declaration consume syntactic separation over ℤ, or would U4 be a result with no consumer here?
- Where did `Theories/Bimodal/Metalogic/Algebraic/ParametricCompleteness.lean` go, and is its D-parametric theorem a consequence of the live `FlowFrame` completeness?
- Can `MaximalConsistent`, `MinusMCS` and `RestrictedMCS` be instances of one `DerivationSystem` seam without changing any pinned statement (C2, C14)?
- Which is cheaper for the temporal sublogic: re-basing cslib's 26-schema BX onto 7-plus-TR, or proving the two axiomatizations inter-derivable once and keeping both?
- Is the `TemporalConservativity` sorry (cslib task 450) dischargeable by stating the temporal side over `AddCommGroup D` here, where that is the only order the semantics ever uses?
- Which co-authored files (F1) sit inside any unit's closure, and how are they attributed?

## Risks and Mitigations

| Risk | Mitigation |
|---|---|
| Pin drift makes a unit's Mathlib API calls fail on this repository's tag | Gate 1 before any copy; port against this repository's tag and record every API rename as a line in the plan |
| A ported unit introduces a `sorry` and trips C3 | No `warn.sorry` file is ported; the `TemporalConservativity` theorem is discharged or omitted, never admitted |
| Namespace rewrite collides with the eight recorded namespace exceptions or with `check-metalogic-cycles.sh`'s allowlist | Run the namespace-audit simulation `MODULE_RELOCATION.md` prescribes before the first move; add layer rows in the same change |
| U7 contends with the Stage 1 and Stage 4 decidability tasks for `Metalogic/Decidability/` | Deferred by this seed; the trigger is 763 landing |
| Two BX axiomatizations end up live | The plan carries exactly one, or an inter-derivability theorem that makes the second a derived presentation |
| The stale `Expressiveness/Separation/README.md` misleads the U4 archaeology | Fix the README in Phase 2, or file it, before reading it as evidence |
| cslib's Bimodal tree is on the older frame and the 42-axiom system | Every ported proof that touches soundness is re-pointed at `soundness_validIn` and the 20-axiom `Axiom`; nothing from cslib's `Bimodal/Semantics` or `ProofSystem` is ported |
