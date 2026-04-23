# Phase 4 Results: Counterexample Elimination and Omega-Union

## Status: PARTIAL (6 sorries)

## Files Created

### 1. `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean`

**Purpose**: Implements Lemmas 2.9-2.10 from Burgess 1982 -- counterexample elimination by point insertion.

**Key definitions and theorems**:
- `C5Counterexample`: Structure representing a missing Until witness
- `C5'Counterexample`: Structure representing a missing Since witness
- `exists_rat_gt_finset`: Fresh rational above all domain points (sorry -- needs `LinearOrder Rat` from `Mathlib.Algebra.Order.Ring.Rat`)
- `exists_rat_lt_finset`: Fresh rational below all domain points (sorry -- same)
- `fresh_gt_not_mem` / `fresh_lt_not_mem`: Fresh rationals are not in the domain (proved)
- `eliminate_C5_counterexample` (Lemma 2.10): Given C0 and a C5 counterexample, extends the chronicle with a witness point using Lemma 2.4 (**sorry-free** modulo helper lemmas)
- `eliminate_C5'_counterexample` (Lemma 2.10'): Mirror for Since (**sorry-free** modulo helper lemmas)
- `PotentialCounterexample`: Uniform interface for enumeration
- `eliminate_potential_counterexample`: Dispatch function that checks if a potential counterexample is actual and eliminates it (**sorry-free**)

**Sorry sites**: 2 (both in helper lemmas about finding fresh rationals)
- `exists_rat_gt_finset`: Needs `import Mathlib.Algebra.Order.Ring.Rat` for `LinearOrder Rat`, `lt_add_one`, `le_max_left/right`
- `exists_rat_lt_finset`: Same dependency

### 2. `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean`

**Purpose**: Implements the omega-chain construction and Claim 2.11 from Burgess 1982.

**Key definitions and theorems**:
- `singleton_chronicle`: Initial chronicle `{0 -> A}` for MCS A
- `singleton_c0`: Singleton chronicle satisfies C0 (**proved**)
- `counterexample_enum`: Enumeration of potential counterexamples (sorry -- needs countability of `Rat x Formula x Formula x Bool`)
- `counterexample_enum_surjective`: Every potential counterexample appears (sorry)
- `omega_chain`: The omega-indexed sequence of chronicles (**defined, sorry-free**)
- `omega_chain_val`: Extract chronicle at step n (**defined**)
- `omega_chain_c0`: Each step satisfies C0 (**proved**)
- `omega_chain_dom_mono`: Domain monotonically increases (**proved**)
- `omega_chain_f_agrees`: f agrees on old domain points (**proved**)
- `omega_chain_dom_mono_le`: Transitive domain monotonicity (**proved**)
- `omega_chain_f_agrees_le`: Transitive f agreement (**proved**)
- `limit_dom`: Limit domain (union of all finite domains) (**defined**)
- `limit_f`: Limit point function (well-defined via agreement) (**defined**)
- `limit_f_eq`: Limit f agrees with any step n where x is in dom(n) (**proved**)
- `limit_c0`: Limit satisfies C0 (**proved**)
- `limit_f_zero`: f(0) = A in the limit (**proved**)
- `zero_mem_limit_dom`: 0 is in the limit domain (**proved**)
- `limit_satisfies_c5_weak`: Limit satisfies C5 (Until witnesses exist) -- sorry
- `limit_satisfies_c5'_weak`: Limit satisfies C5' (Since witnesses exist) -- sorry
- `claim_2_11`: Truth claim (trivially proved as identity; real content in Phase 5)
- `chronicle_model_exists`: Main theorem packaging the construction (**proved**, modulo sorry'd components)

**Sorry sites**: 4
- `counterexample_enum`: Needs countability infrastructure for `Rat x Formula x Formula x Bool`
- `counterexample_enum_surjective`: Needs surjectivity of the enumeration
- `limit_satisfies_c5_weak`: Main C5 theorem -- needs tracking through omega chain
- `limit_satisfies_c5'_weak`: Mirror for Since

## Architecture Summary

The Phase 4 implementation establishes the complete proof architecture:

```
singleton_chronicle(A)  -- Step 0: {0 -> A}
      |
   omega_chain  -- Steps 1, 2, 3, ...
      |         -- Each step: eliminate_potential_counterexample
      v
 limit_chronicle  -- Union: limit_dom, limit_f
      |
 chronicle_model_exists  -- Packages: C0 + C5 + C5' + A = f(0)
```

Key proven properties of the construction:
1. **C0 preservation**: Every step and the limit satisfy C0 (all points map to MCS)
2. **Domain monotonicity**: Domains only grow along the chain
3. **f agreement**: Point assignments are stable (once defined, never changed)
4. **Well-definedness**: limit_f is well-defined (f_m(x) = f_n(x) for x in both domains)
5. **MCS at 0**: The initial MCS A is recovered at point 0 in the limit

## Remaining Work

### To complete Phase 4 (4-6 sorries to resolve):
1. **Fresh rational helpers** (2 sorries): Add `import Mathlib.Algebra.Order.Ring.Rat` and use `LinearOrder Rat` for `lt_add_one`, `le_max_left`, etc. These are mathematically trivial.
2. **Countability** (2 sorries): Define `counterexample_enum` using countability of `Rat` and `Formula`. Lean's `Encodable`/`Countable` instances may help.
3. **C5/C5' satisfaction** (2 sorries): The main theorems. Proof sketch: for any potential C5 counterexample (x, xi, eta), find n where it is enumerated. At step max(n0, n)+1, either a witness was inserted or one already existed. The witness persists to the limit by f-agreement.

### Phase 5 integration (next phase):
- Wire `chronicle_model_exists` into the `dd_countermodel` pathway
- The full truth claim (Claim 2.11) requires the interval function g and TaskFrame integration

## Build Status

- `lake build` succeeds with no errors
- No new axioms introduced
- 6 sorry sites in Phase 4 files (2 in CounterexampleElimination, 4 in ChronicleConstruction)
