/-
Registry-statement snapshot for the theorem library's tableau pipeline.

The pipeline's ADMISSION rule is that a valid formula with an extracted derivation is admitted
"unless it is a substitution instance of an entry already present". "Already present" means every
row of the live registry, hand-curated rows included -- not merely the entries this run has
admitted so far. The driver is a compiled executable and cannot walk the environment, so the
comparison set has to reach it as data. This probe is what produces that data.

It prints one row per line as `<declaration name>` TAB `<tag-encoded Formula>` --
`Formula.toJson`'s encoding, which `BimodalTools.JsonParse.pFormula` reads back -- the formula
being the row's statement instantiated at the canonical schema variables. The name is carried so
that a dropped candidate's ADMIT record can say which row subsumed it. That is exactly the
formula `assert_no_subsumed_entries`
compares, so the filter the pipeline applies and the invariant the build enforces range over the
same set, computed by the same function (`BimodalLib.rowStatement?`) -- with one deliberate
difference: the snapshot covers the HAND-CURATED rows only. Subsumption among the generated
entries is the pipeline's own second pass, over candidates it holds in memory, so it needs no
snapshot; and a snapshot that included the last run's entries would make a run's output depend
on its own previous output.

Run it through the pipeline's own entry point, which refreshes the snapshot before measuring:

```bash
bash scripts/theorem-library-pipeline.sh --all-fragments --atoms 2
```

or directly:

```bash
lake env lean specs/evidence/theorem-library-pipeline/registry-statements.lean
```

The output lands in `data/registry-statements.jsonl`, which is regenerated rather than tracked
(`data/` is gitignored), on the same footing as every other dataset under `data/`.

This file is an evidence probe, not part of the library, and it writes under `data/` rather than
anywhere tracked -- so it does not breach `BimodalLib/Diagnostics/Record.lean`'s rule that no
library command writes a tracked file as an elaboration side effect.
-/
-- The HAND-CURATED registration modules only, and deliberately NOT `BimodalLib` itself nor
-- `BimodalLib.Theorems.Enumerated.Base`. Two reasons, both load-bearing. The snapshot is the
-- comparison set for a pipeline run that is about to REGENERATE the enumerated entries, so
-- including the previous run's entries would make a run's output depend on its own last output.
-- And `BimodalLib.Theorems.Complete` is where `assert_no_subsumed_entries` runs, so importing
-- the root would make the snapshot unbuildable exactly when the invariant it feeds is red --
-- which is the one moment the snapshot is needed.
import BimodalLib.Registry.Complete
import BimodalLib.Subsumption
import BimodalLib.Theorems.Boolean.Base
import BimodalLib.Theorems.ModalBoolean.Base
import BimodalLib.Theorems.ModalTemporalBoolean.Base
import BimodalLib.Theorems.TemporalBoolean.Base
import BimodalLib.Theorems.TemporalBoolean.Dense
import BimodalLib.Theorems.TemporalBoolean.RTime
import BimodalLib.Theorems.TemporalBoolean.ZTime
import BimodalTools.DataExport

open Lean Elab Command Meta
open FormalSystem.Syntax
open BimodalLib

run_cmd liftTermElabM do
  let rows ← registryRows
  let mut out : Array String := #[]
  let mut skipped : Nat := 0
  for (nm, ci) in rows do
    match ← rowStatement? ci with
    | some f => out := out.push (toString nm ++ "\t" ++ f.toJson)
    | none => skipped := skipped + 1
  IO.FS.createDirAll "data"
  IO.FS.writeFile "data/registry-statements.jsonl"
    (String.intercalate "\n" out.toList ++ "\n")
  logInfo m!"registry-statements: wrote {out.size} statement(s) of {rows.size} row(s) to \
    data/registry-statements.jsonl ({skipped} row(s) did not reduce to a closed formula)"
