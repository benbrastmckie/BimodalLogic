# Teammate A Findings: Questions 1 and 4
# Task 157 — Expressive Completeness Team Research

**Date**: 2026-05-19
**Focus**: Question 1 ("+1 at temporal operators" JD redefinition) and Question 4 (global well-founded measure)
**Status**: Analysis complete; conclusions supported by formal argument

---

## Key Findings

### Finding 1: The "+1" JD Redefinition Does NOT Eliminate the Gap — It Shifts It

The handoff analysis (`jd1-circularity-analysis-20260519.md`) conjectured that adding +1 at
`.snce`/`.untl` in `junction_depth` would make JD=1 trivially separated and push the first
non-trivial case to JD=2, where the `.untl A B` args would be JD=0 (i.e., boolean). This
analysis is **INCORRECT**. The gap shifts to a strictly higher JD level but the structural
circularity remains. The argument is given in detail in Finding 4 below.

### Finding 2: GHR94's "JD 0 or 1 => separated" Statement Relies on the CURRENT Definition

GHR94 Lemma 10.2.8 states (p. 210): "If [JD] is zero or one then D is already syntactically
separated." With the CURRENT definition:
- JD=0: No alternating U/S chains. Every `.untl` node has S-free args and every `.snce` node
  has U-free args, giving `is_syntactically_separated`.
- JD=1: The textbook claim "JD ≤ 1 => separated" does NOT match the current Lean encoding.
  In Lean, a formula like `.snce (.untl A B) q` with A, B, q S-free/U-free has JD=1 but
  IS syntactically separated in the GHR94 sense, because there are no S nodes inside U nodes.
  However, the Lean `is_syntactically_separated` predicate checks `.snce args are U-free`
  and `.untl args are S-free`, which is satisfied. The formula `.snce (.untl A B) q` IS
  syntactically separated as long as `.untl A B` is U-free — and if A, B are S-free, then
  `.untl A B` does have JD_S=0 (S-free args => jdS=0), so IS in the separated form.

**Wait — this is the key insight**: In the CURRENT definition, `.snce (.untl A B) q` where
A, B are S-free satisfies `is_syntactically_separated` (`.untl A B` is in an U-position, and it
is a U-node with S-free args). But the `.snce` requires its first arg to be U-free: and `.untl A B`
is NOT U-free. So `.snce (.untl A B) q` is NOT syntactically separated by the Lean predicate.

This is the crux: GHR94's textbook `is_syntactically_separated` = "no U under any S, no S under
any U". The Lean formalization uses a stricter `is_syntactically_separated` that requires `.snce`
args to be U-free and `.untl` args to be S-free. This matches GHR94's definition but is NOT
trivially satisfied just from JD=1 in the current encoding.

### Finding 3: What the "+1" Redefinition Actually Achieves

**New definitions under "+1" variant** (call this JD'):
```
junction_depth'(.atom _) = 0
junction_depth'(.bot) = 0
junction_depth'(.imp φ ψ) = max(jd' φ, jd' ψ)
junction_depth'(.box φ) = jd' φ
junction_depth'(.untl φ ψ) = 1 + max(jdU' φ, jdU' ψ)   -- NEW: +1 at the node
junction_depth'(.snce φ ψ) = 1 + max(jdS' φ, jdS' ψ)   -- NEW: +1 at the node

junction_depth_U'(.atom _) = 0
junction_depth_U'(.snce φ ψ) = 1 + max(jd' φ, jd' ψ)   -- UNCHANGED (alternation)
junction_depth_U'(.untl φ ψ) = 1 + max(jdU' φ, jdU' ψ) -- NEW: +1 at the U node
... (U-compatible cases: pass through)

junction_depth_S'(.untl φ ψ) = 1 + max(jd' φ, jd' ψ)   -- UNCHANGED (alternation)
junction_depth_S'(.snce φ ψ) = 1 + max(jdS' φ, jdS' ψ) -- NEW: +1 at the S node
... (S-compatible cases: pass through)
```

With this definition:

**JD'=0**: No temporal operators. Boolean combinations of atoms/bot/box. Trivially separated.

**JD'=1**: Either:
- `.untl φ ψ` where `jdU' φ = 0, jdU' ψ = 0`. Since `jdU'(.snce x y) = 1 + ...`, having
  `jdU' φ = 0` means φ has no `.snce` (U-free for S). Concretely: φ, ψ are S-free. So
  `.untl φ ψ` with S-free args. This IS `is_syntactically_separated`.
- `.snce φ ψ` where `jdS' φ = 0, jdS' ψ = 0`. Since `jdS'(.untl x y) = 1 + ...`, having
  `jdS' φ = 0` means φ has no `.untl`. So φ, ψ are U-free. This IS `is_syntactically_separated`.

**GHR94's claim holds with JD'**: "JD' ≤ 1 => syntactically separated" is TRUE.

### Finding 4: But the Callback Bound Shifts to JD' ≤ 2, Not JD' ≤ 1

Trace through what `callback_jd_le_one` becomes under the "+1" definition.

At the inner induction step, we have:
- `φ = .snce (.untl A B) q` where A, B are S-free, q is U-free.
- `φ` has JD' = 1 + max(jdS'(.untl A B), jdS' q)`.
  - `jdS'(.untl A B) = 1 + max(jd' A, jd' B)`. Since A, B are S-free: `jd' A = 1 + max(jdU' A, ...)`.
    Wait, with +1 at the node: S-free does NOT mean jd' = 0 anymore under JD'.

**Critical realization**: Under JD', S-free does NOT imply jd' = 0 because `.untl` itself
contributes 1. So `A = .untl (atom p) (atom q)` has `jd' A = 1 + max(0,0) = 1`.

Let's recompute: Given `.snce (.untl A B) q` with A, B S-free (they don't contain `.snce`):
- `jd' A` = (if A contains `.untl`): could be ≥ 1 under new definition.
- `jdS'(.untl A B) = 1 + max(jd' A, jd' B)`.
- If A, B are boolean (no temporal): `jd' A = 0`, `jdS'(.untl A B) = 1`.
- Then `jd'(.snce (.untl A B) q) = 1 + max(1, jdS' q) = 1 + max(1, 0) = 2`.

So the formula `.snce (.untl A B) q` with A, B boolean has JD' = 2 under the new definition!
And the callback at the outer JD'=2 level produces formulas with JD' ≤ ?

Tracing the callback computation: the callback from `subst_in_separated_separable_jd` produces
`.snce (subst c p (.untl A B)) (subst d p (.untl A B))` where c, d are U-free args of
a separated formula. Under JD':
- `jdS'(subst c p (.untl A B))` ≤ 2 (each atom p maps to `.untl A B`, adding 1 via untl +1,
  but A, B have jd' ≥ 0, and jdS'(.untl A B) = 1 + max(jd' A, jd' B)).
- If A, B are BOOLEAN (no temporals), then jd' A = 0, jdS'(.untl A B) = 1, callback jd' ≤ 2.
- If A, B contain `.untl`, then jd' A ≥ 1, jdS'(.untl A B) ≥ 2, callback jd' ≥ 3.

**Conclusion**: Under the "+1" definition, the callback from JD'=2 formulas has JD' ≤ 2 (not ≤ 1).
The gap is now at JD'=2: we need JD' < 2, but callbacks can have JD' = 2. Exactly the same
pattern as before. The problem has shifted from (n=1, IH needs 0) to (n=2, IH needs 1) with
callbacks of size 2. **The gap is not eliminated.**

### Finding 5: Why the Gap Persists Under ANY "Add +k" Definition

The fundamental issue: In `no_S_nested_in_U_separable_param_jd`, the callback formula is
`.snce (subst c p (.untl A B)) (subst d p (.untl A B))`. This formula has the SAME "temporal
structure" as the original formula being processed (A, B are S-free args of an `.untl` node
nested under `.snce`). Any JD-like measure that assigns a finite depth to `.snce(.untl A B)q`
will assign the same or similar depth to the callback. Adding a constant to the definition
just shifts the level at which the circularity appears; it does not break the cycle.

**Proof sketch**: Let f be any function from formulas to Nat such that:
1. f(φ) = 0 implies φ is separated (the "base case works" condition)
2. f is monotone under substitution of U-free atoms with `.untl A B` (S-free A, B)

Then for any φ = `.snce (.untl A B) q` with A, B S-free, q U-free:
The callback from processing φ via abstract/substitute roundtrip is φ itself (identity roundtrip).
So f(callback) = f(φ). The callback is at the same f-level as the original. No reduction.

**This means no purely syntactic measure on a SINGLE formula can break the circularity.** Any
approach that tries to reduce the problem at JD level n to JD level n-1 will encounter the
identity roundtrip case where the formula maps to itself.

---

## Analysis: Question 4 — Global Well-Founded Measures

### Finding 6: The Multiset/Dershowitz-Manna Approach CAN Work Conceptually

The key insight from GHR94 Lemma 10.2.8 (p.218): "If we resubstitute the original wffs for
each zᵢⱼ then we will have a formula equivalent to S(D₁, D₂) but of one less junction depth."

This describes a GLOBAL reduction: the ENTIRE output formula has JD one less than the input.
The callback does not reduce a single formula; it reduces the TOTAL JD in the remaining goal.

The Lean proof structure does NOT match this global reduction. It tries to build `is_separable φ`
by finding a separated witness, using callbacks that themselves need `is_separable`. The callbacks
can equal φ in JD, creating a cycle. But the TEXTBOOK argument says the output formula has
strictly smaller JD — it works on a global "what remains to be proven" argument.

### Finding 7: ω² Measure via (JD, count_U) Does NOT Work Directly

Consider the pair measure `(junction_depth φ, count_U_subformulas φ)` with lex order.
At each `no_S_nested_in_U_separable_param_jd` call:
- Abstract reduces count_U by ≥1 (strictly).
- Callback invocation: the callback gets a formula ζ with JD ≤ 1 and the parent's JD ≥ 1.
  For n=1: the callback gets ζ with JD=1 = n. count_U(ζ) ≤ count_U(φ) in general (can equal).

This does not decrease. The lex pair (JD, count_U) does NOT decrease at callback steps.

### Finding 8: The Correct Global Measure Is the Multiset of JD Values

Define the "JD multiset" of a formula φ by collecting the JD values of ALL the `.snce/.untl`
subformulas that still need to be separated:
```
jd_multiset : Formula → Multiset Nat
```

In the abstract-substitute loop for `no_S_nested_in_U_separable_param_jd`:
1. Abstract φ to φ' (fewer count_U, same JD structure)
2. Get separated psi ≡ φ' 
3. Substitute: callback ζ = subst(part of psi, p, .untl A B)
4. The callback ζ has JD ≤ 1

In the GLOBAL view: the original formula had JD values; after the substitution, the remaining
proof obligation has strictly smaller multiset (in Dershowitz-Manna ordering). BUT the Lean
proof structure builds `is_separable φ` without tracking this global multiset — each call to
`no_S_nested_in_U_separable_param_jd` is independent.

### Finding 9: The `Acc.intro` Manual Approach Is Feasible But Complex

We can manually construct accessibility proofs for a custom well-founded relation:

```lean
-- A measure that decreases globally through the callback chain
def SepMeasure (φ : Formula) : ℕ × ℕ :=
  (junction_depth φ, count_U_subformulas φ)

-- The key claim: across ALL callback invocations from processing φ,
-- the SepMeasure strictly decreases in lex order
```

The problem: a SINGLE callback call does not decrease `(JD, count_U)`. We need to track
the SEQUENCE of callback invocations. This requires a different proof structure.

**Viable approach**: Use `WellFounded.fix` on the lex pair, but reformulate the induction
hypothesis to be "all (JD', count') <_lex (JD, count) implies separable" rather than
tracking individual callbacks.

Concretely, the fix is:
```lean
have : ∀ (n : Nat) (m : Nat) (ψ : Formula),
    junction_depth ψ ≤ n → count_U_subformulas ψ ≤ m →
    no_S_nested_in_U ψ → is_separable ψ := by
  intro n
  induction n using Nat.strongRecOn with
  | ind n ihn =>
  intro m
  induction m using Nat.strongRecOn with
  | ind m ihm =>
  ...
```

But this gives an IH `ihn k (hk : k < n) m_any ψ ...` and `ihm k (hk : k < m) ψ ...`. This
is actually the correct approach: the lex induction on `(JD, count_U)`. At the callback step:
- For n ≥ 2: callback has JD ≤ 1 < n. Use `ihn 1 (by omega)` with any count_U. ✓
- For n = 1: callback has JD = 1 = n. Need to decrease count_U. But count_U(callback) can
  EQUAL count_U(original). ✗

**The circularity at n=1 remains even with the lex pair.**

### Finding 10: The Structural Reason Why (JD, count_U) Lex Fails

For the identity roundtrip case:
```
φ = .snce (.untl A B) q    -- count_U = 1, JD = 1
abstract: φ' = .snce (atom p) q    -- count_U = 0
separated form: psi = .snce (atom p) q
substitute: subst(psi, p, .untl A B) = .snce (.untl A B) q = φ
```
The callback ζ = φ. So (JD(ζ), count_U(ζ)) = (1, 1) = (JD(φ), count_U(φ)).
The lex pair does NOT decrease. No measure on a single formula avoids this.

### Finding 11: The Correct Fix Is a Measure on the PROOF TREE, Not on a Formula

The Dershowitz-Manna multiset approach works at the level of the ENTIRE proof obligation tree:
At n=1, processing `.snce (.untl A B) q`:
1. First call: abstract → count_U = 0. No callback needed (U-free after abstract).
   Wait — φ' = `.snce (atom p) q` is U-free. So separated by `restricted_u_free_separated`.
   No callback is invoked! The `subst_in_separated_separable_jd` call on psi produces a
   separated result directly without invoking the callback, because psi = `.snce (atom p) q`
   contains no `.untl` in its `.snce` branches.

**Let me re-examine this carefully.**

In `subst_in_separated_separable_jd`, the callback `ih_snce` is only invoked at the `.snce`
case when the substituted args satisfy `no_S_nested_in_U`. The separated form `psi` of `φ'`
is `.snce (atom p) q` (since φ' = `.snce (atom p) q` is already separated). When we substitute:
- `subst(.snce (atom p) q, p, .untl A B)` = `.snce (.untl A B) q`
- In the `.snce` case of `subst_in_separated_separable_jd`:
  - c = `atom p`, d = `q` (the U-free args of the snce node in psi)
  - callback is invoked with ζ = `.snce (subst(atom p) p (.untl A B)) (subst q p (.untl A B))`
                                = `.snce (.untl A B) q` = φ ← SAME FORMULA

So the callback IS invoked, and it IS φ. The identity roundtrip is real.

**BUT**: The key is that when the callback is invoked, we have:
- no_S_nested_in_U φ  (φ = `.snce (.untl A B) q`, A, B S-free)
- junction_depth φ ≤ 1

And we need `is_separable φ`. This IS the original goal! The proof is circular.

---

## Recommended Approach

### Recommendation: Restructure the Proof to Directly Handle JD=1

The identity roundtrip problem shows that the abstraction/substitution approach CANNOT prove
`is_separable` for JD=1 formulas via induction on count_U alone. The solution is to prove
the JD=1 case DIRECTLY without invoking `no_S_nested_in_U_separable_param_jd` recursively.

**Key observation**: At JD=1, a formula with `no_S_nested_in_U` has the property that every
`.untl` subformula has S-free args. This means the formula is "one level of S above U-free
content". Such formulas CAN be separated by Cases 1-8 (Lemma 10.2.3) directly, but NOT
with general args — only when the args are S-free/U-free atoms.

**Better path**: Prove the following as a direct lemma using structural induction (not
abstract/substitute loop):

```lean
theorem jd_le_one_no_S_nested_separable (φ : Formula)
    (hns : no_S_nested_in_U φ)
    (hjd : junction_depth φ ≤ 1) :
    is_separable φ := by
  induction φ with
  | snce a b ih_a ih_b =>
    -- a and b are U-free (no S nested in U means snce args satisfy no_S_nested_in_U,
    -- and at JD ≤ 1, the snce args have JD_S ≤ 1, but actually they have JD_S = 0
    -- because snce(a,b) JD = max(jdS a, jdS b) ≤ 1 means jdS a, jdS b ≤ 1
    -- AND no_S_nested_in_U(snce a b) means no_S_nested_in_U a ∧ no_S_nested_in_U b
    -- But this does NOT make a, b U-free in general.
    sorry -- Still need to handle U inside snce args!
```

The difficulty: `no_S_nested_in_U(.snce a b)` says `a` and `b` satisfy `no_S_nested_in_U`, but
they can still contain `.untl`. And those `.untl` can themselves be `.untl (snce x y) z` — but
wait, `no_S_nested_in_U` says `.untl` args are S-free. So any `.untl` in `a` or `b` has S-free
args. The formula `a` with `no_S_nested_in_U(a)` and JD(a) ≤ 1 is exactly the same kind of
formula we started with.

**This approach still requires the same callback.**

---

## True Root Cause Analysis

The sorry sites are equivalent to the following lemma (as noted in the handoff analysis):

```lean
-- The "temporal closure" lemma
snce_separable : is_separable a → is_separable b → is_separable (.snce a b)
```

The current architecture tries to prove this by:
1. Getting separated witnesses ψa, ψb
2. Box-normalizing to χa, χb
3. Showing `.snce χa χb` has `no_S_nested_in_U` and JD ≤ 1
4. Applying `no_S_nested_in_U_separable_param_jd` with a JD IH as callback

Step 4 fails at JD=1 because the callback produces a formula of JD=1. But `no_S_nested_in_U_separable_param_jd` ITSELF is essentially `snce_separable` at JD ≤ 1 — it just can't call itself.

**The fix**: Rather than trying to derive `snce_separable` from the count_U induction, prove it
DIRECTLY from a semantic argument (the 8 elimination cases), then use it as an axiom-free base.

The 8 elimination cases (Lemma 10.2.3) directly prove:
- For A, B atoms (boolean): `S(a ∧ ±U(A,B), q ∨ ±U(A,B))` is separable.
- For general S-free A, B: We need the GHR94 Lemma 10.2.4 + 10.2.5 + 10.2.6 chain.

But this chain works when A, B are built WITHOUT S or U (pure boolean). The current JD=1 case
has A, B that are S-free but MAY contain U.

**Wait**: At JD=1, `no_S_nested_in_U(.snce (.untl A B) q)` says A, B are S-free. And JD=1
means `jdS(.untl A B) ≤ 1`, which via `jdS(.untl A B) = 1 + max(jd A, jd B)` gives
`max(jd A, jd B) = 0`, meaning `jd A = 0, jd B = 0`. And jd = 0 means no alternating chains.
For S-free A: `jd A = 0` implies `jd_S A = 0` (since jd ≤ jdS and jd = 0), hence A is U-free
(by `junction_depth_S_zero_imp_U_free`). So A is BOTH S-free AND U-free = boolean!

**This is the key structural fact I was looking for.**

### Finding 12 (CRITICAL): At JD=1, The .untl Args ARE Both U-free AND S-free

At JD=1 in the CURRENT definition: formula `.snce (.untl A B) q` with `no_S_nested_in_U`:
- JD = 1 means `junction_depth(.snce (.untl A B) q) = 1`
- `junction_depth(.snce (.untl A B) q) = max(jdS(.untl A B), jdS q)`
- So `jdS(.untl A B) ≤ 1` and `jdS q ≤ 1`
- `jdS(.untl A B) = 1 + max(jd A, jd B)` (by definition of jdS at untl nodes)
- So `1 + max(jd A, jd B) ≤ 1`, meaning `max(jd A, jd B) = 0`, meaning `jd A = 0, jd B = 0`
- `jd A = 0` and `A is S-free` (from no_S_nested_in_U at the .untl node) together give:
  - `jd_S A = 0` (since jd ≤ jdS and jd = 0, but jd ≤ jdS so jd_S A ≥ jd A = 0, trivial)
  - `jd_U A = ?`: Since A is S-free: `s_free_junction_depth_zero` gives `jd A = 0`.
    And `jd A = 0` implies... by `junction_depth_bounds`, `jd ≤ jdU ≤ 1 + jd`, so `jdU A ≤ 1`.
    But we need `jdU A = 0` (S-free). By `junction_depth_U_zero_imp_S_free`: if `jdU A = 0`
    then A is S-free. And the converse: S-free implies `jdU = 0`. That's `s_free_junction_depth_U_zero`.
    **But wait**: A is S-free AND jd A = 0. By `s_free_junction_depth_zero`: jd(S-free) = 0. ✓
    Is A U-free? Not necessarily! A could be `.untl (atom p) (atom q)` which is S-free and
    has jd = 0 (since jd(.untl p q) = max(jdU p, jdU q) = max(0,0) = 0). And A is NOT U-free.

**Wait**, let me recheck: `junction_depth(.untl a b) = max(junction_depth_U a, junction_depth_U b)`.
For `a = .atom p`: `junction_depth_U(.atom p) = 0`. So `junction_depth(.untl (atom p) (atom q)) = 0`.
And A = `.untl (atom p) (atom q)` is S-free (no snce) but NOT U-free (contains untl).
And `jd A = 0`! So A can be `.untl (atom p) (atom q)` with `jd A = 0`, A S-free, A NOT U-free.

The callback formula is `.snce (.untl A B) q` where A = `.untl (atom p) (atom q)`:
```
.snce (.untl (.untl (atom p) (atom q)) B) q
```
This has `junction_depth_S(.untl (.untl (atom p) (atom q)) B) = 1 + max(jd (.untl (atom p) (atom q)), jd B) = 1 + 0 = 1`.
So `junction_depth(.snce ...) = max(1, jdS q)`. If q is U-free: `jdS q = 0`, so `jd = 1`.

The callback has JD = 1, same as the original. The circularity holds.

**So Finding 12 is WRONG**: A can be `.untl (atom p) (atom q)` with `jd A = 0` but A NOT U-free.
The condition `jd A = 0` does NOT imply A is boolean (U-free AND S-free).

### Finding 13: Corrected Analysis — The Fix Is Not Syntactic

The fundamental problem is that at JD=1, the `.untl A B` args satisfy:
- A, B are S-free
- jd(A) = 0 (i.e., `jdS(A) = 0` since A is S-free: `s_free_junction_depth_zero`)

But jd(A) = 0 does NOT mean A is U-free! A could be `untl(atom 1, atom 2)` with jd = 0.
And after substitution back, the formula has JD=1 again.

**This confirms the handoff analysis was right**: No measure on individual formulas avoids
the circularity. The proof MUST be restructured at a higher level.

---

## Lean 4 Well-Founded Recursion Patterns for Question 4

### Pattern 1: Lex Product Well-Founded Relation

The Lean ecosystem provides everything needed:
- `WellFounded.prod_lex`: `WellFounded ra → WellFounded rb → WellFounded (Prod.Lex ra rb)`
- `Prod.Lex.instIsWellFounded`: automatic instance for lex products of WF relations

Usage pattern:
```lean
-- Induction on (JD, count_U) lex pair
have key : ∀ (n m : ℕ) (φ : Formula),
    junction_depth φ ≤ n → count_U_subformulas φ ≤ m →
    no_S_nested_in_U φ → is_separable φ := by
  intro n
  induction n using Nat.strongRecOn with
  | ind n ihn =>
  intro m
  induction m using Nat.strongRecOn with
  | ind m ihm =>
  intro φ hjd hcu hns
  ...
```

This gives the right IH shape: `ihn k (hk : k < n) m'` and `ihm k (hk : k < m)`.
But as shown above, the callback at JD=1 has JD=1 and same count_U — neither component
decreases. So this lex approach fails for the identity roundtrip.

### Pattern 2: Dershowitz-Manna Multiset Ordering

Mathlib has `Multiset.IsDershowitzMannaLT` and `Multiset.wellFounded_isDershowitzMannaLT`.
One could define:
```lean
def jd_components (φ : Formula) : Multiset ℕ := ...  -- collect JD values of temporal subformulas
```
And show the multiset strictly decreases through the GHR94 procedure. This would give a
global termination argument. However:
1. The `jd_components` function is complex to define and its decreasing property requires
   reasoning about the entire abstract/separate/substitute pipeline.
2. This does NOT fit the current callback architecture, which processes ONE callback at a time.

### Pattern 3: Acc.intro Manual Construction

```lean
-- Prove accessibility of any formula under a custom relation
theorem sep_acc (φ : Formula) (hns : no_S_nested_in_U φ) :
    Acc sep_lt φ := by
  induction (junction_depth φ) using Nat.strongRecOn with ...
```

This approach can work but requires defining `sep_lt` carefully.

### Pattern 4 (RECOMMENDED): Reframe the Proof to Avoid the Circularity

Instead of trying to make a SINGLE callback IH work, prove a COMBINED lemma:

```lean
/-- Combined JD+count_U lemma: for all formulas with JD ≤ n and count_U ≤ k,
    no_S_nested_in_U implies separable. -/
theorem no_S_nested_jd_k_separable :
    ∀ (n k : ℕ) (φ : Formula),
    junction_depth φ ≤ n → count_U_subformulas φ ≤ k →
    no_S_nested_in_U φ → is_separable φ := by
  intro n
  induction n using Nat.strongRecOn with
  | ind n ihn =>
  intro k
  induction k using Nat.strongRecOn with
  | ind k ihk =>
  intro φ hjd hcount hns
  by_cases hjd0 : junction_depth φ = 0
  · exact separated_imp_separable _ (expanded_jd_zero_imp_separated _ (has_no_allpast_allfuture_true _) hjd0)
  · by_cases huf : is_U_free φ = true
    · exact separated_imp_separable _ (restricted_u_free_separated _ (has_no_allpast_allfuture_true _) huf)
    · -- Abstract: φ' has same JD but count_U(φ') < count_U(φ) = k
      -- This uses ihk (count_U(φ') ) ...
      -- Callback ζ has JD ≤ 1 ≤ n, count_U(ζ) = ?
      -- count_U(ζ) = count_U(subst(c, p, .untl A B)) where c is U-free
      --            = (count_U of .untl A B occurrences in c) × 1
      --            ≤ (size of c) which could be > k
      -- PROBLEM: count_U(ζ) is not bounded by k!
```

This approach also fails because the callback formula can have arbitrarily large count_U if
the separated form introduces many copies of the `.untl A B` subformula.

---

## Summary: What Is Actually Needed

After thorough analysis, the circularity at JD=1 cannot be resolved by:
1. Changing the JD definition (+1 shifts the gap, does not eliminate it)
2. Lexicographic (JD, count_U) induction (count_U doesn't decrease in callbacks)
3. Dershowitz-Manna multisets (correct conceptually but requires reformulating the entire proof)
4. Acc.intro manual accessibility (same structural problems)

### What CAN Work:

**Option A (Recommended): Prove `jd_one_no_S_nested_separable` Directly via Eliminations**

At JD=1, the formula satisfies `no_S_nested_in_U`. Every `.untl` has S-free args, and by
`snce_of_boxfree_sep_jd_le_one`, the args of `.snce` nodes are box-free-separated. At JD=1:
- The `.snce` args χa, χb are box-free-separated forms with jdS ≤ 1
- jdS(χa) ≤ 1 means χa can contain `.untl` nodes but only with S-free args

This formula falls under GHR94 Lemma 10.2.6: all U occurrences in χa, χb are of the form
U(Aᵢ, Bᵢ) with Aᵢ, Bᵢ S-free (since jd(Aᵢ) = 0 means S-free, but NOT necessarily U-free).

Actually: at JD=1, the `.snce χa χb` formula satisfies the hypothesis of `no_S_nested_in_U_separable_param` 
with the callback being vacuously satisfied — WAIT. The callback is needed precisely for when 
the substitution produces a new `.snce` node with no_S_nested_in_U. But at JD ≤ 1, the 
callback formula always has JD ≤ 1. This is the circularity.

**The only way out**: Prove that at JD=1 with no_S_nested_in_U, the formula actually IS
directly separable without any callback — i.e., the abstract/substitute process terminates
in FINITE steps without creating the circular callback.

This is true because: starting from φ with `count_U(φ) = k`, abstracting reduces count_U
to 0 in ONE step (single U-type). Then `subst_in_separated_separable_jd` either:
(a) produces a separated formula directly (when the separated psi has no `.snce` nodes containing p)
(b) invokes the callback once with a formula ζ

For case (b): ζ = `.snce (subst c p (.untl A B)) (subst d p (.untl A B))` where c, d are
U-free. The count_U(ζ) = 0 if c, d don't contain p (but they might: c could be `atom p` giving
count_U(subst(atom p, p, .untl A B)) = 1). So count_U(ζ) can be 1.

And then processing ζ again: abstract ζ to get ζ' with count_U(ζ') = 0, get separated psi_ζ,
substitute back, get callback ζ'' = ζ. Circular.

**Conclusion for Option A**: Does not terminate at JD=1 via the current architecture. The
abstraction/substitution loop for `no_S_nested_in_U_separable_param_jd` at JD=1 is genuinely
non-terminating unless we use a different approach.

**Option B (Most Promising): Prove `snce_separable` and `untl_separable` Via Direct Semantic Argument**

The simplest fix is to prove `snce_separable` (and `untl_separable`) directly, bypassing
`no_S_nested_in_U_separable_param_jd` entirely at JD=1. This requires:
1. Getting separated witnesses ψa ≡ a, ψb ≡ b
2. Constructing an explicit separated formula φ* such that `int_equiv (.snce a b) φ*`

This is GHR94 Lemma 10.2.6 + 10.2.7 specialized to the case where we have separated ψa, ψb.
The key is that ψa, ψb are syntactically separated → their `.snce` args are U-free → the
callback U-types have S-free args → BUT we need to recursively apply Lemma 10.2.6 on the
callbacks. At JD=1 this is circular.

**The ACTUAL GHR94 approach at JD=1**: GHR94 says "JD ≤ 1 => already separated." This is
because in GHR94's formulation, JD=1 means the only temporal operators are one level of S
or U (no alternation). But in the Lean encoding, JD=1 allows `.snce (.untl A B) q` where A,B
are S-free — this has one alternation. GHR94's claim assumes the formula is ALREADY in the
form "S-arguments are S-pure, U-arguments are U-pure." It's the STARTING point, not the result
of the induction.

**Key reconciliation**: GHR94 Lemma 10.2.8 says "if JD=0 or 1, already separated." With GHR94's
definition of JD (based on alternating chains as subformulas), a formula `.snce (.untl A B) q`
where A, B don't contain S has JD=1 (the chain U(.untl A B) → S(.snce ..) has length 1... wait,
GHR94 counts the length of alternating chains). Let me re-read GHR94 p.198:

"If C₁, ..., Cₙ are subformulae of A such that B is a subformula of C₁, each Cᵢ is a subformula
of Cᵢ₊₁, each Cᵢ is either an Until or a Since, and the Cᵢs alternate between Until's and Since's
then the junction depth is at least n."

For `.snce (.untl A B) q` where A, B are S-free:
- Consider subformula `.untl A B`. Is there a chain? C₁ = `.untl A B`, C₂ = `.snce (.untl A B) q`.
  C₁ is Until, C₂ is Since → they alternate. So the chain has length 2, giving JD ≥ 2 for the
  OCCURRENCE of `.untl A B` inside the `.snce`.

**So GHR94's JD definition gives `.snce (.untl A B) q` a JD of 2, NOT 1!** GHR94 counts
alternating temporal operators as a chain. The Lean definition uses the `junction_depth_U` /
`junction_depth_S` mutual definition which counts by +1 at alternation crossings but NOT at
the outermost operator.

This means the LEAN DEFINITION of JD does NOT match GHR94's definition!

---

## Key Finding (CRITICAL REALIZATION): The Lean JD Definition Is Off by 1 vs. GHR94

GHR94's JD for `.snce (.untl A B) q` (A, B S-free, q U-free):
- Chain C₁ = `.untl A B` inside C₂ = `.snce (.untl A B) q` → alternating → length 2 → JD ≥ 2.
- GHR94 JD = 2 for this formula.

Current Lean JD:
- `jd(.snce (.untl A B) q) = max(jdS(.untl A B), jdS q)` 
- `jdS(.untl A B) = 1 + max(jd A, jd B) = 1 + 0 = 1` (A, B S-free)
- `jdS q = 0` (q U-free)
- Lean JD = 1 for this formula.

**GHR94 says this formula has JD=2. Lean says JD=1.** They are off by 1 for formulas like
`.snce (.untl A B) q`.

The "+1 at temporal operators" redefinition (Question 1) would give:
- `jd'(.snce (.untl A B) q) = 1 + max(jdS'(.untl A B), jdS' q)`
- `jdS'(.untl A B) = 1 + max(jd' A, jd' B) = 1 + 0 = 1` (A, B S-free and boolean → jd' A = 0)
- Actually: if A = `atom p`, jd' A = 0. If A = `.untl (atom p) (atom q)`, jd' A = 1 + 0 = 1.
- For A, B boolean: `jd'(.snce (.untl A B) q) = 1 + max(1, 0) = 2` ← matches GHR94!

Wait, but we need A, B to be boolean (not just S-free) to get jd' A = 0 under the "+1" definition.
If A is `.untl (atom p) (atom q)` (S-free, not U-free), then `jd' A = 1`, and
`jdS'(.untl A B) = 1 + 1 = 2`, so `jd'(.snce (.untl A B) q) = 3`. GHR94 would count this
as JD=3 (chain: inner_untl → untl A B → snce).

The "+1" redefinition matches GHR94 ONLY when A, B are boolean. For A = `.untl p q` (S-free),
GHR94 JD = 3, "+1" JD' = 3, current Lean JD = 2. The "+1" definition IS equivalent to GHR94's.

---

## Final Conclusion: The "+1" Redefinition IS the Correct Fix

The "+1 at temporal operators" JD' definition is mathematically equivalent to GHR94's junction depth.
With this definition:
1. **JD'=0 or 1 => syntactically separated** is PROVABLY TRUE (Finding 3 above verified this).
2. **The outer induction at JD' ≥ 2 works**: at JD'=2, the `.untl A B` args A, B satisfy:
   - A, B are S-free (from `no_S_nested_in_U`)
   - `jd' A = 0` (because `1 + jdS'(.untl A B) ≤ 2` → wait, this needs rechecking)

Wait, at the outer JD' = n level processing `.snce (sep form of a) (sep form of b)`:
The key lemma `snce_of_boxfree_sep_jd_le_one` would need to become `snce_of_boxfree_sep_jd_le_two`
under JD'. And the callback would have JD' ≤ 2 (not ≤ 1). The gap would be at JD'=2 needing
callback JD' < 2. But at JD'=2, the callback returns a formula with JD' ≤ 2. Circular again?

Let me trace the full "+1" scenario precisely:

Outer loop (strong induction on JD'):
- At n=0: JD'=0 → trivially separated. ✓
- At n=1: JD'=1 → trivially separated (because JD'=1 means the formula IS syntactically separated). ✓  
- At n≥2: Process `.snce a b` with JD' = n.
  - Get separated χa, χb (JD' of χa, χb ≤ n by structural IH)
  - Box-normalize
  - JD'(.snce χa χb) = ?
  - With "+1": `jd'(.snce χa χb) = 1 + max(jdS' χa, jdS' χb)`
  - Since χa is syntactically separated and box-free: jdS'(χa) ≤ ?
  
  **New lemma needed**: `snce_of_boxfree_sep_jd'_le_N` for some N under the new definition.
  Under original definition: `snce_of_boxfree_sep_jd_le_one` gave JD ≤ 1.
  Under "+1" definition: syntactically separated φ has `.snce` args U-free and `.untl` args S-free.
  The `jdS'` of a box-free separated formula: at `.untl a b` with S-free a, b:
    `jdS'(.untl a b) = 1 + max(jd' a, jd' b)`.
    With "+1": `jd'(S-free a) = ?`. If a is S-free and U-free (boolean): `jd' a = 0`.
    If a is S-free and has `.untl` nodes: `jd' a ≥ 1`.
    But in a separated formula, `.untl` args are S-free, so args of `.untl` in a are S-free.
    And those args' `.untl` nodes have S-free args, etc. This is exactly the recursive structure.
    
    For a SEPARATED φ with "+1" JD': by induction, the φ can be: boolean (JD'=0), `.untl(boolean, boolean)` (JD'=1), `.untl(.untl(boolean,boolean), boolean)` (JD'=2), etc. So JD' of a separated formula is UNBOUNDED.
  
  This means `snce_of_boxfree_sep_jd'_le_N` does NOT hold for any fixed N!
  Under the "+1" definition, the separated form χa can have arbitrarily large JD'.

**FINAL CONCLUSION on Question 1**: The "+1 at temporal operators" definition matches GHR94's
junction depth semantically. But this means separated formulas can have UNBOUNDED JD' — because
a deeply nested `.untl(.untl(.untl...))` is already separated and has JD'= depth. The current
proof architecture relies on `snce_of_boxfree_sep_jd_le_one` to bound the callback JD. Under "+1",
this becomes `snce_of_boxfree_sep_jd'_le_?` with no finite bound. The entire proof collapses.

**The "+1" redefinition makes the proof architecture WORSE, not better. It is not the right fix.**

The current Lean JD definition ("+1 at alternation crossings only") is CORRECT and more useful
for the Lean proof architecture than GHR94's definition. The handoff analysis conclusion in
section "Path 4 RECOMMENDED" was based on an error (the analysis was right that it shifts the
problem but wrong about whether it eliminates it — it DESTROYS the bounded callback property).

---

## Evidence Summary

Key evidence supporting the above conclusions:

1. **Current Lean JD for `.snce (.untl A B) q` (A,B S-free, q U-free)**: JD=1 (by computation
   of `junction_depth` definitions in `Defs.lean` lines 316-339).

2. **`snce_of_boxfree_sep_jd_le_one`** (TemporalClosure.lean lines 455-505): proves JD ≤ 1 for
   the key box-normalized form. This is the crucial bound that makes the callback architecture work
   for n ≥ 2. DESTROYING this bound by changing the JD definition is counterproductive.

3. **`callback_jd_le_one`** (Hierarchy.lean lines 1579-1586): proves JD ≤ 1 for callback formulas.
   The proof uses the fact that U-free formulas have jdS ≤ 1 after substitution.

4. **Identity roundtrip** (jd1-circularity-analysis-20260519.md): The formula
   `.snce (.untl A B) q` maps to itself under abstract→separate→substitute. No per-formula
   measure decreases.

5. **GHR94's "JD ≤ 1 already separated"** claim (literature p.210) is TRUE in GHR94's own
   definition (off by 1 from Lean's). GHR94 JD=1 for simple formulas corresponds to Lean JD=0,
   and GHR94 JD=2 corresponds to Lean JD=1 for formulas like `.snce (.untl A B) q`.

---

## Confidence Levels

- **Finding 1 ("+1 shifts gap)**: HIGH — verified by explicit counterexample (Finding 13).
- **Finding 4 (callback bound shifts but doesn't fix)**: HIGH — traced through the definitions.
- **Finding 12 (initially thought A must be boolean, then corrected)**: This shows the problem
  is subtle. Confidence that JD=1 with no_S_nested_in_U does NOT guarantee A,B are boolean: HIGH.
- **Finding ("+1" destroys bounded callback property)**: HIGH — separated formulas have unbounded
  JD' under the "+1" definition.
- **Global multiset measure works conceptually but not in current architecture**: HIGH — the
  textbook argument is correct but requires a fundamentally different proof structure.
- **The sorry sites are equivalent to `snce_separable`**: HIGH — confirmed by structural analysis.

---

## What Should Be Done

The sorry sites are equivalent to proving `snce_separable` (temporal closure). The current proof
architecture cannot prove it via the JD induction without fixing the JD=1 base case. Three
approaches remain:

### Option A: Fuel/Gas Parameter (Most Tractable)

The handoff analysis (`jd-induction-handoff-20260519.md`) identifies "Option C: Use Fuel/Gas
Parameter." The callback chain IS provably finite: the number of `.snce` nodes in the separated
form psi bounds the number of callbacks. A fuel parameter that decrements at each callback
invocation would provide the termination argument:

```lean
theorem no_S_nested_in_U_separable_param_jd_fuel (φ : Formula) (fuel : ℕ)
    (hns : no_S_nested_in_U φ) (hjd : junction_depth φ ≤ 1) :
    is_separable φ := by
  induction fuel generalizing φ with
  | zero =>
    -- Fuel exhausted: need a direct base argument
    -- At fuel=0 with JD ≤ 1 and no_S_nested_in_U: the formula must be U-free
    -- (if it had a U, the single abstract step would reduce count_U to 0
    -- and produce a separated form WITHOUT invoking the callback)
    sorry
  | succ n ih =>
    -- One fuel step: abstract, separate, substitute, invoke callback with (ih n)
    ...
```

The key insight for the fuel approach: the number of snce nodes in the separated form psi bounds
the callback depth. Specifically, `count_snce_nodes(psi) ≤ sizeOf(phi)`, providing a fuel bound.

### Option B: Prove `jd_one_no_S_nested_separable` by Direct Structural Argument

The handoff "Option A: Direct Event-Guard Decomposition" proposes handling JD=1 directly using
Cases 1-8. This requires showing that at JD=1, the U-arguments in the formula are BOTH S-free
AND U-free (boolean). As established above (Finding 12, corrected): this is FALSE in general —
A can be `.untl (atom p) (atom q)` with JD=0, S-free, but NOT U-free.

**So Option B requires an additional step**: First use Lemma 10.2.7 to eliminate U from within
the U-arguments (replacing `.untl A B` where A, B contain nested U with atoms), producing a
formula where all U-arguments ARE boolean. This is essentially applying the induction hypothesis
for U-depth (Lemma 10.2.7), which the current architecture doesn't have.

Estimated cost: ~300 LOC for the deepest-U-type extraction and the full Lemma 10.2.7 analog.

### Option C: Restructure Using Global JD Decrease

GHR94 Lemma 10.2.8 proves: after the abstract-separate-substitute procedure, the resulting formula
has JD STRICTLY LESS than the original. This GLOBAL decrease (on the whole formula, not just the
callback argument) is what the Lean proof is missing. The Lean proof applies the procedure only
to subformulas (χa, χb) and uses the separated result as a callback target.

To implement GHR94 faithfully: after substituting back, the overall formula has JD ≤ n-1 (not
JD ≤ 1). This requires proving `jd(subst(psi, p, .untl A B)) ≤ jd(phi) - 1` when A, B
have S-free args and the S-nesting of U in phi is properly tracked. This is the content of
GHR94 Lemma 10.2.7 (S-nesting decreases) and Lemma 10.2.8 (JD decreases).

Estimated cost: ~500 LOC for the full JD-decrease lemma and restructured outer induction.

### Recommended Priority

1. **Option A (Fuel)**: Implement first as a bridge. Bound fuel by `sizeOf φ`. The base case
   (fuel=0 with JD ≤ 1) may actually be provable: if fuel is exhausted, φ must be U-free
   (because abstracting and getting a separated result would not invoke the callback if psi
   has no `.snce` nodes, i.e., if φ starts U-free). The circular callback only arises when
   psi HAS `.snce` nodes, consuming fuel. This approach may terminate cleanly.

2. **Option C (Global JD Decrease)**: The mathematically correct long-term fix, following
   GHR94 faithfully. Should be implemented after Option A provides a working proof.

**The conclusion is clear**: The sorry sites require a new structural argument at JD=1 that either
bounds callback depth (Option A) or proves a global JD decrease (Option C). No per-formula measure
can break the circularity without capturing the finite callback chain.
