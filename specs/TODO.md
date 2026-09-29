---
next_project_number: 706
---

# TODO

## Task Order

*Updated 2026-09-29. Generated from state.json dependency graph.*

**Dependency Waves**:
| Wave | Tasks | Blocked by | Topics |
|------|-------|------------|--------|
| 1 | 127,128,178,257,298,464,481,502,559,563,570,604,650,664,701,703,705 | -- | algebraic-representation, categorical-structure, dataset-enhancement, ... |
| 2 | 231,282,296,465,497,564,565,567,616,617,704 | 298,464,502,563,703 | algebraic-representation, categorical-structure, dataset-enhancement, ... |
| 3 | 219,428,498,499,500,566,618 | 231,465,497,564,565,616 | algebraic-representation, categorical-structure, dataset-enhancement, ... |
| 4 | 125,429,543 | 428,498,499,500 | algebraic-representation, decidability, metalogic |
| 5 | 410,501 | 125,429 | algebraic-representation, decidability |
| 6 | 411 | 410 | decidability |
| 7 | 430 | 411 | decidability |
| 8 | 412 | 430 | decidability |
| 9 | 482 | 412 | decidability |
| 10 | 177 | 178,282,296,481,482,543 | formula-refactor |

**Grouped by Topic** (indented = depends on parent):

### Algebraic Representation

502 [NOT STARTED] — RESEARCH TASK. Ground the algebraic representation front in...
  └─ 497 [NOT STARTED] — Bring the Shift-closed Tense S5 Algebra class into live code...
    └─ 498 [NOT STARTED] — Phase 1 of the Jonsson-Tarski representation: the complex...
      └─ 125 [NOT STARTED] — CAPSTONE of the algebraic representation front. Prove the...
        └─ 501 [NOT STARTED] — Phase 4 of the Jonsson-Tarski representation: extend STSA...
    └─ 499 [NOT STARTED] — HARD. Phase 2 of the Jonsson-Tarski representation: the...
      └─ 125 [NOT STARTED] — CAPSTONE of the algebraic representation front. Prove the... (see above)
    └─ 500 [NOT STARTED] — RESEARCH TASK. Prevent two parallel representation theorems...

### Categorical Structure

563 [NOT STARTED] — Promote the presheaf skeleton into the library. DELIVER: the...
  └─ 564 [NOT STARTED] — Prove app:gluing for two interval sections whose germs agree...
    └─ 618 [NOT STARTED] — Formalize the path category Path(F) and prove...
  └─ 565 [NOT STARTED] — Prove app:presheaf-dictionary's Totality and Directed Gluing...
    └─ 566 [NOT STARTED] — Prove app:presheaf-dictionary's Possible Worlds clause: HF...
  └─ 567 [NOT STARTED] — Prove app:presheaf-dictionary's Determinism clause -- F...
  └─ 616 [NOT STARTED] — Formalize the duration monoid BD+, its twisted-arrow...
    └─ 618 [NOT STARTED] — Formalize the path category Path(F) and prove... (see above)
  └─ 617 [NOT STARTED] — Prove app:presheaf-dictionary's Reflection clause: reflection...

### Dataset Enhancement

257 [BLOCKED] — Complete the Hugging Face Hub migration for large dataset...
298 [PARTIAL] — Fix c7 labeling bug at formula ~13750 that causes unbounded...
  └─ 231 [NOT STARTED] — Build comprehensive automation so that every dataset...
    └─ 219 [RESEARCHED] — Run bmlogic-bench through multiple LLMs to establish baseline...
  └─ 282 [PARTIAL] — Flip complexity-9 dataset generation from stratified to...
  └─ 296 [PARTIAL] — Re-add the 6 derived binary temporal operators (release,...
604 [NOT STARTED] — Add zstd-compressed .jsonl dataset support across the data...

### Decidability

464 [RESEARCHED] — Design and land gapPotential, the density coordinate of the...
  └─ 465 [NOT STARTED] — Complete the terminus restatement family at the repaired...
    └─ 428 [BLOCKED] — Engine totality at a quantified branch budget. Owns...
      └─ 429 [NOT STARTED] — Repair the truth-lemma side conditions. Owns obstructions O2...
        └─ 410 [PLANNED] — Track B part 1 for the TM tableau decidability program...
          └─ 411 [NOT STARTED] — Track B part 2 for the TM tableau decidability program...
            └─ 430 [NOT STARTED] — The semantic lift and the Track A assembly. Owns obstruction...
              └─ 412 [NOT STARTED] — Track B finish for the TM tableau decidability program...
                └─ 482 [NOT STARTED] — CLASSIFICATION: OPEN MATHEMATICS, multi-month. This MUST NOT...
481 [BLOCKED] — CLASSIFICATION: genuinely open -- the predicate is refuted as...
701 [RESEARCHED] — Port the branching-substrate lessons from the ProofChecker's...
703 [RESEARCHED] — Prove the L-plus twin of...

### Formula Refactor

178 [NOT STARTED] — Expand Examples/ with publication-quality demonstrations of...
  └─ 177 [NOT STARTED] — Update README.md, docs/, and FormalSystem/ module-level...

### Frame Extensions

127 [NOT STARTED] — Add time addition operator (+) to the bimodal logic TM. φ + ψ...
128 [NOT STARTED] — Add topological open set (interior) operator for dense and...

### Incompleteness

705 [NOT STARTED] — transreflexivityresidualcollapse: Task 696's recommended...

### Literature

664 [NOT STARTED] — Acquire and ingest the Cmiel-Kuhlmann-Kuhlmann ball-space...

### Metalogic

559 [RESEARCHED] — RESEARCH TASK, verdict-first -- reports and sorry-free probe...
570 [NOT STARTED] — OPEN RESEARCH QUESTION, not an implementation task. Is the...
543 [NOT STARTED] — Machine-check the principal new results from the MF...

### Reference Book

650 [RESEARCHING] — Define-before-use audit of...

### Verification

704 [NOT STARTED] — Two structural preventions against the class of defect the...

## Tasks

### 705. Trans reflexivity residual collapse
- **Status**: [NOT STARTED]
- **Task Type**: formal:logic
- **Topic**: incompleteness
- **Dependencies**: None

**Description**: trans_reflexivity_residual_collapse: Task 696's recommended substrate redesign declares trans_refl : forall r in transBack ++ transMid ++ transFwd, forall i, r i i = true as a field of the proposed skeleton (the additive data layer for the trans-based redesign of (C1')'s two temporal conjuncts). With that field, the redesigned (C1') still entails a latent invariance-collapse structurally identical to the one the redesign exists to remove: trans t i j -> (untl g e in L i t <-> untl g e in L j t) and trans (t-1) k i -> (snce g e in L i t <-> snce g e in L k t), both machine-checked in task 699's probe (specs/699_invariance_clause_audit_and_ockhamist_grounding/probes/01_clause_shape_collapse_probe.lean, theorems tUntl_trans_congr and tSnce_trans_congr) against an external trans parameter, using only reflexivity of trans and the shape of the redesigned clause. The invariance is not semantically forced: arrival pruning (trans u i j -> share (u+1) i j) relates the two indices at t + 1, not at t, so the redesigned clause constrains a label row the thread in question never visits at t -- the same category of spurious constraint as the original share-based defect, relocated from share-classes to trans-classes. Both of task 696's gate families set every trans segment to [eq] (trans = eq), making trans t the diagonal, so both theorems are vacuous on them and the gate passes without exhibiting the residual; the residual bites exactly on the hopping families that design T's generality (task 696) exists to admit. Scope: (1) decide whether trans_refl is required, by auditing the approximately 25 term-level Thread.const call sites across PlusWitnessFamily/{Agreement,Basic,Predicates}.lean and Sharing/{Agreement,Predicates,Stability,Thread}.lean (8 files total) against the weaker existential field 'for every i and u there is a thread with idx u = i' -- expected answer: every site consumes only the existential, since the sites need some thread through a position, not the constant one; (2) if so, specify the replacement field and the one substitution lemma, and hand the specification to task 696's Phase 1 so the reflexivity field is never declared; (3) record untl_succ_congr / snce_pred_congr (the common-successor / common-predecessor congruences -- clause_shape_common_witness applied at the flipped relation, already machine-checked as tUntl_common_succ_congr in task 699's probe) as the intended residual once reflexivity is dropped, so the next reader knows the relocation from share-classes to trans-classes is deliberate and bounded -- task 696's report 01 already asks for this record; task 699 supplies the reflexivity-free derivation that makes it exactly the residual and nothing more; (4) optionally, and only if step 1 finds trans_refl genuinely required for some site the existential field cannot supply, construct a hopping countermodel and a target schema that the trans-congruence blocks, turning the residual into a named incompleteness theorem the way not_plusCertifies_stabSnce did for the original defect. Non-goals: no substrate redesign (task 696 owns the redesign in full); no change to plusTruth_iff_mem or plusRefutes_of_certifies (soundness is not in question); no re-conversion of the thomason-1970-indeterminist-time corpus source (optional future work, only if a separate unverified literature claim becomes load-bearing). Ordering constraint: this task should be resolved before task 696 Phase 1 declares trans_refl as a skeleton field, because removing a declared field after code depends on it costs substantially more than not declaring it in the first place -- task 696 Phase 1 is the additive data layer where trans_refl would first appear. Type: formal:logic. Effort estimate: research-first (step 1 is an audit, not a proof); implementation of steps 2-3 belongs to whichever cycle lands task 696 Phase 1.

---

### 704. Certificate non vacuity and shape gates
- **Status**: [NOT STARTED]
- **Task Type**: general
- **Topic**: verification
- **Dependencies**: Task 696, Task 703

**Description**: Two structural preventions against the class of defect the L-plus completeness programme (tasks 695, 696, 699, 700, 703) exists to remove, filed as one task because both are assertions in scripts/check-module-invariants.sh and splitting them would put two tasks on the same single file. (a) A standing obligation that every certificate-shaped condition set carry an exhibited NON-TRIVIAL inhabitant as a checked artifact: the (C1')-clause defect survived undetected because no such witness had ever been exhibited, and a vacuously-satisfiable condition set type-checks indefinitely without ever certifying anything. Task 696's famA_tCertifies and famB_tCertifies (once landed) are the first instances the gate should check against. (b) A mechanical check against the collapsing clause shape -- a definition that universally quantifies a biconditional over a reflexive relation -- so the error class cannot be reintroduced silently. Task 699 Part A's audit table (specs/699_invariance_clause_audit_and_ockhamist_grounding/reports/01_invariance-clause-audit-ockhamist-grounding.md) and its clause_shape_collapse abstract lemma are the specification for (b): the table enumerates every occurrence of the shape and classifies each as intended-invariance or latent-collapse, which is exactly the allowlist a shape check needs.

Sequencing: this task is sequenced LAST in the L-plus completeness programme, after both task 696 (the substrate repair) and task 703 (lplus_compression_and_completeness) land, and not before. A gate landed before task 696's refactor would go red on the very refactor it exists to protect, since 696 deletes and replaces the clauses this gate's allowlist must be built from. A shape check written against the pre-repair clauses would encode the defect itself as the baseline rather than the repair.

Soundness is not in question anywhere in this task; both preventions are gates against future completeness-side regressions, not soundness gates. Existing invariants in scripts/check-module-invariants.sh run C1-C35; these are C36/C37.

---

### 703. Lplus compression and completeness
- **Status**: [RESEARCHED]
- **Task Type**: lean4
- **Topic**: decidability
- **Dependencies**: Task 695, Task 696
- **Research**: [703_lplus_compression_and_completeness/reports/01_lplus-compression-completeness-research.md]

**Description**: Prove the L-plus twin of FormalSystem.Metalogic.Decidability.exists_witnessFamily_of_not_validZTime: every ZTime non-validity of a PlusFormula admits a bounded, canonically guessed PlusSharingWitnessFamily certifying the refutation, against task 696's redesigned condition set. Soundness is not in question anywhere in this task: FormalSystem.Metalogic.Decidability.PlusSharingWitnessFamily.plusTruth_iff_mem and ...plusRefutes_of_certifies are untouched by this task's proof and must survive with their statements unchanged. Acceptance: zero sorries, no new axioms, a docs/theorem-index.md row, and a C2 AXIOM_BASELINE pin for the new theorem.

RESEARCH-FIRST. This task's research round must answer three obligations this repository's completeness-programme survey (task 700) found unrecorded before any plan is written: O1 -- is Liftable decidable, and by what argument (likely yes by finite-graph simulation on the periodic index set, but unscoped; if it is not decidable the compression theorem still holds but the decision procedure degrades to a semi-decision procedure again, which must be recorded plainly rather than concealed); O2 -- constructing a liftable arrival-pruned trans from an arbitrary countermodel, the general case rather than the constant-thread case the two landed lifts use; O3 -- (C5) StabFaithful's time-indexed witness demand and the resulting lasso-count bound, which may not be |closure| + 1 (the Formula side's bound) and may instead be |closure| times the window, a difference that propagates into the enumeration cost and into the paired repository's search-bound expectations. This task's research round must also read task 699 Part B's literature-grounding report, which bears on a fourth question (O4: whether GKWZ-style product-undecidability results for an S5-factor-plus-linear-factor combination bound this repository's two S5-like modalities, box over all histories and the state-agreeing-history stability modal) -- as landed, task 699 Part B does not address O4 (it answers different, adjacent questions: the Peircean/Ockhamist framing, Liftable's identification with Emerson-Halpern R-generability, and positive decidability results (Gurevich-Shelah, Burgess) that de-risk but do not settle O4), so this task's own research round must treat O4 as open and answer it directly rather than assuming 699 settled it.

Why carrier normalization is a hard prerequisite: FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Compression/Family.lean:165 is `rw [validZTime_iff_validInt]`, Step 0 of the Formula-side theorem this task's L-plus statement mirrors; there is no provable Step 0 for the L-plus statement without FormalSystem.PlusLanguage.plusValidZTime_iff_plusValidInt (task 695, landed in FormalSystem/PlusLanguage/PlusIntTransfer.lean).

Substrate dependency: this task's dependency on task 696 is on the substrate as FINALLY CORRECTED, not on 696's design as first recommended. Task 699 Part A's audit found that 696's recommended redesign relocates rather than repairs the (C1')-clause collapse, because the proposed trans_refl field reproduces clause_shape_collapse's hypothesis; 699 has proposed (not yet filed as a numbered task) a follow-on to drop trans_refl before 696's Phase 1 declares it. This task's plan must state its dependency against 696 including that follow-on once it is filed, by fully-qualified declaration name, not by an invented task number.

Soundness is not in question anywhere in this task.

---

### 701. Port substrate lessons to model checker
- **Status**: [RESEARCHED]
- **Task Type**: general
- **Topic**: decidability
- **Dependencies**: Task 696
- **Research**: [701_port_substrate_lessons_to_model_checker/reports/01_substrate-lessons-for-model-checker.md]

**Description**: Port the branching-substrate lessons from the ProofChecker's stability-modal redesign into the bimodal theory (/home/benjamin/Projects/ModelChecker/code/src/model_checker/theory_lib/bimodal/). RESEARCH-FIRST: the deliverable of the research phase is a report that says which lessons apply, where, and what should change; no certificate-search code changes until a plan exists. WHAT THE VERIFIED SIDE FOUND (BimodalLogic task 696, two machine-checked research rounds): (1) under state-sharing between lassos with arrival renaming (a single per-time `share` relation carrying both state identity and one-step succession), BOTH stability coherence clauses are defective, not just `snce` -- `snce_share_congr` and the new `untl_shift_share_congr` force any two indices naming the same state to agree on every `snce` formula and on the shifted `untl` unfolding, so the certificate class is empty for `Pp -> [stab]Pp` AND for `Fp -> (p \/ [stab]Fp)`, both genuine integer-time non-validities. (2) The root cause is that one-step succession is encoded as a class, not a relation; re-timing the `snce` clause is unsound. (3) The recommended repair is a fourth periodic datum `trans` (three lists `transBack`/`transMid`/`transFwd` of n x n Boolean matrices, same lengths as the `rep*` lists), pruned by arrival renaming: `trans u i j -> share (u+1) i j`. `Thread.step` becomes `trans u (idx u) (idx (u+1))`. (4) The one new obligation is closure: every frame history must be a thread (`Liftable`, a skeleton field), with sufficient lemmas for the full relation (today's semantics), splice-closed lasso families (pigeonhole), and later an exact window form. (5) The export contract is ADDITIVE: absent `trans*` fields default to the full relation, which is exactly today's semantics, so no existing deterministic certificate changes and nothing in this repository is required to change for correctness. Sources to read in full: /home/benjamin/Projects/BimodalLogic/specs/696_stability_modal_substrate_design/reports/01_stability-modal-substrate-design.md, .../reports/02_trans-redesign-gate-verification.md, the three probes under .../probes/ (03_trans_redesign_gate_probe.lean states the redesigned conditions and the two gate families), and the `## Hand-off to the consuming model checker` section of /home/benjamin/Projects/BimodalLogic/FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/README.md. RESEARCH QUESTIONS, in order: (Q1) What does this theory's certificate search assume about world histories today -- semantic/certificate.py, semantic/witness_registry.py, semantic/witness_constraints.py, docs/ADEQUACY.md, docs/ARCHITECTURE.md -- and which of those assumptions (histories are lasso orbits, determinism makes the box case enumerable) does the thread/`trans`/`Liftable` account replace? (Q2) Which lessons port, and to which files: separating state identity from succession in any sharing extension; shaping the search space so closure is cheap (splice-closed lasso families rather than arrival renaming); emitting `trans*` beside `rep*` when sharing lands; whether the pure-Python re-checker (`recheck`) needs a thread-based history characterization to stay independent of the verified side. (Q3) Re-scope task 200 (extend_bimodal_to_stability_modal, blocked) against this: its description waits on "a state-sharing witness structure, its histories characterization, its redesigned box condition" -- the verified side now specifies all three; say what 200 should become. Check task 219's THEORY-LIMITS text: the recorded limit is broader than stated, since the `untl` side fails too, and the limit is expected to be REMOVED by the verified redesign, so the group's wording must distinguish a limit of the theory from a limit of a since-repaired certificate system. (Q4) Confirm the additive contract at the wire level: semantic/formula.py JSON codec, certificate.py writer, tests/fixtures/certificates/*.json, and test_certificate_lean_agreement.py -- name the exact fields and default to add when sharing lands, and confirm nothing must change now. (Q5) Whether docs/ADEQUACY.md's box case can be restated over threads ahead of sharing, so the later extension is a refinement rather than a rewrite. CONSTRAINTS: this repository must keep producing valid deterministic certificates throughout; do not adopt arrival renaming as the sharing design; any new fields must be additive to the wire format. OUTPUT: a report answering Q1-Q5 with file-level pointers, a proposed re-scoping of task 200 and an amendment to task 219, and a phased proposal for what (if anything) to change now versus when the verified redesign lands. REPOSITORY BOUNDARY: this task lives in BimodalLogic and DEPENDS ON TASK 696 so that the lessons are drawn from the landed redesign, not from the research alone. All ModelChecker paths above are under /home/benjamin/Projects/ModelChecker (its own task system holds tasks 200 and 219). The research and plan phases read that repository but write only under this repository's specs/; the implementation phase produces the concrete proposals (re-scoped 200, amended 219, any new ModelChecker tasks) as ready-to-file task descriptions in this task's summary, and edits no ModelChecker source directly -- filing and executing them is done in the ModelChecker repository.

---

### 696. Stability modal substrate design
- **Status**: [COMPLETED]
- **Task Type**: lean4
- **Topic**: decidability
- **Dependencies**: Task 700
- **Research**: [696_stability_modal_substrate_design/reports/02_trans-redesign-gate-verification.md]
- **Plan**: [696_stability_modal_substrate_design/plans/02_trans-arrival-substrate-refactor.md]
- **Summary**: [696_stability_modal_substrate_design/summaries/02_trans-arrival-substrate-refactor-summary.md]

**Description**: DESIGN-INVESTIGATION-FIRST TASK. Determine what the stability modals ideally require of the branching witness substrate, choose the best way to provide it, then plan and implement that refactor. Do NOT begin from the assumption that any particular repair is correct: the fourth-periodic-datum `trans` proposal recorded in WitnessFamily/Sharing/README.md's `### (c) What a follow-up needs` is ONE candidate to be evaluated against alternatives, not the settled design. Ground truth to build on, already machine-checked and landed in FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Incompleteness.lean: `snce_share_congr` shows that (C1') LocalCoherentShare's `snce` clause, by quantifying its predecessor over the share-class at the label's OWN time, forces any two indices naming the same world state to agree on every `snce` formula of the closure; `not_plusCertifies_stabSnce` and `not_plusCertifies_stabSnce_premise` show no six-condition L-plus family certifies any instance of `(g S e) -> stab (g S e)` in either target placement, at any time or size; and `not_plusValidZTime_stabSnce` shows `Pp -> stab Pp` is a genuine integer-time non-validity, so the empty certificate class is a completeness failure and not a vacuity. The `untl` clause escapes the defect only because it quantifies over the class at `t+1`, and that asymmetry traces to Sharing/Skeleton.lean's deliberately tight `Thread.step`. RESEARCH PHASE must answer, in order: (1) What does each stability modal's truth clause actually quantify over, semantically, and what is the weakest substrate datum that supplies exactly that -- stated as adequacy criteria before any candidate is scored, so the comparison is not retrofitted to a favoured answer. (2) Enumerate the candidate designs and score every one against those criteria. At minimum: the fourth-datum `trans` relation separating succession from state-identity; leaving `share` single but re-timing (C1')'s `snce` quantifier to `t-1` by analogy with `untl`'s `t+1`; indexing the share relation by the formula class it serves; and any design the investigation itself surfaces. For each, say what it costs in re-proof surface, what it costs in the model checker's export contract, and whether it is additive or breaking there. (3) Confirm by construction, not by argument, that the chosen design does NOT re-derive the defect: exhibit a concrete family satisfying all six redesigned conditions at NON-TRIVIAL sharing (no landed example of this exists at present -- Examples.lean's `stabFamily_separates` checks (C5) in isolation and the only producer of a branching `Certifies` is the deterministic diagonal, where (C5) provably collapses), AND check that the redesigned (C1') no longer entails an analogue of `snce_share_congr`. Without that second check a redesign can reproduce the present defect while type-checking. (4) Re-examine rather than inherit (C2')'s recorded (C1')-relative limitation: there is no standalone `Decidable (ThreadFulfilling S)`, only a hypothesised term plus an instance on the conjunction. HARD CONSTRAINTS on the implementation: soundness is not at issue and must stay untouched -- `plusTruth_iff_mem` and `plusRefutes_of_certifies` keep their current statements; zero sorries and no new axioms; the C2 axiom baseline rows and docs/theorem-index.md rows pinned for Incompleteness.lean must be updated deliberately and visibly, since a successful repair is expected to make the `not_plusCertifies_*` rows FAIL and that transition is the evidence the refactor worked. Re-proof surface is roughly 3500 lines across nine modules on both the Formula and PlusFormula sides, with WitnessFamily/Sharing/Fulfil.lean (1669 lines) and PlusWitnessFamily/Fulfil.lean (1093 lines) dominating, so the plan must phase the work so each phase ends green rather than carrying a broken tree between phases. Relationship to sibling work: this task is the design authority for the substrate question that task 694 prescribes one solution to, and task 694 should be re-scoped or folded in once this task's research settles the design; task 695's L-plus carrier normalization is an independent prerequisite for any decidability route and is deliberately not in scope here.

---

### 664. Ingest cmiel kuhlmann ball space source
- **Status**: [NOT STARTED]
- **Task Type**: general
- **Topic**: literature
- **Dependencies**: None

**Description**: Acquire and ingest the Cmiel-Kuhlmann-Kuhlmann ball-space paper into the literature corpus, which currently has no copy of it.

Measured gap (verify rather than trust): the manuscript's def:frame carries a footnote citing \cite{Cmiel2021} for the claim that the nonempty fibers and segments form a BALL SPACE, and that Saturation is the downward-directed-intersection condition S_1^d of that hierarchy -- the nest condition S_1 with a directed system of balls in place of a nest. That citation has no local backing document: no entry matching Kuhlmann, ball space, spherically complete or ultrametric appears in ~/Projects/Literature/index.json or in specs/literature-index.json, and a filename search across ~/Projects/Literature/ returns nothing.

Why this matters rather than being bookkeeping. Research on the S1-versus-directedness question had to proceed without the primary source and was able to settle only part of it: S_1 provably suffices for the step lemma over every history with a countable domain (covering Z-time and Q-time), while directedness can only be forced over a non-archimedean duration type with an omega_1-coinitial positive cone. The converse direction S_1 -> S_1^d remains open, and the manuscript has already withdrawn its earlier "strictly stronger" wording in favour of "at least as strong as", so the strictness question is live rather than settled. Both the open direction and the ball-space framing route through the cited hierarchy, and neither can be grounded against the source while the source is absent. Note also that Mathlib has no spherical-completeness API at all, so there is no secondary formal reference to fall back on.

Scope: locate the paper (Cmiel, Kuhlmann and Kuhlmann, ball spaces; the manuscript's own bibliography entry is the starting point for exact title and venue), then run /literature to convert and index it so it is discoverable by future --lit dispatches. Record in the sub-index what the hierarchy's S_1 and S_1^d conditions are as the source states them, so later work can check the project's usage against the source's own definitions rather than against paraphrase.

Out of scope: any Lean change, and any edit to the manuscript.

---

### 650. Define before use audit lean appendix
- **Status**: [RESEARCHING]
- **Task Type**: lean4
- **Topic**: reference-book
- **Dependencies**: Task 647, Task 648, Task 649

**Description**: Define-before-use audit of typst/chapters/ax-lean-appendix.typ (the back-matter appendix "Reading the Lean Formalization" of typst/BimodalReference.typ): go through the appendix in reading order, as it stands AFTER tasks 647, 648 and 649 have landed, and make sure that EVERY convention, notation, identifier, and piece of Lean syntax is stated before it is first used. This is an improvement pass over the finished appendix to catch whatever was missed along the way; it depends on 647, 648 and 649 and must not start before they complete.

METHOD (be as systematic as possible; no spot-checking).
(1) Build a first-use ledger. Walk the file top to bottom and record every item a newcomer to Lean would need explained, with the line of its FIRST USE and the line of its INTRODUCTION (or "none"). Item classes:
  (a) project notation: the four turnstile forms `Γ ⊢ φ`, `Γ ⊢[fc] φ`, `G |-! p`, `G |-![fc] p`, their context-free variants, and every formula/operator notation that appears in a snippet;
  (b) project identifiers: `FrameClass` and its four tags, `Axiom.minFrameClass`, `FrameClass.Sat`, `Context`, `TaskFrame`, `TaskModel`, `WorldHistory`, `TruthAt`, `Valid`, and every other project name a snippet or sentence relies on;
  (c) Lean surface syntax: `_` placeholders, anonymous-constructor brackets `⟨ ⟩`, leading-dot constructor shorthand such as `.Dense`, dot/field notation such as `p.box.imp p` and `d.height`, implicit `{x : T}` versus explicit `(x : T)` versus instance `[C α]` binders, `:=`, `|` match arms, `fun`/`=>`, `∀`/`→` in binder position, `Type`/`Prop`, the declaration keywords `def`/`theorem`/`example`/`inductive`/`structure`/`class`/`instance`/`abbrev`, `namespace`/`open`, attributes such as `@[reducible]`/`@[simp]`, `deriving`, `termination_by`, `noncomputable`, and every tactic name that appears;
  (d) the appendix's own presentation conventions: the `>` source-label line, excerpt versus didactic example, docstring omission, line re-breaking, and whatever Lean code environment task 649 introduces.
(2) Classify each ledger row: introduced-before-use (fine); used-before-introduced (a forward reference: move the introduction earlier, or add a one-clause gloss at first use plus a pointer to the full treatment); or never-introduced (add an introduction).
(3) Fix every non-fine row, preferring ONE canonical introduction per item placed at or before first use, with later uses pointing back by section reference rather than re-explaining.
Keep the full ledger in the task's report so the audit is checkable row by row.

KNOWN GAPS to seed the ledger (re-verify each against the file as it then stands; a gap that no longer reproduces is closed with a one-line note, never "fixed" anyway).
(i) The `[fc]` bracket in the turnstile table is never explained. State that the brackets are literal tokens of project-defined notation (declared in FormalSystem/ProofSystem/Derivation.lean and FormalSystem/ProofSystem/Derivable.lean, not built-in Lean syntax); that what goes between them is any term of type `FrameClass`, either a concrete tag such as `.Dense`, giving a derivation in that specific system, or a bound variable `fc`, giving a statement that holds in all four systems at once; that it is the Lean spelling of the subscripted turnstile of the paper's TM_d / TM_z / TM_r; that the bracket-free forms are exactly the `FrameClass.Base` instance, so `Γ ⊢ φ` and `Γ ⊢[.Base] φ` are the same type; and that the exclamation mark in `|-!` marks the `Prop`-valued `Derivable` twin. The sentence after the table currently covers only omission of the context.
(ii) `FrameClass` is first used in the `Derivable` excerpt in the Types/Props section before the reader has been told what it is. A paragraph there now explains that `fc` is a purely syntactic four-element tag selecting the axiom set, declared in `FormalSystem.ProofSystem` with no reference to frames, models, or truth, and given semantic meaning only later by `FrameClass.Sat` in the module `FormalSystem.Semantics.FrameClassValidity`. KEEP that clarification: a reader who rightly holds that semantics has no place in a syntactic definition must not be alarmed by the parameter's name. Then check that the four tags, their partial order (`Base` bottom, `Dense ≤ RTime`, `ZTime` incomparable with both), `Axiom.minFrameClass`, and `DerivationTree.lift` are each introduced once, systematically, before the later sections rely on them.
(iii) The leading-dot shorthand `.Dense` / `.Base`, and the variable-name switch between `Γ`/`φ` and `G`/`p` across the two notations, are used without comment.

CONSTRAINTS. Re-verify every Lean fact against live (non-Boneyard) source under FormalSystem/ before writing it. Every `#leansrc` excerpt stays verbatim up to whitespace, and every didactic example must compile with `lake env lean` against the current toolchain, per the file's header contract. Respect the Lean code environment and formatting decisions made by task 649 rather than reintroducing appendix-local formatting. Do not change what the appendix claims and do not widen its scope: this task adds and reorders introductions, glosses, and back-references only. No task-number references in the deliverable. Done means: the reference manual builds cleanly using the build invocation documented in typst/README.md, the element-placement lint (.claude/scripts/typst-element-lint.sh) reports no blocking findings on the file, and typst/SYNC-MAP.md carries a dated entry.

---

### 649. Systematic lean code environment reference manual
- **Status**: [COMPLETED]
- **Task Type**: typst
- **Topic**: reference-book
- **Dependencies**: Task 647, Task 648
- **Research**: [649_systematic_lean_code_environment_reference_manual/reports/01_lean-code-environment.md]
- **Plan**: [649_systematic_lean_code_environment_reference_manual/plans/01_lean-code-environment.md]
- **Summary**: [649_systematic_lean_code_environment_reference_manual/summaries/01_lean-code-environment-summary.md]

**Description**: Define one Typst environment for presenting Lean code in typst/template.typ and use it systematically throughout the Bimodal Reference Manual (typst/BimodalReference.typ and every file under typst/chapters/), so that every Lean code block is clear and is presented the same way. This is a formatting and structure task: it changes how code is displayed, never what the code or the prose says.

CURRENT STATE, to be re-measured before designing. Lean code blocks are bare triple-backtick raw blocks, optionally preceded by a separate #leansrc(module, name) call that prints a "> Module.name." source line. The two are unrelated elements, so nothing keeps the label on the same page as its code, nothing distinguishes a quoted source excerpt from an illustrative example, and the gap between label and code equals the gap between code and the next paragraph. The book-wide paragraph spacing of 0.55em is also the default block spacing, so a code block runs straight into the paragraph after it. The text width is about 343pt on A4 with 1.75in margins, which at the default raw size fits roughly 64 monospace columns, and blocks wider than that wrap mid-line: measured maxima are 78 columns in chapters/p2-decidability-practice.typ (the decide signature), 88 in chapters/p4-dual-verification.typ, 78 in chapters/p4-dataset-pipeline.typ (JSON) and 71 in chapters/ax-machine-appendix.typ (Python). Blocks live in ax-lean-appendix.typ (about fifteen), p2-decidability-practice.typ (two), p2-frame-classes.typ (one), p4-dual-verification.typ (one, inside an #example), plus one JSON block and one Python block. chapters/ax-lean-appendix.typ already carries FILE-LOCAL rules that solve these problems for that file only: 8pt block raw text (71 columns), unbreakable blocks with explicit 11pt spacing above and below, and a locally shadowed leansrc that is sticky to the block it introduces. Those local rules are the prototype, and the deliverable is to make them the book-wide standard and delete the local copies. template.typ also exports leanref(name) for inline identifiers, which no chapter uses: chapters write inline backticks instead.

DESIGN REQUIREMENTS.
(1) One environment, two declared kinds. A source excerpt carries its module and declaration name and renders the source line and the code as ONE unit that cannot be split across a page break, with the label visibly closer to its code than the code is to the surrounding text. A didactic example carries no source line and is visibly the same family of element. A call site states which kind it is, so a reader and a checker can tell a quotation of the live source from an illustration. Decide whether non-Lean listings (JSON, Python, shell) share the environment through a language parameter or get a sibling with the same geometry, and apply the decision consistently.
(2) Geometry set once, in the template. Font size chosen so that a stated column budget fits the text width, with that budget written down beside the definition. Spacing above and below in absolute units, because em inside a raw show rule is the code size and not the body size. Unbreakable by default with an explicit opt-out for a long listing. Correct behavior inside #example, #definition, #remark, figures and list items. Decide with a rendered comparison whether a left indent or a thin left rule improves the separation of code from prose. The template's stated aesthetic is austere, black-only body text with no background fills, so do not add fills or colored syntax highlighting without making that case explicitly with before-and-after renders.
(3) Line-length policy. Every Lean block in the manual fits the column budget with no wrapped line. Re-break long lines at whitespace only, in one consistent layout (for a declaration: name and parameters, then hypotheses, then conclusion), and never alter tokens. State the excerpt-fidelity policy once, in the template comment and in typst/README.md: verbatim up to whitespace, docstrings omitted.
(4) Inline Lean. Decide whether leanref stays. Either adopt it for a stated purpose or remove it from the template. Do not convert the manual's inline backticks wholesale, because Check 1 of scripts/typst-sync-check.sh resolves every single-line backtick span and must keep doing so.
(5) Compatibility. typst/FormalFoundations.typ imports leansrc and items from the same template and must still compile unchanged, so keep leansrc exported with its current signature, either as a thin wrapper over the new environment or as a deprecated alias. Every call site in the manual migrates to the new environment, and the file-local formatting rules in chapters/ax-lean-appendix.typ for raw blocks and leansrc are deleted once the template supplies them. That file's A.n section-numbering rules and its list and figure spacing rules are not part of this task unless they are promoted deliberately and applied book-wide. ORDERING. This task depends on tasks 647 and 648 and runs last of the three. Task 647 extends the Lean appendix and adds many new code blocks, so it lands first and its blocks are migrated here in the same pass as every other chapter. Task 648 edits typst/template.typ (the items environment, the thmbox font) and corrects prose around the decide block in chapters/p2-decidability-practice.typ, so it lands before this task touches the same files. Code-block presentation was removed from task 648 and belongs to this task alone.
(6) Enforcement. Extend scripts/typst-sync-check.sh or the element lint with a mechanical check, or add a small script wired in beside them, that fails on a bare triple-backtick block outside the environment in typst/chapters/, on a Lean block line over the column budget, and on a source-excerpt call whose module-qualified declaration does not resolve in live, non-Boneyard Lean source. Document the environment, its two kinds, the column budget and the fidelity policy in typst/README.md.

CONSTRAINTS. No change to the wording of prose, and no change to code tokens. No task numbers and no specs/ paths in any deliverable. All backticked spans, comments included, keep resolving under Check 1.

ACCEPTANCE. typst compile --root .. succeeds with zero errors for BOTH BimodalReference.typ and FormalFoundations.typ. scripts/typst-sync-check.sh PASS and the element lint PASS. The new check passes and is shown to fail on a deliberately planted violation of each kind. grep finds no bare fenced block in typst/chapters/ outside the environment. Every page containing a code block is rendered (pdftoppm to PNG) and inspected: no wrapped code line, no source label separated from its code, no code block touching the paragraph after it, consistent appearance across chapters. The summary includes before-and-after renders of one page per affected chapter.

---

### 618. Path category and conduche fibration
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: categorical-structure
- **Dependencies**: Task 563, Task 564, Task 616

**Description**: Formalize the path category `Path(F)` and prove `cor:path-fibration`: the length functor `len : Path(F) -> BD+` is a discrete Conduche fibration whose associated presheaf is `Beh(F)`, together with the `D = Z` clause identifying `Path(F)` as the free category on the graph `(W, =>_1)`.

DELIVER:
- `def:conduche`'s notions: a discrete Conduche fibration `P : E -> BD+` (every morphism `e` and every factorization `P(e) = x + y` admits a unique pair `e1 : A -> C`, `e2 : C -> B` with `e = e2 . e1`, `P(e1) = x`, `P(e2) = y`); the associated presheaf of such a fibration; the associated category of a sheaf on `Int(D)`; and the length functor.
- `def:path-category`'s `Path(F)`: the associated category of `Beh(F)`, whose objects the Germs clause identifies with the world states and whose morphisms `w -> u` of length `l` are the sections `tau` in `Beh(F)(l)` with `tau(0) = w` and `tau(l) = u`, composing by gluing with the germs as identities.
- `cor:path-fibration` proper. Note the paper's proof establishes something sharper than the equivalence alone delivers: the associated presheaf of `len` is EQUAL to `Beh(F)`, not merely naturally isomorphic to it, because restriction along `Tr p` is literally the middle factor of the unique factorization. Formalize the equality, and say in the docstring why it is available.
- The `D = Z` clause: iterating Compositionality identifies `=>_n` for positive `n` with the `n`-fold composite of `=>_1`, and `=>_0` is the identity by `lem:nullity` and Limit, so a function on `[0, l]` is a convex history exactly when it is a path of length `l` in `(W, =>_1)`, gluing is concatenation, and `Path(F)` is the free category on that graph.

HARD SCOPE LIMIT. `fact:conduche-equivalence` -- Johnstone's general equivalence between the sheaves on `Int(D)` and the discrete Conduche fibrations over `BD+` -- is stated in the paper as a CITED FACT (Johnstone, Prop. 3.6; Schultz, Spivak, and Vasilakopoulou, Thm. A.2.1) and is not proved there. Do NOT set out to formalize Johnstone's theorem in general. Formalize the instance: build `Path(F)` directly and prove the fibration property for it. Record in the module docstring that the general equivalence is external and cited, so a later reader does not mistake the instance for the theorem. If a phase discovers the general proof is cheap at this site, that is a finding to report, not a licence to expand scope mid-task.

WHY IT IS WORTH DOING. The `D = Z` clause is the payoff a reader can hold onto: it says the whole categorical packaging, over the discrete temporal order, is the free category on the one-step task graph. It is also the clause most likely to connect to existing work here, since `FormalSystem/Semantics/IntTransfer.lean` already carries the adjacency characterization of `H_F` over `Z`; reuse that reasoning rather than re-deriving it.

PAPER ANCHORS. `def:conduche`, `def:path-category`, `fact:conduche-equivalence`, and `cor:path-fibration` in /home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex, all COMMENTED OUT inside the "SECTION CUT" block holding `app:Structure` -- read them there.

DEPENDENCIES. Task 563 (interval site and behavior presheaf), task 564 (the Sheaf clause, since composition in `Path(F)` IS gluing), and the twisted-arrow task, which supplies the factorization-linearity the fibration property leans on. This is the last and largest item on the categorical front; it should not be started before those land.

CONSTRAINTS. `lake build FormalSystem` green with no new sorry at the end of every phase.

Reconciliation note (task 629): unrelated mathematics with no dependency on the publication refactor programme's schedule (no edge added). Adopt task 636's citation form (`* [Author, *Title*][key]` against the root references.bib) once it lands, or migrate to it if this task is drafted first.

CONVENTION NOTE (2026-09-21). Task 636 has landed: write ## References in the normal form of docs/development/REFERENCE_NORMAL_FORM.md, each key resolving in the root references.bib (typst/bibliography.bib no longer exists). The language-extension files are now under FormalSystem/{Plus,Minus,Star}Language/ with flat FormalSystem.{X}Language namespaces (task 634).

FORWARDED APPENDIX ITEM (2026-09-24), from specs/624_translation_product_task_semantics_visibility/reports/01_translation-product-visibility.md section 2.4 ("Categorical reading -- posed, not settled"), which names this task as the recipient. The translation product of a task frame F -- states W x D, same duration group D, (w,s) =>_x (v,t) iff w =>_x v and t = s + x -- now lives in FormalSystem/Semantics/Frames/TranslationProduct.lean (definitions prodRel, FrameOver.translationProduct, liftH, projH; see also FormalSystem/Semantics/HistoryMorphism.lean for the morphism notion). The report observes that the morphisms of Path(prodFrame F) from (w,d) to (v,e) of length l are exactly the sections tau in Beh(F)(l) from w to v with e = d + l -- the description of the pullback of len : Path(F) -> BD+ along the functor (D, <=) -> BD+ sending the poset arrow d <= e to the duration e - d. Three questions to POSE, none of them settled and none needed by that report: (a) is Path(prodFrame F) the pullback of len along (D, <=) -> BD+ on the nose, with objects W x D, arrows as above, and the projection Path(prodFrame F) -> Path(F) as the pullback leg? (b) is len restricted to the pullback the "height" functor to (D, <=), and does cor:path-fibration's discrete Conduche property transfer to it? (c) do liftH / projH -- unique lifts of total histories -- express that the pullback along a POSET is a discrete fibration over D? SCOPE: this is an APPENDIX ITEM, NOT A SCOPE EXPANSION. It is to be taken up only once Path(F) itself exists, consistent with this task's existing HARD SCOPE LIMIT; the product's path category is then the natural test case for the pullback reading. Nothing in this task's current phases depends on it.

---

### 617. Reflection clause converse frame naturality
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: categorical-structure
- **Dependencies**: Task 563

**Description**: Prove `app:presheaf-dictionary`'s Reflection clause: reflection is a natural isomorphism `Beh(F) iso Beh(F-) . ref` between the behavior presheaf of a task frame and that of its converse frame, precomposed with the reflection automorphism of the interval category.

DELIVER, following `def:behavior-presheaf` and the Reflection paragraph of `app:presheaf-dictionary`'s proof:
- The reflection of a section: `tau^r (z) = tau(l - z)` on `[0, l]`.
- The converse frame `F- = (W, D, =>-)` with `w =>-_x u` iff `w =>_{-x} u`.
- The reflection automorphism `ref` of `Int(D)`: involutive, fixing objects, sending `Tr p : l' -> l` to `Tr (l - p - l') : l' -> l`, thereby interchanging left and right restrictions. Prove it preserves composition, fixes identities, and is its own inverse.
- That `tau^r` lies in `Beh(F-)(l)` whenever `tau` lies in `Beh(F)(l)`, naturality in the translations, and that each component is a bijection, using `(F-)- = F` and `(tau^r)^r = tau`.

THE POINT OF THE CLAUSE, which belongs in the module docstring rather than being left implicit in the proof terms: this natural isomorphism is what underlies the soundness of the time reflection metarule `TR` (`thm:TR-valid` in the paper). The reflection convention on the task relation supplies the involution by definition rather than by assumption, which is why the clause costs so little. Along with the Determinism clause of task 567, this is one of the few places where the categorical packaging says something about the logic rather than merely restating the semantics.

REUSE, NOT REBUILD. This repository already carries time-reflection and converse machinery -- `FormalSystem/Semantics/TruthTransport.lean` and the `reflectTime` vocabulary adopted in the TD->TR rename, with the `swapUS`/`swapMinus` families still under review in task 608. Survey what exists before defining a second converse-frame construction. If the existing API already yields the converse frame, this task consumes it; if not, say in the docstring why a separate one was needed. A duplicate converse frame is a failure of this task, not a side effect of it.

PAPER ANCHOR. The Reflection clauses of `def:behavior-presheaf` and `app:presheaf-dictionary` in /home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex, both COMMENTED OUT inside the "SECTION CUT" block holding `app:Structure` -- read them there.

DEPENDENCY. Task 563, for `Beh(F)` and `Int(D)`.

CONSTRAINTS. `lake build FormalSystem` green with no new sorry at the end of every phase.

Reconciliation note (task 629): unrelated mathematics with no dependency on the publication refactor programme's schedule (no edge added). Adopt task 636's citation form (`* [Author, *Title*][key]` against the root references.bib) once it lands, or migrate to it if this task is drafted first.

CONVENTION NOTE (2026-09-21). Task 636 has landed: write ## References in the normal form of docs/development/REFERENCE_NORMAL_FORM.md, each key resolving in the root references.bib (typst/bibliography.bib no longer exists). The language-extension files are now under FormalSystem/{Plus,Minus,Star}Language/ with flat FormalSystem.{X}Language namespaces (task 634).

---

### 616. Duration monoid twisted arrow interval site
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: categorical-structure
- **Dependencies**: Task 563

**Description**: Formalize the duration monoid `BD+`, its twisted-arrow category, and `lem:interval-twisted-arrow`: `BD+` is factorization-linear and `Tw(BD+)` is isomorphic to the interval category `Int(D)` by an isomorphism carrying the Johnstone coverage of the one to that of the other.

WHY THIS IS NOW ITS OWN TASK. Task 563 carries this as "OPTIONAL, only if cheap". It is being promoted because the paper has changed around it: the presheaf appendix `app:Structure` was cut from /home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex, and the main-body conclusion is being rewritten to assert the Johnstone route in prose -- interval site, sheaf condition, discrete Conduche fibrations, path category -- with the supporting results promised elsewhere. This repository is where "elsewhere" is meant to be. The lemma is no longer an optional extra on the interval-site task; it is the load-bearing step behind a claim the paper now makes in its body with no appendix under it.

DELIVER:
- The duration monoid `BD+`: the one-object category whose morphisms are the durations in the positive cone, composing by addition with identity 0.
- The factorization category `Fact(l)` of a duration: objects the factorizations `l = x + y` with `x, y` positive, morphisms `(x, y) -> (x', y')` the durations `z` with `z + x = x'` and `y = z + y'`.
- Factorization-linearity: each factorization category is a linear preorder -- any two objects related by at most one morphism, and by at least one in one direction or the other.
- The twisted-arrow category `Tw(BD+)`: objects the durations, morphisms `l' -> l` the pairs `(p, q)` of positive durations with `p + l' + q = l`, composing `(p, q) . (p', q') = (p + p', q' + q)` with identities `(0, 0)`.
- The Johnstone coverage on both `Tw(BD+)` and `Int(D)`, and the coverage-preserving isomorphism `Int(D) iso Tw(BD+)`.

SHAPE OF THE WORK. This is pure order algebra over the positive cone of a linearly ordered abelian group. It needs no task frame, no world states, and no history theory -- only `TemporalOrder.lean`'s carrier and its order and group structure. That makes it the most self-contained item on the categorical front and a reasonable one to land early.

DESIGN DECISION TO RECORD EXPLICITLY, not to settle by accident in the first proof: whether these categories are stated as concrete Lean structures with hand-rolled composition lemmas, or as `Mathlib.CategoryTheory.Category` instances. `grep -rl CategoryTheory FormalSystem/` currently returns exactly one file, `FormalSystem/Boneyard/RetiredTactics/AesopRuleSet.lean`, so the live tree imports no category theory at all. Introducing it is a real dependency decision for the whole categorical cluster (tasks 563-567 included) and should be made once, here, and written into the module docstring with its reasoning -- not made implicitly by whichever task gets there first. The concrete route is cheaper and keeps the import surface flat; the Mathlib route is what makes `fact:conduche-equivalence` and the free-category statement expressible without re-inventing vocabulary. State the trade-off, pick one, say why.

PAPER ANCHORS. `def:interval-site`, `def:twisted-arrow`, and `lem:interval-twisted-arrow` in /home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex. NOTE that all three are COMMENTED OUT in the current source, inside the "SECTION CUT" block that holds `app:Structure` in full -- read them there rather than concluding the paper never had them. Docstrings must cite the labels. Read also /home/benjamin/Philosophy/Papers/PossibleWorlds/specs/111_verify_interval_twisted_arrow_lemma/reports/01_verify-twisted-arrow-lemma.md, where the lemma was verified and its proof rebuilt on that repository's side; that report is the statement of record, ahead of any older phrasing.

DEPENDENCY. Task 563, which introduces `Int(D)`. If 563 lands the optional twisted-arrow material after all, this task narrows to the factorization-linearity proof and the coverage transport rather than disappearing -- reconcile at plan time rather than assuming disjointness.

CONSTRAINTS. `lake build FormalSystem` green with no new sorry at the end of every phase.

Reconciliation note (task 629): unrelated mathematics with no dependency on the publication refactor programme's schedule (no edge added). Adopt task 636's citation form (`* [Author, *Title*][key]` against the root references.bib) once it lands, or migrate to it if this task is drafted first.

POST-RELOCATION NOTE (2026-09-21). Task 630 moved the archive to the repository root, so the one CategoryTheory file is Boneyard/RetiredTactics/AesopRuleSet.lean and 'grep -rl CategoryTheory FormalSystem/' now returns NOTHING (grep Boneyard/ to find it). The premise stands: no live module imports Mathlib's CategoryTheory. New files write ## References in the normal form of docs/development/REFERENCE_NORMAL_FORM.md, keys resolving in the root references.bib (task 636 has landed).

---

### 604. Support zstd compressed jsonl datasets
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: dataset-enhancement
- **Dependencies**: Task 631, Task 632

**Description**: Add zstd-compressed .jsonl dataset support across the data pipeline so large datasets can live on disk as .jsonl.zst. data/bmlogic-c7.jsonl was compressed to data/bmlogic-c7.jsonl.zst to reclaim disk space (17G -> 153M; lossless, sha256 of decompressed stream 4079d0a6b4310d417ae91999abcd581e5ebd9dacd4e9f3c33d1d9b3aa55f2704 verified identical; restore with `zstd -d data/bmlogic-c7.jsonl.zst`). Consumers that hardcode data/bmlogic-c7.jsonl are currently broken. Research first: (1) inventory every reader/writer of .jsonl datasets -- Python scripts (validate_benchmark.py, validate_datasets.py, verify_benchmark.py, migrate_schema_v2.py, standardize_metadata.py, curate_benchmark.py, curate_very_hard_plus.py, finalize_benchmark.py, validate_c5_dataset.py), shell scripts (run_dataset_generation.sh, export-training-data.sh, typst-machine-appendix.sh, typst-sync-check.sh), Lean executables under FormalSystem/Automation/*Main.lean, lakefile.lean, Tests/BimodalTest/Automation/ProofFirstTests.lean, data/hf-dataset/ tooling, and path fields in data/*_metadata.json; (2) choose the Python approach, e.g. one shared open_dataset() helper transparently handling .jsonl and .jsonl.zst (zstandard package vs zstd subprocess) and how that dependency is provided; (3) decide how Lean executables handle compressed data given Lean has no native zstd (IO.Process pipe through zstd, or shell-wrapper streaming via stdin/stdout) and whether generators should write .jsonl.zst directly; (4) reconcile with the Hugging Face Hub storage migration (task 257). Then implement, keeping plain .jsonl working, and verify every updated consumer against data/bmlogic-c7.jsonl.zst

Reconciliation note (task 629): depends on task 631 (deliverable hygiene, deletes migrate_schema_v2.py and standardize_metadata.py -- drop these two from this task's own script inventory step) and on task 632 (BimodalTools split -- write the Lean-executable inventory step against BimodalTools.* paths directly, avoiding a second rewrite).

POST-RELOCATION NOTE (2026-09-21). Dependency 632 is complete. The Lean executables this task names as 'FormalSystem/Automation/*Main.lean' are now BimodalTools/*Main.lean (root-level lean_lib BimodalTools, outside defaultTargets; lake exe target names unchanged), and Tests/BimodalTest/Automation/ProofFirstTests.lean is now Tests/BimodalToolsTest/ProofFirstTests.lean. Build and test with lake build BimodalTools and lake build BimodalToolsTest. typst-sync-check.sh now scans two Lean source roots (FormalSystem/, BimodalTools/).

---

### 570. C3 completeness question
- **Status**: [NOT STARTED]
- **Task Type**: formal
- **Topic**: metalogic
- **Dependencies**: Task 568

**Description**: OPEN RESEARCH QUESTION, not an implementation task. Is the logic of C3 -- the domain-restricted consequence relation -- equal to Burgess-Xu without the unboundedness assumption, plus S5?

WHAT IS ALREADY ESTABLISHED (`specs/553_decide_convex_history_layer_collapse/reports/01_convex-correlate-and-consequence.md` section 4.2) is the CONTAINMENT: C3 includes classical propositional logic, S5 for box, the whole Burgess-Xu monotonicity, enrichment, accumulation, absorption and linearity block, and `modal_future`; and C3 excludes seriality and the uniformity layer. The study explicitly DECLINES the completeness claim. Establishing or refuting it is this task, and the honest starting position is that it is open.

THE FIRST OBSTACLE, which any canonical-model construction will hit immediately (`specs/553_decide_convex_history_layer_collapse/reports/01_convex-correlate-and-consequence.md` section 4.3): the germ constraint. Every C3-validity holds at every one-point germ, and `box (phi U psi)` and `box (phi S psi)` are C3-UNSATISFIABLE for every `phi` and `psi`. That is stronger than the loss of seriality: it constrains what any axiomatization of C3 could look like, since no boxed binary-tense formula can ever be a theorem. A canonical model for C3 must either accommodate germs in the box range or the box range must be cut back first.

SEQUENCING. Do not start before the box-range design choice recorded in the C3/C4 library task is settled by the author. If the box range is cut back, this task is about a DIFFERENT logic and this description must be revised before any work begins.

LITERATURE. Burgess 1982 and Xu 1988 axiomatize `U`/`S` over an arbitrary linear order BEFORE unboundedness is added, which is exactly the setting C3 lives in. Check the Literature/ index for both before starting; acquire them if absent.

---

### 567. Determinism clause and separatedness asymmetry
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: categorical-structure
- **Dependencies**: Task 563
- **Research**: [567_determinism_clause_and_separatedness_asymmetry/reports/01_retiming-invariance-definability-findings.md]

**Description**: Prove `app:presheaf-dictionary`'s Determinism clause -- `F` deterministic iff every restriction map of `Beh(F)` is injective -- and connect it to `states_eq_of_deterministic` in `FormalSystem/Semantics/PlusLanguage/PlusDeterminism.lean`.

THE DELIVERABLE THAT MAKES THIS WORTH DOING is not the dictionary row but the asymmetry the study found (`specs/553_decide_convex_history_layer_collapse/reports/01_convex-correlate-and-consequence.md` section 5.2.1): SEPARATEDNESS of `Beh(F)` is STRICTLY STRONGER than the validity of `Determined` on `F`. The witness for the failure of the converse is the drift frame already living in `FormalSystem/Metalogic/Independence/` -- this repository's own countermodel, not a new construction. State the result as a THEOREM PAIR (one direction proved, the converse refuted by that countermodel), not as a single clause.

WHY IT MATTERS. This is one of only two results the study found running FROM this repository's semantics TO the paper's category theory rather than the reverse. That direction is the point of the categorical front, not a by-product of it.

OPEN QUESTION TO POSE, NOT TO SETTLE: does any `BL-star` formula characterize separatedness of `Beh(F)` exactly? `PlusDeterminism.lean`'s own choice-dependence note suggests it does not. Record the question in the module docstring; do not spend phases attacking it.

DEPENDENCY NOTE, NOW DISCHARGED. The language-name sync has landed: the file is `FormalSystem/Semantics/PlusLanguage/PlusDeterminism.lean`.

CONSTRAINTS. lake build FormalSystem must be green with no new sorry at the end of every phase.

Reconciliation note (task 629): unrelated mathematics with no dependency on the publication refactor programme's schedule (no edge added). Adopt task 636's citation form (`* [Author, *Title*][key]` against the root references.bib) once it lands, or migrate to it if this task is drafted first.

POST-RELOCATION NOTE (2026-09-21). The file moved again: task 634 merged Syntax/ and Semantics/PlusLanguage/ into one directory, so it is now FormalSystem/PlusLanguage/PlusDeterminism.lean, and states_eq_of_deterministic moved from namespace FormalSystem.Semantics to the flat namespace FormalSystem.PlusLanguage. Import FormalSystem.PlusLanguage.PlusDeterminism. New files write ## References in the normal form of docs/development/REFERENCE_NORMAL_FORM.md, keys resolving in the root references.bib (task 636 has landed).

---

### 566. Possible worlds clause hf as limit
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: categorical-structure
- **Dependencies**: Task 563, Task 565

**Description**: Prove `app:presheaf-dictionary`'s Possible Worlds clause: `H_F iso lim Beh(F)(2x)` along the central restrictions.

EXISTING HOOK, to be used rather than rebuilt: over `D = Z` this connects to `FrameOver.mem_HF_iff_adjacent`, already proved in `FormalSystem/Semantics/IntTransfer.lean`. Do not re-derive the adjacency argument.

DEPENDS on the interval-site/presheaf cluster and on the Totality clause, since the limit construction consumes Totality.

CONSTRAINTS. lake build FormalSystem must be green with no new sorry at the end of every phase. Background: `specs/553_decide_convex_history_layer_collapse/reports/01_convex-correlate-and-consequence.md` section 5.1.

Reconciliation note (task 629): unrelated mathematics with no dependency on the publication refactor programme's schedule (no edge added). Adopt task 636's citation form (`* [Author, *Title*][key]` against the root references.bib) once it lands, or migrate to it if this task is drafted first.

CONVENTION NOTE (2026-09-21). Task 636 has landed: write ## References in the normal form of docs/development/REFERENCE_NORMAL_FORM.md, each key resolving in the root references.bib (typst/bibliography.bib no longer exists). The language-extension files are now under FormalSystem/{Plus,Minus,Star}Language/ with flat FormalSystem.{X}Language namespaces (task 634).

---

### 565. Totality and directed gluing from extension theorem
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: categorical-structure
- **Dependencies**: Task 563

**Description**: Prove `app:presheaf-dictionary`'s Totality and Directed Gluing clauses. Both are WRAPPERS on `thm:extension`, which is fully proved in this repository under `FormalSystem/Semantics/Extension/`: translate a section to its subinterval, extend to a possible world, restrict.

WHY THIS MATTERS OUT OF PROPORTION TO ITS SIZE. It is the task that demonstrates the Extension Theorem was the presheaf appendix's analytic content all along -- the strongest structural claim the study makes about the relationship between this repository and `app:Structure`, and the clearest single piece of evidence that the categorical material was already present here under non-categorical names. Small (1-2 phases), high explanatory value.

RECORD explicitly, rather than leaving it implicit in the proof terms, which clauses are choice-free: Sheaf is; Directed Gluing is NOT.

HARD CONSTRAINT. Leave `PartialHistory` and the Extension Theorem themselves untouched. This task CONSUMES `thm:extension`; it does not restate, strengthen or reprove it. lake build FormalSystem must be green with no new sorry at the end of every phase.

Background: `specs/553_decide_convex_history_layer_collapse/reports/01_convex-correlate-and-consequence.md` section 5.1.

Reconciliation note (task 629): unrelated mathematics with no dependency on the publication refactor programme's schedule (no edge added). Adopt task 636's citation form (`* [Author, *Title*][key]` against the root references.bib) once it lands, or migrate to it if this task is drafted first.

CONVENTION NOTE (2026-09-21). Task 636 has landed: write ## References in the normal form of docs/development/REFERENCE_NORMAL_FORM.md, each key resolving in the root references.bib (typst/bibliography.bib no longer exists). The language-extension files are now under FormalSystem/{Plus,Minus,Star}Language/ with flat FormalSystem.{X}Language namespaces (task 634).

---

### 564. Sheaf clause gluing and starpasting generalization
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: categorical-structure
- **Dependencies**: Task 563
- **Research**: [564_sheaf_clause_gluing_and_starpasting_generalization/reports/01_finite-vs-directed-gluing-findings.md]

**Description**: Prove `app:gluing` for two interval sections whose germs agree at the seam, plus the two restriction identities and uniqueness.

THE COMPOSITION STEP IS ALREADY PROVED as `glue_seam` in `specs/553_decide_convex_history_layer_collapse/probes/04_presheaf-skeleton.lean`. The remainder is assembling the glued section by cases and applying `ShiftSet.wh_ext`.

THE DE-DUPLICATION THAT MAKES THIS WORTH DOING, and which is part of the deliverable rather than optional: generalize `PlusPasting`s `paste` off its totality hypothesis. `FormalSystem/Semantics/PlusLanguage/PlusPasting.lean`'s `paste_rel_le_lt` is the SAME ARGUMENT as the interval-site gluing step. The study established that the general-convex and interval-site versions share one proof and should not be written twice; delivering the Sheaf clause while leaving `paste` untouched creates exactly the duplication this task exists to prevent.

RECORD in the module docstring which dictionary clauses are choice-free. Sheaf is.

DEPENDENCY NOTE, NOW DISCHARGED. This formerly waited on the language-name sync. That rename has landed: the file is `FormalSystem/Semantics/PlusLanguage/PlusPasting.lean` and `paste_rel_le_lt` lives there in namespace `FormalSystem.Semantics`. Nothing blocks the generalization on naming grounds any longer.

CONSTRAINTS. lake build FormalSystem must be green with no new sorry at the end of every phase. Background: `specs/553_decide_convex_history_layer_collapse/reports/01_convex-correlate-and-consequence.md` sections 5.1 and 5.2.

Reconciliation note (task 629): unrelated mathematics with no dependency on the publication refactor programme's schedule (no edge added). Adopt task 636's citation form (`* [Author, *Title*][key]` against the root references.bib) once it lands, or migrate to it if this task is drafted first.

POST-RELOCATION NOTE (2026-09-21). The file moved again: task 634 merged Syntax/ and Semantics/PlusLanguage/ into one directory, so it is now FormalSystem/PlusLanguage/PlusPasting.lean, and its declarations moved from namespace FormalSystem.Semantics to the flat namespace FormalSystem.PlusLanguage (241 declarations across 17 files were renamed). Import FormalSystem.PlusLanguage.PlusPasting. New files write ## References in the normal form of docs/development/REFERENCE_NORMAL_FORM.md, keys resolving in the root references.bib (task 636 has landed).

---

### 563. Formalize interval site and behavior presheaf
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: categorical-structure
- **Dependencies**: None

**Description**: Promote the presheaf skeleton into the library. DELIVER: the section type `Beh F l` (the convex histories with domain exactly [0, l]), restriction along the translation `Tr p`, presheaf functoriality (`restrict_id`, `restrict_comp`), and the Germs clause `Beh(F)(0) iso W`.

ALL FOUR ARE ALREADY PROVED, sorry-free, against the live tree in roughly 200 lines in `specs/553_decide_convex_history_layer_collapse/probes/04_presheaf-skeleton.lean`. The work here is siting, naming and docstrings -- not discovery. Read that probe before planning.

SITING. A new `FormalSystem/Semantics/Presheaf/` cluster, placed BELOW `Truth.lean` in the module layering so that the existing `assert_not_exists` on the proof system still holds. Two repo conventions apply: a directory `X/` has exactly one sibling aggregator `X.lean`, and `scripts/check-module-invariants.sh` C24 requires every module to stay in the root closure.

PAPER ANCHORS: `app:Structure`'s `def:interval-site` and `def:behavior-presheaf` in /home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex. Docstrings must cite those labels. NOTE that `app:Structure` carries a `% TODO: review in full` marker in the LaTeX source, so this task tracks material the author has not finished reviewing -- flag that in the module docstring rather than silently depending on it.

OPTIONAL, only if cheap: `BD+` and the twisted-arrow category with `lem:interval-twisted-arrow`. That lemma is pure order algebra and needs no frame.

WHY THIS FIRST. It is the cheapest task on the categorical front -- the theorems already exist -- and it gates the Sheaf, Totality/Directed Gluing, Possible Worlds and Determinism clauses. Background and the full `app:Structure`-to-tree dictionary: `specs/553_decide_convex_history_layer_collapse/reports/01_convex-correlate-and-consequence.md` section 5.1.

CONSTRAINTS. lake build FormalSystem must be green with no new sorry at the end of every phase.

Reconciliation note (task 629): unrelated mathematics with no dependency on the publication refactor programme's schedule (no edge added). Adopt task 636's citation form (`* [Author, *Title*][key]` against the root references.bib) once it lands, or migrate to it if this task is drafted first.

CONVENTION NOTE (2026-09-21). Task 636 has landed: write ## References in the normal form of docs/development/REFERENCE_NORMAL_FORM.md, each key resolving in the root references.bib (typst/bibliography.bib no longer exists). The language-extension files are now under FormalSystem/{Plus,Minus,Star}Language/ with flat FormalSystem.{X}Language namespaces (task 634).

---

### 559. Nondeterministic canonical model tm star completeness
- **Status**: [RESEARCHED]
- **Task Type**: lean4
- **Topic**: metalogic
- **Dependencies**: None
- **Research**: [559_nondeterministic_canonical_model_tm_star_completeness/reports/04_semantics-first-task-frames.md]

**Description**: RESEARCH TASK, verdict-first -- reports and sorry-free probe files under this task's directory only; no changes to FormalSystem/ or Tests/. Run further rounds with `/orchestrate 559 --research --lit`.

AIM (revised 2026-09-18; this paragraph governs everything below). Present the most natural proof system containing the stability modal ⊡ and prove it sound and COMPLETE over the paper's task semantics, at Base and at each extension class (Dense, ZTime, RTime). The logic does NOT need to express state recurrence. The SEMANTICS IS FIXED: task frames with all four frame axioms (Compositionality, Seriality, Limit, Saturation), H_F = ALL total histories, □ over H_F, ⊡ over the histories through the current world state at the current time (PlusTruthAt). Everything else is open to change: new axiom schemata, new inference rules, and extensions of the OBJECT LANGUAGE where completeness takes them. Completeness of the CURRENT PlusAxiom set was never the goal and is refuted; do not re-investigate it. A bundled semantics (□/⊡ over a chosen paste- and shift-closed bundle) is a DIFFERENT semantics: admissible only as an intermediate tool (soundness vehicle, stepping stone), never as the result (see USER DECISION).

ESTABLISHED -- read reports 01-04 and probes 01-04 of this task, and the reports of 624, 625 and 628, first; do not redo. Labels: compiled-mirror = sorry-free Mathlib-only probe mirroring PlusTruthAt (probes 01-03 over ℤ, probe 04 over any ordered abelian group D); compiled-live = `lake env lean` against the repository; paper; UNVERIFIED; recalled.
(a) Current TM⁺ is incomplete at ZTime: LC⁺ := (⟐Xp ∧ ⊡G(p → ⟐Xp)) → ⟐Gp is ℤ-valid and refuted in a paste-closed coarsened-state model (report 01, compiled-mirror). This answers negatively the manuscript's commented-out remark (3832) that TM⁺ completeness "remains open".
(b) Incomplete at Base: BLC := (⟐Fp ∧ ⊡G(p → ⟐Fp)) → ⟐(Fp ∧ G(p → Fp)) is Base-valid by Zorn + `extension` (paper, report 02 §2) and refuted in a compiled coarsened countermodel on ℤ-frame `eR` (Saturation on paper). Dense/RTime non-derivability needs a dense saturated countermodel: 624 removes the Limit obligation (product/colourClock); Saturation of the ordinal-budget colour structure and a .Dense form of paste-closed soundness remain UNVERIFIED (624 §4.1).
(c) Mechanism, restated natively (report 04 §4.1, paper): for a translation- and paste-closed bundle H, the all-histories set of the frame read off H is the topological closure of H in W^D. All-histories semantics = closed bundles; PS/US give paste-closure, MF translation-closure, nothing gives closedness. Saturation supplies the Extension property at infinite W; it is idle at ZTime (oriented-forest argument, report 03 §1.2, paper). Whether Saturation adds any L⁺-validity at the other classes is OPEN.
(d) Soundness vehicle for non-derivability: paste-closed coarsened-state models (Metalogic/Independence/CoarsenedModels.lean plus PS/US arms); compatible with the translation product (624: liftK, c_invariance, pasteClosed_liftK, c_refuted_lift, compiled-live).
(e) Naming. 535's time-naming candidate is unsound (□ sees every shift). Sound and demoted to proof devices: Gabbay IRR (irr_sound) and the ⊡-local clock rule (clock_irr_sound), compiled-mirror over ℤ. Naming rule of record: the STATE-naming rule "from ⊢ (q ∧ ⋀_ψ NOM_q(ψ)) → φ, q fresh, infer ⊢ φ", NOM_q(ψ) := (⟐ψ → □(q → ⟐ψ)) ∧ (⊡ψ → □(q → ⊡ψ)), sound frame by frame at every D with no frame axiom (state_name_sound, compiled-mirror) and also on translation-closed bundles (paper), so it derives no LC_n. It needs no language extension.
(f) The bundled-vs-completion indistinguishability route is closed. All four landed completeness engines build deterministic, linear countermodels (⊡ = id) and none applies as is; states must not be MCSs (that forces Determined).
(g) What ⊡ is. ⊡-truth is a function of the present world state alone (stab_state_only, compiled-mirror at every D; landed as Semantics.stab_state_only). ⊡ is the manuscript's ⟨τ⟩_x modality, not Ockhamist historical necessity (that is ▷): HN fails for ⊡ (hn_stab_refuted, compiled-mirror; compiled-live on F3 := FrameOver.ofStep of the three-state sink relation, proposed name sinkFrame, 625 probe 01) and holds for the open-future modality over AgreeUpTo (hn_open_pure, hn_open_mixed, 625, compiled-live semantic form). FrameOver.rev (time reversal, all four axioms, rev_rev by rfl, agreeUpTo_rev) is compiled-live (625 probe 02). Hence the Reynolds-2003 engine does not transfer beyond its LC ingredient. Invariances: truth is preserved by surjective two-way bounded morphisms (tw_invariance, compiled-mirror ℤ) and by re-timing each history by an order automorphism (repar_invariance, compiled-mirror every D), so L⁺ is blind to durations.
(h) Translation product, 624 (compiled-live). F × D is a task frame at all six FrameOver fields and every class tag (prodFrame, prodFrame_sat; Saturation transfer prodRel_saturation and converse saturation_of_prodRel; Limit from ⇒₀ ⊆ id, prodRel_limit). Validity of L, L⁺ and L⋆ over a class equals validity over its recurrence-free members (validIn_iff_recurrenceFree, plusValidIn_iff_recurrenceFree, starValidIn_iff_recurrenceFree; star_invariance settles report 04 §3.3.3 for L⋆). Canonical frames may therefore be built clocked WLOG. Limit contributes no validity beyond reflexivity of the zero task (TD_zeroFix, zeroFix_limit_clocked, 624 probe 02, compiled-mirror). Any finite reflective serial compositional colour relation with ⇒₀ ⊆ id clocks to a task frame over any D (colourClock): frame axioms are NOT the obstacle at any class -- the truth lemma over ALL histories is. Frame-by-frame validity does NOT transfer to the product (frame_validity_not_reflected); the device never refutes anything F does not and is silent on closure, Saturation, and naming.
(i) Truth lemma, stated natively (report 04 §4.2, paper): with states = ⊡-theories and a translation-closed family 𝒞 of perfectly coherent chronicles, the truth lemma holds iff every trace in the closure of the canonical bundle is the state trace of a coherent chronicle. Failure mode: a trace postponing an inevitability ⊡Fα forever; cure by LC_n in the logic and progress measures carried in the state.
(j) Limit closure. LC_n := ⊡G≤ ⋀_{i<n}(⟐αᵢ → ⟐F⟐α_{i+1 mod n}) → ⟐G≤ ⋀_{i<n}(⟐αᵢ → F⟐α_{i+1 mod n}) is valid at ZTime for all n ≥ 1 and arbitrary αᵢ (lcN_valid_full, compiled-mirror via omega_chain) and at Base by Zorn + `extension` (paper, UNVERIFIED in Lean). LC_n is an instance of LC_m when n ∣ m; LC_1(p) is independent of current TM⁺ (paper); BLC ≈ LC_1. LCU (X-free until-form of Reynolds 2001's LC) is ZTime-only: semantic core compiled-mirror, formula level UNVERIFIED; invalid at Dense/RTime by a Zeno pattern (sketch, UNVERIFIED). The Dense/RTime until-form principle is unknown.
(k) Axiomatizability. ZTime validities are decidable (report 03 §1.3, paper; rests on recalled Rabin; finite model property not established). Base, Dense, RTime: r.e. status OPEN, obstruction located (tree-like preimages need a relative Saturation; MSO over ℝ undecidable, recalled).
(l) Language extensions, 628 (compiled-live). A state-identity test across two times of one history is the minimal resource making recurrence visible (one state register: recF_defines, bindRec_defines, transF_valid); state nominals, registers and propositional quantifiers are needed only to EXPRESS recurrence, which is not a goal. A NAME rule for state nominals gives the ⊡-existence lemma free in a named canonical model (paper) but does not touch closure of the canonical bundle; once nominals enter, class validity ≠ recurrence-free validity, so any WLOG-clocking must precede them. Whether ANY naming rule is needed for the nominal-free system stays OPEN.
(m) AA rule: forward-cone unravelling (aa_expand, cone_twoWay, compiled-mirror) is a ZTime proof device only; formula-level rule UNVERIFIED.

QUESTIONS FOR THE NEXT ROUND, in priority order, each with a verdict and machine-checked evidence wherever checkable.
(P1) AXIOMATIZABILITY FIRST. Are the ⊡-validities r.e. at Base, and at Dense/RTime? Bound this before any engine work: give a proof, a reduction to a held decidability/r.e. result, or a located obstruction. Say exactly what transfers from Gurevich-Shelah via held sources, and what the closure characterization (c) does to the question.
(P2) ZTIME TRUTH LEMMA for TM⁺_Z + LC_n + LCU + the state-naming rule. Design the replacement for Reynolds 2001's one-sided, rooted automaton: emergent histories are limits of splices in BOTH directions, formulas contain S, and there is no root. Target: a two-sided device (e.g. pure-past/pure-future separation with ⊡/□ leaves plus two runs anchored at a named point, or state-carried progress measures) making every closure trace of the clocked canonical bundle coherent (i); or locate the first formula shape where LC_n + LCU fail to force it. Use colourClock for the frame side.
(P3) ECONOMY. Does a finite subfamily of LC_n suffice (single-schema candidates), per class? Can the naming rule be dropped entirely -- assess the rule-free route of Di Maio-Zanardo only through held sources (not held: say so)?
(P4) LEAN CHECK of LC_n validity at Base (Zorn over partial histories + `extension`), as a sorry-free probe; ideally via a general "maximal non-erring partial history" lemma reusable by 560.
Bundled completeness is NOT to be researched unless P1 returns a NEGATIVE verdict (see USER DECISION).
BASELINES any candidate must meet: soundness over all task frames of the class, one lemma per new constructor; collapse to the deterministic completeness of 537 under Determined; both directions of conservativity over TM (forward_plus, plusDerivable_ofFormula_iff) re-checked. Settled and not to be reopened: class order (ZTime first, Base second, Dense/RTime last); frame-axiom obligations (h).

USER DECISION (2026-09-19): the Henkin-style (bundled) presentation is REJECTED as cheap -- it buys completeness by changing the semantics, as Henkin models do for second-order logic. The goal is completeness over the standard all-histories semantics. Bundles are to be revisited ONLY if it is PROVEN that no complete system exists for the standard semantics at a class, i.e. its ⊡-validities are not r.e. (P1 negative, with a proof, not a located obstruction). Incompleteness of the current TM⁺ (items a-b) does NOT count: it refutes one axiom set, not every r.e. system.

LITERATURE -- run with --lit. In the sub-index (specs/literature-index.json): reynolds_2001 (CTL*: LC, AA rule, automaton completeness proof); reynolds_2003_priors-ockhamist-logic-historical-necessity (infinite LC schema, IRR, hues and colours; extended abstract whose completeness proof is a SKETCH; OCR FORMULAS UNRELIABLE -- re-derive from prose, cross-check reynolds_2002); reynolds_2002_axioms_for_branching_time; emerson_and_halpern_-_1986_-_sometimes_and_not_never_revisited_on_branching_versus_linear_time_temporal_logic (fusion/suffix/limit closure); rumberg-zanardo-2019-transition-structures; thomason_1984 (§4: T×W, Kamp frames); thomason-1970-indeterminist-time; burgess_1982_i, burgess_1984_*, gabbay_1994_* (chronicles, S/U, IRR). Held in the global corpus and used by 628: blackburn_2002 ch. 7 (NAME/PASTE), Gabbay-Kurucz-Wolter-Zakharyaschev 2003. NOT YET ACQUIRED (specs/literature/SOURCES.md, newest rows): Reynolds 2005 PCTL*, Zanardo 1991 (bundled S/U completeness), Di Maio-Zanardo 1998 (rule-free T×W) -- high priority -- and Zanardo 1985, Zanardo 1996, von Kutschera 1997, Gurevich-Shelah 1985, Burgess 1980, Zanardo-Barcellan-Reynolds 1999, Kupferman-Pnueli-Vardi 2012. Use these only through what held sources say about them, state plainly where an argument depends on an unread paper, and never reconstruct their theorems from memory as if cited.

HARD CONSTRAINTS: never state a completeness theorem and discharge it with sorry; every proposed axiom or rule carries a sorry-free validity/soundness probe or the label UNVERIFIED; every literature claim is tied to a held source or labelled recalled; a precisely located obstruction (which frame axiom, which formula class, which step of which published proof fails to transfer) is a complete outcome for a round; do not begin implementation here; add no constructor to PlusAxiom or PlusDerivationTree. OUTPUT per round: a numbered report plus probes under this task's directory, a per-class table (candidate system, soundness status, completeness status, engine), and any follow-on task proposals. 560's scope stands as rescoped by report 02 (plus_incomplete_base : PlusValid blc ∧ ¬ PlusDerivable FrameClass.Base [] blc, ZTime as corollary); report only if a finding changes it.
COORDINATION NOTE (added later): a separate, certificate-side line now exists for the stability modal, aimed at a DECISION PROCEDURE with finite certificates rather than at a proof system: a gating decidability-provenance research task, a state-sharing witness-structure redesign (re-proving the histories characterization and redesigning box faithfulness), an agreement lemma over all walks of that structure, and a compression bound over subformula-set space. Priority question P2 of this task and that line's agreement-lemma task target THE SAME MATHEMATICS from two directions. Neither should prove it twice: whichever reaches it first states the lemma in reusable form and the other cites it. This task's own aim is unchanged -- a sound and complete proof system over the standard all-histories semantics -- and the certificate line does not substitute for it, nor does the USER DECISION rejecting bundled semantics apply to it, since a certificate format is not a semantics.

---

### 543. Formalize mf correspondence rigidity
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: metalogic
- **Dependencies**: Task 500, Task 652, Task 656, Task 683

**Description**: Machine-check the principal new results from the MF frame-correspondence research conducted in the PossibleWorlds paper repository. SOURCE MATERIAL (read before starting; six reports, all outside this repository): /home/benjamin/Philosophy/Papers/PossibleWorlds/specs/archive/136_rewrite_mf_paragraph_frame_correspondence/reports/02_mf-substrate-weakening-definability.md (Theorem A), /home/benjamin/Philosophy/Papers/PossibleWorlds/specs/archive/136_rewrite_mf_paragraph_frame_correspondence/reports/03_worlds-topological-categorical-characterization.md (rigidity, T1 converse), /home/benjamin/Philosophy/Papers/PossibleWorlds/specs/archive/136_rewrite_mf_paragraph_frame_correspondence/reports/04_dense-correspondent-and-rigidity.md (Theorems B and C, scope limits), and /home/benjamin/Philosophy/Papers/PossibleWorlds/specs/archive/136_rewrite_mf_paragraph_frame_correspondence/reports/05_lean-verification-and-formalization-program.md (THE ROADMAP -- effort estimates, elaborated statements, and Mathlib dependencies, all checked against this tree). VERIFIED BASELINE, established by that round-3 work against this repository: lake build FormalSystem green (2591 jobs); 20 lean_verify calls returning standard axioms with no sorryAx; and the claim that modal_future_valid discharges no frame field now verified at the proof-term level by a transitive constant-closure walk (696 of 703 constants, imported bodies loaded via findAsync?) finding no FrameOver or TaskFrame field projection and no hF_nonempty. TARGETS, in roadmap priority order. R1: the result that deterministic task frames determine the same BL-logic as all task frames. It is NOT the pure composition of reverse_repr and forward_repr that the originating report claimed -- it needs a third fact, S.frame.Deterministic, absent from this tree; with a one-line helper it typechecks in about 25 lines, reproduced in report 05 Appendix A.1 (elaborated in scratch only; nothing was written into this repository). R2 -- BEST EFFORT-TO-VALUE IN THE SET: the rigidity theorem (report 03 section 4.3.6): over a dense Archimedean temporal order a task frame is static iff it has a uniform dwell time, hence every task frame over such an order with finitely many world states is static. Approximately 100 lines, and the finite-W half ALREADY EXISTS here as exists_uniform_radius_of_finite. The proof uses only Limit and Compositionality; Mathlib supplies Archimedean and DenselyOrdered. The claim is surprising enough that machine-checking it before it enters the paper is the point. Note report 04's refinement: for time-indexed frames the boundary is Dedekind completeness rather than the Archimedean property. R3: the T1-converse witness (report 03 section 4.2.3), a 4-state structure refuting the converse of the paper's Limit-implies-T1 result. BLOCKER TO RESOLVE FIRST: this witness cannot currently even be STATED here, because WorldHistory requires a TaskFrame and the witness violates that structure's limit field; a structural workaround is needed, and this would introduce the first topology into the repository. R4: Theorem A (MF valid iff the task relation is stationary) over Z-time, medium-large; the TimeIndexed structure and the statement are elaborated in report 05. CRITICAL SCOPE CONSTRAINT from report 04 Theorem C: Theorem A's scope is EXACTLY D isomorphic to Z -- for every discrete D not isomorphic to Z (including Z x_lex Z) and every countable or divisible dense D, a non-affine order-automorphism yields a deterministic non-stationary MF-valid frame. Do not state it more generally. Also worth formalizing: Theorem B (report 04) -- MF valid iff its past mirror MP valid iff every box-sentence is globally constant in every model -- which is exact and uniform over every D and is flagged in report 04 as reachable via box_const. NOT RECOMMENDED: Theorem A-prime; report 05 judges the formalization cost unjustified and the paper statement fine unformalized. DEPENDENCY RATIONALE: this task depends on the ShiftSet representation-theorem reconciliation research task because Theorems A and B both touch FormalSystem/Semantics/ShiftSet.lean, and that task exists precisely to prevent two parallel representation theorems from being developed and having to be reconciled afterwards. Settle that question before landing R4. Land real proofs; no sorry. This repository already carries a task-relation correspondent the paper lacks, density_schema_iff_fwdRec over Z, which is a useful model for how to state these. Reconciliation notes (2026-09-21): R1 and R2 were split out into task 646 (they import but never edit FormalSystem/Semantics/ShiftSet.lean, so they do not need the ShiftSet reconciliation this task waits on). This task retains R3 (the T1-converse witness), R4 (Theorem A over Z-time) and Theorem B, and still depends on task 500. Do not re-do R1 or R2 here. Reconciliation notes (2026-09-22): task 646 has LANDED R1 and R2. R2 is FormalSystem/Semantics/Correspondence/Rigidity.lean (FrameOver.static_iff_uniformDwell, static_of_finite; the core chop lemma eq_of_rel_of_step needs only [Archimedean D], density enters once, the biconditional consumes Seriality and the reflection law) with compiled sharpness witnesses in RigiditySharpness.lean showing neither density nor the Archimedean property can be dropped (lexRatFrame_not_static over ℚ ×ₗ ℚ, lexRat_not_archimedean). R1 is FormalSystem/Metalogic/Deterministic/SameLogic.lean (validIn_iff_validDetIn, valid_iff_valid_deterministic) via the helper ShiftSet.frame_deterministic, which lives in SameLogic.lean, not in ShiftSet.lean. The Dedekind-completeness refinement for time-indexed frames noted in report 04 is now its own task, 652, which DEFINES the TimeIndexed structure per report 05 in FormalSystem/Semantics/TimeIndexed.lean; this task now depends on 652 and R4 (Theorem A over ℤ-time) MUST consume that structure rather than define a second one. Remaining scope here: R3, R4, Theorem B. R3 additionally depends on the general-task-frame refactor, which is what makes the four-state witness statable (a frame satisfying Compositionality, Seriality and Saturation but not Limit, with its own histories); do not attempt a structural workaround here.

---

### 502. Ground algebraic representation in goldblatt and brv
- **Effort**: 12-20 hours
- **Status**: [NOT STARTED]
- **Task Type**: formal
- **Topic**: algebraic-representation
- **Dependencies**: None

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
- **Dependencies**: Task 497

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
- **Dependencies**: Task 502

**Description**: Bring the Shift-closed Tense S5 Algebra class into live code and close the G-operator gap. Phase 1 groundwork for the Jonsson-Tarski representation. THE SEED: Boneyard/UltrafilterFrame/TenseS5Algebra.lean (361 lines, behind #exit) already contains the full class STSA extending BooleanAlgebra with fields box, G, H, sigma and axioms box_deflationary, box_monotone, box_idempotent, box_s5, G_monotone, H_monotone, sigma_involution, sigma_neg, sigma_sup, sigma_G, sigma_H, sigma_box, MF, TF, TA, TL. This is the exact algebraic signature the representation needs. IT CARRIES 3 SORRIES, AND THEY MUST NOT BE PROVED AS-IS: they are for temp_a and temp_l, axioms that have since been REMOVED or restructured; restate them against the current 45-constructor ProofSystem.Axiom set (Axioms.lean:115-464) rather than reviving the old shapes. THE G GAP: LindenbaumQuotient.lean supplies boxQuot (:305-ish), hQuot, and sigmaQuot (:346) with its four laws (sigma_quot_involution :353, sigma_quot_neg :362, sigma_quot_sup :373, sigma_quot_box :385) -- but there is NO gQuot. G on the Lindenbaum quotient must be constructed and its congruence proved before LindenbaumAlg can be an STSA instance. Boneyard/SorriedDeclExcisions/AlgebraicGQuotChain.lean is the excised prior attempt and should be consulted, not trusted. DESIGN REFERENCE: specs/archive/992_shift_closed_tense_s5_algebra/reports/01_stsa-algebraic-analysis.md (538 lines) gives the full axiom-to-equation translation table and the key structural claim that box a <= box(G a) meet G(box a) says the box-fixed points form a G-invariant subalgebra -- the algebraic encoding of Omega being shift-closed. It is stale on file names (references deleted AlgebraicRepresentation.lean and ParametricRepresentation.lean) but sound on the mathematics. ACCEPTANCE: STSA class live and sorry-free, gQuot constructed with congruence, instance STSA LindenbaumAlg, lake build green.

=== DEPENDENCY ADDED 2026-09-01 ===
Task 528 (Algebraic/ modernisation: propDecide in BooleanStructure.lean, SetMaximalConsistent.ultrafilterEquiv as a named Equiv, the bespoke `Ultrafilter` structure reconciled with Mathlib Order.PFilter/Ideal.IsPrime, Multiset.inf; from specs/reviews/review-2026-09-01-lean-engineering.md findings D-08, F-11, F-12, F-13) must land first so this task builds on the modernised algebra rather than inheriting a shadowed Ultrafilter name and ~430 lines of hand-built Boolean algebra.

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
- **Dependencies**: None
- **Research**:
  - [481_discharge_or_replace_unorderedsuccessorlabelclosed_residual/reports/01_unorderedsuccessorlabelclosed-verdict.md]
  - [481_discharge_or_replace_unorderedsuccessorlabelclosed_residual/reports/02_spawn-analysis.md]
- **Plan**: [481_discharge_or_replace_unorderedsuccessorlabelclosed_residual/plans/01_sharpen-replace-labelclosed-residual.md]
- **Summary**: [481_discharge_or_replace_unorderedsuccessorlabelclosed_residual/summaries/01_sharpen-replace-labelclosed-residual-summary.md]

**Description**: CLASSIFICATION: genuinely open -- the predicate is refuted as stated, so this is a repair-or-replace problem, not routine discharge. This is the FIFTH termination residual; the four-residual framing used elsewhere in this programme (`UniverseClosed`, `DifficultyBounded`/`StepLengthBounded`, `MintPaysForTime`, `PostBlockingSettles`) is WRONG and must be corrected wherever it recurs.

TARGET: `UnorderedSuccessorLabelClosed` (`FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound/ClosureResidual.lean:836`) is carried as a live hypothesis by `buildTableauAt_isSome_at_seed_lengthBudget_signedUniverse` (`ClosureResidual.lean:1139`) and has an in-tree refutation at `ClosureResidual.lean:889` (`¬ UnorderedSuccessorLabelClosed fc freshWorldLabels`) -- the same shape of problem `DifficultyBounded` presented before `StepLengthBounded` replaced it.

WHAT TO DO -- determine which of three outcomes applies:
(a) the predicate can be discharged at the frame classes/settings the surviving terminus theorems actually need (distinct from the setting `ClosureResidual.lean:889` refutes it in -- check precisely which); or
(b) it needs a `StepLengthBounded`-style weaker replacement, analogous to the `DifficultyBounded` -> `StepLengthBounded` repair pattern already in this file; or
(c) it is unclosable as stated and needs a C9 register entry (the file already has 24 such entries; this would be the 25th) plus an explicit statement of which theorem still carries it and at which frame classes.

A C9 REGISTER ENTRY IS A VALID, COMPLETE DELIVERABLE for this task -- do not treat "prove it" as the only acceptable outcome.

SEQUENCING NOTE (direct from `specs/reviews/review-2026-08-24.md` amendment 10e, re-affirmed by task 468's realignment): task 462 targets `MintPaysForTimeFixed` discharge at a NONEMPTY UNIVERSE, which is the same setting `ClosureResidual.lean:889`'s refutation applies in. If this task and 462 are not sequenced, 462 risks either duplicating the discovery of the refutation or, worse, building on an implicit assumption that this residual is harmless. This task should run BEFORE OR ALONGSIDE 462.

DEPENDENCIES: `[434]` (established the residual set this belongs to). Do NOT fold into 465 (the mechanical restatement-family task) -- 465 is explicitly scoped as "a one-line application of its family root" for SETTLED residuals; this residual is not settled, so folding it in would either force 465 to do research work outside its charter or produce a restatement of an unsettled predicate, which is exactly the kind of premature-closure risk this whole realignment exists to prevent.

VERIFIED at task-468 realignment time (2026-08-25): none of tasks 462, 463, 464, 465 mentions the symbol `UnorderedSuccessorLabelClosed` in its live description.

ACCEPTANCE: one of outcomes (a)/(b)/(c) above is reached and recorded; `lake build` green; no regression to any currently-passing check-module-invariants.sh check.

PROVENANCE: specced by task 468's realignment (report `specs/468_realign_task_programme_from_proof_state_audit/reports/02_stage1-verification-and-programme-realignment.md` §5, new-task-spec-3), itself descended from `specs/reviews/review-2026-08-24.md` amendment 10e.

POINTER REFRESH (2026-09-16 reorganization): `MintBound.lean` was split into the `MintBound/` directory (the monolithic `MintBound.lean` is now a 121-line aggregator). Line references above were re-confirmed against `MintBound/ClosureResidual.lean` (definition :836, in-tree refutation :889, carrying theorem :1139); "this file" in the text above now means that directory. The completed dependency numbers 434/483 were pruned from the dependency list; the blocked status and blockers are unchanged.

---

### 465. Complete terminus restatement family
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: decidability
- **Dependencies**: Task 464

**Description**: Complete the terminus restatement family at the repaired residuals. Task 433's Phase 6 landed EIGHT of the twenty-two restatements -- the four family roots and their four caller-facing seed forms -- and recorded the remaining FOURTEEN as a Reasoned Exclusion with the recipe written down: each is a `_lengthBudget` / `signedUniverse` substitution, "a one-line application of its family root".

This is deliberately MECHANICAL work with the recipe already recorded. Its value is uniformity: a caller reaching for a `_lengthBudget` or `signedUniverse` form of a repaired terminus should find it landed rather than having to re-derive it, and a half-populated family is a trap for a future reader who assumes an absent member is absent for a reason.

SCOPE: read Phase 6's Reasoned Exclusions section in specs/433_discharge_postblockingsettles_residual/plans/01_postblockingsettles-refute-or-prove.md for the enumerated list and the recipe. The family roots and existing members are the `buildTableauAt_isSome_*` declarations in MintBound.lean (the `_at`, `_selfGuarded`, `_fixed` and `_run` families, roughly :6308-:12240). Land the fourteen missing members following the naming convention the file already uses; do not invent a new convention.

WHY THIS RUNS LAST: it restates termini at the repaired residuals, so it must run after the residuals themselves are settled. If 462, 463 or 464 changes a predicate's shape or sheds a hypothesis, the restatements must reflect the settled form -- doing this work earlier would mean doing it twice. Before starting, RE-DERIVE the list of missing members from the file as it then stands rather than trusting the count of fourteen recorded here: earlier tasks may have landed some, or added new family roots.

PROHIBITED: no `sorry`; additive only; do not alter any previously-landed declaration; do not edit Fuel.lean, Saturation.lean or Tableau.lean; axioms within {propext, Classical.choice, Quot.sound}; full `lake build` green. If any of the fourteen turns out NOT to be a one-line application -- i.e. the recipe does not actually apply -- STOP on that member, record why, and do not force it; a member that needs real mathematics belongs in its own task, not smuggled in here.

Dependencies: 462, 463, 464 -- all three, so that the restatements are made against a settled set of residuals rather than a moving one.

---

### 464. Gappotential density measure component
- **Status**: [RESEARCHED]
- **Task Type**: lean4
- **Topic**: decidability
- **Dependencies**: None
- **Research**: [464_gappotential_density_measure_component/reports/01_gappotential-density-component.md]

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

POST-RELOCATION NOTE (2026-09-21). The banner this task points to is now at the head of Tests/BimodalTest/Metalogic/Decidability/TemporalWitnessProbe.lean; task 634 moved the file there from the test root.

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

Reconciliation note (task 629): task 634 (language-extension directories and probe tests) relocates this task's cited Tests/BimodalTest/TemporalWitnessProbe.lean to Tests/BimodalTest/Metalogic/Decidability/TemporalWitnessProbe.lean (added to this task's file_scope above). No dependency edge in either direction: at execution time, check whether task 634 has landed and adjust the path accordingly.

POST-RELOCATION NOTE (2026-09-21). Task 634 has landed and moved Tests/BimodalTest/TemporalWitnessProbe.lean to Tests/BimodalTest/Metalogic/Decidability/TemporalWitnessProbe.lean together with the other seven probe files and TableauConformance.lean, with no follow-up move outstanding (this task was not_started with no uncommitted work under Tests/ when 634 checked). This task's file_scope already names the new path; any mention of the old path in the description above is historical.

---

### 428. Engine totality at a quantified branch budget
- **Status**: [BLOCKED]
- **Task Type**: lean4
- **Topic**: decidability
- **Dependencies**: Task 465
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
- **Dependencies**: Task 410, Task 411, Task 428, Task 430

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
- **Dependencies**: Task 410

**Description**: Track B part 2 for the TM tableau decidability program (parent: task 165; grounding: reports/02_tableau-decidability-hard-research.md sections 3.2-3.3 and 10). First run a /literature acquisition pass for Reynolds 1992 and Reynolds 2003 (the untlNeg co-decomposition and the Dedekind gap axioms; report 02 section 10 flags in-repo literature as thin). Then prove the hard admissibility block in Verified/Refutation/Rules/{UntilSince,Trichotomy,Discrete,Dense,Dedekind}.lean: untlPos (branch 1 via until_F, branch 2 via self_accum_until — follow the axiom literally), untlNeg (Reynolds co-decomposition via absorb_until + left_mono_until_G; the single largest lemma — budget it its own dispatch), sncePos/snceNeg duals, orderTrichotomy (one-liner if Phase 2.2 kept branches syntactically equal to temp_linearity disjuncts — verify, do not assume), z1Rule (two-premise instance of z1 + two modus ponens, relies on same-label internalization from the predecessor task), densityRule/denseIndicatorClosure via density/dense_indicator, and the Dedekind rules via prior_U_gap/prior_S_gap/sep. Acceptance: all admissibility lemmas sorry-free; lake build green.

---

### 410. Internalize tableau branches and prove routine rule admissibility
- **Effort**: 12-18 hours
- **Status**: [PLANNED]
- **Task Type**: lean4
- **Topic**: decidability
- **Dependencies**: Task 429
- **Research**: [410_internalize_tableau_branches_and_prove_routine_rule_admissibility/reports/01_internalize-routine-admissibility.md]
- **Plan**: [410_internalize_tableau_branches_and_prove_routine_rule_admissibility/plans/01_internalize-routine-admissibility.md]

**Description**: Track B part 1 for the TM tableau decidability program (parent: task 165, plan plans/01_tableau-decidability-two-track.md, research reports/02_tableau-decidability-hard-research.md sections 3.1-3.4). Create FormalSystem/Metalogic/Decidability/Verified/Internalize.lean defining Branch.internalize (world labels via box/diamond nesting, time labels via U/S guards realizing the branch TimeOrdering; SETTLED constraints: internalization design over substitution — no cut or uniform-substitution admissibility exists in the tree — and z1Rule's two premises must stay at the same label). Then prove the routine admissibility lemmas in Verified/Refutation/Rules/{Propositional,Modal,Temporal}.lean (~21 lemmas: 8 propositional, 4 S5 modal, 1 boxTemporal, 8 temporal universal/existential), each stated as rule_admissible per report 02 section 3.1 with hypothesis ruleFrameClass r <= fc, reusing Combinators.lean, ModalS5.lean, TemporalDerived.lean, GeneralizedNecessitation.lean, and DeductionTheorem.lean via DerivationTree.lift. Acceptance: all lemmas sorry-free, lake build green, RuleSpec GATE lemmas still green.

---

### 298. Fix c7 labeling bug and regenerate dataset
- **Status**: [PARTIAL]
- **Task Type**: lean4
- **Topic**: dataset-enhancement
- **Dependencies**: None
- **Research**: [298_fix_c7_labeling_bug_and_regenerate_dataset/reports/01_c7-labeling-bug.md]
- **Plan**: [298_fix_c7_labeling_bug_and_regenerate_dataset/plans/01_c7-labeling-bug.md]
- **Summary**:
  - [298_fix_c7_labeling_bug_and_regenerate_dataset/summaries/01_c7-labeling-bug-summary.md]
  - [298_fix_c7_labeling_bug_and_regenerate_dataset/summaries/01_c7-labeling-bug-summary.md]

**Description**: Fix c7 labeling bug at formula ~13750 that causes unbounded memory growth in the decision procedure's timeout handling, then regenerate the full c7 dataset. During task 297 dataset regeneration, all 3 attempts to generate c7 stalled at exactly record 13,749 with RSS growing ~40MB/6s. The labeling function enters an apparent infinite loop or unbounded search for formula #13,750 in the sorted enumeration order. The timeout mechanism either does not fire or cannot interrupt the stuck state. Steps: (1) Identify the specific formula at position ~13,750 in the c7 enumeration. (2) Reproduce the hang in isolation with that formula. (3) Diagnose whether the decision procedure's timeout is failing to fire or the procedure is in an uninterruptible state. (4) Fix the timeout handling so it reliably terminates. (5) Regenerate the full c7 dataset (target: 77,272 records)

POST-RELOCATION NOTE (2026-09-21). Task 632 moved the 25 tooling modules (DatasetGenerator, DatasetAssembly, FormulaEnumerator, DataExport, ProofFirstBenchmark, the *Main exe roots and the rest) from FormalSystem/Automation/ to a root-level lean_lib BimodalTools, namespace BimodalTools, with tests under Tests/BimodalToolsTest/. This task's partial work was committed before the move (task 632 gated its move on a clean git status for FormalSystem/Automation/), so nothing was lost, but every path in this task's plan and handoff that names a tooling module is stale: re-derive before resuming. The library half (Tactics/, ProofSearch/, SuccessPatterns) stays under FormalSystem/Automation/. file_scope widened to include BimodalTools/ and Tests/BimodalToolsTest/. Build the tooling with lake build BimodalTools; a default lake build no longer compiles it, and a green lake build does not prove the exe roots compile (gate on the build-inclusive check-module-invariants.sh, C25). Tasks 231, 282 and 296 depend on this task.

SCOPE NARROWED (2026-09-28): file_scope's BimodalTools/, FormalSystem/Automation/ and Tests/BimodalToolsTest/ directory-wide entries were an inherited blanket widening from task 632's relocation note, not a derived surface for this task. Replaced with the specific paths this task actually touches per its own description (fixing the c7 labeling/timeout bug in the dataset generator and regenerating c7): BimodalTools/DatasetGenerator.lean, Tests/BimodalToolsTest/DatasetGeneratorTest.lean. Re-widen at this task's own research/plan time if the chosen approach implicates more files.

---

### 296. Re add derived binary operators with dedup fix
- **Status**: [PARTIAL]
- **Task Type**: lean4
- **Topic**: dataset-enhancement
- **Dependencies**: Task 298
- **Research**: [296_re_add_derived_binary_operators_with_dedup_fix/reports/01_derived-binary-operators.md]
- **Plan**: [296_re_add_derived_binary_operators_with_dedup_fix/plans/01_derived-binary-operators-plan.md]
- **Summary**: [296_re_add_derived_binary_operators_with_dedup_fix/summaries/01_derived-binary-operators-summary.md]

**Description**: Re-add the 6 derived binary temporal operators (release, weak_until, trigger, weak_since, strong_release, strong_trigger) to the formula enumerator, adjusting canonicalization and/or the passesFilter gate so they survive deduplication and appear in the unique pipeline output. These operators were removed in task 295 because they inflated the enumeration space by ~40-60% without contributing unique formulas — their canonical representations collapsed with primitives. Potential approaches: (1) skip canonicalization for formulas containing derived binary operators, (2) canonicalize to the derived form instead of the primitive form, (3) lower or remove the passesFilter complexity gate for these operators, (4) add a fold-aware dedup stage that treats release(p,q) as distinct from neg(untl(neg p, neg q)). The goal is to have all 13 derived operators represented in the final dataset.

POST-RELOCATION NOTE (2026-09-21). Task 632 moved the 25 tooling modules (DatasetGenerator, DatasetAssembly, FormulaEnumerator, DataExport, ProofFirstBenchmark, the *Main exe roots and the rest) from FormalSystem/Automation/ to a root-level lean_lib BimodalTools, namespace BimodalTools, with tests under Tests/BimodalToolsTest/. This task's partial work was committed before the move (task 632 gated its move on a clean git status for FormalSystem/Automation/), so nothing was lost, but every path in this task's plan and handoff that names a tooling module is stale: re-derive before resuming. The library half (Tactics/, ProofSearch/, SuccessPatterns) stays under FormalSystem/Automation/. file_scope widened to include BimodalTools/ and Tests/BimodalToolsTest/. Build the tooling with lake build BimodalTools; a default lake build no longer compiles it, and a green lake build does not prove the exe roots compile (gate on the build-inclusive check-module-invariants.sh, C25).

SCOPE NARROWED (2026-09-28): file_scope's BimodalTools/, FormalSystem/Automation/ and Tests/BimodalToolsTest/ directory-wide entries were an inherited blanket widening from task 632's relocation note, not a derived surface for this task. Replaced with the specific paths this task actually touches per its own description (re-adding the 6 derived binary temporal operators to the enumerator/canonicalizer): BimodalTools/FormulaEnumerator.lean, BimodalTools/AtomCanonicalization.lean, Tests/BimodalToolsTest/EnumeratorCountsTest.lean. Re-widen at this task's own research/plan time if the chosen approach implicates more files.

---

### 282. Exhaustive enumeration by default
- **Status**: [PARTIAL]
- **Task Type**: lean4
- **Topic**: dataset-enhancement
- **Dependencies**: Task 298
- **Plan**: [282_exhaustive_enumeration_by_default/plans/01_exhaustive-enumeration-plan.md]
- **Research**: [282_exhaustive_enumeration_by_default/reports/01_exhaustive-enumeration-default.md]
- **Summary**: [282_exhaustive_enumeration_by_default/summaries/01_exhaustive-enumeration-summary.md]

**Description**: Flip complexity-9 dataset generation from stratified to exhaustive-by-default once feasibility is confirmed. Prior work (see plans/01_exhaustive-enumeration-plan.md, handoffs/phase-1-6-handoff-20260714.md) verified the 0-sentinel/.take-guard machinery is already correct and unlimited-capable, and corrected stale infeasibility claims in data/README.md and scripts/run_dataset_generation.sh. The next action is the deferred c9 feasibility probe (Plan Phase 2), followed -- pending a GO verdict and explicit user approval for the multi-hour compute -- by c8/c9 exhaustive regeneration and HF Hub republication (Phases 3, 4(rest), 5, 6(rest), 7).

POST-RELOCATION NOTE (2026-09-21). Task 632 moved the 25 tooling modules (DatasetGenerator, DatasetAssembly, FormulaEnumerator, DataExport, ProofFirstBenchmark, the *Main exe roots and the rest) from FormalSystem/Automation/ to a root-level lean_lib BimodalTools, namespace BimodalTools, with tests under Tests/BimodalToolsTest/. This task's partial work was committed before the move (task 632 gated its move on a clean git status for FormalSystem/Automation/), so nothing was lost, but every path in this task's plan and handoff that names a tooling module is stale: re-derive before resuming. The library half (Tactics/, ProofSearch/, SuccessPatterns) stays under FormalSystem/Automation/. file_scope widened to include BimodalTools/ and Tests/BimodalToolsTest/. Build the tooling with lake build BimodalTools; a default lake build no longer compiles it, and a green lake build does not prove the exe roots compile (gate on the build-inclusive check-module-invariants.sh, C25).

SCOPE NARROWED (2026-09-28): file_scope's BimodalTools/, FormalSystem/Automation/ and Tests/BimodalToolsTest/ directory-wide entries were an inherited blanket widening from task 632's relocation note, not a derived surface for this task -- this task's own description names no BimodalTools/ module edit, only the deferred c9 feasibility probe and the dataset-generation mode flip. Dropped all three directory entries and added scripts/run_dataset_generation.sh, the mode-flip target this task's description names as its next action but never previously declared. Re-widen at this task's own research/plan time if the chosen approach implicates more files.

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
- **Dependencies**: Task 298

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

POST-RELOCATION NOTE (2026-09-21). Task 632 moved the dataset tooling out of FormalSystem/Automation/ into a root-level lean_lib BimodalTools (outside defaultTargets) and re-rooted the 12 lean_exe targets under BimodalTools.*. The lake exe target NAMES are unchanged (benchmark_oracle, dataset_generator, proof_extractor and the rest), so command lines in this task still work, but every source path is now BimodalTools/<Module>.lean and every tooling test is under Tests/BimodalToolsTest/. A default lake build no longer compiles the tooling; build it with lake build BimodalTools.

---

### 219. Llm baseline difficulty calibration
- **Status**: [RESEARCHED]
- **Task Type**: general
- **Topic**: dataset-enhancement
- **Dependencies**: Task 231
- **Research**: [219_llm_baseline_difficulty_calibration/reports/01_llm-baseline-research.md]

**Description**: Run bmlogic-bench through multiple LLMs to establish baseline difficulty calibration. Evaluate at least 3 models (GPT-4o, Claude Sonnet, a 7B open model). Report zero-shot accuracy per difficulty tier (easy/medium/hard/very_hard), chain-of-thought vs direct label accuracy, error rate correlation with modal/temporal depth. Include random baseline (50% for balanced benchmark). Publish results in data/baselines/README.md with methodology. Both symbolic formula input and NL paraphrase input (if available from R1).

---

### 178. Publication examples and demo
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: formula-refactor
- **Dependencies**: Task 635, Task 641

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

Reconciliation note (task 629): depends on task 635 (Expressiveness extraction), which renames the Kamp-named results this task cites. Task 632 (BimodalTools split) also edits Examples/BimodalProofs.lean's imports; that overlap is covered transitively via task 635's own dependency chain (635 <- 634 <- {632,633}), so no separate edge to 632 is added here.

POST-RELOCATION NOTE (2026-09-21). Dependency 635 is complete. It moved 141 modules from FormalSystem/Metalogic/WeakCanonical/ to FormalSystem/Metalogic/Expressiveness/ with the namespace rename WeakCanonical.X -> Expressiveness.X (the Kamp development is at Metalogic/Expressiveness/Kamp/), renamed 12 paper-numbered files to content names, and deleted 2 declaration-free stubs. The old-to-new name table is in specs/635_expressiveness_extraction/summaries/01_expressiveness-extraction-move-summary.md: cite results by their new names. Kamp/Section5Correspondence.lean was deliberately NOT renamed, so that a reader searching 'Section 5' finds it. Task 636 then stripped Logos and ProofChecker wording and personal paths from FormalSystem/Examples/ docstrings and installed the ## References normal form (docs/development/REFERENCE_NORMAL_FORM.md, keys in the root references.bib): new example files follow it. Examples/BimodalProofs.lean and Examples/Walkthrough.lean now import specific Automation modules and not the aggregator, since the tooling half left for lean_lib BimodalTools.

---

### 177. Update readme and module docstrings
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: formula-refactor
- **Dependencies**: Task 178, Task 282, Task 296, Task 298, Task 428, Task 429, Task 430, Task 464, Task 465, Task 481, Task 482, Task 534, Task 543, Task 568, Task 623, Task 628, Task 635, Task 636, Task 645, Task 646, Task 683, Task 684, Task 685, Task 696

**Description**: Update README.md, docs/, and FormalSystem/ module-level docstrings to their final post-refactor state, once the decidability chain (426, 428, 429, 430, 432, 433, 434) lands. This is the final polish pass, distinct from and run after task 472's already-completed immediate correction pass. Explicitly excludes: every item task 472 already corrected (the Decidability.lean Status block, Verified/README.md, FMP/README.md, DecisionProcedure.lean's decideAuto docstring, Verified/Decidable.lean's Status docstring, WeakCanonical.lean, RealModel/ShuffleReal.lean, Soundness.lean, PriorExpressivenessDense.lean) and the two Kamp files task 473 already swept (Kamp/EANegationClosure.lean, NfMultiAnchorBridge/NavigatedSpine.lean). This task's residual content is: re-auditing all touched documentation for drift accumulated during the decidability chain's landing (472/473 audited a snapshot; the chain's remaining tasks will touch further files after 472/473 ran), and the Axiom Reference update the charter names as part of 177's original scope.

REALIGNMENT NOTE (task 468, 2026-08-25, verdict per specs/468_realign_task_programme_from_proof_state_audit/reports/02_stage1-verification-and-programme-realignment.md §6): DIVIDE, already half-executed exactly as specs/reviews/review-2026-08-24.md amendment 10f states -- tasks 472 (documentation correction pass) and 473 (Kamp vacuity deletion) already ran the ungated half; the description above is the remaining, gated half's text. `file_scope` (README.md, specs/ROADMAP.md, FormalSystem/, docs/) was already repaired by task 470 item (G) and is confirmed resolvable, no duplicate -- left unchanged here.

=== DEPENDENCY ADDED 2026-09-01 ===
Task 530 (documentation single source of truth + theorem index, from specs/reviews/review-2026-09-01-lean-engineering.md) is the UN-GATED metalogic half of this charter and is now a dependency; this task remains the gated post-decidability-chain pass and its residual shrinks to re-auditing drift the decidability chain introduces plus the Axiom Reference update.

Reconciliation note (task 629): gains dependencies on task 635 (Expressiveness extraction) and task 636 (docstring and citation normalisation), in addition to its existing 428/429/430 dependencies. Kept separate from task 636 rather than merged: this task's residual scope (re-auditing documentation drift the decidability chain introduces, plus the Axiom Reference update) is materially different from task 636's citation-form/bibliography normalisation work.

POST-RELOCATION REVISION (2026-09-21, after tasks 626, 630 and 632-636 landed). Dependencies 635 and 636 are complete. (A) PATHS CHANGED under this task's description: the archive is a root-level Boneyard/; 25 tooling modules left FormalSystem/Automation/ (and Metalogic/Decidability/TraceExport.lean) for a root-level lean_lib BimodalTools; FormalSystem/Tactic/ is new; Syntax/ and Semantics/{Plus,Minus,Star}Language/ merged into FormalSystem/{X}Language/ with flat FormalSystem.{X}Language namespaces; 141 modules moved from Metalogic/WeakCanonical/ to Metalogic/Expressiveness/ (Kamp/, Separation/, GameTransfer/, EFGames/ are there now) and 12 files took content names. The Kamp files named in the exclusion list above live under Metalogic/Expressiveness/Kamp/. Re-derive every path. BimodalTools/ is in scope for module-docstring work; Boneyard/ is not. (B) CITATION FORM: write ## References in the normal form of docs/development/REFERENCE_NORMAL_FORM.md, each key resolving in the root references.bib; typst/bibliography.bib no longer exists. Historical and provenance statements are preserved verbatim, never rewritten to current paths (Semantics/TaskFrame.lean's 'Known gaps... recorded as closed' block, Metalogic/Soundness.lean's 'app:valid... never existed' block, Boneyard provenance READMEs, typst/SYNC-MAP.md, ADR histories). sub: anchors stay verbatim. (C) ITEMS FOLDED IN from the batch's recorded follow-ups, each outside the recording task's scope. Docstring and documentation edits only. (C1) FormalSystem/Theorems/TemporalDerived.lean's ### Removed section names two archive files that do not exist, Boneyard/OpenGuardInvalid/OpenGuardTemporalDerived.lean and Boneyard/ClosedGuardLegacy/ClosedGuardTemporalDerived.lean; both directories hold only a README.md. Repairing it needs knowledge of where those 27 definitions went; find out from git history. (C2) FormalSystem/Examples/TemporalStructures.lean:21 cites the JPL paper as 'The Perpetuity Calculus of Agency'; the paper this repository formalizes is 'The Construction of Possible Worlds'. Determine whether it names a different work; if the same, correct and cite by bibkey; if different, leave and report. (C3) BimodalTools/TraceExporterMain.lean carries a verbatim-duplicated leading module docstring (lines 16-49 repeated at 51-86, the second with one extra bullet); keep one copy with the extra bullet. (C4) Task-number citations survive in body prose outside ## References, notably Tests/BimodalTest/Automation/TacticsTest.lean's ## Test Coverage and ## Test Organization; the task-reference lint does not scan Tests/ or FormalSystem/, so they are ungated. Grep FormalSystem/, BimodalTools/ and Tests/ and replace each with a durable anchor. The lint lives under .claude/, a deploy artifact with no source store in this repository: do not edit it here; record the scan-root gap for an upstream fix. (C5) The 34 chunk_00NN citations in 15 files under FormalSystem/Metalogic/Expressiveness/Kamp/ (NfMultiAnchorBridge/ and neighbours) point into a corrupt markdown conversion. Kamp/Section5Correspondence.lean records that they 'should be re-cited by page as they are touched'. Re-cite by page from a sound copy of the source (run with --lit); where a page cannot be established, leave the citation and list it; never guess a page. (C6) FormalSystem/Metalogic/README.md's aggregator table has one '<!-- TODO: add description -->' for Deterministic.lean. (C7) docs/development/PUBLICATION_REFACTOR.md:476, the Phase 7 bullet, is still future-tense though task 636 closed that phase; past-tense it; line 597 stays verbatim, being a quoted task brief. (C8) USER DECISION, STILL OPEN, carried from task 636: at FormalSystem/Metalogic/Expressiveness.lean:67,69 the dangling keys stavi1979 and gabbay1980 were re-pointed to gabbay1994 (Ch.9 s.3 and Ch.10), a default the user never confirmed. The bibliography merge then brought in gpss1980 (Gabbay, Pnueli, Shelah and Stavi 1980), a plausible better match for the gabbay1980 site. Which source was intended is not derivable from the repository: ask the user; never author a bibliography entry whose details cannot be verified. SCHEDULING: C1-C8 do not depend on the decidability chain. If that chain stays open, split C1-C8 off with /task --expand instead of letting them wait.

SCOPE NARROWED (2026-09-21): file_scope previously named the whole of FormalSystem/ and docs/, which made every library task flag an overlap with this one at admission. It now names only the paths this description cites (C1-C8, the Axiom Reference, the decidability directory for the gated re-audit). The re-audit is open-ended by design: re-derive and widen file_scope at research time. Dependencies on 534, 543, 568, 628, 645 and 646 added because each also edits the root README.md and this task is the final pass that runs after them.

FURTHER EDGES (2026-09-21): dependencies on 178, 282, 296, 298, 464, 465, 481 and 482 added, each sharing a named path with this task (Examples/TemporalStructures.lean; BimodalTools/TraceExporterMain.lean; Metalogic/Decidability/). This task is the final pass and runs after them. Note 481 is blocked and 282, 296 and 298 are partial: if any of them is abandoned the edge is satisfied; if one stalls indefinitely, drop its edge rather than hold this task.

FURTHER EDGES (2026-09-28): the whole-directory FormalSystem/Metalogic/Decidability/ entry is retained, not narrowed, because this task's own description already defers that narrowing: "The re-audit is open-ended by design: re-derive and widen file_scope at research time." Narrowing it now, before the decidability chain lands, would be exactly the guessing this task's charter prohibits. scripts/validate-state.sh Check 8 currently reports this entry overlapping 8 non-terminal tasks (428,429,430,464,465,481,482,696); 7 of the 8 (428,429,430,464,465,481,482) were already dependency-gated. 696 was not -- it declares Decidability/PlusWitnessFamily/* and Decidability/WitnessFamily/Sharing/*, both under this directory -- so 696 is added to dependencies below to close that one real exposure. The existing "if one stalls indefinitely, drop its edge rather than hold this task" clause (see the 2026-09-21 FURTHER EDGES note above) extends to this new edge.

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
- **Dependencies**: Task 498, Task 499

**Description**: CAPSTONE of the algebraic representation front. Prove the Jonsson-Tarski representation theorem for the bimodal logic: the embedding eta(a) = {U | a in U} is an injective STSA homomorphism A -> Cm(Uf(A)).

RE-SCOPED. This task's original four phases are now distributed: Phase 1 (complex algebra Cm(F)) and Phase 2 (ultrafilter frame Uf(A), including the Spherical obligation) are separately tasked and are this task's dependencies; Phase 4 (binary untl/snce operators) is separately tasked and depends on this one. What remains here is Phase 3 -- the embedding itself and its injectivity -- stated at the unary signature (box, G, H, sigma).

PREREQUISITE STATE, RE-VERIFIED 2026-08-26: the STSA class and the R_G/R_H/R_Box ultrafilter frame exist as Boneyard seeds behind #exit and are ported by the dependency tasks. The MCS-to-ultrafilter bijection is live at Algebraic/UltrafilterMCS.lean:782 (ultrafilter_correspondence), though stated existentially rather than as a named Equiv -- converting it to an Equiv may be worth doing here. The BooleanAlgebra LindenbaumAlg instance is at BooleanStructure.lean:421.

THE PRIOR PREREQUISITE LIST IN THIS DESCRIPTION IS STALE and is superseded: it named 'resolve 6 algebraic sorries in TenseS5Algebra/InteriorOperators/LindenbaumQuotient'. InteriorOperators.lean and LindenbaumQuotient.lean are sorry-free today; the remaining sorries are the 3 in the Boneyard TenseS5Algebra seed, and they are for REMOVED axioms (temp_a, temp_l) that must be restated against the current 45-constructor axiom set rather than proved as-is. That is the STSA port task's business, not this one's.

LITERATURE: Goldblatt 1989 'Varieties of complex algebras' (APAL 44, 173-242, doi 10.1016/0168-0072(89)90032-8) has been acquired. CAVEAT THAT MUST BE HONORED: the acquired PDF is an Acrobat 3.0 Capture scan with a badly degraded OCR text layer -- math-heavy pages yield mangled symbols, dropped and reordered lines. READ THE PAGE IMAGES DIRECTLY (the Read tool's pages parameter); do NOT rely on a pdftotext-derived conversion for any axiom statement or equation. Blackburn/de Rijke/Venema 2002 Chapter 5 (corpus entry blackburn_2002) is the primary reference and is born-digital.

MATHLIB HOOK: Order/Atoms.lean:710 (toSetOfIsAtom : alpha <-> Set {a // IsAtom a} for CompleteAtomicBooleanAlgebra) is the atom-structure half of Stone/Jonsson-Tarski for the complete atomic case and is the single most relevant Mathlib lemma here; supporting lemma eq_setOf_le_sSup_and_isAtom at :695. Mathlib has NO Stone duality for Boolean algebras and no BAO machinery -- the rest is greenfield.

SEE ALSO the reconciliation task on whether this embedding can be factored through ShiftSet.lean's reverse_repr rather than built independently; if it can, that supersedes part of this task's construction and this description should be revised again before implementation starts.

=== DEPENDENCY ADDED 2026-09-01 ===
Task 528 (Algebraic/ modernisation: propDecide in BooleanStructure.lean, SetMaximalConsistent.ultrafilterEquiv as a named Equiv, the bespoke `Ultrafilter` structure reconciled with Mathlib Order.PFilter/Ideal.IsPrime, Multiset.inf; from specs/reviews/review-2026-09-01-lean-engineering.md findings D-08, F-11, F-12, F-13) must land first so this task builds on the modernised algebra rather than inheriting a shadowed Ultrafilter name and ~430 lines of hand-built Boolean algebra.
