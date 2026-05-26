# Research Report: Frame-Class Indicator Forcing in MCS

**Task**: 198
**Session**: sess_1779808712_c4ab21
**Date**: 2026-05-26

## 1. Sorry Locations and Goal States

### Sorry 1: `completeness_dense` (line 285)

**File**: `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean`

**Goal state**:
```
case inr
phi : Formula
h_valid_dense : valid_dense phi
h_not_deriv : -Nonempty (DerivationTree FrameClass.Dense [] phi)
h_cons : SetConsistent {phi.neg}
M : Set Formula
hM_sup : {phi.neg} <= M
hM_mcs : SetMaximalConsistent M
h_neg_in : phi.neg in M
h_not_box_dense : Chronicle.next_top.neg.box.neg in M
goal: False
```

**Interpretation**: M is a Dense-MCS containing `neg(box(neg(U(T,bot))))`. This means `neg(box(F'T)) in M`. We need to derive `False`, showing that every Dense-MCS must contain `box(F'T) = box(neg(U(T,bot)))`.

### Sorry 2: `completeness_discrete` (line 317)

**Goal state**:
```
case inl
phi : Formula
h_valid_discrete : valid_discrete phi
h_not_deriv : -Nonempty (DerivationTree FrameClass.Discrete [] phi)
h_cons : SetConsistent {phi.neg}
M : Set Formula
hM_sup : {phi.neg} <= M
hM_mcs : SetMaximalConsistent M
h_neg_in : phi.neg in M
h_box_dense : Chronicle.next_top.neg.box in M
goal: False
```

**Interpretation**: M is a Discrete-MCS containing `box(neg(U(T,bot))) = box(F'T)`. We need to derive `False`, showing that no Discrete-MCS can contain `box(F'T)`.

## 2. Key Definitions

### Formulas

- `top_formula = bot.imp bot = T` (tautology)
- `next_top = Formula.untl top_formula Formula.bot = U(T, bot)` -- "there is an immediate successor"
- `next_top.neg = neg(U(T,bot)) = F'T` -- "there is no immediate successor" (density at a point)
- `F'T = neg(U(T,bot))` -- the negation of "next top"; true iff the order is dense at this point

### Frame Classes

```
   Dense     Discrete
     ^         ^
      \       /
       Base
```

- `Base`: 37 base axioms (valid on all linear orders)
- `Dense`: Base + density axiom `GG(phi) -> G(phi)` for all phi
- `Discrete`: Base + prior_UZ `F(phi) -> U(phi, neg(phi))` + prior_SZ + z1

### Density Axiom (current)

```lean
| density (phi : Formula) :
    Axiom (phi.all_future.all_future.imp phi.all_future)
```

This is the schema `GG(phi) -> G(phi)` for all formulas phi.

### Discrete Axioms

```lean
| prior_UZ (phi : Formula) : Axiom (phi.some_future.imp (Formula.untl phi phi.neg))
| prior_SZ (phi : Formula) : Axiom (phi.some_past.imp (Formula.snce phi phi.neg))
| z1 (phi : Formula) : Axiom ((phi.all_future.imp phi).all_future.imp (phi.all_future.some_future.imp phi.all_future))
```

### Structural Base Axioms (Available in ALL frame classes)

These are critical base axioms about `U(T,bot)`:
- `discrete_propagate_fwd`: `U(T,bot) -> G(U(T,bot))`
- `discrete_propagate_bwd`: `U(T,bot) -> H(U(T,bot))`
- `discrete_box_necessity`: `U(T,bot) -> box(U(T,bot))`
- `discrete_symm_fwd`: `U(T,bot) -> S(T,bot)`
- `discrete_symm_bwd`: `S(T,bot) -> U(T,bot)`
- `left_mono_until_G`: `G(phi -> chi) -> (U(psi, phi) -> U(psi, chi))` (guard weakening)

## 3. Mathematical Analysis

### 3.1 The Density Axiom is INSUFFICIENT (Sorry 1)

**Central Finding**: The current density axiom `GG(phi) -> G(phi)` (a schema over all formulas phi) does NOT derive `neg(U(T,bot))` (= F'T). Therefore, `box(F'T)` is not a theorem of the Dense proof system, and the sorry at line 285 is currently **unprovable**.

**Proof that the schema is insufficient**:

1. On the discrete order (Z, <), every instance of `GG(phi) -> G(phi)` with atom-free phi is **valid**. The reason: on Z, atom-free formulas in the U,S tense logic evaluate uniformly at every time point (Z is translation-invariant), so both `G(phi)` and `GG(phi)` are either universally true or universally false, making the implication trivially valid.

2. The formula `neg(U(T,bot))` is atom-free and is **false** on Z (since every integer has an immediate successor).

3. By Craig interpolation / conservativity: since all atom-free instances of the density schema are valid on Z, no atom-free formula that fails on Z can be derived from the density schema. Therefore `neg(U(T,bot))` is not derivable from the density schema + base axioms.

4. More concretely: if we could derive `neg(U(T,bot))` from the density schema + base axioms, then by soundness, `neg(U(T,bot))` would be valid on all dense frames. But it would also need to be valid on Z (since the density schema is valid on Z for atom-free phi). But `neg(U(T,bot))` is false on Z -- contradiction.

**Wait -- the schema includes instances with atoms**. Instances like `GG(p) -> G(p)` for atom p are NOT valid on Z (as shown: with p true at all even integers except t=0, `GG(p) -> G(p)` fails at t=-1). So the density schema WITH atom instances is not sound on Z.

However, the atom instances cannot help derive atom-free `neg(U(T,bot))` due to a conservativity argument: any derivation of an atom-free formula from the density schema can be transformed to one using only atom-free instances (by substituting T for all atoms). Since atom-free instances are valid on Z but `neg(U(T,bot))` is not, the derivation is impossible.

**Counter-argument to the conservativity claim**: Substituting T for atoms in the density axiom `GG(p) -> G(p)` yields `GG(T) -> G(T)`, which is a tautology. But in a derivation, the atom p might appear in OTHER axioms or in intermediate steps. Still, the substitution lemma says: if `[] |-[Dense] phi`, then `[] |-[Dense] phi[T/p]` for any atom p. So if `neg(U(T,bot))` were derivable, it would remain derivable after substituting T for every atom (since it contains no atoms). And the derivation after substitution uses only axiom instances with T substituted, which are all valid on Z. Contradiction.

**Conclusion**: `neg(U(T,bot))` is NOT derivable from the density schema `GG(phi) -> G(phi)` plus base axioms. The sorry at line 285 requires an axiom extension.

### 3.2 The Discrete Case IS Provable (Sorry 2)

**Central Finding**: `U(T,bot)` IS derivable from the discrete axioms + base axioms. Therefore, `box(U(T,bot))` is derivable, and the sorry at line 317 CAN be eliminated.

**Derivation of `U(T,bot)` in the Discrete system**:

Step 1: Derive `T` (top_formula = bot.imp bot) -- use `identity Formula.bot`.

Step 2: Derive `F(T)` from `serial_future` (base axiom: `T -> F(T)`) and MP with step 1.

Step 3: Apply `prior_UZ(top_formula)` (discrete axiom): `F(T) -> U(T, neg(T))`.
This gives `U(T, neg(T)) = Formula.untl top_formula top_formula.neg`.

Step 4: Transform `U(T, neg(T))` to `U(T, bot)` via guard weakening:
  - Derive `neg(T) -> bot`: this is `((bot -> bot) -> bot) -> bot`.
    Proof: Assume `(bot -> bot) -> bot`. Since `bot -> bot` is a theorem (identity), by MP we get `bot`. So the whole implication is derivable.
  - Apply temporal necessitation: `G(neg(T) -> bot)`.
  - Apply `left_mono_until_G(top_formula.neg, Formula.bot, top_formula)`:
    `G(neg(T) -> bot) -> (U(T, neg(T)) -> U(T, bot))`.
  - MP twice: `U(T, bot) = next_top`.

Step 5: Derive contradiction with `box(F'T) in M`:
  - From Step 4: `next_top` is a Dense-free theorem (uses only Discrete + Base axioms).
  - By `theorem_in_mcs`: `next_top in M`.
  - From `h_box_dense: box(next_top.neg) in M` and Modal T (`box(phi) -> phi`):
    `next_top.neg in M`.
  - Contradiction: `next_top in M` and `next_top.neg in M` with `set_consistent_not_both`.

## 4. Proof Strategies

### 4.1 Strategy for Sorry 2 (Discrete -- SOLVABLE)

The derivation in Section 3.2 gives a complete proof. The implementation would:

1. Build the derivation tree for `next_top` (= `U(T,bot)`) in the Discrete system.
2. Use `theorem_in_mcs hM_mcs` to place `next_top` in M.
3. Use Modal T (via `SetMaximalConsistent.box_closure` or directly) to extract `next_top.neg` from `box(next_top.neg)`.
4. Apply `set_consistent_not_both` to get `False`.

**Key lemmas needed**:
- `identity : DerivationTree fc [] (bot.imp bot)`
- `serial_future` axiom
- `prior_UZ` axiom (Discrete)
- `left_mono_until_G` axiom (Base)
- `temporal_necessitation` rule
- `theorem_in_mcs`
- `set_consistent_not_both`

### 4.2 Strategy for Sorry 1 (Dense -- REQUIRES AXIOM EXTENSION)

The current density axiom `GG(phi) -> G(phi)` is **too weak** to derive `neg(U(T,bot))`. Two resolution options:

**Option A: Add `F'T` as an additional Dense axiom**

Add a new axiom constructor:
```lean
| dense_indicator : Axiom (Formula.untl (Formula.bot.imp Formula.bot) Formula.bot).neg
```
with `minFrameClass = .Dense`.

Pros:
- Minimal change to the axiom system
- `GG(phi) -> G(phi)` is retained (still sound and useful)
- `F'T` is the standard Burgess 1982 density axiom for U,S tense logic
- Soundness proof is straightforward: `neg(U(T,bot))` is valid on dense orders

Cons:
- Adds an axiom that is "redundant" with density in the semantic sense
- Need to prove soundness for the new axiom

**Option B: Replace `density` with `dense_indicator`**

Replace the `density` constructor with:
```lean
| dense_indicator : Axiom (Formula.untl (Formula.bot.imp Formula.bot) Formula.bot).neg
```

Pros:
- Follows Burgess 1982 exactly
- Single axiom instead of a schema

Cons:
- `GG(phi) -> G(phi)` would need to be derived from `F'T` + base axioms (possible but non-trivial)
- Requires re-proving all existing uses of `Axiom.density`
- More invasive change

**Recommendation: Option A** (add `F'T` alongside existing `density`).

With Option A, the proof of sorry 1 becomes:
1. `dense_indicator` axiom gives `neg(U(T,bot))` as a Dense theorem.
2. `necessitation` gives `box(neg(U(T,bot)))` = `box(F'T)`.
3. `theorem_in_mcs` places `box(F'T) in M`.
4. `h_not_box_dense: neg(box(F'T)) in M`.
5. `set_consistent_not_both` gives `False`.

## 5. Available Lemmas and Tools

### MCS Properties (in `Core/MCSProperties.lean`)
- `SetMaximalConsistent.closed_under_derivation`: If L subset S and L |- phi, then phi in S
- `SetMaximalConsistent.negation_complete`: Either phi in S or neg(phi) in S
- `SetMaximalConsistent.implication_property`: If (phi -> psi) in S and phi in S, then psi in S
- `SetMaximalConsistent.neg_excludes`: If neg(phi) in S, then phi not-in S
- `set_consistent_not_both`: phi in S and neg(phi) in S -> False

### MCS Membership (in `Core/MaximalConsistent.lean`)
- `theorem_in_mcs`: If |-[fc] phi and S is fc-MCS, then phi in S

### Derivation Tools (in `ProofSystem/Derivation.lean`)
- `DerivationTree.axiom`: Axiom instances (with `minFrameClass <= fc` guard)
- `DerivationTree.modus_ponens`: MP rule
- `DerivationTree.necessitation`: Necessitation rule ([] |- phi => [] |- box(phi))
- `DerivationTree.temporal_necessitation`: Temporal necessitation ([] |- phi => [] |- G(phi))

### Mixed Case Elimination (in `Chronicle/ChronicleToCountermodel.lean`)
- `mcs_mixed_case_absurd`: neg(box(F'T)) in A and neg(box(U(T,bot))) in A -> False

### Propositional Helpers (in `Theorems/Propositional.lean`)
- `identity`: |- phi -> phi
- `double_negation`: |- neg(neg(phi)) -> phi
- `contraposition`: If |- A -> B, then |- neg(B) -> neg(A)

## 6. Soundness Considerations

### `F'T` (= `neg(U(T,bot))`) is sound on dense frames

Semantic proof: On a dense order (D, <) with DenselyOrdered:
- `U(T,bot)` at t = exists s > t, T(s) and forall r in (t,s), bot(r)
- The guard `bot` means the interval (t,s) must be empty
- But by DenselyOrdered, for any s > t, there exists r with t < r < s
- Contradiction: the interval (t,s) is non-empty
- Therefore `U(T,bot)` is false at every t on any dense frame
- Therefore `neg(U(T,bot))` is valid on all dense frames

### `U(T,bot)` is sound on discrete frames

Already established implicitly by `prior_UZ_valid` and the derivation chain.
Direct semantic proof: On (Z, <) with SuccOrder, for any t, s = succ(t) > t and there is nothing between t and succ(t), so `U(T,bot)` is true at t.

## 7. Summary and Recommendations

1. **Sorry 2 (Discrete, line 317): SOLVABLE** with existing axioms. Derive `U(T,bot)` from `prior_UZ(T)` + `serial_future` + guard weakening, then derive contradiction via `theorem_in_mcs` + Modal T + `set_consistent_not_both`.

2. **Sorry 1 (Dense, line 285): REQUIRES AXIOM EXTENSION**. The current density axiom `GG(phi) -> G(phi)` is provably insufficient to derive `neg(U(T,bot))`. The fix is to add `F'T = neg(U(T,bot))` as a Dense axiom (following Burgess 1982 Section 1.6). This requires:
   - Adding a new axiom constructor `dense_indicator` (or `neg_next_top`)
   - Setting its `minFrameClass = .Dense`
   - Proving soundness: `neg(U(T,bot))` is valid on dense frames
   - Then the proof of sorry 1 follows by necessitation + theorem_in_mcs

3. **Implementation phases**:
   - Phase 1: Add `dense_indicator` axiom + soundness proof
   - Phase 2: Prove sorry 1 (Dense) using the new axiom
   - Phase 3: Prove sorry 2 (Discrete) using existing axioms
   - Phase 4: Verify with `lake build` and `#print axioms`
