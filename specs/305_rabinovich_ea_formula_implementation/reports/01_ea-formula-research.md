# Research Report: Rabinovich EA-Formula Implementation

**Task**: 305
**Date**: 2026-06-19
**Session**: sess_1781896115_256ba5
**Agent**: lean-research-hard-agent
**Reference Grounding Tier**: Tier 1 (literature-backed, Rabinovich 2014)

---

## Findings

### H3 Lemma-Level Mapping Table (Rabinovich 2014 -> Lean Targets)

| Source | Prop/Location | Lean Identifier | Type Signature | Status |
|--------|--------------|-----------------|----------------|--------|
| Def 3.1 | EA-formula definition, p.4 | `VecEAFormula`, `BracketFormula`, `IntervalPattern` | already defined in `VecEAFormula.lean`, `ExistsForallNF.lean` | EXISTS -- partial overlap |
| Lemma 3.2 | Closure (conj, 2-var reduction, exists), p.4 | `BracketFormula.conj_to_bracket_exists` | proved in `VecEAClosure.lean` | EXISTS -- conj case proved |
| Lemma 3.4 | V-EA closure under disj/conj/exists, p.4-5 | `VEF.closed_disj`, `VEF.closed_conj`, `VEF.closed_ex` | declared in `ExistsForallNF.lean` | EXISTS -- partial |
| Prop 3.5 | V-EA with 1 free var -> TL, p.5 | `ExistsForallSpec.translate_correct` | `ExistsForallSpec -> Formula` with forward+backward proofs | EXISTS -- sorry-free in `RabinovichTranslation.lean` |
| Prop 4.2 | Negation closure (2 free vars), p.6 | **NOT PRESENT** | needs: `neg_ea_2var_is_vea : ... -> VEA` | MISSING -- the hard part |
| Prop 4.3 | FOMLO -> V-EA, p.6 | `kamp_mutual_induction` (approximate) | induction on k instead of structural induction | EXISTS -- wrong parameter |
| Theorem 4.4 | Kamp's Theorem, p.6 | `completeness_discrete` in `KampPrior.lean` | exists sorry chain via PriorComposition | EXISTS -- blocked by sorrys |
| INF formula | Eq. 5.2-5.3, p.8,10 | `kplus_formula`, `HasDefinableINF` | defined in `PriorINF.lean` | EXISTS -- abstract version |
| Lemma 5.1 | Negation of bracket formula is V-EA, p.7-11 | **NOT PRESENT** | needs: `neg_bracket_is_vea : BracketFormula n -> ... -> VEA` | MISSING -- the core gap |
| Lemma 5.3 | All betas True base case, p.8 | **NOT PRESENT** | needs: `neg_ea_all_betas_true : ... -> VEA` | MISSING |
| Corollary 5.4 | Partial EA negation, p.9 | **NOT PRESENT** | needs: `neg_partial_ea_vea : ... -> VEA` | MISSING |
| A_i^-/A_i^+ | Interval splitting, p.10 | **NOT PRESENT** | needs: `bracket_split` | MISSING |

### Key Observation: Significant Infrastructure Already Exists

The codebase already contains substantial infrastructure that an EA-formula implementation would build upon:

1. **`ExistsForallNF.lean`** (267 lines): Defines `TemporalPred`, `IntervalPattern`, `IntervalPattern.holds`, and `VEF`/`EFFormula` types semantically. This IS Rabinovich's Def 3.1 in semantic form.

2. **`VecEAFormula.lean`** (343 lines): Defines `VecEAFormula` (general m free vars, n witnesses), `BracketFormula` (2-free-var bracket notation = Notation 5.2), `FreeVarPositions`, `VecEA2` (specialized 2-free-var version). This IS the bracket notation infrastructure.

3. **`VecEAClosure.lean`** (262 lines): Proves `BracketFormula.conj_to_bracket_exists` (Lemma 3.2.1 forward). This IS partial progress on closure properties.

4. **`RabinovichTranslation.lean`** (302 lines): Defines `ExistsForallSpec` with `future_chain`/`past_chain`/`translate` and proves `translate_correct` (both directions). This IS Proposition 3.5, sorry-free.

5. **`PriorINF.lean`**: Defines `kplus`, `kminus`, `HasDefinableINF`, `HasDefinableSUP` and proves Prior structures satisfy them. This IS the INF formula infrastructure (Eq. 5.2-5.3).

6. **`SeparationBridge.lean`**: Proves `neg_until_equiv_prior` and `neg_since_equiv_prior` (GHR94 Lemma 10.2.2 on Prior structures). Useful for negation closure steps.

### Sorry Inventory (Live Sorrys in Active Code)

| File | Line(s) | Identifier | Type | Why Stuck |
|------|---------|-----------|------|-----------|
| PriorComposition.lean | 459, 462 | `nvar_transfer_from_1var_agree` (quantifier step) | cross-structure r-var transfer | Not on critical path |
| PriorComposition.lean | 554, 559 | `prior_nonconstenv_2var_agree_until` (fwd/bwd) | cross-structure 3-var transfer | THE blocker (zone-3 gap placement) |
| PriorComposition.lean | 610, 614 | `prior_nonconstenv_2var_agree_since` (fwd/bwd) | mirror of above for Since zone | THE blocker (mirror) |
| NfCharFormula.lean | 542 | `nf_exist_backward_prior` | backward existential extraction | Dead code (marked deprecated) |
| NfCharFormula.lean | 657 | `nf_2var_exist_formula_prior` k>=2 branch | general-depth existential | Dead code (marked deprecated) |

**Critical chain**: `completeness_discrete` <- `kamp_mutual_induction` <- `existPart_succ` <- `existPart_succ_n1_bypass` (k>0) <- `prior_2var_transfer_until/since` <- `prior_nonconstenv_2var_agree_until/since` (4 SORRY).

### Boneyard: Previous Failed Attempts

The `Boneyard/` directory contains prior attempts at this exact problem:
- `Boneyard/RabinovichPath/` (4 files, ~1200 lines): Attempted direct negation closure. All contain sorry. Failed attempts at `RabinovichGeneralized`, `RabinovichNegation`, `RabinovichProp42`, `RabinovichWiring`.
- `Boneyard/KampNegationClosure/` (4 files, ~3000 lines): More negation closure attempts. `NegationClosure.lean` (1843 lines), `NegationClosure5.lean` (1033 lines), `FoToVecEA.lean`, `NegationClosureProp42.lean`. All sorry-laden.
- `Boneyard/VecEADecomposition/` (330 lines): VecEA decomposition attempt with sorrys.

These failures indicate the difficulty of the negation closure argument. Key lessons from the Boneyard:
- Direct syntactic negation closure with the existing NF infrastructure is hard because NFs don't encode interval structure.
- The VecEA/BracketFormula infrastructure was introduced to bridge this gap but was never completed.

---

## Option Evaluation: Option A vs Option C

### Option A: Full EA-Formula Implementation (~2200 lines, 8 new files)

**Approach**: Implement Rabinovich's proof faithfully with new EA-formula types and negation closure.

**Advantages**:
1. Faithful to the paper -- follows a proven mathematical argument step-by-step.
2. Does NOT require solving the unsolved cross-structure transfer problem.
3. Works within a single structure (no M/N transfer).
4. Induction on n (witness count), which is the natural parameter for interval decomposition.
5. Substantial infrastructure already exists (Prop 3.5, INF, bracket formulas, closure properties).

**Challenges**:
1. Must define and manipulate interval-typed formulas at the TL level (not just NF level).
2. The negation closure (Lemma 5.1) has 3 cases with intricate interval splitting -- the Boneyard shows this is nontrivial.
3. Must bridge between the EA-formula world and the existing NF/temporal_truth world for the final rewire.
4. Estimated ~2200 lines is significant but much of the infrastructure exists.

**Actual new code needed** (after accounting for existing infrastructure):
- `IntervalPattern.holds` semantics: EXISTS (ExistsForallNF.lean)
- `BracketFormula` definition and holds: EXISTS (VecEAFormula.lean)
- `ExistsForallSpec.translate_correct`: EXISTS, sorry-free (RabinovichTranslation.lean)
- `BracketFormula.conj_to_bracket_exists`: EXISTS (VecEAClosure.lean)
- `HasDefinableINF` + Prior instantiation: EXISTS (PriorINF.lean)
- **Lemma 5.3** (neg_ea_all_betas_true): NEEDED, ~300 lines
- **Corollary 5.4** (neg_partial_ea_vea): NEEDED, ~200 lines
- **Lemma 5.1** (neg_bracket_is_vea): NEEDED, ~500 lines
- **Prop 4.2** (negation closure for 2-var EA): NEEDED, ~200 lines
- **Prop 4.3** (FOMLO -> V-EA structural induction): NEEDED, ~200 lines
- **Rewire** KampPrior.lean to use new path: NEEDED, ~100 lines

**Revised estimate**: ~1500 new lines (not ~2200) because ~700 lines of infrastructure already exist.

### Option C: Hybrid Approach (~750 lines, 2 new + 2 modified)

**Approach**: Encode Rabinovich's negation closure argument directly in terms of the existing NF infrastructure, without introducing EA-formulas as a separate type.

**Advantages**:
1. Smaller code footprint.
2. Reuses existing NF infrastructure more directly.
3. No need to bridge between EA-formula and NF worlds.

**Challenges**:
1. The existing NF infrastructure doesn't encode interval structure -- this is WHY the cross-structure approach failed.
2. Without EA-formulas, expressing "the negation of a bracket formula is V-EA" requires encoding interval types as NF predicates, which is what the Boneyard attempts failed to do.
3. The Boneyard contains ~4200 lines of failed hybrid attempts.
4. There is no clear mathematical argument for how to express Lemma 5.1's induction on witness count n using NF types directly.

**Assessment**: Option C is HIGH RISK. The Boneyard evidence strongly suggests this approach does not work. The cross-structure transfer problem (PriorComposition sorrys) is exactly the problem that arises when trying to avoid EA-formulas, and 10+ dispatch attempts have failed to solve it.

### Recommendation: Option A (Full EA-Formula)

Option A is recommended because:
1. It follows a proven mathematical argument (Rabinovich 2014).
2. The existing infrastructure reduces the work from ~2200 to ~1500 new lines.
3. The Boneyard evidence (4200+ lines of failed hybrid attempts) shows Option C does not work.
4. The key integration point is clear: the new EA path provides an alternative proof of `ExistPart(k+1)` that bypasses PriorComposition entirely.

---

## Integration Architecture

### How the EA Path Connects to Existing Code

The existing code has this structure:
```
completeness_discrete (KampPrior.lean)
  <- kamp_mutual_induction (KampMutualInduction.lean)
     <- CharPart(0): sorry-free
     <- CharPart(k+1) from CharPart(k) + ExistPart(k): sorry-free
     <- ExistPart(0): sorry-free
     <- ExistPart(k+1): SORRY (via existPart_succ_n1_bypass -> PriorComposition)
```

The EA path would provide an ALTERNATIVE proof of ExistPart(k+1) that does NOT go through PriorComposition:

```
ExistPart(k+1) [NEW PROOF]:
  For any (n+1)-var depth-(k+1) NF sub_nf:
  1. Convert the existential "exists x, nf_eval_nf M (k+1) (n+1) [x, t, ...] sub_nf"
     into an EA-formula/BracketFormula characterization (using CharPart(k+1) for point types
     and interval types).
  2. The EA-formula has one free variable (t), so by Prop 3.5 (already proved),
     it is equivalent to a TL formula.
  3. For the NEGATION case (sub_nf.2 ssn = false requires characterizing
     "not exists x, ..."), apply Lemma 5.1 (negation closure) to get a V-EA formula,
     then Prop 3.5 to get TL.
```

### Key Type Signatures for New Code

**IntervalSplitting** (the A_i^-/A_i^+ decomposition):
```lean
def BracketFormula.splitAt (bf : BracketFormula (n + 1)) (i : Fin (n + 1)) :
    BracketFormula i.val × BracketFormula (n - i.val) := ...
```

**Lemma 5.3 type**:
```lean
theorem neg_ordered_points_is_vea
    {sig : MonadicSignature} (atomMap : Formula → sig.preds)
    (n : Nat) (Ps : Fin n → Formula)
    (M : OrderedMonadicStructure sig) (z0 z1 : M.carrier) :
    ¬(∃ xs : Fin n → M.carrier,
        (∀ i j, i < j → xs i < xs j) ∧
        (∀ i, z0 < xs i ∧ xs i < z1) ∧
        (∀ i, temporal_truth M atomMap (xs i) (Ps i))) →
    ∃ (vea_formula : Formula),
      temporal_truth M atomMap z0 vea_formula   -- expressed via Until/Since
```

**Lemma 5.1 type** (the core):
```lean
theorem neg_bracket_is_vea
    {sig : MonadicSignature} (atomMap : Formula → sig.preds)
    (n : Nat) (bf : BracketFormula n)
    (h_UZ : semantic_prior_UZ M atomMap) (h_SZ : semantic_prior_SZ M atomMap)
    (z0 z1 : M.carrier) (hz : z0 < z1) :
    ∃ (neg_formula : Formula),
      (temporal_truth M atomMap z0 neg_formula ↔
       ¬ bf.holds M atomMap z0 z1)
```

### Prior-UZ/SZ vs Dedekind Completeness

Rabinovich's proof uses Dedekind completeness for exactly one purpose: the INF formula (Eq. 5.2-5.3), which finds the infimum point r0 = inf{z in (z_0, z_1) : P(z)}.

The existing code uses Prior-UZ/SZ axioms instead of Dedekind completeness. For the INF construction, Prior-UZ directly provides a "first occurrence" point:
- `semantic_prior_UZ`: if P holds somewhere above t, then there exists a FIRST occurrence s > t with P(s) and not-P throughout (t, s).

This is STRONGER than what Rabinovich needs for INF: Prior-UZ gives an exact first occurrence (not just an infimum), eliminating the K+ disjunct. The existing `PriorINF.lean` already establishes this connection via `HasDefinableINF`.

**Conclusion**: The existing Prior-UZ/SZ framework is SUFFICIENT for implementing Rabinovich's proof. No need to introduce a separate Dedekind completeness hypothesis.

---

## Mathlib Dependencies

### Already Imported
- `Mathlib.Data.Finset.Sort` -- used for witness ordering in VecEAClosure
- `Mathlib.GroupTheory.Perm.Fin` -- used in KampBypassCore
- `Mathlib.Data.Fintype.Card` -- used throughout NF infrastructure
- `Mathlib.Order.SuccPred.Basic` -- used in MonadicFO

### Likely Needed
- `Mathlib.Order.ConditionallyCompleteLattice.Basic` -- for `csInf` characterization (if Dedekind route chosen, but not needed with Prior-UZ)
- `Mathlib.Data.List.Sort` -- `StrictMono.sortedLT_ofFn` for witness sequence manipulation
- `Mathlib.Data.Fin.Tuple.Sort` -- `Tuple.sort` for witness reordering in bracket conjunction

### Verified Existing Constructs
- `StrictMono` (Mathlib): used for witness ordering constraints
- `Finset.sort` / `Finset.orderEmbOfFin` (Mathlib): for canonical witness ordering
- `List.finRange` / `List.ofFn` (Mathlib): for constructing witness sequences
- `LinearOrder` (Mathlib): the carrier order type, already in `OrderedMonadicStructure`

---

## Tactic Survey Results

### Existing Proof Patterns in the Codebase

The Kamp directory uses these patterns consistently:
1. **Classical.em / rcases Classical.em**: For satisfiability case splits (used in `existPart_succ_n1_bypass` at line 482).
2. **Fin.cases / Fin.cons**: For arity-based case analysis (pervasive in PriorComposition, KampBypass).
3. **nf_agreement_from_shared_nf**: The key transfer lemma -- given two structures satisfying the same NF, all NFs agree. Used 6+ times in KampBypass.lean.
4. **nf_characteristic_satisfies / nf_eval_unique**: NF uniqueness lemmas, used throughout.
5. **formula_conjList_iff / formula_disjList_iff**: For encoding finite conjunctions/disjunctions as temporal formulas (Separation module).
6. **temporal_truth_and / temporal_truth_neg**: For decomposing compound temporal formulas.

### Tactics Likely Needed for EA Implementation
- `Nat.strong_induction_on` or `Nat.strong_rec_on`: for induction on n (witness count) in Lemma 5.1
- `simp [IntervalPattern.holds]`: for unfolding interval pattern semantics
- `omega`: for Fin/Nat arithmetic (pervasive in the codebase)
- `constructor / And.intro`: for splitting existential constructions
- `rcases / obtain`: for destructuring existential witnesses

---

## Adversarial Self-Verification

### Challenged Claims

1. **Claim**: "Option C is high risk based on Boneyard evidence."
   - **Verification**: The Boneyard contains `KampNegationClosure/` (3000+ lines) and `RabinovichPath/` (1200+ lines), all sorry-laden. The `VecEADecomposition/` attempt (330 lines) also failed. These represent 3+ fundamentally different approaches to the hybrid strategy, all blocked.
   - **Status**: VERIFIED. The Boneyard evidence is strong.

2. **Claim**: "Existing infrastructure reduces Option A from ~2200 to ~1500 new lines."
   - **Verification**: `RabinovichTranslation.lean` (302 lines, Prop 3.5 sorry-free), `VecEAClosure.lean` (262 lines, conj closure partial), `PriorINF.lean` (INF framework), `VecEAFormula.lean` (343 lines, BracketFormula types), `ExistsForallNF.lean` (267 lines, IntervalPattern). Total existing: ~1200 lines of directly relevant infrastructure. But these are infrastructure definitions, not the hard proofs (Lemma 5.1/5.3). The ~1500 estimate for new code may be optimistic -- Lemma 5.1 alone could be 500-800 lines given the 3-case decomposition.
   - **Status**: REVISED. New estimate: 1500-2000 new lines.

3. **Claim**: "Prior-UZ/SZ is sufficient for the INF construction."
   - **Verification**: `PriorINF.lean` defines `HasDefinableINF` and the abstract framework. Prior-UZ gives first occurrence directly (stronger than infimum). The paper's INF formula uses `P(r0) OR K+(P)(r0)` -- on Prior structures, only the `P(r0)` disjunct is needed since Prior-UZ gives exact first occurrence, not limit points.
   - **Status**: VERIFIED. Prior-UZ is sufficient and simpler.

4. **Claim**: "The 4 PriorComposition sorrys are the only blockers."
   - **Verification**: `grep -rn sorry` in the active Kamp directory shows: PriorComposition.lean (6 sorry references, 4 live), NfCharFormula.lean (2 sorry, both deprecated/dead code), KampMutualInduction.lean (0 sorry in proof terms). The dependency chain traces from `completeness_discrete` through `existPart_succ_n1_bypass` (k>0 case) to `prior_2var_transfer_until/since` to `prior_nonconstenv_2var_agree_until/since`.
   - **Status**: VERIFIED. The 4 PriorComposition sorrys at lines 554, 559, 610, 614 are the only live blockers.

5. **Claim**: "The EA path provides an alternative to PriorComposition."
   - **Verification**: The EA path would provide `ExistPart(k+1)` via: (a) encode the 2-var existential as an EA/bracket formula using CharPart(k+1) for point types, (b) for positive case, use Prop 3.5 (existing) to get TL, (c) for negative case, use Lemma 5.1 (new) for negation closure, then Prop 3.5. This bypasses `prior_nonconstenv_2var_agree_until/since` entirely because it works within a single structure.
   - **Status**: VERIFIED, but with caveat: the encoding step (a) requires careful translation between NF quantifier conditions and EA interval types, which is nontrivial.

### Uncertain Claims (Confidence Levels)

1. **"Lemma 5.1 is provable in Lean with Prior-UZ/SZ instead of Dedekind completeness"** -- Confidence: 85%. Prior-UZ gives FIRST occurrence, which is strictly stronger than INF. The only concern is whether Prior-UZ/SZ compose correctly across the 3-case decomposition. Prior structures on a linear order with first/last occurrence properties should behave like discrete structures from the INF perspective.

2. **"The bracket formula conjunction closure (Lemma 3.2.1) generalizes to arbitrary n"** -- Confidence: 75%. The existing `BracketFormula.conj_to_bracket_exists` only handles the forward direction for specific small n. The general case requires merging two ordered witness sequences, which involves a merge sort on the combined sequence + type conjunction at each point. This is technically straightforward but could be 200+ lines.

3. **"The integration rewire from EA path to KampPrior.lean is ~100 lines"** -- Confidence: 70%. The rewire requires showing that the EA-based `ExistPart(k+1)` proof is type-compatible with the `ExistPart` signature in `KampMutualInduction.lean`. The types match in principle (both produce `exists A, ...`), but the intermediate type translations (TemporalPred <-> Formula, IntervalPattern.holds <-> nf_eval_nf) could add complexity.

---

## Phasing Recommendation

Based on the analysis, the implementation should proceed in these phases:

1. **Phase 1: Interval Splitting Infrastructure** (~200 lines)
   - Define `BracketFormula.splitAt` (A_i^-/A_i^+ decomposition)
   - Prove `splitAt_holds` (splitting preserves interval pattern semantics)
   - Extend `BracketFormula.conj_to_bracket` for arbitrary n

2. **Phase 2: Lemma 5.3 (All Betas True)** (~300 lines)
   - `neg_ordered_points_is_vea`: by induction on n
   - Uses Prior-UZ/SZ for INF construction (PriorINF.lean infrastructure)
   - Base case: universal negation (forall y in interval, not P(y))
   - Inductive step: split at inf point, reduce to n-1

3. **Phase 3: Corollary 5.4** (~200 lines)
   - `neg_partial_ea_vea`: partial bracket negation
   - Defines F_i chain (alpha_i AND (beta_{i+1} Until F_{i+1}))
   - Reduces to Lemma 5.3

4. **Phase 4: Lemma 5.1 (Full Negation Closure)** (~500-800 lines)
   - 3-case decomposition (endpoint failure, guard success, INF splitting)
   - Induction on n using `splitAt`
   - This is the hardest phase

5. **Phase 5: Prop 4.2 and 4.3** (~200 lines)
   - `neg_ea_2var_is_vea`: applies Lemma 5.1
   - `fomlo_to_vea`: structural induction using Lemma 5.1 for negation

6. **Phase 6: ExistPart Rewire** (~200 lines)
   - New proof of `ExistPart(k+1)` using EA negation closure
   - Replace the sorry-containing path in `existPart_succ`
   - Verify `kamp_mutual_induction` compiles sorry-free

7. **Phase 7: Integration and Cleanup** (~100 lines)
   - Verify `completeness_discrete` compiles sorry-free
   - Move PriorComposition sorry code to Boneyard
   - `lake build` verification

---

## Key Files Summary

### Existing Files (Critical Dependencies)
- `/home/benjamin/Projects/BimodalLogic/Theories/Bimodal/Metalogic/WeakCanonical/Kamp/ExistsForallNF.lean` -- IntervalPattern, TemporalPred, VEF types
- `/home/benjamin/Projects/BimodalLogic/Theories/Bimodal/Metalogic/WeakCanonical/Kamp/VecEAFormula.lean` -- VecEAFormula, BracketFormula, VecEA2
- `/home/benjamin/Projects/BimodalLogic/Theories/Bimodal/Metalogic/WeakCanonical/Kamp/VecEAClosure.lean` -- Closure properties (partial)
- `/home/benjamin/Projects/BimodalLogic/Theories/Bimodal/Metalogic/WeakCanonical/Kamp/RabinovichTranslation.lean` -- Prop 3.5 (sorry-free)
- `/home/benjamin/Projects/BimodalLogic/Theories/Bimodal/Metalogic/WeakCanonical/Kamp/PriorINF.lean` -- INF/SUP framework
- `/home/benjamin/Projects/BimodalLogic/Theories/Bimodal/Metalogic/WeakCanonical/Kamp/SeparationBridge.lean` -- Until/Since negation
- `/home/benjamin/Projects/BimodalLogic/Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampMutualInduction.lean` -- CharPart/ExistPart framework (rewire target)
- `/home/benjamin/Projects/BimodalLogic/Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampBypass.lean` -- existPart_succ_n1_bypass (sorry consumer)
- `/home/benjamin/Projects/BimodalLogic/Theories/Bimodal/Metalogic/WeakCanonical/Kamp/PriorComposition.lean` -- sorry source (4 live sorrys)
- `/home/benjamin/Projects/BimodalLogic/Theories/Bimodal/Metalogic/WeakCanonical/PriorDefs.lean` -- semantic_prior_UZ/SZ

### Existing Files (Sorry-Free Foundation)
- `/home/benjamin/Projects/BimodalLogic/Theories/Bimodal/Metalogic/WeakCanonical/NormalForm.lean` -- NF theory (nf_characteristic, nf_eval_nf, nf_agreement_from_shared_nf)
- `/home/benjamin/Projects/BimodalLogic/Theories/Bimodal/Metalogic/WeakCanonical/MonadicFO.lean` -- MonadicSignature, OrderedMonadicStructure, eval
- `/home/benjamin/Projects/BimodalLogic/Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfCharFormula.lean` -- nf_characterizable_temporal_prior_classical (sorry-free)
- `/home/benjamin/Projects/BimodalLogic/Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean` -- completeness_discrete (top-level, consumes ExistPart)

### Literature Reference
- `/home/benjamin/Projects/Literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.md` -- Full paper summary
