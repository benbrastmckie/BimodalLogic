# Teammate B Findings: Alternative Approaches to the JD=1 Callback Circularity

**Date**: 2026-05-19
**Focus**: Questions 2 and 3 — Alternative structures for the separation proof
**Task**: 157 — Formalize expressive completeness of {S,U} over integer time

---

## Key Findings

### Finding 1: Cases 1-8 Cannot Directly Handle JD=1 Callbacks (Confirmed Blocker)

The case signatures in `Eliminations.lean` and `DedekindZ.lean` require BOTH `is_U_free` AND `is_S_free` for the arguments `a`, `q`, `A`, `B`. For example, `elim_case_1` requires:

```lean
theorem elim_case_1 (a q A B : Formula)
    (ha : is_U_free a = true) (hq : is_U_free q = true)
    (hA : is_U_free A = true) (hB : is_U_free B = true)
    (ha' : is_S_free a = true) (hq' : is_S_free q = true)
    (hA' : is_S_free A = true) (hB' : is_S_free B = true) : ...
```

The callback formula at JD=1 is `.snce (.untl A B) q` where A, B are S-free but NOT necessarily U-free. The `is_U_free A` requirement in Cases 1-8 is the fundamental obstacle. S-free formulas with nested `.untl` cannot be made U-free without additional separation steps, which is circular.

**Why the GHR94 proof works but the Lean proof doesn't**: GHR94 Lemma 10.2.3 (Cases 1-8) takes atoms `a, q, A, B`. These are not just "atom-typed" in the sense of being propositional variables; they are syntactically atomic (no connectives). However, Lemmas 10.2.4-10.2.6 extend this to arbitrary boolean combinations by using DNF/CNF reduction (Lemma 10.2.1). This reduction step produces terms that ARE atoms or nested temporal formulas — but crucially, in GHR94, by the time Cases 1-8 are applied, the arguments have been shown to be "built from atoms and boolean connectives only" (no temporal operators). In the Lean formalization, the current callback at JD=1 doesn't reduce arguments to that state.

**Structural insight**: The callback formula `.snce c' d'` where `c' = subst c p (.untl A B)` and `d' = subst d p (.untl A B)` with `c, d` U-free has this structure: since `c, d` are U-free and are arguments of a `.snce` in the separated form, they are S-free too (by `is_syntactically_separated`). So after substitution, `c' = subst c p (.untl A B)` contains `.untl A B` where A, B are S-free. The key missing piece: Cases 1-8 were designed for atoms, not for S-free but non-U-free args.

### Finding 2: GHR94's "By the Result We're Proving" Step is a Fixed-Point Argument

Reading GHR94 Lemma 10.2.7's induction step carefully (p. 183-185):

> "To correct this we use the induction hypothesis on each of these pure past subformula of E. It is clear that we can do so as the level of nesting of U in U(Aᵢ,Bᵢ) must be strictly greater than that in its subformula U(Xᵢⱼ,Yᵢⱼ)."

GHR94 uses the **U-depth measure** (nesting depth of U under S) as the decreasing quantity. The key is that `U(Xᵢⱼ, Yᵢⱼ)` has STRICTLY SMALLER U-depth than `U(Aᵢ, Bᵢ)` because `Xᵢⱼ, Yᵢⱼ` come from INSIDE `Aᵢ, Bᵢ`. This is well-founded because U-depth is a natural number.

In the Lean formulation, this corresponds to `U_depth_under_S` (defined in `Defs.lean`). The Lean proof using `junction_depth` instead of this measure is the root cause of the JD=1 problem: `junction_depth` counts S-U alternation depth, not raw U-nesting depth. At JD=1, a `.snce c d` with c containing `.untl A B` where A contains `.untl X Y` has JD=1 at the outer level (from the single alternation), but GHR94 would use U-depth = 2 (two U's nested). The GHR94 induction would have the callback at U-depth 1, not U-depth 2, which IS strictly less than 2.

**This is the most important finding**: GHR94 Lemma 10.2.7 uses `U_depth_under_S` as its induction measure, NOT `junction_depth`. The current Lean proof conflates these measures. Reformulating using `U_depth_under_S` would eliminate the JD=1 circularity.

### Finding 3: The `U_depth_under_S` Measure Already Exists in the Codebase

`Defs.lean` already defines:
```lean
def U_depth_under_S : Formula → Nat
  | .atom _ => 0
  | .bot => 0
  | .imp φ ψ => max (U_depth_under_S φ) (U_depth_under_S ψ)
  | .box φ => U_depth_under_S φ
  | .untl φ ψ => 1 + max (U_depth_under_S φ) (U_depth_under_S ψ)
  | .snce _ _ => 0  -- S resets the counter
```

This counts U-depth above S. For the Lemma 10.2.7 induction, we need the DUAL notion: how many S-nodes separate the outer formula from a given U. But more importantly, `count_U_subformulas` counts the number of U occurrences, and `U_depth_under_S` counts depth.

**The critical observation**: For the specific callback pattern in `subst_in_separated_separable_jd`, the substituted formula `.snce c' d'` has:
- `c = subst_formula c p (.untl A B)` where `c` is U-free (from the separated form)
- So `c` was U-free, `c'` has one U-type: `.untl A B`
- Within A, B themselves, there may be nested `.untl` formulas

The GHR94 argument says: apply Lemma 10.2.7 IH on the `.snce c' d'` formula, where U-nesting depth of `.untl X Y` inside `.untl A B` inside `.snce ...` is LESS than U-nesting depth of `.untl A B` inside `.snce ...`. This works because depth decreases.

### Finding 4: The JD-Bounded Callback Contracts to `no_S_nested_in_U` Formulas

The callback in `no_S_nested_in_U_separable_param_jd` receives formulas with:
1. `no_S_nested_in_U` — all `.untl` have S-free arguments
2. `junction_depth ≤ 1`

Condition 1 means the formula is already in the domain of Lemma 10.2.7. Condition 2 is the problematic one — it's trying to use a JD bound to ensure termination, but JD doesn't decrease at JD=1.

**Alternative approach that works**: Instead of using `junction_depth` for the outer induction in `all_formulas_separable_aux`, use `U_depth_under_S` — the depth of U-nesting beneath S — as the outer induction measure. Then:
- Base case: `U_depth_under_S = 0` means no U under any S → formula is separable by Lemma 10.2.6 directly
- Inductive step: extract outer U's, abstract atoms, apply Lemma 10.2.6, resubstitute; callbacks have STRICTLY SMALLER `U_depth_under_S`

### Finding 5: Alternative Proof Strategies — Automata/Model-Theoretic Approaches

**Automata-theoretic approach**: The connection between temporal logic and counter-free automata (Kamp's theorem) does provide an alternative proof of expressive completeness. However:
1. It requires formalizing automata theory and the McNaughton-Papert theorem
2. It would NOT avoid the callback issue — it would instead avoid the syntactic separation entirely, proving semantic equivalence through automata language membership
3. Cost: massive new formalization (likely 5000+ LOC for a Lean 4 automata library)

**Model-theoretic approach**: Proving that every formula has a "separated model-equivalent" (finding a separated formula with the same truth conditions on all structures) is essentially equivalent to what we're doing. It doesn't sidestep the construction.

**Ehrenfeucht-Fraïssé approach**: EF games capture expressive power but require establishing a theory of these games for temporal logic, which is equally complex.

**Conclusion on alternative proofs**: All alternatives either (a) are more complex than fixing the current proof, or (b) don't actually avoid the circularity in a different form.

### Finding 6: How GHR94 Avoids the Circularity — The Key Mathematical Insight

Reading GHR94 Lemma 10.2.7 and 10.2.8 carefully:

GHR94 Lemma 10.2.8 uses junction_depth for the outer induction. However, the inner step:

> "Replace each least deeply nested such subformula S(Eᵢⱼ,Fᵢⱼ) in U(Aᵢ,Bᵢ) by its own new atom zᵢⱼ to obtain U(A'ᵢ,B'ᵢ)."

After this step, the resubstituted formula has junction_depth AT MOST d-2 (stated explicitly: "junction depth of any of these subformulae is at most d-2"). This is why JD decreases by at least 2 at each outer step, and JD=1 is trivially separated (GHR94 says "If it is zero or one then D is already syntactically separated").

**This is the key**: In GHR94's formulation, JD=1 formulas (not JD≤1) ARE already syntactically separated! GHR94's junction_depth definition must be such that JD=1 implies separation. Let's verify:

GHR94 page 198: "If the junction depth of a certain appearance of B in A is at least n but not at least n+1, then it is n." For JD=1: there exists a chain of length 1 (a single S or U with a subformula). But this single temporal operator must have S-free/U-free arguments (no alternation inside), so it IS syntactically separated.

**The critical discrepancy**: In the Lean definition, `junction_depth (.snce (.untl A B) q)` where A, B are S-free = `max(junction_depth_S (.untl A B), junction_depth_S q)` = `max(1 + max(jd A, jd B), 0)` = `1 + max(jd A, jd B)`. If A contains `.untl X Y`, then `jd A = max(jdU X, jdU Y)`. If X, Y are S-free (atom level), `jd A = 0`, so `jd (.snce (.untl A B) q) = 1`.

In GHR94, the same formula `.snce(.untl A B, q)` where A,B contain `.untl X Y` would have: "the chain U → S → U exists" (length 2 chain). So GHR94's JD would be 2 here, not 1!

**The root of the discrepancy**: The Lean `junction_depth` adds 1 at the S-U ALTERNATION boundary (`junction_depth_U(.snce ...) = 1 + ...`), but NOT at the S or U node itself. GHR94's definition adds 1 for each step in the alternating chain, including the innermost node. This means:

- GHR94 JD of `.snce(.untl A B, q)` where A,B have `.untl X Y` = 2 (chain: S → U → U = length 2? Actually GHR94 requires alternation)
- Lean JD of the same formula = 1

The GHR94 definition counts alternation chains, so `.snce(.untl(.untl X Y, B), q)` has JD=2 only if there's an S inside the nested U — specifically, GHR94's chain requires alternation. A `.untl` inside a `.untl` without intervening `.snce` doesn't increase junction depth.

Let me recheck: GHR94 requires the chain to "alternate between Untils and Sinces". So `.untl(.snce(...), ...)` has JD ≥ 2. But `.snce(.untl A B, q)` where A, B are atom-level has JD = 1 (one Until inside one Since). The Lean definition agrees here.

For `.snce(.untl A B, q)` where A = `.untl X Y` (U inside U, no S): GHR94 JD = 1 (the chain S → U has length 1, the nested U doesn't extend the alternating chain). Lean JD = 1. These agree.

So GHR94's claim "JD ≤ 1 is already separated" means: if the only alternation chain has length ≤ 1, then the formula is separated. But `.snce(.untl A B, q)` where A, B are S-free IS separated IF A, B are also U-free! If A = `.untl X Y`, then `.snce(.untl(.untl X Y, B), q)` is NOT separated because `.untl` is inside `.snce` with a non-U-free argument.

**Wait** — this reveals a contradiction in the current codebase. The lemma `snce_of_boxfree_sep_jd_le_one` claims `.snce χa χb` has `junction_depth ≤ 1` because `χa, χb` are separated (no `.untl` inside `.snce` args). The Lean definition of `junction_depth(.snce c d) = max(jdS c, jdS d)` and `junction_depth_S(.untl c d) = 1 + max(jd c, jd d)`. If `χa` is separated with no `.snce` in `.untl` args (guaranteed by `is_syntactically_separated`), then for any `.untl` in `χa`, its args are S-free → `jd_S(args) = 0` → `jdS(.untl...) = 1`. So `jdS(χa) ≤ 1` → `jd(.snce χa χb) ≤ 1`. This is correct.

The callback formula `.snce(subst c p (.untl A B))(subst d p (.untl A B))` where c, d are U-free has JD ≤ 1 (proved by `callback_jd_le_one`). The issue is not JD but the IDENTITY ROUNDTRIP: when count_U = 1 and the formula is exactly `.snce(.untl A B) q`, abstracting and substituting returns the SAME formula.

### Finding 7: The Callback Identity Roundtrip Is the TRUE Obstacle

The analysis in `jd1-circularity-analysis-20260519.md` is correct: the identity roundtrip is the fundamental problem. When `phi = .snce (.untl A B) q` with count_U = 1:
1. Abstract: `phi' = .snce (atom p) q` (count_U = 0)
2. Separate phi': it's already separated = `.snce (atom p) q`
3. Substitute: `subst (.snce (atom p) q) p (.untl A B) = .snce (.untl A B) q = phi`
4. Callback receives phi — the same formula

This is NOT specific to JD=1. The REASON it only fails at JD=1 is:
- At JD ≥ 2, the outer IH (which handles JD ≤ 1 < JD) provides the callback
- At JD = 1, we would need a callback that handles JD ≤ 1, but the only available callback is "for JD < 1 = 0", which doesn't cover JD = 1 callbacks

The fundamental mathematical content of the 2 sorry calls is exactly `snce_separable`: given `is_separable a` and `is_separable b`, prove `is_separable (.snce a b)`. This is the temporal closure property that the entire proof structure is trying to establish without circularity.

---

## Recommended Approach

### Primary Recommendation: Prove `snce_separable` via Lemma 10.2.7 Directly

The correct fix is to prove `snce_separable` using GHR94 Lemma 10.2.7 (`no_S_nested_in_U_separable`) with a termination argument based on `U_depth_under_S`, NOT junction_depth.

**Concrete proof plan**:

Given `is_separable a` and `is_separable b`:
1. Let `φa` be the separated form of `a`, `φb` the separated form of `b`.
2. `.snce a b ≡ .snce φa φb` by congruence.
3. Apply box-normalization: `.snce φa φb ≡ .snce χa χb` where χa, χb are box-free separated.
4. `.snce χa χb` has `no_S_nested_in_U` and is in the domain of Lemma 10.2.7.
5. Apply `no_S_nested_in_U_separable_noax` (Lemma 10.2.7, which exists without sorry) to `.snce χa χb`.

Wait — does `no_S_nested_in_U_separable_noax` exist? Looking at the code:

```lean
theorem no_S_nested_in_U_separable_noax (phi : Formula)
    (hns : no_S_nested_in_U phi)
    (hexp : has_no_allpast_allfuture phi = true) :
    is_separable phi :=
  no_S_nested_in_U_separable_param phi hns hexp (fun χ _hns_χ => all_separable χ)
```

This DOES use `all_separable` as the callback! It's not sorry-free — it relies on the axioms in `SeparationThm.lean`.

**Revised conclusion**: The callback in `no_S_nested_in_U_separable_param` IS calling `all_separable` which depends on `snce_separable` axiom. The entire current structure uses `snce_separable` as an axiom.

To eliminate the axiom, the key issue is: when `no_S_nested_in_U_separable_param` processes a formula and reaches the callback position, the callback formula has STRICTLY FEWER `count_U_subformulas` than the original... no wait, that's the `count_U` induction and it DOES decrease. The callback receives a formula with fewer U's...

Actually re-reading the code: `no_S_nested_in_U_separable_param` does `count_U` induction. The callback `ih_snce` is NOT called recursively in the count_U loop — it's called EXTERNALLY from `subst_in_separated_separable`. The callback handles the `.snce` node of the SUBSTITUTED separated form, which then needs to be shown separable.

The trick: after substitution, the `.snce c' d'` node represents a formula that itself might have U-subformulas. Making THIS formula separable requires either:
(a) Recursing into `no_S_nested_in_U_separable_param` with a smaller count, OR
(b) Using an external proof (`all_separable` / `snce_separable`)

The current code uses (b). The JD approach tries to use the outer JD induction for (a), but fails at JD=1 because the callback has JD=1 and the outer induction only provides IH for JD=0.

### The Fix That Can Work: Separate the Count Induction from the JD Induction

The real fix is to prove `no_S_nested_in_U_separable_param_jd` WITHOUT needing the callback at all — by proving that the callback formula has STRICTLY FEWER `count_U_subformulas` than `phi`, so the count_U induction can handle it directly.

**Is this true?** The callback formula is `.snce c' d'` where `c' = subst c p (.untl A B)` and `c` is U-free. After substitution, `c'` has exactly one U-type: `.untl A B`. So `count_U_subformulas c' = count_U_subformulas (.untl A B)`.

And `count_U_subformulas phi` where `phi` has at least one U-occurrence abstractable (we're in the `count_U > 0` branch). After abstracting `.untl A B` from `phi` to get `phi'` (with count_U strictly less than phi), we separate `phi'` to get `psi`, then substitute back to get `subst psi p (.untl A B)`.

The callback formula count_U: `count_U_subformulas (.snce c' d') = count_U_subformulas c' + count_U_subformulas d'`. Since c, d are U-free in `psi` (they're S-args of the separated form), after substitution they each have count_U = count_U (`.untl A B`) = 1. So callback count = 2 (one per snce arg, if both have the atom p).

But `count_U_subformulas phi ≥ 1` (since phi is not U-free). If phi had count_U = 1, the callback has count_U = 2 > 1. This fails too!

Wait, but this is wrong. The callback formula `.snce c' d'` need not have count_U = 2. The atom p might only appear in one of c, d. And even if it appears in both, 2 > 1 means the count INCREASES. This is why the callback cannot be handled by the count_U induction.

**The fundamental issue confirmed**: No natural formula-level measure (JD, count_U, sizeOf, snce_depth_of_U) decreases for the identity roundtrip callback.

### The Only Viable Path: Prove `snce_separable` as a Proper Lemma via `no_S_nested_in_U_separable_param_jd` with JD ≥ 2

The crucial observation from the code at lines 1763-1774:

```lean
have h_sep : is_separable (.snce χa χb) := by
  by_cases hn : n ≥ 2
  · -- n ≥ 2: callback JD ≤ 1 < 2 ≤ n
    exact no_S_nested_in_U_separable_param_jd (.snce χa χb) hns
      (has_no_allpast_allfuture_true _) (fun ζ hns_ζ hjd_ζ =>
        ih_jd 1 (by omega) ζ hjd_ζ (has_no_allpast_allfuture_true ζ))
  · -- n = 1: SORRY
```

For n ≥ 2, this IS proved (no sorry). The sorry is ONLY at n = 1. And n = 1 means the outer formula `.snce a b` has `junction_depth = 1`. This implies:

- `junction_depth (.snce a b) = max(jdS a, jdS b) = 1`
- So at least one of a, b has `jdS = 1`
- `jdS a = 1` means a has a `.untl` node with args having `jd = 0` (i.e., S-free and U-free)

Wait, this is KEY: if `jdS a = 1`, then for the `.untl` nodes in a, their args have `jd = 0` meaning they have NO junction (no S inside U, no U inside S). So the `.untl` args are BOTH S-free AND U-free!

**Crucial structural fact**: When `junction_depth (.snce a b) = 1`, the `.untl` subformulas in a (via `jdS a ≤ 1`) have ATOM-LEVEL arguments (both S-free and U-free). Therefore Cases 1-8 CAN be applied at the JD=1 level, because the U-arguments are both S-free and U-free!

Let me verify this claim formally. `jdS a = max(jdS φᵢ)` over components. For a `.untl c d` inside a:
- `jdS(.untl c d) = 1 + max(jd c, jd d)` 
- If `jdS a = 1`, then `jdS(.untl c d) ≤ 1`, so `max(jd c, jd d) = 0`, so `jd c = jd d = 0`
- `jd c = 0` means `junction_depth c = 0` which means c contains no alternating temporal chain of length ≥ 1
- More precisely, `jd c = max(jdU c, ...) = 0` means `jdU c = 0` (no S nested in U) and... wait

The mutual definitions in `Defs.lean`:
```lean
def junction_depth : Formula -> Nat
  | .untl phi psi => max (junction_depth_U phi) (junction_depth_U psi)
  | .snce phi psi => max (junction_depth_S phi) (junction_depth_S psi)

def junction_depth_U : Formula -> Nat
  | .snce phi psi => 1 + max (junction_depth phi) (junction_depth psi)
  -- other cases: max/0 without +1

def junction_depth_S : Formula -> Nat
  | .untl phi psi => 1 + max (junction_depth phi) (junction_depth psi)
  -- other cases: max/0 without +1
```

For `jd c = 0` where `c` is in the arg position of `.untl`:
- If c contains `.untl d e`: `jd(.untl d e) = max(jdU d, jdU e)`. For this to be 0, need `jdU d = jdU e = 0`, meaning no `.snce` in d or e. So d, e are S-free.
- If c contains `.snce d e`: `jd(.snce d e) = max(jdS d, jdS e)`. For this to be 0, need `jdS d = jdS e = 0`, meaning no `.untl` in d or e. So d, e are U-free.

Therefore `jd c = 0` means c has NO S inside U (`.snce` args must be U-free) AND NO U inside S (`.untl` args must be S-free). This means every `.snce` in c has U-free args and every `.untl` in c has S-free args — i.e., c IS syntactically separated!

**Theorem (informal)**: If `junction_depth φ = 0`, then `φ` is syntactically separated (this is `expanded_jd_zero_imp_separated` in the codebase, confirmed).

So when `junction_depth (.snce a b) = 1` (JD level n=1):
- `a, b` have `junction_depth_S ≤ 1`
- After box-normalization to `χa, χb` (separated forms of a, b), we have `.snce χa χb` with JD ≤ 1
- `χa, χb` are box-free and syntactically separated
- The `.untl` subformulas in `χa, χb` have S-free arguments (by separation)
- The `.snce` subformulas in `χa, χb` have U-free arguments (by separation)
- `junction_depth_S(χa) ≤ 1` and same for χb

Key question: when we apply `no_S_nested_in_U_separable_param_jd` at n=1, the callback formula is `.snce c' d'` where c', d' come from substituting `.untl A B` into the U-free args `c, d` of the separated form. With χa, χb syntactically separated and JD ≤ 1, and `.untl A B` being the only U in `φ`:
- A, B are S-free (from `extract_U_type_S_free`)
- A, B have `jd = 0` (because `jdU(A) ≤ jdS(.untl A B) - 1 + something`...

Wait, we need to check what `jd A = 0` means. `extract_U_type` returns the FIRST `.untl` found by descending through non-snce nodes. The `.untl A B` that's extracted from a `no_S_nested_in_U` formula with JD ≤ 1 has: A, B are S-free (proven) and `jd A ≤ ?`

`jdS(.snce χa χb) = max(jdS χa, jdS χb) = junction_depth(.snce χa χb) ≤ 1`. And `jdS χa` involves the `.untl` args in χa: for each `.untl c d` in χa, `jdS(inner args c, d)`. Since χa is separated and `jdS(χa) ≤ 1`, the `.untl c d` in χa have `jdS(inner) = 0`... but that measures S-in-U depth, not U-in-S depth.

Let me think differently: `junction_depth(.snce χa χb) ≤ 1`. The only `.untl` formulas in `.snce χa χb` are in χa, χb with S-free args (by separation). What is `jd A` for the extracted A?

`jd(.snce χa χb) = max(jdS χa, jdS χb) ≤ 1`. The `.untl A B` extracted from `φ = .snce χa χb` via `extract_U_type` comes from χa or χb. Say it comes from χa. Then `jdS(χa) ≤ 1`. `jdS(.untl A B) = 1 + max(jd A, jd B) ≤ jdS(χa) ≤ 1`. So `1 + max(jd A, jd B) ≤ 1`, giving `max(jd A, jd B) = 0`, so `jd A = jd B = 0`.

**THIS IS THE KEY LEMMA**: When extracting `.untl A B` from a formula `φ` with `junction_depth φ ≤ 1` and `no_S_nested_in_U`, the args A, B have `junction_depth = 0`. And `junction_depth = 0` implies syntactically separated. So A, B are BOTH S-free (by `no_S_nested_in_U`) AND U-free (since JD=0 implies separated, and being separated + S-free implies U-free because if A had a `.untl c d` inside, `jdS(A) > 0`).

**WAIT**: This isn't quite right. A, B are S-free (proved by `extract_U_type_S_free`). If additionally `jd A = 0`, what does that give us? `jd A = max(jdU A, ...)`. `jdU(atom) = 0, jdU(.untl c d) = max(jdU c, jdU d), jdU(.snce c d) = 1 + ...`. If A is S-free, there's no `.snce` in A, so `jdU A = 0` (since every case is just max of children, with no +1 for `.untl`). So `jd A = max(jdU A, jdS A) = max(0, jdS A)`. For `jd A = 0`, need `jdS A = 0`. For a S-free formula, `jdS A = 0` trivially since no `.untl` appears (all `.untl` args in A are S-free by `no_S_nested_in_U`, and `jdS(.untl ...) = 1 + ...`, but A itself is S-free, so no `.snce` in A, so the only temporal ops in A are `.untl`. And `jdS` of A = 0 if A has no `.snce`). Actually: `jdS(.untl c d) = 1 + max(jd c, jd d)`. If A = `.untl c d` with c, d S-free, then `jd A = max(jdU A, jdS A) = max(0, 1 + max(jd c, jd d))`. Hmm, `jdS A ≥ 1`. Contradiction with `jd A = 0`.

Wait, I was computing incorrectly. Let's recheck. The extracted `.untl A B` has:
```
jdS(.untl A B) = 1 + max(jd A, jd B)
```
And we need `jdS(.untl A B) ≤ jdS(χa) ≤ 1`. So `1 + max(jd A, jd B) ≤ 1`, giving `max(jd A, jd B) = 0`.

For `jd A = 0`: `A` is not the atom `p` (it's a formula). `junction_depth A = ?`. With A S-free (no `.snce`):
```
junction_depth A = max over subformulas; for .untl c d: max(jdU c, jdU d)
jdU c = 0 if c is S-free (no .snce nodes, so jdU never sees the +1)
```
Actually `jdU(.snce φ ψ) = 1 + max(jd φ, jd ψ)`. If A is S-free, A contains no `.snce`, so `jdU A = 0` (recursing through `.untl, .imp, .box, .atom, .bot` — none of which add to jdU). Therefore `jd A = max(jdU A, ...) = max(0, jdS A)`. For S-free A: `jdS A = max over components`; for `.untl c d` in A: `jdS(.untl c d) = 1 + max(jd c, jd d)`. So if A = `.untl c d`, `jdS A = 1 + max(jd c, jd d)`. If `jd A = 0`... but A = `.untl c d` gives `jd A = max(jdU A, jdS A) = max(0, 1+...) ≥ 1`.

This means `jd A = 0` AND A is S-free IMPLIES A is U-free (no `.untl`). And U-free + S-free means A is a boolean combination of atoms and `.box` — i.e., purely propositional/present.

**CONFIRMED**: When `junction_depth(.snce χa χb) ≤ 1` and we extract `.untl A B`, both A and B are S-free (by `no_S_nested_in_U`) AND U-free (by `jd A = jd B = 0` and S-free). Therefore:

**A and B at JD=1 are both U-free and S-free.**

This means Cases 1-8 CAN be applied at JD=1! The preconditions for Cases 1-8 require both `is_U_free A` and `is_S_free A` — and we've just shown these hold at JD=1.

---

## The Gap in the Current Proof

The current code at the n=1 case:
```lean
exact no_S_nested_in_U_separable_param_jd (.snce χa χb) hns
  (has_no_allpast_allfuture_true _) (fun ζ hns_ζ hjd_ζ =>
    ih_jd 0 (by omega) ζ (by sorry) (has_no_allpast_allfuture_true ζ))
```

The `sorry` is trying to prove `junction_depth ζ ≤ 0` (i.e., JD = 0) but only has `hjd_ζ : junction_depth ζ ≤ 1`. This is FALSE in general — callback formulas CAN have JD = 1.

BUT: if we instead prove that the callback formula has U-free AND S-free arguments (because the extracted U-type has U-free and S-free args at JD=1), then we can directly conclude `is_separable ζ` WITHOUT calling `ih_jd 0`.

The specific callback formula ζ at n=1 is `.snce c' d'` where `c' = subst_formula c p (.untl A B)` with c, d U-free and A, B BOTH U-free and S-free. Since A, B are U-free, `subst_formula c p (.untl A B)` produces a formula where every occurrence of p is replaced by `.untl A B`. With c U-free (no other `.untl`) and A, B U-free, the result c' has U-free args in every `.snce` it might contain? Actually c itself is U-free and has S-free args in its `.snce` nodes. After substituting p with `.untl A B` (which is itself S-free since A,B S-free): `c'` has S-free args in every `.snce`. So `.snce c' d'` has U-free args in... wait.

`c'` may contain the `.untl A B` formula. So `.snce c' d'` has args c', d' which ARE NOT U-free. But they ARE S-free (since the substitution replaces U-free positions with S-free `.untl A B`).

Actually, `.snce c' d'` where c', d' are S-free means this `.snce` has S-free args, making it syntactically separated directly! Therefore `is_separable (.snce c' d')` holds trivially.

**The Proof of the Fix**:

At n=1, the callback formula ζ = `.snce c' d'` where:
- c, d are U-free (S-args of separated form)
- A, B are U-free AND S-free (by JD=1 bound, as shown above)
- c' = subst_formula c p (.untl A B) preserves S-freeness? 

`subst_S_free_preserves_S_free`: if c is S-free and `.untl A B` is S-free, then c' is S-free. YES, `.untl A B` is S-free when A, B are S-free. So c' is S-free.

Similarly d' is S-free.

Therefore `.snce c' d'` has S-free args (both c' and d' are S-free), so it's syntactically separated! `is_separable (.snce c' d') = ⟨.snce c' d', by simp [is_syntactically_separated, hc'_sf, hd'_sf], int_equiv_refl _⟩`.

**This is the fix for the sorry!** When A, B are provably U-free (from the JD=1 constraint), the callback formula is already separated, and no recursive call is needed.

---

## Evidence / Formal Argument

The chain of lemmas needed to fill in the sorry at lines 1773 and 1806:

1. **`jd_le_one_U_args_U_free`** (new): When `junction_depth (.snce χa χb) ≤ 1` and we extract `.untl A B` from it (via `extract_U_type`), then `is_U_free A = true` and `is_U_free B = true`.

   Proof: From `callback_jd_le_one` applied to the OUTER formula, the extracted A satisfies `jd A = 0`. Since A is S-free (`extract_U_type_S_free`) and S-free + jd=0 implies U-free (see argument above).

2. **`callback_args_s_free`** (new): If c, d are U-free and A, B are S-free, then `subst_formula c p (.untl A B)` is S-free.

   Proof: `subst_S_free_preserves_S_free` already exists in the codebase.

3. **Filling the sorry**: At n=1, the callback formula ζ = `.snce c' d'` where c', d' are S-free. Therefore `is_syntactically_separated (.snce c' d') = true` by `is_syntactically_separated` case for `.snce`, which requires `is_U_free c'` and `is_U_free d'`. Wait — the separation definition requires U-free, not S-free.

**Correction**: `is_syntactically_separated (.snce φ ψ) = is_U_free φ && is_U_free ψ`. So we need U-free, not S-free, for the args.

After substitution: `c' = subst_formula c p (.untl A B)` where c is U-free. If A, B are U-free (from Finding 7), then `.untl A B` is... not U-free (it's an until formula). So `c'` has a `.untl A B` where `.untl` is not U-free. So c' is NOT U-free.

Therefore `.snce c' d'` does NOT have U-free args, and is NOT trivially separated.

**Correcting the argument**: We cannot prove ζ = `.snce c' d'` is trivially separated. However, ζ has `no_S_nested_in_U` (proved) and `junction_depth ζ ≤ 1` (from `callback_jd_le_one`). Moreover, ζ has count_U = 1 (each of c', d' has at most 1 U-occurrence from the substitution of p with `.untl A B`, assuming p appears at most once in c and d respectively).

Actually, with A, B U-free AND S-free (from JD=1), the formula `.untl A B` is syntactically separated. So ζ = `.snce c' d'` where:
- c' has `no_S_nested_in_U` (proved)
- The only `.untl` in c' is `.untl A B` with A, B U-free and S-free
- Therefore c' has single U-type U(A,B) with U-free, S-free A, B

By `single_U_formula_separable`: c' is separable. Similarly d' is separable.

But we need `.snce c' d'` to be separable, not just c' and d' separately. This is exactly `snce_separable`! We're back to circular.

**But wait** — `snce_depth_of_U c' = 0` because all `.snce` in c' (which come from the original U-free c) have U-free args (since c was U-free with S-free args for `.snce`). After substituting p with `.untl A B`: the `.snce` nodes in c had U-free args (since c is U-free), and substituting p (not inside any `.snce` arg because... wait, p CAN appear inside `.snce` args).

This is getting complex. Let me step back to the essential mathematical argument.

---

## Recommended Approach (Revised)

### The Correct Fix: Use `no_S_nested_in_U_separable_param` Directly with `snce_depth_of_U = 0`

At JD=1 and count_U=1, the callback formula ζ = `.snce c' d'` has:
- `no_S_nested_in_U` ✓
- `count_U_subformulas ζ = 1` (since A, B are U-free at JD=1, `count_U (.untl A B) = 1`, and p appears at most once in c or d)
- `snce_depth_of_U c' = 0` IF the single occurrence of p in c is not inside any `.snce` of c (which is true since c is U-free with S-free args for `.snce`)

Actually `snce_depth_of_U c' = snce_depth_of_U c` because substituting p with `.untl A B` (a single untl) in a U-free c: the `.snce` nodes in c all have U-free args (since c is U-free with the specific structure). After substituting p: the `.snce` nodes in c' have args that were U-free + one might contain the atom p replaced by `.untl A B`. If the atom p appears inside a `.snce` arg, then after substitution that `.snce` arg contains `.untl A B` and is no longer U-free, so `snce_depth_of_U` increases.

This is Approach C from the analysis — it can increase. Confirmed blocker.

### The True Fix (Path 1): Prove `no_S_nested_in_U_separable_param_jd` Bypasses the Callback at JD=1

The mathematical content: at JD level n=1, after abstracting the U-type and separating, the substituted form has ζ with U-free, S-free A, B (PROVED ABOVE). Apply Lemma 10.2.4 directly: `.snce c' d'` where c', d' have the single U-type `.untl A B` with both U-free and S-free args. By Lemma 10.2.4 (already proved in the codebase as `snce_single_U_top_level_separable`), this IS separable without needing `snce_separable`!

**Critical lemma** (`snce_single_U_top_level_separable`):
```lean
theorem snce_single_U_top_level_separable (C F A B : Formula)
    (hA_sf : is_S_free A = true) (hB_sf : is_S_free B = true)
    (hC_single : has_single_U_type C A B)
    (hF_single : has_single_U_type F A B) ... :
    is_separable (.snce C F) :=
  snce_separable C F (single_U_formula_separable ...) (single_U_formula_separable ...)
```

This still uses `snce_separable`! So it's circular.

### Honest Assessment

Every path to prove ζ = `.snce c' d'` is separable (where c', d' contain `.untl A B`) reduces to `snce_separable`. The mathematical content of the sorry IS `snce_separable`.

**The only non-circular proof strategy** is to completely bypass the callback by proving that at JD=1, the substitution step produces a directly separated formula. This requires showing A, B are U-free at JD=1 (proved) and then that the substituted form `.snce c' d'` is ALREADY syntactically separated (which requires c', d' to be U-free — but they're not, since they contain `.untl A B`).

**The inescapable conclusion**: The sorry at JD=1 cannot be eliminated within the current proof architecture without using `snce_separable` or an equivalent axiom. The current proof architecture has a genuine circular dependency at this point.

---

## Recommended Alternative Proof Architecture

### Approach: Prove `snce_separable` Directly via the Junction Depth Induction (Different Structure)

Instead of embedding `snce_separable` proof inside `all_formulas_separable_aux`, factor the proof as:

1. First prove `all_formulas_separable_aux` WITH `snce_separable` as an ADMITTED lemma (current state)
2. Then prove `snce_separable` as a CONSEQUENCE of `all_formulas_separable_aux` for the specific case

**The self-application trick**: `snce_separable a b h1 h2` needs `is_separable (.snce a b)`. Apply `all_formulas_separable_aux` to `.snce a b` — but this requires JD reduction, which is exactly what we're trying to prove.

This is circular. The only way out is an induction that's OUTSIDE `all_formulas_separable_aux`.

### Approach: The `junction_depth` Definition Change (Path 1 from jd1-analysis, Revised Assessment)

Change `junction_depth` to count +1 at S and U nodes (not just at alternation):
```lean
def junction_depth_S : Formula -> Nat
  | .snce phi psi => 1 + max (junction_depth_S phi) (junction_depth_S psi)  -- ADD +1 here
  | .untl phi psi => 1 + max (junction_depth phi) (junction_depth psi)     -- unchanged
```

With this definition, `junction_depth(.snce(.untl A B, q)) = max(jdS(.untl A B), jdS q) = max(1 + max(jd A, jd B), 0)`. And `jdS(.untl A B) = 1 + max(jd A, jd B)`. With A, B atom-level: `jdS(.untl A B) = 1`, so `jd(.snce(.untl A B, q)) = 1`.

Under the new definition, `jd(.snce(.untl A B, q))` where A,B atom-level would be: `max(new_jdS(.untl A B), new_jdS q)`. New `jdS(.untl A B) = 1 + max(jd A, jd B) = 1 + 0 = 1`. So JD = 1. Same as before.

But `jd(.snce atom q) = max(new_jdS(atom), new_jdS q) = max(0, 0) = 0`. Under current definition same. The change doesn't shift the gap.

**Conclusion**: The +1 change does not help. The jd1-analysis document's REVISED RECOMMENDATION is correct: Path 1 fails.

### The True Recommendation: Accept `snce_separable` as a Structural Axiom and Prove It Separately

The most promising approach is to prove `snce_separable` directly using a DIFFERENT induction argument — specifically, induction on `junction_depth a + junction_depth b` with the base case being when `.snce a b` already satisfies `no_S_nested_in_U` (so Lemma 10.2.7 applies directly without callback).

**The key insight that was missed**: `all_formulas_separable_aux` does NOT need to prove `snce_separable` as an intermediate lemma. Instead, the sorry at JD=1 should call the already-proven JD ≥ 2 case applied to a DIFFERENT formula. Specifically:

When `junction_depth (.snce a b) = 1` and we have `is_separable a` and `is_separable b`, let `χa, χb` be box-free separated equivalents. Apply `no_S_nested_in_U_separable_param_jd (.snce χa χb)` with callback = `fun ζ _ _ => all_formulas_separable_aux ζ ...` — but this requires `junction_depth ζ < 1`, circular again.

**Alternative**: Call the JD induction with n=2 (even though the formula has JD=1) by artificially increasing n. But `all_formulas_separable_aux` bounds apply to the outer formula.

---

## Final Conclusion and Confidence

**For Question 2** (Can callbacks be avoided): NO, not within the current architecture. The callback is mathematically necessary and represents exactly the `snce_separable` property being proved.

**For Question 3** (Alternative proofs): Automata/model-theoretic proofs exist in the literature but would require major new formalization work (2000+ LOC). They sidestep the syntactic separation argument entirely but at enormous cost.

**The path with highest probability of success**: 

Prove `snce_separable` (and similarly `untl_separable`) as a direct corollary of `no_S_nested_in_U_separable_param_jd` at JD ≥ 2, applied to a LIFTED formula. Specifically:

Given `is_separable a` and `is_separable b`, we want `is_separable (.snce a b)`. Let `φa, φb` be separated equivalents. Consider the formula `F = .snce φa φb`. `F` has `no_S_nested_in_U` (by `snce_of_boxfree_sep_no_S_nested`) and `junction_depth F ≤ 1` (by `snce_of_boxfree_sep_jd_le_one`).

The sorry at JD=1 is asking for exactly `is_separable F`. The proven JD ≥ 2 case provides the tool: `no_S_nested_in_U_separable_param_jd F hns callback` where callback requires formulas with JD < 2. At JD=1 for F, the callback ζ has JD ≤ 1. The sorry asks for JD < 1 = 0.

**The gap persists**: ζ might have JD = 1, not 0.

**NEW INSIGHT**: At JD=1 for the OUTER formula `.snce χa χb`, the INNER formula ζ = `.snce c' d'` has A, B with JD=0 (proved above). Therefore A and B are both U-free AND S-free. Therefore:
- ζ = `.snce c' d'` where c' = `subst c p (.untl A B)` with c U-free, A, B both U-free and S-free
- After substitution: c' has single U-type U(A,B) with U-free S-free args
- c' itself has `snce_depth_of_U = 0` IF all `.snce` nodes in c (which is U-free) had U-free args before substitution — YES because c is U-free, so it has no `.untl` nodes at all, meaning the ONLY `.untl` in c' is `.untl A B` which does NOT appear inside any `.snce` in c (since c is U-free, c has no `.untl` subformulas, so p can only appear in non-`.snce` positions of c OR in `.snce` positions)

Hmm. p CAN appear inside a `.snce` argument in c (c is U-free, not atom-free). If c = `.snce (atom p) (atom q)`, then after substitution c' = `.snce (.untl A B) (atom q)`. Then `snce_depth_of_U c' = 1`.

So ζ = `.snce c' d'` has `no_S_nested_in_U` (proven) and `count_U = 2` at most (one `.untl A B` per occurrence of p in c and d). With A, B U-free, each `.untl A B` occurrence has count_U = 1. So `count_U ζ ≤ 2`.

But we need `is_separable ζ`. The formula ζ = `.snce c' d'` with `no_S_nested_in_U` can be handled by `no_S_nested_in_U_separable_param_jd ζ` with callback for JD ≤ 1 formulas produced by ζ's own abstraction. The callback from ζ's iteration would get χ with JD ≤ 1 and A, B U-free and S-free (since ζ has JD ≤ 1 and same argument applies). So the callback from ζ also needs JD < 1 = 0, but callbacks from ζ at JD ≤ 1 ALSO have U-free, S-free args... this is an infinite regress.

**The mathematical conclusion**: The sorry IS `snce_separable`. No finite reduction terminates. The only fix is a proof of `snce_separable` that does NOT go through `all_formulas_separable_aux`.

---

## Summary of Findings

| Question | Answer | Confidence |
|----------|--------|-----------|
| Can Cases 1-8 handle JD=1 callbacks directly? | No (args not U-free in general) | High |
| Is there structure at JD=1 that helps? | Yes: A, B are provably U-free AND S-free at JD=1 | High |
| Can this structure eliminate the sorry? | No — callback ζ = `.snce c' d'` still needs `snce_separable` | High |
| Do alternative proofs exist? | Yes (automata), but at enormous implementation cost | High |
| Is the sorry mathematically equivalent to `snce_separable`? | YES — confirmed | High |
| Can `snce_separable` be proved within `all_formulas_separable_aux`? | No — genuinely circular at JD=1 | High |

**Recommended path forward**: The 2 sorry calls represent `snce_separable` and `untl_separable`. The architectural fix is to ACCEPT these as axioms (they are already in `SeparationThm.lean`) and find an independent proof that they hold — either via the Reynolds/GHR94 completeness result (circular for a formalization goal) or by restructuring the entire proof to use a different induction that terminates. The most promising structural fix is to prove the separation theorem by induction on `sizeOf` with a GLOBAL fuel argument that accounts for the entire callback chain across all JD levels.

**Confidence Level**: HIGH on the mathematical analysis. HIGH on the conclusion that the sorry cannot be eliminated within the current architecture.

---

## File References

- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean` lines 1763-1806 (sorry locations)
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Defs.lean` lines 312-339 (junction_depth definitions)
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/SeparationThm.lean` lines 90-103 (snce_separable axiom)
- `literature/Gabbay_Hodkinson_Reynolds_1994_Temporal_Logic_Foundations_Vol1_ch10.md` (GHR94 source, Lemmas 10.2.5-10.2.8)
- `specs/157_expressive_completeness_su_integer/handoffs/jd1-circularity-analysis-20260519.md` (prior analysis)
