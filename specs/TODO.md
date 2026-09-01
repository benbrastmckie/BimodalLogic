---
next_project_number: 516
---

# TODO

## Task Order

*Updated 2026-09-01. Generated from state.json dependency graph.*

**Dependency Waves**:
| Wave | Tasks | Blocked by | Topics |
|------|-------|------------|--------|
| 1 | 127,128,257,298,433,461,476,481,493,495,504,506,507 | -- | dataset-enhancement, decidability, frame-extensions, ... |
| 2 | 231,282,296,463,502,510,513 | 298,433,461,507 | algebraic-representation, dataset-enhancement, decidability, ... |
| 3 | 219,464,497,508 | 231,463,502,510 | algebraic-representation, dataset-enhancement, decidability, ... |
| 4 | 193,465,498,499,500,509 | 464,493,497,508 | algebraic-representation, automation, decidability, ... |
| 5 | 125,178,428,494 | 193,465,498,499,509 | algebraic-representation, decidability, formula-refactor, ... |
| 6 | 429,501 | 125,428 | algebraic-representation, decidability |
| 7 | 410 | 429 | decidability |
| 8 | 411 | 410 | decidability |
| 9 | 430 | 411 | decidability |
| 10 | 177,412 | 193,430,494,513 | decidability, formula-refactor |
| 11 | 482 | 412 | decidability |

**Grouped by Topic** (indented = depends on parent):

### Algebraic Representation

125 [NOT STARTED] — CAPSTONE of the algebraic representation front. Prove the Jonsson
  └─ 501 [NOT STARTED] — Phase 4 of the Jonsson-Tarski representation: extend STSA with th
497 [NOT STARTED] — Bring the Shift-closed Tense S5 Algebra class into live code and 
  └─ 498 [NOT STARTED] — Phase 1 of the Jonsson-Tarski representation: the complex algebra
    └─ 125 [NOT STARTED] — CAPSTONE of the algebraic representation front. Prove the Jonsson (see above)
  └─ 499 [NOT STARTED] — HARD. Phase 2 of the Jonsson-Tarski representation: the ultrafilt
    └─ 125 [NOT STARTED] — CAPSTONE of the algebraic representation front. Prove the Jonsson (see above)
  └─ 500 [NOT STARTED] — RESEARCH TASK. Prevent two parallel representation theorems from 
502 [NOT STARTED] — RESEARCH TASK. Ground the algebraic representation front in the l
  └─ 497 [NOT STARTED] — Bring the Shift-closed Tense S5 Algebra class into live code and  (see above)

### Automation

193 [NOT STARTED] — Apply validity-intro and truth-simp macros to the soundness layer

### Dataset Enhancement

257 [BLOCKED] — Complete the Hugging Face Hub migration for large dataset storage
298 [PARTIAL] — Fix c7 labeling bug at formula ~13750 that causes unbounded memor
  └─ 231 [NOT STARTED] — Build comprehensive automation so that every dataset regeneration
    └─ 219 [RESEARCHED] — Run bmlogic-bench through multiple LLMs to establish baseline dif
  └─ 282 [PARTIAL] — Flip complexity-9 dataset generation from stratified to exhaustiv
  └─ 296 [PARTIAL] — Re-add the 6 derived binary temporal operators (release, weak_unt

### Decidability

433 [PARTIAL] — Discharge `PostBlockingSettles fc`, defined at FormalSystem/Metal
  └─ 463 [NOT STARTED] — Decide `PostBlockingSettlesRun fc (mintAwareFuelAt U.card Tmax mi
    └─ 464 [NOT STARTED] — Design and land `gapPotential`, the density coordinate of the ter
      └─ 465 [NOT STARTED] — Complete the terminus restatement family at the repaired residual
        └─ 428 [BLOCKED] — Engine totality at a quantified branch budget. Owns obstruction O
          └─ 429 [NOT STARTED] — Repair the truth-lemma side conditions. Owns obstructions O2 and 
            └─ 410 [PLANNED] — Track B part 1 for the TM tableau decidability program (parent: t
              └─ 411 [NOT STARTED] — Track B part 2 for the TM tableau decidability program (parent: t
                └─ 430 [NOT STARTED] — The semantic lift and the Track A assembly. Owns obstruction O4 o
                  └─ 412 [NOT STARTED] — Track B finish for the TM tableau decidability program (parent: t
                    └─ 482 [NOT STARTED] — CLASSIFICATION: OPEN MATHEMATICS, multi-month. This MUST NOT be r
476 [NOT STARTED] — THE BOX-FAITHFUL SMALL-MODEL THEOREM.
481 [BLOCKED] — CLASSIFICATION: genuinely open -- the predicate is refuted as sta

### Formula Refactor

177 [NOT STARTED] — Update README.md, docs/, and FormalSystem/ module-level docstring
178 [NOT STARTED] — Expand Examples/ with publication-quality demonstrations of the f

### Frame Extensions

127 [NOT STARTED] — Add time addition operator (+) to the bimodal logic TM. φ + ψ is 
128 [NOT STARTED] — Add topological open set (interior) operator for dense and contin

### Literature

461 [NOT STARTED] — SCOPE 8 acquisition gap identified by task 457's research and re-
504 [NOT STARTED] — Retry acquisition of the standard modal-representation sources th

### Metalogic

495 [RESEARCHED] — RESEARCH TASK, DELIBERATELY AGNOSTIC ABOUT THE VERDICT. Determine
507 [PLANNED] — ROOT FIX for the metalogic systematicity front. Give the proof-si
  └─ 510 [NOT STARTED] — Decide the fate of FormalSystem/FrameConditions/ (4 modules, 906 
    └─ 508 [NOT STARTED] — Collapse ~23 soundness theorems into ONE parameterized theorem pl
      └─ 509 [NOT STARTED] — Make the compactness / strong-completeness layer a FrameClass-ind

### Publication Quality

506 [NOT STARTED] — Fix all outstanding display/layout defects in the compiled typst 

### Strong Completeness

493 [RESEARCHED] — Assemble the compactness result and collect strong completeness f
494 [NOT STARTED] — NOW SEQUENCED BEHIND THE COMPACTNESS PARAMETERIZATION (see the RE

### Correspondence Theory

513 [NOT STARTED] — GALOIS-CLOSURE IMPLEMENTATION for the frame-class layer, replacin

## Tasks

### 515. Eliminate overlapping nontrivial instance warnings
- **Status**: [COMPLETED]
- **Task Type**: lean4
- **Topic**: code-quality
- **Dependencies**: None
- **Research**: [515_eliminate_overlapping_nontrivial_instance_warnings/reports/01_overlapping-nontrivial-instance-warnings.md]
- **Plan**: [515_eliminate_overlapping_nontrivial_instance_warnings/plans/01_eliminate-overlapping-instance-binders.md]
- **Summary**: [515_eliminate_overlapping_nontrivial_instance_warnings/summaries/01_eliminate-overlapping-instance-binders-summary.md]

**Description**: Eliminate the 21 remaining "Overlapping instance parameters -- There are 2 [Nontrivial D] instances; one is sufficient" warnings across three Metalogic files. All 21 are the same linter class, but they split into two structurally DIFFERENT shapes and the second needs real judgment -- do not treat this as a uniform find-and-replace.

PRECEDENT, ALREADY DONE (do not redo): the same warning class was fixed in FormalSystem/Semantics/TaskFrame.lean at 9 sites in commit e73dcb62f -- limit_of_shift, exists_uniform_radius_of_finite, exists_pos_of_nontrivial, limit_of_eq, staticFrame_rel_iff, staticFrame_serial, staticFrame_interpolates, staticFrame_limit, staticFrame_spherical. There the fix was mechanical: each theorem re-declared [Nontrivial D] explicitly while the enclosing section variable blocks (:783, :1308) already bound it; deleting the explicit binder sufficed. Result: 9 -> 0 overlapping warnings, 0 errors, and unused-section-variable warnings also dropped 30 -> 20 because the section binder became genuinely used. Full lake build green, 2506 jobs. Use that commit as the reference pattern for CLASS A below.

AUTHORITATIVE SITE LIST. Do not re-derive by grepping for the binder text -- 4 of the 21 sites carry no explicit [Nontrivial D] on the flagged line and a text grep will miss them. Get the list from the compiler: `lake env lean <file>` and read the "Overlapping instance parameters" diagnostics.

CLASS A -- MECHANICAL (17 sites). An explicit [Nontrivial D] on the declaration duplicates an enclosing section variable binder. Same fix as TaskFrame: delete the explicit binder only.
  FormalSystem/Metalogic/Algebraic/FlowFrame.lean (section binder at :449) -- 13 sites:
    :466 bundleFlowFrame, :472 bundleFlowHistory, :479 bundleFlowModel, :483 bundleFlowHistory_total,
    :491 bundleFlow_pos_shift, :498 bundleFlow_comp_iff, :506 bundleFlow_serial, :514 bundleFlow_limit,
    :521 bundleFlow_spherical, :533 bundleFlow_total_eq, :549 bundleFlow_total_eq_range,
    :678 bundleFlow_truth_lemma, :803 bundleFlow_completeness_from_neg_membership
  FormalSystem/Metalogic/Decidability/Verified/Decidable.lean (section binder at :136) -- 4 sites:
    :2144 exists_gt_self, :2149 exists_lt_self, :2162 exists_gt_not_untl_disj, :2172 exists_lt_not_snce_disj

CLASS B -- NOT MECHANICAL (4 sites), THE REAL CONTENT OF THIS TASK. These have NO explicit [Nontrivial D] on the flagged line. The duplication arises from nested/shadowing section variable blocks, so the fix is a decision about which block should own the instance -- not a deletion.
  FormalSystem/Metalogic/Decidability/Verified/Bridge/TruthLemma.lean -- :364 RegionValued, :374 atomRegionInvariant_regionHistory, :389 interpInvariantAt_regionHistory.
    Structure: an outer `variable {D : Type} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D]` at :74, then `section Countermodel` at :343 whose :345 RE-DECLARES `{D : Type}` (shadowing the outer D) and whose :351 binds [Nontrivial D] again. Both get auto-included.
  FormalSystem/Metalogic/Decidability/Verified/Decidable.lean:2761 truthAt_sep -- [Nontrivial D] sits on a CONTINUATION line (:2762, alongside [DenselyOrdered D]) under the :136 section binder, so it is a Class A shape hiding from a single-line grep, but confirm that before treating it as one.

BINDING CONSTRAINT ON CLASS B: a careless fix here can silently change WHICH `D` a theorem quantifies over, inside the decidability bridge. Establish, before editing, whether the shadowing at TruthLemma:345 is deliberate (the Countermodel section genuinely working over a different D) or accidental. If deliberate, the outer binder must not simply be deleted. State the finding explicitly in the plan and justify the chosen owner of the instance; do not infer it from the fact that the build stays green, since both arrangements may well compile.

PROHIBITIONS:
- Do NOT use `set_option linter.overlappingInstances false`, at any scope. The duplicate is what gets removed, never the warning.
- Do NOT restructure section variable blocks beyond what removing the duplication requires.
- Do NOT modify FormalSystem/Semantics/TaskFrame.lean; it is already fixed and verified.
- Do NOT touch FormalSystem/Semantics/Ultraproduct/** or ShiftSet.lean.

ACCEPTANCE:
- `lake env lean` on each of the three files reports 0 "Overlapping instance parameters" diagnostics; tree-wide the count goes 21 -> 0.
- Full `lake build` exits 0 with no new errors and no new warnings of any other class. Note the guard shares completed results: force a genuine full build and confirm the job count (~2506), because a scoped result can replay and present as a full pass.
- `lake test` green.
- No `sorry`, `admit`, or `native_decide` introduced; no linter disabled anywhere (`grep -rn overlappingInstances FormalSystem/` returns nothing).
- The plan records, per Class B site, which variable block owns [Nontrivial D] and why.

WHY THIS IS A TASK AND NOT AN AD-HOC FIX: it spans three files in a subsystem separate from where it was discovered, contains four sites needing genuine judgment about binder ownership in the decidability bridge, and each verification round costs a full multi-minute rebuild. It surfaced incidentally during unrelated ultraproduct work; it is pre-existing and unrelated to that work.

---

### 513. Uniform frame faithfulness predicate
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: correspondence theory
- **Dependencies**: Task 512, Task 507

**Description**: GALOIS-CLOSURE IMPLEMENTATION for the frame-class layer, replacing the uniform-faithfulness
question, which is ANSWERED and closed: no uniform Faithful predicate is needed for
Dense/Discrete (class-level exactness already holds via indicator axioms) and none can exist
for Complete (Reynolds: completeness is not characterizable by temporal formulas — the sep
docstring in ProofSystem/Axioms.lean already quotes this; sep itself has no correspondent,
511 report 01 §6.5). Design (A)-with-indicators is the design of record.

DELIVERABLES (all post-512, post-507; spec at
specs/514_align_definitions_with_source_paper/reports/01 §3.3–3.4):
(1) Semantics/Correspondence/Galois.lean: Th, Mod, antitonicity, closure operator,
GaloisClosed — one definition pair, no per-class copies.
(2) Indicator exactness: F.ValidOn ¬X⊤ ↔ DenselyOrdered F.Duration and the X⊤/discrete dual;
corollaries Mod(Th(Sat .Dense)) = Sat .Dense and the paper-Discrete analogue; the
Derivable-level X⊤-from-prior_UZ+serial_future lemma.
(3) Per-axiom closure of the density schema: port 511's Corr.density_iff_fwdRec (atomic,
arbitrary D) and Bridge.density_schema_iff_fwdRec (schema, D = Z) from the probe files into
the tree over bundled frames, stated as Mod {density} = {F | FwdRec F} at Z.
(4) Duration-level correspondence (T1) for DF/DN/CO in the paper's proven form —
"(∀ F over D, F ⊨ ax) ↔ D is Discrete/Dense/Complete" — with the translation frame and the
two-state permissive frame as (⇒) witnesses (app:discrete/app:dense/app:complete adjudication:
report 01 §2.4).
(5) Non-closure witnesses: generalize the static-frame time-invariance lemma to arbitrary D
(03_probes density_of_hist_periodic is the pattern); derive staticFrame over Q ∈
Mod(Axioms .Complete) \ Sat .Complete and staticFrame over Z ×ₗ Z ∈ Mod(Axioms .Discrete) \
Z-time; sandwich corollaries Z-time ⊊ Mod(TM+_f) ⊆ paper-Discrete and R-time ⊊ Mod(TM+_c) ⊆
Sat .Dense.
(6) EXPLICIT NON-GOALS, recorded so the question is not reopened: closed-form
characterizations of Mod(TM+_f) and Mod(TM+_c) are OPEN and not promised — evidence: no
variable-free BL+ sentence separates Z from Z ×ₗ Z or Q from R, and sep has no correspondent.

ACCEPTANCE: sorry-free, lake build green, every theorem above stated over bundled frames with
Sat from 507, axiom profiles clean; the FwdRec port must not re-prove what the probes proved —
transplant and restate. GROUNDING: possible_worlds.tex def:frame-properties, def:frame-validity,
cor:tm-completeness, app:discrete/dense/complete;
specs/514_align_definitions_with_source_paper/reports/01;
specs/511_research_frame_correspondence_infrastructure/reports/01–03 + probes.

---

### 511. Research frame correspondence infrastructure
- **Status**: [EXPANDED]
- **Task Type**: formal
- **Topic**: metalogic
- **Dependencies**: Task 514, Task 512, Task 513
- **Research**:
  - [511_research_frame_correspondence_infrastructure/reports/03_e2-periodicity.md]
  - [511_research_frame_correspondence_infrastructure/reports/01_frame-correspondence-infrastructure.md]
  - [511_research_frame_correspondence_infrastructure/reports/02_per-frame-correspondence-reassessment.md]

**Description**: RESEARCH TASK, DELIBERATELY AGNOSTIC ABOUT FEASIBILITY. Determine what frame-correspondence infrastructure this bimodal setting can support, and specify it. THE GAP IS TOTAL, NOT PARTIAL: there is NO result anywhere in the live tree of the form 'axiom X is valid on frame class C IF AND ONLY IF C satisfies condition Y'. A search for correspond|characteriz|definabl|Sahlqvist across live code returns only chronicleMonadic_truth_correspondence (a chronicle/monadic bridge, BXCanonical/Chronicle/ChronicleMonadicBridge.lean:413), SetMaximalConsistent.ultrafilter_correspondence (algebraic, Algebraic/UltrafilterMCS.lean:782), and the *Definable* family in WeakCanonical/EFGames/ -- which concerns DEFINABLE GAPS in the Kamp/Ehrenfeucht-Fraisse machinery, not axiom-frame correspondence. WHAT EXISTS IS THE SUFFICIENCY HALF ONLY: Axiom.minFrameClass declares the intended class per axiom (a definition, not a theorem); Metalogic/SoundnessLemmas/ proves each axiom valid on its class. The NECESSITY half -- that each frame condition is required, i.e. the axiom fails on some frame violating it -- is established nowhere systematically. The closest artifacts are the three ad hoc non-derivability countermodels in Metalogic/Independence/ (ClockFrame.lean, LoopingDuration.lean, CoNotPriorU.lean), which are per-axiom and not organized as correspondence. CONSEQUENCE: Axiom.minFrameClass is currently an ASSERTION about the axiom-class relation with one direction proven, and the tree cannot state 'TM+_d is the logic of dense task frames' as a theorem. SCOPE: (a) which of the 45 axiom constructors admit a correspondence argument at all; (b) whether Sahlqvist-style machinery transfers to task frames with Until/Since and an S5 modality, or whether a bespoke argument is needed per axiom layer -- DO NOT ASSUME IT TRANSFERS; (c) what the right general statement is here given that frame classes are carrier-type constraints (DenselyOrdered, SuccOrder, LUB) rather than relational conditions on a Kripke accessibility relation, which is the setting standard correspondence theory assumes; (d) whether the Independence/ countermodels generalize into the necessity half. A NEGATIVE OR HEAVILY-QUALIFIED VERDICT IS A COMPLETE OUTCOME -- if correspondence in the textbook sense does not apply to carrier-constraint frame classes, say so with evidence and specify whatever weaker characterization IS available, so the question is not reopened. SEQUENCING: run alongside the TM-completeness-characterization research task, which asks the adjacent question for the BaseLanguage fragment. DELIVERABLE: a report with a verdict and, if affirmative, a concrete construction specification. GROUNDING: specs/reviews/review-2026-08-31-metalogic-systematicity.md issue M2.=== DIRECTION AMENDED (three research reports complete; construction spec partially retired) ===
VERDICT REACHED AND MACHINE-VERIFIED across reports 01/02/03 (evidence: 02_probes.lean,
03_probes.lean, both sorry-free):
  - Carrier-only correspondence (`forall D F, F |= ax <-> Cond(D)`) is FALSE and mis-shaped -- it
    quantifies over frames on the left and only over the carrier on the right.
  - Per-frame correspondence in its textbook shape `F |= ax <-> C(F)` EXISTS and is proved for
    density: `Corr.density_iff_fwdRec` (atomic, arbitrary D) and
    `Bridge.density_schema_iff_fwdRec` (every formula, at D = Z).
  - `FwdRec F` implies every total history is periodic (at D = Z), via determinism.
  - The differentiation/refined-frame side-condition route is exactly trivial, not merely
    near-trivial, and is refuted for good.

RETIRED FROM THE CONSTRUCTION SPEC (report 02 section 9): Phase D (`transFrame` + Tier 1
`ValidOn D density <-> DenselyOrdered D`) is CUT. It is duration validity -- the notion this
project is rejecting -- and it was the only genuinely new proof work in the spec. Phase E1 was
already deleted by report 03. What remains (Phases A, B', C, E2) is transcription of proofs that
compile today, restated at frame level.

DEPENDS ON: the TaskFrame duration-bundling refactor (correspondence must be stated per-frame on
bundled frames, not per-carrier), and on the uniform frame-faithfulness research task, which
decides whether the correspondent is a bare frame condition (`FwdRec`) or `Sat (minFrameClass ax)`
under a uniform non-degeneracy hypothesis. Do not implement before that design question is settled
-- the choice determines the shape of every per-axiom correspondence theorem that follows.

STILL OPEN: E2' -- over a general non-dense D, does FwdRec still give full-schema density, with
"periodic" weakened to shift-recurrence under a history-preserving order automorphism? Currently
[paper], unverified; the counterexample is the sum of Z/nZ over Z x_lex Z. All exactness claims are
scoped to D = Z and nowhere wider.

=== BOARD NOTE (task 514 postflight) ===
Research complete and absorbed: FwdRec and the Tier-1/T1 statements land under revised task
513; probe files remain the evidence of record. Terminal at [RESEARCHED]; do not dispatch
/plan 511.

---

### 510. Resolve orphaned frameconditions layer
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: metalogic
- **Dependencies**: Task 507

**Description**: Decide the fate of FormalSystem/FrameConditions/ (4 modules, 906 lines) -- currently orphaned code that also contains a half-built version of the validity parameterization. MEASURED STATE: consumers outside the directory itself number exactly ONE, the library aggregator FormalSystem/FormalSystem.lean:13. Nothing in Metalogic/, Semantics/, Theorems/, or Tests/ references any definition it exports. SILENT REGRESSION TO RECORD: archived task 58 logged 'Wire completeness to FrameConditions -- wiring is DONE: completeness_over_Int, discrete_completeness_fc, dovetailed_bundle'. All three identifiers are ABSENT from the entire live tree today; the wiring was removed and the claim never retracted. Its README separately states the live-importer count as 1 without drawing the conclusion. THREE THINGS IT CONTAINS: (a) FrameClass.lean marker typeclasses LinearTemporalFrame(:88), SerialFrame(:103), DenseTemporalFrame(:124), DiscreteTemporalFrame(:148), DedekindTemporalFrame(:182) -- the binder-list-as-predicate-on-D that the prerequisite parameterization needs, and which it should consume rather than re-invent; (b) Validity.lean's ValidOver/ValidLinear/ValidDenseFc/ValidDiscreteFc/ValidOverInt (:59,:79,:89,:100,:199), a FOURTH parallel validity vocabulary plus the bridge lemmas that exist only to translate to and from Semantics/Validity.lean; (c) Compatibility.lean's AxiomLinearCompatible/AxiomDenseCompatible/AxiomDiscreteCompatible (:85,:93,:102) with roughly 40 hand-written per-axiom instances that duplicate Axiom.minFrameClass -- whose own docstring calls itself 'the single source of truth for axiom-frame-class compatibility' and says it 'replaces the ad-hoc predicates isBase, isDenseCompatible, isDiscreteCompatible'. Both encodings are live. DELIVERABLE: an explicit verdict, executed. PROMOTE (marker typeclasses become the FrameClass interpretation, tree consumes them) or DELETE. Its README argues for staying separate on layering grounds, but that argument addresses placement, not zero consumers, and under the promote path the layering inverts anyway since the interpretation belongs beside Semantics/Validity.lean, below Metalogic/. THE AxiomCompatible INSTANCES SHOULD GO IN EITHER CASE -- minFrameClass supersedes them. A DELETE VERDICT IS A COMPLETE OUTCOME if the prerequisite task chose a different interpretation. ACCEPTANCE: no orphaned validity vocabulary remains; lake build green; check-module-invariants.sh C6 unreachable-module count updated and manifested. GROUNDING: specs/reviews/review-2026-08-31-metalogic-systematicity.md issue M1.=== DIRECTION NOTE ===
The FrameClass-indexed validity this task builds on is being defined at FRAME level, not carrier
level: `FrameClass.Sat : FrameClass -> TaskFrame -> Prop` and
`ValidIn fc phi := forall F : TaskFrame, fc.Sat F -> F |= phi`, on frames that carry their own
duration type. Do not plan against the earlier carrier-quantified shape
(`fc.Sat D -> ValidOver D phi`), which is superseded. This task sequences transitively behind the
TaskFrame duration-bundling refactor via its dependency on the indexed-validity task.

=== VERDICT PRE-REGISTERED BY TASK 514 RESEARCH === DELETE. Under the frame-level Sat of 507
the carrier-typeclass layer has no role and no paper counterpart (the paper has no
carrier-level validity notion at all — def:frame-validity is per-frame, ⊨_C is per-class).
Execute as deletion + C6 manifest update; promotion is off the table unless 507's
implementation discovers a concrete consumer, which its plan must record explicitly if so.

---

### 509. Parameterize compactness and strong completeness family
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: metalogic
- **Dependencies**: Task 493, Task 507, Task 508

**Description**: Make the compactness / strong-completeness layer a FrameClass-indexed family instead of three hand-copied rows with a missing fourth. THE ARCHITECTURE IS ALREADY RIGHT AND IS THE PLAN OF RECORD -- strong completeness derived from compactness plus weak completeness. Present and sorry-free: strongCompletenessBase_of_compact (StrongCompleteness.lean:314), strongCompletenessDense_of_compact (:340), compactBase_of_modelExistence (:378), compactDense_of_modelExistenceDense (:424), and the negative results discrete_consequence_not_compact (DiscreteNonCompactness.lean:250) and strongCompletenessDiscrete_refuted (:280). WHAT IS WRONG IS THE SHAPE, NOT THE MATHEMATICS. SetConsequence.lean defines the family once per class by hand: Base at :214,:222,:230,:245; Dense at :262,:269,:277,:291; Discrete at :315,:329,:342 (ModelExistenceDiscrete correctly absent, it is refuted); Dedekind ENTIRELY ABSENT. And the two strongCompleteness*_of_compact reductions are the same argument written twice. DELIVERABLE: (1) StrongCompleteness (fc), Compact (fc), SatisfiableSet (fc), ModelExistence (fc) as one indexed family over the interpretation landed by the prerequisite; (2) ONE strongCompleteness_of_compact (fc) replacing the two reductions; (3) ONE modelExistence_implies_compact (fc) replacing the two bridges; (4) the existing Base/Dense/Discrete results recovered as instantiations with identical statements and axiom profiles. WHY THIS SEQUENCES BEFORE THE DEDEKIND REFUTATION TASK: that task's Part 1 is specified as defining the missing vocabulary 'mirroring the Base/Dense/Discrete groups' -- a fourth hand copy of exactly what this task collapses. After this lands, its Part 1 becomes a single instantiation and only its genuinely hard Part 2 (a new non-compactness witness that cannot reuse archWitness, since the Dedekind binder list has no successor structure) remains. DOES NOT DISCHARGE ANYTHING: ModelExistenceBase/Dense stay unproven here; the ultraproduct chain owns that. This is a restructuring task, and the conditional results must stay exactly as strong as they are today. ACCEPTANCE: sorry-free, lake build green, every currently-provable result still provable with an unchanged axiom profile. GROUNDING: specs/reviews/review-2026-08-31-metalogic-systematicity.md issue H3.=== DIRECTION NOTE ===
The FrameClass-indexed validity this task builds on is being defined at FRAME level, not carrier
level: `FrameClass.Sat : FrameClass -> TaskFrame -> Prop` and
`ValidIn fc phi := forall F : TaskFrame, fc.Sat F -> F |= phi`, on frames that carry their own
duration type. Do not plan against the earlier carrier-quantified shape
(`fc.Sat D -> ValidOver D phi`), which is superseded. This task sequences transitively behind the
TaskFrame duration-bundling refactor via its dependency on the indexed-validity task.

=== PAPER GROUNDING === Targets def:soundness / def:logical-consequence / cor:tm-completeness's
⊨_C and per-class strong/weak completeness roster (TM+ strong over all task frames; TM+_d
strong over dense; TM+_f weak over Z-time; TM+_c weak over dense-and-complete). Class naming
follows 507: the class keeps the name .Dedekind (the .Complete rename was rejected — "complete"
is reserved in this tree for proof-theoretic completeness). See
specs/514_align_definitions_with_source_paper/reports/01 §1.2.

=== SEQUENCING EDGE ADDED (file-safety, not a mathematical dependency) ===
The 493 entry in dependencies[] is a SERIALIZATION edge, not a proof dependency. Both this task
and 493 rewrite FormalSystem/Metalogic/StrongCompleteness.lean: 493 discharges the engine
hypotheses of strongCompletenessBase_of_compact (:305) and strongCompletenessDense_of_compact
(:331) in their existing shape, while this task restates that same file as a FrameClass-indexed
family. With no edge between them, /orchestrate wave assignment would place them in the SAME
wave (per commands/orchestrate.md: two tasks share a wave whenever no dependencies[] edge
connects them) and 493 declares no file_scope, so the in_batch collision detector cannot see the
overlap. Order is 493 first: it lands the mathematical content, this task then reshapes it.
Do not remove this edge as spurious.

---

### 508. Parameterize soundness over indexed validity
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: metalogic
- **Dependencies**: Task 507, Task 510

**Description**: Collapse ~23 soundness theorems into ONE parameterized theorem plus corollaries. CURRENT DUPLICATION, all instances of a single schema: Metalogic/Soundness.lean has soundness(:1100), soundness_dense(:1274), soundness_discrete(:1420), soundness_dedekind(:1947) plus three *_valid variants(:1205,:1368,:1928); Metalogic/StrongCompleteness.lean has soundness_{base,dense,discrete,dedekind}_consequence(:667,:771,:879,:524); FrameConditions/Soundness.lean has soundness_over, soundness_linear, soundness_dense, soundness_discrete, soundness_Int; Metalogic/BaseLanguageSoundness.lean has bl_soundness{,_dense,_discrete,_dedekind} plus four *_valid variants(:168-252). Metalogic/SoundnessLemmas/FrameClassVariants.lean (1041 lines) exists solely to carry per-frame-class variants of the axiom-validity lemmas. TARGET: one theorem, Derivable fc Gamma phi -> SetSemanticConsequence fc Gamma phi, by induction on the derivation, with the axiom case discharged from the Axiom.minFrameClass <= fc side condition already carried by DerivationTree's axiom constructor plus a per-axiom validity lemma. The existing theorems become one-line corollaries. BL SIDE COLLAPSES FOR FREE: blValid_iff_valid_tr (BaseLanguageSoundness.lean:141) already reduces BL validity to Formula validity through the translation tr, so BLValidOn fc phi := ValidOn fc (tr phi) subsumes all four BLValid* definitions (BLValidity.lean:77,102,115,132), the three blValid_implies_* bridges (:153,:157,:162), and all eight bl_soundness* theorems -- do NOT scope that as separate work. CONSTRAINT: preserve the soundness_dedekind target discipline -- it targets ValidDedekindDense, not ValidDedekind, and the docstring at Validity.lean:301 explains why retargeting is refutable. ACCEPTANCE: sorry-free, lake build green, axiom profiles preserved on all flagship soundness results, no theorem weakened. GROUNDING: specs/reviews/review-2026-08-31-metalogic-systematicity.md issue H2 and M3.=== DIRECTION NOTE ===
The FrameClass-indexed validity this task builds on is being defined at FRAME level, not carrier
level: `FrameClass.Sat : FrameClass -> TaskFrame -> Prop` and
`ValidIn fc phi := forall F : TaskFrame, fc.Sat F -> F |= phi`, on frames that carry their own
duration type. Do not plan against the earlier carrier-quantified shape
(`fc.Sat D -> ValidOver D phi`), which is superseded. This task sequences transitively behind the
TaskFrame duration-bundling refactor via its dependency on the indexed-validity task.

=== PAPER GROUNDING === Targets def:soundness / def:logical-consequence / cor:tm-completeness's
⊨_C and per-class strong/weak completeness roster (TM+ strong over all task frames; TM+_d
strong over dense; TM+_f weak over Z-time; TM+_c weak over dense-and-complete). Class naming
follows 507: the class keeps the name .Dedekind (the .Complete rename was rejected — "complete"
is reserved in this tree for proof-theoretic completeness). See
specs/514_align_definitions_with_source_paper/reports/01 §1.2.

---

### 507. Parameterize validity by frameclass
- **Status**: [PLANNED]
- **Task Type**: lean4
- **Topic**: metalogic
- **Dependencies**: Task 514, Task 512
- **Research**: [507_parameterize_validity_by_frameclass/reports/01_frameclass-indexed-validity.md]
- **Plan**: [507_parameterize_validity_by_frameclass/plans/02_frame-level-validity-indexing.md]

**Description**: ROOT FIX for the metalogic systematicity front. Give the proof-side FrameClass tag a SEMANTIC interpretation, then define validity ONCE, indexed by it. THE ASYMMETRY: the proof side is already fully parameterized -- Derivable (fc : FrameClass) (ProofSystem/Derivable.lean:69), DerivationTree (fc : FrameClass) (ProofSystem/Derivation.lean:91), DerivationTree.lift along fc1 <= fc2 (Derivation.lean:184), PartialOrder FrameClass (ProofSystem/Axioms.lean:551), Axiom.minFrameClass as declared single source of truth (Axioms.lean:531ff). The semantic side has NONE of this: 15 hand-copied validity predicates with no fc index (5 in Semantics/Validity.lean:94,206,248,301,336; 4 in Semantics/BLValidity.lean:77,102,115,132; ValidInt in Semantics/IntTransfer.lean; 5 in FrameConditions/Validity.lean), plus 8 semantic-consequence variants. SMOKING GUN IN ONE FILE: Metalogic/SetConsequence.lean carries SetDerivable (fc : FrameClass) at :72 with ONE monotonicity lemma at :118, and directly beneath it SetSemanticConsequence{Base,Dense,Discrete,DedekindDense} at :79,:87,:97,:106 with FOUR copied monotonicity lemmas at :124,:130,:136,:144. Those four definitions are BYTE-IDENTICAL except for the typeclass binder line; their own docstrings cross-reference the Valid* whose binder list they copy. THE MISSING INGREDIENT ALREADY EXISTS: FrameConditions/FrameClass.lean defines marker typeclasses LinearTemporalFrame(:88), SerialFrame(:103), DenseTemporalFrame(:124), DiscreteTemporalFrame(:148), DedekindTemporalFrame(:182) -- exactly the binder-list-as-predicate-on-D that a FrameClass-indexed validity needs. That layer is orphaned (see the FrameConditions resolution task) and this task should consume it rather than invent a sixth vocabulary. DELIVERABLE: (1) a FrameClass -> carrier-constraint interpretation; (2) ValidOn (fc : FrameClass) (phi) and SetSemanticConsequence (fc) defined once; (3) ONE monotonicity lemma replacing valid_implies_valid_dense/_discrete/_validDedekind/_validDedekindDense (Validity.lean:349,356,364,371), pointing the same direction as DerivationTree.lift; (4) the existing 15 predicates retained as abbreviations or retired, with every call site migrated. HAZARD THIS CLOSES: the ValidDedekind docstring (Validity.lean:301) warns that retargeting soundness_dedekind to it yields a REFUTABLE theorem -- a trap that exists only because binder lists are inlined rather than derived from the frame class. ACCEPTANCE: sorry-free, lake build green, check-module-invariants.sh passes, axiom profiles unchanged on the flagship theorems. GROUNDING: specs/reviews/review-2026-08-31-metalogic-systematicity.md issue H1.=== DIRECTION AMENDED (supersedes the plan at plans/01_frameclass-indexed-validity.md) ===
The existing plan is SUPERSEDED and must be revised before implementation. Its Phase 1 defines
  FrameClass.Sat (fc : FrameClass) (D : Type) [insts] : Prop
  ValidIn (fc) (phi) := forall (D : Type) [insts], fc.Sat D -> ValidOver D phi
i.e. `Sat` is a predicate on the CARRIER TYPE and `ValidIn` is duration-quantified. That is
duration validity, and it is explicitly NOT what this project wants. Landing it would harden the
wrong notion into the tree's single validity definition.

REQUIRED SHAPE INSTEAD -- frame validity, on bundled frames:
  FrameClass.Sat : FrameClass -> TaskFrame -> Prop     (a predicate on FRAMES)
  ValidIn (fc : FrameClass) (phi : Formula) : Prop := forall F : TaskFrame, fc.Sat F -> F |= phi
This mirrors `Derivable fc` on the proof side exactly, which is the symmetry this task exists to
restore.

DEPENDS ON the TaskFrame duration-bundling refactor: `Sat` cannot be a predicate on frames until a
frame carries its own duration. Sequence behind it.

WHAT SURVIVES from the research report (reports/01_frameclass-indexed-validity.md): the verified
correction that the FrameConditions marker typeclasses are NOT reusable (DiscreteTemporalFrame
omits IsPredArchimedean, which would silently widen the discrete class under soundness_discrete);
that Sat must be Prop-valued with an existential Discrete case because SuccOrder/PredOrder are
data-carrying; the finding that FrameConditions/Validity.lean is nearly all dead code; the
ValidInt/ValidOverInt definitional duplicate. All of that holds under the frame-level shape.
The report's further recommendation to rename ValidDedekind to ValidComplete is REJECTED — see
the naming decision below.

WHAT CHANGES: the 92-site binder-list migration is substantially DISSOLVED rather than performed --
bundling removes the inlined `[DenselyOrdered D]`-style binder lists at the root, which is the
disease this task was treating symptomatically. Re-scope the migration against the post-refactor
tree rather than against the counts in the current report.

=== PAPER GROUNDING AND NAMING === ValidIn fc is the paper's class-restricted consequence ⊨_C
(cor:tm-completeness: "restricts def:logical-consequence to models over task frames in a class
C"); TaskFrame.ValidOn is def:frame-validity and stays the single frame-level primitive.
Sat interpretation of record: .Base ↦ True; .Dense ↦ DenselyOrdered F.Duration; .Discrete ↦
∃ least positive duration WITH the successor-Archimedean refinement kept as a SEPARATE
named predicate (the paper's def:TMplus-f narrows TM+_f's target to Z-time via Hölder — do not
silently conflate the Discrete property with the Z-time class); KEEP the name FrameClass.Dedekind — do NOT rename it to .Complete, and
do NOT rename ValidDedekind. The paper's def:frame-properties calls this class Complete, but
"complete" is already load-bearing in this tree for PROOF-THEORETIC completeness (the
completeness-theorem family), so FrameClass.Complete would collide with the tree's most
prominent existing use of the word; "Dedekind complete" is the standard and unambiguous name
for the least-upper-bound property this class actually denotes. This is a DELIBERATE,
RECORDED deviation from paper naming — the ONLY naming deviation sanctioned on this front —
and it must be documented at the definition site, citing def:frame-properties as the
definition of record and naming the divergence explicitly. Sat .Dedekind ↦ DenselyOrdered ∧
conditionally-complete (the paper's TM+_c target is the DENSE-AND-COMPLETE class,
cor:tm-completeness; the bare Complete property of def:frame-properties admits Z as well —
record both, one predicate each, no bridged duplicates). See specs/514_align_definitions_with_source_paper/reports/01 §1.1, §3.3.

---

### 506. Fix typst display defects via playwright visual loop
- **Status**: [NOT STARTED]
- **Task Type**: typst
- **Topic**: publication-quality
- **Dependencies**: None

**Description**: Fix all outstanding display/layout defects in the compiled typst documents (typst/FormalFoundations.typ and typst/BimodalReference.typ) using a Playwright-driven visual check loop. Known defect: in <sec:representation> Definition 5.1 (TM+-algebra), the display equation listing the derived operators (F a := 1 ▷ a, G a := ¬F(¬a), P a := 1 ◁ a, H a := ¬P(¬a), Next a := 0 ▷ a, △a := H a ∧ a ∧ G a) is set as one unbreakable math line and overflows both the definition box and the page margins; it must be broken across lines (e.g. an aligned block or a two-row layout) so it fits within the text block. Approach: compile each document to PDF (and/or SVG/PNG pages via `typst compile --format png`), serve the output to a headless browser via the Playwright MCP tools, screenshot every page, and systematically inspect for overflowing display math, content escaping theorem/definition boxes, text running past margins, clipped tables, orphaned headings, broken cross-references or citation placeholders, and any other visual defect. Catalogue every finding with page number and source line, then plan and implement fixes in the .typ sources (line-breaking long equations, resizing tables, adjusting box widths, etc.), recompiling and re-screenshotting after each fix and repeating the full sweep until no display issues remain. Both documents must compile cleanly and scripts/typst-sync-check.sh must pass at the end. Do not change mathematical content — layout only

---

### 504. Retry acquisition of missing representation sources
- **Status**: [NOT STARTED]
- **Task Type**: general
- **Topic**: literature
- **Dependencies**: None

**Description**: Retry acquisition of the standard modal-representation sources that the representation-section literature research could not obtain because Semantic Scholar (literature-discover.sh Tier 3) was rate-limited (HTTP 429) for the whole session: Sambin & Vaccaro 1988 "Topology and duality in modal logic"; S. K. Thomason 1972 "Semantic analysis of tense logics" and 1975 "Categories of frames for modal logic"; Goldblatt 1976 "Metamathematics of modal logic" I-II; Fine 1975 "Some connections between elementary and modal logic"; Gehrke & Jonsson 2004 "Bounded distributive lattice expansions" (mscand.dk URLs 404; proxy gehrke_vosmaer_2011 already ingested); Gabbay & Shehtman "Products of modal logics I"; Marx & Venema 1997 "Multi-dimensional modal logic" (Zotero metadata only, no PDF). Use /literature "<title>" or literature-discover.sh once Tier 3 recovers (or after the S2_API_KEY / multi-provider fallback lands in the literature extension), ingest what is open-access or in Zotero, record paywalled items honestly as not acquired, and register every acquired doc in specs/literature-index.json with reason and citation_rule fields following the existing entries. Evidence and the full standard-sources checklist are in specs/503_revise_representation_section_with_literature/reports/01_representation-literature-research.md sections 2.2-2.3

---

### 502. Ground algebraic representation in goldblatt and brv
- **Effort**: 12-20 hours
- **Status**: [NOT STARTED]
- **Task Type**: formal
- **Topic**: algebraic-representation
- **Dependencies**: Task 461

**Description**: RESEARCH TASK. Ground the algebraic representation front in the literature BEFORE the STSA axiom set is fixed and before Uf(A) is constructed. Gates the STSA port; the complex-algebra and ultrafilter-frame tasks inherit the gate transitively.

WHY THIS RUNS EARLY. Goldblatt 1989 is largely about which varieties of Boolean algebras with operators are complex algebras, and about canonicity. Those are design questions for the STSA axiomatization and for the Uf(A) construction, not questions the eta-embedding capstone can act on. On the pre-existing graph this paper was ingested in wave 1 and not opened until wave 4, by which point three tasks would have committed to designs it should have informed.

PRIMARY SOURCE, WITH A HARD READING CONSTRAINT. Goldblatt, R. "Varieties of complex algebras", Annals of Pure and Applied Logic 44 (1989) 173-242, doi 10.1016/0168-0072(89)90032-8. The acquired PDF is an Acrobat 3.0 Capture scan (70 pages) whose OCR text layer is UNRELIABLE ON MATHEMATICS: symbols mangle, lines drop and reorder, and even the title page renders New Zealand as "New 2Miand". READ THE PAGE IMAGES via the Read tool's pages parameter. Do NOT grep the text layer for definitions or theorem statements, and do NOT accept a pdftotext- or /literature --convert-derived markdown as a faithful source for any axiom or equation. The text layer is usable only as a rough locator.

PAGINATION. Journal page 173 is PDF page 1, so PDF page = journal page - 172. The paper's own table of contents is partly OCR-garbled in its page-number column; verify each section start against the actual page image rather than trusting the offsets below.

SECTIONS IN SCOPE (do not read the whole paper):
- 2.2 The dual space of a lattice (journal ~185) and 2.3 Bounded morphisms (~192) -- the duality machinery the eta embedding rests on.
- 3.1 Canonical structures (~198) -- the canonical extension / Uf(A) construction. Bears directly on the ultrafilter-frame task.
- 3.5 Canonical varieties (~208) -- IS THE STSA VARIETY CANONICAL? This is the single most load-bearing question for the STSA port, which must restate three Boneyard sorries against the current 45-constructor axiom set and should not do so blind.
- 3.6 The elementary case (~210) and 3.8 First-order definability -- bears on whether the Spherical frame condition is first-order definable and preserved, which is the ultrafilter-frame task's dominant and explicitly unattempted obligation, and one the paper's finite-W discharge pattern does not cover.
- 4.2 Preservation by bounded morphisms and inner substructures (~229) -- whether the TaskFrame axioms transfer along the constructions.
EXPLICITLY OUT OF SCOPE: 2.4 Heyting algebras (intuitionistic, not this signature).

CROSS-FRONT NOTE, RECORD BUT DO NOT PURSUE HERE: section 4.3 covers preservation by DISJOINT UNIONS, which may bear on the two-fibre structure named in Metalogic/Conservativity.lean as the CEB countermodel shape. That belongs to the TM-completeness research task on the metalogic front; if 4.3 looks relevant, record a pointer for that task rather than expanding this one.

SECONDARY SOURCE: Blackburn/de Rijke/Venema 2002 Chapter 5 (corpus entry blackburn_2002, born-digital, full text) is the standard Jonsson-Tarski reference and should be read alongside. CAVEAT: the corpus warns this entry is 365,868 tokens and exceeds a single context budget -- create a chapter-scoped sub-entry before an agent consumes it.

DELIVERABLE: a grounding report answering, with citations to specific pages read as images: (1) does the STSA axiom set as seeded in Boneyard/UltrafilterFrame/TenseS5Algebra.lean match the standard BAO presentation, and where does it diverge; (2) is the variety canonical, and what does that buy or cost the representation; (3) what the literature says about discharging a Spherical-style frame condition on an ultrafilter frame; (4) a concrete recommendation on how the three removed-axiom sorries (temp_a, temp_l) should be restated against the current axiom set. A finding that the literature does NOT settle one of these is a complete and valid answer for that item -- record it as unsettled rather than manufacturing a verdict.

---

### 501. Extend stsa with until since operators
- **Effort**: 20-32 hours
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: algebraic-representation
- **Dependencies**: Task 125

**Description**: Phase 4 of the Jonsson-Tarski representation: extend STSA with the binary Until and Since operators. The STSA class as seeded in Boneyard/UltrafilterFrame/TenseS5Algebra.lean carries only the unary box, G, H and sigma. The live object language's primitives are untl and snce (Formula, Syntax/Formula.lean), with allFuture and allPast DERIVED from them (:167, :177) -- so an STSA over the unary fragment alone does not represent the actual logic, and the representation theorem is incomplete without this. SCOPE: add binary operators to the STSA signature with their algebraic laws, extend the complex algebra Cm(F) to interpret them from the frame relations, extend the ultrafilter frame Uf(A) correspondingly, and re-prove the eta embedding at the extended signature. SEQUENCING: this deliberately follows the unary capstone rather than being folded into it -- the unary representation is a standalone result worth landing first, and folding the binary case in would make a single task that cannot complete in one dispatch. LITERATURE: Blackburn/de Rijke/Venema 2002 Chapter 5 (in the corpus as blackburn_2002, full text) is the standard reference for Jonsson-Tarski and its extensions to n-ary operators. Note the corpus warns blackburn_2002 exceeds a single context budget at 365,868 tokens -- a chapter-scoped sub-entry should be created before an agent consumes it.

---

### 500. Reconcile shiftset representation with stsa route
- **Effort**: 10-16 hours
- **Status**: [NOT STARTED]
- **Task Type**: formal
- **Topic**: algebraic-representation
- **Dependencies**: Task 492, Task 497

**Description**: RESEARCH TASK. Prevent two parallel representation theorems from being developed and having to be reconciled after the fact. THE OBSERVATION: FormalSystem/Semantics/ShiftSet.lean -- landed by task 424 for the COMPACTNESS route -- is already a representation theorem. forward_repr (:263) and reverse_repr (:362) represent task models as shift sets, both directions, sorry-free. Separately, the STSA design report (specs/archive/992_shift_closed_tense_s5_algebra/reports/01_stsa-algebraic-analysis.md) identifies its key structural claim as: box a <= box(G a) meet G(box a) says the box-fixed points form a G-invariant subalgebra, which is the algebraic encoding of OMEGA BEING SHIFT-CLOSED. That is the same shift structure ShiftSet.lean makes explicit. These look like two views of one representation. SCOPE: determine whether they are, and if so, specify the shared infrastructure so the algebraic route consumes ShiftSet rather than duplicating it. Concretely: (a) is Cm(F) expressible as an algebra of shift-invariant subsets of a ShiftSet carrier? (b) does ShiftSet's sep hypothesis correspond to an STSA axiom, and if so which? (c) can the eta embedding be factored through reverse_repr? DELIVERABLE: a report with a verdict and, if affirmative, a concrete refactor specification. A NEGATIVE VERDICT IS A COMPLETE OUTCOME -- if the two representations are genuinely different objects, say so with evidence and record it so the question is not reopened. TIMING: run this after the Los-lemma work and the STSA port have both landed, so both sides are concrete rather than projected.

---

### 499. Build ultrafilter frame and prove task frame axioms
- **Effort**: 24-40 hours
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: algebraic-representation
- **Dependencies**: Task 497

**Description**: HARD. Phase 2 of the Jonsson-Tarski representation: the ultrafilter frame Uf(A), and the proof that it is a TaskFrame. THE SEED: Boneyard/UltrafilterFrame/UltrafilterFrame.lean (1189 lines, behind #exit, 4 sorry hits) already has R_G (:82), R_Box (:90), R_H (:98) and a substantial body of proved structure -- R_Box_refl (:111), R_Box_euclidean (:127), R_Box_symm (:154), R_Box_trans (:164), R_G_R_H_converse (:179), the preimage and upward-closure lemmas (:229-251), R_G_trans (:281), R_H_trans (:304), and the F/P resolution lemmas (:515, :750). Port and revive rather than rebuild. THE GENUINELY NEW OBLIGATION, flagged in task 125's own FOUR-AXIOM EXPOSURE NOTE (2026-08-10): proving SPHERICAL for an ultrafilter frame is nontrivial and unattempted, and the paper's finite-W discharge pattern EXPLICITLY DOES NOT APPLY. Budget this as the dominant cost of the task; Compositionality, Seriality and Limit are expected to be far cheaper. MATHLIB HOOKS: Order/PrimeSeparator.lean:44 (DistribLattice.prime_ideal_of_disjoint_filter_ideal -- the Boolean prime ideal theorem in distributive-lattice form) is what a Zorn-free Uf(A)-nonemptiness argument should use; Order/Ideal.lean and Order/PrimeIdeal.lean (:156, :171) give the ultrafilter-as-prime-filter characterization. NOTE: Mathlib has NO Ultrafilter on an abstract Boolean algebra -- its Ultrafilter is Filter-on-Set-based. UltrafilterMCS.lean:44 rolls its own structure for exactly this reason, and its MCS-to-ultrafilter bijection (ultrafilter_correspondence :782) is available, though stated existentially rather than as a named Equiv. SHADOWING HAZARD: if Mathlib's Ultrafilter is opened in that namespace it collides with the bespoke one; keep them explicitly qualified.

---

### 498. Build complex algebra for task frames
- **Effort**: 16-24 hours
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: algebraic-representation
- **Dependencies**: Task 497

**Description**: Phase 1 of the Jonsson-Tarski representation: the complex algebra Cm(F). Construct the powerset STSA over a TaskFrame -- carrier the powerset of the world-history space, with box, G, H and sigma defined from the frame relations -- and prove it satisfies every STSA axiom. GREENFIELD WARNING: Mathlib has NO Boolean algebras with operators, no complex algebras, no canonical extensions, and no modal-algebra machinery of any kind; a survey of the pinned v4.33.0-rc1 tree found nothing reusable for this. What Mathlib DOES supply and should be used: Order/BooleanAlgebra/ (already consumed by BooleanStructure.lean:421) and Order/CompleteBooleanAlgebra.lean:711 (CompleteAtomicBooleanAlgebra). CONSTRAINT FROM THE FOUR-AXIOM WORK (task 420, completed): TaskFrame (Semantics/TaskFrame.lean:474-577) now carries SEVEN fields, not five -- biconditional Compositionality, Seriality, Limit and Spherical plus a Nonempty WorldState field and [Nontrivial D]. The complex algebra must be built against the live seven-field structure, not the five-field shape the older design documents assume. ACCEPTANCE: Cm(F) defined, instance STSA (Cm F) proved, sorry-free, lake build green.

---

### 497. Port stsa class and add g operator
- **Effort**: 16-24 hours
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: algebraic-representation
- **Dependencies**: Task 496, Task 502

**Description**: Bring the Shift-closed Tense S5 Algebra class into live code and close the G-operator gap. Phase 1 groundwork for the Jonsson-Tarski representation. THE SEED: Boneyard/UltrafilterFrame/TenseS5Algebra.lean (361 lines, behind #exit) already contains the full class STSA extending BooleanAlgebra with fields box, G, H, sigma and axioms box_deflationary, box_monotone, box_idempotent, box_s5, G_monotone, H_monotone, sigma_involution, sigma_neg, sigma_sup, sigma_G, sigma_H, sigma_box, MF, TF, TA, TL. This is the exact algebraic signature the representation needs. IT CARRIES 3 SORRIES, AND THEY MUST NOT BE PROVED AS-IS: they are for temp_a and temp_l, axioms that have since been REMOVED or restructured; restate them against the current 45-constructor ProofSystem.Axiom set (Axioms.lean:115-464) rather than reviving the old shapes. THE G GAP: LindenbaumQuotient.lean supplies boxQuot (:305-ish), hQuot, and sigmaQuot (:346) with its four laws (sigma_quot_involution :353, sigma_quot_neg :362, sigma_quot_sup :373, sigma_quot_box :385) -- but there is NO gQuot. G on the Lindenbaum quotient must be constructed and its congruence proved before LindenbaumAlg can be an STSA instance. Boneyard/SorriedDeclExcisions/AlgebraicGQuotChain.lean is the excised prior attempt and should be consulted, not trusted. DESIGN REFERENCE: specs/archive/992_shift_closed_tense_s5_algebra/reports/01_stsa-algebraic-analysis.md (538 lines) gives the full axiom-to-equation translation table and the key structural claim that box a <= box(G a) meet G(box a) says the box-fixed points form a G-invariant subalgebra -- the algebraic encoding of Omega being shift-closed. It is stale on file names (references deleted AlgebraicRepresentation.lean and ParametricRepresentation.lean) but sound on the mathematics. ACCEPTANCE: STSA class live and sorry-free, gQuot constructed with congruence, instance STSA LindenbaumAlg, lake build green.

---

### 495. Determine tm completeness status over task frames
- **Effort**: 12-20 hours
- **Status**: [RESEARCHED]
- **Task Type**: formal
- **Topic**: metalogic
- **Dependencies**: Task 489
- **Research**: [495_determine_tm_completeness_status_over_task_frames/reports/01_tm-completeness-status.md]

**Description**: RESEARCH TASK, DELIBERATELY AGNOSTIC ABOUT THE VERDICT. Determine whether TM (the BaseLanguage proof system) is complete over task frames, and if not, characterize what it IS complete for. DO NOT ASSUME COMPLETENESS HOLDS; the evidence points the other way, and a machine-checked incompleteness result is a complete and valid outcome. EVIDENCE THAT IT MAY FAIL: (1) the paper's cor:tm-completeness (possible_worlds.tex:4657) carries completeness for the BL+ systems ONLY -- TM+, TM+_d, TM+_f, TM+_c -- and never claims it for TM. (2) Metalogic/Conservativity.lean's scope section states that the forward direction TM+ |- tr phi => TM |- phi is REFUTED at FrameClass.Base (the (Sp) witness) and at FrameClass.Discrete (the Z1 witness), with the TM+ half of the Discrete witness already machine-checked in-tree as z1_translate. THE SUBTLETY ANY DISPATCH MUST CONFRONT FIRST: since |-[Base] tr (Sp) is proved and TM+ is sound over all task frames, (Sp) is VALID ON EVERY TASK FRAME. So a refutation of TM |- Sp by soundness CANNOT use a task frame. It needs a structure outside the class on which TM remains sound precisely because it lacks the Until/Since expressive power to detect the violation. Identifying that broader class is the actual research content. SCOPE: (a) settle whether TM is complete over task frames; (b) if not, identify the class TM is sound and complete for; (c) determine whether the CEB and CEF refutations that Conservativity.lean currently only DOCUMENTS can now be machine-checked, given the BL-side semantics and soundness theorem delivered by the prerequisite task. Conservativity.lean's own 'What a machine-checked refutation would need' section names three missing pieces: a BL-side semantics, a BL-side soundness theorem, and the two countermodels (a two-fibre structure for CEB, Z x_lex Z for CEF); the prerequisite supplies the first two. HARD CONSTRAINT INHERITED FROM Conservativity.lean: do not state a forward-conservativity theorem and discharge it with sorry -- it is provably false at two frame classes, so that would be an unsound placeholder, not deferred debt.

---

### 494. Define and refute dedekind compactness
- **Effort**: 10-16 hours
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: strong_completeness
- **Dependencies**: Task 490, Task 493, Task 509

**Description**: NOW SEQUENCED BEHIND THE COMPACTNESS PARAMETERIZATION (see the REVISED note at the end); still INDEPENDENT of the ultraproduct chain. Settle the fourth frame class negatively and complete the compactness picture. CURRENT STATE: there is NO CompactDedekind definition anywhere in the tree, no StrongCompletenessDedekind, no SatisfiableDedekindSet, and no refutation -- the Dedekind row of StrongCompleteness.lean's status ledger (:84-89) rests on the scope of Reynolds 1992 section 9 Theorem 7 alone. Meanwhile the paper (cor:tm-completeness, possible_worlds.tex:4657) asserts that strong completeness 'provably fails for Z-time as well as for the dense-and-complete class R where compactness fails' -- so this is a REFUTATION target, not a proof target. DELIVERABLE PART 1: define the missing vocabulary in SetConsequence.lean mirroring the Base/Dense/Discrete groups -- SetSemanticConsequenceDedekindDense already exists (:103); add StrongCompletenessDedekind, CompactDedekind, SatisfiableDedekindSet, ModelExistenceDedekind. PART 2: refute CompactDedekind and StrongCompletenessDedekind. CRITICAL CONSTRAINT: the Discrete witness does NOT port. archWitness (DiscreteNonCompactness.lean:102) and its unsatisfiability half (:229-242) turn entirely on Order.succ_le_of_lt and exists_succ_iterate, i.e. on [SuccOrder D] + [IsSuccArchimedean D]; the Dedekind binder list is DenselyOrdered plus LUB with no successor at all, and over R the operator Formula.next = untl bot phi is vacuous, so archWitness carries no contradiction. A NEW witness is required. Model DiscreteNonCompactness.lean's structure (finitely-satisfiable half, then unsatisfiable half) but not its witness. ACCEPTANCE: both refutations sorry-free and axiom-audited; the four-class compactness picture complete (Base/Dense open pending the ultraproduct chain, Discrete refuted, Dedekind refuted). === REVISED 2026-08-31 (review: metalogic systematicity) === PART 1 IS RESCOPED. Do NOT define StrongCompletenessDedekind/CompactDedekind/SatisfiableDedekindSet/ModelExistenceDedekind by mirroring the Base/Dense/Discrete groups -- that fourth hand copy is exactly what the compactness-parameterization prerequisite collapses. After that task lands, Part 1 is a SINGLE INSTANTIATION of the FrameClass-indexed family at FrameClass.Dedekind. PART 2 IS UNCHANGED and remains the real content: a new non-compactness witness, since archWitness does not port (it turns on SuccOrder/IsSuccArchimedean and the Dedekind binder list has no successor structure; over the reals Formula.next = untl bot phi is vacuous). Grounding: specs/reviews/review-2026-08-31-metalogic-systematicity.md issue H3.

---

### 493. Discharge compactbase compactdense and strong completeness
- **Effort**: 10-16 hours
- **Status**: [RESEARCHED]
- **Task Type**: lean4
- **Topic**: strong_completeness
- **Dependencies**: Task 490, Task 492
- **Research**: [493_discharge_compactbase_compactdense_and_strong_completeness/reports/01_compactness-and-strong-completeness.md]

**Description**: Assemble the compactness result and collect strong completeness for Base and Dense. Steps S4 and S5 of task 424's authorized route. S4: from the Los lemma, prove ModelExistenceBase and ModelExistenceDense (every finitely-satisfiable Gamma is satisfiable), then compose with the ModelExistence -> Compact bridge to obtain CompactBase and CompactDense. S5: feed those into strongCompletenessBase_of_compact (StrongCompleteness.lean:305) and strongCompletenessDense_of_compact (:331), which are already proved as reductions, and DISCHARGE their engine hypotheses -- deliberately left live so that compactness was isolated as the whole remaining obligation. The engines are BXCanonical.completeness (BXCanonical/Completeness.lean:196) for Base and BXCanonical.completeness_dense (:256) for Dense, both sorry-free and both of exactly the required type. WHY THIS MATTERS BEYOND THE TREE: the paper's cor:tm-completeness rows 1 and 2 assert strong completeness for TM+ and TM+_d and attribute them to this repository, where they are currently CONDITIONAL on unproved hypotheses. This task is what makes the paper's own headline claim true; task 488's author memo records the mismatch as a live paper-side correction until then. ACCEPTANCE: StrongCompletenessBase and StrongCompletenessDense proved unconditionally, sorry-free, axiom-audited; the author-memo item retired.

---

### 492. Build shiftset ultraproduct and los lemma
- **Effort**: 20-30 hours
- **Status**: [COMPLETED]
- **Task Type**: lean4
- **Topic**: strong_completeness
- **Dependencies**: Task 491
- **Research**: [492_build_shiftset_ultraproduct_and_los_lemma/reports/01_shiftset-ultraproduct-and-los.md]
- **Plan**: [492_build_shiftset_ultraproduct_and_los_lemma/plans/01_shiftset-ultraproduct-los.md]
- **Source**: [FormalSystem/Semantics/Ultraproduct/Los.lean]
- **Summary**: [492_build_shiftset_ultraproduct_and_los_lemma/summaries/01_shiftset-ultraproduct-los-summary.md]

**Description**: HARD. Build the ultraproduct of shift sets and prove Los for TruthAt. This is steps S2 and S3 of the route task 424 authorized. S2: construct the ultraproduct over an ultrafilter on the index type {L : List Formula // forall psi in L, psi in Gamma}, using the carrier route selected by the preceding research task -- do not re-litigate that choice here. S3: the Los lemma for TruthAt, by induction on Formula, six cases (atom, bot, imp, box, untl, snce). Five are mechanical. The box case is the real content and carries task 424's risk R2: it needs a choice-function argument for the forward direction, because box quantifies over all total world-histories (TruthAt, Semantics/Truth.lean:164) rather than over a pointwise-definable family. ACCEPTANCE: sorry-free, lake build green, #print axioms recorded for the Los statement (Classical.choice is expected and acceptable here; sorryAx is not). SEQUENCING NOTE: ShiftSet.lean's forward_repr/reverse_repr is the representation this builds on, and it is also the representation the algebraic route should reuse -- see the reconciliation task, which should not be allowed to fork a second, parallel representation. CARRIER ROUTE (SETTLED -- do not re-litigate): route (a), a bespoke quotient of the Pi group (forall i, D i) by its eventually-zero AddSubgroup, with AddCommGroup inherited free from QuotientAddGroup.Quotient.addCommGroup and only LE, LinearOrder, IsOrderedAddMonoid, Nontrivial (plus DenselyOrdered on the Dense branch) supplied by hand -- 5 instances, 6 on Dense, not the ~15 the design doc estimated. The history carrier is the parallel Quotient of (forall i, Omega i) by eventual equality, with the shift action lifted through both and sh_zero/sh_add discharged. Route (b), carrier normalization first, is a NO-GO: the only normalization machinery in the tree (DurationClassification.lean intIso, IntTransfer.lean TaskFrame.map) is Discrete-only, and DiscreteNonCompactness.lean discrete_consequence_not_compact refutes compactness exactly at Discrete. Do NOT import Mathlib.Order.Filter.Germ or FilterProduct: Filter.Product carries only coeTC and Inhabited, and Mathlib.Order.Filter.Ultrafilter.Basic (already built) supplies everything the route needs. EVIDENCE, COMPILED AND UNDER A BUILD TARGET: Tests/BimodalTest/Semantics/DependentUltraproductProbe.lean, imported from Tests/BimodalTest.lean, carries the whole carrier construction sorry-free with axiom profile [propext, Classical.choice, Quot.sound]; its shiftSetOnUD is the live check that ShiftSet (UD phi D) elaborates and that the quotient lands in Type. FULL REASONING: specs/491_select_dependent_ultraproduct_carrier_route/reports/01_dependent-ultraproduct-carrier-route.md (section 9 is the decision record, section 5 lists what S2 still owes). The probe deliberately does NOT supply: the ultrafilter on the index type, ShiftSet.sep, carrier_nonempty, or the valuation A -- shiftSetOnUD takes the last three as hypotheses. Those are this task's work.

---

### 482. Discharge proof extraction completeness
- **Effort**: large
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: decidability
- **Dependencies**: Task 412

**Description**: CLASSIFICATION: OPEN MATHEMATICS, multi-month. This MUST NOT be re-described as engineering, and must not be scheduled or budgeted as a routine task.

TARGET: eliminate `.extractionFailed` as a live outcome of `decide` on a genuinely closed tableau. Currently `verifyProof` is `fun _ _ => true` (`FormalSystem/Metalogic/Decidability/ProofExtraction.lean:345`, honestly commented, misleadingly named) and no theorem establishes that a closed tableau ALWAYS yields an extractable Hilbert-system derivation. `ProofExtraction.lean` has zero theorems today (re-confirmed at task 468 realignment time, 2026-08-25).

WHAT THIS REQUIRES: the missing refutation induction (`allClosed → Derivable`, the content that would live under `FormalSystem/Metalogic/Decidability/Verified/Refutation/` -- this directory does not exist today, zero files, re-confirmed 2026-08-25) is a PREREQUISITE owned by task 412, which already targets exactly this induction (`allClosed_derivable`). This task is sequenced AFTER 412 rather than folded into 412's acceptance criteria as an additional corollary, precisely so the research problem is not hidden behind 412's engineering-shaped description -- see the planner's decision recorded in task 468's implementation plan (`specs/468_realign_task_programme_from_proof_state_audit/plans/01_programme-realignment-execution.md`, "Planner decisions taken here" item 1). Task 412's own description carries a one-line REVISE naming this task as the owner of `.extractionFailed` elimination.

DEPENDENCIES: `[412]`.

FILE SCOPE: `FormalSystem/Metalogic/Decidability/ProofExtraction.lean`,
`FormalSystem/Metalogic/Decidability/Verified/Refutation/` (does not yet exist -- this task or a predecessor may need to create it).

DO NOT schedule this as an independent parallel effort that would redundantly re-derive the refutation induction 412 already targets -- consume 412's `allClosed_derivable` once it lands.

ACCEPTANCE: `.extractionFailed` is unreachable on a genuinely closed tableau (stated and proved as a corollary of `allClosed_derivable` or equivalent); `lake build` green; no regression to any currently-passing check-module-invariants.sh check; `verifyProof` either proved correct against the new theorem or replaced by an implementation whose correctness the new theorem certifies.

PROVENANCE: specced by task 468's realignment (report `specs/468_realign_task_programme_from_proof_state_audit/reports/02_stage1-verification-and-programme-realignment.md` §5, new-task-spec-2), itself descended from `specs/reviews/review-2026-08-24.md` amendment 10b's surviving ADD-list item, per R4.

---

### 481. Discharge or replace unorderedsuccessorlabelclosed residual
- **Effort**: large
- **Status**: [BLOCKED]
- **Task Type**: lean4
- **Topic**: decidability
- **Dependencies**: Task 434, Task 483
- **Research**:
  - [481_discharge_or_replace_unorderedsuccessorlabelclosed_residual/reports/01_unorderedsuccessorlabelclosed-verdict.md]
  - [481_discharge_or_replace_unorderedsuccessorlabelclosed_residual/reports/02_spawn-analysis.md]
- **Plan**: [481_discharge_or_replace_unorderedsuccessorlabelclosed_residual/plans/01_sharpen-replace-labelclosed-residual.md]
- **Summary**: [481_discharge_or_replace_unorderedsuccessorlabelclosed_residual/summaries/01_sharpen-replace-labelclosed-residual-summary.md]

**Description**: CLASSIFICATION: genuinely open -- the predicate is refuted as stated, so this is a repair-or-replace problem, not routine discharge. This is the FIFTH termination residual; the four-residual framing used elsewhere in this programme (`UniverseClosed`, `DifficultyBounded`/`StepLengthBounded`, `MintPaysForTime`, `PostBlockingSettles`) is WRONG and must be corrected wherever it recurs.

TARGET: `UnorderedSuccessorLabelClosed` (`FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean:6199`) is carried as a live hypothesis by `buildTableauAt_isSome_at_seed_lengthBudget_signedUniverse` (`:6215`) and has an in-tree refutation at `:6238` (`¬ UnorderedSuccessorLabelClosed fc freshWorldLabels`) -- the same shape of problem `DifficultyBounded` presented before `StepLengthBounded` replaced it.

WHAT TO DO -- determine which of three outcomes applies:
(a) the predicate can be discharged at the frame classes/settings the surviving terminus theorems actually need (distinct from the setting `:6238` refutes it in -- check precisely which); or
(b) it needs a `StepLengthBounded`-style weaker replacement, analogous to the `DifficultyBounded` -> `StepLengthBounded` repair pattern already in this file; or
(c) it is unclosable as stated and needs a C9 register entry (the file already has 24 such entries; this would be the 25th) plus an explicit statement of which theorem still carries it and at which frame classes.

A C9 REGISTER ENTRY IS A VALID, COMPLETE DELIVERABLE for this task -- do not treat "prove it" as the only acceptable outcome.

SEQUENCING NOTE (direct from `specs/reviews/review-2026-08-24.md` amendment 10e, re-affirmed by task 468's realignment): task 462 targets `MintPaysForTimeFixed` discharge at a NONEMPTY UNIVERSE, which is the same setting `:6238`'s refutation applies in. If this task and 462 are not sequenced, 462 risks either duplicating the discovery of the refutation or, worse, building on an implicit assumption that this residual is harmless. This task should run BEFORE OR ALONGSIDE 462.

DEPENDENCIES: `[434]` (established the residual set this belongs to). Do NOT fold into 465 (the mechanical restatement-family task) -- 465 is explicitly scoped as "a one-line application of its family root" for SETTLED residuals; this residual is not settled, so folding it in would either force 465 to do research work outside its charter or produce a restatement of an unsettled predicate, which is exactly the kind of premature-closure risk this whole realignment exists to prevent.

VERIFIED at task-468 realignment time (2026-08-25): none of tasks 462, 463, 464, 465 mentions the symbol `UnorderedSuccessorLabelClosed` in its live description.

ACCEPTANCE: one of outcomes (a)/(b)/(c) above is reached and recorded; `lake build` green; no regression to any currently-passing check-module-invariants.sh check.

PROVENANCE: specced by task 468's realignment (report `specs/468_realign_task_programme_from_proof_state_audit/reports/02_stage1-verification-and-programme-realignment.md` §5, new-task-spec-3), itself descended from `specs/reviews/review-2026-08-24.md` amendment 10e.

---

### 476. Box faithful small model theorem
- **Effort**: large
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: decidability
- **Dependencies**: Task 475

**Description**: THE BOX-FAITHFUL SMALL-MODEL THEOREM.

CLASSIFICATION: OPEN MATHEMATICS. MULTI-MONTH. This is a genuine research problem in the same
category as the audit's R4 "semantic FMP" entry. IT MAY NOT BE RE-DESCRIBED AS ENGINEERING, AND IT
MAY NOT BE MERGED INTO THE BILASSO WIRING TASK OR THE CARRIER-NORMALIZATION TASK. Merging is
precisely how a research problem gets hidden behind an engineering description, and this task
exists partly to prevent that.

DO NOT BEGIN before the BiLasso wiring task and the carrier-normalization task (task 475) are
landed. Those two have standalone value; this one does not, and its cost is dominated by a problem
a two-day literature check might refute outright.

=== LITERATURE GATE -- RUN FIRST, AND IT IS EMPOWERED TO STOP THE TASK ===

Acquire Gabbay, Kurucz, Wolter, Zakharyaschev, *Many-Dimensional Modal Logics* (2003) and read its
temporal-products chapter. IF the two-dimensional `Until`/`Since` case is recorded there as
undecidable or as lacking the finite model property, THIS TASK IS REFUTED and must be REPORTED AS
SUCH rather than attempted. A negative result here is as valuable as a positive one and would
redirect the whole decidability front.

What is already firm from a prior search: products of THREE OR MORE modal logics are undecidable,
with no logic between K x K x K and S5 x S5 x S5 decidable, and S5 x S5 x S5 lacks the finite model
property. What is NOT settled: the two-dimensional case with `Until`/`Since`, which is what this
logic is closest to. Note that TM is in any case NOT a full product -- its second dimension is the
path space of a graph, not an arbitrary set of runs -- so a product-logic result would be evidence,
not a decision.

=== THE TARGET ===

Build `cands : Formula -> List IntPresentation` and prove

    not (ValidDiscrete phi) -> exists P in cands phi, exists w, SatAtState P w phi.neg

This is the SINGLE remaining obligation for decidability of `ValidDiscrete`. Everything else is
already compiled: given this hypothesis, `check`-over-`cands` is equivalent to `ValidDiscrete phi`
and `decidable_of_iff` reads the `Decidable` instance off it. There is no bridge theorem, no
transfer lemma, no enumeration over `Atom`, and no `Fin n`-from-`Finite` extraction anywhere in the
assembly; `check_correct` is the FINAL step.

=== THE CONSTRUCTION (the tractable part) ===

Build `cands phi` from the CLOSURE-TYPE SPACE: subsets of `subformulaClosure phi` satisfying the
local Hintikka conditions, with `step` given by `LocalCoherent`'s `untl`/`snce` unfolding clauses
(`BiLasso/Annotation.lean` already states them, and they relate the label at `t` to the label at
`t` plus-or-minus one only -- i.e. they ARE an adjacency relation), and the valuation read off the
state by deciding atom membership. Every ingredient is `Finset`/`Bool` data with `DecidableEq`.
Two real obligations, neither research-grade:

  1. `fwd`/`bwd` SERIALITY OF THE TYPE GRAPH. Not free: a Hintikka type may have no locally
     coherent successor, forcing an ITERATED PRUNING to a maximal serial subgraph. Standard,
     bounded, fiddly.
  2. INDEXING. `IntPresentation` demands `Fin card` specifically, so the type `Finset` must be
     listed and indexed. Mechanical.

Estimate for this part alone: two to four weeks.

DO NOT instead try "bound `card` by some `presentationBound phi`, then enumerate the presentations
up to that bound". That does not typecheck as stated: `IntPresentation.val : Atom -> Fin card ->
Bool` is a function on the `Infinite` type `Atom`, so presentations of a given `card` are not a
finite collection. Closing that would need a valuation-restriction lemma that is not in the tree.
The formula-indexed candidate list sidesteps the problem rather than solving it.

=== THE CRUX: BOX-FAITHFULNESS (the research part) ===

The `box` clause of `TruthAt` quantifies universally over ALL total histories. Two landed facts
make this a GLOBAL modality rather than a local one:

  - `Truth.box_const` (`Semantics/Truth.lean`): box truth is independent of both the history and
    the time. Its own docstring: "a model has one finite set of box facts, computed once."
  - `Extension.occurrence` (`cor:occurrence`): every state occurs at every time in some total
    history.

That collapse is why `BoxOracleSound P bx` types `bx` as `Formula -> Bool` -- one `Bool` per
formula, per model. It is also the obstruction:

  The box facts of the SOURCE model M and of the TARGET presentation P are each global constants
  of their own model, and they need not agree. P admits every path of its graph. The subgraph of
  types realized in M still generates paths that M does not realize, and along such a path a
  `box chi` true in M can fail. When it fails, the type-map image is no longer a `LocalCoherent`
  annotation, and the transfer breaks.

Restricting `cands phi` to realized-type subgraphs does NOT by itself close this: the subshift
generated by the realized edges properly contains the realized paths. So the residue is a genuine
BOX-FAITHFUL small-model theorem -- in effect a bounded-model property for LTL(Until, Since) over
bi-infinite paths of a graph, PLUS a universal path quantifier over the whole structure.

Is it true? Almost certainly -- the shape is the classical automata-theoretic bounded-model
setting, and the analogous results (CTL*-style satisfiability, LTL with a universal modality) are
decidable with finite/bounded model properties. Is it in reach? Not routinely. Neither Mathlib nor
this tree carries omega-automata, Buchi complementation, or any language-inclusion machinery, so a
Lean proof must be hand-rolled.

=== WHAT TO REUSE ===

`BiLasso/GoodCycle.lean`'s good-cycle argument, `cycleBound`, and `exists_annot_of_truth` are
exactly the fulfilment machinery a hand-rolled proof would reuse. Be clear-eyed that they operate
INSIDE a presentation, not across the model boundary, which is the whole difficulty.

=== DO NOT PROMISE A CHOICE-FREE RESULT ===

`wlem_of_spherical` (`Tests/BimodalTest/Semantics/SphericalFiniteAxiomTest.lean`) derives weak
excluded middle from `Spherical R` at the finite carrier `Bool` over `D = ZZ`, from
`[propext, Quot.sound]` alone. So NO finite-carrier frame with an arbitrarily shaped relation can
be choice-free, on any route. The cost is already paid by `IntPresentation.toTaskFrame`. Any spec
promising choice-freedom here is promising something proved impossible. Note the separate
distinction: `instDecidableSatAtState` COMPUTES (kernel-evaluated `#guard`s prove it) while
measuring `[propext, Classical.choice, Quot.sound]`. Computability and choice-freedom are different
properties.

---

### 465. Complete terminus restatement family
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: decidability
- **Dependencies**: Task 462, Task 463, Task 464

**Description**: Complete the terminus restatement family at the repaired residuals. Task 433's Phase 6 landed EIGHT of the twenty-two restatements -- the four family roots and their four caller-facing seed forms -- and recorded the remaining FOURTEEN as a Reasoned Exclusion with the recipe written down: each is a `_lengthBudget` / `signedUniverse` substitution, "a one-line application of its family root".

This is deliberately MECHANICAL work with the recipe already recorded. Its value is uniformity: a caller reaching for a `_lengthBudget` or `signedUniverse` form of a repaired terminus should find it landed rather than having to re-derive it, and a half-populated family is a trap for a future reader who assumes an absent member is absent for a reason.

SCOPE: read Phase 6's Reasoned Exclusions section in specs/433_discharge_postblockingsettles_residual/plans/01_postblockingsettles-refute-or-prove.md for the enumerated list and the recipe. The family roots and existing members are the `buildTableauAt_isSome_*` declarations in MintBound.lean (the `_at`, `_selfGuarded`, `_fixed` and `_run` families, roughly :6308-:12240). Land the fourteen missing members following the naming convention the file already uses; do not invent a new convention.

WHY THIS RUNS LAST: it restates termini at the repaired residuals, so it must run after the residuals themselves are settled. If 462, 463 or 464 changes a predicate's shape or sheds a hypothesis, the restatements must reflect the settled form -- doing this work earlier would mean doing it twice. Before starting, RE-DERIVE the list of missing members from the file as it then stands rather than trusting the count of fourteen recorded here: earlier tasks may have landed some, or added new family roots.

PROHIBITED: no `sorry`; additive only; do not alter any previously-landed declaration; do not edit Fuel.lean, Saturation.lean or Tableau.lean; axioms within {propext, Classical.choice, Quot.sound}; full `lake build` green. If any of the fourteen turns out NOT to be a one-line application -- i.e. the recipe does not actually apply -- STOP on that member, record why, and do not force it; a member that needs real mathematics belongs in its own task, not smuggled in here.

Dependencies: 462, 463, 464 -- all three, so that the restatements are made against a settled set of residuals rather than a moving one.

---

### 464. Gappotential density measure component
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: decidability
- **Dependencies**: Task 462, Task 463

**Description**: Design and land `gapPotential`, the density coordinate of the termination measure. This is the one genuinely OPEN MATHEMATICAL question remaining on the totality terminus; it is research, not plumbing, and should be run with --lit.

THE PROBLEM, stated exactly. `densityRule` mints a fresh time while lying OUTSIDE BOTH `freshLabelRules` AND `selfGuardRules`. Consequently no disjunct of the current measure moves at a `densityRule` step, FOR ANY sigma WHATSOEVER. This has been open since C9 register entry 17 named it, and task 434's Phase 8 records the current state bluntly: `gapPotential` "remains implemented nowhere and assumed by nothing". Because `densityRule` is `denseRules`-gated, this blocks a nonempty `MintPaysForTimeFixed` discharge at `.Dense` and `.Dedekind` frame classes specifically; every frame class needs `gapPotential` for a fully general result.

SHAPE SUGGESTED BY PRIOR WORK (a starting point, NOT a specification to follow blindly): task 434 records the expectation that `gapPotential` is indexed by `U x U` and `denseRules`-gated. Validate or refute that shape as part of the research; if a different indexing is correct, say so and justify it.

HARD REQUIREMENT -- PRESERVATION ACROSS THE IDENTIFICATION ARM. Any candidate component must be preserved across `TimeOrdering.identifyTime`, which can LOWER `ord.timeCount`. This is the same maxTime-lowering mechanism that refuted earlier candidates; see `nextTime_reissues_retired_time` and `reuse_driven_through_engine`, and task 436's oriented-arm re-gate (`orientedGate*` family, :8592-8788) for how the analogous obstacle was handled for the self-guard component. A component that pays at `densityRule` steps but is destroyed by the identification arm is not a solution.

REFUTED ROUTES -- C9 register entries 14, 17, 18, 19, 20, 24. Read them ALL in full before designing anything. In particular entry 14 forbids BOTH (1) re-indexing `mintPotential` on `freshTimeRules` instead of `freshLabelRules` -- refuted by `witnessPresent_eq_false_of_not_freshLabel`, whose match has exactly eight arms so the three added columns are permanently false -- and (2) dropping disjunct 1's cardinality conjunct in favour of the ordering-rank conjunct alone -- refuted by `splitOrderedRank_lt_of_knownTimes_lt` plus `mintPaysForTime_rank_repair_false`. Neither may be re-attempted.

LITERATURE. Run with --lit against the sub-index curated for this line of work, drawing specifically on: venema_2001 section 5 (interval-based temporal logic) for the density/gap-guarded component itself; caleiro_2013 sections 6-7 (mosaic-method decidability for combined tense-and-modal logics) as a structural analogue for a combined-logic termination measure; gerth_1995 and baier_katoen_2008 (closure-set LTL tableau termination) as a model for a measure over an evolving, non-monotonically-changing time set; and massacci_2000 for rule-bounding technique.

DONE MEANS EITHER: (a) `gapPotential` defined, its payment at `densityRule` steps proved, its preservation across `identifyTime` proved, integrated into the measure, and a nonempty `MintPaysForTimeFixed` discharge extended to `.Dense` and `.Dedekind`; OR (b) a machine-checked impossibility result showing no such component exists at the current measure's shape, with the obstruction identified precisely and a C9 entry recording it. Outcome (b) is a genuine and valuable result, NOT a failure -- this repo's practice is that a proved refutation ranks with a proof, and several of this measure's real advances came from refutations.

PROHIBITED: no `sorry`, no vacuous or false predicate, no weakening presented as a repair (a direction lemma is a GATE, not a nicety -- C9 entry 7 exists because that mistake was made once); do not edit Fuel.lean, Saturation.lean or Tableau.lean (md5-pinned frozen); additive only in MintBound.lean; axioms within {propext, Classical.choice, Quot.sound}; full `lake build` green.

Dependencies: 462 is a REAL SEMANTIC dependency -- the engine-level assembly is what makes a per-rule payment usable at the successor, and `gapPotential`'s payment needs the same threading. 463 is a file_scope SERIALIZATION edge only (both edit MintBound.lean), with no mathematical content.

---

### 463. Postblockingsettlesrun verdict at terminus fuel
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: decidability
- **Dependencies**: Task 462, Task 433

**Description**: Decide `PostBlockingSettlesRun fc (mintAwareFuelAt U.card Tmax mintBudget D beta)` -- the narrowed settlement residual task 433 landed -- at the terminus's OWN fuel figure. Nothing currently decides it in either direction, and task 433's C9 register entry 24 exists precisely so the narrowing is not mistaken for a proof.

WHY THIS MATTERS. `PostBlockingSettlesRun` (MintBound.lean:11961) is CARRIED as a hypothesis by the fully-repaired terminus `buildTableauAt_isSome_of_budget_fixed_run` (:12199), exactly as `ArmSettlement` is. Until it is decided, the repaired terminus rests on an unknown. Task 433 established the surrounding facts but deliberately stopped short of this verdict.

WHAT IS ALREADY DECIDED -- consume, do not repeat:
- `PostBlockingSettles fc` (the unnarrowed form, :5181) is REFUTED: `postBlockingSettles_fuel_zero_false` (false at the `fuel = 0` arm at every frame class) and `postBlockingSettles_fuel_gap_false` / `postBlockingSettles_gap_at_every_fuel` (fuel does not close the gap, at ANY fuel). The witness is `freshWorldBranch = [F(box p)@<0,0>]`: `.boxNeg` mints a fresh world, so `expandOnceNoFresh` skips it and reports `.saturated` while `findUnexpandedUnblockedWith` reports it.
- `PostBlockingSettlesAt fc` (:11539) holds OUTRIGHT for every `fc` (`postBlockingSettlesAt_holds`, :11721) -- but the bridge from `saturateBlocked ... = some (.inr (satBr, satOrd))` to its antecedents does NOT go through, because at `fuel = 0` that equation holds at every branch while carrying no saturation information (`labelFreeSaturatedExit_not_of_saturateBlocked_inr`).
- Task 433 PROVED that the only bridge shape that typechecks carries a hypothesis that is itself refutable (it composes with the settlement lemma to give the refuted `PostBlockingSettles fc`). Do NOT re-attempt that bridge; it is a weakening dressed as a repair.

STRUCTURE THIS AS A REFUTE-FIRST GATE with a BINARY verdict, in the style tasks 432, 433 and 436 used successfully. Both outcomes are first-class deliverables:
- TRUE: `PostBlockingSettlesRun` holds at the terminus's own fuel figure -- discharge it, and the repaired terminus sheds a hypothesis.
- FALSE: it is refutable at that figure -- land the machine-checked refutation with its witness, record a C9 entry, and name the minimal further narrowing as the next step. A proved refutation here is as valuable as a proof and MUST NOT be treated as failure.

EMPIRICAL WARNING FROM TASK 433. Across fourteen formula shapes, four frame classes and three fuel figures, `buildTableauAt`'s own guard NEVER fired -- the threaded tracker and the recomputed `armTracker` agreed everywhere -- so no probed run exercised the post-blocking arm at all. That is a fact about the probe's reach, not about the residual, but it means this path is essentially untested empirically. Do not treat "no counterexample found by probing" as evidence of truth; the verdict must be proved either way, and if the honest answer is "undecided by the means available", say so explicitly with evidence rather than guessing.

PROHIBITED: do not discharge via `ArmSettlement` (proved strictly too weak: `resolveOpenArm` tests `findClosure satBr` before its saturation test, `buildTableauAt` does not); do not edit Saturation.lean, Tableau.lean or Fuel.lean (md5-pinned frozen) -- use only their existing public interface; do not re-attempt anything in the C9 register; no `sorry`, no vacuous discharge. Sorry-free, axiom-free, additive only, full `lake build` green.

Dependencies: 462, as a file_scope SERIALIZATION edge only (both tasks edit MintBound.lean). There is no mathematical dependency on 462 -- this task's content is independent of the minting measure and may be reasoned about immediately.

---

### 461. Acquire Goldblatt 1989 'Varieties of complex algebras' (Annals of Pure and Applied Logic)
- **Status**: [NOT STARTED]
- **Task Type**: general
- **Topic**: literature
- **Dependencies**: Task 460
- **Research**: [461_acquire_goldblatt_1989_varieties_of_complex_algebras/reports/01_acquisition-feasibility.md]

**Description**: SCOPE 8 acquisition gap identified by task 457's research and re-confirmed at implementation time: this paper is absent from both the ~/Projects/Literature corpus and the Zotero library, and is named as a prerequisite by other tasks in this repo working on the Jonsson-Tarski representation theorem. Note: goldblatt_2003 already present in the corpus is a DIFFERENT paper (Erdos Graphs Resolve Fine's Canonicity Problem) -- do not conflate the two. Needed: locate and acquire a copy of Goldblatt 1989 (Annals of Pure and Applied Logic 44, pp. 173-242), add it to Zotero, then run a normal /literature ingest.

---

### 433. Discharge postblockingsettles residual
- **Effort**: 6-10 hours
- **Status**: [PARTIAL]
- **Task Type**: lean4
- **Topic**: decidability
- **Dependencies**: Task 432, Task 434
- **Research**:
  - [428_engine_totality_at_a_quantified_branch_budget/reports/05_spawn-analysis.md]
  - [433_discharge_postblockingsettles_residual/reports/01_spawn-inherited-research.md]
- **Plan**: [433_discharge_postblockingsettles_residual/plans/01_postblockingsettles-refute-or-prove.md]
- **Summary**: [433_discharge_postblockingsettles_residual/summaries/01_postblockingsettles-summary.md]

**Description**: Discharge `PostBlockingSettles fc`, defined at FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean:4344, one of the four residual hypotheses on the totality terminus `buildTableauAt_isSome_of_budget` (MintBound.lean:4416). It states that the post-blocking pass leaves a branch the blocking-aware saturation test certifies -- i.e. `findUnexpandedUnblockedWith satBr satOrd fc (blockedTimes satBr satOrd fc (armTracker satBr)) = none` whenever `saturateBlocked ob fuel oOrd fc = some (.inr (satBr, satOrd))`. It subsumes `resolveOpenArm`'s own `none` arm via `armSettlement_of_postBlockingSettles` (MintBound.lean:4354) -- `ArmSettlement` alone is proved strictly too weak (`resolveOpenArm` tests `findClosure satBr` before its saturation test; `buildTableauAt` does not), so do not attempt to discharge via `ArmSettlement` instead. The relevant definitions are frozen (md5-pinned) in Saturation.lean (`saturateBlocked`, :431) and Tableau.lean (`blockedTimes`, :2104; `findUnexpandedUnblockedWith`, :2115) -- do not edit either file; the residual's own docstring states the gap ('whether the fuel-vs-condition gap can be closed by fuel alone') is exactly what Saturation.lean leaves open using only its existing public interface. Done means: either (a) a proof of `PostBlockingSettles fc` for the frame classes the terminus is meant to be used at, using only the public interface of the frozen files, landed sorry-free and axiom-free with `lake build` green; or (b), if (a) turns out to be genuinely impossible without touching the frozen files, a return to [BLOCKED] with the specific counterexample or obstruction found, analogous to the parent task's own refutation-driven repairs (e.g. `ordTimes_identifyTime_arm3_false`, MintBound.lean:1217) -- do not paper over with a vacuous definition (`lean4.md`'s Vacuous Definitions prohibition applies). This task's own residual work -- deciding PostBlockingSettlesRun at the terminus's own fuel figure, and completing the terminus restatement family -- has moved downstream to tasks 463 and 465 respectively; do not re-attempt those here.

---

### 430. Semantic lift and track a assembly valid iff allclosed
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: decidability
- **Dependencies**: Task 428, Task 429, Task 411

**Description**: The semantic lift and the Track A assembly. Owns obstruction O4 of the Phase 7.3 deadlock, then delivers what Phase 7.3 of task 165 was for. Grounding: specs/165_establish_semantic_finite_model_property/reports/09_phase7-deadlock-blocker-research.md.

THIS TASK CARRIES THE WORK MOVED OUT OF TASK 165's PHASE 7.3. Task 165 terminated with Phase 7 scoped to what it delivered (the truth lemma and Track A's conditional results); 7.3 -- `valid_iff_allClosed` and the `Decidable` instances -- was moved here rather than closed, because it is blocked on prerequisites no task owned.

O4 HAS TWO DISTINCT PIECES, per Verified/Decidable.lean:3062-3067: "It is not yet `valid_iff_allClosed` (7.3), which additionally needs the fuel/termination side and the truth-lemma gate, and it says nothing about the two rules scheduled outside `allRulesForFC` -- `serialityRule` and `timeLinearity` run as stages 2 and 3 of `expandOnce` and need their own obligations at the point where `expandOnce`, rather than `applyRule`, is the object."

(a) Two more `RuleSound`-analogues at the `expandOnce` level, for `serialityRule` and `timeLinearity`. These are deliberately outside `allRulesForFC`, so `ruleSound_of_mem_allRulesForFC` (landed, 34/34) does NOT cover them.
(b) THE SEMANTIC LIFT: the induction lifting single-step satisfiability preservation to the whole recursion, so that `.allClosed` yields a contradiction. This is the LARGER of the two and is comparable in weight to a landed sub-phase, not to a wrapper. Naming it inside "the two outside rules" understates it.

THEN, and only after (a), (b) and both predecessors: `valid_iff_allClosed` plus the four `Decidable` instances for validity over Base, Dense, Discrete and Dedekind.

WHAT IS ALREADY LANDED (do not re-prove): the rule half is done -- `ruleSound_of_mem_allRulesForFC` is a single landed induction over `mem_allRulesForFC_iff`, ledger complete at 34/34, from task 165 Phase 7.2.

PLAN AGAINST SIX ROWS, NOT EIGHT: the truth-lemma gate hypothesis hTW is discharged on SIX accepted TemporalWitnessProbe rows (A, B, C, D, E, F), not the historical eight -- rows I and K left when the PASSIVE arms of untlNeg/snceNeg were retired. See the banner at the head of Tests/BimodalTest/TemporalWitnessProbe.lean.

DO NOT write a conditional `valid_iff_allClosed` carrying hTW as an explicit hypothesis. Correctness.lean:98-105 refuses exactly this shape, and the O4(b) hypothesis would BE the conclusion's forward direction, making the theorem vacuous. Four vacuous theorems were deleted in 165's Phase 8; do not land a fifth.

DONE WHEN: `valid_iff_allClosed` and the four `Decidable` validity instances are landed unconditionally, sorry-free and axiom-clean outside Boneyard, lake build green.

---

### 429. Repair truth lemma side conditions boxanchored and temporalwitness
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: decidability
- **Dependencies**: Task 428

**Description**: Repair the truth-lemma side conditions. Owns obstructions O2 and O3 of the Phase 7.3 deadlock recorded in specs/165_establish_semantic_finite_model_property/reports/09_phase7-deadlock-blocker-research.md. THIS IS THE TASK WITH GENUINE OPEN MATHEMATICS IN IT and should be budgeted accordingly.

READ FIRST: specs/418_*/artifacts/boxanchored-finding.md -- it carries the measurement, the full carrier list, and the repair options. Then TruthLemma.lean:399-404 and BoxSaturation.lean:430-435, :574-580.

O2 -- `hBA` (`boxAnchoredCheck`) is no longer dischargeable on multi-world branches. BoxSaturation.lean:430-435: the two copy blocks "have since been removed as unsound ... They were the ONLY route by which T(G phi)/T(H phi) could reach a freshly minted world ... `boxAnchoredCheck` is therefore expected to compute `false` on multi-world branches now." :574-580: "a caller can no longer expect to discharge that hypothesis from a real run." TruthLemma.lean:399-404 names the repair as "an open design decision with its own soundness obligations" and lists THREE candidate routes: (a) propagate T(box phi) itself; (b) copy T(G phi)/T(H phi) only when box-derived; (c) restructure the `box` case to need no anchor.

CRITICAL CONSTRAINT: this was caused by task 418 (completed) removing a GENUINE UNSOUNDNESS. It is the cost of a correct fix, not a regression to revert. TruthLemma.lean:404 says "Do NOT reinstate the removed copies." Any repair must re-establish the anchor WITHOUT reinstating them.

O3 -- `hTW` (`temporalWitnessCheck`) is no longer dischargeable on any branch carrying a negative until with a known future time. TemporalWitnessProbe.lean:66-73: `untlNegFuture` demands F(event) at every known future time of every negative until; the PASSIVE arm's branch 1 was the ONLY producer of `not event` at an EXISTING time; that arm was retired as unsound (user-authorized rank 2), so the producer is gone. Measured cost: fourteen probe rows moved check=true -> check=false; the accepted set went from EIGHT rows to SIX (rows A, B, C, D, E, F; I and K left). :86-88: "it was already `false` on the branches the engine actually builds. What it removes is the last set of hand-built branches on which the hypothesis was discharged."

DO NOT REOPEN (settled by 165): guardWitnessed in any variant; restoring sat_untl_neg / sat_snce_neg (they are FALSE against the current engine, not merely unproved); reinstating the retired PASSIVE arms or the removed box copy blocks.

GOAL: choose among the three documented BoxAnchored repair routes and land it with its soundness obligations discharged; and re-establish a producer for `not event` at existing future times. Both must hold on branches the engine ACTUALLY builds, measured by the probes, not on hand-built branches.

DONE WHEN: `boxAnchoredCheck` and `temporalWitnessCheck` are dischargeable on real engine output for the relevant branch classes, evidenced by probe rows moving back to check=true; no unsound copy block or retired arm is reinstated; lake build green.
REALIGNMENT ADDENDUM (task 468, 2026-08-25) -- RECOMMENDED ROUTE, NAMED UP FRONT: of the three O2
repair routes listed above, route (a) -- propagate T(box phi) itself to the fresh world -- is the
RECOMMENDED route (per specs/reviews/review-2026-08-24.md amendment 10a and the box-anchor
artifact's own §5), so a dispatch need not re-derive the recommendation from
boxanchored-finding.md each time. It follows the S5 axiom-4/5 pattern, carries its own RuleSound
obligation, and has named fuel/termination consequences that Fuel.lean's bounds and the
subformula property must absorb -- all as already detailed in that artifact. Route (b) remains
available but reduces to route (a)'s obligation once branch provenance is tracked, per the
artifact. Route (c) stays recorded as CLOSED AS FORMULATED (boxGridCheck fails for the same
structural reason the anchor does, so weakening only the anchor buys nothing) -- do not
re-attempt it. This addendum names a recommendation; it does not narrow the task's own account of
all three routes and their obligations above, which stands as written.

---

### 428. Engine totality at a quantified branch budget
- **Status**: [BLOCKED]
- **Task Type**: lean4
- **Topic**: decidability
- **Dependencies**: Task 432, Task 433, Task 434, Task 465
- **Plan**:
  - [428_engine_totality_at_a_quantified_branch_budget/plans/02_lexicographic-splitordered-measure.md]
  - [428_engine_totality_at_a_quantified_branch_budget/plans/03_mint-bound-irreflexivity-totality.md]
  - [428_engine_totality_at_a_quantified_branch_budget/plans/04_ordtimesknown-strengthening-totality.md]
  - [428_engine_totality_at_a_quantified_branch_budget/plans/01_budget-totality-engine-repair.md]
- **Summary**:
  - [428_engine_totality_at_a_quantified_branch_budget/summaries/02_lexicographic-splitordered-measure-summary.md]
  - [428_engine_totality_at_a_quantified_branch_budget/summaries/01_budget-totality-engine-repair-summary.md]
  - [428_engine_totality_at_a_quantified_branch_budget/summaries/04_ordtimesknown-strengthening-totality-summary.md]
- **Research**:
  - [428_engine_totality_at_a_quantified_branch_budget/reports/03_phase11-potential-obstruction.md]
  - [428_engine_totality_at_a_quantified_branch_budget/reports/04_witness-preservation-machine-checked.md]
  - [428_engine_totality_at_a_quantified_branch_budget/reports/01_budget-totality-refuted-and-repair.md]
  - [428_engine_totality_at_a_quantified_branch_budget/reports/02_splitordered-measure-blocker.md]
  - [428_engine_totality_at_a_quantified_branch_budget/reports/05_spawn-analysis.md]

**Description**: Engine totality at a quantified branch budget. Owns obstruction O1 of the Phase 7.3 deadlock recorded in specs/165_establish_semantic_finite_model_property/reports/09_phase7-deadlock-blocker-research.md section "The four obstructions" (read it first; do not re-derive the refutation).

THE REFUTED THEOREM, SETTLED: `buildTableau_isSome` in unconditional form is FALSE, not merely unproved, and is on a do-not-re-attempt register (165's plan 01_tableau-decidability-two-track.md:1405-1420, :1489-1493). The refutation is a property of the engine SIGNATURE, not a proof difficulty: `buildTableau` (Saturation.lean:928-951) calls `expandBranchWithFuel` at the default `maxBranches := 50000` (Saturation.lean:590), whose first line is `if branchesUsed >= maxBranches then none` (:594). A formula exploring more than 50000 branches returns `none` at ANY fuel whatsoever. Independently, `buildTableau`'s last arm returns `none` on a still-unsaturated branch (:950). Neither is fuel exhaustion, so no fuel figure rules them out. DO NOT attempt the unconditional form.

WHAT LANDED INSTEAD, and why it is unusable as-is: Verified/Termination/Fuel.lean:1587-1598 carries two hypotheses -- `(hP : NoSplit P fc)` and `(hbud : branchesUsed + fuel <= maxBranches)`. `NoSplit` excludes impPos, orPos, untlPos, untlNeg, sncePos, snceNeg, orderTrichotomy and every frame-class-gated splitting rule, i.e. it holds only on non-branching runs. 165's plan:1467-1468 records "Residual 2 (branching arms) -- isolated, not discharged."

GOAL: add a `maxBranches`-parameterised entry point ALONGSIDE `buildTableau` -- an ADDITION, never an edit to the existing default, because `maxBranches = 50000` is a deliberate runtime guard -- and prove totality against a quantified budget. Target shape:

  theorem buildTableau_isSome_of_budget (phi : Formula) (fc : FrameClass)
      (maxBranches : Nat) (hmb : <bound in phi> <= maxBranches) :
      (buildTableauAt phi (soundFuel' phi) fc maxBranches).isSome = true

THREE SUB-OBLIGATIONS:
1. Discharge the branching-arm residual that `NoSplit` currently hypothesises (Fuel.lean:1587, Saturation.lean:661-664, :686-689).
2. Supply the missing WORLD-COUNT dimension. 165's plan:1484-1488: "T1 bounds formulas and T2 bounds times; neither bounds worlds ... as defined, `soundFuel' = 2*n*2^(2n)` has no world factor at all." A branch bound that ignores worlds cannot bound branches.
3. Establish the `<bound in phi> <= maxBranches` side condition in a form callers can actually discharge.

COORDINATION: overlaps task 426's hypothesis (b) on the same file (Fuel.lean). Sequence with 426 or merge; do not both edit Fuel.lean concurrently. Task 412 consumes this theorem in place of the refuted `buildTableau_isSome`.

DONE WHEN: the budget-parameterised totality theorem is landed sorry-free with no `NoSplit` hypothesis, lake build green, and the world dimension is either supplied or its absence is proved harmless.

RETARGET DECISION (user-approved, post-research): the specified unconditional target shape is refuted (see reports/01_budget-totality-refuted-and-repair.md). Task WIDENED to own the validated certificate repair: swap findUnexpanded -> findUnexpandedUnblocked at resolveOpenArm's two decision points, discharge the accompanying soundness obligation on what .hasOpen certifies (shared with O2/O3), lift the proved saturateBlocked_isSome asset, close the world dimension via worldFuel'/WorldWitness, and land the budget-parameterised totality theorem against the repaired engine. The per-path budget finding (maxBranches >= 3*fuel linear invariant) supplies the side condition.

SECOND RETARGET DECISION (user-approved, post-research 03). The per-step framing of Phase 11 cannot be closed: reports/03_phase11-potential-obstruction.md section 4 is a proof about the SHAPE of the argument, not a report of a failed attempt. Route (a) (a lower bound on branch cardinality after identification) is DEAD by definition -- `Branch.identifyTime = (b.map relabel).eraseDups`, so all shrinkage comes from eraseDups and is bounded only by |U|. Route (b) (an independent mint bound) is the APPROVED path.

THE CHEAPER ALTERNATIVE IS EXPLICITLY REJECTED BY THE USER: do NOT carry the mint bound as a hypothesis in the shape `hT` has, and do NOT push the discharge obligation onto task 412. Do it the right way.

APPROVED WORK (route (b), ~6-7 phases, comparable in size to everything landed so far):
1. WITNESS PRESERVATION (~3 phases): the eight-rule case analysis of report 03 section 3 step 4, resting on the three lemmas already machine-checked in that report's section 1 (`mem_futureOf_of_mem_constraints`, `mem_pastOf_of_mem_constraints`, `identifyTime_no_collapse`).
2. RESTATEMENT (~1 phase): give `expandBranchWithFuel_isSome_of_budget` an explicit MINT-BUDGET PARAMETER, in the shape `branchesUsed`/`maxBranches` already establishes. This is what converts route (b)'s amortized bound into something the induction can carry; a per-step potential over (b, ord) provably cannot express it (report 03 section 4), and `maxTime` was checked and is not a usable proxy (arm 3 can lower it).
3. AMORTIZED INDUCTION (~2-3 phases): #mints <= 8*|U|; #identifications <= |knownTimes|_0 + #mints; total shrinkage <= #identifications * |U|; #extensions <= |U| + total shrinkage; then the terminus `buildTableauAt_isSome_of_budget`.

RESEARCH GATE -- MACHINE-CHECK BEFORE PLANNING. Report 03 marks two load-bearing claims UNCERTAIN, and the whole mint bound rests on both:
  (i) section 3 step 4, witness preservation across `.splitOrdered` arm 3 -- ARGUED, NOT MACHINE-CHECKED. The two modal rules are trivial (their witness sits at the same time as `sf`, so identification moves both together); THE SIX TEMPORAL ONES NEED THE REACHABILITY TRANSPORT and were not verified.
  (ii) section 3 step 3, "formulas are never deleted" -- read off the rule shapes, consistent with the landed `expandOnceUnblocked_card_lt` / `expandOnceUnblocked_split_card_lt`, but NOT PROVED.
Machine-check BOTH before any plan is written. This task has twice had a plan rest on an unverified lemma that later turned out FALSE (the unconditional `buildTableau_isSome`; then the `.splitOrdered` cardinality twin). A third occurrence is not acceptable. If witness preservation fails for any temporal rule, ROUTE (b) IS DEAD and that is a THIRD retarget decision requiring human approval -- report it plainly, do not work around it and do not substitute a weaker statement.

PRESERVED, DO NOT RE-PROVE: phases 1-10 of plans/02_lexicographic-splitordered-measure.md are landed, sorry-free, axiom-free, and green repo-wide. Consume those declarations. `buildTableau`, its `fuel := 1000` default, and `expandBranchWithFuel`'s `maxBranches := 50000` default stay BYTE-IDENTICAL. No `NoSplit` reintroduction; no admitted `WorldWitness` or `hT`; no `sorry`; no narrowing a statement into vacuity. The refuted unconditional `buildTableau_isSome` and the refuted `.splitOrdered` cardinality twin stay on the do-not-re-attempt register. `resolveOpenArmCancellable` in CancellableExpansion.lean remains a DECLARED, deliberately-unrepaired out-of-scope divergence. Task 412 must not be planned against `buildTableauAt_isSome_of_budget` until it lands; the Phase 3 assets (`BudgetedTableau`, `buildTableauAt`, `BudgetedTableau.upgrade`) are available and sorry-free meanwhile.

RESUME SEQUENCE: `/research 428` first (discharge the two uncertain claims above), then `/orchestrate 428`. The stale loop guard from the prior invocation has been removed so a restart gets a fresh cycle budget.
REALIGNMENT ADDENDUM (task 468, 2026-08-25) -- ASSESS-AND-C9-REGISTER ESCAPE CLAUSE FOR THE
SPLIT-ARM FUEL SCALING PROBLEM: the opening "THE REFUTED THEOREM, SETTLED" paragraph above is
unaffected by this addendum and gets a CURRENT verdict on that point -- do NOT touch it.

`Fuel.lean:1595-1610` documents that fuel adequate for a split run scales like
`beta ^ depth * worldFuel'`, and depth is not bounded by anything proved in that file -- this is,
in its own words, "a real property of a deliberate engine policy, not a gap in a proof," of the
same class as the already-settled `buildTableau_isSome` refutation. If, in the course of this
task's approved route (b) work, the split-arm fuel-adequacy question proves genuinely unclosable
as specified -- i.e. no depth bound can be established or supplied without weakening the engine's
own proportional-fuel policy -- the correct deliverable is an explicit ASSESS-and-C9-register
outcome: name the specific obstruction, add a C9 register entry (in
`Verified/Termination/MintBound.lean`, alongside its other entries) stating precisely which
theorem still carries the split-arm scaling exposure and under what hypothesis, and stop there.
This is a VALID, COMPLETE outcome for this sub-question -- do not treat "close it" as the only
acceptable result, and do not force a proof past this obstruction by weakening `NoSplit`,
reintroducing a hypothesis this task's own do-not-re-attempt register forbids, or narrowing a
statement into vacuity.

---

### 412. Prove refutation core and decidability of provability with completeness corollaries
- **Effort**: 10-15 hours
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: decidability
- **Dependencies**: Task 165, Task 410, Task 411, Task 428, Task 430

**Description**: Track B finish for the TM tableau decidability program (parent: task 165; grounding: reports/02_tableau-decidability-hard-research.md sections 3.1, 8.3, 8.5). Create Verified/Refutation/Core.lean proving allClosed_derivable as ONE induction over allRulesForFC fc, discharging each rule by its admissibility lemma (predecessor tasks) and its ruleFrameClass r <= fc hypothesis via the RuleSpec GATE lemmas — Dense/Discrete/Dedekind instantiate the generic theorem, they do not re-prove it. Then Verified/Provable.lean: Decidable (Derivable fc [] phi) combining allClosed_derivable with Track A's buildTableau_isSome and not_valid_of_hasOpen; the completeness corollaries ValidFor fc phi -> Derivable fc [] phi; supply the Dedekind engine consumed by completeness_dedekind_of_engine (StrongCompleteness.lean:308, target ValidDedekindDense). Acceptance: zero sorries repo-wide outside Boneyard; lake build green; update typst/latex decidability chapters to record headline result 2.
RE-SCOPING ADDENDUM (2026-07-29, supersedes the buildTableau_isSome reference above): the scope text above depends on "Track A's buildTableau_isSome", which task 165 proved FALSE and placed on a do-not-re-attempt register (165's plan 01_tableau-decidability-two-track.md:1405-1420, :1489-1493). The refutation is a property of the engine signature, not a proof difficulty: buildTableau returns none whenever a formula explores more than maxBranches := 50000, at ANY fuel. Consequently this task's acceptance criterion "zero sorries repo-wide outside Boneyard" was UNREACHABLE AS SCOPED, independently of task 165's own status.

CORRECTED DEPENDENCE: consume the budget-parameterised totality theorem from task 428 (engine_totality_at_a_quantified_branch_budget) -- shape `buildTableau_isSome_of_budget phi fc maxBranches (hmb : <bound in phi> <= maxBranches)` -- in place of the unconditional buildTableau_isSome. Task 428 has been added as a predecessor. Do NOT attempt the unconditional form yourself.

ALSO NOTE: this task inherits obstructions O2 and O3 (the boxAnchoredCheck and temporalWitnessCheck truth-lemma side conditions) from Phase 7.3 of task 165 by way of not_valid_of_hasOpen. Those are owned by task 429. If your induction reaches a point where a truth-lemma gate hypothesis must be discharged on real engine output, that is 429's work, not this task's -- record it and coordinate rather than re-deriving it. Grounding for all of this: specs/165_establish_semantic_finite_model_property/reports/09_phase7-deadlock-blocker-research.md.

REALIGNMENT CORRECTION (task 468, 2026-08-25): the struck clause above ("discharge the
pre-existing sorry countermodel_discrete at Transfer.lean:1242") is STALE. That sorry no longer
exists -- countermodel_discrete is CLOSED, via tasks 477/478/479's k-equivalence/groupable-
companion route, and now lives sorry-free in
FormalSystem/Metalogic/WeakCanonical/GroupModel/CountermodelBase.lean, not Transfer.lean. Verified
fresh by scripts/check-module-invariants.sh C2/C3 at realignment time: C3 reports zero live
structural sorries tree-wide; C2 reports BXCanonical.completeness axiom-clean
([propext, Classical.choice, Quot.sound]). This task's remaining scope (allClosed_derivable, the
Decidable (Derivable fc [] phi) instance, the completeness corollaries, the Dedekind engine) is
UNCHANGED and still open.

New task 482 (discharge_proof_extraction_completeness, dependencies: [412]) is the owner of
eliminating .extractionFailed as a live outcome on a genuinely closed tableau -- it is gated on
this task's allClosed_derivable induction as a prerequisite and consumes it once landed. This
task's own acceptance criteria are unchanged by 482's existence; 482 is a downstream consumer,
not an addition to this task's scope.

---

### 411. Prove hard admissibility lemmas for until since trichotomy discrete and dedekind rules
- **Effort**: 15-20 hours
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: decidability
- **Dependencies**: Task 165, Task 410

**Description**: Track B part 2 for the TM tableau decidability program (parent: task 165; grounding: reports/02_tableau-decidability-hard-research.md sections 3.2-3.3 and 10). First run a /literature acquisition pass for Reynolds 1992 and Reynolds 2003 (the untlNeg co-decomposition and the Dedekind gap axioms; report 02 section 10 flags in-repo literature as thin). Then prove the hard admissibility block in Verified/Refutation/Rules/{UntilSince,Trichotomy,Discrete,Dense,Dedekind}.lean: untlPos (branch 1 via until_F, branch 2 via self_accum_until — follow the axiom literally), untlNeg (Reynolds co-decomposition via absorb_until + left_mono_until_G; the single largest lemma — budget it its own dispatch), sncePos/snceNeg duals, orderTrichotomy (one-liner if Phase 2.2 kept branches syntactically equal to temp_linearity disjuncts — verify, do not assume), z1Rule (two-premise instance of z1 + two modus ponens, relies on same-label internalization from the predecessor task), densityRule/denseIndicatorClosure via density/dense_indicator, and the Dedekind rules via prior_U_gap/prior_S_gap/sep. Acceptance: all admissibility lemmas sorry-free; lake build green.

---

### 410. Internalize tableau branches and prove routine rule admissibility
- **Effort**: 12-18 hours
- **Status**: [PLANNED]
- **Task Type**: lean4
- **Topic**: decidability
- **Dependencies**: Task 165, Task 429
- **Research**: [410_internalize_tableau_branches_and_prove_routine_rule_admissibility/reports/01_internalize-routine-admissibility.md]
- **Plan**: [410_internalize_tableau_branches_and_prove_routine_rule_admissibility/plans/01_internalize-routine-admissibility.md]

**Description**: Track B part 1 for the TM tableau decidability program (parent: task 165, plan plans/01_tableau-decidability-two-track.md, research reports/02_tableau-decidability-hard-research.md sections 3.1-3.4). Create FormalSystem/Metalogic/Decidability/Verified/Internalize.lean defining Branch.internalize (world labels via box/diamond nesting, time labels via U/S guards realizing the branch TimeOrdering; SETTLED constraints: internalization design over substitution — no cut or uniform-substitution admissibility exists in the tree — and z1Rule's two premises must stay at the same label). Then prove the routine admissibility lemmas in Verified/Refutation/Rules/{Propositional,Modal,Temporal}.lean (~21 lemmas: 8 propositional, 4 S5 modal, 1 boxTemporal, 8 temporal universal/existential), each stated as rule_admissible per report 02 section 3.1 with hypothesis ruleFrameClass r <= fc, reusing Combinators.lean, ModalS5.lean, TemporalDerived.lean, GeneralizedNecessitation.lean, and DeductionTheorem.lean via DerivationTree.lift. Acceptance: all lemmas sorry-free, lake build green, RuleSpec GATE lemmas still green.

---

### 298. Fix c7 labeling bug and regenerate dataset
- **Status**: [PARTIAL]
- **Task Type**: lean4
- **Topic**: dataset-enhancement
- **Dependencies**: Task 297, Task 343
- **Research**: [298_fix_c7_labeling_bug_and_regenerate_dataset/reports/01_c7-labeling-bug.md]
- **Plan**: [298_fix_c7_labeling_bug_and_regenerate_dataset/plans/01_c7-labeling-bug.md]
- **Summary**:
  - [298_fix_c7_labeling_bug_and_regenerate_dataset/summaries/01_c7-labeling-bug-summary.md]
  - [298_fix_c7_labeling_bug_and_regenerate_dataset/summaries/01_c7-labeling-bug-summary.md]

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

**Description**: Flip complexity-9 dataset generation from stratified to exhaustive-by-default once feasibility is confirmed. Prior work (see plans/01_exhaustive-enumeration-plan.md, handoffs/phase-1-6-handoff-20260714.md) verified the 0-sentinel/.take-guard machinery is already correct and unlimited-capable, and corrected stale infeasibility claims in data/README.md and scripts/run_dataset_generation.sh. The next action is the deferred c9 feasibility probe (Plan Phase 2), followed -- pending a GO verdict and explicit user approval for the multi-hour compute -- by c8/c9 exhaustive regeneration and HF Hub republication (Phases 3, 4(rest), 5, 6(rest), 7).

---

### 257. Large data storage huggingface
- **Status**: [BLOCKED]
- **Task Type**: general
- **Topic**: dataset-enhancement
- **Dependencies**: None
- **Research**: [257_large_data_storage_huggingface/reports/01_large-data-storage.md]
- **Plan**: [257_large_data_storage_huggingface/plans/01_implementation-plan.md]
- **Summary**: [257_large_data_storage_huggingface/summaries/01_execution-summary.md]

**Description**: Complete the Hugging Face Hub migration for large dataset storage. Prior work (see plans/01_implementation-plan.md, summaries/01_execution-summary.md) removed Git LFS tracking from .gitattributes and rewrote data/README.md to point at HF Hub (logos-labs/bmlogic-bench) as the canonical source, but Phase 1 -- the actual upload to HF Hub via the existing data/hf-dataset/upload.py pipeline -- was never executed because it requires user HF authentication. This task is blocked on that credential; once supplied, run the upload, validate, and confirm data/hf-dataset/PUBLISHING.md's 'Migration Status' header reflects completion.

---

### 231. Dataset regeneration automation
- **Status**: [NOT STARTED]
- **Task Type**: general
- **Topic**: dataset-enhancement
- **Dependencies**: Task 230, Task 298

**Description**: Build comprehensive automation so that every dataset regeneration automatically updates all downstream artifacts and documentation fields. Supersedes task 227 scope. (1) Create data/scripts/sync-all.py master sync script that: (a) Scans all JSONL files and recomputes metadata JSON files (record counts, rule distributions, schema field lists, valid/invalid ratios, tier distributions, step statistics). (b) Updates specific fields in data/README.md: file inventory table (Records, Size columns), training record schema table (field count), proof steps statistics (records, theorems, rule distribution, steps per theorem), cross-logic split table (records, valid rates), NL paraphrase statistics. (c) Updates specific fields in data/dataset-card.md: overview table, all record counts, proof steps section, competitive position 'primary gaps' paragraph. (d) Recomputes SHA-256 hashes and contentSize for all distributions in croissant.json. (e) Regenerates bmlogic-bench-splits.json. (f) Validates all JSONL records against declared schemas (checks field presence, types, null patterns). (g) Checks train/benchmark formula overlap and reports contamination percentage. (h) Validates metadata key consistency (total_records not total_count). (2) Idempotent and safe to run after any regeneration command (lake exe dataset_generator, lake exe proof_extractor, lake exe benchmark_oracle, finalize_benchmark.py). (3) --dry-run mode that reports what would change. (4) --commit mode that creates structured git commit. (5) CI-friendly exit codes (0=clean, 1=staleness detected, 2=validation error). (6) Update data/README.md with pipeline documentation. (7) Integrate into agent context (.claude/context/project/dataset/) so /implement for dataset tasks runs sync-all as post-implementation step. Note: supersedes task 227 (dataset_pipeline_automation_croissant_sync) with broader scope covering README/dataset-card field updates and schema validation.
=== ITEM (7) TARGETS A DISPOSABLE DEPLOY ARTIFACT -- CORRECTED 2026-08-24 ===

Item (7) above says "Integrate into agent context (.claude/context/project/dataset/)". DO NOT WRITE
THERE. Verified 2026-08-24: `.claude/` in this repository is fully gitignored (`.gitignore:81`) with
zero tracked files, and is regenerated wholesale from a source store that is NOT in this repository
-- it lives at /home/benjamin/.config/nvim/agent-system/, a separate git repo. A file written to
`.claude/context/project/dataset/` will be silently destroyed on the user's next agent-system
reload.

Item (7) therefore CANNOT be completed from inside this repository. Two acceptable dispositions,
both of which require asking the user first:

  (a) DROP item (7) from this task's scope and record why. The other seven sub-targets of this task
      are ordinary repository work (`data/scripts/sync-all.py`, `data/README.md`,
      `data/dataset-card.md`, `croissant.json`, the splits file, schema validation, contamination
      check) and are unaffected. This is the recommended default -- it keeps the task in one repo.
  (b) Split item (7) into a task filed in the nvim repository's own tracker
      (/home/benjamin/.config/nvim/specs/state.json), targeting
      agent-system/extensions/<appropriate-extension>/context/, and committed there.

Do not silently satisfy item (7) by writing into `.claude/`.
=== ITEM (7) DROPPED FROM SCOPE -- 2026-08-24, user decision ===

Item (7) ("Integrate into agent context (.claude/context/project/dataset/) so /implement for
dataset tasks runs sync-all as post-implementation step") is REMOVED from this task's scope. It is
not a defect and not deferred -- it is out of scope here, permanently, and no successor task owns
it in this repository.

WHY. The disposition options recorded above were put to the user on 2026-08-24 and option (a) was
chosen. Three considerations decided it:

  1. `.claude/` here is gitignored (`.gitignore:81`, zero tracked files) and regenerated wholesale
     from /home/benjamin/.config/nvim/agent-system/, a separate git repo. A file written to
     `.claude/context/project/dataset/` is destroyed on the next agent-system reload.
  2. Filing it in the nvim tracker instead was considered and declined. There is no `dataset`
     extension in that source store (verified 2026-08-24: core, cslib, email, epidemiology,
     filetypes, formal, founder, latex, lean, literature, memory, nix, nvim, present, python,
     slidev, typst, web, z3), and a BimodalLogic-specific post-implementation hook placed in the
     shared global agent-system would deploy to every repository that loads it. It would have to be
     generalized into a repo-local hook mechanism first -- a different and larger piece of work
     than this task.
  3. The `.syncprotect` escape hatch (project root; honored by deploy-headless.sh and the picker's
     sync path) would survive a reload, but leaves the file untracked and unbacked-up in a repo
     where everything else is version-controlled.

WHAT REMAINS IN SCOPE. Items (1) through (6) and (8), unchanged and unaffected -- they are ordinary
repository work under `data/`: `data/scripts/sync-all.py`, `data/README.md`,
`data/dataset-card.md`, `croissant.json`, `bmlogic-bench-splits.json`, schema validation, the
train/benchmark contamination check, and the metadata-key consistency check. Do not treat the
removal of item (7) as reducing any of them.

IF THE HOOK IS WANTED LATER. `sync-all.py` is a plain script with CI-friendly exit codes (item 5).
Wire it from repository CI or run it manually after a regeneration. That reaches the same outcome
without depending on agent-system context at all.

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
- **Dependencies**: Task 165, Task 402, Task 448, Task 470, Task 508
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

### 178. Publication examples and demo
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: formula-refactor
- **Dependencies**: Task 131, Task 193, Task 402

**Description**: Expand Examples/ with publication-quality demonstrations of the full verified pipeline. Complete worked example showing soundness and completeness on a concrete formula, plus decidability of the propositional fragment (genuinely complete today, per the soundness/completeness metatheory's axiom-clean status). Examples exercising each frame class with FrameClass-parameterized DerivationTree. Examples of the expressive completeness result. Update BimodalProofs.lean and TemporalStructures.lean. All examples sorry-free.

REALIGNMENT CORRECTION (task 468, 2026-08-25, carried from specs/reviews/review-2026-08-24.md
amendment M-7, independently re-confirmed at realignment time): the struck original acceptance
criterion above ("Complete worked example showing soundness-completeness-decidability on a
concrete formula") is RESCOPED. Decidability of TM (the full bimodal logic) is still open --
re-confirmed fresh this dispatch: grep -rn "isValid" FormalSystem/Metalogic/Decidability/ shows no
declaration takes DecisionProcedure.isValid as its subject, and ruleSound_of_mem_allRulesForFC is
not lifted to any allClosed -> valid theorem. `truthAt_of_isValid`
(Verified/Decidable.lean:2412) is NOT evidence of decidability -- it concerns a different,
semantic-side `SoundnessLemmas.IsValid`, not the decision procedure's `DecisionProcedure.isValid`.
Do not cite it as such. This task's decidability example is therefore rescoped to the
propositional-fragment case (genuinely decidable today) rather than the full logic; a full-logic
decidability example remains gated on the decidability/tableau front (410-465,
480-482) landing.

---

### 177. Update readme and module docstrings
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: formula-refactor
- **Dependencies**: Task 131, Task 193, Task 402, Task 426, Task 428, Task 429, Task 430, Task 432, Task 433, Task 434, Task 440, Task 441, Task 448, Task 494, Task 510, Task 513

**Description**: Update README.md, docs/, and FormalSystem/ module-level docstrings to their final post-refactor state, once the decidability chain (426, 428, 429, 430, 432, 433, 434) lands. This is the final polish pass, distinct from and run after task 472's already-completed immediate correction pass. Explicitly excludes: every item task 472 already corrected (the Decidability.lean Status block, Verified/README.md, FMP/README.md, DecisionProcedure.lean's decideAuto docstring, Verified/Decidable.lean's Status docstring, WeakCanonical.lean, RealModel/ShuffleReal.lean, Soundness.lean, PriorExpressivenessDense.lean) and the two Kamp files task 473 already swept (Kamp/EANegationClosure.lean, NfMultiAnchorBridge/NavigatedSpine.lean). This task's residual content is: re-auditing all touched documentation for drift accumulated during the decidability chain's landing (472/473 audited a snapshot; the chain's remaining tasks will touch further files after 472/473 ran), and the Axiom Reference update the charter names as part of 177's original scope.

REALIGNMENT NOTE (task 468, 2026-08-25, verdict per specs/468_realign_task_programme_from_proof_state_audit/reports/02_stage1-verification-and-programme-realignment.md §6): DIVIDE, already half-executed exactly as specs/reviews/review-2026-08-24.md amendment 10f states -- tasks 472 (documentation correction pass) and 473 (Kamp vacuity deletion) already ran the ungated half; the description above is the remaining, gated half's text. `file_scope` (README.md, specs/ROADMAP.md, FormalSystem/, docs/) was already repaired by task 470 item (G) and is confirmed resolvable, no duplicate -- left unchanged here.

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
- **Dependencies**: Task 420, Task 439, Task 461, Task 498, Task 499

**Description**: CAPSTONE of the algebraic representation front. Prove the Jonsson-Tarski representation theorem for the bimodal logic: the embedding eta(a) = {U | a in U} is an injective STSA homomorphism A -> Cm(Uf(A)).

RE-SCOPED. This task's original four phases are now distributed: Phase 1 (complex algebra Cm(F)) and Phase 2 (ultrafilter frame Uf(A), including the Spherical obligation) are separately tasked and are this task's dependencies; Phase 4 (binary untl/snce operators) is separately tasked and depends on this one. What remains here is Phase 3 -- the embedding itself and its injectivity -- stated at the unary signature (box, G, H, sigma).

PREREQUISITE STATE, RE-VERIFIED 2026-08-26: the STSA class and the R_G/R_H/R_Box ultrafilter frame exist as Boneyard seeds behind #exit and are ported by the dependency tasks. The MCS-to-ultrafilter bijection is live at Algebraic/UltrafilterMCS.lean:782 (ultrafilter_correspondence), though stated existentially rather than as a named Equiv -- converting it to an Equiv may be worth doing here. The BooleanAlgebra LindenbaumAlg instance is at BooleanStructure.lean:421.

THE PRIOR PREREQUISITE LIST IN THIS DESCRIPTION IS STALE and is superseded: it named 'resolve 6 algebraic sorries in TenseS5Algebra/InteriorOperators/LindenbaumQuotient'. InteriorOperators.lean and LindenbaumQuotient.lean are sorry-free today; the remaining sorries are the 3 in the Boneyard TenseS5Algebra seed, and they are for REMOVED axioms (temp_a, temp_l) that must be restated against the current 45-constructor axiom set rather than proved as-is. That is the STSA port task's business, not this one's.

LITERATURE: Goldblatt 1989 'Varieties of complex algebras' (APAL 44, 173-242, doi 10.1016/0168-0072(89)90032-8) has been acquired. CAVEAT THAT MUST BE HONORED: the acquired PDF is an Acrobat 3.0 Capture scan with a badly degraded OCR text layer -- math-heavy pages yield mangled symbols, dropped and reordered lines. READ THE PAGE IMAGES DIRECTLY (the Read tool's pages parameter); do NOT rely on a pdftotext-derived conversion for any axiom statement or equation. Blackburn/de Rijke/Venema 2002 Chapter 5 (corpus entry blackburn_2002) is the primary reference and is born-digital.

MATHLIB HOOK: Order/Atoms.lean:710 (toSetOfIsAtom : alpha <-> Set {a // IsAtom a} for CompleteAtomicBooleanAlgebra) is the atom-structure half of Stone/Jonsson-Tarski for the complete atomic case and is the single most relevant Mathlib lemma here; supporting lemma eq_setOf_le_sSup_and_isAtom at :695. Mathlib has NO Stone duality for Boolean algebras and no BAO machinery -- the rest is greenfield.

SEE ALSO the reconciliation task on whether this embedding can be factored through ShiftSet.lean's reverse_repr rather than built independently; if it can, that supersedes part of this task's construction and this description should be revised again before implementation starts.
