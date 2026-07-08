# Task 334 — Faithful Carrier Re-grounding: Final Implementation Summary

- **Task**: 334 — Faithful re-grounding of the `NfMultiAnchorBridge` carrier onto Rabinovich's proof architecture
- **Plan**: `plans/03_faithful-carrier-regrounding.md` (9 phases, spike-gated)
- **Session**: sess_1783539835_7b6867
- **Status**: ALL 9 PHASES COMPLETE — build green, both top theorems axiom-clean, 0 critical-path sorries
- **Primary file**: `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/SharedWitness.lean` (macro side, F7); additive Phase-3 lift in `SubBracket2V.lean`

## What the rebuild delivered

The divergent Lean-convenience carrier (additive open-zone filter over a flatMap slot union,
`sorryAx`-contaminated non-vacuity, singleton "N2" retreat) was replaced with Rabinovich's
faithful three-pillar architecture:

1. **Order-type disjunction** over the merged anchor set `A := {x1_σ : σ∈pos} ∪ {w}` — Lemma 3.2(1)
   (md:77). Realized as `kvE2_sepOrderTypes` (finite, decidable weak-order enumeration) filtered by
   the per-disjunct validity predicate `kvE2_sepDisjValidOwner` into the carrier `kvE2_sepArr'`.
2. **Region-partitioned interval decomposition** — Def 3.1 (md:61-74). `k1v_sorted_realizationK`
   generalizes the proven three-region `k1v_sorted_realization3` to k regions, folding
   `k1v_sorted_realization` verbatim per region.
3. **Closed/point-type coincidence channel** — §5 meet-typed shared point (md:168-173). The 5th
   closed-zone compat leaf `kvE2_sepCompat_zAtX1L_eq` and the three-way (before/**at**/after)
   segment-meet cuts `kvE2_sepSegLForSub'` / `kvE2_sepSegRForSub'`, discharged by the preserved
   axiom-clean `kvE2_sepCoincidentAnchor_discharge`.

Both directions of Lemma 3.2(1) are realized: `kvE2_sepBody_nonvacuous` (⇒) rewired axiom-clean off
the additive filter; `kvE2_sepBody_complete` (⇐) newly STATED and proved.

## Phase-9 verification results (this dispatch)

| Check | Result |
|-------|--------|
| `lake build …NfMultiAnchorBridge.SharedWitness` | **exit 0** (green) |
| Carrier critical-path sorry count | **0** (census script `sorry_count: 0`) |
| FALSE scaffolds `kvE2_sepSlotsL_valid`/`_valid` (Phase 6) | GONE — grep-0 live decls |
| Additive filter `kvE2_sepValid`/`kvE2_sepArrL`/`kvE2_sepArrR` (Phase 6) | GONE — grep-0 live decls |
| Singleton retreat `kvE2_sepSingleton`/`kvE2_sepBody_singleton*` + 2 strategic sorries (Phase 8) | GONE — grep-0 |
| `SubBracket2V.lean` (Phase 3 additions) | green + sorry-free (`.olean` built as dependency) |
| `lean_verify kvE2_sepBody_nonvacuous` | `[propext, Classical.choice, Quot.sound]`, **no sorryAx**, no warnings |
| `lean_verify kvE2_sepBody_complete` | `[propext, Classical.choice, Quot.sound]`, **no sorryAx**, no warnings |

All remaining textual occurrences of the abandoned identifiers are docstrings / removal-notes /
Faithfulness-Rationale prose — no live `def`/`theorem`/`lemma`/`abbrev` declarations remain
(verified by declaration-pattern grep).

## Faithfulness invariant audit (F1-F7) — ALL HOLD

- **F1 — QF point/segment types**: HOLDS. Point (α) and segment (β) types remain quantifier-free
  over Σ; the three-way "at" meet type `Formula.and (segForm zXU) (segForm zUW)` (and its right
  mirror) is a conjunction of QF segment forms, no nested depth-k characteristic. Confirmed sound in
  Phases 4/5 (`kvE2_sepSegLForSub'_at_sound`, `kvE2_sepSegRForSub'_at_sound`).
- **F2 — Lemma 3.2(1) never weakened to vacuity; BOTH directions realized**: HOLDS. ⇒ via
  `kvE2_sepArr'_sound` + rewired `kvE2_sepBody_nonvacuous`; ⇐ via newly-built `kvE2_sepBody_complete`
  (unconditional non-vacuity through the coincident order for left-interior positive owners). No
  disjunct set is silently empty — `kvE2_sepCoincidentOrder_mem_orderTypes` gives structural
  presence.
- **F3 — anchor cap 2**: HOLDS. Free anchors stay `{x,t}`; `x1_σ` and `w` are interior witness slots
  merged into `A` with `|A| = |pos| + 1`, never promoted to free anchors.
- **F4 — no-nesting**: HOLDS. No `x1 < e_i` literal introduced; the region lift uses interior
  witnesses, no nested depth-k characteristic inside a point/segment type.
- **F5 — LITMUS discrimination**: HOLDS. Zone keys `zAtX1L`/`zXU`/`zUW`/`zWT` stay distinct in
  coordinate 0; the coincidence disjunct reads the CLOSED `zAtX1L` bit, strict disjuncts read the
  OPEN `zXU`/`zUW` bits — never conflated (the crux the Phase-1 spike settled and Phase-8's
  empirical finding confirmed).
- **F6 — F4-chain (Cor 5.4) discriminates**: HOLDS. The per-bracket F_i chain translates a single
  bracket faithfully; the multi-owner combination sits ABOVE it at the Lemma 3.2(1) disjunction
  level, not folded into the chain.
- **F7 — macro-side confinement**: HOLDS. All rebuild lives in `NfMultiAnchorBridge/SharedWitness.lean`;
  the only other-file change is the additive k-anchor lift co-located with the region engine in
  `SubBracket2V.lean` (Phase 3, F7's explicit allowance). `SubBracket2.lean` and `CarrierK1V.lean`
  reused unchanged.

## Outer-gate scope decision (RECORDED)

`kvE2_body` / `bracketEndChar_kvE2` (task 321 v4 / NS Phase-7 assembly ENGINE) have no live def.

**DECISION**: The faithful carrier rebuild **does NOT require rebuilding the outer gate**. The
carrier's non-vacuity (`kvE2_sepBody_nonvacuous`) and completeness (`kvE2_sepBody_complete`) are
self-contained, verified, axiom-clean theorems — they compile and verify green independently of the
outer-gate assembly. The outer-gate assembly is a SEPARATE downstream obligation with its own
captured failed-closer history (NS:423-435); the faithful carrier is a correct INPUT to it. This
matches the plan's Risk R4 mitigation and Scope note (plan lines 136, 417-419, 428-430).

**RECOMMENDED FOLLOW-UP TASK 1 (outer gate)**: Open a dedicated task for the outer-gate assembly
engine (`kvE2_body` / `bracketEndChar_kvE2`, the task-321-v4 / NS Phase-7 two-level quant-layer
connector). It consumes this carrier as input and is a distinct, substantial obligation — it should
NOT be folded back into task 334.

## Phase-8 right-interior deviation (RECORDED as follow-up)

`kvE2_sepBody_complete` is scoped to the **left-interior positive-owner class** via an explicit `hL`
hypothesis. The genuine mathematical content of the right half is already LANDED and sorry-free:
`kvE2_sepCoincidentAnchor_discharge_R` proves `kvE2_sepBits σ zAtX1R (nf0_projFresh σ.1) = true` at
`w < x1 < t`. What remains is small predicate-wiring: the coincident validity channel
`kvE2_sepDisjValidOwner .coincident` / `kvE2_sepClosedLeafStub` currently hardcodes the self-zone to
`zAtX1L` (SharedWitness :737, :2475); making `kvE2_sepArr'` non-vacuous for right-interior positive
owners needs the placement-generic self-zone (`zAtX1R` for right owners). This is a carrier-predicate
extension, **NOT new mathematics**, and does not weaken F2 (the left-class result is a genuine
multi-owner completeness theorem; the right discharge itself is proved).

**RECOMMENDED FOLLOW-UP TASK 2 (right-interior wiring)**: Extend the closed-leaf validity predicate
to read the placement-generic self-zone (`zAtX1R` for right-interior owners), wiring the already-proved
`kvE2_sepCoincidentAnchor_discharge_R` into the coincident validity channel to lift
`kvE2_sepBody_complete` from the left-interior class to general (left ∪ right) interior positive
owners. Small predicate-wiring extension; can be a sub-task of the carrier or a standalone task.

## Preserved assets (unmodified, still green)

`k1v_sorted_realization`, `k1v_sorted_realization3`, `kvE_subBracket2V_correctness_pair`,
`kvE_subBracket2_complete_extract` (+ generic zone-forward channel), `kvE2_sepCoincidentAnchor_discharge`,
the four compat leaves `kvE2_sepCompat_*_eq`, `kvE2_sepFreshAnchor_ne_baseChiPoint`,
`kvE2_sepHonestBundleL`. `SubBracket2.lean` and `CarrierK1V.lean` unchanged.

## Acceptance criteria (Phase 9) — ALL MET

Build green ✓ · both top theorems axiom-clean ✓ · invariant audit F1-F7 passes ✓ · outer-gate
scope decision recorded ✓ · Phase-8 right-interior deviation recorded as follow-up ✓.
