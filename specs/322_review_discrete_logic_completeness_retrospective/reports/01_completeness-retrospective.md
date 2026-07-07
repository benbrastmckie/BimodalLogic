# Research Report: Discrete-Logic Completeness Effort — Full-Arc Retrospective

- **Task**: 322 - review_discrete_logic_completeness_retrospective
- **Started**: 2026-07-07T00:00:00Z
- **Completed**: 2026-07-07T00:00:00Z
- **Effort**: ~4 hours (6 parallel evidence-gathering agents + synthesis)
- **Dependencies**: None (diagnostic/retrospective; consumes artifacts of tasks 006–321)
- **Sources/Inputs**:
  - Early era task dirs (archived): 006, 008, 018, 072, 086, 088, 093, 105, 113, 118, 122, 129
  - Middle era task dirs: 141, 142, 155, 157, 163, 197, 202, 240, 255, 271, 273, 281, 301 (mostly `specs/archive/`)
  - Recent era task dirs: 303, 305, 306, 307, 308, 309, 310, 311, 320, 321 (`specs/`)
  - Lean tree: `Theories/Bimodal/Metalogic/` (esp. `WeakCanonical/Kamp/`), F1–F4 verdict records in `NfMultiAnchorBridge.lean`, `KampPrior.lean`
  - `specs/ROADMAP.md`, `specs/state.json`, git history over `Theories/Bimodal/Metalogic/`
  - Literature: `~/Projects/Literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.md`
- **Artifacts**: this report
- **Standards**: status-markers.md, artifact-management.md, tasks.md, report-format.md

## Scope Note (Retrospective, Not a Proof Task)

This is a diagnostic review of the entire completeness lineage, not an attempt to close any
goal. Per the task-322 steering correction, the arc surveyed runs from the *earliest* canonical-
model work (task 006, 2026-03) through the current F4 blocker (tasks 309/320/321, 2026-07) — the
305–321 F1–F4 cycle is only the most recent segment. Every load-bearing claim is cited to a task
artifact, a Lean file:line, a commit, or the Rabinovich source. First-hand verifications of the
Lean state are marked in the Adversarial Self-Verification section.

## Executive Summary

- The effort is enormous and largely *sound*: ~20,459 lines of Lean under `Kamp/` alone, 327
  commits touching that directory, and the discrete-completeness blocker has been correctly
  narrowed to a single conceptual hole (`KampPrior.lean:351`, the `n=1` arm of
  `nf_nvar_exist_all_depths`). Soundness is sorry-free throughout; the k=0 case is fully closed
  (task 273, ~1400 lines).
- **One mathematical fact has blocked the effort at every era**, wearing three different costumes:
  you cannot recover a *joint two-point / interval / relative-position* property at a *single
  evaluation point* from independent one-variable data. It appears as (early) F/P non-persistence
  through Lindenbaum on a linear index; (middle) "1-var NF agreement does not determine 2-var NF"
  and the "between-zone is a 2-variable property" refutations; (recent) the F1–F4 "flattening"
  defect — a single-point formula cannot assert a relative-position identity between two
  independently-bound variables.
- **The dominant failure mode is refuted-device churn against one's own intermediate lemmas.**
  Task 305 went through ~40 plan versions; task 303 through 18; the archived BXCanonical task 093
  through 22 plan versions / 175 commits / 45+ recorded dead ends. In case after case the
  *top-level theorem is true* (Kamp's theorem holds) but the *intermediate lemma as stated is
  FALSE* — proven false by a concrete counterexample the team itself constructed
  (`prior_nonconstenv_2var_agree_until`, `ExistPart_r`, `GeneralExistPartOrdered`,
  `merge_forward_succ`, F1–F4). Huge effort was spent refuting home-grown lemmas.
- **Literature fidelity vs. formalization shortcut is the crux divergence, and it was detected
  late every single time.** The formalization substituted NF-depth induction + cross-structure
  transfer + arity growth for Rabinovich's witness-count induction in a single structure at fixed
  arity ≤2. Six independent audits (reports 303/20, 305/14, 305/15, 305/22, 305/37, 305/40)
  reached the *same* verdict — but each only after "10+ failed dispatches."
- **The successes point the way.** Tasks 308, 310, and 311-v3 each landed sorry-free precisely by
  *removing a formalization artifact and restoring literature fidelity* (arity growth → Rabinovich
  E[Σ]-fold; fixed one-witness codomain → witness-growing `VVecEA2`). Progress correlated with
  alignment to Rabinovich, never with a cleverer flattening.
- **Recommendation headline**: adopt route **b3** (nested F_i-chain / Cor 5.4 recursion) as the
  *only* sanctioned architecture and gate every design on the "position-by-evaluation-point"
  litmus *before* machine-probing; but first make an explicit strategic decision between (A)
  patching b3 onto the existing `nf_eval_nf` carrier assets and (B) the deeper rebuild the audits
  keep pointing at (an interval-typed EA-formula datatype with witness-count induction, which the
  codebase still lacks). Slow convergence is now mostly an *architecture-selection* problem, not a
  proof-engineering one.

## Context & Scope

The target theorem is `completeness_discrete` for the bimodal logic TM. As of the task-301 audit
(`specs/301_.../reports/01_completeness-status-audit.md:12-23`) it reduces to a single live sorry
via the chain:

```
completeness_discrete → countermodel_discrete_reynolds_v2 → limitdom_is_good
  → no_gaps_discrete_model_surgery → US_expressively_complete_over_prior
  → kamp_prior_expressive_completeness → existPart_succ_n1_bypass (k>0)
```

The Reynolds/model-surgery layers (Layer 2, `GoodStructuresModelSurgery.lean`, 2167 lines; Layer
3, `ReynoldsBridge.lean`) are sorry-free; the residual hole is Layer 1 (expressive completeness,
Rabinovich/GHR94). Tasks 303 and 305–321 are all attempts to close that k>0 / depth-k≥2 hole,
today localized to `KampPrior.lean:351` (`nf_nvar_exist_all_depths`, n=1 arm — verified
first-hand, see Adversarial Self-Verification).

Metric baseline (git/Lean survey; note the git *first-commit* dates are unreliable — the history
was rewritten and ~98 commits collapse onto 2026-01-05, so only last-commit dates and per-task
commit counts are trustworthy):

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

`Kamp/` totals: 20,459 lines (incl. Boneyard), 327 commits. `NfMultiAnchorBridge.lean` alone is
5,610 lines / 39 commits (the F1–F4 battleground). `Metalogic/` currently has 113 sorry-token
sites (verified first-hand), the vast majority documented as dead-code or off-critical-path.

## Findings

### Reference-Grounding Tier

This retrospective is **Tier 1 (literature-backed)**: the load-bearing verdicts about *where the
formalization diverged from the mathematics* are grounded in Rabinovich 2014 §5 (via the task
audits that cite it verbatim) and Gabbay 1994 (via task 320's alignment audit). The lemma-level
mapping of "what the code built vs. what the literature builds" is the Divergence Map below (F-6).

### F-1. The single recurring obstruction (the through-line across all three eras)

Every terminal blocker in the entire arc is an instance of one fact: **a property relating two
independently-chosen points (an interval, a relative order, a joint type) cannot be expressed from
independent one-variable data evaluated at a single point.**

| Era | Task(s) | How the obstruction appeared | Citation |
|-----|---------|------------------------------|----------|
| Early | 006, 008, 093 | F/P eventualities do not persist through Lindenbaum extension on a *linear* index (`forward_F`/`backward_P`); once `G(¬χ)` leaks it "propagates forever" | `093/.../59_comprehensive-analysis.md` §3.4–3.5; early dossier §2 |
| Early | 122 | mixed dense/discrete families cannot share one index: `U(⊤,⊥)` false on ℚ, true on ℤ | `122_build.../reports/01_discrete-bfmcs-research.md` §4 |
| Middle | 303 | 1-var NF agreement does **not** determine 2-var NF (`NfComposition.lean`, compositionality FALSE, Z, `[0,2]` vs `[0,1]`) | `303/summaries/02_...md:18-19`; dossier E1–E8 |
| Middle | 305 | `prior_nonconstenv_2var_agree_until` FALSE at K=0 ⇒ all K (Z, evens, `[10,0]` vs `[2,0]`) | `305/handoffs/prior-nonconstenv-false-handoff-20260622.md` |
| Recent | 309 (F1–F4) | a single-point formula cannot assert a relative-position identity `e 1 = w, e 2 = x` between two independently-bound variables (the "flattening" defect) | `309/reports/06_spawn-analysis-f4.md:48-64` |
| Recent | 305/307 | "an x-independent temporal formula at t cannot name a second free anchor x" (`no_x_independent_formula_captures_future_zone_k1`, landed sorry-free) | `305/summaries/40_phase16-gate-no-go-summary.md` |

The chronicle construction (`dd_countermodel_chronicle_*`) was adopted specifically to *bypass*
the early linear-index form (point-insertion over a growing finite domain makes F-eventuality
immediate). The Rabinovich Cor 5.4 F_i-chain is the corresponding fix for the recent form (joint
content carried by a *nested* evaluation point, not a flat literal). Both are the *same* remedy:
carry the relative-position content structurally, not by assertion at a point.

### F-2. Recurring failure modes (diagnostic)

1. **Refuted-device churn against home-grown lemmas.** The dominant time sink is proposing an
   intermediate lemma, building toward it, then constructing a counterexample that refutes it —
   repeatedly, because the *true* target is provable but the *chosen* intermediate is not. Roster
   of self-refuted intermediates: `prior_nonconstenv_2var_agree_until/since`,
   `depth0_3var_exist_transfer_until/since`, `nonconstenv_exist_transfer_general`, `ExistPart_r`,
   `GeneralExistPartOrdered`, `BetweenZoneExistPart`, `merge_forward_succ` (not a theorem),
   `neg_2var_vec_ea_indep_backward` (unprovable), and the F1–F4 carriers
   (`bracketEndChar_kv/kvE/kvE'`). (303 dossier E1–E8; 305 dossier §1–§3.)

2. **"The theorem is true, the proof strategy is false."** Stated explicitly at least twice:
   `existPart_succ_n1_bypass` "IS true … The issue is the proof strategy, not the theorem"
   (`305/handoffs/prior-nonconstenv-false-handoff-20260622.md`); F1 "does not refute the
   completeness direction" (`NfMultiAnchorBridge.lean:3884` region). This is the signature of an
   *encoding* problem, not a mathematics problem.

3. **Encoding lock-in / mechanical iteration.** The `nf_eval_nf` encoding (explicit depth + arity
   parameters) is load-bearing across ~20k lines, so each fix patched *within* it. The clearest
   instance is F1→F2→F3→F4: four successive carriers, each "just add another channel," each
   machine-refuted. Task 309's plan v7 finally imposed a "one-round uniformization budget"
   (`309/plans/07:293-294`) precisely to stop this, and F4 triggered escalation instead of a fifth
   carrier.

4. **Arity tower as a pure artifact.** NF-depth induction forces `(k+1,1)→(k,2)→…→(0,k+2)`; the
   chain "breaks at arity 3" because `VVecEA2` handles arity 2 (`305/reports/15_arity-tower-
   deviation.md` §3). Rabinovich has *no* arity growth (Lemma 3.2(2): every ∃∀ formula ≡ a
   conjunction of ∃∀ formulas with ≤2 free variables). The tower is "NOT part of Rabinovich's
   proof" (`305/reports/14_faithfulness-audit.md`).

5. **Late audit detection.** Every faithfulness/divergence audit reached the correct root cause,
   but only after many dispatches: "The code has been stuck on this for 10+ dispatches"
   (`303/reports/20_literature-divergence-audit.md` §4); "attempted for 10+ dispatches without
   success" (ibid. §recommendation). The diagnosis was always available earlier than it was acted
   on.

6. **Churn instrumentation did not fire.** `303/.orchestrator-churn-state.json` reads
   `total_churn: 0, adversarial_triggers: 0` despite 18 plan versions and 8 refutations;
   `305/.orchestrator-churn-state.json` reads `total_churn: 5` against ~40 plan versions. The
   automated guardrails materially undercount the real churn; the plan/handoff corpus is the only
   accurate churn record.

### F-3. Refuted-device churn table (the F1–F4 core, recent segment)

| Finding | Phase | Carrier device | Refutation (counterexample) | Record |
|---------|-------|----------------|------------------------------|--------|
| **F1** | 13 | `bracketEndChar_kv` (fiber-projected) | Unconditional ∀k correctness FALSE at k=2 soundness; `M=(ℚ,<)`, `u₁,u₂` share depth-1 1-type but differ at arity-4 | `NfMultiAnchorBridge.lean:3884-3947` |
| **F2** | 13.0 | `bracketEndChar_kv` (Prior-relativized) | UZ/SZ-relativized k=2 statement FALSE; **machine-checked** `f2_relativized_refutation`, `M=(ℤ,<)`, `P={0,10,20}` | `:3957`/`:4766-4829`, axioms `[propext, Classical.choice, Quot.sound]` |
| **F3** | 13.3 | `bracketEndChar_kvE` (per-sub enriched) | Single `t`-anchored provider literal `P.existF 3 σ` leaves unpinnable residual `e 1=w, e 2=x`; `M=ℤ`, `σ''=char[14,16,11,20]` | `:5204-5280` |
| **F4** | 13.35 | `bracketEndChar_kvE'` (pin+exclusion channels) | Channel (i) `rfl`-collapses (discards `witnessZone`, positionally vacuous); channel (ii) guard collapses to `⊤`; same ℤ counterexample | `:5532-5608` |

The F-lineage narrows the defect from "carrier reads fibers" (F1/F2) to "the only surviving joint
channel is a single-evaluation-point literal whose private existential rebinds the anchors"
(F3/F4). All four are read-only prose verdict records (no landed sorries), F2 additionally backed
by a machine-checked refutation theorem — this "verdict-record house style" is a *positive*
practice (see F-5).

### F-4. Where literature fidelity and formalization shortcuts diverged (Divergence Map)

The audits converge on a single architectural substitution. Faithful ("what Rabinovich builds")
in the left column; the formalization's shortcut ("what the code built") in the right.

| Rabinovich 2014 §5 mechanism | Formalization substitute | Verdict |
|------------------------------|--------------------------|---------|
| Induction on **witness count n** (Lemma 5.1/5.3) | Induction on **NF depth k** | "the wrong induction parameter" (`303/reports/20` §3 row 15) |
| Work **within a single structure**; negate an interval formula → V-∃∀ | **Cross-structure NF transfer** between M and N | "the root architectural divergence" (`303/reports/20` §3 row 17) |
| Fixed arity **≤2** (Lemma 3.2(2), the "arity firewall") | **Arity growth** `(k+1,1)→…→(0,k+2)` | "artifact … NOT in Rabinovich" (`305/reports/14`, `305/reports/15`) |
| Interval-typed EA-formula datatype; negation closure (Prop 4.2) | Doets `NormalForm` with **no interval structure** | "missing interval normal form" (`303/reports/20` §4 root cause #3) |
| Joint content via **nested Until evaluation point** (Cor 5.4: `F_{i-1}:=α_{i-1}∧(β_i Until F_i)`) | Joint content **flattened into a single-point literal** | the F3/F4 "flattening" defect (`309/reports/06:48-64`) |
| Position identity by evaluation position (Prop 3.5 single-free-var nesting) | Position identity by **asserting an equality between two bound vars** at one point | refuted "on sight" by the litmus (`320/reports/01`, Rec 2) |

Task 320's alignment audit adds the sharpest framing: routes b1 (repair the pin to consume
`witnessZone`) and b2 (structural-identity via `nf_eval_unique`) are **formalization-engineering
shortcuts with no counterpart in either Rabinovich or Gabbay** — they "try to *solve* a problem
the literature *never creates*" — while **b3 (nested F_i-chain) is the literature-faithful
mechanism** (`320/reports/01:31-37`). Gabbay's separation route independently avoids the same joint
single-point assertion, confirming the departure is from the *whole corpus*, not one paper.

### F-5. What actually worked, and why (the positive signal)

| Task | What landed | Why it succeeded |
|------|-------------|------------------|
| 273 | k=0 KampBypass, ~1400 lines sorry-free (`BracketFormula k` encoding fix) | The k=0 case has singleton fibers; no joint two-anchor problem arises |
| 308 | `nf_char2_formula` + `nf_zone_flatten_navigable`, 578 lines, 0 sorries | Diagonal / single-collapsed-anchor case (`x=t`); never needs off-diagonal joint pinning; hook-parametric split keeps anchor set `{x,t}` |
| 310 | `NfEFold.lean` E[Σ]-fold engine, sorry-free | **Removed** the arity-growth artifact — restored Rabinovich Def 4.1's monadic E[Σ]-atom |
| 311-v3 | `bracketEndChar_k1v_correct` (k=1), sorry-free | **Removed** the fixed one-witness codomain — replaced `VecEA2 1` with witness-growing `VVecEA2` (G6 amendment), Rabinovich-licensed by Lemma 3.4 |

The pattern is unambiguous: **every success removed a Lean-encoding artifact and moved *toward*
the literature; every stall came from patching *within* the artifact.** The chronicle adoption
(early era) and the dense-case closure on ℚ (`dd_countermodel_chronicle_dense`, Cantor iso) are
older instances of the same "align with the literature construction" success.

Also working and worth preserving: the **decision-gate / verdict-record house style** (F1–F4,
311-v1/v2 NO-GO, the Phase-16 NO-GO landed as `no_x_independent_formula_captures_future_zone_k1`).
It converts a failed attempt into a *bankable, machine-checked* obstruction with zero landed
sorries, and it is what prevented the F-cycle from silently accumulating debt.

### F-6. Why convergence has been slow (root-cause synthesis)

1. **Wrong-substrate lock-in.** The `nf_eval_nf` depth/arity encoding is the wrong abstraction for
   Rabinovich's proof, but it is baked into ~20k lines and the "consume-do-not-rebuild" asset
   lists (e.g. `309/plans/07:142-197`). Every fix was therefore forced to be a *carrier on top of*
   the wrong substrate, which is exactly the F1→F4 mechanical-iteration trap.

2. **Diagnosis/action latency.** The correct root cause was written down repeatedly (reports
   303/20, 305/14/15/22/37/40) but each time only after ~10 dispatches. The audits were run as
   *post-mortems* rather than as *design gates*.

3. **Instrumentation blind spot.** Churn counters read 0–5 while real churn was 18–40 plan
   versions; the three-strikes guard could not fire because it was not seeing the strikes.

4. **True novelty at the base.** Task 113's literature review found "no paper addresses the full BX
   combination" (S5 + U/S + strict irreflexive order + chronicle). The irreflexive-semantics switch
   (tasks 90/92/98/102) invalidated the T-axiom-dependent `CanonicalEmbedding` path mid-effort
   (`088`, deleted 434 lines). So some churn is irreducible frontier cost — but the *k>0* wall
   specifically is not novel; it is Rabinovich §5, and the slowness there is self-inflicted by (1)–(3).

## Decisions

This is a retrospective; it makes no code changes. It records the following *diagnostic
conclusions* as inputs to the next plan:

- D1. The remaining blocker is an **architecture-selection** problem, not a missing-lemma problem.
  Rabinovich's proof is available; the question is whether to *reach* it by patching or rebuilding.
- D2. Route **b3** (nested F_i-chain / Cor 5.4) is the only route consistent with the literature;
  b1 and b2 are shortcuts that relocate rather than remove the obstruction and should not consume
  the design budget (already the standing conclusion of tasks 320/321).
- D3. The "position-by-evaluation-point litmus" is the correct GO gate and should be applied
  *before* machine-probing, not after.

## Recommendations (prioritized)

1. **[Strategic, do first] Make the patch-vs-rebuild decision explicitly, in writing, before the
   next implementation dispatch.** The audits (303/20 root cause #3, 305/14/15/24/37/40) repeatedly
   point past b3-on-existing-assets toward the deeper fix the codebase still lacks: an
   *interval-typed EA-formula datatype* with *witness-count induction* faithful to Rabinovich §5.
   Option A (patch: b3 nested sub-bracket on the landed `fChainFrom`/`fChainPred` + `VVecEA2`
   assets, tasks 320/321 as scoped) is cheaper and continues current momentum. Option B (rebuild:
   introduce the interval EA-formula type + Lemma 3.2(2) arity firewall + witness-count induction,
   ~700–1050 lines per `305/reports/37` §4.4) is the audits' actual recommendation and removes the
   substrate that has generated four straight refutations. **Recommend Option A first as a bounded,
   falsifiable probe (it is already de-risked by task 320's litmus), with Option B pre-authorized
   as the fallback if the b3 probe fails the litmus** — do not enter a fifth carrier iteration.
   Owner: planner (task 321 plan / task 309 v8 re-point).

2. **Adopt the position-by-evaluation-point litmus as a hard design gate.** Reject on sight any
   candidate that asserts a two-anchor positional identity inside a one-point formula
   (`320/reports/01` Rec 2). This single rule would have predicted F3→F4 a priori. Encode it as an
   explicit checklist item in the plan's guard set (it generalizes G3/G5). Owner: planner.

3. **Run the faithfulness audit as a design *gate*, not a post-mortem.** Before any new carrier or
   converter is built, require a one-paragraph mapping of each proof step to a specific Rabinovich
   §5 result (the G5 discipline already exists; make it a *precondition* of dispatch, not a
   reporting requirement). Every past audit found the same divergence eventually — move it to the
   front. Owner: research/planner.

4. **Fix or replace the churn instrumentation.** Counters that read 0–5 against 18–40 real plan
   versions cannot enforce a three-strikes budget. Count *plan versions targeting the same leaf*
   and *self-refuted intermediate lemmas*, not just orchestrator re-dispatches. Trip escalation at
   three self-refutations on one target (the F4 escalation is the model to institutionalize).
   Owner: orchestration/meta.

5. **Preserve the verdict-record house style and extend it.** The F1–F4 records and the landed
   NO-GO theorems are the effort's best hygiene practice. Continue: no landed sorry on any live
   path, every NO-GO captured as a machine-checked obstruction or a cited prose verdict, all prior
   exhibits byte-preserved. Owner: implementer.

6. **Scope the next b3 probe minimally.** A single nested-Until sub-bracket at k=2 using the
   codebase's own labelled Cor-5.4 shapes (`fChainFrom`/`fChainPred`, `EANegation:552/:567`),
   evaluated at the honest point, tested against the mandatory F4 ℤ counterexample (`M=ℤ`,
   `p={0}`, `r={13}`, `x=10`, `t=20`, `σ''=char[14,16,11,20]`, honest `char[14,15,10,20]` false).
   No full carrier surgery until the minimal probe passes the litmus. Owner: implementer (task 321).

7. **Do not reopen the barred routes.** Provider-side pinning (route a, F-A circularity), the
   `nvar_transfer`/cross-structure-transfer family (303 postmortem, 2 independent vacuity audits),
   the arity-tower descent, and any flat-carrier "kvE''" iteration are all refuted and should stay
   closed. Owner: all.

## Risks & Mitigations

- **Risk: b3-on-existing-assets inherits the same substrate defect and produces an F5.** Mitigation:
  Recommendation 1's litmus-gated minimal probe surfaces this in a bounded dispatch; Option B is
  pre-authorized so an F5 escalates directly to the rebuild rather than a sixth carrier.
- **Risk: the rebuild (Option B) is a multi-week effort on the critical path.** Mitigation: it is
  additive (new interval EA-formula type) and reuses the sorry-free k=0/k=1 kit (273, 308, 310,
  311); the ~700–1050 line estimate is the audits', and it retires the recurring cost rather than
  paying it again.
- **Risk: retrospective relies on task-artifact self-reports that could overstate rigor.**
  Mitigation: the F1/F2 records and the Phase-16 NO-GO are machine-checked
  (`f2_relativized_refutation`, `no_x_independent_formula_captures_future_zone_k1`,
  axioms `[propext, Classical.choice, Quot.sound]`); key file:line anchors verified first-hand
  (see below).

## Adversarial Self-Verification

Applied the Claim Verification Bar to every load-bearing claim. `lean_hover_info`-style checks
were done via direct `grep`/`Read` on the live tree (retrospective, so file:line existence is the
relevant verification, not goal-state).

| Claim | Source/Counterexample | Verification Method | Confidence |
|-------|------------------------|---------------------|------------|
| Live blocker is `KampPrior.lean:351`, `n=1` arm of `nf_nvar_exist_all_depths` | 301 audit + first-hand grep: `:351 sorry`, `:354 sorry`, docstring `:197` "key construction for eliminating the critical-path sorry" | first-hand grep of `KampPrior.lean` | High |
| `NfMultiAnchorBridge.lean` is 5,610 lines and holds F1/F2 records at :3884/:3957 | first-hand `wc -l` (5610) + grep hits `F1` :3884, F2 probe :3957 | first-hand grep/wc | High |
| F2 is machine-checked (`f2_relativized_refutation`, axioms `[propext, Classical.choice, Quot.sound]`) | `309/summaries/06_phase-13-0-f2-probe-summary.md`; git/Lean dossier | task summary + dossier (not re-run first-hand) | Medium-High |
| Metalogic has ~113 live sorry-token sites, most dead-code/off-path | first-hand `grep -rn sorry ... | grep -v Boneyard | wc -l` → 113; git dossier breakdown (42 "live" tokens by stricter filter) | first-hand grep (count sensitive to filter) | Medium |
| `completeness_discrete` reduces to the single k>0 sorry via the 7-step chain | `301/reports/01:14-23`, `ROADMAP.md:49-58` | two independent artifacts agree | High |
| Compositionality (1-var NF ⇏ 2-var NF) is FALSE, Z `[0,2]`/`[0,1]` | `303/summaries/02:18-19`; `NfComposition.lean` counterexample cited across 303 handoffs | multiple 303 artifacts | High |
| `prior_nonconstenv_2var_agree_until` FALSE at K=0 ⇒ all K | `305/handoffs/prior-nonconstenv-false-handoff-20260622.md` | task handoff (concrete counterexample) | High |
| Arity tower is a formalization artifact, not in Rabinovich | `305/reports/14`, `305/reports/15` §3; Lemma 3.2(2) ≤2 cap | two audits + literature citation | High |
| Successes (308/310/311-v3) each removed an artifact and restored fidelity | 308/310/311 summaries; 311 faithfulness audit | task summaries | High |
| b3 is literature-faithful; b1/b2 are shortcuts absent from Rabinovich AND Gabbay | `320/reports/01:23-37` | dedicated alignment audit (2 sources) | High |
| ~40 plan versions (305), 18 (303), 22/175 commits (093) | plan-file enumeration in each task dir; git commit counts | first-hand `ls`/git + dossiers | High |
| Churn counters undercount (303: total_churn 0 vs 18 plans) | first-hand `cat .orchestrator-churn-state.json` | first-hand read | High |

**Contradiction Log.** One apparent contradiction surfaced and was resolved:

- Sorry-count figures differ: the git/Lean dossier reports **42 "live" sorry tokens** (strict
  filter, enclosing-decl inspected) while my first-hand `grep | grep -v Boneyard | wc -l` returned
  **113**. Resolution (precedence: direct machine evidence > agent summary): both are correct at
  different filters — 113 counts every `sorry` token including prose/comment occurrences and
  documented-dead sites; 42 counts stricter "tactic sorry" sites; the *live-critical-path* count
  both agree on is effectively **one** (`KampPrior.lean:351`), with `:354` off-path and the
  EANegation/Chronicle/Truth-Lemma sorries documented non-blocking or dead. No downstream claim
  depends on the exact token total. **Resolved.**

No unresolved contradictions. No forbidden verification outputs were used: every "the code has X"
claim is backed by a file:line or a first-hand grep, not by "mathlib/the code likely has this."

Recommendations modified after verification: none reversed; Recommendation 1 was *strengthened*
(from "do b3" to "make the patch-vs-rebuild decision explicit, b3-probe-first with rebuild
pre-authorized") after the divergence-audit evidence (303/20 root cause #3, 305/37 §4.4) showed the
audits point past b3-on-existing-assets toward the interval-EA-formula rebuild.

## Appendix

- **Eras and their pivots**:
  - *Early (006–129, 2026-03…05)*: canonical-`TaskFrame` → Int-indexed BFMCS → BXCanonical
    embedding, all killed by F/P non-persistence + the irreflexive-semantics switch; chronicle
    construction adopted; dense case closed on ℚ; discrete/mixed case left open (118/122).
  - *Middle (141–301, 2026-05…06)*: expressive completeness of U/S (155/157), Reynolds model
    surgery (202/281) and its k-equivalence bypass, chronicle path declared dead code (301);
    roadmap collapses to the single k>0 `existPart_succ_n1_bypass` blocker; k=0 closed (273).
  - *Recent (303–321, 2026-06…07)*: Rabinovich §5 k>0 closure; 303 (18 plans) and 305 (~40 plans)
    both blocked on the arity-tower/cross-transfer wall; 307/308/310/311 spawned; 308/310/311-v3
    land; 309 reaches the two-anchor k≥2 carrier and hits F1→F2→F3→F4; 320 (litmus audit) + 321
    (b3 implementation) spawned.
- **Key Lean anchors** (all under `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/`):
  `KampPrior.lean:351` (live blocker); `NfMultiAnchorBridge.lean` F1 :3884, F2 :3957/:4766, F3
  :5204, F4 :5532; carriers `bracketEndChar_kv` :3630, `kvE` :5150, `kvE'` region incl.
  `kvE_pinDisjunct` :5374 / `kvE_exclConj` :5387; `NfEFold.lean` (task 310 fold engine);
  `fChainFrom`/`fChainPred` `EANegation.lean:552/:567` (Cor 5.4 candidate shapes).
- **Literature**: `~/Projects/Literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.md`
  — Def 3.1 (md:61-74), Lemma 3.2(2) ≤2 cap (md:76-79), Prop 3.5 (md:87-94), Prop 4.2 (md:100-101),
  Lemma 5.1 (md:134-135), Lemma 5.3 (md:137-152), Cor 5.4 (md:154-157).
- **Evidence provenance**: six parallel Explore dossiers (task 303 lineage; task 305 lineage; tasks
  307–320 F-lineage; git/Lean state; early canonical arc 006–129; middle Reynolds/expressive arc
  141–301), cross-checked against first-hand git and Lean-tree inspection.

## Context Extension Recommendations

- **Topic**: Rabinovich §5 faithful-transcription checklist for the k>0 completeness closure.
  **Gap**: the "position-by-evaluation-point litmus" and the "arity firewall (Lemma 3.2(2))"
  discipline exist only inside task-309/320 plan prose, not in reusable Lean-extension context.
  **Recommendation**: capture them as a `lean/context` note so future dispatches gate on them by
  default rather than rediscovering them after ~10 dispatches. (Context-gap task creation is
  currently disabled; documented here for manual review.)
