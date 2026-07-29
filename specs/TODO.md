---
next_project_number: 428
---

# TODO

## Task Order

*Updated 2026-07-29. Generated from state.json dependency graph.*

**Dependency Waves**:
| Wave | Tasks | Blocked by | Topics |
|------|-------|------------|--------|
| 1 | 125,127,128,165,231,257,298,408,413,415,419,421,423,424 | -- | completeness, frame-extensions, algebraic-representation, ... |
| 2 | 193,219,282,296,410,420,422,425,426 | 165,231,298,415,421,423 | completeness, automation, dataset-enhancement, ... |
| 3 | 169,177,178,411,414 | 193,410,420,422 | formula-refactor, paper-refactor, strong_completeness |
| 4 | 362,412,417 | 169,411,414 | paper-refactor, strong_completeness |
| 5 | 95,427 | 408,412,417,419 | completeness, paper-refactor |

**Grouped by Topic** (indented = depends on parent):

### Completeness

165 [IMPLEMENTING] — Establish verified decidability of TM bimodal logic for all four 
  └─ 410 [NOT STARTED] — Track B part 1 for the TM tableau decidability program (parent: t
    └─ 411 [NOT STARTED] — Track B part 2 for the TM tableau decidability program (parent: t
      └─ 412 [NOT STARTED] — Track B finish for the TM tableau decidability program (parent: t
        └─ 95 [NOT STARTED] — Verify and record the final axiom/sorry status of the headline me
  └─ 426 [NOT STARTED] — Settle whether the tableau engine can positively refute (G p) -> 
408 [IMPLEMENTING] — Identify and implement the most faithful and mathematically corre
  └─ 95 [NOT STARTED] — Verify and record the final axiom/sorry status of the headline me (see above)
413 [NOT STARTED] — Formalize the TM+ over TM conservativity bridge in Lean 4 (paper 

### Formula Refactor

177 [NOT STARTED] — Update all documentation to match final codebase state after refa
178 [NOT STARTED] — Expand Examples/ with publication-quality demonstrations of the f

### Frame Extensions

127 [NOT STARTED] — Add time addition operator (+) to the bimodal logic TM. φ + ψ is 
128 [NOT STARTED] — Add topological open set (interior) operator for dense and contin

### Algebraic Representation

125 [NOT STARTED] — Implement a Jonsson-Tarski representation theorem for TM logic: e

### Automation

193 [NOT STARTED] — Apply validity-intro and truth-simp macros to the soundness layer

### Dataset Enhancement

231 [NOT STARTED] — Build comprehensive automation so that every dataset regeneration
  └─ 219 [RESEARCHED] — Run bmlogic-bench through multiple LLMs to establish baseline dif
257 [BLOCKED] — large_data_storage_huggingface
298 [PARTIAL] — Fix c7 labeling bug at formula ~13750 that causes unbounded memor
  └─ 282 [PARTIAL] — exhaustive_enumeration_by_default
  └─ 296 [PARTIAL] — Re-add the 6 derived binary temporal operators (release, weak_unt

### Paper Refactor

415 [RESEARCHED] — Completeness under the refactored (Omega-free, maximal-history) s
  └─ 420 [BLOCKED] — Align the Lean TaskFrame with the refactored paper def:frame (Pos
    └─ 414 [RESEARCHED] — DEFINITIONAL ALIGNMENT (PossibleWorlds Comments/fix.md B1/C1; rev
      └─ 417 [RESEARCHED] — Semantic FMP over a fixed carrier, stated against the refactored 
        └─ 427 [NOT STARTED] — Bring the BimodalReference typst book back into sync with the ref
419 [NOT STARTED] — Machine-check the CO-does-not-derive-Reynolds independence result
  └─ 427 [NOT STARTED] — Bring the BimodalReference typst book back into sync with the ref (see above)

### Strong Completeness

421 [NOT STARTED] — Two deliverables on the Base weak terminus, both small.
  └─ 422 [NOT STARTED] — Construct the discrete-case analogue of the existing dense chroni
    └─ 169 [NOT STARTED] — Base (FrameClass.Base / general) WEAK completeness green: make th
      └─ 362 [NOT STARTED] — Implement the completeness capstone under the SETTLED TERMINOLOGY
423 [NOT STARTED] — Create FormalSystem/Metalogic/SetConsequence.lean containing the 
  └─ 425 [NOT STARTED] — Convert the informal argument at FormalSystem/Metalogic/StrongCom
424 [NOT STARTED] — Prove, in both directions, that the task-model class is represent

### Uncategorized

## Tasks

### 427. Sync typst book with refactored paper
- **Effort**: large
- **Status**: [NOT STARTED]
- **Task Type**: typst
- **Topic**: paper-refactor
- **Dependencies**: Task 414, Task 415, Task 417, Task 419, Task 420

**Description**: Bring the BimodalReference typst book back into sync with the refactored paper at /home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex, and with the Lean tree as it stands once the paper-refactor task chain has landed. This is the typst-side counterpart of the LaTeX work already done in latex/subfiles/; it was deliberately deferred and declared out of scope there, so the typst chapters currently CONTRADICT the corrected LaTeX.

KNOWN STALE SITE (confirmed, the trigger for this task): typst/chapters/02-semantics.typ:35-40 states the PRE-REFACTOR three-axiom Task Frame definition -- one-way Nullity (w =>_0 w rather than the iff), Reflection as a SUBSTANTIVE axiom, and unrestricted mixed-sign Compositionality. All three are wrong against the current paper def:frame: (i) Nullity is now an iff; (ii) Compositionality is the proviso-free LAX law on the positive cone D+ = {x : 0 <= x} (R_{x+y} contains R_x o R_y -- equality would assert interpolation and is NOT adopted); (iii) Reflection is DERIVED, not primitive -- negative durations come from the definitional CONVERSE CONVENTION (w =>_x u for x < 0 IS u =>_{-x} w); and (iv) a NEW axiom Limit Nullity is missing entirely (the intersection over x > 0 of the two-sided cones (w)_x equals {w}). The prose gloss at 02-semantics.typ:42-50 repeats the same errors and calls the mixed-sign form merely "algebraically impossible for non-deterministic relations" as if the Lean tree diverged from the paper -- that framing is now inverted: the paper has ADOPTED the positive-cone presentation, so this should record AGREEMENT, not divergence. The corrected LaTeX wording is in latex/subfiles/02-Semantics.tex and should be the model for the typst restatement.

STALE LINE ANCHORS: 02-semantics.typ cites Semantics/TaskFrame.lean:93 for the structure; it now lives at TaskFrame.lean:152. typst/SYNC-MAP.md:230 records the 02-semantics verdict against the PRE-refactor paper range possible_worlds.tex:902-907; the correct live anchors are possible_worlds.tex:2423 (formal def:frame) and 908-926 (body). Re-derive rather than trusting either number -- the paper moves.

SCOPE: audit ALL of typst/chapters/ against the current paper and the post-chain Lean tree, not just 02-semantics.typ. Chapters carrying paper-anchored claims that the refactor chain plausibly touches include 02-semantics.typ (frame/semantics), 04-metalogic.typ (completeness, FMP, decidability), p2-frame-classes.typ (DF/DN/CO paper correspondence, possible_worlds.tex line refs at :109-112), p3-ltl-to-tm.typ and p3-vlach-blstar.typ (paper clause ranges). Update typst/SYNC-MAP.md verdict rows for every claim re-verified, and refresh typst/sync-check-whitelist.txt if paper labels changed. Verify with the repo scripts: scripts/typst-sync-check.sh (backtick name resolution + count freshness) and a full typst compile of typst/BimodalReference.typ.

NOTATION (binding user decision, 2026-07-28): any explicit converse operation on the task relation is written with a superscript inverse -- $Rightarrow^{-1}$ / $R^{-1}$ -- NEVER the relation-algebra breve/smile ($breve{R}$, $R^{smallsmile}$) common in the arrow-logic literature. Note that the paper itself currently states the converse convention with subscript negation only and introduces no operator symbol at all; the corrected LaTeX subfile followed suit and introduced none either, so the typst restatement should also introduce none unless a symbol is genuinely needed.

WHY IT DEPENDS ON THE WHOLE CHAIN: this task must run LAST. Each predecessor changes what the typst book must say. 420 fixes the frame definition itself (its Phase 6, adding the limit_nullity structure field, is blocked on 415 and had not landed when this task was created -- confirm before starting). 414 refactors semantics to maximal-history validity. 415 replaces the canonical frame (bundleFlowFrame) and reworks completeness. 417 moves FMP to a finite WorldState over Z. 419 machine-checks co-Reynolds independence. Syncing typst before these land would guarantee a second full re-sync.

NON-GOALS: no edits under Philosophy/Papers/ -- the paper is READ-ONLY ground truth here. No changes to latex/subfiles/ (already corrected). No Lean changes: if the audit finds a Lean/paper divergence, record it and raise a separate task rather than fixing it here.

---

### 426. Settle anchor row countermodel or nontermination for g p box g p
- **Effort**: 4-8 hours
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: completeness
- **Dependencies**: Task 165
- **Research**: [418_fix_tableau_engine_crossworld_temporalcopy_unsoundness_in_boxnegdiamondpos/artifacts/after-verdicts.md]

**Description**: Settle whether the tableau engine can positively refute (G p) -> square (G p), or whether that branch provably never saturates. Context: the cross-world temporal-copy unsoundness in boxNeg/diamondPos is fixed and the engine is sound, but the fix moved this formula from a WRONG answer to NO answer rather than to the intended positive refutation. Measured post-fix: decide returns .fuelExhausted (not .invalid), getCountermodel?.isSome = false, and buildTableau returns none at fuel 30, 60, 400 and 1000 -- so the fuel ceiling is not bracketed from above and there is no evidence a larger budget helps. Pre-fix the same formula returned .extractionFailed, which under this codebase R7 semantics asserts VALIDITY of an invalid formula; the current .fuelExhausted is the only constructor isUndecided recognises, so the present state is honest-but-incomplete rather than wrong. Two hypotheses to discriminate: (a) budget -- the branch does saturate but needs more fuel, in which case find and record the ceiling; (b) non-termination -- the branch never saturates, in which case this is a termination question for FormalSystem/Metalogic/Decidability/Verified/Termination/Fuel.lean, not a budget one, and the honest deliverable is a proof or argument that no finite fuel suffices. Discriminating between (a) and (b) is the primary deliverable; producing the countermodel is the secondary one and only applies under (a). The corpus already pins this outcome directly: CrossWorldPropagationProbe row F asserts the decide constructor and builds green at (false, false, true, false, true) -- update that row if the verdict moves. Do NOT reintroduce any temporal-copy propagation block into boxNeg/diamondPos to make the branch close; that is the exact unsoundness that was removed, and reverting it would restore a false claim of validity. Note the related but SEPARATE inheritance also recorded for the parent task: the decidable-branch-gate family (boxAnchoredCheck, boxGridCheck, regionGate, regionLabelCheck, rayUpOk/rayDnOk) now computes false on every multi-world branch; that is the truth-lemma side-condition problem and is not this task.

---

### 425. Machine check discrete non compactness witness
- **Effort**: high
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: strong_completeness
- **Dependencies**: Task 361, Task 423

**Description**: Convert the informal argument at FormalSystem/Metalogic/StrongCompleteness.lean:56-62 into a machine-checked theorem: the FrameClass.Discrete consequence relation is not compact, hence strong completeness is refuted for that class.

The witness is the premise set {F p} union {not X^n p : n in N} where X phi = Formula.next phi. Every finite subset is satisfiable over Z (place p beyond the largest n used); the whole set is unsatisfiable over any Archimedean discrete carrier, because the F p witness would lie at some finite successor distance, contradicting the corresponding not X^n p.

The load-bearing ingredient is already in the tree: Formula.next phi = Formula.untl phi Formula.bot (FormalSystem/Syntax/Formula.lean:490) genuinely is a next-step operator — through the untl clause of TruthAt, "exists s > t, phi(s) and for all r in (t,s), false" says exactly that s is the immediate successor. No extra hypothesis is needed for this. The "not satisfiable" half is where IsSuccArchimedean does its work, via Order.succ_iterate-style reachability lemmas in Mathlib.

This is the negative half of the per-class split and is independent of the compactness gate — it is not affected by whether Route B succeeds. It depends only on the set-based layer's vocabulary (SatisfiableDiscreteSet / CompactDiscrete are the Discrete analogues of SatisfiableDenseSet / CompactDense).

Explicitly out of scope: an analogous Dedekind non-compactness witness. That belongs to task 408 and the class's non-compactness is already established; duplicating it here would create scope overlap with an in-flight task for no gain.

Governing design document: specs/361_strong_completeness_architecture_and_weak_terminus_gap_analysis/design/02_compactness-route.md, section "Discrete non-compactness witness".

Acceptance: archWitness_finitely_satisfiable, archWitness_not_satisfiable, and discrete_consequence_not_compact all land sorry-free; #print axioms clean on each; lake build green.

---

### 424. Prove shift set representation theorem compactness feasibility gate
- **Effort**: high
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: strong_completeness
- **Dependencies**: Task 361

**Description**: Prove, in both directions, that the task-model class is representable by shift sets <Omega, D, sh, A> — D an ordered abelian group, Omega a nonempty type with a D-action sh : Omega -> D -> Omega, and A : Atom -> Omega -> Prop.

THIS TASK IS THE GATE FOR THE ENTIRE ULTRAPRODUCT BRANCH. The follow-on work — the ultraproduct carrier (S2), the Los lemma for TruthAt (S3), compactness of the Base/Dense consequence relations (S4), and strong completeness for Dense and Base (S5-Dense, S5-Base) — is NOT AUTHORIZED and has deliberately NOT been created as tasks. It becomes authorized only when this task lands sorry-free. Do not spawn, plan, or dispatch any of it from within this task.

Gate-passed evidence standard, and nothing weaker: a sorry-free Lean statement of both directions, with #print axioms on each direction reporting no sorryAx. A statement that type-checks with a sorry body does not pass. Proving only the forward direction does not pass. A prose argument does not pass.

Cancel condition: if either direction is refuted, or the construction cannot be stated without an additional non-elementary hypothesis, then Route B (semantic compactness via ultraproduct) is REFUTED and the whole branch is cancelled, not retried. Record the refutation and re-open the compactness question; do not proceed to S2 hoping the gap can be patched downstream.

Governing design document: specs/361_strong_completeness_architecture_and_weak_terminus_gap_analysis/design/02_compactness-route.md — section "Representation theorem" for both directions (the reverse direction uses WorldHistory.timeShift and FormalSystem.Semantics.TimeShift.time_shift_preserves_truth, FormalSystem/Semantics/Truth.lean:446), section "Risks" R3 for the Type vs Type* constraint (assert it EARLY, not at assembly time), and section "GATING RULE" for the full gate contract.

Acceptance: both directions sorry-free; #print axioms clean on each; lake build green; the task's summary states explicitly whether the gate PASSED or FAILED.

---

### 423. Land set based consequence layer setderivable and per class setsemanticconsequence
- **Effort**: high
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: strong_completeness
- **Dependencies**: Task 361

**Description**: Create FormalSystem/Metalogic/SetConsequence.lean containing the finitary set-derivability relation SetDerivable, the four per-class SetSemanticConsequence* predicates, the basic lemmas, and the strong-completeness / compactness / model-existence statements. Then import it from FormalSystem/Metalogic/StrongCompleteness.lean.

This is vocabulary only. It proves no compactness result and closes no existing sorry. It is self-contained and unblocks two downstream branches (the Discrete non-compactness witness, and Dense strong completeness).

Governing design document: specs/361_strong_completeness_architecture_and_weak_terminus_gap_analysis/design/01_set-consequence-layer.md — transcribe section 2 (SetDerivable), section 3 (the four per-class definitions), section 4 (basic lemmas), section 5 (StrongCompletenessDense, CompactDense, strongCompletenessDense_of_compact, SatisfiableDenseSet, ModelExistenceDense). Section 4's "Implementer notes" name three elaboration risks; section 7 records what is deliberately out of scope.

Acceptance (from design/01 section 6, all five required): zero sorries and zero vacuous placeholders; grep -c 'import FormalSystem.Metalogic.BXCanonical' on the new module returns 0; each SetSemanticConsequence* binder list is byte-comparable to its Validity.lean source (valid :79, ValidDense :169, ValidDiscrete :187, ValidDedekindDense :276) with only the premise hypothesis inserted, and uses Type not Type* (Validity.lean:77 records this as deliberate); #print axioms on every new declaration reports no sorryAx; StrongCompleteness.lean imports the module and still builds.

---

### 422. Build discrete chronicle over non archimedean block carrier with restricted coherence
- **Effort**: high
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: strong_completeness
- **Dependencies**: Task 421

**Description**: Construct the discrete-case analogue of the existing dense chronicle machinery, over the non-Archimedean carrier Q x_lex Z confirmed by the predecessor task.

Deliverable (a): the analogue of box_dense_gives_density (FormalSystem/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodelBasic.lean:435) and cantorIsoDense for the "box U(T,F) in A" case — block decomposition of the chronicle order into Z-blocks, densification of the block order, and the isomorphism into Q x_lex Z.

Deliverable (b): the three restricted-coherence analogues, mirroring cantor_bfmcs_dense_restricted_tc (:629), _buc (:680), _fuc (:755) at the new carrier.

Why this carrier and not Z: succ_cofinal — the obligation that killed the old BX pipeline, refuted by the Z+Z counterexample in Boneyard/BXPipelineGapAnalysis/ — was only ever needed to force the chronicle into Z, i.e. to make it Archimedean. FrameClass.Base imposes no Archimedean-ness (valid, FormalSystem/Semantics/Validity.lean:79, has no IsSuccArchimedean binder). The Z+Z shape is not a counterexample here — it is the intended carrier. Do not re-attempt succ_cofinal.

PRINCIPAL RISK, unresolved at scoping time: it has NOT been verified that the chronicle's block order can always be densified without disturbing MCS-chain coherence. A countable discrete order without endpoints is a Z-indexed fibration over its block order, but making the total structure a group requires the block order to carry a compatible group structure. If this fails, escalate as [BLOCKED] with the failing coherence obligation named — do not paper over it with a sorry or a vacuous placeholder.

Governing design document: specs/361_strong_completeness_architecture_and_weak_terminus_gap_analysis/design/03_weak-terminus-status.md, sections 5.4-5.7.

Acceptance: the block-carrier construction and all three restricted-coherence analogues are sorry-free; #print axioms on each reports no sorryAx; lake build green. This task does NOT close the Transfer.lean:1242 sorry — that is task 169's job, which consumes this output.

---

### 421. Correct transfer route guidance and probe non archimedean discrete carrier
- **Effort**: medium
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: strong_completeness
- **Dependencies**: Task 361

**Description**: Two deliverables on the Base weak terminus, both small.

(a) Correct the refuted route guidance. FormalSystem/Metalogic/WeakCanonical/Transfer.lean:1239-1241 currently proposes "(i) a Base-MCS -> Discrete-MCS transfer lemma that lets countermodel_discrete_reynolds_v2 apply". Route (i) is REFUTED and MUST NOT be re-attempted. The witness: over D := Z x_lex Z (lex, first coordinate dominant) with p true exactly at points >= (1,0), every point has an immediate successor so box U(T,F) holds; G(Gp -> p) holds at (0,0); FGp holds at (0,0) (witness (1,0)) but Gp fails there (witness (0,1)); hence Axiom.z1 p is false. So a Base-MCS containing box U(T,F) need not be Discrete-consistent and no Base-to-Discrete MCS transfer lemma can exist. Replace those comment lines with the refutation and point at route (ii). Docstring/comment-only — do not touch the sorry at :1242 in this task.

(b) Probe the recommended carrier. Confirm AddCommGroup, LinearOrder, IsOrderedAddMonoid, Nontrivial all resolve for Q x_lex Z, and add a CarrierProbe-style example block (mirroring the pattern at FormalSystem/Metalogic/BXCanonical/CompletenessDedekind.lean:61-100) showing the parametric canonical machinery elaborates at that carrier. This is a confirmation step, not a supply step: Mathlib/Algebra/Order/Monoid/Prod.lean:52-59 declares @[to_additive] instance Lex.isOrderedMonoid ... : IsOrderedMonoid (a x_lex b), whose additive form supplies IsOrderedAddMonoid (a x_lex b). Confirm the instance actually fires for Q x_lex Z (in particular that AddLeftStrictMono Q is found) — the generated instance name was inferred from the attribute and not resolved by lookup.

Governing design document: specs/361_strong_completeness_architecture_and_weak_terminus_gap_analysis/design/03_weak-terminus-status.md, section 5.3 (the refutation), 5.5 (the carrier), 5.6 (the Mathlib instance).

Acceptance: the refuted-route comment no longer appears at Transfer.lean:1239-1241; the probe block elaborates; lake build is green; #print axioms on any new declaration shows no sorryAx; the live non-Boneyard sorry count is unchanged at 2 (verify with: grep -rn --include='*.lean' -E '^\s*sorry\s*$' FormalSystem/ | grep -vc Boneyard).

---

### 420. Align task frame with positive cone limit nullity
- **Effort**: medium
- **Status**: [BLOCKED]
- **Task Type**: lean4
- **Topic**: paper-refactor
- **Dependencies**: Task 415
- **Research**: [420_align_task_frame_with_positive_cone_limit_nullity/reports/01_taskframe-positive-cone-limit-nullity.md]
- **Plan**: [420_align_task_frame_with_positive_cone_limit_nullity/plans/01_taskframe-limit-nullity-alignment.md]
- **Summary**: [420_align_task_frame_with_positive_cone_limit_nullity/summaries/01_taskframe-limit-nullity-alignment-summary.md]

**Description**: Align the Lean TaskFrame with the refactored paper def:frame (PossibleWorlds task 51, commits 754d069..e566885; SUPERSEDES fix.md A1 -- Reflection is no longer a paper axiom). PAPER'S NEW DEF:FRAME (settled, do not re-litigate): primitive task relation on the positive cone (subset of W x D+ x W, D+ = {x : 0 <= x}); (i) iff-Nullity; (ii) proviso-free Compositionality on D+ stated as the LAX law (R_{x+y} contains R_x o R_y -- equality would assert interpolation, NOT adopted); (iii) NEW axiom Limit Nullity: the intersection over x > 0 of the two-sided cones (w)_x equals {w}; negative durations by the definitional CONVERSE CONVENTION (w =>_x u for x < 0 IS u =>_{-x} w); Reflection and backward composition are DERIVED; mixed-sign composition is inexpressible at the primitive level; the paper appendix now proves T_F is T1 (hence R0) for EVERY frame (app:topology-r0, one-line proof from Nullity + converse convention + Limit Nullity). CURRENT LEAN STATE (FormalSystem/Semantics/TaskFrame.lean): already close -- nullity_identity matches iff-Nullity; forward_comp (0 <= x, 0 <= y hypotheses) is exactly the official lax positive-cone law; backward_comp already derived, matching the paper's derived status. The two-sided primitive TaskRel with the `converse` FIELD is precisely the paper's EXTENDED relation, so the presentation itself can stand; but the docstring must be recast: `converse` is the paper's definitional converse convention packaged as a structure field, not a substantive temporal-symmetry axiom, and the 'Axiomatization Notes' block is now inverted (the paper has ADOPTED the positive-cone presentation -- record agreement, not divergence). Stale 'def:frame, line 1835' citations throughout the module must be re-anchored. THE REAL MATHEMATICAL DELTA: Limit Nullity is absent from the Lean structure. (1) Add a limit_nullity field; direct transcription with the extended relation: forall w u, (forall x, 0 < x -> exists y, |y| < x and TaskRel w y u) -> u = w. Paper task-51 research S2 proved forward-only and two-sided forms equivalent when imposed at all states -- research may pick either, but the two-sided form matches the paper's official statement. (2) Provide helper limit_nullity_of_discrete: over Z (and generally SuccOrder + IsSuccArchimedean D) the axiom is AUTOMATIC (|y| < succ 0 forces y = 0, then nullity_identity), so every Discrete-class construction discharges it in one line. (3) Inventory and discharge ALL TaskFrame instantiation sites tree-wide (research phase: grep ': TaskFrame' / 'TaskFrame D where' / '.mk'). Known: trivialFrame (Unit singleton -- trivially fine), identityFrame (fine -- verify), natFrame (VIOLATES the axiom over dense D: any u is reachable in arbitrarily small nonzero duration -- repair the relation or restrict its temporal parameter to discrete D), plus every canonical/countermodel frame in Metalogic/ (coordinate with 415, which owns the per-class canonical obligations). (4) latex/subfiles/02-Semantics.tex Task Frame definition is stale vs BOTH the live tree and the paper (states one-way Nullity and unrestricted mixed-sign Compositionality -- the very axiomatization TaskFrame.lean's own notes call impossible for nondeterministic relations): restate with iff-Nullity, positive-cone lax Compositionality, the converse convention, and Limit Nullity; must still compile standalone (pdflatex with TEXINPUTS=../assets: from latex/subfiles/). SCOPE BOUNDARY with task 409: 409 owns 04-Metalogic.tex/06-Notes.tex identifier-architecture fidelity; THIS task owns the 02-Semantics.tex frame-definition subsection. OPTIONAL STRETCH (defer if nontrivial): formalize the paper's T1 theorem as a sanity check -- with the cone topology, closure of {u} equals {u} for every frame. NON-GOALS: no edits under Philosophy/Papers/; no change to WorldHistory/respects_task (unaffected -- it evaluates at d = t - s with converse handling signs); no validity/semantics refactor (task 414 owns that and now depends on this task so the Omega-free API lands once, against the final frame structure). Related: 414, 415, 417, 409.

NOTATION (user decision, 2026-07-28): any explicit converse operation on the task relation is written with a superscript inverse -- $\Rightarrow^{-1}$ (and $R^{-1}$ for abstract relations) -- NEVER the relation-algebra breve/smile ($\breve{R}$, $R^{\smallsmile}$) common in the arrow-logic literature. This applies to the 02-Semantics.tex restatement of the converse convention, any Lean notation or declaration names (prefer inv/⁻¹ vocabulary, e.g. TaskRel.inv, consistent with Mathlib's Inv), and all module docstrings. Note the paper itself currently states the converse convention without any operator symbol (subscript negation only) -- if a symbol is ever introduced paper-side it uses the same superscript -1 form.

---

### 419. Machine check co reynolds independence
- **Effort**: large
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: paper-refactor
- **Dependencies**: None

**Description**: Machine-check the CO-does-not-derive-Reynolds independence result. Currently recorded ONLY as a pen-and-paper model sketch in the Layer 9 prose of FormalSystem/ProofSystem/Axioms.lean:376-387 (immediately above the Axiom.prior_U_gap constructor), where it is explicitly flagged as NOT machine-checked. GOAL: construct a Lean countermodel establishing that the paper's CO principle does not syntactically derive the Reynolds gap axioms — specifically that CO does not derive Axiom.prior_U_gap. THE SKETCH TO FORMALIZE: a rational (Q) flow carrying isolated not-phi points that accumulate at an irrational from above validates every CO instance while refuting Prior-U; this is the classical Stavi US-vs-FO gap phenomenon. WHY IT MATTERS: this is the sole load-bearing justification for the paper-side amendment to def:TMplus-c / cor:tm-completeness in /home/benjamin/Philosophy/Papers/PossibleWorlds/ (fix.md C4 option 2) — the paper's completeness claim is deferred to this repository with no independent citation, so if the sketch is right def:TMplus-c is deductively too weak, and if it is wrong the amendment is unnecessary. Right now that amendment would rest on an unverified claim. CONTEXT ALREADY IN THE TREE (do not redo): the CONVERSE direction is done and sorry-free — co_derived in FormalSystem/Theorems/DedekindDerived.lean proves Reynolds |- CO, consuming Axiom.prior_U_gap and nothing else outside FrameClass.Base, and co_valid in FormalSystem/Metalogic/SoundnessLemmas/CoValidity.lean gives the semantic side. Formula.co (FormalSystem/Syntax/Formula.lean) is the CO formula as a source-cited abbreviation; note the triangle is Formula.always, NOT Formula.box. CO source formula: PossibleWorlds/JPL/possible_worlds.tex:3250. Likely needs a /literature acquisition pass for Stavi and Reynolds 1992 on the US-vs-FO expressiveness gap. Nothing currently in the Lean tree depends on the claim, so this is additive — no rebase surface. NON-GOAL: editing any file under Philosophy/Papers/. Related: 416, 408, 390.

---

### 418. Fix tableau engine crossworld temporalcopy unsoundness in boxnegdiamondpos
- **Effort**: 4-8 hours
- **Status**: [COMPLETED]
- **Task Type**: lean4
- **Topic**: completeness
- **Dependencies**: None
- **Research**: [165_establish_semantic_finite_model_property/reports/08_spawn-analysis.md]
- **Plan**: [418_fix_tableau_engine_crossworld_temporalcopy_unsoundness_in_boxnegdiamondpos/plans/01_remove-unsound-temporal-copy-blocks.md]
- **Summary**: [418_fix_tableau_engine_crossworld_temporalcopy_unsoundness_in_boxnegdiamondpos/summaries/01_remove-unsound-temporal-copy-blocks-summary.md]

**Description**: Remove the six unsound group-3 blocks -- tempGProps, tempHProps, tempFNegProps, tempPNegProps, tempUNegProps, tempSNegProps -- from both boxNeg (FormalSystem/Metalogic/Decidability/Tableau.lean:555-574) and diamondPos (same file, :599-619). Groups 1 (existential witness) and 2 (T(square B)/F(diamond B) propagation) in both rules are sound and MUST NOT be touched. After the edit, temporalProps in each rule reduces to the empty concatenation (or is deleted along with its assembly line), and each rule's .linear list becomes `witness :: boxProps ++ diaProps`. Root cause: the six blocks copy every temporal-universal/existential signed formula true at l.time on the current branch verbatim into the freshly minted box/diamond-witness world, conflating 'true along the history being built' with 'true at the same instant along every admissible history' -- exactly what square/diamond quantify over. Measured effect: buildTableau ((G p) -> square (G p)) 1000 .Base returns .allClosed (should be .hasOpen), with decide returning .extractionFailed rather than .invalid with a countermodel; pinned in Tests/BimodalTest/BoxNegReachabilityProbe.lean (twelve #guard_msgs rows) and Tests/BimodalTest/BoxNegPreservationProbe.lean. Rebuild Tableau.lean and the full project (lake build), then run the FULL conformance corpus (Tests/BimodalTest/TableauConformance.lean plus the two probes above) as the acceptance gate -- not a spot check. Because the removal is risk-asymmetric (branches can only get harder to close, never easier: the fix cannot introduce a new false-invalid verdict, only reveal previously-hidden false-valid ones or newly-uncloseable branches), the only way to bound the fix's blast radius is to run the entire corpus before and after and record every verdict that changes, producing a before/after table (formula, old verdict, new verdict) as part of the task's summary artifact. Because three concurrent sessions (tasks 408, 414, 415) share this git clone and have previously destroyed full-build attempts by deleting .olean files mid-build, this task's own plan must include an explicit build-reliability strategy before attempting the full-project rebuild and corpus run that form its acceptance gate: check for and honor any existing build-coordination/lock convention in the repo, avoid `lake clean` while a concurrent session may be mid-build, and treat a corpus run whose build step failed or was interrupted as inconclusive (retry) rather than as a passing gate -- never treat an oleans-were-deleted failure as if the corpus had validated the fix. Do NOT touch FormalSystem/Metalogic/Decidability/Verified/Decidable.lean or attempt Phase 7.2's RuleSound proof -- that remains task 165's responsibility once this fix lands. This task ends at: engine sound, full corpus green (or every regression explicitly recorded and triaged), full build green.

---

### 417. Semantic fmp finite worldstate over z
- **Effort**: medium
- **Status**: [RESEARCHED]
- **Task Type**: lean4
- **Topic**: paper-refactor
- **Dependencies**: Task 414, Task 420
- **Research**: [417_semantic_fmp_finite_worldstate_over_z/reports/01_semantic-fmp-finite-worldstate.md]

**Description**: Semantic FMP over a fixed carrier, stated against the refactored Omega-free maximal-history semantics of task 414 (PossibleWorlds Comments/fix.md C6; revised 2026-07-28): prove the TruthAt-connected finite model property the paper cor:tm-decidability proof text cites — any formula satisfiable over the Discrete class is satisfiable in a model with FINITE WorldState over D = Z — replacing reliance on the syntactic closure-MCS FMP theorems (Metalogic/Decidability/FMP/FMP.lean) that never connect to TruthAt. Add decidable model checking for the finite-W-over-Z presentation to back the paper enumeration argument (restated paper-side as finite W over Z, since every model has infinite D). This is the semantic-FMP follow-on explicitly descoped by task 165 redirect; the tableau programme (165/410-412) remains the decision-procedure route and also rebases onto the new semantics. Related: 165, 410, 411, 412.

LIMIT NULLITY NOTE (PossibleWorlds task 51; repo task 420): over D = Z the new Limit Nullity frame axiom is automatic (|y| < 1 forces y = 0, then nullity_identity), so the finite-W-over-Z programme is mathematically unaffected; the TaskFrame packaging in this task's construction must simply discharge the new field via 420's discrete helper.

---

### 416. Adopt co axiom basis for dedekind class
- **Effort**: large
- **Status**: [COMPLETED]
- **Task Type**: lean4
- **Topic**: paper-refactor
- **Dependencies**: None
- **Research**: [416_adopt_co_axiom_basis_for_dedekind_class/reports/01_co-axiom-basis-adoption.md]
- **Plan**: [416_adopt_co_axiom_basis_for_dedekind_class/plans/02_co-derived-reynolds-basis.md]
- **Summary**: [416_adopt_co_axiom_basis_for_dedekind_class/summaries/02_co-derived-reynolds-basis-summary.md]

**Description**: DEFINITIONAL ALIGNMENT (PossibleWorlds Comments/fix.md C4; INVERTED after research, user-ratified 2026-07-28: the Reynolds basis stays official and CO becomes derived — the reverse of this task's original framing). Research found strong evidence CO does NOT syntactically derive prior_U_gap/prior_S_gap/sep: the two bases are frame-equivalent (both pin Dedekind completeness) but plausibly NOT deductively equivalent — an independence-model sketch (Q-flow with isolated not-p points accumulating at an irrational from above, the classical Stavi US-vs-FO gap phenomenon) validates every CO instance while refuting Prior-U; the converse Reynolds |- CO derivation sketch does work. THEREFORE: (1) KEEP the Reynolds triple prior_U_gap/prior_S_gap/sep as the OFFICIAL Dedekind-class axiom basis — no basis swap, no two-basis bridge. (2) Add CO as a DERIVED internal theorem co_derived plus its validity lemma co_valid, where CO = triangle(H phi -> F(H phi)) -> (H phi -> G phi) with triangle phi := H phi and phi and G phi (the TEMPORAL triangle, not box); the CO formula is at PossibleWorlds/JPL/possible_worlds.tex:3250 (identical formula at current-tex line 1109 — note the top-level Papers/possible_worlds.tex has only 2253 lines and is NOT the right source). All needed operators (allPast/allFuture/someFuture/always) already exist in Formula.lean. (3) Route the paper-side correction back through fix.md C4 option 2, which explicitly contemplated switching the paper's basis: the paper's BX_c completeness claim is deferred to THIS repo with no independent citation, so def:TMplus-c is implicated and needs paper-side amendment. Under this inversion the 408/411 rebase surface is EMPTY (no downstream churn), and the 6 real DerivationTree.axiom consumption sites — 3 Chronicle limit-witness files plus 3 in ChronicleMonadicBridge feeding the Doets embedding, the latter having no CO-local workaround — stay untouched. (4) Record the Hoelder classification where cheap: pinned Mathlib v4.33.0-rc1 verified to PROVIDE LinearOrderedAddCommGroup.discrete_or_denselyOrdered / discrete_iff_not_denselyOrdered (GroupTheory/ArchimedeanDensely.lean, exact typeclass match with the repo's duration binders) and Archimedean.exists_orderAddMonoidHom_real_injective (Data/Real/Embedding.lean:232); verified ABSENT are "complete ordered group => Archimedean" (cheap ~20-line hand lemma, do it) and packaged "dense+complete group ~=+o R" (NOT cheap — docs, not a lemma); complete+discrete = Z is cheaply composable as a lemma. (5) Align FrameClass/Validity docs with the paper TM_c / TM+_dc distinction, noting complete-but-discrete is exactly Z (Discrete class). Related: 390, 408, 411.

---

### 415. Completeness over maximal history semantics
- **Effort**: large
- **Status**: [RESEARCHED]
- **Task Type**: lean4
- **Topic**: paper-refactor
- **Dependencies**: Task 414, Task 420
- **Research**: [415_completeness_over_maximal_history_semantics/reports/01_completeness-maximal-history-rebase.md]

**Description**: Completeness under the refactored (Omega-free, maximal-history) semantics of task 414 — INTERNALIZED, not bridged (PossibleWorlds Comments/fix.md B1/C2; revised 2026-07-28): restate and reprove WEAK completeness per frame class so the canonical/chronicle constructions deliver countermodels that are maximal-history models OUTRIGHT. The former singleton-Omega device (WeakCanonical/Transfer.lean:603-638) becomes: construct frames — deterministic frames are the lead, their maximal histories forming a single shift class — whose FULL maximal-history set is the required countermodel family; no transfer or realization lemmas in the final statements. Order: Discrete first (currently green under the old semantics), then Dense (task 170), Base (task 169), Dedekind (task 408), whose targets all rebase onto the new semantics. The mathematical content of realization is absorbed into the constructions; the headline theorems mention only the paper-aligned validity.

NEW OBLIGATION FROM THE PAPER FRAME REFACTOR (PossibleWorlds task 51; repo task 420): once TaskFrame carries the Limit Nullity field, every countermodel frame this task constructs must discharge it. Discrete class: automatic via 420's limit_nullity_of_discrete helper (free over Z). Dense, Dedekind, and Base canonical/chronicle constructions: GENUINE new per-class proof obligation -- verify the constructed task relation does not relate distinct states in arbitrarily small durations (for the deterministic lead frames, check the induced relation's small-duration behavior explicitly; the paper's three-state countermodel shows exactly how Nullity + Compositionality alone permit violations). Add this to each class's rebase checklist. A class whose canonical frame violates Limit Nullity needs a repaired construction, not a weakened axiom -- the axiom is settled paper-side (def:frame axiom iii).

---

### 414. Refactor semantics to maximal history validity
- **Effort**: large
- **Status**: [RESEARCHED]
- **Task Type**: lean4
- **Topic**: paper-refactor
- **Dependencies**: Task 420
- **Research**:
  - [414_refactor_semantics_to_maximal_history_validity/reports/01_maximal-history-validity-refactor.md]
  - [414_refactor_semantics_to_maximal_history_validity/reports/02_group-c-reconciliation.md]

**Description**: DEFINITIONAL ALIGNMENT (PossibleWorlds Comments/fix.md B1/C1; revised 2026-07-28: change the basic definitions, no bridge lemmas). Make maximal-history validity THE validity of the repo, eliminating the Omega parameter from the semantics core. (1) Define the extension order on WorldHistory (sigma extends tau iff tau.domain subset-of sigma.domain and states agree on tau.domain), the Maximal predicate, and prove: every history extends to a maximal one (Zorn) and maximality is preserved by time-shift — the paper re-verified both. (2) Refactor TruthAt, valid, satisfiable, and semantic consequence to quantify over MAXIMAL histories of the frame, removing Omega and ShiftClosed hypotheses everywhere; the false Set.univ-equivalence docstrings (Semantics/Validity.lean:33,70-71) disappear with the parameter. (3) Propagate through Soundness (expected to survive verbatim via Zorn extension + shift-preservation). NO compatibility shims, aliases, or parallel validity notions: one uniform Omega-free API. Downstream metalogic rebasing is task 415; 417 restates against this semantics.

FRAME-PRESENTATION COORDINATION (2026-07-28, PossibleWorlds task 51): the paper's def:frame has been refactored to the positive-cone presentation with Limit Nullity, Reflection demoted to a derived remark (supersedes fix.md A1). This task's charter (Omega-free maximal-history validity) is mathematically unaffected -- the paper's world-history apparatus gained only a converse-convention gloss, and the Zorn extension + shift-preservation claims were re-verified paper-side under the new axioms. Frame-axiom alignment (new Limit Nullity field, converse-as-definitional docstring recast, 02-Semantics.tex restatement) is owned by task 420, which this task now DEPENDS ON so the validity refactor lands once against the final TaskFrame structure. Any def:frame line-number citations in this task's research artifacts refer to the pre-refactor paper and must be re-anchored during implementation.

---

### 413. Formalize tm conservativity bridge
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: completeness
- **Dependencies**: None

**Description**: Formalize the TM+ over TM conservativity bridge in Lean 4 (paper thm:ConservativeExtension, CEB/CEF/CED/CEC): add a BL base-language Formula type with primitive box/G/H, its TM axiom set and derivation trees, a translation into the existing BL+ Formula type, and prove that TM+ derivability of a translated BL-formula yields TM derivability, supplying the missing step in the paper's cor:tm-completeness route

---

### 412. Prove refutation core and decidability of provability with completeness corollaries
- **Effort**: 10-15 hours
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Dependencies**: Task 165, Task 410, Task 411

**Description**: Track B finish for the TM tableau decidability program (parent: task 165; grounding: reports/02_tableau-decidability-hard-research.md sections 3.1, 8.3, 8.5). Create Verified/Refutation/Core.lean proving allClosed_derivable as ONE induction over allRulesForFC fc, discharging each rule by its admissibility lemma (predecessor tasks) and its ruleFrameClass r <= fc hypothesis via the RuleSpec GATE lemmas — Dense/Discrete/Dedekind instantiate the generic theorem, they do not re-prove it. Then Verified/Provable.lean: Decidable (Derivable fc [] phi) combining allClosed_derivable with Track A's buildTableau_isSome and not_valid_of_hasOpen; the completeness corollaries ValidFor fc phi -> Derivable fc [] phi; discharge the pre-existing sorry countermodel_discrete at FormalSystem/Metalogic/WeakCanonical/Transfer.lean:1242; and supply the Dedekind engine consumed by completeness_dedekind_of_engine (StrongCompleteness.lean:308, target ValidDedekindDense). Acceptance: zero sorries repo-wide outside Boneyard; lake build green; update typst/latex decidability chapters to record headline result 2.

---

### 411. Prove hard admissibility lemmas for until since trichotomy discrete and dedekind rules
- **Effort**: 15-20 hours
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Dependencies**: Task 165, Task 410

**Description**: Track B part 2 for the TM tableau decidability program (parent: task 165; grounding: reports/02_tableau-decidability-hard-research.md sections 3.2-3.3 and 10). First run a /literature acquisition pass for Reynolds 1992 and Reynolds 2003 (the untlNeg co-decomposition and the Dedekind gap axioms; report 02 section 10 flags in-repo literature as thin). Then prove the hard admissibility block in Verified/Refutation/Rules/{UntilSince,Trichotomy,Discrete,Dense,Dedekind}.lean: untlPos (branch 1 via until_F, branch 2 via self_accum_until — follow the axiom literally), untlNeg (Reynolds co-decomposition via absorb_until + left_mono_until_G; the single largest lemma — budget it its own dispatch), sncePos/snceNeg duals, orderTrichotomy (one-liner if Phase 2.2 kept branches syntactically equal to temp_linearity disjuncts — verify, do not assume), z1Rule (two-premise instance of z1 + two modus ponens, relies on same-label internalization from the predecessor task), densityRule/denseIndicatorClosure via density/dense_indicator, and the Dedekind rules via prior_U_gap/prior_S_gap/sep. Acceptance: all admissibility lemmas sorry-free; lake build green.

---

### 410. Internalize tableau branches and prove routine rule admissibility
- **Effort**: 12-18 hours
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Dependencies**: Task 165

**Description**: Track B part 1 for the TM tableau decidability program (parent: task 165, plan plans/01_tableau-decidability-two-track.md, research reports/02_tableau-decidability-hard-research.md sections 3.1-3.4). Create FormalSystem/Metalogic/Decidability/Verified/Internalize.lean defining Branch.internalize (world labels via box/diamond nesting, time labels via U/S guards realizing the branch TimeOrdering; SETTLED constraints: internalization design over substitution — no cut or uniform-substitution admissibility exists in the tree — and z1Rule's two premises must stay at the same label). Then prove the routine admissibility lemmas in Verified/Refutation/Rules/{Propositional,Modal,Temporal}.lean (~21 lemmas: 8 propositional, 4 S5 modal, 1 boxTemporal, 8 temporal universal/existential), each stated as rule_admissible per report 02 section 3.1 with hypothesis ruleFrameClass r <= fc, reusing Combinators.lean, ModalS5.lean, TemporalDerived.lean, GeneralizedNecessitation.lean, and DeductionTheorem.lean via DerivationTree.lift. Acceptance: all lemmas sorry-free, lake build green, RuleSpec GATE lemmas still green.

---

### 409. Reconcile latex metalogic docs with live tree
- **Effort**: medium
- **Status**: [COMPLETED]
- **Task Type**: general
- **Topic**: documentation
- **Dependencies**: None
- **Research**: [409_reconcile_latex_metalogic_docs_with_live_tree/reports/01_latex-metalogic-live-tree-audit.md]
- **Plan**: [409_reconcile_latex_metalogic_docs_with_live_tree/plans/01_latex-metalogic-reconcile.md]
- **Summary**: [409_reconcile_latex_metalogic_docs_with_live_tree/summaries/01_latex-metalogic-reconcile-summary.md]

**Description**: Systematically reconcile the LaTeX reference (latex/subfiles/, especially 04-Metalogic.tex and 06-Notes.tex) with the live FormalSystem/ tree and the settled completeness terminology. The TERMINOLOGY pass already landed (2026-07-27): "strong completeness" is reserved for infinite premise sets, the finite-context form is named consequence completeness, and 04-Metalogic.tex now carries a "Strong Completeness and Compactness" subsection with the per-class split (Base/Dense open; Discrete/Dedekind provably non-compact) — see specs/ROADMAP.md ("Completeness programme" block) and the FormalSystem/Metalogic/StrongCompleteness.lean module docstring for the authoritative statements. What remains, and what this task owns, is ARCHITECTURE/IDENTIFIER fidelity: the chapter still largely describes the retired Metalogic_v2 (Boneyard) architecture.

SCOPE:
(1) Identifier audit: check every \texttt{...} Lean identifier in latex/subfiles/ against the live tree (grep, excluding Boneyard/). Known-stale already: semantic_weak_completeness, main_provable_iff_valid(_v2), representation_theorem, strong_representation_theorem, deduction_theorem (live names: deductionTheorem / Derivable.deduction, Metalogic/Core/DeductionTheorem.lean), truth_lemma path (cited as Metalogic/Representation/TruthLemma.lean, which does not exist), semantic_task_rel_compositionality, finite_model_property_constructive, semantic_truth_lemma_v2, IndexedMCSFamily, canonical_model. The "Implementation Status" subsection describes Metalogic_v2 sorries and module layout (Core/, Soundness/, Representation/, Completeness/, Applications/, FMP.lean) that no longer exist.
(2) Restate the completeness-proof narrative around the live architecture: per-class weak termini (completeness at Metalogic/BXCanonical/Completeness.lean:196, completeness_dense :255, completeness_discrete :296 — the latter two sorryAx-free with axioms [propext, Classical.choice, Quot.sound]; completeness_dedekind in flight via the limit-MCS route), consequence completeness (StrongCompleteness.lean), and the chronicle/parametric canonical machinery actually used (Metalogic/Core, BXCanonical + Chronicle, WeakCanonical/Kamp, Algebraic parametric truth lemma, Bundle FMCS/BFMCS) instead of the retired quotient/semantic-canonical story where the two diverge.
(3) Update the two tikz diagrams (theorem dependency structure; directory structure) and the status tables to the live module layout and live theorem names; remove or historicize the Metalogic_v2 sorry inventory.
(4) Verify compilation: pdflatex -interaction=nonstopmode with TEXINPUTS=../assets: from latex/subfiles/ (formatting.sty lives in latex/assets/); both 04-Metalogic.tex and 06-Notes.tex currently compile standalone and must still compile after the rewrite.

COORDINATION: task 362 leg D owns stating the genuine strong-completeness results (and any further restatement) once the per-class consequence/strong results land; this task owns bringing the existing chapter to identifier/architecture fidelity now. Do not duplicate. Per .claude/rules/no-task-references-in-deliverables.md, do not cite task numbers inside the .tex files — reference module names and theorem identifiers instead.

SCOPE BOUNDARY ADDENDUM (2026-07-28): the frame-definition subsection of latex/subfiles/02-Semantics.tex is owned by task 420 (positive-cone + Limit Nullity restatement following the paper's task-51 def:frame refactor); this task continues to own 04-Metalogic.tex and 06-Notes.tex identifier/architecture fidelity. Do not duplicate.

---

### 408. Faithful route to strong completeness for the dedekind extension
- **Status**: [IMPLEMENTING]
- **Task Type**: lean4
- **Topic**: completeness
- **Dependencies**: None
- **Research**: [408_faithful_route_to_strong_completeness_for_the_dedekind_extension/reports/09_lemma6-first-clause-blocker.md]
- **Plan**: [408_faithful_route_to_strong_completeness_for_the_dedekind_extension/plans/10_strong-completeness-dedekind-v10.md]
- **Summary**: [408_faithful_route_to_strong_completeness_for_the_dedekind_extension/summaries/32_theorem6-g-minimality-and-quotient-summary.md]

**Description**: Identify and implement the most faithful and mathematically correct route to completeness for FrameClass.Dedekind (the Dedekind-complete extension of the Base and Dense logics).

TARGET (SETTLED 2026-07-27 by the project-wide terminology settlement; this paragraph replaces the former "TARGET IS SETTLED: strong completeness is the goal" directive, which is SUPERSEDED and must not be reinstated): the class HEADLINE is weak completeness `completeness_dedekind`, together with the finite-context consequence form `consequence_completeness_dedekind` (formerly misnamed "strong_completeness_dedekind"), the two being inter-derivable via the deduction theorem. Project-wide, "strong completeness" is RESERVED for consequence from possibly-infinite premise sets (Γ : Set Formula) with finitary set-derivability. Genuine strong completeness is PROVABLY UNAVAILABLE for this class: the Dedekind consequence relation is not compact (Reynolds 1992 §2, printed p.169; his Theorem 7, printed p.189, is explicitly "sound and weakly complete" and the restriction is genuine). A derivation is finite and can cite only finitely many premises, so strong completeness for a finitary derivability relation would entail compactness. It is REFUTED, not deferred — no strengthening of the countermodel construction can reach it. Do NOT reintroduce the "strong" name for any finite-context result, and do NOT treat the weak headline as a shortfall. See FormalSystem/Metalogic/StrongCompleteness.lean's module docstring for the per-class programme and plan v10's Reframing Note.

WHY THIS IS NOT MERELY "EXECUTE THE 390 PLAN": the route proposed in specs/390_dedekind_carrier_construction_research/reports/01_dedekind-carrier-construction.md is Reynolds' transfer argument. That report correctly identifies Reynolds 1992 Theorem 7 as weak completeness. Under the settled target above this is no longer a mismatch: weak completeness IS the terminus, so the Reynolds/Doets route is the faithful one. The remaining question is which construction discharges it most faithfully, not whether it reaches an infinitary statement.

DESIGN CONSTRAINT FROM THE USER: avoid needless bridges. Prefer the construction that is faithful to the mathematics over one that accumulates intermediate scaffolding, adapter lemmas, or bespoke bridge predicates. If a proposed step exists only to connect two artifacts the tree happens to already have, that is evidence the route is wrong, not evidence a bridge is needed. This applies specifically to the phase-5 gap-freeness bridge (Gap-free <-> conditionally complete for the dense case), which was NOT authorized as standalone work and should only appear if the faithful route genuinely requires it.

CURRENT STATE (verified 2026-07-27, do not re-derive from stale notes):
- Soundness is COMPLETE. FrameClass.Dedekind exists (ProofSystem/Axioms.lean:453) with the Base < Dense < Dedekind chain; the three Reynolds axioms prior_U_gap/prior_S_gap/sep exist (:377,:387,:398) with minFrameClass at :524-526; ValidDedekind and ValidDedekindDense exist (Semantics/Validity.lean:231,:255); all three axioms and the sep temporal dual are proved valid; soundness_dedekind is assembled at Metalogic/Soundness.lean:1910. Soundness.lean is at ZERO sorries.
- The terminus scaffolding EXISTS and is pinned: consequence_completeness_dedekind_of_engine, completeness_dedekind_of_engine, soundness_dedekind_consequence, and SemanticConsequenceDedekindDense are landed in Metalogic/StrongCompleteness.lean and are [COMPLETED]. What remains is discharging the `engine` hypothesis (one formula in, one derivation from the empty context out).
- completeness_dense and completeness_discrete exist and are sorryAx-free (Metalogic/BXCanonical/Completeness.lean:255,:296).
- The only live sorry outside Boneyard is Metalogic/WeakCanonical/Transfer.lean:1242, on the DISCRETE countermodel branch (a Base-MCS -> Discrete-MCS gap). It blocks general `completeness` and is not on the Dedekind route.

THREE KNOWN OBSTRUCTIONS the work must address explicitly:
1. The input model does not exist. Reynolds' step 1 needs a Q-flowed model validating Prior-U/Prior-S/Sep. The tree's countermodel_dense_enriched (Metalogic/BXCanonical/Completeness.lean:133) produces a Q model for FrameClass.Dense (density + dense_indicator) -- a different axiom set.
2. TRAP -- the Base-MCS problem applies verbatim. Completeness.lean:178-193 documents why general `completeness` carries sorryAx: a Base-MCS is not automatically Discrete-consistent. A Dedekind variant hits the structurally identical problem, since a Base-MCS need not validate Prior-U/Prior-S/Sep. Any countermodel must be built from an MCS of its own class. A proof that reuses the dense pipeline's MCS will look complete and be unsound at the seam.
3. The transfer engine is Z-specialized. Metalogic/WeakCanonical/IntegerModel/ has the right primitives (good, VeryGood, ContempEquiv, k_equiv_of_iso, KEquiv, orderedSumPt) but its engine is subinterval_finite_of_succ_archimedean -- a FINITENESS argument with no dense analogue.

DO NOT ASSUME THE BIMODAL GRAFT IS FREE. The completed sep_valid work found the bimodal graft trivial for SOUNDNESS, because Sep's operators are all temporal evaluated at a fixed history, so the statement reduced to pure order theory. That result does NOT transfer to completeness, where the construction must PRODUCE histories rather than evaluate at one. Research task 390 flagged grafting a monadic-FO transfer argument onto TaskFrame/WorldHistory/Omega/ShiftClosed semantics as genuinely new work not present in any source read.

COORDINATE WITH the completeness architecture axis: tasks 361 (strong_completeness_architecture_and_weak_terminus_gap_analysis, completed) and 362 (completeness_capstone_consequence_all_classes_strong_where_compact). Per-class status recorded there and in StrongCompleteness.lean: strong completeness is refuted for Dedekind and for Discrete (witness {F p} u {not X^n p : n}, finitely satisfiable over Z but unsatisfiable over any Archimedean discrete carrier -- task 425 machine-checks it), and OPEN for Base and Dense, whose binder lists impose no Archimedean-ness (tasks 423, 424). If the faithful Dedekind route is subsumed by that architecture, say so plainly rather than proposing a parallel construction.

LITERATURE: run with --lit. Primary sources already local: /home/benjamin/Projects/Literature/sources/reynolds_1992/ (all sections; sec04 is the separability section). GHR 1994 chapter 10 treats Dedekind completeness as a HYPOTHESIS rather than deriving it, per 390's Finding 3. Doets' theorem is reached via Reynolds section 8 (printed pp.184-188, lemmas 11-13). Read verbatim; do not reconstruct statements from memory.

DONE WHEN: `completeness_dedekind` and `consequence_completeness_dedekind` are landed unconditionally (the `engine` hypothesis discharged), sorry-free and axiom-clean outside Boneyard, with lake build green; the faithful route is justified against at least one rejected alternative; and it is recorded which existing tree assets are genuinely reused versus which would have been needless bridges. If some sub-goal turns out to be unreachable, say so honestly and state what would have to change. Do NOT state, name, or gesture at an infinite-premise completeness result for this class.

---

### 390. Dedekind carrier construction research
- **Effort**: large
- **Status**: [COMPLETED]
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

### 362. Completeness capstone consequence all classes strong where compact
- **Effort**: high
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: strong_completeness
- **Dependencies**: Task 361, Task 375, Task 169, Task 170

**Description**: Implement the completeness capstone under the SETTLED TERMINOLOGY (2026-07-27): "strong completeness" is reserved for consequence from possibly-infinite premise sets (Γ : Set Formula) with finitary set-derivability; finite-context (Context = List Formula) consequence statements are inter-derivable with weak completeness via the deduction theorem and are named CONSEQUENCE completeness, never strong. (This task was formerly "main_strong_completeness: finite-context strong completeness" — that framing was misleading and is retired.)

SCOPE:
(A) Finite-context CONSEQUENCE completeness for all four frame classes. For each X ∈ {Base, Dense, Discrete}: define SemanticConsequenceX (Γ : Context) (paralleling the ValidX binder list), prove the semantic deduction lemma, and prove consequence_completeness_X : SemanticConsequenceX Γ φ → Derivable FrameClass.X Γ φ via (a) the semantic deduction lemma, (b) the class's weak completeness engine, (c) the fc-generic derivable_foldr_imp_iff. The Dedekind instance and all the generic lemmas (truthAt_foldr_imp, derivable_of_derivable_foldr_imp, derivable_foldr_imp_of_derivable, derivable_foldr_imp_iff) ALREADY EXIST in FormalSystem/Metalogic/StrongCompleteness.lean (landed by task 408 phase 2, reframed 2026-07-27) — follow its three-declaration shape and drop the Base/Dense/Discrete instances into that file's reserved sections. Weak completeness for each class stays re-exposed as the Γ=[] corollary (exactly one proof of the weak form per class, as a corollary). State conclusions as `Derivable` (definitionally Nonempty (DerivationTree ...), ProofSystem/Derivable.lean:69), matching the existing weak termini.
(B) GENUINE strong completeness (Γ : Set Formula with finitary set-derivability) for Base and Dense ONLY, conditional on task 361's feasibility verdict and gated on the set-based model-existence theorem it scopes (every SetConsistent set satisfiable in a class frame). If 361 returns a non-compactness verdict for Base or Dense, record the counterexample and downgrade that leg to consequence-only, matching Discrete/Dedekind.
(C) Discrete and Dedekind get NO strong form — both provably non-compact (Discrete: the {F p} ∪ {¬Xⁿ p : n} witness under IsSuccArchimedean, since next = untl φ bot is definable; Dedekind: Reynolds 1992 Thm 7 weak-only, restriction genuine). The StrongCompleteness.lean section headers already document this; optionally land the formalized Discrete non-compactness witness if 361 scoped it.
(D) LaTeX alignment: restate latex/subfiles/04-Metalogic.tex so "Strong Completeness" (main_strong_completeness, :266; identifier also at :211, :490) is used ONLY for the Set Formula statement (stated for Base/Dense if reachable, with the non-compactness of Discrete/Dedekind recorded), presenting the finite-context result as consequence completeness derived from weak completeness; resolve that file's "Note on Infinite Contexts" TODO accordingly.

VERIFIED ANCHORS (re-checked 2026-07-27):
  - FormalSystem/Metalogic/BXCanonical/Completeness.lean:196 `completeness`; :255 `completeness_dense`; :296 `completeness_discrete` (base validity predicate is lowercase `valid`; dense/discrete are ValidDense/ValidDiscrete — Semantics/Validity.lean:79, :169, :187).
  - FormalSystem/Metalogic/StrongCompleteness.lean — module docstring carries the per-class programme and reserved sections; Dedekind instance complete modulo its engine (consequence_completeness_dedekind_of_engine, completeness_dedekind_of_engine).
  - Syntactic deduction theorem: FormalSystem.ProofSystem.Derivable.deduction (Metalogic/Core/DeductionTheorem.lean:467, Prop-level), data-level deductionTheorem at :325, deductionConverse at :447.
  - Set-based MCS layer (for leg B): SetConsistent/SetMaximalConsistent/set_lindenbaum, Metalogic/Core/MaximalConsistent.lean:96/:103/:303. SetConsistent is already finitary (every finite sublist consistent).
  - Frame-class-agnostic SemanticConsequence (Γ : Context) exists at Semantics/Validity.lean:103 with notation Γ ⊨ φ at :114 — it quantifies over ALL carriers and is NOT the per-class relation; per-class variants named in UpperCamel (Prop-valued definitions), theorem names snake_case.
  - Update the tracking table in FormalSystem/Metalogic.lean (the file at the FormalSystem/ root, NOT FormalSystem/Metalogic/Metalogic.lean, which does not exist).

Axioms exactly [propext, Classical.choice, Quot.sound] modulo whatever the underlying weak terminus already carries; leg A sorry-free once the three weak termini are green.

DEPENDENCY STATUS (2026-07-27; dependencies array unchanged): 375 (discrete weak terminus) COMPLETED — completeness_discrete/completeness_dense kernel-verify to the pristine axiom set. 169 (base weak) not_started. 170 (dense weak) not_started. 361 (terminology/architecture research + set-based layer design + Base/Dense compactness verdict) not_started — leg B is additionally gated on 361's verdict and the model-existence tasks it spawns; legs A/C/D are not.

---

### 361. Strong completeness architecture and weak terminus gap analysis
- **Effort**: high
- **Status**: [COMPLETED]
- **Task Type**: lean4
- **Topic**: strong_completeness
- **Dependencies**: None
- **Research**: [361_strong_completeness_architecture_and_weak_terminus_gap_analysis/reports/01_strong-completeness-architecture-gap-analysis.md]
- **Plan**: [361_strong_completeness_architecture_and_weak_terminus_gap_analysis/plans/01_strong-completeness-scoping.md]
- **Summary**: [361_strong_completeness_architecture_and_weak_terminus_gap_analysis/design/04_subtask-decomposition.md]

**Description**: Research + scoping for the completeness-terminology refactor and the genuine strong-completeness architecture. TERMINOLOGY IS SETTLED (2026-07-27): "strong completeness" is reserved for consequence from possibly-INFINITE premise sets (Γ : Set Formula) with finitary set-derivability (∃ L : List Formula, (∀ ψ ∈ L, ψ ∈ Γ) ∧ Derivable fc L φ). Finite-context (Context = List Formula) consequence statements are inter-derivable with weak completeness via the deduction theorem and are named CONSEQUENCE completeness, never strong (see FormalSystem/Metalogic/StrongCompleteness.lean module docstring, reframed 2026-07-27, for the per-class programme).

Deliverables:
(1) Design the set-based layer: per-class SetSemanticConsequence_X (Γ : Set Formula) (φ : Formula) paralleling the valid/ValidDense/ValidDiscrete binder lists in Semantics/Validity.lean; the finitary set-derivability relation; and their basic lemmas (monotonicity, finite-restriction). The set-based MCS layer already exists and is correctly finitary — SetConsistent, SetMaximalConsistent, set_lindenbaum in Metalogic/Core/MaximalConsistent.lean (:96, :103, :303).
(2) Feasibility verdict on GENUINE strong completeness per class. Already established, do not re-derive: Discrete is provably NON-COMPACT — ValidDiscrete requires IsSuccArchimedean/IsPredArchimedean, and Formula.next φ = untl φ bot is a genuine next-step operator on discrete orders, so {F p} ∪ {¬Xⁿ p : n ∈ ℕ} is finitely satisfiable over ℤ yet unsatisfiable over every Archimedean discrete carrier — hence weak completeness only. Dedekind is likewise non-compact (Reynolds 1992 Thm 7 is weak-only and the restriction is genuine) — weak completeness only, owned by task 408. OPEN QUESTION this task must answer: whether Base and Dense (neither binder list imposes Archimedean-ness, so no known counterexample applies; classical Burgess-style strong completeness for the ℚ tense logic suggests plausibility) are compact under the FULL task-frame semantics (S5 box over shift-closed Omega, ordered-abelian-group time). For Base/Dense, determine whether the BXCanonical chronicle machinery (which already manipulates Set Formula MCSs internally) extends to a MODEL-EXISTENCE theorem — every SetConsistent set is satisfiable in a frame of the class. That theorem is the substantive new obligation; the single-formula countermodel engines do NOT suffice for it.
(3) Authoritative gap analysis of what still gates each WEAK terminus (unchanged charter): Base = the open sorries reachable from `completeness` (BXCanonical/Completeness.lean:196 — dense-arm countermodel_dense, the deprecated countermodel_discrete Transfer.lean route, dd_countermodel_chronicle_mixed_sorry); Dense = the chronicle dense-path sorries inherited by `completeness_dense` (:255) (ChronicleToCountermodel.lean succ_reaches_dom_N / chronicle_gap_contradiction; MCSMixedCase.lean). Produce a concrete sub-task decomposition + dependency graph for tasks 169 (base weak) and 170 (dense weak), PLUS new model-existence sub-tasks for the Base/Dense strong legs if the feasibility verdict is positive, spawning refinements as needed.
(4) Optionally scope formalizing the Discrete non-compactness witness as a documented theorem (satisfiable-finitely-but-not-globally), so the weak-only status of Discrete is machine-checked rather than prose.

Reference: FormalSystem/Metalogic/StrongCompleteness.lean (per-class programme + reserved section headers); latex/subfiles/04-Metalogic.tex §Completeness-as-Corollary "Note on Infinite Contexts" and its TODO (the LaTeX restatement is owned by task 362). Analysis/read task — no proof obligations to close here.

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
- **Dependencies**: Task 165, Task 402
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
- **Status**: [COMPLETED]
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
- **Status**: [COMPLETED]
- **Task Type**: lean4
- **Topic**: strong_completeness
- **Dependencies**: Task 361

**Description**: Dense (FrameClass.Dense) WEAK completeness — SUBSTANTIVELY CLOSED. NO IMPLEMENTATION AGENT SHOULD BE DISPATCHED AT THIS TASK.

VERIFIED STATUS (2026-07-28, from task 361's design/03_weak-terminus-status.md section 1): `completeness_dense` (BXCanonical/Completeness.lean:255) is already machine-verified sorry-free. `lean_verify` against current oleans reports `#print axioms completeness_dense` = [propext, Classical.choice, Quot.sound] — no `sorryAx`.

WHY THE EARLIER DESCRIPTION WAS STALE: it named three inherited chronicle dense-path obligations. All three are gone from live code — two survive only under `Boneyard/` sub-trees, and the third file exists but is sorry-free (its mixed-case closer, `Chronicle.mcs_mixed_case_absurd`, is what discharges that case). None of the three is reachable from `completeness_dense`. The itemized correction table, naming each stale claim against its actual state, is design/03 section 3; it is deliberately not reproduced here so this description cannot be mistaken for a live obligation list. There are exactly TWO live non-Boneyard sorries in the whole tree — `Transfer.lean:1242` (task 169's) and `RealModel/ShuffleReal.lean:201` (task 408's) — and neither is reachable from `completeness_dense`.

THE SINGLE REMAINING ACTION, and it is administrative, not Lean work: a build-lock holder runs an independent CLEAN-BUILD `#print axioms FormalSystem.Metalogic.BXCanonical.completeness_dense`. (Task 361's verification consumed existing oleans; a clean-build re-verification is the stronger evidence the closure should rest on.) If it reports exactly `propext, Classical.choice, Quot.sound`, transition this task to [COMPLETED] with a completion summary recording that axiom set verbatim.

The status transition was deliberately NOT performed by task 361, which held no build lock and therefore could not produce the clean-build evidence.

ROLE IN THE COMPLETENESS PROGRAMME (terminology settled 2026-07-27): this is the headline WEAK terminus for Dense, consumed by the consequence-completeness capstone (task 362) as its single-formula engine. The weak engine yields only the finite-context consequence corollary (inter-derivable with weak completeness via the deduction theorem — deliberately NOT called "strong completeness"). Genuine STRONG completeness for Dense (Γ : Set Formula) additionally requires semantic compactness, gated on task 424; that obligation is NOT discharged by this task. Because this weak engine is already green, DENSE IS THE NATURAL FIRST STRONG-COMPLETENESS TARGET — it does not wait on the Base weak terminus.

Governing design document: specs/361_strong_completeness_architecture_and_weak_terminus_gap_analysis/design/03_weak-terminus-status.md section 4.

---

### 169. Complete frame extension setup and soundness
- **Effort**: high
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: strong_completeness
- **Dependencies**: Task 361, Task 422

**Description**: Base (FrameClass.Base / general) WEAK completeness green: make the empty-context theorem `completeness` (BXCanonical/Completeness.lean:196, `valid φ → Derivable FrameClass.Base [] φ`) genuinely sorry-free.

CORRECTED SCOPE (2026-07-28, from task 361's design/03_weak-terminus-status.md): this task's earlier description named THREE open sorries. That was stale. `completeness` has EXACTLY ONE reachable sorry: `WeakCanonical.countermodel_discrete` at `FormalSystem/Metalogic/WeakCanonical/Transfer.lean:1242`. Machine-verified this session via `lean_verify`: `#print axioms completeness` = [propext, sorryAx, Classical.choice, Quot.sound], with `Transfer.lean:1242` the sole `sorryAx` source. The other two the old description named are gone from live code — the dense arm now runs through `countermodel_dense_enriched` (Completeness.lean:133, called at :221), which is sorry-free, and the mixed case is closed by `Chronicle.mcs_mixed_case_absurd` (MCSMixedCase.lean, called from Completeness.lean:231), also sorry-free. `dd_countermodel_chronicle_mixed_sorry` is archived.

ROUTE (settled by task 361, design/03 sections 5.3-5.7):
- Route (i) — a Base-MCS → Discrete-MCS transfer lemma letting `countermodel_discrete_reynolds_v2` apply (the route the Transfer.lean docstring currently proposes) — is REFUTED and MUST NOT be re-attempted. Witness: over `ℤ ×ₗ ℤ` with `p` true exactly at points ≥ (1,0), `□U(⊤,⊥)` holds everywhere while `Axiom.z1 p` is false at (0,0); so a Base-MCS containing `□U(⊤,⊥)` need not be Discrete-consistent.
- Route (iii) — reuse the existing ℚ dense chronicle — is BLOCKED: `box_dense_gives_density` (ChronicleToCountermodelBasic.lean:435) is load-bearing for the ℚ Cantor isomorphism and is unavailable when the order is discrete.
- Route (ii) — direct construction over the NON-ARCHIMEDEAN discrete carrier `ℚ ×ₗ ℤ` — is RECOMMENDED. `FrameClass.Base` imposes no Archimedean-ness (`valid`, Validity.lean:79, has no `IsSuccArchimedean` binder), so the ℤ+ℤ shape that killed the old BX `succ_cofinal` pipeline is not a counterexample here — it is the intended carrier. Do not re-attempt `succ_cofinal`.

DEPENDENCIES: task 421 corrects the refuted route guidance in Transfer.lean and probes the carrier's Mathlib instances; task 422 builds the discrete chronicle over that carrier plus its three restricted-coherence analogues. THIS task consumes 422's output to close `countermodel_discrete`, delete the Transfer.lean sorry, and re-verify `#print axioms completeness` reports no `sorryAx`.

ROLE IN THE COMPLETENESS PROGRAMME (terminology settled 2026-07-27): this is the headline WEAK terminus for Base, consumed by the consequence-completeness capstone (task 362) as its single-formula engine. The weak engine yields only the finite-context consequence corollary (inter-derivable with weak completeness via the deduction theorem — deliberately NOT called "strong completeness"). Genuine STRONG completeness for Base (Γ : Set Formula) additionally requires semantic compactness, gated on task 424; that obligation is NOT discharged by this task.

Governing design document: specs/361_strong_completeness_architecture_and_weak_terminus_gap_analysis/design/03_weak-terminus-status.md.

---

### 165. Establish semantic finite model property
- **Status**: [IMPLEMENTING]
- **Task Type**: lean4
- **Topic**: completeness
- **Dependencies**: Task 418
- **Plan**: [165_establish_semantic_finite_model_property/plans/01_tableau-decidability-two-track.md]
- **Research**: [165_establish_semantic_finite_model_property/reports/06_soundfuel-decision.md]
- **Summary**: [165_establish_semantic_finite_model_property/summaries/19_phase8-vacuous-theorem-hygiene-summary.md]

**Description**: Establish verified decidability of TM bimodal logic for all four frame classes (Base, Dense, Discrete, Dedekind) by completing the tableau decision procedure in FormalSystem/Metalogic/Decidability/ into a fully proved decidability result. This redirects the task away from the semantic finite model property: the semantic FMP is now out of scope (an optional follow-on), though the existing research report (reports/01_semantic-fmp-research.md) remains valid background and its documentation-defect findings are retained below.

CURRENT STATE (sound-only). The tableau stack exists and builds: a 28-rule calculus in Tableau.lean (23 base rules in allRules, 2 in denseRules, 3 in discreteRules), fuel-based saturation with blocking plus AppliedSet and EventualityTracker (Saturation.lean), per-frame-class closure detection (Closure.lean), and the entry point `decide` (DecisionProcedure.lean:128). Valid answers do carry proof terms, but the stack is sound only, and three gaps block any decidability theorem: (a) closed-tableau proof extraction (`extractProof`, ProofExtraction.lean:258) is a best-effort runtime search over 5 strategies that can fail, returning `.timeout` even on a genuinely closed tableau; (b) there is NO termination theorem -- `soundFuel` (Saturation.lean:627) caps at `min bound 100000` with nothing proved about it, and the original `blocking_terminates` was found FALSE (see the status discussion at Saturation.lean:1028-1060); (c) countermodel extraction proves `branchTruthLemma` (CountermodelExtraction.lean:1044) only over a bespoke `branchTruth` semantics (CountermodelExtraction.lean:263 -- direct-successor Until/Since, box quantified over a finite world list) that is NOT connected to the repository's real `TruthAt`/`valid`.

WORK PACKAGES, in recommended order.

WP1 -- Adversarial calculus-adequacy probe (must come first; top risk). The branch's `TimeOrdering` is a partial order while real TM time is linear, and the calculus appears to lack an ordering-trichotomy/linearity branching rule for freshly introduced times. Probe whether an open saturated branch can fail to admit any linear model. Also probe Until-guard interpolation at times not present on the branch, and blocking-vs-truth-lemma compatibility (blocked branches will need an unwinding argument). This package comes first because a negative result forces rule additions, which would invalidate every downstream proof in WP2-WP4.

WP2 -- Refutation meta-theorem (closed tableau to Derivable). Replace runtime proof extraction with a theorem of the form `allClosed tableau -> Derivable fc [] phi`, established via per-rule admissibility lemmas in the Hilbert system across all ~28 rules. The untlPos/untlNeg Reynolds decomposition and z1Rule are the hard cases. The existing runtime strategies in ProofExtraction.lean are retained only as fast paths, no longer as the correctness story.

WP3 -- Termination theorem. Prove a generalized subformula property covering every rule in `applyRule` (the current `subformula_property` at Saturation.lean:1014 covers only the initial branch), then a pigeonhole argument on at most 2^(2n) distinct time types showing that blocking must fire, and finally an uncapped, justified fuel function with a theorem of the form `buildTableau phi (soundFuel' phi) fc = some _`.

WP4 -- Semantic bridge (open saturated branch to not-valid). This is the mathematical core, comparable in weight to a canonical-model completeness proof. Embed the finite branch time order into an actual temporal type D (arbitrary, Q, Z, or R according to frame class), interpolate valuations so that the real Until/Since guard conditions hold at in-between times, construct genuine WorldHistories and a shift-closed Omega, and prove `not TruthAt` -- thereby replacing the bespoke `branchTruth` semantics with the real one.

ASSEMBLY AND PAYOFF. WP2 + WP3 + WP4 together yield `Decidable (Derivable fc [] phi)` and decidability of validity for each frame class. As a corollary they also yield completeness for all four classes, which discharges the repository's single live sorry -- `countermodel_discrete` at FormalSystem/Metalogic/WeakCanonical/Transfer.lean:1242, which currently taints Base `completeness` -- and supplies the missing Dedekind engine required by `completeness_dedekind_of_engine` (StrongCompleteness.lean:308, via `consequence_completeness_dedekind_of_engine` at :274).

DEDEKIND CAVEAT. `allRulesForFC` (Tableau.lean:1067) gates dense rules on `Dense <= fc` and discrete rules on `Discrete <= fc`; since the FrameClass order (Axioms.lean:456-463) makes `Dense <= Dedekind` true but `Discrete <= Dedekind` false, the Dedekind class receives only the Base + Dense rules. Adequacy for Dedekind must therefore be proved rather than assumed: finite branch models do embed into R, but this requires an actual theorem.

HYGIENE SUBTASK. Delete or replace the two vacuous theorems `validity_decidable` and `validity_has_decision_procedure` (Decidability/Correctness.lean:78 and :91 -- both are mere `Classical.em`/`by_cases` tautologies), and the `and True`-padded `filtered_world_bound` and `fmp_size_bound` (Decidability/FMP/FMP.lean:183 and :237). Also correct the LaTeX and Typst documentation that currently cites the unproven 2^|cl(phi)| bound as an established result.

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
- **Dependencies**: Task 165, Task 408, Task 412

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
