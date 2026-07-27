# Research Report: Semantic Validity of the Sep Axiom over Real Flow

- **Task**: `406 - Prove semantic validity of the Sep axiom over real flow (Reynolds 1992 section 7, lemma 10)`
- **Started**: `2026-07-27`
- **Completed**: `2026-07-27`
- **Effort**: research complete; implementation is transcription of verified tactic text
- **Dependencies**: task 405 (landed; supplies `exists_isGLB_of_lub`, the binder-set decision, and the sorry baseline)
- **Sources/Inputs**:
  - `/home/benjamin/Projects/Literature/sources/reynolds_1992/sec04_7-separability.md` (lemma 10 + the long-line caveat)
  - `/home/benjamin/Projects/Literature/sources/reynolds_1992/sec01_an-axiomatization-for-until-and-since-ov.md` (p.168 Sep statement, K±/U/S semantics table)
  - `/home/benjamin/Projects/BimodalLogic/FormalSystem/Metalogic/Soundness.lean` (:1435-1710)
  - `/home/benjamin/Projects/BimodalLogic/FormalSystem/Semantics/Validity.lean` (:195-306)
  - `/home/benjamin/Projects/BimodalLogic/FormalSystem/Semantics/Truth.lean` (:128-138)
  - `/home/benjamin/Projects/BimodalLogic/FormalSystem/Syntax/Formula.lean` (:118-193, :433-438, :619-625)
  - `specs/405_.../reports/01_prior-gap-axiom-validity.md` and its summary
- **Artifacts**: this report; verified proof text reproduced in section 7
- **Standards**: `.claude/rules/artifact-formats.md`, `.claude/rules/lean4.md`, `.claude/rules/no-task-references-in-deliverables.md`

---

## 1. Executive Summary

- **Both lemmas are proved, sorry-free, and machine-verified.** The complete proof text for
  `sep_valid` and `sep_swap_valid` — together with every supporting lemma — compiles against this
  tree's Lean/Mathlib pin with `EXIT=0` and `#print axioms` reporting only
  `[propext, Classical.choice, Quot.sound]`. Section 7 reproduces it verbatim. Implementation is
  transcription, not search.
- **The bimodal graft question is settled: the history-indexed layer does not interfere.** Sep's
  outermost operators are all temporal (`U`, `S`, `K⁺`, `K⁻`) and are evaluated at a single fixed
  history `τ`, so `{u : D | TruthAt M Omega τ u φ}` is an arbitrary subset of `D` and the whole
  statement reduces to a pure order-theoretic fact. `F`, `M`, `Omega`, `h_sc`, `τ`, `h_mem` are
  bound and never used — exactly as in the Prior gap lemmas.
- **The `ValidDedekindDense` binder set is exactly right, but for a reason that does NOT apply to
  the Prior lemmas: the `AddCommGroup` / `IsOrderedAddMonoid` binders are load-bearing.** Sep is
  FALSE on a general dense Dedekind-complete linear order (counterexample: the lexicographic square,
  section 5). It is true here only because a dense, Dedekind-complete, non-trivial *ordered abelian
  group* is forced to be Archimedean and hence separable. Any plan that tries to prove Sep from the
  order axioms alone, as the Prior lemmas were proved, will fail — and cannot be patched.
- **Reynolds' cardinality route is replaced by an equivalent nested-interval route, deliberately.**
  Reynolds' lemma 10 argues that a failure produces an uncountable pairwise-disjoint family of
  non-degenerate real intervals, via `S ≅ ℚ` and its uncountable gap order. The verified proof uses
  the same essential input (separability of the flow) but repackages it as a Baire-style nested
  interval construction over ℕ. This eliminates the order-type classification `S ≅ ℚ` and all
  cardinal arithmetic. Section 8 documents the deviation and why fidelity is preserved.
- **The DONE-WHEN sorry arithmetic in the task description is stale.** It was written against the
  task-391 exit baseline of 5. Task 405 has since landed and discharged 2. The current in-closure
  count is **3** (`Soundness.lean:1582`, `Soundness.lean:1605`, `WeakCanonical/Transfer.lean:1242`);
  the correct target is **1**. The "drops by exactly 2" clause still holds, measured from 3.
- **Two new Mathlib imports are required** — `Mathlib.Algebra.Order.Archimedean.Basic` and
  `Mathlib.Data.Set.Countable` — and nothing else. Verified by compiling the full proof against a
  file whose only other import is `FormalSystem.Metalogic.Soundness`. Total compile cost: ~4s.

---

## 2. Literature Proof Structure

**Source**: Reynolds, *An Axiomatization for Until and Since over the Reals without the IRR Rule*,
Studia Logica 51:165-193, 1992. Section 7 "Separability", Lemma 10. Statement of Sep at printed
p.168.

**Strategy**: refutation by cardinality — a failure of Sep manufactures an uncountable family of
pairwise disjoint non-degenerate intervals in ℝ, which contradicts separability.

### Verbatim axiom statement (p.168)

```
Sep:   K⁺p ∧ ¬K⁺(p ∧ U(p, ¬p)) → K⁺(K⁺p ∧ K⁻p)
```

### Verbatim abbreviations (p.168 table)

| Abbreviation | Definition        | Reading                            |
|---|---|---|
| `K⁺A`        | `¬U(⊤, ¬A)`       | A will be true arbitrarily soon    |
| `K⁻A`        | `¬S(⊤, ¬A)`       | A was true arbitrarily recently    |

`U(A,B)(t)` iff there is `s > t` with `A(s)` and `B(u)` for all `u ∈ (t,s)`. **The first argument
is the target, the second is the guard.** Reading `U(p,¬p)` the other way round inverts the
meaning of the antecedent's second conjunct and yields an immediately refutable statement — see
section 4, "the trap".

### Verbatim deferral (p.168)

> "Axiom Sep is based on Sep in [8] but is a neater version developed by Ian Hodkinson in [12]. It
> is associated with the *separability* of ℝ ... We investigate this axiom in more detail in section
> 7 and defer proving its validity in ℝ until lemma 10 there."

### Verbatim lemma 10 proof (section 7)

> Suppose that `R = (ℝ, <, h)` is a structure in which Sep does not hold at `t ∈ ℝ`. We can choose
> `s > t` and put `S = h(p) ∩ (t, s)` so that
>
> - `S` has neither a first nor a last point,
> - `S` is relatively dense — i.e. between any two points of `S` is another — and
> - for each `u ∈ (t, s)`, there is a (non-singleton) interval `I_u ⊆ (t, s)` disjoint from `S` but
>   ending at `u` on the left or right.
>
> By recursively choosing ω points from `S` we can without loss of generality suppose that `S` is
> countable and satisfies the three conditions above. As a suborder of ℝ, `S` is thus isomorphic to
> ℚ. Thus the order `(S, <)` has an uncountable order `(G, <)` of gaps. Define a map `r : G → ℝ` as
> follows: given a gap `γ` in `S`, let `X = {s ∈ S | s < γ}`. Let `r(γ) = sup(X)` ... Thus
> `{I_{r(γ)} | γ ∈ G}` is an uncountable set of pairwise disjoint non-singleton intervals of ℝ.
> Impossible.

### Source-to-tree encoding check

| Source object (p.168 / §7) | Tree encoding | Location | Verified |
|---|---|---|---|
| `K⁺A = ¬U(⊤,¬A)` | `Formula.kPlus φ = (Formula.untl Formula.top φ.neg).neg` | `Syntax/Formula.lean:180` | yes |
| `K⁻A = ¬S(⊤,¬A)` | `Formula.kMinus φ = (Formula.snce Formula.top φ.neg).neg` | `Syntax/Formula.lean:193` | yes |
| `U(A,B)` semantics | `∃ s, t < s ∧ TruthAt s A ∧ ∀ r ∈ (t,s), TruthAt r B` | `Semantics/Truth.lean:134` | yes, argument order matches |
| `S(A,B)` semantics | `∃ s, s < t ∧ TruthAt s A ∧ ∀ r ∈ (s,t), TruthAt r B` | `Semantics/Truth.lean:136` | yes |
| Sep as a whole | `sep_valid` statement | `Metalogic/Soundness.lean:1578-1581` | yes, transcribed verbatim |
| "structures with real flow" | `ValidDedekindDense` binder set | `Semantics/Validity.lean:255-262` | yes — but see section 5 |

### Step map (Reynolds' argument, decomposed)

Fix `P := {u | φ holds at u}` at the fixed history. Write

- `Rlim(u)` for "`u` is a right limit point of `P`" — this *is* `K⁺φ` at `u`;
- `Llim(u)` for "`u` is a left limit point of `P`" — this *is* `K⁻φ` at `u`;
- `Start(u)` for `u ∈ P ∧ U(φ,¬φ)(u)` — "`u ∈ P` has a P-successor separated from it by a
  φ-free interval".

1. Assume Sep fails at `t`. Extract three facts:
   (A) `K⁺φ(t)`: for every `v > t` there is `u ∈ (t,v)` with `u ∈ P`.
   (B) `¬K⁺(φ ∧ U(φ,¬φ))(t)`: there is `s₁ > t` with no `Start` point in `(t,s₁)`.
   (C) `¬K⁺(K⁺φ ∧ K⁻φ)(t)`: there is `s₂ > t` with no two-sided limit point of `P` in `(t,s₂)`.
2. Put `s := min s₁ s₂`, `S := P ∩ (t,s)`.
3. **`S` is relatively dense.** If `a < b` in `S` with `(a,b) ∩ P = ∅`, then `Start(a)` holds with
   witness `b`, contradicting (B). *This is the only use of (B), and it is exactly what (B) is for.*
4. **`S` has no first point.** A least element `a` of `S` would give `(t,a) ∩ P = ∅`, contradicting
   (A). (Reynolds also claims no last point; the verified proof does not need it — see section 8.)
5. **Every `u ∈ (t,s)` carries a `P`-free adjacent interval `I_u`.** By (C), `¬Rlim(u)` or
   `¬Llim(u)`; the former gives `(u,v)` with `(u,v) ∩ P = ∅`, clip to `(u, min v s)`; the latter
   gives `(max v t, u)`. Non-degeneracy of `I_u` is where `DenselyOrdered D` is consumed.
6. **Separation lemma.** If `a, b ∈ S` with `a < u < b`, then `I_u ⊆ (a,b)`: `a` and `b` lie in `P`,
   so neither can lie inside the `P`-free `I_u`, and `I_u` is adjacent to `u`.
7. *(Reynolds)* `S` countable + relatively dense + no endpoints ⟹ `S ≅ ℚ` ⟹ uncountably many gaps
   ⟹ `sup` of each gap's lower cut gives an uncountable `S`-separated set ⟹ the `I` intervals over
   that set are pairwise disjoint and uncountable ⟹ contradiction with separability of ℝ.
8. *(Verified route, replacing 7)* Let `Q` be a countable order-dense subset of the flow. By step 6
   plus density of `Q`, each `u ∈ (t,s)` picks a `q_u ∈ Q ∩ I_u` with `a < q_u < b` for every
   `a,b ∈ S` bracketing `u`. Enumerate `Q = {q_0, q_1, …}`. Build nested `[a_n, b_n]` with endpoints
   in `S`, `[a_{n+1},b_{n+1}] ⊂ (a_n,b_n)` and `q_n ∉ (a_{n+1},b_{n+1})` — possible because step 3
   supplies three points of `S` inside `(a_n,b_n)`, and `q_n` misses one of the two resulting
   sub-intervals. Take `x := sup a_n` (Dedekind completeness). Then `x ∈ (a_{n+1},b_{n+1})` for every
   `n`, so `q_x ∈ (a_{n+1},b_{n+1})` by step 6, so `q_x ≠ q_n` for every `n` — contradicting
   `q_x ∈ Q`.

### Dependencies

- Step 3 depends on (B); step 4 on (A); step 5 on (C) and `DenselyOrdered`.
- Step 6 depends on step 5 only.
- Step 8 depends on steps 3, 5, 6, the LUB hypothesis, and separability of the flow (section 5).
- Steps 1-6 are pure order theory; only step 8 needs the group structure, and only through
  separability.

### Formalization challenges (and how each was resolved)

| Step | Challenge | Resolution |
|---|---|---|
| 1 | `K⁺` is a doubly-negated `U`, so the antecedent unfolds to nested `¬¬`. | `and_of_not_imp_not` (already private at `Soundness.lean:106`) + `Classical.byContradiction`; identical to the task-405 idiom. |
| 7 | `S ≅ ℚ` needs Cantor's back-and-forth theorem and a cardinality argument on gaps. | Replaced by step 8; nothing about order types or cardinals appears in the verified proof. |
| 8 | Separability of the flow is not a hypothesis of `ValidDedekindDense`. | Derived: LUB ⟹ Archimedean ⟹ (with density) a countable order-dense subset. Section 6. |
| 8 | ℕ-indexed recursion with choice at each stage. | `choose` on a totalised step function, then `Nat.rec` on `D × D`. Verified. |
| dual | Sep's temporal dual is a genuinely separate semantic fact. | `sep_order_mirror` instantiates the core at `Dᵒᵈ` in 20 lines; no hand-mirrored duplicate. Section 7.4. |

---

## 3. Does the bimodal setting need an adaptation? (the flagged open question)

**No. The graft is trivial, and the reason is structural rather than lucky.**

`TruthAt` (`Semantics/Truth.lean:128-138`) recurses on the formula with `M`, `Omega`, `τ` fixed
except in the `Formula.box` case, which quantifies over `Omega`. The Sep schema

```
(K⁺φ ∧ ¬K⁺(φ ∧ U(φ,¬φ))) → K⁺(K⁺φ ∧ K⁻φ)
```

contains no `box` at the top level: every operator surrounding `φ` is `U`, `S`, `imp` or `bot`.
Consequently the whole statement, at a fixed `(M, Omega, τ)`, is a statement about the set

```
P := {u : D | TruthAt M Omega τ u φ}
```

and the linear order on `D`. `φ` may itself contain modal operators — that only affects *which*
subset `P` is, and the argument treats `P` as arbitrary. `ShiftClosed Omega` is never consulted;
neither is `τ ∈ Omega`.

This is confirmed mechanically: in the verified proof the binder line is

```lean
intro D _ _ _ _ _ h_lub F M Omega h_sc τ h_mem t h_ant
```

and `F`, `h_sc`, `h_mem` never appear again; `M`, `Omega`, `τ` appear only inside `TruthAt M Omega
τ _ φ`, i.e. only as the definition of `P`.

**Contrast with the Prior lemmas.** Task 405 reached the same conclusion for `prior_U_gap_valid` /
`prior_S_gap_valid` but with an additional corollary — those proofs consume *nothing* beyond
`LinearOrder` + `h_lub`, so they would also establish the stronger `ValidDedekind`. **That
corollary does not extend to Sep.** Sep genuinely needs `DenselyOrdered`, `AddCommGroup`,
`IsOrderedAddMonoid`, and `Nontrivial`. See section 5.

---

## 4. The trap, checked

Reynolds' `U(A,B)` puts the *target* first and the *guard* second. Under the opposite reading,
`U(p,¬p)(u)` would mean "`φ` holds on some right-neighbourhood interval of `u` terminating at a
`¬φ` point", and the antecedent's second conjunct would say something different and much weaker.

Concrete refutation of the mis-reading (over ℝ, so no exotic order is involved): take
`P = {1/n : n ≥ 1}` and `t = 0`. Then `K⁺p(0)` holds; under the mis-reading `U(p,¬p)` is false
everywhere (no interval lies inside `P`), so `¬K⁺(p ∧ U(p,¬p))(0)` holds; but no point of `(0,s)`
is a two-sided limit point of `P`, so the consequent fails. Sep would be refuted over ℝ. Under the
**correct** reading, `Start(1/(n+1))` holds with witness `1/n` for every `n`, these accumulate at
`0`, so `K⁺(p ∧ U(p,¬p))(0)` is true and the antecedent fails. No contradiction.

The tree's encoding at `Soundness.lean:1580` is `Formula.untl φ φ.neg` and `Truth.lean:134` puts
the first `untl` argument at the witness point `s`. **The tree matches Reynolds.** Do not "fix" it.

---

## 5. Is Sep true over `ValidDedekindDense`? (binder-set analysis — the key finding)

### 5.1 The order-only statement is FALSE

Consider `D = [0,1] ×lex [0,1]`, the lexicographic square. It is densely ordered and Dedekind
complete, and it is not an ordered group. Take

```
t = (0,1),    P = {(a,0) : 0 < a < 1}
```

- `K⁺p(t)` holds: any `s > t` is some `(a,y)` with `a > 0`, and `(a',0) ∈ ((0,1), (a,y))` for
  `0 < a' < a`.
- `Start(u)` holds nowhere: for `u = (a,0)` and any `v = (a',0)` above it, `(a'',0)` lies strictly
  between whenever `a < a'' < a'`. So `¬K⁺(p ∧ U(p,¬p))(t)` holds.
- The consequent fails everywhere: for `u = (a,y)`, the interval `(u, (a, y'))` with `y < y' < 1`
  contains no point of `P`, so `K⁺p(u)` is false at every `u`. Hence no two-sided limit point
  exists anywhere above `t`.

So Sep fails. (This counterexample is a hand-checked reconstruction, not machine-verified; it is not
needed for the proof, only to justify the design decision below. It is consistent with Reynolds'
own §7 remark that Sep holds in "any structure whose underlying flow of time only has open intervals
beginning with a copy of the reals" — a condition the lexicographic square violates.)

### 5.2 The group binders rescue it

`ValidDedekindDense` (`Semantics/Validity.lean:255-262`) binds
`[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [DenselyOrdered D] [Nontrivial D]` plus the
LUB hypothesis. That is enough to force separability:

1. **LUB ⟹ Archimedean.** If `{n • y}` were bounded above by `x`, its supremum `s` would satisfy
   `s - y < s`, so some `n • y > s - y`, so `(n+1) • y > s`. Contradiction.
2. **Density ⟹ approximate halving.** For `a > 0` pick `c ∈ (0,a)`; then `b := min c (a-c)` is
   positive and `b + b ≤ c + (a-c) = a`. (No LUB needed, and no exact division needed.)
3. **A null sequence.** Iterate (2) from any `a > 0` to get `d : ℕ → D` with `d(n+1) + d(n+1) ≤ d n`,
   hence `2^n • d n ≤ a`. Archimedean then gives, for any `e > 0`, some `n` with `d n ≤ e`.
4. **A countable order-dense set.** `Q := {k • d n | k : ℤ, n : ℕ}` is countable (image of `ℤ × ℕ`).
   Given `x < y`, insert `y'` by density, take `n` with `d n ≤ y' - x`, and
   `existsUnique_zsmul_near_of_pos` puts some `(k+1) • d n` in `(x, y']  ⊆ (x,y)`.

This is Hölder's theorem in miniature — the binder set in fact pins `D` down to ℝ up to ordered-group
isomorphism — but the proof does not need the classification, only the countable dense subset.

### 5.3 Decision

**Keep `ValidDedekindDense`. Do not weaken to `ValidDedekind`, and do not attempt an order-only
proof.** The binder set is not merely adequate; every one of its algebraic binders is consumed.
Removing `DenselyOrdered` breaks steps 5 and (2) above; removing `AddCommGroup` /
`IsOrderedAddMonoid` breaks (1)-(4) entirely and the statement becomes false (5.1); removing
`Nontrivial` leaves no `a > 0` to start (3).

This is the one place where the task-405 report's "these proofs use no algebraic binder" observation
must **not** be carried over. A planner or implementer who assumes Sep behaves like the Prior
lemmas will burn dispatches on an unprovable goal.

---

## 6. Mathlib findings

All entries verified by compilation against this tree's pin (`lake env lean`, EXIT=0).

| Need | Lemma / API | Signature (as used) | Verified |
|---|---|---|---|
| Archimedean from LUB | none in Mathlib for ordered *groups* — `ConditionallyCompleteLinearOrderedField.to_archimedean` covers fields only | must be proved locally (`arch_of_lub`, 13 lines) | yes |
| integer part w.r.t. a positive element | `existsUnique_zsmul_near_of_pos` | `0 < a → ∀ g, ∃! k : ℤ, k • a ≤ g ∧ g < (k+1) • a` | yes |
| nsmul distributes over `+` | `nsmul_add` | `n • (a + b) = n • a + n • b` | yes |
| nsmul cancellation | `le_of_nsmul_le_nsmul_right` | `n ≠ 0 → n • a ≤ n • b → a ≤ b` | yes |
| nsmul monotone in the scalar | `nsmul_le_nsmul_left` | `0 ≤ a → m ≤ n → m • a ≤ n • a` | yes |
| nsmul monotone in the element | `nsmul_le_nsmul_right` | `a ≤ b → ∀ n, n • a ≤ n • b` | yes |
| `2^n` unboundedness | `Nat.lt_two_pow_self` | `n < 2 ^ n` | yes |
| countable set enumeration | `Set.Countable.exists_eq_range` | `s.Countable → s.Nonempty → ∃ f : ℕ → α, s = Set.range f` | yes |
| countability of a range | `Set.countable_range` | `(f : ι → α) → [Countable ι] → (Set.range f).Countable` | yes |
| sup approximation | `IsLUB.exists_between` | `IsLUB s a → b < a → ∃ c ∈ s, b < c ∧ c ≤ a` | yes |
| GLB from LUB | `exists_isGLB_of_lub` (already local, `Soundness.lean:1457`) | reused unchanged | yes |
| dual instances | `DenselyOrdered Dᵒᵈ`, `LinearOrder Dᵒᵈ` | `inferInstance` succeeds | yes |
| dual coercion | `OrderDual.toDual` / `OrderDual.ofDual` used explicitly | see 7.4 | yes |

**Negative findings worth recording.**

- There is no usable Mathlib route from `Archimedean` + `LinearOrderedAddCommGroup` to a countable
  order-dense subset. `SecondCountableTopology.of_separableSpace_orderTopology` exists but needs a
  `TopologicalSpace` + `OrderTopology` instance on `D`, which this tree does not carry. Introducing
  `Preorder.topology` locally would add instance-unification risk to every downstream
  `[LinearOrder D]` lemma, for no gain. **Rejected.**
- Hölder's theorem (Archimedean ordered group embeds in ℝ) is not needed and was not used. Even if
  available, transporting `TaskFrame D` / `WorldHistory` / `Omega` along an isomorphism `D ≃ ℝ`
  would be far more invasive than deriving the countable dense subset directly. **Rejected.**
- `lean_run_code` (MCP) reported `success: true, diagnostics: []` for `example : 1 = 2 := by rfl`.
  **It is silently swallowing diagnostics in this environment; do not trust it.** All verification in
  this report was done with `lake env lean` on scratch files. This is worth propagating to other Lean
  work in this repo.

---

## 7. Verified implementation

Verified as a single file whose only imports are `FormalSystem.Metalogic.Soundness`,
`Mathlib.Algebra.Order.Archimedean.Basic`, `Mathlib.Data.Set.Countable`. EXIT=0, no warnings,
~4s elapsed. `#print axioms` on `sep_valid`, `sep_swap_valid` and `exists_countable_order_dense`
each returns `[propext, Classical.choice, Quot.sound]`.

### 7.1 Placement

**Recommended**: a new file `FormalSystem/Metalogic/SoundnessLemmas/Separability.lean` holding
sections 7.2 and 7.3 (~200 lines of pure order/group theory with no `Formula` or `TruthAt`
dependency), imported by `Soundness.lean`; only section 7.4 (~65 lines) lands in `Soundness.lean`,
replacing the two `sorry` bodies.

Rationale: `SoundnessLemmas/` already exists for exactly this purpose (`Core.lean`,
`DenseValidity.lean`, `FrameClassVariants.lean`); the material is domain-general; and it keeps
`Soundness.lean` from growing from 1836 to ~2050 lines with content that is not about soundness.
The `lean_lib FormalSystem` target uses `roots := #[`FormalSystem]`, so a new module is picked up
automatically once `Soundness.lean` imports it.

**Alternative (also verified)**: inline everything in `Soundness.lean` immediately before
`sep_valid`, with the two Mathlib imports added at the top of `Soundness.lean`. Task 405 chose
inlining for its ~50-line addition. Either works; the import-graph change is identical in both
cases because the two new Mathlib imports are required regardless.

**Do not touch** `FormalSystem/Metalogic/WeakCanonical/Kamp/` — concurrent work.

### 7.2 Phase A — separability of the flow

```lean
private theorem exists_half_le {D : Type} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    [DenselyOrdered D] (a : D) (ha : 0 < a) : ∃ b : D, 0 < b ∧ b + b ≤ a := by
  obtain ⟨c, hc0, hca⟩ := exists_between ha
  refine ⟨min c (a - c), lt_min hc0 (by simpa using hca), ?_⟩
  calc min c (a - c) + min c (a - c) ≤ c + (a - c) :=
        add_le_add (min_le_left _ _) (min_le_right _ _)
    _ = a := by abel

private theorem arch_of_lub {D : Type} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    (h_lub : ∀ s : Set D, s.Nonempty → BddAbove s → ∃ x, IsLUB s x) : Archimedean D := by
  refine ⟨fun x y hy => ?_⟩
  by_contra hcon
  simp only [not_exists, not_le] at hcon
  have hbdd : BddAbove (Set.range (fun n : ℕ => n • y)) := by
    refine ⟨x, ?_⟩; rintro _ ⟨n, rfl⟩; exact (hcon n).le
  obtain ⟨s, hs⟩ := h_lub (Set.range (fun n : ℕ => n • y))
    ⟨(0:ℕ) • y, Set.mem_range_self 0⟩ hbdd
  have h1 : s - y < s := by simpa using sub_lt_self s hy
  obtain ⟨_, ⟨n, rfl⟩, hn, -⟩ := hs.exists_between h1
  have hle : (n+1) • y ≤ s := hs.1 ⟨n+1, rfl⟩
  have h3 : s - y < n • y := hn
  have h2 : s < (n+1) • y := by rw [succ_nsmul]; exact sub_lt_iff_lt_add.mp h3
  exact absurd hle (not_le_of_gt h2)

private theorem exists_null_seq {D : Type} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    [DenselyOrdered D] [Archimedean D] [Nontrivial D] :
    ∃ d : ℕ → D, (∀ n, 0 < d n) ∧ ∀ e : D, 0 < e → ∃ n, d n ≤ e := by
  obtain ⟨a, ha⟩ : ∃ a : D, 0 < a := by
    obtain ⟨x, hx⟩ := exists_ne (0 : D)
    rcases lt_or_gt_of_ne hx with h | h
    · exact ⟨-x, by simpa using h⟩
    · exact ⟨x, h⟩
  have key : ∀ a : D, ∃ b : D, 0 < a → (0 < b ∧ b + b ≤ a) := by
    intro a
    by_cases h : 0 < a
    · obtain ⟨b, hb1, hb2⟩ := exists_half_le a h
      exact ⟨b, fun _ => ⟨hb1, hb2⟩⟩
    · exact ⟨a, fun h' => absurd h' h⟩
  choose g hg using key
  set d : ℕ → D := fun n => Nat.rec a (fun _ x => g x) n with hd
  have hpos : ∀ n, 0 < d n := by
    intro n; induction n with
    | zero => exact ha
    | succ n ih => exact (hg _ ih).1
  have hsm : ∀ n, (2^n : ℕ) • d n ≤ a := by
    intro n; induction n with
    | zero =>
      have hz : d 0 = a := rfl
      simp [one_nsmul, hz]
    | succ n ih =>
      have h2 : d (n+1) + d (n+1) ≤ d n := (hg _ (hpos n)).2
      calc (2^(n+1) : ℕ) • d (n+1) = (2^n : ℕ) • (d (n+1) + d (n+1)) := by
            rw [nsmul_add, ← add_nsmul]; congr 1; ring
        _ ≤ (2^n : ℕ) • d n := nsmul_le_nsmul_right h2 _
        _ ≤ a := ih
  refine ⟨d, hpos, ?_⟩
  intro e he
  obtain ⟨m, hm⟩ := Archimedean.arch a he
  obtain ⟨n, hn⟩ : ∃ n : ℕ, m ≤ 2^n := ⟨m, (Nat.lt_two_pow_self).le⟩
  refine ⟨n, ?_⟩
  have h1 : (2^n : ℕ) • d n ≤ (2^n : ℕ) • e :=
    le_trans (hsm n) (le_trans hm (nsmul_le_nsmul_left he.le hn))
  exact le_of_nsmul_le_nsmul_right (pow_ne_zero n (by norm_num)) h1

theorem exists_countable_order_dense {D : Type} [AddCommGroup D] [LinearOrder D]
    [IsOrderedAddMonoid D] [DenselyOrdered D] [Nontrivial D]
    (h_lub : ∀ s : Set D, s.Nonempty → BddAbove s → ∃ x, IsLUB s x) :
    ∃ Q : Set D, Q.Countable ∧ ∀ x y : D, x < y → ∃ q ∈ Q, x < q ∧ q < y := by
  have harch : Archimedean D := arch_of_lub h_lub
  obtain ⟨d, hdpos, hdsmall⟩ := exists_null_seq (D := D)
  refine ⟨Set.range (fun p : ℤ × ℕ => p.1 • d p.2), Set.countable_range _, ?_⟩
  intro x y hxy
  obtain ⟨y', hxy', hy'y⟩ := exists_between hxy
  obtain ⟨n, hn⟩ := hdsmall (y' - x) (by simpa using hxy')
  obtain ⟨k, ⟨hk1, hk2⟩, -⟩ := existsUnique_zsmul_near_of_pos (hdpos n) x
  refine ⟨(k+1) • d n, Set.mem_range.mpr ⟨(k+1, n), rfl⟩, hk2, ?_⟩
  have h : (k+1) • d n = k • d n + d n := by rw [add_zsmul, one_zsmul]
  rw [h]
  calc k • d n + d n ≤ x + (y' - x) := add_le_add hk1 hn
    _ = y' := by abel
    _ < y := hy'y
```

### 7.3 Phase B — the order-theoretic core

`nested_core` is step 8 of the step map; `sep_order` is steps 1-6 plus the call into `nested_core`;
`sep_order_mirror` is the past-directed instance at `Dᵒᵈ`.

```lean
theorem nested_core {D : Type} [LinearOrder D]
    (h_lub : ∀ X : Set D, X.Nonempty → BddAbove X → ∃ x, IsLUB X x)
    (Q : Set D) (hQc : Q.Countable) (S : Set D) (t s : D)
    (hSsub : ∀ x ∈ S, t < x ∧ x < s)
    (hSdense : ∀ a ∈ S, ∀ b ∈ S, a < b → ∃ c ∈ S, a < c ∧ c < b)
    (hF : ∀ u, t < u → u < s → ∃ q ∈ Q, ∀ a ∈ S, ∀ b ∈ S, a < u → u < b → a < q ∧ q < b)
    (a0 b0 : D) (ha0 : a0 ∈ S) (hb0 : b0 ∈ S) (hab : a0 < b0) : False := by
  have hQne : Q.Nonempty := by
    obtain ⟨c, hc, hac, hcb⟩ := hSdense a0 ha0 b0 hb0 hab
    obtain ⟨q, hq, -⟩ := hF c (hSsub c hc).1 (hSsub c hc).2
    exact ⟨q, hq⟩
  obtain ⟨qf, hqf⟩ := hQc.exists_eq_range hQne
  have step : ∀ (n : ℕ) (p : D × D), ∃ p' : D × D,
      (p.1 ∈ S ∧ p.2 ∈ S ∧ p.1 < p.2) →
      (p'.1 ∈ S ∧ p'.2 ∈ S ∧ p.1 < p'.1 ∧ p'.1 < p'.2 ∧ p'.2 < p.2 ∧
        (qf n ≤ p'.1 ∨ p'.2 ≤ qf n)) := by
    intro n p
    by_cases h : p.1 ∈ S ∧ p.2 ∈ S ∧ p.1 < p.2
    · obtain ⟨h1, h2, h3⟩ := h
      obtain ⟨c2, hc2, hac2, hc2b⟩ := hSdense _ h1 _ h2 h3
      obtain ⟨c1, hc1, hac1, hc1c2⟩ := hSdense _ h1 _ hc2 hac2
      obtain ⟨c3, hc3, hc2c3, hc3b⟩ := hSdense _ hc2 _ h2 hc2b
      rcases le_or_gt (qf n) c2 with hq | hq
      · exact ⟨(c2, c3), fun _ => ⟨hc2, hc3, hac2, hc2c3, hc3b, Or.inl hq⟩⟩
      · exact ⟨(c1, c2), fun _ => ⟨hc1, hc2, hac1, hc1c2, hc2c3.trans hc3b, Or.inr hq.le⟩⟩
    · exact ⟨p, fun h' => absurd h' h⟩
  choose G hG using step
  set seq : ℕ → D × D := fun n => Nat.rec (a0, b0) (fun n p => G n p) n with hseq
  have hinv : ∀ n, (seq n).1 ∈ S ∧ (seq n).2 ∈ S ∧ (seq n).1 < (seq n).2 := by
    intro n; induction n with
    | zero => exact ⟨ha0, hb0, hab⟩
    | succ n ih =>
      obtain ⟨u1, u2, _, u4, _, _⟩ := hG n (seq n) ih
      exact ⟨u1, u2, u4⟩
  have hstep : ∀ n, (seq n).1 < (seq (n+1)).1 ∧ (seq (n+1)).2 < (seq n).2 ∧
      (qf n ≤ (seq (n+1)).1 ∨ (seq (n+1)).2 ≤ qf n) := by
    intro n
    obtain ⟨_, _, h3, _, h5, h6⟩ := hG n (seq n) (hinv n)
    exact ⟨h3, h5, h6⟩
  have hmonoA : ∀ m n : ℕ, m ≤ n → (seq m).1 ≤ (seq n).1 := by
    intro m n hmn
    induction n with
    | zero => simp_all
    | succ n ih =>
      rcases Nat.lt_or_ge m (n+1) with h | h
      · exact le_trans (ih (Nat.lt_succ_iff.mp h)) (hstep n).1.le
      · have hm : m = n+1 := le_antisymm hmn h
        subst hm; exact le_refl _
  have hmonoB : ∀ m n : ℕ, m ≤ n → (seq n).2 ≤ (seq m).2 := by
    intro m n hmn
    induction n with
    | zero => simp_all
    | succ n ih =>
      rcases Nat.lt_or_ge m (n+1) with h | h
      · exact le_trans (hstep n).2.1.le (ih (Nat.lt_succ_iff.mp h))
      · have hm : m = n+1 := le_antisymm hmn h
        subst hm; exact le_refl _
  have hbdd : BddAbove (Set.range (fun n : ℕ => (seq n).1)) := by
    refine ⟨b0, ?_⟩
    rintro _ ⟨m, rfl⟩
    exact le_of_lt (lt_of_lt_of_le (hinv m).2.2 (hmonoB 0 m (Nat.zero_le m)))
  obtain ⟨x, hx⟩ := h_lub _ ⟨(seq 0).1, Set.mem_range_self 0⟩ hbdd
  have hlt : ∀ n, (seq n).1 < x := fun n =>
    lt_of_lt_of_le (hstep n).1 (hx.1 (Set.mem_range_self (n+1)))
  have hub : ∀ n, x ≤ (seq n).2 := by
    intro n
    refine hx.2 ?_
    rintro _ ⟨m, rfl⟩
    rcases le_or_gt m n with h | h
    · exact le_of_lt (lt_of_le_of_lt (hmonoA m n h) (hinv n).2.2)
    · exact le_trans (hinv m).2.2.le (hmonoB n m h.le)
  have hgt : ∀ n, x < (seq n).2 := fun n => lt_of_le_of_lt (hub (n+1)) (hstep n).2.1
  have htx : t < x := lt_of_lt_of_le (hSsub a0 ha0).1 (hlt 0).le
  have hxs : x < s := lt_trans (hgt 0) (hSsub b0 hb0).2
  obtain ⟨q, hqQ, hqprop⟩ := hF x htx hxs
  obtain ⟨n, hn⟩ : ∃ n, qf n = q := by
    rw [hqf] at hqQ; obtain ⟨n, hn⟩ := hqQ; exact ⟨n, hn⟩
  obtain ⟨hq1, hq2⟩ := hqprop (seq (n+1)).1 (hinv (n+1)).1 (seq (n+1)).2 (hinv (n+1)).2.1
    (hlt (n+1)) (hgt (n+1))
  rcases (hstep n).2.2 with h | h
  · exact absurd (hn ▸ h : q ≤ (seq (n+1)).1) (not_le_of_gt hq1)
  · exact absurd (hn ▸ h : (seq (n+1)).2 ≤ q) (not_le_of_gt hq2)

theorem sep_order {D : Type} [LinearOrder D] [DenselyOrdered D]
    (h_lub : ∀ X : Set D, X.Nonempty → BddAbove X → ∃ x, IsLUB X x)
    (Q : Set D) (hQc : Q.Countable) (hQd : ∀ x y : D, x < y → ∃ q ∈ Q, x < q ∧ q < y)
    (P : Set D) (t s₁ s₂ : D) (hs₁ : t < s₁) (hs₂ : t < s₂)
    (hK : ∀ v, t < v → ∃ u, t < u ∧ u < v ∧ u ∈ P)
    (hNoStart : ∀ u, t < u → u < s₁ → u ∈ P →
        ¬ ∃ v, u < v ∧ v ∈ P ∧ ∀ r, u < r → r < v → r ∉ P)
    (hNoTwo : ∀ u, t < u → u < s₂ →
        (∃ v, u < v ∧ ∀ w, u < w → w < v → w ∉ P) ∨
        (∃ v, v < u ∧ ∀ w, v < w → w < u → w ∉ P)) : False := by
  have hts : t < min s₁ s₂ := lt_min hs₁ hs₂
  have hss1 : min s₁ s₂ ≤ s₁ := min_le_left _ _
  have hss2 : min s₁ s₂ ≤ s₂ := min_le_right _ _
  set s := min s₁ s₂ with hsdef
  set S : Set D := {u | u ∈ P ∧ t < u ∧ u < s} with hS
  have hSsub : ∀ x ∈ S, t < x ∧ x < s := fun x hx => ⟨hx.2.1, hx.2.2⟩
  have hSdense : ∀ a ∈ S, ∀ b ∈ S, a < b → ∃ c ∈ S, a < c ∧ c < b := by
    intro a ha b hb hab
    by_contra hcon
    have hfree : ∀ r, a < r → r < b → r ∉ P := by
      intro r har hrb hrP
      exact hcon ⟨r, ⟨hrP, lt_trans ha.2.1 har, lt_trans hrb hb.2.2⟩, har, hrb⟩
    exact hNoStart a ha.2.1 (lt_of_lt_of_le ha.2.2 hss1) ha.1 ⟨b, hab, hb.1, hfree⟩
  have hF : ∀ u, t < u → u < s →
      ∃ q ∈ Q, ∀ a ∈ S, ∀ b ∈ S, a < u → u < b → a < q ∧ q < b := by
    intro u htu hus
    rcases hNoTwo u htu (lt_of_lt_of_le hus hss2) with ⟨v, huv, hv⟩ | ⟨v, hvu, hv⟩
    · obtain ⟨q, hqQ, huq, hqc⟩ := hQd u (min v s) (lt_min huv hus)
      refine ⟨q, hqQ, ?_⟩
      intro a _ b hb hau hub
      refine ⟨lt_trans hau huq, ?_⟩
      rcases le_or_gt (min v s) b with h | h
      · exact lt_of_lt_of_le hqc h
      · exact absurd hb.1 (hv b hub (lt_of_lt_of_le h (min_le_left _ _)))
    · obtain ⟨q, hqQ, hcq, hqu⟩ := hQd (max v t) u (max_lt hvu htu)
      refine ⟨q, hqQ, ?_⟩
      intro a ha b _ hau hub
      refine ⟨?_, lt_trans hqu hub⟩
      rcases le_or_gt a (max v t) with h | h
      · exact lt_of_le_of_lt h hcq
      · exact absurd ha.1 (hv a (lt_of_le_of_lt (le_max_left _ _) h) hau)
  obtain ⟨u1, htu1, hu1s, hu1P⟩ := hK s hts
  obtain ⟨u0, htu0, hu0, hu0P⟩ := hK u1 htu1
  exact nested_core h_lub Q hQc S t s hSsub hSdense hF u0 u1
    ⟨hu0P, htu0, lt_trans hu0 hu1s⟩ ⟨hu1P, htu1, hu1s⟩ hu0

theorem sep_order_mirror {D : Type} [LinearOrder D] [DenselyOrdered D]
    (h_lub : ∀ X : Set D, X.Nonempty → BddAbove X → ∃ x, IsLUB X x)
    (Q : Set D) (hQc : Q.Countable) (hQd : ∀ x y : D, x < y → ∃ q ∈ Q, x < q ∧ q < y)
    (P : Set D) (t s₁ s₂ : D) (hs₁ : s₁ < t) (hs₂ : s₂ < t)
    (hK : ∀ v, v < t → ∃ u, v < u ∧ u < t ∧ u ∈ P)
    (hNoStart : ∀ u, u < t → s₁ < u → u ∈ P →
        ¬ ∃ v, v < u ∧ v ∈ P ∧ ∀ r, v < r → r < u → r ∉ P)
    (hNoTwo : ∀ u, u < t → s₂ < u →
        (∃ v, v < u ∧ ∀ w, v < w → w < u → w ∉ P) ∨
        (∃ v, u < v ∧ ∀ w, u < w → w < v → w ∉ P)) : False := by
  refine sep_order (D := Dᵒᵈ) ?_ (Q : Set Dᵒᵈ) hQc ?_ (P : Set Dᵒᵈ)
    (OrderDual.toDual t) (OrderDual.toDual s₁) (OrderDual.toDual s₂) hs₁ hs₂ ?_ ?_ ?_
  · intro X hne hbdd
    exact exists_isGLB_of_lub h_lub (B := (X : Set D)) hne hbdd
  · intro x y hxy
    obtain ⟨q, hq, h1, h2⟩ := hQd (OrderDual.ofDual y) (OrderDual.ofDual x) hxy
    exact ⟨OrderDual.toDual q, hq, h2, h1⟩
  · intro v hv
    obtain ⟨u, h1, h2, h3⟩ := hK (OrderDual.ofDual v) hv
    exact ⟨OrderDual.toDual u, h2, h1, h3⟩
  · intro u h1 h2 h3 ⟨v, hv1, hv2, hv3⟩
    exact hNoStart (OrderDual.ofDual u) h1 h2 h3 ⟨OrderDual.ofDual v, hv1, hv2,
      fun r hr1 hr2 => hv3 (OrderDual.toDual r) hr2 hr1⟩
  · intro u h1 h2
    rcases hNoTwo (OrderDual.ofDual u) h1 h2 with ⟨v, hv1, hv2⟩ | ⟨v, hv1, hv2⟩
    · exact Or.inl ⟨OrderDual.toDual v, hv1, fun w hw1 hw2 => hv2 (OrderDual.ofDual w) hw2 hw1⟩
    · exact Or.inr ⟨OrderDual.toDual v, hv1, fun w hw1 hw2 => hv2 (OrderDual.ofDual w) hw2 hw1⟩
```

`exists_isGLB_of_lub` is the existing private helper at `Soundness.lean:1457`; if Phase B moves to a
new file it must move with it (or be re-declared there and the `Soundness.lean` copy left in place
for `prior_S_gap_valid`).

### 7.4 Phase C — the two validity lemmas

These replace the `sorry` bodies at `Soundness.lean:1582` and `:1605`. **The theorem statements are
unchanged**, so the two call sites (`axiom_dedekind_valid` at `:1675`, `axiom_dedekind_swap_valid` at
`:1696`) need no edit.

```lean
theorem sep_valid (φ : Formula) :
    ValidDedekindDense ((Formula.and (Formula.kPlus φ)
        (Formula.kPlus (Formula.and φ (Formula.untl φ φ.neg))).neg).imp
        (Formula.kPlus (Formula.and (Formula.kPlus φ) (Formula.kMinus φ)))) := by
  intro D _ _ _ _ _ h_lub F M Omega h_sc τ h_mem t h_ant
  obtain ⟨Q, hQc, hQd⟩ := exists_countable_order_dense h_lub
  simp only [TruthAt, Formula.and, Formula.neg, Formula.kPlus, Formula.kMinus,
    Formula.top] at h_ant ⊢
  obtain ⟨h1, h2⟩ := and_of_not_imp_not h_ant
  rintro ⟨s₂, hts₂, -, hno⟩
  have hK : ∀ v, t < v → ∃ u, t < u ∧ u < v ∧ TruthAt M Omega τ u φ := by
    intro v htv
    by_contra hc
    refine h1 ⟨v, htv, fun hb => hb, ?_⟩
    intro r htr hrv hrφ
    exact hc ⟨r, htr, hrv, hrφ⟩
  have h2' : ∃ s₁, t < s₁ ∧ (True) ∧ ∀ u, t < u → u < s₁ →
      (TruthAt M Omega τ u φ → TruthAt M Omega τ u (Formula.untl φ φ.neg) → False) := by
    refine Classical.byContradiction (fun hc => h2 ?_)
    intro hbad
    exact hc (by
      obtain ⟨s₁, hts₁, -, hu⟩ := hbad
      exact ⟨s₁, hts₁, trivial, fun u htu hus => Classical.byContradiction (hu u htu hus)⟩)
  obtain ⟨s₁, hts₁, -, hstart⟩ := h2'
  refine sep_order h_lub Q hQc hQd {u | TruthAt M Omega τ u φ} t s₁ s₂ hts₁ hts₂ hK ?_ ?_
  · rintro u htu hus₁ huP ⟨v, huv, hvP, hfree⟩
    exact hstart u htu hus₁ huP ⟨v, huv, hvP, fun r hur hrv => hfree r hur hrv⟩
  · intro u htu hus₂
    have hAB : TruthAt M Omega τ u (Formula.kPlus φ) →
        TruthAt M Omega τ u (Formula.kMinus φ) → False := by
      intro ha hb
      exact hno u htu hus₂ (fun k => k ha hb)
    by_cases hR : ∃ v, u < v ∧ ∀ w, u < w → w < v → ¬ TruthAt M Omega τ w φ
    · exact Or.inl hR
    · refine Or.inr ?_
      have ha : TruthAt M Omega τ u (Formula.kPlus φ) := by
        simp only [TruthAt, Formula.kPlus, Formula.neg, Formula.top]
        rintro ⟨v, huv, -, hw⟩
        exact hR ⟨v, huv, fun w huw hwv => hw w huw hwv⟩
      have hb := hAB ha
      refine Classical.byContradiction (fun hns => hb ?_)
      simp only [TruthAt, Formula.kMinus, Formula.neg, Formula.top]
      rintro ⟨v, hvu, -, hw⟩
      exact hns ⟨v, hvu, fun w hvw hwu => hw w hvw hwu⟩

theorem sep_swap_valid (φ : Formula) :
    ValidDedekindDense (((Formula.and (Formula.kPlus φ)
        (Formula.kPlus (Formula.and φ (Formula.untl φ φ.neg))).neg).imp
        (Formula.kPlus (Formula.and (Formula.kPlus φ) (Formula.kMinus φ)))).swapTemporal) := by
  intro D _ _ _ _ _ h_lub F M Omega h_sc τ h_mem t h_ant
  obtain ⟨Q, hQc, hQd⟩ := exists_countable_order_dense h_lub
  simp only [Formula.and, Formula.neg, Formula.kPlus, Formula.kMinus, Formula.top,
    Formula.swapTemporal, TruthAt] at h_ant ⊢
  obtain ⟨h1, h2⟩ := and_of_not_imp_not h_ant
  rintro ⟨s₂, hs₂t, -, hno⟩
  have hK : ∀ v, v < t → ∃ u, v < u ∧ u < t ∧ TruthAt M Omega τ u φ.swapTemporal := by
    intro v hvt
    by_contra hc
    refine h1 ⟨v, hvt, fun hb => hb, ?_⟩
    intro r hvr hrt hrφ
    exact hc ⟨r, hvr, hrt, hrφ⟩
  have h2' : ∃ s₁, s₁ < t ∧ (True) ∧ ∀ u, u < t → s₁ < u →
      (TruthAt M Omega τ u φ.swapTemporal →
        TruthAt M Omega τ u (Formula.snce φ.swapTemporal φ.swapTemporal.neg) → False) := by
    refine Classical.byContradiction (fun hc => h2 ?_)
    intro hbad
    exact hc (by
      obtain ⟨s₁, hs₁t, -, hu⟩ := hbad
      exact ⟨s₁, hs₁t, trivial, fun u hut hs₁u => Classical.byContradiction (hu u hs₁u hut)⟩)
  obtain ⟨s₁, hs₁t, -, hstart⟩ := h2'
  refine sep_order_mirror h_lub Q hQc hQd {u | TruthAt M Omega τ u φ.swapTemporal}
    t s₁ s₂ hs₁t hs₂t hK ?_ ?_
  · rintro u hut hs₁u huP ⟨v, hvu, hvP, hfree⟩
    exact hstart u hut hs₁u huP ⟨v, hvu, hvP, fun r hvr hru => hfree r hvr hru⟩
  · intro u hut hs₂u
    have hAB : TruthAt M Omega τ u (Formula.kMinus φ.swapTemporal) →
        TruthAt M Omega τ u (Formula.kPlus φ.swapTemporal) → False := by
      intro ha hb
      exact hno u hs₂u hut (fun k => k ha hb)
    by_cases hL : ∃ v, v < u ∧ ∀ w, v < w → w < u → ¬ TruthAt M Omega τ w φ.swapTemporal
    · exact Or.inl hL
    · refine Or.inr ?_
      have ha : TruthAt M Omega τ u (Formula.kMinus φ.swapTemporal) := by
        simp only [TruthAt, Formula.kMinus, Formula.neg, Formula.top]
        rintro ⟨v, hvu, -, hw⟩
        exact hL ⟨v, hvu, fun w hvw hwu => hw w hvw hwu⟩
      have hb := hAB ha
      refine Classical.byContradiction (fun hns => hb ?_)
      simp only [TruthAt, Formula.kPlus, Formula.neg, Formula.top]
      rintro ⟨v, huv, -, hw⟩
      exact hns ⟨v, huv, fun w huw hwv => hw w huw hwv⟩
```

**On the swap.** `swapTemporal` distributes through `imp`/`bot`, hence through `neg` and `and`, and
exchanges `untl`/`snce` while fixing `top`; so `(kPlus φ).swapTemporal = kMinus φ.swapTemporal` and
vice versa, and the swapped Sep is the exact past mirror with `ψ := φ.swapTemporal`. The single
`simp only` above performs the whole unfolding. The past-directed core is obtained from
`sep_order_mirror`, which is `sep_order` at `Dᵒᵈ` — no hand-mirrored duplicate of `nested_core` is
needed. This differs from the task-405 approach (which hand-dualised `prior_S_gap_valid`) because
here the dualised body is ~130 lines rather than ~25.

### 7.5 Docstring / comment edits

- Delete the trailing paragraph of the section comment at `Soundness.lean:1442-1448` outright — task
  405's implementer wrote it as a self-contained deletable block. Replace with a sentence recording
  that the Dedekind soundness chain is now sorry-free.
- Replace the `-- sorry:` blocks in both Sep docstrings with proof-summary prose citing Reynolds §7
  lemma 10, the separability input, and the nested-interval restructuring. Follow the shape task 405
  used for the Prior docstrings.
- Update `Soundness.lean:1612` ("The three Reynolds axioms route to the strategic-sorry lemmas
  above") and `:1673` ("the only debt in this theorem") — both are now false.

---

## 8. Fidelity: the deviation from Reynolds' route, and why it is sound

`.claude/rules/lean4.md` requires following a cited literature source step-by-step. The verified
proof follows Reynolds' lemma 10 exactly through step 6 of the step map — including his `S`,
his relative-density condition, his `I_u` intervals, and his separation observation — and then
substitutes step 8 for his step 7.

**What is preserved.** The essential mathematical input is unchanged: separability of the flow (a
countable dense subset). Reynolds uses it in the form "ℝ has no uncountable family of pairwise
disjoint non-degenerate intervals"; the verified proof uses it in the form "each `I_u` contains a
point of a fixed countable dense `Q`, and the map `u ↦ q_u` separates `S`-separated points". These
are two packagings of the same fact — the second is exactly the standard proof of the first.

**What is dropped, and why.** Reynolds' step 7 needs: (i) a recursive thinning of `S` to a countable
subset preserving all three conditions; (ii) Cantor's theorem that a countable dense linear order
without endpoints is isomorphic to ℚ; (iii) the fact that ℚ has uncountably many gaps; (iv) cardinal
comparison. None of (i)-(iv) is in scope for this tree, (ii) alone is a substantial development, and
(iii)-(iv) would drag `Cardinal` into the soundness chain. Reynolds' "no last point" condition is
also dropped: it is needed only to secure order type ℚ, which the verified route does not use.

**Why this is not a shortcut in the prohibited sense.** The rule forbids using `simp`/`omega`/`aesop`
to bypass steps the literature handles explicitly, and forbids abandoning the source's approach after
a tactic failure. Neither applies: no automation is used anywhere in the core (see section 9), the
source's approach is followed to step 6, and the substitution at step 7/8 is a documented,
mathematically equivalent restructuring of the source's own final move, adopted for a stated
formalization reason rather than a proof-search failure. **The deviation must be recorded in the
`sep_valid` docstring** so a future reader comparing against Reynolds §7 is not confused by the
absence of `S ≅ ℚ`.

---

## 9. Tactic survey results

| Goal | Tactic class | Result | Note |
|---|---|---|---|
| `nested_core` (all steps) | `simp` / `aesop` / `omega` / `decide` | not applicable | goals are `∃`/`∀` over an abstract `LinearOrder` with an opaque set `S`; no decidable or arithmetic structure |
| `arch_of_lub` closing step | `linarith` | fails | ordered *group*, not ordered field; `linarith` has no multiplication to work with. Replaced by `sub_lt_iff_lt_add.mp` |
| `c + (a - c) = a` | `ring` | fails ("made no progress") | `AddCommGroup`, not a ring. `abel` succeeds |
| `k • e + e ≤ x + e` | `gcongr` | succeeds | preferred over `add_le_add_right`, whose argument order differs from the naive expectation in this Mathlib pin |
| `n • a ≤ n • b → a ≤ b` | `exact?` | found `le_of_nsmul_le_nsmul_right` | the guess `le_of_nsmul_le_nsmul` does not exist |
| `2^0 • d 0 ≤ a` | `simp` | leaves `1 • d 0 ≤ a` | needs `simp [one_nsmul, (rfl : d 0 = a)]` |
| TruthAt unfolding | `simp only [TruthAt, Formula.and, Formula.neg, Formula.kPlus, Formula.kMinus, Formula.top]` | succeeds | the established house idiom; add `Formula.swapTemporal` for the swap lemma |

Productive tools: `lake env lean` on scratch files (ground truth), Mathlib source grep for exact
lemma names and argument orders. `lean_run_code` was actively misleading — see section 6.

---

## 10. Verification evidence

| Check | Command | Result |
|---|---|---|
| Phase A compiles | `lake env lean .../Probe1.lean`, `.../Probe3.lean` | EXIT=0 |
| `nested_core` compiles | `lake env lean .../Probe2.lean` | EXIT=0 |
| `sep_order` compiles | `lake env lean .../Probe4.lean` | EXIT=0 |
| `sep_order_mirror` via `Dᵒᵈ` | `lake env lean .../Probe8.lean` | EXIT=0 |
| TruthAt glue for both lemmas | `lake env lean .../Probe5.lean` | EXIT=0 |
| **Full assembly, no `sorry`** | `lake env lean .../Full.lean` | **EXIT=0, no warnings** |
| Axiom footprint | `#print axioms Probe.sep_valid` / `sep_swap_valid` | `[propext, Classical.choice, Quot.sound]` — no `sorryAx` |
| Minimal import set | assembly with only `FormalSystem.Metalogic.Soundness` + 2 Mathlib modules | EXIT=0 |
| Compile cost | `time lake env lean .../FullMin.lean` | 3.9s real |
| Current in-closure sorry count | `grep -rn '^\s*sorry\s*$' --include=*.lean FormalSystem \| grep -v Boneyard` | 3 (`Soundness.lean:1582`, `:1605`, `WeakCanonical/Transfer.lean:1242`) |
| **DONE-WHEN** | `lake build` AND `lake build BimodalTest` both green; both Sep lemmas sorry-free; count 3 → 1 | to be run at implementation time; `lake build` alone is insufficient because `Metalogic/Decidability/TraceExport.lean` sits outside the default target's import closure |

Scratch files live under
`/tmp/claude-1000/-home-benjamin-Projects-BimodalLogic/51024596-e6d9-4261-a34c-cf493ee4da52/scratchpad/`
(`Probe1`-`Probe8`, `Full.lean`, `FullMin.lean`). They are ephemeral; the authoritative copy of the
verified text is section 7 of this report.

---

## 11. Risks and scope notes

| Risk | Severity | Mitigation |
|---|---|---|
| Implementer assumes Sep behaves like the Prior lemmas and tries an order-only proof | High | Section 5 states the counterexample explicitly; the plan must front-load "the group binders are load-bearing" |
| Implementer re-derives its own decomposition instead of transcribing section 7 | High | `.claude/rules/plan-compliance.md` applies; the plan should say "transcribe verbatim, do not re-derive" |
| `Formula.snce`/`Formula.untl` argument order mis-transcribed | Medium | Section 4 documents the trap and gives the ℝ refutation of the wrong reading |
| Two new Mathlib imports perturb the build graph | Low | Verified: only `Mathlib.Algebra.Order.Archimedean.Basic` and `Mathlib.Data.Set.Countable` are needed; full assembly compiles in ~4s |
| `Dᵒᵈ` instance friction | Low (resolved) | Must use explicit `OrderDual.toDual` / `OrderDual.ofDual` as in 7.3; the naive `exact h` and the `OrderDual.toDual_lt_toDual` rewrite both fail with an instance-defeq error |
| `exists_isGLB_of_lub` duplication if Phase B moves to a new file | Low | Note it in the plan; either move it or re-declare |
| Concurrent edits | Low | Do not touch `FormalSystem/Metalogic/WeakCanonical/Kamp/` |
| Stale DONE-WHEN arithmetic in the task description | Low | Section 1 records the correction: baseline is 3, target 1 |

**Out of scope.** No change to `ValidDedekindDense`, `ValidDedekind`, `FrameClass`, or the
dispatchers. No new axioms, no `sorry`, no vacuous definitions. No restatement of the Prior lemmas.
No formalization of the section 5.1 counterexample (it is documentation, not a proof obligation).

---

## 12. Recommended plan shape

Three phases, each bounded to a single agent run and each independently `lake build`-able.

**Phase 1 — separability of the flow** (~110 lines). Create
`FormalSystem/Metalogic/SoundnessLemmas/Separability.lean` with the two Mathlib imports; transcribe
section 7.2 (`exists_half_le`, `arch_of_lub`, `exists_null_seq`, `exists_countable_order_dense`) plus
a copy of `exists_isGLB_of_lub`. Verify with `lake build FormalSystem.Metalogic.SoundnessLemmas.Separability`.

**Phase 2 — the order-theoretic core** (~135 lines). Append section 7.3 (`nested_core`, `sep_order`,
`sep_order_mirror`) to the same file. Verify with the same scoped build.

**Phase 3 — the two validity lemmas and comment cleanup** (~70 lines changed). Add the import to
`Soundness.lean`; replace the two `sorry` bodies with section 7.4; apply the section 7.5 docstring
and comment edits. Verify with `lake build` **and** `lake build BimodalTest`, then re-run the sorry
count (expect 1) and `#print axioms FormalSystem.Metalogic.sep_valid` /
`...sep_swap_valid` (expect no `sorryAx`).

If the planner prefers the inlining alternative (7.1), phases 1 and 2 append to `Soundness.lean`
immediately before `sep_valid` instead, and the two Mathlib imports go at its top. No other change.

**No blockers.** Both lemmas are proved.

---

## 13. Context extension recommendations

- **Topic**: `lean_run_code` MCP reliability.
  **Gap**: `.claude/rules/lean4.md` lists `lean_diagnostic_messages` and `lean_file_outline` as
  blocked but says nothing about `lean_run_code`. In this environment `lean_run_code` returned
  `success: true, diagnostics: []` for `example : 1 = 2 := by rfl`, silently reporting a false
  positive; and `import Mathlib` does not resolve in this project (only individual Mathlib modules
  are built), so snippets written against it are not testing what they appear to test.
  **Recommendation**: add `lean_run_code` to the blocked/untrusted list for this repo, with the
  substitute recipe: write a scratch `.lean` file importing the specific project and Mathlib modules,
  then run `lake env lean <abs-path>` **from the project root** (a `cd` into the scratch directory
  breaks `lake env` module resolution) and read the exit code.

---

## 14. References

- `/home/benjamin/Projects/Literature/sources/reynolds_1992/sec01_an-axiomatization-for-until-and-since-ov.md`
  lines 74-79 (K± table), 118 (Sep), 124 (the deferral), 50-66 (U/S semantics)
- `/home/benjamin/Projects/Literature/sources/reynolds_1992/sec04_7-separability.md` lines 3-21
  (lemma 10 and the long-line caveat)
- `FormalSystem/Metalogic/Soundness.lean`:106 (`and_of_not_imp_not`), 1435-1449 (section comment),
  1457 (`exists_isGLB_of_lub`), 1486-1568 (the Prior lemmas), 1570-1605 (the two targets),
  1675 and 1696 (call sites)
- `FormalSystem/Semantics/Validity.lean`:195-262 (`ValidDedekind`, `ValidDedekindDense` and the
  binder-set rationale), 291-305 (bridges)
- `FormalSystem/Semantics/Truth.lean`:128-138 (`TruthAt`)
- `FormalSystem/Syntax/Formula.lean`:118 (`top`), 121 (`neg`), 180 (`kPlus`), 193 (`kMinus`),
  433-438 (`and`, `or`), 619-625 (`swapTemporal`)
- `specs/405_prove_semantic_validity_of_the_prioru_and_priors_gap_axioms_over_dense_dedekindcomplete_duration_groups/reports/01_prior-gap-axiom-validity.md`
