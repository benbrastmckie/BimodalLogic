# Teammate A Findings: Lemma 3.2.2 + Prop 4.3 Formalization Strategy

**Task**: 273 (chronicle_gap_contradiction_proof)
**Artifact**: 12 (teammate A)
**Focus**: Path B formalization — Lemma 3.2.2 + Prop 4.3 to bypass P1/P2 circularity
**Date**: 2026-06-12

---

## Summary

Path B (Lemma 3.2.2 + Prop 4.3) is viable and substantially simpler than the
handoff estimated. The core insight: Prop 4.3's structural induction on
`MonadicFormula` needs Lemma 3.2.2 only in the **negation case**, and only to
reduce an n-free-variable `EA` formula to a conjunction of 2-free-variable `EA`
formulas — each of which Prop 4.2 (already done in Phase 4) can negate. The
formalization of Lemma 3.2.2 is straightforward once we understand its statement
precisely from the PDF. The gap between Prop 4.3 and the existing P1/P2
induction is bridgeable via two lemmas already partially constructed in
`FoToVecEA.lean`.

---

## Key Findings

### Finding 1: Lemma 3.2.2 — Precise Mathematical Content

**Source**: Rabinovich 2014, p. 4, Lemma 3.2(2) (not "Lemma 3.2.2" as a separate
lemma — the paper uses "Lemma 3.2" with numbered clauses).

The PDF states (p. 4, Lemma 3.2):

> (2) Every ∃∀-formula is equivalent to a conjunction of ∃∀-formulas with at
> most two free variables.

The proof is implicit: the ∃∀-formula `ψ(z_0, ..., z_m)` = `∃x_n...∃x_0 (ordering ∧ point_types ∧ interval_types)` decomposes by **locality of the interval predicate**. Each `βj` in the formula ranges over a segment between two *consecutive* elements in the combined ordering. Given the total ordering `z_{i_0} < ... < x_0 < ... < x_n < ... < z_{i_m}`, the formula factors as:

For each consecutive pair `(a, b)` of the combined ordering (where `a` and `b`
are either free variables `z_i` or witnesses `x_j`):
- The interval condition on `(a, b)` is local: it only mentions `a`, `b`, and
  points between them
- Point conditions at witnesses are also local

Therefore `ψ(z_0, ..., z_m)` is equivalent to: for each `i ∈ {0,...,m}`, the
conjunction `∧_i θ_i(z_i, z_{i+1})` where `θ_i` is an ∃∀-formula with exactly
the two free variables `z_i` and `z_{i+1}`, quantifying only the witnesses
`x_j` that fall in the interval `(z_i, z_{i+1})`.

**Key observation**: The witnesses are already sorted among the free variables.
When we fix a partition of the witnesses to intervals, the formula splits exactly
because:
1. The ordering constraint `x_n > ... > x_0` factors across intervals
2. Each `α_j(x_j)` (point type at `x_j`) depends only on `x_j`
3. Each `β_j` (interval type on `(x_{j-1}, x_j)`) depends only on local bounds
4. The segment types `β_0` ("before x_0") and `β_{n+1}` ("after x_n") factor
   to conditions on the first and last intervals relative to the free variables

**What it requires**: No machinery beyond what is already in `VecEAFormula.lean`.
The key ingredient is a **partition map** from witnesses to intervals:
given `m+1` free variables and `n+1` witnesses in total order, for each
witness `x_j`, there is a unique interval index `seg(j) ∈ {0,...,m}` such that
`z_{seg(j)} < x_j < z_{seg(j)+1}`.

### Finding 2: Prop 4.3 Structure

**Source**: Rabinovich 2014, p. 6, Proposition 4.3 + proof.

The proof is entirely by **structural induction on the MonadicFormula** (the
`φ` being translated):

- **Atomic case**: `P(x)`, `x < y`, `x = y` — already ∃∀-formulas with 0 or 2
  free variables (quantifier-free).
- **Disjunction case**: immediate by closure of V-∃∀ under disjunction (Lemma 3.4,
  done as `VBracketFormula.disj`).
- **Negation case**: By Lemma 3.2.2, the ∃∀-formula `φ` is equivalent to a
  conjunction `∧_i ψ_i(z_a, z_b)` with each `ψ_i` having at most 2 free
  variables. By Prop 4.2 (done in `NegationClosureProp42.lean`), `¬ψ_i` is
  equivalent to a V-∃∀-formula. The conjunction of V-∃∀-formulas is again
  V-∃∀ by Lemma 3.4 (`VVecEA2.conj_holds_vvecEA2`).
- **Existential case**: `∃x φ` where φ is V-∃∀: by Lemma 3.4, V-∃∀ is closed
  under existential quantification (`BracketFormula.existsBounded_right`).

The critical subtlety: Prop 4.3 works in the **expanded signature** (Definition
4.1), where every temporal formula is an atomic predicate. In the expanded
setting, quantifier-free formulas are already in ∃∀-form. The original Prop 4.2
(negation closure) applies to ∃∀-formulas with at most 2 free variables —
Lemma 3.2.2 ensures all ∃∀-formulas reduce to this case before applying Prop 4.2.

### Finding 3: How Prop 4.3 Resolves the P1/P2 Circularity

The circularity in the current Lean proof is:
- P2(k+1) backward direction needs the composition theorem
- Composition theorem not available

Prop 4.3 resolves this by **changing the induction structure**. Instead of
inducting on NF depth `k` with a simultaneous P1/P2, we:

1. Fix `k` = quantifier depth of the target `MonadicFormula`
2. By Prop 4.3, the formula is equivalent to a V-∃∀-formula
3. By Prop 3.5 (done in `VecEATranslation.lean`), V-∃∀ with 1 free variable
   translates to temporal

The backward direction of P2(k+1) is never needed because Prop 4.3 gives P1(k)
for ALL k simultaneously, directly from the structural induction — not by a
depth-induction that requires knowing P2 at depth k+1.

**Specifically**: `nf_characterizable_temporal_prior` at the `succ k ih` case
(currently sorry at KampPrior.lean:149) should use:
- `nf_characterizable_temporal_prior_classical` (NfCharFormula.lean:577)
  after filling `nf_2var_exist_formula_prior` (NfCharFormula.lean:550)
- `nf_2var_exist_formula_prior` should be filled using
  `p2_from_p1_succ` (FoToVecEA.lean:156) — which is **already sorry-free**

Wait — `p2_from_p1_succ` is already implemented and sorry-free (FoToVecEA.lean
lines 156-222). It gives P2(k) from P1(k+1), which is exactly the direction we
want for the NF characterization at depth k+1.

### Finding 4: The Actual Gap

Reading `nf_2var_exist_formula_prior` (NfCharFormula.lean:550-572):

This theorem has the same type as `p2_from_p1_succ` but is stated as requiring
the `char_k` characterizations at depth `k`, not `char_kp1` at depth `k+1`.

The sorry at NfCharFormula.lean:572 and the sorry at NegationClosure.lean:1371
are **the same gap** expressed at two different abstraction levels:

- NfCharFormula.lean:572: "P2(k) from P1(k)" — states ∃ temporal formula for
  2-var NF existence given depth-k characterizations
- NegationClosure.lean:1371: the same, instantiated inside the backward direction
  of the explicit `nf_exist_formula_nested` construction

The distinction: `p2_from_p1_succ` proves P2(k) from P1(k+1). The sorry at
NfCharFormula.lean needs P2(k) from P1(k). These are different — P2(k) from
P1(k) is what the current NF-depth induction needs. P2(k) from P1(k+1) is
what `p2_from_p1_succ` provides.

**The Resolution via Prop 4.3**: Prop 4.3 avoids needing P2(k) from P1(k)
entirely. Here is why:

In KampPrior.lean's `kamp_prior_expressive_completeness`, the proof:
1. Takes `psi : MonadicFormula sig 1` with `quantifier_depth = k`
2. Uses `nf_characterizable_temporal_prior k nf` for each depth-k NF `nf`

The sorry in `nf_characterizable_temporal_prior` at the `succ k ih` case needs:
for each depth-(k+1) NF `nf`, a temporal formula characterizing it. This
requires knowing temporal formulas for the depth-k 2-var NF existentials.

The key: `p2_from_p1_succ` gives depth-k 2-var NF existentials from depth-(k+1)
1-var characterizations. So the proof is:

```
nf_characterizable_temporal_prior (k+1) nf :=
  -- By IH, we have char_{k+1} formulas for all depth-(k+1) 1-var NFs
  -- (actually the IH gives depth-k, but we need to go one level up...)
```

This is exactly the same circularity: IH at `k` gives depth-k formulas; we
need depth-k 2-var existential formulas to build the depth-(k+1) 1-var formula.

**Conclusion**: The circularity is real and intrinsic to the NF-depth induction.
Prop 4.3 as stated in Rabinovich does NOT directly fix this — it is proved using
Prop 4.2 which is the negation closure, and Lemma 3.2.2 is the key to make
Prop 4.2 applicable in the negation case. But Prop 4.3 is about translating
arbitrary first-order formulas — it starts from a completely different angle
(structural induction on formula syntax) and doesn't directly help the NF-depth
induction in KampPrior.lean.

### Finding 5: Correct Statement of Path B

Path B works as follows (correcting the handoff description):

The handoff says "Prop 4.3 proves that every MonadicFormula has a V-EA
equivalent, by structural induction on the formula (NOT by induction on NF
depth). This gives P1(k) for all k simultaneously."

This is correct in spirit but the mechanism needs precision. What actually
happens:

**Step 1**: Implement `prop43_every_fo_is_vvecEA2`:
```lean
theorem prop43_every_fo_is_vvecEA2 {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (h_UZ : semantic_prior_UZ M atomMap)
    (h_SZ : semantic_prior_SZ M atomMap)
    (φ : MonadicFormula sig 1) :
    ∃ (v : VVecEA2), ∀ (t : M.carrier),
      eval M (fun _ => t) φ ↔ v.holds M atomMap t t
```

No — the 2-free-variable VVecEA2 is designed for interval `(z0, z1)`. For a
1-free-variable result, we use **Prop 3.5** (VecEATranslation.lean) to convert
a 1-free-variable V-∃∀-formula directly to a temporal formula.

**Correct Path B statement**: Prove `∀ (φ : MonadicFormula sig 1), ∃ A : Formula,
∀ M t, eval M (fun _ => t) φ ↔ temporal_truth M atomMap t A` by structural
induction on φ, using:
- Lemma 3.2.2 in the negation case to reduce n-var ∃∀ to 2-var
- Prop 4.2 (`neg_vecEA2`/`neg_vvecEA2`) for 2-var negation closure
- Prop 3.5 (`VecEA2.translateLeft_correct`) for the translation

This replaces the sorry in `nf_characterizable_temporal_prior` (KampPrior.lean:149)
by a completely different proof that doesn't use NF-depth induction at all.

---

## Recommended Approach

### Option B-Direct: Direct MonadicFormula Structural Induction

Instead of fixing the NF-depth induction, implement Prop 4.3 as a standalone
theorem and use it to fill `kamp_prior_expressive_completeness` directly,
bypassing `nf_characterizable_temporal_prior`.

**New theorem to prove**:

```lean
-- In new file: Theories/Bimodal/Metalogic/WeakCanonical/Kamp/Prop43.lean

/-- Prop 4.3: Every first-order monadic formula is equivalent (on Prior
    structures) to a disjunction of ∃∀-formulas (V-VecEA2 in arity-2 form).
    Proof by structural induction on MonadicFormula.
    For the 1-free-variable case, the result directly gives a temporal formula
    via VVecEA2.translateLeft_correct (Prop 3.5). -/
theorem prop43_fo_to_temporal
    {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (φ : MonadicFormula sig 1) :
    ∃ A : Formula,
      ∀ (M : OrderedMonadicStructure sig)
        (h_UZ : semantic_prior_UZ M atomMap)
        (h_SZ : semantic_prior_SZ M atomMap)
        (t : M.carrier),
        eval M (fun _ => t) φ ↔
        temporal_truth M atomMap t A
```

The proof proceeds by induction on the **number of ∃/∀ quantifiers** (not the
syntactic structure of φ), or equivalently on `φ.quantifier_depth`.

**Induction structure for Prop 4.3**:

For the base case (quantifier-free formulas): these are conjunctions/disjunctions
of atoms and order literals. Each atom `P(x)` is already temporal. Each `x < y`
is a 2-var formula expressible via bounded quantifiers → already a V-∃∀ formula.
By `VecEATranslation.lean`, V-∃∀ with 1 free variable translates to temporal.

For the inductive case (`∃x φ` where φ has n+1 free variables after substitution):
Use `BracketFormula.existsBounded_right` / `VVecEA2.conj_holds_vvecEA2` to lift
the V-∃∀ formula to one with an additional existential.

For the negation case: this is the hard step requiring Lemma 3.2.2.

### Lemma 3.2.2 Lean Type Signature

```lean
-- In new file: Theories/Bimodal/Metalogic/WeakCanonical/Kamp/Lemma322.lean

/-- Lemma 3.2.2: Every VecEAFormula with n > 2 free variables is equivalent
    to a conjunction of VecEA2 formulas (one per consecutive pair of free
    variables).

    Given a VecEAFormula with m free variables z_0 < ... < z_{m-1} and
    witnesses partitioned among them, the formula factors into m-1 independent
    VecEA2 formulas, one for each interval (z_i, z_{i+1}).

    The key data: a VecEAFormula with m free variables and n witnesses
    determines, for each consecutive pair (z_i, z_{i+1}):
    - A count n_i of witnesses between z_i and z_{i+1}
    - A BracketFormula n_i for the interval (z_i, z_{i+1})
    - Point predicates at z_i and z_{i+1}

    The conjunction of these 2-var formulas is equivalent to the original. -/
theorem lemma322_decompose
    {sig : MonadicSignature} {m n : Nat}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (vea : VecEAFormula m n)
    (env : Fin m → M.carrier) (h_mono : StrictMono env)
    (h_holds : vecEAFormula_holds M atomMap vea env) :
    ∀ (i : Fin (m - 1)),
      ∃ (n_i : Nat) (bf_i : BracketFormula n_i),
        bf_i.holds M atomMap (env ⟨i.val, by omega⟩) (env ⟨i.val + 1, by omega⟩)
```

and the converse direction:

```lean
theorem lemma322_reconstruct
    {sig : MonadicSignature} {m : Nat}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (env : Fin m → M.carrier) (h_mono : StrictMono env)
    (bracketFamilies : ∀ i : Fin (m - 1),
      Σ n_i, BracketFormula n_i)
    (h_brackets : ∀ i : Fin (m - 1),
      (bracketFamilies i).2.holds M atomMap
        (env ⟨i.val, by omega⟩) (env ⟨i.val + 1, by omega⟩)) :
    ∃ (n : Nat) (vea : VecEAFormula m n),
      vecEAFormula_holds M atomMap vea env
```

**However**, examining the codebase more carefully: `VecEAFormula` in
`VecEAFormula.lean` is defined syntactically with `freePos`, `witnessTypes`, and
`segmentTypes`, but there is **no semantic evaluation function**
`vecEAFormula_holds` for the general `VecEAFormula` type. Only `BracketFormula`
and `VecEA2` have semantic evaluation functions. The full `VecEAFormula` type
appears to be a skeleton — its `holds` predicate is not implemented.

This means Lemma 3.2.2, in its pure form (∃∀ formula with n > 2 free variables
decomposes), cannot be stated using the existing `VecEAFormula` type without
first adding a `vecEAFormula_holds` function.

### Practical Reformulation: Work Directly with NF Types

Rather than going through the abstract `VecEAFormula`, a more direct Lean
approach works with `NormalForm sig k n` — the existing NF type that is the
core data structure throughout this proof.

The key insight: Lemma 3.2.2 is needed ONLY to justify that in the negation case
of Prop 4.3, one can apply Prop 4.2. In the Lean codebase, the negation closure
(Prop 4.2) is stated for `VecEA2` (2-free-variable formulas). The relevant
observation is:

**For the NF-based proof**, the 2-var NF at depth k (type `NormalForm sig k 2`)
already represents a 2-free-variable ∃∀-formula. The negation closure for
`VVecEA2` (already proved in `NegationClosureProp42.lean`) handles exactly these.

The correct implementation is:

1. Implement `lemma322_NF_decompose`: An n-var NF (with n > 2) is semantically
   equivalent to a conjunction of 2-var formulas.
2. Use this inside `nf_2var_exist_formula_prior` to fill the sorry: the 2-var NF
   existential `∃ x, nf_eval_nf M k 2 (x,t) sub_nf` is a 2-var ∃∀-formula, so
   Prop 4.2 gives its temporal negation, and `p2_from_p1_succ` already gives
   the positive direction.

**Wait** — re-reading `p2_from_p1_succ` (FoToVecEA.lean:156), this function
already fills the sorry at NfCharFormula.lean:572 in the "wrong" direction:
`p2_from_p1_succ` proves P2(k) from P1(k+1), but the sorry needs P2(k) from
P1(k). These are different statements.

### Clarified Resolution Strategy

The actual sorry chain is:

1. `NegationClosure.lean:1371` — `nf_exist_formula_nested_backward` — needs
   backward direction of the deeply-encoded `nf_exist_formula_nested`
2. `NfCharFormula.lean:572` — `nf_2var_exist_formula_prior` — needs existence
   of temporal formula for 2-var NF existential given depth-k 1-var chars
3. `KampPrior.lean:149` — `nf_characterizable_temporal_prior` succ case —
   needs to construct depth-(k+1) char formula from depth-k IH

These three sorries form a chain:
- (3) → (2): filling (2) would fill (3) via `nf_characterizable_temporal_prior_classical`
- (2) is the core gap: P2(k) from P1(k)

**The Prop 4.3 / Path B strategy**: Fill sorry (2) by using:
- `p2_from_p1_succ` (P2(k) from P1(k+1))
- BUT we don't have P1(k+1) at the point where we need P2(k)

The genuine fix: restructure the induction so that P1(k+1) is established BEFORE
P2(k) is needed. This is the `master_induction` structure in `NegationClosure.lean`
which DOES have this structure (it proves P1(k+1) from P1(k)+P2(k) and P2(k+1)
is the problematic step).

**The True Insight**: `p2_from_p1_succ` CAN fill the sorry at NfCharFormula.lean:572
if we change the type signature of `nf_2var_exist_formula_prior` to take
`char_kp1` instead of `char_k`. This is the simplest concrete fix:

```lean
-- Replace sorry at NfCharFormula.lean:572 with:
exact p2_from_p1_succ atomMap h_surj k char_kp1 char_kp1_correct parent_atoms sub_nf
```

But `nf_2var_exist_formula_prior` currently takes `char_k` (depth-k). We need
it to take `char_kp1` (depth-(k+1)). The types don't match without additional
restructuring. This is precisely the P1/P2 circularity: `char_kp1` isn't available
when we need `p2_k` in the induction step.

The master_induction in NegationClosure.lean solves this by:
- Proving P1(k+1) from P1(k)+P2(k) — works, no sorry
- Proving P2(k+1) from P1(k)+P2(k) — requires the backward sorry

For Path B: the path is to prove P2(k+1) by using `p2_from_p1_succ` applied
to `char_kp1` (which is derived from `p1_kp1`). The `master_induction` already
does this at NegationClosure.lean:1448-1470 — it constructs `char_kp1` from
`p1_kp1` and uses `p2_from_p1_succ` implicitly... except it uses
`nf_exist_formula_nested` (the sorry-containing formula) instead.

**The crux**: `master_induction` at lines 1448-1470 should use `p2_from_p1_succ`
directly instead of `nf_exist_formula_nested_backward`. The `p2_from_p1_succ`
theorem IS the correct implementation of P2(k+1) — it derives P2(k) from
P1(k+1), which is what we have at the induction step.

The fix is:

At NegationClosure.lean:1448-1470, replace the construction using
`nf_exist_formula_nested` with a direct call to `p2_from_p1_succ`:

```lean
-- Current (with sorry):
have p2_kp1 : P2 atomMap (k + 1) := by
  intro parent_atoms sub_nf
  let char_kp1 := fun nf_1 => Classical.choose (p1_kp1 nf_1)
  refine ⟨nf_exist_formula_nested k char_kp1 parent_atoms sub_nf, ...⟩
  -- sorry at backward direction

-- Proposed fix:
have p2_kp1 : P2 atomMap (k + 1) := by
  intro parent_atoms sub_nf
  -- p1_kp1 provides char_{k+1} formulas for all depth-(k+1) 1-var NFs
  -- p2_from_p1_succ(k) takes char_{k+1} and gives P2(k)
  -- But we need P2(k+1), not P2(k) !
```

**We still need P2(k+1), not P2(k)**. `p2_from_p1_succ` provides:
`P2(k) from P1(k+1)` — i.e., temporal formula for `∃ x, nf_eval_nf M k 2 (x,t) sub_nf`
given `char_{k+1}`.

But P2(k+1) requires: temporal formula for `∃ x, nf_eval_nf M (k+1) 2 (x,t) sub_nf`
given `char_{k+1}`.

These are different: the k in the NF depth matters. `p2_from_p1_succ` solves
P2(k), not P2(k+1).

**The conclusion**: `p2_from_p1_succ` fills the sorry in `nf_2var_exist_formula_prior`
only if we instantiate it at `k' = k+1` taking `char_{k+2}` — but then we'd need
`char_{k+2}` which requires P2(k+1) again.

The genuine block is that proving `P2(k+1)` (temporal formula for depth-(k+1)
2-var NF existentials) requires knowledge of depth-(k+1) interval structure that
is NOT captured by depth-(k+1) 1-var NFs alone.

---

## Codebase Alignment

The existing types map to Rabinovich's paper as follows:

| Paper concept | Lean type | File |
|--------------|-----------|------|
| ∃∀-formula, 2 free vars | `VecEA2 n` | VecEAFormula.lean |
| V-∃∀ formula, 2 free vars | `VVecEA2` | VecEAFormula.lean |
| Bracket formula `[...](z0,z1)` | `BracketFormula n` | VecEAFormula.lean |
| ∃∀-formula, general | `VecEAFormula m n` | VecEAFormula.lean (no holds!) |
| Lemma 3.2.1 (conj) | `BracketFormula.conj_to_bracket_exists` | VecEAClosure.lean |
| Lemma 3.2.3 (∃-closure) | `BracketFormula.existsBounded_right` | VecEAClosure.lean |
| Lemma 3.4 (all closures) | various `*_holds_vvecEA2` theorems | VecEAClosure.lean |
| Prop 4.2 | `neg_vecEA2`, `neg_vvecEA2` | NegationClosureProp42.lean |
| Prop 3.5 | `VecEA2.translateLeft_correct` | VecEATranslation.lean |
| P2(k) from P1(k+1) | `p2_from_p1_succ` | FoToVecEA.lean |

**Missing**:
- `vecEAFormula_holds` for general n-var `VecEAFormula` (not implemented)
- Lemma 3.2.2 (n-var ∃∀ → conjunction of 2-var ∃∀) — not formalized
- Prop 4.3 full structural induction — not formalized
- Semantic evaluation for `VecEAFormula` with m > 2

---

## Gap Analysis

### Gap 1: Missing `vecEAFormula_holds` for General VecEAFormula (Critical)

`VecEAFormula.lean` defines the `VecEAFormula m n` type but provides NO semantic
evaluation function for it. Only `BracketFormula` (= 2 free variables, `m=2`)
has `holds`. This means Lemma 3.2.2 as stated in the paper cannot be formalized
using the existing type without adding:

```lean
def VecEAFormula.holds {sig : MonadicSignature} {m n : Nat}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (vea : VecEAFormula m n) (env : Fin m → M.carrier) : Prop
```

Estimated: ~30 lines.

### Gap 2: Lemma 3.2.2 Semantic Decomposition (Core New Lemma)

Assuming `vecEAFormula_holds` is added:

```lean
theorem lemma322 {sig : MonadicSignature} {m n : Nat}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (vea : VecEAFormula m n)
    (env : Fin m → M.carrier) (h_mono : StrictMono env) :
    vea.holds M atomMap env ↔
    ∀ (i : Fin (m - 1)),
      ∃ (n_i : Nat) (bf_i : BracketFormula n_i),
        bf_i.holds M atomMap (env ⟨i.val, by omega⟩) (env ⟨i.val + 1, by omega⟩)
```

This is nontrivial because the witness partition map (mapping witnesses to
intervals) needs to be made explicit, and the "only if" direction requires
showing that witnesses in different intervals are independent.

Estimated: ~150-200 lines for both directions.

### Gap 3: Prop 4.3 Structural Induction (Not Clearly Helpful)

As analyzed in Finding 5, Prop 4.3 as a structural induction on `MonadicFormula`
would bypass the NF-depth induction but has the same fundamental obstacle: in
the negation case of the structural induction, we need to negate V-∃∀-formulas
with n > 2 free variables, which requires the full Lemma 3.2.2.

However, even with Lemma 3.2.2 and Prop 4.3 fully proved, the sorry in
`nf_characterizable_temporal_prior` (KampPrior.lean:149) cannot be filled by
Prop 4.3 directly because the types are different: Prop 4.3 translates
`MonadicFormula sig 1` (the full formula), but
`nf_characterizable_temporal_prior` needs a temporal formula for a specific
`NormalForm sig k 1` (a semantic object, not a syntactic formula).

### Gap 4: The Core Sorry Remains (Fundamental)

The sorry at NegationClosure.lean:1371 cannot be filled by Lemma 3.2.2 +
Prop 4.3 without a major restructuring. The fundamental issue identified in the
handoff remains:

The backward direction of P2(k+1) requires showing that the formula
`nf_exist_formula_nested k char_kp1 parent_atoms sub_nf` is equivalent to
`∃ x, nf_eval_nf M (k+1) 2 (x,t) sub_nf`. The formula was designed to encode
the depth-(k+1) 2-var NF existential, but the encoding is insufficient for the
backward direction.

Neither Lemma 3.2.2 nor Prop 4.3 directly addresses the backward direction of
`nf_exist_formula_nested`. They are relevant to a DIFFERENT proof strategy that
bypasses `nf_exist_formula_nested` entirely.

---

## Revised Recommendation: Path B Requires Full Restructuring

Path B is viable but requires more than 400-600 lines as the handoff estimated.
It requires restructuring the entire proof to avoid `nf_exist_formula_nested`.

**The cleanest restructuring** (following Rabinovich's proof literally):

1. **Add `vecEAFormula_holds`** for general `VecEAFormula` (~30 lines)
2. **Prove Lemma 3.2.2** — n-var VecEA decomposes into 2-var conjuncts (~150 lines)
3. **Prove Prop 4.3** — structural induction on MonadicFormula (~100 lines)
4. **Connect to kamp_prior_expressive_completeness** by replacing the NF-depth
   induction with the structural induction (~100 lines)

The connection in Step 4 requires showing that for any `NormalForm sig k 1`,
the formula `nf_to_formula nf` (if it exists as a `MonadicFormula sig 1`) can be
translated via Prop 4.3 to a temporal formula. This requires:

```lean
-- Need to define or show existence of:
def nf_to_monadicFormula {sig : MonadicSignature} (k : Nat) :
    NormalForm sig k 1 → MonadicFormula sig 1
```

which encodes the NF as a first-order formula. The quantifier depth of this
formula is `k`, so Prop 4.3 applied to it uses induction up to depth `k`.

**Is `nf_to_monadicFormula` already defined?** Searching the codebase:
- `NormalForm sig k n` is defined in `WeakCanonical` infrastructure
- No explicit `nf_to_monadicFormula` is visible from grep results
- The connection between NF evaluation and MonadicFormula evaluation is
  established via `nf_characteristic` and `doets_lemma_1_1`

This additional step (encoding NF as MonadicFormula) adds ~100-150 lines.

**Total Path B estimate**: 480-580 lines, 3-5 days.

---

## Evidence / Page Citations

- p. 4, Lemma 3.2: The three-part lemma. Clause (2) is the key decomposition
  into at most 2 free variables.
- p. 4, Definition 3.3: V-∃∀-formula as disjunction of ∃∀-formulas.
- p. 5, Lemma 3.4: V-∃∀ is closed under disjunction, conjunction, ∃.
- p. 5, Prop 3.5: V-∃∀ with 1 free variable → TL(Until, Since) formula.
- p. 6, Prop 4.2: Negation of 2-free-var ∃∀ is equivalent to V-∃∀ formula
  (over Dedekind complete chains).
- p. 6, Prop 4.3 proof: Structural induction. Negation case: "If φ is an
  ∃∀-formula, then by Lemma 3.2(2) it is equivalent to a conjunction of ∃∀
  formulas with at most two free variables. Hence ¬φ is equivalent to a
  disjunction of ¬ψ_i where ψ_i are ∃∀-formulas with at most two free variables.
  By Proposition 4.2, ¬ψ_i is equivalent to a disjunction of ∃∀-formulas γ_i^j.
  Hence, ¬φ is equivalent to a disjunction ∨_i ∨_j γ_i^j of ∃∀-formulas."

---

## Estimated Effort

| Component | Lines | Hours |
|-----------|-------|-------|
| `vecEAFormula_holds` semantic evaluation | ~30 | 1 |
| Lemma 3.2.2 (decompose + reconstruct) | ~150-200 | 4-6 |
| `nf_to_monadicFormula` + eval_nf correspondence | ~100-150 | 3-5 |
| Prop 4.3 structural induction | ~100-150 | 3-5 |
| Connection to kamp_prior_expressive_completeness | ~100 | 2-3 |
| **Total** | **480-630** | **13-20 hours** |

---

## Confidence Level: Medium-High

The mathematical content is clear from the paper (p. 4-6). The Lean formalization
challenge is:
1. The `VecEAFormula` type exists but lacks semantic evaluation — must be added
2. Lemma 3.2.2 requires explicit partition map, finicky Fin arithmetic
3. The connection from Prop 4.3 to the NF-depth characterization requires
   `nf_to_monadicFormula` which may or may not exist

The strategy is sound. The main uncertainty is whether `nf_to_monadicFormula`
(or an equivalent) is already defined somewhere in the codebase — if so, effort
drops by ~150 lines. If not, it must be constructed, which is straightforward
but adds work.

**Confidence that Path B resolves the sorry**: HIGH (it bypasses the backward
direction of `nf_exist_formula_nested` entirely by replacing the NF-depth
induction with a structural induction on formulas).

**Confidence in effort estimate**: MEDIUM (Fin arithmetic in Lemma 3.2.2 is
the main source of uncertainty).
