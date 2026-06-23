# Z-Completeness Transfer and Rabinovich Proof Method Analysis

- **Task**: 305 -- rabinovich_ea_formula_implementation
- **Type**: lean4
- **Session**: sess_1782220000_research
- **Agent**: lean-research-hard-agent (H2+H3+H4)
- **Tier**: 1 (literature-backed, lean4 strict)

---

## 1. Sorry Inventory (Current State)

| # | Theorem | File:Line | Critical Path | Status |
|---|---------|-----------|:---:|--------|
| 1 | `nf_characterizable_temporal_prior` (succ) | KampPrior.lean:158 | YES | The sole critical-path sorry |
| 2 | `neg_vecEA2_is_vvecEA2` (succ) | EndpointNegation.lean:160 | No | Not imported by KampPrior |
| 3 | `neg_bracket_is_vbracket` (beta_0(r_0)) | EANegation.lean:1084 | No | Documented impossibility at BracketFormula level |
| 4 | `neg_partialBracketExist_is_vbracket` (n+1 bwd) | EANegation.lean:1235 | No | Fixable (bounded F-chain) |

**Sorry chain**: KampPrior:158 -> kamp_prior_expressive_completeness -> US_expressively_complete_over_prior -> no_gaps_discrete_model_surgery -> countermodel_discrete_reynolds_v2 -> completeness_discrete. Every link after the first is sorry-free in its own code; the sorry propagates via `sorryAx`.

**Dead code**: KampComposition.lean (213 lines) is orphaned -- nothing imports it. KampBypass, KampMutualInduction, PriorComposition, NfCharFormula have been deleted.

---

## 2. Path Analysis

### Path B: Stavi Chain -- DEAD

StaviCompleteness.lean exists at `EFGames/StaviCompleteness.lean` with 3 sorrys. The key backward lemma (`nf_exist_sf_guarded_backward`, line 2873) is **mathematically false as stated** (independently verified by 2 research teammates). The Stavi path is bypassed entirely; `US_expressively_complete_over_prior` now delegates to `kamp_prior_expressive_completeness` instead.

### Path C: Z-Completeness Transfer -- NOT VIABLE

`US_expressively_complete_over_Z` (sorry-free) proves:
```lean
∀ (sig) (psi : MonadicFormula sig 1), ∃ (A : Formula) (atomMap : sig.preds → Atom),
  ∀ (M : IntStructureFromSig sig) (t : Int),
    eval (int_to_ordered sig M) (fun _ => t) psi ↔ int_truth (to_int_struct M atomMap) t A
```

Three independent blockers prevent using this to fill KampPrior.lean:158:

1. **AtomMap mismatch**: Z-theorem CHOOSES its own `atomMap' : sig.preds -> Atom` (type: preds -> Atom). KampPrior needs results for an externally given `atomMap : Formula -> sig.preds` (type: Formula -> preds). These have incompatible types and cannot be unified.

2. **Carrier mismatch**: Z-theorem quantifies over `IntStructureFromSig` (carrier = Int). KampPrior needs ALL `OrderedMonadicStructure sig` satisfying Prior-UZ/SZ (arbitrary carriers). Prior structures are not necessarily order-isomorphic to Z.

3. **Transfer circularity**: Using `doets_lemma_1_1` to transfer from Z to Prior requires NF agreement at depth k+1, which is the very thing being constructed.

**Bridge infrastructure**: `int_truth_eq_temporal_truth_Z` (SemanticBridge.lean) bridges int_truth to temporal_truth only for Z-carrier structures. Does not help with non-Z carriers.

### Path A: Rabinovich Prop 4.3 (Structural Induction) -- VIABLE

**This is the only viable path.** The full chain is:

```
Cor 5.4 biconditional (fix backward) -- EANegation.lean:1235
  |
  v
VecEA2-level Lemma 5.1 (new) -- EndpointNegation.lean
  |
  v
Model-independent Prop 4.2 (new) -- new file
  |
  v
Prop 4.3 structural induction (new) -- new file
  |
  v
Theorem 4.4 = Prop 4.3 + Prop 3.5 (new) -- new file
  |
  v
KampPrior.lean: replace NF-depth proof with Rabinovich chain
```

---

## 3. Rabinovich's Proof Method (from Literature)

Source: Rabinovich 2014, "A Proof of Kamp's Theorem", *LMCS* 10(1:14). Located at `~/Projects/Literature/sources/rabinovich_2014/`.

### Core Architecture

Rabinovich uses exactly TWO induction principles:

1. **Induction on n** (number of existential witnesses): Lemma 5.3 and Lemma 5.1. Each case reduces the witness count strictly.

2. **Structural induction on FO formulas**: Prop 4.3. Cases: atomic (trivially EA), disjunction (closure), negation (Prop 4.2), existential (Lemma 3.4). No depth parameter consumed.

The current formalization uses NEITHER. It uses mutual induction on NF depth k (CharPart(k) AND ExistPart(k)), which creates circular depth dependencies.

### Lemma 5.1: Negation of Bracket Formula

**Rabinovich's key convention**: alpha_0 is at the fixed ENDPOINT z_0, not an interior witness. This eliminates the beta_0(r_0) problem entirely.

**Case analysis** (assuming alpha_0(z_0) holds):
- **Case 2**: seg_0 (= beta_1) holds everywhere in (z_0, z_1). Reduces to Cor 5.4 on the tail bracket.
- **Case 3**: seg_0 fails at r_0 = inf{x | neg seg_0(x)} via HasAttainedINF. For any interior witness x_0:
  - If x_0 >= r_0: seg_0 on (z_0, x_0) fails at r_0. Bracket fails.
  - If x_0 < r_0: seg_0 on (z_0, x_0) holds. Need neg right_part(x_0, z_1). This is Cor 5.4 on (z_0, r_0) with fewer witnesses.

**Why this is model-independent**: The V-bracket construction depends only on the bracket's structure (pointTypes, segmentTypes), not on the model. The INF formula (sorry-free) pins r_0. Each sub-case produces a fixed V-bracket from the IH.

### Why EndpointNegation.lean:160 Failed

The analysis at EndpointNegation.lean:127-160 says the VecEA2-level proof is blocked because "the bracket's INTERIOR witnesses remain existentially quantified." This analysis is **incorrect** -- it appears to attempt a decomposition that splits on interior WITNESSES rather than on SEGMENT TYPES.

Rabinovich's decomposition splits on where the first SEGMENT type fails, not on where the first POINT type occurs. This gives:
- Case 2 (segment holds everywhere): reduces to partial bracket negation (Cor 5.4)
- Case 3 (segment fails at r_0): ALL interior witnesses before r_0 have the segment holding; ALL witnesses at or after r_0 are blocked by the segment failure

This decomposition is model-independent because the INF formula constructs r_0 as a V-EA formula, and the sub-problems have strictly fewer witnesses.

**The EndpointNegation.lean sorry IS fixable**, but requires implementing the correct Rabinovich case analysis (segment-type decomposition) rather than the point-type decomposition that was attempted.

### Cor 5.4 Backward Direction

The sorry at EANegation.lean:1235 (`neg_partialBracketExist_is_vbracket`, n+1 backward) has a concrete fix path:

**Current obstruction**: fChainPred uses nested Until operators, and Until witnesses can go past z_1. Contrapositively, fChainPred(x_0) does not guarantee exists z < z_1 with bf.holds(z_0, z).

**Fix (from report 20)**: Redefine the F-chain to use bounded Until (bounded by z_1) or modify the proof to use partial bracket existence directly. On HasAttainedINF structures, all infima are attained, so the bounded version works.

**Estimated effort**: ~100-150 lines.

---

## 4. H3 Reference Grounding Table

| Source (Rabinovich) | Prop/Location | Lean Identifier | Type Signature | Status |
|---------------------|--------------|-----------------|----------------|--------|
| Def 3.1 | EA formula, p.3 | `BracketFormula`, `VecEA2` | `structure BracketFormula (n : Nat)`, `structure VecEA2 (n : Nat)` | sorry-free |
| Def 3.3 | V-EA formula, p.3 | `VBracketFormula`, `VVecEA2` | `structure VBracketFormula`, `structure VVecEA2` | sorry-free |
| Lemma 3.2.1 | Conj closure, p.3 | `BracketFormula.conj_to_bracket_exists` | `bf1.holds -> bf2.holds -> exists bf, bf.holds` | sorry-free |
| Lemma 3.4 | V-EA closure, p.4 | `VVecEA2.conj_holds_vvecEA2` | disj/conj/exists closure | sorry-free |
| Prop 3.5 | V-EA 1-var -> TL, p.5 | `ExistsForallSpec.translate_correct`, `VVecEA2.translateLeft_correct` | `temporal_truth t v.translateLeft <-> v.holdsLeft t` | sorry-free |
| Lemma 5.3 | Ordered points neg, p.8 | `neg_orderedPointsExist_is_vbracket` | `exists v, v.holds <-> neg orderedPointsExist` | sorry-free |
| Cor 5.4 fwd | Partial bracket neg fwd, p.9 | `neg_partialBracketExist_sufficient` | `v.holds -> neg partialBracketExist` | sorry-free |
| Cor 5.4 bwd | Partial bracket neg bwd, p.9 | `neg_partialBracketExist_is_vbracket` | `v.holds <-> neg partialBracketExist` | **sorry** (fixable) |
| Lemma 5.1 model-dep | Bracket neg fwd, pp.7-11 | `neg_interval_formula` | `neg bf.holds -> exists v, v.holds` | sorry-free |
| Lemma 5.1 model-indep | Bracket neg bidi, pp.7-11 | `neg_vecEA2_is_vvecEA2` | `exists v, v.holds <-> neg vea.holds` | **sorry** (fixable via correct decomp) |
| Prop 4.2 model-dep | Neg 2-var EA, p.6 | `neg_2var_vec_ea` | `neg v.holds -> exists v', v'.holds` | sorry-free |
| Prop 4.2 model-indep | Neg 2-var EA, p.6 | -- | -- | **NOT IMPLEMENTED** |
| Prop 4.3 | FO -> V-EA, p.6 | -- | -- | **NOT IMPLEMENTED** |
| Thm 4.4 | Kamp's theorem, p.6 | `kamp_prior_expressive_completeness` | `exists A, eval psi <-> temporal_truth A` | **sorry** (KampPrior:158) |
| HasAttainedINF | Prior-specific | `prior_hasAttainedINF` | Prior -> HasAttainedINF | sorry-free |
| INF formula | eq 5.2, p.7 | `inf_bracket_formula`, `inf_bracket_formula_hasINF` | BracketFormula 1, holds iff first occurrence | sorry-free |
| K+ operator | eq 5.2, p.7 | `kplus` | `kplus M atomMap P t : Prop` | sorry-free |
| NF to FO | (infrastructure) | `nf_to_formula`, `nf_to_formula_correct` | `eval M env (nf_to_formula nf) <-> nf_eval_nf M k n env nf` | sorry-free |

---

## 5. Implementation Plan Outline

### Phase 1: Fix Cor 5.4 Backward (~100-150 lines)

**File**: EANegation.lean (modify `neg_partialBracketExist_is_vbracket`, n+1 case)

**Strategy**: Replace the fChainPred-based approach with a direct bounded construction. Use the already sorry-free `neg_orderedPointsExist_is_vbracket` (Lemma 5.3) combined with a bounded F-chain that incorporates segmentTypes(0) and bounds witnesses to (z_0, z_1).

**Dependencies**: neg_orderedPointsExist_is_vbracket (sorry-free)

### Phase 2: VecEA2-Level Lemma 5.1 (~300-400 lines)

**File**: EndpointNegation.lean (rewrite `neg_vecEA2_is_vvecEA2` succ case)

**Strategy**: Implement Rabinovich's segment-type case analysis:
1. neg endpointLeft(z_0): trivial V-bracket
2. neg endpointRight(z_1): trivial V-bracket
3. endpointLeft(z_0) AND endpointRight(z_1) AND:
   a. seg_0 holds everywhere: reduce to Cor 5.4 backward (Phase 1)
   b. seg_0 fails at r_0: INF formula pins r_0, Cor 5.4 on sub-interval (z_0, r_0) with IH

**Dependencies**: Phase 1 (Cor 5.4 backward), inf_bracket_formula (sorry-free), VecEAClosure (sorry-free)

### Phase 3: Model-Independent Prop 4.2 (~100-150 lines)

**File**: New file (e.g., `ModelIndepNegation.lean`)

**Strategy**: neg VVecEA2 = conjunction of neg VecEA2's. Each neg VecEA2 is VVecEA2 by Phase 2. Conjunction of VVecEA2's is VVecEA2 by VecEAClosure.

**Dependencies**: Phase 2, VecEAClosure (sorry-free)

### Phase 4: Prop 4.3 Structural Induction (~200-300 lines)

**File**: New file (e.g., `FOToVEA.lean`)

**Strategy**: Structural induction on `MonadicFormula sig 1`:
- Atomic: trivially V-EA (NfToVecEA bridge)
- Disjunction: V-EA closed under disjunction (Lemma 3.4)
- Negation: Prop 4.2 (Phase 3)
- Existential: V-EA closed under existential (Lemma 3.4)

**Key subtlety**: The negation step needs the formula to have at most 2 free variables. For 1-free-variable formulas, each existential introduces a new variable pairing with the single free variable, staying within 2-var scope.

**Dependencies**: Phase 3, VecEAClosure (sorry-free), NfToVecEA (sorry-free)

### Phase 5: Theorem 4.4 + KampPrior Rewiring (~100 lines)

**File**: New file (e.g., `KampRabinovich.lean`) and KampPrior.lean modification

**Strategy**: Prop 4.3 converts MonadicFormula sig 1 to VVecEA2. VVecEA2.translateLeft converts to Formula. VVecEA2.translateLeft_correct provides the biconditional. Wire this into kamp_prior_expressive_completeness.

**Dependencies**: Phase 4, RabinovichTranslation (sorry-free), VecEATranslation (sorry-free)

### Summary

| Phase | Lines (est.) | Risk | Dependencies |
|-------|-----:|:----:|-------------|
| Phase 1: Cor 5.4 fix | 100-150 | Medium | Lemma 5.3 (sorry-free) |
| Phase 2: VecEA2 Lemma 5.1 | 300-400 | High | Phase 1, INF formula (sorry-free) |
| Phase 3: Prop 4.2 model-indep | 100-150 | Low | Phase 2, VecEAClosure (sorry-free) |
| Phase 4: Prop 4.3 structural | 200-300 | Medium | Phase 3, NfToVecEA (sorry-free) |
| Phase 5: Thm 4.4 + rewiring | 100 | Low | Phase 4, RabinovichTranslation (sorry-free) |
| **Total** | **800-1200** | | |

### Incremental Build Guarantee

Each phase adds new files or modifies existing sorry sites. No sorry-free code is touched until Phase 5. `lake build` succeeds at every intermediate step:
- Phase 1: modifies sorry at EANegation.lean:1235 (reduces sorry count)
- Phase 2: modifies sorry at EndpointNegation.lean:160 (reduces sorry count)
- Phase 3: new file, new import
- Phase 4: new file, new import
- Phase 5: modifies KampPrior.lean:158 (eliminates critical sorry)

---

## 6. Adversarial Self-Verification (H4)

### Challenge 1: "The VecEA2-level Lemma 5.1 is fixable via segment-type decomposition"

**PARTIALLY VERIFIED.** The decomposition follows Rabinovich exactly when alpha_0 is at the endpoint z_0. The three cases reduce to:
- Case 1: trivial (endpoint check)
- Case 2: Cor 5.4 on tail bracket (fewer witnesses)
- Case 3: Cor 5.4 on sub-interval (z_0, r_0) (fewer witnesses)

Both cases 2 and 3 require Cor 5.4 backward (Phase 1). The INF formula construction (sorry-free) pins r_0 model-independently.

**Remaining uncertainty**: The Cor 5.4 backward fix (Phase 1) is described conceptually but not implemented. The bounded F-chain approach needs verification in Lean. **Confidence: MEDIUM-HIGH** -- the approach is sound mathematically but may require 50-100 lines of additional helper lemmas for the bounded Until construction.

### Challenge 2: "Path C (Z-transfer) is truly non-viable"

**VERIFIED.** Three independent blockers:
1. AtomMap type mismatch: `sig.preds -> Atom` vs `Formula -> sig.preds` -- confirmed by reading both type signatures
2. Carrier mismatch: IntStructureFromSig has carrier = Int, Prior structures have arbitrary carriers -- confirmed
3. Transfer circularity: doets_lemma_1_1 requires depth-(k+1) NF agreement, which is circular -- confirmed by reading the type at NormalForm.lean:433

No bridge infrastructure exists that addresses all three blockers simultaneously.

### Challenge 3: "The Stavi path is dead"

**VERIFIED.** `nf_exist_sf_guarded_backward` at StaviCompleteness.lean:2873 is documented as "mathematically FALSE as stated" in the file's own docstring (line 19). The Stavi chain is bypassed by the Kamp chain. No remaining Stavi infrastructure provides an alternative route.

### Challenge 4: "Prop 4.3 for 1-free-variable doesn't need Lemma 3.2.2"

**VERIFIED WITH CAVEAT.** For `MonadicFormula sig 1`, the existential case produces a `MonadicFormula sig 2` (2 free variables). This IS within the scope of Prop 4.2 (which handles at most 2 free variables). However, the negation of a `MonadicFormula sig 2` may internally involve formulas with 3+ variables. Rabinovich handles this via Lemma 3.2.2 (reduction to 2-free-variable EA). The current formalization has conjunction closure (Lemma 3.2.1) but NOT the full Lemma 3.2.2.

**Risk**: Prop 4.3 may need a preliminary step implementing Lemma 3.2.2. Estimated: +100 lines. This would push total to 900-1300 lines.

### Challenge 5: "800-1200 lines is realistic"

**PARTIALLY VERIFIED.** Model-dependent versions provide templates:
- `neg_interval_formula` (model-dep Lemma 5.1): 75 lines. VecEA2-level biconditional: ~2-3x = 150-225 lines.
- `neg_vecEA2` (model-dep Prop 4.2): 40 lines. Model-independent: similar or 2x.
- `neg_orderedPointsExist_is_vbracket` (Lemma 5.3 biconditional): 160 lines. Already sorry-free.

The estimate is plausible but could reach 1200-1500 if:
- Cor 5.4 backward fix is more complex than expected
- Lemma 3.2.2 is needed for Prop 4.3
- Index arithmetic in Case 3 (interval splitting) requires extensive helper lemmas

---

## 7. Findings Summary

1. **Single critical sorry**: `nf_characterizable_temporal_prior` (succ case) at KampPrior.lean:158. All other sorrys in the Kamp directory are off the critical path.

2. **Only viable path**: Rabinovich chain (Lemma 5.1 -> Prop 4.2 -> Prop 4.3 -> Theorem 4.4). Both Path B (Stavi -- mathematically false) and Path C (Z-transfer -- three independent blockers) are non-viable.

3. **The EndpointNegation.lean:160 sorry IS fixable**: The previous analysis used the wrong decomposition (point-type splitting instead of segment-type splitting). Rabinovich's segment-type decomposition avoids the beta_0(r_0) problem entirely.

4. **Required prerequisite**: Fix Cor 5.4 backward (EANegation.lean:1235) before VecEA2-level Lemma 5.1 can be completed.

5. **Estimated effort**: 800-1500 lines of new code across 5 phases, with incremental build guarantee.

6. **High-risk phase**: Phase 2 (VecEA2-level Lemma 5.1, Case 3: interval splitting with INF formula). Template exists in `neg_interval_formula` but the model-independent biconditional requires careful construction.

7. **All referenced Lean identifiers verified**: via lean_local_search and lean_hover_info. Type signatures confirmed against codebase.
