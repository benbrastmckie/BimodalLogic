---
next_project_number: 133
repository_health:
  overall_score: 95
  production_readiness: near-publication
  last_assessed: 2026-05-10T23:59:00Z
task_counts:
  active: 24
  completed: 780
  in_progress: 0
  not_started: 7
  abandoned: 80
  total: 870
technical_debt:
  sorry_count: 1
  sorry_count_note: "Audited 2026-05-13: 1 critical-path sorry in ChronicleToCountermodel.lean (dd_countermodel_chronicle_nondense_sorry). Axiom count reduced 61->41 (tasks 115/124/133). PointInsertion.lean reduced 4333->3555 lines (task 134). ~17 dead-code sorries in BXCanonical pipeline (mathematically false under irreflexive semantics, bypassed by Chronicle). ~19 TemporalDerived re-derivations (low priority). Soundness, SoundnessLemmas, and Decidability are sorry-free."
  publication_path_sorries: 1
  axiom_count: 0
  axiom_count_note: "Zero custom axioms. Prior-UZ/SZ are standard axiom constructors with sorry-free soundness proofs."
  build_errors: 0
  status: excellent
---

# TODO

<!-- Vault transition: 2026-03-20 - Archived to specs/vault/01-vault/ -->

## Task Order

*Updated 2026-05-13. Axiom cleanup sprint complete (8 tasks archived). Tasks 137-138 created for ROADMAP/TODO documentation updates.*

**Goal**: Axiom cleanup → sorry-free `bx_completeness` → module reorganization → frame hierarchy → formula refactor → expressive extensions → algebraic representation.

**Status**: Axiom cleanup complete (tasks 115, 124, 133, 134, 135, 136 archived). Axiom count reduced 61→41. Soundness (all 3 variants) and FMP completeness are sorry-free. Dense completeness internally sorry-free. Discrete `discrete_fmcs` sorry-free. One sorry remains on critical path: `dd_countermodel_chronicle_nondense_sorry` (task 122, depends on 129). Task 129 (weak/reflexive completeness) is planned and ready to implement.

### Phase 1: Sorry-Free Completeness

1. **129** [IMPLEMENTING] — Weak/reflexive completeness via Henkin model + Doets compression + model-theoretic transfer (40h, bypasses succ_cofinal gap)
2. **139** [NOT STARTED] — FO satisfaction for monadic structures: close k-equivalence sorry chain (15-25h, depends on 129)
3. **140** [NOT STARTED] — Truth transfer and succ_cofinal elimination: standard translation + Reynolds pipeline wiring (8-15h, depends on 129, 139)
4. **122** [NOT STARTED] — Build discrete BFMCS on ℤ, complete last sorry (depends on 129)
5. **130** [NOT STARTED] — Archive ~40 dead sorries to Boneyard (depends on 129)

### Phase 2: Module Reorganization

1. **131** [NOT STARTED] — Restructure Theories/Bimodal/ file hierarchy, clean APIs, module documentation (15-25h, after 129 lands new modules)

### Phase 3: Frame Hierarchy and Formula Refactor

1. **126** [RESEARCHED] — Four-tier frame hierarchy: Base → Dense/Discrete → Integer with Sahlqvist correspondence (depends on 129)
2. **116** [PLANNED] — Redefine G/H/F/P in terms of U/S (~18h, high risk, touches everything)

### Phase 4: Expressive Extensions

1. **127** [NOT STARTED] — Time addition operator (+): ternary semantics, FO[<,+] (depends on 123)
2. **128** [NOT STARTED] — Open set (interior) operator for dense/continuous frames (depends on 122)

### Phase 5: Algebraic Representation

- **125** [NOT STARTED] — Jónsson-Tarski representation for S/U/□ (depends on all Phase 1-5 tasks)

### Phase 6: Publication Quality

- **95** [NOT STARTED] — Verification audit (after axiom system is final)
- **8** [RESEARCHED] — Genuine truth_at completeness
- **68** [RESEARCHED] — Dense completeness via ℚ

### Deferred / Low Priority

- **998** [RESEARCHING] — FMP redesign for irreflexive temporal semantics
- **112** [RESEARCHED] — Literature study (reference)
- **18** [BLOCKED] — Dense representation theorem
- **20** [NOT STARTED] — Parametric canonical audit
- **21** [PLANNED] — Tech debt cleanup
- **953** [RESEARCHED] — Bilateral proof system (55-90h)
- **992** [RESEARCHED] — STSA temporal shift automorphism
- **949** [RESEARCHED] — Update Demo.lean (cosmetic)
- **64** [RESEARCHED] — Critical path review (reference)
- **619** [RESEARCHED] — Agent system architecture upgrade (meta)
- **114** [NOT STARTED] — Plan-compliance rule (meta)
- **137** [COMPLETED] — Update ROADMAP.md stale axiom info (~30min)
- **138** [COMPLETED] — Update TODO.md sorry_count_note (~10min)

## Tasks

### 138. Update TODO.md sorry_count_note for axiom cleanup sprint
- **Effort**: 10 minutes
- **Status**: [COMPLETED]
- **Task Type**: general
- **Plan**: [specs/138_update_todo_sorry_note/plans/01_todo-note-update-plan.md]

**Description**: Update TODO.md frontmatter sorry_count_note to reflect axiom cleanup sprint: axiom count now 41 (was 61), tasks 115/124/133/134 completed.

---

### 137. Update ROADMAP.md stale axiom info
- **Effort**: 30 minutes
- **Status**: [COMPLETED]
- **Task Type**: general
- **Priority**: high
- **Plan**: [specs/137_update_roadmap_axiom_info/plans/01_roadmap-update-plan.md]

**Description**: Update ROADMAP.md: axiom count 45->41, remove BX2/BX2' table rows (now derived from BX2G/BX2H), update CanonicalChain.lean summary (remove left_mono_until_mcs reference), update PointInsertion.lean line count (~3690->~3555).

---

### 131. Refactor module organization for clean APIs and documentation
- **Effort**: 15-25 hours
- **Status**: [NOT STARTED]
- **Task Type**: lean4

**Description**: Restructure Theories/Bimodal/ file hierarchy for clean APIs and documentation. Currently 130 live .lean files across 7 top-level directories, with the Metalogic/ directory being a catch-all containing 7 subdirectories (Algebraic, Bundle, BXCanonical, ConservativeExtension, Core, Decidability, Relational) plus loose files (Soundness.lean, SoundnessLemmas.lean, DenseSoundness.lean, DiscreteSoundness.lean, Completeness.lean, Metalogic.lean). Goals: (1) Reorganize Metalogic/ into a clearer hierarchy — group soundness files into Metalogic/Soundness/, completeness files into Metalogic/Completeness/, clarify relationship between BXCanonical (chronicle approach) and Algebraic (parametric approach). (2) Add module-level documentation (docstrings on namespace declarations, module descriptions at file tops). (3) Establish clean APIs with explicit exports via root .lean files for each subdirectory. (4) Evaluate whether FrameConditions/ should be merged into Metalogic/ or remain separate. (5) Audit Boneyard/ organization (45 files across 10+ subdirectories). (6) Consider whether docs/ and latex/ and typst/ should remain under Theories/Bimodal/ or move to project root.

---

### 129. Weak/reflexive completeness and conservative extension for discrete frames
- **Effort**: 30-60 hours
- **Status**: [IMPLEMENTING]
- **Task Type**: lean4
- **Priority**: critical
- **Research**:
  - [specs/129_weak_reflexive_completeness_conservative_extension/reports/01_weak-reflexive-findings.md]
  - [129_weak_reflexive_completeness_conservative_extension/reports/02_team-research.md]
  - [129_weak_reflexive_completeness_conservative_extension/reports/03_reynolds-deep-dive.md]
  - [129_weak_reflexive_completeness_conservative_extension/reports/06_multi-relation-mathematical-analysis.md]
  - [129_weak_reflexive_completeness_conservative_extension/reports/07_team-research.md]
  - [129_weak_reflexive_completeness_conservative_extension/reports/09_team-research.md]
- **Plan**:
  - [129_weak_reflexive_completeness_conservative_extension/plans/01_weak-completeness-plan.md]
  - [129_weak_reflexive_completeness_conservative_extension/plans/03_doets-reynolds-plan.md]
  - [129_weak_reflexive_completeness_conservative_extension/plans/05_chronicle-reynolds-plan.md]
  - [129_weak_reflexive_completeness_conservative_extension/plans/09_reynolds-theorem15-plan.md]
- **Summary**:
  - [specs/129_weak_reflexive_completeness_conservative_extension/summaries/09_reynolds-theorem15-summary.md]

**Description**: Develop a weak/reflexive temporal sub-language for discrete frames and prove the strict system is a conservative extension, bypassing the succ_cofinal gap scenario entirely.

**Motivation**: The sorry at `succ_cofinal` (ChronicleToCountermodel.lean:1869) exists because the Burgess chronicle construction for *strict* (irreflexive) temporal semantics requires proving IsSuccArchimedean of the limit domain — leading to a Z+Z gap scenario that no temporal axiom can rule out in the constant-MCS case. The entire chronicle machinery (omega-chain, counterexample elimination, IR rule) exists *because* of the irreflexivity of strict `<`. Under *weak/reflexive* semantics (using `≤`), standard Henkin canonical model methods apply directly: the canonical frame is reflexive, no IR rule is needed, no chronicle construction is needed, and no gap scenario arises.

**Key Observation**: Under weak semantics, `G_w(φ)` at `x` means `φ` at all `y ≥ x`. Then `G_w(φ) → φ` is valid (reflexivity of `≥`), and Z1 collapses to `FG_w(φ) → G_w(φ)` — the pure backward induction principle with no `G(Gφ→φ)` antecedent to establish. On discrete orders, the strict and weak operators are inter-translatable: `G_w(φ) ≡ φ ∧ G(φ)` and `G(φ) ≡ G_w(φ) at succ(x)`.

**Architecture**:

*Phase 1 — Weak Sub-Language Definition (~100 lines)*
- Define `G_w(φ) := φ ∧ G(φ)`, `H_w(φ) := φ ∧ H(φ)`, `F_w(φ) := φ ∨ F(φ)`, `P_w(φ) := φ ∨ P(φ)` as derived operators in the existing Formula type (no new constructors needed).
- Define weak Until: `U_w(η, ξ)` true at `x` iff `∃ y ≥ x` with `η` at `y` and `ξ` at all `z` with `x ≤ z < y`. Similarly for weak Since.
- Verify these are expressible in the existing language or add minimal constructors.

*Phase 2 — Weak Axiom System (~200 lines)*
- Identify which axioms of the strict system translate to the weak system. The weak system should include: reflexivity axiom `G_w(φ) → φ` (valid by construction), transitivity `G_w(φ) → G_w(G_w(φ))`, weak Z1 `FG_w(φ) → G_w(φ)`, weak Prior-UZ, and all BX axioms adapted for `U_w`/`S_w`.
- Prove these are derivable in the strict system (via the `G_w = φ ∧ G` translation).

*Phase 3 — Weak Canonical Model (~500-800 lines)*
- Build a standard Henkin canonical model for the weak system. Each point is a distinct MCS (à la Doets). The temporal accessibility relation is `≤` (reflexive, transitive, linear).
- The constant-MCS problem cannot arise: distinct MCS are distinct points.
- Prove the truth lemma for the weak canonical model.
- Prove weak completeness: if `φ` is not derivable in the weak system, there exists a weak discrete model falsifying `φ`.

*Phase 4 — Z1 and IsSuccArchimedean in the Weak Model (~200-400 lines)*
- In the weak canonical model, use `FG_w(φ) → G_w(φ)` (weak Z1) to prove the maximum principle (Doets Claim 10): every definable set that is non-empty and bounded above has a maximum.
- Use the maximum principle to compress the canonical model to order type ℤ (following Doets Claims 9-11: expand equivalence classes to ζ-shapes, then compress bounded types).
- Prove the resulting model is IsSuccArchimedean.

*Phase 5 — Model-Theoretic Completeness Transfer (~100 lines)*
- NOTE: Expressing strict G in terms of weak operators is impossible. `U_w(φ, ⊥) = φ` in weak semantics, so Next is not definable. No formula-to-formula translation from strict to weak exists.
- Instead, use model-theoretic argument: if ψ is not provable in the strict system, ¬ψ is consistent in the strict system. Since every weak axiom is a strict theorem (`G_w(φ) = φ ∧ G(φ)` is derivable), ¬ψ is consistent in the weak system. By weak completeness, there exists a weak countermodel on a discrete IsSuccArchimedean frame. This is also a strict countermodel (same domain, same valuation, reinterpret ≤ as <). Contrapositive: valid under strict → provable.

*Phase 6 — Integration and Verification (~100 lines)*
- Wire the weak completeness + model-theoretic transfer into the existing completeness pipeline or create a parallel sorry-free completeness theorem.
- Verify `lake build` passes.
- Verify key theorems are sorry-free via `lean_verify`.

*Phase 7 — Close the Sorry (~50 lines)*
- Replace the admitted `limitDomSubtype_isSuccArchimedean` in ChronicleToCountermodel.lean with the Henkin-derived IsSuccArchimedean, making `dd_countermodel_chronicle_discrete` sorry-free.

**Risks and Mitigations**:
- Risk: Weak Until `U_w` may not be cleanly expressible from strict Until. Mitigation: Add `U_w` as a new constructor if needed, with its own semantics.
- Risk: The conservative extension proof for Until/Since may be subtle (guard semantics differ between weak and strict). Mitigation: Prove for the G/H fragment first, then extend to U/S.
- Risk: Doets's compression to ℤ (Claims 9-11) requires Ehrenfeucht game / n-characteristic infrastructure (~500 lines). Mitigation: This is the main cost driver but is well-documented in the literature.
- Risk: The weak canonical model may require different MCS machinery than what exists. Mitigation: The existing Lindenbaum, MCS properties, and derivation infrastructure should be largely reusable; only the frame construction differs.

**Relationship to Existing Work**:
- Subsumes task 123's succ_cofinal sorry (bypasses the gap scenario entirely).
- Can coexist with the chronicle construction (which remains valid for the dense case).
- The Doets Henkin approach (originally planned as a separate task) is essentially Phase 3-4 of this task.
- The weak sub-language is independently interesting for proof-theoretic and algebraic investigations (task 125).

**Literature**: Doets 1987 (Completeness and Definability, Claims 9-11), Burgess 1982/1984 (chronicle construction for strict semantics), Gabbay-Hodkinson-Reynolds (irreflexivity techniques), Blackburn-de Rijke-Venema 2002 (Section 7.2, completeness with Until/Since).

---

### 139. FO satisfaction for monadic structures: close k-equivalence sorry chain
- **Effort**: 15-25 hours
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Priority**: critical
- **Dependencies**: 129

**Description**: Build first-principles FO (first-order) satisfaction infrastructure for monadic structures and close the k-equivalence sorry chain left by task 129.

The current `MonadicSentence` type (NEquivalence.lean) lacks variable binding infrastructure: `.forall` has no De Bruijn index, `.lt` has no variable positions, and `.atom` has no variable argument. This makes it impossible to define `eval`/`satisfies`, which leaves `k_type_of`, `ktype_finite`, and `k_equiv_monotone` as sorries. The entire Reynolds Theorem 15 pipeline (`doets_lemma_1_4`, `finite_structures_good`, `one_class`, `chronicle_is_good`) inherits these sorries through the axiomatized `KEquivalenceFramework` instance.

**Scope**:

1. **Redesign `MonadicSentence` with proper variable binding**. The monadic case is simpler than full FO: predicates are unary, the only relation is binary `<`, quantification is over a single sort. Options: (a) De Bruijn indices for quantifier binding with explicit variable positions for `lt`, (b) two-sorted variable scheme. Refactor all downstream consumers.

2. **Implement decidable `eval`/`satisfies`**. For finite carriers and finite signatures, satisfaction is decidable. Define `eval : MonadicStructure sig → Assignment → MonadicSentence sig → Bool` with proper variable lookup, quantifier evaluation over `Fintype` carriers, and `lt` comparison using the structure's order.

3. **Close `k_type_of`** from the semantics: the set of sentences of depth ≤ k satisfied by M, converted to a canonical representative.

4. **Prove `ktype_finite`**: finitely many k-types, bounded by 2^|S_k| where S_k is the finite set of sentences of depth ≤ k over a finite signature.

5. **Prove `k_equiv_monotone`**: k-equivalence at depth k implies k-equivalence at depth m ≤ k.

6. **Close `KEquivalenceFramework` instance fields** (`equiv_at`, `equiv_is_equiv`, `equiv_monotone`, `finite_types`, `sum_preservation`) with proofs from the FO semantics, replacing the current sorry-based axioms.

7. **Verify downstream**: Confirm `doets_lemma_1_4`, `finite_structures_good`, `one_class`, `chronicle_is_good`, and Transfer.lean still compile with strictly fewer sorries.

**Definition of done**: `KEquivalenceFramework` instance is sorry-free, `k_type_of`/`ktype_finite`/`k_equiv_monotone` are sorry-free, `lake build` passes, `chronicle_is_good` has strictly fewer sorries than before.

**Files**: `Theories/Bimodal/Metalogic/WeakCanonical/NEquivalence.lean` (primary), `OrderedSum.lean`, `IntegerModel.lean`, `Transfer.lean` (downstream verification).

---

### 140. Truth transfer and succ_cofinal elimination
- **Effort**: 8-15 hours
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Priority**: critical
- **Dependencies**: 129, 139

**Description**: Prove the standard translation preserves truth (table correctness), wire it into Transfer.lean to replace the chronicle fallback with the Reynolds pipeline, and eliminate `succ_cofinal` from the axiom set of `doets_countermodel_discrete`. This is the final link in the chain: task 129 built the Reynolds pipeline (`one_class`, `chronicle_is_good`), task 139 closes the FO satisfaction foundation (`eval`/`satisfies`, `k_type_of`), and this task completes the circuit.

**Scope**:

1. **Prove `table_correctness`**: the standard translation preserves truth. For any temporal formula phi and point t in model M, `M |= phi at t` iff `monadic(M) |= table(phi) at t`. Requires `eval`/`satisfies` from task 139. Proof by structural induction on `Formula`: atom case is definitional, boolean cases trivial, G/H cases use the order relation in `MonadicSentence`, Until/Since cases use the FO encoding of bounded quantification.

2. **Close `table_depth_bound`**: the quantifier depth of `table(phi)` is bounded by `Formula.complexity(phi)`. Straightforward structural induction once `table` is non-vacuous.

3. **Replace chronicle fallback in `doets_countermodel_discrete`** (Transfer.lean) with the full Reynolds pipeline. The 6-step flow is already documented as comments from task 129: (a) extract chronicle, (b) build signature via `mkSigFrom`, (c) build atom map via `mkAtomMap`, (d) prove chronicle is good via `chronicle_is_good`, (e) extract Z-model from goodness, (f) transfer truth via k-equivalence + `table_correctness`.

4. **Verify axiom elimination**: `#print axioms doets_countermodel_discrete` must show no `succ_cofinal`. Check `#print axioms bx_completeness` for remaining paths.

**Definition of done**: `table_correctness` sorry-free, `doets_countermodel_discrete` uses Reynolds pipeline (not chronicle fallback), `#print axioms doets_countermodel_discrete` clean of `succ_cofinal`, `lake build` passes.

**Files**: `Theories/Bimodal/Metalogic/WeakCanonical/Table.lean` (table correctness), `Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean` (pipeline wiring).

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


## Recommended Order


## Recommended Order

