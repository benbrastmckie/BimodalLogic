# Research Report: JPL Paper Appendix Analysis -- Canonical Model Construction

**Task**: 956 -- Construct D as translation group from syntax
**Report**: research-007
**Date**: 2026-03-06
**Session**: sess_1772912000_a1b2c3
**Status**: Findings ready for planning

---

## 1. Executive Summary

Analysis of the JPL paper (`possible_worlds.tex`) and its unpublished metalogic appendix (`metalogic.tex`) reveals a critical finding that resolves the blockers identified in research-006:

**The paper's completeness proof uses D = Z (integers) directly as the canonical temporal order. It does NOT construct D as a group of order-preserving automorphisms of any timeline.**

This means the three blockers (freeness, Holder's theorem, homogeneity) are artifacts of an approach NOT taken by the paper. The paper sidesteps these entirely by choosing Z as a primitive temporal order for the canonical model.

---

## 2. Key Findings from the Paper

### 2.1 The Paper Assumes D is Given (Not Constructed)

In the paper's semantic framework (Section 4, Definition `def:frame`), a frame is:
- `F = (W, D, =>)` where D = (D, +, <=) is a **totally ordered abelian group** given as a primitive.

The paper does NOT construct D from the set of MCSes. D is a parameter of the model, not derived from syntax.

### 2.2 The Canonical Model Uses D = Z

The metalogic appendix (`metalogic.tex`, Definition `def:canonical-temporal-order`) states explicitly:

> The *canonical temporal order* is T^c = (Z, +, <=) where Z is the set of integers with standard addition and ordering.

This is line 42-44 of `metalogic.tex`. The canonical model is then:
- W^c = set of maximal TM-consistent sets
- T^c = (Z, +, <=)
- =>^c defined by canonical histories (see below)
- Valuation by syntactic membership

### 2.3 Canonical Histories Are Built Recursively

The paper builds canonical histories `tau_Gamma : Z -> W^c` by:
1. `tau_Gamma(0) = Gamma` (the starting MCS)
2. For n > 0: extend forward using temporal consistency (propagating Future-formulas)
3. For n < 0: extend backward using temporal consistency (propagating Past-formulas)

This is a step-by-step construction indexed by integers -- no automorphism group needed.

### 2.4 The Canonical Task Relation

The canonical task relation is defined as:
> `w =>^c_d u` iff there exists tau in H^c and t in Z such that tau(t) = w and tau(t + d) = u.

This is purely existential -- it just checks whether some canonical history connects w to u with displacement d.

### 2.5 Density Extension Uses D = Q

For the dense logic TM^d, the paper sketches (Theorem `thm:TMd-completeness`) that the canonical model uses T^c = Q instead of T^c = Z. The proof is described as carrying through "unchanged" with this substitution.

### 2.6 Time-Shift Invariance

The paper's key technical lemma (`app:auto_existence`, `lem:history-time-shift-preservation`) shows that for any world history tau and times x, y, there exists a time-shifted history sigma where `sigma(z) = tau(z - x + y)`. This uses the **group structure of D** (specifically, translation by group elements), NOT automorphisms of a separate timeline.

The automorphism used is simply `a_bar(z) = z - x + y`, which is addition by a constant -- i.e., a translation in D itself. The paper never needs arbitrary order automorphisms of a constructed timeline.

---

## 3. Implications for Task 956

### 3.1 The Automorphism Group Approach is Not From the Paper

The approach of constructing D as `Additive(T ≃o T)` (the group of order-preserving automorphisms of a timeline T of MCSes) appears to be an independent mathematical construction not found in the JPL paper. The paper's approach is simpler:

1. **Choose D = Z** (or Q for dense case)
2. **Build canonical histories** as functions `Z -> W^c`
3. **Define the task relation** from the histories
4. **Prove the truth lemma** by induction on formula complexity

### 3.2 The Three Blockers Do Not Apply

Since the paper uses D = Z directly:
- **Freeness**: Not needed. Z acts on itself by translation, which is trivially free.
- **Holder's theorem**: Not needed. Z is trivially abelian.
- **Homogeneity**: Not needed. Z acts on itself transitively by translation.

All three properties hold trivially for Z acting on itself.

### 3.3 What the Paper Actually Needs

The paper needs:
1. **Z is a totally ordered abelian group** -- trivially true, available in Mathlib
2. **Canonical histories can be constructed** -- requires temporal consistency lemma
3. **The canonical task relation satisfies Nullity and Compositionality** -- follows from construction
4. **Truth Lemma** -- the main technical challenge (induction on formula complexity)

### 3.4 The Existing Codebase Already Has TaskFrame Int

The codebase already defines `TaskFrame Int` with various task relations in `TemporalStructures.lean`. The task is to connect the canonical model construction to this existing infrastructure rather than building a new abstract D.

---

## 4. What Remains for the Completeness Proof

Based on the paper's approach, the completeness proof requires:

### Phase 1: Canonical World States
- Define W^c as maximal TM-consistent sets (partially done in codebase)
- Prove Lindenbaum's Lemma
- Prove Modal Saturation

### Phase 2: Canonical Histories
- Define `tau_Gamma : Z -> W^c` recursively
- Prove temporal consistency (the key technical lemma)
- This is where the "forward/backward witness" construction in the codebase connects

### Phase 3: Canonical Task Relation
- Define `w =>^c_d u` from canonical histories
- Prove Nullity (trivial from construction)
- Prove Compositionality (requires care about history composition)

### Phase 4: Truth Lemma
- Induction on formula complexity
- Base cases: sentence letters, bottom (straightforward)
- Implication case (straightforward)
- Box case: requires Modal Saturation
- Past/Future cases: require temporal consistency

### Phase 5: Completeness
- Weak completeness: contrapositive via Lindenbaum + Truth Lemma
- Strong completeness: extend consistent sets, apply Truth Lemma

---

## 5. Density and Discreteness Axioms

The paper treats density and discreteness as **optional extensions**, not base axioms:

| Logic | Temporal Order | Density Axiom (DN) | Discrete Axioms (DP, DF) |
|-------|---------------|-------------------|--------------------------|
| TM (base) | Any totally ordered abelian group | Not included | Not included |
| TM^d | Dense totally ordered abelian group | Included | Excluded |
| TM^disc (not named) | Discrete totally ordered abelian group | Excluded | Included |

The paper focuses on TM^d for philosophical reasons but the base logic TM is complete over ALL totally ordered abelian groups, with the canonical model using Z.

**Key insight**: The density axiom DN is proven INVALID over Z (Theorem `app:not-dense` constructs an explicit Z-countermodel). This means TM is NOT complete over dense models alone -- it needs the full class of frames including discrete ones.

---

## 6. Revised Recommendation

### Primary: Use D = Z Following the Paper

Abandon the automorphism group construction for D. Instead:
1. Use `D = Int` (= Z) as the canonical temporal order
2. Build canonical histories as `Z -> MCS` functions
3. Define the canonical task relation from these histories
4. Prove the Truth Lemma

This aligns with:
- The paper's own approach
- Option C from research-006 (which was identified as "most pragmatic")
- The existing `TaskFrame Int` infrastructure in the codebase

### Secondary: Option D (Axiomatic Abstraction) is Unnecessary

The `HomogeneousTimeline` typeclass from Option D in research-006 is unnecessary for the completeness proof. The paper never needs to construct D from T -- it goes the other way, using D to parameterize T.

### What Changes for Task 956

Task 956's objective ("Construct D as the group of order-preserving automorphisms of the canonical timeline of MCSs") should be **revised** or **replaced**. The paper does not perform this construction. Instead, a new task should:
1. Set D = Z
2. Build canonical histories indexed by Z
3. Define the canonical task relation
4. Verify frame properties (Nullity, Compositionality)

---

## 7. Open Questions

1. **Compositionality of the canonical task relation**: The paper's proof of compositionality (Theorem `thm:canonical-compositionality`) is sketchy -- it hand-waves about "constructing a history passing through w, u, and v." This may require non-trivial formalization.

2. **Non-uniqueness of canonical histories**: The construction uses Lindenbaum's Lemma, which is non-constructive. Multiple maximal extensions exist. The paper defines `tau_Gamma(n)` as "the unique maximal TM-consistent extension" but this uniqueness is not justified and likely false -- it should say "a" maximal extension, chosen by some selection principle.

3. **Temporal Consistency Lemma**: The proof (Lemma `lem:temporal-consistency`) uses axioms T4, TA, and TK in a specific way. The Lean formalization needs these axioms to be available.

4. **Future work on density**: For TM^d completeness, the paper claims the same construction works with Q instead of Z. This would be a separate task.

---

## 8. Summary

- The JPL paper uses D = Z directly, not an automorphism group construction
- The three blockers (freeness, Holder, homogeneity) are irrelevant to the paper's approach
- Task 956 should be revised to follow the paper's simpler D = Z approach
- The completeness proof requires: Lindenbaum, Modal Saturation, Temporal Consistency, canonical history construction, Truth Lemma
- The existing `TaskFrame Int` infrastructure is well-suited to this approach
