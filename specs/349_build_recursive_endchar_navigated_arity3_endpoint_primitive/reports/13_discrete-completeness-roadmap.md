# Discrete Completeness — Finishing Roadmap

**Agent**: lean-research-agent | **Date**: 2026-07-12 | **Type**: lean4 research/synthesis
**Scope**: sequenced plan of everything remaining to finish DISCRETE COMPLETENESS sorry-free,
plus refactoring, cleanup, polish. No Lean files edited (research-only).

**Verdict up front**: The discrete-completeness proof is **one live proof-term sorry away from
green**. `completeness_discrete` compiles today but carries `sorryAx`, traced to a single
construction: `nf_nvar_exist_all_depths` (KampPrior.lean:361 n=1 arm; :364 n+2 arm). Every other
real sorry in the tree (163 of 164) is either dead/bypassed, in the Boneyard, or in an
unrelated subsystem. The remaining mathematics is concentrated in the Rabinovich Cor 5.4
within-bracket witness-selection realizer (tasks 358 / 305 / 307 / 309); the rest of the open
graph is bounded threading and assembly.

---

## 1. COMPLETENESS SPINE

**Terminus theorems** (both in `Metalogic/BXCanonical/Completeness.lean`):
- `completeness_discrete` (:276) — valid_discrete φ → Nonempty (DerivationTree Discrete [] φ)
- `completeness` / `completeness'` (:135/:177), `completeness_dense` (:234) — sibling termini.
- Tracking table: `Metalogic/Metalogic.lean:32` marks discrete completeness `SORRY`.

**Authoritative axiom check** (`#print axioms completeness_discrete`, confirmed via `lean_verify`):
```
[propext, sorryAx, Classical.choice, Lean.ofReduceBool, Lean.trustCompiler, Quot.sound]
```
`sorryAx` present ⇒ **NOT sorry-free**. (`ofReduceBool`/`trustCompiler` are from `native_decide`
in the Syntax layer — acceptable, not sorry.)

**The live dependency spine (terminus → lowest real dependency):**
1. `completeness_discrete` — Completeness.lean:276 (discrete arm :334–338)
2. → `countermodel_discrete_reynolds_v2` — IntegerModel/ReynoldsBridge.lean:724 *(sorry-free)*
3. → `limitdom_is_good` → `no_gaps_discrete_model_surgery` — IntegerModel/GoodStructuresModelSurgery.lean *(sorry-free; its old surgery sorries were reduced away)*
4. → `US_expressively_complete_over_prior` — WeakCanonical/PriorExpressiveness.lean:346 *(sorry-free)*
5. → `kamp_prior_expressive_completeness` — Kamp/KampPrior.lean:490
6. → `nf_characterizable_temporal_prior` — Kamp/KampPrior.lean:407
7. → **`nf_nvar_exist_all_depths` — Kamp/KampPrior.lean:212** ← lowest real dependency, the SOLE
   live proof-term sorry on the path:
   - **:361** — the `| 1 =>` (n=1) arm. **On the critical path** (invoked with n=1 at :273).
   - **:364** — the `| n+2 =>` arm. Off the critical path, but taints the definition's axiom
     footprint (same recursive constant), so it must also be retired for a clean `#print axioms`.

**Wiring facts** (settle the "parallel vs. spine" question):
- The Kamp/Prior expressive-completeness route **IS the live spine**, reached through the Reynolds
  "no-gaps" pipeline (`GoodStructuresModelSurgery` imports `PriorExpressiveness`, which imports
  `KampPrior`). Not a parallel effort.
- `NfMultiAnchorBridge/` is imported by `KampPrior.lean:4` and is the **active frontier machinery
  built to discharge the :361 sorry** (tasks 309/348/355/356/357). It follows a strict
  "decision-gate lands no partial theorem or sorry" discipline, so the debt sits in KampPrior.lean,
  not in the bridge — the bridge leaves are themselves sorry-free.
- `US_expressively_complete_over_Z` (ExpressiveCompleteness/Theorem.lean:357, "Thm 10.2.10") is a
  **separate/parallel** statement — nothing outside its docstring references it; NOT on the
  terminus path. Do not confuse it with the `_over_prior` variant that is on-spine.
- The old terminus `existPart_succ_n1_bypass` / `KampBypass.lean` is **stale/Boneyard'd** — several
  task descriptions (notably task 303) still cite it and must be re-pointed.

**What still blocks the terminus**: exactly one thing — retire `nf_nvar_exist_all_depths` :361
(critical) and :364 (footprint), i.e. produce the genuine Rabinovich within-bracket realizer.

---

## 2. LIVE SORRY INVENTORY

Total **real** (live-tactic, block-comments stripped) sorries under `Theories/Bimodal/`: **164**.
Raw `grep sorry` massively overcounts (e.g. Base.lean raw 23 → real 0; CarrierK1V raw 16 → real 0)
because the architecture is documented in docstrings that mention "sorry". Confirmed real counts:

### LIVE spine (the only sorry that blocks completeness)
| File:line | Asserts | Owner |
|-----------|---------|-------|
| **KampPrior.lean:361** | n=1 arm of `nf_nvar_exist_all_depths`: `∃ env : Fin 1, nf_eval_nf M (k+1) 2 (insertEnv env t) sub_nf` — the genuine interior/exterior realizer (Rabinovich Cor 5.4 inf/sup bounded witness selection) | **task 358** (= task 309 Phase-14 successor) |
| **KampPrior.lean:364** | n+2 arm (n≥2), off critical path but taints the def footprint | **task 358** |

### Bucket A — spine files, all DEAD/BYPASSED (do not block terminus)
Core spine files are **sorry-clean**: `Completeness.lean`, all `IntegerModel/*`,
`Metalogic.lean` = 0 real sorries.
- `TruthLemma.lean:431,448,483,497,540,556` (6) — Until/Since MCS forward/backward arms. Each
  labeled "NOT needed for completeness / parametric truth lemma handles Until/Since via BFMCS
  coherence." The Reynolds route uses the parametric truth lemma; these `ReflCanDomain` lemmas are
  bypassed.
- `Transfer.lean:1270` (1) — the DEPRECATED `countermodel_discrete` direct sorry (dead BX pipeline
  `succ_cofinal` path, task 255). Superseded by `countermodel_discrete_reynolds_v2`.

### Bucket B — Kamp frontier, non-blocking
- `EANegation.lean:1090,1249` (2) — BracketFormula-level neg-bracket biconditional arms;
  "UNPROVABLE at BracketFormula level… does NOT block completeness" (the model-dependent
  `neg_interval_formula`/`neg_partialBracketExist_sufficient` in EANegationClosure.lean are
  sorry-free and sufficient).
- All other listed frontier files — Base, CarrierK1V, CarrierKv, SharedWitness (the one raw hit is
  in a docstring), NfZoneDepthK, NfZoneFlattenNavigable, NfToVecEA, VecEADecomp, Prop43 — **0 real**.
  (Note: an earlier tool pass flagged SharedWitness "1"; on reconciliation it is a docstring token.
  The k=2 layer OuterGate/ExteriorBracket/SubBracket2/SubBracket2V is fully **0 real** — k=2 is done.)

### Bucket C — DEAD / PARKED / UNRELATED (153 total)
- **Boneyard/** (all subdirs): **121** real sorries — legacy KampBypassArchive, RabinovichPath,
  StrictSemanticsLegacy, QuasimodelOracle, UltrafilterFrame, etc. Fully parked.
- Non-Boneyard parked (32): `BXCanonical/Chronicle/ChronicleToCountermodel.lean` (3, explicitly dead
  `chronicle_gap_contradiction→succ_cofinal`), `Expressiveness/CaseAnalysis.lean` (7, provably
  bypassed by Transfer's Reynolds route), `EFGames/StaviCompleteness.lean` (3, abandoned Stavi/EF
  route), `Bundle/SuccRelation.lean` (7), `Bundle/SuccExistence.lean` (3),
  `Bundle/UntilSinceCoherence.lean` (2), `Algebraic/{InteriorOperators,LindenbaumQuotient}.lean`
  (1+2), `BXCanonical/Frame.lean` (1, `bx_le_refl` intentionally abandoned), `OrderedSum.lean` (1),
  Kamp/Boneyard EndpointNegation/FOToVEA (1+1).

**Flag for maintainer**: `Bundle/SuccRelation.lean` (7) + `Bundle/SuccExistence.lean` (3) are the
only non-Boneyard parked files whose subsystem (Bundle seed-consistency) is imported by the live
TruthLemma. The specific sorried lemmas appear off-spine, but they sit closest to the live path —
worth an explicit confirmation during the task-95 verification audit.

---

## 3. SEQUENCED CRITICAL PATH

Dependency-satisfaction re-check (deps 308/310/311/320/333/335/337/340/346/348 and 351–357 are all
**completed/archived**). This collapses the open graph considerably:

**Reduced open dependencies:**
- 358 deps=[357✓] → **READY NOW**
- 349 deps=[351–357 all ✓] → **dep-unblocked** (needs plan revision v8 — see below)
- 350 deps=[349]
- 309 deps=[310✓,311✓,320✓,333✓,335✓,346✓,348✓, **349, 350**] → real blockers only 349, 350
- 307 deps=[308✓, **309**] → real blocker only 309
- 305 deps=[307]
- 303 deps=[305]  *(plan is STALE — targets Boneyard'd KampBypass)*
- 299 deps=[303]; 95 deps=[303]
- 341 deps=[335✓,337✓,340✓,346✓] → **ALL SATISFIED — refactor can start now**

**Topological order to green (proof tasks):**

```
        ┌─ 358  (retire KampPrior:361/364 realizer) ──────────────┐
349 ──▶ 350 ──▶ 309 ──▶ 307 ──▶ 305 ──▶ 303 ──▶ {299, 95} ──▶ DONE
  (endChar prim) (aggregate)  (offdiag)  (cor54)  (EA-formula) (k>0 induction)
```

Two things need clarification, because the graph encodes **two routes to the same sorry**:
- **Direct route**: task **358** retires `nf_nvar_exist_all_depths` :361/:364 directly via the
  Rabinovich Cor 5.4 within-bracket inf/sup realizer, consuming the task-357 obligation-carrying
  reshape (`EndIntervalCorrectPrior`) and the task-356 exterior discharge. This is the shortest
  path to a clean `#print axioms`.
- **Supply route**: 349→350 build the recursive `endChar` navigated arity-3 primitive + aggregate
  quant/seg construction and discharge the arm-correctness hooks; 309/307/305 build the faithful
  Rabinovich EA-formula machinery (off the live import path) that the realizer consumes; 303 is the
  k>0 depth induction that ultimately re-points KampPrior's arms.

**Hard vs. threading:**
- **Genuinely hard (open mathematics)**: task **358** (bounded within-bracket witness selection —
  Rabinovich 2014 Cor 5.4 inf/sup); task **309** (off-diagonal two-anchor F_i chain, the non-trivial
  navigated characteristic); task **305** (faithful EA-formula formalization, ~2200 lines, negation
  closure by induction on witness count — the single largest chunk of real content).
- **Mostly threading/assembly**: task **349** Phase 2 (D1–D4 bracket wrapper, ~150–200 additive
  lines mirroring the sorry-free k=2 template — see report 11); task **350** (aggregate zone-routing
  construction in landed house style); task **307** (uniform-A adjudication + zone converter, much
  already scoped in reports); task **303** (k>0 induction, ~200–400 lines given the sorry-free k=0
  template — but its plan must first be re-pointed off the stale KampBypass reference); tasks
  **299/95** (refactor + verification audit, pure once green).

**Stale/satisfied deps to act on now:**
- **349**: all deps satisfied → transition out of [blocked]; run `/revise 349` → v8 (report 11
  §4 gives the six concrete edits: re-point Phase 2 at the delivered 351/352/354 clause layer,
  carry `hreal`/`hsat` discharged one level up by `kvE_futBundle_of_realizer`).
- **358**: deps satisfied → transition [not_started]→research/plan now; it is the direct blocker
  retirement and gates the entire terminus.
- **341**: all deps satisfied → the SharedWitness/carrier refactor can begin in parallel (does not
  block the spine; reduces risk for 305/307/309 which live in that layer).
- **303**: description names `existPart_succ_n1_bypass` / `KampBypass.lean` (Boneyard) and "SOLE
  remaining sorry" — both stale. Re-scope to the NfMultiAnchorBridge/KampPrior architecture before
  planning.

---

## 4. REFACTORING & CLEANUP DEBT

- **k=2 vs general-k duplication.** The k=2 bracket/gate layer (`OuterGate.lean`,
  `ExteriorBracket.lean`, `SubBracket2.lean`, `SubBracket2V.lean`, `ExteriorNegation*.lean`) is
  sorry-free and now shadowed by the general-k `*K.lean` / `*AssembleK.lean` leaves
  (`ExteriorBracketAssembleK`, `ExteriorGateAssembleK`, `ExteriorConverterK/PastK`,
  `InteriorGateGeneralK`, `ExteriorNegationK/PastK`). Once general-k lands and the terminus is green,
  the k=2 layer should either be deleted or explicitly retained as the `k=1` base case with a
  one-line pointer. Do NOT delete before green (the k=2 lemmas are live templates and some are still
  consumed as base cases).
- **Dead `endIntervalStep` placeholder.** `CarrierK1V.lean:2144` `endIntervalStep` returns the empty
  `⟨[]⟩` VVecEA2 (an honest gate-failure object, not a sorry) — superseded by task 357's relocation
  of the real step to `EndIntervalConsumerK.lean` (`endInterval_step_correct`). After 358 consumes
  the reshape, remove/retire the CarrierK1V placeholder and its `endInterval` `Nat.rec` wrapper
  (:2166) to avoid two `endIntervalStep` definitions of record.
- **SharedWitness / carrier-layer refactor (task 341).** `SharedWitness.lean` is **12,800 lines**
  (the dir `NfMultiAnchorBridge/` totals **29,531 lines** across ~29 files). All deps satisfied;
  this is the single largest structural-debt item. Split by concern (carrier defs vs. bit-compat vs.
  disjunct engine vs. order-type routing) before the 305/307/309 content grows it further.
- **Boneyard removal.** 71 files, ~47,400 lines, 121 sorries. **Not fully dead**: 3 non-Boneyard
  files still import Boneyard scaffold to keep it compiling — `Prop43.lean` (imports `VecEA_m`,
  `EAVecNegationClosure`) and `NavigatedEndChar.lean` (imports `NavigatedEndCharSinglePoint`). Task:
  sever these 3 live imports (inline or replace the needed scaffold), then delete the Boneyard tree
  wholesale. This alone removes 121 of the 164 real sorries and ~47k lines.
- **Module organization (task 131) / naming + bridge cleanup (task 175, [researched]).** The
  NfMultiAnchorBridge naming has drifted (`kvE2` k=2 vs `kvE` general-k vs `kvE_ext*` vs
  `bracketEndChar_*`); consolidate the naming convention and the `*K`/`*AssembleK` bridge layer once
  general-k is settled.
- **DiscreteGameTransfer refactor (task 299).** Inline `discrete_ghr93_theorem6`, make
  `discrete_rank_embed_eq_drc` a `@[simp]` lemma, drop the fixed-pivot dead code from task 273. Pure
  once the chain is sorry-free — sequence after 303.

---

## 5. POLISH

- **Copyright headers (tasks 180, 292).** **352 of 352** `.lean` files lack a `Copyright` header —
  a single mechanical sweep (Mathlib-style header block) covers both tasks. Task 180 also bundles
  universe-polymorphism and line-limit cleanups.
- **README / module docstrings (task 177).** Update `IntegerModel/README.md`,
  `NfMultiAnchorBridge` module docs, and the `Metalogic.lean` tracking table (flip discrete
  completeness `SORRY`→green) once 358 lands.
- **Mathlib linter compliance (task 293).** Audit/fix simpNF, unusedVariables, docString, and
  line-length linters across the shipped layers.
- **Toolchain upgrade (task 291).** Currently `leanprover/lean4:v4.27.0-rc1` + Mathlib v4.27.0-rc1;
  task targets v4.31. Sequence AFTER green (a toolchain bump mid-proof risks churn in the 29k-line
  bridge). Use `skill-lean-version` with backup/rollback.
- **Stray sorries in shipped subsystems (task 294).** `Theorems/ModalS5.lean` (1 real) and the
  Perpetuity layer (`Bridge.lean`, `Principles.lean`) carry sorries in already-"shipped" theorems —
  independent of the completeness spine, safe to close anytime.

---

## 6. BOTTOM LINE

**What to do next (prioritized):**
1. **Unblock and dispatch task 358** — it directly retires the sole spine sorry
   (`nf_nvar_exist_all_depths` KampPrior.lean:361/:364). This is the highest-leverage single move:
   its completion flips `completeness_discrete` to a clean `[propext, Classical.choice, Quot.sound]`
   footprint. Deps satisfied (357✓). Genuinely hard (Rabinovich Cor 5.4 realizer).
2. **`/revise 349` → v8** and implement Phase 2 (D1–D4 bracket wrapper) — bounded ~150–200 additive
   lines against the sorry-free k=2 template; unblocks 350, feeding the 309→307→305 supply chain
   that 358 draws on.
3. **Start task 341 (SharedWitness refactor) in parallel** — all deps satisfied, off the spine,
   de-risks the 12.8k-line layer before 305 grows it.
4. **Re-scope task 303** off the stale `KampBypass`/`existPart_succ_n1_bypass` reference before
   planning; then 303 → {299, 95}.
5. **After green**: task 95 verification audit (re-run `#print axioms`, confirm the Bundle
   `SuccRelation`/`SuccExistence` sorries are truly off-spine), then Boneyard removal + copyright
   sweep (180/292) + linter (293) + docstrings (177) + toolchain (291).

**Mechanical vs. genuinely open mathematics:**
- **Genuinely open**: the Rabinovich Cor 5.4 within-bracket bounded witness-selection realizer
  (task 358), the off-diagonal two-anchor F_i chain (task 309), and the faithful EA-formula
  formalization with negation-closure induction (task 305, ~2200 lines). This is the real remaining
  content — call it **one hard core (the realizer) plus one large faithful-transcription file**.
- **Mechanical threading/assembly**: 349 Phase 2, 350, 307 wiring, 303 k>0 induction (given the
  k=0 template), 299, and all of §4–§5 (Boneyard removal, headers, linters, docstrings, toolchain).
  This is the majority of the *task count* but a minority of the *difficulty*.

**One-sentence characterization**: discrete completeness is a single hard realizer lemma
(KampPrior.lean:361, task 358) away from sorry-free; the surrounding ~10 open tasks are
predominantly bounded assembly and cleanup, with the only other substantial mathematics being the
faithful Rabinovich EA-formula layer (task 305) that the realizer consumes.
