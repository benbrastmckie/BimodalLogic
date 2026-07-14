# Task 358 — Phase 2 handoff (v05 plan): general-m G2 gate NO-GO / [BLOCKED]

**Session**: sess_1784054976_3cdaea · **Date**: 2026-07-14 · **Plan**: plans/05_realizer-recursion-v05.md

## Immediate next action

`/spawn 358` an isolated 363/364-style interface-refinement task: DEEP-anchor the exterior
fiber population to the ambient (depth-recursive on-fiber/content guard tying σ's marked
fibers' TAIL content to qnf's deep marking), and restate the rows-8-9 binders
(`hsliceFut`/`hslicePast`, EndIntervalConsumerK.lean:154-167) against it. Do NOT re-attempt
G2-1 (`kvE_{fut,past}SliceId_of_end` at general m) or the rows-8-9 supplies against the
current interface — machine-refuted (route R2, sorry-free).

## Verdict

**P2-0 = PASSED; general-m kernel gate = NO-GO ⇒ Phase 2 [BLOCKED].** Task 364's
co-realization strengthening fully dissolved the v04 planted-mate blocker (as plan v05
records), but a NEW, independent countermodel family — the all-honest **tail-doppelgänger**
— defeats the m=0 → general-m generalization one step later, inside the 364-strengthened
admissible population.

## What was executed (all green)

1. **P2-0 re-probe gate (route R2)** — PASSED. `lean_verify` at floor axioms
   `[propext, Classical.choice, Quot.sound]`, no sorryAx:
   `kvE_probe358_eP_atomMate_present` (still TRUE — historical record),
   `kvE_probe364_sigma2_inadmissible`, `kvE_probe364_sstar_honest_unrealizable`.
2. **P2-1 population check** — PASSED-WITH-ADVERSE-FINDING. The G2 supply population is
   realizer-derived exactly as report 08 §3 states (τ := `nf_characteristic` at the
   destructor endpoint; realizer `nf_characteristic_satisfies` in scope; admissibility via
   the sanctioned `kvE_futRealizer_admissible`). ADVERSE: the countermodel is
   realizer-derived too — carrying a realizer does not pin the realizer's TAIL.
3. **Route-R2 machine probe** (mandated before any kernel build): new additive leaf
   `Theories/.../NfMultiAnchorBridge/ExteriorPinnedProbe358TailK.lean`, GREEN
   (`lake build` 1024 jobs), both certificates `lean_verify` at floor axioms, zero guard
   unfoldings (source scan clean), zero production/frozen files touched (git audit).

## The decisive certificates (sorry-free, floor axioms)

Model `(ℤ, <)`, one predicate `R = {10}`; real pinned tuple `[x1,w,x,t] = [35,5,2,30]`;
fake tail `[40,12,8,25]` (depth-0 indistinguishable rows); walk point `32` in both gaps.

- `kvE_probe358_tailDG_gapItem_pinned_fails`: the honest depth-1 5-type `m3s` of `32` over
  the FAKE tail satisfies EVERY antecedent of the m=0 free-env → pinned upgrade
  (`kvE_futGapItem_pinned_zero` shape: gap-zoned, dropped row realized at the real tuple,
  free-env occurrence at `32 ∈ (30,35)`) yet is pinned-realizable at the real tuple at NO
  fresh witness (its marked inner `m3eR` demands an R-point in the real `(x,w) = (2,5)` —
  empty). This upgrade is the load-bearing step of BOTH zone-list inclusions of
  `kvE_futSliceId_of_end_zero` — the m=0 route does not generalize past depth-0
  losslessness (`nf_eval_nf0_cons_factor`; the codebase's own D7 doctrine).
- `kvE_probe358_tailDG_sigma_in_population`: the fake slice `m3sigma` (fully realized
  depth-2 4-type of the fake tuple) passes `kvE_futAdmissible` through the SANCTIONED
  byte-stable route `kvE_futRealizer_admissible`, sits on the REAL ambient's fiber
  (`nfk_dropFresh m3sigma = qnf.1` shape), and marks `m3s` on its Future gap zone list.
  Task 364's co-realization check has no purchase: no fake fiber, no plant — only a second,
  deeply-different but honestly realized environment.

## Binder-level closure (analytical — the escalation task's deliverable)

Per the v04 `kvE_probe358_eP_atomMate_present` precedent (decisive step machine-certified;
full universal documented): on a dense homogeneous order (ℚ; `R` a single point placed
fake-interior/real-interior discrepantly), the pure fake characteristic
`σ := nf_characteristic M (m+1) 4 (fake tuple)` fires the ENTIRE `hsliceFut` antecedent
stack at the real `t` — automorphism homogeneity collapses each fake exterior zone to a
single deep type; every real walked point IS a fake-gap point of the one fake tuple;
`x1_dest := x̃1` serves the endpoint description — while every qnf-marked σ' is a REAL-tail
characteristic whose gap types mark the R-point with the real coupling vector, never the
fake one, so `kvE_futSliceEq σ' σ = false` for all marked σ'. Rows 8-9 at m ≥ 1 are
FALSE-as-restated. Root cause: the clause family's item content
(`kvE_futItemShift`/`P.existF 4`) is intrinsically env-existential
(`kvE_futItemShift_correct : … ↔ ∃ env, …`), and no antecedent ties the marked fibers'
tails to the ambient beyond the depth-0 row `nfk_dropFresh σ = qnf.1`.

## What is needed (spawn target)

A depth-graded anchoring of the fiber population to the ambient — the "depth-recursive mate
CONTENT comparison" direction the v04 Phase-2 handoff already named as most promising and
which 364 (deliberately, for the plant family) did not take. Candidate shapes: (a) a
recursive on-fiber guard: σ's marked fibers' one-slot-dropped DEEP forms must be qnf-marked
one level down (hereditary fiber anchoring); (b) restate the rows-8-9 antecedents with a
deep on-fiber condition replacing `nfk_dropFresh σ = qnf.1`. Constraints: byte-stability of
the m=0 layer (`_zero` kernels + 360 supplies discharge through depth-0 inertness), k ≤ 1
rungs untouched, and the strengthened-guard routing rule (never unfold
`kvE_fiberElemConsistent`) preserved.

## Scope notes

- **G2-2 (`SliceUnique` at general m) is NOT refuted** by this cast (both σ's are pinned
  over the SAME real tail — no free env). Its honest proof needs a deep transfer kernel
  (EF-style exterior-chain matching; interior witnesses reused, exterior witnesses
  re-matched along the zone lists' accumulated type-chain). Build it only AFTER the
  interface refinement, since the population it quantifies over will be restated.
- **G1 (rows 5-6) untouched by this gate** — its antecedents are `igPtW`-guarded and
  ambient-realization-guarded; adjudicate separately after the interface repair.
- **Rows 10-11 (`hexclSlice*`)** consume `hreal` + uniqueness (G2-2) — downstream of the
  same restatement.

## Preserved / frozen (audited unchanged this session)

k≤1 arms, `kampPrior_case1_arm_k0`, task 350 carriers, task 360 m=0 supply + slice kernels,
task 363/364 predicate/guard/probes/discharge lemmas — zero edits (git status audit: the
only tree change is the additive probe leaf). KampPrior's two live sorries (`:519`, `:522`)
unchanged — NOT retired (blocked upstream on the rows-8-9 interface).

## Green landings this session (commit ff64b0f6f)

- `ExteriorPinnedProbe358TailK.lean` (additive probe leaf, 2 public certificates)
- plan v05 with Phase-2 BLOCKED record + checklist annotations
- report 08 (previously uncommitted artifact) landed
