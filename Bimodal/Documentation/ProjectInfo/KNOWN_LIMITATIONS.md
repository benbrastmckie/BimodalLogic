# Bimodal Known Limitations

Current limitations of the Bimodal TM logic MVP and available workarounds.

## MVP Scope

This is a **Minimum Viable Product** release with intentional scope limitations.

## Limitation 1: Completeness Proof Incomplete

### Description

The completeness theorem (`valid φ → DerivationTree [] φ`) has infrastructure only.
The `provable_iff_valid` theorem uses `sorry`.

### Impact

- Cannot automatically derive proofs from semantic validity
- Must construct proofs syntactically

### Workaround

Construct proofs using axioms and inference rules directly:

```lean
-- Instead of appealing to completeness
example (p : Formula) : ⊢ p.box.imp p := modal_t p
```

### Resolution

Tracked in Tasks 132-135, 257 (currently on hold).

## Limitation 2: ProofSearch Has Build Issues

### Description

`Bimodal/Automation/ProofSearch.lean` has `aesop` internal errors that prevent
compilation in some contexts.

### Impact

- `bounded_search` and related automation may not work
- Integration tests in `AutomationProofSystemTest.lean` fail

### Workaround

Use simpler automation tactics:

```lean
-- Instead of proof_search
example (p : Formula) : ⊢ p.box.imp p := by
  modal_t  -- Use specific tactics
  -- or
  exact modal_t p  -- Use term-mode
```

### Resolution

Requires investigation of aesop internal errors.

## Limitation 3: Example Files Have Pedagogical Sorries

### Description

Files in `Bimodal/Examples/` contain `sorry` placeholders (~24 total).

### Impact

- Example files don't fully compile
- Not all proof strategies demonstrated

### Workaround

These are intentional as exercises. The completed examples nearby demonstrate
the pattern. Use them as templates.

### Resolution

Tracked in Task 367 (complete example proofs).

## Limitation 4: Test Suite Has Pending Tests

### Description

Some test files have `sorry` placeholders:
- `CompletenessTest.lean` (3) - pending completeness proof
- `PropositionalTest.lean` (1) - pending deduction helpers
- `PerpetuityTest.lean` (1) - requires concrete premises

### Impact

Tests document expected behavior but don't verify it.

### Workaround

Tests that can compile do verify type signatures are correct.

### Resolution

Tracked in Task 365 (complete BimodalTest sorries).

## Limitation 5: Modal S4 Theorems Partial

### Description

Some advanced S4 theorems (`s4_diamond_box_conj`, etc.) have `sorry`.

### Impact

Cannot use these theorems in downstream proofs.

### Workaround

Derive similar results manually using available axioms and proven theorems.

### Resolution

Part of ongoing theorem library development.

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

- ✅ All 14 axiom schemas
- ✅ All 7 inference rules
- ✅ Full soundness proof
- ✅ Task frame semantics
- ✅ Core tactics (`modal_t`, `apply_axiom`)
- ✅ Perpetuity principles P1-P5
- ✅ Modal S5 theorem
- ✅ Propositional theorem library

## Reporting Issues

If you encounter issues not listed here:

1. Check [Project Issues](https://github.com/owner/ProofChecker/issues)
2. Verify against latest `main` branch
3. Report with minimal reproducing example

## See Also

- [Implementation Status](IMPLEMENTATION_STATUS.md) - Detailed module status
- [Project Known Limitations](../../../Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md#known-limitations)
