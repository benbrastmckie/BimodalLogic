/-
Phase 5.1 environment classifier.

The Mathlib casing branch is a function of a declaration's RESULT TYPE, which cannot be
inferred from its name. This walks the real environment and reports, for each
linter-flagged declaration, which of four categories it falls in:

  proof_valued_def     the declaration's type is itself a `Prop` -- it PROVES something, so it
                       should be a `theorem` and leaves `defsWithUnderscore`'s scope entirely
  prop_valued_definition
                       after telescoping the binders, the result type IS `Prop` -- the
                       declaration DEFINES a predicate (Mathlib: `Function.Injective`,
                       `IsCompact`) -> UpperCamelCase.  NOT convertible to `theorem`:
                       `α → Prop` has type `Type`, not `Prop`.
  sort_or_type         result is some other `Sort`/`Type` -> UpperCamelCase
  data                 anything else, including all `DerivationTree`-valued -> lowerCamelCase

Run:  lake env lean specs/402_.../tools/Classify.lean
Reads  specs/402_.../target-names/flagged-names.txt
Writes specs/402_.../target-names/categories.tsv
-/
import FormalSystem

open Lean Meta Elab

def dir : String := "specs/402_systematic_mathlib_naming_upgrade/target-names/"

unsafe def classify (n : Name) : MetaM String := do
  let env ← getEnv
  match env.find? n with
  | none => return "MISSING"
  | some ci => do
    let ty := ci.type
    -- Is the declaration itself a proof?  (its type is a Prop)
    if ← Meta.isProp ty then return "proof_valued_def"
    forallTelescopeReducing ty fun _ body => do
      if body.isProp then return "prop_valued_definition"
      if body.isSort then return "sort_or_type"
      -- a result type that is itself a Sort (e.g. `Type`), reached via reduction
      let bty ← Meta.inferType body
      if bty.isSort && !bty.isProp then
        if body.isSort then return "sort_or_type" else return "data"
      return "data"

unsafe def kindOf (n : Name) : MetaM String := do
  let env ← getEnv
  match env.find? n with
  | some (.thmInfo _) => return "theorem"
  | some (.defnInfo _) => return "def"
  | some (.axiomInfo _) => return "axiom"
  | some (.opaqueInfo _) => return "opaque"
  | some (.ctorInfo _) => return "ctor"
  | some (.inductInfo _) => return "inductive"
  | some _ => return "other"
  | none => return "missing"

unsafe def run : MetaM Unit := do
  let raw ← IO.FS.readFile (dir ++ "flagged-names.txt")
  let names := (raw.splitOn "\n").filter (fun s => !s.trim.isEmpty)
  let mut out := "name\tcategory\tkind\tmodule\n"
  let env ← getEnv
  for s in names do
    let n := s.trim.toName
    let cat ← classify n
    let k ← kindOf n
    let m := match env.getModuleFor? n with
             | some mo => mo.toString
             | none => "?"
    out := out ++ s!"{n}\t{cat}\t{k}\t{m}\n"
  IO.FS.writeFile (dir ++ "categories.tsv") out
  IO.println s!"wrote {names.length} rows to {dir}categories.tsv"

unsafe def main : IO Unit := do
  let env ← importModules #[{ module := `FormalSystem }] {}
  let _ ← (run.run' {} {}).toIO { fileName := "<classify>", fileMap := default } { env := env }
  pure ()

#eval main
