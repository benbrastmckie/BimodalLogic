# Report 39 — Depth-(k+1) NF→Temporal Bridge Design for KampPrior:391 (task 305)

- **Task**: 305 (lean4, hard mode) — faithful Rabinovich path; corrects the design gap in report 38
  that produced the Phase 8 BLOCKER.
- **Session**: sess_1783306400_33dd64
- **Agent**: lean-research-hard-agent
- **Reference-grounding tier**: **Tier 1** (literature-backed — Rabinovich 2014, "A Proof of Kamp's
  Theorem", §3–5). Source:
  `~/Projects/Literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.md`.
- **Focus**: depth-(k+1) NF→VecEA_m bridge design for `KampPrior.lean:391`.

## Executive Summary (verdicts)

1. **Report 38 solved the WRONG target.** Its "surgical unblock" (Lemma 3.4 `existClosureLeft` +
   3-arm VecEA_m disjunction) was designed against `∃ x, nf_eval_nf M **k** 2 (Fin.cons x …) sub_nf`
   — which is the conclusion of the **IH `ih_exist_1`** (KampPrior:305–331), at depth **k**. The
   **actual** `:391` goal (verified by `lean_term_goal`) is at depth **k+1**:
   `∃ env, nf_eval_nf M **(k+1)** (1+1) (insertEnv env t) sub_nf`, `sub_nf : NormalForm sig (k+1) (1+1)`.
   Every `existClosure`/`existClosureLeft`/`disj` combinator is stated over `VecEA_m.holds`, a
   different object; no NF(k+1)↔VecEA_m iff exists. This is the exact H4 failure the team lead
   flagged, now **confirmed and root-caused**.

2. **CHEAPEST CORRECT ROUTE = a DIRECT `nf_eval_nf` construction that mirrors the proven
   `nf_succ_char_formula` (char_k1) pattern — NOT a generic NF→VecEA_m bridge, and NOT the uniform
   Prop 4.3/4.2 negation route.** The winning lever: `nf_succ_char_formula` discharges the depth-(k+1)
   **arity-1** characteristic directly over `nf_eval_nf`, pushing negation to the **formula level**
   (`nf_quant_clause_tl` wraps the IH's temporal formula in `¬`), thereby avoiding the hard uniform
   VecEA negation entirely. `:391` is the **arity-2 existential** analogue of that pattern.

3. **A per-model existential bridge (`∃ vea, nf_eval ↔ vea.holds`) is VACUOUS** — the Phase-4b trap
   (report 38 confirmed `neg_vec_ea_m`'s `∃ v', v'.holds` is closed by `⟨tt, tt_holds⟩`). Any bridge
   must be a **uniform function** `NormalForm sig (k+1) 2 → Formula` with a model-independent iff,
   exactly like `nf_succ_char_formula`.

4. **The genuinely-missing infrastructure is narrow but hard: a depth-k generalization of the
   two-anchor arity-3 zone decomposition** (`∃ y, nf_eval_nf M k 3 (y,x,t) qnf` as a nested
   Since/Until bracket with depth-k IH formulas as point/segment types). Everything at depth 0 exists
   sorry-free (`nf_vecEA2_past/future`, `nf_3var_zone_*`, `bracketBuildRight`, `bracketBuildLeft`), but
   **depth-0 NFs have no quant layer**, so the base case does not de-risk the quant-layer coupling —
   the hard part is untested at depth 0.

5. **`:391` is genuinely load-bearing at ARBITRARY depth** (not just bounded k):
   `nf_characterizable_temporal_prior` (succ k, KampPrior:469) consumes
   `nf_nvar_exist_all_depths_fn … k 1`, and `kamp_prior_expressive_completeness` (KampPrior:520) uses
   it at `k = psi.quantifier_depth`. This is the inductive step of Kamp's theorem, not a wiring task.

6. **SIZING: 5–7 dispatches, ~1250–2050 lines, central piece MEDIUM-LOW confidence. This exceeds the
   ~4-dispatch remaining budget.** **RECOMMENDATION: PAUSE the batch** (details in Phase Decomposition).

## Findings

### Verified `:391` goal (H4 — `lean_term_goal` at KampPrior.lean:391:7)

```
sub_nf : NormalForm sig (k + 1) (1 + 1)
-- in scope: ih_exist_1, exist_tl_fn_k : NormalForm sig k 2 → Formula,
--           exist_tl_fn_k_correct, char_k1 : NormalForm sig (k+1) 1 → Formula, char_k1_correct
⊢ ∃ A, ∀ (M : OrderedMonadicStructure sig),
    semantic_prior_UZ M atomMap → semantic_prior_SZ M atomMap →
      ∀ (t : M.carrier), temporal_truth M atomMap t A ↔
        ∃ env, nf_eval_nf M (k + 1) (1 + 1) (insertEnv env t) sub_nf
```

For `env : Fin 1`, `insertEnv env t = Fin.cons (env 0) (fun _ => t)` (proved inline at KampPrior:482),
so the goal is exactly the **depth-(k+1) arity-2 existential engine**
`∃ x, nf_eval_nf M (k+1) 2 (Fin.cons x (fun _=>t)) sub_nf` — the depth-(k+1) sibling of `exist_tl_fn_k`.

### H3 Lemma-level mapping table (Tier 1 — REQUIRED)

| Source (Rabinovich 2014) | Prop/Location | Lean Identifier | Type Signature (verified) | Status |
|---|---|---|---|---|
| Prop 3.5 — V-∃∀ (1 free var) ≡ TL(U,S); nested Until | md:87–94, Cor 5.4 md:157 | `bracketBuildRight` (+`_correct`) | `bracketBuildRight : BracketFormula n → TemporalPred → Formula` (VecEATranslation.lean:50) | **DONE sorry-free** (VecEATranslation sorry-count = 0) |
| Prop 3.5 — Since mirror | md:92 | `bracketBuildLeft` (+`_correct`) | Since-nesting mirror | **DONE — now EXISTS sorry-free** (VecEATranslation.lean; report 38 wrongly listed as missing) |
| §5 interval split — depth-0 arity-2 ∃ (base case) | §5 | `nf_2var_exist_depth0_tl` (+`_fn`,`_correct`) | `NormalForm sig 0 2 → …` order-direction case split | **DONE sorry-free** (NfToVecEA.lean:503) |
| §5 past/future bracket at depth 0 | §5 Cor 5.4 | `nf_vecEA2_past/future` (+`_correct`) | over `NormalForm sig **0** 2` → `VecEA2` | **DONE sorry-free** (NfToVecEA.lean:217,259) — **DEPTH-0 ONLY** |
| §5 three-zone split at depth 0 | §5 | `nf_3var_zone_{ytx,txy,yxt,xty}` (+`_correct`) | over `VecEA2` (depth-0 brackets) | **DONE sorry-free** (VecEADecomp.lean:518–731) — **DEPTH-0 ONLY** |
| Doets Def 1.6.1 n-characteristic / k-type | — | `NormalForm`, `nf_eval_nf` | `NormalForm (k+1) n = (AtomKind n → Bool) × (NormalForm k (n+1) → Bool)`; eval decomposes atoms ∧ per-subNF existential (NormalForm.lean:134–207) | **DONE** |
| depth-(k+1) arity-1 characteristic (the WORKING pattern) | analogue of Prop 3.5 | `nf_succ_char_formula` (+`_correct`) | `(NormalForm sig k 2 → Formula) → NormalForm sig (k+1) 1 → Formula` | **DONE sorry-free** (KampPrior.lean:107–177) — **formula-level ¬ via `nf_quant_clause_tl`** |
| diagonal (x=t) arity collapse at depth k+1 | — | `mergeNF_succ`, `mergeNF_succ_atom` | `NormalForm sig (k+1) (n+2) → Fin (n+2) → Fin (n+1) → NormalForm sig (k+1) (n+1)` = `renameNF (skipFin j) (totalUnskip j i')` | **def+atom layer DONE**; **quant layer OPEN** (NfDepth0Generalized.lean:593,599) |
| depth-**k+1** arity-2 ∃ engine (the `:391` GOAL) | §5 inductive step | *(none)* | see design below | **MISSING** — this report's subject |

**Verified: NO proven depth>0 arity-2 existential converter exists anywhere.** Every NF→temporal /
NF→VecEA converter in the tree is depth-0 (all take `NormalForm sig 0 _` or operate on the depth-0
`VecEA2` bracket type). Corroborated by full codebase sweep (Explore): the only decl whose *type*
covers arity-2 depth>0 is `nf_nvar_exist_all_depths` itself, whose `k+1, n=1` case IS the `:391`
sorry. All other depth>0 arity-2 statements live in `Boneyard/` (`FOToVEA.lean:146`, `NfExistTL`,
`Prop43`, `KampBypassArchive`) and carry sorries.

**Dead-end reference route (do NOT chase):** the KampBypass k=0 infrastructure the handoff flagged as
possible reference is **archived and unusable**. `KampBypass*` live only in
`Boneyard/KampBypassArchive`; their leaf proofs are individually 0-sorry but depend on
`prior_2var_transfer_until/since` in `PriorComposition.lean`, which are **explicit sorry stubs
documented as provably FALSE at K=0** (ℤ `is_even` counterexample). There is no salvageable sorry-free
k=0/k+1 arity-2 asset to lift. (Also: no `"task 303"` string exists in the repo.)

### Literature Proof Structure (Rabinovich §3–5, verified against md:59–173)

- **Prop 4.3** (md:103–110): every FO ≡ disjunction of ∃∀, by structural induction; hard case
  (`not`/`all`) via **Prop 4.2 = interval splitting** (§5). Minimal basis `{atomic,∨,¬,∃}`.
- **Prop 3.5 / Cor 5.4** (md:87–94,157): a 1-free-var ∃∀ maps to a **nested Until/Since chain**
  `F_n := α_n`, `F_{i-1} := α_{i-1} ∧ (β_i Until F_i)` — the interval decomposition IS the temporal
  formula. `bracketBuildRight/Left` are the Lean realizations (both now sorry-free).
- **§5 (md:119–173)**: the negation/universal side needs `INF` + Dedekind completeness. **Our route
  AVOIDS this** by keeping negation at the temporal-formula level (see below), because the input is a
  Doets NF (already a canonical exact-realization spec), not an arbitrary FO formula.

### Q1 — CHEAPEST CORRECT ROUTE: direct `nf_eval_nf` construction (IH-composition), no generic bridge

The proven `nf_succ_char_formula` (char_k1) is the template. It handles depth-(k+1) **arity-1** by
decomposing `nf_eval_nf M (k+1) 1 (fun _=>t) nf` (NormalForm.lean:203–207) into:
- **atom layer** — a depth-0 arity-1 predicate conjunction (`nf_depth0_char_formula`); and
- **quant layer** — for each `sub_nf' : NormalForm sig k 2`, the clause
  `(∃x, nf_eval_nf M k 2 (Fin.cons x (fun _=>t)) sub_nf') ↔ nf.2 sub_nf'`, realized by
  `nf_quant_clause_tl (exist_tl_fn_k sub_nf') (nf.2 sub_nf')` — the **positive** existential comes from
  the depth-k IH (`exist_tl_fn_k`), and the **"not-realized"** (`= false`) clauses are just its
  temporal **negation** `¬(exist_tl_fn_k …)` — model-independent, trivial. **No VecEA negation, no
  uniform Prop 4.2.** This is the key architectural insight report 38 missed.

`:391` is the **arity-2 existential** sibling. For `sub_nf : NormalForm sig (k+1) 2 = ⟨A, Q⟩`:
```
∃ x, nf_eval_nf M (k+1) 2 (Fin.cons x (fun _=>t)) sub_nf
  = ∃ x,  (∀ a : AtomKind sig 2, atom_eval M (x,t) a ↔ A a)               -- atom layer (incl. order x<t / t<x)
        ∧ (∀ qnf : NormalForm sig k 3,
             (∃ y, nf_eval_nf M k 3 (Fin.cons y (x,t)) qnf) ↔ Q qnf)      -- quant layer (TWO-anchor: x AND t)
```

Two differences from arity-1 (char_k1):
- **(D1) Witness-position is FIXED by data, not a runtime disjunction.** The order atoms
  `A (order 0 1)` (=`x<t`) and `A (order 1 0)` (=`t<x`) are **decidable Bool values of the given
  `sub_nf.1`**. So the construction is a **compile-time 3-way case split on `sub_nf.1`**, not report
  38's runtime `VVecEA_m.disj`:
  - `A(0<1)=false, A(1<0)=false` → **x=t arm** (diagonal);
  - `A(0<1)=true` → **x<t arm** (past / Since);
  - `A(1<0)=true` → **t<x arm** (future / Until);
  - both true → unsatisfiable atom layer → `A := ⊥` (`Formula` false).
  This is strictly simpler and more faithful than report 38's design.
- **(D2) The quant layer is TWO-anchor** (`x` and `t`), the genuine new content — see Q4.

**Route decision: build a uniform `NormalForm sig (k+1) 2 → Formula` directly over `nf_eval_nf`,
mirroring `nf_succ_char_formula`, with formula-level negation and the decidable order-atom case split.
Do NOT route through `VecEA_m.holds`.**

### Q2 — If a bridge is nonetheless wanted: exact spec

- **Shape**: a **uniform total function** `bridge : NormalForm sig (k+1) 2 → Formula` (NOT
  `∃ vea : VecEA_m 2, …` — that is the vacuity trap, report 38 confirmed).
- **Direction**: **iff** (both), model-independent:
  `∀ M [UZ][SZ] t, temporal_truth M atomMap t (bridge sub_nf) ↔ ∃ x, nf_eval_nf M (k+1) 2 (Fin.cons x (fun _=>t)) sub_nf`.
- **Arity**: `:391` needs **only arity 2 (n=1)**. But the two-anchor quant layer internally requires a
  depth-k **arity-3** zone converter (see Q4); it does NOT require the general-arity `existClosureAll`
  (that is `:394`/n≥2 territory).
- **Statement granularity**: per-`sub_nf` (a function), exactly like `nf_succ_char_formula` — never a
  per-model existential.

### Q3 — x=t arm: is the mergeNF_succ quant-layer collapse needed?

**Yes, it IS needed** — `char_k1` cannot handle the x=t case directly, because `char_k1` takes an
**arity-1** NF, whereas the x=t arm is an arity-2 NF on the diagonal env `(t,t)`. The reduction
`nf_eval_nf M (k+1) 2 (fun _=>t) sub_nf ↔ nf_eval_nf M (k+1) 1 (fun _=>t) (mergeNF_succ sub_nf 0 0)`
followed by `char_k1` is required, and `mergeNF_succ`'s **quant-layer** correctness is the missing piece.

**But it is NOT unfixable** (contra the pessimistic handoff framing). The `renameNF_eval_iff`
(NfDepth0Generalized:440) **bijection** requirement is the WRONG tool for the non-injective merge, but
the comment at NfDepth0Generalized.lean:580–582 already sketches the correct approach: the
**duplicating (diagonal) environment `full_val` satisfies the env-compatibility `E = e ∘ r` on all
positions** precisely because it lives in the duplicated subspace — so a **diagonal-specialized eval
lemma** (`mergeNF_succ_quant`, not the general bijection lemma) closes it. `mergeNF_succ` (def) and
`mergeNF_succ_atom` (atom layer) are preserved reusable assets; only `mergeNF_succ_quant` is missing.
Difficulty: **MEDIUM**.

### Q4 — The crux: the two-anchor quant-layer converter (past/future arms)

For the x<t (past) arm, after the order atom is fixed, each quant clause is
`∃ y, nf_eval_nf M k 3 (Fin.cons y (Fin.cons x (fun _=>t))) qnf` — a **depth-k arity-3 existential
anchored at TWO points x<t**. The depth-k IH (`nf_nvar_exist_all_depths … k m`) only provides
**single-anchor (t)** existentials, so it does **not** apply directly. Bridging two-anchor → temporal
requires expressing the y-existential as a **nested Since/Until bracket between x and t**, splitting y
by zone (`y<x`, `y=x`, `x<y<t`, `y=t`, `y>t`) — the depth-k generalization of `nf_3var_zone_*`
(which exist **only at depth 0**), with **depth-k IH formulas as the bracket point/segment types**
(fed through `bracketBuildLeft`/`bracketBuildRight`, which accept arbitrary `TemporalPred`). This is
Rabinovich's Cor 5.4 `F_i`-chain, lifted from depth-0 atom types to depth-k characteristic types.

**This is the genuine inductive step of Kamp's theorem and the single hard piece. It is untested at
depth 0 (depth-0 NFs have no quant layer), so the sorry-free depth-0 base case does not de-risk it.**

## Q4 — Phase Decomposition (H8: one dispatch per phase) + confidences

Replace the mis-scoped Phase 8 (3-arm VecEA_m wiring) with the following, all **direct over
`nf_eval_nf`**:

| Phase | Content | Territory (append-only) | Confidence | Lines |
|---|---|---|---|---|
| **8a** | `mergeNF_succ_quant`: diagonal-specialized eval iff for the quant layer (x=t arm), then `x=t` arm = `char_k1 ∘ mergeNF_succ`. Self-contained; also unblocks `:394`/751 territory. | NfDepth0Generalized.lean | **MEDIUM** | 250–400 |
| **8b** | Depth-k **two-anchor arity-3 zone converter**: generalize `nf_3var_zone_*` from depth-0 to depth-k, point/segment types = depth-k IH formulas. **THE CRUX.** | new file `NfZoneDepthK.lean` | **MEDIUM-LOW** | 400–700 |
| **8c** | **x<t (past)** arm: assemble 8b zones + `bracketBuildLeft` + formula-level ¬ into a `NormalForm sig (k+1) 2 → Formula` for the past case; iff proof. | new file / KampPrior region | **MEDIUM** | 300–450 |
| **8d** | **t<x (future)** arm: mirror of 8c via `bracketBuildRight`. | same | **MEDIUM** (mirror) | 250–400 |
| **8e** | Assembly: decidable order-atom case split (8a/8c/8d + ⊥ arm), rewire `:391`, `lake build` GREEN, live-path sorry 2→1. | KampPrior.lean:387–391 | **MEDIUM-HIGH** (contingent) | 200–350 |

**Total: 5 phases (8b likely splits into 2 dispatches) ⇒ 5–7 dispatches, ~1400–2300 lines.**

## PROCEED / PAUSE recommendation: **PAUSE the batch**

**Honest assessment**: `:391` is the inductive step of Kamp's theorem (two-anchor interval splitting at
general depth), not the "wiring" task report 38 mis-scoped. The crux (8b) is **MEDIUM-LOW** and alone
is ≥2 dispatches; the full discharge is **5–7 dispatches**, **exceeding the ~4-dispatch remaining
budget**. Proceeding autonomously risks another partial/blocked state and burns budget that tasks
303/95/299 are gated on.

**Recommended path forward**:
1. **Revise plan 38** to the corrected decomposition above (direct `nf_eval_nf`, formula-level ¬,
   decidable order-atom case split) — discard the VecEA_m `existClosure`/`disj` wiring for `:391`.
2. **Either** commit a dedicated ~6-dispatch budget to phases 8a–8e as a focused effort (this IS the
   hard half of Kamp for the depth induction), **or** spawn **Phase 8a** (`mergeNF_succ_quant`) as a
   self-contained first task: it is MEDIUM confidence, ~1–2 dispatches, broadly reusable (x=t arm +
   `:394`/751 merge territory), and produces the first verified brick while the batch is re-scoped.
   Note: 8a alone does NOT reduce the `:391` sorry (the function must handle all three arms), so expect
   no live-path count change until 8e.

## Adversarial Self-Verification

Every load-bearing claim re-derived against the verified `:391` goal (`lean_term_goal`) and primary
sources. Verification method per H4-lean4: `lean_term_goal`/`lean_hover_info`-confirmed, source read at
file:line, or codebase sweep.

| Claim | Source/Counterexample | Verdict |
|---|---|---|
| `:391` goal is depth-**(k+1)** arity-2 `∃ env, nf_eval_nf M (k+1) (1+1) (insertEnv env t) sub_nf` | `lean_term_goal` KampPrior.lean:391:7 (verbatim above) | **CONFIRMED** |
| Report 38 targeted depth-**k** (`∃ x, nf_eval_nf M k 2 …`), i.e. `ih_exist_1`'s conclusion, not the goal | report 38 line 219 vs `ih_exist_1` KampPrior:305–331 vs goal | **CONFIRMED — root-caused H4 failure** |
| `existClosure`/`existClosureLeft`/`disj` are over `VecEA_m.holds`, not `nf_eval_nf`; no NF(k+1)↔VecEA_m iff | VecEA_m.lean (holds-typed combinators); no converter takes `NormalForm sig (k>0) _` | **CONFIRMED** |
| `nf_succ_char_formula` discharges depth-(k+1) arity-1 directly over `nf_eval_nf`, negation at formula level | KampPrior.lean:107–177 (`nf_quant_clause_tl`, `¬`); sorry-free | **CONFIRMED** |
| A per-model bridge `∃ vea, nf_eval ↔ vea.holds` is vacuous | report 38 (`neg_vec_ea_m` closed by `⟨tt,tt_holds⟩`); design must be a uniform function | **CONFIRMED** |
| `:391` load-bearing at arbitrary k (completeness path) | `nf_characterizable_temporal_prior` succ uses `…_fn k 1` (KampPrior:469); `kamp_prior_expressive_completeness` at `k=psi.quantifier_depth` (:520,535) | **CONFIRMED** |
| All NF→temporal/VecEA converters are depth-0; none at depth>0 | `nf_vecEA2_past/future` over `NormalForm sig 0 2`; `nf_3var_zone_*` over `VecEA2`; `nf_2var_exist_depth0_tl` over `NF 0 2` | **CONFIRMED** |
| Depth-0 base case is sorry-free but has NO quant layer, so does not de-risk 8b | `NormalForm sig 0 n = AtomKind n → Bool` (NormalForm.lean:135) — no quant component | **CONFIRMED** |
| x=t arm needs `mergeNF_succ` quant collapse; char_k1 cannot take arity-2 | `char_k1 : NormalForm sig (k+1) 1 → Formula`; x=t env is `(t,t)` arity-2 | **CONFIRMED** |
| `mergeNF_succ` quant collapse is provable (diagonal-specialized), NOT unfixable | NfDepth0Generalized.lean:580–582 (duplicating env satisfies `E=e∘r`; bijection not required) | **CONFIRMED — corrects pessimistic handoff framing** |
| Witness-position (past/present/future) is decidable on `sub_nf.1` order atoms, not a runtime disjunction | `sub_nf.1 : AtomKind sig 2 → Bool`; `AtomKind.order 0 1`, `order 1 0` decidable | **CONFIRMED — improves on report 38's runtime `disj`** |
| `bracketBuildLeft` exists sorry-free (report 38 said missing) | VecEATranslation.lean sorry-count 0; decl present in VecEATranslation/NfToVecEA/VecEA_m | **CONFIRMED — report 38 stale on this point** |
| The two-anchor quant layer (Q4) cannot be closed by the single-anchor depth-k IH directly | IH gives `∃ env:Fin m, nf_eval_nf M k (m+1) (insertEnv env t) …` (anchor t only); quant clause anchors x AND t | **CONFIRMED — irreducible crux** |
| Doets/`char_{k+2}` disjunction route is circular; uniform Prop 4.2 route is the hard half of Kamp | report 18 (circularity); report 38 (uniform negation LOW/large) | **CONFIRMED — both rejected, not re-litigated** |
| No usable k=0/k+1 arity-2 asset to lift; KampBypass is a dead end | Explore sweep: KampBypass* archived in Boneyard, depend on `prior_2var_transfer_until/since` (PriorComposition.lean) — sorry stubs provably false at K=0 (ℤ is_even ctrex) | **CONFIRMED — rules out the handoff's reference route** |
| Item 7 (no depth>0 arity-2 converter) corroborated by independent full sweep | Explore agent: only `nf_nvar_exist_all_depths` covers the type; `:391`/`:394` are the sorries | **CONFIRMED** |
| Sizing 5–7 dispatches exceeds ~4 budget ⇒ PAUSE | phase table; MAX_CYCLES budget per team-lead | **CONFIRMED** |

**No unresolved contradictions.** Two prior-report claims corrected: (a) report 38's `:391` target
depth (k → k+1, the root cause); (b) report 38's "`bracketBuildLeft` missing" (now exists).

## References

- Rabinovich (2014), *A Proof of Kamp's Theorem*, §3–5 —
  `~/Projects/Literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.md`.
- Prior task-305: report 38 (mis-scoped design, root-caused here), report 18 (circularity), plan 38
  (Phase 8 BLOCKER), handoff `.orchestrator-handoff.json`.
- Primary Lean: `KampPrior.lean` (:107–177 char_k1, :252–394 nf_nvar_exist_all_depths, :437–545
  completeness chain), `NormalForm.lean` (:134–207), `NfDepth0Generalized.lean` (:580–751),
  `NfToVecEA.lean` (:217–503), `VecEADecomp.lean` (:518–731), `VecEATranslation.lean` (:50 bracketBuild).
