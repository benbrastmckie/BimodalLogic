# Phase 1 Handoff: vec-EA Formula Type and Bracket Notation

## Status: COMPLETED

## What was done

Created `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/VecEAFormula.lean` (343 lines, sorry-free) implementing Rabinovich 2014 Definition 3.1 and Notation 5.2.

## Key Definitions Created

| Definition | Purpose | Lines |
|-----------|---------|-------|
| `FreeVarPositions m n` | Position assignment for free vars among witnesses | ~10 |
| `VecEAFormula m n` | General vec-EA formula with m free vars, n witnesses | ~15 |
| `BracketFormula n` | Bracket notation [alpha_0, beta_1, ...](z_0, z_1) | ~8 |
| `VBracketFormula` | Disjunction of bracket formulas (V-EA for intervals) | ~5 |
| `VecEA2 n` | 2-free-var vec-EA: endpoint preds + bracket | ~10 |
| `VVecEA2` | Disjunction of VecEA2 formulas | ~5 |

## Key Lemmas Proved

| Lemma | Description |
|-------|-------------|
| `BracketFormula.toIntervalPattern_toBracketFormula` | Round-trip conversion |
| `IntervalPattern.toBracketFormula_toIntervalPattern` | Round-trip conversion |
| `BracketFormula.holds_eq_intervalPattern_holds` | Semantic equivalence |
| `VBracketFormula.holds_iff_vef_holds` | VBracketFormula = VEF semantically |
| `VBracketFormula.disj_holds` | Closure under disjunction |
| `VVecEA2.disj_holds` | Closure under disjunction |
| `BracketFormula.trivial_holds` | 0-witness simplification |
| `VecEA2.fromBracket_holds` | Trivial endpoints reduce to bracket |

## Design Decisions

1. **Reused TemporalPred from ExistsForallNF.lean** rather than defining new predicate types
2. **BracketFormula is isomorphic to IntervalPattern** with explicit conversion functions; this maintains backward compatibility while providing Notation 5.2 vocabulary
3. **VecEA2 decomposes into endpoint predicates + bracket formula**, matching the decomposition needed for Prop 4.2 (Phase 4f)
4. **General VecEAFormula parameterized by m and n** for Def 3.1 generality, but primary work uses specialized BracketFormula/VecEA2

## Immediate Next Action

Phase 2: Closure properties (Lemma 3.4) in `VecEAClosure.lean`. The `VBracketFormula.disj_holds` and `VVecEA2.disj_holds` already provide disjunction closure; Phase 2 needs conjunction and existential quantification closure.

## Build Status

- `lake build Bimodal.Metalogic.WeakCanonical.Kamp.VecEAFormula`: SUCCESS
- `lake build` (full): Only pre-existing CanonicalTaskRelation.lean errors
- Sorry count in VecEAFormula.lean: 0
- No regressions in existing sorry-free files

## Session

sess_1781193902_83bc5c
