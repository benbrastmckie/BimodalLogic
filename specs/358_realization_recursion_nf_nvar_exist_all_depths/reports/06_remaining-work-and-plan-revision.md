# Task 358 — Remaining Work and Plan-Revision Guidance (Round 6)

**Task**: 358 — realization_recursion_nf_nvar_exist_all_depths (lean4)
**Agent**: lean-research-agent · **Session**: sess_1784036998_a5fcb0 · **Date**: 2026-07-14
**Mode**: --lit (Rabinovich 2014 per-repo sub-index; Cor 5.4 grounding)
**Tree state**: clean at `6c76ffe58` (`task 309: complete orchestration`); full `lake build`
GREEN (1751 jobs per task-350 completion audit); live Kamp-path sorries = **exactly two**,
`KampPrior.lean:519` and `:522` (grep-verified this round).

**Purpose**: Identify precisely what remains toward (a) revising task 358's plan and (b)
implementing all remaining work. This report is research-only — no Lean or plan files were edited.

---

## TL;DR

1. **The source has advanced past plan v3.** When plan v3 (`plans/03`) was written the entire
   `| 1 =>` arm was a single strategic sorry at `:361`. Since then, task 309 v10 Phases 20–21
   (`kampPrior_case1_arm_k1`) and task 358 Phase 5.1 (`kampPrior_case1_arm_k0`), over task 350's
   six landed `kampArm_*_{k0,k1}_correct` carriers, **discharged the k=0 and k=1 arms**. The
   `| 1 =>` arm is now a `match k, sub_nf` whose k=0/k=1 legs are closed and whose only open leg
   is the **k≥2 residual** (`| _k + 2, _sub_nf =>`, sorry at `:519`). The second sorry (`:522`)
   is the off-critical-path **`| n + 2 =>` arity-lift arm** (G4).

2. **The `blocked` status is JUSTIFIED, not stale — but the `blockers` field is wrong (empty/null).**
   Both remaining sorries need depth-≥1 fiber-marking supply theorems (G1 interior rows 5–6,
   G2 exterior rows 8–11) whose obligation shapes were **machine-refuted FALSE** on the current
   interface by three sorry-free countermodel probes (Phase 6 + Phase 8). Task **363** is the
   interface-restatement task spawned to fix exactly that root cause (D7), and 363 is only
   `researched` (not implemented). So 358 genuinely cannot land green until 363 completes.
   The metadata defect is that `blockers` is `null` when it should name 363.

3. **363 is a genuine hard blocker.** It does not merely "come first": 358's Phase 7/8 supply
   theorems are *literally re-keyed* to whatever binder shape 363 lands (anchored/pinned item
   rendering vs. depth-graded fiber guard). No meaningful green implementation of either sorry is
   possible before 363. The only 358 activity not blocked is *planning* — and even a good v04
   depends on knowing 363's landed signature to state the supply theorems precisely.

4. **Recommended flow**: keep 358 `blocked`; **populate `blockers` with task 363**; drive 363
   through `/plan` → `/implement` first; then `/revise 358` → **plan v04** to re-key Phases 7–8 to
   363's landed interface and drop the four now-[COMPLETED]/[BLOCKED-superseded] phases; then
   `/implement 358` resuming at G2 (exterior) → G1 (interior) → arm rewrites.

---

## 1. Current-state map (plan v3 phase status vs. actual source)

### 1.1 The two live sorries (verified this round)

| Sorry | Line | Arm | Goal shape (from `lean_hover_info` on the match, this session) | Owner |
|---|---|---|---|---|
| S1 | `KampPrior.lean:519` | `\| _k + 2, _sub_nf =>` — the **k≥2 residual** of the `\| 1 =>` arm; `sub_nf : NormalForm sig (_k+3) 2`, per-`qnf` population depth ≥ 2 | `∃ A, ∀ M UZ SZ t, temporal_truth M atomMap t A ↔ ∃ env : Fin 1 → M.carrier, nf_eval_nf M (k+1) (1+1) (insertEnv env t) sub_nf` (at ambient `k = _k+2 ≥ 2`) | task 358 (this task) |
| S2 | `KampPrior.lean:522` | `\| n + 2 =>` — the **arity-lift arm** (off critical path; in-scope for zero-debt) | same RHS at arity `n+2` (`∃ env : Fin (n+2) → M.carrier`) | task 358 G4, serialized after S1 |

The `| 1 =>` arm dispatcher (KampPrior.lean:503–519) now reads:
```
match k, sub_nf with
| 0, sub_nf => kampPrior_case1_arm_k0 atomMap h_surj sub_nf      -- LANDED (task 358 P5.1)
| 1, sub_nf => kampPrior_case1_arm_k1 atomMap h_surj sub_nf      -- LANDED (task 309 P20)
| _k + 2, _sub_nf => sorry                                        -- S1 (:519) — task 358
```
Both `kampPrior_case1_arm_k0` (KampPrior.lean:271) and `kampPrior_case1_arm_k1` (:301) are green,
sorry-free, verified against task 350's `kampArm_{past,diag,future}_{k0,k1}_correct`
(AggregateHookDischarge.lean). The comment at `:507–517` names the live gate for the residual as
the Track-A blocker **`P17-frozen-interface-gap`** (see §4.3).

### 1.2 Plan v3 phase status (reconciled against source + handoffs)

| Phase (plan v3 `03`) | Plan status | Actual state | Notes |
|---|---|---|---|
| 1 — Interface pin + Until-witness | [COMPLETED] | ✅ landed | GO verdict; nine interfaces resolve |
| 2 — Realizer engine `hσ` (Cor 5.4⇐) | [COMPLETED] | ✅ landed sorry-free | `kampPrior_fChain_realize_*`, `_Realizer_assemble/_of_pos` (KampPrior.lean:1192–1649) |
| 3 — Probe A0 (Q-fold hook shape) | [COMPLETED] | ✅ NO-GO recorded | literal `(quantEnd,seg)` hook machine-refuted (task 350 R1/R2); Route V skeleton adopted |
| 4 — Fold/hook assembly arms 0–1 | [BLOCKED] | **SUPERSEDED / effectively done for k≤1** | task 350 delivered the six `kampArm_*_{k0,k1}_correct`; k=0/k=1 arms now closed via `kampPrior_case1_arm_{k0,k1}`. General-k fold folded into S1. |
| 5 — Arm skeleton (depth-2 milestone) | [BLOCKED] (k=0 slice closed) | **partially realized**: k=0 (`arm_k0`) + k=1 (`arm_k1`) both landed; the depth-2 (k≥2) instance is S1 | The "skeleton" now lives as the `match k` dispatcher itself |
| 6 — Probe C0 (general-m slice id, m=1) | [COMPLETED] | ✅ **NO-GO** | `kvE_probeM1_sliceId_NOGO` (ExteriorPinnedProbeM1K.lean:679) refutes rows 8–11 at m≥1 |
| 7 — G2 general-m slice supply (rows 8–11) | [BLOCKED] | ⛔ blocked on 363 interface | statement is FALSE on current interface |
| 8 — G1 interior `hreal`/`hexcl` (rows 5–6) | [BLOCKED] | ⛔ blocked on 363 interface | `kvE_probeM1_interiorHreal_NOGO` (:884) + `kvE_probeM1_interiorGuard_identical` (:899) refute rows 5–6; shares D7 root cause |
| 9 — Arm rewrite retire `:361` | [NOT STARTED] | now = **retire S1 `:519`** | depends on 7+8 |
| 10 — G4 retire `:364` | [NOT STARTED] | now = **retire S2 `:522`** | depends on 9 |

**Net**: Phases 1–3, 6 are done. Phases 4–5 are *substantially subsumed* by the landed
k≤1 machinery (their remaining general-k content is inside S1). Phases 7–8 are hard-blocked on the
same interface defect. Phases 9–10 are downstream of 7–8. So **every path to closing S1/S2 runs
through the depth-≥1 fiber-marking interface that task 363 owns.**

### 1.3 Landed supply/consumer assets (green, consume by name — do NOT re-derive)

| Asset | File:line | Role |
|---|---|---|
| Realizer engine (Cor 5.4⇐) | `kampPrior_fChain_realize_from/_bracket/_cons`, `kampPrior_{fut,past}Realizer_assemble/_of_pos` | KampPrior.lean:1192/1292/1426/1479/1506/1539/1598 | genuine `hσ` given at-anchor transfer inputs |
| Consumer stack | `endIntervalStepPrior/endIntervalPrior/EndIntervalCorrectPrior/endInterval_step_correct/endInterval_correct` | EndIntervalConsumerK.lean:55/70/97/185/220 | recursive endpoint core (357+349) |
| Site seam (single-depth providers) | `kampPrior_site_rungK_gate_match` | KampPrior.lean:924+ | general-k per-qnf seam carrying the 11 obligations (route R1) |
| Provider shim | `kampPrior_existProviders_of_ih` (+`_correct/_existF0_char/_exist1/_one_of_ih/_zero`) | KampPrior.lean:985–1122 | `ExistProviders` from the recursion IH |
| Trichotomy assemble | `kampPrior_case1_trichotomy_assemble` | KampPrior.lean:1146 | `Formula.or` fold of past/diag/future carriers |
| k=0/k=1 arm lemmas | `kampPrior_case1_arm_k0`, `kampPrior_case1_arm_k1` | KampPrior.lean:271/301 | discharge the k≤1 legs (over task 350 carriers) |
| Off-diagonal carriers (k0/k1) | `kampArm_{past,diag,future}_{k0,k1}(_correct)` | AggregateHookDischarge.lean | Route-V skeleton conclusions (task 350) |
| m=0 slice supply | `kvE_hsliceFut_supply_zero`/`kvE_hexclSliceFut_supply_zero` (+ Past mirrors) | ExteriorPinnedConverseK.lean:1301/1242; PastK:822/769 | rows 8–11 at m=0 (task 360) |
| Slice-id/uniqueness kernels (m=0) | `kvE_{fut,past}SliceId_of_end_zero`, `kvE_{fut,past}SliceUnique_zero` | ExteriorPinnedConverseK.lean:891; PastK:530 | m=0 identification (task 360) |
| Refutation regression guard | `kvE_futPinned_of_end_zero_refuted` | ExteriorPinnedConverseK.lean:500 | do not delete/weaken |
| m≥1 countermodel probes | `kvE_probeM1_sliceId_NOGO`, `kvE_probeM1_interiorHreal_NOGO`, `kvE_probeM1_interiorGuard_identical` | ExteriorPinnedProbeM1K.lean:679/884/899 | the frozen NO-GO evidence 363 must overturn |

---

## 2. Blocker adjudication

### 2.1 Is the `blocked` status stale? — NO, it is justified.

The delegation prompt asked whether the `blocked` status is stale because `blockers` is empty.
Finding: **the status is correct; the `blockers` field is a metadata defect (it is `null`).**

- Task 358's remaining obligations are the interior rows 5–6 (`hreal`/`hexcl`, KampPrior:835–846)
  and exterior rows 8–11 (`hslice*`/`hexclSlice*`, EndIntervalConsumerK.lean:141–162), each at
  general depth m ≥ 1 (i.e. ambient k ≥ 2, S1).
- All three obligation shapes were machine-refuted FALSE at m = 1 by sorry-free countermodel
  probes (Phase 6, Phase 8; ExteriorPinnedProbeM1K.lean). They cannot be proved as stated.
- The repair is a single interface restatement (the doppelgänger-tail fake `s*` must be excluded).
  That repair is task **363**, which is `researched` — **not yet implemented**.

Therefore 358 remains genuinely blocked. **Recommendation: leave status `blocked` and populate the
`blockers` field**, e.g.:
```
"blockers": ["363: depth>=1 fiber-marking interface restatement — 358 Phases 7/8 supply theorems
              (rows 5-6, 8-11) are re-keyed to 363's landed rungK/igFoldBit binder shape; 363 is
              only researched"]
```

### 2.2 What does 363 supply that 358 needs?

363's deliverable is a restated **rungK obligation binder / `igFoldBit` consumer seam** such that
depth-≥1 fiber marking is *pinned* rather than free-env/projected — via either
(a) **anchored/pinned item rendering** (carry the fiber's full pinned coordinates through the
binder), or (b) a **depth-graded fiber guard** (strengthen the admissibility/fold-bit guard to
distinguish fibers by depth-graded content the projection currently discards). 363's definition of
done is that the **existing** probes `kvE_probeM1_sliceId_NOGO`,
`kvE_probeM1_interiorHreal_NOGO`, `kvE_probeM1_interiorGuard_identical` no longer apply to the new
interface (re-probe GREEN) — a restated signature alone is not sufficient.

This directly determines how 358 states and proves:
- **G2** (Phase 7): `kvE_{fut,past}SliceId_of_end` and `kvE_{fut,past}SliceUnique` at general m,
  plus the four `kvE_hsliceFut_supply` / `kvE_hexclSliceFut_supply` (+ Past) supply theorems — all
  keyed to 363's slice-equality/rendering shape.
- **G1** (Phase 8): `kampPrior_hreal_supply` / `kampPrior_hexcl_supply` (rows 5–6) — keyed to
  363's `igFoldBit` consumer seam.

Because these proof obligations are *literally re-keyed* to 363's landed signature (not merely
sequenced after it), this is an implementation-detail dependency: **363 is a hard blocker**, and
358 cannot even write a final v04 supply-theorem statement without it.

### 2.3 Can 358 proceed independently / partially? — Not to green.

No partial green win remains inside 358 before 363 lands:
- S1 (k≥2) requires G1+G2 supply at fibers depth ≥ 1 → 363.
- S2 (`| n+2 =>`) reduces through the `| 1 =>` machinery (route (i)) or the docstring bootstrap
  (route (ii)); either way it must hold at all ambient k including k ≥ 2, so it inherits the S1
  block.
- The A-branch (G3 fold) is resolved for k ≤ 1 (task 350 + arm_k0/k1); its general-k residue is
  inside S1 and shares the 363 dependency.

The one unblocked activity is **planning** (revise to v04) — but see §4 for why the *precise*
supply-theorem statements should be finalized only after 363's signature is known.

### 2.4 Other dependencies (349, 357, 360) — all satisfied.

349, 357, 360 are COMPLETED/archived and their assets are landed and consumed by name (§1.3).
They are no longer active blockers. Only 363 remains.

---

## 3. Remaining-work decomposition (ordered proof obligations)

Keyed to real codebase lemma names and to Rabinovich 2014 Cor 5.4 (chunks 0014–0016, 0021–0023).
"NEW" = must be newly proven; "EXISTS" = landed asset consumed by name.

### Prerequisite (external, task 363): pinned/depth-graded fiber-marking interface
- **363-1** (NEW, task 363): restate rungK binder (KampPrior:835–846) + `igFoldBit` consumer seam
  (InteriorGateGeneralK.lean:318) so depth-≥1 fiber marking is pinned/depth-graded.
- **363-2** (NEW, task 363): re-probe `kvE_probeM1_*` GREEN (countermodel no longer applies).
- Gate: until 363-1/363-2 land, obligations G2-*/G1-* below are FALSE-as-stated. **Do not attempt.**

### G2 — exterior general-m slice supply (rows 8–11), depends on 363
Rabinovich Lemma 5.1 Cases 1–3 (first-point `inf`, `INF` definability) generalized off m=0.
1. **G2-1** (NEW): `kvE_{fut,past}SliceId_of_end` at general m — endpoint slice identification;
   walked-point/endpoint types rendered through `charF`/providers (level descent). Generalizes
   `kvE_{fut,past}SliceId_of_end_zero` (ExteriorPinnedConverseK.lean:891 / PastK:530). Re-keyed to
   363's rendering.
2. **G2-2** (NEW): `kvE_{fut,past}SliceUnique` at general m. Generalizes
   `kvE_{fut,past}SliceUnique_zero`. Build the uniqueness/readback kernel ONCE (route R3) — G1's
   `hexcl` (below) consumes it too.
3. **G2-3** (NEW): the four supply theorems `kvE_hsliceFut_supply` / `kvE_hexclSliceFut_supply`
   (+ Past mirrors) at general m, conjunct-by-conjunct against the frozen m=0 layer (route R2).
   The `hexclSlice*` proofs consume only carried `hreal` + G2-2 + admissibility zone readback; the
   `hslice*` proofs consume the destructor + G2-1.
   - Territory: `ExteriorPinnedConverseK.lean`, `ExteriorPinnedConversePastK.lean` (m=0 frozen).

### G1 — interior `hreal`/`hexcl` supply at general depth (rows 5–6), depends on 363 + G2-2
The dominant new mathematics — Rabinovich Cor 5.4(1)⇐ level descent (chunks 0021–0023 IH).
Obligation shapes (rungK binders, KampPrior:835–846): for all `w ∈ (x,t)` satisfying the
`igPtW` guard,
- `hreal`: every bit-true `σ : NormalForm sig (k+1) 4` has SOME `x1` with pinned realization
  `nf_eval_nf M (k+1) 4 [x1,w,x,t] σ`;
- `hexcl`: every bit-false σ has NO realizer with `x ≤ x1 ≤ t`.
4. **G1-1** (NEW): split the `w` population.
   - ⇒-direction ws (ambient `nf_eval_nf M (k+2) 3 [w,x,t] qnf` in scope): the ∀σ agreement is
     DEFINITIONAL — discharge outright.
   - ⇐-direction ws (igPtW-selected): render w's realization of `igFoldBit qnf` via `hcharK` +
     `P.correct` + `kampPrior_existProviders_of_ih_existF0_char` (KampPrior:1026; fiber-existential
     read InteriorGateGeneralK.lean:318/387), under 363's pinned seam.
5. **G1-2** (NEW): per marked σ, the fold-bit → chain-firing bridge:
   - exterior-zone σ: fold bit fires `kvE_{fut,past}Pos (Pbr) σ`; **EXISTS** drivers
     `kampPrior_{fut,past}Realizer_of_pos` (KampPrior:1539/1598) select `x1` and emit `hσ`; their
     `hreal`/`hsat` transfer inputs (:1546–1554/1605–1613) are the SAME statement one fiber level
     down (σ's fibers `s : NormalForm sig k 5`) — close by the recursion's IH at depth k
     (level descent); depth-0 base fully atomic (ExteriorFiberProbeK.lean:252 pattern).
   - interior-zone σ (`x1 ∈ (x,t)`): **EXISTS** `kampPrior_fChain_realize_bracket` (KampPrior:1426)
     with F-chain firing from the fold-bit fiber content, bracket endpoints `(x,t)`.
6. **G1-3** (NEW): `hexcl` — the contrapositive channel: a within-`[x,t]` realizer of a bit-false σ
   back-propagates through the fold (`nf_eval_nfk_iff_efold`, off-fiber falsity from admissibility)
   to contradict the igPtW agreement, via the G2-2 uniqueness/readback kernel (R3).
   - Deliverables: `kampPrior_hreal_supply`, `kampPrior_hexcl_supply` (NEW), matching the S1
     obligation hypothesis shapes for rows 5–6. Territory: KampPrior.lean (or a new Kamp/ leaf).

### G3(c) — the arm rewrite that retires S1 (`:519`), depends on G1 + G2
7. **G3c-1** (NEW edit): in the `| _k + 2, _sub_nf =>` body, instantiate providers via
   `kampPrior_existProviders_of_ih … (fun n sub => nf_nvar_exist_all_depths atomMap h_surj j n sub)`
   at `j = k'+1, k'` (structurally decreasing recursive calls — the documented Phase-16 move,
   KampPrior:955–958). Rows 1–2 discharged.
8. **G3c-2** (NEW edit): discharge rows 5–6 via G1, rows 8–11 via 360's m=0 + G2-3; rows 3–4
   ambient; row 7 internal (task 356). Close via `kampPrior_case1_trichotomy_assemble` (:1146) +
   `kampPrior_site_rungK_gate_match`. Replace the `:519` sorry. Update the fencing note
   (KampPrior:352–360 + the residual comment :507–517) in the SAME edit (route R4).

### G4 — retire S2 (`:522`, `| n+2 =>`), depends on S1 closed
9. **G4-1** (NEW): adjudicate at phase start (report 04 §3 G4):
   (i) iterated one-variable reduction through the `| 1 =>` machinery
   (`Fin.cons x (insertEnv env t) = insertEnv (Fin.cons x env) t`, KampPrior:235; needs an
   arity-general restatement of the arity-2-specific trichotomy/nf_char2 layer) vs.
   (ii) docstring bootstrap (KampPrior:323–331). The realizer engine/drivers are already
   arity-generic (`BracketFormula (n+1)`, KampPrior:1183–1185). If neither closes green → [BLOCKED]
   + spawn isolated arity-lift task; S1 stays landed; never a carried sorry.

**Newly-proven vs. existing summary**: G2-1/2/3, G1-1/2/3 supply theorems and both arm rewrites are
NEW (all downstream of 363). The realizer engine, drivers, consumer stack, provider shim,
trichotomy assemble, m=0 supply, and slice-id/uniqueness m=0 kernels all EXIST and are consumed by
name.

---

## 4. Plan-revision guidance (plan v04)

### 4.1 When to revise
`/revise 358` → **v04 should be produced AFTER task 363 lands its interface** (so the G2/G1 supply
theorem statements can be keyed to the actual binder signature). A *conditional* v04 could be
drafted now, but its supply-theorem statements would be provisional until 363's shape is fixed —
avoid re-churn by scheduling v04 immediately post-363.

### 4.2 Recommended v04 phase breakdown (each phase ≈ one agent run, ~100–500 lines)
Drop/relabel the superseded phases; do not re-litigate settled decisions:

| v04 Phase | Content | Depends on | Landing shape |
|---|---|---|---|
| P1 — Consume 363 interface | Pin 363's restated rungK/`igFoldBit` binder by name; re-verify the three `kvE_probeM1_*` re-probe GREEN; record the exact supply-theorem signatures | 363 done | interface-pin note, no code |
| P2 — G2 slice-id + uniqueness (general m) | G2-1 + G2-2 (build the shared readback kernel once, R3) | P1 | `kvE_*SliceId_of_end` / `_SliceUnique` general-m, green |
| P3 — G2 four supply theorems | G2-3 conjunct-by-conjunct vs frozen m=0 (R2) | P2 | four supply theorems green, m=0 unregressed |
| P4 — G1 interior supply | G1-1 + G1-2 + G1-3 → `kampPrior_hreal_supply` / `kampPrior_hexcl_supply` | P2 (shares kernel), P3 | rows 5–6 supply green |
| P5 — Arm rewrite, retire S1 | G3c-1 + G3c-2; instantiate providers, discharge 11 rows, close via trichotomy assemble; replace `:519`; update fencing note (R4) | P3, P4 | `:519` gone; only remaining sorryAx from `:522` |
| P6 — G4, retire S2 | G4-1 route adjudication; replace `:522`; full-tree green + axiom audit | P5 | zero live sorries in KampPrior; clean axiom footprint |

Note: plan v3's Phases 1–3/6 stay [COMPLETED] (carry forward verbatim); Phases 4–5 collapse into
"already landed for k≤1" preamble; the depth-2 milestone is already realized by
`kampPrior_case1_arm_{k0,k1}`.

### 4.3 Interface/seam risks — the "P17-frozen-interface-gap"
The residual comment at KampPrior.lean:507–517 names the live gate for the k≥2 arms as
**`P17-frozen-interface-gap`**: the `hrealI`/`hrealB` **anchor-content interface gap**
(OuterGate:374/:380) — "the frozen producer chain's `kvE2_sepPtW` is a point-type at `w` and drops
the x/t anchor content" (convergent three-agent finding, task 309 plan v9 Phase 17).

**Adjudication: P17-frozen-interface-gap is NOT independently resolved.** It is the *ancestor
framing of the exact root cause task 363 owns*: content dropped by a projected/free-env rendering
(point-type at `w`, anchor content discarded) is the same failure mode as D7 (the doppelgänger-tail
fake `s*` is projection-invisible through the `igFoldBit (zone, nfk_projFresh)` arity-1 F1 channel,
InteriorGateGeneralK.lean:318). The post-360 gap map (report 04) recast P17 into the G1/G2 supply
gaps, and the m=1 probes (Phase 6/8) localized it precisely as D7. **363's pinned/depth-graded
interface is the resolution of P17.** v04's P1 must confirm 363 closed the *anchor-content* variant
(x/t anchor coordinates carried through the binder), not merely a slice-list equality tweak —
otherwise the G1 driver transfer inputs (`hreal`/`hsat`, KampPrior:1546–1554) remain unservable.

### 4.4 Settled decisions to carry forward (do NOT re-open)
- Method = Rabinovich Cor 5.4(1)⇐ (landed, Phase 2). Site route = `kampPrior_site_rungK_gate_match`
  with single-depth providers (R1) — NOT `endInterval_correct`.
- Do NOT route exterior discharge through `kvE_{fut,past}Bundle_of_realizer` (machine-refuted v2
  route). Do NOT delete `kvE_futPinned_of_end_zero_refuted`. Do NOT re-introduce `hbr*` binders.
- Formula A must be M-independent (fold over the finite qnf population). House style: no
  `simp`/`omega`/`aesop` past literature-mapped case-splits.
- Zero-debt terminus: no sorry, no vacuous def. If G2/G1 still won't close after 363, escalate
  [BLOCKED] + spawn — never force a proof against a live countermodel.

---

## 5. Verification bar (acceptance criteria for v04)

1. **Build green**: scoped `lake build` per phase
   (`Bimodal.Metalogic.WeakCanonical.Kamp.KampPrior` + the `ExteriorPinnedConverse{K,PastK}` for
   G2 phases); full-tree `lake build` GREEN at the terminal phase (current baseline: 1751 jobs).
2. **Re-probe GREEN (v04 P1 gate)**: `kvE_probeM1_sliceId_NOGO`,
   `kvE_probeM1_interiorHreal_NOGO`, `kvE_probeM1_interiorGuard_identical` must be shown *not to
   apply* to 363's restated interface (this is 363's DoD; v04 confirms it before building supply).
3. **Zero live sorries**: at terminus, `grep -n "sorry" KampPrior.lean` shows no live `sorry`
   (only doc/comment occurrences). Currently exactly two live sorries (`:519`, `:522`).
4. **Axiom transcript**: `nf_nvar_exist_all_depths` is currently **sorryAx-dependent** (via the two
   open arms). Full retirement means:
   - `lean_verify` on `nf_nvar_exist_all_depths` (and the downstream
     `nf_characterizable_temporal_prior`, KampPrior:407) shows axiom closure exactly
     `[propext, Classical.choice, Quot.sound]` with **no `sorryAx`**.
   - `#print axioms completeness_discrete` = `[propext, Classical.choice, Quot.sound]`
     (+ acceptable `ofReduceBool`/`trustCompiler` from `native_decide` in the Syntax layer, and
     NOT `sorryAx`). Any `sorryAx` is a FAIL.
5. **Per-phase `lean_verify`**: each new supply theorem / arm rewrite verified at the floor
   axioms, no new axiom, no `sorryAx`.
6. **No regressions**: 360's m=0 layer, the refutation regression guard, and all modules outside
   per-phase territory stay green; the k=0/k=1 arm lemmas (`kampPrior_case1_arm_{k0,k1}`) untouched.

---

## 6. Concrete recommendations (actionable)

1. **Fix metadata**: set 358 `blockers` to reference task 363 (currently `null`). Keep status
   `blocked`.
2. **Unblock path**: `/plan 363` → `/implement 363` (the depth-≥1 fiber-marking interface
   restatement + re-probe). 363 has no dependencies and is the sole blocker.
3. **After 363 lands GREEN**: `/revise 358` → plan **v04** (§4.2), keyed to 363's actual binder
   signature; then `/implement 358` resuming at G2 (P2) → G1 (P4) → arm rewrites (P5/P6).
4. **Do NOT** attempt any G1/G2 supply build-out before 363 — the statements are machine-refuted
   FALSE on the current interface; that path landed three NO-GO probes already.

---

## 7. Evidence base
- Source (verified this round): `KampPrior.lean:271/301/503–522/835–846/924+/985–1122/1146/1192–1649`
  (grep + `lean_hover_info` on the `| 1 =>` match; two live sorries at `:519`/`:522`).
- Probes: `ExteriorPinnedProbeM1K.lean:679/884/899` (three sorry-free NO-GO countermodels).
- Prior artifacts: reports 04 (`04_post-360-gap-map-and-route.md`, authoritative gap map) and 05
  (`05_spawn-analysis.md`); plan `03_post-360-gap-closure.md`; handoffs phase-6/phase-8.
- State: `specs/state.json` (358 `blocked`, `blockers: null`, deps [349,357,360,363]; 363
  `researched`, no deps; 350 `completed`); git `6c76ffe58`, clean tree.
- Literature: Rabinovich 2014 `~/Projects/Literature/sources/rabinovich_2014/` chunk_0015 (Cor 5.4⇐,
  landed verbatim), chunks 0014–0016/0021–0023 (Lemma 5.1 Cases, level-descent IH).
