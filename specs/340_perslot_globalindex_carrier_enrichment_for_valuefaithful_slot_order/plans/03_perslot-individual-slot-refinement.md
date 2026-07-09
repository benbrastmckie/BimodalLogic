# Implementation Plan (v3): Per-individual-slot carrier refinement for value-faithful slot order

- **Task**: 340 — Per-slot global-index carrier enrichment for value-faithful slot order
- **Status**: [PLANNING]
- **Effort**: ~14-22 hours (10 phases; Phase 1 is a design gate that may FAIL/escalate before any Lean edit)
- **Dependencies**: 339, 338, 336, 334 (COMPLETED — carrier surface read/extended, not re-derived). **Downstream: task 337** consumes this task's value-faithful per-slot carrier (`halignL/R` + assembled `regionsL/R` + `hbdry`). 340 v3 is dispatched BEFORE 337 re-dispatch and must finish first; it consumes NOTHING task 337 produces.
- **Research Inputs**:
  - reports/07_rabinovich-faithful-carrier-granularity.md — the CONFIRMED design (per-individual-slot value-rank via `kvE2_ordRank` over `Fin N`, `G j = (M-value_j, j)` lex); Tier-1 faithful transcription; verified sound.
  - reports/08_adversarial-verify-carrier-refinement.md — H4 adversarial verification: GO-WITH-CAVEATS, corrected **7-10 phase** scope, TWO mandatory missing design elements (value_j→engine-point binding; per-slot meet-type coincidence fold).
  - reports/06_coinciding-anchor-design-gate.md — R3 foreign-witness-at-anchor; the anchor keystone `kvE2_sepAnchor_injOn` (distinct owners ⟹ distinct anchors, via `nf_eval_unique`); `kvE2_sepCoincidentAnchor_discharge` infrastructure.
  - reports/05_research-team-synthesis.md — R1/R2 citation-precision corrections; keep-separate acyclic 340→337 seam.
  - 337 blocker: `specs/337_.../.orchestrator-handoff.json` (stop-guard root_cause: `kvE2_sepSlotGIdx` reads `kvE2_sepHonestTuple = (3r,3r+1,3r+2)`, one index per owner-REGION, tied across all base slots — `halignL/R` unprovable when an owner-region holds ≥2 base types) + `summaries/04_joint-disjunct-holds-codesign-summary.md`.
- **Artifacts**: plans/03_perslot-individual-slot-refinement.md (this file; supersedes the Phase-5 owner-block layer of plans/02)
- **Standards**:
  - .claude/context/formats/plan-format.md
  - .claude/rules/artifact-formats.md
  - .claude/rules/state-management.md
  - .claude/rules/lean4.md
  - .claude/context/contracts/anti-analysis.md (H2)
  - .claude/context/contracts/reference-grounding.md (H3)
- **Type**: lean4
- **Mode**: --hard (foundational faithful-transcription; corrects the exact carrier-granularity defect 337 proved)

## Overview

**This is a revision (v3).** Plan v2's Phase 5 landed the owner-block honest tuple
`kvE2_sepHonestTuple = (3r, 3r+1, 3r+2)` (SW:~2095), one global index per owner-REGION with
`r = kvE2_ordRank` of the ANCHOR family (`n` = #owners). Task 337 then consumed it and its
stop-guard fired at Phase 1 (`337/.orchestrator-handoff.json`): `kvE2_sepSlotGIdx` (SW:~1006) reads
that tuple at region rank (`kvE2_sepSlotRank`: all `.lXU`↦rank 0, all `.lUW`↦rank 2), so **every base
slot of one owner-region shares its index — a TIE**. `kvE2_sepSlotsLOf` (SW:~1034, mergeSort by that
index) is therefore NOT value-sorted within a tie-block of ≥2 base types, and the required
`halignL/R` (mergeSort order = engine's value-sorted `interleaveK ps` order) is **unprovable**. This
is the (owner,region)-coarse defect task 340's own description forbids.

**The correction (report 07, adversarially verified report 08).** Replace the per-(owner,region)
`ℕ×ℕ×ℕ` payload with a **per-INDIVIDUAL-slot global value-rank**:

```
kvE2_sepSlotGIdx s := kvE2_ordRank G (slotIndexOf s),   G : Fin N → M.carrier ×ₗ Fin N,  G j = (value_j, j)
```

lex over the FULL slot family `Fin N` (`N` = total individual base+anchor slots across all owners).
Rabinovich **Def 3.1** (PDF p.4): the witness is a strict chain of INDIVIDUAL points; two points may
share a base 1-type yet occupy distinct chain positions. `kvE2_sepS` is an unconstrained
`Finset.filter` (SW:178) — a region provably holds ≥2 slots (report 07/08 Test 1) — so per-region is
unfaithful. The lex second coordinate makes `G` injective with NO value-distinctness hypothesis.

**Scope re-sizing (report 08 refutes v2's 4-6 estimate).** The `ℕ×ℕ×ℕ` payload is load-bearing far
beyond the honest layer: validity conjuncts (ii)+(iii), the enumeration `kvE2_sepIdxTuples` (the `3*n`
bound is WRONG, rebuild to `N`), the SOUNDNESS-side `kvE2_sepModelOrder`, and the coincident-order
channel (18 refs) all destructure the 3-tuple. Corrected scope: **7-10 H8 phases**. This plan uses
**10 phases** (1 design gate + 9 implementation), each a bounded one-agent-run unit.

**Two mandatory design elements the plan adds (report 08 §Missing Design — NOT optional):**

1. **`value_j`→engine-point binding (data-flow inversion).** Base-witness slots carry TYPES, not
   points; `value_j` for a base slot has no canonical M-value. The only assignment that makes
   `halign` hold is `value_j :=` the engine's realized point for slot `j`, forcing the honest order to
   be defined FROM the engine realizer, not as a free enum member. Planned explicitly in Phase 6.
2. **Per-slot meet-type coincidence fold (LOAD-BEARING RISK).** The engine's `interleaveK` is
   STRICTLY increasing (`Pairwise (·<·)`, no ties), but a foreign depth-0 base witness realizable
   ONLY at an anchor value (report 06 R3, `kvE2_sepCoincidentAnchor_discharge`) makes a base slot's
   realization EQUAL an anchor value — the strict chain has ONE point where the carrier lists TWO
   slots, so `halign` (list equality) fails on length. This fold **may reopen model-independence of
   the slot list** (`kvE2_sepSlotsLFor`, a fixed function of σ, SW:292, might have to become
   model-dependent variable-length). **Phase 1 is a design gate on exactly this risk** (see below).

### Preserved Assets

The following work is complete and MUST NOT regress (on `main`, sorry-0, axiom-clean
`{propext, Classical.choice, Quot.sound}`, full build 1720 jobs; verified by reports 07/08 direct read):

| Component | File (SW = SharedWitness.lean) | Status | Verified |
|-----------|--------------------------------|--------|----------|
| **THE kernel**: `kvE2_ordRank` + `kvE2_ordRank_lt` / `_strictMono` / `_injective` — fully general `{β}[LinearOrder β]{n}(g:Fin n→β)`, hover-confirmed; **re-instantiate at the slot family (`N`), do NOT re-derive** | SW:783-832 | [COMPLETED] | 2026-07-08 |
| **Anchor keystone** `kvE2_sepAnchorVal(_spec)` + `kvE2_sepAnchor_injOn` (distinct owners ⟹ distinct anchors, via `nf_eval_unique`) + `kvE2_sepAnchorFam(_injective)` | SW:~2042-2090 | [COMPLETED] (340 v2 5A) | 2026-07-08 |
| Slot enumeration + finiteness: `KvE2SepSlot`, `kvE2_sepSlotSub`, `kvE2_sepSlotRank`, `kvE2_sepS` (bounded by `Fintype`), `kvE2_sepBits`, `kvE2_sepSlotsLFor/RFor` | SW:152-311 | [COMPLETED] | 2026-07-08 |
| Realization engine: `interleaveK`, `k1v_stitch_regions`, `k1v_sorted_realization(K)` (already per-slot value-sorting, `Pairwise (·<·)`) | SubBracket2V.lean:445-658 | [COMPLETED] | 2026-07-08 |
| Tag/coincidence discharge: `kvE2_sepClosedLeafStub`, `kvE2_sepCoincidentOwner_valid_left/right`, `kvE2_sepCoincidentAnchor_discharge` (tuple-agnostic) | SW:~880, ~1695, ~1788/1862 | [COMPLETED] | 2026-07-08 |
| `mergeSort_perm` membership route `kvE2_sepSlotsLOf_mem` / `ROf_mem` (comparator-agnostic) | SW:~1092 | [COMPLETED] | 2026-07-08 |
| **337-P1** `kvE2_sepCoincidentOrder_mem_arr'` (preserve; re-prove against new enumeration in Phase 5) | SW:~1966 | [COMPLETED] (337-P1) | 2026-07-08 |
| Honest bundles `kvE2_sepHonestAnchorBundleL/R` — pin `lXU ∈ (x,x1_σ)`, `lUW ∈ (x1_σ,w)` (Attack 2 SURVIVES: per-slot value rank is automatically a per-owner region linear extension; no region/value conflict) | SW:~2290/2329 | [COMPLETED] (340 v2 5D) | 2026-07-08 |
| F5 zone-key discipline: `kvE2_sepDisjValidOwner` (open→OPEN, coincident→CLOSED) | SW:~890 | [COMPLETED] (336) | 2026-07-08 |

Note: `kvE2_sepAnchor_injOn` is the load-bearing keystone for realizability/monotonicity — the lex
tiebreak is **inert for realizability** (report 06/08); route monotonicity through the keystone, never
through the tiebreak. The tiebreak only manufactures rank INJECTIVITY, not distinct model points.

### Source-to-Implementation Mapping (H3, Tier 1 — literature, faithful transcription)

**R1/R2 citation-precision fix applied (per report 05 §R2 — Lemma 3.2(1) asserts only
conjunction≡disjunction, NOT the single-chain order, which is Def 3.1).**

| Load-bearing decision | Source (Rabinovich 2014) | Implementation site |
|-----------------------|--------------------------|---------------------|
| Witness is a strict chain of **INDIVIDUAL** points; two points may share a base 1-type yet occupy distinct positions ⟹ per-individual-slot granularity (per-region unfaithful) | **Def 3.1** (PDF p.4 / md:65,74) — `∃x_n…∃x_0 (x_0<…<x_n)`, `α_j` need not be distinct across `j` | per-slot `kvE2_sepSlotGIdx s := kvE2_ordRank G (slotIndexOf s)` over `Fin N`; carrier payload type change (Phases 2-4) |
| Merge of owners = disjunction over **order-consistent interleavings** of the union multiset; enumeration ranges over per-slot assignments | **Lemma 3.2(1)** (PDF p.4 / md:77, verbatim "conjunction of ∃∀-formulas ≡ disjunction of ∃∀-formulas") | `kvE2_sepIdxTuples` rebuilt to per-slot `N`-bound enumeration + `kvE2_sepIdxTuple_mem_of_lt` richness (Phase 3) |
| Index is a **linear extension of each owner's region order** (`lXU<lX1<lUW`) — CORRECTED R1: this is **Def 3.1** per-owner interval order (`α_j` at points, `β_j` on open `(x_{j-1},x_j)`), NOT Lemma 3.2(1) | **Def 3.1** interval decomposition (md:66-74); disjuncts = order-consistent interleavings via Lemma 3.2(1) | `kvE2_sepConsistentTuple` generalized to per-slot region-monotonicity (every `lXU`-gidx < anchor-gidx < every `lUW`-gidx) + global Nodup (Phase 3) |
| Multi-**owner** union is the object (multiple reference points) | **Def 7.13** (PDF p.15 / md:202); Lemma 7.14 (md:204) | cross-owner slot multiset `kvE2_sepSlotsLOf/ROf` re-sorted by per-slot gidx (Phase 4) |
| `value_j`→realized-point binding: model contact enters once, at realization; the base slot's rank key is the engine-realized point (data-flow inversion) | **Insight #3** (md:221-222); **Prop 4.3** all-chains equivalence (md:103-115) | value-assignment lemma + "carrier index = value rank of realized points" bridge (Phase 6) |
| Per-slot meet-type fold: a reference/base point may **collapse onto** a chain point (`z_k = x_{i_k}`) — the foreign-witness-at-anchor meet | **§5 / Lemma 5.3** (md:151, "r_0 = z_0 or r_0 ∈ (z_0,z_1)"); §5 meet (md:168-173) | coincidence fold routing through `coincident` tag / `kvE2_sepCoincidentAnchor_discharge` (Phase 1 gate + Phase 9) |
| No relative-position literal / open-closed non-conflation | LITMUS (NavigatedSpine.lean:437); F4/F5 | Index is abstract ℕ, reads no zone bit; validity keeps CLOSED-only coincidence read |

## Postmortem Constraints

Binding rules for all implementation dispatches. Derived from the 337 stop-guard, reports 07/08, and
prior 340 churn (339 region-primary → 340 v2 per-owner-region tuple → still tied).

**Do NOT**:
- **Return to a per-(owner, region) product carrier** (`ℕ×ℕ×ℕ` or any fixed 3-arity per owner). This
  is the exact defect 337's stop-guard proved: it ties all base slots of one owner-region and makes
  `halignL/R` unprovable. The payload must be per-INDIVIDUAL-slot, variable-arity over `Fin N`.
- **Collapse same-region slots to one index.** The honest slot order MUST reach per-individual-slot
  value faithfulness — every distinct base slot gets a distinct value-ranked global index (via the lex
  second coordinate). Collapsing same-region slots to one index IS the defect this refinement corrects.
- **Encode the order as per-OWNER-only rank data.** Per-owner ranks cannot express "σ's region-2 slot
  below τ's region-1 slot"; the rank must be over the full cross-owner slot family `Fin N`.
- **Wire `kvE2_ordRank` at the anchor/owner family** (`n`) as v2 did. It must instantiate at the SLOT
  family (`N`) — that is the one-level-too-coarse wiring that caused the tie.
- **Expose any `x1 < e_i` relative-position literal** (LITMUS, F4). The global index is an abstract ℕ
  read structurally off the arrangement; the value order uses M's `LinearOrder` over ALREADY-extracted
  witnesses only.
- **Conflate OPEN and CLOSED zone keys** (F5). Strict placements read OPEN `zXU`/`zUW`; the coincidence
  fold reads the CLOSED `zAtX1L/R` self-zone bit only. The consistency conjunct reads NO zone bit.
- **Insert a vacuous placeholder or `sorry` to fake the coincidence fold** (Phase 9). If the fold
  cannot be discharged faithfully, Phase 1's gate FAILS and the orchestrator escalates — a fabricated
  green is forbidden (lean4.md Vacuous Definitions; task-305 stop-guard discipline).
- **Do a monolithic RED refactor.** Phase 2 is a behavior-PRESERVING type migration that lands GREEN
  re-expressing the old owner-block semantics in the new per-slot type BEFORE any semantic/value
  change (Phases 6+). Never leave `SharedWitness.lean` RED across an entire dispatch (task-305
  unbounded-attempt failure mode). Each phase ends at a green, sorry-tracked `lake build`.
- **Use `simp`/`omega`/`aesop` to bypass** a Def 3.1 / Lemma 3.2(1) / §5-meet step the literature
  handles explicitly (lean4.md Literature Fidelity).

**MUST preserve** (see Preserved Assets table):
- The `kvE2_ordRank` kernel + lt/strictMono/injective (SW:783-832) — re-instantiate, do not re-derive.
- The anchor keystone `kvE2_sepAnchor_injOn` and `kvE2_sepAnchorFam(_injective)`.
- The slot-enumeration finiteness, the `k1v_sorted_realizationK` engine, and the tag/coincidence
  discharge (`kvE2_sepCoincidentAnchor_discharge`) — all tuple-agnostic, reused verbatim.
- **337-P1** `kvE2_sepCoincidentOrder_mem_arr'` (re-proved against the new enumeration in Phase 5, not
  destroyed).
- The honest bundles' interval pinning `lXU ∈ (x,x1_σ)`, `lUW ∈ (x1_σ,w)` (Attack 2 SURVIVES).
- Every completed 334/336/338/339 result.

**Design decisions are SETTLED** (do not re-open without a concrete Lean counterexample):
- Per-individual-slot value-rank via `kvE2_ordRank G (slotIndexOf s)`, `G j = (value_j, j)` lex over
  `Fin N`. Per-region and per-owner-region are REFUTED (report 07/08; both escape hatches fail —
  `kvE2_sepS` provably selects ≥2 χ, and the engine cannot delegate an order the carrier already
  asserted). (reports 07, 08)
- `value_j` for a base slot is bound to the engine-realized point (data-flow inversion), NOT a free
  canonical value. (report 08 element 1)
- The coincidence fold routes through the existing `coincident` tag / `kvE2_sepCoincidentAnchor_discharge`
  channel (Rabinovich §5 `z_k = x_{i_k}` meet). (reports 06, 08 element 2)
- 340 stays confined to `SharedWitness.lean`. The engine invocation (`k1v_sorted_realizationK`) and
  `kvE_subBracket2V_sound_of_parts` (SubBracket2V.lean) are 337-owned — EXCEPT that this refinement
  now lands `halignL/R` + assembled `regionsL/R` + `hbdry` as 337 INPUTS (per the 337 stop-guard's
  preferred resolution), because they require the per-slot value-faithfulness only 340 can derive.
- 340 v3 is dispatched BEFORE 337 re-dispatch and consumes NOTHING 337 produces.

## 340↔337 Interface (keep-separate, acyclic — strengthened per the 337 stop-guard)

The 337 stop-guard (`337/.orchestrator-handoff.json`, preferred resolution) requires 340 to land the
value-faithful per-slot carrier so that `kvE2_sepSlotsLOf/ROf (kvE2_sepHonestOrder …)` is a
value-sorted chain matching `interleaveK ps`, PLUS `halignL/R` + assembled `regionsL/R` + `hbdry` as
consumable INPUTS.

| Owner | Deliverable | Nature |
|-------|-------------|--------|
| **340 v3** (SharedWitness) | Per-individual-slot value-faithful `kvE2_sepSlotGIdx`; `kvE2_sepHonestOrder` over `Fin N`; `kvE2_sepHonestOrder_mem_arr'`; **`halignL/R`** (mergeSort-by-gidx = engine value order); assembled boundary-linked **`regionsL/R`** with `hpos/hlink/hnd/hreal`; endpoint **`hbdry`**; the per-slot **coincidence fold** (Phase 9, gated) | value-faithful carrier + alignment; derivable from M's `LinearOrder` + the engine realizer binding |
| **337** (SubBracket2V + seam) | Consume the bundle → invoke `k1v_sorted_realizationK` → match `interleaveK` chain to `kvE2_sepBracketN` single-`ptW` point types → discharge endpoint conjuncts → `.holds` via `kvE_subBracket2V_sound_of_parts` → `kvE2_sepBody_holds_iff.mpr` | bracket-entangled; the M-realization step |

**No circular dependency**: 340 v3 → 337 is a linear shared-subgoal chain over the already-green
engine; 340 v3 consumes nothing 337 produces.

## Goals & Non-Goals

- **Goals**:
  - Replace the `ℕ×ℕ×ℕ` payload with a per-individual-slot index type; migrate behavior-preservingly
    to green (Phase 2).
  - Rebuild validity conjuncts (ii)+(iii), the enumeration (bound `N`, not `3*n`) + richness lemma,
    `kvE2_sepSlotGIdx`/`kvE2_sepSlotMergeLe`, and the SOUNDNESS-side membership re-proofs (Phases 3-5).
  - Define the value_j→engine-point binding and the honest per-slot order via `kvE2_ordRank` over
    `Fin N`; prove its membership (Phases 6-7).
  - Prove `halignL/R` (coincidence-free) and land the per-slot coincidence fold (Phases 8-9, Phase 9
    gated by Phase 1).
  - Assemble `regionsL/R` + `hbdry` and export the 337 hand-off; final axiom-clean/F1-F7/LITMUS audit
    (Phase 10).
- **Non-Goals**:
  - Building 337's `.holds` witness (`kvE_subBracket2V_sound_of_parts`) or invoking
    `k1v_sorted_realizationK` — that is task 337.
  - Any change outside `SharedWitness.lean`; any new axiom, `sorry`, or vacuous placeholder.
  - Re-deriving the `kvE2_ordRank` kernel or the anchor keystone (preserved verbatim).

## Risks & Mitigations

- **Risk (LOAD-BEARING): the per-slot coincidence fold reopens model-independence of the slot list.**
  A foreign witness forced onto an anchor makes the honest slot list model-dependent / variable-length,
  weakening the "bounded refinement" framing toward a partial carrier rebuild. **Mitigation**: Phase 1
  is a PAPER design gate on exactly this (see below). If model-independence genuinely reopens, the gate
  FAILS with a precise statement and the orchestrator escalates rather than churning a fifth time.
- **Risk: `value_j` for base slots is underspecified**, breaking `halign`. **Mitigation**: Phase 6
  binds `value_j` to the engine-realized point (data-flow inversion) explicitly; the binding lemma is
  proved before the honest order is defined FROM it.
- **Risk: type migration is monolithic-RED for a full dispatch** (v2's non-failure, but a known
  hazard). **Mitigation**: Phase 2 preserves behavior — old owner-block indices re-expressed in the
  new per-slot type, GREEN — before any value-faithful change. Phases sequenced type→validity→reader→
  soundness so each lands green.
- **Risk: the soundness-side `kvE2_sepModelOrder`/`kvE2_sepCoincidentOrder` re-proofs stall** (report
  08 Attack 3: 18 refs, 3 membership theorems). **Mitigation**: Phase 5 is dedicated to them; they
  reuse the same `List.mem_flatMap`/`List.mem_range` technique at the new arity.
- **Risk: `halign` proof (Phase 8) is the hardest** (~300-450 lines). **Mitigation**: proved in the
  coincidence-FREE case first (Phase 8), with the fold isolated to Phase 9; both are separate bounded
  units.
- **Risk: an axiom leak (`sorryAx`) hides behind a `decide`.** **Mitigation**: Phase 10 runs
  `lean_verify` on every touched top-level theorem; axiom set MUST equal
  `{propext, Classical.choice, Quot.sound}`.

## Implementation Phases

**Dependency Analysis (wave map)**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 0 | 1 (DESIGN GATE) | -- |
| 1 | 2 | 1 (PASS) |
| 2 | 3, 4 | 2 |
| 3 | 5, 6 | 3 / 4 |
| 4 | 7, 8 | 6 (+3 / +4) |
| 5 | 9 | 8, 1 (PASS with resolution (a)) |
| 6 | 10 | 8, 9 |

**Single-file note**: all edits land in `SharedWitness.lean`. The wave map declares LOGICAL
independence (ordering/batching freedom — e.g. Phases 3 and 4 have no inter-dependency), NOT
concurrent multi-agent file ownership (H7 territory here is the one file). Dispatch is sequential,
wave by wave. **Implementation phases 2-10 proceed ONLY if Phase 1's gate PASSES.**

### Phase 1: DESIGN GATE — coincidence fold + value-binding faithfulness proof (analysis) [NOT STARTED]

**PAPER ONLY. No Lean edited. Terminates in GATE PASS or GATE FAIL.** This gate discharges the
load-bearing risk (report 08 element 2) before any implementation commit, so the orchestrator
escalates rather than churning a fifth time on the same seam.

The gate MUST prove ON PAPER either:

- **(a) PASS**: the foreign-witness-at-anchor meet (report 06 R3) is handled faithfully WITHOUT
  reopening model-independence of the slot list — e.g. the fold routes through the existing
  `coincident` tag / `kvE2_sepCoincidentAnchor_discharge` channel (SW:~1695), the folded slot is
  identified via the CLOSED self-zone bit, and the honest slot list stays a valid `kvE2_sepArr'`
  member with `kvE2_sepSlotsLFor` (SW:292) remaining a fixed (model-independent) function of σ. Ground
  the argument in Rabinovich Def 3.1's `z_k = x_{i_k}` collapse (md:151, 168-173): the reference/base
  point collapsing onto a chain point is a legitimate disjunct of the Lemma 3.2(1) enumeration, not an
  unmet obligation. Show concretely how `halign`'s two lists stay equal length after the fold (the
  folded slot occupies the anchor's position, not a distinct one).

- **(b) FAIL**: if model-independence genuinely reopens (the realized slot list must become
  model-dependent / variable-length), mark the gate FAIL with a PRECISE statement of what breaks:
  which declaration (`kvE2_sepSlotsLFor`? `kvE2_sepArr'` membership?) loses model-independence, why the
  `coincident` channel cannot absorb the meet, and what the minimal carrier rebuild would be. The
  orchestrator escalates (a larger task, not phases 2-10 of this plan).

The gate must ALSO confirm design element 1 (value_j→engine-point binding): that the honest order can
be defined FROM the engine realizer (`k1v_sorted_realizationK` output) consistently threaded into both
the carrier index and the engine `regions`, without introducing an `x1 < e_i` literal (LITMUS).

- **Done when**: a written gate record states PASS (with the faithful fold routing + the value-binding
  data-flow direction, both Def-3.1-grounded) or FAIL (with the precise model-independence breakage).
  On PASS, Phase 9's approach is fixed. On FAIL, STOP — do not start Phase 2; emit escalation.
- **Estimated output**: paper analysis (no Lean), ~1-2 pages; grounded in Rabinovich Def 3.1 §5 +
  the real `kvE2_sepCoincidentAnchor_discharge` infrastructure.
- **Depends on**: --

### Phase 2: Carrier payload type migration — `ℕ×ℕ×ℕ` → per-slot index, behavior-preserving (green) [COMPLETED]

**Deviation note**: Payload migrated `(ℕ × ℕ × ℕ)` → `List ℕ` (variable-arity, per-slot-capable),
behavior-preserving: `kvE2_sepPlaceholderTuple`/`kvE2_sepHonestTuple` now emit length-3 lists
`[a,b,c]` reproducing the exact old owner-block indices; `kvE2_sepSlotGIdx` reads `t.getD rank 0`
(rank-indexed, tie retained — the tie removal is deferred to Phase 4 per the plan's own Phase-4
scope). Enumeration `kvE2_sepIdxTuples` keeps the `3*n` bound for behavior preservation; the
`N`-bound genuinely-per-slot rebuild is grown in Phase 3 (it is not behavior-preserving and would
force a RED refactor here, which the postmortem constraints forbid in Phase 2). Green, sorry-0,
axiom-clean `{propext, Classical.choice, Quot.sound}` (verified on `kvE2_sepHonestOrder_mem_arr'`).

Change `KvE2SepWeakOrder`'s payload (SW:~701) from `ℕ×ℕ×ℕ` to a per-slot index (recommended: a global
`List (KvE2SepSlot × ℕ)` assignment, or a per-owner `List ℕ` whose length is the owner's slot-block
length). Re-express the EXISTING owner-block semantics in the new type so the file stays GREEN — the
old `(3r,3r+1,3r+2)` behavior is transcribed into per-slot form with NO value-faithfulness change yet
(that lands in Phases 6+). Scaffold the per-slot enumeration `kvE2_sepIdxTuples` with the new `N` bound
(report 08 Attack 4: the `3*n` bound at SW:~734 is WRONG) and its `_mem_of_lt` richness stub.
`DecidableEq` is preserved (`List ℕ`/`List (KvE2SepSlot × ℕ)` has it — `kvE2_sepArr'_decidable`, SW:~927).

- **Done when**: `lake build` green, sorry-0; payload type is per-slot; `kvE2_sepModelOrder`/
  `kvE2_sepCoincidentOrder`/`kvE2_sepHonestOrder` supply behavior-preserving per-slot payloads; no
  value-faithfulness change yet. Commit.
- **Estimated output**: ~200-300 lines.
- **Depends on**: 1 (PASS).

### Phase 3: Validity conjuncts (ii)+(iii) + per-slot enumeration richness (green) [COMPLETED]

**Landed (dispatch sess_1783561356_89aa2d_340, additive/green, committed `phase 3.1`):** the
variable-length `N`-bound enumeration `kvE2_sepIdxTuplesN (n : ℕ) : ℕ → List (List ℕ)` (all length-`L`
lists with entries `< n`) + richness `kvE2_sepIdxTupleN_mem_of_forall_lt` (SW:~968-990). Reused
verbatim in the atomic wiring (swap `kvE2_sepIdxTuples n` → `kvE2_sepIdxTuplesN n (kvE2_sepSlotBlock σ).length`
in `kvE2_sepOrderTypes`).

**CORRECTION to the naive framing below (found this dispatch — load-bearing for the next).** The
consistency predicate CANNOT be a single strict chain over the block. `kvE2_sepSlotBlock σ` is NOT
globally rank-sorted: for a left-interior owner it is `[lXU(rank0)…] lX1(1) [lUW(2)…] [lWT(0)…]` —
rank DROPS from 2 (lUW, left region) back to 0 (lWT, right region) at the L→R boundary. Moreover
`kvE2_sepSlotsLOf` sorts ONLY the left-region slots and `kvE2_sepSlotsROf` ONLY the right-region
slots (separate mergeSorts). So `kvE2_sepConsistentTuple` must be REGION-SCOPED: within an owner's
LEFT region, region-monotone (`lXU-gidx < lX1-gidx < lUW-gidx`); within its RIGHT region separately
(`rWX1-gidx < rX1-gidx < rX1T-gidx`). A payload strictly-increasing along the whole block is WRONG.
Recommended shape: `kvE2_sepConsistentTuple σ t := decide (∀ j < B.length, ∀ k < B.length,
sameRegion(B[j],B[k]) → kvE2_sepSlotRank B[j] < kvE2_sepSlotRank B[k] → t.getD j 0 < t.getD k 0)`
with `B = kvE2_sepSlotBlock σ` (owner now threaded via `kvE2_sepDisjValid` calling
`kvE2_sepConsistentTuple p.1 p.2.2`). Conjunct (iii) → global `Nodup` over `wo.flatMap (·.2.2)`.

**Foundation landed (dispatch sess_1783578954_3bce55_340, 10 additive/green commits `phase 3.2`-`3.6`,
`5.1`-`5.2`, `7.1`-`7.2`):** region tag (`kvE2_sepSlotRegionLeft`); within-region rank sortedness +
block-position alignment (`kvE2_sepSlotBlock_region_rank_sorted`, `kvE2_sepBlock_pos_lt_of_rank_lt`);
`kvE2_sepSlotIndexOf_block_mono`; the REGION-SCOPED consistency predicate `kvE2_sepConsistentBlock`
(crux-corrected) + BOTH consistency proofs (`_slotIndexOf` prefix-sum, `_honest` value-rank via the
crux `kvE2_sepSlotValue_region_rank_mono`); BOTH global-Nodup lemmas; enumeration-parametric
`kvE2_sepOrderTypes_mem_aux'`/`_owners_aux'`; payload-flatten `kvE2_sepZipPayload_flatMap`. The atomic
swap consuming these is logically complete/correct (saved `swap-attempt-cycle2.patch`) but reverted
this dispatch for declaration reordering + the mergeSort-sortedness consumer layer (SW:1614-1627,
1798-1860) — see `.orchestrator-handoff.json`.

Remaining: apply the swap patch, relocate 3 declaration clusters (topological), mark 2 defs
noncomputable, fix `kvE2_sepArr'_sound` conclusion, and re-prove the mergeSort-sortedness consumers
against the `kvE2_sepBlockPos` reader. No new mathematics remains.

Generalize `kvE2_sepConsistentTuple` (SW:~902) from the per-owner `i₀<i₁<i₂` 3-chain to per-slot
**region-rank monotonicity**: every `lXU`-gidx < the owner's anchor-gidx < every `lUW`-gidx (the
per-owner region PARTIAL order — within-region order is FREE, set at the honest disjunct). Rebuild
`kvE2_sepDisjValid` (SW:~890-917) conjunct (iii) to a global `Nodup` over per-slot indices. Complete
`kvE2_sepIdxTuple_mem_of_lt` at the new `N` bound (same `List.mem_flatMap`/`List.mem_range` technique).
Ground: Def 3.1 per-owner interval order (R1-corrected); Lemma 3.2(1) enumeration.

- **Done when**: `lake build` green, sorry-0; validity admits any per-slot region-monotone + globally
  `Nodup` assignment; enumeration ranges over per-slot assignments with the `N` bound; richness lemma
  proves. Commit.
- **Estimated output**: ~180-280 lines.
- **Depends on**: 2.

### Phase 4: `kvE2_sepSlotGIdx` per-slot read + `kvE2_sepSlotMergeLe` re-sort (green) [COMPLETED]

**Landed (dispatch sess_1783561356_89aa2d_340, additive/green, committed `phase 4.1`):** the reader
coordinate `kvE2_sepBlockPos s := (kvE2_sepSlotBlock (kvE2_sepSlotSub s)).idxOf s` + `kvE2_sepBlockPos_lt`
(position `< block length` for block members; SW:~505-520). The atomic wiring reads
`kvE2_sepSlotGIdx wo s := t.getD (kvE2_sepBlockPos s) 0` (t = the owner's block-length payload),
STAYING model-independent (trip-wire respected — only the honest PAYLOAD VALUES are model-dependent,
not the reader). `kvE2_sepBlockPos_lt` guarantees the `getD` hits a real entry.

Remaining: rebuild `kvE2_sepSlotGIdx` (SW:~1183) to read at `kvE2_sepBlockPos` (drop `kvE2_sepSlotRank`),
keep `kvE2_sepSlotMergeLe` single-level; `kvE2_sepSlotsLOf/ROf_mem` (mergeSort_perm) preserved
comparator-agnostically. COUPLED with Phase 3 + Phase 5 — atomic RED→GREEN.

Rebuild `kvE2_sepSlotGIdx` (SW:~1006) to read the per-slot index DIRECTLY (no longer via
`kvE2_sepSlotRank` region-rank projection — that projection is the source of the tie). Keep
`kvE2_sepSlotMergeLe` single-level `decide (giOf a ≤ giOf b)`. `kvE2_sepSlotsLOf/ROf_mem`
(mergeSort_perm route) preserved comparator-agnostically.

- **Done when**: `lake build` green, sorry-0; `kvE2_sepSlotGIdx` reads per-individual-slot index; the
  mergeSort key is per-slot; membership route unchanged. Commit.
- **Estimated output**: ~120-200 lines.
- **Depends on**: 2.

### Phase 5: Soundness-side membership re-proofs (green) [COMPLETED]

Re-prove the SOUNDNESS-side `kvE2_sepModelOrder` (SW:~859) and `kvE2_sepCoincidentOrder` (SW:~1927)
membership in `kvE2_sepArr'` against the new per-slot enumeration + validity conjuncts (report 08
Attack 3: this is the phase report 07 OMITTED — both destructure the tuple). **Preserve 337-P1
`kvE2_sepCoincidentOrder_mem_arr'`** (SW:~1966) by re-proving it, not destroying it. Three membership
theorems total.

- **Done when**: `lake build` green, sorry-0; `kvE2_sepModelOrder` and `kvE2_sepCoincidentOrder` are
  proven `kvE2_sepArr'` members under the new carrier; `kvE2_sepCoincidentOrder_mem_arr'` (337-P1)
  re-proves; axiom-clean. Commit.
- **Estimated output**: ~200-320 lines.
- **Depends on**: 3.

### Phase 6: `value_j`→engine-point binding + honest per-slot order over `Fin N` (green) [COMPLETED]

**Value-binding foundation landed (dispatch sess_1783578954_3bce55_340, additive/green, committed
`phase 6.1`-`6.4`):** the ENTIRE model-dependent `value_j` binding + lex value rank — the identified
~350-line Phase-6 bottleneck — is now in `SharedWitness.lean` (all additive, no existing
declaration changed, `{propext, Classical.choice, Quot.sound}`):
- `kvE2_sepSlotValue` (report 08 element 1 data-flow inversion): anchor slots → `kvE2_sepAnchorVal`;
  base slots → `Classical.epsilon` over the interval-constrained realization existence. Total map.
- Eight spec lemmas: `kvE2_sepSlotValue_lX1/_rX1` (anchor, definitional) + six base-slot interval
  specs (`_lXU/_lUW/_rWX1/_rX1T` via honest bundles L/R; `_lWT/_rXW` via
  `kvE_subBracket2_complete_extract`): each slot's bound `value_j` lies in the slot's own region
  interval and realizes its base type χ.
- `kvE2_sepSlotG` (lex family `G j = (value_j, j)` over `Fin N`) + `kvE2_sepSlotG_injective` (from
  the index second coordinate, no value-distinctness) + `kvE2_sepSlotG_lt_of_value_lt`.
- `kvE2_sepSlotHonestGIdx` (the per-INDIVIDUAL-slot value rank `kvE2_ordRank G`, replacing the tied
  `(3r,3r+1,3r+2)`) + `kvE2_sepSlotHonestGIdx_mono` (Phase 7 conjunct (ii) region-monotonicity
  engine) + `kvE2_sepSlotHonestGIdx_injOn` (Phase 7 conjunct (iii) global-Nodup ingredient).

**Remaining Phase-6/atomic-flip work (structural, largely model-independent):** thread
`kvE2_sepSlotHonestGIdx` into the per-owner block-length honest payload; do the coupled 3-4-5-7
structural flip (region-scoped `kvE2_sepConsistentTuple`, `kvE2_sepDisjValid` (iii) global Nodup,
`kvE2_sepOrderTypes`/`_mem_aux`/`_owners_aux` N-bound enumeration, `kvE2_sepSlotGIdx` at
`kvE2_sepBlockPos`, model/coincident prefix-sum re-proofs, honest membership). The mono/injOn
engines above discharge the two hardest conjuncts.

**Original foundation landed (dispatch sess_1783561356_89aa2d_340, additive/green, committed):** handoff
step (1) — the model-independent per-individual-slot family — is now in `SharedWitness.lean`:
`kvE2_sepSlotBlock` (σ's LEFT++RIGHT block), `kvE2_sepAllSlots` (the full `Fin N` family),
`kvE2_sepSlotIndexOf` (= `idxOf`), with `kvE2_sepSlotSub_of_mem_block`, `kvE2_sepMem_allSlots`,
`kvE2_sepMem_slotBlock`, the load-bearing `kvE2_sepAllSlots_nodup` (per-block Nodup + cross-owner
disjointness), and `kvE2_sepSlotIndexOf_lt` / `kvE2_sepSlotIndexOf_injOn` (the `Fin N` bound +
structural injectivity for `G`'s index coordinate). Axiom-clean `{propext, Classical.choice,
Quot.sound}`. The remaining Phase-6 work (the `value_j` binding from the honest bundles + defining
`kvE2_sepHonestOrder` FROM `kvE2_ordRank G (slotIndexOf s)`, `G j = (value_j, j)` over `Fin N`) is
still to do, and is COUPLED with Phases 3+4 (variable-length payload + per-slot reader + N-bound
enumeration) — see the critical-coupling note in `.orchestrator-handoff.json`.

**Design element 1 (report 08).** Prove the value-assignment lemma binding each base slot's rank key
`value_j` to the engine's realized point, and the bridge "carrier index = value rank of realized
points". Define `kvE2_sepHonestOrder` via `kvE2_ordRank G (slotIndexOf s)` with `G j = (value_j, j)`
lex over the FULL slot family `Fin N` (`N` = total individual slots) — the data-flow inversion (honest
order defined FROM the engine realizer). Re-instantiate the preserved `kvE2_ordRank` kernel at the
slot family, NOT the anchor family. All owners tagged `.coincident` per the settled layout. Introduce
NO `x1 < e_i` literal (LITMUS): order only already-extracted realizer witnesses via M's `LinearOrder`.

- **Done when**: `lake build` green, sorry-0 (or sorry-tracked only for any 337-boundary realizer
  input, explicitly logged); the value-binding lemma proves; `kvE2_sepHonestOrder` is defined over
  `Fin N` with per-individual-slot distinct indices; `_mem_orderTypes` holds. Commit.
- **Estimated output**: ~200-350 lines.
- **Depends on**: 4, 1 (value-binding gate confirmation).

### Phase 7: `kvE2_sepHonestOrder_mem_arr'` re-proof (green) [COMPLETED]

Re-prove `kvE2_sepHonestOrder_mem_arr'` (SW:~2146) for the per-slot honest order: conjunct (i) tag
validators reused verbatim (`kvE2_sepCoincidentOwner_valid_left/right`, tuple-agnostic); (ii)
region-monotonicity via `kvE2_ordRank_strictMono` on the slot family + the keystone; (iii) global
`Nodup` via `kvE2_ordRank_injective` (the lex second coordinate gives injectivity with no
value-distinctness hypothesis); enumeration membership via `kvE2_ordRank_lt` → `kvE2_sepIdxTuple_mem_of_lt`.

- **Done when**: `lake build` green, sorry-0; `kvE2_sepHonestOrder_mem_arr'` proves under the per-slot
  carrier; the member is the object 337 consumes. Commit.
- **Estimated output**: ~150-250 lines.
- **Depends on**: 6, 3.

### Phase 8: `halignL/R` — mergeSort-by-gidx = engine value order, coincidence-free (green) [NOT STARTED]

**The crux the 337 stop-guard demanded.** Prove `halignL/R`: `kvE2_sepSlotsLOf/ROf (kvE2_sepHonestOrder …)`
(mergeSort by per-slot gidx) equals the engine's value-sorted `interleaveK ps` order, in the
COINCIDENCE-FREE case (engine points all distinct, ties impossible). Both sides are the M-value order
over individual slots, tie-broken identically by slot index; route the monotonicity through the
KEYSTONE (`kvE2_sepAnchor_injOn`) + `kvE2_ordRank_strictMono`, NOT the lex tiebreak (inert for
realizability). Uses `List.sorted_mergeSort` / `List.mergeSort_perm`.

- **Done when**: `lake build` green, sorry-0; `halignL/R` proves in the coincidence-free case; the
  `a<u'<b` cross-region interleave is realized (`i₂(σ) < i₁(τ)` ⟺ `x1_σ < x1_τ`). Commit.
- **Estimated output**: ~300-450 lines.
- **Depends on**: 6, 4.

### Phase 9: Per-slot meet-type coincidence fold — foreign-witness-at-anchor (green) [NOT STARTED — GATED BY PHASE 1]

**Design element 2 (report 08) — the LOAD-BEARING risk. Proceeds ONLY if Phase 1 PASSED with
resolution (a).** Land the fold: when a base slot's only realization equals an anchor value (report 06
R3), `kvE2_sepSlotsLOf` drops/folds that slot via the `coincident` tag / `kvE2_sepCoincidentAnchor_discharge`
channel (SW:~1695) so `halign`'s two lists keep equal length. Ground in Rabinovich §5 `z_k = x_{i_k}`
meet (md:168-173): the folded slot occupies the anchor's position (a legitimate Lemma-3.2(1)
disjunct), not a distinct one. Extend `halignL/R` (Phase 8) to the coincidence case. **No vacuous
placeholder / sorry to fake the fold** — if it cannot close faithfully, this is a Phase-1-gate
regression and must escalate, not paper over.

- **Done when**: `lake build` green, sorry-0; the coincidence fold discharges via the CLOSED-zone
  channel; `halignL/R` holds in the coincidence case; the honest slot list stays a `kvE2_sepArr'`
  member (model-independence preserved per the Phase-1 gate). Commit.
- **Estimated output**: ~200-400 lines.
- **Depends on**: 8, 1 (PASS with resolution (a)).

### Phase 10: `regionsL/R` assembly + `hbdry` + 337 hand-off export + final audit (green) [NOT STARTED]

Assemble the boundary-linked `regionsL/R : List (M.carrier × M.carrier × List (NormalForm sig 0 1))`
with `hpos` (strict `a_i < a_{i+1}`, from keystone), `hlink` (`Chain'` boundary-linked), `hnd`
(per-zone base-type `Nodup`), `hreal` (honest bundles). Prove endpoint `hbdry` (regionsL leftmost lo =
x, rightmost hi = w; regionsR lo = w, hi = t). Export the hand-off object for 337 (the three missing
inputs the stop-guard named: `regionsL/R`, `halignL/R`, `hbdry`). Run the final audit: full `lake
build`, `lean_verify` axiom set = `{propext, Classical.choice, Quot.sound}` on every touched top-level
theorem (no `sorryAx`), F1-F7 + LITMUS (no `x1 < e_i` literal; index abstract ℕ; F5 open/closed not
conflated), and confirm no 334/336/338/339 result destroyed.

- **Done when**: `lake build` green, sorry-0, axiom-clean; `regionsL/R` + `hbdry` + `halignL/R`
  exported and match `k1v_sorted_realizationK`'s signature (SubBracket2V.lean:633-646); F1-F7+LITMUS
  audit passes; seam 340→337→335 restored (`halign` provable). Commit; emit the 337 hand-off record.
- **Estimated output**: ~200-350 lines.
- **Depends on**: 8, 9.

## Testing & Validation

- [ ] `lake build` green, sorry-0 at the end of every phase (2-10).
- [ ] `lean_verify` axiom set = `{propext, Classical.choice, Quot.sound}` for all touched top-level
      theorems including `kvE2_sepHonestOrder(_mem_arr')`, `halignL/R`, the coincidence fold, and
      `kvE2_sepCoincidentOrder_mem_arr'`; no `sorryAx`.
- [ ] `kvE2_sepSlotGIdx` reads a per-INDIVIDUAL-slot index (no owner-region tie); distinct base slots
      of one owner-region get distinct value-ranked indices.
- [ ] `kvE2_sepIdxTuple_mem_of_lt` proves at the `N` bound (not `3*n`).
- [ ] `kvE2_sepModelOrder` AND `kvE2_sepCoincidentOrder` remain proven `kvE2_sepArr'` members;
      `kvE2_sepCoincidentOrder_mem_arr'` (337-P1) re-proves.
- [ ] `halignL/R` proves (coincidence-free AND coincidence cases); `regionsL/R` + `hbdry` exported and
      match the engine signature.
- [ ] The `a<u'<b` cross-region interleave is realized in the monotone slots.
- [ ] No `x1 < e_i` relative-position literal introduced (LITMUS grep); F5 open/closed keys not
      conflated; index is abstract ℕ.
- [ ] Seam 340→337→335 restored: the three inputs the 337 stop-guard named exist as consumable
      declarations.

## Artifacts & Outputs

- plans/03_perslot-individual-slot-refinement.md (this file)
- summaries/03_perslot-individual-slot-refinement-summary.md (on completion)
- Modified: Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/SharedWitness.lean

## Rollback/Contingency

- **Phase 1 gate FAIL**: STOP. Do not start Phase 2. Emit an escalation with the precise
  model-independence breakage (which declaration loses model-independence, why the `coincident`
  channel cannot absorb the meet, the minimal carrier rebuild). This is a larger task, not phases
  2-10 — the orchestrator escalates rather than churning.
- Each phase commits at a green, sorry-0 checkpoint (git-workflow.md commit-per-green-substep
  mandate); phases revert independently to the prior green state.
- Phase 2 (behavior-preserving type migration) must land green BEFORE any value-faithful change; if it
  cannot, the type choice (per-owner `List ℕ` vs global `List (KvE2SepSlot × ℕ)`) is reconsidered
  before proceeding — never a monolithic RED refactor.
- Never insert a vacuous/`sorry` placeholder to force green (especially the Phase 9 fold). If a genuine
  obstruction appears, mark [BLOCKED] with a concrete Lean counterexample — NOT a prose claim.
- The `.holds` closure is 337's; if it stalls, that is a task-337 concern — 340 v3's green deliverable
  (value-faithful carrier + `halignL/R` + `regionsL/R` + `hbdry`) stands independently.
