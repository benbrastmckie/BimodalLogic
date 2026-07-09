# Implementation Plan (v2): Per-slot global-index carrier enrichment for value-faithful slot order

- **Task**: 340 - Per-slot global-index carrier enrichment for value-faithful slot order
- **Status**: [COMPLETED]
- **Effort**: ~4-6 hours remaining (Phase 5 only; Phases 1-4 + Phase-6 verification already landed, ~16h delivered)
- **Dependencies**: 339 (COMPLETED), 338 (COMPLETED), 336, 334 — carrier surface built by these tasks is read and extended, not re-derived. **Downstream: task 337** consumes this task's Phase-5 engine-precondition bundle (see "340↔337 Interface"). 340 Phase 5 is dispatched BEFORE 337 and must finish first; it consumes NOTHING 337 produces.
- **Research Inputs**:
  - reports/01_perslot-global-index-research.md — original blocker analysis (verified via report 06 three `lean_run_code` experiments); drove plan v1.
  - reports/02_rabinovich-faithfulness-recheck.md — Rabinovich Def 3.1 / Lemma 3.2(1) / Def 7.13 faithfulness + terminality confirmation (PDF spot-check).
  - reports/03_lean-carrier-model-independence.md — Agent B: the Phase-5 obstruction is a strawman; concrete `kvE2_sepBody_complete_holds` + `kvE2_sepIdxTuple_mem_of_lt` signatures over the EXISTING carrier.
  - reports/04_337-codesign-interface.md — Agent C: `k1v_sorted_realizationK` engine contract; the strengthened engine-precondition-bundle interface (not mere order-existence).
  - reports/05_research-team-synthesis.md — 3-agent synthesis: Phase 5 is a model-dependent selection/aggregation lemma over the existing carrier; keep-separate acyclic 340→337 interface; R1/R2 citation corrections.
- **Artifacts**: plans/02_perslot-global-index-plan-v2.md (this file; supersedes plans/01_perslot-global-index-plan.md)
- **Standards**:
  - .claude/context/formats/plan-format.md
  - .claude/rules/artifact-formats.md
  - .claude/rules/state-management.md
  - .claude/rules/lean4.md
  - .claude/context/contracts/anti-analysis.md (H2)
  - .claude/context/contracts/reference-grounding.md (H3)
- **Type**: lean4
- **Mode**: --hard (foundational faithful-transcription, terminal carrier layer)

## Overview

**This is a revision (v2) of plan 01.** Phases 1-4 and the Phase-6 verification pass are DONE,
committed, green, sorry-0, and axiom-clean (`{propext, Classical.choice, Quot.sound}`, full `lake
build` 1720 jobs). They are preserved verbatim and are NOT re-planned. The entire revision rewrites
**Phase 5**, whose original framing ("blocked pending a carrier type change or a vacuous
placeholder") a 3-agent research investigation (reports 02-05) proved **mis-framed**.

Task 339 sorted the joint cross-owner slot lists (`kvE2_sepSlotsLOf/ROf`) with a 2-level
region-primary key, unconditionally value-infaithful for the `a < u' < b` cross-region
interleaving (report 06). Phases 1-4 replaced that with a single **per-slot GLOBAL INDEX** (per-owner
payload `ℕ → ℕ×ℕ×ℕ` tuple; reader `kvE2_sepSlotGIdx`; single-level merge `decide (giOf a ≤ giOf b)`;
per-owner linear-extension validity conjunct `kvE2_sepConsistentTuple : i₀<i₁<i₂`; enumeration
`kvE2_sepIdxTuples` ranging over all of `[0,3n)³`). The honest `a<u'<b` interleaving is now
**expressible** (it was `omega`-unsatisfiable under 339), and the enumeration ranges over every
order-consistent tuple assignment. 340 is the TERMINAL carrier layer (a total order over a fixed
finite point set admits no refinement — reports 02, 05).

**What the research overturned.** Plan 01's Phase 5 conflated two distinct obligations:

1. `kvE2_sepBody_complete` (SW:~1830) concludes only **non-vacuity** (`kvE2_sepArr' qnf ≠ []`) — it
   is ALREADY sorry-free via `kvE2_sepCoincidentOrder`. Nothing remains to do here, and
   `kvE2_sepCoincidentOrder` stays as-is for non-vacuity.
2. The genuine Phase-5 obligation is the **latent RHS of `kvE2_sepBody_holds_iff`** (SW:~1111):
   `∃ wo ∈ kvE2_sepArr' qnf, (kvE2_sepDisjunct … (kvE2_sepSlotsLOf wo) (kvE2_sepSlotsROf wo)).2.holds
   M …`.

Obligation (2) is dischargeable over the **existing carrier** (`ℕ×ℕ×ℕ`, unchanged). It is a
**model-dependent SELECTION/AGGREGATION lemma** living entirely in 340/SharedWitness: pick a `wo`
from `kvE2_sepArr'` whose index tuples match M's honest value order, and prove
`kvE2_sepSlotsLOf/ROf wo` monotone in M. This aggregation — collect + sort + linear-extension over
the existing per-owner honest bundles — is **derivable for free from M's `LinearOrder`**: no new
model data, no new axioms, no carrier type change, no vacuous placeholder. It needs exactly one
trivial enumeration-richness lemma (`kvE2_sepIdxTuple_mem_of_lt`) plus membership and monotonicity.
`kvE2_sepCoincidentOrder` is untouched.

**Definition of done for Phase 5**: sorry-free, axiom-clean, green `lake build` after each
sub-phase; the model-value-faithful selection `wo` provably exists with monotone `SlotsLOf/ROf wo`;
and the engine-precondition bundle `hpos/hlink/hnd/hreal` (in genuine M-value order) is exported as
the hand-off object to task 337. F1-F7 / LITMUS invariants preserved; no load-bearing 334/336/338/339
result destroyed.

### Research Integration

- reports/01 — integrated in plan v1; supplies the verified blocker (region-primary key
  omega-refutable), the SW change map (report 06 §5), the must-preserve list, terminality.
- **reports/02 (Rabinovich faithfulness recheck)** — integrated in v2. PDF spot-check CONFIRMS the
  carrier is faithful and TERMINAL: Def 3.1 (p.4) single strictly-increasing chain with free
  reference-point placement `z_k = x_{i_k}` (admits the `a<u'<b` interleaving — the paper permits
  it, so 340 repairs 339's under-approximation); Lemma 3.2(1) (p.4, verbatim "conjunction ≡
  disjunction") grounds the enumeration; Def 7.13 (p.15) grounds the multi-reference-point segment
  framing. Verdict HOLDS: only a citation-precision edit (H3 row 76) is warranted, no design change.
- **reports/03 (Lean carrier model-independence)** — integrated in v2. The obstruction is a
  strawman: real only for the narrow claim "make a FIXED `qnf → KvE2SepWeakOrder` value-faithful"
  (false for the actual goal). Supplies the concrete `kvE2_sepBody_complete_holds` theorem signature
  and the `kvE2_sepIdxTuple_mem_of_lt` enumeration-richness lemma, both pure-340 over the existing
  type. Decomposition (A) honest-order selection / (B) membership / (C) monotonicity = 340; (D)
  `.holds` = 337.
- **reports/04 (337 co-design interface)** — integrated in v2. `k1v_sorted_realizationK`
  (SubBracket2V.lean:633-646) is landed/green and consumed (not built) by both tasks. The
  implementer's `∃ wo, monotone` interface is right-directioned but **too weak** — 340 must hand 337
  the engine's precondition bundle (`hpos/hlink/hnd/hreal` in genuine M-value order for
  `kvE2_sepSlotsLOf/ROf wo`), the realized value assignment, not just order-existence.
- **reports/05 (team synthesis)** — integrated in v2. Reconciled co-design contract (keep-separate,
  acyclic); R1/R2 citation corrections applied to the H3 table below.

### Preserved Assets

The following work is complete and must not regress (verified: on `main`, Phases 1-4 + Phase-6
verification landed 2026-07-08, sorry-0, axiom-clean, full build 1720 jobs):

| Component | File (SW = SharedWitness.lean) | Status | Verified |
|-----------|--------------------------------|--------|----------|
| Enriched carrier: `ℕ×ℕ×ℕ` payload, `kvE2_sepSlotGIdx` reader, single-level `kvE2_sepSlotMergeLe`, `kvE2_sepConsistentTuple`, `kvE2_sepIdxTuples`, `kvE2_sepPlaceholderTuple`(_mem) | SW carrier block (Phases 2-4) | [COMPLETED] (340 P2-4) | 2026-07-08 |
| `mergeSort_perm` membership route `kvE2_sepSlotsLOf_mem` / `ROf_mem` (comparator-agnostic) | SW:954-971 | [COMPLETED] (339, re-verified P3) | 2026-07-08 |
| Same-owner `rank<rank ⟹ index<index` (`kvE2_sep_index_lt_of_rank_lt`; giOf monotone) | SW:2015-2029, 455-461 | [COMPLETED] (334, re-verified P3) | 2026-07-08 |
| No-collapse: `kvE2_sepModelOrder`, `kvE2_sepCoincidentOrder` proven members of `kvE2_sepArr'` | SW:846-851, 1804-1832 | [COMPLETED] (334/337-P1, re-verified P4) | 2026-07-08 |
| Task 337 Phase-1 `kvE2_sepCoincidentOrder_mem_arr'` | SW:1804-1832 | [COMPLETED] (337-P1, re-verified P4) | 2026-07-08 |
| Structural enumeration lemmas `kvE2_sepOrderTypes_mem_aux` / `_owners_aux` / `_owners` / `kvE2_sepMem_orderOwners` | SW:810-945 | [COMPLETED] (338, re-verified P2) | 2026-07-08 |
| `kvE2_sepBody_complete` non-vacuity (`kvE2_sepArr' qnf ≠ []`) — ALREADY sorry-free | SW:~1830 | [COMPLETED] (P4) | 2026-07-08 |
| Honest extractors `kvE2_sepHonestBundleL/R`, `kvE_subBracket2_complete_extract` (do-not-edit extractor) | SW:1471-1565, 1460+; SubBracket2.lean:606 | [COMPLETED] (334) | 2026-07-08 |
| F5 zone-key discipline: `kvE2_sepClosedLeafStub`, `kvE2_sepDisjValidOwner` (open→OPEN, coincident→CLOSED) | SW:759-792 | [COMPLETED] (336) | 2026-07-08 |
| Phase-6 verification for Phases 1-4 scope (axiom-clean audit, F1-F7/LITMUS, full build) | — | [COMPLETED] (P6, re-runs after P5) | 2026-07-08 |

The permutation-based membership route and the same-owner monotonicity property are the two
load-bearing invariants the ⇒-extraction (`kvE2_sepDisjunct_extract`, SW:2086) consumes; they hold
verbatim under the current key and must survive Phase 5.

### Source-to-Implementation Mapping (H3, Tier: literature — faithful transcription)

**R1/R2 citation-precision fix applied (row "linear extension" corrected per reports 02, 05).**

| Load-bearing decision | Source | Implementation site |
|-----------------------|--------|---------------------|
| Single global chain over the union of points (not region×owner product) | Rabinovich Def 3.1 (PDF p.4, single strictly-increasing chain `x_n > … > x_0`) + Lemma 3.2(1) (PDF p.4, union-enumeration) | `kvE2_sepSlotMergeLe` single-level compare; enriched `KvE2SepWeakOrder` |
| Index must be a **linear extension of each owner's region order** (`lXU<lX1<lUW` left; mirror right) | **CORRECTED (R1/R2):** single per-owner chain = **Def 3.1** (PDF p.4, interval decomposition `α_j` at points / `β_j` on open `(x_{j-1},x_j)`); enumeration over order-consistent interleavings = **Lemma 3.2(1)** (PDF p.4, verbatim "conjunction of ∃∀-formulas ≡ disjunction of ∃∀-formulas" — the disjuncts ARE exactly the order-consistent interleavings); multi-reference-point / depth-k≥2 segment framing = **Def 7.13** (PDF p.15). *(Prior gloss "Lemma 3.2(1) one consistent global order over the union" was imprecise — Lemma 3.2(1) asserts only conjunction≡disjunction, NOT the single-chain order, which is Def 3.1.)* | `kvE2_sepConsistentTuple` conjunct in `kvE2_sepDisjValid`; preserved `kvE2_sepSlotRank` (SW:245-253) region ordering |
| `a < u' < b` (σ's `lUW` below τ's anchor) must be expressible and admitted | Def 3.1 free reference-point placement `z_k = x_{i_k}`, `i_k ∈ {0,…,n}` (PDF p.4 — the paper PERMITS σ's interior point below τ's anchor); report 06 Experiments A/B/C; honest bound `x1_σ < u < w` only (`kvE2_sepHonestBundleL`, SW:1471-1504) | Enumeration ranges over order-consistent global interleavings (`kvE2_sepIdxTuples`); Phase-1 gate (delivered) |
| Completeness witness supplies index consistent with MODEL value order (not just any linear extension) | Lemma 3.2(1) ⇐ honest arrangement (PDF p.4); Def 3.1 chain realized at M's points | Phase-5 selection lemma `kvE2_sepHonestOrder` + monotonicity (C); feeds `kvE2_sepBody_complete_holds` |
| No relative-position literal / open-closed non-conflation | LITMUS (NavigatedSpine.lean:437); F4/F5 | Index is abstract ℕ, reads no zone bit; validity keeps CLOSED-only coincidence read |

## Postmortem Constraints

Binding rules for all implementation dispatches. All plan-01 constraints are PRESERVED; one new
Do-NOT (Phase-5 mis-framing) is ADDED, marked **[NEW v2]**.

**Do NOT**:
- **[NEW v2]** Re-frame Phase 5 as blocked-pending-carrier-change or as needing a vacuous
  placeholder. Phase 5 is a **model-dependent selection lemma over the EXISTING carrier**
  (`ℕ×ℕ×ℕ` unchanged); the enumeration already ranges over all order-consistent tuples and validity
  already admits the honest one. This is established by research reports 02-05 (Agent B's adversarial
  obstruction test H4 conceded the obstruction is real ONLY for a fixed `qnf → KvE2SepWeakOrder`
  function, which the actual goal never required).
- Reintroduce or retain a region-rank-PRIMARY (or any 2-level region×owner lex) merge key. Report 06
  Experiment C proved it rank-independent-insufficient for `a < u' < b`; the task removed it.
- Encode the cross-owner order as per-OWNER-only rank data. Per-owner ranks cannot express "σ's
  region-2 slot below τ's region-1 slot"; the enrichment carries per-SLOT (per region-rank) index
  data.
- Expose any `x1 < e_i` relative-position literal (LITMUS, F4). The global index is an abstract ℕ
  read structurally off the arrangement, never a model-order comparison of a fresh anchor against a
  slot index. Phase 5's honest-bundle ordering uses M's `LinearOrder` over ALREADY-extracted
  witnesses only — it introduces NO new `x1 < e_i` literal.
- Conflate OPEN and CLOSED zone keys (F5). Strict placements read OPEN `zXU`/`zUW`; the coincidence
  tie reads the CLOSED `zAtX1L/R` self-zone bit only. The consistency conjunct reads NO zone bit.
- Use `simp`/`omega`/`aesop` to bypass a Def 3.1 / Lemma 3.2(1) step the literature handles
  explicitly (lean4.md Literature Fidelity).
- Introduce any vacuous definition (`def X := True`, `theorem X := trivial`) to force a green build
  (lean4.md Vacuous Definitions). In particular Phase 5 must NOT fabricate a value-faithfulness
  fiction for the model-independent `kvE2_sepCoincidentOrder`.
- Leave the file RED for an entire dispatch (task-305 unbounded-attempt failure mode). Each Phase-5
  sub-phase (5.1, 5.2) ends at a green, sorry-tracked `lake build`.

**MUST preserve**:
- The `mergeSort_perm` membership route: `kvE2_sepSlotsLOf_mem` / `kvE2_sepSlotsROf_mem` (SW:954-971).
- The same-owner `rank<rank ⟹ index<index` property (`kvE2_sep_index_lt_of_rank_lt`, SW:2015-2029;
  `hpairL/hpairR` obligations).
- The no-collapse property: `kvE2_sepModelOrder` AND `kvE2_sepCoincidentOrder` remain proven members
  of `kvE2_sepArr'`. `kvE2_sepCoincidentOrder` stays UNCHANGED (it discharges non-vacuity).
- Task 337 Phase-1's `kvE2_sepCoincidentOrder_mem_arr'` (SW:1804).
- Every completed 334/336/338/339 result and every Phase 1-4 / Phase-6 result (Preserved Assets).

**Design decisions are SETTLED** (do not re-open without a concrete Lean counterexample):
- The key is a single per-slot global index; region-primary lex is dropped. (report 06 §5) — DELIVERED.
- The index is a linear extension of each owner's region partial order. (Def 3.1 + Lemma 3.2(1),
  PDF p.4) — DELIVERED.
- 340 is the TERMINAL carrier layer; no fifth carrier layer. (reports 02, 05; a total order over a
  fixed finite point set admits no refinement) — CONFIRMED by PDF spot-check.
- **[v2]** Phase 5 is a model-dependent selection/aggregation lemma over the existing carrier — NOT
  a carrier change, NOT a placeholder. (reports 03, 05)
- **[v2]** The task stays confined to `SharedWitness.lean`. The `.holds` builder
  (`kvE_subBracket2V_sound_of_parts`, SubBracket2V.lean:1025, referenced at SW:~1927) and the engine
  invocation (`k1v_sorted_realizationK`, SubBracket2V.lean:633) are **337-owned**, out of 340 scope.
- **[v2]** 340 Phase 5 is dispatched **BEFORE** task 337 and must finish first. 340 Phase 5 consumes
  NOTHING task 337 produces; it PRODUCES the engine-precondition bundle that 337 consumes.

## 340↔337 Interface (keep-separate, acyclic)

The reconciled co-design contract (report 05 synthesis; Agent C, report 04):

| Owner | Deliverable | Nature |
|-------|-------------|--------|
| **340 Phase 5** (SharedWitness) | The selection lemma `∃ wo ∈ kvE2_sepArr' qnf` with `kvE2_sepSlotsLOf/ROf wo` in genuine M-value order, PLUS the exported engine-precondition bundle `hpos/hlink/hnd/hreal` (realized per-slot value assignment aggregated from the per-owner honest bundles) | bracket-INDEPENDENT; derivable **for free from M's `LinearOrder`** — no new model data, no new axioms; one enumeration-richness lemma |
| **337** (SubBracket2V + SharedWitness seam) | Consume 340's bundle → invoke `k1v_sorted_realizationK` (SubBracket2V.lean:633) → match the `interleaveK` monotone chain to `kvE2_sepBracketN`'s single-`ptW` IntervalPattern point types → discharge endpoint conjuncts → `.holds` via `kvE_subBracket2V_sound_of_parts` (SubBracket2V.lean:1025) | bracket-ENTANGLED; the only M-realization step |

Together these discharge `kvE2_sepBody_holds_iff.mpr` (`∃ wo, .holds M`). **No circular dependency**:
340-P5 → 337 is a linear shared-subgoal chain over the already-green engine; 340-P5 consumes nothing
337 produces. The engine-precondition bundle is the **hand-off object** to 337.

## Goals & Non-Goals

- **Goals** (Phase-5-scoped; carrier goals delivered by Phases 1-4):
  - Prove the enumeration-richness lemma `kvE2_sepIdxTuple_mem_of_lt` (any order-consistent tuple in
    `[0,3n)³` is a member of `kvE2_sepIdxTuples n`).
  - Define the model-dependent selection `kvE2_sepHonestOrder qnf M w x t : KvE2SepWeakOrder sig`
    (tuple = each owner's three slots' actual global positions in M's honest value order), aggregated
    over the existing per-owner honest bundles.
  - Prove membership `kvE2_sepHonestOrder … ∈ kvE2_sepArr' qnf` and monotonicity
    `kvE2_sepSlotsLOf/ROf (kvE2_sepHonestOrder …)` reproduce M's value order (including `a<u'<b`).
  - Export the engine-precondition bundle `hpos/hlink/hnd/hreal` for `kvE2_sepSlotsLOf/ROf wo` in
    genuine M-value order — the hand-off object to 337.
  - State the unblocking theorem `kvE2_sepBody_complete_holds` and reduce it to the 337-owned `.holds`
    step, showing how the bundle feeds `kvE2_sepBody_holds_iff.mpr`.
- **Non-Goals**:
  - Building 337's monotone `.holds` witness (`kvE_subBracket2V_sound_of_parts`) or invoking
    `k1v_sorted_realizationK` — that is task 337.
  - Modifying `kvE2_sepCoincidentOrder` (it stays as-is for non-vacuity) or any carrier type.
  - Any change outside `SharedWitness.lean`; any new axiom, `sorry`, or vacuous placeholder.

## Risks & Mitigations

- **Risk**: The honest-order aggregation is mistaken for new model reasoning and drifts into a `x1 <
  e_i` literal or a fresh model comparison (F4/LITMUS). **Mitigation**: the aggregation orders only
  ALREADY-extracted witnesses from `kvE_subBracket2_complete_extract` via M's `LinearOrder`
  (collect + sort + linear-extension); no fresh anchor comparison. Grep LITMUS at completion.
- **Risk**: `kvE2_sepIdxTuple_mem_of_lt` or membership (B) is harder than the placeholder-specialized
  `kvE2_sepPlaceholderTuple_mem` (SW:740). **Mitigation**: report 03 confirms it is the same three
  `List.mem_flatMap`/`List.mem_range` steps; the honest global indices are a subset of `[0,3n)`, so
  membership is immediate once the richness lemma lands.
- **Risk**: monotonicity (C) requires the `mergeSort` sorted spec to interact with the honest tuple
  in a way that stalls. **Mitigation**: (C) follows from the tuple definition + `kvE2_sepSlotGIdx`
  (SW:921) + `mergeSort` sorted spec; the same-owner monotonicity is already proven, and cross-owner
  order is exactly the aggregated total order the tuple encodes.
- **Risk**: Phase 5 exceeds one agent run. **Mitigation**: the pre-declared 5.1 (selection +
  membership + monotonicity, green) / 5.2 (exported precondition bundle + unblocking-theorem
  reduction, green) split keeps each within one agent run (H8). Each ends at a green, sorry-tracked
  `lake build`.
- **Risk**: an axiom leak (`sorryAx`) hides behind a `decide`. **Mitigation**: the Phase-6
  re-verification pass (re-run after Phase 5) runs `lean_verify` on every touched top-level theorem
  and asserts the axiom set equals `{propext, Classical.choice, Quot.sound}`.

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by | Status |
|------|--------|------------|--------|
| 1 | 1 | -- | [COMPLETED] |
| 2 | 2 | 1 | [COMPLETED] |
| 3 | 3 | 2 | [COMPLETED] |
| 4 | 4 | 3 | [COMPLETED] |
| 5 | 5 (5A → 5B → 5C → 5D) | 4 | [COMPLETED] — settled honest order, sorry-0, axiom-clean |
| 6 | 6 | 5 | [COMPLETED] for Phases 1-4 scope; re-verification pass re-runs after 5 |

Fully sequential. Phase 5's internal sub-phases 5.1 → 5.2 are sequential. **340 Phase 5 must complete
before task 337 is dispatched.**

### Phase 1: Design gate — value-faithfulness + terminality proof (analysis) [COMPLETED]

**GATE PASSED** (2026-07-08). Chosen representation: per-owner payload `ℕ×ℕ×ℕ = (i₀,i₁,i₂)` global
indices; carrier `KvE2SepWeakOrder = List (NormalForm sig 1 4 × KvE2SepSpikeOrderType × (ℕ×ℕ×ℕ))`;
per-slot reader `giOf`; single-level merge `decide (giOf a ≤ giOf b)`; consistency conjunct per-owner
`i₀<i₁<i₂` + all indices `Nodup`. Seven proofs validated on paper + scratch (`a<u'<b` expressible via
σ=(0,2,3), τ=(1,4,5); consistency⟹same-owner monotone; mergeSort_perm survives; faithful to Def 3.1;
terminal; placeholder `(k,n+k,2n+k)` reproduces 339 order; DecidableEq + decide confirmed). See plan
01 Phase 1 for the full gate record. No design change in v2 (PDF spot-check, report 02, CONFIRMS the
gate verdict).

### Phase 2: Carrier type migration — enriched index field, behavior-preserving (green) [COMPLETED]

**GREEN** (2026-07-08). Payload `ℕ`→`ℕ×ℕ×ℕ`; added `kvE2_sepPlaceholderTuple`/`kvE2_sepIdxTuples`/
`kvE2_sepPlaceholderTuple_mem`; enumeration ranges tuples; `kvE2_sepOwnerRank`/`kvE2_sepOrderOwners`
project `i₀`; merge key temporarily 2-level lex on `giOf`-i₀; `kvE2_sepDisjValid` Nodup on `i₀`;
model/coincident supply `(k,n+k,2n+k)`; re-proved `mem_aux`/`owners_aux`/model+coincident
`mem_orderTypes`/`mem_arr'`/`kvE2_sepArr'_sound`. `lake build` green (1013 jobs), sorry-free,
`kvE2_sepCoincidentOrder_mem_arr'` axiom-clean. See plan 01 Phase 2 for the full record.

### Phase 3: Activate single-level merge key + re-sort + membership + pairwise (green) [COMPLETED]

**GREEN** (2026-07-08). Added `kvE2_sepSlotGIdx` (per-slot global-index reader); collapsed
`kvE2_sepSlotMergeLe` to single-level `decide (giOf a ≤ giOf b)`, dropped region-primary lex.
`kvE2_sepSlotsLOf/ROf_mem` unchanged (mergeSort_perm route). Replaced the interleaving example with
the below-anchor `a<u'<b` case (`.lUW σ` before `.lX1 τ`). hpairL/hpairR merge-key-agnostic,
preserved. `lake build` green (1013 jobs), sorry-free. See plan 01 Phase 3 for the full record.

### Phase 4: Validity consistency conjunct + carrier-membership re-proofs (green) [COMPLETED]

**GREEN** (2026-07-08). Added `kvE2_sepConsistentTuple t := decide (t.1<t.2.1 ∧ t.2.1<t.2.2)`;
`kvE2_sepDisjValid` now 3 conjuncts (F5 zone read + `all kvE2_sepConsistentTuple` linear extension +
`i₀`-Nodup total order). Re-proved `kvE2_sepBody_complete` (non-vacuity), `kvE2_sepCoincidentOrder_mem_arr'`
(337-P1), `kvE2_sepArr'_sound`; placeholder tuples satisfy consistency. `lake build` green (1013
jobs), sorry-free, `kvE2_sepBody_complete` axiom-clean. Both `kvE2_sepModelOrder` and
`kvE2_sepCoincidentOrder` remain arr' members (no-collapse preserved). See plan 01 Phase 4.

### Phase 5: Model-dependent selection/aggregation lemma over the existing carrier (green) [COMPLETED]

**COMPLETED (2026-07-08, sess_1783561356_89aa2d_340).** Built against the SETTLED layout of design
gate report 06 (the coinciding-anchor fork is dissolved — two distinct owners provably cannot share
an anchor). Four green, sorry-0, axiom-clean (`{propext, Classical.choice, Quot.sound}`) milestones,
committed each:
- **5A** (keystone): `kvE2_sepAnchorVal` + `kvE2_sepAnchorVal_spec` + `kvE2_sepAnchor_injOn` (distinct
  owners ⟹ distinct anchors, via `nf_eval_unique`) + `kvE2_sepAnchorFam` + `kvE2_sepAnchorFam_injective`.
- **5B**: `kvE2_sepHonestTuple` (owner-block `(3r,3r+1,3r+2)`) + `_consistent`, `kvE2_sepHonestOrder`
  (all `.coincident` tags), `kvE2_sepHonestOrder_mem_orderTypes`, and `kvE2_sepHonestOrder_mem_arr'`
  (the carrier member task 337 consumes — tag validators reused verbatim, consistency by omega,
  `i₀`-Nodup via `kvE2_ordRank_injective` on the keystone-injective family).
- **5C** (monotonicity): `kvE2_sepHonest_rank_strictMono`, `kvE2_sepHonest_cross_region`
  (`i₂(σ)<i₁(τ)` from `x1_σ<x1_τ`, the `a<u'<b` disjunct 339 dropped), `kvE2_sepHonest_same_owner_mono`.
- **5D** (engine hand-off): `kvE2_sepBody_complete_holds` (wires 5B into `kvE2_sepBody_holds_iff.mpr`,
  delegating the single 337-owned `.holds` via `kvE_subBracket2V_sound_of_parts`) + public
  `kvE2_sepHonestAnchorBundleL/R` (per-owner `hnd`/`hreal` data at the value-ranked anchors — the
  `k1v_sorted_realizationK` inputs). Full project build green (1720 jobs). The regions realization
  `.holds` (incl. any meet-type folding of a foreign witness onto an anchor, report 06 R3) is task
  337's territory, NOT a carrier change — the sanctioned Phase-5 completion boundary.

**PROGRESS (superseded):** Sub-phase 5.1 objective 1 (`kvE2_sepIdxTuple_mem_of_lt`) DELIVERED green,
sorry-0, axiom-clean, committed. Handoff #2 mis-diagnosed a coinciding-anchor "fork"; the design gate
(report 06) dissolved it, and the honest order above is the single settled construction. Carrier is
CORRECT and UNCHANGED — this was never a carrier-change blocker.

**REWRITTEN IN v2.** This phase is NOT blocked and needs NO carrier change or placeholder (reports
02-05, and the Do-NOT above). It is a model-dependent selection/aggregation lemma living entirely in
`SharedWitness.lean`, over the EXISTING `ℕ×ℕ×ℕ` carrier. `kvE2_sepCoincidentOrder` is UNTOUCHED (it
already discharges non-vacuity via `kvE2_sepBody_complete`, SW:~1830). The genuine target is the
latent RHS of `kvE2_sepBody_holds_iff` (SW:~1111): `∃ wo ∈ kvE2_sepArr' qnf, (kvE2_sepDisjunct …
(kvE2_sepSlotsLOf wo) (kvE2_sepSlotsROf wo)).2.holds M …`.

**Target signatures (concrete).**

Enumeration-richness (5.1, pure 340 — same three `List.mem_flatMap`/`List.mem_range` steps as
`kvE2_sepPlaceholderTuple_mem`, SW:742-747):

```lean
theorem kvE2_sepIdxTuple_mem_of_lt (n a b c : ℕ)
    (ha : a < 3*n) (hb : b < 3*n) (hc : c < 3*n) :
    (a, b, c) ∈ kvE2_sepIdxTuples n
```

Selection (5.1, pure 340 — model-dependent DEFINITION; tuple data = each owner's three slots' actual
global positions in M's honest value order, aggregated by collect + sort + linear-extension over the
per-owner honest bundles; **derivable for free from M's `LinearOrder`**):

```lean
def kvE2_sepHonestOrder (qnf : NormalForm sig 2 3)
    (M : OrderedMonadicStructure sig) (w x t : M.carrier) : KvE2SepWeakOrder sig
-- (A) each interior owner tagged .coincident; tuple = owner's (i₀,i₁,i₂) global positions in M order
theorem kvE2_sepHonestOrder_mem_arr' … : kvE2_sepHonestOrder qnf M w x t ∈ kvE2_sepArr' qnf   -- (B)
theorem kvE2_sepHonestOrder_monotone … :                                                        -- (C)
    -- kvE2_sepSlotsLOf/ROf (kvE2_sepHonestOrder …) reproduce M's value order (incl. a<u'<b)
```

Exported engine-precondition bundle (5.2, pure 340 — the HAND-OFF OBJECT to 337; `hpos/hlink/hnd/hreal`
in genuine M-value order for `kvE2_sepSlotsLOf/ROf wo`, matching `k1v_sorted_realizationK`'s
signature, SubBracket2V.lean:633-646):

```lean
-- for wo := kvE2_sepHonestOrder qnf M w x t, derived from (C) + M.LinearOrder + honest-bundle realizers:
--   hpos  : ∀ r ∈ regions, r.1 < r.2.1
--   hlink : List.Chain' (fun a b => a.2.1 = b.1) regions
--   hnd   : ∀ r ∈ regions, r.2.2.Nodup
--   hreal : ∀ r ∈ regions, ∀ χ ∈ r.2.2, ∃ u, r.1 < u ∧ u < r.2.1 ∧ nf_eval_nf M 0 1 (fun _=>u) χ
```

Unblocking theorem (5.2 — Agent B's `kvE2_sepBody_complete_holds`; its `.holds` step (D) is the
337-owned boundary object `kvE_subBracket2V_sound_of_parts` consuming 340's bundle; feeds
`kvE2_sepBody_holds_iff.mpr`):

```lean
theorem kvE2_sepBody_complete_holds {sig : MonadicSignature}
    (charBase : NormalForm sig 0 1 → Formula) (charK : NormalForm sig 1 1 → Formula)
    (qnf : NormalForm sig 2 3)
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (w x t : M.carrier) (hxw : x < w) (hwt : w < t)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    (hLR : ∀ σ ∈ kvE2_sepPos qnf,
             nf0_zoneSpec σ.1 = kvE2_sep_zXW3 ∨ nf0_zoneSpec σ.1 = kvE2_sep_zWT3) :
    ∃ wo ∈ kvE2_sepArr' qnf,
      (kvE2_sepDisjunct charBase charK qnf (kvE2_sepSlotsLOf wo) (kvE2_sepSlotsROf wo)).2.holds
        M atomMap x t
```

Witness `wo := kvE2_sepHonestOrder qnf M w x t`; membership by (B); monotone slots by (C); the bundle
(5.2) supplies exactly `k1v_sorted_realizationK`'s preconditions; the final `.holds` (D) is 337's
engine invocation + `kvE_subBracket2V_sound_of_parts` consuming that bundle. This existential is
literally the RHS of `kvE2_sepBody_holds_iff` (SW:~1111), so it + the gate close completeness.

- **Goal:** Deliver the model-value-faithful selection `wo`, its monotonicity, and the exported
  engine-precondition bundle over the existing carrier — the substantive value-faithful discharge and
  the 337 hand-off object — leaving `kvE2_sepCoincidentOrder` untouched.

- **Tasks (sub-phase 5.1 — selection + membership + monotonicity, green):**
  - [x] Prove `kvE2_sepIdxTuple_mem_of_lt` (SW near the `kvE2_sepIdxTuples` defn) by the three
        `List.mem_flatMap`/`List.mem_range` steps mirroring `kvE2_sepPlaceholderTuple_mem` (SW:742-747).
        *(DONE 2026-07-08: added at SW:749-763, green, sorry-0, axiom-clean `{propext, Quot.sound}`, committed.)*
  - [x] **Lex-rank kernel DELIVERED** (2026-07-08, continuation dispatch): `kvE2_ordRank` +
        `kvE2_ordRank_lt` (range `< n`) + `kvE2_ordRank_strictMono` (`g a < g b → rank a < rank b`)
        + `kvE2_ordRank_injective` (SW:783-832), green, sorry-0, axiom-clean
        `{propext, Classical.choice, Quot.sound}`, committed. *(deviation: this is the model-agnostic
        SORT SPEC that the handoff identifies as what steps 2/4/5 all reduce to — range→`i<3n`,
        strictMono→`i₀<i₁<i₂` + `a<u'<b`, injective→`Nodup`. Uses the LEX `(value, index)` order so
        ties in the model value are broken by the distinct slot index, sidestepping the SW:1585
        value-distinctness crux WITHOUT any distinctness hypothesis. Design-agnostic: reused by
        whichever honest-order layout the next dispatch settles.)*
  - [ ] Define `kvE2_sepHonestOrder qnf M w x t` (A): each interior owner `.coincident`, tuple =
        the owner's three slots' actual global positions in M's honest value order, aggregated by
        collect + sort + linear-extension over the per-owner honest bundles via
        `kvE_subBracket2_complete_extract` (do-not-edit extractor) + M's `LinearOrder`. Introduce NO
        new model reasoning beyond ordering already-extracted witnesses; NO `x1 < e_i` literal (LITMUS).
        *(deviation: NOT YET DEFINED. Continuation dispatch surfaced an unsettled design point — see
        handoff `phase-5-partial-handoff-2.md` §"Design decision the def hinges on": the carrier tuple
        `(i₀,i₁,i₂)` is per-(owner, REGION-RANK) coarse (all `lXU σ χ` slots share `i₀`), so the def
        must pick ONE representative M-value per (owner,region); and step-6 realizability collides with
        coinciding anchors (a strict region-rank order forces separation the model may not admit,
        routing coinciding-anchor owners to `kvE2_sepCoincidentOrder`). This must be settled before the
        def is built, to avoid churning a membership proof against a to-be-redesigned layout.)*
  - [ ] Prove membership (B) `kvE2_sepHonestOrder_mem_arr'`, mirroring `kvE2_sepCoincidentOrder_mem_arr'`
        (SW:1899) with conjuncts (ii) consistency `i₀<i₁<i₂` and (iii) `i₀`-Nodup re-proved for the
        model tuples (honest global indices ⊂ `[0,3n)` ⟹ enumeration membership via
        `kvE2_sepIdxTuple_mem_of_lt`; consistency from `kvE2_ordRank_strictMono` on the bundle chain;
        Nodup from `kvE2_ordRank_injective` on the lex family). *(deferred: blocked on the def above.)*
  - [ ] Prove monotonicity (C) `kvE2_sepHonestOrder_monotone`: `kvE2_sepSlotsLOf/ROf (kvE2_sepHonestOrder …)`
        reproduce M's value order, from the tuple definition + `kvE2_sepSlotGIdx` (SW:939) + the
        `mergeSort` sorted spec (including the `a<u'<b` cross-region case). *(deferred: blocked on the def.)*
  - [ ] `lake build` green, sorry-free checkpoint after 5.1; commit. *(kernel checkpoint DONE + committed;
        def/membership/monotonicity checkpoint pending.)*

- **Tasks (sub-phase 5.2 — exported precondition bundle + unblocking-theorem reduction, green):**
  - [ ] Derive and EXPORT the engine-precondition bundle `hpos/hlink/hnd/hreal` for
        `kvE2_sepSlotsLOf/ROf (kvE2_sepHonestOrder …)` in genuine M-value order (from (C) + M's
        `LinearOrder` + the honest-bundle realizers) — matching `k1v_sorted_realizationK`'s signature
        (SubBracket2V.lean:633-646). This is the hand-off object to 337; it is bracket-INDEPENDENT and
        uses NO `kvE2_sepBracketN` reference.
  - [ ] State `kvE2_sepBody_complete_holds` and reduce it to the single 337-owned `.holds` step (D):
        `wo := kvE2_sepHonestOrder …`, membership (B), monotone slots (C), preconditions (bundle);
        the `.holds` proper is completed by task 337 consuming the bundle
        (`kvE_subBracket2V_sound_of_parts`, SubBracket2V.lean:1025). Show the reduction to
        `kvE2_sepBody_holds_iff.mpr` (SW:~1104-1122). 340's sorry-free deliverable ends at the bundle;
        the `.holds` closure lands in the 337 dispatch (no 340 sorry — the `.holds` is not a 340
        obligation).
  - [ ] `lake build` green, sorry-free checkpoint after 5.2; commit. Emit the phase-5 handoff
        recording the bundle contract for 337.

- **Done when:** `lake build` green, sorry-free after each sub-phase; `kvE2_sepIdxTuple_mem_of_lt`,
  `kvE2_sepHonestOrder(_mem_arr'/_monotone)` prove; the engine-precondition bundle is exported and
  demonstrably matches `k1v_sorted_realizationK`'s signature; the `a<u'<b` case is realized in the
  monotone slots. `kvE2_sepCoincidentOrder` unchanged; no new axiom/sorry/placeholder; LITMUS/F5
  clean. Commit green milestones (5.1, then 5.2). Dispatch task 337 only AFTER this phase is green.
- **Estimated output:** ~200-400 lines total (5.1 ~120-220, 5.2 ~100-200). Riskiest phase; the
  pre-declared 5.1/5.2 split keeps each within one agent run (H8).
- **Timing:** 4-6 hours
- **Depends on:** 4

### Phase 6: Final re-verification, axiom-clean, faithfulness audit (green) [COMPLETED]

**VERIFIED (2026-07-08) for the delivered carrier (Phases 1-4)** — full project `lake build` GREEN
(1720 jobs), sorry-free in scope, axiom audit `{propext, Classical.choice, Quot.sound}` (no `sorryAx`)
confirmed on `kvE2_sepBody_extract`, `kvE2_sepDisjunct_extract`, `kvE2_sepBody_complete`,
`kvE2_sepCoincidentOrder_mem_arr'` (337-P1), `kvE2_sepArr'_mem_modelOrder`, `kvE2_sepSlotsLOf_mem`.
F4/F5/LITMUS audit passed (index defs read no zone bit, abstract ℕ, no `x1 < e_i` literal;
NavigatedSpine:437 anchor unchanged). Preserved Assets all still proven.

**Re-verification pass re-runs after Phase 5** (its scope grows to include `kvE2_sepIdxTuple_mem_of_lt`,
`kvE2_sepHonestOrder(_mem_arr'/_monotone)`, and `kvE2_sepBody_complete_holds`):
- [ ] Full project `lake build` green (no downstream regression).
- [ ] `lean_verify` on the Phase-5 lemmas + `kvE2_sepBody`, `kvE2_sepBody_extract`,
      `kvE2_sepBody_complete`, `kvE2_sepBody_complete_holds`, `kvE2_sepCoincidentOrder_mem_arr'`:
      axiom set MUST equal `{propext, Classical.choice, Quot.sound}` — NO `sorryAx`.
- [ ] F1-F7 audit: F5 zone-key non-conflation intact; LITMUS (NavigatedSpine.lean:437) — grep/confirm
      no `x1 < e_i` relative-position literal introduced by the honest-order aggregation; F4
      index-is-abstract-ℕ confirmed.
- [ ] Confirm no load-bearing 334/336/338/339 / Phase 1-4 result was destroyed.
- **Depends on:** 5

## Testing & Validation

- [ ] `lake build` green at the end of every sub-phase (5.1, 5.2) and the Phase-6 re-verification.
- [ ] `lean_verify` axiom set = `{propext, Classical.choice, Quot.sound}` for all touched top-level
      theorems including the Phase-5 lemmas; no `sorryAx`.
- [ ] `kvE2_sepIdxTuple_mem_of_lt` proves (enumeration richness).
- [ ] `kvE2_sepHonestOrder_mem_arr'` and `kvE2_sepHonestOrder_monotone` prove; the `a<u'<b` case is
      realized in the monotone slots.
- [ ] The engine-precondition bundle `hpos/hlink/hnd/hreal` for `kvE2_sepSlotsLOf/ROf wo` is exported
      and matches `k1v_sorted_realizationK`'s signature (SubBracket2V.lean:633-646).
- [ ] `kvE2_sepCoincidentOrder` UNCHANGED; both `kvE2_sepModelOrder` and `kvE2_sepCoincidentOrder`
      remain proven members of `kvE2_sepArr'`; `kvE2_sepCoincidentOrder_mem_arr'` (337-P1) still proves.
- [ ] No `x1 < e_i` relative-position literal introduced (LITMUS grep); F5 open/closed keys not
      conflated.

## Artifacts & Outputs

- plans/02_perslot-global-index-plan-v2.md (this file; supersedes plans/01)
- summaries/02_perslot-global-index-summary.md (on Phase 5 completion)
- Modified: Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/SharedWitness.lean

## Rollback/Contingency

- Each sub-phase commits at a green, sorry-free checkpoint (git-workflow.md commit-per-green-substep
  mandate); 5.1 and 5.2 can be reverted independently to the prior green state.
- If Phase 5 model reasoning stalls, land 5.1 (selection + membership + monotonicity) green
  independently before attempting 5.2 (bundle export).
- Never insert a vacuous/`sorry` placeholder to force green; never re-frame Phase 5 as
  blocked-pending-carrier-change (Do-NOT [NEW v2]). If a genuine new obstruction appears, mark
  [BLOCKED] with a concrete Lean counterexample — NOT a prose claim (Agent B's H4 test showed the
  prior blocker was a prose strawman a read signature refutes).
- The `.holds` closure (D) is 337's; if it stalls, that is a task-337 concern — 340 Phase 5's green
  deliverable (selection + monotonicity + exported bundle) stands independently.
