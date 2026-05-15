# Task 140 — Teammate B Findings: Alternative Approaches and Prior Art

**Date**: 2026-05-15
**Focus**: Alternative approaches to standard translation, prior art in literature, Lean/Mathlib infrastructure opportunities, and deviation analysis

---

## Key Findings

1. **Reynolds 1994 Section 6 is the canonical source** for the `table` definition and `table_correctness`. The proof structure is extremely simple: a two-line definition by structural induction plus a trivial corollary. No alternative approach is better — follow Reynolds directly.

2. **The truth transfer step follows immediately from `table_correctness`** in Reynolds Theorem 18. The key logical connection is: `(T,<,h) |= A(t)  iff  (T,<,h) |= CA(t)`, which is precisely what `table_correctness` formalizes. This is a definitional consequence of how `table` is defined.

3. **The `succ_cofinal` sorry cannot be eliminated by proving `succ_cofinal`** — it is a genuine limitation confirmed by 12+ research rounds. Elimination requires replacing the entire fallback path with the Reynolds pipeline. Task 140's plan is correct: once `table` and `table_correctness` are implemented, `Transfer.lean` can wire the Reynolds pipeline which does not go through `succ_cofinal`.

4. **The `succ_cofinal` sorry sits in `dd_countermodel_chronicle_discrete`**, NOT in `doets_countermodel_discrete`. The latter currently delegates to the former as fallback. Once the Reynolds pipeline in `doets_countermodel_discrete` is complete, the delegation to `dd_countermodel_chronicle_discrete` is removed — eliminating the `succ_cofinal` sorry's effect on the proof.

5. **`finite_structures_good` (sorried) is the key remaining blocker** beyond `table`. It requires Doets 1989 Theorem 1.1 (k-type realizability). This blocks `chronicle_is_good` which blocks the Reynolds pipeline. Task 140 must address this or mark it as a dependency on Task 143.

6. **The Obendrauf 2024 Lean formalization** of Coalition Logic demonstrates a directly applicable pattern: use typeclasses to unify proof obligations across logics, and define modal truth by structural induction on the formula type. Their `s_entails_CLC` definition mirrors the structure needed for `table_correctness`.

---

## Literature Comparison: Different Authors on Standard Translation

### Reynolds 1994 (Primary Source)

**Location**: Section 6, "Expressive and Dedekind Completeness", pp. 122–123.

Reynolds defines the `table` (standard translation) by structural induction. For temporal structures `(T, <, h)`:

- Each atom `p` maps to the predicate `P(t)` (i.e., `t ∈ h(p)`)
- For `U(A, B)`, the table is: `∃s > t (CA(s) ∧ ∀u(t < u ∧ u < s → CB(u)))`

The correctness statement (implicitly: Claim before Theorem 5, p. 122-123) is:

> For all structures `(T, <)`, for all valuations `h`, for all `t ∈ T`:
> `(T, <, h) |= A(t)` iff `(T, <, h) |= CA(t)`

Reynolds notes: "A simple induction, (see for example [5]), establishes that all temporal formulas A have a corresponding monadic formula CA." The proof is not spelled out — it is considered a trivial structural induction. **This is the approach to follow.**

Reynolds then invokes this at Theorem 18 (full completeness, p. 132):
- Let `k` be one greater than the quantifier depth of the table `a(t)` of `A₀`
- The Z-structure satisfies the same monadic sentences of quantifier depth ≤ k as M
- "Thus Z like M is a model of `∃t a(t)`. Say `b ∈ Z` and `Z |= a(b)`. We have `Z |= A₀(b)` as promised."

The transfer from Z-structure to temporal truth of `A₀` uses `table_correctness` in a one-step application.

### Blackburn, de Rijke, Venema 2002 (Standard Modal Logic Reference)

The BdRV Appendix A (Venema 1991) gives the general construction at Definition A7: "Classical local model correspondent":

```
(pᵢ)¹ = Pᵢx₀
(¬φ)¹ = ¬φ¹
(φ ∨ ψ)¹ = φ¹ ∨ ψ¹
(◇(φ₁,...,φₙ))¹ = ∃x₁...xₙ(R◇(x₀,x₁,...,xₙ) ∧ ⋀φᵢ¹(xᵢ/x₀))
```

Theorem A8 (Correspondence) gives the correctness:
```
M, w |= φ  iff  M |= φ¹[x₀ ↦ w]
```

This is the **general abstract version** of `table_correctness`. It applies directly to the temporal setting. The Lean `MonadicFormula` type with De Bruijn indices is a faithful implementation of the `φ¹` translation.

**Recommendation**: The `table_correctness` proof can be modeled on the BdRV Theorem A8 proof structure. The proof is by structural induction on the formula, and each case corresponds to unfolding one constructor in both `truthAt` and `eval`. No alternative approaches offer advantages.

### Venema 1991 ch2 (Sahlqvist)

This chapter is focused on non-ξ rules and canonicity, not on the standard translation per se. It provides:
- The general framework for first-order model correspondence (Definition 2.3.5, Lemma 2.3.6)
- The substitution method for first-order correspondents of Sahlqvist formulas

This is **not directly relevant** to `table_correctness`. The standard translation proof does not require Sahlqvist machinery; it is a much simpler structural induction.

### Venema 2001 (Temporal Logic Survey)

Section 3 of the survey defines temporal truth (equation 1) and implicitly uses the standard translation when discussing correspondence. The key insight for our setting: the truth definition (1) is exactly the semantics that the `table` translation computes, case by case.

The survey confirms: the standard translation is well-established folklore, not a deep theorem. The correctness proof is immediate by induction.

### Burgess 1984 (Basic Tense Logic)

Burgess's approach is constructive — the step-by-step method (also documented in Verbrugge 2004). This is an **alternative completeness proof strategy** that avoids the Reynolds pipeline entirely:

Instead of: chronicle → k-equivalence → Z-structure → Reynolds Theorem 18

Burgess/Verbrugge use: step-by-step construction of a model directly satisfying the target conditions.

**However**: The project has already committed to the Reynolds pipeline architecture. Verbrugge's Theorem 5 and the step-by-step method for **D** (discrete tense logic) is an instructive reference but would require significant architectural changes. It is not recommended as an alternative at this stage.

The Verbrugge/Burgess approach for **Z** (integers, Section 4) uses Z-adequate sets and is more directly comparable to the Reynolds approach. Their key insight is that for strong completeness over **Z**, compactness fails, so a finite-closure technique is needed — this is exactly what Reynolds' k-types (depth-bounded formulas) provide. Both approaches are implementing the same underlying mathematics.

### Caleiro, Viganò, Volpe 2013 (Mosaic Method)

The mosaic method is an **alternative completeness proof technique** that does not use canonical models at all. Instead, it constructs models from finite "tiles" (mosaics). While mathematically interesting, it:
- Does not have a clear advantage over the Reynolds pipeline for this specific task
- Would require complete architectural rearchitecture
- Is best viewed as future work or as a cross-check

**Not recommended** as an alternative for Task 140.

---

## Lean/Mathlib Opportunities

### 1. Structural Induction on Formula

The `table_correctness` proof is a textbook structural induction. The key Lean infrastructure is:

```lean
-- Lean 4 structural induction on Formula:
induction φ with
| atom a => ...
| bot => ...
| imp φ ψ ihφ ihψ => ...
| box φ ih => ...
| all_future φ ih => ...
| all_past φ ih => ...
| untl φ ψ ihφ ihψ => ...
| snce φ ψ ihφ ihψ => ...
```

This is directly supported by Lean 4's `induction` tactic on the `Formula` inductive type.

### 2. `eval` Definition as Key Bridge

The `eval` function in `NEquivalence.lean` is the Tarski satisfaction relation for `MonadicFormula`. The `table_correctness` statement would be:

```lean
theorem table_correctness (sig : MonadicSignature) (φ : Formula)
    (M : OrderedMonadicStructure sig) (t : M.carrier)
    (atomMap : sig.preds → Formula)
    (h_atom : ∀ p, M.interp p t ↔ (atomMap p).truthAt ...) :
    eval M (fun _ => t) (table sig φ) ↔ truthAt ... t φ
```

The `eval` function is already defined without sorries. The `table` definition needs to be filled in first, then `table_correctness` follows by `simp` unfolding both `eval` and `truthAt` for each constructor.

### 3. `Fin.cons` for De Bruijn Variable Binding

The `eval` uses `Fin.cons x env` for quantifier binding. This is the standard Mathlib pattern. Lean's `simp` lemmas for `Fin.cons` are available:
- `Fin.cons_zero`: `Fin.cons x env 0 = x`
- `Fin.cons_succ`: `Fin.cons x env (Fin.succ i) = env i`

These will be needed in the `table_correctness` proof for the quantifier cases (G, H, Until, Since).

### 4. `Fintype` and `Finset` Infrastructure

For `finite_structures_good` (needed for `chronicle_is_good`):
- `Fintype.ofFinite`: converts `Finite` to `Fintype`
- `Subtype.fintype`: finite subtypes of finite types are finite
- `Fintype.Pi.fintype`: `Fintype (Π i, f i)` from finite domain and range

These are all available in Mathlib and already imported via existing files.

### 5. `LinearOrder` and `SuccOrder` Infrastructure

The chronicle-as-monadic-structure already has `SuccOrder` and `PredOrder` instances (lines 404-415 of NEquivalence.lean). The Z-interval structure inherits `ℤ`'s order. Mathlib's:
- `Order.succ_le_of_lt`: key for Z1-type arguments
- `Int.instLinearOrder`, `Int.instSuccOrder`: give ℤ its discrete structure

These enable the `no_boundary_at_successor` proof (already complete) and will help with `finite_structures_good`.

---

## Recommended Alternatives

### Recommendation 1: Follow Reynolds Section 6 Exactly for `table` Definition

The `table` body should implement the inductive cases directly as Reynolds defines them:
- Atom `a`: `MonadicFormula.atom (atomLookup a) 0` (predicate for atom `a` applied to free variable `t`)
- Bot: `MonadicFormula.not (MonadicFormula.not ... bot formula)`
- Imp φ ψ: `MonadicFormula.not (MonadicFormula.and (table φ) (MonadicFormula.not (table ψ)))`
- Box φ: needs discussion (this is the modal operator — it would require a different predicate or be expanded as a bounded quantifier if viewed temporally)
- G φ: `MonadicFormula.all (MonadicFormula.not (MonadicFormula.and (MonadicFormula.lt 1 0) (MonadicFormula.not (shift (table φ))))`
- H φ: symmetric to G
- Until φ ψ: the Reynolds formula `∃s > t (CA(s) ∧ ∀u(t < u ∧ u < s → CB(u)))`
- Since φ ψ: symmetric to Until

**Critical design issue**: The current `table` signature takes a `MonadicSignature` as a parameter but does not take an `atomMap : sig.preds → Formula`. This creates a problem: how does the table for atomic formulas map to monadic predicates? The signature needs either:
- Option A: `table` takes an explicit `atomMap : Formula → sig.preds` mapping atomic formulas to predicate symbols
- Option B: The signature is constructed from the formula (so `sig.preds` IS indexed by subformulas)

Looking at `Transfer.lean` lines 69-83: `mkSigFrom` uses `Fin 1` as a placeholder, and `mkAtomMap` uses a dummy mapping. These placeholders must be replaced with genuine implementations. **This is the primary design choice that needs resolution.**

The simplest approach consistent with Reynolds: parameterize `table` by an atom injection `atomInj : Atom → sig.preds` (where `Atom` is the type of propositional atoms). This is cleaner than using the full formula as the key.

### Recommendation 2: Separate `table_correctness` into Two Parts

Rather than one monolithic theorem, prove:
1. `table_atom_correct`: for atomic formulas, the table is correct (base case)
2. `table_inductive_correct`: for compound formulas, correctness follows from induction

This mirrors Obendrauf's approach of splitting proofs into per-datatype lemmas. For Lean 4 with structural induction, this is natural.

### Recommendation 3: Use `simp` Extensionally in `table_correctness`

For each constructor, the proof should unfold:
- `table sig φ` → reveals the `MonadicFormula` structure
- `eval M env` → reveals the Tarski satisfaction condition
- `truthAt` (temporal semantics) → reveals the semantic clause

Each case should close with `simp [eval, truthAt, table]` or explicit `exact` after unfolding. The Obendrauf formalization demonstrated this pattern works well in Lean 4.

### Recommendation 4: Do NOT Attempt to Close `finite_structures_good` in Task 140

`finite_structures_good` depends on Doets 1989 Theorem 1.1 (finitely many k-types for a finite signature). This is Task 143's scope. Task 140 should:
- Implement `table` definition
- Prove `table_correctness`
- Prove `table_depth_bound`
- Wire the Reynolds pipeline in `Transfer.lean` (keeping `chronicle_is_good` as sorry)
- Verify that the sorry count is not increased: `chronicle_is_good` was already sorry before Task 140

The `succ_cofinal` elimination happens automatically once `doets_countermodel_discrete` no longer delegates to `dd_countermodel_chronicle_discrete`. Since `doets_countermodel_discrete` already calls `chronicle_is_good` (via the planned Reynolds pipeline), and `chronicle_is_good` is sorry, the sorry count stays flat — but the architecture is correct and the `succ_cofinal` sorry is no longer in the main proof path.

### Recommendation 5: For `mkSigFrom` and `mkAtomMap`, Use Formula Atoms

Replace the placeholder `mkSigFrom` with a genuine implementation:

```lean
-- Build signature from formula: predicates indexed by atoms appearing in φ
def mkSigFrom (φ : Formula) : MonadicSignature where
  preds := φ.atoms  -- or Finset (Atom), converted to Fintype
  ...
```

And `mkAtomMap` should map each atom predicate to its corresponding formula:
```lean
def mkAtomMap (φ : Formula) (sig : MonadicSignature) : sig.preds → Formula :=
  fun p => Formula.atom p.val  -- if sig.preds is Formula.atoms
```

This is consistent with Reynolds's convention: "each atom p in the temporal language corresponds to a predicate symbol P."

---

## Evidence / Examples

### From Reynolds 1994

The exact truth transfer step in Theorem 18 (p. 132):
> "Thus Z like M is a model of `∃t a(t)`. Say `b ∈ Z` and `Z |= a(b)`. We have `Z |= A₀(b)` as promised."

Here `a(t)` is the table of `A₀`. The step from `Z |= a(b)` to `Z |= A₀(b)` is `table_correctness` applied once. The step from `M |= ∃t a(t)` to `Z |= ∃t a(t)` is k-equivalence (since `a(t)` has quantifier depth ≤ k, and M and Z are k-equivalent by Theorem 6).

### From NEquivalence.lean

The `eval` function (line 217) is already correct and complete:
```lean
def eval ... : MonadicFormula sig n → Prop
  | .atom p i => M.interp p (env i)
  | .lt i j => env i < env j
  | .not α => ¬ eval M env α
  | .and α β => eval M env α ∧ eval M env β
  | .all α => ∀ (x : M.carrier), eval M (Fin.cons x env) α
  | .ex α => ∃ (x : M.carrier), eval M (Fin.cons x env) α
```

This is exactly the Tarski semantics. `table_correctness` says: if `table` is defined correctly, then `eval M (fun _ => t) (table sig φ) ↔ truthAt ... t φ`.

### From Table.lean

The `operator_depth` function (line 40) is genuine and correct. The `table_depth_bound` can be proved by structural induction once `table` is defined, as each temporal operator adds exactly 1 quantifier in the FO translation.

### From Transfer.lean

The Reynolds pipeline stub (lines 119-136) shows exactly what needs to be filled in:
```lean
-- Step 1: Extract chronicle
-- let M := extract_chronicle_as_prior A h_mcs h_box_discrete
-- Step 2: Build signature and atom map
-- let sig := mkSigFrom φ
-- ...
-- Step 5: Transfer truth from chronicle to Z-model (requires table correctness)
```

Steps 1-4 are already implemented (behind sorries in `chronicle_is_good`). Step 5 is what Task 140 provides.

### From Obendrauf 2024

Directly applicable pattern from Section 8.4 (Truth Lemma, p. 12):
> "This proof is by induction on ψ. ... For space reasons we include only the proof for C_G ψ..."

The structure of their truth lemma proof matches what `table_correctness` needs: induction on the formula, with each case unfolding the modal truth definition and the satisfaction relation. Their use of `simp only` and `apply` matches the expected Lean 4 proof style.

---

## Confidence Level

**High confidence** on:
- Reynolds 1994 Section 6 is the correct source to follow literally for `table` and `table_correctness`
- The proof structure (structural induction, unfolding) is standard and well-supported
- `succ_cofinal` elimination happens by architecture change (removing delegation), not by proving `succ_cofinal`
- `finite_structures_good` is out of scope for Task 140; it belongs to Task 143

**Medium confidence** on:
- The exact Lean representation of the `table` function (the `atomMap` parameter design choice)
- Whether `table_depth_bound` will require additional Lean-specific lemmas about `quantifier_depth`

**Low confidence** on:
- Whether the `sum_preservation` sorry in `KEquivalenceFramework` will block the Reynolds pipeline at the `very_good_implies_good` step even after `table_correctness` is proved
- The exact amount of Lean boilerplate needed to lift `k_equiv` to temporal truth (Step 5 in the pipeline)

---

## Summary of Recommended Implementation Order

1. **Fix `mkSigFrom` and `mkAtomMap`** in Transfer.lean to use genuine atom extraction
2. **Implement `table` body** in Table.lean following Reynolds Section 6 case-by-case
3. **Prove `table_correctness`** by structural induction on φ, unfolding `eval` and `truthAt`
4. **Prove `table_depth_bound`** by structural induction, trivial once `table` is defined
5. **Wire Steps 1-5 in `doets_countermodel_discrete`** in Transfer.lean
6. **Verify** that `dd_countermodel_chronicle_discrete` delegation is removed and `succ_cofinal` is no longer in the main proof path
7. **Mark `chronicle_is_good` as still sorry** (blocked on Task 143), with an updated TODO comment

Steps 2-4 are the core of Task 140 and should be straightforward. Step 5 requires careful threading of types. Steps 6-7 complete the succ_cofinal elimination.
