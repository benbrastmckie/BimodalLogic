# Retrospective Review: Why Discrete-Logic Completeness Has Been Hard

- **Task**: 322 - review_discrete_logic_completeness_retrospective
- **Date**: 2026-07-07
- **Type**: Retrospective review document (Phase 1 deliverable)
- **Derived from**: `specs/322_review_discrete_logic_completeness_retrospective/reports/01_completeness-retrospective.md` (H4-verified full-arc research report, Tier 1 literature-backed)
- **Companion**: `reports/03_streamlining-recommendations.md` (Phase 2 — dispatchable recommendations)
- **Scope**: The full completeness lineage, task 006 (2026-03) through the current F4 blocker (tasks 309/320/321, 2026-07). This document is standalone: a future planner should be able to read it in one sitting without opening the 40+ underlying task directories.

---

## 1. Executive Summary

The discrete-completeness effort — the formalization of Kamp's theorem needed to close
`completeness_discrete` for the bimodal logic TM — is enormous and largely *sound*: ~20,459
lines of Lean under `Kamp/` alone, 327 commits touching that directory, soundness sorry-free
throughout, and the k=0 case fully closed (task 273, ~1400 lines). The blocker has been
correctly narrowed to a single conceptual hole: `KampPrior.lean:351`, the `n=1` arm of
`nf_nvar_exist_all_depths` (verified first-hand in the research report's Adversarial
Self-Verification table).

Four theses, each developed in a section below:

1. **One obstruction, three costumes** (§3). A single mathematical fact has blocked the effort
   in every era: a property relating two independently-chosen points — an interval, a relative
   order, a joint type — cannot be expressed from independent one-variable data evaluated at a
   single point. It appeared early as F/P non-persistence through Lindenbaum on a linear index,
   in the middle era as "1-var NF agreement does not determine 2-var NF," and recently as the
   F1–F4 "flattening" defect.

2. **The dominant failure mode is refuted-device churn against home-grown lemmas** (§4). Task
   305 went through ~40 plan versions; task 303 through 18; archived task 093 through 22 plan
   versions / 175 commits / 45+ recorded dead ends. In case after case the *top-level theorem
   is true* (Kamp's theorem holds) but the *chosen intermediate lemma is FALSE* — proven false
   by a counterexample the team itself constructed. Automated churn instrumentation materially
   undercounted this (counters read 0–5 against 18–40 real plan versions), so the three-strikes
   guard never fired.

3. **Literature fidelity correlates with success; formalization shortcuts correlate with
   stalls** (§5, §6). The formalization substituted NF-depth induction + cross-structure
   transfer + arity growth for Rabinovich's witness-count induction in a single structure at
   fixed arity ≤2. Six independent audits (reports 303/20, 305/14, 305/15, 305/22, 305/37,
   305/40) reached the *same* divergence verdict — each only after "10+ failed dispatches."
   Conversely, every landed success (273, 308, 310, 311-v3) succeeded precisely by *removing*
   a formalization artifact and restoring literature fidelity.

4. **The headline recommendation** (§7; expanded in the companion recommendations document):
   the remaining blocker is an *architecture-selection* problem, not a missing-lemma problem
   (settled decision D1). Route **b3** (nested F_i-chain / Rabinovich Cor 5.4 recursion) is the
   only literature-consistent architecture (D2), gated *before* machine-probing by the
   position-by-evaluation-point litmus (D3), with the patch-vs-rebuild decision made explicitly
   in writing: Option A (b3 probe on existing assets) first as a bounded falsifiable probe,
   Option B (interval-EA-formula rebuild with witness-count induction, ~700–1050 lines per
   `305/reports/37` §4.4) pre-authorized as the fallback. Do not enter a fifth carrier
   iteration.

## 2. Arc Overview: Three Eras

Per the research report's Appendix era-chronology:

- **Early (tasks 006–129, 2026-03…05)**: canonical-`TaskFrame` → Int-indexed BFMCS →
  BXCanonical embedding, all killed by F/P non-persistence plus the irreflexive-semantics
  switch (tasks 90/92/98/102), which invalidated the T-axiom-dependent `CanonicalEmbedding`
  path mid-effort (task 088, 434 lines deleted). The chronicle construction was adopted; the
  dense case was closed on ℚ (`dd_countermodel_chronicle_dense`, Cantor iso); the
  discrete/mixed case was left open (tasks 118/122).
- **Middle (tasks 141–301, 2026-05…06)**: expressive completeness of U/S (155/157), Reynolds
  model surgery (202/281) and its k-equivalence bypass; the chronicle path declared dead code
  (task 301); the roadmap collapses to the single k>0 `existPart_succ_n1_bypass` blocker; k=0
  closed (task 273).
- **Recent (tasks 303–321, 2026-06…07)**: Rabinovich §5 k>0 closure attempts; 303 (18 plans)
  and 305 (~40 plans) both blocked on the arity-tower/cross-transfer wall; 307/308/310/311
  spawned; 308/310/311-v3 land sorry-free; 309 reaches the two-anchor k≥2 carrier and hits
  F1→F2→F3→F4; 320 (litmus alignment audit) and 321 (b3 implementation) spawned.

As of the task-301 audit (`specs/301_.../reports/01_completeness-status-audit.md:12-23`),
`completeness_discrete` reduces to a single live sorry via the chain:

```
completeness_discrete → countermodel_discrete_reynolds_v2 → limitdom_is_good
  → no_gaps_discrete_model_surgery → US_expressively_complete_over_prior
  → kamp_prior_expressive_completeness → existPart_succ_n1_bypass (k>0)
```

The Reynolds/model-surgery layers (Layer 2, `GoodStructuresModelSurgery.lean`, 2167 lines;
Layer 3, `ReynoldsBridge.lean`) are sorry-free; the residual hole is Layer 1 (expressive
completeness, Rabinovich/GHR94), today localized to `KampPrior.lean:351`.

**Metric baseline** (reproduced from the research report; git *first-commit* dates are
unreliable — history was rewritten and ~98 commits collapse onto 2026-01-05, so only
last-commit dates and per-task commit counts are trustworthy):

| Task | Commits | Plan versions | Terminal state |
|------|---------|---------------|----------------|
| 093 (BXCanonical embedding) | 175 | 22 | superseded/blocked |
| 155 (expressiveness_general) | ~599 grep-hits | 67 | abandoned (rescoped) |
| 157 (expressive completeness /Z) | 215 | 27 | completed (partial) |
| 202 (Reynolds bypass) | 116 | — | partial/blocked |
| 273 (k=0 KampBypass) | 334 | 39 | **completed** |
| 303 (k>0 depth induction) | 128 | 18 | planned/parked |
| 305 (Rabinovich EA formula) | 232 | ~40 | **blocked** |
| 309 (off-diag two-anchor) | 47 | 7 | **blocked (F4)** |

`Kamp/` totals: 20,459 lines (incl. Boneyard), 327 commits. `NfMultiAnchorBridge.lean` alone
is 5,610 lines / 39 commits — the F1–F4 battleground (first-hand `wc -l`/grep per the report's
verification table).

## 3. The One Obstruction, Three Costumes

Every terminal blocker in the entire arc is an instance of one fact: **a property relating two
independently-chosen points (an interval, a relative order, a joint type) cannot be expressed
from independent one-variable data evaluated at a single point.** (Report F-1.)

| Era | Task(s) | How the obstruction appeared | Citation |
|-----|---------|------------------------------|----------|
| Early | 006, 008, 093 | F/P eventualities do not persist through Lindenbaum extension on a *linear* index (`forward_F`/`backward_P`); once `G(¬χ)` leaks it "propagates forever" | `093/.../59_comprehensive-analysis.md` §3.4–3.5; early dossier §2 |
| Early | 122 | mixed dense/discrete families cannot share one index: `U(⊤,⊥)` false on ℚ, true on ℤ | `122_build.../reports/01_discrete-bfmcs-research.md` §4 |
| Middle | 303 | 1-var NF agreement does **not** determine 2-var NF (`NfComposition.lean`, compositionality FALSE, Z, `[0,2]` vs `[0,1]`) | `303/summaries/02_...md:18-19`; dossier E1–E8 |
| Middle | 305 | `prior_nonconstenv_2var_agree_until` FALSE at K=0 ⇒ all K (Z, evens, `[10,0]` vs `[2,0]`) | `305/handoffs/prior-nonconstenv-false-handoff-20260622.md` |
| Recent | 309 (F1–F4) | a single-point formula cannot assert a relative-position identity `e 1 = w, e 2 = x` between two independently-bound variables (the "flattening" defect) | `309/reports/06_spawn-analysis-f4.md:48-64` |
| Recent | 305/307 | "an x-independent temporal formula at t cannot name a second free anchor x" (`no_x_independent_formula_captures_future_zone_k1`, landed sorry-free) | `305/summaries/40_phase16-gate-no-go-summary.md` |

Both historical remedies are the *same* remedy: the chronicle construction
(`dd_countermodel_chronicle_*`) was adopted specifically to bypass the early linear-index form
(point-insertion over a growing finite domain makes F-eventuality immediate), and the
Rabinovich Cor 5.4 F_i-chain is the corresponding fix for the recent form (joint content
carried by a *nested* evaluation point, not a flat literal). Carry the relative-position
content structurally, not by assertion at a point.

## 4. Recurring Failure Modes

All six diagnostic failure modes from report F-2, each with its sharpest cited example:

1. **Refuted-device churn against home-grown lemmas.** The dominant time sink: propose an
   intermediate lemma, build toward it, then construct a counterexample refuting it —
   repeatedly, because the *true* target is provable but the *chosen* intermediate is not.
   Roster of self-refuted intermediates: `prior_nonconstenv_2var_agree_until/since`,
   `depth0_3var_exist_transfer_until/since`, `nonconstenv_exist_transfer_general`,
   `ExistPart_r`, `GeneralExistPartOrdered`, `BetweenZoneExistPart`, `merge_forward_succ` (not
   a theorem), `neg_2var_vec_ea_indep_backward` (unprovable), and the F1–F4 carriers
   (`bracketEndChar_kv/kvE/kvE'`). (303 dossier E1–E8; 305 dossier §1–§3.)

2. **"The theorem is true, the proof strategy is false."** Stated explicitly at least twice:
   `existPart_succ_n1_bypass` "IS true … The issue is the proof strategy, not the theorem"
   (`305/handoffs/prior-nonconstenv-false-handoff-20260622.md`); F1 "does not refute the
   completeness direction" (`NfMultiAnchorBridge.lean:3884` region). This is the signature of
   an *encoding* problem, not a mathematics problem.

3. **Encoding lock-in / mechanical iteration.** The `nf_eval_nf` encoding (explicit depth +
   arity parameters) is load-bearing across ~20k lines, so each fix patched *within* it. The
   clearest instance is F1→F2→F3→F4: four successive carriers, each "just add another
   channel," each machine-refuted. Task 309's plan v7 finally imposed a "one-round
   uniformization budget" (`309/plans/07:293-294`) precisely to stop this, and F4 triggered
   escalation instead of a fifth carrier.

4. **Arity tower as a pure artifact.** NF-depth induction forces `(k+1,1)→(k,2)→…→(0,k+2)`;
   the chain "breaks at arity 3" because `VVecEA2` handles arity 2
   (`305/reports/15_arity-tower-deviation.md` §3). Rabinovich has *no* arity growth (Lemma
   3.2(2): every ∃∀ formula ≡ a conjunction of ∃∀ formulas with ≤2 free variables). The tower
   is "NOT part of Rabinovich's proof" (`305/reports/14_faithfulness-audit.md`).

5. **Late audit detection.** Every faithfulness/divergence audit reached the correct root
   cause, but only after many dispatches: "The code has been stuck on this for 10+ dispatches"
   (`303/reports/20_literature-divergence-audit.md` §4); "attempted for 10+ dispatches without
   success" (ibid. §recommendation). The diagnosis was always available earlier than it was
   acted on.

6. **Churn instrumentation did not fire.** `303/.orchestrator-churn-state.json` reads
   `total_churn: 0, adversarial_triggers: 0` despite 18 plan versions and 8 refutations;
   `305/.orchestrator-churn-state.json` reads `total_churn: 5` against ~40 plan versions. The
   automated guardrails materially undercount real churn; the plan/handoff corpus is the only
   accurate churn record.

### The F1–F4 refuted-device churn table (recent segment, report F-3)

| Finding | Phase | Carrier device | Refutation (counterexample) | Record |
|---------|-------|----------------|------------------------------|--------|
| **F1** | 13 | `bracketEndChar_kv` (fiber-projected) | Unconditional ∀k correctness FALSE at k=2 soundness; `M=(ℚ,<)`, `u₁,u₂` share depth-1 1-type but differ at arity-4 | `NfMultiAnchorBridge.lean:3884-3947` |
| **F2** | 13.0 | `bracketEndChar_kv` (Prior-relativized) | UZ/SZ-relativized k=2 statement FALSE; **machine-checked** `f2_relativized_refutation`, `M=(ℤ,<)`, `P={0,10,20}` | `:3957`/`:4766-4829`, axioms `[propext, Classical.choice, Quot.sound]` |
| **F3** | 13.3 | `bracketEndChar_kvE` (per-sub enriched) | Single `t`-anchored provider literal `P.existF 3 σ` leaves unpinnable residual `e 1=w, e 2=x`; `M=ℤ`, `σ''=char[14,16,11,20]` | `:5204-5280` |
| **F4** | 13.35 | `bracketEndChar_kvE'` (pin+exclusion channels) | Channel (i) `rfl`-collapses (discards `witnessZone`, positionally vacuous); channel (ii) guard collapses to `⊤`; same ℤ counterexample | `:5532-5608` |

The F-lineage narrows the defect from "carrier reads fibers" (F1/F2) to "the only surviving
joint channel is a single-evaluation-point literal whose private existential rebinds the
anchors" (F3/F4). All four are read-only prose verdict records (no landed sorries), F2
additionally backed by a machine-checked refutation theorem. F2's refutation and the Phase-16
NO-GO (`no_x_independent_formula_captures_future_zone_k1`) are checked theorems — facts, not
beliefs.

## 5. Literature Fidelity vs. Formalization Shortcuts

The audits converge on a single architectural substitution (report F-4, the Divergence Map).
Faithful ("what Rabinovich builds") in the left column; the formalization's shortcut ("what
the code built") in the right. Rabinovich anchors: Def 3.1 (md:61-74), Lemma 3.2(2) (md:76-79),
Prop 3.5 (md:87-94), Prop 4.2 (md:100-101), Lemma 5.1 (md:134-135), Lemma 5.3 (md:137-152),
Cor 5.4 (md:154-157), all in
`~/Projects/Literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.md`.

| Rabinovich 2014 §5 mechanism | Formalization substitute | Verdict |
|------------------------------|--------------------------|---------|
| Induction on **witness count n** (Lemma 5.1/5.3, md:134-152) | Induction on **NF depth k** | "the wrong induction parameter" (`303/reports/20` §3 row 15) |
| Work **within a single structure**; negate an interval formula → V-∃∀ | **Cross-structure NF transfer** between M and N | "the root architectural divergence" (`303/reports/20` §3 row 17) |
| Fixed arity **≤2** (Lemma 3.2(2), md:76-79, the "arity firewall") | **Arity growth** `(k+1,1)→…→(0,k+2)` | "artifact … NOT in Rabinovich" (`305/reports/14`, `305/reports/15`) |
| Interval-typed EA-formula datatype; negation closure (Prop 4.2, md:100-101) | Doets `NormalForm` with **no interval structure** | "missing interval normal form" (`303/reports/20` §4 root cause #3) |
| Joint content via **nested Until evaluation point** (Cor 5.4, md:154-157: `F_{i-1}:=α_{i-1}∧(β_i Until F_i)`) | Joint content **flattened into a single-point literal** | the F3/F4 "flattening" defect (`309/reports/06:48-64`) |
| Position identity by evaluation position (Prop 3.5, md:87-94, single-free-var nesting) | Position identity by **asserting an equality between two bound vars** at one point | refuted "on sight" by the litmus (`320/reports/01`, Rec 2) |

**The b1/b2/b3 verdict (task 320 alignment audit).** Routes b1 (repair the pin to consume
`witnessZone`) and b2 (structural-identity via `nf_eval_unique`) are **formalization-
engineering shortcuts with no counterpart in either Rabinovich or Gabbay** — they "try to
*solve* a problem the literature *never creates*" — while **b3 (nested F_i-chain) is the
literature-faithful mechanism** (`320/reports/01:31-37`). Gabbay's separation route
independently avoids the same joint single-point assertion, confirming the departure is from
the *whole corpus*, not one paper.

Divergence was detected late every single time: six independent audits (reports 303/20,
305/14, 305/15, 305/22, 305/37, 305/40) reached the same verdict, each only after ~10 failed
dispatches. The audits were run as post-mortems rather than as design gates (report F-6.2).

## 6. What Worked and Why

The positive signal (report F-5):

| Task | What landed | Why it succeeded |
|------|-------------|------------------|
| 273 | k=0 KampBypass, ~1400 lines sorry-free (`BracketFormula k` encoding fix) | The k=0 case has singleton fibers; no joint two-anchor problem arises |
| 308 | `nf_char2_formula` + `nf_zone_flatten_navigable`, 578 lines, 0 sorries | Diagonal / single-collapsed-anchor case (`x=t`); never needs off-diagonal joint pinning; hook-parametric split keeps anchor set `{x,t}` |
| 310 | `NfEFold.lean` E[Σ]-fold engine, sorry-free | **Removed** the arity-growth artifact — restored Rabinovich Def 4.1's monadic E[Σ]-atom |
| 311-v3 | `bracketEndChar_k1v_correct` (k=1), sorry-free | **Removed** the fixed one-witness codomain — replaced `VecEA2 1` with witness-growing `VVecEA2` (G6 amendment), Rabinovich-licensed by Lemma 3.4 |

The pattern is unambiguous: **every success removed a Lean-encoding artifact and moved
*toward* the literature; every stall came from patching *within* the artifact.** The chronicle
adoption (early era) and the dense-case closure on ℚ (`dd_countermodel_chronicle_dense`,
Cantor iso) are older instances of the same "align with the literature construction" success.

Also working, and preserved as house style: the **decision-gate / verdict-record practice**
(F1–F4 records, 311-v1/v2 NO-GO, the Phase-16 NO-GO landed as
`no_x_independent_formula_captures_future_zone_k1`). It converts a failed attempt into a
*bankable, machine-checked* obstruction with zero landed sorries, and it is what prevented the
F-cycle from silently accumulating debt.

## 7. Root-Cause Synthesis and Settled Decisions

Why convergence has been slow (report F-6):

1. **Wrong-substrate lock-in.** The `nf_eval_nf` depth/arity encoding is the wrong abstraction
   for Rabinovich's proof, but it is baked into ~20k lines and the "consume-do-not-rebuild"
   asset lists (e.g. `309/plans/07:142-197`). Every fix was therefore forced to be a *carrier
   on top of* the wrong substrate — exactly the F1→F4 mechanical-iteration trap.
2. **Diagnosis/action latency.** The correct root cause was written down repeatedly (reports
   303/20, 305/14/15/22/37/40) but each time only after ~10 dispatches; audits ran as
   post-mortems, not design gates.
3. **Instrumentation blind spot.** Churn counters read 0–5 while real churn was 18–40 plan
   versions; the three-strikes guard could not fire because it was not seeing the strikes.
4. **True novelty at the base.** Task 113's literature review found "no paper addresses the
   full BX combination" (S5 + U/S + strict irreflexive order + chronicle). The
   irreflexive-semantics switch (tasks 90/92/98/102) invalidated the T-axiom-dependent
   `CanonicalEmbedding` path mid-effort (`088`, 434 lines deleted). Some churn is irreducible
   frontier cost — but the *k>0* wall specifically is not novel; it is Rabinovich §5, and the
   slowness there is self-inflicted by (1)–(3).

**Settled decisions** (from the research report; do not re-open without a concrete
counterexample):

- **D1.** The remaining blocker is an **architecture-selection** problem, not a missing-lemma
  problem. Rabinovich's proof is available; the question is whether to *reach* it by patching
  or rebuilding.
- **D2.** Route **b3** (nested F_i-chain / Cor 5.4) is the only route consistent with the
  literature; b1 and b2 are shortcuts that relocate rather than remove the obstruction and
  should not consume the design budget (already the standing conclusion of tasks 320/321).
- **D3.** The "position-by-evaluation-point litmus" is the correct GO gate and is applied
  *before* machine-probing, not after.
- **Rec-1 (strengthened form).** The patch-vs-rebuild decision is presented as
  A-probe-first-with-B-pre-authorized: Option A (b3 nested sub-bracket on the landed
  `fChainFrom`/`fChainPred` + `VVecEA2` assets, tasks 320/321 as scoped) runs first as a
  bounded, falsifiable probe; Option B (interval-EA-formula rebuild, ~700–1050 lines per
  `305/reports/37` §4.4) is pre-authorized as the fallback if the probe fails the litmus.

## 8. Sorry-Count Clarification Box

> **Which sorry count is correct — 42, 113, or 1?** All three, at different filters (report
> Contradiction Log, resolved; precedence: direct machine evidence > agent summary):
>
> - **113**: first-hand `grep -rn sorry ... | grep -v Boneyard | wc -l` over `Metalogic/` —
>   counts every `sorry` token including prose/comment occurrences and documented-dead sites.
> - **42**: the git/Lean dossier's strict filter (enclosing declaration inspected) — counts
>   "tactic sorry" sites only.
> - **1**: the *live-critical-path* count both filters agree on — `KampPrior.lean:351` (the
>   `n=1` arm of `nf_nvar_exist_all_depths`), with `:354` off-path and the
>   EANegation/Chronicle/Truth-Lemma sorries documented non-blocking or dead.
>
> No downstream claim depends on the exact token total. Any future citation of a sorry count
> for this lineage must reproduce this both-correct-at-different-filters resolution, not pick
> one number silently.

---

## Provenance

This review is derived entirely from the H4-verified research report
`specs/322_review_discrete_logic_completeness_retrospective/reports/01_completeness-retrospective.md`
(Tier 1, literature-backed); no new evidence was gathered and no citation was weakened from
the report's file:line / md:NN anchor form. The report's Adversarial Self-Verification table
assigns **High** confidence to the live-blocker location (`KampPrior.lean:351`, first-hand
grep), the F1/F2 record anchors (`NfMultiAnchorBridge.lean:3884`/`:3957`, first-hand grep/wc),
the 7-step reduction chain, the compositionality and `prior_nonconstenv` refutations, the
arity-tower-artifact verdict, the b3-faithful/b1-b2-shortcut verdict, the plan-version counts,
and the churn-counter undercount; **Medium-High** to the F2 machine-check claim (task summary
+ dossier, not re-run first-hand); and **Medium** to the ~113 sorry-token count
(filter-sensitive, resolved in §8). One contradiction (42 vs 113 sorry counts) was surfaced
and resolved; no unresolved contradictions remain.
