# Teammate B Findings: Reynolds 1994 Fidelity Check

**Task**: 129 — weak_reflexive_completeness_conservative_extension
**Date**: 2026-05-14
**Angle**: Faithful comparison of formalization against Reynolds 1994 paper
**Confidence Level**: HIGH

## Key Findings

The formalization captures the high-level architecture of Reynolds 1994 Theorem 15 but departs from the paper in several significant ways. Some departures are defensible engineering choices; others represent genuine gaps or incorrect simplifications that would prevent a faithful formalization. The most critical issue is that the formalization axiomatizes Theorem 15 itself (`z_model_exists` in `KEquivalenceFramework`) rather than proving it, which makes the entire pipeline circular when the goal is precisely to *prove* Theorem 15.

## Reynolds Theorem 15 Step-by-Step Comparison

### Step 1: Setup — Fix k ≥ 3

**Reynolds**: "Fix k ≥ 3." The bound k ≥ 3 ensures that k-equivalence preserves endpoints and discreteness.

**Formalization**: `k : Nat` with no lower bound. No constraint `k ≥ 3` appears anywhere.

**Assessment**: **DEVIATION (minor)**. For the discrete no-endpoints case, k ≥ 3 is automatically satisfied for any meaningful formula complexity. But the formalization should at minimum document why k ≥ 3 is not enforced, since Reynolds explicitly requires it for preserving discreteness and endpoint properties under ≡_k.

### Step 2: k-equivalence definition (M ≡_k N)

**Reynolds**: "M ≡_k N if and only if M and N agree on the truth of monadic sentences of quantifier depth at most k." This is a purely semantic definition using first-order truth.

**Formalization**: `k_equiv sig k M N := k_type_of sig k M = k_type_of sig k N` where `k_type_of` is **completely sorried** (NEquivalence.lean:242). The `KType` is defined as `Finset (MonadicSentence sig)` (line 210), which is the right idea, but the function computing which sentences are true in M is missing entirely.

**Assessment**: **CORRECT TYPE, SORRIED BODY**. The definition is faithful in structure. The sorry is expected given the "shallow encoding" strategy. However, without FO satisfaction, nothing downstream can be proved constructively.

### Step 3: "Good" — M is good iff ∃ N ≡_k M with N having flow an interval of ℤ

**Reynolds**: "Say that M is good if and only if there is some N ≡_k M such that the flow of time of N is an interval of the integers." (line 867-869)

**Formalization**: `good sig k M := ∃ (Z : ZStructure sig), k_equiv sig k M.toMonadic (Z.toMonadic sig)` where `ZStructure` has `carrier := ℤ` (the full integers).

**Assessment**: **DEVIATION (significant)**. Reynolds says "an interval of the integers" — meaning a finite segment like {a, a+1, ..., b} or a half-line like {a, a+1, ...} or the full ℤ. The formalization restricts to carrier = ℤ (always the full integers). This matters for finite subintervals: a finite subinterval [a,b] should be "good" by being ≡_k to a *finite* segment of ℤ, not necessarily the full ℤ. A 3-element structure can certainly be k-equivalent to {0,1,2} but not necessarily to all of ℤ.

This is a **mathematically significant error**. Reynolds's Lemma 16 ("If N is countable and very good then it is good") specifically handles the case where "good" means equivalent to an *interval* of ℤ, and the proof decomposes N into finite good subintervals (each equivalent to finite ℤ-intervals) then combines them via lexicographic sums to get a half-ℤ or full ℤ model. If `good` already requires equivalence to ℤ itself, then `very_good` (all finite subintervals are good) becomes impossible to satisfy — no finite structure is k-equivalent to all of ℤ for k ≥ 3 (since ℤ has no endpoints but finite structures do).

**Recommendation**: Change `ZStructure` to allow finite intervals of ℤ as carrier, or define `good` using a structure with carrier isomorphic to an interval of ℤ (i.e., `carrier : Type` with `[LinearOrder carrier]` plus a proof that the carrier is order-isomorphic to some interval of ℤ).

### Step 4: "Very good" — every subinterval is good

**Reynolds**: "Say that M is very good if and only if, for all t ≤ u in M, the substructure M|[t,u] is good."

**Formalization**: `very_good sig k M := ∀ (a b : M.carrier), a ≤ b → good sig k (M.subinterval sig a b)`

**Assessment**: **FAITHFUL** (modulo the `good` definition issue from Step 3). The structure matches Reynolds exactly.

### Step 5: Contemporaneous equivalence ~M

**Reynolds**: "a ~M b if and only if a = b, or a < b and M|[a,b] is very good, or b < a and M|[b,a] is very good."

**Formalization**: `contemp_equiv sig k M a b := very_good sig k (M.subinterval sig (min a b) (max a b))`

**Assessment**: **FAITHFUL**. Using `min`/`max` elegantly captures all three cases. The a = b case gives `M.subinterval a a` which is a singleton and should be trivially very good (all subintervals of a singleton are singletons, which are finite, hence good).

### Step 6: ~M is a contemporaneous equivalence relation (Lemma 17)

**Reynolds**: Proves ~M is an equivalence relation with interval classes. The key is transitivity: if a < b < c with a ~M b and b ~M c, show M|[a,c] is very good by considering t ≤ u in [a,c].

**Formalization**: `contemp_equiv_is_equiv` — **completely sorried** (IntegerModel.lean:136). The docstring mentions the right proof sketch (transitivity via Doets 1.4 for n=2 ordered sum).

**Assessment**: **CORRECT SKETCH, FULLY SORRIED**. The transitivity proof sketch in the docstring is correct: if t ≤ b ≤ u, decompose M|[t,u] as ordered sum of M|[t,b] and M|[b+1,u], each good, hence good by Lemma 1.4. The code does not implement this.

### Step 7: ~M classes do not end at gaps (Theorem 14)

**Reynolds**: This is the central technical result. It proves that in any Prior structure, the equivalence classes of a contemporaneous equivalence relation cannot end at gaps. The proof uses:
- Expressive completeness of U and S over Prior structures (Theorem 5)
- Lemmas 6-13: elaborate chain using Prior-U/Prior-S to show bad intervals can't exist

**Formalization**: `no_gaps_discrete` (IntegerModel.lean:157-164) — **completely sorried**. The theorem states that in a discrete order, if a and b are in different classes, there exists a boundary at (c, succ(c)). 

**Assessment**: **CORRECT FOR DISCRETE CASE, BUT REASONING IS DIFFERENT**. Reynolds proves Theorem 14 for *all* Prior structures (including dense ones) via the full expressive completeness machinery (Lemmas 6-13). The formalization bypasses this entirely and directly says: in a discrete order, boundaries can only be at successor pairs. This is a valid simplification for the discrete case — in a discrete order there are no Dedekind gaps, so the only way a class can "end" is at a point c where c ~M a but Order.succ c is not. The heavy Lemmas 6-13 machinery is genuinely not needed here.

**However**: The sorry means no actual proof exists. The formalization just *states* the simplified claim without proving it. The proof should be straightforward: given ¬(a ~M b), by linear order either a < b or b < a. WLOG a < b. The set S = {x ∈ [a,b] | a ~M x} is nonempty (a ∈ S) and bounded above (b ∉ S). In a discrete order, S has a maximum element c (by well-ordering of the complement, or by the fact that ~M classes are intervals + discrete). Then c ~M a but succ(c) is not.

### Step 8: No boundary at successor (key contradiction)

**Reynolds**: Within Theorem 15's final paragraph: "Now a's class can not end at a gap on the right (by theorem [14])... so it must include a point c but not the successor c + 1 of c. This can not be because M|[c, c+1], like all finite structures, is very good and ~ is transitive."

**Formalization**: `no_boundary_at_successor` (IntegerModel.lean:179-183) — **completely sorried**. States that for any c, `contemp_equiv sig k M c (Order.succ c)` holds.

**Assessment**: **FAITHFUL**. The proof should be: M|[c, succ(c)] is a 2-element structure (by `subinterval_two_element_finite`), hence finite, hence good (by `finite_structures_good`). Then for any subinterval of M|[c, succ(c)] — it's either [c,c], [succ(c), succ(c)], or [c, succ(c)] itself — all finite, all good. So M|[c, succ(c)] is very good. By definition of contemp_equiv, c ~M succ(c).

BUT: this proof depends on `finite_structures_good` which is itself sorried, and `finite_structures_good` depends on `good` being satisfiable for finite structures — which circles back to the `good` definition issue from Step 3. If `good` requires equivalence to the *full* ℤ, a 2-element structure cannot be good.

### Step 9: One-class theorem

**Reynolds**: Combines steps 7 and 8: if there were two classes, by step 7 there's a boundary at (c, succ(c)), but by step 8 c ~M succ(c), contradiction with transitivity.

**Formalization**: `one_class` (IntegerModel.lean:206-210) — **completely sorried**.

**Assessment**: **FAITHFUL LOGIC, SORRIED**. The proof sketch in the docstring correctly captures Reynolds's argument.

### Step 10: Good → Z-model (Lemma 16)

**Reynolds**: "If N is countable and very good then it is good." Proof by cofinal sequence decomposition + Doets Lemma 1.4 lexicographic sum.

**Formalization**: `very_good_implies_good` (IntegerModel.lean:232-235) — **completely sorried**. `chronicle_is_good` (IntegerModel.lean:273-276) — **completely sorried**.

**Assessment**: **FAITHFUL STRUCTURE**. The docstring captures the right decomposition idea. Note that `chronicle_is_good` should use `one_class` → all very good → use Lemma 16.

### Step 11: Completeness (Theorem 18)

**Reynolds**: Uses Corollary 3 (Burgess-Xu model M₀) + Theorem 15 to get Z-model, then transfers truth via table correctness.

**Formalization**: `doets_countermodel_discrete` (Transfer.lean:86-112) — **falls back to chronicle construction** (line 110-111). The Reynolds pipeline is commented out (lines 94-102).

**Assessment**: **NOT ACTIVE**. The Reynolds pipeline exists as comments only; the actual proof delegates to the old `dd_countermodel_chronicle_discrete` which carries the `succ_cofinal` sorry.

## Missing or Incorrect Formalizations

### 1. CRITICAL: `good` uses full ℤ instead of ℤ-interval
As detailed in Step 3. This makes `finite_structures_good` mathematically false: no finite structure with endpoints can be k-equivalent (k ≥ 3) to ℤ (which has no endpoints).

### 2. CRITICAL: `KEquivalenceFramework.z_model_exists` axiomatizes the conclusion
The `KEquivalenceFramework` typeclass (NEquivalence.lean:290-321) includes a field `z_model_exists` that directly states: "Every countable discrete linear order without endpoints, satisfying Prior-UZ/SZ, is k-equivalent to a Z-structure." But this IS Theorem 15 — the very thing being proved. Including it as an axiom makes the entire proof circular. The framework should provide k-equivalence properties (reflexivity, transitivity, monotonicity, finite types, sum preservation) and then Theorem 15 should be PROVED from these properties.

### 3. Table translation is completely vacuous
`table` (Table.lean:61) has a sorried body. `table_correctness` (Table.lean:100) has conclusion `True` — a placeholder, not an actual correctness statement. The truth transfer step (Reynolds Theorem 18, step 3 of Transfer.lean) has no foundation.

### 4. MonadicSentence lacks relational atoms
`MonadicSentence` (NEquivalence.lean:48-53) has: `atom`, `not`, `and`, `forall`. It lacks:
- **Equality** (`x = y`) — needed for "x = y" subformulas
- **Order relation** (`x < y`) — critical for monadic FO over ordered structures
- **Existential quantifier** — definable from `∀` + `¬` but explicit would help

The order relation `<` is the backbone of the monadic language in Reynolds's framework. Without it, monadic sentences cannot express anything about the temporal structure's order, making k-equivalence meaningless.

### 5. `OrderedSum` carrier definition lacks order
`OrderedSum` (NEquivalence.lean:172-175) defines a `MonadicStructure` (unordered) not an `OrderedMonadicStructure`. The Sigma type `Sigma fun (i : I) => (M i).carrier` has no lexicographic order defined. For Doets Lemma 1.4, the ordered sum must carry the lexicographic order, since k-equivalence is defined over *ordered* structures.

### 6. Doets Lemma 1.5 is stated incorrectly
`doets_lemma_1_5` (OrderedSum.lean:110-113) is stated as an unconditional `k_equiv sig k (OrderedSum sig I m) (OrderedSum sig J m')` — claiming ANY two ordered sums are k-equivalent. This is obviously false. Doets Lemma 1.5 requires matching type distributions: the multiset of k-types across the two indexed families must agree. The type signature needs a hypothesis about matching type distributions.

## Deviations from Reynolds (Intentional vs. Errors)

| Deviation | Intentional? | Assessment |
|-----------|-------------|------------|
| Discrete-only gap elimination (bypass Lemmas 6-13) | YES | Valid — discrete orders have no Dedekind gaps |
| `good` uses full ℤ instead of ℤ-interval | NO | **Error** — makes finite_structures_good impossible |
| k ≥ 3 not enforced | YES | Minor — irrelevant for the discrete no-endpoints case |
| `z_model_exists` as axiom instead of theorem | NO | **Error** — makes proof circular |
| `MonadicSentence` lacks `<` relation | NO | **Error** — k-equivalence undefined without order |
| Lemma 1.5 stated unconditionally | NO | **Error** — the current statement is trivially false |
| `OrderedSum` unordered | NO | **Error** — breaks Lemma 1.4 semantics |
| Table translation vacuous | Known | Expected deferred work |

## Recommendations for Faithful Formalization

### Priority 1: Fix `good` definition
Replace `ZStructure` (carrier = ℤ) with a type allowing finite ℤ-intervals:
```lean
structure ZIntervalStructure (sig : MonadicSignature) where
  lo : ℤ  -- or use a general type with OrderIso to a ℤ-interval
  hi : ℤ ∪ {+∞}
  interp (p : sig.preds) : {n : ℤ // lo ≤ n ∧ (hi = +∞ ∨ n ≤ hi)} → Prop
```
Or more cleanly: let "good" be equivalence to *any* structure whose carrier is order-isomorphic to a (possibly infinite) interval of ℤ.

### Priority 2: Remove `z_model_exists` from `KEquivalenceFramework`
This field axiomatizes the theorem being proved. The framework should contain only the core properties: equivalence, monotonicity, finite types, sum preservation. Theorem 15 must be proved from these.

### Priority 3: Add `<` to `MonadicSentence`
The monadic language over ordered structures needs the order relation. Add `lt : MonadicSentence sig` as a binary relation atom or handle it structurally.

### Priority 4: Fix `OrderedSum` to carry lexicographic order
Define `OrderedSum` as returning `OrderedMonadicStructure` with the lexicographic order on `Sigma i, (M i).carrier`.

### Priority 5: Fix Doets Lemma 1.5 type signature
Add the hypothesis requiring matching type distributions between the two families.

### Priority 6: Fill the sorry chain bottom-up
The dependency chain is: `k_type_of` → `k_equiv` → `finite_structures_good` → `no_boundary_at_successor` → `one_class` → `chronicle_is_good` → `doets_countermodel_discrete`. Each sorry depends on the previous ones. Start from the bottom (`k_type_of` requires FO satisfaction) and work up.

## Summary

The formalization has the right high-level architecture but contains 4 mathematical errors that would prevent a faithful proof even if all sorries were filled:
1. `good` wrongly requires equivalence to full ℤ (should be ℤ-interval)
2. `KEquivalenceFramework` axiomatizes the conclusion (circular)
3. `MonadicSentence` lacks the order relation (k-equivalence undefined)
4. `Doets Lemma 1.5` is stated as an unconditional falsehood

These must be corrected before the sorry chain can be meaningfully closed. The 15 remaining sorries in the pipeline files (NEquivalence: 3, OrderedSum: 3, IntegerModel: 7+2, Table: 3) represent genuine mathematical work but are blocked by the structural errors above.
