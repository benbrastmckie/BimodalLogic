# Report 08 — Task 349 v6 Phase 3 Design-Resolution Audit (rec-vs-charF)

- **Task**: 349 (build recursive endchar navigated arity-3 endpoint primitive), v6 Phase 3
- **Session**: sess_1783841542_df767b
- **Mode**: lean-research-hard (H2 anti-analysis, H3 reference grounding Tier 1, H4 adversarial verification, H5 divergence audit)
- **Scope**: READ-ONLY design adjudication. No Lean source edited.
- **Authority**: the actual Lean types (file:line below) + Rabinovich 2014 (`rabinovich_2014`); reports 04/05/06/07 and plan 06 are context.

---

## VERDICT

**OPTION B (compose `rec (reduceA sub) : VVecEA2` via the archived `VVecEA_m.liftInterval` two-endpoint machinery) is INFEASIBLE.** It is a red herring: `liftInterval` is the **wrong arity family**. Its codomain is arity-`m` `VVecEA_m`, the carrier's codomain is arity-2 `VVecEA2`; there is **no general `m→2` existential-collapse bridge**; and its semantic model is `m` **free** anchors, not two fixed endpoints with existential interior witnesses. The plan's own preserved-assets audit already reached this conclusion (plan 06:107–108, "LEAVE ARCHIVED (wrong arity family)").

**Option C** (relocate a self-contained depth-`k` arity-1 char provider below `CarrierK1V`) is a real construction but is **conditionally viable at best** — it is the retired `charF`/`kv_body` route, and its viability turns on an **unresolved** question: whether F1 (`bracketEndChar_kv_factors`) refutes only the *unconditional/general-structure* soundness or also the *Prior-hypothesis-guarded* target.

**The true minimal unblock is a bounded `/revise` that RE-FREEZES the Phase-2 signature**, in one of two directions (neither is `liftInterval`):
- **(D) Prop-valued carrier** — re-type `BracketEndCharCarrierV` from the syntactic `VVecEA2` to a genuinely Prop-valued interval predicate, threading the IH `rec` through the **already-green Step-A/Step-B reduction** (`endCharStep_quant_reduceA`, `nf_zone_flatten_navigable_correct`). No syntactic bracket, no `charF`, no F1 collapse.
- **(C′) Prior-guarded `charF` carrier** — add `semantic_prior_UZ/SZ` to the correctness target, relocate a `charF` provider below `CarrierK1V`, and adopt the `kv_body` construction — **only if** the F1-under-Prior question below resolves in its favour.

This is a **plan-revision / spawned-prerequisite decision**, exactly as the handoff flagged. It should NOT resume via a "restore machinery + fill the step" `/revise` against the Boneyard `liftInterval` files.

---

## Findings (H3 Tier 1 — literature-backed; 5-column lemma mapping)

Tier 1 selected: the task cites Rabinovich Def 7.13 (`md:451`), §5 bracket notation (`md:219`), Lemma 3.2(2) (`md:119`), Prop 4.2/4.3.

| Source (Rabinovich 2014) | Prop / Location | Lean Identifier | Type Signature (verified from source) | Status |
|---|---|---|---|---|
| §5 Notation 5.2 — two-endpoint bracket `[α₀,…,αₙ](z₀,z₁)` | `md:219` (p.7) | `BracketEndCharCarrierV` | `abbrev … (sig)(k) : Type := NormalForm sig k 3 → VVecEA2` (CarrierK1V.lean:365) | GREEN (frozen carrier) |
| §5 bracket semantics | `md:219` | `BracketFormula` | `pointTypes : Fin n → TemporalPred; segmentTypes : Fin (n+1) → TemporalPred` (VecEAFormula.lean:128) | GREEN — **point types are CLOSED formulas** |
| §5 disjunct assembly | `md:219` | `bracketFromLists` | `(lL:List TemporalPred)(ptW:TemporalPred)(lR:List TemporalPred)(segL segR) : BracketFormula (lL.length+1+lR.length)` (CarrierK1V.lean:389) | GREEN — interior slots are `List TemporalPred` (closed) |
| Def 7.13 — "conjunction of adjacent 2-endpoint pieces" (arity-`m` lift) | `md:451` (p.7) | `VecEA_m.liftInterval` | `(i:Fin (m-1))(vea2:VecEA2 k) : VecEA_m m` (EAVecNegationClosure.lean:101) | GREEN but **arity-`m` output** |
| Def 7.13 (disjunctive lift) | `md:451` | `VVecEA_m.liftInterval` | `(i:Fin (m-1))(v:VVecEA2) : VVecEA_m m` (EAVecNegationClosure.lean:161) | GREEN but **arity-`m` output** |
| Prop 4.2 (arity-`m` negation closure, the file's real purpose) | `md` p.9 | `neg_vec_ea_m` | `… (v:VVecEA_m m)(env:Fin m→carrier)(StrictMono env) … → ∃ v', v'.holds … env` (EAVecNegationClosure.lean:285) | GREEN — **free-anchor `env` model** |
| §7 arity-`m` → pair projection | `md:451` | `IsVEA` / `isVEA_ex` | `IsVEA … := ∀ i j, i<j → ∃ v:VVecEA2, …` (ArityReduction.lean:69); only `isVEA_ex` proved | **PARTIAL** — projection construction + neg-closure UNBUILT (ArityReduction.lean:20–22,38–51) |
| Lemma 3.2(2) — reduce arity-`n` to ≤2-anchor conjunction | `md:119` (p.4) | `nfEval_le2_reduction` | `nf_eval_nf M k n env qnf ↔ nfEvalRHS M k n env qnf` (Lemma32Reduction.lean:535) | GREEN (task 351) |
| Lemma 3.2(2) whole-quant-layer step reduction | `md:119` | `endCharStep_quant_reduceA` | `(∀ sub, (∃v, nf_eval_nf M k 4 [v,w,x,t] sub) ↔ qnf.2 sub) ↔ (∀ sub, (∃v, nfEvalRHS M k 4 [v,w,x,t] sub) ↔ qnf.2 sub)` (NavigatedEndChar.lean:281) | GREEN (Step A) |
| Def 4.1 char formula (arity-1 depth-`k`) | `md:137` (p.5) | `nf_characterizable_temporal_prior` | `(k)(nf:NormalForm sig k 1) : {A:Formula // ∀ M (h_UZ:semantic_prior_UZ)(h_SZ:semantic_prior_SZ)(t), temporal_truth M atomMap t A ↔ nf_eval_nf M k 1 (fun _=>t) nf}` (KampPrior.lean:407) | GREEN — **requires Prior hyps; lives ABOVE CarrierK1V (cycle)** |
| — (machine-refuted closed-formula fiber collapse) | — | `bracketEndChar_kv_factors` | equal-carrier congruence on `(atom, offFiber, foldbits over (zoneSpec, nfk_projFresh sub))` (CarrierKv.lean:422) | GREEN theorem = **F1 refutation of the `charF`/`kv_body` route** |
| — (machine-refuted single-point/general-structure form) | — | `endCharN0_correct_infeasible` | concrete Bool countermodel (Base.lean:1779; narrative :1036–1047) | GREEN theorem = negative guardrail |

---

## Answers to the five decisive questions

### Q1 — Does `VVecEA_m.liftInterval` provide exactly the combinator `endIntervalStep` needs, yielding a `VVecEA2` without a `VVecEA2→Formula` bridge? **NO.**

The type is decisive. `endIntervalStep` must have codomain `BracketEndCharCarrierV sig (k+1) = NormalForm sig (k+1) 3 → VVecEA2` (CarrierK1V.lean:365, 2144–2147). `VVecEA2` is a **two-fixed-endpoint** object: `VVecEA2.holds M atomMap z0 z1` takes exactly two points (VecEAFormula.lean:276), with interior content as **existentially quantified** bracket witnesses (`BracketFormula.holds` = "there exist strictly increasing witnesses in `(z0,z1)`…", VecEAFormula.lean:160–169).

`liftInterval` produces the **opposite** object:
- `VecEA_m.liftInterval : (i:Fin (m-1)) → VecEA2 k → VecEA_m m` (EAVecNegationClosure.lean:101).
- `VVecEA_m.liftInterval : (i:Fin (m-1)) → VVecEA2 → VVecEA_m m` (EAVecNegationClosure.lean:161).

The output is `VVecEA_m m` (arity `m`), whose semantics `VVecEA_m.holds M atomMap (env : Fin m → M.carrier)` takes a **given `m`-tuple of FREE anchors** (VecEA_m.lean:104–112: every `endpointTypes i` is evaluated at `env i`; the `env` is supplied, never existentially bound). So there is **no term skeleton** of the required shape: `liftInterval` neither returns a `VVecEA2` nor keeps the two endpoints fixed with interiors existential.

To reach `VVecEA2` from a lifted `VVecEA_m m` you would need a general `m→2` existential collapse (quantify the `m−2` interior anchors, re-express as bracket witnesses). **It does not exist.** The only conversion in-tree is `VVecEA_m.toVVecEA2 : VVecEA_m 2 → VVecEA2` (VecEA_m.lean:586), a **trivial `m=2` relabel** (no quantification). The general projection is `IsVEA` (ArityReduction.lean:69), which is only an **existence predicate**; solely `isVEA_ex` is proved, and the projection construction + its negation closure are explicitly **UNBUILT / blocked** (ArityReduction.lean:20–22, 38–51). For `k ≥ 2` the Def-7.13 chain has `m ≥ 3`, so the trivial `m=2` relabel never applies.

Note the "STRONG LEAD" phrasing `rec (reduceA sub)` also does not type: `rec : NormalForm sig k 3 → VVecEA2` (arity 3), but the reduction's subs are `sub : NormalForm sig k 4` (arity 4; NavigatedEndChar.lean:263–290). The arity-4 reduced structure cannot be fed to the arity-3 `rec` without a navigation/projection step (Step B), which is exactly the unbuilt-and-partly-refuted piece (see Q5).

### Q2 — Faithful and F1-avoiding? Is it Def 7.13, and does it re-enter the F1 collapse? **The combinator does not apply (Q1), so the question is moot for `liftInterval`; but the adversarial probe surfaces the REAL obstruction.**

`liftInterval` genuinely *is* Def 7.13's "conjunction of adjacent 2-endpoint pieces" (report 07:271, `md:451`) — but in the **negation-closure / arity-firewall** setting where the `m` anchors are a **free strictly-increasing environment** (its consumer is `neg_vec_ea_m`, EAVecNegationClosure.lean:285, over `StrictMono env`). That is not the endchar-carrier setting (two fixed endpoints `{x,t}`, interior witnesses existential). Lifting into a free-anchor chain and then *existentially collapsing* the interior anchors to bracket witnesses re-introduces, at each collapsed anchor, a **single closed-formula point type** (`BracketFormula.pointTypes : Fin n → TemporalPred`, VecEAFormula.lean:130). For depth-`k` content that closed-formula-per-witness demand **is exactly the F1 collapse** — so even the collapse route does not escape F1; it re-enters it.

**The deeper, load-bearing finding (this is the real root cause):** a **syntactic `VVecEA2` carrier assembled via `bracketFromLists` is inseparable from a closed-formula `charF`.** `bracketFromLists` (CarrierK1V.lean:389) takes interior point slots as `List TemporalPred` (closed formulas). The only in-tree way to supply depth-`k` interior point types is `charF k = nf_characterizable_temporal_prior` (KampPrior.lean:407). That is precisely the `kv_body` / `bracketEndChar_kv` route (CarrierKv.lean:238–249), and it is F1-exposed: `bracketEndChar_kv_factors` (CarrierKv.lean:422) proves the carrier term depends **only** on `(qnf.1, off-fiber Prop, fold bits `b zs χ` over `(zoneSpec, nfk_projFresh sub)`)`. The arity-4 sub `sub` is projected to its **arity-1 fresh projection** `χ = nfk_projFresh sub`; distinct quant layers sharing that fiber yield **equal carriers** — the information-loss channel (CarrierKv.lean:414–421).

Consequently v6's premise — *keep the syntactic `VVecEA2` carrier but thread the two-endpoint IH `rec` to avoid F1* — is **internally contradictory**: you cannot assemble a syntactic bracket without closed-formula point slots, and closed-formula point slots for depth-`k` content ARE the `charF` collapse. Threading `rec : →VVecEA2` to avoid `charF` is **type-impossible** for a syntactic bracket (no `VVecEA2 → TemporalPred` bridge; plan 06:340–351).

### Q3 — Does option B require re-freezing the Phase-2 signature, or is it purely additive? **Moot for B (infeasible); the genuine unblock DOES require a re-freeze.**

`endInterval`/`endIntervalStep`/`EndIntervalCorrect` (Phase 2, green) are frozen with codomain `VVecEA2` and inputs `(atomMap, h_surj, rec)` — no `charF` (CarrierK1V.lean:2144–2170). Since a faithful body is impossible under that exact signature (Q2), **any real fix re-freezes Phase 2**:
- **(D) minimal semantic re-type**: change `BracketEndCharCarrierV sig k` from `NormalForm sig k 3 → VVecEA2` to a Prop-valued interval predicate (e.g. `NormalForm sig k 3 → ∀ (M)(x t : M.carrier), Prop`, or reuse the green Prop-merge `nf_zone_flatten_navigable`, Base.lean:667/687). `EndIntervalCorrect` is then `carrier qnf M x t ↔ ∃ w, nf_eval_nf M k 3 [w,x,t] qnf` (same content as `BracketCarrierCorrectV`, CarrierK1V.lean:374, but with `.holds` replaced by direct application). `endIntervalStep` composes the IH `rec` (Prop) through `endCharStep_quant_reduceA` + `nf_zone_flatten_navigable_correct`. No `charF`, no bracket, no F1.
- **(C′) signature re-freeze to carry `charF`**: add a `charF : (j:Nat) → NormalForm sig j 1 → Formula` parameter (as `bracketEndChar_kv` does, CarrierKv.lean:241) and add `semantic_prior_UZ/SZ` to the correctness target.

Either way the change is **not purely additive** — it edits the frozen Phase-2 decls. That is why the handoff (correctly) classified this as a plan-revision/spawn decision, not an in-Phase-3 edit.

### Q4 — Restore scope / cycle safety of the Boneyard files. **Cycle-safe to restore, but pointless (they are the wrong tool).**

Import chain (verified): `EAVecNegationClosure.lean` imports `Boneyard.VecEAArityFirewall` (→ `Boneyard.VecEA_m` → `VecEAFormula`, `VecEAClosure`, `VecEATranslation`) and `EANegationClosure` (→ `EANegation`, `VecEAClosure`). **None of these import `CarrierK1V`/`NfMultiAnchorBridge` in code** — the apparent hits in `EANegationClosure.lean` (`:738`, `:744`) are **docstring line-number mentions only**. So restoring `EAVecNegationClosure` + `VecEA_m` would sit strictly **below** `CarrierK1V` (no cycle), and does **not** transitively pull `NegationIndep`/`RabinovichTranslation` (those are separate Boneyard files with their own imports; `RabinovichTranslation` imports only `Kamp.Translation`). Restore is a clean `git mv` + revert of `import …Boneyard.VecEAArityFirewall`.

**But the restore buys nothing**: `liftInterval` cannot produce the carrier's `VVecEA2` (Q1), and the plan's own audit already marked both files "LEAVE ARCHIVED (wrong arity family), 0 code hits" (plan 06:107–108). **Do not restore them for this purpose.**

### Q5 — If B fails, assess C and state the true minimal unblock. **B fails; the unblock is (D) or (C′) via a bounded `/revise`, gated on resolving F1-under-Prior.**

**Why the reduction assets do not close the gap on their own.** The green Step-A family reduces the depth-`(k+1)` quant layer to `nfEvalRHS` form while keeping subs at full arity 4 and the witness `v` outside (`endCharStep_quant_reduceA`, NavigatedEndChar.lean:281). This is faithful and F1-*avoiding at the Prop level* — it never projects to `nfk_projFresh`. The unbuilt piece is **Step B**: converting the reduced Prop into the carrier's term. The only existing Prop→term bridges are (a) `kv_body`/`charF` (F1-refuted at k≥2), (b) the k=1 base (works only because depth-0 interior 1-types are already closed formulas), and (c) the **single-point** `navPieceForm_correct`, which is the **machine-checked non-theorem** (archived to `Boneyard/NavigatedEndCharSinglePoint.lean`; NavigatedEndChar.lean:9–13, 204–207).

**Option C assessment.** C = relocate a self-contained `charF` provider below `CarrierK1V` and re-freeze the signature to consume it = essentially adopt `kv_body`. Feasibility hinges on **one unresolved question**:

> **Is F1 (`bracketEndChar_kv_factors`) fatal under Prior hypotheses, or only unconditionally?**

Evidence I could establish:
- F1 is a **structure-independent term equality** (definitional congruence on `kv_body`; CarrierKv.lean:439–453). It holds regardless of `M`.
- Its docstring scopes it to *"the **unconditional** k≥2 soundness direction"* (CarrierKv.lean:420), and the concrete countermodel it points at (`endCharN0_correct_infeasible`, Base.lean:1779) is a **general `OrderedMonadicStructure`** witness — no `semantic_prior_UZ/SZ`.
- `charF` provably **exists and is correct on Prior structures** (`nf_characterizable_temporal_prior`, KampPrior.lean:407, under `semantic_prior_UZ/SZ`), and the Def-4.1 fold has a soundness lemma (`nf_quant_layer_fold_iff`, cited NfEFold:391).
- The frozen `BracketCarrierCorrectV` target is stated over **general** `OrderedMonadicStructure` with **no Prior hypotheses** (CarrierK1V.lean:374–380). By contrast `IsVEA` carries `semantic_prior_UZ/SZ` (ArityReduction.lean:74–75).

**Synthesis of the evidence (adversarially flagged as not fully verified):** F1 as written refutes the *general-structure* charF carrier; it does **not**, by itself, refute a **Prior-hypothesis-guarded** charF carrier where two quant layers sharing the fold fiber are semantically equivalent. If the Def-4.1 fold is sound on Prior structures, then `kv_body` (option C/A) **could be correct after all** under the added `semantic_prior_UZ/SZ` hypotheses — and v6 may have over-generalized F1 into a blanket ban on `charF`. **This must be resolved before choosing C over D.**

**Recommended true minimal unblock — (D) Prop-valued carrier**, because it side-steps the F1 question entirely and consumes only already-green assets:
1. `/revise 349 --hard`: re-type `BracketEndCharCarrierV sig k` to a Prop-valued two-endpoint interval predicate; restate `EndIntervalCorrect` as `carrier qnf M x t ↔ ∃ w, nf_eval_nf M k 3 (Fin.cons w (Fin.cons x (fun _=>t))) qnf` (content-identical to `BracketCarrierCorrectV`).
2. Re-establish the (trivial) k=0 and k=1 bases at the Prop level (the green `bracketEndChar_k0_correct`/`bracketEndChar_k1v_correct` provide the `↔` content; wrap `.holds`).
3. `endIntervalStep` body: compose `rec` (Prop) via `nfEval_step_unfold_gen` → `endCharStep_quant_reduceA` (Step A, green) → `nf_zone_flatten_navigable_correct` (Step B Prop merge, green; Base.lean:687) → IH `rec` at each ≤3-anchor reduced conjunct.
4. Correctness obligations for Phases 4/5: the ≤3-anchor navigation discharge of the Step-B merge (the piece report 06 §4.5 identified), by `k`-induction with the k=1 kit as template.

If instead the team confirms F1-does-not-bite-under-Prior, **(C′)** is also viable and keeps the syntactic `VVecEA2` codomain (better for the downstream 309/350 extraction), at the cost of adding `semantic_prior_UZ/SZ` + relocating `charF`.

**Is the faithful step itself infeasible?** No. The *step* is feasible; the frozen *codomain choice* (syntactic `VVecEA2` without `charF`) is what is infeasible. The obstruction is a codomain/type decision, not a mathematical wall.

---

## Faithfulness + F1-avoidance argument (grounded)

Rabinovich's faithful depth-`k` object is Def 7.13's "conjunction of adjacent 2-endpoint pieces, never a one-point read" (`md:451`; report 07:271, High confidence). The single-point `EndCharCarrier → TemporalPred` line is refuted precisely because it reads a two-free-variable object at one point (`endCharN0_correct_infeasible`, Base.lean:1779; NavigatedEndChar.lean:34–45). The two-endpoint carrier fixes the **arity** mismatch (two free vars matched to `{x,t}`). But faithfulness of the *interior* recursion requires that each interior witness's depth-`k` content be carried **relationally** (via the bracket order + segments + recursively nested witnesses), not by an arity-1 projection. `kv_body` violates this by projecting to `nfk_projFresh` (F1). The Prop-valued route (D) preserves the relation exactly (the reduced `nfEvalRHS` keeps subs at full arity and the witness outside — NavigatedEndChar.lean:100–113, 281–290), which is why it is F1-avoiding **without** needing `liftInterval` at all. `liftInterval`'s free-anchor `env` model (VecEA_m.lean:104–112) is faithful for Prop 4.2 negation closure but is the **wrong semantic frame** for the existential-witness endchar carrier.

---

## Adversarial Self-Verification (H4)

Applied the Claim Verification Bar to every load-bearing claim. Verification methods below are lean4-domain values (source-line + type reads; MCP hover was unnecessary because the exact type signatures are read verbatim from source and are the authority per the task).

| Claim | Source / Counter-probe | Verification Method | Confidence |
|---|---|---|---|
| `liftInterval` outputs arity-`m` `VVecEA_m`, not `VVecEA2` | EAVecNegationClosure.lean:101,161,163 | direct source type read | High |
| Carrier codomain is arity-2 `VVecEA2`; `.holds` takes exactly 2 points | CarrierK1V.lean:365; VecEAFormula.lean:271–279 | direct source type read | High |
| No general `m→2` existential collapse; only trivial `VVecEA_m 2 → VVecEA2` | VecEA_m.lean:586; ArityReduction.lean:69 (IsVEA existence-only, neg-closure blocked) | direct source read | High |
| `VecEA_m.holds` uses a FREE env (no existential interior) | VecEA_m.lean:104–112 | direct source read | High |
| `bracketFromLists` interior slots are closed `TemporalPred` | CarrierK1V.lean:389–395; VecEAFormula.lean:128–132 | direct source type read | High |
| Threading `rec:→VVecEA2` into a bracket needs a `VVecEA2→Formula` bridge that does not exist | plan 06:340–351; type structure | source + type reasoning | High |
| F1 (`bracketEndChar_kv_factors`) is a structure-independent term equality via `(atom, offFiber, foldbits over (zone, nfk_projFresh))` | CarrierKv.lean:422–453 | direct source read | High |
| `charF` (`nf_characterizable_temporal_prior`) exists+correct ONLY under `semantic_prior_UZ/SZ` | KampPrior.lean:407–420 | direct source read | High |
| `charF` provider is above `CarrierK1V` (import cycle via KampPrior→…→CarrierK1V) | CarrierKv.lean:25–30; handoff blocker evidence | source + handoff | High |
| Step-A reduction is green and keeps subs at arity 4, witness outside (F1-avoiding at Prop level) | NavigatedEndChar.lean:100–113,281–290 | direct source read | High |
| Boneyard restore is cycle-safe (EAVecNegationClosure/VecEA_m sit below CarrierK1V) | import grep: EANegationClosure/VecEAArityFirewall/VecEA_m — no CarrierK1V code import | grep of `^import` lines | High |
| **F1 does NOT refute a Prior-hypothesis-guarded charF carrier (only the unconditional/general-structure one)** | CarrierKv.lean:420 ("unconditional"); Base.lean:1779 (general-structure countermodel); no Prior-guarded refutation found | source reading + ABSENCE of counter-evidence; fold-soundness (`nf_quant_layer_fold_iff`) NOT re-verified | **Low (UNRESOLVED)** |
| Prop-valued route (D) consumes only green assets and avoids F1 | Base.lean:667/687 (`nf_zone_flatten_navigable_correct`); NavigatedEndChar.lean:281 | source read; the k-induction discharge for Phases 4/5 is NOT yet proved | Medium |

**Contradiction Log.** One unresolved item, surfaced by adversarial challenge:

> **UNRESOLVED CONTRADICTION**: plan 06 treats F1 as a blanket refutation of the `charF` route ("A: … likely a non-starter given F1", plan 06:373–375), whereas the F1 theorem's own docstring scopes it to the **unconditional** direction (CarrierKv.lean:420) and its countermodel is a **general** structure (Base.lean:1779), while `charF` is provably correct on **Prior** structures (KampPrior.lean:407). Resolution attempted via the Contradiction Resolution Protocol precedence (machine-checked artifact > docstring > plan narrative): the machine-checked artifact (`bracketEndChar_kv_factors`) is a term equality that does **not** mention `M`, so it neither asserts nor refutes Prior-conditional correctness — it is **compatible with both**. The plan narrative's stronger claim is therefore **not fully substantiated** by the cited artifact. **Downstream risk**: if a `/revise` picks (D) purely to avoid F1 when (C′) would in fact work, it needlessly changes the codomain that downstream 309/350 extraction prefers. **Resolving check not yet performed**: verify whether `nf_quant_layer_fold_iff` (NfEFold:391) makes the fold fiber determine quant-layer semantics on Prior structures; if yes, `kv_body` is Prior-correct and (C′) is preferred.

**Recommendations modified after verification.** Initial instinct was "B infeasible → recommend C (charF)". Adversarial review demoted C to *conditional* (F1-under-Prior unresolved) and promoted (D) Prop-valued re-type as the **F1-agnostic** primary recommendation, with (C′) as the alternative to pursue **iff** the fold-soundness check resolves favourably. No claim rests on `liftInterval`; the B-infeasibility verdict is type-level and High-confidence.

---

## Revised Phase-3 (and Phase-2 re-freeze) spec — ready for `/revise`

**Do NOT** restore/consume `liftInterval`. Re-freeze Phase 2 per direction (D) (primary) or (C′) (conditional).

**Green assets to consume (by name):**
- `nfEval_le2_reduction` (Lemma32Reduction.lean:535), `endCharStep_quant_reduceA` / `endCharStep_reduceA` / `navPiece_reduce` (NavigatedEndChar.lean:281/263/169), `nfEval3_reduction`/`nfEval4_reduction` (+shapes).
- `nf_zone_flatten_navigable` / `_correct` / `_brick` (Base.lean:667/687/813) — Step-B Prop merge, x,t-explicit.
- `endCharNav0_correct` (+`_pairwise`) (NavigatedEndChar.lean:128/145) — reduced base.
- `bracketEndChar_k0_correct` (CarrierK1V.lean:87), `bracketEndChar_k1v_correct` (CarrierK1V.lean:2041) — k=0/k=1 `↔` content for the re-stated bases.
- `endInterval k` IH (its restated Prop-level correctness) as the recursion hypothesis.
- **(C′) only**: `nf_characterizable_temporal_prior` (KampPrior.lean:407) relocated below `CarrierK1V`; add `semantic_prior_UZ/SZ` to the target.

**Correctness obligations Phases 4/5 then discharge:**
- **Phase 4 (soundness LHS→RHS)** and **Phase 5 (completeness RHS→LHS + `↔`)** of the re-stated `endInterval_correct`, by `induction k`, with the k=1 kit (CarrierK1V.lean:513–2039) as template; the step's obligation is the ≤3-anchor navigation discharge of the Step-B merge under the IH (report 06 §4.5), the witness staying existential (G2/G4), anchors `{x,t}` explicit.
- **(C′) only**: additionally resolve the F1-under-Prior soundness (verify `nf_quant_layer_fold_iff` gives fold-fiber determinacy on Prior structures) BEFORE committing to the syntactic codomain.

**Prohibited (carried over):** no `sorry`/vacuous stub; no reinstating the single-point `navPieceForm`/`endChar_correct` line; no per-pair `∀ij∃v` distribution; no arity-collapsing `nfRestrict`; no restore of `liftInterval` as the step vehicle.

---

## H5 Divergence note

`focus_prompt` did not contain "divergence"/"audit" as trigger tokens, but this dispatch functions as a de-facto divergence resolution: the churned target is `endIntervalStep`'s body across v3→v6 (single-point `navPieceForm` refuted; v6 syntactic `VVecEA2` blocked). **Root cause of repeated failure**: the recursion motive has been chosen as a **syntactic** object (`TemporalPred`, then `VVecEA2`) at each attempt, forcing a per-witness closed-formula characterization that is either arity-wrong (single point) or F1-collapsing (`charF`). The convergent fix is to stop emitting a syntactic per-witness type inside 349 and either (D) keep the carrier Prop-valued or (C′) admit `charF` under Prior hypotheses — deferring syntactic emission to the 309/350 extraction where `nf_characterizable_temporal_prior` legitimately applies.
