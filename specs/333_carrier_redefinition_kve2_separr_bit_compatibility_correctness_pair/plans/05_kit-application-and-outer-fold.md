# Implementation Plan: Per-σ Kit Application and the Outer Depth-2 Fold for the k=2 Carrier (task 333)

- **Task**: 333 - carrier_redefinition_kve2_separr_bit_compatibility_correctness_pair
- **Status**: [IN PROGRESS]
- **Effort**: ~7-9 hours remaining (Phase 1 COMPLETED; 3 phases open, one agent run each)
- **Dependencies**: task 334 (COMPLETED — chartered carrier redefinition: `kvE2_sepArr'` + `kvE2_sepDisjValidOwner`); task 342 (COMPLETED — interior-restricted owner index `kvE2_sepPosI`, tie-admitting weak orders, `hLR` deleted; postdates plan-02's assumptions); task 321 (PARTIAL — predecessor lineage / now-DISSOLVED O4 crux record)
- **Research Inputs**: reports/03_pdf-fidelity-r3-dissolved-regrounding.md (authoritative); reports/02_post334-soundness-extraction-frontier.md (partly superseded — its §C.2 obligation 2 is the mistaken R3)
- **Artifacts**: plans/05_kit-application-and-outer-fold.md (this file)
- **Standards**:
  - .claude/context/formats/plan-format.md
  - .claude/rules/artifact-formats.md
  - .claude/rules/state-management.md
  - .claude/rules/git-workflow.md
- **Type**: lean4

## Overview

This plan (v3) **restructures** the superseded plan-02 (`plans/04_post334-soundness-extraction.md`)
following the hard-mode, PDF-grounded, adversarially-verified (H4) re-grounding in
`reports/03_*`. An implementation of plan-02 was HALTED mid-flight after two contaminations were
found: (1) the Rabinovich `.md` used for citations was a hand-written paraphrase, replaced today by
a PDF text-extract that **drops every displayed equation** and **semantically inverts `k ≠ m` to
`k = m`**, dangling all `md:NN` citations; and (2) task 342 (`[COMPLETED]`, interior-restricted owner
index `kvE2_sepPosI` + tie-admitting weak orders, `hLR` deleted) landed in HEAD and postdates
plan-02's assumptions.

The central re-grounding finding (H4-verified against HEAD `924d76c49`): **plan-02's Phase 3 (R3)
was the WRONG obligation.** R3 asked to *prove* the forward-zone conjunct
`σ.2 (nf0_assemble kvE_sub2_zXU χ σ.1) = true`. In current HEAD that conjunct is **never a goal** —
it is uniformly the *antecedent* of a per-owner `bit ⟹ witness` implication in `kvE2_sepBundleL`
(SW:5117) and `kvE_subBracket2V_extract` (SubBracket2V), with the bit supplied by each owner's own
arrangement enumeration. The gate `kvE2_sepGate` (SW:1238) has four clauses, all concluding
`= false`; it never demands a bit be true. The landed sorry-free `kvE2_sepBody_extract` (SW:6328)
already produces the bundles via `kvE2_sepDisjunct_extract` (SW:6167). The SW:6556 comment
("`kvE2_sepSlotLe` leaves cross-σ order free") sits inside a record self-annotated "additive and
inert"; **cross-σ order freedom is INTENDED design post-342, not a bug.** Pursuing R3 is re-fighting
the dissolved, inert task-321 O4 crux.

Accordingly this plan: keeps R1 (already DONE, committed green) marked `[COMPLETED]`; keeps R2
(`Pairwise`/`Nodup` side-conditions) unchanged and mechanical; **deletes the old R3** and replaces
it with a **small per-σ kit-application phase**; and **promotes R4** (`kvE2_outer_fold`) to the true
make-or-break. All citations are re-grounded to **PDF page numbers** (`Rabinovich 2014, p.N`); no
`md:NN` citation is used.

**Definition of done (re-scoped charter)**: the remaining SharedWitness soundness lemmas (R2, the
per-σ kit application, R4) land sorry-free and axiom-clean on the `NfMultiAnchorBridge` import path,
`lake build` green, LITMUS grep 0 live hits, the carrier structure
(`kvE2_sepArr'`/`kvE2_sepBody`) stays byte-identical, and the R2/kit/R4 lemmas are available for task
335 to consume in `OuterGate.lean` to close its BLOCKED ⇒ half. This plan does **not** claim the
OuterGate gate assembly nor the F4 semantic ℤ discriminator (both out of scope — see Territory
Contract and Non-Goals).

### Research Integration

- **reports/03_pdf-fidelity-r3-dissolved-regrounding.md** (integrated in plan v3, 2026-07-09):
  the authoritative input. Supplies (a) the PDF fidelity audit proving the re-extracted `.md` is
  unsafe for any formula-level citation and that 89 in-code `md:NN` citations in `SharedWitness.lean`
  now dangle; (b) the re-grounded H3 source-to-implementation map by PDF page (§A, adopted below);
  (c) the breakthrough ledger (321→342) naming the recurring axis (strict-vs-coincident order /
  open-vs-closed bit) and confirming the crux is DISSOLVED; (d) the code-verified proof (Part C, H4
  refutation attempts 1-3) that plan-02's R3 targets a goal that does not exist at HEAD — the
  forward-zone conjunct is antecedent-only at its three live sites (SW:5117, :5175, :5289); and (e)
  the RESTRUCTURE recommendation (Part D) realized by this plan's phases. HEAD at research time:
  `924d76c49` (the Phase-1/R1 child of snapshot `235d181ef`).
- **reports/02_post334-soundness-extraction-frontier.md** (integrated in plan v2, carried into v3,
  2026-07-09): supplies the post-334 ground-truth inventory (§A), the `hvalid`-residue resolution
  that motivated the R1 cleanup (§B), and the extraction-chain residue (§C.2). **Partly superseded by
  report 03**: its §C.2 obligation 2 (the "make-or-break `kvE2_sepDisjValidOwner ⟹` forward-zone
  conjunct bridge") is the **mistaken R3** that report 03 dissolves; treat that specific obligation
  as retracted, but its obligations 1 (side-conditions = R2) and 3 (outer fold = R4) stand.

### Source-to-Implementation Mapping (H3 — Tier 1: literature, re-grounded to PDF pages)

Ground truth: `~/Projects/Literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.pdf`
(16 pp., cited by PAGE only). **Never cite `md:NN`** — the re-extracted `.md` drops every displayed
equation and inverts an inline negation; all line-number anchors dangle after today's swap. This
table **replaces** plan-02's `md:NN` H3 table.

| Source claim | PDF location | Lean identifier (HEAD 924d76c49) | Phase |
|--------------|--------------|----------------------------------|-------|
| Def 3.1: strict chain `x_n > … > x_0`, pinning indices `i_k` with **no distinctness** ⇒ tie-collapse forced (coincident owners merge onto one strict slot) | **p.4** | `KvE2SepSpikeOrderType` (SW:1258), `kvE2_sepDisjValid` tie conjunct `kvE2_sepTieRead` (SW:~1758) | consumed (all) |
| Lemma 3.2(1): conjunction ≡ disjunction of ⃗∃∀ — **stated, no printed proof** ("It is clear that") | **p.4** | `kvE2_sepArr'` / `kvE2_sepDisjValid` (per-order-type filter) | consumed (all) |
| Lemma 3.2(2): anchor cap 2 — ≤ two free variables `(x,t)` | **p.4** | outer depth-2 fold over `(x,t)` (R4 target `kvE2_outer_fold`) | 4 |
| Lemma 5.1, formula (5.1): QF point types, open-interval betweens, both ends pinned (`z₀=x₀`, `z₁=x_n`) | **p.7** | `kvE2_sepPtX1L/R` point types = `charBase` / `charK (nfk_projFresh σ)`; no `fChainPred`, no nesting (LITMUS) | 2, 3, 4 (audit) |
| Notation 5.2: `[α₀,β₁,…,α_n](z₀,z₁)` abbreviates (5.1) | **pp.7-8** | per-owner bracket bundle shape | 3 |
| Lemma 5.3 + INF (5.2): `¬∃`-chain ≡ `O_n(P₁,…,P_n,z₀,z₁)` | **p.8** | navigated `¬∃` interval decomposition | 3, 4 (audit) |
| Cor 5.4 fold `F_{i-1} := α_{i-1} ∧ (β_i Until F_i)` | **p.9** | navigated fold (task-330 verdict); `NavigatedSpine.lean` | 4 |
| Def 7.5: 3-alternative `z₀ > z₁ ∨ z₀ = z₁ ∨ [bracket]` (NOT half-open) | **p.13** | tie-admitting validity, coincidence a first-class disjunct | consumed (all) |
| §5 ψ0/ψ1/φ split (interiority a construction invariant) | **p.7** | `kvE2_sepPosI` (interior-restricted owner index, 222× in HEAD, task 342) | consumed (all) |

**Mandated citation form for Def 3.1 / Lemma 3.2 (from 342, verbatim):** *"the construction forced
by Def 3.1 (p.4), corroborated by the k=m split (p.7) and Def 7.5 (p.13); Lemma 3.2(1) (p.4) states
the closure without printed proof."* Any new load-bearing docstring uses this page-cited form.

## Goals & Non-Goals

- **Goals**:
  - Phase 1 (R1): **DONE** — dead `kvE2_sepBody_nonvacuous` deleted, ⇐ axiom triple re-verified;
    committed green at `924d76c49`. Carried forward as `[COMPLETED]`; not re-planned.
  - Phase 2 (R2): prove the soundness-path `Pairwise`/`Nodup` side-condition lemmas over
    `kvE2_sepSlotsL/ROf wo` for arbitrary `wo ∈ kvE2_sepArr' qnf`, discharging
    `kvE2_sepBody_extract`'s `hpairL`/`hpairR`/`hnd` (SW:6331-6340). **Unchanged from plan-02;
    mechanical.**
  - Phase 3 (NEW per-σ kit application, small): thread the per-owner bundles produced by the landed
    sorry-free `kvE2_sepBody_extract` (SW:6328) through `kvE2_sepBundleL_parts` (SW:5167) /
    `kvE2_sepBundleR_parts` (SW:5184) into `kvE_subBracket2V_sound_of_parts` (SubBracket2V:1025) to
    obtain each positive owner's `nf_eval`. This is a **kit application**, NOT a bit-proof and NOT the
    make-or-break. Verify the right-interior class kit application lands (the one genuine residual;
    MEDIUM — see Risks).
  - Phase 4 (R4, promoted make-or-break): prove `kvE2_outer_fold` — reassemble
    `∃ w, nf_eval_nf M 2 3 [w,x,t] qnf` from the per-σ bundles + `ExistProviders.correct` + the
    navigated sub-chain (`NavigatedSpine.lean:445` sketch).
- **Non-Goals**:
  - No edits outside `SharedWitness.lean`. In particular, **no edit to `OuterGate.lean`** (task 335's
    file).
  - **The old plan-02 R3 obligation is DELETED**, not re-attempted: "prove the forward-zone conjunct
    `σ.2 (nf0_assemble kvE_sub2_zXU χ σ.1) = true` true" is the wrong obligation (antecedent-only at
    HEAD). No phase pursues it.
  - No R5 gate assembly (`bracketEndChar_kvE2_sound_two_prior` /
    `bracketEndChar_kvE2_correct_two_prior`) — task 335 consumes this plan's lemmas for that.
  - No F4 semantic ℤ discriminator — OUT OF SCOPE; spawn a separate task after 335's R5 lands.
  - No carrier-structure edits; no de-privatization; no new axioms; no `sorry` deferral.
  - This plan does **not** fix the 89 dangling in-code `md:NN` citations in `SharedWitness.lean` (a
    deliberate user decision — see Risks: KNOWN hazard).

## Risks & Mitigations

- **Risk (HIGH — the true make-or-break: Phase 4 outer fold has no landed depth-2 quant-layer
  engine).** `nf_quant_layer_fold_iff` (`NfEFold.lean:391`) folds depth-0 inner subs; the k=2 quant
  layer ranges over depth-1 subs. *Mitigation*: `kvE2_sepBundleL_parts` (SW:5167) and
  `kvE2_sepBundleR_parts` (SW:5184) already reduce a bundle to the `kvE_subBracket2V_sound_of_parts`
  (SubBracket2V:1025) input, so the per-σ application is near-mechanical; the open difficulty is
  purely the outer `∃ w` fold. Assemble from per-σ realizations via `ExistProviders.correct` + the
  `NavigatedSpine.lean:445` sketch, not a generic fold engine. If no viable route exists, `/spawn` a
  scoped depth-2 quant-layer-fold research task — **do NOT fabricate a fold or weaken the statement.**
- **Risk (MEDIUM — the one genuine residual: right-interior class kit application).** The
  `kvE2_sepBundleR` docstring (SW:5138) carries a Phase-7-era note "no landed per-σ correctness kit
  serves this class yet." H4 refutation attempt 3 confirmed this is a *residual to verify*, not a
  revival of R3: `kvE2_sepBundleR_parts` (SW:5184) exists and targets the **same**
  `kvE_subBracket2V_sound_of_parts` (SubBracket2V:1025) as the left class. *Mitigation*: exercise the
  right-class kit application explicitly in Phase 3 and confirm it discharges; if it does not, the
  fix is a kit-application lemma in `SharedWitness.lean` (333 territory), never a filter weakening.
- **Risk (MEDIUM): R2 landed `Pairwise`/`Nodup` lemmas are for the wrong relation/order.** The landed
  `kvE2_sepSlotsLFor_rank_sorted` (SW:745) is per-σ (For-list), not the merged `Of`-list over
  arbitrary `wo`; `kvE2_sepSlotsLOf_nodup` (SW:4299) is `Nodup` of the slots, not of
  `.map kvE2_sepSlotGIdx`. *Mitigation*: prove a fresh soundness-oriented pair over arbitrary
  `wo ∈ kvE2_sepArr' qnf` using the in-file `List.Pairwise`/`List.Nodup`/`List.mem_filter`/
  `List.mem_map` families — no new Mathlib search (report §C.3: bespoke transcription, not a
  Mathlib-gap task).
- **Risk (MEDIUM): the per-σ/kit/fold lemmas land but task 335 cannot consume them** (signature
  mismatch at the SharedWitness↔OuterGate seam). *Mitigation*: state each lemma in the shape
  `kvE2_sepBody_extract` / the OuterGate ⇒ path expects (`OuterGate.lean:172-201`); coordinate the
  exact statement with 335's consumer. Re-shape in `SharedWitness.lean` (333 territory) rather than
  editing `OuterGate.lean`.
- **Risk (LOW — regression from a stale premise): treating the SW:6556 "cross-σ order free" comment
  or the O4 crux record as a live blocker.** *Mitigation*: it is INTENDED design post-342
  (arrangement-awareness moved from the `kvE2_sepSlotLe` comparator into the `kvE2_sepDisjValid`
  filter); the record self-annotates "additive and inert." Do not re-open it; do not pursue the
  deleted R3.
- **KNOWN, DOCUMENTED hazard (NOT fixed by this task — deliberate user decision): 89 dangling
  `md:NN` citations in `SharedWitness.lean`.** After today's `.md` replacement, every in-code
  `md:NN` anchor (md:77 ×27, md:168 ×24, md:154 ×9, md:72 ×8, …) points to shifted or blank content.
  **Future readers must not trust these `md:NN` in-code citations.** This plan neither relies on them
  nor repairs them; new docstrings use PDF page numbers per the H3 table above.

## Task 335 coordination (informational — 335 is NOT edited by this task)

Task 335 retains the authorization (granted in plan-02's Territory Contract) to consume task 333's
additive soundness lemmas to close its ⇒ half in `OuterGate.lean`. **335's BLOCKED record
(`OuterGate.lean:180-203`) is doubly stale:** (a) it names redefining `kvE2_sepValid` /
`kvE2_sepArrL` / `kvE2_sepArrR`, which have **0 declarations remaining** at HEAD (all deleted by
334/342); and (b) it claims **no authorization is held**, which is **false** — the authorization was
granted and no carrier edit is needed. 335's real remaining need is exactly "R2 + the per-σ kit +
R4 landed and shaped for its consumer"; once landed, `bracketEndChar_kvE2_sound_two_prior` wraps
`kvE2_outer_fold`. Updating 335's record is out of this plan's file scope (SharedWitness only).

## Territory Contract (H7 — binding ownership scope)

Orchestrator-approved, user-binding. Encode and honor exactly.

- **Task 333 owns ONLY `SharedWitness.lean`.** `file_scope` stays narrowed to
  `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/SharedWitness.lean`. All Phase
  2/3/4 work is additive soundness lemmas in this single file.
- **Task 333 MUST NOT edit `OuterGate.lean`** (task 335's file). It stays byte-identical under
  task 333.
- **Task 335 is GRANTED authorization** (carried from plan-02) to consume task 333's R2/kit/R4
  lemmas to close its BLOCKED ⇒ half in `OuterGate.lean`. Scope: "add soundness lemmas in
  SharedWitness (333) + consume in OuterGate (335); the carrier structure
  `kvE2_sepArr'`/`kvE2_sepDisjValidOwner`/`kvE2_sepBody` stays byte-identical."
- **Carrier structure `kvE2_sepArr'` / `kvE2_sepBody` stays byte-identical**; work is additive
  soundness lemmas only. All do-not-edit assets (`SubBracket2V.lean`, `NavigatedSpine.lean` engine
  bricks, `SubBracket.lean`, `SubBracket2.lean`, `Base.lean`, `CarrierK1V.lean`, `CarrierKv.lean`,
  `PriorInterface.lean`, sibling-Kamp files) stay byte-identical.
- **F4 semantic ℤ discriminator is EXCLUDED.** It is strictly downstream of 335's R5 (needs the
  corrected carrier's evaluation direction). Spawn it as its own task after R5 lands; when spawned it
  must genuinely DISCRIMINATE (LHS-FALSE at `(10,20)`; never weakened to pass), mirroring
  `SubBracket.lean:44-264` house style.

## Postmortem Constraints (carried forward — non-negotiable)

Binding for every phase dispatch.

**Do NOT**:
- **Do NOT pursue the deleted plan-02 R3.** The forward-zone conjunct
  `σ.2 (nf0_assemble kvE_sub2_zXU χ σ.1) = true` is the *antecedent* of a per-owner `bit ⟹ witness`
  implication (`kvE2_sepBundleL` SW:5117; `kvE_subBracket2V_extract`), never a goal. `kvE2_sepGate`
  (SW:1238) is four falsity-only clauses. The bit is supplied by each owner's own arrangement
  enumeration, self-owned. Do not try to "prove the bit true."
- **Do NOT weaken any filter toward vacuity.** `kvE2_sepDisjValidOwner` / `kvE2_sepDisjValid` is the
  consistency filter of Lemma 3.2(1) (p.4). If a kit application or the fold cannot be shown to
  close, the fix is NOT to relax the filter; STOP and escalate (Rollback/Contingency).
- **Do NOT introduce a new `sorry`, `sorry` deferral, or assumed-`hgate` on any committed path**
  (zero-debt). No vacuous placeholder. Final state: sorry-free on every live path, axiom-clean.
- **Do NOT introduce a `x1 < e_i` relative-position literal** on any live path (LITMUS). Read
  arrangement slot **indices** and per-owner **validity bits**, never a model-order literal between a
  fresh witness and a slot.
- **Do NOT introduce a `fChainPred` term or nested point-type structure** (no-nesting, Lemma 5.1,
  p.7). Every point-type position stays `charBase χ` or `charK (nfk_projFresh σ)`.
- **Do NOT edit any do-not-edit asset** or the carrier structure. All new work is additive soundness
  lemmas in `SharedWitness.lean`.
- **Do NOT keep the L/R macro-side confinement invariant unaudited**: L list carries only `(x,w)`
  slots, R list only `(w,t)` slots — audit on every new lemma.
- **Do NOT treat the SW:6556 cross-σ-order comment or the O4 crux record as a live blocker** — it is
  intended design post-342, self-annotated "additive and inert."

**MUST preserve / consume-only**:
- The landed ⇐ completeness chain (`kvE2_sepBody_complete` SW:3236, `kvE2_sepBody_complete_holds`,
  `kvE2_sepBody_holds_of_honest`) — consumed unchanged; NOT re-opened.
- The landed sorry-free extraction chain `kvE2_sepDisjunct_extract` (SW:6167) and
  `kvE2_sepBody_extract` (SW:6328) — consumed; R2 discharges their `hpairL`/`hpairR`/`hnd`.
- The per-owner bundle reducers `kvE2_sepBundleL_parts` (SW:5167) / `kvE2_sepBundleR_parts`
  (SW:5184) — consumed; Phase 3 threads them into the sound kit.
- The do-not-edit soundness kit in `SubBracket2V.lean`: `kvE_subBracket2V_sound_of_parts` (:1025),
  `kvE_subBracket2V_extract` (:1027), and the per-σ kit `kvE_subBracket2V_correctness_pair` — consumed
  only.
- The retained design-guard `kvE2_sepHonest_hLR_absurd` (SW:5714) — the sole surviving `hLR` binder
  (takes `hLR`, derives `False`); preserved, not a regression.

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2 | -- |
| 2 | 3 | 2 |
| 3 | 4 | 3 |

Phase 1 is already COMPLETED (committed green at `924d76c49`); it and Phase 2 carry no prerequisite,
so they sit in wave 1. Phase 2's side-conditions unlock `kvE2_sepBody_extract`'s bundles that Phase 3
threads; Phase 3's per-σ realizations feed Phase 4's fold. Every phase edits the single file
`SharedWitness.lean` (H7 exclusive ownership), so within-wave parallelism is nominal — the ordering
is effectively sequential. (Each phase's `R{n}` / kit label is a readable cross-reference; the plain
integer `1`-`4` is the canonical phase number used by the wave table, `Depends on` fields, and
`/implement` resume logic.)

### Phase 1: R1 — Cleanup: dead `kvE2_sepBody_nonvacuous` deleted; ⇐ axiom triple re-verified [COMPLETED]

- **Completed:** 2026-07-09 — committed green at `924d76c49` (Phase-1 child of snapshot `235d181ef`).
- **Goal (achieved):** removed the dead conditional non-vacuity lemma `kvE2_sepBody_nonvacuous` (zero
  live consumers, superseded by the unconditional `kvE2_sepBody_complete` SW:3236) and re-confirmed
  the ⇐-chain axiom triple.
- **Outcome (from the commit record):** axiom triple re-confirmed
  `[propext, Classical.choice, Quot.sound]` on `kvE2_sepBody_complete` / `kvE2_sepArr'_sound` /
  `kvE2_sepBody_holds_of_honest` (all axiom-clean, no `sorryAx`); dead `kvE2_sepBody_nonvacuous`
  deleted; `lake build …SharedWitness` and `…OuterGate` green; LITMUS 0 live. Optional
  `.disjuncts ≠ []` corollary and strict-order cluster sweep SKIPPED (optional, no consumer, risk-free
  skip).
- **Depends on:** none
- **Do NOT re-plan or re-run.** Carried forward for provenance only.

### Phase 2: R2 — Soundness side-conditions: `Pairwise`/`Nodup` over arbitrary `wo ∈ kvE2_sepArr'` [IN PROGRESS]

- **Goal:** Prove the soundness-oriented `Pairwise`/`Nodup` lemmas over `kvE2_sepSlotsL/ROf wo` for
  **arbitrary** `wo ∈ kvE2_sepArr' qnf` (not just the honest order), discharging
  `kvE2_sepBody_extract`'s `hpairL`/`hpairR`/`hnd` (verbatim shape at SW:6331-6340). The landed
  lemmas do not already discharge these (`kvE2_sepSlotsLFor_rank_sorted` SW:745 is per-σ For-list;
  `kvE2_sepSlotsLOf_nodup` SW:4299 is `Nodup` of slots, not of `.map kvE2_sepSlotGIdx`). Unchanged
  from plan-02; the report calls it mechanical and correctly stated.
- **Tasks:**
  - [ ] Prove `∀ wo ∈ kvE2_sepArr' qnf, (kvE2_sepSlotsLOf wo).Pairwise (fun a b => kvE2_sepSlotLe a b = true)`
        and the R analogue (`hpairL`/`hpairR` shape).
  - [ ] Prove `∀ wo ∈ kvE2_sepArr' qnf, ((kvE2_sepSlotsLOf wo).map (kvE2_sepSlotGIdx wo)).Nodup ∧ ((kvE2_sepSlotsROf wo).map (kvE2_sepSlotGIdx wo)).Nodup`
        (`hnd` shape).
  - [ ] Derive from `wo ∈ kvE2_sepArr'` (a valid weak order) via the in-file `List.Pairwise` /
        `List.Nodup` / `List.mem_filter` / `List.mem_map` families — no new Mathlib search.
  - [ ] State each lemma in the exact shape `kvE2_sepBody_extract` consumes so task 335 can thread
        them into the OuterGate ⇒ path unchanged.
  - [ ] Macro-side confinement audit (L only `(x,w)`, R only `(w,t)`); LITMUS 0 hits; no-nesting.
- **Timing:** ~2-3 hours.
- **Depends on:** none (R1 done; R2 is independent of the R1 cleanup)
- **Estimated output:** ~120-250 lines (two Pairwise lemmas + two Nodup lemmas + glue).
- **Sorry-count target:** 0.
- **Done when:** `lake build …SharedWitness` exit 0; the four side-condition lemmas proven,
  sorry-free + axiom-clean via `lean_verify`; they discharge `kvE2_sepBody_extract`'s
  `hpairL`/`hpairR`/`hnd` for arbitrary `wo`; LITMUS 0 hits; diff only `SharedWitness.lean`.

### Phase 3: Per-σ kit application: thread bundles through `kvE2_sepBundleL/R_parts` into the sound kit [NOT STARTED]

- **Goal:** Apply the landed per-owner sound kit to each bundle. Thread the per-σ bundles that the
  landed sorry-free `kvE2_sepBody_extract` (SW:6328) produces (via `kvE2_sepDisjunct_extract`
  SW:6167) through `kvE2_sepBundleL_parts` (SW:5167) / `kvE2_sepBundleR_parts` (SW:5184) into
  `kvE_subBracket2V_sound_of_parts` (SubBracket2V:1025) to obtain each positive owner's `nf_eval`.
  **This REPLACES the deleted plan-02 R3.** It is a kit application, NOT a bit-proof: the
  forward-zone conjunct is the *antecedent* of the `bit ⟹ witness` implication these bundles carry
  (`kvE2_sepBundleL` SW:5117), with the bit supplied by the owner's own arrangement enumeration —
  never a goal to prove true.
- **Tasks:**
  - [ ] For an arbitrary realized `wo ∈ kvE2_sepArr' qnf`, take the per-σ bundles from
        `kvE2_sepBody_extract` (SW:6328), with R2's `hpairL`/`hpairR`/`hnd` discharged.
  - [ ] Reduce each left-class bundle via `kvE2_sepBundleL_parts` (SW:5167) — whose docstring states
        it "yields EXACTLY the `kvE_subBracket2V_sound_of_parts` input 5-tuple" — and feed
        `kvE_subBracket2V_sound_of_parts` (SubBracket2V:1025) to obtain the owner's `nf_eval`.
  - [ ] **Verify the right-interior class kit application lands** (the one genuine residual; MEDIUM):
        reduce each right-class bundle via `kvE2_sepBundleR_parts` (SW:5184) into the same
        `kvE_subBracket2V_sound_of_parts`. If it does not discharge, add a kit-application lemma in
        `SharedWitness.lean` — never weaken a filter, never assume `hgate`.
  - [ ] Confirm the bit consumed at each owner is self-owned (from that owner's arrangement
        enumeration), NOT a cross-σ goal; do NOT introduce an `x1 < e_i` literal (LITMUS).
  - [ ] LITMUS 0 hits; no-nesting audit; macro-side confinement audit (L only `(x,w)`, R only
        `(w,t)`).
- **Timing:** ~1-2 hours (small — near-mechanical kit application).
- **Depends on:** 2
- **Estimated output:** ~80-200 lines (left-class application + right-class verification + glue).
- **Sorry-count target:** 0.
- **Done when:** `lake build …SharedWitness` exit 0; each positive owner's `nf_eval` obtained from
  its bundle via `kvE2_sepBundleL/R_parts` → `kvE_subBracket2V_sound_of_parts`, sorry-free +
  axiom-clean via `lean_verify`; the right-interior class application confirmed to land; NO filter
  weakened, NO `hgate` assumed; LITMUS 0 hits; diff only `SharedWitness.lean`.

### Phase 4: R4 — Outer depth-2 fold `kvE2_outer_fold` (THE make-or-break) [NOT STARTED]

- **Goal:** Prove `kvE2_outer_fold`: reassemble `∃ w, nf_eval_nf M 2 3 [w,x,t] qnf` from the per-σ
  realizations (Phase 3) + `ExistProviders.correct` + the navigated sub-chain
  (`NavigatedSpine.lean:445` sketch). This is the **true make-or-break** (promoted from plan-02's
  Risk-MEDIUM, per report §C.4 / Part D). There is no landed depth-2 quant-layer fold engine
  (`nf_quant_layer_fold_iff` NfEFold.lean:391 folds depth-0 inner subs; the k=2 layer ranges over
  depth-1 subs), so this assembles from the per-σ realizations rather than a generic fold.
- **Tasks:**
  - [ ] From the per-σ `nf_eval` realizations obtained in Phase 3, assemble each σ's depth-1
        realization at a shared pivot `w` with `x < w < t`.
  - [ ] Use `ExistProviders.correct` and the navigated sub-chain (`NavigatedSpine.lean:445`) to fold
        the per-σ realizations into `∃ w, nf_eval_nf M 2 3 [w,x,t] qnf`. Consume-only the do-not-edit
        `NavigatedSpine.lean` engine bricks.
  - [ ] State `kvE2_outer_fold` in the shape task 335's `bracketEndChar_kvE2_sound_two_prior` will
        consume (the OuterGate ⇒ path); coordinate the exact interface with 335's consumer.
  - [ ] No `x1 < e_i` literal (LITMUS); no nested point types (no-nesting, Lemma 5.1 p.7); L/R
        confinement audit.
  - [ ] **If the fold has no viable route:** STOP, capture `lean_goal`, and `/spawn` a scoped
        depth-2 quant-layer-fold research task. Do NOT fabricate a fold, weaken the statement, or
        introduce `sorry`.
- **Timing:** ~3-4 hours (make-or-break; split if >300 lines).
- **Depends on:** 3
- **Estimated output:** ~150-300 lines. If assembly exceeds ~300 lines, split into 4.1 (per-σ
  depth-1 realization assembly at the shared pivot) and 4.2 (outer `∃ w` fold via
  `ExistProviders.correct`).
- **Sorry-count target:** 0.
- **Done when:** `lake build …SharedWitness` exit 0; `kvE2_outer_fold` proven, sorry-free +
  axiom-clean via `lean_verify`; the R2/kit/R4 lemma set is available and shaped for task 335's
  OuterGate ⇒ path; LITMUS 0 hits; diff only `SharedWitness.lean`. (On no-route: uncommitted,
  escalated via `/spawn`.)

## Testing & Validation

Per-phase invariants (run at every open phase's Done-when):
- [ ] `lake build Theories.Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.SharedWitness`
      exit 0; `lake build …OuterGate` exit 0 after Phase 4 (no downstream regression).
- [ ] Sorry inventory: `grep -nw "sorry" …/SharedWitness.lean` shows only comment/docstring hits —
      **0 live sorries** at every phase (the import path is already 0-sorry; no new sorry allowed).
- [ ] `lean_verify` axiom-clean (`[propext, Classical.choice, Quot.sound]`) on new/changed symbols.
- [ ] LITMUS grep `grep -nE "fChainPred|x1[[:space:]]*<[[:space:]]*e"` = 0 live hits on new lemmas.
- [ ] No-nesting audit: every point-type position is `charBase χ` or `charK (nfk_projFresh σ)`
      (Lemma 5.1, p.7).
- [ ] Macro-side confinement: L list only `(x,w)` slots, R list only `(w,t)` slots.
- [ ] Citation hygiene: any new load-bearing docstring cites the **PDF by page** (`Rabinovich 2014,
      p.N`) — **no `md:NN`**. Def 3.1 / Lemma 3.2 use the mandated 342 form.
- [ ] `git diff --stat` touches only `SharedWitness.lean`; `OuterGate.lean` and all do-not-edit
      assets (incl. the carrier structure `kvE2_sepArr'`/`kvE2_sepBody`) byte-identical.

## Artifacts & Outputs

- plans/05_kit-application-and-outer-fold.md (this file)
- Modified: `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/SharedWitness.lean`
  (Phase 2 soundness side-condition lemmas; Phase 3 per-σ kit application; Phase 4 outer depth-2
  fold — all additive soundness lemmas, carrier structure byte-identical; Phase 1 already committed)
- summaries/05_kit-application-and-outer-fold-summary.md (on completion)
- Follow-on (NOT this task): task 335 consumes R2/kit/R4 to close the OuterGate ⇒ half (R5); a new
  task to be spawned after R5 lands for the F4 semantic ℤ discriminator.

## Rollback/Contingency

- **Per-phase git discipline**: commit each phase at its green Done-when (`task 333 phase {P}: …`).
  Any phase that fails its build-green stays uncommitted; fix forward (never discard uncommitted work
  — snapshot via `.claude/scripts/git-snapshot.sh` before any intentional rollback).
- **Phase 3 right-interior kit does not land**: add a kit-application lemma in `SharedWitness.lean`
  (333 territory). Do NOT weaken `kvE2_sepDisjValidOwner`/`kvE2_sepDisjValid` toward vacuity; do NOT
  introduce `sorry`; do NOT assume `hgate`.
- **Phase 4 (make-or-break) has no viable fold route**: if `ExistProviders.correct` + the
  `NavigatedSpine.lean:445` sketch do not fold, STOP, capture `lean_goal`, and `/spawn` a scoped
  research task for the depth-2 quant-layer fold engine; do NOT fabricate a fold or weaken the
  statement.
- **Task 335 cannot consume the lemmas** (interface mismatch): coordinate the exact statements with
  335's `OuterGate.lean:172-201` consumer before finalizing; re-shape in `SharedWitness.lean` (333
  territory) rather than editing `OuterGate.lean`.
- **Full revert**: because all open-phase edits are confined to `SharedWitness.lean`, a full rollback
  is `git checkout 924d76c49 -- …/SharedWitness.lean` (only after a snapshot per the dirty-tree rule).
