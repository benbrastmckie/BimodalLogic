# Phase 7 Summary — Joint Carrier `kvE2_sepBody` + Non-Vacuity + Membership Collapse (O1 + O1b + O2)

- **Task**: 321 (lean4) — v7 plan `plans/07_v7-faithful-separate-bracket.md`
- **Session**: sess_1783487859_3f6358 (2026-07-07)
- **Phase executed**: 7 only (single-phase dispatch; phases 8-13 untouched)
- **Commits**: 5f3d4cdab (O1+O2), c9dcc0c0e (O1b), + wrap-up commit (umbrella import, plan updates)

## What Landed

NEW module `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/SharedWitness.lean`
(943 lines, purely additive) + ONE import line in the umbrella `NfMultiAnchorBridge.lean` (D1).

**O1 — the carrier.** `kvE2_sepBody charBase charK (qnf : NormalForm sig 2 3) : VVecEA2`:
model-independent joint separate-content carrier. Positive subs classified by outer zone
(`nf0_zoneSpec σ.1`, 7 zones incl. the shared-witness self-zone `zAtW3`); both interior
classes get tagged slot groups (`KvE2SepSlot` inductive, 8 constructors); disjuncts enumerate
joint interleavings (`kvE2_sepArrL/R` = permutations filtered by per-σ region-rank validity —
Lemma 3.2(1), md:77); one flat bracket per interleaving via the fresh N-slot builder
`kvE2_sepBracketN` with PER-INDEX refined-conjunction segment types (Cor 5.4); one shared
`ptW` slot (`kvE2_sepPtW`); joint `epL`/`epR` carry `qnf.1` endpoint 1-types + per-interior-σ
exterior/boundary literals + σ-level `Since`/`Until` navigation literals for the five
non-interior classes (Prop 3.5, LITMUS-clean); depth-2 gate `kvE2_sepGate` (outer off-fiber,
outer 7-zone consistency, inner off-fiber for all positives, inner 9-zone for left-interior
positives — verbatim `SubBracket2V.lean:1400-1408` pattern set) with empty-branch failure.

**O1b — non-vacuity.** `kvE2_sepBody_nonvacuous` (fresh analog of `SubBracket2V.lean:1425`):
honest depth-2 realization under `x < w < t` → gate holds (`kvE2_sepGate_holds_of_honest`,
consuming `nf_eval_depth1_fold_iff` + the landed per-σ honest gate lemma + a fresh arity-3
zone-consistency case bash `kvE2_sep_zone3_consistent`) → disjuncts non-empty (canonical
identity interleavings proven valid).

**O2 — membership collapse.** `kvE2_sepBody_holds_iff`: on the gate-true branch,
`(kvE2_sepBody …).holds M atomMap x t ↔ ∃ lL ∈ kvE2_sepArrL qnf, ∃ lR ∈ kvE2_sepArrR qnf,
(kvE2_sepDisjunct … lL lR).2.holds M atomMap x t` — a direct `dif_pos` +
`VVecEA2.holds_flatMap_map` instantiation (all builders/sets are top-level defs; the crux
failed-closer-3 `let`-burial defect cannot recur). Plus `kvE2_sepBody_gate_fail`.

## Verification Results

| Gate | Result |
|------|--------|
| `lake build` (full project, 1720 jobs) | green |
| `lean_verify` on `kvE2_sepBody_holds_iff`, `_gate_fail`, `kvE2_sepGate_holds_of_honest`, `kvE2_sepBody_nonvacuous` | exactly `[propext, Classical.choice, Quot.sound]` |
| Sorries in `SharedWitness.lean` / live path | 0 |
| Litmus grep (`fChainPred` / `x1 < e_i`) on `SharedWitness.lean` | 0 hits |
| Vacuous-definition scan | 0 |
| New axioms | 0 (non-Boneyard axiom count unchanged at 0) |
| `git diff --stat` | only `SharedWitness.lean` (new) + umbrella import + task artifacts |
| Do-not-edit assets | untouched (no 331-landed module edited) |

## Plan Deviations

- *(deviation: altered)* The plan's O1 sketch was silent on σ-placement; implemented outer
  seven-zone classification with mirrored right-interior slot groups and σ-level navigation
  literals for non-interior classes (recorded in the plan's Phase 7 completion note and the
  phase handoff). Inner nine-zone gate clause stated for left-interior positives only —
  right-interior extension deferred to Phases 8-10 arbitration (additive, file-internal).
- Line count 943 vs the 170-280 estimate: the honest-gate discharge (arity-3 zone
  consistency, drop-fresh transfer, canonical-arrangement validity plumbing) is proof mass
  the estimate did not account for; all of it is O1b-mandated (FM-vac).

## Sorry Inventory

Empty.

## Next

Phase 8 (O3): joint soundness extraction — shared `w` + per-σ bundles from a realized
disjunct via `kvE2_sepBody_holds_iff` + the Lemma 5.1 split kit. See
`handoffs/phase-7-handoff-20260707.md` for the landed API table and watch items.
