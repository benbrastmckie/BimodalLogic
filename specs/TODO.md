---
next_project_number: 352
---

# TODO

Warning: 2 task(s) have no topic and will render under Uncategorized: 298, 341 (non-fatal)
## Task Order

*Updated 2026-07-12. Generated from state.json dependency graph.*

**Dependency Waves**:
| Wave | Tasks | Blocked by | Topics |
|------|-------|------------|--------|
| 1 | 125,127,128,131,161,162,165,169,170,175,179,180,186,187,188,189,191,194,199,219,230,257,282,290,291,296,318,341,343,349 | -- | completeness, formula-refactor, frame-extensions, ... |
| 2 | 192,196,231,292,293,294,298,350 | 161,187,191,194,230,291,343,349 | publication-quality, sorry-elimination, automation, ... |
| 3 | 193,309 | 189,192,196,350 | automation, kamp_theorem_formalization |
| 4 | 177,178,307 | 131,193,309 | completeness, formula-refactor |
| 5 | 305 | 307 | completeness |
| 6 | 303 | 305 | completeness |
| 7 | 95,299 | 303 | completeness |

**Grouped by Topic** (indented = depends on parent):

### Completeness

165 [NOT STARTED] — Establish the semantic finite model property for TM bimodal logic
169 [NOT STARTED] — complete_frame_extension_setup_and_soundness
170 [NOT STARTED] — complete_dense_extension_completeness
95 [NOT STARTED] — Verification pass on sorry status for completeness_discrete and b
299 [NOT STARTED] — Refactor DiscreteGameTransfer.lean to eliminate the wrapper patte
303 [PLANNED] — Close existPart_succ_n1_bypass k>0 (KampBypass.lean) via Rabinovi
  └─ 95 [NOT STARTED] — Verification pass on sorry status for completeness_discrete and b (see above)
  └─ 299 [NOT STARTED] — Refactor DiscreteGameTransfer.lean to eliminate the wrapper patte (see above)
305 [BLOCKED] — Implement Rabinovich's proof of Kamp's theorem (Option A from rep
  └─ 303 [PLANNED] — Close existPart_succ_n1_bypass k>0 (KampBypass.lean) via Rabinovi (see above)
307 [BLOCKED] — Kamp Cor 5.4 depth-k zone converter: resolve the multi-anchor sin
  └─ 305 [BLOCKED] — Implement Rabinovich's proof of Kamp's theorem (Option A from rep (see above)

### Formula Refactor

131 [NOT STARTED] — Restructure Theories/Bimodal/ file hierarchy for clean APIs and d
  └─ 177 [NOT STARTED] — Update all documentation to match final codebase state after refa
  └─ 178 [NOT STARTED] — Expand Examples/ with publication-quality demonstrations of the f
161 [NOT STARTED] — Rename Theories/Bimodal/ to FormalSystem/. Move the entire Theori
175 [RESEARCHED] — Normalize naming conventions to follow Mathlib-style descriptive 
194 [NOT STARTED] — migrate_nonempty_to_derivable

### Frame Extensions

127 [NOT STARTED] — Add time addition operator (+) to the bimodal logic TM. φ + ψ is 
128 [NOT STARTED] — Add topological open set (interior) operator for dense and contin

### Algebraic Representation

125 [NOT STARTED] — Implement a Jonsson-Tarski representation theorem for TM logic: e

### Agent System

162 [NOT STARTED] — Add a .claude/rules/ rule enforcing strict plan compliance for le

### Toolchain

291 [NOT STARTED] — Upgrade Lean toolchain from v4.27 to v4.31 and update Mathlib to 

### Publication Quality

180 [NOT STARTED] — copyright_headers_universe_polymorphism_line_limits
292 [NOT STARTED] — Add Apache 2.0 copyright headers to all source files under Theori
293 [NOT STARTED] — Audit and fix Mathlib linter compliance across all sorry-free mod

### Sorry Elimination

294 [NOT STARTED] — Eliminate all sorry instances in Theorems/ModalS5.lean and Theore

### Automation

179 [RESEARCHED] — research_lean4_tactics_infrastructure
186 [NOT STARTED] — unify_search_systems
187 [NOT STARTED] — backward_chaining_lemma_db
  └─ 192 [NOT STARTED] — master_tactic_dispatch
    └─ 193 [NOT STARTED] — codebase_tactic_refactor
188 [NOT STARTED] — weakening_aware_search
189 [NOT STARTED] — deduction_theorem_tactic
  └─ 193 [NOT STARTED] — codebase_tactic_refactor (see above)
191 [NOT STARTED] — propositional_decision_procedure
  └─ 192 [NOT STARTED] — master_tactic_dispatch (see above)
199 [PARTIAL] — Create a bespoke grid_order_tac tactic (in Theories/Bimodal/Autom
196 [RESEARCHED] — Systematic survey of the entire Theories/Bimodal/ codebase to ide
  └─ 193 [NOT STARTED] — codebase_tactic_refactor (see above)

### Dataset Enhancement

219 [RESEARCHED] — Run bmlogic-bench through multiple LLMs to establish baseline dif
230 [NOT STARTED] — After contamination resolution (task 229), regenerate all benchma
  └─ 231 [NOT STARTED] — Build comprehensive automation so that every dataset regeneration
257 [IMPLEMENTING] — large_data_storage_huggingface
282 [NOT STARTED] — exhaustive_enumeration_by_default
290 [PLANNED] — Improve tableau fuel allocation heuristic for imbalanced branches
296 [NOT STARTED] — Re-add the 6 derived binary temporal operators (release, weak_unt

### Literature

343 [NOT STARTED] — Make the tableau decision procedure abort-aware by threading an I
  └─ 298 [PLANNED] — Fix c7 labeling bug at formula ~13750 that causes unbounded memor

### Reference Book

318 [NOT STARTED] — GATED ON EXTERNAL EVENT: execute only after the Lk paper (anonymo

### Kamp_theorem_formalization

349 [PLANNED] — Build the recursive navigated arity-3 endpoint primitive `endChar
  └─ 350 [RESEARCHED] — Build the aggregate forall-qnf quantEnd/seg construction -- a sin
    └─ 309 [BLOCKED] — Build the off-diagonal two-anchor navigated characteristic (Rabin

### Uncategorized

341 [PLANNED] — Structural refactor of the NfMultiAnchorBridge kvE2_sep carrier l

## Tasks

### 351. Formalize rabinovich lemma 322 2freevariable reduction for normalformnf eval nf
- **Effort**: high
- **Status**: [COMPLETED]
- **Task Type**: lean4
- **Topic**: kamp_theorem_formalization
- **Dependencies**: None
- **Research**: [349_build_recursive_endchar_navigated_arity3_endpoint_primitive/reports/03_spawn-blocker-analysis.md]
- **Plan**: [351_formalize_rabinovich_lemma_322_2freevariable_reduction_for_normalformnf_eval_nf/plans/01_lemma32-2var-reduction-plan.md]

**Description**: Build a reusable, green, sorry-free Lean structural lemma (or minimal cohesive family of lemmas) in a new file Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/Lemma32Reduction.lean that is the Lean analogue of Rabinovich (2014) Lemma 3.2(2) (~/Projects/Literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.md, around md:119): 'Every →∃∀-formula is equivalent to a conjunction of →∃∀-formulas with at most two free variables.' Concretely, over this project's NormalForm/nf_eval_nf types (Theories/Bimodal/Metalogic/WeakCanonical/NormalForm.lean, nf_eval_nf at line 198; AtomKind at line 113) and the ExistsForallNF/TemporalPred types (Theories/Bimodal/Metalogic/WeakCanonical/ExistsForallNF.lean, TemporalPred.eval_at at line 53), the lemma must show that for arbitrary arity n, evaluating nf_eval_nf M k n env qnf against an arbitrary env : Fin n -> M.carrier is equivalent to a finite conjunction of nf_eval_nf-style facts each restricted to at most two free anchor positions (arity <=3 once the existential witness position from nf_eval_nf's own recursive unfolding is included), matching the 'two anchors + one witness' shape the GREEN nf_zone_flatten_navigable/_correct two-anchor lemma already uses (Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/Base.lean:667-697). The reduction must happen BEFORE any navigation step, decomposing the arity-n obligation into arity-<=3 pieces at the NormalForm/nf_eval_nf level, so task 349's recursion can later navigate each piece with Until/Since without ever climbing past arity 3. Motivation to cite verbatim in the module docstring: the two in-tree refutation theorems endCharN0_correct_world_local_obstruction and endCharN0_correct_infeasible (Base.lean) prove the climbing-arity single-world base is impossible, and specs/349_build_recursive_endchar_navigated_arity3_endpoint_primitive/reports/02_rabinovich-faithfulness-audit.md (§Q4 target 4, H3 lemma-mapping table) is the faithfulness ground truth establishing this reduction as the paper's own prescribed alternative. Reusable assets to build on (do not re-derive): nf_endpoint_tl_gen/_correct (Base.lean:1879/1893), atomPartN (Base.lean:1866), seg/seg_holds_coupled (Base.lean:1127/1150), and the green nf_zone_flatten_navigable/_correct full-eval hook shape (Base.lean:667-697) as the structural template. Explicitly forbidden (H4-refuted or plan-forbidden): the single-anchor navBrickForm reshape, the nf_char3_deeper_split arity collapse, and reintroducing a free-standing NavResidual/h_nav predicate-layer residual at inner witnesses. Deliverable/acceptance criterion: a green, sorry-free, 0-new-axiom (beyond [propext, Classical.choice, Quot.sound]) Lean theorem (or minimal family) stating the <=2/<=3 free-variable equivalence for nf_eval_nf, committed under Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/, verified by lake build. Does NOT include re-architecting task 349's recursion itself — that is deferred to /revise 349 (v4) once this lemma lands.

---

### 350. Build aggregate quantendseg construction and discharge armcorrectness hooks at k0 and k1
- **Effort**: high
- **Status**: [RESEARCHED]
- **Task Type**: lean4
- **Topic**: kamp_theorem_formalization
- **Dependencies**: Task 349
- **Research**: [309_offdiag_two_anchor_fi_chain/reports/08_spawn-analysis.md]

**Description**: Build the aggregate forall-qnf quantEnd/seg construction -- a single TemporalPred/BracketFormula 0 encoding the population match `forall qnf : NormalForm sig k 3, ((exists w, nf_eval_nf M k 3 (zoneEnv3 w x t) qnf) <-> sub_nf.2 qnf)` via 5-zone order-pattern routing (the existing `seg endChar qnf` at Base.lean:1127 is per-qnf, not an all-order-patterns aggregate; same house style as the landed zone-triage lemmas, e.g. nf_zone_exists_trichotomy_k1) -- and use it plus the recursive endChar_correct (consumed by name from the prerequisite task) to discharge the three arm-correctness lemma hooks as separate green lemmas at depth k=0 and k=1: h_quant past (nf_char2_past_formula_correct, Base.lean:1230, hook at 1238-1241), h_quant future (nf_char2_future_formula_correct, Base.lean:1430, hook at 1438-1441), and h_past/h_fut/h_diag (A_diag_correct, Base.lean:758, hooks at 765-773). Consume, do NOT rebuild: endChar_correct (from the prerequisite task), seg_holds_coupled (Base.lean:1150), nf_zone_flatten_navigable_correct (NfZoneFlattenNavigable.lean:709). Guards (binding, same set as the prerequisite task): G1-G5; FORBIDDEN nf_char3_deeper_split; do NOT edit the seven frozen provider files (SharedWitness.lean, SubBracket2V.lean, OuterGate.lean, ExteriorBracket.lean, ExteriorZoneTriage.lean, ExteriorNegation.lean, ExteriorNegationPast.lean); do NOT edit KampPrior.lean:352-364 (the :361/:364 sorry region and its transfer note stay task 309's own Phase 19 edit -- this task lands consumable lemmas only, in Base.lean or an additive 309-owned wiring file, never the sorry lines themselves); axioms exactly [propext, Classical.choice, Quot.sound]; sorry-free. Definition of done: lake build GREEN; all new lemmas sorry-free; lean_verify on each named hook-discharge lemma = exactly [propext, Classical.choice, Quot.sound]; no frozen-file edits; no edit inside the KampPrior.lean recursion body; task 309's Phase 18b/19 can cite the k=0/k=1 hook-discharge lemmas by name to instantiate the landed Phase-18a skeleton kampPrior_case1_trichotomy_assemble (KampPrior.lean:1056) and narrow :361. Literature grounding: orchestrator handoff blocker P18b-endChar-recursive-core-unbuilt (crux and resolution fields, second successor); report 02 Section 6 'Phase 9' decomposition (reports/02_endpoint-hook-discharge-research.md:272-279), adapted -- the :361 rewire itself stays task 309's own Phase 19, only the hook discharge is this task's deliverable.

---

### 349. Build recursive endchar navigated arity3 endpoint primitive
- **Effort**: high
- **Status**: [PLANNED]
- **Task Type**: lean4
- **Topic**: kamp_theorem_formalization
- **Dependencies**: Task 351
- **Research**:
  - [309_offdiag_two_anchor_fi_chain/reports/08_spawn-analysis.md]
  - [349_build_recursive_endchar_navigated_arity3_endpoint_primitive/reports/01_endchar-faithful-architecture.md]
  - [349_build_recursive_endchar_navigated_arity3_endpoint_primitive/reports/02_rabinovich-faithfulness-audit.md]
- **Plan**: [349_build_recursive_endchar_navigated_arity3_endpoint_primitive/plans/04_reduction-navigated-endchar.md]

**Description**: Build the recursive navigated arity-3 endpoint primitive `endChar : (k : Nat) -> EndCharCarrier sig k` (EndCharCarrier abbrev at Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/Base.lean:1007) by recursion on k, plus `endChar_correct`. Base case = the already-landed `endChar0`/`endChar0_correct` (Base.lean:995/1056, sorry-free). Step case = navigable-brick flatten of each sub's existential witness composed with the already-landed non-trivial interior segment `seg`/`seg_holds_correct`/`seg_holds_coupled` (Base.lean:1127-1162, sorry-free) for the interior and Phase-6/8-shaped endpoint characteristics for the exteriors, arity capped at 3 (guard G4). This is the report-02-Section-1.4 primitive, explicitly documented as NOT YET BUILT at Base.lean:958-969 (~300-500 lines estimated in-file, brick-witness-collapse / anchor-management core). Consume, do NOT rebuild: endChar0/endChar0_correct, seg/seg_holds_correct/seg_holds_coupled, nf_zone_flatten_navigable(_brick)/_correct (Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/NfZoneFlattenNavigable.lean:689/709). Guards (binding): G1 no arity-1 collapse; G2/G4 anchors strictly {a,b} subset {x,t}, <=2, w never a third free anchor; G3 non-trivial segment only (reuse seg, never TemporalPred.top); G5 no simp/omega/aesop shortcut of a Rabinovich chain step, manual bridges only; FORBIDDEN: nf_char3_deeper_split (refuted route -- grows anchor set to 4, forbidden tower, report 02 Section 4.1); do NOT edit the seven frozen provider files (SharedWitness.lean, SubBracket2V.lean, OuterGate.lean, ExteriorBracket.lean, ExteriorZoneTriage.lean, ExteriorNegation.lean, ExteriorNegationPast.lean); do NOT touch KampPrior.lean or nf_nvar_exist_all_depths's signature -- this task's scope is Base.lean only, additive; axioms exactly [propext, Classical.choice, Quot.sound]; sorry-free -- if a sub-piece cannot close green, mark [BLOCKED] and escalate per the lean4 vacuous-definitions/escalation rule, do not land a vacuous or sorry'd endChar. Definition of done: lake build GREEN (scoped Base module at minimum, full tree recommended); endChar/endChar_correct sorry-free; lean_verify on endChar_correct = exactly [propext, Classical.choice, Quot.sound]; no frozen-file edits; downstream task 309 Phase 18/19 can cite endChar_correct by name. Literature grounding: Rabinovich 2014 Cor 5.4 / report 02 Section 1.4 (the missing navigated-endpoint primitive) and Section 6 'Phase 8' decomposition (reports/02_endpoint-hook-discharge-research.md:266-270); orchestrator handoff blocker P18b-endChar-recursive-core-unbuilt.

---

### 348. Prop43 exterior reflatten
- **Status**: [COMPLETED]
- **Task Type**: lean4
- **Topic**: kamp_theorem_formalization
- **Dependencies**: Task 335, Task 346, Task 347
- **Research**: [348_prop43_exterior_reflatten/reports/01_prop43-exterior-reflatten.md]
- **Plan**: [348_prop43_exterior_reflatten/plans/01_prop43-exterior-reflatten.md]

**Description**: Restore Rabinovich interval-bounding faithfulness for the exterior-marked hexclExt residue isolated by task 346 and narrowed by task 347 R1 (commits d370d438e, 3b8aee3c4 — residue is exterior-marked σ ONLY before this task starts). AUTHORITATIVE SPEC: specs/346_successor_carrier_redefinition/summaries/01_successor-carrier-redefinition-summary.md, section "prop43_exterior_reflatten" (line ~195) — consume it verbatim, do NOT re-derive. METHOD (settled by 347 adjudication, not to be re-opened without a machine counterexample): re-flatten per Rabinovich Prop 4.3 (p.6, Fig.1 p.10) + Lemma 7.6 adjacency (p.13) — exterior arrangements x1<x and x1>t belong to ADJACENT intervals (-inf,x)/(t,inf), each with its own bracket (Def 7.5/Lemma 7.10 shapes), composed with the landed interior (x,t) bracket via the adjacency primitive; seam at anchors x,t. Do NOT prove hexclExt as strictly-exterior completeness on the interior bracket (retired phantom framing, no §5 counterpart; 335 report 07 Refutation 2). Do NOT bound nf_eval_nf's outer existential in place (correct raw FOMLO semantics). ENTRY PROBLEM: Prop43.lean:120-159 uniform-negation connective cases (blocked navigated route — first target; feed the already-proven neg_2var_vec_ea Prop 4.2 closure, EANegationClosure.lean:722). LANDED ASSETS: BracketEndCharCarrierV (NfMultiAnchorBridge.lean:1872), task-326 interior closers, 347 R1 interior-slice discharge lemma (SharedWitness.lean below SW:10210 GATE banner). DEFINITION OF DONE: exterior-marked hexclExt residue discharged by adjacent exterior bracket composed with interior gate; fold + soundness-half theorems called with residue closed (interior + boundary + adjacent-exterior = full completeness); KampPrior.lean:351 strategic sorry retired; axiom-clean {propext, Classical.choice, Quot.sound}, no sorry on live paths. GROUNDING: Rabinovich 2014 §4/§5/§7; 347 report 01 (verdict (b), §7 R2); 330 report 01 (REDESIGN); 335 report 07. Scope: distinct major effort (missing re-flatten infrastructure, a genuine mathematical gap — not wiring).

---

### 347. Rabinovich bracket faithfulness review
- **Status**: [COMPLETED]
- **Task Type**: lean4
- **Dependencies**: Task 346

**Description**: Faithfulness review + revision of the task-346 gate against Rabinovich 2014 §5 (full text at ~/Projects/Literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.md). CORE QUESTION: Rabinovich's brackets (Lemma 5.3/Cor 5.4/Lemma 5.1, Notation 5.2) bound witnesses INSIDE (z0,z1) by ordering conjuncts — the paper has NO exterior-completeness direction; yet the Lean encoding's nf_eval_nf (NormalForm.lean:206) quantifies the fresh variable over ALL of M.carrier, which is what forced 346's hexclExt residue and the conditional interior+boundary gate. Adjudicate: (a) BENIGN — the qnf/zone encoding carries ordering content from which strictly-exterior non-realization is derivable, so hexclExt is encoding-level debt (possibly cheap to discharge, superseding the heavy prop43_exterior_completeness successor spec in 346 summary); or (b) SUBSTANTIVE — the encoding dropped Rabinovich's interval-bounding (cf. 335 report 07 Refutation 2 'category mismatch at inner-bits layer'), in which case propose and land the smallest revision restoring bracket-semantics faithfulness rather than proving exterior completeness from an unfaithful encoding. MUST ALSO CHECK: (1) strictness — Rabinovich strict interior z0<x<z1 + K+/K- endpoint operators vs 346's boundary-inclusive cone x<=x1<=t with realized boundary positives (Phase 4 endpoint/witness literals) — verify the trichotomy maps to interior-brackets+K± without double-counting endpoints; (2) hreal hypothesis shape vs what Rabinovich §5 induction actually proves (task-335 provider obligation match); (3) interior-singleton kvE2_sepPosI fragment vs Lemma 5.3 induction single-P1 case structure. GROUNDING: Rabinovich full text (cite by page); specs/346_*/summaries/01 + progress records; specs/archive/330_*/reports/01 (faithfulness audit); specs/335_*/reports/07. OUTPUT: verdict (a)/(b) with paper-cited justification; if (b), revision plan + implementation; update or retire the prop43_exterior_completeness successor spec accordingly. CONSUMERS: prop43 successor decision, task 309 Phases 13.4/14, task 335 Phase D.

---

### 346. Successor carrier redefinition
- **Status**: [COMPLETED]
- **Task Type**: lean4
- **Dependencies**: Task 345
- **Research**: [346_successor_carrier_redefinition/reports/01_hexcl-refutation-and-vacuity.md]

**Description**: THE 321-N2 NAMED SUCCESSOR (user-deferred; NOT auto-dispatched — major scope decision). Certified by task 335 report 07 (2026-07-11) as the ONLY remaining route to the k=2 gate: bit-compatibility filtering carrier redefinition (O4 SW:6763-6770) / 330-audit Prop 4.3 navigated exterior completeness. MUST ALSO: (1) redefine the fragment predicate — the landed kvE2_sepFragment (OuterGate.lean:191, global singleton) is flagged UNREALIZABLE (any realized qnf has >=3 positive bits; report 07 Refutation 1); intended fragment is plausibly interior-singleton via kvE2_sepPosI (SW:211); (2) re-state bracketEndChar_kvE2_sound_two_prior_frag non-vacuously (its derivation survives, its premise set does not — VACUITY NOTEs stamped on both decls in OuterGate.lean); (3) resolve hexcl properly — machine-confirmed NOT dischargeable under ANY fold-interface enrichment (report 07 Refutation 2: category mismatch at inner-bits layer + bracketEndChar_kv_factors arity-1 inseparability of sibling/exterior types). ASSETS THAT SURVIVE: tasks 344/345 pin-anchored symmetric-gate machinery (fragL/fragR/kit/fold — hypothesis-carrying, proofs genuine; predicate swap expected to preserve them, verify), 335 Phase 2 completeness half (unconditional), 335 Phase B derivation modulo the predicate repair, symmetric gate clause (v) (literature-faithful, Rabinovich Cor 5.4 p.9). GROUNDING: specs/335_outer_gate_assembly_engine_kvE2_body/reports/04-07 + specs/330_.../reports/01 (faithfulness audit) + Rabinovich PDF (cite by page only). CONSUMERS: task 309 Phases 13.4/14 + KampPrior.lean:351 strategic sorry; task 335 Phase D. Recommend /research 346 --lit --hard before any planning.

---

### 345. Symmetric gate clause v
- **Status**: [COMPLETED]
- **Task Type**: lean4
- **Dependencies**: Task 344
- **Research**: [345_symmetric_gate_clause_v/reports/01_literature-fidelity-gate-design.md]
- **Plan**: [345_symmetric_gate_clause_v/plans/01_symmetric-gate-plan.md]
- **Summary**: [345_symmetric_gate_clause_v/summaries/01_symmetric-gate-summary.md]

**Description**: SPAWNED from task 335 R1 decision, literature-fidelity-verified (session sess_1783723095_edd5a7; USER directive: most mathematically correct and faithful approach; verdict R1-faithful, reports/01). Make kvE2_sepGate symmetric per Rabinovich Cor 5.4(1)/(2) mirror pair (p.9): (1) ADD clause (v) to the LANDED kvE2_sepGate def (SharedWitness.lean ~1244-1246) = the zWT3 mirror of clause (iv), forcing bits false on non-kvE2_sepInnerConsistentR zone specs for RIGHT owners. (2) Discharge the ONE gate constructor gaining an obligation: kvE2_sepGate_holds_of_honest (SW:2666), by byte-mirroring the clause-(iv) discharge (SW:2706-2726) via the landed kvE2_sep_zone4_consistentR (SW:11309). (3) REMOVE (not guard) the now-derivable hInnerR hypothesis from kvE2_sepGateAtPin_fragR, kvE2_sepBody_kit_sound_frag, kvE2_outer_fold_frag — recovering RIGHT inner-consistency from hg clause (v) exactly as fragL uses clause (iv); this REPAIRS the confirmed LEFT-unsatisfiability of hInnerR (344 fold currently uninvokable). (4) Verify all other kvE2_sepGate consumers inert (literature report says so — re-verify at build level). CONSTRAINTS: this is the SANCTIONED exception to the SharedWitness freeze — touch ONLY the gate def, holds_of_honest, and the three 344 _frag lemma signatures/bodies; everything else byte-identical; full lake build green; axiom-clean {propext, Classical.choice, Quot.sound}; zero sorries on live paths; incremental green commits; cite Rabinovich by PDF page only. CONSUMER: 335 Phases B-D resume with discharge obligations reduced to {hcorrK, hexcl}. Task 341 GATE-phase re-diff absorbs the delta.

---

### 344. Pin anchored fragment fold
- **Status**: [COMPLETED]
- **Task Type**: lean4
- **Dependencies**: None
- **Research**: [344_pin_anchored_fragment_fold/reports/01_fragment-extractor-derivability.md]
- **Plan**: [344_pin_anchored_fragment_fold/plans/01_pin-anchored-fold-plan.md]
- **Summary**: [344_pin_anchored_fragment_fold/summaries/01_pin-anchored-fold-summary.md]

**Description**: SPAWNED from task 335 blocker escalation 2 (session sess_1783723095_edd5a7). Land the pin-anchored fragment fold in SharedWitness.lean, ADDITIVE-ONLY (zero existing decls modified — task 341 GATE re-diff absorbs it): kvE2_sepGateAtPin_fragL/R (six gate conjuncts derived at the extracted pin witness q with x < q < w via kvE_sub2V_bounded_anchor_of_outer), kvE2_sepBody_kit_sound_frag, and kvE2_outer_fold_frag (pin-anchored variant of kvE2_outer_fold). Grounding: machine-verified derivability report (reports/01_fragment-extractor-derivability.md; original at specs/335_outer_gate_assembly_engine_kvE2_body/reports/05_fragment-extractor-derivability.md). REFUTED shapes to avoid: the ∀-anchor hgateL of the landed fold is FALSE in gate-legal hfrag-legal configurations (SW:9911-9928, SW:6772-6778 binder-level obstruction survives the fragment) — do NOT attempt a segment-coverage extractor for it; a NEW FILE will not work (segment/pin internals are file-private). One extra dischargeable input allowed: provider correctness at the pin (hcorrK = ExistProviders.correct step already assigned to 335). Consumer: task 335 Phases B-D (bracketEndChar_kvE2_correct_two_prior_frag). Invariants: lake build green, axiom-clean {propext, Classical.choice, Quot.sound}, no sorries on live paths, incremental green commits. Residual risks to probe early: hexcl threading, arrangement-shape reduction under hfrag, pin-extraction output shape. Sizing: 2-3 dispatches.

---

### 343. Abort aware tableau cancellation
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: literature
- **Dependencies**: None

**Description**: Make the tableau decision procedure abort-aware by threading an IO.Ref Bool abort signal through expandBranchWithFuel and related functions. Currently, IO.cancel in labelFormulaImpl is cooperative but the pure tableau computation never calls IO.checkCanceled, so cancelled tasks continue as zombie threads accumulating memory. The fix: (1) Add an IO.Ref Bool parameter to expandBranchWithFuel that is checked at each recursive step. (2) Wire the abort ref from the IO.cancel handler in labelFormulaImpl. (3) Ensure extractCountermodelData in mkInvalidLabel also respects the abort signal. This eliminates the root cause of the c7 OOM — zombie tableau computations that survive cancellation.

---

### 341. Structural refactor sharedwitness carrier layer
- **Status**: [PLANNED]
- **Task Type**: lean4
- **Dependencies**: Task 335, Task 337, Task 340, Task 346
- **Research**: [341_structural_refactor_sharedwitness_carrier_layer/reports/01_sharedwitness-declaration-survey.md]
- **Plan**: [341_structural_refactor_sharedwitness_carrier_layer/plans/01_module-split-design.md]

**Description**: Structural refactor of the NfMultiAnchorBridge kvE2_sep carrier layer, now that it has grown to a large, intricate state. MEASURED CURRENT SIZE (2026-07-09, wc -l): SharedWitness.lean is ~9248 lines (NOT ~3540 as previously stated — 2.6x larger); SubBracket2V.lean ~2160; CarrierK1V.lean ~2097; the enclosing directory Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ totals ~18,100 lines across 11 files (Base 1478, CarrierK1V 2097, CarrierKv 482, NavigatedSpine 451, OuterGate 203, PriorInterface 105, RefutationF2 963, SharedWitness 9248, SubBracket 266, SubBracket2 647, SubBracket2V 2160). Any module-split proposal MUST be sized against the true ~9248-line SharedWitness, not the stale 3540 figure. CURRENT CARRIER STRUCTURE (post-task-334, post-task-342 — describe the split against THIS, not the old text): task 334 [COMPLETED] switched the carrier to kvE2_sepArr' (41 occ; decls kvE2_sepArr'_mem_modelOrder at 1888, kvE2_sepArr'_sound at 6918) plus kvE2_sepDisjValidOwner (def at 1733, 12 occ), DELETING kvE2_sepArrL / kvE2_sepArrR / kvE2_sepValid and the entire kvE2_sepSingleton block — all four now have 0 declarations; their surviving mentions are prose/comment only (kvE2_sepArrL 9, kvE2_sepArrR 2, kvE2_sepValid 17, kvE2_sepSingleton 0). Task 342 [COMPLETED] added the interior-restricted owner index kvE2_sepPosI (noncomputable def at line 211; now ~229 occurrences) plus tie-admitting weak orders, and deleted the global hLR hypothesis-carrying construction: hLR now survives ONLY as a local binder inside the certificate theorem kvE2_sepHonest_hLR_absurd (SharedWitness:5710), which proves the former hLR was inconsistent with every honest evaluation — there is no global hLR declaration. Name the split against the REAL current symbols — kvE2_sepArr', kvE2_sepDisjValidOwner, kvE2_sepPosI, kvE2_sepBody (def at 2328, 52 occ), kvE2_sepBody_extract (thm at 6328), kvE2_sepHonest_hLR_absurd — and NEVER against the deleted kvE2_sepArrL/R/Valid/Singleton/hLR. LITERATURE-CITATION HAZARD (record explicitly and respect): SharedWitness.lean carries 89 dangling md:NN citations in comments (md:77 x27, md:168 x24, md:154 x9, md:72 x8, md:61 x6, md:91 x3, md:218 x3, md:170 x3, and singletons md:78/74/66/207/137/100). These point into a Rabinovich markdown that was a hand-written paraphrase, replaced 2026-07-09 by a PDF text-extract that drops every displayed equation and inverts k!=m into k=m; the md:NN line references are therefore meaningless. By a deliberate user decision these are left UNFIXED for now — but this refactor, which will move those comments between modules, MUST NOT silently propagate them as if valid. This is a natural opportunity to re-cite to Rabinovich PDF page numbers if the refactor touches those comments (the codebase already uses this style, e.g. 'Rabinovich §5, p.7' at SharedWitness:6132). RULE: cite Rabinovich by PDF page only, never md:NN. GOALS (original intent preserved): (1) SPLIT the oversized SharedWitness.lean into cohesive modules along natural seams (e.g. slot/carrier types & enumeration; per-slot global-index + kvE2_ordRank kernel and the interior owner index kvE2_sepPosI; honest-order + membership/monotonicity; coincidence-fold/discharge; body/holds_iff/extract assembly via kvE2_sepBody / kvE2_sepBody_extract), preserving the public API and all import sites. (2) IMPROVE the API: consistent naming, clearer signatures, section structure, and comprehensive docstrings/comments explaining the value-faithful per-individual-slot design and its Rabinovich Def 3.1 grounding (cite PDF pages, and reports 05-09), correcting or dropping dangling md:NN comments wherever they are encountered. (3) ARCHIVE genuinely dead/superseded code to Theories/Bimodal/Boneyard/ (residual 339 region-primary machinery; obsolete owner-block tuple remnants after the task-340 v3 per-slot refinement; comment blocks referencing the deleted kvE2_sepArrL/R/Valid/Singleton/hLR constructions), WHILE preserving anything still uncertain or potentially load-bearing in place with clear NOTE:/QUESTION: comments rather than deleting it. (4) Keep the full lake build green and axiom-clean {propext, Classical.choice, Quot.sound} throughout; no sorries introduced; preserve F1-F7 faithfulness invariants and the LITMUS (NavigatedSpine:437, UNVERIFIED exact line). This is a code-health/maintainability pass, NOT a semantic change — behavior and proved theorems must be preserved exactly. SEQUENCING (hard constraint): MUST run AFTER the active carrier chain completes — dependencies 340 (per-slot refinement), 337 (holds builder), 335 (outer gate) — AND must NOT run concurrently with the H7 territory contract that currently assigns SharedWitness.lean to task 333 and OuterGate.lean to task 335; both 333 and 335 must land before this structural refactor is safe, to avoid churning files under active edit. Strongly recommend a survey/plan phase that maps the current declaration graph against the true ~9248-line structure and proposes the module split before moving any code. This is a description correction, not a re-scoping: overall scope and goals are unchanged. SEQUENCING ADDENDUM (2026-07-11, session sess_1783723095_edd5a7): task 346 (successor carrier redefinition, spawned from 335) added as an explicit dependency — it reworks NfMultiAnchorBridge carrier internals, so the code-move GATE must verify BOTH 335 COMPLETED AND 346 COMPLETED (or 346 abandoned by user decision) before moving code. Note for the GATE re-diff: tasks 344/345 grew SharedWitness.lean from 10,037 to ~12,600 lines (TASK 344/345 banner sections — pin-anchored fragment fold + symmetric gate); the five-seam cut lines and the md:NN inventory in plan 01 are stale and must be refreshed at the GATE as the plan already provides.

---

### 335. Outer gate assembly engine kvE2 body
- **Status**: [COMPLETED]
- **Task Type**: lean4
- **Topic**: kamp_theorem_formalization
- **Dependencies**: Task 334, Task 337, Task 344, Task 345, Task 346
- **Summary**:
  - [335_outer_gate_assembly_engine_kvE2_body/summaries/01_outer-gate-assembly-summary.md]
  - [335_outer_gate_assembly_engine_kvE2_body/summaries/01_outer-gate-assembly-summary.md]
- **Plan**:
  - [335_outer_gate_assembly_engine_kvE2_body/plans/05_fragment-gate-v5.md]
  - [335_outer_gate_assembly_engine_kvE2_body/plans/06_fragment-gate-v6.md]
- **Research**: [335_outer_gate_assembly_engine_kvE2_body/reports/07_hexcl-enrichment-derivability.md]

**Description**: Follow-up to task 334 (faithful carrier re-grounding, COMPLETED): build the outer-gate assembly engine kvE2_body / bracketEndChar_kvE2 (task 321 v4 / NavigatedSpine Phase-7 two-level quant-layer connector), which currently has no live def. Task 334 proved the faithful carrier's nonvacuity (kvE2_sepBody_nonvacuous, ⇒) and completeness (kvE2_sepBody_complete, ⇐) as self-contained axiom-clean theorems in NfMultiAnchorBridge/SharedWitness.lean; this task assembles them into the outer gate that KampPrior.lean:351 (depth-k≥2 Cor 5.4 converter) consumes. The carrier is a verified INPUT — do not re-prove it. See task 334 plan 03 Risk R3/R4 and Scope note (lines 417-419), and the captured failed-closer history at NavigatedSpine:423-435. Preserve all 7 faithfulness invariants (F1-F7) from task 334. UPDATE (task-347 adjudication, session sess_1783792054_45a555): the Phase-D provider obligation is re-shaped to Rabinovich Cor 5.4 ⇐ form — realize BOUNDED, jointly-ordered interior witnesses over the interior index kvE2_sepPosI (SharedWitness.lean:211-214), NOT the global kvE2_sepPos (which over-asks: unbounded, decoupled — 347 report 01 MUST-CHECK 2). The hard hexcl blocker is DISSOLVED, not discharged in-335: task-347 R1 (commits d370d438e/3b8aee3c4) discharged the interior exclusion slice in-line and narrowed the residue to exterior-marked σ only; that exterior-arrangement residue is the province of successor task 348 (prop43_exterior_reflatten — Prop 4.3 re-flatten / Lemma 7.6 adjacency), for which 335 is the PROVIDER. Phase D therefore assembles the interior+boundary-scoped gate and threads the exterior-marked hexclExt outward to 348; it does NOT attempt exterior completeness on the interior (x,t) bracket (retired phantom framing, no §5 counterpart). Plan: v6 (06_fragment-gate-v6.md); Phase D actionable, v5 blocker dissolved.

---

### 333. Carrier redefinition kve2 separr bit compatibility correctness pair
- **Status**: [COMPLETED]
- **Task Type**: lean4
- **Dependencies**: Task 321, Task 332
- **Summary**: [333_carrier_redefinition_kve2_separr_bit_compatibility_correctness_pair/summaries/01_bit-compat-carrier-redefinition-summary.md]
- **Research**:
  - [333_carrier_redefinition_kve2_separr_bit_compatibility_correctness_pair/reports/02_post334-soundness-extraction-frontier.md]
  - [333_carrier_redefinition_kve2_separr_bit_compatibility_correctness_pair/reports/03_pdf-fidelity-r3-dissolved-regrounding.md]
  - [333_carrier_redefinition_kve2_separr_bit_compatibility_correctness_pair/reports/04_r2-blocker-repair-route.md]
- **Plan**:
  - [333_carrier_redefinition_kve2_separr_bit_compatibility_correctness_pair/plans/05_kit-application-and-outer-fold.md]
  - [333_carrier_redefinition_kve2_separr_bit_compatibility_correctness_pair/plans/06_route-a-grouped-extraction.md]

**Description**: Successor to task 321 (F4 correctness gate): the bit-compatibility carrier redefinition that closes what task 321's additive-only v7 plan structurally could not. Task 321 reached a scoped PARTIAL: the O4 hgate forward-zone coverage residue does not close additively at singleton size (needs six interlocking LITMUS/no-nesting-constrained lemmas), and the multi-positive-sub fragment was deferred at the Phase 10 gate. Both route to the SAME fix identified by the crux analysis: redefine kvE2_sepArrL / kvE2_sepArrR (currently arrangement-blind) with bit-compatibility FILTERING so the interleaving enumeration only admits realizations whose zone bits are compatible with each sigma's fold content. This is a Phase-7 carrier RE-DEFINITION (out of task 321's additive scope; it kills the current canonical-list non-vacuity proof, which must be re-established). Deliverables: (1) redefined kvE2_sepArrL/R + restored non-vacuity; (2) discharge task 321's two remaining strategic sorries in SharedWitness.lean (kvE2_sepSingleton_coverage_left:1796, kvE2_sepBody_singleton_complete_left:1952) for the single-positive fragment; (3) lift to the full multi-positive-sub correctness pair; (4) run Phase 12 (N2-C gate wrapper) and Phase 13 (F4 Z adversarial LHS-FALSE + GO verdict record) from task 321's v7 plan; (5) full lake build green + axiom-clean surviving public API. Faithfulness constraints from 321 remain binding: Rabinovich 2014 Lemma 5.1 quantifier-free point types, no-nesting audit, LITMUS (no x1<e_i), F4 adversarial test must discriminate. Do not run concurrently with 321/332 (file_scope overlap on SharedWitness / NfMultiAnchorBridge).

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
- **Plan**:
  - [321_implement_corrected_k2_carrier_and_close_the_correctness_gate_f4_resolution/plans/02_corrected-k2-carrier-fi-chain-v2.md]
  - [321_implement_corrected_k2_carrier_and_close_the_correctness_gate_f4_resolution/plans/03_corrected-k2-carrier-gate-v3.md]
  - [321_implement_corrected_k2_carrier_and_close_the_correctness_gate_f4_resolution/plans/04_corrected-k2-carrier-gate-v4.md]
  - [321_implement_corrected_k2_carrier_and_close_the_correctness_gate_f4_resolution/plans/05_corrected-k2-carrier-gate-v5.md]
  - [321_implement_corrected_k2_carrier_and_close_the_correctness_gate_f4_resolution/plans/06_corrected-k2-carrier-gate-v6-redesign.md]
  - [321_implement_corrected_k2_carrier_and_close_the_correctness_gate_f4_resolution/plans/07_v7-faithful-separate-bracket.md]

**Description**: REDESIGN (v6, plan 06). Task 330's PDF-verified faithfulness audit (specs/330_.../reports/01_faithfulness-audit-fold-representation.md — the PRIMARY BASIS) determined the entire v1-v5 route rested on a MIS-CITATION: the "constant-arity E[Sigma]-fold (Def 4.1)" does not exist in Rabinovich 2014. Def 4.1 (p.5) is the E[Sigma] ALPHABET EXPANSION (TL-formulas-as-atoms), NOT a fold. The real fold is Prop 3.5 / Cor 5.4: NAVIGATED (nested Until/Since) over FLAT exists-forall blocks with QUANTIFIER-FREE point types (Lemma 5.1, p.7); higher FO depth is discharged by STRUCTURAL INDUCTION (Prop 4.3, p.6), never by nesting a depth-k characteristic. The static arity-1 E-atom (EAtomDom = ZoneSpec n x NormalForm sig k 1, NfEFold:69) is a CATEGORY ERROR at k>=1 — the recurring wall (G6 :1609-1641, F4 :5689-5765, k=2 NO-GO 327 :8760-8825) is ONE obstruction: an arity-1 monadic channel cannot carry an inner witness's joint coupling to multiple anchors (goal needs ZoneSpec 4, channel supplies ZoneSpec 1).\n\nv6 DROPS every phase depending on the refuted infrastructure (nfk_assemble/nfk_dropFresh/nfk_zoneSpec, nf_eval_nf1_cons_factor, efold_of_nfk, the constant-arity fold engine nf_quant_layer_fold_k2_gate). It CONSUMES the landed assets the audit identified: BracketCarrierCorrectV (NfMultiAnchorBridge:1881, the witness-growing carrier), neg_2var_vec_ea (EANegationClosure:722, the LANDED Prop 4.2 negation closure — the hardest piece), and the task-326 interior closers (kvE_subBracket2V_sound_of_outer/_complete). It ADDS the missing ingredient: the Prop 4.3 re-flatten structural-induction wiring. It FOLDS IN the redefined scope of the now-ABANDONED prerequisite tasks (NOT re-spawned): former 328 -> the navigated witness-growing fold (Prop 4.3 re-flatten induction over flat exists-forall blocks); former 329 -> the per-arrangement VVecEA2 non-interior dischargers (soundness + completeness) for the 5 non-interior zones (zPastX/zAtX/zAtW/zAtT/zFutT). v5 Phase 15 (F4 Z adversarial gate + verdict record) is preserved as the downstream consumer (now Phase 8).\n\nBINDING INVARIANT (the ONE thing v6 changes after 5 non-converging versions): reconstruction is NAVIGATED / witness-growing, NEVER a static arity-1 characteristic — inter-anchor coupling rides the EVALUATION POINT / structural position of nested Until/Since (Prop 3.5 / Cor 5.4). LITMUS: no x1 < e_i relative-position literal on any live path. CONSTRAINTS (preserved from v5): purely additive; DO-NOT-EDIT (byte-identical) task-325/326 landed lemmas, kvE2_body/bracketEndChar_kvE2 splice, kvE_subChain2V, BracketCarrierCorrectVPrior, EANegation, F1-F4 records; no provider-side pinning (Amendment F3); anchor cap 2; G5 citations at every chain step; axiom-clean [propext, Classical.choice, Quot.sound]; no sorry on any live path. RE-SCOPE fallback (audit-sanctioned) only if the navigated fold + induction wiring exceeds budget: narrow to the interior + boundary fragment via task 326 + epL/epR/ptW, deferring exterior-navigated completeness. GOAL STATE: v6 GO gate unblocks task 309 Phase 13.4 (general-k one-step correctness) + Phase 14 (hook rewire discharging KampPrior.lean:351's strategic sorry). LITERATURE GROUNDING: /home/benjamin/Projects/Literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.md (Def 3.1/4.1, Prop 3.5, Prop 4.2, Prop 4.3, Lemma 5.1, Lemma 5.3, Cor 5.4). SCOPE AMENDMENT (2026-07-07, plan v7 Phase 10 decision gate): O4 (carrier-side per-sigma hgate derivation) FAILED its one dedicated dispatch — forward-zone conjunct underdetermined at cross-sigma slot points (inert O4 CRUX RECORD, SharedWitness.lean). Verdict N2: task re-scoped to the single-positive-sub fragment (Appendix N2 promoted into Phases 11-12). The GO/NO-GO deliverable for task 309 Phase 13.4 + KampPrior.lean:351 is now fragment-scoped; the multi-positive case (bit-compatibility filtering of kvE2_sepArrL/R, a carrier re-definition) is deferred to a successor task.

---

### 318. Slot lk results into bimodalreference decidability
- **Effort**: 3-4 hours
- **Status**: [NOT STARTED]
- **Task Type**: typst
- **Topic**: reference-book
- **Dependencies**: Task 313, Task 319

**Description**: GATED ON EXTERNAL EVENT: execute only after the Lk paper (anonymous TACAS 2027 double-blind submission at ~/Philosophy/Papers/PossibleWorlds/Lk/) is accepted and the embargo (user decision 2 on task 313) lifts. Insert the Lk-specific content into chapters/p3-decidability-frontier.typ at the prepared // SLOT-IN: anchors, without renumbering chapters or sections: the BL-star ladder table (Lk 07-related-work.tex 32-104, tab:bl-star-ladder), the complexity map (L1 = PTL x S5 EXPSPACE-complete; L_k undecidable for k >= 2; alternation-freedom does not restore decidability, Theorem F-B; forall-AF-L_k PSPACE-complete flagship, Theorem F-A), and the hardware case study (constant-time as forall-forall, reset convergence, SVA/Logos-Hardware bridge, Lk 06-case-study.tex). Add the Lk bibliography entry with its final published citation. State openly, in plain prose, which results are established in print and which are new; note that none are Lean-formalized (Lk 08-conclusion.tex names Lean 4 formalization as future work). Include the honest trace-vs-task-semantics bridging caveats (Lk is discrete/future-only trace sets; TM is group-time/two-sided task frames). Sources: teammate A rows 15-18.

---

### 309. Offdiag two anchor fi chain
- **Effort**: high
- **Status**: [BLOCKED]
- **Task Type**: lean4
- **Topic**: kamp_theorem_formalization
- **Dependencies**: Task 310, Task 311, Task 320, Task 333, Task 335, Task 346, Task 348, Task 349, Task 350
- **Plan**:
  - [309_offdiag_two_anchor_fi_chain/plans/05_offdiag-fi-chain-plan.md]
  - [309_offdiag_two_anchor_fi_chain/plans/08_offdiag-fi-chain-v8.md]
  - [309_offdiag_two_anchor_fi_chain/plans/09_offdiag-fi-chain-v9.md]
  - [309_offdiag_two_anchor_fi_chain/plans/09_offdiag-fi-chain-v9.md]
- **Research**: [309_offdiag_two_anchor_fi_chain/reports/07_unblock-assessment-post-333.md]

**Description**: Build the off-diagonal two-anchor navigated characteristic (Rabinovich Cor 5.4 non-trivial-segment F_i chain) for the KampPrior.lean:350 past/future arms (prerequisite spawned from task 307 Phase 7 blocker audit, reports/03_endpoint-hook-blocker-audit.md).

Off the live import path, sorry-free, axioms exactly [propext, Classical.choice, Quot.sound]. Deliverables (see task 307 report 03 SS4): (1) segment-carrying A_past/A_future + _correct in Kamp/NfZoneFlattenNavigable.lean (drop the forced `trivial top`; via bracketBuildLeft/Right_correct directly, ~80-120 lines); (2) nf_char2_past_formula / nf_char2_future_formula : NormalForm sig (k+1) 2 -> Formula with `temporal_truth M atomMap t (nf_char2_past_formula ... sub_nf) <-> exists x, x < t AND nf_eval_nf M (k+1) 2 (Fin.cons x (fun _=>t)) sub_nf` (future dual with t < x) — the F_i chain: outer NON-trivial-segment bracket from t to x, endpoint at x = the arity-2 characteristic of sub_nf at [x,t], quant layer (per qnf : NormalForm sig k 3) flattened via nf_zone_flatten_navigable_brick, residual arity-3 zones discharged by the depth-k IH (exist_tl_fn_k / nf_nvar_exist_all_depths); ~300-500 lines, recursion on k — the load-bearing new object; (3) rewire KampPrior.lean:350 to A := nf_char2_past_formula ... OR A_diag ... OR nf_char2_future_formula ..., proven via nf_zone_exists_trichotomy_k1 disjunction-elim + the three _correct lemmas, replacing the :350 sorry (live-path sorries 2 -> 1, :353 remains downstream per task 305 scope).

CONSUME, DO NOT REBUILD (all sorry-free): all of task 308 (NfMultiAnchorBridge: nf_char2_formula deliverable 1, nf_zone_flatten_navigable(_brick) deliverable 2, nf_char2_zone_split5, nf_char2_atom_part(_correct), nf_quant_clause_tl); A_diag/_correct + the trichotomy nf_zone_exists_trichotomy_k1 (task 307 Phases 2-3); depth-0 bases diagDup/diagDup_eval_zero/renameNF_eval_diag0; bracketBuildLeft/Right(_correct) (Kamp/VecEATranslation.lean); the navigated pillars as the diagonal-only degenerate case. The import-cycle relocation is ALREADY LANDED (commit 69998c02d) — NfMultiAnchorBridge no longer imports KampPrior.

FORBIDDEN ROUTES (obstruction guards G1-G5, task 307 report 03 SS4): G1 no arity-1 collapse of the off-diagonal (refuted, report 02 SS1; NfDepth0Generalized:1691-1719). G2 no projection-based VecEA2 / third-free-anchor tower (refuted, specs/305 report 40; R2). G3 no trivial-top segment on the off-diagonal arms (report 03 SS1.2/SS2.3: a closed pastEnd under a trivial segment is unsatisfiable; the (x,t) coupling MUST ride the non-trivial Rabinovich beta_i segment). G4 w stays a bracket witness (env arity never grows past {w,x,t}=3 -> {x,t}=2; anchor set {x,t}; Rabinovich <=2 cap). G5 follow Cor 5.4 F_i chains step-by-step (F_n := alpha_n, F_{i-1} := alpha_{i-1} AND (beta_i Until F_i)); no simp/omega/aesop shortcut of a chain step (literature-fidelity policy).

LITERATURE GROUNDING: ~/Projects/Literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.md Section 5 (Lemma 5.1 md:134-152, Corollary 5.4 md:154-157).

GOAL STATE: lake build GREEN (full), top-level axioms unchanged (propext/Classical.choice/Quot.sound, 0 domain axioms), live-path sorries reduced 2 -> 1 (KampPrior.lean:350 closed, :353 remains), task 307 unblocked to finish Phase 7 wiring verification + Phase 8 wrap-up. Estimated ~400-700 lines total; run --hard --lit. v8 re-point (task-347 adjudication, verdict (b)): the KampPrior.lean:351 discharge consumes an interior+boundary gate PLUS a separate adjacent-exterior bracket with the interior/exterior seam at the anchors x,t (Rabinovich Prop 4.3 + Lemma 7.6 re-flatten) — NOT a single all-arrangement (x,t) gate (that target was an outer-existential globalization artifact with no §5 counterpart; F3/F4 refuted it). The adjacent-exterior bracket and the final KampPrior.lean:351 close are the task-348 prop43_exterior_reflatten deliverable; task 309 depends on 348. Phases 13.4/14 are GATED on task 348's definition-of-done (exterior-marked hexclExt residue discharged by the adjacent-exterior bracket; KampPrior.lean:351 strategic sorry retired). Plan: v8 (08_offdiag-fi-chain-v8.md).

v9 realignment (2026-07-11, providers landed): tasks 335 and 348 COMPLETE — the k=2 interior+boundary fragment gate (bracketEndChar_kvE2_correct_two_prior_frag, OuterGate.lean:359, commit 147af2fbe) and the enriched composed gate bracketEndChar_kvE2Ext_correct_two_prior_frag (ExteriorBracket.lean, hexclExt discharged INTERNALLY) are landed, axiom-clean. Per task 348's R1 scope decision the KampPrior.lean:351 strategic-sorry retirement (now at :361, the | 1 => arm of nf_nvar_exist_all_depths) transferred BACK to task 309 — retirement = consume 348's discharge theorem + discharge the 309-owned provider inventory (hfrag/hrealI/hrealB/hexcl + six order bits). The ∀k-lift composition flag (335 handoff §5) is RESOLVED: option (a) — fragment-scoped k=2 induction step, nf_nvar_exist_all_depths interface unchanged, non-fragment residue routed to the 321-N2 successor. v8 Phases 13.4/14 are RETIRED (superseded by the landed provider chain); open work is Phases 15-19 (site/coverage probe → provider shim → hrealI/hrealB/hexcl discharge → kvE2Ext gate consumption + hooks + depth-2 assembly → ∀k lift + :361 retirement). Plan: v9 (09_offdiag-fi-chain-v9.md).

---

### 307. Kamp cor54 bound anchor zone converter
- **Effort**: 6-10 hours
- **Status**: [BLOCKED]
- **Task Type**: lean4
- **Topic**: completeness
- **Dependencies**: Task 308, Task 309
- **Handoff**: [305_rabinovich_ea_formula_implementation/.orchestrator-handoff.json]
- **Summary**: [305_rabinovich_ea_formula_implementation/summaries/40_phase16-gate-no-go-summary.md]
- **Plan**:
  - [305_rabinovich_ea_formula_implementation/plans/40_prop43-negation-closure-route.md]
  - [307_kamp_cor54_bound_anchor_zone_converter/plans/01_bound-anchor-converter.md]
- **Research**:
  - [305_rabinovich_ea_formula_implementation/reports/40_phase11b-divergence-audit.md]
  - [307_kamp_cor54_bound_anchor_zone_converter/reports/01_bound-anchor-verdict.md]

**Description**: Kamp Cor 5.4 depth-k zone converter: resolve the multi-anchor single-point coupling when the second anchor is EXISTENTIALLY BOUND (residual spawned from task 305's Phase 16 GO/NO-GO gate, plan v40).

PRECISE MATHEMATICAL QUESTION: The live-path obligation KampPrior.lean:391 has the shape `temporal_truth M atomMap t A <-> exists x, nf_eval_nf M (k+1) 2 (Fin.cons x (fun _=>t)) sub_nf` — the second anchor x is EXISTENTIALLY BOUND and navigated-to (not free). Determine whether there EXISTS a model-independent (uniform) Formula A, built from bracketBuildLeft/bracketBuildRight navigation (Until/Since chains) over the depth-k IH formula as the navigable endpoint TemporalPred type, such that the iff holds for every Prior model M satisfying h_UZ/h_SZ — i.e. CONSTRUCT the depth-k zone converter for the bound-anchor case — OR establish the definitive obstruction proving no such uniform navigable A exists (mirroring the free-anchor refutation already proven for the exterior/free case). The task must reach one of these two decisive outcomes; it may not defer or reframe.

THREE PROVEN OBSTRUCTIONS ANY APPROACH MUST RESPECT (all sorry-free counterexample machinery — do not re-attempt any of these three routes):
1. Projection VecEA2 non-injectivity: the coupled quant layer for the depth-(k+1) x=t diagonal case does NOT factor through per-variable projections; `liftIdx(totalUnskip)` is non-injective. Proven in Kamp/NfZoneDepthK.lean (Phase 10, `renameNF_eval_diag0` context) — do not re-attempt a projection-based VecEA2 bridge for x=t.
2. D1 flat-bracket interior-confinement: a `BracketFormula.holds M atomMap x t bf` with depth-0 atomic types is confined to the closed interval [x,t] and cannot capture exterior-w realizability (zones w<x, t<w). Proven sorry-free by `interior_bracket_cannot_realize_exterior_sub_k1` in Kamp/NfZoneDepthK1Probe.lean — do not re-attempt a flat single-interval atomic bracket absorption.
3. Phase-16 free-anchor identification obstruction: for a FREE anchor x, no x-independent formula A can satisfy the future-zone gate iff `temporal_truth M atomMap t A <-> exists y, t<y AND nf_eval_nf M 1 3 (zoneEnv3 y x t) qnf` in any non-degenerate model, because the RHS pins x's local monadic type (`future_zone_pins_x_pred`) while an x-independent formula at t has one fixed truth value (`gate_forces_x_independence`) — navigation can quantify over points but cannot NAME a specific free anchor. Proven sorry-free by `no_x_independent_formula_captures_future_zone_k1` in Kamp/NfZoneNavProbe.lean. This task's open question is whether the SAME obstruction recurs when x is existentially bound (not free) rather than assuming it automatically does or does not.

PRESERVED REUSABLE ASSETS (must not be rebuilt; consume, do not re-derive):
- `renameNF_eval_diag0` — depth-0 diagonal value-duplication congruence (NfDepth0Generalized.lean:1646), sorry-free, off-path; usable as the x=t diagonal arm base.
- Phase 11a/11b extraction and split lemmas in Kamp/NfZoneDepthK.lean: `nf_eval_atom_layer`, `zoneEnv3`, `nf3_order_*` (atom/order extraction); `nf_eval_quant_layer`, `nf_zone_exists_iff_char`, `exists_trichotomy_split`, `nf_zone_partition5`, `nf_zone_exists_partition5` (outer y-split); `nf_characteristic_atom_succ`, `nf_characteristic_quant_succ`, `nf_char_eq_iff_eval`, `exists_nested_split3`, `nf_characteristic_quant_split3`, `nf_char3_eq_succ_iff` (inner w-split + char interface). All sorry-free, off-path.
- `prior_hasAttainedINF` (Kamp/PriorINF.lean:224, sorry-free): `semantic_prior_UZ M atomMap -> HasAttainedINF M atomMap`, in scope on the live path via h_UZ; unlocks `neg_bounded_exists`/`neg_interval_formula`.
- `neg_interval_formula` (Lemma 5.1 forward, Kamp/EANegationClosure.lean:401) and `neg_bounded_exists` (Cor 5.4 forward, Kamp/EANegationClosure.lean:492) — model-dependent negation/INF closures, sorry-free.
- `existClosureLeft`/`existClosureLeft_correct`/`existClosureLeft_correct_rev`, `existClosure` (Kamp/VecEATranslation.lean, VecEA_m.lean:208) — Phase 7 leftward existential closure, sorry-free, off-path.
- Prop43.lean atomic blocks: `atomAt`/`ltAt`/`tt`/`ff` (+`_holds`), Kamp/Prop43.lean:45-109, sorry-free — faithful uniform Prop-4.3 atomic clauses; do NOT reopen the uniform-VecEA-negation framing (Prop43.lean's own BLOCKER note over-reaches the paper per plan v40's mitigated divergence risk).
- Bracket builders `bracketBuildLeft`/`bracketBuildRight` (+`_correct`), Kamp/VecEATranslation.lean:50,234, sorry-free — the navigation mechanism itself, arbitrary TemporalPred.
- Depth-k IH engine `exist_tl_fn_k`/`exist_tl_fn_k_correct` (Kamp/KampPrior.lean:334-344), in scope at :391.

LITERATURE GROUNDING: ~/Projects/Literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.md Section 5 (Lemma 5.1, md:134-152; Corollary 5.4, md:154-157). KEY ARCHITECTURAL FACT (must not be violated): the paper's F_i chain (`F_n := alpha_n`, `F_{i-1} := alpha_{i-1} AND (beta_i Until F_i)`) couples witnesses to the interval ENDPOINTS z_0, z_1 ONLY — never to a third free or bound anchor beyond the two endpoints already in scope. Rabinovich caps free variables at <= 2 (Lemma 3.2.2) and absorbs deeper quantifier structure as additional bracket witnesses within ONE interval, not as new anchors. Any candidate construction for this task must be checked against this fact: if the construction requires encoding a characteristic-type condition on a third anchor at a single navigable point (the arity-tower pattern already refuted in reports/40_phase11b-divergence-audit.md and reports/37/38 faithfulness audits), that is evidence the bound-anchor case shares the same obstruction as the free-anchor case, not a reason to build the tower anyway.

GOAL STATE: Either (a) close KampPrior.lean:391 sorry-free using the constructed converter, reducing the live-path sorry baseline from 2 to 1 (with :394 downstream, per task 305 Phase 19/20 scope), and hand a working rewire back to task 305; or (b) establish the definitive obstruction for the bound-anchor case (sorry-free counterexample machinery analogous to NfZoneNavProbe.lean's free-anchor proof) and document the resulting axiomatization/scope decision for :391 and :394 (e.g. whether the two sorries become a permanent documented gap, an axiom, or route to a different overall proof strategy for Kamp's theorem in this codebase). Either outcome must leave `lake build` GREEN with the top-level axiom set unchanged (2 axioms: propext/Classical.choice/Quot.sound style, per task 305 baseline) and record which of (a)/(b) was reached in a report/summary under specs/307_kamp_cor54_bound_anchor_zone_converter/.

---

### 305. Rabinovich ea formula implementation
- **Status**: [BLOCKED]
- **Task Type**: lean4
- **Topic**: completeness
- **Dependencies**: Task 307
- **Research**:
  - [305_rabinovich_ea_formula_implementation/reports/01_ea-formula-research.md]
  - [305_rabinovich_ea_formula_implementation/reports/04_faithful-lemma51-design.md]
  - [305_rabinovich_ea_formula_implementation/reports/05_vecEA2-level-lemma51.md]
  - [305_rabinovich_ea_formula_implementation/reports/07_zone3-induction-design.md]
  - [305_rabinovich_ea_formula_implementation/reports/08_nf-eval-boost-design.md]
  - [305_rabinovich_ea_formula_implementation/reports/14_constructive-eval-design.md]
  - [305_rabinovich_ea_formula_implementation/reports/17_faithful-bridge-design.md]
  - [305_rabinovich_ea_formula_implementation/reports/20_eanegation-sorry-analysis.md]
  - [305_rabinovich_ea_formula_implementation/reports/24_z-completeness-rabinovich.md]
  - [305_rabinovich_ea_formula_implementation/reports/14_faithfulness-audit.md]
  - [305_rabinovich_ea_formula_implementation/reports/15_arity-tower-deviation.md]
  - [305_rabinovich_ea_formula_implementation/reports/16_syntactic-vea-design.md]
  - [305_rabinovich_ea_formula_implementation/reports/17_b2-construction-fix.md]
  - [305_rabinovich_ea_formula_implementation/reports/18_rabinovich-restructure-design.md]
  - [305_rabinovich_ea_formula_implementation/reports/18_circularity-resolution-n1.md]
  - [305_rabinovich_ea_formula_implementation/reports/35_team-research.md]
  - [305_rabinovich_ea_formula_implementation/reports/36_phase0-regate-decision.md]
  - [305_rabinovich_ea_formula_implementation/reports/37_hard-findings-critical-audit.md]
  - [305_rabinovich_ea_formula_implementation/reports/38_prop43-unblock-design.md]
  - [305_rabinovich_ea_formula_implementation/reports/39_depth-k1-bridge-design.md]
- **Plan**:
  - [305_rabinovich_ea_formula_implementation/plans/37_faithful-rabinovich-path.md]
  - [305_rabinovich_ea_formula_implementation/plans/38_lemma34-m1-rewire.md]
  - [305_rabinovich_ea_formula_implementation/plans/39_direct-nf-construction.md]

**Description**: Implement Rabinovich's proof of Kamp's theorem (Option A from report 20): faithful EA-formula formalization with negation closure via interval splitting. Define EAFormula type, prove closure properties (Lemma 3.2/3.4), V-EA to TL conversion (Prop 3.5), INF formula construction, Lemma 5.3/Corollary 5.4, full Lemma 5.1 (negation closure by induction on witness count n), and Propositions 4.2/4.3. Then rewire KampBypass k>0 to use the new single-structure path, eliminating all PriorComposition sorry. ~2200 lines across 8 new files. Depends on: existing CharPart/NormalForm infrastructure (sorry-free). Blocks: task 303 completion

---

### 303. K gt 0 depth induction
- **Status**: [PLANNED]
- **Task Type**: lean4
- **Topic**: completeness
- **Dependencies**: Task 305
- **Research**:
  - [303_k_gt_0_depth_induction/reports/01_team-research.md]
  - [303_k_gt_0_depth_induction/reports/02_depth-induction-resolution.md]
  - [303_k_gt_0_depth_induction/reports/04_rabinovich-formula-analysis.md]
  - [303_k_gt_0_depth_induction/reports/05_recursive-formula-design.md]
  - [303_k_gt_0_depth_induction/reports/06_generalexistpart-redesign.md]
  - [303_k_gt_0_depth_induction/reports/07_literature-construction.md]
  - [303_k_gt_0_depth_induction/reports/09_interval-splitting-mapping.md]
  - [303_k_gt_0_depth_induction/reports/09_interval-splitting-mapping.md]
  - [303_k_gt_0_depth_induction/reports/10_blocker-resolution-path.md]
- **Summary**: [303_k_gt_0_depth_induction/summaries/02_depth-induction-summary.md]
- **Plan**:
  - [303_k_gt_0_depth_induction/plans/14_literature-grounded-plan.md]
  - [303_k_gt_0_depth_induction/plans/15_charpart-threading-plan.md]
  - [303_k_gt_0_depth_induction/plans/16_strong-d-induction-plan.md]
  - [303_k_gt_0_depth_induction/plans/17_reconstruction-induction-plan.md]
  - [303_k_gt_0_depth_induction/plans/18_nvar-transfer-plan.md]
  - [303_k_gt_0_depth_induction/plans/19_subsumption-closure-plan.md]

**Description**: Close existPart_succ_n1_bypass k>0 (KampBypass.lean) via Rabinovich Section 5 Lemma 5.1 interval-splitting induction. This is the SOLE remaining sorry blocking completeness_discrete. The k=0 infrastructure (complete and sorry-free, ~4400 lines) provides the template. Estimated effort: 200-400 lines. The key step: when negating an exists-forall formula with n witnesses at depth k+1, each insertion point creates sub-interval negation problems with fewer witnesses at depth k.

---

### 299. Refactor discrete game transfer
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: completeness
- **Dependencies**: Task 303

**Description**: Refactor DiscreteGameTransfer.lean to eliminate the wrapper pattern once the completeness chain is sorry-free. Inline discrete_ghr93_theorem6 by having StaviCompleteness.lean call ghr93_forward_to_backward directly with discrete typeclass instances. Convert discrete_rank_embed_eq_drc to a @[simp] lemma. Remove discrete_ghr93_theorem6_rank_varying if callers can use the general version. Clean up any dead code from the old fixed-pivot architecture that was deleted in task 273.

---

### 298. Fix c7 labeling bug and regenerate dataset
- **Status**: [PLANNED]
- **Task Type**: lean4
- **Dependencies**: Task 297, Task 343
- **Research**: [298_fix_c7_labeling_bug_and_regenerate_dataset/reports/01_c7-labeling-bug.md]
- **Plan**: [298_fix_c7_labeling_bug_and_regenerate_dataset/plans/01_c7-labeling-bug.md]

**Description**: Fix c7 labeling bug at formula ~13750 that causes unbounded memory growth in the decision procedure's timeout handling, then regenerate the full c7 dataset. During task 297 dataset regeneration, all 3 attempts to generate c7 stalled at exactly record 13,749 with RSS growing ~40MB/6s. The labeling function enters an apparent infinite loop or unbounded search for formula #13,750 in the sorted enumeration order. The timeout mechanism either does not fire or cannot interrupt the stuck state. Steps: (1) Identify the specific formula at position ~13,750 in the c7 enumeration. (2) Reproduce the hang in isolation with that formula. (3) Diagnose whether the decision procedure's timeout is failing to fire or the procedure is in an uninterruptible state. (4) Fix the timeout handling so it reliably terminates. (5) Regenerate the full c7 dataset (target: 77,272 records)

---

### 296. Re add derived binary operators with dedup fix
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: dataset-enhancement
- **Dependencies**: Task 295

**Description**: Re-add the 6 derived binary temporal operators (release, weak_until, trigger, weak_since, strong_release, strong_trigger) to the formula enumerator, adjusting canonicalization and/or the passesFilter gate so they survive deduplication and appear in the unique pipeline output. These operators were removed in task 295 because they inflated the enumeration space by ~40-60% without contributing unique formulas — their canonical representations collapsed with primitives. Potential approaches: (1) skip canonicalization for formulas containing derived binary operators, (2) canonicalize to the derived form instead of the primitive form, (3) lower or remove the passesFilter complexity gate for these operators, (4) add a fold-aware dedup stage that treats release(p,q) as distinct from neg(untl(neg p, neg q)). The goal is to have all 13 derived operators represented in the final dataset.

---

### 294. Eliminate sorry in modals5 and perpetuity
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: sorry-elimination
- **Dependencies**: Task 291

**Description**: Eliminate all sorry instances in Theorems/ModalS5.lean and Theorems/Perpetuity/Principles.lean. These files are needed for PR 4 (Derived Theorems) in cslib but contain 1-3 sorry each. Analysis suggests these are small enough to resolve: ModalS5.lean sorries likely require direct axiom application or simple combinatorial arguments; Perpetuity/Principles.lean sorries relate to fixpoint principles for G/H operators that should follow from the core axiom system. Complete both files to be fully sorry-free. Run lake build to verify zero errors and zero sorries.

---

### 293. Audit and fix mathlib linter compliance
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: publication-quality
- **Dependencies**: Task 291

**Description**: Audit and fix Mathlib linter compliance across all sorry-free modules scheduled for porting to cslib (Syntax, Semantics, ProofSystem, Theorems, FrameConditions, Soundness, MCS/Deduction, Completeness, Decidability, Separation, ConservativeExtension). Run the Mathlib linter (set_option linter.all true or use #check_lint). Fix: (1) Naming convention violations -- Mathlib uses descriptive snake_case names not opaque abbreviations (e.g., bfmcs, drm). (2) Missing docstrings on public declarations. (3) Universe polymorphism issues. (4) Line length violations (100 char limit). (5) Unused variable warnings. This task produces files ready for direct porting to cslib without linter failures.

---

### 292. Add copyright headers to all source files
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: publication-quality
- **Dependencies**: Task 291

**Description**: Add Apache 2.0 copyright headers to all source files under Theories/Bimodal/ (approximately 160 .lean files). cslib requires headers on all contributed files following the format: "-- Copyright (c) 2024 The Bimodal Logic Contributors. All rights reserved. -- Released under Apache 2.0 license as described in the file LICENSE. -- Authors: [author names]". Use a script to batch-add headers to files that lack them. Verify no duplicates are introduced. Run lake build to confirm no import errors.

---

### 291. Upgrade lean toolchain to v431 and mathlib
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: toolchain
- **Dependencies**: None

**Description**: Upgrade Lean toolchain from v4.27 to v4.31 and update Mathlib to the same pin as cslib. This is a prerequisite for all porting tasks: cslib uses Lean 4.31 and tasks 292-294 cannot proceed until BimodalLogic builds cleanly on 4.31. Steps: (1) Update lean-toolchain to v4.31.0-rc1 (or current cslib pin). (2) Run lake update to fetch compatible Mathlib. (3) Fix any API breakage caused by Lean/Mathlib version bump (expect ~50-200 lines of fixes across formula, tactic, and instance changes). (4) Run lake build to confirm zero errors. (5) Run existing tests to confirm no regressions. This task unlocks tasks 292, 293, 294 and all cslib porting tasks (2-13).

---

### 290. Improve tableau fuel allocation
- **Status**: [PLANNED]
- **Task Type**: lean4
- **Topic**: dataset-enhancement
- **Dependencies**: Task 288
- **Research**: [290_improve_tableau_fuel_allocation/reports/01_fuel-allocation-research.md]
- **Plan**: [290_improve_tableau_fuel_allocation/plans/01_fuel-allocation-plan.md]

**Description**: Improve tableau fuel allocation heuristic for imbalanced branches. Add estimateBranchDifficulty heuristic (temporal count, modal count, branch depth). Allocate fuel proportionally to difficulty across sub-branches. Prove termination still holds. Benchmark on c6. Expected 2-5% timeout reduction.

---

### 282. Exhaustive enumeration by default
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: dataset-enhancement
- **Dependencies**: Task 274

---

### 257. Large data storage huggingface
- **Status**: [IMPLEMENTING]
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

### 230. Benchmark refresh splits paraphrases schema
- **Status**: [NOT STARTED]
- **Task Type**: general
- **Topic**: dataset-enhancement
- **Dependencies**: Task 229

**Description**: After contamination resolution (task 229), regenerate all benchmark-derived artifacts. (1) Regenerate bmlogic-bench-splits.json for current record count — splits reference 727 records but benchmark now has 777. Run generate_splits.py and validate all IDs assigned to exactly one slice. (2) Restore NL paraphrase fields: benchmark was regenerated after paraphrases were added, losing nl_paraphrase and nl_paraphrase_method. Run generate_paraphrases.py and validate with validate_paraphrases.py. (3) Schema alignment: add formula_sexpr, formula_tokens, and pattern_features to benchmark records so evaluation uses the same representations as training. Extend finalize_benchmark.py or create enrichment script. (4) Decide whether to remove or keep the redundant max_modal_depth/max_temporal_depth fields in training data (they duplicate metrics.modalDepth/temporalDepth and pattern_key.modalDepth/temporalDepth — three copies of the same data). (5) Fill pattern_key for the 15 benchmark records where it is currently null.

---

### 219. Llm baseline difficulty calibration
- **Status**: [RESEARCHED]
- **Task Type**: general
- **Topic**: dataset-enhancement
- **Dependencies**: None
- **Research**: [219_llm_baseline_difficulty_calibration/reports/01_llm-baseline-research.md]

**Description**: Run bmlogic-bench through multiple LLMs to establish baseline difficulty calibration. Evaluate at least 3 models (GPT-4o, Claude Sonnet, a 7B open model). Report zero-shot accuracy per difficulty tier (easy/medium/hard/very_hard), chain-of-thought vs direct label accuracy, error rate correlation with modal/temporal depth. Include random baseline (50% for balanced benchmark). Publish results in data/baselines/README.md with methodology. Both symbolic formula input and NL paraphrase input (if available from R1).

---

### 199. Grid order tactic
- **Status**: [PARTIAL]
- **Task Type**: lean4
- **Topic**: automation
- **Dependencies**: None
- **Research**: [199_grid_order_tactic/reports/01_grid-order-tactic.md]
- **Plan**: [199_grid_order_tactic/plans/01_grid-order-tactic.md]

**Description**: Create a bespoke grid_order_tac tactic (in Theories/Bimodal/Automation/) that automates the same_order_type grid dispatch in ghr93_case_II (Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/CaseAnalysis.lean). The problem: after same_order_type_grid expands to intro i j; simp only [game_tuple]; split_ifs, it generates ~25 ordering goals per case. Each goal has shape (a_bwd ⟨k, proof_n+1⟩ < x ↔ resp_tau ⟨k, proof_n⟩ < y) ∧ (... = ... ↔ ...). The available ordering lemmas (tau_sel_y, tau_sel_sel, sel_pn_ord, pn_sel_ord, tau_d_sel, hord_cd_en_pn, pivot_chain_order, fwd_x_b, fwd_b_y) are stated with Fin n but the goals use Fin (n+1), causing exact to fail on metavar unification. The tactic must: (1) try each ordering lemma with automatic Fin bridging via convert ... using 3 <;> (congr 1; exact Fin.ext (by omega)), (2) handle the hab_eq rewrite for p_n cases (when not k < n, rewrite a_bwd to extendPoint p_n before applying sel_pn_ord/pn_sel_ord), (3) handle symmetry (y < sel goal uses tau_sel_y.symm), (4) fall back to sorry with trace if no lemma applies. After building the tactic, apply it to replace the two sorry fallbacks in ghr93_case_II: Case A sorry at line ~1631 and Case B sorry at line ~1940. These are the last fallthrough goals in the first | ... | sorry chains inside the same_order_type proof obligation. Verify zero build errors. Iterate on the tactic if the initial version does not close all goals.

---

### 196. Codebase tactic survey
- **Status**: [RESEARCHED]
- **Task Type**: lean4
- **Topic**: automation
- **Dependencies**: Task 161
- **Research**: [196_codebase_tactic_survey/reports/01_team-research.md]

**Description**: Systematic survey of the entire Theories/Bimodal/ codebase to identify all tactic and automation opportunities. Produces a ranked inventory of tactic groups with effort estimates, line savings, and dependency relationships. Output: one new task per tactic group, replacing or refining existing tasks 185-195.

---

### 194. Migrate nonempty to derivable
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: formula-refactor
- **Dependencies**: None
- **Research**: [194_migrate_nonempty_to_derivable/reports/01_derivable-migration-seed.md]

---

### 193. Codebase tactic refactor
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: automation
- **Dependencies**: Task 189, Task 192, Task 196
- **Research**: [193_codebase_tactic_refactor/reports/01_codebase-refactor-seed.md]

---

### 192. Master tactic dispatch
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: automation
- **Dependencies**: Task 185, Task 187, Task 190, Task 191, Task 194
- **Research**: [192_master_tactic_dispatch/reports/01_master-dispatch-seed.md]

---

### 191. Propositional decision procedure
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: automation
- **Dependencies**: None
- **Research**: [191_propositional_decision_procedure/reports/01_decision-procedure-seed.md]

---

### 189. Deduction theorem tactic
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: automation
- **Dependencies**: None
- **Research**: [189_deduction_theorem_tactic/reports/01_deduction-theorem-seed.md]

---

### 188. Weakening aware search
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: automation
- **Dependencies**: None
- **Research**: [188_weakening_aware_search/reports/01_weakening-aware-seed.md]

---

### 187. Backward chaining lemma db
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: automation
- **Dependencies**: None
- **Research**: [187_backward_chaining_lemma_db/reports/01_lemma-database-seed.md]

---

### 186. Unify search systems
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: automation
- **Dependencies**: Task 185
- **Research**: [186_unify_search_systems/reports/01_unify-search-seed.md]

---

### 180. Copyright headers universe polymorphism line limits
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: publication-quality
- **Dependencies**: None

---

### 179. Research lean4 tactics infrastructure
- **Status**: [RESEARCHED]
- **Task Type**: lean4
- **Topic**: automation
- **Dependencies**: None
- **Research**:
  - [179_research_lean4_tactics_infrastructure/reports/01_team-research.md]
  - [179_research_lean4_tactics_infrastructure/reports/02_mathlib-submission.md]

---

### 178. Publication examples and demo
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: formula-refactor
- **Dependencies**: Task 131, Task 193

**Description**: Expand Examples/ with publication-quality demonstrations of the full verified pipeline. Complete worked example showing soundness-completeness-decidability on a concrete formula. Examples exercising each frame class with FrameClass-parameterized DerivationTree. Examples of the expressive completeness result. Update BimodalProofs.lean and TemporalStructures.lean. All examples sorry-free.

---

### 177. Update readme and module docstrings
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: formula-refactor
- **Dependencies**: Task 131, Task 193

**Description**: Update all documentation to match final codebase state after refactoring. README.md axiom counts, architecture diagram, sorry obligations. Module-level docstrings for every file in the final structure. ROADMAP.md updates. Axiom Reference doc verification. This is the final documentation pass after all structural refactoring is complete.

---

### 175. Naming convention and bridge cleanup
- **Status**: [RESEARCHED]
- **Task Type**: lean4
- **Topic**: formula-refactor
- **Dependencies**: None
- **Research**: [175_naming_convention_and_bridge_cleanup/reports/01_team-research.md]

**Description**: Normalize naming conventions to follow Mathlib-style descriptive conventions and eliminate bridge/wrapper indirection for publication quality. Adopt Mathlib naming patterns: bot_of_and_neg instead of ecq, and_left instead of lce, and_right instead of rce, or_inl instead of ldi, or_inr instead of rdi, absurd instead of raa, False.elim instead of efq, not_not_intro instead of dni, etc. Expand opaque abbreviations (bfmcs, drm, cud, sdc, dd_, tc_, fuc_, buc_). Inline or remove Bridge.lean wrappers (993 lines, 16 forwarding definitions). Eliminate trivial primed variants. Normalize z1_valid to axiom_z1_valid for consistency. Rename temp_ prefix to temporal_ for clarity. Purge 81 removed/archived/superseded tombstone comments. Reference Mathlib naming conventions guide and task 179 research report for the full mapping.

---

### 170. Complete dense extension completeness
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: completeness
- **Dependencies**: None

---

### 169. Complete frame extension setup and soundness
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: completeness
- **Dependencies**: None

---

### 165. Establish semantic finite model property
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: completeness
- **Dependencies**: None

**Description**: Establish the semantic finite model property for TM bimodal logic. The existing FMP in Decidability/FMP/ is purely proof-theoretic: it shows closure MCS structures are finite and that provability is decidable via MCS enumeration, but it does not construct finite semantic models (task frames with world histories). A standard semantic FMP requires: (1) Starting from a canonical model where phi fails, quotient worlds by agreement on the subformula closure. (2) Prove the filtration lemma for all formula constructors including Until/Since (known to be problematic for naive filtration). (3) Prove the quotient model is a valid task frame. (4) Bound the model size by 2^|cl(phi)|. The result should be stated as: if phi is satisfiable in a task model, then phi is satisfiable in a finite task model of bounded size.

---

### 162. Enforce plan compliance rule
- **Status**: [NOT STARTED]
- **Task Type**: meta
- **Topic**: agent-system
- **Dependencies**: None

**Description**: Add a .claude/rules/ rule enforcing strict plan compliance for lean-implementation-agent and other formal implementation agents. The rule should: (1) Prohibit agents from "assessing what's truly minimal" or inventing alternative approaches when a plan exists. (2) Require agents to follow the plan's exact task sequence step-by-step, in order. (3) Explicitly ban common divergence patterns: skipping intermediate theorems, inlining proofs instead of following the plan's decomposition, routing through different helper lemmas than specified, and "cleaner approach" rationalizations. (4) Be auto-applied via glob pattern to Theories/ and any formal proof files. (5) Reference the repeated failures in task 157 (8 plan versions, agents diverging every time) as motivation. The rule should be concise but firm -- agents must treat the plan as a contract, not a suggestion.

---

### 161. Rename theories bimodal to formalsystem
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: formula-refactor
- **Dependencies**: None

**Description**: Rename Theories/Bimodal/ to FormalSystem/. Move the entire Theories/Bimodal/ directory to FormalSystem/, update all imports in Lean files, update lakefile.lean srcDir from Theories to FormalSystem and roots from Bimodal to FormalSystem, update any references in README.md, Tests/, and other files that point to the old path. Ensure lake build still passes after the rename.

---

### 131. Refactor module organization
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: formula-refactor
- **Dependencies**: None

**Description**: Restructure Theories/Bimodal/ file hierarchy for clean APIs and documentation. Currently 130 live .lean files across 7 top-level directories, with the Metalogic/ directory being a catch-all containing 7 subdirectories (Algebraic, Bundle, BXCanonical, ConservativeExtension, Core, Decidability, Relational) plus loose files (Soundness.lean, SoundnessLemmas.lean, DenseSoundness.lean, DiscreteSoundness.lean, Completeness.lean, Metalogic.lean). Goals: (1) Reorganize Metalogic/ into a clearer hierarchy — group soundness files into Metalogic/Soundness/, completeness files into Metalogic/Completeness/, clarify relationship between BXCanonical (chronicle approach) and Algebraic (parametric approach). (2) Add module-level documentation (docstrings on namespace declarations, module descriptions at file tops). (3) Establish clean APIs with explicit exports via root .lean files for each subdirectory. (4) Evaluate whether FrameConditions/ should be merged into Metalogic/ or remain separate. (5) Audit Boneyard/ organization (45 files across 10+ subdirectories). (6) Consider whether docs/ and latex/ and typst/ should remain under Theories/Bimodal/ or move to project root.

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
- **Task Type**: general
- **Topic**: completeness
- **Dependencies**: Task 303

**Description**: Verification pass on sorry status for completeness_discrete and bx_completeness. Updated scope after task 202 completion and task 155 re-scope: (1) Verify dd_countermodel_chronicle_dense and dd_countermodel_chronicle_mixed_sorry show no sorryAx (confirmed sorry-free as of 2026-05-15). (2) Trace the discrete case sorryAx: The BX chronicle path (dd_countermodel_chronicle_discrete -> succ_embed_surjective -> limitDomSubtype_isSuccArchimedean -> succ_cofinal) is being bypassed. The correct fix is the WeakCanonical path: task 155 targets closing the no_gaps_discrete import cycle (GoodStructures.lean:855) by delegating to no_gaps_discrete_model_surgery (GoodStructuresModelSurgery.lean:2133), then rewiring completeness_discrete. Note: succ_cofinal remains the current root sorry on the BX chronicle path (ChronicleToCountermodel.lean), but this path is dead code -- the WeakCanonical route via no_gaps_discrete_model_surgery (already sorry-free) is the production path once the import cycle is resolved by task 155. (3) Classify all Metalogic/ sorry occurrences as critical-path vs dead-code vs non-critical-path. (4) Update stale axiom audit comments in Completeness.lean (lines 177-234 reference CE:3570 which is no longer the sorry source). (5) Verify soundness and decidability remain sorry-free. (6) Produce audit report. Dependencies on tasks 93 and 109 removed (both completed).
