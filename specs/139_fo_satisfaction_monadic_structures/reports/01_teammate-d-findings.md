# Teammate D (Horizons) — Task 139 Research Findings

**Role**: Strategic Direction
**Task**: 139 — FO satisfaction for monadic structures: close k-equivalence sorry chain
**Date**: 2026-05-14

---

## Key Findings

### 1. The Current State Is a Shallow Encoding with a Fundamental Semantic Gap

The code in `NEquivalence.lean` has a `KType` defined as `Finset (MonadicSentence sig)` and `k_type_of` as a sorry-bodied definition. This is not just a missing proof — it is a missing semantic layer. The entire Reynolds pipeline rests on `k_equiv` being *meaningful* (agreeing on truth of depth-≤k sentences), but currently `k_equiv M N` reduces to `sorry = sorry` which is trivially `True` via `rfl`. This means `chronicle_is_good`, `one_class`, and `finite_structures_good` all hold vacuously because the sorry in `k_type_of` makes `k_equiv` trivially reflexive.

The three sorries in `NEquivalence.lean` (`k_type_of`, `ktype_finite`, `k_equiv_monotone`) are not independent gaps: they are a **single coherent gap** — the absence of a Tarski semantics for `MonadicSentence`. All three close simultaneously once `eval`/`satisfies` is defined.

### 2. The Literature's Proof Structure Is Clear and Well-Paved

Reynolds 1992 (Section 8, Doets' Theorem 6/Theorem 9) and Doets 1987/1989 give the complete proof chain:

1. **Doets Lemma 1.1**: For any finite language, there are only finitely many first-order formulas of quantifier rank ≤ n up to logical equivalence. (This is the key to `ktype_finite`.)
2. **Doets Lemma 1.4**: Lexicographic sums of n-equivalent structures are n-equivalent. (This is `sum_preservation`.)
3. **Reynolds Theorem 9** (discrete Doets): If M is countable, discrete, no endpoints, and has no contemporaneous equivalence classes ending at gaps, then for all k, M has a k-equivalent structure with flow ℤ. (This is the core of `chronicle_is_good`.)

The Reynolds/Doets proof of Theorem 9 (the discrete analogue) is notably simpler than the real-time version. In the discrete case:
- There are no actual gaps (only phantom ones in dense orders)
- The "no boundary at successor" argument suffices
- The condensation ~M on a discrete order collapses to one class (the one-class theorem)
- The proof is essentially: discrete ⇒ very good ⇒ good

### 3. The `MonadicSentence` Type Needs Variable Binding

The current `MonadicSentence sig` type has:
- `.atom (p : sig.preds)` — no variable argument
- `.lt` — no variable positions
- `.forall (α : MonadicSentence sig)` — no De Bruijn index

This makes it impossible to write `eval : MonadicStructure sig → Assignment → MonadicSentence sig → Bool`. The fix requires choosing between:

**Option A (De Bruijn indices)**: Add variable positions to `atom` and `lt`, use bound variable index in `forall`:
```lean
inductive MonadicSentence (sig : MonadicSignature) : Type where
  | atom (p : sig.preds) (v : Nat) : MonadicSentence sig  -- P(v)
  | lt (v w : Nat) : MonadicSentence sig                   -- v < w
  | not (α : MonadicSentence sig) : MonadicSentence sig
  | and (α β : MonadicSentence sig) : MonadicSentence sig
  | exists (α : MonadicSentence sig) : MonadicSentence sig  -- ∃v.α (binds 0)
```

**Option B (Two-sorted naming)**: Use `Var` type and explicit substitution. More complex but matches textbook presentations.

**Recommendation**: Option A (De Bruijn) is standard for Lean 4 formalizations and avoids α-equivalence issues. The monadic case is particularly simple because there is only one sort of variable.

### 4. The `k_type_of` Definition Strategy Matters for Downstream

Two implementation strategies exist for `k_type_of`:

**Strategy 1 (Intensional)**: Define `k_type_of M k` as the Finset of all depth-≤k sentences true in M:
```lean
def k_type_of sig k M := 
  (sentences_of_depth_le sig k).filter (fun s => eval M s)
```
This requires enumerating `sentences_of_depth_le` as a `Finset` (possible since the language is finite).

**Strategy 2 (Quotient)**: Define k-equivalence directly as the Ehrenfeucht-Fraïssé game equivalence without going through sentence enumeration.

**Recommendation**: Strategy 1 is directly aligned with the Doets finiteness lemma. Strategy 2 (EF games) would provide a cleaner proof of `sum_preservation` but adds significant infrastructure. The project should use Strategy 1.

### 5. `ktype_finite` Follows Immediately from `sentences_of_depth_le`

If `sentences_of_depth_le sig k` is defined as a `Finset`, then `ktype_finite` follows because each k-type is a subset of this finite set, and there are 2^|S_k| such subsets. The `Fintype (Finset S)` instance from Mathlib handles the rest. This is not deep — it is entirely routine once the enumeration exists.

---

## Strategic Assessment

### The 3 Sorries in Task 139 Are a Single Dependency

The sorries form a chain: `eval` → `k_type_of` → `ktype_finite` + `k_equiv_monotone`. There is no clever shortcut: the Tarski semantics must be built. However, the monadic case is significantly simpler than general FO:
- One sort of variable
- Unary predicates only
- One binary relation symbol (<)
- Decidable evaluation for finite carriers

This is a well-understood formalization target. The main implementation challenge is the De Bruijn variable handling and the `Assignment` type.

### Task 139 Is the Semantic Foundation for Tasks 140-142

Without genuine `k_equiv` semantics, the proof in Transfer.lean remains vacuous. Task 140 requires `table_correctness` which uses `eval`/`satisfies` directly. Tasks 141 and 142 are independent of the FO satisfaction layer (they concern canonical model construction, not the discrete Reynolds pipeline).

**Critical path dependency**:
- Tasks 139 → 140 are strictly sequential (140 depends on 139's `eval`)
- Tasks 141 and 142 are independent of 139/140 (different sub-proof)
- Tasks 141 and 142 can proceed in parallel with 139/140

This suggests that if implementation is parallelized across agents, **139+140 should be one agent thread** and **141+142 should be another agent thread**.

### The Current Code Is Not Wrong — It Just Needs Filling In

The type signatures in `NEquivalence.lean` are mathematically correct. The `KEquivalenceFramework` typeclass has the right interface. The `one_class`, `no_boundary_at_successor`, and `chronicle_is_good` proofs are structurally sound. Task 139 is essentially: replace the sorry-based `k_type_of` with a genuine semantic definition, and all the downstream proofs will either compile as-is or need minor adjustments.

---

## Cross-Task Interactions

### Task 139 → Task 140

Task 140 requires `table_depth_bound` and the main `table_correctness` theorem:

```
M, t ⊨ φ  ⟺  monadic(M) ⊨ table(φ, t)
```

This uses `eval`/`satisfies` from task 139. Concretely, the `table` function in `Table.lean` maps temporal formulas to monadic sentences. The `table_correctness` proof goes by induction on formula structure:
- Atom case: `interp p t` iff `monadic(M).interp (atomMap p) t` (definitional)
- Until case: `∃ s > t, φ(s) ∧ ∀ u ∈ (t,s), ψ(u)` translates to the FO sentence `∃v (t < v ∧ P(v) ∧ ∀w (t < w ∧ w < v → Q(w)))`

**The key design question**: Should `table sig φ` produce a sentence with a free variable `t` (to be instantiated) or a closed sentence parametrized by `t : M.carrier`? The `MonadicSentence` type currently has no free variable construct. For `table_correctness`, the most natural form is:
```lean
theorem table_correctness (M : MonadicStructure sig) (t : M.carrier) (φ : Formula) :
    truth_at M t φ ↔ eval M (instantiate (table sig φ) t)
```

This means `table` produces a sentence with one free variable (the "now" variable), and `instantiate` substitutes a concrete domain element. This design choice should be made in Task 139 (when redesigning `MonadicSentence`) to ensure compatibility with Task 140's needs.

**Design recommendation for cross-task compatibility**: Add an explicit free variable position to `MonadicSentence` for the "current time point" in `table`, distinct from bound variables. This can be done as a top-level `MonadicFormula` (with free variable slot) vs `MonadicSentence` (closed), or by a `MonadicFormula.subst` operation. Making this design explicit now will avoid a breaking change in Task 140.

### Task 139 → Task 141/142

Task 141 (canonical truth lemma) and Task 142 (mixed-case countermodel) do not depend on the monadic FO layer. They are in `TruthLemma.lean` and `ChronicleToCountermodel.lean` respectively, which are entirely separate from the Reynolds pipeline. Task 139 has no effect on them.

### The `mkSigFrom` and `mkAtomMap` Stubs in Transfer.lean

`Transfer.lean` has placeholder implementations:
```lean
noncomputable def mkSigFrom (_φ : Formula) : MonadicSignature where
  preds := Fin 1  -- placeholder: single predicate
```

These stubs must be replaced in Task 140 with genuine implementations that extract the atoms of φ. The design of `table` in Task 139 must be compatible with the signature produced by `mkSigFrom`. This is another cross-task interface point.

---

## Creative Alternatives

### Alternative 1: Ehrenfeucht-Fraïssé Games as the Primary Abstraction

Instead of Tarski semantics, one could formalize k-equivalence directly via EF games:

```lean
inductive EFWin : Nat → MonadicStructure sig → MonadicStructure sig → Prop where
  | zero : (∀ p, M.interp p a ↔ N.interp p b) → EFWin 0 M N
  | succ : (∀ x : M.carrier, ∃ y : N.carrier, EFWin k (M.restrict x) (N.restrict y)) →
           (∀ y : N.carrier, ∃ x : M.carrier, EFWin k (M.restrict x) (N.restrict y)) →
           EFWin (k+1) M N
```

**Pros**: `sum_preservation` becomes a standard game-theory exercise. No need for `eval`. `ktype_finite` requires Lemma 1.1 from Doets (finite up-to-equivalence) which is a game argument.

**Cons**: Substantially more infrastructure (game types, strategy, winning condition). The connection to `table_correctness` (truth transfer) requires proving the correspondence between EF games and sentence truth — which is exactly what Doets Lemma 1.1 provides anyway. The EF approach delays (not avoids) the sentence-level work needed for Task 140.

**Assessment**: This approach is elegant for `sum_preservation` but creates a larger proof obligation overall. Not recommended unless the team wants the EF formalization for its own sake (e.g., for Task 125 algebraic representation).

### Alternative 2: Hintikka Formulas as k-types

Instead of computing k-types as sets of sentences, one can use **Hintikka formulas** (also called n-characteristics or Scott-rank formulas). For each structure M and depth k, there is a single sentence `char(M, k)` that:
- Is true in M
- Is true in N iff M ≡_k N

This is what Doets calls the "n-characteristic" (Doets 1987, Chapter 1, Section 1.6). In this approach:
```lean
def hintikka (sig : MonadicSignature) (k : Nat) (M : MonadicStructure sig) : MonadicSentence sig
```

Then `k_equiv M N` is simply `hintikka sig k M = hintikka sig k N` (structural equality of sentences). And `ktype_finite` follows from the finitude of depth-k formulas modulo equivalence (Doets 1.7.1).

**Pros**: Avoids computing `eval` on all depth-≤k sentences. `k_equiv_monotone` is immediate. The Lean definition is clean and termination is guaranteed by the depth parameter.

**Cons**: Computing `hintikka` requires enumerating successors of elements in M, which requires `Fintype M.carrier` or at least some decidability condition. For the chronicle (countable carrier), this is problematic — the chronicle is *not* finite. However, the Hintikka formula for an infinite structure refers to which depth-k formulas are realizable (the good-formula set), not to enumerating all elements.

**Assessment**: This is a potentially viable alternative for simplifying `k_type_of`. The key insight is that two structures are k-equivalent iff they satisfy the same "conjunction of all depth-k sentences" — i.e., the same Hintikka formula. This can be encoded syntactically without a full Tarski evaluation. However, it requires careful treatment of the "finitely many sentences modulo equivalence" argument. The Tarski semantics approach is more straightforward and is the approach the existing code anticipates.

### Alternative 3: Skip FO Satisfaction Entirely — Prove chronicle_is_good Directly

Could the one-class theorem be proved without ever defining `eval`? In the current code, `one_class` is proved from `no_boundary_at_successor` and `no_gaps_discrete`. Both currently use vacuous sorries (trivial via `k_type_of` sorry chain). Could a *genuine* proof of these lemmas be given without FO semantics?

**Yes, for the discrete case.** The key insight from Doets/Reynolds is:

In a discrete order (with SuccOrder), every finite subinterval `[a, b]` with `b - a` bounded is trivially good (it is finite, hence realized by some Z-interval). The contemporaneous equivalence relation in the discrete case simplifies dramatically: `a ~M b` iff `[a, b]` has a Z-interval k-equivalent. In a discrete order, every finite interval is isomorphic to `[0, n] ⊆ ℤ`, so every finite subinterval is already a Z-interval (hence k-equivalent to itself). This means:

```
In a discrete, countable, no-endpoint order, EVERY finite subinterval is good.
```

This is the key to `finite_structures_good`: a finite structure is good because it IS a Z-interval (or isomorphic to one). And since every subinterval of a discrete order is determined by its length (up to isomorphism for the FO content), the contemporaneous equivalence has only one class if every pair of points has a Z-interval-equivalent subinterval between them.

**However**, without a genuine notion of "k-equivalent", the claim "good" is vacuous. The current code already exploits this: `finite_structures_good` uses `trivial` because `k_equiv` is trivially true via the sorry chain. So the one-class theorem already "holds" in the current code — but vacuously.

The real content needed for Task 140 is the *truth transfer*: the chronicle and the Z-model agree on temporal truth. This requires genuine k-equivalence semantics. There is no way to avoid FO satisfaction if truth transfer is the goal.

**Assessment**: This alternative does not avoid the work — it just relocates it. Still need FO semantics for Task 140.

### Alternative 4: Reduce to Decidable Type Theory via `decide`

For a finite monadic structure, `satisfies` is decidable. Could one avoid defining `eval` on infinite structures entirely, and instead work with a decidable instance on finite quotients?

The chronicle is infinite, but k-equivalence only looks at depth-k sentences. The finite approximation argument (Doets Lemma 1.1) says there are finitely many depth-k sentences up to equivalence — so one could formalize the quotient type `{sentences of depth ≤ k} / (logical equivalence on finite structures)` as a `Fintype`, and use `Fintype.decidableEq` for the quotient.

**Assessment**: This is essentially reinventing `k_type_of` via a fintype-of-quotient construction. The overhead is similar to the direct Tarski approach. Not a simplification.

---

## Recommendations

### Primary Recommendation: Tarski Semantics with De Bruijn Variables

1. **Redesign `MonadicSentence`** with De Bruijn indices for bound variables and explicit free variable positions for the "current point" of evaluation. Specifically: use `0` as the bound variable introduced by `forall`/`exists`, and use `n+1` for the outer free variable. Define `Assignment := Nat → M.carrier`.

2. **Define `eval`** by structural recursion on the sentence, with the `forall` case ranging over `M.carrier` elements. For finite signatures (which we always have), this is computable but need not be decidable for infinite carriers.

3. **Define `k_type_of M k`** as `(sentences_of_depth_le sig k).filter (eval M)`. This requires `sentences_of_depth_le` to be a `Finset` — which it is, by the Doets finiteness argument.

4. **Prove `ktype_finite`** by `Fintype (Finset (sentences_of_depth_le sig k))`.

5. **Prove `k_equiv_monotone`** by showing depth-≤m formulas are a subset of depth-≤k formulas for m ≤ k.

6. **Design `table` and `MonadicSentence` jointly** so that `table φ` produces a sentence whose free variable represents the evaluation point. The type signature should be `table sig atomMap φ : MonadicFormula sig 1` (formula with one free variable), where `MonadicFormula sig n` is a sentence with n free variables (using De Bruijn levels).

### Secondary Recommendation: Design for Task 140 Compatibility Now

Task 140 needs `table_correctness`:
```
truth_at M Ω τ t φ ↔ eval (chronicleAsMonadicStructure M sig atomMap) (table sig atomMap φ) [t]
```

The `table` function and the `eval` function must be co-designed. Implement `table` in Task 139 even if `table_correctness` is deferred to Task 140. The stub in `Table.lean` should be replaced with a genuine (non-sorry) definition.

### Third Recommendation: Parallelize Tasks 141/142 with 139/140

Since 141 and 142 are independent of the FO satisfaction layer, they should be assigned to a separate implementation agent. This allows:
- Agent 1: Tasks 139 + 140 (FO semantics + truth transfer)
- Agent 2: Tasks 141 + 142 (canonical truth lemma + mixed case)

Completing both in parallel reduces the total time to sorry-free `bx_completeness`.

### Fourth Recommendation: Minimal FO Infrastructure, Maximum Reuse

Do not formalize a general FO logic framework. The project needs exactly:
- Monadic FO sentences with one sort, one binary relation, finitely many unary predicates
- Evaluation on ordered structures with finitely many elements (or countably many, for the chronicle)
- The specific properties: `ktype_finite`, `k_equiv_monotone`, `sum_preservation`

The Doets finiteness lemma (1.1) is the mathematical core. Everything else is engineering. Lean's `Fintype` infrastructure (decidable enumeration, `Finset.filter`, cardinality bounds) makes this largely mechanical once `eval` is defined.

---

## Confidence Level: HIGH

The literature is clear. Reynolds 1992 Section 10 (Theorem 9, the discrete analogue) and Doets 1989 provide the proof structure. The code in `NEquivalence.lean` has correct type signatures and a sound overall architecture. The gap is purely a matter of implementing `eval`/`satisfies` with proper variable binding, which is a standard Lean 4 formalization task with no deep mathematical obstacles. The estimated effort of 15-25 hours in the task description is realistic; the FO semantics foundation can likely be completed in 8-12 hours with a competent implementation agent, leaving 3-5 hours for proof adjustment in downstream files.

The main risk is the co-design of `MonadicSentence` and `table`: if `MonadicSentence` is redesigned in Task 139 without coordinating with Task 140's needs, Task 140 will require another redesign. The recommendation to implement `table` (non-sorry) in Task 139 mitigates this risk.

---

## Literature Proof Structure

**Source**: Reynolds 1992, Section 10 ("Using Contemporaneity on the Integers") + Doets 1987 Chapter 7 + Doets 1989 Sections 1-3

**Strategy**: Ehrenfeucht-Fraïssé game / n-equivalence condensation argument for the discrete case

### Step Map (Discrete / Integer Case)

1. Define monadic FO language: finite signature (unary predicates + binary <), sentences with quantifier depth
2. Define n-equivalence: M ≡_n N iff same monadic sentences of depth ≤ n hold
3. **Doets 1.1**: Finitely many sentences of depth ≤ n up to logical equivalence → finitely many n-equivalence classes (`ktype_finite`)
4. **Doets 1.4**: Ordered sums of n-equivalent structures are n-equivalent (`sum_preservation`)
5. Define "good" (k-equivalent to Z-interval) and "very good" (all subintervals are good)
6. **Reynolds Doets Thm 9, Lemma 14**: In discrete order, every finite subinterval [a,b] is isomorphic to a Z-interval → every finite subinterval is good
7. **One-class theorem**: In countable discrete order without endpoints, contemporaneous equivalence has exactly one class → the structure is very good
8. **Reynolds Doets Thm 9, Lemma 16**: Countable + very good → good → k-equivalent to Z-interval

### Dependencies

- Step 3 (ktype_finite) depends on Step 1 (monadic language definition with eval)
- Step 5 (good/very good) depends on Step 2 (n-equivalence with eval)
- Step 7 (one-class) depends on Step 6 (finite subintervals good) + Steps 5 + Step 4
- Step 8 (chronicle_is_good) depends on Step 7 (one-class) + Step 4 (sum preservation)
- Task 140's `table_correctness` depends on Step 1 (eval) + table definition

### Potential Formalization Challenges

- **Step 1 (MonadicSentence with variables)**: Need De Bruijn indices. Lean 4 supports this cleanly but requires care for `forall` evaluation.
- **Step 3 (ktype_finite)**: The mathematical argument (finitely many formulas up to equivalence → Fintype on quotient) needs to go through `Finset`. The key lemma is: for a finite signature, `{sentences of depth ≤ k}` is a `Finset`. This requires a termination argument on the inductive construction of sentences — not hard but requires `WF` reasoning.
- **Step 6 (finite subintervals)**: In the current code, `finite_structures_good` uses `trivial` (vacuous). The genuine proof requires showing a finite monadic structure is isomorphic to a Z-interval. For a discrete structure, the isomorphism is given by order-preserving bijection `{0,...,n} → carrier`. This requires `Fintype.equivFin`.
- **Step 8 (chronicle_is_good with genuine semantics)**: Once steps 1-7 are genuine, the current proof structure in `IntegerModel.lean` should still work, but the `sorry` stubs in `contemp_equiv_is_equiv.trans`, `no_gaps_discrete`, `very_good_implies_good`, and `chronicle_is_good` will need to be replaced with genuine game-theoretic or semantic arguments. The transitivity of `contemp_equiv` is the hardest part (requires a careful case analysis on `a < b < c`).
