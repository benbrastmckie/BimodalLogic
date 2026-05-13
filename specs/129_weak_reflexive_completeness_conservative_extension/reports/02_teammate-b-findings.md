# Teammate B Findings: Infrastructure Audit and Alternative Approaches

- **Task**: 129 - weak_reflexive_completeness_conservative_extension
- **Angle**: Infrastructure audit, reusability analysis, alternative approaches
- **Date**: 2026-05-13

## Key Findings

1. **MCS infrastructure is fully reusable without modification.** `SetMaximalConsistent`, `set_lindenbaum`, and all MCS closure properties are defined over the *single* axiom system (the `Axiom` inductive type) but through `DerivationTree` which is the *only* proof system. The weak system does NOT need a separate axiom set or proof infrastructure — it is a conservative extension view of the same axiom system, since every weak axiom is *derivable* as a strict theorem.

2. **The critical realization: there is no "weak axiom system" to build.** The existing `Axiom` type already contains everything needed. G_w(φ) := φ ∧ Gφ, F_w(φ) := φ ∨ Fφ, etc. are *definitional abbreviations* on `Formula`. The "weak axiom" G_w(φ) → φ is just the propositional tautology (φ ∧ Gφ) → φ, provable from `prop_k`/`prop_s`. No new axiom constructors, no new derivation trees.

3. **The sorry site has a very specific signature.** `limitDomSubtype_isSuccArchimedean` takes `(A : Set Formula) (h_mcs : SetMaximalConsistent A) (h_discrete : ∀ x ∈ limit_dom A h_mcs, next_top ∈ limit_f A h_mcs x)` and produces `@IsSuccArchimedean (LimitDomSubtype A h_mcs) _ (limitDomSubtype_succOrder A h_mcs h_discrete)`. **However**, closing this sorry is NOT the right integration point. The actual goal should be proving `valid_discrete φ → Nonempty (DerivationTree [] φ)` directly via the Doets construction, bypassing the chronicle machinery entirely.

4. **Doets Section 4 (complete orderings) is the correct template, not Section 3.** Section 3 handles ω via definable induction (requires a least element). For Z (= ω* + ω, no least element), Section 4's condensation argument is needed. The analogue of "definable completeness" for Z is exactly what Z1 gives: every definable bounded set has a maximum.

5. **The `truth_at` definition uses STRICT semantics (< not ≤).** Lines 125-130 of Truth.lean: `all_future` uses `t < s`, `all_past` uses `s < t`, `untl` uses `t < s` for the witness and `t < r → r < s` for the guard. The weak operators must be defined to interpret reflexively *at the formula level* (G_w φ = φ ∧ Gφ), not by modifying `truth_at`.

---

## Infrastructure Audit

### 1. MaximalConsistent Infrastructure

**File**: `Metalogic/Core/MaximalConsistent.lean` (~523 lines)

| Definition | Type | Reusability |
|------------|------|-------------|
| `SetConsistent S` | `∀ L : List Formula, (∀ φ ∈ L, φ ∈ S) → Consistent L` | **Direct reuse** |
| `SetMaximalConsistent S` | `SetConsistent S ∧ ∀ φ, φ ∉ S → ¬SetConsistent (insert φ S)` | **Direct reuse** |
| `set_lindenbaum` | `SetConsistent S → ∃ M, S ⊆ M ∧ SetMaximalConsistent M` | **Direct reuse** |
| `theorem_in_mcs` | `SetMaximalConsistent S → ([] ⊢ φ) → φ ∈ S` | **Direct reuse** |

**Key observation**: `SetConsistent` is defined via `Consistent L = ¬Nonempty (DerivationTree L Formula.bot)`. Since `DerivationTree` includes *all* axioms (including Z1, Prior-UZ/SZ), **any MCS produced by `set_lindenbaum` contains all theorems of the full system**. There is no need to define a separate "weak MCS." The weak canonical model uses the same MCS notion — the only difference is how we interpret G_w/H_w membership.

**File**: `Metalogic/Core/MCSProperties.lean` (~362 lines)

| Theorem | Reusability |
|---------|-------------|
| `closed_under_derivation` | **Direct reuse** |
| `implication_property` | **Direct reuse** |
| `negation_complete` | **Direct reuse** |
| `all_future_all_future` (Gφ ∈ S → GGφ ∈ S) | **Direct reuse** |
| `all_past_all_past` (Hφ ∈ S → HHφ ∈ S) | **Direct reuse** |
| `set_consistent_not_both` | **Direct reuse** |
| `neg_excludes` | **Direct reuse** |

**File**: `Metalogic/Completeness.lean` (~528 lines, modal MCS properties)

| Theorem | Reusability |
|---------|-------------|
| `conjunction_intro`, `conjunction_elim`, `conjunction_iff` | **Direct reuse** |
| `disjunction_intro`, `disjunction_elim`, `disjunction_iff` | **Direct reuse** |
| `box_closure`, `box_box` | **Direct reuse** |
| `diamond_box_duality` | **Direct reuse** |

### 2. Proof System

**File**: `ProofSystem/Axioms.lean` (431 lines, 41 axiom constructors)

The `Axiom` inductive type includes:
- Propositional (4): prop_k, prop_s, ex_falso, peirce
- S5 Modal (5): modal_t, modal_4, modal_b, modal_5_collapse, modal_k_dist
- BX Temporal (26): including temp_k_dist, temp_4, serial_future/past, Until/Since axioms
- Uniformity (4): discrete_symm_fwd/bwd, discrete_propagate_fwd/bwd
- Prior (2): prior_UZ, prior_SZ
- **Z1** (1): `z1 φ = G(Gφ→φ) → (FGφ→Gφ)`

**File**: `ProofSystem/Derivation.lean` (7 rules: axiom, assumption, modus_ponens, necessitation, temporal_necessitation, temporal_duality, weakening)

**Reusability**: **Direct reuse for everything.** The weak canonical model uses the *same* derivation system. The weak operators are definitional abbreviations, not a new layer.

### 3. Existing Canonical Models

**File**: `BXCanonical/CanonicalModel.lean` — builds an Int-indexed chain of MCS via `fwd_succ`/`bwd_succ` using `g_content`/`h_content` and schedule-based resolution.

**Reusability**: **Inspiration only.** The weak canonical model does NOT build an indexed chain. It uses the *set of all MCS* as the domain (standard Henkin construction). The existing chain construction is specific to the irreflexive chronicle approach.

**File**: `Bundle/WitnessSeed.lean` — `forward_temporal_witness_seed`, `g_content`, `h_content`

| Definition | Reusability |
|------------|-------------|
| `g_content M = {φ \| Gφ ∈ M}` | **Direct reuse** (defines the canonical temporal relation) |
| `h_content M = {φ \| Hφ ∈ M}` | **Direct reuse** |
| `forward_temporal_witness_seed M ψ = {ψ} ∪ g_content M` | **Parametric reuse** (for the weak truth lemma G_w backward direction) |
| `forward_temporal_witness_seed_consistent` | **Parametric reuse** (adaptable for weak G_w backward) |

### 4. Frame Semantics

**File**: `Semantics/Truth.lean` — `truth_at` with **strict** `<` for temporal operators

| Definition | Reusability |
|------------|-------------|
| `truth_at` | **Direct reuse** — the strict semantics is the target. The weak model is a proof *technique*; the final countermodel uses strict truth. |

**File**: `Semantics/Validity.lean`

| Definition | Relevant Properties |
|------------|---------------------|
| `valid_discrete φ` | Quantifies over `D` with `SuccOrder D`, `PredOrder D`, `IsSuccArchimedean D`, `IsPredArchimedean D`, `Nontrivial D` |
| `valid_dense φ` | Uses `DenselyOrdered D` |

**Key**: The completeness theorem needs to prove `valid_discrete φ → Nonempty (DerivationTree [] φ)`. The Doets construction produces a countermodel on ℤ with strict `<`, which satisfies all the `valid_discrete` frame conditions.

### 5. The Sorry Site

**File**: `ChronicleToCountermodel.lean` lines 1893-1909

```lean
noncomputable def limitDomSubtype_isSuccArchimedean
    (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (h_discrete : ∀ x ∈ limit_dom A h_mcs, next_top ∈ limit_f A h_mcs x) :
    @IsSuccArchimedean (LimitDomSubtype A h_mcs)
      inferInstance
      (limitDomSubtype_succOrder A h_mcs h_discrete) :=
  ...sorry (via succ_cofinal at line 1885)
```

This takes a `SetMaximalConsistent A` from the chronicle construction and needs to prove `IsSuccArchimedean` on the `LimitDomSubtype`. The sorry is at `succ_cofinal` (line 1885), which needs to show that the successor orbit from any point reaches any larger point.

**Integration analysis**: The Doets approach does NOT close this sorry directly. Instead, it provides an *alternative completeness proof* that bypasses the chronicle construction entirely. The integration should be at the `bx_completeness` level (or a new `discrete_completeness` theorem), not at the `limitDomSubtype_isSuccArchimedean` level.

**However**, if the plan requires closing this specific sorry (as stated in Phase 7), the integration would need to show that whenever we have a `SetMaximalConsistent A` with the discrete hypothesis, the domain carries `IsSuccArchimedean`. This is structurally different from what the Doets construction directly provides.

---

## Reusability Matrix

| Component | Classification | Notes |
|-----------|---------------|-------|
| `SetMaximalConsistent` | **Direct reuse** | Core type, unchanged |
| `set_lindenbaum` | **Direct reuse** | Produces MCS for weak canonical domain |
| `SetConsistent` | **Direct reuse** | Same derivation system |
| MCS closure properties (all 12+) | **Direct reuse** | All proofs go through `DerivationTree` |
| `DerivationTree` | **Direct reuse** | Single proof system for everything |
| `Axiom` type (41 constructors) | **Direct reuse** | Includes Z1, Prior-UZ/SZ — no new axioms needed |
| `truth_at` | **Direct reuse** | Strict semantics is the target |
| `valid_discrete` | **Direct reuse** | The completeness theorem's LHS |
| `g_content` / `h_content` | **Direct reuse** | Defines canonical temporal relation |
| `forward_temporal_witness_seed_consistent` | **Parametric reuse** | Adapt for weak G_w backward |
| `neg_consistent_of_not_derivable` | **Direct reuse** | Entry point for contrapositive argument |
| `BXCanonical/CanonicalModel.lean` chain | **Inspiration only** | Different construction pattern |
| `RestrictedMCS` | **Irrelevant** | For finite model property, not Henkin |
| `Algebraic/LindenbaumQuotient.lean` | **Irrelevant** | Provable equivalence quotient, not MCS quotient |

---

## Alternative Approaches Analysis

### 1. Doets Section 3 (ω) vs Section 4 (complete orderings)

**Section 3** proves: if (M,<) satisfies definable induction and is 3-equivalent to ω, then M has n-equivalents of order type ω.

**Adaptation for Z**: Z = ω* + ω has no least element, so definable induction does not directly apply. One could split Z into the negative part (ω*) and positive part (ω) and handle each half, but this requires careful bookkeeping at the junction point.

**Section 4** proves: if M is definably complete, then M has complete n-equivalents. Via Lemma 4.3, this covers well-orderings (completeness + least element + immediate successors). For Z, "definable completeness" maps to Z1: every definable bounded-above set has a maximum.

**Verdict**: Section 4 is the correct template. Section 3 would require non-trivial adaptation for the bidirectional (Z not ω) case and is not simpler.

**Confidence**: High.

### 2. Direct Henkin Model on Z

Could we directly build a canonical model indexed by Z (one MCS per integer)?

The standard Henkin canonical model has *one MCS per point*, with the set of *all* MCS as the domain. The domain cardinality is 2^|Formula| (continuum), not countable. You cannot directly index by Z.

The Doets compression is precisely the mechanism that reduces the uncountable canonical model to a Z-indexed countermodel. This is not a step that can be skipped.

**Verdict**: Not viable. The Doets compression (or equivalent) is necessary.

**Confidence**: High.

### 3. Quotient-Only Approach

Could we just quotient the reflexive canonical model by `~` (mutual accessibility) and show the quotient is isomorphic to Z?

The quotient of the canonical preorder by mutual accessibility gives a *strict linear order*. But this order has order type up to 2^|Formula| — not Z in general. The quotient eliminates reflexive pairs but doesn't control the cardinality or order type.

The expansion + compression steps (Doets Claims 9-11 / Theorem 4.1 Claims 1-4) are what reduce the order type. Without them, you have a strict linear order but not one isomorphic to Z.

**Verdict**: Not viable without the full compression pipeline.

**Confidence**: High.

### 4. Reuse of Algebraic/LindenbaumQuotient.lean

The Lindenbaum quotient `Formula / ProvEquiv` is a quotient of *formulas* by provable equivalence. The Doets quotient is a quotient of *MCS (model points)* by mutual accessibility. These are entirely different mathematical objects.

**Verdict**: No reusability.

**Confidence**: High.

### 5. FMP-Based Approach

The FMP (finite model property) is sorry-free and gives: every satisfiable formula has a finite countermodel. Could we use this for discrete completeness?

FMP gives finite countermodels, but finite linear orders are not necessarily isomorphic to Z or any IsSuccArchimedean frame. A finite linear order {1,...,n} has boundaries (no predecessor for 1, no successor for n), violating the seriality axioms under strict semantics. The FMP countermodels use filtrations which may not preserve discrete frame conditions.

**However**, there's an interesting secondary approach: FMP + transfer. If φ has a finite countermodel, it has a countermodel on some {1,...,n}. We could embed this into Z. But the FMP doesn't directly give countermodels satisfying IsSuccArchimedean or the Prior axioms.

**Verdict**: Not directly viable for discrete completeness. FMP handles a different frame class.

**Confidence**: High.

---

## Recommended Module Structure

Based on the audit, the new code can be surprisingly lean because almost all MCS infrastructure is reused unchanged.

### New Files

| File | Purpose | Est. Lines | Dependencies |
|------|---------|-----------|-------------|
| `Metalogic/WeakCanonical/WeakOperators.lean` | Define G_w, H_w, F_w, P_w as Formula abbreviations; prove semantic characterization under reflexive interpretation | ~120 | `Syntax.Formula`, `Semantics.Truth` |
| `Metalogic/WeakCanonical/WeakAxioms.lean` | Prove weak axioms are strict theorems: G_w(φ)→φ, weak K, weak Z1, etc. | ~250 | `ProofSystem`, `WeakOperators` |
| `Metalogic/WeakCanonical/WeakCanonicalModel.lean` | Domain = all MCS; relation x R y ↔ g_content(x) ⊆ y; prove R is reflexive preorder (from G_w(φ)→φ being a theorem), linear (from BX11) | ~200 | `Core.MaximalConsistent`, `Core.MCSProperties`, `WeakOperators`, `WeakAxioms`, `Bundle.TemporalContent` |
| `Metalogic/WeakCanonical/WeakTruthLemma.lean` | Truth lemma: φ ∈ x ↔ truth holds at x (using *weak* interpretation for G/H, standard for others). Forward/backward for each connective. | ~500 | `WeakCanonicalModel`, all MCS properties |
| `Metalogic/WeakCanonical/NCharacteristic.lean` | n-characteristic (propositional type at bounded depth); finiteness; equivalence preservation | ~300 | `Syntax.Formula` |
| `Metalogic/WeakCanonical/DoetsCompression.lean` | Full pipeline: quotient → expansion → Z1 compression → Z countermodel. Follows Doets 1989 §4 Claims 1-4 adapted for Z1. | ~600 | `WeakCanonicalModel`, `WeakTruthLemma`, `NCharacteristic` |
| `Metalogic/WeakCanonical/Transfer.lean` | Contrapositive argument: ¬provable → ¬φ consistent → weak MCS → Doets compression → Z countermodel → ¬valid_discrete | ~100 | `DoetsCompression`, `Semantics.Validity`, `BXCanonical.Completeness` (for neg_consistent_of_not_derivable) |
| `Metalogic/WeakCanonical/Integration.lean` | Wire transfer theorem to close the sorry or provide alternative completeness entry point | ~80 | `Transfer`, `ChronicleToCountermodel` |
| `Metalogic/WeakCanonical.lean` | Root import file | ~15 | all above |

**Total estimated**: ~2165 lines

### Files to Modify

| File | Modification | Est. Changes |
|------|-------------|-------------|
| `Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` | Replace sorry at `succ_cofinal` (line 1885) with call to integration wrapper, OR: add alternative completeness path | ~10 lines |
| `Metalogic/Metalogic.lean` | Add import for `WeakCanonical` | 1 line |

### Key Observation on Integration

The plan says Phase 7 "closes the sorry at `limitDomSubtype_isSuccArchimedean`." But this sorry lives *inside* the chronicle construction. The Doets approach produces a Z-countermodel via a completely different path. The clean integration is:

**Option A (Targeted)**: Prove that any `SetMaximalConsistent A` with the discrete hypothesis has `IsSuccArchimedean` on its limit domain. This would require showing the Doets pipeline applies to the chronicle's limit domain specifically.

**Option B (Bypass)**: Add a new discrete completeness theorem `discrete_completeness_doets` that goes directly from `valid_discrete φ → Nonempty (DerivationTree [] φ)` via the Doets construction, replacing the chronicle path. Mark the old chronicle sorry as dead code.

**Option B is cleaner** and avoids coupling the Doets construction to the chronicle's internal types (`LimitDomSubtype`, `limit_dom`, `limit_f`). The chronicle construction was designed for a different approach; retrofitting the Doets result into it adds unnecessary complexity.

---

## Integration Requirements (Sorry Site Specifics)

### Current Sorry Chain

```
bx_completeness (wanted: sorry-free)
  └── dd_countermodel_chronicle_discrete (sorry-free IF limitDomSubtype_isSuccArchimedean is)
       └── limitDomSubtype_isSuccArchimedean (SORRY via succ_cofinal)
            └── succ_cofinal (SORRY at line 1885)
```

### Integration with Option B

```
discrete_completeness_doets (new, sorry-free via Doets)
  └── Uses set_lindenbaum + WeakTruthLemma + DoetsCompression + Transfer

bx_completeness
  └── Delegates discrete case to discrete_completeness_doets
  └── Dense case: dd_countermodel_chronicle_dense (already sorry-free)
```

The old `limitDomSubtype_isSuccArchimedean` sorry becomes dead code, archivable via Task 130.

---

## Confidence Levels

| Section | Confidence | Notes |
|---------|------------|-------|
| Infrastructure Audit | **High** | Read every relevant file; types and signatures verified |
| Reusability Matrix | **High** | Classification based on actual type signatures |
| Alternative Approaches | **High** | Each ruled out on mathematical grounds |
| Module Structure | **Medium** | Line estimates uncertain; DoetsCompression could be 400-800 |
| Integration (Option B) | **Medium** | Requires understanding how `bx_completeness` dispatches dense vs discrete. Need to verify the top-level completeness theorem structure allows this. |
| Sorry Site Analysis | **High** | Exact signature read from source |
