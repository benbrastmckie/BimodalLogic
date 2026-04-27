# Research Report: Task 107 -- Design Plan for rebuild_g Removal

**Task**: 107 - Remove rebuild_g shortcut and construct g-values directly in elimination functions
**Started**: 2026-04-26
**Completed**: 2026-04-26
**Task Type**: logic

## Executive Summary

- `rebuild_g` uses the FALSE theorem `burgessR3Maximal_exists_general` (RRelation.lean:1348) to assign BurgessR3Maximal g-values to every adjacent pair after every elimination step
- The fix is to remove `rebuild_g` entirely and instead have each elimination function construct g-values for the NEW adjacent pairs it creates, using context-specific seeds
- The omega chain return type `{ chi // chi.c0 AND chi.c2' }` must be preserved, but c2' must come from the elimination functions themselves, not from rebuild_g
- This requires modifying `EliminationResult` to carry a `ChronicleInvariant` (or at minimum c2') and modifying each elimination function to produce correct g-values

## Section 1: What rebuild_g Does Exactly

### Definition (ChronicleConstruction.lean:143-151)

```lean
noncomputable def rebuild_g (chi : Chronicle) (h_c0 : chi.c0) : Chronicle :=
  { f := chi.f
    g := fun x y =>
      if h : Adjacent chi.dom x y then
        (burgessR3Maximal_exists_general (chi.f x) (chi.f y)
          (h_c0 x h.1) (h_c0 y h.2.1)).choose
      else empty
    dom := chi.dom }
```

### What it preserves/changes

| Field | Preserved? | Notes |
|-------|-----------|-------|
| `f` | YES | `rebuild_g_f: (rebuild_g chi h_c0).f = chi.f` |
| `dom` | YES | `rebuild_g_dom: (rebuild_g chi h_c0).dom = chi.dom` |
| `g` | NO | Completely replaced. For adjacent pairs: uses `burgessR3Maximal_exists_general.choose`. For non-adjacent pairs: empty set. |

### The false dependency

`rebuild_g_c2'` (line 175) proves c2' for the rebuilt chronicle by appealing to `burgessR3Maximal_exists_general.choose_spec`. Since `burgessR3Maximal_exists_general` is sorry'd and FALSE, this c2' is unsound.

### Where rebuild_g is called

Only in `omega_chain` (line 314):
```lean
let rebuilt := rebuild_g elim.val elim.c0
```

## Section 2: The omega_chain Structure

### Current definition (ChronicleConstruction.lean:307-315)

```lean
noncomputable def omega_chain (A : Set Formula) (h_mcs : SetMaximalConsistent A) :
    (n : Nat) -> { chi : Chronicle // chi.c0 AND chi.c2' }
  | 0 => <singleton_chronicle A, singleton_c0 h_mcs, singleton_c2' h_mcs>
  | n + 1 =>
    let prev := omega_chain A h_mcs n
    let pc := counterexample_enum (Nat.unpair n).2
    let elim := eliminate_potential_counterexample prev.val prev.property.1 prev.property.2 pc
    let rebuilt := rebuild_g elim.val elim.c0
    <rebuilt, rebuild_g_c0 elim.c0, rebuild_g_c2' elim.c0>
```

### How c2' flows through the chain

1. Step 0: singleton_c2' (vacuously true -- no adjacent pairs in {0})
2. Step n+1:
   - `prev.property.2` is c2' for the previous chronicle
   - `eliminate_potential_counterexample` takes `h_c2' : chi.c2'` as input (needed for C4 hard case)
   - `elim.val` is the elimination result -- a new chronicle with potentially new domain points BUT `g` unchanged from the input (`g_ext : forall a b, val.g a b = chi.g a b`)
   - `rebuild_g elim.val elim.c0` discards the elimination's g and reconstructs from scratch
   - `rebuild_g_c2' elim.c0` proves c2' using the false theorem

### What happens if we remove rebuild_g

Without rebuild_g, `omega_chain` step n+1 would return `elim.val` directly. But `elim.val` has `g_ext : forall a b, val.g a b = chi.g a b` -- the g values are UNCHANGED. This means:

- Old adjacent pairs that are still adjacent: g-values carried from previous step (OK if they had c2')
- Old adjacent pairs that are NO LONGER adjacent (because a new point was inserted between them): g-values still carry from previous step, but these pairs are no longer adjacent so c2' does not apply to them
- NEW adjacent pairs (involving the newly inserted point): g-values are whatever the old chronicle had for those pairs, which is EMPTY (since the new point wasn't in the domain before)

**Problem**: New adjacent pairs get empty g-values. Empty g-values do NOT satisfy BurgessR3Maximal (empty set is not a DCS -- it's not deductively closed).

**Solution**: Each elimination function must construct appropriate g-values for the new adjacent pairs it creates.

## Section 3: EliminationResult Structure

### Current definition (CounterexampleElimination.lean:728-757)

```lean
structure EliminationResult (chi : Chronicle) (pc : PotentialCounterexample) where
  val : Chronicle
  dom_sub : chi.dom <= val.dom
  c0 : val.c0
  f_agrees : forall x in chi.dom, val.f x = chi.f x
  g_agrees : forall a b, a in chi.dom -> b in chi.dom -> val.g a b = chi.g a b
  g_ext : forall a b, val.g a b = chi.g a b   -- STRONGER: g completely unchanged
  c5_forward_witness : ...
  c5_backward_witness : ...
  c4_forward_witness : ...
  c4_backward_witness : ...
  density_witness : ...
```

### Key observation: g_ext vs g_agrees

- `g_agrees`: g matches on OLD domain pairs (necessary for limit g to be well-defined)
- `g_ext`: g is COMPLETELY unchanged (even for new pairs involving new points)

Currently `g_ext` is the stronger statement and is the one used. After the refactor:

- `g_agrees` must be KEPT (needed by omega_chain_g_agrees and limit construction)
- `g_ext` must be REMOVED or WEAKENED (new pairs will have new g-values)

### What must be ADDED to EliminationResult

```lean
  -- New: the result chronicle satisfies c2'
  c2' : val.c2'
```

This is the crucial addition. Each elimination function must prove c2' for its result chronicle.

## Section 4: The Correct Architecture Per Elimination Type

### 4.1 C5 Elimination (Lemma 2.10 -- adding new endpoint y)

**Current behavior**: Adds point y beyond all domain points. Sets `f(y) = C` from lemma_2_4. Sets `g = chi.g` (unchanged).

**What changes**: Must also set g-values for the new adjacent pair `(x_max, y)` where x_max is the maximum of the old domain.

**Seed for g(x_max, y)**: From `lemma_2_4`, we get C with:
- eta in C (the Until eventuality)
- g_content(f(x)) <= C
- P(untl(gamma, eta)) in C

The key seed element is `eta` itself. We need to verify: does eta satisfy `burgessR(f(x_max), eta, C)` and `burgessRSince(C, eta, f(x_max))`?

Actually, the appropriate seed is the GUARD formula from the Until obligation. Lemma 2.4 gives us an MCS C where `g_content(f(x)) <= C`. The g_content relationship means `burgessR(f(x), phi, C)` holds for all phi in g_content(f(x)) -- but this is the g_content notion, not the full burgessR.

**Correct approach per Burgess**: Lemma 2.4 directly constructs B (the interval DCS) and C (the endpoint). The B satisfies R(A, B, C) by maximality. We should use this B as g(x_max, y).

**But wait**: The current `lemma_2_4` (PointInsertion.lean:183) returns only `(C, h_C_mcs, h_eta_C, h_g_sub, h_P_until)`. It does NOT return the interval set B. The Burgess proof of 2.4 constructs B as "maximal with respect to the properties that beta in B and r(A, B, C)".

**Action needed**: Enhance `lemma_2_4` to also return B satisfying BurgessR3Maximal(A, B, C). Specifically:
1. Current lemma_2_4 constructs C_0 = {gamma} U {S(alpha, beta) : alpha in A}, extends to MCS C
2. It establishes r(A, beta, C) via criterion 2.3b
3. Need to add: let B be maximal with r(A, B, C) and beta in B
4. Return both B and C, with BurgessR3Maximal(A, B, C)

This means using `burgessR3Maximal_exists_from_seed` with eta = beta (the guard) as the seed. This is VALID because:
- beta is the guard formula
- `burgessR(A, beta, C)` follows from the construction (all gamma in C have untl(beta, gamma) in A)
- `burgessRSince(C, beta, A)` needs verification -- this may require the P(untl(gamma,beta)) in C condition

**For non-adjacent pairs involving y**: Define via C3: `g(a, y) = g(a, x_max) inter f(x_max) inter g(x_max, y)` for a < x_max.

**c2' proof for (x_max, y)**: Direct from the BurgessR3Maximal returned by enhanced lemma_2_4 or `burgessR3Maximal_exists_from_seed`.

### 4.2 C5' Elimination (mirror of C5)

Mirror of 4.1. Adds point y before all domain points. New adjacent pair is `(y, x_min)`. Uses mirror of lemma_2_4 for Since.

### 4.3 C4 Elimination (Lemma 2.9 -- inserting z between x and y)

**Current behavior**: Finds MCS D with gamma.neg in D. Sets f(z) = D. Sets g = chi.g (unchanged).

**What changes**: Must also set g-values for the new adjacent pairs created by inserting z.

When z is inserted between x and y:
- If x and y were adjacent: creates pairs (x, z) and (z, y), removes pair (x, y)
- If x and y were NOT adjacent: z goes between some adjacent pair (w, w_next) where w <= x and w_next >= y... actually z goes at `(x + y) / 2`, so it goes between whatever pair was adjacent containing that point.

**For the n=0 case (x and y adjacent)**: This is exactly Burgess Lemma 2.6. We have R(f(x), g(x,y), f(y)) from c2'. Lemma 2.6 constructs:
- D_0 = {S(alpha, beta) : alpha in A, beta in B} U B U {not-delta} U {U(gamma, beta) : gamma in C, beta in B}
- D extends D_0 to an MCS
- B' maximal with B <= B' and r(A, B', D)
- B'' maximal with B <= B'' and r(D, B'', C)
- B = B' inter D inter B'' (by Lemma 2.5)

So g(x, z) = B', g(z, y) = B''. These satisfy:
- BurgessR3Maximal(f(x), B', D) -- by construction
- BurgessR3Maximal(D, B'', f(y)) -- by construction

**This is exactly `burgessR3_absorption` applied in reverse**: it SPLITS the existing R3-maximal g(x,y) into two sub-intervals.

**What already exists in the codebase**: The `burgessR3_absorption` theorem (RRelation.lean:641) goes in the other direction: given r3(A, B1, D) and r3(D, B2, C), it derives r3(A, B12, C) where B12 = B1 inter D inter B2. But we need the SPLITTING direction: given R3Maximal(A, B, C) and delta not in B, construct B', D, B'' with the split properties.

**Action needed**: Implement the splitting direction of Lemma 2.6. This is a substantial piece of new code that constructs:
1. The seed D_0 and extends to MCS D
2. B' and B'' as maximal DCS with the appropriate r-relations
3. Proof that B = B' inter D inter B'' (from Lemma 2.5)

**For non-adjacent pairs**: Define g via C3.

**c2' proof**: Direct from the splitting construction.

### 4.4 C4' Elimination (mirror of C4)

Mirror of 4.3 for Since direction.

### 4.5 Density Elimination

**Current behavior**: Inserts z = (x+y)/2 between adjacent x, y. Sets f(z) to an MCS extending g_content(f(x)). Sets g unchanged.

**What changes**: Same splitting pattern as C4 when x, y are adjacent. The splitting must produce g(x, z) and g(z, y) from g(x, y).

The density elimination is simpler than C4 because there's no specific formula constraint on f(z). The Lemma 2.6 splitting can be applied with any delta not in g(x,y) (or even without the delta constraint, just splitting for density).

**However**: For density, we may not need the full Lemma 2.6. If we simply need to insert a point z with some MCS f(z), and construct appropriate g-values, we can:
1. Pick any delta not in g(x,y) (such always exists since g(x,y) is a proper DCS, not an MCS)
2. Apply Lemma 2.6 splitting
3. Or use a simpler approach: since f(z) can be ANY MCS, construct f(z) as an MCS extending g(x,y), then g(x,z) = g(x,y) and g(z,y) = g(x,y) both have the r-relation. But this won't give R3-MAXIMALITY.

Better approach: use the full Lemma 2.6 machinery since we need R3Maximal for c2'.

### 4.6 G-propagation / H-propagation Elimination

**Current behavior**: Inserts z between adjacent x, y to propagate G(alpha). Sets g unchanged.

**What changes**: Same splitting pattern. Since z is inserted between an adjacent pair, needs the Lemma 2.6 split.

## Section 5: Changes to omega_chain

### New omega_chain definition

```lean
noncomputable def omega_chain (A : Set Formula) (h_mcs : SetMaximalConsistent A) :
    (n : Nat) -> { chi : Chronicle // chi.c0 AND chi.c2' }
  | 0 => <singleton_chronicle A, singleton_c0 h_mcs, singleton_c2' h_mcs>
  | n + 1 =>
    let prev := omega_chain A h_mcs n
    let pc := counterexample_enum (Nat.unpair n).2
    let elim := eliminate_potential_counterexample prev.val prev.property.1 prev.property.2 pc
    <elim.val, elim.c0, elim.c2'>   -- DIRECT, no rebuild_g
```

### What changes downstream

1. `omega_chain_f_eq_elim`: Currently uses `rebuild_g` unfolding. Simplifies to direct equality.
2. `omega_chain_dom_eq_elim`: Same simplification.
3. `rebuild_g_f`, `rebuild_g_dom`, `rebuild_g_c0`, `rebuild_g_c2'`: All deleted.
4. `rebuild_g` itself: Deleted.
5. `burgessR3Maximal_exists_general`: Deleted (the false theorem).

### What stays the same

- All limit-level theorems (`limit_satisfies_c5_weak`, `limit_satisfies_c4`, `limit_dom_dense`, etc.) only use `omega_chain_f_eq_elim`, `omega_chain_dom_eq_elim`, and the EliminationResult witness fields. These continue to work after the refactor.
- `limit_g` is defined by C3 at the limit (no adjacent pairs in the dense limit domain), so it's independent of finite-stage g-values.
- `limit_c3` is proved directly from the definition of `limit_g`.

## Section 6: The Critical New Code Required

### Priority 1: Lemma 2.6 Splitting (the hard part)

This is the mathematically deepest new code. Given:
- R(A, B, C) (BurgessR3Maximal(A, B, C))
- delta not in B

Construct:
- D_0 consistent
- D extending D_0 to MCS
- B' maximal with B <= B' and R(A, B', D)
- B'' maximal with B <= B'' and R(D, B'', C)
- Proof: B = B' inter D inter B''

**Estimated complexity**: ~200-300 lines. The consistency proof for D_0 follows Burgess's argument using A4a, A5a, A3a.

**Prerequisite**: The BX axiom counterparts of A4a, A5a, A3a, A7a must exist in the codebase. Check:
- A4a -> BX4? (connect_future): `untl(p,q) AND neg(untl(p,r)) -> untl(q AND neg(r), q)` -- this is `Axiom.self_split_until` or similar
- A5a -> BX5 (self_accum_until): `untl(p,q) -> untl(p, q AND untl(p,q))`
- A3a -> BX3 (connect_future): `p AND U(q,r) -> U(q AND S(p,r), r)` -- this is the cross-operator axiom

### Priority 2: Enhanced lemma_2_4 (return B along with C)

Either:
- Modify `lemma_2_4` to also return B with BurgessR3Maximal(A, B, C)
- Or add a wrapper that takes lemma_2_4's output C and calls `burgessR3Maximal_exists_from_seed`

The second approach is cleaner since `burgessR3Maximal_exists_from_seed` already exists and is proved.

**Seed requirement**: Need eta satisfying `burgessR(A, eta, C)` AND `burgessRSince(C, eta, A)`.

From lemma_2_4's construction:
- beta (the guard formula of the Until) satisfies `burgessR(A, beta, C)` by the r(A, beta, C) established in the proof
- Need `burgessRSince(C, beta, A)`: for all gamma in A, `snce(beta, gamma) in C`. This follows from the construction of C_0 which contains `{S(alpha, beta) : alpha in A}` -- wait, that's Burgess's criterion 2.3b applied. Under Burgess's definition, r(A, beta, C) means: for all gamma in C, untl(beta, gamma) in A. The SINCE direction (for all alpha in A, snce(beta, alpha) in C) is the equivalent condition by Lemma 2.3.

So `burgessRSince(C, beta, A)` holds by Lemma 2.3 equivalence. This needs to be proved in Lean.

### Priority 3: Modify EliminationResult and all elimination functions

1. Add `c2' : val.c2'` field to EliminationResult
2. Remove `g_ext` field (or weaken to g_agrees)
3. Modify each elimination function to:
   a. Construct proper g-values for new adjacent pairs
   b. Prove c2' for the result chronicle
4. For the "not actual counterexample" branch in each case: return identity with `h_c2'` inherited

## Section 7: Risks and Mitigations

### Risk 1: Lemma 2.6 splitting may require axioms not yet formalized

**Mitigation**: Check which BX axioms correspond to Burgess A3a-A7a. The codebase already has BX4 (connect_future), BX5 (self_accum_until), BX6 (absorb_until), BX7 (split_until). A3a is the cross-operator axiom involving S within U -- need to verify this exists.

### Risk 2: The Since direction of the seed may be hard to prove

**Mitigation**: Lemma 2.3 equivalence (criterion 2.3a iff 2.3b) should already be partially proved in the codebase. Check for `burgessR_iff_burgessRSince` or similar.

### Risk 3: g_agrees may be harder to prove when g is modified for new pairs

**Mitigation**: New pairs only involve the newly inserted point, which was not in the old domain. So `g_agrees` (which ranges over OLD domain pairs) is unaffected. The key insight: `g_agrees : forall a b, a in chi.dom -> b in chi.dom -> val.g a b = chi.g a b` -- since the new point is NOT in chi.dom, this is trivially satisfied for old-domain pairs as long as we don't change g on those pairs.

### Risk 4: C3 at finite stages

**Observation**: The current approach does NOT maintain C3 at finite stages. The `ChronicleInvariant` structure includes hc3, but the omega chain currently only maintains c0 and c2'. The limit_g is defined by the C3 formula directly, making finite-stage C3 unnecessary for the limit.

However, if each elimination function needs to produce a chronicle with full ChronicleInvariant (including C3), this is additional work. The answer is: we do NOT need C3 at finite stages. We only need c0 and c2'. The C4 elimination functions use c2' for the hard case (finding gamma not in g(x,y)), and c0 for MCS properties. C3 is only needed at the limit.

## Section 8: Implementation Order

1. **Phase A**: Implement Lemma 2.6 splitting in RRelation.lean or a new file
   - D_0 consistency proof
   - D construction (MCS extension)
   - B', B'' construction (maximal DCS with appropriate r-relations)
   - B = B' inter D inter B'' (Lemma 2.5)
   - ~200-300 lines

2. **Phase B**: Enhance C5/C5' elimination to construct g-values
   - Use `burgessR3Maximal_exists_from_seed` with beta as seed
   - Prove burgessR(A, beta, C) from the construction
   - Prove burgessRSince(C, beta, A) via Lemma 2.3 equivalence
   - Set g(x_max, y) = B from the seed-based construction
   - Prove c2' for the result
   - ~100-150 lines per direction

3. **Phase C**: Enhance C4/C4' elimination to construct g-values using Lemma 2.6
   - Apply splitting to the adjacent pair containing the inserted point
   - Set g(x, z) = B', g(z, y) = B''
   - Prove c2' for all new adjacent pairs
   - ~100-150 lines per direction

4. **Phase D**: Enhance density and g-prop elimination similarly
   - Density: Lemma 2.6 splitting
   - G-prop: Lemma 2.6 splitting
   - ~100-150 lines per direction

5. **Phase E**: Modify EliminationResult, omega_chain, remove rebuild_g
   - Add c2' to EliminationResult
   - Remove g_ext (or weaken)
   - Delete rebuild_g and associated lemmas
   - Delete burgessR3Maximal_exists_general
   - Update omega_chain to use elim.val directly
   - Simplify bridge lemmas
   - ~50-100 lines of changes

6. **Phase F**: Verify build, fix downstream breakage
   - Ensure all limit-level theorems still compile
   - Fix any references to deleted lemmas
   - ~50-100 lines of fixes

**Total estimate**: ~800-1200 lines of new/modified code.

## Appendix A: Key Codebase Locations

| Entity | File | Line |
|--------|------|------|
| `rebuild_g` | ChronicleConstruction.lean | 143 |
| `rebuild_g_c2'` | ChronicleConstruction.lean | 175 |
| `omega_chain` | ChronicleConstruction.lean | 307 |
| `EliminationResult` | CounterexampleElimination.lean | 728 |
| `eliminate_potential_counterexample` | CounterexampleElimination.lean | 767 |
| `eliminate_C5_counterexample` | CounterexampleElimination.lean | 167 |
| `eliminate_C4_counterexample` | CounterexampleElimination.lean | 304 |
| `burgessR3Maximal_exists_general` (FALSE) | RRelation.lean | 1345 |
| `burgessR3Maximal_exists_from_seed` | RRelation.lean | 1184 |
| `burgessR3_absorption` | RRelation.lean | 641 |
| `lemma_2_4` | PointInsertion.lean | 183 |
| `BurgessR3Maximal` | ChronicleTypes.lean | 307 |
| `ChronicleInvariant` | ChronicleTypes.lean | 505 |

## Appendix B: The Burgess Proof Structure (for reference)

The Burgess completeness proof (Section 2) has this dependency structure:

```
Lemma 2.3 (r-relation equivalence)
  -> Lemma 2.4 (C5 endpoint construction, uses 2.3 + 2.2)
  -> Lemma 2.5 (absorption, B = B' inter D inter B'')
  -> Lemma 2.6 (C4 splitting, uses 2.5 + A4a + A5a + A3a)
  -> Lemma 2.7 (C5 interval case, uses A5a + A7a + A3a)
  -> Lemma 2.8 (C5 nested case, uses A7a + A3a)
  -> Lemma 2.9 (C4 counterexample elimination, uses 2.6 inductively)
  -> Lemma 2.10 (C5 counterexample elimination, uses 2.4/2.7/2.8)
  -> Omega chain + Claim 2.11 (truth lemma)
```

The codebase already has: 2.2, 2.3 (partial), 2.4 (partial), 2.5 (as burgessR3_absorption).
Missing or incomplete: 2.6 (splitting direction), 2.7, 2.8.
