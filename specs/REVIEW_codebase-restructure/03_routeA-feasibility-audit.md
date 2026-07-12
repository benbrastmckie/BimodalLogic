# Route A Feasibility Audit — Can 348/309 finish `nf_nvar_exist_all_depths` n=1 WITHOUT endChar?

**Date:** 2026-07-12 · **Session:** sess_1783841542_df767b · **Mode:** `--hard` (H2/H3/H4/H5)
**Baseline:** HEAD `7e50e3ad0`; `KampPrior.lean` sorries exactly `:361` (n=1), `:364` (n+2) — unchanged since the 309 handoff.
**Inputs (all read this session):** `00_synthesis-and-recommendation.md`, `01_discrete-completeness-finish-map.md`, `KampPrior.lean:200-440`, `309/plans/09_offdiag-fi-chain-v9.md` (full), `309/.orchestrator-handoff.json`, `Base.lean:925-1160` (endChar), `349/reports/05_rabinovich-faithful-endchar-architecture.md`, git history of Base/NavigatedEndChar/Lemma32Reduction/KampPrior, `state.json` dependency edges.

---

## VERDICT: ROUTE A NEEDS ENDCHAR (A depends on B)

**Route A cannot discharge the `:361` n=1 arm without the endChar work.** The 349/350 → 309
dependency edges are **REAL, not stale**. Tasks 349 (recursive `endChar`) and 350 (aggregate
`quantEnd/seg` + arm-hook discharge at k=0/k=1) are **not an independent competing "Route B"** —
they are the exact unbuilt prerequisites that task 309's own Phase-18b dispatch identified,
recommended spawning, and is currently BLOCKED on. Route A and Route B **converge on one shared
bottleneck**: the residual-conditioned recursive navigated endpoint primitive `endChar` + its
correctness. Route B is therefore on the critical path after all.

The `00`/`01` framing ("two independent routes"; "endChar NOT on critical path"; "Route A
highest-leverage, 349/350 a demoted alternative") is **refuted** by (a) 309's own
`.orchestrator-handoff.json`, (b) the source-level endChar dependence of the arm-correctness
lemmas the 309 construction consumes, and (c) the literal names + dependency edges of tasks
349/350. See the Corrected Dependency Reality (§5) and the Contradiction Log (§6).

---

## 1. Q1 — What exactly does the n=1 arm (`KampPrior.lean:361`) require?

`nf_nvar_exist_all_depths` (`:212`) has signature `(k n : Nat) → (sub_nf : NormalForm sig k (n+1))
→ ∃ A, ∀ M h_UZ h_SZ t, temporal_truth M atomMap t A ↔ ∃ env : Fin n, nf_eval_nf M k (n+1)
(insertEnv env t) sub_nf`. The match is on `k` first (`| 0` / `| k+1`), then on `n` inside `k+1`.

**The `:361` sorry is the `| 1 =>` arm of the `| k+1` branch**, i.e. **symbolic depth `k+1`,
n=1**. Its obligation (goal per the Phase-15 record, `KampPrior.lean:432-434`):

> given `sub_nf : NormalForm sig (k+1) 2`, produce `A` with
> `temporal_truth M atomMap t A ↔ ∃ env : Fin 1, nf_eval_nf M (k+1) 2 (insertEnv env t) sub_nf`.

Unfolded: `∃ x', nf_eval_nf M (k+1) 2 (x', t) sub_nf` — a **two-anchor, off-diagonal `[x',t]`
depth-`(k+1)` arity-2 existential converter**. Crucially this arm must hold for **all** `k` (all
depths ≥ 1), because it is value-reached at every depth:

- `nf_characterizable_temporal_prior` (`:407`), inducting on `k`, calls `nf_nvar_exist_all_depths_fn
  … k 1` in its `succ` case (`:439`) — n=1 at **arbitrary** depth `k`.
- The recursion at `:273` re-enters `nf_nvar_exist_all_depths … k 1 sub_nf'` — n=1 at depth `k`.

So the n=1 arm is a **depth-recursive** obligation, not a single instance. The 309 construction
builds `A` as a **three-way zone trichotomy** `A_past ∨ A_diag ∨ A_future` over the position of
`x'` relative to `t` (Phase-18a skeleton `kampPrior_case1_trichotomy_assemble`, landed green
`53a3cd2cd`). Each arm formula's correctness (`nf_char2_past_formula_correct`,
`nf_char2_future_formula_correct`, `A_diag_correct`) reduces to discharging its **`∀ qnf` quant-
endpoint hook** (`h_quant`/`h_past`/`h_fut`/`h_diag`), whose shape is (handoff crux, Base:1238):

`∀ qnf : NormalForm sig k 3, ((∃ w, nf_eval_nf M k 3 (zoneEnv3 w x t) qnf) ↔ sub_nf.2 qnf)`.

That hook is exactly the coupling `seg_holds_coupled` needs via `h_endChar` (`Base:1152-1160`):
`(endChar qnf).eval_at M atomMap y ↔ nf_eval_nf M k 3 (zoneEnv3 y x t) qnf` — **which is the
statement of `endChar_correct`**. The arm formulas `nf_char2_past_formula` (`Base:1207`),
`nf_char2_future_formula` (`Base:1443`) and `A_diag` (`Base:741`) all take `seg`/`endChar` as an
explicit argument and are defined as `A_past seg (…)`; `seg endChar qnf` (`Base:1128`) is literally
built from `endChar qnf`. **The n=1 arm's assembly is endChar-parametric at the source level.**

**Precise requirement:** to close `:361` the construction needs, at **every** depth `k`, a
`TemporalPred`-valued navigated arity-3 endpoint primitive `endChar : EndCharCarrier sig k` (=
`NormalForm sig k 3 → TemporalPred`, `Base:1007`) with `endChar_correct` by recursion on `k`
(arity capped at 3, anchors `{x,t}`), so that the `∀ qnf` aggregate hooks discharge and the three
zone arms are correct. That primitive is **the endChar work.**

## 2. Q2 — Is the 349/350 dependency real or stale?

**REAL.** Three independent confirmations:

1. **309's own handoff names endChar as the live blocker.** `309/.orchestrator-handoff.json`
   (2026-07-11, single-owner 18b/19 audit), blocker `P18b-endChar-recursive-core-unbuilt`,
   `hard_wall_in_task: true`, `severity: high`: *"the navigated arity-3 endpoint primitive
   `endChar : EndCharCarrier sig k` + `endChar_correct` by recursion on k … is NOT built. Only the
   k=0 base `endChar0` (Base:995) exists … The recursive step is documented (Base:958-969) as a
   deferred follow_up_task of ~300-500 lines."* Recommendation: *"SPAWN the deferred endChar
   recursive-primitive successor … Recommend `/spawn 309` for the endChar core."* — This is Route
   A's owner declaring it is blocked on endChar.

2. **The task graph encodes it.** `state.json`: `349 deps=[351]`, `350 deps=[349]`, and 309's
   `dependencies` include `349,350`. Task **349** = `build_recursive_endchar_navigated_arity3_
   endpoint_primitive`. Task **350** = `build_aggregate_quantendseg_construction_and_discharge_
   armcorrectness_hooks_at_k0_and_k1` — its literal name **is** the Phase-18b work (discharge the
   `nf_char2_*`/`A_diag` hooks at k=0 and k=1 via the aggregate `quantEnd/seg`). 349/350 are the
   spawned realization of the handoff's recommendation, not a parallel alternative.

3. **The consumers grep-confirm the edge.** `nf_char2_past_formula_correct` (`Base:1230`),
   `nf_char2_future_formula_correct` (`Base:1443`), `A_diag_correct` (`Base:758`) — the three
   lemmas the Phase-18a skeleton consumes — are **referenced only in docstrings, never applied**
   (handoff finding 1; independently grep-checked). They have **zero dischargers** because their
   discharge requires `endChar_correct`, which does not exist.

**Why `00`/`01` called it "stale/independent" — and why that is wrong.** The finish-map §4.5
observed, correctly, that the **348 gate carrier** `bracketEndChar_kvE2Ext_correct_two_prior_frag`
(`ExteriorBracket.lean`) does not reference `endChar`/`quantEndSeg`/`NavigatedEndChar`. But it then
**over-generalized** from "the 348 gate doesn't use endChar" to "Route A doesn't need endChar." The
348 gate is **one rung** (k=2-fixed, `nf_eval_nf M 2 3`); it serves only the k=2 arm. The n=1 arm's
**other** depths (k=0, k=1) and its `∀k` assembly go through the trichotomy/arm-formula route,
which **is** endChar-parametric. The gate is not a substitute for the recursive primitive.

## 3. Q3 — Can 348's material + a re-scoped 309 finish n=1 without endChar?

**No.** 348 delivered a genuine, sorry-free, axiom-clean asset —
`bracketEndChar_kvE2Ext_correct_two_prior_frag` (the enriched k=2 interior+boundary+adjacent-
exterior gate, `hexclExt` discharged internally) — and explicitly **deferred** the `:351` (`:361`)
retirement to 309 (348 plan R1; transfer note `KampPrior.lean:352-360`). But this gate **cannot
cover the n=1 arm alone**, for three structural reasons established by 309's own Phase-15 verdict
and Phase-18b audit:

- **Depth-typing wall.** Phase-15 F-i (`765054d5a`): at the k=1 arm (depth-2 instance, `sub_nf :
  NormalForm sig 2 2`) the per-qnf population is `NormalForm sig 1 3`; `kvE2_sepFragment` **types at
  `NormalForm sig 2 3`** and *does not apply*. The 348 gate is unusable at the k=1 arm; that arm is
  served by the trichotomy + `bracketEndChar_kv_correct_one_prior` rung — which needs the aggregate
  hook (endChar) to assemble the *formula*, not merely a per-qnf certificate.
- **Per-qnf ≠ aggregate.** Phase 15 landed per-qnf **seam certificates** (`kampPrior_site_rung1_
  match`, `Iff.rfl`-level, fixed order pattern). Phase 18b then found these are **necessary but not
  sufficient**: the actual arm formula quantifies over **all** qnf order patterns (`∀ qnf`), routing
  `w` across five zones via `nf_zone_flatten_navigable`, whose endpoints **are** the depth-`k` IH
  bottoming at the recursive `endChar`. The per-qnf rung does not give formula-level arm
  correctness.
- **No rung above k=2.** Phase-15 F-ii: rung-index = arm-index; depths ≥ 3 have **no landed rung**
  (`bracketEndChar_kvE'` retired, V9-3). The `| 1 =>` arm needs all depths; the gate tops out at
  one depth. Spanning all depths **is** a depth-recursive primitive = endChar.

So `bracketEndChar_kvE2Ext…` (k=2) + 309's segment-carrying `A_past`/`A_future` +
`nf_char2_{past,future}_formula` **do not compose to a sorry-free `:361` retirement**: the arm
formulas' `_correct` lemmas are undischarged precisely because they need `endChar_correct`. The
arity/depth "match" the prompt notes (n=1 = depth-`k+1` arity-2 Prior converter) is real, but the
converter is depth-**recursive**, and the recursion carrier is endChar.

## 4. Q4 — Why is 309 blocked? (2 live blockers)

Per `309/.orchestrator-handoff.json` (`status: partial`, 2/5 phases complete):

- **Blocker 1 — `P18b-endChar-recursive-core-unbuilt`** (`kind: unbuilt_recursive_prerequisite`,
  `hard_wall_in_task: true`). **Not plan churn; not a budget overrun — a genuine unbuilt-primitive
  wall.** Phase 18b's three arm-correctness lemmas have zero dischargers; discharging them needs
  (A) the aggregate `quantEnd`/`seg` (all order patterns, 5-zone routing) and (B) the recursive
  `endChar`/`endChar_correct`. Only `endChar0` (k=0 base) exists, and even it discharges the full
  depth-0 arity-3 atom layer **only under the anchor residual `h_res`** (`Base:1056`), because a
  closed navigated-`w` `TemporalPred` provably cannot read free carrier anchors (counterexample
  `Base:1036-1047`). → This is a **feasibility-flavored wall**, category (b), *shared with 349*.

- **Blocker 2 — `P17-frozen-interface-gap`** (`kind: frozen_interface_gap`, `hard_wall_in_task:
  true`). Independent of Blocker 1. `hrealI`/`hrealB` (`OuterGate:374/:380`) need x/t anchor atom
  content that the frozen producer chain drops (`kvE2_sepPtW` is a point-type at `w`, zero x/t
  content). Discharging them requires enriching the **frozen provider** gate obligation shapes —
  forbidden inside 309 (V9-1) → a spawned successor (handoff proposes ~task 349-class). This feeds
  the **k=2 gate arm**, not the k≤1 narrowing.

Neither blocker is (c) plan-churn/wiring. The v5→v9 churn is real history, but the **current** stall
is two hard structural walls: an unbuilt (and, unconditionally, refuted) recursive endChar primitive,
and a frozen-interface anchor-content gap. Category: **(b) genuine feasibility/structure walls**,
one of which (Blocker 1) is identical to 349's wall.

## 5. Q5 — Adversarial refutation attempt (H4): "Route A finishes without endChar"

**I tried to establish the claim and it fails.** Steelman: plan v9 Phase 18 *intends* to consume
the kvE2Ext gate BY NAME (not endChar); if the whole `| 1 =>` arm could be built from the gate +
the recursion's own `ExistProviders` IH, endChar would be avoidable. Refuted by:

- **R1 (self-refutation).** 309's own Phase-18b audit concluded the opposite: BLOCKED on unbuilt
  endChar; explicit `/spawn 309 for the endChar core` recommendation. The implementer, on actually
  attempting the arm, could not avoid endChar.
- **R2 (source dependence).** The arm formulas consumed by the landed Phase-18a skeleton are
  endChar-parametric (`seg endChar`, `Base:1128/1152`); their `_correct` needs `endChar_correct`.
- **R3 (depth-typing).** The gate is k=2-fixed and cannot type at the k=0/k=1 arms (Phase-15 F-i)
  nor exist at k≥3 (F-ii). No single-depth gate spans the depth-recursive arm.
- **R4 (349 refuted the unconditional form).** The endChar recursive correctness was attempted in
  349 Phase 5 and **proven UNPROVABLE in its frozen/unconditional form** (git: `0c1298c47 task 349
  phase 5: BLOCKED — frozen unconditional multi-anchor base proven UNPROVABLE`; concrete refutation
  `endCharN0_correct_infeasible`, world-locality obstruction). So the prerequisite is not merely
  unbuilt but has a demonstrated obstruction; only a **residual-conditioned** revise (349 report 05)
  is feasible-pending (Medium-High), not green.

**The only residual escape hatch** by which A *might* avoid the Base-`endChar` symbol: rebuild the
entire `| 1 =>` arm as a **symbolic-k gate family** (never touching the trichotomy/arm-formula
route). But (i) that family is itself unbuilt, (ii) it would face the **identical** world-locality/
anchor-residual obstruction (the gate's interior segment is also a navigated characteristic), and
(iii) 309 already committed to the trichotomy route. This hatch is speculative, unproven, and does
not change the verdict — it is just endChar under another name.

**Conclusion of the adversarial pass:** "Route A finishes without endChar" is **false**. A and B
are **not independent**; Route B (349/350, and specifically the residual-conditioned recursive
endChar) is on the critical path.

---

## Claim Verification Table (H4)

| # | Claim (load-bearing) | Source / evidence | Verification method | Confidence |
|---|----------------------|-------------------|---------------------|------------|
| 1 | `:361` is the `| 1 =>` (n=1, depth-`k+1`) arm; value-reached at all depths | `KampPrior.lean:334-361`, `:273`, `:439` | Direct file read of the match + call sites | High |
| 2 | The n=1 arm is assembled as trichotomy `A_past∨A_diag∨A_future` (Phase-18a landed) | `KampPrior.lean:580` note; commit `53a3cd2cd` | Read plan §Phase 18 + git log | High |
| 3 | Arm-correctness lemmas are endChar-parametric (`seg endChar`, need `endChar_correct`) | `Base.lean:741/758/1128/1152-1160/1207/1443` | grep + read of defs/`_correct` shapes | High |
| 4 | The 3 arm-correctness lemmas have ZERO dischargers (docstring-only refs) | Handoff finding 1; grep of `Theories/` | grep, cross-checked with handoff | High |
| 5 | 309 Phase 18b BLOCKED on unbuilt recursive endChar; `/spawn` recommended | `309/.orchestrator-handoff.json` blocker `P18b-…` | Read handoff JSON | High |
| 6 | `endChar0` (k=0) exists but is correct only under `h_res`; recursive step unbuilt | `Base.lean:995/1056/958-969` | Read Base source | High |
| 7 | 349 = recursive endChar; 350 = arm-hook discharge k0/k1; `350 deps=[349]` | `state.json` names + dep edges | jq query of state.json | High |
| 8 | 349's unconditional endChar was proven UNPROVABLE (feasibility wall) | git `0c1298c47`/`eea309338`; `endCharN0_correct_infeasible` | git log + 349 report 05 §0 | High |
| 9 | 349's residual-conditioned architecture is FEASIBLE-PENDING (Med-High), not green | `349/reports/05…md:49-55` | Read report 05 executive summary + §5 | Med-High (their own verdict) |
| 10 | 348 gate is k=2-fixed, cannot type at k=0/k=1 arm (`kvE2_sepFragment` at `NF sig 2 3`) | Phase-15 F-i; plan `:406-416` | Read plan Phase-15 verdict | High |
| 11 | 348 delivered its gate sorry-free/axiom-clean and deferred `:361` to 309 | plan `:139-151`; `KampPrior.lean:352-360` | Read plan + transfer note | High |
| 12 | Current tree: `:361`/`:364` sorries intact; HEAD `7e50e3ad0` | `grep sorry KampPrior.lean`; `git rev-parse` | Direct grep + git | High |
| 13 | `NavigatedEndChar.lean` has zero importers (349 staging, off import closure) | grep of `Theories/` | grep | High |

**Recommendations modified after verification:** the `00`/`01` recommendation ("Route A highest-
leverage; 349/350 demoted alternative") is **reversed** by this audit — see §6 and the head-to-head.

## 6. Contradiction Log (H4 resolution)

**Contradiction:** `00_synthesis`/`01_finish-map` assert "two **independent** routes… endChar NOT
on critical path… Route A highest-leverage" — vs. this audit's finding that Route A **needs**
endChar (349/350 on the critical path).

**Resolution (precedence: proof-term/source evidence > plan-narrative optimism):** The `00`/`01`
claim rests on one true but narrow fact (the 348 **gate** doesn't reference endChar) over-extended
to the **whole** arm. The countervailing evidence is proof-level and self-reported by Route A's
owner: (a) `309/.orchestrator-handoff.json` explicitly blocks Phase-18b on unbuilt endChar; (b) the
arm-correctness lemmas are endChar-parametric at the source; (c) 350's task name and dep edge
encode the dependency. Source + self-report **outrank** the synthesis's narrative. Additionally the
finish-map itself was written **before/around** the Phase-18b audit landed; the audit supersedes
it. **RESOLVED** in favor of "A needs endChar." No unresolved contradiction remains.

Secondary tension (resolved): Phase-15 GO-k1 optimism ("k=1 arm closes via unconditional rung-1")
vs. Phase-18b pessimism ("needs unbuilt endChar"). Resolution: the later, more thorough Phase-18b
dependency audit supersedes the Phase-15 per-qnf seam certificates — per-qnf certificates are not
formula-level arm correctness. Precedence: later exhaustive audit > earlier partial certificate.

---

## 7. Remaining-work list for Route A (what must land to close `:361`)

Route A's honest remaining work, relabeled to the true prerequisites (all currently unbuilt or
blocked):

| # | Work item | Owning task | State | Effort | Feasibility |
|---|-----------|-------------|-------|--------|-------------|
| A | Residual-conditioned recursive `endChar` + `endChar_correct` (recursion on k, arity ≤3, `h_res`-threaded) | **349** | researched; unconditional form REFUTED; residual form feasible-pending | ~300-500 lines (Base:964 estimate) | **Medium-High** (349 report 05); one open obligation: residual threading at the k+1 step |
| B | Aggregate `quantEnd`/`seg` (all-order-pattern, 5-zone) + discharge `nf_char2_{past,future}_formula_correct` / `A_diag_correct` hooks at k=0 and k=1 | **350** | researched; `deps=[349]` | ~200-400 lines | Medium (gated on A) |
| C | Frozen-interface enrichment: thread `hEpL`-at-x / `hEpR`-at-t into the gate obligation shapes so `hrealI`/`hrealB` discharge; then `hexcl` | spawned (≈349-class successor) | blocker `P17-…`; needs a frozen-provider edit | ~200-450 lines | Medium; **only needed for the k=2 gate arm** |
| D | 309 Phases 18-19: wire A+B (+C for the k=2 rung), assemble trichotomy at all depths, retire `:361`; verify `#print axioms` drops `sorryAx` | **309** | Phase 18 PARTIAL / 19 NOT STARTED | ~200-400 lines | High **once A/B land** |
| E | Retire the `:364` n+2 arm (restrict domain to n≤1) + re-run `#print axioms` (task 95) | 305/95 | — | ~50-150 lines | High (mechanical) |

**Critical-path ordering:** 351 (done) → **A (349)** → **B (350)** → **D (309 P18-19)** → E.
Item C is a parallel side-branch feeding only the k=2 gate arm. **Total remaining ≈ 950-1,750
lines**, gated first on the feasibility of the residual-conditioned endChar (A), which is
feasible-pending — the single largest risk in the entire finish.

**Key upside of A:** if the residual-conditioned endChar generalizes to **all** k (349 report 05's
open obligation resolves positively), it closes the `:361` arm at **every** depth — including the
k≥3 arms the plan otherwise routes to a narrowed strategic sorry. endChar is not a low-depth
helper; it is the **symbolic-k engine** for the whole arm. This makes 349/350 the finish, not a
detour.

## 8. Head-to-head: "Route A" vs "Route B" (they are the same critical path)

The framing collapses: there is **one** finish path, with 348 as a landed side-rung and 349/350 as
the load-bearing core. Comparing the *labels* as the review posed them:

| Dimension | "Route A" (348 gate + 309 wiring, endChar-free) | "Route B" (349/350 endChar core) |
|-----------|--------------------------------------------------|----------------------------------|
| Can it close `:361` alone? | **No** — gate is k=2-only; k≤1 arms + ∀k need endChar | **Yes in principle** — recursive endChar spans all depths |
| Remaining effort | Illusory as "endChar-free"; real work = 349+350+309 anyway | ~300-500 (349) + ~200-400 (350) + 309 wiring |
| Feasibility confidence | N/A as standalone (structurally blocked) | **Medium-High** for the residual-conditioned form (349 rpt 05); unconditional form **refuted** |
| Faithfulness (Rabinovich) | Gate is faithful for its rung; but skipping endChar is not a faithful *whole* | High — residual-conditioned endChar mirrors Rabinovich §5 (both endpoints explicit; navigation = re-anchoring, never a 3rd free var) |
| Risk | Hidden: presents as near-done but hits the same wall | Concentrated + named: residual threading at the k+1 step |
| Landed assets consumed | 348 gate (k=2 rung), Phase-15/16 shims, Phase-18a skeleton | 351 `nfEval_le2_reduction` (done), `endChar0`/`h_res` base, `nf_zone_flatten_navigable_correct` (~80% named assets green) |

**Recommendation:**

1. **Invest in the residual-conditioned recursive `endChar` (task 349) as the top priority** — it
   is the shared bottleneck of both routes and, if it lands, closes `:361` at all depths. Use 349
   report 05's architecture verbatim: keep the ≥2-anchor object Prop-valued with `x,t` explicit
   (`nf_zone_flatten_navigable`), reduce arity-4→≤3 first via `nfEval_le2_reduction` (351, landed),
   state `endChar_correct` at every k **with `h_res`** (generalize the green `endChar0_correct`),
   collapse to a closed `Formula` only at `endChar0`. Target the single open obligation (residual
   threading at the step) as the whole deliverable.
2. **Then task 350** (aggregate `quantEnd/seg` + arm-hook discharge at k=0/k=1), which unblocks
   309 Phase 18b.
3. **Keep 348's gate as the k=2 rung** — do not discard it; it is landed, sorry-free, axiom-clean,
   and is the faithful interior+boundary+adjacent-exterior characterization at k=2. It composes
   *with* endChar, not instead of it.
4. **Do NOT re-dispatch 309 in-task on `:361`** until 349 lands — the handoff is explicit that this
   re-hits the unbuilt-endChar wall.
5. **Correct `00`/`01`** to remove the "independent routes / endChar off critical path" claim; 349/
   350 are prerequisites, not alternatives.

## 9. Corrected dependency reality (309 / 348 / 349 / 350)

```
351 [completed]  nfEval_le2_reduction  (Rabinovich Lemma 3.2(2), arity-4→≤3)
   │
   ▼
349 [researched] recursive endChar + endChar_correct   ← REAL, load-bearing, feasible-pending
   │   (unconditional form REFUTED 349 P5; residual-conditioned form is the live proposal)
   ▼
350 [researched] aggregate quantEnd/seg + discharge nf_char2_*/A_diag hooks @ k0,k1
   │
   ▼
309 [blocked]    Phase 18b/19 — assemble trichotomy, retire :361   ← consumes 349+350
   ▲
   │ (side-rung, landed, NOT sufficient alone)
348 [completed]  bracketEndChar_kvE2Ext_correct_two_prior_frag  (k=2 gate; serves k=2 arm only)

parallel side-branch (k=2 gate arm only):
309 Phase 17 hrealI/hrealB  ──needs──▶  frozen-interface enrichment successor (≈task 349-class)
```

**Edge-by-edge:**

- **348 → 309: REAL but PARTIAL.** 348 correctly deferred `:361` to 309 and delivers a genuine k=2
  rung. It does **not** discharge the arm; it is one depth of a depth-recursive obligation.
- **349 → 309: REAL (load-bearing).** endChar/`endChar_correct` is the recursion carrier the arm-
  correctness hooks require. **Not stale.**
- **350 → 309: REAL (load-bearing).** 350's deliverable *is* the Phase-18b arm-hook discharge.
  **Not stale.**
- **349 → 350: REAL** (`350 deps=[349]`; 350 consumes `endChar_correct`).
- **351 → 349: REAL** (349 consumes `nfEval_le2_reduction`; 351 completed).
- **No stale edges found.** The only *mischaracterization* is in the prose of `00`/`01` (calling
  349/350 an "independent alternative not on the critical path"), which this audit corrects. The
  `state.json` dependency edges are accurate.

---

### Appendix — files/lines grounding the verdict

- `KampPrior.lean:212` (`nf_nvar_exist_all_depths` def), `:347-361` (`| 1 =>` arm + transfer note +
  sorry), `:362-364` (`| n+2 =>` sorry), `:273`/`:439` (n=1 value-reached), `:580` (Phase-18a note).
- `Base.lean:741/758` (`A_diag`/`_correct`), `:995` (`endChar0`), `:1007` (`EndCharCarrier`),
  `:1056` (`endChar0_correct` under `h_res`), `:958-969` (recursive endChar deferred follow_up),
  `:1128/1139/1152-1160` (`seg endChar` / `seg_holds_coupled` / `h_endChar`), `:1207/1443`
  (`nf_char2_{past,future}_formula`), `:1230/:1443` (their `_correct`), `:1036-1047`
  (world-locality counterexample).
- `309/.orchestrator-handoff.json` (blockers `P18b-endChar-recursive-core-unbuilt`,
  `P17-frozen-interface-gap`; `status: partial`, 2/5).
- `309/plans/09_offdiag-fi-chain-v9.md:395-475` (Phase-15 GO-k1 verdict), `:577-624` (Phase-18
  PARTIAL + structural finding), `:626-666` (Phase-19).
- `349/reports/05_rabinovich-faithful-endchar-architecture.md:13-55` (executive summary;
  FEASIBLE-PENDING-RESIDUAL-THREADING, Medium-High).
- git: `0c1298c47`/`eea309338`/`2d645d77e` (349 P5 endChar infeasibility), `53a3cd2cd` (309 P18a),
  `70dd69481` (351 done). `state.json`: `349 deps=[351]`, `350 deps=[349]`, statuses.
</content>
</invoke>
