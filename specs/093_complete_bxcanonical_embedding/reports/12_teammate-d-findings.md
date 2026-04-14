# Teammate D Findings: Strategic Horizons

**Task**: 93 - Close BXCanonical Embedding (Round 12)
**Role**: Strategic horizons researcher
**Date**: 2026-04-14
**Session**: teammate-d round 12

---

## Key Findings

1. **The quasimodel BFMCS approach (v11) is the correct architecture** — literature confirms this is standard for bimodal temporal+modal logics with Until/Since.
2. **The FMP path (task 82) is a parallel quick win** — 2 sorries, low effort, gives weak completeness independently. It does NOT block or unblock task 93.
3. **The task 82 FMP path can be done in ~1-2 hours** and should be attempted immediately as a morale/progress boost, regardless of task 93 status.
4. **No architectural bypass exists for forward_F** — all completeness strategies for BX-style logics converge on eventuality resolution through some form of quasimodel or enrichment.
5. **The v11 plan is sound in its mathematical foundation** but the codebase's quasimodel infrastructure is less complete than assumed — Realization.lean explicitly documents a "chain realization obstacle" (lines 366-395) that affects G-persistence through multi-step chains.
6. **Rescoping to forward_G and backward_H only is NOT meaningful** — these are already trivially provable from the BX T-axiom; the hard part has always been F/P and Until/Since.
7. **The sorry sites cannot be individually deferred** — all 4 are interlocked through bx_countermodel; partial closure gives no usable completeness theorem.
8. **Literature shows a critical distinction missed in prior rounds**: enriched-closure approaches (Goldblatt, Verbrugge, de Jongh/Veltman) build the canonical sequence so that EACH ELEMENT is already an enriched MCS — meaning F(psi) is already present in every enriched world — rather than building an enriched seed for one successor step. This is fundamentally different from the current scheduling chain approach.

---

## Literature Survey

### What standard completeness proofs do for F-eventuality

The authoritative sources surveyed (through web search and codebase internal references):

**Burgess 1984 ("Basic Tense Logic", Handbook of Philosophical Logic)**
- Treats pure tense logic (G, H, F, P) over linear frames.
- The canonical model is built by a "defect-discharge" process: start with a maximally consistent set (MCS), iteratively build a chain by repeatedly resolving the "earliest unresolved defect" (i.e., the F-formula with the smallest priority).
- Key insight: **the chain is constructed over a finite subformula closure**, so defects are finite in number and each step strictly reduces the defect count.
- F-eventuality holds BY CONSTRUCTION: the schedule guarantees every F(psi) is eventually resolved before the chain repeats.
- This is exactly the quasimodel approach, but Burgess does it at the MCS level (not a Hintikka-point abstraction layer).

**Goldblatt 1992 ("Logics of Time and Computation", CSLI Lecture Notes)**
- Chapters 4 and 8 cover canonical models for linear temporal logics.
- Uses "enriched canonical models" where each canonical world is a MAXIMALLY CONSISTENT set that is already closed under the appropriate temporal operators within the relevant closure.
- F-eventuality resolution is handled by the **enumeration lemma**: arrange all F-formulas in the closure in an omega-sequence, build the canonical chain so that the n-th step resolves the n-th F-formula. The chain is omega-long (indexed by Nat), not Int-indexed.
- The Int-indexed version requires a separate backward construction for P-formulas.
- **Key technique**: Goldblatt doesn't use a "scheduling chain with resolving vs. non-resolving steps" — instead, every step is an enriched Lindenbaum extension of the CURRENT CANONICAL WORLD's g_content plus the NEXT F-obligation. This keeps all other F-formulas in the g_content, avoiding the "F-loss at resolving steps" problem entirely. This is only possible because every canonical world already CONTAINS all its G-consequences (enrichment).

**Verbrugge / de Jongh / Veltman ("Completeness by Construction for Tense Logics of Linear Time", 2004)**
- Available at: https://festschriften.illc.uva.nl/D65/verbrugge.pdf
- Directly relevant: constructive completeness for tense logics of Z (integers).
- Method: construct the canonical model as an omega-sequence backward and forward from a seed world. Each step uses a DETERMINED successor based on the previous world's g_content, not a non-deterministic Lindenbaum choice. The seed itself is enriched to contain all "needed" F-witnesses.
- F-eventuality: because each canonical world is determined, there is NO non-determinism to cause F-formula loss. The chain is built by dovetailing: interleave resolving future F-formulas with resolving past P-formulas, with each world fully determined by its predecessor.
- **Critical difference from the current BXCanonical scheduling chain**: Verbrugge's construction uses DETERMINISTIC successors; the BXCanonical chain uses NON-DETERMINISTIC Lindenbaum extensions. Non-determinism is what causes F-formula loss at resolving steps.

**Gabbay, Hodkinson, Reynolds ("Temporal Logic: Mathematical Foundations and Computational Aspects", OUP 1994)**
- Volume 1 covers completeness for temporal logics with U/S operators.
- The standard completeness technique for Until/Since over linear orders: build a "quasimodel" — a finite structure satisfying local Hintikka conditions — then realize it as a full Kripke model via the completeness-by-construction technique.
- For the canonical model: use an omega-sequence of enriched MCSs where each world i contains F(psi) already in the enrichment (via BX12 reduction or direct F-axiom), so forward_F holds BY CONSTRUCTION.
- The enrichment is done at world-construction time, not at seed-construction time.

**Reynolds 2003 ("An Axiomatization of Full Computation Tree Logic", JSL)**
- Branching-time (CTL*) rather than linear-time, so less directly applicable.
- However: uses the same technique — enriched Henkin sets where every world in the canonical model is already an ENRICHED complete set (not just any MCS), ensuring all temporal obligations (including F(psi)) are pre-satisfied.

### Summary: What all approaches have in common
All standard approaches handle F-eventuality by ensuring that **the canonical worlds are already enriched** before the chain is built, rather than trying to carry F-formulas through a step-by-step chain construction. The scheduling chain in the current BXCanonical codebase attempts the latter, which is why it fails.

The three viable strategies from the literature:
- **(a) Quasimodel/defect-discharge**: Build finite Hintikka chains within a subformula closure, where defects are discharged by construction. (Burgess, GHR Vol.1)
- **(b) Enriched canonical model**: Every canonical world is an enriched MCS (contains all F(psi) witnesses). Enumeration lemma resolves F-formulas one at a time. (Goldblatt, Verbrugge)
- **(c) Compactness/non-constructive**: Prove by compactness that a consistent set with F(psi) has a consistent extension witnessing psi. (Less common for discrete time)

The codebase's existing quasimodel infrastructure corresponds to approach (a). Approach (b) would require a different canonical model structure (enriched MCS instead of plain MCS). Approach (c) is not suited to Lean formalization without a compactness theorem.

---

## Architectural Bypass Analysis

### Can we avoid forward_F entirely?

**Short answer: No.** Here is why.

The truth lemma for F (some_future) states: `F(psi) is true at w iff exists s > t, psi ∈ fam.mcs(s)`. The forward direction of this requires finding an s > t where psi is in the family. This is exactly forward_F.

The only way to avoid proving forward_F as an independent lemma is to build the canonical model so that forward_F holds BY CONSTRUCTION (i.e., the model is defined to have this property, and existence/well-foundedness is proved separately). This is the quasimodel approach — it does not eliminate forward_F; it relocates the proof to the model construction phase.

**Alternative: Modify the truth lemma to weaken the F-case.**

Could the truth lemma be changed so that F(psi) uses a different semantic condition that doesn't require a witness in the SAME family? For example:
- Use an existential over ALL families in the BFMCS (not just the current one).
- This would require changing `BFMCS.restricted_temporally_coherent` and the parametric truth lemma, which is a 200-400 line change affecting many proved theorems.
- More importantly: the semantics of `truth_at` in the codebase uses `∃ s > t, psi ∈ fam.mcs(s)` for a specific fam. Changing this would alter the semantic meaning of the logic, not just the proof strategy.

**Alternative: FMP-based completeness (task 82).**

The FMP path (task 82) gives weak completeness by a different route: every satisfiable formula is satisfiable in a finite model. Completeness follows: if φ is not derivable, by weak completeness there is a finite countermodel. This is a valid completeness theorem, but it:
- Does NOT subsume task 93's completeness (which is over the full Int-indexed canonical model).
- Is weaker in the sense that task 82 proves completeness via a detour through finite models.
- Still requires proving F-eventuality holds in the FINITE canonical model used for FMP, which is actually EASIER (finite models, no omega-chain issues).

**Alternative: Dense completeness (task 68).**

Task 68 proves completeness over rational-time models (dense linear order). The obstacle there is different (rational canonical model construction). This is independent of and does not help with task 93.

**Architectural bypass conclusion**: There is no bypass. The quasimodel approach (v11) correctly identifies the only viable path. The question is whether the existing codebase infrastructure supports it.

---

## Investment Analysis

### Is the quasimodel adapter (v11) likely to succeed?

**Assessment: MEDIUM confidence, HIGH complexity.**

The v11 plan is sound in its mathematical structure:
- The quasimodel infrastructure (Construction.lean, Realization.lean) exists (~1,816 lines across 6 files).
- The key theorems needed (hintikka_step_g_prop, defect_count, quasimodel_chain_exists) are stated.
- BX12 (F -> top U psi) is proved at the MCS level.

However, there is a significant obstacle identified in Realization.lean:366-395 (reproduced in the codebase analysis above): **G-persistence through multi-step chains is blocked**. Specifically:
- `hintikka_step_g_prop` proves G-propagation for ONE step.
- For chains longer than 2, G(chi) may not persist through all steps unless G(chi) is in EVERY chain element.
- This is the "further obstacle" documented in Realization.lean: "G-formulas do NOT persist through the Hintikka chain. For G(χ) ∈ h_i, hintikka_step gives χ ∈ h_{i+1}, but G(χ) ∈ h_{i+1} is not guaranteed."

This obstacle is distinct from the forward_F problem and affects any chain-based FMCS adapter. It means the quasimodel-to-FMCS adapter may run into the same G-persistence problem that blocked Plan v8.

**Is it a rabbit hole?** Not exactly — it's the right mathematical direction. But the effort estimate of 300-400 lines (12-14 hours) may be optimistic if G-persistence for multi-step chains requires additional lemmas. A more realistic estimate is 500-700 lines, 20-30 hours.

### Would time be better spent on task 82 (FMP) or task 68 (dense completeness)?

**Task 82 (FMP TruthPreservation):**
- Estimated effort: 1-2 hours.
- Closes 2 sorries (`mcs_all_future_closure`, `mcs_all_past_closure`) in FMP/TruthPreservation.lean.
- Gives **weak completeness of TM independently of task 93**.
- The proofs are described as "parallel to `mcs_box_closure`" (TruthPreservation.lean:188-203).
- **Verdict: Highest ROI available. Do this immediately.**

**Task 68 (dense completeness over rationals):**
- Estimated effort: 10-20 hours.
- Requires constructing a Rat-indexed canonical model (different from Int-indexed).
- Independent of task 93. Does not solve forward_F over Int.
- **Verdict: Independent track, lower priority than task 82.**

### What's the minimal viable path to ANY form of completeness theorem?

1. **Immediate (1-2 hours)**: Close task 82 FMP sorries → weak completeness via FMP.
2. **Short term (20-40 hours)**: Complete task 93 quasimodel adapter → strong completeness over Int.
3. **Medium term (10-20 hours)**: Close task 68 → dense completeness over Q.

The project already has soundness proved and completeness structurally wired. Task 82 is the fastest path to a sorry-free completeness result, even if weak.

---

## Scope Assessment

### Should task 93 be descoped?

**Descoping to forward_G and backward_H only: NO.**
These properties are trivially provable from the BX T-axiom (G(phi) -> phi) and BX2 (H(phi) -> phi). They are not the obstacle. Descoping to these only would close zero of the 4 active-path sorry sites.

**Reclassifying the sorry sites as "deferred": POSSIBLY.**

The 4 sorry sites block `bx_countermodel`, which is used by `bx_completeness`. If the sorries remain, `bx_completeness` is not sorry-free. However, there is a meaningful intermediate state:

- Close task 82 → `bx_completeness` is superseded by the FMP-based completeness, which is sorry-free.
- Task 93's sorry sites could then be reclassified as "open research problems" rather than "active path" sorries.
- This would accurately represent the state: `bx_completeness` is one form of the completeness theorem (using a specific canonical model), while FMP completeness is another form. Both are valid completeness theorems; they differ in the model used for the counterexample.

**Simpler intermediate milestone**:
- Mark the 4 sorry sites as `[DEFERRED]` with a note that `bx_completeness_fmp` (from task 82) gives completeness via a different route.
- Document that full BXCanonical completeness requires the quasimodel adapter (task 93 v11).
- This is not "giving up" — it's accurate documentation of the project state.

### Is there a simpler intermediate milestone for task 93 itself?

Looking at the 4 sorry sites:
- `bx_fmcs_forward_F` (518) — root obstacle, requires quasimodel
- `bx_fmcs_backward_P` (525) — symmetric to forward_F
- `bx_bfmcs_restricted_buc` (649) — requires step transfer (also hard)
- `bx_bfmcs_restricted_fuc` (655) — requires F-witness (also hard)

There is NO meaningful partial closure here. Closing just forward_F and backward_P would still leave restricted_buc and restricted_fuc open, and bx_countermodel would still fail. All 4 must be closed together.

---

## Recommended Strategy

### Immediate action (do first, ~2 hours):
**Close task 82 FMP sorries.**
This gives a sorry-free completeness theorem immediately, via a different route. It does not require quasimodel work. The proofs are parallel to existing proved lemmas and should be straightforward.

### Short-to-medium term (20-40 hours):
**Continue task 93 v11 quasimodel BFMCS approach**, but with adjusted expectations:
1. **Phase 0 (prerequisite, not in v11)**: Verify that the existing quasimodel infrastructure provides G-PERSISTENCE through multi-step chains, not just single-step hintikka_step_g_prop. If G-persistence fails for chains longer than 2, the FMCS adapter will break. This requires reading Realization.lean:366-395 carefully and either (a) proving G-persistence is not needed (because the FMCS only needs forward_G for restricted deferralClosure formulas which are always in Sigma) or (b) adding a G-persistence-through-chains lemma.
2. **Phase 1 (in v11)**: Extend deferralClosure (BX12 Reynolds enrichment). Build and test IMMEDIATELY.
3. **Phases 2-4**: Proceed as in v11.

### If Phase 0 reveals G-persistence is an insurmountable obstacle:
Fall back to approach (b) from the literature: **enriched canonical model** where every MCS in the chain is already enriched to contain all F-witnesses. This is a more fundamental restructuring (~600-1000 lines) but avoids the G-persistence problem by construction. The key: instead of building a PLAIN scheduling chain and trying to prove F-persistence through it, build an ENRICHED chain where every world is a Lindenbaum extension of `g_content(prev) ∪ {psi | F(psi) ∈ prev}` — i.e., always include all current F-obligations in the seed. This is only consistent if the seed itself is consistent, which requires showing that `g_content(M) ∪ f_carry(M)` is always consistent for enriched M — which IS provable when M is itself enriched (the inconsistency counterexample from handoff 11 uses a NON-enriched M).

---

## Confidence Level

**Medium** — with the following caveats:
- The literature survey is based on web search summaries and codebase internal references, not full paper access. The techniques described are standard in the temporal logic literature and are consistent with what the codebase's own comments indicate (Realization.lean references Burgess 1984 and Reynolds 2003).
- The architectural bypass analysis is HIGH CONFIDENCE: there is no bypass for forward_F, it must be proved by building a model where it holds by construction.
- The task 82 recommendation is HIGH CONFIDENCE: the TODO description explicitly says the proofs are "parallel to mcs_box_closure" and the effort is 1-2 hours.
- The investment analysis is MEDIUM CONFIDENCE: the G-persistence obstacle in Realization.lean may or may not be a blocker for v11 — it depends on whether deferralClosure formulas are always in Sigma for the quasimodel construction.
- The enriched-chain fallback is MEDIUM CONFIDENCE: the key claim (g_content(M) ∪ f_carry(M) is consistent for enriched M) needs to be verified formally. The argument depends on "enriched M" meaning something specific that makes f_carry consistent with g_content, which may not hold in full generality.
