# Implementation Plan: Task #335 — Outer-Gate Assembly Engine (`kvE2_body` / `bracketEndChar_kvE2`) — ⇒ Soundness Half via Consuming Task 333

- **Task**: 335 - Build the outer-gate assembly engine `kvE2_body` / `bracketEndChar_kvE2`, the two-level quant-layer connector that `KampPrior.lean:351` (the depth-k≥2 Cor 5.4 converter) consumes
- **Status**: [IN PROGRESS]
- **Effort**: 3.5 hours (remaining ⇒ half + assembly; Phases 1-2 already landed)
- **Dependencies**:
  - 334 (COMPLETED — faithful carrier redefinition `kvE2_sepArr'` + `kvE2_sepDisjValidOwner`)
  - 337 (COMPLETED — `kvE2_sepBody_holds_of_honest` completeness engine, consumed by the landed Phase 2)
  - 342 (COMPLETED — interior-restricted owner index `kvE2_sepPosI`, tie-admitting weak orders, `hLR` deletion)
  - **333 (UPSTREAM, IN PROGRESS)** — soundness-extraction lemmas in `SharedWitness.lean`; revised plan `specs/333_carrier_redefinition_kve2_separr_bit_compatibility_correctness_pair/plans/05_kit-application-and-outer-fold.md` (being authored now, supersedes `plans/04_post334-soundness-extraction.md`). 335's ⇒ half CONSUMES 333's landed R2/R3/R4 lemmas (see Overview). **335 must not run concurrently with 333** (H7 territory).
- **Research Inputs**:
  - specs/333_carrier_redefinition_kve2_separr_bit_compatibility_correctness_pair/reports/03_pdf-fidelity-r3-dissolved-regrounding.md (CONFIRMED, adversarially verified H4 — proves the O4 crux is DISSOLVED, the forward-zone conjunct is never a goal, all `md:NN` cites dangle; cite Rabinovich by PDF page only)
  - specs/335_outer_gate_assembly_engine_kvE2_body/reports/01_outer-gate-assembly-engine.md (original research; carrier/interface grounding — line numbers superseded post-334/342)
  - specs/337_build_joint_multiowner_disjunct_bracketholds_engine_for_kve2_sepdisjunct/reports/13_rxw-faithfulness-audit.md (CONFIRMED — pivot/faithfulness constraints on `.rXW`)
  - specs/337_build_joint_multiowner_disjunct_bracketholds_engine_for_kve2_sepdisjunct/reports/14_tie-class-semantics-audit.md (CONFIRMED — tie-class disambiguation, primed-order guardrail)
- **Artifacts**: plans/03_soundness-half-consume-333-lemmas.md (this file); supersedes plans/02_outer-gate-assembly-current-interface.md
- **Standards**: plan-format.md; status-markers.md; artifact-management.md; lean4.md; literature-fidelity-policy.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

This is **plan v3**, a revision of plan-02. Plan-02 correctly re-grounded onto the post-342
interface (unconditional theorems, `kvE2_sepPosI` interior index, primed order, task-337 completeness
engine) — **all of that grounding is PRESERVED here**. What plan-02 got wrong was its Phases 3-5
BLOCKED framing. That framing is now **doubly stale** and is retired by this plan.

**The ⇐ (completeness) half is delivered.** `bracketEndChar_kvE2_complete_two_prior`
(`OuterGate.lean:139`, sorry-free, axiom-clean `{propext, Classical.choice, Quot.sound}`) is landed
and preserved. Phase 1 (live `bracketEndChar_kvE2` def + `bracketEndChar_kvE2_two_eq` `rfl` bridge,
`OuterGate.lean:62-79`) is landed and preserved.

**The ⇒ (soundness) half is real, now-attemptable work — NOT a crux.** It re-scopes around its true
dependency: it CONSUMES task 333's landed `SharedWitness.lean` soundness lemmas. Concretely 335 waits
on these 333 deliverables (333 plan-05):

1. **R2 — extraction side-conditions**: `kvE2_sepBody_extract`'s `hpairL`/`hpairR`/`hnd`
   (`Pairwise`/`Nodup` over arbitrary `wo ∈ kvE2_sepArr' qnf`), stated verbatim at
   `SharedWitness.lean:6331-6340`.
2. **R3 + per-σ kit application**: the bit-compat bridge (`kvE2_sepDisjValidOwner ⟹` the forward-zone
   `hgate` conjunct) and the per-σ realizations threaded through `kvE2_sepBundleL_parts` (SW:5167) /
   `kvE2_sepBundleR_parts` (SW:5184) into `kvE_subBracket2V_sound_of_parts` (`SubBracket2V.lean:1025`).
3. **R4 — outer depth-2 fold** `kvE2_outer_fold`: assembles `∃ w, nf_eval_nf M 2 3 [w,x,t] qnf` from
   the per-σ bundles + `ExistProviders.correct` + the navigated sub-chain (`NavigatedSpine.lean:445`),
   stated in the shape 335's `bracketEndChar_kvE2_sound_two_prior` consumes.

335's own new work is then thin: on the `OuterGate.lean` side, `rw [bracketEndChar_kvE2_two_eq]` and
wrap 333's `kvE2_outer_fold` into `bracketEndChar_kvE2_sound_two_prior`, then `constructor` both
directions into the assembled `bracketEndChar_kvE2_correct_two_prior`.

**Deliverables** (the k=2 N2-C gate, `PriorInterface.lean:60`):
- `bracketEndChar_kvE2_sound_two_prior : (bracketEndChar_kvE2 atomMap h_surj P qnf).holds M atomMap x t
  → ∃ w, nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf` (UNCONDITIONAL).
- `bracketEndChar_kvE2_correct_two_prior : BracketCarrierCorrectVPrior atomMap
  (bracketEndChar_kvE2 atomMap h_surj P)` — mirroring the landed k≤1 lift
  `bracketEndChar_kv_correct_one_prior` (`PriorInterface.lean:95`).

The work is **purely additive** and confined to the existing `OuterGate.lean` sibling (aggregator
import already present, `NfMultiAnchorBridge.lean:39`). The 334/342 carrier and 333's soundness lemmas
are **verified INPUTS** — only applied, never edited.

### The plan-02 BLOCKED framing is retired (both reasons stale, with evidence)

Plan-02 / `OuterGate.lean:172-201` recorded the ⇒ half as BLOCKED for two reasons. **Both are now
false**, verified against HEAD:

1. **"The faithful repair redefines `kvE2_sepValid`/`kvE2_sepArrL`/`kvE2_sepArrR` — a verified INPUT."**
   Those three symbols have **0 declarations** in `SharedWitness.lean` — every remaining occurrence is
   prose in a comment (verified: `grep -n "kvE2_sepValid\|kvE2_sepArrL\|kvE2_sepArrR"` returns only
   `--`/docstring lines, e.g. SW:1040-1042 "REMOVED (task 334 Phase 6)", SW:1453, SW:1748). Task 334
   (COMPLETED) already performed the redefinition — the live carrier is `kvE2_sepArr'` +
   `kvE2_sepDisjValidOwner`; task 342 (COMPLETED) added the interior-restricted index `kvE2_sepPosI`
   (SW:211) + tie-admitting weak orders and deleted the `hLR` hypothesis. **The redefinition 335 was
   waiting on already happened.**

2. **"No orchestrator re-authorization is held."** It IS held. Task 333's plan (Territory Contract,
   `plans/04_post334-soundness-extraction.md:75-82`, carried into plan-05) explicitly GRANTS 335
   authorization to consume 333's additive soundness lemmas to close its ⇒ half, under an H7 territory
   split: **333 owns `SharedWitness.lean`, 335 owns `OuterGate.lean`.** Reaffirmed here.

3. **The underlying crux is DISSOLVED** (333 report 03, H4-verified). The forward-zone `hgate`
   conjunct `σ.2 (nf0_assemble kvE_sub2_zXU χ σ.1) = true` is **never a goal**; it is uniformly the
   *antecedent* of a per-owner `bit ⟹ witness` implication (`kvE2_sepBundleL` SW:5117;
   `kvE_subBracket2V_extract` SubBracket2V:1027). `kvE2_sepGate` (SW:1238) is four clauses **all
   concluding `= false`** — it never demands a bit be true. The sorry-free `kvE2_sepBody_extract`
   (SW:6328) already *produces* the bundles. Cross-σ order freedom in `kvE2_sepSlotLe` (SW:6556) is
   **intended design post-342**, not a bug (arrangement-awareness moved into the validity filter). The
   O4 CRUX RECORD (SW:6566-6659) is a task-321-vintage record self-annotated "additive and inert",
   superseded by the live 334/342 architecture.

The in-source comment block at `OuterGate.lean:172-201` (the "Phases 3-5 BLOCKED" note) and the
"What this file delivers" items 4/5 (`OuterGate.lean:24-29`) are 335's own file — correcting them is
within territory and is scheduled as Phase 3 (comment correction) and Phase 5 (final docstring).

### Research Integration (newly integrated in plan v3)

- **333 report 03 (`03_pdf-fidelity-r3-dissolved-regrounding.md`, CONFIRMED / H4-verified)**: the
  make-or-break finding that the O4 crux is DISSOLVED, not relocated — the forward-zone conjunct is
  antecedent-only (three live sites SW:5117/5175/5289, all antecedents), the gate is four falsity-only
  clauses, and `kvE2_sepBody_extract` already discharges the witness-finding. This report is the
  evidentiary basis for retiring the BLOCKED framing. It also establishes the **citation rule**: the
  re-extracted Rabinovich `.md` drops every displayed equation and inverts `k≠m`→`k=m`; all `md:NN`
  anchors dangle. Cite the PDF **by page** only.
- **Preserved from plan-02**: 337 report 13 (`.rXW` faithfulness, pivot bound `x < v ∧ v < w ∧ χ`,
  LITMUS-clean) and 337 report 14 (primed order `kvE2_sepHonestOrder'` SW:5974 is the only correct
  order; `kvE2_sepModelOrder` SW:1476 and unprimed `kvE2_sepHonestOrder` SW:3891 force singleton
  classes) remain binding for any ordering-touching step on the soundness side.

### Citation rule (binding — carried into every phase)

Cite the Rabinovich source **by PDF page** (`p.N`), never `md:NN`. The markdown was a hand-written
paraphrase until 2026-07-09; its replacement drops every displayed equation and inverts `k≠m`→`k=m`,
and every pre-existing `md:NN` anchor now dangles. For **Lemma 3.2** use the mandated form: *"the
construction forced by Def 3.1 (p.4), corroborated by the k=m split (p.7) and Def 7.5 (p.13); Lemma
3.2(1) (p.4) states the closure without printed proof."* One dangling cite (`md:297`, beyond even the
old 245-line file) exists in a prior 335 artifact; purging/re-grounding it to a page cite is folded
into Phase 3.

## Goals & Non-Goals

**Goals**:
- Preserve the landed ⇐ completeness (`bracketEndChar_kvE2_complete_two_prior`, Phase 2) and Phase 1
  live def + `rfl` bridge — do not re-plan or re-touch them.
- Correct the stale in-source BLOCKED framing (`OuterGate.lean:172-201`) and re-ground the dangling
  `md:297` cite (Phase 3) — 335's own file, within territory.
- Prove **⇒ soundness** `bracketEndChar_kvE2_sound_two_prior`: `.holds ⟹ ∃ w, nf_eval_nf M 2 3
  (Fin.cons w (Fin.cons x (fun _ => t))) qnf`, by consuming task 333's landed `kvE2_outer_fold` (+ R2
  side-conditions + the per-σ kit via `kvE2_sepBundleL/R_parts → kvE_subBracket2V_sound_of_parts`),
  closed through `bracketEndChar_kvE2_two_eq` (Phase 4).
- Assemble both directions into the **UNCONDITIONAL** `k = 2` gate-correctness theorem
  `bracketEndChar_kvE2_correct_two_prior : BracketCarrierCorrectVPrior atomMap
  (bracketEndChar_kvE2 atomMap h_surj P)`, mirroring `bracketEndChar_kv_correct_one_prior`
  (`PriorInterface.lean:95`); update the `OuterGate.lean` scope docstring items 4/5 (Phase 5).
- Preserve F1-F7 and the LITMUS (`NavigatedSpine.lean:437`): no `x1 < e_i` relative-position literal
  on any live path; witness bounds come from the bracket range, never a chain.

**Non-Goals**:
- **Do NOT edit `SharedWitness.lean` or any 333/334/342 carrier input** (H7: 333's territory; verified
  INPUTS). 335 owns `OuterGate.lean` only. If a phase concludes a `SharedWitness.lean` decl must
  change or its shape mismatches 335's consumer, STOP and coordinate with 333 — re-shape in
  `SharedWitness.lean` (333's file), never in `OuterGate.lean` by weakening the statement.
- **Do NOT re-prove or weaken** `kvE2_sepBody_holds_of_honest`, `kvE2_outer_fold`, or any 333/334/342
  lemma. Consume unchanged.
- **Do NOT reintroduce any interiority hypothesis** (`hL`, `hLR`, or a left/right-interior guard on
  realized types). Refuted by `kvE2_sepHonest_hLR_absurd` (SW:5714); any phase adding one is wrong by
  construction.
- **Do NOT wire the gate into `KampPrior.lean:351`** — R-B, a distinct downstream task, out of scope.
- **The F4 semantic `ℤ` LHS-FALSE discriminator + GO verdict is a SEPARATE, not-yet-spawned successor
  task** (per `SubBracket.lean:231`), to be spawned once the ⇒ half lands. Out of scope here. When
  spawned it must genuinely DISCRIMINATE (LHS-FALSE at `(10,20)`, never weakened to pass).
- No bare `sorry`/`admit`; no vacuous close (`False.elim`, `(kvE2_sepHonest_hLR_absurd …).elim`,
  `def X := True`); no gate-modulo-assumed-`hgate`; no interiority hypothesis (zero-debt).

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Task 333's `kvE2_outer_fold` (R4) is not yet landed when 335 dispatches | H | M | Phase 4 has an EXTERNAL prerequisite: 333 plan-05 R4 landed and shaped for 335's consumer. Do not dispatch Phase 4 until `kvE2_outer_fold` is on disk, sorry-free, axiom-clean. If absent, HALT Phase 4 (not BLOCKED-permanently — a sequencing wait); Phases 1-3 are independent and can land first. |
| SharedWitness↔OuterGate seam mismatch — 333's `kvE2_outer_fold` signature does not line up with 335's `bracketEndChar_kvE2_sound_two_prior` consumer | M | M | Coordinate the exact statement with 333 (its plan-05 Risk row already flags this interface constraint). Re-shape on the **333/SharedWitness** side, never by weakening 335's statement or editing `SharedWitness.lean` from 335. If the wrapper needs 335 to thread the per-σ kit itself (bundles → `sound_of_parts`), split Phase 4 into 4a (per-σ realization threading) and 4b (outer wrap) — each ~100-300 lines, committed at each green milestone. |
| Wiring the soundness wrapper to the wrong weak order (`kvE2_sepModelOrder` SW:1476 or unprimed `kvE2_sepHonestOrder` SW:3891 — injective payloads force singleton classes, grouped obligations FALSE under ties) | H | L | Guardrail (337 report 14): any ordering-touching step uses the PRIMED `kvE2_sepHonestOrder'` (SW:5974) only. 333's `kvE2_outer_fold` already uses the primed order internally; 335's wrapper is order-agnostic (consumes the fold structurally). Checklist item in Phase 4. |
| Accidentally editing `SharedWitness.lean` (333's territory) | H | L | All 335 code lives in `OuterGate.lean`. A `git status` gate in Phase 5 confirms `SharedWitness.lean`/`SubBracket2V.lean` byte-unchanged. If a landed decl must change, STOP and coordinate with 333 — do not edit. |
| Vacuous close typechecks and builds green but proves nothing | H | L | Explicit testing item: grep `OuterGate.lean` for `False.elim`, `hLR_absurd`, `sorry`, `admit`, `:= True`, `:= trivial`. Green + vacuous is a FAILURE. |
| Re-introducing a `md:NN` cite or citing the corrupted `.md` | M | L | Binding citation rule: page cites only, mandated Lemma 3.2 form. Phase 3 purges the dangling `md:297`; Testing greps `OuterGate.lean` for `md:` = 0. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 0 | 1, 2 | -- (landed) |
| 1 | 3 | -- |
| 2 | 4 | 3 (+ EXTERNAL: task 333 plan-05 R4 `kvE2_outer_fold` landed) |
| 3 | 5 | 2, 4 |

Phases within the same wave can execute in parallel. Phase 4 additionally has an external prerequisite
(333's `kvE2_outer_fold` must be on disk, sorry-free) that is NOT a 335 phase — do not dispatch Phase
4 until it lands. All phases edit only `OuterGate.lean`; 335 and 333 do not run concurrently (H7).

### Phase 1: Live wrapper def + `rfl` bridge [COMPLETED]

**Goal**: Introduce the first live `bracketEndChar_kvE2` definition delegating to the faithful
carrier, plus the `rfl` bridge, in the isolated `OuterGate.lean` sibling wired into the aggregator.

**Delivered** (verified against source, on disk, green):
- `bracketEndChar_kvE2` (`OuterGate.lean:62-67`): `noncomputable def` producing
  `BracketEndCharCarrierV sig 2`, delegating to `kvE2_sepBody (nf_depth0_char_formula …) (fun χ =>
  P.existF 0 χ)`.
- `bracketEndChar_kvE2_two_eq` (`OuterGate.lean:73-79`): the `rfl` bridge exposing `kvE2_sepBody`.
- Aggregator import (`NfMultiAnchorBridge.lean:39`).

**Depends on**: none. **Files**: `OuterGate.lean` (present). Preserved as-is; do not re-do.

**Completed**: prior task-335 dispatch. Green build; axiom-clean `{propext, Classical.choice,
Quot.sound}`, no `sorryAx`.

---

### Phase 2: ⇐ completeness half — consume `kvE2_sepBody_holds_of_honest` [COMPLETED]

**Result**: `bracketEndChar_kvE2_complete_two_prior` landed (`OuterGate.lean:139`, sorry-free,
axiom-clean `{propext, Classical.choice, Quot.sound}`), plus helper bridges
`bracketEndChar_kvE2_hcb` / `bracketEndChar_kvE2_hck`. The gate `hg` is discharged by the landed
`kvE2_sepGate_holds_of_honest`; `hxw`/`hwt` recovered from `qnf`'s atom layer via `h_xy`/`h_yt`
(LITMUS-clean, bracket range). UNCONDITIONAL — no `hL`/`hLR`.

**Depends on**: 1. **Files**: `OuterGate.lean` (present). Preserved as-is; do not re-do.

**Completed**: prior task-335 dispatch (verified `OuterGate.lean:133-170`).

---

### Phase 3: Retire the stale in-source BLOCKED framing + citation hygiene [NOT STARTED]

**Goal**: Correct 335's own in-source prose that records the ⇒ half as BLOCKED for two now-false
reasons, and re-ground the one dangling `md:NN` cite in 335's artifacts. This is a comment-only edit
within 335's territory; it lands no proof but removes the doubly-stale mental model that misled two
plans. Independent of 333 (can land before the ⇒ half).

**Tasks**:
- [ ] Replace the `OuterGate.lean:172-201` "Phases 3-5 — BLOCKED" note with an accurate status: the
      ⇒ half is now-attemptable additive work consuming task 333's landed `SharedWitness.lean`
      soundness lemmas (R2 side-conditions, R3 + per-σ kit, R4 `kvE2_outer_fold`); the O4 crux is
      DISSOLVED (333 report 03), the named symbols `kvE2_sepValid`/`kvE2_sepArrL`/`kvE2_sepArrR` no
      longer exist (334 redefined to `kvE2_sepArr'` + `kvE2_sepDisjValidOwner`), and the authorization
      is held (333 Territory Contract; 333 owns `SharedWitness.lean`, 335 owns `OuterGate.lean`).
- [ ] State the evidence inline with `file:line`: `kvE2_sepGate` = four `= false` clauses (SW:1238);
      forward-zone conjunct is antecedent-only (SW:5117/5175/5289); `kvE2_sepBody_extract` sorry-free
      produces bundles (SW:6328); cross-σ order freedom in `kvE2_sepSlotLe` (SW:6556) is intended
      post-342 design; O4 CRUX RECORD (SW:6566-6659) is inert/superseded.
- [ ] Purge/re-ground the dangling `md:297` cite (and any other `md:NN`) in 335's artifacts to a PDF
      page cite, using the mandated Lemma 3.2 form.
- [ ] Do NOT touch the delivered decls, the docstring items 4/5 (Phase 5 finalizes those once
      soundness lands), or any `SharedWitness.lean` content.

**Timing**: 0.5 hours. **Depends on**: none (1, 2 landed).

**Files to modify**: `OuterGate.lean` (comment block only).

**Verification**:
- `lake build …OuterGate` still exit 0 (comment-only edit, no proof change).
- `grep -n "md:" OuterGate.lean` = 0; no `kvE2_sepValid`/`kvE2_sepArrL`/`kvE2_sepArrR` asserted as a
  live obstruction in the note.
- `SharedWitness.lean`/`SubBracket2V.lean` byte-unchanged (`git status`).

---

### Phase 4: ⇒ soundness half — `bracketEndChar_kvE2_sound_two_prior` via consuming task 333 [NOT STARTED]

**EXTERNAL PREREQUISITE**: task 333 plan-05 R4 `kvE2_outer_fold` (and R2 side-conditions + R3/per-σ
kit) landed in `SharedWitness.lean`, sorry-free, axiom-clean, and shaped for 335's consumer. Do NOT
dispatch this phase until that is on disk. This is a sequencing wait, not a permanent blocker.

**Goal**: Prove the ⇒ (mp) direction as a standalone lemma
`bracketEndChar_kvE2_sound_two_prior`:
```
(bracketEndChar_kvE2 atomMap h_surj P qnf).holds M atomMap x t
  → ∃ w, nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf
```
over the six `BracketCarrierCorrectVPrior` order hypotheses + `h_UZ`/`h_SZ` + `x t`, UNCONDITIONAL
(no `hL`/`hLR`). This is a CONSUMPTION of 333's landed soundness lemmas — no new engine on the 335
side.

**Tasks**:
- [ ] State `bracketEndChar_kvE2_sound_two_prior` with the same signature shape as
      `bracketEndChar_kvE2_complete_two_prior` (`OuterGate.lean:139-153`), reversed arrow.
- [ ] `intro h_holds`; `rw [bracketEndChar_kvE2_two_eq] at h_holds` to expose `(kvE2_sepBody …).holds`.
- [ ] Apply task 333's `kvE2_outer_fold` to `h_holds` (with the R2 `hpairL`/`hpairR`/`hnd`
      side-conditions and the per-σ kit already discharged upstream in 333) to obtain
      `∃ w, nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf`. Supply the standard
      instantiation (`charBase = nf_depth0_char_formula atomMap h_surj`, `charK = fun χ => P.existF 0
      χ`) and the `hcb`/`hck` char-formula bridges (`bracketEndChar_kvE2_hcb`/`bracketEndChar_kvE2_hck`,
      already landed from Phase 2) exactly as the completeness half does.
- [ ] Confirm each `have` with `lean_goal`; witness bound `x < w < t` reads from the bracket's own
      range (Def 3.1 monotone enumeration, p.4), NOT a chain — no `x1 < e_i` literal (LITMUS
      `NavigatedSpine.lean:437`).
- [ ] Any ordering-touching step uses the PRIMED `kvE2_sepHonestOrder'` (SW:5974) only (337 report 14).
- [ ] **If the SharedWitness↔OuterGate seam does not line up**: STOP and coordinate with 333; re-shape
      `kvE2_outer_fold` on the 333/SharedWitness side. Do NOT weaken 335's statement, do NOT edit
      `SharedWitness.lean` from 335, do NOT assume `hgate`, do NOT add an interiority hypothesis. If
      335 must thread the per-σ kit itself (`kvE2_sepBundleL/R_parts → kvE_subBracket2V_sound_of_parts`,
      `SubBracket2V.lean:1025`), split into Phase 4a (per-σ realization threading) and Phase 4b (outer
      wrap), committing each green.

**Timing**: 1.5 hours (thin wrapper if 333's fold is shaped; up to 3h if the per-σ kit must be threaded
on the 335 side — then split). **Depends on**: 3 (same-file sequencing) + EXTERNAL 333 `kvE2_outer_fold`.

**Files to modify**: `OuterGate.lean` (add ⇒ soundness lemma).

**Verification**:
- `bracketEndChar_kvE2_sound_two_prior` compiles sorry-free; no interiority hypothesis in its
  signature; consumes 333's lemmas unmodified.
- `#print axioms bracketEndChar_kvE2_sound_two_prior` (via `lake env lean`, NOT `lean_verify` — it is
  UNRELIABLE on `SharedWitness.lean`, returning stale `sorryAx` after an external `lake build`) →
  `{propext, Classical.choice, Quot.sound}`, no `sorryAx`.
- No `x1 < e_i` literal; primed order only; `SharedWitness.lean`/`SubBracket2V.lean` byte-unchanged.

---

### Phase 5: Assemble unconditional `k = 2` gate-correctness + axiom/faithfulness audit + docstring [NOT STARTED]

**Goal**: Combine both directions into `bracketEndChar_kvE2_correct_two_prior :
BracketCarrierCorrectVPrior atomMap (bracketEndChar_kvE2 atomMap h_surj P)`, confirm
axiom-cleanliness and F1-F7/LITMUS preservation, and finalize the `OuterGate.lean` scope docstring.

**Tasks**:
- [ ] State `bracketEndChar_kvE2_correct_two_prior` (UNCONDITIONAL): unfold
      `BracketCarrierCorrectVPrior` (`PriorInterface.lean:60`), `intro` the six order hypotheses +
      `h_UZ`/`h_SZ` + `x t`, then `constructor` combining Phase 4 (⇒, mp) and Phase 2 (⇐, mpr),
      mirroring `bracketEndChar_kv_correct_one_prior` (`PriorInterface.lean:95`).
- [ ] Finalize the `OuterGate.lean` header docstring: rewrite delivered items 4/5
      (`OuterGate.lean:24-29`) to record `bracketEndChar_kvE2_sound_two_prior` and
      `bracketEndChar_kvE2_correct_two_prior` as DELIVERED (drop the "NOT delivered, BLOCKED" text);
      note R-A unconditional, R-B out of scope, and the F4 `ℤ` discriminator as a not-yet-spawned
      successor task (`SubBracket.lean:231`). Page-cite only.
- [ ] Run `#print axioms bracketEndChar_kvE2_correct_two_prior` via `lake env lean`; confirm
      `{propext, Classical.choice, Quot.sound}`, no `sorryAx`.
- [ ] F1-F7 + LITMUS preservation checklist (see Testing & Validation).
- [ ] `git status` confirms only `OuterGate.lean` changed; `SharedWitness.lean`/`SubBracket2V.lean`
      byte-for-byte unmodified.
- [ ] `lake build Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.OuterGate`, then full
      `lake build`.

**Timing**: 1 hour. **Depends on**: 2, 4.

**Files to modify**: `OuterGate.lean` (assembled theorem + docstring finalize).

**Verification**:
- `#print axioms bracketEndChar_kvE2_correct_two_prior` axiom-clean, no `sorryAx`.
- Full `lake build` green.
- No interiority hypothesis anywhere; no vacuous close; docstring records delivered decls, page-cited.

## Testing & Validation

- [ ] `lake build Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.OuterGate` succeeds after
      each phase; full `lake build` green at the end.
- [ ] **Axiom check via `#print axioms` (NOT `lean_verify`)**: run each delivered declaration through
      `lake env lean` with `#print axioms <name>`; every one returns `{propext, Classical.choice,
      Quot.sound}` with no `sorryAx`. `lean_verify` is UNRELIABLE on `SharedWitness.lean` (stale LSP
      `sorryAx` after external `lake build`) — do not trust it.
- [ ] **No vacuous close**: grep `OuterGate.lean` for `False.elim`, `hLR_absurd`, `sorry`, `admit`,
      `:= True`, `:= trivial`. Green + vacuous is a FAILURE, not a pass.
- [ ] **No interiority hypothesis**: no `hL`/`hLR`/left-or-right-interior guard on realized types in
      any delivered signature (refuted by `kvE2_sepHonest_hLR_absurd`, SW:5714).
- [ ] **Primed order only**: no live path consumes `kvE2_sepModelOrder` (SW:1476) or the unprimed
      `kvE2_sepHonestOrder` (SW:3891); ordering rides `kvE2_sepHonestOrder'` (SW:5974).
- [ ] **LITMUS (`NavigatedSpine.lean:437`)**: no `x1 < e_i` relative-position literal on any live path;
      witness bounds come from the bracket range, never a chain.
- [ ] **F1-F7**: non-vacuous realization (F2/F3 via the landed completeness engine + 333's soundness
      fold); no open/closed zone-key conflation (F5); no model literal buried (F4).
- [ ] **Citation hygiene**: `grep -n "md:" OuterGate.lean` = 0; all Rabinovich references page-cited;
      Lemma 3.2 uses the mandated form (Def 3.1 p.4 / k=m split p.7 / Def 7.5 p.13).
- [ ] **Territory (H7)**: `SharedWitness.lean`, `SubBracket2V.lean`, and all other 334/337/342 files
      byte-for-byte unmodified (`git status`); only `OuterGate.lean` changed. If any landed decl must
      change, STOP and coordinate with 333 — do NOT edit `SharedWitness.lean` from 335.
- [ ] **SW sorry count unchanged**: `SharedWitness.lean` sorry string occurrences all inside prose
      comments (zero real sorries); count MUST NOT rise (335 does not edit `SharedWitness.lean`).
- [ ] `bracketEndChar_kvE2_two_eq` remains a genuine `rfl` bridge (unchanged from Phase 1).

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/OuterGate.lean` — extended:
  corrected BLOCKED-note comment (Phase 3), ⇒ soundness lemma `bracketEndChar_kvE2_sound_two_prior`
  (Phase 4), assembled unconditional gate-correctness theorem `bracketEndChar_kvE2_correct_two_prior`
  + finalized scope docstring (Phase 5). (Phase 1 def + `rfl` bridge and Phase 2 completeness lemma
  already present.)
- `specs/335_outer_gate_assembly_engine_kvE2_body/plans/03_soundness-half-consume-333-lemmas.md`
  (this file).
- `specs/335_outer_gate_assembly_engine_kvE2_body/summaries/03_soundness-half-summary.md` (on
  completion).
- **Successor task (F4, NOT this task)**: a separate lean4 task for the F4 semantic `ℤ` LHS-FALSE
  discriminator + GO verdict (per `SubBracket.lean:231`), to be spawned once the ⇒ half lands.
- **Follow-on task (R-B, NOT this task)**: wire `bracketEndChar_kvE2` +
  `bracketEndChar_kvE2_correct_two_prior` into `KampPrior.lean:351`.

## Rollback/Contingency

- All 335 work is additive and isolated to `OuterGate.lean`. To revert new phases: `git checkout
  OuterGate.lean` to its Phase-2 state; the tree returns to the current landed state (⇐ half + def +
  bridge) with all carrier/soundness INPUTS untouched.
- **If 333's `kvE2_outer_fold` is not yet landed**: HALT Phase 4 (sequencing wait, not BLOCKED). Land
  Phases 1-3 (all independent of 333); resume Phase 4 once 333 plan-05 R4 is on disk, sorry-free.
- **If the SharedWitness↔OuterGate seam mismatches**: coordinate the exact `kvE2_outer_fold` statement
  with 333; re-shape on the 333/SharedWitness side (333's territory), never by weakening 335's
  statement or editing `SharedWitness.lean` from 335. Optionally split Phase 4 into 4a/4b.
- **If any phase concludes a landed 333/334/337/342 declaration must change**: STOP — this is 333's
  territory. Coordinate with 333; do not edit `SharedWitness.lean` from 335 and do not assume
  permission. Never commit a bare `sorry`, an assumed-`hgate`, a vacuous close, or an interiority
  hypothesis.
