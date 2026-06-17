# Alignment Evaluation: Research ↔ Plan ↔ Literature

**Task**: 303 (k_gt_0_depth_induction)
**Session**: sess_1781710390_4591d5
**Date**: 2026-06-17
**Sources Evaluated**:
- Research: reports/09_interval-splitting-mapping.md
- Plan: plans/09_betweenzone-existpart-plan.md
- Primary Literature: Rabinovich 2014, "A Proof of Kamp's Theorem", Section 5
- Lean Code: GeneralExistPart.lean, KampBypass.lean, KampMutualInduction.lean, VecEADecomp.lean, ZoneBridge.lean

## Executive Summary

The research report and plan are in STRONG INTERNAL ALIGNMENT: the plan correctly discovers that the research report's recommended Option K1 (BetweenZoneExistPart) is ALSO FALSE, and pivots to a different strategy. However, both documents are MISALIGNED WITH RABINOVICH on the fundamental architecture of the solution. The plan's Phase 2 narrows to a "self-bootstrapping backward proof" approach that the plan itself proves circular, then retreats to sorry-with-documentation. The plan's Phase 3-4 (V-EA negation closure) correctly identifies the Rabinovich-faithful path but provides no concrete design. The net effect is that the plan accurately diagnoses the problem and honestly documents the failure, but does not provide an implementable path. The gap between current Lean architecture (depth-stratified NF mutual induction) and Rabinovich's architecture (bracket-formula witness-count induction) is underestimated in both documents.

## A. Research ↔ Plan Alignment

### A1. Does the plan faithfully implement the research recommendation (Option K1)?

**No -- and for good reason.** The research report recommends Option K1 (BetweenZoneExistPart), but the plan independently discovers that Option K1 is ALSO FALSE via the same Z counterexample mechanism: on Z with constant predicates, the formula is evaluated at x, but temporal_truth at any integer is the same for all formulas due to translation homogeneity. The plan's Section "Planning-phase finding" (lines 19-25) explicitly documents this refutation and correctly explains why: characterizing a 2-free-variable condition via a 1-free-variable formula is not guaranteed by Kamp's theorem.

**Alignment verdict**: The plan's self-correction is CORRECT and demonstrates genuine intellectual progress beyond the research report. The research report's adversarial verification (Claim 3, lines 216-228) partially identified this risk but concluded "VERIFIED: approach works for the actual usage site" -- the plan's deeper analysis shows this verification was incomplete.

### A2. Are there claims in the research that the plan contradicts or ignores?

**Two contradictions, both justified**:

1. **Research Claim**: "Zone-decomposed approach avoids the counterexample" (Finding 5, line 101-130). **Plan correction**: BetweenZoneExistPart is also FALSE (plan lines 19-25). The research's argument that "the temporal formula naturally distinguishes these cases because the evaluation point differs" was flawed -- on Z, the evaluation point IS different (x=2 vs x=1) but temporal formulas cannot distinguish between different points on Z with constant predicates.

2. **Research Claim**: "~200-400 lines to replace GeneralExistPart.lean" (line 298). **Plan correction**: The plan's effort estimate is 8 hours across 4 phases, with Phases 3-4 described as research-then-implement for V-EA negation closure. The plan correctly recognizes this is substantially more work than the research estimated.

**One item ignored (acceptable)**: The research's Option K2 (IntervalExistPart with SSNZone) is not explored in the plan. This is acceptable because the plan demonstrates that the fundamental issue (1-var formula characterizing 2-var condition) affects all zone-based formulations equally.

### A3. Does the plan's phase decomposition match the research's effort estimate?

**No -- the plan is significantly more honest about effort.** The research estimated 200-400 lines (Finding 5, line 298). The plan:
- Phase 1: 1.5 hours (deletion, straightforward)
- Phase 2: 2.5 hours (restructuring, but ending with 2 sorry at between-zone sites)
- Phase 3: 2 hours (RESEARCH only -- designing V-EA negation closure)
- Phase 4: 2 hours (CONDITIONAL on Phase 3 tractability)
- Total: 8 hours, with 50% risk that Phases 3-4 are blocked

The plan's phase decomposition is more realistic but still potentially underestimates Phase 4 (implementing V-EA negation closure from scratch in Lean is likely 500-1000 lines, not 2 hours).

### A4. Does the plan address all 6 zones identified in the research?

**Yes, but with a critical admission.** The research identifies 6 zones (Finding 5, lines 107-126):
1. y = x -- Plan: handled by eq zone (false/false), sorry-free
2. y = t -- Plan: handled by eq zone, sorry-free
3. y > x -- Plan: handled by existing Until infrastructure
4. y < t -- Plan: handled by existing Since infrastructure
5. t < y < x (between-zone) -- Plan: **sorry** (between-zone quantifier encoding)
6. x < y < t (between-zone mirror) -- Plan: **sorry** (mirror of zone 5)

The plan correctly identifies that zones 1-4 can use `ih_exist` (constant-env ExistPart) and only zones 5-6 require the new formulation. The code confirms this: the `false/false` match arm (eq zone, lines 921-1060 of KampBypass.lean) already uses `ih_exist` and is sorry-free.

## B. Plan ↔ Literature Alignment

### B1. Does BetweenZoneExistPart correspond to a specific step in Rabinovich Section 5?

**Not directly.** BetweenZoneExistPart (the research's Option K1, which the plan proves FALSE) does not correspond to any single step in Rabinovich. Rabinovich never attempts to characterize a between-zone existential via a single temporal formula at one evaluation point. Instead, Rabinovich works with BRACKET FORMULAS [alpha_0, beta_1, ..., beta_n, alpha_n](z_0, z_1) that have TWO free variables and shows closure under negation (Proposition 4.2).

The plan's Phase 3-4 (V-EA negation closure) DOES correspond to Rabinovich Section 5:
- Phase 3 maps to Lemma 5.1 (negation of bracket formula -> V-EA)
- The between-zone sorry would be closed by Case 3 of Lemma 5.1

However, the plan does not specify HOW Rabinovich's 2-free-variable bracket formulas map to the Lean codebase's 1-free-variable formulation (ExistPart evaluates formulas at `e(0)` only, while Rabinovich's bracket formulas depend on both z_0 and z_1).

### B2. Does the zone decomposition match Rabinovich's A_i^-/A_i^+ interval splitting?

**Partially, but at a different level of abstraction.** Rabinovich's A_i^-/A_i^+ splitting (page 10-11 of the PDF) decomposes a bracket formula at an intermediate point z:
- A_i^-(z_0, z) = [alpha_0, beta_1, ..., beta_i, alpha_i](z_0, z) -- left sub-interval
- A_i^+(z, z_1) = [alpha_i, beta_{i+1}, ..., alpha_{n+1}](z, z_1) -- right sub-interval

The Lean code's zone decomposition (zones 1-6) operates at a DIFFERENT level: it classifies the existential witness y's position relative to the two free variables x and t. This is closer to the INNER structure of a single bracket formula (which existential witness is being placed where), not the A_i^-/A_i^+ splitting which operates on the OUTER negation structure.

The plan correctly identifies this gap in Phase 3 ("Research and Design V-EA Negation Closure") but does not resolve it.

### B3. Does the plan correctly handle Dedekind completeness (INF formula, K+ operator)?

**Yes, at the k=0 level; unclear at k>0.** The plan correctly notes (research report Finding 7, lines 186-199) that:
- Prior axioms (semantic_prior_UZ/SZ) encode Dedekind completeness
- The INF formula (Rabinovich equation 5.2) is well-defined on Z
- K+ is implemented via Until-based temporal formulas
- PriorINF.lean (194 lines) exists

However, for k>0, the plan does not specify how the INF formula interacts with the depth-stratified NF hierarchy. In Rabinovich, INF is defined for predicates P_1, which at depth k>0 would be temporal formulas (from the induction hypothesis). The plan does not address whether the existing PriorINF infrastructure handles temporal-formula predicates or only atomic predicates.

### B4. Are there proof techniques in Rabinovich that the plan should use but doesn't mention?

**Yes, three critical techniques are underspecified:**

1. **Corollary 5.4 (F_i = alpha_i AND (beta_{i+1} Until F_i+1))**: This is the CORE mechanism that reduces bracket formulas with interval types beta_i to bracket formulas where all beta_i = True (Lemma 5.3). The plan mentions this in the research report (Step 2, lines 318-320) but the plan itself does not specify how to implement it. The Lean code's existing KampBypass enriched formula construction (lines 630-636) is EXACTLY this F_i construction, so the infrastructure partially exists -- but only for the forward direction.

2. **Witness-count induction (n -> n+1)**: Rabinovich's proof of Lemma 5.3 uses induction on the NUMBER OF EXISTENTIAL WITNESSES, which decreases with each interval splitting. The Lean codebase has no analog of this induction -- the existing mutual induction is on DEPTH k, not on witness count. Implementing Rabinovich faithfully would require either (a) adding a second induction parameter (witness count) to the mutual induction, or (b) showing that the depth induction subsumes witness-count induction via the NF hierarchy.

3. **Case 3 of Lemma 5.1 (INF^{not beta_1} splitting)**: The full Lemma 5.1 proof uses three cases at the point z where not-beta_1 first holds (found via INF). The plan mentions Case 3 in Phase 3 but does not account for how the Lean formalization of "INF^{not beta_1}" interacts with the NF-based approach.

## C. Research ↔ Literature Alignment

### C1. Does the H3 mapping table accurately reflect Rabinovich's proof structure?

**Partially accurate, with two significant mismatches.**

**Accurate mappings**:
- Proposition 3.5 -> `existPart_succ_n1_bypass_k0` (correct for k=0)
- Corollary 5.4 -> KampBypass enriched formula construction (correct)
- INF formula -> `semantic_prior_UZ`/`semantic_prior_SZ` (correct)
- K+ operator -> Until-based temporal formula (correct)

**Inaccurate mappings**:
1. **Lemma 5.1** is mapped to "Encoded in ExistPart backward direction" with status "Partial". This understates the gap. Lemma 5.1 is a STANDALONE result about negation closure of bracket formulas. The Lean codebase has no direct analog -- the backward direction of ExistPart is a different theorem (characterizing existentials on constant environments, not negating bracket formulas).

2. **A_i^-/A_i^+ decomposition** is mapped to "Zone decomposition in KampBypassUntil/Since" with status "Sorry-free (k=0)". This is a STRUCTURAL MISMATCH: the Lean zone decomposition classifies y's position relative to x and t (6 zones), while Rabinovich's A_i^-/A_i^+ splits the interval at an intermediate witness point. These are different operations at different levels of the proof.

### C2. Are there gaps in the mapping?

**Yes, three major gaps:**

1. **Rabinovich concept with no Lean analog**: Lemma 5.3 (negation of pure existential formula over Dedekind complete chains). The Lean codebase has `VecEADecomp` which handles SOME aspects of this at depth 0, but the full Lemma 5.3 result (induction on witness count n) has no direct Lean counterpart. This is the foundational building block for the whole Section 5 argument.

2. **Rabinovich concept with no Lean analog**: The B_i^-/B_i^+ formulas (page 10, defining the "extended" sub-interval formulas that include the interval types beta). The Lean code only has the restricted A_i^-/A_i^+ structure, not the B variant that includes beta constraints on sub-intervals.

3. **Lean concept without Rabinovich analog**: `GeneralExistPartOrdered` -- this is a Lean-specific formulation that has no counterpart in Rabinovich. Rabinovich never needs to characterize non-constant-env existentials via a single formula at one point; his approach works exclusively with bracket formulas over intervals defined by TWO endpoints.

### C3. Does the Z counterexample analysis align with Rabinovich's handling of discrete structures?

**Yes, and this reveals why Rabinovich's approach works where the Lean formulation fails.**

The research report correctly identifies (Finding 1, lines 42-55) that Z with constant predicates is Dedekind complete and provides a counterexample to GeneralExistPartOrdered. This is CONSISTENT with Rabinovich: Rabinovich's proof works on Z because bracket formulas have two free variables (z_0, z_1), and the interval (z_0, z_1) is well-defined on Z. The gap size (number of integers between z_0 and z_1) is captured by the bracket formula's STRUCTURE (how many existential witnesses fit), not by a single-point evaluation.

The fundamental issue: the Lean codebase tries to reduce everything to temporal formulas at ONE evaluation point (e(0)), while Rabinovich's bracket formulas inherently carry information about TWO points (the interval endpoints). This architectural mismatch is the root cause of the counterexample problem.

## D. Risk Assessment

### D1. Is BetweenZoneExistPart actually TRUE?

**No -- the plan proves it FALSE.** The plan's "Planning-phase finding" (lines 19-25) provides a rigorous refutation: on Z with constant predicates, the formula at x=2 must differ from the formula at x=1 (since between-zone existentials differ), but Z's translation homogeneity forces all temporal formulas to evaluate the same at every point. The plan correctly identifies the root cause: a 2-free-variable condition cannot be characterized by a 1-free-variable formula in general.

**This is mathematically correct.** More precisely: the set of temporal formulas is determined by the 1-type (depth-k 1-var NF) of the evaluation point, but the between-zone existential depends on the 2-type (depth-k 2-var NF) of the pair (x, t). On Z with constant predicates, all points have the same 1-type but pairs can have different 2-types (depending on gap size). Therefore no temporal formula at x alone can distinguish different 2-types.

### D2. Does the between-zone case genuinely reduce to something provable via Since from x?

**No.** The plan's detailed analysis (lines 158-169) demonstrates that the naive Since formula `pred Since char(t)` at x is TOO WEAK: it finds witnesses outside the target interval (t, x) because it cannot uniquely identify t. On Z with constant predicates, `pred Since char(t)` evaluated at x=1 finds y=0 (outside the empty interval (0,1)), giving a false positive.

The plan's conclusion is correct: characterizing "exists y strictly between t and x" via a temporal formula at x requires the formula to KNOW about t, but the formula is a fixed syntactic object independent of t.

### D3. What is the hardest sub-lemma, and does existing infrastructure cover it?

**Hardest sub-lemma**: The between-zone case at k>0, which is the negation closure of bracket formulas with quantifier sub-conditions (Rabinovich Lemma 5.1, inductive step).

**Infrastructure assessment**:
- PriorINF.lean (194 lines): Provides INF formula infrastructure. **Covers** the Dedekind completeness part of Lemma 5.1 Case 3.
- VecEADecomp.lean (898 lines): Provides depth-0 zone decomposition. **Does NOT cover** the depth-k>0 generalization.
- KampBypass.lean (1069 lines): Provides enriched Until/Since formula construction (Corollary 5.4). **Covers** the F_i construction but only for the forward direction.
- VecEAClosure.lean (262 lines): Provides V-EA closure properties. **Partially covers** the Boolean closure needed for Lemma 5.1.
- ExistsForallNF.lean (267 lines): Provides EA normal form infrastructure. **Partially covers** the syntactic structure.
- KampForward.lean (675 lines): Provides forward-direction temporal formulas. **Covers** part of the bracket -> temporal translation.

**Gap**: No existing infrastructure handles the NEGATION direction at k>0 (bracket formula negation -> V-EA). This is a 500-1500 line gap, not the 200-400 lines estimated in the research report.

### D4. Are there hidden circular dependencies in the proposed mutual induction?

**Yes -- the plan explicitly discovers one.** Phase 2's "Critical design question" (lines 153-169) documents a circularity: using `generalExistPart_from_classical` requires 2-var NF eval as precondition, but establishing 2-var NF eval requires the very existential characterization that `generalExistPart_from_classical` provides.

**Additional hidden circularity**: The plan proposes (Phase 2, lines 106-112) to use `generalExistPart_from_classical` for the forward direction and build nf_eval_nf "directly" for the backward direction. But the "direct construction" still requires knowledge of quantifier truth values, which requires either (a) the formula to encode them (circular with the construction), or (b) cross-structure transfer (which requires 2-var NF agreement, also circular).

The plan's honest assessment is that this circularity is FUNDAMENTAL and cannot be resolved without the V-EA negation closure approach (Phases 3-4).

## H4 Adversarial Verification

| # | Claim | Source | Challenge | Result |
|---|-------|--------|-----------|--------|
| 1 | GeneralExistPartOrdered is FALSE at all depths | Research Finding 1 | Could depth-k NF uniformity on Z fail at some k? | **CONFIRMED**. Z's translation automorphism (shift by 1) preserves all atomic predicates and all temporal structure. By induction on k, depth-k 1-var NFs are uniform. The research report's argument is rigorous. |
| 2 | BetweenZoneExistPart (Option K1) is also FALSE | Plan lines 19-25 | Could the formula at x (not t) distinguish gap sizes? | **CONFIRMED**. On Z with constant predicates, temporal_truth is uniform across all integers (by induction: if 1-var NFs are uniform, then temporal characteristic formulas evaluate uniformly, hence temporal_truth is uniform for ALL formulas). The plan's refutation is correct. |
| 3 | existPart_succ_n1_bypass for k>0 is sorry-free given valid ih | Research Finding 2 | Could there be sorry in the Until/Since zones? | **CONFIRMED with nuance**. The KampBypass.lean code (lines 591-920) for Until and Since zones IS complete with no sorry in the proof BODY. However, the code USES `ih_general_exist` (the GeneralExistPartOrdered hypothesis) in lines 616, 627, 797, 808. Since GeneralExistPartOrdered is FALSE, these uses produce a vacuously true proof. The "sorry-free" claim is technically correct (no sorry keyword) but semantically misleading: the proof is vacuously valid from a false hypothesis. |
| 4 | k=0 infrastructure (~4400 lines) is sorry-free | Research Finding 6 | Could there be hidden sorry dependencies? | **CONFIRMED**. Verified: KampBypassCore.lean (2160 lines, 1 sorry -- but it's in a comment/docstring context), KampBypassUntil.lean (979 lines, 0 sorry), KampBypassSince.lean (1307 lines, 0 sorry), ZoneBridge.lean (513 lines, 0 sorry). The k=0 paths (`existPart_succ_n1_bypass_k0_until`, `_since`, `_eq`) are genuinely sorry-free. |
| 5 | Plan Phase 1 (delete GeneralExistPartOrdered) is safe | Plan Phase 1 | Could deleting GeneralExistPartOrdered break other consumers? | **CONFIRMED with caveat**. `GeneralExistPartOrdered` is used in: (a) `kamp_mutual_induction` as third conjunct, (b) `existPart_succ` as `ih_general_exist_ordered` parameter, (c) `existPart_succ_n1_bypass` as `ih_general_exist` parameter. Deleting it breaks the k>0 case but not the k=0 case. `generalExistPart_from_classical` (the sound version with full NF precondition) is PRESERVED and should NOT be deleted. The plan correctly identifies this distinction. |
| 6 | Phase 2 backward direction can be built without circularity | Plan Phase 2 | Can quantifier truth values be extracted from formula encoding? | **REFUTED**. The plan itself proves this circular (lines 116-122): top/bot formulas from classical satisfiability don't carry enough information. The plan's alternative (zone decomposition of each ssn) recurses to higher-arity existentials, making the problem worse. The plan honestly documents this as a blocker. |
| 7 | Phase 3-4 (V-EA negation closure) is achievable in 4 hours | Plan Phases 3-4 | Is 4 hours realistic for implementing Rabinovich Lemma 5.1? | **REFUTED**. Rabinovich's proof of Lemma 5.1 is 3 pages of dense mathematics involving: (a) induction on witness count n, (b) case analysis with INF formula, (c) sub-interval splitting with B_i^-/B_i^+ formulas, (d) interaction with V-EA closure under conjunction/disjunction/existential quantification. In Lean, this requires: new induction parameter, INF formula integration with depth-k NFs, sub-interval bracket formula definitions, and full V-EA closure at all depths. Realistic estimate: 500-1500 lines over 3-8 implementation sessions. |
| 8 | The eq zone (false/false) serves as template for Until/Since zones | Plan Prior Plan Reference | Can the eq-zone pattern be adapted for non-equal zones? | **REFUTED**. The eq zone works because x=t, so the environment is constant (Fin.cons t (fun _ => t)), and ih_exist (constant-env ExistPart) applies directly. The Until/Since zones have x != t, so the environment is NON-constant, and ih_exist does NOT apply. The plan acknowledges this (lines 124-131) but initially presents the eq-zone as a template before realizing the fundamental difference. |
| 9 | Plan's Revised approach (generalExistPart_from_classical + self-bootstrapping) works | Plan Phase 2 approach | Can generalExistPart_from_classical close the gap? | **UNCERTAIN** leaning **REFUTED**. `generalExistPart_from_classical` (GeneralExistPart.lean lines 213-249) uses classical top/bot encoding with FULL r-var NF precondition. It IS proved and sorry-free. However, using it in the backward direction of existPart_succ_n1_bypass requires establishing the full 2-var NF eval as precondition, which is the very thing being proved. The plan identifies this circularity. |
| 10 | Rabinovich's approach avoids the counterexample | Literature Section 5 | Why does Rabinovich's proof work on Z where the Lean formulation fails? | **CONFIRMED**. Rabinovich works with bracket formulas that have TWO free variables (z_0, z_1), so the interval (z_0, z_1) is explicitly part of the formula's structure. On Z, the bracket formula [alpha_0, beta_1, alpha_1](0, 2) differs from [alpha_0, beta_1, alpha_1](0, 1) because the interval (0,2) contains 1 and (0,1) is empty. The 2-variable structure carries the gap-size information that the 1-variable Lean formulation loses. |

## Recommendations

1. **Do NOT implement the plan as written.** Phases 1-2 are implementable but Phase 2 ends with 2 sorry at between-zone sites that are at least as hard as the original sorry. Phases 3-4 are research tasks masquerading as implementation phases with unrealistic effort estimates. The plan honestly documents this but does not provide an implementable path.

2. **Pursue the Rabinovich-faithful architecture (Phases 3-4) as a DEDICATED research task.** The key question: can Rabinovich's Lemma 5.1 be formalized within the existing NF mutual induction framework, or does it require a fundamentally different proof architecture (bracket-formula induction on witness count)? This is a research question, not an implementation question.

3. **Separate Phase 1 as a standalone improvement.** Deleting the FALSE GeneralExistPartOrdered and simplifying `kamp_mutual_induction` to 2-conjunct (CharPart + ExistPart) is safe and removes dead code. This can be done independently of the harder problem. However, it will temporarily break `existPart_succ` at k>0 because `ih_general_exist_ordered` is passed to `existPart_succ_n1_bypass`.

4. **Investigate the architectural bridge.** The fundamental gap is between Rabinovich's 2-free-variable bracket formulas and the Lean codebase's 1-free-variable ExistPart. Possible bridges:
   - (a) Reformulate ExistPart to carry TWO evaluation points (breaking the current API)
   - (b) Add a new mutual induction conjunct that is a PROPER 2-variable characterization (unlike GeneralExistPartOrdered which was an improper one)
   - (c) Show that the depth-k induction in the Lean code subsumes the witness-count induction in Rabinovich (this would be the cleanest solution but may be impossible)

5. **Consult Gabbay 1993 ("Temporal Expressive Completeness in the Presence of Gaps") for the discrete case specifically.** Rabinovich's proof is for ALL Dedekind complete chains. Gabbay 1993 may contain discrete-specific techniques (for N and Z) that avoid the full generality of Lemma 5.1 and might be easier to formalize.

6. **The sorry count will not decrease in Phase 2.** The plan proposes moving 2 sorry from GeneralExistPart.lean (lines 174, 207) to 2 sorry at between-zone sites in KampBypass.lean. This is a lateral move in terms of sorry count but a conceptual improvement (the new sorry sites are TRUE statements, unlike the old sorry sites which are FALSE statements). Communicate this clearly to avoid false expectations.

7. **Re-examine whether generalExistPart_from_classical suffices.** The sound `generalExistPart_from_classical` (which uses full r-var NF precondition and IS proved) might suffice if the forward direction can establish the full 2-var NF eval. The forward direction starts from `exists x, nf_eval_nf M (k'+2) 2 [x,t] sub_nf` and directly has the 2-var NF eval. Check whether the FORWARD use of `generalExistPart_from_classical` + `ih_exist` for the backward direction's quantifier conditions creates a well-founded chain. This approach is sketched in the plan but dismissed as circular; a more careful analysis might reveal it is NOT circular if the forward and backward directions are proved independently.

8. **Effort recalibration.** Replace the plan's "8 hours" total with a more realistic estimate: Phase 1 (1 hour), Phase 2 with sorry (3 hours), Phase 3 research (4-8 hours), Phase 4 implementation (8-20 hours). Total: 16-32 hours of agent time. This is a significant undertaking that should be communicated to the project owner.
