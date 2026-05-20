---
next_project_number: 179
repository_health:
  overall_score: 95
  production_readiness: near-publication
  last_assessed: 2026-05-20T00:00:00Z
task_counts:
  active: 23
  completed: 128
  in_progress: 1
  not_started: 13
  abandoned: 0
  total: 143
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

*Updated 2026-05-20. 23 active tasks. Created 5 refactoring tasks (174-178).*

**Goal**: Sorry-free `bx_completeness` → purge dead code → FrameClass refactor → split/rename/clean → publication-quality codebase.

**Execution Pipeline**:

```
Active: 155 (Reynolds pipeline — sorry-free bx_completeness)

Parallel with 155:
  Wave 1a: 173, 130, 21, 172                (purge dead code — no 155 overlap)

After 155 completes:
  Wave 1b: 176, 95                           (Chronicle relocation, verification)
  Wave 3:  168 → 174 → 175 → 131 → 161     (deep refactor)
  Wave 4:  177 → 178                         (final polish)
```

### Completeness (in progress)

155 [IMPLEMENTING] — Reynolds pipeline: eliminate succ_cofinal from bx_completeness

### Wave 1a — Purge Dead Code (safe to start now, parallel with 155)

173 [RESEARCHED] — Archive 19 dead sorry stubs from TemporalDerived.lean
130 [RESEARCHED] — Archive ~19 dead-code sorries to Boneyard (+ orphaned ConservativeExtension/)
21 [RESEARCHED] — Clean up technical debt: stale docstrings, 81 tombstone comments
172 [RESEARCHED] — Fix stale Metalogic.lean docstring

### Wave 1b — Post-155 Cleanup (blocked on 155)

176 [NOT STARTED] — Relocate Chronicle/ out of BXCanonical/, archive dead BXCanonical subtree
  └─ 155
95 [NOT STARTED] — Verification audit: `#print axioms` + sorry classification pass
  └─ 155

### Wave 3 — Deep Refactor

168 [NOT STARTED] — Parameterize DerivationTree over FrameClass (the linchpin refactor)
174 [NOT STARTED] — Split oversized files (9 files > 1400 lines)
  └─ 168 — (SoundnessLemmas dedup depends on FrameClass parameterization)
175 [NOT STARTED] — Naming conventions + bridge/wrapper cleanup
  └─ 168, 174
131 [NOT STARTED] — Restructure Theories/Bimodal/ file hierarchy for clean APIs
161 [NOT STARTED] — Rename Theories/Bimodal/ to final namespace (LAST)

### Wave 4 — Final Polish

177 [NOT STARTED] — Update README and all module docstrings
  └─ 131, 175
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
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Priority**: medium
- **Dependencies**: 168, 174

**Description**: Normalize naming conventions and eliminate bridge/wrapper indirection for publication quality. Expand opaque abbreviations (`bfmcs`, `drm`, `cud`, `sdc`, `dd_`, `tc_`, `fuc_`, `buc_`). Inline or remove `Bridge.lean` wrappers (993 lines, 16 forwarding definitions). Eliminate trivial primed variants. Normalize `z1_valid` to `axiom_z1_valid` for consistency. Purge 81 removed/archived/superseded tombstone comments. Consider renaming `temp_` prefix to `temporal_` for clarity.

---

### 174. Split oversized files (> 1500 lines)
- **Effort**: medium (8-12 hours)
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Priority**: medium
- **Dependencies**: 168

**Description**: Split Lean files exceeding ~1500 lines into focused modules. Targets: `Hierarchy.lean` (3845 lines — split by induction level), `SoundnessLemmas.lean` (2422 lines — split after task 168 collapses 4 near-duplicate frame-class blocks), `DedekindZ.lean` (2236), `ExpressiveCompleteness.lean` (2129), `SubformulaClosure.lean` (1889 in Syntax/), `Propositional.lean` (1712 in Theorems/), `Tactics.lean` (1416), `RestrictedMCS.lean` (1413), `ProofSearch.lean` (1384). Each split file should have a clear single responsibility and a module docstring.

---

### 173. Archive 19 dead sorry stubs from TemporalDerived.lean
- **Effort**: small (1-2 hours)
- **Status**: [IMPLEMENTING]
- **Task Type**: lean4
- **Priority**: medium
- **Research**: [173_archive_dead_temporal_derived_sorry_stubs/reports/01_sorry-stub-audit.md]
- **Plan**: [173_archive_dead_temporal_derived_sorry_stubs/plans/01_sorry-stub-archive.md]

**Description**: Archive or remove 19 sorry-stubbed theorems in `TemporalDerived.lean` that are explicitly documented as "NOT VALID under open guard semantics" (task 113). Includes `psi_imp_until`, `until_imp_or`, `refl_F`, `bot_until_bot_absurd`, and 15 others. These theorems are semantically invalid under the current open-guard `(t,s)` semantics and will never be provable. Move to `Boneyard/ClosedGuardDerived/` or delete with a file-level comment listing removals. This will reduce the active sorry count by 19.

---

### 172. Fix stale Metalogic.lean docstring
- **Effort**: small (1-2 hours)
- **Status**: [COMPLETED]
- **Task Type**: lean4
- **Priority**: medium
- **Research**: [172_fix_stale_metalogic_docstring/reports/01_docstring-audit.md]
- **Plan**: [172_fix_stale_metalogic_docstring/plans/01_docstring-fix.md]

**Description**: Rewrite `Metalogic.lean` docstring which is severely stale. Currently says "Reflexive G/H Semantics" but the project uses irreflexive semantics (task 93). References "SuccChain architecture" (dead code). Status table shows wrong completeness architecture. Should reference Chronicle/WeakCanonical-based completeness, irreflexive semantics, and current sorry status. Also update the status table to accurately reflect which completeness results are sorry-free.

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
- **Effort**: 6-10 hours
- **Status**: [IMPLEMENTING]
- **Task Type**: lean4
- **Priority**: high
- **Dependencies**: 154
- **Research**:
  - [specs/155_reynolds_pipeline_activation/reports/01_team-research.md]
  - [specs/155_reynolds_pipeline_activation/reports/02_team-research.md]
  - [specs/155_reynolds_pipeline_activation/reports/03_post-157-status.md]
  - [specs/155_reynolds_pipeline_activation/reports/03_team-research.md]
- **Plan**:
  - [155_reynolds_pipeline_activation/plans/01_reynolds-pipeline-plan.md]
  - [155_reynolds_pipeline_activation/plans/02_reynolds-pipeline-plan.md]
  - [155_reynolds_pipeline_activation/plans/03_reynolds-pipeline-plan.md]

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
- **Status**: [IMPLEMENTING]
- **Task Type**: lean4
- **Priority**: medium
- **Dependencies**: 129
- **Research**:
  - [specs/130_archive_dead_sorries_to_boneyard/reports/01_sorry-inventory.md]
  - [130_archive_dead_sorries_to_boneyard/reports/02_archive-vs-delete.md]
- **Plan**: [130_archive_dead_sorries_to_boneyard/plans/01_archive-dead-sorries.md]

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
- **Status**: [COMPLETED]
- **Language**: lean4
- **Dependencies**: None
- **Research**:
  - [01_tech-debt-audit.md](021_technical_debt_cleanup/reports/01_tech-debt-audit.md)
  - [02_team-research.md](021_technical_debt_cleanup/reports/02_team-research.md)
  - [03_archive-delete-audit.md](021_technical_debt_cleanup/reports/03_archive-delete-audit.md)
- **Plan**:
  - [01_tech-debt-cleanup-plan.md](021_technical_debt_cleanup/plans/01_tech-debt-cleanup-plan.md)
  - [021_technical_debt_cleanup/plans/02_tech-debt-cleanup.md]

**Description**: Clean up technical debt from metalogic refactoring track (tasks 9-20). Scope revised: (1) Document which metalogic paths are live (chronicle BXCanonical approach) vs dead (TimelineQuot, DenseTask, CanonicalModel parametric approach). (2) Remove dead code from non-chronicle paths or archive to Boneyard (overlaps with task 130). (3) Update stale docstrings in Metalogic/ files that reference superseded approaches. (4) Consolidate parametric representation usage documentation. Original dependency on task 18 removed (task 18 abandoned).

---
