# Post-360 Gap Map and Route to Retire KampPrior:361/:364 — Task #358 (Round 4)

**Task**: 358 — realization_recursion_nf_nvar_exist_all_depths
**Agent**: lean-research-agent · **Session**: sess_1783979891_6ad95e_358 · **Date**: 2026-07-13
**Mode**: --lit (per-repo sub-index present; Rabinovich 2014 consulted directly)
**Tree state**: clean at `f4d7b70ff`; full build GREEN per task-349 Phase-7 audit (1736 jobs);
live Kamp-path sorries = exactly `KampPrior.lean:361` and `:364` (grep-verified this round).
**Supersedes**: the stale framings in reports 01–03 and the phase-3 blocker where they predate
tasks 349/357/360 — all three of report 03's routing recommendations have since EXECUTED
(spawn → task 360 COMPLETED; gate → task 349 COMPLETED; fold stays home → this report's G3).

---

## TL;DR

1. **The landscape has moved decisively since the phase-3 blocker.** Task 360 ELIMINATED the four
   machine-refuted exterior `hbr*` obligations repo-wide and replaced them with a slice-keyed,
   fiber-guarded interface (`hslice*`/`hexclSlice*`) including **four m=0 supply theorems**;
   tasks 357+349 landed and adopted the obligation-carrying consumer stack
   (`endInterval_correct`) with a binding 11-row obligation-disposition ledger
   (EndIntervalConsumerK.lean:228–253). The blocker's Finding 1 (pinning gap) is RESOLVED at
   the interface level; Finding 2 (arm assembly) remains and is now precisely locatable.
2. **The delegation prompt's framing is partially stale**: there are no live `hbr*` binders
   (360 audit: 0 repo-wide), and `kvE_{fut,past}Bundle_of_realizer` is no longer the exterior
   discharge seam. The exterior obligations are the slice family, discharged at m=0; their
   general-m extension is one of this task's gaps (G2 below).
3. **What remains to retire `:361` decomposes into three gaps** (plus one for `:364`):
   **G1** interior `hreal`/`hexcl` supply at general depth (the dominant new mathematics — the
   Rabinovich Cor 5.4 ⇐ level-descent, for which task 358's own Phases 1–2 already landed the
   complete chain-realizer engine and drivers); **G2** general-m slice supply (structured
   extension of 360's m=0 theorems); **G3** the hook/fold assembly (carrier→formula fold into
   the `h_quant`/diag hooks and the trichotomy assemble — the un-owned 309 P18/19 frontier);
   **G4** the `:364` arity lift.
4. **Recommendation**: `/revise` to plan v3 with six single-dispatch phases (§6), probe-first
   where design questions are open (Q-fold, the general-m identification probes report 03
   flagged as C3/C8). No phase needs a sorry; each has a green landing shape.

---

## 1. Current state — machine-grounded inventory (what is LANDED and green)

### 1.1 The target (unchanged)

`nf_nvar_exist_all_depths` (KampPrior.lean:212–364): by recursion on depth `k`, all arities
simultaneously. Depth-0 arm closed (`nf_nvar_exist_depth0_tl_fn`, :224–227). At `| k+1 =>`,
`char_k1` at arity 1 is built from the depth-`k` IH (`ih_exist_1`, :265–304); the match on `n`
closes `| 0 =>` (:335–346) and leaves:

- `:361` — `| 1 =>` arm: `sub_nf : NormalForm sig (k+1) 2`, goal `∃ A, ∀ M h_UZ h_SZ t,
  temporal_truth t A ↔ ∃ env : Fin 1 → M.carrier, nf_eval_nf M (k+1) 2 (insertEnv env t) sub_nf`.
- `:364` — `| n+2 =>` arm: same at arity n+2 (off the critical path for the main theorem, but
  in-scope for zero-debt retirement).

Only consumer of the `| 1 =>` instance on the critical path:
`nf_characterizable_temporal_prior` (:407, `succ` arm :425–439) — the depth induction that
feeds Kamp/Prior completeness. The in-source fencing note (:352–360) binds retirement to
"task 348's discharge theorem + the Phase-14 provider instantiation"; the provider shim is now
landed (§1.4) and 348's k=2 gate has been superseded by the general-k stack (§1.3).

### 1.2 Task 358 Phases 1–2 (LANDED, green): the Cor 5.4(1)⇐ realizer engine

All in KampPrior.lean, sorry-free, axiom-clean:

| Asset | Line | Content |
|---|---|---|
| `kampPrior_fChain_realize_cons` | :1192 | chain-link prepend (shared assembly step) |
| `kampPrior_fChain_realize_from` | :1292 | Cor 5.4(1)⇐ suffix induction with the two-way `min`/case-split — verbatim Rabinovich chunk_0015:19–37 |
| `kampPrior_fChain_realize_bracket` | :1426 | within-bracket witness `z ∈ (z0, z1]` — the bounded resolution of the EANegation:1249 Until-unboundedness obstruction |
| `kampPrior_futRealizer_assemble` / `pastRealizer_assemble` | :1479 / :1506 | genuine `hσ` fold-up at an anchor via `nf_eval_nfk_iff_efold` (positive mirror of the converter body) |
| `kampPrior_futRealizer_of_pos` / `pastRealizer_of_pos` | :1539 / :1598 | drivers: from `kvE_{fut,past}Pos P σ` firing, the chain destructor selects the exterior anchor `x1` and emits `hσ` — arity-generic |

The drivers' remaining INPUTS are the at-anchor transfer hypotheses (`hreal`/`hsat`,
:1546–1554 / :1605–1613): pinned fiber realization/saturation one fiber level down. These are
exactly the level-descent obligations G1 consumes the recursion's IH for (§3.1).

### 1.3 Tasks 357 + 360 + 349: the obligation-carrying consumer stack (LANDED, green)

- `endIntervalStepPrior` / `endIntervalPrior` / `EndIntervalCorrectPrior` /
  `endInterval_step_correct` / `endInterval_correct` — EndIntervalConsumerK.lean:55/:70/:97/:185/:220.
- Site seam: `kampPrior_site_rungK_gate_match` (KampPrior.lean:818–888) — the general-k per-qnf
  seam restatement of `bracketEndChar_kvExt_correct_prior` (ExteriorGateAssembleK.lean:106),
  carrying the 11 obligations. Takes SINGLE-depth providers (`P` at k+1, `Pbr` at k) — no total
  provider family needed at the site (unlike `endInterval_correct`'s `Pfam : (j : Nat) → …`;
  route note R3, §5).
- Task 360 replaced the machine-refuted `hbr*` family (regression guard preserved:
  `kvE_futPinned_of_end_zero_refuted`, ExteriorPinnedConverseK.lean:500) with the slice-keyed
  interface and landed the **m=0 supply theorems**:
  `kvE_hsliceFut_supply_zero` (ExteriorPinnedConverseK.lean:1301 — UNCONDITIONAL given a
  depth-0 provider + h_UZ/h_SZ; destructor + `kvE_futSliceId_of_end_zero` :891),
  `kvE_hexclSliceFut_supply_zero` (:1242 — conditional only on the CARRIED interior `hreal`;
  slice-mate realization + admissibility zone readback + `kvE_futSliceUnique_zero`), and the
  Past mirrors (ExteriorPinnedConversePastK.lean:822/:769, slice-id converse :530).

### 1.4 Task 309 Phases 15/16/18 assets in KampPrior.lean (LANDED, green)

| Asset | Line | Role |
|---|---|---|
| `kampPrior_site_env_bridge` | :650 | `∃ env : Fin 1` ⟷ `∃ x` on `Fin.cons x (fun _ => t)` |
| `kampPrior_site_trichotomy` | :677 | site RHS ⟷ past ∨ diag ∨ future disjuncts |
| `kampPrior_site_perQnf_seam` | :694 | depth-(k+1) unfolding: atom layer ∧ ∀qnf agreement (`Iff.rfl`) |
| rung ladder | :707/:733/:761/:818 | arm 0 unconditional; arm 1 `h0` only; arm 2 legacy k=2 gate; arms ≥ 2 uniformly `rungK` (11 obligations) |
| `kampPrior_existProviders_of_ih` (+`_correct`, `_existF0_char`, `_exist1`, `_one_of_ih`, `_zero`) | :985–:1122 | the Phase-16 provider shim: `ExistProviders` from the recursion's IH shape; concrete green depth-0 instance |
| `kampPrior_case1_trichotomy_assemble` | :1146 | `Formula.or` assembly: given `A_past`/`A_diag`/`A_future` correctness, the composed formula realizes the full `| 1 =>` RHS |

### 1.5 The arm formula builders (Base.lean, task 309 P3–P5, LANDED)

- `nf_char2_past_formula` / `_correct` — Base.lean:1239/:1262; hook `h_quant` (:1270–1273):
  `∀ x < t, (quantEnd.eval_at x ∧ seg.holds x t) ↔ (∀ qnf : NormalForm sig k 3,
  (∃ w, nf_eval_nf M k 3 (zoneEnv3 w x t) qnf) ↔ sub_nf.2 qnf = true)`.
- `nf_char2_future_formula` / `_correct` — Base.lean:~1430 (structural dual, flipped order guard).
- `A_diag` / `A_diag_correct` — Base.lean:741/:758; hooks (:765–773): per-qnf POINTWISE
  characterizations `pastEnd qnf` at `w < t` / `futureEnd qnf` at `w > t` ↔
  `nf_eval_nf M k 3 (Fin.cons w (fun _ => t)) qnf`, and `diagChar qnf` at `t` ↔ the all-diagonal
  evaluation.
- Per KampPrior:1136: "**No hook is discharged here** (that is the remaining frontier of
  Phase 18/19)" — this frontier is G3.

### 1.6 The obligation-disposition ledger (binding; EndIntervalConsumerK.lean:235–247)

| # | Obligation | Status | Remaining owner |
|---|---|---|---|
| 1–2 | `P`, `hcharK` | shim landed (§1.4) | site instantiation = G3(c) |
| 3–4 | `h_UZ`, `h_SZ` | ambient at every Prior site | — |
| 5–6 | `hreal`, `hexcl` (interior) | **OPEN** | **G1 (task 358)** |
| 7 | `hexclExt` | discharged internally (task 356) | — |
| 8–11 | `hslice*`/`hexclSlice*` | **m=0 DISCHARGED** (task 360) | general m = **G2 (task 358)** |

### 1.7 Corrections to the delegation prompt (staleness)

- "the four task-356 exterior hbr* obligations": RETIRED. 0 live `hbr*` binders repo-wide
  (task-360 Phase-6 audit). The exterior obligations are now rows 8–11 above.
- "The discharge site for the exterior hbr* is kvE_{fut,past}Bundle_of_realizer
  (ExteriorConverterK.lean:208 / ExteriorConverterPastK.lean:177)": no longer the seam. The
  bundle converters survive as the *exact inverses* the Phase-2 assemblers mirror
  (KampPrior:1478/:1505 docstrings) but nothing routes obligation discharge through them.
- "The missing piece is PRODUCING hσ": half-true post-360. The drivers already produce `hσ`
  from `kvE_*Pos` truth GIVEN the at-anchor transfer hypotheses; the missing mathematics is
  (i) supplying those transfer hypotheses by level descent (G1) and (ii) everything in G2/G3.

---

## 2. Literature grounding (Rabinovich 2014; per-repo sub-index, read this round)

| Paper step | Source | Lean status |
|---|---|---|
| Cor 5.4(1) statement + ⇐ induction with the two-way `min`/case-split ("If y2 ≤ xn+1 then z = y2 … otherwise xn+1 ∈ (y1, y2) … z = xn+1") | chunk_0015:9–37 | **LANDED verbatim** — `kampPrior_fChain_realize_from` (:1292), `_bracket` (:1426) |
| Cor 5.4(1) `¬F0(z0) ∨ On(…)` chain device | chunk_0015:39–41 | LANDED — `kvE_futPos`/chain layer (ExteriorNegationK) |
| Cor 5.4(2) mirror re-anchoring; Lemma 5.1 Cases 1–3 (case-condition truths, first-point `inf` r0 on Dedekind complete chains, `INF` definability) | chunk_0015:43–:59, chunk_0016:17–19, chunk_0014 | LANDED at k=2/m=0 (`HasAttainedINF` arity-2; 360's slice-id converses); general m = G2 |
| Induction on quantifier depth (the canonical-expansion level descent; Def 7.7/7.13 adjacent-anchor discipline) | chunks 0021–0023 | The recursion's IH availability at depths ≤ k IS this descent; G1/G2 are its two consumption points |

Fidelity note: G1's route (§3.1) follows the paper's own structure — every hypothesis consumed
is a truth at pinned coordinates (endpoint/interval/case-condition), never a free→pinned
inference; task 360's slice re-key restored precisely the Def 7.13 discipline the refuted
`hbr*` shapes had violated (360 summary, "The Three Faithful Rabinovich-Grounded Repairs").

---

## 3. The remaining gap decomposition

### G1 — interior `hreal`/`hexcl` supply at general depth (dominant; rows 5–6)

**Exact obligation shapes** (rungK binders, KampPrior:835–846; `EndIntervalCorrectPrior`
mirrors :119–130): for all `w ∈ (x,t)` with
`(igPtW (nf_depth0_char_formula …) (charF (k+1)) qnf.1 (igFoldBit qnf)).eval_at M atomMap w`:
- `hreal`: every bit-true `σ : NormalForm sig (k+1) 4` has SOME `x1` with pinned realization
  `nf_eval_nf M (k+1) 4 [x1,w,x,t] σ` (existential over x1 — NOT the refuted universal shape);
- `hexcl`: every bit-false σ has NO realizer with `x ≤ x1 ≤ t`.

**Two structurally different `w` populations** (important for the proof plan):
1. **⇒-direction ws (ambient-realized)**: where the site has
   `nf_eval_nf M (k+2) 3 [w,x,t] qnf`, the ∀σ agreement is DEFINITIONAL
   (`nf_eval_nf` unfolding = atom layer ∧ ∀σ, (∃x1 …) ↔ bits) — `hreal`/`hexcl` at such w are
   free. (This is why 360's `kvE_hexclSliceFut_supply_zero` could consume `hreal` as carried.)
2. **⇐-direction ws (igPtW-selected, no ambient)**: the genuinely new mathematics. `igPtW`
   truth at w renders (via `hcharK` + `P.correct` + `_existF0_char`, KampPrior:1026) w's
   realization of the arity-1 fold `igFoldBit qnf` (fiber-existential read:
   InteriorGateGeneralK.lean:318/:387). Reconstruction per marked σ:
   - **exterior-zone σ**: the fold bit fires `kvE_{fut,past}Pos (Pbr) σ` at the appropriate
     anchor; the landed drivers (`kampPrior_{fut,past}Realizer_of_pos`) select `x1` and emit
     `hσ` — their `hreal`/`hsat` transfer inputs are the SAME statement one fiber level down
     (σ's fibers `s : NormalForm sig k 5`), closing by the recursion's IH at depth k
     (level descent) with the depth-0 base fully atomic (pattern demonstrated green:
     ExteriorFiberProbeK.lean:252 concrete depth-0 provider instance; the k=1/m=0 rung is
     where 360's supply theorems already run this).
   - **interior-zone σ** (`x1 ∈ (x,t)` prescribed by σ's zone spec): the within-bracket case —
     exactly `kampPrior_fChain_realize_bracket` (:1426), whose F-chain firing comes from the
     fold-bit fiber content, with bracket endpoints `(x,t)` carried per the Phase-2 design.
   - **`hexcl`**: the contrapositive channel — a within-`[x,t]` realizer of a bit-false σ
     back-propagates through the fold (`nf_eval_nfk_iff_efold`, off-fiber falsity from
     admissibility) to contradict the igPtW fold agreement. Depth-0 template:
     `kvE_futSliceUnique_zero`-style uniqueness/readback.

**Assessment**: structured, paper-faithful, non-trivial. The engine and drivers exist; what is
new is the fold-bit → chain-firing bridge (igFoldBit content into `kvE_*Pos`/F-chain shape) and
the per-level IH plumbing. This is the task's namesake "realization recursion".

### G2 — general-m slice supply (rows 8–11)

Extend the four m=0 supply theorems to general m. The proof SHAPES generalize verbatim (the
`hexclSlice*` proofs consume only carried `hreal` + slice uniqueness + admissibility zone
readback; the `hslice*` proofs consume the destructor + slice identification). The two
m-sensitive kernels to generalize:
- `kvE_{fut,past}SliceId_of_end_zero` (ExteriorPinnedConverseK.lean:891 / PastK:530) — endpoint
  slice identification: at m ≥ 1 the walked-point/endpoint types must be rendered through
  `charF`/providers (level descent again — same IH consumption as G1's driver inputs).
- `kvE_{fut,past}SliceUnique_zero` — uniqueness at general m.

Report 03's adversarial pass flagged the m ≥ 1 identification ambiguity (C3) and the m=0
positive route (C8) as mandatory machine probes; C8 has since been VALIDATED by 360's green
m=0 landings. C3 remains the honest risk of G2 — probe first (§6, Phase B0).

### G3 — the hook/fold assembly (the un-owned 309 P18/19 frontier; report 03 Q3 routed it HERE)

Three sub-pieces, all single-file-ish at the KampPrior/Base seams:

(a) **The ∀qnf fold into `h_quant`** (Base:1270–1273 and the future mirror): construct
   `quantEnd : TemporalPred` and `seg : BracketFormula 0` from the per-qnf rung biconditionals.
   Positives from the rung `.mpr`, negatives from `.mp` contrapositive; the ∀qnf agreement is a
   finite conjunction over the `NormalForm sig k 3` fintype.
   **Open design question Q-fold**: the rung delivers TWO-anchor content
   (`carrier.holds M atomMap x t`), while the hook slots are (point at x) ∧ (segment on (x,t)).
   Whether the `VVecEA2` carrier content decomposes into that shape is the load-bearing design
   decision. Candidate landed assets: the sorry-free VecEA2 temporal translation
   (VecEADecomp:877–895), `bracketBuildLeft/Right_correct` (VecEATranslation), NavigatedEndChar.
   If the decomposition fails as stated, the repair is to RESTATE the hook (Base.lean edit —
   `h_quant` is a caller-supplied hypothesis, so reshaping it is a local interface change with
   one consumer), NOT to force the fold — probe first.

(b) **The A_diag hooks** (Base:765–773): per-qnf pointwise characterizations at the degenerate
   `x = t` env — `diagChar` is an all-diagonal instance (servable by `charF`/fold);
   `pastEnd`/`futureEnd` are pinned endpoint characterizations, the diag case's own smaller
   version of (a).

(c) **The arm rewrite** (the edit that retires `:361`): in the `| 1 =>` body, case-split the
   ambient `k` (`0` / `1` / `k'+2` — rung0/rung1 unconditional, rungK for ≥ 2), instantiate
   providers via `kampPrior_existProviders_of_ih … (fun n sub =>
   nf_nvar_exist_all_depths atomMap h_surj j n sub)` at `j = k'+1, k'` (structurally decreasing
   recursive calls — the documented Phase-16 arm-rewrite move, KampPrior:955–958), discharge
   rows 1–11 per G1/G2, fold per (a)/(b), and close with
   `kampPrior_case1_trichotomy_assemble` (:1146). Note the formula A must be M-independent:
   choose it as the fold over the FINITE qnf population with per-qnf formulas from the carriers
   (all constructions above are already formula-level; correctness is where M enters).

### G4 — the `:364` `| n+2 =>` arm

Two candidate routes (adjudicate at plan time):
(i) iterated one-variable reduction — peel `∃ env : Fin (n+2)` one variable at a time through
   the `| 1 =>` machinery (`Fin.cons x (insertEnv env t) = insertEnv (Fin.cons x env) t`,
   KampPrior:235); requires an arity-general restatement of the trichotomy/nf_char2 layer,
   which is currently arity-2-specific;
(ii) the docstring bootstrap route (KampPrior:323–331): disjunction over good depth-(k+1+n)
   arity-1 NFs built iteratively from `char_k1` upward via `doets_lemma_1_1`-style reduction.
The realizer engine and drivers are already arity-generic (`BracketFormula (n+1)`,
Phase-2 design note KampPrior:1183–1185). Serialize strictly after `:361`.

---

## 4. Population/arm analysis (sizing sanity)

At the `| 1 =>` arm with ambient depth parameter k:
- arm k=0: per-qnf depth 0 — rung0, UNCONDITIONAL. Only G3 applies.
- arm k=1: per-qnf depth 1 — rung1, `h0` only (supplied by construction). Only G3 applies.
- arm k≥2: rungK with the 11 obligations — G1 + G2 + G3 all apply; rungK indexing: at arm k,
  `qnf : NormalForm sig k 3` with rungK's internal index `k_rung := k - 2`, σ population depth
  k-1 arity 4, fibers depth k-2 arity 5, providers `P` at depth k-1, `Pbr` at depth k-2 (both
  structurally available, F-A).

Consequence: G3 alone closes the depth-2 instance end-to-end (arms 0–1) — a natural first
green milestone that de-risks the fold before the G1/G2 mathematics lands (matches the
Phase-15 verdict's "Phase 18 closes via the unconditional rung-1 — cheaper than planned").

---

## 5. Route notes (binding for the plan)

- **R1**: Use `kampPrior_site_rungK_gate_match` (single-depth providers) at the recursion site,
  NOT `endInterval_correct` (its `Pfam : (j : Nat) → ExistProviders …` total family cannot be
  instantiated inside the `| k+1 =>` arm — depths > k are not structurally available; the
  ledger rows 1–2 anticipate exactly this: "provider-family instantiation … NO-EDIT for 349").
- **R2**: The 360 methodology is the template for G2: machine probe (ExteriorPinnedProbeK
  pattern) BEFORE landing; frozen k=2/m=0 layer as the conjunct-by-conjunct reference.
- **R3**: `hexcl` and the `hexclSlice*` general-m proofs share the uniqueness/readback kernel —
  build it once.
- **R4**: Line-citation churn: the `:361`/`:364` citations appear in the Phase-15/16 verdict
  records and multiple handoffs; the arm rewrite (G3c) should land LAST in its phase and update
  the fencing note (:352–360) in the same edit (the Phase-16 note :959–961 pre-authorizes this).
- **R5**: Zero-debt: no phase below requires a sorry to land green; if the Q-fold probe or the
  C3 probe returns NO-GO, the escalation is an interface restatement (Base.lean hook shape /
  slice-kernel shape respectively), spawned as its own task per the 360 precedent — never a
  sorry or vacuous def.

## 6. Recommended phase decomposition (for `/revise` → plan v3)

| Phase | Content | Gate/inputs | Landing shape |
|---|---|---|---|
| A0 (probe) | Q-fold machine probe: render one concrete per-qnf carrier biconditional in (quantEnd, seg) hook shape at k=0 | none | `lean_run_code`/probe file, GO/NO-GO recorded |
| A | G3(a)+(b) at arms 0–1: build quantEnd/seg + diag hooks from rung0/rung1; discharge `h_quant` both arms | A0 GO | new fold lemmas in KampPrior (or a new leaf), green |
| B | G3(c) restricted: rewrite the `| 1 =>` arm for k ∈ {0,1} … **NO** — the arm is a single ∀k body; instead: land the k-case-split skeleton with arms 0–1 closed and k≥2 routed through the (still-hypothesis-carrying) rungK seam as a named lemma, NOT an arm edit | A | additive lemma `kampPrior_case1_arm_of_obligations` (green, obligation-carrying) |
| C0 (probe) | C3 probe: general-m slice identification countermodel attempt at m=1 (report 03's mandated probe) | none (parallel to A) | GO/NO-GO recorded |
| C | G2: general-m slice-id + uniqueness kernels; lift the four supply theorems | C0 GO | `kvE_{fut,past}SliceId_of_end` / `_SliceUnique` general-m + four supply theorems, green |
| D | G1: interior supply — depth-graded `hreal`/`hexcl` supply theorem consuming the IH providers (exterior-zone σ via the drivers, interior-zone via `_realize_bracket`, `hexcl` via the readback kernel) | C (shares kernel) | `kampPrior_hreal_supply` / `kampPrior_hexcl_supply`, green |
| E | G3(c) full: the `| 1 =>` arm rewrite — instantiate providers (Phase-16 move), discharge all 11 rows, assemble, **retire `:361`**; update fencing notes | B+C+D | `:361` gone; `lake build` green; `lean_verify` on `nf_nvar_exist_all_depths` still shows `sorryAx` only from `:364` |
| F | G4: the `| n+2 =>` arm (route adjudication (i) vs (ii) at phase start), **retire `:364`** | E | zero live sorries in KampPrior; full-tree green; axiom audit clean |

Each phase is one dispatch (~100–500 lines); A0/C0 are cheap probe dispatches. A and C/C0 are
parallelizable (disjoint territory: KampPrior/Base fold seams vs ExteriorPinnedConverse*).

## 7. Tactic survey

Not applicable at research granularity: no single open proof goal exists yet (the sorries are
whole-construction arms). At implementation time the relevant discipline is the house style
already enforced in this territory (manual chain steps, no `simp`/`omega`/`aesop` bypass of
literature-mapped case-splits — see `_realize_from`'s docstring :1289–1291). `lean_multi_attempt`
is appropriate for the A0/C0 probes' leaf goals.

## 8. Sorry inventory (unchanged this round; no code edits)

| file | line | statement | strategic | why open | owner |
|---|---|---|---|---|---|
| Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean | 361 | `nf_nvar_exist_all_depths` `\| 1 =>` arm | yes (inherited) | G1+G2+G3 (§3) | task 358 plan v3 Phases A–E |
| Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean | 364 | `\| n+2 =>` arm | yes (inherited) | G4, serialized after `:361` | task 358 plan v3 Phase F |

Off-path documented sorries (EANegation.lean:1090/:1249, NfDepth0Generalized.lean:751) are
superseded/quarantined per their in-source notes and are NOT in task scope.

## 9. Evidence base

- Lean (all under `/home/benjamin/Projects/BimodalLogic/Theories/Bimodal/Metalogic/WeakCanonical/`):
  `Kamp/KampPrior.lean` :190–364, :578–888, :939–1160, :1162–1649;
  `Kamp/NfMultiAnchorBridge/EndIntervalConsumerK.lean` (full);
  `Kamp/NfMultiAnchorBridge/ExteriorPinnedConverseK.lean` :891, :1223–1345 (+ PastK :530/:769/:822);
  `Kamp/NfMultiAnchorBridge/Base.lean` :737–786, :1196–1330;
  `Kamp/NfMultiAnchorBridge/InteriorGateGeneralK.lean` :243/:318/:387/:1014–1145;
  `Kamp/NfMultiAnchorBridge/ExteriorFiberProbeK.lean` :252.
- Literature: `~/Projects/Literature/sources/rabinovich_2014/` chunk_0015 (read verbatim this
  round), chunks 0013–0016/0021–0023 (via report 03's verified table).
- Task artifacts: 360 summary `specs/360_restate_exterior_hbr_pinned_converse/summaries/01_…`;
  357 summary `specs/357_…/summaries/01_…`; this task's reports 01–03 + phase-3 blocker handoff;
  349 Phase-7 ledger (EndIntervalConsumerK.lean:228–253).
