# Research Report: Task #303

**Task**: K gt 0 depth induction
**Date**: 2026-06-16
**Mode**: Team Research (4 teammates)

## Summary

Task 303 targets the SOLE remaining sorry blocking `completeness_discrete`: the `succ k'` branch of `existPart_succ_n1_bypass` at `KampBypass.lean:104`. The k=0 case is fully sorry-free (~4446 lines across KampBypassCore/Until/Since). The k>0 generalization requires encoding depth-k 3-variable NF existentials as temporal formulas — a step that the k=0 infrastructure avoids because depth-0 NFs are purely atomic. The recommended approach is a mutual induction on depth (CharPart + ExistPart at all arities), following the structure already present in the archived `RabinovichGeneralized.lean` and aligned with Rabinovich 2014 Section 5 Lemma 5.1.

## Key Findings

### 1. Sole Sorry Confirmed — No Second Blocker (HIGH CONFIDENCE)

The sorry at `KampBypass.lean:104` is the SOLE `sorryAx` blocking `completeness_discrete`. This is confirmed by:
- The axiom audit at `Completeness.lean:367`
- `lean_verify` trace from task 301 (ROADMAP lines 49-63)
- `PriorExpressiveness.lean:338-340`: `US_expressively_complete_over_prior` now delegates to `kamp_prior_expressive_completeness`, **fully bypassing** the Stavi chain

The ROADMAP documents a "second independent sorry chain" (Stavi chain, verified 2026-06-09), but this is outdated — the Kamp path has fully replaced it in the live code. The 3 sorries in `StaviCompleteness.lean` are dead code for the `completeness_discrete` goal.

The sorry chain is:
```
completeness_discrete
  → countermodel_discrete_reynolds_v2
    → limitdom_is_good
      → no_gaps_discrete_model_surgery
        → US_expressively_complete_over_prior
          → kamp_prior_expressive_completeness
            → nf_characterizable_temporal_prior_classical
              → nf_2var_exist_formula_prior
                → existPart_succ_n1_bypass (k>0 sorry) ← SOLE BLOCKER
```

### 2. The k>0 Mathematical Challenge: 3-Variable Quantifier Encoding (HIGH CONFIDENCE)

At k=0, the 2-var NF `sub_nf : NormalForm sig 1 2` unfolds as:
```
(∀ a, atom_eval M [x,t] a ↔ sub_nf.1 a)                                    -- atoms
∧ (∀ ssn : NormalForm sig 0 3, (∃ y, nf_eval_nf M 0 3 [y,x,t] ssn) ↔ ...)  -- quant
```
The depth-0 3-var NFs (`NormalForm sig 0 3`) are purely atomic — no inner quantifiers. Zone decomposition (VecEADecomp, ZoneBridge) encodes them directly as temporal formulas.

At k>0 (the sorry), `sub_nf : NormalForm sig (k'+2) 2` unfolds with:
```
(∀ ssn : NormalForm sig (k'+1) 3, (∃ y, nf_eval_nf M (k'+1) 3 [y,x,t] ssn) ↔ ...)
```
The depth-(k'+1) 3-var NFs have their OWN quantifier component: `ssn.2 : NormalForm sig k' 4 → Bool`, involving 4-variable existentials at depth k'. This is the "arity-climbing" problem: encoding `∃ y` at arity 3 requires ExistPart at arity 3 (not just arity 2), which in turn needs ExistPart at arity 4, etc.

### 3. `nf_exist_backward_prior` Is Dead Code (HIGH CONFIDENCE)

The sorry at `NfCharFormula.lean:542` (`nf_exist_backward_prior`, requiring "Prior composition property at depth k+1") is:
- A `private theorem` not called by the live dispatch at `NfCharFormula.lean:636-650`
- Independent of the bypass approach — the bypass was designed specifically to avoid this backward direction
- Dead code for `completeness_discrete`

Closing `existPart_succ_n1_bypass` k>0 does NOT close `nf_exist_backward_prior`, but that's irrelevant — it doesn't need to be closed.

### 4. Boneyard Contains Valid Prior Art (HIGH CONFIDENCE)

`Theories/Bimodal/Boneyard/RabinovichPath/RabinovichGeneralized.lean` was archived in task 302 as "dead code with no live downstream consumers" — NOT because the mathematics was wrong. It contains:
- `CharPart` / `ExistPart` definitions (lines 88-127): the correct mutual induction abstraction
- `existPart_succ` (lines 399-471): the step case structure, with n=1 delegating to `existPart_succ_n1_bypass` and n≥2 marked "depends on n=1 case"
- `kamp_mutual_induction` (lines 479-491): the full induction producing `CharPart(k) ∧ ExistPart(k)` for all k
- `nf_2var_exist_formula_prior_filled` (lines 497-520): shows how the mutual induction fills the NfCharFormula sorry

This is directly reusable as a template for the live implementation.

### 5. Line Count Estimate Needs Revision (MEDIUM-HIGH CONFIDENCE)

The task description estimates 200-400 lines. Analysis:
- **Shared infrastructure**: Zone dispatch (Until/Since/Eq), atom compatibility, VecEADecomp — all reused from k=0
- **New work**: (a) Encoding `∃ y, nf_eval_nf M k 3 [y,x,t] ssn` at depth k as a temporal formula, (b) the mutual induction scaffold (CharPart + ExistPart), (c) the n≥2 → n=1 reduction
- **k=0 reference**: 4446 lines, but much of this is zone-specific machinery that won't be duplicated

The 200-400 estimate is plausible IF the approach can reduce the 3-var encoding to a recursive call to ExistPart at lower depth without re-deriving zone machinery. If new zone-level infrastructure is needed at depth k, the estimate rises to 1000-3000 lines. The mutual induction scaffold itself is modest (~200-400 lines based on the boneyard template).

**Revised estimate**: 400-1500 lines depending on how much 3-var encoding infrastructure must be built from scratch.

## Synthesis

### Conflicts Resolved

| Conflict | Teammates | Resolution |
|----------|-----------|------------|
| Stavi chain status | C (bypassed) vs D (live blocker) | **C is correct**: `PriorExpressiveness.lean:359` delegates to `kamp_prior_expressive_completeness`, fully bypassing Stavi. Code evidence overrides outdated ROADMAP text. |
| Line count estimate | A (200-400) vs C (2000-4000+) | **Between**: 400-1500 lines. C's upper bound assumes full zone machinery duplication; A's lower bound assumes no new zone work. The mutual induction scaffold reuses existing infrastructure but needs new 3-var encoding. |
| Approach strategy | A (classical existence + strong induction on k) vs B (revive mutual induction pattern) | **Compatible**: Both agree on strong induction on k. B's mutual induction (CharPart + ExistPart) provides the correct framework; A's classical existence strategy applies within each step. |

### Gaps Identified

1. **ROADMAP Stavi chain outdated**: The ROADMAP (lines 71-82) claims the Stavi chain is a "second independent sorry chain blocking `completeness_discrete`." This is no longer true — the Kamp path has replaced it. The ROADMAP should be updated after task 303 completes.

2. **3-variable encoding at depth k**: No existing infrastructure handles `∃ y, nf_eval_nf M k 3 [y,x,t] ssn` for k>0 as a temporal formula. The boneyard's mutual induction suggests the n≥2 case reduces to n=1 via projection, but the exact mechanism (`bool_eq_of_iff_same` at arity 3) needs verification.

3. **Prior composition property**: Whether `semantic_prior_UZ/SZ` suffices to prove that x's 1-var NF + t's predicates + y's zone determines the full 3-var NF at depth k. At depth 0 this is trivial; at depth k>0 it may require new lemmas. `NfComposition.lean` notes that generalized composition is FALSE for n≥2 on general linear orders — but may hold on Prior structures.

### Recommendations

**Primary approach**: Mutual induction on depth k with ExistPart at all arities n, following Rabinovich Section 5 Lemma 5.1 and using the archived `RabinovichGeneralized.lean` as a structural template.

**Concrete implementation plan**:
1. Create `KampMutualInduction.lean` (or similar) with `CharPart(k)` and `ExistPart(k)` definitions
2. Base cases (k=0): delegate to existing sorry-free results (`nf_depth0_char_formula`, `nf_2var_exist_depth0_tl`)
3. Step case CharPart(k+1): uses ExistPart(k) — already sorry-free in the boneyard pattern
4. Step case ExistPart(k+1) at n=1: this is the core — uses `char_kp1` (from CharPart(k+1)) plus zone dispatch (from k=0 infrastructure) plus recursive ExistPart(k) at n=2 for the 3-var quantifier conditions
5. Step case ExistPart(k+1) at n≥2: reduces to n=1 via projection (boneyard pattern at lines 445-471)
6. Fill `existPart_succ_n1_bypass` `succ k'` branch by extracting from the mutual induction

**Literature fidelity**: Follow Rabinovich 2014 Section 5 Lemma 5.1 faithfully. The key alignment points:
- Lemma 5.1's interval-splitting induction ↔ the mutual induction step case
- The INF formula (5.2) ↔ `PriorINF.lean:prior_hasDefinableINF`
- Closure under negation (Prop 4.2) ↔ ExistPart closure under the quantifier profile
- V-exists-forall formula composition ↔ `nf_characterizable_temporal_prior_classical`

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key Contribution |
|----------|-------|--------|------------|-----------------|
| A | Primary approach | completed | high | Classical existence strategy; identified strong induction on k as correct structure; confirmed bypass avoids nf_exist_backward_prior |
| B | Alternative approaches | completed | high | Found boneyard mutual induction template; identified n≥2 arity-climbing dependency; rated revive-mutual-induction as best approach |
| C | Critic | completed | high | Debunked Stavi chain as blocker; identified type-level mismatch (3-var at depth k); challenged line count estimate; confirmed nf_exist_backward_prior is dead code |
| D | Strategic horizons | completed | high | Mapped post-303 roadmap; identified task 95/299 dependencies; recommended tight scoping to Reynolds chain only |

## References

- Rabinovich 2014, "A Proof of Kamp's Theorem", Section 5 (Lemma 5.1, interval-splitting induction)
- `KampBypass.lean:78-104` — sorry site
- `KampBypassCore.lean`, `KampBypassUntil.lean`, `KampBypassSince.lean` — k=0 sorry-free template
- `NfCharFormula.lean:634-651` — dispatch to existPart_succ_n1_bypass
- `PriorExpressiveness.lean:338-359` — Stavi bypass confirmation
- `Completeness.lean:358-367` — sole sorryAx audit
- `Boneyard/RabinovichPath/RabinovichGeneralized.lean` — mutual induction template
- `PriorINF.lean` — INF/SUP infrastructure for Prior structures
- `NfComposition.lean` — composition property notes
