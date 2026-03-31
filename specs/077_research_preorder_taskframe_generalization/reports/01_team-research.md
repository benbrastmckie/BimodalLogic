# Research Report: Task #77 — PreorderTaskFrame Generalization and Completeness Theory

**Task**: Research PreorderTaskFrame generalization to relax AddCommGroup constraint
**Date**: 2026-03-31
**Mode**: Team Research (2 teammates)
**Session**: sess_1774979329_29349c

## Summary

The F/P witness construction blocker is a **genuine mathematical obstruction** for full TM completeness, not a formalization artifact. However, it CAN be sidestepped by (a) dropping linearity to obtain a weaker logic **BTM** (Branching Tense and Modality) that is complete over preorder-based semantics, or (b) using filtration/FMP for bounded-formula TM completeness. Task Semantics is fundamentally distinct from Kripke semantics due to its ternary task relation with algebraic duration structure, and this distinction provides powerful tools (time-shift preservation, group composition) that should be exploited rather than reduced away.

## Key Findings

### 1. F/P Witness Blocker Is Genuine (Teammate A)

**Cannot be sidestepped for full TM.** The core problem:

- An MCS M can contain both F(p) and F(¬p) consistently (in linear time, p holds at one future point, ¬p at another)
- Building a single successor MCS N forces a choice: p or ¬p, deferring the other via F(p) or F(¬p)
- After omega iterations, pending F-obligations may still exist due to infinite closure under G
- This is the same obstruction identified in Task 64 research

**Alternative approaches assessed:**

| Approach | Viable? | Key Issue |
|----------|---------|-----------|
| Filtration/FMP | **YES** | Quotient by closure(φ) makes obligations finite and bounded |
| Fair scheduling (omega-rule) | **YES in theory** | Requires omega-enumeration with global coordination |
| Bundle coherence weakening | **Viable alternative** | Allow F-witness in any bundle family |
| Ultraproduct | No | TM has FMP, so ultraproducts add nothing |
| Direct insertion/splicing | No | Breaks G-coherence |

### 2. Branching TM (BTM) — Complete Weaker Logic (Teammate A)

**Dropping the linearity axiom** (`temp_linearity: F(φ) ∧ F(ψ) → F(φ∧ψ) ∨ F(φ∧F(ψ)) ∨ F(F(φ)∧ψ)`) yields BTM:

- **Retains**: All propositional axioms, S5 modal axioms, temporal K/4/A/L/T, modal-temporal interaction (MF, TF)
- **Drops**: Only the linearity axiom

**BTM is complete with respect to preorder-based TaskFrames:**
- D needs only `[Preorder D]` (reflexive + transitive), not `[LinearOrder D]`
- Canonical model: D = CanonicalMCS with preorder = CanonicalR (g_content inclusion)
- F(φ) witnesses exist trivially: Lindenbaum extension of g_content(M) + {φ} is in D by construction
- **No linearity requirement** means F-witnesses need not fit on the same timeline

**Linearity is independent of other TM axioms** (concrete counterexample):
- Model: D = {0, 1a, 1b} with 0 ≤ 1a, 0 ≤ 1b, but 1a and 1b incomparable
- F(p) at 0 (witnessed at 1a), F(q) at 0 (witnessed at 1b)
- All three disjuncts of temp_linearity fail at time 0

### 3. Task Semantics Is Fundamentally Distinct (Teammate B)

Task Semantics CANNOT be reduced to standard Kripke semantics without losing essential structure:

| Feature | Kripke | Task Semantics |
|---------|--------|----------------|
| Relation | Binary R: W → W → Prop | Ternary: W → D → W → Prop |
| Duration | No metric | Ordered abelian group D |
| Compositionality | Transitive closure | Algebraic: d₁ + d₂ |
| Symmetry | Symmetric relation (optional) | Converse: task_rel w d u ↔ task_rel u (-d) w |
| Identity | Reflexivity | Nullity identity: task_rel w 0 u ↔ w = u |
| Histories | Paths through graph | Functions τ: domain → W with convex domains |

**Unique expressive capabilities:**
- Metric temporal properties (duration-specific, not just "eventually")
- Perpetuity principles (MF: □φ → □Gφ, TF: □φ → G□φ) — necessity is temporally stable
- Domain-dependent truth (atoms undefined outside history domain — models finite processes)
- Time-shift preservation: truth invariant under group translation of histories

### 4. Characterization Theorems for Extensions (Teammate B)

| System | Added Axioms | Frame Class | Canonical D |
|--------|-------------|-------------|-------------|
| Base TM | (none) | All TaskFrames over LOAGs | Int |
| Dense TM | GGφ → Gφ | TaskFrames with DenselyOrdered D | Rat |
| Discrete TM | DF + SF/SP | TaskFrames with SuccOrder D | Int (with SuccOrder) |
| **BTM** (new) | Drop linearity | TaskFrames over Preorder D | CanonicalMCS |

Dense and Discrete are **incompatible** (no frame is both dense and has immediate successors). Both extend Base TM.

### 5. Algebraic Advantages for Completeness (Teammate B)

The group structure on D provides tools unavailable in Kripke semantics:

1. **Time-shift preservation theorem**: `truth_at M Ω (shift σ (y-x)) x φ ↔ truth_at M Ω σ y φ`
2. **Backward compositionality** (derived from forward_comp + converse)
3. **STSA (Shift-Closed Tense S5 Algebra)**: Lindenbaum algebra with Box, G, H operators and involution σ swapping G ↔ H
4. **D-parametric representation**: Construction works for ANY LOAG D, avoiding domain mismatch

## Synthesis

### Conflicts Resolved

**Conflict**: Teammate A states dovetailing "fails" due to infinite F-obligations, but prior Task 64 research proposed omega-enumeration as viable.

**Resolution**: Both are correct at different levels. Dovetailing fails as a SIMPLE strategy (finite interleaving over infinite obligations), but the omega-enumeration approach (fair scheduling with omega-rule) works IN THEORY — it's the implementation/formalization in Lean that is blocked by the need for noncomputable choice over infinite chains. The mathematical obstruction is real; it's a question of whether the formalization can capture the omega-rule argument.

### Gaps Identified

1. **BTM vs CTL*/CTL relationship**: BTM should be compared with known branching-time logics. BTM has S5 modality (not in CTL*) and different temporal operators, so it likely doesn't reduce to any standard branching-time logic, but this needs precise characterization.

2. **FMP/filtration path for TM**: Both teammates mention this as viable but neither provides a detailed proof sketch. This is the most promising path for formal TM completeness and warrants dedicated investigation.

3. **PreorderTaskFrame Lean structure**: What exactly should the Lean definition look like? The current TaskFrame requires `[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]`. A PreorderTaskFrame would need `[AddCommGroup D] [Preorder D]` — but should it keep all three axioms (nullity_identity, forward_comp, converse)?

4. **Exact weakness of BTM**: How much weaker is BTM than TM? What formulas distinguish them beyond temp_linearity itself?

### Recommendations

**Immediate actions:**

1. **Define PreorderTaskFrame in Lean** — A new structure with `[Preorder D]` instead of `[LinearOrder D]`, keeping nullity_identity, forward_comp, converse. This supports BTM completeness.

2. **Prove BTM completeness** — Follow the canonical model construction with D = CanonicalMCS and preorder = CanonicalR. The F/P blocker vanishes because witnesses need not be on the same timeline.

3. **Investigate FMP/filtration for TM** — This is the most promising path for full TM completeness. Quotient by closure(φ) creates finite structures where F-obligations are bounded.

**Medium-term:**

4. **Establish BTM-TM relationship formally** — Prove linearity independence (using the 3-element model). Show BTM ⊂ TM strictly.

5. **Explore BTM applications** — Branching time with S5 necessity may model multi-agent systems, game semantics, or relativistic causality.

**Architecture:**

6. **Keep reflexive semantics** — Both teammates confirm this is the right choice (eliminates irreflexivity concerns, simplifies canonical construction).

7. **D-parametric approach is sound** — The parametric representation works for any LOAG D; extend this pattern to preorder-based BTM.

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | F/P blocker analysis, weaker logic completeness | completed | HIGH |
| B | Task Semantics uniqueness, characterization theorems | completed | HIGH |

## References

### Teammate Reports
- `specs/077_research_preorder_taskframe_generalization/reports/01_teammate-a-findings.md`
- `specs/077_research_preorder_taskframe_generalization/reports/01_teammate-b-findings.md`

### Key Source Files
- `Theories/Bimodal/Semantics/TaskFrame.lean` — TaskFrame definition (AddCommGroup + LinearOrder)
- `Theories/Bimodal/Semantics/Truth.lean` — time_shift_preserves_truth
- `Theories/Bimodal/ProofSystem/Axioms.lean` — 21 axiom schemata including temp_linearity
- `Theories/Bimodal/Metalogic/Bundle/FMCSDef.lean` — FMCS with Preorder D
- `Theories/Bimodal/Metalogic/Algebraic/ParametricRepresentation.lean` — D-parametric completeness
- `Theories/Bimodal/Metalogic/Algebraic/TenseS5Algebra.lean` — STSA structure

### Prior Research
- `specs/064_critical_path_review/reports/09_team-research.md` — Omega-enumeration BFMCS proposal
- `specs/006_canonical_taskframe_completeness/reports/` — Earlier completeness approaches

### Literature
- Goldblatt, R. (1992). "Logics of Time and Computation" — Completeness for linear temporal logic
- Blackburn, de Rijke, Venema (2001). "Modal Logic" — Canonical models (Ch. 4)
