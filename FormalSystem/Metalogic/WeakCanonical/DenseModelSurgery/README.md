# DenseModelSurgery — Reynolds sections 6 and 7

Reynolds 1992, *An Axiomatization for Until and Since over the Reals without the IRR Rule*,
section 6 (*No gaps between equivalence classes*, printed pp.176-183) and section 7
(*Separability*, printed p.184).

These two sections supply **D1** and **D2**, the two hypotheses of Doets' theorem, which
`../RealModel/` then consumes. The work is model surgery: given a Prior structure, cut out the
*bad intervals* — maximal intervals across which formula truth fails to transfer — and show
that doing so preserves truth (Lemma 8) and leaves no gaps between the resulting equivalence
classes (Lemma 9, Theorem 4). Section 7 then extracts a dense set of singleton classes from
axiom `Sep`.

Reynolds states section 6's lemmas on one side only and discharges every dual by appeal to
symmetry; `Dual.lean` is that appeal, made mechanical.

## Modules

| File | Lines | Description |
|------|-------|-------------|
| `BadIntervals.lean` | 1494 | Lemmas 6 and 7 — the bad point and bad interval vocabulary (printed pp.179-181). |
| `ChronicleInstance.lean` | 267 | Theorems 4 and 5 instantiated at the countable dense endpointless Prior structure satisfying `Sep` that this repository actually constructs. This is where **D1** and **D2** become usable. |
| `Defs.lean` | 695 | Section 6 vocabulary at the dense instance: contemporaneous equivalence, `ρ`, `λ`, and Lemma 2 (printed pp.176-177). |
| `Dual.lean` | 530 | The order-duality transport layer, discharging every one of section 6's duals mechanically rather than by hand. |
| `Lemma34.lean` | 1117 | Lemmas 3 and 4 — maximal `R`-intervals (printed pp.178-179). |
| `Lemma5.lean` | 885 | Lemma 5 — formula and elementary transfer across classes, both statements (printed p.179). |
| `NoGaps.lean` | 1133 | Lemma 9 and Theorem 4 — the classes do not end at gaps. Closes section 6 (printed pp.182-183). |
| `Singletons.lean` | 607 | Section 7 Theorem 5 — a dense set of singleton classes, from axiom `Sep` (printed p.184). This is **D2**. |
| `TruthTransfer.lean` | 840 | Lemma 8 — truth preservation under bad-interval surgery (printed pp.181-182). |

## Key Results

- Theorem 4 (`NoGaps.lean`) — **D1**, the no-gaps hypothesis of Doets' theorem.
- Theorem 5 (`Singletons.lean`) — **D2**, the separability hypothesis.
- `ChronicleInstance.lean` — both, at the chronicle structure, which is what `../RealModel/`
  consumes.

## Dependencies

- **Imports from**: `FormalSystem.Metalogic.BXCanonical.Chronicle`,
  `FormalSystem.Metalogic.WeakCanonical` prior-structure vocabulary
- **Imported by**: `FormalSystem.Metalogic.WeakCanonical.RealModel`

## Related Documentation

- [WeakCanonical README](../README.md)
- [RealModel README](../RealModel/README.md) — Doets' theorem, the consumer of D1 and D2
- [Metalogic README](../../README.md)

---

**Last verified**: 2026-08-25
