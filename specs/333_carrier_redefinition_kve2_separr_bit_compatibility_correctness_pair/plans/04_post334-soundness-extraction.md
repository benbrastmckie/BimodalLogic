# Implementation Plan: Post-334 Soundness-Extraction Threading for the k=2 Carrier (task 333)

- **Task**: 333 - carrier_redefinition_kve2_separr_bit_compatibility_correctness_pair
- **Status**: [IMPLEMENTING]
- **Effort**: ~10-14 hours (4 phases, one agent run each)
- **Dependencies**: task 334 (COMPLETED — performed the chartered carrier redefinition: `kvE2_sepArr'` + `kvE2_sepDisjValidOwner`); task 321 (PARTIAL — predecessor lineage / O4 crux record)
- **Research Inputs**: reports/02_post334-soundness-extraction-frontier.md
- **Artifacts**: plans/04_post334-soundness-extraction.md (this file)
- **Standards**:
  - .claude/context/formats/plan-format.md
  - .claude/rules/artifact-formats.md
  - .claude/rules/state-management.md
  - .claude/rules/git-workflow.md
- **Type**: lean4

## Overview

Task 334 (COMPLETED) already performed the carrier redefinition that task 333 was originally
chartered to do: the interleaving-enumeration carrier is now `kvE2_sepArr'` with per-order-type
validity `kvE2_sepDisjValidOwner` (the cross-σ bit-compatibility filter), and non-vacuity is the
unconditional `kvE2_sepBody_complete`. As a result, **plan-01 is stale in every phase** — its
Phases 1-2 are done/deleted, its Phases 3-5 target deleted declarations (the entire
`kvE2_sepSingleton*` retreat block and both strategic sorries at the old `:1820`/`:1952` were
removed by 334), and its Phases 6-8 have moved to `OuterGate.lean` and changed shape. This plan
(v2) discards all of plan-01's phases and re-scopes task 333 to the single genuinely-open piece:
the **⇒ (soundness) half** of the k=2 carrier biconditional, `(kvE2_sepBody …).holds ⟹ ∃ w,
nf_eval_nf M 2 3 [w,x,t] qnf`. This is a **soundness-extraction threading** problem, not a carrier
edit: the missing cross-σ bit channel the pre-334 O4 crux declared absent now exists as
`kvE2_sepArr'_sound` (`SharedWitness.lean:6946`); the work is to thread its per-owner validity bits
into the forward-zone `hgate` conjunct, discharge the extraction chain's side-conditions, and
assemble the outer depth-2 fold — all as **additive soundness lemmas in `SharedWitness.lean` only**.

**Definition of done (this plan's re-scoped charter)**: the four SharedWitness soundness lemmas
(R1-R4) land sorry-free and axiom-clean on the `NfMultiAnchorBridge` import path, `lake build`
green, LITMUS grep 0 live hits, the carrier structure (`kvE2_sepArr'`/`kvE2_sepBody`) stays
byte-identical, and the R2-R4 lemmas are available for task 335 to consume in `OuterGate.lean` to
close its BLOCKED ⇒ half. This plan does **not** claim the OuterGate gate assembly (R5) or the F4
semantic ℤ discriminator (R6) — both are explicitly out of scope (see Territory Contract).

### Research Integration

- **reports/02_post334-soundness-extraction-frontier.md** (integrated in plan v2, 2026-07-09):
  supplies the post-334 ground-truth inventory (§A, all line anchors verified against HEAD
  `235d181ef`), the `hvalid`-residue resolution motivating the R1 cleanup (§B), the multi-positive
  correctness-pair frontier with the three open soundness sub-obligations (§C.2), the Phase-12
  N2-C gate + F4 status and the task-335 ownership overlap (§D), and the phase-sized frontier table
  (§E.2) that this plan's R1-R4 phases realize (dropping E.2's R5/R6 to their respective owners).
  Report supersedes the stale reports/01 (written against pre-334 HEAD `443684ae6`). Verified build
  state at plan time: `lake build …OuterGate` exit 0 (1014 jobs, warnings only); 0 live sorries on
  the whole `NfMultiAnchorBridge/` import path; key anchors re-confirmed this planning session
  (`kvE2_sepBody_nonvacuous` SW:2915, `kvE2_sepBody_complete` SW:3236, `kvE2_sepArr'_sound`
  SW:6946, `kvE2_sepBody_extract` SW:6356, `kvE2_sepBody_holds_of_honest` SW:9262,
  `kvE2_sepDisjunct_extract` SW:6195, `kvE2_sepDisjValidOwner` SW:1733).

### Source-to-Implementation Mapping (H3 — Tier 1: literature)

Ground truth: `~/Projects/Literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.md`.

| Source claim | Location | Implementation site | Phase |
|--------------|----------|---------------------|-------|
| Lemma 5.1: quantifier-free point types = `charBase χ` (depth-0) / `charK (nfk_projFresh σ)` (E[Σ]-atom) ONLY — no `fChainPred`, no bracket-in-bracket | rabinovich md:72, :134-135; `NavigatedSpine.lean:43-48` | no-nesting audit on every new soundness lemma; LITMUS grep 0 | R1-R4 (audit) |
| Lemma 3.2(1): the disjunction ranges over CONSISTENT interval-decomposition refinements | rabinovich md:77 | `kvE2_sepDisjValidOwner` is the consistency filter (334); R3 reads its bits, NEVER weakens it toward vacuity | R3 |
| Lemma 3.2(2): anchor cap 2 — everything over free variables `(x, t)` | rabinovich md:78 | outer depth-2 fold assembled over `(x, t)`; wrapper (task 335, out of scope) stated over `(x,t)` | R4 |

## Territory Contract (H7 — binding ownership scope)

This is an orchestrator-approved, user-binding ownership decision. Encode and honor it exactly.

- **Task 333 owns ONLY `SharedWitness.lean`.** `file_scope` is narrowed to
  `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/SharedWitness.lean`. All R1-R4
  work is additive soundness lemmas in this single file.
- **Task 333 MUST NOT edit `OuterGate.lean`.** Phase R5 of the research frontier
  (`bracketEndChar_kvE2_sound_two_prior` + the assembled `bracketEndChar_kvE2_correct_two_prior`,
  both in `OuterGate.lean`) is **task 335's territory** and is NOT part of this plan.
- **Task 335 is hereby GRANTED authorization** to consume task 333's R2-R4 lemmas to close its
  currently-BLOCKED ⇒ half. Task 335's stated block reason — "carrier REDEFINITION outside this
  task's additive scope … requires explicit orchestrator re-authorization … No such authorization
  is held" (`OuterGate.lean:194-201`) — is now **stale**: task 334 already performed the
  redefinition, and the remaining work is additive soundness lemmas, not a carrier edit. The
  authorization is scoped to "add soundness lemmas in SharedWitness (333) + consume in OuterGate
  (335); the carrier structure `kvE2_sepArr'`/`kvE2_sepDisjValidOwner`/`kvE2_sepBody` stays
  byte-identical."
- **F4 semantic ℤ discriminator (research frontier R6) is EXCLUDED from this plan.** It is strictly
  downstream of R5 (it needs the corrected carrier's evaluation direction), and `SubBracket.lean:231`
  already directs that it "requires the corrected carrier's evaluation … to be spawned as its own
  task." **No such task exists yet.** It should be spawned as its own task after R5 lands. When
  spawned, the F4 must genuinely DISCRIMINATE (LHS-FALSE at `(10,20)`; never weakened to pass),
  mirroring the `SubBracket.lean:44-264` F1-F4 verdict-record house style.

## Postmortem Constraints (carried forward — non-negotiable)

Binding rules for all R1-R4 dispatches. Derived from the task 321 exhaustion verdict, the O4 CRUX
RECORD (`SharedWitness.lean:6566-6659`), plan-01's postmortem section, and the Rabinovich
faithfulness constraints (research §"Faithfulness constraints carried forward").

**Do NOT**:
- **Do NOT weaken any filter toward vacuity.** `kvE2_sepDisjValidOwner` / `kvE2_sepDisjValid` is the
  consistency filter of Rabinovich Lemma 3.2(1) — the disjunction ranges over CONSISTENT
  refinements. If R3's bridge cannot be shown to close from the arrangement-selected bit, the fix is
  NOT to relax the filter; STOP and escalate (Rollback/Contingency).
- **Do NOT introduce a new `sorry`, `sorry` deferral, or assumed-`hgate` on any live path**
  (zero-debt). No vacuous placeholder. Final state: sorry-free on every live path, axiom-clean.
- **Do NOT introduce a `x1 < e_i` relative-position literal** on any live path (LITMUS). The
  soundness lemmas read arrangement slot **indices** and per-owner **validity bits**
  (`kvE2_sepDisjValidOwner`), never a model-order literal between a fresh witness and a slot.
- **Do NOT introduce a `fChainPred` term or nested point-type structure** (no-nesting, Lemma 5.1).
  Every point-type position stays `charBase χ` or `charK (nfk_projFresh σ)`.
- **Do NOT edit any do-not-edit asset.** `SubBracket2V.lean`, `NavigatedSpine.lean` engine bricks,
  `SubBracket.lean`, `SubBracket2.lean`, `Base.lean`, `CarrierK1V.lean`, `CarrierKv.lean`,
  `PriorInterface.lean`, and all sibling-Kamp files stay byte-identical. **`OuterGate.lean` stays
  byte-identical under task 333** (335's territory). The carrier structure `kvE2_sepArr'` /
  `kvE2_sepDisjValidOwner` / `kvE2_sepBody` stays byte-identical — all new work is **additive
  soundness lemmas only**.
- **Do NOT restate a global ∀-anchor claim** (FALSE at singleton size, SETTLED by the 321 lineage);
  the per-σ gate conjuncts are consumed at each extracted anchor, not via a global ∀-anchor.
- **Do NOT keep the L/R macro-side confinement invariant unaudited**: the L list carries only
  `(x,w)` slots and the R list only `(w,t)` slots — audit on every new lemma.

**MUST preserve / consume-only**:
- The landed ⇐ completeness chain: `kvE2_sepBody_complete` (SW:3236), `kvE2_sepBody_complete_holds`
  (SW:5705), `kvE2_sepHonestOrder'_mem_arr'` (SW:6120), `kvE2_sepBody_holds_of_honest` (SW:9262) —
  all consumed unchanged; NOT re-opened.
- The extraction chain `kvE2_sepDisjunct_extract` (SW:6195) and `kvE2_sepBody_extract` (SW:6356) —
  consumed; R2 discharges their `hpairL`/`hpairR`/`hnd` side-conditions on the soundness path.
- The new cross-σ bit channel `kvE2_sepArr'_sound` (SW:6946) — the make-or-break input to R3.
- The do-not-edit soundness kit in `SubBracket2V.lean`: `kvE_subBracket2V_sound_of_parts` (:1025),
  `kvE_subBracket2V_sound_of_outer` (:1216), `kvE_sub2V_bounded_anchor_of_outer` (:1182), the per-σ
  kit `kvE_subBracket2V_correctness_pair` (:1868-1882) — byte-identical; consumed only.

**Design decisions are SETTLED** (do not re-open without a concrete counterexample):
- **The carrier redefinition is DONE** (334): `kvE2_sepArr'` + `kvE2_sepDisjValidOwner` IS the
  bit-compatibility filtering the O4 crux prescribed (`SharedWitness.lean:6631-6634`). Task 333's
  remaining work is soundness-extraction threading, NOT a carrier edit.
- **`kvE2_sepBody_nonvacuous` (SW:2915) is dead** — its `hvalid` antecedent (about the STRICT
  `kvE2_sepModelOrder`) is not honestly attainable (at self-coincidence σ's OPEN `zXU`/`zUW` bits
  are FALSE; the honest disjunct is `kvE2_sepCoincidentOrder`). It has zero live consumers and is
  superseded by the unconditional `kvE2_sepBody_complete`.

## Goals & Non-Goals

- **Goals**:
  - R1: delete the dead `kvE2_sepBody_nonvacuous`; optionally sweep the strict `kvE2_sepModelOrder`
    cluster and add a one-line unconditional `.disjuncts ≠ []` corollary.
  - R2: prove the soundness-path `Pairwise`/`Nodup` side-condition lemmas over `kvE2_sepSlotsL/ROf
    wo` for arbitrary `wo ∈ kvE2_sepArr' qnf`, discharging `kvE2_sepBody_extract`'s
    `hpairL`/`hpairR`/`hnd`.
  - R3 (make-or-break): prove `kvE2_sepDisjValidOwner ⟹` the forward-zone `hgate` conjunct
    `σ.2 (nf0_assemble kvE_sub2_zXU χ σ.1) = true` from the arrangement-selected `kvE2_sepArr'_sound`
    bit at the realized placement.
  - R4: prove the outer depth-2 fold `kvE2_outer_fold` — reassemble `∃ w, nf_eval_nf M 2 3 [w,x,t]
    qnf` from the per-σ bundles + `ExistProviders.correct` + the navigated sub-chain.
- **Non-Goals**:
  - No edits outside `SharedWitness.lean`. In particular, **no edit to `OuterGate.lean`** (task 335).
  - No R5 gate assembly (`bracketEndChar_kvE2_sound_two_prior` /
    `bracketEndChar_kvE2_correct_two_prior`) — task 335 consumes R2-R4 for that.
  - No F4 semantic ℤ discriminator — spawn a separate task after R5 lands.
  - No carrier-structure edits; no de-privatization of any private declaration; no new axioms; no
    `sorry` deferral.

## Risks & Mitigations

- **Risk (HIGH — the make-or-break): R3 bridge does not close** — the arrangement-selected
  `kvE2_sepArr'_sound` bit does not yield the forward-zone `hgate` conjunct at the realized
  placement. *Mitigation*: strong prior it closes now, because `kvE2_sepDisjValidOwner` is precisely
  the cross-σ bit channel the O4 crux (SW:6610-6638) proved was missing and prescribed as the
  faithful repair; the arrangement that realized `.holds` is a specific `wo ∈ kvE2_sepArr'`, so its
  per-owner bits ARE the cross-σ compatibility facts the conjunct needs. **If it does not close:
  STOP and escalate** — never weaken a filter toward vacuity, never introduce `sorry`, never assume
  `hgate`.
- **Risk (MEDIUM): R2 landed `Pairwise`/`Nodup` lemmas are for the wrong relation/order.** The
  research note (§C.2 obligation 1) warns the existing lemmas "are stated for the wrong
  relation/order or are completeness-only." *Mitigation*: prove a fresh soundness-oriented pair over
  arbitrary `wo ∈ kvE2_sepArr' qnf` (not just the honest order); the Mathlib families needed
  (`List.Pairwise`/`List.Nodup`/`List.mem_filter`/`List.mem_map`) are already used in-file — no new
  Mathlib search.
- **Risk (MEDIUM): R4 outer fold has no landed depth-2 quant-layer engine.** `nf_quant_layer_fold_iff`
  (`NfEFold.lean:391`) folds depth-0 inner subs; the k=2 quant layer ranges over depth-1 subs.
  *Mitigation*: the `NavigatedSpine.lean:445` sketch of `kvE2_outer_fold` + `ExistProviders.correct`
  is the intended route; assemble from per-σ bundles rather than a generic fold engine. If it exceeds
  one agent run, split R4 into two sub-phases.
- **Risk (MEDIUM): R2-R4 land but task 335 cannot consume them** (signature mismatch at the
  SharedWitness↔OuterGate seam). *Mitigation*: state each R2-R4 lemma in the shape
  `kvE2_sepBody_extract` / the OuterGate ⇒ path expects (per §C.2 / `OuterGate.lean:172-201`); this
  is a plan-time interface constraint, coordinate the exact statement with 335's consumer.
- **Risk (LOW): R1 reference sweep misses a live consumer of `kvE2_sepModelOrder`.** *Mitigation*:
  gate the optional strict-order cluster deletion behind a full reference sweep; do NOT delete
  `kvE2_sepArr'_mem_modelOrder` (SW:1888) or anything with live consumers. The mandatory R1 deletion
  (`kvE2_sepBody_nonvacuous`, zero live consumers) is independent and LOW-risk.
- **Risk (LOW): axiom triple of the ⇐ chain is UNVERIFIED-by-lean_verify.** The research report
  marks the exact `[propext, Classical.choice, Quot.sound]` triple of `kvE2_sepBody_complete` /
  `kvE2_sepArr'_sound` / `kvE2_sepBody_holds_of_honest` as grounded only by a green build + prose,
  not a per-declaration check. *Mitigation*: the R1 pre-task runs `lean_verify` on all three before
  any lemma builds on them (see below).

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |

**No phases run in parallel.** Every phase edits the single file `SharedWitness.lean` (H7 territory
contract: exclusive ownership, no overlap possible), and each phase builds on the prior phase's
lemmas being in place (R2's side-conditions feed R3's extraction; R3's bridge feeds R4's fold). The
wave map is therefore strictly sequential — one phase per wave. (Each phase's `R{n}` prefix is the
readable label from research §E.2, retained for cross-reference; the plain integer `1`-`4` is the
canonical phase number used by the wave table, `Depends on` fields, and `/implement` resume logic.)

### Phase 1: R1 — Cleanup: delete dead `kvE2_sepBody_nonvacuous`; re-verify the ⇐ axiom triple [COMPLETED 2026-07-09]

<!-- Phase 1 done (2026-07-09): axiom triple re-confirmed [propext, Classical.choice, Quot.sound]
on kvE2_sepBody_complete / kvE2_sepArr'_sound / kvE2_sepBody_holds_of_honest (all axiom-clean, no
sorryAx). Deleted dead `kvE2_sepBody_nonvacuous` (zero live consumers, superseded by
kvE2_sepBody_complete). Build green; OuterGate green; LITMUS 0 live. Optional corollary and
strict-order cluster sweep SKIPPED (deviation: optional, no consumer, risk-free skip). -->


- **MANDATORY FIRST ACTION (pre-task, before any edit):** Run `lean_verify` on
  `kvE2_sepBody_complete`, `kvE2_sepArr'_sound`, and `kvE2_sepBody_holds_of_honest` to re-confirm the
  axiom triple `[propext, Classical.choice, Quot.sound]`. The research report marks this exact triple
  as **UNVERIFIED-by-lean_verify** (grounded only by a green `lake build …OuterGate` and by cluster
  summaries, not by a per-declaration check). Do NOT build any R2-R4 lemma on these three ⇐-chain
  declarations before this re-confirmation. If any of the three carries an unexpected axiom, STOP and
  report before proceeding.
- **Goal:** Remove the dead conditional non-vacuity lemma and, optionally, its strict-order support
  cluster, replacing it (if a corollary is wanted) with an unconditional `.disjuncts ≠ []`
  one-liner. This is LOW-risk cleanup that clears the stale `hvalid` residue.
- **Tasks:**
  - [ ] Run the mandatory `lean_verify` pre-task above; record the axiom footprint inline.
  - [ ] Delete `kvE2_sepBody_nonvacuous` (`SharedWitness.lean:2915`). It is conditioned on
        `hvalid : kvE2_sepDisjValid qnf (kvE2_sepModelOrder qnf) = true`, which 334 proved is NOT
        honestly attainable (the strict `kvE2_sepModelOrder` reads σ's OPEN `zXU`/`zUW` bit at σ's own
        fresh type, FALSE at self-coincidence; the honest disjunct is the coincidence order
        `kvE2_sepCoincidentOrder`). It has **zero live consumers** (all three mentions SW:910, :6668,
        :6703 are docstring / O4-record prose) and is superseded by the unconditional
        `kvE2_sepBody_complete` (SW:3236).
  - [ ] (Optional) Add a one-line unconditional `.disjuncts ≠ []` corollary derived from
        `kvE2_sepBody_complete` + `List.map_ne_nil` (uses `kvE2_sepBody.disjuncts = (kvE2_sepArr'
        qnf).map …`, SW:2351), for API symmetry.
  - [ ] (Optional) After a full reference sweep, remove the strict `kvE2_sepModelOrder` cluster
        (SW:1476 + `_mem_orderTypes` SW:1871). **Gate behind the sweep** — do NOT regress any live
        proof (e.g. keep `kvE2_sepArr'_mem_modelOrder` SW:1888 if still consumed).
  - [ ] LITMUS grep (`grep -nE "fChainPred|x1[[:space:]]*<[[:space:]]*e"`) = 0 live hits; no-nesting
        audit on any added corollary.
- **Timing:** ~1-2 hours.
- **Depends on:** none
- **Estimated output:** ~30-100 lines (deletions + optional one-line corollary; net may be negative).
- **Sorry-count target:** 0 (path is already 0-sorry; no new sorry introduced).
- **Done when:** the `lean_verify` triple re-confirmed `[propext, Classical.choice, Quot.sound]`;
  `lake build …SharedWitness` exit 0; `kvE2_sepBody_nonvacuous` removed (grep-0);
  `lake build …OuterGate` still exit 0 (no downstream regression); LITMUS 0 hits; `git diff --stat`
  touches only `SharedWitness.lean`.

### Phase 2: R2 — Soundness side-conditions: `Pairwise`/`Nodup` over arbitrary `wo ∈ kvE2_sepArr'` [NOT STARTED]

- **Goal:** Prove the soundness-oriented `Pairwise`/`Nodup` lemmas over `kvE2_sepSlotsL/ROf wo` for
  **arbitrary** `wo ∈ kvE2_sepArr' qnf` (not just the honest order), discharging
  `kvE2_sepBody_extract`'s `hpairL`/`hpairR`/`hnd` hypotheses on the soundness path (§C.2 obligation
  1). The landed lemmas are stated for the wrong relation/order or are completeness-only, so a fresh
  pair is needed.
- **Tasks:**
  - [ ] Prove `∀ wo ∈ kvE2_sepArr' qnf, (kvE2_sepSlotsL Of wo).Pairwise (kvE2_sepSlotLe · · = true)`
        and the R analogue (`hpairL`/`hpairR` shape at `OuterGate.lean:172-201` /
        `SharedWitness.lean:6356`).
  - [ ] Prove `∀ wo ∈ kvE2_sepArr' qnf, ((kvE2_sepSlotsL/ROf wo).map (kvE2_sepSlotGIdx wo)).Nodup`
        (`hnd` shape).
  - [ ] Derive these from `wo ∈ kvE2_sepArr'` (i.e. `wo` is a valid weak order) via the in-file
        `List.Pairwise`/`List.Nodup`/`List.mem_filter`/`List.mem_map` families — no new Mathlib
        search (research §C.3: bespoke transcription, not a Mathlib-gap task).
  - [ ] State each lemma in the exact shape `kvE2_sepBody_extract` consumes so task 335 can thread
        them into the OuterGate ⇒ path unchanged.
  - [ ] Macro-side confinement audit (L only `(x,w)`, R only `(w,t)`); LITMUS 0 hits; no-nesting.
- **Timing:** ~2-3 hours.
- **Depends on:** 1
- **Estimated output:** ~120-250 lines (two Pairwise lemmas + two Nodup lemmas + glue).
- **Sorry-count target:** 0.
- **Done when:** `lake build …SharedWitness` exit 0; the four side-condition lemmas proven,
  sorry-free + axiom-clean via `lean_verify`; they discharge `kvE2_sepBody_extract`'s
  `hpairL`/`hpairR`/`hnd` for arbitrary `wo`; LITMUS 0 hits; diff only `SharedWitness.lean`.

### Phase 3: R3 — The bit-compat bridge: `kvE2_sepDisjValidOwner ⟹` forward-zone `hgate` conjunct (make-or-break) [NOT STARTED]

- **Goal:** Prove that `kvE2_sepDisjValidOwner` implies the cross-σ forward-zone `hgate` conjunct
  `σ.2 (nf0_assemble kvE_sub2_zXU χ σ.1) = true` from the arrangement-selected `kvE2_sepArr'_sound`
  bit (`SharedWitness.lean:6946`) at the realized placement (§C.2 obligation 2). **This is the exact
  crux the whole 321→333 lineage has orbited** (pre-334 O4 crux, SW:6588: the forward-zone conjunct
  at a cross-σ slot point was underdetermined). The new `kvE2_sepDisjValidOwner` channel is the
  intended, faithful resolution.
- **Tasks:**
  - [ ] From `wo ∈ kvE2_sepArr' qnf` (the arrangement that realized `.holds`), apply
        `kvE2_sepArr'_sound` (SW:6946) to obtain `∀ p ∈ wo, kvE2_sepDisjValidOwner p.1 p.2.1 = true`
        (plus `anchorDistinct` and `tieRead`).
  - [ ] At the realized placement of a cross-σ slot (owner σ, realizing χ), read the per-owner
        validity bit and derive the `SubBracket2V` forward-zone conjunct `σ.2 (nf0_assemble
        kvE_sub2_zXU χ σ.1) = true` (`SubBracket2V.lean:1868-1882`, do-not-edit, consumed only).
  - [ ] Confirm the bit read is at σ's placement-generic outer zone class, matching the conjunct's
        `kvE_sub2_zXU` reading — NEVER an `x1 < e_i` literal (LITMUS).
  - [ ] **If the bridge does not close: STOP and escalate.** Capture the `lean_goal`; do NOT weaken
        `kvE2_sepDisjValidOwner`/`kvE2_sepDisjValid` toward vacuity; do NOT introduce a `sorry`; do
        NOT assume `hgate`. Report that the redefinition-channel prescription needs revision (see
        Rollback/Contingency).
  - [ ] LITMUS 0 hits; no-nesting audit; macro-side confinement audit.
- **Timing:** ~3-4 hours (make-or-break).
- **Depends on:** 2
- **Estimated output:** ~150-300 lines. If the bridge proof alone exceeds ~300 lines, split into R3.1
  (bit extraction from `kvE2_sepArr'_sound` at the placement) and R3.2 (conjunct assembly into the
  `SubBracket2V` shape).
- **Sorry-count target:** 0 (a `sorry` here is prohibited — this is the zero-debt crux).
- **Done when:** `lake build …SharedWitness` exit 0; the `kvE2_sepDisjValidOwner ⟹ forward-zone
  conjunct` bridge proven, sorry-free + axiom-clean via `lean_verify`; NO filter weakened, NO `hgate`
  assumed; LITMUS 0 hits; diff only `SharedWitness.lean`. (On failure: uncommitted, escalated.)

### Phase 4: R4 — Outer depth-2 fold: `kvE2_outer_fold` [NOT STARTED]

- **Goal:** Prove `kvE2_outer_fold`: reassemble `∃ w, nf_eval_nf M 2 3 [w,x,t] qnf` from the per-σ
  bundles + `ExistProviders.correct` + the navigated sub-chain (§C.2 obligation 3; sketch at
  `NavigatedSpine.lean:445`). There is no landed depth-2 quant-layer fold engine
  (`nf_quant_layer_fold_iff`, `NfEFold.lean:391`, folds depth-0 inner subs; the k=2 quant layer
  ranges over depth-1 subs), so this assembles from the per-σ bundles rather than a generic fold.
- **Tasks:**
  - [ ] From the per-σ bundles surfaced by `kvE2_sepBody_extract` (with R2's side-conditions
        discharged) and the forward-zone conjunct from R3, assemble each σ's depth-1 realization at a
        shared pivot `w` with `x<w<t`.
  - [ ] Use `ExistProviders.correct` and the navigated sub-chain (`NavigatedSpine.lean:445`) to fold
        the per-σ realizations into `∃ w, nf_eval_nf M 2 3 [w,x,t] qnf`. Consume-only the do-not-edit
        `NavigatedSpine.lean` engine bricks.
  - [ ] No `x1 < e_i` literal (LITMUS); no nested point types (no-nesting); L/R confinement audit.
  - [ ] State `kvE2_outer_fold` in the shape task 335's `bracketEndChar_kvE2_sound_two_prior` will
        consume (the OuterGate ⇒ path); coordinate the exact interface with 335's consumer.
- **Timing:** ~3-4 hours.
- **Depends on:** 3
- **Estimated output:** ~150-300 lines. If the fold assembly exceeds ~300 lines, split into R4.1
  (per-σ depth-1 realization assembly) and R4.2 (outer `∃ w` fold via `ExistProviders.correct`).
- **Sorry-count target:** 0.
- **Done when:** `lake build …SharedWitness` exit 0; `kvE2_outer_fold` proven, sorry-free +
  axiom-clean via `lean_verify`; the R2-R4 lemma set is available and shaped for task 335's OuterGate
  ⇒ path; LITMUS 0 hits; diff only `SharedWitness.lean`.

## Testing & Validation

Per-phase invariants (run at every phase's Done-when):
- [ ] `lake build Theories.Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.SharedWitness`
      exit 0; `lake build …OuterGate` exit 0 at R1 (no downstream regression) and after R4.
- [ ] Sorry inventory: `grep -nw "sorry" …/SharedWitness.lean` shows only comment/docstring hits —
      **0 live sorries** at every phase (the import path is already 0-sorry; no new sorry allowed).
- [ ] `lean_verify` axiom-clean (`[propext, Classical.choice, Quot.sound]`) on new/changed symbols;
      R1 pre-task additionally re-verifies the three ⇐-chain declarations.
- [ ] LITMUS grep `grep -nE "fChainPred|x1[[:space:]]*<[[:space:]]*e"` = 0 live hits on new lemmas.
- [ ] No-nesting audit: every point-type position is `charBase χ` or `charK (nfk_projFresh σ)`.
- [ ] Macro-side confinement: L list only `(x,w)` slots, R list only `(w,t)` slots.
- [ ] `git diff --stat` touches only `SharedWitness.lean`; `OuterGate.lean` and all do-not-edit
      assets (incl. the carrier structure `kvE2_sepArr'`/`kvE2_sepDisjValidOwner`/`kvE2_sepBody`)
      byte-identical.

## Artifacts & Outputs

- plans/04_post334-soundness-extraction.md (this file)
- Modified: `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/SharedWitness.lean`
  (R1 cleanup deletion; R2 soundness side-condition lemmas; R3 bit-compat bridge; R4 outer depth-2
  fold — all additive soundness lemmas, carrier structure byte-identical)
- summaries/04_post334-soundness-extraction-summary.md (on completion)
- Follow-on (NOT this task): task 335 consumes R2-R4 to close the OuterGate ⇒ half (R5); a new
  task to be spawned after R5 lands for the F4 semantic ℤ discriminator (R6).

## Rollback/Contingency

- **Per-phase git discipline**: commit each phase at its green Done-when
  (`task 333 phase R{n}: …`). Any phase that fails its build-green stays uncommitted; fix forward
  (never discard uncommitted work — snapshot via `.claude/scripts/git-snapshot.sh` before any
  intentional rollback).
- **R3 (make-or-break) fails**: if the `kvE2_sepDisjValidOwner ⟹ forward-zone conjunct` bridge does
  not close from the arrangement-selected `kvE2_sepArr'_sound` bit, STOP and escalate. Capture the
  `lean_goal`. Do NOT weaken `kvE2_sepDisjValidOwner`/`kvE2_sepDisjValid` toward vacuity; do NOT
  introduce a `sorry`; do NOT assume `hgate`. This would indicate the O4-crux redefinition
  prescription itself needs revision — a research escalation, not an implementation workaround.
- **R4 outer fold has no viable assembly route**: if `ExistProviders.correct` + the
  `NavigatedSpine.lean:445` sketch do not fold, STOP and `/spawn` a scoped research task for the
  depth-2 quant-layer fold engine; do NOT fabricate a fold or weaken the statement.
- **Task 335 cannot consume R2-R4** (interface mismatch): coordinate the exact lemma statements with
  335's `OuterGate.lean:172-201` consumer before finalizing; re-shape in `SharedWitness.lean` (333
  territory) rather than editing `OuterGate.lean`.
- **Full revert**: because all edits are confined to `SharedWitness.lean`, a full rollback is
  `git checkout 235d181ef -- …/SharedWitness.lean` (only after a snapshot per the dirty-tree rule).
