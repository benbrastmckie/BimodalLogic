# Handoff: Phase 1 — FOToVEA Bridge Structure

## Current State

Phase 1 partially complete. Created FOToVEA.lean and wired the bridge into NfExistTL.lean.

- **FOToVEA.lean** (105 lines): Defines `fo_to_temporal` (MonadicFormula sig 1 → Formula) and `nf_exist_to_temporal` (bridge NF → temporal). The `fo_to_temporal` function handles atom/lt/not/and cases correctly but returns `Formula.bot` as placeholder for all/ex cases.
- **NfExistTL.lean**: The sorry at line 301 (Part B at k+1) is replaced with the bridge `nf_exist_to_temporal`. The sorry is now in FOToVEA.lean:87 (`fo_to_temporal_correct`).
- **lake build**: passes (1705 jobs)

## Sorry Inventory

1. **FOToVEA.lean:87** — `fo_to_temporal_correct` — CRITICAL PATH
   - Statement: `temporal_truth M atomMap t (fo_to_temporal phi) ↔ eval M (fun _ => t) phi`
   - Assumption: The formula returned by `fo_to_temporal` for `all`/`ex` cases is `Formula.bot` (incorrect placeholder)
   - Why deferred: The `ex` case requires converting `∃ x, eval M [x,t] alpha` (where alpha : MonadicFormula sig 2) to a temporal formula. This is the core of Rabinovich Prop 4.3 and requires either (a) VecEA2 decomposition with arity reduction, or (b) a direct construction that handles the 2-variable dependency.
   - Next dispatch: Replace `fo_to_temporal` with a correct implementation for the `ex` case, or bypass `fo_to_temporal` entirely.

## Key Technical Finding

The original plan's approach (mutual structural induction producing VVecEA2) cannot produce model-independent formulas because:
- `neg_2var_vec_ea` (Prop 4.2) gives `∃ v' : VVecEA2` (model-dependent existential)
- `conj_holds_vvecEA2` similarly gives `∃ v` (model-dependent)
- The NfExistTL sorry requires `{ A : Formula // ...}` where A is a single model-independent formula

The NF-disjunction approach (`nf_exist_iff_nf1_disjunction` from boneyard) also has circular formula construction: Part_A_{k+2} references Part_B_{k+1} which references Part_A_{k+2}.

## Viable Paths Forward

1. **NF-level direct construction**: Instead of going through MonadicFormula, construct the temporal formula directly from the NF structure. The depth-0 case (`nf_2var_exist_depth0_tl`) shows the pattern: case-split on order booleans, then build VecEA2 from predicate data. At depth k+1, the quantifier clauses are the challenge — each involves a 3-var existential.

2. **Depth-0 arity-3 decomposition + IH**: VecEADecomp.lean handles depth-0 arity-3 zone decomposition (897 lines, sorry-free). At depth k+1, the 3-var quantifier clauses can be decomposed by first reducing to depth 0 via nf_to_formula, then applying VecEADecomp.

3. **NF type disjunction with finite unrolling**: Define Part_A and Part_B formulas for a FIXED maximum depth as a finite formula tree, avoiding infinite circularity.

## Immediate Next Action

Focus on implementing a correct `fo_to_temporal` for the `ex` case, likely by case-splitting on order atoms in the MonadicFormula sig 2 argument and using VecEA2 infrastructure for each case.

## Key Decisions

- Bridge structure: NF → nf_to_formula → MonadicFormula.ex → fo_to_temporal → Formula
- Model-dependent correctness is acceptable (Prior structures with HasAttainedINF)
- The sorry is localized to a single theorem (fo_to_temporal_correct)
