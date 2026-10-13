/-
Probe 17 -- the early-exit saving, measured side by side.

`Nu.gfp' G.verts G.bwdLiveStep` and `Nu.gfp G.verts G.bwdLiveStep` are run at the pinned
self-loop embedded witness under the Phase 1 harness, and the same pair is run for
`EUFix.lfp'` / `EUFix.lfp` at one inner liveness fixpoint. No landed definition is switched at
this point, so this measures the NEW code against the OLD code, not the library against itself.

Harness: as probe 16 -- the measured value is forced through an `IO` write before the second
`IO.monoMsNow` read.
-/
import FormalSystem
open FormalSystem.Syntax FormalSystem.PlusLanguage
open FormalSystem.Metalogic.Decidability
open FormalSystem.Metalogic.Decidability.PlusSharingWitnessFamily

namespace Probe716EarlyExit

def logPath : System.FilePath :=
  "/tmp/claude-1000/-home-benjamin-Projects-BimodalLogic/cdc42a16-7328-4525-8f63-a2cd097dc642/scratchpad/probe17.out"

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

abbrev EC := WitnessFamily.Embedded.liveFamily.sliced (-1)

#eval show IO Unit from do
  say "=== probe 17: the early-exit saving at the embedded witness ==="
  timeIt "OLD Nu.gfp verts bwdLiveStep .card"
    (fun _ => (Nu.gfp EC.verts EC.bwdLiveStep).card)
  timeIt "NEW Nu.gfp' verts bwdLiveStep .card"
    (fun _ => (Nu.gfp' EC.verts EC.bwdLiveStep).card)
  timeIt "OLD Nu.gfp verts fwdLiveStep .card"
    (fun _ => (Nu.gfp EC.verts EC.fwdLiveStep).card)
  timeIt "NEW Nu.gfp' verts fwdLiveStep .card"
    (fun _ => (Nu.gfp' EC.verts EC.fwdLiveStep).card)
  say "=== probe 17 done ==="

end Probe716EarlyExit
