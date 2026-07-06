# Report 40 — Phase 11b Divergence Audit (multi-anchor bracket bridge)

- **Task**: 305 (rabinovich_ea_formula_implementation, lean4)
- **Type**: Divergence audit (H5). No `.lean` files edited.
- **Session**: sess_1783315428_d370a2
- **Effort**: hard (H2 anti-analysis, H3 Tier-1 literature grounding, H4 adversarial verification, H5 divergence audit)
- **Reference grounding tier**: Tier 1 (literature-backed — Rabinovich 2014 "A Proof of Kamp's Theorem", local at `~/Projects/Literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.md`)

## Executive Verdict

**GO/NO-GO on the "multi-anchor bounded-existential bracket bridge" as stated: NO-GO.**

The bridge as specified in the handoff and `NfZoneDepthK.lean` module note — "express each open zone existential
as a `bracketBuildLeft`/`bracketBuildRight` formula whose endpoint `TemporalPred` is the depth-`k` characteristic
predicate encoded recursively via `nf_char3_eq_succ_iff` one depth down" — is **not a single ~400-700-line unit**.
Traced to its base, it forces an **arity tower**: the endpoint condition `char[y,x,t] = qnf` has a quant layer
`∃ w, nf_eval M k 4 [w,y,x,t] sub` (arity 4, three anchors), whose own endpoint has `∃ v, nf_eval M (k-1) 5 [v,w,y,x,t] …`
(arity 5, four anchors), and so on — the `nf_eval` **environment arity grows by one at each depth-recursion step**,
terminating only at depth 0 (arity `k+3`). This is precisely the failure mode the plan's own **Postmortem Constraint
(plan v39:146)** bans: *"Reintroduce any NF-depth / arity-tower parameter beyond `k`, arity-4+ existential converter …
This is the durable failure mode across plans 11-38."* The three recessions are the mechanical symptom of the approach
colliding with its own ban and deferring rather than violating it.

**The bridge is not wrong because Kamp's theorem is false** (it is true, and the tower terminates). It is NO-GO because
(a) it is banned by the governing plan, and (b) it **diverges from Rabinovich**, who never grows arity: he caps free
variables at **≤ 2** (Lemma 3.2.2) and absorbs all deeper quantifier structure as **additional bracket witnesses in one
interval**, not as new anchors.

## 1. Divergence Table

| Dispatch | Claimed target | What actually landed (sorry-free) | Actual residual crux | Recession cause |
|----------|----------------|-----------------------------------|----------------------|-----------------|
| **D1 (Phase 10 fold)** | depth-(k+1) x=t diagonal quant collapse `mergeNF_succ_quant` | `renameNF_eval_diag0` (depth-0 diagonal congruence, `NfDepth0Generalized.lean:1646`) | full x=t arm at depth k+1 | Projection-based `VecEA2` for x=t refuted as NON-theorem (`liftIdx(totalUnskip)` non-injectivity). Re-scoped into Phase 11. |
| **D2 (11a + framing)** | depth-k arity-3 zone converter | 11a extraction (`nf_eval_atom_layer`, `nf3_order_*`), then `nf_zone_exists_iff_char`, `nf_zone_partition5`, `nf_characteristic_quant_succ` (`NfZoneDepthK.lean:163-412`) | "bracket integration, zone-by-zone, ~400-700 lines" | Projection route refuted (correctly) at depth k+1; concluded remaining work is bracket assembly, but did not yet see the arity-growth wall. |
| **D3 (11b body)** | zone-by-zone bracket bridge | inner-`w` split (`nf_characteristic_quant_split3`, `nf_char3_eq_succ_iff`, `exists_nested_split3`, `nf_char_eq_iff_eval`, `NfZoneDepthK.lean:431-521`) | "single shared multi-anchor bracket bridge, all 5 zones, ~400-700 lines, no partial statement" | Discovered zones share one construction; restated crux as the multi-anchor bridge — **but the bridge's own endpoint recurses to arity-4 `∃w`, i.e. the banned tower.** Deferred again ("no non-vacuous partial statement exists"). |

**Recession signature.** Each dispatch lands a genuine sorry-free *split* lemma (outer `y`-split, then the
characteristic-type pivot, then the inner `w`-split) and re-labels the *unsplit remainder* as the crux "one layer deeper."
The remainder recedes because the split lemmas are all **unconditional trichotomies** (`exists_trichotomy_split`,
`exists_nested_split3`) — they reorganize the existential but never discharge the coupling. The coupling can only be
discharged by either (i) the banned arity tower, or (ii) a construction the plan does not yet contain (Rabinovich's
flattening — see §3). Absent (ii), every dispatch is structurally forced to (i), sees the ban, and defers.

## 2. Postmortem

### 2.1 Answers to the four audit questions

**A. Is the multi-anchor bracket bridge, as stated, a THEOREM? Is there a third hidden non-theorem?**

The bridge is *not* a fresh non-theorem — but it is *not the theorem the bracket builders can consume either.* Decisive
mechanical fact: the bracket builders accept only **single-point** `TemporalPred`s. `TemporalPred` is a bare `Formula`
wrapper and `TemporalPred.eval_at M atomMap tp z = temporal_truth M atomMap z tp.formula` — evaluation at **one** point
`z` (`ExistsForallNF.lean:49-56`). `bracketBuildRight_correct` (`VecEATranslation.lean:234-241`) gives
`∃ z1, t < z1 ∧ endRight.eval_at z1 ∧ bf.holds t z1`, where every `bf.pointTypes i` / `bf.segmentTypes i` is likewise
evaluated at a single point (`chainHolds`, `VecEATranslation.lean:30-47`). **Therefore a `TemporalPred` cannot carry a
multi-anchor (`y,x,t`) joint condition.** The handoff's plan to make the endpoint `TemporalPred` "the depth-`k`
characteristic predicate encoded recursively via `nf_char3_eq_succ_iff` one depth down" is trying to place a 3-anchor
condition (whose quant layer is the arity-4 `∃w, nf_eval M k 4 [w,y,x,t] sub`, `NfZoneDepthK.lean:491-497`) into a
1-anchor slot. The only ways to do that are: grow the `nf_eval` env arity (the banned tower), or re-locate `x,t` by
temporal navigation from `y` — which itself needs further single-point bracket types and reproduces the tower one level
out. So the "bridge as stated" is a **recursion into the arity tower**, i.e. effectively a **third recession**, not a
landable brick.

**B. Is the ~400-700-line single-unit estimate real, or does a non-vacuous decomposition exist?**

The single-unit estimate is an artifact of the mis-framing. A non-vacuous decomposition exists **once the approach is
corrected** (§3): the make-or-break question — *can the quant-layer witness `w` be absorbed as an additional bracket
witness on the fixed interval, rather than as a new anchor?* — is a small, falsifiable lemma at `k = 1` (proposal **D1**,
§3.2). Under the *current* framing no non-vacuous partial statement exists, and that is itself the diagnosis: a framing
whose only honest statement is the entire body is a framing that has hidden its real obligation.

**C. Is the Rabinovich Cor 5.4 correspondence faithful?**

**No — the plan/code has diverged from the source.** Verified against the paper:
- **Lemma 3.2.2** (`Rabinovich…md:78`): *"Every exists-forall formula is equivalent to a conjunction of exists-forall
  formulas with **at most two free variables**."* Rabinovich holds free variables (anchors) at ≤ 2, always.
- **Cor 5.4** (`…md:154-157`): `F_n := α_n`, `F_{i-1} := α_{i-1} ∧ (β_i Until F_i)`. The `α_j, β_j` are
  **quantifier-free single-point types**; the witnesses `x_0 < … < x_n` all live in **one** interval between **two**
  endpoints. There is **no** nested "arity-4 `∃w` recursively encoding a 4-anchor joint type." Arity of the *free
  variables* is constant; only the *witness count* `n` grows (and `BracketFormula n` handles arbitrary `n`).
- **Prop 3.5** (`…md:87-94`), the translation actually used for the converter: one free variable at position `z_k`,
  nested `Until`/`Since` over point/segment types. Again single-anchor, no tower.

The code's `nf_characteristic_quant_split3` / `nf_char3_eq_succ_iff` push the deeper quant witness `w` into the **env
arity** (`[w,y,x,t]`, `NfZoneDepthK.lean:491`), i.e. it treats `w` as a **new anchor**. Rabinovich treats the analogous
witness as **another bracket witness in the same 2-endpoint interval**. This is the divergence, and it is exactly why the
approach hits an arity tower the paper never incurs.

**D. Root cause of the 3× recession.**

Structural mis-framing of the induction load, in two compounding parts:
1. **Wrong recursion variable.** The code recurses on **depth `k` while growing anchor-arity** (`env` length
   `[y,x,t] → [w,y,x,t] → …`). The faithful construction keeps **2 anchors fixed** and grows the **bracket witness
   count** by *flattening* the depth-nested NF quant layers into a single-interval exists-forall (Rabinovich's
   exists-forall normal form; the codebase already has the flattening bridge `doets_lemma_1_1`,
   `NormalForm.lean:433`). The missing brick is this **flattening / free-variable reduction (Lemma 3.2 analog)**, not a
   "bracket bridge."
2. **Over-correction from the refuted projection route.** Having correctly refuted *per-variable projection* at depth
   `k+1` (the quant layer does not factor into independent per-anchor types — `NfZoneDepthK.lean:41-52`), the dispatches
   concluded the only faithful alternative was recursive multi-anchor char-encoding. They **skipped Rabinovich's actual
   middle route**: reduce to ≤ 2 free variables and absorb deeper witnesses into one flat interval decomposition whose
   point/segment types *are* single-anchor. Projection-fails does **not** imply anchors-must-grow.

### 2.2 The over-constrained corner (why this task has 38+ plan versions)

Four routes, three already closed by prior work, and the fourth (current) collides with a ban:

| Route | Status | Where closed |
|-------|--------|--------------|
| Per-variable projection `VecEA2` | Refuted NON-theorem at depth k+1 | `NfZoneDepthK.lean:41-52`; Phase 10 x=t diagnosis |
| Per-model `VecEA_m` existential bridge | Vacuous (`⟨tt, …⟩`); banned | plan v39:138-139 |
| Recursive multi-anchor char (current bridge) | Arity tower; banned | plan v39:146; **this report** |
| Uniform Prop 4.3 negation closure | Off completeness path; `/spawn` candidate | plan v39:181; `Prop43.lean`, `EAVecNegationClosure.lean` exist |

The corrected target (§3) is the **fifth** route — the depth-graded *flattening* (Rabinovich Lemma 3.2 + Cor 5.4 over a
flat single-interval bracket), which is the one Rabinovich actually uses and the one none of the four closed routes
implements.

## 3. Corrected Target Definition

### 3.1 What the next dispatch must NOT do

- Do **not** "build the multi-anchor bounded-existential bracket bridge" as the handoff `next_action_hint` states.
  Traced out, it is the banned arity tower (verdict: NO-GO, §2.1-A).
- Do **not** feed a multi-anchor `char[y,x,t]=qnf` condition into a `TemporalPred` endpoint — structurally impossible
  (single-point only, `ExistsForallNF.lean:49-56`).
- Do **not** retry projection `VecEA2` (refuted) or wire `VecEA_m.holds` into `:391` (vacuous, plan v39:135-139).

### 3.2 What the next dispatch SHOULD do — the flattening probe (falsifiable go/no-go gate)

Re-frame around Rabinovich's actual mechanism: **keep 2 anchors, absorb the quant witness as a bracket witness.** The
make-or-break question is decidable at minimal cost with a single non-vacuous lemma at `k = 1` (`NormalForm sig 1 3`
has exactly one quant layer, i.e. one nested witness `w`):

**D1 — Flattening pilot (open mid-zone, depth 1). ~200-350 lines, ONE dispatch, decisive.**

```lean
-- Off-path, in NfZoneDepthK.lean or a sibling module.
-- RHS is a CONCRETE BracketFormula.holds disjunction (over w's placement among y,x,t),
-- NOT an `∃ formula, iff` (Postmortem-compliant, non-vacuous).
theorem nf_zone_mid_flatten_k1 {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (qnf : NormalForm sig 1 3) (x t : M.carrier) :
    (∃ y, x < y ∧ y < t ∧ nf_eval_nf M 1 3 (zoneEnv3 y x t) qnf) ↔
      -- explicit disjunction over the 7 w-zones of nf_characteristic_quant_split3,
      -- each disjunct a concrete `BracketFormula.holds M atomMap x t bf_i` on the (x,t)
      -- interval whose pointTypes are DEPTH-0 ATOMIC (pred/order atoms of y and of the
      -- absorbed witness w), NOT a recursive depth-k characteristic predicate.
      (Explicit_BracketFormula_disjunction M atomMap qnf x t)
```

- **Why D1 is the right probe.** It exercises exactly the one claim the whole route rests on: that the coupled
  `∃w` (`nf_characteristic_quant_succ`, `NfZoneDepthK.lean:405-412`) can be realized by placing `w` as a **second
  bracket witness on the fixed `(x,t)` interval** with a **single-point** type, keeping the anchor set `{x,t}`. If true,
  the F_i chain (Cor 5.4) applies with single-point types and the tower never appears.
- **Why it is safe.** If D1 is **false** (the absorption cannot be expressed without re-coupling to a non-navigable
  anchor — the same non-injectivity that killed projection), that is a genuine **NON-theorem discovery at ~1 dispatch
  cost**, and it must trigger **STOP + re-plan onto the Uniform-Prop-4.3 `/spawn` route (plan v39:181)** — *not* another
  recession. Either outcome is decisive; neither is a deferral.

**Conditional continuation (only if D1 GREEN):**

- **D2** — Depth induction: generalize D1 to `qnf : NormalForm sig k 3` by induction on `k`, absorbing all `k` quant
  levels into the single `(x,t)` interval (witness count grows, anchors stay at 2). ~300-450 lines.
- **D3** — Half-bounded open zones `y<x`, `t<y` via `bracketBuildLeft`/`bracketBuildRight` from a single anchor. Mirror
  of D2. ~250-400 lines.
- **D4** — Point zones `y=x`, `y=t`: diagonal collapse via `renameNF_eval_diag0` (depth-0 base). Unchanged from current
  plan. ~150 lines.
- **D5** — Cor 5.4 `F_i` assembly of the per-zone brackets into the converter, then Phases 12/13/14. ~300-450 lines.

**Recommended dispatch count:** **1 dispatch on D1 as a hard go/no-go gate**, then (conditionally) **3-4 dispatches**
for D2-D5. Total 4-5, replacing the current unbounded "budget the whole body as one unit" framing that has produced 3
recessions.

### 3.3 Reusable assets that survive the re-framing

- `nf_eval_atom_layer`, `nf3_order_{yx,yt,xy,xt,ty,tx}` (`NfZoneDepthK.lean:163-257`) — atom/order extraction, reused by
  every zone's forward direction.
- `nf_zone_exists_iff_char`, `nf_zone_partition5`, `nf_zone_exists_partition5` (`:291-379`) — the outer `y`-split, still
  the correct skeleton.
- `nf_characteristic_quant_succ` (`:405`), `exists_nested_split3`, `nf_characteristic_quant_split3` (`:450-500`) — the
  inner `w`-split; these are exactly the input to the **absorption** that D1 tests.
- `renameNF_eval_diag0` (`NfDepth0Generalized.lean:1646`) — point-zone depth-0 base.
- `bracketBuildLeft`/`bracketBuildRight` + `_correct` (`VecEATranslation.lean:50,273,234,502`) — consumed with
  single-point types (as their signatures require).
- `doets_lemma_1_1` (`NormalForm.lean:433`) — the NF↔MonadicFormula flattening bridge; likely load-bearing for D2.

Nothing landed so far is wasted; the re-framing changes only what the *next* brick is (a flattening probe, not a
tower-bridge).

## 4. Adversarial Self-Verification

Applied the Claim Verification Bar to every load-bearing claim. Verification methods: `Read`-confirmed source
line, literature-chunk quote, or structural trace.

| Claim | Source / Counterexample | Verification Method | Confidence |
|-------|-------------------------|---------------------|------------|
| Bracket builders consume only single-point `TemporalPred`s | `TemporalPred := ⟨formula⟩`; `eval_at … z = temporal_truth … z tp.formula` | `Read` `ExistsForallNF.lean:49-56` | High |
| `bracketBuildRight` yields `∃ z1, t<z1 ∧ endRight.eval_at z1 ∧ bf.holds t z1` (endpoint at one point) | correctness lemma body | `Read` `VecEATranslation.lean:234-241` + `chainHolds:30-47` | High |
| Endpoint `char[y,x,t]=qnf` quant layer is arity-4 `∃w, nf_eval M k 4 [w,y,x,t] sub` | `nf_characteristic_quant_split3` RHS uses `Fin.cons w (zoneEnv3 …)` = arity-4 env | `Read` `NfZoneDepthK.lean:487-497` | High |
| Recursing that endpoint one depth down grows env arity each step (3→4→5…), terminating at depth 0 | quant layer of arity-n NF at depth d is arity-(n+1) at depth d-1; depth-0 NF is atomic (no quant layer) | Structural trace over `nf_eval_nf` succ-case (`NfZoneDepthK.lean:41-44`, `nf_eval_quant_layer:275-281`) | High |
| Arity-4+/NF-depth-tower is explicitly banned by the plan | *"Reintroduce any … arity-4+ existential converter … the durable failure mode across plans 11-38"* | `Read` plan v39:146 | High |
| Rabinovich caps free variables at ≤ 2 (Lemma 3.2.2) | *"equivalent to a conjunction of exists-forall formulas with at most two free variables"* | Literature quote `Rabinovich…md:78` | High |
| Rabinovich Cor 5.4 `F_i` chain uses single-point quantifier-free types over witnesses in one interval (no anchor growth) | `F_{i-1} := α_{i-1} ∧ (β_i Until F_i)`; `α_j,β_j` quantifier-free; witnesses `x_0<…<x_n` in `(z_0,z_1)` | Literature quote `…md:65-72,154-157` | High |
| Code treats quant witness `w` as a new anchor (env `[w,y,x,t]`) — the divergence from Rabinovich | `Fin.cons w (zoneEnv3 y x t)` extends the env rather than adding an interval witness | `Read` `NfZoneDepthK.lean:491` vs. `…md:65-72` | High |
| Per-variable projection route is a refuted NON-theorem at depth k+1 (not re-litigated here) | module DIVERGENCE NOTE; `liftIdx(totalUnskip)` non-injectivity | `Read` `NfZoneDepthK.lean:41-52`; accepted as prior finding | Medium |
| `NfZoneDepthK.lean` is genuinely sorry-free and off the live import path | 0 real `sorry` terms (all mentions in comments); no `import …NfZoneDepthK` in `Theories/` | `Bash` grep (`grep -E` sorry = 0; import grep = empty) | High |
| Live-path sorries are `KampPrior.lean:391` (n=1) and `:394` (n≥2); baseline top-level axioms = 2 | direct file read + grep | `Bash` `sed -n '387,394p'`; `grep '^axiom ' = 2` | High |
| D1 (flattening pilot) is the correct falsifiable probe of the make-or-break claim | The single unverified premise of the corrected route is "quant witness absorbs as a fixed-interval bracket witness"; D1 states exactly that at k=1 | Structural argument (not machine-checked) | Medium |
| The absorption in D1 will SUCCEED (Kamp's theorem route closes in this NF encoding) | Kamp's theorem is true, but the specific `NormalForm` encoding's non-injectivity refuted the projection route; absorption may hit the same wall | NOT verified — this is the open risk D1 exists to resolve | Low |

**Contradiction Log.** One contradiction surfaced and is resolved:

- *Handoff claim* ("no non-vacuous partial statement exists for the bridge; budget the whole body as one unit")
  vs. *this audit* ("D1 is a non-vacuous partial statement"). **Resolution** (precedence: primary-source + structural
  trace over prior handoff assertion): the handoff statement is true only *within the mis-framing* (recursive
  multi-anchor char). Under the corrected flattening framing (Rabinovich Lemma 3.2 + Cor 5.4), D1 is a concrete,
  falsifiable, `BracketFormula.holds`-valued iff — non-vacuous by construction. No unresolved contradiction remains.

**Low-confidence flag (honest).** The single claim I could not verify — and deliberately did not overclaim — is that
D1's absorption **succeeds**. It might fail for the same non-injectivity reason that refuted projection. That is
precisely why D1 is scoped as a **1-dispatch go/no-go gate** rather than the first step of a committed multi-dispatch
build: it converts the open mathematical risk into a bounded, decisive experiment instead of a fourth recession.

## 5. References

- Rabinovich 2014, "A Proof of Kamp's Theorem": Lemma 3.2 (`md:76-79`), Prop 3.5 (`md:87-94`), §5 / Cor 5.4
  (`md:119-157`), Key Insights (`md:208-230`). Local: `~/Projects/Literature/sources/rabinovich_2014/`.
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfZoneDepthK.lean` (landed sorry-free splits + module note).
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/VecEATranslation.lean:50,234,273,502` (bracket builders + correctness).
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/ExistsForallNF.lean:49-56` (`TemporalPred` / `eval_at`).
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean:374-416` (single-anchor IH engine; `:391`/`:394` sorries).
- `Theories/Bimodal/Metalogic/WeakCanonical/NormalForm.lean:433` (`doets_lemma_1_1` flattening bridge).
- `specs/305_rabinovich_ea_formula_implementation/plans/39_direct-nf-construction.md:128-192,339-452` (Postmortem
  Constraints + Phase 11 detail).
