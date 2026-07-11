# Implementation Plan: Task #335 — Outer-Gate Assembly Engine (`kvE2_body` / `bracketEndChar_kvE2`) — FRAGMENT GATE (v6, post-347-adjudication)

> **Revision provenance**: revised from `plans/05_fragment-gate-v5.md` per the **task-347
> bracket-faithfulness adjudication** (session `sess_1783792054_45a555`, 2026-07-11). Sources:
> `specs/347_rabinovich_bracket_faithfulness_review/reports/01_bracket-faithfulness-adjudication.md`
> (verdict (b) SUBSTANTIVE, H4-verified) and its summary `.../summaries/01_bracket-faithfulness-review-summary.md`.
> **What changed vs v5**: only **Phase C** and **Phase D** are revised; Phases 1/2/3/A/B are carried
> forward verbatim with their current `[COMPLETED]` markers (Phase B gains a short post-347 note on
> the binder narrowing 347 landed). The Phase-D **provider obligation is re-shaped** from the global
> `kvE2_sepPos`, decoupled/unbounded `hreal` shape to Rabinovich **Cor 5.4 ⇐**: bounded, jointly-ordered
> interior witnesses routed through the interior index `kvE2_sepPosI` — matching exactly what
> successor task **348** (`prop43_exterior_reflatten`) will consume (335 is 348's PROVIDER). The
> hard `hexcl` blocker that halted v5 Phase C/D is **DISSOLVED, not discharged in-335**: task-347 R1
> (commits `d370d438e` / `3b8aee3c4`) discharged the interior exclusion slice in-line and narrowed
> the residue to **exterior-marked σ only**, which is now the province of task 348 (re-flatten), not
> an in-335 discharge.

> **Proposed task-335 description update** (for the orchestrator to apply to state.json — NOT applied
> here). Append to the existing description:
>
> *"UPDATE (task-347 adjudication, session sess_1783792054_45a555): the Phase-D provider obligation is
> re-shaped to Rabinovich Cor 5.4 ⇐ form — realize BOUNDED, jointly-ordered interior witnesses over the
> interior index kvE2_sepPosI (SharedWitness.lean:211-214), NOT the global kvE2_sepPos (which over-asks:
> unbounded, decoupled — 347 report 01 MUST-CHECK 2). The hard hexcl blocker is DISSOLVED, not discharged
> in-335: task-347 R1 (commits d370d438e/3b8aee3c4) discharged the interior exclusion slice in-line and
> narrowed the residue to exterior-marked σ only; that exterior-arrangement residue is the province of
> successor task 348 (prop43_exterior_reflatten — Prop 4.3 re-flatten / Lemma 7.6 adjacency), for which
> 335 is the PROVIDER. Phase D therefore assembles the interior+boundary-scoped gate and threads the
> exterior-marked hexclExt outward to 348; it does NOT attempt exterior completeness on the interior
> (x,t) bracket (retired phantom framing, no §5 counterpart)."*

- **Task**: 335 - Build the outer-gate assembly engine `kvE2_body` / `bracketEndChar_kvE2`, the two-level quant-layer connector that `KampPrior.lean:351` (the depth-k≥2 Cor 5.4 converter) consumes — now delivered as the **single-positive-sub fragment gate** sanctioned by task 321 verdict N2, with the Phase-D provider obligation re-shaped to Cor 5.4 ⇐ (bounded interior, jointly-ordered) per the task-347 adjudication
- **Status**: [NOT STARTED] (Phase D re-scoped, actionable post-347) — Phases 1/2/3/A/B COMPLETED; **Phase C RESHAPED → resolved** (interior exclusion slice discharged in-line by task-347 R1 `d370d438e`/`3b8aee3c4`; exterior-marked residue RE-ROUTED to successor task 348 `prop43_exterior_reflatten`, NOT an in-335 discharge); **Phase D re-scoped** to the interior+boundary gate assembly with the provider obligation re-shaped to bounded-interior + jointly-ordered (Cor 5.4 ⇐) over `kvE2_sepPosI`, threading the exterior-marked `hexclExt` outward to task 348. The v5 hard blocker (in-335 `hexcl` discharge) is dissolved by the adjudication.
- **Effort**: 4-6 hours (Phases 1-3/A/B landed; the remaining genuine work is the Phase-D interior+boundary assembly against the re-shaped `kvE2_sepPosI` provider obligation)
- **Dependencies**:
  - 334 (COMPLETED — faithful carrier redefinition `kvE2_sepArr'` + `kvE2_sepDisjValidOwner`)
  - 337 (COMPLETED — `kvE2_sepBody_holds_of_honest` completeness engine, consumed by the landed Phase 2)
  - 342 (COMPLETED — interior-restricted owner index `kvE2_sepPosI`, tie-admitting weak orders, `hLR` deletion)
  - **333 (COMPLETED — `ff54d45c5`)** — landed `kvE2_outer_fold` (`SharedWitness.lean:9897`, green, axiom-clean) plus the extraction/kit lemmas (`kvE2_sepBody_extract`, `kvE2_sepBundleL/R_parts`, `kvE2_sepBody_kit_sound`). 335 CONSUMES these unchanged; H7 territory holds (333 owns `SharedWitness.lean`, 335 owns `OuterGate.lean`).
  - **345 (COMPLETED)** — the pin-anchored symmetric gate (Rabinovich Cor 5.4 clause (v)); delivered `kvE2_outer_fold_frag` (`SharedWitness.lean:12529`) and dissolved `hInnerR`; consumed by the landed Phase B.
  - **347 (COMPLETED — R1 landed `d370d438e`/`3b8aee3c4`)** — the bracket-faithfulness adjudication (verdict (b)). Narrowed the deferred exclusion binder from global `∀ σ, qnf.2 σ = false` to **exterior-marked σ only** (interior slice discharged in-line by the depth-0 order atom), and re-shaped 335's provider obligation to Cor 5.4 ⇐ over `kvE2_sepPosI`. This is the AUTHORITATIVE new input driving v6.
  - **321 verdict N2 (SANCTION — scope amendment, 2026-07-07)**: the GO/NO-GO deliverable for 309 Phase 13.4 + `KampPrior.lean:351` is re-scoped to the single-positive-sub fragment; the multi-positive case is deferred to the named successor task. This is the authoritative authorization for the `hfrag` restriction on `qnf`.
  - **Downstream — task 335 is the PROVIDER for task 348** (`prop43_exterior_reflatten`, NOT STARTED): 348 consumes the interior+boundary gate + the re-shaped `kvE2_sepPosI` provider obligation and supplies the exterior-arrangement re-flatten (Prop 4.3 / Lemma 7.6 adjacency).
- **Research Inputs**:
  - **specs/347_rabinovich_bracket_faithfulness_review/reports/01_bracket-faithfulness-adjudication.md (NEWLY INTEGRATED — AUTHORITATIVE for v6.** Verdict (b) SUBSTANTIVE, H4-verified against Rabinovich 2014 §5 full text. MUST-CHECK 2: the landed `hreal` OVER-ASKS — global `kvE2_sepPos`, unbounded, decoupled — vs Cor 5.4 ⇐ (p.9, l.263–273) which builds ONE bounded, jointly-ordered interior sequence `x1<…<xn ∈ (z0,z1)`. §7 R1: interior exclusion slice discharged from the depth-0 order atom, residue narrowed to exterior-marked σ. §7 R2 + Consumer guidance: exterior residue is the Prop 4.3 re-flatten route (task 348), NOT exterior completeness on the interior bracket.)
  - **specs/347_rabinovich_bracket_faithfulness_review/summaries/01_bracket-faithfulness-review-summary.md (NEWLY INTEGRATED** — records the R1 landings `d370d438e`/`3b8aee3c4`, the narrowed `hexclExt` binder shape, and the three consumer records including "Task 335 Phase D re-shape".)
  - **specs/346_successor_carrier_redefinition/summaries/01_successor-carrier-redefinition-summary.md (NEWLY INTEGRATED** — the active `prop43_exterior_reflatten` successor spec (task 348, ~line 195) 335 provides for; §"Task 335, Phase D" (lines 157-162) confirms Phase D assembles the interior+boundary gate with the exterior residue explicitly deferred to the Prop-4.3 successor.)
  - specs/335_outer_gate_assembly_engine_kvE2_body/reports/04_gate-blocker-adjudication.md (AUTHORITATIVE for the v5 fragment-route sanction. Verdict `b-weaken-fragment`. Branch (a) SharedWitness reshape REFUTED; branch (b-strengthen) REFUTED-BY-AUDIT. Sanctioned path: single-positive-sub fragment gate.)
  - specs/335_outer_gate_assembly_engine_kvE2_body/.blocker-research.json (verdict JSON, `plan_v5_shape`, `spawn_needed: false`)
  - specs/335_outer_gate_assembly_engine_kvE2_body/reports/03_plan-currency-check-post-333.md (post-333 currency check — established `kvE2_outer_fold` takes FOUR families; superseded on discharge strategy by report 04, and again on the exclusion family by the 347 adjudication)
  - specs/333_carrier_redefinition_kve2_separr_bit_compatibility_correctness_pair/reports/03_pdf-fidelity-r3-dissolved-regrounding.md (CONFIRMED — citation rule: Rabinovich by PDF page only)
  - specs/337_.../reports/13_rxw-faithfulness-audit.md + 14_tie-class-semantics-audit.md (CONFIRMED — `.rXW` faithfulness; primed order `kvE2_sepHonestOrder'` is the only correct order)
- **Artifacts**: plans/06_fragment-gate-v6.md (this file); supersedes plans/05_fragment-gate-v5.md
- **Standards**: plan-format.md; status-markers.md; artifact-management.md; lean4.md; literature-fidelity-policy.md
- **Type**: lean4
- **Lean Intent**: false
- **reports_integrated**: 347/reports/01_bracket-faithfulness-adjudication.md, 347/summaries/01_bracket-faithfulness-review-summary.md, 346/summaries/01_successor-carrier-redefinition-summary.md

## Overview

This is **plan v6**, forced by the **task-347 bracket-faithfulness adjudication** (report 01,
verdict (b) SUBSTANTIVE, H4-verified against Rabinovich 2014 §5 full text). It supersedes v5 only in
**Phase C and Phase D**; Phases 1/2/3/A/B are carried forward unchanged.

**What v5 got right and keeps** (unchanged): the fragment route (task 321-N2), the landed
def + `rfl` bridge (Phase 1), the unconditional ⇐ completeness half (Phase 2), the corrected
in-source note (Phase 3), the fragment predicate `kvE2_sepFragment` + `_frag` shells (Phase A), and
the ⇒ soundness half `bracketEndChar_kvE2_sound_two_prior_frag` over the symmetric-gate fold
`kvE2_outer_fold_frag` (Phase B). NO `SharedWitness.lean` reshape is contemplated (branch (a) remains
REFUTED, report 04).

**What v5 got wrong, and what the 347 adjudication corrects** (Phase C / Phase D):

- **v5's Phase C treated `hexcl` as a monolithic in-335 GO/NO-GO probe and reported NO-GO** — the
  fold's deferred exclusion binder ranged over the **global** `∀ σ, qnf.2 σ = false` and could not be
  closed at `charK := P.existF 0` from the fold's hypotheses. The 347 adjudication (§C1/§C2, MUST-CHECK
  1/2) shows this obligation was **globalized past Rabinovich's bracket**: `nf_eval_nf`
  (`NormalForm.lean:203–207`) quantifies the outer/fresh witness **unbounded over all `M.carrier`**,
  whereas Rabinovich's Cor 5.4 bounds it (`(∃z)^{<z1}_{>z0}`). The monolithic exclusion was a
  **phantom obligation with no §5 counterpart**. **Task-347 R1 (landed `d370d438e`/`3b8aee3c4`)**
  split it by σ-zone: the **interior-marked slice** is discharged in-line from the falsified depth-0
  `.order` atom (an exterior `x1` breaks a strict interior order literal), and the residue is narrowed
  to **exterior-marked σ only**. So there is **no remaining in-335 exclusion discharge** — Phase C's
  question is settled: interior slice discharged (upstream, in 347's territory below the SW:10210 341
  GATE banner), exterior residue re-routed to task 348.

- **v5's Phase D asked for a fragment-UNCONDITIONAL gate with `hexcl` fully DISCHARGED** — impossible,
  hence BLOCKED. The 347 adjudication re-shapes the deliverable: Phase D assembles the
  **interior+boundary-scoped** gate; the exterior-marked residue is a **named deferred obligation
  threaded outward to task 348** (the Prop 4.3 re-flatten successor), exactly as the 346 successor
  summary §"Task 335, Phase D" (lines 157-162) directs. In addition, the **provider obligation shape
  is corrected** (MUST-CHECK 2): the landed `hreal` (`SharedWitness.lean:12648–12652`) over-asks —
  it ranges over the **global** `kvE2_sepPos`, and demands **independent, per-σ, unbounded**
  existentials. Rabinovich Cor 5.4 ⇐ (p.9, l.263–273) instead builds **one jointly-ordered interior
  sequence** `x1<…<xn ∈ (z0,z1)` — witnesses **coupled by order** and **bounded to the open interval**.
  The faithful provider obligation is therefore: realize over the **interior index `kvE2_sepPosI`**
  (`SharedWitness.lean:211–214`, the strict-interior order-literal predicate `x<x1<w ∨ w<x1<t`), NOT
  global `kvE2_sepPos`, and produce **bounded, jointly-ordered** witnesses. For the current **n=1
  interior singleton** the coupling is vacuous, so the existing `hreal` is *accidentally* adequate for
  the landed fragment; it does **not** generalize to `On` (n≥2). v6 re-expresses the Phase-D provider
  obligation against `kvE2_sepPosI` to (i) match what task 348 consumes and (ii) generalize correctly.

**Net effect on the blocker**: v5's Phase C/D `[BLOCKED]` (in-335 `hexcl` NO-GO) is **dissolved**.
The interior+boundary deliverable becomes actionable; the exterior slice is a clean provider hand-off
to task 348, not a 335 obstruction.

### Verified interface facts (checked against HEAD, do not re-derive)

| Symbol | Location | Role in this plan |
|---|---|---|
| `kvE2_outer_fold_frag` | `SharedWitness.lean:12529` | LANDED (345). Symmetric-gate pin-anchored fold consumed by Phase B/D. Post-347 its deferred exclusion binder is `hexclExt` narrowed to exterior-marked σ (SW:12665). |
| `kvE2_sepPosI` (interior index) | `SharedWitness.lean:211–214` | **The re-shaped provider index** (v6). Strict-interior order-literal predicate `x<x1<w ∨ w<x1<t` — Lemma 5.3 base + one navigation. The Phase-D `hreal`-shaped obligation ranges over THIS, not global `kvE2_sepPos`. |
| `kvE2_sepPos` (global positive list) | `SharedWitness.lean:193–195` | The global positive index the landed `hreal` over-asked against (MUST-CHECK 2). v6 re-points the provider obligation off this to `kvE2_sepPosI`. |
| task-347 R1 interior-slice lemma | `SharedWitness.lean` (below SW:10210 341 GATE banner), commit `d370d438e` | LANDED. `(nf0_zoneSpec σ.1 = kvE2_sep_zXW3 ∨ = kvE2_sep_zWT3) → ¬(x ≤ x1 ∧ x1 ≤ t) → ¬ nf_eval_nf M 1 4 [x1,w,x,t] σ`. Discharges the interior exclusion slice in-line; 335 CONSUMES it, does not re-derive. |
| narrowed `hexclExt` binder | `SharedWitness.lean:12665–12669` / `OuterGate.lean:280` (commit `3b8aee3c4`) | LANDED. Ranges over exterior-marked σ only (adds `¬(nf0_zoneSpec σ.1 = kvE2_sep_zXW3 ∨ = kvE2_sep_zWT3)`). This is the **exterior obligation threaded outward to task 348**. |
| `bracketEndChar_kvE2_sound_two_prior_frag` | `OuterGate.lean:245` | LANDED (Phase B); post-347 re-threaded to the narrowed `hexclExt` binder. The ⇒ soundness half Phase D consumes. |
| `bracketEndChar_kvE2_complete_two_prior` | `OuterGate.lean:139` | ⇐ half (Phase 2, landed). Phase D reuses it unchanged (the fragment/interior restriction gates only ⇒). |
| Cor 5.4 ⇐ (Rabinovich 2014) | p.9, l.263–273 | The literature ground truth for the re-shaped provider obligation: one jointly-ordered, interval-bounded interior sequence. |
| `bracketEndChar_kvE2` / `_two_eq` | `OuterGate.lean:62` / `73` | Live def + `rfl` bridge (Phase 1, landed). Delegates to `kvE2_sepBody … (fun χ => P.existF 0 χ)`. |
| `ExistProviders` (`existF`, `correct`) | `PriorInterface.lean:38` | Provider tool; instantiated at `charK := fun χ => P.existF 0 χ`. |
| `BracketCarrierCorrectVPrior` | `PriorInterface.lean:60` | k=2 target (fragment/interior-restricted). PROTECTED interface — provider shape must NOT change. |
| `bracketEndChar_kv_factors` | `CarrierKv.lean:422` | The (outer zone, projected 1-type) information-ceiling record — reference for why the exterior residue is inexpressible on the interior bracket (belongs to 348). |
| `KampPrior.lean:351` | — | Downstream consumer (R-B, out of scope here). |

### Research Integration (newly integrated in plan v6)

- **347 report 01 (`01_bracket-faithfulness-adjudication.md`, AUTHORITATIVE)** — the load-bearing new
  finding driving v6. Verdict (b): the encoding dropped Rabinovich's **outer-∃ bound** (Cor 5.4), not
  the per-σ order atoms. MUST-CHECK 2 re-shapes 335's provider obligation to bounded-interior +
  jointly-ordered over `kvE2_sepPosI`. §7 R1 discharged the interior exclusion slice and narrowed the
  residue to exterior-marked σ. §7 R2 + Consumer guidance route the exterior residue to the Prop 4.3
  re-flatten successor (task 348), NOT exterior completeness on the interior bracket.
- **347 summary 01** — records R1 landings (`d370d438e`/`3b8aee3c4`), the narrowed `hexclExt` binder
  shape, and the explicit "Task 335 Phase D re-shape" consumer record (needs `/revise 335` — this plan).
- **346 summary 01 (active `prop43_exterior_reflatten` spec)** — the successor (task 348) 335 provides
  for; §"Task 335, Phase D" confirms Phase D is interior+boundary-scoped with the exterior residue
  deferred to the Prop-4.3 successor.
- **Superseded by the 347 adjudication on the exclusion family**: v5 Phase C's monolithic in-335
  `hexcl` NO-GO framing and v5 Phase D's fragment-UNCONDITIONAL (`hexcl` fully discharged) target —
  both retained only as historical records; the interior slice is now discharged (347 R1) and the
  exterior slice deferred (348).
- **Preserved**: 335 report 04 (fragment-route sanction), 333 report 03, 337 reports 13/14 (`.rXW`
  faithfulness, primed-order guardrail), the page-cite-only citation rule. All remain binding.

### Citation rule (binding — carried into every phase)

Cite the Rabinovich source **by PDF page** (`p.N`), never `md:NN`. The markdown paraphrase drops
every displayed equation and inverts `k≠m`→`k=m`. The Cor 5.4 ⇐ bounded-interior construction cites
**p.9, l.263–273**; the outer-∃ unboundedness root cause cites `NormalForm.lean:203–207` by line.
Internal proof-tree references (O4 CRUX RECORD, task-347 R1 lemma) cite SW line / commit only.

## Goals & Non-Goals

**Goals**:
- Preserve the landed Phase 1 (live def + `rfl` bridge), Phase 2 (⇐ completeness), Phase 3 (corrected
  note), Phase A (fragment predicate + `_frag` shells), and Phase B (⇒ soundness half over
  `kvE2_outer_fold_frag`). Do not re-plan or re-touch them.
- **Re-shape the Phase-D provider obligation** to Rabinovich **Cor 5.4 ⇐**: realize **bounded,
  jointly-ordered** interior witnesses over the interior index **`kvE2_sepPosI`**
  (`SharedWitness.lean:211–214`), NOT the global `kvE2_sepPos`. Express the obligation so it matches
  verbatim what task 348 (`prop43_exterior_reflatten`) consumes.
- **Assemble the interior+boundary-scoped gate** `bracketEndChar_kvE2_correct_two_prior_frag`
  (interior/boundary complete; the exterior-marked `hexclExt` residue threaded outward to task 348 as
  the named exterior obligation — NOT discharged in 335).
- **Consume, do not re-derive, task-347 R1**: the interior-slice exclusion discharge landed in 347's
  SharedWitness territory (below the SW:10210 341 GATE banner); 335 relies on the narrowed `hexclExt`
  binder shape.
- Write the **309-v8 + task-348 handoff note** recording (i) the interior+boundary gate and its
  `kvE2_sepPosI` provider obligation, and (ii) the exterior-marked `hexclExt` obligation task 348 owns.
- Keep deliverables axiom-clean `{propext, Classical.choice, Quot.sound}`; no sorries on live paths;
  primed order only; LITMUS-clean (`NavigatedSpine.lean:437`).

**Non-Goals**:
- **Do NOT attempt to discharge the exterior-marked `hexclExt` residue inside 335.** It is a phantom
  obligation on the interior `(x,t)` bracket (347 report 01 §C2/§7; no §5 counterpart) and belongs to
  task 348 (`prop43_exterior_reflatten`, Prop 4.3 re-flatten / Lemma 7.6 adjacency). Thread it outward;
  do not prove exterior completeness on the interior bracket.
- **Do NOT bound `nf_eval_nf`'s outer existential in place.** The unbounded `∃ (x : M.carrier)`
  (`NormalForm.lean:203–207`) is correct raw FOMLO semantics; the fix is re-flatten (task 348), not a
  local bound (347 report 01 §C3).
- **Do NOT re-point the provider obligation back to global `kvE2_sepPos`.** MUST-CHECK 2: it over-asks
  (unbounded, decoupled, ranges over exterior-zone positives the interior bracket never asserts). Use
  `kvE2_sepPosI`.
- **Do NOT edit `SharedWitness.lean` / `SubBracket2V.lean`.** 341's frozen-file gate stays intact; the
  task-347 R1 lemma and narrowed binder are CONSUMED unchanged. H7 territory: `OuterGate.lean` only.
- **Do NOT add any provider-conditional family** (`hbdry`/`hgateL`/`hgateR`) as a hypothesis of the
  final gate — they are internal to `kvE2_outer_fold_frag` (post-345). The only sanctioned added
  hypothesis beyond the provider shape is `hfrag` (`kvE2_sepFragment qnf`), a `qnf`-domain restriction.
  The exterior-marked `hexclExt` is threaded outward to 348 as a **named provider hand-off**, not a
  hidden gate assumption.
- **Do NOT attempt the multi-positive / full `On` induction.** n≥2 (nested `K⁺`, jointly-ordered
  coupling) is out of the fragment; deferred (321-N2 successor + task 348).
- **Do NOT reintroduce any interiority hypothesis on realized types** (`hL`, `hLR` — refuted by
  `kvE2_sepHonest_hLR_absurd`, SW:5714). The `kvE2_sepPosI` restriction is a positivity/zone predicate
  on `qnf`, not a guard on realized types.
- No bare `sorry`/`admit`; no vacuous close (`False.elim`, `hLR_absurd.elim`, `:= True`,
  `:= trivial`); no gate-modulo-assumed-family; zero-debt on live paths.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| **Re-shaped `kvE2_sepPosI` provider obligation does not line up with the landed `hreal`/`kvE2_outer_fold_frag` argument positions** (the fold was built against `kvE2_sepPos`) | M | M | For the n=1 interior singleton, `kvE2_sepPosI = [σ0]` coincides with the fragment's sole positive, so the landed `hreal` is *accidentally* adequate (347 MUST-CHECK 2). Build the interior-indexed obligation as a `have` and confirm defeq/derivation against the fold argument with `lean_goal` before wiring; if a `show`/`change` bridge is needed, insert it (no re-proof). Record the exact `kvE2_sepPosI`-indexed shape for task 348. |
| **Exterior-marked `hexclExt` is mistakenly attempted in-335** (regressing to the v5 NO-GO thrash) | H | L | Non-goal + checklist: `hexclExt` (exterior-marked binder, SW:12665) is THREADED OUTWARD as the task-348 obligation, never discharged. Grep the final gate for any in-335 attempt to close an exterior-marked exclusion; its presence as a discharged goal is a FAILURE. |
| **Provider obligation silently re-points to global `kvE2_sepPos`** | H | L | Checklist item: the Phase-D realization obligation must be indexed by `kvE2_sepPosI` (`SW:211–214`); inspect the index in the assembled statement. Global `kvE2_sepPos` in the provider obligation is a FAILURE (MUST-CHECK 2). |
| Order-bit mismatch: fold wants `qnf.1 (.order …)`, `BracketCarrierCorrectVPrior` supplies `qnf.atom_assgn (.order …)` | L | M | **Defeq** at successor depth. Supply directly; insert `show`/`change` if `exact` balks. No re-proof. |
| Accidental `SharedWitness.lean` / `SubBracket2V.lean` edit (breaks 341's frozen-file gate + 347's R1 landings) | H | L | All 335 code lives in `OuterGate.lean`. `git status` gate in Phase D confirms both files byte-unchanged from their post-347 state. |
| Vacuous close typechecks green but proves nothing | H | L | Grep `OuterGate.lean` for `False.elim`, `hLR_absurd`, `sorry`, `admit`, `:= True`, `:= trivial`. Green + vacuous is a FAILURE. |
| Handoff note under-specifies the 335→348 provider contract | M | L | Phase D handoff records the exact `kvE2_sepPosI`-indexed provider obligation AND the narrowed exterior `hexclExt` binder verbatim, so task 348 can consume without re-deriving. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 0 | 1, 2, 3 | -- (landed; completed carryover) |
| 1 | A | 3 (same-file sequencing) |
| 2 | B | A |
| — | C | RESOLVED via task-347 R1 (interior slice) + re-routed to task 348 (exterior slice); no in-335 work |
| 3 | D | B; consumes task-347 R1 (landed) |

All phases edit only `OuterGate.lean`. 335 and 341 do not run concurrently (H7); SharedWitness.lean
stays frozen (post-347 state). Phases sized to one agent dispatch each. **Task 335 provides for task
348** (`prop43_exterior_reflatten`), which consumes the Phase-D interior+boundary gate + the
`kvE2_sepPosI` provider obligation + the exterior `hexclExt` binder.

### Phase 1: Live wrapper def + `rfl` bridge [COMPLETED]

**Delivered** (verified against source, on disk, green):
- `bracketEndChar_kvE2` (`OuterGate.lean:62`): `noncomputable def` producing `BracketEndCharCarrierV
  sig 2`, delegating to `kvE2_sepBody (nf_depth0_char_formula …) (fun χ => P.existF 0 χ)`.
- `bracketEndChar_kvE2_two_eq` (`OuterGate.lean:73`): the `rfl` bridge exposing `kvE2_sepBody`.
- Aggregator import (`NfMultiAnchorBridge.lean:39`).

Completed carryover — preserved as-is; do NOT re-do.

---

### Phase 2: ⇐ completeness half — consume `kvE2_sepBody_holds_of_honest` [COMPLETED]

**Delivered**: `bracketEndChar_kvE2_complete_two_prior` (`OuterGate.lean:139`, sorry-free,
axiom-clean `{propext, Classical.choice, Quot.sound}`), plus helper bridges
`bracketEndChar_kvE2_hcb` / `bracketEndChar_kvE2_hck`. UNCONDITIONAL (no `hL`/`hLR`). Phase D's
`_frag` correctness theorem reuses this ⇐ direction unchanged (the interior restriction gates only
the ⇒ half).

Completed carryover — preserved as-is; do NOT re-do.

---

### Phase 3: Retire the stale in-source BLOCKED framing + citation hygiene [COMPLETED]

**Delivered** (committed `5689db302`): replaced the `OuterGate.lean:172-201` BLOCKED note with an
accurate status; stated the fold's requirement inline with `file:line`; purged the dangling `md:297`
cite. SharedWitness.lean byte-unchanged.

Completed carryover — preserved as-is; do NOT re-do. (Phase D re-touches only the delivered-items
4/5 docstring to record the interior+boundary `_frag` deliverables and the 348 hand-off.)

---

### Phase A: Single-positive-sub fragment predicate + `_frag` statement surgery [COMPLETED]

**Delivered** (committed, green, no sorry): `kvE2_sepFragment` (`OuterGate.lean`) —
`∃ σ0, kvE2_sepPos qnf = [σ0] ∧ (nf0_zoneSpec σ0.1 = kvE2_sep_zXW3 ∨ = kvE2_sep_zWT3)`. Depends only
on `qnf` (family-smuggling guard satisfied). The `_frag` sound shell was stated and its fold
reduction verified to typecheck (six order bits unify defeq `qnf.atom_assgn = qnf.1`).

> **v6 note (not a re-plan — recorded for Phase D)**: the 347 adjudication (MUST-CHECK 3) confirms
> `kvE2_sepFragment`'s single-interior-positive form is faithful *for the base/one-step case* — it is
> Lemma 5.3's basis + one navigation. When Phase D expresses the provider obligation, index the
> realization over `kvE2_sepPosI` (the interior index the fragment's `∃!` already pins to), NOT global
> `kvE2_sepPos`. No change to the predicate `def` itself is needed for n=1; the index correction lives
> in the Phase-D obligation shape.

Completed carryover — preserved as-is; do NOT re-do.

---

### Phase B: Discharge `hgateL` / `hgateR` under `hfrag` (⇒ soundness half) [COMPLETED]

**RESOLVED post-345** (2026-07-10): task 345 landed the symmetric gate (Rabinovich Cor 5.4, clause
(v)), dissolving `hInnerR` and delivering the pin-anchored fold `kvE2_outer_fold_frag`
(`SharedWitness.lean:12529`) whose interior gates `hgateL`/`hgateR` and non-interior `hbdry` are
internal to the fold. 335 Phase B landed `bracketEndChar_kvE2_sound_two_prior_frag`
(`OuterGate.lean`, green, axiom-clean `{propext, Classical.choice, Quot.sound}`): it discharges
`hcorrK` inline via `bracketEndChar_kvE2_hck.mp` and threads the deferred exclusion binder as a
hypothesis. `SharedWitness.lean`/`SubBracket2V.lean` byte-unchanged.

> **Post-347 update (binder narrowing — landed by task 347, 335 consumes it)**: task-347 R1
> (`d370d438e`/`3b8aee3c4`) re-threaded this theorem so the deferred exclusion binder is now
> **`hexclExt`, narrowed to exterior-marked σ only** (`OuterGate.lean:280`, mirroring
> `SharedWitness.lean:12665`): it additionally requires
> `¬(nf0_zoneSpec σ.1 = kvE2_sep_zXW3 ∨ = kvE2_sep_zWT3)`. The interior-marked exclusion slice is
> discharged in-line by the 347 R1 depth-0 order-atom lemma (no residue). The soundness half remains
> green + axiom-clean under the narrowed binder. This is a CONSUMED upstream change — Phase B needs no
> re-work.

Completed carryover — preserved as-is; do NOT re-do.

<details><summary>Historical goal/tasks (v5, unchanged)</summary>

**Goal** (historical): Build the two interior LEFT/RIGHT per-σ gate families in the exact shape
`kvE2_outer_fold` expects, under `hfrag`. Superseded by the symmetric-gate fold (345) which
internalized these families. See v5 for the full historical task list and the pre-345 blocker record.

</details>

---

### Phase C: Exclusion disposition — interior slice landed (347 R1), exterior residue deferred to task 348 [COMPLETED]

> **RESHAPED from v5 by the task-347 adjudication.** v5's Phase C was a monolithic in-335 `hexcl`
> GO/NO-GO probe that reported **NO-GO** (machine-confirmed 2026-07-10): the deferred exclusion binder
> ranged over **global** `∀ σ, qnf.2 σ = false` and could not close at `charK := P.existF 0`. The 347
> adjudication (report 01 §C1/§C2, MUST-CHECK 1/2) diagnoses **why**: that obligation was **globalized
> past Rabinovich's bracket**. `nf_eval_nf` (`NormalForm.lean:203–207`) quantifies the outer witness
> **unbounded over all `M.carrier`**, whereas Cor 5.4 bounds it (`(∃z)^{<z1}_{>z0}`); the monolithic
> exclusion was a **phantom obligation with no §5 counterpart**. The disposition is now settled and
> requires **no in-335 work**:

**Interior slice — DISCHARGED (task-347 R1, landed `d370d438e`, CONSUMED by 335).** For an
interior-marked σ (`nf0_zoneSpec σ.1 ∈ {kvE2_sep_zXW3, kvE2_sep_zWT3}`), an exterior `x1` falsifies a
strict interior `.order` atom, so `¬ nf_eval_nf … σ` follows directly from the depth-0 atom clause.
Task 347 landed this lemma in `SharedWitness.lean` (below the SW:10210 341 GATE banner) and re-threaded
the fold so the interior branch discharges in-line with **no residue**. 335 consumes this — it does NOT
re-derive it and does NOT edit SharedWitness.

**Exterior-marked residue — DEFERRED to task 348, threaded outward (NOT an in-335 discharge).** The
narrowed `hexclExt` binder (`SharedWitness.lean:12665`, `OuterGate.lean:280`) ranges over
exterior-marked σ only. Per the 347 adjudication §7 R2 + Consumer guidance and the 346 successor
summary (`prop43_exterior_reflatten`, task 348), the exterior arrangements `x1<x` / `x1>t` belong to
the **adjacent** intervals `(−∞,x)` / `(t,∞)` and are handled by Rabinovich's **Prop 4.3 re-flatten /
Lemma 7.6 adjacency** — a **separate exterior bracket composed with the interior `(x,t)` bracket**, NOT
an exterior-completeness proof on the interior bracket (retired phantom framing; 335 report 07
Refutation 2 + `bracketEndChar_kv_factors` arity-1 inseparability, `CarrierKv.lean:422`). Task 335 is
the PROVIDER; task 348 owns this residue.

**Disposition for v6**: there is **no remaining in-335 exclusion obligation**. Phase C is closed by
(interior) upstream landing + (exterior) hand-off. Phase D threads the exterior binder outward.

**Files to modify**: NONE (interior slice landed in 347's territory; exterior residue is task 348's).

**Verification**:
- Confirm the post-347 narrowed `hexclExt` binder shape is present at `OuterGate.lean:280` /
  `SharedWitness.lean:12665` (read-only; do not edit).
- Confirm NO in-335 attempt to discharge an exterior-marked exclusion goal exists on any live path.

---

### Phase D: Assemble the interior+boundary gate over the re-shaped `kvE2_sepPosI` provider obligation + 309-v8/348 handoff [NOT STARTED]

> **RE-SHAPED from v5 by the task-347 adjudication (this is the substantive v6 change).** v5's Phase D
> was `[BLOCKED]` because it targeted a fragment-UNCONDITIONAL gate with the exclusion family fully
> DISCHARGED in-335 — impossible given the (now-diagnosed phantom) monolithic `hexcl`. v6 re-scopes
> Phase D to the **interior+boundary-scoped** gate, with (1) the provider realization obligation
> re-shaped to **Cor 5.4 ⇐ over `kvE2_sepPosI`** (bounded interior, jointly-ordered — MUST-CHECK 2),
> and (2) the exterior-marked `hexclExt` residue **threaded outward to task 348** as the named
> provider hand-off (346 successor summary §"Task 335, Phase D", lines 157-162). The interior+boundary
> deliverable is now actionable — the v5 blocker is dissolved.

**Goal**: Assemble `bracketEndChar_kvE2_correct_two_prior_frag` as the **interior+boundary-scoped**
correct gate: combine the ⇒ soundness half (Phase B, `bracketEndChar_kvE2_sound_two_prior_frag` under
the narrowed `hexclExt` binder) with the ⇐ completeness half (Phase 2, unchanged), expressing the
provider realization obligation over the interior index `kvE2_sepPosI` (bounded, jointly-ordered, Cor
5.4 ⇐). The exterior-marked `hexclExt` is carried as the named obligation task 348 discharges via
re-flatten — NOT closed here. Finalize the docstring and write the 309-v8 + task-348 handoff note.

**Tasks**:
- [ ] **Re-express the provider realization obligation over `kvE2_sepPosI`** (the v6 correction).
      Instead of the global-`kvE2_sepPos` `hreal` shape, state the realization obligation as: for the
      pivot `w` (with `x<w`, `w<t`, `(kvE2_sepPtW …).eval_at M atomMap w`), realize each **interior**
      positive σ ∈ `kvE2_sepPosI qnf` by a **bounded, jointly-ordered** witness `x1 ∈ (x,t)` —
      `∃ x1, (x < x1 ∧ x1 < t) ∧ nf_eval_nf M 1 4 [x1,w,x,t] σ` (Cor 5.4 ⇐, p.9 l.263–273). For the
      n=1 interior singleton `kvE2_sepPosI = [σ0]`, the joint-order coupling is vacuous, so the landed
      `hreal` is accidentally adequate — but express the obligation against `kvE2_sepPosI` and the
      interval bound so it matches what task 348 consumes and generalizes to `On`. Confirm the shape
      against the `kvE2_outer_fold_frag` argument position with `lean_goal`; insert a `show`/`change`
      bridge if `exact` balks (defeq — no re-proof).
- [ ] **Close `bracketEndChar_kvE2_sound_two_prior_frag`** (already landed under Phase B; re-confirm
      green under the post-347 narrowed `hexclExt` binder): `intro h_holds`;
      `rw [bracketEndChar_kvE2_two_eq] at h_holds`; feed `kvE2_outer_fold_frag` with the internal
      families (from the symmetric-gate fold) + the interior-indexed realization obligation + the
      narrowed `hexclExt` binder. Bridge `qnf.atom_assgn (.order …)` → `qnf.1 (.order …)` via
      `show`/`change` if needed (defeq).
- [ ] **Assemble `bracketEndChar_kvE2_correct_two_prior_frag`** (interior+boundary-scoped): unfold the
      (fragment-restricted) `BracketCarrierCorrectVPrior`, `intro` the six order hypotheses +
      `h_UZ`/`h_SZ` + `x t`, then `constructor` combining the ⇒ (Phase-B/D sound, under `hfrag`, with
      the exterior `hexclExt` threaded as the task-348 provider obligation) and ⇐ (Phase 2 complete,
      unchanged) directions. Mirror `bracketEndChar_kv_correct_one_prior` (`PriorInterface.lean:100`).
      **The exterior-marked `hexclExt` binder appears as an explicit named hypothesis/obligation
      routed to task 348 — it is NOT discharged here and NOT a hidden gate assumption; it is the
      documented 335→348 provider contract.**
- [ ] `#print axioms bracketEndChar_kvE2_correct_two_prior_frag` via `lake env lean` (NOT
      `lean_verify` — unreliable on SharedWitness.lean, stale `sorryAx`) → `{propext,
      Classical.choice, Quot.sound}`, no `sorryAx` on the interior+boundary path.
- [ ] Finalize the `OuterGate.lean` header docstring (delivered items 4/5): record
      `bracketEndChar_kvE2_sound_two_prior_frag` and `bracketEndChar_kvE2_correct_two_prior_frag` as
      DELIVERED (interior+boundary-scoped, provider obligation over `kvE2_sepPosI`); note the
      exterior-marked residue deferred to task 348 (`prop43_exterior_reflatten`). Page-cite only.
- [ ] **Write the 309-v8 + task-348 handoff note** (`specs/335_.../handoffs/03_frag-gate-for-309-and-348.md`)
      recording precisely: (1) the interior+boundary gate `bracketEndChar_kvE2_correct_two_prior_frag`
      provides the k=2 interior+boundary GO gate for **309 Phases 13.4/14** and **`KampPrior.lean:351`**
      *under `kvE2_sepFragment qnf`*, with the realization obligation indexed by **`kvE2_sepPosI`**
      (bounded, jointly-ordered, Cor 5.4 ⇐); (2) the **exterior-marked `hexclExt` binder** (verbatim
      shape, `SharedWitness.lean:12665`/`OuterGate.lean:280`) is the **provider hand-off to task 348**
      (`prop43_exterior_reflatten`) — Prop 4.3 re-flatten / Lemma 7.6 adjacency, adjacent exterior
      brackets `(−∞,x)`/`(t,∞)` composed at the anchors `x,t`; (3) 309 consumes an interior+boundary
      gate + adjacent exterior bracket, seam at `x,t` — NOT a single all-arrangement `(x,t)` gate;
      (4) the multi-positive / full `On` case stays DEFERRED (321-N2 successor); (5) flag for 309's
      reviser whether the ∀k lift composes with a fragment-scoped k=2 rung.
- [ ] `git status` confirms only `OuterGate.lean` (+ the handoff note) changed; `SharedWitness.lean`
      / `SubBracket2V.lean` byte-for-byte unmodified (post-347 state). `lake build …OuterGate`, then
      full `lake build`.

**Timing**: 1.5-2 hours. **Depends on**: B (landed) + task-347 R1 (landed). Interior+boundary path is
actionable; the exterior slice is task 348's, not a blocker.

**Files to modify**: `OuterGate.lean` (assemble interior+boundary `_frag` theorems over `kvE2_sepPosI`
+ docstring); new handoff note `specs/335_.../handoffs/03_frag-gate-for-309-and-348.md`.

**Verification**:
- `bracketEndChar_kvE2_sound_two_prior_frag` and `_correct_two_prior_frag` compile sorry-free on the
  interior+boundary path; the realization obligation is indexed by **`kvE2_sepPosI`** (NOT global
  `kvE2_sepPos`) and is interval-bounded; the exterior-marked `hexclExt` is a named
  provider-hand-off hypothesis (routed to task 348), never discharged in-335 and never a hidden
  assumption; consume `kvE2_outer_fold_frag` unmodified.
- `#print axioms …_correct_two_prior_frag` axiom-clean, no `sorryAx` on the interior+boundary path.
- Full `lake build` green; 309-v8 + task-348 handoff note written.
- `SharedWitness.lean` / `SubBracket2V.lean` byte-unchanged (341's frozen-file gate + 347's R1
  landings intact).

## Testing & Validation

- [ ] `lake build Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.OuterGate` succeeds after
      Phase D; full `lake build` green at the end.
- [ ] **Axiom check via `#print axioms` (NOT `lean_verify`)**: every delivered `_frag` declaration
      through `lake env lean` returns `{propext, Classical.choice, Quot.sound}`, no `sorryAx` on the
      interior+boundary path. `lean_verify` is UNRELIABLE on `SharedWitness.lean`.
- [ ] **Provider obligation indexed by `kvE2_sepPosI`, bounded, jointly-ordered**: the Phase-D
      realization obligation ranges over `kvE2_sepPosI` (`SW:211–214`), bounds `x1 ∈ (x,t)`, and (for
      n≥2, documented for task 348) couples the witnesses by order — NOT global `kvE2_sepPos`,
      unbounded, decoupled (347 MUST-CHECK 2).
- [ ] **Exterior residue NOT discharged in-335**: the exterior-marked `hexclExt` binder is threaded
      outward as the task-348 provider obligation; grep for any in-335 attempt to close an
      exterior-marked exclusion goal — its presence is a FAILURE.
- [ ] **Fragment hypothesis is a pure `qnf` restriction**: `kvE2_sepFragment` depends only on `qnf`;
      `hfrag` never smuggles `M`/`atomMap`/`P`/a realized type.
- [ ] **No vacuous close**: grep `OuterGate.lean` for `False.elim`, `hLR_absurd`, `sorry`, `admit`,
      `:= True`, `:= trivial`. Green + vacuous is a FAILURE.
- [ ] **No interiority hypothesis on realized types**: no `hL`/`hLR`/realized-type interior guard in
      any delivered signature (refuted by `kvE2_sepHonest_hLR_absurd`, SW:5714).
- [ ] **Primed order only**: no live path consumes `kvE2_sepModelOrder` (SW:1476) or unprimed
      `kvE2_sepHonestOrder` (SW:3891); ordering rides `kvE2_sepHonestOrder'` (SW:5974).
- [ ] **LITMUS (`NavigatedSpine.lean:437`)**: no `x1 < e_i` relative-position literal on any live
      path; witness bounds come from the interior interval `(x,t)`.
- [ ] **Citation hygiene**: `grep -n "md:" OuterGate.lean` = 0; Rabinovich page-cited (Cor 5.4 ⇐ =
      p.9 l.263–273); internal lemmas cite SW line / commit.
- [ ] **Territory (H7) / 341 frozen-file gate**: `SharedWitness.lean`, `SubBracket2V.lean`, and all
      334/337/342/345/347 files byte-for-byte unmodified (`git status`); only `OuterGate.lean` (+ the
      handoff note) changed.
- [ ] `bracketEndChar_kvE2_two_eq` remains a genuine `rfl` bridge (unchanged from Phase 1).

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/OuterGate.lean` — extended:
  interior+boundary-scoped `bracketEndChar_kvE2_correct_two_prior_frag` over the `kvE2_sepPosI`
  provider obligation + finalized docstring (Phase D). (Phase 1 def + `rfl` bridge, Phase 2
  completeness lemma, Phase 3 corrected note, Phase A predicate + shells, Phase B soundness half
  already present.)
- `specs/335_outer_gate_assembly_engine_kvE2_body/plans/06_fragment-gate-v6.md` (this file);
  supersedes `plans/05_fragment-gate-v5.md`.
- `specs/335_outer_gate_assembly_engine_kvE2_body/handoffs/03_frag-gate-for-309-and-348.md` (Phase D —
  the 309-v8 + task-348 provider hand-off note).
- `specs/335_outer_gate_assembly_engine_kvE2_body/summaries/06_fragment-gate-summary.md` (on completion).
- **Successor task 348** (`prop43_exterior_reflatten`, EXISTS, NOT STARTED): consumes this Phase-D
  interior+boundary gate + `kvE2_sepPosI` provider obligation + the exterior-marked `hexclExt` binder;
  discharges the exterior residue by Prop 4.3 re-flatten / Lemma 7.6 adjacency. 335 is its PROVIDER.
- **Follow-on task (R-B, NOT this task)**: wire `bracketEndChar_kvE2` +
  `bracketEndChar_kvE2_correct_two_prior_frag` into `KampPrior.lean:351`.
- **Unblocks (downstream)**: task 309 (consumes the interior+boundary gate at Phase 13.4/14 + the
  adjacent exterior bracket from 348), task 341 (SharedWitness frozen, gate easier to certify), and
  task 348 (its provider contract is delivered by Phase D).

## Rollback/Contingency

- All 335 work is additive and isolated to `OuterGate.lean`. To revert Phase D: `git checkout`
  `OuterGate.lean` to its Phase-B (post-347) state; the tree returns to the landed ⇒ soundness half +
  ⇐ completeness + def + bridge + corrected note, with all carrier/soundness/347 INPUTS untouched.
- **If the `kvE2_sepPosI`-indexed provider obligation does not align with the landed
  `kvE2_outer_fold_frag`** for n=1: the coupling is vacuous, so the accidentally-adequate landed
  `hreal` may be used directly with a `show`/`change` bridge to the interior index — this is a defeq
  alignment, not a re-proof. Record the exact aligned shape for task 348. Do NOT re-point to global
  `kvE2_sepPos`.
- **Do NOT attempt the exterior-marked `hexclExt` residue in-335** — it is task 348's (Prop 4.3
  re-flatten); attempting exterior completeness on the interior bracket is the retired phantom framing
  (347 report 01 §C2/§7). Thread it outward.
- **Do NOT edit `SharedWitness.lean` (branch (a) REFUTED) or bound `nf_eval_nf` in place** (correct raw
  FOMLO semantics; 347 §C3). Never commit a bare `sorry`, an assumed family, a vacuous close, or an
  interiority hypothesis.
