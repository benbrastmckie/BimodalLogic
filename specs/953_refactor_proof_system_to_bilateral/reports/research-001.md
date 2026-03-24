# Research Report: Task #953 (research-001) -- Refactoring the Proof System to a Bilateral System

**Task**: 953 - Refactor proof system to bilateral system
**Date**: 2026-03-03
**Effort**: High (major architectural refactoring of proof system and all downstream modules)
**Dependencies**: None (foundational refactoring)
**Sources/Inputs**: Bimodal/ProofSystem/Axioms.lean, Bimodal/ProofSystem/Derivation.lean, Bimodal/Syntax/Formula.lean, Bimodal/Metalogic/Decidability/SignedFormula.lean, Bimodal/Metalogic/ (completeness infrastructure), Bimodal/Semantics/ (truth evaluation)
**Artifacts**: This report
**Standards**: report-format.md

---

## 1. Executive Summary

This report details how to refactor the current **unilateral** proof system for TM logic into a **bilateral** system. A bilateral proof system operates with two primitive speech acts — **assertion** (acceptance) and **denial** (rejection) — rather than deriving rejection from assertion via negation-as-implication-to-bottom.

**Principal Findings**:

1. **The current system is unilateral.** Derivations have the form `Γ ⊢ φ`, meaning "φ is derivable (assertible) from context Γ." Rejection is encoded indirectly: `Γ ⊢ φ → ⊥` means "φ leads to absurdity from Γ." There is no primitive notion of rejection.

2. **A bilateral system would introduce dual judgments.** The fundamental types become `Γ ⊢⁺ φ` ("φ is accepted from Γ") and `Γ ⊢⁻ φ` ("φ is rejected from Γ"), with rules governing how acceptance and rejection interact across all connectives and operators.

3. **The existing signed formula infrastructure provides a prototype.** The `Sign` type (`pos`/`neg`) and `SignedFormula` in `Decidability/SignedFormula.lean` already implement a bilateral concept for the tableau procedure. The refactoring extends this duality from the decision procedure into the proof system itself.

4. **Negation becomes eliminable.** In a bilateral system, `¬φ` can be reinterpreted: "φ is rejected" replaces "φ implies absurdity." Bottom (`⊥`) transitions from a primitive connective to a definable concept (the formula that is always rejected and never accepted). This fundamentally changes the formula type.

5. **The refactoring has a large blast radius.** Every module that depends on `DerivationTree`, `Axiom`, or `Formula` will require updates: soundness, completeness (BFMCS, FMCS, MCS infrastructure), the deduction theorem, generalized necessitation, all derived theorems, and the decidability procedure.

**Recommendation**: Implement in four phases: (1) bilateral formula and judgment types, (2) bilateral proof rules and axioms, (3) bilateral metalogic (soundness, completeness, MCS), (4) decidability and derived theorems.

---

## 2. Current Architecture Analysis

### 2.1 Formula Type (Syntax/Formula.lean)

The current formula type has **6 primitive constructors**:

```lean
inductive Formula : Type where
  | atom : String → Formula          -- Propositional variable
  | bot : Formula                     -- Bottom (⊥)
  | imp : Formula → Formula → Formula -- Implication (→)
  | box : Formula → Formula           -- Modal necessity (□)
  | all_past : Formula → Formula      -- Universal past (H)
  | all_future : Formula → Formula    -- Universal future (G)
```

**Derived operators**:
- `neg φ = φ.imp bot` — negation via implication-to-bottom
- `and φ ψ = (φ.imp ψ.neg).neg` — conjunction via double negation
- `or φ ψ = φ.neg.imp ψ` — disjunction via implication
- `diamond φ = φ.neg.box.neg` — possibility via duality
- `some_past φ = φ.neg.all_past.neg` — existential past (P)
- `some_future φ = φ.neg.all_future.neg` — existential future (F)

**Key observation**: ALL derived operators go through negation, which goes through `imp` and `bot`. In a bilateral system, many of these can be given direct bilateral characterizations without this encoding.

### 2.2 Derivation System (ProofSystem/Derivation.lean)

The current system has **7 inference rules**:

| Rule | Signature | Bilateral Analog |
|------|-----------|-----------------|
| `axiom` | `Axiom φ → Γ ⊢ φ` | Split into acceptance axioms and rejection axioms |
| `assumption` | `φ ∈ Γ → Γ ⊢ φ` | Split into `φ⁺ ∈ Γ → Γ ⊢⁺ φ` and `φ⁻ ∈ Γ → Γ ⊢⁻ φ` |
| `modus_ponens` | `Γ ⊢ φ→ψ, Γ ⊢ φ → Γ ⊢ ψ` | Acceptance modus ponens + rejection modus tollens |
| `necessitation` | `⊢ φ → ⊢ □φ` | `⊢⁺ φ → ⊢⁺ □φ` (acceptance only) |
| `temporal_necessitation` | `⊢ φ → ⊢ Gφ` | `⊢⁺ φ → ⊢⁺ Gφ` (acceptance only) |
| `temporal_duality` | `⊢ φ → ⊢ swap(φ)` | Applies to both acceptance and rejection |
| `weakening` | `Γ ⊢ φ, Γ⊆Δ → Δ ⊢ φ` | Applies to both `⊢⁺` and `⊢⁻` |

### 2.3 Axiom System (ProofSystem/Axioms.lean)

The current system has **18 axiom schemata** across 4 categories:
- **Propositional** (4): `prop_k`, `prop_s`, `ex_falso`, `peirce`
- **S5 Modal** (5): `modal_t`, `modal_4`, `modal_b`, `modal_5_collapse`, `modal_k_dist`
- **Temporal** (6): `temp_k_dist`, `temp_4`, `temp_a`, `temp_l`, `temp_t_future`, `temp_t_past`
- **Modal-Temporal** (2): `modal_future`, `temp_future`
- **Linearity** (1): `temp_linearity`

### 2.4 Existing Bilateral Concepts (Decidability/SignedFormula.lean)

The tableau procedure already uses signed formulas:

```lean
inductive Sign : Type where
  | pos : Sign    -- Formula asserted true
  | neg : Sign    -- Formula asserted false

structure SignedFormula where
  sign : Sign
  formula : Formula
```

The tableau expansion rules already define bilateral behavior for each connective:
- **T(φ → ψ)**: Branch into F(φ) or T(ψ) — acceptance of implication
- **F(φ → ψ)**: Linear: T(φ) and F(ψ) — rejection of implication
- **T(□φ)**: T(φ) at all accessible worlds — acceptance of necessity
- **F(□φ)**: F(φ) at some accessible world — rejection of necessity

These rules are precisely what a bilateral proof system formalizes as inference rules rather than search procedures.

---

## 3. Design of the Bilateral System

### 3.1 Bilateral Formula Type

The bilateral approach requires deciding whether to change the formula type or keep it and add a judgment layer. Two options:

**Option A: Keep Formula, Add Bilateral Judgments**

```lean
-- Formula stays the same (including bot and imp)
-- Add bilateral judgment type
inductive Judgment : Type where
  | accept : Context → Formula → Judgment  -- Γ ⊢⁺ φ
  | reject : Context → Formula → Judgment  -- Γ ⊢⁻ φ
```

**Advantage**: Minimal disruption to syntax layer. Formula complexity, countability, swap_temporal all preserved.
**Disadvantage**: The bilateral structure lives in the proof system, not the syntax. Derived operators still go through negation-as-implication.

**Option B: Pure Bilateral Formulas (Remove Bot)**

```lean
inductive Formula : Type where
  | atom : String → Formula
  | imp : Formula → Formula → Formula
  | box : Formula → Formula
  | all_past : Formula → Formula
  | all_future : Formula → Formula
  -- No bot! Rejection is a primitive judgment, not a formula constructor.
```

**Advantage**: Cleaner bilateral design. No need for `ex_falso` axiom — rejection of absurdity is built into the judgment structure.
**Disadvantage**: Massive refactoring. Every reference to `Formula.bot`, `Formula.neg`, and derived operators must change. The formula type loses a constructor, breaking all pattern matches.

**Recommendation: Option A** (keep Formula, add bilateral judgments). This allows incremental refactoring and preserves the existing formula infrastructure while adding bilateral structure at the proof system level. Bottom and negation remain as formula constructors but gain bilateral characterization through the proof rules.

### 3.2 Bilateral Contexts

A bilateral context contains both accepted and rejected formulas:

```lean
-- A signed context entry
structure SignedAssumption where
  sign : Sign
  formula : Formula

-- Bilateral context
def BilateralContext := List SignedAssumption
```

Alternatively, use a pair of contexts:

```lean
-- Γ⁺ = accepted formulas, Γ⁻ = rejected formulas
structure BilateralContext where
  accepted : List Formula
  rejected : List Formula
```

The pair-of-contexts approach is cleaner for most metalogic because it avoids pattern matching on signs in context operations.

### 3.3 Bilateral Derivation Rules

The bilateral derivation tree has two judgment forms:

```lean
inductive BilateralDeriv : BilateralContext → Formula → Sign → Type where
  -- === STRUCTURAL RULES ===
  | accept_assumption (Γ : BilateralContext) (φ : Formula)
      (h : φ ∈ Γ.accepted) : BilateralDeriv Γ φ .pos
  | reject_assumption (Γ : BilateralContext) (φ : Formula)
      (h : φ ∈ Γ.rejected) : BilateralDeriv Γ φ .neg

  -- === IMPLICATION RULES ===
  -- Accept imp: If accepting φ leads to accepting ψ, accept φ → ψ
  | accept_imp (Γ : BilateralContext) (φ ψ : Formula)
      (d : BilateralDeriv (Γ.addAccepted φ) ψ .pos) : BilateralDeriv Γ (φ.imp ψ) .pos
  -- Reject imp: Accept φ and reject ψ to reject φ → ψ
  | reject_imp (Γ : BilateralContext) (φ ψ : Formula)
      (d1 : BilateralDeriv Γ φ .pos)
      (d2 : BilateralDeriv Γ ψ .neg) : BilateralDeriv Γ (φ.imp ψ) .neg
  -- Modus ponens: Accept φ → ψ and accept φ, then accept ψ
  | modus_ponens (Γ : BilateralContext) (φ ψ : Formula)
      (d1 : BilateralDeriv Γ (φ.imp ψ) .pos)
      (d2 : BilateralDeriv Γ φ .pos) : BilateralDeriv Γ ψ .pos
  -- Modus tollens: Accept φ → ψ and reject ψ, then reject φ
  | modus_tollens (Γ : BilateralContext) (φ ψ : Formula)
      (d1 : BilateralDeriv Γ (φ.imp ψ) .pos)
      (d2 : BilateralDeriv Γ ψ .neg) : BilateralDeriv Γ φ .neg

  -- === BOTTOM RULES ===
  -- Reject bot: Bottom is always rejected (replaces ex_falso)
  | reject_bot (Γ : BilateralContext) : BilateralDeriv Γ .bot .neg
  -- Explosion: Accept φ and reject φ yields accept ψ (coordination principle)
  | explosion (Γ : BilateralContext) (φ ψ : Formula)
      (d1 : BilateralDeriv Γ φ .pos)
      (d2 : BilateralDeriv Γ φ .neg) : BilateralDeriv Γ ψ .pos

  -- === CLASSICAL COORDINATION ===
  -- Smilean reductio (bilateral Peirce):
  -- If rejecting φ leads to accepting φ, then accept φ
  | reductio (Γ : BilateralContext) (φ : Formula)
      (d : BilateralDeriv (Γ.addRejected φ) φ .pos) : BilateralDeriv Γ φ .pos
  -- Dual reductio: If accepting φ leads to rejecting φ, then reject φ
  | dual_reductio (Γ : BilateralContext) (φ : Formula)
      (d : BilateralDeriv (Γ.addAccepted φ) φ .neg) : BilateralDeriv Γ φ .neg

  -- === MODAL RULES ===
  -- Accept box: Accept φ from empty bilateral context → Accept □φ
  | accept_box (φ : Formula)
      (d : BilateralDeriv ⟨[], []⟩ φ .pos) : BilateralDeriv ⟨[], []⟩ (.box φ) .pos
  -- Reject box: Reject □φ iff accept ◇¬φ (via reject diamond)
  -- Alternative: Reject □φ if reject φ is consistent
  | reject_box_from_reject (Γ : BilateralContext) (φ : Formula)
      (d : BilateralDeriv Γ φ .neg) : BilateralDeriv Γ (.box φ) .neg
  -- Accept box elimination (Modal T): Accept □φ → Accept φ
  | accept_box_elim (Γ : BilateralContext) (φ : Formula)
      (d : BilateralDeriv Γ (.box φ) .pos) : BilateralDeriv Γ φ .pos

  -- === TEMPORAL RULES ===
  -- Accept all_future: Accept φ from empty context → Accept Gφ
  | accept_future (φ : Formula)
      (d : BilateralDeriv ⟨[], []⟩ φ .pos) : BilateralDeriv ⟨[], []⟩ (.all_future φ) .pos
  -- Accept future elimination (Temporal T): Accept Gφ → Accept φ
  | accept_future_elim (Γ : BilateralContext) (φ : Formula)
      (d : BilateralDeriv Γ (.all_future φ) .pos) : BilateralDeriv Γ φ .pos
  -- Reject all_future: Reject Gφ iff accept Fφ (some future where φ fails)
  | reject_future (Γ : BilateralContext) (φ : Formula)
      (d : BilateralDeriv Γ φ .neg) : BilateralDeriv Γ (.all_future φ) .neg
  -- Past analogs via temporal duality
  | temporal_duality (φ : Formula) (s : Sign)
      (d : BilateralDeriv ⟨[], []⟩ φ s) : BilateralDeriv ⟨[], []⟩ φ.swap_past_future s

  -- === WEAKENING ===
  | weakening (Γ Δ : BilateralContext) (φ : Formula) (s : Sign)
      (d : BilateralDeriv Γ φ s)
      (h : Γ ⊆ Δ) : BilateralDeriv Δ φ s
```

### 3.4 Bilateral Axiom Schemata

Each current axiom becomes a bilateral acceptance axiom. Some gain rejection duals:

| Current Axiom | Bilateral Form | Status |
|---|---|---|
| `prop_k` | `⊢⁺ (φ→(ψ→χ))→((φ→ψ)→(φ→χ))` | Acceptance axiom (unchanged) |
| `prop_s` | `⊢⁺ φ→(ψ→φ)` | Acceptance axiom (unchanged) |
| `ex_falso` | `⊢⁻ ⊥` (reject bot rule) | Becomes a structural rule |
| `peirce` | `reductio` rule (bilateral structural) | Becomes a structural rule |
| `modal_t` | `accept_box_elim` rule | Becomes a structural rule |
| `modal_4` | `⊢⁺ □φ → □□φ` | Acceptance axiom (unchanged) |
| `modal_b` | `⊢⁺ φ → □◇φ` | Acceptance axiom |
| `modal_5_collapse` | `⊢⁺ ◇□φ → □φ` | Acceptance axiom |
| `modal_k_dist` | `⊢⁺ □(φ→ψ)→(□φ→□ψ)` | Acceptance axiom (unchanged) |
| `temp_k_dist` | `⊢⁺ G(φ→ψ)→(Gφ→Gψ)` | Acceptance axiom (unchanged) |
| `temp_4` | `⊢⁺ Gφ → GGφ` | Acceptance axiom (unchanged) |
| `temp_a` | `⊢⁺ φ → GPφ` | Acceptance axiom |
| `temp_l` | `⊢⁺ △φ → GHφ` | Acceptance axiom |
| `temp_t_future` | `accept_future_elim` rule | Becomes a structural rule |
| `temp_t_past` | `accept_past_elim` rule | Becomes a structural rule |
| `modal_future` | `⊢⁺ □φ → □Gφ` | Acceptance axiom |
| `temp_future` | `⊢⁺ □φ → G□φ` | Acceptance axiom |
| `temp_linearity` | Acceptance axiom | Unchanged |

**Key simplification**: Several current axioms become structural rules in the bilateral system. The bilateral rules for implication, bottom, and reflexivity (T-axioms) absorb `ex_falso`, `peirce`, `modal_t`, `temp_t_future`, and `temp_t_past`.

---

## 4. Impact Analysis: Downstream Modules

### 4.1 Metalogic: MCS and Lindenbaum

**Current MCS definition** (MaximalConsistent.lean):
- `SetConsistent S` = `¬ (list_from_S ⊢ ⊥)` — no derivation of bottom from S
- `SetMaximalConsistent S` = consistent + maximal (for every φ, either φ ∈ S or ¬φ ∈ S)

**Bilateral MCS definition**:
- `BilateralConsistent (S⁺, S⁻)` = no formula φ with both `S⁺ ⊢⁺ φ` and `S⁻ ⊢⁻ φ` in the signed context
- `BilateralMaximal (S⁺, S⁻)` = for every φ, either φ ∈ S⁺ or φ ∈ S⁻ (accepted or rejected)

**Lindenbaum's lemma** adapts: extend a bilateral-consistent set to a bilateral-maximal one by, for each formula, placing it in S⁺ or S⁻ while preserving bilateral consistency.

### 4.2 Metalogic: FMCS and BFMCS

**FMCS** (Family of MCS indexed by time):
- Currently: `mcs : D → Set Formula` (unilateral MCS at each time)
- Bilateral: `mcs : D → Set Formula × Set Formula` (accepted/rejected pair at each time)

**Forward/backward coherence**:
- Currently: `G(φ) ∈ mcs(t) → φ ∈ mcs(t')` for t ≤ t'
- Bilateral: `G(φ) ∈ mcs(t).accepted → φ ∈ mcs(t').accepted` (acceptance propagates forward)
- Plus: `G(φ) ∈ mcs(t).rejected → ∃ t' ≥ t, φ ∈ mcs(t').rejected` (rejection of G means some future rejects φ)

**BFMCS modal coherence**:
- Currently: `□φ ∈ fam.mcs(t) → ∀ fam', φ ∈ fam'.mcs(t)`
- Bilateral acceptance: `□φ ∈ fam.mcs(t).accepted → ∀ fam', φ ∈ fam'.mcs(t).accepted`
- Bilateral rejection: `□φ ∈ fam.mcs(t).rejected → ∃ fam', φ ∈ fam'.mcs(t).rejected`

### 4.3 Semantics: Truth Evaluation

**Current truth_at** (Truth.lean):
- `truth_at M Omega τ t φ : Prop` — φ is true at world-history τ, time t

**Bilateral semantics**:
- `accepts M Omega τ t φ : Prop` — φ is accepted (= truth_at, same as current)
- `rejects M Omega τ t φ : Prop` — φ is rejected (= ¬ truth_at, for classical bilateral)

In a classical bilateral system, `rejects` is simply the complement of `accepts`. The bilateral structure is thus **proof-theoretic** rather than semantic: the semantics remains two-valued, but the proof system explicitly tracks both values.

This means **soundness and completeness can be stated bilaterally**:
- Bilateral soundness: `Γ ⊢⁺ φ → Γ ⊨ φ` and `Γ ⊢⁻ φ → Γ ⊭ φ`
- Bilateral completeness: `Γ ⊨ φ → Γ ⊢⁺ φ` and `Γ ⊭ φ → Γ ⊢⁻ φ`

### 4.4 Decidability: Tableau Procedure

The tableau procedure already works bilaterally (signed formulas). The refactoring would align the proof system's bilateral structure with the existing tableau:

- **Proof extraction** (ProofExtraction.lean): Currently extracts `DerivationTree` from closed branches. Would extract `BilateralDeriv` instead.
- **Countermodel extraction** (CountermodelExtraction.lean): Currently extracts falsifying model from open branches. Would extract rejecting bilateral context.

### 4.5 Derived Theorems

All derived theorems in `Theories/Bimodal/Theorems/` would need bilateral reformulation:
- `Propositional.lean`: Double negation, contraposition, De Morgan — gain bilateral versions
- `ModalS5.lean`: S5 theorems — bilateral acceptance versions
- `Temporal.lean`: Temporal theorems — bilateral acceptance versions
- `GeneralizedNecessitation.lean`: Bilateral generalized necessitation (for both signs)

---

## 5. Implementation Strategy

### 5.1 Phase 1: Bilateral Infrastructure (New Files)

**New files to create**:
- `Bimodal/ProofSystem/BilateralContext.lean` — BilateralContext type and operations
- `Bimodal/ProofSystem/BilateralDerivation.lean` — BilateralDeriv type with all rules

**Changes to existing files**:
- `Bimodal/Syntax/Formula.lean` — No changes (keep bot, imp, etc.)

**Verification**: Prove basic bilateral theorems (bilateral modus ponens, bilateral deduction theorem).

### 5.2 Phase 2: Equivalence Bridge

**Goal**: Prove that the bilateral system is equivalent to the unilateral system.

```lean
-- Acceptance in bilateral system ↔ derivation in unilateral system
theorem bilateral_accept_iff_unilateral (Γ : List Formula) (φ : Formula) :
    (∃ d : BilateralDeriv ⟨Γ, []⟩ φ .pos) ↔ (∃ d : DerivationTree Γ φ)

-- Rejection in bilateral system ↔ derivation of negation in unilateral system
theorem bilateral_reject_iff_neg (Γ : List Formula) (φ : Formula) :
    (∃ d : BilateralDeriv ⟨Γ, []⟩ φ .neg) ↔ (∃ d : DerivationTree Γ (φ.neg))
```

This bridge allows all existing metalogic to transfer to the bilateral system.

### 5.3 Phase 3: Bilateral Metalogic

**Adapt MCS infrastructure**:
- Define `BilateralMCS` using `BilateralContext`
- Prove bilateral Lindenbaum lemma
- Define bilateral FMCS and BFMCS
- Prove bilateral truth lemma and completeness

**Alternatively**: Use the equivalence bridge (Phase 2) to derive bilateral metalogic from unilateral metalogic, avoiding reimplementation.

### 5.4 Phase 4: Bilateral Decidability

**Adapt tableau procedure**:
- The existing procedure already uses signed formulas
- Add extraction of `BilateralDeriv` instead of `DerivationTree`
- Adapt proof extraction to produce bilateral derivation trees

---

## 6. Risks and Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Massive blast radius breaks all downstream modules | High | High | Phase 2 equivalence bridge preserves existing proofs |
| Bilateral deduction theorem is harder to prove | Medium | Medium | Can use unilateral version via equivalence bridge |
| Performance: bilateral derivations are larger | Low | Low | Lean compilation handles well; can use `Prop` instead of `Type` |
| Bilateral MCS construction differs non-trivially | Medium | Medium | Classical bilateral MCS = standard MCS with complement (well-known) |
| Bilateral completeness requires different truth lemma | Medium | Low | Classical bilateral semantics = standard truth; bridge transfers |
| Loss of existing sorry-free results during refactoring | High | Medium | Keep unilateral system alongside bilateral during transition |

---

## 7. Alternative Approaches

### 7.1 Minimal Bilateral Extension (Recommended Starting Point)

Instead of replacing `DerivationTree`, **add** `BilateralDeriv` alongside it with a proven equivalence. This allows:
- Existing metalogic to continue working unchanged
- Bilateral results to be derived via the equivalence bridge
- Gradual migration of downstream modules

### 7.2 Sequent Calculus Bilateral

Rather than natural-deduction-style bilateral rules, use a bilateral sequent calculus:

```lean
-- Γ | Δ ⊢ φ : Sign
-- Γ = accepted hypotheses, Δ = rejected hypotheses
inductive BilateralSequent : List Formula → List Formula → Formula → Sign → Type
```

This is closer to Gentzen's LK and may simplify cut elimination proofs. However, it diverges more from the current natural deduction style.

### 7.3 Display Calculus

Use Belnap's display logic framework, which is inherently bilateral and modular. This provides automatic cut elimination for well-behaved logics but is substantially more complex to implement.

---

## 8. Relationship to Tableau Decision Procedure

The existing tableau procedure already implements bilateral reasoning:

| Tableau Rule | Bilateral Rule | Direction |
|---|---|---|
| T(φ → ψ) branches to F(φ) or T(ψ) | accept_imp / modus_ponens | Backward search |
| F(φ → ψ) yields T(φ) and F(ψ) | reject_imp | Backward search |
| T(□φ) propagates T(φ) | accept_box / accept_box_elim | Modal expansion |
| F(□φ) propagates F(φ) | reject_box_from_reject | Modal expansion |
| T(Gφ) propagates T(φ) | accept_future / accept_future_elim | Temporal expansion |
| F(Gφ) yields F(φ) witness | reject_future | Temporal witness |
| Branch closes on T(φ)+F(φ) | explosion | Contradiction |

The bilateral proof system can be seen as a top-down formalization of what the tableau procedure does bottom-up. Proof extraction from closed tableau branches would directly produce bilateral derivations.

---

## 9. Recommendations

### 9.1 Primary Recommendation

Implement the bilateral system as a **parallel proof system** alongside the existing unilateral system:

1. **New files**: `BilateralContext.lean`, `BilateralDerivation.lean`, `BilateralEquivalence.lean`
2. **Equivalence bridge**: Prove `BilateralDeriv ↔ DerivationTree` with explicit translations
3. **Bilateral metalogic**: Derive from unilateral via equivalence (no reimplementation)
4. **Gradual migration**: Replace unilateral system file-by-file once bilateral is proven equivalent

### 9.2 Effort Estimate

| Phase | Effort | Confidence |
|-------|--------|-----------|
| Phase 1: Bilateral infrastructure | 15-25 hours | High |
| Phase 2: Equivalence bridge | 10-15 hours | High |
| Phase 3: Bilateral metalogic | 20-35 hours | Medium |
| Phase 4: Bilateral decidability | 10-15 hours | Medium |
| **Total** | **55-90 hours** | Medium |

### 9.3 Prerequisites

- No strict dependencies on other tasks
- Task 951 (completeness) can proceed independently — bilateral system is compatible with both unilateral and bilateral metalogic
- The equivalence bridge (Phase 2) ensures bilateral refactoring does not block or invalidate any existing work

---

## 10. Decisions

1. **Use Option A (keep Formula, add bilateral judgments)** to minimize blast radius.
2. **Implement as parallel system** with equivalence bridge, not as replacement.
3. **Bilateral MCS = standard MCS with complement** — in classical logic, a bilateral MCS `(S⁺, S⁻)` where S⁺ ∪ S⁻ = all formulas and S⁺ ∩ S⁻ = ∅ is equivalent to a standard MCS S with S⁺ = S and S⁻ = complement(S).
4. **The bilateral system is proof-theoretically motivated** — it makes the dual roles of assertion and denial explicit, which aligns with the philosophical foundations of the logic.
5. **Existing tableau infrastructure provides the blueprint** — the bilateral proof rules mirror the tableau expansion rules.

---

## Appendix A: Files That Would Be Affected

### Direct Changes (New Files)
- `ProofSystem/BilateralContext.lean` (NEW)
- `ProofSystem/BilateralDerivation.lean` (NEW)
- `ProofSystem/BilateralEquivalence.lean` (NEW)
- `Theorems/BilateralPropositional.lean` (NEW)

### Indirect Changes (Migration)
- `Metalogic/Core/MaximalConsistent.lean` — bilateral MCS
- `Metalogic/Core/Lindenbaum.lean` — bilateral Lindenbaum
- `Metalogic/Bundle/FMCSDef.lean` — bilateral FMCS
- `Metalogic/Bundle/BFMCS.lean` — bilateral BFMCS
- `Metalogic/Bundle/TruthLemma.lean` — bilateral truth lemma
- `Metalogic/Soundness.lean` — bilateral soundness
- `Metalogic/Decidability/ProofExtraction.lean` — bilateral extraction
- `Theorems/Propositional.lean` — bilateral versions
- `Theorems/ModalS5.lean` — bilateral versions
- `Theorems/Temporal.lean` — bilateral versions
- `Theorems/GeneralizedNecessitation.lean` — bilateral version

### Unchanged
- `Syntax/Formula.lean` — no changes to formula type
- `Syntax/Context.lean` — unilateral context preserved
- `Semantics/TaskFrame.lean` — unchanged
- `Semantics/Truth.lean` — unchanged (bilateral is proof-theoretic)
- `Semantics/Validity.lean` — unchanged

## Appendix B: Literature on Bilateral Logic

- **Rumfitt, I.** (2000). "Yes" and "No." *Mind*, 109(436), 781-823. — Foundational bilateral logic paper.
- **Restall, G.** (2005). Multiple Conclusions. In *Logic, Methodology, and Philosophy of Science*. — Bilateral sequent calculus framework.
- **Smiley, T.** (1996). Rejection. *Analysis*, 56(1), 1-9. — Philosophical foundations of rejection as primitive.
- **Incurvati, L. & Schlöder, J.** (2017). Weak rejection. *Australasian Journal of Philosophy*, 95(4). — Bilateral systems with weak rejection.
