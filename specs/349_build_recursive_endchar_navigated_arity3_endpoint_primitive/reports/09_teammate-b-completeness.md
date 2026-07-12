# Report 09 — Teammate B: The Completeness Direction (Rabinovich 2014)

**Task**: 349 | **Angle**: B — completeness/expressiveness direction of the endChar carrier
**Session**: sess_1783841542_df767b | **Tier**: 1 (literature-backed, lean4 strict)
**Authority**: Rabinovich 2014 PDF (read directly, pages 1–16, equations intact) + actual Lean types.
**Verdict (one line)**: The completeness direction **favors Option D (Prop-valued carrier)** — not
because Rabinovich uses semantic Props (his *output* is a closed formula), but because his completeness
*argument* threads interior sub-characterizations **relationally** from the IH, which the Lean `charF`
(`nf_characterizable_temporal_prior`) does **not** do at `k ≥ 2` (it arity-1-projects — the F1 collapse),
whereas Option D reproduces the paper's relation-preserving mechanism with green assets only.

> **Citation-form note.** The literature index (`specs/literature-index.json`) mandates **PDF page
> citations only** for `rabinovich_2014` and flags every `md:NN` citation as dangling (the `.md`
> extract drops all displayed equations and inverts `k≠m`→`k=m`). The mission asked for "`md:` citations";
> per the mission's own rule "paper wins conflicts" and "Authority = paper," I read the PDF directly and
> cite by **page number**. All equation-level claims below are from the PDF pages, not the `.md`.

---

## 1. How Rabinovich achieves the completeness / expressiveness direction

**The completeness direction is Theorem 2.1(2) = Theorem 4.4** (p.3, p.6): *every FOMLO formula φ(x)
with one free variable is equivalent, over Dedekind-complete chains, to a TL(Until,Since) formula.*
This is "the direction that forces the carrier to encode quantifier alternation." It is achieved by a
three-stage pipeline, and the quantifier-alternation content is carried by an explicit **∃∀ normal form**.

### 1.1 The ∃∀ normal form is where "there EXISTS a witness" lives (Def 3.1, p.4)

An ∃∀-formula ψ(z₀,…,z_m) is (equations verbatim from p.4):

```
∃xₙ…∃x₁∃x₀ [ (⋀_{k=0..m} z_k = x_{i_k}) ∧ (xₙ > x_{n-1} > … > x₁ > x₀)      "ordering"
           ∧ ⋀_{j=0..n} α_j(x_j)                                          "α_j AT witness x_j"
           ∧ ⋀_{j=1..n} (∀y)^{<x_j}_{>x_{j-1}} β_j(y)                      "β_j ALONG (x_{j-1},x_j)"
           ∧ (∀y)_{>xₙ} β_{n+1}(y)  ∧  (∀y)^{<x₀} β₀(y) ]                  "exterior rays"
```

The existential/quantifier layer is captured by: (a) an **explicit existential prefix** over a
**strictly ordered witness chain** `xₙ > … > x₀`; (b) **point predicates α_j AT** each witness; (c)
**universal interval predicates β_j BETWEEN adjacent witnesses**. The free variables `z_k` (and, in the
two-endpoint case, both endpoints) are **pinned** to particular `x_{i_k}` and stay **explicit**. This is
the canonical shape the endChar carrier must express.

### 1.2 The negation closure is the two-free-variable object (Prop 4.2, p.6; §5, p.7–11)

Expressive completeness is proved by structural induction (**Prop 4.3, p.6**: every FOMLO formula ≡ a
disjunction of ∃∀-formulas). The *only* hard induction case is **negation**, discharged by:

- **Prop 4.2 (p.6)** — *Closure under negation:* the negation of an ∃∀-formula **with at most two free
  variables** is, over Dedekind-complete chains, a disjunction of ∃∀-formulas. **This is precisely the
  two-endpoint object.** Lemma 3.2(2) (p.4) first reduces arbitrary ∃∀-formulas to conjunctions of
  ≤2-free-variable ones, so the two-endpoint negation is the load-bearing closure step.

- **§5 proof (p.7–11):** ψ(z₀,z₁) splits on `k=m` (z₀=z₁) vs `k≠m` (p.7 — corroborating the index's
  "k=m split" correction). For `k≠m`, ψ decomposes into ψ₀(z₀), ψ₁(z₁) (one free var each → TL by
  Prop 3.5) and the **interior bracket φ(z₀,z₁)** — the two-endpoint interval between them. The bracket
  notation **`[α₀,β₁,…,αₙ](z₀,z₁)`** (Notation 5.2, p.8; eqn 5.1) has **z₀=x₀ and z₁=xₙ both pinned**.

### 1.3 The completeness ENGINE: interior sub-characterizations threaded relationally (p.9–11)

The core mechanism (Lemma 5.1 / Cor 5.4) expresses a bracket by **quantifying over an interior point z**
and splitting into left/right **sub-brackets**, threaded from the IH. From p.11 (verbatim):

```
[α₀,β₁,…,αₙ](z₀,z₁)  ⟺  (∀z)^{<z₁}_{>z₀} ( ⋁_i A_i ∨ ⋁_i B_i )
[α₀,β₁,…,αₙ](z₀,z₁)  ⟺  (∃z)^{<z₁}_{>z₀} ( ⋁_i A_i ∨ ⋁_i B_i )
```

where (p.10) `A_i(z₀,z,z₁) := A_i⁻(z₀,z) ∧ A_i⁺(z,z₁)` and `B_i := B_i⁻(z₀,z) ∧ B_i⁺(z,z₁)` are
themselves **brackets on the two sub-intervals** `(z₀,z)` and `(z,z₁)`, and `¬A_i, ¬B_i` are ∨∃∀
"by the inductive assumption." **Key structural facts for the carrier decision:**

1. The interior witness stays **existential/universal** (∃z / ∀z), never eliminated.
2. The two endpoints `z₀,z₁` stay **explicit** throughout.
3. The interior sub-content is threaded as a **relation over a sub-interval** (a two-endpoint bracket),
   **never as an isolated single-point read** of one witness.

Where a genuinely semantic object is needed — the least witness violating a predicate,
`r₀ = inf{z∈(z₀,z₁) | P₁(z)}` (exists **by Dedekind completeness**, p.8, Lemma 5.3) — it is **immediately
recaptured by a closed formula** `INF^{¬β₁}` using the near-boundary abbreviation `K⁺` (eqn 5.3, p.10).
So even the semantic infimum is converted to a closed formula, but that formula is **relation-preserving**.

### 1.4 The closed-formula OUTPUT preserves the relation via Until/Since NESTING (Prop 3.5, p.5; Cor 5.4, p.9)

The final TL formula (Prop 3.5, p.5) is a right-nested Until chain plus a left-nested Since chain that
**navigates the witness chain from the pinned anchor `x_k` outward**:

```
A_k ∧ (B_{k+1} Until (A_{k+1} ∧ (B_{k+2} Until … (Aₙ₋₁ ∧ (Bₙ Until (Aₙ ∧ □B_{n+1})))…)))    (future)
A_k ∧ (B_{k-1} Since (A_{k-1} ∧ … (A₁ ∧ (B₁ Since (A₀ ∧ ⟵□B₀)))…))                          (past)
```

Cor 5.4 (p.9) makes the recursion explicit: `Fₙ := αₙ; F_{i-1} := α_{i-1} ∧ (β_i Until F_i)`, with
"there is z∈(z₀,z₁) such that `[bracket](z₀,z)` iff F₀(z₀) …". **The closed formula preserves the
inter-point relation via the `β_i Until F_i` nesting** (each `Until` existentially quantifies the next
witient) — it does **not** project each interior point to an isolated arity-1 type. The **E[Σ] canonical
expansion** (Def 4.1, p.5; Def 7.7, p.14) is what lets interior `α_j,β_j` be **closed TL-formula atoms**
`{a | M,a⊨A}` supplied by lower induction levels — and these atoms are correct **unconditionally over all
Dedekind-complete chains** (Kamp's theorem is unconditional; no "Prior" hypothesis anywhere in the paper).

*(§7, p.13–16 — future fragment — reconfirms the faithful depth-k object: **Def 7.13 (p.15)** is a
`(z₀,…,z_k,∞)`-∃∀ formula = a **conjunction of ADJACENT two-endpoint brackets**, `⋀_{i≤k} φ_i` with each
`φ_i` a `(z_i,z_{i+1})`-bracket — never a one-point read. **Def 7.5 (p.13)** is a **3-alternative**
definition (`z₀>z₁`, `z₀=z₁`, or the bracket), confirming the index correction that it is NOT a half-open
interval.)*

---

## 2. The three decisive questions, answered

### Q1 — Is the interior characterization a SEMANTIC predicate (Prop) or a closed FORMULA?

**Both representations appear and are linked by the E[Σ] expansion, but the load-bearing *argument* is
semantic-relational and the *output* is a relation-preserving closed formula.** Concretely:

- The completeness **argument** (p.11 biconditionals, Lemma 5.3 induction, Cor 5.4 recursion) reasons
  **semantically**: quantify over interior points `z`, thread sub-brackets `A_i^±,B_i^±` **from the IH**
  as relations over sub-intervals. The infimum `r₀` is a genuine **semantic** point (Dedekind completeness).
- The **output** is a **closed formula**, obtained at the top via Prop 3.5 / Cor 5.4, in which interior
  content is preserved by **Until/Since nesting** and by **E[Σ] atoms** that are lower-level TL formulas.

Crucially: the closed formula **never** characterizes an interior point by an isolated single-point read
that erases the sub-interval relation. That is the distinction that decides D vs C′ in Lean.

### Q2 — Does completeness NEED closed formulas at interior points (→C′), or go through with semantic predicates threaded from the IH (→D)?

**The argument goes through with sub-characterizations threaded relationally from the IH; the closed
formula is assembled only at the top and is *relation-preserving*.** Therefore the paper's mechanism maps
to **D**, and it maps to C′ **only if** the interior closed formula is itself relation-preserving.

Mapping to the two Lean carriers:

| Paper mechanism (p.9–11) | Option D (Prop-valued) | Option C′ (charF closed formula) |
|---|---|---|
| Interior witness stays ∃ (p.11 `(∃z)…`) | witness `v`/`w` kept **OUTSIDE**, ∃, in `endCharStep_quant_reduceA` (NavigatedEndChar.lean:281) — verified sorry-free, `qnf.2` preserved verbatim, no arity-collapse | witness folded into `charF`; at `k≥2` the arity-4 sub is projected to `nfk_projFresh` (arity-1) — **F1 collapse** (`bracketEndChar_kv_factors`, CarrierKv.lean:422) |
| Sub-content = **relation over sub-interval** (two-endpoint bracket) | subs kept at **full arity 4** through the reduction — relation preserved | `charF = nf_characterizable_temporal_prior` (KampPrior.lean:407) projects to arity-1 `χ` — **relation lost** |
| Interior atoms correct **unconditionally** over all Dedekind-complete chains | reduction assets are unconditional (green) | `charF` correct **only** under `semantic_prior_UZ/SZ` (KampPrior.lean:407–420) |

**Conclusion:** Rabinovich's completeness does *not* require a single-point closed formula at interiors;
it requires the relation to survive. Option D preserves it; the **current** Lean `charF` (C′) destroys it
at `k≥2`. A *faithful* C′ would need a relation-preserving `charF` — which is exactly Rabinovich's E[Σ]
atom, and legitimately belongs to the downstream 309/350 extraction on Prior structures, **not** to the
depth-k carrier recursion inside 349.

### Q3 — Map to the green k=1 asset `bracketEndChar_k1v_complete`: which carrier does it realize, and does D or C′ generalize it to all k?

**The carrier type is syntactic**: `BracketEndCharCarrierV sig k := NormalForm sig k 3 → VVecEA2`
(CarrierK1V.lean:365) — a **closed-formula (VVecEA2 `.holds`) object**, i.e. **C′-family in shape**. Its
correctness (`BracketCarrierCorrectV`, CarrierK1V.lean:374–380) is exactly the biconditional
`(carrier qnf).holds M atomMap x t ↔ ∃ w, nf_eval_nf M k 3 [w,x,t] qnf`.

**`bracketEndChar_k1v_complete` (CarrierK1V.lean:1629–1637, verified sorry-free) realizes the COMPLETENESS
direction** in exactly the mission's sense:
`(∃ w, nf_eval_nf M 1 3 [w,x,t] qnf) → (bracketEndChar_k1v …).holds M atomMap x t`.

**How it works — and why it is a base case, not a template that generalizes for free:** the proof
destructures the witness `w`, splits depth-1 into atom+quant layers (`Iff.rfl`), applies the fold gate
(`nf_quant_layer_fold_k1_gate`), and — the decisive step — uses the **complete-type bridge**
`temporal_truth … (nf_depth0_char_formula …) ↔ nf_eval_nf M 0 1 (fun _=>u) χ'` (CarrierK1V.lean:1672–1675,
`nfPred_correct`). `nf_depth0_char_formula` is a **charF at depth 0**, and it is **unconditionally correct
because depth-0 arity-1 interior types are already closed formulas with no quantifier layer to project.**

So the k=1 green asset is **C′-shaped, and its C′ works only because the interior charF is at depth 0**
(no collapse possible). This is the crux:

- **C′ generalizes the k=1 SHAPE** by swapping `nf_depth0_char_formula` for `charF k =
  nf_characterizable_temporal_prior`. Same carrier type, same proof skeleton — but at `k≥2` the deeper
  `charF` **must** project the interior quant layer to `nfk_projFresh` (arity-1), re-entering the **F1
  collapse** and requiring `semantic_prior_UZ/SZ`. It is faithful to the paper **iff** F1-does-not-bite-
  under-Prior resolves favourably (an **UNRESOLVED** question — see reports 07/08, not re-adjudicated here).
- **D generalizes the k=1 CONTENT** (the `↔`, from `bracketEndChar_k1v_correct` :2041, wrap `.holds`) by
  **re-typing** the carrier to Prop-valued, so completeness becomes the reduction
  `endCharStep_quant_reduceA` (witness OUTSIDE, subs full-arity) + `nf_zone_flatten_navigable_correct`
  (Base.lean:687) — **no charF, no F1, green-only**. It does not literally reuse the syntactic bracket, but
  it **is** the faithful Lean analog of the paper's p.11 semantic biconditional
  `[bracket] ⟺ (∃z) (⋁A_i ∨ ⋁B_i)`.

**Neither generalizes the k=1 asset "for free."** C′ inherits the k=1 *shape* but re-enters a collapse the
depth-0 base structurally avoided; D changes the *type* but matches the paper's completeness mechanism and
consumes only green, unconditional assets.

---

## 3. Verdict: the completeness direction favors **Option D**

**Grounded in the paper AND the k=1 template:**

1. **Paper (Prop 4.2 / Lemma 5.1, p.9–11):** completeness proceeds by *semantic quantification over
   interior points* with sub-characterizations *threaded relationally from the IH*; the witness stays
   existential, endpoints stay explicit, and the closed-formula output preserves inter-point relations via
   **Until/Since nesting** (Cor 5.4, p.9) — **never** an arity-1 single-point projection. Interior E[Σ]
   atoms are correct **unconditionally** (no Prior hypothesis exists in the paper).

2. **k=1 template (`bracketEndChar_k1v_complete`):** the closed-formula/charF route succeeds at the base
   **only** because depth-0 interior types carry no quantifier layer. At `k≥2` the analogous
   `nf_characterizable_temporal_prior` **must** arity-1-project (`nfk_projFresh`, CarrierKv.lean:82/422) —
   the F1 collapse — which is the precise point where the paper's relation is preserved by nesting but the
   Lean charF is not.

3. **Option D** reproduces the paper's mechanism (subs at full arity, witness `v` OUTSIDE, `qnf.2`
   verbatim — `endCharStep_quant_reduceA`, NavigatedEndChar.lean:281, sorry-free/green) and side-steps F1
   entirely. **Option C′** is faithful to the paper's *output* form (closed formula) but its **current**
   Lean instantiation (`charF`) is an unfaithful arity-1 projection; C′ becomes paper-faithful only if
   `charF` is replaced by a relation-preserving characterization — which belongs to the 309/350 extraction
   on Prior structures, not to task 349's carrier.

**Therefore: the completeness direction favors Option D (Prop-valued).** This *converges* with reports 05
(Prop-valued, `x,t` explicit) and 08 (D as the F1-agnostic primary recommendation) and **adds** the
positive, paper-grounded reason absent there: D is not merely "F1-avoiding," it is the **faithful Lean
analog of Rabinovich's completeness engine** (the p.11 `[bracket] ⟺ (∃z)(⋁A_i∨⋁B_i)` semantic
biconditional with IH-threaded sub-brackets), whereas the current charF deviates from the paper's
relation-preserving Until/Since nesting.

**Honest counter-weight (does completeness ever favor C′?):** The paper's *deliverable* is a closed
formula, and E[Σ] closed interior atoms are paper-legitimate and unconditional. So closed-formula interiors
are **not** intrinsically unfaithful — the problem is specific to the Lean `charF`'s arity-1 projection.
If the team confirms F1-does-not-bite-under-Prior (reports 07/08's open question), C′ is *also* viable and
retains the syntactic `VVecEA2` codomain preferred by downstream 309/350 extraction. That gate is
**unresolved** and I do not resolve it here; the completeness-direction analysis makes **D** the
lower-risk, F1-free, green-only faithful choice.

---

## 4. Cross-reference to reports 05–08 (no repetition)

- **05** (Prop-valued, `x,t` explicit): I supply the paper-level *completeness* justification for its
  Prop-valued recommendation — the p.11 semantic biconditional and the relation-preservation requirement.
- **06** (multi-anchor navigating characteristic / §4.5 ≤3-anchor merge): the k-induction discharge it
  identified is the Lean analog of Lemma 5.1's interior-point split (p.10–11); the k=1 kit is the base.
- **07** (Def 7.13 "adjacent 2-endpoint pieces, never one-point read", p.15): I confirm from the PDF and
  connect it to *why* C′'s single-point charF projection is the faithfulness break.
- **08** (D primary / C′ conditional on F1-under-Prior): I **corroborate** the D recommendation and
  **strengthen** it with the positive paper-grounded completeness argument; I **do not** re-adjudicate the
  F1-under-Prior gate (still UNRESOLVED — deferred to reports 07/08 and downstream).

---

## 5. Adversarial Self-Verification (H4)

### 5.1 Claim Verification Table

| Claim | Source / Counterexample | Verification Method | Confidence |
|---|---|---|---|
| Completeness direction = Thm 2.1(2)/Thm 4.4 (FOMLO→TL), proved via Prop 4.3 (structural induction) + Prop 4.2 (negation closure) + Prop 3.5 | Rabinovich p.3, p.5, p.6 | direct PDF read (equations intact) | High |
| ∃∀ normal form encodes ∃-witness chain `xₙ>…>x₀` with α AT points, β ALONG intervals, endpoints pinned | Rabinovich p.4, Def 3.1 (full display captured) | direct PDF read | High |
| Prop 4.2 is the **two-free-variable** closure; §5 splits `k=m`/`k≠m` and isolates the interior bracket `[α₀,…,αₙ](z₀,z₁)` | Rabinovich p.6, p.7–8, Notation 5.2 | direct PDF read | High |
| Completeness engine threads interior **sub-brackets** `A_i^±,B_i^±` from the IH; witness stays ∃, endpoints explicit; `[bracket]⟺(∃z)(⋁A_i∨⋁B_i)` | Rabinovich p.10–11 (biconditionals displayed) | direct PDF read | High |
| Closed-formula output preserves inter-point relation via `β_i Until F_i` nesting, not arity-1 projection | Rabinovich p.9, Cor 5.4; p.5 Prop 3.5 | direct PDF read | High |
| Paper's interior atoms (E[Σ]) are correct **unconditionally** over all Dedekind-complete chains (no "Prior" hypothesis in paper) | Rabinovich p.5 Def 4.1, p.3 Thm 2.1; absence of any Prior-style side condition across pp.1–16 | direct PDF read + absence check | Medium (rests partly on absence) |
| `BracketEndCharCarrierV sig k := NormalForm sig k 3 → VVecEA2` (syntactic, C′-shaped) | CarrierK1V.lean:365 | source read (exact line) | High |
| `bracketEndChar_k1v_complete` realizes completeness `(∃w,nf_eval)→carrier.holds`, and is sorry-free | CarrierK1V.lean:1629–1637; `awk` sorry-scan of lines 988–2216 returned empty | source read + text scan | High |
| k=1 completeness works via a **depth-0** charF (`nf_depth0_char_formula`), unconditional because depth-0 arity-1 types carry no quant layer | CarrierK1V.lean:1672–1675 (`nfPred_correct` bridge) | source read | High |
| At `k≥2`, `charF = nf_characterizable_temporal_prior` projects interior to arity-1 `nfk_projFresh` (F1 collapse), correct only under `semantic_prior_UZ/SZ` | KampPrior.lean:407–420; CarrierKv.lean:82, 249, 422 | source read | High |
| Option D route assets green/sorry-free, witness OUTSIDE, `qnf.2` verbatim, no arity-collapse | NavigatedEndChar.lean:281; v5-phase2 handoff JSON (`lean_verify` = [propext, Classical.choice, Quot.sound], no sorry); Base.lean:687 | source read + handoff record | Medium-High |
| Completeness direction **favors D** | synthesis of the above | inference from paper mechanism + k=1 mechanism | Medium-High |
| Whether a Prior-guarded C′ (`charF`) is ALSO completeness-faithful | reports 07/08 F1-under-Prior gate | NOT resolved here | **Low (UNRESOLVED, by design)** |

### 5.2 Flagged / ungrounded-risk claims

- **"Unconditional over all Dedekind-complete chains"** rests partly on the *absence* of a Prior-style
  hypothesis in the paper. I read all 16 pages; the only structural hypothesis is **Dedekind completeness**
  (p.3, footnote p.2). No epistemic/Prior condition appears. Confidence Medium (absence-based).
- **The D-route greenness** for the *step* (Phases 4/5, the ≤3-anchor navigation discharge under the IH)
  is **not yet proved** — only the Step-A reduction (`endCharStep_quant_reduceA`) is green. I do **not**
  claim D is fully implemented, only that its completeness obligation matches the paper and its consumed
  assets are green. Flagged as Medium-High, not High.
- I explicitly **decline** to resolve the F1-under-Prior gate (reports 07/08). If it resolves in C′'s
  favour, C′ is also completeness-viable and retains the syntactic codomain. My verdict is a
  **risk-weighted preference for D**, not a proof that C′ is completeness-impossible.

### 5.3 Contradiction log

No unresolved contradiction with the paper. One **apparent** tension resolved: the paper's *output* is a
closed formula (surface reading → C′), but its *argument* is relation-preserving and semantic (→ D). The
resolution is that "closed formula" is paper-faithful **only** when relation-preserving (Until/Since
nesting / E[Σ] atoms); the current Lean `charF` is not, at `k≥2`. Hence D for the 349 carrier; a
relation-preserving closed formula belongs to 309/350.

### 5.4 Recommendations modified after verification

Initial instinct after reading Prop 3.5/Cor 5.4 was "the paper produces closed formulas → C′." Adversarial
re-reading of p.10–11 (the completeness *engine*) and CarrierK1V.lean:1672 (k=1 uses a *depth-0* charF that
cannot collapse) **demoted C′ to conditional** and promoted **D** as the completeness-faithful,
collapse-free primary — matching reports 05/08 but on independent, paper-grounded evidence.

---

## 6. Memory candidates

1. Rabinovich's completeness engine (p.10–11) characterizes a two-endpoint bracket by
   `[bracket](z₀,z₁) ⟺ (∃z)^{<z₁}_{>z₀}(⋁A_i ∨ ⋁B_i)` where `A_i,B_i` are sub-brackets on `(z₀,z)`,`(z,z₁)`
   threaded from the IH — witness ∃ and endpoints explicit. The Lean-faithful analog is a **Prop-valued**
   carrier threading the IH (Option D), NOT a per-witness closed formula.
2. The green k=1 `bracketEndChar_k1v_complete` (CarrierK1V.lean:1629) is **C′-shaped** (syntactic VVecEA2)
   but its completeness works ONLY because it uses a **depth-0** charF (`nf_depth0_char_formula`,
   :1672) that is unconditional (no quant layer to project). At `k≥2` the depth-k charF
   (`nf_characterizable_temporal_prior`) must arity-1-project (F1) — so the k=1 asset is a base case, not a
   template that generalizes the C′ shape without collapse.
3. The paper has **no Prior/epistemic hypothesis** anywhere (16 pages); its only structural assumption is
   **Dedekind completeness** (p.3). Thus the Lean `charF`'s `semantic_prior_UZ/SZ` side condition is a
   Lean-specific artifact of the arity-1 projection, not a Rabinovich requirement — a point favoring the
   unconditional Option D for the carrier and localizing Prior-guarded charF to the 309/350 extraction.
