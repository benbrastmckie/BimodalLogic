# Research Report: Weak/Reflexive Completeness with Model-Theoretic Transfer

- **Task**: 129 - weak_reflexive_completeness_conservative_extension
- **Date**: 2026-05-13
- **Session**: sess_1778657762_d3e9ec
- **Type**: Research -- proof architecture for integer completeness

## Executive Summary

The weak/reflexive canonical model is a proof technique for establishing strict-semantics completeness of the integer temporal logic. The strict semantics remains the primary object of study; nothing about the logic, its syntax, or its semantics changes. The Doets compression (quotient + Z-shape expansion + Z1 maximum principle) produces a countermodel on Z with strict `<` directly, making the conservative extension a 10-line model-theoretic observation rather than a separate infrastructure module.

---

## 1. The Strict Semantics Remains Primary

The weak/reflexive approach does NOT change the logic under study. All frame classes (`valid`, `valid_dense`, `valid_discrete`), the `Formula` type, the `Axiom` type, `truth_at`, and all soundness theorems remain exactly as they are. The weak canonical model is an intermediate construction used solely to prove completeness -- analogous to proving a theorem about integers by embedding into the reals, doing analysis, and bringing the result back.

The deliverable of task 129 is a proof of: "if phi is valid on all discrete IsSuccArchimedean frames under **strict** semantics, then phi is provable in the strict axiom system." The weak model appears only inside this proof.

---

## 2. Why the Standard Canonical Model Fails for Strict Semantics

The standard Henkin canonical model has the accessibility relation:

```
x R y  iff  forall phi, G(phi) in x -> phi in y
```

### The truth lemma backward direction for G

To prove `G(phi) notin x -> exists y, x R y and phi notin y`, the Lindenbaum lemma constructs an MCS y containing `{psi | G(psi) in x} union {neg phi}`. This y satisfies `x R y` and `phi notin y`.

**Problem**: nothing prevents `y = x`. Under strict semantics, `y = x` is not a valid witness for "there exists a strictly future point." The canonical relation R is a **preorder** (reflexive + transitive), not a strict order. Some MCS x satisfy `G(phi) -> phi` for all phi (making `x R x`), since `G(phi) -> phi` is not refutable in the strict system even though it is not an axiom.

### Three workarounds for irreflexivity

**IR Rule (Gabbay)**: A non-standard inference rule: "from `|- G(p) -> p` where p is a fresh variable, conclude `|- p`." Forces every MCS to have some phi with `G(phi) in x` but `phi notin x`, ensuring `not (x R x)`. Complicates the proof theory (global freshness side-condition, not a standard Hilbert rule).

**Chronicle Construction (Burgess)**: Build the model point by point at fresh rational positions, maintaining strict `<` by physical distinctness. The truth lemma works because witnesses are placed at genuinely new positions. **But**: this construction loses the "all MCS are distinct" property of the canonical model. The same MCS can label multiple points, enabling the constant-MCS gap scenario where Z1 holds vacuously for all definable predicates but the frame has Z+Z structure.

**Doets Quotient**: Start with the standard reflexive canonical model (where Sahlqvist canonicity applies), quotient by the equivalence `x ~ y iff x R y and y R x` to get a strict partial order, expand equivalence classes to Z-shapes, compress via Z1 maximum principle. **This is what task 129 uses.**

---

## 3. The Doets Compression Produces a Strict Model

Starting from the weak canonical model (reflexive preorder <=):

**Step 1 -- Quotient**: Define `x ~ y iff x <= y and y <= x`. Quotient by ~. The result is a **strict partial order** on equivalence classes (reflexive pairs collapsed).

**Step 2 -- Linearize**: The temporal linearity axioms (BX11 and duals) ensure the quotient order is linear. Result: a **strict linear order** on equivalence classes.

**Step 3 -- Expand** (Doets Claim 9): Each equivalence class `[x]` is replaced by a Z-shaped model `[x]*` that preserves all n-characteristics (propositional type patterns) occurring cofinally in `[x]`. The expanded model `N = Sigma [x]*` has order type "sum of Z's and 1's."

**Step 4 -- Compress** (Doets Claim 10): Z1 gives the maximum principle: every definable set that is non-empty and bounded above has a maximum. This eliminates "1-cells" (singleton equivalence classes between Z-cells). The result is a single Z-shaped model with strict `<`.

The output is a model on Z with the standard strict ordering. The truth lemma shows formulas up to quantifier rank k (where k is the rank of the target formula) are preserved through the compression. The model serves as a **countermodel under strict semantics** directly.

---

## 4. The Conservative Extension is a 10-Line Argument

**Theorem**: If phi is valid on all discrete IsSuccArchimedean frames under strict semantics, then phi is provable in the strict axiom system.

**Proof** (by contrapositive):

1. Suppose phi is not provable in the strict system.
2. Then neg(phi) is consistent in the strict system.
3. Every weak axiom is a strict theorem: `G_w(psi) = psi and G(psi)` is definable, and every weak axiom instance translates to a provable strict formula. (For example, `G_w(psi) -> psi` translates to `(psi and G(psi)) -> psi`, a propositional tautology.)
4. So neg(phi) is consistent in the weak system (any strict proof of `neg(neg(phi))` would also be a strict proof of phi, contradicting step 1; since all weak axioms are strict theorems, weak consistency implies strict consistency).
5. By weak completeness (Henkin model + Doets compression): there exists a countermodel M on Z falsifying phi. M has domain Z, strict ordering `<`, and a valuation V.
6. M is a discrete IsSuccArchimedean frame under strict semantics (Z with `<` trivially satisfies SuccOrder, PredOrder, IsSuccArchimedean, IsPredArchimedean).
7. M falsifies phi under strict semantics (the Doets compression already produces truth values relative to strict `<`; the truth lemma for the compressed model gives `M, x |=_strict phi iff phi in [x]` for the relevant quantifier ranks).
8. But phi was assumed valid on all discrete IsSuccArchimedean frames under strict semantics. Contradiction with step 7.
9. Therefore phi is provable. QED.

**Key observation**: Step 7 works because Doets's compression already produces Z with strict `<`. The conservative extension is not a separate module to build -- it is an observation that the Doets construction's output is already a strict model. The "transfer" is trivial because there is nothing to transfer; the model lives in both the weak and strict worlds simultaneously.

---

## 5. Why Weak Semantics Enables the Doets Argument

### Under weak semantics (all properties that compose cleanly):

- **G_w(phi) -> phi is valid** (reflexivity of >=). This is the T axiom for the weak temporal logic.
- **Z1 collapses** to `FG_w(phi) -> G_w(phi)` -- pure backward induction with no `G(Gphi -> phi)` antecedent to establish. The antecedent `G_w(G_w(phi) -> phi) = G_w(T) = T` is trivially true.
- **Standard Henkin canonical model works**: R is reflexive (since `G_w(phi) -> phi` is an axiom), so the truth lemma's backward direction for G_w has no witness-distinctness problem. `y = x` is a valid witness.
- **Each point is a distinct MCS** by construction of the canonical model (distinct maximal consistent sets are distinct points). A discriminating formula always exists between any two points.
- **Constant-MCS is structurally impossible**: no two distinct canonical model points share the same MCS.
- **Sahlqvist canonicity applies**: Z1 is Sahlqvist, so the canonical frame validates Z1, which ensures IsSuccArchimedean.

### Under strict semantics (each property breaks):

- **G(phi) -> phi is not valid** (current point excluded from strict future). Z1's antecedent `G(Gphi -> phi)` requires establishing `Gphi -> phi` at every strictly future point -- a substantive claim, not a tautology.
- **Canonical R is reflexive** (a preorder), requiring IR rule or chronicle for irreflexivity.
- **Chronicle loses distinct MCS**: the same MCS can label multiple points, enabling constant-MCS.
- **Constant-MCS gap**: all definable predicates are trivial (constant), so Z1 holds vacuously, but the frame has Z+Z structure visible only to non-definable predicates.
- **Sahlqvist canonicity does not apply** to the chronicle model (it is not the standard canonical model).

---

## 6. What Doesn't Change

The following are **completely untouched** by task 129:

- `Formula` inductive type and all syntax
- `Axiom` inductive type and all constructors
- `truth_at` definition in `Truth.lean`
- `valid`, `valid_dense`, `valid_discrete` definitions
- All soundness theorems (`soundness`, `soundness_dense`, `soundness_discrete`)
- `SoundnessLemmas.lean` (including `z1_is_valid`, `prior_UZ_is_valid`)
- Dense completeness branch (sorry-free, uses chronicle on Q -- unrelated to the discrete sorry)
- FMP completeness
- The `TaskFrame`, `TaskModel` semantic infrastructure
- All `Examples/`, `Theorems/`, `Automation/` modules

The weak approach adds NEW files (likely under `Metalogic/DoetsCanonical/` or `Metalogic/WeakCompleteness/`) and modifies only the discrete completeness path to wire in the result.

---

## 7. Revised Phase Structure

| Phase | Description | Lines | Depends on |
|-------|-------------|-------|------------|
| 1 | Weak sub-language definition: `G_w`, `H_w`, `F_w`, `P_w` as derived operators | ~100 | -- |
| 2 | Weak axiom system: prove weak axioms derivable in strict system | ~200 | 1 |
| 3 | Weak Henkin canonical model: standard construction + truth lemma | ~500-800 | 2 |
| 4 | Doets compression to Z: quotient, expand, Z1 maximum principle, compress | ~200-400 | 3 |
| 5 | Model-theoretic transfer: the 10-line argument + verify Doets Z-model is strict countermodel | ~50-100 | 4 |
| 6 | Integration: wire into existing completeness pipeline | ~100 | 5 |
| 7 | Close the sorry: make `limitDomSubtype_isSuccArchimedean` sorry-free | ~50 | 6 |

**Total estimated**: 1200-1750 lines, 30-50 hours.

**The hard phases are 3 and 4.** Phase 3 (Henkin canonical model) requires building MCS infrastructure for the weak system and proving the truth lemma. Phase 4 (Doets compression) requires n-characteristic / Ehrenfeucht game infrastructure and the Z-shape expansion argument. Phases 5-7 are straightforward once 3-4 are done.

---

## 8. Key Insight: The Definability Gap

IsSuccArchimedean is a second-order property: "for ALL subsets S of the domain, if S is non-empty and bounded above, then S has a maximum." This quantifies over all subsets, including non-definable ones.

Z1 gives this for all **definable** subsets: "for all formulas phi, if {x | phi holds at x} is non-empty and bounded above, it has a maximum."

The gap between "all definable" and "all" is the core obstacle:

- **Standard canonical model** (weak semantics): each point is a distinct MCS. For any two points x != y, there exists a formula phi with phi in x and phi notin y. So every non-trivial subset is approximated by definable ones. "All definable" effectively equals "all." Z1 gives full IsSuccArchimedean.

- **Chronicle model** (strict semantics): distinct points can share the same MCS (constant-MCS case). Then every definable subset is either empty or the full domain. Z1 holds vacuously for all definable predicates. But the frame can have Z+Z structure, with the gap visible only to the non-definable predicate "is in the left copy." "All definable" is a strict subset of "all." Z1 does not give IsSuccArchimedean.

The weak approach returns to the setting where the definability gap closes. This is not a workaround -- it is returning to the mathematically natural setting where the standard model-theoretic machinery works as designed.

---

## 9. Relationship to Other Tasks

- **Task 123** (partial): Z1 axiom + soundness infrastructure completed. The `succ_cofinal` sorry in the chronicle construction is documented as an architectural limitation. Task 129's Phase 7 closes this sorry.
- **Task 126** (frame hierarchy): The four-tier hierarchy (Base/Dense/Discrete/Integer) is orthogonal to task 129. Task 129 provides integer completeness; task 126 organizes the frame classes and correspondence axioms.
- **Task 130** (archival): After task 129 closes the sorry, dead-end proof attempts and bypassed BXCanonical pipeline code (~40 sorries) can be archived to the Boneyard.
- **Task 122** (nondense BFMCS): Depends on task 123/129 for the discrete path. Once IsSuccArchimedean is established, the discrete BFMCS construction becomes sorry-free, unblocking task 122.
