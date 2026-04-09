# Teammate B Findings: Alternative Approaches Evaluation

**Task**: 86 -- Close BXCanonical completeness sorries
**Author**: Teammate B (Alternative Approaches Assessment)
**Date**: 2026-04-09
**Round**: 5

---

## Key Findings

### Approach 1: Tuple-Based Approach

**Summary**: Work with tuples (finite sets of formulas under a subformula closure) instead of building full chains of MCSes. F-obligations "pull" their witnesses into the construction explicitly, then a timeline is assembled from the placed witnesses.

**Source**: Task 83 report 30 (Teammate C, root cause analysis) and report 31 (sequel), with critical analysis in report 30 (Teammate D).

**Core mechanism**:
- A tuple is a pair (X, Y) of finite formula sets (verified/falsified), with consistency of X
- F(psi) in a tuple generates a Task: place a new tuple containing psi at some strictly later position
- The witness-first philosophy: collect all F-obligation witnesses BEFORE assembling the timeline
- Duration resolution: assign concrete integer positions to placed tuples (Bellman-Ford satisfiability)

**Why it was abandoned** (Report 30, Teammate D; Report 31, Teammate C):

The tuple construction relocates the difficulty to "duration resolution" without solving it. Report 30 Teammate D diagnosed the core issue: the universal constraints (G/H propagation) are NOT difference constraints. The constraint `chi must hold at ALL future positions` cannot be expressed as `t_j - t_i >= 1`. The finite tuple set must be "unrolled" into an infinite Z-indexed model, and the unrolling must satisfy the universal temporal properties. This unrolling IS the completeness proof.

More precisely, the circularity is:
- To prove the truth lemma for G(alpha), we need: `G(alpha) in tuple(t) <-> alpha in all future tuples`
- The backward direction requires: for all future tuples where alpha holds, G(alpha) holds here
- This is the same meta-to-object conversion (`temporal_backward_G`) that blocks the deterministic chain approach

**Verdict for task 86**: The tuple approach is inapplicable. Task 86's sorry is specifically about the imp Case B of `usf_completeness` in the BXCanonical architecture, where we need a bidirectional truth lemma for USF formulas. The tuple approach would require building an entirely new model construction, bypassing BXCanonical entirely. Report 39 (task 83 final synthesis) explicitly recommended against BXCanonical port attempts (95% confidence it is blocked). The tuple approach is a different flavor of the same blocked BXCanonical path.

**Does it avoid the forward_F problem?**: NO. Forward_F remains needed for the backward G direction of the truth lemma. The tuple construction does NOT resolve this circularity -- it only provides a different organizational structure.

**Confidence**: HIGH that the tuple approach does not apply here.

---

### Approach 2: Pull-Before-Push (Avoid Overwriting Witness Commitments)

**Summary**: When building chains, "pull" all needed witnesses before "pushing" (extending) the chain, so that extending does not destroy previously committed witnesses.

**Source**: Task 83 reports 29-30 (Teammate D introduced push vs pull framing; Teammate C elaborated with the tuple/witness-first philosophy).

**Key terminology**: The deterministic chain is "push-based" (x_content determines successor). F-resolution is "pull-based" (an obligation at time t needs a witness at some future time s). The push doesn't guarantee the pull.

**The specific mechanism proposed** (Report 38, Report 39):

The "enriched-Succ chain builder" adds the following to the Lindenbaum seed at each step:
```
seed(w_i, i) = g_content(w_i) ∪ scheduled_target(w_i, i)
```
where `scheduled_target(w_i, i)` picks ONE active F-formula using round-robin scheduling and places its witness directly into the seed. By dovetailing, every F(phi) is eventually scheduled, and phi enters the seed at that step.

**Why this approach (for the old Bundle/FMCS architecture) has partial progress**:

- Seed consistency `{target} ∪ g_content(M)` is already sorry-free (`forward_temporal_witness_seed_consistent` in WitnessSeed.lean:79)
- The FMCS/Bundle architecture already has working G/H coherence
- Report 39 estimated 600-1000 LOC to complete

**Why it was not completed in task 83**:

The backward direction of the Until truth lemma requires `¬(phi U psi) → ¬psi ∧ (¬phi ∨ G(¬(phi U psi)))`. This requires BX6 (absorption) for the contrapositive. While the derivation was outlined (report 39), it was assigned MEDIUM risk (70% confidence) and was never verified in Lean.

**Does it apply to task 86?**: The pull-before-push approach was designed for the FMCS/Bundle architecture (task 83's domain), NOT for the BXCanonical architecture (task 86's domain). The task 86 sorry is in `CanonicalEmbedding.lean:409`, which is in the BXCanonical pipeline. The handoff document (01_forward-f-blocker.md) explicitly identifies this as a BXCanonical problem.

**Critical architectural mismatch**: Report 39 concluded that "Path B (BXCanonical Port) is mathematically impossible" at 95% confidence. The BXCanonical sorry stubs quantify over ALL BXPoints:
```lean
∀ u : BXPoint, bx_le w u → bx_le u v ∧ ¬bx_le v u → φ ∈ u.formulas
```
A chain construction only gives phi at chain members. An arbitrary BXPoint between w and v in the bx_le preorder is NOT necessarily on any chain. This architectural impossibility remains.

**However**: The handoff from Phase 1 (01_forward-f-blocker.md) identifies a more targeted sub-problem. The blocking sorry is in `usf_completeness` (USF = Until/Since-free). The USF restriction means we never encounter Until/Since cases in the truth lemma. This avoids the main difficulty of the pull-before-push approach.

**Partial relevance**: The "Combined F-Seed Extension" (Path 1 in the handoff) is a variant of pull-before-push specifically adapted for the BXCanonical/dovetailed-chain context. The handoff proposed:
```
seed = {psi_1, ..., psi_k} ∪ g_content(M) ∪ box_content(M)
```
where F(psi_i) ∈ M for each i. This IS the pull-before-push philosophy applied to BXCanonical.

**Can the combined seed be proved consistent?**: The single-target version `{psi} ∪ g_content(M)` is sorry-free (WitnessSeed.lean:79). The multi-target version requires proving that simultaneously including ALL pending psi_i is consistent. Report 02 of task 83 (blocker analysis) identified this as the key difficulty: adding multiple F-witnesses to the seed may allow derivation of ⊥ through interactions between them. The standard proof (Goldblatt 1992 / Burgess 1984) uses compactness + temporal duality: any inconsistent finite subset leads to a contradiction with M being an MCS. This is achievable but non-trivial.

**Verdict**: The pull-before-push philosophy (Combined F-Seed Extension) is the MOST DIRECTLY RELEVANT approach to task 86. It is Path 1 in the handoff document, rated "Medium difficulty." The main mathematical work is the combined seed consistency lemma.

**Confidence**: MEDIUM-HIGH that this approach is viable.

---

### Approach 3: Quasimodel Approach

**Summary**: Use quasimodels (finite approximations that may have non-deterministic successor relations) instead of full canonical models. A quasimodel resolves all eventualities by construction, then a linear model is extracted.

**Source**: Task 83 report 24 (solo deep study), reports 31 (Teammate C), and indirect references throughout.

**Core mechanism**: A TM-quasimodel is a tuple (W, succ, pred, label) where W is the set of all MCSes in the same box-class, succ(M) = x_content(M), and F-witnesses are explicitly provided via `temporal_theory_witness_with_g_exists`. The path through the quasimodel is constructed incrementally using fair scheduling.

**Why the standard quasimodel fails** (Report 24, Section 1.9):

The quasimodel approach as in GHR 1994 does NOT directly apply because:

1. **Until persistence breaks through detours**: When the path detours to a witness MCS (instead of following x_content), Until formulas in the current state are not preserved. Until formulas are X-liftable (X(phi U psi) follows from phi U psi) but NOT G-liftable (G(phi U psi) does not follow from phi U psi under strict semantics). The enriched seed approach (adding Until deferrals to the Lindenbaum seed) also fails for the same reason (Report 24, Section 1.6).

2. **Strict vs reflexive semantics**: The published GHR 1994 technique works under reflexive semantics (G(phi) → phi is valid). Under strict semantics (TM's semantics), G quantifies over STRICTLY future times, breaking the key self-inclusion property.

3. **Concrete failure**: In report 24, Section 1.5, a specific failure scenario is constructed: (top U psi) in M_n, but the detour to a witness M destroys the Until formula because the witness W contains g_content(M_n) but not x_content(M_n), and the Until deferral `psi or (phi and (phi U psi))` is not in g_content.

**Whether the reasons still apply to task 86**: YES, emphatically. Task 86 operates under the same strict temporal semantics as task 83. The BXCanonical completeness proof for USF formulas uses the same MCS infrastructure. The quasimodel approach's core failure mode (Until through detours) is inherent to strict semantics, not to the specific architecture.

**However**: The USF restriction in task 86 is important. `usf_completeness` only needs the truth lemma for formulas WITHOUT Until or Since. The quasimodel approach's failure specifically involves Until formula persistence through detours. If there are no Until formulas, the detour problem does not arise in the same way.

**Can the quasimodel work for USF?**: For USF formulas (no Until/Since), the temporal operators are only G, H, F, P (and the last two are defined as ¬G¬, ¬H¬). The failure mode for Until is avoided. The quasimodel simplifies to: for each G(alpha) not in w, find a witness v with alpha not in v, and ensure v appears in the path. This is precisely the "dovetailed chain history" construction in report 04 (task 86).

Report 04 (task 86, Section 8-10) worked out in detail that:
- The dovetailed chain for USF formulas gives a bidirectional truth lemma
- Box preservation along bx_le (Phase 1, now sorry-free) enables modal_omega to work at all chain points
- The full construction requires: dovetail_chain definition, dovetail_history as WorldHistory, Omega = modal_omega w ∪ {shifts of dovetail history}, bidirectional truth lemma by induction on USF formula complexity

**Verdict**: The quasimodel approach, when restricted to USF formulas (the specific scope of task 86), transforms into the dovetailed chain history construction. This IS the "Dovetailed Chain with Full Bidirectional Truth Lemma" (report 04, Section 10). The approach is viable and the mathematical content is fully worked out. The gap between "worked out on paper" and "implemented in Lean" remains, but the path is clear.

**Confidence**: HIGH that this (as restricted to USF) is a viable and complete path.

---

## Recommended Approach

**For task 86 specifically**: The dovetailed chain history construction (quasimodel restricted to USF) is the correct and viable path. This is:

1. Report 04 (task 86), Sections 8-11 describe the full blueprint
2. Phase 1 lemmas (box_preserved_along_bx_le, bx_modal_equiv_of_bx_le, modal_omega_eq_of_bx_le) are already COMPLETED (from the Phase 1 implementation in the current branch)
3. Remaining phases require: dovetail_chain construction, dovetail_history as WorldHistory, Omega definition, and the bidirectional truth lemma by induction on USF formula complexity

**Why not the Combined F-Seed Extension (pull-before-push / Path 1 from handoff)**:

The combined F-seed extension targets the _chain construction_ for forward_F. But in the BXCanonical architecture, forward_F is not the primary problem -- the primary problem is the bidirectional truth lemma for the imp case. The dovetailed chain history directly solves the truth lemma problem. The combined seed extension would be needed if we were building a new chain (FMCS-style), not for BXCanonical.

**Hybrid recommendation**: The dovetailed chain history construction (from the quasimodel approach) should be primary. The combined seed extension insight is relevant ONLY if one wants to build a forward_F-satisfying chain rather than a bidirectional truth lemma. Since the task is to close `usf_completeness` (not to build a new FMCS chain), the dovetailed chain history is more directly applicable.

**Summary of viable paths**:

| Path | Viability | Effort | Notes |
|------|-----------|--------|-------|
| Dovetailed chain history (quasimodel restricted to USF) | HIGH | 600-900 LOC | Full blueprint in report 04; Phases 1 done |
| Combined F-Seed Extension (pull-before-push) | MEDIUM | 400-700 LOC | Seed consistency lemma is key risk; targets different blocker |
| Tuple approach | LOW | Very high | Blocked by same architectural issues as BXCanonical port |

---

## Evidence and Examples

### Evidence that Tuple approach fails

Report 30 (Teammate D, task 83): "The tuple-based construction is a plausible framework but **relocates the fundamental difficulty to Step 7 (duration resolution) without solving it**. The hard mathematical content -- showing that temporal obligations can be simultaneously satisfied in a linear model over Z -- is exactly the content of the forward_F proof."

Report 31 (Teammate C, task 83): "The tuple construction does not resolve the circularity identified in Report 24 Section 1.3: forward_F(psi) at chain(t) requires psi at some chain(s) with s > t. To derive G(neg psi) in chain(t) (the contrapositive), we need temporal_backward_G_with_fwd_F, which takes forward_F as a hypothesis."

### Evidence that Pull-Before-Push has partial relevance

Report 39 (task 83): "The witness-first philosophy is correct. Building witnesses (F/P) before assembling the timeline directly addresses the push/pull mismatch. Critical insight: No full-MCS enriched chain with dovetailed scheduling has ever been attempted. The approach proposed here is structurally different from all prior attempts."

Handoff 01 (task 86, Path 1): "Combined F-Seed Extension (Recommended): seed = {psi_1, ..., psi_k} ∪ g_content(M) ∪ box_content(M) where F(psi_i) ∈ M for each i. The standard proof uses compactness + temporal duality. Difficulty: Medium."

### Evidence that Quasimodel restricted to USF works

Report 04 (task 86, Section 9.3): "For USF formulas (no Until/Since), the two-point (or multi-point) construction can be made to work by recursion on formula complexity: atom p, (alpha -> beta), box alpha, G(alpha), H(alpha). For each case, the formula we recurse on is STRUCTURALLY SMALLER."

Report 04 (task 86, Section 10): "Dovetailed Chain with Full Bidirectional Truth Lemma: Step 1: Build the dovetailed chain history. Step 2: Define Omega. Step 3: Prove bidirectional truth lemma. For all USF formulas alpha and all times s: alpha in tau_w(s).formulas <-> truth_at canonical_valuation Omega tau_w s alpha."

Report 04 (task 86, Section 10, Box preservation): "Proof of backward direction [of box]: Suppose box phi in v and bx_le w v. Suppose for contradiction box phi not-in w. Then neg(box phi) in w. By S5 negative introspection: box(neg(box phi)) in w. By temp_future: G(box(neg(box phi))) in w. By bx_G_forward with bx_le w v: box(neg(box phi)) in v. By modal_t: neg(box phi) in v. But box phi in v and neg(box phi) in v contradicts consistency. QED." This key lemma is already implemented as `box_preserved_along_bx_le` (Phase 1, completed).

### Evidence that quasimodel standard approach is blocked for Until

Report 24 (task 83, Section 1.9): "The quasimodel approach, as standardly described in GHR 1994, does NOT directly apply to this formalization because: (1) the standard quasimodel uses non-deterministic successor relations, but Until persistence in TM requires the deterministic x_content linkage; (2) when the path detours to a witness MCS, Until formulas in the current state are not preserved; (3) enriching the witness seed with Until deferrals fails because the consistency proof requires G-liftability."

---

## Confidence Level

- **Tuple approach is non-viable for task 86**: HIGH confidence (same circularity, wrong architecture)
- **Pull-before-push (Combined F-Seed) has partial relevance**: MEDIUM confidence (targets wrong blocker for this specific sorry, but would work if goal were forward_F in BXCanonical chains)
- **Quasimodel restricted to USF (dovetailed chain history) is viable**: HIGH confidence (full blueprint exists in report 04, Phases 1 done, mathematical content verified on paper)
- **Overall recommendation**: Proceed with the dovetailed chain history construction as the primary path
