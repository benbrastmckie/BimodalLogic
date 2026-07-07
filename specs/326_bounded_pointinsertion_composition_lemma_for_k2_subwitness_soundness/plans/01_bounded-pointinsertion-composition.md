# Implementation Plan: Bounded Point-Insertion Composition Lemma for k=2 Sub-Witness Soundness

- **Task**: 326 - Bounded point-insertion composition lemma for k=2 sub-witness soundness
- **Status**: [NOT STARTED]
- **Effort**: 6-12 hours
- **Dependencies**: None (parent task 321 resumes via `/revise 321` after this lands)
- **Research Inputs**:
  - reports/01_proof-strategy.md (PROVABLE-WITH-CAVEAT; pin-slot route)
  - specs/321_.../reports/03_divergence-audit-joint-channel.md (audit — REFUTED route, context only)
  - specs/321_.../reports/04_spawn-analysis.md (spawn rationale, context only)
- **Artifacts**: plans/01_bounded-pointinsertion-composition.md (this file)
- **Standards**:
  - .claude/context/formats/plan-format.md
  - .claude/rules/artifact-formats.md
  - .claude/rules/state-management.md
  - .claude/rules/git-workflow.md
  - .claude/extensions/lean/context/contracts/reference-grounding.md (H3 Tier 1)
  - .claude/extensions/lean/context/contracts/anti-analysis.md (H2)
- **Type**: lean4

## Overview

Deliver ONE standalone, machine-verified, purely additive Lean 4 lemma that produces the BOUNDED
sub-anchor bundle `∃ x1, x < x1 ∧ x1 < t ∧ hanchor(charK at x1) ∧ hbelow` — exactly the
`(x1, hxx1, hx1t, hanchor, hbelow)` bundle that the already-landed
`kvE_subBracket2V_sound_of_parts` (`NfMultiAnchorBridge.lean:7449`) consumes to close task 321
Phase 10 (Stage C soundness). The lemma is stated against the outer carrier's **pin-slot extract**
(and an order-preserving outer extraction), NOT the `fChainPred @ u`-only data — this scope
correction is the load-bearing finding of the research (report 01 §Recommendations, lines 204-207).

**The winning route (build around THIS, not the audit's refuted route).** The outer carrier's PIN
SLOTS (`kvE_pinDisjunct` `:5374-5379` → `⟨charK (nfk_projFresh σ)⟩`) are LEFT outer-bracket
witnesses (`slotsFor lL`, `:8236`/`:8244`), pinned strictly in `(x, w_outer) ⊂ (x, t)` by bracket
monotonicity. They supply `hanchor` + the bounded `hx1t` (`x1 < t`) DIRECTLY from the outer
`.holds` data — with NO reverse Cor 5.4, NO splice restructure, NO `HasAttainedINF` gating. The
boundedness rides the pin's STRUCTURAL slot position (left of the `ptW` split), satisfying the GO
litmus (never an `x1 < e_i` relative-position literal). The audit's proposed
`neg_2var_vec_ea` / `neg_interval_formula` point-insertion route is REFUTED as inapplicable
(report 01 H3 table lines 108-109, H4 table line 177) — do NOT plan or implement around it.

**Definition of done.** The new lemma is green under a scoped `lake build`, axiom-clean
(`#print axioms` shows only `[propext, Classical.choice, Quot.sound]`), carries NO `sorry` on any
committed live path, and type-checks against the actual `kvE_subBracket2V_sound_of_parts` consumer
signature. On completion, task 321 resumes via `/revise 321` (v5, re-pointing Phase 10 at this
lemma) then `/orchestrate 321`.

### Source-to-Implementation Mapping (H3 Tier 1 — Rabinovich 2014)

Literature: `/home/benjamin/Projects/Literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.md`.

| Source | Prop/Location | Lean Identifier (consumed / produced) | Type Signature (intent) | Status |
|--------|---------------|----------------------------------------|--------------------------|--------|
| Rabinovich 2014 | Lemma 5.1, md:169-171 | pin-slot bound → `hx1t` (`x1 < t`) via structural split at `ptW` | shared-endpoint point-insertion: witness bounded by its slot position, not a formula literal | pending |
| Rabinovich 2014 | Cor 5.4, md:154-157 | (SIDESTEPPED) reverse `fChainPred → .holds` (`EANegation.lean:1249` `sorry`) | NOT consumed — pin route avoids the reverse direction entirely | n/a (avoided) |
| Rabinovich 2014 | Lemma 5.3, md:137-152 | `kvE_subChain2V` `S_XU.permutations` structure → `hbelow` coverage | per-disjunct arrangement: each `χ ∈ S_XU` heads some permutation | pending |
| (project) | `NfMultiAnchorBridge.lean:7449-7504` | `kvE_subBracket2V_sound_of_parts` (CONSUMER) | `(x1,hxx1,hx1t,hanchor,hbelow,hgate) → ∃x1', nf_eval_nf [x1',w,x,t] σ` | do-not-edit; feed it |
| (project) | `:5374-5379` | `kvE_pinDisjunct` → produces `hanchor` | `[⟨charK (nfk_projFresh σ)⟩]` bounded left witness | pending |
| (project) | `EANegation.lean:616`/`583` | `fChainFrom_step`/`_base` → produces `hbelow` below-witnesses | `fChainPred @ u ⟹ (pointTypes 0)@u = ⟨charBase χ⟩@u` | pending |

### Preserved Assets

The following work is complete and MUST NOT regress. The new lemma is PURELY ADDITIVE; none of
these are edited.

| Component | File | Status | Notes |
|-----------|------|--------|-------|
| VVecEA2 block (`kvE_subChain2V`, `kvE_subBracket2V`, `_sound`/`_complete`/`_nonvacuous`, `kvE_subBracket2V_sound_of_parts`, `bracketFromLists3`) | NfMultiAnchorBridge.lean | landed (task 325) | byte-identical DO-NOT-EDIT; the consumer at `:7449` |
| `kvE_pinDisjunct` | NfMultiAnchorBridge.lean:5374 | landed | byte-identical; the pin-slot source |
| `kvE2_body` / `bracketEndChar_kvE2` | NfMultiAnchorBridge.lean | landed (321-owned) | byte-identical; task 326 does NOT touch |
| `BracketCarrierCorrectVPrior`, `ExistProviders` | NfMultiAnchorBridge.lean | landed | byte-identical |
| EANegation forward-stack (`bracket_implies_fChainPred:660`, `fChainFrom_base/_step:583/616`) | EANegation.lean | landed | byte-identical; consume, do not edit |
| EANegation reverse sorry (`:1090`, `:1249`) | EANegation.lean | documented-unprovable | do NOT consume; pin route avoids it |
| EANegation Closure landed assets (`neg_2var_vec_ea`, `neg_interval_formula`, `first_occ_tp`) | EANegationClosure.lean | landed | do NOT consume for this task (refuted route) |
| F1-F4 verdict records | (task 321 artifacts) | landed | do not re-litigate |

## Postmortem Constraints

Binding rules for all implementation dispatches. Derived from the task-320/324/325/321-v4-P10
failure history and the report 01 / report 03 findings.

**Do NOT**:
- Do NOT recover the anchor `x1` from the flat `fChainPred @ u`'s internal chain point `ptX1`.
  It is genuinely UNBOUNDED above (`fChainFrom_base:583` is `∃s>x` with no cap; the endpoint `z`
  is dropped from the formula). The transitivity hope `u < w < t ⟹ x1 < t` is a TRAP (report 01
  §Make-or-Break, H4 table line 172-173).
- Do NOT plan or implement around `neg_2var_vec_ea` / `neg_interval_formula` /
  `HasAttainedINF.first_occ_tp`. These are negation-closure lemmas, not chain-point bounders; the
  `first_occ_tp` occurrence precondition is exactly the fact the flat extract lacks (report 01 H3
  lines 107-109). This is the REFUTED audit route.
- Do NOT carry boundedness via a single-point relative-position formula literal (`x1 < e_i`)
  between independently-bound variables. That literal form is the F4 flattening relapse that tasks
  320/324/325/321-v4-P10 all hit. Boundedness MUST ride the pin's slot position / structural split.
  LITMUS: if `x1 < t` is ever produced by asserting a formula literal rather than by the pin's
  bracket-monotonicity position, STOP — that is the relapse.
- Do NOT edit any DO-NOT-EDIT asset (see Preserved Assets). The new lemma is additive-only.
- Do NOT provider-side pin (Amendment F3 remains binding).
- Do NOT introduce a THIRD anchor. Two anchors `{x, t}` fixed at 2 (G4); `w_outer` stays a bracket
  WITNESS, never a third anchor.
- Do NOT close any proof step with `simp` / `omega` / `aesop` as the load-bearing closer (G-rules).
- Do NOT land a live-path `sorry` as a "division point". If Phase 4.2 (`hbelow` assembly) cannot be
  completed, the ONLY sanctioned outcome is to report NOT-PROVABLE-AS-SPEC with a precise residual
  (see Rollback/Contingency). This task has NO strategic-sorry escape valve.
- Do NOT alter the shape of the `kvE_subChain2V` splice or require a new joint-channel shape —
  that would reopen the task-321 completeness risk (report 03 Determination 2). Consume the existing
  flat splice extract AS-IS.

**MUST preserve**:
- The task-325 VVecEA2 block byte-identical (completeness closes via `kvE_subBracket2V_complete`;
  it stays closed only if this lemma consumes the existing splice extract unchanged).
- All EANegation forward-stack assets and F1-F4 verdict records.
- The counterexample-rejection behavior (F4 Z-counterexample stays REJECTED; the new lemma fires
  only WHEN `.holds` holds — rejection lives in `.holds`, unchanged — report 01 H4 line 179).

**Design decisions are SETTLED** (do not re-open without a concrete machine counterexample):
- The anchor comes from the PIN SLOT (`kvE_pinDisjunct`), not the fChainPred internal `ptX1`.
  Verified High-confidence in report 01 (H4 table lines 174-176).
- The reverse Cor 5.4 direction is unprovable and is SIDESTEPPED, not attacked.
- The lemma must be STATED against the pin-slot extract + order-preserving outer extraction, not
  `fChainPred @ u`-only data. Task 321's v5 `/revise` threads σ's pin witnesses into Phase-10
  wiring; that threading is task 321's job, NOT task 326's. Task 326 delivers only the standalone
  lemma with the correct signature.

## Goals & Non-Goals

- **Goals**:
  - Deliver one additive lemma (name at implementer's discretion, e.g.
    `kvE_sub2V_bounded_anchor_of_outer`) producing the `(x1, hxx1, hx1t, hanchor, hbelow)` bundle
    from the outer bracket's soundness-side `.holds` data via the pin-slot route.
  - Establish `x1 < t` STRUCTURALLY (Rabinovich Lemma 5.1 shared-endpoint split at the `ptW` slot),
    never from the unbounded chain.
  - Lemma green + axiom-clean `[propext, Classical.choice, Quot.sound]` + no live-path sorry.
  - Type-check the bundle against the real `kvE_subBracket2V_sound_of_parts` (`:7449`) signature.
- **Non-Goals**:
  - NOT wiring task 321 Phase 10 (that is task 321's v5 `/revise` job).
  - NOT touching completeness (Phases 12-14 of task 321) — it closes via
    `kvE_subBracket2V_complete`, unaffected by this additive soundness lemma.
  - NOT editing any DO-NOT-EDIT asset, the splice shape, or the carrier.
  - NOT reintroducing the reverse Cor 5.4 direction or the refuted negation-closure route.

## Risks & Mitigations

- **Risk (HIGHEST, drives the CAVEAT): Phase 4.2 `hbelow` assembly fails.** Two independent
  sub-risks (report 01 lines 151-158): (a) the `List.permutations` head-coverage helper (every
  `χ ∈ S_XU` heads some permutation) may not exist locally and must be proved; (b) the
  order-preserving extraction (Phase 1) must place ALL fChainPred F_0 points strictly below the
  chosen pin `q`, which depends on σ-block contiguity (`ptSub σ ++ pinSlots σ`, `:8236`) surviving
  the `flatMap` and being threaded through monotone indexing.
  **Mitigation**: Isolate the pure `List.permutations` head-coverage helper into its own Phase 4.1
  (independent file `EANegationClosure.lean`, provable/parallel early — also satisfies the H2
  first-sorry-free-lemma bar). Keep the σ-block contiguity/monotone-ordering burden in Phase 1 so
  Phase 4.2 only consumes finished order facts. **Fallback if 4.2 still fails**: report
  NOT-PROVABLE-AS-SPEC with the precise residual (which sub-step — perm coverage vs. monotone
  placement — blocked, and the exact goal state). Do NOT land a live-path sorry. This reopens the
  reverse-Cor-5.4 wall and flips the verdict; escalate rather than relapse.
- **Risk: F4 flattening relapse.** An implementer under pressure re-derives `x1 < t` from a formula
  literal. **Mitigation**: the Postmortem LITMUS is checked at every phase that lands a proof step;
  `hx1t` must trace to bracket monotonicity of the pin's slot position (Phase 2), never a literal.
- **Risk: consumer signature drift.** The plan's bundle shape is read from report 01, not
  re-verified. **Mitigation**: Phase 0 reads and records the exact `sound_of_parts` (`:7449-7504`)
  signature and the pin/fChainPred landmark line numbers before any proof work.
- **Risk: completeness regression.** Altering the splice extract shape reopens report 03
  Determination 2. **Mitigation**: consume the existing flat `kvE_subChain2V` extract AS-IS
  (Postmortem constraint); Phase 6 re-runs a scoped build over the completeness lemmas.

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 0 | -- |
| 2 | 1, 4.1 | 0 |
| 3 | 2, 3 | 1 |
| 4 | 4.2 | 2, 3, 4.1 |
| 5 | 5 | 2, 4.2 |
| 6 | 6 | 0, 1, 2, 3, 4.1, 4.2, 5 |

Phases within the same wave can execute in parallel. **Territory contracts (H7)**: Phase 1, 2, 3,
4.2, 5 all append additive lemma blocks to `NfMultiAnchorBridge.lean`; Phase 4.1's `List.permutations`
helper lives in `EANegationClosure.lean` (genuinely parallel to Phase 1 — disjoint file). Phases 2
and 3 (same wave, same file) are conflict-free only if each owns a DISTINCT, append-only named lemma
block; if a single agent cannot own both, sequence 3 after 2. No phase edits an existing declaration.

### Phase 0: Baseline and integrity snapshot [COMPLETED]
- **Goal:** Establish a green baseline and record the exact consumer signature + landmark line
  numbers the proof will target, so no later phase re-discovers or drifts.
- **Tasks:**
  - [x] Run a scoped `lake build` over `NfMultiAnchorBridge.lean` + `EANegationClosure.lean` +
        `EANegation.lean`; confirm green baseline (record any pre-existing sorries/warnings).
        *(baseline green, 1005 jobs; pre-existing sorries: EANegation.lean:834 and :1129 — the
        documented-unprovable reverse-Cor-5.4 assets; only lint warnings otherwise)*
  - [x] Read and transcribe the exact `kvE_subBracket2V_sound_of_parts` signature (`:7449-7504`),
        including the `hgate` hypothesis (`:7462` takes `a<t` as INPUT, yields `a<w` at `:7482` —
        confirming the gate CONSUMES `hx1t`, cannot supply it). *(confirmed verbatim; `hbelow` uses
        `nf_depth0_char_formula atomMap h_surj χ` with `u < x1`; hgate at :7462, `hgate x1 hxx1 hx1t hanchor`
        at :7482)*
  - [x] Confirm current-tree line numbers for `kvE_pinDisjunct` (`:5374`), `ptSub`/`pinSlots`/`slotsFor`/`mkDisjunct`
        (`:5467`/`:5473`/`:5475`/`:5479`), `kvE_subChain2V` (`:6757`), `bracketFromLists3` (`:6609`),
        `k1v_bracket_extract` (`:2150`), `fChainFrom_base`/`_step` (`EANegation.lean:580`/`616`),
        `bracket_implies_fChainPred` (`EANegation.lean:660`, hmono unpacked :670).
  - [x] Verify (`grep`/read) each DO-NOT-EDIT asset is present and record a byte/line fingerprint
        to check against at Phase 6. *(all present; new work is PURELY ADDITIVE — inserted only
        between `k1v_bracket_extract` end (:2260) and `k1v_reconstruct_nf3`; no DO-NOT-EDIT asset touched)*
- **Timing:** ~0.5-1 hour
- **Depends on:** none
- **Files:** (read-only) NfMultiAnchorBridge.lean, EANegationClosure.lean, EANegation.lean
- **Verification:** Scoped `lake build` green; consumer signature + landmark table recorded in the
  dispatch handoff. No file writes to Lean sources.

### Phase 1: Order-preserving outer extraction [COMPLETED]
- **Goal:** Provide an extraction stronger than `k1v_bracket_extract` (`:2150`) that returns the
  MONOTONE witness sequence for σ's block `ptSub σ ++ pinSlots σ`, all in `(x, w_outer)` in
  strictly-increasing order — the ordering `k1v_bracket_extract` forgets (report 01 memory
  candidate 3; the monotone `ws` lives in `IntervalPattern.holds`, surfaced by
  `bracket_implies_fChainPred:670`).
- **Tasks:**
  - [x] State an additive extraction lemma returning the realized points for σ's block in
        strictly-increasing order with all `< w_outer` and `w_outer < t`. *(delivered:
        `bracketFromLists_flatMap_block_extract`, NfMultiAnchorBridge.lean ~:2331; returns
        `(w_outer, u, x<w_outer, w_outer<t, ptW@w_outer, x<u, u<w_outer, head a@u, ∀p∈tail a ∃q, u<q<w_outer ∧ p@q)`)*
  - [x] Prove it by threading the `hmono` (`ws` increasing sequence) from `IntervalPattern.holds`,
        mirroring `bracket_implies_fChainPred` (`EANegation.lean:670`), NOT the per-element
        existential of `k1v_bracket_extract`. *(delivered: `k1v_bracket_extract_mono`,
        ~:2263 — general monotone extraction exposing the full increasing `ws`; block lemma consumes it)*
  - [x] Thread σ-block contiguity (`ptSub σ :: pinSlots σ`, `:5476` — note `::`, not `++`) through
        the `flatMap` monotone indexing so downstream phases get "pins are above the fChainPred F_0
        points" for free. *(delivered via pure helper `getElem_append3_mid` ~:2288 +
        `bracketFromLists_flatMap_block_extract`; `head a` = `ptSub σ` sub-chain point realized
        STRICTLY BELOW every `tail a` = `pinSlots σ` witness — the ordering downstream consumes)*
- **Timing:** ~1.5-2 hours (~100-200 lines)
- **Depends on:** 0
- **Files:** NfMultiAnchorBridge.lean (additive)
- **Verification:** Scoped `lake build` green; no sorry; axiom-clean; new lemma type-checks. Cite
  Rabinovich 2014 Lemma 5.1 (md:169-171) in the lemma doc-comment for the structural bound.

### Phase 2: Bounded anchor from a pin [COMPLETED]
- **Goal:** Select the first pin witness `q` for σ and establish `x < q`, `q < w_outer < t`
  (⇒ `hx1t`), and `⟨charK (nfk_projFresh σ)⟩.eval_at q` (⇒ `hanchor`) — the bounded anchor,
  STRUCTURALLY from the pin's slot position (litmus PASS: no `x1 < e_i` literal).
- **Tasks:**
  - [x] Identify the first pin index (`|ptSub σ|` within σ's block) from Phase 1's ordered points.
        *(delivered generically: `p0 ∈ tail a` designates the head pin; at the gate `tail := pinSlots`,
        `p0 := ⟨charK (nfk_projFresh σ)⟩` the head of `pinSlots σ` :5601)*
  - [x] Derive `x < q` and `q < w_outer < t` from Phase 1's monotone bound + `w_outer < t`
        (`k1v_bracket_extract:2155`). Confirm `hx1t` traces to bracket monotonicity, not a literal.
        *(delivered: `bracketFromLists_flatMap_first_pin_anchor` ~:2390; `x<q` via `lt_trans hxu huq`,
        `q<w_outer` from Phase 1's `hpins` (slot monotonicity), `w_outer<t` from Phase 1's `hwt`;
        litmus PASS — no `x1<e_i` literal)*
  - [x] Extract `⟨charK (nfk_projFresh σ)⟩.eval_at q` from the pin point type (`kvE_pinDisjunct:5379`).
        *(delivered as `p0.eval_at M atomMap q` in the bundle; `p0` = the pin point type)*
- **Timing:** ~1-1.5 hours (~60-120 lines)
- **Depends on:** 1
- **Files:** NfMultiAnchorBridge.lean (additive)
- **Verification:** Scoped `lake build` green; no sorry; axiom-clean. `hx1t` provenance audited
  against the LITMUS. Cite Rabinovich 2014 Lemma 5.1 (md:169-171) for the shared-endpoint bound.

### Phase 3: fChainPred F_0 below-witnesses [COMPLETED]
- **Goal:** For each arrangement fChainPred slot realized at `u_i` (all `< q`, preceding the pins in
  σ's block by Phase 1's order), extract `(pointTypes 0).eval_at u_i = ⟨charBase χ_i⟩.eval_at u_i`,
  where `χ_i` is arrangement `i`'s first `zXU` type.
- **Tasks:**
  - [x] For a realized `fChainPred @ u_i`, extract `(pointTypes 0)@u_i` via
        `fChainFrom_step`/`_base` (`EANegation.lean:616`/`583`).
        *(delivered: `bracketFromLists3_fChainPred_head_extract` ~:6794; `bracket_implies_fChainPred`
        (:660) → F_0, then `fChainFrom_step` at index 0 (STEP, never base — `0 < n` since the
        `+1+1` arity) → `(pointTypes 0)@x0`)*
  - [x] Identify `pointTypes 0 = ⟨charBase χ_i⟩` via `bracketFromLists3` (`:6613-6614`).
        *(delivered: `pointTypes 0 = χ0` = head of `(χ0 :: lXU') ++ ptX1 :: lUW ++ ptW :: lWT`
        via `List.cons_append`/`List.getElem_cons_zero`; `χ0` is the first `zXU` type `⟨charBase χ⟩`)*
  - [x] Conclude, per realized arrangement, `∃ u_i, x < u_i < q ∧ ⟨charBase χ_i⟩.eval_at u_i`
        (the `< q` bound from Phase 1's ordering).
        *(delivered generically as `∃ u, z0 < u ∧ u < z ∧ χ0.eval_at u`; the specific `x < u < q`
        bound instantiates the inner endpoints `(z0, z)` at Phase 4.2/5 assembly — Phase 3 owns the
        extraction, the `< q` bound is Phase 1's ordering applied downstream)*
- **Timing:** ~1.5-2 hours (~100-180 lines)
- **Depends on:** 1
- **Files:** NfMultiAnchorBridge.lean (additive)
- **Verification:** Scoped `lake build` green; no sorry; axiom-clean. Cite Rabinovich 2014
  Lemma 5.3 (md:137-152) for the arrangement/point-type structure.

### Phase 4.1: List.permutations head-coverage helper [COMPLETED]
- **Goal:** Prove the pure combinatorial helper: every element of a list heads some permutation of
  that list (`∀ χ ∈ l, ∃ p ∈ l.permutations, p.head? = some χ`, or the form Phase 4.2 needs). This
  is the isolated, file-independent piece of the hardest step — provable early, in parallel with
  Phase 1, and it satisfies the H2 first-sorry-free-lemma bar.
- **Tasks:**
  - [x] Search Mathlib (`lean_leansearch`/`lean_loogle`) for an existing head-coverage /
        `List.permutations` membership lemma before proving from scratch.
        *(No single packaged head-coverage lemma exists; assembled from three Mathlib primitives:
        `List.mem_permutations` (`s ∈ t.permutations ↔ s ~ t`, `Mathlib.Data.List.Permutation`),
        `List.append_of_mem` (`a ∈ l → ∃ s t, l = s ++ a :: t`, core), and `List.perm_middle`
        (`(l₁ ++ a :: l₂) ~ (a :: (l₁ ++ l₂))`, core).)*
  - [x] If absent, prove the helper by induction / `List.permutations` structure. NO `simp`/`aesop`
        as the load-bearing closer.
        *(delivered: `exists_permutation_cons_head` (EANegationClosure.lean :752) — no `simp`/`aesop`;
        proof = `append_of_mem` split + `mem_permutations.mpr perm_middle.symm`. No `DecidableEq`
        needed — append-split route, not `erase`. Required additive `import Mathlib.Data.List.Permutation`
        (EANegationClosure's narrower closure lacked `List.mem_permutations`).)*
  - [x] State it in the exact shape Phase 4.2 consumes (coordinate the interface in the handoff).
        *(CONS form `∃ rest, (χ :: rest) ∈ l.permutations` is the make-or-break interface — the head
        `χ` feeds Phase 3's `bracketFromLists3 (χ0 :: lXU')`, and membership is the `S_XU.permutations`
        flatMap key. Also shipped the plan's literal `head?` form `exists_permutation_head?_eq`
        (:761) as a corollary. Interface recorded in `.orchestrator-handoff.json`
        `continuation_context`.)*
- **Timing:** ~1-1.5 hours (~60-120 lines)
- **Depends on:** 0
- **Files:** EANegationClosure.lean (additive; disjoint from Phase 1's file for genuine parallelism)
- **Verification:** Scoped `lake build` green; no sorry; axiom-clean; helper type-checks standalone.

### Phase 4.2: hbelow assembly [NOT STARTED] (HARDEST — make-or-break)
- **Goal:** For an arbitrary `zXU`-positive `χ` (`χ ∈ S_XU`), exhibit the arrangement whose `lXU`
  permutation starts with `χ` (via Phase 4.1 coverage over `kvE_subChain2V` `:6787-6791`), read its
  F_0 below-witness `u_χ < q` from Phase 3, and conclude `∃ u, x < u < q ∧ ⟨charBase χ⟩.eval_at u` —
  i.e. `hbelow(q)`. This is the single highest-risk step (report 01 lines 140-158).
- **Tasks:**
  - [ ] Instantiate Phase 4.1 coverage: pick the arrangement whose `lXU` heads with `χ`.
  - [ ] Pull that arrangement's Phase-3 F_0 below-witness `u_χ` and its `< q` bound.
  - [ ] Assemble the per-`χ` `hbelow` witness; universally quantify over `χ ∈ S_XU`.
  - [ ] If assembly blocks (perm coverage interface mismatch OR monotone `< q` placement gap):
        do NOT land a live-path sorry — invoke Rollback/Contingency (report NOT-PROVABLE-AS-SPEC
        with the exact blocked sub-step and goal state).
- **Timing:** ~2-3 hours (~120-200 lines)
- **Depends on:** 2, 3, 4.1
- **Files:** NfMultiAnchorBridge.lean (additive)
- **Verification:** Scoped `lake build` green; no sorry; axiom-clean. If green, the CAVEAT is
  discharged. Cite Rabinovich 2014 Lemma 5.3 (md:137-152) for permutation coverage.

### Phase 5: Bundle and feed the consumer [NOT STARTED]
- **Goal:** Package `(q, hxx1, hx1t, hanchor, hbelow)` into the final additive lemma and verify it
  type-checks against `kvE_subBracket2V_sound_of_parts` (`:7449`) with the outer gate `hgate`.
- **Tasks:**
  - [ ] Assemble the bundle from Phases 2 (anchor+bound) and 4.2 (`hbelow`).
  - [ ] State the final lemma (e.g. `kvE_sub2V_bounded_anchor_of_outer`) with the signature the
        research specifies (consumes the pin-slot extract + order-preserving extraction).
  - [ ] Confirm the bundle instantiates `sound_of_parts`'s expected argument types EXACTLY
        (type-check against `:7449-7504`); do NOT edit the consumer.
- **Timing:** ~0.5-1 hour (~40-80 lines)
- **Depends on:** 2, 4.2
- **Files:** NfMultiAnchorBridge.lean (additive)
- **Verification:** Scoped `lake build` green; no sorry; axiom-clean; the final lemma's output type
  unifies with the `sound_of_parts` input bundle.

### Phase 6: Verification and axiom-clean sweep [NOT STARTED]
- **Goal:** Final integrity gate: the deliverable is green, axiom-clean, sorry-free on live paths,
  and no DO-NOT-EDIT asset regressed.
- **Tasks:**
  - [ ] Full scoped `lake build` over NfMultiAnchorBridge.lean + EANegationClosure.lean +
        EANegation.lean — green.
  - [ ] `#print axioms <final lemma>` and each new helper → confirm ONLY
        `[propext, Classical.choice, Quot.sound]` (no `sorryAx`).
  - [ ] `grep`/`lean_verify` the final lemma + helpers for `sorry` on committed live paths → none.
  - [ ] Re-check the Phase-0 fingerprints of all DO-NOT-EDIT assets → byte-identical.
  - [ ] Confirm completeness lemmas (`kvE_subBracket2V_complete`) still build (splice extract
        consumed unchanged).
- **Timing:** ~0.5 hour
- **Depends on:** 0, 1, 2, 3, 4.1, 4.2, 5
- **Files:** (read-only verification) NfMultiAnchorBridge.lean, EANegationClosure.lean, EANegation.lean
- **Verification:** All above checks pass; handoff records axiom list and the do-not-edit fingerprint
  re-check. This is the definition-of-done gate.

## Testing & Validation

- [ ] Scoped `lake build` green at Phase 0 baseline and after every phase.
- [ ] `#print axioms` on the final lemma + each new helper = `[propext, Classical.choice, Quot.sound]`.
- [ ] No `sorry` on any committed live path (`lean_verify` / `grep`).
- [ ] Final lemma output type unifies with `kvE_subBracket2V_sound_of_parts` (`:7449`) input bundle.
- [ ] `hx1t` provenance traces to pin-slot bracket monotonicity, never a formula literal (LITMUS).
- [ ] All DO-NOT-EDIT assets byte-identical vs. Phase-0 fingerprint.
- [ ] Completeness lemmas still build (no splice-shape change).

## Artifacts & Outputs

- plans/01_bounded-pointinsertion-composition.md (this file)
- Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge.lean (additive: final lemma +
  Phase 1/2/3/4.2 helper lemmas)
- Theories/Bimodal/Metalogic/WeakCanonical/Kamp/EANegationClosure.lean (additive: Phase 4.1
  `List.permutations` head-coverage helper, if not found in Mathlib)
- summaries/01_bounded-pointinsertion-composition-summary.md (on completion)

## Rollback/Contingency

- **Per-phase**: each phase is additive; if a phase's `lake build` is not green, do NOT commit —
  fix forward within the phase. No destructive git on uncommitted work.
- **Phase 4.2 make-or-break (the CAVEAT)**: if `hbelow` assembly cannot be completed after genuine
  effort, do NOT land a live-path sorry and do NOT relapse to a formula-literal bound. Report
  NOT-PROVABLE-AS-SPEC with a precise residual: which sub-step blocked (Phase 4.1 perm-coverage
  interface vs. Phase 1 monotone `< q` placement), the exact `lean_goal` state, and the minimal
  missing fact. This escalates back to the reverse-Cor-5.4 wall and is handed to `/spawn` or a
  task-321 re-plan — it is a legitimate terminal outcome, not a failure to commit.
- **Full rollback**: since all work is additive to two files, reverting is `git checkout` of the two
  Lean files to the Phase-0 baseline commit (only on a clean tree or after `git-snapshot.sh`).
- **On completion**: task 321 resumes via `/revise 321` (v5, re-point Phase 10 at this lemma) then
  `/orchestrate 321`. Completeness (task 321 Phases 12-14) stays closed via
  `kvE_subBracket2V_complete` because this lemma consumes the existing splice extract unchanged.
