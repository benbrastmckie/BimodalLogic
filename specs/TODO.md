---
next_project_number: 326
---

# TODO

Warning: 1 task(s) have no topic and will render under Uncategorized: 298 (non-fatal)
## Task Order

*Updated 2026-07-07. Generated from state.json dependency graph.*

**Dependency Waves**:
| Wave | Tasks | Blocked by | Topics |
|------|-------|------------|--------|
| 1 | 125,127,128,131,161,162,165,169,170,175,179,180,186,187,188,189,191,194,199,219,230,257,282,290,290,291,296,300,318,321 | -- | completeness, formula-refactor, frame-extensions, ... |
| 2 | 192,196,231,292,293,294,298,309 | 161,187,191,194,230,291,300,321 | publication-quality, sorry-elimination, automation, ... |
| 3 | 193,307 | 189,192,196,309 | completeness, automation |
| 4 | 177,178,305 | 131,193,307 | completeness, formula-refactor |
| 5 | 303 | 305 | completeness |
| 6 | 95,299 | 303 | completeness |

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

300 [NOT STARTED] — Make the tableau decision procedure abort-aware by threading an I
  └─ 298 [PLANNED] — Fix c7 labeling bug at formula ~13750 that causes unbounded memor

### Reference Book

318 [NOT STARTED] — GATED ON EXTERNAL EVENT: execute only after the Lk paper (anonymo

### Kamp_theorem_formalization

321 [BLOCKED] — Depends on task 320's probe result. Task 309 (offdiag_two_anchor_
  └─ 309 [BLOCKED] — Build the off-diagonal two-anchor navigated characteristic (Rabin

### Uncategorized

## Tasks

### 325. Redesign k2 subbracket to vvecea2 arrangementdisjunction
- **Effort**: 10-16 hours
- **Status**: [COMPLETED]
- **Task Type**: lean4
- **Topic**: kamp_theorem_formalization
- **Dependencies**: None
- **Research**:
  - [324_redesign_k2_subbracket_arity4_correctness_pair/reports/03_spawn-analysis.md]
  - [325_redesign_k2_subbracket_to_vvecea2_arrangementdisjunction/reports/01_adversarial-verification.md]
- **Plan**:
  - [325_redesign_k2_subbracket_to_vvecea2_arrangementdisjunction/plans/01_vvecea2-carrier-redesign.md]
  - [325_redesign_k2_subbracket_to_vvecea2_arrangementdisjunction/plans/02_vvecea2-carrier-v2-nine-zone-gate.md]

**Description**: Task 324's Phases 1-5 landed a k=2 arity-4 sub-bracket construction (kvE_subBracket2/kvE_subChain2, NfMultiAnchorBridge.lean:6120-6720) with a soundness direction (kvE_subBracket2_sound, :6530) and a completeness *extraction* kit (kvE_subBracket2_complete_extract, :6683). Phase 6 (the completeness converse) is machine-refuted: adversarially-verified blocker research (specs/324_redesign_k2_subbracket_arity4_correctness_pair/reports/02_phase6-blocker-research.md) proves the converse `(exists x1, nf_eval_nf M 1 4 [x1,w,x,t] sigma) -> (kvE_subBracket2 ...).2.holds M atomMap x t` is a FALSE forall-M statement over the current carrier, for two independent, machine-confirmed reasons: (1) kvE_subBracket2.segmentTypes is the CONSTANT segExcl (all-three-zone exclusion, :6159), but IntervalPattern.holds (ExistsForallNF.lean:106-132) requires each segment type to hold at EVERY point of its open segment, while the depth-1 fold (nf_eval_depth1_fold_iff :5187) only forces zone-membership <-> fold-bit for a point's OWN zone, never cross-zone positivity -- an interior point realized only in one zone survives the antecedent yet falsifies segExcl; (2) kvE_subBracket2.pointTypes is a FIXED filter-order list (Finset.univ.toList-derived leftSlots/rightSlots, :6139-6158), but IntervalPattern.holds needs strictly-monotone witnesses positionally matching that fixed order, and the model's realization order need not match it. Report 02 Q2 additionally shows no rescue is available on the current carrier: the codomain (Sigma m, BracketFormula (m+1), a single IntervalPattern) is structurally the wrong shape for completeness -- the landed k1v template's completeness (bracketEndChar_k1v_complete, :2979) is provable ONLY because that carrier is a VVecEA2 finite disjunction over arrangement permutations with PER-SIDE segment types (bracketFromLists.segmentTypes, :1902), letting completeness (a) select the model-sorted arrangement disjunct and (b) discharge each side's segment type because every point of that side is genuinely zone-positive there. A gate-hypothesis rescue is also rejected: in completeness .holds is the CONCLUSION (unlike soundness where it is the hypothesis), so any hypothesis strong enough to make it provable would itself assert the monotone-positional + per-segment conditions -- i.e. it would BE the conclusion, trivializing the deliverable.

DELIVERABLE (standalone against nf_eval_nf M 1 4, NOT wired into the outer gate): a corrected carrier `kvE_subBracket2V`/`kvE_subChain2V` (exact names at implementer discretion) plus a freshly re-derived, machine-driven-through soundness AND completeness pair over it, per report 02 Q3's corrected target definition:
(1) CODOMAIN CHANGE: replace `Sigma m, BracketFormula (m+1)` with `VVecEA2` (`Sigma n, VecEA2 n`, a finite disjunction) -- satisfies Guard G6 (codomain may be witness-growing VVecEA2) and report 321/01 Section 2 (:225, which already declared VVecEA2 as the binding amended-spec codomain that kvE_subBracket2 deviated from).
(2) FIXED ENDPOINTS: `{x, t}` only, every disjunct's VecEA2.holds evaluated at `(x,t)` -- satisfies Guard G4 (anchor set fixed at {x,t}) and the Corrected Anchor-Cap (endpoint/anchor count <= 2).
(3) THREE INTERIOR REGIONS (not two, since the arity-4 env `[x1,w,x,t]` has two interior fixed references `x1` and `w`): regions `(x,x1)=zXU`, `(x1,w)=zUW`, `(w,t)=zWT`; both `x1` and `w` become bracket WITNESS SLOTS (not endpoints/anchors, so G4/Cap stay respected -- anchor count stays 2). Point-type layout per disjunct: `zXU-arrangement ++ [x1-slot] ++ zUW-arrangement ++ [w-slot] ++ zWT-arrangement`.
(4) THREE PER-REGION SEGMENT TYPES: `segXU` excludes only zXU-negatives on (x,x1); `segUW` only zUW-negatives on (x1,w); `segWT` only zWT-negatives on (w,t) -- the arity-4 lift of `bracketFromLists.segmentTypes` (:1902), extended from a 2-way to a 3-way `if`. Satisfies Guard G3 (real exclusion segments, never top/const-multi-zone). Each region-segment is satisfiable in completeness because every point of that region is genuinely zone-positive there -- the exact property the old constant segExcl violated.
(5) DISJUNCTS: one per arrangement in `S_XU.permutations x S_UW.permutations x S_WT.permutations` (each `S_z = allTypes.filter (bits z .)`), mirroring `bracketEndChar_k1v` (:2013-2018); gate-failure branch = empty disjunction (holds = False).
(6) NO PROVIDER PINNING (Amendment F3): witness positions are the temporal-semantics-quantified bracket witnesses; no `w = e 1` / `x1 = e 0` residual equation. `w` enters as a witness TYPE slot (charBase of w's projection), realized by some point sorted between the zUW and zWT blocks, consistent with the given `w` by 1-type uniqueness.
(7) SUCCESSOR-PARAMETERIZED COMPATIBILITY: the redesign must read sigma.2 at the j+1 successor shift (sigma : NormalForm sig (j+1) 4, per specs/321.../reports/01_blocker-research-successor-k.md Section 2 :56/:225); at j=0 this is the landed NormalForm sig 1 4. The VVecEA2 codomain is exactly the spec's declared target, so this redesign converges the carrier onto the amended spec rather than diverging further.
(8) FULL CORRECTNESS PAIR: a soundness lemma (holds -> exists x1, nf_eval_nf M 1 4 (Fin.cons x1 [w,x,t]) sigma) GENUINELY RE-DERIVED (the landed kvE_subBracket2_sound binds the OLD single-bracket carrier and does not transfer), and a completeness lemma (the reverse), the arity-4 analog of bracketEndChar_k1v_sound (:2338) / bracketEndChar_k1v_complete (:2979), re-using the k1v template kit (k1v_sorted_realization/_insert/_bracket_construct/_bracket_extract, :2028-2825) one arity up but with a THREE-region (vs k1v's two-region) arrangement.

DRIVEN-PROOF VALIDATION DISCIPLINE (mandatory, binding): do NOT accept the redesigned construction on type-check/probe grounds. Two consecutive prior constructions have now failed EXACTLY that way -- kvE_subBracket (task 321 Phase 8: type-checked and probed clean, but its upward-only chain anchored at an interior point could not reach the zXU zone below it) and kvE_subBracket2 (task 324 Phase 6: type-checked and probed clean at soundness, but the completeness converse is a false forall-M statement). The new construction MUST be validated by actually driving BOTH the soundness direction AND the completeness direction through to a closed, sorry-free proof before the construction counts as validated -- neither direction may be deferred, assumed, or accepted on the strength of the other having closed.

PRESERVED-ASSET ACCOUNTING (per report 02, which asset survives near-verbatim vs must be re-derived):
- SURVIVE NEAR-VERBATIM (reusable raw material, adapt/consume, do not rebuild from scratch): kvE_sub2_zoneHolds_cons_iff (:6615), _zXU/_zUW/_zWT (:6642-6671) -- pure zoneHolds<->inequalities over env [x1,w,x,t], carrier-agnostic; kvE_subBracket2_complete_extract (:6683) -- reads nf_eval_nf M 1 4, independent of carrier, supplies the per-zone monotone witnesses the new disjunct closure consumes; kvE_sub2_zXU/zUW/zWT zone specs (:6200-6209) -- fold-bit zone specs, carrier-independent.
- RE-DERIVED (proof shape survives but statement changes, restated over the VVecEA2 disjunct .holds by destructuring the disjunction first, as bracketEndChar_k1v_sound :2352 does): kvE_subBracket2_extract (:6233), _reaches_z* (:6327-6381), kvE_subBracket2_fold_z* (:6434-6491), and kvE_subBracket2_sound (:6530) itself (soundness is stated against the CURRENT single bracket; this task owns a fresh sound/complete pair over the new carrier).
- REPLACED (new separately-named defs; originals stay byte-identical and unreferenced): kvE_subBracket2 (:6120) and kvE_subChain2 (:6166).

BINDING CONSTRAINTS (carried forward verbatim from task 324's description, self-contained):
- Guards G1-G6 + Corrected Anchor-Cap (source: specs/309_offdiag_two_anchor_fi_chain/plans/07_offdiag-fi-chain-plan.md:230-260): G1 no arity-1 collapse; G2 no projection-based third-free-anchor tower; G3 no trivial-top segment on carrier interval types; G4 witnesses stay bracket witnesses, anchor set fixed at {x,t}; G5 follow Cor 5.4/Prop 3.5 F_i chains step-by-step, cite Rabinovich at every chain step, no simp/omega/aesop shortcut (by omega permitted ONLY for Fin-index typing in signatures); G6 carrier stays the two-anchor bracket characteristic, fixed endpoints, codomain may be witness-growing VVecEA2 but anchor count never exceeds 2.
- Amendment F3: no provider-side pinning -- the provider disappears from the joint path; no w = e 1 / x = e 2 residual equation.
- DO-NOT-EDIT landed assets byte-identical, EXTENDED to now also include task-324's landed Phases 1-5 code (kvE_subBracket2/kvE_subChain2 + the full zone/reachability/soundness/extraction kit, NfMultiAnchorBridge.lean ~:6120-6720), in addition to all prior do-not-edit assets: task-321 Stage A/B code (kvE_subFoldBits, kvE_subInteriorZones, kvE_subBracket, kvE_subChain, kvE_subBracket_implies_subChain, kvE2_body + gate-fail, bracketEndChar_kvE2 + two_eq, the Stage-B discrimination lemmas), BracketCarrierCorrectVPrior, ExistProviders, all task-310/311 material, the task-320 probes, bracketEndChar_k1v/_sound/_complete and the full k1v proof kit (:2028-2825). SAME NEW-DEFINITIONS-ONLY EXCEPTION as task 324 (authorized only for this task, not a general license): add NEW, separately-named definitions rather than editing kvE_subBracket2/kvE_subChain2 or any earlier landed asset in place; originals stay byte-identical and unreferenced by the new work. Do NOT edit kvE2_body/bracketEndChar_kvE2 to re-point at the new construction -- that re-pointing is task 321's own resumption work via a future /revise 321, out of scope here. This task's lemmas are stated and proved standalone against nf_eval_nf M 1 4, not yet wired into the outer gate.
- CONSUME-DO-NOT-REBUILD list (extended per report 02's preserved-asset accounting): nf_eval_depth1_fold_iff (:5187), nf0_assemble (NfEFold.lean:180), nf_quant_layer_fold_iff (NfEFold:391), zone semantics kit (zoneHolds/EAtomDom), k1v helper kit (k1v_zoneHolds_cons_iff/k1v_zone_consistent/k1v_bracket_extract/k1v_reconstruct_nf3/k1v_sorted_insert/k1v_sorted_realization/k1v_bracket_construct, :2028-2825), bracketEndChar_k1v_sound/_complete direction templates, BracketFormula.bracket_implies_fChainPred (EANegation:660), existsBounded_right (VecEAClosure:265) -- PLUS, newly available from task 324's own Phases 1-5: kvE_sub2_zoneHolds_cons_iff/_zXU/_zUW/_zWT (:6615-6671), kvE_subBracket2_complete_extract (:6683), and the kvE_sub2_zXU/zUW/zWT zone specs (:6200-6209), all of which survive near-verbatim per report 02 and should be consumed/adapted rather than rebuilt.
- No EANegation :1090/:1249 (uniform-backward variants) may be consumed -- both are live sorrys, machine-confirmed.
- No simp/omega/aesop on chain-construction steps; by omega only for Fin-index typing; cite Rabinovich at every chain step per G5.
- No sorry on any live path, including intermediate WIP; keep unfinished work uncommitted until green.
- Literature grounding: ~/Projects/Literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.pdf -- Def 3.1 (md:61-74), Lemma 3.2(2) (md:76-79), Prop 3.5 (md:87-94), Def 4.1 (md p.5-6), Prop 4.2 (md:100-101), Lemma 5.1 (md:134-135), Lemma 5.3 (md:137-152, base-case negation -> V-forall-exists, the source of the per-region segment-type + disjunction-over-arrangements structure), Cor 5.4 (md:154-157, F_i chain / per-beta_i Until-chaining that requires per-region, not constant, segment types).

VERIFICATION: scoped lake build green after each committed lemma; axiom-clean (propext, Classical.choice, Quot.sound) via lean_verify; no forbidden tactics; no sorry; the new VVecEA2 carrier's per-region segment types and disjunct arrangement machine-verified to admit BOTH a closed soundness proof and a closed completeness proof (not merely a type-check) -- per the driven-proof validation discipline above.

SUGGESTED PHASE SKELETON (per report 02, realistically 4-5 one-dispatch phases, ~150-400 lines each): P1 VVecEA2 carrier def + three per-region segment types + gate; P2 three-region sorted_realization/bracket_construct lift (extending k1v's two-region kit); P3 soundness over the disjunction (destructure disjunct first, as bracketEndChar_k1v_sound does); P4 completeness (disjunct selection + per-region segment discharge); optionally P5 successor-parameter threading / final integration if P1-P4 do not fully absorb it.

AFTER COMPLETION: resume task 321 via /revise 321 (fold this task's delivered VVecEA2 carrier + full soundness/completeness pair into a v4 phase decomposition that re-points Phase 8 and downstream phases at it), then /implement 321.

---

### 324. Redesign k2 subbracket arity4 correctness pair
- **Effort**: 10-14 hours
- **Status**: [ABANDONED]
- **Task Type**: lean4
- **Topic**: kamp_theorem_formalization
- **Dependencies**: Task 325
- **Research**:
  - [321_implement_corrected_k2_carrier_and_close_the_correctness_gate_f4_resolution/reports/02_spawn-analysis.md]
  - [324_redesign_k2_subbracket_arity4_correctness_pair/reports/01_adversarial-verification.md]
  - [324_redesign_k2_subbracket_arity4_correctness_pair/reports/02_phase6-blocker-research.md]
- **Plan**: [324_redesign_k2_subbracket_arity4_correctness_pair/plans/01_arity4-correctness-pair-plan.md]

**Description**: Task 321's v3 plan Phase 8 (soundness scaffolding for the k=2 BracketCarrierCorrectVPrior gate over bracketEndChar_kvE2) is machine-grounded BLOCKED: the landed kvE_subBracket/kvE_subChain (task-321 Stage A, `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge.lean`) supply only a strictly-upward Until chain from the outer witness slot `u`, which structurally cannot reach sigma's own interior zone `zXU = (x,v,u)` (below `u`); and the sole landed connector `kvE_subBracket_implies_subChain` runs bracket-holds -> chain-at-point, the wrong direction for soundness (soundness needs chain-at-point -> full `nf_eval_nf M 1 4` reconstruction). No arity-4 sub-bracket correctness pair (soundness + completeness, the analog of the landed k1v `:2338`/`:2979` templates one arity up, with a cross-body sigma.1 atom-layer recovery channel) exists among landed assets.

DELIVERABLE (this task, standalone, NOT wired into the outer gate): (1) a corrected sub-bracket construction (new, separately-named definitions, e.g. `kvE_subBracket2`/`kvE_subChain2` — exact names at implementer discretion) whose chain(s) reach ALL THREE interior zones `[zXU, zUW, zWT]` (`kvE_subInteriorZones`), e.g. via a Since+Until pair, or by anchoring the chain at `x` instead of `u` — the redesign choice must be validated by actually driving the correctness proof through it, not accepted on type-check/probe grounds alone (the ORIGINAL kvE_subBracket already failed this way: it type-checked and probed clean but had an undiscovered semantic gap). (2) The soundness direction: sigma.1's full atom layer (order + predicate bits over `[u,w,x,t]` or the redesigned chain's evaluation points) recoverable from the new construction; the interior-fold `<=` direction closable for the now-reachable zXU alongside zUW/zWT; off-fiber falsity handled (may assume access to an outer gate-shaped hypothesis analogous to `kvE_gate`, stated as an explicit hypothesis of this task's standalone lemma rather than wired to the real outer gate). (3) The completeness direction: fold `nf_eval_depth1_fold_iff` (:5187) style extraction of inner witnesses, construction of `IntervalPattern.holds` data (Rabinovich Lemma 5.3, order-theoretic), and the arrangement-disjunct closure — the k1v `:2979` template pattern re-derived at arity 4.

BINDING CONSTRAINTS (carry forward verbatim, self-contained):
- Guards G1-G6 + Corrected Anchor-Cap (source: specs/309_offdiag_two_anchor_fi_chain/plans/07_offdiag-fi-chain-plan.md:230-260): G1 no arity-1 collapse; G2 no projection-based third-free-anchor tower; G3 no trivial-top segment on carrier interval types; G4 witnesses stay bracket witnesses, anchor set fixed at {x,t}; G5 follow Cor 5.4/Prop 3.5 F_i chains step-by-step, cite Rabinovich at every chain step, no simp/omega/aesop shortcut (by omega permitted ONLY for Fin-index typing in signatures); G6 carrier stays the two-anchor bracket characteristic, fixed endpoints, codomain may be witness-growing VVecEA2 but anchor count never exceeds 2.
- Amendment F3: no provider-side pinning — the provider disappears from the joint path; no w = e 1 / x = e 2 residual equation.
- Do-not-edit landed assets byte-identical, INCLUDING task-321 Stage A/B code (kvE_subFoldBits, kvE_subInteriorZones, kvE_subBracket, kvE_subChain, kvE_subBracket_implies_subChain, kvE2_body + gate-fail, bracketEndChar_kvE2 + two_eq, the Stage-B discrimination lemmas), BracketCarrierCorrectVPrior, ExistProviders, all task-310/311 material, the task-320 probes, bracketEndChar_k1v/_sound/_complete and the full k1v proof kit (:2028-2825). EXPLICIT EXCEPTION (authorized only for this task, not a general license): add NEW, separately-named definitions rather than editing kvE_subBracket/kvE_subChain in place; the originals stay byte-identical and unreferenced by the new work. Do NOT edit kvE2_body/bracketEndChar_kvE2 to re-point at the new construction — that re-pointing is task 321's own resumption work via a future /revise 321, out of scope here. This task's lemmas are stated and proved standalone against nf_eval_nf M 1 4, not yet wired into the outer gate.
- Consume-do-not-rebuild list: nf_eval_depth1_fold_iff (:5187), nf0_assemble (NfEFold.lean:180), nf_quant_layer_fold_iff (NfEFold:391), zone semantics kit (zoneHolds/EAtomDom), k1v helper kit (k1v_zoneHolds_cons_iff/k1v_zone_consistent/k1v_bracket_extract/k1v_reconstruct_nf3/k1v_sorted_insert/k1v_sorted_realization/k1v_bracket_construct, :2028-2825), bracketEndChar_k1v_sound/_complete direction templates, BracketFormula.bracket_implies_fChainPred (EANegation:660), existsBounded_right (VecEAClosure:265).
- No EANegation :1090/:1249 (uniform-backward variants) may be consumed.
- No simp/omega/aesop on chain-construction steps; by omega only for Fin-index typing; cite Rabinovich at every chain step per G5.
- No sorry on any live path, including intermediate WIP; keep unfinished work uncommitted until green.
- Literature grounding: ~/Projects/Literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.pdf — Def 3.1 (md:61-74), Lemma 3.2(2) (md:76-79), Prop 3.5 (md:87-94), Def 4.1 (md p.5-6), Prop 4.2 (md:100-101), Lemma 5.1 (md:134-135), Lemma 5.3 (md:137-152), Cor 5.4 (md:154-157). Report specs/321_implement_corrected_k2_carrier_and_close_the_correctness_gate_f4_resolution/reports/01_blocker-research-successor-k.md Section 2 (Q1-Q3) is the binding amended design spec for the successor-parameterized sigma.2 read the construction must stay compatible with.

VERIFICATION: scoped lake build green after each committed lemma; axiom-clean (propext, Classical.choice, Quot.sound) via lean_verify; no forbidden tactics; no sorry; the new construction's chains machine-verified to reach all three interior zones (a concrete probe/lemma per zone, not merely a type-check); the soundness and completeness lemmas both close standalone.

AFTER COMPLETION: resume task 321 via /revise 321 (fold this task's delivered construction + correctness pair into a v4 phase decomposition that re-points Phase 8 and Phases 9-15 at it), then /implement 321.

---

### 323. Review and revise bimodalreference uniform standard
- **Effort**: 8-12 hours
- **Status**: [COMPLETED]
- **Task Type**: typst
- **Topic**: reference-book
- **Dependencies**: Task 315, Task 316, Task 317
- **Research**: [323_review_and_revise_bimodalreference_uniform_standard/reports/01_editorial-review-research.md]
- **Plan**: [323_review_and_revise_bimodalreference_uniform_standard/plans/01_editorial-uniform-standard.md]
- **Summary**: [323_review_and_revise_bimodalreference_uniform_standard/summaries/01_editorial-implementation-summary.md]

**Description**: Full editorial review-and-revise pass over the entire BimodalReference monograph (Theories/Bimodal/typst/: all chapters/*.typ, front matter, notation) to raise it to a UNIFORM, FINISHED-BOOK standard. PRIMARY DIRECTIVE: write as a completed textbook, not a draft-in-progress. Remove the pervasive "honest account / we state honestly / an honest X" refrain and ALL meta-commentary in which the text narrates its own incompleteness or sync status -- a finished book does not explain what it has not yet done. Where prose currently hedges or editorializes about status (e.g. "an honest account of what is and is not proven", sync-class asides, apologetic framing of soundness-without-completeness, remarks about formalization frontiers), rewrite into confident, neutral expository prose. CRITICAL CONSTRAINT -- honesty-removal must NOT become overclaiming: every factual claim stays accurate. Metaphysical modality remains derived soundness-only (completeness is genuinely open); the decidability frontier still cites NO embargoed Lk results; of countermodels 1-12 only #1/#8/#9 are fully interpreted; no nonexistent local Lean theorems may be asserted. The change is TONE and COMPLETENESS-POSTURE, not truth-value. Where content genuinely remains to be written, do not confess it in prose -- instead place a clean "TO BE CONTINUED..." marker at that point in the body text and a typst comment (// TO BE CONTINUED: ...) stating concretely what remains (which theorem, which worked example, which subsection, which citation). Identify the weakest/thinnest sections by comparison against the strongest chapters (e.g. 03-proof-theory.typ ~356 lines, p5-counterfactual.typ ~505 lines) and bring them up to that bar: consistent expository depth, worked examples, cross-references, definitional completeness. PRESERVE byte-identical: the // SLOT-IN: anchors and the EMBARGO header comment in chapters/p3-decidability-frontier.typ (these belong to embargo-gated task 318 and are categorically distinct from TO-BE-CONTINUED gap markers -- do not conflate or remove them). Every backticked token must remain a resolving Lean name. ACCEPTANCE GATES: `typst compile Theories/Bimodal/typst/BimodalReference.typ` exits 0 and `scripts/typst-sync-check.sh` passes all checks. Deliver a per-chapter quality assessment in the task summary (which sections were revised, which gaps were marked TO BE CONTINUED and why).

---

### 322. Review discrete logic completeness retrospective
- **Status**: [COMPLETED]
- **Task Type**: lean4
- **Topic**: completeness
- **Dependencies**: None

**Description**: Review the discrete-logic completeness effort (Kamp theorem formalization retrospective): survey the past tasks (305-321 lineage and earlier completeness work), their reports/plans/verdict records (F1-F4), and the git history to diagnose why establishing completeness for the discrete logic has been so difficult — recurring failure modes, refuted-device churn, where literature fidelity vs formalization shortcuts diverged — and produce actionable recommendations to streamline the remaining attempt

---

### 321. Implement corrected k2 carrier and close the correctness gate f4 resolution
- **Effort**: 10-16 hours
- **Status**: [BLOCKED]
- **Task Type**: lean4
- **Topic**: kamp_theorem_formalization
- **Dependencies**: Task 320
- **Research**:
  - [309_offdiag_two_anchor_fi_chain/reports/06_spawn-analysis-f4.md]
  - [320_derisk_jointpinning_route_for_the_k2_carrier_gate_f4_followup/reports/01_literature-alignment.md]
- **Plan**:
  - [321_implement_corrected_k2_carrier_and_close_the_correctness_gate_f4_resolution/plans/02_corrected-k2-carrier-fi-chain-v2.md]
  - [321_implement_corrected_k2_carrier_and_close_the_correctness_gate_f4_resolution/plans/03_corrected-k2-carrier-gate-v3.md]

**Description**: Depends on task 320's probe result. Task 309 (offdiag_two_anchor_fi_chain) is BLOCKED at Phase 13.35 (finding F4, carrier-shape defect -- see task 320's description for the full crux goal, counterexample, and literature grounding; do not re-derive, consume task 320's design spec directly). This task builds the FULL corrected construction for whichever route task 320's machine-checked probe confirmed viable -- expected b3, the nested F_i-chain/bracket recursion for positive interior subs, which the literature-alignment audit (specs/320_derisk_jointpinning_route_for_the_k2_carrier_gate_f4_followup/reports/01_literature-alignment.md) found to be the literature-faithful mechanism; b1 is a boxed falsifier expected NO-GO and b2 is only a lemma-level assist inside b3, per task 320's revised probe ladder -- exact choice and design spec supplied by task 320's report. Then re-run the k=2 BracketCarrierCorrectVPrior correctness gate to a GO verdict, using the F4 provider-independent Z-counterexample (M=Z, p={0}, r={13}, x=10, t=20, sigma''=char[14,16,11,20], honest char[14,15,10,20] false) as the mandatory adversarial test case (it MUST fail against the new construction).

FRAMING CAVEAT (binding, from the literature-alignment audit): "carrier" here means the Cor 5.4 RECURSIVE FORMULA-CONSTRUCTION realized in carrier form -- inter-anchor positional content carried by the EVALUATION POINT of nested temporal operators (Cor 5.4 md:154-157; Prop 3.5 single-free-variable nesting md:87-94), NEVER by a formula asserted at a single point claiming a relative-position identity between independently-bound variables. Building a third FLAT carrier variant (another kvE''-style body with smarter per-sub literals evaluated at t) is the exact shape refuted by F3/F4 and is OUT OF SCOPE regardless of what any intermediate probe suggests. The same position-by-evaluation-point litmus that gates task 320's design spec gates this task's GO verdict.

Deliverable naming: land the new construction under NEW names taken from task 320's design spec -- prefer names reflecting the nested-chain structure (e.g. a bracketEndChar_nested / fChain-style family) over another primed flat-carrier name, since the deliverable is a recursive construction, not a kvE'' iteration -- additive alongside the landed bracketEndChar_kvE (13.2) and bracketEndChar_kvE' (13.25), following the F1-F4 house style (byte-identical preservation of all prior landed assets; no partial theorem; no sorry on any live path; verdict record either way).

GOAL STATE for the overall chain: this task's GO gate is the prerequisite for task 309's Phase 13.4 (general-k one-step correctness) and Phase 14 (hook rewire discharging KampPrior.lean:351's strategic sorry, target axioms exactly [propext, Classical.choice, Quot.sound]). After this task completes, task 309 resumes via /implement 309 (possibly preceded by /revise 309 for a v8 re-pointing to the new deliverable names, mirroring the v6->v7 re-pointing pattern).

CONSTRAINTS (identical to New Task 0 -- binding, carried from plan v7, do not re-litigate): Guards G1-G6 + Corrected Anchor-Cap (no arity-1 collapse G1; no projection-based VecEA2/third-anchor tower G2; no trivial-top segment G3; w stays a bracket WITNESS, anchor set {x,t} fixed at 2 G4; Cor 5.4/Prop 3.5 F_i chains step-by-step with citations, no simp/omega/aesop shortcuts G5; two-anchor fixed-endpoint bracket, VVecEA2 codomain, never a third anchor G6-as-amended). v7 Amendment F3 STILL BINDING: no provider-side pinning. Do NOT consume EANegation :1090/:1249. Do NOT edit any landed asset (bracketEndChar_kv/kvE_body/bracketEndChar_kvE, bracketEndChar_kvE'/kvE'_body/kvE_pinDisjunct/kvE_exclConj, the F1/F2/F3/F4 verdict records, ExistProviders/BracketCarrierCorrectVPrior, all task-310/311 material) -- purely additive. CONSUME-DO-NOT-REBUILD asset list: same as New Task 0 (E[Sigma]-fold engine, k1v proof kit, nf_eval_unique/nfPred_correct, A_past/A_future, bracketBuildLeft/Right, VVecEA2/bracketFromLists/existsBounded_right, fChainFrom/fChainPred, EANegationClosure forward stack proof-side only, prior_hasAttainedINF/HasAttainedINF). LITERATURE GROUNDING: /home/benjamin/Projects/Literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.md Section 5 (Def 3.1 md:61-74, Lemma 3.2(2) md:76-79, Prop 3.5 md:87-94, Prop 4.2 md:100-101, Lemma 5.1 md:134-135, Lemma 5.3 md:137-152, Cor 5.4 md:154-157) -- cite per G5 at every chain step, especially for the route task 320 selected. Secondary cross-check (from the alignment audit): Gabbay 1994 ch 9 SS9.3 / ch 10 SS10.3 confirm the whole prior-art corpus keeps every proof step single-anchor (position identity by evaluation point) -- if a proposed step needs a two-anchor single-point assertion, that is a design smell to escalate, not to engineer around.

---

### 320. Derisk jointpinning route for the k2 carrier gate f4 followup
- **Effort**: 6-10 hours
- **Status**: [COMPLETED]
- **Task Type**: lean4
- **Topic**: kamp_theorem_formalization
- **Dependencies**: None
- **Research**:
  - [309_offdiag_two_anchor_fi_chain/reports/06_spawn-analysis-f4.md]
  - [320_derisk_jointpinning_route_for_the_k2_carrier_gate_f4_followup/reports/01_literature-alignment.md]
- **Plan**: [320_derisk_jointpinning_route_for_the_k2_carrier_gate_f4_followup/plans/01_derisk-jointpinning-probe.md]

**Description**: Task 309 (offdiag_two_anchor_fi_chain) is BLOCKED at Phase 13.35 with finding F4 (carrier-shape defect, the second-and-LAST gate NO-GO under v7 Amendment F3's one-round uniformization budget). F4 verdict record: Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge.lean, final section after :5533. F3 record (defect lineage) is the section immediately preceding it. Orchestrator handoff: specs/309_offdiag_two_anchor_fi_chain/.orchestrator-handoff.json. Plan v7 BLOCKER block + Amendment F3: specs/309_offdiag_two_anchor_fi_chain/plans/07_offdiag-fi-chain-plan.md lines ~277-460, 620-680, 893-996.

CRUX GOAL (verbatim, provider-independent): after `P.correct 3 sigma M h_UZ h_SZ t`, hypothesis `he : nf_eval_nf M 1 (3+1) (insertEnv e t) sigma` (`insertEnv e t = [e 0, e 1, e 2, t]`, anchor t LAST, u/w/x REBOUND by the provider's own `e : Fin 3 -> M.carrier`) against goal `nf_eval_nf M 1 (3+1) (Fin.cons x_1 (Fin.cons w (Fin.cons x fun _ => t))) sigma`; funext residual `w = e 1`, `x = e 2` UNPINNABLE -- no hypothesis relates provider-chosen e to the honest anchors. Channel (i) `kvE_pinDisjunct` rfl-collapses (probe A) to a positionally-vacuous `charK (nfk_projFresh sigma)` -- the `witnessZone` placement field is discarded, so channel content is a function of the sigma.1-level fresh type alone. Channel (ii) `kvE_exclConj` is negative-subs-only and its honest-safe guard (`hasPos` fiber occupancy) collapses to `Formula.top` when the dishonest positive sub shares the fiber. PROVIDER-INDEPENDENT COUNTEREXAMPLE: M = Z (Prior UZ/SZ trivially), preds p={0}, r={13}, x=10, t=20, dishonest positive sub sigma'' = char[14,16,11,20] (fake anchors sharing only t; on-fiber, zone zXW, fresh type type(14)), honest char[14,15,10,20] marked false -- the k=2 statement is FALSE for bracketEndChar_kvE' under ANY correct depth-1 provider bundle.

GOAL: determine, via machine-checked minimal probes (NOT full carrier surgery), which route can actually carry the discriminating per-sub JOINT content (the sub's inner-witness structure relative to the honest anchor pair (w,x), which rides sigma.2) so a future carrier construction can close the k=2 soundness gap. PROBE ORDER (revised per the literature-alignment audit, reports/01_literature-alignment.md in THIS task's directory: b3 is the literature-faithful mechanism -- Rabinovich carries joint two-anchor content by the NESTED Until EVALUATION POINT, never by a formula asserted at a single point; b1/b2 are formalization-engineering shortcuts with no counterpart in Rabinovich or Gabbay, and F3/F4 already burned two flattening rounds -- so LEAD with b3 and box b1/b2 as bounded falsifiers/micro-checks):
(b3, LEAD -- primary design probe) Probe a NESTED bracket / F_i-chain recursion for positive interior subs, per Rabinovich Cor 5.4 (md:154-157: F_n := alpha_n, F_{i-1} := alpha_{i-1} AND (beta_i Until F_i)) and the negation-closure machinery of Prop 4.2 (md:100-101) / Lemma 5.1 (md:134-135) / Lemma 5.3 (md:137-152, INF splitting via Dedekind completeness) -- instead of flattening an interior positive sub's joint content into a single TL provider literal (P.existF 3 sigma at t), give the sub's own witness u an EXPLICIT two-anchor sub-bracket relative to the CURRENT bracket's real interval decomposition, so the TL evaluation at the actual honest point yields the honest positions directly (the same mechanism that already lets A_past/A_future see (x,t) under G3, generalized one level). Early sub-probe (MEDIUM-confidence claim from the audit to confirm FIRST, before any full build): verify that fChainFrom/fChainPred (EANegation:552/:567) genuinely match the Cor 5.4 chain shape -- the audit relied on the codebase's own labelling for this.
(b1, BOXED fast falsifier -- strictly timeboxed, run in parallel with or before b3 design work, expected NO-GO) Repair channel (i) to ACTUALLY consume `witnessZone` (encode which of the seven consistent zones the pin witness occupies AND the two adjacent segment types relative to (x,w,t), per Def 3.1's real pinning discipline -- point type alpha_j AND BOTH adjacent interval types beta_j, beta_{j+1}, Rabinovich PDF p.4 md:61-74), using the landed non-trivial-segment machinery (A_past/A_future NfZoneFlattenNavigable:335/:386, bracketBuildLeft/Right VecEATranslation, both valid only at fixed-endpoint literals per G3/N4). Audit finding: Def 3.1 pinning pins sigma's OWN witnesses inside sigma's OWN bracket and has NO counterpart for pinning across the provider/e boundary (the actual F4 gap) -- so this probe's value is as an F5-generator (a captured refutation strengthening the defect record), not a live design candidate. Do NOT let it consume the b3 budget.
(b2, CONDITIONAL micro-check only -- run ONLY if the b3 design turns out to need a structural-identity hypothesis at a per-sub obligation site) Check whether `nf_eval_unique` (Theories/Bimodal/.../NormalForm.lean:245) / `nfPred_correct` (NfToVecEA.lean:69) can supply the needed hypothesis -- that sigma IS (by the outer recursion's own construction/selection) the complete type realized by the ACTUAL honest quadruple [u,w,x,t] -- at the site where b3 needs it (the zone/arrangement selection machinery). Audit finding: b2 has NO counterpart in Rabinovich or Gabbay as a standalone mechanism and inherits the same sigma.2-exposure obstruction as b1; it is NOT a route of its own, only a possible lemma-level assist inside b3.

DELIVERABLE: a report (in this new task's own specs/{NNN}_{slug}/reports/ directory) with (i) machine-checked probe results for each route attempted (rfl/exact/type-mismatch states captured, in the F1-F4 house style -- no partial theorem, no sorry landed on any live path), (ii) an explicit GO/NO-GO per route, (iii) for whichever route is GO: a concrete design spec (exact new definition names, signatures, and the demonstrated-closed crux goal) that New Task 2 can implement directly without re-deriving the decision, or (iv) if ALL routes NO-GO in-budget: a new defect record (F5 candidate, F1-F4 house style) with a fresh counterexample proving the joint-pinning content is inexpressible in the current per-sub-literal ExistProviders architecture, plus an explicit recommendation for further escalation (do NOT silently absorb -- this is itself a blocker finding to surface). GO-GATE LITMUS (position-by-evaluation-point, from the literature-alignment audit): a design passes the GO gate ONLY if every inter-anchor positional fact in it is carried by the EVALUATION POINT of a nested temporal operator (Cor 5.4 / Prop 3.5 single-free-variable nesting, md:87-94) and NEVER by a formula asserted at a single evaluation point claiming a relative-position identity between two independently-bound variables -- the exact shape refuted by F3/F4.

CONSTRAINTS (binding, carried from plan v7 -- do not re-litigate): Guards G1-G6 + Corrected Anchor-Cap (v7 plan lines 230-260): no arity-1 collapse (G1); no projection-based VecEA2/third-anchor tower (G2); no trivial-top segment on off-diagonal arms (G3); w stays a bracket WITNESS, anchor set {x,t} fixed at 2 (G4); Cor 5.4/Prop 3.5 F_i chains step-by-step with literature citations at every chain step, no simp/omega/aesop shortcuts (G5); carrier is the two-anchor fixed-endpoint bracket, VVecEA2 witness-growing codomain, never a third anchor (G6-as-amended). v7 Amendment F3 STILL BINDING: do NOT attempt provider-side pinning / pinned-anchor converters (the barred (a)-route -- circular with the outer recursion's single-anchor-only converters, finding F-A). Do NOT consume EANegation :1090/:1249 (uniform-backward sorries) -- needing them is itself a blocker finding to record and escalate, never silent absorption. Do NOT edit any landed asset: bracketEndChar_kv/kvE_body/bracketEndChar_kvE (13.2, F1/F2 exhibits), bracketEndChar_kvE'/kvE'_body/kvE_pinDisjunct/kvE_exclConj (13.25, the F4 exhibit), the F1/F2/F3/F4 verdict records, ExistProviders/BracketCarrierCorrectVPrior (13.1), all task-310/311 material -- any probe code is scratch-only (discarded before commit or landed as a clearly-marked non-consumed verdict addition, per house style). CONSUME-DO-NOT-REBUILD (task 309 asset list, plan v7 lines 142-197): the E[Sigma]-fold engine (nf_quant_layer_fold_iff NfEFold:391, nf_eval_depth1_fold_iff NfMultiAnchorBridge:5187, nf0_split_assemble NfEFold:235); the k1v proof kit (:2028-2825) and direction templates (:2325/:2966); nf_eval_unique (NormalForm:245) / nfPred_correct (NfToVecEA:69); A_past/A_future/_correct (NfZoneFlattenNavigable:335/:386); bracketBuildLeft/Right/_correct (VecEATranslation, fixed-endpoint literals only); VVecEA2/bracketFromLists/existsBounded_right (VecEAFormula:271, NfMultiAnchorBridge:1883, VecEAClosure:265); fChainFrom/fChainPred (EANegation:552/:567); the EANegationClosure forward stack (:401/:492/:646/:720) + neg_orderedPointsExist_is_vbracket (EANegation:347) -- PROOF-SIDE ONLY; prior_hasAttainedINF (PriorINF:224) + HasAttainedINF (PriorINF:202). LITERATURE GROUNDING (cite per G5 at every step): /home/benjamin/Projects/Literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.md Section 5 -- Def 3.1 (md:61-74), Lemma 3.2(2) (md:76-79), Prop 4.2 (md:100-101), Lemma 5.1 (md:134-135), Lemma 5.3 (md:137-152), Cor 5.4 (md:154-157).

---

### 319. Restructure bimodalreference clean textbook
- **Effort**: 6-8 hours
- **Status**: [COMPLETED]
- **Task Type**: typst
- **Topic**: reference-book
- **Dependencies**: Task 313
- **Research**: [319_restructure_bimodalreference_clean_textbook/reports/01_restructure-clean-textbook-research.md]
- **Plan**: [319_restructure_bimodalreference_clean_textbook/plans/01_restructure-clean-textbook-plan.md]
- **Summary**: [319_restructure_bimodalreference_clean_textbook/summaries/01_restructure-clean-textbook-summary.md]

**Description**: Turn the BimodalReference book (Theories/Bimodal/typst/) from the task-313 living-monograph-with-sync-scaffolding into a clean, direct textbook presentation at a rigorous formal level, with clear but concise explanations where essential — a natural unified whole with a clear narrative arc. Keep whatever can be kept (Part II and Part IV prose is essentially puzzle-free). Four workstreams:

(1) REMOVE the status-symbol/sync-class machinery from the compiled book (maintenance burden, distracting): every top-of-chapter #sync-banner(...) call; the Reading-Guide/Sync-Class Legend box (BimodalReference.typ:145-161) and the symbol mentions in the abstract (:141) and title-page Sources list (:111-118); the dominant-class labels passed to #part-divider (template.typ:236-253); the 'How to Read This Book If You Are an AI' symbol protocol (00-introduction.typ:151-160); the Closing Status Table with Roadmap column (p2-decidability-practice.typ:67-75) and the status table in 04-metalogic.typ; the #planned-chapter-notice stub boxes (drop the stub includes or replace with a single plain sentence). Update scripts/typst-sync-check.sh accordingly: KEEP check 1 (backticked Lean names must resolve — this is valuable and cheap) and check 4 (generated-count freshness) if counts are kept; REMOVE checks 2-3 (banner presence, legend discipline). Generated counts (#axiom-count, #rule-count etc. from generated/status.typ via scripts/typst-status-counts.sh) MAY be kept since they are script-generated, but remove sorry-count reporting from reader-facing text. Retire SYNC-MAP.md's PDF-governing role to a repo-side dev doc (update its header to say so).

(2) REAL CITATIONS to the three relevant papers. bibliography.bib currently has entries but ZERO @-citations in any .typ file, so the References section renders empty. Add/complete entries with links and wire @-citations into the prose where the papers are drawn on: the possible-worlds draft as forthcoming in JPL with URL https://benbrastmckie.com/wp-content/uploads/2026/07/possible_worlds.pdf; the published papers https://link.springer.com/article/10.1007/s10992-025-09793-8 (Counterfactual Worlds, JPL) and https://link.springer.com/article/10.1007/s10992-021-09612-w (Identity and Aboutness, JPL) — verify exact titles/years/DOIs against the Springer pages. Convert plain-text author-year mentions (Vlach 1973, Cresswell 1990, Kamp, Burgess, Xu, Reynolds, Doets) into real citations, adding bib entries as needed and clearing verify-before-print notes where confirmed. Embargo unchanged: no Lk entry (bibliography.bib:8-10).

(3) RESTRUCTURE to the new narrative arc. Rewrite 00-introduction.typ as a brief introduction that motivates the project directly (unifying tense and modality in a verified system; no philosophical puzzles, no AI-practitioner-first framing) and outlines the structure: the book begins with the bimodal system, then applications, then adds the counterfactual logic, and concludes with the constitutive logic. Concretely: Part on the bimodal system = current Part II chapters plus the honest LTL-to-TM positioning and Vlach/BL-star material (p3-ltl-to-tm.typ, p3-vlach-blstar.typ) folded in as direct formal chapters, and p3-decidability-frontier.typ kept as a concise formal chapter PRESERVING the // SLOT-IN: anchors (needed by task 318); Part on applications = current Part IV (proof automation, dataset pipeline, dual verification) with the AI-training motivation kept brief; Part on counterfactual logic (p5-counterfactual.typ); concluding Part on constitutive logic (p5-constitutive.typ) — NOTE this inverts the current Part V chapter order, do not silently keep constitutive-then-counterfactual. DROP the philosophical-puzzle chapters from the book plan: p1-why-worlds.typ (eternalism critique, Prior chess-loop, Peircean/Ockhamist, Montague, Kaplan) and p3-open-future.typ (sea-battle, open future) — present their essential technical content (perpetuity principles, Determined/Deterministic, actuality operators) directly where formally relevant, with citations to the papers instead of puzzle-driven exposition.

(4) REVISE follow-up tasks 314-318 in specs/state.json (descriptions, and dependencies to include this task) to align with the new direction, then regenerate TODO.md: 314 (Part I motivation chapter) shrinks to whatever brief motivation the introduction still needs or is abandoned/absorbed — decide and record; 315 drops p3-open-future as a puzzle chapter and drops all sync-banner/sync-class-legend constraints (backtick-resolution constraint stays); 316 (JSONL appendix) re-anchors its pointer since 'How to Read This Book If You Are an AI' is gone — decide the replacement location; 317 must match the new counterfactual-then-constitutive order and drop banner constraints; 318 unchanged except banner constraints removed (SLOT-IN anchors preserved by workstream 3).

Verify: typst compile green (page count will change), revised scripts/typst-sync-check.sh green, References section renders non-empty with the three papers.

---

### 318. Slot lk results into bimodalreference decidability
- **Effort**: 3-4 hours
- **Status**: [NOT STARTED]
- **Task Type**: typst
- **Topic**: reference-book
- **Dependencies**: Task 313, Task 319

**Description**: GATED ON EXTERNAL EVENT: execute only after the Lk paper (anonymous TACAS 2027 double-blind submission at ~/Philosophy/Papers/PossibleWorlds/Lk/) is accepted and the embargo (user decision 2 on task 313) lifts. Insert the Lk-specific content into chapters/p3-decidability-frontier.typ at the prepared // SLOT-IN: anchors, without renumbering chapters or sections: the BL-star ladder table (Lk 07-related-work.tex 32-104, tab:bl-star-ladder), the complexity map (L1 = PTL x S5 EXPSPACE-complete; L_k undecidable for k >= 2; alternation-freedom does not restore decidability, Theorem F-B; forall-AF-L_k PSPACE-complete flagship, Theorem F-A), and the hardware case study (constant-time as forall-forall, reset convergence, SVA/Logos-Hardware bridge, Lk 06-case-study.tex). Add the Lk bibliography entry with its final published citation. State openly, in plain prose, which results are established in print and which are new; note that none are Lean-formalized (Lk 08-conclusion.tex names Lean 4 formalization as future work). Include the honest trace-vs-task-semantics bridging caveats (Lk is discrete/future-only trace sets; TM is group-time/two-sided task frames). Sources: teammate A rows 15-18.

---

### 317. Write bimodalreference part v logos chapters const
- **Effort**: 6-8 hours
- **Status**: [COMPLETED]
- **Task Type**: typst
- **Topic**: reference-book
- **Dependencies**: Task 313, Task 319
- **Research**: [317_write_bimodalreference_part_v_logos_chapters_const/reports/01_counterfactual-constitutive-chapters.md]
- **Plan**: [317_write_bimodalreference_part_v_logos_chapters_const/plans/01_counterfactual-constitutive-chapters.md]
- **Summary**: [317_write_bimodalreference_part_v_logos_chapters_const/summaries/01_counterfactual-constitutive-chapters-summary.md]

**Description**: Write the counterfactual and constitutive chapters of BimodalReference (Parts III and IV; book order is counterfactual THEN constitutive -- p5-counterfactual.typ is Part III, p5-constitutive.typ concludes the book as Part IV), replacing the current one-sentence placeholders, as full adapted chapters -- BimodalReference OWNS this exposition, LogosManual links here (user decision 3). (1) chapters/p5-counterfactual.typ (Part III) -- adapted from counterfactual_worlds.tex sections 4-5 + Logos 03-dynamics.typ/07-proof-theory.typ: bilateral propositions, exact semantics, boxright clause in both imposition and mereological form, CL/CML/CTL axiom ladder via principle lists, HEADLINE: box A := top boxright A with S5 derived (metaphysical modality derived, soundness only -- completeness open, state honestly), perpetuity re-derivation, countermodels 1-12 as example environments with ModelChecker-reproducibility note, Vlach regimentation of tensed counterfactuals reusing Part I's store/recall operators; cite @brastmckie2025counterfactualworlds. (2) chapters/p5-constitutive.typ (Part IV) -- adapted from Logos manual 02-constitutive.typ (1623 lines) + counterfactual_worlds.tex sections 2.2-3.2: state lattice with parthood, task relation over all states, possible/world states DEFINED not primitive, imposition defined, Fine's constraints as theorems, worlds as maximal possible evolutions; closing comparison figure: the bimodal frame of Part I as the world-state shadow of this structure; cite @brastmckie2021identity for ground/essence. Follow teammate B's 9-item dependency-ordered staging list and resolve the 4 documented paper-vs-Logos divergences (duration-parameterized task relation; possible-state definition -- Lean is ground truth; stay propositional, point to LogosManual for FOL; state CTL over the book's Until/Since basis). Carry the extensional-antecedent restriction into the grammar (do not silently import ModelChecker's unrestricted extension). Plain textbook prose -- no sync-class banners or status symbols; state openly what is published, what is adapted, and what is not formalized. Add notation/constitutive-notation.typ importing the needed Logos state-space symbols; re-verify B's staging list against counterfactual_worlds.tex at drafting time. typst compile and scripts/typst-sync-check.sh must pass. Sources: teammate B findings F1/F2/F5 (specs/313_design_full_extent_bimodalreference_book/reports/01_teammate-b-findings.md).

---

### 316. Generate machinereadable jsonl appendix for bimoda
- **Effort**: 3-4 hours
- **Status**: [COMPLETED]
- **Task Type**: lean4
- **Topic**: reference-book
- **Dependencies**: Task 313, Task 319
- **Research**: [316_generate_machinereadable_jsonl_appendix_for_bimoda/reports/01_machinereadable-jsonl-appendix.md]
- **Plan**: [316_generate_machinereadable_jsonl_appendix_for_bimoda/plans/01_machine-appendix-jsonl.md]
- **Summary**: [316_generate_machinereadable_jsonl_appendix_for_bimoda/summaries/01_machine-appendix-jsonl-summary.md]

**Description**: Implement the machine-readable appendix (teammate D recommendation R5.1, prioritized by the AI-practitioner audience decision): export the 42-constructor axiom table, 7 inference rules, and derived-operator definitions from Lean as JSONL matching the Automation/DatasetExporter.lean schema, generated by a lake exe or script and included in the BimodalReference build as an appendix (with a human-readable rendering plus a pointer to the raw JSONL artifact). Wire the dataset pipeline chapter (chapters/p4-dataset-pipeline.typ) to point at the shipped artifact (task 319 re-anchor: the former 'How to Read This Book If You Are an AI' introduction section was removed with the sync-class machinery). The appendix generation must be re-runnable and commit-stamped like scripts/typst-status-counts.sh output; never hand-copy the exported content. Verify: build produces the JSONL, typst compile green, sync-check green.

---

### 315. Write bimodalreference part iii expressivepower ch
- **Effort**: 6-8 hours
- **Status**: [COMPLETED]
- **Task Type**: typst
- **Topic**: reference-book
- **Dependencies**: Task 313, Task 319
- **Research**: [315_write_bimodalreference_part_iii_expressivepower_ch/reports/01_positioning-chapters-research.md]
- **Plan**: [315_write_bimodalreference_part_iii_expressivepower_ch/plans/01_positioning-chapters-plan.md]
- **Summary**: [315_write_bimodalreference_part_iii_expressivepower_ch/summaries/01_positioning-chapters-summary.md]

**Description**: Write the three positioning chapters of BimodalReference Part I (The Bimodal System), replacing the current one-sentence placeholders (they sit at the end of Part I, after 05-theorems.typ): (1) chapters/p3-ltl-to-tm.typ -- honest positioning of TM among temporal-modal logics (Until/Since over linear orders fused with S5 + interaction/uniformity; trace vs task semantics; conservativity as the bridge; NEVER describe TM as vanilla LTL+S5 -- that framing is extension-roadmap only); (2) chapters/p3-vlach-blstar.typ -- Vlach store/recall operators and BL-star (possible_worlds.tex 1246-1256), hybrid-logic prior-art framing (@vlach1973nowandthen, @cresswell1990entities, @blackburn2000hybrid -- verify citations before print), Kamp theorem correctly scoped (strict Until/Since, Dedekind-complete flows, @kamp1971formalproperties) and the Metalogic/WeakCanonical/Kamp/ formalization frontier status stated honestly in plain prose; (3) chapters/p3-decidability-frontier.typ -- the decidability frontier written at a level citing NO Lk-specific results (EMBARGO, user decision 2: no BL-star-ladder table lifted from Lk, no L_k complexity theorems attributed; general ceiling-and-descent narrative from published sources and general prior art only), PRESERVING the three // SLOT-IN: anchors and the EMBARGO header comment verbatim for post-acceptance insertion (task 318). The former p3-open-future.typ puzzle chapter is dropped (task 319): its technical content (Determined/Deterministic, actuality operators) lives as cited remarks in the semantics chapter. Plain textbook prose throughout -- no sync-class banners, no status symbols. Every backticked Lean name must resolve: typst compile and scripts/typst-sync-check.sh (checks 1+4 structure: name resolution + count freshness) must pass. Sources per teammate A rows 6, 8-10, 15-18 and teammate B F3 prior art.

---

### 314. Write bimodalreference part i motivation chapter w
- **Effort**: 4-6 hours
- **Status**: [ABANDONED]
- **Task Type**: typst
- **Topic**: reference-book
- **Dependencies**: Task 313, Task 319

**Description**: Decision (task 319): the rewritten introduction carries the book's motivation; chapter p1-why-worlds.typ deleted; task absorbed into 319. The philosophical puzzle material (eternalism critique, Prior's what/when conflation, Peircean/Ockhamist failure, Montague triviality, Kaplan/abundance dilemma) is covered by a citing pointer to possible_worlds.tex (@brastmckie2026possibleworlds) in the introduction rather than a dedicated chapter.

---

### 313. Design full extent bimodalreference book
- **Status**: [COMPLETED]
- **Task Type**: typst
- **Topic**: reference-book
- **Dependencies**: None
- **Research**: [313_design_full_extent_bimodalreference_book/reports/01_team-research.md]
- **Plan**: [313_design_full_extent_bimodalreference_book/plans/01_full-book-design.md]
- **Summary**: [313_design_full_extent_bimodalreference_book/summaries/01_full-book-design-summary.md]

**Description**: Design the full extent of the BimodalReference book by examining what /home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex, the BimodalLogic Lean codebase, and /home/benjamin/Philosophy/Papers/PossibleWorlds/Lk/main.tex still offer that is relevant and worth including in Theories/Bimodal/typst/BimodalReference.typ, toward a more complete, well-motivated, and well-explained account of the bimodal system and its applications. The account should: (1) acknowledge the sizable remaining project of carving off decidable fragments for fully automated reasoning, contrasted with training AI systems to reason proof-theoretically and to solve constraint systems, both deterministically checkable and fast; (2) present the system as closest to vanilla LTL extended first with S5 modal operators and then with Vlach operators for cross-referencing traces and times; (3) frame this as an early milestone in combined expressive power from unifying logics, with the full Logos aiming to vastly expand this; (4) plan a next chapter adding constitutive structure to provide the counterfactual semantics and logic of /home/benjamin/Philosophy/Papers/Counterfactuals/JPL/counterfactual_worlds.tex and /home/benjamin/Projects/Logos/Theory/typst/manual/LogosManual.typ, carving off the next dimension of logical structure to yield a tensed counterfactual logic from which metaphysical modality can be derived. Deliverable: an initial design report mapping candidate content from each source to a proposed full book structure, to base further research on.

---

### 312. Revise bimodalreference typst paper lean
- **Status**: [COMPLETED]
- **Task Type**: typst
- **Topic**: publication-quality
- **Dependencies**: None
- **Research**: [312_revise_bimodalreference_typst_paper_lean/reports/01_team-research.md]
- **Plan**: [312_revise_bimodalreference_typst_paper_lean/plans/01_revise-typst-reference.md]
- **Summary**: [312_revise_bimodalreference_typst_paper_lean/summaries/01_revise-typst-reference-summary.md]

**Description**: Systematically revise Theories/Bimodal/typst/BimodalReference.typ to align with the completed paper /home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex, prioritizing accuracy with the substantially-changed Lean 4 source code as the first priority

---

### 311. Close k1 bracket gate efold
- **Effort**: high
- **Status**: [COMPLETED]
- **Task Type**: lean4
- **Topic**: kamp_theorem_formalization
- **Dependencies**: Task 310
- **Research**: [311_close_k1_bracket_gate_efold/reports/01_rabinovich-faithfulness-audit.md]
- **Summary**:
  - [311_close_k1_bracket_gate_efold/summaries/01_k1-gate-closure-summary.md]
  - [311_close_k1_bracket_gate_efold/summaries/02_k1-gate-closure-v3-summary.md]
- **Plan**: [311_close_k1_bracket_gate_efold/plans/03_k1-gate-closure-plan-v3.md]

**Description**: Using the fixed-arity monadic E[Sigma]-fold encoding delivered by the prerequisite task (Define NormalForm E[Sigma]-fold encoding), redo task 309's Phase 10 (R2) k=1 decision-gate probe UNDER THE NEW ENCODING and close it GO. This is the encoding-level task's acceptance probe (task 309 plan v3 Phase 10 NO-GO handoff, commit 8fd4340b1): the exact goal that failed under the OLD nf_eval_nf-only encoding must close under the new fold.

BLOCKER GOAL SHAPE THIS TASK MUST CLOSE (task 309, NfMultiAnchorBridge.lean:1546-1552, `BracketCarrierCorrect` at k=1):
  (carrier qnf).holds M atomMap x t <-> exists w : M.carrier, nf_eval_nf M 1 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf
for `carrier : BracketEndCharCarrier sig 1 := NormalForm sig 1 3 -> VecEA2 1` (NfMultiAnchorBridge.lean:1536), where under the OLD encoding the residual after atom-layer discharge was the irreducible arity-4 goal
  forall sub_nf : NormalForm sig 0 4, (exists x_1, nf_eval_nf M 0 4 (Fin.cons x_1 (Fin.cons w (Fin.cons x fun _ => t))) sub_nf) <-> qnf.2 sub_nf = true
(env [x_1,w,x,t], arity 4, coupling bracket witness w to BOTH fixed endpoints x,t). This task must rebuild the quant-layer discharge of `qnf.2` using the prerequisite task's fold encoding (folding the depth-0 quant layer into a monadic E[Sigma]-atom evaluated at [w,x,t], not at an arity-4 env) so the residual never arises. Use the prerequisite task's documented fold definition name(s) and bridge lemma signature(s) (see its completion summary) -- do not redefine the fold independently.

RABINOVICH GROUNDING (report 03, reports/03_rabinovich-faithful-path-research.md): Def 4.1 (PDF p.5, E[Sigma] monadic-atom fold), Lemma 3.2(2) (PDF p.4, <=2 free variables as a standing invariant of the carrier TYPE), Prop 3.5 (PDF p.5, exists x_i -> Until/Since bracket witness at FIXED endpoints z_0,z_1, never an interior witness).

FALSIFIED ROUTES (do not resurrect): endChar carrier (NfMultiAnchorBridge.lean:1029, arity-1 navigated point characteristic, provably FALSE in free-anchor form per :1058-1069); VecEA2 bracket carrier at the OLD nf_eval_nf encoding (NfMultiAnchorBridge.lean:1586-1618, this task's direct predecessor blocker) -- NOTE: G6's carrier SHAPE (BracketEndCharCarrier / VecEA2 1 / fixed endpoints {x,t} / w as bracket witness) stays CORRECT after the prerequisite task's re-encoding lands; do not change the carrier shape, only the quant-layer discharge mechanism underneath it.

GUARDS (carry verbatim, from plans/03_offdiag-fi-chain-plan.md Postmortem Constraints):
- G1 -- No arity-1 collapse of the off-diagonal. (Refuted: report 02 SS1; NfDepth0Generalized:1691-1719.)
- G2 -- No projection-based VecEA2 / third-free-anchor tower. (Refuted: specs/305 report 40; R2.)
- G3 -- No trivial-top segment on the off-diagonal arms. A closed pastEnd under a trivial segment is unsatisfiable; the (x,t) coupling MUST ride the non-trivial Rabinovich beta_i segment (a real interval type, not top/trivial).
- G4 -- w stays a bracket witness. Env arity never grows past {w,x,t}=3 -> {x,t}=2; anchor set {x,t}; Rabinovich <=2 cap.
- G5 -- Follow Cor 5.4 / Prop 3.5 F_i chains step-by-step; no simp/omega/aesop shortcut of a chain step (literature-fidelity policy). Cite Rabinovich PDF p.4-5 at every chain step.
- G6 -- The recursion carrier MUST be the two-anchor bracket characteristic with FIXED endpoints z_0,z_1 (Prop 3.5, PDF p.5): NormalForm sig k 3 -> VecEA2 1 (two endpoint TemporalPreds + one interval TemporalPred), {x,t} FIXED, w a bracket WITNESS. It MUST NOT be an arity-1 navigated point characteristic nor an interior-existential-witness evaluation. CRITICAL DISTINCTION from G2: G2 bars a THIRD free anchor; G6's VecEA2 is a fixed-endpoint bracket, not a projection tower -- anchors stay {x,t} (2, fixed).
- Corrected Anchor-Cap Statement: the hook-discharge path MUST keep the anchor set at {x,t} (<=2) by the bracket-witness-collapse mechanism, NOT by nf_char3_deeper_split (NfMultiAnchorBridge.lean:625-642, which grows arity 3->4 and anchors {x,t}->{y,x,t} -- forbidden tower).

CONSUME, DO NOT REBUILD (all sorry-free, task 309 assets, PLUS the prerequisite task's new fold definition/bridge lemma(s)): nf_3var_bracket_xyt/_correct (VecEADecomp.lean:233/244); char_k1/_correct (KampPrior.lean:307/310); bracketBuildLeft/_correct (VecEATranslation.lean:273/503) and bracketBuildRight/_correct (VecEATranslation.lean:50/234); BracketEndCharCarrier / BracketCarrierCorrect / bracketEndChar_k0 / bracketEndChar_k0_correct (NfMultiAnchorBridge.lean:1536/1546/1557/1571, task 309 Phase 9); nf_zone_flatten_navigable(_brick)/_correct (NfMultiAnchorBridge.lean:689/709); A_diag/_correct (NfMultiAnchorBridge.lean:763/808); nf_zone_exists_trichotomy_k1 (NfZoneFlattenNavigable.lean:188); Phases 1-5 assets (A_past/A_future + _correct, NfZoneFlattenNavigable.lean:335/386; nf_char2_atom_offdiag_{origin,endpoint,correct}, NfMultiAnchorBridge.lean:364/375/391; nf_char3_endpoint_tl/_correct, NfMultiAnchorBridge.lean:891/907; nf_char2_past_formula/_correct, NfMultiAnchorBridge.lean:992/1015; nf_char2_future_formula/_correct, NfMultiAnchorBridge.lean:1185).

GOAL STATE: the k=1 BracketCarrierCorrect instance (NfMultiAnchorBridge.lean:1546-1552 restricted to k=1) proved sorry-free using the new fold encoding, off the live path until wired; lake build GREEN; axioms exactly [propext, Classical.choice, Quot.sound]; explicit GO verdict recorded (mirroring the Phase 10 handoff format: 'R2 = GO', with evidence that the fold closed via the prerequisite task's lemma with no arity-4 residual and no navigated arity-3 characteristic) so task 309 can resume via /revise 309 (plan v4) then /implement 309 with the fold-backed carrier. Estimated ~150-300 lines (hard-mode; H8 sizing).

AFTER COMPLETION: once both spawned tasks land, task 309 remains [BLOCKED] until /revise 309 folds the new encoding + GO verdict into a plan v4; live sorries stay at 2 (:354 remains task 305 scope) until 309's own future R3/R4-equivalent phases close :351.

---

### 310. Normalform efold encoding
- **Effort**: high
- **Status**: [COMPLETED]
- **Task Type**: lean4
- **Topic**: kamp_theorem_formalization
- **Dependencies**: None

**Description**: Define a new fixed-arity monadic E[Sigma]-fold evaluation for NormalForm depth-recursion (Rabinovich 2014 Def 4.1, PDF p.5), as a parallel/alternative encoding alongside `nf_eval_nf` (Theories/Bimodal/Metalogic/WeakCanonical/NormalForm.lean:198-207), which currently grows environment arity n -> n+1 at every depth descent:

  nf_eval_nf (k+1) n env <atom_assignment, quant_assignment> :=
    (atom layer) AND
    (forall sub_nf : NormalForm sig k (n+1), (exists x, nf_eval_nf M k (n+1) (Fin.cons x env) sub_nf) <-> quant_assignment sub_nf)

BLOCKER THIS TASK RESOLVES (task 309, R2 NO-GO, commit 8fd4340b1, session sess_1783359214_93fd70): at k=1, arity 3 ([w,x,t]), the quant layer of `nf_eval_nf M 1 3 [w,x,t] qnf` unfolds to
  forall sub_nf : NormalForm sig 0 4, (exists x_1, nf_eval_nf M 0 4 [x_1,w,x,t] sub_nf) <-> qnf.2 sub_nf = true
-- an irreducible arity-4 residual coupling the bracket witness w to BOTH fixed endpoints x,t (plus a fresh existential x_1). No monadic VecEA2 component (each reading a single point) can supply it. This is the SAME wall hit independently by two routes: task-309 plan-v2 Phase 8 (endChar arity-4->3 re-bounding) and plan-v3 R2 (VecEA2 bracket carrier, NfMultiAnchorBridge.lean:1586-1618).

RABINOVICH GROUNDING (report 03, specs/309_offdiag_two_anchor_fi_chain/reports/03_rabinovich-faithful-path-research.md, full-PDF read of ~/Projects/Literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.pdf):
- Def 3.1 (PDF p.4): alpha_j/beta_j endpoint/interval types are quantifier-free, ONE-variable.
- Lemma 3.2(2) (PDF p.4): every existential-universal formula is equivalent to a conjunction of such formulas with AT MOST TWO free variables -- a standing invariant, not a hand-checked guard.
- Prop 3.5 (PDF p.5): exists x_i collapses into an Until/Since BRACKET WITNESS; the two anchors z_0,z_1 are FIXED bracket endpoints, never an interior existential witness.
- Def 4.1 (PDF p.5): the E[Sigma] expansion -- 'the set of unary predicate names Sigma union {A | A is a TL(Until,Since)-formula over Sigma}' -- folds each ALREADY-PROCESSED quantifier depth into a MONADIC (arity-1) atom before the next level is decomposed. Rabinovich never grows arity with depth; depth lives in Until/Since NESTING over quantifier-free atoms, not in sub-evaluation arity.

FALSIFIED ROUTES (do not resurrect; both hit the identical residual under the OLD nf_eval_nf encoding):
- endChar carrier (plan-v2 Phase 8): `EndCharCarrier := NormalForm sig k 3 -> TemporalPred` (NfMultiAnchorBridge.lean:1029) -- arity-1 navigated point characteristic; provably FALSE in free-anchor form (endChar0_correct deviation note, NfMultiAnchorBridge.lean:1058-1069): a closed navigated-w TemporalPred cannot read anchor positions.
- VecEA2 bracket carrier at the OLD encoding (plan-v3 R2, this task's direct blocker): `BracketEndCharCarrier := NormalForm sig k 3 -> VecEA2 1` (NfMultiAnchorBridge.lean:1536), `BracketCarrierCorrect` (NfMultiAnchorBridge.lean:1546-1552) -- G6's carrier SHAPE (two-anchor bracket, fixed endpoints, w as bracket witness) stays CORRECT after this task's re-encoding; only the underlying nf_eval_nf recursion it must bridge to needs the E[Sigma]-fold. Do not conclude G6 itself was wrong; do not change the carrier shape.

GUARDS (carry verbatim into every dispatch, from plans/03_offdiag-fi-chain-plan.md Postmortem Constraints):
- G1 -- No arity-1 collapse of the off-diagonal. (Refuted: report 02 SS1; NfDepth0Generalized:1691-1719.)
- G2 -- No projection-based VecEA2 / third-free-anchor tower. (Refuted: specs/305 report 40; R2.)
- G3 -- No trivial-top segment on the off-diagonal arms. A closed pastEnd under a trivial segment is unsatisfiable; the (x,t) coupling MUST ride the non-trivial Rabinovich beta_i segment (a real interval type, not top/trivial).
- G4 -- w stays a bracket witness. Env arity never grows past {w,x,t}=3 -> {x,t}=2; anchor set {x,t}; Rabinovich <=2 cap.
- G5 -- Follow Cor 5.4 / Prop 3.5 F_i chains step-by-step; no simp/omega/aesop shortcut of a chain step (literature-fidelity policy). Cite Rabinovich PDF p.4-5 at every chain step.
- G6 -- The recursion carrier MUST be the two-anchor bracket characteristic with FIXED endpoints z_0,z_1 (Prop 3.5, PDF p.5): NormalForm sig k 3 -> VecEA2 1 (two endpoint TemporalPreds + one interval TemporalPred), {x,t} FIXED, w a bracket WITNESS. It MUST NOT be an arity-1 navigated point characteristic nor an interior-existential-witness evaluation. CRITICAL DISTINCTION from G2: G2 bars a THIRD free anchor; G6's VecEA2 is a fixed-endpoint bracket, not a projection tower -- anchors stay {x,t} (2, fixed).
- Corrected Anchor-Cap Statement: the hook-discharge path MUST keep the anchor set at {x,t} (<=2) by the bracket-witness-collapse mechanism, NOT by nf_char3_deeper_split (NfMultiAnchorBridge.lean:625-642, which grows arity 3->4 and anchors {x,t}->{y,x,t} -- forbidden tower).

CONSUME, DO NOT REBUILD (all sorry-free, task 309 assets): nf_3var_bracket_xyt/_correct (VecEADecomp.lean:233/244, the depth-0 base collapse); char_k1/_correct (KampPrior.lean:307/310, the depth-k arity-1 E[Sigma]-atom); bracketBuildLeft/_correct (VecEATranslation.lean:273/503) and bracketBuildRight/_correct (VecEATranslation.lean:50/234); BracketEndCharCarrier / BracketCarrierCorrect / bracketEndChar_k0 / bracketEndChar_k0_correct (NfMultiAnchorBridge.lean:1536/1546/1557/1571, task 309 Phase 9 -- the carrier SHAPE to preserve, not rebuild); nf_zone_flatten_navigable(_brick)/_correct (NfMultiAnchorBridge.lean:689/709); A_diag/_correct (NfMultiAnchorBridge.lean:763/808); nf_zone_exists_trichotomy_k1 (NfZoneFlattenNavigable.lean:188); Phases 1-5 assets (A_past/A_future segment-carrying + _correct, NfZoneFlattenNavigable.lean:335/386; nf_char2_atom_offdiag_{origin,endpoint,correct}, NfMultiAnchorBridge.lean:364/375/391; nf_char3_endpoint_tl/_correct, NfMultiAnchorBridge.lean:891/907; nf_char2_past_formula/_correct, NfMultiAnchorBridge.lean:992/1015; nf_char2_future_formula/_correct, NfMultiAnchorBridge.lean:1185).

SCOPE OF THIS TASK (deliberately narrow -- NOT a project-wide re-encoding of NormalForm.lean; report 03 SS3 'Adjustment to the NormalForm encoding' explicitly rejects a project-scale rewrite): define a NEW fixed-arity monadic-fold evaluation function (suggested name `nf_eval_efold` or similar -- implementer's choice, document the name in the summary) ALONGSIDE `nf_eval_nf`, whose quant-layer clause folds the processed depth into a monadic E[Sigma]-atom (a TemporalPred/char_k1-shaped object) evaluated at the SAME arity-n env, rather than recursing into an arity-(n+1) sub-evaluation. Prove the fold's depth-0 case coincides with nf_eval_nf's depth-0 atom-assignment case (the trivial base), and prove a bridge/equivalence lemma relating one step of the fold's quant-layer recursion to one step of nf_eval_nf's quant-layer recursion FOR THE ARITY-3 TWO-ANCHOR SHAPE task 309 needs (env [w,x,t] with fixed x,t) -- i.e. establish that folding nf_eval_nf's depth-(k+1) quant layer via a monadic E[Sigma]-atom (rather than growing arity to n+1) is propositionally equivalent to the existing nf_eval_nf semantics for that shape. This is the load-bearing new object; do NOT attempt to replace nf_eval_nf's global definition or migrate unrelated consumers.

GOAL STATE: lake build GREEN (scoped: the new file/module + its dependents); the new fold definition + bridge/equivalence lemma(s) sorry-free; axioms exactly [propext, Classical.choice, Quot.sound] on every new lemma; the new encoding sits OFF the live import path until the follow-up task consumes it to re-close the k=1 gate. Estimated ~150-280 lines (hard-mode phase sizing, H8: one agent run per phase; split into sub-phases if it overruns). Document the exact fold definition name(s) and bridge lemma signature(s) in the completion summary -- the follow-up task depends on them.

---

### 309. Offdiag two anchor fi chain
- **Effort**: high
- **Status**: [BLOCKED]
- **Task Type**: lean4
- **Topic**: kamp_theorem_formalization
- **Dependencies**: Task 310, Task 311, Task 320, Task 321
- **Research**: [307_kamp_cor54_bound_anchor_zone_converter/reports/03_endpoint-hook-blocker-audit.md]
- **Plan**: [309_offdiag_two_anchor_fi_chain/plans/05_offdiag-fi-chain-plan.md]

**Description**: Build the off-diagonal two-anchor navigated characteristic (Rabinovich Cor 5.4 non-trivial-segment F_i chain) for the KampPrior.lean:350 past/future arms (prerequisite spawned from task 307 Phase 7 blocker audit, reports/03_endpoint-hook-blocker-audit.md).

Off the live import path, sorry-free, axioms exactly [propext, Classical.choice, Quot.sound]. Deliverables (see task 307 report 03 SS4): (1) segment-carrying A_past/A_future + _correct in Kamp/NfZoneFlattenNavigable.lean (drop the forced `trivial top`; via bracketBuildLeft/Right_correct directly, ~80-120 lines); (2) nf_char2_past_formula / nf_char2_future_formula : NormalForm sig (k+1) 2 -> Formula with `temporal_truth M atomMap t (nf_char2_past_formula ... sub_nf) <-> exists x, x < t AND nf_eval_nf M (k+1) 2 (Fin.cons x (fun _=>t)) sub_nf` (future dual with t < x) — the F_i chain: outer NON-trivial-segment bracket from t to x, endpoint at x = the arity-2 characteristic of sub_nf at [x,t], quant layer (per qnf : NormalForm sig k 3) flattened via nf_zone_flatten_navigable_brick, residual arity-3 zones discharged by the depth-k IH (exist_tl_fn_k / nf_nvar_exist_all_depths); ~300-500 lines, recursion on k — the load-bearing new object; (3) rewire KampPrior.lean:350 to A := nf_char2_past_formula ... OR A_diag ... OR nf_char2_future_formula ..., proven via nf_zone_exists_trichotomy_k1 disjunction-elim + the three _correct lemmas, replacing the :350 sorry (live-path sorries 2 -> 1, :353 remains downstream per task 305 scope).

CONSUME, DO NOT REBUILD (all sorry-free): all of task 308 (NfMultiAnchorBridge: nf_char2_formula deliverable 1, nf_zone_flatten_navigable(_brick) deliverable 2, nf_char2_zone_split5, nf_char2_atom_part(_correct), nf_quant_clause_tl); A_diag/_correct + the trichotomy nf_zone_exists_trichotomy_k1 (task 307 Phases 2-3); depth-0 bases diagDup/diagDup_eval_zero/renameNF_eval_diag0; bracketBuildLeft/Right(_correct) (Kamp/VecEATranslation.lean); the navigated pillars as the diagonal-only degenerate case. The import-cycle relocation is ALREADY LANDED (commit 69998c02d) — NfMultiAnchorBridge no longer imports KampPrior.

FORBIDDEN ROUTES (obstruction guards G1-G5, task 307 report 03 SS4): G1 no arity-1 collapse of the off-diagonal (refuted, report 02 SS1; NfDepth0Generalized:1691-1719). G2 no projection-based VecEA2 / third-free-anchor tower (refuted, specs/305 report 40; R2). G3 no trivial-top segment on the off-diagonal arms (report 03 SS1.2/SS2.3: a closed pastEnd under a trivial segment is unsatisfiable; the (x,t) coupling MUST ride the non-trivial Rabinovich beta_i segment). G4 w stays a bracket witness (env arity never grows past {w,x,t}=3 -> {x,t}=2; anchor set {x,t}; Rabinovich <=2 cap). G5 follow Cor 5.4 F_i chains step-by-step (F_n := alpha_n, F_{i-1} := alpha_{i-1} AND (beta_i Until F_i)); no simp/omega/aesop shortcut of a chain step (literature-fidelity policy).

LITERATURE GROUNDING: ~/Projects/Literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.md Section 5 (Lemma 5.1 md:134-152, Corollary 5.4 md:154-157).

GOAL STATE: lake build GREEN (full), top-level axioms unchanged (propext/Classical.choice/Quot.sound, 0 domain axioms), live-path sorries reduced 2 -> 1 (KampPrior.lean:350 closed, :353 remains), task 307 unblocked to finish Phase 7 wiring verification + Phase 8 wrap-up. Estimated ~400-700 lines total; run --hard --lit.

---

### 308. Multi anchor char formula bridge
- **Effort**: 10-15 hours
- **Status**: [COMPLETED]
- **Task Type**: lean4
- **Topic**: completeness
- **Dependencies**: None
- **Research**: [307_kamp_cor54_bound_anchor_zone_converter/reports/02_diag-blocker-audit.md]

**Description**: Build the depth-graded multi-anchor characteristic FORMULA builder (the "multi-anchor bracket bridge"), spawned from task 307's diagnostic blocker audit (specs/307_kamp_cor54_bound_anchor_zone_converter/reports/02_diag-blocker-audit.md). Task 307's Phases 3-6 are ALL blocked on this single missing object; it is also task 305's recurring Phase-11b crux. Build it once, off the live import path, sorry-free, axioms exactly [propext, Classical.choice, Quot.sound].

DELIVERABLES:
1. `nf_char2_formula : NormalForm sig (k+1) 2 -> Formula` satisfying `temporal_truth M atomMap t (nf_char2_formula sub_nf) <-> nf_eval_nf M (k+1) 2 (fun _=>t) sub_nf` (diagonal/constant two-anchor env) -- the arity-2 analog of `nf_succ_char_formula` (arity-1, KampPrior.lean:107-118). Consumes `nf_char3_eq_succ_iff` and `nf_characteristic_quant_split3` (both sorry-free theorems in NfZoneDepthK.lean), `renameNF_eval_diag0` (NfDepth0Generalized.lean:1646, sorry-free) for the diagonal depth-0 base, and `bracketBuildLeft`/`bracketBuildRight` (+ `_correct`, VecEATranslation.lean:50/234, sorry-free) for the w-zone navigation.
2. The general navigated bounded-existential corollary at arbitrary depth k (`nf_zone_flatten_navigable`): `exists w, nf_eval M k 3 [w,x,t] q <-> ` a `bracketBuild` disjunction over w's zones relative to (x,t), each depth-k residual discharged by the IH, endpoints NAVIGATED, w a bracket witness (env arity never grows past the {w,x,t}=3 -> {x,t}=2 reduction; anchor set stays {x,t}; respects Rabinovich's <=2 free-variable cap, Lemma 3.2.2).

Deliverable 1 unblocks task 307 Phase 3; deliverable 2 unblocks task 307 Phases 4/5/6; both together directly supply task 305's Phase-11b multi-anchor bracket bridge crux. Estimated ~400-700 lines; recursion on depth k.

LITERATURE GROUNDING (Tier 1): ~/Projects/Literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.md, Corollary 5.4 F_i chain (md:154-157: `F_n := alpha_n`, `F_{i-1} := alpha_{i-1} AND (beta_i Until F_i)`) and Lemma 5.1 inner w-zone case decomposition (md:159-169). Follow the F_i chain step-by-step (no simp/omega shortcut of a chain step).

HARD MODE REQUIRED (R-A): this bridge is the same object task 305's Phase-11b lineage has repeatedly failed to land across three prior refutations. Dispatch this task with `--hard` (H5 churn tracking mandatory). Encode the following as a Postmortem-forbidden 'Do NOT' list and check every candidate construction against it before implementing:
  (a) Do NOT re-attempt a projection-based VecEA2 bridge for the x=t diagonal case -- `liftIdx(totalUnskip)` is non-injective, so the coupled quant layer does not factor through per-variable projections (proven in NfZoneDepthK.lean, Phase 10 / `renameNF_eval_diag0` context).
  (b) Do NOT re-attempt a flat single-interval atomic bracket absorption (D1 flat-bracket) -- a depth-0 atomic `BracketFormula` is confined to the closed interval [x,t] and cannot capture exterior-w realizability (proven sorry-free by `interior_bracket_cannot_realize_exterior_sub_k1`, NfZoneDepthK1Probe.lean).
  (c) Do NOT re-attempt an arity-1-collapse repair for the diagonal arm (`char_k1 (diagCollapse sub_nf)`) -- this reduces to the depth-(k+1) lift of `diagDup_eval_zero`, which is already documented sorry-free as a non-theorem (NfDepth0Generalized.lean:1691-1719; liftIdx r is non-injective, the `<-` direction fails). This route BINDS at the actual :391 obligation because sub_nf there is universally quantified (see task 307 report 02, section 1).

SELF-DECOMPOSITION GUIDANCE (R-B): ~400-700 lines may exceed one dispatch. Phase-decompose internally, diagonal-first: build deliverable 1 (`nf_char2_formula`, the diagonal/constant case) before deliverable 2 (the general navigated bridge at arbitrary depth k) -- deliverable 1 is smaller, unblocks task 307 Phase 3 alone, and de-risks the recursive bracket-assembly machinery before extending it to the general case. Note even the diagonal-only version needs the full recursive bridge one depth down (the diagonal env collapses the seven w-zones to three, but each zone still encodes a depth-(k-1) diagonal characteristic), so do not expect deliverable 1 alone to materially shrink the total work -- it is a legitimate first phase, not a shortcut.

CONSUMPTION NOTES FOR TASK 305 (R-C): the bridge built here is task 305's Phase-11b crux. On completion, hand back explicit consumption notes (in a summary under specs/308_multi_anchor_char_formula_bridge/summaries/) documenting: the exact signatures of `nf_char2_formula` and the general navigated corollary, which task-305 artifacts/plans reference the Phase-11b bridge and should be rewired to reuse these definitions verbatim rather than rebuilding, and any depth/anchor-count assumptions task 305's rewire must respect. This ensures task 305 reuses the shared object instead of re-deriving it.

PRESERVED REUSABLE ASSETS (must not be rebuilt; consume, do not re-derive): `nf_char3_eq_succ_iff`, `nf_characteristic_quant_split3`, `nf_characteristic_quant_succ` (NfZoneDepthK.lean, all sorry-free theorems verified by lean_local_search); `renameNF_eval_diag0` (NfDepth0Generalized.lean:1646, sorry-free); `bracketBuildLeft`/`bracketBuildRight` (+ `_correct`, VecEATranslation.lean:50/234, sorry-free); `nf_succ_char_formula`/`_correct` (KampPrior.lean:107/121, arity-1 template); reuse the landed `diagDup`/`diagDup_eval_zero` (depth-0 duplication base, NfZoneFlattenNavigable.lean:243) verbatim.

GOAL STATE: both deliverables sorry-free, off the live import path, `lake build` GREEN, axiom set unchanged (propext/Classical.choice/Quot.sound only). Document consumption notes for task 305 per R-C above. Once complete, task 307 resumes Phases 3-6 using these two objects as prerequisites.

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

### 306. Add combinatorial bracketformula conjunction to veceaclosure
- **Effort**: 1-2 hours
- **Status**: [COMPLETED]
- **Task Type**: lean4
- **Topic**: completeness
- **Dependencies**: None
- **Research**: [305_rabinovich_ea_formula_implementation/reports/03_spawn-analysis.md]
- **Plan**:
  - [306_add_combinatorial_bracketformula_conjunction_to_veceaclosure/plans/01_bracket-conj-plan.md]
  - [306_add_combinatorial_bracketformula_conjunction_to_veceaclosure/plans/01_bracket-conj-plan.md]
- **Summary**: [306_add_combinatorial_bracketformula_conjunction_to_veceaclosure/summaries/01_bracket-conj-summary.md]

**Description**: Add a structural, model-independent BracketFormula conjunction to VecEAClosure.lean. The existing `conj_to_bracket_exists` only proves existence (∃ n, ∃ bf, ...) which cannot be used inside the VecEA2 negation closure induction. This task adds:

1. `BracketFormula.conjStruct (bf1 : BracketFormula n1) (bf2 : BracketFormula n2) : BracketFormula (n1 + n2)` -- a concrete combined bracket formula whose n1+n2 witnesses are the n1 witnesses of bf1 followed by the n2 witnesses of bf2. Point types are concatenated. Segment types interleave: for positions in bf1's range, conjoin the corresponding bf1 segment with the overall bf2 trivial segment (top), and vice versa for bf2's range.

2. `BracketFormula.conjStruct_holds` -- if bf1.holds M atomMap z0 z1 and bf2.holds M atomMap z0 z1, then (conjStruct bf1 bf2).holds M atomMap z0 z1. The proof reuses the witness interleaving approach from the n1+1/n2+1 case in the existing `conj_to_bracket_exists`.

3. `VBracketFormula.conj_struct` -- a fixed disjunct-list conjunction of VBracketFormulas: given v1 and v2, returns a VBracketFormula whose disjuncts are all pairwise combinations (conjStruct d1 d2) for d1 in v1.disjuncts, d2 in v2.disjuncts. Prove that if v1.holds and v2.holds then (conj_struct v1 v2).holds.

4. `VVecEA2.conj_struct` -- analogous structural conjunction for VVecEA2, combining endpoint conditions (conj) and brackets (conjStruct). Prove the semantic direction.

These definitions return fixed syntactic objects (not existential witnesses), enabling the VecEA2 negation closure induction in EANegation.lean (Phase 4 of task 305) to produce a concrete VVecEA2 from the three-case decomposition.

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

### 304. Import refactor mcs mixed case
- **Status**: [COMPLETED]
- **Task Type**: lean4
- **Topic**: completeness
- **Dependencies**: None

**Description**: Move mcs_mixed_case_absurd out of ChronicleToCountermodel.lean to eliminate phantom sorry dependency. Completed as part of task 301 phase 1.

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

### 302. Boneyard dead code archival
- **Status**: [COMPLETED]
- **Task Type**: lean4
- **Topic**: cleanup
- **Dependencies**: Task 301
- **Research**: [302_boneyard_dead_code_archival/reports/01_team-research.md]
- **Plan**: [302_boneyard_dead_code_archival/plans/02_implementation-plan.md]
- **Summary**: [302_boneyard_dead_code_archival/summaries/03_implementation-summary.md]

**Description**: Comprehensive dead code archival to Boneyard/ with comment cleanup. Scope: (1) Research all source files to identify dead code — unused definitions, unreachable lemmas, commented-out blocks, sorry-bearing stubs with no downstream consumers, and deprecated proof paths (BXCanonical, dead chronicle functions, VecEADecomposition sorries, Stavi path, etc.). (2) Physically move each dead code item from its source file into a corresponding file under Boneyard/, preserving module structure. (3) Update all imports and aggregator files so lake build passes after removal. (4) Add clear provenance comments in each Boneyard file noting the original location and reason for archival. (5) Review and improve comments throughout the remaining codebase for clarity — remove stale TODOs, outdated references, and misleading annotations left behind by prior refactors.

---

### 301. Completeness cleanup and roadmap
- **Status**: [COMPLETED]
- **Task Type**: lean4
- **Topic**: completeness
- **Dependencies**: None
- **Research**: [301_completeness_cleanup_and_roadmap/reports/01_completeness-status-audit.md]
- **Plan**: [301_completeness_cleanup_and_roadmap/plans/02_cleanup-roadmap-plan.md]

**Description**: Repository cleanup and roadmap update following task 273 completion and chronicle_gap dead-code audit. Scope: (1) Archive dead code to Boneyard/ (BXCanonical path, dead chronicle functions, VecEADecomposition sorries, possibly Stavi path) with clear comments. (2) Factor oversized files (KampBypass.lean at 4488 lines). (3) Move mcs_mixed_case_absurd out of ChronicleToCountermodel.lean to eliminate phantom sorry dependency. (4) Abandon obsolete tasks (155, 268, 200, 254, 176). (5) Revise task 95/299 dependencies. (6) Create new tasks: k>0 depth induction (sole completeness_discrete blocker) and import refactor. (7) Update ROADMAP.md to reflect current state: sole blocker is existPart_succ_n1_bypass k>0 in KampBypass.lean.

---

### 300. Refactor literature index json
abort aware tableau cancellation
- **Status**: [COMPLETED
NOT_STARTED]
- **Task Type**: meta
lean4
- **Topic**: literature
literature
- **Dependencies**: 

**Description**: Refactor specs/literature/ to use index.json files for --lit flag compatibility, keeping PDFs but ignoring them during literature retrieval, modeled after cslib specs/literature/ structure
Make the tableau decision procedure abort-aware by threading an IO.Ref Bool abort signal through expandBranchWithFuel and related functions. Currently, IO.cancel in labelFormulaImpl is cooperative but the pure tableau computation never calls IO.checkCanceled, so cancelled tasks continue as zombie threads accumulating memory. The fix: (1) Add an IO.Ref Bool parameter to expandBranchWithFuel that is checked at each recursive step. (2) Wire the abort ref from the IO.cancel handler in labelFormulaImpl. (3) Ensure extractCountermodelData in mkInvalidLabel also respects the abort signal. This eliminates the root cause of the c7 OOM — zombie tableau computations that survive cancellation.

---

### 300. Refactor literature index json
abort aware tableau cancellation
- **Status**: [COMPLETED
NOT_STARTED]
- **Task Type**: meta
lean4
- **Topic**: literature
literature
- **Dependencies**: 

**Description**: Refactor specs/literature/ to use index.json files for --lit flag compatibility, keeping PDFs but ignoring them during literature retrieval, modeled after cslib specs/literature/ structure
Make the tableau decision procedure abort-aware by threading an IO.Ref Bool abort signal through expandBranchWithFuel and related functions. Currently, IO.cancel in labelFormulaImpl is cooperative but the pure tableau computation never calls IO.checkCanceled, so cancelled tasks continue as zombie threads accumulating memory. The fix: (1) Add an IO.Ref Bool parameter to expandBranchWithFuel that is checked at each recursive step. (2) Wire the abort ref from the IO.cancel handler in labelFormulaImpl. (3) Ensure extractCountermodelData in mkInvalidLabel also respects the abort signal. This eliminates the root cause of the c7 OOM — zombie tableau computations that survive cancellation.

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
- **Dependencies**: Task 297, Task 300
- **Research**: [298_fix_c7_labeling_bug_and_regenerate_dataset/reports/01_c7-labeling-bug.md]
- **Plan**: [298_fix_c7_labeling_bug_and_regenerate_dataset/plans/01_c7-labeling-bug.md]

**Description**: Fix c7 labeling bug at formula ~13750 that causes unbounded memory growth in the decision procedure's timeout handling, then regenerate the full c7 dataset. During task 297 dataset regeneration, all 3 attempts to generate c7 stalled at exactly record 13,749 with RSS growing ~40MB/6s. The labeling function enters an apparent infinite loop or unbounded search for formula #13,750 in the sorted enumeration order. The timeout mechanism either does not fire or cannot interrupt the stuck state. Steps: (1) Identify the specific formula at position ~13,750 in the c7 enumeration. (2) Reproduce the hang in isolation with that formula. (3) Diagnose whether the decision procedure's timeout is failing to fire or the procedure is in an uninterruptible state. (4) Fix the timeout handling so it reliably terminates. (5) Regenerate the full c7 dataset (target: 77,272 records)

---

### 297. Verify operator removal and regenerate datasets
- **Status**: [COMPLETED]
- **Task Type**: lean4
- **Topic**: dataset-enhancement
- **Dependencies**: None
- **Research**: [297_verify_operator_removal_and_regenerate_datasets/reports/01_verify-operator-removal.md]
- **Plan**: [297_verify_operator_removal_and_regenerate_datasets/plans/01_verify-operator-removal.md]

**Description**: Verify that the removal of 6 derived binary temporal operators (release, weak_until, trigger, weak_since, strong_release, strong_trigger) from the formula enumerator is correct and complete. (1) Confirm lake build passes with zero errors. (2) Run enumeration at c4-c7 and verify the 6 operators no longer appear in enumerated formulas. (3) Verify formula counts are reduced as expected (~40-60% reduction in raw enumeration). (4) Run exhaustive labeling at c4 and c5 to confirm correctness (zero label disagreements, prefilter and cache still working). (5) Regenerate datasets at c4, c5, and c6 (with appropriate timeouts). (6) Verify the regenerated JSONL files contain no formulas with the removed operators. (7) Compare new dataset sizes against pre-removal baselines from the task 295 diagnostic report.

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
improve tableau fuel allocation
- **Status**: [PLANNED
PLANNED]
- **Task Type**: lean4
lean4
- **Topic**: dataset-enhancement
dataset-enhancement
- **Dependencies**: Task 288

**Description**: Improve tableau fuel allocation heuristic for imbalanced branches. Add estimateBranchDifficulty heuristic (temporal count, modal count, branch depth). Allocate fuel proportionally to difficulty across sub-branches. Prove termination still holds. Benchmark on c6. Expected 2-5% timeout reduction.
Improve tableau fuel allocation heuristic for imbalanced branches. Add estimateBranchDifficulty heuristic (temporal count, modal count, branch depth). Allocate fuel proportionally to difficulty across sub-branches. Prove termination still holds. Benchmark on c6. Expected 2-5% timeout reduction.

---

### 290. Improve tableau fuel allocation
improve tableau fuel allocation
- **Status**: [PLANNED
PLANNED]
- **Task Type**: lean4
lean4
- **Topic**: dataset-enhancement
dataset-enhancement
- **Dependencies**: Task 288

**Description**: Improve tableau fuel allocation heuristic for imbalanced branches. Add estimateBranchDifficulty heuristic (temporal count, modal count, branch depth). Allocate fuel proportionally to difficulty across sub-branches. Prove termination still holds. Benchmark on c6. Expected 2-5% timeout reduction.
Improve tableau fuel allocation heuristic for imbalanced branches. Add estimateBranchDifficulty heuristic (temporal count, modal count, branch depth). Allocate fuel proportionally to difficulty across sub-branches. Prove termination still holds. Benchmark on c6. Expected 2-5% timeout reduction.

---

### 289. Branch result memoization caching
- **Status**: [COMPLETED]
- **Task Type**: lean4
- **Topic**: dataset-enhancement
- **Dependencies**: Task 286
- **Research**: [289_branch_result_memoization_caching/reports/01_memoization-research.md]
- **Plan**: [289_branch_result_memoization_caching/plans/01_memoization-plan.md]
- **Summary**: [289_branch_result_memoization_caching/summaries/01_memoization-summary.md]

**Description**: Add branch-result memoization/caching to expandBranchWithFuel. Cache decide results keyed by (Formula, FrameClass, searchDepth, tableauFuel) in an IO.Ref-based LRU cache at the decide level. Size bound to 10K entries. Benchmark hit rate and total labeling time. Best combined with parallelization (task 286).

---

### 288. Deeper invalid pattern recognizers
- **Status**: [COMPLETED]
- **Task Type**: lean4
- **Topic**: dataset-enhancement
- **Dependencies**: Task 287
- **Research**: [288_deeper_invalid_pattern_recognizers/reports/01_invalid-patterns-research.md]
- **Plan**: [288_deeper_invalid_pattern_recognizers/plans/01_invalid-patterns-plan.md]
- **Summary**: [288_deeper_invalid_pattern_recognizers/summaries/01_invalid-patterns-summary.md]

**Description**: Add deeper invalid-pattern recognizers to structuralPrefilter. Detect structurally invalid formulas (e.g., U(box(bot), X)) that timeout the tableau but have obvious countermodels. Add isTemporalContradiction, isObviousSatisfiable, hasUnfulfillableEventuality. Wire into labelFormulaImpl before valid-prefilter. Each pattern must have formal soundness proof. Target: reduce c6 timeout rate by 3-8%.

---

### 282. Exhaustive enumeration by default
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: dataset-enhancement
- **Dependencies**: Task 274

---

### 273. Chronicle gap contradiction proof
- **Status**: [COMPLETED]
- **Task Type**: lean4
- **Topic**: completeness
- **Dependencies**: None
- **Research**:
  - [273_chronicle_gap_contradiction_proof/reports/01_gap-contradiction-research.md]
  - [273_chronicle_gap_contradiction_proof/reports/02_deep-analysis.md]
  - [273_chronicle_gap_contradiction_proof/reports/03_stavi-sorry-analysis.md]
  - [273_chronicle_gap_contradiction_proof/reports/04_ghr93-literature-review.md]
  - [273_chronicle_gap_contradiction_proof/reports/03_team-research.md]
  - [273_chronicle_gap_contradiction_proof/reports/05_proposition7-research.md]
  - [273_chronicle_gap_contradiction_proof/reports/06_decomposition-path-research.md]
  - [273_chronicle_gap_contradiction_proof/reports/05_team-research.md]
  - [273_chronicle_gap_contradiction_proof/reports/07_sorry-chain-verification.md]
  - [273_chronicle_gap_contradiction_proof/reports/08_game-pipeline-research.md]
  - [273_chronicle_gap_contradiction_proof/reports/08_team-research.md]
  - [273_chronicle_gap_contradiction_proof/reports/09_negation-closure-research.md]
  - [273_chronicle_gap_contradiction_proof/reports/10_literature-transcription.md]
  - [273_chronicle_gap_contradiction_proof/reports/11_divergence-audit.md]
  - [273_chronicle_gap_contradiction_proof/reports/12_team-research.md]
  - [273_chronicle_gap_contradiction_proof/reports/13_team-research.md]
  - [273_chronicle_gap_contradiction_proof/reports/23_team-research.md]
  - [273_chronicle_gap_contradiction_proof/reports/24_blocker-research.md]
  - [273_chronicle_gap_contradiction_proof/reports/26_team-research.md]
  - [273_chronicle_gap_contradiction_proof/reports/28_wiring-gap-analysis.md]
  - [273_chronicle_gap_contradiction_proof/reports/31_kamp-bypass-sorry-goals.md]
  - [273_chronicle_gap_contradiction_proof/reports/33_team-research.md]
  - [273_chronicle_gap_contradiction_proof/reports/35_team-research.md]
  - [273_chronicle_gap_contradiction_proof/reports/36_literature-bracket-proof.md]
  - [273_chronicle_gap_contradiction_proof/reports/38_team-research.md]
- **Plan**: [273_chronicle_gap_contradiction_proof/plans/39_bracketformula-k-encoding.md]

**Description**: Close the two remaining blockers for completeness_discrete: (1) KampPrior.lean:149 via NF-specific Prop 4.3 restricted to arity-1 formulas, using sorry-free neg_2var_vec_ea for the negation case (~150-200 lines); (2) chronicle_gap_contradiction (ChronicleToCountermodel.lean:531) via fully-proved reynolds_model_surgery_core (~100-150 lines). VecEADecomposition.lean sorries quarantined as dead code.

---

### 268. Reynolds pipeline bridge
- **Status**: [ABANDONED]
- **Task Type**: lean4
- **Topic**: completeness
- **Dependencies**: None
- **Research**:
  - [268_reynolds_pipeline_bridge/reports/01_bridge-research.md]
  - [268_reynolds_pipeline_bridge/reports/04_team-research.md]
  - [268_reynolds_pipeline_bridge/reports/05_completion-analysis.md]
  - [268_reynolds_pipeline_bridge/reports/06_reynolds-literature-review.md]
- **Plan**:
  - [268_reynolds_pipeline_bridge/plans/01_implementation-plan.md]
  - [268_reynolds_pipeline_bridge/plans/04_strategy-b-plan.md]
- **Summary**: [268_reynolds_pipeline_bridge/summaries/01_implementation-summary.md]
- **Handoff**: [268_reynolds_pipeline_bridge/handoffs/phase-2-handoff-20260603.md]

**Description**: Strategy B: Refactor discrete completeness to use Reynolds k-equivalence bypass instead of IsSuccArchimedean. Build LimitDomSubtype as OrderedMonadicStructure, apply sorry-free one_class -> very_good -> good pipeline, extract k-equivalent Z-interval, transfer satisfiability, build countermodel on Z. Eliminates succ_embed_surjective sorry chain entirely.

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

### 254. Update stale metadata post 202
- **Status**: [ABANDONED]
- **Task Type**: meta
- **Topic**: completeness
- **Dependencies**: Task 95, Task 176

**Description**: Final metadata and documentation update after completeness pipeline stabilization: (1) TODO.md sorry_count_note — comprehensive audit of sorry landscape post-tasks 202/155; (2) ROADMAP.md — annotate all completeness milestones achieved; (3) Transfer.lean and Completeness.lean — update stale axiom audit comments and sorry status documentation; (4) Verify #print axioms completeness_discrete shows no sorryAx. Follows tasks 95 (verification audit) and 176 (Chronicle relocation) to capture the final state.

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

### 200. Ghr93 case ii elegance rewrite
- **Status**: [ABANDONED]
- **Task Type**: lean4
- **Topic**: code-quality
- **Dependencies**: None

**Description**: Rewrite ghr93_case_II in CaseAnalysis.lean for code elegance and GHR93 fidelity. The proof is already correct, sorry-free, and axiom-clean (733 lines). The goal is to replace the tau_left/tau_right sub-game structure with a single restricted tau following GHR93 exactly. This requires resolving the fundamental gap between GHR93's continuous order-type preservation and the Lean formalization's finite-position EF games: same_order_type applies to n+3 positions, so orderings at interior points (p_n, e_n) require those points to be game endpoints — which is exactly what tau_left/tau_right achieve. A solution would require either (a) enriching the EF game framework to support continuous order-type preservation, or (b) finding a way to make the restricted tau's endpoint orderings imply interior-point orderings. Extensive research (7 agents, 3 plan revisions) confirmed the blocker is structural. GHR93 infrastructure theorems (untl_witness_bounded, ghr93_untl_transfer, ghr93_construct_en) are proved and available in CharacteristicFormula.lean and CaseAnalysis.lean. See specs/155_reynolds_pipeline_activation/reports/47_*.md and handoffs/phase-5-blocker-finite-position-games-20260528.md for full analysis.

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

### 176. Relocate chronicle and archive dead bxcanonical
- **Status**: [ABANDONED]
- **Task Type**: lean4
- **Topic**: formula-refactor
- **Dependencies**: Task 155

**Description**: Resolve architectural confusion where Chronicle/ lives under BXCanonical/ but is only consumed by WeakCanonical/. Move 6 Chronicle files (14331 lines) to Metalogic/Chronicle/ or WeakCanonical/Chronicle/. Archive entire non-Chronicle BXCanonical subtree (16 files, 4615 lines, 19 false sorries) to Boneyard/BXCanonical/. Verify OrderedSeedConsistency.lean dependency from WeakCanonical/ReflexiveCanonical.lean before archiving. Update aggregator imports. Subsumes part of task 130 scope.

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

### 155. Reynolds pipeline activation
- **Status**: [ABANDONED]
- **Task Type**: lean4
- **Topic**: completeness
- **Dependencies**: Task 268
- **Research**:
  - [155_reynolds_pipeline_activation/reports/01_team-research.md]
  - [155_reynolds_pipeline_activation/reports/02_team-research.md]
  - [155_reynolds_pipeline_activation/reports/03_post-157-status.md]
  - [155_reynolds_pipeline_activation/reports/03_team-research.md]
  - [155_reynolds_pipeline_activation/reports/04_phase4-blocker.md]
  - [155_reynolds_pipeline_activation/reports/05_full-reynolds-impl.md]
  - [155_reynolds_pipeline_activation/reports/06_path-b-feasibility.md]
  - [155_reynolds_pipeline_activation/reports/07_ghr93-strategy-review.md]
  - [155_reynolds_pipeline_activation/reports/08_ghr93-game-theory.md]
  - [155_reynolds_pipeline_activation/reports/09_lean-infrastructure-inventory.md]
  - [155_reynolds_pipeline_activation/reports/10_team-research.md]
  - [155_reynolds_pipeline_activation/reports/11_phase10-blocker-research.md]
  - [155_reynolds_pipeline_activation/reports/15_d-consistency-blocker.md]
  - [155_reynolds_pipeline_activation/reports/12_degenerate-interval-blocker.md]
  - [155_reynolds_pipeline_activation/reports/21_muSig-blocker-resolution.md]
  - [155_reynolds_pipeline_activation/reports/27_d-consistency-blocker.md]
  - [155_reynolds_pipeline_activation/reports/35_phase1-blocker-prior-art.md]
  - [155_reynolds_pipeline_activation/reports/18_task17-blocker-resolution.md]
  - [155_reynolds_pipeline_activation/reports/22_claim1-case2-literature.md]
  - [155_reynolds_pipeline_activation/reports/23_tactic-needs-beyond-195.md]
  - [155_reynolds_pipeline_activation/reports/27_post-195-assessment.md]
  - [155_reynolds_pipeline_activation/reports/27_team-research.md]
  - [155_reynolds_pipeline_activation/reports/28_team-research.md]
  - [155_reynolds_pipeline_activation/reports/29_phase3-blocker-research.md]
  - [155_reynolds_pipeline_activation/reports/30_blocker-study-prior-art.md]
  - [155_reynolds_pipeline_activation/reports/32_post-dependency-assessment.md]
  - [155_reynolds_pipeline_activation/reports/33_lit-sel-pn-ordering.md]
  - [155_reynolds_pipeline_activation/reports/33_infra-sel-pn-fix.md]
  - [155_reynolds_pipeline_activation/reports/33_tactic-sel-pn-grid.md]
  - [155_reynolds_pipeline_activation/reports/38_equality-case-research.md]
  - [155_reynolds_pipeline_activation/reports/39_game-depth-restructuring.md]
  - [155_reynolds_pipeline_activation/reports/40_ghr93-case-ii-step6.md]
  - [155_reynolds_pipeline_activation/reports/41_stavi-completeness-audit.md]
  - [155_reynolds_pipeline_activation/reports/42_plan-literature-alignment.md]
  - [155_reynolds_pipeline_activation/reports/44_team-research.md]
  - [155_reynolds_pipeline_activation/reports/50_import-cycle-research.md]
  - [155_reynolds_pipeline_activation/reports/55_team-research.md]
  - [155_reynolds_pipeline_activation/reports/56_phase2-blocker-research.md]
  - [155_reynolds_pipeline_activation/reports/57_bypass-surjectivity-research.md]
  - [155_reynolds_pipeline_activation/reports/58_proper-fix-research.md]
  - [155_reynolds_pipeline_activation/reports/60_team-research.md]
  - [155_reynolds_pipeline_activation/reports/61_team-research.md]
  - [155_reynolds_pipeline_activation/reports/62_blocker-literature-research.md]
  - [155_reynolds_pipeline_activation/reports/65_team-research.md]
- **Handoff**:
  - [155_reynolds_pipeline_activation/handoffs/phase-0-handoff-20260520.md]
  - [155_reynolds_pipeline_activation/handoffs/phase-4-handoff-20260520c.md]
  - [155_reynolds_pipeline_activation/handoffs/phase-1-handoff-20260522T160731Z.md]
  - [155_reynolds_pipeline_activation/handoffs/phase-1-handoff-20260522T164255Z.md]
  - [155_reynolds_pipeline_activation/handoffs/phase-1-handoff-20260522T180000Z.md]
  - [155_reynolds_pipeline_activation/handoffs/phase-1-handoff-20260522T190000Z.md]
  - [155_reynolds_pipeline_activation/handoffs/phase-1-handoff-20260522T174500Z.md]
  - [155_reynolds_pipeline_activation/handoffs/phase-1-handoff-20260522T193000Z.md]
  - [155_reynolds_pipeline_activation/handoffs/phase-1-handoff-20260522T210000Z.md]
  - [155_reynolds_pipeline_activation/handoffs/phase-3-handoff-20260525T043000Z.md]
  - [155_reynolds_pipeline_activation/handoffs/phase-1-handoff-20260603T051841Z.md]
  - [155_reynolds_pipeline_activation/handoffs/phase-1-blocked-handoff-20260602.md]
- **Summary**: [155_reynolds_pipeline_activation/summaries/28_reynolds-bypass-summary.md]
- **Plan**:
  - [155_reynolds_pipeline_activation/plans/65_discrete-game-bypass.md]
  - [155_reynolds_pipeline_activation/plans/67_half-rank-game-bypass.md]

**Description**: Eliminate all sorries from completeness_discrete by fixing 3 root sorries in StaviCompleteness.lean (4-variable EF-game existential transfer, GHR93 Proposition 7) and rewiring limitDomSubtype_isSuccArchimedean to use the now-sorry-free Reynolds model surgery pipeline. Phase 1 (import cycle resolution) complete.

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
