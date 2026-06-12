# Team Research Report: Task 273 — Path B Architecture and CSLib Design

- **Task**: 273 — chronicle_gap_contradiction_proof
- **Date**: 2026-06-12
- **Mode**: Team Research (4 teammates, round 13)
- **Session**: sess_1781281463_30493c
- **Status**: [RESEARCHED]
- **Type**: lean4

## Summary

This research round resolved the critical question from round 12 and designed the complete Path B architecture. **Both directions of P2(k) are confirmed used** in `nf_char_kp1_from_2var` (NegationClosure.lean:270,272,286,289), ruling out the two-phase induction shortcut. Full Path B is required.

The most important discovery is that **the NF-to-FOMLO bridge already exists**: `nf_to_formula` at NormalForm.lean:705 with `nf_to_formula_correct` at line 719 converts any NormalForm to a `MonadicFormula` with a sorry-free correctness proof. Combined with `MonadicFormula sig n` already existing in MonadicFO.lean, the biggest risk identified in round 12 (the bridge) is eliminated.

The resolution architecture is clean and produces results of independent mathematical value:

1. **VecEADecomposition.lean** (~200-300 lines): Lemma 3.2.2 — general result for ANY linear order
2. **Prop43.lean** (~200-250 lines): Prop 4.3 structural induction — Prior-specific
3. **Bridge wiring** (~25-30 lines): Close all 3 sorries via Prop 4.3 + Prop 3.5 + existing infrastructure

Total: ~425-580 lines. No restructuring of `master_induction` required.

## Confirmed Findings

### 1. Both Directions of P2(k) Used — Shortcut Impossible

Verified by direct code reading of `nf_char_kp1_from_2var` (NegationClosure.lean:204-290):

| Line | P1 direction | P2 direction used | P2 method |
|------|-------------|-------------------|-----------|
| 270 | Forward (formula → NF) | Backward (∃x → formula) | `.mpr` |
| 272 | Forward (formula → NF) | Forward (formula → ∃x) | `.mp` |
| 286 | Backward (NF → formula) | Backward (∃x → formula) | `.mpr` |
| 289 | Backward (NF → formula) | Forward (formula → ∃x) | `.mp` |

**Conclusion**: The two-phase induction (prove P1 only, derive P2 via `p2_from_p1_succ`) is impossible. Full Path B required.

### 2. Critical Infrastructure Already Exists (All Sorry-Free)

| Component | Location | Status | What it does |
|-----------|----------|--------|-------------|
| `nf_to_formula` | NormalForm.lean:705 | SORRY-FREE | NF → MonadicFormula conversion |
| `nf_to_formula_correct` | NormalForm.lean:719 | SORRY-FREE | eval M env (nf_to_formula nf) ↔ nf_eval_nf M k n env nf |
| `MonadicFormula sig n` | MonadicFO.lean | SORRY-FREE | FOMLO formula type with `eval` semantics |
| `p2_from_p1_succ` | FoToVecEA.lean:156 | SORRY-FREE | P2(k) from P1(k+1) |
| `nf_exist_iff_char_quant` | FoToVecEA.lean:85 | SORRY-FREE | ∃x, nf_eval ↔ char(t).2(sub_nf) |
| FoToVecEA.lean (full) | FoToVecEA.lean | BUILDS OK | Confirmed: `lake build` succeeds |
| Prop 4.2 | NegationClosureProp42.lean | SORRY-FREE | Negation closure for 2-var V-EA |
| Prop 3.5 | VecEATranslation.lean | SORRY-FREE | V-EA with 1 free var → temporal |
| Closure properties | VecEAClosure.lean | SORRY-FREE | V-EA closed under ∨, ∧, ∃ |

### 3. Three-Layer Mathematical Architecture (CSLib-Quality)

The natural mathematical joints, following Rabinovich 2014:

**Layer 1 — General Linear Order Results** (no completeness needed):
- Lemma 3.2.1: Conjunction closure (done in VecEAClosure.lean)
- **Lemma 3.2.2**: n-var EA → conjunction of 2-var EA (**TO DO**, ~200-300 lines)
- Lemma 3.2.3: Existential closure (done in VecEAClosure.lean)
- Lemma 3.4: V-EA closed under ∨, ∧, ∃ (done in VecEAClosure.lean)
- Prop 3.5: V-EA with 1 free var → TL(U,S) (done in VecEATranslation.lean)

**Layer 2 — Prior/Dedekind-Specific**:
- Prop 4.2: Negation closure for ≤2-var V-EA (done in NegationClosureProp42.lean)
- **Prop 4.3**: Every FOMLO formula → V-EA over Prior structures (**TO DO**, ~200-250 lines)

**Layer 3 — Kamp's Theorem** (corollary of Layers 1+2):
- Every FOMLO sentence with 1 free var has a temporal equivalent (Prop 4.3 + Prop 3.5)
- P1(k) for all k: apply Layer 3 to `nf_to_formula nf`
- P2(k) for all k: apply `p2_from_p1_succ` to P1(k+1)

### 4. Lemma 3.2.2: General Result, Independent CSLib Value

**Mathematical content** (Rabinovich p. 4): Every EA formula with n > 2 free variables `z_0 < ... < z_{m-1}` is equivalent to a conjunction of EA formulas with at most 2 free variables.

**Key properties** (from Teammate A):
- Works for ANY linear order (no density, no completeness)
- Decomposition is **constructive** (witnesses partition among intervals deterministically)
- Witness partition is implicit from the total ordering
- Point types and interval types are **local** to segments between consecutive free variables

**Design** (from Teammate A):
- Add `VecEAFormula.holds` evaluation function (~70-110 lines)
- Build `segmentBracket` extraction (~90-140 lines)
- Prove equivalence (~80-150 lines)
- Total: ~240-400 lines in `VecEADecomposition.lean`

### 5. Prop 4.3: Structural Induction on MonadicFormula

**Mathematical content** (Rabinovich p. 6): Every FOMLO formula is equivalent over Prior structures to a V-EA formula.

**Proof structure** (from Teammate B):
- Structural induction on `MonadicFormula` (or well-founded on `quantifier_depth`)
- Atomic: quantifier-free = EA with 0 witnesses (immediate)
- Disjunction: V-EA closed under ∨ (VecEAClosure.lean)
- Negation: Lemma 3.2.2 reduces to ≤2-var → Prop 4.2 negates each piece
- Existential: V-EA closed under ∃ (VecEAClosure.lean)

**Key insight** (from Teammate B): For the NF-specific case (`nf_to_formula` produces formulas with ≤2 free variables at each quantifier level), Lemma 3.2.2 is NOT needed — Prop 4.2 alone suffices. But the general Prop 4.3 statement DOES need Lemma 3.2.2 in the negation case.

**The user wants the general result** for CSLib contribution. So Lemma 3.2.2 should be formalized.

### 6. Sorry Closure Wiring (from Teammate C)

Once Prop 4.3 is proven, closing all 3 sorries requires ~25-30 lines:

**KampPrior.lean:149** (`nf_characterizable_temporal_prior` succ case):
```
1. nf_to_formula nf : MonadicFormula sig 1  (NormalForm.lean:705)
2. Prop 4.3 applied: ∃ vea, VVecEA2 equivalent  (Prop43.lean)
3. Prop 3.5: VVecEA2 → temporal formula          (VecEATranslation.lean)
4. nf_to_formula_correct: link back to nf_eval_nf (NormalForm.lean:719)
```
~15-20 lines of wiring.

**NfCharFormula.lean:572** (`nf_2var_exist_formula_prior`):
Redirect to `nf_2var_exist_formula_prior_fill` which extracts P2 from `master_induction`.
With KampPrior:149 closed, this fills automatically. ~5-8 lines.

**NegationClosure.lean:1371** (`nf_exist_formula_nested_backward`):
This sorry becomes **dead code** under Path B. The master_induction's P2(k+1) case is bypassed because KampPrior.lean provides `kamp_prior_expressive_completeness` independently. Can be marked as bypassed (like NfComposition.lean) or the master_induction can be restructured to use `p2_from_p1_succ`.

**No restructuring of `master_induction` needed** — the downstream consumers (KampPrior.lean, NfCharFormula.lean) can be closed directly.

## Synthesis

### Conflicts Resolved

**Conflict 1: Effort estimate for Lemma 3.2.2**
- Teammate A: 270-440 lines (detailed component breakdown)
- Teammate D: ~200 lines
- **Resolution**: Teammate A's estimate is more carefully derived. The `VecEAFormula.holds` addition alone is 70-110 lines. Use 250-350 as working estimate.

**Conflict 2: Is Lemma 3.2.2 needed?**
- Teammate B: Not for the NF-specific case (≤2 free vars throughout)
- Teammate D: Yes for CSLib quality and general Prop 4.3
- **Resolution**: Both correct. The user explicitly wants general results. Formalize Lemma 3.2.2.

**Conflict 3: Total scope**
- Teammate C: ~25-28 lines of wiring after Prop 4.3
- Teammate D: ~460 total (200 + 250 + 10)
- **Resolution**: These are compatible — C counts only the wiring, D counts the full implementation.

### Gaps Identified

1. **VecEAFormula.holds**: Must be added before Lemma 3.2.2 can be stated (no evaluation function exists)
2. **Arity tracking in Prop 4.3**: Structural induction ranges over ALL arities (going under ∃ increases arity). Need careful Lean encoding.
3. **NegationClosure.lean:1371 cleanup**: The sorry at line 1371 becomes dead code but isn't automatically removed. Need to either mark it bypassed or restructure master_induction.

## Implementation Plan (Recommended)

### Phase 5a: VecEADecomposition.lean — Lemma 3.2.2 (~250-350 lines)
- Add `VecEAFormula.holds` evaluation function
- Build `segmentBracket` extraction
- Prove the decomposition equivalence
- General result: works for any linear order (no Prior assumption)
- **Literature**: Rabinovich 2014, p. 4, Lemma 3.2(2)

### Phase 5b: Prop43.lean — FO → V-EA structural induction (~200-250 lines)
- Structural induction on `MonadicFormula` (or well-founded on `quantifier_depth`)
- Uses: Lemma 3.2.2 (Phase 5a), Prop 4.2 (NegationClosureProp42.lean), closure (VecEAClosure.lean)
- Prior-specific (uses Prop 4.2 which requires Prior structure)
- **Literature**: Rabinovich 2014, p. 6, Prop 4.3

### Phase 5c: Bridge Wiring (~25-30 lines)
- Close KampPrior.lean:149 via Prop 4.3 + Prop 3.5 + nf_to_formula_correct
- Close NfCharFormula.lean:572 via redirect to filled master_induction
- Mark NegationClosure.lean:1371 as bypassed

### Phase 6-8: Downstream (from existing plan v21)
- Full build verification
- NfComposition.lean quarantine (already planned)
- ROADMAP update

**Total new code**: ~475-630 lines across 2 new files + ~25-30 lines modification
**Total effort**: 12-18 hours

## Teammate Contributions

| Teammate | Angle | Status | Key Finding | Confidence |
|----------|-------|--------|-------------|------------|
| A | Lemma 3.2.2 design | completed | Constructive decomposition, 250-350 lines, any linear order | high |
| B | Prop 4.3 design | completed | MonadicFormula exists; Lemma 3.2.2 not needed for NF case but needed for general Prop 4.3 | high |
| C | Sorry wiring | completed | nf_to_formula already exists! Bridge is 25-30 lines. No master_induction restructure needed | high |
| D | CSLib architecture | completed | Three-layer decomposition (general/Prior/Kamp), clean mathematical joints | high |

## References

- Rabinovich 2014, p. 3-4: Lemma 3.2 (EA closure properties + 2-var decomposition)
- Rabinovich 2014, p. 5-6: Prop 4.2 (negation closure), Prop 4.3 (FO → V-EA)
- NormalForm.lean:705-719: `nf_to_formula` + `nf_to_formula_correct` (sorry-free bridge)
- MonadicFO.lean: `MonadicFormula sig n` type with `eval` semantics
- FoToVecEA.lean:156: `p2_from_p1_succ` (sorry-free P2(k) from P1(k+1))

## Next Steps

1. `/plan 273` — Revise plan v21 to incorporate Path B architecture (phases 5a/5b/5c)
2. `/implement 273` — Phase 5a first (Lemma 3.2.2), then 5b (Prop 4.3), then 5c (wiring)
3. Hard-mode dispatch: per-phase agents, anti-analysis contract, literature grounding
