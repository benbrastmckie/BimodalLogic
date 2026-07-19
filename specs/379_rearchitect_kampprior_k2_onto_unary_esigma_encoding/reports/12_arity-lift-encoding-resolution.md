# Report 12 — Arity-2 → Arity-r Lift: Encoding-Gap Resolution (Phase 10b blocker)

- **Task**: 379 — rearchitect KampPrior K2 onto unary E[Σ] encoding
- **Type**: lean4 (hard mode, H2/H3/H4/H5; `--lit`)
- **Status**: researched
- **Scope**: blocker-resolution / design-resolution pass for Phase 10b (`efSat_negation_general`).
  No implementation proofs written. Deliverable is the recommended path + Lean construction sketch.
- **Reference grounding tier**: **Tier 1 (literature-backed)** — Rabinovich 2014, cited by PDF page
  (`~/Projects/Literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.pdf`;
  companion `.md` is corrupt and was not used).

---

## (a) Verdict — one paragraph

**Recommend Option 2: a `liftPair` completion-expansion sub-phase — but built as an *adaptation of
the already-landed `conjInterleave` chain-merge machinery*, not as a fresh from-scratch proof.** The
root cause is real and correctly diagnosed by the blocked dispatch, but it is a **Lean
representational obligation, not a mathematical gap in Rabinovich**: Rabinovich's ∨∃∀ object
(Def 3.3, p.4) is a disjunction of ∃∀-formulas with **no common-arity requirement**, and in the
Prop 4.3 negation case (p.6) the disjuncts `γ_iʲ` each carry **at most two free variables** (the ones
inherited from the Lemma 3.2(2) conjuncts), *not* all `r`. The Lean type `VeeExistsForall sig F r =
List (ExistsForallFormula sig F r)` is a *homogeneous-arity specialization* of Def 3.3 that forces
every disjunct to pin all `r` free variables via a total `pin`. Reconciling a ≤2-free-variable
disjunct with the arity-`r` context is therefore an encoding bridge, and the faithful bridge is
exactly the **Lemma 3.2(1) / Lemma 3.4-(∧) order-preserving chain merge** — which this codebase has
*already proven sorry-free as `conjInterleave_iff` (both directions)*. Option 2 introduces **no object
Rabinovich lacks and proves no novel mathematics**; it reuses a Rabinovich-sanctioned, already-landed
technique, and — decisively — it leaves the planned `efSat_negation_general` signature and the entire
downstream pipeline (γ/δ/ζ) **unchanged**, so it consumes the two green precursors and feeds Phase 11
exactly as planned. Options 1 and 3 are ruled out below on ripple/consumer-breakage grounds (not on
faithfulness): both force re-derivation of landed core work (the total-pin `ExistsForallFormula`, or
the homogeneous Phase-9 `veeConj_iff` / the γ/δ/Prop-3.5 type contract). This is an **additive** plan
revision — insert one sub-phase; touch nothing already green.

---

## (b) Rabinovich-grounded faithfulness argument (by PDF page)

### The five load-bearing facts from the paper

| # | Fact | PDF page | Verbatim / near-verbatim |
|---|------|----------|--------------------------|
| R1 | **A single ∃∀-formula has a TOTAL pin.** Def 3.1: `ψ(z₀,…,z_m) := ∃xₙ…∃x₀ (⋀_{k=0}^m z_k = x_{i_k}) ∧ (xₙ>…>x₀) ∧ ⋀αⱼ(xⱼ) ∧ ⋀(∀y)^{<x_j}_{>x_{j-1}}βⱼ(y) ∧ …`, with `i₀,…,i_m ∈ {0,…,n}`. | p.4 | "`⋀_{k=0}^m z_k = x_{i_k}`" — **every** free variable is pinned to an existential point. |
| R2 | **Lemma 3.2(2):** every ∃∀-formula ≡ a **conjunction** of ∃∀-formulas **with at most two free variables.** | p.4 | "Every ∃∀-formula is equivalent to a conjunction of ∃∀-formulas with at most two free variables." |
| R3 | **Lemma 3.2(1):** conjunction of ∃∀-formulas ≡ a **disjunction** of ∃∀-formulas. Lemma 3.4: ∨∃∀ closed under ∨, ∧, ∃. | p.4–5 | (used for the merge; the codebase's `conjInterleave`.) |
| R4 | **Def 3.3:** "A formula is a ∨∃∀ formula if it is equivalent to a **disjunction of ∃∀-formulas**." | p.4 | **No requirement that the disjuncts share a free-variable set / arity.** |
| R5 | **Prop 4.3 negation case:** `φ` ≡ `⋀_i ψ_i` (each `ψ_i` ≤2 free vars, by R2); `¬φ` ≡ `⋁_i ¬ψ_i`; each `¬ψ_i` ≡ `⋁_j γ_iʲ` (Prop 4.2, ∃∀-formulas); hence `¬φ` ≡ `⋁_i ⋁_j γ_iʲ`. | p.6 | The `γ_iʲ` have the free variables of `ψ_i`, i.e. **≤ 2**, not `r`. |

### The argument

1. **The total pin is faithful — for a single formula.** R1 shows Def 3.1 pins *every* declared free
   variable (`z_k = x_{i_k}`). So the Lean field `pin : Fin r → Fin (n+1)`
   (`ExistsForallFormula.lean:109`) is a *faithful* transcription of Def 3.1 for one ∃∀-formula. The
   blocked handoff's phrasing ("Rabinovich's conjuncts have non-occurring variables simply absent")
   is true only at the *level of which variables a given conjunct declares* — it is **not** that
   Rabinovich uses a partial pin inside a single formula. This distinction is what rules out Option 1
   as "more faithful": it is not.

2. **The friction lives at the disjunction, and Def 3.3 is heterogeneous.** By R4 a ∨∃∀-formula is
   *any* disjunction of ∃∀-formulas; the disjuncts need not declare the same variables. By R5, the
   negation `¬φ ≡ ⋁_i ⋁_j γ_iʲ` is precisely such a heterogeneous disjunction: each `γ_iʲ` declares
   ≤ 2 of the `r` context variables. **This is the crux.** The Lean `VeeExistsForall sig F r` forces
   every disjunct to declare all `r` (total pin over `Fin r`). That is a representational choice
   *narrower than Def 3.3*, and it is the sole source of the blocker.

3. **The bridge is Rabinovich's own merge (R3), already landed.** To present a ≤2-free-variable
   disjunct `γ` at arity `r` under `StrictMono env`, the `r−2` other (ordered) context points must be
   inserted into `γ`'s existential chain. Because `γ` is a *fresh* negation object (from
   `prop42_efSat_negation_general`) whose interior witness points are existentially chosen, the
   insertion position of a *middle* variable (`k < k' < l`) is model-dependent — so no *single*
   arity-`r` formula suffices, and one must **disjoin over the finite set of order-preserving
   insertions**. That disjunction-over-merges is *exactly* Lemma 3.2(1) / Lemma 3.4-(∧) (R3), which
   the codebase realizes as `conjInterleave` / `conjInterleave_iff` (`ConjInterleave.lean`, both
   directions landed sorry-free). **No new mathematics; a Rabinovich technique reused at a point the
   homogeneous encoding forces.**

**Conclusion.** Option 2 is faithful: it uses only Def 3.1 objects and the Lemma 3.2(1) merge, both
already in the paper and both already in the codebase. It manufactures no engine-like object that
"Rabinovich does not have" (the failure mode that abandoned the two prior attempts). The lift is an
elementary, provable biconditional whose hard direction (reverse/backward) has a landed analogue.

---

## (c) Concrete Lean construction sketch (recommended path)

**Target (UNCHANGED from plan 11 Phase 10b, lines 956–966):**

```lean
theorem efSat_negation_general … (ψ : ExistsForallFormula sig F r) :
    ∃ Φ : VeeExistsForall sig F r, ∀ env : Fin r → N.carrier, StrictMono env →
      (¬ efSat N env ψ ↔ veeSat N env Φ)
```

The signature does **not** change — only new *helper* lemmas are inserted before the assembly.

### New primitive 1 — arity-`r` skeleton (trivial chain)

```lean
/-- `r` ordered existential points, one per free variable, ⊤ point/interval types.
    Satisfied by every `StrictMono env`. -/
noncomputable def skelR (r : Nat) : ExistsForallFormula sig F r   -- n := r-1, pin := id, ⊤ types

theorem skelR_sat (N) (env : Fin r → N.carrier) (h : StrictMono env) :
    efSat N env (skelR r)
```

(Needs a ⊤ `UnaryType` and the full `IntervalType` — the everywhere-admissible completion set;
`intervalHolds` at ⊤ is trivially true, cf. `IntervalType.lean`.)

### New primitive 2 — the pair lift (the genuine content)

```lean
/-- Lift a single arity-2 ∃∀-formula `ξ`, occurring at context positions `k < l`, to an
    arity-`r` ∨∃∀-formula. Disjoins over every order-preserving insertion of the `r-2` other
    (⊤-typed) free-variable points into `ξ`'s chain, copying `ξ`'s interval type to each split
    interval. Built on the ConjInterleave `MergePair` / `mergedFormula` infrastructure. -/
noncomputable def liftPair (ξ : ExistsForallFormula sig F 2) (k l : Fin r) :
    VeeExistsForall sig F r

/-- Correctness of the pair lift — an adaptation of `conjInterleave_iff`. -/
theorem liftPair_iff (N) (env : Fin r → N.carrier) (h : StrictMono env)
    (ξ : ExistsForallFormula sig F 2) (k l : Fin r) (hkl : k < l) :
    veeSat N env (liftPair ξ k l) ↔ efSat N ![env k, env l] ξ
```

**Why it is a genuine biconditional (adversarially checked, see (e)):**
- **Forward** (`efSat ![env k,env l] ξ → veeSat env (liftPair …)`): from `ξ`'s chain `x`, the actual
  env points `z_i (i≠k,l)` land in specific intervals of `x` (below/between/above); that placement is
  one enumerated merge; its merged arity-`r` formula holds (⊤ point types on inserted points; `ξ`'s
  β copied onto split sub-intervals still holds because they are sub-intervals).
- **Reverse** (`veeSat env (liftPair …) → efSat ![env k,env l] ξ`): any holding merge restricts to a
  chain witnessing `ξ` (inserted points are ⊤, imposing nothing on `ξ`; split intervals recombine to
  `ξ`'s originals). `z_k,z_l` are pinned to the right points by construction.

Both directions mirror `conjInterleave_forward` / `conjInterleave_backward`
(`ConjInterleave.lean:60–62, 979–986`), which are landed sorry-free.

### New primitive 3 — sentence lift (degenerate `r`=0 case, for the existence disjunct)

```lean
/-- Lift the arity-0 negation object of the existence sentence to arity `r`
    (insert all `r` context points; no fixed pins). Degenerate `liftPair`. -/
noncomputable def liftSentence (ξ : ExistsForallFormula sig F 0) : VeeExistsForall sig F r

theorem liftSentence_iff (N) (env : Fin r → N.carrier) (h : StrictMono env)
    (ξ : ExistsForallFormula sig F 0) :
    veeSat N env (liftSentence ξ) ↔ efSat N ![] ξ
```

### Assembly (composes only through landed + the three new lemmas)

```lean
theorem efSat_negation_general … : ∃ Φ, ∀ env, StrictMono env → (¬ efSat N env ψ ↔ veeSat N env Φ) := by
  -- Φ := (pairwiseProjections ψ).flatMap (fun (k,l,_) => liftPair (Φ_{k,l} disjuncts) k l)
  --        ++ liftSentence (existence-negation object)
  -- Chain of iffs, all landed except liftPair_iff/liftSentence_iff:
  --   veeSat env Φ
  --     ↔ (∃ (k,l), veeSat env (liftPair Φ_{k,l} k l)) ∨ veeSat env (liftSentence …)   -- veeSat_append / veeSat_flatMap (landed)
  --     ↔ (∃ (k,l), veeSat ![env k,env l] Φ_{k,l})     ∨ efSat ![] (existence-neg)     -- liftPair_iff, liftSentence_iff (NEW)
  --     ↔ (∃ (k,l), ¬ efSat ![env k,env l] (pairProject ψ k l)) ∨ ¬ efSat ![] (existenceSentence ψ)
  --                                                                                    -- efSat_negation_pair (LANDED, EFSatNegation.lean)
  --     ↔ ¬ efSat env ψ                                                                -- efSat_negation_demorgan (LANDED, EFSatNegation.lean)
```

**Landed lemmas it composes through** (do NOT re-prove):
`efSat_negation_pair`, `efSat_negation_demorgan` (`EFSatNegation.lean`); `veeSat_append`,
`veeSat_singleton` (`VeeExistsForall.lean:72,58`); `veeSat_flatMap` (`VeeConj.lean:40`);
`augTarget_iff`, `pairwiseProjections`, `pairProject`, `existenceSentence` (`ExistsForallLemmas.lean`);
and — as the *technique reused inside `liftPair`* — `MergePair` / `mergedFormula` / `mergedSet` /
`conjInterleave_forward` / `conjInterleave_backward` (`ConjInterleave.lean`).

**Diagonal (`pin k = pin l`) and orientation:** unchanged from plan (route the same-index / `pin k =
pin l` diagonal to the arity-1 Prop 3.5 negation; `StrictMono` forces `env k ≠ env l` for `k ≠ l`).
These are orthogonal to the lift and already specified in Phase 10b tasks 3–4.

---

## (d) Size / risk estimate and plan-revision recommendation

| Item | Est. lines | Risk | Notes |
|------|-----------|------|-------|
| `skelR` + `skelR_sat` (⊤ types) | 40–80 | Low | Needs ⊤ `UnaryType` / full `IntervalType`; check `IntervalType.lean` for an existing top. |
| `liftPair` + `liftPair_iff` | 200–400 | **Medium** | The real content. Reverse direction = adaptation of landed `conjInterleave_backward`. Risk driver: whether `MergePair`/`mergedFormula` are cleanly reusable for "one fixed arity-2 chain + `r−2` free insertions" or need a small generalization. |
| `liftSentence` + `liftSentence_iff` | 60–120 | Low–Med | Degenerate `liftPair` (no fixed pins); may reuse `liftPair` internals. |
| `efSat_negation_general` assembly | 60–120 | Low | Pure glue over landed + the three new lemmas. |
| **Total** | **~360–720** | **Medium** | One-to-two focused dispatches. |

**De-risking spike (do FIRST, ≤1 hour):** before writing fresh merge code, attempt to *invoke*
`conjInterleave`/`mergedFormula` via a "skeleton merge" reformulation. Note the obstruction found in
this research: `conjInterleave (ψ₁ ψ₂ : … r)` reads each formula's **structure** `pin` inside `efSat`,
so it cannot be fed an arity-2 `ξ` directly (that is the lift itself). Expect to reuse the *internal*
`MergePair`/`mergedFormula`/`mergedSet`/sorted-union-rank pieces rather than call `conjInterleave`
verbatim. If those internals are `private`/too specialized, budget toward the upper bound.

**Plan revision: YES, but purely additive.** Insert one sub-phase (e.g. **Phase 10b-i `liftPair`**)
between the two landed precursors and the `efSat_negation_general` assembly (now **Phase 10b-ii**).
Nothing downstream changes: β keeps its planned signature; γ (Phase 11), δ (Phase 12), ζ (Phase 13),
and the landed Phase-9 `veeConj_iff` / `veeSat_append` / `veeSat_exists` are untouched. `hCapture`
stays threaded (never discharged here). Recommend `/revise` plan 11 to add Phase 10b-i; the
orchestrator may alternatively dispatch the sketch above directly, since the target signature is
already fixed in the plan.

**Consumer verification (why Options 1/3 are ruled out, checked against plan + landed code):**
- Phase 11 γ `veeSat_negation` returns `VeeExistsForall sig F r` and reassembles via the **landed
  homogeneous** `veeConj_iff` (`VeeConj.lean:61`) — plan lines 1066–1088.
- Phase 12 δ `translate_correct` returns/consumes `VeeExistsForall sig F m` and routes `not`→γ,
  `and`→`veeConj`, `or`→`veeSat_append`, `ex`→`veeSat_exists` — plan lines 1092–1120.
- Phase 13 ζ consumes δ + Prop 3.5 (1-free-variable ∨∃∀→TL).
- **Option 3 (restate β to a heterogeneous / natural-arity aggregate)** would change the type γ/δ
  consume and would *not* escape interleaving — conjoining heterogeneous disjuncts in γ's `veeConj`
  re-introduces the same chain-merge, but now against a Phase-9 `veeConj_iff` built for homogeneous
  arity `r`. Net: re-derive Phase 9 + re-type γ/δ/ζ. **Rejected (consumer breakage + ripple).**
- **Option 1 (partial-pin `ExistsForallFormula`)** changes the core `pin` field, rippling into
  `efSat`, the `prop42_efSat_negation_general` engine, `conjInterleave`, `translateProp42`,
  `collapseEF`, `vvecea2_collapse_bridge`, and Phase-9 `veeConj_iff` — the ~3,000-line landed critical
  path. Faithfulness gain over total-pin is **nil** (R1: Def 3.1 pins are total). **Rejected (massive
  regression risk, no faithfulness benefit).**

---

## (e) Adversarial Self-Verification (H4)

Every load-bearing claim challenged; verification method and confidence recorded. `lean_*` methods
denote source/type facts confirmed by reading the cited declaration this dispatch.

| Claim | Source / Counterexample | Verification method | Confidence |
|-------|-------------------------|---------------------|------------|
| Def 3.1 pins **every** free variable (`⋀ z_k = x_{i_k}`), so total `pin` is faithful for one formula | Rabinovich Def 3.1, PDF p.4 (read the page image) | PDF page read + `ExistsForallFormula.lean:105–115` field read | **High** |
| Rabinovich's ∨∃∀ (Def 3.3) has **no** common-arity requirement; negation disjuncts `γ_iʲ` have ≤2 free vars | Def 3.3 p.4; Prop 4.3 negation case p.6 (read) | PDF page read | **High** |
| Lean `VeeExistsForall sig F r` forces homogeneous arity-`r` total pin on every disjunct | `List (ExistsForallFormula sig F r)` | `VeeExistsForall.lean:35–42` read | **High** |
| The middle-variable obstruction is REAL (non-adjacent pairs reachable): `pairwiseProjections` uses ALL ordered pairs, not just adjacent | Could have been adjacent-only (would trivialize) | `ExistsForallLemmas.lean:139–142` read — `flatMap`×`map` over `finRange r × finRange r` | **High** |
| The negation object `ξ` has existentially-chosen interior points (so a middle var's insertion slot is model-dependent) — confirms the agent's counterexample that **no single** arity-`r` lift is an iff | Agent's blocked-handoff counterexample | `efSat` definition `∃ x, StrictMono x ∧ …` (`ExistsForallFormula.lean:125–136`); `ξ` from engine `prop42_efSat_negation_general` | **High** — counterexample CONFIRMED for single-formula lift |
| …but the **disjunctive** lift (over insertions) IS a valid biconditional — the agent's counterexample does NOT block Option 2 | Same | Forward/reverse argument in (c); structurally identical to landed `conjInterleave_iff` | **High** — counterexample REFUTED as an obstruction to Option 2 |
| The required merge technique is already landed as a **both-directions** biconditional | Risk it was forward-only (blocker at reverse) | `ConjInterleave.lean:979–986` — `conjInterleave_iff` calls landed `conjInterleave_backward` AND `conjInterleave_forward` | **High** |
| Option 2 introduces **no object Rabinovich lacks / no novel math** | The abandoned-attempt failure mode | Uses only Def 3.1 objects + Lemma 3.2(1) merge (R1,R3); both in paper and codebase | **High** |
| Option 2 leaves β signature + γ/δ/ζ pipeline UNCHANGED | Downstream might need the total-pin shape (it does — and Option 2 preserves it) | plan 11 lines 956–966 (β), 1066–1120 (γ/δ); `VeeConj.lean:61` (`veeConj_iff` homogeneous) | **High** |
| Option 3 does not escape interleaving (defers it to γ's `veeConj` against homogeneous `veeConj_iff`) | Option 3 might be lighter | Landed `veeConj`/`veeConj_iff` are homogeneous arity-`r` (`VeeConj.lean:52,61`) | **High** |
| Option 1 has no faithfulness benefit over total pin | Option 1 pitched as "more faithful" | R1 (Def 3.1 pins are total) | **High** |
| `conjInterleave` cannot be called *verbatim* on an arity-2 `ξ` (it reads each formula's structure pin inside `efSat`) — so `liftPair` reuses internals, not the top-level call | Hoped for a one-line reuse | `ConjInterleave.lean:238–246` (`conjInterleave` sig) + `conjInterleave_iff` stated at `ψ.pin` | **Medium** — reuse boundary is the main size-risk driver |
| No `liftPair` / trivial-`skelR` / `veeSat_negation` / `translate` exists yet | — | grep of `Kamp/` returned none (skeleton, liftPair, veeSat_negation, translate absent; `veeSat_exists` present) | **High** |
| Size ~360–720 lines, Medium risk | Could be higher if `MergePair` internals are not reusable | Bounded by landed `conjInterleave` (~980 lines incl. all infra); `liftPair` is a narrower adaptation | **Medium** |

**Contradiction log:** No unresolved contradictions. One *apparent* tension resolved: the agent's
"the lift is not an iff" is TRUE for a single arity-`r` formula and FALSE for the disjunctive lift;
both halves are captured above (rows 5–6). The blocked handoff correctly listed Option 2 as a
resolution; this report confirms it and adds the decisive reuse + faithfulness grounding.

**Recommendations modified after verification:** the blocker framed Option 2 as "~several hundred
lines with its own correctness proof." Verification of `ConjInterleave.lean` (a landed both-directions
merge biconditional) downgrades this to an *adaptation* with a landed reverse-direction analogue —
the estimate and risk are lowered accordingly, and a ≤1-hour reuse spike is prepended.

---

## Memory candidates

1. Rabinovich's ∨∃∀ (Def 3.3, p.4) is a disjunction of ∃∀-formulas with **no common-arity
   requirement**; a Lean encoding as `List (ExistsForallFormula sig F r)` (homogeneous total pin) is a
   *specialization* that is faithful for positive/conjunction/∃ closure but forces an explicit
   arity-lift for the Prop 4.3 negation case, where disjuncts carry ≤2 free variables.
2. In this codebase, lifting a low-arity ∃∀-formula to the arity-`r` context under `StrictMono` is the
   *same* order-preserving chain-merge as Lemma 3.2(1) conjunction — reuse `ConjInterleave.lean`'s
   `MergePair`/`mergedFormula`/`mergedSet` internals rather than writing fresh merge code; its
   biconditional (`conjInterleave_iff`) is landed both-directions, so the usual reverse-direction wall
   is already solved.
3. When a blocked Lean handoff says "the lift is not an iff," check whether the claim is about a
   *single* target object vs. a *disjunction*: a single arity-`r` ∃∀ cannot capture a model-dependent
   insertion, but the finite disjunction over insertions can — the negative result about one object is
   not a negative result about the ∨∃∀ lift.
