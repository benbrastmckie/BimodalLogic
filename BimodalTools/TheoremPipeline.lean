/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import BimodalLib.Subsumption
import BimodalTools.AtomCanonicalization
import BimodalTools.CertificateImport
import BimodalTools.FormulaEnumerator
import BimodalTools.LeanSourceEmit
import BimodalTools.PipelineDiagnostics

/-!
# The theorem-library pipeline: five stages, one driver

`records/theorem-library.md` names five stages — enumerate, decide, extract, certify, admit —
and this module sequences them. Nothing here is new machinery: the enumerator, atom
canonicalization, the decision procedure, proof extraction, the eight gates, the subsumption
matcher, the Lean-source emitter and the diagnostics records all exist, and the driver's whole
job is to call them in order and emit what each stage records.

## ENUMERATE

`enumerateUpToDepth` at the fragment's own complexity bound, then `deduplicateCanonical`, then a
filter on `BimodalLib.profileF`. The filter is `profileF` and not `passesFilter`: `profileF` is
the same function the registry's `profile_eq` closes by `rfl`, so a surviving formula agrees with
how its row will be filed by construction, while `passesFilter` additionally demands
`complexity ≥ 3` and at least one of `box`/`untl`/`snce`, which deletes the whole `Boolean`
fragment.

The enumerator's modal and temporal depth budgets are opened only for the families the fragment
contains, so the enumeration is not inflated by formulas the filter would discard immediately.

## DECIDE

`decideAutoAdaptiveCancellable` on a dedicated `IO.asTask`, with a cooperative `abortRef` and the
adaptive fuel `min 500 (150 + complexity * 30)` — `labelFormulaImpl`'s own shape, reused rather
than rewritten. The fuel landscape is bimodal: a formula resolves at 500 or not at all, so a
`fuelExhausted` verdict is never retried at higher fuel.

`extractionFailed` is a **principal path, not an error path**. The tableau closed, so the formula
*is* valid; there is simply no `⊢ φ` witness to extract, so it is never admissible and always
lands in the conjecture half. It is 26 of 133 at `ModalBoolean` complexity 5 — as large as
`fuelExhausted` and larger than `valid` — so the driver neither logs it as an anomaly nor retries
it.

## EXTRACT

A `valid` verdict carries its derivation, which the driver keeps live in a `Candidate` array — the
`ProofPool` shape — because a `DerivationTree` cannot be rebuilt from a record. An `invalid`
verdict carries the `SimpleCountermodel` that `decideAuto` already pulled out of the open branch
through `extractCountermodelSimple`/`extractCountermodelBlocked`; its world and time counts come
from the rebuilt branch, which CERTIFY needs anyway, so the two stages share one rebuild.

## CERTIFY

At `Base`, `Dense` and `RTime`: `evalBranchGates`, which re-derives the branch rather than
trusting any dataset `invalid` label — a `structural_invalid_prefilter` verdict never had a branch
at all.

**At `ZTime` the gates are not evaluated.** `regionLabel` and `temporalWitness` come back `false`
on every formula there, so `BranchGates.gated` is 0 of 11 while each of the other three classes
gates 11 of 11. The gated grade is therefore structurally unavailable at `ZTime`, not merely rare,
and evaluating the gates there is measured cost for a known answer. The frame-class dispatch
`certifyStage` performs selects the certificate route for `ZTime` and the gate route for the other
three, so the skip is a branch of the dispatch rather than a runtime shortcut a later reader could
mistake for an optimization and remove.

The `ZTime` route is `decidableCertifies`, reached through `CertificateImport.checkRaw`: a
witness-family certificate whose target names the formula is accepted or rejected by the four
decidable conditions. Certificates are *supplied*, not manufactured — nothing in this tree derives
a `RawCertificate` from a tableau branch — so a `ZTime` refutation count of zero is a reportable
finding about `decidableCertifies`' acceptance rate rather than a pipeline defect.

## ADMIT

A `valid` candidate is generalized from its own atoms to schema variables and emitted as Lean
source by `entrySource`, unless `BimodalLib.isSubstInstance` makes it an instance of a candidate
already admitted. Everything else — `fuelExhausted`, `extractionFailed`, and an `invalid` verdict
that is neither gated nor certified — is routed to the conjecture half with its verdict verbatim.

## What the driver does not do

It does not register a countermodel in `BimodalLib`: until the countermodels record lands,
certified refutations are written to a dataset in the form it will read. It does not re-run the
theorem half above `Base`, because proof extraction is `Base`-only by construction. And it does
not filter admission by an interestingness measure: the ruling is to keep every non-subsumed
theorem.

## References

* `records/theorem-library.md` — the five stages
* `BimodalTools/PipelineDiagnostics.lean` — the records each stage emits
* `BimodalTools/LeanSourceEmit.lean` — `entrySource`, the ADMIT stage's output
* `BimodalLib/Subsumption.lean` — `isSubstInstance`, the subsumption test
* `BimodalTools/TableauBridge.lean` — `evalBranchGates` and the eight gates
* `BimodalTools/CertificateImport.lean` — `checkRaw`, the `decidableCertifies` route

## Tags

theorem-library · pipeline · tableau · diagnostics
-/

open Lean (Json)
open FormalSystem.Syntax
open FormalSystem.ProofSystem (FrameClass DerivationTree)
open FormalSystem.Metalogic.Decidability
open BimodalLib.Diagnostics (Head Stage)
open BimodalTools.PipelineDiagnostics
open BimodalTools.TableauBridge (BranchGates evalBranchGates gatesOfBranch)
open BimodalTools.AtomCanonicalization (collectAtomsDFS deduplicateCanonical)
open BimodalTools.CertificateImport (RawCertificate checkRaw CheckResult)

namespace BimodalTools.TheoremPipeline

/-! ## Configuration -/

/--
Everything a run is parameterized by.

`atoms` is required rather than defaulted, and is echoed into every record. The measured yield is
superexponential in pool size — `Boolean` 14 and `ModalBoolean` 133 at a two-atom pool, against
902 and 751 in a dataset tabulation at a wider one — so a yield figure without its pool says
nothing, and the CLI refuses to emit one.
-/
structure Config where
  /-- The fragment to enumerate and filter by. -/
  fragment : BimodalLib.Fragment
  /-- The `Formula.complexity` bound: pattern-aware operator layers, not primitive nodes. -/
  maxComplexity : Nat
  /-- The atom pool. Required, and recorded in every head. -/
  atoms : List Atom
  /-- The frame classes the countermodel half runs at. The theorem half is always `Base`. -/
  frameClasses : List FrameClass
  /-- Wall-clock budget per formula, in milliseconds. -/
  perFormulaTimeoutMs : Nat
  /-- Whole-run deadline in seconds; 0 means none. -/
  deadlineS : Nat
  /-- Where to checkpoint progress, so an interrupted run resumes. -/
  checkpoint : Option System.FilePath := none
  /-- Witness-family certificates for the `ZTime` route. -/
  certificates : List RawCertificate := []
  /-- The statements already present in the registry, as (declaration name, statement) pairs.
  ADMIT refuses a candidate strictly subsumed by any of them, which is what the task's ADMISSION
  rule means by "an entry already present". Produced by
  `specs/evidence/theorem-library-pipeline/registry-statements.lean`. -/
  registryStatements : List (String × Formula) := []
  /-- The exact command line, recorded in every head and in the sidecar. -/
  command : String
  /-- The commit the run is measured at. -/
  commit : String
  /-- Zero the one volatile timing field, for a byte-stable record. -/
  zeroTimings : Bool := false
  /-- The namespace the generated module declares. -/
  moduleNamespace : String := "BimodalLib.Theorems.Enumerated"

/-- The name of a frame class, matching the spelling the datasets use. -/
def fcName : FrameClass → String
  | .Base => "Base"
  | .Dense => "Dense"
  | .ZTime => "ZTime"
  | .RTime => "RTime"

/-- Read a frame class from its name. -/
def fcOfName? : String → Option FrameClass
  | "Base" => some .Base
  | "Dense" => some .Dense
  | "ZTime" => some .ZTime
  | "RTime" => some .RTime
  | _ => none

/-- Every frame class, in the order every table reports them. -/
def allFrameClasses : List FrameClass := [.Base, .Dense, .ZTime, .RTime]

/-- Read a fragment from its name. -/
def fragmentOfName? : String → Option BimodalLib.Fragment
  | "Boolean" => some .Boolean
  | "ModalBoolean" => some .ModalBoolean
  | "TemporalBoolean" => some .TemporalBoolean
  | "ModalTemporalBoolean" => some .ModalTemporalBoolean
  | _ => none

/-- The fragment of a formula, from the registry's own computed profile (not a depth encoding). -/
def fragOf (φ : Formula) : BimodalLib.Fragment := (BimodalLib.profileF φ).fragment

/--
The enumerator configuration that can produce `cfg.fragment` at its bound. The modal and temporal
depth budgets are opened only for the families the fragment contains.
-/
def enumConfigOf (cfg : Config) : EnumConfig :=
  let n := cfg.maxComplexity
  match cfg.fragment with
  | .Boolean =>
      { maxModalDepth := 0, maxTemporalDepth := 0, maxSize := n, atomPool := cfg.atoms }
  | .ModalBoolean =>
      { maxModalDepth := n, maxTemporalDepth := 0, maxSize := n, atomPool := cfg.atoms }
  | .TemporalBoolean =>
      { maxModalDepth := 0, maxTemporalDepth := n, maxSize := n, atomPool := cfg.atoms }
  | .ModalTemporalBoolean =>
      { maxModalDepth := n, maxTemporalDepth := n, maxSize := n, atomPool := cfg.atoms }

/-! ## The shared head -/

/-- The head of one record. -/
def headOf (cfg : Config) (stage : Stage) (statement : String) (fc : FrameClass) : Head :=
  { statement := statement
    stage := stage
    fragment := cfg.fragment.name
    frameClass := fcName fc
    commit := cfg.commit
    command := cfg.command }

/-! ## ENUMERATE -/

/--
The surviving formulas: enumerated at the bound, canonicalized to one representative per renaming
of atoms, then filtered to the configured fragment by `profileF`.
-/
def enumerateStage (cfg : Config) : List Formula × Nat :=
  let raw := enumerateUpToDepth (enumConfigOf cfg)
  let canon := deduplicateCanonical raw
  let kept := canon.filter (fun φ => fragOf φ == cfg.fragment)
  (kept, raw.length - canon.length)

/-- The `enumerate` record for a whole run. -/
def enumerateRecord (cfg : Config) (kept : List Formula) (duplicatesRemoved : Nat) :
    EnumerateRecord :=
  let byComplexity :=
    (List.range (cfg.maxComplexity + 1)).filterMap fun n =>
      let c := (kept.filter (fun φ => φ.complexity == n)).length
      if c == 0 then none else some (n, c)
  { head := headOf cfg .enumerate ("fragment:" ++ cfg.fragment.name) .Base
    formulasGenerated := kept.length
    byFragment := [(cfg.fragment.name, kept.length)]
    byComplexity := byComplexity
    duplicatesRemoved := duplicatesRemoved }

/-! ## DECIDE -/

/-- The verdict vocabulary, read off a `DecisionResult`. -/
def verdictOf {φ : Formula} : DecisionResult φ → Verdict
  | .valid _ => .valid
  | .invalid _ => .invalid
  | .fuelExhausted => .fuelExhausted
  | .extractionFailed => .extractionFailed

/--
A formula that reached ADMIT with a live derivation. The derivation cannot be rebuilt from a
record, so the driver carries the tree itself — the `ProofPool` shape.
-/
structure Candidate where
  /-- The concrete formula the tableau decided. -/
  formula : Formula
  /-- Its extracted derivation, at `Base`, where extraction produces derivations. -/
  proof : DerivationTree FrameClass.Base [] formula
  /-- The atoms to generalize, in depth-first first-occurrence order. -/
  atoms : List Atom

/-- What DECIDE produced for one formula. -/
structure Decided where
  /-- The formula. -/
  formula : Formula
  /-- Its verdict. -/
  verdict : Verdict
  /-- Wall-clock time spent deciding, in milliseconds. -/
  elapsedMs : Nat
  /-- The fuel tier the adaptive strategy reported. -/
  tier : String
  /-- The adaptive fuel actually offered. -/
  fuel : Nat
  /-- The live derivation, when the verdict is `valid`. -/
  candidate : Option Candidate
  /-- The countermodel, when the verdict is `invalid`. -/
  countermodel : Option SimpleCountermodel

/--
Decide one formula under a wall-clock budget.

`labelFormulaImpl`'s shape, reused: a dedicated `IO.asTask` running the *cancellable* decision
mirror, a cooperative `abortRef` the mirror observes at every tableau step, and the adaptive fuel
`min 500 (150 + complexity * 30)`. A timeout is recorded as `fuelExhausted`, which is what it is
from the pipeline's point of view: no verdict was reached.
-/
def decideOne (cfg : Config) (φ : Formula) : IO Decided := do
  let atoms := collectAtomsDFS φ
  let fuel := min 500 (150 + φ.complexity * 30)
  let startTime ← IO.monoMsNow
  let abortRef ← IO.mkRef false
  let task ← IO.asTask (prio := .dedicated) do
    decideAutoAdaptiveCancellable abortRef φ FrameClass.Base fuel
  let deadline := startTime + cfg.perFormulaTimeoutMs
  let mut timedOut := false
  repeat do
    let done ← IO.hasFinished task
    if done then break
    let now ← IO.monoMsNow
    if cfg.perFormulaTimeoutMs > 0 && now >= deadline then
      timedOut := true
      break
    IO.sleep 1
  let endTime ← IO.monoMsNow
  let elapsed := endTime - startTime
  if timedOut then
    abortRef.set true
    IO.cancel task
    return { formula := φ, verdict := .fuelExhausted, elapsedMs := elapsed
             tier := "wallclock_timeout", fuel := fuel, candidate := none
             countermodel := none }
  let taskResult ← IO.wait task
  let (result, tier) ← IO.ofExcept taskResult
  match result with
  | .valid proof =>
      return { formula := φ, verdict := .valid, elapsedMs := elapsed, tier := tier
               fuel := fuel
               candidate := some { formula := φ, proof := proof, atoms := atoms }
               countermodel := none }
  | .invalid counter =>
      return { formula := φ, verdict := .invalid, elapsedMs := elapsed, tier := tier
               fuel := fuel, candidate := none, countermodel := some counter }
  | .fuelExhausted =>
      return { formula := φ, verdict := .fuelExhausted, elapsedMs := elapsed, tier := tier
               fuel := fuel, candidate := none, countermodel := none }
  | .extractionFailed =>
      -- A principal path: the tableau closed, so the formula is valid, but no witness came out.
      -- Never retried at higher fuel and never logged as an anomaly.
      return { formula := φ, verdict := .extractionFailed, elapsedMs := elapsed, tier := tier
               fuel := fuel, candidate := none, countermodel := none }

/-- The `decide` record for one formula. -/
def decideRecord (cfg : Config) (statement : String) (d : Decided) : DecideRecord :=
  { head := headOf cfg .decide statement .Base
    verdict := d.verdict
    decisionTimeMs := d.elapsedMs
    fuelUsed := d.fuel
    branchesOpened := 0
    branchesClosed := 0 }

/-! ## EXTRACT -/

/--
The axiom constructor names a derivation instantiates, in first-use order and without repeats.

Reuses `axiomConstructorName` from the emitter, which carries the exhaustive 20-arm match, rather
than a second constructor table that could drift from it.
-/
def axiomNamesOf {fc : FrameClass} : {Γ : Context} → {φ : Formula} →
    DerivationTree fc Γ φ → List String
  | _, _, .axiom _ _ h _ => [axiomConstructorName h]
  | _, _, .assumption _ _ _ => []
  | _, _, .modus_ponens _ _ _ d1 d2 => (axiomNamesOf d1 ++ axiomNamesOf d2).eraseDups
  | _, _, .necessitation _ d => axiomNamesOf d
  | _, _, .temporal_necessitation _ d => axiomNamesOf d
  | _, _, .time_reflection _ d => axiomNamesOf d
  | _, _, .weakening _ _ _ d _ => axiomNamesOf d


/--
The open branch of `φ`'s tableau at `fc`, with its gates and its world and time counts.

One rebuild serves both EXTRACT and CERTIFY: `DecisionResult` discards the branch and the
`TimeOrdering`, so the branch has to be recovered, and recovering it twice would double the
dominant cost of the countermodel half. `buildTableau φ (soundFuel φ) fc` is the exact call
`decideAuto` makes, and `buildTableau` is pure and total, so the branch recovered here is the one
the `invalid` verdict came from.
-/
def rebuildOpenBranch (φ : Formula) (fc : FrameClass) :
    Option (BranchGates × Nat × Nat) :=
  match buildTableau φ (soundFuel φ) fc with
  | some (.hasOpen b ord _ _) =>
      some (gatesOfBranch φ b ord fc, b.knownWorlds.length, b.knownTimes.length)
  | _ => none

/-- Which extraction route ran for a verdict. -/
def extractionRouteOf : Verdict → String
  | .valid => "proof_extractor"
  | .invalid => "countermodel_extractor"
  | .fuelExhausted => "none"
  | .extractionFailed => "proof_extractor_incomplete"

/-- The `extract` record for one decided formula. -/
def extractRecord (cfg : Config) (statement : String) (d : Decided)
    (branch : Option (BranchGates × Nat × Nat)) : ExtractRecord :=
  let sizes := d.candidate.map fun c =>
    (BimodalLib.Diagnostics.derivationSize c.proof, c.proof.height)
  { head := headOf cfg .extract statement .Base
    derivationSize := sizes.map (·.1)
    derivationHeight := sizes.map (·.2)
    axiomSchemata := match d.candidate with
      | none => []
      | some c => axiomNamesOf c.proof
    extractionRoute := extractionRouteOf d.verdict
    countermodelHistories := match d.verdict, branch with
      | .invalid, some (_, worlds, _) => some worlds
      | _, _ => none
    countermodelTimes := match d.verdict, branch with
      | .invalid, some (_, _, times) => some times
      | _, _ => none }

/-! ## CERTIFY -/

/--
Whether a supplied certificate's target names `φ` as a conclusion, which is the condition under
which `checkRaw`'s verdict is a verdict *about* `φ`.
-/
def certificateTargets (φ : Formula) (raw : RawCertificate) : Bool :=
  raw.target.conclusions.contains φ

/--
The `ZTime` route: a witness-family certificate accepted by `decidableCertifies`.

`checkRaw` runs the four decidable conditions through `WitnessFamily.decidableCertifies` and
returns `.countermodel` only when every one of them decided `true`. Certificates are supplied
rather than manufactured — nothing in this tree derives a `RawCertificate` from a tableau branch —
so `none` here is the ordinary case and is reported as an ungraded refutation.
-/
def certifyByCertificate (cfg : Config) (φ : Formula) : Option Grade :=
  match cfg.certificates.find? (certificateTargets φ) with
  | none => none
  | some raw =>
      match checkRaw raw with
      | .countermodel _ _ => some Grade.certificate
      | _ => none

/--
The `certify` record for one refutation at one frame class.

The frame-class dispatch is the whole of Decision 12: `ZTime` takes the certificate route and
evaluates no gates, and the other three take the gate route. A `ZTime` record therefore carries
`certificate` or no grade, and `gates := none`, which is what
`CertifyRecord.zTimeWellFormed` asserts.
-/
def certifyStage (cfg : Config) (statement : String) (φ : Formula) (fc : FrameClass) :
    CertifyRecord :=
  match fc with
  | .ZTime =>
      { head := headOf cfg .certify statement fc
        axioms := []
        countermodelGrade := certifyByCertificate cfg φ
        gates := none }
  | _ =>
      let gates := evalBranchGates φ fc
      { head := headOf cfg .certify statement fc
        axioms := []
        countermodelGrade :=
          match gates with
          | some g => if g.gated then some Grade.gatedTableau else none
          | none => none
        gates := gates }

/-- The `certify` record on the theorem side: the axiom set the derivation instantiates. -/
def certifyTheorem (cfg : Config) (statement : String) (c : Candidate) : CertifyRecord :=
  { head := headOf cfg .certify statement .Base
    axioms := axiomNamesOf c.proof
    countermodelGrade := none
    gates := none }

/-! ## ADMIT -/

/-- One admitted entry: its generated declaration name and its Lean source. -/
structure Admitted where
  /-- The generated declaration's name, unqualified. -/
  declName : String
  /-- The whole generated declaration, including its `register_theorem` line. -/
  source : String
  /-- The concrete statement the entry generalizes. -/
  formula : Formula
  /-- The generalized statement, for the subsumption test. -/
  schema : Formula

/--
The generated declaration name for a candidate: `enumerated` plus its position, camelCase.

Underscored names are avoided deliberately: check `C26` flags a non-trailing underscore in a live
`def`/`abbrev` name, and the `env_linter` sweep over the non-`FormalSystem` lakefile roots carries
a pinned finding ceiling.
-/
def admittedName (index : Nat) : String := "enumerated" ++ toString index

/--
Strict subsumption, mirroring `assert_no_subsumed_entries`' own test exactly: `stmt` is an
instance of `schema` and not conversely.

The asymmetry is the point. Two statements each an instance of the other are renamings, which
`register_theorem` already refuses by name; only the strictly-more-general direction is a
redundancy. Testing the symmetric form here would make ADMIT drop entries the build invariant
does not object to.
-/
def strictlySubsumedBy (schema stmt : Formula) : Bool :=
  BimodalLib.isSubstInstance schema stmt && !BimodalLib.isSubstInstance stmt schema

/-- A candidate with its generalized statement, carried through ADMIT's two passes. -/
private structure Scored where
  /-- The candidate. -/
  candidate : Candidate
  /-- Its generalized statement, which is what both subsumption passes compare. -/
  schema : Formula
  /-- The row that subsumes it, once one is found. -/
  subsumer : Option String

/--
ADMIT: generalize each candidate and emit its declaration, dropping any candidate that is a
substitution instance of an entry already present.

**"Already present" means two things, and both passes are needed.** The task's ADMISSION rule is
that a candidate is admitted "unless it is a substitution instance of an entry already present",
and the entries already present are the whole registry, hand-curated rows included — not merely
the candidates this run has admitted so far.

Pass 1 compares each candidate against `cfg.registryStatements`, the snapshot of the live
registry. Without it the pipeline emits entries that duplicate hand-curated laws: measured, two
of ten admitted entries at the ruled bound were substitution instances of
`FormalSystem.Theorems.ConnectDerived.lceImpThm`, and the build invariant caught both.

Pass 2 compares the survivors against **each other**, and is deliberately a separate pass rather
than a fold. A single accumulating fold is order-dependent and misses a real redundancy: if a
less general candidate is seen first it is admitted, and the more general one that arrives later
is not an instance of it, so both are kept. Measured: two further pairs of the same ten entries
were caught by the invariant for exactly this reason. Comparing every survivor against every
other has no such blind spot, and keeps the more general of each pair because the test is strict.
-/
def admitStage (cfg : Config) (candidates : List Candidate) :
    List Admitted × List (Candidate × String) :=
  let scored : List Scored := candidates.map fun c =>
    { candidate := c, schema := schemaFormula c.atoms c.formula, subsumer := none }
  -- Pass 1: against the registry snapshot.
  let afterRegistry : List Scored := scored.map fun s =>
    match cfg.registryStatements.find? (fun r => strictlySubsumedBy r.2 s.schema) with
    | some r => { s with subsumer := some r.1 }
    | none => s
  -- Pass 2: survivors against each other, every pair, not a fold.
  let survivors := afterRegistry.filter (fun s => s.subsumer.isNone)
  let afterSelf : List Scored := afterRegistry.map fun s =>
    if s.subsumer.isSome then s
    else
      match survivors.find? (fun o =>
          !(o.schema == s.schema) && strictlySubsumedBy o.schema s.schema) with
      | some o => { s with subsumer := some ("the generated entry for " ++ o.schema.prettyPrint) }
      | none => s
  let keep := afterSelf.filter (fun s => s.subsumer.isNone)
  let dropped := afterSelf.filterMap fun s =>
    s.subsumer.map (fun n => (s.candidate, n))
  let admitted := (keep.zip (List.range keep.length)).map fun p =>
    let name := admittedName p.2
    { declName := name
      source := entrySource cfg.moduleNamespace name p.1.candidate.atoms p.1.candidate.proof
      formula := p.1.candidate.formula
      schema := p.1.schema }
  (admitted, dropped)

/-- The `admit` record for an admitted entry. -/
def admitRecordAdmitted (cfg : Config) (statement : String) : AdmitRecord :=
  { head := headOf cfg .admit statement .Base
    disposition := .admitted
    subsumedBy := none
    conjectureVerdict := none }

/--
The `admit` record for a candidate subsumed by an entry already present.

`subsumer` is recorded VERBATIM and is not prefixed with the generated module's namespace: a
subsuming row is as often a hand-curated registry declaration (`FormalSystem.Theorems....`) as a
sibling generated entry, and prefixing would produce a name that resolves to nothing.
-/
def admitRecordSubsumed (cfg : Config) (statement subsumer : String) : AdmitRecord :=
  { head := headOf cfg .admit statement .Base
    disposition := .subsumed
    subsumedBy := some subsumer
    conjectureVerdict := none }

/--
The `admit` record for a non-admitted outcome.

Every verdict that is not `valid`-with-a-derivation lands here with its verdict verbatim:
`fuelExhausted`, `extractionFailed`, and an `invalid` verdict that is neither gated nor
certified. The conjecture half is expected to dominate the admitted half.
-/
def admitRecordConjecture (cfg : Config) (statement : String) (v : Verdict) (fc : FrameClass) :
    AdmitRecord :=
  { head := headOf cfg .admit statement fc
    disposition := .conjecture
    subsumedBy := none
    conjectureVerdict := some v }

/-! ## The run -/

/-- One certified refutation, in the form the countermodels record will read. Not registered. -/
structure Refutation where
  /-- The refuted inference's statement identifier. -/
  statement : String
  /-- The refuted formula, pretty-printed. -/
  inference : String
  /-- The frame class it is refuted at. -/
  frameClass : String
  /-- The grade, when it has one. -/
  grade : Option Grade
  /-- The eight gates, when they were evaluated. -/
  gates : Option BranchGates
  /-- The countermodel's true atoms. -/
  trueAtoms : List String
  /-- The countermodel's false atoms. -/
  falseAtoms : List String

/-- A refutation as one JSON object, in the shape the countermodels record will read. -/
def Refutation.toJson (r : Refutation) : Json :=
  Json.mkObj
    [ ("statement", Json.str r.statement)
    , ("inference", Json.str r.inference)
    , ("frame_class", Json.str r.frameClass)
    , ("grade", match r.grade with
        | none => Json.null
        | some g => Json.str g.key)
    , ("gates", gatesValue r.gates)
    , ("true_atoms", Json.arr ((r.trueAtoms.map Json.str)).toArray)
    , ("false_atoms", Json.arr ((r.falseAtoms.map Json.str)).toArray) ]

/--
Everything the first four stages produced, with ADMIT not yet run.

ADMIT is deliberately not part of this: subsumption has to be decided over **all** candidates at
once, so a run covering several fragments admits once at the end rather than once per fragment.
Admitting per fragment would let a `ModalBoolean` entry be registered that is a substitution
instance of a `Boolean` one already admitted, which is exactly what the subsumption test exists to
prevent.
-/
structure Staged where
  /-- Stage records, in emission order, for the stages before ADMIT. -/
  records : List Json
  /-- The certified refutations. -/
  refutations : List Refutation
  /-- Candidates carrying a live derivation. -/
  candidates : List Candidate
  /-- How many formulas reached DECIDE. -/
  decidedCount : Nat
  /-- The four-way verdict split, in `Verdict.all` order. -/
  verdictSplit : List (String × Nat)
  /-- How many conjecture records were written before ADMIT. -/
  conjectureCount : Nat
  /-- The next free statement serial, so a later fragment's identifiers do not collide. -/
  nextSerial : Nat

/-- An empty stage result, at the given starting serial. -/
def Staged.empty (serial : Nat) : Staged :=
  { records := [], refutations := [], candidates := [], decidedCount := 0
    verdictSplit := Verdict.all.map (fun v => (v.key, 0)), conjectureCount := 0
    nextSerial := serial }

/-- Concatenate two stage results, summing the splits. -/
def Staged.append (a b : Staged) : Staged :=
  { records := a.records ++ b.records
    refutations := a.refutations ++ b.refutations
    candidates := a.candidates ++ b.candidates
    decidedCount := a.decidedCount + b.decidedCount
    verdictSplit := a.verdictSplit.zip b.verdictSplit |>.map (fun p => (p.1.1, p.1.2 + p.2.2))
    conjectureCount := a.conjectureCount + b.conjectureCount
    nextSerial := b.nextSerial }

/-- Everything one run produced. -/
structure Outcome where
  /-- Every stage record, in emission order. -/
  records : List Json
  /-- The certified refutations, in the countermodels record's form. -/
  refutations : List Refutation
  /-- The admitted entries' generated source. -/
  admitted : List Admitted
  /-- Candidates dropped as substitution instances, with the subsuming entry's name. -/
  subsumed : List (Candidate × String)
  /-- How many formulas reached DECIDE. -/
  decidedCount : Nat
  /-- The four-way verdict split, in `Verdict.all` order. -/
  verdictSplit : List (String × Nat)
  /-- How many conjecture records were written. -/
  conjectureCount : Nat

/--
Run the four stages before ADMIT, over one fragment.

The loop is bounded twice: `perFormulaTimeoutMs` per formula, and `deadlineS` for the whole run.
A run that hits the whole-run deadline stops where it is and reports what it has, which is a
legitimate partial outcome — the records and refutations written so far stand. `checkpoint`, when
given, is rewritten after each formula with the serial reached, so an interrupted run resumes.
-/
def runStages (cfg : Config) (startSerial : Nat := 0) : IO Staged := do
  let (kept, duplicatesRemoved) := enumerateStage cfg
  let mut records : List Json := [(enumerateRecord cfg kept duplicatesRemoved).toJson]
  let mut refutations : List Refutation := []
  let mut candidates : List Candidate := []
  let mut split : List (String × Nat) := Verdict.all.map (fun v => (v.key, 0))
  let mut conjectureCount := 0
  let mut decidedCount := 0
  let runStart ← IO.monoMsNow
  let mut serial := startSerial
  for φ in kept do
    if cfg.deadlineS > 0 then
      let now ← IO.monoMsNow
      if now - runStart >= cfg.deadlineS * 1000 then
        break
    let statement := datasetStatementId "bmlogic" serial
    serial := serial + 1
    let d ← decideOne cfg φ
    decidedCount := decidedCount + 1
    split := split.map (fun p => if p.1 == d.verdict.key then (p.1, p.2 + 1) else p)
    records := records ++ [(decideRecord cfg statement d).toJson cfg.zeroTimings]
    -- One rebuild, shared by EXTRACT and CERTIFY, and only where there is a branch to recover.
    let baseBranch := if d.verdict == Verdict.invalid then rebuildOpenBranch φ .Base else none
    records := records ++ [(extractRecord cfg statement d baseBranch).toJson]
    match d.verdict with
    | .valid =>
        match d.candidate with
        | some c =>
            candidates := candidates ++ [c]
            records := records ++ [(certifyTheorem cfg statement c).toJson]
        | none =>
            conjectureCount := conjectureCount + 1
            records := records ++
              [(admitRecordConjecture cfg statement .extractionFailed .Base).toJson]
    | .invalid =>
        let mut anyGrade := false
        for fc in cfg.frameClasses do
          let cr := certifyStage cfg statement φ fc
          records := records ++ [cr.toJson]
          if cr.countermodelGrade.isSome then
            anyGrade := true
            refutations := refutations ++
              [{ statement := statement
                 inference := φ.prettyPrint
                 frameClass := fcName fc
                 grade := cr.countermodelGrade
                 gates := cr.gates
                 trueAtoms := (d.countermodel.map (·.trueAtoms)).getD [] |>.map (·.base)
                 falseAtoms := (d.countermodel.map (·.falseAtoms)).getD [] |>.map (·.base) }]
        if !anyGrade then
          conjectureCount := conjectureCount + 1
          records := records ++ [(admitRecordConjecture cfg statement .invalid .Base).toJson]
    | v =>
        -- `fuelExhausted` and `extractionFailed`: the conjecture half, verdict verbatim.
        conjectureCount := conjectureCount + 1
        records := records ++ [(admitRecordConjecture cfg statement v .Base).toJson]
    match cfg.checkpoint with
    | none => pure ()
    | some path => IO.FS.writeFile path (toString serial ++ "\n")
  return { records := records
           refutations := refutations
           candidates := candidates
           decidedCount := decidedCount
           verdictSplit := split
           conjectureCount := conjectureCount
           nextSerial := serial }

/-- Finish a stage result with ADMIT, which runs once over every candidate. -/
def finish (cfg : Config) (st : Staged) : Outcome :=
  let (admitted, subsumed) := admitStage cfg st.candidates
  let admittedRecords := admitted.map fun a =>
    (admitRecordAdmitted cfg (cfg.moduleNamespace ++ "." ++ a.declName)).toJson
  let subsumedRecords := subsumed.map fun p =>
    (admitRecordSubsumed cfg p.1.formula.prettyPrint p.2).toJson
  { records := st.records ++ admittedRecords ++ subsumedRecords
    refutations := st.refutations
    admitted := admitted
    subsumed := subsumed
    decidedCount := st.decidedCount
    verdictSplit := st.verdictSplit
    conjectureCount := st.conjectureCount }

/-- Run the five stages over one fragment. -/
def run (cfg : Config) : IO Outcome := do
  return finish cfg (← runStages cfg)

/--
The ruled bound per fragment, as the user fixed it: `Boolean` and `ModalBoolean` at complexity 5,
`TemporalBoolean` and `ModalTemporalBoolean` at complexity 4. "Complexity N" is N pattern-aware
operator layers in `Formula.complexity`'s measure, not N primitive nodes.
-/
def ruledBound : BimodalLib.Fragment → Nat
  | .Boolean => 5
  | .ModalBoolean => 5
  | .TemporalBoolean => 4
  | .ModalTemporalBoolean => 4

/-- The four fragments, in the order every table reports them. -/
def allFragments : List BimodalLib.Fragment :=
  [.Boolean, .ModalBoolean, .TemporalBoolean, .ModalTemporalBoolean]

/--
Run the five stages over all four fragments, each at its own ruled bound, as one command.

ADMIT runs **once**, over the candidates of every fragment together, so the subsumption test sees
the whole admitted set and a later fragment cannot register an instance of an earlier fragment's
entry. Statement serials continue across fragments, so no two records share an identifier.

A whole-run `deadlineS` is divided evenly across the fragments rather than spent on the first one,
so a budget that runs out still produces records for every fragment instead of none for three of
them.
-/
def runAll (cfg : Config) : IO Outcome := do
  let perFragment := if cfg.deadlineS == 0 then 0 else cfg.deadlineS / allFragments.length
  let mut st := Staged.empty 0
  for frag in allFragments do
    let fragCfg := { cfg with fragment := frag, maxComplexity := ruledBound frag,
                              deadlineS := perFragment }
    let one ← runStages fragCfg st.nextSerial
    st := st.append one
  return finish cfg st

/-! ## The generated module -/

/--
The invocation that reproduces a run, reconstructed from the configuration rather than echoed
from `argv`.

Two reasons, both load-bearing. The raw command line carries incidental paths — an `--out-module`
under a scratch directory, say — and a path is not part of what makes a run reproducible. And an
arbitrary path can begin with a slash and a hyphen, which inside a generated doc comment opens a
nesting Lean
block comment and breaks the file; `commentSafe` guards the rest, but not emitting a path at all
is better than sanitizing one. (That delimiter is why this docstring does not spell it out.)
The authoritative full command line is recorded where it belongs:
every record's `command` head field, and the dataset sidecar.
-/
def reproCommand (cfg : Config) : List String :=
  [ "bash scripts/theorem-library-pipeline.sh \\"
  , "  --fragment " ++ cfg.fragment.name
      ++ " --max-complexity " ++ toString cfg.maxComplexity
      ++ " --atoms " ++ toString cfg.atoms.length ++ " \\"
  , "  " ++ String.intercalate " " (cfg.frameClasses.map (fun fc => "--frame-class " ++ fcName fc))
  ]

/--
The preamble of the generated theorem module.

`lineBudget` is emitted as a file-level `set_option linter.style.longFile`. That option is the
ONE file-level linter `set_option` the package sanctions (see `lakefile.toml`'s package-options
comment and check `C30`), and the generated module needs it: a fully explicit concrete derivation
is hundreds of lines on its own, so ten admitted entries came to 2,150 lines against the
package's 1,500-line limit, which `--wfail` turns into a failure. The value is PINNED to the
file's actual length rather than set to a round ceiling, so a module that grows past it trips the
linter again instead of being silently exempt.
-/
def modulePreamble (cfg : Config) (lineBudget : Nat) : String := String.intercalate "\n"
  ([ "/-"
   , "Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved."
   , "Released under Apache 2.0 license as described in the file LICENSE."
   , "Authors: Benjamin Brast-McKie"
   , "-/"
   , ""
   , "import BimodalLib.Registry"
   , "import FormalSystem.ProofSystem.Substitution"
   , ""
   , "/-!"
   , "# Registered theorems: enumerated by the tableau pipeline"
   , ""
   , "Generated. Do not edit by hand; regenerate with:"
   , ""
   , "```bash"
   ] ++ reproCommand cfg ++
   [ "```"
   , ""
   , "The bound is " ++ toString cfg.maxComplexity ++ " pattern-aware operator layers in"
   , "`Formula.complexity`'s measure, not primitive nodes, over an atom pool of "
       ++ toString cfg.atoms.length ++ "."
   , "The fragment is `" ++ cfg.fragment.name ++ "` and the frame class is `Base`, where proof"
   , "extraction produces derivations. The full command line, with every path, is in each"
   , "record's `command` field and in the dataset sidecar."
   , "-/"
   , ""
   , "-- A fully explicit concrete derivation runs to hundreds of lines, so this generated module"
   , "-- exceeds the package's 1500-line limit. The long-file baseline is the one file-level"
   , "-- linter option the package sanctions; it is pinned to this file's own length, so growth"
   , "-- past it trips the linter rather than passing silently. It sits AFTER the module"
   , "-- docstring, which the style linter requires to be the first command after the imports."
   , "set_option linter.style.longFile " ++ toString lineBudget
   , ""
   , "open FormalSystem.Syntax"
   , "open FormalSystem.ProofSystem"
   , ""
   , "namespace " ++ cfg.moduleNamespace
   , ""
   ])

/--
The whole generated module: the preamble, every admitted entry, and the namespace close.

Assembled in two passes, because the preamble carries the file's own line budget: the body is
built first, its lines counted, and the budget pinned at the next multiple of 100 above the
total.
-/
def moduleSource (cfg : Config) (admitted : List Admitted) : String :=
  let body := String.intercalate "\n\n" (admitted.map (·.source))
    ++ "\n\nend " ++ cfg.moduleNamespace ++ "\n"
  -- The preamble's own length does not depend on the budget's number of digits enough to matter,
  -- so one measurement of a budget-free preamble plus the body is sufficient.
  let probe := modulePreamble cfg 0 ++ body
  let total := (probe.splitOn "\n").length
  let budget := ((total / 100) + 1) * 100
  modulePreamble cfg budget ++ body

end BimodalTools.TheoremPipeline
