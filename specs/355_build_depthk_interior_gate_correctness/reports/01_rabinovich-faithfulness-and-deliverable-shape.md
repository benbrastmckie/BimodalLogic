# Task 355 — Rabinovich Faithfulness & Deliverable-Shape Verification (Adversarial, H3+H4)

**Agent**: lean-research-hard-agent · **Mode**: adversarial faithfulness + consumer-acceptance
**Reference grounding tier**: Tier 1 (literature-backed — Rabinovich 2014)
**Scope**: READ-ONLY. No Lean/plan edits. Verdicts on Q1–Q4 with independent grounding.

---

## TL;DR (leads with the pivotal Q3)

- **Q3 (PIVOTAL) — REFUTED as the implementer stated it.** The task-349 consumer contract that
  `endIntervalStep` (CarrierK1V.lean:2144) must satisfy is **`EndIntervalCorrect`
  (CarrierK1V.lean:2179)**, and it is a **fully UNCONDITIONAL ∀-k biconditional** — it supplies
  **none** of the seven extra inputs (`P`, `hcharK`, `h_UZ`, `h_SZ`, `hreal`, `hexcl`, `hexclExt`)
  that the delivered `bracketEndChar_kv_step_correct` (InteriorGateGeneralK.lean:1165) requires.
  There is **no `def EndIntervalCorrectPrior` anywhere in the tree** (grep: 0 hits). So the
  delivered obligation-carrying shape does **not** drop into the frozen consumer as-is, and the
  implementer's "the consumer very likely supplies these obligations" is **not** borne out by the
  frozen signature. **However** the path forward is still option (a): the fix is a *two-sided*
  reshape (re-freeze BOTH the task-355 deliverable AND the task-349 consumer to the obligation-
  carrying shape), threading the obligations up to the KampPrior recursion where the providers/
  UZ/SZ actually live.
- **Q1 (Faithfulness) — CONFIRMED.** The division of labor (single bracket = Cor 5.4/Lemma 5.1;
  exterior residue `hexclExt` = Lemma 7.6 adjacency composition) is directly supported by the
  chunk text I read. The interior gate genuinely cannot dispatch an out-of-bracket witness; that
  is a separate lemma in the paper.
- **Q2 (F1-refutation) — CONFIRMED, with one calibration.** The obligation-FREE target is
  genuinely unprovable at k≥2. The information-blindness half is *machine-witnessed*
  (`bracketEndChar_kv_factors`, CarrierKv.lean:422, sorry-free). The "differing realizability
  exists at k≥2" half is a sound semantic argument but is **not** a landed counterexample theorem
  — so the precise status is "provably information-blind + unprovable through the only available
  channel," not "a landed `_refuted` theorem." Practical consequence is identical: no clean close.
- **Q4 (Recommendation) — `revise` (option a) for task 355**, re-freezing the DoD to the delivered
  `bracketEndChar_kv_step_correct` + base rungs. The general-k `hexclExt` discharge (option b) is a
  **genuinely separate** exterior-bracket-layer task (348/351/352/354 family), NOT part of task
  355's interior gate; spawn it only when the ∀-k Kamp close at KampPrior:351 needs it.

---

## Literature Proof Structure (Rabinovich 2014, chunks read independently)

I read chunk_0013, _0014, _0015 (§5, Lemma 5.1 / Lemma 5.3 / Cor 5.4) and chunk_0020, _0021,
_0022 (§7, Def 7.5 / Lemma 7.6 / Lemma 7.8) directly. Key structure:

1. **Single-bracket interior characterization (Lemma 5.1 / Cor 5.4).**
   Notation 5.2 (chunk_0013:53): the bracket `[α0, β1, …, αn−1, βn, αn](z0, z1)` is the
   forward-EA formula for a **single** interval `(z0, z1)`. Lemma 5.1 (chunk_0013:29–33): the
   *negation* of one bracket is a ∨forward-EA formula over Dedekind-complete chains. The engine is
   Lemma 5.3 (chunk_0014:3): `¬∃x1…∃xn (z0<x1<…<xn<z1) ∧ ⋀Pi(xi)` ≡ a ∨forward-EA formula `On`,
   built inductively with the **bounded interior existential** `(∃r0)^{<z1}_{>z0}[INF ∧ On(…)]`
   (chunk_0014:35). Cor 5.4 (chunk_0015:3–5): `¬(∃z)^{<z1}_{>z0}[…](z0, z)` ≡ ∨forward-EA — the
   witness `z` is **bounded strictly inside `(z0, z1)`** (`^{<z1}_{>z0}`).
   → This is the **interior gate**: everything happens **within the single bracket `[x, t]`**.

2. **Adjacent-bracket composition (Def 7.5 + Lemma 7.6).**
   Def 7.5 (chunk_0021:17) fixes the `(z0, z1)`-relative bracket family. **Lemma 7.6**
   (chunk_0021:23): *"If φ1 is a (z0,z1)-∨forward-EA formula and φ2 is a (z1,z2)-∨forward-EA
   formula, then `(∃z1)^{<z2}_{>z0}(φ1 ∧ φ2)` is a (z0,z2)-∨forward-EA formula."*
   → This is a **separate closure lemma** that stitches a `(z0,z1)`-bracket to an **adjacent**
   `(z1,z2)`-bracket across the **shared endpoint z1**. A witness that lies **outside** `[x, t]`
   is handled **here**, never inside the single-bracket characterization of step 1.

**Load-bearing quotes** (verbatim from the chunks):
- Cor 5.4, chunk_0015:3: `¬(∃z)^{<z1}_{>z0}[α0, β1, α1, …, αn−1, βn, αn](z0, z)` … *"equivalent to a
  ∨forward-EA formula."* (bounded interior witness `^{<z1}_{>z0}`).
- Lemma 7.6, chunk_0021:23: `(∃z1)^{<z2}_{>z0}(φ1 ∧ φ2) is a (z0, z2)-∨forward-EA formula` for
  `φ1` a `(z0,z1)`- and `φ2` a `(z1,z2)`-formula.

---

## Reference-Grounding Mapping Table (H3, Tier 1 — 5 columns)

| Source | Prop / Location | Lean Identifier | Type Signature (verified by read) | Status |
|--------|-----------------|-----------------|-----------------------------------|--------|
| Rabinovich 2014 | Cor 5.4 / Lemma 5.1 (chunk_0015:3 / chunk_0013:29) — single bracket `[x,t]`, bounded interior witness `(∃z)^{<z1}_{>z0}` | `bracketEndChar_kv_step_sound` (InteriorGateGeneralK.lean:1043) | `… (hreal)(hexcl)(hexclExt) : (bracketEndChar_kv … (k+1) qnf).holds M atomMap x t → ∃ w, nf_eval_nf M (k+1) 3 [w,x,t] qnf` | VERIFIED — obligation-carrying soundness; `hreal` = bounded interior placement `x<w<t`, `hexcl` = interior-cone exclusion |
| Rabinovich 2014 | Cor 5.4 ⇔ interior gate biconditional | `bracketEndChar_kv_step_correct` (InteriorGateGeneralK.lean:1165) | adds `(P : ExistProviders …)(hcharK)(h_UZ)(h_SZ)` then `… .holds … ↔ ∃ w, nf_eval_nf M (k+1) 3 [w,x,t] qnf` | VERIFIED — `⟨step_sound, step_complete⟩`; the maximal green general-k engine |
| Rabinovich 2014 | Lemma 7.6 (chunk_0021:23) — adjacency composition `(∃z1)^{<z2}_{>z0}(φ1∧φ2)` across shared endpoint | `hexclExt` binder (InteriorGateGeneralK.lean:1067 / :1193) | `∀ w, x<w→w<t→ igPtW… → ∀ σ, qnf.2 σ = false → ∀ x1, ¬(x≤x1∧x1≤t) → ¬ nf_eval_nf M k 4 [x1,w,x,t] σ` | VERIFIED — the **exterior** (strictly-outside-`[x,t]`) residue; faithfully a NON-goal of the interior gate |
| task-349 (consumer) | Frozen ∀-k contract for `endInterval` | `EndIntervalCorrect` (CarrierK1V.lean:2179) | `∀ k qnf M x t (6 order bits), (endInterval … k qnf).holds M atomMap x t ↔ ∃ w, nf_eval_nf M k 3 [w,x,t] qnf` | VERIFIED — **UNCONDITIONAL**; supplies no P/UZ/SZ/hreal/hexcl/hexclExt |
| task-355 (frozen DoD) | Obligation-FREE interior target | `InteriorGateTarget` = `BracketCarrierCorrectVPrior` (InteriorGateGeneralK.lean:76 / PriorInterface.lean:60) | `∀ qnf (6 order bits) M (h_UZ)(h_SZ) x t, (carrier qnf).holds … ↔ ∃ w, nf_eval_nf M k 3 [w,x,t] qnf` | VERIFIED F1-obstructed at k≥2 (carries UZ/SZ but no provider obligations) |
| k=2 precedent | OuterGate composed gate | `bracketEndChar_kvE2_correct_two_prior_frag` (OuterGate.lean:359) | carries `P, h_UZ, h_SZ, hfrag, hrealI, hrealB, hexcl, hexclExt` then `.holds ↔ ∃ w …` | VERIFIED — even at k=2 **only** an obligation-carrying instance exists; no clean instance ever landed |
| F1 machine witness | Carrier information-blindness | `bracketEndChar_kv_factors` (CarrierKv.lean:422) | fold-bit-equal `qnf, qnf'` ⇒ `bracketEndChar_kv … qnf = bracketEndChar_kv … qnf'` | VERIFIED — sorry-free (propext congruence); carrier cannot read per-σ arity-4 marks |

---

## Q1 — Faithfulness verdict: **CONFIRMED (faithful; not a divergence)**

The implementer's structural claim is that `hexclExt` corresponds to Lemma 7.6's **adjacency
composition** handled by a *separate* adjacent-bracket lemma, while the interior gate is the
single-bracket `[x, t]` characterization (Cor 5.4). Reading the actual chunk text confirms this
division of labor, and — adversarially — I could **not** find a paper route that closes the single
bracket without the exterior residue:

- **The paper's interior witness is bounded strictly inside the bracket.** Cor 5.4 (chunk_0015:3)
  and Lemma 5.3's inductive existential (chunk_0014:35, `(∃r0)^{<z1}_{>z0}`) place every interior
  witness in the **open interval `(z0, z1)`**. The Lean `hreal` obligation (line 1055) mirrors this
  exactly: `x < w` and `w < t` (bounded), and the interior-cone exclusion `hexcl` (line 1061)
  ranges over `x ≤ x1 ≤ t`. These are the *within-bracket* moves — faithful to Cor 5.4.
- **The exterior residue is a different lemma in the paper.** A witness realizing an unmarked sub
  at a point **strictly outside `[x, t]`** (`hexclExt`, line 1067: `¬(x ≤ x1 ∧ x1 ≤ t)`) is exactly
  the object Lemma 7.6 composes across an adjacent bracket (`(∃z1)^{<z2}_{>z0}(φ1 ∧ φ2)`,
  chunk_0021:23). The single-bracket lemma (5.1/5.4) never quantifies outside `(z0, z1)`; the paper
  *structurally* cannot and does not handle exterior witnesses inside one bracket.
- **Adversarial attempt to break it:** Could the single bracket be closed without the exterior
  residue (which would mean the formalization is doing unnecessary work)? No. The `(z0,z1)`-relative
  formulas are explicitly **not closed under negation** (Lemma 7.8 preamble, chunk_0022:3), and the
  whole point of Lemma 7.6 is that only the *bounded composition* re-enters the class. The exterior
  witness is therefore genuinely out-of-class for the single bracket; the residue is not
  unnecessary work, it is the paper's actual seam. **The `hexclExt` binder is a faithful encoding
  of Rabinovich's seam, not a formalization artifact.**

Where I agree with the implementer I say so on the **same** evidence (chunk_0015 Cor 5.4;
chunk_0021 Lemma 7.6), verified independently by reading the chunks rather than the handoff prose.

**One calibration** (not a refutation): the implementer's phrase "the frozen clean InteriorGateTarget
is simply STRONGER than the paper's single-bracket result" is right in spirit but should be stated
precisely — Cor 5.4 characterizes the *negation of a single bracket* relative to an adjacent
context; the obligation-free `.holds ↔ ∃w` biconditional asks the carrier to encode per-σ interior
realizability with **no** access to the adjacent context, which the paper never claims for one
bracket in isolation. So "stronger" = "context-free," and the missing context is precisely the
`hreal/hexcl/hexclExt` obligations.

---

## Q2 — F1-refutation verdict: **CONFIRMED (genuine obstruction), with a status calibration**

Claim under scrutiny: the obligation-FREE `InteriorGateTarget` (= `BracketCarrierCorrectVPrior`) is
genuinely unprovable at k≥2 because `bracketEndChar_kv` builds only `P.existF 0` (arity-1) literals
and never `P.existF 3` (arity-4), so `.holds` + `P` has no channel to recover the arity-4 fiber
content. I scrutinized this hardest, including whether UZ/SZ or `P.correct` provides a back door.

**Machine-witnessed facts (independently read):**
- `bracketEndChar_kv_factors` (CarrierKv.lean:422) is **sorry-free** and proves: any two depth-(k+1)
  `qnf, qnf'` that agree on the atom layer (`qnf.1 = qnf'.1`), the off-fiber Prop, and the
  **fiber-existential fold bits** (`∃ marked sub in fiber (zoneSpec, projFresh)`) yield **equal
  carriers**. The doc (lines 415–421) states this is "the information-loss channel." Crucially,
  two `qnf` may **disagree on the mark `qnf.2 σ` of an individual arity-4 sub** inside a shared
  fiber, yet the carrier is byte-identical.
- The carrier only invokes `P.existF 0`: the delivered step lemma forces `hcharK : charF k =
  fun χ => P.existF 0 χ` (line 1170), and `igPtW` (line 1056) is built from `charF k` only. The
  `P.existF 3` channel (arity-4) is explicitly the one the carrier does **not** use (doc line 1015:
  "the arity-`(3+1)` provider `P.existF 3` channel … gated on" the obligation).

**Adversarial back-door checks (all fail to rescue the clean target):**
1. *Can UZ/SZ + all-M quantification recover the fiber?* No. `bracketEndChar_kv_factors` gives
   carrier **equality**, so `.holds M …` agrees on **every** M — including all UZ/SZ structures —
   for a fold-bit-equal pair. If the RHS `∃w, nf_eval_nf M (k+1) 3 [w,x,t] qnf` (which reads per-σ
   arity-4 marks via the quant layer) differs across the pair on even one UZ/SZ M, the biconditional
   cannot hold for both. Priors constrain M, not the carrier's blindness — no back door.
2. *Can `P.correct` supply the arity-4 equation?* `P.correct` at arity 3 exists in the
   `ExistProviders` bundle, but the **carrier never calls it**, so `.holds` yields no equation
   pinning the arity-4 fiber. The provider is present but off-channel.
3. *Precedent cross-check:* even at k=2, `bracketEndChar_kvE2_correct_two_prior_frag`
   (OuterGate.lean:359) carries `P, hrealI, hrealB, hexcl, hexclExt` — a clean
   `BracketCarrierCorrectVPrior` instance has **never** been delivered at k≥2. This is corroborating
   (not merely asserted) evidence that the obligation-free shape is unreachable past k=1.

**Calibration (the one place I temper the implementer):** the phrase "**F1-refuted**" overstates the
landed evidence. What is *machine-proven* is carrier **information-blindness** (factors) plus the
structural fact that the arity-4 channel is unused. The completing step — "there exists a concrete
`(qnf, qnf', M, x, t)` at k≥2 with equal carrier but differing `∃w`-realizability" — is a sound
semantic argument (arity-4 fibers become non-singleton at k≥2, so a mark can be flipped while fold
bits stay constant) but **is not a landed counterexample theorem** (grep found no `_refuted` /
`_false` interior-gate lemma; only `bracketEndChar_kv_factors`). So the accurate status is
**"provably unprovable through the only available channel,"** not "a machine-checked false." The
**operational consequence is identical**: the obligation-free ∀-k close cannot be assembled, and the
deliverable must be obligation-carrying. I endorse the obstruction; I recommend the handoff drop the
word "refuted" in favor of "channel-unprovable / information-blind."

---

## Q3 — PIVOTAL: Consumer acceptance — **REFUTED as stated; path forward is a TWO-SIDED reshape**

**What the frozen consumer actually is.** The contract that `endIntervalStep` (CarrierK1V.lean:2144,
still the `⟨[]⟩` placeholder) must satisfy is **`EndIntervalCorrect`** (CarrierK1V.lean:2179). Its
verified signature is a **bare, unconditional ∀-k biconditional**:

```
EndIntervalCorrect atomMap h_surj :=
  ∀ (k) (qnf : NormalForm sig k 3) (M) (x t) (six order bits),
    (endInterval atomMap h_surj k qnf).holds M atomMap x t ↔
      ∃ w, nf_eval_nf M k 3 [w, x, t] qnf
```

It carries **no `h_UZ`, no `h_SZ`, no `P`, no `hcharK`, and none of `hreal`/`hexcl`/`hexclExt`.**
There is **no `def EndIntervalCorrectPrior` in the tree** (grep: 0 hits) — the "Prior" name in the
task prompt does not correspond to a landed definition.

**What the delivered lemma requires.** `bracketEndChar_kv_step_correct` (InteriorGateGeneralK.lean:1165)
requires, beyond `k, qnf, M, x, t` and the six order bits, **seven** extra inputs:
`P : ExistProviders`, `hcharK`, `h_UZ`, `h_SZ`, `hreal`, `hexcl`, `hexclExt`.

**Signature trace, side by side:**

| Input | delivered `bracketEndChar_kv_step_correct` (:1165) | frozen `EndIntervalCorrect` (:2179) | k=2 `…kvE2_correct…` (:359) |
|-------|---|---|---|
| carrier | `bracketEndChar_kv … (k+1)` | `endInterval … k` (**different carrier**) | `bracketEndChar_kvE2` |
| `P : ExistProviders` | REQUIRED (:1169) | absent | REQUIRED (:362) |
| `hcharK` | REQUIRED (:1170) | absent | (implicit via `P.existF 0`) |
| `h_UZ`, `h_SZ` | REQUIRED (:1179) | **absent** | REQUIRED (:371) |
| `hreal`/`hrealI/B` | REQUIRED (:1181) | absent | REQUIRED (:374/:380) |
| `hexcl` | REQUIRED (:1187) | absent | REQUIRED (:387) |
| `hexclExt` | REQUIRED (:1193) | absent | REQUIRED (:393) |

**Verdict: the shapes DO NOT match.** The delivered obligation-carrying lemma cannot discharge the
frozen `EndIntervalCorrect` directly — the consumer supplies none of the seven obligations, and it
is even stated over a **different carrier** (`endInterval`, whose step `endIntervalStep` is still the
`⟨[]⟩` hole). Neither `bracketEndChar_kv_step_correct`/`InteriorGateTarget` **nor**
`EndIntervalCorrect`/`endInterval` is consumed anywhere yet (grep: only def-site/doc mentions) — the
wiring is genuinely un-done; task-349 Phase 5 is the intended junction.

**Where the implementer is wrong, precisely.** The `spawn_detail` claims "the k=2 consumer
KampPrior:351 supplies exactly these obligations, so it very likely does [accept]." Reading
KampPrior.lean:347–360 shows :351 is inside `nf_nvar_exist_all_depths`, and the `n = 1` general-`k+1`
case is **still a `sorry`** (line 361), waiting on the task-309/348 provider + exterior mechanism —
it is about `bracketEndChar_kvE2`, **not** `endInterval`/`EndIntervalCorrect`. So the "consumer
supplies the obligations" statement conflates (i) the KampPrior recursion (where UZ/SZ + providers
*do* live, but the general-k slot is an open `sorry`) with (ii) the task-349 `EndIntervalCorrect`
contract (which supplies nothing and is unconditional). **The consumer, as frozen, does NOT accept
the delivered shape.**

**Where the implementer is nonetheless right about direction.** F1 (Q2) means an unconditional
`EndIntervalCorrect` is *itself* unreachable at k≥2 — task-349's own frozen contract inherits the
identical obstruction the moment `endIntervalStep` is filled with the F1-lossy `bracketEndChar_kv`.
So the correct fix is **not** "prove the delivered lemma satisfies the frozen consumer" but a
**two-sided reshape**: re-freeze **both** the task-355 DoD **and** the task-349 consumer to the
obligation-carrying shape, and route the obligation discharge **up to the KampPrior recursion**,
where the `ExistProviders` bundle (via `nf_nvar_exist_all_depths`, KampPrior:330+) and UZ/SZ are in
scope. At k=2 that discharge already exists (`bracketEndChar_kvE2Ext_correct_two_prior_frag`,
referenced KampPrior:353, internalizes `hexclExt`); at general k it is the still-open KampPrior:351
`sorry`.

**Net Q3 answer:** the delivered shape is *reusable and correct*, but it does **not** slot into the
consumer contract as currently frozen. Option (a) unblocks task 349 **only after** the consumer
contract `EndIntervalCorrect` is also re-frozen to an obligation-carrying `EndIntervalCorrectPrior`
(new def) whose induction step **is** `bracketEndChar_kv_step_correct` and whose obligations are
discharged where the providers live. This is more construction than "re-verify the consumer accepts,"
but it is bounded and does not require any new interior-gate mathematics.

---

## Q4 — Recommendation: **`revise` (option a) for task 355**; option (b) is a distinct downstream task

Grounded in Q1–Q3:

1. **F1 (Q2) is real** → the task-355 DoD *cannot* be the obligation-free `InteriorGateTarget`. It
   must be re-frozen to the delivered obligation-carrying engine.
2. **Faithfulness (Q1) confirms** `hexclExt` is Rabinovich Lemma 7.6 exterior adjacency — a genuine
   NON-goal of the interior gate. Keeping it as a threaded binder is correct, not a debt.
3. **Consumer (Q3) does not accept the delivered shape as frozen** → the revision must also declare
   the task-349-side reshape (new `EndIntervalCorrectPrior`) and the KampPrior obligation-routing,
   so the plan does not silently re-block at the wiring step.

**Recommendation: `revise`.** Re-freeze the task-355 deliverable to the **already-delivered, GREEN**
obligation-carrying biconditional plus the two base rungs. Concretely, the exact statements to
freeze as the task-355 DoD:

- **Primary (re-freeze `InteriorGateTarget` → this):**
  `bracketEndChar_kv_step_correct` (InteriorGateGeneralK.lean:1165) — the general-k step
  biconditional `⟨step_sound, step_complete⟩`, carrying `P, hcharK, h_UZ, h_SZ, hreal, hexcl,
  hexclExt`.
- **Base rungs (retain):** `interiorGateTarget_zero` (:89) and `interiorGateTarget_one` (:102).
- **Consumer-side companion to declare in the revised plan (task-349 scope, flagged, not built
  here):** a new `EndIntervalCorrectPrior` over `endInterval` carrying the same obligation bundle,
  whose `Nat.rec` step is `bracketEndChar_kv_step_correct` and whose base is
  `endInterval_zero_correct` (CarrierK1V.lean:2199); obligations discharged at the KampPrior
  recursion.

**Do NOT spawn option (b) as part of task 355.** The general-k `hexclExt` discharge
(`bracketEndChar_kv_hexclExt_discharge` via Lemma 7.6) belongs to the **exterior-bracket layer**
(tasks 348/351/352/354) and is what the open `sorry` at KampPrior.lean:351 (general-`k+1`, n=1)
consumes. Spawn it **separately** only when the ∀-k Kamp close needs the general-k exterior
mechanism — it is out of interior-gate scope by the same Rabinovich seam (Q1). Bundling it into 355
would re-import the exact scope error the interior/exterior split was designed to avoid.

**Residual risk to surface in the revised plan:** the two-sided reshape means task 349's frozen
`EndIntervalCorrect` (unconditional) must be *unfrozen* and replaced — this touches a task-349
byte-frozen file, so the revision should confirm task 349 owns that change and that no other consumer
depends on the unconditional `EndIntervalCorrect` shape (grep confirms it is currently unconsumed).

---

## Adversarial Self-Verification (H4)

Re-read the draft under the mandate to break each load-bearing claim before endorsing. Claim
Verification Table (lean4 domain methods):

| Claim | Source / Counterexample tried | Verification Method | Confidence |
|-------|------------------------------|---------------------|------------|
| `hexclExt` = Rabinovich Lemma 7.6 adjacency composition | Read chunk_0021:23 verbatim; tried to find an in-bracket close of the exterior witness in Cor 5.4/Lemma 5.3 | chunk_0021 quoted passage + `hexclExt` sig read (InteriorGateGeneralK.lean:1067/:1193) | High |
| Interior witness is bounded strictly inside `(x,t)` | chunk_0015:3 (`^{<z1}_{>z0}`), chunk_0014:35 | quoted passage + `hreal` sig `x<w ∧ w<t` (line 1055) | High |
| Frozen consumer `EndIntervalCorrect` is unconditional (no obligations) | Direct read CarrierK1V.lean:2179–2190; grepped for `def EndIntervalCorrectPrior` (0 hits) | lean signature read + grep | High |
| Delivered `step_correct` requires P/hcharK/UZ/SZ/hreal/hexcl/hexclExt | Direct read InteriorGateGeneralK.lean:1165–1203 | lean signature read | High |
| Delivered lemma does NOT satisfy frozen consumer as-is | Side-by-side signature trace; checked neither is yet consumed (grep) | signature diff + grep (no consumers) | High |
| `bracketEndChar_kv_factors` is sorry-free & carrier-blind | Read CarrierKv.lean:415–448; grepped module for `sorry`/`admit` | lean source read + grep | High |
| No landed concrete F1 counterexample theorem (only `factors`) | grep `refut/_false/not_correct/unprov` in CarrierKv.lean → only doc + `factors` | grep result | Medium |
| Carrier uses only `P.existF 0`, never `existF 3` | `hcharK` (:1170), `igPtW` from `charF k`; doc line 1015 | lean signature read | High |
| k=2 has only obligation-carrying instance (never clean) | Read OuterGate.lean:359–399 | lean signature read | High |
| KampPrior:351 general-k slot is an open `sorry` (not a provider that supplies obligations) | Read KampPrior.lean:347–361 | lean source read | High |
| "F1-refuted" overstates: it is channel-unprovability, not a machine-checked false | Searched for a landed `_refuted` theorem; found none | absence-of-evidence (grep) | Medium |

**Contradiction Log.** One contradiction between the implementer's `spawn_detail` ("the k=2
consumer KampPrior:351 supplies exactly these obligations, so [the consumer] very likely does
[accept]") and the frozen `EndIntervalCorrect` signature (supplies nothing). **Resolution:** by the
verification-precedence ranking (a directly-read Lean signature outranks prose reasoning about
"likely"), the frozen-signature reading wins. Resolved in Q3: the implementer conflated the
KampPrior recursion (providers in scope, but the general-k slot is an open `sorry`) with the
task-349 `EndIntervalCorrect` contract (unconditional). No UNRESOLVED contradictions remain.

**Recommendations modified after verification:**
- Tempered Q2 from the implementer's "F1-refuted" to "channel-unprovable / information-blind" (no
  landed counterexample theorem).
- Sharpened Q3 from the implementer's "re-verify consumer accepts" to a **two-sided reshape**
  (consumer contract must also be re-frozen; obligations route to KampPrior), because the frozen
  `EndIntervalCorrect` demonstrably does not accept the delivered shape.
- Kept the overall `revise` recommendation but explicitly scoped option (b) OUT of task 355.

**Anti-analysis compliance (H2):** every faithfulness claim is anchored to a specific Rabinovich
chunk + quoted passage; every "consumer accepts / requires X" claim cites the exact Lean signature
line read (no "mathlib likely has" / instinct-only conclusions). No `sorry`/deferral/axiom route is
recommended.

---

## Files read (evidence base, absolute paths)

- `/home/benjamin/Projects/Literature/sources/rabinovich_2014/chunk_0013.md` … `chunk_0015.md`,
  `chunk_0020.md` … `chunk_0022.md`
- `/home/benjamin/Projects/BimodalLogic/Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/InteriorGateGeneralK.lean` (76–115, 1043–1117, 1165–1203)
- `/home/benjamin/Projects/BimodalLogic/Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/PriorInterface.lean` (16–108)
- `/home/benjamin/Projects/BimodalLogic/Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/CarrierK1V.lean` (2090–2216)
- `/home/benjamin/Projects/BimodalLogic/Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/OuterGate.lean` (268–399)
- `/home/benjamin/Projects/BimodalLogic/Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/CarrierKv.lean` (415–448)
- `/home/benjamin/Projects/BimodalLogic/Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean` (205–361)

*Note: build GREEN / axiom-clean / byte-identical-frozen claims are consumed from the prior dispatch
handoff (HEAD `c6ce32317`); this read-only research independently confirmed the delivered module is
`sorry`/`admit`-free by grep but did not re-run `lake build`.*
