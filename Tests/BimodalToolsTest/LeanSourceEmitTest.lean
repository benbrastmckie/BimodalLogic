/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import BimodalTools.LeanSourceEmit

/-!
# Tests for the Lean-source emitter

The emitter's only real contract is that its output *elaborates* — a printer whose text does not
compile is useless to the ADMIT stage — so this file decides that contract two ways.

## The pasted mirror

The `Gen` namespace below is the emitter's output for the T axiom at the concrete atom `p`,
pasted in verbatim as real Lean source. The build therefore elaborates the emitted shape itself,
and `--wfail` is what makes that elaboration an assertion: a `sorry` anywhere raises
`declaration uses 'sorry'`, which is a warning, which is a failure. The `#guard`s after it tie
the paste to the printer line by line, so neither can drift without the other.

## The round trip

`runRoundTripTest` writes the emitted text of two trees — the T axiom, and a
`modus_ponens`-shaped tree over `prop_s` — to a temporary module and elaborates it with
`lake env lean`, then checks the output reports no `sorryAx`. It shells out, so it is an `IO`
probe rather than an elaboration-time guard; it is what covers the emitted `register_theorem`
line, which the paste above cannot carry because `BimodalToolsTest` does not import
`BimodalLib.Registry`.

## Axiom coverage

Coverage of the 20 `Axiom` constructors is asserted inside `BimodalTools/LeanSourceEmit.lean`
itself, because that is where a constructor added upstream must fail. It is re-checked here
against `allAxiomNames` directly.

## References

* `BimodalTools/LeanSourceEmit.lean` — the printers under test
* `FormalSystem/ProofSystem/Substitution.lean` — `DerivationTree.substNil`, which the emitted
  declaration's body closes over
-/

namespace BimodalToolsTest.LeanSourceEmitTest

open FormalSystem.Syntax
open FormalSystem.ProofSystem
open BimodalTools

/-! ## Fixtures -/

/-- The canonical first enumerated atom, as `AtomCanonicalization` produces it. -/
def pAtom : Atom := Atom.mk "p" none

/-- `p`, as a formula. -/
def pF : Formula := .atom pAtom

/-- `□p → p`: the statement the T axiom gives at the concrete atom `p`. -/
def tStmt : Formula := Formula.imp (Formula.box pF) pF

/-- A hand-built derivation of `□p → p`, standing for what proof extraction returns. -/
def concreteT : DerivationTree FrameClass.Base [] tStmt :=
  .axiom _ _ (.modal_t pF) (by decide)

/-- A `modus_ponens`-shaped tree: `prop_s` at `(□p → p)` and `⊥`, applied to `concreteT`, which
derives `⊥ → (□p → p)`. Two nested `axiom` nodes under one `modus_ponens`, so the recursive arms
of `derivationSource` are exercised and not only the leaf arm. -/
def mpTree : DerivationTree FrameClass.Base [] (Formula.imp Formula.bot tStmt) :=
  .modus_ponens _ tStmt (Formula.imp Formula.bot tStmt)
    (.axiom _ _ (.prop_s tStmt Formula.bot) (by decide))
    concreteT

/-! ## The printers

Atoms print through an explicit constructor call, never through notation, so the output is
independent of whatever atom notation the consuming module has in scope. -/

#guard atomSource pAtom == "(Atom.mk \"p\" none)"
#guard atomSource (Atom.mk "q" (some 3)) == "(Atom.mk \"q\" (some 3))"

#guard formulaSource pF == "(Formula.atom (Atom.mk \"p\" none))"
#guard formulaSource Formula.bot == "(Formula.bot)"
#guard formulaSource tStmt ==
  "(Formula.imp (Formula.box (Formula.atom (Atom.mk \"p\" none))) \
   (Formula.atom (Atom.mk \"p\" none)))"

#guard contextSource [] == "[]"
#guard contextSource [Formula.bot] == "[(Formula.bot)]"

#guard schemaSource 0 == "A"
#guard schemaSource 25 == "Z"
#guard schemaSource 26 == "(v 26)"

-- The generalized atoms print as the bound schema variables; an atom outside the list prints as
-- itself. That is the whole difference between the two formula faces.
#guard schemaFormulaSource [pAtom] tStmt == "(Formula.imp (Formula.box A) A)"
#guard schemaFormulaSource [] tStmt == formulaSource tStmt

#guard axiomSource (Axiom.modal_t pF) == "Axiom.modal_t (Formula.atom (Atom.mk \"p\" none))"
#guard axiomSource Axiom.serial_future == "Axiom.serial_future"
#guard axiomConstructorName (Axiom.modal_t pF) == "modal_t"
#guard axiomConstructorName (Axiom.linear_until pF pF pF pF) == "linear_until"

#guard derivationSource concreteT ==
  "(DerivationTree.axiom [] (Formula.imp (Formula.box (Formula.atom (Atom.mk \"p\" none))) \
   (Formula.atom (Atom.mk \"p\" none))) \
   (Axiom.modal_t (Formula.atom (Atom.mk \"p\" none))) (by decide))"

-- The recursive arms: one `modus_ponens` node carrying two `axiom` children, each printed by the
-- leaf arm, so a dropped recursive call shows up here as a missing child.
#guard ((derivationSource mpTree).splitOn "DerivationTree.axiom").length == 3
#guard ((derivationSource mpTree).splitOn "DerivationTree.modus_ponens").length == 2

/-! ## Axiom coverage -/

#guard axiomNamesMissing == ([] : List String)
#guard axiomNamesExtra == ([] : List String)
#guard axiomSampleNames.length == 20
#guard axiomSampleNames == allAxiomNames

/-! ## The pasted mirror

Everything in this namespace is `entrySource`'s own output, pasted verbatim. Its
`register_theorem` line is the one part left out, since this library does not import the
registry; `runRoundTripTest` covers it instead. -/

namespace Gen

/-- The derivation the tableau extracted for `(□p → p)`, over its own concrete atoms. Generated;
do not edit by hand. -/
private def modalTConcrete : DerivationTree FrameClass.Base []
    (Formula.imp (Formula.box (Formula.atom (Atom.mk "p" none))) (Formula.atom (Atom.mk "p"
    none))) :=
  (DerivationTree.axiom [] (Formula.imp (Formula.box (Formula.atom (Atom.mk "p" none)))
  (Formula.atom (Atom.mk "p" none))) (Axiom.modal_t (Formula.atom (Atom.mk "p" none)))
  (by decide))

/-- The substitution generalizing `modalTConcrete`'s atoms to schema variables. Generated; do not
edit by hand. -/
private def modalTSubst (A : Formula) : Atom → Formula :=
  fun q => if q = (Atom.mk "p" none) then A else Formula.atom q

/-- `(□A → A)` — admitted by the theorem-library pipeline at `Base`. Generated; do not edit by
hand. -/
def modalT (A : Formula) : DerivationTree FrameClass.Base []
    (Formula.imp (Formula.box A) A) := by
  have h := DerivationTree.substNil (modalTSubst A) modalTConcrete
  simpa [substF, modalTSubst] using h

end Gen

-- Informational: the pasted declaration's axiom profile. Sorry-freeness is gated by `--wfail`
-- rather than by this probe, since a `sorry` raises a warning and a warning is a failure.
#print axioms BimodalToolsTest.LeanSourceEmitTest.Gen.modalT

/-! ### Tying the paste to the printer

The emitted lines below are quoted one per `#guard` rather than as one byte-exact blob: a single
literal holding the whole entry would itself carry lines past the 100-character limit the
package's linter set enforces. Each guard names a line the paste above also carries. -/

/-- The emitted entry for `concreteT`, generalized at `p`, split into lines. -/
def modalTLines : List String :=
  (entrySource "BimodalToolsTest.LeanSourceEmitTest.Gen" "modalT" [pAtom] concreteT).splitOn "\n"

#guard modalTLines.contains "private def modalTConcrete : DerivationTree FrameClass.Base []"
#guard modalTLines.contains "private def modalTSubst (A : Formula) : Atom → Formula :="
#guard modalTLines.contains "  fun q => if q = (Atom.mk \"p\" none) then A else Formula.atom q"
#guard modalTLines.contains "def modalT (A : Formula) : DerivationTree FrameClass.Base []"
#guard modalTLines.contains "    (Formula.imp (Formula.box A) A) := by"
#guard modalTLines.contains "  have h := DerivationTree.substNil (modalTSubst A) modalTConcrete"
#guard modalTLines.contains "  simpa [substF, modalTSubst] using h"
#guard modalTLines.getLast? ==
  some "register_theorem BimodalToolsTest.LeanSourceEmitTest.Gen.modalT"

-- At arity 0 the signature binds nothing and the substitution is the identity chain alone.
#guard (entrySource "Gen" "efq" [] (concreteT)).splitOn "\n" |>.contains
  "private def efqSubst : Atom → Formula :="

-- No emitted line exceeds the limit, on either fixture. The wrapping is the reason the generated
-- module can land under `BimodalLib/` at all.
#guard modalTLines.all (·.length ≤ 100)
#guard ((entrySource "Gen" "mpSample" [pAtom] mpTree).splitOn "\n").all (·.length ≤ 100)

/-! ## The round trip through `lake env lean` -/

/-- The preamble a generated module needs: the registry, the substitution layer, and the two
namespaces `entrySource`'s output leaves unqualified. -/
def generatedPreamble (ns : String) : String := String.intercalate "\n"
  [ "import BimodalLib.Registry"
  , "import FormalSystem.ProofSystem.Substitution"
  , ""
  , "open FormalSystem.Syntax"
  , "open FormalSystem.ProofSystem"
  , ""
  , "namespace " ++ ns
  , ""
  ]

/-- The namespace the round-trip module declares. -/
def roundTripNamespace : String := "LeanSourceEmitRoundTrip"

/-- The two emitted entries, wrapped in the preamble, as one standalone module. -/
def generatedModule : String :=
  let ns := roundTripNamespace
  generatedPreamble ns
    ++ entrySource ns "modalT" [pAtom] concreteT
    ++ "\n\n"
    ++ entrySource ns "mpSample" [pAtom] mpTree
    ++ "\n\n#print axioms " ++ ns ++ ".modalT"
    ++ "\n#print axioms " ++ ns ++ ".mpSample"
    ++ "\n\nend " ++ ns ++ "\n"

/--
Write the emitted module to a temporary file and elaborate it with `lake env lean`.

Returns `true` when the elaboration exits 0 and reports no `sorryAx` for either generalized
declaration. Shelling out means this is not an elaboration-time guard. Run it from a scratch
file that imports this module:

```lean
#eval BimodalToolsTest.LeanSourceEmitTest.runRoundTripTest
```
-/
def runRoundTripTest : IO Bool := do
  let tmp := (← IO.getEnv "TMPDIR").getD "/tmp"
  let path := tmp ++ "/leanSourceEmitRoundTrip.lean"
  IO.FS.writeFile path generatedModule
  let out ← IO.Process.output { cmd := "lake", args := #["env", "lean", path] }
  IO.println out.stdout
  unless out.stderr.isEmpty do IO.println out.stderr
  let noSorry := (out.stdout.splitOn "sorryAx").length == 1
  let printedBoth := (out.stdout.splitOn "depends on axioms").length == 3
  let ok := out.exitCode == 0 && noSorry && printedBoth
  if ok then
    IO.println "PASS round trip: the emitted module elaborates and reports no sorryAx"
  else
    IO.println s!"FAIL round trip: exit {out.exitCode}, noSorry={noSorry}, both={printedBoth}"
  return ok

end BimodalToolsTest.LeanSourceEmitTest
