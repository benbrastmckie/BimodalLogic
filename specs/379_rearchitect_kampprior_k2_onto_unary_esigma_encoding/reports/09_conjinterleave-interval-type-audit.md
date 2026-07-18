# Divergence Audit — Interval-Type Representation for `conjInterleave_iff` / Phase 3

- **Task**: 379 — rearchitect_kampprior_k2_onto_unary_esigma_encoding
- **Mode**: H5 divergence audit / design adjudication (research-only; NO `Theories/**` edits)
- **Type**: lean4 (hard mode: H2/H3/H4/H5)
- **Reference grounding tier**: Tier 1 (literature-backed — Rabinovich 2014, PDF page cites only;
  companion `.md` is corrupt and was not used)
- **Inputs read**: `ConjInterleave.lean`, `ExistsForallFormula.lean`, `ExistsForallLemmas.lean`,
  `Prop42NegationGeneral.lean`, `NormalForm.lean`, `VeeExistsForall.lean`, plan
  `08_esigma-negation-rearchitecture.md`, Rabinovich PDF pp.4-6.

## Verdict Summary (front-loaded)

1. **VERIFY the refutation**: **CONFIRMED.** A full biconditional `conjInterleave_iff` is
   unattainable on the complete-`UnaryType` encoding. Two independent machine-grounded reasons
   (empty-interval mismatch; irreducible disjunctive-∀). The Phase 2 finding's *conclusion* is
   correct; one of its cited *supports* (footnote 2, p.5) is mischaracterized (corrected below).
2. **Chosen option**: **(A)** — refine interval types to **partial** (conjoinable) types. Faithful
   reason: Rabinovich Def 3.1 (p.4) makes αⱼ, βⱼ *quantifier-free formulas with one variable*, and
   Prop 3.5 (p.5) treats them as Boolean atoms Aᵢ, Bᵢ. **(B) is refuted** — the spine's Phase 5 (γ)
   and Phase 6 (δ `and`-case) consume the **full** `veeConj_iff` biconditional, which rests on a
   full `conjInterleave_iff`. **(C) "complete type + forced-empty flag" is refuted** — it cannot
   express the disjunctive-∀ interval constraints `translate` produces.
3. **Blast radius**: **RE-SCOPE.** The change touches the field type of a landed structure consumed
   by ~3,000 lines of sorry-free proof (`Prop42NegationGeneral`, `ExistsForallLemmas`,
   `Prop35Assembly/Chain`, `Prop42ExistsForall`) on the α→β→γ→δ→ζ critical path. It is not a
   Phase-3-local, one-agent-per-phase change. Orchestrator should **escalate / revise the plan**,
   not resume Phase 3 as written.
4. **Corrected Phase 3 target**: interpose a type-refactor phase (partial interval types +
   migration of landed assets), then prove the **full** `conjInterleave_iff` under partial-interval
   satisfaction. Precise statement in §5.

## H3 Reference-Grounding Table (Tier 1 — lemma-level, 5-column)

| Source (Rabinovich 2014) | Prop/Location | Lean Identifier | Type Signature (as landed / as needed) | Status |
|---|---|---|---|---|
| Def 3.1 ∃∀-formula, αⱼ/βⱼ "quantifier free formulas with one variable" | PDF p.4 | `ExistsForallFormula`, `UnaryType`, `efSat` | `intervalType : Fin (n+2) → UnaryType` where `UnaryType := NormalForm (sigE sig F) 0 1` (**complete** type) | LANDED but **unfaithfully narrowed** — Def 3.1 requires partial qf-formulas |
| "a point realizes at most one complete type" | — (Lean) | `nf_eval_unique` | `NormalForm.lean:245` — `nf_eval_nf … nf1 → nf_eval_nf … nf2 → nf1 = nf2` | LANDED — this is exactly what makes `UnaryType` *total/complete* |
| Lemma 3.2(1) conjunction → disjunction of ∃∀ | PDF p.4 | `conjInterleave`, `conjInterleave_forward`, `pointConsistent_of_holds` | forward-only, point-consistency filter, carries chain-1 intervals | PARTIAL — forward TRUE (1 strategic sorry); **full iff FALSE on complete types** |
| Lemma 3.4 closure under ∧ | PDF p.5 | `veeConj`, `veeConj_iff` (Phase 3) | `veeSat (veeConj Φ₁ Φ₂) ↔ veeSat Φ₁ ∧ veeSat Φ₂` | NOT STARTED — needs full `conjInterleave_iff` |
| Prop 3.5 ∃∀ → TL, "Aᵢ, Bᵢ … do not even use Until and Since" (Boolean/qf) | PDF p.5 | `translateProp35`, `efIntervalTP`, `efPointTP` | translate a **complete** `UnaryType` to a TL formula | LANDED — assumes complete types; would need to translate admissible-completion **sets** |
| Footnote 2 (P·Until·Q) | PDF p.5 | — | "`P Until Q` is ∃∀; its **negation** is not equivalent to any ∨∃∀ formula" | Motivates E[Σ] expansion (Prop 4.2 / §5); **NOT** a statement about forced-empty intervals |
| Def 4.1 E[Σ] canonical expansion | PDF p.5 | `sigE`, `esigma_descent`, `hcapture_dischargeable` | E[Σ] = Σ ∪ {A ∣ A a TL formula} | LANDED (Phase 0/1) |
| Prop 4.3 FO → ∨∃∀ (structural induction) | PDF p.6 | `translate` (Phase 6 δ) | `MonadicFormula → VeeExistsForall`; `and`-case = `veeConj` | NOT STARTED — biconditional `translate_correct` needs full `veeConj_iff` |
| Thm 4.4 Kamp | PDF p.6 | spine rewire (Phase 7 ζ) | retire `KampPrior.lean:562` `sorryAx` | NOT STARTED |

## Findings

### 1. VERIFY the refutation — CONFIRMED

**Machine-checked basis for "`UnaryType` is a complete type":**
`UnaryType sig F := NormalForm (sigE sig F) 0 1` (`ExistsForallFormula.lean`). `unaryHolds N τ p`
unfolds to *every* E[Σ] atom at `p` matching `τ`'s Boolean assignment (`unaryHolds_iff`). Because a
`NormalForm 0 1` is a **total** function `AtomKind (sigE sig F) 1 → Bool`, and `nf_eval_unique`
(`NormalForm.lean:245`) proves a point satisfies **at most one** such object, `UnaryType` is a
*complete* 1-type: it fixes the truth value of every unary predicate. There is no `⊥` (unsatisfiable)
`UnaryType` and no proper disjunction of `UnaryType`s inside a single slot.

**Reproduction of the empty-interval counterexample (the module's own claim).** Take `r = 0`
(sentences), a discrete two-point model `{a, b}`, `a < b` order-adjacent (no point strictly between).

- `ψ₁ := ∃x₀ · pointType = type_of(a) ∧ (∀y > x₀) β₁`, `β₁ := type_of(b)`. Satisfied by `x₀ = a`.
- `ψ₂ := ∃x₀ · pointType = type_of(b) ∧ (∀y < x₀) β₀`, `β₀ := type_of(a)`. Satisfied by `x₀ = b`.

The unique valid 2-point rank-merge maps both points into `{a,b}`. **Point-consistency holds**: at
`a`, chain-1 gives `type_of(a)` (existential point) and chain-2 gives `β₀ = type_of(a)` (its
before-interval) — equal; symmetrically at `b`. But the merged interval **between** `a` and `b` is
**empty** (adjacency), and there chain-1's contribution is `β₁ = type_of(b)` while chain-2's is
`β₀ = type_of(a)`; since `type_of(a) ≠ type_of(b)` these **mismatch**. A *full-consistency* filter
(demanding interval-type equality) rejects the sole merge → **no disjunct is satisfied**, yet
`efSat ψ₁ ∧ efSat ψ₂` holds. Hence the **forward** direction of a full-consistency
`conjInterleave` is **FALSE** — exactly the module's design note. CONFIRMED.

**Second, independent reason the biconditional is unattainable (stronger than the module states).**
The landed module instead filters by **point-consistency only** and sets
`mergedFormula.intervalType := chainIntervalType ψ₁` (carries **chain-1 only**;
`ConjInterleave.lean`). Therefore `veeSat (conjInterleave ψ₁ ψ₂)` asserts nothing about ψ₂'s
interval types, so the **backward** direction `veeSat → efSat ψ₂` fails in general. Either filter
choice loses one direction: **no full biconditional exists on the single-complete-`UnaryType`
encoding.** CONFIRMED.

**Root cause (the deepest reason — needed for the δ `translate`).** A merged/conjoined interval
carries the *conjunction* `βⱼ ∧ β'ⱼ'` of two qf-formulas. Two facts about `∀y (interval type)(y)`
force partiality:
- **Contradictory conjunction** (`βⱼ ∧ β'ⱼ' = ⊥`): satisfiable **iff the interval is empty**
  (`∀y ∈ ∅` is vacuous). A complete `UnaryType` can never be `⊥`, so it cannot force an interval
  empty.
- **Disjunctive ∀** (irreducible): `translate` of an atom `P(z₀)` yields interval constraints like
  `∀y P(y)`, where `P` is satisfied by *many* complete types. `∀y P(y)` does **not** mean all `y`
  share one complete type, so it is **not** expressible as any finite disjunction of
  "`∀y realizes complete-type τ`" clauses. Partiality in interval types is therefore
  **irreducible** — it cannot be pushed up to the ∨ of ∨∃∀.

### 2. Rabinovich adjudication (source-grounded, PDF pages only)

- **Def 3.1 (p.4)**, verbatim from the PDF: an ∃∀-formula has "a prefix of `n+1` existential
  quantifiers and with all αⱼ, βⱼ **quantifier free formulas with one variable**". A quantifier-free
  1-formula over a finite monadic signature is a Boolean combination of the unary predicates —
  equivalently (canonical normal form) the **set of complete 1-types that satisfy it**. It can be
  contradictory (`⊥`, empty set), a single complete type (singleton), a proper disjunction, or `⊤`.
- **Lemma 3.2(1) (p.4)** "conjunction of ∃∀-formulas ≡ disjunction of ∃∀-formulas" and **Lemma 3.4
  (p.5)** "closed under conjunction" are the operations Phase 3 must realize; their proof merges two
  chains, **conjoining** point/interval qf-formulas per merged slot — a contradictory interval
  conjunction forces that (necessarily empty) slot, a step available only with partial types.
- **Prop 3.5 (p.5)**: the ∃∀ → TL translation names `Aᵢ, Bᵢ` temporal formulas equivalent to `αᵢ, βᵢ`
  and states they "do not even use Until and Since" — i.e. `αⱼ, βⱼ` are general Boolean/qf formulas,
  **confirming** they are partial types, not complete ones.
- **Footnote 2 (p.5) — correction to the Phase 2 finding.** The footnote actually reads: the truth
  table of `P Until Q` is an ∃∀ formula `(∃x')_{>x}(Q(x') ∧ (∀y)_{>x}^{<x'} P(y))`, "yet we can
  prove that its **negation** is not equivalent to any ∨∃∀ formula." It motivates the **E[Σ]
  expansion** (Prop 4.2, proved in §5) — it is **not** a statement that "a contradictory conjunction
  forces an interval empty," as the `ConjInterleave.lean` docstring and the plan's Phase 2 DESIGN
  FINDING assert. The forced-empty mechanism is real and inherent to Def 3.1's qf-formula interval
  types, but its source is **Def 3.1 + Lemma 3.2(1)/3.4**, not footnote 2. (H4 correction; see
  Adversarial section.)

**Faithfulness conclusion (binding, no novel mathematics):** faithful transcription of Def 3.1
*requires* interval types to be **partial** (conjoinable, possibly-contradictory,
possibly-disjunctive) qf-formulas. The complete-`UnaryType` encoding is a strict, unfaithful
narrowing. Representing a qf 1-formula by its **finite set of satisfying complete 1-types**
(`Finset (UnaryType)`) is the standard normal form — faithful, not novel.

### 3. Decision: (A), (B), or (C)

**Chosen: (A) — partial interval types.** Grounds:

- **(B) — keep complete types, prove a restricted iff — REFUTED by the downstream obligation.**
  Phase 7 (ζ) rewires `completeness_discrete` through Thm 4.4 = Prop 4.3 (δ) + Prop 3.5 (ε). Prop
  4.3's `translate_correct` is a **biconditional** `veeSat (translate φ) ↔ eval φ` by structural
  induction; its `and`-case defines `translate (φ₁ ∧ φ₂) := veeConj (translate φ₁) (translate φ₂)`
  and needs `veeSat (veeConj Φ₁ Φ₂) ↔ veeSat Φ₁ ∧ veeSat Φ₂` (full `veeConj_iff`). Phase 5 (γ)
  reassembles `⋀ᵢ ¬φᵢ` into ∨∃∀ via the same full `veeConj_iff`. `veeConj_iff` (both directions)
  rests on a **full `conjInterleave_iff`**. The spine therefore needs the **full biconditional**,
  not a directional/point-consistency version. A restricted iff does **not** suffice.
- **(C) — complete type + per-slot "forced-empty" flag — REFUTED.** A Boolean empty-flag captures
  conjunctions of *singletons* (equal → that type; unequal → ⊥/empty), which is enough for merging
  two *already-complete* formulas, but it **cannot** represent the genuinely disjunctive `∀y P(y)`
  interval constraints that `translate` (δ) produces from atoms — irreducible per §1. So (C) breaks
  at Phase 6, the crux.
- **(A) — partial interval types — REQUIRED and faithful.** Represent each interval type as a
  `Finset (UnaryType)` = the set of admissible complete-type completions of a qf-formula.
  Satisfaction: `∀ y ∈ slot, ∃ τ ∈ S, unaryHolds N τ y`. Conjunction = `S₁ ∩ S₂`; `⊥ = ∅` (forces
  slot empty); `⊤ = Finset.univ`. **Point types MAY remain complete** `UnaryType` (a merged point is
  a real point; disjunctive point constraints lift soundly to the ∨ level), which halves the
  negation-engine re-proof; making them uniformly partial is equally faithful but larger. The
  interval-type refinement is **mandatory**; the point-type choice is a bounded sub-decision.

**Feasibility (machine-checked):** `Fintype (NormalForm sig k n)` and `DecidableEq (NormalForm sig
k n)` are provided (`NormalForm.lean:167-182`), so `UnaryType` is a `Fintype` with `DecidableEq`;
`Finset (UnaryType)`, `Finset.univ`, `∩`, and the decidable `∃ τ ∈ S` are all available. Option (A)
is mechanically well-founded.

### 4. Blast radius + re-scope verdict — RE-SCOPE

The candidate change is to the **field type** `ExistsForallFormula.intervalType` (and the interval
clauses of `efSat`). Proof-term consumers (via `lean_references`-class grep, cited by declaration):

- `.intervalType` / `.pointType` are referenced **227×** across **12** `Theories/…/Kamp/*.lean`
  files (excluding `ConjInterleave.lean`).
- **`prop42_efSat_negation_general`** (`Prop42NegationGeneral.lean`, ~1004 lines, LANDED sorry-free)
  threads `ψ.intervalType` through `efIntervalTP` in `belowFormula` / `aboveFormula` /
  `middleBracket` and their correctness proofs — dozens of sites. `efIntervalTP` translates a
  **complete** interval type to a TL formula; a partial (set) interval type requires translating a
  **disjunction**, and re-proving the engine.
- **`ExistsForallLemmas.lean`** (~702 lines, LANDED): `augTarget`, `pairProject`,
  `existenceSentence` copy `intervalType`/`pointType` through and `augTarget_iff` reasons about the
  interval clauses via `unaryHolds` — all would move to the partial satisfaction relation.
- **`Prop35Assembly.lean`** (~397), **`Prop35Chain.lean`** (~231), **`Prop42ExistsForall.lean`**
  (~448): consume `efSat` and the interval clauses; re-proof required.
- `efSat` itself is consumed by all of the above; changing its interval clause is a breaking change
  to the landed `VeeExistsForall`/`veeSat` layer built atop it.

That is **~3,000 lines of landed, sorry-free proof** on the α→β→γ→δ→ζ critical path, all built on
the "one complete `UnaryType` per slot" assumption. Changing the type invalidates them. This is
**not** implementable "within the existing plan's Phases 3-7 by one implement agent per phase."

**Verdict: RE-SCOPE.** Requires a plan revision (or a spawned type-refactor task) that inserts a
type-migration phase before the current Phase 3. The orchestrator should **escalate to the user /
`/revise`**, not resume Phase 3 as written.

### 5. Corrected Phase 3 target definition (faithful, executable)

Under option (A). Insert **Phase 2.5 (type refactor)** before the current Phase 3, then restate
Phase 3.

**Phase 2.5 — partial interval types + landed-asset migration (NEW; the re-scope phase).**
- Introduce `IntervalType sig F := Finset (UnaryType sig F)` (admissible-completion set). Define
  `intervalHolds N (S : IntervalType) (y) : Prop := ∃ τ ∈ S, unaryHolds N τ y`, with
  `intervalConj S₁ S₂ := S₁ ∩ S₂`, `intervalBot := (∅ : Finset _)`, `intervalTop := Finset.univ`.
- Change `ExistsForallFormula.intervalType : Fin (n+2) → IntervalType sig F` (point types **may**
  stay `UnaryType`). Rewrite the three interval clauses of `efSat` to use `intervalHolds`.
- Provide the embedding `ofComplete : UnaryType → IntervalType := ({·})` and the compatibility lemma
  `intervalHolds N {τ} y ↔ unaryHolds N τ y`, so every landed proof that fed a complete type migrates
  by rewriting through `ofComplete`.
- Migrate `ExistsForallLemmas` (`augTarget`, `pairProject`, `existenceSentence`, `augTarget_iff`),
  `Prop42NegationGeneral` (generalise `efIntervalTP` to a set = disjunction of complete-type
  translations), `Prop35Assembly/Chain`, `Prop42ExistsForall` to the partial satisfaction relation.
- **DoD**: `lake build` EXIT 0; `#print axioms completeness_discrete` unchanged (still off-path);
  no new sorry/axiom.

**Phase 3 (restated) — full `conjInterleave_iff` under partial intervals.**
- Merge rule per slot: merged **point** type = common complete type (point-consistency, unchanged);
  merged **interval** type = `intervalConj` of the two chains' contributions
  (`chainIntervalType ψ₁ e₁ t ∩ chainIntervalType ψ₂ e₂ t`) — **both** chains, not chain-1 only.
- Consistency filter: point-consistency (kept). Interval slots are **not** filtered out on mismatch;
  instead the mismatched slot carries `S₁ ∩ S₂` (possibly `∅`), and `intervalHolds` over an empty
  slot is vacuously true, over a nonempty slot forces `S₁ ∩ S₂ ≠ ∅` at each point.
- **Target theorem (full biconditional):**
  ```
  theorem conjInterleave_iff (N) (env) (ψ₁ ψ₂ : ExistsForallFormula sig F r) :
      veeSat N env (conjInterleave ψ₁ ψ₂ ψ₁.pin ψ₂.pin) ↔ efSat N env ψ₁ ∧ efSat N env ψ₂
  ```
  Forward: the realized rank-merge (as in the landed `conjInterleave_forward` plan) now also
  realizes `S₁ ∩ S₂` at each merged interval point (each witness realizes both chains' interval
  types, hence a common completion). Backward: from a merged disjunct, project `e₁`/`e₂` back to
  recover both chains; `intervalHolds (S₁ ∩ S₂)` at every point of every ψₖ-interval gives
  `intervalHolds Sₖ`, discharging each chain's interval clause.
- Then `veeConj` / `veeConj_iff` as planned (Lemma 3.4-∧), now provable as a **biconditional**.

**Knock-on to later phases:**
- **Phase 4 (β) / Phase 5 (γ)**: `efSat_negation_general` and `veeSat_negation` inherit the
  partial-interval `efSat`; the reused `prop42_efSat_negation_general` is available only *after*
  Phase 2.5 migrates it. γ's reassembly uses the now-full `veeConj_iff` — unchanged in shape.
- **Phase 6 (δ)**: `translate`'s atom/`lt` base cases now emit partial interval types directly
  (`∀y P(y)` → interval `S = {τ : τ ⊨ P}`), which is the case that was impossible before; the
  `and`-case uses the full `veeConj_iff`. This is where (A) pays off and (B)/(C) failed.
- **Phase 7 (ζ)**: unchanged in intent; consumes the migrated δ/ε.

## Adversarial Self-Verification (H4)

Applied the Claim Verification Bar to every load-bearing claim. Verification methods:
`lean_hover_info`/direct-Read of the declaration; PDF-page image read; grep/reference count.

| Claim | Source / Counterexample | Verification Method | Confidence |
|---|---|---|---|
| `UnaryType` is a *complete* (total) type; no `⊥`, no proper in-slot disjunction | `ExistsForallFormula.lean` (`UnaryType := NormalForm 0 1`), `nf_eval_unique` | Direct Read of both decls (`NormalForm.lean:245`) | High |
| Def 3.1 makes αⱼ/βⱼ *quantifier-free formulas with one variable* (partial) | Rabinovich PDF **p.4** (verbatim) | PDF page image read | High |
| Prop 3.5 treats αᵢ/βᵢ as Boolean atoms Aᵢ/Bᵢ ("do not even use Until/Since") | Rabinovich PDF **p.5** | PDF page image read | High |
| Footnote 2 is about `P Until Q`'s **negation** not being ∨∃∀ — NOT forced-empty intervals | Rabinovich PDF **p.5**; contradicts `ConjInterleave.lean` docstring + plan Phase 2 note | PDF page image read | High |
| Full-consistency forward direction is FALSE (2-point empty-interval counterexample) | Constructed `{a,b}` adjacent; sole merge interval-inconsistent yet both ∃∀ satisfied | Hand-constructed model + `efSat` clause inspection | High |
| Point-consistency-only version's backward is FALSE (`mergedFormula` carries chain-1 intervals only) | `ConjInterleave.lean` `mergedFormula.intervalType := chainIntervalType ψ₁` | Direct Read | High |
| Disjunctive `∀y P(y)` interval constraint is irreducible to a finite ∨ of complete-type clauses | Semantics of `∀` over an interval where distinct points have distinct complete types | Model-theoretic argument (no counterexample found against it) | High |
| Spine (Phase 5 γ, Phase 6 δ `and`-case) needs the FULL `veeConj_iff` biconditional | Plan `08` Phases 3/5/6; `translate_correct` is a biconditional by structural induction | Read of plan Phases 3/5/6; standard induction obligation | High |
| Blast radius ≈ 3,000 lines across `Prop42NegationGeneral`/`ExistsForallLemmas`/`Prop35*`/`Prop42ExistsForall` on complete-type `intervalType` | grep: 227 `.intervalType`/`.pointType` refs / 12 files; `efIntervalTP` threading; `wc -l` | grep + `wc -l` + Read of `Prop42NegationGeneral` interval sites | High |
| `Finset (UnaryType)` representation is feasible (Fintype + DecidableEq) | `NormalForm.lean:167-182` (`Fintype`/`DecidableEq (NormalForm sig k n)`) | Direct Read | High |
| Point types MAY stay complete (disjunction lifts to ∨-level); only intervals must go partial | Merged points are real points; `∀`-intervals are the only irreducible case | Model-theoretic argument | Medium |

**Contradiction Log.** One contradiction found and resolved:
- *Phase 2 finding cites footnote 2 (p.5) as grounding "contradictory conjunction forces an interval
  empty."* The PDF footnote 2 says only that `P Until Q`'s **negation** is not ∨∃∀-expressible.
  **Resolution (precedence: primary source > repo docstring):** the *conclusion* (interval types
  must be partial/conjoinable) stands, grounded correctly on **Def 3.1 (p.4) + Lemma 3.2(1)/3.4
  (p.4-5)**; the *citation* of footnote 2 is incorrect and should be dropped from the module
  docstring and the plan on the next edit. No UNRESOLVED contradiction remains.

**Forbidden-output check:** no "mathlib likely has this" without a search; no type-mismatch claim
without the goal/type; every recommendation traces to a Read declaration or a PDF page. No `sorry`
deferral or axiom introduction recommended (this is a research-only audit).

## Recommendation to the orchestrator

Do **not** resume Phase 3 as written. **Escalate to `/revise`** (or spawn a type-refactor task):
insert **Phase 2.5** (partial interval types + migration of the landed
`Prop42NegationGeneral`/`ExistsForallLemmas`/`Prop35*`/`Prop42ExistsForall` assets), then the
restated Phase 3 (full `conjInterleave_iff` under partial-interval satisfaction). Option (A),
`Finset (UnaryType)` admissible-completion sets, point types staying complete. This is faithful to
Rabinovich Def 3.1 and is the only option that supports the full `veeConj_iff` the spine's δ/γ
require.
