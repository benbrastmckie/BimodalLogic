# Implementation Summary — Task 335: Outer-Gate Assembly Engine

- **Task**: 335 (lean4, BimodalLogic ProofChecker)
- **Plan**: specs/335_outer_gate_assembly_engine_kvE2_body/plans/01_outer-gate-assembly.md
- **Session**: sess_1783546987_0faeae_335
- **Status**: PARTIAL — Phase 1 delivered (green, axiom-clean, committed); Phases 2-4 BLOCKED.
- **Date**: 2026-07-08

## What was delivered

**Phase 1 (COMPLETED)** — the first LIVE outer-gate carrier, in a new isolated sibling file:

- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/OuterGate.lean` (new):
  - `bracketEndChar_kvE2` — `noncomputable def` producing `BracketEndCharCarrierV sig 2`,
    delegating to the task-334 faithful carrier `kvE2_sepBody` at the standard instantiation
    (`charBase = nf_depth0_char_formula atomMap h_surj`, `charK = fun χ => P.existF 0 χ`).
  - `bracketEndChar_kvE2_two_eq` — the `rfl` bridge exposing the carrier. Verified axiom-clean via
    `lean_verify`: `{propext, Classical.choice, Quot.sound}`, no `sorryAx`.
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge.lean` (aggregator): added the
  `OuterGate` import.

`lake build` of the `OuterGate` target is green. The file contains no `sorry`/`admit` and no
vacuous placeholder. The verified carrier INPUT (`SharedWitness.lean`) and `KampPrior.lean` are
byte-for-byte unmodified.

## What is blocked (Phases 2-4)

Phases 2 (⇒ soundness), 3 (⇐ left-interior completeness), and 4 (assembled k=2 gate correctness)
are **BLOCKED** on a single missing building block: the **joint multi-owner disjunct bracket
realization builder**.

Root cause (grounded): closing either direction requires the disjunct's `VecEA2.holds`
(`bracket.holds`, an `IntervalPattern.holds` over the merged per-owner slot lists
`kvE2_sepSlotsL/R qnf`). Task 334's carrier delivered the STRUCTURAL lemmas
(`kvE2_sepBody_holds_iff` collapse, `_extract`, order-type-level `_complete`/`_nonvacuous`/`_sound`,
per-σ `kvE2_sepBundleL/R`) but explicitly deferred the semantic multi-owner bracket-`holds`
construction (`SharedWitness.lean:1954`: "the general multi-owner pairwise discharge is the
completeness-side Phase-8 obligation"). The landed `holds` builders are per-σ / single-owner
(`kvE_subBracket2V_complete`) or the k=1 carrier (`bracketEndChar_k1v_complete`) and do not lift.

The intended foundation is the general region engine `k1v_sorted_realizationK`
(`SubBracket2V.lean:633`); a follow-on dispatch must wire it into the `kvE2_sepDisjunct`
slot/segment/endpoint layout (comparable in size to CarrierK1V's ~370-line
`bracketEndChar_k1v_complete`). See the per-phase BLOCKER entries in the plan for the concrete
unblocking path.

## Verification results

- `lake build Bimodal.…NfMultiAnchorBridge.OuterGate` — green.
- `lean_verify bracketEndChar_kvE2_two_eq` — `{propext, Classical.choice, Quot.sound}`, no `sorryAx`.
- Sorry census on delivered file — 0 live `sorry`/`admit`.
- Vacuous-definition scan — 0.
- New axioms — 0.
- `SharedWitness.lean` / `KampPrior.lean` — unmodified (grep-confirmed via `git status`).

## Faithfulness (F1-F7)

Phase 1 is a pure delegation to the verified carrier; it introduces no new semantic content and
therefore cannot regress F1-F7. No `x1 < e_i` relative-position literal, no open/closed zone-key
conflation, no vacuous placeholder introduced.

## Scope decisions (unchanged from plan)

- **R-A**: left-interior only (`hL` guard) — right-interior generalization is task 336.
- **R-B**: KampPrior.lean:351 wiring is a follow-on; not touched here.

## Plan Deviations

- **Task 3.x (altered → blocked)**: Phase 3's "build that disjunct's realization from
  `kvE2_sepHonestBundleL/R` + `kvE2_sepArr'_sound`" step assumed a composition of landed lemmas.
  Grounded investigation showed the joint multi-owner bracket-`holds` builder is un-landed
  (task-334 deferral), so Phases 2-4 are BLOCKED rather than completed. No sorry or vacuous
  placeholder was introduced (zero-debt honest RESCOPE).

## Follow-on recommendation

A dedicated task: "Joint multi-owner disjunct bracket-`holds` builder for `kvE2_sepDisjunct`" —
wire `k1v_sorted_realizationK` into the `kvE2_sepDisjunct` layout, then complete Phases 2-4 of this
plan. This is the true depth-k≥2 completeness rung; task 336 (right-interior) is orthogonal.
