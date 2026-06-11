# Continuation Handoff: Rabinovich Pipeline (Plan v18)

**Task**: 273 | **Status**: PARTIAL (Phases 1 complete, Phase 2 partial)
**Session**: sess_1781193902_83bc5c | **Date**: 2026-06-11

## Progress Summary

### Phase 1: Translation Correctness [COMPLETED]
- `Kamp/Translation.lean`: sorry-free proofs of `buildRight_correct`, `buildLeft_correct`, `translateEF1_correct`, `ef1_to_temporal`, `translateVEF1_correct`
- Fixed bugs in `buildRight`/`buildLeft` definitions in ExistsForallNF.lean (argument order and formula structure)
- Added temporal_truth helper lemmas for derived connectives (neg, top, and, or, all_future, all_past)

### Phase 2: Abstract INF/SUP + Prior Instantiation [PARTIAL]
- `Kamp/PriorINF.lean`: sorry-free `HasDefinableINF`/`HasDefinableSUP` abstract hypotheses, `kplus`/`kminus` definitions, `prior_hasDefinableINF`/`prior_hasDefinableSUP`
- NOT done: `VEF.closed_conj`, `VEF.closed_ex`, `inf_point_is_vef`, Dedekind instantiation

### Phases 3-5: NOT STARTED

## What Remains

### Critical Path
The sorry at KampPrior.lean:149 needs `rabinovich_fo_to_temporal_prior`:
```lean
noncomputable def rabinovich_fo_to_temporal_prior
    {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (psi : MonadicFormula sig 1) :
    { A : Formula //
      ∀ (M : OrderedMonadicStructure sig)
        (h_UZ : semantic_prior_UZ M atomMap)
        (h_SZ : semantic_prior_SZ M atomMap)
        (t : M.carrier),
        temporal_truth M atomMap t A ↔ eval M (fun _ => t) psi }
```

Once this exists, the sorry fills in ~10 lines:
```lean
| succ k _ih =>
    obtain ⟨A, hA⟩ := rabinovich_fo_to_temporal_prior atomMap h_surj (nf_to_formula nf)
    exact ⟨A, fun M hUZ hSZ t =>
      (hA M hUZ hSZ t).trans (nf_to_formula_correct M (fun _ => t) nf)⟩
```

### Why `rabinovich_fo_to_temporal_prior` Is Hard

The theorem converts `MonadicFormula sig 1` to `Formula`. By structural induction on the formula:
- Atoms, negation, conjunction: trivial (map directly to temporal connectives)
- `.all α` reduces to `.not (.ex (.not α))`
- `.ex α` where `α : MonadicFormula sig 2`: THIS IS THE HARD CASE

The existential case `∃ x, eval M (Fin.cons x (fun _ => t)) α` requires expressing a 2-variable existence statement as a temporal formula. The structural induction does NOT provide an IH for arity-2 formulas.

### Full Pipeline Required (Rabinovich 2014)

The Rabinovich pipeline proves the general statement: for ALL n, every `MonadicFormula sig n` is VEF (exists-forall normal form). At n=1, VEF implies temporal formula (Phase 1 translation). The proof uses:

1. **VEF closure under conjunction** (`VEF.closed_conj`, Lemma 3.2.1): merge witness sequences
2. **VEF closure under existential** (`VEF.closed_ex`, Lemma 3.4): add witness point
3. **VEF closure under negation on Prior structures** (negation closure, Lemmas 5.3, 5.1): the critical phase, uses HasDefinableINF

The general statement is proved by JOINT INDUCTION on quantifier depth and arity:
- Base (depth 0, any n): quantifier-free formulas of any arity are VEF
- Step: conjunction uses VEF.closed_conj, negation uses negation closure, existential uses VEF.closed_ex (reduces arity by 1) + IH on smaller depth

### Recommended Approach for Continuation

**Option A (Original plan)**: Complete Phases 2-5 as planned. This requires:
1. Prove `VEF.closed_conj` and `VEF.closed_ex` (Phase 2 completion)
2. Prove negation closure from HasDefinableINF (Phase 3)
3. Prove `rabinovich_fo_to_temporal_prior` via Prop 4.3 + Prop 3.5 (Phase 4)
4. Fill the sorry (Phase 5)

Estimated: 1500-2500 lines across 2-3 dispatches.

**Option B (Bypass VEF data type)**: Instead of working with the `IntervalPattern`/`VEF` types, prove `rabinovich_fo_to_temporal_prior` using a more direct representation. The VEF property can be expressed as "there exists a temporal formula equivalent to the formula", without constructing interval patterns explicitly. This avoids the witness-merging complexity of VEF.closed_conj.

The negation closure is still needed regardless of representation choice.

## File Inventory

| File | Status | New/Modified |
|------|--------|-------------|
| `Kamp/Translation.lean` | Complete, sorry-free | New (Phase 1) |
| `Kamp/PriorINF.lean` | Complete, sorry-free | New (Phase 2) |
| `Kamp/ExistsForallNF.lean` | Modified (buildRight/buildLeft fix) | Modified (Phase 1) |
| `Kamp/KampPrior.lean` | Sorry at line 149 | Unchanged |
| `Kamp/NegationClosure.lean` | Not created | Future (Phase 3) |

## Build Status

- `lake build` succeeds (987 jobs, only the existing sorry warning)
- All new code verified sorry-free via `lean_verify`
- No new axioms, no vacuous definitions
