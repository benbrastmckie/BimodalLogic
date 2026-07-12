# Discrete-Completeness Finish-Line Map (Angle 1)

**Scope**: the live dependency neighborhood of `completeness_discrete` only.
**Authority basis**: `lean_verify` axiom check (proof-term truth) + import-graph reachability + source line evidence. NOT grep-guessing.
**Verdict up front**: `completeness_discrete` **still carries `sorryAx`** (verified this session, see §0). The sole live proof-term sorry is a **single declaration** — `nf_nvar_exist_all_depths` (KampPrior.lean), two match arms `:361` and `:364`. The Completeness.lean audit note (`:355–367`) naming `existPart_succ_n1_bypass` / `KampBypass.lean` is **stale** (ROADMAP.md:31 says so explicitly; that file is Boneyard'd).

---

## 0. Authoritative axiom verdict

`lean_verify` on `Bimodal.Metalogic.BXCanonical.completeness_discrete`:

```
axioms = [propext, sorryAx, Classical.choice, Lean.ofReduceBool, Lean.trustCompiler, Quot.sound]
```

`sorryAx` present ⇒ NOT sorry-free. `Lean.ofReduceBool` / `Lean.trustCompiler` are `decide`-class, acceptable. The task-95 audit target is: eliminate `sorryAx` only.

---

## 1. On-path file list (live transitive deps), grouped by role

### 1a. The proof-term spine (the actual critical chain)

Each arrow is a real definitional/proof-term call, traced from the discrete arm of `completeness_discrete`:

| # | Symbol | File:line | Status |
|---|--------|-----------|--------|
| 1 | `completeness_discrete` (discrete arm) | BXCanonical/Completeness.lean:276 (call at :336) | carries sorryAx |
| 2 | `countermodel_discrete_reynolds_v2` | WeakCanonical/IntegerModel/ReynoldsBridge.lean:724 | sorry-free |
| 3 | `limitdom_is_good` | WeakCanonical/IntegerModel/ReynoldsBridge.lean:346 | sorry-free |
| 4 | `no_gaps_discrete_model_surgery` | WeakCanonical/IntegerModel/GoodStructuresModelSurgery.lean:2133 | sorry-free |
| 5 | `US_expressively_complete_over_prior` | WeakCanonical/PriorExpressiveness.lean:346 | sorry-free (Kamp/Prior route; bypasses Stavi, PriorExpressiveness.lean:24) |
| 6 | `kamp_prior_expressive_completeness` | WeakCanonical/Kamp/KampPrior.lean:490 | body sorry-free; calls ↓ |
| 7 | `nf_characterizable_temporal_prior` | WeakCanonical/Kamp/KampPrior.lean:407 (uses `k 1` at :427–428) | body sorry-free; calls ↓ |
| 8 | **`nf_nvar_exist_all_depths`** | WeakCanonical/Kamp/KampPrior.lean:212 | **SORRY :361 (n=1), :364 (n+2)** |

The k+1 recursion at KampPrior.lean:273 re-enters `nf_nvar_exist_all_depths … k 1` (the n=1 arm), so the `:361` sorry is genuinely value-reached for k ≥ 1.

### 1b. Sorry-free supporting infra actually consumed on the spine

- **Reynolds bridge**: WeakCanonical/Transfer.lean (`truth_transfer`, `mkSig*`), IntegerModel/GoodStructures.lean, IntegerModel/ShiftAndGlue.lean, IntegerModel/NoGapsDiscreteProof.lean (`one_class`), IntegerModel/ReynoldsNoGaps.lean, WeakCanonical/OrderedSum.lean, Algebraic/ParametricCanonical, Algebraic/ParametricHistory, Algebraic/ParametricCompleteness, Algebraic/RestrictedParametricTruthLemma.
- **Kamp / Prior expressiveness**: WeakCanonical/PriorExpressiveness.lean, Kamp/KampPrior.lean, Kamp/ExistsForallNF.lean, Kamp/NfToVecEA.lean, Kamp/NfDepth0Generalized.lean, WeakCanonical/NormalForm.lean, WeakCanonical/PriorDefs.lean, Separation/KampTranslation.lean, WeakCanonical/MonadicFO.lean, WeakCanonical/Table.lean, Expressiveness/Theorem6.lean (`doets_lemma_1_1`).
- **Mixed/dense guard (sorry-free)**: BXCanonical/Chronicle/MCSMixedCase.lean (`mcs_mixed_case_absurd`) — the ONLY Chronicle symbol on the live path.

### 1c. Anchor-bridge role — in import closure, NOT proof-term-consumed (yet)

KampPrior.lean:4 imports the `NfMultiAnchorBridge` aggregator, so the entire `NfMultiAnchorBridge/` subtree is in the **import closure** of `completeness_discrete`. But because the `:361`/`:364` sorries block the proof term, **nothing in this subtree is currently a proof-term dependency of `completeness_discrete`**. This subtree is the *intended provider* for the n=1 retirement:

`NfMultiAnchorBridge.lean` + `{Base, CarrierK1V, CarrierKv, RefutationF2, PriorInterface, SubBracket, SubBracket2, SubBracket2V, NavigatedSpine, SharedWitness, OuterGate, ExteriorZoneTriage, ExteriorBracket, Lemma32Reduction}`, plus Kamp/`{NfZoneFlattenNavigable, NfEFold, EANegationClosure}`.

Key discharge asset already landed: `bracketEndChar_kvE2Ext_correct_two_prior_frag` (NfMultiAnchorBridge/ExteriorBracket.lean:1069, task 348, sorry-free).

---

## 2. Sorry ledger (every actual `sorry` in the live Metalogic tree, Boneyard excluded)

| File | Sorry line(s) | On-path for `completeness_discrete`? | Task | Status |
|------|--------------|--------------------------------------|------|--------|
| Kamp/KampPrior.lean | **361** (n=1 arm), **364** (n+2 arm) of `nf_nvar_exist_all_depths` | **YES** — sole live proof-term sorry; :361 value-reached via :273 recursion + `nf_characterizable_temporal_prior` (:427); :364 in same def body ⇒ propagates `sorryAx` | 309 (retirement); 349/350/351 (alt route); 303 (historical) | 309 blocked; 303 planned |
| Kamp/EANegation.lean | 1090, 1249 (B.1 backward, n≥1) | No — in import closure (EANegationClosure), but the n=1 sorry blocks before any consumption; not proof-term-reached | — | parked |
| WeakCanonical/TruthLemma.lean | 431,448,483,497,540,556 | No — file self-documents "non-critical-path; parametric truth lemma handles via BFMCS" (:392–397). Live path uses `RestrictedParametricTruthLemma` | 141 | resolved/off-path |
| Chronicle/ChronicleToCountermodel.lean | 221,377,513,527,768,788 | No — dead `chronicle_gap_contradiction → succ_cofinal` chain; Completeness uses Reynolds v2 (ROADMAP.md:68) | — | dead code |
| WeakCanonical/Transfer.lean | 1270 | No — deprecated `countermodel_discrete` (BX path); `succ_cofinal` provably unfixable (:1249–1254) | 155 | deprecated |
| WeakCanonical/OrderedSum.lean | 56 (`doets_lemma_1_5`) | No — self-documents "Not on discrete completeness critical path; dense case only; bypassed by one_class" (:47–52) | — | dense/future |
| EFGames/StaviCompleteness.lean | 2421,2503,2873 | No — Stavi chain superseded by Kamp/Rabinovich route (PriorExpressiveness.lean:24) | 273 (hist.) | superseded |
| Expressiveness/CaseAnalysis.lean | 3376,3383,3403,3405,3407,3417 | No — Transfer.lean:745,840 explicitly "avoids the sorry at CaseAnalysis.lean" | — | avoided |
| BXCanonical/Frame.lean | 205 (`bx_le_refl`) | No — old BX pipeline (chronicle/quasimodel importers only); not on Reynolds spine | — | off-path |
| Bundle/SuccRelation.lean | 558,567,591,615,629,640,648 | No — Bundle reached only via ReflexiveCanonical / WeakCanonical.TruthLemma / Chronicle (all off proof-term path) | — | off-path |
| Bundle/SuccExistence.lean | 446,749,823 | No — same as above | — | off-path |
| Bundle/UntilSinceCoherence.lean | 85,96 | No — same as above | — | off-path |

**Off-path proof**: `lean_verify` reports exactly one `sorryAx` for `completeness_discrete`; the 2026-07-07 ROADMAP verification + in-file docstrings attribute it to KampPrior; every other file above carries an explicit "dead / deprecated / superseded / avoided / non-critical-path / dense-only" self-annotation. `NfMultiAnchorBridge/` subtree is sorry-free (the only "sorry" tokens there are docstrings, e.g. SharedWitness.lean:2996 "sorry-free").

---

## 3. Finish-line statement

`completeness_discrete` becomes `sorryAx`-free **iff** the single declaration `nf_nvar_exist_all_depths` (KampPrior.lean:212) becomes sorry-free. That requires BOTH:

- **(A) Discharge the n=1 arm** (KampPrior.lean:361): the depth-`k`, arity-`(n+1)=2` existential-converter for Prior structures (the "F_i-chain converter"). In-code named route (KampPrior.lean:348-360 comment): **task 309 Phase 14** — consume task 348's `bracketEndChar_kvE2Ext_correct_two_prior_frag` (ExteriorBracket.lean:1069) + instantiate the Phase-14 provider obligations (`hfrag/hrealI/hrealB/hexcl` + order bits + `h_UZ/h_SZ`). This arm is genuinely value-reached and is the true blocker.
- **(B) Eliminate the n+2 arm** (KampPrior.lean:364): even though the call values only need n=0,1, the n+2 sorry sits in the same `match` body and so propagates `sorryAx`. Discharge = either prove the general n≥2 case, or **restate `nf_nvar_exist_all_depths` to restrict its domain to n ≤ 1** so the arm structurally vanishes (the theorem only ever calls n=0 and n=1). The domain-restriction option is the lower-cost path to sorry-freeness and should be the default. Zero-debt note: (B) must be discharged, not deferred — a sorry in an "unreached" arm still taints the axiom audit.
- **(C)** Re-run `#print axioms` (task 95) to confirm `sorryAx` gone.

### Task mapping onto (A)/(B)

| Task | Maps to | Reality |
|------|---------|---------|
| **303** ("k>0 depth induction", `existPart_succ_n1_bypass` k>0) | (A), historically | **HISTORICAL / mis-scoped.** Its named terminus `existPart_succ_n1_bypass` and file `KampBypass.lean` are Boneyard'd (task 305 P0; ROADMAP.md:31). It is the *spiritual ancestor* of (A) but does not point at live code. Should be re-scoped to the KampPrior:361 obligation or closed. `[planned]` |
| **348** (prop43 exterior reflatten) | material for (A) | `[completed]` — produced the k=2 exterior discharge theorem; **explicitly deferred the KampPrior:351 retirement to 309** (completion summary). |
| **309** (offdiag two-anchor F_i chain) | (A), live owner | `[blocked]` — owns Phase 14 (consume 348 + provider instantiation). **This is the true finish-line task for (A).** Unblocking 309 is the highest-leverage action. |
| **349/350/351** (endChar / quantEndSeg / Lemma 3.2 reduction) | (A)+(B), alt route | Alternative arity-capped provider route (see §4). 351 `[completed]` (`nfEval_le2_reduction`); 349/350 `[researched]`. Cleanly handles (B) via the arity-≤3 cap. |

**Bottom line**: two independent routes converge on the same n=1 obligation — the ExteriorBracket route (348→309) and the endChar/reduction route (351→349→350). Neither is wired to the proof term yet.

---

## 4. endChar / NfMultiAnchorBridge — is it on the critical path?

**Verdict: NO, not currently on the proof-term critical path — but it is future critical-path infrastructure for the SAME theorem (`completeness_discrete`), not for a different theorem.** It is "parallel" only in the temporal sense (not yet wired), not in the target sense.

Evidence:

1. **Proof-term**: the live sorry (KampPrior.lean:361) is undischarged, so the `completeness_discrete` proof term terminates at `sorry` *before* reaching any endChar construction. `lean_verify`'s single `sorryAx` is the KampPrior one, not an endChar one.
2. **`NavigatedEndChar.lean` (task 349, the `endChar` primitive) has ZERO importers** (grep of live tree) — it is off even the *import* closure. It is a sorry-free Phase-1 scaffold that *imports* `Base`, `Lemma32Reduction`, `CarrierKv` and consumes task 351's `nfEval_le2_reduction`, explicitly to build an arity-≤3-capped recursion (NavigatedEndChar.lean:6-14).
3. **`nf_char3_endpoint_tl`** (Base.lean:869, task 349/350 endpoint primitive): Base.lean IS in the import closure (via the aggregator), but `nf_char3_endpoint_tl` is referenced only inside NavigatedEndChar.lean comments and Base.lean itself — **no proof-term consumer on the live path**.
4. **`quantEndSeg`** (task 350 aggregate): **not present in the live tree** — task 350 is `[researched]`, unimplemented.
5. The task-348 discharge route (`ExteriorBracket.lean`, the route the KampPrior:361 comment actually names for 309) does **not** reference `nf_char3_endpoint_tl` / `quantEndSeg` / `NavigatedEndChar` (grep-clean). So the endChar work (349/350) is an **independent alternative** to the 348/309 route, not a sub-component of it.

**Interpretation for restructuring**: endChar (349/350) + `nfEval_le2_reduction` (351) form a *second, more general* provider path (arity-reduction capped at 3, Rabinovich Lemma 3.2 route) aimed at the same n=1/n+2 obligation, with the bonus that the arity cap gives a clean structural discharge of the (B) n+2 arm. It targets `completeness_discrete`, not a different theorem. Restructuring should treat 348/309 and 351/349/350 as two competing finishes for one obligation and pick one to wire, rather than maintaining both indefinitely.

---

## Appendix: stale artifacts to correct during restructure

- **Completeness.lean:355–367** — axiom-audit note names `existPart_succ_n1_bypass` / `KampBypass.lean` (Boneyard'd). Rewrite to point at `nf_nvar_exist_all_depths` (KampPrior.lean:361/364).
- **ROADMAP.md:1431–1432** — "Task 303 CRITICAL … `existPart_succ_n1_bypass` k>0 (KampBypass.lean)". ROADMAP.md:31 already flags this as historical; §68 gives the correct current chain. The 303 task itself needs re-scoping to KampPrior:361.
- **Metalogic.lean:32** — completeness_discrete listed as "SORRY (chronicle + canonical model open question)"; the real open question is the KampPrior arity converter, not chronicle/canonical.
