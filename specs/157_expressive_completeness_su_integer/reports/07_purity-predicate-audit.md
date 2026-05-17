# Purity Predicate Audit: is_U_free / is_S_free / is_syntactically_separated

## Date: 2026-05-17
## Task: 157 (Expressive Completeness of {S,U} over Integer Time)
## Session: sess_1779001651_c41984

---

## 1. Lean Definitions (Exact Code)

### 1.1 Formula Inductive Type

From `Theories/Bimodal/Syntax/Formula.lean`, the `Formula` type has **8 constructors**:

```lean
inductive Formula : Type where
  | atom : Atom -> Formula
  | bot : Formula
  | imp : Formula -> Formula -> Formula
  | box : Formula -> Formula
  | all_past : Formula -> Formula    -- H (universal past)
  | all_future : Formula -> Formula  -- G (universal future)
  | untl : Formula -> Formula -> Formula  -- U(event, guard)
  | snce : Formula -> Formula -> Formula  -- S(event, guard)
```

Key observation: `all_future` (G) and `all_past` (H) are **primitive constructors**, not derived from U/S.

Derived operators include:
- `some_future phi = neg(all_future(neg phi))` -- F (existential future)
- `some_past phi = neg(all_past(neg phi))` -- P (existential past)
- `next phi = untl phi bot` -- X (next step)
- `prev phi = snce phi bot` -- Y (previous step)
- `neg phi = imp phi bot`
- `and phi psi = neg(imp phi (neg psi))`
- `or phi psi = imp (neg phi) psi`

### 1.2 is_U_free

From `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Defs.lean` (lines 96-104):

```lean
def is_U_free : Formula -> Bool
  | .atom _ => true
  | .bot => true
  | .imp phi psi => is_U_free phi && is_U_free psi
  | .box phi => is_U_free phi
  | .all_past phi => is_U_free phi
  | .all_future phi => is_U_free phi   -- *** PERMITS all_future ***
  | .untl _ _ => false
  | .snce phi psi => is_U_free phi && is_U_free psi
```

**What it checks**: Returns `true` iff the formula contains no `untl` constructor. It **permits** `all_future` (G), `all_past` (H), `snce` (S), `box`, `imp`, `atom`, and `bot`.

### 1.3 is_S_free

From `Defs.lean` (lines 107-115):

```lean
def is_S_free : Formula -> Bool
  | .atom _ => true
  | .bot => true
  | .imp phi psi => is_S_free phi && is_S_free psi
  | .box phi => is_S_free phi
  | .all_past phi => is_S_free phi     -- *** PERMITS all_past ***
  | .all_future phi => is_S_free phi
  | .untl phi psi => is_S_free phi && is_S_free psi
  | .snce _ _ => false
```

**What it checks**: Returns `true` iff the formula contains no `snce` constructor. It **permits** `all_past` (H), `all_future` (G), `untl` (U), `box`, `imp`, `atom`, and `bot`.

### 1.4 is_syntactically_separated

From `Defs.lean` (lines 130-138):

```lean
def is_syntactically_separated : Formula -> Bool
  | .atom _ => true
  | .bot => true
  | .imp phi psi => is_syntactically_separated phi && is_syntactically_separated psi
  | .box _ => true  -- box treated as atomic
  | .all_past phi => is_U_free phi
  | .all_future phi => is_S_free phi
  | .untl phi psi => is_S_free phi && is_S_free psi
  | .snce phi psi => is_U_free phi && is_U_free psi
```

**What it checks**: A formula is syntactically separated if:
- Atoms, bot, box: always separated
- `imp phi psi`: both sub-formulas are separated
- `all_past phi`: phi is U-free (i.e., contains no `untl`)
- `all_future phi`: phi is S-free (i.e., contains no `snce`)
- `untl phi psi`: both arguments are S-free
- `snce phi psi`: both arguments are U-free

### 1.5 is_separable

From `Defs.lean` (lines 142-143):

```lean
def is_separable (phi : Formula) : Prop :=
  exists psi : Formula, is_syntactically_separated psi = true /\ int_equiv phi psi
```

A formula is separable if there EXISTS a syntactically separated formula that is integer-time equivalent to it.

---

## 2. GHR94 Definitions (Exact)

### 2.1 The Formula Language (GHR94 Ch 9, Section 9.1)

GHR94 defines temporal connectives with truth tables. The **primitive** connectives are:
- **F** (will): `||Fp||_t = 1 iff exists s > t, ||p||_s = 1`
- **P** (was): `||Pp||_t = 1 iff exists s < t, ||p||_s = 1`
- **U** (until): `||U(p,q)||_t = 1 iff exists s > t (||p||_s = 1 /\ forall y (t < y < s => ||q||_y = 1))`
- **S** (since): `||S(p,q)||_t = 1 iff exists s < t (||p||_s = 1 /\ forall y (s < y < t => ||q||_y = 1))`

Boolean connectives (neg, and, or, imp) are standard.

**G and H are DERIVED** in GHR94:
- `G(phi) = neg F(neg phi) = neg U(neg phi, top)` -- a derived abbreviation
- `H(phi) = neg P(neg phi) = neg S(neg phi, top)` -- a derived abbreviation

Since `F(phi) = U(phi, top)` (Example 9.1.3 in GHR94), we have:
- `G(phi) = neg U(neg phi, top)`
- `H(phi) = neg S(neg phi, top)`

### 2.2 "U-free" and "S-free" in GHR94 (Ch 10, Section 10.2)

GHR94's language for Ch 10.2 uses **only** the connectives `{U, S}` plus boolean connectives and atoms. The operators G, H, F, P are all derived from U and S:
- `F(A) = U(A, top)`
- `P(A) = S(A, top)`
- `G(A) = neg F(neg A) = neg U(neg A, top)`
- `H(A) = neg P(neg A) = neg S(neg A, top)`

Therefore, in GHR94:
- **"U-free"** means: the formula does not contain the U connective at all. Since G is defined via U, a "U-free" formula also cannot contain G. Since F is defined via U, a "U-free" formula also cannot contain F.
- **"S-free"** means: the formula does not contain the S connective at all. Since H is defined via S, an "S-free" formula also cannot contain H. Since P is defined via S, an "S-free" formula also cannot contain P.

### 2.3 "Separated" in GHR94 (Ch 10, Section 10.2, Definition 10.3.3 adapted for integers)

GHR94 defines "syntactically separated" for integer time as: a boolean combination of:
- **atoms** (pure present)
- **wffs `U(E, F)` with E and F built without using S** (pure future)
- **wffs `S(E, F)` with E and F built without using U** (pure past)

The key text (p. 569): "A wff with this property is already separated, because any wff beginning with U and containing only atoms and Us is pure future. Anything with S only is pure past and the atoms are of course pure present."

Since G and H are abbreviations for U- and S-expressions, a "wff built without using S" can contain G (since G = neg U(neg A, top)), but not H (since H = neg S(neg A, top)). Similarly, "wff built without using U" can contain H but not G.

### 2.4 How G and H relate to U and S in GHR94

- G(phi) = neg U(neg phi, top) -- contains U
- H(phi) = neg P(neg phi) = neg S(neg phi, top) -- contains S
- F(phi) = U(phi, top) -- contains U
- P(phi) = S(phi, top) -- contains S

---

## 3. Mismatch Analysis

### 3.1 Core Mismatch: all_future is primitive in Lean but derived in GHR94

| Aspect | GHR94 | Our Lean Code |
|--------|-------|---------------|
| G operator | Derived: `neg U(neg A, top)` | **Primitive constructor**: `all_future` |
| H operator | Derived: `neg S(neg A, top)` | **Primitive constructor**: `all_past` |
| "U-free" | Excludes U, and hence G, F | Excludes only `untl` -- **permits** `all_future` |
| "S-free" | Excludes S, and hence H, P | Excludes only `snce` -- **permits** `all_past` |

### 3.2 Consequence for is_U_free

In GHR94, `G(phi)` is an abbreviation for `neg U(neg phi, top)`, so any formula containing G implicitly contains U and is NOT U-free.

In our Lean code, `all_future phi` is a primitive constructor and `is_U_free (.all_future phi) = is_U_free phi`. So `all_future (atom p)` returns `true` for `is_U_free`, even though in GHR94's world this would be `neg U(neg p, top)` which contains U.

**Example**:
- `is_U_free (.all_future (.atom p)) = true` in our code
- In GHR94, `G(p) = neg U(neg p, top)` is NOT U-free

### 3.3 Consequence for is_S_free

Symmetric to above:
- `is_S_free (.all_past (.atom p)) = true` in our code
- In GHR94, `H(p) = neg S(neg p, top)` is NOT S-free

### 3.4 Consequence for is_syntactically_separated

Consider `is_syntactically_separated (.snce (.all_future (.atom p)) (.atom q))`:
- Our code: `is_U_free (.all_future (.atom p)) && is_U_free (.atom q)` = `true && true` = `true`
- In GHR94: `S(G(p), q)` -- the S-argument `G(p) = neg U(neg p, top)` contains U, so this is NOT separated

This means our `is_syntactically_separated` is **weaker** (more permissive) than GHR94's definition. Formulas that our code considers "separated" may not be separated in GHR94's sense.

### 3.5 However: Semantic equivalence saves us at the definition level

Our `int_truth` gives `all_future` its own semantics clause: `int_truth M t (.all_future phi) = forall s, t < s -> int_truth M s phi`. The key insight: **over integer time, this is semantically equivalent to the GHR94 encoding** `neg U(neg phi, top)`. That is, for any `phi`, `int_truth M t (.all_future phi) <-> int_truth M t (neg (untl (neg phi) (neg bot)))`.

So at the semantic level the formalization is consistent. The mismatch is purely in the **syntactic predicates**.

---

## 4. Impact on Separation Infrastructure

### 4.1 File-by-file Analysis

#### Defs.lean -- AFFECTED (definitions are weaker)
- `is_U_free`: Permits `all_future`. Weaker than GHR94.
- `is_S_free`: Permits `all_past`. Weaker than GHR94.
- `is_syntactically_separated`: Weaker than GHR94 (accepts formulas with G under S, or H under U).
- `is_separable`: Uses `is_syntactically_separated`, so inherits the weaker criterion. This means `is_separable` is **easier to satisfy** -- it asks for less.

#### Distributivity.lean -- NOT AFFECTED
- Proves pure semantic equivalences about U/S distributing over boolean connectives.
- Does not use `is_U_free`, `is_S_free`, or `is_syntactically_separated`.

#### NegationEquiv.lean -- NOT AFFECTED
- Proves `neg_until_equiv` and `neg_since_equiv` -- pure semantic equivalences.
- Does not use any purity predicates.

#### IntHelpers.lean -- NOT AFFECTED
- Integer-arithmetic lemmas and direct semantic constructions.
- No purity predicates used.

#### Duality.lean -- AFFECTED (but correctly)
- `dual_U_free_iff_S_free`: Proves `is_U_free(swap phi) = is_S_free(phi)`. This is **correct** for OUR definitions (swap_temporal maps all_past <-> all_future and untl <-> snce).
- `dual_separated`: Proves swap preserves `is_syntactically_separated`. Correct for our definitions.
- These theorems are sound for the predicates AS DEFINED. They would need updating if the predicates were strengthened.

#### FormulaOps.lean -- NOT AFFECTED
- Substitution machinery and freshness infrastructure.
- No purity predicates used directly.

#### Eliminations.lean -- AFFECTED (hypotheses and conclusions)
- All 8 cases require `is_U_free a = true`, `is_S_free a = true`, etc. for the "atoms" a, q, A, B.
- Since GHR94's Lemma 10.2.3 states "Let a, q, A, and B be **atoms**", the hypotheses are satisfied trivially for actual atoms under BOTH our weak predicates and GHR94's strict ones.
- **BUT**: The lemmas are stated generally (not just for atoms), so if they are invoked with `a`, `q`, `A`, `B` being more complex formulas (as happens in the inductive buildup), our weaker predicates permit arguments that GHR94 would reject.
- **The proved equivalences are correct** regardless: they are semantic equivalences conditional on the purity hypotheses. The issue is whether the hypotheses will be satisfiable when the lemmas are invoked from the inductive machinery.

#### DualEliminations.lean -- AFFECTED (all sorry)
- All 8 dual cases are sorry. They require `is_S_free psi = true` as a conclusion, which is a syntactic property of the output formula. Our weaker predicate makes this easier to achieve.

#### SeparationThm.lean -- AFFECTED (axiomatized temporal closure)
- The temporal closure axioms (`all_past_separable`, `all_future_separable`, `untl_separable`, `snce_separable`) are the critical bridge.
- `all_separable` uses structural induction and appeals to these axioms.
- The conclusion `is_separable phi` means: exists psi with `is_syntactically_separated psi = true` and `int_equiv phi psi`.
- Since our `is_syntactically_separated` is weaker, we are proving a WEAKER separation theorem (the separated equivalent may have G under S, or H under U).

#### ExpressiveCompleteness.lean -- POTENTIALLY AFFECTED
- `separation_implies_expressiveness` takes `h_sep : forall phi, is_separable phi` and uses the separation to eliminate auxiliary atoms r_=, r_>, r_< by substitution.
- The substitution step (Step 6 in Theorem 9.3.1) requires: in the "pure past" parts, substitute r_> = True, r_= = False, r_< = False. In the "pure future" parts, substitute r_> = False, r_= = True, r_< = False. In the "pure present" parts, substitute r_> = False, r_= = True, r_< = False.
- **THIS STEP REQUIRES SEMANTIC PURITY**: the "pure past" parts must genuinely depend only on the past. A formula containing `all_future` inside an `snce` is NOT purely past-dependent -- it looks at the future. So our weaker `is_syntactically_separated` does NOT guarantee the purity required.

---

## 5. Impact on Cases 1-4 (Proved Cases)

### 5.1 Hypotheses Analysis

All four proved cases (elim_case_1 through elim_case_4) have the same hypothesis pattern:

```lean
(ha : is_U_free a = true) (hq : is_U_free q = true)
(hA : is_U_free A = true) (hB : is_U_free B = true)
(ha' : is_S_free a = true) (hq' : is_S_free q = true)
(hA' : is_S_free A = true) (hB' : is_S_free B = true)
```

This means a, q, A, B are required to be BOTH U-free AND S-free under our definitions.

### 5.2 Would strengthening predicates break these proofs?

**Answer: NO.** Strengthening `is_U_free` to also reject `all_future` and `is_S_free` to also reject `all_past` would make the hypotheses STRONGER (harder to satisfy), but the proofs only use these hypotheses to conclude that constructed formulas are syntactically separated. The proofs reason about:

1. Semantic correctness (the int_equiv part) -- this doesn't depend on the purity predicates at all.
2. Separation of the output formula -- this uses `simp [is_syntactically_separated, is_U_free, ...]` to verify the output. If the predicates were strengthened, the `simp` lemmas would still work the same way because:
   - The base parameters (a, q, A, B) are both U-free and S-free under EITHER definition
   - The output formulas are built from these base parameters using `snce`, `untl`, `and`, `or`, `neg`, `all_future`, `all_past`
   - The output formulas' separation depends on the base parameters being U-free/S-free

**However**: The proofs use `is_U_free (.all_future phi) = is_U_free phi` via `simp`. If we strengthened `is_U_free` to return `false` for `all_future`, these simp steps would produce different results.

### 5.3 Detailed check of Case 1 output

The output formula `case1_psi` is:
```
or (or (and (and (and (snce a q) (snce a B)) B) (untl A B))
       (and (and A (snce a B)) (snce a q)))
   (snce (and (and (and A q) (snce a B)) (snce a q)) q)
```

For this to be `is_syntactically_separated`:
- `untl A B`: needs `is_S_free A && is_S_free B`. Given by `hA'` and `hB'`. OK.
- `snce a q`: needs `is_U_free a && is_U_free q`. Given by `ha` and `hq`. OK.
- `snce a B`: needs `is_U_free a && is_U_free B`. Given by `ha` and `hB`. OK.
- The outer `snce (and ...) q`: needs `is_U_free (and (and (and A q) (snce a B)) (snce a q))`. This expands to checking `is_U_free A`, `is_U_free q`, `is_U_free a`, `is_U_free B`. All given. **But also needs `is_U_free (snce a B)` and `is_U_free (snce a q)`**. Since `snce` case: `is_U_free (.snce phi psi) = is_U_free phi && is_U_free psi`. So `is_U_free (.snce a B) = is_U_free a && is_U_free B = true`. OK.

**None of these sub-checks involve `all_future` or `all_past`**. The Case 1 output formula does not contain `all_future` or `all_past` at all. So strengthening the predicates would NOT break Case 1.

### 5.4 Case 2 output check

Case 2 reduces to Case 1 plus `snce (and a (all_future (neg A))) q`:
- `is_syntactically_separated` of this `snce`: needs `is_U_free (and a (all_future (neg A))) && is_U_free q`
- `is_U_free (.all_future (neg A)) = is_U_free (neg A) = is_U_free A = true` (under current definition)
- **Under a strengthened definition where `is_U_free (.all_future _) = false`**, this would be `false`, and the proof would break.

**Case 2 WOULD BREAK if we strengthen is_U_free to reject all_future.**

But semantically, `all_future (neg A)` with A being U-free and S-free is in fact "pure future" -- it only looks at the future. The issue is that under GHR94's encoding, `G(neg A) = neg U(neg(neg A), top) = neg U(A, top) = neg F(A)`, which contains U, making it NOT U-free. But in GHR94, the formula `S(a ^ G(neg A), q)` would be handled differently -- the G would be considered part of the U-structure, not a standalone component.

### 5.5 Summary for Cases 1-4

| Case | Contains all_future/all_past in output? | Would break with strict predicates? |
|------|-----------------------------------------|-------------------------------------|
| Case 1 | No | No |
| Case 2 | Yes (`all_future (neg A)` in one disjunct) | **Yes** |
| Case 3 | Yes (via `all_past (neg a)` in output) | **Yes** |
| Case 4 | Yes (via `all_past (neg a)` in output) | **Yes** |

---

## 6. Impact Scope: Is the Problem Separation-Wide or Only Theorem 9.3.1?

### 6.1 The Separation Theorem (all_separable) itself

The separation theorem `all_separable` proves: for every formula phi, there exists a syntactically separated psi equivalent to phi over Z.

With our current weak `is_syntactically_separated`, the theorem allows the separated form to contain `all_future` inside `snce` arguments (or `all_past` inside `untl` arguments). The separated form may not be "semantically separated" in GHR94's sense.

**BUT**: The separation theorem itself is still **mathematically correct** in the following sense: it IS true that every {U,S}-formula over Z has an equivalent formula in which no `untl` appears under `snce` and no `snce` appears under `untl`. Our `is_syntactically_separated` correctly captures this structural property. The issue is that GHR94 additionally requires no G under S and no H under U (because G and H are abbreviations for U/S expressions), which is a STRONGER requirement.

### 6.2 Where the mismatch actually matters

The mismatch matters at **Theorem 9.3.1** (separation implies expressive completeness). This theorem needs:

1. A separated formula B is equivalent to `beta(B_+i, B_-j, B_0)` where:
   - `B_+i` are **semantically pure future** (depend only on future of t)
   - `B_-j` are **semantically pure past** (depend only on past of t)
   - `B_0` is **semantically pure present** (depends only on time t)

2. The substitution step then sets the auxiliary atoms to appropriate values in each component.

For this to work, we need: if a formula is in the "S-parts" of a separated formula (i.e., it appears as an argument of `snce` with U-free arguments), then it is semantically pure past.

**Under our current definitions**: `snce (all_future p) q` is syntactically separated (since `is_U_free (.all_future p) = true`), but `all_future p` makes the snce-formula NOT purely past. It depends on the future (G(p) requires p to hold at all future times of the witness point).

### 6.3 Verdict

**The mismatch affects BOTH the separation infrastructure AND Theorem 9.3.1**, but in different ways:

1. **Separation infrastructure**: The syntactic predicate `is_syntactically_separated` does not guarantee semantic purity. This is a definitional weakness. However, all the actual separated formulas PRODUCED by the elimination cases (Cases 1-4 proved, Cases 5-8 axiomatized) happen to satisfy a stronger property, because GHR94 Lemma 10.2.3 starts from atoms.

2. **Theorem 9.3.1**: This is where the mismatch is FATAL. The proof structure of 9.3.1 REQUIRES that syntactically separated formulas decompose into semantically pure components. Our weak predicate does not guarantee this.

3. **The inductive buildup (Lemmas 10.2.4-10.2.8)**: These lemmas substitute U-subterms by fresh atoms, apply the elimination cases, then resubstitute. After resubstitution, the formerly-separated formula may contain complex sub-formulas in its S-arguments. The induction needs these to be re-separable with the SAME predicate. Since our predicate is weaker, the induction still works -- we just get a weaker conclusion.

---

## 7. Recovery Option Analysis

### Option A: Strengthen is_syntactically_separated with stricter predicates

**Approach**: Define `is_strictly_U_free` that also rejects `all_future` (and dually for `is_strictly_S_free`).

```lean
def is_strictly_U_free : Formula -> Bool
  | .atom _ => true
  | .bot => true
  | .imp phi psi => is_strictly_U_free phi && is_strictly_U_free psi
  | .box phi => is_strictly_U_free phi
  | .all_past phi => is_strictly_U_free phi
  | .all_future _ => false    -- REJECT G
  | .untl _ _ => false
  | .snce phi psi => is_strictly_U_free phi && is_strictly_U_free psi
```

And update `is_syntactically_separated` to use these strict predicates:
```lean
  | .all_past phi => is_strictly_U_free phi
  | .all_future phi => is_strictly_S_free phi
  | .untl phi psi => is_strictly_S_free phi && is_strictly_S_free psi
  | .snce phi psi => is_strictly_U_free phi && is_strictly_U_free psi
```

**Impact assessment**:
- Defs.lean: Update 2 definitions, add 2 new definitions. Moderate.
- Duality.lean: `dual_U_free_iff_S_free` etc. need updating for strict versions. The proofs are straightforward structural inductions and would adapt easily. Low effort.
- Eliminations.lean (Cases 1-4):
  - **Case 1**: Output contains no G/H. Proof survives unchanged. Zero effort.
  - **Case 2**: Output contains `all_future(neg A)`. This would fail the strict check. The proof would need to replace G(neg A) with its U-encoding: `neg(untl A (neg bot))`. But then the output contains `untl` which also fails `is_strictly_U_free`. **This is the fundamental problem**: GHR94's Case 2 formula contains G(neg A) as a standalone component in an S-argument, which is "U-free" in GHR94 because it appears as part of the separated structure, but our strict predicate would reject it.
  - **Cases 3, 4**: Similar issue with `all_past(neg a)` in the output.
- SeparationThm.lean: Axioms would need updating. Low effort.
- ExpressiveCompleteness.lean: Would benefit -- the strict predicate would properly guarantee semantic purity.

**Problem**: The proved Cases 2-4 use `all_future` / `all_past` in their output formulas as top-level temporal operators in the separated form. In GHR94, these ARE permitted as top-level temporal operators in a separated formula (G(phi) beginning a "pure future block" is fine). The issue is that our `is_syntactically_separated` check for `all_past phi` currently requires `is_U_free phi`, but with strict predicates it would require the absence of `all_future` in phi as well, which is TOO STRICT.

**Wait -- let me re-examine**. In GHR94's definition: "a wff beginning with U and containing only atoms and Us is pure future. Anything with S only is pure past." And `G(phi) = neg F(neg phi) = neg U(neg phi, top)`. So a "separated" formula in GHR94 is one where:

- `U(E, F)` appears with E, F containing no S (but may contain U, G, F)
- `S(E, F)` appears with E, F containing no U (but may contain S, H, P)
- `G(phi) = neg U(neg phi, top)` appears -- this IS a U-formula, so it's pure future
- `H(phi) = neg S(neg phi, top)` appears -- this IS an S-formula, so it's pure past

In GHR94, `G(phi)` inside an S-argument DOES contain U, so it violates "S-arguments contain no U." Our predicate correctly models this at the `untl`/`snce` level, but misses the G/H level.

**The correct fix for Option A** would be to update `is_syntactically_separated` as follows:
```lean
  | .all_past phi => is_U_free phi && is_all_future_free phi  -- no untl AND no all_future
  | .all_future phi => is_S_free phi && is_all_past_free phi  -- no snce AND no all_past
  | .snce phi psi => is_U_free phi && is_all_future_free phi
                   && is_U_free psi && is_all_future_free psi
  | .untl phi psi => is_S_free phi && is_all_past_free phi
                   && is_S_free psi && is_all_past_free psi
```

But this would break Cases 2-4 because their output formulas use `all_future` and `all_past` as **top-level** temporal operators in the separated form, which IS correct in GHR94.

**The actual issue**: Our `is_syntactically_separated` checks the wrong thing for `all_past` and `all_future`. In GHR94, `H(phi)` is a pure past formula if phi contains no U (since H = neg S(neg phi, top) only uses S). But our code checks `is_U_free phi` for `all_past phi`, which correctly excludes `untl` from inside H's argument, BUT does not exclude `all_future`. However, `H(G(p))` in GHR94 = `neg S(neg(neg U(neg p, top)), top)` = `neg S(U(neg p, top), top)` -- this contains U inside an S, and IS NOT separated.

So the correct check for `all_past phi` being part of a "pure past" component is: phi must not contain any `untl` AND phi must not contain any `all_future`. In other words, phi must be "strictly U-free" where both `untl` and `all_future` are excluded.

**Effort estimate for Option A**:
- New definitions: 2 (is_strictly_U_free, is_strictly_S_free). Small.
- Update is_syntactically_separated: Moderate.
- Cases 2-4 would need rewriting to produce outputs without `all_future` / `all_past` in S/U arguments. This is a MAJOR rewrite because the current proof strategy uses G and H freely.
- Alternatively: Cases 2-4 outputs could replace `all_future(neg A)` with `neg(untl A (neg bot))`, but then the S-arguments would contain `untl`, violating U-free. The resolution in GHR94 is that `G(neg A)` appears at the TOP LEVEL of the separated form, not inside an S-argument. But our Case 2 output has `all_future(neg A)` inside an `snce` argument...

Let me re-check Case 2's output structure more carefully. Case 2 produces `or psi_l psi1` where `psi_l = snce (and a (all_future (neg A))) q`. Here `all_future (neg A)` appears INSIDE the snce event argument. This means in GHR94's encoding, U appears inside S -- which is NOT separated.

**This means Case 2's output formula is actually NOT separated in GHR94's sense!** Our code reports it as separated only because our weak predicate allows it. The proof is producing the wrong output formula.

**Risk: HIGH**. Cases 2-4 prove semantic equivalences to formulas that are weakly-separated but not GHR94-separated. The proofs are correct modulo the weak definition, but the formulas need to be different for the strict definition.

### Option B: Prove all_separable produces strongly-separated formulas as a separate property

**Approach**: Keep the current definitions but prove an additional theorem:

```lean
theorem all_separable_strong (phi : Formula) :
    exists psi, is_strongly_separated psi = true /\ int_equiv phi psi
```

where `is_strongly_separated` uses the strict predicates.

**Feasibility**: This would require reproving the separation theorem with the stronger predicate. It would encounter the same problems as Option A (the elimination case outputs are not strongly separated). This approach does not save work; it just defers it.

**Effort**: Same as Option A. Not recommended as a separate path.

### Option C: Alternative proof of Theorem 9.3.1 that doesn't require purity

**Approach**: Find a proof of expressive completeness that doesn't go through the separation-purity-substitution pathway.

**Assessment**: The GHR94 proof of Theorem 9.3.1 fundamentally requires the purity property. The substitution step (replacing r_=, r_>, r_< by constants in each pure component) is the entire mechanism. Without purity, there is no way to eliminate the auxiliary atoms.

There is one alternative approach: prove expressive completeness directly by translation from monadic FO to temporal formulas, without going through separation at all. This is essentially Kamp's theorem approach (Kamp 1968). However, Kamp's original proof is for real-number time, and the proof for integer time (via separation) is the standard approach.

**Effort**: Very high. Would require a completely different proof architecture. Not recommended.

### Option D: Redefine separated to match our primitive operators (RECOMMENDED)

**Approach**: Accept that our formalization has G and H as primitives, and adjust the definition of "separated" to account for this. The key insight is:

In our formalization, a formula is "semantically separated" if it can be decomposed into:
- **Pure future parts**: formulas built from `all_future`, `untl`, atoms, boolean connectives (NO `all_past`, NO `snce`)
- **Pure past parts**: formulas built from `all_past`, `snce`, atoms, boolean connectives (NO `all_future`, NO `untl`)
- **Pure present parts**: formulas built from atoms and boolean connectives only

This correctly captures the semantic purity requirement. The corresponding syntactic predicates would be:

```lean
-- "contains no past temporal operators" (no all_past, no snce)
def is_future_only : Formula -> Bool
  | .atom _ => true
  | .bot => true
  | .imp phi psi => is_future_only phi && is_future_only psi
  | .box phi => is_future_only phi
  | .all_past _ => false       -- REJECT H
  | .all_future phi => is_future_only phi
  | .untl phi psi => is_future_only phi && is_future_only psi
  | .snce _ _ => false         -- REJECT S

-- "contains no future temporal operators" (no all_future, no untl)
def is_past_only : Formula -> Bool
  | .atom _ => true
  | .bot => true
  | .imp phi psi => is_past_only phi && is_past_only psi
  | .box phi => is_past_only phi
  | .all_past phi => is_past_only phi
  | .all_future _ => false     -- REJECT G
  | .untl _ _ => false         -- REJECT U
  | .snce phi psi => is_past_only phi && is_past_only psi
```

Then:
```lean
def is_properly_separated : Formula -> Bool
  | .atom _ => true
  | .bot => true
  | .imp phi psi => is_properly_separated phi && is_properly_separated psi
  | .box _ => true
  | .all_past phi => is_past_only phi    -- H(phi) where phi has no future ops
  | .all_future phi => is_future_only phi -- G(phi) where phi has no past ops
  | .untl phi psi => is_future_only phi && is_future_only psi
  | .snce phi psi => is_past_only phi && is_past_only psi
```

**Key advantages**:
1. `is_future_only` correctly captures "pure future" for our primitive operators
2. `is_past_only` correctly captures "pure past" for our primitive operators
3. `all_future(neg A)` IS future-only when A has no temporal operators (as required in Cases 2-4)
4. `snce(all_future p)(q)` is NOT properly separated -- correctly rejects G inside S
5. Aligns with the semantic purity needed by Theorem 9.3.1

**Impact on Cases 1-4**:
- Case 1: Output has no `all_future`/`all_past`. The snce arguments (a, q, A, B, combinations thereof) are all U-free AND S-free, hence past-only. The untl argument uses A, B which are S-free, hence future-only. **SURVIVES**.
- Case 2: Output has `snce(and a (all_future(neg A))) q`. The snce argument `and a (all_future(neg A))`: is this past-only? `all_future(neg A)` has `all_future`, which is a future operator. So this is NOT past-only. **BREAKS**.

**Hmm**. Case 2's output formula puts `G(neg A)` inside an `snce` argument. In GHR94's encoding, this is `neg U(A, top)` inside S, which IS a violation. The GHR94 formula for Case 2 (p. 572) is different: it does NOT put G inside S. Let me re-read GHR94 Case 2.

GHR94 Case 2 result (from the literature):
```
S(a ^ not U(A,B), q)  <->
  [S(a, q ^ not A) ^ not A ^ not U(A,B)]
  v [not A ^ not B ^ S(a, not A ^ q)]
  v S(not A ^ not B ^ q ^ S(a, not A ^ q), q)
```

**This formula does NOT contain G at all!** It uses `not U(A,B)` at the top level (outside S) and `not A` inside S-arguments, but no G. Our Lean Case 2 produces a DIFFERENT formula that uses `G(neg A)` = `all_future(neg A)` inside an S, which is not GHR94's formula.

This reveals a deeper issue: **our Case 2 proof uses a different equivalent formula than GHR94**. Our formula works under the weak predicate but not under the correct one.

**Option D effort estimate**:
- New definitions: 3 (`is_future_only`, `is_past_only`, `is_properly_separated`). Small.
- Cases 1: Survives. Zero effort.
- Cases 2-4: Need to produce different output formulas matching GHR94's actual formulas. SIGNIFICANT effort (rewrite 3 proofs, each ~100-200 lines).
- Duality: New dual theorems for `is_future_only` <-> `is_past_only` under swap. Moderate.
- SeparationThm: Axioms updated to new predicate. Small.
- ExpressiveCompleteness: Now properly guaranteed. Zero extra effort.

---

## 8. Recommended Fix

### Primary Recommendation: Option D (Redefine separated with future-only/past-only predicates)

**Rationale**:
1. It correctly models the semantic purity property that GHR94 requires
2. It preserves the primitive G/H constructors (no need to change Formula type)
3. It is the only option that properly supports Theorem 9.3.1
4. Case 1 proof survives unchanged
5. The duality infrastructure adapts naturally (`is_future_only(swap phi) = is_past_only(phi)`)

### Implementation Plan

**Phase 1: New definitions** (small effort)
- Add `is_future_only`, `is_past_only`, `is_properly_separated` to Defs.lean
- Keep the old definitions (they may be useful for intermediate steps)
- Add `is_properly_separable` using the new predicate

**Phase 2: Prove semantic purity lemmas** (moderate effort)
- Prove: `is_future_only phi = true -> is_pure_future phi` (all_future contributes to purity)
- Prove: `is_past_only phi = true -> is_pure_past phi` (all_past contributes to purity)
- Prove: `is_properly_separated phi = true -> semantic separation` (the key bridge)

**Phase 3: Rewrite Cases 2-4** (significant effort)
- Rewrite Case 2 to produce GHR94's actual formula (no G inside S)
- Rewrite Case 3 analogously (no H inside U)
- Rewrite Case 4 analogously
- Case 1 stays unchanged

**Phase 4: Update duality and separation theorem** (moderate effort)
- Prove `dual_future_only_iff_past_only` and `dual_properly_separated`
- Update temporal closure axioms to use `is_properly_separable`
- Update `all_separable` (structural induction argument is the same)

**Phase 5: Complete Theorem 9.3.1** (already possible after Phase 2)
- The `separation_implies_expressiveness` proof can now use the purity lemmas

### Effort Estimate

| Phase | Effort | Risk |
|-------|--------|------|
| Phase 1: Definitions | Low (30 LOC) | Low |
| Phase 2: Purity lemmas | Moderate (100-150 LOC) | Low |
| Phase 3: Rewrite Cases 2-4 | High (300-500 LOC) | Medium (semantic proofs) |
| Phase 4: Duality + SepThm | Moderate (100-150 LOC) | Low |
| Phase 5: Theorem 9.3.1 | High (already sorry) | High (independent difficulty) |
| **TOTAL** | **~600-900 LOC** | **Medium** |

### Alternative: Keep current definitions, add bridge lemma

If rewriting Cases 2-4 is too costly, a pragmatic alternative is to:

1. Define `is_properly_separated` as above
2. Prove: `is_syntactically_separated phi = true -> exists psi, is_properly_separated psi = true /\ int_equiv phi psi`
   - This would essentially say: every weakly-separated formula can be made properly separated by replacing `all_future(phi)` with `neg(untl(neg phi)(neg bot))` and `all_past(phi)` with `neg(snce(neg phi)(neg bot))` in the appropriate positions
   - This is semantically valid but would increase formula complexity
3. Use this bridge in `separation_implies_expressiveness`

This approach avoids rewriting Cases 2-4 but adds a post-processing step. The bridge lemma is non-trivial but doable (structural induction, replacing one constructor with its semantic encoding).

**Effort**: ~200 LOC for the bridge lemma. Lower risk than rewriting Cases 2-4.

---

## Appendix: Cross-reference of Key Definitions

| Concept | Our Lean name | Our semantics | GHR94 name | GHR94 semantics | Match? |
|---------|--------------|---------------|------------|-----------------|--------|
| U operator | `untl` | primitive constructor | U | primitive connective | YES |
| S operator | `snce` | primitive constructor | S | primitive connective | YES |
| G operator | `all_future` | primitive constructor | G = neg U(neg -, top) | derived | MISMATCH |
| H operator | `all_past` | primitive constructor | H = neg S(neg -, top) | derived | MISMATCH |
| F operator | `some_future` | derived | F = U(-, top) | derived | YES |
| P operator | `some_past` | derived | P = S(-, top) | derived | YES |
| U-free | `is_U_free` | no `untl` | U-free | no U (hence no G, F) | WEAKER |
| S-free | `is_S_free` | no `snce` | S-free | no S (hence no H, P) | WEAKER |
| Separated | `is_syntactically_separated` | no untl under snce, no snce under untl | separated | no U under S, no S under U (incl. G/H) | WEAKER |
| Separable | `is_separable` | exists weakly-separated equiv | separable | exists strongly-separated equiv | WEAKER |

---

## Appendix: Axiom and Sorry Inventory (Current State)

| Location | Type | Name | Impact of purity fix |
|----------|------|------|---------------------|
| Eliminations.lean | axiom | `elim_case_5_axiom` | Hypotheses unchanged (atoms are both-free) |
| Eliminations.lean | axiom | `elim_case_6_axiom` | Same |
| Eliminations.lean | axiom | `elim_case_7_axiom` | Same |
| Eliminations.lean | axiom | `elim_case_8_axiom` | Same |
| SeparationThm.lean | axiom | `all_past_separable` | Needs update to new predicate |
| SeparationThm.lean | axiom | `all_future_separable` | Needs update to new predicate |
| SeparationThm.lean | axiom | `untl_separable` | Needs update to new predicate |
| SeparationThm.lean | axiom | `snce_separable` | Needs update to new predicate |
| DualEliminations.lean | sorry | All 8 cases | Need new approach (not just duality) |
| ExpressiveCompleteness.lean | sorry | `separation_implies_expressiveness` | Unblocked after purity fix |
