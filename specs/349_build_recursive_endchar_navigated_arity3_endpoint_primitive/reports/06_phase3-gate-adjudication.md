# Report 06 — Phase-3 Gate Adjudication (H5 divergence audit): the endChar single-point primitive

- **Task**: 349 — recursive navigated arity-3 endpoint primitive `endChar` + `endChar_correct`
- **Type**: lean4 (hard-mode; H2/H3/H4/H5). Read-only audit — no source edits, no spawns.
- **Session**: sess_1783841542_df767b
- **Dispatch**: 4th block at the same single-point-Formula obstruction; adjudicate (1) divergence /
  (2) residual lemma / (3) architecture infeasible.
- **Reference grounding tier**: Tier 1 (literature-backed — Rabinovich 2014, read directly this dispatch).
- **Agent**: lean-research-hard-agent

---

## VERDICT (read first): **(3) ARCHITECTURE INFEASIBLE**

The frozen carrier `EndCharCarrier sig k := NormalForm sig k 3 → TemporalPred` (Base.lean:1007) forces
`endChar (k+1) qnf` to be a **closed `Formula`/`TemporalPred` read at the single point `w`**. For
`k ≥ 1` the target it must characterize contains a **quant layer** whose free-anchor `(x,t)` dependence
is **non-atomic**, and **no residual hypothesis expressible at the `endChar_correct` interface** (an
atom-residual `h_res : ∀ atom : AtomKind sig 3, …`) can cancel it. This is the report-04 non-theorem
(`endCharN0_correct_infeasible`, Base.lean:1779) shown to **survive the `h_res` escape** exactly at the
step `k ≥ 1`, because the escape only works at depth 0 where all anchor-dependence is atomic.

Report 05's "FEASIBLE-PENDING-RESIDUAL-THREADING" (§0, §5.1 row 6) was **over-optimistic**: the
deferred residual-threading lemma is a **non-theorem** (§Case-2 below), and report 05's own specified
proof tool `nf_zone_flatten_navigable_correct` (Base.lean:687) demands the **unconditional** endpoint
hooks that are themselves the infeasible form (§SQ2). The specific error is report 05 §5.1 **row 7**
("frozen carrier is compatible", Confidence High): it verified the **base case** and extrapolated to
all `k`, missing the depth-0-vs-depth-(k+1) structural asymmetry.

**Is there also a divergence (Case 1)?** Yes, literally: the implementer built `endCharStep` via the
`navPieceForm` **def** (NavigatedEndChar.lean:321), which report 05 §3.5/§0 forbade. **But that
divergence is not the cause and re-implementing faithfully per report 05 §3 does NOT avoid the stuck
goal** — the frozen carrier forces *any* per-`sub` closed formula read at `w` into the same obligation
(§Case-1). So the Case-1 verdict ("re-implement, wall goes away") is **false**; the divergence is a
symptom of an unrealizable spec, not a repairable mistake.

**Action**: `/revise 349` to **change the recursion carrier type** to Rabinovich's two-endpoint,
`x,t`-explicit Prop-valued interval characterization (already green as `nf_zone_flatten_navigable`);
collapse to a closed `TemporalPred` only at the ≤1-free-anchor base. This is report 04 §5's
recommendation, which report 05 acknowledged in prose but failed to carry into the **type** of the carrier.

---

## 1. Claim Verification Table (H4)

Verification methods: `read` = direct file:line read this dispatch; `goal` = machine-located blocker
goal-state; `lit` = Rabinovich source read this dispatch; `type` = Lean type-level (arity) fact.

| # | Claim | Source / Counterexample | Method | Confidence |
|---|-------|-------------------------|--------|-----------|
| 1 | Frozen `EndCharCarrier sig k = NormalForm sig k 3 → TemporalPred` at **all** `k` (closed, no `x,t`) | Base.lean:1007 | read | High |
| 2 | `endCharStep` is inescapably a closed `⟨formula_conjList …⟩` read at `w`; per-`sub` clause = `nf_quant_clause_tl (navPieceForm rec sub) …` | NavigatedEndChar.lean:313-321 | read | High |
| 3 | Landed 3a step DIVERGES from report 05 §3.5/§0 (which forbade `navPieceForm` as inner converter) | report 05 §0, §3.5, §5.3 vs NavigatedEndChar.lean:321 | read | High |
| 4 | Stuck goal is verbatim `navPieceForm_correct` (report-04 non-theorem, closed biconditional) | NavigatedEndChar.lean:510; handoff `verbatim_goal` | goal | High |
| 5 | At depth 0, `nf_eval_nf M 0 3 [w,a,b] qnf` is **purely the atom layer**; `h_res` (atom-residual) cancels ALL anchor-dependence ⇒ base green | Base.lean:1064-1081 (`endChar0_correct`) | read | High |
| 6 | At depth `k+1`, `nf_eval_nf` = atom layer ∧ **quant layer** `∀ sub, (∃v nf_eval_nf M k 4 [v,w,x,t] sub) ↔ qnf.2 sub` | NavigatedEndChar.lean:293-300 | read | High |
| 7 | `h_res : ∀ atom : AtomKind sig **3**` cannot reach the quant layer: `sub : NormalForm sig k **4**`, its atom layer is `AtomKind sig 4` (positions 2,3 = x,t) — a **different type** | NavigatedEndChar.lean:266, 298, 320 | type | High |
| 8 | Quant-layer `(x,t)`-dependence is **non-constant** in `(x,t)` even under `h_res` (sub's atoms ≠ qnf's atoms) | report 04 §2.1 + claim 7 | read+type | High |
| 9 | report 05's Step-B tool `nf_zone_flatten_navigable_correct` demands **unconditional** `h_past`/`h_fut`: `(pastEnd q).eval_at w ↔ nf_eval_nf M k 3 [w,x,t] q` — **no residual slot** | Base.lean:692-697 | read | High |
| 10 | Discharging claim-9 hooks with `pastEnd := endChar k` is exactly `endCharN0_correct_infeasible` (unconditional world-local) | Base.lean:692-697 vs 1779 | read | High |
| 11 | Residual-threading lemma (derive per-`sub` residual from `h_res` + exterior) is a **NON-THEOREM** | §Case-2 counterexample; claim 7 | type+model | High |
| 12 | `endCharN0_correct_infeasible` obstruction engine is fully general (any single-point base ⇒ nf_eval invariant off position 0) | Base.lean:1745-1753, 1779-1803 | read | High (machine-checked) |
| 13 | Rabinovich's recursive carrier is the **two-free-variable** interval formula `[α0,β1,…,αn](z0,z1)`, NOT a single-point formula | chunk_0015 (Cor 5.4, Lemma 5.1) | lit | High |
| 14 | Rabinovich collapses to a single-point TL formula **only at one free variable** (Prop 3.5) | chunk_0010:11 | lit | High |
| 15 | Rabinovich "residual" = navigation re-anchors an endpoint (`r0=inf`, recurse `On(…,r0,z1)`); `INF(z0,r0,z1,P1)` pins it, expressed over the **two explicit endpoints** — never a separate single-point hypothesis | chunk_0014 (Lemma 5.3 step); chunk_0015 | lit | High |
| 16 | Faithful primitive = `x,t`-explicit Prop-valued recursion carrier = the already-green `nf_zone_flatten_navigable(_correct)` | Base.lean:667/687; report 04 §5 | read | High |
| 17 | Report 05 §5.1 **row 7** ("frozen carrier compatible", Conf High) is the specific over-optimism; refuted by claims 5–8 | report 05 §5.1 row 7 vs claims 5-8 | read | High |

**Contradiction Log**: The apparent contradiction — report 05 §5.2 resolved "closed `TemporalPred` under
`h_res` is fine (row 2/7)" against report 04's non-theorem — is itself **misresolved**. Precedence
(machine-checked green asset > analysis) is satisfied only for the **base** (`endChar0_correct`, depth 0,
green). Extending it to `k ≥ 1` is not backed by any green asset; it is refuted by the arity mismatch
(claim 7) and the unconditional flatten hooks (claim 9). Resolution: report 05's discriminator (`h_res`
+ `x,t`-explicit) is **real but only sufficient at depth 0**; at `k ≥ 1` it is insufficient. No
remaining unresolved contradiction.

---

## 2. Decisive sub-questions (answered with file:line + goal state)

### SQ1 — Does report 05 §3's `endCharStep` route the k+1 per-`sub` characterization through a Formula (`navPieceForm`) or a Prop (`nf_zone_flatten_navigable`)? Does landed 3a match?

**Report 05 specified the Prop route and explicitly forbade the Formula.** Verbatim:
- §0: "**FORBIDDEN and to be deleted from the critical path**: … `navPieceForm` as an inner *converter*
  (its `navPiece_reduce` reduction is retained, its `_correct` is a non-theorem and must not be stated)".
- §3.4 Step B: "characterize each ≤2-anchor conjunct with `x,t` EXPLICIT (Prop-valued). Use
  `nf_zone_flatten_navigable_correct M atomMap x t pastEnd futureEnd q` (Base.lean:687), whose LHS …
  and RHS both carry `x,t` **explicitly** → immune to the refutation."
- §3.5: "**Deleted from the critical path (FORBIDDEN):** … `navPieceForm` as inner converter,
  `navPieceForm_correct` (must not be stated)".

**The landed 3a `endCharStep` does NOT match — it routes through `navPieceForm`** (NavigatedEndChar.lean:317-321):
```lean
fun qnf =>
  ⟨formula_conjList
    ((endChar0 atomMap h_surj qnf.1).formula ::
      (Finset.univ.toList : List (NormalForm sig k 4)).map
        (fun sub => nf_quant_clause_tl (navPieceForm rec sub) (qnf.2 sub)))⟩
```
So there **is** a literal divergence (claim 3). The step-correctness proof then reduces (NavigatedEndChar.lean:499-510) to the machine-located goal:
```
⊢ temporal_truth M atomMap w (navPieceForm rec sub) ↔ ∃ v, nf_eval_nf M k 4 (Fin.cons v (zoneEnv3 w x t)) sub
```
which is verbatim `navPieceForm_correct` — the report-04 non-theorem (claim 4).

**But the divergence is not repairable (see SQ2).** report 05 §3.4 conflates the DEFINITION level (the
returned `EndCharCarrier` value is a **closed** `TemporalPred`, so `x,t` **cannot** be its parameters)
with the PROOF level (the correctness theorem may `∀`-quantify `x,t`). "`x,t` flowing as explicit
parameters of the Prop-valued flatten" is realizable in the correctness *proof* but **not** inside the
`endCharStep` *definition*. A closed `EndCharCarrier sig (k+1)` value has exactly one read point (its
`.eval_at` argument `w`) and no access to the carrier values `x,t`.

### SQ2 — Can a faithful construction produce `endChar(k+1)` as a Formula while correctness stays x,t-explicit, WITHOUT `navPieceForm_correct`? 

**No.** Two independent walls, both from the frozen carrier:

1. **Any per-`sub` closed formula read at `w` inherits the same obligation.** For
   `(endCharStep rec qnf).eval_at M atomMap w ↔ nf_eval_nf M (k+1) 3 [w,x,t] qnf` to hold with the LHS
   a closed `Formula`, the per-`sub` component must satisfy
   `temporal_truth w (φ_sub) ↔ ∃v nf_eval_nf M k 4 [v,w,x,t] sub` for **some** closed `φ_sub` read at
   `w` — regardless of whether `φ_sub` is `navPieceForm` or another `bracketBuild*` disjunction. This
   is the `navPieceForm_correct` shape. By report 04 §2.1 (parameter-independence): `L(x,t) :=
   temporal_truth w φ_sub` is **constant** in `(x,t)` (a closed formula captures no carrier values),
   while `R(x,t) := ∃v nf_eval_nf M k 4 [v,w,x,t] sub` is **non-constant** (reads `sub`'s atoms at
   positions 2,3 = `x,t`). Constant ≢ non-constant. Navigation (`bracketBuild*`) lets the formula
   *read other worlds* but cannot *select the specific free parameters* `x,t` — it reaches "the next
   point where P holds", never "the point `x`".

2. **report 05's own specified tool re-imposes the unconditional non-theorem.** `nf_zone_flatten_navigable_correct`
   (Base.lean:687) hypotheses (Base.lean:692-697):
   ```lean
   (h_past : ∀ w, w < x → ((pastEnd q).eval_at M atomMap w ↔ nf_eval_nf M k 3 (zoneEnv3 w x t) q))
   (h_fut  : ∀ w, t < w → ((futureEnd q).eval_at M atomMap w ↔ nf_eval_nf M k 3 (zoneEnv3 w x t) q))
   ```
   have **no residual slot**. With `pastEnd := endChar k`, discharging `h_past` requires
   `(endChar k q).eval_at w ↔ nf_eval_nf M k 3 [w,x,t] q` for all `w < x`, arbitrary `x,t` — exactly
   `endCharN0_correct_infeasible` (Base.lean:1779, machine-checked non-theorem). The residual-conditioned
   IH `endChar_correct k` cannot discharge `h_past` because `h_past` supplies no `h_res`, and none can be
   threaded (SQ3). So report 05's Step B, taken literally, would need to prove the non-theorem it claims
   to escape.

**Why the Formula-valued carrier forces the non-theorem (the depth-0 vs depth-(k+1) asymmetry, decisive):**
- **Depth 0** (`endChar0_correct`, Base.lean:1064-1081): `nf_eval_nf M 0 3 [w,a,b] qnf` unfolds
  (Base.lean:1066) to **only** the atom layer `∀ atom, atom_eval M [w,a,b] atom ↔ qnf atom`. The
  `w`-locus read (`endChar0_wlocus_correct`) discharges position 0; `h_res` discharges positions 1,2 +
  order. **All** `(a,b)`-dependence is atomic ⇒ atom-residual cancels it ⇒ green.
- **Depth k+1**: `nf_eval_nf` = atom layer ∧ **quant layer** (claim 6). The quant layer's `(x,t)`-dependence
  flows through `∃v nf_eval_nf M k 4 [v,w,x,t] sub` — **not** an atom, and over `AtomKind sig **4**`
  (claim 7), a strictly larger/different object than the `AtomKind sig 3` residual `h_res` can even be
  applied to. So the mechanism that makes depth 0 green **structurally cannot fire** at `k+1`.

### SQ3 — Is the residual-threading lemma a theorem or a non-theorem?

**Candidate statement** (the lemma a `/spawn` would chase):
> For `qnf : NormalForm sig (k+1) 3`, `w x t`, given `h_res` pinning `qnf`'s top atom layer at
> `[w,x,t]` and the bracket-exterior navigation structure in scope, then for each
> `sub : NormalForm sig k 4` and each arity-3 reduction-piece `q` of `sub` (via `nfEval_le2_reduction`),
> there exists a residual `h_res_q` pinning `q`'s atom layer at the piece's anchors, derivable from `h_res`.

**Verdict: NON-THEOREM.** Adversarial refutation (concrete, in the spirit of `endCharN0_correct_infeasible`):
- Take `k+1 = 1` (`k=0`), so `sub : NormalForm sig 0 4`, `qnf : NormalForm sig 1 3`. `h_res` pins
  `qnf`'s arity-3 atom layer bits at positions 1,2. `sub`'s atom bits are **independent syntactic data**
  of a **different formula** at **different arity** (`AtomKind sig 4`).
- Let `sub` carry atom `AtomKind.pred p 2` (reads position 2 = `x`) with bit `true`. The needed residual
  `h_res_q` requires `M.interp p x = true`. Choose a model with `M.interp p x = false`. Then `h_res_q`
  is **false**, while `h_res` — a constraint on `qnf`'s *own* (positions 1,2) atoms — remains satisfiable
  independently (choose `qnf`'s bits to match `M` at `x,t`). So `h_res` holds but the per-`sub` residual
  fails ⇒ not derivable.
- **The per-`sub` residual is strictly MORE information than `h_res` carries** (blocker's exact claim,
  confirmed). Worse: the bound witness `v` ranges over all worlds, so any piece anchored at `v` would
  need its residual to hold at the *witnessing* `v` — unknown until the existential is discharged; no
  fixed hypothesis covers it. **This is Case (2)'s disqualifier: the residual is strictly more than
  anything in scope carries — so it is NOT Case 2.**

Note the eval side does not rescue it: even assuming `nf_eval_nf M (k+1) 3 [w,x,t] qnf` (backward
direction), the quant clause only tells you the *truth value* `∃v … ↔ qnf.2 sub` matches, not that
`sub`'s atoms hold at `x` — so no per-piece atom-residual is extractable.

### SQ4 — How does Rabinovich 2014 actually avoid this? Single recursive formula, a family, or a differently-typed carrier?

**A differently-typed carrier.** Rabinovich's recursion motive at the ≥2-variable level is the
**two-free-variable interval formula** `[α0, β1, α1, …, αn](z0, z1)` (chunk_0015, Cor 5.4 / Lemma 5.1),
a predicate over **both** explicit endpoints `z0, z1`. He does **all** the hard work (negation,
navigation — §5, Lemma 5.1/5.3) at this two-variable level. He collapses to a single-point
`TL(Until,Since)` formula **only** at Proposition 3.5 — "Every ∨∃∀-formula with **one free variable** is
equivalent to a `TL(Until,Since)` formula" (chunk_0010:11) — i.e. **only when exactly one free variable
remains**.

Navigation is **re-anchoring, never a third free variable** (chunk_0014, Lemma 5.3 inductive step):
`r0 = inf{z ∈ (z0,z1) | P1(z)}`, then recurse with `On(P2,…,Pn, r0, z1)` — the past endpoint `z0` is
**replaced** by the navigated `r0`, which is defined/pinned by the ∨∃∀ formula `INF(z0,r0,z1,P1)`
expressed **over the two explicit endpoints**. The free-variable count stays exactly 2. The "residual"
is never a separate single-point hypothesis; it is **carried by the two-endpoint interval formula
itself**, which reads at both `z0` and `z1` directly (they are substituted free variables).

**Faithful primitive**: the recursion carrier must read at **both** enclosing anchors `(x,t)` — i.e. be
`Prop`-valued with `x,t` explicit (Rabinovich `[…](z0,z1)`), which the codebase **already has green** as
`nf_zone_flatten_navigable M atomMap x t … q` (Base.lean:667/687). The frozen
`NormalForm sig k 3 → TemporalPred` is Rabinovich's **Prop-3.5 OUTPUT** — faithful only at the ≤1-free
base (`endChar0`). Freezing it at **all** `k` (Base.lean:1007) is the root type error.

---

## 3. Why the primitive is infeasible + the faithful alternative

### 3.1 The root defect (precise)
`abbrev EndCharCarrier sig k := NormalForm sig k 3 → TemporalPred` (Base.lean:1007) commits the
recursion motive to a **single-point closed formula at every depth**. Rabinovich's motive is a
**two-endpoint (`z0,z1`-explicit) interval formula** at every depth ≥ the base; the single-point form
appears only once, at the outermost ≤1-free-variable collapse (Prop 3.5). The frozen carrier therefore
**mistypes the recursion**, and the mistype is invisible at `k = 0` (where the two views coincide:
depth-0 eval is pure atom layer, cancelled by `h_res`) but fatal at `k ≥ 1` (where the quant layer's
non-atomic `(x,t)`-dependence has no atom-residual to cancel it).

### 3.2 Faithful alternative primitive (grounded in Rabinovich; all assets already green)
Re-type the recursion carrier to the two-endpoint Prop-valued interval characterization and reserve the
closed-formula collapse for the base only:

```lean
-- Recursion motive (Rabinovich [α…](z0,z1); green shape = nf_zone_flatten_navigable):
--   two enclosing anchors EXPLICIT, Prop-valued, reads at BOTH x and t.
-- Intended correctness of the recursion (x,t explicit on BOTH sides — immune to §2.1):
--   endInterval_correct k q x t :
--     (∃ w, nf_eval_nf M k 3 (zoneEnv3 w x t) q) ↔ nf_zone_flatten_navigable M atomMap x t (endInterval k) (endInterval k) q
-- Base / outermost collapse to closed TemporalPred ONLY at ≤1 free anchor (Prop 3.5):
--   endChar0 / endChar0_correct (Base.lean:995/1056), consumed at the top level only.
```

- **Step A (reduce arity FIRST, keep witness bound)** — `nfEval_le2_reduction` (Lemma32Reduction.lean:535)
  / `navPiece_reduce` (NavigatedEndChar.lean:215): GREEN, retained verbatim.
- **Step B (≥2-anchor merge, `x,t` explicit)** — `nf_zone_flatten_navigable_correct` (Base.lean:687):
  GREEN. Its endpoint hooks `h_past`/`h_fut` are discharged by the **IH of the re-typed recursion**
  (`endInterval_correct k`, which is *also* `x,t`-explicit), **not** by a residual-conditioned closed
  `endChar k`. This is the piece report 05 got backwards (SQ2 wall 2).
- **Step C (interior β-segment)** — `seg` / `seg_holds_coupled` (Base.lean:1127/1150): GREEN.
- **Step D (collapse only at the base)** — `endChar0` / `endChar0_correct` (Base.lean:995/1056): GREEN.

**Crucially this is NOT a spawn** (no new bridge lemma exists to prove — the arity-4 bridge and the
residual-threading lemma are both non-theorems). It is a `/revise` that **changes the carrier type** and
the `endChar_correct` statement so the free-anchor count never exceeds Rabinovich's cap before the final
collapse. `endChar : (k) → EndCharCarrier sig k` (single-point at every `k`) cannot be the deliverable;
the deliverable is the two-endpoint interval recursion with a single-point collapse only at the top.

### 3.3 What this means for tasks 349 / 350 / 309
- **349**: the current typed goal (`endChar`/`endChar_correct` over the frozen single-point carrier) is
  **infeasible for `k ≥ 1`**. `/revise 349` must re-type the carrier (§3.2). The base assets from **309**
  (`endChar0`, `endChar0_correct`, `endChar0_wlocus_correct`) and **351** (`nfEval_le2_reduction`), plus
  `nf_zone_flatten_navigable(_correct)`, `seg*` are all **GREEN and reusable** — only the recursion
  *type* and step statement change. Preserved: everything in report 05 §6 "PRESERVED".
- **350 / 309 (downstream consumers)**: any task consuming `endChar : (k) → EndCharCarrier sig k` with
  the frozen carrier inherits the infeasibility and must instead consume the re-typed two-endpoint
  primitive (or the top-level closed-formula collapse only). *(Scope caveat: I did not read 350's/309's
  current task descriptions this dispatch; this is the type-level implication of the carrier change, to
  be confirmed against their consumption sites during `/revise`.)*

### 3.4 What must NOT be attempted (all provably closed)
- Stating `navPieceForm_correct` or any single-point closed-formula `_correct` for a ≥2-free-anchor
  quant target (report 04 §2.1; this report SQ2).
- Spawning a residual-threading lemma (SQ3 non-theorem).
- Discharging `nf_zone_flatten_navigable_correct`'s `h_past`/`h_fut` with `endChar k` (SQ2 wall 2 =
  `endCharN0_correct_infeasible`).
- A single-pair arity-4→3 collapse (Lemma32Reduction.lean:290-306, forgetting non-theorem); per-pair
  `∀ij∃w` distribution; arity-1 collapse.

---

## 4. H5 Divergence Audit

### 4.1 Divergence table
| Target | Churn | Last-attempted approach | Failure reason |
|--------|-------|-------------------------|----------------|
| inner arity-(n+1) converter | 4 (`navBrickForm`→`navMultiAnchorForm`→`navPieceForm`→v5 `endCharStep`-via-navPieceForm) | closed `Formula` read at one point characterizing a multi-anchor eval | single-point read cannot reference/select free anchors (parameter-independence, report 04 §2.1) |
| `navPieceForm_correct` / step 3b | 4th block | frozen single-point carrier + atom-`h_res` escape | `h_res` (AtomKind sig 3) cannot reach the arity-4 quant layer; escape only works at depth 0 |
| residual-threading lemma | 1 (proposed, report 05 row 6) | derive per-`sub` residual from top `h_res` | non-theorem (SQ3): per-`sub` residual is strictly more info than `h_res` carries |

### 4.2 Postmortem (root cause)
Four successive attempts renamed the **same object** (a closed single-point formula characterizing a
≥2-free-anchor target) without changing its **type**. Report 05 correctly diagnosed the free-variable
discipline (Rabinovich ≤2, collapse only at 1) and correctly identified the green Prop-valued asset, but
then **kept the frozen single-point carrier** and tried to rescue it with an atom-residual `h_res`. That
rescue is a **theorem at depth 0 only** (all anchor-dependence atomic) and a **non-theorem at `k ≥ 1`**
(quant-layer anchor-dependence is non-atomic and out of the residual's type). The root cause is a
**carrier type error** frozen at Base.lean:1007, not a missing lemma and not (repairably) a wrong builder.

### 4.3 Sorry inventory
| Identifier | State | Type | Why stuck |
|-----------|-------|------|-----------|
| `endCharStep` (def) | GREEN, sorry-free | `EndCharCarrier sig (k+1)` | landed 3a; but embeds the non-theorem obligation in its correctness |
| `endChar_correct_step` (3b) | BLOCKED, no sorry landed | `k+1` step biconditional | reduces to `navPieceForm_correct` (non-theorem); frozen carrier forces it |
| `navPieceForm_correct` | never stated (forbidden) | closed biconditional | report-04 non-theorem |
| residual-threading lemma | never stated | — | non-theorem (SQ3) |

**Verified 0 sorries / 0 vacuous / 0 new axioms landed** (handoff `verification`: `sorry_count:0`,
`vacuous_count:0`, `new_axiom_count:0`, `scoped_build_passed:true`). Zero-debt honored.

### 4.4 Type-mismatch analysis
| Object | Demanded type (frozen) | Faithful type (Rabinovich) | Mismatch |
|--------|------------------------|----------------------------|----------|
| recursion motive at `k ≥ 1` | `NormalForm sig k 3 → TemporalPred` (closed, read at `w`) — Base.lean:1007 | `(x t) → NormalForm sig k 3 → Prop` reading at `x` and `t` — Base.lean:667 (`[…](z0,z1)`) | closed single-point vs two-endpoint-explicit Prop; former cannot reference `x,t` |
| step residual | `∀ atom : AtomKind sig 3, …` (`h_res`) — NavigatedEndChar.lean:266 | quant-layer needs per-`sub` `AtomKind sig 4` residual at `[v,w,x,t]` | wrong arity (3 vs 4) + wrong layer (atomic vs quant) + bound witness `v` |
| flatten endpoint hook | unconditional `(pastEnd q).eval_at w ↔ nf_eval_nf M k 3 [w,x,t] q` — Base.lean:692 | `x,t`-explicit IH `endInterval_correct k` (both sides carry `x,t`) | frozen hook has no residual/anchor slot ⇒ = `endCharN0_correct_infeasible` |

### 4.5 Corrected lean-ready targets (for `/revise 349`, exact signatures)
Do **not** re-dispatch `endChar_correct_step` or any `navPieceForm_correct`. Re-type the recursion:

```lean
-- Recursion carrier (replace EndCharCarrier at k ≥ 1): two-endpoint Prop-valued interval motive.
-- Concretely, reuse nf_zone_flatten_navigable's shape; recursion produces the endpoint hooks.
theorem endInterval_correct {sig} (M) (atomMap)
    (h_surj : ∀ p, ∃ a : Atom, atomMap (.atom a) = p) :
    ∀ (k : Nat) (q : NormalForm sig k 3) (x t : M.carrier),
      (∃ w, nf_eval_nf M k 3 (zoneEnv3 w x t) q) ↔
        nf_zone_flatten_navigable M atomMap x t (endIntervalHook k) (endIntervalHook k) q
-- base collapse to a closed TemporalPred ONLY at the outermost ≤1-free level:
--   consume endChar0_correct (Base.lean:1056) at the top, exactly as now.
```
The `h_past`/`h_fut` of `nf_zone_flatten_navigable_correct` are then discharged by
`endInterval_correct k` (both sides `x,t`-explicit — no residual needed, no non-theorem). The closed
`Formula`/`TemporalPred` (`endChar0`) is produced once, at the ≤1-free-anchor top, never inside the
recursion. This is the `/revise` deliverable; it is **feasibility-clean** (no non-theorem, no sorry, no
new axiom) and consumes only green assets.

---

## 5. Adversarial Self-Verification

- **Challenged the verdict against Case 1 (divergence).** I confirmed the literal divergence
  (NavigatedEndChar.lean:321 vs report 05 §3.5) and then attempted hardest to make "re-implement
  faithfully" work: it fails on two independent walls (SQ2), the strongest being that report 05's own
  cited tool `nf_zone_flatten_navigable_correct` has unconditional hooks (Base.lean:692-697) equal to
  the machine-checked non-theorem. So Case 1's *verdict* is refuted even though its *premise* (divergence
  occurred) is true. This is why the verdict is (3), not (1).
- **Challenged the verdict against Case 2 (spawn).** I constructed the exact residual-threading lemma and
  refuted it with a concrete model counterexample (SQ3) plus a type-level impossibility (AtomKind 3 vs 4,
  claim 7). The per-`sub` residual is strictly more information than `h_res` carries, which the task's own
  Case-2 gate disqualifies.
- **Forbidden verification outputs check**: none. The infeasibility is anchored to a machine-checked
  sorry-free theorem (`endCharN0_correct_infeasible`, Base.lean:1779, generalized via the depth-0/depth-k+1
  atom-vs-quant asymmetry read directly at Base.lean:1066 vs NavigatedEndChar.lean:298), not "mathlib
  likely has" or instinct. Every load-bearing claim carries a file:line, goal-state, type-fact, or a
  directly-read Rabinovich chunk.
- **Uncertain-claim flags**: (a) The parameter-independence core (SQ2 wall 1) is the semantic argument
  from report 04 §2.1, not re-mechanized here as a new `theorem`; confidence High because it is a strict
  generalization of the sorry-free `endCharN0_correct_infeasible` and turns only on signatures read this
  dispatch. (b) The 350/309 downstream implication (§3.3) is type-level; I flagged it as to-be-confirmed
  against those tasks' consumption sites since I did not read their descriptions this dispatch. Neither
  uncertainty changes the 349 verdict.
- **Recommendation modified after verification**: entered leaning "Case 1 (divergence — re-implement)",
  because report 05 did forbid `navPieceForm` and the implementer used it. Adversarial checking of report
  05's *own* proof tool (Base.lean:692-697) and the frozen carrier (Base.lean:1007) against the depth-0
  base mechanism (Base.lean:1066) upgraded the verdict to **(3) ARCHITECTURE INFEASIBLE**: the divergence
  is real but not the cause; the spec report 05 gave is not realizable in the frozen carrier type.

---

## Reference Grounding (Tier 1)

| Source | Prop / Location | Lean Identifier | Type Signature / Fact (verified read) | Status |
|--------|-----------------|-----------------|----------------------------------------|--------|
| codebase | Base.lean:1007 | `EndCharCarrier` | `NormalForm sig k 3 → TemporalPred` (frozen at ALL k) | ROOT DEFECT |
| codebase | Base.lean:1056-1081 | `endChar0_correct` | closed `TemporalPred` char. of 2-anchor eval **under `h_res`**; depth-0 eval = pure atom layer (1066) | GREEN (base only) |
| codebase | Base.lean:687-706 | `nf_zone_flatten_navigable_correct` | `x,t`-explicit Prop merge; `h_past`/`h_fut` **unconditional**, no residual slot (692-697) | GREEN (faithful motive; hooks = infeasible form if fed `endChar k`) |
| codebase | Base.lean:667-678 | `nf_zone_flatten_navigable` | Prop over explicit `(x,t)`, reads at `x` and `t` | GREEN (Rabinovich `[…](z0,z1)`) |
| codebase | Base.lean:1745-1803 | `endCharN0_correct_infeasible` (+ engine 1745) | ¬∃ single-point base char. multi-anchor eval; general obstruction | GREEN (machine-checked non-theorem) |
| codebase | NavigatedEndChar.lean:313-321 | `endCharStep` | closed `formula_conjList`; per-`sub` = `navPieceForm rec sub` (the divergence) | GREEN def, non-theorem correctness |
| codebase | NavigatedEndChar.lean:480-510 | `endChar_correct_step` (3b) | reduces to `navPieceForm_correct` goal (510) | BLOCKED |
| codebase | NavigatedEndChar.lean:266 | `endChar_correct` spec `h_res` | `∀ atom : AtomKind sig 3, …` — arity 3, cannot reach `sub : NormalForm sig k 4` | type-level impossibility |
| Rabinovich 2014 | Prop 3.5 (chunk_0010:11) | — | single-point TL collapse **only at one free variable** | Tier-1 fact |
| Rabinovich 2014 | Cor 5.4 / Lemma 5.1 (chunk_0015) | — | recursion carrier = two-endpoint interval `[…](z0,z1)` | Tier-1 fact |
| Rabinovich 2014 | Lemma 5.3 step (chunk_0014) | — | navigate `r0=inf`, re-anchor `z0↦r0`, pinned by `INF(z0,r0,z1,P1)`; stays 2 free vars | Tier-1 fact |

---

*Report 06. Verdict: **(3) ARCHITECTURE INFEASIBLE** — the frozen single-point `EndCharCarrier`
(Base.lean:1007) mistypes the recursion; the report-04 non-theorem survives the `h_res` escape at
`k ≥ 1` because `h_res` (atom-residual, `AtomKind sig 3`) cancels anchor-dependence only at depth 0,
where the eval is purely atomic. Action: `/revise 349` — re-type the recursion carrier to the
`x,t`-explicit Prop-valued two-endpoint interval motive (green `nf_zone_flatten_navigable`), collapse to
a closed formula only at the ≤1-free base. NOT a spawn (residual-threading lemma is a non-theorem); NOT
a faithful-re-implement (report 05's spec is unrealizable in the frozen carrier).*
