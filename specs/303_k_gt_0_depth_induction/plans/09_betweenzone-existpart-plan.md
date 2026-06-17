# Implementation Plan: Eliminate ih_general_exist via Enriched Quantifier Encoding

- **Task**: 303 - k_gt_0_depth_induction
- **Status**: [NOT STARTED]
- **Effort**: 8 hours
- **Dependencies**: None (k=0 infrastructure is sorry-free)
- **Research Inputs**: reports/09_interval-splitting-mapping.md
- **Artifacts**: plans/09_betweenzone-existpart-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Plan v9 eliminates the false `GeneralExistPartOrdered` third mutual induction conjunct and removes `ih_general_exist` from `existPart_succ_n1_bypass`. Research report 09 proved GeneralExistPartOrdered is FALSE at all depths (Z counterexample). Extended analysis during planning revealed that BetweenZoneExistPart (report 09's Option K1) is ALSO FALSE for the same reason: on Z with constant predicates, translation homogeneity makes all temporal formulas evaluate identically at every point, yet between-zone existentials depend on gap size. Any formulation that tries to characterize non-constant-env existentials via a single temporal formula at one evaluation point is false on translation-homogeneous structures. The fix is to restructure the k>0 case of `existPart_succ_n1_bypass` to encode quantifier conditions via `generalExistPart_from_classical` (which uses the full 2-var NF precondition and IS proved) with a self-bootstrapping backward proof that establishes the 2-var NF eval from formula-encoded truth values.

### Research Integration

Report 09 (interval-splitting-mapping.md) established:
1. GeneralExistPartOrdered is FALSE at ALL depths via Z translation homogeneity
2. Both sorry sites (GeneralExistPart.lean:174, 207) are IMPOSSIBLE to prove
3. The existing KampBypass proof for k>0 is vacuously true from a false hypothesis (ih_general_exist has an unsatisfiable type)
4. k=0 infrastructure (~4400 lines) is UNCHANGED and sorry-free

**Planning-phase finding (extends report 09)**: BetweenZoneExistPart (Option K1) is also FALSE. On Z with constant predicates: env [0,2] has between-zone witness y=1 (existential TRUE), env [0,1] has no between-zone witness (existential FALSE). Formula evaluated at x=2 vs x=1 must differ, but Z's translation homogeneity forces temporal_truth Z n A = temporal_truth Z m A for all n, m and all formulas A. No temporal formula can distinguish these cases. The fundamental issue: characterizing a 2-free-variable condition (depending on both x and t) via a 1-free-variable formula (evaluated at x only) is not guaranteed by the Kamp theorem, which handles only 1-free-variable formulas.

### Prior Plan Reference

Plan v8 Phase 1 BLOCKED because GeneralExistPartOrdered is FALSE. The completed Phases 3-4 demonstrated that the ih_general_exist plumbing and enriched formula structure in KampBypass.lean work correctly -- the issue is solely that ih_general_exist has an unprovable type. The eq-zone case (false/false branch, lines 922-1060) is fully sorry-free and provides the correct template: it uses ih_exist (constant-env ExistPart) for quantifier conditions, bypassing ih_general_exist entirely. Key lesson: the k>0 Until/Since zones need the same approach -- use ih_exist (not ih_general_exist) for quantifier encoding by leveraging `generalExistPart_from_classical`.

### Roadmap Alignment

Advances: "Task 303 (k>0 depth induction via Rabinovich Section 5 Lemma 5.1) -> sorry-free completeness_discrete" -- the SOLE remaining blocker on the critical path.

## Goals & Non-Goals

**Goals**:
- Remove GeneralExistPartOrdered from the mutual induction (revert to 2-conjunct: CharPart + ExistPart)
- Remove ih_general_exist parameter from existPart_succ_n1_bypass
- Restructure the k>0 Until/Since zones in existPart_succ_n1_bypass to encode quantifier conditions using `generalExistPart_from_classical` (full 2-var NF precondition, already proved)
- Close the sorry at GeneralExistPart.lean:174 and :207 by deleting the false definitions
- Verify the completeness chain through completeness_discrete

**Non-Goals**:
- Modifying the k=0 case (existPart_succ_n1_bypass_k0 is sorry-free)
- Modifying the eq-zone case (false/false branch is sorry-free)
- Proving BetweenZoneExistPart (it is also FALSE)
- Modifying k=0 infrastructure (KampBypassCore/Until/Since, ~4400 lines)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Self-bootstrapping backward proof creates circularity: need 2-var NF to use generalExistPart_from_classical, need generalExistPart_from_classical to establish 2-var NF | H | H | The enriched formula encodes quantifier truth values as temporal conjuncts. Extracting x from Until gives truth values directly. Use these truth values to CONSTRUCT the 2-var NF eval (atoms from h_atom_agree, quantifiers from formula-encoded values). The construction is direct, not via generalExistPart_from_classical. |
| Removing ih_general_exist requires major restructuring of 500+ lines of k>0 proof | H | M | The restructuring follows the eq-zone template (lines 922-1060), which already handles quantifier conditions without ih_general_exist. The Until/Since zones need analogous treatment. Estimate 200-300 lines modified. |
| New quantifier encoding approach exceeds heartbeat limits | M | M | Factor into private helpers. Use set_option maxHeartbeats as needed. The eq-zone case demonstrates the pattern at 140 lines. |
| Backward proof direction fails: formula-encoded truth values don't suffice to reconstruct nf_eval | H | M | The enriched formula encodes ALL quantifier conditions (one conjunct per ssn : NF(k'+1, 3)). Combined with atom agreement, this fully determines nf_eval_nf at the 2-var level. If reconstruction fails, investigate whether additional conjuncts are needed in the enriched formula. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |

Phases within the same wave can execute in parallel.

### Phase 1: Remove GeneralExistPartOrdered and Simplify Mutual Induction [COMPLETED]

**Goal**: Delete the false GeneralExistPartOrdered definition, its sorry proofs, and revert kamp_mutual_induction to a 2-conjunct form (CharPart + ExistPart).

**Tasks**:
- [x] In GeneralExistPart.lean: delete `GeneralExistPartOrdered` abbrev (lines 57-80), `generalExistPartOrdered_zero` theorem (lines 121-182), and `generalExistPartOrdered_succ` theorem (lines 191-207). Keep `GeneralExistPart` abbrev and `generalExistPart_from_classical` (both are correct and proved).
- [x] In KampMutualInduction.lean: remove the `GeneralExistPart` import if no longer needed, or keep it for `generalExistPart_from_classical`. Change `kamp_mutual_induction` return type from `CharPart ∧ ExistPart ∧ GeneralExistPartOrdered` to `CharPart ∧ ExistPart`. Remove `ih_general_exist_ordered` from `existPart_succ` parameter and its corresponding argument in the call. Remove `generalExistPartOrdered_succ` / `generalExistPartOrdered_zero` from induction cases. *(deviation: altered -- also removed GeneralExistPart import entirely since no symbol from that file is needed)*
- [x] In KampMutualInduction.lean: update `existPart_succ` to remove `ih_general_exist_ordered` parameter. The call to `existPart_succ_n1_bypass` will temporarily fail (parameter removed in Phase 2). *(deviation: altered -- also removed ih_general_exist from KampBypass.lean and fixed NfCharFormula.lean call site so full build passes with sorry at Until/Since zones)*
- [x] Verify: `lake build GeneralExistPart` succeeds (no sorry in remaining code)

**Notes**: Also fixed `nf_2var_exist_formula_prior_filled` extractor from `.2.1` to `.2` for 2-conjunct form. Fixed NfCharFormula.lean call from 3 sorry args to 2 sorry args. Full `lake build` passes.

**Sorry budget**: 0 new sorry (deleting sorry code)

**Timing**: 1.5 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/GeneralExistPart.lean` -- delete false definitions
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampMutualInduction.lean` -- simplify to 2-conjunct

**Verification**:
- `lake build Bimodal.Metalogic.WeakCanonical.Kamp.GeneralExistPart` succeeds
- No sorry in GeneralExistPart.lean
- KampMutualInduction.lean may have temporary errors (expected, fixed in Phase 2)

---

### Phase 2: Remove ih_general_exist from existPart_succ_n1_bypass [COMPLETED]

**Goal**: Remove the ih_general_exist parameter from existPart_succ_n1_bypass and restructure the k>0 Until/Since/Eq zones to encode quantifier conditions without it.

**Approach**: The k>0 case (lines 493-1067) currently uses ih_general_exist in the Until zone (true/false, lines 592-773) and Since zone (false/true, lines 774-920) to build quant_conj. The eq zone (false/false, lines 921-1060) already uses ih_exist instead of ih_general_exist. The restructuring makes Until/Since zones follow the eq-zone pattern:

For the Until zone (t < x), each 3-var existential `exists y, nf_eval_nf M (k'+1) 3 [y,x,t] ssn` is encoded using `generalExistPart_from_classical` at arity 2 with env_nf = sub_nf. The key change: instead of using ge_formula/ge_correct (from ih_general_exist with weak preconditions), use gep_formula/gep_correct (from generalExistPart_from_classical with full 2-var NF precondition).

**Forward direction** (exists x -> temporal): We have nf_eval_nf M (k'+2) 2 [x,t] sub_nf. This satisfies the full 2-var NF precondition. So gep_correct applies directly: temporal truth at x iff existential.

**Backward direction** (temporal -> exists x): We extract x from Until. We need nf_eval_nf M (k'+2) 2 [x,t] sub_nf to use gep_correct. We build this from:
1. Atoms: h_atom_agree (from 1-var NF agreement + known order t < x)
2. Quantifiers: each ssn truth value is encoded in quant_conj. Extract from formula, use the truth value to produce the quantifier part directly via Iff.intro with the known Boolean value.

The crucial insight: we don't need gep_correct for the backward direction. The quant_conj already encodes the truth values. We BUILD nf_eval_nf by providing both the atom part (from h_atom_agree) and the quantifier part (from formula-extracted truth values). Once nf_eval_nf is established, we have the goal.

Wait -- the goal IS `exists x, nf_eval_nf M (k'+2) 2 [x,t] sub_nf`. We need to produce x and show nf_eval_nf. x comes from Until. nf_eval_nf requires atoms + quantifiers. Atoms: from agreement. Quantifiers: we need `(exists y, nf_eval [y,x,t] ssn) <-> sub_nf.2 ssn` for each ssn.

The formula-encoded truth values tell us whether `temporal_truth M x (gep_formula ssn)` holds. But gep_formula was built via classical satisfiability on M0. gep_formula = top iff M0 has the existential. We need: does M have the existential?

If gep_formula = top (M0 satisfiable): temporal_truth M x top = True. We need exists y in M. But M might not have the existential (Z counterexample). So this fails.

If gep_formula = bot (M0 unsatisfiable): temporal_truth M x bot = False. We need NOT exists y in M. If M unsatisfiable: correct. But M might be satisfiable. Again fails.

THE CIRCULARITY REMAINS. The formula (top/bot) does not carry enough information.

**Alternative approach**: Instead of top/bot, use ih_exist (ExistPart at depth k'+1 with constant env) to build formulas for each ssn. But ih_exist requires constant env, and the existential has non-constant env [x,t].

**Zone decomposition of each ssn**: For each ssn : NF(k'+1, 3), decompose `exists y, nf_eval [y,x,t] ssn` by y's zone:
- ssn says y=x: exists y=x with nf_eval [x,x,t] ssn. Since var0=var1, this simplifies to a constant-env condition at x plus conditions involving t. Use ih_exist for the constant-env part.
- ssn says y=t: similar.
- ssn says y>x: constant-env at x, use Until.
- ssn says y<t: constant-env at t, use Since.
- ssn says t<y<x: between-zone. THIS IS THE HARD CASE.
- ssn says x<y<t: mirror.

For the between-zone case, the existential is "exists y strictly between t and x with depth-(k'+1) conditions". At depth k'+1, this involves quantifier sub-conditions at depth k'. The sub-conditions are constant-env when y is the only variable (the sub-existential has env [y] -- constant), or involve [z,y,x,t] (4-var).

Actually, the depth-k'+1 NF eval at [y,x,t] has:
- Atom part: predicates at y,x,t + all pairwise orders (determined by zone + 1-var NFs)
- Quantifier part: for each chi : NF(k', 4), (exists z, nf_eval [z,y,x,t] chi) <-> ssn.2 chi

Each sub-existential `exists z, nf_eval [z,y,x,t] chi` has 3 free variables (y,x,t). This is even worse.

This recursive structure suggests we need induction on BOTH depth k AND some measure of the existential. Rabinovich uses induction on the bracket depth (number of witnesses), which decreases with each application of Lemma 5.1.

Given this deep structural issue, the correct implementation approach may be significantly more involved than initially estimated. Let me outline what IS achievable.

**Tasks**:
- [x] Remove ih_general_exist parameter from existPart_succ_n1_bypass signature *(completed in Phase 1)*
- [x] For the Until zone (true/false): restructure using inlined classical top/bot encoding. *(deviation: altered — used direct sub_nf.2 ssn truth values instead of generalExistPart_from_classical due to circular import. Forward direction (mpr) proved sorry-free. Backward direction (mp) sorry — requires V-EA negation closure.)*
- [x] For the Since zone (false/true): mirror of Until restructuring *(same approach as Until zone)*
- [x] Update existPart_succ in KampMutualInduction.lean to call existPart_succ_n1_bypass without ih_general_exist_ordered *(completed in Phase 1)*
- [x] Verify: `lake build KampBypass` succeeds — 2 sorry remain (backward directions only)

**Critical design question**: The backward direction needs to establish `nf_eval_nf M (k'+2) 2 [x,t] sub_nf` WITHOUT using generalExistPart_from_classical (circular). The approach: encode the quantifier truth values in the enriched formula (via ih_exist for constant-env sub-problems), extract them in the backward direction, and construct nf_eval_nf directly from atoms + extracted quantifier values.

For this to work, each 3-var existential `exists y, nf_eval [y,x,t] ssn` must be encoded as a temporal formula at x that is CORRECT (not just top/bot). The constant-env sub-problems (y=x, y=t, y>x, y<t) CAN be encoded correctly via ih_exist. The between-zone case (t<y<x, x<y<t) requires additional handling.

**Between-zone encoding via Since/Until**: "exists y in (t,x) with depth-0 atomic conditions" IS encodable via `char_pred(y) Since char(t)` at x (for the Until zone where t < x). At depth 0, this works because the atomic conditions on y are independent of the gap size -- the Since formula finds y if and only if a point with matching predicates exists between t and x. At depth k'+1, the between-zone involves quantifier conditions, which recurse to depth k'. By induction, the depth-k' conditions are encodable.

This IS the BetweenZoneExistPart idea, but now I realize the issue with the Z counterexample was wrong. Let me re-examine:

On Z with constant predicates: "exists y in (0,2) with pred(y)=true" IS true. "exists y in (0,1) with pred(y)=true" IS false. The Since formula `(pred Since char(t))` at x: at x=2, this asks "exists y<2 where pred holds and char(t) holds at some z<=y with pred holding from z to 2". Since pred is always true and char(t) is always true, this asks "exists y<2 and z<=y". Yes: y=1, z=0. So temporal_truth Z 2 (pred Since char(t)) = True. Good, matches the existential.

At x=1, "pred Since char(t)" asks "exists y<1 and z<=y with conditions". y=0, z=0 works (pred(0)=true, char(t) at 0=true). So temporal_truth Z 1 (pred Since char(t)) = True. But the existential "exists y in (0,1)" is False!

The Since formula is TOO WEAK: it finds witnesses OUTSIDE the interval (t,x). The formula `pred Since char(t)` finds y between z and x (where z satisfies char(t)), but doesn't constrain y to be in (t,x) specifically.

To constrain y to (t,x), we'd need a formula like `pred Since (char(t) AND NOT pred_before_t)` where pred_before_t captures "this is the SPECIFIC t we care about". But on Z with constant predicates, there's no formula that identifies t uniquely.

THIS is why Rabinovich uses a fundamentally different approach (bracket formulas + V-EA negation closure) rather than trying to express between-zone existentials directly.

Given this deep analysis, the correct implementation requires following Rabinovich's approach more faithfully. This is beyond the scope of a simple plan phase.

**Revised approach for Phase 2**: Add sorry at the between-zone quantifier encoding sites, with detailed blocker documentation. The non-between zones (y=x, y=t, y>x, y<t) CAN be handled via ih_exist. Document the between-zone case as requiring Rabinovich Lemma 5.1 negation closure.

**Sorry budget**: 2 sorry (one for Until between-zone quantifier encoding, one for Since mirror). This replaces the existing 2 sorry at GeneralExistPart.lean:174, 207 with sorry at more precise locations.

**Timing**: 2.5 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampBypass.lean` -- remove ih_general_exist, restructure k>0 zones
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampMutualInduction.lean` -- update call site

**Verification**:
- `lake build KampBypass` succeeds
- Sorry count: 2 (at precise between-zone sites, replacing 2 in GeneralExistPart.lean)

---

### Phase 3: Research and Design V-EA Negation Closure [COMPLETED]

**Goal**: Research Rabinovich's V-EA negation closure (Lemma 5.1) and design the Lean formalization needed to close the between-zone sorry from Phase 2.

**Context**: The between-zone existential "exists y in (t,x) with depth-k conditions on [y,x,t]" cannot be characterized by a single temporal formula evaluated at x. Rabinovich handles this via Lemma 5.1: the NEGATION of a bracket formula (exists-forall with multiple witnesses) reduces to a V-EA formula (disjunction of exists-forall formulas) on shorter intervals. The reduction uses:
1. INF formula: identify the nearest future point where a condition holds (using Prior-UZ/SZ = Dedekind completeness)
2. Interval splitting: at the INF point, split the interval into two sub-intervals
3. Sub-interval bracket formulas: each sub-interval has FEWER witnesses (induction terminates)

**Research Findings (from report 11_vea-negation-closure-design.md)**:

1. The sorry is structurally incompatible with the current 2-conjunct mutual induction (CharPart + ExistPart). ExistPart evaluates at ONE point with CONSTANT parent env; the between-zone case needs interval (t,x) characterization.

2. The single-witness case (our scenario) simplifies dramatically vs full Lemma 5.1: the negation of "exists y in (t,x) with P(y)" is simply "forall y in (t,x), NOT P(y)" — a 0-witness bracket formula (interval type constraint).

3. The POSITIVE direction can use enriched bracket formulas (BracketFormula with proper temporal point types from CharPart) translated via bracketBuildRight — infrastructure already exists.

4. The NEGATIVE direction for single-witness is trivially the universal quantifier over the interval, expressible as NOT (P Until T) restricted to before x.

5. The deep blocker: even with bracket semantics giving y, establishing the FULL nf_eval_nf at [y,x,t] requires sub-quantifier conditions at depth k' with non-constant 3-var env. This recurses to the same problem at lower depth, terminating only at depth 0 (where everything is purely atomic).

6. **Effort estimate**: 500-800 lines of new code across 4-8 implementation sessions (16-32 hours agent time). This is significantly more than the plan's original 2-hour estimate for Phase 4.

**Tasks**:
- [x] Study Rabinovich Lemma 5.1 in detail: identify exactly which steps need Lean formalization
- [x] Map the V-EA negation closure to the existing codebase: which infrastructure exists (VecEADecomp, ZoneBridge, KampForward) and what is missing
- [x] Design the Lean type signature for a negation-closure lemma that suffices for the between-zone case
- [x] Estimate effort for implementing the negation-closure lemma
- [x] Write a research report with the design and effort estimate
- [x] If the design shows the between-zone case is tractable (< 500 lines), proceed to Phase 4. Otherwise, document the blocker.

**Result**: The between-zone case requires 500-800 lines (NOT < 500). The sorry is a genuine architectural limitation. Phase 4 should be re-scoped as a multi-session implementation with incremental progress, not a single 2-hour phase.

**Sorry budget**: 0 (research only)

**Timing**: 2 hours (actual: ~2 hours)

**Depends on**: 2

**Files to modify**:
- `specs/303_k_gt_0_depth_induction/reports/11_vea-negation-closure-design.md` -- research report on V-EA negation closure design

**Verification**:
- [x] Research report written with clear design recommendation
- [x] Effort estimate for Phase 4 (500-800 lines, 4-8 sessions)

---

### Phase 4: Implement Enriched Bracket-Formula Encoding and Close Sorry [BLOCKED]

**Goal**: Replace the top/bot quant_conj encoding in the Until/Since zones with proper bracket-formula-based temporal formulas, then prove the backward direction using bracket semantics + NF transfer.

**Architecture** (from Phase 3 research report 11):
- Replace `gep_formula_until` (top/bot) with bracket-formula temporal translations using CharPart(k'+2) for point types
- For the positive case (sub_nf.2 ssn = true): build BracketFormula with point type from CharPart, translate via bracketBuildRight, extract bracket witness in backward direction
- For the negative case (sub_nf.2 ssn = false): use negation of bracket formula (single-witness negation = universal on interval)
- Resolve sub-quantifier conditions via depth induction (terminates at depth 0)

**Phase 4a Status** (dispatch 2026-06-17):
- [x] Added VecEATranslation import to KampBypass.lean (enables future bracket work)
- [x] Enriched Until backward (mp) direction: extracts x from Until, obtains x's 1-var NF type from compat_disj, decomposes proof obligation to `nf_eval_nf M (k'+2) 2 [x,t] sub_nf`
- [x] Enriched Since backward (mp) direction: mirror of Until enrichment
- [x] Preserved forward (mpr) direction: sorry-free (still uses top/bot trivially)
- [x] Documented precise blocking condition: establishing full 2-var NF at [x,t] from 1-var data + orders requires Prior compositionality at lower depth or bracket-formula interval characterization
- [x] Full `lake build` passes, sorry count unchanged (2 in KampBypass.lean)
- **Outcome**: Lateral progress (sorry not reduced but enriched with partial proof structure). The backward direction now has: x extracted, nf_x obtained, compat verified. Sorry is at the exact point of establishing quantifier conditions for the non-constant env [x,t].

**Phase 4b Status** (dispatch 2026-06-17):
- [x] Restructured Until/Since formula from trivial top/bot encoding to Prior composition transfer:
  - Until: `(char_kp1 nf_t₀) ∧ ((char_kp1 nf_x₀) U top)` — encodes exact 1-var NF types of M₀ witness
  - Since: `(char_kp1 nf_t₀) ∧ ((char_kp1 nf_x₀) S top)` — mirror
- [x] Backward direction (mp) now SORRY-FREE in KampBypass.lean: extracts char_kp1 at t and x, builds full NF agreement via nf_agreement_from_shared_nf, applies prior_2var_transfer_until/since
- [x] Forward direction (mpr) now SORRY-FREE in KampBypass.lean: projects 2-var agreement to 1-var via cross_1var_from_2var (first component) and prior_second_1var_from_2var (second component), then char_kp1_correct gives temporal truth
- [x] Added PriorComposition.lean import to KampBypass.lean
- [x] Added prior_second_1var_from_2var_until/since helpers to PriorComposition.lean (sorry-bearing; extracts second component 1-var NF from 2-var agreement on Prior structures)
- [x] Full `lake build` passes. KampBypass.lean: 0 sorry. PriorComposition.lean: 6 sorry (4 pre-existing + 2 new).
- **Outcome**: KampBypass.lean is sorry-free. The sorry is properly decomposed into PriorComposition.lean which contains focused Prior-specific mathematical primitives (exist_transfer_3var_nonconstenv, prior_second_1var_from_2var).

**Phase 4c Status** (dispatch 2026-06-17):
- [x] Added private `skipIdx` infrastructure to PriorComposition.lean: `skipIdx` definition, `skipIdx_injective`, `skipIdx_succ_comm`, `cons_comp_skipIdx` commutation, `cons_comp_skipIdx_zero`
- [x] Proved `nf_skipIdx_cross`: general cross-structure projection from (n+1)-var NF agreement to n-var NF agreement along any `skipIdx j`, by induction on depth k
- [x] Proved `cross_2nd_1var_from_2var`: extracts second-component 1-var NF agreement from 2-var NF agreement via `nf_skipIdx_cross` at j=0
- [x] Proved `prior_second_1var_from_2var_until` and `prior_second_1var_from_2var_since` as one-liner applications of `cross_2nd_1var_from_2var`
- [x] `lean_verify` confirms: only standard axioms (propext, Classical.choice, Quot.sound), no sorryAx
- [x] Full `lake build` passes (including KampBypass downstream). PriorComposition.lean: 4 sorry (reduced from 6; the 2 new sorry from Phase 4b are now resolved)
- **Key insight**: The comment claiming this "is NOT a consequence of 2-var agreement alone" was incorrect. The proof uses ONLY 2-var NF agreement (no Prior UZ/SZ properties needed). The h_UZ, h_SZ, h_order parameters are retained in the public signatures for API compatibility.
- **Outcome**: PriorComposition.lean sorry count reduced from 6 to 4. Phase 4c complete.

**Sub-Phases** (incremental):
- Phase 4a: Enrich backward direction with partial proof structure [COMPLETED - lateral]
- Phase 4b: Prior composition transfer — eliminate KampBypass sorry [COMPLETED]
- Phase 4c: Prove prior_second_1var_from_2var in PriorComposition.lean [COMPLETED — proved via nf_skipIdx_cross projection, ~100 lines]
- Phase 4d: Prove exist_transfer_3var_nonconstenv in PriorComposition.lean (~400-600 lines, Fraisse game argument) [BLOCKED — requires new infrastructure]

**Tasks**:
- [x] Restructure Until/Since formula encoding from top/bot to Prior composition transfer *(Phase 4b)*
- [x] Prove backward direction (mp) using prior_2var_transfer_until/since *(Phase 4b)*
- [x] Prove forward direction (mpr) using cross_1var_from_2var + prior_second_1var_from_2var *(Phase 4b)*
- [x] Verify: `lake build KampBypass` with 0 sorry *(Phase 4b — confirmed)*
- [x] Prove prior_second_1var_from_2var_until/since in PriorComposition.lean *(Phase 4c — proved via nf_skipIdx_cross: general cross-structure projection along skipIdx j, then specialized to j=0 for second-component extraction. ~100 lines of helpers + 2 one-liner theorem proofs. lean_verify confirms no sorryAx.)*
- [ ] Prove exist_transfer_3var_nonconstenv in PriorComposition.lean *(Phase 4d — BLOCKED: Fraisse game argument needed, see blocker below)*
- [ ] Verify: `lean_verify existPart_succ_n1_bypass` shows no sorryAx
- [ ] Verify: `lean_verify kamp_mutual_induction` shows no sorryAx
- [ ] Run full `lake build` for regression check

**BLOCKER** (Phase 4d):
- **What failed**: The `exist_transfer_3var_nonconstenv` theorem (lines 231, 239) and the K=0 base cases (lines 322, 399) in PriorComposition.lean cannot be proved with the current proof structure.
- **What was tried**: (1) Using c from hex_x as witness — fails because c<t' ↔ y<t cannot be established from depth-(K+1) 2-var at [y,x]/[c,x']. (2) Using c_K from hex_K — gives depth-K 3-var (atoms correct) but quantifier boost to depth K+1 creates circular dependency (needs depth-K 4-var which needs depth-(K+1) 3-var). (3) For K=0 base case: outside zones provable via cross_extend_bwd_1var + transitivity; between-zone (t<w<x) gives two partial witnesses (w'<x' from h_x, w''>t' from h_t) that cannot be combined without Prior axioms.
- **Why stuck**: Fundamental circularity in depth-boost argument. The circular structure: depth-(K+1) 3-var needs depth-K 4-var existential, which needs depth-(K+1) 3-var agreement (the goal). Breaking requires simultaneous induction on (depth, arity) = Fraisse game. The depth-0 terminus of this recursion (purely atomic between-zone) requires connecting NF predicates to temporal_truth via atomMap, then using Prior-UZ/SZ to find between-zone witnesses.
- **What is needed**: (A) Add atomMap + Prior UZ/SZ hypotheses to exist_transfer_3var_nonconstenv. (B) Implement Fraisse game lemma: from depth-(K+2) 1-var + depth-(K+1) 2-var + Prior, prove depth-(K+1) n-var existential transfer by strong induction on K with inner arity recursion. At depth 0: use char_kp1_correct to express NF types as temporal formulas, apply Prior-UZ on N to find first w-type point above t', bound by x' using h_x quantifier info. Estimated: 400-600 new lines.
- **Prohibited**: Do NOT use sorry, def X := True, or vacuous placeholder

**Sorry budget**: 0 (target: all sorry closed)

**Timing**: 8-16 hours across 4-8 implementation sessions (revised from 2 hours based on Phase 3 findings)

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampBypass.lean` -- replace top/bot with bracket formulas, close sorry
- Possibly `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/BracketBypass.lean` (new) -- enriched bracket construction at depth k'+1

**Verification**:
- `lake build` succeeds with 0 sorry in Kamp pipeline
- `lean_verify completeness_discrete` clean

**Risk**: Phase 3 research (Finding 7 in adversarial verification) identifies that sub-quantifier conditions at depth k' still face the non-constant-env problem recursively. The recursion terminates at depth 0, but the intermediate steps may require 3-var NF composition that was proved FALSE in NfComposition.lean. If this blocks, the sorry count will decrease from 2 to a smaller number but not 0. Escalation: re-scope as a new task with longer timeline.

## Testing & Validation

- [ ] After Phase 1: `lake build GeneralExistPart` succeeds; no sorry in remaining code
- [ ] After Phase 2: `lake build KampBypass` succeeds; sorry count = 2 (at between-zone sites only)
- [ ] After Phase 3: Research report written with actionable design
- [ ] After Phase 4: `lake build` succeeds; `lean_verify existPart_succ_n1_bypass` clean; `lean_verify completeness_discrete` clean

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/GeneralExistPart.lean` -- simplified (false definitions deleted)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampMutualInduction.lean` -- simplified to 2-conjunct
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampBypass.lean` -- restructured k>0 zones
- `specs/303_k_gt_0_depth_induction/plans/09_betweenzone-existpart-plan.md` -- this plan
- `specs/303_k_gt_0_depth_induction/reports/` -- V-EA negation closure research (Phase 3)

## Rollback/Contingency

1. **Phase 2 restructuring breaks k=0 case**: The k=0 case does not use ih_general_exist (it calls existPart_succ_n1_bypass_k0 directly). The restructuring only touches the `| succ k' =>` branch. Rollback: `git revert`.

2. **Phase 3 research shows between-zone case requires > 500 lines**: Document as a separate task. The Phase 2 sorry at precise between-zone sites is a strictly better state than the current sorry at GeneralExistPartOrdered (which is FALSE and blocks all progress). The between-zone sorry blocks only the non-constant-env quantifier conditions, not the entire mutual induction.

3. **Phase 4 implementation exceeds heartbeat limits**: Factor negation-closure proof into a separate file (e.g., VEANegationClosure.lean). Use set_option maxHeartbeats liberally.

4. **Any phase**: `git revert` to restore pre-attempt state. The task has 8 prior plan versions; do NOT re-attempt GeneralExistPartOrdered or BetweenZoneExistPart (both are FALSE).
