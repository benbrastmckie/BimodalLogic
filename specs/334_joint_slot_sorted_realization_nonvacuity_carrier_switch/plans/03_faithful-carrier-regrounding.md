# Implementation Plan: Task #334 — Faithful re-grounding of the NfMultiAnchorBridge carrier onto Rabinovich's proof architecture

- **Task**: 334 - Joint slot sorted realization / nonvacuity carrier switch (faithful re-grounding)
- **Status**: [IMPLEMENTING]
- **Date**: 2026-07-08
- **Effort**: 14-20 hours (9 phases; spike-gated at Phase 1; ~700-1050 net-new Lean lines)
- **Dependencies**: None to start. Downstream: the outer-gate assembly (`kvE2_body` / `bracketEndChar_kvE2`, task 321 v4) is a SEPARATE obligation — see Phase 9 and Risk R3; it likely needs its own task.
- **Research Inputs**:
  - handoffs/07_carrier-faithfulness-map.md (PRIMARY BLUEPRINT — HIGH confidence; this plan operationalizes it)
  - handoffs/06_singleton-sufficiency-scope.md (JOINT REQUIRED verdict; singleton retreat is a divergence)
  - handoffs/05_phase3-spike-relocation-blocker.md (the additive open-zone filter is FALSE post-switch)
  - handoffs/04_faithfulness-audit.md (Def 3.1 region partition; §5 coincidence = meet-typed shared point)
  - /home/benjamin/Projects/Literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.md (ground truth)
- **Prior Plans**: plans/01_joint-slot-sorted-realization.md, plans/02_faithful-region-partitioned-lift.md (retained as history; NOT templates — plan 02's fatal error was preserving the additive filter, see Faithfulness Rationale)
- **Artifacts**: plans/03_faithful-carrier-regrounding.md (this file)
- **Standards**: plan-format.md; status-markers.md; artifact-management.md; tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

The `NfMultiAnchorBridge` carrier (`kvE2_sep*` in `SharedWitness.lean`) implements a genuine, on-critical-path Rabinovich requirement — the multi-owner (JOINT) characterization of Lemma 3.2(1) — with a Lean-convenient structure that diverges from the paper at its core, and whose joint non-vacuity (`kvE2_sepBody_nonvacuous`) is not merely unproven but rests on scaffolds that are `sorryAx`-contaminated and documented FALSE. This plan replaces the divergent carrier with Rabinovich's structure: an **order-type disjunction over the merged anchor set** (Lemma 3.2(1)), a **region-partitioned interval decomposition** lifted from the already-proven single-owner engine (Def 3.1), and a **closed/point-type coincidence channel** (§5 meet-typed shared point). Both directions of Lemma 3.2(1) are realized, including the currently-absent completeness half.

The work is **spike-first**. Phase 1 is a make-or-break end-to-end construction on a concrete 2-owner case that proves the faithful architecture COMPOSES on the exact obligation the additive filter made FALSE. If the spike does not go green and axiom-clean, the plan STOPS and reports the obstruction before the ~700-1050-line rebuild is attempted. This front-loads the architectural risk — the discipline that caught the plan-02 failure at its own Phase 3.

**Definition of done**: `kvE2_sepBody_nonvacuous` (rewired) and a newly-stated `kvE2_sepBody_complete` both compile green and are axiom-clean (`[propext, Classical.choice, Quot.sound]`, no `sorryAx`); the additive-filter carrier, the singleton retreat, the flatMap slot union, and the FALSE scaffolds are removed; all 7 faithfulness invariants hold; the outer-gate scope decision is recorded.

### Research Integration

This plan is the direct operationalization of handoff 07 (the authoritative paper→Lean divergence map). The architecture (order-type disjunction + region partition + closed/point channel = "Option B") is fixed at HIGH confidence by handoffs 04/06/07; handoff 05 supplies the type-checked refutation of the alternative (additive filter) and the exact 2-owner counterexample the spike must dissolve. Phase-to-construct mapping follows handoff 07 §3 (reconstruction blueprint) and §4 (abandon/reuse/build lists).

### Prior Plan Reference

Plan 02 ("faithful region-partitioned lift") shares the same faithful target (Option B) but made one fatal structural concession: it **kept the additive open-zone filter `kvE2_sepValid` / `kvE2_sepArrL/R` and the flatMap slot union as "preserved assets"** and only ADDED a point-type channel beside them. Plan-02's own Phase-3 spike then proved (handoff 05) that this only RELOCATES the coincident-anchor obligation: the discharge produces the CLOSED-zone bit `zAtX1L`, which the preserved OPEN-zone additive filter (reading `zXU`/`zUW`) structurally cannot consume — distinct `nf0_assemble` keys, independent `σ.2` bits, Lean type-mismatch confirmed. `kvE2_sepBody_nonvacuous` is FALSE for the full carrier. **This plan's decisive difference: the additive filter framing itself is ABANDONED, not preserved.** Each order-type disjunct reads the zone bits appropriate to ITS arrangement (open bits for strict disjuncts; the closed `zAtX1L` bit for the coincidence disjunct). Effort calibration from plan 02: 8 phases / 12-18h estimated; this plan is 9 phases / 14-20h (one extra completeness-direction phase, since `kvE2_sepBody_complete` is genuinely absent).

### Roadmap Alignment

No `roadmap_flag` set for this dispatch. The carrier feeds `KampPrior.lean:351` (the depth-k≥2 Cor 5.4 converter, ROADMAP:30/51) via the not-yet-attempted task 309 Phase 13.4/14 wiring (ROADMAP:36). This plan does not modify ROADMAP.md.

## Faithfulness Rationale (read this first)

**Why the order-type disjunction is the faithful transcription** (per handoff 07 §0, §2):

JOINT-ness is a property of the **output normal form** `VVecEA2` (a disjunction of totally-ordered exists-forall brackets — the exact form the Prop 4.2 negation-closure induction rides), NOT of the model semantics. Type-checked ground (`NormalForm.lean:198-207`): the gate target `∃w, atomLayer ∧ ∀σ, (∃x1, nf_eval_nf M 1 4 [x1,w,x,t] σ) ↔ qnf.2 σ` is per-σ-independent in the model (each `x1_σ` independently existentially quantified, sharing only `w,x,t`). But expressing the per-σ conjunction `⋀_σ (∃x1_σ …)` as a SINGLE `VVecEA2` forces listing all witnesses `(w, x1_σ, x1_τ, …)` as the ordered points of one bracket in some order — i.e. it forces the merge. This is exactly **Lemma 3.2(1)** (paper md:77): "conjunction of exists-forall ≡ **disjunction** of exists-forall." Different orders = different disjuncts; the coincidence `x1_σ = x1_τ` is one order-type carrying the **meet** (§5, md:168-173). Per-σ semantics does not license a per-σ representation; the required output normal form forces the merge. This is HIGH confidence and dissolves the last "singleton is enough" escape hatch.

**The three faithful pillars** (paper → construct):
- **Order-type disjunction** over the merged anchor set `A := {x1_σ : σ∈pos} ∪ {w}` = Lemma 3.2(1) (md:77) + Def 3.3 V-exists-forall (md:81-82). NOT the additive single-bit open-zone filter over a flat slot list.
- **Region-partitioned interval decomposition** per disjunct = Def 3.1 (md:61-74). Reuse `k1v_sorted_realization3`'s per-owner region-interior witnesses (`SubBracket2V.lean:379-402`), lifted from `{x1,w}` to the merged anchor set `A`. NOT a total single-point sort or flatMap slot union.
- **Closed/point-type coincidence channel** = §5 meet-typed shared point (md:168-173, 213-219). Reuse the axiom-clean `kvE2_sepCoincidentAnchor_discharge`. Coincidence is a first-class DISJUNCT, not a tie refuted by an inequality.

**Both directions of Lemma 3.2(1)** must be realized (invariant F2):
- ⇒ (soundness): a held disjunct implies the conjunction. The four task-333 compat leaves supply the ⇒ bit-content INSIDE a strict disjunct.
- ⇐ (completeness): every honest model arrangement selects its order-type disjunct. `kvE2_sepBody_complete` is currently ABSENT (grep 0) — this plan STATES and proves it.

### Abandon / Reuse / Build accounting (binding)

**ABANDON** (Lean-convenience divergences, removed as this plan proceeds — state explicitly as removed in the phase that supersedes each):
- `kvE2_sepSlotsL`/`R` flatMap slot union (C3, `SharedWitness.lean:315/320`) — the flat cross-owner list, no paper analogue.
- `kvE2_sepValid` + `kvE2_sepArrL`/`R` additive open-zone filter (C4/C6, `:466/:472/:477`).
- `kvE2_sepBody_nonvacuous` in its current form (C10, `:1191`) — `sorryAx`-contaminated; rewired in Phase 6.
- The FALSE scaffolds `kvE2_sepSlotsL_valid` / `kvE2_sepSlotsR_valid` (`:894/:901`, sorries `@897/@904`, documented "FALSE post-switch") — removed in Phase 6.
- The singleton "N2" retreat `kvE2_sepSingleton` / `kvE2_sepBody_singleton*` (`:1944/:1952/:2069/:2212`) + its two strategic sorries (`@2093/@2225`) — removed in Phase 8; it characterizes only a proper subclass.
- (Historical: `List.mergeSort` joint sort — already retired, C17; not re-introduced.)

**REUSE** (faithful, landed, verified — do NOT re-plan or break; see Preserved Assets):
- `k1v_sorted_realization` (`CarrierK1V.lean:1447`) + `k1v_sorted_realization3` (`SubBracket2V.lean:379`) — the region engine (sorry-free). Lifted to k anchors in Phase 3.
- `kvE_subBracket2V` (`SubBracket2V.lean:139`) + `kvE_subBracket2V_correctness_pair` (`:1855`, sorry-free, both directions) — the single-owner bracket.
- `kvE_subBracket2_complete_extract` (`SubBracket2.lean:606`) incl. the GENERIC zone-forward channel (`:614-618`) that already admits `zAtX1L` — **no extractor extension needed** (confirmed by plan-02 Phase 3; `SubBracket2.lean` stays UNCHANGED).
- `kvE2_sepCoincidentAnchor_discharge` (`SharedWitness.lean:1161`) — **axiom-clean** closed-zone brick (verified `[propext, Classical.choice, Quot.sound]`); the §5 coincidence discharge.
- The four compat leaves `kvE2_sepCompat_{lX1,lX1_after,rX1,rX1_after}_eq` (`:409/:422/:434/:446`) — correct INSIDE strict disjuncts (Phase 4/5 re-host them; see Rebuild note).
- `kvE2_sepFreshAnchor_ne_baseChiPoint` (`:1133`, reduced form) — for the NON-coincident disjuncts only.
- `kvE2_sepHonestBundleL` (`:1083`) — per-owner honest bundle; the R mirror is built in Phase 7.
- `kvE2_sepPos` (`:193`), `kvE2_sepSlotsLFor`/`RFor` (`:292/:304`, per-owner region content, F per owner), `kvE2_sepBracketN` (`:611`, N-slot bracket shape).
- The 10 non-interior `_sound`/`_complete` dischargers + Prop 4.3 reflatten engine + Prop 4.2 `neg_2var_vec_ea` (all landed, F).

**BUILD** (absent, on the faithful critical path):
- The order-type disjunction index + per-disjunct validity predicate (Phases 1-2), replacing `kvE2_sepArrL/R`.
- The k-anchor region-partition lift (Phase 3), generalizing `k1v_sorted_realization3`.
- The 5th closed-zone (`zAtX1L`) compat leaf + the three-way (before/**at**/after) segment-meet cut (Phases 4-5), replacing the binary cut `kvE2_sepSegLForSub/RForSub` (C7, `:561/574`).
- `kvE2_sepHonestBundleR` (Phase 7, C13 — absent).
- `kvE2_sepBody_complete` — the ⇐ direction of Lemma 3.2(1) (Phase 8, P6/C11 — absent).
- (Separately, downstream / own task) the outer `kvE2_body` / `bracketEndChar_kvE2` assembly engine.

**REBUILD note — task 333's four additive compat leaves.** They are additive-filter-based in their CURRENT role (global validity over the flat union). Under the order-type-disjunction structure their bit-reading STATEMENTS survive (`kvE2_sepCompat_lX1_eq : kvE2_sepCompat a (.lX1 σ) = kvE2_sepBits σ zXU χ`, etc.) but their ROLE changes: they become the **strict-adjacency validators of a single strict disjunct**, not bits of a global additive filter. All four SURVIVE (re-hosted, per handoff 07 §3.1); NONE is replaced. What is replaced is the containing filter (`kvE2_sepValid`/`kvE2_sepArrL/R`). A **fifth, new** closed-zone leaf reading `zAtX1L` validates the coincidence disjunct. This is NOT handoff 05's rejected "Option A" (a single disjunctive `zXU ∨ zAtX1L ∨ zUW` filter over the same flat union — symptom-patching); it is per-order-type validity where each disjunct reads the bits appropriate to its own arrangement.

## Preserved Assets (binding — do NOT re-plan, re-prove, or break)

These are landed and verified. The plan consumes them as inputs. Any phase that touches a file containing these must leave them green.

| Asset | Site | State | Role in this plan |
|-------|------|-------|-------------------|
| `k1v_sorted_realization` | CarrierK1V.lean:1447 | sorry-free | Per-region insertion induction, reused verbatim per region in Phase 3 |
| `k1v_sorted_realization3` | SubBracket2V.lean:379 | sorry-free | Three-region template generalized to k anchors in Phase 3 |
| `kvE_subBracket2V_correctness_pair` | SubBracket2V.lean:1855 | sorry-free, non-vacuous | Single-owner bracket, both directions |
| `kvE_subBracket2_complete_extract` (+ generic zone-forward channel) | SubBracket2.lean:606 (:614-618) | landed | Admits `zAtX1L` forward; SubBracket2.lean stays UNCHANGED |
| `kvE2_sepCoincidentAnchor_discharge` | SharedWitness.lean:1161 | sorry-free, axiom-clean | The closed-zone brick; input to the coincidence disjunct (Phases 1,4) |
| four compat leaves `kvE2_sepCompat_*_eq` | SharedWitness.lean:409/422/434/446 | landed | Re-hosted as strict-disjunct validators (Phase 4/5) |
| `kvE2_sepFreshAnchor_ne_baseChiPoint` (reduced) | SharedWitness.lean:1133 | axiom-clean | Non-coincident disjuncts only (Phase 3/4) |
| `kvE2_sepHonestBundleL` | SharedWitness.lean:1083 | landed | Left honest bundle; R mirror built in Phase 7 |

## Faithfulness Invariants (plan-level acceptance — EVERY phase preserves ALL 7)

Each phase's Verification block names which invariants it actively exercises; none may be violated by any phase.

- **F1 — Lemma 5.1 QF point/segment types**: point (α) and segment (β) types stay quantifier-free over Σ (`charBase = nf_depth0_char_formula`); higher FO depth only via Prop 4.3 re-flatten, never by nesting a depth-k characteristic. (md:134-135)
- **F2 — Lemma 3.2(1) never weakened to vacuity; BOTH directions realized**: no disjunct set is silently empty; the ⇒ (held disjunct ⇒ conjunction) and ⇐ (every honest arrangement selects a disjunct) halves are both proved. (md:77)
- **F3 — Lemma 3.2(2) anchor cap 2**: free anchors stay `{x,t}`; `x1,w` (and merged `x1_σ`) are interior WITNESS slots, never new free anchors. (md:76-79)
- **F4 — no-nesting**: no `x1 < e_i` literal; no nested depth-k characteristic inside a point/segment type (LITMUS). (md:65-72)
- **F5 — LITMUS discrimination**: the carrier's zone keys remain distinct/discriminating (`zAtX1L`/`zXU`/`zUW`/`zWT` differ in coordinate 0); the coincidence disjunct reads the closed key, strict disjuncts the open keys — never conflated.
- **F6 — F4-chain (Cor 5.4) discriminates**: the per-bracket F_i chain (`F_n:=α_n`, `F_{i-1}:=α_{i-1}∧(β_i Until F_i)`, md:154-157) translates a single bracket faithfully; multi-owner combination sits ABOVE it (Lemma 3.2(1)), not folded into it.
- **F7 — macro-side confinement**: all rebuild lives in `NfMultiAnchorBridge/SharedWitness.lean` (macro side); `SubBracket2.lean`, `SubBracket2V.lean`, `CarrierK1V.lean` reused unchanged except an additive k-anchor lift co-located with the region engine if unavoidable (Phase 3).

## Goals & Non-Goals

**Goals**:
- Prove the faithful architecture COMPOSES on a concrete 2-owner coincidence case (Phase 1 gate) before the full rebuild.
- Replace the additive-filter carrier with the order-type disjunction + k-anchor region partition + closed/point channel.
- State and prove BOTH directions of Lemma 3.2(1): rewire `kvE2_sepBody_nonvacuous` (⇒) axiom-clean; build `kvE2_sepBody_complete` (⇐).
- Remove the abandon-list constructs (additive filter, flat union, FALSE scaffolds, singleton retreat).
- Verify: lake build green; sorry inventory clean on the top theorems; axiom-clean check on nonvacuity + completeness; all 7 invariants hold.

**Non-Goals**:
- Building the outer-gate assembly engine (`kvE2_body` / `bracketEndChar_kvE2`, task 321 v4 / NS Phase-7). This is a SEPARATE obligation (Risk R3; Phase 9 records the scope decision and recommends a follow-up task). The faithful carrier is a correct INPUT to it, but the rebuild does not remove it.
- Wiring the carrier into `KampPrior.lean:351` (task 309 Phase 13.4/14).
- Any density assumption ruling out coincidences (unfaithful; handoff 05 Option C rejected).
- Re-proving preserved assets.

## Risks & Mitigations

| ID | Risk | Impact | Likelihood | Mitigation |
|----|------|--------|------------|------------|
| R0 | **Spike does not compose** (the make-or-break): the order-type disjunction filter + closed channel fail to prove the 2-owner coincidence non-vacuous | H | M | Phase 1 is the explicit gate. If it does not go green + axiom-clean, STOP — do NOT build Phases 2+; report the obstruction with the exact failing goal. Fallback below. |
| R1 | Order-type enumeration blow-up / decidability: the weak-order index on `A` (ties allowed) must be a finite, `decide`-able `List`; tie-handling multiplies disjuncts | M | M | Keep the index a `List` of weak orders; reuse `VVecEA2.disjList` (NavigatedSpine:140). Bound by anchor cap (F3): `|A| = |pos| + 1`, small in practice. Prototype the enumeration in Phase 2 on ≤3 owners. |
| R2 | Segment-meet correctness (the genuinely new content): the three-way cut's "at" case must set the meet type AND stay sound for negative owners' universal β over the shared interval | H | M | Phase 4/5 isolate this; the "at" case discharges via the axiom-clean closed brick; split L/R so each is one agent run. |
| R3 | ⇐-completeness (`kvE2_sepBody_complete`) never stated before; each honest arrangement must select its disjunct across owners | H | M | Phase 8; template exists (`mem_permutations.mpr (Perm.refl _)`, SB2V:1440-1444), lift across owners; consumes `kvE2_sepHonestBundleL/R`. Splittable 8a-L/8b-R. |
| R4 | **Outer-gate entanglement**: `kvE2_body`/`bracketEndChar_kvE2` have no live def (task 321 v4 unbuilt) | M | H (already true) | Decision (Phase 9): the carrier rebuild does NOT require the outer gate — the carrier's nonvacuity + completeness are self-contained theorems, verifiable green + axiom-clean independently. Flag the outer-gate assembly as an explicit downstream dependency needing its own task. |
| R5 | `sorryAx` leakage: FALSE scaffolds / singleton sorries must be fully retired so the new theorems are axiom-clean | M | L | Phases 6 & 8 remove them at the point of supersession; Phase 9 runs `lean_verify` on the top theorems to confirm no `sorryAx`. |

**Fallback if the Phase 1 spike fails (R0)**: Do not weaken to vacuity and do not reintroduce the single-point sort. Report the precise obstruction (failing goal, which bit is unconsumable, minimal counterexample) in the phase summary and `.orchestrator-handoff.json` with `status: "blocked"`, `next_action_hint: "escalate"`. The escalation options at that point are: (a) a different faithful merge representation of `VVecEA2` (re-research); or (b) accept that the multi-owner completeness is genuinely out of reach for this `VVecEA2` shape and escalate to a normal-form redesign task. The spike's job is to surface this BEFORE the 700+-line investment, exactly as plan-02's Phase 3 did.

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3 | 1 |
| 3 | 4, 5, 7 | 2, 3 (4,5); 3 (7) |
| 4 | 6 | 4, 5 |
| 5 | 8 | 6, 7 |
| 6 | 9 | 8 |

Phases within the same wave can execute in parallel. Phase 1 is a HARD GATE: waves 2-6 are conditional on Phase 1 going green + axiom-clean.

---

### Phase 1: MAKE-OR-BREAK SPIKE — faithful architecture composes on a concrete 2-owner coincidence [COMPLETED]

**Goal**: Prove, end-to-end on ONE concrete 2-owner arrangement, that an order-type-disjunction validity predicate reading the CLOSED `zAtX1L` bit in the coincidence disjunct makes non-vacuity TRUE for the exact `qnf` the additive filter made FALSE. This is the whole plan's premise; it must be settled before any rebuild.

**Paper citation**: Lemma 3.2(1) (md:77) — coincidence is a disjunct; §5 meet-type shared point (md:168-173).

**Tasks**:
- [x] Instantiate the handoff-05 counterexample *(completed — altered: modeled via the realization-parametrized 2-owner arrangement matching `kvE2_sepCoincidentAnchor_discharge`'s hypotheses (σ = anchor-owning left-interior sub realized at `[x1,w,x,t]`; χ = foreign owner τ's base type realized AT `x1`; open bits `zXU`/`zUW` pinned false), rather than a hardcoded finite `sig`/`M`/`qnf` fixture. Rationale: the parametrized realization is a robust, general encoding of the exact counterexample that exercises the REAL preserved brick, avoiding fixture-decidability noise unrelated to the make-or-break.)*
- [x] Define a MINIMAL order-type-disjunction validity predicate for this 2-owner set *(completed — `KvE2SepSpikeOrderType` = {strictBefore, strictAfter, coincident}; `kvE2_sepSpikeOrderTypes` list includes the tie disjunct; `kvE2_sepSpikeArr := orderTypes.filter (kvE2_sepSpikeDisjValid σ χ))*
- [x] Route the coincidence disjunct's validity through the CLOSED `zAtX1L` bit *(completed — `kvE2_sepSpikeDisjValid .coincident = kvE2_sepBits σ zAtX1L χ`; strict disjuncts read `zXU`/`zUW`; no conflation)*
- [x] Prove the coincidence disjunct is non-empty for this `qnf` *(completed — `kvE2_sepSpike_twoOwner_coincidence_nonvacuous : kvE2_sepSpikeArr σ χ ≠ []`, closing via `kvE2_sepCoincidentAnchor_discharge`. Companion `kvE2_sepSpike_additiveOpenOnly_vacuous` proves the open-only filter is `[]` on the same scenario — the plan-02 RED baseline dissolved.)*
- [x] Run `lean_verify` on the spike lemma *(completed — `[propext, Classical.choice, Quot.sound]`, NO `sorryAx`; contrast lemma `[propext, Quot.sound]`)*

**Acceptance criteria (GATE)**: spike lemma compiles green; sorry-free; axiom-clean. If ANY of these fail: STOP, do not proceed to Phase 2; write the obstruction to the phase summary and handoff (Risk R0 fallback).

**Lemma names produced**: `kvE2_sepSpike_twoOwner_coincidence_nonvacuous` (spike, may be deleted or promoted after Phase 2); a throwaway concrete `qnf` fixture.

**Faithfulness invariants exercised**: F2 (non-vacuity, coincidence direction), F5 (closed vs open key discrimination — the crux), F1 (QF types).

**Timing**: 2-4 hours (~150-300 lines, or STOP early).

**Depends on**: none.

**Files to modify**: `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/SharedWitness.lean` (spike scaffold only).

---

### Phase 2: General order-type-disjunction index + per-disjunct validity predicate [COMPLETED]

**Goal**: Generalize the Phase-1 spike to the k-owner merged anchor set `A := {x1_σ : σ∈kvE2_sepPos qnf} ∪ {w}`: a finite, decidable `List` of weak orders (ties allowed) on `A`, with a per-disjunct validity predicate. This replaces `kvE2_sepArrL/R := (flatMap slot union).permutations.filter (additive kvE2_sepValid)`.

**Paper citation**: Lemma 3.2(1) (md:77) disjunction over merge order-types; Def 3.3 V-exists-forall (md:81-82).

**Tasks**:
- [x] Define the weak-order index `kvE2_sepOrderTypes qnf : List (WeakOrder A)` (finite; `decide`-able; ties represent coincidences). *(altered: `WeakOrder A` realized as `KvE2SepWeakOrder sig := List (NormalForm sig 1 4 × KvE2SepSpikeOrderType)` — per-owner placement tags of each `x1_σ` relative to the merge pivot `w`; enumeration is the cartesian `foldr` product `3^|pos|`. `VVecEA2.disjList` is the Phase-6 assembly consumer of this filtered list, not needed for the index definition itself; noted for Phase 6.)*
- [x] Define per-disjunct validity `kvE2_sepDisjValid qnf π`: strict adjacencies validated by the surviving open-zone compat leaves; ties validated by the (Phase-4) closed-zone leaf placeholder. *(completed — `kvE2_sepDisjValidOwner`: strict → `kvE2_sepBits σ zXU/zUW`; tie → `kvE2_sepClosedLeafStub` forward-reading `kvE2_sepBits σ zAtX1L (nf0_projFresh σ.1)`. Genuine bit reads, NO sorry; Phase 4 re-hosts the closed read as `kvE2_sepCompat_zAtX1L_eq` over foreign types.)*
- [x] Replace `kvE2_sepArrL/R` with `kvE2_sepArr' qnf := kvE2_sepOrderTypes qnf |>.filter (kvE2_sepDisjValid qnf)`. *(completed — `kvE2_sepArr'` built; old `kvE2_sepArrL/R` NOT yet deleted, per abandon-list timing they are removed in Phase 6 when the assembly is rewired; both coexist green for now.)*
- [x] Prove the index is non-empty for honest `qnf` at the structural level (decidability + at least the model-order disjunct present). *(completed — `kvE2_sepArr'_decidable` instance; `kvE2_sepModelOrder_mem_orderTypes` (unconditional, enumeration contains the model order); `kvE2_sepArr'_mem_modelOrder` (model-order in the filtered carrier given its validity — the honest-selection hypothesis discharged in Phase 8). All axiom-clean `[propext, Classical.choice, Quot.sound]`.)*

**Acceptance criteria**: compiles green; `kvE2_sepOrderTypes` and `kvE2_sepArr'` are `decide`-able and terminating; no new sorries beyond forward-declared closed-leaf stub (discharged in Phase 4).

**Lemma names produced**: `kvE2_sepOrderTypes`, `kvE2_sepDisjValid`, `kvE2_sepArr'`, `kvE2_sepArr'_decidable`, `kvE2_sepArr'_mem_modelOrder`.

**Faithfulness invariants**: F2 (disjunction, no vacuity), F3 (anchor cap — `|A|=|pos|+1`), F5.

**Timing**: 2-3 hours (~200-300 lines).

**Depends on**: 1.

**Files to modify**: `SharedWitness.lean`.

---

### Phase 3: Multi-anchor region-partition lift (`k1v_sorted_realizationK`) [COMPLETED]

**Goal**: Generalize the proven three-region `k1v_sorted_realization3` (`SubBracket2V.lean:379`) to a **k-region** partition around the merged, per-disjunct-fixed anchor set `A`, reusing `k1v_sorted_realization` (`CarrierK1V.lean:1447`) verbatim per region. Per-owner region-interior witnesses; distinctness is per-region-per-owner (type-driven `nf_eval_unique`, NormalForm:245) — NOT across owners at an anchor.

**Paper citation**: Def 3.1 interval decomposition (md:61-74); Lemma 5.1 per-region insertion (md:134-135).

**Tasks**:
- [x] State `k1v_sorted_realizationK`: given fixed strictly-ordered anchors `a_0 < a_1 < … < a_k` and per-region Nodup type lists realized strictly interior, produce per-region point lists whose concatenation (stitched around the anchors) is `Pairwise (· < ·)`. *(completed — anchors encoded as the region list `[(a_i, a_{i+1}, S_i)]` with `hlink : hiᵢ = loᵢ₊₁` (`List.Chain'`) + `hpos : loᵢ < hiᵢ`; concatenation is `interleaveK ps` (blocks separated by interior anchors, final outer anchor dropped exactly as `k1v_sorted_realization3` drops `t`). SubBracket2V.lean.)*
- [x] Prove by folding `k1v_sorted_realization` once per region and stitching (generalize the `k1v_sorted_realization3` stitch: every region-`i` point exceeds `a_i` and is below `a_{i+1}`). *(completed — `k1v_realizationK_build` folds `k1v_sorted_realization` (CarrierK1V:1447) verbatim per region producing the tagged arrangement + anchor `Chain'`/positivity; `k1v_stitch_regions` (+ `k1v_stitch_lowers_ge`) proves `interleaveK` strictly increasing by peeling one region and threading the strict-below invariant. All axiom-clean `[propext, Classical.choice, Quot.sound]`.)*
- [x] Confirm the `.permutations`-as-disjunction machinery (SB2V:129,249-251) reuses per region. *(completed — the Forall₂ conclusion carries `List.Perm (p.2.2.map Prod.fst) r.2.2` PER region, so each region's selected arrangement is a permutation of that region's own type list — precisely what the per-region `S_z.permutations` flatMap (`kvE_subBracket2V` :249-251) enumerates; the k-region lift arranges each region independently, reusing the machinery per region without cross-owner coupling.)*

**Acceptance criteria**: `k1v_sorted_realizationK` compiles green, sorry-free; instantiates back to `k1v_sorted_realization3` for k=3 (regression check).

**Lemma names produced**: `k1v_sorted_realizationK` (+ any stitch helper `k1v_stitch_regions`).

**Faithfulness invariants**: F1 (QF region types), F3 (interior witnesses, not new anchors), F4 (no `x1 < e_i` literal), F7 (co-located with region engine if it must live in SubBracket2V; otherwise SharedWitness).

**Timing**: 3-4.5 hours (~250-350 lines — the largest net-new construct).

**Depends on**: 1.

**Files to modify**: `SubBracket2V.lean` (co-located with the region engine — narrowest additive scope; F7) OR `SharedWitness.lean`. Do NOT alter existing `k1v_sorted_realization3`/`k1v_sorted_realization`.

---

### Phase 4: Closed-zone compat leaf + three-way segment-meet cut — LEFT [NOT STARTED]

**Goal**: Build the 5th closed-zone (`zAtX1L`) compat leaf validating the coincidence disjunct, and replace the binary before/after left segment cut `kvE2_sepSegLForSub` (C7, `:561`) with a three-way before/**at**/after cut whose "at" case sets the segment type to the MEET and discharges via the closed brick. Re-host the two LEFT compat leaves (`kvE2_sepCompat_lX1_eq`, `kvE2_sepCompat_lX1_after_eq`) as strict-disjunct validators.

**Paper citation**: §5 splitting `A_i = A_i^- ∧ A_i^+`, case-split on which i the new point matches (md:168-173, 213-219); §5 coincidence = meet type.

**Tasks**:
- [ ] Define `kvE2_sepCompat_zAtX1L_eq` (the 5th leaf: `kvE2_sepCompat` at a tie reads `kvE2_sepBits σ zAtX1L χ`), fed by `kvE2_sepCoincidentAnchor_discharge`.
- [ ] Replace `kvE2_sepSegLForSub` with `kvE2_sepSegLForSub'` (three-way: before → left β; at → meet β_σ ∧ β_τ; after → right β), branching on `nf0_zoneSpec σ.1`.
- [ ] Prove the "at" case is sound for negative owners' universal β over the shared interval (Risk R2 core content).
- [ ] Confirm the two LEFT compat leaves survive as strict-disjunct validators (their statements unchanged; role re-hosted).

**Acceptance criteria**: compiles green; the "at" case discharges axiom-clean; the two LEFT compat leaves still typecheck in the new role.

**Lemma names produced**: `kvE2_sepCompat_zAtX1L_eq`, `kvE2_sepSegLForSub'`, `kvE2_sepSegLForSub'_at_sound`.

**Faithfulness invariants**: F2 (meet, not vacuity), F5 (closed key for tie), F1 (QF meet type), F6 (chain per bracket unaffected).

**Timing**: 2.5-3.5 hours (~150-250 lines).

**Depends on**: 2, 3.

**Files to modify**: `SharedWitness.lean`.

---

### Phase 5: Three-way segment-meet cut — RIGHT [NOT STARTED]

**Goal**: Mirror Phase 4 on the right: replace `kvE2_sepSegRForSub` (C7, `:574`) with the three-way cut; re-host the two RIGHT compat leaves (`kvE2_sepCompat_rX1_eq`, `kvE2_sepCompat_rX1_after_eq`) as strict-disjunct validators. Confirm the same closed-zone leaf serves the right coincidence disjunct.

**Paper citation**: §5 splitting (md:168-173, 213-219), right sub-interval `A_i^+(z,z_1)` (md:170).

**Tasks**:
- [ ] Define `kvE2_sepSegRForSub'` (three-way before/at/after, right region).
- [ ] Prove the "at" case sound (right-side, symmetric to Phase 4).
- [ ] Confirm the two RIGHT compat leaves survive as strict-disjunct validators.
- [ ] Record the compat-leaf survival audit: all four `kvE2_sepCompat_*_eq` survive; none replaced; one new closed leaf added (Phase 4).

**Acceptance criteria**: compiles green; "at" case axiom-clean; four compat leaves + one closed leaf all live in the new roles.

**Lemma names produced**: `kvE2_sepSegRForSub'`, `kvE2_sepSegRForSub'_at_sound`.

**Faithfulness invariants**: F2, F5, F1, F6.

**Timing**: 2.5-3.5 hours (~150-250 lines).

**Depends on**: 2, 3.

**Files to modify**: `SharedWitness.lean`.

---

### Phase 6: Lemma 3.2(1) ⇒ (soundness) + rewire `kvE2_sepBody_nonvacuous` + remove FALSE scaffolds [NOT STARTED]

**Goal**: Prove the ⇒ direction — a held order-type disjunct implies the conjunction — over `kvE2_sepArr'`, using the k-anchor region lift (Phase 3) and the three-way cuts (Phases 4-5). Rewire `kvE2_sepBody` / `kvE2_sepBody_nonvacuous` onto `kvE2_sepArr'` (off `List.Perm.refl` / the flat union). Remove the FALSE scaffolds `kvE2_sepSlotsL_valid`/`_valid` and the additive `kvE2_sepValid`/`kvE2_sepArrL/R`/flatMap slot union.

**Paper citation**: Lemma 3.2(1) ⇒ (md:77): a held disjunct (one consistent arrangement) implies the conjunction; Def 3.1 (md:61-74).

**Tasks**:
- [ ] Prove `kvE2_sepArr'_sound`: a valid disjunct's realization implies the joint conjunction holds.
- [ ] Rewire `kvE2_sepBody` to build over `kvE2_sepArr'`; prove `kvE2_sepBody_nonvacuous` (rewired) — disjuncts ≠ [] for honest qnf, via the k-anchor region lift + coincidence disjunct.
- [ ] DELETE `kvE2_sepSlotsL_valid`/`kvE2_sepSlotsR_valid` (`:894/:901`) and the flatMap union `kvE2_sepSlotsL`/`R`, the additive `kvE2_sepValid`/`kvE2_sepArrL`/`R`. State explicitly in the phase summary: these are REMOVED.
- [ ] `lean_verify` on the rewired `kvE2_sepBody_nonvacuous`: confirm NO `sorryAx`.

**Acceptance criteria**: compiles green; `kvE2_sepBody_nonvacuous` axiom-clean (`[propext, Classical.choice, Quot.sound]`); the four abandoned constructs are gone (grep 0).

**Lemma names produced**: `kvE2_sepArr'_sound`, `kvE2_sepBody` (rewired), `kvE2_sepBody_nonvacuous` (rewired, axiom-clean).

**Faithfulness invariants**: F2 (⇒ realized, not vacuous), F3, F5, F7.

**Timing**: 2-3 hours (~150-250 lines).

**Depends on**: 4, 5.

**Files to modify**: `SharedWitness.lean`.

---

### Phase 7: `kvE2_sepHonestBundleR` — completeness-side mirror [NOT STARTED]

**Goal**: Build the absent right honest bundle (C13): from an honest `qnf`, a right-interior owner σ yields anchor `x1` + real witnesses per its `zWX1`/`zWT` 1-types, mirroring `kvE2_sepHonestBundleL` (`:1083`). This is the completeness-side per-owner input consumed by Phase 8.

**Paper citation**: Def 3.1 exterior/interior β (md:66-74); Lemma 3.2(1) ⇐ honest arrangement (md:77).

**Tasks**:
- [ ] State `kvE2_sepHonestBundleR` symmetric to `kvE2_sepHonestBundleL`.
- [ ] Prove via the extractor's generic forward channel + the region structure (Phase 3).

**Acceptance criteria**: compiles green, sorry-free; symmetric to and consistent with the landed L bundle.

**Lemma names produced**: `kvE2_sepHonestBundleR`.

**Faithfulness invariants**: F1, F2, F4.

**Timing**: 2-3 hours (~150-250 lines).

**Depends on**: 3.

**Files to modify**: `SharedWitness.lean`.

---

### Phase 8: Lemma 3.2(1) ⇐ (completeness) — state + prove `kvE2_sepBody_complete` + retire singleton retreat [NOT STARTED]

**Goal**: STATE and prove the genuinely-absent completeness half: every honest model arrangement of the merged witnesses selects its order-type disjunct. Consume both honest bundles (`kvE2_sepHonestBundleL` + Phase-7 R). Then retire the singleton "N2" retreat (`kvE2_sepSingleton`/`kvE2_sepBody_singleton*` + its two strategic sorries `@2093/@2225`), now superseded by the joint completeness.

**Paper citation**: Lemma 3.2(1) ⇐ (md:77): every model arrangement is some disjunct; §5 case-split on which i the point matches (md:168-173).

**Tasks**:
- [ ] Phase 8a (LEFT): state `kvE2_sepBody_complete` and prove the left honest arrangement selects its disjunct (template `mem_permutations.mpr (Perm.refl _)`, SB2V:1440-1444, lifted across owners; coincidence → tie disjunct).
- [ ] Phase 8b (RIGHT): complete the right half using `kvE2_sepHonestBundleR`.
- [ ] DELETE `kvE2_sepSingleton`, `kvE2_sepBody_singleton*` and the two strategic sorries. State explicitly in the summary: singleton retreat REMOVED.
- [ ] `lean_verify` on `kvE2_sepBody_complete`: confirm NO `sorryAx`.

**Acceptance criteria**: `kvE2_sepBody_complete` compiles green, sorry-free, axiom-clean; singleton constructs gone (grep 0); no `sorryAx` anywhere in the carrier's top theorems.

**Lemma names produced**: `kvE2_sepBody_complete` (NEW — the ⇐ half of Lemma 3.2(1)).

**Faithfulness invariants**: F2 (⇐ realized — the whole point), F1, F5, F6.

**Timing**: 3-4.5 hours (~200-350 lines; splittable 8a-L / 8b-R).

**Depends on**: 6, 7.

**Files to modify**: `SharedWitness.lean`.

---

### Phase 9: Final verification + outer-gate scope decision [NOT STARTED]

**Goal**: Full verification of the rebuilt carrier and an explicit, recorded decision on outer-gate entanglement.

**Paper citation**: whole-carrier faithfulness audit against Def 3.1 / Lemma 3.2(1) / Lemma 5.1 / §5.

**Tasks**:
- [ ] `lake build Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.SharedWitness` → exit 0.
- [ ] Sorry inventory: confirm the 2 FALSE scaffolds (Phase 6) and 2 singleton strategic sorries (Phase 8) are gone; report residual count (target: 0 in the carrier's critical path).
- [ ] `lean_verify` axiom-clean check on BOTH `kvE2_sepBody_nonvacuous` and `kvE2_sepBody_complete`: `[propext, Classical.choice, Quot.sound]`, no `sorryAx`.
- [ ] Invariant audit: confirm all 7 faithfulness invariants (F1-F7) hold across the rebuilt carrier.
- [ ] **Outer-gate scope decision (record explicitly)**: `kvE2_body`/`bracketEndChar_kvE2` have no live def (task 321 v4 / NS Phase-7 assembly ENGINE). DECISION: the faithful carrier rebuild does NOT require rebuilding the outer gate — the carrier's nonvacuity + completeness are self-contained, verified theorems. The outer-gate assembly is a SEPARATE downstream obligation. Recommend a dedicated follow-up task (see Summary). Record this in the phase summary and handoff.

**Acceptance criteria**: build green; both top theorems axiom-clean; invariant audit passes; scope decision recorded.

**Lemma names produced**: none (verification phase).

**Faithfulness invariants**: F1-F7 (audit).

**Timing**: 0.5-1 hour.

**Depends on**: 8.

**Files to modify**: none (verification only; the phase summary + handoff record the outer-gate decision).

---

## Testing & Validation

- [ ] Phase 1 gate: spike lemma green + sorry-free + axiom-clean, or STOP with obstruction report.
- [ ] `lake build …SharedWitness` exits 0 after each phase (incremental green commits per hard-mode H9).
- [ ] `k1v_sorted_realizationK` regresses to `k1v_sorted_realization3` at k=3.
- [ ] `kvE2_sepBody_nonvacuous` (rewired) is TRUE for the handoff-05 counterexample `qnf` (the exact case the additive filter made FALSE).
- [ ] `kvE2_sepBody_complete` is stated and proved (grep confirms it now exists).
- [ ] `lean_verify kvE2_sepBody_nonvacuous` and `lean_verify kvE2_sepBody_complete` → `[propext, Classical.choice, Quot.sound]`, no `sorryAx`.
- [ ] Abandon list gone: grep 0 for `kvE2_sepValid`, `kvE2_sepArrL`, `kvE2_sepArrR`, `kvE2_sepSlotsL_valid`, `kvE2_sepSlotsR_valid`, `kvE2_sepSingleton`, `kvE2_sepBody_singleton`.
- [ ] Preserved assets still green (no regression in `k1v_sorted_realization*`, `kvE_subBracket2V_correctness_pair`, `kvE2_sepCoincidentAnchor_discharge`, the four compat leaves, `kvE2_sepHonestBundleL`).
- [ ] All 7 faithfulness invariants (F1-F7) audited green.

## Artifacts & Outputs

- plans/03_faithful-carrier-regrounding.md (this file)
- summaries/03_faithful-carrier-regrounding-summary.md (on completion)
- Modified: `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/SharedWitness.lean` (primary), possibly `SubBracket2V.lean` (Phase 3 k-anchor lift, additive only)
- New lemmas: `kvE2_sepOrderTypes`, `kvE2_sepDisjValid`, `kvE2_sepArr'`, `k1v_sorted_realizationK`, `kvE2_sepCompat_zAtX1L_eq`, `kvE2_sepSegLForSub'`, `kvE2_sepSegRForSub'`, `kvE2_sepArr'_sound`, `kvE2_sepBody` (rewired), `kvE2_sepBody_nonvacuous` (rewired), `kvE2_sepHonestBundleR`, `kvE2_sepBody_complete`
- Recommended follow-up task: outer-gate assembly engine (`kvE2_body` / `bracketEndChar_kvE2`, task 321 v4 / NS Phase-7) — see Summary.

## Rollback/Contingency

- Each phase commits incrementally at every green milestone (hard-mode H9); if a phase fails to close, the prior green commit is the rollback point (no destructive git on a dirty tree — snapshot first per git-workflow.md).
- **Phase 1 gate failure (R0)**: STOP; do not build Phases 2+; report obstruction; status → blocked, next_action_hint escalate. Do not weaken to vacuity or reintroduce the single-point sort.
- **Scope escalation**: if, during Phases 2-8, the outer-gate entanglement proves to block carrier verification (contrary to the Phase-9 decision), flag it immediately as a blocker and recommend splitting the outer-gate assembly into its own task rather than expanding this plan.
- The abandoned constructs are removed only at the phase that supersedes each (Phase 6 for the filter/scaffolds, Phase 8 for singleton), so the build stays green throughout; if a removal breaks a downstream reference unexpectedly, restore the construct and re-scope the removal to Phase 9.

## Scope note (single task vs split)

The carrier re-grounding itself (Phases 1-9) is a coherent single task: it reuses the proven region engine and single-owner pair (a generalization, not a fifth green-field carrier), and its output theorems are self-contained. It is at the upper end of a single task (~700-1050 lines, 9 phases). The **outer-gate assembly engine** (`kvE2_body`/`bracketEndChar_kvE2`, task 321 v4 / NS Phase-7 two-level quant-layer connector, currently no live def) is genuinely OUT of scope and should be a **separate task** — the faithful carrier is a correct input to it, but rebuilding the assembly is a distinct, substantial obligation with its own captured failed-closer history (NS:423-435). Recommendation: keep this plan focused on the carrier; open a follow-up task for the outer gate once the carrier is green.
