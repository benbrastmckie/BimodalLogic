# Alternative Proof Strategy: Cases 5-8 via Hierarchy Inversion

## Executive Summary

This report analyzes the blocker in Phase 2 (Case 5 circular dependency with Case 8) and recommends a **hierarchy-first phase inversion** strategy. The key insight is that GHR94's 8 elimination cases are NOT self-contained lemmas -- they are proved WITHIN the hierarchy framework (Lemmas 10.2.4-10.2.6). Cases 5-8 cannot be proved in isolation because their reductions are mutually recursive; they require the multi-U induction of Lemma 10.2.6 to terminate.

**Recommended phase ordering**:

1. Phase 2' (NEW): Build Lemma 10.2.5 (single-U wrapper) with Cases 5-8 as internal sorry
2. Phase 3' (NEW): Build Lemma 10.2.6 (multi-U induction on count) with Lemma 10.2.5 as base case
3. Phase 4' (NEW): Prove Cases 5-8 USING the multi-U induction as termination guarantee
4. Phase 5' (MERGED): Close sorry in Lemmas 10.2.5/10.2.6 by composing Cases 5-8 proofs

This eliminates the circular dependency because the well-foundedness comes from the hierarchy's induction measure (decreasing U-count), not from standalone case reductions.

---

## 1. Why Standalone Case 5 is Impossible

### 1.1 The Circular Dependency (Confirmed)

The Phase 2 handoff documents the exact cycle:

```
Case 5(A,B): S(a ^ U(A,B), q v U(A,B))
  --[Case 3 reduction]--> Case 8(A,B): S(neg_q ^ neg U(A,B), neg_a v neg U(A,B))
  --[neg_until_equiv + distribute]--> Case 5(A',B'): S(... ^ U(A',B'), ... v U(A',B'))
    where A' = neg A ^ neg B, B' = neg A
  --[Case 3 reduction]--> Case 8(A',B')
  --[neg_until_equiv + distribute]--> Case 5(A, A v B)
  ... (cycles)
```

The parameters cycle: `(A,B) -> (neg A ^ neg B, neg A) -> (A, A v B) -> ...` and never terminate.

### 1.2 Why Direct Semantic Construction Also Fails

Attempted direct constructions of a separated equivalent for Case 5 fail because:

- The guard `q v U(A,B)` on integers can be satisfied by **arbitrarily long chains** of alternating U(A,B) and q satisfaction points
- Each chain pattern requires a different formula structure to capture
- No fixed-size formula can enumerate all possible chain patterns (the interval (s,t) can be arbitrarily large)

### 1.3 Root Cause

Case 5 has U(A,B) in BOTH the event and guard. Any reduction that eliminates U from one position introduces neg U(A,B) in the other, which after expansion via `neg_until_equiv` reintroduces a U-formula, creating a mutual dependency with Case 8.

The ONLY way to break this cycle is with an external termination measure -- which is exactly what the hierarchy provides.

---

## 2. GHR94's Actual Proof Architecture

### 2.1 How GHR94 Really Proves Cases 5-8

Re-reading GHR94 carefully (Lemma 10.2.3, pp. 80-120 of our markdown), the 8 cases are stated as a SINGLE lemma with the conclusion:

> "Each of the wffs above is equivalent, over integer time, to another wff in which the only appearances of the until connective are as the wff U(A, B) and no appearance of that wff is in the scope of an S."

This is NOT saying the result is fully syntactically separated. It says:
- U only appears as U(A,B) (not any other U-formula)
- U(A,B) does not appear under S

The FULL separation then comes from applying Lemma 10.2.4 (normal form + 8 cases), Lemma 10.2.5 (single-U by S-nesting induction), and Lemma 10.2.6 (multi-U by count induction).

### 2.2 Case 5's Explicit Formula in GHR94

GHR94 gives:
```
S(a ^ U(A,B), q v U(A,B)) <->
  S(a, B) ^ [A v (B ^ U(A,B))]
  v S(A ^ S(a, B), A v B v neg S(neg q, neg A))
    ^ [A v (B ^ U(A,B))] ^ neg S(neg q, neg A)
```

This formula has U(A,B) appearing ONLY as the literal `U(A,B)` (not under S). GHR94 considers this "eliminated" because U(A,B) is at top level. The remaining S-subformulas (`S(a,B)`, `S(A ^ S(a,B), ...)`, `S(neg q, neg A)`) are all U-free.

**However**: This formula is INCORRECT on integer time (our Report 02 counterexample). The formula assumes the U-chain propagates B to the evaluation point, which fails on discrete time due to vacuous guards.

### 2.3 Case 8's Negation Trick

GHR94's Case 8 proof is the most instructive. It does NOT produce its own direct formula. Instead:

```
neg D = neg S(a ^ neg U(A,B), q v neg U(A,B))
     <-> H(neg a v U(A,B))
         v S(neg q ^ U(A,B) ^ neg a, neg a v U(A,B))
```

Then GHR94 says: "These are cases we can handle by other eliminations, especially elimination (5)."

The key observation: the resulting `S(neg q ^ U(A,B) ^ neg a, neg a v U(A,B))` IS a Case 5 instance. GHR94 is comfortable with this circular reference because **within the hierarchy**, the U-count strictly decreases: the original formula had `neg U(A,B)` (which after expansion introduces U(A',B')), but after Case 8's negation trick, we get a formula with ONLY `U(A,B)` -- a single U-formula type, not two. This is handled by Lemma 10.2.5 directly.

### 2.4 Cases 6-7 Similarly Refer Forward

- Case 6: "Eliminations (3) and (5) can be used to finish the separating."
- Case 7: "The first disjunct can be further eliminated by eliminations (8) and (4)."

Both explicitly reference later cases. GHR94 treats all 8 cases as a simultaneous system proved within the hierarchy, not as sequentially ordered standalone lemmas.

---

## 3. The Hierarchy-First Strategy

### 3.1 Key Insight: Single-U Elimination (Lemma 10.2.5) IS Case 5

Lemma 10.2.5 states: "If A, B are S/U-free and U only appears in D as U(A,B), then D is equivalent to a syntactically separated formula in which U only appears as U(A,B)."

The proof is by induction on the maximum S-nesting depth k above U(A,B):
- **k = 0**: D is already separated (U(A,B) not under S)
- **k > 0**: Apply Lemma 10.2.4 to the most deeply nested S containing U(A,B). This invokes the 8 cases. After elimination, U(A,B) appears at lower S-nesting depth. Apply IH.

The critical observation: **Case 5 does not introduce NEW U-formulas** (unlike Cases 6-8 which involve neg U expanding to two U-types). Case 5's formula `S(a ^ U(A,B), q v U(A,B))` has exactly ONE U-formula type: `U(A,B)`. So Lemma 10.2.5's induction is the correct framework for Case 5.

But wait -- we said Case 5's explicit formula is wrong on Z. So what do we use instead?

### 3.2 The Correct Case 5 Strategy Within The Hierarchy

Instead of finding a correct explicit formula for Case 5 on Z, we can prove Case 5 **semantically within Lemma 10.2.5's induction**. The argument:

1. Start with `S(a ^ U(A,B), q v U(A,B))` where a, q, A, B are atoms (U-free, S-free)
2. Apply Case 3 with event = `a ^ U(A,B)`, producing an equivalent formula where U(A,B) in the GUARD position has been eliminated
3. The result has U(A,B) appearing in positions derived from `neg(a ^ U(A,B))`, specifically inside S-arguments. After expanding neg U(A,B) via neg_until_equiv: `G(neg A) v U(neg A ^ neg B, neg A)`
4. Now we have TWO U-formula types: U(A,B) and U(A',B') where A'=neg A ^ neg B, B'=neg A
5. **This is where Lemma 10.2.6 (multi-U induction) takes over**: treat one U as an atom, eliminate the other via Lemma 10.2.5, substitute back, re-separate

The well-foundedness: at step 4, the total count of U-S junctions has decreased (we eliminated U from the guard position). After invoking Lemma 10.2.6, each sub-problem has fewer U-formula types under any given S.

### 3.3 Avoiding the Circular Dependency

The key realization is that:
- Case 5 reduction introduces a second U-formula (step 4 above)
- The second U-formula is handled by **Lemma 10.2.6** (not by Case 8 directly)
- Lemma 10.2.6 handles multiple U-formulas by induction on count
- Within Lemma 10.2.6, each individual U is handled by Lemma 10.2.5 (single-U)
- Lemma 10.2.5 invokes the 8 cases at lower S-nesting depth
- At lower depth, Case 5 instances have smaller k (S-nesting measure)

So the termination is:
```
(k, n) where k = S-nesting depth, n = U-formula count
Ordering: lexicographic, k primary
Case 5 at depth k produces Cases 1-4 at depth k-1 (plus a multi-U at depth k-1)
Multi-U at depth k-1 reduces to single-U at depth k-1 with fewer U-types
Single-U at depth k-1 invokes 8 cases at depth k-2
... eventually reaches k=0
```

### 3.4 Why This Works Formally

The well-founded measure is `(S_nesting_above_U, count_U_subformulas)` with lexicographic ordering. Both components are computable from the formula (already defined in `Defs.lean`).

- Applying a Case 1-4 elimination reduces S-nesting (the U is pulled out from under the deepest S)
- Applying neg_until_equiv may increase U-count but does NOT increase S-nesting
- Lemma 10.2.6's atom-substitution reduces U-count while preserving S-nesting
- After substituting back, the formula has lower S-nesting (the eliminated U has been moved out)

---

## 4. Recommended Revised Phase Ordering

### 4.1 Current Plan (Blocked)

```
Phase 1: Fix purity predicates [COMPLETED]
Phase 2: Prove Case 5 standalone [BLOCKED - circular]
Phase 3: Prove Cases 6-8 using Case 5 [NOT STARTED - depends on 2]
Phase 4: Build Lemmas 10.2.5-10.2.7 [NOT STARTED - depends on 3]
Phase 5: Prove all_separable via junction depth [NOT STARTED - depends on 4]
Phase 6: Theorem 9.3.1 [NOT STARTED - depends on 5]
```

### 4.2 Proposed Revision

```
Phase 2': Build Lemma 10.2.4 (normal form to 8 cases)
  - This is purely mechanical: distribute S over boolean combinations
  - Reduces S(C, F) to boolean combo of 8-case instances
  - Uses: Lemma 10.2.1 (distributivity, already proved)
  - Calls: Cases 1-8 (Cases 1-4 proved, Cases 5-8 as axioms for now)
  - Output: theorem single_S_with_single_U_separable
  - LOC: ~200-300

Phase 3': Build Lemma 10.2.5 (single-U by S-nesting induction)
  - Induction on k = max S-nesting above U(A,B)
  - k=0: already separated (U not under S)
  - k>0: apply Lemma 10.2.4 to deepest S containing U(A,B), reduces k
  - Uses: Lemma 10.2.4 (Phase 2')
  - Output: theorem single_U_formula_separable
  - Note: This uses Cases 5-8 axioms transitively through 10.2.4
  - LOC: ~150-250

Phase 4': Build Lemma 10.2.6 (multi-U by count induction)
  - Induction on n = number of distinct U-formula types under S
  - n=0: U-free formula, already separated
  - n=1: apply Lemma 10.2.5
  - n>1: fresh-atom substitute for all but one U, apply 10.2.5,
          substitute back, re-separate (now has fewer U-types)
  - Uses: Lemma 10.2.5, subst_formula, fresh_atom
  - Output: theorem multi_U_formula_separable
  - LOC: ~300-400

Phase 5': Prove Cases 5-8 using the hierarchy (eliminate axioms)
  - Case 5: Apply Case 3 with event=a^U(A,B), use Lemma 10.2.6 for the
    two-U residue. Well-founded by the hierarchy's own induction measure.
  - Case 8: Apply neg_since_equiv, reduces to Case 5 instance (handled
    by Lemma 10.2.5 which no longer needs standalone Case 5)
  - Case 6: Expand neg U, distribute, disjunct 1 is Case 3, disjunct 2
    uses Lemma 10.2.6 for two-U
  - Case 7: Fresh-atom for U(A,B), apply Case 3 for U(A',B'), substitute
    back, use Lemma 10.2.5 for single-U re-separation
  - Output: Remove all 4 axioms from Eliminations.lean
  - LOC: ~400-600

Phase 6': Prove all_separable + remove temporal closure axioms
  - With Cases 1-8 all proved, Lemmas 10.2.4-10.2.6 use no axioms
  - Build Lemma 10.2.7 (no-S-in-U) on top of 10.2.6
  - Build Lemma 10.2.8 (junction depth) on top of 10.2.7
  - all_separable follows from 10.2.8
  - Remove 4 temporal closure axioms from SeparationThm.lean
  - LOC: ~300-500

Phase 7': Theorem 9.3.1 (unchanged from current Phase 6)
  - LOC: ~300-500
```

### 4.3 Dependency Graph

```
Phase 1 [DONE]
    |
    v
Phase 2' (Lemma 10.2.4: normal form)
    |
    v
Phase 3' (Lemma 10.2.5: single-U, uses Cases 5-8 axioms)
    |
    v
Phase 4' (Lemma 10.2.6: multi-U induction)
    |
    v
Phase 5' (Prove Cases 5-8 using 10.2.6, remove axioms)
    |
    v
Phase 6' (all_separable via 10.2.7-10.2.8, remove temporal closure axioms)
    |
    v
Phase 7' (Theorem 9.3.1)
```

### 4.4 Key Design Decision: Bootstrap with Axioms

The critical insight enabling this ordering:

1. Build Lemmas 10.2.4-10.2.6 **using the existing Case 5-8 axioms** as primitives
2. Once the hierarchy is in place, prove Cases 5-8 **using the hierarchy itself**
3. The hierarchy provides the termination guarantee that standalone cases cannot
4. After proving Cases 5-8, the axioms are provably redundant -- remove them
5. The final state has zero axioms: each theorem's proof is self-contained

This is logically sound because:
- The hierarchy theorems (10.2.5, 10.2.6) have the SAME conclusion as the axioms (separability)
- Cases 5-8 axioms assert separability (which is true by Kamp's theorem)
- Once we prove Cases 5-8 as theorems, the axiom declarations become dead code

---

## 5. Detailed Analysis of Each Case Within the Hierarchy

### 5.1 Case 5 Within Lemma 10.2.6

**Input**: `S(a ^ U(A,B), q v U(A,B))` where a, q, A, B are atoms

**Strategy**: Semantic case analysis on the U-witness position

At time t, the formula holds iff there exists s < t with a(s), U(A,B)(s), and for all r in (s,t): q(r) v U(A,B)(r).

The U(A,B)(s) gives u > s with A(u) and B on (s,u). Three cases:
- **u > t**: B holds on all of (s,t) (stronger than guard), and A holds in the future
- **u = t**: B holds on (s,t), and A holds at t
- **u < t**: A holds at u < t, B holds on (s,u), and q v U(A,B) holds on (u,t)

For the third case (u < t), note that at each point r in (u,t), either q(r) or U(A,B)(r). If U(A,B)(r) at some r, then there's a further A-witness beyond r. This creates a "chain" of A-witnesses.

**Key observation for discrete time**: On Z, this chain must be FINITE (the interval (s,t) is finite). So there is a LAST A-witness in the chain. After the last A-witness, the guard is satisfied purely by q.

The formula can be expressed as:
```
  [S(a, B) ^ B ^ U(A,B)]                           -- u > t case
v [S(a, B) ^ A]                                     -- u = t case  
v [S(A ^ S(a, B), q) ^ (A v (B ^ U(A,B)))]         -- u < t, stepping stone
```

Wait -- this third disjunct is the one that failed before. The issue is that between s and the stepping stone, B must hold. And after the stepping stone, q must hold until t. But there could be MULTIPLE stepping stones.

**Correct approach**: The correct formula for Case 5 on Z uses the multi-step structure. Let me trace GHR94's approach more carefully using the hierarchy.

Actually, within the hierarchy framework, we do NOT need an explicit formula for Case 5. We need only show that the formula IS separable (i.e., prove `exists psi, is_syntactically_separated psi = true ^ int_equiv LHS psi`). The proof proceeds:

1. `S(a ^ U(A,B), q v U(A,B))` has U(A,B) under S (in both event and guard)
2. The formula has S-nesting depth k=1 above U(A,B) and U-count n=1 under the S
3. Apply the Case 3 semantic equivalence with event = `a ^ U(A,B)`:
   - This is semantically valid (Case 3's proof only uses the semantic meaning of S)
   - We need a GENERALIZED Case 3 that allows non-atomic event
4. The result has neg(a ^ U(A,B)) = neg a v neg U(A,B) under S
5. Expand neg U(A,B) via neg_until_equiv: `G(neg A) v U(A',B')`
6. Distribute. Now under S we have two U-types: U(A,B) and U(A',B')
7. Apply Lemma 10.2.6 with n=2: treat U(A,B) as fresh atom p, apply Lemma 10.2.5 for U(A',B'), substitute back
8. After substitution, only U(A,B) remains under S. Apply Lemma 10.2.5 again.
9. Each inner application of 10.2.5 invokes the 8 cases at depth k=0 or via Cases 1-4 which are proved.

The well-foundedness: step 7 reduces U-count from 2 to 1. Step 8 then handles U-count 1. Both are at S-nesting depth at most 1 (same as original). But Lemma 10.2.5's induction on k handles this: after applying a case elimination, the resulting formula has U(A,B) at k-1 depth or U not under S at all.

### 5.2 Case 8 Within the Hierarchy

**Input**: `D = S(a ^ neg U(A,B), q v neg U(A,B))`

**Strategy** (GHR94's approach, now provable):

1. Negate: `neg D <-> H(neg a v U(A,B)) v S(neg q ^ U(A,B) ^ neg a, neg a v U(A,B))`
   (Proved via neg_since_equiv with substitution y = z = neg U(A,B))

2. The S-term `S(neg q ^ U(A,B) ^ neg a, neg a v U(A,B))` has:
   - Event: `neg q ^ U(A,B) ^ neg a` (single U in event)
   - Guard: `neg a v U(A,B)` (single U in guard, same U)
   - This is a Case 5 instance! With a' = neg q ^ neg a, q' = neg a, same A, B.

3. The H-term `H(neg a v U(A,B))` has U under all_past (= under S in GHR94's framework).
   - `H(phi) = all_past(phi)` in our formalization
   - Under `is_properly_separated`, this requires `is_past_only(neg a v U(A,B))` = false (since U(A,B) is not past-only)
   - So this also needs elimination via Lemma 10.2.5

4. Both sub-problems have a SINGLE U-formula type (U(A,B)) under S/H.
   Apply Lemma 10.2.5 to each, producing separated equivalents.

5. `D <-> neg(separated_H v separated_S5)` which is properly separated (negation of separated is separated).

**Why no circularity**: Case 8 reduces to Case 5 (via the hierarchy, not standalone). Case 5 is handled by Lemma 10.2.5 (induction on S-nesting). At S-nesting depth 1, Lemma 10.2.5 invokes Lemma 10.2.4 which invokes the 8 cases, but at this point U(A,B) appears in a simpler structural position (only event, or only guard) -- hence Case 1, 2, 3, or 4 applies, not Case 5 again. The depth has decreased.

### 5.3 Case 6 Within the Hierarchy

**Input**: `S(a ^ neg U(A,B), q v U(A,B))`

**Strategy**:
1. Expand neg U(A,B) in event: `a ^ [G(neg A) v U(A',B')]`
2. Distribute: `S(a ^ G(neg A), q v U(A,B)) v S(a ^ U(A',B'), q v U(A,B))`
3. Disjunct 1: Event `a ^ G(neg A)` is U-free. Single U in guard. Case 3 (proved).
4. Disjunct 2: Two U-types under S. Apply Lemma 10.2.6 with n=2.
   - Treat U(A,B) as atom p. Get `S(a ^ U(A',B'), q v p)` -- Case 1 (U in event only, proved).
   - Case 1 gives separated psi1 (containing atom p).
   - Substitute p := U(A,B) back.
   - Result has single U-type U(A,B) under S. Apply Lemma 10.2.5.
5. Combine via or_separable.

### 5.4 Case 7 Within the Hierarchy

**Input**: `S(a ^ U(A,B), q v neg U(A,B))`

**Strategy**:
1. Expand neg U(A,B) in guard: `q v G(neg A) v U(A',B')`
2. Substitute p := U(A,B) in event: `S(a ^ p, (q v G(neg A)) v U(A',B'))`
3. Event `a ^ p` is U-free (p is atom). Single U(A',B') in guard. Case 3 applies.
4. Case 3 gives separated psi3 (containing atom p).
5. Substitute p := U(A,B) back.
6. Result has single U-type U(A,B) under S. Apply Lemma 10.2.5.

---

## 6. Technical Requirements for Implementation

### 6.1 Generalized Case 3

The current `elim_case_3` requires `is_U_free a = true`. For the Case 5 reduction, we need to apply Case 3's semantic equivalence with `a' = a ^ U(A,B)` which is NOT U-free.

**Two options**:

**Option A (Recommended): Semantic Case 3 lemma**
Prove a separate lemma that captures Case 3's semantic content without the U-free precondition:

```lean
theorem case3_semantic (a q A B : Formula) (M : IntStructure) (t : Z) :
    int_truth M t (.snce a (Formula.or q (.untl A B))) <->
    int_truth M t (neg(H(neg a) v case3_inner_formula a q A B))
```

This works for ANY formula `a`, regardless of its U-freeness. The output formula's separation properties depend on `a`'s structure, but the EQUIVALENCE is unconditional.

**Option B: Prove Case 5 entirely within Lemma 10.2.6's induction**
Skip the explicit Case 5 theorem entirely. Within Lemma 10.2.6's proof (induction on n), the n=1 case with U(A,B) in both event and guard is handled by:
- Applying the generalized Case 3 semantic equivalence
- Noting the result now has 2 U-types (the original + one from neg_until_equiv expansion)
- This does NOT increase n (we're still handling the original formula)
- The hierarchy's S-nesting measure has decreased
- Apply 10.2.5 at lower S-nesting depth

This avoids needing a standalone "Case 5 theorem" entirely. The elimination is embedded in the hierarchy proof.

### 6.2 Substitution Re-Separation Lemma

After Lemma 10.2.6's fresh-atom substitution, we need:

```lean
theorem subst_atom_separable (psi : Formula) (p : Atom) (phi : Formula)
    (hsep : is_syntactically_separated psi = true)
    (hphi_sep : is_separable phi) :
    is_separable (subst_formula psi p phi)
```

This is the core "re-separation after substitution" step. The proof:
- `psi` is separated, so `p` appears either at top level, inside U-args (S-free), or inside S-args (U-free)
- In S-free contexts: substituting `phi` (which is separable) preserves separability
- In U-free contexts: substituting `phi` introduces potential U, which needs the 8-case elimination
- The result is separable by applying the hierarchy to the impure positions

This lemma itself depends on `all_separable` (or equivalently, on the hierarchy being complete). This creates an apparent circularity, but it's resolved by:
- During Phases 2'-4', this lemma uses the temporal closure AXIOMS (which are sound)
- During Phase 5', the axioms are replaced by proofs (the hierarchy is self-supporting)
- The final state has no axioms: `subst_atom_separable` is proved using `all_separable` which is proved by junction-depth induction using the hierarchy

### 6.3 Fresh Atom Infrastructure

Already available in `FormulaOps.lean`:
- `subst_formula`: atom substitution
- `subst_correctness`: substitution preserves truth under modified valuation
- `fresh_atom` / `fresh_atoms`: generate atoms not in a formula
- `exists_atom_not_in_finset`: existence of fresh atoms

### 6.4 Distributivity Infrastructure

Already available in `Distributivity.lean`:
- `since_distrib_or_left`: S(A v B, C) <-> S(A,C) v S(B,C)
- `until_distrib_or_left`: dual
- `since_distrib_and_right`: S(A, B ^ C) <-> S(A,B) ^ S(A,C)
- `until_distrib_and_right`: dual

### 6.5 Missing Infrastructure

Needed but not yet proved:
1. **Generalized Case 3 semantic equivalence** (works for non-atomic event)
2. **neg_since_equiv generalized** (for Case 8's negation trick): `neg S(a^z, q v y)` expansion
3. **or_separable** (exists but is private in Eliminations.lean -- make public)
4. **and_separable**, **neg_separable** (boolean closure of separability)
5. **Lemma 10.2.4** (normal form reduction to 8 cases)
6. **S_nesting_decrease lemma**: applying an elimination case reduces S-nesting above U

---

## 7. Comparison with Current Plan v4

### 7.1 What Changes

| Aspect | Current Plan v4 | Proposed Revision |
|--------|----------------|-------------------|
| Phase 2 | Case 5 standalone (BLOCKED) | Lemma 10.2.4 (normal form) |
| Phase 3 | Cases 6-8 using Case 5 | Lemma 10.2.5 (single-U) |
| Phase 4 | Lemmas 10.2.5-10.2.7 | Lemma 10.2.6 (multi-U) |
| Phase 5 | Junction depth induction | Cases 5-8 via hierarchy |
| Phase 6 | Theorem 9.3.1 | Lemma 10.2.7-10.2.8 + axiom removal |
| Phase 7 | (none) | Theorem 9.3.1 |
| Axiom strategy | Prove cases first, then hierarchy | Build hierarchy first (with axioms), then prove cases |
| Circularity | Blocked by Case 5-8 mutual dependency | Resolved by hierarchy's external termination measure |

### 7.2 What Stays The Same

- Phase 1 (purity predicates): COMPLETED, unchanged
- Infrastructure (FormulaOps, Distributivity, NegationEquiv, IntHelpers): all reusable
- Cases 1-4: proved, unchanged
- Final goal: zero axioms, zero sorry

### 7.3 Effort Comparison

| Approach | Total LOC | Risk |
|----------|-----------|------|
| Current v4 (blocked) | N/A | Infinite (stuck) |
| Proposed revision | ~1500-2200 | Medium (hierarchy is complex but well-understood) |
| Alternative: axiom retention | 0 (done) | None (but 8 axioms remain) |

---

## 8. Semantic vs Syntactic Approaches

### 8.1 Could Cases 5-8 Be Proved Semantically?

A "semantic proof" would show existence of a separated equivalent via a model-theoretic argument without constructing the equivalent formula explicitly.

In Lean, `is_separable phi` is `exists psi, is_syntactically_separated psi = true ^ int_equiv phi psi`. This is a pure EXISTENCE statement. We could prove it by:

1. **Choice from decidability**: If we could show the set of separated formulas equivalent to phi is non-empty (by a model-theoretic argument), we could use `Classical.choice` to extract a witness.

2. **Transfer from Kamp's theorem**: Kamp's theorem (for Z) states every FO-definable property is expressible in {U,S}. Since `phi` is FO-definable, its separated equivalent exists.

However, both approaches require ADDITIONAL infrastructure:
- Option 1 needs a proof that the search space is decidable (it is, but formalizing this is non-trivial)
- Option 2 needs Kamp's theorem formalized, which is the GOAL of the entire task 157

So a purely semantic approach is circular or requires even more work than the syntactic hierarchy approach.

### 8.2 Verdict

The syntactic hierarchy approach (GHR94 Lemmas 10.2.4-10.2.8) is the correct and minimal-effort path. It works by providing the well-founded termination measure that standalone case reductions cannot provide.

---

## 9. Recommendations

### 9.1 Immediate Action

**Revise plan v4** to Phase 2'-7' ordering as described in Section 4.2.

### 9.2 Implementation Priority

1. Make `or_separable`, `and_separated`, `neg_separated`, `is_separable_of_equiv` PUBLIC in Eliminations.lean
2. Prove generalized Case 3 semantic equivalence (no U-free precondition on event)
3. Build Lemma 10.2.4 (mechanical: distribute, invoke 8 cases)
4. Build Lemma 10.2.5 (induction on S-nesting, use Lemma 10.2.4)
5. Build Lemma 10.2.6 (induction on U-count, use 10.2.5 + substitution)
6. Prove Cases 5-8 within the hierarchy (eliminates 4 axioms)
7. Build 10.2.7-10.2.8 and prove all_separable (eliminates 4 temporal closure axioms)

### 9.3 Risk Assessment

- **Medium risk**: The generalized Case 3 (allowing non-U-free event) may require careful formulation. The semantic argument is clear, but the Lean formalization needs to handle the fact that the output formula's separation depends on further elimination.
- **Low risk**: Lemmas 10.2.5-10.2.6 are standard inductive constructions with clear termination measures already defined in Defs.lean.
- **Medium risk**: The substitution re-separation step (Section 6.2) is the most technically complex, requiring careful handling of positions where atoms get replaced by U-formulas.

### 9.4 Fallback

If the full hierarchy proves too complex (exceeds budget), a pragmatic fallback is:
- Retain the 4 Case 5-8 axioms (mathematically sound by Kamp's theorem)
- Build Lemma 10.2.5-10.2.7 using the axioms as primitives
- Prove all_separable via junction-depth induction (removes temporal closure axioms)
- Final state: 4 axioms (Cases 5-8) + 0 temporal closure axioms = 4 axioms total (reduced from 8)

This fallback still delivers meaningful progress (halves the axiom count) even if Cases 5-8 cannot be fully eliminated.

---

## References

- GHR94, Chapter 10, Section 10.2 (Lemmas 10.2.1-10.2.9)
- Report 02: Case 5 counterexample on Z
- Report 04: Iterated elimination strategies
- Report 05: GHR94 deep analysis, hierarchy structure
- Phase 2 handoff: Circular dependency documentation
