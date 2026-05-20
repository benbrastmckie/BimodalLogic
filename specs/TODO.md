---
next_project_number: 171
repository_health:
  overall_score: 95
  production_readiness: near-publication
  last_assessed: 2026-05-18T23:45:00Z
task_counts:
  active: 18
  completed: 124
  in_progress: 2
  not_started: 14
  abandoned: 0
  total: 139
technical_debt:
  sorry_count: 1
  sorry_count_note: "Audited 2026-05-15: 1 root sorry on bx_completeness critical path: succ_cofinal (ChronicleToCountermodel.lean:1885) blocks limitDomSubtype_isSuccArchimedean → succ_embed_surjective → discrete countermodel → bx_completeness. Dense case sorry-free (dd_countermodel_chronicle_dense). Mixed case sorry-free (dd_countermodel_chronicle_mixed_sorry via False.elim, task 142). Tasks 143-148 closed NormalForm/KType/table_correctness sorries. Two paths to eliminate succ_cofinal: direct proof (task 153) or Reynolds pipeline bypass (tasks 154-155). ~17 dead-code sorries in BXCanonical pipeline (bypassed by Chronicle). ~6 non-critical TruthLemma sorries. Soundness, SoundnessLemmas, and Decidability are sorry-free."
  publication_path_sorries: 1
  axiom_count: 0
  axiom_count_note: "Zero custom axioms. Prior-UZ/SZ and discrete_box_necessity are standard axiom constructors with sorry-free soundness proofs."
  build_errors: 0
  status: excellent
---

# TODO

<!-- Vault transition: 2026-03-20 - Archived to specs/vault/01-vault/ -->

## Task Order

*Updated 2026-05-19. 18 active tasks.*

**Goal**: Sorry-free `bx_completeness` → formula refactor (G/H via U/S) → dead code cleanup → module reorganization → expressive extensions → algebraic representation.

**Dependency Waves**:
| Wave | Tasks | Blocked by | Topics |
|------|-------|------------|--------|
| 1 | 116, 21, 95, 130, 131, 156, 161, 162, 168 | -- | completeness, formula-refactor, meta, proof-system |
| 2 | 125, 127, 128, 157, 164, 165, 169 | 116, 168 | completeness, extensions, algebraic, decidability |
| 3 | 155, 170 | 157, 169 | completeness (Reynolds pipeline, Complete extension) |

**Grouped by Topic** (indented = must complete first):

### Completeness


155 [IMPLEMENTING] — Reynolds pipeline: eliminate succ_cofinal from bx_completeness
  └─ 157 [RESEARCHED] — Formalize expressive completeness of {S,U} over integer time
    └─ 116 [COMPLETED] — Remove G and H as primitive constructors; define via U and S
95 [NOT STARTED] — Verification audit: #print axioms + sorry classification pass
21 [NOT STARTED] — Clean up technical debt from metalogic refactoring track

### Proof System Architecture

168 [NOT STARTED] — Parameterize DerivationTree over FrameClass (Pattern 3 refactor)

### Formula Refactor

167 [RESEARCHED] — Close 7 sorries from task 116 (SubformulaClosure gap + ConservativeExtension dead code)
130 [RESEARCHED] — Archive ~19 dead-code sorries to Boneyard
131 [NOT STARTED] — Restructure Theories/Bimodal/ file hierarchy for clean APIs
161 [NOT STARTED] — Rename Theories/Bimodal/ to FormalSystem/

### Frame Extensions

169 [NOT STARTED] — Complete frame extension: axiom, typeclass, soundness, correspondence
  └─ 168 [NOT STARTED] — (proof-system: FrameClass refactor) (see above)
170 [NOT STARTED] — Completeness theorem for TM^dc (dense + complete)
  └─ 169 [NOT STARTED] — (Complete frame extension setup)
127 [NOT STARTED] — Add time addition operator (+) for bimodal logic TM
128 [NOT STARTED] — Add topological open set (interior) operator
165 [NOT STARTED] — Establish semantic finite model property (filtration)

### Algebraic Representation

125 [NOT STARTED] — Jónsson-Tarski representation theorem for TM logic
  └─ 116 [COMPLETED] — (formula-refactor: define G/H via U/S) (see above)

### Decidability

164 [NOT STARTED] — Prove tableau correctness (connect decide to semantic validity)
  └─ 165 [NOT STARTED] — (frame-extensions: establish semantic FMP) (see above)

### Agent System

162 [NOT STARTED] — Enforce strict plan compliance for formal implementation agents
156 [NOT STARTED] — Multi-angle team research strategy for formal agents


## Tasks

### 170. Establish completeness theorem for TM^dc (dense + complete extension)
- **Effort**: large
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Dependencies**: 169

**Description**: Prove proof-theoretic completeness for TM^dc, the dense + complete extension of the base TM logic. TM^dc extends TM with the density axiom DN (Fφ → FFφ) and the completeness axiom CO (G(Pφ → FPφ) → (Pφ → Fφ)). The standard model is ℝ (the reals as a conditionally complete densely ordered abelian group). This requires constructing a canonical model for TM^dc and proving a truth lemma showing that every TM^dc-consistent formula is satisfiable in a task model over a conditionally complete dense linear order. The existing dense completeness proof (BXCanonical chronicle construction) produces models over quotient types that are dense but not necessarily complete; this task must either extend that construction to produce complete models, or develop a new completeness argument. This is a research-level formalization — the paper "The Construction of Possible Worlds" (Brast-McKie 2025) proves the CO correspondence theorem but does not establish TM^dc completeness. Literature: Burgess 1982/84, Xu 1988, Reynolds 1994 for the base completeness pipeline; the CO correspondence proof in the paper's Appendix provides the semantic characterization.

---

### 169. Add Complete frame extension with axiom, typeclass, and soundness
- **Effort**: medium
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Dependencies**: 168

**Description**: Add the Complete frame class as an extension of Dense to the TM logic formalization, following the paper "The Construction of Possible Worlds" (Brast-McKie 2025). The Complete frame condition (Dedekind completeness) requires every nonempty bounded-above subset of the temporal domain to have a least upper bound. Key changes: (1) Add FrameClass.Complete to the FrameClass enum with Dense ≤ Complete in the partial order (from task 168). (2) Add the CO axiom constructor to Axiom: G(Pφ → FPφ) → (Pφ → Fφ), mapped to minFrameClass = .Complete. (3) Add CompleteTemporalFrame typeclass extending DenseTemporalFrame with ConditionallyCompleteLinearOrder from Mathlib. (4) Add ℝ instance for CompleteTemporalFrame. (5) Prove CO soundness on complete frames (paper Appendix, ~50 lines, uses sInf on the set of counterexamples). (6) Prove CO correspondence: CO is valid over a frame iff the frame is Complete (paper Theorem at line 2453, both directions). (7) Prove CO is valid on Archimedean discrete frames (paper footnote: since every Archimedean discrete ordered group is conditionally complete, CO holds vacuously). (8) Update soundness wrappers in FrameConditions/Soundness.lean. (9) Update README to document the Complete extension and the full frame class hierarchy: Base ≤ Dense ≤ Complete, Base ≤ Discrete.

---

### 168. Parameterize DerivationTree over FrameClass (Pattern 3 refactor)
- **Effort**: large
- **Status**: [NOT STARTED]
- **Task Type**: lean4

**Description**: Refactor axiom system to parameterize DerivationTree over FrameClass with a partial order, so frame-class validity is enforced structurally by the type system rather than by external predicates. Currently the codebase has a single Axiom inductive with 40 constructors and ad-hoc Boolean predicates (isBase, isDenseCompatible, isDiscreteCompatible) to filter axioms by frame class. The density axiom Fφ → FFφ exists as a semantic validity but has no Axiom constructor, and FrameClass.Dense exists but nothing maps to it. Soundness theorems carry side-conditions like h_dc throughout ~60+ call sites. Key changes: (1) Add density axiom constructor to Axiom for Fφ → FFφ mapped to FrameClass.Dense. (2) Add PartialOrder on FrameClass: Base ≤ Dense, Base ≤ Discrete, Dense and Discrete incomparable. (3) Define Axiom.minFrameClass: Base for 37 base axioms, Dense for density, Discrete for prior_UZ/prior_SZ/z1. (4) Parameterize DerivationTree (fc : FrameClass) : Context → Formula → Type with axiom rule requiring ax.minFrameClass ≤ fc. (5) Add lift function for fc₁ ≤ fc₂. (6) Remove all ad-hoc predicates (isBase, isDenseCompatible, isDiscreteCompatible on Axiom and DerivationTree). (7) Update all soundness theorems to remove h_dc side-conditions. (8) Update completeness theorems to produce DerivationTree .Base/.Dense/.Discrete as appropriate. (9) Update ~123 downstream references across Metalogic/, FrameConditions/, Theorems/, Boneyard/. (10) Connect density_valid to new axiom constructor. (11) Update README: rename Serial → Base, document three axiom systems as additive extensions.

---

### 165. Establish semantic finite model property for TM bimodal logic
- **Effort**: large
- **Status**: [NOT STARTED]
- **Task Type**: lean4

**Description**: Establish the semantic finite model property for TM bimodal logic. The existing FMP in `Decidability/FMP/` is purely proof-theoretic: it shows closure MCS structures are finite and that provability is decidable via MCS enumeration, but it does not construct finite semantic models (task frames with world histories). A standard semantic FMP requires: (1) Starting from a (possibly infinite) canonical model where φ fails, quotient worlds by agreement on the subformula closure of φ. (2) Prove the filtration lemma: truth of all subformulas is preserved in the quotient. The existing `TruthPreservation.lean` handles bot, imp, and box, but temporal operators are absent — the G/H cases were archived (they assumed the T-axiom, invalid under strict semantics) and Until/Since cases were never attempted. Until/Since are known to be problematic for naive filtration since they quantify over intermediate points; selective filtration or alternative constructions may be needed (see Blackburn/de Rijke/Venema Ch 2.3, Reynolds 2003). (3) Prove the quotient model is a valid task frame (nullity, compositionality, reflection preserved under filtration). (4) Bound the model size by `2^|cl(φ)|`. The result should be stated as: if φ is satisfiable in a task model, then φ is satisfiable in a finite task model of bounded size. This is needed for each frame class (serial, dense, discrete) to establish decidability.

### 164. Prove tableau correctness theorem for decision procedure
- **Effort**: large
- **Status**: [NOT STARTED]
- **Task Type**: lean4

**Description**: Prove tableau correctness theorem connecting decision procedure output to semantic validity. The current `validity_decidable` theorem in `Theories/Bimodal/Metalogic/Decidability/Correctness.lean` is trivially `Classical.em (⊨ φ)` — it says nothing about the tableau. The `decide` function in `DecisionProcedure.lean` implements a real tableau (proof search + branch expansion + countermodel extraction), but there is no theorem linking its output to semantic validity. Needed: (1) `decide_sound`: if `decide φ = .valid proof` then `⊨ φ` (may follow from soundness + the proof term). (2) `decide_complete`: if `decide φ = .invalid counter` then `¬(⊨ φ)` (requires proving countermodel extraction produces a genuine semantic countermodel). (3) `decide_terminates`: the procedure terminates for sufficient fuel (relates to FMP size bound). Without these, "sorry-free (tableau)" in the README is misleading — the implementation exists but its correctness is unverified.

### 162. Enforce strict plan compliance for formal implementation agents
- **Effort**: small
- **Status**: [NOT STARTED]
- **Task Type**: meta

**Description**: Add a .claude/rules/ rule enforcing strict plan compliance for lean-implementation-agent and other formal implementation agents. The rule should: (1) Prohibit agents from "assessing what's truly minimal" or inventing alternative approaches when a plan exists. (2) Require agents to follow the plan's exact task sequence step-by-step, in order. (3) Explicitly ban common divergence patterns: skipping intermediate theorems, inlining proofs instead of following the plan's decomposition, routing through different helper lemmas than specified, and "cleaner approach" rationalizations. (4) Be auto-applied via glob pattern to Theories/ and any formal proof files. (5) Reference the repeated failures in task 157 (8 plan versions, agents diverging every time) as motivation. The rule should be concise but firm -- agents must treat the plan as a contract, not a suggestion.

### 161. Rename Theories/Bimodal/ to FormalSystem/
- **Effort**: medium
- **Status**: [NOT STARTED]
- **Task Type**: lean4

**Description**: Rename Theories/Bimodal/ to FormalSystem/. Move the entire Theories/Bimodal/ directory to FormalSystem/, update all imports in Lean files, update lakefile.lean srcDir from Theories to FormalSystem and roots from Bimodal to FormalSystem, update any references in README.md, Tests/, and other files that point to the old path. Ensure lake build still passes after the rename.

### 157. Formalize expressive completeness of {S,U} over integer time
- **Effort**: 3-4 weeks (~2500 lines)
- **Status**: [IMPLEMENTING]
- **Task Type**: lean4
- **Priority**: high
- **Dependencies**: 155, 116
- **Research**:
  - [specs/157_expressive_completeness_su_integer/reports/01_expressive-completeness-proof.md]
  - [specs/157_expressive_completeness_su_integer/reports/04_team-research.md]
  - [specs/157_expressive_completeness_su_integer/reports/05_team-research.md]
  - [157_expressive_completeness_su_integer/reports/06_team-research.md]
  - [157_expressive_completeness_su_integer/reports/07_team-research.md]
  - [157_expressive_completeness_su_integer/reports/08_team-research.md]
  - [157_expressive_completeness_su_integer/reports/09_team-research.md]
  - [157_expressive_completeness_su_integer/reports/10_task116-dependency-analysis.md]
  - [157_expressive_completeness_su_integer/reports/11_post-task116-assessment.md]
  - [157_expressive_completeness_su_integer/reports/12_team-research.md]
  - [specs/157_expressive_completeness_su_integer/reports/14_team-research.md]
  - [specs/157_expressive_completeness_su_integer/reports/15_team-research.md]
  - [157_expressive_completeness_su_integer/reports/17_team-research.md]
  - [157_expressive_completeness_su_integer/reports/23_team-research.md]
- **Plan**:
  - [157_expressive_completeness_su_integer/plans/05_dedekind-approach-plan.md]
  - [157_expressive_completeness_su_integer/plans/06_phase7-first-plan.md]
  - [157_expressive_completeness_su_integer/plans/07_complete-remaining-plan.md]
- **Summary**: [specs/157_expressive_completeness_su_integer/summaries/06_implementation-summary.md]
  - [157_expressive_completeness_su_integer/plans/07_dedekind-specialization-plan.md]
  - [157_expressive_completeness_su_integer/plans/08_axiom-elimination-plan.md]
  - [157_expressive_completeness_su_integer/plans/12_separation-repair-plan.md]
  - [157_expressive_completeness_su_integer/plans/15_ghr94-restructuring-plan.md]
  - [157_expressive_completeness_su_integer/plans/17_revised-restructuring-plan.md]
  - [157_expressive_completeness_su_integer/plans/23_oracle-free-plan.md]

**Description**: Formalize expressive completeness of {S,U} over integer time (GHR94 Ch 10.2 separation theorem). Prove that every monadic first-order sentence over integer time has a temporal {U,S} equivalent (Theorem 10.2.9-10.2.10). This is Reynolds's Theorem 5, required as prerequisite for Phase 3B of task 155 (gap elimination, Reynolds Theorem 14). Literature: GHR94 Chapters 9-10 (in literature/ with markdown conversions). Proof structure: 8 elimination cases (pulling U out of S and vice versa), nested 4-level induction (junction depth -> nesting depth -> number of U-subformulas -> single case).

---

### 156. Improve formal/lean/math/logic research agents with multi-angle team research strategy
- **Effort**: 4-8 hours
- **Status**: [NOT STARTED]
- **Task Type**: meta
- **Priority**: medium

**Description**: Improve formal/lean/math/logic research agents with multi-angle team research strategy. In the task 154 research cycle, a proof blocker persisted through multiple single-agent rounds. What broke through was launching 4 parallel agents each assigned a distinct angle: (A) backward from sorry sites using lean_goal/lean_multi_attempt, (B) infrastructure inventory with exact signatures and gap analysis, (C) literature review assessing approach soundness, (D) decomposition into small lemmas with lean_run_code verification. Improvements: (1) Add multi-angle analysis mode to lean-research-agent, (2) Always try lean_multi_attempt/lean_run_code to verify solutions compile, (3) Add guidance for when to recommend team research after repeated blockers, (4) Add prototype-first research pattern, (5) Update formal-research-agent to auto-route to multi-angle team research when multiple handoffs indicate the same blocker.

---

### 155. Activate Reynolds pipeline for sorry-free discrete completeness
- **Effort**: 6-10 hours
- **Status**: [IMPLEMENTING]
- **Task Type**: lean4
- **Priority**: high
- **Dependencies**: 154
- **Research**:
  - [specs/155_reynolds_pipeline_activation/reports/01_team-research.md]
  - [specs/155_reynolds_pipeline_activation/reports/02_team-research.md]
- **Plan**:
  - [155_reynolds_pipeline_activation/plans/01_reynolds-pipeline-plan.md]
  - [155_reynolds_pipeline_activation/plans/02_reynolds-pipeline-plan.md]

**Description**: Replace the chronicle fallback in Transfer.lean with the full Reynolds Theorem 15 pipeline, eliminating `succ_cofinal` from `bx_completeness`. Rather than bridging `ZIntervalStructure` to `TaskFrame` via an adapter, refactor the pipeline to construct a `TaskFrame Int` directly from the Reynolds output. Wire `chronicle_is_good` (unblocked by task 154), `table_correctness` (sorry-free from tasks 147-148), and a direct `TaskFrame` construction into Transfer.lean. Definition of done: `doets_countermodel_discrete` uses Reynolds pipeline, `bx_completeness` has no `sorryAx`, `lake build` passes.

---

### 131. Refactor module organization for clean APIs and documentation
- **Effort**: 15-25 hours
- **Status**: [NOT STARTED]
- **Task Type**: lean4

**Description**: Restructure Theories/Bimodal/ file hierarchy for clean APIs and documentation. Currently 130 live .lean files across 7 top-level directories, with the Metalogic/ directory being a catch-all containing 7 subdirectories (Algebraic, Bundle, BXCanonical, ConservativeExtension, Core, Decidability, Relational) plus loose files (Soundness.lean, SoundnessLemmas.lean, DenseSoundness.lean, DiscreteSoundness.lean, Completeness.lean, Metalogic.lean). Goals: (1) Reorganize Metalogic/ into a clearer hierarchy — group soundness files into Metalogic/Soundness/, completeness files into Metalogic/Completeness/, clarify relationship between BXCanonical (chronicle approach) and Algebraic (parametric approach). (2) Add module-level documentation (docstrings on namespace declarations, module descriptions at file tops). (3) Establish clean APIs with explicit exports via root .lean files for each subdirectory. (4) Evaluate whether FrameConditions/ should be merged into Metalogic/ or remain separate. (5) Audit Boneyard/ organization (45 files across 10+ subdirectories). (6) Consider whether docs/ and latex/ and typst/ should remain under Theories/Bimodal/ or move to project root.

---

### 130. Archive dead sorries to Boneyard
- **Effort**: 4-8 hours
- **Status**: [RESEARCHED]
- **Task Type**: lean4
- **Priority**: medium
- **Dependencies**: 129
- **Research**: [specs/130_archive_dead_sorries_to_boneyard/reports/01_sorry-inventory.md]

**Description**: After task 129 provides IsSuccArchimedean via weak/reflexive completeness, archive all dead-code sorries to the Boneyard. Includes: (1) succ_reaches_dom_N boundary cases (ChronicleToCountermodel.lean) — stage induction superseded by Henkin model. (2) limit_dom_points_are_succ_iterates — convergence approach superseded. (3) succ_cofinal gap analysis — entire convergence + Z1 gap section. (4) BXCanonical pipeline dead code (Quasimodel/Realization, Quasimodel/Construction, TruthLemma, RootScopedChain, Filtration/SigmaOrdering, Frame) — bypassed by Chronicle. (5) Bundle/SuccRelation and Bundle/SuccExistence sorries if no longer needed. Total: ~40 sorries to archive.

---

### 128. Open set (interior) operator for dense and continuous temporal frames
- **Effort**: 15-25 hours
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Dependencies**: 122

**Description**: Add topological interior operator for dense and continuous temporal frames. On discrete Z the interior is trivial, but on dense Q and continuous R it captures neighborhood-stable truth: Int(phi) true at t iff phi holds in an open neighborhood of t. Related to Dynamic Topological Logic (Kremer-Mints 2005), McKinsey-Tarski topological semantics for S4. Phases: TopologicalSpace instance for dense/continuous TaskFrame, interior Formula constructor with truth clause, S4-like axioms (Int(phi)->phi, Int(phi)->Int(Int(phi))), interaction with temporal operators and S5 box. Note: DTL is not finitely axiomatizable (Fernandez-Duque 2014).

---

### 127. Time addition operator (+) for bimodal logic TM
- **Effort**: 20-40 hours
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Dependencies**: 123

**Description**: Add time addition operator to TM. phi + psi true at (tau, x) iff there exist y,z with x = y+z and phi at (tau,y) and psi at (tau,z). Internalizes AddCommGroup structure into the object language, extending expressive power from FO[<] to FO[<,+] (Presburger arithmetic). Related to arrow logic (Venema), relevant logic (Routley-Meyer ternary frames), separation logic (BI). Phases: add tadd/tsub constructors to Formula, truth clause, basic axioms (associativity, commutativity, identity, inverse), soundness, interaction with G/H/U/S/box. Completeness (ternary canonical model) and decidability are open research problems.

---

### 125. Jónsson-Tarski representation theorem for TM logic
- **Effort**: 15-25 hours
- **Status**: [NOT STARTED]
- **Task Type**: formal
- **Dependencies**: 116, 122, 163

**Description**: Implement a Jónsson-Tarski representation theorem for TM logic: every STSA embeds into the complex algebra of a concrete frame. This is a purely algebraic structural result with no mention of provability — distinct from the completeness theorems (renamed in task 163).

**Phased approach**:
- **Phase 1 — Complex algebra `Cm(F)`**: Define the powerset STSA for TaskFrames with `box`/`G`/`H`/`sigma` operators derived from frame relations. Prove `Cm(F)` satisfies all STSA axioms. Self-contained, depends only on Semantics and Mathlib.
- **Phase 2 — Ultrafilter frame `Uf(A)`**: Given abstract STSA `A`, construct frame whose worlds are ultrafilters with canonical relations `R_G`, `R_H`, `R_Box` (seed infrastructure recovered in task 163 from Boneyard). Prove `Uf(A)` satisfies TaskFrame axioms. Duration type D may require parametric treatment.
- **Phase 3 — Embedding theorem**: Prove `η(a) = {U | a ∈ U}` is an injective STSA homomorphism `A ↪ Cm(Uf(A))`. Core J-T result.
- **Phase 4 — Since/Until extension**: Extend STSA typeclass with binary `untl`/`sinc` operators (additive in each argument, conjugated per Venema 1997). Prove representation for full operator signature. S/U induce ternary canonical relations in the BAO framework.

**Start with basic `{□, G, H}` fragment** (Phases 1–3) before tackling S/U (Phase 4).

**Prerequisites**: Resolve 6 algebraic sorries (`temp_k_dist`, `temp_a`, `temp_l` in TenseS5Algebra/InteriorOperators/LindenbaumQuotient). Obtain 3 missing papers: Jónsson-Tarski 1951/52 (AJM), BRV 2001 Ch. 5, Goldblatt 1989 (APAL). Task 992 research report maps ~80% of needed infrastructure.

**Architecture**: Restructure `Algebraic/` into `Core/` (shared STSA, Boolean, ultrafilter), `Completeness/` (renamed existing), `Representation/` (new J-T work: ComplexAlgebra.lean, UltrafilterFrame.lean, RepresentationEmbedding.lean, FrameProperties.lean).

**Key references**: Venema 1991 Ch. 2 + App. A (BAO duality for temporal), de Rijke-Venema 1995 Thm 3.5 (Sahlqvist canonicity), Venema 1997 Thm 1.4 (conjugated varieties), GHV 2003 (BAOs and modal logic), Venema 1993 Anti-Axioms (orthodox axiomatizability).

---

### 167. Close 7 sorries from task 116 (SubformulaClosure gap + ConservativeExtension dead code)
- **Effort**: 5-10 hours
- **Status**: [COMPLETED]
- **Task Type**: lean4
- **Dependencies**: 116
- **Research**:
  - [specs/167_close_task116_sorries/reports/01_subformula-closure-gap.md]
- **Plan**: [167_close_task116_sorries/plans/01_close-sorries-plan.md]
- **Summary**: [167_close_task116_sorries/summaries/01_close-sorries-summary.md]

**Description**: Close 7 sorries introduced by task 116 (G/H/F/P redefinition via U/S). Three sorries in SuccExistence.lean and RestrictedMCS.lean are caused by the SubformulaClosure design gap: under new definitions P(χ) = S(χ,⊤), the formula H(¬χ) is no longer a structural subformula of P(χ). Fix: extend `baseDeferralClosure` with a `temporalBlockingSet` that includes H(¬χ) for each P(χ) and G(¬χ) for each F(χ) in the closure. Four sorries in ConservativeExtension/Lifting.lean are dead Boneyard code with removed temp_k_dist/temp_4 axiom match arms. Research identifies 3 additional SuccExistence sorries (lines 460, 763, 837) as a separate BX1 issue, not closure-related.

---

### 116. Redefine G, H, F, P in terms of U and S following Burgess 1982
- **Effort**: 15-25 hours
- **Status**: [COMPLETED]
- **Completed**: 2026-05-18
- **Summary**: Removed all_future/all_past as Formula constructors, redefined G/H/F/P as def abbreviations via Until/Since (Burgess 1982). Derived temp_k_dist/temp_4 from BX axioms, removed as axiom constructors. 40+ files modified, build passes (1647 jobs, 0 errors). Sorry delta: +7 (3 SuccExistence SubformulaClosure gap, 4 ConservativeExtension dead code).
- **Task Type**: lean4
- **Dependencies**: 107
- **Research**:
  - [specs/116_redefine_ghfp_via_until_since/reports/01_redefine-ghfp-research.md]
  - [116_redefine_ghfp_via_until_since/reports/02_team-research.md]
- **Plan**:
  - [116_redefine_ghfp_via_until_since/plans/04_redefine-ghfp-plan.md]
- **Summary**:
  - [specs/116_redefine_ghfp_via_until_since/summaries/04_redefine-ghfp-summary.md]

**Description**: Remove `all_future` (G) and `all_past` (H) as primitive constructors from the `Formula` inductive type. Define F and P as abbreviations using `untl`/`snce` with ⊤, then G and H as ¬F¬ and ¬P¬, matching Burgess 1982 §1.1. `box` (□) remains primitive (S5 modal operator). ~3200 references across codebase. Should be done AFTER task 107 Phase 9 (convention migration) to avoid double-refactoring.

---

### 95. Verification audit: #print axioms + sorry classification pass
- **Effort**: 2-4 hours
- **Status**: [NOT STARTED]
- **Language**: lean4
- **Priority**: medium
- **Dependencies**: None
- **Created**: 2026-04-10

**Description**: Verification pass on `bx_completeness` sorry status. Updated scope: (1) Verify `dd_countermodel_chronicle_dense` and `dd_countermodel_chronicle_mixed_sorry` show no `sorryAx` (confirmed sorry-free as of 2026-05-15). (2) Trace the discrete case `sorryAx` chain: `dd_countermodel_chronicle_discrete` -> `succ_embed_surjective` -> `limitDomSubtype_isSuccArchimedean` -> `succ_cofinal` (root sorry). (3) Classify all Metalogic/ sorry occurrences as critical-path vs dead-code vs non-critical-path. (4) Update stale axiom audit comments in Completeness.lean (lines 177-234 reference CE:3570 which is no longer the sorry source). (5) Verify soundness and decidability remain sorry-free. (6) Produce audit report.

---

### 21. Clean up technical debt from tasks 9-20
- **Effort**: 3-5 hours
- **Status**: [NOT STARTED]
- **Language**: lean4
- **Dependencies**: None
- **Research**:
  - [01_tech-debt-audit.md](021_technical_debt_cleanup/reports/01_tech-debt-audit.md)
  - [02_team-research.md](021_technical_debt_cleanup/reports/02_team-research.md)
- **Plan**: [01_tech-debt-cleanup-plan.md](021_technical_debt_cleanup/plans/01_tech-debt-cleanup-plan.md)

**Description**: Clean up technical debt from metalogic refactoring track (tasks 9-20). Scope revised: (1) Document which metalogic paths are live (chronicle BXCanonical approach) vs dead (TimelineQuot, DenseTask, CanonicalModel parametric approach). (2) Remove dead code from non-chronicle paths or archive to Boneyard (overlaps with task 130). (3) Update stale docstrings in Metalogic/ files that reference superseded approaches. (4) Consolidate parametric representation usage documentation. Original dependency on task 18 removed (task 18 abandoned).

---
