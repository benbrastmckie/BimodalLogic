---
next_project_number: 152
repository_health:
  overall_score: 95
  production_readiness: near-publication
  last_assessed: 2026-05-14T01:30:00Z
task_counts:
  active: 27
  completed: 783
  in_progress: 0
  not_started: 11
  abandoned: 80
  total: 873
technical_debt:
  sorry_count: 6
  sorry_count_note: "Audited 2026-05-15: 6 sorries remain on bx_completeness critical path: 3 in NEquivalence.lean (k_type_of, ktype_finite, finite_types — task 139), 2 in Table.lean (table, table_depth_bound — task 140), 1 in ChronicleToCountermodel.lean (mixed case — task 142). Task 141 resolved: canS5R_symm and reflCanR_linear closed (sorry-free); 6 TruthLemma Until/Since sorries reclassified as non-critical-path (parametric truth lemma handles via BFMCS coherence). ~17 dead-code sorries in BXCanonical pipeline (bypassed by Chronicle). ~6 non-critical TruthLemma sorries. Soundness, SoundnessLemmas, and Decidability are sorry-free."
  publication_path_sorries: 6
  axiom_count: 0
  axiom_count_note: "Zero custom axioms. Prior-UZ/SZ are standard axiom constructors with sorry-free soundness proofs."
  build_errors: 0
  status: excellent
---

# TODO

<!-- Vault transition: 2026-03-20 - Archived to specs/vault/01-vault/ -->

## Task Order

*Updated 2026-05-15. Generated from state.json dependency graph.*

**Goal**: Sorry-free `bx_completeness` → module reorganization → frame hierarchy → formula refactor → expressive extensions → algebraic representation.

**Dependency Waves**:
| Wave | Tasks | Blocked by |
|------|-------|------------|
| 1 | 8,18,60,64,68,95,112,114,116,122,126,127,130,131,142,143,146,148,151,619,949,953,992,998 | -- |
| 2 | 20,21,125,128 | 18,116,122 |

**Dependency Tree** (indented = must complete first):
```
8 [RESEARCHED] — genuine_truth_at_completeness
18 [BLOCKED] — Wire the TimelineQuot BFMCS and DenseTask-based TaskFrame ℚ into 
60 [NOT STARTED] — discrete_Icc_finite_axiom was already eliminated (zero custom axi
64 [RESEARCHED] — critical_path_review
68 [RESEARCHED] — Eliminate the sorry in dense_completeness_fc (FrameConditions/Com
95 [NOT STARTED] — Verification pass to confirm sorry-free completeness. (1) Run #pr
112 [RESEARCHED] — literature_study_representation_theorem
114 [NOT STARTED] — Add a .claude/rules/ rule enforcing plan compliance for implement
116 [PLANNED] — Remove all_future (G) and all_past (H) as primitive constructors 
122 [RESEARCHED] — Build discrete BFMCS on Z and complete dd_countermodel_chronicle_
126 [RESEARCHED] — Establish a four-tier axiom hierarchy with explicit frame corresp
127 [NOT STARTED] — Add time addition operator (+) to the bimodal logic TM. φ + ψ is 
130 [NOT STARTED] — After task 129 provides IsSuccArchimedean via weak/reflexive comp
131 [NOT STARTED] — Restructure Theories/Bimodal/ file hierarchy for clean APIs and d
142 [RESEARCHED] — Resolve the mixed-case sorry in bx_completeness: the case where n
143 [PARTIAL] — Prove Doets 1989 Lemma 1.1 (finitely many formulas up to logical 
146 [RESEARCHING] — Remove legacy dead code (vacuous nf_eval, nf_vector, normalFormId
148 [RESEARCHING] — Close the 4 temporal operator cases of table_correctness (all_fut
151 [IMPLEMENTING] — Integrate Task Order with /todo and /review commands. Update /tod
619 [RESEARCHED] — agent_system_architecture_upgrade
949 [RESEARCHED] — update_demo_lean_bimodal_logic
953 [RESEARCHED] — Refactor unilateral proof system (Γ ⊢ φ) to bilateral system with
992 [RESEARCHED] — Implement the Shift-Closed Tense S5 Algebra (STSA) representation
998 [RESEARCHING] — Redesign the FMP filtration for strict temporal semantics. The 2 
20 [NOT STARTED] — Review ParametricCanonical.lean, ParametricTruthLemma.lean, and P
  └─ 18 [BLOCKED] — Wire the TimelineQuot BFMCS and DenseTask-based TaskFrame ℚ into  (see above)
21 [PLANNED] — Clean up technical debt accumulated across tasks 9-20 metalogic r
  └─ 18 [BLOCKED] — Wire the TimelineQuot BFMCS and DenseTask-based TaskFrame ℚ into  (see above)
125 [NOT STARTED] — Research algebraic methods for establishing a Jónsson-Tarski-styl
  └─ 116 [PLANNED] — Remove all_future (G) and all_past (H) as primitive constructors  (see above)
  └─ 122 [RESEARCHED] — Build discrete BFMCS on Z and complete dd_countermodel_chronicle_ (see above)
128 [NOT STARTED] — Add topological open set (interior) operator for dense and contin
  └─ 122 [RESEARCHED] — Build discrete BFMCS on Z and complete dd_countermodel_chronicle_ (see above)
```

## Tasks

### 149. Redesign Task Order format and generation script
- **Effort**: 3-6 hours
- **Status**: [COMPLETED]
- **Task Type**: meta
- **Dependencies**: None
- **Research**: [149_redesign_task_order_format/reports/01_format-redesign-research.md]
- **Plan**: [149_redesign_task_order_format/plans/01_task-order-redesign.md]
- **Summary**: [149_redesign_task_order_format/summaries/01_task-order-redesign-summary.md]

**Description**: Redesign the Task Order section format in TODO.md. Replace flat category lists with dependency wave table and indented dependency tree format. Create `generate-task-order.sh` script to regenerate Task Order from state.json dependency graph. Update `task-order-format.md` spec with new wave+tree format definition. Files: `.claude/context/formats/task-order-format.md` (redesign), `.claude/scripts/generate-task-order.sh` (new).

---

### 150. Task Order auto-pruning and auto-insertion
- **Effort**: 3-6 hours
- **Status**: [COMPLETED]
- **Task Type**: meta
- **Dependencies**: Task #149
- **Research**: [150_task_order_auto_sync/reports/01_task-order-auto-sync.md]
- **Plan**: [150_task_order_auto_sync/plans/01_task-order-auto-sync.md]
- **Summary**: [150_task_order_auto_sync/summaries/01_task-order-auto-sync-summary.md]

**Description**: Add automatic Task Order synchronization. Update `update-task-status.sh` to auto-prune completed tasks from Task Order when status is set to [COMPLETED]. Update `/task` command to auto-insert new tasks into Task Order with correct dependencies. Add sync validation logic to detect and auto-correct drift between Task Order status markers and state.json. Files: `.claude/scripts/update-task-status.sh`, `.claude/commands/task.md`.

---

### 151. Task Order command integration and rules
- **Effort**: 1-3 hours
- **Status**: [IMPLEMENTING]
- **Task Type**: meta
- **Dependencies**: Task #149
- **Research**: [151_task_order_command_integration/reports/01_command-integration.md]
- **Plan**: [151_task_order_command_integration/plans/01_command-integration.md]

**Description**: Integrate Task Order with `/todo` and `/review` commands. Update `/todo` to regenerate Task Order during archive flow using `generate-task-order.sh`. Update `/review` to use new wave+tree format instead of old pruning logic. Add Task Order sync rules to `state-management.md`. Files: `.claude/commands/todo.md`, `.claude/commands/review.md` (Section 6.5), `.claude/rules/state-management.md`.

---

### 147. Prove lift_eval and insertEnv De Bruijn substitution lemmas
- **Effort**: 2-3 hours
- **Status**: [COMPLETED]
- **Completed**: 2026-05-15
- **Task Type**: lean4
- **Priority**: high
- **Dependencies**: None
- **Research**: [specs/147_lift_eval_insertenv_lemmas/reports/01_scope-analysis.md]
- **Plan**: [147_lift_eval_insertenv_lemmas/plans/01_debruijn-plan.md]
- **Summary**: [specs/147_lift_eval_insertenv_lemmas/summaries/01_debruijn-summary.md]

**Description**: Prove the 4 De Bruijn substitution lemmas in NEquivalence.lean left sorry by task 140: `insertEnv_zero_eq_cons` (inserting at 0 equals Fin.cons), `insertEnv_succ_cons` (commutation of insertEnv with Fin.cons under binders), `insertEnv_finLift` (inverse relationship between insertEnv and finLift), and `lift_eval` (main substitution lemma: evaluating a lifted formula in an inserted environment recovers original evaluation). Pure Fin-arithmetic / function-extensionality proofs. Once proved, `weaken_eval` becomes sorry-free automatically.

---

### 148. Complete table_correctness temporal operator cases
- **Effort**: 1.5-2 hours
- **Status**: [RESEARCHED]
- **Task Type**: lean4
- **Priority**: high
- **Dependencies**: 147
- **Research**:
  - [specs/148_table_correctness_temporal_cases/reports/01_scope-analysis.md]
  - [specs/148_table_correctness_temporal_cases/reports/02_proof-development.md]

**Description**: Close the 4 temporal operator cases of `table_correctness` (`all_future`, `all_past`, `untl`, `snce`) in Table.lean, plus 2 helper lemmas (`cons_eq_insertEnv_one`, `cons3_eq_insertEnv`). Each temporal case: unfold definitions, apply `lift1_eval`/`lift1_lift1_eval`, use induction hypothesis. Also fix `chronicle_is_good` atomMap signature in Transfer.lean step 3 comment and update pipeline status table. Result: `table_correctness` fully sorry-free with `lean_verify` showing no `sorryAx`.

---

### 143. Doets Lemma 1.1: normal form KType redesign with finite domain
- **Effort**: 6-9 hours
- **Status**: [PARTIAL]
- **Task Type**: lean4
- **Priority**: critical
- **Dependencies**: 139
- **Plan**: [143_doets_lemma_1_1_normal_form_ktype/plans/02_revised-plan.md]
- **Summary**: Doets Lemma 1.1 bridge theorem proved sorry-free in NormalForm.lean. finite_types closed. KType redesign to NormalForm domain and k_equiv_monotone closure deferred to task 145 (circular import).

**Description**: Prove Doets 1989 Lemma 1.1 (finitely many formulas up to logical equivalence) and redesign `KType` with a finite normal form domain, closing `ktype_finite` and `KEquivalenceFramework.finite_types`.

The current `KType` uses an infinite domain (`{s : MonadicFormula sig 0 // s.quantifier_depth ≤ k} → Bool`) making `Fintype` impossible. The correct mathematical object (Doets 1987 Chapter 1, Section 1.6-1.7) is the space of n-characteristics. Define `NormalForm sig k n` as a finite type of Hintikka formula representatives, prove every formula is equivalent to one (Doets Lemma 1.1 by induction on k), redefine `KType sig k := NormalForm sig k 0 → Bool`, and close `finite_types` via `Setoid.quotientKerEquivRange`.

**Literature**: Doets 1987 thesis Ch. 1 (Sections 1.6-1.7), Doets 1989 Lemma 1.1.

- **Research**:
  - [specs/143_doets_lemma_1_1_normal_form_ktype/reports/01_team-research.md]
  - [specs/143_doets_lemma_1_1_normal_form_ktype/reports/01_teammate-a-findings.md]
  - [specs/143_doets_lemma_1_1_normal_form_ktype/reports/01_teammate-b-findings.md]
  - [specs/143_doets_lemma_1_1_normal_form_ktype/reports/01_teammate-c-findings.md]
  - [specs/143_doets_lemma_1_1_normal_form_ktype/reports/01_teammate-d-findings.md]

---

### 145. Split NEquivalence.lean, redesign KType to NormalForm, close k_equiv_monotone
- **Effort**: 3-5 hours
- **Status**: [COMPLETED]
- **Completed**: 2026-05-15
- **Task Type**: lean4
- **Priority**: high
- **Dependencies**: 143
- **Research**: [specs/145_split_nequivalence_close_k_equiv_monotone/reports/01_split-design.md]
- **Plan**: [145_split_nequivalence_close_k_equiv_monotone/plans/01_split-plan.md]
- **Summary**: [specs/145_split_nequivalence_close_k_equiv_monotone/summaries/01_split-summary.md]

**Description**: Split NEquivalence.lean into MonadicFO.lean (pure FO definitions: MonadicSignature, MonadicFormula, eval, atomCount, nfCount, NormalFormIdx) and NEquivalence.lean (k-equiv framework). Break the circular import so NEquivalence.lean can import NormalForm.lean. Redefine `KType sig k := NormalForm sig k 0 -> Bool` (replacing NormalFormIdx). Redefine `k_type_of` using `nf_eval_nf` (replacing vacuous `nf_rep`). Close `k_equiv_monotone` sorry via `nf_agreement_monotone`. Delete `nf_rep`. Verify `finite_types` remains closed and `lake build` passes.

---

### 146. NormalForm legacy cleanup and cardinality correspondence proof
- **Effort**: 1-2 hours
- **Status**: [RESEARCHING]
- **Task Type**: lean4
- **Priority**: medium
- **Dependencies**: 145
- **Research**: [specs/146_normalform_cleanup_cardinality/reports/01_cleanup-design.md]

**Description**: Remove legacy dead code (vacuous `nf_eval`, `nf_vector`, `normalFormIdx_nonempty`) from NormalForm.lean. Prove cardinality correspondences: `Fintype.card (AtomKind sig n) = atomCount p n` and `Fintype.card (NormalForm sig k n) = nfCount p k n`, confirming the counting function matches the actual type. Update docstrings for publication quality. Optionally prove `normalForm_equiv_fin : NormalForm sig k n ≃ NormalFormIdx sig k n`.

---

### 131. Refactor module organization for clean APIs and documentation
- **Effort**: 15-25 hours
- **Status**: [NOT STARTED]
- **Task Type**: lean4

**Description**: Restructure Theories/Bimodal/ file hierarchy for clean APIs and documentation. Currently 130 live .lean files across 7 top-level directories, with the Metalogic/ directory being a catch-all containing 7 subdirectories (Algebraic, Bundle, BXCanonical, ConservativeExtension, Core, Decidability, Relational) plus loose files (Soundness.lean, SoundnessLemmas.lean, DenseSoundness.lean, DiscreteSoundness.lean, Completeness.lean, Metalogic.lean). Goals: (1) Reorganize Metalogic/ into a clearer hierarchy — group soundness files into Metalogic/Soundness/, completeness files into Metalogic/Completeness/, clarify relationship between BXCanonical (chronicle approach) and Algebraic (parametric approach). (2) Add module-level documentation (docstrings on namespace declarations, module descriptions at file tops). (3) Establish clean APIs with explicit exports via root .lean files for each subdirectory. (4) Evaluate whether FrameConditions/ should be merged into Metalogic/ or remain separate. (5) Audit Boneyard/ organization (45 files across 10+ subdirectories). (6) Consider whether docs/ and latex/ and typst/ should remain under Theories/Bimodal/ or move to project root.

---

### 142. Mixed-case countermodel for bx_completeness
- **Effort**: 45-75 hours
- **Status**: [RESEARCHED]
- **Research**:
  - [specs/142_mixed_case_countermodel/reports/01_mixed-case-research.md]
  - [142_mixed_case_countermodel/reports/02_team-research.md]
- **Task Type**: lean4
- **Priority**: high
- **Dependencies**: None (architecturally independent of discrete/dense branches)

**Description**: Resolve the mixed-case sorry in `bx_completeness`: the third branch where neither `box(F'T)` (dense) nor `box(U(T,bot))` (discrete) is in the MCS. Currently `dd_countermodel_chronicle_mixed_sorry` (ChronicleToCountermodel.lean:3327) is a bare sorry.

The dense case uses Cantor iso to Q, the discrete case uses chronicle + Reynolds pipeline to Z. The mixed case has some box-accessible worlds that are dense and others discrete, which cannot coexist in a single BFMCS with a fixed domain type D.

**Research candidates**:
1. Product construction: separate dense and discrete countermodels, combine via disjoint union
2. Ultraproduct: Los theorem to merge models
3. BX theorem: derive contradiction showing mixed case is inconsistent
4. Enriched frames: domain accommodating both dense and discrete regions
5. Reduction: show mixed case reduces to one of the other two via modal reasoning

Task 122 research report (Section 4) has preliminary analysis. Requires dedicated research before planning.

**Definition of done**: `dd_countermodel_chronicle_mixed_sorry` sorry-free, `#print axioms bx_completeness` shows no `sorryAx`, `lake build` passes.

**Files**: `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean`, `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean`.

---

### 130. Archive dead sorries to Boneyard
- **Effort**: 4-8 hours
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Priority**: medium
- **Dependencies**: 129

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

### 125. Jónsson-Tarski representation theorem for bimodal S/U/□ logic
- **Effort**: 15-25 hours
- **Status**: [NOT STARTED]
- **Task Type**: formal
- **Dependencies**: 123, 124, 122, 116, 115

**Description**: Research algebraic methods for establishing a Jónsson-Tarski-style representation theorem for the bimodal logic TM with primitives Since (S), Until (U), and Box (□), plus material implication (→) and bottom (⊥). Key questions: (1) Does standard n-ary BAO representation apply directly to binary S/U + unary □, or does S5 interaction complicate things? (2) Role of orthodox axiomatizability (no IRR rule) per Venema 1993. (3) Can TenseS5Algebra.lean extend to a full BAO with S/U? (4) Relationship between parametric representation and Jónsson-Tarski. (5) Interaction of Prior-UZ/SZ and uniformity axioms with the algebraic representation. Literature: Venema 1991 Ch2+AppA, Venema 1993 Anti-Axioms, GHV 2003, Venema 1997, de Rijke-Venema 1995, BdRV 2001 Ch5.

---

### 122. Build discrete BFMCS on ℤ and complete discrete countermodel
- **Effort**: 8-15 hours
- **Status**: [RESEARCHED]
- **Task Type**: lean4
- **Priority**: high
- **Dependencies**: 123
- **Research**: [specs/122_build_discrete_bfmcs_and_complete_countermodel/reports/01_discrete-bfmcs-research.md]

**Description**: Build discrete BFMCS on ℤ and complete `dd_countermodel_chronicle_nondense_sorry`. Mirror the dense case pattern: use `discrete_fmcs` (already exists) to build a `BFMCS Int` with restricted coherence properties, then wire into parametric representation for the countermodel. Located at ChronicleToCountermodel.lean:836.

---

### 126. Four-tier frame hierarchy: Base → Dense/Discrete → Integer extensions
- **Effort**: 15-25 hours
- **Status**: [RESEARCHED]
- **Task Type**: lean4
- **Dependencies**: 123, 129
- **Research**: [specs/126_frame_hierarchy_dense_discrete_integer_extensions/reports/01_frame-hierarchy-research.md]

**Description**: Establish a four-tier axiom hierarchy with explicit frame correspondence. Tier 0 (Base): BX axioms sound on all linear orders. Tier 1a (Dense): base + density axiom GGp→Gp (characterizes DenselyOrdered). Tier 1b (Discrete): base + next_top=U(⊤,⊥) (characterizes SuccOrder/PredOrder). Tier 2 (Integer): discrete + Prior-UZ + Prior-SZ + Z1 (characterizes IsSuccArchimedean). Split valid_discrete/valid_integer, add Axiom.frameClass variants, update soundness dispatch, prove Sahlqvist-style frame correspondence for each extension axiom.

---

### 116. Redefine G, H, F, P in terms of U and S following Burgess 1982
- **Effort**: 15-25 hours
- **Status**: [PLANNED]
- **Task Type**: lean4
- **Dependencies**: 107
- **Research**: [specs/116_redefine_ghfp_via_until_since/reports/01_redefine-ghfp-research.md]
- **Plan**: [116_redefine_ghfp_via_until_since/plans/01_redefine-ghfp-plan.md]

**Description**: Remove `all_future` (G) and `all_past` (H) as primitive constructors from the `Formula` inductive type. Define F and P as abbreviations using `untl`/`snce` with ⊤, then G and H as ¬F¬ and ¬P¬, matching Burgess 1982 §1.1. `box` (□) remains primitive (S5 modal operator). ~3200 references across codebase. Should be done AFTER task 107 Phase 9 (convention migration) to avoid double-refactoring.

---

### 114. Add plan-compliance rule for implementation agents
- **Effort**: small
- **Status**: [NOT STARTED]
- **Task Type**: meta
- **Priority**: high

**Description**: Add a `.claude/rules/` rule enforcing plan compliance for implementation agents. Root cause: lean-implementation-agent invented a "theorems-as-interval" shortcut for task 107 Phase 1 instead of following the planned Burgess D₀ seed construction. The agent definition, skill, and workflow docs tell agents HOW to execute (lean_goal, phase markers, builds) but never say they MUST follow the plan's specified approach. The rule must state: (1) agents MUST implement the plan's specified approach, not invent alternatives; (2) if agent believes a simpler approach exists, MUST write a handoff recommending `/revise` and return partial — never implement the alternative silently; (3) plan task items are binding specifications, not suggestions.

---

### 112. Systematic literature study for task 107 representation theorem
- **Effort**: medium
- **Status**: [RESEARCHED]
- **Task Type**: formal
- **Research**: [specs/112_literature_study_representation_theorem/reports/01_team-research.md]

**Description**: Review 5 non-original literature sources (Burgess 1982b, Venema 1993, Obendrauf 2024, Burgess 1984, Thomason 1984) for relevance to the task 107 representation theorem. Assess how each source's techniques relate to the three-layer infrastructure problem (g-function, guard conventions, domain extension) and the hybrid approach identified in task 107 research round 15.

---

### 95. Verification audit: #print axioms + sorry classification pass
- **Effort**: 2-4 hours
- **Status**: [NOT STARTED]
- **Language**: lean4
- **Priority**: medium
- **Dependencies**: Tasks 93, 109
- **Created**: 2026-04-10
- **Related**: Tasks 60, 93, 109

**Description**: Verification pass to confirm sorry-free completeness after task 109 closes the chain construction sorries. (1) Run `#print axioms` on `bx_completeness`; confirm output is exactly `{propext, Classical.choice, Quot.sound}` with no `sorry` dependency. (2) Classify all `sorry` occurrences in `Soundness.lean` and `SoundnessLemmas.lean` (real sorry vs docstring/comment). (3) Confirm `soundness`, `soundness_dense`, `soundness_discrete` build with only standard axioms. (4) Audit for any custom Lean `axiom` declarations (expected: possibly `discrete_Icc_finite_axiom` per task 60). (5) Produce audit report at `specs/reviews/completeness-audit-{DATE}.md`. Depends on task 109 for full completeness verification.

---

### 68. Prove dense_completeness_fc via Rat canonical model
- **Effort**: 6-10 hours
- **Status**: [RESEARCHED]
- **Language**: lean4
- **Dependencies**: Task #72
- **Parent Task**: #58
- **Research**: [83_spawn-analysis.md](058_wire_completeness_to_frame_conditions/reports/83_spawn-analysis.md)

**Description**: Eliminate the sorry in dense_completeness_fc (FrameConditions/Completeness.lean line 121) by constructing a canonical model over Rat. Int cannot be used because Int is not densely ordered. Rat is countable, aligning with existing Lindenbaum/countable MCS machinery.

**Hint**: BX5 self-accumulation (`(φ U ψ) → ((φ ∧ (φ U ψ)) U ψ)`) is the key to dense guard population — it propagates the Until formula itself through the interval, making each intermediate point contain `φ` via BX9 `until_elim`. Use Cantor-domain chain construction over a countable dense order, with interval-filling for Until guards.

---

### 64. Critical path review: algebraic analysis of completeness obstacles
- **Effort**: Research task
- **Status**: [RESEARCHED]
- **Language**: lean4
- **Research**:
  - [01_critical-path-analysis.md](064_critical_path_review/reports/01_critical-path-analysis.md)
  - [02_team-research.md](064_critical_path_review/reports/02_team-research.md)

**Description**: Multi-agent review of the critical path tasks (58-60) for accuracy, identification of gaps, and algebraic strategy analysis. Key findings:

**Sorry inventory correction**: Actual sorry count is 25 (not 98 per ROADMAP). SuccChain sorries (24) removed in task 56. Perpetuity bridge (16) all proven. Publication-path sorries: 9 (tasks 58+59 only). The ROADMAP Class A/B distinction is moot — the SuccChain approach was abandoned.

**TODO.md accuracy**: Task descriptions are accurate on locations and content. Task 59 is incorrectly marked as dependent on 58 — it's parallelizable. Task 58's description understates the obstacle: the real blocker is temporal coherence construction, not wiring.

**Central obstacle**: `construct_bfmcs` requires `B.temporally_coherent` proof. The deprecated implementation depends on the false `f_nesting_is_bounded`. The entire 5,300-line sorry-free algebraic path reduces to this single callback.

**Algebraic resolution strategies identified**:
- **(A) Zorn on R_G-chains**: Maximal chains through R_□-class exist; challenge is matching order type of D.
- **(B) Temporal shift automorphism**: Define τ on Lindenbaum algebra; FMCS = {τᵗ(U)}. Challenge: G is not invertible.
- **(C) Restricted chain + σ-duality** (recommended): Forward chain is sorry-free; use σ-duality for backward chain; dovetail into FMCS over ℤ. Shortest path leveraging existing infrastructure.

**STSA status**: Typeclass and LindenbaumAlg instance are fully sorry-free (TenseS5Algebra.lean, 350 lines). The STSA representation theorem (task 992) is a reorganization of existing code, not on critical path but provides the elegant algebraic framing.

**Custom axiom inventory**: Only `discrete_Icc_finite_axiom` remains (task 60). The `f_nesting_boundary` and `p_nesting_boundary` axioms were eliminated in task 56.

---

### 60. Clean up stale discrete_Icc_finite_axiom references
- **Effort**: 1-2 hours
- **Status**: [NOT STARTED]
- **Language**: lean4

**Description**: discrete_Icc_finite_axiom was already eliminated (zero custom axioms confirmed). Remaining scope: clean up stale docstrings in FrameClass.lean and SuccExistence.lean that still reference the removed axiom.

### 21. Clean up technical debt from tasks 9-20
- **Effort**: 3-5 hours
- **Status**: [IMPLEMENTING]
- **Language**: lean4
- **Dependencies**: Tasks 15, 18
- **Plan**: [01_tech-debt-cleanup-plan.md](021_technical_debt_cleanup/plans/01_tech-debt-cleanup-plan.md) — 6 phases: axiom elimination, dead-code resolution, documentation
- **Research**:
  - [01_tech-debt-audit.md](021_technical_debt_cleanup/reports/01_tech-debt-audit.md) — comprehensive 4-agent parallel audit of all code from tasks 9-20
  - [02_team-research.md](021_technical_debt_cleanup/reports/02_team-research.md) — synthesized team research: axiom classification, derivation priorities, action plan
  - [02_teammate-a-findings.md](021_technical_debt_cleanup/reports/02_teammate-a-findings.md) — axiom semantic validity analysis
  - [02_teammate-b-findings.md](021_technical_debt_cleanup/reports/02_teammate-b-findings.md) — axiom proof dependencies and derivation paths
  - [02_teammate-c-findings.md](021_technical_debt_cleanup/reports/02_teammate-c-findings.md) — frame condition theory analysis

**Description**: Pay down technical debt accumulated across the metalogic refactoring track (tasks 9-20). Systematic cleanup in 4 phases: (1) **Dead code removal** — delete redundant lemmas in CanonicalTaskRelation.lean (iter_F_succ_eq, CanonicalTask_neg_succ_nat, 3 unused accessors), unused helpers in TimelineQuotBFMCS.lean (6 items), deprecated dead-end code in AlgebraicBaseCompleteness.lean (2 items). (2) **Deprecation marking** — mark discreteTaskFrame/denseTaskFrame as deprecated in DurationTransfer.lean, evaluate CanonicalRecovery.lean compat wrappers. (3) **Bridge assessment** — evaluate ClosedFlagIntBFMCS.lean bridge for simplification, assess downstream usage of compat wrappers, document dovetailing gap resolution path. (4) **Deferred items** — re-audit after tasks 18-20 complete to capture final debt state. Note: Tasks 18 (researching), 19 (not started), and 20 (not started) may introduce or resolve additional debt.

---

### 20. Audit and update parametric canonical infrastructure
- **Effort**: 2-3 hours
- **Status**: [NOT STARTED]
- **Language**: lean4
- **Dependencies**: Tasks 15, 18
- **Research (task 6)**:
  - [19_role-in-representation-theorems.md](006_canonical_taskframe_completeness/reports/19_role-in-representation-theorems.md) §2.2–2.3, §7 open question 3 — current duration-coarse relation vs duration-precise alternatives, question of parametric unification
  - [18_dense-three-place-task-relation.md](006_canonical_taskframe_completeness/reports/18_dense-three-place-task-relation.md) §4.3 — unified TaskFrame view showing both discrete/dense cases instantiate the same structure

**Description**: Review ParametricCanonical.lean, ParametricTruthLemma.lean, and ParametricRepresentation.lean. Determine whether the parametric infrastructure can be refactored to accept a generic task_rel parameter (not hardcoded duration-coarse relation), enabling both CanonicalTask and DenseTask as instantiations. If feasible, refactor; otherwise document the relationship between parametric (base) and specialized (discrete/dense) paths.

---

### 18. Complete dense representation theorem via DenseTask
- **Effort**: 6-7 hours
- **Status**: [BLOCKED]
- **Language**: lean4
- **Dependencies**: Tasks 17, 27, 30, 31
- **Research (task 6)**:
  - [18_dense-three-place-task-relation.md](006_canonical_taskframe_completeness/reports/18_dense-three-place-task-relation.md) §5 — replacing CanonicalR with DenseTask in the dense setting, truth condition restatement
  - [19_role-in-representation-theorems.md](006_canonical_taskframe_completeness/reports/19_role-in-representation-theorems.md) §3.2, §6 dense table — full wiring of dense representation pipeline, use of timelineQuot_instantiate_dense to close the domain mismatch
- **Research**:
  - [01_dense-representation-research.md](018_dense_representation_theorem_completion/reports/01_dense-representation-research.md)
  - [02_team-research.md](018_dense_representation_theorem_completion/reports/02_team-research.md) — team research: blocker analysis, domain confusion, correct approach
  - [05_team-research.md](018_dense_representation_theorem_completion/reports/05_team-research.md) — team research run 2: 7 real sorries, revised 4-phase plan A-D, no closure operator needed
  - [13_post-task27-analysis.md](018_dense_representation_theorem_completion/reports/13_post-task27-analysis.md) — post-task27: 4 localized sorries in j>0 termination, DovetailedTimelineQuot integration
- **Plan**: [04_dense-representation-v4.md](018_dense_representation_theorem_completion/plans/04_dense-representation-v4.md) — v4: post-task27 using DovetailedTimelineQuot, 3 remaining phases
- **Summary**: [03_implementation-summary.md](018_dense_representation_theorem_completion/summaries/03_implementation-summary.md) — Phases 1-2 complete (v3), plan revised for phases 3-5

**Description**: Wire the TimelineQuot BFMCS and DenseTask-based TaskFrame ℚ into the unconditional dense representation theorem: valid_dense φ → ⊢_dense φ. Instantiate parametric truth lemma with D=TimelineQuot (which carries DenselyOrdered). Use timelineQuot_instantiate_dense to instantiate valid_dense at D=TimelineQuot. Resolves the Task 988 blocker via the DenseTask framework.

**Hint**: BX5 self-accumulation (`(φ U ψ) → ((φ ∧ (φ U ψ)) U ψ)`) is the key to dense guard population — it propagates the Until formula itself through the interval, making each intermediate point contain `φ` via BX9 `until_elim`. Use Cantor-domain chain construction over a countable dense order, with interval-filling for Until guards.

---

### 8. Establish genuine truth_at completeness theorems for TM logic
 **Effort**: 12-20 hours
 **Status**: [RESEARCHED]
 **Language**: lean4
 **Dependencies**: Task #1007
 **Research**:
  - [01_completeness-architecture.md](008_genuine_truth_at_completeness/reports/01_completeness-architecture.md)
  - [02_completeness-blockers.md](008_genuine_truth_at_completeness/reports/02_completeness-blockers.md)
  - [03_team-research.md](008_genuine_truth_at_completeness/reports/03_team-research.md)
  - [04_team-research.md](008_genuine_truth_at_completeness/reports/04_team-research.md)
 **Plan**: [03_revised-completeness-plan.md](008_genuine_truth_at_completeness/plans/03_revised-completeness-plan.md)

**Description**: Establish genuine completeness theorems for base, dense, and discrete TM logic using the official `truth_at` semantics over `TaskFrame D` with convex `WorldHistory` structures — not the internal `satisfies_at` substitute. The existing parametric infrastructure (ParametricCanonicalTaskFrame, ParametricTruthLemma, ParametricRepresentation) is already sorry-free and correctly uses `truth_at` with `domain = True` (trivially convex). The core open problem is constructing a multi-family `BFMCS D` satisfying both modal coherence (modal_backward requires multiple families, not singleton) and temporal coherence (forward_F/backward_P — linear chain constructions via Lindenbaum extension cannot satisfy these because F-witnesses escape the chain). CanonicalFMCS over CanonicalMCS solves F/P trivially but CanonicalMCS lacks AddCommGroup/LinearOrder. The gap is bridging sorry-free CanonicalMCS results to a concrete D (Int for base/discrete, Rat for dense). Supersedes tasks 997, 988, 989 in approach (those tasks remain as they track the individual completeness legs).

**Hint (dense leg)**: BX5 self-accumulation (`(φ U ψ) → ((φ ∧ (φ U ψ)) U ψ)`) is the key to dense guard population — it propagates the Until formula itself through the interval, making each intermediate point contain `φ` via BX9 `until_elim`. Use Cantor-domain chain construction over a countable dense order, with interval-filling for Until guards.

---

### 998. Redesign FMP filtration for strict temporal semantics
- **Effort**: TBD (estimated 4-8 hours)
- **Status**: [RESEARCHED]
- **Language**: lean4
- **Priority**: high
- **Related**: Tasks 74-77 (strict temporal extensions research track)

**Description**: Redesign the FMP (Finite Model Property) filtration for strict temporal semantics. The 2 sorry'd theorems in `Decidability/FMP/TruthPreservation.lean` — `mcs_all_future_closure` (line 263) and `mcs_all_past_closure` (line 281) — are deprecated because the temporal T-axiom (`Gφ → φ`) is NOT valid under strict semantics. `filtration_all_future_forward` and `filtration_all_past_forward` depend on them. The FMP module is separate from the main decidability pipeline (`decide` is sorry-free), but completing it formally proves the finite model property. Resolution options: (A) restrict FMP statement to serial frames where temporal seriality holds, (B) redesign filtration to avoid temporal reflexivity entirely, (C) prove the filtered model satisfies a weaker correctness property sufficient for the FMP theorem. Note: `mcs_finite_model_property` in `FMP.lean` does NOT directly use these sorry'd lemmas, so the impact is localized to `filtration_all_future_forward`/`backward`.

---


### 992. Implement Shift-Closed Tense S5 Algebra representation theorem
- **Effort**: TBD
- **Status**: [RESEARCHED]
- **Language**: lean
- **Research**: [01_stsa-algebraic-analysis.md](992_shift_closed_tense_s5_algebra/reports/01_stsa-algebraic-analysis.md)

**Description**: Implement the Shift-Closed Tense S5 Algebra (STSA) representation theorem. Define STSA as a Lean structure extending BooleanAlgebra with box, G, H, sigma operators and interaction axioms. Lift temporal duality sigma from swap_temporal to the Lindenbaum quotient. Prove LindenbaumAlg is an STSA instance by wiring existing pieces (BooleanStructure, InteriorOperators, UltrafilterMCS). Restructure ParametricRepresentation into unified STSA representation theorem. Research report 001 provides complete algebraic analysis with ~80% of formalization already existing.

---


### 953. Refactor proof system to bilateral system
- **Effort**: 55-90 hours
- **Status**: [RESEARCHED]
- **Language**: lean
- **Priority**: medium
- **Research**: [research-001.md](specs/953_refactor_proof_system_to_bilateral/reports/research-001.md), [research-002.md](specs/953_refactor_proof_system_to_bilateral/reports/research-002.md), [research-003.md](specs/953_refactor_proof_system_to_bilateral/reports/research-003.md)

**Description**: Refactor the TM proof system from a unilateral system (single judgment `Γ ⊢ φ`) to a bilateral system with dual judgments: acceptance (`Γ ⊢⁺ φ`) and rejection (`Γ ⊢⁻ φ`). The bilateral system makes the dual roles of assertion and denial explicit, with rules governing how acceptance and rejection interact across all connectives and operators. Key design: keep Formula type unchanged (Option A), add BilateralDeriv alongside existing DerivationTree with a proven equivalence bridge. Several current axioms (ex_falso, peirce, modal_t, temp_t_future, temp_t_past) become structural rules in the bilateral system. The existing signed formula infrastructure in the decidability module provides the blueprint.

**Research summary (research-003)**: Cost-benefit analysis recommends deferring bilateral refactor until higher-priority tasks (981: axiom debt, 951: completeness) progress. Benefits are primarily theoretical (assertion/denial duality, tableau alignment); existing unilateral system is adequate. Parallel-system approach (Option A) minimizes risk.

**Implementation approach**: Parallel bilateral system with equivalence bridge — not a replacement. Phase 1: bilateral infrastructure (BilateralContext, BilateralDeriv). Phase 2: prove equivalence with unilateral system. Phase 3: bilateral metalogic (MCS, FMCS, completeness). Phase 4: bilateral decidability integration.

---

### 949. Update Demo.lean for current bimodal logic state
- **Effort**: Small (~2 hours)
- **Status**: [RESEARCHED]
- **Language**: lean
- **Research**: [research-001.md](specs/949_update_demo_lean_bimodal_logic/reports/research-001.md)

**Description**: Update Theories/Bimodal/Examples/Demo.lean given the current state of the bimodal logic. The demo file should reflect the current API and showcase the working features of the bimodal logic implementation.

---

### 619. Migrate skills to native context:fork isolation
- **Effort**: 3 hours
- **Status**: [PLANNING]
- **Researched**: 2026-02-17
- **Language**: meta
- **Created**: 2026-01-19
- **Researched**: 2026-01-28
- **Planned**: 2026-01-19
- **Blocked on**: GitHub anthropics/claude-code #16803 (context:fork runs inline instead of forking)
- **Research**: [research-001.md](specs/archive/619_agent_system_architecture_upgrade/reports/research-001.md), [research-006.md](specs/archive/619_agent_system_architecture_upgrade/reports/research-006.md), [research-007.md](specs/619_agent_system_architecture_upgrade/reports/research-007.md)
- **Plan**: [implementation-002.md](specs/archive/619_agent_system_architecture_upgrade/plans/implementation-002.md)

**Description**: Migrate all delegation skills from manual Task tool invocation to native `context: fork` frontmatter. Skills to migrate: skill-researcher, skill-lean-research, skill-planner, skill-implementer, skill-lean-implementation, skill-latex-implementation, skill-meta. Implementation plan has 3 phases: (1) verify bug fix with test skill, (2) migrate skill-researcher as pilot, (3) migrate remaining skills. Current workaround (Task tool delegation) continues to work. **Unblock when**: GitHub #16803 is closed AND fix verified locally. Last checked: 2026-02-17 — still OPEN (v2.1.32).

