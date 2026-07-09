# Implementation Plan v4: Task #337 — Joint Multi-Owner Disjunct `.holds` Builder on the 340↔337 Co-Design Interface

- **Task**: 337 - Build the joint multi-owner disjunct bracket-`holds` engine for `kvE2_sepDisjunct`, delivering the ⇐-direction builder `kvE2_sepDisjunct_holds_of_honest`
- **Status**: [NOT STARTED]
- **Effort**: 4-5 hours
- **Dependencies**: 336 (COMPLETED — `kvE2_sepBody_complete` generalized `hL` → `hLR`); 338 (COMPLETED, axiom-clean — enriched `KvE2SepWeakOrder`, `kvE2_sepBody` consumes `wo`); 339 (COMPLETED — region-primary key, superseded by 340); **340 (blocking; Phases 1-4/6 green, Phase 5 = the engine-precondition selection lemma being finished FIRST)**. 337 is currently BLOCKED and is unblocked the moment 340 Phase 5 lands its bundle.
- **Research Inputs**: specs/340_perslot_globalindex_carrier_enrichment_for_valuefaithful_slot_order/reports/05_research-team-synthesis.md; specs/340_.../reports/03_lean-carrier-model-independence.md; specs/340_.../reports/04_337-codesign-interface.md; specs/337_.../reports/01_rabinovich-witness-ordering-faithfulness.md; specs/337_.../reports/02_coincident-order-and-weakorder-scope.md; specs/338_enrich_separatedbody_weakorder_with_crossowner_anchor_order/summaries/01_weakorder-crossowner-enrichment-summary.md; specs/335_outer_gate_assembly_engine_kvE2_body/reports/02_spawn-analysis.md
- **Artifacts**: plans/04_joint-disjunct-holds-codesign.md (this file)
- **Standards**: plan-format.md; status-markers.md; artifact-management.md; tasks.md; lean4.md (literature-fidelity-policy.md)
- **Type**: lean4
- **Lean Intent**: false

## Overview

This is the **v4 redesign** of task 337, produced by revising v3 (`plans/03_rank-ordered-coincidence-holds-builder.md`) against the completed 3-agent research investigation on the 340↔337 seam (`specs/340_.../reports/05_research-team-synthesis.md` + agent reports 03 and 04). v3 was **BLOCKED at Phase 2** by a concretely-grounded structural mismatch: task 338's `kvE2_sepSlotsLOf/ROf wo` was a **per-owner BLOCK flatMap**, but `k1v_sorted_realizationK` requires a boundary-linked (`Chain'`) region list and emits `interleaveK ps` in **merged-anchor order**, while `IntervalPattern.holds_eq_succ` requires the witness strictly monotone in block-index order. For ≥2 interior owners whose base-witness intervals interleave, block order ≠ merged order, so no monotone witness existed (three `lean_run_code`/`decide`/`omega` experiments in the v3 blocker, `.orchestrator-handoff.json`).

**Task 340 dissolves that blocker at the carrier level.** The single per-slot **global index** (`kvE2_sepSlotGIdx` SharedWitness.lean:921-928; single-level compare `kvE2_sepSlotMergeLe` :936-938) turns the slot list into a genuine cross-owner MERGE: `kvE2_sepSlotsLOf/ROf wo = (owners.flatMap slotsSFor).mergeSort (kvE2_sepSlotMergeLe wo)` (:949-957). Region rank is **no longer primary**; the merged order can equal any order-consistent cross-region interleaving of the union of all owners' points (report 04 Q4; the committed example SW:1026-1034 documents a region-2 slot receiving a strictly smaller index than a foreign region-1 anchor). So a `wo` whose global index equals M's true value order makes `kvE2_sepSlotsLOf wo` **equal the merged model order** — precisely the single boundary-linked chain `k1v_sorted_realizationK`'s `hlink`/`hreal` demand, which was `omega`-unsatisfiable under 339 (report 04 Q4; report 03 Q1(1b)).

The crux of THIS revision is the **strengthened interface**. The 3-agent synthesis (report 05 §3; report 04 verdict (b)) established that 337's input from 340 Phase 5 is NOT the weak order-existence `∃ wo, SlotsLOf wo monotone`, but the **engine-precondition bundle**: `wo ∈ kvE2_sepArr' qnf` PLUS, for both `kvE2_sepSlotsLOf wo` and `kvE2_sepSlotsROf wo`, a boundary-linked region decomposition **in genuine M-value order** satisfying `k1v_sorted_realizationK`'s four hypotheses (`hpos`/`hlink`/`hnd`/`hreal`) — the realized value assignment, not merely an order-existence claim. This plan **pins that strengthened contract as 337's verified INPUT** (Preconditions section) and does NOT re-derive it.

337's own remaining work is the four bracket-entangled steps (a)–(d) the synthesis assigns to it (report 05 contract table; report 04 Q3 carve-out): (a) consume the precondition bundle, (b) invoke `k1v_sorted_realizationK` to obtain the `interleaveK` monotone chain, (c) match that chain to `kvE2_sepBracketN`'s single-`ptW` `IntervalPattern` point types (the ONLY bracket-entangled step), (d) discharge the endpoint conjuncts `kvE2_sepEpL`@x / `kvE2_sepEpR`@t, yielding `(kvE2_sepDisjunct … (kvE2_sepSlotsLOf wo) (kvE2_sepSlotsROf wo)).2.holds M atomMap x t`. The `.holds` core is `kvE_subBracket2V_sound_of_parts` (SubBracket2V.lean:1025, referenced at SW:1927).

### The 340↔337 boundary: keep-separate, no cycle (REQUIRED determination)

**Determination (report 04 verdict (a)/(c); report 05 §3):** the two tasks stay SEPARATE with a clean acyclic interface. **NO task merge with 340. NO circular dependency.**

- **337 consumes 340's bundle; 340 consumes nothing 337 produces.** 337 produces `kvE2_sepDisjunct … .holds`; 340 Phase 5's deliverable (the value-order-realized engine inputs + `wo ∈ kvE2_sepArr'`) is logically **prior to and independent of** `.holds` and of the bracket. The dependency is linear `340-P5 → 337` — a **shared subgoal over the already-green engine `k1v_sorted_realizationK`**, not a cycle (report 04 Q3(a)).
- **The boundary is anchored to a concrete, type-checked, bracket-independent object** — `k1v_sorted_realizationK`'s signature — unlike the abstract 339 2-level key that caused the prior handoff failure (report 04 Q3 "Why NOT fold"). 340 stops at the value-ordered realized slot data (engine INPUTS); 337 owns the engine INVOCATION + the `kvE2_sepBracketN` `lL ++ ptW :: lR` slice, because that slice is bracket-dependent (report 04 Q3 carve-out; Q5 caveat).
- **All task-334/336/338/339/340 carrier lemmas are verified INPUTS** — apply, do not re-derive or weaken. This task is **ADDITIVE**: new helpers + one builder + one corollary in `SharedWitness.lean`; it edits NO existing declaration. If any step appears to require editing a 334/336/338/339/340 INPUT, STOP and surface it as a scope question rather than weakening a verified INPUT.

### Rabinovich faithfulness (confirmed)

The model-realization step this task owns is Rabinovich's "one place" of model contact (Prop 4.3 all-chains equivalence; Insight #3: Dedekind-completeness "used in exactly one place" — report 05 §1, PDF spot-check §"R2 … COMPLETE"). The realization/witness layer = 337's per-M construction; the 340/337 seam sits exactly on Rabinovich's formula-level/realization-level boundary (Def 3.1 single strictly-increasing chain, confirmed against PDF p.4; Def 7.13 multi-owner union, PDF p.15). This is 337's job by design and is faithful.

### Research Integration

Newly integrated (this revision):
- `specs/340_.../reports/05_research-team-synthesis.md` — the reconciled co-design contract (§3, contract table): 340-P5 delivers the engine-precondition bundle in M-value order; 337 owns engine invocation + single-`ptW` bracket match; keep-separate, no cycle; Rabinovich faithfulness + PDF spot-check confirmed.
- `specs/340_.../reports/04_337-codesign-interface.md` (Agent C) — the `k1v_sorted_realizationK` input/output contract (Q1), the strengthened interface verdict (Q2/verdict (b)), the no-cycle analysis (Q3), what 340's index newly gives 337 (Q4), the honest-bundle aggregation scope (Q5).
- `specs/340_.../reports/03_lean-carrier-model-independence.md` (Agent B) — the two-obligation split (non-vacuity vs value-faithful `.holds`), the `∃ wo ∈ kvE2_sepArr', P(M,wo)` framing over the unchanged carrier, the `.holds` (D) boundary object = 337's `kvE_subBracket2V_sound_of_parts` construction.

Carried forward: `reports/01_rabinovich-witness-ordering-faithfulness.md` (Option A faithful witness; enumeration at the formula level), `reports/02_coincident-order-and-weakorder-scope.md` (coincidence first-class), the 338 summary (enriched carrier consuming `wo`), and `specs/335_.../reports/02_spawn-analysis.md` (verified-INPUT boundary).

### Assets preserved from v3 (do NOT re-derive or delete)

v3 Phase 1 landed **green + axiom-clean**: `kvE2_sepCoincidentOrder_mem_arr'` (the honest coincidence weak order is a member of `kvE2_sepArr'`; the ⇐ membership witness for `kvE2_sepBody_holds_iff.mpr`), additive, editing no carrier declaration. **This lemma stays in `SharedWitness.lean`, untouched.** Under v4, the honest `wo` and its membership are supplied by 340 Phase 5's bundle (which delivers `wo ∈ kvE2_sepArr'` in genuine model order, not merely the coincidence placeholder order); the v3 asset remains available as a fallback/INPUT and MUST NOT be discarded. v3's Phases 2–6 (the additive-on-338 region-assembly route) are **superseded** — the region decomposition is now delivered by 340-P5 rather than assembled here from 338's block flatMap.

### Roadmap Alignment

No ROADMAP.md consulted (roadmap flag not set). Advances the `kamp_theorem_formalization` topic by landing the faithful completeness-side joint bracket engine on 340's terminal per-slot-index carrier, unblocking parent task 335 Phases 2–4.

## Preconditions — the 340-Phase-5 engine-precondition bundle (VERIFIED INPUT)

**This section pins 337's input contract. Treat the entire bundle as a verified INPUT delivered by task 340 Phase 5 (`kvE2_sepBody_complete_holds`'s engine-input core, `SharedWitness.lean`). Do NOT re-derive, re-prove, or weaken it. 337 begins by DESTRUCTURING this bundle.**

For an honest instance — `charBase`, `charK`, `qnf : NormalForm sig 2 3`, `M : OrderedMonadicStructure sig`, `atomMap`, `w x t : M.carrier`, `hxw : x < w`, `hwt : w < t`, `hLR` (every positive owner is left- or right-interior), and the honest depth-2 evaluation `h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)` — task 340 Phase 5 supplies:

1. **`wo : KvE2SepWeakOrder sig` with `hmem : wo ∈ kvE2_sepArr' qnf`** — the honest weak order whose per-slot global index (`kvE2_sepSlotGIdx wo`, SW:921-928) equals M's true cross-owner value order. Membership is 340's (`kvE2_sepIdxTuple_mem_of_lt` + the honest-tuple validity route, report 03 Q4).

2. **For `S ∈ {L, R}`, a boundary-linked region decomposition of the value-ordered slot list `kvE2_sepSlotsSOf wo` in genuine M-value order:**
   `regionsS : List (M.carrier × M.carrier × List (NormalForm sig 0 1))` together with exactly the four `k1v_sorted_realizationK` hypotheses (SubBracket2V.lean:633-646, report 04 Q1):
   - `hposS  : ∀ r ∈ regionsS, r.1 < r.2.1`
   - `hlinkS : List.Chain' (fun a b => a.2.1 = b.1) regionsS`
   - `hndS   : ∀ r ∈ regionsS, r.2.2.Nodup`
   - `hrealS : ∀ r ∈ regionsS, ∀ χ ∈ r.2.2, ∃ u, r.1 < u ∧ u < r.2.1 ∧ nf_eval_nf M 0 1 (fun _ => u) χ`
   plus an **alignment fact** `halignS` tying the region point-type lists (concatenated in `hlinkS` link order) to the value-ordered `kvE2_sepSlotsSOf wo`, sliced at the bracket's `lL ++ ptW :: lR` split (report 04 Q3 carve-out; the `x1_σ` anchors appear as type-carrying interior points, `w` remaining the sole `ptW`, report 04 Q5 caveat).

3. **The endpoint boundary alignment**: `regionsL`'s leftmost `lo = x`, `regionsL`'s rightmost `hi = w`, `regionsR`'s leftmost `lo = w`, `regionsR`'s rightmost `hi = t` (so the merged chain runs `x < … < w < … < t`).

**Why this is exactly consumable (report 04 Q4, report 03 Q1(1b)):** under 340's single global index, `kvE2_sepSlotsLOf wo` is the mergeSort of the full slot multiset by `kvE2_sepSlotGIdx wo`; choosing `wo` = the honest value order makes that list the merged model order, so the decomposition in (2) exists and satisfies `hlink`/`hreal` — the precise precondition that was unsatisfiable under 339's region-primary key. 337 does NOT prove (1)–(3); it receives them.

> **Interface stability note.** The exact Lean packaging of this bundle (a `structure`, an `∃`-tuple, or the `Kv337RealizedSlotOrder` predicate of report 03 §Q3) is 340 Phase 5's to fix. 337's Phase 1 begins by reading the landed 340-P5 signature (`kvE2_sepBody_complete_holds` / its engine-input helper) and destructuring whatever concrete shape it exposes into the `wo, hmem, regionsL/R, hpos/hlink/hnd/hreal L/R, halignL/R` fields above. If the landed 340-P5 shape is weaker than (2)+(3) (e.g. delivers only `∃ wo, monotone`), STOP and surface it as an interface mismatch — do not attempt to re-derive the missing engine hypotheses inside 337 (that is the re-scope the synthesis explicitly rejected, report 04 Q2).

## Goals & Non-Goals

**Goals**:
- Consume the 340-P5 engine-precondition bundle (Preconditions) as a verified INPUT; destructure `wo`, `hmem`, and the L/R region decompositions with their four engine hypotheses + alignment facts.
- Invoke `k1v_sorted_realizationK` on `regionsL` and `regionsR`, obtain `ps` + `(interleaveK ps).Pairwise (· < ·)`, and define the bracket witness `ws : Fin (N+1) → M.carrier` re-indexed into the `kvE2_sepSlotsLOf wo ++ ptW :: kvE2_sepSlotsROf wo` slot order, with strict monotonicity + range `x < ws i < t`.
- Match `ws`/`interleaveK` to `kvE2_sepBracketN`'s single-`ptW` `IntervalPattern` point types and segment families, closing `(kvE2_sepDisjunct charBase charK qnf (kvE2_sepSlotsLOf wo) (kvE2_sepSlotsROf wo)).2.holds M atomMap x t` via `IntervalPattern.holds_eq_succ.mpr` / `kvE_subBracket2V_sound_of_parts` (SubBracket2V.lean:1025).
- Discharge the endpoint conjuncts `kvE2_sepEpL`@x and `kvE2_sepEpR`@t from the honest evaluation `h`.
- Deliver a sorry-free `kvE2_sepDisjunct_holds_of_honest` concluding `∃ wo ∈ kvE2_sepArr' qnf, (kvE2_sepDisjunct charBase charK qnf (kvE2_sepSlotsLOf wo) (kvE2_sepSlotsROf wo)).2.holds M atomMap x t` (the exact ⇐ witness shape of `kvE2_sepBody_holds_iff`, SW:1111-1113), plus the corollary `kvE2_sepBody_holds_of_honest` = builder + `kvE2_sepBody_holds_iff.mpr`, exposing `(kvE2_sepBody charBase charK qnf).holds M atomMap x t` — the object task 335 consumes.
- `lean_verify` axiom-clean (`{propext, Classical.choice, Quot.sound}`, no `sorryAx`); full `lake build` green.
- Preserve F1–F7 (esp. F5 no open/closed zone-key conflation — coincident tags read only the CLOSED `zAtX1L`/`zAtX1R` self-zone bits; LITMUS NavigatedSpine:437 — no `x1 < e_i` relative-position literal; witness/segment bounds come from the bracket range `x`/`w`/`t` and the engine's interior guarantees `hreal`, NEVER an owner-to-owner chain).

**Non-Goals**:
- **Do NOT re-derive the 340-P5 bundle.** `wo`, `hmem`, `regionsL/R`, `hpos/hlink/hnd/hreal L/R`, and the value-faithfulness of the global index are task 340's verified deliverables (report 03 verdict; report 05 contract table). 337 receives them.
- **Do NOT merge with task 340**, and **do NOT create a circular dependency**. 337 consumes 340's bundle; 340 consumes nothing from 337 (report 04 Q3(c)). The seam is `k1v_sorted_realizationK`'s type signature.
- **Do NOT edit ANY task-334/336/338/339/340 definition or lemma.** This task is ADDITIVE — new helpers + one builder + one corollary only.
- **Do NOT re-enumerate permutations at the `.holds` level** (`List.mem_permutations` / Option B forbidden). The formula-level enumeration `kvE2_sepArr'` already lands the faithful disjunction (Lemma 3.2(1), PDF p.4; report 01 §2).
- **Do NOT target the strict `kvE2_sepModelOrder` tags** for validity — the strict OPEN bits are not honestly provable; the honest `wo` carries coincident tags (CLOSED self-zone discharge) with model-order global indices (report 05 §2; report 03 Q2).
- **Do NOT touch `OuterGate.lean` or `KampPrior.lean`** — task 335's consumption is a separate re-dispatch.
- No bare `sorry`/`admit`, no new `axiom`, no vacuous placeholder (`def X := True`), no `.holds` modulo an assumed monotonicity/anchor hypothesis.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| **Bracket point-type match (step c) is the deepest step** — align `interleaveK ps` (multi-separator) to `kvE2_sepBracketN`'s single-`ptW` `lL ++ ptW :: lR` layout (SW:602-608) | H | M | Highest-risk phase (Phase 3), sized alone. Use the landed k=3 template `SubBracket2V.lean:807-819` (`witnesses = usXU ++ x1 :: usUW ++ w :: usWT`, monotone → `.holds`) as the shape guide; build point-type realizations and the `beta` segment families as separate green `have`s; if overflow looms, commit the point-type helper as its own sorry-free lemma and split the segment matcher into a follow-on green sub-step (never a `sorry`). |
| `ws` re-indexing of `interleaveK ps` into `kvE2_sepSlotsLOf wo ++ ptW :: kvE2_sepSlotsROf wo` | H | M | Mirror the extractor's index arithmetic in reverse (pivot `ptW` at `|kvE2_sepSlotsLOf wo|`); the `interleaveK` block/separator structure (SubBracket2V.lean:453-457) aligns with the value-order slot layout via the bundle's `halignL/R` alignment facts. Verify pivot index by `lean_hover_info` on the landed `kvE2_sepDisjunct_extract` before use. |
| 340-P5 bundle shape differs from Preconditions (2)+(3) (e.g. weaker `∃ monotone wo`) | H | L | Phase 1 opens by reading the landed 340-P5 signature and destructuring it; if weaker than the engine-precondition bundle, STOP and surface as an interface mismatch (Preconditions interface-stability note) — do NOT re-derive the engine hypotheses in 337. |
| Post-340 line numbers shifted from v3's references | M | M | Every phase opens with a grep + one `lean_hover_info` per cited identifier to re-confirm line/shape before use (line numbers below are from reports 03/04 against the 340-enriched file and are advisory). |
| Endpoint conjunct discharge (`kvE2_sepEpL`@x / `kvE2_sepEpR`@t) needs a helper not present | M | L | Extract from the atom-layer of `h` over `[w,x,t]` (the same data `kvE2_sepDisjunct_extract` destructures as `hepL`/`hepR`); add a small private `have` if no direct helper exists. |
| Faithfulness regression: `x1 < e_i` literal (LITMUS NS:437) or F5 open/closed key conflation | H | L | All witness/segment bounds from region endpoints `x`/`w`/`t` and engine interior guarantees (`hreal`), never an owner-to-owner chain; coincident tags read ONLY the CLOSED self-zone bits; Phase 5 re-audits F1–F7. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 0 | (external) | 340 Phase 5 landing its bundle |
| 1 | 1 | 340-P5 bundle |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |

Fully sequential: each phase consumes the sorry-free auxiliary lemma of the previous. Each phase is sized to one agent run (H8) and ends at a green, sorry-tracked `lake build`. **Phases 1–4 map one-to-one to the synthesis's steps (a)–(d); Phase 5 is the axiom-clean + faithfulness gate.**

### Phase 1: Consume the 340-P5 engine-precondition bundle (step a) [IN PROGRESS]

**STOP-GUARD RESOLVED** (2026-07-09, re-verified against the CURRENT `SharedWitness.lean`,
now 4174 lines vs. the ~2600 the prior stop-guard examined). Task 340 Phases 5-7 landed the
per-INDIVIDUAL-slot value-faithful global index the prior blocker said was missing:
- `kvE2_sepSlotHonestGIdx` (SW:2979) — per-slot value-rank index (`kvE2_ordRank` of the lex
  family `kvE2_sepSlotG = (value, slotIndex)`, SW:2945), REPLACING the tied `(3r,3r+1,3r+2)`
  owner-region tuple. Its own docstring (SW:2975-2978, 3059-3062) states it "replaces the tied
  length-3 tuple the 337 stop-guard refuted."
- `kvE2_sepSlotHonestGIdx_mono` (SW:2990) — value-faithful: `value a < value b → GIdx a < GIdx b`.
- `kvE2_sepSlotHonestGIdx_injOn` (SW:3012) — injective on the slot family (no ties).
- `kvE2_sepHonestOrder` (SW:3063) + `kvE2_sepHonestOrder_mem_arr'` (SW:3095) — the honest carrier
  member built on that value-rank payload.
The tie-block obstruction (`halign` unprovable) is therefore DISSOLVED: within any owner-region
the value-rank index is strictly monotone in value. Per the delegation decision rule this is the
"derivable from landed 340 lemmas" case → PROCEED TO BUILD (not blocked). The old blocker text
below is retained for history only.

**BLOCKER (SUPERSEDED — stale, retained for history)** (Phase 1 — interface mismatch, stop-guard fired):
- **What failed**: The destructure of Preconditions (2)+(3) — the assembled boundary-linked
  `regionsL/R` with `hpos/hlink/hnd/hreal`, the alignment fact `halignL/R`, and the endpoint
  boundary alignment `hbdry` — has nothing to bind to. Task 340 landed the carrier member
  (`kvE2_sepHonestOrder_mem_arr'`), per-owner realizer bundles (`kvE2_sepHonestAnchorBundleL/R`),
  tuple-index monotonicity (`kvE2_sepHonest_cross_region`), and the reduction
  `kvE2_sepBody_complete_holds` — but NOT the assembled region decomposition, NOT `halignL/R`,
  NOT `hbdry`. The 340 Phase 5D docstring (SW:2249-2260) itself reassigns the regions assembly
  to "task 337's territory", directly contradicting this plan's Preconditions (2)+(3) which pin
  it as a verified 340 INPUT.
- **What was tried / root cause (grounded in the landed defs, not speculation)**: The landed
  `kvE2_sepSlotGIdx` (SW:1006-1013) reads `kvE2_sepHonestTuple` (SW:2095-2103) `= (3ρ, 3ρ+1, 3ρ+2)`
  — exactly THREE index values per owner (ρ = `kvE2_ordRank`), one per region. `kvE2_sepSlotRank`
  (SW:245-253) gives every `.lXU σ χ` rank 0 and every `.lUW σ χ` rank 2, so ALL of an owner's
  region-0 base slots collapse to the SAME global index `3ρ` (and region-2 to `3ρ+2`).
  `kvE2_sepSlotsLOf wo` (SW:1034) is `mergeSort` by this index, so within any owner-region block of
  ≥2 base types the order is stable-input (enum) order, unrelated to the realizers' M-values. But
  the bracket `.holds` (via `IntervalPattern.holds_eq_succ`, the mpr dual of
  `kvE2_sepDisjunct_extract` SW:2625) needs a STRICTLY MONOTONE `ws` realizing each slot's
  `charBase χ` point type at its mergeSort position, and the engine `k1v_sorted_realizationK`
  (SubBracket2V:633-646) emits `interleaveK ps` with `ps.map fst` a `List.Perm` of the region
  types sorted BY VALUE. Reconciling the value-sorted engine order with the tie-blocked mergeSort
  order is exactly `halignL/R`, and it is UNPROVABLE against the landed per-owner-region index
  whenever an owner-region holds ≥2 base types (the tie-block has no value-faithful order).
- **Why stuck**: The seam object the plan anchored on (a value-faithful PER-SLOT global index) did
  not land; the landed `kvE2_sepSlotGIdx` is PER-OWNER-REGION (3 values/owner, with ties). The
  missing `halignL/R` + assembled regions + `hbdry` cannot be built inside 337 without re-deriving
  the carrier-level value-faithfulness of the global index — the exact re-scope the synthesis
  rejected (report 04 Q2) and this plan's Non-Goals + Rollback bullet 3 + interface-stability note
  forbid.
- **What is needed** (→ resolution, NOT a 337 edit): a task-340 follow-up that either (i) refines
  the honest tuple / `kvE2_sepSlotGIdx` to a genuinely per-INDIVIDUAL-SLOT value-faithful global
  index (distinct index per base type, value-ranked), landing `kvE2_sepSlotsLOf (kvE2_sepHonestOrder …)`
  as a value-sorted chain; or (ii) lands the `halignL/R` + assembled boundary-linked `regionsL/R`
  + `hbdry` bundle directly as consumable INPUTS (Preconditions (2)+(3) verbatim). Either restores
  the acyclic `340 → 337` seam so 337's Phases 2-4 (engine invoke + single-`ptW` bracket match +
  endpoint discharge) become executable as planned.
- **Prohibited**: Do NOT use sorry, `def X := True`, or a vacuous placeholder; do NOT re-derive
  the carrier value-faithfulness inside 337; do NOT edit any 334/336/338/339/340 declaration.

**337 CYCLE 5 PROGRESS (2026-07-09) — halign FOUNDATION LANDED GREEN**: The load-bearing
`halign` fact the superseded blocker claimed unprovable is now proved, axiom-clean
(`{propext, Classical.choice, Quot.sound}`), and committed as three additive lemmas after
`kvE2_sepHonest_rank_strictMono`:
- `kvE2_sepSlotGIdx_honestOrder` — the bridge: on `kvE2_sepHonestOrder`, the mergeSort key reader
  `kvE2_sepSlotGIdx` equals the value-faithful per-slot index `kvE2_sepSlotHonestGIdx` on every
  slot of every positive owner's block. (find? resolved via `List.find?_map` + `List.zipIdx_map_fst`
  + `kvE2_sepPos` nodup; read via `kvE2_sepBlockMap_getD` + `List.idxOf_get`.)
- `kvE2_sepSlotGIdx_honestOrder_mono` — `value a < value b → key a < key b` (bridge + `_mono`).
- `kvE2_sepSlotGIdx_honestOrder_injOn` — key injective on the family (bridge + `_injOn`).
These discharge `halignL/R`'s value-faithfulness core (the mergeSort key IS the value order). The
REMAINING Phase-1 work is the region ASSEMBLY: building boundary-linked `regionsL/R` from the
sorted honest anchors with `hpos/hlink/hnd/hreal` + `hbdry` (helper `kvE2_sepHonest_engineInputs`).

**Goal**: Read the landed 340 Phase 5 signature, destructure the engine-precondition bundle into `wo`, `hmem : wo ∈ kvE2_sepArr' qnf`, and the L/R region decompositions with their four engine hypotheses (`hpos/hlink/hnd/hreal`) + alignment facts (`halignL/R`) + endpoint boundary alignment, and stage them as local `have`s in a private helper. Confirm the destructured `wo`/`hmem` match the ⇐ witness shape of `kvE2_sepBody_holds_iff` (SW:1111-1113). No new proof content — this phase pins the interface.

**Tasks**:
- [x] **Task 1.halign**: prove the halign bridge `kvE2_sepSlotGIdx_honestOrder` + `_mono` + `_injOn` *(deviation: landed — three additive green axiom-clean lemmas, the load-bearing `halign` core; see CYCLE 5 PROGRESS above)*.
- [x] **Task 1.valueSorted** (CYCLE 6, 2026-07-09): prove the value-sortedness the region alignment consumes — `kvE2_sepSlotMergeLe_trans`/`_total`, `kvE2_sepSlotsLOf_mergeSorted`/`ROf_mergeSorted` (merge-key `Pairwise` for ANY `wo` via `List.pairwise_mergeSort`), `kvE2_sepOrderOwners_mem_pos`, `kvE2_sepSlotsLOf_mem_block`/`ROf_mem_block` (each merged slot ∈ a positive owner's block), and `kvE2_sepSlotsLOf_honest_valueSorted`/`ROf_honest_valueSorted` (`Pairwise` value-nondecreasing on the honest order, consuming the halign trio via `Pairwise.imp_of_mem` + `_mono`). All additive, green, axiom-clean `{propext, Classical.choice, Quot.sound}`. *(This is the "consume the halign trio for value-sortedness; do NOT re-derive" directive, landed.)*
- [ ] **Task 1.regionAssembly** (REMAINING — the crux of P1): `kvE2_sepHonest_engineInputs` building boundary-linked `regionsL/R : List (carrier × carrier × List (NF 0 1))` with `hpos/hlink/hnd/hreal/hbdry`. STRUCTURE RESOLVED this cycle: region boundaries = the value-sorted LEFT-interior anchors `a_1<…<a_k` (regionsL `= [(x,a_1,S_0),…,(a_k,w,S_k)]`, so `interleaveK` emits `a_1..a_k` as the shared internal boundaries and `w` is the final un-emitted hi — matching the bracket's `lL ++ ptW :: lR` layout with the anchors as type-carrying interior points and `w` as `ptW`). The genuine remaining work is the **value-based partition** of the base types into the anchor gaps: each `zXU/zUW` (resp. `zWX1/zWT`) base type χ has a realized witness value `kvE2_sepSlotValue`, and it must be placed in the gap `(a_i,a_{i+1})` its value falls in (NOT statically by owner — a `zUW` type of owner i is realized in `(a_i,w)`, spanning several gaps). `hreal` then holds by the partition definition; `hlink`/`hpos` from strict anchor sortedness (`kvE2_sepHonest_rank_strictMono` + `kvE2_sepAnchorFam_injective`); `hnd` from `kvE2_sepS_nodup` restricted to each gap sublist. This is a substantial standalone construction (~150-300 lines) and must be sized as its own dispatch — do NOT rush it into a RED state.
- [ ] Grep + `lean_hover_info`: the landed 340-P5 deliverable (`kvE2_sepBody_complete_holds` and/or its engine-input helper); `kvE2_sepBody_holds_iff` conclusion shape (SW:1104-1122, RHS 1111-1113); `kvE2_sepSlotsLOf/ROf` (SW:949-957); `kvE2_sepSlotGIdx` (SW:921-928); `k1v_sorted_realizationK` (SubBracket2V.lean:633-646); the preserved v3 asset `kvE2_sepCoincidentOrder_mem_arr'` (confirm still green, untouched).
- [ ] Destructure the bundle: `obtain ⟨wo, hmem, regionsL, hposL, hlinkL, hndL, hrealL, halignL, regionsR, hposR, hlinkR, hndR, hrealR, halignR, hbdry⟩ := <340-P5 bundle>` (adapt to the landed shape).
- [ ] If the landed 340-P5 shape is weaker than Preconditions (2)+(3), STOP and surface an interface mismatch (do NOT re-derive the engine hypotheses here).
- [ ] Verify each `have` with `lean_goal`; keep sorry-free.

**Timing**: 0.5 hours

**Depends on**: 340 Phase 5 (external)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/SharedWitness.lean` — add a private consume/stage helper (suggested `kvE2_sepHonest_engineInputs`), additive.

**Verification**:
- Helper compiles sorry-free; `lean_verify` no `sorryAx`.
- `wo`/`hmem` match `kvE2_sepBody_holds_iff`'s RHS witness shape over `kvE2_sepSlotsLOf/ROf wo`.
- Green `lake build`.

---

### Phase 2: Invoke `k1v_sorted_realizationK` → global monotone bracket witness `ws` (step b) [NOT STARTED]

**Goal**: Apply `k1v_sorted_realizationK` to `regionsL` and `regionsR` (Phase-1 bundle), obtain `psL/psR` + `(interleaveK psS).Pairwise (· < ·)`, define the bracket witness `ws : Fin (N+1) → M.carrier` re-indexed into the `kvE2_sepSlotsLOf wo ++ ptW :: kvE2_sepSlotsROf wo` slot order (pivot `ptW = w` at index `|kvE2_sepSlotsLOf wo|`), and prove strict monotonicity `∀ i j, i < j → ws i < ws j` + range `∀ i, x < ws i ∧ ws i < t`. Deliver as a sorry-free private helper (suggested `kvE2_sepHonest_witnesses`).

**Tasks**:
- [ ] `obtain ⟨psL, hfL, hsortedL⟩ := k1v_sorted_realizationK M regionsL hposL hlinkL hndL hrealL` (mirror for R).
- [ ] Stitch the L chain, `ptW = w`, and the R chain into `ws` via the `halignL/R` alignment facts + `hbdry` (leftmost `x`, mid `w`, rightmost `t`); pivot at `|kvE2_sepSlotsLOf wo|`.
- [ ] Prove strict monotonicity from `hsortedL`/`hsortedR` (`interleaveK` pairwise, SubBracket2V.lean:646) + `hbdry` (L block < `w` < R block).
- [ ] Prove range `x < ws i < t` from region positivity/link (leftmost lo `x`, rightmost hi `t`).
- [ ] Verify each step with `lean_goal`; keep sorry-free.

**Timing**: 1 hour

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/SharedWitness.lean` — add `kvE2_sepHonest_witnesses` (private helper).

**Verification**:
- Helper compiles sorry-free; `lean_verify` no `sorryAx`.
- `ws` indexing agrees with `kvE2_sepDisjunct`'s `lL ++ ptW :: lR` layout for `lL = kvE2_sepSlotsLOf wo`, `lR = kvE2_sepSlotsROf wo` (pivot at `|kvE2_sepSlotsLOf wo|`).
- No `x1 < e_i` literal introduced (LITMUS NS:437); bounds from region endpoints only.
- Green `lake build`.

---

### Phase 3: Bracket point-type + segment match → `(kvE2_sepDisjunct … (kvE2_sepSlotsLOf wo) (kvE2_sepSlotsROf wo)).2.holds` (step c) [NOT STARTED]

**Goal** (**HIGHEST-RISK PHASE — the ONLY bracket-entangled step; sized alone per H8**): From the Phase-2 witness `ws`, prove every point-type realization and the `kvE2_sepSegs` segment families, then close `(kvE2_sepDisjunct charBase charK qnf (kvE2_sepSlotsLOf wo) (kvE2_sepSlotsROf wo)).2.holds M atomMap x t` via `IntervalPattern.holds_eq_succ.mpr` (ExistsForallNF.lean:188) / `kvE_subBracket2V_sound_of_parts` (SubBracket2V.lean:1025). Deliver as a sorry-free private helper (suggested `kvE2_sepHonest_bracket_holds`).

**`kvE2_sepBracketN` IntervalPattern structure (SW:602-608, report 04 Q1):** `pointTypes = lL ++ ptW :: lR` — a SINGLE interior distinguished slot `ptW` (= the shared `w`), NOT per-owner separators. `IntervalPattern.holds_eq_succ.mpr` requires ONE `witnesses : Fin (N+1) → M.carrier` that is (1) strictly monotone in block slot-index order AND (2) realizes each slot's point type at its block index, PLUS the three `beta` segment families along the open gaps. The landed k=3 template `SubBracket2V.lean:807-819` (`witnesses = usXU ++ x1 :: usUW ++ w :: usWT`, monotone → `.holds`) is the structural guide: `interleaveK`'s multi-separator output must be sliced to this single-`ptW` layout. The value-order alignment (`halignL/R`) is what makes the slice well-defined — the `x1_σ` anchors sit as type-carrying interior points inside `lL`/`lR` (report 04 Q5 caveat), `w` alone is `ptW`.

**Tasks**:
- [ ] `rw [IntervalPattern.holds_eq_succ …]` and `refine ⟨ws, ?_, ?_, ?_, ?_, ?_, ?_⟩` to expose the six mpr obligations (mono, range, point types, the three `beta` segment families) — dual to the extractor's `obtain ⟨ws, hmono, hrange, hpt, -, -, -⟩`.
- [ ] Mono + range: discharge from the Phase-2 helper directly.
- [ ] Point types: for each slot index `i` into `kvE2_sepSlotsLOf wo ++ ptW :: kvE2_sepSlotsROf wo`, evaluate the slot's point type at `ws i` — left/right slots from the engine's per-region realizers (`hrealL/R` threaded through `psL/psR`'s `hf` `Forall₂`), pivot `ptW` from the shared `w`; positions read via the value-order alignment `halignL/R`.
- [ ] Segments: for each inter-witness gap + the two boundary gaps, realize the refined-conjunction `beta` segment type from the region-interior realizers threaded through the engine's `ps` per-region guarantees.
- [ ] Verify each `have` with `lean_goal`; keep sorry-free. **If nearing an agent-run boundary, commit the point-type portion as a standalone green lemma and continue segments as a follow-on green sub-step — never a `sorry`.**

**Timing**: 1.5 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/SharedWitness.lean` — add `kvE2_sepHonest_bracket_holds` (private helper).

**Verification**:
- Helper compiles sorry-free; `lean_verify` no `sorryAx`.
- Segment/point bounds come from region endpoints + engine guarantees (`hreal`/`hf`), not owner-to-owner chains (LITMUS NS:437); F5 closed/open keys unconflated (coincident tags read only the CLOSED self-zone bits).
- Green `lake build`.

---

### Phase 4: Endpoint discharge + assemble builder + body corollary (step d) [NOT STARTED]

**Goal**: Discharge the endpoint conjuncts `kvE2_sepEpL`@x and `kvE2_sepEpR`@t from the honest evaluation `h`, assemble the three-part disjunct `.holds`, and state + prove the builder `kvE2_sepDisjunct_holds_of_honest` (the ⇐ witness of `kvE2_sepBody_holds_iff`) plus the corollary `kvE2_sepBody_holds_of_honest`, sorry-free.

**Tasks**:
- [ ] Prove `(kvE2_sepEpL charBase charK qnf).eval_at M atomMap x` and `(kvE2_sepEpR charBase charK qnf).eval_at M atomMap t` from the atom-layer of `h` over `[w,x,t]` (the same data the extractor destructures as `hepL`/`hepR`; add a small private `have` if no direct helper exists).
- [ ] State `kvE2_sepDisjunct_holds_of_honest` (signature mirroring `kvE2_sepGate_holds_of_honest` + `kvE2_sepBody_complete` — `charBase`, `charK`, `qnf`, `M`, `atomMap`, `w x t`, `hxw`, `hwt`, `hLR`, `h`, and the 340-P5 bundle) concluding `∃ wo ∈ kvE2_sepArr' qnf, (kvE2_sepDisjunct charBase charK qnf (kvE2_sepSlotsLOf wo) (kvE2_sepSlotsROf wo)).2.holds M atomMap x t`.
- [ ] `refine ⟨wo, hmem, hepL, hepR, ?_⟩` (from Phase 1); close the bracket via the Phase-3 helper.
- [ ] Add the corollary `kvE2_sepBody_holds_of_honest`: `(kvE2_sepBody charBase charK qnf).holds M atomMap x t`, via `(kvE2_sepBody_holds_iff …).mpr` applied to `kvE2_sepDisjunct_holds_of_honest`.
- [ ] Verify each `have` with `lean_goal`; keep sorry-free.

**Timing**: 0.75 hours

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/SharedWitness.lean` — add the builder `kvE2_sepDisjunct_holds_of_honest` + corollary `kvE2_sepBody_holds_of_honest`.

**Verification**:
- Both compile sorry-free; `lean_verify` no `sorryAx` (full audit in Phase 5).
- Builder conclusion is the ⇐ witness shape of `kvE2_sepBody_holds_iff` (SW:1111-1113), over `kvE2_sepSlotsLOf/ROf wo`.
- Corollary discharges `kvE2_sepBody.holds` — the object task 335 consumes.
- Green `lake build`.

---

### Phase 5: Axiom-cleanliness gate + F1–F7 faithfulness audit + full build [NOT STARTED]

**Goal**: Run the explicit axiom-cleanliness gate, audit F1–F7 preservation, confirm every task-334/336/338/339/340 INPUT (and the preserved v3 asset `kvE2_sepCoincidentOrder_mem_arr'`) is byte-for-byte untouched, and pass a full project build.

**Tasks**:
- [ ] `lean_verify` on `kvE2_sepDisjunct_holds_of_honest`, `kvE2_sepBody_holds_of_honest`, and each Phase-1..3 helper; confirm each returns `{propext, Classical.choice, Quot.sound}` with **no `sorryAx`**.
- [ ] Grep the diff for `sorry`/`admit`/new `axiom`/vacuous `:= True` — must be NONE.
- [ ] F1–F7 checklist: F1 (region types stay QF); F2 (non-vacuous — realizers from the engine/bundle, not placeholders); F3/F4 (witnesses region-interior, no new anchors, no `x1 < e_i` literal); F5 (no open/closed zone-key conflation — coincident tags read only the CLOSED `zAtX1L`/`zAtX1R` bits); LITMUS NavigatedSpine:437 (all witness/segment bounds from the bracket range `x`/`w`/`t` and engine interior guarantees, never a chain).
- [ ] `git diff` gate: confirm the change is EXCLUSIVELY the Phase-1..4 additive helpers + builder + corollary; every existing declaration (all 334/336/338/339/340 INPUT defs/lemmas — `kvE2_sepBody`, `kvE2_sepBody_holds_iff`, `kvE2_sepBody_extract`, `kvE2_sepArr'`, `kvE2_sepSlotsLOf/ROf`, `kvE2_sepSlotGIdx`, `kvE2_sepSlotMergeLe`, `kvE2_sepDisjunct_extract`, `kvE2_sepHonestBundleL/R`, `kvE2_sepCoincidentOrder_mem_arr'`, the 340-P5 bundle lemma) is UNMODIFIED.
- [ ] Full `lake build` green.

**Timing**: 0.5 hours

**Depends on**: 4

**Files to modify**:
- None (verification-only; fixups surfaced by the audit excepted, and only to the new additive declarations).

**Verification**:
- `lean_verify` on all delivered declarations axiom-clean, no `sorryAx`.
- Full `lake build` succeeds.
- F1–F7 checklist passes; every INPUT declaration untouched (`git diff` = additive-only).

---

## Testing & Validation

- [ ] `lake build` of the `NfMultiAnchorBridge/` target (and full project in Phase 5) succeeds; each phase ends green.
- [ ] `lean_verify` on `kvE2_sepDisjunct_holds_of_honest`, `kvE2_sepBody_holds_of_honest`, and every auxiliary helper returns `{propext, Classical.choice, Quot.sound}` with no `sorryAx`.
- [ ] No bare `sorry`/`admit`, no new `axiom`, no vacuous definition anywhere in the diff.
- [ ] The change is ADDITIVE: every 334/336/338/339/340 INPUT def/lemma (and the preserved `kvE2_sepCoincidentOrder_mem_arr'`) is byte-for-byte unmodified (`git diff` shows only new declarations).
- [ ] The builder's conclusion is the ⇐ witness shape of `kvE2_sepBody_holds_iff` (SW:1111-1113) over `kvE2_sepSlotsLOf/ROf wo`; the corollary discharges `kvE2_sepBody.holds`.
- [ ] The 340-P5 engine-precondition bundle was CONSUMED, not re-derived (no re-proof of `hpos/hlink/hnd/hreal` or of the global index's value-faithfulness inside 337).
- [ ] No `List.mem_permutations` at the `.holds` level (Option B forbidden).
- [ ] F1–F7 faithfulness checklist passes (F5 closed/open discrimination; LITMUS NS:437 no `x1 < e_i` literal; witness/segment bounds from the bracket range and engine guarantees).
- [ ] No task merge with 340; no circular dependency introduced.

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/SharedWitness.lean` — additive only: `kvE2_sepHonest_engineInputs` (Phase 1), `kvE2_sepHonest_witnesses` (Phase 2), `kvE2_sepHonest_bracket_holds` (Phase 3), the builder `kvE2_sepDisjunct_holds_of_honest` + corollary `kvE2_sepBody_holds_of_honest` (Phase 4). NO existing declaration edited; the preserved v3 asset `kvE2_sepCoincidentOrder_mem_arr'` stays untouched.
- `specs/337_.../plans/04_joint-disjunct-holds-codesign.md` (this file).
- `specs/337_.../summaries/04_joint-disjunct-holds-codesign-summary.md` (on completion).
- **Downstream**: task 335 re-dispatches Phases 2–4 to consume `kvE2_sepBody_holds_of_honest` (and the underlying `kvE2_sepDisjunct_holds_of_honest`) via the already-landed `kvE2_sepBody_holds_iff`.

## Rollback/Contingency

- ALL phases are additive to `SharedWitness.lean`. To revert any phase: delete the new declaration(s); the file returns to its post-340 green state with every INPUT (and the v3 asset) untouched. There is no carrier edit to roll back.
- If Phase 3 (bracket match) cannot close within one agent run: commit the point-type helper as a standalone sorry-free lemma (green checkpoint), then continue the segment matcher as a follow-on green sub-step. Never commit a bare `sorry`, a vacuous placeholder, or a `.holds` modulo an assumed segment obligation.
- If the landed 340-P5 bundle is weaker than the Preconditions engine-precondition bundle (delivers only `∃ wo, monotone`, or omits the `hlink`/`hreal` region decomposition): STOP at Phase 1 and surface an interface mismatch to the orchestrator — do NOT re-derive the engine hypotheses inside 337 (that is the re-scope the synthesis rejected, report 04 Q2). This is a 340-P5 gap, resolved by strengthening 340's deliverable, not by folding it into 337.
- If any step appears to require editing a 334/336/338/339/340 INPUT def/lemma (rather than adding a new helper), STOP and surface it as a scope question rather than weakening a verified INPUT. This task is ADDITIVE by construction — such a need signals a design error or a 340-P5 interface gap, not an authorized edit.
