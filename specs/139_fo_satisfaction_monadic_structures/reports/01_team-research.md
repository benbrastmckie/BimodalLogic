# Research Report: Task #139

**Task**: FO satisfaction for monadic structures: close k-equivalence sorry chain
**Date**: 2026-05-14
**Mode**: Team Research (4 teammates)

## Summary

The k-equivalence sorry chain in NEquivalence.lean stems from a single coherent gap: the absence of Tarski semantics for `MonadicSentence`. All 4 teammates converge on the same primary approach — redesign `MonadicSentence` as `MonadicFormula sig n` with De Bruijn variable binding via `Fin n`, following Reynolds 1994 Section 6 and Doets 1987/1989 exactly. The current type has three fatal design flaws: `.atom` lacks a variable argument, `.lt` is nullary (should be binary), and `.exists` is missing entirely. Additionally, `KType sig k := Finset (MonadicSentence sig)` is semantically wrong — it should be a truth-assignment function type over finitely many depth-bounded sentences. The task scope is substantially larger than described: implementing `eval` will break all downstream proofs in IntegerModel.lean and OrderedSum.lean that currently work through sorry-propagation, and `sum_preservation` (Doets Lemma 1.4) requires EF-game arguments that constitute a substantial independent subproject.

## Key Findings

### 1. MonadicSentence Redesign: MonadicFormula sig n with Fin n (All teammates agree)

The literature (Reynolds 1994 Section 6, Doets 1987 Chapter 1, Doets 1989 Lemma 1.1) is unambiguous: the monadic FO language uses standard one-sorted first-order logic with individual variables ranging over the carrier, unary predicates per `sig.preds`, and the binary order `<`. The natural Lean encoding is a depth-indexed inductive type:

```lean
inductive MonadicFormula (sig : MonadicSignature) : Nat → Type where
  | atom (p : sig.preds) (i : Fin n) : MonadicFormula sig n
  | lt (i j : Fin n) : MonadicFormula sig n
  | not : MonadicFormula sig n → MonadicFormula sig n
  | and : MonadicFormula sig n → MonadicFormula sig n → MonadicFormula sig n
  | forall : MonadicFormula sig (n+1) → MonadicFormula sig n
  | exists : MonadicFormula sig (n+1) → MonadicFormula sig n

abbrev MonadicSentence (sig : MonadicSignature) := MonadicFormula sig 0
```

Variable references use `Fin n` guaranteeing they are in-scope. Under the De Bruijn convention, `forall`/`exists` introduce variable 0, shifting outer variables up by 1. This matches Doets' Definition 1.6.1 exactly where the k-characteristic `[[a₀,...,a_{k-1}]]^n` has exactly k free variables.

**Current fatal flaws** (confirmed by all teammates):
- `.atom (p : sig.preds)` — no variable argument (should be `P(x)` not just `P`)
- `.lt` — nullary constructor for a binary relation `x < y` (semantically incoherent)
- No `.exists` constructor — required for standard translation of Until/Since (Reynolds: `C_{U(A,B)}(t) = ∃s > t(...)`)

### 2. KType Definition Must Change (Teammates A, B, C agree — critical)

The current definition `KType sig k := Finset (MonadicSentence sig)` is semantically wrong:

- **Teammate B**: `MonadicSentence sig` is infinite even at bounded depth (arbitrarily long conjunctions). `ktype_finite` as stated is trivially false — there are uncountably many `Finset`s of an infinite type.
- **Teammate C**: The actual claim requires "finitely many *realized* k-types," which requires the satisfaction relation to identify equivalences.
- **Teammate A**: The correct type is a truth-assignment function over a finite basis.

**Recommended fix**: Redefine KType as:
```lean
def KType (sig : MonadicSignature) (k : Nat) :=
  {s : MonadicFormula sig 0 // s.quantifier_depth ≤ k} → Bool
```

Then `k_type_of sig k M := fun ⟨s, _⟩ => decide (eval M Fin.elim0 s)` and `ktype_finite` follows immediately from `Fintype` of the function type (`Fintype.Pi.fintype`), provided `{s : MonadicFormula sig 0 // s.quantifier_depth ≤ k}` is a `Fintype`. This requires proving depth-bounded sentences form a finite type (Doets Lemma 1.1 enumeration by induction on k).

### 3. Eval Definition Is Straightforward (All teammates agree)

```lean
def eval {n : Nat} (M : MonadicStructure sig) [LinearOrder M.carrier]
    (env : Fin n → M.carrier) : MonadicFormula sig n → Prop
  | .atom p i => M.interp p (env i)
  | .lt i j   => env i < env j
  | .not α    => ¬ eval M env α
  | .and α β  => eval M env α ∧ eval M env β
  | .forall α => ∀ (x : M.carrier), eval M (Fin.cons x env) α
  | .exists α => ∃ (x : M.carrier), eval M (Fin.cons x env) α
```

For finite carriers with decidable predicates, `eval` is decidable by structural induction (using `Fintype.decidableForallFintype` and `Fintype.decidableExistsFintype`).

### 4. Sorry-Propagation Cascade (Teammates B, C, D confirm)

All downstream proofs in IntegerModel.lean and OrderedSum.lean currently "work" through sorry-propagation: `simp only [k_equiv, k_type_of]` reduces to `sorry = sorry` which Lean resolves trivially. Once `k_type_of` has a genuine definition, ALL of these proofs will break:

- `finite_structures_good` — uses `trivial` vacuously
- `contemp_equiv_is_equiv.trans` — same pattern
- `no_gaps_discrete` — same pattern
- `very_good_implies_good` — same pattern
- `chronicle_is_good` — same pattern
- `doets_lemma_1_4` in OrderedSum.lean — same pattern

These will need genuine mathematical arguments. This is NOT acknowledged in the task description.

### 5. sum_preservation Is the Hardest Sorry (Teammates A, B, C, D all flag)

`KEquivalenceFramework.sum_preservation` implements Doets Lemma 1.4: if component structures are k-equivalent, their ordered sums are k-equivalent. This requires either:
- (a) Direct EF-game formalization (substantial independent subproject)
- (b) Structural induction on depth k with careful ordered-sum quantifier reasoning

All teammates recommend deferring `sum_preservation` to a follow-up task or accepting it as the final sorry in the framework. The other framework fields (`equiv_is_equiv`, `equiv_monotone`, `finite_types`) close straightforwardly once eval is defined.

### 6. table Should Be Co-Designed in Task 139 (Teammates A, C, D recommend)

`Table.lean` has two critical sorries (`table` definition and `table_depth_bound`) that are equally blocking as the k-equivalence sorries. The `table` function maps temporal formulas to monadic FO formulas with one free variable:

```lean
def table (sig : MonadicSignature) (atomMap : ...) (φ : Formula) : MonadicFormula sig 1
```

This follows Reynolds 1994 Section 6: `C_{U(A,B)}(t) = ∃s > t(C_A(s) ∧ ∀u(t < u ∧ u < s → C_B(u)))` — a formula in one free variable `t`. Implementing `table` (definition only, not correctness proof) in Task 139 ensures the `MonadicFormula` type is designed compatibly with Task 140's needs.

### 7. Tasks 141/142 Are Fully Independent (All teammates confirm)

Tasks 141 (TruthLemma Until/Since) and 142 (ChronicleToCountermodel mixed case) operate in the canonical model construction layer, completely separate from the Reynolds pipeline. They can run in parallel with tasks 139/140.

## Synthesis

### Conflicts Resolved

| Conflict | Resolution | Reasoning |
|----------|------------|-----------|
| KType representation | Truth-assignment function `{depth ≤ k sentences} → Bool` | Teammates A, B, C all identify `Finset (MonadicSentence sig)` as wrong. Function type gives immediate `Fintype` via `Fintype.Pi.fintype`. |
| Whether to include `or` constructor | Omit (derive from `not`/`and`) | Teammate A suggested optional `or`. Keeping minimal constructors reduces cases in proofs. `or` can be defined as abbreviation. |
| table in Task 139 vs 140 | Implement `table` *definition* in 139, `table_correctness` *proof* in 140 | Teammates C and D flag that co-design avoids a breaking cross-task interface change. |
| sum_preservation scope | Defer to follow-up task | All teammates flag this as the hardest proof, requiring EF-game infrastructure. Closing it separately keeps Task 139 tractable. |
| Named vs De Bruijn variables | De Bruijn with `Fin n` | All teammates agree. `Fin n` is the standard Lean idiom, avoids alpha-equivalence issues, and matches Doets' explicit variable lists. |

### Gaps Identified

1. **The box modality translation**: The bimodal language includes `Formula.box` (S5 modality). Teammate C asks: does `table` translate box? The S5 modality ranges over Kripke-accessible worlds, not temporal points — this is NOT monadic FO over linear orders. The `table` translation should be purely temporal (G, H, U, S, atoms), with box handled separately by the canonical model's R-relation. This needs explicit scoping.

2. **Finiteness of depth-bounded formulas**: Proving `Fintype {s : MonadicFormula sig 0 // s.quantifier_depth ≤ k}` requires a careful induction on k. At depth 0, the only sentences over the monadic language are ⊤ and ⊥ (no ground atoms exist). At depth k+1, sentences are built from depth-k formulas with one free variable via ∀/∃. The count is finite but the proof requires well-founded recursion on the formula structure.

3. **Universe polymorphism**: `KEquivalenceFramework` is `Type 1` because `MonadicStructure sig` contains `carrier : Type`. This may cause universe-level conflicts with Mathlib's `Fintype`. Needs testing during implementation.

4. **mkSigFrom and mkAtomMap stubs**: Transfer.lean has placeholder implementations that extract the monadic signature from a formula. These must be replaced in Task 140 and must be compatible with Task 139's MonadicFormula design.

### Recommendations

1. **Redesign MonadicFormula/MonadicSentence** with `Fin n` De Bruijn variables, adding `exists` constructor and fixing `atom`/`lt` to take variable arguments.

2. **Redefine KType** as `{s : MonadicFormula sig 0 // s.quantifier_depth ≤ k} → Bool`. This makes `ktype_finite` immediate once the domain is `Fintype`.

3. **Implement eval** by structural recursion with `Fin.cons` for quantifier binding.

4. **Prove Doets Lemma 1.1 finiteness** by induction on k: `Fintype {s : MonadicFormula sig n // s.quantifier_depth ≤ k}` for each n and k.

5. **Implement table definition** (without correctness proof) in Task 139 as `MonadicFormula sig 1`.

6. **Defer sum_preservation** to a follow-up task focused on EF-game formalization.

7. **Acknowledge downstream breakage**: IntegerModel.lean and OrderedSum.lean proofs will break. Budget time for rewriting them with genuine semantic arguments, or leave them as sorry-propagation temporarily with explicit TODO markers.

8. **Parallelize 139/140 against 141/142**: These are independent proof threads that can run concurrently.

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | Primary approach: De Bruijn + Fin n, literature-guided | completed | high |
| B | Alternative approaches: Mathlib FO, Hintikka formulas, KType redesign | completed | high |
| C | Critic: scope underestimate, KType bug, sum_preservation gap | completed | high |
| D | Horizons: cross-task design, parallelization strategy | completed | high |

## References

- Doets 1987, *Completeness and Definability* (thesis), Chapter 1 (k-characteristics, Lemma 1.7.1)
- Doets 1989, "Monadic Π¹₁-Theories of Π¹₁-Properties", *Notre Dame J. Formal Logic* (Lemma 1.1, Lemma 1.4)
- Reynolds 1992, "An Axiomatization for Until and Since over the Reals without the IRR Rule"
- Reynolds 1994, "Axiomatising U and S over Integer Time", Section 6 (monadic language), Theorem 15
- Hodkinson & Reynolds 2006, "Temporal Logic" (Handbook of Modal Logic, Ch. 11)
- Blackburn, de Rijke & Venema 2002, *Modal Logic*, Section 7.2 (Since/Until)
- Obendrauf 2024, "Lean Formalization of Coalition Logic" (typeclass patterns for formalization)
