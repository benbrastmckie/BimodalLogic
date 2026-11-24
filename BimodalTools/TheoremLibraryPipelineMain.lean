/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import BimodalTools.TheoremPipeline

/-!
# `theorem_library_pipeline` — the executable root

One command runs the five stages of `records/theorem-library.md` end to end and writes three
outputs: the stage records, the certified refutations in the form the countermodels record will
read, and the generated theorem module.

The module name is forced: check `C25N` of `scripts/check-module-invariants.sh` requires every
`lean_exe` root to be named `PascalCase(target)Main`, and the target is
`theorem_library_pipeline`.

## The atom pool is required

`--atoms` has no default and omitting it is a usage error. The measured yield is superexponential
in pool size — `Boolean` 14 and `ModalBoolean` 133 at a two-atom pool, against 902 and 751 in a
dataset tabulation at a wider one — so a yield figure without its pool is not reportable, and
making the pool unspecifiable is the only way to keep an unreportable figure from being emitted.

## `--frame-class` defaults to `Base` alone

A `Dense` gate pass over a modal fragment reached 2.8 GB RSS at 100% CPU under measurement and is
a plausible OOM rather than merely a slow run. A caller asking for `Dense` is asking for the
expensive path and says so explicitly. `--deadline-s` and `--checkpoint` are requirements of the
expensive path rather than conveniences: the first bounds the run, the second makes an interrupted
one resumable.

## `--json` and determinism

Two `--json` runs at the same bound and the same atom pool are byte-identical. `--json` zeroes
`decision_time_ms`, which is the only field of the five reserved payloads that is not a function
of the commit and the toolchain. The verdict counts were measured to reproduce exactly across two
runs while the timings did not, so zeroing the timing field is the whole of what determinism
requires here.

## References

* `BimodalTools/TheoremPipeline.lean` — the driver this root is a CLI for
* `scripts/theorem-library-pipeline.sh` — the one named entry point, which calls this target
-/

open Lean (Json)
open FormalSystem.Syntax
open FormalSystem.ProofSystem (FrameClass)
open BimodalTools.TheoremPipeline
open BimodalTools.CertificateImport (RawCertificate parseCertificate)

namespace BimodalTools.TheoremLibraryPipelineMain

/-- The flag set, printed by `--help`. -/
def usage : String := String.intercalate "\n"
  [ "theorem_library_pipeline — the theorem library's tableau pipeline"
  , ""
  , "Usage:"
  , "  lake exe theorem_library_pipeline --fragment F --max-complexity N --atoms K [options]"
  , ""
  , "Required:"
  , "  --atoms K            the atom pool size; required, and recorded in every record"
  , "  and EITHER --all-fragments, OR both of:"
  , "  --fragment F         Boolean | ModalBoolean | TemporalBoolean | ModalTemporalBoolean"
  , "  --max-complexity N   the bound, in pattern-aware operator layers, not primitive nodes"
  , ""
  , "  --all-fragments      run all four fragments in ONE command, each at its own ruled bound"
  , "                       (Boolean and ModalBoolean at 5, TemporalBoolean and"
  , "                       ModalTemporalBoolean at 4). ADMIT runs once over every fragment's"
  , "                       candidates together, so subsumption is global; statement serials"
  , "                       continue across fragments; and --deadline-s is divided evenly, so a"
  , "                       budget that runs out still covers every fragment."
  , ""
  , "Options:"
  , "  --frame-class C      repeatable; Base | Dense | ZTime | RTime (default: Base alone)"
  , "  --out-module PATH    write the generated theorem module here"
  , "  --out-countermodels PATH  write the certified refutations here (JSONL)"
  , "  --out-records PATH   write the five stages' records here (JSONL)"
  , "  --certificates PATH  witness-family certificates (JSONL), for the ZTime route"
  , "  --registry-statements PATH  the registry snapshot ADMIT compares candidates against,"
  , "                       one `<decl>TAB<tag-encoded formula>` per line, as"
  , "                       specs/evidence/theorem-library-pipeline/registry-statements.lean"
  , "                       emits it. WITHOUT it, ADMIT compares candidates only against each"
  , "                       other and will emit entries that duplicate hand-curated registry"
  , "                       laws, which assert_no_subsumed_entries then fails the build on."
  , "  --checkpoint PATH    rewrite the index reached after each formula, so a run resumes"
  , "  --deadline-s N       whole-run wall-clock budget in seconds (0 = none)"
  , "  --timeout-ms N       per-formula wall-clock budget (default 30000)"
  , "  --namespace NS       the generated module's namespace"
  , "  --commit SHA         the commit stamped into every record's head"
  , "  --json               zero the one volatile timing field, for a byte-stable record"
  , "  --help               print this and exit 0"
  , ""
  , "Notes:"
  , "  The theorem half always runs at Base: proof extraction is Base-only by construction, so"
  , "  --frame-class moves the countermodel half alone. At ZTime the eight gates are not"
  , "  evaluated at all — regionLabel and temporalWitness are false there on every formula — and"
  , "  the only route is a supplied witness-family certificate through --certificates."
  ]

/-- The parsed command line, before validation. -/
structure Args where
  /-- `--fragment`. -/
  fragment : Option String := none
  /-- `--all-fragments`: run all four at their own ruled bounds, in one command. -/
  allFragments : Bool := false
  /-- `--max-complexity`. -/
  maxComplexity : Option Nat := none
  /-- `--atoms`. -/
  atoms : Option Nat := none
  /-- `--frame-class`, repeatable. -/
  frameClasses : List String := []
  /-- `--out-module`. -/
  outModule : Option String := none
  /-- `--out-countermodels`. -/
  outCountermodels : Option String := none
  /-- `--out-records`. -/
  outRecords : Option String := none
  /-- `--certificates`. -/
  certificates : Option String := none
  /-- `--registry-statements`. -/
  registryStatements : Option String := none
  /-- `--checkpoint`. -/
  checkpoint : Option String := none
  /-- `--deadline-s`. -/
  deadlineS : Nat := 0
  /-- `--timeout-ms`. -/
  timeoutMs : Nat := 30000
  /-- `--namespace`. -/
  moduleNamespace : String := "BimodalLib.Theorems.Enumerated"
  /-- `--commit`. -/
  commit : String := "unstamped"
  /-- `--json`. -/
  json : Bool := false
  /-- `--help`. -/
  help : Bool := false

/-- Parse the command line. An unknown flag is an error rather than a silent no-op. -/
def parseArgs : List String → Except String Args
  | [] => .ok {}
  | "--help" :: _ => .ok { help := true }
  | "--json" :: rest => (parseArgs rest).map fun a => { a with json := true }
  | "--all-fragments" :: rest => (parseArgs rest).map fun a => { a with allFragments := true }
  | "--fragment" :: v :: rest => (parseArgs rest).map fun a => { a with fragment := some v }
  | "--max-complexity" :: v :: rest => do
      let n ← v.toNat?.elim (.error s!"--max-complexity expects a number, got {v}") .ok
      (parseArgs rest).map fun a => { a with maxComplexity := some n }
  | "--atoms" :: v :: rest => do
      let n ← v.toNat?.elim (.error s!"--atoms expects a number, got {v}") .ok
      (parseArgs rest).map fun a => { a with atoms := some n }
  | "--frame-class" :: v :: rest =>
      (parseArgs rest).map fun a => { a with frameClasses := v :: a.frameClasses }
  | "--out-module" :: v :: rest => (parseArgs rest).map fun a => { a with outModule := some v }
  | "--out-countermodels" :: v :: rest =>
      (parseArgs rest).map fun a => { a with outCountermodels := some v }
  | "--out-records" :: v :: rest => (parseArgs rest).map fun a => { a with outRecords := some v }
  | "--certificates" :: v :: rest =>
      (parseArgs rest).map fun a => { a with certificates := some v }
  | "--registry-statements" :: v :: rest =>
      (parseArgs rest).map fun a => { a with registryStatements := some v }
  | "--checkpoint" :: v :: rest => (parseArgs rest).map fun a => { a with checkpoint := some v }
  | "--deadline-s" :: v :: rest => do
      let n ← v.toNat?.elim (.error s!"--deadline-s expects a number, got {v}") .ok
      (parseArgs rest).map fun a => { a with deadlineS := n }
  | "--timeout-ms" :: v :: rest => do
      let n ← v.toNat?.elim (.error s!"--timeout-ms expects a number, got {v}") .ok
      (parseArgs rest).map fun a => { a with timeoutMs := n }
  | "--namespace" :: v :: rest =>
      (parseArgs rest).map fun a => { a with moduleNamespace := v }
  | "--commit" :: v :: rest => (parseArgs rest).map fun a => { a with commit := v }
  | flag :: _ => .error s!"unknown or incomplete flag: {flag}"

/-- The atom pool of a given size, from the enumerator's own default pool. -/
def atomPool (k : Nat) : Except String (List Atom) :=
  if k == 0 then .error "--atoms must be at least 1"
  else if k > BimodalTools.defaultAtomPool.length then
    .error s!"--atoms at most {BimodalTools.defaultAtomPool.length}"
  else .ok (BimodalTools.defaultAtomPool.take k)

/--
Turn parsed arguments into a `Config`, or report the first usage error.

Every required flag is checked here rather than defaulted, which is the point: `--atoms` has no
default because a yield figure without its pool is not reportable.
-/
def configOf (args : Args) (command : String) (certs : List RawCertificate)
    (registry : List (String × Formula)) : Except String Config := do
  -- Under `--all-fragments` the fragment and the bound come from `ruledBound`, so the two flags
  -- are not required; the placeholders here are replaced per fragment by `runAll`.
  let frag : BimodalLib.Fragment ← match args.allFragments, args.fragment with
    | true, _ => pure BimodalLib.Fragment.Boolean
    | false, some name =>
        match fragmentOfName? name with
        | some f => pure f
        | none => Except.error s!"--fragment expects a fragment name, got {name}"
    | false, none => Except.error "--fragment is required (or pass --all-fragments)"
  let maxC : Nat ← match args.allFragments, args.maxComplexity with
    | true, _ => pure (BimodalTools.TheoremPipeline.ruledBound frag)
    | false, some n => pure n
    | false, none => Except.error "--max-complexity is required (or pass --all-fragments)"
  let k ← args.atoms.elim
    (.error "--atoms is required: a yield figure without its atom pool is not reportable") .ok
  let atoms ← atomPool k
  -- `parseArgs` prepends while recursing into the TAIL, so `frameClasses` is already in
  -- command-line order; reversing it here would misreport the order in every record.
  let fcs ← args.frameClasses.foldlM
    (fun acc name => match fcOfName? name with
      | none => .error s!"--frame-class expects a frame class name, got {name}"
      | some fc => .ok (acc ++ [fc])) ([] : List FrameClass)
  return { fragment := frag
           maxComplexity := maxC
           atoms := atoms
           frameClasses := if fcs.isEmpty then [FrameClass.Base] else fcs
           perFormulaTimeoutMs := args.timeoutMs
           deadlineS := args.deadlineS
           checkpoint := args.checkpoint.map System.FilePath.mk
           certificates := certs
           registryStatements := registry
           command := command
           commit := args.commit
           zeroTimings := args.json
           moduleNamespace := args.moduleNamespace }

/-- Read witness-family certificates from a JSONL file, one per non-blank line. -/
def loadCertificates (path : String) : IO (List RawCertificate) := do
  let text ← IO.FS.readFile path
  let mut out : List RawCertificate := []
  for line in text.splitOn "\n" do
    let t := line.trimAscii.toString
    if t.isEmpty then continue
    match parseCertificate t with
    | .ok raw => out := out ++ [raw]
    | .error e => throw (IO.userError s!"{path}: {e}")
  return out

/--
Read the registry snapshot: one `<declaration name>` TAB `<tag-encoded formula>` per non-blank
line, as `specs/evidence/theorem-library-pipeline/registry-statements.lean` emits it. The formula
is parsed by the same `pFormula` the tableau bridge uses, so the encoding has one reader.
-/
def loadRegistryStatements (path : String) : IO (List (String × Formula)) := do
  let text ← IO.FS.readFile path
  let mut out : List (String × Formula) := []
  for line in text.splitOn "\n" do
    let t := line.trimAscii.toString
    if t.isEmpty then continue
    match t.splitOn "\t" with
    | [name, json] =>
        match BimodalTools.JsonParse.pFormula (BimodalTools.JsonParse.mkPState json) with
        | .ok (f, _) => out := out ++ [(name, f)]
        | .error e => throw (IO.userError s!"{path}: {name}: {e}")
    | _ => throw (IO.userError s!"{path}: expected '<decl>TAB<json>', got: {t}")
  return out

/-- The run summary, printed to stdout and mirrored into the sidecar by the entry-point script. -/
def summaryJson (cfg : Config) (o : Outcome) (allFragmentsRun : Bool) : Json :=
  Json.mkObj
    [ ("fragment", Json.str cfg.fragment.name)
    , ("all_fragments", Json.bool allFragmentsRun)
    , ("max_complexity", Json.num (cfg.maxComplexity : Int))
    , ("atom_pool", Json.num (cfg.atoms.length : Int))
    , ("frame_classes", Json.arr ((cfg.frameClasses.map (fun fc => Json.str (fcName fc)))).toArray)
    , ("command", Json.str cfg.command)
    , ("commit", Json.str cfg.commit)
    , ("decided", Json.num (o.decidedCount : Int))
    , ("verdicts", Json.mkObj (o.verdictSplit.map (fun p => (p.1, Json.num (p.2 : Int)))))
    , ("admitted", Json.num (o.admitted.length : Int))
    , ("subsumed", Json.num (o.subsumed.length : Int))
    , ("conjectures", Json.num (o.conjectureCount : Int))
    , ("refutations", Json.num (o.refutations.length : Int))
    , ("records", Json.num (o.records.length : Int)) ]

/-- Write a list of JSON objects as JSONL. -/
def writeJsonObjects (path : String) (items : List Json) : IO Unit :=
  IO.FS.writeFile path (String.intercalate "\n" (items.map Json.compress) ++ "\n")

end BimodalTools.TheoremLibraryPipelineMain

open BimodalTools.TheoremLibraryPipelineMain in
/-- The executable entry point. -/
def main (argv : List String) : IO UInt32 := do
  match parseArgs argv with
  | .error e =>
      IO.eprintln s!"theorem_library_pipeline: {e}"
      IO.eprintln usage
      return 2
  | .ok args =>
    if args.help then
      IO.println usage
      return 0
    let command := "lake exe theorem_library_pipeline " ++ " ".intercalate argv
    let certs ← match args.certificates with
      | none => pure []
      | some path => loadCertificates path
    let registry ← match args.registryStatements with
      | none => pure []
      | some path => loadRegistryStatements path
    match configOf args command certs registry with
    | .error e =>
        IO.eprintln s!"theorem_library_pipeline: {e}"
        IO.eprintln usage
        return 2
    | .ok cfg =>
      let o ← if args.allFragments then BimodalTools.TheoremPipeline.runAll cfg
              else BimodalTools.TheoremPipeline.run cfg
      match args.outRecords with
      | none => pure ()
      | some path => writeJsonObjects path o.records
      match args.outCountermodels with
      | none => pure ()
      | some path =>
          writeJsonObjects path (o.refutations.map Refutation.toJson)
      match args.outModule with
      | none => pure ()
      | some path => IO.FS.writeFile path (moduleSource cfg o.admitted)
      IO.println (summaryJson cfg o args.allFragments).compress
      return 0
