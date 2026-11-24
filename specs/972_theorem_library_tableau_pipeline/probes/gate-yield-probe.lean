/-
Phase 1 probe for task 972 (theorem library: tableau pipeline).

Takes the two figures the research report leaves unmeasured:

1. The surviving per-fragment enumeration count at the ruled bound, after
   `deduplicateCanonical` and the `BimodalLib.profileF` fragment filter (Decision 10).
2. On a BOUNDED, STRIDE-SELECTED sample (at most `sampleCap` formulas per fragment, so the
   sample is reproducible), the four-way `DecisionResult` split; and for the `invalid` members,
   the per-gate `Bool` histogram and the `BranchGates.gated` pass rate at each of the four
   frame classes, plus the wall-clock delta between DECIDE alone and DECIDE + gate evaluation
   over that same sample.

The ruled bound (`.decisions.json`, cycle 4): Boolean and ModalBoolean at complexity 5;
TemporalBoolean and ModalTemporalBoolean at complexity 4. "Complexity N" is N pattern-aware
operator layers in `enumerateUpToDepth`'s `maxSize` measure, not N primitive nodes.

Run with:
  lake env lean --run specs/972_theorem_library_tableau_pipeline/probes/gate-yield-probe.lean
-/
import BimodalTools.FormulaEnumerator
import BimodalTools.AtomCanonicalization
import BimodalTools.TableauBridge
import BimodalLib.Fragment

set_option autoImplicit false
set_option maxHeartbeats 0

open FormalSystem.Syntax
open FormalSystem.ProofSystem (FrameClass)
open FormalSystem.Metalogic.Decidability (decideAuto)

namespace GateYieldProbe

/-- The fragment of a formula, from BimodalLib's own computed profile (Decision 10). -/
def fragOf (φ : Formula) : BimodalLib.Fragment := (BimodalLib.profileF φ).fragment

/-- The four frame classes, in the order every table below reports them. -/
def allFrameClasses : List FrameClass := [.Base, .Dense, .ZTime, .RTime]

/-- The name of a frame class. -/
def fcName : FrameClass → String
  | .Base => "Base"
  | .Dense => "Dense"
  | .ZTime => "ZTime"
  | .RTime => "RTime"

/-- At most this many formulas per fragment enter the DECIDE stage. -/
def sampleCap : Nat := 150

/-- At most this many of a fragment's `invalid` verdicts enter the CERTIFY stage.

CERTIFY is a strictly tighter sub-sample than DECIDE, and deliberately so. `evalBranchGates`
rebuilds the whole tableau per formula per frame class, so the gate stage costs four tableau
builds for every one DECIDE paid, and a first run of this probe at the full DECIDE cap did not
finish the four `ModalBoolean` gate rows in nine minutes of wall clock. Every gate figure below
is therefore labelled with the sub-sample it came from. -/
def gateCap : Nat := 25

/-- The ruled bound per fragment: the `maxSize` complexity budget. -/
def ruledBound : BimodalLib.Fragment → Nat
  | .Boolean => 5
  | .ModalBoolean => 5
  | .TemporalBoolean => 4
  | .ModalTemporalBoolean => 4

/-- The enumerator config that can produce the given fragment at its ruled bound. The modal and
temporal depth budgets are opened only for the families the fragment contains, so the
enumeration is not inflated by formulas the filter would immediately discard. -/
def configFor (frag : BimodalLib.Fragment) (atoms : List Atom) : BimodalTools.EnumConfig :=
  let n := ruledBound frag
  match frag with
  | .Boolean => { maxModalDepth := 0, maxTemporalDepth := 0, maxSize := n, atomPool := atoms }
  | .ModalBoolean => { maxModalDepth := n, maxTemporalDepth := 0, maxSize := n, atomPool := atoms }
  | .TemporalBoolean => { maxModalDepth := 0, maxTemporalDepth := n, maxSize := n, atomPool := atoms }
  | .ModalTemporalBoolean =>
      { maxModalDepth := n, maxTemporalDepth := n, maxSize := n, atomPool := atoms }

/-- Take at most `cap` elements of `xs` by a fixed stride, so the sample is reproducible. -/
def strideSample (cap : Nat) (xs : List Formula) : List Formula :=
  if xs.length ≤ cap then xs
  else
    let step := xs.length / cap
    let step := if step = 0 then 1 else step
    (xs.zipIdx.filter (fun p => p.2 % step = 0)).map (·.1) |>.take cap

/-- The four-way `DecisionResult` split over a sample. -/
structure Split where
  /-- `DecisionResult.valid`. -/
  valid : Nat := 0
  /-- `DecisionResult.invalid`. -/
  invalid : Nat := 0
  /-- `DecisionResult.fuelExhausted`. -/
  fuelExhausted : Nat := 0
  /-- `DecisionResult.extractionFailed`. -/
  extractionFailed : Nat := 0
  deriving Repr

/-- The per-gate `Bool` histogram: how many sampled `invalid` formulas pass each gate. -/
structure GateHist where
  /-- How many branches were evaluated at all (`evalBranchGates` returned `some`). -/
  evaluated : Nat := 0
  /-- `evalBranchGates` returned `none`: no open branch on the rebuild. -/
  noBranch : Nat := 0
  /-- `timeOrderTotal`. -/
  timeOrderTotal : Nat := 0
  /-- `boxAnchored`. -/
  boxAnchored : Nat := 0
  /-- `regionLabel`. -/
  regionLabel : Nat := 0
  /-- `temporalWitness`. -/
  temporalWitness : Nat := 0
  /-- `branchOrderValid`. -/
  branchOrderValid : Nat := 0
  /-- `saturated`. -/
  saturated : Nat := 0
  /-- `noClosure`. -/
  noClosure : Nat := 0
  /-- `rootDenied`. -/
  rootDenied : Nat := 0
  /-- The conjunction: `BranchGates.gated`. -/
  gated : Nat := 0
  deriving Repr

/-- Fold one formula's gate evaluation into the histogram. -/
def GateHist.bump (h : GateHist) (φ : Formula) (fc : FrameClass) : GateHist :=
  match BimodalTools.TableauBridge.evalBranchGates φ fc with
  | none => { h with noBranch := h.noBranch + 1 }
  | some g =>
      let b : Bool → Nat := fun x => if x then 1 else 0
      { h with
        evaluated := h.evaluated + 1
        timeOrderTotal := h.timeOrderTotal + b g.timeOrderTotal
        boxAnchored := h.boxAnchored + b g.boxAnchored
        regionLabel := h.regionLabel + b g.regionLabel
        temporalWitness := h.temporalWitness + b g.temporalWitness
        branchOrderValid := h.branchOrderValid + b g.branchOrderValid
        saturated := h.saturated + b g.saturated
        noClosure := h.noClosure + b g.noClosure
        rootDenied := h.rootDenied + b g.rootDenied
        gated := h.gated + b g.gated }

/-- Pad a string on the left to `n` characters. -/
def pad (n : Nat) (s : String) : String :=
  if s.length ≥ n then s else "".pushn ' ' (n - s.length) ++ s

/-- Pad a string on the right to `n` characters. -/
def padR (n : Nat) (s : String) : String :=
  if s.length ≥ n then s else s ++ "".pushn ' ' (n - s.length)

/-- ENUMERATE for one fragment: enumerate at the ruled bound, canonicalize, filter by
`profileF`. Returns the raw, canonical and surviving counts with the surviving list. -/
def enumerateFragment (frag : BimodalLib.Fragment) (atoms : List Atom) :
    Nat × Nat × List Formula :=
  let raw := BimodalTools.enumerateUpToDepth (configFor frag atoms)
  let canon := BimodalTools.AtomCanonicalization.deduplicateCanonical raw
  let surviving := canon.filter (fun φ => fragOf φ = frag)
  (raw.length, canon.length, surviving)

/-- DECIDE over a sample at `.Base`, reporting the four-way split. -/
def decideSample (sample : List Formula) : Split × List Formula :=
  sample.foldl
    (fun (acc : Split × List Formula) φ =>
      let (s, inv) := acc
      match decideAuto φ .Base with
      | .valid _ => ({ s with valid := s.valid + 1 }, inv)
      | .invalid _ => ({ s with invalid := s.invalid + 1 }, φ :: inv)
      | .fuelExhausted => ({ s with fuelExhausted := s.fuelExhausted + 1 }, inv)
      | .extractionFailed => ({ s with extractionFailed := s.extractionFailed + 1 }, inv))
    ({}, [])

/-- Print a line and flush, so a bounded wait that expires still has every completed row. -/
def say (s : String) : IO Unit := do
  IO.println s
  (← IO.getStdout).flush

/-- Run the whole probe for one fragment and print its rows. -/
def runFragment (frag : BimodalLib.Fragment) (atoms : List Atom) : IO Unit := do
  let name := frag.name
  let bound := ruledBound frag
  say ""
  say s!"## {name} (complexity {bound}, atoms {atoms.length})"

  -- Stage 1: ENUMERATE.
  let t0 ← IO.monoMsNow
  let (rawN, canonN, surviving) := enumerateFragment frag atoms
  let t1 ← IO.monoMsNow
  say s!"enumerate: raw={rawN} canonical={canonN} surviving={surviving.length} ({t1 - t0} ms)"

  -- The bounded, stride-selected sample.
  let sample := strideSample sampleCap surviving
  let sampled := sample.length < surviving.length
  say s!"sample: {sample.length} of {surviving.length} ({if sampled then "SAMPLED by fixed stride" else "EXHAUSTIVE -- whole cell fits the cap"})"

  -- Stage 2: DECIDE at Base, timed on its own.
  let t2 ← IO.monoMsNow
  let (split, invalids) := decideSample sample
  let t3 ← IO.monoMsNow
  let decideMs := t3 - t2
  say s!"decide(.Base): valid={split.valid} invalid={split.invalid} fuelExhausted={split.fuelExhausted} extractionFailed={split.extractionFailed} ({decideMs} ms)"

  -- Stage 3: CERTIFY -- the per-gate histogram and the gated pass rate, per frame class, over a
  -- tighter sub-sample, with the marginal cost of gating measured on a FORCED accumulator.
  let gateSample := strideSample gateCap invalids
  if gateSample.isEmpty then
    say "certify: no invalid verdicts in the sample; no gate rows"
  else
    say s!"gate sub-sample: {gateSample.length} of {invalids.length} invalid ({if gateSample.length < invalids.length then "SAMPLED by fixed stride" else "EXHAUSTIVE"})"
    say ""
    say (padR 6 "fc" ++ pad 6 "eval" ++ pad 5 "none" ++ pad 6 "tot" ++ pad 6 "box"
      ++ pad 6 "rgn" ++ pad 6 "twit" ++ pad 6 "ordV" ++ pad 6 "sat" ++ pad 6 "noCl"
      ++ pad 6 "root" ++ pad 7 "GATED" ++ pad 9 "gate_ms")
    let mut gateTotalMs := 0
    for fc in allFrameClasses do
      let g0 ← IO.monoMsNow
      let h := gateSample.foldl (fun h φ => h.bump φ fc) ({} : GateHist)
      -- The row is built before the clock stops, so every field is forced inside the window.
      let row := padR 6 (fcName fc) ++ pad 6 (toString h.evaluated) ++ pad 5 (toString h.noBranch)
        ++ pad 6 (toString h.timeOrderTotal) ++ pad 6 (toString h.boxAnchored)
        ++ pad 6 (toString h.regionLabel) ++ pad 6 (toString h.temporalWitness)
        ++ pad 6 (toString h.branchOrderValid) ++ pad 6 (toString h.saturated)
        ++ pad 6 (toString h.noClosure) ++ pad 6 (toString h.rootDenied)
        ++ pad 7 (toString h.gated)
      let g1 ← IO.monoMsNow
      gateTotalMs := gateTotalMs + (g1 - g0)
      say (row ++ pad 9 (toString (g1 - g0)))
    say s!"marginal cost: DECIDE alone {decideMs} ms over {sample.length} formulas ({if sample.length = 0 then 0 else decideMs / sample.length} ms/formula); gating {gateTotalMs} ms over {gateSample.length} invalid x 4 frame classes ({if gateSample.length = 0 then 0 else gateTotalMs / (gateSample.length * 4)} ms/(formula,class))"

end GateYieldProbe

def main : IO Unit := do
  let atoms : List FormalSystem.Syntax.Atom := [⟨"p", none⟩, ⟨"q", none⟩]
  GateYieldProbe.say "# Phase 1 gate-yield probe (task 972)"
  GateYieldProbe.say s!"sampleCap={GateYieldProbe.sampleCap}; bounds: Boolean 5, ModalBoolean 5, TemporalBoolean 4, ModalTemporalBoolean 4"
  GateYieldProbe.say "gate columns: tot=timeOrderTotal box=boxAnchored rgn=regionLabel twit=temporalWitness ordV=branchOrderValid sat=saturated noCl=noClosure root=rootDenied"
  for frag in [BimodalLib.Fragment.Boolean, .ModalBoolean, .TemporalBoolean,
      .ModalTemporalBoolean] do
    GateYieldProbe.runFragment frag atoms
  GateYieldProbe.say ""
  GateYieldProbe.say "# done"

