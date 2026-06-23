# Arity Tower Deviation Analysis: Rabinovich vs. Current Formalization

- **Task**: 305 -- rabinovich_ea_formula_implementation
- **Type**: lean4
- **Session**: sess_1782280000_research
- **Agent**: lean-research-agent

---

## 1. Executive Summary

The "arity tower" blocking KampPrior.lean:154 is NOT part of Rabinovich's proof. It is an artifact of replacing Rabinovich's structural formula induction (Prop 4.3) with NF-depth induction (CharPart/ExistPart). Rabinovich's proof has zero arity growth because it uses two independent induction principles -- structural induction on FO formulas (Prop 4.3) and induction on witness count (Lemma 5.1) -- neither of which involves normal form depth or arity parameters. The formalization diverged when it chose to route through NormalForm evaluation with explicit depth and arity parameters instead of through MonadicFormula structural induction.

---

## 2. H3 Reference Grounding Table

| Rabinovich Reference | Current Code | Deviation Analysis |
|---------------------|--------------|-------------------|
| **Def 3.1** (EA formula) | `BracketFormula`, `VecEA2` (VecEAFormula.lean) | **Faithful**. Types match Rabinovich's definition exactly. Sorry-free. |
| **Def 3.3** (V-EA formula) | `VBracketFormula`, `VVecEA2` (VecEAFormula.lean) | **Faithful**. Sorry-free. |
| **Lemma 3.2(1)** (conjunction closure) | `conj_to_bracket_exists` (VecEAClosure.lean) | **Faithful**. Sorry-free. |
| **Lemma 3.2(2)** (arity reduction to 2-var) | **MISSING** | **Critical gap**. Rabinovich uses this to reduce m-variable EA to conjunction of 2-variable EA. Required for the existential case of Prop 4.3. Not formalized. |
| **Lemma 3.2(3)** (existential closure) | Implicit in VecEAClosure.lean | **Faithful**. Sorry-free. |
| **Lemma 3.4** (V-EA closure: disj, conj, exists) | `conj_holds_vvecEA2`, `disj_holds` (VecEAClosure.lean) | **Faithful**. Sorry-free. |
| **Prop 3.5** (V-EA 1-var -> TL) | `ExistsForallSpec.translate_correct` (RabinovichTranslation.lean) | **Faithful**. Sorry-free. |
| **Lemma 5.3** (all-betas-True negation) | `neg_orderedPointsExist_is_vbracket` (EANegation.lean) | **Faithful**. Sorry-free (full biconditional). |
| **Cor 5.4** (partial bracket negation) | Forward: `neg_partialBracketExist_sufficient` (sorry-free). Backward: **sorry** at EANegation.lean:1235 | **Partially faithful**. Forward direction sorry-free. Backward sorry is non-critical (off the Rabinovich chain's critical path). |
| **Lemma 5.1** (bracket negation, model-independent) | `neg_interval_formula_indep` + `neg_interval_formula_indep_correct` (NegationIndep.lean) | **Faithful for forward direction**. 328-line sorry-free disjunction construction. Correctness proved: if bracket fails, constructed VVecEA2 holds. |
| **Prop 4.2** (neg 2-var EA -> V-EA) | Model-dep: `neg_2var_vec_ea` (EANegationClosure.lean, sorry-free). Model-indep: `neg_2var_vec_ea_indep` (NegationIndep.lean, sorry-free). | **Faithful**. Both versions sorry-free. |
| **Prop 4.3** (FO -> V-EA, structural induction) | **NOT IMPLEMENTED as Rabinovich intends**. Current Prop43.lean contains `nf_succ_char_formula` (NF-depth infrastructure), NOT structural formula induction. | **Diverged**. This is the root cause of the arity tower. |
| **Thm 4.4** (Kamp's theorem) | `kamp_prior_expressive_completeness` (KampPrior.lean) | **Sorry at line 154**. Uses NF-depth induction instead of Prop 4.3 + Prop 3.5. |
| INF formula | `inf_bracket_formula`, `prior_hasAttainedINF` (PriorINF.lean) | **Faithful** (adapted for HasAttainedINF). Sorry-free. |
| A_i^- / A_i^+ decomposition | `leftPart`, `rightPart`, `splitAt_combine` (VecEAFormula.lean) | **Faithful**. Sorry-free. |

---

## 3. Root Cause of the Arity Tower

### What the Formalization Does

The current `kamp_prior_expressive_completeness` in KampPrior.lean uses the following proof architecture:

```
MonadicFormula sig 1
  --> (quantifier_depth = k)
  --> enumerate all NormalForm sig k 1
  --> for each NF, need temporal characteristic formula
  --> nf_characterizable_temporal_prior(k, nf)
      --> induction on k
      --> k=0: atom literals (sorry-free)
      --> k+1: nf_succ_char_formula needs exist_tl_fn : NormalForm sig k 2 -> Formula
          --> k=0: nf_2var_exist_depth0_tl_fn (sorry-free)
          --> k>=1: SORRY (arity tower)
```

At depth k+1 arity 1, the NF's quantifier layer consists of conditions over `NormalForm sig k 2`. Converting `exists x, nf_eval_nf M k 2 (x :: (fun _ => t)) sub_nf` to a temporal formula requires handling depth-k arity-2 NFs. At depth k arity 2, the quantifier layer consists of conditions over `NormalForm sig (k-1) 3`. At arity 3, the conditions are over `NormalForm sig (k-2) 4`. This continues: depth d at arity m requires depth (d-1) at arity (m+1), terminating at depth 0 and arity (k+1).

**The arity tower is**: (k+1, 1) -> (k, 2) -> (k-1, 3) -> ... -> (0, k+2).

VVecEA2 handles arity 2. There is no VVecEA_m for arbitrary arity m. So the chain breaks at arity 3.

### What Rabinovich Does Instead

Rabinovich's proof has a fundamentally different architecture with zero arity growth:

```
MonadicFormula sig 1
  --> Prop 4.3 (structural induction on formula):
      - atomic: trivially V-EA (zero witnesses)
      - disjunction: IH + Lemma 3.4 disjunction closure
      - negation: IH gives V-EA; Prop 4.2 gives neg(V-EA) = V-EA
      - existential: IH gives V-EA at arity 2;
                     Lemma 3.2(2) reduces to conjunction of 2-var EA;
                     Lemma 3.4 existential closure absorbs the quantifier
  --> Prop 3.5: V-EA with 1 free variable -> TL(U,S)
```

**There is no depth parameter anywhere in this chain.** The induction is on formula structure (which is well-founded because formulas are finite trees). The negation step uses Prop 4.2, which uses Lemma 5.1, which does induction on witness count n -- again, no depth parameter.

**There is no arity growth anywhere in this chain.** The existential case at arity n produces a sub-formula at arity n+1. But Rabinovich immediately applies Lemma 3.2(2) to decompose the (n+1)-variable EA into a conjunction of 2-variable EAs. The conjunction closure (Lemma 3.4) then handles the conjunction. The arity never exceeds 2 in any intermediate V-EA formula.

### Why the Formalization Diverged

The divergence occurred because the formalization chose to route through normal forms (via `doets_lemma_1_1` and `nf_exists_unique`) rather than through direct formula translation. This was probably motivated by the backward direction of the proof: showing that `eval M env psi -> temporal_truth M atomMap t A`. The normal form approach uses the completeness of NF classification: there exists a unique NF that characterizes any (M, t), and if two structures agree on the NF, they agree on psi. This is a clean strategy for the backward direction.

However, routing through NFs introduces depth and arity as explicit parameters, creating the tower. Rabinovich avoids this entirely because his structural induction never decomposes formulas into NFs -- it works directly on the MonadicFormula type.

---

## 4. Rabinovich's Actual Approach for the Inductive Step

### Prop 4.3 (Structural Induction on FO Formulas)

Rabinovich proves: every FO formula with m free variables is equivalent (over Dedekind complete chains) to a V-EA formula.

**Proof by structural induction on the formula**:

1. **Atomic** (P(x_i) or x_i < x_j): Trivially an EA formula (zero existential witnesses, the predicate is a "segment type" applied at the free variable positions).

2. **Disjunction** (phi_1 OR phi_2): By IH, phi_1 and phi_2 are V-EA. By Lemma 3.4, V-EA is closed under disjunction. Done.

3. **Negation** (NOT phi): By IH, phi is V-EA. Need to show neg(V-EA) is V-EA. This is exactly Prop 4.2 -- but Prop 4.2 applies to EA formulas with **at most 2 free variables**. So first apply Lemma 3.2(2): the V-EA for phi is equivalent to a conjunction of 2-variable V-EA formulas. Then negate each 2-variable conjunct using Prop 4.2, and recombine using Lemma 3.4.

4. **Existential** (EXISTS x, phi): By IH (at arity m+1), phi is V-EA. By Lemma 3.2(3), the existential of an EA formula is EA. By Lemma 3.4, V-EA is closed under existential quantification. Done.

### Key Insight: Lemma 3.2(2) is the Arity Firewall

Lemma 3.2(2) is the critical missing piece. It states:

> Every EA formula with m free variables is equivalent to a **conjunction** of EA formulas each having at most 2 free variables.

The decomposition works by projecting the m-variable EA formula onto all (m choose 2) pairs of free variables. For each pair (z_i, z_j), the EA formula restricted to that pair is a 2-variable EA formula. The conjunction of all projections recovers the original.

In the negation step of Prop 4.3, this lemma prevents arity from ever exceeding 2 in the objects handled by the negation closure (Prop 4.2). Without it, negating an m-variable V-EA would require an m-variable version of Prop 4.2, which would require Lemma 5.1 at arity m, which does not exist in the current formalization.

### Why Lemma 3.2(2) Eliminates the Arity Tower

With Lemma 3.2(2):
- Structural induction produces V-EA at arity m
- Existential quantification increases arity to m+1
- Lemma 3.2(2) immediately decomposes back to conjunctions of 2-variable V-EA
- Negation (Prop 4.2) operates only on 2-variable V-EA
- No arity ever exceeds 2 in the negation closure

Without Lemma 3.2(2) (current state):
- NF-depth induction produces existentials at arity 2
- Converting arity-2 existentials requires handling arity-3 quantifier conditions
- Arity 3 requires arity 4, and so on
- Tower grows until depth reaches 0

---

## 5. Current Sorry Inventory with Updated Remediation Paths

| # | File:Line | Statement | Critical Path | Remediation |
|---|-----------|-----------|:---:|-------------|
| 1 | KampPrior.lean:154 | `nf_characterizable_temporal_prior` succ (succ k') | **YES** | **Replace NF-depth induction with Rabinovich's structural formula induction (Prop 4.3)**. Requires: (a) implementing Lemma 3.2(2) for arity reduction, (b) implementing structural induction on MonadicFormula using Prop 4.2 + Lemma 3.4 + Lemma 3.2(2), (c) rewiring KampPrior.lean to use MonadicFormula -> V-EA -> TL instead of NF -> temporal. |
| 2 | EANegation.lean:1084 | `neg_bracket_is_vbracket` beta_0(r0) case | NO | **Leave as-is**. Documented as inherent limitation of BracketFormula-level biconditional (universal quantification over witness positions cannot be expressed as finite V-bracket). The model-dependent version and the disjunction construction (`neg_interval_formula_indep`) both work around this. Not on any critical path. |
| 3 | EANegation.lean:1235 | `neg_partialBracketExist_is_vbracket` backward n+1 | NO | **Leave as-is**. Same structural limitation as #2. F-chain reduction loses interval boundedness. Forward direction is sorry-free. Not on any critical path. |

### Sorry Chain

```
KampPrior.lean:154 (nf_characterizable_temporal_prior succ (succ k'))
  -> kamp_prior_expressive_completeness (KampPrior.lean:170)
    -> US_expressively_complete_over_prior
      -> completeness_discrete
```

All links after KampPrior.lean:154 are sorry-free in their own code; the sorry propagates via `sorryAx`.

---

## 6. What Should Go to Boneyard

### Already in Boneyard (8 files, 2350 lines)
Files moved in commit `af46ad097`:
- `FOToVEA.lean` -- NF-direct arity tower approach
- `NfExistTL.lean` -- Combined NF depth induction
- `EndpointNegation.lean` -- VecEA2-level biconditional (confirmed unprovable)
- `KampComposition.lean` -- Orphaned composition approach
- `NfComposition.lean` -- NF composition (may be useful later)
- `SeparationBridge.lean` -- Separation bridge
- `WitnessCount.lean` -- Witness counting
- `ZoneBridge.lean` -- Zone bridge infrastructure

### Should NOT Be Boneyarded
All currently active files are correctly positioned:
- `NegationIndep.lean` (328 lines, sorry-free) -- model-independent Lemma 5.1 + Prop 4.2 via disjunction construction. This IS the correct approach and is on the critical path.
- `Prop43.lean` (196 lines, sorry-free) -- NF-depth characterization infrastructure. While misnamed relative to Rabinovich's Prop 4.3, it provides `nf_succ_char_formula` which handles the depth-0 and depth-1 cases that work. It will be superseded but not boneyarded when the true Prop 4.3 is built.
- All other active files are sorry-free infrastructure that the new approach reuses.

---

## 7. Concrete Refactoring Plan

### Architecture Change

Replace:
```
MonadicFormula -> NormalForm (k, 1) -> nf_characterizable_temporal_prior(k) -> Formula
                                         ^^^ arity tower at k >= 2
```

With:
```
MonadicFormula -> fo_to_vea (Prop 4.3) -> VVecEA2 -> translate (Prop 3.5) -> Formula
                    ^^^ structural formula induction, no arity growth
```

The NF infrastructure (`doets_lemma_1_1`, `nf_exists_unique`) is still used in `kamp_prior_expressive_completeness` for the backward direction (NF determines psi). But the characteristic formula construction no longer routes through NF depth.

### What to Build

**Step 1: Lemma 3.2(2) -- Arity Reduction (~100-200 lines)**

New file or section in VecEAClosure.lean.

The statement: every m-variable EA formula is equivalent to a conjunction of 2-variable EA formulas. The construction: for each pair (z_i, z_j) of free variables among z_0, ..., z_{m-1}, project the EA formula onto that pair by existentially quantifying out all other free variables.

This requires:
- A type for m-variable EA formulas (may need VecEA_m generalizing VecEA2)
- Projection operations
- Conjunction closure for the projections

**Complication**: The current VecEA2 type is specialized to exactly 2 free variables. Lemma 3.2(2) requires either generalizing VecEA to m variables or working at the MonadicFormula level. Since Rabinovich's proof works with FO formulas (not bracket/VecEA types), the cleanest approach may be to prove Lemma 3.2(2) directly at the MonadicFormula level:

```lean
theorem fo_neg_2var_decomposable :
    forall (phi : MonadicFormula sig m),
    (forall (psi : MonadicFormula sig 2), exists (v : VVecEA2),
      forall M z0 z1, v.holds M z0 z1 <-> neg (eval M env psi)) ->
    exists (v : VVecEA2),
    forall M env, neg (eval M env phi) = ...
```

Actually, a cleaner approach for Prop 4.3 at arity 1: the existential case at arity 1 introduces arity 2. By IH at arity 2, the sub-formula is V-EA (VVecEA2). But we need to show that `exists x, VVecEA2.holds M atomMap z0 x` (or similar) is V-EA. This is exactly Lemma 3.4(3) -- existential closure. The arity never exceeds 2 because:
- We only prove Prop 4.3 at arity 1 (what KampPrior needs)
- Existential quantification at arity 1 introduces arity 2
- Arity 2 is exactly what VVecEA2 handles
- Negation at arity 2 is handled by Prop 4.2 (NegationIndep.lean)
- Disjunction/conjunction at arity 2 is handled by Lemma 3.4 (VecEAClosure.lean)

WAIT -- but the structural induction must go THROUGH all sub-formulas, including those obtained by going under existential quantifiers. If phi = EXISTS x, psi(x, z), then psi has arity 2. The IH must handle psi at arity 2. Then the negation step for psi at arity 2 uses Prop 4.2. But what if psi itself has existential sub-formulas? Then we have EXISTS y, chi(x, y, z) at arity 3. The IH at arity 3 gives V-EA3 (not VVecEA2!). Negation of V-EA3 requires Prop 4.2 at arity 3.

This is where Lemma 3.2(2) becomes essential: it reduces the arity-3 V-EA to a conjunction of arity-2 V-EAs before applying negation.

**However**, for the special case needed here (Kamp theorem for arity-1 formulas), there is a more direct route. Since MonadicFormula is a one-sorted FOMLO formula, all variables range over the same carrier. An arity-1 formula `phi(z)` has free variable z. Going under EXISTS x introduces arity 2: `psi(x, z)`. Going under another EXISTS y introduces arity 3: `chi(x, y, z)`. But in FOMLO, the variables are all interchangeable (same sort), and the formula can be viewed as having "up to 2 distinguishable free variables" by relabeling.

Actually, the issue is more subtle. Prop 4.3 is stated for ALL arities simultaneously: "every FO formula with m free variables is equivalent to a V-EA formula." The structural induction is over formulas at all arities together. The IH applies to sub-formulas at possibly higher arity.

For the formalization, this means Prop 4.3 must be:
```lean
fo_to_vea : (m : Nat) -> MonadicFormula sig m -> VVecEA_m
```
where `VVecEA_m` is a generalized V-EA type at arity m. Then Lemma 3.2(2) reduces `VVecEA_m` to a conjunction of `VVecEA2` when needed for negation.

This is exactly the arity generalization that plans 27 and 28 flagged as missing. The difference from the NF-depth approach is that here the arity grows with FORMULA DEPTH (syntactic tree depth), not with NF DEPTH. And Lemma 3.2(2) provides a FIREWALL that reduces it back to arity 2 at each negation step.

**Step 2: Generalized V-EA Type (~200-400 lines)**

New file `VecEAGeneral.lean` or extend VecEAFormula.lean.

Define `VecEA_m (m : Nat)` -- an EA formula with m free variables and n existential witnesses. This generalizes `VecEA2`. The m free variables sit at specific positions in the ordered sequence.

Alternatively, avoid introducing VecEA_m entirely by working at the MonadicFormula level. The V-EA property can be expressed as a predicate on MonadicFormula rather than as a separate type:

```lean
def is_VEA (phi : MonadicFormula sig m) : Prop :=
  exists (v : VVecEA_m m), forall M env, eval M env phi <-> v.holds M env
```

**Step 3: Structural Induction (Prop 4.3) (~300-500 lines)**

New file (rename current Prop43.lean or create a new one).

Prove by structural induction on MonadicFormula that every formula is V-EA. The critical sub-task is the negation step, which requires Lemma 3.2(2) to reduce arity before applying Prop 4.2.

**Step 4: Rewire KampPrior.lean (~100 lines)**

Replace the sorry at `nf_characterizable_temporal_prior succ (succ k')` with:
1. Convert NF to MonadicFormula via `nf_to_formula` (sorry-free)
2. Apply Prop 4.3 to get V-EA
3. Apply Prop 3.5 to get temporal Formula
4. Bridge correctness via `nf_to_formula_correct`

### What to Keep

| File | Status | Role in New Architecture |
|------|--------|------------------------|
| VecEAFormula.lean | KEEP | Core types (BracketFormula, VecEA2, VVecEA2) |
| VecEAClosure.lean | KEEP | Lemma 3.4 closure properties |
| NegationIndep.lean | KEEP | Model-independent Lemma 5.1 + Prop 4.2 (Phase 2 of v29) |
| EANegation.lean | KEEP | Lemma 5.3, Cor 5.4 forward (sorry-free parts) |
| EANegationClosure.lean | KEEP | Model-dependent Lemma 5.1 / Prop 4.2 (fallback) |
| PriorINF.lean | KEEP | INF formula infrastructure |
| RabinovichTranslation.lean | KEEP | Prop 3.5 |
| VecEATranslation.lean | KEEP | VVecEA2 -> Formula translation |
| NfToVecEA.lean | KEEP | Depth-0 NF -> VecEA2 bridge |
| ExistsForallNF.lean | KEEP | NF infrastructure (doets_lemma_1_1) |
| VecEADecomp.lean | KEEP | Depth-0 zone decomposition |
| Translation.lean | KEEP | buildRight, buildLeft |
| Prop43.lean | KEEP (rename/extend) | Currently NF-depth infrastructure; will be extended with true Prop 4.3 |
| KampPrior.lean | MODIFY | Replace sorry with Prop 4.3 + Prop 3.5 chain |

### Estimated Effort

| Component | Lines | Risk |
|-----------|------:|:----:|
| Lemma 3.2(2) arity reduction | 100-200 | Medium |
| Generalized V-EA type or predicate | 200-400 | High |
| Prop 4.3 structural induction | 300-500 | Medium |
| KampPrior rewiring | 100 | Low |
| **Total** | **700-1200** | |

### Key Risk: Generalized V-EA Type

The highest-risk component is the generalized V-EA type (or predicate). The current formalization has VecEA2 (2 free variables) as a concrete structure with `endpointLeft`, `endpointRight`, `bracket`. Generalizing to m variables means either:

(a) Defining VecEA_m with m endpoint predicates and brackets between consecutive pairs, plus specifying which position each free variable occupies.

(b) Working at the MonadicFormula level and expressing V-EA as a property rather than a type. The property would say "this formula is equivalent to a disjunction of EA formulas" without constructing the EA formulas as BracketFormula objects.

Option (b) is cleaner but loses the computational content that VVecEA2.translateLeft provides. Option (a) is heavier but preserves the translation to temporal formulas.

For the arity-1 case (what Kamp's theorem needs), there is a third option:

(c) Prove Prop 4.3 only at arity 1. The existential case introduces arity 2. The negation case at arity 2 uses Prop 4.2 (already have this for VVecEA2). The sub-formula under the existential at arity 2 is handled recursively. But the sub-formula under the existential at arity 2 may itself contain an existential, producing arity 3. The IH applies at arity 3... and we are back to needing generalized V-EA.

Unless the induction is structured differently: prove Prop 4.3 simultaneously for ALL arities via one large structural induction on MonadicFormula. Then the IH at arity m+1 is available when we process the existential case at arity m. The arity reduction (Lemma 3.2(2)) converts the m+1-variable result to 2-variable conjunctions before negation.

This is what Rabinovich does, and it requires the generalized V-EA type or predicate.

---

## 8. Alternative: Bypass Lemma 3.2(2) via NF-to-Formula Bridge

There is a possible shortcut that avoids building generalized V-EA types entirely. Observation: the current proof already has:

1. `nf_to_formula : NormalForm sig k n -> MonadicFormula sig n` (sorry-free)
2. `nf_to_formula_correct : eval M env (nf_to_formula nf) <-> nf_eval_nf M k n env nf` (sorry-free)
3. `nf_characterizable_temporal_prior` works at k=0 and k=1 (sorry-free)
4. The depth-0 case at any arity is handled by `nf_depth0_char_formula`

The question is: can we express the depth-(k+1) arity-2 existential conversion differently?

At depth k+1 arity 2, we need:
```
exists x, nf_eval_nf M (k+1) 2 (x :: env) sub_nf  <->  temporal_truth M atomMap t A
```

The NF at depth k+1 arity 2 consists of:
- Atom layer (depth 0 arity 2): predicates and orderings on (x, env)
- Quantifier layer: for each `chi : NormalForm sig k 3`, a boolean indicating exists/forall

The atom layer is handled by NfToVecEA.lean (maps to VecEA2 conditions).
The quantifier layer involves depth-k arity-3 NFs -- the arity tower.

But what if instead of descending into the NF structure, we convert the entire NF back to a MonadicFormula and apply Prop 4.3? That is:

```
nf_eval_nf M (k+1) 2 env sub_nf
  <-> eval M env (nf_to_formula sub_nf)   -- by nf_to_formula_correct
  <-> vvea.holds M env                     -- by Prop 4.3
  <-> temporal_truth M atomMap t (translate vvea)  -- by Prop 3.5
```

This would work if Prop 4.3 can handle MonadicFormula at arity 2. And it CAN -- because the structural induction on MonadicFormula does not care about arity. The MonadicFormula at arity 2 has sub-formulas at arities 1, 2, 3, etc., but the induction handles them all simultaneously.

However, this just moves the problem: Prop 4.3 at arity 2 internally needs to handle the existential case producing arity 3, which needs Lemma 3.2(2) or a generalized V-EA type.

**There is no shortcut around Lemma 3.2(2) or a generalized V-EA type.** This is the fundamental missing piece.

---

## 9. Recommendations

### Primary Recommendation

Implement Rabinovich's full Prop 4.3 with Lemma 3.2(2). This requires:

1. A predicate-based V-EA property at arbitrary arity (lighter than a full VecEA_m type)
2. Lemma 3.2(2) for arity reduction
3. Structural induction on MonadicFormula at all arities simultaneously

**Estimated effort**: 700-1200 lines, High risk due to the generalized V-EA design.

### Fallback Recommendation

If the generalized V-EA type proves too complex, consider the following pragmatic approach:

1. Prove Prop 4.3 at arity 1 and arity 2 only (mutual structural induction)
2. At arity 2, the existential case produces arity 3
3. Handle arity 3 by explicit decomposition into pairwise 2-variable conditions (this IS Lemma 3.2(2) in the special case m=3)
4. The pairwise decomposition at arity 3 produces at most 3 pairs, each yielding a VVecEA2
5. Each pair is handled by the IH at arity 2

This avoids building a general VecEA_m type but limits the proof to arity <= 3. For MonadicFormula sig 1, the maximum arity encountered during structural induction depends on the formula's quantifier depth. A formula with quantifier depth q has sub-formulas up to arity q+1. So for the general case, arbitrary arity is needed.

However, if the user's goal is just `kamp_prior_expressive_completeness` (arity-1 formulas), the maximum arity needed is bounded by the formula's quantifier depth. The induction on formula structure handles this automatically -- the question is whether the V-EA type infrastructure can handle it.

### Blocking Assessment

The task is **not blocked** in the sense that a clear path exists (Rabinovich's actual proof structure). But it requires significant new infrastructure (generalized V-EA + Lemma 3.2(2)) that the previous 29 plan versions did not build. The disjunction construction (NegationIndep.lean, plan v29 Phases 1-2) was a major step forward for Prop 4.2, but the remaining gap is Prop 4.3's handling of arbitrary arity.
