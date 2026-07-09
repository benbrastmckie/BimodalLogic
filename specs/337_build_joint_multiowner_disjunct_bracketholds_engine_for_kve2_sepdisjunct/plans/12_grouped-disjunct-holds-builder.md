# Implementation Plan v5: Task #337 — Grouped Multi-Owner Disjunct `.holds` Builder

- **Task**: 337 - Build the joint multi-owner disjunct bracket-`holds` engine for `kvE2_sepDisjunct'`, delivering the ⇐-direction builder `kvE2_sepDisjunct'_holds_of_honest` and its body corollary `kvE2_sepBody_holds_of_honest`
- **Status**: [NOT STARTED]
- **Effort**: 9 hours
- **Dependencies**: 342 (COMPLETED, axiom-clean — grouped tie-admitting carrier, `hLR` deletion, `kvE2_sepBody_complete_holds'`, Phase-8 honesty pack); 334/336/338/339/340 (COMPLETED — landed carrier/value chain). Task 337 is NOT blocked (report 08 §3).
- **Research Inputs**: specs/337_build_joint_multiowner_disjunct_bracketholds_engine_for_kve2_sepdisjunct/reports/08_post-342-revision-strategy.md (authoritative, independently verified — all 18 declaration citations confirmed at HEAD `cbf812606`)
- **Artifacts**: plans/12_grouped-disjunct-holds-builder.md (this file)
- **Standards**: plan-format.md; status-markers.md; artifact-management.md; tasks.md; lean4.md (literature-fidelity-policy.md)
- **Type**: lean4
- **Lean Intent**: false

## Overview

This is **plan version 5** for task 337 (the filename prefix `12` is the task's unified artifact
sequence number, not a version count — plans 01..04 precede this one; summaries already reach 11).
It is authored **fresh against report 08 §2** per that report's explicit Decision, NOT by patching
plan 04 — the file grew 4174 → 7845 lines and all plan-01..04 line numbers are stale. Plan 04
contributes only its landed-asset inventory.

**Problem.** Task 342 retargeted the completeness-side obligation from the FLAT disjunct to the
GROUPED tie-admitting disjunct. The unblocking declaration `kvE2_sepBody_complete_holds'`
(SharedWitness.lean:6158, hereafter SW:) pins the exact residual obligation as its single delegated
hypothesis `hdisj`: the `.holds` of `kvE2_sepDisjunct'` over the grouped honest order. Roughly half
of 337's pipeline is already LANDED and must NOT be re-derived (engine inputs, witness chain,
generic N-slot bracket constructor, Phase-8 endpoint/pivot honesty pack). What remains is the
per-tie-class witness/point-type/segment construction (the four open obligations O1–O4 below).

**Scope / definition of done.** Two public theorems, additive to `SharedWitness.lean`, placed
AFTER SW:7789 (below the Phase-8 pack, so all honesty lemmas and the private
`kvE2_sepBracketN_construct` are in scope): `kvE2_sepDisjunct'_holds_of_honest` (the exact §2.1
statement, reproduced below) and the corollary `kvE2_sepBody_holds_of_honest` (proved as
`kvE2_sepBody_complete_holds' … (kvE2_sepDisjunct'_holds_of_honest …)`). Sorry-free, axiom-clean
(`{propext, Classical.choice, Quot.sound}`, no `sorryAx`), full `lake build` green, faithfulness
gates (F5 / LITMUS / baseline caps / citation discipline) satisfied. Task 335 consumes
`kvE2_sepBody_holds_of_honest`.

**`hLR` is DELETED** from all four completeness theorems by task 342; `kvE2_sepHonest_hLR_absurd`
(SW:5730) certifies it was unsatisfiable, and exactly one `(hLR :` binder remains file-wide (inside
that guard). Any phase that assumes `hLR` is wrong.

### The exact target (report 08 §2.1 — reproduce verbatim)

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

The `hcb`/`hck` hypotheses are copied verbatim from the Phase-8 pack (SW:7669-7672). `.2.holds` for
this `Σ n, VecEA2 n` decomposes as the triple ⟨`kvE2_sepEpL` eval at `x`, `kvE2_sepEpR` eval at `t`,
bracket `.holds`⟩ exactly as `kvE2_sepDisjunct_extract` destructures it (`obtain ⟨hepL, hepR, hbr⟩`,
SW:6207).

### Research Integration

Integrated from `reports/08_post-342-revision-strategy.md` (plan version 5):
- §2.1 exact target theorem statement (reproduced above).
- §2.2 verified lemma inventory (all names confirmed present at cited SW: lines) — the single
  refreshed reference for every phase; plan-01..04 line numbers are NOT used.
- §2.3 recommended proof route: **value-direct per-class witnesses** — the payload law
  `kvE2_sepSlotHonestVIdx_eq_iff` (:5857) converts equal tie-class indices into equal honest
  `kvE2_sepSlotValue`s, so each tie class has one well-defined honest value; `usL/usR :=
  classes.map (class-head slot value)` feeds `kvE2_sepBracketN_construct` directly. Class heads
  exist by `kvE2_sepTieRuns_ne_nil` (:2008) / `kvE2_sepTieGroupedL_ne_nil` (:2074). The banked
  engine route (`kvE2_sepHonest_witnesses`) is retained as a documented fallback only.
- §2.3 O1–O4 open-obligation split (this plan's phases).
- §Risks — cross-region slot values, O3 sizing, stale-line-number discipline, citation drift.

**Plan-time verification already performed (this dispatch):** the two cross-region slot-value
specs O1 depends on were read directly from the file (not via stale plan refs):
- `kvE2_sepSlotValue_rXW_spec` (SW:3642): a **left-region base slot of a RIGHT-interior owner**
  realizes `x < value < kvE2_sepAnchorVal … σ`, and that anchor lies in `(w,t)`. **Therefore a
  left-list slot value CAN honestly exceed `w`.** The naive "left values `< w <` right values" zone
  bound is FALSE. O1's cross-class order MUST ride `kvE2_sepSlotHonestVIdx_mono` (:5834) + the
  merged-list sortedness `kvE2_sepSlotsLOf_honest_valueSorted` (:4157), NOT zone bounds. This is a
  binding constraint on Phase 2, resolved before it is written.
- `kvE2_sepSlotValue_lWT_spec` (SW:3625): a right-region base slot of a LEFT-interior owner realizes
  `w < value < t` (consistent with the right side; not the problematic direction).

### Prior Plan Reference

Plan 04 is SUPERSEDED-but-salvageable for its **landed-asset inventory only** (report 08 §1). From
it, the following are LANDED and must NOT be re-derived or deleted: `kvE2_sepHonest_engineInputs`
(:4803), `kvE2_sepHonest_witnesses` (:4992), the private `kvE2_sepBracketN_construct` (:5357). Plan
04's flat-disjunct target, its `hLR`-carrying hypothesis package, its `kvE2_sepHonest_bracket_holds`
BLOCKED phase, and every plan-04 line number are stale and NOT carried forward. Effort calibration
from plan 04: the O3/segment-match work was its deepest, highest-risk step — this plan sizes O3 as
two phases accordingly.

### Roadmap Alignment

No ROADMAP.md consulted (roadmap flag not set). Advances the Kamp-theorem completeness arm by
landing the faithful grouped joint-bracket `.holds` builder on 342's tie-admitting carrier,
unblocking the ⇐ direction of parent task 335.

## Goals & Non-Goals

**Goals**:
- Define the value-direct per-class witness lists `usL/usR := classes.map (class-head slot value)`
  over `kvE2_sepTieGroupedL/R (kvE2_sepHonestOrder' …)`, with class-head existence from the
  `_ne_nil` lemmas and one-value-per-class from the payload law `kvE2_sepSlotHonestVIdx_eq_iff`.
- Discharge the four open obligations O1 (class witness order & range), O2 (class point types),
  O3 (honest segment evaluation — split across two phases: the new segment-eval lemma family, then
  the gap discharge), O4 (assembly arithmetic + endpoints + the two public theorems).
- Deliver `kvE2_sepDisjunct'_holds_of_honest` (exact §2.1 statement) and the corollary
  `kvE2_sepBody_holds_of_honest`, both sorry-free and axiom-clean.
- Feed the four obligations into the private `kvE2_sepBracketN_construct` (:5357), keeping the task
  strictly ADDITIVE to `SharedWitness.lean`.

**Non-Goals**:
- Do NOT re-derive or delete any LANDED asset: `kvE2_sepHonest_engineInputs` (:4803),
  `kvE2_sepHonest_witnesses` (:4992), `kvE2_sepBracketN_construct` (:5357), the Phase-8 honesty pack
  `kvE2_sepEpL/PtW/EpR_eval_of_honest` (:7663/:7724/:7789), `kvE2_sepProjFresh_eval` (:6992).
- Do NOT assume `hLR` (deleted; `kvE2_sepHonest_hLR_absurd` :5730 certifies it unsatisfiable).
- Do NOT edit any existing declaration; the task is strictly additive (new lemmas + two public
  theorems placed after SW:7789).
- Do NOT close any phase via `(kvE2_sepHonest_hLR_absurd …).elim` or any vacuous route; no bare
  `sorry`/`admit`, no new `axiom`, no `def X := True` placeholder, no `.holds` modulo an assumed
  hypothesis.
- Do NOT use the banked engine route (`kvE2_sepHonest_witnesses`) as the primary; it is a documented
  fallback only (its stitched chain is a different multiset from the per-class values).
- Do NOT touch `OuterGate.lean` or `KampPrior.lean` (task 335's consumption is a separate dispatch).

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| **O3 (honest segment evaluation) exceeds one dispatch** — no banked completeness-direction segment-eval lemma exists (`_at_sound` :6827/:6908 are definitional shape lemmas; `kvE2_sepSegForm_excludes` :6543 is the exclusion reading, not an honest-eval discharge) | H | H | Split O3 into Phase 4 (segment-eval lemma family as STANDALONE green lemmas, generic in the interior point `y`, reading the owners' universal β-layer out of `h` via `kvE2_sepSegForm` :184 + `hcb`, generalizing the private honest bundles :2739/:2791) and Phase 5 (gap discharge consuming them). Land Phase 4's family green before Phase 5; never a `sorry` or vacuous placeholder. |
| **Cross-region slot values (`.rXW`/`.lWT`) break the naive "left < w < right" order** | H | H (confirmed) | Already resolved at plan time: `kvE2_sepSlotValue_rXW_spec` (:3642) shows a left-list value can exceed `w`. O1 (Phase 2) rides `kvE2_sepSlotHonestVIdx_mono` (:5834) + `kvE2_sepSlotsLOf_honest_valueSorted` (:4157), NOT zone bounds. Phase 2 opens by re-reading both specs via `lean_hover_info`. |
| **Grouped-cut / flat-cut reindexing arithmetic in `kvE2_sepSegsG`** (`(gL.take i).flatten.length`, `kvE2_sepTieGroupedL_flatten` :2064) misaligns | M | M | Isolate the length/reindex lemmas in Phase 6 (O4) as separate `have`s; verify each pivot/offset via `lean_hover_info` on `kvE2_sepTieGroupedL_flatten` and `kvE2_sepSegsG` before assembly. |
| **Stale line numbers** (file grows as phases land) | M | M | §2.2 inventory is the refreshed reference; EVERY phase opens with a `grep -n` re-confirmation of the declarations it consumes. |
| **Citation drift on Lemma 3.2(1) / tie mechanism** | L | L | Use only the sanctioned D1/D2/D7 phrasing: tie collapse *forced by Def 3.1 (p.4)*; Lemma 3.2(1) *states the closure without printed proof* (never "per the proof of Lemma 3.2(1)"); k=m split (p.7) corroboration ONLY; `kvE2_sepAnchorDistinct` is a Lean-side `nf_eval_unique` pruning with NO Rabinovich counterpart. Cite PDF pages only (the `.md` conversion is inaccurate). |
| **Faithfulness regression** (`x1 < e_i` literal, F5 open/closed key conflation) | H | L | All witness/segment bounds from the bracket range `x`/`w`/`t` and per-slot value specs, never an owner chain (LITMUS NavigatedSpine.lean:437); CLOSED-key reads for tie discharges (F5); Phase 6 runs the explicit gate. Baseline caps measured with `grep -c` (LINE counts): `kvE_sub2_` == 107, `x1 <` == 73. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3, 4 | 1 |
| 3 | 5 | 2, 4 |
| 4 | 6 | 3, 5 |

Phases within the same wave can execute in parallel. Wave 2 parallelism is REAL and is asserted per
report 08's explicit prompt to evaluate it: O1 (Phase 2), O2 (Phase 3), and the O3 segment-eval
family (Phase 4) each depend only on the Phase-1 foundation (the per-class witness value function +
landed lemmas + `h`/`hcb`/`hck`) — O1 needs the class values and monotonicity, O2 needs the class
values and point-type specs, and the Phase-4 family is stated STANDALONE (generic in an interior
point `y`), so none of the three consumes another's output. Phase 5 (the O3 gap discharge) is where
the class order (Phase 2) and the segment-eval family (Phase 4) first combine.

Every phase: (i) opens with a `grep -n` re-confirmation of the declarations it consumes (the file
grows as phases land); (ii) ends at a green, sorry-tracked `lake build` with a `lean_verify`
axiom check on each new declaration; (iii) commits at every green milestone (per-phase, and per
green sub-step within a phase — e.g. each standalone segment-eval lemma in Phase 4).

### Phase 1: Foundation — reconfirm consumed declarations + per-class witness value function [IN PROGRESS]

- **Goal:** Establish the shared substrate all of O1/O2/O3 consume: reconfirm the landed
  declarations at their current lines, and define the value-direct per-class witness value lists
  `usL/usR` with class-head existence and the one-value-per-class fact. No obligation proof yet —
  this phase pins the interface and the witness data.
- **Tasks:**
  - [ ] `grep -n` re-confirm the primary hand-off and carrier: `kvE2_sepBody_complete_holds'`
    (~:6158), `kvE2_sepDisjunct'` (~:2204), `kvE2_sepHonestOrder'` (~:5966), `kvE2_sepTieGroupedL/R`
    (~:2054/:2059) + `_flatten`/`_ne_nil`, `kvE2_sepTieRuns` (~:1971) + `_ne_nil` (~:2008),
    `kvE2_sepClassType` (~:2109) + `_eval_iff` (~:2116), `kvE2_sepSegsG` (~:2167).
  - [ ] `grep -n` + `lean_hover_info` re-confirm the value layer: `kvE2_sepSlotValue` (~:3528),
    `kvE2_sepSlotHonestVIdx` (~:5823) + `_mono` (~:5834) + payload law `_eq_iff` (~:5857),
    `kvE2_sepSlotsLOf_honest_valueSorted` (~:4157), and (binding for O1) `kvE2_sepSlotValue_rXW_spec`
    (~:3642) + `_lWT_spec` (~:3625).
  - [ ] `grep -n` + `lean_hover_info` re-confirm the structural core `kvE2_sepBracketN_construct`
    (~:5357, private): read its exact input contract (`usL/usR` lists, length equalities, combined
    strict sortedness, range in `(x,t)`, per-index point-type evals, `ptW` at the pivot, the three
    segment-gap families) — this is the ground-truth interface O1–O4 must satisfy.
  - [ ] Define the per-class witness value function: `usL := (kvE2_sepTieGroupedL (kvE2_sepHonestOrder'
    …)).map (fun c => kvE2_sepSlotValue … (class-head c))` and the R analogue, with class heads from
    `kvE2_sepTieGroupedL_ne_nil` / `kvE2_sepTieRuns_ne_nil`.
  - [ ] Prove the one-value-per-class fact: any two slots in a class have equal `kvE2_sepSlotValue`
    (equal tie index → equal value via the payload law `kvE2_sepSlotHonestVIdx_eq_iff` :5857), so the
    class-head value is the class's well-defined value.
  - [ ] Record baseline caps NOW (`grep -c 'kvE_sub2_'` == 107, `grep -c 'x1 <'` == 73) as the gate
    reference for Phase 6.
- **Timing:** 1 hour
- **Depends on:** none
- **Files to modify:** `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/SharedWitness.lean` — additive foundation lemmas/definitions after SW:7789.
- **Verification:** foundation compiles sorry-free; `lean_verify` no `sorryAx`; class-head value
  function and one-value-per-class lemma green; green `lake build`.

---

### Phase 2: O1 — class witness order and range [NOT STARTED]

- **Goal:** Prove strict cross-class monotonicity of the combined list `usL ++ w :: usR` and the
  range facts: left-class values `< w <` right-class values and everything in `(x,t)`, in the exact
  shape `kvE2_sepBracketN_construct` demands.
- **Tasks:**
  - [ ] Re-read `kvE2_sepSlotValue_rXW_spec` (:3642) / `_lWT_spec` (:3625) via `lean_hover_info` and
    fix O1's statement to the **monotonicity route**, NOT zone bounds: cross-class strictness from
    `kvE2_sepSlotHonestVIdx_mono` (:5834) + the run structure, and the merged-list sortedness
    `kvE2_sepSlotsLOf_honest_valueSorted` (:4157). (A left-list `.rXW` value can honestly exceed `w`,
    confirmed at plan time — do NOT claim `left < w` per slot; the class ORDER, not a zone bound,
    carries the strictness.)
  - [ ] Prove strict monotonicity within `usL` and within `usR` from cross-class index strictness +
    one-value-per-class (Phase 1).
  - [ ] Prove the pivot bounds `usL`-last `< w < usR`-first and the global range `x < · < t` from the
    per-slot value specs (:3548-:3661) and the honest order's boundary structure, not owner chains.
  - [ ] Assemble the combined `usL ++ w :: usR` strict-sortedness fact in `kvE2_sepBracketN_construct`'s
    expected form.
  - [ ] Verify each `have` with `lean_goal`; keep sorry-free; commit at the first green sub-lemma.
- **Timing:** 1.5 hours
- **Depends on:** 1
- **Files to modify:** `.../SharedWitness.lean` — additive O1 lemma(s).
- **Verification:** sorry-free; `lean_verify` no `sorryAx`; no `x1 < e_i` literal introduced (LITMUS
  NS:437) — bounds from bracket range + value specs only; green `lake build`.

---

### Phase 3: O2 — class point types [NOT STARTED]

- **Goal:** Prove `(kvE2_sepClassType c).eval_at` at each class value, reducing via
  `kvE2_sepClassType_eval_iff` (:2116) to each member's point type.
- **Tasks:**
  - [ ] `grep -n` re-confirm `kvE2_sepClassType_eval_iff` (~:2116), `kvE2_sepSlotValue_baseType_spec`
    (~:5909), `kvE2_sepSlotValue_anchorSlot` (~:5897), `kvE2_sepAnchorVal_spec` (~:3345),
    `kvE2_sepProjFresh_eval` (~:6992), `kvE2_sepClosedLeafAt_discharge_honest` (~:3360),
    `kvE2_sepPtW_eval_of_honest` (~:7724).
  - [ ] Base slots: discharge via `kvE2_sepSlotValue_baseType_spec` (:5909) + `hcb`.
  - [ ] Anchor slots: discharge via `kvE2_sepSlotValue_anchorSlot` (:5897) + `kvE2_sepAnchorVal_spec`
    (:3345) + `hck` + the fresh-projection content `kvE2_sepProjFresh_eval` (:6992).
  - [ ] Foreign-base-at-anchor members: discharge via `kvE2_sepClosedLeafAt_discharge_honest` (:3360)
    — F5: CLOSED key only (document the tie collapse as *forced by Def 3.1 (p.4)*; Lemma 3.2(1)
    *states the closure without printed proof*).
  - [ ] Pivot point type from `kvE2_sepPtW_eval_of_honest` (:7724).
  - [ ] Reduce `kvE2_sepClassType_eval_iff` over the class members to the per-member discharges above.
  - [ ] Verify each `have` with `lean_goal`; keep sorry-free; commit at first green sub-lemma.
- **Timing:** 1.5 hours
- **Depends on:** 1
- **Files to modify:** `.../SharedWitness.lean` — additive O2 lemma(s).
- **Verification:** sorry-free; `lean_verify` no `sorryAx`; F5 CLOSED-key reads for tie discharges;
  green `lake build`.

---

### Phase 4: O3(a) — honest segment-evaluation lemma family (standalone) [NOT STARTED]

- **Goal:** Land the NEW "honest segment evaluation" lemma family as STANDALONE green lemmas
  (generic in an interior point `y`), since no banked completeness-direction segment-eval lemma
  exists. Each owner's segment contribution evaluates at an interior `y`, read out of the owners'
  universal (β) layer of `h` via `kvE2_sepSegForm` (:184) + `hcb`.
- **Tasks:**
  - [ ] `grep -n` re-confirm `kvE2_sepSegsG` (~:2167), `kvE2_sepSegLAt`/`kvE2_sepSegRAt`
    (~:1156/:1163), `kvE2_sepSegLForSub'`/`kvE2_sepSegRForSub'` (~:6805/:6884), their `_at_sound`
    shape lemmas (~:6827/:6908), `kvE2_sepSegForm` (~:184), and the private honest bundles
    `kvE2_sepHonestBundleL/R` (~:2739/:2791) to generalize from.
  - [ ] Confirm (do not consume as an eval discharge) that `_at_sound` (:6827/:6908) are definitional
    shape lemmas and `kvE2_sepSegForm_excludes` (:6543) is the exclusion reading — the honest-eval
    discharge is NEW work here.
  - [ ] State and prove the segment-eval family: for an interior `y` (with the appropriate value
    bounds as hypotheses, generic — NOT yet tied to consecutive class gaps), every owner's
    `kvE2_sepSegLForSub'`/`kvE2_sepSegRForSub'` contribution evaluates at `y`, reading the β-layer of
    `h` via `kvE2_sepSegForm` (:184) + `hcb`. Generalize the private honest bundles :2739/:2791.
  - [ ] Land each lemma of the family GREEN and COMMIT individually before moving on (H8/H9: never a
    RED or `sorry` intermediate; this phase dominates the line budget).
  - [ ] Verify each with `lean_goal` + `lean_verify` (no `sorryAx`).
- **Timing:** 2 hours
- **Depends on:** 1
- **Files to modify:** `.../SharedWitness.lean` — additive segment-eval lemma family.
- **Verification:** each family lemma sorry-free and axiom-clean; bounds from region endpoints +
  value specs, never an owner chain (LITMUS NS:437); green `lake build`.

---

### Phase 5: O3(b) — gap discharge over consecutive class witnesses [NOT STARTED]

- **Goal:** Consume the Phase-4 family and the Phase-2 class order to discharge, for every `y`
  strictly between consecutive class witnesses (plus the `x`-, `w`-, `t`-boundary gaps), every
  owner's segment contribution — i.e. produce the three segment-gap families in the shape
  `kvE2_sepBracketN_construct` demands.
- **Tasks:**
  - [ ] `grep -n` re-confirm `kvE2_sepSegsG` (~:2167) and its grouped-cut dispatch to
    `kvE2_sepSegLAt`/`kvE2_sepSegRAt` (:1156/:1163).
  - [ ] Instantiate the Phase-4 generic-`y` family at the actual consecutive-class gaps of the
    ordered `usL ++ w :: usR` (Phase 2), plus the three boundary gaps at `x`, `w`, `t`.
  - [ ] Assemble the per-cut flat conjunctions `kvE2_sepSegLAt`/`kvE2_sepSegRAt` that `kvE2_sepSegsG`
    dispatches grouped cut `i` to.
  - [ ] Produce the three segment-gap families in `kvE2_sepBracketN_construct`'s expected
    `IntervalPattern.holds_eq_succ` shapes.
  - [ ] Verify each `have` with `lean_goal`; keep sorry-free; commit per green gap family.
- **Timing:** 1.5 hours
- **Depends on:** 2, 4
- **Files to modify:** `.../SharedWitness.lean` — additive gap-discharge lemma(s).
- **Verification:** sorry-free; `lean_verify` no `sorryAx`; segment bounds from the bracket range +
  Phase-4 family, not owner chains; green `lake build`.

---

### Phase 6: O4 — assembly arithmetic + endpoints + the two public theorems + gates [NOT STARTED]

- **Goal:** Discharge the assembly arithmetic, feed O1/O2/O3 into `kvE2_sepBracketN_construct`,
  attach the Phase-8 endpoints, and state + prove the two public theorems; then run the axiom-clean
  and faithfulness gates.
- **Tasks:**
  - [ ] Prove the length equalities `(gL.map kvE2_sepClassType).length = usL.length` (and R) by
    construction, and the grouped-cut/flat-cut reindexing via `kvE2_sepTieGroupedL_flatten` (:2064)
    and the `(gL.take i).flatten.length` arithmetic inside `kvE2_sepSegsG`.
  - [ ] Feed O1 (order/range), O2 (point types), O3 (segment gaps) into the private
    `kvE2_sepBracketN_construct` (:5357) to obtain the bracket `.holds`.
  - [ ] Attach the endpoints/pivot from the Phase-8 pack: `kvE2_sepEpL_eval_of_honest` (:7663) at `x`,
    `kvE2_sepEpR_eval_of_honest` (:7789) at `t`, `kvE2_sepPtW_eval_of_honest` (:7724) at `w`; assemble
    the `.2.holds` triple ⟨EpL@x, EpR@t, bracket `.holds`⟩ (shape per `kvE2_sepDisjunct_extract`
    :6207).
  - [ ] State + prove `kvE2_sepDisjunct'_holds_of_honest` — the EXACT §2.1 statement (reproduced in
    the Overview), placed AFTER SW:7789.
  - [ ] State + prove the corollary `kvE2_sepBody_holds_of_honest` as
    `kvE2_sepBody_complete_holds' … (kvE2_sepDisjunct'_holds_of_honest …)` (:6158) — the object task
    335 consumes.
  - [ ] **Axiom/faithfulness gate**: `lean_verify` on both public theorems and every new helper →
    exactly `{propext, Classical.choice, Quot.sound}`, no `sorryAx`. Grep the diff for
    `sorry`/`admit`/new `axiom`/`:= True` (must be NONE). F5 (no open/closed zone-key conflation;
    CLOSED-key tie reads). LITMUS (NS:437): no `x1 < e_i` relative-position literal. Baseline caps
    (`grep -c`, LINE counts): `kvE_sub2_` == 107, `x1 <` == 73 (against Phase-1 reference). `git
    diff` additive-only (every LANDED asset byte-for-byte untouched). Full `lake build` green.
- **Timing:** 1.5 hours
- **Depends on:** 3, 5
- **Files to modify:** `.../SharedWitness.lean` — the assembly helpers + the two public theorems
  (additive, after SW:7789).
- **Verification:** both public theorems compile sorry-free and axiom-clean; corollary discharges
  `kvE2_sepBody`.holds; full `lake build` green; all gates pass.

---

## Testing & Validation

- [ ] `lake build` of the `NfMultiAnchorBridge/` target (and full project in Phase 6) succeeds;
  each phase ends green.
- [ ] `lean_verify` on `kvE2_sepDisjunct'_holds_of_honest`, `kvE2_sepBody_holds_of_honest`, and every
  new helper returns `{propext, Classical.choice, Quot.sound}` with no `sorryAx`.
- [ ] No bare `sorry`/`admit`, no new `axiom`, no vacuous definition anywhere in the diff; no phase
  closed via `(kvE2_sepHonest_hLR_absurd …).elim`.
- [ ] The change is ADDITIVE: every LANDED asset (`kvE2_sepHonest_engineInputs`,
  `kvE2_sepHonest_witnesses`, `kvE2_sepBracketN_construct`, the Phase-8 pack,
  `kvE2_sepProjFresh_eval`) is byte-for-byte unmodified (`git diff` = additive-only).
- [ ] `kvE2_sepDisjunct'_holds_of_honest` matches the §2.1 statement exactly; the corollary is
  `kvE2_sepBody_complete_holds' … (kvE2_sepDisjunct'_holds_of_honest …)`.
- [ ] No `hLR` assumed anywhere (exactly one `(hLR :` binder remains file-wide, inside the guard).
- [ ] F5 CLOSED/open key discrimination; LITMUS NS:437 no `x1 < e_i` literal; witness/segment bounds
  from the bracket range `x`/`w`/`t` and per-slot value specs only.
- [ ] Baseline caps hold (`grep -c`, LINE counts): `kvE_sub2_` == 107, `x1 <` == 73.
- [ ] Citation discipline D1/D2/D7 respected in all docstrings (PDF pages only; tie collapse forced
  by Def 3.1 (p.4); Lemma 3.2(1) states the closure without printed proof; `kvE2_sepAnchorDistinct`
  documented as a Lean-side `nf_eval_unique` pruning with no Rabinovich counterpart).

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/SharedWitness.lean` — additive
  only: the Phase-1 foundation (class-head value function + one-value-per-class), O1 lemma(s)
  (Phase 2), O2 lemma(s) (Phase 3), the O3 segment-eval family (Phase 4), the O3 gap discharge
  (Phase 5), the assembly helpers + the two public theorems `kvE2_sepDisjunct'_holds_of_honest` and
  `kvE2_sepBody_holds_of_honest` (Phase 6), all placed after SW:7789. NO existing declaration edited.
- `specs/337_.../plans/12_grouped-disjunct-holds-builder.md` (this file).
- `specs/337_.../summaries/12_grouped-disjunct-holds-builder-summary.md` (on completion).
- **Downstream**: task 335 consumes `kvE2_sepBody_holds_of_honest`.

## Rollback/Contingency

- ALL phases are additive to `SharedWitness.lean`. To revert any phase: delete the new
  declaration(s); the file returns to its post-342 green state with every LANDED asset untouched.
  There is no carrier edit to roll back.
- If Phase 4 (segment-eval family) cannot close within one agent run: land each family lemma as a
  standalone sorry-free green lemma and commit it, then continue with the remaining lemmas in a
  follow-on green sub-step. Never commit a bare `sorry`, a vacuous placeholder, or a segment eval
  modulo an assumed obligation.
- If Phase 2 (O1) discovers a class-order fact that neither the monotonicity route nor the value
  specs support (e.g. a cross-region slot value that the merged-list sortedness cannot bound), STOP
  and surface it — do NOT force a zone bound or introduce an `x1 < e_i` literal.
- If any step appears to require editing a LANDED declaration rather than adding a new one, STOP and
  surface it as a scope question; the task is ADDITIVE by construction and such a need signals a
  design error, not an authorized edit.
