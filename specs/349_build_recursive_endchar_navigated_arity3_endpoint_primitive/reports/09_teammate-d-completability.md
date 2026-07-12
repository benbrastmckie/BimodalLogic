# Report 09 — Teammate D: Lean Completability of the Carrier Options (D vs C′)

**Task**: 349 | **Angle**: D — Completability (green, sorry-free `endInterval`/`endInterval_correct` for ALL depths k)
**Mode**: research --hard (H2/H3/H4) | **Authority**: actual Lean types + goal states | **Cross-ref**: reports 06, 08 (not repeated)
**Session**: sess_1783841542_df767b

## Headline verdict (inverts report 08's primary recommendation)

**C′ (syntactic `VVecEA2` bracket carrier under Prior) is the MORE completable option with LEAST risk, and it is the option that matches the downstream 350/309 interface.** This inverts report 08's D-primary recommendation, and it does so on the exact "resolving check not yet performed" that report 08 flagged as its open contradiction (08:140): a machine-checked **green, sorry-free k=2 instance of the C′ family already exists** — `bracketEndChar_kvE2Ext_correct_two_prior_frag` (ExteriorBracket.lean:1069, 0 live sorries) — proving precisely the `EndIntervalCorrect` biconditional at depth 2 under `semantic_prior_UZ/SZ`. That artifact **empirically refutes the F1-under-Prior objection** that was the sole basis for preferring D.

Option **D's recursion bottoms out on `navMultiAnchorForm`/`navMultiAnchorForm_correct` (Base.lean:1831), which is UNBUILT (frozen docstring only, no def anywhere)** — the historically-deferred hard "navigate-to-each-anchor" lemma. The green Step-A/Step-B reductions that report 08 cites for D **reduce** the problem to that lemma's hooks but do **not** build or discharge them.

## Findings — H3 Tier-1 lemma mapping table (5-column)

| Source (Rabinovich / task) | Prop / Location | Lean Identifier | Type Signature (verified) | Status |
|---|---|---|---|---|
| GREEN k=1 template (VVecEA2) | §5 bracket, task 311 | `bracketEndChar_k1v` / `_sound` / `_complete` / `_correct` | `… → BracketEndCharCarrierV sig 1`; `_correct : (…).holds M atomMap x t ↔ ∃ w, nf_eval_nf M 1 3 (Fin.cons w (Fin.cons x (fun _=>t))) qnf` (CarrierK1V.lean:433, 2041) | GREEN, OFF live path (2065–2092) |
| **GREEN k=2 C′-family instance** | Lemma 7.6 / task 348 | `bracketEndChar_kvE2Ext_correct_two_prior_frag` | `… (h_UZ : semantic_prior_UZ …)(h_SZ : semantic_prior_SZ …)(hfrag)(hrealI)(hrealB)(hexcl) : (bracketEndChar_kvE2Ext … qnf).holds M atomMap x t ↔ ∃ w, nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _=>t))) qnf` (ExteriorBracket.lean:1069) | **GREEN, sorry-free** (provider hyps threaded, not sorries) |
| Closed-formula provider interface (charF) | Def 4.1, p.5 | `ExistProviders.existF` | `existF : (n : Nat) → NormalForm sig k (n+1) → Formula` (PriorInterface.lean:38–40) | GREEN interface |
| Step A — quant-layer arity reduction | Lemma 3.2(2), p.4 | `endCharStep_quant_reduceA` | `(∀ sub, (∃ v, nf_eval_nf M k 4 (Fin.cons v (zoneEnv3 w x t)) sub) ↔ qnf.2 sub) ↔ (∀ sub, (∃ v, nfEvalRHS …) ↔ qnf.2 sub)` (NavigatedEndChar.lean:281) | GREEN, sorry-free |
| Lemma 3.2(2) core reduction | Lemma 3.2(2) | `nfEval_le2_reduction` (task 351) | `… n=3/4 arity collapse ≤2` (Lemma32Reduction.lean:535) | GREEN, sorry-free |
| Step B — five-zone navigable flatten | Def 3.1 zones | `nf_zone_flatten_navigable` / `_correct` | hooks `pastEnd futureEnd : NormalForm sig k 3 → **TemporalPred**`; `_correct` needs `h_past/h_fut : (hook q).eval_at M atomMap w ↔ nf_eval_nf M k 3 (zoneEnv3 w x t) q`; concludes `(∃ w, nf_eval_nf M k 3 (zoneEnv3 w x t) q) ↔ nf_zone_flatten_navigable …` (Base.lean:667, 687) | GREEN, sorry-free — **hooks are single-point TemporalPred** |
| k=0 navigated base | task 309 P8 | `endChar0` / `endChar0_correct` | `(endChar0 qnf).eval_at w ↔ nf_eval_nf M 0 3 (zoneEnv3 w a b) qnf` **only under `h_res`** (Base.lean:995, 1056) | GREEN, sorry-free (conditional) |
| interior β-segment | §Q2 | `seg` / `seg_holds_coupled` | Base.lean:1127, 1150 | GREEN, sorry-free |
| **D's recursion core (navigate-to-anchor)** | §Q4 target 1 | `navMultiAnchorForm` / `navMultiAnchorForm_correct` | frozen: `… (h_past)(h_now)(h_fut : (rec sub).eval_at w' ↔ nf_eval_nf M k (n+1) (Fin.cons w' env) sub) : temporal_truth M atomMap (env 0) (navMultiAnchorForm rec env sub) ↔ ∃ w', nf_eval_nf …` (Base.lean:1831) | **UNBUILT — docstring code-block only, no def in tree** |
| single-point UNCONDITIONAL refutation | §Q4 | `endCharN0_correct_infeasible` | `¬ ∃ base, ∀ …, (base qnf).eval_at (env 0) ↔ nf_eval_nf …` (Base.lean:1779) | GREEN refutation (unconditional only) |
| **Downstream consumer** | main thm | `nf_nvar_exist_all_depths` | `→ ∃ (A : **Formula**), ∀ M (h_UZ : semantic_prior_UZ)(h_SZ : semantic_prior_SZ)(t), temporal_truth M atomMap t A ↔ ∃ env, nf_eval_nf M k (n+1) (insertEnv env t) sub_nf`; **n=1 arm = `sorry` (KampPrior.lean:361)**, retired by task 309 P14 consuming the task-348 bracket theorem above | closed **Formula** under Prior; sorry wired to C′ family |
| Downstream arity-1 char (charF) | Def 4.1 | `nf_characterizable_temporal_prior` | `(nf : NormalForm sig k 1) : {A : Formula // … under h_UZ/h_SZ … ↔ nf_eval_nf M k 1 (fun _=>t) nf}` (KampPrior.lean:407) | GREEN, requires Prior hyps |

### The three carrier families (disambiguation)

Report 08 conflates two distinct green lineages. There are **three** carrier types:

1. **`EndCharCarrier sig k = NormalForm sig k 3 → TemporalPred`** (Base.lean:1007) — single-point navigated, closed-formula. Base `endChar0` GREEN (conditional on `h_res`); **step `navMultiAnchorForm` UNBUILT**; assembly `endCharRec`/`endCharRec_correct` UNBUILT (Base.lean:1856–1870). This is the ORIGINAL 309 design and the lineage **option D actually consumes**.
2. **`BracketEndCharCarrierV sig k = NormalForm sig k 3 → VVecEA2`** (CarrierK1V.lean:365) — witness-growing syntactic bracket. **This is the CURRENT frozen v6 `endInterval` codomain.** k=1 green (`bracketEndChar_k1v`), **k=2 green** (`bracketEndChar_kvE2Ext`). This is the **C′** lineage.
3. **Option D re-type** — change (2)'s codomain to a Prop-valued interval predicate (e.g. reuse `nf_zone_flatten_navigable`, itself Prop but carrying TemporalPred hooks internally).

**Faithful generalization of the green k=1 template `bracketEndChar_k1v` is C′, not D.** `bracketEndChar_k1v` IS a `VVecEA2` assembled from closed point types via `bracketFromLists`; its k+1 generalization is definitionally the `charF`/provider bracket = C′ (`bracketEndChar_kvE2Ext` is literally that object at k=2). D belongs to a **different** lineage (family 1) and reuses **none** of `bracketEndChar_k1v`'s ~1000 lines of sound/complete proof.

## Q1 — Concrete `endIntervalStep` + proof skeletons, and where each gets stuck

### Option D — Prop-valued re-type

**`endIntervalStep` (Prop):**
```
carrierD k qnf M x t : Prop := nf_zone_flatten_navigable M atomMap x t (pastEnd k) (futureEnd k) qnf
-- step k→k+1: given rec = carrierD k, build carrierD (k+1) by
--   (a) Step A: rewrite the depth-(k+1) quant layer via endCharStep_quant_reduceA → nfEvalRHS;
--   (b) reduce arity-4 subs via nfEval_le2_reduction (task 351);
--   (c) Step B: apply nf_zone_flatten_navigable_correct to navigate the OUTER ∃ w.
```
**Soundness/completeness skeleton:** both directions are the single biconditional `nf_zone_flatten_navigable_correct` — **provided its two hook hypotheses `h_past`/`h_fut` are discharged.**

**WHERE IT GETS STUCK (the wall):** `nf_zone_flatten_navigable_correct` demands `pastEnd futureEnd : NormalForm sig (k+1) 3 → TemporalPred` (single-point, closed) and `h_past/h_fut : (pastEnd q).eval_at w ↔ nf_eval_nf M (k+1) 3 (zoneEnv3 w x t) q` for exterior `w`. At depth `k+1` this discharge — a single navigated `.eval_at w` certifying the FULL arity-3 anchor-predicate layer by navigation — **is exactly `navMultiAnchorForm_correct`, which is UNBUILT** (Base.lean:1831, no def in tree; `endCharN0_correct_infeasible` shows the *unconditional* version is even false, so the discharge is genuinely hard, not clerical). Threading `rec : … → Prop` into a `TemporalPred` hook slot is additionally a **type mismatch** — the Prop carrier is two-anchor, the hook is single-point navigable. **Report 08's claim that D "composes rec (Prop) through Step A + Step B" silently skips the hook-construction, which is the entire mathematical difficulty of task 349.**

### Option C′ — syntactic `VVecEA2` under Prior (keeps the frozen v6 codomain)

**`endIntervalStep` (`VVecEA2`):** generalize `bracketEndChar_k1v` (CarrierK1V.lean:433) to arbitrary k; the k=2 instance is already written as `bracketEndChar_kvE2Ext` (ExteriorBracket.lean:661). Point types come from a depth-`k` provider `P : ExistProviders sig atomMap 1` (`P.existF : NormalForm sig k (n+1) → Formula`, PriorInterface.lean:40) plus the depth-0 `nf_depth0_char_formula`; interior realization rides witness slots; exterior residue via `bracketEndChar_kvE2{Past,Fut}`.

**Soundness/completeness skeleton:** generalize `bracketEndChar_k1v_sound`/`_complete`; the k=2 template is `bracketEndChar_kvE2_sound_two_prior_frag` + `bracketEndChar_kvE2Ext_holds_iff`, assembled in `bracketEndChar_kvE2Ext_correct_two_prior_frag` (ExteriorBracket.lean:1069, **green**). Conclusion at k=2 is **verbatim** the `EndIntervalCorrect` biconditional under `h_UZ/h_SZ`.

**WHERE IT GETS STUCK (the wall):** the k=2 green theorem threads the interior-realization obligations `hfrag`/`hrealI`/`hrealB`/`hexcl` (ExteriorBracket.lean:1083–1102) as **hypotheses on a provider `P`**. The general k→k+1 recursion must **discharge these from the IH** at every depth, and must show the Def-4.1 fold is **sound under Prior at general k** (the F1 concern). Only the k=2 *gate* biconditional is landed; the general-k provider-discharge recursion is unbuilt. This is the residual risk — but it is *localized* and has a green witness one depth up from the k=1 template.

## Q2 — Least new machinery vs the green `bracketEndChar_k1v` proof structure

**C′ reuses the green k=1 template directly (same family, same `bracketFromLists`/`VVecEA2` sound-complete shape) and already has a green k=2 instance.** New lemmas for C′:
- add `semantic_prior_UZ/SZ` (+ order bits) to `EndIntervalCorrect` — a **bounded `/revise`** of the frozen statement; **codomain unchanged** (stays `VVecEA2`).
- general-k `endIntervalStep` body = arity-generalize `bracketEndChar_kvE2Ext` (k=2 template exists).
- general-k sound/complete = arity-generalize `bracketEndChar_kvE2Ext_correct_two_prior_frag`.
- provider-discharge recursion: instantiate `ExistProviders` from the depth-k IH (mutual with `nf_nvar_exist_all_depths`/`nf_characterizable_temporal_prior`). **Bounded/feasible** — provider interface already factored, k=2 discharged.
- resolve general-k F1-under-Prior (check `nf_quant_layer_fold_iff`, NfEFold:391). **Feasible; k=2 is empirical evidence it holds.**

**D reuses none of `bracketEndChar_k1v`.** New lemmas for D:
- `navMultiAnchorForm` **def** + `navMultiAnchorForm_correct` (**UNBUILT, the hard navigate-to-anchor lemma**).
- `endCharRec` + `endCharRec_correct` k-induction assembly (UNBUILT, Base.lean:1856–1870).
- re-type codomain of `BracketEndCharCarrierV`; restate `EndIntervalCorrect`.
- a **boundary Formula-emitter** for 350/309 (see Q3).

Net: **C′ = smaller diff, more reuse, one green depth higher; D = larger diff, reuses a different lineage, bottoms on an unbuilt hard core.**

## Q3 — Downstream interface: is D's Prop output sufficient for 350/309?

**No.** `nf_nvar_exist_all_depths` (KampPrior.lean:212) delivers a **closed `Formula` `A`** under `semantic_prior_UZ`/`semantic_prior_SZ`: `temporal_truth M atomMap t A ↔ ∃ env, nf_eval_nf …`. Its **n=1 arm is the live `sorry` at KampPrior.lean:361**, and the task-348 transfer note (KampPrior.lean:352–360) states that sorry is retired (task 309 Phase 14) by **consuming `bracketEndChar_kvE2Ext_correct_two_prior_frag`** — i.e., the downstream is *already wired to the `VVecEA2`-bracket-under-Prior codomain* = the **C′ family**, threading `h_UZ`/`h_SZ`.

Consequences:
- **The Prior hypotheses are NOT a new burden for C′** — `nf_nvar_exist_all_depths` and `nf_characterizable_temporal_prior` already require `semantic_prior_UZ/SZ` at the interface. D's "unconditionality" (no Prior hyps) buys **nothing** downstream, since the interface carries them regardless.
- **D would mismatch the wiring.** A Prop-valued `endInterval` cannot be handed to KampPrior:361 directly; D must add a **Prop→Formula boundary emitter**. The ≤1-free collapse for D lands at `nf_characterizable_temporal_prior` (arity-**1**) at the 350/309 boundary — but 349's content is arity-**3**, so the collapse is non-trivial and is **exactly where D re-meets `charF`**. D therefore does not escape `charF`/F1 globally; it relocates the emission to a boundary that is **not currently plumbed for it**, and the arity-3→arity-1 collapse at that boundary is itself unbuilt.
- **C′ delivers what 350/309 consume, directly.** Its `VVecEA2.holds ↔ ∃ w, nf_eval_nf` under Prior is the object KampPrior:361 already imports via task 348.

## Q4 — Phase count + risk

| | Option C′ (recommended) | Option D |
|---|---|---|
| Codomain change | none (keep frozen v6 `VVecEA2`) | re-type + restate `EndIntervalCorrect` |
| New hard core lemma | none unbuilt from scratch (k=2 green template exists) | **`navMultiAnchorForm(_correct)` — UNBUILT** |
| Green starting depth | **k=2** (`bracketEndChar_kvE2Ext_correct_two_prior_frag`) | k=0 base only; k=1 via a still-unbuilt hook |
| Prior hyps | add to `EndIntervalCorrect` (bounded /revise); free downstream | none, but downstream needs them anyway |
| Downstream match | **direct** (KampPrior:361 already wired to it) | requires new Prop→Formula boundary emitter |
| Est. phases | **~4–6** (revise stmt; general-k step body; general-k sound/complete; provider-discharge recursion; k-induction; wire KampPrior:361) | **~6–9** (retype; restate; build navMultiAnchorForm def+proof; endCharRec assembly; k-induction; boundary emitter) |
| Residual risk | **MEDIUM** — general-k provider discharge + general-k F1-under-Prior soundness (k=2 green de-risks; localized) | **HIGH** — navMultiAnchorForm is the historically-deferred hard lemma across v3→v6 churn; codomain/interface mismatch adds a whole extra sub-problem |

## Recommendation

**Pursue C′.** Keep the frozen v6 `VVecEA2` codomain; do a **bounded `/revise`** of `EndIntervalCorrect` to add `semantic_prior_UZ`/`semantic_prior_SZ` (+ the six order bits already present) exactly as `bracketEndChar_kvE2Ext_correct_two_prior_frag` carries them; fill `endIntervalStep` by arity-generalizing the **green k=2** `bracketEndChar_kvE2Ext`; discharge the interior providers via the IH (mutual with `nf_nvar_exist_all_depths`). This reuses the green k=1 template's proof structure, has a **machine-checked k=2 witness**, and lands the exact object that KampPrior:361 (task 309 Phase 14) already consumes.

**Do not pursue D** as primary: its recursion step reduces (via green Step A/B) only to the **unbuilt** `navMultiAnchorForm`, its Prop codomain mismatches the downstream Formula-under-Prior interface, and its sole theoretical advantage (F1-avoidance / unconditionality) is nullified because (i) the interface carries Prior hyps anyway and (ii) the k=2 green artifact shows F1 does not bite under Prior.

**On report 08's UNRESOLVED CONTRADICTION (08:140):** the "resolving check not yet performed" — whether the fold-fiber determines quant-layer semantics on Prior structures — is now answered *affirmatively at k=2 by a machine-checked, sorry-free theorem*. That evidence removes the only reason report 08 demoted C′ below D.

## Adversarial Self-Verification (H4)

### Claim Verification Table

| Claim | Source / Counterexample | Verification Method | Confidence |
|---|---|---|---|
| `navMultiAnchorForm(_correct)` is UNBUILT (D's core) | Base.lean:1831 inside ```-fenced docstring; `grep '^noncomputable def navMultiAnchorForm\|^theorem navMultiAnchorForm'` → 0 real defs | source read + grep | High |
| Step B hooks are single-point `TemporalPred`; `_correct` needs `.eval_at w` discharge | Base.lean:667–706 (`pastEnd futureEnd : … → TemporalPred`, `h_past/h_fut`) | lean_hover-equivalent direct type read | High |
| k=2 C′ instance is green + sorry-free, concludes `EndIntervalCorrect` shape under Prior | ExteriorBracket.lean:1069–1104; `grep -c sorry` ExteriorBracket = 0 | source read + sorry grep | High |
| Downstream needs a closed **Formula** under `semantic_prior_UZ/SZ` | KampPrior.lean:212–223, 407–418 | direct type read | High |
| KampPrior:361 n=1 sorry is wired to the task-348 bracket-under-Prior theorem | KampPrior.lean:352–361 transfer note | source read | High |
| Frozen v6 codomain is `VVecEA2` (= C′ family), `endIntervalStep` = `⟨[]⟩` hole | CarrierK1V.lean:365, 2144–2150 | source read | High |
| F1 (`bracketEndChar_kv_factors`) refutes only the *unconditional* charF carrier, not Prior-guarded | CarrierKv.lean:422 (per report 08:41); **k=2 Prior theorem is green** | cross-check: report 08 + green k=2 artifact | Medium-High |
| C′ general-k provider discharge + general-k fold-soundness are unproven | only k=2 gate landed; hfrag/hrealI/hrealB/hexcl are hypotheses (ExteriorBracket.lean:1083–1102) | source read | High |

### Contradiction Log
- **Resolved (precedence: machine-checked artifact > docstring > plan/report narrative).** Reports 06/07/08 treat the syntactic charF/`VVecEA2` route as F1-endangered and prefer D. The machine-checked `bracketEndChar_kvE2Ext_correct_two_prior_frag` (green, k=2, under Prior) is a **stronger, higher-precedence artifact** than the narrative caution and shows the Prior-guarded route is sound at k=2. Resolution: **prefer C′.** This is a deliberate, evidence-backed inversion of report 08's primary recommendation, not an oversight.

### The wall C′ WILL hit (steelmanned)
The k=2 theorem discharges the *gate* biconditional but **leaves `hfrag`/`hrealI`/`hrealB`/`hexcl` as provider hypotheses**. C′'s completion requires a general-k recursion that (a) instantiates `ExistProviders` from the depth-k IH — a **mutual recursion** between 349's carrier and `nf_nvar_exist_all_depths`/`nf_characterizable_temporal_prior`, whose termination/well-foundedness must typecheck; and (b) proves the Def-4.1 fold is Prior-sound at **general** depth, not just k≤2. If `nf_quant_layer_fold_iff` (NfEFold:391) fails to give fold-fiber determinacy uniformly in k, the recursion stalls exactly at the F1 boundary report 08 feared — the k=2 green would then be a lucky low-depth coincidence rather than a general pattern. **This is the single check to run before committing C′ to a full plan.** Even so, C′'s wall is *localized and instrumented* (one determinacy lemma, green k=2 witness), whereas D's wall is a *fully unbuilt hard lemma plus an interface mismatch* — so C′ remains the lower-risk path.

### Recommendations modified after verification
Initial framing (following report 08) leaned D-primary "to avoid F1." Adversarial review **promoted C′ to primary** on the strength of the green k=2 artifact and the downstream wiring, and reframed D's F1-avoidance as **downstream-irrelevant** (Prior hyps present at the interface regardless) and **incomplete** (bottoms on unbuilt `navMultiAnchorForm`). No claim rests on `liftInterval` (report 08's B-infeasibility stands).
