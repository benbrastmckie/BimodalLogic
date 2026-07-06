# Report 38 — Prop 4.3 Unblock Design (task 305, Phase 4 blocker)

- **Task**: 305 (lean4, hard mode) — faithful Rabinovich path, plan v37
- **Session**: sess_1783306400_33dd64
- **Agent**: lean-research-hard-agent
- **Reference-grounding tier**: **Tier 1** (literature-backed — Rabinovich 2014, "A Proof of
  Kamp's Theorem", §3–4). Paper present at
  `specs/literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.md`.
- **Focus**: verify/design the recommended unblock path for Phase 4 (Prop 4.3): De Morgan
  restructure soundness, Lemma 3.2(1) complete conjunction, Lemma 3.4 arbitrary-position
  existential closure. Feasibility + phase decomposition + revise-vs-spawn.

## Executive Summary (verdicts)

1. **The De Morgan / positive-NF restructure of Prop 4.3 is NOT sufficient** to dodge the
   unfixable uniform negation. It merely *relocates* the obstruction from the `not` case to
   the `all` (universal) case. Over exists-forall formulas, universal-closure is
   equinumerous-in-difficulty with negation-closure (both are the "hard half" of Kamp's
   theorem, handled in the paper by Prop 4.2 = interval splitting). Verdict: **REJECT as a
   standalone unblock.**

2. **The live completeness path does NOT need a uniform Prop 4.3 at all.** The single live
   sorry that matters — `KampPrior.lean:391` (`nf_nvar_exist_all_depths … k 1`) — reduces to
   **Lemma 3.4 at m = 1** (absorb one order-unconstrained existential witness into a 1-point
   environment). It needs **no conjunction (3.2(1)) and no negation**. This is the surgical
   unblock and it is **HIGH-feasibility**.

3. **Recommendation: REVISE plan 37.** Replace the blocked uniform-Prop-4.3 Phase 4 with a
   narrow Lemma-3.4 build (leftward `existClosure` companion + n=1 position split) that clears
   `:391` directly, and re-scope Phase 5 to a direct existential-closure rewire rather than a
   full Prop 4.3 anchor. **Spawn a separate task** only if the standalone *uniform* Prop 4.3 is
   wanted as a library asset (that path additionally needs complete conjunction + a faithful
   bidirectional Prop 4.2 rebuild — LOW confidence, large).

## Findings

### H3 Lemma-level mapping table (Tier 1 — REQUIRED)

Each Rabinovich §3–4 lemma ↔ the Lean asset that realizes it, with verified status.

| Source (Rabinovich 2014) | Prop / Location | Lean Identifier | Type Signature (verified) | Status |
|---|---|---|---|---|
| Def 3.1 exists-forall formula (interval decomposition) | md:61–72 | `VecEA_m m` / `VVecEA_m m` | `structure VecEA_m (m) { endpointTypes : Fin m → TemporalPred; intervalBrackets : (i:Fin (m-1)) → Σ k, BracketFormula k }`; `VVecEA_m m := { disjuncts : List (VecEA_m m) }` | **PRESENT** (VecEA_m.lean:91–120). Note: brackets only *between consecutive* free vars — no unbounded left/right region. |
| Bracket notation 5.2 `[α₀,β₁,…,αₙ](z₀,z₁)` | md:108–132 | `BracketFormula n` | `{ pointTypes : Fin n → TemporalPred; segmentTypes : Fin (n+1) → TemporalPred }` | **PRESENT** (VecEAFormula.lean:128–132) |
| Lemma 3.2(1) — conj of EA ≡ **disjunction** of EA | md:77 | `VVecEA_m.conj` + `conjStruct` | `conj : VVecEA_m m → VVecEA_m m → VVecEA_m m`; `conj_holds : … → v1.holds → v2.holds → (v1.conj v2).holds` | **FORWARD-ONLY / INCOMPLETE** (VecEA_m.lean:161–182; over-approximates, VecEAClosure.lean:121–122,163–169). **Missing**: complete iff. |
| Lemma 3.2(2) — EA ≡ conj of ≤2-free-var EA (arity firewall) | md:78 | `VecEA_m.arity_firewall` | (Phase 2) sorry-free, off-path | **DONE** (plan 37 Phase 2 [COMPLETED], `lean_verify` clean) |
| Lemma 3.2(3) / Lemma 3.4 — closure under ∃ (rightmost) | md:79,84–85 | `VecEA_m.existClosure` (+ `_correct`, `_correct_rev`) | `existClosure : VecEA_m (m+1) → VecEA_m m`; iff via `existClosure_correct` (fwd, :245) + `existClosure_correct_rev` (bwd, :314) | **PARTIAL — rightmost only.** Genuine iff for absorbing the *rightmost* var under `StrictMono (extendEnv env z)`. |
| Lemma 3.4 — closure under ∃ (arbitrary position) | md:84–92 | *(none)* — needs `existClosureLeft` + position split | see design below | **MISSING** (leftward + middle absorption). |
| Def 3.3 V-exists-forall; disjunction closure | md:81–82 | `VVecEA_m.disj` (+ `disj_holds`) | `disj : VVecEA_m m → VVecEA_m m → VVecEA_m m`; `disj_holds : (v1.disj v2).holds ↔ v1.holds ∨ v2.holds` | **DONE — genuine iff** (VecEA_m.lean:131–148) |
| Prop 4.2 — negation of ≤2-var EA ≡ disj of EA (the hard part) | md:100–101, §5 | `neg_2var_vec_ea` (model-dep, EANegationClosure.lean:720); `neg_2var_vec_ea_indep` (model-indep, **forward only**, NegationIndep.lean:315) | model-dep biconditional sorry-free; model-indep `_correct : ¬v.holds → (neg v).holds` (:319) | **model-DEP: DONE**; **model-INDEP backward: UNFIXABLE** (NegationIndep.lean:331–363; report 18). |
| Prop 4.3 — every FO ≡ disj of EA (structural induction) | md:103–110 | `Prop43.lean` (atom/lt/tt/ff) | `atomAt_holds : (atomAt …).holds ↔ M.interp p (env i)`; `ltAt_holds : (ltAt i j).holds ↔ env i < env j` (StrictMono) | **atom/lt: DONE sorry-free** (Prop43.lean:81–109); **and/all/ex/not (uniform): BLOCKED** |
| Prop 3.5 — V-EA (1 free var) ≡ TL(U,S) | md:87–94 | `bracketBuildRight` (+ `_correct`) | `bracketBuildRight : BracketFormula n → TemporalPred → Formula` (VecEATranslation.lean:50) | **PRESENT** (rightward/Until nesting). Since-mirror `bracketBuildLeft` **MISSING**. |
| Lemma 5.1/5.3, INF (interval-splitting core, Dedekind) | md:134–173 | `HasAttainedINF` hypothesis; `neg_2var_vec_ea` uses it | INF 5.2 asset (used by `neg_vec_ea_m`, EAVecNegationClosure.lean:285) | **PRESENT** (model-dep). Faithful bidirectional (mutually-exclusive `Cond_i` partition) **NOT built**. |

### Literature Proof Structure (Rabinovich §3–4, verified against md:59–173)

- **Def 3.1**: an exists-forall formula existentially picks ordered points partitioning the
  chain into intervals; each point carries a QF type `αⱼ`, each interval a QF type `βⱼ`;
  `β₀` holds everywhere *before* `x₀`, `β_{n+1}` everywhere *after* `xₙ` (md:65–70). **The Lean
  `VecEA_m` encoding omits the unbounded β₀/β_{n+1} regions** and fixes the free-variable
  environment — this is the structural reason arbitrary-position ∃-closure is nontrivial here.
- **Closure basis actually proven directly** (md:76–85): `∨` (trivial), `∧` = **Lemma 3.2(1)
  → a *disjunction*** of EA (the merge/interleaving of two witness sequences is
  order-dependent), `∃` = Lemma 3.2(3)/3.4.
- **Prop 4.3 induction basis** (md:106–110): *Atomic, Disjunction, **Negation (via Prop 4.2)**,
  Exists (via Lemma 3.4)*. The paper's minimal basis is `{atomic, ∨, ¬, ∃}`; `∧` and `∀` are
  derived. **Negation is confronted head-on via Prop 4.2 (interval splitting), not sidestepped.**
- **Prop 4.2 (§5, md:119–173)**: negation of a bracket EA is a disjunction `⋁ᵢ (Condᵢ ∧ Formᵢ)`
  over an exhaustive case partition (endpoint failure / guard-succeeds-no-witness /
  interior-failure at `r₀ = inf{…}`), using **Dedekind completeness** to define `r₀` (`INF`,
  md:149). Mathematically this **is a biconditional** because the `Condᵢ` are exhaustive.

### Blocker 1 — Root framing (vacuity) + the De Morgan question (H4-verified)

- **Vacuity confirmed**: `neg_vec_ea_m` (EAVecNegationClosure.lean:285) has conclusion
  `∃ v' : VVecEA_m m, v'.holds env` under hypothesis `¬v.holds env`. Verified: it is closed by
  `⟨tt, tt_holds⟩` (Prop43.lean:45–58) independent of the formula — a per-model existential
  carries no translation content. So a non-vacuous Prop 4.3 requires a **uniform**
  `translate : MonadicFormula sig m → VVecEA_m m` with a model-independent correctness iff.
  **This part of the handoff is correct.**

- **Does the paper's negation sidestep the report-18 unfixable backward?** **NO.** The paper
  handles `not` via Prop 4.2, which in the paper is a genuine *biconditional* (exhaustive
  `Condᵢ` partition, md:161–173). What report 18 proved unfixable is **not the mathematics** —
  it is the codebase's *specific* construction `neg_vecEA2_indep`, whose three cases
  (`1a endpointLeft.neg`, `1b endpointRight.neg`, `23 bracket-negation`) **overlap and
  over-approximate**, so it is forward-only (NegationIndep.lean:352–356, verbatim: *"the three
  cases … overlap, and the backward direction bottoms out at … universal quantification over
  per-model bracket witnesses"*). The mathematical Prop 4.2 backward is **true**; the Lean
  unfixability is an artifact of an over-approximating encoding.

- **Is the De Morgan / positive-NF restructure sound and sufficient?** **Sound but NOT
  sufficient.** Verified reasoning:
  - `MonadicFormula` primitives are `{atom, lt, not, and, all, ex}` (MonadicFO.lean:216–223).
  - NNF pushes `not` to atoms. A negated atom is uniform and trivial (`atomAt` with the
    `false` literal, mirroring `atomAt_holds`, Prop43.lean:81–90) — so the general `not` case
    disappears. **But NNF keeps `all` as a primitive**, and the exists-forall class is **not**
    constructively closed under `∀` except via `∀x φ ≡ ¬∃x¬φ` — i.e. via negation = Prop 4.2.
  - Symmetrically, if one instead eliminates `all` via `all = not (ex (not ·))`, the general
    `not` returns.
  - **Either way, a general `not` OR a general `all` survives, and both require the uniform
    Prop 4.2 backward.** De Morgan relocates the obstruction; it does not remove it.

  **Corollary**: there is no cheap uniform Prop 4.3. The only genuine routes to it are
  (i) a faithful bidirectional Prop 4.2 rebuild (exhaustive `Condᵢ` partition per §5 — a large,
  LOW-confidence effort that is the real hard half of Kamp), or (ii) abandon the uniform anchor
  and stay on the model-dependent live path (recommended).

### Blocker 2 — Negation (uniform) — verdict: OUT OF SCOPE for the live path

Verified at NegationIndep.lean:357–363 (verbatim): Phase 3 took the *pre-authorized
model-dependent* interim — `neg_2var_vec_ea` (sorry-free, axioms
`[propext, Classical.choice, Quot.sound]`) — and *"The model-INDEPENDENT backward gap is a
known, bounded, follow-up item — it is NOT on the live completeness path."* The live completeness
argument uses model-dependent negation and is sorry-free for `not`. **No new work required for
the live path.** A uniform negation is required *only* for a standalone uniform Prop 4.3.

### Blocker 3 — Complete conjunction (Lemma 3.2(1)) — design

**Root cause (verified)**: `BracketFormula.conjStruct` (VecEAClosure.lean:109–122). When both
conjuncts carry witnesses (`n1+1, _+1` branch, :121–122) it returns
`⟨n1+1, ⟨bf1.pointTypes, fun _ => TemporalPred.top⟩⟩` — it keeps only bf1's witness points,
**discards bf2's witnesses, and tops-out every segment**. Hence `conjStruct_holds` (:126) is
forward-only (`both hold → conj holds`); the converse fails.

**Correct construction (common-refinement / interleaving disjunction = Lemma 3.2(1))**. Two
brackets `bf1 : BracketFormula n1`, `bf2 : BracketFormula n2` on the same interval `(z0,z1)`
assert two independent witness sequences. Their conjunction is the **merge** of the two
sequences, whose relative order is model-dependent, so the result is a **disjunction over all
merge patterns**:

```lean
/-- A merge letter records the origin of a merged witness point. -/
inductive MergeLetter | left | right | both
/-- Words with exactly `n1` occurrences using `left/both` and `n2` using `right/both`,
    in order; length `k` ranges over `max n1 n2 … n1+n2`. -/
def mergeWords (n1 n2 : Nat) : List { k // BracketMerge n1 n2 k }

/-- Complete conjunction of two brackets: a *disjunction* (list) of brackets,
    one per merge word. -/
def BracketFormula.conjComplete {n1 n2 : Nat}
    (bf1 : BracketFormula n1) (bf2 : BracketFormula n2) : List (Σ k, BracketFormula k)
-- per word W of length k:
--   pointTypes  j := conj of (bf1.pointTypes a  if W j uses left/both)
--                            (bf2.pointTypes b  if W j uses right/both)
--   segmentTypes s := (bf1.segmentTypes covering s).conj (bf2.segmentTypes covering s)

/-- COMPLETENESS upgrade over `conjStruct_holds`: a genuine iff. -/
theorem BracketFormula.conjComplete_holds {sig} (M) (atomMap)
    (bf1 : BracketFormula n1) (bf2 : BracketFormula n2) (z0 z1 : M.carrier) :
    (∃ bf ∈ bf1.conjComplete bf2, bf.2.holds M atomMap z0 z1)
      ↔ (bf1.holds M atomMap z0 z1 ∧ bf2.holds M atomMap z0 z1)
```

Proof sketch:
- `⟸` (the missing direction): from witnesses `w1` (bf1) and `w2` (bf2), sort `w1 ∪ w2` with
  coincidences identified, read off the merge word `W`; the `W`-disjunct holds with those
  merged witnesses. Each merged point is a `w1`- and/or `w2`-point so the conjoined point type
  holds; each open merged sub-segment lies inside exactly one bf1-segment and one bf2-segment,
  so the conjoined segment type holds.
- `⟹`: from `W`-disjunct witnesses `u`, project to the `left/both` positions (→ `w1`) and
  `right/both` positions (→ `w2`); bf1/bf2 hold by projecting the conjunctions.

`VVecEA_m.conj` then becomes: for each `(vea1, vea2)` disjunct pair, conjoin endpoints
(unchanged, VecEA_m.lean:156) and, per interval `i`, replace `conjStruct` by the
`conjComplete` **disjunction**, then distribute the per-interval disjunctions across intervals
(product) into `VVecEA_m` disjuncts. This is exactly Rabinovich Lemma 3.2(1) ("conj ≡
disjunction of EA").

**Feasibility: MEDIUM.** The `⟸` sort/merge argument is clean; the cost is the merge-word
combinatorics and `Fin` index bookkeeping (`leftPart`/`rightPart` at VecEAFormula.lean:360–371
are usable building blocks). Estimate **400–600 lines**. **Not needed for the live path** —
only for a standalone uniform Prop 4.3.

### Blocker 4 — Lemma 3.4 (arbitrary-position ∃-closure) — design (LIVE-PATH CRITICAL)

**Verified gap**: `existClosure` (VecEA_m.lean:208) absorbs only the **rightmost** var, folding
the interval `(z_{m-1}, z_m)` + endpoint at `z_m` into a temporal condition via
`bracketBuildRight` (Until-nesting). The De Bruijn `.ex α := ∃ x, eval M (Fin.cons x env) α`
(MonadicFO.lean:223) prepends `x` at **index 0 with no order constraint**. Bridging = split on
where `x` lands among the `m` existing points.

Three sub-pieces:

**(4a) Leftward existential closure** — the mirror of `existClosure`.
```lean
/-- Since-based mirror of `bracketBuildRight`; holds at z1 iff ∃ z0 < z1 with the
    endpoint + bracket on (z0,z1). Built from `Formula.snce` / `weak_since`
    (Formula.lean:474) — Since analog of the `Formula.untl` used by bracketBuildRight. -/
noncomputable def bracketBuildLeft : {n : Nat} → BracketFormula n → TemporalPred → Formula
theorem bracketBuildLeft_correct … -- Since-mirror of bracketBuildRight_correct (VecEATranslation.lean:234)

/-- Absorb the LEFTMOST var z0: fold interval (z0,z1)+endpoint(z0) into endpoint(z1). -/
noncomputable def VecEA_m.existClosureLeft {m : Nat} (vea : VecEA_m (m+1)) : VecEA_m m
theorem VecEA_m.existClosureLeft_correct  (hm : m ≥ 1) … :
    vea.existClosureLeft.holds M atomMap env →
      ∃ z, z < env ⟨0,_⟩ ∧ vea.holds M atomMap (prependEnv z env)
theorem VecEA_m.existClosureLeft_correct_rev (hm : m ≥ 1) … :
    z < env ⟨0,_⟩ → vea.holds M atomMap (prependEnv z env) →
      vea.existClosureLeft.holds M atomMap env
```
All primitives exist (`Formula.snce`, `weak_since`, `all_past`; VecEAFormula `leftPart` for
shifting). This is a **structural mirror of proven sorry-free code**. **Feasibility: HIGH.**
Estimate **250–400 lines** (bulk is re-deriving the Since analog of `bracketBuildRight_correct`
+ the witness-prepend lemma at VecEATranslation.lean:66).

**(4b) n = 1 position split → clears `KampPrior:391`.** For `m = 1` (env is a single point `t`),
a fresh `.ex` witness lands **before**, **at**, or **after** `t`:
```lean
∃ x, eval (Fin.cons x (fun _ => t)) φ
  ↔ (∃ x < t, φ) ∨ (φ[x := t]) ∨ (∃ x > t, φ)   -- disjunction of 3 arms
```
- `x < t` → `existClosureLeft` (4a);
- `x = t` → substitution `x := t` (arity-preserving; drops to a 1-point formula, handled by the
  existing atom/lt/NF machinery);
- `x > t` → existing `existClosure`.
Take `VVecEA_m.disj` of the three (`disj_holds` is a genuine iff, VecEA_m.lean:135). Wire the
result into `nf_nvar_exist_all_depths` at the `| 1 =>` arm (KampPrior.lean:387–391); its target
is `∃ x, nf_eval_nf M k 2 (Fin.cons x (fun _ => t)) sub_nf` (verified via `ih_exist_1`,
KampPrior.lean:305–331). **Feasibility: MEDIUM-HIGH.** Estimate **200–350 lines**. **This is the
step that removes the live-path sorry.**

**(4c, optional) General m arbitrary-position closure.** `m+1`-way disjunction: leftmost
(`existClosureLeft`), rightmost (`existClosure`), and `m−1` **middle** positions where the
witness folds into a merged bracket as an *internal* witness point:
```lean
/-- Insert a witness point (with its endpoint type) into a bracket, splitting the
    interval — the middle-absorption primitive. -/
def BracketFormula.insertPoint {n} (bf : BracketFormula n) (α : TemporalPred)
    (at : Fin (n+1)) : BracketFormula (n+1)
def VecEA_m.absorbMiddle {m} (vea : VecEA_m (m+1)) (k : Fin m) : VecEA_m m
def VecEA_m.existClosureAll {m} (vea : VecEA_m (m+1)) : VVecEA_m m   -- ⋁ over m+1 positions
theorem VecEA_m.existClosureAll_holds … :
    (vea.existClosureAll).holds M atomMap env ↔ ∃ x, vea.holds M atomMap (Fin.cons x env)  -- (up to StrictMono handling)
```
Middle absorption is fully constructive and model-independent (the witness becomes a bracket
interior point, no temporal build). **Feasibility: MEDIUM.** Estimate **350–500 lines.** Needed
only for `:394` (n≥2, off critical path) or a general uniform Prop 4.3.

## Feasibility verdicts (per piece)

| Piece | Rabinovich ref | Live-path? | Confidence | Line est. |
|---|---|---|---|---|
| **4a** `bracketBuildLeft` + `existClosureLeft` (+ iff) | Lemma 3.4 (left) | **YES** | **HIGH** | 250–400 |
| **4b** n=1 position split → clears `:391` | Lemma 3.4 (m=1) | **YES (the goal)** | **MEDIUM-HIGH** | 200–350 |
| 4c general-m arbitrary-position ∃-closure | Lemma 3.4 (full) | no (`:394`/uniform only) | MEDIUM | 350–500 |
| Complete conjunction `conjComplete` (iff) | Lemma 3.2(1) | no | MEDIUM | 400–600 |
| Uniform negation (bidirectional Prop 4.2 rebuild) | Prop 4.2 / §5 | no | **LOW** | 800–1500+ |
| Uniform standalone Prop 4.3 (needs all of the above) | Prop 4.3 | no | LOW | (sum) |

## Recommended phase decomposition (H8: one dispatch per phase)

**REVISE plan 37** — replace the blocked Phase 4 with:

- **Phase 4′ (revised)** — *Leftward existential closure*. Build `bracketBuildLeft`
  (+`_correct`), `VecEA_m.existClosureLeft` (+`_correct`/`_correct_rev`). Off live path,
  sorry-free, `lean_verify` clean. **HIGH**, ~250–400 lines. Territory: new decls in
  `VecEATranslation.lean` + `VecEA_m.lean` (append-only).
- **Phase 4″ (revised)** — *n=1 position split + live rewire*. Assemble the 3-arm disjunction;
  replace `KampPrior.lean:391` (`| 1 =>` arm) with it; `lake build` GREEN; confirm live-path
  sorry count drops from 2 → 1. **MEDIUM-HIGH**, ~200–350 lines. Territory: `KampPrior.lean`
  `:387–391` + the import rewire pre-surveyed in plan Phase 1.
- **Phase 5 (re-scoped)** — drop the "rewire through a uniform Prop 4.3" design; the direct
  existential-closure rewire in Phase 4″ subsumes it. Keep the acyclicity/import checks.
- **Phase 6** — unchanged: `lean_verify completeness_discrete` reachability for `:394`; audit
  axioms/sorryAx.

**SPAWN a separate task** (only if the standalone *uniform* Prop 4.3 is desired as a library
asset, independent of completeness): "Faithful uniform Prop 4.3 — complete conjunction
(Lemma 3.2(1) `conjComplete`) + bidirectional Prop 4.2 (§5 exhaustive `Condᵢ` partition) +
`existClosureAll`." This is the genuine hard half of Kamp and should not gate completeness.

### Revise vs Spawn — decision

**REVISE plan 37** for the live-path Lemma-3.4 work (4′/4″). Rationale: it clears the actual
objective (`:391`), builds directly on preserved sorry-free assets (`existClosure`,
`disj_holds`, `atomAt`/`ltAt`, INF, model-dependent negation), and advances the plan's own
Phase 5/6 — no new task boundary is warranted. **SPAWN** only the uniform-Prop-4.3 research
(conjunction + faithful Prop 4.2), which is large, LOW-confidence, and off the completeness
path.

## Preserved assets (do not re-derive — verified sorry-free / present)

- `Prop43.lean`: `tt`/`tt_holds`, `ff`/`ff_not_holds`, `atomAt`/`atomAt_holds`,
  `ltAt`/`ltAt_holds` (Prop43.lean:45–109).
- `VecEA_m.existClosure` + `existClosure_correct` (:245) + `existClosure_correct_rev` (:314) —
  genuine rightmost iff.
- `VVecEA_m.disj` + `disj_holds` (genuine iff), `VVecEA_m.conj`/`conj_holds` (forward only).
- `bracketBuildRight` + `bracketBuildRight_correct` (VecEATranslation.lean:50,234).
- `neg_2var_vec_ea` (model-dep biconditional, sorry-free), `neg_2var_vec_ea_indep` +
  `_correct` (model-indep forward), `neg_vec_ea_m` (arity-m model-dep existential).
- `VecEA_m.arity_firewall` (Lemma 3.2(2), Phase 2, sorry-free).
- Live path shape: `nf_nvar_exist_all_depths` (`ih_exist_1`, KampPrior.lean:305–331) — `:391`
  target is `∃ x, nf_eval_nf … (Fin.cons x (fun _ => t)) sub_nf`.

## Adversarial Self-Verification

Claims re-challenged against primary sources; verification method = source read at exact
file:line (accepted H4 lean4 method) unless noted.

| Claim | Source/Counterexample | Verdict |
|---|---|---|
| The per-model existential Prop 4.3 is vacuous (closed by tt/ff for any φ) | `neg_vec_ea_m` concl. `∃ v', v'.holds env` (EAVecNegationClosure.lean:285–291) closed by `⟨tt, tt_holds⟩` (Prop43.lean:45–58) | **CONFIRMED** |
| Model-independent Prop 4.2 *backward* is UNFIXABLE, but *forward* is sorry-free | NegationIndep.lean:319 (`_correct` fwd) vs :331–356 (bwd unfixable: 3 overlapping cases) | **CONFIRMED** — unfixability is the *forward-only over-approximating construction*, not the mathematics |
| De Morgan/NNF restructure dodges the unfixable uniform negation | NNF eliminates general `not` but keeps `all`; `∀`-closure ≡ `¬∃¬` needs Prop 4.2 (MonadicFO.lean:216–223; paper basis md:106–110) | **REFUTED** — relocates `not`→`all`; NOT sufficient |
| The paper sidesteps negation syntactically (NNF) | Paper Prop 4.3 handles `not` via Prop 4.2 = interval splitting (md:109, §5); minimal basis `{atomic,∨,¬,∃}` (md:106) | **REFUTED** — paper confronts negation head-on; ∧,∀ are *derived* via ¬ |
| Live sorry `:391` needs only Lemma 3.4 (m=1), no conjunction/negation | `nf_nvar_exist_all_depths … k 1` target `∃ x, nf_eval_nf M k 2 (Fin.cons x (fun _=>t)) sub_nf` (KampPrior.lean:313, 387–391) | **CONFIRMED** |
| `conjStruct` over-approximates when both conjuncts carry witnesses | VecEAClosure.lean:121–122,163–169 — keeps bf1 points, tops all segments, drops bf2 | **CONFIRMED** |
| `existClosure` absorbs rightmost only; no re-indexing bridges the index-0 unordered `.ex` witness | VecEA_m.lean:208–232 (rightmost via `bracketBuildRight`); `.ex` prepends index 0 unordered (MonadicFO.lean:223); orders genuinely differ | **CONFIRMED** |
| `existClosure` is a genuine iff (rightmost) | `existClosure_correct` (:245) + `existClosure_correct_rev` (:314) both present | **CONFIRMED** |
| `bracketBuildLeft` buildable — Since primitives present | `Formula.snce`, `weak_since` (Formula.lean:474), `all_past` present; `bracketBuildRight` uses `Formula.untl` mirror | **CONFIRMED** (feasibility, not yet built) |
| Lemma 3.2(1) yields a *disjunction* (merge order-types), not a single EA | Rabinovich md:77 ("conj ≡ **disjunction** of EA"); merge order is model-dependent | **CONFIRMED** |
| Model-indep uniform negation is OFF the live completeness path | NegationIndep.lean:357–363 ("NOT on the live completeness path"); plan Phase 3 [COMPLETED] via model-dep interim | **CONFIRMED** |
| `conjComplete` `⟸` proof is HIGH confidence | Enumeration + Fin bookkeeping intricate; only sort/project argument is clean | **CORRECTED to MEDIUM** (was tempting to overstate) |

**No unresolved contradictions.** One recommendation modified after verification: the
conjunction-completeness feasibility was down-graded HIGH→MEDIUM given the merge-word
combinatorics.

## References

- Rabinovich (2014), *A Proof of Kamp's Theorem*, §3–4 —
  `specs/literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.md`.
- Prior task-305 artifacts: report 18 (negation unfixability), report 37 (critical audit),
  plan 37 (Phase 4 BLOCKED), handoff `phase-4b-prop43-blocker-20260624.md`.
