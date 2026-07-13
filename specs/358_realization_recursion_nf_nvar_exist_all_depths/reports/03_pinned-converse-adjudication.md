# Pinned-Realization Converse Adjudication — Task #358 (Round 3)

**Task**: 358 — realization_recursion_nf_nvar_exist_all_depths (Phase 3 [BLOCKED] escalation)
**Agent**: lean-research-hard-agent · **Mode**: --hard --lit, H5 divergence audit active
**Date**: 2026-07-13 · **Session**: sess_1783922322_803708
**Inputs**: handoffs/phase-3-blocker-20260712.md (canonical blocker), plans/02 Phase-3 [BLOCKED]
block, Rabinovich 2014 chunks 0013–0016 + 0021/0023 (Def 7.5/7.7/7.13), reports/01–02,
task 349 plans/08 (v8), task 356 summary concession.
**Scope**: research only — no Lean edit; tree remains at green Phase-2 HEAD `6453bee06`.

---

## TL;DR — the three answers and the routing

- **Q1**: The pinned fiber realization is **NOT derivable from free-env content** — the
  as-stated `hbrFutReal`/`hbrPastReal` binders are semantically FALSE (machine probe + P2M
  countermodel + task-356 written concession all agree; this report's adversarial pass
  re-confirms and sharpens the countermodel one level down). Rabinovich's existence-direction
  machinery **never performs a free→pinned inference**: every hypothesis his Cor 5.4(1)⇐ /
  Cor 5.4(2) / Lemma 5.3 re-anchoring consumes is a *truth at pinned coordinates* — `F0(z0)`
  at the pinned anchor, milestones `Fi(xi)` at points pinned inside the walked interval, and
  the definable first-point truth `INF(z0,r0,z1)`. The faithful Lean statement (§2.4)
  requires BOTH the chain-firing/endpoint truth antecedent AND the level-up ambient
  realization; its proof route is the landed complete-type totality
  (`nf_characteristic_satisfies`/`nf_eval_unique`, NormalForm.lean:215/224/245) + the
  destructor's currently-DISCARDED pinned walked-point facts (`_hgap`/`_hocc`,
  ExteriorConverterK.lean:159).
- **Q2**: **YES — the interface MUST be restated**; no in-scope reformulation exists (one
  cannot instantiate a semantically false universal from any true site supply). The exterior
  obligations dropped exactly the two truth antecedents their interior siblings and `Sat`
  halves already carry. Binder restatement alone is **necessary but not sufficient** — the
  content channel/proof of `kvE_extNeg*_complete` must also be re-derived from the
  destructor's pinned facts. → **SPAWN one dedicated task** (§3.3); it blocks 349 Phase 6 too.
- **Q3**: The carrier→formula fold is **NOT task 349's charter** (349 v8 freezes
  KampPrior.lean and names the :361 wiring an explicit non-goal) — it is the un-owned
  task-309 P18/19 slice that 358's definition-of-done requires. **Keep it in 358** as the
  revised Phase 3, gated on 349 Phases 5–7 (`endInterval_correct`) and the spawned task.
- **BOTTOM LINE**: routing **(B) with a (C)-refinement** — spawn one interface task; 358
  goes [BLOCKED] on {spawn, 349}; the fold stays 358's (do NOT extend 349's charter). §5.

---

## 1. Reference grounding (H3, Tier 1 — lemma-level mapping table)

| Paper result (Rabinovich 2014) | Paper statement (chunk:lines) | Target Lean signature | Landed? | File:line or NEW |
|---|---|---|---|---|
| Cor 5.4(1), observation ⇐ (realizer) | chunk_0015:11–37: `∃z∈(z0,z1)` with bracket(z0,z) **iff** `F0(z0)` ∧ increasing `x1<…<xn` in `(z0,z1)` with `Fi(xi)`; ⇐ by induction, Until-witness + min/case-split | `kampPrior_fChain_realize{,_cons,_from,_bracket}` | **LANDED** (Phase 2) | KampPrior.lean (tail section, :1149 ff.) |
| Cor 5.4(1), `O_n` chain formula | chunk_0015:39–41: `¬F0(z0) ∨ On(F1,…,Fn,z0,z1)` is the ∨∃∀ equivalent of the negated existential | `kvE_futPos` / `kvE_extNegFut` (chain device `kvE_futChainG`) | LANDED | ExteriorNegationK.lean:405–428 |
| Cor 5.4(2) (mirror re-anchoring) | chunk_0015:43: "(2) is the mirror image of (1)" — bracket anchored at the RIGHT endpoint `[…](z,z1)`; consumed by Lemma 5.1 Case 2 (chunk_0016:17) under the case-condition truth `α0(z0) ∧ β1 along (z0,z1)` | fresh-slot re-anchor `kvE_futItemShift` + `kvE_anchorBridge` (partial: re-anchors ONE slot only) | PARTIAL | ExteriorNegationK.lean:358–361, :442–451 |
| Lemma 5.3 inductive step (first-point re-anchoring) | chunk_0014:15–41: case split on `r0 = inf{z∈(z0,z1) | P1(z)}`; consumes `K+(P1)(z0)` or the **definable** `INF(z0,r0,z1,P1)` truth — never a bare existential | `HasAttainedINF.first_occ` (arity-2) | LANDED (arity-2) | EANegationClosure.lean:54–66 |
| INF definability (eq. 5.3) | chunk_0016:19: `INF¬β1(z0,z,z1) := z0<z<z1 ∧ (∀y)∈(z0,z)β1 ∧ (¬β1(z) ∨ K+(¬β1)(z))` — footnote 4: "use only existence" | `HasAttainedINF` structure hypothesis | LANDED | EANegationClosure.lean (h_INF threading) |
| Chain destruction (walked-point pinning) | implicit in Cor 5.4(1)⇒ + O_n semantics: chain truth at `s` yields endpoint + per-item occurrence pinned in `(s,x1)` | `kvE_futChainDestructG` — returns `hend` + `hgap` + `hocc : ∀ a ∈ l, ∃ r, s<r ∧ r<x1 ∧ itemF a @ r` | LANDED | ExteriorNegationK.lean:293–303 |
| Complete atomic type at a point (canonical expansion discipline, Def 7.7) | chunk_0022:5: expansion predicate `A` interpreted as `{a | M,a ⊨ A}` — truth at a point IS the complete pinned datum; no residual free anchors | `nf_characteristic` + `nf_characteristic_satisfies` + `nf_eval_unique` (totality + uniqueness of the realized complete type) | **LANDED** | NormalForm.lean:215/224/245 |
| Adjacent-pair anchor discipline (Def 7.13) | chunk_0023:25: k-anchor formulas decompose into conjuncts `ϕi(zi, zi+1)` — each with TWO adjacent free anchors only; non-adjacent anchor dependence does not occur | (design constraint, violated by the free-env rendering of arity-5 fibers) | N/A — root cause | see §2.2 |
| **The pinned fiber-realization converse** (Cor 5.4(1)⇐ one fiber level down) | composite of the above: reconstruct σ's pinned realizer at the destructor endpoint from chain truth + ambient | `kvE_futPinned_of_end` (§2.4) + Past mirror | **NEW** | NEW (spawn task, §3.3) |
| Carrier→formula fold (P18/19 hooks) | Prop 4.2 assembly layer (chunk_0013:9–27) | `quantEnd`/`seg` construction discharging `h_quant` (Base.lean:1238–1241/:1438–1441) into `kampPrior_case1_trichotomy_assemble` (KampPrior.lean:1133) | **NEW** | NEW (358 revised Phase 3, gated; §4) |

Source-coverage: every load-bearing claim below cites a Rabinovich chunk line-range or a
Lean file:line; cross-checked against reports/01–02 and the 349 v8 plan.

---

## 2. Q1 — the pinned-realization converse

### 2.1 What Rabinovich's existence direction actually consumes

Reading Cor 5.4(1)'s proof verbatim (chunk_0015:11–37): the ⇐ induction consumes exactly
(i) `F0(z0)` — truth of the folded Until-chain formula **at the pinned left anchor**;
(ii) `Fi(xi)` for an increasing sequence **pinned inside `(z0,z1)`**;
(iii) Until-witness extraction at the IH's `y1` and the decidable `min`/case-split.
Cor 5.4(2) is declared "the mirror image" (chunk_0015:43); where Lemma 5.1 invokes it
(Case 2, chunk_0016:17), the hypothesis consumed is the case condition
`α0(z0) ∧ (∀z)∈(z0,z1) β1` — truths at/along pinned coordinates. Lemma 5.3's re-anchoring
subcases (chunk_0014:19–35) consume `K+(P1)(z0)` or the **definable** first-point truth
`INF(z0,r0,z1,P1)` — again a pinned-interval characterization ("we will use only existence",
chunk_0016 footnote 4).

**There is no step anywhere in §5 that infers realization at designated coordinates from an
unpinned existential.** The free/pinned distinction cannot even arise for Rabinovich: his
fiber-level atoms `αi, βi` are quantifier-free formulas of the canonical E[Σ]-expansion
(Def 7.7, chunk_0022:5) — ONE free variable, truth at a point = the complete pinned fiber
datum; and when more anchors are needed, Def 7.13 (chunk_0023:25) decomposes into
adjacent-pair segment formulas, so non-adjacent anchor dependence never occurs.

### 2.2 The divergence (H5 root cause)

The project's depth-`k` truth channel renders fiber content as
`P.existF 4 (renameNF rot5Fwd rot5Bwd s)` with correctness
`temporal_truth r (kvE_futItemShift P s) ↔ ∃ env : Fin 4 → M.carrier, nf_eval_nf M k 5
(Fin.cons r env) s` (ExteriorNegationK.lean:448–449): it pins the walked point `r` (fresh
slot) and **existentially discards the four outer coordinates**. This is strictly weaker than
Rabinovich's canonical-expansion predicates and violates the Def 7.13 discipline (an arity-5
fiber depends freely on non-adjacent anchors, then the dependence is quantified away). The
compensation was the four `hbr*` universal obligations — which are semantically false
(blocker probe; task-356 concession, summaries/01:52–55).

Crucially, `kvE_extNegFut_complete` **discards the pinned facts it already has**: the chain
destructor returns `⟨x1, htx1, hend, _hgap, _hocc⟩` (ExteriorConverterK.lean:159) where
`hocc : ∀ a ∈ l, ∃ r, t < r ∧ r < x1 ∧ temporal_truth r (itemF a)` and
`hgap : ∀ r ∈ (t,x1), D @ r` (ExteriorNegationK.lean:300–303) — per-item occurrences
**pinned inside the real interval `(t, x1)`** — and then substitutes the false `hreal` for
the reconstruction instead. The walk geometry + fresh-slot pinning is exactly Rabinovich's
milestone mechanism; the free-env `hreal` is the corner cut.

### 2.3 Is free-env content sufficient? Is `hpos`/`hend` alone sufficient? (decisive)

- **Free-env alone: NO.** Machine-refuted (blocker probe, compiled `lean_run_code`) and
  semantically refuted on `P2M = (ℤ,<), P = {0,10,20}` (ExteriorFiberProbeK.lean:61). This
  report does not re-litigate it; it is settled.
- **`hpos` + `hend` truth antecedents alone: NOT in general.** Adversarial construction
  (§6, C3): the self-zone coupling `(false,false)` (kvE_futSelfZone,
  ExteriorNegationK.lean:70; coupling semantics kvE_futZone4_of_above :457–466) forces
  fresh/x1 **coincidence**, so `hend`'s self content pins the endpoint's own atomic profile
  — but the on-fiber population all share the same `(w,x,t)`-slot atoms
  (`nfk_dropFresh s = σ.1`), so at fiber depth `m ≥ 1` two admissible σ ≠ σ′ differing only
  in **depth-`m` fiber marking** can both pass free-env-rendered `hend`/ray content at the
  same `x1` while only σ′ is pinned-realized. The free-env ray/gap rendering cannot separate
  them; the truth antecedent is **necessary** (it is what the consumption site actually has
  in scope: `hpos` intro'd at ExteriorConverterK.lean:140, `hend` at :159–163) but not
  sufficient by itself.
- **What IS sufficient (the faithful ingredient set)** — all three, matching precisely what
  Rabinovich's ⇐ consumes:
  1. **Complete-type totality at the endpoint** (his "quantifier-free type" step): landed —
     `τ := nf_characteristic M (m+1) 4 [x1,w,x,t]` with `nf_characteristic_satisfies`
     (NormalForm.lean:224) giving the PINNED realization of τ, and `nf_eval_unique` (:245)
     its uniqueness.
  2. **The level-up ambient** `h : nf_eval_nf M (m+2) 3 [w,x,t] qnf` (his `F0(z0)` /
     bracket-ambient): `(h.2 τ).mp` marks τ; off-fiber falsity excludes off-fiber τ. This is
     what pins `(w,x,t)` — pinning always descends from one level up, never rises from the
     truth channel.
  3. **Endpoint identification τ = σ** from `hend` + admissibility + the destructor's
     pinned `hgap`/`hocc` walk facts (his milestone reconstruction): at `m = 0` (the `:361`
     arm) the walk geometry + fresh-slot coincidence pin the complete fiber datum (v-profile
     + zone), so identification closes with landed machinery; at `m ≥ 1` it requires the
     recursion's own `charF`/provider to render walked-point types (the level-by-level
     descent — Rabinovich's induction on quantifier depth), i.e. new but structured work.

### 2.4 The faithful Lean statement (signature level)

```lean
/-- Pinned fiber-realization converse (Rabinovich Cor 5.4(1) ⇐ one fiber level down,
    + Cor 5.4(2) re-anchoring): at a destructor-selected exterior endpoint carrying the
    chain/endpoint truth, under the level-up ambient realization, σ itself is realized
    PINNED at [x1, w, x, t]. -/
theorem kvE_futPinned_of_end {sig : MonadicSignature} {atomMap : Formula → sig.preds}
    {m : Nat} (P : ExistProviders sig atomMap m)
    (M : OrderedMonadicStructure sig)
    (h_UZ : semantic_prior_UZ M atomMap) (h_SZ : semantic_prior_SZ M atomMap)
    (qnf : NormalForm sig (m + 2) 3) (σ : NormalForm sig (m + 1) 4)
    (hadm : kvE_futAdmissible σ = true)
    (hfib : nf1_dropFresh σ = qnf.1)              -- σ on qnf's fiber (shape per site)
    (w x t : M.carrier) (hxw : x < w) (hwt : w < t)
    (h : nf_eval_nf M (m + 2) 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)  -- AMBIENT
    (x1 : M.carrier) (htx1 : t < x1)
    (hpos : temporal_truth M atomMap t (kvE_futPos P σ))                     -- chain fires
    (hend : temporal_truth M atomMap x1 (kvE_futEnd P σ))                    -- endpoint
    (hgap : ∀ r : M.carrier, t < r → r < x1 →
      temporal_truth M atomMap r (kvE_futGapD P σ))                          -- destructor
    (hocc : ∀ s ∈ kvE_fiberZoneList σ kvE_futGapZone, ∃ r : M.carrier,
      t < r ∧ r < x1 ∧ temporal_truth M atomMap r (kvE_futItemShift P s)) :  -- destructor
    nf_eval_nf M (m + 1) 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ
```

Consequences: (a) `kvE_futBundle_of_realizer` (ExteriorConverterK.lean:208) converts the
conclusion into exactly the `hbrFutReal`/`hbrFutSat` conjuncts at the selected `x1`; (b) for
UNMARKED σ (`qnf.2 σ = false`) the conclusion contradicts `(h.2 σ).mp` — which is precisely
the contradiction `kvE_extNegFut_complete` needs, so the restated (antecedent-guarded)
obligations discharge **vacuously-from-contradiction** at the outer site. The Past mirror
(`kvE_pastPinned_of_end`) is symmetric.

**Answer to the prompt's direct question**: it requires the additional truth antecedents —
`hpos`/`hend` (+ the destructor facts `hgap`/`hocc`) AND the level-up ambient `h`. What
Rabinovich's Cor 5.4(2) existence-direction re-anchoring consumes is never free-env content:
it consumes the mirror-bracket/case-condition truth at pinned endpoints and the definable
INF first-point truth. Free-env `P.existF 4` content alone can NEVER yield pinned
realization (refuted); `hpos`+`hend` without the ambient cannot either (§6 C3).

---

## 3. Q2 — interface restatement (the 5-file chain)

### 3.1 Must the binders be restated? YES (no in-scope alternative exists)

The four exterior obligations as stated
(EndIntervalConsumerK.lean:129–154 ≡ KampPrior.lean:845–870 ≡
ExteriorGateAssembleK.lean:142–167 ≡ ExteriorBracketAssembleK.lean:181–191, all mirroring
`kvE_extNeg{Fut,Past}_complete`'s parameters ExteriorConverterK.lean:126–134) are
**semantically false universals**. A false hypothesis cannot be instantiated by any true
supply from the KampPrior site; therefore **no KampPrior.lean-only Phase 3 exists**, under
any proof cleverness. This is structural, not a difficulty estimate.

The restatement is a *dropped-antecedent repair*, and the codebase itself shows the pattern:

- The **interior** obligations `hreal`/`hexcl` already carry the site truth antecedent
  `(igPtW …).eval_at M atomMap w` (EndIntervalConsumerK.lean:117–128). The exterior four do
  not.
- The **Sat halves** already carry the endpoint truth `temporal_truth x1 (kvE_*End P σ)`
  (:147–154). The Real halves do not.
- Inside `kvE_extNegFut_complete`, both consumption points of `hreal` (:171, :182) have
  `hend` (:159–163) and `hpos` (:140) in scope — threading the antecedents through is
  type-mechanical.

### 3.2 Restatement alone is insufficient — the proof must consume the destructor facts

Adding antecedents makes the binders (plausibly) true but leaves them **undischargeable
until the pinned converse (§2.4) exists**, because the discharge at the outer site goes:
ambient + antecedents → pinned σ realization (converse) → bundle conjuncts (converter) →
contradiction for unmarked σ. Equivalently and more cleanly: `kvE_extNeg*_complete` should
be re-proved to consume `hgap`/`hocc` (which it currently discards, :159) plus the ambient,
**eliminating the `hbr*Real` parameters entirely** and weakening `hbr*Sat` to the guarded
form. Either formulation lands the same mathematics; the second shrinks the threaded
interface instead of enlarging it and is the recommended shape.

### 3.3 Concrete spawn recommendation (decisive)

- **Title**: `Restate exterior hbr* obligations under consumption-site antecedents and land
  the pinned fiber-realization converse (kvE_{fut,past}Pinned_of_end)`
- **file_scope**: `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/
  {ExteriorNegationK, ExteriorNegationPastK, ExteriorConverterK, ExteriorConverterPastK,
  ExteriorBracketAssembleK, ExteriorGateAssembleK, EndIntervalConsumerK}.lean` +
  `KampPrior.lean:845–870` (binder-mirror lines only, no arm logic)
- **One-line mandate**: make the four exterior obligations true-as-stated (carry the
  `igPtW`-site and `kvE_*End`-endpoint truth antecedents; preferably eliminate `hbr*Real`
  by re-proving `_complete` from the destructor's `hgap`/`hocc` + ambient via
  `kvE_{fut,past}Pinned_of_end`), keeping every current consumer green.
- **Grounding for the implementer**: §2.3's three-ingredient proof route;
  `nf_characteristic_satisfies`/`nf_eval_unique` (NormalForm.lean:224/:245) for endpoint
  totality; `kvE_futChainDestructG` (ExteriorNegationK.lean:293–303) for the pinned walk;
  the `m = 0` instance first (it closes with landed machinery and is all `:361` needs);
  general `m` as the structured level-descent extension.
- **Blocks**: task 358 Phase 3 AND task 349 v8 Phase 6 ("discharges `hreal`/`hsat`" —
  plans/08:508 — which would otherwise hit the identical false-binder wall).

---

## 4. Q3 — arm-assembly fold: 358 or 349?

**Adjudication: NOT 349. It stays in 358 (revised Phase 3), gated.** Evidence:

- 349 v8 (plans/08_consume-depthk-clause-layer.md) **freezes KampPrior.lean** (NO-EDIT,
  :157, :222, :279) and lists "Wiring `KampPrior.lean:361` (task 309 Phase 14, downstream)"
  as an explicit non-goal (:229). Its deliverable terminates at `endInterval_correct`
  (carrier-level, per-qnf `holds x t ↔ ∃ w, qnf realized` — EndIntervalConsumerK.lean:155–156
  is the already-frozen statement shape).
- The fold — constructing `quantEnd`/`seg` and discharging the `h_quant` hooks
  (Base.lean:1238–1241 past / :1438–1441 future) into `kampPrior_case1_trichotomy_assemble`
  (KampPrior.lean:1133–1147) — is the task-309 **P18/19** frontier ("No hook is discharged
  here", KampPrior.lean:1123), which no open task currently owns: 358's charter is the P14
  successor (realizer), 349's is the endpoint primitive.
- Extending 349 would be its **9th plan version** on a task with 8 — anti-churn (H6) says no.
- The fold IS executable single-file at the KampPrior site once its inputs exist: the
  `h_quant` RHS (`∀ qnf, (∃w realizer) ↔ marked`) is pointwise the per-qnf conclusion of
  `EndIntervalCorrectPrior`; positives come from the carrier correctness `.mpr`, negatives
  from the same biconditional's `.mp` contrapositive; the `∀qnf` fold is a finite
  `formula_conjList` over the NF fintype. Moderate size (~150–400 lines), mechanical GIVEN
  `endInterval_correct` (349 Phases 5–7, currently [NOT STARTED]) and dischargeable
  obligations (§3 spawn).
- The plan's old "return `⟨endIntervalPrior …, proof⟩`" step stays refuted
  (`BracketEndCharCarrierV` is a per-qnf `VVecEA2`, not a `Formula`) — the revised Phase 3
  must go through the trichotomy/hook route above, not a carrier return.

---

## 5. BOTTOM LINE — routing recommendation (orchestrator-actionable)

**(B) with a (C)-refinement — one spawn, two gates, fold stays home:**

1. **SPAWN** the interface task of §3.3 (out-of-scope 7-file redesign + the pinned converse
   `kvE_{fut,past}Pinned_of_end`). This is the single true atom of difficulty.
2. **Mark 358 [BLOCKED]** on: (i) the spawned task, (ii) task 349 Phases 5–7
   (`endInterval_correct`). Do not re-dispatch Phase 3 before both land.
3. **Q3 routes to 358, not 349**: after the gates clear, `/revise` the 358 plan so Phase 3 =
   (a) instantiate the restated (guarded) obligations at the site — unmarked-σ cases
   discharge by contradiction via the pinned converse; marked-σ / interior cases via the
   Phase-2 realizer engine + `kvE_*Bundle_of_realizer`; (b) build the `∀qnf` carrier→formula
   fold and discharge `h_quant` into `kampPrior_case1_trichotomy_assemble`; retire `:361`.
   Phase 4 (`:364`) is unchanged (arity lift over the same engine).
4. **Alternative (A) — a revised in-scope Phase 3 now — is REJECTED** on structural grounds
   (§3.1): the false binders cannot be supplied from KampPrior.lean under any formulation.
5. **Flag to 349's owner**: v8 Phase 6 inherits the same false-binder wall; it should
   consume the spawned task's restated interface rather than attempt discharge against the
   current shapes.

---

## 6. Adversarial Self-Verification (H4)

| Claim | Source/Counterexample | Verification Method | Confidence |
|---|---|---|---|
| C1. As-stated `hbrFutReal`/`hbrPastReal` are semantically false | Blocker's compiled `lean_run_code` probe + P2M countermodel (ExteriorFiberProbeK.lean:61) + task-356 concession (summaries/01:52–55) | machine probe (prior dispatch) + Read of binder shapes at EndIntervalConsumerK.lean:129–154 / KampPrior.lean:845–870 (verbatim match confirmed) | High |
| C2. Rabinovich's existence directions consume only pinned-coordinate truths (`F0(z0)`, `Fi(xi)`, `INF`, mirror-bracket case conditions); no free→pinned inference exists in §5 | chunk_0015:11–43, chunk_0014:15–41, chunk_0016:17–19 read verbatim | direct literature read (chunks 0013–0016, 0021–0023) | High |
| C3. `hend`-guarded binders remain insufficient at fiber depth m ≥ 1 (identification failure) | Constructed countermodel sketch: on-fiber σ ≠ σ′ share `(w,x,t)`-slot atoms (forced by `nfk_dropFresh = σ.1`) and endpoint atomic profile (forced by self-zone coincidence, kvE_futSelfZone = `(false,false)` ⇒ v = x1 via kvE_futZone4_of_above :461 semantics), differing only in depth-m fiber marking — free-env ray/gap rendering (kvE_futItemShift_correct :448–449, env fully free) cannot separate them | zone-coupling semantics verified by Read; countermodel NOT machine-run (flagged for the spawn task's Phase 0 probe) | Medium |
| C4. Complete-type totality + uniqueness are landed | `nf_characteristic` :215, `nf_characteristic_satisfies` :224, `nf_eval_unique` :245 in Theories/Bimodal/Metalogic/WeakCanonical/NormalForm.lean; consumed in-tree at ExteriorFiberProbeK.lean:121–125 | lean_local_search hit (both names) + grep line confirmation | High |
| C5. `kvE_extNegFut_complete` discards the destructor's pinned facts | `obtain ⟨x1, htx1, hend, _hgap, _hocc⟩` (ExteriorConverterK.lean:159) vs destructor conclusion carrying both (ExteriorNegationK.lean:300–303) | Read of both sites | High |
| C6. `hreal`'s consumption points have `hend`/`hpos` in scope (restatement is type-mechanical) | `hpos` intro'd :140; `hend` :159–163; `hreal` used :171, :182 (inside `hfib` after `hend`) | Read of the full proof body :138–190 | High |
| C7. 349 v8 excludes the fold and freezes KampPrior.lean | plans/08:157/:222/:229/:279 ("Wiring KampPrior.lean:361 … downstream" as non-goal) | Read + grep of the v8 plan | High |
| C8. `m = 0` instance of the pinned converse closes with landed machinery (walk geometry + coincidence + totality) | §2.3 item 3; depth-0 fiber elements are atomic, so pinned walk placement + fresh-slot profile = complete datum | reasoning over verified zone/destructor semantics; NOT machine-run | Medium |

**Attempted refutation of the §2.4 proposal (mandated):** I re-ran the blocker's
countermodel logic against the proposed statement. `P2M=(ℤ,<), P={0,10,20}`, σ admissible
with `σ.1` prescribing P at the x1 slot, exterior anchor a non-P point above t: under the
PROPOSED antecedents this configuration is **excluded** — the self-zone coincidence forces
`hend`'s self content to demand P at the endpoint itself, so no chain reaches a non-P
endpoint for that σ; the original counterexample refutes only the unguarded binder. The
surviving attack is C3 (depth-m ≥ 1 marking ambiguity), which the ambient-`h` +
totality + walk-descent ingredients are specifically chosen to close; C3/C8 are flagged
Medium and assigned to the spawn task's Phase 0 as mandatory machine probes (one
`lean_run_code` countermodel attempt against the guarded binder at m = 1, one at m = 0 for
the positive route). **No claim in this report rests on an unverified "mathlib likely has
this"; all cited declarations were existence-checked.**

**Contradiction log**: report 02 §5 declared the task "GREEN-VIABLE, not BLOCKED". No
contradiction after resolution: report 02 adjudicated the WITHIN-BRACKET realizer (Cor
5.4(1)⇐ — landed green as Phase 2) and explicitly caveated ("if those reshapes are not
actually landed/green … 358 re-blocks at the *wiring*"); this round's blocker is exactly
that caveat materializing, one fiber level down. Precedence: machine-verified probe >
report-level optimism (per the resolution protocol).

---

## 7. Divergence audit (H5 — focus_prompt triggered)

**Divergence table** (target: retire KampPrior.lean:361):

| Target | Churn | Last-attempted approach | Failure reason |
|---|---|---|---|
| `:361` arm via obligation discharge (358 P3) | 1 direct + threaded debt from 354→356→357 | report-01 §3 map `hbr* ← kvE_*Bundle_of_realizer hσ` | converter needs a realizer the site ambient REFUTES for unmarked σ (false binders) |
| exterior obligation interface | 3 tasks of outward threading (354, 356, 357) | thread obligations outward "for discharge one level up" | antecedents dropped during threading; outermost level reached with no discharge site |
| endChar/endInterval primitive (349) | 8 plan versions | v8 consume-clause-layer | Phases 5–7 unstarted; Phase 6 discharge will hit the same false binders |
| P18/19 hook fold | 0 attempts (unowned) | none | no owner; inputs (endInterval_correct) not landed |

**Postmortem (root cause of repeated failure)**: an obligation-carrying interface was
threaded outward across three tasks while silently **dropping the truth antecedents under
which the obligations are consumed** (interior siblings kept theirs; the exterior four lost
both the `igPtW` site truth and — for the `Real` halves — the endpoint truth). Each
threading task verified "consumer compiles green" (hypotheses are free), so the falsity
surfaced only at the outermost supply site. Secondary cause: the depth-`k` content channel
rendered fiber elements with a fully-free outer env (`P.existF 4`), diverging from
Rabinovich's canonical-expansion/adjacent-pair discipline (Def 7.7/7.13) in which residual
free anchors do not exist — while the pinned facts that faithful reconstruction needs
(`hgap`/`hocc`) were being returned by the destructor and discarded.

**Corrected Lean-ready targets**: §2.4 (`kvE_futPinned_of_end` + Past mirror, exact
signature given), §3.3 (restated binder shapes), §4 (fold route through
`h_quant`/`kampPrior_case1_trichotomy_assemble` with exact hook signatures at
Base.lean:1238–1241/:1438–1441).

**Sorry inventory** (unchanged from blocker; no edit this dispatch):

| identifier | current state | type | why stuck |
|---|---|---|---|
| KampPrior.lean:361 `\| 1 =>` arm | inherited strategic sorry | `∃ A, ∀ M …, temporal_truth t A ↔ ∃ env : Fin 1 → _, nf_eval_nf M (k+1) 2 (insertEnv env t) sub_nf` | false hbr* binders (pinning gap) + unowned P18/19 fold |
| KampPrior.lean:364 `\| n+2 =>` arm | inherited strategic sorry | arity-(n+1) existential at depth k+1 | serialized behind :361 |

**Type-mismatch analysis**:

| theorem/step | expected | actual | mismatch |
|---|---|---|---|
| plan step "return `⟨endIntervalPrior …, proof⟩`" | `Formula` (arm) | `BracketEndCharCarrierV sig k` = per-qnf `VVecEA2` | carrier ≠ formula; fold layer missing |
| `hbrFutReal` discharge via converter | converter input `hσ : nf_eval_nf M (m+1) 4 [x1,w,x,t] σ` | site ambient provides `¬∃ x1, …` for unmarked σ | required input refuted; obligation false as stated |
| truth channel → obligation | pinned `∃ v, nf_eval_nf M m 5 [v,x1,w,x,t] s` | `∃ env : Fin 4 → _, nf_eval_nf M m 5 (Fin.cons r env) s` (free outer) | 4 coordinates unpinned; only fresh slot pinned |

---

## Appendix — evidence base

- Rabinovich 2014: `~/Projects/Literature/sources/rabinovich_2014/chunk_0013.md` (Lemma 5.1
  setup :29–47), `chunk_0014.md` (Lemma 5.3 :3–41), `chunk_0015.md` (Cor 5.4 + proof
  :3–43), `chunk_0016.md` (Lemma 5.1 cases, eq. 5.3 :17–19), `chunk_0021.md` (Def 7.5 :17),
  `chunk_0022.md` (Def 7.7 :5), `chunk_0023.md` (Def 7.13 :25).
- Lean anchors (all absolute under `/home/benjamin/Projects/BimodalLogic/`):
  `Theories/Bimodal/Metalogic/WeakCanonical/NormalForm.lean:215/224/245`;
  `…/Kamp/NfMultiAnchorBridge/ExteriorNegationK.lean:70, 293–303, 358–361, 395–400, 442–451,
  457–466`; `…/ExteriorConverterK.lean:119–190, 208–225`;
  `…/EndIntervalConsumerK.lean:95–156`; `…/Kamp/KampPrior.lean:838–876, 1111–1147`;
  `…/Kamp/NfMultiAnchorBridge/Base.lean:1230–1244`;
  `…/Kamp/NfMultiAnchorBridge/ExteriorFiberProbeK.lean:57–153`.
- Task artifacts: `specs/358_…/handoffs/phase-3-blocker-20260712.md`;
  `specs/358_…/plans/02_…` Phase-3 [BLOCKED] block (:316–395);
  `specs/349_…/plans/08_consume-depthk-clause-layer.md` (:1–60, :157–229, :304–612);
  `specs/358_…/reports/02_literature-proof-method-survey.md`.
