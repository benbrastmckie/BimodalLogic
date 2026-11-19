# Branch 1 closeout

Scope: P0–P2 on `feat/proof-mode-rewriting`. P3–P5 remain separate implementation branches.
Initial grades are preserved: Codex **84.75/100**, Opus **68.5/100**. They describe the first
reviewed draft, not a certificate of the corrected implementation. Opus's closeout gives GO
for the source, conditioned on compilation and a `--wfail` library build; both passed.

## Required findings

| Finding | Resolution |
| --- | --- |
| F1: guessed data/premises | Check the replacement before premise resolution. Only ground Prop hypotheses may resolve from locals; unknown data is rejected. Native proof premises can be explicit opaque obligations. |
| F2: unreadable facts/demands | Reconstruct the requested AST, verify it against the kernel, and give facts the expected type. Syntactic `guard_target`/`guard_hyp` fixtures pin the presentation. |
| F3: unchecked simp assignment | Verify every reconstructed goal and derived fact before assignment. |
| F4: scope-based occurrence choice | Count formula matches before discharge. Require an explicit path when multiple matches exist, even if only one is accessible. |
| F5: rule-reader assignments | Probe rigidly with restoration; reject unknown heads, fresh residual holes and assignments to existing source metas. Compare iff directions read-only. Registration uses a fresh metavariable depth. |
| F6: reversed orientation | Use exclusive-or against the registered orientation; a compact fixture exercises the reversed box-conjunction seed. |
| F7: hidden wrapper expansion | Enumerate only registered syntactic views; other wrappers require explicit unfolding. |
| F8: missing P0 Since fold | `baseSinceFoldPrototype` in the shared extension module proves the Base converse by closed reflection. The pointed soundness prototype also compiles. |
| F9: unrun adapters | Compile-time validators check all positional builders, conditional Next/Previous variants, finite conversions, closed scope lifts and both iff projections in TM/Plus. A small product fixture exercises actual use. |
| F10: trace detail | Traces include rule, path, demand, frame, route, output, skips and counters. Parameter-solving subroutes are not individually traced. |

The closeout's additional N1/N5 implicit-hole concern is fixed by elaborating once and
collecting implicit holes from the proof expression as well as explicit telescope parameters.
Every remaining certificate hole must have an explicit goal. A regression fixture exposes an
implicit Dense gate, and both unrequested rewrite/simp attempts fail atomically.

N2 iff recognition now rejects comparisons that assign source metavariables. N3 exposure is
limited to genuinely unsupported nonempty scope demands; supported-builder, frame and context
errors propagate. Discarded rule premises are removed only from this invocation's synthetic
elaboration jobs. The scope fixture deliberately has an unused implicit False premise: only
the new, valid boxed premise is requested. N4 adapter validation was extended as listed above.
Unused occurrence-selection arguments were removed; the repeated-state check remains defensive.

Codex's final source review finds no remaining branch-1 blocker. Neither review claims the
future temporal/semantic tactics or the complete P0–P5 goal are finished.

## Verification evidence

- Full `lake build FormalSystem --wfail`: passed, reusing the existing dependency cache.
- Original and extension proof-mode modules with `--wfail`: passed.
- `lake exe runLinter FormalSystem`: passed after fixing five missing-docstring findings;
  no linter baseline or suppression was added.
- The full module-invariant audit passed every group except those five C16 docstrings. C16
  was then rerun explicitly and passed. The final `--no-build` structural audit reports
  `ALL CHECKS PASSED` on the refreshed tree; README lint and book count generation also passed.
- Axiom inspection: the generic composition/equality-cast kernel has no axioms; representative
  native rules use only existing `propext`, `Classical.choice` and `Quot.sound` dependencies.
- Representative simp traces: the nested modal reduction used 1 reduction, 7 matches and
  9 node visits; the Boolean/eventuality example used 2 reductions, 9 matches and 11 visits.
  These are local baselines, not wall-clock or asymptotic promises.

All source inventory, root/count and book synchronization owners are refreshed before the
branch checkpoint. Checks for later branches remain required; cached success is not evidence
for code that has not yet been implemented.

Last updated: 2026-11-19.
