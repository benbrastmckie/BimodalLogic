# Task 342 Phase 8 Handoff (sess_1783617988_38e7cf)

## Immediate Next Action

Phase 9 (tie-reporting honest order + `kvE2_sepBody_complete_holds'`), per the plan's Phase 9
section: (1) `kvE2_sepSlotHonestVIdx` (value-only rank over the honest slot-VALUE family,
`kvE2_ordRank` at SW:1219, no injectivity needed) + payload lemmas; (2) `kvE2_sepHonestOrder'`
(zipIdx over `kvE2_sepPosI`, all-`.coincident`, payload `block.map kvE2_sepSlotHonestVIdx`) +
`kvE2_sepOrderTypes` membership; (3) `kvE2_sepHonestOrder'_mem_arr'` (four conjuncts — see
"How Phase 8 feeds conjunct (iv)" below); (4) `kvE2_sepBody_complete_holds'` (report 07 §4
shape) + exit verification gate. Split escape 9.1/9.2 sanctioned by the plan if needed.

## Current State

- Phase 8 [COMPLETED] (plan heading + all three checklist items, deviations annotated).
- Full `lake build` green (1720 jobs). Only `SharedWitness.lean` touched (+1011 lines vs
  `1e5d3420c`). Commits: `5b981fee1` (8.1 F5 discharges), `f6c8368db` (8.2 infra),
  `1b53e0ff8` (8.3 literal-family helpers), `c1358bdeb` (8.3b marker-clean clone),
  `3679f26e4` (8.4 endpoint/pivot honesty lemmas), phase-complete commit follows.
- **Phase 8 (a) — F5 foreign-base CLOSED-key discharges** (all axiom-clean
  `{propext, Classical.choice, Quot.sound}`):
  - `kvE2_sepClosedLeafAt_discharge` (SW:3142) — placement-dispatched: for
    `σ ∈ kvE2_sepPosI qnf` realized at anchor `a` and any `χ` realized AT `a`,
    `kvE2_sepClosedLeafAt σ χ = true`. LEFT branch reads the CLOSED `kvE2_sep_zAtX1L` key
    via `kvE2_sepCoincidentAnchor_discharge`; RIGHT branch reads the CLOSED
    `kvE2_sep_zAtX1R` key via `_R`. Anchor bounds are read off σ's own `nf0_zoneSpec`
    ordering channel (no chain).
  - `kvE2_sepClosedLeafAt_discharge_honest` (SW:3360) — the instance at
    `kvE2_sepAnchorVal qnf M w x t h σ`. **This is the exact shape Phase 9's conjunct (iv)
    consumes.**
  - `kvE2_sepTieRead_of_discharge` (SW:3191) — intro rule for conjunct (iv): reduces
    `kvE2_sepTieRead wo = true` to the per-(anchor, base-χ) discharge obligation; base-base
    ties (non-anchor first slot, or anchor partner with `kvE2_sepSlotBaseType = none`) are
    machine-checked read-free.
- **Phase 8 (b) — endpoint/pivot honesty lemmas** (all axiom-clean):
  - `kvE2_sepEpL_eval_of_honest` (SW:7254), `kvE2_sepPtW_eval_of_honest` (SW:7315),
    `kvE2_sepEpR_eval_of_honest` (SW:7380). Hypothesis shape: honest `h`, `hxw`, `hwt`, plus
    char-semantics iffs `hcb : ∀ χ u, temporal_truth M atomMap u (charBase χ) ↔
    nf_eval_nf M 0 1 (fun _ => u) χ` and `hck` (depth-1 analog). These are the abstract form
    of `nfPred_correct` (`CarrierK1V.lean:1672` derives `hcb` for the concrete
    `nf_depth0_char_formula atomMap h_surj`); a depth-1 concrete `charK` instance must be
    supplied by the eventual consumer the same way.
  - Supporting infra (SW:6500-7250): `kvE2_sepProjFresh_eval` (SW:6583, PUBLIC — depth-1
    fresh-projection factor: realized owner at witness `v` gives
    `nf_eval_nf M 1 1 (fun _ => v) (nfk_projFresh σ)`; quant layer transports via
    `nf_characteristic` + `nf_eval_unique`), `kvE2_sepCharZone3` (characteristic zone
    computation), proj3/proj4 coordinate evals, four zone-fact readers,
    `kvE2_sepHasPos_of_realized`/`_witness` (σ-level bit intro/elim), five σ-level
    (`zPastX3`/`zAtX3`/`zAtW3`/`zAtT3`/`zFutT3`) and six per-owner
    (`zPastX4`/`zAtX4`/`zAtT4`/`zFutT4`/`zAtWL`/`zAtWR`) literal-family helpers.
- **Exit-gate audit**: guard `kvE2_sepHonest_hLR_absurd` VERBATIM (awk text diff vs
  `010527e6b` empty); exactly one `(hLR :` binder; `kvE2_sepPosI_eq_pos` 0 repo-wide;
  `x1 <` count 73 (unchanged); `kvE_sub2_` count **107** (unchanged — see below); axioms in
  Theories/ = 2 (baseline); vacuous-def scan 1 (pre-existing Examples baseline); 0 code
  sorries in SharedWitness/OuterGate; `ExistsForallNF.lean`/`NavigatedSpine.lean`/
  `OuterGate.lean` diff EMPTY vs `1e5d3420c`.

## F5 demonstration (the phase's defining obligation)

Every coincident/tie read in the new code routes through CLOSED self-zone keys only:
- LEFT foreign-base discharge: `kvE2_sepBits σ kvE2_sep_zAtX1L χ` (CLOSED), via the
  preserved `kvE2_sepCoincidentAnchor_discharge`.
- RIGHT foreign-base discharge: `kvE2_sepBits σ kvE2_sep_zAtX1R χ` (CLOSED), via `_R`.
- Base-base tie classes: NO read (machine-checked in `kvE2_sepTieRead_of_discharge` — the
  `none` base-type arm and the non-anchor guard arm close by `rfl`).
- The endpoint-honesty pack reads only boundary/exterior zones
  (`zPastX4`/`zAtX4`/`zAtT4`/`zFutT4`/`zAtWL`/`zAtWR`) — none is an OPEN interior key, and
  none is a coincident read.
- Marker hygiene: the pack references NO identifier with the `kvE_sub2_` prefix — the
  arity-4 zoneHolds cons-iff helper was cloned marker-clean as `kvE2_sepZone4_iff`
  (SW:6986, byte-identical content to `SubBracket2.lean:538`).

## How Phase 8 feeds Phase 9's conjunct (iv)

`kvE2_sepHonestOrder'_mem_arr'` conjunct (iv) = `kvE2_sepTieRead (kvE2_sepHonestOrder' …)`.
Route: apply `kvE2_sepTieRead_of_discharge`; for each anchor-involved payload tie
`(p anchor-slot sj, q base-slot sk of type χ)` with equal VIdx payloads, equal value-only
ranks give equal honest slot VALUES (the `kvE2_ordRank` payload lemma of Phase 9 task 1);
the anchor slot's honest value is `kvE2_sepAnchorVal qnf M w x t h p.1` and the base slot's
value realizes χ (the `kvE2_sepSlotValue_*_spec` family, consumed at SW:4519-4565), so χ is
realized AT the anchor value — exactly `kvE2_sepClosedLeafAt_discharge_honest`'s `hp`.
Owners of `kvE2_sepHonestOrder'` come from `kvE2_sepPosI`, so `hσI` is definitional
(`List.fst_mem_of_mem_zipIdx` + membership, as in the Phase 6/7 membership proofs).

## Gotchas carried forward (+ new)

- `<+`/`~` notations still do not parse in SharedWitness.lean — use `List.Sublist`/`List.Perm`.
- `rw` cannot rewrite under the `kvE2_sepTieRuns` match binder — `simp only` there.
- NEW: `Fin.cons`/`Fin.cases` at an index whose Nat literal is fine but whose PROOF is a
  postponed `by omega` METAVARIABLE does not whnf-reduce during unification — pass match-arm
  proof binders (`| ⟨0, hlt⟩ => exact f ⟨0, hlt⟩ …`) or bind the term with `have` first so
  tactic proofs are solved before the final `exact` (both idioms used throughout Phase 8 (b)).
- NEW: `(nfk_projFresh σ).2 sub` appears in goals as the beta-redex
  `(fun χ' => decide …) sub` — `rw (show … from rfl)` fails; `simp only [decide_eq_true_eq]`
  normalizes and rewrites in one step.
- NEW: `nf_characteristic`'s decide instance is `Classical.dec` — elaborating a fresh
  `decide (atom_eval …)` fails instance synthesis; pass it explicitly
  (`@kvE2_sep_decide_eq_of_iff _ (Classical.dec _) _ …`).
- MECHANICAL-GUARD note: any mention of an identifier prefixed `kvE_sub2_` (even a lemma
  name in a docstring) raises the F5 marker count. Keep new code referencing
  `kvE2_sepZone4_iff` and plain-text descriptions instead.
- The 340-task files (`specs/340_*/plans/03_*.md`, `working-progress-*.patch`) remain dirty
  from an unrelated session — do NOT stage them.
- FORBIDDEN (unchanged): PosI/Pos equality lemma; hLR-shaped hypothesis; `kvE2_sepPosI` as
  zone-filter append; weakening `IntervalPattern.holds` strictness; citing "per the proof of
  Lemma 3.2(1)" (audited form: "forced by Def 3.1; Lemma 3.2(1) states the closure without
  printed proof; corroborated by the k=m split (p.7) and Def 7.5 (p.13)").

## Sorry Inventory

(empty)
