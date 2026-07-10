# Implementation Plan v6: Task #337 — Grouped Multi-Owner Disjunct `.holds` Builder (carrier-fix revision)

- **Task**: 337 - Build the joint multi-owner disjunct bracket-`holds` engine for `kvE2_sepDisjunct'`, delivering the ⇐-direction builder `kvE2_sepDisjunct'_holds_of_honest` and its body corollary `kvE2_sepBody_holds_of_honest`
- **Status**: [NOT STARTED]
- **Effort**: 10 hours (Phase 1, 1h, already COMPLETED)
- **Dependencies**: 342 (COMPLETED, axiom-clean — grouped tie-admitting carrier, `hLR` deletion, `kvE2_sepBody_complete_holds'`, Phase-8 honesty pack); 334/336/338/339/340 (COMPLETED — landed carrier/value chain, including the `.rXW` carrier this revision amends); 324 (COMPLETED — `SubBracket2.lean` zone extraction). Task 337 is NOT blocked.
- **Research Inputs**:
  - specs/337_build_joint_multiowner_disjunct_bracketholds_engine_for_kve2_sepdisjunct/reports/08_post-342-revision-strategy.md (authoritative target + landed-asset inventory; carried forward from plan 12)
  - specs/337_build_joint_multiowner_disjunct_bracketholds_engine_for_kve2_sepdisjunct/reports/13_rxw-faithfulness-audit.md (NEW — the faithfulness audit that authorizes the `.rXW` carrier edit; orchestrator-verified as GROUND TRUTH)
- **Artifacts**: plans/13_grouped-disjunct-holds-builder-carrier-fix.md (this file); supersedes plans/12_grouped-disjunct-holds-builder.md
- **Standards**: plan-format.md; status-markers.md; artifact-management.md; tasks.md; lean4.md (literature-fidelity-policy.md)
- **Type**: lean4
- **Lean Intent**: false

## Overview

This is **plan version 6** for task 337 (the filename prefix `13` is the task's unified artifact
sequence number, matching report `13`). It is a **revision of plan 12** (version 5), authored to
resolve the hard blocker that halted plan 12's Phase 2 (O1). Plan 12's Phase 1 is DONE, green, and
axiom-clean (committed `df9b9988e`, `b4d414c2c`); this plan carries it forward UNCHANGED and inserts
a new, bounded, explicitly-authorized carrier-fix phase ahead of O1.

### What happened (the blocker)

Plan 12 Phase 2 (obligation O1) is BLOCKED. The grouped LEFT bracket
(`kvE2_sepBracketN_construct`, SW:5357, `hsort`) requires `(usL ++ w :: usR).Pairwise (· < ·)`, i.e.
every LEFT per-class witness value strictly `< w` (`usL`-last `< w`). A right-interior (`zWT3`) owner
contributes a `.rXW` slot to the LEFT list; the landed `kvE2_sepSlotValue` `.rXW` branch
(SharedWitness.lean:3540-3541, hereafter SW:) picks its value by `Classical.epsilon` over the WEAK
predicate `x < v ∧ v < kvE2_sepAnchorVal … σ ∧ realizes χ`. For a right-interior owner
`kvE2_sepAnchorVal … σ ∈ (w,t)`, so with no `v < w` conjunct the epsilon may land in `[w, x1)` and
`usL`-last `< w` is unprovable. Plan 12 pre-flagged this at line 140 but **mis-mitigated** it: it
claimed O1 rides `kvE2_sepSlotsLOf_honestOrder'_valueSorted` "NOT zone bounds." Value-sortedness
orders the left values mutually; it does NOT prove the largest left value is `< w`. That mitigation
is unsound and is NOT repeated here.

### The audit verdict (report 13 — orchestrator-verified GROUND TRUTH)

- **Verdict (a): TRANSCRIPTION OMISSION, isolated to the `.rXW` branch.** Its epsilon predicate
  (SW:3534-3535 vs :3540-3541) is byte-identical to the `.lXU` branch — a copy-paste that carried the
  left-interior upper bound `anchorVal (= x1)` into a branch where the pivot `w` is required
  (`w < x1` for right-interior owners).
- **The `v < w` bound IS in the model data.** Zone `kvE_sub2_zXU` (SubBracket2.lean:123-124) sets
  coordinate 1 (the `w` coordinate) to `(true,false)` = `v < w`. The extraction lemma
  `kvE_sub2_zoneHolds_zXU` (SubBracket2.lean:565-572) DISCARDS it, destructuring `⟨hp0, _, hp2, _⟩`
  and returning only `x < v ∧ v < x1`. Restoring it is faithfulness RESTORATION, not a convenience
  patch. Paper basis: Def 3.1 ordering channel (PDF p.4) and the below-pivot half of Figure 1's
  `[…](z0, z)` (PDF p.9).
- **Verdict (b) RULED OUT.** The slot assignment `kvE2_sepSlotsLFor` (SW:331-338) is FAITHFUL —
  routing a right-interior owner's `(x,w)` witness into the LEFT list is Rabinovich's below-pivot
  bracket (Figure 1, PDF p.9). DO NOT touch `kvE2_sepSlotsLOf`.
- **Verdict (c) RULED OUT.** O1's strict `<` is FAITHFUL (Lemma 5.3 strict chain; task 342's
  tie-grouping already merges genuine coincidences). DO NOT weaken O1.
- **Not systematic.** The other four base branches (`.lUW`, `.lWT`, `.rWX1`, `.rX1T`) match their
  zone bits. One-branch patch.
- **LITMUS clean.** `v < w` is an env-anchored literal already present in the sibling `.lUW`
  predicate, NOT an `x1 < e_i` relative-position literal (NavigatedSpine:437). F1–F5 preserved.

### The authorized change (the one thing this revision grants)

Plan 12's strictly-additive constraint (plan 12 lines ~119, ~126; Non-Goal "Do NOT edit any existing
declaration") is hereby **AMENDED**. This plan authorizes a **bounded, 3-site, non-additive carrier
edit and NOTHING WIDER**:

1. `kvE_sub2_zoneHolds_zXU` (SubBracket2.lean:565) — strengthen its conclusion to
   `x < v ∧ v < w ∧ v < x1` (stop discarding `hp1`, the coord-1 component of
   `kvE_sub2_zoneHolds_cons_iff`, SubBracket2.lean:543-544). Provable sorry-free from the zone spec.
2. `kvE2_sepSlotValue_rXW_spec` (SharedWitness.lean:3642) — strengthen its conclusion
   correspondingly to `x < v ∧ v < w ∧ nf_eval_nf … χ` (`v < anchorVal` remains DERIVABLE as
   `v < w < x1`, so consumers wanting it are unaffected).
3. `kvE2_sepSlotValue` `.rXW` branch (SharedWitness.lean:3540-3541) — change the epsilon upper bound
   from `kvE2_sepAnchorVal … σ` to `w`. This is the single non-additive line of substance.

**Everything else in this task stays additive.** All other prohibitions from plan 12 remain binding
(see Non-Goals).

### The exact target (report 08 §2.1 — reproduce verbatim; UNCHANGED from plan 12)

```
theorem kvE2_sepDisjunct'_holds_of_honest {sig : MonadicSignature}
    (charBase : NormalForm sig 0 1 → Formula) (charK : NormalForm sig 1 1 → Formula)
    (qnf : NormalForm sig 2 3)
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (w x t : M.carrier) (hxw : x < w) (hwt : w < t)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    (hcb : ∀ (χ : NormalForm sig 0 1) (u : M.carrier),
      temporal_truth M atomMap u (charBase χ) ↔ nf_eval_nf M 0 1 (fun _ => u) χ)
    (hck : ∀ (χ : NormalForm sig 1 1) (u : M.carrier),
      temporal_truth M atomMap u (charK χ) ↔ nf_eval_nf M 1 1 (fun _ => u) χ) :
    (kvE2_sepDisjunct' charBase charK qnf
        (kvE2_sepTieGroupedL (kvE2_sepHonestOrder' qnf M w x t h))
        (kvE2_sepTieGroupedR (kvE2_sepHonestOrder' qnf M w x t h))).2.holds M atomMap x t
```

The `hcb`/`hck` hypotheses are copied verbatim from the Phase-8 pack (SW:7669-7672). `.2.holds`
decomposes as the triple ⟨`kvE2_sepEpL` eval at `x`, `kvE2_sepEpR` eval at `t`, bracket `.holds`⟩
exactly as `kvE2_sepDisjunct_extract` destructures it (`obtain ⟨hepL, hepR, hbr⟩`, SW:6207).

### Research Integration

Newly integrated report (this revision): **`reports/13_rxw-faithfulness-audit.md`**.

- §Bottom line / Q1–Q5: verdict (a) TRANSCRIPTION OMISSION isolated to `.rXW`; verdicts (b) and (c)
  ruled out. This authorizes the Phase 2 carrier edit below and forbids touching `kvE2_sepSlotsLOf`
  or weakening O1.
- §Q2: the exact model-data trace — `kvE_sub2_zXU` coord-1 = `v < w`, discarded at
  `kvE_sub2_zoneHolds_zXU` (SubBracket2.lean:565-572, `hp1` dropped). The fix restores `hp1`.
- §Q5 minimal edit: the exact 3 sites and their landed-asset provenance (all 340/324-chain, none
  belong to 342).
- §F1-F7 / LITMUS: the new `v < w` conjunct is env-anchored, LITMUS-clean; F1–F5 preserved.
- §Evidence index: the file:line map used to scope the blast radius below.

Carried forward from plan 12 (integrated report `08_post-342-revision-strategy.md`, unchanged):

- §2.1 exact target theorem statement (reproduced above).
- §2.2 verified lemma inventory (all names confirmed present at cited SW: lines).
- §2.3 value-direct per-class witness route and the O1–O4 obligation split.
- §Risks (cross-region slot values, O3 sizing, stale-line-number discipline, citation drift).

### Blast radius (orchestrator-verified — each site MUST be re-checked)

The three edit sites are LANDED assets of COMPLETED tasks 340/342/324. Their consumers:

- `kvE_sub2_zoneHolds_zXU` (SubBracket2.lean:565) has **exactly ONE consumer**: SubBracket2.lean:631
  (the `complete_extract` zXU field, per report 13 §evidence :619-620). Strengthening its conclusion
  (adding the `v < w` conjunct) changes its result shape — that one consumer MUST be re-checked and,
  if it destructures the tuple, updated to accept the extra conjunct.
- `kvE2_sepSlotValue_rXW_spec` (SharedWitness.lean:3642) has **exactly TWO consumers**:
  SharedWitness.lean:4654 and :5943, both projecting `.2.2` (the `realizes χ` conjunct). A
  strengthened predicate (`x < v ∧ v < w ∧ realizes χ`) preserves the `.2.2` projection target, so
  both are expected to remain valid — but both MUST be re-checked, since inserting `v < w` before
  the realizes-conjunct shifts the `.2` structure (`.2.2` now reads through `v < w`).
- The `.rXW` branch of `kvE2_sepSlotValue` (SharedWitness.lean:3540-3541) is the carrier itself; its
  `Classical.epsilon` value is pinned by `kvE2_sepSlotHonestVIdx_eq_iff` (SW:5857) and consumed via
  `kvE2_sepSlotValue_baseType_spec` (SW:5943).

**STOP condition (task 342 regression).** The plan MUST re-verify that task 342's theorems — in
particular `kvE2_sepBody_complete_holds'` (SW:6158) and `kvE2_sepBody_complete` — remain GREEN and
axiom-clean (`{propext, Classical.choice, Quot.sound}`, no `sorryAx`) after the carrier change. Any
regression there is a **STOP condition**, surfaced to the orchestrator — NOT something to patch
around.

### Sorry accounting

SharedWitness.lean currently contains **7 `sorry` string occurrences, ALL inside prose comments —
zero real sorries**. That count MUST NOT rise. Every phase ends with a `grep -c` re-count and a
`lean_verify` no-`sorryAx` check.

### Prior plan reference

Plan 12 is SUPERSEDED by this file. Its Phase 1 landed assets are reusable INPUTs and must NOT be
re-derived (see Goals). Plan 12's flat-cut inventory (from plan 04) also remains: `kvE2_sepHonest_engineInputs`
(:4803), `kvE2_sepHonest_witnesses` (:4992, fallback only), the private `kvE2_sepBracketN_construct`
(:5357). Plan 12's line 140 mitigation ("value-sortedness gives `usL`-last `< w`") is
RETRACTED as unsound; O1 (Phase 3) now gets `usL`-last `< w` per-slot from the strengthened `.rXW`
spec plus the `.lXU`/`.lUW` specs.

### Roadmap Alignment

No ROADMAP.md consulted (roadmap flag not set). Advances the Kamp-theorem completeness arm by
landing the faithful grouped joint-bracket `.holds` builder on 342's tie-admitting carrier, after
restoring the `.rXW` below-pivot faithfulness bound, unblocking the ⇐ direction of parent task 335.

## Goals & Non-Goals

**Goals**:
- **(NEW)** Land the authorized 3-site `.rXW` carrier fix (Phase 2) so every `.rXW` slot value is
  provably `< w`, restoring `usL`-last `< w`, sorry-free and axiom-clean, with all three blast-radius
  consumers re-checked and the task-342 STOP-condition theorems re-verified green.
- Carry forward the COMPLETED Phase 1 foundation UNCHANGED: reuse (never re-derive)
  `kvE2_sepSlotGIdx_honestOrder'` (+ `_mono`), `kvE2_sepSlotsLOf_honestOrder'_valueSorted` /
  `...ROf...`, `kvE2_sepTieRuns_key_const`, `kvE2_sepTieGroupedL_value_const` / `...R...`.
- Discharge the four open obligations O1 (class witness order & range — now unblocked by Phase 2),
  O2 (class point types), O3 (honest segment evaluation — split across two phases), O4 (assembly
  arithmetic + endpoints + the two public theorems).
- Feed the obligations into the private `kvE2_sepBracketN_construct` (:5357).
- Deliver `kvE2_sepDisjunct'_holds_of_honest` (exact §2.1 statement) and the corollary
  `kvE2_sepBody_holds_of_honest`, both sorry-free and axiom-clean.

**Non-Goals** (all binding; the additive constraint is AMENDED only for the 3 sites named in Phase 2):
- Do NOT widen the carrier edit beyond the exact 3 sites of Phase 2. Any need to edit a FOURTH
  landed declaration is a STOP condition, surfaced to the orchestrator — not an authorized edit.
- Do NOT touch `kvE2_sepSlotsLOf` / `kvE2_sepSlotsLFor` (verdict (b) ruled out — the slot assignment
  is faithful).
- Do NOT weaken O1's strict `Pairwise (· < ·)` or make it pivot-crossing (verdict (c) ruled out).
- Do NOT re-derive or delete any LANDED asset carried forward: Phase 1's substrate (above),
  `kvE2_sepHonest_engineInputs` (:4803), `kvE2_sepHonest_witnesses` (:4992),
  `kvE2_sepBracketN_construct` (:5357), the Phase-8 honesty pack `kvE2_sepEpL/PtW/EpR_eval_of_honest`
  (:7663/:7724/:7789), `kvE2_sepProjFresh_eval` (:6992).
- Do NOT assume `hLR` (deleted; `kvE2_sepHonest_hLR_absurd` :5730 certifies it unsatisfiable). Exactly
  one `(hLR :` binder remains file-wide, inside that guard.
- Do NOT close any phase via `(kvE2_sepHonest_hLR_absurd …).elim`, `False.elim`, or any vacuous
  route. **A vacuous close is a FAILURE, not a completion.** No bare `sorry`/`admit`, no new `axiom`,
  no `def X := True` placeholder, no `.holds` modulo an assumed hypothesis.
- Do NOT use the banked engine route (`kvE2_sepHonest_witnesses`) as the primary; documented fallback
  only (its flat per-slot multiset differs from the per-class values, and it filters `≥ w` pairs
  rather than proving `< w`).
- Do NOT touch `OuterGate.lean` or `KampPrior.lean` (task 335's consumption is a separate dispatch).

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| **Carrier edit (Phase 2) regresses a task-342 theorem** (`kvE2_sepBody_complete_holds'` :6158, `kvE2_sepBody_complete`) | H | M | Phase 2 re-verifies BOTH named theorems green + axiom-clean AFTER the edit. Any regression is a STOP condition surfaced to the orchestrator, NOT patched around. The strengthened predicate only ADDS a conjunct; consumers project `.2.2` (realizes χ), preserved. |
| **A blast-radius consumer breaks on the new conjunct** (SubBracket2.lean:631; SharedWitness.lean:4654, :5943) | M | M | Phase 2 re-checks each of the 3 consumers individually via `lean_hover_info`/`lean_goal`; `:631` (tuple destructure) is updated to accept the extra `v < w` conjunct; `:4654`/`:5943` re-read their `.2.2` projection through the shifted structure. |
| **Scope creep beyond the 3 authorized sites** | H | L | The additive constraint is amended for EXACTLY 3 named sites. Any fourth landed-declaration edit STOPs. `git diff` after Phase 2 shows only SubBracket2.lean (`zXU` extraction + its one consumer) and SharedWitness.lean (`.rXW` branch + `_rXW_spec` + its two consumers) touched. |
| **O3 (honest segment evaluation) exceeds one dispatch** — no banked completeness-direction segment-eval lemma exists | H | H | Split O3 into Phase 5 (segment-eval family as STANDALONE green lemmas, generic in interior point `y`, reading owners' universal β-layer via `kvE2_sepSegForm` :184 + `hcb`) and Phase 6 (gap discharge). Land Phase 5's family green before Phase 6; never a `sorry` or vacuous placeholder. |
| **Baseline caps shift because Phase 2 is non-additive** | M | M | Re-measure caps (`grep -c 'kvE_sub2_'`, `grep -c 'x1 <'`) IMMEDIATELY after Phase 2 lands green; the re-measured values become the reference for Phase 7's gate. The gate's real purpose (no NEW `x1 < e_i` relative-position literal, LITMUS NS:437) is unchanged; report 13 confirms the fix introduces only the env-anchored `v < w` literal. |
| **Grouped-cut / flat-cut reindexing arithmetic in `kvE2_sepSegsG`** misaligns | M | M | Isolate length/reindex lemmas in Phase 7 (O4) as separate `have`s; verify each pivot/offset via `lean_hover_info` on `kvE2_sepTieGroupedL_flatten` :2064 and `kvE2_sepSegsG` before assembly. |
| **Stale line numbers** (file grows/shifts as phases land, and Phase 2 shifts lines below :3540) | M | H | EVERY phase opens with a `grep -n` re-confirmation of the declarations it consumes. After Phase 2 all SW: line numbers below :3540 shift — treat all cited lines as approximate and re-grep. |
| **Faithfulness regression** (`x1 < e_i` literal, F5 open/closed key conflation) | H | L | All witness/segment bounds from the bracket range `x`/`w`/`t` and per-slot value specs, never an owner chain (LITMUS NS:437); CLOSED-key reads for tie discharges (F5); Phase 7 runs the explicit gate. Phase 2's new conjunct is env-anchored `v < w` (report 13 §F1-F7), LITMUS-clean. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 (COMPLETED) | -- |
| 2 | 2 | 1 |
| 3 | 3, 4, 5 | 2 |
| 4 | 6 | 3, 5 |
| 5 | 7 | 4, 6 |

Phase 2 (the carrier fix) is a serialization point: O1 (Phase 3) cannot close until every `.rXW`
value is provably `< w`, and O2 (Phase 4) consumes `kvE2_sepSlotValue_rXW_spec` via
`baseType_spec` (SW:5943), so both must run AFTER the carrier fix. Wave-3 parallelism (Phases 3, 4,
5) is inherited from plan 12: O1 needs the class values + monotonicity + the strengthened pivot
bound; O2 needs the class values + point-type specs; the Phase-5 segment-eval family is stated
STANDALONE (generic in an interior point `y`), so none consumes another's output.

Every phase: (i) opens with a `grep -n` re-confirmation of the declarations it consumes (the file
grows and Phase 2 shifts lines below :3540); (ii) ends at a green, sorry-tracked `lake build` with a
`lean_verify` axiom check on each new/edited declaration and a `grep -c 'sorry'` re-count (must stay
== 7, all in prose comments); (iii) commits at every green milestone.

### Phase 1: Foundation — reconfirm consumed declarations + per-class witness value substrate [COMPLETED]

*(CARRIED FORWARD UNCHANGED from plan 12. Committed `df9b9988e`, `b4d414c2c`; green + axiom-clean.
Deviation as recorded in plan 12: the per-class witness value function `usL/usR` is realized inline
at final assembly as `gL.map (class-head value)`; the load-bearing Phase-1 deliverable is the
primed-order value substrate.)*

- **Goal:** Establish the shared substrate all of O1/O2/O3 consume: the landed declarations
  reconfirmed at their lines, and the primed-order value substrate.
- **Landed assets (reusable INPUTs — do NOT re-derive):** `kvE2_sepSlotGIdx_honestOrder'` (bridge)
  and `_mono`; `kvE2_sepSlotsLOf_honestOrder'_valueSorted` and `...ROf...`; `kvE2_sepTieRuns_key_const`;
  `kvE2_sepTieGroupedL_value_const` and `...R...` (one value per class via `kvE2_sepSlotHonestVIdx_eq_iff`
  :5857). All green + axiom-clean.
- **Timing:** 1 hour (DONE)
- **Depends on:** none
- **Files modified:** `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/SharedWitness.lean`
  — additive foundation lemmas after SW:7789.
- **Verification:** foundation compiles sorry-free; `lean_verify` no `sorryAx`; green `lake build`. (Met.)

---

### Phase 2: `.rXW` carrier fix — restore the below-pivot `v < w` bound (AUTHORIZED non-additive edit) [COMPLETED]

**Phase 2 completion note (task 337, session sess_1783639750_29c89e_337):**
- All 3 authorized sites edited: Site 1 `kvE_sub2_zoneHolds_zXU` (SubBracket2:565, conclusion now
  `x < v ∧ v < w ∧ v < x1`, keeping `hp1`); Site 2 `kvE2_sepSlotValue_rXW_spec` (SW, conclusion
  `x < v ∧ v < w ∧ realizes`); Site 3 `.rXW` epsilon upper bound changed to `v < w` (SW).
- **Deviation (blast-radius under-count, altered/threaded):** propagating `v < w` to `_rXW_spec`
  required strengthening the zXU field of `kvE_subBracket2_complete_extract` (SubBracket2:619-620/631)
  — the plan's named authorized consumer (":631, the complete_extract zXU field, :619-620"). That
  field has **three** consumers, not the one the plan's blast-radius stated: SW:2770, SW:3464, and
  **SubBracket2V.lean:1904** (the last NOT listed in the plan). All three re-projected mechanically
  (drop the new `v < w` conjunct), each preserving its own public signature byte-for-byte. No fourth
  landed declaration's *interface* changed; SubBracket2V:1904 is a consumer re-check per the plan's
  "re-check each consumer" mandate, not a scope widening.
- **Plan-premise confirmation (NOT a regression):** `lean_verify` MCP returned unreliable/stale
  `sorryAx` for `kvE2_sepBody_complete_holds'` (contradicted itself across runs). Deterministic
  `#print axioms` at build time shows `kvE2_sepBody_complete_holds'`, `kvE2_sepBody_complete`, and
  `kvE2_sepSlotValue_rXW_spec` ALL clean `{propext, Classical.choice, Quot.sound}` — no `sorryAx`.
  STOP-condition satisfied, task-342 assets green + axiom-clean.
- Phase-7 gate reference (post-fix caps): SW `kvE_sub2_`=107, SW `x1 <`=73, SB2 `kvE_sub2_`=46,
  SB2 `x1 <`=4. SharedWitness `sorry` count = 7 (all prose).
- Two SB2 `sorry`s exist in EANegation.lean:834/1129 (unrelated file, off the axiom path — confirmed
  by `#print axioms` showing no `sorryAx`).

**This phase is the sole reason this revision exists.** It executes the bounded, 3-site,
non-additive carrier edit authorized above and NOTHING WIDER. It resolves plan 12's O1 blocker at the
definition, so that every `.rXW` slot value is provably `< w`.

- **Goal:** Strengthen the `.rXW` value bound from `v < anchorVal` to `v < w` at its three pinned
  sites, re-check all blast-radius consumers, and re-verify the task-342 STOP-condition theorems
  remain green + axiom-clean.
- **Tasks:**
  - [ ] `grep -n` re-confirm the three edit sites and their current lines: `kvE_sub2_zoneHolds_zXU`
    (SubBracket2.lean ~:565) and `kvE_sub2_zoneHolds_cons_iff` (~:538-546, source of `hp1`);
    `kvE2_sepSlotValue` `.rXW` branch (SW ~:3540-3541); `kvE2_sepSlotValue_rXW_spec` (SW ~:3642-3655).
    `lean_hover_info` each to read the exact current signatures.
  - [ ] **Site 1** — strengthen `kvE_sub2_zoneHolds_zXU` (SubBracket2.lean:565) conclusion from
    `x < v ∧ v < x1` to `x < v ∧ v < w ∧ v < x1`, by keeping the discarded `hp1` (the coord-1 /
    `w`-coordinate component of `kvE_sub2_zoneHolds_cons_iff`, :543-544; the `v < w` fact is
    `hp1.1.mpr rfl`). Sorry-free from the zone spec.
  - [ ] **Re-check Site 1's ONE consumer** — SubBracket2.lean:631 (the `complete_extract` zXU field,
    :619-620). `lean_goal` at the consumer; update its destructuring to accept the new `v < w`
    conjunct. Verify green.
  - [ ] **Site 2** — strengthen `kvE2_sepSlotValue_rXW_spec` (SW:3642) conclusion to
    `x < v ∧ v < w ∧ nf_eval_nf … χ`, threading the `v < w` from Site 1. Keep `v < anchorVal`
    derivable as `v < w < x1` (right-interior `w < x1`) so any consumer still wanting it is covered.
  - [ ] **Site 3** — edit the `.rXW` branch of `kvE2_sepSlotValue` (SW:3540-3541): change the epsilon
    predicate upper bound from `v < kvE2_sepAnchorVal … σ` to `v < w`, i.e. the branch becomes
    `Classical.epsilon (fun v => x < v ∧ v < w ∧ nf_eval_nf M 0 1 (fun _ => v) χ)`. This is the single
    non-additive line of substance. Its `Classical.epsilon_spec` is now satisfiable via Site 2 (the
    honest witness genuinely exists in `(x,w)` by the zone bit).
  - [ ] **Re-check Site 2's TWO consumers** — SharedWitness.lean:4654 and :5943, both projecting
    `.2.2` (the `realizes χ` conjunct). `lean_goal` at each; confirm the `.2.2` projection still
    reaches `realizes χ` through the inserted `v < w` (adjust projection depth if the tuple shape
    shifted). Verify green.
  - [ ] **STOP-condition re-verification** — `lean_verify` on `kvE2_sepBody_complete_holds'` (SW:6158)
    AND `kvE2_sepBody_complete`: both must be GREEN and return exactly
    `{propext, Classical.choice, Quot.sound}` with no `sorryAx`. **If either regresses, STOP and
    surface to the orchestrator — do NOT patch around it.**
  - [ ] Full `lake build` green. `grep -c 'sorry'` in SharedWitness.lean still == 7 (all prose).
    Re-measure baseline caps NOW (`grep -c 'kvE_sub2_'`, `grep -c 'x1 <'` in the touched files) and
    record the post-fix values as the Phase-7 gate reference.
  - [ ] `git diff` confirms ONLY the 3 authorized sites + their re-checked consumers are touched
    (SubBracket2.lean: `zXU` extraction + :631; SharedWitness.lean: `.rXW` branch + `_rXW_spec` +
    :4654/:5943). NO fourth landed declaration edited. Commit the green carrier fix.
- **Timing:** 1 hour
- **Depends on:** 1
- **Files to modify:**
  `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/SubBracket2.lean` (Site 1 + its
  one consumer) and `.../SharedWitness.lean` (Sites 2, 3 + their two consumers). **Non-additive, but
  bounded to exactly these sites.**
- **Verification:** all 3 edited declarations sorry-free; `lean_verify` no `sorryAx` on each;
  `kvE2_sepBody_complete_holds'` and `kvE2_sepBody_complete` re-verified green + axiom-clean; every
  `.rXW` value now provably `< w` (via the strengthened `_rXW_spec`); `git diff` bounded to the 3
  sites + re-checked consumers; `sorry` count still 7; green `lake build`.

---

### Phase 3: O1 — class witness order and range (unblocked by Phase 2) [COMPLETED]

**Phase 3 completion note (task 337, session sess_1783639750_29c89e_337):**
- Landed `kvE2_sepTieRuns_key_strictMono` (generic combinatorial: key-sorted list ⟹ runs strictly
  key-increasing across classes), and the value-transfer pair `kvE2_sepTieGroupedL_strictMono` /
  `kvE2_sepTieGroupedR_strictMono` — exactly report 14 verdict (b)'s prescribed additive fix
  (assembles five landed Phase-1 assets; `≤` via `List.pairwise_flatten` + `≠` via key-distinct
  through the primed bridge and `kvE2_sepSlotHonestVIdx_eq_iff`). Builder consumes the PRIMED order.
- Landed the pivot/range per-slot bounds: `kvE2_sepSlotsLFor_value_bound` (LEFT slot value ∈ (x,w)),
  `kvE2_sepSlotsRFor_value_bound` (RIGHT slot value ∈ (w,t)), and their merged-list corollaries
  `kvE2_sepSlotsLOf_honestOrder'_value_bound` / `...ROf...`. `usL`-last `< w` from per-slot value
  specs (NOT value-sortedness; plan 12 line 140 mis-mitigation stays retracted). rXW below-pivot
  bound consumed from the landed Phase-2 `_rXW_spec`.
- **Deviation (altered — assembly-level `hsort` deferred to Phase 7):** the final
  `(usL ++ w :: usR).Pairwise (· < ·)` in `kvE2_sepBracketN_construct`'s `hsort` shape is assembled
  in Phase 7 where `usL`/`usR` (the concrete class-value lists) are fixed. Phase 3 lands the strict
  monotonicity + pivot/range as reusable standalone lemmas (report 14's "the fix"), which Phase 7
  combines. No `x1 < e_i` literal introduced; all bounds ride the bracket range `x`/`w`/`t` and the
  per-slot value specs. All 7 new lemmas axiom-clean `{propext, Classical.choice, Quot.sound}`
  (the generic one only `{propext, Quot.sound}`); SharedWitness `sorry` count still 7 (all prose).

- **Goal:** Prove strict cross-class monotonicity of the combined list `usL ++ w :: usR` and the
  pivot/range facts in the exact shape `kvE2_sepBracketN_construct` (`hsort`, SW:5363) demands. With
  Phase 2 landed, `usL`-last `< w` is now provable per-slot.
- **Tasks:**
  - [ ] `grep -n` re-confirm (post-Phase-2 lines will have shifted): `kvE2_sepSlotHonestVIdx_mono`
    (~:5834), `kvE2_sepSlotsLOf_honestOrder'_valueSorted` (Phase 1), the strengthened
    `kvE2_sepSlotValue_rXW_spec` (~:3642, now concluding `v < w`), `kvE2_sepSlotValue_lXU_spec` and
    `_lUW_spec` (left-list bounds), `kvE2_sepSlotValue_lWT_spec` / `_rWX1_spec` / `_rX1T_spec`
    (right-list bounds), `kvE2_sepBracketN_construct` `hsort` (~:5363).
  - [ ] **Pivot bound `usL`-last `< w` — the direct route now available:** every LEFT-list slot value
    is `< w` per-slot: `.lXU` (`x < v < x1 < w`), `.lUW` (`x1 < v < w`), and `.rXW`
    (`x < v < w`, from the strengthened Phase-2 spec). **Do NOT use value-sortedness for this bound
    (plan 12 line 140's retracted mis-mitigation); use the per-slot value specs.**
  - [ ] **Pivot bound `w < usR`-first:** every RIGHT-list slot value is `> w` per-slot: `.lWT`
    (`w < v < t`), `.rWX1` (`w < v < x1`), `.rX1T` (`x1 < v < t`, `w < x1`). From the value specs.
  - [ ] Prove strict monotonicity WITHIN `usL` and WITHIN `usR` from cross-class index strictness
    (`kvE2_sepSlotHonestVIdx_mono`) + one-value-per-class (Phase 1). Class ORDER carries within-list
    strictness; the pivot bounds above carry the cross-pivot split.
  - [ ] Global range `x < · < t` from the per-slot value specs and the honest order's boundary
    structure, not owner chains.
  - [ ] Assemble the combined `usL ++ w :: usR` strict-sortedness fact in
    `kvE2_sepBracketN_construct`'s expected `Pairwise (· < ·)` form.
  - [ ] Verify each `have` with `lean_goal`; sorry-free; commit at first green sub-lemma.
- **Timing:** 1.5 hours
- **Depends on:** 2
- **Files to modify:** `.../SharedWitness.lean` — additive O1 lemma(s).
- **Verification:** sorry-free; `lean_verify` no `sorryAx`; no `x1 < e_i` literal introduced (LITMUS
  NS:437) — bounds from bracket range + value specs only; green `lake build`.

---

### Phase 4: O2 — class point types [NOT STARTED]

- **Goal:** Prove `(kvE2_sepClassType c).eval_at` at each class value, reducing via
  `kvE2_sepClassType_eval_iff` (~:2116) to each member's point type.
- **Tasks:**
  - [ ] `grep -n` re-confirm `kvE2_sepClassType_eval_iff` (~:2116), `kvE2_sepSlotValue_baseType_spec`
    (~:5943 — a Phase-2 blast-radius consumer of `_rXW_spec`; confirm it stays green post-fix),
    `kvE2_sepSlotValue_anchorSlot` (~:5897), `kvE2_sepAnchorVal_spec` (~:3345),
    `kvE2_sepProjFresh_eval` (~:6992), `kvE2_sepClosedLeafAt_discharge_honest` (~:3360),
    `kvE2_sepPtW_eval_of_honest` (~:7724). (All lines shifted by Phase 2 — re-grep.)
  - [ ] Base slots: discharge via `kvE2_sepSlotValue_baseType_spec` (~:5943) + `hcb`.
  - [ ] Anchor slots: discharge via `kvE2_sepSlotValue_anchorSlot` (~:5897) + `kvE2_sepAnchorVal_spec`
    (~:3345) + `hck` + `kvE2_sepProjFresh_eval` (~:6992).
  - [ ] Foreign-base-at-anchor members: discharge via `kvE2_sepClosedLeafAt_discharge_honest`
    (~:3360) — F5: CLOSED key only (document the tie collapse as *forced by Def 3.1 (p.4)*; Lemma
    3.2(1) *states the closure without printed proof*).
  - [ ] Pivot point type from `kvE2_sepPtW_eval_of_honest` (~:7724).
  - [ ] Reduce `kvE2_sepClassType_eval_iff` over the class members to the per-member discharges.
  - [ ] Verify each `have` with `lean_goal`; sorry-free; commit at first green sub-lemma.
- **Timing:** 1.5 hours
- **Depends on:** 2
- **Files to modify:** `.../SharedWitness.lean` — additive O2 lemma(s).
- **Verification:** sorry-free; `lean_verify` no `sorryAx`; F5 CLOSED-key reads for tie discharges;
  green `lake build`.

---

### Phase 5: O3(a) — honest segment-evaluation lemma family (standalone) [NOT STARTED]

- **Goal:** Land the NEW "honest segment evaluation" lemma family as STANDALONE green lemmas
  (generic in an interior point `y`), since no banked completeness-direction segment-eval lemma
  exists. Each owner's segment contribution evaluates at interior `y`, read out of the owners'
  universal (β) layer of `h` via `kvE2_sepSegForm` (~:184) + `hcb`.
- **Tasks:**
  - [ ] `grep -n` re-confirm `kvE2_sepSegsG` (~:2167), `kvE2_sepSegLAt`/`kvE2_sepSegRAt`
    (~:1156/:1163), `kvE2_sepSegLForSub'`/`kvE2_sepSegRForSub'` (~:6805/:6884), their `_at_sound`
    shape lemmas (~:6827/:6908), `kvE2_sepSegForm` (~:184), and the private honest bundles
    `kvE2_sepHonestBundleL/R` (~:2739/:2791) to generalize from. (Lines shifted by Phase 2.)
  - [ ] Confirm (do NOT consume as an eval discharge) that `_at_sound` (~:6827/:6908) are
    definitional shape lemmas and `kvE2_sepSegForm_excludes` (~:6543) is the exclusion reading — the
    honest-eval discharge is NEW work here.
  - [ ] State and prove the segment-eval family: for an interior `y` (with the appropriate value
    bounds as GENERIC hypotheses — not yet tied to consecutive class gaps), every owner's
    `kvE2_sepSegLForSub'`/`kvE2_sepSegRForSub'` contribution evaluates at `y`, reading the β-layer of
    `h` via `kvE2_sepSegForm` (~:184) + `hcb`. Generalize the private honest bundles.
  - [ ] Land each lemma of the family GREEN and COMMIT individually before moving on (never a RED or
    `sorry` intermediate; this phase dominates the line budget).
  - [ ] Verify each with `lean_goal` + `lean_verify` (no `sorryAx`).
- **Timing:** 2 hours
- **Depends on:** 2
- **Files to modify:** `.../SharedWitness.lean` — additive segment-eval lemma family.
- **Verification:** each family lemma sorry-free and axiom-clean; bounds from region endpoints +
  value specs, never an owner chain (LITMUS NS:437); green `lake build`.

---

### Phase 6: O3(b) — gap discharge over consecutive class witnesses [NOT STARTED]

- **Goal:** Consume the Phase-5 family and the Phase-3 class order to discharge, for every `y`
  strictly between consecutive class witnesses (plus the `x`-, `w`-, `t`-boundary gaps), every
  owner's segment contribution — the three segment-gap families in `kvE2_sepBracketN_construct`'s
  shape.
- **Tasks:**
  - [ ] `grep -n` re-confirm `kvE2_sepSegsG` (~:2167) and its grouped-cut dispatch to
    `kvE2_sepSegLAt`/`kvE2_sepSegRAt` (~:1156/:1163).
  - [ ] Instantiate the Phase-5 generic-`y` family at the actual consecutive-class gaps of the
    ordered `usL ++ w :: usR` (Phase 3), plus the three boundary gaps at `x`, `w`, `t`.
  - [ ] Assemble the per-cut flat conjunctions `kvE2_sepSegLAt`/`kvE2_sepSegRAt` that `kvE2_sepSegsG`
    dispatches grouped cut `i` to.
  - [ ] Produce the three segment-gap families in `kvE2_sepBracketN_construct`'s expected
    `IntervalPattern.holds_eq_succ` shapes.
  - [ ] Verify each `have` with `lean_goal`; sorry-free; commit per green gap family.
- **Timing:** 1.5 hours
- **Depends on:** 3, 5
- **Files to modify:** `.../SharedWitness.lean` — additive gap-discharge lemma(s).
- **Verification:** sorry-free; `lean_verify` no `sorryAx`; segment bounds from the bracket range +
  Phase-5 family, not owner chains; green `lake build`.

---

### Phase 7: O4 — assembly arithmetic + endpoints + the two public theorems + gates [NOT STARTED]

- **Goal:** Discharge the assembly arithmetic, feed O1/O2/O3 into `kvE2_sepBracketN_construct`,
  attach the Phase-8 endpoints, state + prove the two public theorems, and run the axiom-clean +
  faithfulness gates.
- **Tasks:**
  - [ ] Prove the length equalities `(gL.map kvE2_sepClassType).length = usL.length` (and R) and the
    grouped-cut/flat-cut reindexing via `kvE2_sepTieGroupedL_flatten` (~:2064) and the
    `(gL.take i).flatten.length` arithmetic inside `kvE2_sepSegsG`.
  - [ ] Feed O1 (order/range), O2 (point types), O3 (segment gaps) into the private
    `kvE2_sepBracketN_construct` (~:5357) to obtain the bracket `.holds`.
  - [ ] Attach the endpoints/pivot from the Phase-8 pack: `kvE2_sepEpL_eval_of_honest` (~:7663) at
    `x`, `kvE2_sepEpR_eval_of_honest` (~:7789) at `t`, `kvE2_sepPtW_eval_of_honest` (~:7724) at `w`;
    assemble the `.2.holds` triple ⟨EpL@x, EpR@t, bracket `.holds`⟩ (shape per
    `kvE2_sepDisjunct_extract` ~:6207).
  - [ ] State + prove `kvE2_sepDisjunct'_holds_of_honest` — the EXACT §2.1 statement (Overview),
    placed AFTER SW:7789.
  - [ ] State + prove the corollary `kvE2_sepBody_holds_of_honest` as
    `kvE2_sepBody_complete_holds' … (kvE2_sepDisjunct'_holds_of_honest …)` (~:6158) — the object task
    335 consumes.
  - [ ] **Axiom/faithfulness gate**: `lean_verify` on both public theorems and every new helper →
    exactly `{propext, Classical.choice, Quot.sound}`, no `sorryAx`. `grep -c 'sorry'` still == 7
    (all prose). Grep the diff for `admit`/new `axiom`/`:= True` (must be NONE). F5 (no open/closed
    zone-key conflation; CLOSED-key tie reads). LITMUS (NS:437): no `x1 < e_i` relative-position
    literal. Baseline caps against the **Phase-2 re-measured reference** (not plan 12's pre-fix
    107/73). `git diff` beyond Phase 2 is additive-only (every OTHER landed asset byte-for-byte
    untouched). Full `lake build` green.
- **Timing:** 1.5 hours
- **Depends on:** 4, 6
- **Files to modify:** `.../SharedWitness.lean` — the assembly helpers + the two public theorems
  (additive, after SW:7789).
- **Verification:** both public theorems compile sorry-free and axiom-clean; corollary discharges
  `kvE2_sepBody`.holds; full `lake build` green; all gates pass.

---

## Testing & Validation

- [ ] `lake build` of the `NfMultiAnchorBridge/` target (and full project in Phase 7) succeeds; each
  phase ends green.
- [ ] **Phase 2 carrier fix:** all 3 edited declarations sorry-free and axiom-clean; the STOP-condition
  theorems `kvE2_sepBody_complete_holds'` (SW:6158) and `kvE2_sepBody_complete` re-verified green +
  `{propext, Classical.choice, Quot.sound}`; every `.rXW` value provably `< w`; `git diff` bounded to
  the 3 authorized sites + their re-checked consumers (SubBracket2.lean:565 + :631; SharedWitness.lean
  `.rXW` branch + `_rXW_spec` + :4654/:5943).
- [ ] `lean_verify` on `kvE2_sepDisjunct'_holds_of_honest`, `kvE2_sepBody_holds_of_honest`, and every
  new helper returns `{propext, Classical.choice, Quot.sound}` with no `sorryAx`.
- [ ] **Sorry count:** `grep -c 'sorry'` in SharedWitness.lean stays == 7, ALL inside prose comments
  — zero real sorries, at the end of EVERY phase.
- [ ] No `admit`, no new `axiom`, no vacuous definition anywhere in the diff; no phase closed via
  `(kvE2_sepHonest_hLR_absurd …).elim` or `False.elim` (a vacuous close is a FAILURE).
- [ ] **Scope:** apart from the Phase-2 3-site carrier edit, the change is ADDITIVE: every OTHER
  LANDED asset (Phase-1 substrate, `kvE2_sepHonest_engineInputs`, `kvE2_sepHonest_witnesses`,
  `kvE2_sepBracketN_construct`, the Phase-8 pack, `kvE2_sepProjFresh_eval`) is byte-for-byte
  unmodified. `kvE2_sepSlotsLOf` / `kvE2_sepSlotsLFor` untouched.
- [ ] `kvE2_sepDisjunct'_holds_of_honest` matches the §2.1 statement exactly; the corollary is
  `kvE2_sepBody_complete_holds' … (kvE2_sepDisjunct'_holds_of_honest …)`.
- [ ] No `hLR` assumed anywhere (exactly one `(hLR :` binder remains file-wide, inside the guard).
- [ ] O1 (Phase 3) is NOT weakened — strict `Pairwise (· < ·)`, `usL`-last `< w` proved per-slot from
  the value specs (NOT value-sortedness).
- [ ] F5 CLOSED/open key discrimination; LITMUS NS:437 no `x1 < e_i` literal; the Phase-2 conjunct is
  the env-anchored `v < w` (report 13 §F1-F7); witness/segment bounds from the bracket range
  `x`/`w`/`t` and per-slot value specs only.
- [ ] Baseline caps hold against the Phase-2 re-measured reference (`grep -c`, LINE counts).
- [ ] Citation discipline D1/D2/D7 respected in all docstrings (PDF pages only; tie collapse forced
  by Def 3.1 (p.4); Lemma 3.2(1) states the closure without printed proof; the `.rXW` `v < w` bound
  cited to Def 3.1 ordering channel (PDF p.4) / Figure 1 below-pivot half (PDF p.9) per report 13).

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/SubBracket2.lean` — Phase 2
  only: strengthen `kvE_sub2_zoneHolds_zXU` (:565) + re-check its consumer (:631). Non-additive,
  bounded.
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/SharedWitness.lean` — Phase 2:
  the `.rXW` branch of `kvE2_sepSlotValue` (:3540-3541) + `kvE2_sepSlotValue_rXW_spec` (:3642) +
  re-check consumers (:4654, :5943), non-additive; Phases 3–7: additive only — O1 lemma(s), O2
  lemma(s), the O3 segment-eval family, the O3 gap discharge, the assembly helpers + the two public
  theorems `kvE2_sepDisjunct'_holds_of_honest` and `kvE2_sepBody_holds_of_honest`, all after SW:7789.
- `specs/337_.../plans/13_grouped-disjunct-holds-builder-carrier-fix.md` (this file; supersedes
  plan 12).
- `specs/337_.../summaries/13_grouped-disjunct-holds-builder-carrier-fix-summary.md` (on completion).
- **Downstream**: task 335 consumes `kvE2_sepBody_holds_of_honest`.

## Rollback/Contingency

- **Phase 2 (carrier fix)** is a single bounded commit touching 3 sites + their consumers. To revert:
  restore the `v < anchorVal` bound at all three sites; the tree returns to its post-342 green state.
  If Phase 2 cannot be made green without touching a FOURTH landed declaration, STOP and surface it —
  this signals the audit's blast-radius analysis was incomplete, a scope question for the
  orchestrator, NOT an authorized widening.
- **Task-342 regression is a STOP condition.** If `kvE2_sepBody_complete_holds'` (:6158) or
  `kvE2_sepBody_complete` regresses (RED or a new axiom) after Phase 2, STOP and surface it — do NOT
  patch around it, do NOT weaken those theorems.
- Phases 3–7 are additive to `SharedWitness.lean`. To revert any: delete the new declaration(s).
- If Phase 5 (segment-eval family) cannot close within one agent run: land each family lemma as a
  standalone sorry-free green lemma and commit it, then continue the remaining lemmas in a follow-on
  green sub-step. Never commit a bare `sorry`, a vacuous placeholder, or a segment eval modulo an
  assumed obligation.
- If Phase 3 (O1) discovers a class-order fact that the value specs (post-Phase-2) still cannot
  support, STOP and surface it — do NOT force a zone bound, do NOT weaken O1, do NOT introduce an
  `x1 < e_i` literal, do NOT re-touch `kvE2_sepSlotsLOf`.
