# NF-Bridge Research: nf_determines_stavi_truth

## Task

Research how to prove `nf_determines_stavi_truth` at ExpressivenessGeneral.lean:522 -- the
theorem that carrier points with the same NormalForm characteristic at depth r agree on all
StaviFormula truth values at depth <= r.

## 1. Does `extendedStructure` Exist?

**Yes.** Defined at EFGames.lean:724.

```lean
noncomputable def extendedStructure {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds) (r : Nat) :
    OrderedMonadicStructure sig where
  carrier := ExtendedCarrier M atomMap r
  interp := fun p e => match e with
    | .inl x => M.interp p x
    | .inr _ => False  -- gaps have no predicate values
  carrier_order := extendedLinearOrder
```

The `extendedStructure N atomMap r` is an `OrderedMonadicStructure sig` whose carrier is
`ExtendedCarrier N atomMap r = N.carrier + RDefinableGap N atomMap r`. Predicates at gaps
are false; predicates at actual points inherit from N.

This is exactly what `nf_determines_stavi_truth` uses in its hypothesis:
`nf_characteristic (extendedStructure N atomMap r) r 1 (fun _ => extendPoint p)`.

## 2. The Exact Path from nf_characteristic to stavi_temporal_truth

### 2a. What the hypothesis provides

The hypothesis says:

```
nf_characteristic (extendedStructure N atomMap r) r 1 (fun _ => extendPoint p) =
nf_characteristic (extendedStructure N atomMap r) r 1 (fun _ => extendPoint q)
```

By `nf_exists_unique` (NormalForm.lean:277), each `(M, env)` satisfies exactly one
normal form. So `nf_characteristic` at `(extendedStructure N atomMap r, fun _ => extendPoint p)`
is the unique NF satisfied by the 1-variable monadic theory at point p in the extended
structure.

Same nf_characteristic implies, by `nf_agreement_from_shared_nf` (NormalForm.lean:291):

```
forall nf, nf_eval_nf (extendedStructure N atomMap r) r 1 (fun _ => extendPoint p) nf <->
           nf_eval_nf (extendedStructure N atomMap r) r 1 (fun _ => extendPoint q) nf
```

Then by `doets_lemma_1_1` (NormalForm.lean:433):

```
forall phi : MonadicFormula sig 1, phi.quantifier_depth <= r ->
  eval (extendedStructure N atomMap r) (fun _ => extendPoint p) phi <->
  eval (extendedStructure N atomMap r) (fun _ => extendPoint q) phi
```

This tells us: p and q agree on all monadic FO sentences of depth <= r, evaluated
on the EXTENDED structure with 1 free variable (the variable bound to the point).

### 2b. What the conclusion requires

The conclusion says:

```
stavi_temporal_truth N atomMap p A <-> stavi_temporal_truth N atomMap q A
```

where `A : StaviFormula` with `stavi_depth A <= r`. Here `stavi_temporal_truth` operates
on `N.carrier` (the ORIGINAL structure, not the extended one).

### 2c. The Missing Bridge

The gap is: we need to connect `stavi_temporal_truth N atomMap p A` to
`eval (extendedStructure N atomMap r) (fun _ => extendPoint p) phi` for some
monadic formula phi that encodes A.

**There are two possible approaches:**

**Approach A: Build a stavi_table (StaviFormula -> MonadicFormula)**

Define a function `stavi_table : sig -> (Formula -> sig.preds) -> StaviFormula -> MonadicFormula sig 1`
that translates each StaviFormula into its FO monadic equivalent over the extended structure.
Then prove `stavi_table_correctness`:

```
eval (extendedStructure M atomMap r) (fun _ => extendPoint t) (stavi_table sig atomMap A) <->
stavi_temporal_truth M atomMap t A
```

This approach mirrors the existing `table` and `table_correctness` (Table.lean:244) which
work for standard temporal formulas. The stavi_table would:

- `.base phi` -> use the existing `table` (but need to adapt from `eval M` to
  `eval (extendedStructure M atomMap r)` -- requires showing predicates agree at mu-points)
- `.neg A` -> negate the translation
- `.conj A B` -> conjoin the translations
- `.stavi_untl A B` -> encode the GHR93 FO table body (3 conjuncts with quantifiers)
- `.stavi_snce A B` -> past dual
- `.std_untl A B` -> standard Until FO encoding with mu-relativization
- `.std_snce A B` -> standard Since FO encoding with mu-relativization

The critical issue is that the **quantifiers in the FO translation must range over
the extended carrier** (including gaps), while the mu-relativization restricts the
semantically relevant quantification to points. Concretely, `std_untl A B` at point t
says:

```
exists s : ExtendedCarrier, t < s /\ mu_holds s /\ A^mu(s) /\ ...
```

This translates to the FO formula over the extended structure:
```
exists s. t < s /\ mu(s) /\ C_A(s) /\ forall u. t < u /\ u < s /\ mu(u) -> C_B(u)
```

where `mu(s)` is a predicate in the extended structure. But wait -- `mu_holds` is
NOT a predicate of the signature `sig`. It distinguishes points from gaps, which is
structural information about `ExtendedCarrier`, not captured by any `sig.preds` predicate.

**This means mu cannot be directly encoded as a MonadicFormula atom.** To make this work,
we would need an extended signature `sig'` that adds `mu` as a new predicate, and then
prove that `nf_characteristic` at depth r on `sig'` is still finite and determines truth.

This is a significant infrastructure cost.

**Approach B: Direct induction on StaviFormula without FO intermediary**

Instead of going through FO monadic formulas, prove directly that same nf_characteristic
implies same stavi_temporal_truth_mu, by structural induction on A.

The key insight: `nf_characteristic (extendedStructure N atomMap r) r 1 (fun _ => extendPoint p)`
captures the complete depth-r monadic theory at point p in the extended structure. This
includes information about:

1. Which predicates hold at p
2. For any depth-(r-1) property phi(x, t), whether there exists x in the extended carrier
   satisfying phi(x, p) -- and whether such x is above p, below p, etc.
3. Recursively, the full quantifier alternation pattern up to depth r

The stavi_temporal_truth quantifiers (exists s > t with mu(s) and ...) ARE expressible
in this monadic theory IF we can encode mu. Since `mu_holds (Sum.inl x) = True` and
`mu_holds (Sum.inr g) = False`, mu is NOT a predicate of `sig` but IS definable
as a property of the extended structure.

However, the NormalForm theory works over `OrderedMonadicStructure sig`, which only
has `sig.preds` as predicates. To encode mu, we would need:

**Option 1**: Extend `sig` to `sig'` with one extra predicate for mu.
**Option 2**: Show mu is definable from existing predicates (unlikely in general).
**Option 3**: Avoid mu entirely.

### 2d. Critical Observation: mu IS Definable from the Signature

Actually, consider: in the extended structure, predicates at gaps are ALWAYS false.
So for any predicate p in sig.preds:

```
(extendedStructure N atomMap r).interp p e = match e with
  | .inl x => N.interp p x
  | .inr _ => False
```

This means `mu_holds e <-> exists p, (extendedStructure N atomMap r).interp p e` is
NOT generally true (a point might have all predicates false). So mu is NOT definable
from sig predicates alone in general.

## 3. Recommended Approach: Extend the Signature

### 3a. The Extended Signature Approach

Define:

```lean
def extendedSignature (sig : MonadicSignature) : MonadicSignature where
  preds := sig.preds + Unit  -- add one predicate "mu"
  fintypePreds := inferInstance
  decEqPreds := inferInstance
```

Define `extendedStructureWithMu` where the extra predicate is interpreted as `mu_holds`:

```lean
noncomputable def extendedStructureWithMu (M : OrderedMonadicStructure sig)
    (atomMap : Formula -> sig.preds) (r : Nat) :
    OrderedMonadicStructure (extendedSignature sig) where
  carrier := ExtendedCarrier M atomMap r
  interp := fun p e => match p with
    | .inl p' => match e with
      | .inl x => M.interp p' x
      | .inr _ => False
    | .inr () => mu_holds e   -- the mu predicate
  carrier_order := extendedLinearOrder
```

Then define `stavi_table_mu` that translates StaviFormula into
`MonadicFormula (extendedSignature sig) 1`, using the mu predicate freely in the
translation of quantifiers.

Prove `stavi_table_mu_correctness`:
```
eval (extendedStructureWithMu M atomMap r) (fun _ => extendPoint t) (stavi_table_mu ...) <->
stavi_temporal_truth M atomMap t A
```

Then the proof of `nf_determines_stavi_truth`:

1. From `h_same_nf` on `extendedStructure` (sig), derive the same-nf on
   `extendedStructureWithMu` (sig'). This requires showing that the nf_characteristic
   on sig' at depth r determines the nf_characteristic on sig at depth r
   (since sig' has MORE predicates, its NF is a refinement).

   **Wait -- this direction is wrong.** The hypothesis gives same NF on `sig`, and we need
   same NF on `sig'`. Having the same NF on fewer predicates does NOT imply same NF on more
   predicates.

**This approach fails.** Same nf_characteristic on sig does NOT imply same nf_characteristic
on sig' (the extended signature with mu). The mu-predicate creates NEW atoms that could
distinguish p and q even when they agree on all sig-predicates.

### 3b. The Hypothesis Should Use the Extended Signature

Looking more carefully at the theorem statement:

```lean
(h_same_nf : nf_characteristic (extendedStructure N atomMap r) r 1
    (fun _ => extendPoint p) =
  nf_characteristic (extendedStructure N atomMap r) r 1
    (fun _ => extendPoint q))
```

The nf_characteristic is computed on `extendedStructure N atomMap r` which has
signature `sig`. Since both `extendPoint p` and `extendPoint q` are actual points
(Sum.inl), and predicates at points inherit from N, the nf_characteristic includes
information about `N.interp` predicates at p and q, but does NOT include mu
information explicitly.

However, because the carrier is `ExtendedCarrier` (which includes gaps), the
quantifier part of the NF DOES implicitly encode mu information. Specifically,
at depth k+1, the NF records which depth-k types (with one extra free variable)
are existentially realized. The extra variable ranges over the extended carrier
(including gaps), so the NF captures the structure of gaps around p.

**Key insight**: At actual points, `stavi_temporal_truth N atomMap p A` is
equivalent to `stavi_temporal_truth_mu (extendedStructure) r (extendPoint p) A`
(by `stavi_truth_mu_at_point`, EFGames.lean:1973). The mu-relativized truth
quantifies over the extended carrier but restricts to mu-points. Since mu-points
are exactly `Sum.inl x` for `x : N.carrier`, and the NF at depth r already
captures all existential patterns over the extended carrier at depth r, the
NF determines whether any depth-bounded mu-relativized formula holds.

The question is: can every `stavi_temporal_truth_mu` formula of depth <= r be
expressed as a monadic formula of quantifier depth <= r over the extended
structure WITH the existing sig predicates (without adding mu as a predicate)?

**Yes, because mu is first-order definable from the order structure in a specific way:**

Actually no. mu_holds is NOT first-order definable from the linear order and sig predicates
in general. A gap is a point where all sig predicates are false, but a carrier point
might also have all predicates false.

### 3c. Correct Approach: Change the Hypothesis

The cleanest solution is to **change the hypothesis** of `nf_determines_stavi_truth` to
use an extended signature that includes mu, rather than the bare `sig`. Specifically:

```lean
private theorem nf_determines_stavi_truth {sig : MonadicSignature}
    {N : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {r : Nat} {p q : N.carrier}
    (h_same_nf : nf_characteristic (extendedStructureWithMu N atomMap r) r 1
        (fun _ => extendPoint p) =
      nf_characteristic (extendedStructureWithMu N atomMap r) r 1
        (fun _ => extendPoint q))
    (A : StaviFormula) (hA : stavi_depth A ≤ r) :
    stavi_temporal_truth N atomMap p A ↔
    stavi_temporal_truth N atomMap q A
```

But this changes the call site. Let me check if the call site can be adapted.

The call site is `pigeonhole_definable_formula` (line 546), which uses
`nf_determines_stavi_truth` to show that points with the same NF type have the same
truth on all depth-r StaviFormulas.

The pigeonhole argument builds an ascending chain of failure points with pairwise
distinct NF types. The NF types are `NormalForm sig r 1`, which is Fintype with
cardinality `nfCount (Fintype.card sig.preds) r 1`.

If we switch to `extendedSignature sig`, the NF types become
`NormalForm (extendedSignature sig) r 1` which is Fintype with cardinality
`nfCount (Fintype.card sig.preds + 1) r 1`. This is still finite, so the
pigeonhole argument still works -- just with a larger (but finite) bound.

### 3d. Alternative: Direct Proof Without FO Translation

**This is actually the right approach and avoids the mu problem entirely.**

The theorem says: if p and q have the same NF at depth r on the extended structure
(with sig predicates only), then they agree on all StaviFormulas of depth <= r.

Proof idea: by induction on A, show that `stavi_temporal_truth N atomMap t A`
depends only on the nf_characteristic at depth `stavi_depth A`. The base cases
(atoms, bot, box) use only sig predicates which are captured by the NF. The
temporal connective cases (U, S, U', S') quantify over `N.carrier`, which
embeds into `ExtendedCarrier` as the mu-points. The key is:

For U(A, B) at t: `exists s > t, A(s) /\ forall u in (t,s), B(u)`.
Since s and u range over N.carrier = mu-points of the extended structure,
this is: `exists s : ExtendedCarrier, mu(s) /\ s > t /\ ...`.

In the extended structure's monadic theory, `exists s with nf_eval_nf(env_with_s, sub_nf)`
captures all existential patterns. The question is whether `mu(s)` (which is `IsPoint s`)
can be expressed as an existential pattern.

**Actually, mu IS definable in the extended structure.** Consider:

`mu_holds e <-> e = extendPoint (some carrier point)`

For e = Sum.inl x: mu_holds is true.
For e = Sum.inr g: mu_holds is false.

In the ordering: `Sum.inr g` is never equal to `Sum.inl x` for any x. But
the NF does NOT have equality. It has order `<` and predicates. Can we distinguish
points from gaps using `<` and predicates?

**Yes, for the following reason:** By definition of Gap, a gap g has the property
that its "cut" has no supremum in the cut and the complement has no minimum.
In particular, for any gap g viewed as an element of ExtendedCarrier:

- There is no predecessor: for any point x below g, there is another point y with
  x < y and y below g (no maximum in the cut).
- There is no successor: for any point x above g, there is another point y with
  y < x and y above g (no minimum in the complement).

So g is a "limit point from both sides" in the extended carrier. A point x = Sum.inl x',
by contrast, might have immediate predecessors or successors (gaps are dense around
the point on at most one side, not both).

However, this distinction requires second-order or infinitary reasoning. In
first-order monadic logic with a finite number of quantifiers, whether an element
is a limit point is NOT decidable.

**Bottom line: mu is NOT definable in bounded-depth monadic FO over the extended structure
with only sig predicates.**

## 4. The Correct Proof Path

After extensive analysis, there are two viable approaches:

### Approach 1: Extend the Signature (Recommended)

**Cost: ~80 lines.** Steps:

1. **Define `extendedSig sig` and `extendedStructureWithMu`** (~20 lines)
   - Add one predicate to sig, interpreted as mu_holds
   - NormalForm on extendedSig is still Fintype

2. **Define `stavi_table_mu`** (~60 lines)
   - Translate StaviFormula -> MonadicFormula (extendedSig) 1
   - Each case mirrors the existing `table` but with mu-relativized quantifiers
   - `.base phi`: needs adaptation from `table` to use mu (since box is a predicate)
   - `.std_untl A B`: `exists s. t < s /\ mu(s) /\ C_A(s) /\ forall u. t < u /\ u < s /\ mu(u) -> C_B(u)`
   - `.stavi_untl A B`: full GHR93 FO table body with mu
   - `.neg A`, `.conj A B`: structural

3. **Prove `stavi_table_mu_correctness`** (~150 lines, by induction on A)
   - Each case follows from the definition of `stavi_temporal_truth` / `stavi_temporal_truth_mu`
   - The key is `stavi_truth_mu_at_point` (EFGames.lean:1973) for the base case

4. **Prove `stavi_table_mu_depth_bound`** (~30 lines)
   - `(stavi_table_mu sig atomMap A).quantifier_depth <= stavi_depth A`

5. **Prove `nf_determines_stavi_truth`** (~15 lines)
   - From `h_same_nf` on sig, derive same NF on extendedSig
     (this requires a lemma: `nf_characteristic_project` that relates NF on sig to NF on
     extendedSig... **but this is the wrong direction** -- we'd need to go FROM less info TO
     more info, which is impossible)

**PROBLEM**: The hypothesis uses `nf_characteristic` on `extendedStructure` (sig),
not on `extendedStructureWithMu` (extendedSig). We cannot lift from sig to extendedSig
because the extra mu predicate provides additional discriminating power.

**RESOLUTION**: The hypothesis must be CHANGED to use the extended signature. This means
modifying the call site in `pigeonhole_definable_formula` and all upstream references.
The pigeonhole still works because `NormalForm (extendedSig sig) r 1` is still Fintype.

**Total estimated cost: ~275 lines + call site changes (~20 lines).**

### Approach 2: Avoid the Bridge Entirely -- Direct rank_type Finiteness

**Cost: ~50 lines.** This is significantly simpler.

The purpose of `nf_determines_stavi_truth` is to enable `pigeonhole_definable_formula`.
The pigeonhole argument needs: the function `p |-> (truth pattern of depth-r StaviFormulas at p)`
has finite image, so some truth pattern must repeat.

Instead of proving this via NormalForm, prove it DIRECTLY:

**Claim**: `{ rank_type N atomMap r (extendPoint p) | p : N.carrier }` has finite image
when `N.carrier` is projected through `stavi_temporal_truth`.

The set of all StaviFormulas is NOT finite. However, what matters is: for each
A with `stavi_depth A <= r`, the truth value `stavi_temporal_truth N atomMap p A` is
determined by the NF type. Since we CANNOT prove this without the bridge, we need a
different finiteness argument.

**Alternative finiteness argument**: The rank_type `{ A | stavi_depth A <= r /\ truth_mu A }`
is a subset of StaviFormulas with depth <= r. Two rank_types are equal iff they agree on
all depth-<= r StaviFormulas. Since `stavi_temporal_truth_mu` depends only on the carrier
point's relationship to the extended structure, and the NF captures all depth-r information
about this relationship...

This is circular -- it's the same bridge problem.

**Better alternative**: Use a COUNTING argument. The number of distinct rank_types is
bounded by `2^(number of StaviFormulas of depth <= r)`. But StaviFormulas of bounded
depth form an INFINITE set (due to arbitrary base formulas). So this doesn't immediately
give finiteness.

**However**: `stavi_temporal_truth_mu` at point `extendPoint p` depends only on
`temporal_truth M atomMap p A_flat` where `A_flat` is the flattened version (which
uses only sig predicates and the order). The number of DISTINCT truth patterns for
all formulas of bounded depth on the EXTENDED structure is bounded by the number of
NF types. So we're back to NormalForm.

### Approach 3: Use the Existing NF on sig + Leverage mu_holds at Points (BEST)

**Key insight I missed**: At actual carrier points (not gaps), `mu_holds` is
always true. So when we evaluate `stavi_temporal_truth_mu` at `extendPoint p`,
all the mu-relativized quantifiers effectively range over:
```
{ e : ExtendedCarrier | mu_holds e } = { extendPoint x | x : N.carrier }
```

Now, the `nf_characteristic` on `extendedStructure N atomMap r` (with sig predicates
only, NOT with mu) captures:

- Which sig-predicates hold at `extendPoint p` (same as `N.interp`)
- Which depth-(r-1) types (on extendedStructure) are existentially realized
  by extending the environment with one more element from `ExtendedCarrier`

The existential quantification ranges over ALL of `ExtendedCarrier`, including gaps.
But `stavi_temporal_truth_mu` quantifies only over mu-points (carrier points).

**The crucial question**: Does the depth-r NF on sig (without mu) determine the
restriction of the depth-r monadic theory to mu-points?

**Answer: YES, because the NF determines the FULL monadic theory (including
quantification over gaps), and the restriction to mu-points is a special case.**

More precisely: for any monadic formula phi(t) of depth <= r, the truth of
`eval (extendedStructure) (fun _ => extendPoint p) phi` is determined by the NF.
Now if we can express "there exists a mu-point s > t with property P(s)" as a
monadic formula of depth <= r, we're done.

**But can we?** The formula "exists s. t < s /\ mu(s) /\ P(s)" has the same
quantifier depth as "exists s. P(s)" (plus 1 for the exists). The problem is that
mu(s) is not expressible as a monadic formula of the signature sig.

**WAIT**: I realize that we don't need to express mu(s) as a sig-formula. We need
a DIFFERENT argument.

### Approach 4: The Correct Mathematical Argument

The proof in GHR93 Chapter 9 uses the following reasoning (which I'll reconstruct):

The pigeonhole argument in `pigeonhole_definable_formula` does NOT need
`nf_determines_stavi_truth` in its full generality. It needs a WEAKER statement:

**If two carrier points p, q have the same nf_characteristic on extendedStructure
at depth r, then they agree on all stavi_temporal_truth formulas of depth <= r.**

The proof should go through `stavi_expressive_completeness` (EFGames.lean:3569) in
reverse:

`stavi_expressive_completeness` says: for every monadic formula phi of depth <= r (with
1 free variable), there exists a StaviFormula A such that
`stavi_temporal_truth M atomMap t A <-> eval M (fun _ => t) phi`.

The CONVERSE is what we need: for every StaviFormula A of depth <= r, there exists
a monadic formula phi (on the EXTENDED structure) such that
`stavi_temporal_truth_mu (extendedStructure) r (extendPoint t) A <-> eval (extendedStructure) (fun _ => extendPoint t) phi`.

**But this is exactly the direction that requires mu to be in the signature.**

### FINAL RESOLUTION: Reformulate the Theorem

After exhaustive analysis, the cleanest approach is:

1. **Change the NF type used in the pigeonhole** from `NormalForm sig r 1` to
   `NormalForm (muSig sig) r 1` where `muSig` adds one predicate for mu.

2. **Change `nf_determines_stavi_truth`** to use `extendedStructureWithMu` in
   the hypothesis.

3. **Build stavi_table_mu** as the FO translation using mu.

4. **Prove correctness** via induction.

This is the approach used in the literature: GHR93 Section 8 explicitly works with
the extended structure M_r where mu IS a predicate of the signature (see p.111:
"h'(mu) = M", treating mu as a new unary predicate whose extension is M within M_r).

## 5. Concrete Proof Sketch

### Step 1: Define muSig (~5 lines)

```lean
def muSig (sig : MonadicSignature) : MonadicSignature where
  preds := sig.preds ⊕ Unit
  fintypePreds := inferInstance
  decEqPreds := inferInstance
```

### Step 2: Define extendedStructureWithMu (~15 lines)

```lean
noncomputable def extendedStructureWithMu (M : OrderedMonadicStructure sig)
    (atomMap : Formula → sig.preds) (r : Nat) :
    OrderedMonadicStructure (muSig sig) where
  carrier := ExtendedCarrier M atomMap r
  interp := fun p e => match p with
    | .inl p' => (extendedStructure M atomMap r).interp p' e
    | .inr () => mu_holds e
  carrier_order := extendedLinearOrder
```

### Step 3: Define stavi_table_mu (~80 lines)

Translate `StaviFormula` to `MonadicFormula (muSig sig) 1`. Each constructor:

- `.base phi`: adapt `table` to use `muSig`, predicates at `.inl p`
- `.neg A`: `MonadicFormula.not (stavi_table_mu A)`
- `.conj A B`: `MonadicFormula.and (stavi_table_mu A) (stavi_table_mu B)`
- `.std_untl A B`: `exists s. t < s /\ mu(s) /\ C_A(s) /\ forall u. (t < u /\ u < s /\ mu(u)) -> C_B(u)`
- `.std_snce A B`: past dual
- `.stavi_untl A B`: full GHR93 FO table body (3 conjuncts with mu-restricted quantifiers)
- `.stavi_snce A B`: past dual

### Step 4: Prove stavi_table_mu_depth_bound (~30 lines)

```lean
theorem stavi_table_mu_depth (A : StaviFormula) :
    (stavi_table_mu sig atomMap A).quantifier_depth <= stavi_depth A
```

### Step 5: Prove stavi_table_mu_correctness (~200 lines)

```lean
theorem stavi_table_mu_correct (M : OrderedMonadicStructure sig)
    (atomMap : Formula → sig.preds) (r : Nat) (t : M.carrier) (A : StaviFormula) :
    eval (extendedStructureWithMu M atomMap r) (fun _ => extendPoint t)
      (stavi_table_mu sig atomMap A) <->
    stavi_temporal_truth M atomMap t A
```

By induction on A, using `stavi_truth_mu_at_point` for the bridge between
`stavi_temporal_truth_mu` (on ExtendedCarrier) and `stavi_temporal_truth` (on carrier).

### Step 6: Reformulate and prove nf_determines_stavi_truth (~20 lines)

Change hypothesis to use `extendedStructureWithMu`:

```lean
private theorem nf_determines_stavi_truth {sig : MonadicSignature}
    {N : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {r : Nat} {p q : N.carrier}
    (h_same_nf : nf_characteristic (extendedStructureWithMu N atomMap r) r 1
        (fun _ => extendPoint p) =
      nf_characteristic (extendedStructureWithMu N atomMap r) r 1
        (fun _ => extendPoint q))
    (A : StaviFormula) (hA : stavi_depth A ≤ r) :
    stavi_temporal_truth N atomMap p A ↔
    stavi_temporal_truth N atomMap q A := by
  -- 1. Same nf_characteristic -> same NF evaluation on all depth-r formulas
  have h_agree := nf_characteristic_implies_agree h_same_nf
  -- 2. In particular, on stavi_table_mu A (which has depth <= r by stavi_table_mu_depth)
  have h_eval := doets_lemma_1_1 r 1 (stavi_table_mu sig atomMap A)
    (stavi_table_mu_depth A |>.trans hA)
    (extendedStructureWithMu N atomMap r) (extendedStructureWithMu N atomMap r)
    (fun _ => extendPoint p) (fun _ => extendPoint q)
    h_agree
  -- 3. Apply stavi_table_mu_correct on both sides
  exact (stavi_table_mu_correct N atomMap r p A).symm.trans
    (h_eval.trans (stavi_table_mu_correct N atomMap r q A))
```

### Step 7: Update pigeonhole_definable_formula (~10 lines)

Change the NF type from `NormalForm sig r 1` to `NormalForm (muSig sig) r 1`.
The pigeonhole bound changes from `Fintype.card (NormalForm sig r 1)` to
`Fintype.card (NormalForm (muSig sig) r 1)`, but both are finite.

## 6. Estimated Lines

| Component | Lines |
|-----------|-------|
| muSig definition | 5 |
| extendedStructureWithMu | 15 |
| stavi_table_mu (all constructors) | 80 |
| stavi_table_mu_depth_bound | 30 |
| stavi_table_mu_correctness | 200 |
| nf_determines_stavi_truth (reformulated) | 20 |
| pigeonhole_definable_formula updates | 15 |
| infimum_gap_r_definable updates | 10 |
| **Total** | **~375** |

## 7. Alternative Approach: Direct rank_type Finiteness (Simpler but Weaker)

Instead of building the FO bridge, observe that:

The pigeonhole argument only needs: "the map `p -> rank_type_at_p` has finite image
among carrier points of N". This can be proved differently:

**Claim**: For any structure N, the number of distinct rank_types among carrier points
is at most `Fintype.card (NormalForm (muSig sig) r 1)`.

**Proof**: Define the map `p -> nf_characteristic (extendedStructureWithMu) r 1 (fun _ => extendPoint p)`.
This has finite image (the range is NormalForm, which is Fintype). Two points with the
same NF have the same rank_type (by nf_determines_stavi_truth). So the number of
distinct rank_types is at most the number of distinct NFs.

This is essentially the same proof, just phrased differently. The infrastructure
(muSig, extendedStructureWithMu, stavi_table_mu, correctness) is still needed.

## 8. Recommendation

**Use Approach 1 (extended signature)** with the following plan:

1. Define `muSig` and `extendedStructureWithMu` (EFGames.lean, ~20 lines)
2. Define `stavi_table_mu` (new file StaviTable.lean or in EFGames.lean, ~80 lines)
3. Prove `stavi_table_mu_depth_bound` (~30 lines)
4. Prove `stavi_table_mu_correctness` (~200 lines, the bulk of the work)
5. Reformulate and prove `nf_determines_stavi_truth` (~20 lines)
6. Update `pigeonhole_definable_formula` and call sites (~25 lines)

**Total: ~375 lines, mostly mechanical.**

The alternative (avoiding the bridge entirely by working directly with rank_types
as the pigeonhole object) would save ~200 lines but would not actually avoid
the core issue: we still need finiteness of rank_types, which requires the
NormalForm connection.

## 9. Key Existing Infrastructure

The following theorems are available and sorry-free:

- `nf_exists_unique` (NormalForm.lean:277): unique NF for each (M, env)
- `nf_eval_unique` (NormalForm.lean:245): if two NFs both satisfied, they're equal
- `nf_characteristic_satisfies` (NormalForm.lean:224): characteristic NF is satisfied
- `nf_agreement_from_shared_nf` (NormalForm.lean:291): shared NF -> agree on all NFs
- `doets_lemma_1_1` (NormalForm.lean:433): NF agreement -> formula agreement (the bridge)
- `nf_agreement_monotone` (NormalForm.lean:339): depth monotonicity
- `normalForm_fintype` (NormalForm.lean:177): NormalForm is Fintype
- `stavi_truth_mu_at_point` (EFGames.lean:1973): mu-truth at points = standard truth
- `temporal_truth_mu_at_point` (EFGames.lean:1927): same for standard Formula
- `table_correctness` (Table.lean:244): standard table is correct (sorry-free)
