# Phase 6 handoff — task 518

Landed as one green commit (`Commit Mode: atomic-batch`), pre-declared file set honored exactly:
`FormalSystem/Automation/NormalizationAttr.lean` (new), `FormalSystem/Automation/Normalization.lean`,
`Tests/BimodalTest/Automation/NormalizationTest.lean`. No intermediate red state was committed.

**Done**:
- New `NormalizationAttr.lean`: header, `import Lean`, `register_simp_attr formula_unfold`,
  `register_simp_attr formula_fold`, plus docstrings recording why the module must be separate.
- `Normalization.lean`: `import FormalSystem.Automation.NormalizationAttr` added; 21 `@[simp]`
  -> `@[formula_unfold]`, 10 `@[simp]` -> `@[formula_fold]`; `modalNorm`/`modalNormAt`/
  `modalNormAll` collapsed to `simp only [formula_unfold]`; three stale docstring sites corrected.
- `NormalizationTest.lean`: `SimpLoopRegression` section with the plain-`simp` regression plus one
  example per simp set.

**Held to plan**: `normalizeFormula_id`'s `@[simp]` at `:1218` untouched (32nd tag, not in the
loop). `modalFold` kept on the `←`-form — six of its entries have no `_fold` counterpart, so
`simp only [formula_fold]` would be a behavioural change. `propNorm`/`modalOpNorm`/`temporalNorm`
byte-identical: each is a proper sub-list, so `[formula_unfold]` would over-normalize.

**Verification**: `lake build` exit 0 (2520 jobs); `lake build BimodalTest` exit 0 (2571 jobs,
`BimodalTest.Automation.NormalizationTest` built in 43s). Standalone probe on
`example (a : Formula) : a.neg = a.neg := by simp` — exit 0 where research measured `maximum
recursion depth has been reached` at `HEAD`. Both `simp only [formula_unfold]` and
`simp only [formula_fold]` resolve across the module boundary.

**No fallback needed**: the two-module `register_simp_attr` layout compiled first try, so the
plan's Phase 6 contingency (plain tag removal with no replacement attribute) was not used.

**Next**: Phase 7 — `AesopRules.lean` rule set. Probe `declare_aesop_rule_sets` first.
Pre-established fact for the "no consumer regresses" check: the only live `aesop` tactic call
outside `AesopRules.lean`'s own docstring is `ProofSystem/Derivable.lean:185`, and that file does
not import `AesopRules`, so no call site currently depends on these rules being in the default set.
