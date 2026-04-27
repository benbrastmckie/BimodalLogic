# Teammate D Findings: Reflexive vs Strict Semantics Gap

**Task**: 107 - Chain design diagnostics for representation theorem
**Focus**: Horizons -- how the reflexive-to-strict adaptation affects the r-relation and seed construction
**Date**: 2026-04-26

## Executive Summary

The reflexive-vs-strict semantics gap is both the root cause of the seed construction problem AND resolvable without changing any definitions. The codebase's half-open guard `[t,s)` is strictly STRONGER than Burgess's open guard `(t,s)`, and this strength provides the key tool: the `until_guard` axiom (`untl(phi,psi) -> phi`). The Lindenbaum-with-side-condition argument sketched in the sorry comment at RRelation.lean:1138-1150 is mathematically correct and should be formalized directly.

## Finding 1: Precise Characterization of the Semantics Gap

### Burgess (1982) -- Open Guard on Strict Order

```
V(U(alpha, beta)) = {x : exists y. x < y AND alpha(y) AND forall z. (x < z < y => beta(z))}
```

- Witness: `x < y` (strict)
- Guard interval: `(x, y)` open -- does NOT include x or y
- The r-relation `r(A, beta, C)`: for all gamma in C, `U(gamma, beta) in A`
- Reflexive consequence: taking `y = x` is NOT possible (strict), but the guard `(x,y)` is open, so even with y being the immediate successor, the guard interval may be empty (in dense orders) or skip the current point

### Codebase -- Half-Open Guard on Strict Order

```
truth_at ... (Formula.untl phi psi) = exists s. t < s AND psi(s) AND forall r. (t <= r AND r < s => phi(r))
```

- Witness: `t < s` (strict, same as Burgess)
- Guard interval: `[t, s)` half-open -- INCLUDES the current point t
- Axiom `until_guard`: `untl(phi, psi) -> phi` (sound because guard covers t)
- Axiom `until_elim` (BX9): `untl(phi, psi) -> phi OR psi` (weaker, also available)

### The Gap

In Burgess's setting, `r(A, beta, C)` says: for all gamma in C, `U(gamma, beta) in A`. When A = C or gamma in A intersect C, one might hope to take `y = x` to make the guard vacuous. But `x < y` is strict, so this fails in BOTH settings.

The REAL difference is what the guard covers:
- Burgess open guard `(t,s)`: the guard beta need not hold at t itself
- Codebase half-open guard `[t,s)`: the guard beta MUST hold at t (hence `until_guard`)

This means `untl(beta, gamma) in A` implies `beta in A` in the codebase (via `until_guard`), which Burgess does not have.

### Consequence for K = {beta | burgessR(A, beta, C) AND burgessRSince(C, beta, A)}

The proof at RRelation.lean:1126-1130 already shows `K subset A` using this: pick any theorem `gamma0 in C`, then `untl(beta, gamma0) in A`, and `until_guard` gives `beta in A`.

This is CORRECT and UNIQUE to the half-open guard semantics. Burgess's open-guard version would not have K subset A in general.

## Finding 2: The Lindenbaum-with-Side-Condition Approach is Correct

The sorry comment at lines 1138-1150 sketches the right proof. Here is the rigorous argument:

### Claim
For any MCS A, C, there exists B with `BurgessR3Maximal(A, B, C)`.

### Proof Strategy: Lindenbaum Extension Preserving burgessR3

**Step 1**: The empty set satisfies `burgessR3(A, {}, C)` vacuously (no beta in {} to check).

**Step 2**: Enumerate all formulas as `phi_0, phi_1, phi_2, ...`. Build a chain:
- `B_0 = {}`
- `B_{n+1} = B_n union {phi_n}` if this is consistent AND satisfies `burgessR3(A, -, C)`, otherwise `B_n`.

**Step 3**: `B_omega = union B_n` satisfies:
- Consistent (each finite stage is)
- burgessR3(A, B_omega, C) (each element was checked)
- Maximal with respect to consistent sets satisfying burgessR3

**Step 4**: B_omega is deductively closed. This is the KEY step. Suppose `L subset B_omega` and `L derives phi`. We must show `phi in B_omega`.

By the BX7+BX2 argument (already proved as `untl_conj_guard` + `untl_left_mono_thm`):
- `untl_conj_guard`: if `untl(beta1, gamma)` and `untl(beta2, gamma)` in A, then `untl(beta1 AND beta2, gamma)` in A
- `untl_left_mono_thm`: if `|- (beta1 -> beta2)` and `untl(beta1, gamma)` in A, then `untl(beta2, gamma)` in A
- Combined: if `L = {l1, ..., lk} subset B_omega` and each `li` has `burgessR(A, li, C)`, then `l1 AND ... AND lk` has `burgessR(A, -, C)` (by iterated `untl_conj_guard`), and if `L derives phi`, then `burgessR(A, phi, C)` (by `untl_left_mono_thm` since `|- (l1 AND ... AND lk -> phi)`).
- Mirror argument for `burgessRSince` using `snce_conj_guard` + `snce_left_mono_thm`.

So `phi` satisfies `burgessR3(A, -, C)`. Since `B_omega` is maximal among consistent sets satisfying burgessR3, and `B_omega union {phi}` is consistent (derivable from B_omega) and satisfies burgessR3, we must have `phi in B_omega`.

**Step 5**: B_omega is an MCS. By maximality: if `phi not in B_omega`, then `B_omega union {phi}` either violates consistency or burgessR3. If it violates consistency, then `phi.neg` is derivable from B_omega, hence `phi.neg in B_omega` (by Step 4). If it violates burgessR3, then `phi.neg` may not be in B_omega. But wait -- we need B_omega to be a DCS, not necessarily an MCS.

**Correction**: B_omega is NOT necessarily an MCS. It IS a DCS (Step 4 shows closure under derivation, and consistency is maintained). And it IS maximal among DCS satisfying burgessR3. Here is why:

If D is a DCS with `B_omega subset D` and `burgessR3(A, D, C)`, then for each `phi in D`, `phi` satisfies burgessR3 individually (since D does and phi in D). So `phi` would have been added during the Lindenbaum construction (it's consistent with B_omega since B_omega subset D, and it satisfies burgessR3). Hence `phi in B_omega`. So `D = B_omega`.

### Critical Insight: No Seed Needed

The empty set IS a valid seed. It is NOT a DCS (missing theorems), but the Lindenbaum construction does not need a DCS seed. It starts from the empty set and builds up to a DCS. The `burgessR3Maximal_extension_exists` theorem requires a DCS seed, but `burgessR3Maximal_exists` can bypass this by using a direct Lindenbaum construction instead.

## Finding 3: Why the Existing `burgessR3Maximal_extension_exists` Cannot Help Directly

The existing Zorn argument (`burgessR3Maximal_extension_exists` at line 781) requires a DCS seed S with `burgessR3(A, S, C)`. The three candidates explored in the handoff:

1. **Empty set**: Satisfies burgessR3 vacuously but is NOT a DCS.
2. **Set of theorems**: IS a DCS. For `burgessR(A, thm, C)`: need `untl(thm, gamma) in A` for all gamma in C. By BX2 + temporal generalization, `untl(thm, gamma)` follows from `F(gamma)`, but `F(gamma)` may not be in A.
3. **Kernel K**: May be empty, and deductiveClosure({}) = theorems, returning to case 2.

The solution is to NOT use `burgessR3Maximal_extension_exists` at all. Instead, prove `burgessR3Maximal_exists` directly via the Lindenbaum argument in Finding 2.

## Finding 4: Formalization Path

The Lindenbaum-with-side-condition can be formalized in Lean 4 using the same Zorn's lemma approach but on a different partial order:

```
-- Family: consistent sets satisfying burgessR3(A, -, C)
def burgessR3ConsistentSets (A C : Set Formula) : Set (Set Formula) :=
  {B | SetConsistent B AND burgessR3 A B C}
```

This family:
- Is non-empty (contains the empty set)
- Is closed under chain unions (consistency is preserved since any finite subset lies in one chain element; burgessR3 is preserved since each element lies in some chain element)
- By Zorn, has a maximal element B_max

Then show B_max is a DCS:
- **Consistency**: by membership in the family
- **Closure under derivation**: by the BX7+BX2 argument. If L subset B_max derives phi, then burgessR3(A, B_max union {phi}, C) holds (from untl_conj_guard + untl_left_mono_thm + mirrors). And B_max union {phi} is consistent (phi is derivable from B_max). So by maximality, phi in B_max.

Then B_max is BurgessR3Maximal:
- DCS: shown above
- burgessR3: by membership
- Maximality: if D is a proper DCS extension with burgessR3, then D is consistent with burgessR3, contradicting B_max's maximality among consistent sets.

### Key Lemma Needed

The only non-trivial step is: if L subset B and `burgessR3(A, B, C)` and `L derives phi`, then `burgessR3(A, {phi}, C)` (i.e., `burgessR(A, phi, C)` and `burgessRSince(C, phi, A)`).

This factors as:
1. `burgessR_derivation_closed`: if each `li in L` has `burgessR(A, li, C)` and `L derives phi`, then `burgessR(A, phi, C)`.
   - Proof: by `untl_conj_guard` (conjoin all guards) then `untl_left_mono_thm` (weaken conjunction to phi).
2. Mirror for `burgessRSince`.

Both building blocks (`untl_conj_guard`, `untl_left_mono_thm`, `snce_conj_guard`, `snce_left_mono_thm`) are already sorry-free in RRelation.lean.

## Finding 5: The C4 Hard Case Dependency

The C4 hard case (CounterexampleElimination.lean:332) requires:
- `BurgessR3Maximal(f(x), g(x,y), f(y))` for adjacent x, y (this is C2')
- `burgessR3_gamma_not_in_B` (already sorry-free): if `neg(untl(gamma, delta)) in A` and `delta in C`, then `gamma not in B`

Once `burgessR3Maximal_exists` is proved, the C4 hard case can be resolved:
1. The g-values for adjacent pairs are constructed via `burgessR3Maximal_exists`
2. `gamma not in g(x,y)` by `burgessR3_gamma_not_in_B`
3. `gamma.neg in g(x,y)` by `dcs_neg_insert_consistent` + DCS closure (actually by the maximality of g(x,y): since gamma not in g(x,y), and g(x,y) is maximal consistent with burgessR3, gamma.neg must be derivable from g(x,y) union {gamma.neg})

Wait -- DCS is NOT MCS. So `gamma not in g(x,y)` does NOT directly give `gamma.neg in g(x,y)`. We need the intermediate MCS f(z) for the new point z. The strategy from Burgess Lemma 2.6 is: since `gamma not in g(x,y)` and `BurgessR3Maximal(f(x), g(x,y), f(y))`, the maximality means adding gamma breaks either consistency or burgessR3. This is the content of Lemma 2.6 itself, which constructs D (with `neg(delta) in D`) by building `D_0 = {...} union {neg(delta)}` and showing it consistent.

This is a separate proof concern from the seed problem. The seed problem (burgessR3Maximal_exists) is a prerequisite.

## Finding 6: Relationship Between Two r-Relations

The codebase has TWO different r-relation families:

1. **Obligation-propagation** (`rRelation`, `R3Maximal`): For all `untl(gamma, delta) in A`, either `delta in B` or `(gamma in B AND untl(gamma,delta) in B)`. This is MONOTONE in B.

2. **Content-based** (`burgessR`, `BurgessR3Maximal`): For all `gamma in C`, `untl(beta, gamma) in A`. This is the Burgess r-relation. ANTI-MONOTONE in B (larger B means more betas to check).

The chronicle construction uses BurgessR3Maximal for C2' (correct). The `R3Maximal` and `r3Maximal_extension_exists` at line 388 are for the obligation-propagation version and are NOT used in the chronicle conditions. They appear to be legacy code from an earlier design.

## Recommendations

### Immediate Action: Prove `burgessR3Maximal_exists` via Zorn on Consistent Sets

Replace the sorry at RRelation.lean:1151 with:

1. Define `burgessR3ConsistentSets A C = {B | SetConsistent B AND burgessR3 A B C}`
2. Show empty set is in this family
3. Apply Zorn (chain unions preserve the property)
4. Show the maximal element is a DCS (via BX7+BX2 argument)
5. Show it is BurgessR3Maximal

### Required New Lemma

`burgessR_derivation_closed`: if `L : List Formula`, each `li` has `burgessR(A, li, C)`, and `DerivationTree L phi`, then `burgessR(A, phi, C)`.

Proof uses `untl_conj_guard` (iterated) + `untl_left_mono_thm`. Mirror for Since.

### Do NOT Need

- `G(beta) AND F(gamma) -> untl(beta, gamma)` (this was a red herring; it is NOT a theorem of the half-open guard logic)
- Any modification to the BurgessR3Maximal definition
- Any C5-specific variant of the existence theorem

## Appendix: Verification of Key Claims

### Claim: Empty set satisfies burgessR3(A, {}, C) vacuously

`burgessR3 A {} C` unfolds to `burgessRSet A {} C AND burgessRSetSince C {} A`.
`burgessRSet A {} C` unfolds to `forall beta in {}, burgessR A beta C`.
The empty set has no elements, so this is vacuously true.

### Claim: BX7+BX2 preserve burgessR

Given `burgessR(A, beta1, C)` and `burgessR(A, beta2, C)`:
- For any gamma in C: `untl(beta1, gamma) in A` and `untl(beta2, gamma) in A`
- By `untl_conj_guard`: `untl(beta1 AND beta2, gamma) in A`
- So `burgessR(A, beta1 AND beta2, C)`.

Given `burgessR(A, beta, C)` and `|- beta -> phi`:
- For any gamma in C: `untl(beta, gamma) in A`
- By `untl_left_mono_thm` (which uses BX2 left_mono_until): `untl(phi, gamma) in A`
- So `burgessR(A, phi, C)`.

These compose to handle arbitrary derivation trees with finitely many premises.
