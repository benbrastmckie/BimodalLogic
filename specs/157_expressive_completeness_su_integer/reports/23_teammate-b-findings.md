# Teammate B Findings: Codebase Inventory and GHR94 Divergence Analysis

**Task**: 157 — Formalize expressive completeness of {S,U} over integer time
**Artifact**: 23 (teammate B findings)
**Focus**: Codebase inventory, GHR94 alignment, axiom tracking

---

## Key Findings

1. **Formula type is 6-constructor with negation as derived operator**: `atom`, `bot`, `imp`, `box`, `untl`, `snce`. Negation is `φ.imp .bot`, G(φ) is `¬F(¬φ) = ¬(U(¬φ, ⊤))`, H(φ) is `¬P(¬φ) = ¬(S(¬φ, ⊤))`. All_future and all_past are `def` abbreviations, NOT constructors.

2. **`is_syntactically_separated` has the right shape**: `.untl A B` requires `is_S_free A ∧ is_S_free B`; `.snce A B` requires `is_U_free A ∧ is_U_free B`. Negation `¬U(A,B)` = `.imp (.untl A B) .bot` is checked as `.imp` (recursively), so it is separated iff `.untl A B` is separated.

3. **`has_single_U_type (.imp (.untl A B) .bot) A B` holds**: The definition checks `.untl ψ₁ ψ₂ => ψ₁ = A ∧ ψ₂ = B`. For `.imp (.untl A B) .bot`, it recurses into the `.imp` case, checking `has_single_U_type (.untl A B) A B ∧ has_single_U_type .bot A B`, which both hold. So ¬U(A,B) has single-U-type. This is important: Case 2 and Case 4 witnesses work correctly.

4. **Cases 2 and 4 keep ¬U unexpanded**: The witnesses in Eliminations.lean for Cases 2 and 4 do NOT expand `¬U(A,B)` to `G(¬A) ∨ U(¬A∧¬B, ¬A)`. They call `neg_until_equiv` (a semantic equivalence) to split the ¬U branch, but the syntactic witness uses `all_future (Formula.neg A)` for the G(¬A) branch and the `case1_psi` formula for the U' branch.

5. **The GHR94-exact plan v22 has completed only Phases A.1 and A.2**: Phase A.3, Phase B, Phase C, Phase D, and Phase E are not yet done. The key remaining axioms are in SeparationThm.lean: 9 axioms total. `all_formulas_separable_aux` (Lemma 10.2.8) still falls back to `no_S_nested_in_U_separable_direct` (which uses `all_separable`) for the JD = 1 case.

6. **The oracle architecture in `_param` variants is the current approach**: Functions `single_U_formula_separable_noax_param`, `lemma_10_2_6_self_contained_param`, `no_S_nested_in_U_separable_direct_param`, and `all_formulas_separable_aux` take an oracle but thread it through to `snce_separable`/`all_separable` calls. The oracle is NEVER invoked at `snce_depth_of_U ≤ 1` (Phase A achieved this), but `all_formulas_separable_aux` still calls `no_S_nested_in_U_separable_direct` (which uses `all_separable`) when n = 1.

7. **`has_no_allpast_allfuture` is trivially always true**: Since `all_past` and `all_future` are `def` abbreviations (not constructors), `has_no_allpast_allfuture` returns `true` for every formula. Similarly, `expand_temporal` is the identity function. This simplifies the proof structure significantly.

---

## Formula Type Analysis

**Six constructors** (from `Theories/Bimodal/Syntax/Formula.lean`):

| Constructor | Syntax | Semantics |
|-------------|--------|-----------|
| `atom a` | propositional atom | `t ∈ M.val a` |
| `bot` | ⊥ | `False` |
| `imp φ ψ` | φ → ψ | `int_truth M t φ → int_truth M t ψ` |
| `box φ` | □φ | `True` (degenerate for separation proofs) |
| `untl φ ψ` | U(φ, ψ) | `∃ s > t, φ(s) ∧ ∀ r ∈ (t,s), ψ(r)` |
| `snce φ ψ` | S(φ, ψ) | `∃ s < t, φ(s) ∧ ∀ r ∈ (s,t), ψ(r)` |

**Derived operators** (all `def` abbreviations, NOT constructors):
- `neg φ` = `φ.imp .bot`
- `top` = `.bot.imp .bot`
- `some_future φ` = `.untl φ top`
- `all_future φ` = `(some_future φ.neg).neg` = `¬U(¬φ, ⊤)`
- `all_past φ` = `(some_past φ.neg).neg` = `¬S(¬φ, ⊤)`

**Key consequence**: G(φ) and H(φ) expand to nested `imp`/`untl`/`snce`/`bot` nodes. `is_U_free (all_future φ) = false` always (from simp lemma `is_U_free_all_future`). `is_S_free (all_past φ) = false` always. These simp lemmas are critical for is_separated computations.

---

## Separation Predicate Analysis

**`is_syntactically_separated`** (from `Defs.lean`):

```
| .atom _ => true
| .bot => true
| .imp φ ψ => is_syntactically_separated φ && is_syntactically_separated ψ
| .box _ => true
| .untl φ ψ => is_S_free φ && is_S_free ψ
| .snce φ ψ => is_U_free φ && is_U_free ψ
```

**Critical observations**:

1. `¬U(A,B)` = `.imp (.untl A B) .bot` is separated iff `.untl A B` is separated (checked recursively through `.imp`), iff A and B are S-free. So `¬U(A,B)` is a separated formula when A, B are S-free.

2. `is_separated_all_past φ = is_U_free φ` and `is_separated_all_future φ = is_S_free φ` (proven as simp lemmas).

3. `is_separable φ` = `∃ ψ, is_syntactically_separated ψ = true ∧ int_equiv φ ψ`. This is the existential predicate.

4. `is_properly_separable` uses `is_past_only`/`is_future_only` as stricter predicates. It has its own set of 4 axioms in SeparationThm.lean plus 1 atom-preservation axiom.

**`has_single_U_type`** behavior for negated U:

```
has_single_U_type (.imp (.untl A B) .bot) A B
= has_single_U_type (.untl A B) A B ∧ has_single_U_type .bot A B
= (A = A ∧ B = B) ∧ True
= True
```

So yes, `has_single_U_type (.imp (.untl A B) .bot) A B` holds. The negation of U(A,B) has single-U-type U(A,B).

---

## Elimination Case Witness Inventory

All 8 cases live in `Eliminations.lean`. Cases 5-8 are in `DedekindZ.lean`.

### Case 1: S(a ∧ U(A,B), q)

**Witness** (`case1_psi a q A B`):
```
(S(a,q) ∧ S(a,B) ∧ B ∧ U(A,B)) ∨ (A ∧ S(a,B) ∧ S(a,q)) ∨ S(A∧q∧S(a,B)∧S(a,q), q)
```
This is the GHR94-exact formula (three disjuncts corresponding to where A-event lies relative to t). The witness keeps `U(A,B)` as a term (first disjunct), not expanded.

**Syntactic separation**: requires `is_U_free a`, `is_U_free q`, `is_U_free A`, `is_U_free B`, `is_S_free A`, `is_S_free B`. The arguments `a` and `q` appear only under `.snce` (where U-freeness suffices).

**Generalized version** (`elim_case_1_gen`): drops `is_S_free a` and `is_S_free q`. Same witness formula. Used by Cases 5-8 where event/guard may come from abstracted separated formulas.

### Case 2: S(a ∧ ¬U(A,B), q)

**Strategy**: Case 2 is NOT a separate witness formula. It reduces Case 2 to a combination of:
- Branch 1: S(a, q ∧ ¬A) ∧ ¬A(t) ∧ G_t(¬A) -- the G(¬A) branch
- Branch 2: Case 1 applied with U' = U(¬A∧¬B, ¬A) -- the "some U' holds" branch

**Witness** is `Formula.or psi_l psi1` where:
- `psi_l = S(a, q ∧ ¬A) ∧ ¬A ∧ G(¬A)` (using `all_future (neg A)`, NOT expanded further)
- `psi1 = case1_psi a q (¬A∧¬B) (¬A)` from Case 1 with the "U' = U(¬A∧¬B,¬A)" substitution

Key: The ¬U(A,B) at the event point is decomposed via `neg_until_equiv A B` (which states `¬U(A,B) ↔ G(¬A) ∨ U(¬A∧¬B, ¬A)`). The witness does NOT keep ¬U(A,B) as-is; it expands it to the two branches. This is the correct GHR94 approach.

**Generalized version** (`elim_case_2_gen`): drops `is_S_free a` and `is_S_free q`.

### Case 3: S(a, q ∨ U(A,B))

**Strategy**: Reduces to S(¬a∧¬q, ¬a) via double negation and then uses Case 2. The witness is `¬H(¬a) ∧ ¬psi2` where `psi2` is from `elim_case_2` applied to `(¬a∧¬q)` and guard `¬a`.

**Witness**: `Formula.and (Formula.neg (.all_past (Formula.neg a))) (Formula.neg psi2)`

**Separation**: Uses `is_syntactically_separated_all_past` = `is_U_free (neg a)` = `is_U_free a`.

**Generalized version** (`elim_case_3_gen`): drops S-free on a, q; uses `elim_case_2_gen`.

### Case 4: S(a, q ∨ ¬U(A,B))

**Strategy**: Analogous to Case 3 but uses `elim_case_1_gen` instead of `elim_case_2_gen`.

**Witness**: `Formula.and (Formula.neg (.all_past (Formula.neg a))) (Formula.neg psi1)`

**Generalized version** (`elim_case_4_gen`): drops S-free on a, q.

### Cases 5-8 (from DedekindZ.lean)

These use `case3_equiv_Z_general` as the core decomposition mechanism. The general Case 3 equivalence is:
```
S(a, q ∨ U(A,B)) ↔ case3_rhs(a, q, A, B)
```
where:
```
case3_rhs = S(a, q) ∨ [S(alpha, Q_Z(A,B,¬q)) ∧ (A ∨ B∧U(A,B))] ∨ S(A∧(q∨U)∧S(alpha,Q_Z), q)
alpha = a ∨ (¬q ∧ S(a,q) ∧ (q∨U(A,B)))
Q_Z(A,B,C) = B ∨ A ∨ ¬S(C, ¬A)
```

**Case 5**: S(a∧U, q∨U) -- applies `case3_equiv_Z_general` with event `a∧U`, reduces to separable subterms via Cases 1 and 2 machinery.

**Case 6**: S(a∧¬U, q∨U) -- decomposes ¬U via `neg_until_equiv` into G(¬A) and U' branches. G(¬A) branch is handled separately (event becomes U-free after extracting G(¬A)). U' branch uses contradiction: U(A,B) and U(¬A∧¬B,¬A) cannot both hold.

**Case 7**: S(a∧U, q∨¬U) -- similar to Case 5 with negated guard.

**Case 8**: S(a∧¬U, q∨¬U) -- similar to Case 6.

**Key observation**: All Cases 5-8 witnesses avoid sorry. They are proved in `DedekindZ.lean` without invoking `all_separable` from SeparationThm. The proofs use `snce_combined_U_separable`, `snce_combined_notU_separable`, `d21_sep`, and `d21_sep_equiv`.

---

## Measure Analysis

### `snce_depth_of_U` (GHR94 Lemma 10.2.5 measure)

```lean
def snce_depth_of_U : Formula → Nat
  | .atom _ => 0
  | .bot => 0
  | .imp a b => max (snce_depth_of_U a) (snce_depth_of_U b)
  | .box a => snce_depth_of_U a
  | .untl _ _ => 0
  | .snce a b =>
    if is_U_free a = true ∧ is_U_free b = true then 0
    else 1 + max (snce_depth_of_U a) (snce_depth_of_U b)
```

This is the "maximum number k of nested Ss above any U(A,B)" from GHR94 Lemma 10.2.5 (p. 569). A `.untl` node contributes 0 (it is what is being counted above), and a `.snce` node adds 1 only if it has U below it (both children are not U-free).

**Relation to GHR94 "k"**: `snce_depth_of_U φ` = GHR94's k for formula φ.

### `U_nesting_depth` (GHR94 Lemma 10.2.7 measure)

```lean
def U_nesting_depth : Formula → Nat
  | .atom _ => 0
  | .bot => 0
  | .imp a b => max (U_nesting_depth a) (U_nesting_depth b)
  | .box a => U_nesting_depth a
  | .untl a b => 1 + max (U_nesting_depth a) (U_nesting_depth b)
  | .snce a b => max (U_nesting_depth a) (U_nesting_depth b)
```

This is the "maximum depth n of nesting of Us beneath an S" from GHR94 Lemma 10.2.7 (p. 572). It counts how many U-nesting levels exist through `.untl` chains. A `.snce` passes through (takes max without increment). At depth ≤ 1, all U-arguments are U-free.

### `junction_depth` (GHR94 Lemma 10.2.8 measure)

Defined mutually with `junction_depth_U` and `junction_depth_S`. The key insight:
- `junction_depth (.untl a b) = max (junction_depth_U a) (junction_depth_U b)` where `junction_depth_U` counts +1 when passing through `.snce`
- `junction_depth (.snce a b) = max (junction_depth_S a) (junction_depth_S b)` where `junction_depth_S` counts +1 when passing through `.untl`

This captures the alternation depth of U/S nesting. JD = 0 formulas are already separated. JD = 1 after box-normalization of separated sub-formulas gives `no_S_nested_in_U`. The `all_formulas_separable_aux` theorem inducts on this.

**GHR94 alignment**: This correctly encodes GHR94's "junction depth" (Section 10.2.8). The mutual recursion matches GHR94's definition where each U/S alternation adds 1.

### `count_U_subformulas` (inner induction for Lemma 10.2.6)

```lean
def count_U_subformulas : Formula → Nat
  | .untl _ _ => 1  -- count the U itself
  | ...
```

Counts the number of `.untl` nodes. Used in `lemma_10_2_6_self_contained_param` for the inner induction after fixing the U-nesting depth. Strictly decreases under `abstract_untl`.

---

## Oracle Architecture

Several functions take an `oracle` parameter:

```lean
(oracle : ∀ (chi : Formula), no_S_nested_in_U chi → junction_depth chi ≤ 1 → is_separable chi)
```

The oracle is the key architectural element for avoiding circular dependencies. The chain is:

1. **`single_U_formula_separable_noax_param`** (10.2.5) -- takes oracle for `junction_depth chi ≤ 1`. As of Phase A.2, the oracle is NEVER INVOKED when `snce_depth_of_U ≤ 1` (leaf case uses `snce_single_U_depth_one_separable` directly). Oracle is only needed for `snce_depth_of_U ≥ 2`.

2. **`lemma_10_2_6_self_contained_param`** (10.2.6) -- takes same oracle. Calls `single_U_formula_separable_noax_param` with the oracle threaded through.

3. **`no_S_nested_in_U_separable_direct_param`** (10.2.7) -- takes same oracle. For depth ≤ 1, calls `lemma_10_2_6_self_contained_param` with oracle. For depth ≥ 2, uses inner `count_U_subformulas` induction + `subst_in_separated_separable_jd` with oracle.

4. **`all_formulas_separable_aux`** (10.2.8) -- does NOT take an oracle parameter. Instead:
   - For `n ≥ 2`: provides oracle from the JD IH (`ih_jd (junction_depth chi) (by omega) chi ...`)
   - For `n = 1`: falls back to `no_S_nested_in_U_separable_direct` (which uses `all_separable` -- THIS IS THE REMAINING AXIOM LEAK)

The `n = 1` fallback in `all_formulas_separable_aux` is the current blocker. At JD = 1, the oracle that would be needed is exactly what the JD IH provides at level 0, but this requires a non-trivial argument about JD = 0 formulas being already separated.

**Why the oracle was introduced**: To break the circular dependency: 10.2.8 depends on 10.2.7, which depends on 10.2.6, which depends on 10.2.5, which needs to call back to something for the `.snce` case. GHR94 avoids this by making each lemma self-contained -- 10.2.5 uses only 10.2.4 directly.

---

## Axiom Inventory

### Current axioms in `SeparationThm.lean` (9 total)

**Temporal closure axioms for `is_separable` (4)**:
- `all_past_separable` -- H(separable) is separable
- `all_future_separable` -- G(separable) is separable
- `untl_separable` -- U(separable, separable) is separable
- `snce_separable` -- S(separable, separable) is separable

**Temporal closure axioms for `is_properly_separable` (4)**:
- `all_past_properly_separable`
- `all_future_properly_separable`
- `untl_properly_separable`
- `snce_properly_separable`

**Atom preservation (1)**:
- `proper_separation_preserves_atoms` -- properly separated form has same atoms

### Where axioms are used

- `snce_separable` is used in:
  - `single_U_formula_separable` (old version, `.snce` case)
  - `all_separable` (old version, `.snce` and `.untl` cases)
  - `snce_single_U_top_level_separable` (wraps snce_separable)
  - Various wrapper lemmas

- `all_separable` (proved from these axioms) is used in:
  - `no_S_nested_in_U_separable_noax` (backward-compat wrapper for 10.2.7)
  - `no_S_nested_in_U_separable_direct` (backward-compat wrapper)
  - `single_U_formula_separable_noax` (backward-compat wrapper)
  - `lemma_10_2_6_self_contained` (backward-compat wrapper)
  - `all_formulas_separable_aux` (the n = 1 fallback path)

### Axiom-free theorems (no custom axioms)

- `case1_psi_properties` -- fully proved, no axioms
- `elim_case_1`, `elim_case_1_gen` -- fully proved
- `elim_case_2`, `elim_case_2_gen` -- fully proved
- `elim_case_3`, `elim_case_3_gen` -- fully proved
- `elim_case_4`, `elim_case_4_gen` -- fully proved
- `case5_separable_Z_gen`, `case5_separable_Z` -- fully proved (DedekindZ.lean)
- `case3_equiv_Z_general` -- fully proved
- `Q_lemma_Z_fwd`, `Q_lemma_Z_bwd` -- fully proved
- `single_U_formula_separable_noax_param` -- axiom-free for n ≤ 1 paths (Phase A complete)
- `lemma_10_2_6_self_contained_param` -- axio-free when oracle is axiom-free
- `no_S_nested_in_U_separable_direct_param` -- axiom-free when oracle is axiom-free

### Theorems that still depend on axioms

- `all_formulas_separable_aux` -- n = 1 case calls `no_S_nested_in_U_separable_direct` which uses `all_separable` which uses `snce_separable` axiom
- `all_formulas_separable` -- top-level theorem, depends on above
- `all_separable` -- built on 4 temporal closure axioms
- `separation_theorem_int` -- wraps `all_separable`
- All properly separable variants

---

## GHR94-to-Lean Mapping Table

| GHR94 | Lean Function | File | Axiom-Free? | Notes |
|-------|---------------|------|-------------|-------|
| Lemma 10.2.3 (Cases 1-4) | `elim_case_1` through `elim_case_4` | Eliminations.lean | Yes | Fully proved |
| Lemma 10.2.3 (Cases 5-8) | `case5_separable_Z_gen` etc. | DedekindZ.lean | Yes | Uses case3_equiv_Z_general |
| Lemma 10.2.4 | `snce_single_U_depth_one_separable` | Hierarchy.lean | Yes | Direct construction |
| Lemma 10.2.5 | `single_U_formula_separable_noax_param` | Hierarchy.lean | Partial | Oracle-free for n≤1 (Phase A done) |
| Lemma 10.2.6 | `lemma_10_2_6_self_contained_param` | Hierarchy.lean | Partial | Oracle-free when oracle is |
| Lemma 10.2.7 | `no_S_nested_in_U_separable_direct_param` | Hierarchy.lean | Partial | Oracle-free when oracle is |
| Lemma 10.2.8 | `all_formulas_separable_aux` | Hierarchy.lean | No | n=1 uses `snce_separable` axiom |
| Theorem 10.2.9 | `all_formulas_separable` | Hierarchy.lean | No | Wraps all_formulas_separable_aux |
| (alt 10.2.9) | `separation_theorem_int` | SeparationThm.lean | No | Wraps all_separable |
| Q-lemma (10.3.6) | `Q_lemma_Z_fwd`, `Q_lemma_Z_bwd` | DedekindZ.lean | Yes | Z-specialization |
| Dedekind (10.3) | `K_plus_bot_on_Z`, etc. | DedekindZ.lean | Yes | K+/K-/Gamma all false on Z |

**GHR94's measure hierarchy for inductions**:
- Lemma 10.2.5: "k = max S-nesting above U" → Lean: `snce_depth_of_U`
- Lemma 10.2.6: "count of distinct U-types" → Lean: `count_U_subformulas`
- Lemma 10.2.7: "n = max U-nesting depth under S" → Lean: `U_nesting_depth`
- Lemma 10.2.8: "junction depth" → Lean: `junction_depth` (mutual recursion)

The mapping is precise and correct.

---

## Import Dependencies

```
Hierarchy.lean
  imports: NormalForm, SeparationThm, TemporalClosure, DedekindZ

SeparationThm.lean
  imports: Defs, Eliminations, FormulaOps, Distributivity, Duality

DedekindZ.lean
  imports: Defs, Eliminations, NegationEquiv, SeparationThm

Eliminations.lean
  imports: Defs, NegationEquiv, Distributivity, IntHelpers

NormalForm.lean
  imports: Eliminations, Distributivity, SeparationThm, DedekindZ
```

**Key circular dependency issue**: `Hierarchy.lean` imports `SeparationThm.lean` (to use `snce_separable` for backward-compat wrappers). Plan v22 calls for reversing this: Hierarchy should not need SeparationThm once all axioms are eliminated. Currently `all_formulas_separable_aux` calls `no_S_nested_in_U_separable_direct` which calls `all_separable` from SeparationThm.

**The n = 1 fallback in `all_formulas_separable_aux`** (line 2784):
```lean
· -- n = 1: fallback to axiom-dependent path (to be eliminated)
  exact no_S_nested_in_U_separable_direct (.snce χa χb) hns
```
This is the sole remaining leak point for the snce case. The `.untl` case has a symmetric issue at line 2820.

---

## Critical GHR94 Divergences

### Divergence 1: `all_formulas_separable_aux` n = 1 fallback

**GHR94**: The proof of Lemma 10.2.8 does NOT call back to an axiom at JD = 1. At JD = 1, the `no_S_nested_in_U` formula is handled directly by Lemma 10.2.7 (which is itself self-contained via 10.2.6 and 10.2.5).

**Current Lean**: At n = 1, `all_formulas_separable_aux` calls `no_S_nested_in_U_separable_direct` which ultimately uses `all_separable` (which is just an axiom wrapper). This is a circular path: 10.2.8 calls back to an axiom instead of using 10.2.7 self-containedly.

**Root cause (from plan v22)**: At n = 1, the JD IH provides a level-0 oracle, but the oracle call in `no_S_nested_in_U_separable_direct_param` receives formulas with JD ≤ 1 (not ≤ 0). This is the blocker described in plan v22 Phase B.

### Divergence 2: `all_separable` as a trivial theorem

**GHR94**: Theorem 10.2.9 is a consequence of the full hierarchy (Lemmas 10.2.4-10.2.8).

**Current Lean**: `all_separable` in `SeparationThm.lean` is proved by structural induction using temporal closure axioms directly. It is NOT a consequence of the hierarchy. This means `separation_theorem_int` (which wraps `all_separable`) still depends on 4 axioms.

### Divergence 3: Proper separability axioms separate from syntactic separability axioms

**GHR94**: There is one separation theorem. The "properly separated" notion corresponds to GHR94's semantic separation (past parts don't depend on future, etc.).

**Current Lean**: Two separate sets of axioms: 4 for `is_separable` and 4 for `is_properly_separable` (plus 1 atom preservation). The properly separable path is not addressed in plan v22, which focuses only on the `is_separable` path.

---

## Confidence Level

- **Formula type analysis**: VERY HIGH -- directly read from code
- **is_syntactically_separated**: VERY HIGH -- definitional, directly read
- **has_single_U_type for ¬U**: VERY HIGH -- definitional check
- **Elimination case witnesses**: HIGH -- read all 4 + generalized variants; Cases 5-8 confirmed from DedekindZ.lean
- **Measure analysis**: VERY HIGH -- all 4 measures directly read and analyzed
- **Oracle architecture**: HIGH -- traced through all `_param` function signatures and call sites
- **Axiom inventory**: VERY HIGH -- grepped all `axiom` declarations in all files; none in non-SeparationThm files
- **GHR94 mapping**: HIGH -- based on docstrings and proof structure; confirmed alignment for measures
- **GHR94 divergences**: VERY HIGH -- n = 1 fallback path is explicitly marked in the code comment

---

## Recommended Next Steps for Implementation

1. **Phase B (plan v22)**: The n = 1 case in `all_formulas_separable_aux` needs to call `no_S_nested_in_U_separable_direct_param` with an appropriate oracle. The oracle at n = 1 should use the JD = 0 case of the JD IH (which is trivially separation-by-identity for JD = 0 formulas). Key insight: JD = 0 formulas after box-normalization are syntactically separated (no U/S alternation) -- this can be used as the oracle base case without circularity.

2. **Phase C (plan v22)**: Once Phase B is done, `no_S_nested_in_U_separable_direct_param` is oracle-free, and `all_formulas_separable_aux` can be rewritten to call it without axiom dependencies.

3. **Critical constraint**: The `_noax_param` variants must NOT use `all_separable` or `snce_separable` anywhere in their call chain. Currently the n = 1 fallback does so. This is the sole remaining blocker for Phases A-C.

4. **Phase D/E (axiom replacement)**: Once the hierarchy is oracle-free, replace `all_separable`, `snce_separable`, `untl_separable` etc. in SeparationThm.lean with references to `all_formulas_separable` (which will then be axiom-free).
