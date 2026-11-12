/-
A/B harness, OLD arm: the same two kernel obligations against a locally mirrored per-vertex
clause shape.

This file is an evidence probe, not part of the library, and is deliberately NOT wired into
`scripts/check-evidence-probes.sh` -- see `ab-new.lean`'s header for why.

WHAT IS MIRRORED, AND FROM WHERE. The definitions below reconstruct the clause shape that
`FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/LiveFix.lean` had before the table was
introduced, built out of that module's own surviving per-vertex vocabulary:

  * `fwdLiveStepOld` / `bwdLiveStepOld` mirror `PlusSlicedCertificate.fwdLiveStep` /
    `bwdLiveStep`, with the table lookup `untlLiveAtTab (untlTable X) v ψ` /
    `snceLiveAtTab (snceTable X) v ψ` replaced by the direct per-vertex clause
    `untlLiveAt X v ψ` / `snceLiveAt X v ψ`. Those two clause definitions are still live in the
    library and unchanged, so the mirror is the pre-hoist clause rather than a reconstruction of
    it: `untlLiveAtTab_eq` / `snceLiveAtTab_eq` state exactly that the two agree.
  * `fwdLiveTOld` / `bwdLiveTOld` mirror `fwdLiveT` / `bwdLiveT` (`Nu.gfp'` over `G.verts`).
  * `liveTOld` mirrors `liveT` (the intersection), and `liveAtOld` mirrors `Stable.lean`'s
    `liveAt`.

Nothing else differs between the arms. Both files import the same built library, set the same
elaboration options (including `profiler true`, which is what separates the two sites inside one
file -- see `ab-new.lean`'s header), and state the same two closed obligations, so the comparison carries no
rebuild confound: the only moving part is which clause shape the kernel evaluates.

Mirrored at commit e2c2662e0461024619ba2c628cc0610932f9421f, toolchain
leanprover/lean4:v4.33.0-rc1. Raw timings, medians and ratios: see README.md beside this file.
-/

import FormalSystem.Metalogic.Decidability.PlusSlicedCertificate

open FormalSystem.PlusLanguage
open FormalSystem.Metalogic.Decidability
open FormalSystem.Metalogic.Decidability.PlusSlicedCertificate
open FormalSystem.Metalogic.Decidability.WitnessFamily

namespace FormalSystem.Metalogic.Decidability.Evidence.Phase5HoistAB.Old

variable {Γ Del : PlusContext}

/-- The pre-hoist forward contraction: the inner fixpoint is evaluated inside the filter, once
per vertex of `X`, through `untlLiveAt` directly. -/
def fwdLiveStepOld (G : PlusSlicedCertificate Γ Del) (X : Finset G.TPos) : Finset G.TPos :=
  X.filter (fun v => (∃ w ∈ G.succT v, w ∈ X) ∧
    ∀ ψ ∈ plusClosureOf (Γ ++ Del), G.untlLiveAt X v ψ = true)

/-- The pre-hoist backward contraction, the mirror. -/
def bwdLiveStepOld (G : PlusSlicedCertificate Γ Del) (X : Finset G.TPos) : Finset G.TPos :=
  X.filter (fun v => (∃ w ∈ G.predT v, w ∈ X) ∧
    ∀ ψ ∈ plusClosureOf (Γ ++ Del), G.snceLiveAt X v ψ = true)

/-- The forward-live timed positions under the per-vertex contraction. -/
def fwdLiveTOld (G : PlusSlicedCertificate Γ Del) : Finset G.TPos :=
  Nu.gfp' G.verts (fwdLiveStepOld G)

/-- The backward-live timed positions under the per-vertex contraction. -/
def bwdLiveTOld (G : PlusSlicedCertificate Γ Del) : Finset G.TPos :=
  Nu.gfp' G.verts (bwdLiveStepOld G)

/-- Both directions at once, mirroring `liveT`. -/
def liveTOld (G : PlusSlicedCertificate Γ Del) : Finset G.TPos :=
  fwdLiveTOld G ∩ bwdLiveTOld G

/-- The live positions at a time, mirroring `Stable.lean`'s `liveAt`. -/
def liveAtOld (G : PlusSlicedCertificate Γ Del) (s : ℤ) : Finset G.Pos :=
  (G.posAt s).filter (fun p => (p, s) ∈ liveTOld G)

set_option maxRecDepth 4000000 in
set_option maxHeartbeats 0 in
set_option profiler true in
/-- Site 1 (hard certificate): the backward liveness fixpoint at `certA`, under the per-vertex
clause shape. Same stated cardinality as `ab-new.lean`'s site 1. -/
example : (bwdLiveTOld TotalEdge.certA).card = 16 := by decide

set_option maxRecDepth 4000000 in
set_option maxHeartbeats 0 in
set_option profiler true in
/-- Site 2 (small embedded witness): the `liveAt` cardinality at the embedded lasso certificate,
under the per-vertex clause shape. Same stated cardinality as `ab-new.lean`'s site 2. -/
example : (liveAtOld (Embedded.liveFamily.sliced (-1)) (-1)).card = 1 := by decide

end FormalSystem.Metalogic.Decidability.Evidence.Phase5HoistAB.Old
