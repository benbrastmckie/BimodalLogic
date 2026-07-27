---
next_project_number: 408
---

# TODO

## Task Order

*Updated 2026-07-27. Generated from state.json dependency graph.*

**Dependency Waves**:
| Wave | Tasks | Blocked by | Topics |
|------|-------|------------|--------|
| 1 | 95,125,127,128,165,179,193,231,257,298,361,390 | -- | completeness, frame-extensions, algebraic-representation, ... |
| 2 | 169,170,177,178,219,282,296 | 193,231,298,361 | formula-refactor, dataset-enhancement, strong_completeness |
| 3 | 362 | 169,170 | strong_completeness |

**Grouped by Topic** (indented = depends on parent):

### Completeness

95 [NOT STARTED] — Verify and record the final axiom/sorry status of the headline me
165 [NOT STARTED] — Establish the semantic finite model property for TM bimodal logic
390 [RESEARCHED] — RESOLVED (research complete). VERDICT: GO on the carrier question

### Formula Refactor

177 [NOT STARTED] — Update all documentation to match final codebase state after refa
178 [NOT STARTED] — Expand Examples/ with publication-quality demonstrations of the f

### Frame Extensions

127 [NOT STARTED] — Add time addition operator (+) to the bimodal logic TM. φ + ψ is 
128 [NOT STARTED] — Add topological open set (interior) operator for dense and contin

### Algebraic Representation

125 [NOT STARTED] — Implement a Jonsson-Tarski representation theorem for TM logic: e

### Automation

179 [RESEARCHED] — research_lean4_tactics_infrastructure
193 [NOT STARTED] — Apply validity-intro and truth-simp macros to the soundness layer

### Dataset Enhancement

231 [NOT STARTED] — Build comprehensive automation so that every dataset regeneration
  └─ 219 [RESEARCHED] — Run bmlogic-bench through multiple LLMs to establish baseline dif
257 [BLOCKED] — large_data_storage_huggingface
298 [PARTIAL] — Fix c7 labeling bug at formula ~13750 that causes unbounded memor
  └─ 282 [PARTIAL] — exhaustive_enumeration_by_default
  └─ 296 [PARTIAL] — Re-add the 6 derived binary temporal operators (release, weak_unt

### Strong Completeness

361 [NOT STARTED] — Research + scoping for finite-context strong completeness (Contex
  └─ 169 [NOT STARTED] — Base (FrameClass.Base / general) WEAK completeness green: make th
    └─ 362 [NOT STARTED] — Implement main_strong_completeness: finite-context strong complet
  └─ 170 [NOT STARTED] — Dense (FrameClass.Dense) WEAK completeness green: make `completen
    └─ 362 [NOT STARTED] — Implement main_strong_completeness: finite-context strong complet (see above)

## Tasks

### 390. Dedekind carrier construction research
- **Effort**: large
- **Status**: [RESEARCHED]
- **Task Type**: lean4
- **Topic**: completeness
- **Dependencies**: Task 389
- **Research**: [390_dedekind_carrier_construction_research/reports/01_dedekind-carrier-construction.md]

**Description**: RESOLVED (research complete). VERDICT: GO on the carrier question; the umbrella Dedekind-completeness effort is CONDITIONAL. Report: specs/390_dedekind_carrier_construction_research/reports/01_dedekind-carrier-construction.md (three named preconditions + nine-phase decomposition).
The obstruction stated below conflates the chronicle limit domain X with the model time domain D. X is countable; D is the carrier and is already strictly larger than X (X subset of Rat, with carrier Rat). The carrier therefore requires NO construction: setting D = Real is the same move that already sets D = Rat, and the live parametric scaffolding was compile-verified to instantiate at Real unmodified.
Reynolds 1992 Theorem 7 (printed p.189) obtains real-flow WEAK completeness by a Doets quantifier-depth TRANSFER from a countable rational model -- never by completion. GHR94 ch.10 section 10.3 likewise assumes Dedekind completeness as a frame condition rather than constructing it.
Dedekind completeness is NOT modally definable (Reynolds printed p.169: the Prior axioms enforce a merely DEFINABLY Dedekind-complete model). The axiomatic proxy is Prior-U / Prior-S / Sep (printed p.168), none of which is in the Axiom inductive today; the tree's existing prior_UZ / prior_SZ are the DIFFERENT integer well-ordering axioms, not Reynolds' gap axioms.
The original framing below is retained as historical context for why this task existed; its file anchors have been corrected against the working tree.

Research task: determine how a Dedekind-complete carrier can be produced for the canonical-model construction. This is the mathematical crux of the Dedekind-complete completeness effort and MUST resolve before any implementation plan is written.

THE OBSTRUCTION. specs/ROADMAP.md:1477 describes the chronicle limit domain X as a COUNTABLE linear order (sparse X subset of Rat for Base, Rat for Dense, order-isomorphic to Int for Discrete). But a Dedekind-complete, densely ordered, unbounded linear order is order-isomorphic to the reals, hence uncountable. So the existing chronicle / canonical-model route cannot directly yield a Dedekind-complete carrier.
Corroborating anchors: specs/ROADMAP.md:317-320 warns that dense domains such as Rat are WRONG for general completeness (GGp -> Gp is valid on Rat but not derivable in BX; Burgess uses a sparse X subset of Rat). specs/ROADMAP.md:1414's "Representation Theorem Goal" enumerates D' = Rat (base), Rat (dense), Int (discrete) and has NO reals row. FormalSystem/Metalogic/WeakCanonical/Kamp/DedekindINF.lean:50 states flatly that no reals OrderedMonadicStructure is constructed here or anywhere in this tree.

QUESTIONS TO ANSWER, with literature grounding (see the Dedekind literature-remediation task):
1. Does the intended semantics quantify over Dedekind-complete ORDERS, or over Dedekind-complete orders arising as duration groups? The live validity predicates take instance binders on a duration type D (FormalSystem/Semantics/Validity.lean:79 valid, :169 ValidDense, :187 ValidDiscrete -- note the declarations are named ValidDense / ValidDiscrete, not valid_dense / valid_discrete). Establish what the Dedekind analogue's binder list must be.
2. Is a Dedekind completion of the countable limit domain sound for the truth lemma -- i.e. does adding limit points preserve the coherence conditions the BFMCS bundle requires? If not, why not, and what is the obstruction precisely.
3. What does the literature actually do? Reynolds 1992 axiomatizes Until/Since over the reals; GHR94 Ch.10 section 10.3 treats separation over Dedekind-complete flows. Extract the construction each uses for the carrier and state whether it is a completion, a direct construction, or a representation argument.
4. Is the target completeness result even true for the intended axiom set, and what axiom characterizes Dedekind completeness? No candidate exists in the Axiom inductive today.

CONSTRAINTS. Standing ROADMAP anti-patterns apply: do NOT attempt a direct IsSuccArchimedean proof bypassing chronicle_gap_contradiction; do NOT attempt the "discrete bypass"; decidability-based completeness is explicitly excluded as a path to the representation theorem.
Reusable scaffolding that a solution must plug into (all live, sorry-free, generic in the duration type D and the frame class fc; line numbers verified against the working tree): ParametricCanonicalTaskFrame (FormalSystem/Metalogic/Algebraic/ParametricCanonical.lean:207), ParametricCanonicalTaskModel (FormalSystem/Metalogic/Algebraic/ParametricTruthLemma.lean:108), parametric_canonical_truth_lemma (:240), restricted_parametric_shifted_truth_lemma (FormalSystem/Metalogic/Algebraic/RestrictedParametricTruthLemma.lean:119), and the single funnel both live countermodels go through, fully_restricted_parametric_completeness_from_neg_membership (:417). Also neg_consistent_of_not_derivable (FormalSystem/Metalogic/BXCanonical/Completeness.lean:72, generic in fc) and mcs_mixed_case_absurd (FormalSystem/Metalogic/BXCanonical/Chronicle/MCSMixedCase.lean:42 -- note this is under BXCanonical/, takes fc explicitly). structure Gap (FormalSystem/Metalogic/WeakCanonical/EFGames/Defs.lean:248) is the existing object with the right shape for phrasing "no Dedekind gaps" as a frame condition.
Related warning from the existing tree: FormalSystem/Metalogic/BXCanonical/Completeness.lean:173-193 documents why the general completeness theorem still carries sorryAx -- a Base-MCS is not automatically Discrete-consistent, so the sorry-free Reynolds pipeline cannot be reused. A Dedekind variant will hit the structurally identical problem and must build a countermodel from an MCS of its own class.
DELIVERABLE: a research report with a GO / NO-GO recommendation and, if GO, the carrier construction to be formalized. Dispatch with --lit.

---

### 362. Main strong completeness finite context all frame classes
- **Effort**: high
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: strong_completeness
- **Dependencies**: Task 361, Task 375, Task 169, Task 170

**Description**: Implement main_strong_completeness: finite-context strong completeness (Γ : Context = List Formula) for all three frame classes, with weak completeness re-exposed as the Γ=[] corollary. For each X ∈ {Base, Dense, Discrete}: prove strong_completeness_X : semantic consequence for X of Γ and φ → Derivable FrameClass.X Γ φ (note `Derivable fc G p` is *definitionally* `Nonempty (DerivationTree fc G p)` -- FormalSystem/ProofSystem/Derivable.lean:69 -- so state the conclusion as `Derivable`, matching the existing weak termini, rather than unfolding to `Nonempty`), by (a) the semantic deduction lemma reducing Γ ⊨_X φ to ⊨_X (Γ.foldr Formula.imp φ), (b) the existing empty-context weak completeness theorem for X, and (c) iterated application of the syntactic deduction theorem to move the finite premises into the context. Then derive weak_completeness_X as strong_completeness_X at Γ=[].

VERIFIED ANCHORS (re-checked 2026-07-27 against the working tree; all paths are post-rename FormalSystem/ paths):
  - FormalSystem/Metalogic/BXCanonical/Completeness.lean:196 -- `completeness (φ : Formula) : valid φ → Derivable FrameClass.Base [] φ`
  - FormalSystem/Metalogic/BXCanonical/Completeness.lean:255 -- `completeness_dense (φ : Formula) : ValidDense φ → Derivable FrameClass.Dense [] φ`
  - FormalSystem/Metalogic/BXCanonical/Completeness.lean:296 -- `completeness_discrete (φ : Formula) : ValidDiscrete φ → Derivable FrameClass.Discrete [] φ`
    (These supersede the previously-recorded :135/:234/:276, which had drifted. The base-class validity predicate is lowercase `valid`; only the dense and discrete variants are UpperCamel `ValidDense`/`ValidDiscrete` -- FormalSystem/Semantics/Validity.lean:79, :169, :187.)
  - Syntactic deduction theorem, FormalSystem/Metalogic/Core/DeductionTheorem.lean: the usable entry point is
    `FormalSystem.ProofSystem.Derivable.deduction` at :467 (Prop-level, `Derivable fc (A :: Γ) B → Derivable fc Γ (A.imp B)` -- this is the one to iterate), backed by the data-level
    `deductionTheorem` at :325 (`(A :: Γ) ⊢[fc] B → Γ ⊢[fc] A.imp B`). There is no declaration literally named `deduction_theorem`; the earlier description's use of that name was wrong.
  - Frame-class-agnostic `SemanticConsequence (Γ : Context) (φ : Formula)` ALREADY EXISTS at FormalSystem/Semantics/Validity.lean:103, with notation `Γ ⊨ φ` at :114. The per-class variants are the piece research 361 is chartered to design; name them in UpperCamel to match the post-naming-upgrade convention for Prop-valued definitions (as `SemanticConsequence`, `ValidDense`, `TruthAt` already are), while theorem names stay snake_case (as `completeness_dense` already is).

New file FormalSystem/Metalogic/StrongCompleteness.lean (additive; confirmed absent, so this task creates it). Update the tracking table in FormalSystem/Metalogic.lean -- note this is Metalogic.lean at the FormalSystem/ root, NOT FormalSystem/Metalogic/Metalogic.lean, which does not exist.

Axioms exactly [propext, Classical.choice, Quot.sound] modulo whatever the underlying weak terminus already carries; sorry-free once the three weak termini are green.

This is the capstone the LaTeX names main_strong_completeness: latex/subfiles/04-Metalogic.tex:266 (`\begin{theorem}[Strong Completeness]`) -- line VERIFIED 2026-07-27; the identifier itself also appears at :211 and :490 of the same file.

DEPENDENCY STATUS (checked 2026-07-27; the dependencies array itself is unchanged):
  - 375 kamp_completeness_final_assembly_axiom_audit -- COMPLETED. This is the DISCRETE terminus, and it is already available: its completion records that completeness_discrete and completeness_dense kernel-verify to exactly [propext, Classical.choice, Quot.sound]. (An earlier version of this description named "358 (discrete)"; task 358 is in fact the abandoned realization_recursion_nf_nvar_exist_all_depths and is NOT a dependency of this task. Trust the dependencies array, which lists 375.)
  - 169 complete_frame_extension_setup_and_soundness (base) -- not_started.
  - 170 complete_dense_extension_completeness (dense) -- not_started.
  - 361 strong_completeness_architecture_and_weak_terminus_gap_analysis (architecture + per-class semantic-consequence definitions) -- not_started.
So the discrete leg is done; the base and dense legs plus the architecture research remain.

---

### 361. Strong completeness architecture and weak terminus gap analysis
- **Effort**: high
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: strong_completeness
- **Dependencies**: None

**Description**: Research + scoping for finite-context strong completeness (Context = List Formula) across all three frame classes (Base, Dense, Discrete). Deliverables: (1) Confirm the strong-completeness corollary architecture — per-class semantic_consequence_X (paralleling valid/valid_discrete in Semantics/Validity.lean; the current `⊨`/semantic_consequence quantifies over ALL ordered abelian groups D, so a Discrete/Dense restriction must be defined), the semantic deduction lemma (Γ ⊨ φ ↔ ⊨ Γ.foldr imp φ), and iterated use of the existing syntactic deduction_theorem (Metalogic/Core/DeductionTheorem.lean) to derive Γ ⊢ φ from []⊢(Γ→φ). (2) Authoritative gap analysis of what still gates each WEAK terminus: Discrete = task 358 (KampPrior.lean:361/364) + supply (task 350/309); Base = the open sorries in `completeness` (BXCanonical/Completeness.lean:135 — dense arm countermodel_dense, deprecated countermodel_discrete Transfer.lean:1270 "unfixable Z+Z", dd_countermodel_chronicle_mixed_sorry); Dense = the chronicle dense-path sorries inherited by `completeness_dense` (:234) (ChronicleToCountermodel.lean, MCSMixedCase). For each, determine whether the current live architecture reaches green or needs rerouting, and produce a concrete sub-task decomposition + dependency graph for tasks 169 (base weak) and 170 (dense weak), spawning refinements as needed. (3) Confirm the LaTeX-documented main_strong_completeness (04-Metalogic.tex:266) finite-context shape and that weak completeness is exactly the Γ=[] instance. Reference: 04-Metalogic.tex §Completeness-as-Corollary; report 13 (discrete-completeness roadmap). Analysis/read task — no proof obligations to close here.

---

### 321. Implement corrected k2 carrier and close the correctness gate f4 resolution
- **Effort**: 10-16 hours
- **Status**: [EXPANDED]
- **Task Type**: lean4
- **Topic**: kamp_theorem_formalization
- **Dependencies**: Task 320, Task 326, Task 330, Task 331, Task 335, Task 336
- **Research**:
  - [309_offdiag_two_anchor_fi_chain/reports/06_spawn-analysis-f4.md]
  - [320_derisk_jointpinning_route_for_the_k2_carrier_gate_f4_followup/reports/01_literature-alignment.md]
  - [321_implement_corrected_k2_carrier_and_close_the_correctness_gate_f4_resolution/reports/06_faithful-separate-bracket-architecture.md]
  - [321_implement_corrected_k2_carrier_and_close_the_correctness_gate_f4_resolution/reports/07_v7-consolidated-faithful-route.md]
  - [321_implement_corrected_k2_carrier_and_close_the_correctness_gate_f4_resolution/reports/10_supersession-decision.md]
  - [321_implement_corrected_k2_carrier_and_close_the_correctness_gate_f4_resolution/reports/01_blocker-research-successor-k.md]
  - [321_implement_corrected_k2_carrier_and_close_the_correctness_gate_f4_resolution/reports/02_spawn-analysis.md]
  - [321_implement_corrected_k2_carrier_and_close_the_correctness_gate_f4_resolution/reports/03_divergence-audit-joint-channel.md]
  - [321_implement_corrected_k2_carrier_and_close_the_correctness_gate_f4_resolution/reports/04_spawn-analysis.md]
  - [321_implement_corrected_k2_carrier_and_close_the_correctness_gate_f4_resolution/reports/05_remaining-k2-gate-architecture.md]
- **Plan**:
  - [321_implement_corrected_k2_carrier_and_close_the_correctness_gate_f4_resolution/plans/02_corrected-k2-carrier-fi-chain-v2.md]
  - [321_implement_corrected_k2_carrier_and_close_the_correctness_gate_f4_resolution/plans/03_corrected-k2-carrier-gate-v3.md]
  - [321_implement_corrected_k2_carrier_and_close_the_correctness_gate_f4_resolution/plans/04_corrected-k2-carrier-gate-v4.md]
  - [321_implement_corrected_k2_carrier_and_close_the_correctness_gate_f4_resolution/plans/05_corrected-k2-carrier-gate-v5.md]
  - [321_implement_corrected_k2_carrier_and_close_the_correctness_gate_f4_resolution/plans/06_corrected-k2-carrier-gate-v6-redesign.md]
  - [321_implement_corrected_k2_carrier_and_close_the_correctness_gate_f4_resolution/plans/07_v7-faithful-separate-bracket.md]
  - [321_implement_corrected_k2_carrier_and_close_the_correctness_gate_f4_resolution/plans/01_corrected-k2-carrier-fi-chain.md]
- **Summary**:
  - [321_implement_corrected_k2_carrier_and_close_the_correctness_gate_f4_resolution/summaries/01_corrected-k2-carrier-fi-chain-summary.md]
  - [321_implement_corrected_k2_carrier_and_close_the_correctness_gate_f4_resolution/summaries/06_corrected-k2-carrier-gate-v6-redesign-summary.md]
  - [321_implement_corrected_k2_carrier_and_close_the_correctness_gate_f4_resolution/summaries/07_phase11-n2-singleton-summary.md]
  - [321_implement_corrected_k2_carrier_and_close_the_correctness_gate_f4_resolution/summaries/07_phase7-sepbody-carrier-summary.md]
  - [321_implement_corrected_k2_carrier_and_close_the_correctness_gate_f4_resolution/summaries/08_phase8-joint-extraction-summary.md]
  - [321_implement_corrected_k2_carrier_and_close_the_correctness_gate_f4_resolution/summaries/09_phase9-o4-verdict-summary.md]

**Description**: REDESIGN (v6, plan 06). Task 330's PDF-verified faithfulness audit (specs/330_.../reports/01_faithfulness-audit-fold-representation.md — the PRIMARY BASIS) determined the entire v1-v5 route rested on a MIS-CITATION: the "constant-arity E[Sigma]-fold (Def 4.1)" does not exist in Rabinovich 2014. Def 4.1 (p.5) is the E[Sigma] ALPHABET EXPANSION (TL-formulas-as-atoms), NOT a fold. The real fold is Prop 3.5 / Cor 5.4: NAVIGATED (nested Until/Since) over FLAT exists-forall blocks with QUANTIFIER-FREE point types (Lemma 5.1, p.7); higher FO depth is discharged by STRUCTURAL INDUCTION (Prop 4.3, p.6), never by nesting a depth-k characteristic. The static arity-1 E-atom (EAtomDom = ZoneSpec n x NormalForm sig k 1, NfEFold:69) is a CATEGORY ERROR at k>=1 — the recurring wall (G6 :1609-1641, F4 :5689-5765, k=2 NO-GO 327 :8760-8825) is ONE obstruction: an arity-1 monadic channel cannot carry an inner witness's joint coupling to multiple anchors (goal needs ZoneSpec 4, channel supplies ZoneSpec 1).\n\nv6 DROPS every phase depending on the refuted infrastructure (nfk_assemble/nfk_dropFresh/nfk_zoneSpec, nf_eval_nf1_cons_factor, efold_of_nfk, the constant-arity fold engine nf_quant_layer_fold_k2_gate). It CONSUMES the landed assets the audit identified: BracketCarrierCorrectV (NfMultiAnchorBridge:1881, the witness-growing carrier), neg_2var_vec_ea (EANegationClosure:722, the LANDED Prop 4.2 negation closure — the hardest piece), and the task-326 interior closers (kvE_subBracket2V_sound_of_outer/_complete). It ADDS the missing ingredient: the Prop 4.3 re-flatten structural-induction wiring. It FOLDS IN the redefined scope of the now-ABANDONED prerequisite tasks (NOT re-spawned): former 328 -> the navigated witness-growing fold (Prop 4.3 re-flatten induction over flat exists-forall blocks); former 329 -> the per-arrangement VVecEA2 non-interior dischargers (soundness + completeness) for the 5 non-interior zones (zPastX/zAtX/zAtW/zAtT/zFutT). v5 Phase 15 (F4 Z adversarial gate + verdict record) is preserved as the downstream consumer (now Phase 8).\n\nBINDING INVARIANT (the ONE thing v6 changes after 5 non-converging versions): reconstruction is NAVIGATED / witness-growing, NEVER a static arity-1 characteristic — inter-anchor coupling rides the EVALUATION POINT / structural position of nested Until/Since (Prop 3.5 / Cor 5.4). LITMUS: no x1 < e_i relative-position literal on any live path. CONSTRAINTS (preserved from v5): purely additive; DO-NOT-EDIT (byte-identical) task-325/326 landed lemmas, kvE2_body/bracketEndChar_kvE2 splice, kvE_subChain2V, BracketCarrierCorrectVPrior, EANegation, F1-F4 records; no provider-side pinning (Amendment F3); anchor cap 2; G5 citations at every chain step; axiom-clean [propext, Classical.choice, Quot.sound]; no sorry on any live path. RE-SCOPE fallback (audit-sanctioned) only if the navigated fold + induction wiring exceeds budget: narrow to the interior + boundary fragment via task 326 + epL/epR/ptW, deferring exterior-navigated completeness. GOAL STATE: v6 GO gate unblocks task 309 Phase 13.4 (general-k one-step correctness) + Phase 14 (hook rewire discharging KampPrior.lean:351's strategic sorry). LITERATURE GROUNDING: /home/benjamin/Projects/Literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.md (Def 3.1/4.1, Prop 3.5, Prop 4.2, Prop 4.3, Lemma 5.1, Lemma 5.3, Cor 5.4). SCOPE AMENDMENT (2026-07-07, plan v7 Phase 10 decision gate): O4 (carrier-side per-sigma hgate derivation) FAILED its one dedicated dispatch — forward-zone conjunct underdetermined at cross-sigma slot points (inert O4 CRUX RECORD, SharedWitness.lean). Verdict N2: task re-scoped to the single-positive-sub fragment (Appendix N2 promoted into Phases 11-12). The GO/NO-GO deliverable for task 309 Phase 13.4 + KampPrior.lean:351 is now fragment-scoped; the multi-positive case (bit-compatibility filtering of kvE2_sepArrL/R, a carrier re-definition) is deferred to a successor task.

---

### 298. Fix c7 labeling bug and regenerate dataset
- **Status**: [PARTIAL]
- **Task Type**: lean4
- **Topic**: dataset-enhancement
- **Dependencies**: Task 297, Task 343
- **Research**: [298_fix_c7_labeling_bug_and_regenerate_dataset/reports/01_c7-labeling-bug.md]
- **Plan**: [298_fix_c7_labeling_bug_and_regenerate_dataset/plans/01_c7-labeling-bug.md]
- **Summary**: [298_fix_c7_labeling_bug_and_regenerate_dataset/summaries/01_c7-labeling-bug-summary.md]

**Description**: Fix c7 labeling bug at formula ~13750 that causes unbounded memory growth in the decision procedure's timeout handling, then regenerate the full c7 dataset. During task 297 dataset regeneration, all 3 attempts to generate c7 stalled at exactly record 13,749 with RSS growing ~40MB/6s. The labeling function enters an apparent infinite loop or unbounded search for formula #13,750 in the sorted enumeration order. The timeout mechanism either does not fire or cannot interrupt the stuck state. Steps: (1) Identify the specific formula at position ~13,750 in the c7 enumeration. (2) Reproduce the hang in isolation with that formula. (3) Diagnose whether the decision procedure's timeout is failing to fire or the procedure is in an uninterruptible state. (4) Fix the timeout handling so it reliably terminates. (5) Regenerate the full c7 dataset (target: 77,272 records)

---

### 296. Re add derived binary operators with dedup fix
- **Status**: [PARTIAL]
- **Task Type**: lean4
- **Topic**: dataset-enhancement
- **Dependencies**: Task 295, Task 298
- **Research**: [296_re_add_derived_binary_operators_with_dedup_fix/reports/01_derived-binary-operators.md]
- **Plan**: [296_re_add_derived_binary_operators_with_dedup_fix/plans/01_derived-binary-operators-plan.md]
- **Summary**: [296_re_add_derived_binary_operators_with_dedup_fix/summaries/01_derived-binary-operators-summary.md]

**Description**: Re-add the 6 derived binary temporal operators (release, weak_until, trigger, weak_since, strong_release, strong_trigger) to the formula enumerator, adjusting canonicalization and/or the passesFilter gate so they survive deduplication and appear in the unique pipeline output. These operators were removed in task 295 because they inflated the enumeration space by ~40-60% without contributing unique formulas — their canonical representations collapsed with primitives. Potential approaches: (1) skip canonicalization for formulas containing derived binary operators, (2) canonicalize to the derived form instead of the primitive form, (3) lower or remove the passesFilter complexity gate for these operators, (4) add a fold-aware dedup stage that treats release(p,q) as distinct from neg(untl(neg p, neg q)). The goal is to have all 13 derived operators represented in the final dataset.

---

### 282. Exhaustive enumeration by default
- **Status**: [PARTIAL]
- **Task Type**: lean4
- **Topic**: dataset-enhancement
- **Dependencies**: Task 274, Task 298
- **Plan**: [282_exhaustive_enumeration_by_default/plans/01_exhaustive-enumeration-plan.md]
- **Research**: [282_exhaustive_enumeration_by_default/reports/01_exhaustive-enumeration-default.md]
- **Summary**: [282_exhaustive_enumeration_by_default/summaries/01_exhaustive-enumeration-summary.md]

---

### 257. Large data storage huggingface
- **Status**: [BLOCKED]
- **Task Type**: general
- **Topic**: dataset-enhancement
- **Dependencies**: None
- **Research**: [257_large_data_storage_huggingface/reports/01_large-data-storage.md]
- **Plan**: [257_large_data_storage_huggingface/plans/01_implementation-plan.md]
- **Summary**: [257_large_data_storage_huggingface/summaries/01_execution-summary.md]

---

### 231. Dataset regeneration automation
- **Status**: [NOT STARTED]
- **Task Type**: general
- **Topic**: dataset-enhancement
- **Dependencies**: Task 230

**Description**: Build comprehensive automation so that every dataset regeneration automatically updates all downstream artifacts and documentation fields. Supersedes task 227 scope. (1) Create data/scripts/sync-all.py master sync script that: (a) Scans all JSONL files and recomputes metadata JSON files (record counts, rule distributions, schema field lists, valid/invalid ratios, tier distributions, step statistics). (b) Updates specific fields in data/README.md: file inventory table (Records, Size columns), training record schema table (field count), proof steps statistics (records, theorems, rule distribution, steps per theorem), cross-logic split table (records, valid rates), NL paraphrase statistics. (c) Updates specific fields in data/dataset-card.md: overview table, all record counts, proof steps section, competitive position 'primary gaps' paragraph. (d) Recomputes SHA-256 hashes and contentSize for all distributions in croissant.json. (e) Regenerates bmlogic-bench-splits.json. (f) Validates all JSONL records against declared schemas (checks field presence, types, null patterns). (g) Checks train/benchmark formula overlap and reports contamination percentage. (h) Validates metadata key consistency (total_records not total_count). (2) Idempotent and safe to run after any regeneration command (lake exe dataset_generator, lake exe proof_extractor, lake exe benchmark_oracle, finalize_benchmark.py). (3) --dry-run mode that reports what would change. (4) --commit mode that creates structured git commit. (5) CI-friendly exit codes (0=clean, 1=staleness detected, 2=validation error). (6) Update data/README.md with pipeline documentation. (7) Integrate into agent context (.claude/context/project/dataset/) so /implement for dataset tasks runs sync-all as post-implementation step. Note: supersedes task 227 (dataset_pipeline_automation_croissant_sync) with broader scope covering README/dataset-card field updates and schema validation.

---

### 219. Llm baseline difficulty calibration
- **Status**: [RESEARCHED]
- **Task Type**: general
- **Topic**: dataset-enhancement
- **Dependencies**: Task 231
- **Research**: [219_llm_baseline_difficulty_calibration/reports/01_llm-baseline-research.md]

**Description**: Run bmlogic-bench through multiple LLMs to establish baseline difficulty calibration. Evaluate at least 3 models (GPT-4o, Claude Sonnet, a 7B open model). Report zero-shot accuracy per difficulty tier (easy/medium/hard/very_hard), chain-of-thought vs direct label accuracy, error rate correlation with modal/temporal depth. Include random baseline (50% for balanced benchmark). Publish results in data/baselines/README.md with methodology. Both symbolic formula input and NL paraphrase input (if available from R1).

---

### 193. Codebase tactic refactor
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: automation
- **Dependencies**: Task 402
- **Research**: [193_codebase_tactic_refactor/reports/01_codebase-refactor-seed.md]

**Description**: Apply validity-intro and truth-simp macros to the soundness layer.

RE-SCOPED 2026-07-26 by the codebase tactic survey (now archived at specs/archive/196_codebase_tactic_survey/reports/02_automation-survey.md section 6.3). The original charter targeted Theorems/ using tm_prove. Theorems/ is 7,017 lines - 3.8% of the tree, half the relative share the 2026-05 research assumed - and is sorry-free and stable; tm_prove (task 192) is abandoned; and the search-family tactics it would have fallen back on have zero adoption. The task keeps its kind (an application pass that reduces existing proof text) and replaces its target and its instrument.

Define a small family of syntactic macros and apply them mechanically to the three files that concentrate the codebase two highest-frequency verbatim proof repetitions. This is an APPLICATION task: the deliverable is measured reduction in existing proof text at named files, not the existence of a macro.

Macros to define (single-line `macro ... : tactic` declarations - no elaboration, no goal inspection):
  - intros_validity           for `intro F M Omega _h_sc τ _h_mem t`
  - intros_validity_framed    for the frame-condition-prefixed variant
  - simp_truth                for the recurring `simp only [TruthAt, Truth.future_iff, Truth.past_iff, Truth.some_future_iff, Truth.some_past_iff]` bundle
  - unfold_validity           composing intros_validity with simp_truth, for sites where the two appear consecutively

NAMING NOTE (2026-07-27): the simp head symbol is `TruthAt`, not the pre-upgrade `truth_at` -- the systematic Mathlib naming upgrade renamed it. The `Truth.*_iff` names above are unchanged (declared in FormalSystem/Semantics/Truth.lean at :220 some_future_iff, :239 some_past_iff, :258 future_iff, :278 past_iff).

Measured target sites (re-verified 2026-07-27 against the working tree, Boneyard/ excluded; counts unchanged from the 2026-07-26 measurement, only the paths and the simp head symbol were restated):
  - FormalSystem/Metalogic/SoundnessLemmas/DenseValidity.lean      - 92 `intro F M Omega`, 54 `simp only [TruthAt`
  - FormalSystem/Metalogic/SoundnessLemmas/FrameClassVariants.lean - 56 `intro F M Omega`, 30 `simp only [TruthAt`
  - FormalSystem/Metalogic/Soundness.lean                          -  0 `intro F M Omega`, 47 `simp only [TruthAt`

DO BOTH MACRO GROUPS AS ONE PASS over the same files, not two. Splitting them edits the same two files twice and forfeits the unfold_validity collapse.

COMPLETION CRITERION: `intro F M Omega` occurrences in the two SoundnessLemmas/ files reach zero; `simp only [TruthAt` occurrences across the three files fall by at least 80%; lake build green; executable sorry count unchanged at 1, located BY CONTENT in FormalSystem/Metalogic/WeakCanonical/Transfer.lean, never by line number. A task that ends with working macros and unchanged proof text has FAILED.

EXPLICITLY OUT OF SCOPE: Theorems/ refactoring, tm_prove, modal_search and every other search-family tactic, and any new elaborated tactic. See the survey report section 5 for the measured evidence (38 real proof-site invocations across ~5,800 lines of proof automation, all 38 in one file).

DEPENDENCY ON THE SYSTEMATIC MATHLIB NAMING UPGRADE -- NOW DISCHARGED (2026-07-27): this task rewrites proof bodies at roughly 330 sites, and the naming-upgrade task rewrote the same reference graph at 24,364 sites while moving every file from Theories/Bimodal/ to FormalSystem/. A mass proof rewrite must not race a mass rename, so this task was held until that rename landed. It HAS landed -- the naming-upgrade task is status `completed` -- so the precondition is satisfied and this task is NOT blocked. Every path in this description, and every entry in file_scope, is now stated in its post-rename FormalSystem/ form; `Theories/Bimodal/` appears above only as the historical source of that move, never as a path to open.

Inventory groups drawn on: survey report section 4.2 groups 2 (intros_validity, score 153) and 3 (simp_truth, score 72.7).

---

### 179. Research lean4 tactics infrastructure
- **Status**: [RESEARCHED]
- **Task Type**: lean4
- **Topic**: automation
- **Dependencies**: None
- **Research**:
  - [179_research_lean4_tactics_infrastructure/reports/01_team-research.md]
  - [179_research_lean4_tactics_infrastructure/reports/02_mathlib-submission.md]
  - [179_research_lean4_tactics_infrastructure/reports/01_teammate-a-findings.md]
  - [179_research_lean4_tactics_infrastructure/reports/01_teammate-b-findings.md]
  - [179_research_lean4_tactics_infrastructure/reports/01_teammate-c-findings.md]
  - [179_research_lean4_tactics_infrastructure/reports/01_teammate-d-findings.md]

---

### 178. Publication examples and demo
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: formula-refactor
- **Dependencies**: Task 131, Task 193, Task 402

**Description**: Expand Examples/ with publication-quality demonstrations of the full verified pipeline. Complete worked example showing soundness-completeness-decidability on a concrete formula. Examples exercising each frame class with FrameClass-parameterized DerivationTree. Examples of the expressive completeness result. Update BimodalProofs.lean and TemporalStructures.lean. All examples sorry-free.

---

### 177. Update readme and module docstrings
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: formula-refactor
- **Dependencies**: Task 131, Task 193, Task 402

**Description**: Update all documentation to match final codebase state after refactoring. README.md axiom counts, architecture diagram, sorry obligations. Module-level docstrings for every file in the final structure. ROADMAP.md updates. Axiom Reference doc verification. This is the final documentation pass after all structural refactoring is complete.

---

### 175. Naming convention and bridge cleanup
- **Status**: [EXPANDED]
- **Task Type**: lean4
- **Topic**: formula-refactor
- **Dependencies**: Task 131, Task 402
- **Research**:
  - [175_naming_convention_and_bridge_cleanup/reports/01_team-research.md]
  - [175_naming_convention_and_bridge_cleanup/reports/01_teammate-a-findings.md]
  - [175_naming_convention_and_bridge_cleanup/reports/01_teammate-b-findings.md]
  - [175_naming_convention_and_bridge_cleanup/reports/01_teammate-c-findings.md]
  - [175_naming_convention_and_bridge_cleanup/reports/01_teammate-d-findings.md]

**Description**: Normalize naming conventions to follow Mathlib-style descriptive conventions and eliminate bridge/wrapper indirection for publication quality. Adopt Mathlib naming patterns: bot_of_and_neg instead of ecq, and_left instead of lce, and_right instead of rce, or_inl instead of ldi, or_inr instead of rdi, absurd instead of raa, False.elim instead of efq, not_not_intro instead of dni, etc. Expand opaque abbreviations (bfmcs, drm, cud, sdc, dd_, tc_, fuc_, buc_). Inline or remove Bridge.lean wrappers (993 lines, 16 forwarding definitions). Eliminate trivial primed variants. Normalize z1_valid to axiom_z1_valid for consistency. Rename temp_ prefix to temporal_ for clarity. Purge 81 removed/archived/superseded tombstone comments. Reference Mathlib naming conventions guide and task 179 research report for the full mapping.

CASING CONSTRAINT (added after the systematic Mathlib naming upgrade was scoped): the target names listed above are SNAKE_CASE, which is correct for `theorem`s but WRONG for `def`s under Mathlib convention -- and this repository has ~860 declarations that are forced to be `def` because `DerivationTree` is Type-valued. Any declaration that remains a `def` must receive a lowerCamelCase semantic name (`botOfAndNeg`, not `bot_of_and_neg`), or this task will reintroduce exactly the `defsWithUnderscore` violations its predecessor eliminated. Do not choose a target name without first establishing whether the declaration is a `def` or a `theorem`; where a `-> Prop` declaration can legitimately become a `theorem`, doing so is strictly better than renaming it, because it leaves the linter's scope entirely.

---

### 170. Complete dense extension completeness
- **Effort**: high
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: strong_completeness
- **Dependencies**: Task 361

**Description**: Dense (FrameClass.Dense) WEAK completeness green: make `completeness_dense` (BXCanonical/Completeness.lean:234) genuinely sorry-free by retiring the inherited chronicle dense-path sorries (BXCanonical/Chronicle/ChronicleToCountermodel.lean succ_reaches_dom_N / chronicle_gap_contradiction; MCSMixedCase.lean). Weak terminus feeding the finite-context strong-completeness capstone (task 362). Exact decomposition scoped by research task 361. (Repurposed from the former empty stub "complete_dense_extension_completeness".)

---

### 169. Complete frame extension setup and soundness
- **Effort**: high
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: strong_completeness
- **Dependencies**: Task 361

**Description**: Base (FrameClass.Base / general) WEAK completeness green: make the empty-context theorem `completeness` (BXCanonical/Completeness.lean:135, `valid φ → Nonempty (DerivationTree FrameClass.Base [] φ)`) genuinely sorry-free by retiring or rerouting its open sorries — the dense-arm `countermodel_dense` (:159), the deprecated `countermodel_discrete` path (:166 → Transfer.lean:1270, the "unfixable Z+Z" succ_cofinal route; reroute through the clean countermodel_discrete_reynolds_v2 where the base case overlaps), and `dd_countermodel_chronicle_mixed_sorry` (:170). Weak terminus feeding the finite-context strong-completeness capstone (task 362). Exact decomposition scoped by research task 361. (Repurposed from the former empty stub "complete_frame_extension_setup_and_soundness".)

---

### 165. Establish semantic finite model property
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: completeness
- **Dependencies**: None

**Description**: Establish the semantic finite model property for TM bimodal logic. The existing FMP in Decidability/FMP/ is purely proof-theoretic: it shows closure MCS structures are finite and that provability is decidable via MCS enumeration, but it does not construct finite semantic models (task frames with world histories). A standard semantic FMP requires: (1) Starting from a canonical model where phi fails, quotient worlds by agreement on the subformula closure. (2) Prove the filtration lemma for all formula constructors including Until/Since (known to be problematic for naive filtration). (3) Prove the quotient model is a valid task frame. (4) Bound the model size by 2^|cl(phi)|. The result should be stated as: if phi is satisfiable in a task model, then phi is satisfiable in a finite task model of bounded size.

---

### 161. Rename theories bimodal to formalsystem
- **Status**: [EXPANDED]
- **Task Type**: lean4
- **Topic**: formula-refactor
- **Dependencies**: Task 291

**Description**: Rename Theories/Bimodal/ to FormalSystem/. Move the entire Theories/Bimodal/ directory to FormalSystem/, update all imports in Lean files, update lakefile.lean srcDir from Theories to FormalSystem and roots from Bimodal to FormalSystem, update any references in README.md, Tests/, and other files that point to the old path. Ensure lake build still passes after the rename.

---

### 128. Open set operator dense continuous
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: frame-extensions
- **Dependencies**: None

**Description**: Add topological open set (interior) operator for dense and continuous temporal frames. On discrete ℤ the interior is trivial (discrete topology), but on dense ℚ and continuous ℝ it captures neighborhood-stable truth: Int(φ) true at t iff φ holds in an open neighborhood of t. Related to Dynamic Topological Logic (Kremer-Mints 2005), McKinsey-Tarski topological semantics for S4, and Fernandez-Duque intuitionistic temporal logic. Phase 1: add TopologicalSpace instance to TaskFrame for dense/continuous cases. Phase 2: add interior constructor to Formula with truth clause. Phase 3: axioms (S4-like: Int(φ)→φ, Int(φ)→Int(Int(φ))). Phase 4: interaction with temporal operators and S5 □. Note: DTL is not finitely axiomatizable (Fernandez-Duque 2014) — completeness may require non-standard techniques.

---

### 127. Time addition operator
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: frame-extensions
- **Dependencies**: None

**Description**: Add time addition operator (+) to the bimodal logic TM. φ + ψ is true at (τ, x) iff ∃ y,z with x = y+z, φ true at (τ,y), ψ true at (τ,z). This internalizes the AddCommGroup structure of D into the object language, extending expressive power from FO[<] to FO[<,+] (Presburger arithmetic). Related to arrow logic (Venema), relevant logic (Routley-Meyer ternary frames), and separation logic (BI). Phase 1: add tadd/tsub constructors to Formula, truth clause in semantics. Phase 2: basic axioms (associativity, commutativity, identity, inverse). Phase 3: soundness proofs. Phase 4: interaction with G/H/U/S/□. Completeness (ternary canonical model) and decidability are open research problems — defer to later phases.

---

### 125. Jonsson tarski representation bimodal sus
- **Status**: [NOT STARTED]
- **Task Type**: formal
- **Topic**: algebraic-representation
- **Dependencies**: None

**Description**: Implement a Jonsson-Tarski representation theorem for TM logic: every STSA embeds into the complex algebra of a concrete frame. Phased approach: Phase 1 — Complex algebra Cm(F): define powerset STSA for TaskFrames with box/G/H/sigma operators derived from frame relations. Prove Cm(F) satisfies all STSA axioms. Phase 2 — Ultrafilter frame Uf(A): given abstract STSA A, construct frame whose worlds are ultrafilters with canonical relations R_G, R_H, R_Box (seed infrastructure from task 163 recovery of UltrafilterChain.lean). Prove Uf(A) satisfies TaskFrame axioms. Phase 3 — Embedding theorem: prove eta(a) = {U | a in U} is an injective STSA homomorphism A into Cm(Uf(A)). Phase 4 — Since/Until extension: extend STSA typeclass with binary untl/sinc operators and prove representation for the full operator signature. Start with basic {box, G, H} fragment (Phases 1-3) before tackling S/U (Phase 4). Prerequisites: resolve 6 algebraic sorries (temp_k_dist, temp_a, temp_l in TenseS5Algebra/InteriorOperators/LindenbaumQuotient); obtain 3 missing papers (Jonsson-Tarski 1951/52, BRV 2001 Ch.5, Goldblatt 1989). Task 992 research report (01_stsa-algebraic-analysis.md) maps ~80% of needed infrastructure. Architecture: restructure Algebraic/ into Core/ (shared STSA/Boolean/ultrafilter), Completeness/ (renamed existing), Representation/ (new J-T work).

---

### 95. Completeness verification audit
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: completeness
- **Dependencies**: None

**Description**: Verify and record the final axiom/sorry status of the headline metalogical results, then close.

RE-SCOPED 2026-07-26. Most of this task's original content has been ANSWERED by the archivable-sorry review, which resolved the question definitively rather than partially. Do not re-derive it:

  - The discrete-case sorryAx trace is COMPLETE. `WeakCanonical.countermodel_discrete`
    (FormalSystem/Metalogic/WeakCanonical/Transfer.lean) is the SOLE sorryAx source reaching
    `BXCanonical.completeness`. This was established by a whole-environment
    `Lean.collectAxioms` scan, not by inference from names or file locations.
  - The tainted set is exactly 3 declarations: countermodel_discrete,
    completeness, completeness'. It was 47 before the archival.
  - `completeness_dense` and `completeness_discrete` are CLEAN.
  - The BX chronicle path named in the original charter
    (dd_countermodel_chronicle_discrete -> succ_embed_surjective ->
    chronicle_gap_contradiction) was dead code and has been ARCHIVED to
    FormalSystem/Boneyard/DeadChronicleGapElimination/. It is no longer in
    the build, so there is nothing left to trace along that path.
  - The dense and mixed chronicle countermodels were already confirmed
    sorry-free.

WHAT REMAINS -- a narrow confirmation pass, not an investigation:
  (1) Re-run `#print axioms` (or lean_verify) on the headline theorems and
      confirm the state above still holds. Record the result.
  (2) Confirm the live sorry count is exactly 1, located BY CONTENT in
      FormalSystem/Metalogic/WeakCanonical/Transfer.lean -- never by line number, it drifts
      with every edit to that file.
  (3) Record, in a durable location, that discharging countermodel_discrete is a
      genuine open construction rather than an oversight: the clean
      `countermodel_discrete_reynolds_v2` requires a Discrete-MCS, and the old
      BX route is PROVABLY unavailable (succ_cofinal is refuted by the Z+Z
      counterexample). Proving it belongs to its own task.

METHODOLOGY WARNING, established the hard way: do NOT build a reverse-dependency
graph over `ConstantInfo.value?` to decide what depends on what. Under Lean
4.33's module system imported THEOREM bodies are unavailable, so such a graph
silently under-reports -- it wrongly showed countermodel_discrete as having zero
consumers, which would have led to archiving the one sorry that breaks
completeness. Use `Lean.collectAxioms` plus textual analysis instead.

EXPECTED OUTCOME: this task most likely closes as verified-complete. If step (1)
or (2) diverges from the state above, that divergence IS the finding and should
be reported prominently rather than silently reconciled.
