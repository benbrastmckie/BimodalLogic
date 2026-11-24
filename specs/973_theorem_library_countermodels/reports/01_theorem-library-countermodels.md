# Research Report: Task #973

**Task**: 973 - Theorem library: countermodels
**Started**: 2026-11-24T11:29:00Z
**Completed**: 2026-11-24T11:55:00Z
**Effort**: Large (4-6 implementation phases; one generated-entry phase dominates)
**Dependencies**: `theorem_library_layout_and_registry` (landed: `BimodalLib/Registry.lean`,
`Fragment.lean`, `Index.lean`, `Subsumption.lean`, `Conjecture.lean` all in tree);
`theorem_library_tableau_pipeline` (landed: `data/theorem-library-countermodels.jsonl`,
2,981 rows)
**Sources/Inputs**:
- Codebase: `BimodalLib/`, `FormalSystem/Semantics/`, `FormalSystem/PlusLanguage/`,
  `FormalSystem/StarLanguage/`, `FormalSystem/Metalogic/Independence/` (31 files),
  `FormalSystem/Metalogic/Decidability/` (gate theorems, witness-family certificates),
  `BimodalTools/TheoremPipeline.lean`, `BimodalTools/TableauBridge.lean`
- Design records: `records/theorem-library.md`, `records/proof-mode.md` (M20),
  `records/milestones.md` (B4), `records/proof-mode-architecture.md`
- Reference docs: `docs/reference/bimodal-lib.md`
- Compiled probes (this report's evidence): 7 probe files under the session scratchpad, run
  through `lake-build-guard.sh ... env lean`
- lean-lsp: not used; evidence tier is **compiled probe**, which is strictly stronger than an
  LSP index lookup for every claim below
**Artifacts**:
- `specs/973_theorem_library_countermodels/reports/01_theorem-library-countermodels.md`
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **The entry type works, generically, and is compile-verified.** A single
  `CountermodelEntry L` parameterized by the existing `PointTruth L` class
  (`FormalSystem/Semantics/ValidityLayer.lean`) covers L and L⁺ with one structure, one
  registration command and one index walk. `ValidIn fc φ` and `PlusValidIn fc φ` are
  **definitionally equal** to `GenericValidIn fc φ` (verified by `rfl`), so every existing
  refutation in both languages is admissible without restatement.
- **All three grades have a landed first entry, each kernel-checked.** SEMANTIC:
  `Independence.not_validIn_dense_prior_UZ` (L, Dense) and `PlusLanguage.refute_stab_box`
  (L⁺, Base). CERTIFICATE: `WitnessFamily.not_consequence_ztime` applied to
  `botUntlFamily_certifies` (L, ZTime) — the only predicate in the tree that natively has the
  `Γ ⊭ φ` shape with a non-empty `Γ`. GATED TABLEAU: `not_valid_of_hasOpen_int` repackaged on
  explicit branch data, gates discharged by `decide`, axioms
  `[propext, Classical.choice, Quot.sound]` — identical to the rest of `BimodalLib`.
- **Both TRANSFER theorems are one-liners and are compile-verified.** Downward in frame class
  via `FrameClass.Sat.anti`; L into L⁺ via `plusTruthAt_ofFormula`. The frame-class poset is a
  **tree, not a chain**: `Base < Dense < RTime` and `Base < ZTime`, with ZTime incomparable to
  Dense and RTime. The record's "every weaker class it belongs to" must be read against that
  tree.
- **TRANSFER collapses the pipeline's 2,981 rows to 1,047 admissible entries** (measured:
  1,047 distinct statements, 967 carrying all of Base/Dense/RTime, 80 Base-only). Registering
  the raw row count would be threefold redundant. There are **zero** ZTime rows and **zero**
  certificate-grade rows in the pipeline output.
- **The pipeline's data file is insufficient for part (3) as it stands.** It carries only
  `true_atoms`/`false_atoms`; a kernel-checked gated-tableau entry needs the open **branch**
  and its `TimeOrdering`. Even the trivial `p → ⊥` has a 14-element branch over 4 times. At
  ~70 generated lines per entry, 1,047 entries is ~73,000 lines against a 1,500-line-per-file
  linter that CI enforces with `--wfail`.
- **Part (5) NEAR MISSES has no reciprocal row to point at.** `TheoremEntry` is `Formula`-only
  by type (`stmt : (Nat → Formula) → Formula`, `proof : DerivationTree`), so the three laws the
  five `⊡` refutations bound — `PlusAxiom.box_stab`, `PlusPasting.stab_allFuture_valid`, and
  the paper's unformalized *Determined* schema — are not and cannot be registry rows. This
  needs a plan decision, not an implementation guess.
- **Recommended approach**: generic `CountermodelEntry L` over `PointTruth` + a small
  `HasProfile` class; parts (1), (2), (4), (6) and the three grades' first entries in one
  bounded pass; part (3)'s bulk admission gated behind a pipeline change that exports branches,
  sized by a measured per-entry line cost rather than assumed.

## Context & Scope

Researched: how to realize M20 / B4 (`records/proof-mode.md` §M20) against the tree as it
stands on `main`. Specifically: what shape a countermodel entry can take given the existing
validity layer; which refutations already in the tree are registrable and in what form; what
each of the three grades actually has behind it; whether the two TRANSFER claims are theorems
or work; how lookup up to atom renaming can be built from existing machinery; and what part (3)
costs.

Constraints respected: no `sorry`, no new `axiom`, no `native_decide` in `BimodalLib`;
`BimodalLib` imports `FormalSystem` and never the converse (`B3` of
`check-module-invariants.sh`); `BimodalLib` must **not** import `BimodalTools` (ruled out
explicitly in `lakefile.toml`'s header); `lake build BimodalLib --wfail` and
`scripts/library-index.sh --check` run in CI.

Out of scope here: the EVALUATOR-CHECKED fourth grade (waits on the evaluator milestone and on
`records/semantic-proof-mode.md`, neither of which exists on `main`); the re-prove and compare
stages (M19 items 6-7).

## Findings

### Codebase Patterns

**The validity layer is already language-generic, and the generic notions are defeq to the
per-language ones.** `FormalSystem/Semantics/ValidityLayer.lean` defines
`class PointTruth (L : Type)` with a single `sat` field, and `GenericValidOnFrames` /
`GenericValidIn` / `GenericValid` over it, with `GenericValidIn.mono` and `GenericValid.of_not`.
Probe `P1.lean` establishes by `rfl`:

```lean
example (fc : FrameClass) (φ : PlusFormula) : PlusValidIn fc φ = GenericValidIn fc φ := rfl
example (fc : FrameClass) (φ : Formula)     : ValidIn fc φ     = GenericValidIn fc φ := rfl
example (φ : PlusFormula) : PlusValid φ = GenericValidIn FrameClass.Base φ := rfl
```

and `SemanticConsequenceIn fc [] φ = ValidIn fc φ` by `unfold; simp`. This is what makes one
entry type serve both languages without a translation at the boundary.

**There is no generic consequence relation with premises.** `ConsequenceOnFrames` /
`SemanticConsequenceIn` exist for `Formula` only; L⁺ has no premise-bearing consequence
predicate at all. One must be added. It is four lines over `PointTruth` and needs no `imp` on
the language (probe `P5.lean`, `P6.lean`):

```lean
def GenericConsequenceIn {L : Type} [PointTruth L]
    (fc : FrameClass) (Γ : List L) (φ : L) : Prop :=
  ∀ F : TaskFrame, fc.Sat F → ∀ (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration),
    (∀ γ ∈ Γ, PointTruth.sat M τ t γ) → PointTruth.sat M τ t φ
```

**The refutation corpus is not uniform in shape, and only part of it is registrable.** A
sweep of `Independence/` (31 files) plus `PlusNonValidities.lean` and `StarNonValidities.lean`
found non-validity expressed through 16 distinct predicates in five tiers. What matters for
filing:

| Tier | Shape | Count (approx.) | Registrable as an entry? |
|---|---|---|---|
| `¬ ValidIn <class> φ` | class-tag validity, L | ~16 in `ZTimeSharpness`, `DenseRTimeSharpness`, `SepSharpness` | **Yes, directly** |
| `¬ PlusValid φ` | `PlusValidIn .Base`, L⁺ | 5 in `PlusNonValidities` | **Yes, directly** (defeq to `GenericValidIn .Base`) |
| `¬ F.ValidOn φ` / `¬ ValidOnFrames P φ` | one explicit frame, or a bare frame predicate with no class tag | ~16 | Only where a class-tag corollary exists beside it (most have one) |
| `¬ Derivable fc [] φ` / `¬ PlusDerivable` / `¬ NaiveDerivable` | derivability, not semantics | ~16 | **No** — these are independence results about a *calculus*, not countermodel entries |
| `¬ ∃ Γ, …` definability; `¬ Separated F`; `F ∉ Sat fc` | definability / frame-property | ~25 | **No** |
| `StarFormula` refutations | `¬ NF.StarValidOn`, `¬ StarValid` | 4 in `StarNonValidities`, plus ~6 in `Independence/` | **No** — see below |

The dispatch says to register `StarNonValidities` "where the inference is statable in L or L⁺".
Measured: it is not. `StarValidOn` carries an **extra** binder — the stored-time vector
`(v : ℕ → F.Duration)` — so L⋆ validity is not an instance of the L/L⁺ point shape; there is no
`profileS`; and `sentDet`, `timeStore`, `timeRecall` are L⋆-only operators. `refute_erasure`'s
*content* (`Gp → p` fails) is L-statable, but the declaration as written is over `StarFormula`.
The honest disposition is: register no `StarNonValidities` row, and record why.

`co_not_derives_prior_U_gap` (`Independence/CoNotPriorU.lean:313`) is the only `Γ`-indexed
refutation in the directory, and it is derivability-level, not semantic. **Every landed
semantic entry will have `Γ = []`.** The `Γ` slot still earns its place, because the
certificate grade's own theorem takes one.

**The gate theorem family is four theorems and eight decidable gates.** The gates
(`timeOrderTotal`, `boxAnchoredCheck`, `regionLabelCheck`, `temporalWitnessCheck`,
`branchOrderValid`, `findUnexpanded … = none`, `findClosure … = none`, the root-denial pair)
all live under `FormalSystem/`, so `BimodalLib` can bundle them without touching
`BimodalTools` (whose `BranchGates`/`evalBranchGates` it must not import). The headline
theorems:

| Theorem | Concludes | File |
|---|---|---|
| `not_valid_of_hasOpen_int` | `¬ Valid χ` | `Verified/Bridge/IntTruth.lean:1045` |
| `not_validZTime_of_hasOpen_int` | `¬ ValidZTime χ` | `Verified/Bridge/IntTruth.lean:1073` |
| `not_validDense_of_hasOpen` | `¬ ValidDense χ` | `Verified/Bridge/DenseTruth.lean:658` |
| `not_validRTime_of_hasOpen` | `¬ ValidRTime χ` | `Verified/Bridge/DenseTruth.lean:680` |

`Branch := List SignedFormula` (`SignedFormula.lean:240`) — a plain list, so a branch is
printable data and the gates are `decide`-able on it. Crucially, **none of the four theorems
requires that the branch came from `buildTableau`**: soundness rests on the gates alone. That
is what makes a cheap entry possible (see Recommendations).

**The certificate grade is the only one with the record's exact `Γ ⊭ φ` shape.**
`WitnessFamily.not_consequence_ztime` (`WitnessFamily/Agreement.lean:219`) concludes
`¬ SemanticConsequenceIn FrameClass.ZTime Γ σ` from `W.Certifies t`'s four projections, and
`Certifies` is decidable (`botUntlFamily_certifies : botUntlFamily.Certifies 0 := by decide`,
`PlusSlicedCertificate/EmbedComplete.lean`). `WitnessFamily.Refutes` /
`PlusWitnessFamily.PlusRefutes` are the model-exhibiting existentials behind it; L⁺
certificates land `PlusRefutes` through `PlusSlicedCertificate.plusRefutes_of_certifies`
(`Sound.lean:330`).

**The frame-class order is a tree.** `FormalSystem/ProofSystem/Axioms.lean:512`:
`Base ≤ everything`; `Dense ≤ {Dense, RTime}`; `RTime ≤ RTime`; `ZTime ≤ ZTime`. ZTime is
incomparable with Dense and RTime. `Independence/ZTimeSharpness.lean`'s own docstring already
reasons this way ("`.Dense` is not below `.ZTime` in the frame-class order, so this is not
implied by `prior_UZ_minFrameClass_sharp`"). Consequence for filing: "the strongest frame class
at which the model lives" is not a total order, so an inference can need **two** maximal
entries (one at RTime, one at ZTime) rather than one.

**Pipeline output, measured.** `data/theorem-library-countermodels.jsonl`: 2,981 rows, all
grade `gated_tableau`; frame classes Base 1,047 / Dense 967 / RTime 967; **1,047 distinct
statements**; 967 statements carry `{Base, Dense, RTime}` and 80 carry `{Base}` only. No ZTime
row and no certificate row. `BimodalTools/TheoremPipeline.lean:62-65` explains the ZTime
absence: `regionLabel` and `temporalWitness` come back `false` on every formula there, so the
gated grade is *structurally* unavailable at ZTime, not merely rare.

Each row carries `gates` (8 flags plus the `gated` conjunction), `frame_class`, `inference`
(a rendered string), `true_atoms`, `false_atoms` — and **not** the branch or the time ordering.

**Lookup up to renaming is already available, strictly.** `BimodalLib/Subsumption.lean`'s own
docstring notes that mutual instance-hood is renaming; `isSubstInstance x y && isSubstInstance
y x` is therefore the whole of part (6)'s matching, with no new recursion. Probe `P7.lean`
(`#eval`, six cases): `p₀ → p₁` vs `p₁ → q` → `true`; `p₀ → p₀` vs `p₀ → p₁` → `false`;
`□p₀ → p₀` vs `□p₁ → p₁` → `true`; `p₀ → ⊥` vs `□p₀ → ⊥` → `false` while plain
`isSubstInstance` on the same pair → `true`. Caveat: `matchSubst?` is `Formula`-only; L⁺ lookup
needs a `PlusFormula` companion.

**Part (5)'s reciprocity target does not exist as a row.** `TheoremEntry` is `Formula`-only by
construction, and all 196 registered rows are over `Formula`. The laws the five `⊡`
refutations bound are:

| Refutation | Bounds | Status of the bounded object |
|---|---|---|
| `refute_stab_box` (`⊡p → □⊡p`) | MS, `□φ → ⊡φ` | `PlusAxiom.box_stab`, an **axiom constructor** (`PlusLanguage/Axioms.lean:300`) |
| `refute_allFuture_stab` (`G⊡p → ⊡Gp`) | GS, `⊡Gφ → G⊡φ` for pure-future `φ` | `PlusPasting.stab_allFuture_valid`, a **semantic validity** theorem |
| `refute_stab_allFuture_past` (`⊡GPp → G⊡Pp`) | GS with its side condition dropped | same declaration |
| `refute_determined` (`Fp → ⊡Fp`) | the paper's *Determined* schema | **not formalized** (module docstring says so explicitly) |
| `refute_somePast_stab` (`P⊡p → ⊡Pp`) | Kamp's AK12 / Reynolds' HN analogue | **no counterpart in the tree** |

None is a `TheoremEntry`. `theorem_library_stability_entries` (M21) is the record that would
add L⁺ theorem entries, and it is **not** a dependency of this task — M21 in fact lists M20 as
its own sequencing dependency, so the pairing cannot be deferred to it either.

### External Resources

No external search was needed: every question resolved against the tree or a compiled probe.
Named declarations relied on, with their sites:

- `FormalSystem.Semantics.PointTruth`, `GenericValidIn`, `GenericValidIn.mono`,
  `GenericValid.of_not` — `FormalSystem/Semantics/ValidityLayer.lean:164,187,205,256`
- `FormalSystem.ProofSystem.FrameClass`, its `LE` instance, `FrameClass.base_le` —
  `FormalSystem/ProofSystem/Axioms.lean:505,512,639`
- `FormalSystem.Semantics.FrameClass.Sat.anti` — `FormalSystem/Semantics/FrameClassValidity.lean`
- `FormalSystem.PlusLanguage.plusValidIn_ofFormula_iff`, `plusTruthAt_ofFormula`,
  `ofFormula` — `FormalSystem/PlusLanguage/PlusValidity.lean:218`,
  `FormalSystem/PlusLanguage/Formula.lean:389`
- `BimodalLib.profileF`, `profileP`, `Profile.join`, `Profile.fragment` —
  `BimodalLib/Fragment.lean:121,130,85,99`
- `BimodalLib.isSubstInstance`, `matchSubst?`, `registryRows` — `BimodalLib/Subsumption.lean`,
  `BimodalLib/Registry/Complete.lean`

### Recommendations

Every recommendation below that names a landable artifact was run against the gate that decides
its acceptance — Lean elaboration and the kernel, via `lake env lean` under
`lake-build-guard.sh` — before being written. Probe files are under
`/tmp/claude-1000/-home-benjamin-Projects-BimodalLogic/9241cced-5dde-48e7-a4d3-cebffbdde8be/scratchpad/probe/`.

- **R1. Define the entry type once, generically over `PointTruth`, with a small `HasProfile`
  class for the fragment computation.** The structure below elaborates, and its `profile_eq`
  field closes by `rfl` for both languages.
  [VERIFIED: PASS -- probe `P5.lean` elaborated via `lake env lean`, exit 0: the
  `GenericConsequenceIn` definition, `genericConsequenceIn_nil`, `HasProfile` with both
  instances, `inferenceProfile`, `Grade`, the `CountermodelEntry L` structure, and
  `CountermodelEntry.fragment`, all accepted]

  ```lean
  class HasProfile (L : Type) where profile : L → Profile
  instance : HasProfile Formula     := ⟨profileF⟩
  instance : HasProfile PlusFormula := ⟨profileP⟩

  def inferenceProfile {L} [HasProfile L] (Γ : List L) (φ : L) : Profile :=
    Γ.foldr (fun γ acc => Profile.join (HasProfile.profile γ) acc) (HasProfile.profile φ)

  inductive Grade | semantic | certificate | gatedTableau deriving DecidableEq, Repr

  structure CountermodelEntry (L : Type) [PointTruth L] [HasProfile L] where
    premises   : List L
    conclusion : L
    frameClass : FrameClass
    grade      : Grade
    refutation : ¬ GenericConsequenceIn frameClass premises conclusion
    profile    : Profile
    profile_eq : inferenceProfile premises conclusion = profile
    nearMiss   : Option Name := none
  ```

  As with `TheoremEntry`, `refutation` is what the kernel checks and `profile_eq` is what makes
  the fragment computed rather than asserted — the two invariants `docs/reference/bimodal-lib.md`
  already states for the theorem half.

- **R2. File the SEMANTIC grade's first two entries as `Independence.not_validIn_dense_prior_UZ`
  (L, Dense) and `PlusLanguage.refute_stab_box` (L⁺, Base), each bridged through
  `genericConsequenceIn_nil`.**
  [VERIFIED: PASS -- probe `P5.lean`, `def cmPriorUZDense : CountermodelEntry Formula` and
  `def cmStabBox : CountermodelEntry PlusFormula` both elaborated with `profile_eq := rfl` and
  `refutation := fun h => <existing theorem> _ ((genericConsequenceIn_nil _ _).mp h)`]

- **R3. File the CERTIFICATE grade's first entry as `⊥ U ⊥` at ZTime, from the accepted
  witness-family certificate.** `WitnessFamily.not_consequence_ztime` applied to
  `botUntlFamily` and the four projections of `botUntlFamily_certifies` (itself `by decide`).
  [VERIFIED: PASS -- probe `P5.lean`, `def cmBotUntl : CountermodelEntry Formula` elaborated;
  this is the one entry whose refutation reaches the `Γ ⊭ φ` shape through a predicate that
  takes a premise list natively]

- **R4. Realize the GATED TABLEAU grade by repackaging the gate theorem on explicit branch
  data, and do NOT rebuild the tableau in the kernel.** Bundle the eight gates as one
  decidable `Bool` and prove the bridge once; each entry then discharges its gates by `decide`
  on a finite list.
  [VERIFIED: PASS -- probe `P4.lean`/`P6.lean`: `gatesOK`, `not_valid_of_gatesOK` /
  `not_genericConsequence_of_gatesOK`, a concrete 14-element branch for `p → ⊥` with
  `cm2_gates := by decide` (under `set_option maxRecDepth 10000`), and
  `#print axioms cm2_refutation` reporting exactly
  `[propext, Classical.choice, Quot.sound]` — the same triple every other `BimodalLib` theorem
  measures. Whole-file elaboration including imports: ~11 s]

  ```lean
  def gatesOK (φ : Formula) (fc : FrameClass) (b : Branch) (ord : TimeOrdering) : Bool :=
    timeOrderTotal b ord && boxAnchoredCheck b && regionLabelCheck b ord
      && temporalWitnessCheck b ord && branchOrderValid b ord
      && (findUnexpanded b (timeOrd := ord)).isNone && (findClosure b fc).isNone
      && b.hasNegAt φ Label.initial && b.knownWorlds.contains Label.initial.world
  ```

  The alternative shape — a `gatedRefuted φ fc : Bool` that matches on
  `buildTableau φ (soundFuel φ) fc` and is discharged by `decide` — was **not** recommended,
  because it asks the kernel to evaluate the whole tableau construction per entry. It was not
  measured and should not be assumed feasible; the explicit-branch form sidesteps the question
  entirely and is the one that was verified.

- **R5. State both TRANSFER theorems over the generic consequence relation; each is a
  one-liner.**
  [VERIFIED: PASS -- probe `P6.lean`: `not_genericConsequenceIn_of_le` (downward in frame
  class, via `FrameClass.Sat.anti`) and `not_genericConsequenceIn_ofFormula` (L into L⁺, via
  `plusTruthAt_ofFormula` and `List.mem_map`) both elaborated, and
  `#print axioms cm2_refutation_plus` — the gated-tableau entry carried through the L⁺ transfer
  — reports `[propext, Classical.choice, Quot.sound]`]

  ```lean
  theorem not_genericConsequenceIn_of_le {L} [PointTruth L] {fc₁ fc₂ : FrameClass}
      (h : fc₁ ≤ fc₂) {Γ : List L} {φ : L}
      (hr : ¬ GenericConsequenceIn fc₂ Γ φ) : ¬ GenericConsequenceIn fc₁ Γ φ :=
    fun hc => hr (fun F hF => hc F (FrameClass.Sat.anti h hF))
  ```

  Note that `plusValidIn_ofFormula_iff`, which the dispatch names for the L-into-L⁺ step, is the
  `Γ = []` case; the premise-bearing form needs `plusTruthAt_ofFormula` instead, which is what
  the probe used.

- **R6. Build part (6)'s lookup from `isSubstInstance` in both directions, not from a new
  matcher.** `sameUpToRenaming x y := isSubstInstance x y && isSubstInstance y x`.
  [VERIFIED: PASS -- probe `P7.lean`, six `#eval` cases, all six matching the intended
  semantics: genuine renamings `true`, variable-collapse and strict-instance pairs `false`]
  Add a `PlusFormula` companion to `matchSubstAux` if L⁺ leaves must be lookup-able; the
  existing matcher is `Formula`-only.

- **R7. Admit the pipeline's gated-tableau entries at their MAXIMAL frame classes only, and
  derive the weaker ones by R5 rather than registering them.** Measured: 1,047 distinct
  statements, of which 967 would be one RTime entry each and 80 one Base entry each, against
  2,981 raw rows. [VERIFIED: PASS -- counted directly from
  `data/theorem-library-countermodels.jsonl` with a `json`/`collections` tabulation:
  `rows 2981`, `distinct statements 1047`, class-set pattern counts
  `{Base,Dense,RTime}: 967`, `{Base,}: 80`, `grades {gated_tableau: 2981}`]

- **R8. Treat part (3) as gated on a pipeline change, and size it before committing to it.**
  The data file carries no branch, so no kernel-checked gated entry can be generated from it
  today; `BimodalTools/TheoremPipeline.lean`'s refutation record must also emit the open branch
  and its `TimeOrdering`. [VERIFIED: FAIL -- the acceptance gate here is
  `lake build BimodalLib --wfail` plus the package's `linter.style.longFile = 1500`, and the
  artifact as currently specifiable does not pass it: measured, the open branch of the
  *simplest* refuted formula in the dataset (`p → ⊥`, `bmlogic-00002`) is 14 signed formulas
  across 4 times with a 3-constraint ordering — about 70 generated lines per entry once wrapped
  under the 100-character limit, so 1,047 entries is on the order of 73,000 lines and ~50
  files. Revised to: land parts (1), (2), (4), (5), (6) and ONE generated gated-tableau entry
  as the grade's existence witness in this task; put the bulk admission behind an explicit
  phase that first extends the pipeline's refutation record with the branch, then measures
  lines-per-entry and elaboration time on a 10-entry sample, and files per
  (fragment, frame class) with a pinned `set_option linter.style.longFile` baseline per
  generated file. The memory record from the theorem half is the precedent: six admitted
  entries came to 2,053 lines against the same 1,500-line limit.]

- **R9. Give `nearMiss` a declaration name, not a row name, and record the asymmetry.**
  [No compiled gate applicable -- this is a design decision about what the field denotes, with
  no existing predicate that decides acceptance.] Of the five `⊡` refutations the record calls
  "the model" for near misses, none bounds a registry row: two bound `PlusAxiom.box_stab` and
  `PlusPasting.stab_allFuture_valid` (an axiom constructor and a semantic validity, neither
  registrable by `TheoremEntry`'s type), one bounds an unformalized schema, and one has no
  counterpart in the tree. A reciprocal row-to-row check is therefore not constructible in this
  task. Two candidate dispositions, for the plan to choose between (see Decisions below).

- **R10. Extend `BimodalLib/Index.lean` with a Countermodels section and a per-grade census,
  and `scripts/library-index.sh` needs no change.** [No compiled gate applicable -- no existing
  predicate decides the index's content; `--check` only compares the committed file to a fresh
  render.] Note one real cost of R1's generic type: `Index.lean`'s `rowStatement?` uses
  `unsafe evalExpr Formula`, so the index walk needs a per-language branch over
  `CountermodelEntry Formula` and `CountermodelEntry PlusFormula`.

## Decisions

- **The entry type is generic over `PointTruth`, not duplicated per language.** Taken because
  `ValidIn` and `PlusValidIn` are defeq to `GenericValidIn` (measured), so genericity costs
  nothing at the statement side and saves a second structure, a second command and a second
  index section. The price is paid in meta-code: the index and lookup walks need a branch per
  language because `evalExpr` is monomorphic. The alternative — two concrete row types — was
  considered and is a legitimate fallback if the meta-code branching proves worse than the
  duplication; it does not change any statement in the library.
- **The refutation field is `¬ GenericConsequenceIn`, not a model-exhibiting existential.**
  Taken because every landed refutation in the tree has the `¬ Valid…` shape, and converting
  one to an explicit model requires classical choice, which discards exactly the explicit model
  the conversion was for. The record's "and a model" is then honoured by the *proof*, which in
  every case names its model (`natModel` over `NF`, `botFrame`, `ztimeSharpOrder`, the open
  branch), not by a data field. A `RefutesIn`-style existential field was considered: it does
  pack the model constructively, and `WitnessFamily.Refutes` / `PlusRefutes` are exactly that
  shape at ZTime, but adopting it as *the* field would require restating all ~21 hand-built
  refutations in model-exhibiting form. Recommended compromise for the plan: keep the field as
  above and add an optional `model : Option String` naming the model's declaration, so the
  record's third component is recorded without new proof obligations.
- **No `StarNonValidities` row is registered.** The dispatch's own side condition ("where the
  inference is statable in L or L⁺") is not met: `StarValidOn` carries an extra binder, there
  is no `profileS`, and the operators are L⋆-only. Recorded rather than silently skipped.
- **Derivability-level and definability-level independence results are not countermodel
  entries.** `¬ Derivable`, `¬ PlusDerivable`, `¬ NaiveDerivable`, `¬ OfutPlusDefinable` and
  the `∉ Sat` results are about calculi and frame classes, not about an inference failing in a
  model. The dispatch's "independence results under `FormalSystem/Metalogic/Independence/`"
  is read as the ~16 class-tag `¬ ValidIn` declarations in `ZTimeSharpness`,
  `DenseRTimeSharpness` and `SepSharpness`, plus the frame-level refutations that have a
  class-tag corollary beside them.
- **Maximal-class-only admission.** Registering Base/Dense/RTime rows for the same statement
  would make the TRANSFER theorem of part (4) decorative. Entries are filed at maximal classes
  and the weaker readings are *derived*.

## Risks & Mitigations

- **Part (3) line-count blowout against `--wfail` + the 1,500-line linter.** Measured at ~70
  generated lines per entry on the smallest case; 1,047 entries is ~73,000 lines. Mitigation:
  R8's staged approach — one witness entry in this task, bulk admission as its own phase with a
  10-entry measurement first, per-file `longFile` baselines pinned to actual length (not a round
  ceiling, per the theorem half's recorded lesson), and line wrapping on token boundaries built
  into the emitter from the outset.
- **`decide` on the gate bundle could regress on larger branches.** Verified cheap for a
  14-element branch with `maxRecDepth 10000`; untested above that. Mitigation: measure on the
  largest branch in the sample before generating, and treat `maxRecDepth` and elaboration time
  as sized quantities in the plan, not defaults.
- **Part (5) cannot be completed as the record words it.** The reciprocal row does not exist.
  Mitigation: implement `nearMiss` pointing at a declaration, record the one-directional
  asymmetry in `docs/reference/bimodal-lib.md`, and — if the plan wants reciprocity — add a
  separate `NearMissPair` table in `BimodalLib` keyed by two declaration names, with a check
  that both sides resolve. Escalating this to the user is **not** warranted: both dispositions
  are within the record's intent and the plan can choose. It is flagged here so the choice is
  made deliberately rather than discovered mid-implementation.
- **`BimodalLib` must not reach for `BimodalTools`' gate bundle.** `lakefile.toml` forbids the
  edge explicitly. Mitigation: `BimodalLib` defines its own `gatesOK` over the `FormalSystem`
  primitives, as the probe does. There will then be two gate bundles in the tree
  (`BimodalTools.TableauBridge.BranchGates` and `BimodalLib`'s); they must agree, and a test
  pinning their agreement is cheap insurance.
- **ZTime/Dense-RTime incomparability invites a silent filing error.** A model at ZTime does
  *not* refute at Dense or RTime. Mitigation: state the transfer theorem with its `fc₁ ≤ fc₂`
  hypothesis (as R5 does) rather than a "weaker class" convention, so the order is checked by
  the kernel and not by the author.
- **No certificate-grade entry comes from the pipeline.** The grade's only landed witness is
  hand-built (`botUntl`/`botSnce`). Mitigation: that is sufficient for "at least one entry
  each"; record that the certificate grade's population route is the ZTime witness-family
  checkers and that the tableau pipeline structurally cannot feed it.
- **A completeness check for the countermodel half would over-reach.** An analogue of
  `assert_registry_complete` that demanded a row for every `¬ Valid…`-shaped theorem in
  `FormalSystem` would indict ~100 declarations across five incompatible tiers. Mitigation:
  scope any such check to named modules (as `assert_no_subsumed_entries P` scopes its candidate
  side), or omit it and rely on the dispatch's explicit registration list.

## Tactic Survey Results

| Goal | Tactic | Result | Premises/Config |
|---|---|---|---|
| `PlusValidIn fc φ = GenericValidIn fc φ` | `rfl` | success | none (definitional) |
| `ValidIn fc φ = GenericValidIn fc φ` | `rfl` | success | none (definitional) |
| `SemanticConsequenceIn fc [] φ = ValidIn fc φ` | `unfold … ; simp` | success | unfold `SemanticConsequenceIn`, `ConsequenceOnFrames`, `ValidIn`, `ValidOnFrames`, `TaskFrame.ValidOn` |
| `GenericConsequenceIn fc [] φ ↔ GenericValidIn fc φ` | `unfold`; explicit term + `by simp` on the empty-premise side | success | `simp` discharges `∀ γ ∈ [], _` |
| `gatesOK cm2Formula .Base cm2Branch cm2Ord = true` | `decide` | success | `set_option maxRecDepth 10000`; 14-element branch |
| same goal | `native_decide` | not attempted | forbidden in `BimodalLib` by the dispatch and by `records/proof-mode.md` |
| gate-bundle destructuring | `simp only [Bool.and_eq_true, Option.isNone_iff_eq_none]` then `obtain` (8-deep left-nested pattern) | success after two shape corrections | `List.contains_iff_mem` for the `knownWorlds` conjunct; `List.contains_iff` is deprecated and warns, which `--wfail` would fail |
| `profile_eq` on every drafted entry | `rfl` | success | `inferenceProfile` reduces |
| `¬ GenericConsequenceIn fc₁ Γ φ` from the `fc₂` version | explicit term via `FrameClass.Sat.anti` | success | no tactic needed |
| L-into-L⁺ premise transfer | `intro`/`refine` + `List.mem_map.mp` + `plusTruthAt_ofFormula` | success | neither `simp` nor `aesop` attempted; the explicit term was shorter |

## Context Extension Recommendations

- **Topic**: the frame-class order is a tree, not a chain.
  **Gap**: nothing under `.claude/context/project/lean4/` records that `ZTime` is incomparable
  with `Dense` and `RTime`, although it governs every "transfers to the weaker class" argument
  in this repository and is the kind of claim an agent will assume rather than check.
  **Recommendation**: add a short note to `context/project/lean4/domain/` giving the four-class
  poset, the `LE` instance's site, and the standing consequence (a refutation may need two
  maximal entries).

- **Topic**: `PointTruth`-generic statements as the way to serve L, L⁻, L⁺ with one declaration.
  **Gap**: the defeq between `ValidIn`/`PlusValidIn` and `GenericValidIn` is load-bearing and
  undocumented outside `ValidityLayer.lean`'s own header; an agent writing a cross-language
  library type will reach for a translation instead.
  **Recommendation**: a pattern note recording the class, the defeq (with the `rfl` probe), and
  the one real cost — `evalExpr` is monomorphic, so meta-code over a generic row type still
  needs a per-language branch.

- **Topic**: kernel-checked entries from a decision procedure, without re-running it in the
  kernel.
  **Gap**: `context/project/lean4/` has no note on the "carry the certificate as data, discharge
  the checker by `decide`" shape, which is what made R4 cheap and is the same shape
  `botUntlFamily_certifies` uses.
  **Recommendation**: a pattern note contrasting it with the `decide`-the-whole-procedure shape
  and with `native_decide`, which is barred here.

## Appendix

### Compiled probes (evidence of record)

All run as `bash .claude/scripts/lake-build-guard.sh build --timeout N -- env lean <file>` from
the repository root; directory
`/tmp/claude-1000/-home-benjamin-Projects-BimodalLogic/9241cced-5dde-48e7-a4d3-cebffbdde8be/scratchpad/probe/`.

| Probe | What it establishes | Exit |
|---|---|---|
| `P1.lean` | `PlusValidIn`/`ValidIn` defeq to `GenericValidIn`; `PlusValid = GenericValidIn .Base`; `SemanticConsequenceIn fc [] φ = ValidIn fc φ` | 0 |
| `P2.lean` | the gate theorem repackaged on explicit branch data (`not_valid_of_gatesOK`) | 0 (after two destructuring fixes) |
| `P3.lean` | `#eval` of `buildTableau` on `p → ⊥`: the open branch is 14 signed formulas over 4 times, ordering `{constraints := [(1,3),(2,0),(0,1)]}` | 0 |
| `P4.lean` | a concrete gated-tableau entry: `gatesOK … = true := by decide`, `¬ Valid cm2Formula`, `#print axioms` = `[propext, Classical.choice, Quot.sound]` | 0 |
| `P5.lean` | `GenericConsequenceIn`, `genericConsequenceIn_nil`, `HasProfile`, `inferenceProfile`, `Grade`, `CountermodelEntry L`, and three entries — SEMANTIC in L, SEMANTIC in L⁺, CERTIFICATE at ZTime | 0 |
| `P6.lean` | both TRANSFER theorems; the gated-tableau entry restated over `GenericConsequenceIn`; its L⁺ reading, with axioms unchanged | 0 (after fixing `ofFormula`'s namespace) |
| `P7.lean` | `sameUpToRenaming` via mutual `isSubstInstance`, six `#eval` cases | 0 |

### Dataset tabulation

```
rows 2981
grades Counter({'gated_tableau': 2981})
frame classes Counter({'Base': 1047, 'Dense': 967, 'RTime': 967})
distinct statements 1047
class-set patterns Counter({('Base','Dense','RTime'): 967, ('Base',): 80})
```

### Searches and sweeps performed

- Repository-scoped `grep` for every non-validity predicate shape (`¬ Valid`, `¬ ValidIn`,
  `¬ ValidOn`, `¬ PlusValid`, `¬ StarValid`, `¬ Derivable`, `Refutes`, `not_consequence`),
  restricted to `FormalSystem/`, `BimodalLib/`, `BimodalTools/`, `Tests/` — never across
  `.lake/`, where an unrestricted sweep over Mathlib exceeded the command timeout once and was
  abandoned.
- A delegated exhaustive sweep of `FormalSystem/Metalogic/Independence/` (31 files) plus the two
  language non-validity modules, returning the five-tier predicate taxonomy summarized above.
- Record and doc reads: `records/theorem-library.md` (full), `records/proof-mode.md` §M19-M21,
  `records/milestones.md` B1-B4, `docs/reference/bimodal-lib.md` (full).

### Documentation changes this task will owe

Per the dispatch's closing instruction: `docs/reference/bimodal-lib.md` gains the countermodel
half (the entry type, the three grades, the two transfer theorems, the lookup, and the
per-grade population routes), its "What checks the library" table gains the new rows, and the
Countermodels section of `records/theorem-library.md` is cut to what remains unimplemented —
which, on the staging recommended in R8, is the bulk tableau-fed admission and the
EVALUATOR-CHECKED fourth grade.
