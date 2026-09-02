# Phase 4 handoff — task 518

**Done**: `FormalSystem/Metalogic/Bundle/LimitMCS.lean` — deleted
`import FormalSystem.Metalogic.Algebraic.FlowFrame` (`:8`) and the orphan
`fc_theorem_true_in_bundle_flow_model` together with its `/-! ## ... -/` section header, its two
now-dead `open` lines (`FormalSystem.Metalogic.Algebraic`, `FormalSystem.Semantics`), and its
docstring. 33 lines deleted, one file. The `Bundle <-> Algebraic` directory cycle is gone.

**Not edited, per plan Non-Goal**: `FormalSystem/Metalogic/README.md` — it already reads "exactly
two" directory cycles at `:70`; this deletion is what makes that true.

**Verification**: full `lake build` exit 0 (2515 jobs) via
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build`, detached.
`grep 'Algebraic.FlowFrame' LimitMCS.lean` returns nothing.

**Guard-invocation note**: the guard requires the lake subcommand *after* `--`; a first attempt
with an empty argument vector (`... --timeout 1800 --`) was refused at exit 77 without running a
build. Correct form is `... --timeout 1800 -- build`.

**Next**: Phase 5 — add two imports to `FormalSystem/Metalogic.lean` to flip C6.
