# Implementation Plan: Off-Diagonal Two-Anchor F_i Chain (task 309) — v9

> **Revision provenance (v9, 2026-07-11, session sess_1783796165_b5b482_309).** Revised from v8
> (plans/08_offdiag-fi-chain-v8.md) to realign against the **now-LANDED provider tasks 335 and
> 348**, both of which completed in this orchestration session and left handoffs addressed to this
> reviser:
> - `specs/335_outer_gate_assembly_engine_kvE2_body/handoffs/03_frag-gate-for-309-and-348.md` —
>   the k=2 interior+boundary GO gate `bracketEndChar_kvE2_correct_two_prior_frag`
>   (`OuterGate.lean:359`, commit `147af2fbe`, axiom-clean), the `kvE2_sepPosI` provider contract
>   (`hrealI`/`hrealB`/`hexcl` shapes, `OuterGate.lean:374/:380/:387`), and the **∀k-lift
>   composition flag** (§5) this v9 resolves below.
> - `specs/348_prop43_exterior_reflatten/handoffs/02_enriched-gate-for-309.md` — the **enriched
>   composed gate** `bracketEndChar_kvE2Ext_correct_two_prior_frag`
>   (`Kamp/NfMultiAnchorBridge/ExteriorBracket.lean`, on the live import path), in which the
>   exterior residue `hexclExt` is **discharged internally** (GONE from the hypothesis inventory);
>   only 309-owned hypotheses remain (`hfrag`/`hrealI`/`hrealB`/`hexcl` + six order bits +
>   `h_UZ`/`h_SZ`).
> - **Ownership transfer (348 R1 scope decision — SETTLED, do not re-open)**: task 348 DEFERRED the
>   `KampPrior.lean:351` strategic-sorry retirement to task 309 (348 plan §"R1 Scope Decision";
>   inline transfer note now at `KampPrior.lean:352-360`, the sorry itself at **`:361`**, the
>   `| 1 =>` arm of `nf_nvar_exist_all_depths`). **This v9 owns that retirement explicitly**
>   (Phases 18-19). The `| n+2 =>` sorry at `:364` (the historical ":354") stays — task 305 scope.
>
> The v8 gating premise — "Phases 13.4/14 GATED on task 348's definition-of-done, which itself
> retires `:351`" — is OBSOLETE in both directions: the gate condition is now MET (348 complete),
> and the `:351` close it attributed to 348 is now 309's own deliverable. v9 re-decomposes the
> remaining work into Phases 15-19 (each one H8-bounded agent run) and retires v8's Phases 13.4/14
> as written (see the v8 → v9 Phase Mapping). All completed phase work is preserved verbatim in
> the repository history and carried here as compact records with pointers to v8 (the same
> compaction discipline v8 applied to v6/v7 content).

- **Task**: 309 - offdiag_two_anchor_fi_chain
- **Status**: [READY — all provider dependencies landed (335 complete, commit 147af2fbe; 348 complete, 8/8 phases; 346/347 landed earlier); open Phases 15-19; Phase 15 is the dispatch entry]
- **Effort**: ~12-20 hours remaining (Phases 15-19; ~800-1600 lines of Lean total, each phase one H8-bounded agent run)
- **Dependencies**: 310 (COMPLETE — E[Σ]-fold); 311 (COMPLETE — k=1 V-carrier GO); 320, 333 (carried, landed); 335 (**COMPLETE** — k=2 interior+boundary fragment gate + provider contract); 346 (COMPLETE — successor carrier redefinition); 347 (COMPLETE — bracket-faithfulness adjudication + R1); 348 (**COMPLETE** — adjacent-exterior bracket + enriched composed gate; `:351` retirement transferred BACK to 309 per its R1 decision)
- **Research Inputs**:
  - reports/01_offdiag-fi-chain-research.md (H4-verified, Tier 1; outer wrapper + import DAG)
  - reports/02_endpoint-hook-discharge-research.md (background only — superseded by report 03)
  - reports/03_rabinovich-faithful-path-research.md (Path B carrier reformulation authority)
  - reports/04_spawn-analysis.md (v4 revision authority — R2 NO-GO root-cause; tasks 310/311)
  - reports/05_k2-vocab-enrichment-redesign.md (v6 revision authority; §c contingency realized by 13.25)
  - reports/07_unblock-assessment-post-333.md (gating history; superseded by the 335/348 landings)
  - `specs/347_rabinovich_bracket_faithfulness_review/reports/01_bracket-faithfulness-adjudication.md` (v8 revision authority — verdict (b): interior+boundary + adjacent-exterior model, seam at `x,t`)
  - **`specs/335_outer_gate_assembly_engine_kvE2_body/handoffs/03_frag-gate-for-309-and-348.md`** (**v9 revision authority** — the landed k=2 fragment gate, the provider contract, the ∀k-lift flag)
  - **`specs/348_prop43_exterior_reflatten/handoffs/02_enriched-gate-for-309.md`** (**v9 revision authority** — the enriched composed gate consumption guide; hypothesis inventory; R1 transfer)
  - `specs/348_prop43_exterior_reflatten/plans/01_prop43-exterior-reflatten.md` §"R1 Scope Decision" (the `:351` ownership transfer rationale — settled)
- **Artifacts**:
  - plans/01-03, 05-07 (v1-v7, superseded — lineage recorded in v8 §Overview)
  - plans/08_offdiag-fi-chain-v8.md (v8, superseded — its 13.4/14 gating premise obsoleted by the 335/348 landings and the 348 R1 transfer; its history sections remain the verbatim record for Phases 1-13.35)
  - plans/09_offdiag-fi-chain-v9.md (this file, v9)
- **Standards**:
  - .claude/rules/artifact-formats.md
  - .claude/rules/state-management.md
  - .claude/rules/plan-format-enforcement.md
  - .claude/context/formats/plan-format.md
- **Type**: lean4 (hard-mode; H8 phase sizing, postmortem constraints, wave declarations)
- **reports_integrated**: 01_offdiag-fi-chain-research.md, 02_endpoint-hook-discharge-research.md, 03_rabinovich-faithful-path-research.md, 04_spawn-analysis.md, 05_k2-vocab-enrichment-redesign.md, 347/reports/01_bracket-faithfulness-adjudication.md, 335/handoffs/03_frag-gate-for-309-and-348.md, 348/handoffs/02_enriched-gate-for-309.md

## ∀k-Lift Composition Decision (resolves the 335 handoff §5 flag — SETTLED by this v9)

The 335 handoff flagged for this reviser: *"the k=2 gate is conditional on `kvE2_sepFragment qnf`
(plus the provider obligations), while the k ≤ 1 rungs (`bracketEndChar_kv_correct_zero_prior` /
`_one_prior`) are unconditional. The lift's induction must either (a) restrict the k=2 induction
step to fragment `qnf` (and route non-fragment `qnf` through the 321-N2 successor), or (b) thread
the fragment hypothesis + the provider obligations through the `Nat.rec`."*

**Decision: option (a) — restrict the k=2 induction step to fragment `qnf`; route non-fragment
`qnf` (if any arise at the site) through the 321-N2 successor.** Rationale:

1. **Interface stability (decisive).** `nf_nvar_exist_all_depths`'s statement is consumed by its
   own `n = 0` arm, by `nf_nvar_exist_all_depths_fn(_correct)` (KampPrior:367/:375), and by the
   main Kamp theorem downstream. `kvE2_sepFragment qnf` is per-`qnf` data over the arity-3 subs
   that only come into existence INSIDE the `| 1 =>` construction (after the trichotomy split +
   flatten of the given `sub_nf`). It is not expressible as a top-level hypothesis of the theorem
   without quantifying it over all subs of all `sub_nf` — which would weaken the theorem for
   every consumer and break the seam with the unconditional k≤1 rungs. Option (b) is
   shape-incoherent at the interface, not merely inconvenient.
2. **Forward-compatibility.** Per the 335 handoff §4, `hrealI`'s interval-bounded jointly-ordered
   shape is already stated so that the full-`On` generalization (the 321-N2 successor: carrier
   redefinition with bit-compatibility filtering, O4 SW:6763-6770) only extends the index list,
   not the binder shape. Under (a), the fragment triage at the induction step widens IN PLACE
   when 321-N2 lands — no re-shaping of the recursion, no consumer churn.
3. **House precedent.** The 13.1 A1 amendment put provider conditionality in the carrier
   correctness PREDICATE (`BracketCarrierCorrectVPrior`), never in the outer recursion. (a)
   repeats that discipline: conditionality confined to the rung; the recursion interface stays
   unconditional.

**Consequences (binding):** the k=1 arm of the `| 1 =>` case (depth-2 obligations) consumes the
landed k=2 gate only for fragment-scoped `qnf`; Phase 15 machine-determines whether the `qnf`
population actually arising at the site is fragment-covered. If non-fragment `qnf` arise
unavoidably, that is a recorded blocker routed to the 321-N2 successor (escalation, `/spawn 309`)
— never a silent absorption, never a `Nat.rec` re-shape, never a weakening of
`nf_nvar_exist_all_depths`'s statement.

## Overview

Retire the `KampPrior.lean:361` strategic sorry (the `| 1 =>` arm of `nf_nvar_exist_all_depths`
— the handoffs' ":351"; live-path sorries 2 → 1; `:364` stays, task 305 scope) by consuming the
landed provider chain: the task-348 enriched composed gate
`bracketEndChar_kvE2Ext_correct_two_prior_frag` (interior+boundary+adjacent-exterior, `hexclExt`
discharged internally) plus 309's own provider-obligation discharge
(`hfrag`/`hrealI`/`hrealB`/`hexcl` + order bits), per the 348 handoff's consumption guide:
*"Retirement = consume the discharge theorem + discharge the provider inventory; neither half
alone suffices."*

Definition of done: full `lake build` GREEN; `#print axioms` on the rewired live-path theorem
`nf_nvar_exist_all_depths` = exactly `[propext, Classical.choice, Quot.sound]` (0 domain axioms);
all new material sorry-free (sole pre-committed exception: the Phase-19 k≥2-arm routing, if the
Phase-15 verdict shows a symbolic-k gate family is required — then ONE explicitly documented,
narrowed strategic sorry + `follow_up_task`, escalated before landing, per the routing below);
task 307 Phase 7 unblocked.

**Plan lineage summary (v1 → v9).** v1 outer wrapper (P1-5, 6.1 landed); v2 endChar route
(ABANDONED); v3 Path B pivot, R1 landed, R2 k=1 NO-GO; v4/v5 tasks 310+311 folded back, R2=GO,
P12 landed, F1 at k=2; v6 redesign (13.0-13.2 landed, 13.3 NO-GO/F3); v7 uniformization
(13.25 landed, 13.35 NO-GO/F4); v8 task-347 re-point (interior+boundary + adjacent-exterior
model, seam `x,t`; 13.4/14 gated on task 348). Full lineage detail: v8 §Overview (verbatim
record). **v9**: providers landed; the k=2 rung is now a call-the-landed-theorem, not a
prove-it; the `:361` retirement is 309-owned; open work re-decomposed as Phases 15-19.

### Research Integration

All v6/v7/v8 integration records (findings F1/F2/F3/F4, amendments A1/A2, guards, the task-347
adjudication) are carried unchanged — transcribed in plans/08_offdiag-fi-chain-v8.md:147-254 and
not re-litigated here. **New in v9 — the two provider handoffs (2026-07-11; no new task-309
research report — the revision authorities are the 335/348 handoffs + the 348 plan R1 decision):**

1. **The k=2 interior+boundary gate is LANDED and axiom-clean** (task 335 Phase D, commit
   `147af2fbe`): `bracketEndChar_kvE2_correct_two_prior_frag` (`OuterGate.lean:359`), with
   `_sound_two_prior_frag` (`:288`) and the UNCONDITIONAL completeness direction
   `_complete_two_prior` (`:147`). Statement (verbatim from the handoff):
   `(bracketEndChar_kvE2 atomMap h_surj P qnf).holds M atomMap x t ↔ ∃ w : M.carrier,
   nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf`, under
   `kvE2_sepFragment qnf` (`OuterGate.lean:210`; interior-singleton `kvE2_sepPosI qnf = [σ0]`,
   realizable per `kvE2_sepFragment_realizable`, SW:10265) plus `hrealI`/`hrealB`/`hexcl`/
   `hexclExt`. The fragment/interior restriction gates only ⇒. The realization obligation is
   indexed by `kvE2_sepPosI` (`SharedWitness.lean:211`), **bounded and jointly-ordered**
   (Cor 5.4 ⇐, p.9 l.263-273) — NOT the retired global/unbounded `kvE2_sepPos` shape.
2. **The exterior slice is DISCHARGED** (task 348, 8/8 phases): the enriched carrier
   `bracketEndChar_kvE2Ext atomMap h_surj P` = the interior gate `bracketEndChar_kvE2` with the
   past-side adjacent bracket conjoined at the LEFT anchor `x` and the future-side at the RIGHT
   anchor `t` (`VVecEA2.enrichEndpoints`; destructure via `bracketEndChar_kvE2Ext_holds_iff` —
   the degenerate Lemma 7.6 conjunction). Its discharge theorem
   `bracketEndChar_kvE2Ext_correct_two_prior_frag` (`ExteriorBracket.lean`, live import path via
   `NfMultiAnchorBridge.lean`) has **`hexclExt` GONE** — discharged internally. Remaining
   hypotheses (ALL 309-owned): six qnf order bits, `h_UZ`/`h_SZ`, `hfrag`, `hrealI`, `hrealB`,
   `hexcl`. Full build green (1724 jobs); zero sorries in 348 files; axiom-clean.
3. **The `:351` retirement transferred to 309** (348 plan R1 decision, settled): 348's DoD was
   amended to end at the discharge theorem; the task-description clause "`KampPrior.lean:351`
   strategic sorry retired" transferred to 309 (this plan's Phases 18-19). Inline transfer note
   at `KampPrior.lean:352-360`; the sorry at `:361`.
4. **Multi-positive / full `On` stays DEFERRED to the 321-N2 successor** (335 handoff §4) — the
   fragment predicate is the sanctioned k=2 scope. The ∀k-lift flag (335 §5) is resolved by this
   v9's option-(a) decision above.

### Corrected Anchor-Cap Statement (CARRIED FORWARD; still binding)

Carried verbatim from v8 (plans/08:222-254): anchors strictly `{x,t}` (≤2, Rabinovich cap;
G2/G4) by the bracket-witness mechanism at every depth; `nf_char3_deeper_split` FORBIDDEN
(anchor tower); the task-347 corrected model (interior+boundary + adjacent-exterior, seam `x,t`)
is settled; the raw unbounded fresh-witness `∃` of `nf_eval_nf` is correct FOMLO semantics and
is NOT bounded in place.

## Preserved / Live Assets (consume — do NOT rebuild)

The full v8 asset table (plans/08_offdiag-fi-chain-v8.md:256-310) is carried unchanged — all
Phases 1-5/6.1/9-12/13.0-13.35 material, the task-310/311 assets, the F1/F2/F3/F4 records, the
negation-stack and fold assets. **NEW rows (the landed provider chain — frozen territory,
consume BY NAME):**

| Component | File:line | Status | Role in v9 |
|-----------|-----------|--------|------------|
| `bracketEndChar_kvE2` (interior gate carrier) + `kvE2_sepFragment` (:210) + `kvE2_sepPosI` (SW:211) + `kvE2_sepFragment_realizable` (SW:10265) | Kamp/NfMultiAnchorBridge/{OuterGate,SharedWitness}.lean | Landed (341/346/335), sorry-free | the k=2 interior+boundary carrier + fragment predicate (Phase 15 triage, 18) |
| `bracketEndChar_kvE2_correct_two_prior_frag` / `_sound_two_prior_frag` / `_complete_two_prior` | OuterGate.lean:359/:288/:147 | Landed 335 Phase D, commit 147af2fbe, axiom-clean | the k=2 interior+boundary GO gate (⇐ unconditional); superseded as the LIVE consumable by the kvE2Ext form but stays the interior template |
| `hrealI`/`hrealB`/`hexcl` obligation shapes | OuterGate.lean:374/:380/:387 | Landed (statement shapes) | the provider contract Phase 17 discharges |
| `kvE2_outer_fold_frag` + narrowed exterior binder + `kvE2_sepInterior_exterior_notRealizable` | SharedWitness.lean:12665/:12710/:12627 | Landed 347 R1 | interior/exterior split record (read-only) |
| **`bracketEndChar_kvE2Ext` + `bracketEndChar_kvE2Ext_correct_two_prior_frag` + `bracketEndChar_kvE2Ext_holds_iff`** | **Kamp/NfMultiAnchorBridge/ExteriorBracket.lean (live path)** | **Landed 348, sorry-free, axiom-clean** | **THE Phase-18 consumable — the enriched composed gate, `hexclExt` internal** |
| `kvE2_extBracketFut_{sound,exists,complete}` / `kvE2_extBracketPast_*` | ExteriorBracket.lean | Landed 348 | per-side adjacent-bracket lemmas (pins `henv`, `hbelow`/`habove`) |
| `kvE2_futMarked`/`kvE2_pastMarked` (+ `_iff`, `_of_realizer`) | ExteriorBracket.lean | Landed 348 | syntactic exterior marking |
| `kvE2_exterior_zone_triage` (+ determination lemmas) | ExteriorZoneTriage.lean | Landed 348 | zone triage (Phase 15/18 support) |
| One-sided complement clause families (`_sound`/`_complete`) | ExteriorNegation.lean (future) / ExteriorNegationPast.lean (past) | Landed 348 | exterior complement support |
| `kvE2_extGate_henv` / `kvE2_extGate_anyBit_iff` | ExteriorBracket.lean (**private**) | Landed 348 | pin derivations at a gate-holds site without a realized qnf — mirror or de-private in a 309 dispatch IF Phase-18 wiring needs the shapes (348 handoff license) |
| `:361` strategic sorry + transfer note | KampPrior.lean:352-361 | Open — THE target | Phases 18-19 retire it |

**Frozen-territory rule (NEW, binding)**: `SharedWitness.lean`, `SubBracket2V.lean`,
`OuterGate.lean`, `ExteriorBracket.lean`, `ExteriorZoneTriage.lean`, `ExteriorNegation.lean`,
`ExteriorNegationPast.lean` are provider territory (tasks 341/346/335/347/348) — byte-unchanged
except for the ONE sanctioned edit: de-privatizing `kvE2_extGate_henv`/`kvE2_extGate_anyBit_iff`
(or mirroring them into 309 territory, preferred) per the 348 handoff license. All other 309
edits confine to `KampPrior.lean` (+ additive material in `NfMultiAnchorBridge.lean` or a new
309-owned wiring file if Phase 16-18 shims outgrow the call site).

### Source-to-Implementation Mapping (H3, Tier 1)

The v8 table (plans/08:312-335) is carried unchanged. v9 updates the rows that pointed at
unlanded targets:

| Paper item (Rabinovich 2014) | Paper loc | Lean target | Phase |
|------------------------------|-----------|-------------|-------|
| Cor 5.4 ⇐ bounded interior witnesses `(∃z)^{<z1}_{>z0}` | p.9 l.263-273 | `hrealI` (OuterGate:374) — LANDED shape, 309 discharges | 17 |
| Prop 4.3 re-flatten / Lemma 7.6 adjacency (seam `x,t`) | p.6 / p.13 | `bracketEndChar_kvE2Ext` + `_holds_iff` — **LANDED (348), consumed by name** | 18 |
| Def 7.5 / Lemma 7.10 adjacent-interval brackets | p.13 | `kvE2_extBracketPast/Fut_*` — **LANDED (348)** | 18 |
| Cor 5.4 `F_{i-1} := α_{i-1} ∧ (β_i Until F_i)` past/future arms | p.9 | `A_past`/`A_future`/`_correct` (P1); `nf_char2_{past,future}_formula_correct` (P4/P5) | 18 |
| Prop 4.2 / Lemma 5.1 / 5.3 negation-closure (per-model directions) | md:100-152 | forward negation stack (EANegationClosure :401/:492/:646/:720) — proof-side ONLY | 17 |
| Def 4.1 E[Σ] fold, inside-out | p.5-6 | `nf_quant_layer_fold_iff` (NfEFold:391) per innermost per-sub layer | 17-18 |

## Postmortem Constraints

Guards G1-G6 (+ amendments), rules N1-N5, v7 Amendment F3, and the v8 corrected-model constraints
are carried VERBATIM from v8 (plans/08:337-507) and remain binding on every dispatch. v9 adds:

**v9 Amendments (NEW):**

- **V9-1 (frozen provider territory)**: do NOT edit the seven provider files listed in the
  Frozen-territory rule (sole sanctioned exception there). Consume
  `bracketEndChar_kvE2Ext_correct_two_prior_frag` and the supporting API BY NAME.
- **V9-2 (no hexclExt resurrection)**: `hexclExt` is discharged INTERNALLY by the enriched gate.
  Do NOT restate, re-derive, or thread it; do NOT consume the unenriched
  `bracketEndChar_kvE2_correct_two_prior_frag` on the live path where the kvE2Ext form is
  available (the unenriched gate would re-impose `hexclExt` on 309 — machine-confirmed
  undischargeable from interior hypotheses, 335 handoff §2).
- **V9-3 (kvE' k≥2 retirement)**: the v7 carrier `bracketEndChar_kvE'` is RETIRED as a k≥2
  live-path consumable (F4 refuted its k=2 correctness; the landed kvE2/kvE2Ext chain supersedes
  it). Its 13.25 material stays landed as record; do NOT restate `bracketEndChar_kvE'_correct*`
  targets in any form.
- **V9-4 (∀k-lift discipline)**: the lift is option (a) (decision section above). Do NOT thread
  `kvE2_sepFragment` or the provider obligations through `nf_nvar_exist_all_depths`'s statement;
  do NOT weaken that theorem's interface for any consumer. Non-fragment residue routes to the
  321-N2 successor via recorded blocker + escalation.
- **V9-5 (retirement exactly once, both halves)**: per the 348 handoff, retirement = consume the
  discharge theorem + discharge the provider inventory — neither half alone. Do NOT declare the
  `:361` sorry retired on gate consumption with sorry'd provider obligations, and do NOT
  re-prove exterior content the gate already internalizes.

**Do NOT** (carried from v8 in full, plans/08:439-478; headline items): no arity-1 collapse (G1);
no third anchor ever (G2/G4); no trivial-top segment on off-diagonal arms (G3); no chain-step
tactic shortcuts (G5); no `nf_char3_deeper_split`; no edits to any landed 309/310/311 asset or
any F-record; no consumption of EANegation `:1090`/`:1249` (blocker criterion); no vacuous
definitions; no domain axioms; no in-place bounding of the `:361` fresh-witness `∃`; no
monolithic all-arrangement `(x,t)` gate re-attempt (F3/F4/347 settled); no import cycles.

**Design decisions SETTLED (do not re-open without a machine counterexample):** all v8-settled
items (plans/08:487-507) plus: the `:361` completeness obligation is delivered by the LANDED
adjacency composition (`bracketEndChar_kvE2Ext`), consumed by name (v9); the ∀k lift is
option (a) (v9); the `:361` retirement is 309-owned (348 R1, v9).

## v8 → v9 Phase Mapping

| v8 phase | v8 status | v9 disposition |
|----------|-----------|----------------|
| 1-5, 6.1, 9-12 | [COMPLETED] | **Survive verbatim** (history records below; content in v8 §Implementation History) |
| v2 Phases 6-8 (endChar/seg) | ABANDONED ROUTE | Survives as-is (inert, off live path) |
| 13.0-13.3 | [COMPLETED] (13.3 = NO-GO/F3 record) | **Survive verbatim** |
| 13.25 | [COMPLETED] | **Survives** (kvE' construction stays landed as record; V9-3 retires its k≥2 live-path role) |
| 13.35 | [COMPLETED — NO-GO/F4 record] | **Survives verbatim** (permanent defect exhibit) |
| 13.4 (general-k interior correctness of `bracketEndChar_kvE'`) | [NOT STARTED], gated | **SUPERSEDED — RETIRED as written.** Its purpose (an interior+boundary correctness rung for the `:361` wiring) is fulfilled by the LANDED k=2 gates on the kvE2/kvE2Ext carriers (tasks 341/346/335/348) — "call the landed theorem" replaces "prove it". The unlanded symbolic-k residue (depth ≥3 rungs, if the Phase-15 verdict shows they are required) routes to a spawned successor building on the landed kvE2Ext template — NOT re-opened in-task on the retired kvE' carrier (V9-3) |
| 14 (adjacency assembly + hooks + `:351` close) | [NOT STARTED], gated on 348 "retiring :351" | **SUPERSEDED — RE-DECOMPOSED as Phases 15-19.** Its gating premise inverted (348 R1 transferred the `:351` close TO 309); its hook-discharge and provider-instantiation content survives, redistributed: providers → Phase 16, provider obligations → Phase 17, hooks + trichotomy assembly + gate consumption → Phase 18, ∀k lift + `:361` retirement + verification → Phase 19; the site/coverage probe it lacked → Phase 15 |

## Goals & Non-Goals

**Goals:**
- Resolve the ∀k-lift composition flag (DONE in this plan — option (a); Phases 15/19 realize it).
- Machine-establish the two coverage facts the retirement depends on: fragment coverage of the
  `qnf` population at the `| 1 =>` site, and the depth ladder (which rungs the symbolic-k arm
  actually needs) (Phase 15).
- Build the provider instantiation (`ExistProviders` from the recursion) and discharge the
  provider inventory `hrealI`/`hrealB`/`hexcl` at the site (Phases 16-17).
- Consume the task-348 enriched composed gate `bracketEndChar_kvE2Ext_correct_two_prior_frag`
  BY NAME; discharge `hfrag` + the six order bits + the four deferred hooks; assemble the
  three-way trichotomy at the depth-2 instance (Phase 18).
- Execute the option-(a) ∀k lift and **retire the `KampPrior.lean:361` strategic sorry** (live
  sorries 2 → 1); full-tree GREEN; axioms exactly `[propext, Classical.choice, Quot.sound]`;
  report the task-307 Phase-7 unblock (Phase 19).

**Non-Goals:**
- Closing `:364` (`| n+2 =>` arm — task 305 scope).
- Rebuilding, editing, or re-proving ANY provider-chain material (V9-1/V9-2): the exterior
  brackets, the adjacency composition, the fragment gate, the fold, the negation stack.
- Re-attempting the retired routes: monolithic all-arrangement gate (F3/F4/347), kvE' k≥2
  correctness (V9-3), endChar/seg, `nf_char3_deeper_split`, provider-side pinning.
- The multi-positive / full-`On` generalization (321-N2 successor scope; 335 §4).
- The uniform-backward EANegation sorries (`:1090`/`:1249`) — consuming them is a blocker
  finding, never a license.
- A symbolic-k gate-family construction in-task: if Phase 15 shows depth-≥3 rungs are required,
  that is a SPAWNED successor (building on the landed kvE2Ext template), pre-committed in the
  Phase-19 routing — not silent in-task scope growth.

## Risks & Mitigations

- **Risk (High — the v9 concentration): depth coverage of the ∀k lift.** The landed gate is
  k=2-FIXED (`nf_eval_nf M 2 3`); the `| 1 =>` sorry is at symbolic `k` (depth `k+1`). The k=0
  arm has the unconditional k≤1 rungs; the k=1 arm has the landed gate; the k≥2 arms (depth ≥3)
  have NO landed rung. **Mitigation**: Phase 15 machine-determines whether the landed
  symbolic-k assets (P4/P5 arm lemmas, flatten brick, fold engine) reduce the per-`qnf`
  obligation at every depth to a k=2-shaped gate consumption, or whether a symbolic-k gate
  family is genuinely required; the Phase-19 routing pre-commits the honest outcomes (full
  close / narrowed documented residual + spawn + escalation). No dispatch may silently assert
  symbolic-k coverage the verdict did not establish.
- **Risk (High): fragment coverage at the site.** `kvE2_sepFragment` (interior-singleton) may
  fail for some `qnf` arising from an arbitrary `sub_nf` even at depth 2. **Mitigation**:
  Phase 15's triage fact (F-i) settles this by machine before Phases 16-18 are dispatched; the
  NO-GO routing (321-N2 successor) is pre-committed; `hrealI`'s shape is already
  `On`-forward-compatible (335 §4), so the successor extends the index list only.
- **Risk (Medium-High): provider-obligation discharge difficulty (`hrealI`/`hrealB`/`hexcl`).**
  These are the load-bearing new proofs (Phase 17); the negation-stack directions are
  model-dependent (F-D discipline). **Mitigation**: consume the forward stack proof-side only;
  `prior_hasAttainedINF` (PriorINF:224) bridges `h_UZ`; the k1v proof kit and
  `nf_eval_depth1_fold_iff` (:5187) supply the extraction/assembly machinery; H8 split note
  17a/17b at the obligation seam.
- **Risk (Medium): `ExistProviders` instantiation from recursive calls** (report 05 Medium-High,
  carried). **Mitigation**: the KampPrior:273 `ih_exist_1` pattern; fallback = thread converters
  as extra hypotheses (13.1 surgery pattern, confined to KampPrior.lean, documented).
- **Risk (Medium): private 348 API needed at the wiring site** (`kvE2_extGate_henv`/
  `kvE2_extGate_anyBit_iff`). **Mitigation**: the 348 handoff pre-licenses mirroring or
  de-privatizing in a 309 dispatch — the ONE sanctioned frozen-territory exception (V9-1).
- **Risk (Medium): double-close / seam confusion at `:361`.** **Mitigation**: 348 landed NO
  KampPrior edit beyond the transfer note; ownership is unambiguous (309, Phases 18-19); V9-5
  bars declaring retirement with either half missing.
- **Risk (recurring): churn via refuted devices.** **Mitigation**: the carried Do-NOT list +
  V9-1..V9-5 enumerate each refuted/retired device with its citation.

## Implementation History (landed / abandoned / retired — NOT open work)

None of these match the orchestrator open-phase heading-scan. Do not re-dispatch. Full verbatim
records: plans/08_offdiag-fi-chain-v8.md:601-1139.

### Phase 1: Segment-carrying A_past / A_future + _correct [COMPLETED]
Commit f4b9600a1; NfZoneFlattenNavigable:335/:386. Consumed in Phase 18.

### Phase 2: Off-diagonal atom layer for [x,t] [COMPLETED]
Commit 762ea60da; NfMultiAnchorBridge:364/:375/:391. Consumed in Phase 18.

### Phase 3: Arity-3 endpoint-hook construction [COMPLETED]
Commit 010ab616d; NfMultiAnchorBridge:891/:907.

### Phase 4: nf_char2_past_formula + _correct [COMPLETED]
Commit fed9fcd8e; NfMultiAnchorBridge:992/:1015; `h_quant` (:1023-1026) discharged in Phase 18.

### Phase 5: nf_char2_future_formula + _correct [COMPLETED]
Commit b60c63b1a; NfMultiAnchorBridge:1185/…; dual `h_quant` (:1223-1226) discharged in Phase 18.

### Phase 6.1: Cycle-safe import edge (NfMultiAnchorBridge → KampPrior) [COMPLETED]
Commit f3827e255. Do not re-add/move (D1).

### Plan-v2 Phases 6-8 (endChar/seg) [ABANDONED ROUTE — code retained, off live path]
Do not build on; do not delete.

### Phase 9: Two-anchor bracket carrier interface (R1) [COMPLETED]
### Phase 10: k=1 probe (R2) [COMPLETED — NO-GO, superseded by Phase 11]
### Phase 11: Prerequisite closure via tasks 310 + 311 (R2 = GO) [COMPLETED]
### Phase 12: Depth-k V-carrier `bracketEndChar_kv` (R3a) [COMPLETED]
### Phase 13 (v5): `bracketEndChar_kv_correct` (R3b) [BLOCKED — RETIRED (F1); superseded by 13.0-13.4]
### Phase 13.0: F2 probe [COMPLETED — F2 CONFIRMED, machine-checked]
### Phase 13.1: `ExistProviders` + `BracketCarrierCorrectVPrior` surgery [COMPLETED]
### Phase 13.2: Per-sub enriched carrier `bracketEndChar_kvE` [COMPLETED]
### Phase 13.3: k=2 gate for `bracketEndChar_kvE` [COMPLETED — NO-GO, F3]
### Phase 13.25: Uniformization `bracketEndChar_kvE'` (v6's "13.2b") [COMPLETED]
Landed sorry-free (:5282-5531). Per V9-3 the kvE' carrier is retired as a k≥2 live-path
consumable — the material stays as record.
### Phase 13.35: k=2 gate RE-RUN for `bracketEndChar_kvE'` [COMPLETED — NO-GO, F4]
Permanent defect exhibit (NfMultiAnchorBridge, after :5533). The escalation this NO-GO triggered
was resolved externally: task 347 adjudication → tasks 341/346/335/348 built the corrected
interior+boundary + adjacent-exterior chain, now landed.

### Phase 13.4 (v8): General-k interior+boundary correctness `bracketEndChar_kvE'_correct` [RETIRED — SUPERSEDED by the landed provider chain (341/346/335/348); never dispatched]
The interior+boundary rung it was to prove exists LANDED at k=2 on the kvE2/kvE2Ext carriers
(`bracketEndChar_kvE2_correct_two_prior_frag`, OuterGate:359; enriched form in
ExteriorBracket.lean). v9 consumes those by name (Phase 18). The symbolic-k residue, if the
Phase-15 verdict shows it is required, is a spawned successor on the kvE2Ext template — NOT this
phase re-opened (V9-3). Do not dispatch.

### Phase 14 (v8): Adjacency assembly + hooks + :351 close [RETIRED — SUPERSEDED; re-decomposed as Phases 15-19; never dispatched]
Its gating premise ("task 348's DoD itself retires :351") was inverted by the 348 R1 scope
decision — the retirement is 309-owned. Its surviving content is redistributed per the v8 → v9
Phase Mapping. Do not dispatch under this heading.

## Implementation Phases (open work — Phases 15-19)

**Dependency Analysis (v9):**

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 15 (site/coverage probe — DECISION GATE) | — (all provider inputs landed) |
| 2 | 16 (provider instantiation shim) | 15 = GO (either GO form) |
| 3 | 17 (provider-obligation discharge) | 16 |
| 4 | 18 (gate consumption + hooks + depth-2 assembly) | 17 |
| 5 | 19 (∀k lift + `:361` retirement + verification) | 18 |

Phases are strictly sequential (each consumes the previous phase's declarations by name). Edit
territory: `KampPrior.lean` (+ additive 309-owned material in `NfMultiAnchorBridge.lean` or a new
`Kamp/KampPriorWiring.lean` if the shims outgrow the call site; frozen provider files per V9-1).
One agent run per phase (H8). The orchestrator dispatches exactly one open phase per cycle by
heading-scan.

### Phase 15: Site/coverage probe — fragment triage + depth-ladder wiring verdict (DECISION GATE) [NOT STARTED]

*(The verdict-record house style of 13.0/13.3/13.35: machine-probe, record the verdict either
way, land only green material, no sorry, no partial theorem.)*

- **Goal:** Machine-establish the two facts the option-(a) lift depends on, at the actual
  `| 1 =>` site (`KampPrior.lean:347-361`; goal per `sub_nf : NormalForm sig (k+1) 2`:
  `∃ A, ∀ M h_UZ h_SZ t, temporal_truth M atomMap t A ↔ ∃ env : Fin 1,
  nf_eval_nf M (k+1) 2 (insertEnv env t) sub_nf`):
  - **(F-i) Fragment coverage:** after the trichotomy split (`nf_zone_exists_trichotomy_k1`) and
    flatten (`nf_zone_flatten_navigable_brick`), the per-arm inner obligations are per arity-3
    sub `qnf` of `sub_nf`. Determine by machine whether every such `qnf` arising at the k=1 arm
    (depth-2 instance) satisfies `kvE2_sepFragment qnf` (interior-singleton `kvE2_sepPosI`), or
    exhibit a non-fragment `qnf` reachable at the site. Consume `kvE2_sepFragment_realizable`
    (SW:10265) and `kvE2_exterior_zone_triage` as probes; land any positive results as lemmas
    (`kampPrior_site_qnf_fragment`-shape), any negative result as a defect-style record.
  - **(F-ii) Depth ladder:** determine whether the landed symbolic-k assets
    (`nf_char2_{past,future}_formula_correct` P4/P5, `A_diag_correct`, the flatten brick, the
    fold engine `nf_quant_layer_fold_iff`) reduce the per-`qnf` obligation at symbolic `k` to a
    k=2-SHAPED gate consumption at every depth (i.e. the depth-`k+1` arity-3 obligation folds to
    per-sub depth-`k` content dischargeable by providers-at-`k` + the landed gate pattern), or
    whether depths ≥ 3 require a symbolic-k analog of the kvE2Ext gate family (unlanded).
    Record the finding with the exact goal states probed.
- **Deliverables:** site-shape lemmas as far as green material carries (the trichotomy/or_congr
  decomposition of the `| 1 =>` goal STATED and proved down to the named per-`qnf` obligations —
  no sorry; stop at the seam if a direction cannot close green); a wiring VERDICT record (house
  style, N3 Def-3.1 lead) stating F-i and F-ii dispositions.
- **Pre-committed routing:**
  - **GO-full** (F-i covered AND F-ii reduces all depths): Phases 16-19 proceed; Phase 19 targets
    the FULL `:361` retirement.
  - **GO-k1** (F-i covered at the k=1 arm; F-ii shows depth-≥3 rungs required): Phases 16-18
    proceed (depth-2 close); Phase 19 executes the option-(a) case split with the k≥2 arm as a
    NARROWED, documented strategic sorry + `follow_up_task` (spawned successor: symbolic-k
    kvE2Ext generalization on the landed template) — escalated to the orchestrator/user BEFORE
    the sorry lands (AskUserQuestion / `/spawn 309` territory).
  - **NO-GO** (F-i fails — non-fragment `qnf` reachable at the site): STOP. Record; mark this
    phase [BLOCKED]; escalate to the blocker ladder (`/spawn 309` with the record; the 321-N2
    successor is the named route, 335 §4). Do NOT dispatch Phases 16-18.
- **File targets:** `KampPrior.lean` (additive site lemmas) and/or a new 309-owned wiring file;
  provider files untouched (V9-1).
- **Consume, do NOT rebuild:** `nf_zone_exists_trichotomy_k1` (NfZoneFlattenNavigable:188);
  `nf_zone_flatten_navigable(_brick)/_correct` (:689/:709); P4/P5 arm lemmas + `A_diag_correct`;
  `kvE2_sepFragment`/`kvE2_sepPosI`/`kvE2_sepFragment_realizable`; `kvE2_exterior_zone_triage`;
  `nf_quant_layer_fold_iff` (NfEFold:391); `nf_eval_depth1_fold_iff` (:5187).
- **Acceptance criteria:** `lake build` GREEN; 0 sorries landed; verdict record present with
  F-i/F-ii dispositions + the routing consequence named; any landed lemma `lean_verify` = exactly
  `[propext, Classical.choice, Quot.sound]`; no provider file modified.
- **Estimated lines:** 100-250 (one agent run; H8).
- **Guards enforced:** G1-G6 (as amended), A1/A2, N1-N5, V9-1..V9-5.
- **Commit:** `task 309 phase 15: site/coverage probe — fragment triage + depth-ladder verdict`

### Phase 16: Provider instantiation shim — `ExistProviders` from the recursion at the :361 site [NOT STARTED]

- **Goal:** Build `P : ExistProviders sig atomMap 1` (and, if F-ii = GO-full, the general
  `ExistProviders sig atomMap k` family) at the KampPrior `| 1 =>` site from the recursive calls
  `nf_nvar_exist_all_depths atomMap h_surj j n'` — the KampPrior:273 `ih_exist_1` pattern
  generalized across arities (structural on the first Nat argument; F-A licenses all depths ≤ k).
  Land `P.correct` availability from `exist_tl_fn_k_correct`/`char_k1_correct` (KampPrior:
  296-321). If some arity is not structurally available, thread the needed converters as extra
  hypotheses (the 13.1 surgery pattern, confined to `KampPrior.lean`, documented as a deviation)
  — never edit the landed 13.1 `ExistProviders`.
- **Deliverables:** the provider-instantiation shim (named defs/lemmas, e.g.
  `kampPrior_existProviders_one` + correctness), compiling green at the site with `h_UZ`/`h_SZ`
  in scope (KampPrior:216-223).
- **File targets:** `KampPrior.lean` (or the Phase-15 wiring file).
- **Consume, do NOT rebuild:** `ExistProviders`/`BracketCarrierCorrectVPrior` (13.1, unchanged —
  KD3); `nf_succ_char_formula(_correct)` (KampPrior:67/:81); the recursion's own
  `ih_exist_1`/`exist_tl_fn_k`/`char_k1` (KampPrior:264-321); `nf_characterizable_temporal_prior`
  (KampPrior:397) where k≤1 instances are consumed.
- **Acceptance criteria:** `lake build` GREEN; shim sorry-free; `lean_verify` on each named shim
  = exactly `[propext, Classical.choice, Quot.sound]`; no change to `nf_nvar_exist_all_depths`'s
  statement (V9-4); documented deviation note if converters were threaded.
- **Estimated lines:** 150-300 (one agent run; H8).
- **Guards enforced:** G1-G6, A1/A2, N1-N5, V9-1..V9-5.
- **Commit:** `task 309 phase 16: ExistProviders instantiation shim at the KampPrior :361 site`

### Phase 17: Provider-obligation discharge — hrealI / hrealB / hexcl [NOT STARTED]

- **Goal:** Discharge the three 309-owned provider obligations of the enriched gate (shapes
  verbatim in the 335 handoff §1; restated at the kvE2Ext signature in the 348 inventory), for
  the `qnf` population Phase 15 certified, using the Phase-16 providers:
  - **`hrealI`** (OuterGate:374 shape): interior positives (`σ ∈ kvE2_sepPosI qnf`) realized
    interval-BOUNDED `x < x1 < t` at the pivot `w` — the Cor 5.4 ⇐ bounded-interior-witness
    obligation. For the fragment singleton the joint-order coupling is vacuous (335 §1); the
    realization comes from the provider literal semantics (`P.correct`) + the pivot hypothesis
    (`kvE2_sepPtW … .eval_at M atomMap w`) + the interior extraction machinery.
  - **`hrealB`** (OuterGate:380 shape): the non-interior-marked remainder of `kvE2_sepPos` (the
    boundary/at-point positives `nf_exists_unique` forces), landed unbounded fold shape —
    realized at the anchors via the endpoint/pivot literals; the interval bound applies ONLY to
    the interior index.
  - **`hexcl`** (OuterGate:387 shape): the cone-restricted (`x ≤ x1 ≤ t`) negative-sub
    exclusion — from `nf_eval_unique` (NormalForm:245) / `nfPred_correct` (NfToVecEA:69)
    distinctness + the realized `qnf`'s own bit data; forward negation stack
    (`prior_hasAttainedINF` PriorINF:224 + EANegationClosure :401/:492/:646/:720 +
    `neg_orderedPointsExist_is_vbracket` EANegation:347) consumed proof-side ONLY (F-D).
- **Deliverables:** three named discharge lemmas (`kampPrior_hrealI`-shape etc.), stated at
  exactly the gate's binder shapes (no strengthening, no weakening), green.
- **File targets:** `KampPrior.lean` / the wiring file; provider files untouched.
- **Consume, do NOT rebuild:** the Phase-16 shim; `nf_eval_depth1_fold_iff` (:5187);
  `nf_quant_layer_fold_iff` (NfEFold:391); `nf0_split_assemble` (NfEFold:153-235); the k1v proof
  kit (:2028-2825) extraction patterns; `existsBounded_right` (VecEAClosure:265). Do NOT touch
  EANegation `:1090`/`:1249` (blocker criterion); do NOT re-derive `hexclExt` (V9-2).
- **H8 split note:** if one run overruns, split at the obligation seam — 17a = `hrealI` +
  `hrealB` (positive realization); 17b = `hexcl` (negative exclusion).
- **Acceptance criteria:** `lake build` GREEN; all three lemmas sorry-free; `lean_verify` each =
  exactly `[propext, Classical.choice, Quot.sound]`; binder shapes match the gate verbatim
  (grep-checkable against OuterGate:374/:380/:387 / the kvE2Ext signature); A2 inside-out
  discipline on every per-sub obligation; chain-step citations per G5 (+v6 extension), N1/N2.
- **Estimated lines:** 200-450 (one agent run; H8; split note above).
- **Guards enforced:** G1-G6, A1/A2, v7 Amendment F3, N1-N5, V9-1..V9-5.
- **Commit:** `task 309 phase 17: provider obligations hrealI/hrealB/hexcl discharged`

### Phase 18: Enriched-gate consumption + hook discharge + depth-2 assembly [NOT STARTED]

- **Goal:** Close the **depth-2 instance** of the `| 1 =>` obligation (the k=1 arm:
  `sub_nf : NormalForm sig 2 2`, goal `∃ env : Fin 1, nf_eval_nf M 2 2 (insertEnv env t) sub_nf`)
  by consuming **`bracketEndChar_kvE2Ext_correct_two_prior_frag`** (ExteriorBracket.lean, BY
  NAME — V9-1/V9-2) with the full hypothesis inventory discharged: six qnf order bits from the
  realized/target `qnf`'s atom layer (as at the site, 348 inventory); `h_UZ`/`h_SZ` from scope;
  `hfrag` from the Phase-15 triage (fragment certification); `hrealI`/`hrealB`/`hexcl` from
  Phase 17. Then discharge the four deferred hooks — `h_quant` (past,
  NfMultiAnchorBridge:1023-1026), `h_quant` (future, :1223-1226), `h_past`/`h_fut`/`h_diag`
  (`A_diag_correct`, :787-795) — and assemble the three-way disjunction
  `A := nf_char2_past_formula … ∨ A_diag … ∨ nf_char2_future_formula …` via
  `nf_zone_exists_trichotomy_k1` + or_congr, bridging `env : Fin 1` to `∃x` (the `h_env_eq`
  shape, KampPrior:277-291) and decomposing the depth-0 atom layer via
  `nf_char2_atom_offdiag_correct` (P2). The fresh-witness `∃` stays raw/unbounded (task-347
  verdict (b)); its interior case closes via the gate's interior content and its exterior case
  via the gate's INTERNAL adjacent-exterior composition (`bracketEndChar_kvE2Ext_holds_iff` to
  destructure if needed) — no exterior proof is built here.
- **Deliverables:** the depth-2 instance lemma (`kampPrior_case1_depth2`-shape: the `| 1 =>`
  biconditional at k=1, sorry-free) + the four hook discharges; if the wiring needs the private
  348 pin derivations, MIRROR `kvE2_extGate_henv`/`kvE2_extGate_anyBit_iff` into 309 territory
  (preferred) or de-private them (the sole sanctioned frozen-file edit — V9-1), documented.
- **File targets:** `KampPrior.lean` / the wiring file; ExteriorBracket.lean ONLY under the
  de-private license.
- **Consume, do NOT rebuild:** the enriched gate + `bracketEndChar_kvE2Ext_holds_iff` +
  per-side bracket lemmas + marking lemmas (348, by name); Phases 15-17 deliverables; P1/P2/P4/P5
  arm assets; `A_diag_correct`; `nf_zone_exists_trichotomy_k1`; flatten brick;
  `existsBounded_right`. Do NOT consume the unenriched `_correct_two_prior_frag` on this path
  (V9-2); do NOT bound the fresh-witness `∃`; do NOT re-close exterior content.
- **Acceptance criteria:** `lake build` GREEN full tree; depth-2 instance + hooks sorry-free;
  `lean_verify` on the instance lemma = exactly `[propext, Classical.choice, Quot.sound]`;
  grep confirms the consumed gate is the kvE2Ext form; frozen files byte-identical except the
  documented de-private edit (if taken); anchors `{x,t}` (G4/G6); chain-step citations (G5,
  N1/N2 — Prop 4.3 p.6 / Lemma 7.6 p.13 for the adjacency destructure comments).
- **H8 split note:** if one run overruns, split 18a = hooks + or_congr skeleton; 18b = gate
  consumption + instance assembly.
- **Estimated lines:** 200-400 (one agent run; H8).
- **Guards enforced:** G1-G6, A1/A2, N1-N5, V9-1..V9-5; D1 (import edge landed — do not re-add).
- **Commit:** `task 309 phase 18: kvE2Ext gate consumed + hooks discharged + depth-2 assembly`

### Phase 19: ∀k lift (option (a)) + KampPrior:361 retirement + final verification [NOT STARTED]

- **Goal:** Execute the option-(a) lift inside the `| 1 =>` arm and **retire the `:361`
  strategic sorry** (live-path sorries 2 → 1; `:364` stays). Structure: case-analyze the
  recursion depth at the arm —
  - **k=0 arm** (depth-1 obligation): close via the unconditional k≤1 rungs
    (`bracketEndChar_kv_correct_zero_prior`/`_one_prior`, 13.1 lifts) / the existing depth-1
    machinery (`nf_succ_char_formula` + depth-0 two-var assets), per the Phase-15 site lemmas.
  - **k=1 arm** (depth-2): the Phase-18 instance lemma.
  - **k≥2 arms** (depth ≥3): per the Phase-15 verdict — **GO-full**: close via the certified
    symbolic-k reduction (the fold/arm assets reduce to gate-shaped consumption at every depth
    with Phase-16 providers-at-`k`). **GO-k1**: land the pre-escalated, NARROWED, documented
    strategic sorry + `follow_up_task` (the spawned symbolic-k successor on the kvE2Ext
    template) — ONLY after the escalation (AskUserQuestion / `/spawn 309`) has been executed and
    recorded; the sorry carries an inline note naming the successor task, mirroring the 348
    transfer-note pattern. Under GO-k1 this phase completes as [PARTIAL]-by-design with the
    residual explicitly scoped — the plan-level definition of done is then met only by the
    successor; the orchestrator handoff must say so.
  Replace the `:361` `sorry` with the assembled construction; keep the `:352-360` transfer note
  updated (retired-by note). Then final verification: full-tree `lake build`; `lean_verify` /
  `#print axioms` on `nf_nvar_exist_all_depths` — under GO-full exactly
  `[propext, Classical.choice, Quot.sound]` and NO `sorryAx`; grep across all new v9 material
  shows 0 code sorries (GO-full) or exactly the one documented residual (GO-k1); report the
  task-307 Phase-7 unblock (do not execute it here).
- **Deliverables:** the rewired `| 1 =>` arm; the final verification record; the 307-unblock
  report line in the handoff; under GO-k1, the executed escalation + spawn record.
- **File targets:** `KampPrior.lean`.
- **Consume, do NOT rebuild:** Phases 15-18 deliverables; the 13.1 `_prior` lifts; everything in
  the Preserved/Live Assets table. Do NOT weaken `nf_nvar_exist_all_depths`'s statement (V9-4);
  do NOT touch `:364`; do NOT declare retirement with sorry'd provider obligations (V9-5).
- **Acceptance criteria (definition of done, GO-full):** full-tree `lake build` GREEN (baseline
  1724 jobs); axioms on `nf_nvar_exist_all_depths` exactly `[propext, Classical.choice,
  Quot.sound]` (0 domain axioms, no sorryAx); live-path sorries 2 → 1 (`:361` closed exactly
  once; `:364` remains); new-material sorry grep clean; frozen provider files byte-identical
  (except the documented Phase-18 de-private edit, if taken); task 307 Phase 7 unblock reported.
  **(GO-k1):** all of the above except the single documented, escalated, successor-named
  residual sorry in the k≥2 arm; phase heading set [PARTIAL]; orchestrator handoff states the
  residual and the successor task number.
- **Estimated lines:** 100-250 (one agent run; H8).
- **Guards enforced:** G1-G6, A1/A2, N1-N5, V9-1..V9-5; final sorry + axiom discipline.
- **Commit:** `task 309 phase 19: ∀k lift (option a) + KampPrior:361 retirement + verification`

## Testing & Validation

- After each phase: scoped `lake build` for the touched file + dependents; full-tree build at
  Phases 18/19; grep for new `sorry` (budget: 0, with the two pre-committed exceptions — the
  Phase-19 GO-k1 residual and nothing else).
- Per-phase axiom check (`lean_verify`/`#print axioms`) on each new named lemma: exactly
  `[propext, Classical.choice, Quot.sound]`.
- **Frozen-territory check (every phase)**: git diff confirms the seven provider files
  byte-identical (sole documented exception: the Phase-18 de-private edit, if taken).
- **Gate-form check (Phase 18)**: grep confirms the consumed discharge theorem is
  `bracketEndChar_kvE2Ext_correct_two_prior_frag` (the kvE2Ext form), NOT the unenriched
  `bracketEndChar_kvE2_correct_two_prior_frag` (V9-2), and NO reference to `hexclExt` appears in
  any new 309 material.
- **Binder-shape check (Phase 17)**: the three discharge lemmas' statements match the gate's
  hypothesis shapes verbatim (OuterGate:374/:380/:387 / the kvE2Ext inventory) — no
  strengthening/weakening.
- **Interface check (Phases 16/19)**: `nf_nvar_exist_all_depths`'s statement is byte-unchanged
  (V9-4 — option (a) means no threading through the `Nat.rec` interface).
- **Anchor-cap check (every phase)**: every new `holds`/obligation is at the two-point `(x,t)`
  signature; witness growth only inside bracket structure (G2/G4/G6-amended).
- **A2 discipline check (Phases 17-18)**: per-sub obligations discharged inside-out via
  `nf_quant_layer_fold_iff`/`nf_eval_depth1_fold_iff`; no raw `nf_eval_nf M (k+1)` split leaving
  a joint existential standing; no fiber-existential `qnf.2` read at k≥2.
- **Verdict-phase check (Phase 15)**: verdict record present in-file + handoff with F-i/F-ii
  dispositions and the routing consequence; no partial theorem, no sorry landed on any probe.
- **Uniformization-provenance check**: no reference to EANegation `:1090`/`:1249` in any new
  material; forward EANegationClosure lemmas appear only inside proofs, never in definitions.
- Phase 19 gate (definition of done): as in the phase — live sorries 2 → 1 (GO-full) or the
  explicitly scoped GO-k1 residual; 307 unblock reported.

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean` — site lemmas (P15), provider
  shim (P16), obligation discharges (P17), depth-2 assembly + hooks (P18), rewired `| 1 =>` arm
  (P19). The `:364` sorry and all landed material byte-identical.
- Optionally `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPriorWiring.lean` (new,
  309-owned) if the shims outgrow the call site — additive, cycle-safe (imports
  NfMultiAnchorBridge, imported by KampPrior; verify no cycle).
- `Theories/.../Kamp/NfMultiAnchorBridge/ExteriorBracket.lean` — ONLY the documented de-private
  edit, if the Phase-18 license is exercised.
- Per-phase handoffs under `specs/309_offdiag_two_anchor_fi_chain/handoffs/`.
- Up to five scoped commits (`task 309 phase 15/16/17/18/19: …`), continuing the task history.

## Rollback/Contingency

- Each phase is a scoped commit; revert the last commit to roll back one phase without
  disturbing earlier green milestones (H9).
- All Phases 1-13.35 material, the provider chain (341/346/335/347/348), and the F-records are
  landed and green; if a later phase surfaces a build/axiom problem, roll back to the prior
  green commit — the `:361` sorry simply remains until the wiring lands, with no downstream
  regression.
- **Phase-15 contingency (pre-committed)**: NO-GO (fragment coverage fails) → [BLOCKED] +
  escalation (`/spawn 309`, 321-N2 route); GO-k1 → Phases 16-18 proceed, Phase 19 runs the
  escalated-residual routing. No silent scope growth in either branch.
- **Phase-17 contingency**: split 17a/17b at the obligation seam rather than inflating one
  dispatch; if a direction is found to REQUIRE EANegation `:1090`/`:1249`, STOP + record +
  escalate (blocker criterion).
- **Phase-18 contingency**: split 18a/18b; if the private-API mirror proves insufficient and a
  provider-file change beyond the de-private license appears necessary, that is a recorded
  blocker (provider-territory violation), never an unsanctioned edit.
- **Phase-19 contingency**: under GO-k1, the residual sorry lands ONLY after the executed
  escalation; if the user/orchestrator declines the residual, the phase parks [BLOCKED] with the
  full construction minus the k≥2 arm preserved on a green commit.
- The escalation fence bars any implementer-level anchor growth; anchors stay `{x,t}` (2, fixed)
  under all circumstances.
