---
next_project_number: 185
repository_health:
  overall_score: 95
  production_readiness: near-publication
  last_assessed: 2026-05-22T00:00:00Z
task_counts:
  active: 23
  completed: 134
  in_progress: 1
  not_started: 20
  abandoned: 0
  total: 149
technical_debt:
  sorry_count: 1
  sorry_count_note: "Audited 2026-05-15: 1 root sorry on bx_completeness critical path: succ_cofinal (ChronicleToCountermodel.lean:1885) blocks limitDomSubtype_isSuccArchimedean → succ_embed_surjective → discrete countermodel → bx_completeness. Dense case sorry-free (dd_countermodel_chronicle_dense). Mixed case sorry-free (dd_countermodel_chronicle_mixed_sorry via False.elim, task 142). Tasks 143-148 closed NormalForm/KType/table_correctness sorries. Reynolds pipeline bypass (task 155) in progress. ~17 dead-code sorries in BXCanonical pipeline (bypassed by Chronicle). ~6 non-critical TruthLemma sorries. Soundness, SoundnessLemmas, and Decidability are sorry-free. Zero axioms in Separation module (tasks 157, 171)."
  publication_path_sorries: 1
  axiom_count: 0
  axiom_count_note: "Zero custom axioms. Prior-UZ/SZ and discrete_box_necessity are standard axiom constructors with sorry-free soundness proofs. Separation module has zero axioms (tasks 157, 171 eliminated all 9)."
  build_errors: 0
  status: excellent
---

# TODO

<!-- Vault transition: 2026-03-20 - Archived to specs/vault/01-vault/ -->

## Task Order

*Updated 2026-05-22. 23 active tasks.*

**Goal**: Sorry-free `bx_completeness` → purge dead code → FrameClass refactor → split/rename/clean → publication-quality codebase.

**Execution Pipeline**:

```
Parallel now:
  155 (Reynolds pipeline — sorry-free bx_completeness)
  181 (Derivable Prop wrapper — independent, small)

After 155:
  Wave 1b: 176, 95                                     (post-155 cleanup)
  Wave 3:  168 → 174 → 175 → 180 → 131 → 161          (deep refactor)
  Wave 4:  183 → 177 → 178                             (documentation + polish)
```

### Active — Parallel Work

155 [IMPLEMENTING] — Reynolds pipeline: eliminate succ_cofinal from bx_completeness
181 [PLANNED] — Add Derivable Prop-valued wrapper alongside DerivationTree

### Completed Research (informs Wave 3)

179 [RESEARCHED] — Research Lean 4 best practices (informs 175, 180, 181)

### Wave 1b — Post-155 Cleanup (blocked on 155)

176 [NOT STARTED] — Relocate Chronicle/ out of BXCanonical/, archive dead BXCanonical subtree
  └─ 155
95 [NOT STARTED] — Verification audit: `#print axioms` + sorry classification pass
  └─ 155

### Wave 3 — Deep Refactor (sequential chain)

168 [NOT STARTED] — Parameterize DerivationTree over FrameClass (the linchpin refactor)
174 [NOT STARTED] — Split oversized files (9 files > 1400 lines)
  └─ 168
175 [RESEARCHED] — Naming conventions + bridge/wrapper cleanup
  └─ 168, 174
180 [NOT STARTED] — Copyright headers, universe polymorphism, 100-char line limits
  └─ 174
131 [NOT STARTED] — Restructure Theories/Bimodal/ file hierarchy for clean APIs
161 [NOT STARTED] — Rename Theories/Bimodal/ to final namespace (LAST)

### Wave 4 — Documentation & Final Polish

183 [PLANNED] — Documentation standards: directory READMEs, module docstrings, comment conventions
  └─ 131, 175
177 [NOT STARTED] — Update README and all module docstrings
  └─ 183
178 [NOT STARTED] — Publication examples and demo
  └─ 131

### Deferred — New Features (post-publication)

169 [NOT STARTED] — Complete frame extension: axiom, typeclass, soundness, correspondence
  └─ 168
170 [NOT STARTED] — Completeness theorem for TM^dc (dense + complete)
  └─ 169
127 [NOT STARTED] — Add time addition operator (+) for bimodal logic TM
128 [NOT STARTED] — Add topological open set (interior) operator
165 [NOT STARTED] — Establish semantic finite model property (filtration)
164 [NOT STARTED] — Prove tableau correctness (connect decide to semantic validity)
  └─ 165
125 [NOT STARTED] — Jónsson-Tarski representation theorem for TM logic

### Meta/Tooling

162 [NOT STARTED] — Enforce strict plan compliance for formal implementation agents
156 [NOT STARTED] — Multi-angle team research strategy for formal agents


## Tasks

### 183. Documentation standards: directory READMEs, module docstrings, comment conventions
- **Effort**: large (15-25 hours)
- **Status**: [PLANNED]
- **Research**: [specs/183_documentation_standards_readmes_comments/reports/01_documentation-audit.md]
- **Task Type**: lean4
- **Dependencies**: 131, 175
- **Plan**: [183_documentation_standards_readmes_comments/plans/01_documentation-standards.md]

**Description**: Establish and apply a comprehensive documentation standard for the entire `Theories/Bimodal/` tree, then systematically update every README and docstring in the repository to be accurate and complete. This task defines the standard AND applies it after structural refactoring (tasks 131, 175) is complete. Four deliverables:

**A) Directory README standard + systematic update**: Every directory under `Theories/Bimodal/` must have a `README.md` with: (1) one-paragraph purpose statement, (2) module inventory table (file | lines | status | description), (3) cross-links to related directories (dependencies and dependents), (4) key definitions/theorems exported. Currently missing READMEs: `FrameConditions/`, `Metalogic/BXCanonical/`, `Metalogic/WeakCanonical/`, `latex/build/`. Existing READMEs vary wildly in style — normalize all to the template. **Critically**: every existing README must be audited for accuracy — many contain stale file counts, reference deleted modules, describe superseded architectures, or list wrong sorry counts. The update must be systematic: script-assisted where possible (e.g., auto-generating module inventory tables from `find` + `wc -l`, cross-checking listed files against actual directory contents) to ensure no README is left stale. The top-level `Theories/Bimodal/README.md`, `Metalogic/README.md`, and all subdirectory READMEs must reflect the post-refactoring state with accurate file inventories, dependency descriptions, and status information.

**B) Module docstring standard**: Every `.lean` file must have a `/-! ... -/` module docstring as its first non-import block containing: (1) one-line summary, (2) 2-3 sentence description of purpose and role, (3) key definitions/theorems listed, (4) cross-references to related modules. Currently 152 active files with inconsistent or missing docstrings. Audit all and bring to standard.

**C) Comment convention standard**: Define and enforce: (1) No multi-line removal/archived/tombstone comments in active code (those go in git history). (2) `-- NOTE:` for non-obvious invariants or constraints. (3) `-- FIX:` for known issues requiring attention. (4) No `#check` in library code (only in Examples/). (5) No commented-out code blocks. (6) Docstrings on all public `theorem`/`def`/`structure` declarations that form the module's API. Write the standard as a reference document at `Theories/Bimodal/docs/reference/documentation-standard.md` and then apply it across the codebase.

**D) Root-level documentation**: Update the project `README.md` at repository root and `Theories/Bimodal/README.md` to accurately reflect final architecture, sorry status, axiom inventory, directory structure, and build instructions. Ensure cross-links between all READMEs form a navigable web — every README should link to its parent, its children, and its key lateral dependencies so a reader can traverse the project structure from any entry point.

---

### 181. Add Derivable Prop-valued wrapper alongside DerivationTree
- **Effort**: small (3-5 hours)
- **Status**: [PLANNED]
- **Research**: [specs/181_derivable_prop_wrapper/reports/01_derivable-prop-wrapper.md]
- **Task Type**: lean4
- **Plan**: [181_derivable_prop_wrapper/plans/01_derivable-prop-wrapper.md]

**Description**: Add a `Derivable` Prop-valued wrapper (`def Derivable (Γ : Context) (φ : Formula) : Prop := Nonempty (DerivationTree Γ φ)`) alongside the existing Type-valued `DerivationTree`. This enables `simp` and `aesop` integration for derivability goals (which failed on the Type-valued tree due to proof reconstruction errors) while preserving the existing computable proof tree structure for height functions, pattern matching, and the Metalogic infrastructure. Add basic `Derivable` lemmas mirroring the key `DerivationTree` constructors (modus_ponens, axiom, weakening, necessitation) and a `Derivable.ofTree` coercion. Per task 179 research report `02_mathlib-submission.md`.

---

### 180. Add copyright headers, universe polymorphism, and 100-char line limits
- **Effort**: medium (6-10 hours)
- **Status**: [NOT STARTED]
- **Task Type**: lean4

**Description**: Add Mathlib-compatible copyright headers to all Lean files (currently missing on all ~207 files). Adopt universe polymorphism where appropriate (`Type*` instead of `Type`), particularly in Semantics/ and FrameConditions/ where structures should be universe-polymorphic. Enforce 100-character line limit throughout the codebase for Mathlib style compliance. This is a prerequisite for any future Mathlib contribution and improves code quality for the standalone library. Per task 179 research report `02_mathlib-submission.md`.

---

### 179. Research Lean 4 best practices and infrastructure for tactics and derived theorems
- **Effort**: large (20-30 hours)
- **Status**: [RESEARCHED]
- **Task Type**: lean4
- **Research**:
  - [specs/179_research_lean4_tactics_infrastructure/reports/01_team-research.md]
  - [specs/179_research_lean4_tactics_infrastructure/reports/02_mathlib-submission.md]

**Description**: Research best practices for Lean 4 in 2026 online and in Mathlib to design a systematic library of tactics, derived theorems in the proof theory, semantic lemmas, and other general results that streamline codebase refactoring and raise overall code quality. In anticipation of completing task 155, cleaning up tasks 176 and 95, and beginning a deep refactor of completed theorems, investigate appropriate metaprogramming, custom tactics, derivation infrastructure, and organizational patterns to achieve the best structure throughout the implementation.

---

### 178. Publication examples and demo
- **Effort**: small (4-6 hours)
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Priority**: low
- **Dependencies**: 131

**Description**: Expand `Examples/` with publication-quality demonstrations of the full verified pipeline. Add a complete worked example showing soundness-completeness-decidability on a concrete formula. Add examples exercising each frame class (Base, Dense, Discrete) with the FrameClass-parameterized `DerivationTree` from task 168. Add examples of the expressive completeness result (separation theorem). Update `BimodalProofs.lean` and `TemporalStructures.lean` to use current API conventions. All examples sorry-free.

---

### 177. Update README and all module docstrings
- **Effort**: small (3-5 hours)
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Priority**: medium
- **Dependencies**: 131, 175

**Description**: Final documentation pass after all structural refactoring is complete. Update `README.md` axiom counts, architecture diagram, and sorry obligations section. Ensure every file in the final structure has an accurate `/-! ... -/` module docstring reflecting its role. Update `ROADMAP.md` to reflect completed refactoring. Verify Axiom Reference doc against actual constructors.

---

### 176. Relocate Chronicle and archive dead BXCanonical subtree
- **Effort**: medium (4-6 hours)
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Priority**: medium
- **Dependencies**: 155

**Description**: Resolve architectural confusion where `Chronicle/` lives under `BXCanonical/` but is only consumed by `WeakCanonical/`. Move 6 Chronicle files (14,331 lines) to `Metalogic/Chronicle/` or `WeakCanonical/Chronicle/`. Archive entire non-Chronicle BXCanonical subtree (16 files, 4,615 lines, 19 mathematically false sorries under irreflexive semantics) to `Boneyard/BXCanonical/`. Verify `OrderedSeedConsistency.lean` dependency from `WeakCanonical/ReflexiveCanonical.lean` before archiving. Update aggregator imports. Subsumes part of task 130 scope (the BXCanonical dead-code sorries).

---

### 175. Naming convention and bridge/wrapper cleanup
- **Effort**: medium (6-10 hours)
- **Status**: [RESEARCHED]
- **Research**: [specs/175_naming_convention_and_bridge_cleanup/reports/01_team-research.md]
- **Task Type**: lean4
- **Priority**: medium
- **Dependencies**: 168, 174

**Description**: Normalize naming conventions to follow Mathlib-style descriptive conventions and eliminate bridge/wrapper indirection for publication quality. Adopt Mathlib naming patterns: `bot_of_and_neg` instead of `ecq`, `and_left` instead of `lce`, `and_right` instead of `rce`, `or_inl` instead of `ldi`, `or_inr` instead of `rdi`, `absurd` instead of `raa`, `False.elim` instead of `efq`, `not_not_intro` instead of `dni`, etc. Expand opaque abbreviations (`bfmcs`, `drm`, `cud`, `sdc`, `dd_`, `tc_`, `fuc_`, `buc_`). Inline or remove `Bridge.lean` wrappers (993 lines, 16 forwarding definitions). Eliminate trivial primed variants. Normalize `z1_valid` to `axiom_z1_valid` for consistency. Rename `temp_` prefix to `temporal_` for clarity. Purge 81 removed/archived/superseded tombstone comments. Reference Mathlib naming conventions guide and task 179 research report `specs/179_research_lean4_tactics_infrastructure/reports/02_mathlib-submission.md` for the full mapping.

---

### 174. Split oversized files (> 1500 lines)
- **Effort**: medium (8-12 hours)
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Priority**: medium
- **Dependencies**: 168

**Description**: Split Lean files exceeding ~1500 lines into focused modules. Targets: `Hierarchy.lean` (3845 lines — split by induction level), `SoundnessLemmas.lean` (2422 lines — split after task 168 collapses 4 near-duplicate frame-class blocks), `DedekindZ.lean` (2236), `ExpressiveCompleteness.lean` (2129), `SubformulaClosure.lean` (1889 in Syntax/), `Propositional.lean` (1712 in Theorems/), `Tactics.lean` (1416), `RestrictedMCS.lean` (1413), `ProofSearch.lean` (1384). Each split file should have a clear single responsibility and a module docstring.

---

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


### 156. Improve formal/lean/math/logic research agents with multi-angle team research strategy
- **Effort**: 4-8 hours
- **Status**: [NOT STARTED]
- **Task Type**: meta
- **Priority**: medium

**Description**: Improve formal/lean/math/logic research agents with multi-angle team research strategy. In the task 154 research cycle, a proof blocker persisted through multiple single-agent rounds. What broke through was launching 4 parallel agents each assigned a distinct angle: (A) backward from sorry sites using lean_goal/lean_multi_attempt, (B) infrastructure inventory with exact signatures and gap analysis, (C) literature review assessing approach soundness, (D) decomposition into small lemmas with lean_run_code verification. Improvements: (1) Add multi-angle analysis mode to lean-research-agent, (2) Always try lean_multi_attempt/lean_run_code to verify solutions compile, (3) Add guidance for when to recommend team research after repeated blockers, (4) Add prototype-first research pattern, (5) Update formal-research-agent to auto-route to multi-angle team research when multiple handoffs indicate the same blocker.

---

### 155. Activate Reynolds pipeline for sorry-free discrete completeness
- **Effort**: 60 hours
- **Status**: [IMPLEMENTING]
- **Task Type**: lean4
- **Priority**: high
- **Dependencies**: 154
- **Research**:
  - [specs/155_reynolds_pipeline_activation/reports/01_team-research.md]
  - [specs/155_reynolds_pipeline_activation/reports/02_team-research.md]
  - [specs/155_reynolds_pipeline_activation/reports/03_post-157-status.md]
  - [specs/155_reynolds_pipeline_activation/reports/03_team-research.md]
  - [specs/155_reynolds_pipeline_activation/reports/07_ghr93-strategy-review.md]
  - [specs/155_reynolds_pipeline_activation/reports/35_phase1-blocker-prior-art.md]
- **Plan**:
  - [155_reynolds_pipeline_activation/plans/01_reynolds-pipeline-plan.md]
  - [155_reynolds_pipeline_activation/plans/02_reynolds-pipeline-plan.md]
  - [155_reynolds_pipeline_activation/plans/03_reynolds-pipeline-plan.md]
  - [155_reynolds_pipeline_activation/plans/07_reynolds-pipeline-plan.md]
  - [155_reynolds_pipeline_activation/plans/17_reynolds-pipeline-plan.md]

**Description**: Replace the chronicle fallback in Transfer.lean with the full Reynolds Theorem 15 pipeline, eliminating `succ_cofinal` from `bx_completeness`. Rather than bridging `ZIntervalStructure` to `TaskFrame` via an adapter, refactor the pipeline to construct a `TaskFrame Int` directly from the Reynolds output. Wire `chronicle_is_good` (unblocked by task 154), `table_correctness` (sorry-free from tasks 147-148), and a direct `TaskFrame` construction into Transfer.lean. Definition of done: `doets_countermodel_discrete` uses Reynolds pipeline, `bx_completeness` has no `sorryAx`, `lake build` passes.

---

### 131. Refactor module organization for clean APIs and documentation
- **Effort**: 15-25 hours
- **Status**: [NOT STARTED]
- **Task Type**: lean4

**Description**: Restructure Theories/Bimodal/ file hierarchy for clean APIs and documentation. Currently 130 live .lean files across 7 top-level directories, with the Metalogic/ directory being a catch-all containing 7 subdirectories (Algebraic, Bundle, BXCanonical, ConservativeExtension, Core, Decidability, Relational) plus loose files (Soundness.lean, SoundnessLemmas.lean, DenseSoundness.lean, DiscreteSoundness.lean, Completeness.lean, Metalogic.lean). Goals: (1) Reorganize Metalogic/ into a clearer hierarchy — group soundness files into Metalogic/Soundness/, completeness files into Metalogic/Completeness/, clarify relationship between BXCanonical (chronicle approach) and Algebraic (parametric approach). (2) Add module-level documentation (docstrings on namespace declarations, module descriptions at file tops). (3) Establish clean APIs with explicit exports via root .lean files for each subdirectory. (4) Evaluate whether FrameConditions/ should be merged into Metalogic/ or remain separate. (5) Audit Boneyard/ organization (45 files across 10+ subdirectories). (6) Consider whether docs/ and latex/ and typst/ should remain under Theories/Bimodal/ or move to project root.

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



### 95. Verification audit: #print axioms + sorry classification pass
- **Effort**: 2-4 hours
- **Status**: [NOT STARTED]
- **Language**: lean4
- **Priority**: medium
- **Dependencies**: None
- **Created**: 2026-04-10

**Description**: Verification pass on `bx_completeness` sorry status. Updated scope: (1) Verify `dd_countermodel_chronicle_dense` and `dd_countermodel_chronicle_mixed_sorry` show no `sorryAx` (confirmed sorry-free as of 2026-05-15). (2) Trace the discrete case `sorryAx` chain: `dd_countermodel_chronicle_discrete` -> `succ_embed_surjective` -> `limitDomSubtype_isSuccArchimedean` -> `succ_cofinal` (root sorry). (3) Classify all Metalogic/ sorry occurrences as critical-path vs dead-code vs non-critical-path. (4) Update stale axiom audit comments in Completeness.lean (lines 177-234 reference CE:3570 which is no longer the sorry source). (5) Verify soundness and decidability remain sorry-free. (6) Produce audit report.

---

## Recommended Order

