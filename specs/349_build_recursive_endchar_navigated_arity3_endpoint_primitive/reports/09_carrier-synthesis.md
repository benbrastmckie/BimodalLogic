# Report 09 — Carrier Decision Synthesis (task 349, v7 input)

**Task**: 349 — build recursive `endChar`/`endInterval` (navigated arity-3 endpoint primitive)
**Role**: DECISIVE SYNTHESIS of the 5-report research team (09 teammates A/B/C/D + boneyard audit)
**Mode**: lean-research-hard (H2/H3/H4/H5), `--lit`. Reference tier: **Tier 1** (Rabinovich 2014 + live Lean types)
**Session**: sess_1783841542_df767b | Read-only; all verdicts carry file:line / statement evidence.

---

## 0. THE DECISION (up front)

**Adopt the enriched-segment bracket carrier `bracketEndChar_kvE2Ext` family (carrier 3).**
Keep the frozen v6 codomain `BracketEndCharCarrierV sig k := NormalForm sig k 3 → VVecEA2`
(CarrierK1V.lean:365); fill the Phase-3 hole `endIntervalStep` (CarrierK1V.lean:2144) by
generalizing the **green k=2** `bracketEndChar_kvE2Ext` to symbolic `k`; do a bounded `/revise`
of `EndIntervalCorrect` (CarrierK1V.lean:2179) to add `semantic_prior_UZ/SZ` + the provider
obligations exactly as `bracketEndChar_kvE2Ext_correct_two_prior_frag` (ExteriorBracket.lean:1069)
carries them.

**This resolves the apparent A/B/C-vs-D conflict as a three-carrier confusion, not a real
disagreement.** The reconciliation (fully evidenced in §1–§2):

- **Carrier 2** (`bracketEndChar_kv` / `kv_body`): **DEAD** — machine-refuted by
  `f2_relativized_refutation` (RefutationF2.lean:859) on a genuine Prior model, for *every*
  provider `charF`. All five reports agree. Do not resurrect.
- **Pure Prop-valued D** (`EndCharCarrier = NormalForm sig k 3 → TemporalPred`, navigated): equally
  **faithful** but **less completable** — its recursion core `navMultiAnchorForm(_correct)` is
  **UNBUILT** (docstring skeleton only, Base.lean:1831/1957/1969), its unconditional single-point
  cousin is **provably false** (`endCharN0_correct_infeasible`, Base.lean:1779), and its Prop output
  **mismatches** the downstream `Formula`-under-Prior interface (KampPrior.lean:361).
- **Carrier 3** (`bracketEndChar_kvE2Ext`, enriched): **faithful AND maximally completable.** It is
  *the* object teammate C named as "the genuinely faithful closed-formula carrier" (`bracketEndChar_kvE`)
  but did not evaluate; teammate D's machine-checked **green k=2** witness; it is **NOT** the F2-refuted
  object (Q1); it keeps interior content at **full arity 4** (Q2, faithful by A/B/C's own criterion);
  and it is **already wired downstream** (KampPrior.lean:352-361, task 309 Phase 14).

**Why this satisfies "faithfulness AND completeness, no corners":** carrier 3 is the *unique* option
that is simultaneously (a) paper-faithful — A, B, C, and D are all consistent with it once carrier 2
and carrier 3 are separated — and (b) the shortest completable path with a green anchor and live
downstream wiring. Pure-D would be equally faithful but strictly less completable; carrier 2 fails
faithfulness *and* is refuted. No corner is cut by choosing carrier 3 over pure-D — they are equally
faithful, and carrier 3 dominates on completability.

**The one honest reservation (do not overstate):** **Q3 — uniform-`k` generalization — is UNRESOLVED.**
Only k=2 is green; the symbolic-`k` enriched carrier was previously *quarantined* and never proved
(§Q3). The green k=2 witness *de-risks* but does not *settle* it. This risk is bounded and isolated to
one phase (§3), and — critically — the F1/F2 refutation mechanism **cannot** bite carrier 3 (it never
projects through `nfk_projFresh`), so carrier 3 is not *known to fail* at k≥3, merely *not yet proved*.
That is a materially better position than pure-D, whose core is a genuine unbuilt frontier with a
provably-false neighbor.

---

## 1. Reconciliation: the three carriers, cleanly separated

Teammate D's central contribution is the disambiguation the other three reports blur. There are
**three** carrier types, not two:

| # | Carrier | Lean type | Live status | Refuted? |
|---|---------|-----------|-------------|----------|
| 1 | **Pure Prop-valued D** (navigated) | `EndCharCarrier sig k = NormalForm sig k 3 → TemporalPred` (Base.lean:1007) | base `endChar0` green (cond. `h_res`); **step `navMultiAnchorForm` UNBUILT**; `endCharRec` UNBUILT | not refuted, but core unbuilt; single-point cousin `endCharN0_correct_infeasible` provably FALSE |
| 2 | **`kv_body` C′** | `bracketEndChar_kv … charF k : BracketEndCharCarrierV sig k` (CarrierKv.lean:238) | green carrier | **REFUTED** — `f2_relativized_refutation` (RefutationF2.lean:859), ∀ `charF`, on a Prior model |
| 3 | **Enriched `kvE2Ext`** | `bracketEndChar_kvE2Ext … P : BracketEndCharCarrierV sig 2` (ExteriorBracket.lean:661); general-k body `kvE_body` | **green at k=2** (`_correct_two_prior_frag`:1069, sorry-free); **general-k UNBUILT** | **NOT refuted** — F2 targets carrier 2 only; F2's own record names `kvE` as the repair |

**How each teammate maps onto this taxonomy:**

- **Teammate A** ("Prop-valued D most faithful"): A's load-bearing criterion is the *two-endpoint
  discipline* + *bounded-∃ / Lemma 7.6 adjacency composition* (§2, Fig. 1, Lemma 7.6). A's only
  objection to the syntactic `VVecEA2` carrier was that v6 realized composition through the arity-`m`
  `VVecEA_m.liftInterval` family instead of the paper's immediate `m→2` ∃-collapse. **Carrier 3
  composes exactly by Lemma 7.6 adjacency** — `bracketEndChar_kvE2Ext_holds_iff` (ExteriorBracket.lean:674)
  destructures "the degenerate Lemma 7.6 conjunction" (the two adjacent exterior brackets conjoined at
  the anchor), *not* `liftInterval`. So A's composition objection is **answered** by carrier 3; A's
  faithfulness verdict applies to carrier 3.
- **Teammate B** ("completeness favors D"): B's mechanism is relation-preservation (interior
  sub-content threaded from the IH, never an arity-1 single-point projection). B **explicitly concedes**
  (honest counter-weight, lines 214-218): "closed-formula interiors are NOT intrinsically unfaithful …
  E[Σ] closed interior atoms are paper-legitimate … If the team confirms F1-does-not-bite-under-Prior,
  C′ is *also* viable and retains the syntactic `VVecEA2` codomain preferred by downstream 309/350."
  Carrier 3 is precisely the case where F1/F2 does not bite. B's verdict is **consistent** with carrier 3.
- **Teammate C** ("kv_body machine-refuted DEAD"): C is *right* about carrier 2 and *explicitly names
  carrier 3 as the faithful alternative* — Q4, lines 136-137: "a faithful closed-formula interior would
  require the enriched-segment bracket (the v6 `bracketEndChar_kvE` per-sub enriched carrier,
  RefutationF2.lean:947)." C defaulted to Prop-valued D **only** because C believed `kvE` was "unbuilt."
  Teammate D supplies the missing fact: the k=2 instance **is** built and green.
- **Teammate D** ("enriched `kvE2Ext` green at k=2; pure-D's `navMultiAnchorForm` unbuilt;
  downstream wants a Formula"): correct on all three, verified below.
- **Boneyard audit**: confirms D needs zero restores and the carrier-decision is not gated by any
  `Kamp/Boneyard/` restore. (It did NOT audit `Boneyard/MergedBracketQuarantine/`, which holds the
  quarantined general-`k` enriched carrier — see §Q3 and §3.)

**Net:** every teammate's *faithfulness* judgment is satisfied by carrier 3; the only genuine
disagreement was C/others believing the faithful enriched route was unbuilt, which D refutes at k=2.

---

## 2. Claim Verification Table (Q1–Q5)

Verification method for lean4 claims = direct statement/type read at file:line (the source is the
authority; `lean_verify` on a cold LSP returns empty here — inconclusive, not contradicting — matching
teammate C's finding). Whole-project build is green at HEAD (git: `task 351 phase 6 … ACCEPTANCE MET`);
ExteriorBracket.lean and RefutationF2.lean are sorry-free (grep, non-comment lines).

| Q | Claim | Evidence (file:line / statement) | Verdict | Confidence |
|---|-------|----------------------------------|---------|:----------:|
| **Q1** | F2 refutes **only** `kv_body` (carrier 2), **not** enriched `kvE2Ext` (carrier 3) | `f2_relativized_refutation` (RefutationF2.lean:859) quantifies over `(bracketEndChar_kv f2atomMap f2surj charF 2 qnf).holds` (**line 871**); its docstring (855-858) says "for the CURRENT carrier `bracketEndChar_kv`"; its own verdict record (**947-948**): "The repair remains the v6 per-sub enriched carrier (`bracketEndChar_kvE`)". `kvE2Ext` never appears in F2. | **CONFIRMED** — carrier 3 survives F2 | High |
| **Q2** | `kvE2Ext` is **faithful** (enriched, keeps joint content; does NOT collapse to arity-1) | `bracketEndChar_kvE2Ext_correct_two_prior_frag` interior obligations `hrealI`/`hrealB`/`hexcl` (ExteriorBracket.lean:1084-1102) are stated at **`nf_eval_nf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _=>t)))) σ`** — full arity 4, no `nfk_projFresh` projection; composition via Lemma 7.6 adjacency (`_holds_iff`:674, "degenerate Lemma 7.6 conjunction"). Matches C Q4 ("enriched-segment carries joint content") + A's composition law. | **CONFIRMED** — faithful (relation-preserving, adjacency composition) | High |
| **Q3** | Green k=2 generalizes **uniformly in k** | `nf_quant_layer_fold_iff` (NfEFold:391) is general in **arity `n`** but **depth-0 subs ONLY** (D7, NfEFold:373-374: "claimed ONLY at depth-0 subs (k=1); NO depth-`k` … stated"). Live tree has **only k=2** (`kvE2Ext`); the symbolic-`k` enriched carrier `bracketEndChar_kvE {k}` exists **only** in `Boneyard/MergedBracketQuarantine` behind `#exit` (never proved; Phase 13.4 "symbolic k" never landed). k=2 gate threads 4 provider obligations as **hypotheses**, not IH-discharged. | **UNRESOLVED** — see §Q3 + §5 | Medium (leaning feasible; NOT proved) |
| **Q4** | Downstream requires a **closed `Formula`** (favoring carrier 3), consumes `kvE2Ext` | `nf_nvar_exist_all_depths` (KampPrior.lean:212) returns `∃ (A : Formula), … temporal_truth M atomMap t A ↔ ∃ env, nf_eval_nf …` under `semantic_prior_UZ/SZ`; **n=1 arm = live `sorry` at KampPrior.lean:361**; transfer note (352-360): retired by task 309 Phase 14 **consuming `bracketEndChar_kvE2Ext_correct_two_prior_frag`**. A Prop-valued D output cannot be handed here without a new Prop→Formula emitter. | **CONFIRMED** — closed Formula required; wired to carrier 3 | High |
| **Q5** | Pure-D's `navMultiAnchorForm` is genuinely **unbuilt**, and carrier 3 **avoids** it | `navMultiAnchorForm`/`navMultiAnchorForm_correct` (Base.lean:1831) + second `endCharRec`/`endCharRec_correct` (1957/1969) are inside ```-fenced **skeleton blocks** in `/-! -/` docstrings — no real `def navMultiAnchorForm` in the tree (grep: only `atomPartN`, `nf_endpoint_tl_gen(_correct)` are real). Carrier 3 is the `VVecEA2`/`bracketFromLists`+`ExistProviders` lineage — it never touches `navMultiAnchorForm` (which belongs to family 1). | **CONFIRMED** — unbuilt; avoided by carrier 3 | High |

**Contradiction Log.** No unresolved contradiction *among the reports* after the three-carrier
separation. The one apparent A/B/C-vs-D inversion (D "inverts A/B/C") is resolved by precedence
**machine-checked artifact > report narrative**: D's green k=2 `kvE2Ext` + the F2 record's own
"repair = kvE" line show A/B/C's faithful "D" and D's completable "kvE2Ext" are the **same faithful
family**, differing only in whether the codomain is Prop (`TemporalPred`) or syntactic (`VVecEA2`).
On the codomain tiebreak, **completability + downstream wiring decide for the syntactic `VVecEA2`
enriched carrier** — Q4/Q5 evidence.

---

## Q3 — the load-bearing UNRESOLVED question (stated plainly)

**Does the k=2 green enriched gate generalize uniformly in `k`, or is it a low-depth coincidence?**

**What is proved:** exactly one depth. `bracketEndChar_kvE2Ext_correct_two_prior_frag`
(ExteriorBracket.lean:1069) is the k=2 gate biconditional, sorry-free, under Prior — but it threads
`hfrag`/`hrealI`/`hrealB`/`hexcl` as **provider hypotheses** (lines 1083-1102), not yet discharged
from an actual IH even at k=2.

**What is NOT proved:**
1. A symbolic-`k` `endIntervalStep` body. The general-`k` enriched carrier `bracketEndChar_kvE {k}
   (P : ExistProviders sig atomMap k) : BracketEndCharCarrierV sig (k+1)` exists **only** in
   `Theories/Bimodal/Boneyard/MergedBracketQuarantine/MergedBracketQuarantine.lean:269`, behind a
   file-level `#exit` (does not compile), tagged both "per-sub enriched successor-depth carrier
   (Phase 13.2)" *and* — in the file header — "Refuted merged-bracket route." Its correctness at
   symbolic `k` (that file's "Phase 13.4") **never landed**; only the k=2 GO gate (Phase 13.3) was
   extracted to the live tree as `kvE2Ext`.
2. Uniform fold-determinacy for the enriched channel. `nf_quant_layer_fold_iff` (NfEFold:391) gives
   determinacy **only at depth-0 subs**; the general-`k` provider-discharge is deferred to "309-R3
   inside-out iteration" (NfEFold:388-389) which is unbuilt.

**Why the risk is bounded (not equivalent to pure-D's wall):** F1/F2 refute carriers that read `qnf.2`
through the arity-1 projection `nfk_projFresh`. Carrier 3 **does not project** (Q2: full arity-4
obligations), so the refutation mechanism provably does not apply to it — carrier 3 is *unproven at
k≥3*, not *disproven*. Pure-D's `navMultiAnchorForm`, by contrast, is unbuilt **and** its unconditional
single-point cousin is a machine-checked non-theorem (`endCharN0_correct_infeasible`, Base.lean:1779).

**The one bounded probe that would settle Q3** (recommended as v7 Phase 1, before committing the full
plan): attempt the symbolic-`k` `endIntervalStep` body = `kvE_body` with depth-`k` providers, and
attempt to **discharge `hrealI`/`hrealB`/`hexcl` from the depth-`k` IH** (mutual with
`nf_nvar_exist_all_depths` / `nf_characterizable_temporal_prior`). Success at the induction step —
specifically, that the arity-4 interior realization obligations follow from the depth-`k` provider IH
uniformly — confirms carrier 3 completes; failure localizes the exact obstruction one depth above the
green k=2. This is a single, instrumented probe with a green k=2 template to imitate.

---

## 3. v7 architecture (concrete)

### 3.1 Carrier type + correctness statement

```lean
-- UNCHANGED frozen v6 codomain (CarrierK1V.lean:365):
--   BracketEndCharCarrierV sig k := NormalForm sig k 3 → VVecEA2

-- Fill the Phase-3 hole (currently ⟨[]⟩ at CarrierK1V.lean:2144):
noncomputable def endIntervalStep {sig} (atomMap) (h_surj)
    {k : Nat} (rec : BracketEndCharCarrierV sig k)      -- the depth-k IH carrier
    : BracketEndCharCarrierV sig (k+1) := …             -- = kvE_body pattern, providers from `rec`

-- endInterval via Nat.rec (CarrierK1V.lean:2159), step = endIntervalStep. UNCHANGED shape.

-- BOUNDED /revise of EndIntervalCorrect (CarrierK1V.lean:2179) to the Prior-guarded shape,
-- VERBATIM from bracketEndChar_kvE2Ext_correct_two_prior_frag (ExteriorBracket.lean:1069):
def EndIntervalCorrectPrior … (P : ExistProviders sig atomMap 1) (M) (h_UZ) (h_SZ) (x t)
    (hfrag)(hrealI)(hrealB)(hexcl)(six order bits) :
    (endInterval atomMap h_surj k qnf).holds M atomMap x t ↔
      ∃ w, nf_eval_nf M k 3 (Fin.cons w (Fin.cons x (fun _=>t))) qnf
```

### 3.2 Recursion step construction

`endIntervalStep k` = the `kvE_body` per-sub enriched body (interior point types via a depth-`k`
provider `P.existF 0`, interior segment realization via `P.existF 3` at **full arity 4**, exterior
residue via the two adjacent `kvE2_extBracket{Past,Fut}` brackets conjoined at the anchor — Lemma 7.6
adjacency). The k=2 realization is `bracketEndChar_kvE2Ext` (ExteriorBracket.lean:661); the step
generalizes its provider arities from the frozen k=2 to symbolic `k`.

### 3.3 Green assets consumed by name (all live, sorry-free)

- `bracketEndChar_kvE2Ext` (:661), `_holds_iff` (:674), **`_correct_two_prior_frag` (:1069)** — k=2 template.
- `bracketEndChar_kvE2` (OuterGate.lean:70), `_complete_two_prior` (:147), `_sound_two_prior_frag` (:268),
  `_correct_two_prior_frag` (:359) — interior gate soundness/completeness.
- `kvE2_extBracketPast/Fut_sound`/`_complete` — per-side exterior bracket discharge.
- `bracketEndChar_k1v` family (CarrierK1V.lean:433) — k=1 base of the `Nat.rec`.
- `ExistProviders` / `existF` (PriorInterface.lean:38-40) — provider interface.
- `nf_nvar_exist_all_depths` (KampPrior.lean:212), `nf_characterizable_temporal_prior` (KampPrior.lean:407)
  — the mutual-recursion downstream partners providing the depth-`k` interior characterizations.
- `nf_quant_layer_fold_iff` (NfEFold:391) — the depth-0 innermost fold, applied inside-out.

### 3.4 NEW lemmas needed (with feasibility)

| New lemma | Role | Feasibility |
|-----------|------|-------------|
| `endIntervalStep` general-`k` body | the recursion step | **Bounded** — k=2 body `kvE2Ext` exists; generalize provider arities |
| general-`k` `EndIntervalCorrectPrior` sound/complete | step correctness | **Medium** — generalize `kvE2Ext_correct_two_prior_frag`; **this is the Q3 risk** |
| provider-discharge recursion (instantiate `ExistProviders` from depth-`k` IH) | mutual with `nf_nvar_exist_all_depths` | **Medium** — interface factored; termination/well-foundedness must typecheck |
| general-`k` enriched fold-determinacy | discharge `hrealI`/`hrealB`/`hexcl` uniformly | **UNRESOLVED (Q3)** — the one genuine frontier; isolate to its own phase |
| wire `KampPrior.lean:361` | retire the n=1 `sorry` | **Bounded** — transfer note already specifies it (task 309 Phase 14) |

### 3.5 Phase breakdown (≤500 lines each; k-generalization risk isolated)

1. **Phase 1 — Q3 PROBE (gate).** Symbolic-`k` `endIntervalStep` body + attempt IH-discharge of
   `hrealI`/`hrealB`/`hexcl` at the induction step. **GO/NO-GO on uniform-`k`.** (~200-400 lines.)
   If NO-GO: stop, report the exact obstruction depth; do not proceed.
2. **Phase 2 — bounded `/revise` of `EndIntervalCorrect`** to `EndIntervalCorrectPrior` (add
   `semantic_prior_UZ/SZ` + provider obligations; codomain UNCHANGED). (~100 lines, statement-only.)
3. **Phase 3 — general-`k` step sound/complete**, generalizing `kvE2Ext_correct_two_prior_frag`,
   consuming Phase-1 discharge. (~300-500 lines.)
4. **Phase 4 — provider-discharge recursion** (mutual instantiation with `nf_nvar_exist_all_depths`);
   `Nat.rec` k-induction assembly of `endInterval`. (~300-500 lines.)
5. **Phase 5 — wire `KampPrior.lean:361`** (retire the n=1 `sorry` via task 309 Phase 14). (~100 lines.)
6. **Phase 6 — whole-project `lake build` + axiom audit** (`lean_verify` warm) on the assembled result.

The k-generalization risk is **fully isolated to Phase 1** and gates the rest.

---

## 4. Boneyard actions for the chosen carrier

| Action | Item | Rationale |
|--------|------|-----------|
| **RESTORE: none required** for the carrier | — | Carrier 3 (like pure-D) consumes only already-live green assets (`kvE2Ext`, `kvE2`, `k1v`, `ExistProviders`, KampPrior). Boneyard audit §3c confirms zero carrier restores. |
| **REFERENCE, do NOT blindly restore** | `Boneyard/MergedBracketQuarantine/MergedBracketQuarantine.lean` (`bracketEndChar_kvE {k}` :269, `kvE_body`, `kvE2_body`) | Holds the symbolic-`k` Phase-13.4 skeleton the v7 step must imitate — but it is `#exit`-archived and its header tags it "refuted merged-bracket route (bracket-whose-points-are-brackets)". Extract only the **faithful per-sub `kvE_body` pattern**; do not import the merged-bracket nesting. Verify each extracted piece against the live `kvE2Ext`. |
| **OPTIONAL RESTORE (downstream, not carrier)** | `RabinovichTranslation` (Prop 3.5 wrapper), `SeparationBridge` (¬U/¬S on Prior) — both `Kamp/Boneyard/`, cycle-safe | Per boneyard audit §3b: ergonomic for the FO→TL wrap that 350/309 consume; substances already live (`Translation.lean`, `NegationEquiv.lean`). Not on the carrier critical path. |
| **KEEP-ARCHIVED** | carrier 2 line (`kv_body`), single-point line (`NavigatedEndCharSinglePoint`), all 15 confirmed-dead `Kamp/Boneyard/` files | F2-refuted / non-theorem / superseded. |

---

## 5. Adversarial self-check — strongest case AGAINST carrier 3

Applying the H4 Claim Verification Bar to my own decision. The strongest arguments against carrier 3,
stated as forcefully as the evidence allows:

1. **Q3 is genuinely unproven, and a prior symbolic-`k` enriched attempt is quarantined.** The green
   evidence is *one depth* (k=2), and it is a **provider-conditional gate**, not an unconditional
   result — it *assumes* `hfrag`/`hrealI`/`hrealB`/`hexcl`. A prior general-`k` enriched carrier
   (`bracketEndChar_kvE {k}`) was built far enough to be quarantined behind `#exit` and never proved
   correct at symbolic `k`. If the arity-4 interior obligations do **not** follow uniformly from the
   depth-`k` IH, carrier 3 stalls exactly one depth above its green witness, and the k=2 green becomes
   a low-depth coincidence — the same failure shape (fiber non-determinacy) that killed carrier 2,
   merely relocated. **This is the real risk; it is why Phase 1 is a hard GO/NO-GO gate, not a warm-up.**
   *Rebuttal:* the F1/F2 mechanism cannot bite a carrier that keeps full arity (Q2), so carrier 3 is
   not *known to fail*; and the mutual-recursion partner `nf_nvar_exist_all_depths` is already the
   induction that supplies deeper interior characterizations — the scaffolding exists. But this is a
   *reason for optimism*, not a proof. Confidence on Q3 stays **Medium**.

2. **The result is Prior-conditional; the paper is not.** Teammate B established (16 pages, absence
   check) that Rabinovich/Kamp assumes **only Dedekind completeness** — there is no `semantic_prior_UZ/SZ`
   hypothesis anywhere. Carrier 3 bakes the Prior guard into `EndIntervalCorrectPrior`. Strictly, that
   is a departure from the paper's unconditional theorem — a "corner" on completeness.
   *Rebuttal:* the departure is **not introduced by carrier 3** — the downstream interface
   (`nf_nvar_exist_all_depths`, `nf_characterizable_temporal_prior`) *already* carries the Prior hyps
   (KampPrior.lean:212, 407), and pure-D would have to re-meet them at its Prop→Formula boundary anyway
   (D's "unconditionality" is downstream-void, per teammate D Q3). The Prior restriction is a standing
   project-wide condition, not a fresh corner cut by this decision. Still, the honest statement is:
   **v7 delivers Kamp-on-Prior-structures, which is what the whole `WeakCanonical/Kamp` tree targets —
   not the fully unconditional Kamp theorem.** If the user's "no corners on completeness" means the
   unconditional theorem, that is a *separate, larger* goal than task 349 and is not achievable by
   *any* of the three carriers as currently scaffolded.

3. **Pure-D might yet be the more faithful long-term object.** A/B rank Prop-valued D as *most*
   faithful to the recursion carrier (the paper manipulates the object semantically). Choosing the
   syntactic `VVecEA2` codomain privileges completability/downstream over that "most faithful" reading.
   *Rebuttal:* the paper's object is *nominally syntactic* (A §1.1, `md:219`: "abbreviation for the
   →∃∀-formula") and its *output* must be a syntactic TL formula (Prop 3.5). The syntactic `VVecEA2`
   carrier is therefore *at least as* paper-nominal as Prop-valued D, and it delivers the closed
   `Formula` the exit (Prop 3.5) and downstream both require without a second emitter. Faithfulness is
   a *tie* between carrier 3 and pure-D; completability breaks the tie decisively for carrier 3.

**Verdict after adversarial pass: UNCHANGED.** Carrier 3 is the decision. The single load-bearing
uncertainty (Q3) is disclosed, bounded, and isolated to a gating Phase 1 with a named probe. I do not
overstate: **carrier 3 is proved faithful and green at k=2, and is the uniquely dominant choice on
completability + downstream; its uniform-`k` completion is feasible-but-unproven and must be validated
by the Phase-1 probe before the full v7 plan is committed.**

---

## 6. One-paragraph handoff for `/revise`

Adopt **carrier 3** (`bracketEndChar_kvE2Ext` enriched family). Keep codomain
`BracketEndCharCarrierV sig k = NormalForm sig k 3 → VVecEA2`; fill `endIntervalStep`
(CarrierK1V.lean:2144) by generalizing the green k=2 `bracketEndChar_kvE2Ext`
(ExteriorBracket.lean:1069) to symbolic `k`; bounded-`/revise` `EndIntervalCorrect` → Prior-guarded
`EndIntervalCorrectPrior` matching the k=2 theorem's hypotheses. Carrier 2 (`kv_body`) is F2-dead;
pure-D is equally faithful but bottoms on the unbuilt `navMultiAnchorForm` and mismatches the
`Formula`-under-Prior downstream (KampPrior.lean:361). Restore nothing for the carrier; reference (do
not blindly restore) the quarantined `MergedBracketQuarantine` `kvE_body` for the symbolic-`k` pattern;
optionally restore `RabinovichTranslation`/`SeparationBridge` for the 350/309 FO→TL wrap. **Gate the
whole plan on a Phase-1 GO/NO-GO probe of uniform-`k` (Q3): discharge `hrealI`/`hrealB`/`hexcl` from
the depth-`k` IH (mutual with `nf_nvar_exist_all_depths`). Q3 is the sole UNRESOLVED load-bearing
question; k=2 is green, k≥3 is feasible-but-unproven.**
