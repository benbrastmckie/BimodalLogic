# Lean Infrastructure Inventory for GHR93 Expressive Completeness (Phase 4B)

**Task**: 155 | **Date**: 2026-05-20 | **Scope**: EF Game Infrastructure for GHR93 Theorem 9.3.1

---

## 1. OrderedMonadicStructure

**File**: `Theories/Bimodal/Metalogic/WeakCanonical/MonadicFO.lean`, lines 103-134

**Definition** (line 103):
```lean
structure OrderedMonadicStructure (sig : MonadicSignature) extends MonadicStructure sig where
  carrier_order : LinearOrder carrier
```

**Key operations**:
- `subinterval sig M a b` (line 129): Restricts to `{x : M.carrier // a <= x /\ x <= b}` with inherited order and predicates. This IS substructure restriction to a closed interval.
- `subinterval_singleton_finite` (line 141): `[a,a]` is finite.
- `subinterval_two_element_finite` (line 161): `[a, succ a]` is finite.
- `ZStructure.toOrdered` (line 200): Converts a Z-structure (carrier = Z) to OrderedMonadicStructure.

**Available**: Full subinterval infrastructure. No general "restriction to open interval" or "restriction to a subset defined by a predicate".

---

## 2. NormalForm

**File**: `Theories/Bimodal/Metalogic/WeakCanonical/NormalForm.lean`, lines 134-183

**Definition** (line 134):
```lean
def NormalForm (sig : MonadicSignature) : Nat -> Nat -> Type
  | 0, n => AtomKind sig n -> Bool
  | k + 1, n => (AtomKind sig n -> Bool) * (NormalForm sig k (n + 1) -> Bool)
```

**AtomKind** (line 58):
```lean
inductive AtomKind (sig : MonadicSignature) (n : Nat) : Type where
  | pred (p : sig.preds) (i : Fin n) : AtomKind sig n
  | order (i j : Fin n) (h : i != j) : AtomKind sig n
```

**Fintype/DecidableEq**: Both instances exist (lines 166-183). `normalForm_fintype`, `normalForm_decEq`.

**Key theorems**:
- `nf_eval_nf` (line 198): Semantic evaluation of normal forms.
- `nf_characteristic` (line 215): Computes the unique NF for a given (M, env, k).
- `nf_exists_unique` (line 277): Each (M, env) satisfies exactly one depth-k NF. **Sorry-free**.
- `nf_agreement_monotone` (line 339): NF agreement is monotone in depth. **Sorry-free**.
- `doets_lemma_1_1` (line 433): Bridge theorem -- NF agreement implies formula agreement. **Sorry-free**.
- `atomKind_card` (line 562): Card(AtomKind sig n) = atomCount(p, n). **Sorry-free**.
- `normalForm_card` (line 594): Card(NormalForm sig k n) = nfCount(p, k, n). **Sorry-free**.
- `normalForm_equiv_fin` (line 611): Bijection NormalForm <-> Fin(nfCount). **Sorry-free**.

---

## 3. MonadicFormula

**File**: `Theories/Bimodal/Metalogic/WeakCanonical/MonadicFO.lean`, lines 63-73

**Definition** (line 63): Inductive type with constructors `atom`, `lt`, `not`, `and`, `all`, `ex`, parameterized by signature and number of free variables (De Bruijn).

**eval** (line 216): Tarski satisfaction. `eval M env phi` evaluates phi under environment `env : Fin n -> M.carrier`.

**quantifier_depth** (line 76): Counts max nesting of all/ex.

**lift** and related operations: `finLift`, `lift`, `weaken`, `insertEnv`, `lift_eval`, `weaken_eval` -- all in MonadicFO.lean.

---

## 4. k_equiv

**File**: `Theories/Bimodal/Metalogic/WeakCanonical/NEquivalence.lean`, lines 64-107

**Definitions**:
- `k_type_of sig k M` (line 64): `NormalForm sig k 0 -> Bool` via `nf_eval_nf` + `decide`.
- `k_equiv sig k M N` (line 72): `k_type_of sig k M = k_type_of sig k N`.

**Key lemmas**:
- `k_equiv_iff_same_type` (line 79): Trivial unfolding.
- `k_equiv_monotone` (line 91): m <= k and k-equiv implies m-equiv. **Sorry-free**.
- `k_equiv_of_iso` (IntegerModel.lean, line 101): Order isomorphism preserving predicates implies k-equiv for all k. **Sorry-free**.
- `subinterval_of_subinterval_k_equiv` (IntegerModel.lean, line 283): Nested subintervals flatten. **Sorry-free**.

**KEquivalenceFramework** (NEquivalence.lean, line 1084): Typeclass wrapping `equiv_at`, `equiv_is_equiv`, `equiv_monotone`, `finite_types`, `sum_preservation`. Default instance at line 1113 uses concrete `k_equiv`.

---

## 5. StaviFormula and StaviConnectives

**File**: `Theories/Bimodal/Metalogic/WeakCanonical/StaviConnectives.lean` (540 lines total)

### StaviFormula (line 111):
```lean
inductive StaviFormula : Type where
  | base (phi : Formula)
  | stavi_untl (A B : StaviFormula)
  | stavi_snce (A B : StaviFormula)
  | neg (phi : StaviFormula)
  | conj (phi psi : StaviFormula)
```

### Semantic definitions (all sorry-free):
- `stavi_U_truth` (line 67): U'(A,B) semantics on base Formula operands.
- `stavi_S_truth` (line 89): S'(A,B) semantics on base Formula operands.
- `stavi_temporal_truth` (line 129): Extended truth for StaviFormula on OrderedMonadicStructure. Handles `stavi_untl`/`stavi_snce` with recursive StaviFormula operands.

### FO translations (all sorry-free):
- `cofinal_above_fo` (line 176): FO formula for "q is cofinal above t".
- `stavi_U_fo` (line 194): FO for U'(p,q).
- `cofinal_below_fo` (line 212): FO for "q is cofinal below t".
- `stavi_S_fo` (line 229): FO for S'(p,q).

### Discrete equivalences (all sorry-free):
- `cofinal_above_iff_succ` (line 263): In SuccOrder, cofinal above = B(succ(t)).
- `cofinal_below_iff_pred` (line 287): In PredOrder, cofinal below = B(pred(t)).
- `until_bot_iff_succ` (line 313): U(B, bot)(t) <-> B(succ(t)).
- `since_bot_iff_pred` (line 337): S(B, bot)(t) <-> B(pred(t)).
- `stavi_U_discrete_equiv` (line 362): U'(A,B) <-> U(B,bot) /\ not U(A,B).
- `stavi_S_discrete_equiv` (line 384): S'(A,B) <-> S(B,bot) /\ not S(A,B).

### flatten_stavi (line 411):
Converts StaviFormula to standard Formula in discrete orders. **Sorry-free**.

### flatten_stavi_correct (line 459):
Correctness theorem for discrete case. **Sorry-free, all 5 cases proved** (base, neg, conj, stavi_untl, stavi_snce).

---

## 6. EFGames.lean Current State

**File**: `Theories/Bimodal/Metalogic/WeakCanonical/EFGames.lean` (280 lines)

### Definitions (all sorry-free):
- `EFPosition sig` (line 69): Game position tracking selected elements from two structures.
- `ef_duplicator_wins` (line 88): Predicate/order agreement on selected elements.
- `game_depth sig` (line 109): Depth function `f(n+1) = (1 + 3*f(n)) * (2*k_n) + 2`.
- `stavi_depth` (line 185): Depth of a StaviFormula.
- `stavi_n_equiv` (line 199): Two pointed structures agree on all StaviFormulas of depth <= game_depth(n).

### Theorems (all sorry-free):
- `game_depth_succ_ge_two` (line 119): f(n+1) >= 2.
- `game_depth_strict_mono` (line 138): f(n) < f(n+1).
- `game_depth_mono` (line 160): n <= m => f(n) <= f(m).
- `stavi_n_equiv_symm` (line 208): n-equiv is symmetric.
- `stavi_n_equiv_mono` (line 219): n-equiv is monotone in n.

### The main sorry (line 270-277):
```lean
noncomputable def stavi_expressive_completeness
    (sig : MonadicSignature) (atomMap : Formula -> sig.preds)
    (psi : MonadicFormula sig 1) :
    { A : StaviFormula //
      forall (M : OrderedMonadicStructure sig) (t : M.carrier),
        stavi_temporal_truth M atomMap t A <->
        eval M (fun _ => t) psi } := by
  sorry
```
**This is the single sorry** in EFGames.lean -- the main theorem to be proved.

---

## 7. temporal_truth

**File**: `Theories/Bimodal/Metalogic/WeakCanonical/Table.lean`, lines 182-193

**Definition**:
```lean
def temporal_truth {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (atomMap : Formula -> sig.preds)
    (t : M.carrier) : Formula -> Prop
```
Evaluates standard temporal formulas on any OrderedMonadicStructure. Handles atom, bot, imp, box, untl, snce.

**Relationship to eval**: `table_correctness` (line 244) proves `eval M (fun _ => t) (table sig atomMap phi) <-> temporal_truth M atomMap t phi`. **Sorry-free**.

**Relationship to stavi_temporal_truth**: `stavi_temporal_truth M atomMap t (.base phi) = temporal_truth M atomMap t phi` (by definition, line 133 of StaviConnectives.lean).

---

## 8. operator_depth

**File**: `Theories/Bimodal/Metalogic/WeakCanonical/Table.lean`, lines 42-48

**Definition**:
```lean
def operator_depth : Formula -> Nat
  | .atom _ => 0
  | .bot => 0
  | .imp phi psi => max (operator_depth phi) (operator_depth psi)
  | .box phi => operator_depth phi + 1
  | .untl phi psi => max (operator_depth phi) (operator_depth psi) + 2
  | .snce phi psi => max (operator_depth phi) (operator_depth psi) + 2
```

**Properties**:
- `table_depth_bound` (line 151): `(table sig atomMap phi).quantifier_depth <= operator_depth phi`. **Sorry-free**.

---

## 9. Interval/Substructure Infrastructure

### Subinterval restriction: EXISTS
- `OrderedMonadicStructure.subinterval` (MonadicFO.lean, line 129): Closed interval [a,b] restriction.
- `subinterval_of_subinterval_k_equiv` (IntegerModel.lean, line 283): Nested subintervals flatten for k-equiv.
- `good_of_very_good_subinterval` (IntegerModel.lean, line 307): Extract good subintervals from very_good.

### Ordered sum: EXISTS
- `orderedSum sig I ms` (NEquivalence.lean, line 122): Sigma type with lexicographic order.
- `doets_lemma_1_4` (OrderedSum.lean, line 34): Sum preserves k-equiv pointwise. **Delegates to KEquivalenceFramework.sum_preservation** which is proved (sorry-free via `sum_preservation_proof`).
- `doets_lemma_1_5` (OrderedSum.lean, line 50): Type-matching variant. **Sorried** (not on critical path for discrete case).

### Z-interval structures: EXISTS
- `ZIntervalStructure sig` (IntegerModel.lean, line 46): Optional lo/hi bounds on Z.
- `ZIntervalStructure.toOrdered` (IntegerModel.lean, line 72): Converts to OrderedMonadicStructure.
- `good sig k M` (IntegerModel.lean, line 84): M is k-equiv to some Z-interval.
- `very_good sig k M` (IntegerModel.lean, line 91): Every subinterval is good.
- `finite_structures_good` (IntegerModel.lean, line 176): Finite structures are good. **Sorry-free**.
- `good_of_split_at_succ` (IntegerModel.lean, line 416): Decomposition at succ gives good. **Sorry-free**.

### Key sorry'd infrastructure in IntegerModel.lean:
1. `no_gaps_discrete` (line 837): **Sorried** (needs Reynolds Theorem 5 for general Prior structures).
2. `cofinal_decomposition_k_equiv` (line 1130): **Sorried** (boundary-point duplication issue).
3. `ordered_sum_of_good_bounded_is_good` for k>=2 (line 1148): **Sorried** (shift-and-glue construction).

---

## 10. What's MISSING for GHR93 Phase 4B

### 10a. The core sorry: stavi_expressive_completeness

The main theorem at EFGames.lean:270 is sorry'd. The proof requires the full game-theoretic argument from GHR93 Section 8. This is estimated at 1000-1500 lines.

### 10b. Missing EF game infrastructure

The following GHR93 machinery does NOT exist yet:

1. **EF game strategy/play types**: No `EFStrategy` or `EFPlay` type. Only `EFPosition` and `ef_duplicator_wins` exist. Need:
   - Spoiler move types (choose structure, choose element)
   - Duplicator response types
   - Full game tree / game play sequence
   - Winning strategy definition (for n rounds)

2. **Game-formula connection (Fraisse theorem)**: No theorem connecting "Duplicator wins n-round game" to "structures agree on all formulas of depth <= f(n)". This is the fundamental EF game theorem.

3. **L_k / R_k gap detection formulas**: Referenced in EFGames.lean docstring ("left_formula / right_formula: Gap detection formulas") but **not defined**. These are formulas that detect the "gap" structure needed for Stavi connective cases (Cases II-IV of the main induction).

4. **Game composition**: No machinery for composing EF games on substructures into games on the full structure. This is essential for the inductive step.

5. **Interval decomposition for games**: No notion of decomposing a structure into "left of selected point" and "right of selected point" for game moves.

6. **Normal form enumeration at game depth**: While `Fintype.card (NormalForm sig prev 1)` is used in `game_depth`, there is no explicit enumeration of NF-definable properties as StaviFormulas for the inductive construction.

### 10c. Missing stavi-to-FO bridging

The connection from `stavi_temporal_truth` back to `eval` on arbitrary `OrderedMonadicStructure` is only established for **base formulas** (via `temporal_truth` and `table_correctness`). For the Stavi connectives themselves, there is no theorem showing `stavi_temporal_truth M atomMap t (.stavi_untl A B)` is equivalent to some `eval M env psi` for a monadic FO formula `psi`. The FO translations `stavi_U_fo`/`stavi_S_fo` exist but their correctness theorems connecting back to `stavi_temporal_truth` are **not proved**.

### 10d. Existing sorry inventory (WeakCanonical/)

| File | Sorry | Description | Critical Path? |
|------|-------|-------------|---------------|
| EFGames.lean:277 | `stavi_expressive_completeness` | Main theorem | **YES** |
| IntegerModel.lean:859 | `no_gaps_discrete` | Reynolds Thm 14 | Yes (one_class) |
| IntegerModel.lean:1135 | `cofinal_decomposition_k_equiv` | Lemma 16 helper | Yes (very_good_implies_good) |
| IntegerModel.lean:1194 | `ordered_sum_of_good_bounded_is_good` | Shift-and-glue | Yes (very_good_implies_good) |
| OrderedSum.lean:56 | `doets_lemma_1_5` | Type-matching sum | No (dense case only) |
| Transfer.lean:574 | Transfer sorry | Upstream dependency | Partially |
| TruthLemma.lean | 6 sorries | Various truth lemma cases | No (non-critical) |

### 10e. Summary of building blocks status

| Component | Status | Lines | Sorry-free? |
|-----------|--------|-------|-------------|
| OrderedMonadicStructure + subinterval | Complete | ~80 | Yes |
| NormalForm + Fintype + doets_lemma_1_1 | Complete | ~550 | Yes |
| MonadicFormula + eval | Complete | ~200 | Yes |
| k_equiv + k_type_of + monotonicity | Complete | ~50 | Yes |
| orderedSum + doets_lemma_1_4 | Complete | ~1000 | Yes |
| StaviFormula + stavi_temporal_truth | Complete | ~150 | Yes |
| Stavi discrete equivalences + flatten | Complete | ~300 | Yes |
| EF game position + game_depth + n-equiv | Complete | ~160 | Yes |
| stavi_expressive_completeness | **Sorry** | 1 sorry | **No** |
| EF game strategy/play/composition | **Missing** | 0 | N/A |
| L_k / R_k gap formulas | **Missing** | 0 | N/A |
| Game-formula connection (Fraisse) | **Missing** | 0 | N/A |

---

## Conclusion

The foundational infrastructure (normal forms, k-equivalence, ordered sums, Stavi semantics, game depth function, n-equivalence) is solid and sorry-free. The gap is the **game-theoretic core**: no EF game strategies, no game composition, no gap-detection formulas, and no Fraisse theorem connecting games to formula equivalence. The single sorry in EFGames.lean (`stavi_expressive_completeness`) encompasses all of this missing machinery. Implementation should focus on: (1) defining game strategies and plays, (2) proving the game-formula connection, (3) building the four-case induction (atoms, Until witness, Since witness, gap/Stavi), (4) constructing L_k/R_k formulas for gap detection.
