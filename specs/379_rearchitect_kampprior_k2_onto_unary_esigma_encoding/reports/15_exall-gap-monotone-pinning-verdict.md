# Phase 12 (δ `translate`) — ex/all Gap-Disjunct Monotone-Pinning Verdict (H5 divergence audit)

**Task**: 379 · **Phase**: 12 (δ `translate`, `translate_correct` ex/all `sorry`s at `:439`/`:448`)
**Agent**: lean-research-hard-agent · **Mode**: H5 divergence audit + H2/H3/H4 hard
**Scope**: single open question — does `translate`'s output pin the environment at monotone ranks
in its internal ∃∀ chain? (the crux report 14 §4 flagged UNVERIFIED)

**Anchors read (current source, not report-14's 191-line snapshot — file is now 453 lines)**:
`Prop43Translate.lean` (all 453 lines), `VeeSatNegation.lean` (all 123), `EFSatNegationGeneral.lean:300-470`,
`ExistsForallFormula.lean:100-161` (`efSat` def), `ExistsForallLemmas.lean:172-269` (`dropPin`, `veeSat_exists`),
`LiftPair.lean:83-260,553-672,843-880,1121-1140` (lifts + `valid`/`valid1`/`validS`),
`ConjInterleave.lean:150-247` (`MergePair.valid`, `mergedFormula`), `VeeConj.lean:45-70` (`veeConj`),
`NormalForm.lean:130-207` (`nf_eval_nf`), `ExistsForallFormula.lean:52-71` (`unaryHolds`).

---

## 0. Verdict (3 lines)

- **Monotone pinning: YES.** Every disjunct `translate` emits carries a **strictly monotone `pin`**,
  and `efSat`'s internal chain is `StrictMono`; since `env = x ∘ ψ.pin` (pin clause), the environment
  is forced `StrictMono`, so the gap witness is pinned into gap `p` automatically. **No explicit
  `lt`-skeleton order-constraint conjunct is needed** — the gap disjunct closes as-is.
- **Closure recipe (one sentence):** strengthen `translate_correct`'s conclusion with the invariant
  `∀ ψ ∈ Ψ, StrictMono ψ.pin`; then the gap disjunct's forward direction is pure glue —
  `veeSat_exists` gives a witness `a`, `veeSat_renamePin` moves it to `insertNth p a env`, the
  invariant forces that chain `StrictMono`, hence `a ∈ gap p`, and the size-smaller IH on
  `α.rename (insertPerm p)` fires via `eval_insertNth_rename`.
- **Residual risk (one place):** the sole non-monotone pin in the whole pipeline is `efArb`
  (`VeeSatNegation.lean:77`, `pin := fun _ => 0`), emitted by `veeSat_negation`'s **nil** branch when
  negating an *empty* translation (`.not (.lt i j)` with `j ≤ i`). It is harmless in the gap forward
  direction for outer arity `m ≥ 2` and is neutralized by a one-line swap of the nil-case witness (see §5).

---

## 1. Reference grounding — Tier 1 (Rabinovich 2014, Prop 4.3 / Def 3.1 / Lemma 3.2(1)/3.4)

| Source (Rabinovich 2014) | Prop/Location | Lean identifier | Type signature (source-verified) | Status |
|---|---|---|---|---|
| Def 3.1, p.4 | ∃∀ satisfaction: `n+1`-point **StrictMono** chain, pin clause `env k = x(pin k)` | `efSat` | `∃ x, StrictMono x ∧ (∀ k, env k = x (ψ.pin k)) ∧ …` | LANDED `ExistsForallFormula.lean:125-136` |
| Lemma 3.2(1), p.4 | arity-lift merge, embeddings **StrictMono**, pin `= eS` | `LiftMergePair.valid{,1,S}` / `liftMergedFormula` | `valid … : StrictMono m.eξ ∧ StrictMono m.eS ∧ …`; `liftMergedFormula.pin := m.eS` | LANDED `LiftPair.lean:164-168,232,580-582,849-853` |
| Lemma 3.2(1), ∧-part / 3.4 | conjunction merge, embeddings **StrictMono**, pin `= e₁∘pin₁` | `MergePair.valid` / `mergedFormula` / `veeConj` | `valid … : StrictMono m.e₁ ∧ …`; `mergedFormula.pin := fun v => e₁ (pin₁ v)`; `veeConj … conjInterleave ψ φ ψ.pin φ.pin` | LANDED `ConjInterleave.lean:161-168,230`, `VeeConj.lean:52` |
| Lemma 3.4, ∃-closure, p.5 | drop the rank-0 pin | `dropPin` / `veeSat_exists` | `dropPin.pin := fun k => ψ.pin k.succ`; `(∃ a, veeSat (cons a env) Ψ) ↔ veeSat env (Ψ.map dropPin)` | LANDED `ExistsForallLemmas.lean:179-226` |
| Prop 4.3, ¬-case, p.6 | negation as `∨∃∀` | `efSat_negation_general` / `veeSat_negation` | assembles `liftPairV/liftSingleV/liftSentenceV` disjuncts (all StrictMono pins) | LANDED `EFSatNegationGeneral.lean:369`, `VeeSatNegation.lean:88` |
| — | free-var permutation naturality on ∃∀ side | `renamePin` / `veeSat_renamePin` | `renamePin.pin := fun k => ψ.pin (τ k)`; `veeSat (Ψ.map (renamePin σ)) ↔ veeSat (env∘σ.symm) Ψ` | LANDED `Prop43Translate.lean:204-247` |
| — | gap-insertion permutation | `insertPerm` / `insertPerm_succ` / `eval_insertNth_rename` | `insertPerm p 0 = p`, `insertPerm p j.succ = p.succAbove j`; `eval (insertNth p x env) (α.rename (insertPerm p)) = eval (cons x env) α` | LANDED `Prop43Translate.lean:258-305` |
| Mathlib | `succAbove` is an order-embedding | `Fin.strictMono_succAbove` | `(p : Fin (n+1)) : StrictMono p.succAbove` | Mathlib `Order.Fin.Basic` (loogle-confirmed) |

---

## 2. The definitive YES chain (source-cited)

### 2.1 The general `efSat` order-reflection fact

`efSat N env ψ` unfolds (`ExistsForallFormula.lean:125-136`) to
`∃ x, StrictMono x ∧ (∀ k, env k = x (ψ.pin k)) ∧ …`. The pin clause states exactly
`env = x ∘ ψ.pin` (extensionally). Therefore:

> **Fact (P-comp).** If `ψ.pin` is `StrictMono`, then any `env` with `efSat N env ψ` satisfies
> `env = x ∘ ψ.pin` with `x` `StrictMono`, hence `env` is `StrictMono` (`StrictMono.comp`).

This is *unconditional* on the model. The pin's order type is imprinted on the environment because
the witness chain is strictly increasing. This is the whole mechanism by which "monotone pinning"
forces gap placement.

### 2.2 Every `translate` disjunct has a `StrictMono` pin (structural invariant)

Checked constructor-by-constructor against current source. Write `Π(φ)` for
"every disjunct of the emitted `Ψ` has `StrictMono pin`":

- **atom** (`Prop43Translate.lean:401-407`): `atomEmit i S` disjuncts are `skelDisjunct m σ`
  with `pin := id` (`LiftPair.lean:90`). `StrictMono id`. ✔
- **lt** (`:409-420`): `skelR m'` (all `skelDisjunct`, `pin := id`) or `[]` (vacuous). ✔
- **and** (`:427-432`): `veeConj Ψα Ψβ = conjInterleave … ψ.pin φ.pin` disjuncts are
  `mergedFormula`, `pin := fun v => e₁ (pin₁ v)` (`ConjInterleave.lean:230`). `conjInterleave`
  only includes merges with `m.valid pin₁ pin₂`, which forces `StrictMono m.e₁`
  (`ConjInterleave.lean:161-168`). With `pin₁ = ψ.pin` `StrictMono` by IH, the composite
  `e₁ ∘ pin₁` is `StrictMono`. ✔
- **not** (`:421-426`): output of `veeSat_negation`. In the **cons** branch
  (`VeeSatNegation.lean:114-121`) it is `veeConj Gψ Φrest`; `Gψ` disjuncts come from
  `efSat_negation_general`, which are `liftPairV`/`liftSingleV`/`liftSentenceV` disjuncts. Each of
  those is a `liftMergedFormula` with `pin := m.eS` (`LiftPair.lean:232`), and the lift only admits
  merges with `valid`/`valid1`/`validS`, **all of which require `StrictMono m.eS`**
  (`LiftPair.lean:166,581,851`). `Φrest` is `StrictMono`-pinned by IH; `veeConj` preserves as above. ✔
  **Exception:** the **nil** branch (`VeeSatNegation.lean:101-113`) emits `Gd ++ [efArb]`; `efArb`
  has `pin := fun _ => 0` (`VeeSatNegation.lean:77`) — **not** `StrictMono` for arity `≥ 2`. See §4.
- **ex/all gap** (`:440-448`, planned): the emitted gap disjunct is
  `(Ψ_p.map (renamePin (insertPerm p))).map dropPin`. Its per-disjunct pin computes to
  `fun (k : Fin m) => ψ.pin (p.succAbove k)` — because `renamePin (insertPerm p)` gives
  `pin k = ψ.pin (insertPerm p k)` and `dropPin` reindexes `k ↦ (·).succ`, and
  `insertPerm p (k.succ) = p.succAbove k` (`Prop43Translate.lean:269-271`). With `ψ.pin` `StrictMono`
  (IH on `α.rename (insertPerm p)`) and `Fin.strictMono_succAbove`, the composite is `StrictMono`. ✔
- **ex/all tie** (planned): the tie disjunct is `translate(α.subst0 i)` at arity `m`; `StrictMono`-pinned
  directly by IH (no pin surgery — `subst0` acts on the `MonadicFormula`, not the ∃∀ pin). ✔

So `Π` is preserved by every constructor; base cases (atom/lt) have `id`/empty pins. **`Π(φ)` holds
for all `φ`** (well-founded on `MonadicFormula.size`), modulo the `efArb` exception.

### 2.3 Why this closes the gap disjunct as-is (pure glue)

Forward direction of gap `p` (outer `.ex α` at arity `m`, `env : Fin m` `StrictMono`):

1. Assume `veeSat N env D_p` with `D_p = (Ψ_p.map (renamePin (insertPerm p))).map dropPin`.
2. `veeSat_exists` (`ExistsForallLemmas.lean:214`) ⇒ `∃ a, veeSat N (Fin.cons a env) (Ψ_p.map (renamePin (insertPerm p)))`.
   **The `a` is unconditional** — this is the whole worry.
3. `veeSat_renamePin` (`Prop43Translate.lean:234`) with `σ = insertPerm p` and
   `cons_comp_insertPerm_symm` (`:286`) ⇒ `veeSat N (Fin.insertNth p a env) Ψ_p`.
4. **Invariant `Π(α.rename (insertPerm p))` (from strengthened IH) + Fact (P-comp)** ⇒
   `Fin.insertNth p a env` is `StrictMono`.
5. `Fin.insertNth p a env` `StrictMono` ⟺ `a` sits in gap `p` (env's `p-1`-th < `a` < env's `p`-th).
   So the unconditional `a` from step 2 is *forced* into gap `p`. **This is the payoff of monotone pinning.**
6. The size-smaller IH (`size_rename`, `size (α.rename ρ) = size α < size (.ex α)`) on
   `α.rename (insertPerm p)` at the `StrictMono` chain `insertNth p a env` gives
   `veeSat N (insertNth p a env) Ψ_p ↔ eval N (insertNth p a env) (α.rename (insertPerm p))`.
7. `eval_insertNth_rename` (`:299`) rewrites the RHS to `eval N (Fin.cons a env) α`. Hence
   `eval N (cons a env) α`, i.e. `∃ x, eval N (cons x env) α = eval N env (.ex α)`. ∎

Backward direction is unchanged from the report-14 plan (trichotomy classification of the eval
witness selects the matching gap/tie disjunct; each disjunct is *satisfiable* at the corresponding
order type, which is the already-landed content of `skelR_sat`/`veeSat_exists`).

**Conclusion:** monotone pinning is present, is the exact reason the unconditional `veeSat_exists`
witness cannot escape gap `p`, and requires **no** added order-constraint conjunct. Verdict **YES**.

---

## 3. New obligations for the final assembly dispatch (5-column mapping table)

The YES route is *not* turnkey against the current statement: `translate_correct`'s conclusion does
**not** expose pin-monotonicity, so the IH does not currently hand you step 4 above. The single
structural change is to **strengthen the conclusion**; everything else is glue. All obligations below
are small and reduce to already-landed `valid`/`StrictMono` facts.

| Obligation | Target signature | Existing lemma to adapt | File:line | Gap |
|---|---|---|---|---|
| Strengthen the theorem | `∃ Ψ, (∀ ψ ∈ Ψ, StrictMono ψ.pin) ∧ ∀ env, StrictMono env → (veeSat N env Ψ ↔ eval N env φ)` | current `translate_correct` conclusion | `Prop43Translate.lean:396` | Add the conjunct; re-thread through all 6 arms (4 landed arms gain a trivial pin-mono side goal) |
| skeleton pin mono | `∀ σ, StrictMono (skelDisjunct m σ).pin` | `skelDisjunct.pin = id` | `LiftPair.lean:90` | `StrictMono id` — trivial |
| conj pin mono | `∀ ψφ, StrictMono ψ.pin → (mergedFormula … ψ.pin e₁ e₂).pin StrictMono` | `MergePair.valid.1` (`StrictMono e₁`) | `ConjInterleave.lean:161-168,230` | `(hvalid.1).comp hψpin`; ~12 lines + `veeConj`/`flatMap` membership plumbing |
| lift pin mono | `∀ χ ∈ liftPairV/liftSingleV/liftSentenceV Ψ …, StrictMono χ.pin` | `valid.2.1`/`valid1.2.1`/`validS.2.1` (`StrictMono eS`); `liftMergedFormula.pin = eS` | `LiftPair.lean:166,232,581,851` | extract `eS` mono from the filter predicate through `flatMap`; ~20 lines total for 3 families |
| negation pin mono | `∀ χ ∈ (veeSat_negation … Φ), StrictMono χ.pin` | above two, per branch | `VeeSatNegation.lean:88` | cons branch = veeConj(lift, IH); **nil branch = efArb — see §5** |
| gap-disjunct pin mono | `StrictMono (dropPin (renamePin (insertPerm p) ψ)).pin` given `StrictMono ψ.pin` | `Fin.strictMono_succAbove`, `insertPerm_succ` | `Prop43Translate.lean:269-271` + Mathlib | `hψ.comp (Fin.strictMono_succAbove p)` after computing the pin to `ψ.pin ∘ p.succAbove`; ~10 lines |
| gap forward glue | steps 1-7 of §2.3 | `veeSat_exists`, `veeSat_renamePin`, `cons_comp_insertPerm_symm`, `eval_insertNth_rename`, strengthened IH | all LANDED | assembly only — the residual `ex`/`all` `sorry` body |

Total new proof content ≈ **80-140 lines**, all reducing to landed `StrictMono`/`valid` facts. No new
mathematical content; no change to any *emitted formula* except the §5 nil-case swap.

---

## 4. H4 — Adversarial self-verification

Method key: `read` = direct current-source read at cited line; `loogle` = Mathlib signature confirmed
via `lean_loogle`; `derive` = deduction from a read signature; `stress` = concrete small-case check.

### 4.1 Concrete stress test — `m = 1`, gap at a non-least rank

Take `.ex α` with `α = .not (.atom P 0)` (i.e. `∃x. ¬P(x)`), `m = 1`, `env = ![c]` `StrictMono`
(trivially). Order types of a witness `x` vs the one point `c`: gap 0 (`x<c`), tie (`x=c`), gap 1
(`x>c`) — the `m+1=2` gaps + `m=1` tie the plan enumerates.

Focus on **gap 1 (non-least rank, `x>c`)**, the case the task names. The gap-1 disjunct is
`D_1 = (Ψ_1.map (renamePin (insertPerm 1))).map dropPin`, arity 1. `α` is `.not (.atom …)`, so
`Ψ_1 = translate(α.rename (insertPerm 1))` routes through the negation **cons** branch (the atom
translates to a nonempty `atomEmit`, so `veeSat_negation` never hits its nil branch) ⇒ **all `Ψ_1`
disjuncts are `StrictMono`-pinned; `efArb` does not appear.**

- Forward: `veeSat N ![c] D_1` ⇒ (`veeSat_exists`) `∃ a, veeSat N ![c,a]` (renamed) ⇒
  (`veeSat_renamePin`) `veeSat N (insertNth 1 a ![c]) Ψ_1 = veeSat N ![c,a] Ψ_1`.
- The satisfying `Ψ_1` disjunct `ψ` has `StrictMono ψ.pin`, so `![c,a] = x ∘ ψ.pin` is `StrictMono`
  ⇒ `c < a` ⇒ `a` genuinely in gap 1. IH fires ⇒ `eval ![c,a] (α.rename (insertPerm 1)) =
  eval ![a,c] α = ¬ P-holds-at-`a``. A real gap-1 eval witness. ✔ **No spurious firing.**
- Counterexample hunt (spurious fire with `a ≤ c`): `veeSat N ![c,a] Ψ_1` would need a `Ψ_1` disjunct
  whose `efSat` holds at the non-`StrictMono` `![c,a]` (`a ≤ c`). By Fact (P-comp) every `Ψ_1` pin is
  `StrictMono`, so `efSat` forces `![c,a]` `StrictMono` ⇒ `a > c`. Contradiction. **The spurious
  witness is impossible.** This is exactly the "monotone pinning blocks the escape" claim, verified
  on a concrete case.

### 4.2 Claim verification table

| Claim | Source / Counterexample | Verification method | Verdict | Confidence |
|---|---|---|---|---|
| `efSat` chain is `StrictMono` and pin clause is `env = x ∘ ψ.pin` | `∃ x, StrictMono x ∧ (∀ k, env k = x (ψ.pin k))` | read `ExistsForallFormula.lean:128-130` | CONFIRMED | High |
| `StrictMono pin ⇒ env StrictMono` whenever `efSat` holds | `env = x∘pin`, `StrictMono.comp` | derive from above | CONFIRMED | High |
| Lift disjuncts pin `= eS`, and `valid/valid1/validS` force `StrictMono eS` | `liftMergedFormula.pin := m.eS`; `valid… : StrictMono m.eS ∧ …` | read `LiftPair.lean:232,166,581,851` | CONFIRMED | High |
| Conj disjuncts pin `= e₁∘pin₁`, `valid` forces `StrictMono e₁` | `mergedFormula.pin := fun v => e₁ (pin₁ v)`; `valid… : StrictMono m.e₁ ∧ …` | read `ConjInterleave.lean:230,161-168`; `veeConj` feeds `ψ.pin` (`VeeConj.lean:52`) | CONFIRMED | High |
| skeleton pin `= id` (atom/lt base) | `skelDisjunct.pin := id` | read `LiftPair.lean:90` | CONFIRMED | High |
| gap-disjunct pin computes to `ψ.pin ∘ p.succAbove`, `StrictMono` | `insertPerm p j.succ = p.succAbove j`; `dropPin` reindexes by `.succ`; `Fin.strictMono_succAbove` | read `Prop43Translate.lean:269-271,182`; loogle `Fin.strictMono_succAbove` | CONFIRMED | High |
| The gap forward direction is glue over landed lemmas once IH carries pin-mono | steps 1-7 §2.3, all cited lemmas landed | read (each lemma) + derive | CONFIRMED (design); not yet mechanized | Medium-High |
| `translate_correct`'s **current** conclusion does NOT expose pin-mono; IH must be strengthened | conclusion is `∃ Ψ, ∀ env, StrictMono env → (veeSat ↔ eval)` with no pin clause | read `Prop43Translate.lean:396-397` | CONFIRMED — this is why it "closes as-is" *after* a conclusion strengthening, not against the literal current statement | High |
| `veeSat_negation` nil branch emits `efArb` with `pin := fun _ => 0` (non-`StrictMono`, arity ≥ 2) | `refine ⟨Gd ++ [efArb sig F r], …⟩`; `efArb.pin := fun _ => 0` | read `VeeSatNegation.lean:105,77` | CONFIRMED — the single invariant exception | High |
| nil branch (hence `efArb`) is reachable inside a translated body | `.lt i j` with `¬(i<j)` emits `[]`; `.not (.lt i j)` ⇒ `veeSat_negation … []` ⇒ nil | read `Prop43Translate.lean:416`, `VeeSatNegation.lean:100-101` | CONFIRMED reachable | High |
| `efArb` is harmless in the gap forward direction for outer `m ≥ 2` | `efSat _ w efArb` forces `w` constant (pin const 0, `n=0`); `insertNth p a env` inherits `env`'s ≥2 distinct points for `m ≥ 2`, never constant | derive from `efSat` def + `insertNth` | CONFIRMED for `m ≥ 2` | Medium-High |
| all-false point type `fun _ => false` unsatisfiability (would make `efArb` harmless at every arity) | `unaryHolds N (fun _=>false) p ↔ ∀ atomkind, ¬ atom_eval` — realizable iff a "bare" point exists; model-dependent | read `NormalForm.lean:201-202`, `ExistsForallFormula.lean:62-64` | **UNVERIFIED** — not established in source; genuinely model-dependent | — |
| `efArb` can break the invariant at `m = 1` with a tie-coincident witness `a = c` AND a bare point | narrow corner: `α` contains `.not (.lt …)`, `m=1`, `a=c`, model has all-atom-false point | derive | **UNVERIFIED risk** — precisely scoped; neutralized by §5 swap | Medium |

### 4.3 Contradiction log

One **tension**, resolved. The literal task binary ("YES ⇒ closes as-is" vs "NO ⇒ add an `lt`
conjunct") does not have a pure yes/no answer against the *current* statement, because monotone
pinning is *structurally present in the emitted formula* (YES) yet *not exposed by the correctness
conclusion* (so the current IH cannot use it). Resolution by precedence rule "source signature beats
framing": the *pins are* `StrictMono` (read from `valid`/`skelDisjunct`/`succAbove`), so this is the
YES branch — the fix is a **proof-side conclusion strengthening**, categorically *not* the NO branch's
"explicit `lt`-skeleton order-constraint conjunct added to `Ψ_p`" (no emitted formula gains a
constraint). The one genuine non-monotone pin (`efArb`) is a *bounded defect*, not a refutation of the
YES verdict, and §5 removes it.

### 4.4 Single most load-bearing residual (flagged)

The `UNVERIFIED` rows both concern **`efArb` only**. The verdict YES does not depend on resolving
`efArb`'s satisfiability, because the recommended fix (§5, option i) *removes `efArb` from the pin
inventory entirely*, making `Π` hold with zero exceptions. If instead the dispatch keeps `efArb`
(option ii), it must discharge the `m=1`/`a=c`/bare-point corner — which is exactly the kind of
"one sub-step not reduced to a landed lemma" report 14 already warned about, now localized to a single
named disjunct instead of the whole gap bookkeeping.

---

## 5. Corrected, unambiguous target for the final assembly dispatch

The next `/implement` dispatch on the `ex`/`all` `sorry`s (`Prop43Translate.lean:439,448`) MUST build
**exactly** this — it is glue, and it must not defer again:

**T1. Strengthen the theorem conclusion** (`Prop43Translate.lean:396-397`) to
```
∃ Ψ : VeeExistsForall sig F m,
  (∀ ψ ∈ Ψ, StrictMono ψ.pin) ∧
  (∀ env : Fin m → N.carrier, StrictMono env → (veeSat N env Ψ ↔ eval N env φ))
```
Re-thread the 4 landed arms (atom/lt/and/not): each additionally discharges the pin-mono conjunct via
the §3 helper lemmas (skeleton `id`; `veeConj`/lift preserve `StrictMono` from `valid`).

**T2. Neutralize the `efArb` exception (pick one; option i recommended):**
- **(i, recommended)** In `veeSat_negation`'s nil branch (`VeeSatNegation.lean:105`), replace the
  throwaway witness `efArb sig F r` with an **identity-pinned tautological disjunct** so the emitted
  nil-case formula has only `StrictMono` pins. Concretely, keep the excluded-middle structure but use
  a `skelDisjunct`-style (`pin := id`) inhabitant instead of `efArb` (`pin := fun _ => 0`); the nil
  branch only uses `by_cases` on the witness's `efSat`, never its semantics, so any inhabitant with a
  `StrictMono` pin works. This is a **one-witness swap** in landed, axiom-clean code; it does not touch
  the cons branch, the 4 landed `translate` cases, or the tie disjuncts.
- **(ii)** Keep `efArb`; strengthen the invariant to the *semantic* form
  `∀ ψ ∈ Ψ, ∀ w, efSat N w ψ → StrictMono w`, and discharge the `efArb` disjunct using that
  `insertNth p a env` inherits `env`'s distinct points (constant only in the degenerate `m ≤ 1`
  arity, where the `Fin (m+1)→Fin 1` pin is vacuously `StrictMono`). Larger, corner-heavy — prefer (i).

**T3. `ex` case body** (`:448`): `classical`; obtain `Ψ_p := IH(α.rename (insertPerm p))` for each
`p : Fin (m+1)` (size-smaller via `size_rename`) and `Ψ_i := IH(α.subst0 i)` for each `i : Fin m`
(size-smaller via `size_subst0`); emit
```
Ψ := (⋃_{p : Fin (m+1)} (Ψ_p.map (renamePin (insertPerm p))).map dropPin)
     ++ (⋃_{i : Fin m} Ψ_i)
```
Forward: `veeSat` of a gap disjunct ⇒ steps 1-7 of §2.3 (glue); `veeSat` of a tie disjunct ⇒
`eval_subst0` + IH at `StrictMono env`. Backward: `lt_trichotomy` on the eval witness `x` vs each
`env` point selects the gap `p`/tie `i`, then the matching disjunct is satisfiable (landed
`skelR_sat`/`veeSat_exists` content). Pin-mono conjunct: gap pins `= ψ.pin ∘ p.succAbove`
(`Fin.strictMono_succAbove`), tie pins from IH.

**T4. `all` case body** (`:439`): eval De Morgan bridge `eval env (.all α) ↔ ¬ ∃ x, eval (cons x env) (.not α)`
(classical), then compose the landed `veeSat_negation` (twice) around the T3 `ex` closure applied to
`.not α`, per report 14 §3.3 — expressed as a lemma consuming a provided translation so the size
measure is respected (do **not** recurse on the syntactically larger `.not (.ex (.not α))`).

**Do-not-defer contract:** the only genuinely new content is T1-T2 (conclusion + one-witness swap) and
the T3 assembly/enumeration. Every semantic step (P-comp forcing, `veeSat_exists`, `veeSat_renamePin`,
`eval_insertNth_rename`, size decrease) is a **landed lemma**. There is no remaining unknown lemma to
discover; if a step "cannot be done," it is a plumbing/enumeration issue, not a mathematical gap —
mark `[BLOCKED]` with the exact goal state rather than adding a `sorry`.

---

## 6. Memory candidates

1. *(fact, task-379)* In the Kamp E[Σ] ∨∃∀ framework, `efSat`'s pin clause is `env = x ∘ ψ.pin` with
   `x` `StrictMono`; therefore a **`StrictMono` pin forces the environment `StrictMono`**. Every
   `translate`/`veeSat_negation`/`veeConj` disjunct has a `StrictMono` pin (from
   `LiftMergePair.valid.eS`, `MergePair.valid.e₁`, `skelDisjunct.pin=id`), so the `ex`-closure gap
   witness produced by the *unconditional* `veeSat_exists` is automatically pinned into its gap — no
   explicit order-constraint conjunct is needed.
2. *(pattern, lean4)* When an existential-closure forward direction gets an *unconditional* witness
   from a `∃`-drop lemma but the IH needs the witness order-constrained, the fix is often already
   latent in the object's own structure (a `StrictMono` pin/embedding). Expose it by **strengthening
   the correctness theorem's conclusion with the structural invariant** rather than adding a
   constraint disjunct to the emitted formula.
3. *(fact, task-379)* `veeSat_negation`'s nil branch (`VeeSatNegation.lean:77,105`) emits `efArb`
   with `pin := fun _ => 0` — the sole non-`StrictMono` pin in the Prop-4.3 pipeline, reachable via
   `.not (.lt i j)` (`j ≤ i` translates to `[]`). Swap it for an identity-pinned tautological witness
   to make the pin-monotonicity invariant exception-free; `efArb`'s semantics are never inspected
   (only excluded middle on its `efSat`), so any `StrictMono`-pinned inhabitant is a drop-in.

---

## 7. Divergence audit (H5) — why this target kept deferring

| Symptom | Root cause | Correction |
|---|---|---|
| ex/all deferred at the same point across dispatches (reports 13, 14, now) | Each dispatch re-derived the *obstruction* (unconditional `veeSat_exists` witness) but treated the gap-placement as an open *mathematical* question, when it is a *structural invariant already present in the pins* that the **conclusion fails to expose** | State the invariant `∀ ψ ∈ Ψ, StrictMono ψ.pin` and thread it through the IH (T1). The question stops being open. |
| Report 14 flagged the pin-rank bookkeeping UNVERIFIED and proposed `dropPin`-avoidance fallbacks | The `renamePin`/`insertPerm`/`eval_insertNth_rename` substrate had not yet landed, so the closure was still hypothetical | That substrate is now **LANDED** (`Prop43Translate.lean:204-305`); the fallback is unnecessary — the direct `veeSat_exists`+`veeSat_renamePin` route works *because* the pins are monotone. |
| Risk of a further defer on "does the negation constrain ranks?" | The `efArb` nil-branch pin looked like it might sink the whole invariant | It is a single bounded defect, harmless for `m ≥ 2`, removed by a one-witness swap (T2). Not a blocker. |

**Postmortem:** the target was never blocked by missing mathematics; it was blocked by the correctness
*statement* being one conjunct too weak to let the IH see the monotone pins it already produces. The
corrected target (§5) is assembly + a conclusion strengthening + a one-line witness swap.
