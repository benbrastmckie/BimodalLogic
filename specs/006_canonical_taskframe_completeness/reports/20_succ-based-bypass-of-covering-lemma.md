# Succ-Based Bypass of the Covering Lemma

**Date**: 2026-03-21
**Status**: Research Report
**Companions**: Reports 04 (discrete three-place relation), 06 (role in representation theorems)
**Problem**: Task 974 blocking axiom `discrete_Icc_finite_axiom` in `DiscreteTimeline.lean:316`

---

## 1. Problem Statement

### 1.1 The Covering Lemma Gap

The discrete completeness proof is blocked by a single axiom:

```lean
axiom discrete_Icc_finite_axiom :
    ∀ (a b : DiscreteTimelineQuot root_mcs root_mcs_proof), (Set.Icc a b).Finite
```

This axiom feeds `LocallyFiniteOrder.ofFiniteIcc`, which in turn provides `SuccOrder`, `PredOrder`, and `IsSuccArchimedean` — the prerequisites for Mathlib's `orderIsoIntOfLinearSuccPredArch` theorem that gives `DiscreteTimelineQuot ≃o ℤ`.

The axiom is mathematically sound (the DF frame condition semantically guarantees finite intervals) but unprovable syntactically because the **covering lemma** — proving that DF prevents strict intermediates between adjacent MCS points in the quotient — has resisted four distinct proof approaches (Task 979).

### 1.2 Why the Covering Lemma Is Hard

The gap is between two levels:

| Level | What DF gives | What we need |
|-------|--------------|--------------|
| **Semantic** | `(F⊤ ∧ φ ∧ Hφ) → F(Hφ)` forces immediate successors in frames with SuccOrder | Immediate successors exist |
| **Syntactic** | DF creates `F(Hφ)` obligations in MCSes; these are existential witnesses | No intermediate MCS K exists with `M R K R W` |

F-obligations (`F(Hφ) ∈ M`) can be witnessed by ANY forward-accessible MCS, not necessarily the immediate one. The four failed approaches all attempted to derive a contradiction from assuming an intermediate K exists, but DF's existential character prevents this.

### 1.3 The Bypass Strategy

Instead of proving absence of intermediates on the quotient type, **define "immediate successor" syntactically** via a Succ relation on MCSes. Build the TaskFrame directly from Succ-chains, bypassing the quotient construction entirely.

---

## 2. The Succ Relation

### 2.1 New Content Extractors

Two new definitions are needed (trivial, 2 lines each):

```lean
def f_content (M : Set Formula) : Set Formula :=
  {φ | Formula.some_future φ ∈ M}

def p_content (M : Set Formula) : Set Formula :=
  {φ | Formula.some_past φ ∈ M}
```

These complement the existing `g_content` (universal future) and `h_content` (universal past):

| Extractor | Formula | Captures |
|-----------|---------|----------|
| `g_content(M)` | `{φ \| Gφ ∈ M}` | Universal future commitments |
| `h_content(M)` | `{φ \| Hφ ∈ M}` | Universal past commitments |
| `f_content(M)` | `{φ \| Fφ ∈ M}` | Existential future obligations |
| `p_content(M)` | `{φ \| Pφ ∈ M}` | Existential past obligations |

### 2.2 The Succ Definition

```lean
def Succ (u v : Set Formula) : Prop :=
  g_content u ⊆ v                              -- (1) G-persistence
  ∧ f_content u ⊆ v ∪ f_content v              -- (2) F-step
```

**Condition (1)**: G-persistence. All universal future commitments of u are realized at v. This is identical to `CanonicalR(u, v)`.

**Condition (2)**: F-step. Every existential future obligation of u is either **resolved** at v (φ ∈ v) or **deferred** to v's future (Fφ ∈ v). This is the key addition over bare CanonicalR.

### 2.3 Relationship to CanonicalR

Every Succ pair satisfies CanonicalR, but not conversely:

```
Succ(u, v)  →  CanonicalR(u, v)     [by projection to condition (1)]
CanonicalR(u, v)  ↛  Succ(u, v)     [F-step may fail]
```

The F-step condition is what makes Succ "tighter" than CanonicalR — it forces progress on existential obligations.

### 2.4 Why Succ Captures Immediate Succession

The single-step forcing theorem (Section 3) shows that if `Fφ ∈ u` and `FFφ ∉ u`, then any Succ-successor v must contain φ. This means Succ-successors resolve obligations at the earliest possible moment consistent with the nesting depth of F-formulas.

In the semantic model (where DF holds and SuccOrder exists), the immediate successor `Order.succ t` satisfies both G-persistence and F-step. Conversely, any non-immediate successor w (with `t < s < w` for some s) would violate F-step for formulas whose F-nesting depth is exactly 1: those must be resolved at s, not deferred through w.

**This is the key insight**: rather than proving no intermediates exist (the covering lemma), we define the relation so that intermediates are irrelevant — the Succ relation itself is the "immediate step" by construction.

---

## 3. Single-Step Forcing Theorem

**Theorem**. Let u be an MCS with `Fφ ∈ u` and `FFφ ∉ u`. Then for any MCS v with `Succ(u, v)`, we have `φ ∈ v`.

**Proof**:

1. Since u is MCS and `FFφ ∉ u`, by negation completeness: `¬FFφ ∈ u`
2. Expand: `¬FFφ = ¬(¬G¬(¬G¬φ)) = G(G(¬φ)) = GG(¬φ)`. So `GG(¬φ) ∈ u`.
3. By definition of g_content: `G(¬φ) ∈ g_content(u)`
4. By G-persistence (Succ condition 1): `G(¬φ) ∈ v`
5. This means `¬Fφ ∈ v`, so `Fφ ∉ v`
6. By F-step (Succ condition 2): `Fφ ∈ u` implies `φ ∈ v ∨ Fφ ∈ v`
7. Since `Fφ ∉ v` (step 5), we conclude `φ ∈ v`. **QED**

**Corollary** (Bounded Witness Distance). If `Fⁿφ ∈ u` but `Fⁿ⁺¹φ ∉ u`, then following a Succ-chain from u, φ is reached within at most n steps.

*Proof by induction on n*: At each step, either the obligation resolves (φ ∈ v) or defers with strictly decreasing nesting depth (Fⁿ⁻¹φ ∈ v but Fⁿφ ∉ v by the same argument). After at most n deferrals, the obligation must resolve.

---

## 4. CanonicalTask: The Three-Place Relation

### 4.1 Definition

```lean
def CanonicalTask (u : Set Formula) (n : ℤ) (v : Set Formula) : Prop :=
  if n > 0 then ∃ chain : Fin (n.toNat + 1) → Set Formula,
    chain 0 = u ∧ chain ⟨n.toNat, by omega⟩ = v ∧
    ∀ i : Fin n.toNat, Succ (chain i.castSucc) (chain i.succ)
  else if n < 0 then CanonicalTask v (-n) u  -- converse
  else u = v                                   -- nullity
```

Equivalently, for n ≥ 1:

```
CanonicalTask(u, 0, v)   ⟺  u = v
CanonicalTask(u, n+1, v) ⟺  ∃ w, Succ(u, w) ∧ CanonicalTask(w, n, v)
CanonicalTask(u, -k, v)  ⟺  CanonicalTask(v, k, u)
```

### 4.2 TaskFrame Axioms

**Theorem** (TaskFrame Compliance). `CanonicalTask` satisfies all three TaskFrame axioms.

**(i) Nullity Identity**: `CanonicalTask(u, 0, v) ↔ u = v`
- Direct from definition.

**(ii) Forward Compositionality**: For `0 ≤ x` and `0 ≤ y`:
  `CanonicalTask(u, x, w) ∧ CanonicalTask(w, y, v) → CanonicalTask(u, x + y, v)`
- *Proof*: Concatenate Succ-chains. If u →ˢ w₁ →ˢ ... →ˢ wₓ = w and w →ˢ w'₁ →ˢ ... →ˢ w'ᵧ = v, then u →ˢ w₁ →ˢ ... →ˢ wₓ →ˢ w'₁ →ˢ ... →ˢ w'ᵧ = v is a chain of length x + y. This is a straightforward induction on x.

**(iii) Converse**: `CanonicalTask(u, d, v) ↔ CanonicalTask(v, -d, u)`
- For d > 0: by definition of the negative case.
- For d = 0: both sides are `u = v`, which is symmetric.
- For d < 0: write d = -k, then both sides unfold to `CanonicalTask(v, k, u)`.

### 4.3 Comparison with Current `parametric_canonical_task_rel`

The current implementation (`ParametricCanonical.lean:85-206`):

```lean
def parametric_canonical_task_rel (M : WorldState) (d : D) (N : WorldState) : Prop :=
  if d > 0 then CanonicalR M.val N.val
  else if d < 0 then CanonicalR N.val M.val
  else M = N
```

| Property | Current (duration-coarse) | Proposed (CanonicalTask) |
|----------|--------------------------|--------------------------|
| d > 0 | CanonicalR (g_content ⊆) | Succ-chain of length d |
| d = 0 | M = N | u = v |
| d < 0 | Converse CanonicalR | Succ-chain converse |
| Duration sensitivity | ALL positive d map to same relation | Each d corresponds to specific chain length |
| Determinism | Highly non-deterministic | Less non-deterministic (F-step constrains) |
| F-obligations | Not tracked | Tracked via F-step condition |

---

## 5. Successor Existence Under Discrete Axioms

### 5.1 Forward Successor

**Theorem**. Under discrete axioms (base + DF + seriality), for any MCS u with `F⊤ ∈ u`, there exists an MCS v with `Succ(u, v)`.

**Proof sketch**:

1. **Seed construction**: Define
   ```
   S = g_content(u) ∪ { φ ∨ Fφ | Fφ ∈ u }
   ```
   The disjunctive form `φ ∨ Fφ` for each `Fφ ∈ u` ensures that any MCS extending S either resolves φ or defers Fφ — exactly the F-step condition.

2. **Consistency**: Suppose S is inconsistent. Then a finite subset derives ⊥:
   ```
   G(ψ₁), ..., G(ψₘ), (φ₁ ∨ Fφ₁), ..., (φₖ ∨ Fφₖ) ⊢ ⊥
   ```
   By propositional reasoning, for each disjunction we can split on cases. The G-formulas persist universally. This derivation, lifted back to u via temporal generalization, contradicts `F⊤ ∈ u` (u has a future that must be consistent with its G-content).

   The DF axiom `(F⊤ ∧ φ ∧ Hφ) → F(Hφ)` is used here: it guarantees that the G-content of u is realizable at an immediate successor, and the F-obligations can be either resolved or deferred without contradiction.

3. **Extension**: By Lindenbaum's lemma, extend S to an MCS v.

4. **Verification**:
   - G-persistence: `g_content(u) ⊆ S ⊆ v` ✓
   - F-step: For each `Fφ ∈ u`, `φ ∨ Fφ ∈ S ⊆ v`, so `φ ∈ v ∨ Fφ ∈ v` ✓

### 5.2 Backward Predecessor

Symmetric, using the DB axiom `(P⊤ ∧ φ ∧ Gφ) → P(Gφ)`.

### 5.3 Connection to Existing DiscreteSuccSeed

The existing `DiscreteSuccSeed.lean` uses **blocking formulas** (`¬ψ ∨ ¬Gψ` for each `¬Gψ ∈ M`) to construct immediate successors. This targets the covering property (no intermediates). The proposed Succ-based seed uses **disjunctive deferrals** (`φ ∨ Fφ` for each `Fφ ∈ u`) to ensure F-step compliance. These are complementary:

| Approach | Seed augmentation | Target property | Status |
|----------|------------------|-----------------|--------|
| DiscreteSuccSeed | `¬ψ ∨ ¬Gψ` (blocking) | Covering (no intermediates) | Axiomatized (consistency unproven) |
| Succ-based seed | `φ ∨ Fφ` (deferral) | F-step compliance | Consistency argument via DF + seriality |

The Succ-based approach avoids needing the covering property because F-step compliance is a weaker (and more tractable) condition than covering.

---

## 6. CanonicalR Recovery

**Proposition**. For MCSes u, v:
```
CanonicalR(u, v)  ↔  ∃ n ≥ 1, CanonicalTask(u, n, v)
```

**Forward (⇐)**: If `CanonicalTask(u, n, v)` for n ≥ 1, there is a Succ-chain u = w₀ →ˢ w₁ →ˢ ... →ˢ wₙ = v. Each step preserves G-content (Succ condition 1), and by temporal axiom 4 (`Gφ → GGφ`), g_content is transitive along chains. So `g_content(u) ⊆ v`.

**Backward (⇒)**: Given `g_content(u) ⊆ v`, we need to decompose this into a finite Succ-chain. Under discrete axioms with successor existence (Section 5), we can build a chain from u toward v. The bounded witness theorem (Section 3) guarantees that all F-obligations of u are resolved within finitely many steps. The chain terminates at v when all of v's formulas are reached.

*Note*: The backward direction is the harder direction and may require additional infrastructure (e.g., F-nesting depth arguments or well-foundedness of obligation resolution).

---

## 7. How This Bypasses the Covering Lemma

### 7.1 The Current Pipeline (Blocked)

```
MCSes  →  DiscreteTimelineElem (preorder)
       →  DiscreteTimelineQuot (linear order)
       →  [NEED: Icc finite]  →  LocallyFiniteOrder
       →  SuccOrder / PredOrder / IsSuccArchimedean
       →  ≃o ℤ  →  TaskFrame ℤ
```

The covering lemma is needed at step 3 to prove interval finiteness.

### 7.2 The Proposed Pipeline (Bypass)

```
MCSes  →  f_content / p_content (new, trivial)
       →  Succ relation (syntactic, on MCSes directly)
       →  CanonicalTask (inductive, on ℤ)
       →  TaskFrame ℤ (verify 3 axioms directly)
       →  BFMCS construction (Succ-chain FMCS)
       →  Truth lemma
       →  Discrete completeness
```

**What is bypassed**:
- DiscreteTimelineElem construction
- DiscreteTimelineQuot antisymmetrization
- Interval finiteness axiom
- LocallyFiniteOrder instance
- SuccOrder/PredOrder on the quotient
- Mathlib's ℤ characterization theorem

**What is gained**:
- Direct construction: Succ is defined on MCSes, no quotient needed
- F-step tracking: obligations are explicitly managed
- Simpler consistency argument: deferral seed vs. blocking seed
- No axioms: the construction is entirely derived from the proof system

### 7.3 What Remains to Prove

| Component | Difficulty | Notes |
|-----------|-----------|-------|
| Define f_content, p_content | Trivial | 2 lines each in TemporalContent.lean |
| Define Succ | Easy | Direct from g_content + f_content |
| Define CanonicalTask | Easy | Inductive on ℤ from Succ |
| Prove TaskFrame axioms | Moderate | Nullity/converse trivial; compositionality is chain concatenation |
| Successor existence | **Hard** | Seed consistency via DF; main proof obligation |
| Predecessor existence | **Hard** | Symmetric via DB |
| Succ-chain FMCS construction | **Hard** | Build time-indexed MCS family from Succ-chains |
| Truth lemma for F-case | **Moderate** | Uses F-step + bounded witness |
| Truth lemma for G-case | **Easy** | Uses G-persistence (same as current) |
| BFMCS modal coherence | **Moderate** | Cross-flag construction (same difficulty as current) |

---

## 8. Implementation Plan

### Phase 1: Infrastructure (Low Risk)

1. **Add f_content and p_content** to `TemporalContent.lean`
2. **Define Succ** in a new file `Theories/Bimodal/Metalogic/Bundle/SuccRelation.lean`
3. **Prove basic properties**: Succ implies CanonicalR, g/h duality for Succ pairs

### Phase 2: CanonicalTask Construction (Moderate Risk)

4. **Define CanonicalTask** in `Theories/Bimodal/Metalogic/Bundle/CanonicalTask.lean`
5. **Prove TaskFrame axioms** (nullity, compositionality, converse)
6. **Prove single-step forcing theorem**
7. **Prove bounded witness corollary**

### Phase 3: Existence Theorems (High Risk)

8. **Prove successor existence** under discrete axioms (seed consistency is the main challenge)
9. **Prove predecessor existence** (symmetric)
10. **Prove CanonicalR recovery** (both directions)

### Phase 4: Integration (Moderate Risk)

11. **Build Succ-chain FMCS** construction (time-indexed MCS family from Succ-chains)
12. **Instantiate truth lemma** with CanonicalTask as task_rel
13. **Complete discrete representation theorem** (unconditional)
14. **Remove discrete_Icc_finite_axiom** and DiscreteTimeline quotient construction

### Risk Assessment

The **critical risk** is Phase 3, step 8: proving that the deferral seed `g_content(u) ∪ { φ ∨ Fφ | Fφ ∈ u }` is consistent. This requires a careful argument using DF + seriality to show that no finite subset derives ⊥. The argument is analogous to the standard Lindenbaum construction but must handle the disjunctive form of the seed.

If the seed consistency proof proves intractable, we can fall back to axiomatizing successor existence (which is a weaker axiom than interval finiteness, and more mathematically transparent).

---

## 9. Relationship to Dense Case

The dense case (Report 05) uses a fundamentally different approach: `DenseTask(u, q, v) ⟺ e(tᵥ) - e(tᵤ) = q` via the Cantor isomorphism. This is because:

- Dense logic has no immediate successors (DenselyOrdered)
- Single-step forcing is vacuous (DN gives `Fφ → FFφ`, so `FFφ ∉ u` is unsatisfiable)
- The Succ relation is empty in dense models

The two approaches share the same architectural pattern (duration-precise three-place relation replacing duration-coarse CanonicalR) but are constructed differently:

| Aspect | Discrete (CanonicalTask) | Dense (DenseTask) |
|--------|--------------------------|-------------------|
| Atomic unit | Succ (single step) | Cantor isomorphism (global) |
| Duration type | ℤ (integers) | ℚ (rationals) |
| Construction | Inductive (chain of steps) | Direct (group operation) |
| Determinism | Non-deterministic | Deterministic |
| F-step role | Central (drives obligation resolution) | Absent (all F-obligations infinitely deferred) |

---

## 10. Summary

The Succ-based approach offers a clean bypass of the covering lemma by reframing the problem:

- **Old question**: "Does the DF axiom prevent intermediate MCSes?" (Structural; hard)
- **New question**: "Can we build an F-step-compliant successor?" (Constructive; tractable)

The Succ relation adds the F-step condition `f_content(u) ⊆ v ∪ f_content(v)` to the existing G-persistence condition `g_content(u) ⊆ v`. This single addition enables:

1. **Single-step forcing**: F-obligations with nesting depth 1 must resolve at the next step
2. **Bounded witness**: All F-obligations resolve within bounded chain length
3. **Direct TaskFrame construction**: No quotient type or interval finiteness needed
4. **CanonicalR recovery**: The existing relation is the transitive closure of Succ

The main proof obligation shifts from "no intermediates exist" (covering lemma) to "the deferral seed is consistent" (successor existence), which is a more natural target for DF-based reasoning.
