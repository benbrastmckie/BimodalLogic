/-
Probe 18 -- the DECISION GATE for the position-space leaf cache.

`verts` filters `Finset.univ ×ˢ winTimes` by `v.1 ∈ G.posAt v.2`, so it calls `posAt` once per
PAIR -- 128 x 4 = 512 times at `certA` -- although only 4 distinct times occur. The mirror below
tabulates `posAt` over the window extended one step each way and reads the table instead.

TWO SHAPES ARE MEASURED, not one, because D4 anticipated that the `G`-parameterized form loses
interpreter-level sharing: `G.posTableP` is a function application the interpreter re-runs on
every `posAtC` call, which would make the cache WORSE than no cache. `vertsL` binds the table
once in a `let` outside the filter lambda; `vertsC` does not. Which of the two Phase 7 would
have to land depends on this measurement.

Harness: as probe 16 -- the measured value is forced through an `IO` write before the second
`IO.monoMsNow` read.
-/
import FormalSystem
open FormalSystem.Syntax FormalSystem.PlusLanguage
open FormalSystem.Metalogic.Decidability
open FormalSystem.Metalogic.Decidability.PlusSlicedCertificate

namespace Probe716CacheGate

def logPath : System.FilePath :=
  "/tmp/claude-1000/-home-benjamin-Projects-BimodalLogic/cdc42a16-7328-4525-8f63-a2cd097dc642/scratchpad/probe18.out"

def say (s : String) : IO Unit := do
  let h ← IO.FS.Handle.mk logPath IO.FS.Mode.append
  h.putStrLn s
  h.flush

def timeIt {α : Type} [ToString α] (name : String) (f : Unit → α) : IO Unit := do
  say s!"START {name}"
  let t0 ← IO.monoMsNow
  say s!"  {name} = {toString (f ())}"
  let t1 ← IO.monoMsNow
  say s!"    [{t1 - t0} ms]"

/-! ## The mirror, in the shape Phase 7 would land

The declarations live in `PlusSlicedCertificate`'s own namespace so that dot notation resolves,
and carry a `P` suffix so that re-running this probe after Phase 7 lands the real names cannot
collide with them.
-/

end Probe716CacheGate

namespace FormalSystem.Metalogic.Decidability.PlusSlicedCertificate

variable {Gm Dl : PlusContext}

/-- `posAt` tabulated over the window times extended one step each way. -/
def posTableP (G : PlusSlicedCertificate Gm Dl) : List (ℤ × Finset G.Pos) :=
  (List.range (G.winHi - G.winLo + 2).toNat).map fun i =>
    (G.winLo - 1 + (i : ℤ), G.posAt (G.winLo - 1 + (i : ℤ)))

/-- The table lookup, with `posAt` itself as the off-range fallback -- which is what makes the
equality lemma unconditional and so unobservable at every use site. -/
def posAtCP (G : PlusSlicedCertificate Gm Dl) (t : ℤ) : Finset G.Pos :=
  match G.posTableP.find? (fun p => p.1 == t) with
  | some p => p.2
  | none => G.posAt t

/-- Shape A: the plain `posAtC` call per pair. -/
def vertsCP (G : PlusSlicedCertificate Gm Dl) : Finset G.TPos :=
  (Finset.univ ×ˢ G.winTimes).filter (fun v => v.1 ∈ G.posAtCP v.2)

/-- Shape B: the table bound ONCE in a `let` outside the filter lambda. -/
def vertsLP (G : PlusSlicedCertificate Gm Dl) : Finset G.TPos :=
  let tbl := G.posTableP
  (Finset.univ ×ˢ G.winTimes).filter (fun v =>
    v.1 ∈ (match tbl.find? (fun p => p.1 == v.2) with
           | some p => p.2
           | none => G.posAt v.2))

/-- `predT` through shape B, with `verts` and the `predP` value bound once outside the filter. -/
def predTCP (G : PlusSlicedCertificate Gm Dl) (v : G.TPos) : Finset G.TPos :=
  let V := G.vertsLP
  let P := G.predP v.2 v.1
  let u := G.prevTime v.2
  V.filter (fun w => w.2 = u ∧ w.1 ∈ P)

def snceLiveCP (G : PlusSlicedCertificate Gm Dl) (X : Finset G.TPos) (g e : PlusFormula) :
    Finset G.TPos :=
  EUFix.lfp' X (G.predTCP) (Fair.inSet X (G.atPosT e)) (G.atPosT g)

def snceLiveOfCP (G : PlusSlicedCertificate Gm Dl) (X : Finset G.TPos) :
    PlusFormula → Finset G.TPos
  | .snce g e => G.snceLiveCP X g e
  | _ => ∅

def snceTableCP (G : PlusSlicedCertificate Gm Dl) (X : Finset G.TPos) :
    Finset (PlusFormula × Finset G.TPos) :=
  (plusClosureOf (Gm ++ Dl)).image fun ψ => (ψ, G.snceLiveOfCP X ψ)

def bwdLiveStepCP (G : PlusSlicedCertificate Gm Dl) (X : Finset G.TPos) : Finset G.TPos :=
  let tbl := G.snceTableCP X
  X.filter (fun v => (∃ w ∈ G.predTCP v, w ∈ X) ∧
    ∀ ψ ∈ plusClosureOf (Gm ++ Dl), G.snceLiveAtTab tbl v ψ = true)

def bwdLiveTCP (G : PlusSlicedCertificate Gm Dl) : Finset G.TPos :=
  Nu.gfp' G.vertsLP G.bwdLiveStepCP

end FormalSystem.Metalogic.Decidability.PlusSlicedCertificate

namespace Probe716CacheGate

abbrev CA := TotalEdge.certA

#eval show IO Unit from do
  say "=== probe 18: the leaf-cache decision gate at certA ==="
  say "--- the two cache shapes against the landed verts ---"
  timeIt "LANDED  CA.verts.card" (fun _ => CA.verts.card)
  timeIt "SHAPE A CA.vertsCP.card (plain posAtCP per pair)" (fun _ => CA.vertsCP.card)
  timeIt "SHAPE B CA.vertsLP.card (table let-bound once)" (fun _ => CA.vertsLP.card)
  say "--- predT, summed over the vertex set ---"
  timeIt "LANDED  sum predT cards over verts"
    (fun _ => Finset.sum CA.verts (fun v => (CA.predT v).card))
  timeIt "SHAPE B sum predTCP cards over vertsL"
    (fun _ => Finset.sum CA.vertsLP (fun v => (CA.predTCP v).card))
  say "--- one backward contraction, and the whole backward fixpoint ---"
  timeIt "LANDED  (bwdLiveStep verts).card"
    (fun _ => (CA.bwdLiveStep CA.verts).card)
  timeIt "SHAPE B (bwdLiveStepCP vertsL).card"
    (fun _ => (CA.bwdLiveStepCP CA.vertsLP).card)
  timeIt "LANDED  bwdLiveT.card" (fun _ => CA.bwdLiveT.card)
  timeIt "SHAPE B bwdLiveTC.card" (fun _ => CA.bwdLiveTCP.card)
  say "=== probe 18 done ==="

end Probe716CacheGate
