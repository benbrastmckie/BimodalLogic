# Logos Known Limitations

Current limitations of the Logos logic implementation.

## Primary Limitation

**Logos is not yet implemented.** It currently exists as a re-export layer for Bimodal.

For working functionality, use:
**→ [Bimodal Documentation](../../../Bimodal/Documentation/)**

## Limitation Categories

### Category 1: Not Implemented (Planned Features)

| Feature | Description | Workaround |
|---------|-------------|------------|
| First-order logic | Quantifiers, predicates | Use propositional Bimodal |
| Second-order logic | Predicate variables | Use propositional Bimodal |
| Epistemic operators | K, B for knowledge/belief | Not available |
| Normative operators | O, P for obligation/permission | Not available |
| Explanatory operators | Grounding relations | Not available |
| State-based semantics | Hyperintensional distinctions | Use world-based Bimodal |

### Category 2: Inherited from Bimodal

Since Logos re-exports Bimodal, it inherits Bimodal's limitations:

| Limitation | Description | Resolution |
|------------|-------------|------------|
| Completeness proof | Infrastructure only | Tasks 132-135, 257 |
| ProofSearch issues | Aesop internal errors | Pre-existing |
| Example sorries | Pedagogical placeholders | Task 367 |

See [Bimodal Known Limitations](../../../Bimodal/Documentation/ProjectInfo/KNOWN_LIMITATIONS.md)
for details.

## When to Use Logos vs Bimodal

### Use Bimodal When

- You need working propositional intensional logic
- You want complete, tested functionality
- You don't need planned extensions

### Use Logos When

- You want future compatibility with extensions
- You're developing modules that will integrate with Epistemic/Normative/Explanatory
- You want namespace organization for cross-theory work

## Impact Assessment

| Use Case | Impact | Notes |
|----------|--------|-------|
| Basic modal proofs | None | Works via Bimodal |
| Basic temporal proofs | None | Works via Bimodal |
| Epistemic reasoning | Blocked | Not implemented |
| Normative reasoning | Blocked | Not implemented |
| Hyperintensional contexts | Blocked | Not implemented |

## Resolution Timeline

See [Roadmap](ROADMAP.md) for planned development phases:

1. **Phase 1 (Current)**: Bimodal re-export (complete)
2. **Phase 2**: First-order extension (not scheduled)
3. **Phase 3**: Second-order extension (not scheduled)
4. **Phase 4**: Domain extensions (not scheduled)

## See Also

- [Implementation Status](IMPLEMENTATION_STATUS.md) - Current module status
- [Roadmap](ROADMAP.md) - Development timeline
- [Bimodal Limitations](../../../Bimodal/Documentation/ProjectInfo/KNOWN_LIMITATIONS.md)
