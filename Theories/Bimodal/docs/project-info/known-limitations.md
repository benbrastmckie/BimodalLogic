# Bimodal Known Limitations

Current limitations of the Bimodal TM logic MVP and available workarounds.

## MVP Scope

This is a **Minimum Viable Product** release with intentional scope limitations.

## Limitation 1: General Base-Frame Completeness Has Residual Proof Debt

### Description

`completeness_dense` and `completeness_discrete` (`BXCanonical/Completeness.lean`) are fully
proven and sorryAx-free. The general Base-frame `completeness` theorem (`BXCanonical/Completeness.lean:187`)
retains one residual `sorryAx` dependency through a deprecated dead-code pipeline
(`WeakCanonical.countermodel_discrete`).

### Impact

- The dense and discrete frame-class completeness results can be relied upon directly.
- The general Base-frame case cannot yet be treated as a fully verified theorem due to the
  residual dependency described above.

### Workaround

For dense or discrete frame reasoning, appeal to `completeness_dense` / `completeness_discrete`
directly. For the general Base-frame case, construct proofs syntactically:

```lean
-- Instead of appealing to the general Base-frame completeness theorem
example (p : Formula) : ⊢ p.box.imp p := modal_t p
```

### Resolution

Open proof-debt item confined to the deprecated `WeakCanonical.countermodel_discrete` dead-code
pipeline that the general Base-frame `completeness` theorem still depends on.

## Limitation 2: ProofSearch Has Build Issues (Resolved)

### Description

`Automation/ProofSearch.lean` no longer exists as a single file; it is now
`Automation/ProofSearch/Core.lean` and `Automation/ProofSearch/Strategies.lean`, both compiled by
the green full `lake build` (1877 jobs, 0 errors). The historical build failure described here no
longer reproduces.

### Impact

None currently observed. `bounded_search` and related automation build cleanly as part of the
main build.

### Workaround

Not needed; the modules build without error.

### Resolution

Resolved by the reorganization into `Automation/ProofSearch/Core.lean` and
`Automation/ProofSearch/Strategies.lean`.

## Limitation 3: Example Files Have Pedagogical Sorries (Resolved)

### Description

`Theories/Bimodal/Examples/` contains exactly two files, `BimodalProofs.lean` and
`TemporalStructures.lean`, both sorry-free (0 total, as of the current build).

### Impact

None currently observed. Both example files fully compile.

### Workaround

Not needed.

### Resolution

Resolved — both example files are sorry-free per the `Examples.lean` module docstring and the
current build.

## Limitation 4: Test Suite Has Pending Tests (Resolved)

### Description

`Metalogic/CompletenessTest.lean` does not exist anywhere in the tree.
`Tests/BimodalTest/Theorems/PerpetuityTest.lean` and `.../PropositionalTest.lean` contain zero
`sorry` uses.

### Impact

None currently observed. The tests that exist verify their expected behavior.

### Workaround

Not needed.

### Resolution

Resolved — no outstanding `sorry` placeholders found in `PerpetuityTest.lean` or
`PropositionalTest.lean`; `CompletenessTest.lean` no longer exists in the tree.

## Limitation 5: Modal S4 Theorems Partial (Resolved)

### Description

`Theorems/ModalS4.lean` is sorry-free; all four of its theorems, including
`s4_diamond_box_conj`, are fully proven.

### Impact

None currently observed. All Modal S4 theorems are available for use in downstream proofs.

### Workaround

Not needed.

### Resolution

Resolved — all Modal S4 theorems, including `s4_diamond_box_conj`, are fully proven and
sorry-free.

## Limitation 6: No Decidability Procedures

### Description

No tableau-based or other decision procedures for validity checking.

### Impact

- Cannot automatically decide if formula is valid
- Must rely on proof construction

### Workaround

Use soundness: if you can construct a proof, it's valid.

### Resolution

Tracked in Tasks 136-138, 261.

## Summary Table

| Limitation | Severity | Workaround | Resolution Task |
|------------|----------|------------|-----------------|
| Completeness incomplete | Medium | Manual proofs | 132-135, 257 |
| ProofSearch issues | Low | Use specific tactics | - |
| Example sorries | Low | Use as exercises | 367 |
| Test sorries | Low | Signature tests work | 365 |
| Modal S4 partial | Low | Manual derivation | - |
| No decidability | Medium | Construct proofs | 136-138, 261 |

## What Works Well

Despite limitations, the following are fully functional:

- ✅ All 21 axiom schemas (base/dense/discrete layers)
- ✅ All 7 inference rules
- ✅ Full soundness proof
- ✅ Task frame semantics
- ✅ Core tactics (`modal_t`, `apply_axiom`)
- ✅ Perpetuity principles P1-P6 (fully proven; not yet registered as Aesop safe rules — see
  `tactic-registry.md`)
- ✅ Modal S5 theorem
- ✅ Propositional theorem library

## Reporting Issues

If you encounter issues not listed here:

1. Check [Project Issues](https://github.com/owner/ProofChecker/issues)
2. Verify against latest `main` branch
3. Report with minimal reproducing example

## See Also

- [Implementation Status](implementation-status.md) - Detailed module status
- [Project Limitations](../../../docs/project-info/implementation-status.md)
