# Report 01 — Successor Carrier Redefinition (the 321-N2 named successor)

- **Task**: 346 — successor_carrier_redefinition
- **Type**: lean4 hard-mode research (H2/H3/H4/H5), `--lit` active
- **Session**: sess_1783782450_230288 (orchestrator dispatch, delegation depth 2)
- **Date**: 2026-07-11
- **Reference-grounding tier**: **Tier 1 (literature-backed)** — Rabinovich 2014, *A Proof of
  Kamp's Theorem*, ground truth (cited by PDF page only). Primary internal sources: task-335
  reports 04–07, archived task-330 report 01, and the live Lean tree
  (`OuterGate.lean`, `SharedWitness.lean`, `Prop43.lean`) at HEAD `cc319d626`.
- **Scope**: RESEARCH ONLY — no `.lean` edits, no state changes beyond status/handoff.

---

## Executive verdict (one line)

**RE-SCOPE, not hexcl-elimination.** The interior-singleton predicate repair (`kvE2_sepPosI`)
genuinely restores realizability and un-vacuates the fragment gate, AND the 344/345 machinery
survives the swap — but `hexcl` is the outer-forward *exterior-completeness* direction, which is
**not dischargeable on any currently-unblocked route** (report 07's two machine-probed
refutations + the independently-blocked `Prop43.lean`). The achievable, decision-complete
deliverable is a **re-scoped interior+boundary-complete conditional gate**: repair the predicate,
re-state the soundness half non-vacuously, and retain `hexcl` as an explicitly **boundary/interior-
restricted** obligation with full-exterior completeness *deferred* to a Prop-4.3-unblocking
successor. This is exactly the 330-audit RE-SCOPE fallback (report 01 §4 "Downstream Impact";
report 07 point 3).

---

## Critical correction to the task framing (H4-surfaced)

The task description says the route is "bit-compatibility filtering carrier redefinition (O4
SW:6763-6770)". **That carrier redefinition is ALREADY LANDED** and is not the open work:

- `kvE2_sepCompat` (the cross-σ bit-compatibility predicate, `SharedWitness.lean:951`) is defined
  and its four discrimination equalities (`kvE2_sepCompat_lX1_eq` etc., SW:988–1030) are proven.
- It **is wired** into the live arrangement-validity relation `kvE2_sepSlotLe`
  (`SharedWitness.lean:1035–1038`: `else kvE2_sepCompat a b`).
- The non-vacuity switch (joint model-sorted realization, the O1b obstruction the O4 record
  named) was completed by **task 334** (archived,
  `joint_slot_sorted_realization_nonvacuity_carrier_switch`); **task 333** (`completed`) landed
  the compat pair. The live `kvE2_sepBody` (SW:806) is the task-334 *faithful* carrier already
  running the bit-compatibility-filtered enumeration.

So "SW:6763-6770" is a **stale line reference** into the *proof body* of
`kvE2_sep_zone4_consistent`, not an open carrier obligation. The O4 CRUX RECORD proper lives at
**SW:6863–6960**; the bit-compat block at **SW:899–1035**. The genuinely-open work task 346 owns
is the **fragment-predicate repair + non-vacuous restatement + exterior-completeness re-scope** —
NOT re-plumbing the carrier arrangement.

---

## H3 Reference-Grounding — 5-column mapping table (Tier 1)

| Source claim | Source location | Lean target decl | Current state | Action needed |
|---|---|---|---|---|
| Global-singleton fragment is unrealizable (any realized qnf has ≥3 positive bits) | 335 report 07 Refutation 1; `nf_exists_unique` NormalForm.lean:276 | `kvE2_sepFragment` (`OuterGate.lean:200`), `kvE2_sepFragment_frag` (`SharedWitness.lean:10219`) | LANDED, VACUITY-flagged (both use global `kvE2_sepPos qnf = [σ0]`) | **Swap `kvE2_sepPos` → `kvE2_sepPosI`** at both sites (byte-identical to preserve defeq bridge, OuterGate:223–224) |
| Interior-restricted owner index (the intended N2 fragment) | 335 report 07 §"intended N2 fragment"; task 342 | `kvE2_sepPosI` (`SharedWitness.lean:211`), `kvE2_sepPosI_mem` (:216), `_zone`, `_subset` | LANDED, proven | Use as the new fragment carrier list; realizability verified (see H4 #1) |
| 3 forced positives are AT-POINT/boundary (zAtX/zAtW/zAtT), excluded by interior filter | Refutation 1 chain (x1=w/x/t characteristic forms); zone decode report 06 | `nf0_zoneSpec`, `kvE2_sep_zXW3`/`_zWT3` (interior) vs at-point zones | LANDED | none — this is the *reason* the interior filter dodges Refutation 1 |
| `hexcl` is the outer-forward (realized⇒marked) exclusion direction | fold body `SharedWitness.lean:10186–10191`, `:12626–12629` (`by_contra hne; exact hexcl …`) | `kvE2_outer_fold_frag` hexcl param (SW:12547–12554) | LANDED as hypothesis | **Cannot be discharged as-is** — re-scope to boundary/interior x1 |
| `hexcl` NOT dischargeable under any fold-interface enrichment | 335 report 07 Refutation 2 (satisfiable-set + category mismatch + factors) | `bracketEndChar_kv_factors` (`CarrierKv.lean:422`); `kvE2_sepSegForm_excludes` (SW:6683) | machine-confirmed NO-GO | Accept obstruction; defer exterior via re-scope |
| Exterior completeness requires Prop 4.3 navigated re-flatten | 330 report 01 §4; 335 report 07 point 1 (Rabinovich pp.6–7) | `Prop43.lean` (VVecEA_m, atomAt/ltAt) | **BLOCKED** — connective cases stuck (Prop43.lean:120–159, uniform-negation requirement) | Out of 346 scope; successor task |
| Symmetric gate clause (v) = zWT3 mirror of (iv) | 335 report 06 (Rabinovich Cor 5.4(1)/(2), p.9) | `kvE2_sepGate` clause (v) (SW:1238), `kvE2_sep_zone4_consistentR` (SW:11309) | LANDED (task 345) | none — survives swap untouched |
| Pin-anchored symmetric-gate machinery (hypothesis-carrying) | 335 report 05 §2; tasks 344/345 | `kvE2_sepGateAtPin_fragL/R`, `kvE2_sepBody_kit_sound_frag` (SW:12459), `kvE2_outer_fold_frag` (SW:12529) | LANDED, proofs genuine | **Verify survival** under predicate swap (see §Survival Audit) |
| ⇐ completeness half is unconditional | 335 Phase 2 | `bracketEndChar_kvE2_complete_two_prior` (`OuterGate.lean:139`) | LANDED, unconditional | none — untouched by swap |
| Provider correctness bridge (`hcorrK`) discharged at instantiation | 335 report 05 §2; 335 Phase B | `bracketEndChar_kvE2_hck` (`OuterGate.lean:115`) | LANDED | none — untouched |

---

## Decision-complete resolutions (H2 anti-analysis: the plan must be writable without reopening these)

### (a) The exact new fragment predicate definition

**Swap the carrier list from global `kvE2_sepPos` to interior-restricted `kvE2_sepPosI`.** New body
(identical at both `OuterGate.kvE2_sepFragment` and `SharedWitness.kvE2_sepFragment_frag`, to keep
the `rfl` defeq bridge intact — OuterGate:223–224):

```lean
def kvE2_sepFragment {sig : MonadicSignature} (qnf : NormalForm sig 2 3) : Prop :=
  ∃ σ0 : NormalForm sig 1 4, kvE2_sepPosI qnf = [σ0]
  -- zone disjunct now REDUNDANT: kvE2_sepPosI already filters to
  -- nf0_zoneSpec σ0.1 ∈ {kvE2_sep_zXW3, kvE2_sep_zWT3} (recover via kvE2_sepPosI_zone)
```

The old zone side-condition (`nf0_zoneSpec σ0.1 = zXW3 ∨ = zWT3`) is derivable from
`kvE2_sepPosI_mem`, so it may be dropped or kept (kept form is a strictly-provable redundancy; the
planner may retain it to minimize downstream proof churn where `hzone` is destructured, e.g. the
fold backward branch SW:12628–12633). **Realizability: verified High confidence** — see H4 #1.

### (b) The "carrier redefinition" (bit-compatibility filtering)

**No new carrier work.** The bit-compatibility-filtered arrangement (`kvE2_sepCompat` wired into
`kvE2_sepSlotLe`, SW:1035) and its non-vacuity (task 334 joint sorted realization) are LANDED. The
task-description phrase "carrier redefinition" is satisfied by the existing `kvE2_sepBody` (SW:806).
Task 346 touches **only** the fragment predicate and the soundness-half statement; `SharedWitness`
carrier internals stay frozen (341 frozen-file gate intact — the swap is a def-body edit to
`kvE2_sepFragment_frag` and the two branches that destructure it, both already `_frag`-banner code
below the 341 GATE marker at SW:10210–10212).

### (c) How `hexcl` is eliminated or restructured

**It is NOT eliminated — it is re-scoped.** `hexcl` (SW:12547–12554) consumes at the outer-forward
direction (`SharedWitness.lean:12626`: `rintro ⟨x1, hx1⟩; by_contra hne; exact hexcl …`) to prove
*realized-at-x1 ⇒ marked*. Machine-confirmed (report 07 Refutation 2, independently
`Prop43.lean` blocked): this is exterior-navigated completeness, underivable in the bracket
vocabulary. Two admissible restructurings; **recommend R1**:

- **R1 (recommended) — boundary-restrict the hypothesis.** Weaken `hexcl`'s `∀ x1 : M.carrier`
  to the interior+boundary cone `x ≤ x1 ≤ t` (or the six covered zones
  zPastX-excluded). Under this restriction `hexcl` IS discharargeable by the landed biconditional
  endpoint/witness literals (`kvE2_sepEpL`/`EpR`/`PtW`/`PtX1L` — the "six at/exterior inner zones in
  BOTH directions", O4 record SW:6702–6704) + `kvE2_sepSegForm_excludes` (SW:6683) on the interior
  segments. The theorem then delivers an **interior+boundary-complete** k=2 gate. Full-exterior
  `hexcl` (over all x1) is documented as the deferred obligation.
- **R2 (fallback) — retain full `hexcl`, prove premise-set satisfiability.** Keep the signature but
  replace the VACUITY NOTE with a **realizability witness lemma** exhibiting a qnf/M with all
  premises jointly satisfiable (so the theorem is a genuine non-vacuous conditional), and hand 309
  the full `hexcl` as an explicitly-flagged deferred obligation. Weaker: 309 still cannot discharge
  it, so R2 only un-vacuates, it does not unblock the consumer. Prefer R1.

**The exterior obligation is the true residue** and it is a *separate* blocked problem (Prop 4.3),
NOT task 346's to solve. Task 346 delivers everything reachable and cleanly quarantines the
exterior gap.

### (d) Survival audit of 344/345 symmetric-gate machinery under the predicate swap

The fragL/fragR/kit/fold are **hypothesis-carrying**: they take `hfrag : kvE2_sepFragment_frag qnf`
and `hexcl` as *parameters* and destructure `hfrag` only where the singleton structure is used.
Swap impact, decl by decl:

| Decl (SharedWitness.lean) | Uses `hfrag` how | Survives swap? |
|---|---|---|
| `kvE2_sepGateAtPin_fragL` / `_fragR` | via `kit_sound_frag`; pin extraction is zone-gated, not list-gated | **YES** — no direct `kvE2_sepPos` destructure |
| `kvE2_sepBody_kit_sound_frag` (SW:12459) | threads `hfrag` to the pin producers | **YES** — pass-through |
| `kvE2_outer_fold_frag` (SW:12529) backward branch (SW:12603–12633) | `obtain ⟨σ0, hpos, hzone⟩ := hfrag; rw [hpos] at hmem; List.mem_singleton` | **NEEDS REPAIR** — `hmem : σ ∈ kvE2_sepPos qnf` (global) no longer equals the singleton once `hpos : kvE2_sepPosI qnf = [σ0]`; a *non-interior* positive is now possible, so the `exfalso` non-interior branch (SW:12628–12633) is no longer vacuous |
| `kvE2_outer_fold` (non-frag, SW:10186–10191) | same forward/backward shape | mirror repair if it is on a live path (verify; it may be the pre-345 variant) |

**The one genuine proof-repair** is the fold backward branch: with `kvE2_sepPosI qnf = [σ0]`, a
positive σ splits into (i) interior → σ = σ0, served by `hLreal`/`hRreal`; (ii) boundary/exterior
→ NOT σ0, needs a realization channel. Under R1 (interior+boundary re-scope), boundary positives
are realized by the endpoint/witness biconditional literals (`kvE2_sepEpL`/`EpR`/`PtW`); exterior
positives are the deferred residue (either excluded by an added fragment clause or carried as the
deferred obligation). **This branch is where the plan's main derivation work sits (~150–300 lines).**
Everything else (clause (v), the pin machinery, `hcorrK` discharge, the ⇐ half) is inert under the
swap. Symmetric gate clause (v) is Rabinovich-faithful (Cor 5.4, p.9) and untouched.

### (e) Non-vacuous re-statement of `bracketEndChar_kvE2_sound_two_prior_frag`

Target (`OuterGate.lean:245`): identical signature EXCEPT (1) `hfrag : kvE2_sepFragment qnf` now
carries the *interior-singleton* predicate (realizable → premise set satisfiable), and (2) under
R1, `hexcl`'s binder is `∀ x1, x ≤ x1 → x1 ≤ t → …` (boundary/interior cone). The derivation body
(lines 268–273: `rw [bracketEndChar_kvE2_two_eq]; exact kvE2_outer_fold_frag …`) is **unchanged
modulo the fold's repaired backward branch** — it is a genuine proof from its hypotheses, expected
to survive (335 report 07 explicitly certifies "the derivation itself … is expected to survive a
fragment-predicate repair"). Replace both VACUITY NOTEs (OuterGate:192–199, :236–244) with a
NON-VACUITY note citing the realizability witness + the deferred-exterior scope.

---

## Adversarial Self-Verification

I actively tried to refute the RE-SCOPE verdict — hunting for (i) a reading where interior-singleton
is *also* unrealizable (forcing full abandonment), and (ii) a reading where `hexcl` *is* dischargeable
after the swap (making the gate fully hexcl-free). Both hunts failed; the verdict holds.

### Claim Verification Table

| Claim | Source/Counterexample | Verification method | Confidence |
|---|---|---|---|
| Interior-singleton `kvE2_sepPosI qnf = [σ0]` IS realizable (Refutation 1 does not apply) | Tried: is one of the 3 forced positives (x1=w/x/t) interior? | The 3 forced characteristic forms sit at x1=w/x/t = AT-POINT zones (zAtW/zAtX/zAtT), while `kvE2_sepPosI` filters to `nf0_zoneSpec ∈ {zXW3, zWT3}` = strictly-interior (`SharedWitness.lean:211` def read). Interior filter EXCLUDES all 3 forced positives ⇒ Refutation 1's ≥3-bit argument is silent on PosI. A model with x<w<t and exactly one strictly-interior realized 1-type satisfies the singleton. | **High** |
| The 3 forced positives are boundary, not interior | Tried: could x1=w be interior-zoned? | x1=w means fresh point = witness ⇒ `zAtW` (at-point), which is neither `zXW3` (x<x1<w) nor `zWT3` (w<x1<t). Report 06 zone decode confirms the 9-cell trichotomy separates at-point from open-interval cells. | **High** |
| `hexcl` (full, ∀x1) is NOT dischargeable after the swap | Tried: does interior-singleton constrain exterior negatives? | Report 07 Refutation 2: exterior arrangements (x1<x, x1>t) realize depth-1 types separated only by navigation; `bracketEndChar_kv_factors` (CarrierKv:422) certifies the bracket carries only (outer-zone, projected-1-type); satisfiable-set argument (all threadable facts hold in the same model as `hreal`). The interior filter constrains *interior* owners only — exterior is orthogonal. Independently: the exterior route (Prop 4.3) is itself blocked (`Prop43.lean:120–159`). | **High** |
| The bit-compatibility carrier redefinition is ALREADY landed (not open work) | Tried: is `kvE2_sepCompat` actually wired, or still staged as the SW:899 comment says? | The SW:899 "STAGED, not yet wired" comment is task-333-Phase-1-era; `kvE2_sepSlotLe` (SW:1035–1038) NOW reads `else kvE2_sepCompat a b`. Task 333 = `completed`; task 334 (carrier switch) = archived. The live `kvE2_sepBody` is the filtered carrier. | **High** |
| The 344/345 fold survives the swap except the backward branch | Tried: does any pin/gate producer destructure `kvE2_sepPos` directly? | Grep of `_frag` chain: only `kvE2_outer_fold_frag` backward branch (SW:12603–12633) does `rw [hpos] at hmem` + `List.mem_singleton`; pin producers and `kit_sound_frag` pass `hfrag` through. Clause (v) keys on zone, not the list. | **Medium-High** (grep-level; a full `lake build` after the edit is the confirmatory check) |
| The fold backward branch needs a real repair (not mechanical) | Tried: is the non-interior `exfalso` still vacuous under PosI? | With `kvE2_sepPosI qnf = [σ0]`, a positive σ that is boundary/exterior is NOT in PosI, so `hmem` (global membership) no longer forces σ=σ0; the `exfalso` at SW:12628 loses its contradiction. Boundary positives are forced-realizable (endpoint literals) ⇒ a genuine new sub-proof. | **High** |
| RE-SCOPE (interior+boundary) is what the landed assets already deliver | 330 report 01 §"Downstream Impact" RE-SCOPE fallback; 335 report 07 point 3 | Both name "interior + boundary fragment via task 326 + epL/epR/ptW, deferring exterior-navigated completeness"; the ⇐ half (OuterGate:139) + interior kit are landed. | **High** |
| Full-exterior hexcl-free gate is NOT achievable on any unblocked route | Tried: any non-Prop-4.3 path to exterior completeness? | Report 07 exhausts fold-interface enrichment (NO-GO); `Prop43.lean` exhausts the navigated route (BLOCKED on uniform-negation). No third channel exists in-tree. | **Medium-High** |

### Contradiction log

**One reframing (not a contradiction).** The task title and description present task 346 as "the
bit-compatibility filtering carrier redefinition." Primary-source inspection shows that redefinition
is *already landed* (333/334); the open work is the fragment-predicate repair + exterior re-scope.
Resolution by precedence (live tree > task-description line refs): the stale `SW:6763-6770` reference
points into proof-body, and the O4 record's "carrier redefinition" recommendation was fulfilled by
333/334. No load-bearing conclusion changes — the deliverable set (predicate swap, non-vacuous
restatement, hexcl handling, survival audit) is exactly as scoped; only the *characterization* of
the remaining work is corrected.

**Recommendations modified after verification.** Initial instinct was "interior-singleton swap fully
un-blocks 335 Phase B." Verification showed the swap un-*vacuates* but does not make the gate
hexcl-free; the exterior residue is a distinct blocked problem. Downgraded the deliverable from
"hexcl-free gate" to "re-scoped interior+boundary-complete conditional gate + deferred-exterior
successor."

### Completeness confidence

**Medium-High.** Every load-bearing file:line was read this dispatch against HEAD `cc319d626`. The
one Medium-High residual (survival of the full `_frag` chain) is a `lake build` confirmation the
implementer runs after the def-body edit — the grep-level audit found exactly one branch needing
real repair. The realizability correction (interior filter dodges Refutation 1) is the pivotal
finding and is High confidence by direct zone-decode.

---

## Recommended plan shape (for the planner)

- **Phase 1 — predicate repair (OuterGate + SharedWitness, ~80–150 lines).** Swap
  `kvE2_sepPos` → `kvE2_sepPosI` in `kvE2_sepFragment` (OuterGate:200) and
  `kvE2_sepFragment_frag` (SW:10219), byte-identical. Add a realizability witness lemma
  (interior-singleton is satisfiable by a concrete qnf/M). Rebuild; axiom-clean
  {propext, Classical.choice, Quot.sound}.
- **Phase 2 — fold backward-branch repair + hexcl re-scope (SharedWitness, ~150–300 lines; the
  main work).** Repair `kvE2_outer_fold_frag` backward branch (SW:12603–12633) for boundary
  positives via `kvE2_sepEpL`/`EpR`/`PtW` literals; boundary-restrict `hexcl` (R1). Verify
  `kvE2_sepBody_kit_sound_frag` / pin producers unchanged.
- **Phase 3 — non-vacuous restatement + handoff (OuterGate, ~80–150 lines).** Re-state
  `bracketEndChar_kvE2_sound_two_prior_frag` (OuterGate:245) against the repaired predicate and
  re-scoped `hexcl`; replace both VACUITY NOTEs with NON-VACUITY + deferred-exterior notes.
  Handoff note for 309 Phase 13.4/14 + `KampPrior.lean:351`: consume the interior+boundary gate;
  the exterior obligation is the named successor.
- **Constraints**: no sorries on live paths; H7 territory = OuterGate.lean + the `_frag` banner
  region of SharedWitness (below SW:10210, 341-GATE-clean); no `x1 < e_i` positioning literal
  (LITMUS); Rabinovich cited by PDF page only.
- **Explicitly OUT of scope (successor task)**: full-exterior completeness via Prop 4.3
  (`Prop43.lean` blocked on the uniform-negation connective cases — a distinct major effort).

## Consumers

- **task 309** Phases 13.4/14 + `KampPrior.lean:351` strategic sorry — consume the re-scoped
  interior+boundary gate; do NOT expect a full-exterior hexcl-free gate from 346.
- **task 335** Phase D — the assembled correct gate, interior+boundary-scoped.

## Grounding index

335 reports 04–07 (`specs/335_outer_gate_assembly_engine_kvE2_body/reports/`); 330 report 01
(`specs/archive/330_k2_carrier_faithfulness_audit_and_correct_fold_representation/reports/01`);
Lean HEAD `cc319d626`: `OuterGate.lean`, `SharedWitness.lean` (:211, :899–1035, :6863–6960,
:10210–10240, :12459–12634), `Prop43.lean` (:111–168), `CarrierKv.lean:422`; Rabinovich 2014 PDF
pp.4–9 (Def 3.1, Prop 3.5 p.5, Prop 4.2/4.3 p.6, Lemma 5.1 p.7, Cor 5.4 p.9).
</content>
